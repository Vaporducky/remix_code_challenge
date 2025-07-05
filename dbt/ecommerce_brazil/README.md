Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

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