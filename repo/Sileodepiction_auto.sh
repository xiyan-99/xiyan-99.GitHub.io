#!/bin/bash

# 定义插件根目录，这里存放多个插件目录
PLUGINS_DIR="path_to_plugins"

# 定义Depiction模板文件路径
TEMPLATE_FILE="path_to_template/depiction_template.json"

# 定义输出Depiction文件的目标目录
OUTPUT_DIR="output_depictions_json"

# 检查输出目录是否存在，不存在则创建
mkdir -p $OUTPUT_DIR

# 遍历每个插件目录
for PLUGIN_DIR in "$PLUGINS_DIR"/*; do
    if [[ -d "$PLUGIN_DIR" ]]; then
        # 获取插件目录下的control文件路径
        CONTROL_FILE="$PLUGIN_DIR/control"

        # 确保control文件存在
        if [[ -f "$CONTROL_FILE" ]]; then
            # 读取插件信息
            PACKAGE=$(grep '^Package:' $CONTROL_FILE | cut -d ':' -f 2 | xargs)
            VERSION=$(grep '^Version:' $CONTROL_FILE | cut -d ':' -f 2 | xargs)
            NAME=$(grep '^Name:' $CONTROL_FILE | cut -d ':' -f 2 | xargs)
            DESCRIPTION=$(grep '^Description:' $CONTROL_FILE | cut -d ':' -f 2 | xargs)

            # 生成对应插件的Depiction文件
            OUTPUT_FILE="$OUTPUT_DIR/${PACKAGE}_depiction.json"

            if [[ -f $TEMPLATE_FILE ]]; then
                # 读取模板并替换占位符
                sed -e "s/{{Name}}/$NAME/g" \
                    -e "s/{{Version}}/$VERSION/g" \
                    -e "s/{{Description}}/$DESCRIPTION/g" \
                    $TEMPLATE_FILE > $OUTPUT_FILE
                echo "JSON格式的Depiction文件生成成功：$OUTPUT_FILE"
            else
                echo "模板文件不存在：$TEMPLATE_FILE"
                exit 1
            fi
        else
            echo "control文件不存在：$CONTROL_FILE"
        fi
    fi
done