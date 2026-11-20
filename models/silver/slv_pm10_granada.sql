
select
    p.cod_estacion,
    p.cod_parametro,
    p.cod_tecnica,
    p.fecha,
    p.valor
from {{ ref('stg_pm10') }} p
inner join {{ ref('slv_estaciones_granada') }} e
    on p.cod_estacion = e.cod_estacion