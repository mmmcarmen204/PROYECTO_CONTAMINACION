
select
    cod_tecnica,
    nombre_tecnica,
    cod_tecnica = 'M'       as tecnica_manual
from {{ ref('stg_tecnicas') }}