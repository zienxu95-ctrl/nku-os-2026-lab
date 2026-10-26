# 操作系统实验报告

## 实验基本信息

| 项目 | 内容 |
|------|------|
| **实验名称** | Lab 3：中断与异常处理 |
| **小组成员** | [程浩轩]、[徐子恩]、[胡家华] |


### 小组分工

**练习如何分工？**

| 成员 | 负责的练习/模块 |
|------|----------------|
| [程浩轩] | 功能模块一：Trap 上下文恢复与 Trap 入口功能（`RESTORE_ALL`、`__alltraps`） |
| [徐子恩] | 功能模块二：中断功能（`interrupt_handler`、`exception_handler`） |
| [胡家华] | 功能模块二：异常处理功能



## 一、实验目的

本实验的主要目的是：

1. 理解 RISC-V 中断和异常的基本机制，以及 `stvec`、`sstatus`、`sepc`、`scause` 等寄存器在 Trap 处理过程中的作用。
2. 掌握 Trap 进入内核时处理器上下文的保存和恢复，理解 Trap frame 在汇编入口与 C 语言处理函数之间的传递方式。
3. 完成 Trap 入口、C 语言处理、上下文恢复与 `sret` 返回的基本流程，并通过 QEMU 验证。
4. 在实验过程中使用 AI 辅助理解代码、定位编译和启动问题，同时核对生成代码与实验框架是否一致。

---

## 二、实验环境

- 系统：Windows 11 + WSL2 Ubuntu（实验命令在 Ubuntu 中执行）。
- 目标架构：RISC-V 64 位；使用 `riscv64-unknown-elf` 工具链。
- 模拟环境：QEMU `qemu-system-riscv64`，OpenSBI（运行截图显示 v0.9）。
- 实验代码：OS2026 Lab3 下载包 `lab3.zip`，解压目录 `~/OS2026-lab3/lab3_new`。
- 主要操作：`make clean`、`make`、`make qemu`，使用 `gedit` 编辑文件。

**使用的 AI 工具**

| 成员 | AI 编程工具 | 底层模型 | 备注 |
|------|------------|---------|------|
| [本人成员信息] | ChatGPT（聊天界面） | GPT-6 | 辅助分析 Trap 汇编、排查编译及 QEMU 启动问题 |
| [组员二信息] | [待组员填写] | [待组员填写] | [待组员填写] |
| [其他成员信息，如有] | [待填写] | [待填写] | [按需要删除] |

---

## 三、实验整体逻辑分析

### 2.1 本章节的逻辑主线

本章的核心是建立操作系统对中断、异常的统一处理流程。发生 Trap 后，处理器根据 `stvec` 转入汇编入口，内核先保存现场，随后把保存的数据以 `struct trapframe *` 传给 C 语言函数 `trap()`。C 语言部分判断是中断还是异常并执行相应处理；处理结束后恢复现场，使用 `sret` 返回原来的执行流程。

两部分模块存在先后依赖关系：模块一提供可靠的“进入和返回”通道，模块二才可以在其中实现时钟中断、非法指令异常和断点异常等具体逻辑。

### 2.2 功能的逐步实现

1. **初始化 Trap 入口**：`idt_init()` 将 `stvec` 设为 `__alltraps` 的地址。
2. **保存上下文**：发生 Trap 后进入 `__alltraps`，执行框架提供的 `SAVE_ALL`，形成 Trap frame。
3. **调用 C 函数**：把当前 `sp` 作为第一个参数传入 `a0`，执行 `jal trap`。
4. **分发和处理**：`trap()` 由 `trap_dispatch()` 将中断交给 `interrupt_handler()`，将异常交给 `exception_handler()`（具体由模块二完成）。
5. **恢复与返回**：跳转 `__trapret`，执行 `RESTORE_ALL` 及 `sret`，恢复原程序执行。

---

## 四、实验内容与实现

### 功能模块一：Trap 上下文恢复与 Trap 入口功能

**负责人：** [填写本人学号-姓名]

#### 模块功能描述

