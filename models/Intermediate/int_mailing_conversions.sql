{{
    config(
        materialized='view'
    )
}}

SELECT
    m.mailing_id,
    m.company_id,
    m.hashed_email,
    m.campaign_id,
    m.date_emailed,
    m.status,
    o.order_id,
    o.order_date,
    o.order_amount,
    o.order_status,
    CASE
        WHEN o.order_date IS NOT NULL
        THEN (o.order_date - m.date_emailed)
        ELSE NULL
    END as days_to_convert,
    CURRENT_TIMESTAMP as dbt_loaded_at
FROM {{ ref('stg_customer_mailings') }} m
LEFT JOIN {{ ref('stg_event_basket') }} o
    ON m.hashed_email = o.hashed_email
    AND m.company_id = o.company_id
    AND o.order_date >= m.date_emailed
    AND o.order_date <= m.date_emailed + INTERVAL '90 days'