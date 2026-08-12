#!/bin/bash
set -e

# Delete old release zip archives
echo "🧹 Cleaning up old build archives..."
rm -f QuizMaster-*.zip

# Increment Build Number
BUILD_FILE=".build_number"
if [ -f "$BUILD_FILE" ]; then
    BUILD_NUMBER=$(cat "$BUILD_FILE")
    BUILD_NUMBER=$((BUILD_NUMBER + 1))
else
    BUILD_NUMBER=116
fi
echo "$BUILD_NUMBER" > "$BUILD_FILE"

VERSION="1.0.3"
RELEASE_TAG="v${VERSION}-b${BUILD_NUMBER}"

echo "🔢 Building QuizMaster v${VERSION} (Build ${BUILD_NUMBER})..."

# Create build_info.json in source repository
cat <<EOF > "build_info.json"
{
  "version": "${VERSION}",
  "buildNumber": ${BUILD_NUMBER},
  "releaseTag": "${RELEASE_TAG}",
  "buildDate": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "releaseNotes": "QuizMaster v${VERSION} (Build ${BUILD_NUMBER}):\n- Question & Option Shuffling Toggle\n- Resizable & Spacious Study Mode Windows\n- 3D Flashcard Flipping Animation Restored\n- Practice Mode Progress Bar Fix\n- Exam Mode Anti-Cheating (Ask Gemini removed)\n- Ask Gemini Markdown Formatting Cleanup\n- Right-Side Question Navigator Pane\n- Checkpoint Progress Save & Resume"
}
EOF

# Create release_notes.txt
cat <<EOF > "release_notes.txt"
# 🚀 QuizMaster v${VERSION} (Build ${BUILD_NUMBER}) Release Notes

### 🌟 New Features & Enhancements in v${VERSION}:
- **🔀 Question & Option Shuffling Toggle**: Added a dedicated shuffle checkbox on the dashboard top bar.
- **🎛️ Resizable & Spacious Windows**: Flexible frame dimensions for Practice, Exam, and Flashcard study views.
- **🃏 Restored 3D Flashcard Flip**: True 3D card rotation effect with upright text rendering.
- **📊 Fixed Practice Mode Progress Bar**: Progress bar now advances strictly based on completed questions count.
- **🚫 Exam Mode Anti-Cheating**: Removed Ask Gemini from Exam Mode to maintain test integrity.
- **📝 Cleaned Ask Gemini Markdown Output**: Formatted markdown headers, blockquotes, and rules cleanly in response text views.
- **📍 Question Navigator Pane**: Collapsible right-side sidebar for instant question jumping and status visualization.
- **💾 Practice Checkpoint Resume**: Automatically save and resume at your exact question index.
EOF

echo "🎨 Generating AppIcon..."
swift create_icon.swift
iconutil -c icns AppIcon.iconset -o AppIcon.icns

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
cp "AppIcon.icns" "${RESOURCES_DIR}/AppIcon"
echo "$BUILD_NUMBER" > "${RESOURCES_DIR}/build_number.txt"

# Create Info.plist with explicit AppIcon.icns binding
cat <<EOF > "${CONTENTS_DIR}/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon.icns</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.quizmaster.mac</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
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
touch -c "${BUNDLE_DIR}"

# Create Zip Archive for GitHub Release Asset
ZIP_NAME="QuizMaster-v${VERSION}-b${BUILD_NUMBER}.zip"
rm -f "${ZIP_NAME}"
zip -r -q "${ZIP_NAME}" "${BUNDLE_DIR}"

echo "✅ App bundle created successfully: '${BUNDLE_DIR}' v${VERSION} (Build ${BUILD_NUMBER})!"
echo "📦 Packaged Release Zip: '${ZIP_NAME}'"

# If GitHub CLI (gh) is available, create GitHub release and upload zip asset
if command -v gh &> /dev/null; then
    echo "🚀 Publishing GitHub Release ${RELEASE_TAG}..."
    gh release create "${RELEASE_TAG}" "${ZIP_NAME}" --title "QuizMaster v${VERSION} (Build ${BUILD_NUMBER})" --notes-file "release_notes.txt" || true
fi
