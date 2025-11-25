# starts rocker/verse container and opens Safari to localhost:8787

echo "Opening Docker and Safari..."
cd ~
open -a Docker
open -a Safari http://localhost:8787

# Wait until Docker is running
sleep 4

echo "Starting Docker container..."
cd ~/Project611

docker build . --platform=linux/amd64 -t lou-final-project
docker run\
  --platform=linux/amd64\
  -v $(pwd):/home/rstudio/work\
  -v $HOME/.ssh:/home/rstudio/.ssh\
  -e PASSWORD=123\
  --add-host=host.docker.internal:host-gateway\
  -p 8787:8787 -it lou-final-project
