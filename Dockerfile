FROM rocker/r-ver:4.0.2

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
	make \
	libsodium-dev \
	libicu-dev \
	libcurl4-openssl-dev \
	libssl-dev

# Using rocker to install these packages doesn't provide the latest versions
# Instead, we'll use the precompiled binaries kindly provided by RStudio
# Package versions pinned to 2020-10-01
ENV CRAN_REPO https://packagemanager.rstudio.com/all/__linux__/focal/338
RUN Rscript -e 'install.packages(c("plumber", "promises", "future", "jose", "openssl", "dplyr", "reticulate"), repos = c("CRAN" = Sys.getenv("CRAN_REPO")))'

# Create a non-root plumber user to run the API, along with a new home directory
RUN groupadd -r plumber && useradd --no-log-init -r -g plumber plumber

ADD plumber.R /home/plumber/plumber.R
ADD entrypoint.R /home/plumber/entrypoint.R

RUN mkdir /home/plumber/data

########################################################
#ENV RETICULATE_MINICONDA_PATH /home/plumber/miniconda
#RUN R -q -e 'reticulate::install_miniconda()'
##RUN R -q -e 'reticulate::conda_create(envname = "r-k8s", packages = c("python=3.9.0", "numpy","yaml"))'
#RUN R -q -e 'reticulate::conda_create(envname = "r-k8s", packages = c("python=3.8.13", "numpy","yaml"))'
##RUN R -q -e 'reticulate::conda_list()'
#RUN R -q -e 'reticulate::conda_install(envname = "r-k8s", packages = "kubernetes", pip = TRUE)'

## Modify Rprofile
#RUN R -e 'write("reticulate::use_condaenv(\"r-k8s\", required = TRUE)",file=file.path(R.home(),"etc","Rprofile.site"),append=TRUE)'
#RUN R -e 'write("reticulate::import(\"kubernetes\")",file=file.path(R.home(),"etc","Rprofile.site"),append=TRUE)'

#ADD k8sAPI.R /home/plumber/k8sAPI.R

#RUN mkdir /home/plumber/python
#COPY ./python/ /home/plumber/python
########################################################

EXPOSE 8000

WORKDIR /home/plumber
USER plumber
CMD Rscript entrypoint.R
