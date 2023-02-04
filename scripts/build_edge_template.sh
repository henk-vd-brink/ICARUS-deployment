#!/bin/bash

ICARUS_EDGE_DETECTOR_IMAGE=$1
ICARUS_EDGE_DETECTOR_VERSION=$2
TARGET_CONFITION=$3

pip3 install -r scripts/requirements.cd.txt

python3 src/generate_template.py