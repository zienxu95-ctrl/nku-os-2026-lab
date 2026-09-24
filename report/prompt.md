# Lab1 AI 提示词汇总


## 1. 实验识别与指导书分析

1. `请根据本实验的 RISC-V 64 位 uCore Lab1 环境要求，检查 riscv64-unknown-elf-gcc、riscv64-unknown-elf-ld、riscv64-unknown-elf-gdb 和 qemu-system-riscv64 是否配置正确，并说明这些工具在交叉编译、链接、调试和模拟执行中的作用。`
2. `请分析 kern_init() 的执行逻辑，说明 memset(edata, 0, end - edata) 与 .bss 段初始化之间的关系，并解释为什么内核最后使用无限循环保持运行状态。`
3. `请解释 bin/kernel 与 bin/ucore.img 的区别，并结合 file、readelf 和 nm 的输出说明 ELF 文件中的调试信息、符号表、入口地址与裸二进制镜像之间的关系。`

## 2. Lab1 源码准备与环境处理

4. `请使用 readelf 和 nm 验证内核入口地址是否为 0x80200000，并说明 kernel.ld 中的基地址、kern_entry 的符号地址以及 ELF Header 中 Entry Point 三者为什么应当保持一致`
5. 请分析 kern/init/entry.S 中 kern_entry 的执行过程，重点解释 la sp, bootstacktop 和 tail kern_init 的作用，以及为什么内核进入 C 语言代码之前必须先初始化栈指针。
6. 在发现系统没有 `unzip` 后，提供终端提示并询问后续处理。

## 3. 编译、链接、ELF 与 QEMU 启动

8. 请解释 QEMU、OpenSBI 和 uCore 内核三者在 Lab1 启动过程中的关系，并说明 OpenSBI 的 Firmware Base、Domain0 Next Address 和 Domain0 Next Mode 分别代表什么
9. 当前使用 -device loader,file=...,addr=0x80200000 时，OpenSBI 的 Domain0 Next Address 为 0，内核无法正常执行；而使用 -kernel bin/ucore.img 后可以成功进入 0x80200000。请分析两种启动方式的区别，并给出适合当前 QEMU/OpenSBI 环境的 Makefile 修改方案。
10. `我退不出去 qemu`
11. 在修改 Makefile 后，提供 `make qemu` 黑屏情况并提示：`一直这样`
12. 提供成功的 OpenSBI/QEMU 启动画面，请 AI 确认 `Domain0 Next Address = 0x80200000` 与 `(THU.CST) os is loading ...` 是否代表实验成功。

## 4. 链接脚本、内存布局与反汇编

13.请使用 riscv64-unknown-elf-readelf -S 和 riscv64-unknown-elf-nm -n 分析内核中 .text、.rodata、.data、.sdata 等段以及 bootstack、bootstacktop、edata、end 等符号的实际地址，并与链接脚本中的布局进行对应。
14. 请对 kern_entry 进行反汇编，分析 la sp, bootstacktop 和 tail kern_init 在 RISC-V 指令层面被展开成哪些指令，并解释伪指令与实际机器指令之间的关系。
15. `继续`

## 5. SBI、ecall 与 GDB 调试

16. 请使用 QEMU 的 GDB Server 和 riscv64-unknown-elf-gdb 在 kern_entry 设置断点，观察程序计数器 pc 和栈指针 sp 的变化，并验证 CPU 是否从 0x80200000 开始执行内核。
17. 在 kern_entry 中对 la sp, bootstacktop 进行单步调试，比较执行前后的 sp 值，并结合符号表中 bootstacktop 的地址验证内核栈是否初始化正确。
18. 请通过 GDB 单步执行验证 kern_entry 如何跳转到 kern_init，并使用调用栈信息说明汇编启动代码与 C 语言内核初始化代码之间的衔接过程。
19. 请分析并验证 kern_init → cprintf → vcprintf → vprintfmt → cputch → cons_putc 的调用关系，说明格式化字符串最终如何被拆分为单个字符输出。
20. 请使用 GDB 在 sbi_console_putchar 的 ecall 指令前设置断点，观察 a0、a1、a2 和 a7 寄存器的值，并说明这些寄存器如何按照 RISC-V SBI 调用约定传递字符参数和服务号。
21. 当内核输出字符串 (THU.CST) os is loading ... 时，请以第一个字符 '(' 为例，结合其 ASCII 值 40（0x28） 和 GDB 中 a0=0x28、a7=1 的结果，说明一次 SBI Console Putchar 调用的完整执行过程。

## 7. 本次 AI 辅助内容概括

本次 AI 主要用于：

- 分析 Lab1 指导书目标和源码结构；
- 指导 WSL 下 RISC-V 交叉编译工具链和 QEMU 使用；
- 分析 Makefile、`kernel.ld`、`entry.S`、`init.c`、`stdio.c`、`console.c` 和 `sbi.c`；
- 定位并解决本机 QEMU/OpenSBI 环境下原 `-device loader` 启动方式无法正确进入内核的问题；
- 指导 `readelf`、`nm`、`objdump` 验证 ELF、符号和机器指令；
- 指导 GDB 验证 `kern_entry → kern_init → cprintf → SBI ecall`；
