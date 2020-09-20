# This Docker image was built to encapsulate appcompatprocessor from Matias Bevilacqua at
# https://github.com/mbevilacqua/appcompatprocessor
#
# Since the tool is built on python2.7, and most linux based operating systems are moving away or
# have moved away from supporting python2.7, this is the easiest way to use the tool without 
# installation or requirement for backwards compatibility.

FROM ubuntu:18.04
LABEL maintainer="Corey Forman (digitalsleuth, https://github.com/digitalsleuth)"
LABEL created="19 Sep 2020"

USER root
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential git wget python-dev python-pip sudo
RUN wget -O /tmp/libregf.tar.gz https://github.com/libyal/libregf/releases/download/20200805/libregf-alpha-20200805.tar.gz
WORKDIR /tmp
RUN tar -xvf libregf.tar.gz 
WORKDIR /tmp/libregf-20200805/
RUN ./configure --enable-python && make && make install
RUN python setup.py build && python setup.py install
RUN pip install git+https://github.com/mbevilacqua/appcompatprocessor && ln -s /usr/local/lib/libregf.so.1 /usr/lib/libregf.so.1
RUN rm -rf /tmp/libregf*

RUN groupadd -r appcompat && \
    useradd -m -d /home/appcompat -g appcompat -s /bin/bash -c "AppCompat User" appcompat && \
    mkdir -p /home/appcompat && \
    chown -R appcompat:appcompat /home/appcompat && \
    usermod -a -G sudo appcompat && echo 'appcompat:appcompat' | chpasswd

USER appcompat
ENV HOME /home/appcompat
ENV USER appcompat
WORKDIR /home/appcompat

