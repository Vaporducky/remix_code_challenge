# Remix Code Challenge

## Introduction

## Configuration
1. Build the Spark-Postgres image:
```commandline
docker buildx build \
  --tag local_repo/spark-postgres-0.0.1 \
  --file build/docker/spark/Dockerfile \
  .
```

## Setup

### Initialization
```commandline
docker compose up -d && docker compose up 
```

### Accessing containers
**Enter the Postgres Container**
```commandline
docker compose exec postgres psql -U airflow -d airflow
```

**Enter the DBT Container**
```commandline
docker compose exec dbt
```

### Cleaning the environment
```commandline
docker compose down --volumes --remove-orphans
```
## DBT
### Macro
In order to use other schemas, it is necessary (for us) to override the custom
schema generation. The custom logic:
```jinja
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
```

As one may appreciate, the line 
`{{ default_schema }}_{{ custom_schema_name | trim }}` will add a suffix
to our default schema (which we do not want!). Instead, we will override the
behavior with the following:

```jinja
{% macro generate_schema_name(custom_schema_name, node) -%}

  {%- if custom_schema_name is not none -%}
  
    {{ return(custom_schema_name) }}

  {%- endif -%}

  {{ return(target.schema) }}

{%- endmacro %}
```

Which will allows us to use our custom schemas instead of suffixing the default
schema.