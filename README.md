# E-Commerce Campaign Performance Pipeline

This project moves business logic out of the BI tool and into version-controlled code. Every transformation, every metric definition, every business rule lives in dbt tracked by Git, validated by tests, orchestrated by Dagster. The dashboard becomes a thin viewing layer that reads from a tested, versioned mart table. 

# Business Problem
The organisation would be able to measure the campaign performance of the customers who were sent a campaign and who converted. The stakeholders would be able to filter the dates , attribution window and would be able to monitor the campaign performance on a daily basis.

### Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| Storage | PostgreSQL 15 (AWS RDS) | Raw and transformed data |
| Transformation | dbt Core 1.8.0 | SQL-based data modelling |
| Orchestration | Dagster | Scheduling, monitoring, lineage |
| Visualisation | Amazon QuickSight | Interactive attribution dashboard |
| Version Control | Git / GitHub | Code versioning and collaboration |

## Data Model


<img width="674" height="378" alt="image" src="https://github.com/user-attachments/assets/b40b4f6d-697c-454c-93f3-18ae4edae124" />

### Schema Design

The pipeline follows a layered architecture with four schemas:

**raw** -  source data (5 tables)
- `customers` - 12,000 customer records across 3 companies
- `customer_address` - 12,000 address records
- `campaigns` - 36 email campaigns
- `customer_mailings` - 101,604 mailing records
- `event_basket` - 7,036 orders

**staging** - Cleaned individual tables (5 views)
- Type casting, consistent naming, no business logic

**intermediate** - Joins and business logic (1 view)
- `int_mailing_conversions` - Joins mailings to orders on `hashed_email`, calculates `days_to_convert`

**marts** - Dashboard-ready output (1 table)
- `mart_ecommerce_performance` - 103,171 rows, wide and flat, indexed for QuickSight

### Attribution Logic

- Join key: `hashed_email` (SHA-256 of normalised email) + `company_id`
- Attribution rule: Most recent email before the order gets credit
- Maximum window: 90 days (capped in the intermediate model)
- Dynamic filtering: QuickSight parameter lets users select attribution window

- ### Design Decisions

- **hashed_email as logical FK** - Not enforced at database level. Enforced by dbt relationship tests. If a mailing references a non-existent customer, the test fails and the pipeline stops.
- **days_to_convert stored raw** - No attribution window baked into the mart. One table serves all window sizes. The BI tool filters, not computes.
- **generate_schema_name macro** - Custom macro ensures models land in clean schema names (`staging`, `intermediate`, `marts`).

## Testing as a Gate

13 tests run automatically after every model build:

- **not_null** - Primary keys and critical columns always have values
- **unique** - No duplicate primary keys
- **relationships** - Every foreign key references a valid parent record

Dagster chains the execution: `dbt run` → `dbt test`
