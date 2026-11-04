# Lab3 提示词

本文件参照 Lab2 的 `prompt.md` 编排，面向 **RISC-V uCore Lab3：中断与异常处理**。所有提示词统一采用 `[PROMPT]`、`[RELY]`、`[GUARANTEE]`、`[SPECIFICATION]` 四段式结构。

本实验按两大功能模块拆为 **4 份任务提示词**：

| 编号 | 练习位置 | 提示词作用 | 主要文件 |
| --- | --- | --- | --- |
| 任务 1 | 功能模块一 | 实现 `RESTORE_ALL` 与 `__alltraps` | `kern/trap/trapentry.S` |
| 任务 2-A | 功能模块二 · 中断处理 | 实现 `interrupt_handler()`，完成时钟中断计数、下一次定时器设置、统计输出与关机 | `kern/trap/trap.c` |
| 任务 2-B | 功能模块二 · 异常处理 | 实现 `exception_handler()`，处理非法指令、断点与未知异常 | `kern/trap/trap.c` |
| 任务 3 | 联合集成与验收 | 检查 Trap 入口—处理—返回闭环，完成测试与清理 | `trapentry.S`、`trap.c`、`clock.c`、`init.c` 等 |

> **适用范围和约束**：以下内容根据 Lab3 练习说明及本组此前实际查看的框架编写。框架里已确认 `SAVE_ALL`、`struct trapframe`、`trap()`、`trap_dispatch()`、`clock_set_next_event()` 和 `ticks` 等接口；`SHUTDOWN_AFTER`、关机函数以及不同异常类型的确切输出格式应先核对当前工程或课程要求，不能凭空假定已存在。任务 3 的临时测试代码不得冒充最终模块二实现。实验未要求的 Challenge 不自行添加。

---

# 任务 1　功能模块一：Trap 上下文恢复与 Trap 入口

[PROMPT]

**任务**：修改 `kern/trap/trapentry.S`，补全 `RESTORE_ALL` 汇编宏和 `__alltraps` Trap 入口处标有 `#lab3 function1 YOUR CODE` 的内容，打通 `SAVE_ALL → trap(struct trapframe *tf) → RESTORE_ALL → sret` 的执行流程。

**输出要求**：直接修改指定目标文件的标记位置，而不是只展示示例代码；保留 `SAVE_ALL`、`__trapret`、`sret`、现有函数符号与汇编宏；保留 `lab3` 标记并按课程规定填写学号，不能重写整个汇编文件。

**输入要求**：先阅读真实工程中的 `kern/trap/trapentry.S`、`kern/trap/trap.h`、`kern/trap/trap.c` 与 `libs/riscv.h`，根据 `SAVE_ALL` 和 `struct trapframe` 的布局确定每个偏移；不要依赖其他版本 uCore 的寄存器布局。

[RELY]

已提供的保存宏的关键结构：

```asm
.macro SAVE_ALL
    csrw sscratch, sp
    addi sp, sp, -36 * REGBYTES
    STORE x0, 0*REGBYTES(sp)
    STORE x1, 1*REGBYTES(sp)
    # ... x3 到 x31 对应槽位；原始 x2(sp) 经 sscratch 保存
    csrrw s0, sscratch, x0
    csrr s1, sstatus
    csrr s2, sepc
    csrr s3, sbadaddr
    csrr s4, scause
    STORE s0, 2*REGBYTES(sp)
    STORE s1, 32*REGBYTES(sp)
    STORE s2, 33*REGBYTES(sp)
    STORE s3, 34*REGBYTES(sp)
    STORE s4, 35*REGBYTES(sp)
.endm
```

现有 C 语言接口与数据布局：

```c
struct trapframe {
    struct pushregs gpr;  /* 按 x0 至 x31 的槽位顺序 */
    uintptr_t status;
    uintptr_t epc;
    uintptr_t badvaddr;
    uintptr_t cause;
};

void trap(struct trapframe *tf);
```

可依赖的已定义符号：`REGBYTES`、`LOAD`、`STORE`、`__alltraps`、`__trapret`、`sret`。`idt_init()` 已通过 `write_csr(stvec, &__alltraps)` 设置入口。RV64 中 `REGBYTES=8`，Trap frame 按本框架占用 `36×8=288` 字节。

[GUARANTEE]

