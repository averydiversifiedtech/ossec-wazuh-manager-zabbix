#!/bin/bash

process=`netstat -lanpt | grep 0.0.0.0:1514 | grep tcp | grep wazuh`
if [ $? == 0 ]
then
echo OSSEC/Wazuh Listening
else
echo Not Listening
fi
