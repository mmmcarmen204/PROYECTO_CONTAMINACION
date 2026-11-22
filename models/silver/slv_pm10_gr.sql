
select
    p.cod_estacion,
    p.cod_parametro,
    p.cod_tecnica,
    p.fecha,
    p.valor                 as valor_diario,     -- ya es un valor diario
    true                    as es_dia_valido
from {{ ref('stg_pm10') }} p
inner join {{ ref('slv_estaciones_granada') }} e
    on p.cod_estacion = e.cod_estacion