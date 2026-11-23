
-- Media anual de PM10 (técnica manual, la única presente los cuatro años)
-- frente al límite anual de la UE (40) y la guía anual de la OMS (15).
select
    f.anio,
    e.nombre_estacion,
    round(avg(h.valor_diario), 1)                   as media_anual,
    p.limite_anual_ue,
    p.guia_anual_oms,
    avg(h.valor_diario) <= p.limite_anual_ue        as cumple_ue,
    avg(h.valor_diario) <= p.guia_anual_oms         as cumple_oms
from {{ ref('fct_calidad_aire_diaria') }} h
join {{ ref('dim_fecha') }} f        on h.fecha = f.fecha
join {{ ref('dim_estaciones') }} e   on h.cod_estacion = e.cod_estacion
join {{ ref('dim_parametros') }} p   on h.cod_parametro = p.cod_parametro
where h.cod_parametro = 10
  and h.cod_tecnica = 'M'
group by f.anio, e.nombre_estacion, p.limite_anual_ue, p.guia_anual_oms
order by e.nombre_estacion, f.anio