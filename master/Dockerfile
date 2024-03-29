# Creates hadoop master container
 
FROM hiropppe/scibase:0.0.1
 
# workingaround. hadoop log has empty user part when bootstrapping
ENV USER root

# hadoop
RUN curl -s http://ftp.kddilabs.jp/infosystems/apache/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz | tar -xz -C /usr/local/ \
 && cd /usr/local \
 && ln -s ./hadoop-2.6.0 hadoop \
 && mkdir -p /var/hadoop/dfs/name
 
# environment variables 
ENV HADOOP_PREFIX=/usr/local/hadoop
 
ENV HADOOP_COMMON_HOME=$HADOOP_PREFIX \
    HADOOP_HDFS_HOME=$HADOOP_PREFIX \
    HADOOP_MAPRED_HOME=$HADOOP_PREFIX \
    HADOOP_YARN_HOME=$HADOOP_PREFIX \
    HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop \
    YARN_CONF_DIR=$HADOOP_PREFIX/etc/hadoop
 
ENV PATH=$PATH:$HADOOP_PREFIX/sbin:$HADOOP_PREFIX/bin

RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/java/default\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
 
COPY core-site.xml.template $HADOOP_PREFIX/etc/hadoop/
COPY hdfs-site.xml.template $HADOOP_PREFIX/etc/hadoop/
COPY yarn-site.xml.template $HADOOP_PREFIX/etc/hadoop/
COPY mapred-site.xml $HADOOP_PREFIX/etc/hadoop/
 
RUN sed s/NAMENODE/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml \
 && sed s/RESOUCEMANAGER/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/yarn-site.xml.template > /usr/local/hadoop/etc/hadoop/yarn-site.xml \
 && sed s/NAMENODE/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/hdfs-site.xml.template > /usr/local/hadoop/etc/hadoop/hdfs-site.xml

# run with formated name volume
# RUN $HADOOP_PREFIX/bin/hdfs namenode -format
 
# download hadoop native support
RUN rm /usr/local/hadoop/lib/native/* \
 && curl -Ls http://dl.bintray.com/sequenceiq/sequenceiq-bin/hadoop-native-64-2.6.0.tar | tar -x -C /usr/local/hadoop/lib/native/
 
# workingaround docker.io build error
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh \
 && chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh \
 && ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
 
# run with formated name volume
#RUN mkdir $HADOOP_PREFIX/logs \
# && $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh \
# && $HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode \
# && $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /user/root \
# && $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /user/spark
 
RUN echo '# Hadoop' >> ~/.bash_profile \
 && echo "export HADOOP_PREFIX=$HADOOP_PREFIX" >> ~/.bash_profile \
 && echo 'export PATH=$PATH:$HADOOP_PREFIX/bin:$HADOOP_PREFIX/sbin' >> ~/.bash_profile \
 && echo 'export HADOOP_COMMON_HOME=$HADOOP_PREFIX' >> ~/.bash_profile \
 && echo 'export HADOOP_HDFS_HOME=$HADOOP_PREFIX' >> ~/.bash_profile \
 && echo 'export HADOOP_MAPRED_HOME=$HADOOP_PREFIX' >> ~/.bash_profile \
 && echo 'export HADOOP_YARN_HOME=$HADOOP_PREFIX' >> ~/.bash_profile \
 && echo 'export HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop' >> ~/.bash_profile \
 && echo 'export YARN_CONF_DIR=$HADOOP_PREFIX/etc/hadoop' >> ~/.bash_profile

COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh && chmod 700 /etc/bootstrap.sh
ENV BOOTSTRAP /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh", "-d"]
 
# ssh
EXPOSE 2122
# namenode
EXPOSE 9000 50070
# secondary namenode
EXPOSE 50090
# yarn resource manager
EXPOSE 8030 8031 8032 8033 8088
