# pvsneslib-docker
[![pvsneslib-docker](https://github.com/Bensuperpc/pvsneslib-docker/actions/workflows/main.yml/badge.svg)](https://github.com/Bensuperpc/pvsneslib-docker/actions/workflows/main.yml) <img alt="Docker Image Size (latest by date)" src="https://img.shields.io/docker/image-size/bensuperpc/pvsneslib">

## build the from your local project path
```
docker run --rm -v "${PWD}":/src/ -it bensuperpc/pvsneslib
```

Or use this docker image:
https://hub.docker.com/r/bensuperpc/pvsneslib

## build docker image
```
make linux/386
```

#### Note for Windows: Replace `${PWD}` with `%cd%` in all commands
#### Exemples path : /c/snesdev/snes-examples

Sample projects are available at https://github.com/alekmaul/pvsneslib

Add Original author: https://github.com/Crazy-Piri/pvsneslib-docker
