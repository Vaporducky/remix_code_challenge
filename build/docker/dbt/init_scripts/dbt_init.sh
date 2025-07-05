#!/usr/bin/env bash
set -e

# The UID & GID that dbt runs as in the base image
TARGET_UID=1000
TARGET_GID=1000

echo "Fixing ownership of /usr/app to ${TARGET_UID}:${TARGET_GID}"
chown -R ${TARGET_UID}:${TARGET_GID} /usr/app

# Keep container alive
exec tail -f /dev/null