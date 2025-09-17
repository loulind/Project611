# starts r studio and 


cd ~
echo "Opening Docker"
open -a Docker
sleep 2

echo "Starting rocker/verse container"
docker run -e USERID=$(id -u) -e GROUPID=$(id -g)\
  --platform=linux/amd64\
  -v $(pwd):/home/rstudio/work\
  -v $HOME/.ssh:/home/rstudio/.ssh\
  -v $HOME/.gitconfig:/home/rstudio/.gitconfig\
  -e PASSWORD=123\
  -p 8787:8787 rocker/verse
sleep 2

echo "Opening localhost:8787"
echo "Password: 123"
open -a Safari localhost:8787

setwd("~/work")