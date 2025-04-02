#include <stdlib.h>
int main() {
    while (1) {
        void *ptr = malloc(1024 * 1024); // 分配1MB
        free(ptr);
    }
    return 0;
}
