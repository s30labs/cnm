

START
cd /opt/cnm/os/docker
docker-compose -f /opt/cnm/os/docker/docker-compose-test.yml up -d

STOP
cd /opt/cnm/os/docker
docker-compose -f /opt/cnm/os/docker/docker-compose-test.yml stop


(To rebuild this image you must use `docker-compose build` or `docker-compose up --build`)