需要实现或补全：

```asm
.macro RESTORE_ALL
    #lab3 function1 YOUR CODE
.endm

.globl __alltraps
__alltraps:
    SAVE_ALL
    #lab3 function1 YOUR CODE

.globl __trapret
__trapret:
    RESTORE_ALL
    sret
```

- `RESTORE_ALL` 能从当前 Trap frame 中正确恢复 `sstatus`、`sepc` 和全部需要恢复的通用寄存器。
- `__alltraps` 能遵循 RISC-V 调用约定，将 `struct trapframe *` 传给 `trap()`，并在其返回后进入统一 Trap 返回路径。
- 不改变 `trap(struct trapframe *tf)` 的接口，不修改组员负责的中断与异常具体处理函数。

[SPECIFICATION]

## RESTORE_ALL

**Pre-Condition**：已通过 `SAVE_ALL` 分配并填充本框架的 36 槽 Trap frame；当前 `sp` 指向该帧起始地址；C 处理函数已正常返回并恢复调用前 `sp`。

**Post-Condition**：

- 从第 32、33 槽分别加载并恢复 `sstatus`、`sepc`，保留处理函数对 `tf->epc` 等字段的合法修改。
- 通用寄存器从对应原始槽位加载；`x0` 为硬连线零寄存器，不需要恢复。
- 如使用 `t0`/`x5` 临时写 CSR，应在最后阶段恢复其原值。
- `x2` 即 `sp` 最后恢复，确保此前所有 `LOAD` 仍以 Trap frame 为基址。
- 不将 `scause` 和 `sbadaddr` 当成 `sret` 所必需的返回状态，也不随意更改 `sscratch` 的内核态约定。

**Case 1**（普通时钟中断返回）：`tf->epc` 通常保持不变；恢复后从被中断处继续执行。

**Case 2**（异常处理修改了 `tf->epc`）：从修改后的槽位恢复 `sepc`，使 `sret` 返回处理函数指定的合法执行位置。

## __alltraps

**Pre-Condition**：`stvec` 已正确指向 `__alltraps`；Trap 进入时处理器已将相关 CSR 状态记录好。

**Post-Condition**：先 `SAVE_ALL`；将当前 `sp` 复制至 `a0`；调用 `trap`；函数返回后进入 `__trapret`；恢复后由已有 `sret` 返回。

**Requirements**：

- 使用已有 C 接口，不重新设计结构体、寄存器偏移或 `SAVE_ALL`。
- `jal trap` 会修改 `ra`，但原始 `ra` 已在 Trap frame 保存，后续由 `RESTORE_ALL` 恢复。
- `__alltraps` 作为异步进入的 Trap 入口，不可当成普通 C 函数直接调用进行验证。
- 单独汇编成功仅说明语法及目标文件生成正常；还必须进行真正的 Trap 触发与返回测试。

---

# 任务 2-A　功能模块二：时钟中断与其他中断处理

[PROMPT]

**任务**：修改 `kern/trap/trap.c`，在 `#lab3 function2 YOUR CODE` 位置实现 `interrupt_handler(struct trapframe *tf)`。首先正确识别 S 模式时钟中断，并完成下一次时钟事件设置、计数、统计输出、达到实验规定次数后的系统关机；其他类型中断按要求给出明确兜底诊断。

**输出要求**：直接修改目标文件，不重写 `trap_dispatch()`、`trap()`、`idt_init()`、`print_trapframe()` 等现有函数；保持函数签名不变。不新增永久测试桩与正式实现重复定义。

**输入要求**：读取 `kern/trap/trap.c`、`kern/driver/clock.c`、`kern/driver/clock.h`、`libs/riscv.h`、`libs/sbi.h`（必要时 `sbi.c`），核对 `IRQ_S_TIMER`、`TICK_NUM`、`SHUTDOWN_AFTER` 和关机接口是否存在及其实际名称。不能擅自编造框架已有的常量或函数。

[RELY]

已确认的关键接口：

```c
/* trap.c */
#define TICK_NUM 100
void trap(struct trapframe *tf);
static inline void trap_dispatch(struct trapframe *tf);
void print_trapframe(struct trapframe *tf);

/* clock.c */
volatile size_t ticks;
void clock_set_next_event(void);

/* Trap 识别依据 */
/* RV64 的 scause 最高位表示 interrupt，其余低位表示 cause 编号 */
```

