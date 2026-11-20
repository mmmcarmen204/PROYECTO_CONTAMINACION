-- MODELO SILVER ESTACIONES GRANADA-----------------------

select
    cod_estacion,
    nombre_estacion,
    municipio,
    fecha_alta,
    fecha_baja
from {{ ref('stg_estaciones') }}
where cod_provincia = {{ var('provincia') }}