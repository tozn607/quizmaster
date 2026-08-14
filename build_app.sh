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

VERSION="2.0.0"
RELEASE_TAG="v${VERSION}-b${BUILD_NUMBER}"

echo "🔢 Building QuizMaster v${VERSION} (Build ${BUILD_NUMBER})...."

# Create build_info.json in source repository
cat <<EOF > "build_info.json"
{
  "version": "1.3.0",
  "buildNumber": ${BUILD_NUMBER},
  "releaseTag": "v1.3.0-b${BUILD_NUMBER}",
  "buildDate": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "releaseNotes": "QuizMaster v1.3.0:\n- Hỗ trợ chuyên sâu cho môn Ngoại ngữ với các dạng bài đọc hiểu, trắc nghiệm từ vựng, ngữ pháp và phát âm\n- Tách biệt hoàn toàn dự án Ôn tập chung và Ngoại ngữ\n- Chế độ thẻ ghi nhớ từ vựng tự động trích xuất từ đề thi kèm phiên âm IPA, nghĩa tiếng Việt và câu ví dụ minh họa\n- Giao diện bài thi thông minh hiển thị bài đọc bên trái và khóa phần thi khi chuyển tiếp"
}
EOF

# Create release_notes.txt
cat <<'EOF' > "release_notes.txt"
# QuizMaster v1.3.0 - Bản cập nhật Học & Thi Ngoại ngữ

### Các điểm mới trong phiên bản 1.3.0:
- **Hỗ trợ chuyên biệt cho đề thi Ngoại ngữ**:
  - Nhập và xử lý hoàn chỉnh các đề thi tiếng Anh (như đề thi tốt nghiệp THPT, đề luyện thi chứng chỉ) bao gồm bài đọc hiểu, điền từ, bài tập ngữ pháp và ngữ âm.
- **Phân loại dự án độc lập**:
  - Cho phép tạo dự án chuyên môn 'Học & Thi Ngoại ngữ' riêng biệt với dự án thông thường, đảm bảo quản lý bộ đề trực quan và không bị nhầm lẫn.
- **Thẻ ghi nhớ từ vựng theo khung CEFR**:
  - Chế độ Flashcard cho đề thi ngoại ngữ tự động tổng hợp danh sách từ vựng theo khung tham chiếu CEFR. Mặt trước hiển thị từ kèm loại từ và phiên âm quốc tế IPA; mặt sau hiển thị nghĩa tiếng Việt chuẩn cùng câu văn ví dụ có từ vựng được làm nổi bật.
- **Trải nghiệm làm bài đọc hiểu tiện lợi**:
  - Chế độ Luyện tập và Thi thử tự động tách khung bài đọc ở cột bên trái với cỡ chữ tối ưu, giúp theo dõi nội dung bài luận song song cùng câu hỏi và đáp án bên phải.
- **Bộ đếm thời gian và quy chế chuyển phần thi**:
  - Thi thử yêu cầu thiết lập đồng hồ đếm ngược trước khi bắt đầu và có thông báo xác nhận khi chuyển sang kỹ năng tiếp theo.
EOF

echo "🎨 Generating AppIcon..."
swift create_icon.swift
iconutil -c icns AppIcon.iconset -o AppIcon.icns

echo "🔨 Compiling QuizMaster Swift application..."
swift build -c release

APP_NAME="QuizMaster"
APP_VERSION="2.0.0"
BUNDLE_ID="com.tozn.quizmaster"
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
rm -f "${ZIP_NAME}" "QuizMaster.zip"
zip -r -q "${ZIP_NAME}" "${BUNDLE_DIR}"
cp "${ZIP_NAME}" "QuizMaster.zip"

echo "✅ App bundle created successfully: '${BUNDLE_DIR}' v${VERSION} (Build ${BUILD_NUMBER})!"
echo "📦 Packaged Release Zip: '${ZIP_NAME}' (and permanent asset 'QuizMaster.zip')"

# GitHub Release & Strict Single Same-Version Release Enforcement
if [ -z "$SKIP_GH" ] && command -v gh &> /dev/null; then
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
    gh release create "${RELEASE_TAG}" "${ZIP_NAME}" "QuizMaster.zip" --title "QuizMaster v${VERSION} (Build ${BUILD_NUMBER})" --notes-file "release_notes.txt" || true
fi
