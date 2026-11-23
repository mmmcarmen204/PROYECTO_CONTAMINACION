
select
    cod_estacion,
    nombre_estacion,
    municipio,
    fecha_alta,
    fecha_baja,
    fecha_baja is null as activa
from {{ ref('slv_estaciones_granada') }}