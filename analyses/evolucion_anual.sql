
-- Media anual de cada contaminante por estación, solo días válidos.
-- PM10: solo técnica manual, la única presente los cuatro años.
select
    f.anio,
    p.nombre_parametro,
    e.nombre_estacion,
    round(avg(h.valor_diario), 1)    as media_anual,
    count(h.valor_diario)               as dias_validos
from {{ ref('fct_calidad_aire_diaria') }} h
join {{ ref('dim_fecha') }} f        on h.fecha = f.fecha
join {{ ref('dim_estaciones') }} e   on h.cod_estacion = e.cod_estacion
join {{ ref('dim_parametros') }} p   on h.cod_parametro = p.cod_parametro
join {{ ref('dim_tecnicas') }} t     on h.cod_tecnica = t.cod_tecnica
where h.es_dia_valido
  and (h.cod_parametro <> 10 or t.es_manual)
group by f.anio, p.nombre_parametro, e.nombre_estacion
order by p.nombre_parametro, e.nombre_estacion, f.anio