# Creates hadoop 2.6.0 slave container
#
# Based on sequenceiq/hadoop-docker:2.6.0
 
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
    make \
    git \
    zlib-devel \
    bzip2-devel \
    readline-devel \
    sqlite-devel \
    openssl-devel
 
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
 
# hadoop
RUN curl -s http://ftp.kddilabs.jp/infosystems/apache/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz | tar -xz -C /usr/local/ \
 && cd /usr/local \
 && ln -s ./hadoop-2.6.0 hadoop
 
ENV JAVA_HOME=/usr/java/default \
    HADOOP_PREFIX=/usr/local/hadoop
 
ENV HADOOP_COMMON_HOME=$HADOOP_PREFIX \
    HADOOP_HDFS_HOME=$HADOOP_PREFIX \
    HADOOP_MAPRED_HOME=$HADOOP_PREFIX \
    HADOOP_YARN_HOME=$HADOOP_PREFIX \
    HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop \
    YARN_CONF_DIR=$HADOOP_PREFIX/etc/hadoop
 
#ENV PYENV_ROOT=/root/.pyenv

ENV PATH=$PATH:$JAVA_HOME/bin:$HADOOP_PREFIX/sbin:$HADOOP_PREFIX/bin
#ENV PATH=$PATH:$JAVA_HOME/bin:$HADOOP_PREFIX/sbin:$HADOOP_PREFIX/bin:$PYENV_ROOT/bin

RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/java/default\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
 
COPY core-site.xml.template $HADOOP_PREFIX/etc/hadoop/
COPY yarn-site.xml.template $HADOOP_PREFIX/etc/hadoop/
COPY hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/
COPY mapred-site.xml $HADOOP_PREFIX/etc/hadoop/
 
# download hadoop native support
RUN rm /usr/local/hadoop/lib/native/* \
 && curl -Ls http://dl.bintray.com/sequenceiq/sequenceiq-bin/hadoop-native-64-2.6.0.tar | tar -x -C /usr/local/hadoop/lib/native/
 
# workingaround docker.io build error
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh \
 && chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh \
 && ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
 
RUN echo '# JDK' >> ~/.bash_profile \
 && echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bash_profile \
 && echo 'export PATH="$PATH:$JAVA_HOME/bin"' >> ~/.bash_profile \
 && echo '' >> ~/.bash_profile
 
RUN echo '# Hadoop' >> ~/.bash_profile \
 && echo "export HADOOP_PREFIX=$HADOOP_PREFIX" >> ~/.bash_profile \
 && echo 'export PATH=$PATH:$HADOOP_PREFIX/bin:$HADOOP_PREFIX/sbin' >> ~/.bash_profile \
 && echo 'export HADOOP_COMMON_HOME=$HADOOP_PREFIX' >> ~/.bash_profile \
 && echo 'export HADOOP_HDFS_HOME=$HADOOP_PREFIX' >> ~/.bash_profile \
 && echo 'export HADOOP_MAPRED_HOME=$HADOOP_PREFIX' >> ~/.bash_profile \
 && echo 'export HADOOP_YARN_HOME=$HADOOP_PREFIX' >> ~/.bash_profile \
 && echo 'export HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop' >> ~/.bash_profile \
 && echo 'export YARN_CONF_DIR=$HADOOP_PREFIX/etc/hadoop' >> ~/.bash_profile
 
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
 && pip install nose

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
EXPOSE 2122
# datanode
EXPOSE 50010 50020 50075
# yarn node manager
EXPOSE 8040 8042 45069
# yarn app master
EXPOSE 13562 50030-50040
