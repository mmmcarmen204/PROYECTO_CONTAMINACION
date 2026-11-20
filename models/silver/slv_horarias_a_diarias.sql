
--MODELO DE CAMBIO DE HORAS A DIAS SILVER

with con_media_8h as (
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
    from {{ ref('slv_mediciones_horarias') }}
)

select
    cod_estacion,
    cod_parametro,
    cod_tecnica,
    fecha,
    avg(valor)                                              as valor_medio,
    max(valor)                                              as valor_maximo,
    count(*)                                                as horas_validas,
    count(*) >= 18                                          as es_dia_valido,
    max(case when horas_en_ventana >= 6
             then media_movil_8h end)                       as max_media_movil_8h
from con_media_8h
group by cod_estacion, cod_parametro, cod_tecnica, fecha