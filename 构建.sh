#!/bin/bash

REPO_DIR="/www/wwwroot/apt.xiyan.store/Silica"
PKG_DIR="$REPO_DIR/Packages"
GIT_BRANCH="main"

cd "$REPO_DIR" || exit 1

# 清理旧构建（如有）
rm -rf docs

# 自动生成 changelog 默认值
export SILICA_CHANGELOG="Auto build from script"

# 编译网站
python3.8 index.py <<EOF
$SILICA_CHANGELOG
EOF

# Git 提交并推送
git add .
git commit -m "Auto update from script: $(date +'%F %T')"
git push origin $GIT_BRANCH
