SELECT
    review_id,
    order_id,
    latest_review_comment_title,
    latest_review_comment_message,
    latest_review_creation_dt,
    latest_review_answer_ts
FROM {{ ref('order_review_latest') }}
