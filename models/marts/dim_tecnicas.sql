
select
    cod_tecnica,
    nombre_tecnica,
    cod_tecnica = 'M'       as es_manual
from {{ ref('stg_tecnicas') }}