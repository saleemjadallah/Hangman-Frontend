#!/bin/bash
set -e

echo "Starting Flutter installation..."
echo "Current directory: $(pwd)"
echo "Build base: $NETLIFY_BUILD_BASE"

# Check if wget is available, if not use curl
if command -v wget &> /dev/null; then
    echo "Using wget to download Flutter..."
    cd /tmp
    wget -O flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz
else
    echo "Using curl to download Flutter..."
    cd /tmp
    curl -L -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz
fi

echo "Extracting Flutter..."
tar xf flutter.tar.xz

# Add Flutter to PATH
export PATH="/tmp/flutter/bin:$PATH"

# Return to project directory
cd "$NETLIFY_BUILD_BASE"

# Verify Flutter installation
echo "Verifying Flutter installation..."
flutter --version

# Enable web support
flutter config --enable-web --no-analytics

# Get dependencies
echo "Installing dependencies..."
flutter pub get

# Build the web app
echo "Building web app..."
flutter build web --release

echo "Build complete!"