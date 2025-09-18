# ossec-wazuh-manager-zabbix
Zabbix Templates and scripts to monitor OSSEC or Wazuh Manager Intrusion Detection

Just getting started with this template.  Import the yaml template into zabbix (xml is deprecated).  The userparameters and scripts should be installed on your ossec system with zabbix-agent installed.  They go in /etc/zabbix/scripts and /etc/zabbix/zabbix_agentd.d

So far the template has a discovery routine that should populate the host with a list of agents and notify on disconnect.  We do also have a simple up or down trigger on the Manager.  If port 1514 tcp is not being listened on the server it will trigger a disaster alert.

New scripts have been added to pull the # of Critical/High,Medium and Low alerts over the last 24 hours as well as a calculated field to track the % change over 1, 12 and 24 hours.  Triggers are setup for the # of alerts as well as large percentage changes (20% in an hour, 50% in 12 hours, 100% or more in 24 hours.)

Triggers/clearing needs to be tested further.  Threshholds of course can be adjusted as you like.

Config should consist of placing the required files on the OSSEC/Wazuh Manager(Server) and importing the template into the Zabbix server (and apply it to your OSSEC/Wazuh host).  You need to make sure that the scripts are owned by the zabbix user and are executable.  I have also done something that is not the best - a couple of the user parameters pull the script with a sudo.  So you will need to add zabbix to sudoers.  (Less than ideal - but you could give zabbix priviliges for JUST the couple tools used... /var/ossec/bin/agent_control, netstat)

The template should create a value mapping with the following info:

Name: OSSEC-Wazuh Agent Status

Active = 0

Disconnected = 1

Never connected = 2
Tracking of connected/disconnected agents seems to work ok, but I've only had the template reimplemented for a day to test.




