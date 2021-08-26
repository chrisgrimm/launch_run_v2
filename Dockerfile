# syntax=docker/dockerfile:1

FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu18.04 AS cuda
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/lib/x86_64-linux-gnu

# install python
RUN apt -y update
RUN apt install -y software-properties-common
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt install -y python3.8-dev
RUN apt install -y python3-pip

ARG ssh_prv_key
ARG ssh_pub_key
ARG known_hosts
ARG uid
ARG gid
ARG name
ARG password

ENV PASSWORD=$password
ENV CONTAINER_NAME=$name
WORKDIR /app

COPY ./hostsfile.txt ./hostsfile.txt
COPY ./launch_cluster.py ./launch_cluster.py

RUN apt install -y git 
RUN apt install -y openssh-server 
RUN apt install -y libglib2.0-0 
RUN apt install -y libgtk2.0-0 
RUN apt install -y libgtk2.0-dev 
RUN apt install -y libgl1-mesa-glx 
RUN apt install -y rsync p
RUN apt install -y ssh 
RUN apt install -y vim 
RUN apt install -y tmux

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
RUN python3.8 -m pip install --upgrade pip
RUN pip install ray[default]
RUN pip install ray[tune]
RUN pip install parallel-ssh
RUN pip install tqdm
ENV RAY_BACKEND_LOG_LEVEL=error
CMD /bin/bash
