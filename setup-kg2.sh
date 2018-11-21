#!/bin/bash
BUILD_DIR=~/kg2-build
VENV_DIR=~/kg2-venv
sudo apt-get update
sudo apt-get install -y python3-minimal python3-pip git default-jre
sudo pip3 install virtualenv
virtualenv ${VENV_DIR}
${VENV_DIR}/bin/pip3 install ontobio
mkdir -p ${BUILD_DIR}
wget -P ${BUILD_DIR} http://build.berkeleybop.org/userContent/owltools/owltools
chmod a+x ${BUILD_DIR}/owltools