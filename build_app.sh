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
  "version": "${VERSION}",
  "buildNumber": ${BUILD_NUMBER},
  "releaseTag": "v${VERSION}-b${BUILD_NUMBER}",
  "buildDate": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "releaseNotes": "QuizMaster v${VERSION}:\n- Kiến trúc cửa sổ độc lập, tự do thay đổi kích thước\n- Thuật toán xáo trộn câu hỏi và đáp án chuẩn xác\n- Tối ưu hệ thống phím tắt và trải nghiệm ôn tập\n- Thử nghiệm Chế độ Học Ngoại ngữ (WIP)"
}
EOF

# Create release_notes.txt
cat <<EOF > "release_notes.txt"
# QuizMaster v${VERSION} - Bản phát hành Thế hệ Mới (Major Update)

Bản cập nhật lớn v${VERSION} mang đến nhiều cải tiến vượt bậc về độ ổn định, giao diện và các chế độ học tập chuyên biệt:

### 1. Kiến trúc Cửa sổ Độc lập và Tối ưu Hiển thị
- Mọi chế độ học tập (Luyện tập, Thi thử, Thẻ ghi nhớ và Trình chỉnh sửa đề thi) được mở trong các cửa sổ macOS độc lập, tự do thay đổi kích thước và tự động ghi nhớ không gian làm việc.
- Đồng nhất thiết kế bo góc, phông chữ và dải màu kính lỏng hiện đại trên toàn ứng dụng.

### 2. Thuật toán Xáo trộn Câu hỏi và Đáp án Chuẩn xác
- Tái cấu trúc cơ chế lưu trữ kết quả và tiến độ học theo định danh câu hỏi, khắc phục triệt để hiện tượng lệch đáp án khi bật tắt chế độ xáo trộn trước, trong hoặc sau khi làm bài.

### 3. Tối ưu Hệ thống Phím tắt và Trải nghiệm
- Nhận diện nhạy bén toàn bộ các phím số, phím chữ cái, phím xóa và phím chuyển câu trong suốt quá trình làm bài.
- Bổ sung hộp thoại xác nhận an toàn khi xóa bộ đề thi.

### 4. Thử nghiệm Chế độ Học Ngoại ngữ (Bản thử nghiệm WIP)
- Bổ sung phân loại Dự án Học Ngoại ngữ dành riêng cho các đề thi tiếng Anh (như đề thi THPT, chứng chỉ quốc tế).
- Tách biệt khung đọc bài hiểu ở cột bên trái với thanh tùy chỉnh kiểu chữ, màu nền giấy và giãn cách dòng.
- Tự động trích xuất bộ thẻ ghi nhớ từ vựng theo khung trình độ CEFR kèm phiên âm quốc tế và câu ví dụ minh họa.
- Lưu ý: Chế độ Học Ngoại ngữ đang trong giai đoạn hoàn thiện và tối ưu hóa xử lý văn bản chuyên sâu. Người dùng có thể trải nghiệm thử nghiệm ngay trong phiên bản này.
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
