#!/bin/bash

# 定义 Git 仓库路径
REPO_DIR="/www/wwwroot/xiyan-99.GitHub.io"

# 定义分支名称
BRANCH_NAME="main"

# 切换到仓库目录
cd "$REPO_DIR" || { echo "目录不存在：$REPO_DIR"; exit 1; }

# 检查是否为 Git 仓库
if [ ! -d .git ]; then
    echo "错误：$REPO_DIR 不是一个 Git 仓库"
    exit 1
fi

# 添加所有更改
git add .

# 检查是否有更改需要提交
if git diff --cached --quiet; then
    echo "没有需要推送的更改"
    exit 0
fi

# 提交更改，使用当前时间作为提交信息
COMMIT_MESSAGE="自动同步：$(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$COMMIT_MESSAGE"

# 推送到远程仓库
git pull origin "$BRANCH_NAME" --rebase  # 确保远程与本地同步
git push origin "$BRANCH_NAME"

echo "推送完成：$COMMIT_MESSAGE"
