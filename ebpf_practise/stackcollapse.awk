
BEGIN {
    in_block = 0;
    block_content = "";
}

/^@\[/ {
    in_block = 1;
    block_content = "";
    next;
}

/\]: [0-9]+$/ {
    if (in_block) {
        in_block = 0;
        match($0, /]: ([0-9]+)$/, arr);
        count = arr[1];

        # Split into two parts based on comma
        split(block_content, parts, /,[[:space:]]*/);
        part1 = parts[1];  # Kernel/exception part
        part2 = parts[2];  # Userspace part

        # Process part2 (userspace) and reverse
        num_lines = split(part2, lines, /\n/);
        userspace = "";
        for (i = num_lines; i >= 1; i--) {
            if (lines[i] ~ /^[[:space:]]*$/) continue;
            sub(/\+.*/, "", lines[i]);
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", lines[i]);
            if (userspace == "") userspace = lines[i];
            else userspace = userspace ";" lines[i];
        }

        # Process part1 (kernel) and reverse
        num_lines = split(part1, lines, /\n/);
        kernel = "";
        for (i = num_lines; i >= 1; i--) {
            if (lines[i] ~ /^[[:space:]]*$/) continue;
            sub(/\+.*/, "", lines[i]);
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", lines[i]);
            if (kernel == "") kernel = lines[i];
            else kernel = kernel ";" lines[i];
        }

        # Combine userspace and kernel
        full_chain = userspace;
        if (kernel != "") {
            if (full_chain != "") full_chain = full_chain ";" kernel;
            else full_chain = kernel;
        }

        print full_chain " " count;
    }
    next;
}

in_block {
    sub(/^[[:space:]]+/, "");
    block_content = block_content $0 "\n";
}
