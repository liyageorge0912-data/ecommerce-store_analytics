{{
    config(
        materialized='view'
    )
}}

SELECT
    mailing_id,
    company_id,
    hashed_email,
    campaign_id,
    date_emailed::DATE as date_emailed,
    status,
    CURRENT_TIMESTAMP as dbt_loaded_at
FROM {{ source('raw', 'customer_mailings') }}