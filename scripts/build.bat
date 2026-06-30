@echo off
echo =========================================
echo   ContentOS - Build Script (Windows)
echo =========================================

cd /d "%~dp0mobile" || exit 1

echo.
echo 1. Getting dependencies...
call flutter pub get

echo.
echo 2. Running code analysis...
call flutter analyze --no-pub

echo.
echo 3. Running tests...
call flutter test --no-pub

echo.
echo 4. Cleaning previous builds...
call flutter clean
call flutter pub get

echo.
echo =========================================
echo   Building Release Artifacts
echo =========================================

echo.
echo 5. Building APK (Release)...
call flutter build apk --release --split-per-abi --no-tree-shake-icons
echo    -^> build\app\outputs\flutter-apk\

echo.
echo 6. Building App Bundle (Release)...
call flutter build appbundle --release --no-tree-shake-icons
echo    -^> build\app\outputs\bundle\release\

echo.
echo 7. Building Web (Release)...
call flutter build web --release --no-tree-shake-icons
echo    -^> build\web\

echo.
echo =========================================
echo   Build Complete!
echo =========================================
echo.
echo APK files:
dir /b build\app\outputs\flutter-apk\*.apk 2>nul || echo    No APK files found
echo.
echo AAB file:
dir /b build\app\outputs\bundle\release\*.aab 2>nul || echo    No AAB file found
echo.
echo Web build:
dir /b build\web\index.html 2>nul || echo    Web build not found
echo.
echo =========================================
