#!/bin/bash

echo "========================================="
echo "  ContentOS - Build Script"
echo "========================================="

cd "$(dirname "$0")/mobile" || exit 1

echo ""
echo "1. Getting dependencies..."
flutter pub get

echo ""
echo "2. Running code analysis..."
flutter analyze --no-pub

echo ""
echo "3. Running tests..."
flutter test --no-pub

echo ""
echo "4. Cleaning previous builds..."
flutter clean
flutter pub get

echo ""
echo "========================================="
echo "  Building Release Artifacts"
echo "========================================="

echo ""
echo "5. Building APK (Release)..."
flutter build apk --release --split-per-abi --no-tree-shake-icons
echo "   -> build/app/outputs/flutter-apk/"

echo ""
echo "6. Building App Bundle (Release)..."
flutter build appbundle --release --no-tree-shake-icons
echo "   -> build/app/outputs/bundle/release/"

echo ""
echo "7. Building Web (Release)..."
flutter build web --release --no-tree-shake-icons
echo "   -> build/web/"

echo ""
echo "========================================="
echo "  Build Complete!"
echo "========================================="
echo ""
echo "APK files:"
ls -la build/app/outputs/flutter-apk/*.apk 2>/dev/null || echo "  No APK files found"
echo ""
echo "AAB file:"
ls -la build/app/outputs/bundle/release/*.aab 2>/dev/null || echo "  No AAB file found"
echo ""
echo "Web build:"
ls -la build/web/index.html 2>/dev/null || echo "  Web build not found"
echo ""
echo "========================================="
