#!/bin/bash

USER=root

rm /tmp/*.pid

service sshd start

sed s/NAMENODE/$MASTER_HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
sed s/RESOURCEMANAGER/$MASTER_HOSTNAME/ /usr/local/hadoop/etc/hadoop/yarn-site.xml.template > /usr/local/hadoop/etc/hadoop/yarn-site.xml

#pyenv global 2.7.10

#eval "$(pyenv init -)"

if [[ $1 == "-d" ]]; then
  tail -f /dev/null
fi
 
if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
