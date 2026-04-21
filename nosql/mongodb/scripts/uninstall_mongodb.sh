#!/bin/bash

# Uninstall MongoDB on Debian/Ubuntu Linux

set -e

echo "Stopping MongoDB service..."
sudo systemctl stop mongod 2>/dev/null || true
sudo systemctl disable mongod 2>/dev/null || true

echo "Removing MongoDB packages..."
sudo apt purge -y mongodb-org mongodb-org-database mongodb-org-server \
    mongodb-org-mongos mongodb-org-tools mongodb-mongosh 2>/dev/null || true
sudo apt autoremove -y

echo "Removing MongoDB data, logs, and config..."
sudo rm -rf /var/lib/mongodb/
sudo rm -rf /var/log/mongodb/
sudo rm -f /etc/mongod.conf

echo "Removing MongoDB APT repository..."
sudo rm -f /etc/apt/sources.list.d/mongodb-org*.list
sudo rm -f /usr/share/keyrings/mongodb-server*.gpg

sudo apt update

echo ""
echo "MongoDB has been fully uninstalled."
