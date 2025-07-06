#!/bin/bash

# Exit on any error
set -e

JOB_NAME=source_to_seed
TEST_PATH=code/pipelines/${JOB_NAME}/tests

bash code/common/bash/execute_python.sh \
    --module pytest \
    --common "code/pipelines/${JOB_NAME}" \
    -- -v ${TEST_PATH}/unit
