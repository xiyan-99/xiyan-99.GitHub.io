#!/bin/bash

# 设置 Git 身份信息（防止 author unknown）
git config --global user.name "xiyan-99"
git config --global user.email "1418581664@qq.com"
git config --global safe.directory '*'

# 创建临时文件用于打印 dpkg-scanpackages 日志
echo "📦 正在生成 Packages 文件..."

# 确保 deb 文件夹存在
if [ ! -d "./deb" ]; then
    echo "❌ 错误：当前目录未找到 deb 文件夹！"
    exit 1
fi

# 输出 scanpackages 每一行日志
dpkg-scanpackages -m ./deb | tee Packages

# 生成压缩版本
echo "📦 正在生成压缩版本 Packages 文件..."
bzip2 -kf Packages
gzip -c Packages > Packages.gz
xz -kf Packages

# 添加到 git 并提交
echo "📤 正在提交到 Git 仓库..."
git add .
git commit -m "自动更新插件 $(date '+%Y-%m-%d %H:%M:%S')"

# 推送（强制指定密钥，适配 Filza）
echo "🚀 正在推送到 GitHub（使用 SSH 密钥）..."
GIT_SSH_COMMAND='ssh -i ~/.ssh/id_rsa' git push origin main

echo "✅ 所有操作完成！"