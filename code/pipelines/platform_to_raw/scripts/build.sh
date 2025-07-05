#!/bin/bash

# Exit on any error
set -e

PIPELINES=code/pipelines
JOB_NAME=platform_to_raw

bash code/common/bash/execute_python.sh \
    --script "${PIPELINES}/${JOB_NAME}/${JOB_NAME}_entrypoint.py" \
    --common "code/common" \
    --source_configuration_path="${PIPELINES}/${JOB_NAME}/configuration/source/source.yaml" \
    --sink_configuration_path="${PIPELINES}/${JOB_NAME}/configuration/sink/sink.yaml"