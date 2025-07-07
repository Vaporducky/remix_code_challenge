WITH review_normalized AS (
    SELECT
        TRIM(review_id) AS review_id,
        TRIM(order_id) AS order_id,
        TRIM(review_score) AS review_score,
        TRIM(review_comment_title) AS review_comment_title,
        TRIM(review_comment_message) AS review_comment_message,
        review_creation_date,
        review_answer_timestamp,
        COUNT(*) OVER (PARTITION BY TRIM(review_id)) AS duplicate
    FROM {{ source('raw', 'order_review') }}
),
review_fk_check AS (
    SELECT
        review_normalized.*,
        "order".order_id AS fk_order_id
    FROM review_normalized
    LEFT JOIN (SELECT DISTINCT order_id FROM {{ ref('order') }}) AS "order"
        ON review_normalized.order_id = "order".order_id
),
review_quarantine AS (
    SELECT *,
        (review_id IS NULL)::int AS review_id_quarantine,
        (order_id IS NULL)::int AS order_id_quarantine,
        CASE
            WHEN review_score ~ '^[1-5]$' THEN 0
            ELSE 1
        END AS review_score_quarantine,
        (duplicate > 1)::int AS review_id_uniqueness_quarantine,
        (fk_order_id IS NULL)::int AS fk_order_id_quarantine
    FROM review_fk_check
),
row_quarantine_filtering AS (
    SELECT
        review_id,
        order_id,
        review_score,
        review_comment_title,
        review_comment_message,
        review_creation_date,
        review_answer_timestamp,
        GREATEST(
            review_id_quarantine,
            order_id_quarantine,
            review_score_quarantine,
            review_id_uniqueness_quarantine,
            fk_order_id_quarantine
        ) AS row_quarantine_flag
    FROM review_quarantine
)
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date AS review_creation_dt,
    review_answer_timestamp AS review_answer_ts
FROM row_quarantine_filtering
WHERE row_quarantine_flag = 0