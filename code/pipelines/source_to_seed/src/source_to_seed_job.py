import re
import logging
import yaml
from pathlib import Path

import pyspark.sql.functions as F
from pyspark.sql import DataFrame

import src.source_to_seed_utilities as utilities
from src.source_to_seed_utilities import PostgresSink
import src.source_to_seed_constants as constants
from standards.gen_spark import GenSpark


class SourceToSeedJob:
    def __init__(self, spark_config, job_args: utilities.JobArguments):
        self.job_args = job_args
        self.sink_config: PostgresSink = self.job_args.sink_configuration
        self.gen_spark_session: GenSpark = GenSpark(
            conf=spark_config,
            job_name="source_to_seed_job",
            strategy="hive"
        )

    def _generate_file_mapping(self):
        csv_files: tuple[Path] = tuple(
            self.job_args.source_data_path.glob("olist*")
        )
        pattern = re.compile(r"(?<=olist_).\w+(?=_dataset)")

        # Generate mapping between table name and its system filepath
        logging.info(f"Generating file-table mapping.")
        file_mapping: dict[str, Path] = {
            next(pattern.finditer(csv_file.stem), None).group(): csv_file
            for csv_file in csv_files
        }
        logging.info(f"Successfully generated mapping.")

        return file_mapping

    def run(self):
        file_mapping = self._generate_file_mapping()

        for table_name, file_path in file_mapping.items():
            if table_name == 'sellers':
                logging.info(f"Processing file `{file_path}`:")
                df: DataFrame = (
                    self.gen_spark_session.spark.read
                    .format("csv")
                    .options(header=True,
                             delimiter=",")
                    .load(file_path.as_posix())
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
