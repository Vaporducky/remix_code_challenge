SELECT
    'dbt' AS dummy_col,
    *
FROM {{ source('raw', 'seller') }}