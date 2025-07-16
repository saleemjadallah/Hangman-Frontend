#!/bin/bash
set -e

echo "📦 Installing Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1 /opt/build/flutter
export PATH="/opt/build/flutter/bin:$PATH"

echo "🔧 Flutter Doctor..."
flutter doctor -v

echo "📱 Configuring Flutter for web..."
flutter config --enable-web

echo "📥 Getting dependencies..."
flutter pub get

echo "🏗️ Building for production..."
flutter build web --release \
  --web-renderer html \
  --no-tree-shake-icons \
  --base-href /

echo "✅ Build complete!"