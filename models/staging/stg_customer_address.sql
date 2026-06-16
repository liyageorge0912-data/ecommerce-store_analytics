{{
    config(
        materialized='view'
    )
}}

SELECT
    address_id,
    address_line_1,
    address_line_2,
    city,
    county,
    postcode,
    country,
    CURRENT_TIMESTAMP as dbt_loaded_at
FROM {{ source('raw', 'customer_address') }}