#!/bin/bash

CNM_LOCAL_IP=`docker inspect -f "{{ .NetworkSettings.Networks.cnm_network.IPAddress }}" cnm-datastore-mariadb`
echo $CNM_LOCAL_IP
#-e CNM_LOCAL_IP=172.18.0.2


docker build --rm -t cnm-db-utils:1.0 .

docker run -it --network cnm_network --rm -e CNM_LOCAL_IP=$CNM_LOCAL_IP -e CNM_DB_SERVER=cnm-datastore-mariadb -e CNM_DB_PASSWORD=onm1234 cnm-db-utils:1.0 /bin/bash

#docker run -it --network cnm_network --rm -e CNM_LOCAL_IP=$CNM_LOCAL_IP -e CNM_DB_SERVER=cnm-datastore-mariadb -e CNM_DB_PASSWORD=onm1234 cnm-db-utils:1.0 php db-manage.php

