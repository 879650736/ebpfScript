#include <sched.h>
#include <stdio.h>

int main()
{
    int ret = sched_yield();
    if (ret == 0)
    {
        printf("sched_yield called successfully.\n");
    }
    else
    {
        perror("sched_yield failed");
    }
    return 0;
}
