set -euxo pipefail

LANDING_DIR=/opt/airflow/data/input
OUTPUT_ZIP=${LANDING_DIR}/brazilian_ecommerce.zip

echo "Creating landing directory: ${LANDING_DIR}"
[[ -d $LANDING_DIR ]] || mkdir -p "$LANDING_DIR"

echo "Downloading dataset from Kaggle."
curl --fail \
     --connect-timeout 10 \
     --max-time 60 \
     -L -o "$OUTPUT_ZIP" \
     "https://www.kaggle.com/api/v1/datasets/download/olistbr/brazilian-ecommerce"

echo "Download existence check."
if [ ! -s "$OUTPUT_ZIP" ]; then
  echo "ERROR: ${OUTPUT_ZIP} is missing or empty" >&2
  exit 1
fi

echo "Downloaded ${OUTPUT_ZIP}"