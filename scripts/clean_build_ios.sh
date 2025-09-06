#!/bin/bash

# Clean Build Script for iOS to fix crash issues
# Run this before building for App Store submission

echo "🧹 Starting clean build process for iOS..."

# Clean Flutter
echo "1. Cleaning Flutter build cache..."
flutter clean

# Clean iOS build files
echo "2. Cleaning iOS build files..."
rm -rf ios/build/
rm -rf ios/Pods/
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks/
rm -rf ios/Flutter/App.framework
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec

# Clean derived data (if running on macOS)
if [ -d ~/Library/Developer/Xcode/DerivedData ]; then
    echo "3. Cleaning Xcode DerivedData..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
fi

# Get dependencies
echo "4. Getting Flutter dependencies..."
flutter pub get

# Update iOS pods
echo "5. Updating iOS CocoaPods..."
cd ios
pod repo update
pod install --repo-update
cd ..

# Clean and get dependencies again
echo "6. Final Flutter pub get..."
flutter pub get

echo "✅ Clean build completed!"
echo ""
echo "🚀 Now you can build for iOS:"
echo "   flutter build ios --release --no-codesign"
echo ""
echo "📱 Or run on device:"
echo "   flutter run --release"
