# CNM DB php utils 
# docker build --rm -t cnm-db-utils:1.0 .
FROM debian:buster-slim

LABEL maintainer="fmarin@s30labs.com"

# git clone https://github.com/s30labs/cnm.git
# git pull

RUN  echo "deb [trusted=yes] http://software.s30labs.com/repositorio8/ stable main contrib" > /etc/apt/sources.list.d/s30labs.list \
     	&&	apt-get update && apt-get install -y --allow-unauthenticated git php5=5.6.7+dfsg-1 php-db=1.7.14-3 php5-mysql=5.6.7+dfsg-1 php-pear=5.6.7+dfsg-1 && rm -rf /var/lib/apt/lists/* \
		&& cd /opt && git clone https://github.com/s30labs/cnm.git \
		&& mkdir -p /usr/share/pear/ && cp /opt/cnm/os/debian8/roles/apache-php/files/DB.php /usr/share/pear/DB.php \	
     	&& ln -s /opt/cnm/update /update

COPY ./progress_bar /var/www/html/onm/inc/progress_bar

WORKDIR /opt/cnm/update/db

CMD /bin/bash 



