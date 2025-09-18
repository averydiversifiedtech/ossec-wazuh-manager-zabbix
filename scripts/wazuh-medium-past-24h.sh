#!/bin/bash

# Configuration
INDEXER_HOST="https://localhost:9200"
USERNAME="admin"
PASSWORD="SECRETPASSWORD"  # Set securely (see below)

# Query for count of high and critical severity vulnerability alerts in last 24 hours
COUNT=$(curl -s -X POST "$INDEXER_HOST/wazuh-alerts-*/_count" \
  -u "$USERNAME:$PASSWORD" \
  -k \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "should": [
{
  "range": {
    "rule.level": {
      "gte": 7,
      "lte": 11
    }
  }
}
        ],
        "minimum_should_match": 1,
        "filter": [
          {
            "range": {
              "@timestamp": {
                "gte": "now-24h",
                "lte": "now"
              }
            }
          }
        ]
      }
    }
  }' | jq -r '.count')

# Output only the number
echo "$COUNT"
