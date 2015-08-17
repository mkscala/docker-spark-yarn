# Creates spark-client container

FROM hiropppe/scibase:0.0.1

RUN yum install -y rubygems

# kafka
RUN curl -s http://ftp.jaist.ac.jp/pub/apache/kafka/0.8.2.1/kafka_2.10-0.8.2.1.tgz | tar -xz -C /usr/local \
 && cd /usr/local/ \
 && ln -s kafka_2.10-0.8.2.1 kafka

# td-agent
COPY install-redhat-td-agent2_nosudo.sh /tmp/

RUN chmod u+x /tmp/install-redhat-td-agent2_nosudo.sh \
 && /tmp/install-redhat-td-agent2_nosudo.sh

RUN git clone https://github.com/htgc/fluent-plugin-kafka.git \
 && cd fluent-plugin-kafka \
 && echo "search home.local" >> /etc/resolv.conf \
 && git checkout -b 0.0.15 refs/tags/v0.0.15 \
 && td-agent-gem install fluent-plugin-kafka

COPY td-agent.conf /etc/td-agent/

# hadoop
RUN curl -s http://ftp.kddilabs.jp/infosystems/apache/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz | tar -xz -C /usr/local/ \
 && cd /usr/local \
 && ln -s ./hadoop-2.6.0 hadoop

# spark
RUN curl -s http://ftp.yz.yamagata-u.ac.jp/pub/network/apache/spark/spark-1.4.1/spark-1.4.1-bin-hadoop2.6.tgz | tar -xz -C /usr/local/ \
 && cd /usr/local \
 && ln -s spark-1.4.1-bin-hadoop2.6 spark

ENV HADOOP_PREFIX=/usr/local/hadoop \
    SPARK_HOME=/usr/local/spark

ENV HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop \
    YARN_CONF_DIR=$HADOOP_PREFIX/etc/hadoop

ENV PATH=$PATH:$HADOOP_PREFIX/bin:$SPARK_HOME/bin

RUN mkdir -p YARN_CONF_DIR

COPY core-site.xml.template $YARN_CONF_DIR/
COPY yarn-site.xml.template $YARN_CONF_DIR/
COPY spark-defaults.conf $SPARK_HOME/conf/

RUN echo '# Spark' >> ~/.bash_profile \
 && echo "export SPARK_HOME=$SPARK_HOME" >> ~/.bash_profile \
 && echo "export HADOOP_CONF_DIR=$HADOOP_CONF_DIR" >> ~/.bash_profile \
 && echo "export YARN_CONF_DIR=$YARN_CONF_DIR" >> ~/.bash_profile \
 && echo "export PATH=$PATH" >> ~/.bash_profile \
 && echo '' >> ~/.bash_profile

RUN ipython profile create pyspark

RUN echo "# Configuration file for ipython-notebook." >  ~/.ipython/profile_pyspark/ipython_notebook_config.py \
 && echo "c = get_config()" >> ~/.ipython/profile_pyspark/ipython_notebook_config.py \
 && echo "c.NotebookApp.ip = '*'" >> ~/.ipython/profile_pyspark/ipython_notebook_config.py \
 && echo "c.NotebookApp.open_browser = False" >> ~/.ipython/profile_pyspark/ipython_notebook_config.py \
 && echo "c.NotebookApp.port = 9999" >> ~/.ipython/profile_pyspark/ipython_notebook_config.py

COPY 00-pyspark-setup.py /tmp/
RUN cp /tmp/00-pyspark-setup.py ~/.ipython/profile_pyspark/startup/

RUN echo "# IPython notebook" >> ~/.bash_profile \
 && echo "export PYSPARK_SUBMIT_ARGS=\"--master yarn-client\"" >> ~/.bash_profile \
 && echo '' >> ~/.bash_profile

# spark-notebook
RUN curl -s https://s3.eu-central-1.amazonaws.com/spark-notebook/tgz/spark-notebook-0.6.0-scala-2.10.4-spark-1.4.1-hadoop-2.6.0.tgz | tar xz -C /usr/local \
 && cd /usr/local \
 && ln -s spark-notebook-0.6.0-scala-2.10.4-spark-1.4.1-hadoop-2.6.0/ spark-notebook

ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh && chmod 700 /etc/bootstrap.sh
ENV BOOTSTRAP /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh", "-d"]

# ssh
EXPOSE 2222
# Spark WebUI
EXPOSE 4040 18080
# Spark IPC
EXPOSE 47691 47692 47693 47694 47695 47696
# IPython notebook
EXPOSE 9999
