#include <unistd.h>
#include <proc.h>
#include <syscall.h>
#include <trap.h>
#include <stdio.h>
#include <pmm.h>
#include <console.h>
#include <error.h>
#include <assert.h>

/* Lab5 module 1: kernel-side syscall wrappers. */
static int sys_exit(uint64_t args[]) {
    return do_exit((int)args[0]);
}

static int sys_fork(uint64_t args[]) {
    (void)args;
    return do_fork(0, current->tf->gpr.sp, current->tf);
}

static int sys_wait(uint64_t args[]) {
    return do_wait((int)args[0], (int *)(uintptr_t)args[1]);
}

static int sys_exec(uint64_t args[]) {
    return do_execve((const char *)(uintptr_t)args[0], (size_t)args[1],
                     (unsigned char *)(uintptr_t)args[2], (size_t)args[3]);
}

static int sys_yield(uint64_t args[]) {
    (void)args;
    return do_yield();
}

static int sys_kill(uint64_t args[]) {
    return do_kill((int)args[0]);
}

static int sys_getpid(uint64_t args[]) {
    (void)args;
    return current->pid;
}

static int sys_putc(uint64_t args[]) {
    cons_putc((int)args[0]);
    return 0;
}

static int sys_pgdir(uint64_t args[]) {
    (void)args;
    print_pgdir();
    return 0;
}

static int (*syscalls[])(uint64_t args[]) = {
    [SYS_exit]   = sys_exit,
    [SYS_fork]   = sys_fork,
    [SYS_wait]   = sys_wait,
    [SYS_exec]   = sys_exec,
    [SYS_yield]  = sys_yield,
    [SYS_kill]   = sys_kill,
    [SYS_getpid] = sys_getpid,
    [SYS_putc]   = sys_putc,
    [SYS_pgdir]  = sys_pgdir,
};

#define NUM_SYSCALLS (sizeof(syscalls) / sizeof(syscalls[0]))

/* user/libs/syscall.c passes a0=number, a1..a5=arguments.
 * Store result in a0 so trap return delivers it to user mode. */
void syscall(void) {
    struct trapframe *tf = current->tf;
    uint64_t num = tf->gpr.a0;
    uint64_t args[5] = {
        tf->gpr.a1, tf->gpr.a2, tf->gpr.a3, tf->gpr.a4, tf->gpr.a5
    };

    int ret = -E_INVAL;
    if (num < NUM_SYSCALLS && syscalls[num] != NULL) {
        ret = syscalls[num](args);
    }
    tf->gpr.a0 = (uintptr_t)ret;
}
