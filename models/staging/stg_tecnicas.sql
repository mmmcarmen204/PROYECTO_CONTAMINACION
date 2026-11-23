--modelo stg_tecnicas

with origen as (
    select * from {{ source('contaminacion', 'listado_tecnicas_de_medida') }}
)

select
    trim(c1)                as cod_tecnica,
    trim(c2)                as nombre_tecnica
from origen
where upper(trim(c1)) <> 'ID'          -- elimina la fila de cabecera
