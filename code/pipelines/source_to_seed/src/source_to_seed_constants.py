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
    # Hive catalog configuration
    "spark.sql.warehouse.dir": "file:///tmp/spark-warehouse",
    "spark.sql.catalogImplementation": "hive",
    "spark.sql.hive.metastore.version": "2.3.9",
    "spark.jars.packages": "org.apache.spark:spark-sql_2.12:3.5.1,org.apache.spark:spark-hive_2.12:3.5.1",
    # Java options
    "spark.executor.extraJavaOptions": "-Duser.timezone=Etc/UTC",
}
