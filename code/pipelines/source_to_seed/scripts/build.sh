#!/bin/bash

# Exit on any error
set -e

bash code/common/bash/execute_python.sh \
    --script "code/pipelines/source_to_seed/source_to_seed_entrypoint.py" \
    --common "code/common" \
    --source_data_path="data/" \
    --target_path="dbt/e_commerce_brazil/seeds"
