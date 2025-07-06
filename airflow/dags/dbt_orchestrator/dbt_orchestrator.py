from pathlib import Path
import logging

import pendulum
from airflow.sdk import dag, task

# Constants
LANDING_DIR = Path("/opt/airflow/data/input")
DATASET_URL = (
    "https://www.kaggle.com/api/v1/datasets/download/"
    "olistbr/brazilian-ecommerce"
)
ZIP_NAME = "brazilian_ecommerce.zip"
ZIP_PATH = LANDING_DIR / ZIP_NAME


@dag(
    schedule="@daily",
    start_date=pendulum.today(),
    catchup=False,
    default_args={
        "retries": 0,
    },
    template_searchpath="/opt/airflow/dags/dbt_orchestrator/scripts",
    tags=["dbt", "dev"],
)
def dbt_orchestrator():
    @task.bash
    def download_input_data():
        return "dataset_download.sh"

    @task()
    def unzip_dataset():
        import zipfile

        zip_path = Path(ZIP_PATH)

        try:
            if not zip_path.exists():
                raise FileNotFoundError

            with zipfile.ZipFile(zip_path.as_posix()) as archive:
                # Log dataset info
                for info in archive.infolist():
                    logging.info(f"Filename: {info.filename}")
                    logging.info(f"Modified: {pendulum.datetime(*info.date_time)}")
                    logging.info(f"Normal size: {info.file_size} bytes")
                    logging.info(f"Compressed size: {info.compress_size} bytes")
                    logging.info("-" * 20)

                # Extract all files
                archive.extractall(Path(LANDING_DIR).as_posix())

        except zipfile.BadZipfile as error:
            logging.exception(f"Bad zipfile", exc_info=error)
        except FileNotFoundError as error:
            logging.exception(f"File does not exist", exc_info=error)

    @task()
    def clean_up_zip():
        zip_path = Path(ZIP_PATH)
        if zip_path.exists():
            logging.info(f"Removing zip file `{zip_path.as_posix()}`.")
            zip_path.unlink()
            logging.info(f"Removed zip file.")
        else:
            raise FileNotFoundError(f"Zip file does not exist.`")

        return 1

    # Task dependencies
    download_task = download_input_data()
    unzip_dataset_task = unzip_dataset()
    clean_up_zip_task = clean_up_zip()

    download_task >> unzip_dataset_task >> clean_up_zip_task


dbt_orchestrator()
