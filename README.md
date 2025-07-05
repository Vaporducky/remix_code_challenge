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