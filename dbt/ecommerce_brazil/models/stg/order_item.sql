WITH order_item_normalized AS
(
    SELECT
        TRIM(order_id) AS order_id,
        /* Change field name to reflect its behavior. */
        TRIM(order_item_id) AS product_id_within_order,
        TRIM(product_id) AS product_id,
        TRIM(seller_id) AS seller_id,
        shipping_limit_date,
        price AS product_price,
        freight_value,
        COUNT(*) OVER (PARTITION BY TRIM(order_id), TRIM(order_item_id)) AS duplicate
    FROM {{ source('raw', 'order_item') }}
),
order_item_fk_check AS
(
    SELECT
        order_item_normalized.*,
        "order".order_id AS fk_order_id,
        product.product_id AS fk_product_id,
        seller.seller_id AS fk_seller_id
    FROM order_item_normalized
        LEFT JOIN (SELECT DISTINCT order_id FROM {{ ref('order') }}) AS "order" ON
            order_item_normalized.order_id = "order".order_id
        LEFT JOIN (SELECT DISTINCT product_id FROM {{ ref('product') }}) AS product ON
            order_item_normalized.product_id = product.product_id
        LEFT JOIN (SELECT DISTINCT seller_id FROM {{ ref('seller') }}) AS seller ON
            order_item_normalized.seller_id = seller.seller_id
),
order_item_quarantine AS (
    SELECT *,
        (order_id IS NULL)::int AS order_id_quarantine,
        (product_id_within_order IS NULL)::int AS product_id_within_order_quarantine,
        (product_id IS NULL)::int AS product_id_quarantine,
        (seller_id IS NULL)::int AS seller_id_quarantine,
        (duplicate > 1)::int AS composite_pk_violation,
        (fk_order_id IS NULL)::int AS fk_order_id_quarantine,
        (fk_product_id IS NULL)::int AS fk_product_id_quarantine,
        (fk_seller_id IS NULL)::int AS fk_seller_id_quarantine,
        (product_price < 0)::int AS product_price_quarantine,
        (freight_value < 0)::int AS freight_value_quarantine,
        (shipping_limit_date IS NULL)::int AS shipping_limit_date_quarantine
    FROM order_item_fk_check
),
row_quarantine_filtering AS (
    SELECT
        order_id,
        product_id_within_order,
        product_id,
        seller_id,
        shipping_limit_date,
        product_price,
        freight_value,
        GREATEST(
            order_id_quarantine,
            product_id_within_order_quarantine,
            product_id_quarantine,
            seller_id_quarantine,
            composite_pk_violation,
            fk_order_id_quarantine,
            fk_product_id_quarantine,
            fk_seller_id_quarantine,
            product_price_quarantine,
            freight_value_quarantine,
            shipping_limit_date_quarantine
        ) AS row_quarantine_flag
    FROM order_item_quarantine
)
SELECT
    order_id,
    product_id_within_order,
    product_id,
    seller_id,
    shipping_limit_date,
    product_price,
    freight_value
FROM row_quarantine_filtering
WHERE row_quarantine_flag = 0
