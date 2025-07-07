WITH order_normalized AS
(
    SELECT
        TRIM(order_id) AS order_id,
        TRIM(customer_id) AS customer_id,
        UPPER(TRIM(order_status)) AS order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        COUNT(*) OVER (PARTITION BY TRIM(order_id)) AS duplicate
    FROM {{ source('raw', 'order') }}
),
order_fk_check AS
(
    SELECT
        order_normalized.*,
        customer.customer_id AS fk
    FROM order_normalized
        LEFT JOIN (SELECT DISTINCT customer_id FROM {{ ref ('customer') }}) AS customer ON
            order_normalized.customer_id = customer.customer_id
),
order_quarantine AS
(
    SELECT
        *,
        (order_id IS NULL)::int AS order_id_quarantine,
        (duplicate > 1)::int order_id_uniqueness,
        (customer_id IS NULL)::int AS customer_id_quarantine,
        (fk IS NULL)::int AS fk_quarantine,
        CASE
            WHEN order_status NOT IN ('SHIPPED',
                                      'UNAVAILABLE',
                                      'INVOICED',
                                      'CREATED',
                                      'APPROVED',
                                      'PROCESSING',
                                      'DELIVERED',
                                      'CANCELED') THEN 1
            ELSE 0
        END AS order_status_quarantine,
        /* Timestamps */
        (order_purchase_timestamp IS NULL)::int AS order_purchase_timestamp_quarantine,
        -- The following requires business confirmation
        CASE
            -- Not approved within a specific order status chronology
            WHEN
                    order_approved_at IS NULL
                AND order_status NOT IN ('CREATED', 'CANCELLED')
            THEN 1
            -- Order approved before being purchased
            WHEN
                    order_approved_at IS NOT NULL
                AND order_approved_at < order_purchase_timestamp
            THEN 1
            ELSE 0
        END AS order_approved_at_quarantine,
        0 AS order_delivered_carrier_date_quarantine,
        0 AS order_delivered_customer_date_quarantine,
        0 AS order_estimated_delivery_date_quarantine
    FROM order_fk_check
),
row_quarantine_filtering AS (
    SELECT
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        GREATEST(
          order_id_quarantine,
          order_id_uniqueness,
          customer_id_quarantine,
          fk_quarantine,
          order_status_quarantine,
          order_purchase_timestamp_quarantine,
          order_approved_at_quarantine,
          order_delivered_carrier_date_quarantine,
          order_delivered_customer_date_quarantine,
          order_estimated_delivery_date_quarantine
        ) AS row_quarantine_flag
    FROM order_quarantine
)
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM row_quarantine_filtering
WHERE row_quarantine_flag = 0
