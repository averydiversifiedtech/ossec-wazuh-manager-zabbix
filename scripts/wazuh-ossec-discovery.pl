#!/usr/bin/perl
 
$first = 1;
 
print "{\n";
print "\t\"data\":[\n\n";
 
for (`sudo /var/ossec/bin/agent_control -l | grep ID`)
{
    ($name, $status) = m/\S+ \S+ \S+ (\S+) \S+ \S+ (\S+)/;
 
    print "\t,\n" if not $first;
    $first = 0;
$name =~ s/,\s*$//;
 
    print "\t{\n";
    print "\t\t\"{#NAME}\":\"$name\"\n";
#    print "\t\t\"{#STATUS}\":\"$status\"\n";
    print "\t}\n";
}
 
print "\n\t]\n";
print "}\n";
