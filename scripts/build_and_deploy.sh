#!/bin/bash

DEPLOYMENT_VERSION=$(date +%Y%m%d%H%M%S)

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

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

cat $configuration_file | envsubst > /tmp/configuration.tmp.yaml
cat $template_file > /tmp/template.tmp.json

pip3 install -r scripts/requirements.cd.txt

python3 src/generate_template.py \
    --configuration-file /tmp/configuration.tmp.yaml \
    --template-file /tmp/template.tmp.json

TARGET_IOT_HUB=$1
TARGET_CONDITION=$2

eval $(parse_yaml /tmp/configuration.tmp.yaml)

az config set extension.use_dynamic_install=yes_without_prompt

az iot edge deployment create \
    -d ${DEPLOYMENT_VERSION} \
    -n iot-icarus-dev \
    --content "/tmp/deployment.tmp.json" \
    --target-condition "$target_condition" \
    --priority 100 \
    --verbose \
    --debug