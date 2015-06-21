#!/bin/bash
 
USER=root
env 
rm /tmp/*.pid
 
# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

service sshd start

#MY_IP=$(ip addr show eth0 | sed -nEe 's/^[ \t]*inet[ \t]*([0-9.]+)\/.*$/\1/p')

# add master hostname entry to hosts file
#ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -p 2122 root@$MASTER_IP hostname > /tmp/master_hostname
#echo -e "$MASTER_IP\t$(cat /tmp/master_hostname)" >> /etc/hosts
 
# add slave hostname entry to master hosts file
#ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -p 2122 root@$MASTER_IP "ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -p 2122 root@$MY_IP echo '$MY_IP    $HOSTNAME' >> /etc/hosts"
 
# altering the configurations
sed s/NAMENODE/$MASTER_HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
sed s/RESOURCEMANAGER/$MASTER_HOSTNAME/ /usr/local/hadoop/etc/hadoop/yarn-site.xml.template > /usr/local/hadoop/etc/hadoop/yarn-site.xml
#sed s/NAMENODE/$(cat /tmp/master_hostname)/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
#sed s/RESOURCEMANAGER/$(cat /tmp/master_hostname)/ /usr/local/hadoop/etc/hadoop/yarn-site.xml.template > /usr/local/hadoop/etc/hadoop/yarn-site.xml
 
# start daemons
$HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
$HADOOP_PREFIX/sbin/yarn-daemon.sh start nodemanager

#pyenv global 2.7.10
 
#eval "$(pyenv init -)"

if [[ $1 == "-d" ]]; then
  tail -f /dev/null
fi
 
if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
