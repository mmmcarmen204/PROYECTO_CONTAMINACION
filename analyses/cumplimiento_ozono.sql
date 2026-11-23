
-- Días por año en que el valor diario del ozono (máximo de la media móvil de 8 h)
-- supera el valor objetivo de la UE (120) y la guía de la OMS (100).
select
    f.anio,
    e.nombre_estacion,
    count_if(h.valor_diario > p.valor_objetivo_8h_ue)   as dias_supera_ue,
    count_if(h.valor_diario > p.guia_8h_oms)            as dias_supera_oms,
    25                                                   as superaciones_permitidas_ue
from {{ ref('fct_calidad_aire_diaria') }} h
join {{ ref('dim_fecha') }} f        on h.fecha = f.fecha
join {{ ref('dim_estaciones') }} e   on h.cod_estacion = e.cod_estacion
join {{ ref('dim_parametros') }} p   on h.cod_parametro = p.cod_parametro
where h.cod_parametro = 14
  and h.es_dia_valido
group by f.anio, e.nombre_estacion
order by e.nombre_estacion, f.anio