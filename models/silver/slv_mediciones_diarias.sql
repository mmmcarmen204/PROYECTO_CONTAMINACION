

select * from {{ ref('slv_horarias_a_diarias') }}

union all

select
    cod_estacion,
    cod_parametro,
    cod_tecnica,
    fecha,
    valor                   as valor_medio,
    valor                   as valor_maximo,
    null::number            as horas_validas,
    true                    as es_dia_valido,
    null::float             as max_media_movil_8h
from {{ ref('slv_pm10_granada') }}