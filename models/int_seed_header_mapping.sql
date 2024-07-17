-- This is an example query for returning a mapping table for renaming columns and addressing the nested header issue.

-- unpivot the staged model to get header name in the rows In this instance the excluded columns are not pivotted and .

with unpivot as (

    {{ dbt_utils.unpivot(relation=ref('stg_seed_sample_data'), cast_to='varchar', exclude=['employee', 'row_num'], field_name = 'header', value_name = 'subheader') }}
    
),

-- only take row 1
original_headers as(

    select

        row_number() over (order by null) as col_num,
        header,      
    
    from unpivot
    
    where row_num = 1

),

-- Prep the headers that need to be renamed, in this case they are all length(1) so are changed to null so their info can be copied down and concatenated with the nested header value.
headers as (

    select

        row_num as rn,
        case 
            when length(header) = 1 then null
            else header
        end as header,
        subheader
    
    from unpivot
    
    where row_num = 1

),

-- copy down header value using last_value
new_headers as (
    select

        
        row_number() over (order by null) as col_num,
        case
            when subheader is null then header 
            else coalesce(header, last_value(header) ignore nulls over (order by rn rows between unbounded preceding and current row)) || '_' || coalesce(subheader, '') 
        end as new_header,


    from headers 

),

-- sql databases do not like special characters in the table name so replace these with '_'

rename_table as (

    select

        upper(regexp_replace(h.new_header, '[^A-Za-z0-9_]', '_')) as new_header,

        original_headers.header

    from new_headers h
    inner join original_headers on h.col_num = original_headers.col_num

)

-- end result is a row for every column and THE ORDER IS IMPORTANT, we have new_header followed by original header.

select * from rename_table
