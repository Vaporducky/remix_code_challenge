import argparse
import logging
import json
from pathlib import Path
from dataclasses import dataclass
from typing import Optional


@dataclass
class JobArguments:
    job_name: str
    source_data_path: Path
    target_path: Path

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
            default="source_to_seed_job",
            help="Name of the job."
        )
        parser.add_argument(
            "--source_data_path",
            type=Path,
            required=True,
            help="Path which contains source data as CSVs."
        )
        parser.add_argument(
            "--target_path",
            type=Path,
            required=True,
            help="Target path where processed CSVs will be written."
        )

        return parser

    @staticmethod
    def _log_args(args: argparse.Namespace):
        # Map namespace into dictionary
        args_to_dict = {arg: value for arg, value in vars(args).items()}
        logging.info(json.dumps(args_to_dict, indent=4, default=str))

    @classmethod
    def from_args(cls, args: Optional[list[str]] = None) -> "JobArguments":
        """
        Parses CLI arguments and returns an instance of PGArguments.
        Useful for decoupling argument parsing from instantiation.
        """
        parser = cls._build_parser()
        parsed = parser.parse_args(args)

        logging.info(f"Parsed arguments:")
        logging.info(cls._log_args(parsed))

        return cls(job_name=parsed.job_name,
                   source_data_path=parsed.source_data_path,
                   target_path=parsed.target_path)
