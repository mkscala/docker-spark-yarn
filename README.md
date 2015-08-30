# Spark Docker Image with Notebook（YARN Cluster）
cluster on single docker host.

* Java 1.7
* Hadoop 2.6.0
* Spark 1.4.1
* Python 2.7.10
* Numpy 1.8.2
* IPython 3.2.0
* Matplotlib 1.4.3

# Docker host preparations
install docker-compose  
<https://docs.docker.com/compose/install/>

setup dnsmasq for linking containers  
<https://blog.amartynov.ru/archives/dnsmasq-docker-service-discovery/>

# Build images
```
$ docker build -t hiropppe/hadoop-master:2.6.0 ./master/
$ docker build -t hiropppe/hadoop-slave:2.6.0 ./slave/
$ docker build -t hiropppe/spark-yarn:1.4.1_hadoop2.6 ./spark/
```

# Start containers
```
$ ./bin/up.sh
```
For first time you need to init(format) dfs.
```
$ ./bin/clean_dfs.sh
```
Now you can access hadoop WebUI

<http://docker_host_ip_address:50070/>  
<http://docker_host_ip_address:8088/>  

From next time you can start existing containers simply.
```
$ ./bin/start.sh
```

# Start IPython Notebook
```
# ssh spark container 
$ ssh -p 2122 root@$(docker inspect --format="{{.NetworkSettings.IPAddress}}" <SPARK_CONTAINER_ID>)
# start ipython notebook
$ ipython notebook --profile=pyspark
```
<http://docker_host_ip_address:9999/>

# Start Spark Notebook
```
$ cd /user/local/spark-notebook
$ ./bin/spark-notebook -Dhttp.port=8989
```
<http://docker_host_ip_address:8989/>

# Stop containers
```
$ ./bin/stop.sh
```
