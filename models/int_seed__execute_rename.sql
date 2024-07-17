-- as the rename macro has references back to models, we might have problems with unclear references.
-- this can be avoided two ways, in this version, within the model itself before calling the macro we have added CTEs that refer to the two proceeding models that are needed in the macro. This ensures that this model and the macro within execute after the first two models (otherwise the macro within this model will try and execute before the models are created)

-- the other approach is to tell dbt with a comment statement at the start of the model that specifies dependencies. Like so
-- depends_on: {{ ref('int_seed_data_only_table') }}

with data as (

    select * from {{ ref('int_seed_data_only_table') }}

),

header_mapping as (

    select * from {{ ref('int_seed_header_mapping') }}

),

-- the macro returns a list of column_name1 as new_column_name1, column_name2 as new_column_name2 etc. that are then wrapped in the model with a select and a from for the data that is to be renamed. 

renamed_table as (
        
        select

            {{ dynamic_rename('int_seed_header_mapping','int_seed_data_only_table') }}

        from data

)

select * from renamed_table
