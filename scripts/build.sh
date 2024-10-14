#!/usr/bin/env bash

set -ev

export BUILD_VERSION="0.0.2-SNAPSHOT"
export BUILD_DATE=`date +%Y-%m-%dT%T%z`

SCRIPT_DIR=$(dirname "$0")

if [[ -z "$GROUP" ]] ; then
    echo "Cannot find GROUP env var"
    exit 1
fi

if [[ -z "$IMAGE_TAG" ]] ; then
    echo "Cannot find IMAGE_TAG env var"
    exit 1
fi



if [[ "$(uname)" == "Darwin" ]]; then
    DOCKER_CMD="sudo docker"
else
    DOCKER_CMD=docker
fi

CODE_DIR=$(cd $SCRIPT_DIR/..; pwd)

echo $CODE_DIR

$DOCKER_CMD run --rm -v $HOME/.m2:/root/.m2 -v $CODE_DIR:/usr/src/mymaven -w /usr/src/mymaven maven:3.6-jdk-11 mvn -q -DskipTests package

cp $CODE_DIR/target/*.jar $CODE_DIR/docker/carts

for m in ./docker/*/; do
    REPO=${GROUP}/$(basename $m)

    $DOCKER_CMD build \
      --build-arg BUILD_VERSION=$BUILD_VERSION \
      --build-arg BUILD_DATE=$BUILD_DATE \
      --build-arg COMMIT=$COMMIT \
      -t ${REPO}:${IMAGE_TAG} $CODE_DIR/$m;
done;
