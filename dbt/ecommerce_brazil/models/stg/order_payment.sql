SELECT *
FROM {{ source('raw', 'order_payment') }}