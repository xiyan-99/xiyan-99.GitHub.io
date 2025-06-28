#!/bin/bash

# 设置 Git 用户信息（只设置一次）
git config --global user.name "xiyan-99"
git config --global user.email "1418581664@qq.com"  # ← 替换为你 GitHub 绑定邮箱
git config --global safe.directory '*'

# 打包 Packages
echo "📦 正在生成 Packages 文件..."
dpkg-scanpackages -m ./deb > Packages

# 生成多种压缩格式
bzip2 -kf Packages
gzip -c Packages > Packages.gz
xz -kf Packages

# 添加并提交
echo "📤 正在提交到 Git 仓库..."
git add .
git commit -m "自动更新插件 $(date '+%Y-%m-%d %H:%M:%S')"

# 推送
echo "🚀 正在推送到 GitHub..."
git push origin main

echo "✅ 全部完成！"