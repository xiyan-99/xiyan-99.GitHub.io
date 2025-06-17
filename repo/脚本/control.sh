#!/bin/bash

base_dir="/var/jb/var/mobile/xiyan-99.github.io/repo/debs/deb"

for dir in "$base_dir"/*/; do
  control_file="$dir/DEBIAN/control"

  if [ -f "$control_file" ]; then
    echo "正在修改 $control_file..."
    
    # 检查写入权限
    chmod u+w "$control_file" "$dir/DEBIAN"
    
    # 修改内容
    sed 's/^Maintainer: .*/Maintainer: x/' "$control_file" > "$control_file.tmp"
    
    # 替换文件
    mv "$control_file.tmp" "$control_file"
    echo "$control_file 修改完成！"
  else
    echo "未找到 $control_file，跳过 $dir"
  fi
done

echo "所有 control 文件处理完成！"