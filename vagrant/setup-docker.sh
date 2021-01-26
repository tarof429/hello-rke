#!/bin/sh

# This script will install docker

DOCKER_VERSION=19.03.9

yum -y install yum-utils

# Setup repository
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# Install docker
yum install -y docker-ce-${DOCKER_VERSION} docker-ce-cli-${DOCKER_VERSION} containerd.io

# Add vagrant to the docker group
usermod -aG docker vagrant

# Enable remote access for rke
sed 's|.*ExecStart.*|ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:4243 --containerd=/run/containerd/containerd.sock|' /usr/lib/systemd/system/docker.service > docker.service

mv ./docker.service /usr/lib/systemd/system/docker.service

systemctl daemon-reload

systemctl start docker

systemctl enable docker

# Test remote access
curl -X GET http://localhost:4243/images/json

# Post networking setup required by RKE
sysctl net.bridge.bridge-nf-call-iptables=1