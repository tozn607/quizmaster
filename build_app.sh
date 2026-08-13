#!/bin/bash
set -e

# Delete old release zip archives from local directory
echo "🧹 Cleaning up old build archives..."
rm -f QuizMaster-*.zip

# Increment Build Number
BUILD_FILE=".build_number"
if [ -f "$BUILD_FILE" ]; then
    BUILD_NUMBER=$(cat "$BUILD_FILE")
    BUILD_NUMBER=$((BUILD_NUMBER + 1))
else
    BUILD_NUMBER=140
fi
echo "$BUILD_NUMBER" > "$BUILD_FILE"

VERSION="1.2.1"
RELEASE_TAG="v${VERSION}-b${BUILD_NUMBER}"

echo "🔢 Building QuizMaster v${VERSION} (Build ${BUILD_NUMBER})...."

# Create build_info.json in source repository
cat <<EOF > "build_info.json"
{
  "version": "1.2.1",
  "buildNumber": ${BUILD_NUMBER},
  "releaseTag": "v1.2.1-b${BUILD_NUMBER}",
  "buildDate": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "releaseNotes": "QuizMaster v1.2.1 (Build ${BUILD_NUMBER}):\n- Visually prominent shuffle button with single-shuffle persistence (reshuffles only upon progress reset)\n- Complete English localization coverage for Settings and First-Time Setup Wizard\n- Updated bilingual User Guides with screenshots and detailed setup steps"
}
EOF

# Create release_notes.txt
cat <<EOF > "release_notes.txt"
# 🚀 QuizMaster v1.2.1 Release Notes

### 🌟 New Features & Enhancements in v1.2.1:
- 🔀 **Prominent Shuffle Button & Single-Shuffle Persistence**:
  - Upgraded the shuffle toggle button on the main toolbar to a prominent pill badge with vibrant Ocean Blue color and subtle drop shadow.
  - Enabling shuffle randomizes question & option (A/B/C/D) order **once** and persists it in quiz progress. The deck will only reshuffle when progress is reset.
- 🌐 **100% Complete English Localization Coverage**:
  - Replaced all remaining hardcoded strings in Settings and the First-Time Setup Wizard with dynamic localization calls (\`loc.text(...)\`).
- 📖 **Updated Bilingual Documentation with Screenshots**:
  - Adapted the English User Guide (\`DOCS/USER_GUIDE_EN.md\`) to match the Vietnamese baseline (\`DOCS/HUONG_DAN_SU_DUNG_VI.md\`) 1-to-1, including all screenshots and detailed instructions.
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
echo "🔒 Applying ad-hoc code signing and clearing Gatekeeper quarantine flags..."
codesign --force --deep --sign - "${BUNDLE_DIR}" || true
xattr -cr "${BUNDLE_DIR}" || true
touch -c "${BUNDLE_DIR}"

# Create Zip Archive for Release Asset
ZIP_NAME="QuizMaster-v${VERSION}-b${BUILD_NUMBER}.zip"
rm -f "${ZIP_NAME}"
zip -r -q "${ZIP_NAME}" "${BUNDLE_DIR}"

echo "✅ App bundle created successfully: '${BUNDLE_DIR}' v${VERSION} (Build ${BUILD_NUMBER})!"
echo "📦 Packaged Release Zip: '${ZIP_NAME}'"

# GitHub Release & Strict Single Same-Version Release Enforcement
if command -v gh &> /dev/null; then
    echo "🔍 Finding all existing GitHub releases for version v${VERSION}..."
    
    SAME_VERSION_RELEASES=$(gh release list --limit 100 --json tagName -q '.[].tagName' | grep "^v${VERSION}-" || true)
    
    if [ -n "$SAME_VERSION_RELEASES" ]; then
        echo "🧹 Deleting ALL older builds for version v${VERSION} on GitHub so only 1 release remains..."
        for old_tag in $SAME_VERSION_RELEASES; do
            if [ "$old_tag" != "${RELEASE_TAG}" ]; then
                echo "🗑️ Deleting older release tag ${old_tag}..."
                gh release delete "${old_tag}" -y --cleanup-tag || true
            fi
        done
    fi

    echo "🚀 Publishing single GitHub Release ${RELEASE_TAG}..."
    gh release create "${RELEASE_TAG}" "${ZIP_NAME}" --title "QuizMaster v${VERSION} (Build ${BUILD_NUMBER})" --notes-file "release_notes.txt" || true
fi
