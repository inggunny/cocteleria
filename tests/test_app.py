import unittest
import tempfile
from decimal import Decimal
from pathlib import Path

from sqlalchemy import text

from app import create_app, db, Product, Movement, Cocktail


class StockTests(unittest.TestCase):
    def setUp(self):
        self.app = create_app({'TESTING': True, 'SQLALCHEMY_DATABASE_URI': 'sqlite://',
                               'SECRET_KEY': 'test-secret', 'ADMIN_PASSWORD': 'test-password'})
        self.client = self.app.test_client()
        self.client.get('/login')
        with self.client.session_transaction() as session:
            self.csrf = session['csrf']
        self.post('/login', password='test-password')
        with self.client.session_transaction() as session:
            self.csrf = session['csrf']

    def post(self, path, **data):
        return self.client.post(path, data={'csrf': self.csrf, **data}, follow_redirects=True)

    def product(self, **extra):
        return self.post('/products', **({'name': 'Gin', 'sku': 'GIN-1', 'category': 'Destilados',
                                        'unit': 'botella', 'minimum': '2', 'cost': '1000.50'} | extra))

    def move(self, kind, quantity):
        return self.post('/movements', product_id='1', kind=kind, quantity=quantity, note='Prueba')

    def stock(self):
        with self.app.app_context():
            return db.session.get(Product, 1).stock

    def test_auth_and_csrf(self):
        client = self.app.test_client()
        self.assertEqual(client.get('/').status_code, 302)
        self.assertEqual(client.post('/products').status_code, 400)

    def test_stock_flow_and_history(self):
        self.assertEqual(self.product().status_code, 200)
        self.move('Entrada', '10.5')
        self.move('Salida', '2')
        self.move('Merma', '0.5')
        self.assertEqual(self.stock(), Decimal('8'))
        self.move('Inventario', '3')
        self.assertEqual(self.stock(), Decimal('3'))
        with self.app.app_context():
            self.assertEqual(db.session.query(Movement).count(), 4)
            last = db.session.get(Movement, 4)
            self.assertEqual(last.quantity, Decimal('-5'))
            self.assertEqual(last.balance, Decimal('3'))

    def test_invalid_stock_changes_are_atomic(self):
        self.product()
        self.move('Entrada', '2')
        for quantity in ('3', '-1', 'NaN', 'Infinity', '0', '0.0001'):
            self.move('Salida', quantity)
            self.assertEqual(self.stock(), Decimal('2'))
        with self.app.app_context():
            self.assertEqual(db.session.query(Movement).count(), 1)

    def test_duplicate_edit_and_archive(self):
        self.product()
        self.product()
        with self.app.app_context():
            self.assertEqual(db.session.query(Product).count(), 1)
        self.move('Entrada', '1')
        self.post('/products/1/archive')
        with self.app.app_context():
            self.assertTrue(db.session.get(Product, 1).active)
        self.product(id='1', unit='litro')
        with self.app.app_context():
            self.assertEqual(db.session.get(Product, 1).unit, 'botella')
        self.move('Inventario', '0')
        self.post('/products/1/archive')
        with self.app.app_context():
            self.assertFalse(db.session.get(Product, 1).active)
            self.assertEqual(db.session.query(Movement).count(), 2)

    def test_csv_and_safe_rendering(self):
        self.product(name='<script>alert(1)</script>', sku='=1+1')
        page = self.client.get('/').get_data(as_text=True)
        self.assertNotIn('<script>alert(1)</script>', page)
        self.assertIn('&lt;script&gt;', page)
        export = self.client.get('/export.csv')
        self.assertIn("'=1+1", export.get_data(as_text=True))
        self.assertIn('attachment', export.headers['Content-Disposition'])

    def test_edit_stock_records_adjustment_and_allows_zero(self):
        self.product(stock='5')
        self.assertEqual(self.stock(), Decimal('5'))
        self.product(id='1', stock='8.5', original_stock='5')
        self.assertEqual(self.stock(), Decimal('8.5'))
        with self.app.app_context():
            movement = db.session.get(Movement, 2)
            self.assertEqual(movement.quantity, Decimal('3.5'))
            self.assertEqual(movement.balance, Decimal('8.5'))
            self.assertEqual(movement.kind, 'Inventario')
        self.product(id='1', stock='8.5', original_stock='8.5')
        with self.app.app_context():
            self.assertEqual(db.session.query(Movement).count(), 2)
        self.product(id='1', stock='0', original_stock='8.5')
        self.assertEqual(self.stock(), Decimal('0'))

    def test_edit_rejects_invalid_and_stale_stock(self):
        self.product(stock='5')
        for quantity in ('-1', 'NaN', '0.0001'):
            self.product(id='1', stock=quantity, original_stock='5', name='Cambio inválido')
            self.assertEqual(self.stock(), Decimal('5'))
        self.move('Entrada', '1')
        response = self.product(id='1', stock='10', original_stock='5', name='Cambio vencido')
        self.assertIn('El stock cambió', response.get_data(as_text=True))
        self.assertEqual(self.stock(), Decimal('6'))
        with self.app.app_context():
            self.assertEqual(db.session.get(Product, 1).name, 'Gin')
            self.assertEqual(db.session.query(Movement).count(), 2)

    def test_brand_create_edit_validation_and_export(self):
        self.product(brand='  Bombay Sapphire  ')
        with self.app.app_context():
            self.assertEqual(db.session.get(Product, 1).brand, 'Bombay Sapphire')
        page = self.client.get('/').get_data(as_text=True)
        self.assertIn('Bombay Sapphire', page)
        self.assertIn('name="brand"', page)
        self.product(id='1', brand='Otra marca')
        self.assertIn('Otra marca', self.client.get('/export.csv').get_data(as_text=True))
        self.product(id='1', brand='x' * 61)
        with self.app.app_context():
            self.assertEqual(db.session.get(Product, 1).brand, 'Otra marca')
        self.product(id='1', brand='')
        with self.app.app_context():
            self.assertEqual(db.session.get(Product, 1).brand, '')

    def test_existing_database_gains_brand_without_losing_products(self):
        with tempfile.TemporaryDirectory() as directory:
            config = {'TESTING': True, 'SQLALCHEMY_DATABASE_URI': 'sqlite:///' + str(Path(directory) / 'old.sqlite')}
            first = create_app(config)
            with first.app_context():
                db.session.add(Product(name='Gin existente', sku='OLD', category='Destilados', unit='botella', stock=7))
                db.session.commit()
                db.session.execute(text('ALTER TABLE product DROP COLUMN brand'))
                db.session.commit()
                db.session.remove()
                db.engine.dispose()
            for _ in range(2):
                migrated = create_app(config)
                with migrated.app_context():
                    product = db.session.get(Product, 1)
                    self.assertEqual(product.name, 'Gin existente')
                    self.assertEqual(product.stock, Decimal('7'))
                    self.assertEqual(product.brand, '')
                    db.session.remove()
                    db.engine.dispose()

    def recipe(self, path='/cocktails/new', **extra):
        return self.post(path, **({'name': 'Gin tonic', 'description': 'Fresco y cítrico',
                                  'price': '5000', 'published': 'on',
                                  'product_id': ['1'], 'quantity': ['0.05']} | extra))

    def test_public_menu_tracks_stock_and_does_not_expose_inventory(self):
        self.product(stock='0.05', cost='1234.56')
        self.assertEqual(self.recipe().status_code, 200)
        visitor = self.app.test_client()
        page = visitor.get('/carta')
        self.assertEqual(page.status_code, 200)
        self.assertEqual(page.headers['Cache-Control'], 'no-store')
        self.assertIn('Gin tonic', page.get_data(as_text=True))
        self.assertNotIn('1234.56', page.get_data(as_text=True))
        self.assertNotIn('GIN-1', page.get_data(as_text=True))
        self.assertEqual(self.stock(), Decimal('0.05'))
        self.move('Salida', '0.001')
        self.assertNotIn('Gin tonic', visitor.get('/carta').get_data(as_text=True))
        self.move('Entrada', '0.001')
        self.assertIn('Gin tonic', visitor.get('/carta').get_data(as_text=True))

    def test_all_ingredients_required_and_unpublished_hidden(self):
        self.product(stock='1')
        self.product(name='Tónica', sku='TONIC', stock='0', unit='litro')
        self.recipe(product_id=['1', '2'], quantity=['0.05', '0.15'])
        self.assertNotIn('Gin tonic', self.app.test_client().get('/carta').get_data(as_text=True))
        self.post('/movements', product_id='2', kind='Entrada', quantity='1', note='Compra')
        self.assertIn('Gin tonic', self.app.test_client().get('/carta').get_data(as_text=True))
        self.recipe('/cocktails/1/edit', published='', product_id=['1', '2'], quantity=['0.05', '0.15'])
        self.assertNotIn('Gin tonic', self.app.test_client().get('/carta').get_data(as_text=True))

    def test_recipe_validation_and_atomic_edit(self):
        self.product(stock='1')
        for extra in ({'product_id': [], 'quantity': []}, {'quantity': ['0']},
                      {'quantity': ['NaN']}, {'product_id': ['999']},
                      {'product_id': ['1', '1'], 'quantity': ['0.05', '0.05']}):
            self.recipe(**extra)
            with self.app.app_context():
                self.assertEqual(db.session.query(Cocktail).count(), 0)
        self.recipe()
        self.recipe('/cocktails/1/edit', name='Receta inválida', quantity=['-1'])
        with self.app.app_context():
            cocktail = db.session.get(Cocktail, 1)
            self.assertEqual(cocktail.name, 'Gin tonic')
            self.assertEqual(cocktail.ingredients[0].quantity, Decimal('0.05'))
        self.recipe('/cocktails/1/edit', quantity=['0.1'], price='6000')
        with self.app.app_context():
            cocktail = db.session.get(Cocktail, 1)
            self.assertEqual(len(cocktail.ingredients), 1)
            self.assertEqual(cocktail.ingredients[0].quantity, Decimal('0.1'))

    def test_cocktail_management_is_private_and_forms_render(self):
        visitor = self.app.test_client()
        for path in ('/cocktails', '/cocktails/new', '/cocktails/1/edit'):
            self.assertEqual(visitor.get(path).status_code, 302)
        visitor.get('/carta')
        with visitor.session_transaction() as session:
            token = session['csrf']
        self.assertEqual(visitor.post('/cocktails/new', data={'csrf': token}).status_code, 302)
        self.product()
        self.assertEqual(self.client.get('/cocktails/new').status_code, 200)
        self.recipe()
        self.assertEqual(self.client.get('/cocktails/1/edit').status_code, 200)
        self.product(id='1', unit='litro')
        with self.app.app_context():
            self.assertEqual(db.session.get(Product, 1).unit, 'botella')
        self.post('/products/1/archive')
        self.assertNotIn('Gin tonic', visitor.get('/carta').get_data(as_text=True))


if __name__ == '__main__':
    unittest.main()
