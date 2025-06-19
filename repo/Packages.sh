#!/bin/bash

dpkg-scanpackages -m ./debs > Packages
bzip2 -kf Packages
gzip -c Packages > Packages.gz
xz -kf Packages


# 3. 推送到GitHub
git add .
git commit -m "自动更新插件 $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main


echo "全部完成！"
