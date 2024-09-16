#!/bin/bash
# 该脚本由泡泡和夕颜制作制作 使用injectipa实现一键提取和注入
# 使用方法:新建一个文件夹 把插件和ipa 脚本放在一个文件夹里面 然后复制脚本路径 然后去终端运行 不要直接运行

# 更新日志
#1.0：简单的打包脚本
#2.0: 添加了远程下载等功能
#3.0: 添加了多个注入选项
#4.0：添加了GitHub安装包拉取选项（需vpn）
#5.0：添加注入资源库

# 获取当前时间
current_time=$(date "+%Y-%m-%d %H:%M:%S")
# 显示欢迎信息
echo "你好，欢迎使用一键提取注入脚本"
echo "脚本由泡泡与夕颜共同打造"

echo "当前时间: $current_time"

# 口令检查
read -sp "请输入口令以继续: " password
echo ""

# 定义正确的口令
correct_password1="paopao520"
correct_password2="xiyan520"

# 检查口令是否正确
if [ "$password" != "$correct_password1" ] && [ "$password" != "$correct_password2" ]; then
    echo "口令错误。"
    exit 1
fi

echo "口令正确，欢迎使用"

# 获取脚本所在的目录
script_dir="$(cd "$(dirname "$0")" && pwd)"
echo "Script directory: $script_dir"

# 赋予当前脚本执行和写入权限
chmod +x+w "$0"

# 定义目录
downloaded_ipa_dir="$script_dir/已下载ipa"
local_ipa_dir="$script_dir/ipa"
plugin_dir="$script_dir/插件"
extracted_plugin_dir="$script_dir/已解压插件"

# 创建目录并给予权限
for dir in "$downloaded_ipa_dir" "$local_ipa_dir" "$plugin_dir" "$extracted_plugin_dir"; do
    mkdir -p "$dir"
    chmod u+rw "$dir"
done

# 读取 dylib 注释文件
declare -A dylib_annotations
while IFS='=' read -r dylib_file annotation; do
    dylib_annotations["$dylib_file"]="$annotation"
done < "$script_dir/手动注释dylib用于报告.txt"

