#!/bin/bash
set -e

# Usage: ./deploy.sh Simple-React-application
BRANCH=${1:-dev}  # default to dev if no argument

DEV_IMAGE="mubha/dev:latest"
PROD_IMAGE="mubha/prod:latest"
COMPOSE_FILE="docker-compose.prod.yml"

# Pick the right image for this branch
if [ "$BRANCH" == "dev" ]; then
    IMAGE=$DEV_IMAGE
elif [ "$BRANCH" == "master" ]; then
    IMAGE=$PROD_IMAGE
else
    echo "Unknown branch '$BRANCH'. Nothing to deploy."
    exit 1
fi

# Point the prod compose file at the freshly-built image
sed -i "s|image: .*|image: $IMAGE|" $COMPOSE_FILE

# Stop previous container
echo "Stopping old container if it exists..."
docker compose -f $COMPOSE_FILE down || true

# Pull and start the new one
echo "Pulling and starting container..."
docker compose -f $COMPOSE_FILE pull
docker compose -f $COMPOSE_FILE up -d

echo "Deployment completed for branch $BRANCH!"
