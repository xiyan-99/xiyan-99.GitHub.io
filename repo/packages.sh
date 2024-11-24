#!/bin/bash

# 定义工作目录和输出文件
REPO_ROOT="/www/wwwroot/repo.xiyan.store"
DEB_DIR="$REPO_ROOT/debs"
OUTPUT_FILE="$REPO_ROOT/Packages"

# 检查 dpkg-scanpackages 是否可用
if ! command -v dpkg-scanpackages &> /dev/null; then
    echo "dpkg-scanpackages 未安装，请先安装 dpkg-dev"
    exit 1
fi

# 检查 DEB_DIR 是否存在
if [ ! -d "$DEB_DIR" ]; then
    echo "目录 $DEB_DIR 不存在，请检查路径！"
    exit 1
fi

# 生成 Packages 文件
cd "$REPO_ROOT" || exit 1
dpkg-scanpackages ./debs > "$OUTPUT_FILE"

# 检查 Packages 文件是否生成成功
if [ ! -f "$OUTPUT_FILE" ]; then
    echo "Packages 文件未生成，请检查 dpkg-scanpackages 是否正常运行"
    exit 1
fi

# 替换 Filename 路径，加上 debs/ 前缀


# 压缩 Packages 文件为 Packages.bz2，同时保留未压缩文件
bzip2 -kf "$OUTPUT_FILE"

# 提示完成
echo "Packages 文件已生成，并同时保留未压缩文件和压缩文件 Packages.bz2"

