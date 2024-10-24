#!/bin/bash

# Path to the JSON file
JSON_FILE="public/data/container.json"

# Check if the JSON file exists
if [ ! -f "$JSON_FILE" ]; then
    echo "Error: JSON file not found at expected location '$JSON_FILE'."
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' command not found."
    exit 1
fi

# Extract and build the FQIN (Fully Qualified Image Name) from the JSON file
REGISTRY=$(jq -r '.image.registry // empty' $JSON_FILE)
NAMESPACE=$(jq -r '.image.namespace // empty' $JSON_FILE)
REPOSITORY=$(jq -r '.image.repository // empty' $JSON_FILE)
TAGS=($(jq -r '.image.tags[]' $JSON_FILE))

# Check if REPOSITORY or TAGS is missing
if [[ -z "$REPOSITORY" || ${#TAGS[@]} -eq 0 ]]; then
  echo "Error: Image 'repository' or 'tags' is missing in the JSON file."
  exit 1
fi

# Combine the registry, namespace, and repository to form the image name
FQRN="${REGISTRY:+${REGISTRY}/}${NAMESPACE:+${NAMESPACE}/}${REPOSITORY}"
FQIN="${FQRN}:${TAGS[0]}" # Use the first tag from the array for building the image

# Build a multi-architecture Docker image using the first tag
docker buildx build --platform linux/amd64,linux/arm64 -t $FQIN .

# If the build is successful...
if [ $? -eq 0 ]; then

  # Tag the image with the remaining tags
  for TAG in "${TAGS[@]:1}"; do
    docker tag $FQIN "${FQRN}:${TAG}"
  done

  # Ask if the user wants to push the image to the registry
  read -p "Do you want to push the image '${FQIN}' and its tags? (y/N): " Q
  Q=$(echo "$Q" | tr '[:upper:]' '[:lower:]')
  if [[ "$Q" == "y" || "$Q" == "yes" ]]; then
    for TAG in "${TAGS[@]}"; do
      docker push "${FQRN}:${TAG}"
    done
  fi

  # Ask if the user wants to run the container
  read -p "Do you want to run the container now? (y/N): " Q
  Q=$(echo "$Q" | tr '[:upper:]' '[:lower:]')
  if [[ "$Q" == "y" || "$Q" == "yes" ]]; then
    docker run --rm -p 80:80 --name $REPOSITORY $FQIN
  fi

fi
