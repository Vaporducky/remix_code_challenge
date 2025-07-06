-- Create data engineering role
CREATE ROLE data_engineer;

-- Create ad hoc user for PySpark execution
CREATE USER spark_user
    WITH PASSWORD 'hello_kitty'
    IN ROLE data_engineer
;

-- Create ad hoc user for dbt execution
CREATE USER dbt_user
    WITH PASSWORD 'kuromi'
    IN ROLE data_engineer
;
