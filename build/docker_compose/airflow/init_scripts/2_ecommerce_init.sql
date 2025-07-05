/* Connect to the `platform` database */
\connect platform;

/* Create `ecommerce` schema to load input data */
CREATE SCHEMA IF NOT EXISTS ecommerce
    AUTHORIZATION data_engineer
;
