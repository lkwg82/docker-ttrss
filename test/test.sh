#!/bin/bash

set -e

function finish {
	local exitCode=$?

	echo -n "cleanup: "
        docker-compose down
	
	if [ "$exitCode" == "0" ]; then
		echo "Test: SUCCESS"
	else
		echo "Test: failed"
		exit $exitCode
	fi
}
trap finish EXIT

# build image
cd ..
docker build -t test-ttrss . 
cd $OLDPWD

# start composition
docker-compose up -d db
sleep 2
docker-compose up -d ttrss

#docker-compose logs ttrss
sleep 1

cmd='docker-compose exec ttrss curl -v http://localhost:8080/'

set -x

# tests
$cmd | grep "^< HTTP/1.1 200 OK" || exit 1
$cmd | grep "^< Set-Cookie: ttrss_sid=deleted" || exit 1

set +x


