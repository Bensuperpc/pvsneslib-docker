# pvsneslib-docker

## build the from your local project path
```
docker run --rm -v "${PWD}":/src/ -it bensuperpc/pvsneslib
```

## build docker image
```
make linux/386
```

#### Note for Windows: Replace `${PWD}` with `%cd%` in all commands
#### Exemples path : /c/snesdev/snes-examples

Sample projects are available at https://github.com/alekmaul/pvsneslib

