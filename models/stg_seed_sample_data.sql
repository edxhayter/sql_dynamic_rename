-- read in the seed data (rememnber to dbt seed the source data in if you want to walk through the included example.)

with source as (

    select 

        *

    from {{ ref('rename_sample_data') }}

),

-- add a source row number as this is important in lots of cases for using a sql query to create a mapping table for the headers.

transformed as (

 select 

        *,
        row_number() over (order by null) as row_num

from source

)

select * from transformed
