#!/bin/bash
# 该脚本用于提取插件目录里所有.dylib文件的名字，并将它们写入一个新的文件中，每行一个文件名，带上 =

# 设置插件目录
plugin_dir="./已解压插件"
output_file="./手动注释dylib用于报告.txt"

# 检查插件目录是否存在
if [ ! -d "$plugin_dir" ]; then
  echo "插件目录不存在: $plugin_dir"
  exit 1
fi

# 清空或创建输出文件
> "$output_file"

# 查找插件目录中的所有.dylib文件，并将它们的名字写入输出文件，带上 =
find "$plugin_dir" -type f -name "*.dylib" | while read dylib_path; do
  dylib_name=$(basename "$dylib_path")
  echo "$dylib_name=" >> "$output_file"
done

echo "已将所有.dylib文件的名字写入: $output_file"
