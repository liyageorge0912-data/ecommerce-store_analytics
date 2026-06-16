{{
    config(
        materialized='view'
    )
}}

SELECT
    customer_id,
    company_id,
    email,
    hashed_email,
    first_name,
    last_name,
    address_id,
    acquisition_channel,
    customer_segment,
    region,
    created_at::DATE as created_at,
    CURRENT_TIMESTAMP as dbt_loaded_at
FROM {{ source('raw', 'customers') }}