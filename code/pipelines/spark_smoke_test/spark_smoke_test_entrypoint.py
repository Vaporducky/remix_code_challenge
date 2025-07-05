import sys
import logging

import common_utilities
import src.spark_smoke_test_utilities as utilities
import src.spark_smoke_test_constants as constants
from src.spark_smoke_test_job import SparkSmokeTestJob


def main():
    logging.info("Starting argument parsing.")
    args = utilities.JobArguments.from_args()
    logging.info("Argument parsing completed successfully.")

    # Instantiate job
    job = SparkSmokeTestJob(spark_config=constants.CONFIG, job_args=args)

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
