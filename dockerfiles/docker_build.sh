#!/bin/bash

FLINK_VERSION=1.17
ENV_FILE=build_env_${FLINK_VERSION}.env
DOCKERFILE=Dockerfile.flink-cdc

DOCKER_TAG="flink-cdc-spike:v1"


source ${ENV_FILE}

set -x
./download_dependencies.sh $DEPENDENCY_DIR


docker build --no-cache --build-arg "DEPENDENCY_DIR=$DEPENDENCY_DIR" -f $DOCKERFILE -t $DOCKER_TAG .
