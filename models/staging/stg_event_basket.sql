{{
    config(
        materialized='view'
    )
}}

SELECT
    order_id,
    company_id,
    hashed_email,
    order_date::DATE as order_date,
    order_amount,
    order_status,
    CURRENT_TIMESTAMP as dbt_loaded_at
FROM {{ source('raw', 'event_basket') }}