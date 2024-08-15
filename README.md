# Docker Master

Building containers made easy!

## Overview

This project is a simple bash wrapper around the `docker` command line tool. It is designed to make working with containers easier via running builds & deployments from a configuration file.

## Prerequisites

Before running `dockmaster.sh` first confirm that you have `docker` installed:

```bash
docker --version
```
If you do not have `docker` installed, please follow the instructions [here](https://docs.docker.com/get-docker/).

## Configuration

Before running the `dockmaster.sh` you need to prepare a configuration file, which is a simple `.ini` file. Refer to the table below for detailed information on config sections and their parameters.

<br>
<div align="center">

| Section    | Parameter         | Description |
|:----------:|:-----------------:|:-----------:|
| `env`      | -                 | Environmental variables passed to the build. Define as many as needed; all will be available in your container's environment. |
| `execution`| `devices`         | List of GPU devices to run the container on. Leave empty for CPU, use `all` for all available devices. |
|            | `cmd_scripts`     | List of scripts to execute in the container. Optional if your Dockerfiles already contain scripts to run. |
| `docker`   | `dockerfiles`     | List of paths to Dockerfiles you want to build. |
|            | `image_names`     | List of names for the images that will be built. |
|            | `container_names` | List of names for the containers that will be run. |
|            | `run_containers`  | Create containers from images and run them. |
|            | `delete_containers`| Delete containers after they finish running. |
|            | `delete_images`   | Delete images after containers finish running. |
|            | `run_as_daemon`   | Run containers as daemons (disables `delete_containers` and `delete_images`). |

</div>
<br>

> [!WARNING]
> When providing image & container names and dockerfiles, please make sure that their lengths are matching (same goes for script names and devices if you plan on using them)

## Usage

Building and deploying containers with `dockmaster.sh` is very simple:

```bash
bash dockmaster.sh -c config.ini
```

Based on your configuration the script will:
* Create environmental arguments for your build
* Build images
* Run containers and delete them when finished (or run as deamons and exit providing their IDs)

Check out the [provided example](./example/) to get a better understanding how to set up the configuration and use this tool.
