#!/bin/bash

# 需要监控的 Git 仓库目录
REPO_DIR="/www/wwwroot/repo.xiyan.store"

# 推送脚本路径
SYNC_SCRIPT="/www/wwwroot/sh/tuisong.sh"

# 检查目录是否存在
if [ ! -d "$REPO_DIR" ]; then
    echo "监控目录不存在：$REPO_DIR"
    exit 1
fi

# 监控文件的创建、修改、删除事件
inotifywait -m -r -e modify,create,delete "$REPO_DIR" --format '%w%f' | while read FILE
do
    echo "检测到文件变动：$FILE"
    # 调用同步脚本
    bash "$SYNC_SCRIPT"
done
