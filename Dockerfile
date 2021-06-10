# Original Author : https://github.com/Crazy-Piri/pvsneslib-docker
ARG DOCKER_IMAGE=debian:buster-slim
FROM $DOCKER_IMAGE as builder

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install make python linux-libc-dev binutils gcc g++ git wget cmake -y && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/vhelin/wla-dx /wla-dx \
	&& cd /wla-dx \
	&& mkdir build && cd build \
	&& cmake .. \
	&& cmake --build . --config Release -- -j$(nproc) \
	&& cmake -P cmake_install.cmake

RUN git clone https://github.com/boldowa/snesbrr /snesbrr

RUN git clone https://github.com/alekmaul/pvsneslib /c/snesdev\
	&& cd /c/snesdev\
	&& cp /c/snesdev/devkitsnes/snes_rules /c/snesdev/devkitsnes/snes_rules.orig\
	&& sed 's:\\\\:/:g' /c/snesdev/devkitsnes/snes_rules.orig >/c/snesdev/devkitsnes/snes_rules\
	&& cd /c/snesdev/compiler/tcc-65816\
	&& rm -rf 816-tcc.exe\
	&& ./configure\
	&& make 816-tcc -j$(nproc)\
	&& cp 816-tcc /c/snesdev/devkitsnes/bin/816-tcc

# /c/snesdev/devkitsnes/bin/816-opt.py is expecting python to be in /c/Python27/python
RUN mkdir -p /c/Python27/ && ln -sf /usr/bin/python /c/Python27/python

RUN cd /c/snesdev/tools/constify \
	&& cp Makefile Makefile.orig\
	&& sed 's:-lregex::g' Makefile.orig >Makefile\
	&& make all -j$(nproc) \
	&& cp constify /bin/constify

WORKDIR /c/snesdev/tools/snestools
RUN make all -j$(nproc)
RUN cp snestools /c/snesdev/devkitsnes/tools/snestools

WORKDIR /c/snesdev/tools/gfx2snes
RUN make all -j$(nproc)
RUN cp gfx2snes /c/snesdev/devkitsnes/tools/gfx2snes

WORKDIR /c/snesdev/tools/bin2txt
COPY patch/bin2txt.c /c/snesdev/tools/bin2txt/bin2txt.c
RUN make all -j$(nproc)
RUN cp bin2txt /c/snesdev/devkitsnes/tools/bin2txt

WORKDIR /c/snesdev/tools/smconv
RUN make all -j$(nproc)
RUN cp smconv /c/snesdev/devkitsnes/tools/smconv

WORKDIR /snesbrr/src
RUN make all -j$(nproc)
RUN cp snesbrr /c/snesdev/devkitsnes/tools/snesbrr

RUN chmod 777 /c/snesdev/devkitsnes/bin/*

ARG DOCKER_IMAGE=i386/ubuntu:focal
FROM $DOCKER_IMAGE as runtime

LABEL author="Bensuperpc <bensuperpc@gmail.com>"
LABEL mantainer="Bensuperpc <bensuperpc@gmail.com>"

ARG BUILD_VERSION="1.0.0"
ENV BUILD_VERSION=$BUILD_VERSION

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install make python2 --no-install-recommends -y && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /c /c
COPY --from=builder /usr/local/bin /usr/local/bin

ENV PATH="/c/snesdev/devkitsnes/bin:${PATH}"

ENV PVSNESLIB_HOME="/c/snesdev/"

# Run tests
RUN cd /c/snesdev/snes-examples && make audio debug games graphics hello_world \
	pads random scoring sram testregion timer typeconsole -j$(nproc) && make clean

WORKDIR /src

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="bensuperpc/pvsneslib" \
      org.label-schema.description="build pvsneslib compiler" \
      org.label-schema.version=$BUILD_VERSION \
      org.label-schema.vendor="Bensuperpc" \
      org.label-schema.url="http://bensuperpc.com/" \
      org.label-schema.vcs-url="https://github.com/Bensuperpc/pvsneslib" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.docker.cmd="docker build -t bensuperpc/pvsneslib -f Dockerfile ."