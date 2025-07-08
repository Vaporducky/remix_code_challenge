# Remix Code Challenge

## Introduction
Build a high-performance, testable Data Warehouse on top of the
[Olist Brazilian e-commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce?select=olist_order_reviews_dataset.csv).  

The goal is to answer the following questions:
1. **_What is the average time from purchase to delivery?_**
2. **_What are the top-performing product categories by revenue?_**
3. **_How do review scores correlate with delivery time?_**

With this goal set on mind, we will build a denormalized star schema with a
central fact order table which will contain key metrics such as the total value
of an order; it will also contain item-level information such as product value
when the order was made.

### Data Layers

1. **Raw**  
   - Ingest CSVs with zero transformation.  
   - Immutable snapshots for reproducibility.

2. **Staging**
The staging layer will mostly introduce:
   - Simple data quality checks
      - Quarantine method to separated "_good_" and "_bad_" records applying 
         _ad hoc_ business rules
      - Deduplication (if possible); *e.g.*, for `order_review` we took the latest
         review to build the `review` dimension
      - Integrity checks
   - Enrichment
   - Canonicalization
   - Tests
      - Integrity checks
      - Inclusion set

### Mart

The tables will be:
- `fct_order_item_extended` - The grain is `[order_id, product_id_within_order]`;
  it contains details about the order and the product. There's also aggregated
  metrics such as the `order_total`
- `dim_order` - This dimension contains mostly time-related attributes related
  to an order
- `dim_customer` - Customer details
- `dim_product` - Product details; simulates an SCD2
- `dim_order_review` - Order review details; contains the latest review made by
  the customer

### Tools
We will be using:
1. Docker
2. Airflow
3. PySpark
4. DBT
5. PostgresSQL

## Setup
This repository assumes the following:
- The user has 
  - `pyenv` installed on their system
  - a running configuration of PySpark in their system. The version used
  this project is 3.5.0
  - _In the future, we will Dockerize this situation in order to prevent any
    misconfiguration from the user side._
- Docker Compose

We offer a minimal setup guide.

### Install Docker
Install docker using the installation script
```
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

Verify it runs correctly
```shell
sudo docker run hello-world
```

Add appropriate permissions
```shell
groupd add docker
sudo usermod -aG docker $USER
newgrp docker
```

Retry running without sudo
```shell
docker run hello-world
```

### pyenv
This project uses pyenv as a Python version manager. The following code allows you to setup required environment:

```shell
# Install dependencies
sudo apt update; sudo apt install -y build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev \
libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev git gcc make libpq-dev

# Install pyenv
curl https://pyenv.run | bash

# Configure PATH
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# Source bash
. ~/.bashrc

# Clone repository
git clone "https://github.com/Vaporducky/remix_code_challenge"

cd remix_code_challenge

# Setup virtual environment
pyenv install -v 3.10.9
pyenv virtualenv 3.10.9 remix_code_challenge
pyenv activate remix_code_challenge
python3.10 -m pip install --upgrade pip
pip install -r requirements.txt
```


## Initialization
### 1. Initial data setup
First, we will run all and orchestrate all the services
1. Airflow
2. PostgresSQL
3. DBT
4. `[To be implented]` Spark

using Docker compose

```shell
docker compose up -d; docker compose up
```

Airflow will automatically run a DAG which will:
1. Download the Kaggle dataset (inside that `./data` folder)
2. Unzip the dataset and clean it up
3. Normalize quoting on CSVs
4. Move the product PR-EN mapping into the seed folder linking to the DBT
   container's mount

At the end of this step you should be seeing:
1. Input data from Kaggle + a normalized order review CSV file
2. A file in `./data/input/seeds`

#### Accessing containers
Postgres service into the `airflow` database using the `airflow` user
```shell
docker compose exec postgres psql -U airflow -d airflow
```
DBT service
```shell
docker compose exec dbt bash
```
### 2. `platform` and `warehouse` databases
For this step, we will be using Spark in order to load each of the CSVs we have
in the `input` folder into the `platform` database which will
basically simulate data stored from an E-Commerce store. After that we will
trigger a second pipeline which will full-ingest data from the platform side
into our `warehouse` database.

We have two pipelines which we will be using in order to so:

**Source to Seed**
```shell
bash code/pipelines/source_to_seed/scripts/build.sh
```

**Platform to Raw**
```shell
bash code/pipelines/platform_to_raw/scripts/build.sh
```

After this step, we should have all the tables in the `platform` and `warehouse`
databases. We may check them out using the following:

```shell
docker compose exec postgres psql -U airflow -d airflow
```

Inside the container,
```shell
\c [platform | warehouse]
\dt [ecommerce | raw].*
```
### 3. Creating the warehouse
In this step we will be creating all the warehouse tables, from staging to the
mart; since the raw layer has already been implemented by the Spark passthrough
job we don't have to worry about it.

Exec into the DBT service
```shell
docker compose exec dbt bash
```
Inside the container,
```shell
cd ecommerce_brazil/
dbt seed
dbt run
dbt snapshot
dbt test
```

At the end of this step we will have created the warehouse we discussed
during the introduction of this project.

---

## Cleaning the environment
```shell
docker compose down --volumes --remove-orphans
```

---

## Notes
### DBT
#### Macro
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