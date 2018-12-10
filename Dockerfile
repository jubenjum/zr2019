# Build docker with :
# docker build -t zs19 .
# After installation , run :
# docker run --name mydocker -v "$PWD":/home/zs2019 -it zs19 bash

#build a docker image with the tool used on the zero speech challenge
from ubuntu:16.04

MAINTAINER CoML <zerospeech2019@gmail.com>

# language agnostic locales
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# install system dependencies
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y build-essential git wget
RUN apt-get install -y cmake
RUN apt-get install -y g++
RUN apt-get install -y automake
RUN apt-get install -y csh
RUN apt-get install -y vim
RUN apt-get install -y sox
RUN mkdir /home/zs2019

# install Miniconda
ENV HOME=/home/zs2019
ENV PATH=$HOME/miniconda3/bin:$PATH
ENV USER=root


# the default working directory
WORKDIR $HOME

COPY . $HOME/

