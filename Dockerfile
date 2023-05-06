# Base docker image
FROM rocker/shiny

# Installing linux packages
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    git-core \
    libssl-dev \
    libcurl4-gnutls-dev \
    curl \
    libsodium-dev \
    libxml2-dev \
    libicu-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Installing R packages
RUN install2.r --error --skipinstalled \
    shiny \
    httr \
    stringr \
    DT \
    dplyr \
    fresh \
    shinyWidgets \
    tools \
    shinycssloaders \
    shinyjs \
    readr \
    remotes 

RUN Rscript -e 'remotes::install_github("deepanshu88/shinyCopy2clipboard")'

# Server configuration variables
ENV _R_SHLIB_STRIP_=true
COPY Rprofile.site /etc/R

# Copying in source files
COPY . /srv/shiny-server/
COPY Rprofile.site /etc/shiny-server/shiny-server.conf

# Running the program
CMD ["/usr/bin/shiny-server"]
