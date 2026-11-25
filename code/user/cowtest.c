#include <ulib.h>
#include <stdio.h>

static char shared[32] = "parent-data";

int main(void)
{
    int pid = fork();
    if (pid < 0) {
        cprintf("cowtest fork failed\n");
        return -1;
    }
    if (pid == 0) {
        shared[0] = 'C';
        cprintf("child sees %s\n", shared);
        if (shared[0] != 'C') {
            cprintf("cowtest fail.\n");
            exit(-1);
        }
        exit(0);
    }

    int code = 0;
    if (waitpid(pid, &code) != 0 || code != 0) {
        cprintf("cowtest wait failed code=%d\n", code);
        return -1;
    }
    cprintf("parent sees %s\n", shared);
    if (shared[0] != 'p') {
        cprintf("cowtest fail.\n");
        return -1;
    }
    shared[0] = 'P';
    cprintf("parent writes %s\n", shared);
    cprintf("cowtest pass.\n");
    return 0;
}
