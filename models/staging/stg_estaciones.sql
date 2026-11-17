with origen as (
    select * from {{ source('contaminacion', 'listado_estaciones') }}
)

select
    -- claves
    cod_local_n                 as cod_estacion,
    provincia                   as cod_provincia,
    municipio                   as cod_municipio,
    estacion                    as num_estacion,
    cod_estacion_dem,

    -- descripción
    trim(nombre)                as nombre_estacion,
    trim(n_municipio)           as municipio,
    trim(n_provincia)           as provincia,
    trim(n_ccaa)                as comunidad_autonoma,
    trim(rvca)                  as red,

    -- fechas: de texto a fecha, probando los formatos habituales
    case
        when length(split_part(fecha_ini, '/', 3)) = 2
            then try_to_date(fecha_ini, 'DD/MM/YY')
        else try_to_date(fecha_ini, 'DD/MM/YYYY')
    end                         as fecha_alta,
    case
        when length(split_part(fecha_baja, '/', 3)) = 2
            then try_to_date(fecha_baja, 'DD/MM/YY')
        else try_to_date(fecha_baja, 'DD/MM/YYYY')
    end                         as fecha_baja
from origen