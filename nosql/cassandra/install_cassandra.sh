#!/bin/bash

# Install Apache Cassandra on Debian/Ubuntu Linux
# Requires: Java 11+

set -e

CASSANDRA_VERSION="41x"  # Adjust to target release series (40x, 41x, 50x)

echo "Updating package list..."
sudo apt update

# Install Java (required by Cassandra)
echo "Installing Java 11..."
sudo apt install -y openjdk-11-jdk

# Verify Java installation
java -version

# Add Apache Cassandra repository key
echo "Adding Cassandra repository..."
sudo mkdir -p /etc/apt/keyrings
curl https://downloads.apache.org/cassandra/KEYS \
    | sudo tee /etc/apt/keyrings/apache-cassandra.asc > /dev/null

# Add the repository
echo "deb [signed-by=/etc/apt/keyrings/apache-cassandra.asc] \
https://debian.cassandra.apache.org $CASSANDRA_VERSION main" \
    | sudo tee /etc/apt/sources.list.d/cassandra.sources.list

sudo apt update

# Install Cassandra
echo "Installing Cassandra..."
sudo apt install -y cassandra

# Start the Cassandra service
echo "Starting Cassandra service..."
sudo systemctl start cassandra

# Enable Cassandra to start on boot
sudo systemctl enable cassandra

# Wait for Cassandra to fully start
echo "Waiting for Cassandra to start (30 seconds)..."
sleep 30

# Check service status
sudo systemctl status cassandra --no-pager

# Verify cluster status
echo "Checking cluster node status..."
nodetool status

echo ""
echo "Cassandra installation complete!"
echo "Version installed:"
cassandra -v

echo ""
echo "Connect with: cqlsh"
echo "Default port:  9042"
echo "Config file:   /etc/cassandra/cassandra.yaml"
echo "Log directory: /var/log/cassandra/"
echo "Data directory: /var/lib/cassandra/"
