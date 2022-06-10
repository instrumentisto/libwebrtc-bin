FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN rm -f /etc/apt/apt.conf.d/docker-clean \
 && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
    > /etc/apt/apt.conf.d/keep-cache

RUN apt update \
 && apt upgrade -y \
 && apt install -y build-essential \
                   curl \
                   git \
                   libncurses5 \
                   lsb-release \
                   openjdk-11-jdk-headless \
                   python \
                   pkg-config \
                   rsync \
                   sudo \
                   time \
                   unzip

RUN update-java-alternatives -s java-1.11.0-openjdk-amd64

COPY build/ /root/build/
COPY Makefile VERSION LICENSE /root/
COPY scripts/ /root/scripts/

RUN cd /root/ \
 && make USE_CCACHE=0 -C build android.fetch
