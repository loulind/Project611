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
    apt-get install -y man-db sqlite3 && \
    rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages(c('RSQlite','DBI'))"