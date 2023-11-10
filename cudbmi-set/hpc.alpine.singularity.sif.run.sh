#!/bin/bash

# Shell script to run extended rtx-kg2 image on
# CU HPC Alpine environment.

#SBATCH --job-name=rtx-kg2-cudbmi-set
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=256G
#SBATCH --time=100:00:00
#SBATCH --output=output_file.%j

# load Singularity module
module load singularity

# set a project dir which has 250GB of space
export SINGULARITY_TMPDIR=/projects/$USER
export KG2_LOCAL_BUILD_DIR=$SINGULARITY_TMPDIR/kg2-build

# create a kg2-build dir for the data to land
mkdir -p $KG2_LOCAL_BUILD_DIR

# Pull the Docker image using Singularity
curl -LJO \
    https://github.com/CU-DBMI/RTX-KG2/releases/download/v2023.11.08/kg2-cudbmi-set.sif \
    -o $SINGULARITY_TMPDIR/kg2-cudbmi-set_latest.sif

# Run the Singularity container
singularity run \
    --bind $KG2_LOCAL_BUILD_DIR:/home/ubuntu/kg2-build \
    $SINGULARITY_TMPDIR/kg2-cudbmi-set_latest.sif
