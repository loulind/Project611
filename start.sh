# starts rocker/verse container and opens Safari to localhost:8787

echo "Opening Docker..."
cd ~
open -a Docker

# Wait until Docker is running
sleep 4

echo "Starting rocker/verse container in background..."
cd ~/Project611

docker build . --platform=linux/amd64 -t my-rstudio-with-man
docker run\
  --platform=linux/amd64\
  -v $(pwd):/home/rstudio/work\
  -v $HOME/.ssh:/home/rstudio/.ssh\
  -v $HOME/.gitconfig:/home/rstudio/.gitconfig\
  -e PASSWORD=123\
  -p 8787:8787 -it my-rstudio-with-man



echo "Opening localhost:8787..."
cd ~
# Wait until Container is running
sleep 4
open -a Safari http://localhost:8787
