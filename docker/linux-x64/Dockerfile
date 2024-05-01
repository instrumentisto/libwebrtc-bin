# syntax = docker/dockerfile:experimental
FROM ubuntu:22.04

RUN rm -f /etc/apt/apt.conf.d/docker-clean \
 && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
    > /etc/apt/apt.conf.d/keep-cache

COPY scripts/ /root/scripts/
RUN /root/scripts/apt_install.sh

COPY build/ /root/build/
COPY Makefile VERSION /root/

RUN cd /root/ \
 && make USE_CCACHE=0 -C build linux-x64.fetch