已知 `clock_init()` 中启用了时钟中断并调用 `clock_set_next_event()` 安排首次事件，最后打印 `++ setup timer interrupts`。本框架此前存在的 `print_ticks()` 可用于按规定周期输出统计，但需检查其当前可见范围与格式要求。

[GUARANTEE]

需要实现：

```c
void interrupt_handler(struct trapframe *tf);
```

- 根据 `tf->cause` 区分 S 模式时钟中断和其他中断。
- 在每次被处理的时钟中断中及时调用 `clock_set_next_event()`，保证连续事件可发生。
- 正确更新 `ticks`，按 `TICK_NUM` 的整数倍输出框架要求的统计信息。
- 当达到课程规定的 `SHUTDOWN_AFTER` 或等效阈值时，调用工程确有定义的关机接口，执行要求中的系统关机；不得用死循环或 `panic` 假装正常关机。
- 对未知中断明确报告原因码，必要时利用 `print_trapframe(tf)` 辅助诊断，不得不分类型地当成时钟中断处理。

[SPECIFICATION]

## interrupt_handler

**Pre-Condition**：`trap_dispatch(tf)` 已判定为中断；`tf` 指向有效 Trap frame；时钟驱动初始化完成。

**Post-Condition**：

**Case 1**（`IRQ_S_TIMER`，正常持续运行）：
- 识别中断位和原因码；按工程使用的中断号宏而非随意写“魔法数字”。
- 先或及时设置下一次时钟事件 `clock_set_next_event()`，保证当前中断返回后后续时钟事件仍可到来。
- `ticks` 每次有效时钟中断递增一次。
- 仅在达到 `TICK_NUM` 整倍数时输出规定的统计文字，避免每次中断都刷屏。

**Case 2**（达到关机阈值）：
- 先明确计数单位（是 tick 次数，还是每 `TICK_NUM` tick 记一次统计周期），按实验指导约定判断阈值。
- 从项目中查找 `SHUTDOWN_AFTER` 定义和 `libs/sbi.h` 实际关机接口；若二者未定义，先报告缺项并给出与工程兼容的最小补充方案，避免静默硬编码。
- 到达阈值时按要求输出最终统计并调用真正的关机接口。

**Case 3**（其他中断）：
- 打印明确的类型和原因编号，必要时打印 Trap frame；不得误增加 `ticks`。
- 不在未识别中断上伪造确认/清除操作；避免无休止地重复进入未知中断而无诊断。

**Requirements**：

- 保留已有 `trap_dispatch()` 对中断和异常的分类路径。
- `tf->cause` 的最高位需先去除再比较原因编号；不要直接把含中断位的整个值与低位原因常量比较。
- 仅修改模块二标记范围及确有必要的局部声明，不破坏模块一的 `trapentry.S`。
- 对时间相关输出和关机行为用 QEMU 实际验证，不把 `clock_init()` 的初始化输出当成“时钟中断已处理成功”。

---

# 任务 2-B　功能模块二：非法指令、断点及其他异常

[PROMPT]

**任务**：继续在 `kern/trap/trap.c` 的 `#lab3 function2 YOUR CODE` 标记处实现 `exception_handler(struct trapframe *tf)`，根据 `tf->cause` 区分非法指令异常、断点异常与其他异常，按实验规定输出异常信息，并对需要继续执行的测试正确更新 `tf->epc`。

**输出要求**：直接修改目标文件，保留现有打印辅助函数；不重写 Trap frame 数据布局；不得简单固定地对所有异常执行 `tf->epc += 4`。

**输入要求**：阅读 `trap.c`、`trap.h`、`libs/riscv.h` 及实验指导中对非法指令和断点异常的输出格式与处理方式要求；核对 `CAUSE_ILLEGAL_INSTRUCTION`、`CAUSE_BREAKPOINT` 等宏的确切定义，以及当前编译选项是否允许压缩指令。

[RELY]

```c
struct trapframe {
    struct pushregs gpr;
    uintptr_t status;
    uintptr_t epc;
    uintptr_t badvaddr;
    uintptr_t cause;
};

void print_trapframe(struct trapframe *tf);
void trap(struct trapframe *tf);

/* 从 riscv.h 核对实际定义后使用： */
/* CAUSE_ILLEGAL_INSTRUCTION */
/* CAUSE_BREAKPOINT */
```

