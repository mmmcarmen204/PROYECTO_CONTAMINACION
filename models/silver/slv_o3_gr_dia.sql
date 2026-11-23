


with horario as (
    select
        o.cod_estacion,
        o.cod_parametro,
        o.cod_tecnica,
        o.fecha,
        o.hora,
        o.valor
    from {{ ref('stg_o3') }} o
    inner join {{ ref('slv_estaciones_granada') }} e
        on o.cod_estacion = e.cod_estacion
),

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
    from horario
)

select
    cod_estacion,
    cod_parametro,
    cod_tecnica,
    fecha,
    -- valor diario del ozono: máximo de la media móvil de 8 horas (métrica oficial),
    -- solo con ventanas de al menos 6 de las 8 horas
    max(case when horas_en_ventana >= 6
             then media_movil_8h end)   as valor_diario,
    count(valor) >= 18                  as es_dia_valido
from con_media_8h
group by cod_estacion, cod_parametro, cod_tecnica, fecha
