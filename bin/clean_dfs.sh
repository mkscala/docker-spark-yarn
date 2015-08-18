#!/usr/bin/env bash

exec_on_container ()
{
  ssh -oStrictHostKeyChecking=no -p 2122 root@$(docker inspect --format="{{.NetworkSettings.IPAddress}}" $(docker ps | grep $1 | awk '{print$1}')) $2
}

BIN="${BASH_SOURCE-$0}"
BIN="$(dirname "${BIN}")"
BASEDIR="$(cd "${BIN}/.."; pwd)"

# stop datanode
exec_on_container "slave1" "cd /usr/local/hadoop && ./sbin/hadoop-daemon.sh stop datanode"
exec_on_container "slave2" "cd /usr/local/hadoop && ./sbin/hadoop-daemon.sh stop datanode"
exec_on_container "master_1" "cd /usr/local/hadoop && ./sbin/hadoop-daemon.sh stop namenode"

cd $BASEDIR
rm -rf volumes/hadoop/dfs/name/*
rm -rf volumes/hadoop/dfs/data/slave1/*
rm -rf volumes/hadoop/dfs/data/slave2/*

# init namenode
exec_on_container "master_1" "cd /usr/local/hadoop && ./bin/hdfs namenode -format && ./sbin/hadoop-daemon.sh start namenode"

# start datanode
exec_on_container "slave1_1" "cd /usr/local/hadoop && ./sbin/hadoop-daemon.sh start datanode"
exec_on_container "slave2_1" "cd /usr/local/hadoop && ./sbin/hadoop-daemon.sh start datanode"

# init dfs
exec_on_container "spark_1" "export JAVA_HOME=/usr/java/default && cd /usr/local/hadoop && ./bin/hdfs dfs -mkdir -p /user/root && ./bin/hdfs dfs -mkdir -p /user/spark && ./bin/hdfs dfs -put /usr/local/spark/lib/spark-assembly-1.4.1-hadoop2.6.0.jar /user/spark"
