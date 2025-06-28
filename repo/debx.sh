#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")"; pwd)"
SRC_DEB_DIR="$REPO_DIR/未处理deb"
DST_DEB_DIR="$REPO_DIR/deb/RootHide插件"
UNPACK_DIR="$REPO_DIR/_unpacked"

mkdir -p "$UNPACK_DIR" "$DST_DEB_DIR"

# 1. 解包并修改 Section 字段
find "$SRC_DEB_DIR" -type f -name "*.deb" | while read debfile; do
    pkgname=$(basename "$debfile" .deb)
    workdir="$UNPACK_DIR/$pkgname"

    echo "📦 正在处理: $pkgname"
    rm -rf "$workdir"
    dpkg-deb -R "$debfile" "$workdir"

    ctrl="$workdir/DEBIAN/control"
    if [ -f "$ctrl" ]; then
        sed -i '/^[ ]*Section:/Id' "$ctrl"
        sed -i '${/^$/d;}' "$ctrl"
        echo "Section: RootHide插件" >> "$ctrl"
    else
        echo "❌ 缺少控制文件: $ctrl"
        continue
    fi

    newdeb="$DST_DEB_DIR/${pkgname}.deb"
    dpkg-deb -b "$workdir" "$newdeb" > /dev/null
    echo "✅ 已重新打包: $newdeb"
done

# 2. 生成 Packages 索引
cd "$REPO_DIR"
echo "📄 正在生成 Packages 索引..."
dpkg-scanpackages -m ./debs | tee Packages
bzip2 -kf Packages
gzip -c Packages > Packages.gz
xz -kf Packages

rm -rf "$UNPACK_DIR"

# 3. Git 推送（适配 Filza 环境）
echo "📤 正在推送到 GitHub..."
git config --global user.name "xiyan-99"
git config --global user.email "1418581664@qq.com"
git config --global safe.directory '*'
git add .
git commit -m "自动更新插件 $(date '+%Y-%m-%d %H:%M:%S')" || echo "⚠️ 无变更，无需提交"
GIT_SSH_COMMAND='ssh -i ~/.ssh/id_rsa' git push origin main

echo "✅ 所有操作完成！"