**需要实现/修改的函数或汇编入口：**

```asm
.macro RESTORE_ALL
    #lab3 function1 YOUR CODE
    # 恢复 Trap 前的寄存器和返回状态
.endm

.globl __alltraps
__alltraps:
    SAVE_ALL
    #lab3 function1 YOUR CODE
    # 调用 trap(struct trapframe *tf)，再进入 __trapret
```

实现文件：`kern/trap/trapentry.S`。接口函数是 `void trap(struct trapframe *tf);`，声明位于 `kern/trap/trap.h`，定义在 `kern/trap/trap.c`。

本模块没有修改框架原有 `SAVE_ALL` 和 `struct trapframe` 的布局。`SAVE_ALL` 在栈上预留 `36 * REGBYTES` 个字节，其中前 32 个位置对应 `pushregs` 的通用寄存器槽位，后四个依次保存 `sstatus`、`sepc`、`sbadaddr`、`scause`。其中原 `sp` 经 `sscratch` 暂存后写入第 2 号槽位。

**`RESTORE_ALL` 的主要实现：**

```asm
.macro RESTORE_ALL
    #lab3 function1 YOUR CODE
    LOAD t0, 32*REGBYTES(sp)
    csrw sstatus, t0
    LOAD t0, 33*REGBYTES(sp)
    csrw sepc, t0

    LOAD x1, 1*REGBYTES(sp)
    LOAD x3, 3*REGBYTES(sp)
    LOAD x4, 4*REGBYTES(sp)
    LOAD x6, 6*REGBYTES(sp)
    LOAD x7, 7*REGBYTES(sp)
    LOAD x8, 8*REGBYTES(sp)
    LOAD x9, 9*REGBYTES(sp)
    LOAD x10, 10*REGBYTES(sp)
    LOAD x11, 11*REGBYTES(sp)
    LOAD x12, 12*REGBYTES(sp)
    LOAD x13, 13*REGBYTES(sp)
    LOAD x14, 14*REGBYTES(sp)
    LOAD x15, 15*REGBYTES(sp)
    LOAD x16, 16*REGBYTES(sp)
    LOAD x17, 17*REGBYTES(sp)
    LOAD x18, 18*REGBYTES(sp)
    LOAD x19, 19*REGBYTES(sp)
    LOAD x20, 20*REGBYTES(sp)
    LOAD x21, 21*REGBYTES(sp)
    LOAD x22, 22*REGBYTES(sp)
    LOAD x23, 23*REGBYTES(sp)
    LOAD x24, 24*REGBYTES(sp)
    LOAD x25, 25*REGBYTES(sp)
    LOAD x26, 26*REGBYTES(sp)
    LOAD x27, 27*REGBYTES(sp)
    LOAD x28, 28*REGBYTES(sp)
    LOAD x29, 29*REGBYTES(sp)
    LOAD x30, 30*REGBYTES(sp)
    LOAD x31, 31*REGBYTES(sp)
    LOAD x5, 5*REGBYTES(sp)
    LOAD x2, 2*REGBYTES(sp)
.endm
```

这段代码先从 Trap frame 恢复 `sstatus` 和 `sepc`，然后恢复通用寄存器。`x5`（即 `t0`）被临时用于写 CSR，因此在最后才从栈中恢复；`x2` 就是栈指针 `sp`，必须最后恢复，否则后续寄存器加载就可能使用错误的栈基址。`x0` 恒为零，无需恢复；`scause` 与 `sbadaddr` 是陷入时的诊断信息，不属于这次 `sret` 必须恢复的状态。

**`__alltraps` 的主要实现：**

```asm
.globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    #lab3 function1 YOUR CODE
    mv a0, sp
    jal trap
    j __trapret

.globl __trapret
__trapret:
    RESTORE_ALL
    sret
```

其中 `mv a0, sp` 利用 RISC-V 调用约定将 Trap frame 首地址作为第一个参数交给 `trap()`；`jal trap` 进入 C 函数；返回后跳转 `__trapret`，由恢复宏和 `sret` 完成返回。`SAVE_ALL` 产生的 288 字节栈帧在 RV64 上满足调用前的栈对齐要求（前提是 Trap 入口原 `sp` 已按内核约定对齐）。

