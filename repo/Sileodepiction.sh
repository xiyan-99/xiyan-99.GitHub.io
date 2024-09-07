#!/bin/bash

# 定义通用 Sileodepiction 文件的 URL
sileodepiction_url="https://raw.githubusercontent.com/xiyan-99/xiyan-99.GitHub.io/main/repo/Sileodepiction/all.json"

# 处理 Packages 文件，在每个包的 Description 行后添加 Sileodepiction 字段
awk -v sileodepiction="$sileodepiction_url" '
/^Description:/ {
    print $0
    print "Sileodepiction: " sileodepiction
    next
}
{print}
' Packages > Packages.new

# 备份原 Packages 文件，并将新生成的文件替换原文件
mv Packages Packages.bak
mv Packages.new Packages