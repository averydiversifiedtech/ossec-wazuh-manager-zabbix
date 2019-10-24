# ossec-wazuh-manager-zabbix
Zabbix Templates and scripts to monitor OSSEC or Wazuh Manager Intrusion Detection

Just getting started with this template.  Import the xml template into zabbix.  The userparameters and script should be installed on your ossec system with zabbix-agent installed.  They go in /etc/zabbix/scripts and /etc/zabbix/zabbix_agentd.d

So far the template has a discovery routine that is not yet scripted but as of the initial upload we do have a simple up or down trigger on the Manager.  If port 1514 udp is not being listened on the server it will trigger a disaster alert.

Next up will be getting discovery of hosts and prototypes are already in place to track status of agents (active/disconnected/never connected) and alert accordingly.

The other config item needed after placing the required files on the OSSEC/Wazuh Manager(Server) and importing the template into the Zabbix server (and apply it to your OSSEC/Wazuh host).  Create a value mapping with the following info:

Name: OSSEC-Wazuh Agent Status

Active = 0

Disconnected = 1

Never connected = 2

(Value mapping is in Administration/config and then select Value Mapping from the drop down on the right hand side of the screen (as of verison 4.0))


