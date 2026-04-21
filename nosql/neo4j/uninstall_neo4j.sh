#!/bin/bash

# Uninstall Neo4j on Debian/Ubuntu Linux

set -e

echo "Stopping Neo4j service..."
sudo systemctl stop neo4j 2>/dev/null || true
sudo systemctl disable neo4j 2>/dev/null || true

echo "Removing Neo4j package..."
sudo apt purge -y neo4j 2>/dev/null || true
sudo apt autoremove -y

echo "Removing Neo4j data, logs, and config..."
sudo rm -rf /var/lib/neo4j/
sudo rm -rf /var/log/neo4j/
sudo rm -rf /etc/neo4j/

echo "Removing Neo4j APT repository..."
sudo rm -f /etc/apt/sources.list.d/neo4j.list
sudo rm -f /usr/share/keyrings/neo4j.gpg

sudo apt update

echo ""
echo "Neo4j has been fully uninstalled."
