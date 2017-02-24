#!/bin/bash

set -e

cd ..
docker build -t test-ttrss . 
cd $OLDPWD

function finish {
	echo -n "cleanup: "
	docker-compose stop
}
trap finish EXIT

docker-compose up -d db
sleep 2
docker-compose up -d ttrss

#docker-compose logs ttrss
sleep 1

line=$(docker-compose exec ttrss curl -v http://localhost/ | grep "^< HTTP" | tr -d '\n' | tr -d '\r' )

if [ "$line" == "< HTTP/1.1 200 OK" ]; then 
	echo "TEST: SUCCESS"
else
	echo "TEST: failed => $line"
	exit 1
fi
