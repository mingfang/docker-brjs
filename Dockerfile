FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Runit
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y runit 
CMD /usr/sbin/runsvdir-start

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir -p /var/run/sshd && \
    echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo

#Install Oracle Java 7
RUN apt-get install -y python-software-properties && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java7-installer

#BRJS
RUN wget https://github.com/BladeRunnerJS/brjs/releases/download/v0.4/BladeRunnerJS-v0.4-0-g59c3656.zip && \
    unzip BladeRunnerJS*.zip && \
    rm BladeRunnerJS*.zip
 
#SSH service
RUN mkdir -p /etc/sv/ssh && echo "\
#!/bin/sh\n\
exec 2>&1\n\
exec /usr/sbin/sshd -D -e\
" > /etc/sv/ssh/run 
RUN mkdir -p /etc/sv/ssh/log /var/log/ssh && echo "\
#!/bin/sh\n\
exec 2>&1\n\
exec /usr/bin/svlogd -tt /var/log/ssh\
" > /etc/sv/ssh/log/run
RUN chmod +x /etc/sv/ssh/run /etc/sv/ssh/log/run && ln -s /etc/sv/ssh /etc/service/

RUN echo 'export PATH=/BladeRunnerJS/sdk:$PATH' >> /root/.bashrc
ENV HOME /root
WORKDIR /root
EXPOSE 22
