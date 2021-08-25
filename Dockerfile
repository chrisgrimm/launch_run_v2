# syntax=docker/dockerfile:1

FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu18.04 AS cuda
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/lib/x86_64-linux-gnu

# install python
RUN apt -y update && \
    apt install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt install -y python3.8-dev && \
    apt install -y python3-pip && \
    python3.8 -m pip install --upgrade pip

ARG ssh_prv_key
ARG ssh_pub_key
ARG known_hosts
ARG uid
ARG gid
ARG redis_port
ARG name

ENV REDIS_PORT=$redis_port
ENV NODE_NAME=$name

WORKDIR /app

COPY ./hostsfile.txt ./hostsfile.txt
COPY ./run_ray_head.py ./run_ray_head.py

RUN apt install -y git openssh-server libglib2.0-0 libgtk2.0-dev libgl1-mesa-glx rsync pssh vim tmux

## set up ssh directory
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

# Add the keys and set permissions
RUN echo "$ssh_prv_key" > /root/.ssh/id_rsa && \
    echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub

# install requirements
RUN python3.8 -m pip install --upgrade pip; pip install ray[default] ray[tune]
ENV RAY_BACKEND_LOG_LEVEL=error
CMD python3.8 run_ray_head.py $REDIS_PORT && /bin/bash
