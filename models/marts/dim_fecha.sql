

with dias as (
    select
        dateadd(day, row_number() over (order by seq4()) - 1, '2012-01-01'::date) as fecha
    from table(generator(rowcount => 5000))
)

select
    fecha,
    year(fecha)                                         as anio,
    month(fecha)                                        as mes,
    dayofweekiso(fecha)                                 as dia_semana,
    dayofweekiso(fecha) in (6, 7)                       as es_fin_de_semana,
    case
        when month(fecha) in (12, 1, 2) then 'Invierno'
        when month(fecha) in (3, 4, 5)  then 'Primavera'
        when month(fecha) in (6, 7, 8)  then 'Verano'
        else 'Otoño'
    end                                                 as estacion_del_anio,
    month(fecha) between 3 and 6                        as es_marzo_a_junio,
    fecha between '2020-03-14' and '2020-06-21'         as es_confinamiento
from dias
where fecha <= '2024-12-31'