#### 最终提示词

以下是经过实验分析、代码实现和调试后，整理得到的最终提示词：

```text
[PROMPT]
请协助我完成操作系统 Lab3 的功能模块一：Trap 上下文恢复与 Trap 入口功能。

实验基于 RISC-V 64 位架构，主要修改 kern/trap/trapentry.S 文件。当前实验框架已经提供 SAVE_ALL 宏，需要我实现 RESTORE_ALL 宏，并完善 __alltraps 中的 C 语言函数调用过程。

请先分析已有 SAVE_ALL 的寄存器保存方式和 Trap frame 的内存布局，再给出需要修改的汇编代码，并解释每条关键指令的作用。实现后还需要指导我通过编译和 QEMU 测试验证 Trap 的进入与返回过程。

[RELY]
本模块可以依赖实验框架中已经提供的以下内容：

1. kern/trap/trapentry.S 中的 SAVE_ALL 宏，负责保存通用寄存器、sstatus、sepc、sbadaddr 和 scause。
2. kern/trap/trap.h 中的 struct pushregs 和 struct trapframe 结构体，用于规定寄存器保存顺序和 Trap frame 的内存布局。
3. kern/trap/trap.c 中的 trap(struct trapframe *tf) 函数，作为汇编代码进入 C 语言 Trap 处理流程的接口。
4. libs/riscv.h 中的 REGBYTES、LOAD、STORE 等宏，以及 RISC-V CSR 相关定义。
5. 已有的 __trapret 标签和 sret 指令，用于完成 Trap 返回。
6. 现有 Makefile、RISC-V 编译工具链和 QEMU 环境，用于编译和运行测试。

[GUARANTEE]
本模块必须完成以下功能：

1. 实现 RESTORE_ALL 宏，正确恢复 Trap 发生前保存的通用寄存器状态。
2. 恢复 sstatus 和 sepc，确保处理器能够返回正确的执行位置。
3. 完善 __alltraps，将保存的 Trap frame 地址作为参数传递给 trap() 函数。
4. 在 trap() 返回后进入 __trapret，完成寄存器恢复，并通过 sret 返回原执行流程。
5. 保证模块一与后续的 interrupt_handler()、exception_handler() 能够正确衔接。
6. 完成代码编译和基本 Trap 运行测试，验证中断处理后能够正常返回。

本模块只负责 Trap 上下文管理和入口功能，不直接实现模块二的具体中断与异常处理逻辑。

[SPECIFICATION]
1. RESTORE_ALL 必须严格按照 SAVE_ALL 的寄存器保存偏移进行恢复，不允许自行改变 Trap frame 的数据布局。
2. SAVE_ALL 使用 36 个 REGBYTES 保存上下文，其中前 32 个位置对应通用寄存器，后 4 个位置分别保存 status、epc、badvaddr 和 cause。
3. 恢复 sstatus 和 sepc 时，可以先通过 t0 临时寄存器读取对应栈位置，再使用 csrw 指令写回 CSR。
4. x0 为恒零寄存器，不需要恢复；t0 在使用完毕后恢复其原始值；sp 必须最后恢复，防止提前改变栈指针导致其他寄存器读取错误。
5. __alltraps 首先调用已有的 SAVE_ALL，再使用 mv a0, sp 将 Trap frame 地址放入第一个参数寄存器，随后使用 jal trap 调用 C 语言处理函数。
6. trap() 返回后通过 j __trapret 进入统一恢复流程，执行 RESTORE_ALL 和 sret。
7. 不修改 SAVE_ALL、struct trapframe 和 trap() 的原有接口，不修改模块二负责的具体处理逻辑。
8. 编译阶段使用 make clean 和 make 检查代码，运行阶段使用 make qemu，并利用临时测试处理函数验证连续时钟中断及 Trap 返回。
9. 测试代码需要与正式实验代码分开保存，避免影响后续模块二的实现与合并。
10. 保留实验框架中标记的 lab3 注释，便于最终检查和提交。
```


