
-- TEST QUE NOS PERMITE COMPROBAR QUE EXISTE COINCIDENCIA EN LAS COLUMNAS DE LAS TABLAS QUE UTILIZAMOS ------

{% test columnas_coinciden(model, tablas) %}

{% set todas = [model.identifier | upper] + (tablas | map('upper') | list) %}

with columnas as (
    select table_name, ordinal_position, column_name, data_type
    from {{ model.database }}.information_schema.columns
    where table_schema = '{{ model.schema | upper }}'
      and table_name in ('{{ todas | join("', '") }}')
)

-- posiciones donde las tablas no coinciden en nombre o tipo de columna,
-- o donde a alguna tabla le falta esa columna
select
    ordinal_position                    as posicion,
    count(*)                            as tablas_con_columna,
    count(distinct column_name)         as nombres_distintos,
    count(distinct data_type)           as tipos_distintos
from columnas
group by ordinal_position
having count(*) <> {{ todas | length }}
    or count(distinct column_name) > 1
    or count(distinct data_type) > 1

union all

-- falla también si alguna de las tablas no existe
select -1, count(distinct table_name), 0, 0
from columnas
having count(distinct table_name) <> {{ todas | length }}

{% endtest %}