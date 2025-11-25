FROM rocker/verse:4.4.1

USER root

# Create apt config to avoid caching / proxy issues
RUN echo "Acquire::http::Pipeline-Depth 0;" > /etc/apt/apt.conf.d/99fixbadproxy && \
    echo "Acquire::http::No-Cache true;" >> /etc/apt/apt.conf.d/99fixbadproxy && \
    echo "Acquire::BrokenProxy true;" >> /etc/apt/apt.conf.d/99fixbadproxy

# Clean any old apt lists, update, run unminimize (with yes), then install man-db
RUN rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    apt-get update && \
    yes | unminimize && \
    apt-get update && \
    rm -rf /var/lib/apt/lists/*
    
# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Pull your embedding model
RUN ollama pull qwen3-embedding:8b

# Install R packages
RUN R -e "install.packages(c('tidyverse','httr','jsonlite','digest','Rtsne','viridis'), repos='https://cloud.r-project.org')"