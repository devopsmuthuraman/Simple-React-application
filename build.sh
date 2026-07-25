#!/bin/bash
set -e

# Usage: ./build.sh <branch_name>
BRANCH=${1:-dev}   # default to dev if no argument

IMAGE_NAME="react-static-app"
DEV_IMAGE="your-dockerhub-username/dev:latest"
PROD_IMAGE="your-dockerhub-username/prod:latest"

echo "Building Docker image for branch '$BRANCH'..."
docker build -t $IMAGE_NAME:latest .

if [ "$BRANCH" == "dev" ]; then
    echo "Tagging image for dev repo..."
    docker tag $IMAGE_NAME:latest $DEV_IMAGE
elif [ "$BRANCH" == "master" ]; then
    echo "Tagging image for prod repo..."
    docker tag $IMAGE_NAME:latest $PROD_IMAGE
else
    echo "Unknown branch '$BRANCH'. Tagging as latest locally only."
fi

echo "Build complete."
