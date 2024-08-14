IFS=',' read -ra ACSF_SITE <<<"$ACSF_SITE_IDS"

# Define common parameters
common_params="-v -u innate-accounting:$ACSF_KEY -X POST -H 'Content-Type: application/json'"

# Define the API URL
dev_api="https://www.dev-innateacsf.acsitefactory.com/api/v1/theme/notification"
test_api="https://www.test-innateacsf.acsitefactory.com/api/v1/theme/notification"

for i in "${ACSF_SITE[@]}"; do
  # Make the curl requests
  curl "$dev_api" $common_params -d '{"scope": "site", "event": "modify", "nid": '$i'}'
  curl "$test_api" $common_params -d '{"scope": "site", "event": "modify", "nid": '$i'}'
done
