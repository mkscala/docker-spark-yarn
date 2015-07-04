# Docker Image for PySpark on YARN
cluster on single docker host.

* Java 1.7
* Hadoop 2.6.0
* Spark 1.3.1
* Python 2.7.10
* Numpy 1.9.2
* IPython 3.2.0
* Matplotlib 1.4.3

# Docker host preparations
install docker-compose  
<https://docs.docker.com/compose/install/>

setup dnsmasq for linking containers  
<https://blog.amartynov.ru/archives/dnsmasq-docker-service-discovery/>

# Build images
```
docker build -t hiropppe/hadoop-master:2.6.0 ./master/
docker build -t hiropppe/hadoop-slave:2.6.0 ./slave/
docker build -t hiropppe/spark-yarn:1.3.1_hadoop2.6 ./spark/
```

# Start containers
```
# containers up
docker-compose up -d
# update DNS
./update_docker_hosts.sh
```

<http://docker-host-ip:50070/>  
<http://docker-host-ip:8088/>  

# Start notebook
```
# ssh spark container 
ssh -p 2122 root@$(docker inspect --format="{{.NetworkSettings.IPAddress}}" <SPARK_CONTAINER_ID>)
# start ipython notebook
ipython notebook --profile=pyspark
```

notebook  
<http://docker-host-ip:9999/>

# Stop containers
```
docker-compose stop
```
