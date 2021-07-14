#!/bin/sh
cd $SERENITY_IMAGER_DIR
docker run -v "$SERENITY_IMAGER_DIR:/serenity/out" --rm serenity-imager

