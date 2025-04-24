{{ config(
    materialized='table'
) }}

select * from  {{ source('source_tbl2', 'raw_orders') }}
