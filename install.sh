#!/bin/bash -e

GIT_URL=https://github.com/LoickVirot/symfony-docker-environment.git
GIT_BRANCH=master
TMP_PATH=/tmp/lvinit_$(date +%s)
HERE=$(pwd)
PROJECT_NAME=$(basename "$PWD")
USER=$USER

dist_origin=''

print_usage() {
  printf "Usage:\n"
  printf "  -l: use local dist instead of download it from GitHub.\n"
}

init_opts_variables() {
  while getopts 'hl:' flag; do
    case "${flag}" in
      l) dist_origin="${OPTARG}" ;;
      h) print_usage
          exit 0 ;;
      *) print_usage
         exit 1 ;;
    esac
  done
}

remove_install_script() {
  cd "$HERE"

  if [ -f "install.sh" ]; then
    echo "=== Delete install file"
    rm install.sh
  fi
}

cleanup() {
  exitCode=$?

  cd "$HERE"
  if [ $exitCode != "0" ]; then
    echo "Stopping..."

    if [ -d "$TMP_PATH" ]; then
      echo "=== Cleanup"
      echo "Remove $TMP_PATH"
      rm -Rf "$TMP_PATH"
    fi

    docker_compose_ids=$(docker-compose ps -q)
    if [[ $? == 0 ]]; then
      if [[ $docker_compose_ids ]]; then
        stop_docker_containers
      fi
    fi
  fi

  remove_install_script
}

stop_docker_containers() {
  echo "Stop launched containers"
  docker-compose down
}

enable_composer_recipes() {
  docker-compose exec -T symfony composer config extra.symfony.allow-contrib true
  if [[ $? != 0 ]]; then
    stop_docker_containers
    exit $?
  fi
}

disable_composer_recipes() {
  docker-compose exec -T symfony composer config extra.symfony.allow-contrib false
  if [[ $? != 0 ]]; then
    stop_docker_containers
    exit $?
  fi
}

retrieve_dist() {
  if [[ ! $dist_origin ]]; then
    echo "=== Create temporary directory: $TMP_PATH"
    mkdir -p "$TMP_PATH"
    cd "$TMP_PATH"
    git init .
    git remote add origin $GIT_URL
    git pull origin $GIT_BRANCH

    cp -ra dist/. "$HERE"
  else
    if [ ! -d "$dist_origin" ]; then
      echo "ERR: $dist_origin not found."
      exit 1
    fi
    echo "=== Copy dist directory from: $dist_origin"
    cp -ra "$dist_origin"/. "$HERE"
  fi
}

install_dotenv() {
  cd "$HERE"
  ENV_FILE=.env

  if [ ! -f "$ENV_FILE" ]; then
    echo "=== Create .env file"
    mv .env.example .env
  else
    echo "=== .env file already exists, skipping."
  fi
}

start_docker() {
  cd "$HERE"

  docker_compose_ids=$(docker-compose ps -q)
  if [[ $? != 0 ]]; then
    echo "ERR: Cannot run docker-compose."
  elif [[ $docker_compose_ids ]]; then
    echo "=== Started containers has been detected in docker-compose, skipping."
  else
    # Run docker containers
    echo "=== Starting Docker containers..."
    docker-compose up -d --build

    if [[ $? != 0 ]]; then
      stop_docker_containers
      exit $?
    fi
  fi
}

check_symfony_dependencies() {
  cd "$HERE"

  echo "=== Check Symfony dependencies"
  docker-compose exec -T symfony symfony check:requirements
  if [[ $? != 0 ]]; then
    stop_docker_containers
    exit $?
  fi
}

install_symfony() {
  cd "$HERE"

  echo "=== Remove www/.gitkeep"
  rm www/.gitkeep

  echo "=== Create new Symfony project"
  docker-compose exec -T symfony composer create-project symfony/skeleton .
  if [[ $? != 0 ]]; then
    stop_docker_containers
    exit $?
  fi
}

install_codequality() {
  cd "$HERE/www"

  enable_composer_recipes

  echo "=== Install CodeSniffer"
  docker-compose exec -T symfony composer require --dev squizlabs/php_codesniffer
  if [[ $? != 0 ]]; then
    stop_docker_containers
    exit $?
  fi

  echo "=== Install PHPStan"
  docker-compose exec -T symfony composer require --dev phpstan/phpstan
  if [[ $? != 0 ]]; then
    stop_docker_containers
    exit $?
  fi

  disable_composer_recipes
}

install_phpunit() {
  cd "$HERE/www"

  enable_composer_recipes

  echo "=== Install PHPUnit"
  docker-compose exec -T symfony composer require --dev phpunit/phpunit
  if [[ $? != 0 ]]; then
    stop_docker_containers
    exit $?
  fi

  mv $HERE/phpunit.dist.xml $HERE/www/phpunit.dist.xml
  if [[ $? != 0 ]]; then
    stop_docker_containers
    exit $?
  fi

  disable_composer_recipes
}

configure_composer_json() {
  cd "$HERE/www"

  docker-compose exec -T symfony composer config name "$USER/$PROJECT_NAME"
  if [[ $? != 0 ]]; then
    stop_docker_containers
    exit $?
  fi

  docker-compose exec -T symfony composer config description ""
  if [[ $? != 0 ]]; then
    stop_docker_containers
    exit $?
  fi

  docker-compose exec -T symfony composer update
  if [[ $? != 0 ]]; then
    stop_docker_containers
    exit $?
  fi
}

set_permission() {
  echo "=== Add permission to www directory"
  cd "$HERE"
  sudo chown -R "$USER": www
}

end_message() {
  echo "Symfony has been installed successfully!"
  echo "You can see all docker containers created with the command : "
  echo "    docker-compose ps"
  echo "All Symfony files are located in www folder."
  echo "Your website is accessible in http://localhost:8000/"
}

trap cleanup EXIT

init_opts_variables "$@"
retrieve_dist
install_dotenv
start_docker
check_symfony_dependencies
install_symfony
install_codequality
install_phpunit
configure_composer_json
set_permission
end_message

exit 0
