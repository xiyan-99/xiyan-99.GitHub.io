#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")"; pwd)"
SRC_DEB_DIR="$REPO_DIR/deb"
DST_DEB_DIR="$REPO_DIR/debs"
UNPACK_DIR="$REPO_DIR/_unpacked"
PROCESSED_LIST="$REPO_DIR/.deb_processed.list"
ICON_URL="https://raw.githubusercontent.com/xiyan-99/xiyan-99.GitHub.io/f8aa36c87e47485c8c0b5271df358119f04297b2/repo/img/icon/wxicon.jpg"

mkdir -p "$UNPACK_DIR" "$DST_DEB_DIR"
touch "$PROCESSED_LIST"

# 1. 扫描未处理的新deb
find "$SRC_DEB_DIR" -type f -name "*.deb" | while read debfile; do
    hash=$(sha256sum "$debfile" | awk '{print $1}')
    if grep -q "$hash" "$PROCESSED_LIST"; then
        echo "已处理过: $debfile"
        continue
    fi

    pkgname=$(basename "$debfile" .deb)
    workdir="$UNPACK_DIR/$pkgname"
    echo "处理新包 $debfile"
    rm -rf "$workdir"
    dpkg-deb -R "$debfile" "$workdir"

    ctrl="$workdir/DEBIAN/control"
    if [ -f "$ctrl" ]; then
        # 删除所有 Section 和 icon 字段
        sed -i '/^[ ]*Section:/Id' "$ctrl"
        sed -i '/^[ ]*icon:/Id' "$ctrl"
        sed -i '${/^$/d;}' "$ctrl"
        echo "Section: 微信插件" >> "$ctrl"
        echo "Icon: $ICON_URL" >> "$ctrl"
    fi

    newdeb="$DST_DEB_DIR/${pkgname}.deb"
    dpkg-deb -b "$workdir" "$newdeb"
    echo "已重新打包到: $newdeb"
    echo "$hash" >> "$PROCESSED_LIST"
done

# 2. 生成 Packages 索引和多种压缩格式
cd "$REPO_DIR"
dpkg-scanpackages -m ./debs > Packages
bzip2 -kf Packages
gzip -c Packages > Packages.gz
xz -kf Packages

# 3. 推送到GitHub
git add .
git commit -m "自动更新插件 $(date '+%Y-%m-%d %H:%M:%S')" || echo "无变更，无需提交"


# 4. 清理
rm -rf "$UNPACK_DIR"

echo "全部完成！"
