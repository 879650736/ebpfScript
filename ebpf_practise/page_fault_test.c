#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>

#define MEM_SIZE (1024 * 1024 * 1024) // 1GB
#define FILE_SIZE (1024 * 1024 * 100) // 100MB

// 触发写时复制（COW）的 Minor Fault
void trigger_minor_fault() {
    char *buffer = malloc(MEM_SIZE);
    if (!buffer) {
        perror("malloc failed");
        exit(1);
    }

    // 逐页写入数据（触发 COW）
    for (size_t i = 0; i < MEM_SIZE; i += 4096) {
        buffer[i] = i % 256; // 写入数据触发缺页
    }

    free(buffer);
}

// 触发文件映射的 Major Fault
void trigger_major_fault() {
    int fd = open("testfile.dat", O_RDWR | O_CREAT, 0666);
    if (fd == -1) {
        perror("open failed");
        exit(1);
    }

    // 扩展文件大小并填充内容
    ftruncate(fd, FILE_SIZE);
    char *file_map = mmap(NULL, FILE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (file_map == MAP_FAILED) {
        perror("mmap failed");
        close(fd);
        exit(1);
    }

    // 访问文件映射的每个页（触发 Major Fault）
    for (size_t i = 0; i < FILE_SIZE; i += 4096) {
        file_map[i] = i % 256; // 写入数据触发缺页
    }

    munmap(file_map, FILE_SIZE);
    close(fd);
}

int main() {
    printf("测试程序启动，PID=%d\n", getpid());
    sleep(10);

    // 触发 Minor Fault（写时复制）
    printf("触发 Minor Fault...\n");
    trigger_minor_fault();

    // 触发 Major Fault（文件映射）
    printf("触发 Major Fault...\n");
    trigger_major_fault();

    // 附加测试：fork 子进程触发 COW
    printf("触发 fork + COW...\n");
    pid_t pid = fork();
    if (pid == 0) {
        // 子进程修改数据（触发 COW）
        char *buffer = malloc(MEM_SIZE);
        for (size_t i = 0; i < MEM_SIZE; i += 4096) {
            buffer[i] = (i + 1) % 256;
        }
        free(buffer);
        exit(0);
    } else if (pid > 0) {
        wait(NULL);
    } else {
        perror("fork failed");
    }

    printf("测试完成。\n");
    sleep(10);
    return 0;
}
