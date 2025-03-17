#!/bin/bash
set -euxo pipefail

# Disable Swap (Kubernetes requirement)
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab  # Ensure swap stays off

# Enable Kernel Modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# Set sysctl params required by Kubernetes
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system

# Install Required Packages
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl

# Add Kubernetes Repo
sudo mkdir -p /etc/apt/keyrings
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg \
  https://pkgs.k8s.io/core:/stable:/v1.29/deb/ / | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes Components
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl

# Enable kubelet service
sudo systemctl enable kubelet
