[![Docker Image CI](https://github.com/mattgalbraith/bbtools-docker-singularity/actions/workflows/docker-image.yml/badge.svg)](https://github.com/mattgalbraith/bbtools-singularity/actions/workflows/docker-image.yml)
# bbtools-docker-singularity
## Build Docker container for BBTools and (optionally) convert to Apptainer/Singularity.  
BBTools is a suite of fast, multithreaded bioinformatics tools designed for analysis of DNA and RNA sequence data.    
The BBTools suite includes programs such as:
• bbduk – filters or trims reads for adapters and contaminants using k-mers
• bbmap – short-read aligner for DNA and RNA-seq data
  
#### Requirements:
To run BBTools, you need to have Java 7 or higher installed.
  
## Build docker container:  

### 1. For BBTools installation instructions:  
https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/installation-guide/  


### 2. Build the Docker Image

#### To build image from the command line:  
``` bash
# Assumes current working directory is the top-level bbtools-docker-singularity directory
docker build -t bbtools:39.01 . # tag should match software version
```
* Can do this on [Google shell](https://shell.cloud.google.com)

#### To test this tool from the command line:
``` bash
docker run --rm -it bbtools:39.01 java --version # verify java installation

docker run --rm -it bbtools:39.01 bbduk.sh --version # FAIL due to a bug in bbduk.sh when it should calculate memory usage (container only??) (also present in 38.90)
docker run --rm -it bbtools:39.01 bbduk.sh -Xmx500m --version # PASS specifying memory manualy (and may be better on HPC)
docker run --rm -it bbtools:39.01 bbduk.sh --help # PASS but help comes from the shell script and does not use java

docker run --rm -it bbtools:39.01 stats.sh --version # PASS
docker run --rm -it bbtools:38.90 bash -c "stats.sh in=/usr/local/bin/resources/phix174_ill.ref.fa.gz" # TEST with internal data - PASS so does not have same issue with memory calc
```
See issue here: https://www.biostars.org/p/372460/

## Optional: Conversion of Docker image to Singularity  

### 3. Build a Docker image to run Singularity  
(skip if this image is already on your system)  
https://github.com/mattgalbraith/singularity-docker

### 4. Save Docker image as tar and convert to sif (using singularity run from Docker container)  
``` bash
docker images
docker save <Image_ID> -o bbtools39.01-docker.tar && gzip bbtools39.01-docker.tar # = IMAGE_ID of BBTools image
docker run -v "$PWD":/data --rm -it singularity:1.1.5 bash -c "singularity build /data/bbtools39.01.sif docker-archive:///data/bbtools39.01-docker.tar.gz"
```
NB: On Apple M1/M2 machines ensure Singularity image is built with x86_64 architecture or sif may get built with arm64  

Next, transfer the bbtools.sif file to the system on which you want to run BBTools from the Singularity container  

### 5. Test singularity container on (HPC) system with Singularity/Apptainer available  
``` bash
# set up path to the BBTools Singularity container
BBTOOLS_SIF=path/to/bbtools39.01.sif

# Test that BBTools can run from Singularity container
singularity run $BBTOOLS_SIF bbduk.sh --help # depending on system/version, singularity may be called apptainer
```