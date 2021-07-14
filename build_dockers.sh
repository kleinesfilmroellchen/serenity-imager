#!/bin/env bash

cd $SERENITY_GIT_DIR
git pull
cd Toolchain
docker build -t serenity .

cd $SERENITY_IMAGER_DIR
docker build -t serenity-imager .

