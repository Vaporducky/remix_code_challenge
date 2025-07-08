{{ config(
    unique_key=['order_id', 'product_id_within_order']
) }}

WITH order_metrics AS
(
    SELECT
        order_id,
        SUM(product_price)::NUMERIC(10, 2) AS order_product_total,
        SUM(product_freight_value)::NUMERIC(10, 2) AS order_freight_total,
        SUM(product_price + product_freight_value)::NUMERIC(10, 2) AS order_total
    FROM {{ ref('order_item') }} AS order_item
    GROUP BY order_id
)
SELECT
    "order".order_id,
    order_item.product_id_within_order,
    "order".customer_id,
    order_item.product_id,
    order_item.seller_id,
    "order".order_status,
    order_review.latest_review_score,
    order_item.item_shipping_limit_dt,
    order_item.product_price,
    order_item.product_freight_value,
    order_metrics.order_product_total,
    order_metrics.order_freight_total,
    order_metrics.order_total,
    CASE
        WHEN (NOW() AT TIME ZONE 'utc') > order_estimated_delivery_dt THEN TRUE
        ELSE FALSE
    END AS is_order_delayed,
    CASE
        WHEN "order".order_delivered_customer_dt IS NOT NULL
        THEN EXTRACT(DAY FROM
                     "order".order_delivered_customer_dt - "order".order_purchase_ts)
        ELSE NULL
    END AS days_until_delivery
FROM {{ ref('order_item') }} AS order_item
    LEFT JOIN order_metrics ON
        order_metrics.order_id = order_item.order_id
    LEFT JOIN {{ ref('order') }} AS "order" ON
        order_item.order_id = "order".order_id
    LEFT JOIN {{ ref('order_review_latest') }} AS order_review ON
        "order".order_id = order_review.order_id
