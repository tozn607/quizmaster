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
    BUILD_NUMBER=139
fi
echo "$BUILD_NUMBER" > "$BUILD_FILE"

VERSION="1.1.0"
RELEASE_TAG="v${VERSION}-b${BUILD_NUMBER}"

echo "🔢 Building QuizMaster v${VERSION} (Build ${BUILD_NUMBER})...."

# Create build_info.json in source repository
cat <<EOF > "build_info.json"
{
  "version": "1.1.0",
  "buildNumber": ${BUILD_NUMBER},
  "releaseTag": "v1.1.0-b${BUILD_NUMBER}",
  "buildDate": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "releaseNotes": "QuizMaster v1.1.0 (Build ${BUILD_NUMBER}):\n- Markdown Formatted Explanations for Saved Ask Gemini Answers\n- Guaranteed Light Mode Readability with Solid Card Backings & High-Contrast Dark Typography\n- 100% Solid, Saturated & Vibrant LiquidGlassPalette Colors (Ocean Blue, Sunset Orange, Deep Purple, Emerald Mint, Coral Red, Cyan Teal)\n- Authentic macOS Liquid Glass Translucent Backdrop (NSVisualEffectView fullScreenUI)\n- 6-Color Rainbow Gradient App Icon with Pure White Graduation Cap Main Icon\n- Strict Single Release Enforcement per Version Number on GitHub\n- Persistent Ask Gemini AI Answers\n- Gatekeeper Quarantine & Ad-hoc Code-signing Fix\n- Question & Option Shuffling Toggle\n- Resizable & Spacious Study Mode Windows\n- 3D Flashcard Flipping Animation\n- Practice Checkpoint Progress Save & Resume"
}
EOF

# Create release_notes.txt
cat <<EOF > "release_notes.txt"
# 🚀 QuizMaster v1.1.0 (Build ${BUILD_NUMBER}) Release Notes

### 🌟 New Features & Enhancements in v1.1.0:
- **📝 Markdown Formatted Explanations for Saved Ask Gemini Answers**: Saved Ask Gemini explanations in Practice Mode now parse headers (\`###\`), bold text (\`**...**\`), section dividers (\`---\`), bullet points, and quotes (\`> ...\`) directly inside the explanation box.
- **☀️ Guaranteed Light Mode Readability**: \`GlassCard\` and option containers use 100% solid white backgrounds (\`Color.white\`) with dark high-contrast typography in Light Mode, eliminating white-on-white text glare.
- **🌈 100% Solid, Saturated & Vibrant \`LiquidGlassPalette\` Colors**: Rich, vivid solid color fills for primary buttons, badges, and study modes:
  - **Ocean Blue** (\`#0073FB\`): Practice Mode & primary actions.
  - **Sunset Orange** (\`#FA730D\`): Exam Mode & exam badges.
  - **Deep Purple** (\`#8C40EB\`): Flashcard Mode, AI sparkles, and Ask Gemini actions.
  - **Emerald Mint** (\`#19B861\`): Correct answer indicators, success toasts, and mastered cards.
  - **Coral Red** (\`#EB2E4D\`): Wrong answer indicators, delete actions, and need-review cards.
  - **Cyan Teal** (\`#00AEB8\`): Reset progress actions.
- **🧊 Authentic Liquid Glass Window Backdrop**: Translucent, blurred macOS Liquid Glass backdrop (\`NSVisualEffectView\` behind-window blending) with ambient accent light mesh.
- **🌈 Vibrant Rainbow Gradient App Icon**: Multi-color rainbow gradient background with a crisp, pure white graduation cap main icon.
- **🧹 Single Release Enforcement**: Automatically removes ALL previous builds of version 1.1.0 on GitHub, keeping only 1 release per version.
- **💾 Persistent Ask Gemini Answers**: AI explanations are saved to persistent storage and restored whenever returning to that question.
- **🔒 Gatekeeper & Code-signing Fix**: Applied ad-hoc codesigning and stripped quarantine flags to prevent launch errors.
- **🔀 Question & Option Shuffling Toggle**: Toggle question and option randomization on or off.
- **🎛️ Resizable & Spacious Windows**: Flexible frame dimensions for Practice, Exam, and Flashcard views.
- **🃏 3D Flashcard Flipping**: True 3D card rotation effect with upright text rendering.
- **📊 Fixed Practice Mode Progress Bar**: Progress bar now advances strictly based on completed questions count.
- **🚫 Exam Mode Anti-Cheating**: Removed Ask Gemini from Exam Mode to maintain test simulation integrity.
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
