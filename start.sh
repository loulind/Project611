docker build . --platform=linux/amd64 -t lou-final-project

# ports to 8787 for rocker container and 6052 for shiny interactive output
docker run \
  --platform=linux/amd64 \
  -v $(pwd):/home/rstudio/work \
  -v $HOME/.ssh:/home/rstudio/.ssh \
  -e PASSWORD=123 \
  --add-host=host.docker.internal:host-gateway \
  -p 8787:8787 \
  -it lou-final-project
