{{ config(
        unique_key=['order_id']
    )
}}

SELECT
    order_id,
    order_purchase_ts,
    order_approved_at_ts,
    order_delivered_carrier_dt,
    order_delivered_customer_dt,
    order_estimated_delivery_dt
FROM {{ ref('order') }}
