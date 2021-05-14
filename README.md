# pvsneslib-docker

## build the from your local project path
```
docker run --rm -v "${PWD}":/src/ -it bensuperpc/pvsneslib
make
```

## build docker image
```
docker build -t bensuperpc/pvsneslib .
```

#### Note for Windows: Replace `${PWD}` with `%cd%` in all commands
#### Exemples path : /c/snesdev/snes-examples

Sample projects are available at https://github.com/alekmaul/pvsneslib

