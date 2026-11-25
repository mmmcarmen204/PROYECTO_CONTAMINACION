# Evolución de la calidad del aire en Granada (2012–2024)

Proyecto de dbt + Snowflake que transforma los datos abiertos de calidad del aire de la **Junta de Andalucía** para analizar la provincia de Granada en cuatro años: **2012, 2016, 2020 y 2024**. Incluye datos de PM10 de 2025 para demostrar la carga incremental.

## Preguntas de negocio

1. **¿Ha mejorado la calidad del aire?** Evolución de las medias anuales por estación y contaminante.
2. **¿Se cumplen los límites?** Comparación de la normativa europea (UE) con las guías de la OMS.
3. **¿Qué efecto tuvo el confinamiento?** Comparación de marzo a junio de 2020 con los mismos meses de los otros años.

## Datos de origen

| Fichero | Contenido | Granularidad |
|---|---|---|
| `O3_HH_<año>` | Ozono | Horaria (h01–h24) |
| `NOX_HH_<año>` | Óxidos de nitrógeno | Horaria (h01–h24) |
| `PM10_DD_<año>` | Partículas PM10 | Diaria (d01–d31) |
| `LISTADO_ESTACIONES` | Estaciones de medida | Catálogo |
| `LISTADO_PARAMETROS` | Contaminantes y unidades | Catálogo |
| `LISTADO_TECNICAS_DE_MEDIDA` | Técnicas de medida | Catálogo |

Los CSV se cargan **completos** (todas las provincias) en Snowflake, con codificación `ISO-8859-1` y separador `;`. El filtrado por provincia y años se hace en dbt.

## Arquitectura (medallón)

| Capa | Base de datos | Esquema | Materialización | Función |
|---|---|---|---|---|
| Bronze | `DEV/PRO_BRONZE_PROYECTO` | `RAW`, `SEEDS` | Tablas cargadas | Datos crudos tal como llegan |
| Silver | `DEV/PRO_SILVER_PROYECTO` | `STAGING` | Vistas | Limpieza, tipado, unión de años y despivotado |
| Silver | `DEV/PRO_SILVER_PROYECTO` | `SILVER` | Vistas / incremental | Filtro Granada, agregación diaria y reglas de calidad |
| Gold | `DEV/PRO_GOLD_PROYECTO` | `MARTS` | Tablas | Modelo en estrella para Power BI |

Las bases de datos se eligen con variables de entorno (`DBT_BRONZE`, `DBT_SILVER`, `DBT_GOLD`), así el mismo código funciona en desarrollo y en producción.

## Modelos

### Staging
- `stg_o3`, `stg_nox`: unen los años con un bucle Jinja y despivotan las 24 horas (`UNPIVOT`).
- `stg_pm10`: une las tablas con `dbt_utils.union_relations` (por nombre de columna) y despivota los 31 días. Las fechas imposibles (31 de febrero) se descartan con `try_to_date`.
- `stg_estaciones`, `stg_parametros`, `stg_tecnicas`: limpian los catálogos (fechas con año de 2 y 4 cifras, cabeceras repetidas).

### Silver
- `slv_estaciones_granada`: estaciones de la provincia 18.
- `slv_o3_gr_dia`: máximo diario de la media móvil de 8 horas, con la regla del 75 % (6 de 8 horas en cada ventana, 18 de 24 horas en el día).
- `slv_nox_gr_dia`: media diaria con la regla del 75 %.
- `slv_pm10_gr`: **modelo incremental** (`merge`) con la columna `fecha_carga`.
- `slv_mediciones_diarias`: une los tres contaminantes.
- `slv_parametros_limites`: límites de la UE y de la OMS por contaminante (a partir del seed).

### Gold (esquema en estrella)
- `fct_calidad_aire_diaria`: grano **estación + contaminante + técnica + día**.
- `dim_estaciones`, `dim_parametros`, `dim_tecnicas`, `dim_fecha` (con indicadores de estación del año, marzo a junio y confinamiento).

## Seeds
- `limites_contaminantes.csv`: valores límite de la UE y guías de la OMS para O3, NO2 y PM10.

## Tests
- **Genéricos de dbt**: `unique`, `not_null`, `relationships`, `accepted_values`.
- **dbt_utils**: `unique_combination_of_columns`, `accepted_range`, `expression_is_true`.
- **Test genérico propio** `columnas_coinciden` (`macros/coincidencia_columnas.sql`): comprueba en `INFORMATION_SCHEMA` que las tablas de distintos años tienen las mismas columnas, en el mismo orden y con el mismo tipo, antes de unirlas.

## Snapshot
- `snp_estaciones`: historifica el catálogo de estaciones (SCD tipo 2, estrategia `check`) para registrar altas, bajas y cambios.

## Análisis (`analyses/`)
- `evolucion_anual`: medias anuales por estación y contaminante.
- `cumplimiento_ozono`, `cumplimiento_pm10`: comparación con los límites de la UE y de la OMS.
- `umbrales_horarios_ozono`: horas por encima de los umbrales de información y de alerta.
- `efecto_confinamiento`: marzo a junio de 2020 frente al resto de años.
- `comparacion_tecnicas_pm10`: medida manual frente a automática.

## Decisiones de diseño
- **No se eliminan duplicados entre técnicas de PM10**: algunas estaciones miden el mismo día con método manual y automático. Son medidas distintas, por eso la técnica forma parte de la clave.
- **Los ceros de NOx se mantienen**: son valores reales y bajos (confinamiento, Semana Santa, festivos), no errores.
- **Estaciones huérfanas** (`18189999`, `21005999`): no existen en el catálogo y se excluyen con un `inner join`.

## Cómo ejecutarlo

```bash
dbt deps                  # instala dbt_utils
dbt seed                  # carga los límites
dbt build                 # modelos + tests
dbt snapshot              # historifica las estaciones
dbt build --full-refresh  # reconstruye el modelo incremental desde cero
```

## Variables (`dbt_project.yml`)

```yaml
vars:
  provincia_proyecto: 18
  anios_proyecto: [2012, 2016, 2020, 2024]
```

## Tecnología
Snowflake · dbt Cloud · GitHub

## Autora
M Carmen Garcia Burgos — Proyecto final del curso Data Engineering de Cívica.

Fuente de los datos: Junta de Andalucía, datos abiertos de calidad del aire.
