#include <defs.h>
#include <unistd.h>
#include <syscall.h>

/*
 * 使用固定五个参数，避免可变参数读取数量不匹配。
 * RV64 系统调用约定：
 * a0 保存系统调用号；
 * a1-a5 保存五个参数；
 * ecall 进入内核；
 * 返回值从 a0 读取。
 */
static inline int
syscall(int64_t num,
        uint64_t arg0,
        uint64_t arg1,
        uint64_t arg2,
        uint64_t arg3,
        uint64_t arg4) {
    int ret;

    asm volatile (
        "ld a0, %1\n"
        "ld a1, %2\n"
        "ld a2, %3\n"
        "ld a3, %4\n"
        "ld a4, %5\n"
        "ld a5, %6\n"
        "ecall\n"
        "sw a0, %0"
        : "=m" (ret)
        : "m" (num),
          "m" (arg0),
          "m" (arg1),
          "m" (arg2),
          "m" (arg3),
          "m" (arg4)
        : "a0", "a1", "a2", "a3", "a4", "a5", "memory"
    );

    return ret;
}

int sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code, 0, 0, 0, 0);
}

int sys_fork(void) {
    return syscall(SYS_fork, 0, 0, 0, 0, 0);
}

int sys_wait(int64_t pid, int *store) {
    return syscall(SYS_wait, pid, (uintptr_t)store, 0, 0, 0);
}

int sys_yield(void) {
    return syscall(SYS_yield, 0, 0, 0, 0, 0);
}

int sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid, 0, 0, 0, 0);
}

int sys_getpid(void) {
    return syscall(SYS_getpid, 0, 0, 0, 0, 0);
}

int sys_putc(int64_t c) {
    return syscall(SYS_putc, c, 0, 0, 0, 0);
}

int sys_pgdir(void) {
    return syscall(SYS_pgdir, 0, 0, 0, 0, 0);
}
