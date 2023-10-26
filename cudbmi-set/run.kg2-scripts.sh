#!/bin/bash

# used for running the preparatory scripts within the context
# of a running container.

# setting to exit the script on any failures
set -e

# switch user to ubuntu
su - ubuntu

# cd to the home dir for ubuntu user
cd /home/ubuntu

# run the build script
bash -x /home/ubuntu/RTX-KG2/setup-kg2-build.sh
