# SerenityOS Image creation system

A simple system to automatically build images for SerenityOS. Intended to be used with internet distribution, [just as the author does himself](https://klfr.spdns.de/serenity-iso).

## Disclaimer

This project is not officially associated with the [SerenityOS](https://github.com/SerenityOS/serenity) project, although the author (kleines Filmröllchen) is a SerenityOS contributor. This project is under a separate license from SerenityOS itself and other terms may apply. If you have never heard of SerenityOS, this repo won't make sense to you.

Contrary to popular belief, it is not forbidden to create and/or distribute disk images for the SerenityOS operating system, colloquially referred to as "ISO images". However, as the project itself ["does not cater to non-technical users"](https://github.com/SerenityOS/serenity/blob/master/Documentation/FAQ.md#where-are-the-iso-images), no official images are provided. The "ISO images are forbidden/blasphemy/fbi open up" is more of a meme, because so many of the aforementioned non-technical users have asked for them.

# How to use

There are two parts to this project, and you can use both the raw script and the docker method.

The `create_image.sh` script builds SerenityOS and copies the disk image, runnable with QEMU, into the `monthly` and `nightly` repositories. While a nightly image is created for every date, overriding any existing build, a monthly image is only created if none for this month exists yet. This is useful for having the monthly build being at approximately the same state as the monthly updates that Andreas does on his [YouTube channel](https://www.youtube.com/c/AndreasKling): e.g. a build from 1st of June 2021, tagged for 2021-06, will be in about the same state as the master branch when Andreas records his update for May 2021 at the beginning of June.

The docker method will run the build in a safe containerized way, without requiring you to type `sudo`, that also doesn't require you to put unstable software on your base system. This is recommended as the setup is much easier.

## Prerequisites

This only works on Linux.

You need the SerenityOS project repository itself for either method.

```command
git clone https://github.com/SerenityOS/serenity.git /your/folder/of/choice
```

### Script

This builds SerenityOS and its toolchain on your system itself. Follow the [build instructions](https://github.com/SerenityOS/serenity/blob/master/Documentation/BuildInstructions.md) to find out what you need for that.

The environment variable `SERENITY_DIR` specifies the directory of the SerenityOS git repository and must be set in order for the script to work.

The script requires `sudo` permissions for creating the image, just as a normal SerenityOS build does.

### Docker

You need to have [Docker](https://www.docker.com/) installed for the docker method. This assumes you know how to use docker.

The docker image here depends on the [base image from the SerenityOS toolchain](https://github.com/SerenityOS/serenity/blob/master/Toolchain/Dockerfile). As the image is not available as a normal docker template (like ubuntu, debian etc.), you need to build it yourself. This image comes with a built toolchain and all the build tools ready-to-go. Tag it with `serenity` so that this project's Dockerfile can find it:

```command
sudo docker build -t serenity .
```

Then, you can build this project's docker image and run it.

```command
sudo docker build -t serenity-imager .
sudo docker run -v /serenity/out:/your/target/directory --rm serenity-imagertest
```

The volume on /serenity/out should be bound to a target directory you want the `monthly` and `nightly` folders to appear in. You can use this project'
s directory.

### Further usage

It is recommended that the docker run is executed once per day. You can setup a cronjob or a systemd timer or something similar for that. If you want to provide the images on a website, the monthly and nightly folders are suitable for symlinking to a webserver directory.

## License: MIT
