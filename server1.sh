#!/bin/bash
mkdir -p ~/zato-docker-srv1-dev && cd ~/zato-docker-srv1-dev \
    && wget https://zato.io/download/docker/2.0/components/server1/Dockerfile \
    && wget https://zato.io/download/docker/2.0/components/server1/zato_server.config
#$ sudo docker build --no-cache -t zato-srv1-2.0.7 .
