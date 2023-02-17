################# BASE IMAGE ######################
FROM --platform=linux/amd64 ubuntu:20.04 as base

################## METADATA ######################
LABEL base_image="Ubuntu:20.04"
LABEL version="1.0.0"
LABEL software="BBTools"
LABEL software.version="39.01"
LABEL about.summary="BBTools is a suite of fast, multithreaded bioinformatics tools designed for analysis of DNA and RNA sequence data."
LABEL about.home="https://jgi.doe.gov/data-and-tools/software-tools/bbtools/"
LABEL about.documentation="https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/"
LABEL about.license_file=""
LABEL about.license="Open Source"

################## MAINTAINER ######################
MAINTAINER Matthew Galbraith <matthew.galbraith@cuanschutz.edu>

################## INSTALLATION ######################
ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGES tar wget ca-certificates

RUN apt-get update && \
    apt-get install -y --no-install-recommends ${PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and extract BBTools
# RUN wget https://sourceforge.net/projects/bbmap/files/BBMap_38.90.tar.gz && \
# 	tar -xzvf BBMap_38.90.tar.gz
RUN wget https://sourceforge.net/projects/bbmap/files/BBMap_39.01.tar.gz && \
	tar -xzvf BBMap_39.01.tar.gz

# # Attempting to fix bbduk.sh memory error
# COPY bbduk_mod.sh .
# RUN cp bbduk_mod.sh /bbmap/bbduk.sh


################## 2ND STAGE ######################
FROM --platform=linux/amd64 ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGES ca-certificates openjdk-11-jre-headless

RUN apt-get update && \
    apt-get install -y --no-install-recommends ${PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=base /bbmap/ /usr/local/bin/