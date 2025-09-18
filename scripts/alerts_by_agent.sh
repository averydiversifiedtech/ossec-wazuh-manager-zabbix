#!/bin/bash

# ==============================================================================
# SCRIPT CONFIGURATION
# ==============================================================================
# Replace with the actual IP address or hostname of your Wazuh Indexer
WAZUH_INDEXER_IP="localhost"
WAZUH_INDEXER_PORT="9200"

# Replace with your Wazuh Indexer API credentials
USERNAME="admin"
PASSWORD="SECRETPASSWORD"

# ==============================================================================
# SCRIPT LOGIC
# ==============================================================================

# Check for the required hostname and severity arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <hostname> <severity>" >&2
    echo "Example: $0 my-web-server Critical" >&2
    echo "Valid severities: Critical, High, Medium, Low" >&2
    exit 1
fi

HOST_NAME="$1"
SEVERITY="$2"

# Check for dependencies
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install it to use this script." >&2
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it to use this script." >&2
    exit 1
fi

# Determine the rule level query based on severity
case "$SEVERITY" in
    Critical)
        LEVEL_QUERY='{ "range": { "rule.level": { "gte": 15 } } }'
        ;;
    High)
        LEVEL_QUERY='{ "range": { "rule.level": { "gte": 12, "lt": 15 } } }'
        ;;
    Medium)
        LEVEL_QUERY='{ "range": { "rule.level": { "gte": 5, "lt": 12 } } }'
        ;;
    Low)
        LEVEL_QUERY='{ "range": { "rule.level": { "gte": 1, "lt": 5 } } }'
        ;;
    *)
        echo "Error: Invalid severity. Valid severities are: Critical, High, Medium, Low" >&2
        exit 1
        ;;
esac

# Construct the JSON query body for the Indexer API
# This JSON queries for alerts from the specified host, severity, and time range.
JSON_QUERY=$(cat <<EOF
{
  "query": {
    "bool": {
      "must": [
        { "term": { "agent.name": "${HOST_NAME}" } },
        ${LEVEL_QUERY},
        { "range": { "timestamp": { "gte": "now-24h/h" } } }
      ]
    }
  },
  "size": 0
}
EOF
)

# Pull alerts from the Indexer API
echo "Fetching ${SEVERITY} alerts count for host: ${HOST_NAME} from the last 24 hours..." >&2
ALERTS_RESPONSE=$(curl -s -X POST "https://${WAZUH_INDEXER_IP}:${WAZUH_INDEXER_PORT}/wazuh-alerts-*/_search" \
    -u "${USERNAME}:${PASSWORD}" \
    -H "Content-Type: application/json" \
    --data-raw "${JSON_QUERY}" -k)

# Check for API errors
API_ERROR=$(echo "${ALERTS_RESPONSE}" | jq -r '.error.reason')
if [ "${API_ERROR}" != "null" ] && [ "${API_ERROR}" != "" ]; then
    echo "Error from API: ${API_ERROR}" >&2
    exit 1
fi

# Extract the total count of alerts
ALERTS_COUNT=$(echo "${ALERTS_RESPONSE}" | jq -r '.hits.total.value')

if [ -z "${ALERTS_COUNT}" ] || [ "${ALERTS_COUNT}" == "null" ]; then
    echo "0"
    exit 1
else
    echo "${ALERTS_COUNT}"
fi

exit 0
