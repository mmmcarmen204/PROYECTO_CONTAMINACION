
-- Horas por año en que el ozono supera el umbral de información (180) y de alerta (240).
-- Se calcula con el dato horario de staging, porque estos umbrales son horarios.
select
    year(o.fecha)                       as anio,
    e.nombre_estacion,
    count_if(o.valor > 180)             as horas_supera_informacion,
    count_if(o.valor > 240)             as horas_supera_alerta
from {{ ref('stg_o3') }} o
inner join {{ ref('slv_estaciones_granada') }} e
    on o.cod_estacion = e.cod_estacion
group by 1, 2
order by 2, 1