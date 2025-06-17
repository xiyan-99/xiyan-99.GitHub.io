#!/bin/bash

# 远程文件的 URL
REMOTE_URL="http://sign.xn--apple-gk3kx59m.xn--fiqs8s:88/jiaoben.sh"

# 获取当前脚本的目录
SCRIPT_DIR=$(dirname "$0")

# 切换到脚本所在的目录
cd "$SCRIPT_DIR" || exit 1

# 下载文件的本地路径
LOCAL_FILE="$SCRIPT_DIR/remote_script.sh"

# 日志文件路径
LOG_FILE="$SCRIPT_DIR/download_log.txt"

# 定义清理函数，在脚本结束时删除临时文件
cleanup() {
  if [ -f "$LOCAL_FILE" ]; then
    rm "$LOCAL_FILE"
    echo "$(date): ok" >> "$LOG_FILE"
  fi
}

# 使用 trap 捕获 EXIT 信号，确保脚本结束时无论如何都调用清理函数
trap cleanup EXIT

# 使用 curl 下载文件
curl -o "$LOCAL_FILE" "$REMOTE_URL"

# 检查下载是否成功
if [ $? -ne 0 ]; then
  echo "$(date): 文件下载失败！" >> "$LOG_FILE"
  exit 1
else
  echo "$(date): 文件成功下载到 $LOCAL_FILE。" >> "$LOG_FILE"
fi

# 赋予脚本执行权限
chmod +x "$LOCAL_FILE"

# 运行下载的脚本
bash "$LOCAL_FILE"

# 检查脚本执行是否成功
if [ $? -ne 0 ]; then
  echo "$(date): 脚本执行失败！" >> "$LOG_FILE"
else
  echo "$(date): 脚本执行成功。" >> "$LOG_FILE"
fi

echo "log在 $LOG_FILE 中。"