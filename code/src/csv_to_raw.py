import re
import csv
import logging
from typing import Iterable

import yaml
from pathlib import Path

import common_utilities.common_utilities as utilities


def csv_to_properties_yaml(csv_files: Iterable[Path],
                           target_path: str) -> None:
    models: list[dict] = []
    pattern = re.compile(r"(?<=olist_).\w+(?=_dataset)")

    for csv_file in csv_files:
        model: dict = {
            "name": next(pattern.finditer(csv_file.stem), None).group(),
            "description": ""
        }

        with open(csv_file, "r", newline="", encoding="utf-8") as f:
            reader = csv.reader(f)
            # Get the first row
            headers = next(reader)

            columns = []
            for header in headers:
                column = {
                    "name": header,
                    "description": ""
                }
                columns.append(column)

            model["columns"] = columns

        # Append model
        models.append(model)

    # Write YAML output
    with open(target_path, "w", encoding="utf-8") as f:
        yaml_data = {"models": models}
        f.write(
            yaml.dump(yaml_data, sort_keys=False, default_flow_style=False)
        )


def main():
    # Define input parameters
    data_path = Path(r"./data")
    target_path = r"./dbt/e_commerce_brazil/models/raw/properties.yml"
    csv_files = tuple(data_path.glob("olist_*_dataset.csv"))

    logging.info(f"Starting process of converting CSVs into property YAML.")
    csv_to_properties_yaml(csv_files=csv_files, target_path=target_path)


if __name__ == "__main__":
    utilities.setup_logging()
    main()
