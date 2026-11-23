

-- Efecto del confinamiento: media de marzo a junio de cada año y variación de 2020
-- respecto a la media de los otros tres años en los mismos meses.
-- valor_diario: O3 = máximo de la media móvil de 8 h; NOx = media diaria.
with medias as (
    select
        f.anio,
        p.nombre_parametro,
        avg(h.valor_diario)     as media_marzo_junio
    from {{ ref('fct_calidad_aire_diaria') }} h
    join {{ ref('dim_fecha') }} f        on h.fecha = f.fecha
    join {{ ref('dim_parametros') }} p   on h.cod_parametro = p.cod_parametro
    where h.cod_parametro in (12, 14)
      and h.es_dia_valido
      and f.es_marzo_a_junio
    group by f.anio, p.nombre_parametro
)

select
    nombre_parametro,
    anio,
    round(media_marzo_junio, 1)     as media_marzo_junio,
    round(100 * (media_marzo_junio
          / avg(iff(anio <> 2020, media_marzo_junio, null))
            over (partition by nombre_parametro) - 1), 1)   as variacion_vs_otros_anios_pct
from medias
order by nombre_parametro, anio