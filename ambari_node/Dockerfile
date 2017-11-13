FROM ubuntu:14.04
MAINTAINER Satish Hegde <satish.hegde@wipro.com>

# Install Basics
RUN export DEBIAN_FRONTEND=noninteractive 
RUN apt-get update \
&& apt-get -y install wget software-properties-common python-software-properties sudo ntp

#RUN apt-get install which
RUN apt-get -y install openssh-server openssh-client

# Install Oracle Java8
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# passwordless using openssl.  This can be replaced with actual .pem files
RUN export DEBIAN_FRONTEND=noninteractive \
  && echo -e 'y\n'|ssh-keygen -q -t rsa -N "" -f /root/.ssh/id_rsa \
  && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

#Disable SELinux
RUN echo SELINUX=disabled >> /etc/selinux/config
ADD start.sh /root/start.sh
RUN chmod +x /root/start.sh

RUN apt-get clean 

EXPOSE 22 8080 8081 8082 8083 8084 8085 8086 8087 8088

# update the stack & start ssh services
CMD /root/start.sh
CMD /bin/bash
