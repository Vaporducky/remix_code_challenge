/* We will drop some records due to FK inconsistencies (zip codes in customer
   but not in geolocation)
*/
WITH customer_normalized AS
(
    SELECT
        TRIM(customer_id) AS customer_id,
        /* We rename the following field as it is causing confusion (it is not 
           unique, by design.) 
        */
        TRIM(customer_unique_id) AS customer_master_id,
        TRIM(customer_zip_code_prefix) AS customer_zip_code_prefix,
        UPPER(TRIM(customer_city)) AS customer_city,
        UPPER(TRIM(customer_state)) AS customer_state,
        COUNT(*) OVER (PARTITION BY TRIM(customer_id)) AS duplicate
    FROM {{ source('raw', 'customer') }}
),
customer_fk_check AS
(
    SELECT
        customer_normalized.*,
        geolocation.geolocation_zip_code_prefix AS fk
    FROM customer_normalized
        LEFT JOIN (SELECT DISTINCT geolocation_zip_code_prefix FROM {{ ref('geolocation') }}) AS geolocation ON
            customer_normalized.customer_zip_code_prefix = geolocation.geolocation_zip_code_prefix
),
customer_quarantine AS (
    SELECT *,
        (customer_id IS NULL)::int AS customer_id_quarantine,
        (customer_master_id IS NULL)::int AS customer_master_id_quarantine,
        (duplicate > 1)::int AS customer_id_uniqueness,
        CASE
            WHEN customer_zip_code_prefix ~ '^\d{5}$' THEN 0
            ELSE 1
        END AS customer_zip_code_quarantine,
        CASE
            WHEN customer_state NOT IN ('SC', 'RO', 'PI', 'AM', 'RR', 'GO',
                                        'TO', 'MT', 'SP', 'ES', 'PB', 'RS',
                                        'MS', 'AL', 'MG', 'PA', 'BA', 'SE',
                                        'PE', 'CE', 'RN', 'RJ', 'MA', 'AC',
                                        'DF', 'PR', 'AP')
            THEN 1
            ELSE 0
        END AS customer_state_quarantine,
        (fk IS NULL)::int AS fk_quarantine
    FROM customer_fk_check
),
row_quarantine_filtering AS (
    SELECT
        customer_id,
        customer_master_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        GREATEST(
            customer_id_quarantine,
            customer_master_id_quarantine,
            customer_id_uniqueness,
            customer_zip_code_quarantine,
            customer_state_quarantine,
            fk_quarantine
        ) AS row_quarantine_flag
    FROM customer_quarantine
)
SELECT
    customer_id,
    customer_master_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM row_quarantine_filtering
WHERE row_quarantine_flag = 0