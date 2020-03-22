#!/bin/bash

docker build --rm -t cnm-core-utils:1.0 .

docker run -it --network cnm_network --rm -e CNM_DB_SERVER=cnm-datastore-mariadb -e CNM_DB_PASSWORD=onm1234 cnm-core-utils:1.0 /bin/bash

