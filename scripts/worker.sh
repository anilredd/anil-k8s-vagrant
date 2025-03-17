#!/bin/bash
set -euxo pipefail

# Get Join Command from Master
JOIN_CMD=$(cat /vagrant/configs/join.sh)

# Execute Join Command
sudo $JOIN_CMD