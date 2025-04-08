#include <fcntl.h>
#include <unistd.h>

int main() {
    creat("/tmp/program_created", 0644);  // 创建文件
    sleep(2);                             // 等待 2 秒
    unlink("/tmp/program_created");       // 删除文件
    return 0;
}