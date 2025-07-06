\connect warehouse airflow;

/* ==========================================================================
   Create schemas
   ========================================================================== 
*/
CREATE SCHEMA IF NOT EXISTS raw
  AUTHORIZATION data_engineer
;
CREATE SCHEMA IF NOT EXISTS stg
  AUTHORIZATION data_engineer
;
CREATE SCHEMA IF NOT EXISTS mart
  AUTHORIZATION data_engineer
;

/* ==========================================================================
   Grant connect
   ========================================================================== 
*/
GRANT CONNECT ON DATABASE warehouse TO data_engineer;

/* ==========================================================================
   Schema-level privileges
   ========================================================================== 
*/
GRANT USAGE, CREATE ON SCHEMA raw TO data_engineer;
GRANT USAGE, CREATE ON SCHEMA stg TO data_engineer;
GRANT USAGE, CREATE ON SCHEMA mart TO data_engineer;

/* ==========================================================================
   Table and sequence privileges on existing objects
   ========================================================================== 
*/
-- raw
GRANT ALL PRIVILEGES
  ON ALL TABLES IN SCHEMA raw
  TO data_engineer
;
GRANT USAGE, SELECT
  ON ALL SEQUENCES IN SCHEMA raw
  TO data_engineer
;

-- stg
GRANT ALL PRIVILEGES
  ON ALL TABLES IN SCHEMA stg
  TO data_engineer
;
GRANT USAGE, SELECT
  ON ALL SEQUENCES IN SCHEMA stg
  TO data_engineer
;

-- mart
GRANT ALL PRIVILEGES
  ON ALL TABLES IN SCHEMA mart
  TO data_engineer
;
GRANT USAGE, SELECT
  ON ALL SEQUENCES IN SCHEMA mart
  TO data_engineer
;


/* ==========================================================================
   Default privileges for future objects
   ==========================================================================
*/

-- raw
ALTER DEFAULT PRIVILEGES
  FOR ROLE data_engineer
  IN SCHEMA raw
  GRANT ALL PRIVILEGES
    ON TABLES
    TO data_engineer
;
ALTER DEFAULT PRIVILEGES
  FOR ROLE data_engineer
  IN SCHEMA raw
  GRANT USAGE, SELECT
    ON SEQUENCES
    TO data_engineer
;

-- stg
ALTER DEFAULT PRIVILEGES
  FOR ROLE data_engineer
  IN SCHEMA stg
  GRANT ALL PRIVILEGES
    ON TABLES
    TO data_engineer
;
ALTER DEFAULT PRIVILEGES
  FOR ROLE data_engineer
  IN SCHEMA stg
  GRANT USAGE, SELECT
    ON SEQUENCES
    TO data_engineer
;

-- mart
ALTER DEFAULT PRIVILEGES
  FOR ROLE data_engineer
  IN SCHEMA mart
  GRANT ALL PRIVILEGES
    ON TABLES
    TO data_engineer
;
ALTER DEFAULT PRIVILEGES
  FOR ROLE data_engineer
  IN SCHEMA mart
  GRANT USAGE, SELECT
    ON SEQUENCES
    TO data_engineer
;
