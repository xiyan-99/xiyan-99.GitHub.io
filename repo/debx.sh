#!/bin/bash
# 自动批量修改control、打包、生成Packages、推送GitHub

set -e

REPO_DIR="$(cd "$(dirname "$0")"; pwd)"
DEB_ROOT="$REPO_DIR/deb"
UNPACK_DIR="$REPO_DIR/_unpacked"
ICON_URL="https://raw.githubusercontent.com/xiyan-99/xiyan-99.GitHub.io/f8aa36c87e47485c8c0b5271df358119f04297b2/repo/img/icon/wxicon.jpg"

# 1. 清理旧临时目录
rm -rf "$UNPACK_DIR"
mkdir -p "$UNPACK_DIR"

# 2. 解包所有deb并重新打包覆盖原包
find "$DEB_ROOT" -type f -name "*.deb" | while read debfile; do
    pkgname=$(basename "$debfile" .deb)
    workdir="$UNPACK_DIR/$pkgname"
    echo "解包 $debfile 到 $workdir"
    rm -rf "$workdir"
    dpkg-deb -R "$debfile" "$workdir"

    # 修改 DEBIAN/control
    ctrl="$workdir/DEBIAN/control"
    if [ -f "$ctrl" ]; then
        # 删除所有 Section 和 icon 字段（兼容大小写与前后空格）
        sed -i '/^[ ]*Section:/Id' "$ctrl"
        sed -i '/^[ ]*Icon:/Id' "$ctrl"
        # 删除末尾空行
        sed -i '${/^$/d;}' "$ctrl"
        # 追加新字段
        echo "Section: 微信插件" >> "$ctrl"
        echo "Icon: $ICON_URL" >> "$ctrl"
    fi

    # 重新打包并覆盖原包
    dpkg-deb -b "$workdir" "$debfile"
    echo "已重新打包: $debfile"
done

# 3. 生成 Packages 和多种压缩格式
cd "$REPO_DIR"
dpkg-scanpackages -m ./deb > Packages

bzip2 -kf Packages
gzip -c Packages > Packages.gz
xz -kf Packages

# 4. 推送到GitHub
git add .
git commit -m "自动更新Packages $(date '+%Y-%m-%d %H:%M:%S')" || echo "无变更，无需提交"
git push

# 5. 清理临时目录（可选）
rm -rf "$UNPACK_DIR"

echo "全部完成！"