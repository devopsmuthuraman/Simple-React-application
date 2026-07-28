#!/bin/bash
set -e

BRANCH=$1

DEV_IMAGE="mubha/dev:latest"
PROD_IMAGE="mubha/prod:latest"

COMPOSE_FILE="docker-compose.prod.yml"

if [ "$BRANCH" = "dev" ]; then

    IMAGE=$DEV_IMAGE

elif [ "$BRANCH" = "main" ]; then

    IMAGE=$PROD_IMAGE

else

    echo "Unknown Branch"

    exit 1

fi

sed -i "s|image: .*|image: $IMAGE|" $COMPOSE_FILE

docker compose -f $COMPOSE_FILE down || true

docker compose -f $COMPOSE_FILE pull

docker compose -f $COMPOSE_FILE up -d