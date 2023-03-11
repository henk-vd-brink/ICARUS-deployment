#!/bin/bash

CONFIGURATION_FILE=$1
TEMPLATE_FILE=$2

pip3 install -r scripts/requirements.cd.txt

python3 src/generate_template.py \
    --configuration-file ${CONFIGURATION_FILE} \
    --template-file ${TEMPLATE_FILE}