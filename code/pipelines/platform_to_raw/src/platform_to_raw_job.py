import re
import logging
import yaml
from pathlib import Path

import pyspark.sql.functions as F
from pyspark.sql import DataFrame

import src.platform_to_raw_utilities as utilities
from src.platform_to_raw_utilities import PostgresSource, PostgresSink
import src.platform_to_raw_constants as constants
from standards.gen_spark import GenSpark


class PlatformToRawJob:
    def __init__(self, spark_config, job_args: utilities.JobArguments):
        self.job_args = job_args
        self.source_config: PostgresSource = self.job_args.source_configuration
        self.sink_config: PostgresSink = self.job_args.sink_configuration
        self.gen_spark_session: GenSpark = GenSpark(
            conf=spark_config,
            job_name="platform_to_raw_job",
            strategy="vanilla"
        )

    def run(self):
        for table_name, schema in self.source_config.sources.items():
            src_table_namespace = self.source_config.get_table_namespace(table_name)
            logging.info(f"Processing table `{src_table_namespace}`:")

            if table_name == 'sellers':
                df: DataFrame = (
                    self.gen_spark_session.spark.read
                    .option("url", self.source_config.jdbc_url)
                    .option("dbtable", src_table_namespace)
                    .option("user", self.source_config.user)
                    .option("password", self.source_config.password)
                    .option("driver", self.source_config.driver)
                    .format("jdbc")
                    .load()
                )

        for table_name, schema in self.sink_config.targets.items():
            if table_name == 'seller':
                # Get the table namespace
                tgt_table_namespace = self.sink_config.get_table_namespace(table_name)
                logging.info(f"Writing into `{tgt_table_namespace}`.")
                (
                    df.write
                    .option("url", self.sink_config.jdbc_url)
                    .option("dbtable", tgt_table_namespace)
                    .option("user", self.sink_config.user)
                    .option("password", self.sink_config.password)
                    .option("driver", self.sink_config.driver)
                    .format("jdbc")
                    .mode("overwrite")
                    .save()
                )
