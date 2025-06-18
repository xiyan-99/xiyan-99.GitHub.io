#!/bin/bash
# 自动批量修改control、打包、生成Packages、推送GitHub

set -e

REPO_DIR="$(cd "$(dirname "$0")"; pwd)"
DEB_ROOT="$REPO_DIR/deb"
UNPACK_DIR="$REPO_DIR/_unpacked"
REBUILT_DIR="$REPO_DIR/_rebuilt"
PACKAGES_FILE="$REPO_DIR/Packages"
ICON_URL="https://raw.githubusercontent.com/xiyan-99/xiyan-99.GitHub.io/f8aa36c87e47485c8c0b5271df358119f04297b2/repo/img/icon/wxicon.jpg"

# 1. 清理旧临时目录
rm -rf "$UNPACK_DIR" "$REBUILT_DIR"
mkdir -p "$UNPACK_DIR" "$REBUILT_DIR"

# 2. 解包所有deb
find "$DEB_ROOT" -type f -name "*.deb" | while read debfile; do
    pkgname=$(basename "$debfile" .deb)
    workdir="$UNPACK_DIR/$pkgname"
    echo "解包 $debfile 到 $workdir"
    dpkg-deb -R "$debfile" "$workdir"

    # 修改 DEBIAN/control
    ctrl="$workdir/DEBIAN/control"
    if [ -f "$ctrl" ]; then
        # 删除原有 Section 和 icon 字段
        sed -i '/^Section:/d' "$ctrl"
        sed -i '/^Icon:/d' "$ctrl"
        # 删除 control 文件末尾多余空行
        sed -i '${/^$/d;}' "$ctrl"
        # 追加新字段，且保证只有一组
        echo "Section: 微信插件" >> "$ctrl"
        echo "icon: $ICON_URL" >> "$ctrl"
    fi

    # 重新打包
    newdeb="$REBUILT_DIR/${pkgname}.deb"
    dpkg-deb -b "$workdir" "$newdeb"
    echo "已重新打包: $newdeb"
done

# 3. 汇总所有新deb用于生成Packages
TMP_DEB_DIR="$REPO_DIR/_all_debs"
rm -rf "$TMP_DEB_DIR"
mkdir -p "$TMP_DEB_DIR"
find "$REBUILT_DIR" -type f -name "*.deb" -exec ln -s {} "$TMP_DEB_DIR/" \;

# 4. 生成 Packages 和 Packages.bz2
dpkg-scanpackages -m "$TMP_DEB_DIR" /dev/null > "$PACKAGES_FILE"
bzip2 -kf "$PACKAGES_FILE"

# 5. 推送到GitHub
git add .
git commit -m "自动更新Packages $(date '+%Y-%m-%d %H:%M:%S')" || echo "无变更，无需提交"
git push

# 6. 清理临时目录（可选）
rm -rf "$UNPACK_DIR" "$REBUILT_DIR" "$TMP_DEB_DIR"

echo "全部完成！"