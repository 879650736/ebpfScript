#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int main() {
    int counter = 0;
    while (counter<99) { 
        // 分配内存但不释放（模拟内存泄漏）
        int *leak = (int*)malloc(1024 * sizeof(int));
        if (leak == NULL) {
            perror("malloc failed");
            exit(1);
        }

        // 正常分配并释放（模拟正常操作）
        int *no_leak = (int*)malloc(512 * sizeof(int));
        if (no_leak != NULL) {
            free(no_leak);
        }

        // 打印计数信息
        printf("Program running... (iteration %d)\n", counter++);
        sleep(1); // 休眠1秒，避免CPU占用过高
    }
    return 0;
}
