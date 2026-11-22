--CREACIÓN DEL MODELO SILVER DEL COMTAMINANTE NOX EN LA CIUDAD DE GRANADA DE FORMA DIARIA------------------------

with horario as (
    select
        n.cod_estacion,
        n.cod_parametro,
        n.cod_tecnica,
        n.fecha,
        n.valor
    from {{ ref('stg_nox') }} n
    inner join {{ ref('slv_estaciones_granada') }} e
        on n.cod_estacion = e.cod_estacion
)

select
    cod_estacion,
    cod_parametro,
    cod_tecnica,
    fecha,
    avg(valor)              as valor_medio,
    max(valor)              as valor_maximo,
    count(valor)            as horas_validas,
    count(valor) >= 18      as es_dia_valido
from horario
group by cod_estacion, cod_parametro, cod_tecnica, fecha