-- MODELO STG_TECNICAS----------------------------------

with origen as (
    select * from {{ source('contaminacion', 'listado_parametros') }}
)

select
    try_to_number(c1)       as cod_parametro,
    trim(c2)                as nombre_parametro,
    trim(c3)                as unidad
from origen
where try_to_number(c1) is not null    -- elimina la fila de cabecera ('ID')