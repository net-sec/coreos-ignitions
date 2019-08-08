#!/bin/bash 

docker rm -f coreos-ignitions
docker run --name coreos-ignitions -v $(pwd)/ignitions/:/usr/share/nginx/html:ro -p 80:80 -d nginx
