FROM rocker/verse:4.4.1

USER root

# Install R packages
RUN R -e "install.packages(c('tidyverse','httr','jsonlite','digest','Rtsne','viridis'), repos='https://cloud.r-project.org')"

