{{ config(
        unique_key=['customer_id']
    )
}}

SELECT
    customer_id,
    customer_master_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM {{ ref('customer') }}
