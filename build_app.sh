#!/bin/bash
set -e

# Increment Build Number
BUILD_FILE=".build_number"
if [ -f "$BUILD_FILE" ]; then
    BUILD_NUMBER=$(cat "$BUILD_FILE")
    BUILD_NUMBER=$((BUILD_NUMBER + 1))
else
    BUILD_NUMBER=101
fi
echo "$BUILD_NUMBER" > "$BUILD_FILE"

echo "🔢 Building QuizMaster v1.0.1 (Build ${BUILD_NUMBER})..."

echo "🎨 Generating AppIcon..."
swift create_icon.swift
iconutil -c icns AppIcon.iconset -o AppIcon.icns

echo "📄 Generating Documentation Word files (.docx)..."
swift create_docs.swift

echo "🔨 Compiling QuizMaster Swift application..."
swift build -c release

APP_NAME="QuizMaster"
BUNDLE_DIR="${APP_NAME}.app"
CONTENTS_DIR="${BUNDLE_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "📦 Creating macOS App Bundle '${BUNDLE_DIR}'..."
rm -rf "${BUNDLE_DIR}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Copy binary, icon & build_number into App Bundle
cp ".build/release/${APP_NAME}" "${MACOS_DIR}/${APP_NAME}"
cp "AppIcon.icns" "${RESOURCES_DIR}/AppIcon.icns"
echo "$BUILD_NUMBER" > "${RESOURCES_DIR}/build_number.txt"

# Create Info.plist with AppIcon binding & v1.0.1
cat <<EOF > "${CONTENTS_DIR}/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.quizmaster.mac</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.1</string>
    <key>CFBundleVersion</key>
    <string>${BUILD_NUMBER}</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

chmod +x "${MACOS_DIR}/${APP_NAME}"

echo "✅ App bundle created successfully: '${BUNDLE_DIR}' v1.0.1 (Build ${BUILD_NUMBER})!"
echo "📄 Documentation Word files generated:"
echo "   • QuizMaster_GioiThieuUngDung.docx"
echo "   • QuizMaster_HuongDanSuDung.docx"
echo "🚀 You can launch it using: open ${BUNDLE_DIR}"
