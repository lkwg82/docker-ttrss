#!/bin/bash

set -e

function finish {
	local exitCode=$?
	set +x

	echo -n "cleanup: "
        docker-compose down
	
	echo "-------"
	if [ "$exitCode" == "0" ]; then
		echo "Test: SUCCESS"
	else
		echo "Test: failed"
		exit $exitCode
	fi
}
trap finish EXIT

# build docker image
docker build -t test-ttrss ..

docker-compose up -d 

#docker-compose logs ttrss

cmd='docker-compose exec ttrss curl --fail -v http://localhost:8080/'

# warmups
$cmd > /dev/null || sleep 2
$cmd > /dev/null || sleep 2
$cmd > /dev/null || sleep 2

set -x

# tests
$cmd | grep "^< HTTP/1.1 200 OK" || exit 1
$cmd | grep "^< Set-Cookie: ttrss_sid=deleted" || exit 1

set +x