#### 实现迭代过程

本模块经历了代码实现、工程依赖修复和运行验证三个阶段。下面只记录实际对话中发生过的操作和现象。

##### 第一次迭代：实现 Trap 恢复及入口

**实施过程：** 查看 `trapentry.S`、`trap.h`、`trap.c`，发现框架已提供 `SAVE_ALL`，但 `RESTORE_ALL` 和 `__alltraps` 仍留有 `#lab3 function1 YOUR CODE`。依据寄存器保存位置实现恢复代码，并在 `__alltraps` 中加入 `mv a0, sp`、`jal trap` 和 `j __trapret`。

**初步结果：** `make -k` 输出中出现 `+ cc kern/trap/trapentry.S`，该汇编文件未报错，说明通过汇编检查；但整个项目尚未成功链接，不能据此认定运行正确。

##### 第二次迭代：解决编译与启动依赖问题

**遇到的问题及处理：**

1. `trap.c` 调用 `interrupt_handler`、`exception_handler` 时出现隐式声明错误。为独立测试模块一，临时加入函数声明和测试桩；组员二后续应替换为正式实现。
2. `best_fit_pmm.c` 缺少 `free_list`、`nr_free`。检查发现 `pmm.c` 选择的是 `default_pmm_manager`，因此仅在 Makefile 源文件列表中暂时过滤不使用的 Best Fit 文件。
3. `pmm.c` 调用 `page_init()` 但原 Lab3 框架未提供对应实现。从已完成的 Lab2 工程提取该函数，并针对缺少的 `PHYSICAL_MEMORY_END`、`KERNEL_BEGIN_PADDR` 补充与已有 Lab2 工程一致的内存布局宏。
4. 首次运行 QEMU 只显示 OpenSBI，没有显示内核日志。检查 Makefile 后，将 `qemu` 目标中的 `-device loader,file=$(UCOREIMG),addr=0x80200000` 改为 `-kernel $(UCOREIMG)`，此后进入内核并看到 `check_alloc_page() succeeded!`、`++ setup timer interrupts`。

以上是为了恢复 Lab3 可测试环境而进行的依赖调整，**不是模块一的主要功能实现**；最终合并时应由小组共同审核其保留方式。

##### 第三次迭代：临时测试桩与 Trap 返回验证

**测试方法：** 在临时 `trap_test_stub.c` 中收到时钟中断后调用 `clock_set_next_event()` 安排下一次中断，同时累加 `ticks` 并打印前三次中断。测试版 `kern_init()` 在正常执行循环中检查中断处理时设定的 `trap_test_seen` 标记，打印返回成功信息。这个标记是在 Trap 外部的正常执行流中观察到的，比单纯在中断处理函数内部打印更能说明 Trap 返回成功。

**实际运行输出：**

```text
++ setup timer interrupts
Module1 TEST: timer interrupt 1
Module1 TEST: returned from trap successfully!
Module1 TEST: timer interrupt 2
Module1 TEST: timer interrupt 3
```

**结果分析：** 编译、链接、QEMU 启动均成功；临时测试中能重复进入时钟中断处理函数，且在正常执行流中打印返回成功信息，支持模块一的 Trap 入口、保存、C 函数调用、恢复和 `sret` 返回路径通过基本运行测试。此测试并未逐项检查所有通用寄存器的数值一致性，也不等于模块二全部功能通过。

**关键改进点总结：**

1. 先用 `SAVE_ALL` 和 `struct trapframe` 交叉核对保存槽位，再写 `RESTORE_ALL`，避免自行猜测偏移。
2. 把内核依赖错误和模块一本身错误区分开，逐步修复链接、内存管理和启动参数。
3. 使用临时函数完成独立验证，测试完成后将其移出正式编译目录，避免与组员二实现冲突。

---

### 功能模块二：中断与异常处理功能

**负责人：** [组员二学号-姓名]

#### 模块功能描述

