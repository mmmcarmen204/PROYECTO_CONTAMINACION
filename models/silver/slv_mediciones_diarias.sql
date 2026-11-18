

with estaciones_granada as (
    select cod_estacion
    from {{ ref('stg_estaciones') }}
    where cod_provincia = {{ var('provincia') }}
),

-- 1. Ozono y NOx juntos, solo estaciones catalogadas de Granada
horarias as (
    select h.*
    from (
        select * from {{ ref('stg_o3') }}
        union all
        select * from {{ ref('stg_nox') }}
    ) h
    inner join estaciones_granada e on h.cod_estacion = e.cod_estacion
),

-- 2. Media móvil de 8 horas (la usa la normativa del ozono)
con_media_8h as (
    select
        *,
        datediff(hour, '2000-01-01'::timestamp,
                 dateadd(hour, hora, fecha::timestamp))      as hora_absoluta,
        avg(valor) over (
            partition by cod_estacion, cod_parametro, cod_tecnica
            order by hora_absoluta
            range between 7 preceding and current row
        )                                                   as media_movil_8h,
        count(valor) over (
            partition by cod_estacion, cod_parametro, cod_tecnica
            order by hora_absoluta
            range between 7 preceding and current row
        )                                                   as horas_en_ventana
    from horarias
),

-- 3. De horario a diario
diarias_desde_horarias as (
    select
        cod_estacion,
        cod_parametro,
        cod_tecnica,
        fecha,
        avg(valor)                                          as valor_medio,
        max(valor)                                          as valor_maximo,
        count(*)                                            as horas_validas,
        count(*) >= 18                                      as es_dia_valido,
        max(case when horas_en_ventana >= 6
                 then media_movil_8h end)                   as max_media_movil_8h
    from con_media_8h
    group by cod_estacion, cod_parametro, cod_tecnica, fecha
),

-- 4. PM10, que ya es diario
pm10 as (
    select
        p.cod_estacion,
        p.cod_parametro,
        p.cod_tecnica,
        p.fecha,
        p.valor                 as valor_medio,
        p.valor                 as valor_maximo,
        null::number            as horas_validas,
        true                    as es_dia_valido,
        null::float             as max_media_movil_8h
    from {{ ref('stg_pm10') }} p
    inner join estaciones_granada e on p.cod_estacion = e.cod_estacion
)

select * from diarias_desde_horarias
union all
select * from pm10