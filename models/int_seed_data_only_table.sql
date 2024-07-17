-- take the staged data and in this example skip the first row so that we have a table with the original column names and the first row is now the first row that data actually starts.

with source as (

    select * from {{ ref('stg_seed_sample_Data') }}

),

-- skip the nested header row
transformed as (

    select

        *

    from source
    where row_num > 1

)

select * from transformed
