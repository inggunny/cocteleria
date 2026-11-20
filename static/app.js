document.querySelectorAll('[data-open]').forEach(button => button.addEventListener('click', () => {
  if (button.dataset.open === 'product-dialog') {
    document.querySelector('#product-form').reset();
    document.querySelector('#product-form [name=id]').value = '';
    document.querySelector('#product-title').textContent = 'Nuevo producto';
  }
  document.getElementById(button.dataset.open).showModal();
}));
document.querySelectorAll('.close').forEach(button => button.addEventListener('click', () => button.closest('dialog').close()));
document.querySelectorAll('.edit').forEach(button => button.addEventListener('click', () => {
  const product = JSON.parse(button.dataset.product);
  const form = document.querySelector('#product-form');
  for (const [key, value] of Object.entries(product)) form.elements.namedItem(key).value = value;
  document.querySelector('#product-title').textContent = 'Editar producto';
  document.querySelector('#product-dialog').showModal();
}));
document.querySelectorAll('.archive').forEach(form => form.addEventListener('submit', event => {
  if (!confirm('¿Archivar este producto? Se conservará su historial.')) event.preventDefault();
}));
function filterProducts() {
  const search = document.querySelector('#search').value.toLocaleLowerCase().trim();
  const category = document.querySelector('#category-filter').value;
  const status = document.querySelector('#status-filter').value;
  let count = 0;
  document.querySelectorAll('.product-row').forEach(row => {
    row.hidden = !row.dataset.search.includes(search) || (category && row.dataset.category !== category) || (status && row.dataset.status !== status);
    if (!row.hidden) count++;
  });
  document.querySelector('#result-count').textContent = `${count} productos`;
  document.querySelector('#no-results').hidden = count > 0;
}
['search', 'category-filter', 'status-filter'].forEach(id => document.getElementById(id)?.addEventListener('input', filterProducts));
document.querySelector('#movement-kind')?.addEventListener('change', event => {
  const inventory = event.target.value === 'Inventario';
  document.querySelector('#quantity').min = inventory ? '0' : '0.001';
  document.querySelector('#movement-hint').textContent = inventory ? 'Inventario establece el stock total contado. Ingresá la existencia real, incluso cero.' : 'Entrada suma stock; salida y merma lo descuentan.';
});
