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
    BUILD_NUMBER=118
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
  "releaseNotes": "QuizMaster v${VERSION} (Build ${BUILD_NUMBER}):\n- Ocean Blue, Cyan Teal & Emerald Mint color palette styling\n- Saved Ask Gemini AI answers persistent storage\n- Smart GitHub Release cleanup for same-version builds\n- Question & Option Shuffling Toggle\n- Resizable & Spacious Study Mode Windows\n- 3D Flashcard Flipping Animation Restored\n- Practice Mode Progress Bar Fix\n- Exam Mode Anti-Cheating (Ask Gemini removed)\n- Ask Gemini Markdown Formatting Cleanup\n- Right-Side Question Navigator Pane\n- Checkpoint Progress Save & Resume"
}
EOF

# Create release_notes.txt
cat <<EOF > "release_notes.txt"
# 🚀 QuizMaster v${VERSION} (Build ${BUILD_NUMBER}) Release Notes

### 🌟 New Features & Enhancements in Build ${BUILD_NUMBER}:
- **🎨 Ocean Blue, Cyan Teal & Emerald Mint Theme**: Refined application color palette omitting purple for maximum legibility.
- **💾 Persistent Ask Gemini Answers**: AI explanations are saved to persistent storage and restored whenever returning to that question.
- **🧹 Automated GitHub Release Cleanup**: Script automatically removes older builds of the same version on GitHub while preserving prior major version releases.
- **🔀 Question & Option Shuffling Toggle**: Toggle question and option randomization on or off.
- **🎛️ Resizable & Spacious Windows**: Flexible frame dimensions for Practice, Exam, and Flashcard views.
- **🃏 3D Flashcard Flipping**: True 3D card rotation effect with upright text rendering.
- **📊 Fixed Practice Mode Progress Bar**: Progress bar now advances strictly based on completed questions count.
- **🚫 Exam Mode Anti-Cheating**: Removed Ask Gemini from Exam Mode to maintain test simulation integrity.
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

# GitHub Release & Same-Version Cleanup Logic
if command -v gh &> /dev/null; then
    echo "🔍 Checking existing GitHub releases for v${VERSION} cleanup..."
    
    # List tags starting with current version prefix e.g. v1.0.3-b
    SAME_VERSION_RELEASES=$(gh release list --limit 50 | grep "^v${VERSION}-b" | awk '{print $1}' || true)
    
    SAME_VERSION_COUNT=0
    if [ -n "$SAME_VERSION_RELEASES" ]; then
        SAME_VERSION_COUNT=$(echo "$SAME_VERSION_RELEASES" | wc -l | xargs)
    fi
    
    # If 2 or more releases exist for the same version number, delete older builds of the same version
    if [ "$SAME_VERSION_COUNT" -ge 2 ]; then
        echo "🧹 Found ${SAME_VERSION_COUNT} existing releases for v${VERSION}. Cleaning up older builds of the same version..."
        for old_tag in $SAME_VERSION_RELEASES; do
            if [ "$old_tag" != "${RELEASE_TAG}" ]; then
                echo "🗑️ Deleting older build release ${old_tag} from GitHub..."
                gh release delete "${old_tag}" -y --cleanup-tag || true
            fi
        done
    fi

    echo "🚀 Publishing GitHub Release ${RELEASE_TAG}..."
    gh release create "${RELEASE_TAG}" "${ZIP_NAME}" --title "QuizMaster v${VERSION} (Build ${BUILD_NUMBER})" --notes-file "release_notes.txt" || true
fi
