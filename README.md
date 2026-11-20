# Barra · Gestión de stock para un bar

Aplicación web en español con Flask, PostgreSQL 17 y Docker Compose. Incluye una interfaz adaptable a celulares y computadoras, acceso con clave y datos persistentes.

## Iniciar

Requisitos: Docker Engine y Docker Compose v2.

```bash
cp .env.example .env
```

Editá `.env` y reemplazá las tres claves de ejemplo. Usá una clave **alfanumérica** para `DB_PASSWORD`, ya que forma parte de la URL de conexión. Podés generar claves con `openssl rand -hex 32`.

```bash
docker compose up --build -d
```

Abrí **http://localhost:8000** e ingresá con `ADMIN_PASSWORD`. La base se inicializa automáticamente; el catálogo comienza vacío. El puerto puede cambiarse con `PORT` en `.env`.

## Uso

1. Cargá un producto con código único, nombre, categoría, marca, unidad, cantidad existente, mínimo y costo de compra. El stock inicial queda registrado en el historial.
2. Registrá una **Entrada** para cargar una compra. También podés corregir la **Cantidad existente** desde **Editar producto**: se registra un ajuste de inventario por la diferencia. Si hubo otro movimiento mientras editabas, se pide recargar para evitar sobrescribirlo.
3. Registrá **Salida** para consumos o ventas, y **Merma** para pérdidas. Ambas descuentan stock.
4. Usá **Inventario** para establecer la cantidad real contada: ingresar 5 deja el stock en 5, y el historial guarda la diferencia aplicada. Se admite cero.
5. Consultá las alertas de reposición, buscá por nombre, código o marca, filtrá por categoría/estado y exportá el catálogo a CSV.

Se permiten tres decimales en cantidades y dos en costos. Las existencias nunca pueden quedar negativas. PostgreSQL bloquea la fila del producto durante cada movimiento para evitar pérdidas de actualización entre operaciones simultáneas. Todos los movimientos requieren un motivo y conservan fecha UTC, variación y saldo resultante. La interfaz muestra los últimos 100; los anteriores permanecen en la base.

Podés editar los datos de un producto; su unidad queda fija desde el primer movimiento. Solo se pueden archivar productos en cero y su historial se conserva. Los códigos archivados no se pueden reutilizar. El valor total usa el costo actual por producto, expresado en pesos ($), sin contabilidad de lotes ni costo promedio histórico.

## Carta pública y recetas

Desde **Cócteles** en la gestión podés crear y editar recetas con nombre, descripción, precio de venta e ingredientes del inventario. Cada ingrediente lleva la cantidad necesaria **por una porción**, expresada en la misma unidad que su producto. La marca ayuda a distinguir productos al elegir ingredientes.

Ejemplo para un gin tonic: si registrás gin en litros, una porción puede llevar `0.05` litro de gin y `0.15` litro de tónica. Si registrás botellas de un litro, `0.05` botella equivale a 50 ml. El sistema no conoce el tamaño de las botellas ni convierte unidades: para dosificar con precisión, conviene registrar líquidos en litros. Las cantidades admiten hasta tres decimales. Cada ingrediente corresponde a un producto específico; no se sustituyen marcas automáticamente.

La opción **Publicar cuando haya ingredientes disponibles** habilita el cóctel para la carta. Para retirarlo manualmente, desmarcala y guardá. `/carta` es accesible sin iniciar sesión, muestra únicamente los cócteles publicados con stock suficiente para una porción de **todos** sus ingredientes activos y no expone costos, existencias ni cantidades de receta. Las recetas vacías o con productos archivados no están disponibles. Incluí todos los insumos que quieras controlar.

La carta se consulta en **http://localhost:8000/carta**. Recalcula la disponibilidad al abrirla y se recarga automáticamente cada 60 segundos. Consultarla no reserva ni descuenta existencias; seguí registrando los consumos mediante movimientos de stock. No incluye pedidos ni cobros.

Las tablas de cócteles y recetas se crean automáticamente al actualizar:

```bash
docker compose up --build -d
```

Los productos y movimientos existentes se conservan. Los respaldos completos con `pg_dump` también incluyen las recetas.

### Acceso desde celulares u otras computadoras

Por defecto Docker escucha solo en tu computadora. Para compartir la carta en tu red local, agregá `BIND_ADDRESS=0.0.0.0` a `.env` y volvé a ejecutar `docker compose up --build -d`. Luego abrí `http://IP-DE-TU-COMPUTADORA:8000/carta` desde un equipo conectado a la misma red (el firewall debe permitir ese puerto). La gestión continúa pidiendo la clave.

Esto no publica la carta en Internet. Para acceso fuera de tu red hace falta un dominio o dirección pública y un proxy con HTTPS o un servicio equivalente. No se configuró hosting externo en este proyecto.

## Operación

```bash
docker compose logs -f web
docker compose ps
docker compose down
```

Los datos sobreviven a reinicios y a `docker compose down` en el volumen `postgres_data`. **`docker compose down -v` elimina la base.**

Respaldo:

```bash
docker compose exec -T db pg_dump -U bar -d bar > backup.sql
```

Restauración sobre una base vacía (reemplaza `backup.sql` por tu archivo):

```bash
docker compose stop web
docker compose exec -T db psql -v ON_ERROR_STOP=1 -U bar -d bar < backup.sql
docker compose start web
```

La web escucha por defecto en `127.0.0.1` y PostgreSQL no expone puertos al host. Para acceso por Internet, configurá un proxy con HTTPS y acceso de red apropiado. La autenticación es una clave compartida: esta versión no incluye usuarios, roles ni autoría individual del historial. Tampoco incluye descuento por cóctel, facturación o integración con caja.

El esquema inicial se crea automáticamente. La columna Marca se agrega automáticamente en bases existentes sin borrar datos; los productos anteriores quedan con la marca vacía y pueden editarse. Cambios futuros en tablas existentes necesitarán migraciones; `create_all` no modifica tablas ya creadas. Cambiar `DB_PASSWORD` en `.env` después del primer inicio no cambia la contraseña del usuario ya guardado en PostgreSQL: debe actualizarse también dentro de la base.

## Desarrollo y pruebas

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
export ADMIN_PASSWORD=clave-local
export SECRET_KEY=clave-aleatoria-para-desarrollo
.venv/bin/flask --app app run --port 8000
```

Sin `DATABASE_URL`, el modo local usa SQLite en `instance/bar.sqlite`. En Docker siempre se usa PostgreSQL.

```bash
.venv/bin/python -m unittest discover -s tests -v
docker compose config --quiet
```

Las pruebas usan SQLite en memoria y verifican acceso, CSRF, movimientos, rechazo de salidas sin stock, validaciones numéricas, duplicados, archivado, escape HTML y exportación CSV. Las garantías de concurrencia dependen de PostgreSQL y no se verifican con SQLite.
