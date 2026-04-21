#!/bin/bash

# Uninstall Apache Cassandra on Debian/Ubuntu Linux

set -e

echo "Stopping Cassandra service..."
sudo systemctl stop cassandra 2>/dev/null || true
sudo systemctl disable cassandra 2>/dev/null || true

echo "Removing Cassandra package..."
sudo apt purge -y cassandra 2>/dev/null || true
sudo apt autoremove -y

echo "Removing Cassandra data, logs, and config..."
sudo rm -rf /var/lib/cassandra/
sudo rm -rf /var/log/cassandra/
sudo rm -rf /etc/cassandra/

echo "Removing Cassandra APT repository..."
sudo rm -f /etc/apt/sources.list.d/cassandra.sources.list
sudo rm -f /etc/apt/keyrings/apache-cassandra.asc

sudo apt update

echo ""
echo "Cassandra has been fully uninstalled."
