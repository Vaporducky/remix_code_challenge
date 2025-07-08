{{ config(materialized='table') }}

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
FROM {{ ref('product') }}
