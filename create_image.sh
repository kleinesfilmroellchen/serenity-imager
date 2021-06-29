#!/bin/sh
# Create and copy a new SerenityOS image from the most recent commit.
# Copyright (c) 2021 kleines Filmröllchen
# This file is licensed under the MIT license,
# a copy of which can be obtained at <https://mit-license.org/>.

# Notes on script behavior:
#  * Git: It is assumed that you are on a pullable branch, ideally serenityos/serenity/master.
#  * Sudo: There must not be a password prompt for sudo.

# Environment variables:
# $SERENITY_DIR: Directory of the SerenityOS Git repository.

IMAGE_DIR=$(pwd)
echo $SERENITY_DIR
cd $SERENITY_DIR

# Fetch changes and build.
git pull
cd Build/i686
cmake ../.. -G Ninja
ninja install
ninja image

# Copy image.
IMGNAME="serenityos-vmbootable-nightly-$(date --iso-8601).iso"
cp _disk_image $IMAGE_DIR/nightly/$IMGNAME 

# If this is the first image created this month, save the image as the monthly.
MONTHLY_IMGNAME="serenityos-vmbootable-monthly-$(date +%Y-%m).iso"
if [ ! -f $IMAGE_DIR/monthly/$MONTHLY_IMGNAME ]
then
	echo "Creating monthly image for $(date +%B)."
	cp _disk_image $IMAGE_DIR/monthly/$MONTHLY_IMGNAME
fi

cd $IMAGE_DIR
