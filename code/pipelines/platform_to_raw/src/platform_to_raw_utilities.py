import json
import yaml
import argparse
import logging
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional


@dataclass(frozen=True)
class PostgresSink:
    jdbc_url: str = field(repr=False)
    user: str = field(repr=False)
    password: str = field(repr=False)
    driver: str = field(repr=False)
    targets: dict[str, str] = field(repr=False)
    batchsize: int = field(repr=False, default=1000)
    num_partitions: Optional[int] = field(repr=False, default=None)
    partition_col: Optional[str] = field(repr=False, default=None)
    lower_bound: Optional[int] = field(repr=False, default=None)
    upper_bound: Optional[int] = field(repr=False, default=None)

    def get_table_namespace(self, table: str):
        return f"{self.targets[table]}.{table}"


@dataclass
class PostgresSource:
    jdbc_url: str = field(repr=False)
    user: str = field(repr=False)
    password: str = field(repr=False)
    driver: str = field(repr=False)
    sources: dict[str, str] = field(repr=False)

    def get_table_namespace(self, table: str):
        return f"{self.sources[table]}.{table}"


@dataclass
class JobArguments:
    job_name: str
    source_configuration_path: Path
    source_configuration: PostgresSource
    sink_configuration_path: Path
    sink_configuration: PostgresSink

    @staticmethod
    def _build_parser():
        # Initialize parser
        parser = argparse.ArgumentParser(
            description="Generic job argument parser."
        )

        # Add arguments
        parser.add_argument(
            "--job_name", "-j",
            type=str,
            default="platform_to_raw_job",
            help="Name of the job."
        )
        parser.add_argument(
            "--source_configuration_path",
            type=Path,
            required=True,
            help="Path which contains source configuration."
        )
        parser.add_argument(
            "--sink_configuration_path",
            type=Path,
            required=True,
            help="Path which contains sink configuration."
        )

        return parser

    @staticmethod
    def _log_args(args: argparse.Namespace):
        # Map namespace into dictionary
        args_to_dict = {arg: value for arg, value in vars(args).items()}
        logging.info(json.dumps(args_to_dict, indent=4, default=str))

    @staticmethod
    def _generate_source_configuration(sink_config_path: Path):
        with open(sink_config_path, 'r') as f:
            source_config = {**yaml.safe_load(f)["postgres"]}
            logging.info(f"Config: {source_config}")

        return PostgresSource(**source_config)

    @staticmethod
    def _generate_sink_configuration(sink_config_path: Path):
        with open(sink_config_path, 'r') as f:
            sink_config = {**yaml.safe_load(f)["postgres"]}

        return PostgresSink(**sink_config)

    @classmethod
    def from_args(cls, args: Optional[list[str]] = None) -> "JobArguments":
        """
        Parses CLI arguments and returns an instance of PGArguments.
        Useful for decoupling argument parsing from instantiation.
        """
        parser = cls._build_parser()
        parsed = parser.parse_args(args)

        logging.info("Parsed arguments:")
        logging.info(cls._log_args(parsed))

        logging.info("Getting source configuration")
        source_configuration = cls._generate_source_configuration(parsed.source_configuration_path)

        logging.info("Getting sink configuration")
        sink_configuration = cls._generate_sink_configuration(parsed.sink_configuration_path)

        return cls(job_name=parsed.job_name,
                   source_configuration_path=parsed.source_configuration_path,
                   source_configuration=source_configuration,
                   sink_configuration_path=parsed.sink_configuration_path,
                   sink_configuration=sink_configuration)
