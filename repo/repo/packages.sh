#!/bin/bash

# 定义工作目录
DEB_DIR="/www/wwwroot/repo.xiyan.store/repo/debs"
OUTPUT_FILE="/www/wwwroot/repo.xiyan.store/repo/Packages"

# 检查 dpkg-scanpackages 是否可用
if ! command -v dpkg-scanpackages &> /dev/null; then
    echo "dpkg-scanpackages 未安装，请先安装 dpkg-dev"
    exit 1
fi

# 生成 Packages 文件
cd "$DEB_DIR" || exit 1
dpkg-scanpackages . /dev/null > "$OUTPUT_FILE"

# 保留 Packages 文件，复制一份用于压缩
cp "$OUTPUT_FILE" "${OUTPUT_FILE}.tmp"

# 压缩 Packages 文件为 Packages.bz2
bzip2 -f "${OUTPUT_FILE}.tmp"

# 重命名临时文件为 Packages.bz2
mv "${OUTPUT_FILE}.tmp.bz2" "${OUTPUT_FILE}.bz2"

# 提示完成
echo "Packages 文件已生成，并同时保留原始文件和 Packages.bz2"