`trap_dispatch(tf)` 已经区分中断和异常，本任务只负责异常分支。`tf->epc` 表示用于恢复 `sepc` 的返回位置；`tf->badvaddr` 提供异常相关附加信息，其有效含义随异常类型而变。

[GUARANTEE]

需要实现：

```c
void exception_handler(struct trapframe *tf);
```

- 非法指令异常和断点异常按课程要求输出规定格式的信息。
- 如果实验要求处理后跳过触发指令并继续执行，必须按实际指令长度调整 `tf->epc`，避免重复触发同一异常。
- 遇到其他异常时，使用 `print_trapframe(tf)` 输出完整诊断信息，再按照工程或实验要求采取明确的兜底策略。
- 不影响时钟中断处理路径；异常处理返回后由模块一统一恢复 Trap frame。

[SPECIFICATION]

## exception_handler

**Pre-Condition**：`trap_dispatch(tf)` 已判定为同步异常；`tf` 有效；`cause` 的异常编号可用于分类。

**Post-Condition**：

**Case 1**（非法指令异常）：
- 识别 `CAUSE_ILLEGAL_INSTRUCTION`，按指导书规定输出异常类型和相关 Trap 信息。
- 检查指导书是否要求“跳过并继续”还是“诊断后终止”；不擅自将所有非法指令当成可安全跳过。
- 仅在实验明确要求继续、且能安全判断触发指令长度时修改 `tf->epc`。

**Case 2**（断点异常）：
- 识别 `CAUSE_BREAKPOINT`，按规定输出信息。
- 若需继续运行，确认触发的是 16 位 `c.ebreak` 还是 32 位 `ebreak`，相应跳过 2 或 4 字节；不能固定使用同一偏移。

**Case 3**（未知或其他异常）：
- 打印异常编号与 `print_trapframe(tf)`；根据框架要求终止/诊断，不应不经判断就修改 `epc` 并继续。

**Requirements**：

- RISC-V 压缩指令是否启用，应以工程实际 ISA/编译配置为准。普通 32 位指令和压缩 16 位指令的长度规则不同。
- 如通过读取 `tf->epc` 对应的指令半字判断长度，须考虑该地址可访问性，避免异常处理器因无效取指地址再触发异常；仅在受控测试前提下采用安全方案。
- 保留课程要求的准确输出格式，不能仅打印笼统的 `exception happened`。
- 不修改 `trap()` 的签名，不把异常处理与 `RESTORE_ALL` 耦合在一起。

---

# 任务 3　Lab3 联合集成、测试与提交检查

[PROMPT]

**任务**：集成功能模块一和模块二，完成 Lab3 的编译、QEMU 运行、时钟中断与异常测试、临时测试桩清理，并输出可写入实验报告的真实测试记录及检查结果。

**输出要求**：仅在明确必要的代码位置进行最小修复。给出修改的文件列表、可重复执行的终端命令、实际测试输出与结论；不要虚构 `make grade` 成绩，也不要把临时桩函数当作模块二最终实现。

**输入要求**：先完整检查 `Makefile`、`kern/init/init.c`、`kern/init/entry.S`、`kern/trap/trapentry.S`、`kern/trap/trap.c`、`kern/driver/clock.c`，以及已移植的 Lab2 内存管理依赖。保留本组已有的模块一实现和组员模块二代码。

[RELY]

已确认的工程与测试事实：

- WSL Ubuntu 下使用 RISC-V 工具链及 `qemu-system-riscv64`。
- 本组在 `lab3_new` 中已完成 `RESTORE_ALL` 和 `__alltraps` 的基础实现。
- 当前实验曾因缺失 `page_init()`、`PHYSICAL_MEMORY_END`、`KERNEL_BEGIN_PADDR` 而无法编译，后从已完成 Lab2 工程移植必要依赖。
- `best_fit_pmm.c` 未完成且当前使用 `default_pmm_manager`，此前通过 Makefile 临时排除该未使用文件。
- QEMU 原先使用 `-device loader,file=$(UCOREIMG),addr=0x80200000` 时未正确进入内核；改为 `-kernel $(UCOREIMG)` 后出现正常内核初始化输出。
- 临时测试版本曾输出：

