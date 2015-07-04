# Creates hadoop 2.7.0 master container
#
# Based on sequenceiq/hadoop-docker:2.7.0

FROM sequenceiq/pam:centos-6.5

MAINTAINER hiropppe

USER root

# workingaround. hadoop log has empty user part when bootstrapping
ENV USER root

# install dev tools
RUN yum install -y \
    curl \
    which \
    tar \
    sudo \
    openssh-server \
    openssh-clients \
    rsync \
    gcc \
    gcc-c++ \
    make \
    git \
    zlib-devel \
    bzip2-devel \
    readline-devel \
    sqlite-devel \
    openssl-devel \
    libpng-devel \
    freetype-devel \
    vim

# update libselinux. see https://github.com/sequenceiq/hadoop-docker/issues/14
RUN yum update -y libselinux

# JST
RUN cp /usr/share/zoneinfo/Japan /etc/localtime \
 && echo "ZONE=\"Asia/Tokyo\"" > /etc/sysconfig/clock

# allow empty password root ssh
RUN echo "Port 2122" >> /etc/ssh/sshd_config \
 && sed -ri 's/^#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config \
 && sed -ri 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -ri 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config \
 && passwd -d root

# java
RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie' \
 && rpm -i jdk-7u79-linux-x64.rpm \
 && rm jdk-7u79-linux-x64.rpm

# spark
RUN curl -s http://ftp.tsukuba.wide.ad.jp/software/apache/spark/spark-1.3.1/spark-1.3.1-bin-hadoop2.6.tgz | tar -xz -C /usr/local/ \
 && cd /usr/local \
 && ln -s spark-1.3.1-bin-hadoop2.6 spark

ENV JAVA_HOME=/usr/java/default \
    HADOOP_PREFIX=/usr/local/hadoop \
    SPARK_HOME=/usr/local/spark

ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop

#ENV PYENV_ROOT=/root/.pyenv

ENV PATH=$PATH:$JAVA_HOME/bin:$SPARK_HOME/bin
#ENV PATH=$PATH:$JAVA_HOME/bin:$SPARK_HOME/bin:$PYENV_ROOT/bin

RUN mkdir -p YARN_CONF_DIR

COPY core-site.xml.template $YARN_CONF_DIR/
COPY yarn-site.xml.template $YARN_CONF_DIR/
COPY spark-defaults.conf $SPARK_HOME/conf/

RUN echo '# JDK' >> ~/.bash_profile \
 && echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bash_profile \
 && echo 'export PATH="$PATH:$JAVA_HOME/bin"' >> ~/.bash_profile \
 && echo '' >> ~/.bash_profile
 
RUN echo '# Spark' >> ~/.bash_profile \
 && echo "export SPARK_HOME=$SPARK_HOME" >> ~/.bash_profile \
 && echo "export YARN_CONF_DIR=$YARN_CONF_DIR" >> ~/.bash_profile \
 && echo 'export PATH=$PATH:$SPARK_HOME/bin' >> ~/.bash_profile \
 && echo '' >> ~/.bash_profile

# setup python env
RUN curl -s https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tgz | tar -xz -C . \
 && cd Python-2.7.10/ \
 && ./configure --with-threads --enable-shared --prefix=/usr/local \
 && make \
 && make altinstall

RUN ln -s /usr/local/lib/libpython2.7.so.1.0 /lib64/ \
 && echo "/usr/local/lib" >> /etc/ld.so.conf \
 && ldconfig \
 && ln -s /usr/local/bin/python2.7 /usr/local/bin/python \
 && ln -s /usr/local/bin/python2.7 /usr/local/bin/python2

RUN curl -kL https://bootstrap.pypa.io/get-pip.py | python \
 && pip install numpy==1.9.2 \
 && pip install nose \
 && pip install pyzmq \
 && pip install jinja2 \
 && pip install tornado \
 && pip install jsonschema \
 && pip install ipython \
 && pip install matplotlib

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

#RUN git clone git://github.com/yyuu/pyenv.git ~/.pyenv \
# && git clone git://github.com/yyuu/pyenv-pip-rehash.git ~/.pyenv/plugins/pyenv-pip-rehash

#RUN echo '# Python' >> ~/.bash_profile \
# && echo "export PYENV_ROOT=$PYENV_ROOT" >> ~/.bash_profile \
# && echo 'export PATH=$PATH:$PYENV_ROOT/bin' >> ~/.bash_profile \
# && echo 'eval "$(pyenv init -)"' >> ~/.bash_profile

#RUN eval "$(pyenv init -)" \
# && pyenv install 2.7.10 \
# && pyenv rehash \
# && pyenv global 2.7.10 \
# && pip install numpy==1.9.2 \
# && pip install nose

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
