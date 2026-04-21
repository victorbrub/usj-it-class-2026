# Apache Cassandra Installation on macOS

# Author: Víctor Barceló

## Overview

This guide covers installing Apache Cassandra on macOS using Homebrew. Both Apple Silicon (M1/M2/M3) and Intel Mac architectures are supported.

---

## Prerequisites

- macOS 12 (Monterey) or later
- Administrator privileges
- Internet access
- Terminal application (Terminal.app or iTerm2)

---

## Step 1 — Install Homebrew

Homebrew is the package manager used to install Cassandra and its dependencies.

Check if Homebrew is already installed:

```bash
brew --version
```

If not installed, run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, follow any instructions printed to the terminal to add Homebrew to your `PATH`. Then update it:

```bash
brew update
```

---

## Step 2 — Install Java 11

Cassandra requires Java 11. Install it via Homebrew:

```bash
brew install openjdk@11
```

Add Java 11 to your `PATH`. The correct path depends on your Mac architecture:

**Apple Silicon (M1/M2/M3):**

```bash
echo 'export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Intel:**

```bash
echo 'export PATH="/usr/local/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Verify the installation:

```bash
java -version
```

Expected output (version may vary):

```
openjdk version "11.x.x" ...
```

---

## Step 3 — Install Apache Cassandra

```bash
brew install cassandra
```

---

## Step 4 — Start the Cassandra Service

```bash
brew services start cassandra
```

Wait approximately 30 seconds for the node to fully initialize, then verify it is running:

```bash
nodetool status
```

Expected output:

```
Datacenter: datacenter1
=======================
Status=Up/Normal
-- Address    Load      Tokens  ...
UN  127.0.0.1  ...
```

`UN` means the node is **U**p and **N**ormal.

---

## Step 5 — Connect with cqlsh

```bash
cqlsh
```

You should see the CQL shell prompt:

```
Connected to Test Cluster at 127.0.0.1:9042
[cqlsh 6.x.x | Cassandra 4.x.x | CQL spec 3.4.x | Native protocol v5]
Use HELP for help.
cqlsh>
```

Type `exit` to quit the shell.

---

## Automated Installation

A shell script is provided to perform all of the above steps automatically:

```bash
bash install_cassandra_mac.sh
```

---

## Service Management

| Action   | Command                            |
|----------|------------------------------------|
| Start    | `brew services start cassandra`    |
| Stop     | `brew services stop cassandra`     |
| Restart  | `brew services restart cassandra`  |
| Status   | `brew services info cassandra`     |

---

## File Locations

| Resource       | Apple Silicon path                                      | Intel path                                         |
|----------------|---------------------------------------------------------|----------------------------------------------------|
| Configuration  | `/opt/homebrew/etc/cassandra/cassandra.yaml`            | `/usr/local/etc/cassandra/cassandra.yaml`          |
| Log directory  | `/opt/homebrew/var/log/cassandra/`                      | `/usr/local/var/log/cassandra/`                    |
| Data directory | `/opt/homebrew/var/lib/cassandra/`                      | `/usr/local/var/lib/cassandra/`                    |

---

## Key Connection Details

| Parameter    | Value       |
|--------------|-------------|
| Host         | `127.0.0.1` |
| CQL Port     | `9042`      |
| Default user | `cassandra` |

---

## Troubleshooting

### Cassandra fails to start

Check the logs for errors:

```bash
# Apple Silicon
tail -100 /opt/homebrew/var/log/cassandra/system.log

# Intel
tail -100 /usr/local/var/log/cassandra/system.log
```

### `nodetool status` returns "Connection refused"

The node has not finished starting. Wait a few more seconds and retry.

### Java version not recognized

Ensure the `PATH` update was applied correctly and reload your shell:

```bash
source ~/.zshrc
java -version
```

### Port 9042 already in use

Check what process is using the port and stop it before starting Cassandra:

```bash
lsof -i :9042
```

---

## Uninstallation

To remove Cassandra and its data:

```bash
brew services stop cassandra
brew uninstall cassandra
rm -rf /opt/homebrew/var/lib/cassandra   # Apple Silicon
rm -rf /opt/homebrew/var/log/cassandra   # Apple Silicon
```

For Intel Macs, replace `/opt/homebrew` with `/usr/local`.
