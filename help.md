# Docker commands to build the image and push to docker:
#
# Build the image

docker build -t case-study-web-app:1.0 .

# Execute image in a container
 docker run -d -p 8080:8081 --name WebApplication case-study-web-app:1.0

# Verify it works
curl http://localhost:8081

# Tag image before pushing to docker
docker tag case-study-web-app:1.0 luissanzaguilar/case-study-web-app:1.0

# Push to docker
docker push luissanzaguilar/case-study-web-app:1.0


