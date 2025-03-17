#!/bin/bash
set -euxo pipefail

# Set Variables
NODENAME=$(hostname -s)
CONTROL_IP="192.168.56.100"
POD_CIDR="192.168.0.0/16"

# Pull Kubernetes images
sudo kubeadm config images pull

# Initialize Kubernetes Cluster
sudo kubeadm init --apiserver-advertise-address=$CONTROL_IP \
  --pod-network-cidr=$POD_CIDR \
  --node-name "$NODENAME"

# Configure kubectl for vagrant user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Save kubeadm join command
config_path="/vagrant/configs"
mkdir -p $config_path
sudo kubeadm token create --print-join-command > $config_path/join.sh
chmod +x $config_path/join.sh

# Install Calico CNI
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
