# Use the official Docker-in-Docker image
FROM docker:latest

# Install any additional packages if needed
RUN apk add --no-cache git

# Set the environment variables for Docker Hub login
ARG DOCKERHUB_USERNAME
ARG DOCKERHUB_PASSWORD

# Create a script to log in to Docker Hub, build the image, and push it
RUN echo -e '#!/bin/sh\n\
if [ -z "$DOCKERHUB_USERNAME" ] || [ -z "$DOCKERHUB_PASSWORD" ]; then\n\
  echo "DOCKERHUB_USERNAME and DOCKERHUB_PASSWORD must be set"\n\
  exit 1\n\
fi\n\
# Start the Docker daemon in the background\n\
dockerd &\n\
# Wait for the Docker daemon to start\n\
while (! docker stats --no-stream ); do\n\
  sleep 1\n\
done\n\
echo "$DOCKERHUB_PASSWORD" | docker login --username "$DOCKERHUB_USERNAME" --password-stdin\n\
docker build -t $DOCKERHUB_USERNAME/hello-world:latest -f /app/Dockerfile.hello /app\n\
docker push $DOCKERHUB_USERNAME/hello-world:latest' > /build-and-push.sh

# Make the script executable
RUN chmod +x /build-and-push.sh

# Copy the Dockerfile for the "Hello World" image
COPY Dockerfile.hello /app/Dockerfile.hello

# Add debugging step to check file existence and permissions
RUN ls -l /build-and-push.sh && cat /build-and-push.sh

# Set the entrypoint to the script
ENTRYPOINT ["/build-and-push.sh"]
