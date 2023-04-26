#!/bin/bash

ENV_FILE=.env

if [ ! -f "$ENV_FILE" ]; then
  echo "=== Create .env file"
  cp .env.example .env
else
  echo "=== .env file already exists, skipping."
fi

docker_compose_ids=$(docker-compose ps -q)
if [[ $? != 0 ]]; then
  echo "ERR: Cannot run docker-compose."
elif [[ $docker_compose_ids ]]; then
  echo "=== Started containers has been detected in docker-compose, skipping."
else
  # Run docker containers
  echo "=== Starting Docker containers..."
  docker-compose up -d --build
fi

echo "=== Check Symfony dependencies"
docker-compose exec symfony symfony check:requirements
if [[ $? != 0 ]]; then
  exit $?
fi

echo "=== Remove www/.gitkeep"
rm www/.gitkeep

echo "=== Create new Symfony project"
docker-compose exec symfony composer create-project symfony/skeleton .
if [[ $? != 0 ]]; then
  exit $?
fi

exit 0
