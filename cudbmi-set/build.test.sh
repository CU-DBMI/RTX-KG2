#!/bin/bash

# used for testing Docker or Apptainer/Singularity images for kg2

# setting to exit the script on any failures
set -e

# cd to the home dir for ubuntu user
cd /home/ubuntu

# patch in fixes for setup-kg2-build.sh:
# --------------------------------------
# - insert fixes into line 102 of /home/ubuntu/RTX-KG2/setup-kg2-build.sh
#   for correcting python build requirements
# - replace archived postgres apt link in setup file
#   - see: https://www.postgresql.org/message-id/ZN4OigxPJA236qlg%40msg.df7cb.de
# - start postgresql service in order to run subsequent commands
sudo patch -p1 /home/ubuntu/RTX-KG2/setup-kg2-build.sh \
    /home/ubuntu/RTX-KG2/cudbmi-set/setup-kg2-build.intended.sh.patch

# prepend python dependencies for amending potential challenges
(cat /home/ubuntu/RTX-KG2/cudbmi-set/requirements-build-append.txt \
    && cat /home/ubuntu/RTX-KG2/requirements-kg2-build.txt) > temp.txt \
    && sudo mv temp.txt /home/ubuntu/RTX-KG2/requirements-kg2-build.txt

# redefine s3_cp_cmd after it is set to avoid non-AWS centric work
sudo sed -i.bak '11s/.*/s3_cp_cmd="echo"/' /home/ubuntu/RTX-KG2/master-config.shinc

# run the build script, continuing even if there are errors
sudo bash -x /home/ubuntu/RTX-KG2/setup-kg2-build.sh || true

# make the logs subdir so we may analyze the logs
mkdir -p /home/ubuntu/kg2-build/logs

# copy the logs from the build dir to the log sub dir
cp /home/ubuntu/kg2-build/*.log /home/ubuntu/kg2-build/logs
