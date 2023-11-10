# workarounds added to setup-kg2-build.sh

# these setuptools requirements appear to be interrelated
# and cause errors when left as-is with RTX-KG2 builds through setup-kg2-build.sh
sudo /home/ubuntu/kg2-venv/bin/pip3 uninstall --yes setuptools
sudo /home/ubuntu/kg2-venv/bin/pip3 install setuptools-rust pip setuptools -U

# continue original script
