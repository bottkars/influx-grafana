FROM ubuntu:16.04
MAINTAINER Karsten Bott <Karsten.Bott@labbuildr.com>
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get update && \
    apt-get install -y wget apt-utils apt-transport-https curl sudo vim supervisor openssh-server &&\
    apt-get clean 
RUN mkdir -p /var/run/sshd /var/log/supervisor
    
RUN curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add - &&\
    source /etc/lsb-release &&\
    echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

RUN apt-get update &&\
    apt-get install influxdb
COPY influxdb.conf /etc/influxdb/
RUN chmod 755 /etc/influxdb/influxdb.conf


EXPOSE 8086
EXPOSE 8083
EXPOSE 22
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 755 /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]


