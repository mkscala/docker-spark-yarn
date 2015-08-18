#!/bin/bash

USER=root

rm /tmp/*.pid

service sshd start

sed s/NAMENODE/$MASTER_HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
sed s/RESOURCEMANAGER/$MASTER_HOSTNAME/ /usr/local/hadoop/etc/hadoop/yarn-site.xml.template > /usr/local/hadoop/etc/hadoop/yarn-site.xml

# start kafka
cd /usr/local/kafka
./bin/zookeeper-server-start.sh -daemon config/zookeeper.properties 
./bin/kafka-server-start.sh -daemon config/server.properties
./bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic spark

# start spark-notebook
# cd /usr/local/spark-notebook
# ./bin/spark-notebook -Dhttp.port=8989

# start td-agent
service td-agent start

if [[ $1 == "-d" ]]; then
  tail -f /dev/null
fi
 
if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
