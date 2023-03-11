#!/bin/bash

# This script deploys a template to an IoT Edge device.

DEPLOYMENT_VERSION=$(date +%Y%m%d%H%M%S)

TARGET_IOT_HUB=$1
TARGET_CONDITION=$2

az config set extension.use_dynamic_install=yes_without_prompt

az iot edge deployment create \
    -d ${DEPLOYMENT_VERSION} \
    -n ${TARGET_IOT_HUB} \
    --content "./tmp/deployment.tmp.json" \
    --target-condition ${TARGET_CONDITION} \
    --priority 100 \
    --verbose \
    --debug