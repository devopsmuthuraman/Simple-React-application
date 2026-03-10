#!/bin/bash

# Stop script if any command fails
set -e

# Variables
IMAGE_NAME="react-app"
IMAGE_TAG="latest"

echo "Starting Docker build..."

# Build Docker image
docker build -t $IMAGE_NAME:$IMAGE_TAG .

echo "Docker image built successfully!"
echo "Image: $IMAGE_NAME:$IMAGE_TAG"

# Optional: show images
docker images | grep $IMAGE_NAME