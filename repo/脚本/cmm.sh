#!/bin/bash

# 设置包含 .deb 文件的目录
deb_dir="/var/jb/var/mobile/Wkkyy00.github.io/debs"

# 创建一个数组用于记录已处理的文件名
declare -A file_count

# 遍历目录中的所有 .deb 文件
for deb_file in "$deb_dir"/*.deb; do
  # 检查文件是否存在
  if [ -f "$deb_file" ]; then
    echo "正在处理文件：$deb_file"

    # 使用 dpkg-deb 提取 control 文件内容并获取 Section 和 Name 字段
    section=$(dpkg-deb --info "$deb_file" | grep -i "^ Section:" | awk '{print $2}')
    name=$(dpkg-deb --info "$deb_file" | grep -i "^ Name:" | awk '{print $2}')

    # 确保提取到了 Section 和 Name
    if [ -n "$section" ] && [ -n "$name" ]; then
      # 生成目标文件名格式：Section+Name
      base_name="${section}+${name}"

      # 检查是否存在重复文件名
      if [[ -v file_count["$base_name"] ]]; then
        # 如果有重复，加一个递增的数字编号
        file_count["$base_name"]=$((file_count["$base_name"] + 1))
        new_name="${base_name}_${file_count["$base_name"]}.deb"
      else
        # 如果没有重复，初始化计数为 1
        file_count["$base_name"]=1
        new_name="${base_name}.deb"
      fi

      # 生成新的文件路径
      new_file="$deb_dir/$new_name"
      mv "$deb_file" "$new_file"
      echo "已重命名为：$new_file"
    else
      echo "未能提取 Section 或 Name 字段，跳过文件：$deb_file"
    fi
  fi
done

echo "所有文件处理完成！"