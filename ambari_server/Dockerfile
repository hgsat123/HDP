FROM ubuntu:14.04
MAINTAINER Satish Hegde <satish.hegde@wipro.com>

# Set Global variables
ENV AMBARI_HOME /opt/ambari
ENV AMBARI_VERSION 2.6.0.0

# Install Basics
RUN export DEBIAN_FRONTEND=noninteractive 
RUN apt-get update \
&& apt-get -y install wget software-properties-common python-software-properties sudo ntp
RUN  apt-get -y install supervisor

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

RUN mkdir /etc/supervisor.d/
RUN echo -e "[program:sshd]\ncommand=/sbin/service sshd start" >> /etc/supervisord.conf
RUN echo -e "[program:ntpd]\ncommand=/sbin/service ntpd start" >> /etc/supervisord.conf

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN mkdir -p "$AMBARI_HOME"
WORKDIR $AMBARI_HOME

# passwordless using openssl.  This can be replaced with actual .pem files
RUN export DEBIAN_FRONTEND=noninteractive \
  && echo -e 'y\n'|ssh-keygen -q -t rsa -N "" -f /root/.ssh/id_rsa \
  && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

RUN export DEBIAN_FRONTEND=noninteractive \
  && wget -nv http://public-repo-1.hortonworks.com/ambari/ubuntu14/2.x/updates/${AMBARI_VERSION}/ambari.list -O /etc/apt/sources.list.d/ambari.list 
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
RUN apt-get update

RUN apt-get -y install ambari-server
#Disable SELinux
RUN echo SELINUX=disabled >> /etc/selinux/config

RUN apt-get clean 

EXPOSE 22 8080 8081 8082 8083 8084 8085 8086 8087 8088

## Copy & Install kerberos
ADD install_Kerberos.sh /root
RUN chmod +x /root/install_Kerberos.sh
ADD start.sh /root/start.sh
RUN chmod +x /root/start.sh

# Run Ambari server setup
RUN ambari-server setup -s --verbose --java-home $JAVA_HOME

#CMD ambari-server start
CMD /usr/bin/supervisord -n
CMD /root/start.sh
