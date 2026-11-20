-- MODELO MEDICIONES HORARIAS EN SILVER

with horarias as (
    select * from {{ ref('stg_o3') }}
    union all
    select * from {{ ref('stg_nox') }}
)

select
    h.cod_estacion,
    h.cod_parametro,
    h.cod_tecnica,
    h.fecha,
    h.hora,
    h.valor
from horarias h
inner join {{ ref('slv_estaciones_granada') }} e
    on h.cod_estacion = e.cod_estacion