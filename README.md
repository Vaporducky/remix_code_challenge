# Remix Code Challenge

## Setup
```bash
pip install dbt-core dbt-spark
```

```bash
pip install 'dbt-spark[PyHive]'
```

**Launch a Thrift server**
```bash
spark-submit \
  --master 'local[*]' \
  --conf spark.executor.extraJavaOptions=-Duser.timezone=Etc/UTC \
  --conf spark.eventLog.enabled=false \
  --conf spark.sql.warehouse.dir=file:///tmp/spark-warehouse  \
  --packages 'org.apache.spark:spark-sql_2.12:3.5.1,org.apache.spark:spark-hive_2.12:3.5.1' \
  --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 \
  --name "Thrift JDBC/ODBC Server" \
  --executor-memory 1g
```

**Connect to the Thrift server**
```bash
beeline -u jdbc:hive2://localhost:10000/default
```