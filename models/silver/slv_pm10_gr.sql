{{ config(
    materialized = 'incremental',
    unique_key = ['cod_estacion', 'cod_parametro', 'cod_tecnica', 'fecha'],
    incremental_strategy = 'merge'
) }}

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

{% if is_incremental() %}
-- En las ejecuciones incrementales solo se procesa desde el último año ya cargado
where year(p.fecha) >= (select coalesce(max(year(fecha)), 0) from {{ this }})
{% endif %}