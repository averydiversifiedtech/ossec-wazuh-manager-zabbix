#!/bin/bash

# Ensure a client name is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <client_name>" >&2
    exit 3
fi

# Capture the full status line
# This pattern matches either ": <name>," or ": <name> (server),"
status_line=$(/var/ossec/bin/agent_control -l | grep -E ": $1, |: $1 \(server\),")

# Check if the line is a server's status line
if [[ "$status_line" == *": $1 (server),"* ]]; then
    if [[ "$status_line" == *"Active/Local"* ]]; then
        echo 2
        exit 0
    elif [[ "$status_line" == *"Disconnected/Local"* ]]; then
        echo 1
        exit 0
    elif [[ "$status_line" == *"Never connected/Local"* ]]; then
        echo 0
        exit 0
    else
        echo -1
        exit 1
    fi
else
    # The line is an agent's status line
    status=$(echo "$status_line" | sed 's/^.*, //' | sed 's/\/Local//')
    
    if [[ "$status" == "Active" ]]; then
        echo 2
        exit 0
    elif [[ "$status" == "Disconnected" ]]; then
        echo 1
        exit 0
    elif [[ "$status" == "Never connected" ]]; then
        echo 0
        exit 0
    else
        echo -1
        exit 1
    fi
fi