```text
++ setup timer interrupts
Module1 TEST: timer interrupt 1
Module1 TEST: returned from trap successfully!
Module1 TEST: timer interrupt 2
Module1 TEST: timer interrupt 3
```

以上仅证明**模块一在临时测试环境下的基本 Trap 进入和返回**，并不证明最终模块二、异常处理及自动评分全部通过。

[GUARANTEE]

需要完成的集成检查：

```text
1. make clean && make
2. make qemu
3. 验证连续时钟中断计数、统计输出和规定的最终关机
4. 验证非法指令异常和断点异常的分类及返回策略
5. 检查未知中断/异常兜底输出
6. 清理测试桩、恢复正式初始化代码并重新编译/运行
7. 整理报告中的命令、截图、输出及修改清单
```

- 模块一和模块二应共用已有的 `struct trapframe` 与 `trap()` 接口。
- 不允许两个正式源文件重复定义 `interrupt_handler()` 或 `exception_handler()`。
- 测试后保留的代码必须与最后提交的实验代码一致。

[SPECIFICATION]

## 集成构建

**Pre-Condition**：模块一、模块二代码均已合并到同一工程，Lab2 前置依赖正确，工具链可用。

**Post-Condition**：`make clean && make` 完成编译与链接，内核镜像生成；若失败，定位是编译、汇编还是链接错误，不允许通过注释核心处理函数绕过问题。

**Case 1**（函数缺声明）：根据接口补齐必要声明，说明声明与定义的区别。

**Case 2**（`undefined reference`）：确认模块二处理函数真正存在且已参与链接；删除临时测试桩，避免重复定义。

**Case 3**（Lab2 依赖仍缺失）：从此前已验证的 Lab2 代码中最小迁移必要实现，不能直接用不兼容的整文件覆盖或硬编码错误物理地址。

## QEMU 启动与计时

**Pre-Condition**：成功链接，启动参数与链接地址及固件交接方式一致。

**Post-Condition**：看到内核加载、物理内存初始化和时钟初始化信息；实际发生连续时钟中断，在规定计数时输出统计，并在要求阈值处正常关机。

**Case 1**（只显示 OpenSBI）：检查 `Domain0 Next Address`、`-kernel` 与 `-device loader` 的差异，避免将镜像“加载到内存”误认为已将该地址设为入口。

**Case 2**（仅首次时钟中断发生）：核查处理函数是否调用 `clock_set_next_event()`；检查中断使能和 `scause` 分类。

**Case 3**（中断重复进入/异常死循环）：检查 Trap frame、`sepc` 更新、`sstatus` 与 `sret`，并用可控测试定位，不靠不断添加打印替代分析。

## 异常与 Trap 返回验证

**Pre-Condition**：已选用可控的测试触发方式，并确认是否启用 RVC 压缩指令。

**Post-Condition**：按指导书输出异常信息；当要求恢复执行时，程序能继续，且不会重复触发同一异常。模块一测试除打印处理函数内信息外，还应在 **Trap 返回后的正常执行流** 打印确认信息。

**Requirements**：

- 每张截图对应一项实际通过的测试；未执行的 `make grade`、关机或异常测试必须标注“待验证”。
- 正式合并后再次测试，不能直接复用临时桩阶段的通过结论代替最终验收。
- 提交前检查 `#lab3 ... YOUR CODE` 等标记，按课程要求保留标记并补全学号；检查 `git diff --check`。
- 提交 Markdown 报告，写清整体实现顺序、每个模块的核心实现、AI 提示词迭代与 Bug 修复、测试截图、相关 OS 原理；小组成员分别补充本人负责的部分。

---

## 使用说明

1. **模块一成员**：使用任务 1；现有实现与测试记录可作为讨论和报告依据。
2. **模块二成员**：先使用任务 2-A，再使用任务 2-B；两份提示词的代码修改目标均为同一个 `trap.c`，避免互相覆盖。
3. **全组联调**：最后运行任务 3，替换并清除临时测试桩，重新构建，保留最终实际测试截图。
4. **保持来源准确**：这是参照 Lab2 风格整理的**可复用最终任务提示词**，不代表四份提示词都曾在历史开发中逐字发出，也不代表未完成的模块二和联合测试已经通过。
