#!/bin/bash
set -e

BRANCH=$1

if [ "$BRANCH" = "dev" ]; then

    IMAGE="mubha/dev:latest"

elif [ "$BRANCH" = "main" ]; then

    IMAGE="mubha/prod:latest"

else

    echo "Unknown branch"

    exit 1

fi

echo "Building $IMAGE"

docker build -t $IMAGE .

echo "Build Successful"