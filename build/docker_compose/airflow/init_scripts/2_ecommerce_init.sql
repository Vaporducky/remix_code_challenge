\connect platform airflow;

-- Create schema
CREATE SCHEMA IF NOT EXISTS ecommerce
  AUTHORIZATION data_engineer
;

-- Schema-level grants
GRANT CONNECT ON DATABASE platform TO data_engineer;
GRANT USAGE, CREATE ON SCHEMA ecommerce TO data_engineer;

-- Table-level grants (existing objects)
GRANT ALL PRIVILEGES
  ON ALL TABLES IN SCHEMA ecommerce
  TO data_engineer
;
GRANT USAGE, SELECT
  ON ALL SEQUENCES IN SCHEMA ecommerce
  TO data_engineer
;

-- Default privileges for future objects
ALTER DEFAULT PRIVILEGES
  FOR ROLE data_engineer
  IN SCHEMA ecommerce
  GRANT ALL PRIVILEGES
    ON TABLES
    TO data_engineer
;
ALTER DEFAULT PRIVILEGES
  FOR ROLE data_engineer
  IN SCHEMA ecommerce
  GRANT USAGE, SELECT
    ON SEQUENCES
    TO data_engineer
;