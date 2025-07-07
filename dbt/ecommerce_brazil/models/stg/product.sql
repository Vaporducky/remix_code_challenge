WITH product_normalized AS (
    SELECT
        TRIM(product.product_id) AS product_id,
        LOWER(TRIM(product.product_category_name)) AS product_category_name,
        product_mapping.product_category_name_english,
        product.product_name_lenght AS product_name_length,
        product.product_description_lenght  AS product_description_length,
        product.product_photos_qty AS product_photos_quantity,
        product.product_weight_g AS product_weight_in_grams,
        product.product_length_cm,
        product.product_height_cm,
        product.product_width_cm,
        COUNT(*) OVER (PARTITION BY TRIM(product.product_id)) AS duplicate
    FROM {{ source('raw', 'product') }} AS product
        LEFT JOIN {{ ref('product_category_name_translation') }} AS product_mapping ON
            LOWER(TRIM(product.product_category_name)) = LOWER(TRIM(product_mapping.product_category_name))
),
product_quarantine AS (
    SELECT *,
        (product_id IS NULL)::int AS product_id_quarantine,
        (product_name_length IS NOT NULL AND product_name_length < 1)::int AS product_name_length_quarantine,
        (product_description_length IS NOT NULL AND product_description_length < 1)::int AS product_description_length_quarantine,
        (product_photos_quantity IS NOT NULL AND product_photos_quantity < 0)::int AS product_photos_quantity_quarantine,
        (product_weight_in_grams IS NOT NULL AND product_weight_in_grams < 0)::int AS product_weight_quarantine,
        (product_length_cm IS NOT NULL AND product_length_cm < 0)::int AS product_length_quarantine,
        (product_height_cm IS NOT NULL AND product_height_cm < 0)::int AS product_height_quarantine,
        (product_width_cm IS NOT NULL AND product_width_cm < 0)::int AS product_width_quarantine,
        (duplicate > 1)::int AS product_id_uniqueness_quarantine
    FROM product_normalized
),
row_quarantine_filtering AS (
    SELECT
        product_id,
        product_category_name,
        product_category_name_english,
        product_name_length,
        product_description_length,
        product_photos_quantity,
        product_weight_in_grams,
        product_length_cm,
        product_height_cm,
        product_width_cm,
        GREATEST(
            product_id_quarantine,
            product_name_length_quarantine,
            product_description_length_quarantine,
            product_photos_quantity_quarantine,
            product_weight_quarantine,
            product_length_quarantine,
            product_height_quarantine,
            product_width_quarantine,
            product_id_uniqueness_quarantine
        ) AS row_quarantine_flag
    FROM product_quarantine
)
SELECT
    product_id,
    product_category_name,
    product_category_name_english,
    product_name_length,
    product_description_length,
    product_photos_quantity,
    product_weight_in_grams,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM row_quarantine_filtering
WHERE row_quarantine_flag = 0
