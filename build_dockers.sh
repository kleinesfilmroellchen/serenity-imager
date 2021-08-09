#!/bin/env bash

cp $SERENITY_IMAGER_DIR/SerenityDockerfile $SERENITY_GIT_DIR/Toolchain/Dockerfile
cat $SERENITY_GIT_DIR/Toolchain/Dockerfile

cd $SERENITY_GIT_DIR
git pull
cd Toolchain
docker build -t serenity --no-cache .

cd $SERENITY_IMAGER_DIR
docker build -t serenity-imager --build-arg KILLCACHE=$(date +%s) .

cd $SERENITY_GIT_DIR
git checkout -- .
