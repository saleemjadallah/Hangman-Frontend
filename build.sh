#!/bin/bash
set -e

echo "Installing Flutter..."

# Download Flutter
cd /tmp
wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz
tar xf flutter_linux_3.19.0-stable.tar.xz

# Add Flutter to PATH
export PATH="$PATH:/tmp/flutter/bin"

# Return to project directory
cd $NETLIFY_BUILD_BASE

# Verify Flutter installation
flutter --version

# Enable web support
flutter config --enable-web

# Get dependencies
echo "Installing dependencies..."
flutter pub get

# Build the web app
echo "Building web app..."
flutter build web --release

echo "Build complete!"