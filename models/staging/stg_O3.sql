

{% set anios = [2012, 2016, 2020, 2024] %}

with unido as (
    {% for anio in anios %}
    select * from {{ source('contaminacion', 'o3_hh_' ~ anio) }}
    {% if not loop.last %} union all {% endif %}
    {% endfor %}
),

despivotado as (
    select *
    from unido
    unpivot (valor for hora_col in (
        h01, h02, h03, h04, h05, h06, h07, h08, h09, h10, h11, h12,
        h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24
    ))
)

select
    -- claves
    provincia * 1000000 + municipio * 1000 + estacion   as cod_estacion,
    provincia                                           as cod_provincia,
    municipio                                           as cod_municipio,
    parametro                                           as cod_parametro,
    tecnica                                             as cod_tecnica,

    -- tiempo
    date_from_parts(anyo, mes, dia)                     as fecha,
    cast(replace(hora_col, 'H', '') as integer)         as hora,

    -- medida
    cast(valor as float)                                as valor
from despivotado