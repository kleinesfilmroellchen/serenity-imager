# Image-creating docker container.
# Based on the serenity base container that has the toolchain setup.
FROM serenity

# suppresses git warnings (we shouldn't have changes in the git repo)
RUN cd serenity-git; git config pull.ff only

# copy the folder structure and build script
RUN mkdir serenity-images
RUN mkdir serenity-images/monthly
RUN mkdir serenity-images/nightly
COPY create_image.sh serenity-images

# execute the script and copy the images to the volume
CMD cd serenity-images; \
	export SERENITY_DIR=/serenity/serenity-git; \
	./create_image.sh; \
	cp -r monthly /serenity/out; \
	cp -r nightly /serenity/out

