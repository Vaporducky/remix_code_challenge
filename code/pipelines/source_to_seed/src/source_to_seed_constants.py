# SPARK CONFIGURATION
# Annotations
SparkConfiguration = dict[str, str]

# Configuration
CONFIG: SparkConfiguration = {
    # Compute configuration
    "spark.driver.memory": "2g",
    "spark.sql.shuffle.partitions": 8,
    "spark.default.parallelism": 4,
    # Adaptive configuration
    "spark.sql.adaptive.enabled": "true",
    "spark.sql.adaptive.coalescePartitions": "true",
    "spark.sql.adaptive.skewJoin.enabled": "true",
    # Postgres SQL Configuration
    "spark.jars": "/home/elianther/bin/spark-3.5.1/jars/postgresql-42.7.3.jar"
}