**需要实现/修改的函数：**

```c
void interrupt_handler(struct trapframe *tf);
void exception_handler(struct trapframe *tf);
```

**功能说明：** [待组员二填写：中断/异常分类、时钟中断计数与重设、非法指令及断点异常的处理与 `epc` 更新规则。]

#### 最终提示词

[待组员二粘贴真实 AI 交流形成的最终提示词。]

#### 实现迭代过程

##### 第一次迭代

[待组员二填写实际遇到的问题、修改策略和验证结果。]

##### 第二次迭代（如有）

[待组员二填写。]

---

### 练习：[其他练习标题，如有]

**负责人：** [填写]

[如课程要求还有其他练习，由对应组员补充；无则删除这一小节。]

### Challenge：[Challenge 标题，如有]

**负责人：** [填写]

[按实际完成情况补充；未做则明确说明或删除。]

---

## 五、测试与验证

### 5.1 模块一：内核启动与内存初始化

执行 `make clean`、`make` 和 `make qemu` 后，QEMU 输出内核初始化日志，可观察到 `memory management: default_pmm_manager`、`check_alloc_page() succeeded!` 及 `++ setup timer interrupts`。这证明测试环境可启动内核并执行到时钟初始化位置。

![模块一测试环境启动截图](./images/kernel_boot.png)

### 5.2 模块一：时钟 Trap 进入与返回

使用临时测试函数，实际观察到第一次时钟中断、返回原执行流后的确认输出，以及第二、第三次时钟中断。截图如下：

![模块一 Trap 返回测试截图](./images/module1_timer_test.png)

**结论：** 模块一已通过基础运行测试；尚未进行逐寄存器恢复值检查。临时测试处理函数只用于模块一验证，不计入组员二的正式实现。

### 5.3 模块二及整组联合测试

[待组员二补充：时钟中断预期次数、非法指令/断点异常的输出、`epc` 更新、异常返回等截图和分析。]

**最终 `make qemu` 截图：** [合并正式模块二代码后添加]

**`make grade` 结果：** [先确认此工程是否提供该目标；未实际运行前不可写“通过”]

---

## 六、实验总结与收获

### 对操作系统的理解

**模块一已完成部分：**

1. **Trap 与处理器上下文。** Trap 并非简单调用普通函数：硬件改变异常返回相关状态，内核还必须保存软件可见寄存器，才能在处理后恢复原执行流。
2. **Trap frame 与栈帧。** 本实验的 Trap frame 是特定布局的保存区，汇编中的偏移要与 C 语言 `struct trapframe` 字段顺序一致；普通 C 函数调用也使用栈，但两者的用途和保存约定不同。
3. **控制状态寄存器与返回。** `sepc` 指示返回执行位置，`sstatus` 保存返回所需的特权相关状态，`sret` 完成特权态陷入返回。`scause`、`sbadaddr` 则主要用于判断和诊断异常原因。
4. **中断与异常的分工。** 模块一负责通用进入/返回，模块二决定怎样处理具体原因。这样可以避免每种异常重复编写保存和恢复流程。
5. **理论中重要、但本实验暂未完整涉及的内容。** 例如用户态与内核态完整切换、多核中断路由、复杂设备中断优先级和抢占式调度，都需要更完整的内核机制支持。

**组员二补充：** [结合模块二的处理流程补充对异常分类、`epc` 调整及定时器中断的理解。]

### AI 协作开发的经验

本次实验中，我主要利用 AI 辅助阅读 `SAVE_ALL` 和 `struct trapframe` 的对应关系，并逐步定位编译、链接、QEMU 启动等问题。比较有帮助的做法是每次先提供真实的文件内容和终端报错，再针对单个问题修改，而不是直接替换整个工程。特别是在模块二尚未完成时，使用临时测试桩隔离问题，可以先验证模块一的基本流程。不过 AI 给出的汇编和工程修改仍需要与真实代码核对，不能只根据“编译成功”判断正确，还必须观察运行输出。

**组员二补充：** [填写本人的 AI 协作心得及最终小组总结。]
