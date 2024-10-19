#!/bin/bash

# 指定包含deb文件的顶层目录
TOP_DIR="/var/jb/var/mobile/debs"

# 递归遍历目录中的所有deb文件
find "$TOP_DIR" -type f -name "*.deb" | while read -r deb_file; do
    # 解压 deb 文件的控制文件并提取 Name 和 Version
    tmp_dir=$(mktemp -d)
    dpkg-deb -e "$deb_file" "$tmp_dir" 2>/dev/null

    # 提取 Name 和 Version
    package_name=$(grep '^Name:' "$tmp_dir/control" | awk -F ': ' '{print $2}')
    package_version=$(grep '^Version:' "$tmp_dir/control" | awk -F ': ' '{print $2}')

    # 删除临时目录
    rm -rf "$tmp_dir"

    # 如果成功获取 Name 和 Version，则重命名文件
    if [ -n "$package_name" ] && [ -n "$package_version" ]; then
        # 将 Name 中的空格替换为下划线
        package_name="${package_name// /_}"
        new_name="${package_name}_${package_version}.deb"

        # 获取当前文件所在目录
        dir=$(dirname "$deb_file")

        # 重命名文件
        mv "$deb_file" "$dir/$new_name"
        echo "Renamed $deb_file to $dir/$new_name"
    else
        echo "Failed to extract Name or Version for $deb_file"
    fi
done