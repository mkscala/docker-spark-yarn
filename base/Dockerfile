FROM sequenceiq/pam:centos-6.5

USER root

# install dev tools
RUN yum install -y \
    vim \
    wget \
    curl \
    which \
    tar \
    tree \
    sudo \
    openssh-server \
    openssh-clients \
    rsync \
    gcc \
    gcc-c++ \
    gcc-gfortran \
    make \
    git \
    svn \
    zlib-devel \
    bzip2-devel \
    readline-devel \
    sqlite-devel \
    openssl-devel \
    libpng-devel \
    freetype-devel

# update libselinux. see https://github.com/sequenceiq/hadoop-docker/issues/14
RUN yum update -y libselinux

# install lapack, atlas
ENV ATLAS_LIB=/usr/local/atlas-3.10.2 

RUN curl -o /tmp/lapack-3.5.0.tgz http://www.netlib.org/lapack/lapack-3.5.0.tgz \
 && wget http://downloads.sourceforge.net/project/math-atlas/Stable/3.10.2/atlas3.10.2.tar.bz2 \
 && tar xjf atlas3.10.2.tar.bz2 \
 && mkdir ATLAS/atlas_make \
 && cd ATLAS/atlas_make \
 && ../configure -Fa alg -fPIC --with-netlib-lapack-tarfile=/tmp/lapack-3.5.0.tgz \
 && make \
 && mkdir $ATLAS_LIB \
 && cp lib/*.a $ATLAS_LIB

ENV BLAS=$ATLAS_LIB/libcblas.a \
    LAPACK=$ATLAS_LIB/liblapack.a \
    ATLAS=$ATLAS_LIB/libatlas.a

RUN echo '# ATLAS' >> ~/.bash_profile \
 && echo 'BLAS=$BLAS' >> ~/.bash_profile \
 && echo 'LAPACK=$LAPACK' >> ~/.bash_profile \
 && echo 'ATLAS=$ATLAS' >> ~/.bash_profile \
 && echo '' >> ~/.bash_profile

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

ENV JAVA_HOME=/usr/java/default 

ENV PATH=$PATH:$JAVA_HOME/bin

RUN echo '# JDK' >> ~/.bash_profile \
 && echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bash_profile \
 && echo 'export PATH="$PATH:$JAVA_HOME/bin"' >> ~/.bash_profile \
 && echo '' >> ~/.bash_profile

# MeCab
RUN curl -s https://mecab.googlecode.com/files/mecab-0.996.tar.gz | tar -xz -C . \
 && cd mecab-0.996 \
 && ./configure \
 && make \
 && make check \
 && make install

RUN curl -s https://mecab.googlecode.com/files/mecab-ipadic-2.7.0-20070801.tar.gz | tar -xz -C . \
 && cd ../mecab-ipadic-2.7.0-20070801 \
 && ./configure --with-charset=utf8 \
 && make \
 && make install
 
# system python
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

RUN curl -kL https://bootstrap.pypa.io/get-pip.py | python

RUN pip install numpy==1.8.2 \
 && pip install scipy==0.14.1 \
 && pip install nose==1.3.7 \
 && pip install pyzmq==14.7 \
 && pip install jinja2==2.7.3 \
 && pip install tornado==4.2 \
 && pip install jsonschema==2.5.1 \
 && pip install ipython==3.2.0 \
 && pip install matplotlib==1.4.3 \
 && pip install pandas==0.16.2 \
 && pip install scikit-learn==0.16.1 \
 && pip install mecab-python==0.996 \
 && pip install sparkit-learn==0.2.5

