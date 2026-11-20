
with limites as (
    select * from {{ ref('limites_contaminantes') }}
)

select
    p.cod_parametro,
    p.nombre_parametro,
    p.unidad,
    max(iff(l.tipo_valor = 'valor_limite' and l.periodo = 'diario',  l.valor_ugm3, null)) as limite_diario_ue,
    max(iff(l.tipo_valor = 'valor_limite' and l.periodo = 'anual',   l.valor_ugm3, null)) as limite_anual_ue,
    max(iff(l.tipo_valor = 'valor_limite' and l.periodo = 'horario', l.valor_ugm3, null)) as limite_horario_ue,
    max(iff(l.tipo_valor = 'valor_objetivo',                          l.valor_ugm3, null)) as valor_objetivo_8h_ue,
    max(iff(l.tipo_valor = 'umbral_informacion',                      l.valor_ugm3, null)) as umbral_informacion_ue,
    max(iff(l.tipo_valor = 'guia_oms' and l.periodo = 'diario',      l.valor_ugm3, null)) as guia_diaria_oms,
    max(iff(l.tipo_valor = 'guia_oms' and l.periodo = 'anual',       l.valor_ugm3, null)) as guia_anual_oms,
    max(iff(l.tipo_valor = 'guia_oms' and l.periodo = 'maxima_diaria_media_8h', l.valor_ugm3, null)) as guia_8h_oms
from {{ ref('stg_parametros') }} p
left join limites l
    on p.cod_parametro = l.cod_parametro
group by p.cod_parametro, p.nombre_parametro, p.unidad