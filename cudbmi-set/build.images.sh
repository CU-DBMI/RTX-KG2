#!/bin/bash

# used for building Docker and Apptainer/Singularity images for use
# with RTX-KG2 on the University of Colorado's Alpine HPC

# setting to exit the script on any failures
set -e

# set env vars for use below
export TARGET_VERSION="2023.11.08"
export TARGET_PLATFORM=linux/amd64
export TARGET_KG2_DOCKERFILE=./Dockerfile
export TARGET_KG2_TAG=kg2
export TARGET_CUDBMI_DOCKERFILE=./cudbmi-set/Dockerfile.build-extended
export TARGET_CUDBMI_TAG=kg2-cudbmi-set
export TARGET_DOCKER_IMAGE_FILENAME=$TARGET_CUDBMI_TAG.tar.gz
export TARGET_SINGULARITY_IMAGE_FILENAME=$TARGET_CUDBMI_TAG.sif
export TARGET_DOCKER_IMAGE_FILEPATH=./image/$TARGET_DOCKER_IMAGE_FILENAME

# make image dir if it doesn't already exist
mkdir -p ./image

# clear images
rm -f ./image/*

# build kg2 image as per the platform
docker build --platform $TARGET_PLATFORM \
    -f $TARGET_KG2_DOCKERFILE \
    -t $TARGET_KG2_TAG:latest \
    .

# using the kg2 image above,
# build extended kg2 image with decoupled additions
docker build \
    --build-arg IMAGE_REF="kg2" \
    --platform $TARGET_PLATFORM \
    -f $TARGET_CUDBMI_DOCKERFILE \
    -t $TARGET_CUDBMI_TAG:latest \
    .

# run the docker image with the contents of the build.test.sh script
docker run \
    -v $PWD/cudbmi-set/kg2-build-logs:/home/ubuntu/kg2-build/logs \
    --platform $TARGET_PLATFORM \
    $TARGET_CUDBMI_TAG:latest \
    /bin/bash \
    -c "/home/ubuntu/RTX-KG2/cudbmi-set/build.test.sh" || true

# # seek success text in specific log file
# note: if we fail here we exit and do not proceed to build the singularity image
if grep -q "======= script finished ======" "$PWD/cudbmi-set/kg2-build-logs/setup-kg2-build.log"; then
    echo "setup-kg2-build.sh finished successfully."
else
    echo "Error: setup-kg2-build.sh did not finish successfully."
    exit 1
fi

# build the docker image as a singularity image
docker run --platform $TARGET_PLATFORM \
    --volume $PWD/image:/image \
    --workdir /image \
    --privileged \
    quay.io/singularity/singularity:v4.0.1 \
    build $TARGET_SINGULARITY_IMAGE_FILENAME docker-archive://$TARGET_DOCKER_IMAGE_FILENAME
