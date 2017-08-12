# Description #

API component of CNM

### STEPS ###

Clone repo
```
$ git clone https://bitbucket.org/s30labs/api.git
```
Build image
```
$ docker build -t s30/cnm/api . --no-cache
```
Launch container
```
$ docker run --rm --name api -ti -p 80:80 s30/cnm/api /bin/bash
```

### Who do I talk to? ###

* Sergio Sánchez Vega (ssanchez@s30labs.com)
* Fernando Marín Lario (fmarin@s30labs.com)
