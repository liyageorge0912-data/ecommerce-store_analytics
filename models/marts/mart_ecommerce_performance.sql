{{
    config(
        materialized='table',
        schema='marts',
        indexes=[
            {'columns': ['hashed_email']},
            {'columns': ['campaign_id']},
            {'columns': ['days_to_convert']}
        ]
    )
}}

SELECT
    m.mailing_id,
    m.company_id,
    m.hashed_email,
    m.campaign_id,
    m.date_emailed,
    m.status as mailing_status,
    
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.acquisition_channel,
    c.customer_segment,
    c.region,
    

    a.address_line_1,
    a.address_line_2,
    a.city,
    a.county,
    a.postcode,
    a.country,
    

    cmp.campaign_name,
    cmp.unit_cost,
    cmp.campaign_type,
    cmp.send_date as campaign_send_date,
    
  
    m.order_id,
    m.order_date,
    m.order_amount,
    m.order_status,
    
   
    m.days_to_convert,
    
    m.dbt_loaded_at
FROM {{ ref('int_mailing_conversions') }} m
LEFT JOIN {{ ref('stg_customers') }} c
    ON m.hashed_email = c.hashed_email
    AND m.company_id = c.company_id
LEFT JOIN {{ ref('stg_customer_address') }} a
    ON c.address_id = a.address_id
LEFT JOIN {{ ref('stg_campaigns') }} cmp
    ON m.campaign_id = cmp.campaign_id