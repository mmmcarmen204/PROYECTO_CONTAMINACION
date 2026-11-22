

select
    cod_estacion, cod_parametro, cod_tecnica, fecha,
    valor_medio, valor_maximo, horas_validas, es_dia_valido,
    max_media_movil_8h
from {{ ref('slv_o3_gr_dia') }}

union all

select
    cod_estacion, cod_parametro, cod_tecnica, fecha,
    valor_medio, valor_maximo, horas_validas, es_dia_valido,
    null::float             as max_media_movil_8h
from {{ ref('slv_nox_gr_dia') }}

union all

select
    cod_estacion, cod_parametro, cod_tecnica, fecha,
    valor                   as valor_medio,
    valor                   as valor_maximo,
    null::number            as horas_validas,
    true                    as es_dia_valido,
    null::float             as max_media_movil_8h
from {{ ref('slv_pm10_granada') }}