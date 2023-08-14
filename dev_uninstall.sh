#!/bin/bash -e

docker-compose stop
docker-compose rm

rm -Rf $(pwd)/*
rm -Rf $(pwd)/.* 2> /dev/null
