#!/bin/bash

/var/ossec/bin/agent_control -l | grep "$1" | sed 's/^.*, //' | sed 's/\/Local//'
