{{ config(
    materialized='table'
) }}

select * from  {{ source('source_tbl', 'raw_customers') }}{{ config(
    materialized='table'
) }}

select * from  {{ source('source_tbl', 'raw_customers') }}
