#!/bin/bash
set -e

VERSION=$1
APP_NAME="fluistern_app"
BUILD_DIR="build/linux/x64/release/bundle"
APPDIR="AppDir"

echo "Building AppImage for version $VERSION..."

# Create AppDir structure
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/lib"
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$APPDIR/usr/share/applications"

# Copy application files
cp -r "$BUILD_DIR"/* "$APPDIR/usr/bin/"

# Create desktop file
cat > "$APPDIR/usr/share/applications/$APP_NAME.desktop" << EOF
[Desktop Entry]
Name=Flüstern
Comment=Voice dictation app with AI formatting
Exec=fluistern_app
Icon=fluistern_app
Type=Application
Categories=Utility;AudioVideo;Audio;
Terminal=false
EOF

# Create a simple icon (placeholder - replace with actual icon if available)
cat > "$APPDIR/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png" << EOF
# Placeholder icon - will be replaced with actual icon
EOF

# Create AppRun script
cat > "$APPDIR/AppRun" << 'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"
cd "${HERE}/usr/bin"
exec ./fluistern_app "$@"
EOF

chmod +x "$APPDIR/AppRun"

# Copy desktop file and icon to AppDir root
cp "$APPDIR/usr/share/applications/$APP_NAME.desktop" "$APPDIR/"
cp "$APPDIR/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png" "$APPDIR/"

# Download appimagetool if not available
if [ ! -f "appimagetool-x86_64.AppImage" ]; then
    wget -q "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod +x appimagetool-x86_64.AppImage
fi

# Build AppImage
ARCH=x86_64 ./appimagetool-x86_64.AppImage "$APPDIR" "fluistern-linux-$VERSION.AppImage"

echo "AppImage created: fluistern-linux-$VERSION.AppImage"
