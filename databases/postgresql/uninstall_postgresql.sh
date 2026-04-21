#!/bin/bash

# Uninstall PostgreSQL on Debian/Ubuntu Linux

set -e

echo "Stopping PostgreSQL service..."
sudo systemctl stop postgresql 2>/dev/null || true
sudo systemctl disable postgresql 2>/dev/null || true

echo "Removing PostgreSQL packages..."
sudo apt purge -y postgresql postgresql-* postgresql-contrib 2>/dev/null || true
sudo apt autoremove -y

echo "Removing PostgreSQL data, logs, and config..."
sudo rm -rf /var/lib/postgresql/
sudo rm -rf /var/log/postgresql/
sudo rm -rf /etc/postgresql/

echo "Removing PostgreSQL APT repository (if added manually)..."
sudo rm -f /etc/apt/sources.list.d/pgdg.list
sudo rm -f /usr/share/keyrings/postgresql-keyring.gpg

sudo apt update

echo ""
echo "PostgreSQL has been fully uninstalled."
