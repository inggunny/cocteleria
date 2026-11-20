import csv
import io
import os
import secrets
from datetime import datetime, timezone
from decimal import Decimal, InvalidOperation
from functools import wraps
from hmac import compare_digest

from flask import Flask, Response, flash, redirect, render_template, request, session, url_for
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import CheckConstraint, inspect, select, text
from sqlalchemy.exc import IntegrityError

db = SQLAlchemy()


class Product(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    sku = db.Column(db.String(60), unique=True, nullable=False)
    category = db.Column(db.String(60), nullable=False)
    brand = db.Column(db.String(60), nullable=False, default='', server_default='')
    unit = db.Column(db.String(20), nullable=False)
    stock = db.Column(db.Numeric(12, 3), nullable=False, default=0)
    minimum = db.Column(db.Numeric(12, 3), nullable=False, default=0)
    cost = db.Column(db.Numeric(12, 2), nullable=False, default=0)
    active = db.Column(db.Boolean, nullable=False, default=True)
    __table_args__ = (CheckConstraint('stock >= 0 AND minimum >= 0 AND cost >= 0'),)


class Movement(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)
    product = db.relationship(Product)
    kind = db.Column(db.String(20), nullable=False)
    quantity = db.Column(db.Numeric(12, 3), nullable=False)
    balance = db.Column(db.Numeric(12, 3), nullable=False)
    note = db.Column(db.String(250), nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=lambda: datetime.now(timezone.utc))


class Cocktail(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    description = db.Column(db.String(500), nullable=False, default='')
    price = db.Column(db.Numeric(12, 2), nullable=False)
    published = db.Column(db.Boolean, nullable=False, default=True)
    ingredients = db.relationship('Ingredient', cascade='all, delete-orphan', lazy='selectin')
    __table_args__ = (CheckConstraint('price >= 0'),)

    @property
    def available(self):
        return bool(self.ingredients) and all(i.product.active and i.product.stock >= i.quantity for i in self.ingredients)


class Ingredient(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    cocktail_id = db.Column(db.Integer, db.ForeignKey('cocktail.id'), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)
    product = db.relationship(Product, lazy='joined')
    quantity = db.Column(db.Numeric(12, 3), nullable=False)
    __table_args__ = (CheckConstraint('quantity > 0'), db.UniqueConstraint('cocktail_id', 'product_id'))


def number(value, places=3):
    try:
        result = Decimal(value.replace(',', '.'))
        if not result.is_finite() or result < 0 or result > Decimal('999999999'):
            raise ValueError('El importe o cantidad está fuera de rango.')
        if result != result.quantize(Decimal(10) ** -places):
            raise ValueError(f'Se permiten hasta {places} decimales.')
        return result
    except (InvalidOperation, AttributeError):
        raise ValueError('Ingresá una cantidad numérica válida.')


def create_app(config=None):
    app = Flask(__name__)
    app.config.update(SECRET_KEY=os.environ.get('SECRET_KEY') or secrets.token_hex(32),
                      SQLALCHEMY_DATABASE_URI=os.environ.get('DATABASE_URL', 'sqlite:///bar.sqlite'),
                      ADMIN_PASSWORD=os.environ.get('ADMIN_PASSWORD', ''),
                      SESSION_COOKIE_HTTPONLY=True, SESSION_COOKIE_SAMESITE='Lax',
                      MAX_CONTENT_LENGTH=64 * 1024)
    if config:
        app.config.update(config)
    db.init_app(app)
    with app.app_context():
        db.create_all()
        # Actualización compatible con bases ya existentes; no elimina productos.
        with db.engine.begin() as connection:
            if connection.dialect.name == 'postgresql':
                connection.execute(text('SELECT pg_advisory_xact_lock(72503101)'))
            if 'brand' not in {column['name'] for column in inspect(connection).get_columns('product')}:
                connection.execute(text("ALTER TABLE product ADD COLUMN brand VARCHAR(60) NOT NULL DEFAULT ''"))

    def protected(fn):
        @wraps(fn)
        def wrapped(*args, **kwargs):
            if not session.get('authenticated'):
                return redirect(url_for('login'))
            return fn(*args, **kwargs)
        return wrapped

    @app.before_request
    def csrf_check():
        if 'csrf' not in session:
            session['csrf'] = secrets.token_hex(32)
        if request.method == 'POST' and not compare_digest(session['csrf'], request.form.get('csrf', '')):
            return 'Formulario vencido. Recargá la página.', 400

    @app.get('/health')
    def health():
        db.session.execute(text('SELECT 1'))
        return {'status': 'ok'}

    @app.route('/login', methods=['GET', 'POST'])
    def login():
        if request.method == 'POST':
            password = app.config['ADMIN_PASSWORD']
            if password and compare_digest(password.encode(), request.form.get('password', '').encode()):
                session.clear()
                session['authenticated'] = True
                session['csrf'] = secrets.token_hex(32)
                return redirect(url_for('index'))
            flash('Clave incorrecta o acceso sin configurar.', 'error')
        return render_template('login.html')

    @app.post('/logout')
    def logout():
        session.clear()
        return redirect(url_for('login'))

    @app.get('/')
    @protected
    def index():
        products = db.session.scalars(select(Product).where(Product.active).order_by(Product.name)).all()
        movements = db.session.scalars(select(Movement).order_by(Movement.id.desc()).limit(100)).all()
        return render_template('index.html', products=products, movements=movements,
                               low=sum(p.stock <= p.minimum for p in products),
                               value=sum(p.stock * p.cost for p in products))

    @app.post('/products')
    @protected
    def save_product():
        try:
            name = request.form.get('name', '').strip()
            sku = request.form.get('sku', '').strip().upper()
            category = request.form.get('category', '').strip()
            brand = request.form.get('brand', '').strip()
            if len(brand) > 60:
                raise ValueError('La marca admite hasta 60 caracteres.')
            unit = request.form.get('unit', '')
            if not name or len(name) > 120 or not sku or len(sku) > 60 or not category or len(category) > 60:
                raise ValueError('Completá nombre, código y categoría respetando sus límites.')
            if unit not in ('unidad', 'botella', 'litro', 'kg'):
                raise ValueError('Elegí una unidad válida.')
            product_id = request.form.get('id')
            if product_id and not product_id.isdecimal():
                raise ValueError('Identificador de producto inválido.')
            product_id = int(product_id) if product_id else None
            product = db.session.scalar(select(Product).where(Product.id == product_id).with_for_update()) if product_id else Product(stock=0)
            if product is None:
                raise ValueError('El producto no existe.')
            if product_id and not product.active:
                raise ValueError('El producto está archivado.')
            stock = number(request.form['stock']) if 'stock' in request.form else product.stock
            if product_id and 'stock' in request.form:
                original_stock = number(request.form.get('original_stock', ''))
                if original_stock != product.stock:
                    raise ValueError('El stock cambió mientras editabas. Recargá la página antes de guardar.')
            if product_id and product.unit != unit and (
                db.session.scalar(select(Movement.id).where(Movement.product_id == product.id).limit(1)) or
                db.session.scalar(select(Ingredient.id).where(Ingredient.product_id == product.id).limit(1))
            ):
                raise ValueError('No se puede cambiar la unidad de un producto con movimientos o recetas. Creá otro producto.')
            product.name, product.sku, product.category, product.unit = name, sku, category, unit
            product.brand = brand
            product.minimum = number(request.form.get('minimum', '0'))
            product.cost = number(request.form.get('cost', '0'), 2)
            db.session.add(product)
            if stock != product.stock:
                db.session.add(Movement(product=product, kind='Inventario', quantity=stock - product.stock,
                                        balance=stock, note='Ajuste desde el formulario de producto' if product_id else 'Stock inicial'))
                product.stock = stock
            db.session.commit()
            flash('Producto guardado.', 'success')
        except (ValueError, IntegrityError) as error:
            db.session.rollback()
            flash(str(error) if isinstance(error, ValueError) else 'Ya existe un producto con ese código, incluso archivado.', 'error')
        return redirect(url_for('index'))

    @app.post('/movements')
    @protected
    def movement():
        try:
            product_id = request.form.get('product_id', type=int)
            product = db.session.scalar(select(Product).where(Product.id == product_id, Product.active).with_for_update())
            if not product:
                raise ValueError('Seleccioná un producto activo.')
            quantity = number(request.form.get('quantity', ''))
            kind = request.form.get('kind')
            note = request.form.get('note', '').strip()
            if kind not in ('Entrada', 'Salida', 'Merma', 'Inventario') or not note or len(note) > 250:
                raise ValueError('Elegí un tipo e ingresá un motivo (hasta 250 caracteres).')
            if kind != 'Inventario' and quantity == 0:
                raise ValueError('La cantidad debe ser mayor que cero.')
            balance = quantity if kind == 'Inventario' else product.stock + (quantity if kind == 'Entrada' else -quantity)
            if balance < 0:
                raise ValueError('Stock insuficiente para registrar esa salida.')
            if balance > Decimal('999999999.999'):
                raise ValueError('El stock resultante supera el límite permitido.')
            delta = balance - product.stock
            product.stock = balance
            db.session.add(Movement(product=product, kind=kind, quantity=delta, balance=balance, note=note))
            db.session.commit()
            flash('Movimiento registrado.', 'success')
        except (ValueError, IntegrityError) as error:
            db.session.rollback()
            flash(str(error) if isinstance(error, ValueError) else 'No se pudo registrar el movimiento.', 'error')
        return redirect(url_for('index'))

    @app.post('/products/<int:product_id>/archive')
    @protected
    def archive(product_id):
        product = db.session.scalar(select(Product).where(Product.id == product_id).with_for_update())
        if product is None:
            return 'Producto inexistente', 404
        if product.stock != 0:
            flash('Solo se pueden archivar productos sin existencias.', 'error')
        else:
            product.active = False
            db.session.commit()
            flash('Producto archivado. Su historial se conserva.', 'success')
        return redirect(url_for('index'))

    @app.get('/carta')
    def menu():
        cocktails = db.session.scalars(select(Cocktail).where(Cocktail.published).order_by(Cocktail.name)).all()
        response = app.make_response(render_template('menu.html', cocktails=[c for c in cocktails if c.available]))
        response.headers['Cache-Control'] = 'no-store'
        return response

    @app.get('/cocktails')
    @protected
    def cocktails():
        recipes = db.session.scalars(select(Cocktail).order_by(Cocktail.name)).all()
        return render_template('cocktails.html', cocktails=recipes)

    @app.route('/cocktails/new', methods=['GET', 'POST'])
    @app.route('/cocktails/<int:cocktail_id>/edit', methods=['GET', 'POST'])
    @protected
    def cocktail_form(cocktail_id=None):
        cocktail = db.get_or_404(Cocktail, cocktail_id) if cocktail_id else None
        products = db.session.scalars(select(Product).where(Product.active).order_by(Product.name)).all()
        rows = [{'product_id': i.product_id, 'quantity': str(i.quantity)} for i in cocktail.ingredients] if cocktail else []
        if request.method == 'POST':
            ids = request.form.getlist('product_id')
            quantities = request.form.getlist('quantity')
            rows = [{'product_id': pid, 'quantity': quantities[n] if n < len(quantities) else ''} for n, pid in enumerate(ids)]
            try:
                name = request.form.get('name', '').strip()
                description = request.form.get('description', '').strip()
                if not name or len(name) > 120 or len(description) > 500:
                    raise ValueError('Ingresá un nombre (hasta 120 caracteres) y una descripción de hasta 500 caracteres.')
                price = number(request.form.get('price', ''), 2)
                if not 1 <= len(ids) <= 30 or len(ids) != len(quantities):
                    raise ValueError('La receta debe incluir entre 1 y 30 ingredientes con sus cantidades.')
                ingredients = []
                seen = set()
                for pid, value in zip(ids, quantities):
                    product = db.session.get(Product, int(pid)) if pid.isdecimal() else None
                    if not product or not product.active:
                        raise ValueError('Seleccioná productos activos para todos los ingredientes.')
                    if product.id in seen:
                        raise ValueError('Cada producto debe aparecer una sola vez; sumá sus cantidades.')
                    seen.add(product.id)
                    quantity = number(value)
                    if quantity <= 0:
                        raise ValueError('Las cantidades de la receta deben ser mayores que cero.')
                    ingredients.append(Ingredient(product=product, quantity=quantity))
                if cocktail is None:
                    cocktail = Cocktail()
                    db.session.add(cocktail)
                else:
                    cocktail.ingredients.clear()
                    db.session.flush()
                cocktail.name, cocktail.description, cocktail.price = name, description, price
                cocktail.published = request.form.get('published') == 'on'
                cocktail.ingredients = ingredients
                db.session.commit()
                flash('Cóctel guardado. La carta se actualiza según las existencias.', 'success')
                return redirect(url_for('cocktails'))
            except (ValueError, IntegrityError) as error:
                db.session.rollback()
                flash(str(error) if isinstance(error, ValueError) else 'No se pudo guardar la receta.', 'error')
        return render_template('cocktail_form.html', cocktail=cocktail, products=products, rows=rows or [{'product_id': '', 'quantity': ''}])

    @app.get('/export.csv')
    @protected
    def export():
        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow(['Código', 'Producto', 'Categoría', 'Marca', 'Unidad', 'Stock', 'Mínimo', 'Costo unitario'])
        for p in db.session.scalars(select(Product).where(Product.active).order_by(Product.name)):
            # Evitar fórmulas ejecutables al abrir datos de texto en una planilla.
            safe = lambda s: "'" + s if s.startswith(('=', '+', '-', '@', '\t', '\r', '\n')) else s
            writer.writerow([safe(p.sku), safe(p.name), safe(p.category), safe(p.brand), p.unit, p.stock, p.minimum, p.cost])
        return Response('\ufeff' + output.getvalue(), mimetype='text/csv', headers={'Content-Disposition': 'attachment; filename=stock.csv'})

    return app


app = create_app()
