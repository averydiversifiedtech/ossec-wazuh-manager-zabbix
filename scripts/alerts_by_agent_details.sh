#!/bin/bash

# ==============================================================================
# SCRIPT CONFIGURATION
# ==============================================================================
# Replace with the actual IP address or hostname of your Wazuh Indexer
WAZUH_INDEXER_IP="127.0.0.1"
WAZUH_INDEXER_PORT="9200"

# ==============================================================================
# SCRIPT LOGIC
# ==============================================================================

# Check for the required hostname argument
if [ -z "$1" ]; then
    echo "Usage: $0 <hostname>"
    echo "Example: $0 my-web-server"
    exit 1
fi

HOST_NAME="$1"

# Check for dependencies
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install it to use this script."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it to use this script."
    exit 1
fi

# Get authentication credentials for the Indexer
read -p "Enter Wazuh Indexer username: " USERNAME
read -s -p "Enter Wazuh Indexer password: " PASSWORD
echo ""

# Construct the JSON query body for the Indexer API
# This JSON queries for alerts with a level >= 12 from the specified host
# within the last 24 hours.
JSON_QUERY=$(cat <<EOF
{
  "query": {
    "bool": {
      "must": [
        { "term": { "agent.name": "${HOST_NAME}" } },
        { "range": { "rule.level": { "gte": 12 } } },
        { "range": { "timestamp": { "gte": "now-24h/h" } } }
      ]
    }
  }
}
EOF
)

# Pull alerts from the Indexer API
echo "Fetching critical alerts for host: ${HOST_NAME} from the last 24 hours..."
ALERTS_RESPONSE=$(curl -s -X POST "https://${WAZUH_INDEXER_IP}:${WAZUH_INDEXER_PORT}/wazuh-alerts-*/_search" \
    -u "${USERNAME}:${PASSWORD}" \
    -H "Content-Type: application/json" \
    --data-raw "${JSON_QUERY}" -k)

# Check for API errors
API_ERROR=$(echo "${ALERTS_RESPONSE}" | jq -r '.error.reason')
if [ "${API_ERROR}" != "null" ] && [ "${API_ERROR}" != "" ]; then
    echo "Error from API: ${API_ERROR}"
    exit 1
fi

# Extract and format the alerts
ALERTS=$(echo "${ALERTS_RESPONSE}" | jq -r '.hits.hits[] | ._source | "\nRule ID: \(.rule.id)\nRule Description: \(.rule.description)\nAlert Timestamp: \(.timestamp)\nLog: \(.full_log)\n\n-----------------------------"')

if [ -z "${ALERTS}" ]; then
    echo "No critical alerts found for host: ${HOST_NAME} in the last 24 hours."
else
    echo "${ALERTS}"
fi

exit 0
