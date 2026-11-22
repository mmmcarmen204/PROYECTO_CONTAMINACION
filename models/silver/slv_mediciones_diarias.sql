

select * from {{ ref('slv_o3_gr_dia') }}
union all
select * from {{ ref('slv_nox_gr_dia') }}
union all
select * from {{ ref('slv_pm10_gr') }}