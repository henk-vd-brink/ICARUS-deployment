#!/bin/bash

DEPLOYMENT_VERSION=$(date +%Y%m%d%H%M%S)

mkdir -p ./tmp

while getopts c:t: flag
do
    case "${flag}" in
        c) configuration_file=${OPTARG};;
        t) template_file=${OPTARG};;
    esac
done

if [ -z "$configuration_file" ] || [ -z "$template_file" ]; then
    echo "Usage: $0 -c <configuration_file> -t <template_file>"
    exit 1
fi

pip3 install -r scripts/requirements.cd.txt

python3 src/substitute_environment_variables.py \
    --input-file $configuration_file \
    --output-file ./tmp/configuration.tmp.json

python3 src/substitute_environment_variables.py \
    --input-file $template_file \
    --output-file ./tmp/template.tmp.json


# Generate deployment.json
python3 src/generate_template.py \
    --configuration-file ./tmp/configuration.tmp.json \
    --template-file ./tmp/template.tmp.json

target_condition=$(grep "target_condition" ./tmp/configuration.tmp.json | cut -d ":" -f2-)

az config set extension.use_dynamic_install=yes_without_prompt

az iot edge deployment create \
    -d ${DEPLOYMENT_VERSION} \
    -n iot-icarus-dev \
    --content "./tmp/deployment.tmp.json" \
    --target-condition "$target_condition" \
    --priority 100