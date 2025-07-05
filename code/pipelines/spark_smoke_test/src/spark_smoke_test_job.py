import logging

from pyspark.sql.types import Row

import src.spark_smoke_test_utilities as utilities
import src.spark_smoke_test_constants as constants
from standards.gen_spark import GenSpark


class SparkSmokeTestJob:
    def __init__(self, spark_config, job_args: utilities.JobArguments):
        self.job_args = job_args
        self.gen_spark_session: GenSpark = GenSpark(
            conf=spark_config,
            job_name="spark_smoke_test_job",
            strategy="vanilla"
        )

    def run(self):
        df = self.gen_spark_session.spark.createDataFrame([Row(id=1),
                                                           Row(id=2)])

        logging.info(f"Count of rows: {df.count()}")