# 定义函数来下载和处理 IPA 文件
process_ipa_files() {
    local ipa_files=("$@")

    # 如果没有选择任何 .ipa 文件，重新选择下载方式
    if [ ${#ipa_files[@]} -eq 0 ]; then
        echo "未选择任何 .ipa 文件，请重新选择下载方式。"
        return
    fi

    # 创建日志文件
    log_file="$script_dir/xxx_script.log"
    echo "日志文件: $log_file"
    exec > >(tee -a "$log_file") 2>&1

    # 定义结果文件
    result_file="$script_dir/打包报告.txt"
    echo "处理结果：" > "$result_file"

    for ipa_file in "${ipa_files[@]}"; do
        if [[ "$ipa_file" == http* ]]; then
            echo "正在下载 .ipa 文件: $ipa_file"
            # 将下载的 .ipa 文件保存到 downloaded_ipa_dir 目录
            temp_ipa_file="$downloaded_ipa_dir/$(basename "$ipa_file")"

            if command -v curl >/dev/null 2>&1; then
                echo "使用 curl 下载 ..."
                curl -# -L --retry 3 --retry-delay 5 -o "$temp_ipa_file" "$ipa_file"
            else
                echo "未找到 curl，正在尝试安装 ..."
                install_curl() {
                    echo "检测需要安装 curl ..."
                    if [ -x "$(command -v apt-get)" ]; then
                        echo "使用 apt-get 安装 curl ..."
                        sudo apt-get update && sudo apt-get install -y curl
                    elif [ -x "$(command -v yum)" ];then
                        echo "使用 yum 安装 curl ..."
                        sudo yum install -y curl
                    elif [ -x "$(command -v brew)" ];then
                        echo "使用 brew 安装 curl ..."
                        brew install curl
                    else
                        echo "错误: 找不到合适的包管理器来安装 curl。" >&2
                        exit 1
                    fi
                }

                install_curl

                if [ $? -ne 0 ]; then
                    echo "错误: 安装 curl 失败。" >&2
                    exit 1
                fi

                echo "curl 安装成功，继续下载 ..."

                curl -# -L --retry 3 --retry-delay 5 -o "$temp_ipa_file" "$ipa_file"
            fi

            if [ $? -ne 0 ]; then
                echo "错误: 下载 .ipa 文件失败。" >&2
                continue
            fi

            ipa_file="$temp_ipa_file"
        fi

        for deb_file in "$plugin_dir"/*.deb; do
            if [ ! -e "$deb_file" ];then
                echo "当前目录下未找到任何 .deb 文件。无需处理已跳过"
                continue
            fi

            target_folder="$extracted_plugin_dir/$(basename "$deb_file" .deb)"
            
            if [ ! -d "$target_folder" ];then
                mkdir -p "$target_folder"
                dpkg-deb -x "$deb_file" "$target_folder"
                echo "已解压 $deb_file 到 $target_folder"
            fi

            find "$target_folder" -type f -name "*.dylib" -exec cp -f {} "$extracted_plugin_dir" \;
            echo "已提取 $deb_file 中的 .dylib 文件到 $extracted_plugin_dir"

            rm -r "$target_folder"
            echo "已删除解压的文件夹 $target_folder"
        done

        injectipa_command="injectipa $ipa_file"

        dylib_files=("$extracted_plugin_dir"/*.dylib)
        dylib_list=""

        for dylib in "${dylib_files[@]}"; do
            dylib_file=$(basename "$dylib")
            annotation="${dylib_annotations[$dylib_file]}"
            if [ -z "$annotation" ]; then
                annotation="未找到注释"
            fi
            dylib_list="$dylib_list $dylib_file($annotation)"
            injectipa_command="$injectipa_command $dylib"
        done

        injectipa_command="$injectipa_command -s -p"
        read -p "请输入需要注入的资源，可注入bundle,图标库,图片这些仅支持注入一个 (回车跳过): " new_zip
        if [ ! -z "$new_zip" ];then
            injectipa_command="$injectipa_command -a $new_zip"
        fi
        
        read -p "请输入新的icon路径png格式 (回车跳过): " new_icon
        if [ ! -z "$new_icon" ];then
            injectipa_command="$injectipa_command -i $new_icon"
        fi

        read -p "请输入新的应用名称 (回车跳过): " new_name
        if [ ! -z "$new_name" ];then
            injectipa_command="$injectipa_command -n $new_name"
        fi

        read -p "请输入新的BundleID (回车跳过): " new_bundle_id
        if [ ! -z "$new_bundle_id" ];then
            read -p "是否移出跳转 (输入1移除，回车不移除): " remove_redirect
            if [ "$remove_redirect" == "1" ];then
                injectipa_command="$injectipa_command -b $new_bundle_id -u"
            else
                injectipa_command="$injectipa_command -b $new_bundle_id"
            fi
        fi

        echo "Constructed injectipa command: $injectipa_command"
        eval $injectipa_command
        if [ $? -eq 0 ];then
            echo "已成功执行 injectipa 命令：$injectipa_command"
            echo "包名: $(basename "$ipa_file")" >> "$result_file"
            echo "注入的dylib: $dylib_list" >> "$result_file"
            echo "时间: $current_time" >> "$result_file"
            echo "----------------------------------------" >> "$result_file"
        else
            echo "执行 injectipa 命令时出错：$injectipa_command" >&2
            exit 1
        fi
    done
}

# 函数：列出 GitHub 上的 IPA 文件
list_github_ipa_files() {
    github_repo="https://api.github.com/repos/yinanan77/Yi_WeChat/releases/tags/WeChat_dump"
    echo "正在从 GitHub 列出可用的 IPA 文件..."

    # 使用 curl 获取 GitHub 上的 IPA 文件列表
    ipa_list=$(curl -s "$github_repo" | grep -oP '(?<="browser_download_url": ")[^"]+' | grep '\.ipa$')

    if [ -z "$ipa_list" ];then
        echo "未找到任何 IPA 文件。"
        return
    fi

    echo "找到以下 IPA 文件："
    index=1
    declare -a ipa_urls
    for ipa_url in $ipa_list; do
        file_name=$(basename "$ipa_url")
        echo "$index - $file_name"
        ipa_urls[$index]=$ipa_url
        ((index++))
    done

    read -p "请输入要下载的 IPA 文件编号: " selection
    selected_url=${ipa_urls[$selection]}

    if [ -z "$selected_url" ];then
        echo "无效的选择。"
        return
    fi

    process_ipa_files "$selected_url"
}

# 函数：下载单个远程 IPA 文件
download_remote_ipa_file() {
    read -p "请输入远程 .ipa 文件链接: " ipa_url

    if [[ -z "$ipa_url" ]];then
        echo "未提供有效的链接。"
        return
    fi

    process_ipa_files "$ipa_url"
}

# 函数：从多个远程链接下载多个 IPA 文件
download_multiple_remote_ipa_files() {
    read -p "请输入多个远程 .ipa 文件链接（用空格分隔）: " -a ipa_urls

    if [ ${#ipa_urls[@]} -eq 0 ];then
        echo "未提供有效的链接。"
        return
    fi

    process_ipa_files "${ipa_urls[@]}"
}

# 函数：列出本地 IPA 文件
list_local_ipa_files() {
    ipa_files=("$local_ipa_dir"/*.ipa)
    if [ ${#ipa_files[@]} -eq 0 ];then
        echo "错误: 当前目录下未找到任何 .ipa 文件。"
        return
    fi
    process_ipa_files "${ipa_files[@]}"
}

# 主菜单
show_menu() {
    echo "========= 一键提取注入脚本菜单 ========="
    echo "1. 使用本地 .ipa 文件"
    echo "2. 下载并处理单个远程 .ipa 文件"
    echo "3. 下载并处理多个远程 .ipa 文件"
    echo "4. 从云端拉取砸壳权限 .ipa 文件"
    echo "5. 退出脚本"

    read -p "请输入选项数字: " choice

    case $choice in
        1) list_local_ipa_files ;;
        2) download_remote_ipa_file ;;
        3) download_multiple_remote_ipa_files ;;
        4) list_github_ipa_files ;;
        5) echo "感谢使用！脚本由 泡泡 & 夕颜 制作" && exit 0 ;;
        *) echo "哪有这个选项？从新选。" ;;
    esac

    show_menu
}

# 启动菜单
show_menu

