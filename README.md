# Remix Code Challenge

## Introduction

## Setup

### Initialization
```commandline
docker compose up -d &&
docker compose up 
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