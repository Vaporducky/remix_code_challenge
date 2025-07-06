#!/bin/bash

# Exit on any error
set -e

JOB_NAME=spark_smoke_test

bash code/common/bash/execute_python.sh \
    --target "code/pipelines/${JOB_NAME}/${JOB_NAME}_entrypoint.py" \
    --common "code/common"