#!/bin/bash

# Uninstall Redis on Debian/Ubuntu Linux

set -e

echo "Stopping Redis service..."
sudo systemctl stop redis-server 2>/dev/null || true
sudo systemctl disable redis-server 2>/dev/null || true

echo "Removing Redis package..."
sudo apt purge -y redis redis-server redis-tools 2>/dev/null || true
sudo apt autoremove -y

echo "Removing Redis data and config..."
sudo rm -rf /var/lib/redis/
sudo rm -rf /var/log/redis/
sudo rm -f /etc/redis/redis.conf
sudo rm -rf /etc/redis/

echo "Removing Redis APT repository (if added manually)..."
sudo rm -f /etc/apt/sources.list.d/redis.list
sudo rm -f /usr/share/keyrings/redis-archive-keyring.gpg

sudo apt update

echo ""
echo "Redis has been fully uninstalled."
