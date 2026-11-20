const recipeRows = document.getElementById('recipe-rows');
document.getElementById('add-ingredient').addEventListener('click', () => {
  if (recipeRows.children.length >= 30) return;
  recipeRows.append(document.getElementById('ingredient-template').content.cloneNode(true));
});
recipeRows.addEventListener('click', event => {
  if (!event.target.closest('.remove-ingredient')) return;
  const row = event.target.closest('.ingredient-row');
  if (recipeRows.children.length > 1) row.remove();
  else row.querySelectorAll('input, select').forEach(input => input.value = '');
});
