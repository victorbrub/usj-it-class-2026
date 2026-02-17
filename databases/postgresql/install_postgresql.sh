#!/bin/bash

# Update package list
sudo apt update

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Start PostgreSQL service
sudo systemctl start postgresql

# Enable PostgreSQL to start on boot
sudo systemctl enable postgresql

# Check status
sudo systemctl status postgresql

# Optional: Create a new database user
# sudo -u postgres createuser --interactive

# Optional: Create a new database
# sudo -u postgres createdb mydatabase

echo "PostgreSQL installation complete!"
echo "Version installed:"
psql --version