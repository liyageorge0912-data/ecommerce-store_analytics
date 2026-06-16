{{
    config(
        materialized='view'
    )
}}

SELECT
    campaign_id,
    company_id,
    campaign_name,
    unit_cost,
    send_date::DATE as send_date,
    campaign_type,
    CURRENT_TIMESTAMP as dbt_loaded_at
FROM {{ source('raw', 'campaigns') }}