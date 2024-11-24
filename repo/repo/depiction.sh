#!/bin/bash

# 定义路径
TEMPLATE_FILE="/www/wwwroot/repo.xiyan.store/depictions.json"
OUTPUT_DIR="/www/wwwroot/repo.xiyan.store/repo/depictions"
DEBS_DIR="/www/wwwroot/repo.xiyan.store/repo/debs"
PACKAGES_FILE="/www/wwwroot/repo.xiyan.store/repo/Packages"

# 检查 deb 目录是否存在
if [ ! -d "$DEB_DIR" ]; then
    echo "Error: Directory $DEB_DIR does not exist!"
    exit 1
fi

# 确保输出目录存在
mkdir -p $OUTPUT_DIR

# 遍历所有 DEB 文件
find "$DEB_DIR" -type f -name "*.deb" | while read -r deb; do
  # 获取 DEB 包信息
  PACKAGE_NAME=$(dpkg-deb -f "$deb" Package)
  VERSION=$(dpkg-deb -f "$deb" Version)
  MAINTAINER=$(dpkg-deb -f "$deb" Maintainer)
  DESCRIPTION=$(dpkg-deb -f "$deb" Description)
  UPDATE_TIME=$(date +"%Y-%m-%d")
  CONTACT="zviolety-"
  CHANGELOG="暂无更新日志"

  # 替换模板中的占位符
  JSON_FILE="$OUTPUT_DIR/$PACKAGE_NAME.json"
  sed -e "s|{{DESCRIPTION}}|$DESCRIPTION|g" \
      -e "s|{{MAINTAINER}}|$MAINTAINER|g" \
      -e "s|{{CONTACT}}|$CONTACT|g" \
      -e "s|{{PACKAGE_NAME}}|$PACKAGE_NAME|g" \
      -e "s|{{VERSION}}|$VERSION|g" \
      -e "s|{{UPDATE_TIME}}|$UPDATE_TIME|g" \
      -e "s|{{CHANGELOG}}|$CHANGELOG|g" \
      $TEMPLATE_FILE > $JSON_FILE

  # 更新 Packages 文件中的 SileoDepiction 字段
  sed -i "s|^Package: $PACKAGE_NAME.*|&\nSileoDepiction: https://repo.xiyan.store/depictions/$PACKAGE_NAME.json|g" $PACKAGES_FILE
done

# 压缩 Packages 文件
bzip2 -f $PACKAGES_FILE
