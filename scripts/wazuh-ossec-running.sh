#!/bin/bash

process=`netstat -lanpu | grep 0.0.0.0:1514 | grep udp | grep ossec`
if [ $? == 0 ]
then
echo OSSEC/Wazuh Listening
else
echo Not Listening
fi
