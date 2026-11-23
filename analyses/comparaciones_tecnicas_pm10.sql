
-- Compara las técnicas manual (M) y automática (49) del PM10 en los días
-- de 2024 en que una misma estación midió con las dos.
select
    e.nombre_estacion,
    count(*)                                            as dias_con_ambas,
    round(avg(m.valor_diario), 1)                       as media_manual,
    round(avg(a.valor_diario), 1)                       as media_automatica,
    round(avg(a.valor_diario - m.valor_diario), 1)      as diferencia_media
from {{ ref('fct_calidad_aire_diaria') }} m
join {{ ref('fct_calidad_aire_diaria') }} a
    on  m.cod_estacion = a.cod_estacion
    and m.fecha = a.fecha
join {{ ref('dim_estaciones') }} e
    on m.cod_estacion = e.cod_estacion
where m.cod_parametro = 10 and m.cod_tecnica = 'M'
  and a.cod_parametro = 10 and a.cod_tecnica = '49'
group by e.nombre_estacion