#!/bin/bash
set -e

# Install busybox (for Ubuntu 22.04+)
apt-get update -y
apt-get install -y busybox-static

# Create dir
mkdir -p /var/www/html

echo "Hello, World from $(hostname)" > /var/www/html/index.html

# Run simple http server
nohup busybox httpd -f -p ${server_port} -h /var/www/html &
