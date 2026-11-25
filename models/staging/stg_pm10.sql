--MODELO STG_PM10 -------------------------------------------------------------------------------------

-- depends_on: {{ source('contaminacion', 'pm10_dd_2012') }}
-- depends_on: {{ source('contaminacion', 'pm10_dd_2016') }}
-- depends_on: {{ source('contaminacion', 'pm10_dd_2020') }}
-- depends_on: {{ source('contaminacion', 'pm10_dd_2024') }}

{% set relaciones = dbt_utils.get_relations_by_pattern(
    schema_pattern = 'RAW',
    table_pattern = 'PM10_DD_20%',
    database = env_var('DBT_BRONZE')
) %}

with unido as (
    {{ dbt_utils.union_relations(relations = relaciones) }}
),


despivotado as (
    select *
    from unido
    unpivot (valor for dia_col in (
        d01, d02, d03, d04, d05, d06, d07, d08, d09, d10,
        d11, d12, d13, d14, d15, d16, d17, d18, d19, d20,
        d21, d22, d23, d24, d25, d26, d27, d28, d29, d30, d31
    ))
),

con_fecha as (
    select
        provincia * 1000000 + municipio * 1000 + estacion   as cod_estacion,
        provincia                                           as cod_provincia,
        municipio                                           as cod_municipio,
        parametro                                           as cod_parametro,
        cast(tecnica as varchar)                            as cod_tecnica,
        try_to_date(
            anyo || '-' || lpad(mes::varchar, 2, '0') || '-' || replace(dia_col, 'D', ''),
            'YYYY-MM-DD'
        )                                                   as fecha,
        cast(valor as float)                                as valor
    from despivotado
)

select *
from con_fecha
where fecha is not null    -- descarta días inexistentes (30 de febrero…)