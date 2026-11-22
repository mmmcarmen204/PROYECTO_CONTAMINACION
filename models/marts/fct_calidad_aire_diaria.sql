
select
    cod_estacion,
    cod_parametro,
    cod_tecnica,
    fecha,
    valor_diario,
    es_dia_valido,
from {{ ref('slv_mediciones_diarias') }}
