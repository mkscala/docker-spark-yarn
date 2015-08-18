#!/bin/bash
 
USER=root
env 
rm /tmp/*.pid
 
# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

service sshd start

# altering the configurations
sed s/NAMENODE/$MASTER_HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
sed s/RESOURCEMANAGER/$MASTER_HOSTNAME/ /usr/local/hadoop/etc/hadoop/yarn-site.xml.template > /usr/local/hadoop/etc/hadoop/yarn-site.xml
 
# start daemons
$HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
$HADOOP_PREFIX/sbin/yarn-daemon.sh start nodemanager

/usr/local/elasticsearch/bin/elasticsearch -d --cluster.name spark --path.data /var/elasticsearch/data  --node.name $HOSTNAME

if [[ $1 == "-d" ]]; then
  tail -f /dev/null
fi
 
if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
