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

VERSION="2.0.1"
RELEASE_TAG="v${VERSION}-b${BUILD_NUMBER}"

echo "🔢 Building QuizMaster v${VERSION} (Build ${BUILD_NUMBER})...."

# Create build_info.json in source repository
cat <<EOF > "build_info.json"
{
  "version": "${VERSION}",
  "buildNumber": ${BUILD_NUMBER},
  "releaseTag": "v${VERSION}-b${BUILD_NUMBER}",
  "buildDate": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "releaseNotes": "QuizMaster v${VERSION}:\n- Tối ưu bộ quét tài liệu thông minh: Hỗ trợ quét tài liệu dài (>95 câu) với tính năng chia luồng (chunking) tự động\n- Khắc phục triệt để lỗi đảo từ khi OCR/DOCX, bảo toàn nguyên vẹn văn bản gốc\n- Sửa lỗi nộp bài & hiển thị điểm số tức thì trong Chế độ Thi thử (Exam Mode)\n- Tối ưu và bổ sung nút Xáo trộn (Shuffle) trực tiếp trong Chế độ Luyện tập & Thi thử"
}
EOF

# Create release_notes.txt
cat <<EOF > "release_notes.txt"
# QuizMaster v${VERSION} - Nâng cấp Quét Tài liệu Lớn, Hoàn thiện Thi thử & Nút Xáo trộn

Bản cập nhật v${VERSION} mang đến các cải tiến quan trọng về hiệu năng quét tài liệu và độ ổn định khi làm bài:

### 1. Nâng cấp Bộ Quét Tài liệu Thông minh (> 95 Câu hỏi)
- **Tự động chia luồng (Chunking)**: Hỗ trợ quét và tạo trắc nghiệm cho tài liệu dung lượng lớn với hàng trăm câu hỏi mà không bị ngắt quãng hoặc chạm trần token.
- **Khôi phục JSON tự động**: Cơ chế quét ngược (backwards validation) giúp khôi phục các câu hỏi hoàn chỉnh ngay cả khi phản hồi bị cắt bớt, triệt tiêu hoàn toàn lỗi định dạng dữ liệu.

### 2. Bảo toàn Tuyệt đối Thứ tự Từ & Cấu trúc Câu
- **Tối ưu Vision OCR**: Tự động sắp xếp các khối chữ theo tọa độ hình học (trên xuống dưới, trái qua phải), không còn tình trạng xáo trộn thứ tự từ trong câu.
- **Nâng cấp trình đọc Word DOCX**: Xử lý chuẩn xác khoảng trắng, tab, ngắt dòng và các ô bảng biểu.

### 3. Sửa lỗi Chế độ Thi thử (Exam Mode) & Tính điểm Tức thì
- **Đồng bộ hóa câu trả lời**: Lưu trữ và cập nhật trạng thái làm bài ngay lập tức khi nộp bài thi, không còn bị mất điểm hoặc hiển thị 0 câu đúng.
- **Tính điểm chính xác**: Khớp chính xác phương án đã chọn kể cả khi đang bật chế độ xáo trộn.

### 4. Tối ưu Nút Xáo trộn (Shuffle)
- **Khắc phục lỗi xáo trộn**: Đảm bảo bật/tắt xáo trộn luôn tạo ra bộ câu hỏi và phương án A/B/C/D ngẫu nhiên mới.
- **Nút xáo trộn nhanh**: Bổ sung nút **Xáo trộn (Shuffle)** trực tiếp trên thanh tiêu đề của Chế độ Luyện tập và Thi thử để xáo trộn tức thì khi đang làm bài.
EOF

echo "🎨 Generating AppIcon..."
swift create_icon.swift
iconutil -c icns AppIcon.iconset -o AppIcon.icns

echo "🔨 Compiling QuizMaster Swift application..."
swift build -c release

APP_NAME="QuizMaster"
APP_VERSION="2.0.1"
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
