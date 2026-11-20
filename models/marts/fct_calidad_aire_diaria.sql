
select
    cod_estacion,
    cod_parametro,
    cod_tecnica,
    fecha,
    valor_medio,
    valor_maximo,
    horas_validas,
    es_dia_valido,
    max_media_movil_8h
from {{ ref('slv_mediciones_diarias') }}
