#!/bin/bash

# Exit on any error
set -e

JOB_NAME=source_to_seed

bash code/common/bash/execute_python.sh \
    --script "code/pipelines/${JOB_NAME}/${JOB_NAME}_entrypoint.py" \
    --common "code/common" \
    --source_data_path="data/input" \
    --sink_configuration_path="code/pipelines/${JOB_NAME}/configuration/sink/sink.yaml"