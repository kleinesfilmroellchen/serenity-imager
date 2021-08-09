# SerenityOS Image creation system

A simple system to automatically build images for SerenityOS. Intended to be used with internet distribution, [just as the author does himself](https://klfr.spdns.de/serenity-iso).

## Disclaimer

This project is not officially associated with the [SerenityOS](https://github.com/SerenityOS/serenity) project, although the author (kleines Filmröllchen) is a SerenityOS contributor. This project is under a separate license from SerenityOS itself and other terms may apply. If you have never heard of SerenityOS, this repo won't make sense to you.

Contrary to popular belief, it is not forbidden to create and/or distribute disk images for the SerenityOS operating system, colloquially referred to as "ISO images". However, as the project itself ["does not cater to non-technical users"](https://github.com/SerenityOS/serenity/blob/master/Documentation/FAQ.md#where-are-the-iso-images), no official images are provided. The "ISO images are forbidden/blasphemy/fbi open up" is more of a meme, because so many of the aforementioned non-technical users have asked for them.

# How to use

There are two parts to this project, and you can use both the raw script and the docker method.

The `create_image.sh` script builds SerenityOS and copies the disk image, runnable with QEMU, into the `monthly` and `nightly` repositories. While a nightly image is created for every date, overriding any existing build, a monthly image is only created if none for this month exists yet. This is useful for having the monthly build being at approximately the same state as the monthly updates that Andreas does on his [YouTube channel](https://www.youtube.com/c/AndreasKling): e.g. a build from 31st of May 2021, tagged for 2021-05, will be in about the same state as the master branch when Andreas records his update for May 2021 at the beginning of June.

The docker method will run the build in a safe containerized way, without requiring you to type `sudo`, that also doesn't require you to put unstable software on your base system. This is recommended as the setup is much easier.

## Prerequisites

This only works on Linux.

You need the SerenityOS project repository itself for either method.

```command
git clone https://github.com/SerenityOS/serenity.git /your/folder/of/choice
```

## Script `create_image.sh`

This builds SerenityOS and its toolchain on your system itself. Follow the [build instructions](https://github.com/SerenityOS/serenity/blob/master/Documentation/BuildInstructions.md) to find out what you need for that.

The environment variable `SERENITY_DIR` specifies the directory of the SerenityOS git repository and must be set in order for the script to work.

The script requires `sudo` permissions for creating the image, just as a normal SerenityOS build does.

## Docker

You need to have [Docker](https://www.docker.com/) installed for the docker method. This assumes you know how to use docker.

The docker image here depends on a more basic docker image that contains "only SerenityOS", but it is slightly customized from the [base image from the SerenityOS toolchain](https://github.com/SerenityOS/serenity/blob/master/Toolchain/Dockerfile). To not break other people's workflow, this image is provided as SerenityDockerfile, and you can replace the base dockerfile with it. `build_dockers.sh` does this automatically. If you're doing it manually, you have to tag the image with `serenity`:

```command
sudo docker build -t serenity .
```

Then, you can build this project's docker image and run it.

```command
sudo docker build -t serenity-imager .
sudo docker run -v /your/target/directory:/serenity/out --rm serenity-imagertest
```

The volume on /serenity/out should be bound to a target directory you want the `monthly` and `nightly` folders to appear in. You can use this project's directory.

## Automation (with Docker)

There are two additional scripts that automate the above processes for you.

- `build_dockers.sh` will build and tag both docker images correctly. For this, it requires the environment variables `SERENITY_GIT_DIR` for the SerenityOS git directory (like `SERENITY_DIR` above) and `SERENITY_IMAGER_DIR` for this git repository. This means that the script runs correctly from any folder, making it suitable for use in systemd services.
- `run_docker.sh` will run the docker container build, again requiring `SERENITY_IMAGER_DIR` to be able to run out of any directory. The monthly and nightly image folders will be mounted into the monthly and nightly folders in this repo.

### Systemd

How you configure systemd to do the automation heavily depends on how exactly you want it to be scheduled in relation to the rest of your system. The following will explain a full stack that uses four units: A `serenity-builder` service and timer that run a weekly docker image and toolchain build, and `serenity-imager` service and timer that run a daily Serenity build and image creation. For both timers, adjust `OnCalendar` to your liking. (Also, these unit files are probably horrific.)

```systemd
# serenity-builder.timer
[Unit]
Description=Builds the SerenityOS toolchain weekly

[Timer]
OnCalendar=weekly
AccuracySec=1hour
Unit=serenity-builder.service

[Install]
WantedBy=timers.target
```

```systemd
# serenity-builder.service
[Unit]
Description=Builds the SerenityOS Toolchain

[Service]
ExecStart=/this/repo/build_dockers.sh
Environment="SERENITY_GIT_DIR=/the/serenitos/repo"
Environment="SERENITY_IMAGER_DIR=/this/repo"
```

```systemd
# serenity-imager.timer
[Unit]
Description=Runs the SerenityOS nightly build every 24 hours

[Timer]
OnCalendar=daily
AccuracySec=1hour
Unit=serenity-imager.service

[Install]
WantedBy=timers.target
```

```systemd
# serenity-imager.service
[Unit]
Description=Builds SerenityOS and creates new nightly and monthly images as required

[Service]
ExecStart=/this/repo/run_docker.sh
Environment="SERENITY_IMAGER_DIR=/this/repo"
Environment="SERENITY_GIT_DIR=/the/serenityos/repo"
```

### Cron

I don't know how to use cronjobs and have not used it with this project. If you do, please open a PR with instructions on how to do the above automation with cron.

## Further usage

It is recommended that the docker run is executed once per day. You can setup a cronjob or a systemd timer or something similar for that. If you want to provide the images on a website, the monthly and nightly folders are suitable for symlinking to a webserver directory.

# License: MIT
