
select
    cod_estacion,
    nombre_estacion,
    municipio,
    provincia,
    cod_provincia,
    fecha_alta,
    fecha_baja,
    fecha_baja is null      as es_activa
from {{ ref('stg_estaciones') }}