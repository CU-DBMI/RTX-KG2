#!/bin/bash

# used for building Docker and Apptainer/Singularity images for use
# with RTX-KG2 on the University of Colorado's Alpine HPC

# set env vars for use below
export TARGET_PLATFORM=linux/amd64
export TARGET_KG2_DOCKERFILE=./Dockerfile
export TARGET_KG2_TAG=kg2
export TARGET_CUDBMI_DOCKERFILE=./cudbmi-set/Dockerfile.build-extended
export TARGET_KG2_TAG=kg2-cudbmi-set
export TARGET_DOCKER_IMAGE_FILENAME=$TARGET_TAG.tar.gz
export TARGET_SINGULARITY_IMAGE_FILENAME=$TARGET_TAG.sif
export TARGET_DOCKER_IMAGE_FILEPATH=./image/$TARGET_DOCKER_IMAGE_FILENAME

# make image dir if it doesn't already exist
mkdir -p ./image

# clear images
rm -f ./image/*

# create a buildx builder
docker buildx create --name mybuilder
docker buildx use mybuilder

# build kg2 image as per the platform
docker buildx build --platform $TARGET_PLATFORM -f $TARGET_KG2_DOCKERFILE -t $TARGET_KG2_TAG . --load
# build extended kg2 image with decoupled additions
docker buildx build --platform $TARGET_PLATFORM -f $TARGET_CUDBMI_DOCKERFILE -t $TARGET_CUDBMI_TAG . --load

# docker buildx build --platform $DOCKER_SINGULARITY_PLATFORM -t $TARGET_TAG . --load
docker save $TARGET_TAG | gzip > $TARGET_DOCKER_IMAGE_FILEPATH

# #load the docker image to test that the results work (in docker)
docker load -i $TARGET_DOCKER_IMAGE_FILEPATH
docker run --platform $TARGET_PLATFORM -it $TARGET_TAG /bin/bash

# build the docker image as a singularity image
# docker build --platform $TARGET_PLATFORM -f docker/Dockerfile.2.build-singularity-image -t singularity-builder .
# docker run --platform $TARGET_PLATFORM -v $PWD/image:/image -it --privileged singularity-builder
# docker run --platform $TARGET_PLATFORM \
#     --volume $PWD/image:/image \
#     --workdir /image \
#     --privileged \
#     quay.io/singularity/singularity:v4.0.1 \
#     build $TARGET_SINGULARITY_IMAGE_FILENAME docker-archive://$TARGET_DOCKER_IMAGE_FILENAME