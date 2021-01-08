#!/bin/bash
#This script looks for and lists all the services already installed and running on Tomcat through a list of hosts.
# Script:           Tomcat Scanner
# Author:           Robson Messias
# Created on:       30/12/2019

declare -a List

user=nagios
pass=nagios

count=$(cat exa_hosts.txt | wc -l)

a=1
while [[ $a -le $count ]]; do
    PreName=$(cat exa_hosts.txt | sed -n "$a"'p')
    ipline=$(ping -c 1 $PreName | grep "from" | awk '{print $5}' | cut -d: -f1 | wc -m)
    ipline2=$(($ipline - 2))
    iphost=$(ping -c 1 $PreName | grep "from" | awk '{print $5}' | cut -d: -f1 | cut -c 2-$ipline2)
    List[$a]=$iphost
    echo "${List[$a]}"
    ((a++))
done

b=1
while [[ $b -le $count ]]; do
    ipaddr=${List[$b]}
    servername=$(cat exa_hosts.txt | sed -n "$b"'p')
    echo "Installed Servlets on $servername ($ipaddr)"
    echo ""
    output=$(curl -s -u $user:$pass http://$ipaddr:8080/manager/text/list)
    #
    # Here is where the output is checked for responses.
    # 401 -> fix the user accounts/perms           /opt/tomcat/conf/tomcat-users.xml
    # 403 -> fix the accepted incoming connections /opt/tomcat/webapps/manager/META-INF/context.xml
    #
    if grep -q 403 <<< $output
    then
        echo "[!] 403 for $servername"
    elif grep -q 401 <<< $output
    then
        echo "[!] 401 for $servername"
    else
        curl -s -u $user:$pass http://$ipaddr:8080/manager/text/list | tail -n +2 | awk -F":" '{ print $1 }'
    fi
    echo "-------------------------------------------------------------"
    ((b++))
done
