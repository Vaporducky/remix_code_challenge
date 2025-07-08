WITH review_latest AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY order_id
                           ORDER BY review_answer_ts DESC)
        AS review_answer_order
    FROM {{ ref('order_review_audit') }}
    WHERE review_score IS NOT NULL
)
SELECT
    review_id,
    order_id,
    review_score AS latest_review_score,
    review_comment_title AS latest_review_comment_title,
    review_comment_message AS latest_review_comment_message,
    review_creation_dt AS latest_review_creation_dt,
    review_answer_ts AS latest_review_answer_ts
FROM review_latest
WHERE review_answer_order = 1