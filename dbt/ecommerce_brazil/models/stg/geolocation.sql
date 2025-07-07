SELECT *
FROM {{ source('raw', 'geolocation') }}