import sys
import logging

import common_utilities
import src.source_to_seed_utilities as utilities
import src.source_to_seed_constants as constants
from src.source_to_seed_job import SourceToSeedJob


def main():
    logging.info("Starting argument parsing.")
    args = utilities.JobArguments.from_args()
    logging.info("Argument parsing completed successfully.")

    # Instantiate job
    job = SourceToSeedJob(spark_config=constants.CONFIG,
                          job_args=args)

    # Execute job
    try:
        logging.info(f"Initializing `{args.job_name}` pipeline.")
        job.run()
    except Exception as e:
        logging.exception(f"An error has occurred.", exc_info=e)
        sys.exit(1)
    else:
        logging.info(f"Pipeline successful.")


if __name__ == "__main__":
    common_utilities.setup_logging()
    main()

# spark-submit --master 'local[*]' --conf spark.executor.extraJavaOptions=-Duser.timezone=Etc/UTC --conf spark.sql.warehouse.dir=file:///tmp/spark-warehouse --packages 'org.apache.spark:spark-sql_2.12:3.5.1,org.apache.spark:spark-hive_2.12:3.5.1' --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 --name "Thrift JDBC/ODBC Server" --executor-memory 1g load_data.py
