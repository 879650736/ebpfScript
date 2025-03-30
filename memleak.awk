BEGIN {
    stack = ""
    bytes = 0
    current_block = 0
    last_fn = ""
}

# 匹配分配头信息（兼容制表符和空格）
/^[[:blank:]]*[0-9]+ bytes in [0-9]+ allocations from stack[[:blank:]]*$/ {
    if (current_block == 1 && stack != "") {
        print stack " " bytes
        stack = ""
        last_fn = ""
    }
    bytes = $1
    current_block = 1
    next
}

# 处理调用栈行（兼容制表符分隔）
(current_block == 1) && /^[[:blank:]]*0x[0-9a-f]+/ {
    # 提取函数名（兼容制表符和空格分隔）
    if (match($0, /0x[0-9a-f]+[[:blank:]]+([^+\[[:blank:]]+)/, arr)) {
        fn = arr[1]
        # 去重：跳过连续重复函数
        if (fn != last_fn) {
            stack = (stack == "") ? fn : stack ";" fn
            last_fn = fn
        }
    }
}

END {
    if (current_block == 1 && stack != "") {
        print stack " " bytes
    }
}
