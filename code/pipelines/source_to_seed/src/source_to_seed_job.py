import logging

from pyspark.sql import DataFrame

import src.source_to_seed_utilities as utilities
from src.source_to_seed_utilities import PostgresSink, CsvSource
from standards.gen_spark import GenSpark


class SourceToSeedJob:
    def __init__(self, spark_config, job_args: utilities.JobArguments):
        self.job_args = job_args
        self.source_config: CsvSource = self.job_args.source_configuration
        self.sink_config: PostgresSink = self.job_args.sink_configuration
        self.gen_spark_session: GenSpark = GenSpark(
            conf=spark_config,
            job_name=self.job_args.job_name,
            strategy="vanilla"
        )

    @staticmethod
    def _normalize_entity(entity: str) -> str:
        if entity.endswith("s"):
            return entity[:-1]
        else:
            return entity

    def run(self):

        for table_name, file_path in self.source_config.sources.items():
            logging.info(f"Processing file `{file_path}`:")
            df: DataFrame = (
                self.gen_spark_session.spark.read
                .format("csv")
                .options(header=True,
                         delimiter=",")
                .schema(self.source_config.schemas[table_name])
                .load(file_path)
            )

            # Get the table namespace
            table_namespace = self.sink_config.get_table_namespace(table_name)
            logging.info(f"Writing into `{table_namespace}`.")
            (
                df.write
                .option("url", self.sink_config.jdbc_url)
                .option("dbtable", table_namespace)
                .option("user", self.sink_config.user)
                .option("password", self.sink_config.password)
                .option("driver", self.sink_config.driver)
                .format("jdbc")
                .mode("overwrite")
                .save()
            )
