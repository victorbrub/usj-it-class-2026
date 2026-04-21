#!/bin/bash

# Install Apache Cassandra on macOS
# Requires: Homebrew (https://brew.sh)

set -e

echo "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Update Homebrew
echo "Updating Homebrew..."
brew update

# Install Java (required by Cassandra)
echo "Installing Java 11..."
brew install openjdk@11

# Add Java to PATH
echo "Configuring Java environment..."
echo 'export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"

# For Intel Macs the path may differ:
# echo 'export PATH="/usr/local/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc

# Verify Java installation
java -version

# Install Cassandra
echo "Installing Apache Cassandra..."
brew install cassandra

# Start Cassandra service
echo "Starting Cassandra service..."
brew services start cassandra

# Wait for Cassandra to fully start
echo "Waiting for Cassandra to start (30 seconds)..."
sleep 30

# Check cluster status
echo "Checking cluster node status..."
nodetool status

echo ""
echo "Cassandra installation complete!"
echo "Version installed:"
cassandra -v

echo ""
echo "Connect with: cqlsh"
echo "Default port:  9042"
echo "Config file:   /opt/homebrew/etc/cassandra/cassandra.yaml"
echo "Log directory: /opt/homebrew/var/log/cassandra/"
echo "Data directory: /opt/homebrew/var/lib/cassandra/"
echo ""
echo "Useful commands:"
echo "  Start:   brew services start cassandra"
echo "  Stop:    brew services stop cassandra"
echo "  Restart: brew services restart cassandra"
echo "  Status:  brew services info cassandra"
