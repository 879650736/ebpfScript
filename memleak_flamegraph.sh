#!/bin/bash

# 脚本名称: memleak_flamegraph.sh
# 功能: 将 memleak 输出转换为火焰图
# 用法: ./memleak_flamegraph.sh [输入文件] [输出文件]
-
# # 参数检查
# if [ $# -lt 1 ]; then
#   echo "用法: $0 <输入文件> [输出文件]"
#   echo "示例: $0 memleak_raw.txt memleak.svg"
#   exit 1
# fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-memleak.svg}"  # 默认输出文件为 memleak.svg
FLAMEGRAPH_DIR="$HOME/FlameGraph"
FLAMEGRAPH_PATH="$FLAMEGRAPH_DIR/flamegraph.pl"

# 检查输入文件是否存在
if [ ! -f "$INPUT_FILE" ]; then
  echo "错误: 输入文件 $INPUT_FILE 不存在"
  exit 1
fi


# 处理原始数据生成折叠格式
FOLDED_FILE="${INPUT_FILE}.folded"
awk -f memleak.akw "$INPUT_FILE" > "$FOLDED_FILE" || {
    echo "错误: 无法处理输入文件"
    exit 1
}

# 生成火焰图
echo "正在生成火焰图: $OUTPUT_FILE"
"$FLAMEGRAPH_PATH" --title="Memory Leak Flame Graph (bytes)" --countname=bytes "$FOLDED_FILE" > "$OUTPUT_FILE" || {
    echo "错误: 无法生成火焰图"
    exit 1
}

# # 清理临时文件
# rm -f "$FOLDED_FILE"

echo "完成! 火焰图已保存为: $OUTPUT_FILE"
