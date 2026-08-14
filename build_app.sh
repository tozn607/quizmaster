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
  "releaseNotes": "QuizMaster v${VERSION}:\n- Tách biệt Cỡ chữ và Thu phóng giao diện độc lập với 4 mức kích thước (Nhỏ hơn, Mặc định, Lớn hơn, Rất lớn)\n- Phóng to/thu nhỏ đồng bộ toàn diện trên toàn ứng dụng\n- Tùy biến đồng hồ Thi thử linh hoạt, thi không giới hạn thời gian và khôi phục đồng hồ Pomodoro 25 phút"
}
EOF

# Create release_notes.txt
cat <<EOF > "release_notes.txt"
# QuizMaster v${VERSION} - Nâng cấp Cỡ chữ Toàn diện & Đồng hồ Thi thử Linh hoạt

Bản cập nhật v${VERSION} mang đến trải nghiệm thị giác vượt trội và tinh chỉnh linh hoạt cho các chế độ học tập:

### 1. Tách biệt Cỡ chữ & Thu phóng Giao diện Độc lập
- Tách riêng hai cài đặt: **Cỡ chữ (Font Size)** và **Thu phóng giao diện (Interface Scaling)** để tùy biến độc lập theo sở thích cá nhân.
- Bổ sung tùy chọn **Rất lớn (Extra Large)** (4 mức: *Nhỏ hơn*, *Mặc định*, *Lớn hơn*, *Rất lớn*) và gia tăng khoảng cách tỷ lệ co giãn (từ 0.80x đến 1.45x) giúp chữ to rõ, dễ đọc hơn.

### 2. Đồng bộ Phóng to/Thu nhỏ Toàn Diện Toàn Bộ Ứng Dụng
- Áp dụng chuẩn xác tỷ lệ phóng to trên mọi giao diện: Thanh bên danh mục dự án, Trang tổng quan, Thẻ đề thi, Trình chỉnh sửa câu hỏi, Hộp thoại và Cài đặt.

### 3. Tối ưu Chế độ Thi thử & Khôi phục Đồng hồ Pomodoro
- **Linh hoạt thời gian làm bài**: Các dự án thông thường không còn bị ép buộc đếm giờ, cho phép bạn làm bài thi thoải mái theo nhịp độ riêng hoặc tùy ý bật/tắt đồng hồ qua menu trên thanh tiêu đề.
- **Bắt buộc chuẩn hóa đối với Ngoại ngữ**: Giữ nguyên tính năng kiểm soát thời gian nghiêm ngặt dành riêng cho các kỳ thi chuẩn hóa (IELTS, THPT Tiếng Anh).
- **Khôi phục Đồng hồ Pomodoro**: Bổ sung lại phím tắt chọn nhanh **🍅 Pomodoro (25 Phút)** trong menu đồng hồ và hộp thoại cài đặt thời gian.
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
