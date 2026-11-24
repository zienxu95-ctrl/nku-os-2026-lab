# 操作系统实验报告：Lab5 用户进程管理

## 实验基本信息

| 项目 | 内容 |
|---|---|
| 实验名称 | Lab5 用户进程管理 |
| 小组成员 | 2411102 程浩轩、2411112 徐子恩、2410935 胡家华 |
| 提交分支 | `lab5` |
| 源码目录 | `code/` |

### 小组分工

| 成员 | 负责内容 |
|---|---|
| 2411102 程浩轩 | 功能模块一：用户态系统调用；功能模块二：创建并加载第一个用户进程 |
| 2411112 徐子恩 | 功能模块三：复制用户进程；功能模块四：进程退出、让出与终止 |
| 2410935 胡家华 | Challenge：Copy on Write（COW）机制，待负责人补充 |

## 一、实验目的

Lab5 在已有内存管理、异常处理和虚拟内存机制上，建立用户进程管理的基本闭环。实验通过系统调用连接用户态与内核服务，由内核创建首个用户进程并装载 ELF，再通过 fork、调度、exit、kill 和 wait 管理进程的创建、执行与回收。

本实验关注的不只是各个接口能否被调用，还包括寄存器现场、页表、PCB、进程状态和父子关系如何在不同阶段保持一致。

## 二、实验环境

| 项目 | 环境或说明 |
|---|---|
| 主机环境 | Windows 11、WSL2 Ubuntu-22.04 |
| 目标架构 | RISC-V 64 位，Sv39 |
| 交叉编译工具链 | `riscv64-unknown-elf` 工具链 |
| 编译与运行 | Make、QEMU `virt`、OpenSBI v0.9 |
| 编辑与代码分析 | VS Code、Codex |

以上环境信息根据项目记录整理；本报告只记载已有运行记录，不补写未确认的工具版本或配置参数。

## 三、实验整体逻辑分析

### 3.1 本章节的逻辑主线

Lab5 依赖前序实验提供的基础能力。Lab2 的物理页分配与页引用计数为进程内核栈、页表和用户页面提供资源；Lab3 的 Trap 入口、寄存器保存恢复及调度上下文切换，使内核能够从用户态处理异常并切换进程；Lab4 的 VMA、页表映射及地址空间管理，为 ELF 装载和 fork 地址空间复制提供基础。Lab5 在这些机制之上增加系统调用接口和进程生命周期管理。

整体执行从内核初始化开始。`proc_init` 建立 idleproc 并创建 initproc；initproc 再创建执行用户程序的内核线程。该线程将 ELF 映像交给 `load_icode`，建立用户地址空间、映射程序段和用户栈，并准备 trapframe。随后通过 Trap 返回进入用户态。用户程序发出 `ecall` 后，内核保存现场、识别系统调用号、调用服务函数，并把返回值放回约定寄存器。

用户程序调用 fork 时，内核为子进程建立 PCB、内核栈和 trapframe，并根据标志共享或复制地址空间。父子进程从各自保存的现场继续执行：父进程得到子 PID，子进程得到 0。调度器在 runnable 进程之间切换；yield 请求重新调度，kill 标记目标进程退出。进程退出后释放其地址空间引用并进入僵尸态，父进程通过 wait 取得退出码并最终释放子进程 PCB 和内核栈。父进程退出时，其子进程转交给 initproc，避免遗留悬空父指针。

### 3.2 功能逐步实现与调用顺序

1. **内核启动与进程初始化：**`kern_init → proc_init → kernel_thread(init_main)`。
2. **创建首个用户执行线程：**`init_main → kernel_thread(user_main)`。
3. **装载 ELF 并进入用户态：**`user_main → kernel_execve → do_execve → load_icode → forkrets → sret`。
4. **用户态请求内核服务：**`ecall → SAVE_ALL → exception_handler → syscall → sys_* → RESTORE_ALL → sret`。
5. **复制进程：**`sys_fork → do_fork → copy_mm → dup_mmap → copy_range`，新进程加入进程集合并变为可运行。
6. **调度与生命周期管理：**`do_yield` 设置重新调度标记；`do_kill` 设置退出标记；`do_exit` 释放地址空间并进入僵尸态；`do_wait` 回收子进程。

以上链路把 Lab2 的页面资源管理、Lab3 的 Trap 与调度、Lab4 的虚拟内存管理和 Lab5 的用户进程管理连接起来。具体测试证据与覆盖范围见第五节。

## 四、实验内容与实现

### 4.1 功能模块一：用户态系统调用

**负责人：2411102 程浩轩**

#### 4.1.1 模块功能与设计思路

用户程序不能直接执行内核服务，因此通过 `ecall` 进入内核。Trap 入口先把寄存器和异常状态保存到 trapframe，C 层根据异常原因识别系统调用。分发器使用系统调用号索引服务函数表，从保存现场中读取参数，调用对应内核函数，再把返回值写回 `a0`。Trap 返回路径恢复用户现场并执行 `sret`。

#### 4.1.2 核心函数及职责

| 函数 | 职责 |
|---|---|
| `exception_handler` | 识别 U 态和 S 态 `ecall`，将 `epc` 前移 4 字节后进入系统调用分发。 |
| `syscall` | 从 trapframe 读取系统调用号及 `a1–a5` 参数，检查编号并调用分发表中的函数，把结果写回 `a0`。 |
| `sys_exit`、`sys_fork`、`sys_wait`、`sys_exec` | 分别连接进程退出、复制、等待和执行服务。 |
| `sys_yield`、`sys_kill`、`sys_getpid` | 连接调度请求、进程终止和 PID 查询。 |
| `sys_putc`、`sys_pgdir` | 提供字符输出和页表信息输出服务。 |
| `RESTORE_ALL` | 恢复 trapframe，并依据 `SPP` 设置 `sscratch`，支持回到用户态或内核态。 |

系统调用号定义于 `libs/unistd.h`，用户侧调用约定可见 `user/libs/syscall.c`：`a0` 传系统调用号，`a1–a5` 传参数，返回值从 `a0` 读取。异常处理将 `epc` 加 4 是因为 RISC-V `ecall` 指令为 4 字节；若不前移，返回后会再次执行同一条 `ecall`。

#### 4.1.3 核心实现代码

```c
case 8: /* ECALL from U mode */
    tf->epc += 4;
    syscall();
    break;
```

异常处理从 `cause` 判断 U 态环境调用，推进返回地址后才进入分发。`syscall()` 使用 `current->tf` 作为寄存器现场来源，因此 Trap 保存和当前进程 trapframe 的关联是调用链成立的前提。

```c
uint64_t num = tf->gpr.a0;
uint64_t args[5] = { tf->gpr.a1, tf->gpr.a2, tf->gpr.a3,
                     tf->gpr.a4, tf->gpr.a5 };
int ret = -E_INVAL;
if (num < NUM_SYSCALLS && syscalls[num] != NULL)
    ret = syscalls[num](args);
tf->gpr.a0 = (uintptr_t)ret;
```

分发表将系统调用号映射到 `sys_*` 服务函数；范围和空项检查避免非法编号直接索引或调用无效函数。用户库中的汇编将参数装入寄存器并执行 `ecall`，内核写回的 `a0` 即成为用户侧结果。

`RESTORE_ALL` 从 trapframe 恢复 `sstatus` 和 `sepc`。当 `SPP` 表示返回 U 态时，将内核栈地址写入 `sscratch`，供下一次用户陷入交换栈使用；返回 S 态时清零 `sscratch`。最终由 `sret` 根据恢复的状态与入口地址继续执行。

#### 4.1.4 与其他模块的关系及注意事项

模块一连接用户 API 与内核服务：`sys_fork`、`sys_wait`、`sys_kill` 等服务最终依赖模块三、四的进程管理代码。系统调用传入的用户指针必须经过地址范围和权限校验。当前 `SYS_exec` 虽然注册到分发表，但 `do_execve` 仅支持内核初次启动用户程序；普通用户进程调用会返回 `-E_UNIMP`，不应视为完整支持。

### 4.2 功能模块二：创建并加载第一个用户进程

**负责人：2411102 程浩轩**

#### 4.2.1 模块功能与设计思路

启动时 idleproc 作为空闲进程，`proc_init` 创建 initproc。initproc 运行 `init_main`，再创建执行用户程序的线程；该线程调用 `kernel_execve` 加载内核链接进来的用户 ELF。加载成功后，线程的页表和 trapframe 指向用户程序的地址空间与入口，Trap 返回使处理器进入用户态。用户程序结束后，initproc 通过 `do_wait` 读取退出状态并回收线程。

#### 4.2.2 核心函数及职责

| 函数 | 职责 |
|---|---|
| `alloc_proc` | 分配并初始化 PCB、状态、PID 占位值、页表根字段和链表节点。 |
| `kernel_thread` | 构造内核线程初始 trapframe，并通过 `do_fork` 建立线程。 |
| `init_main` | 创建用户程序执行线程，并等待它退出。 |
| `user_main` | 选择嵌入内核的用户 ELF；当前源码使用 `forktest`。 |
| `kernel_execve` | 调用 `do_execve`，成功后切换 SATP 并以 trapframe 返回。 |
| `do_execve` | 校验初次执行所需参数并调用 ELF 装载函数。 |
| `load_icode` | 检查 ELF、创建地址空间、映射段和用户栈、设置用户入口与状态。 |
| `do_wait` | 等待子进程退出，传递退出码并回收僵尸进程。 |

#### 4.2.3 核心实现代码

```c
static int user_main(void *arg) {
    (void)arg;
    int ret = KERNEL_EXECVE(forktest);
    panic("kernel_execve failed: %d", ret);
}
```

`user_main` 是内核线程执行入口之一。执行成功时 `kernel_execve` 不按普通函数返回，而是恢复新构造的 trapframe 进入用户态；因此后面的 panic 仅用于处理装载失败返回的情况。当前实际源码启动的是 `forktest`，与旧报告记载的 `hello` 不同。

```c
current->mm = mm;
mm_count_inc(mm);
current->pgdir = PADDR(mm->pgdir);
memset(current->tf, 0, sizeof(struct trapframe));
current->tf->gpr.sp = USTACKTOP;
current->tf->epc = elf->e_entry;
current->tf->status = (read_csr(sstatus) | SSTATUS_SPIE) &
                      ~(SSTATUS_SPP | SSTATUS_SIE);
```

装载完成后，当前进程关联新 mm 和页表物理地址。trapframe 的 `sp` 指向用户栈顶，`epc` 指向 ELF 入口；清除 `SPP` 使异常返回目标为 U 态，并通过 `SPIE` 设置返回后的中断状态。`kernel_execve` 随后切换 SATP 并调用 `forkrets`，由汇编返回路径恢复现场。

`load_icode` 对 ELF 程序头进行边界检查，为 `PT_LOAD` 段建立 VMA、分配页面、清零页面并复制文件内容；随后建立用户栈 VMA，当前源码为栈顶分配四个物理页。加载失败时统一解除映射并释放页目录和 mm。段的 VMA 标志来源于 ELF，但当前页面分配权限使用统一的 `PTE_U | PTE_R | PTE_W | PTE_X`，因此页级权限没有严格保持 ELF 段权限。

#### 4.2.4 与其他模块的关系及注意事项

该模块依赖 Lab2 的物理页分配、Lab3 的 Trap 返回及上下文切换、Lab4 的 VMA 和页表管理。`kernel_thread` 建立执行载体，`load_icode` 将载体准备为用户进程；`init_main` 是父进程，等待用户线程退出。普通用户态 `exec` 的地址空间替换目前未实现，这与内核首次加载 ELF 是不同路径。

### 4.3 功能模块三：复制用户进程

**负责人：2411112 徐子恩**

#### 4.3.1 模块功能与设计思路

fork 需要复制进程的执行现场及用户地址空间，同时区分“共享 mm”与“独立复制 mm”。实现按层分工：`do_fork` 管理 PCB、内核栈、PID 和进程关系；`copy_mm` 决定共享或复制；`dup_mmap` 复制 VMA 并逐段调用 `copy_range`；`copy_range` 操作页表和物理页面。这样地址空间策略与底层页面复制相互分离，失败时由上层统一回滚。

#### 4.3.2 核心函数及职责

| 函数 | 所属层 | 职责 |
|---|---|---|
| `do_fork` | 进程管理 | 建立子 PCB、内核栈、父子关系、PID、进程/哈希链表和可运行状态。 |
| `copy_mm` | 地址空间策略 | 无 mm 时保持内核页表；`CLONE_VM` 时共享 mm 并增加引用计数；否则创建新 mm 并复制映射。 |
| `dup_mmap` | VMA 管理 | 按父 mm 中的 VMA 范围与标志在子 mm 中创建 VMA，再复制该范围内的用户页。 |
| `copy_range` | 页表/物理页 | 对普通 fork 分配新物理页、复制内容并按原权限映射；共享模式复用页面并增加引用计数。 |

#### 4.3.3 核心实现代码

```c
static int copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    struct mm_struct *oldmm = current->mm;
    if (oldmm == NULL) {
        proc->mm = NULL;
        proc->pgdir = boot_pgdir_pa;
        return 0;
    }
    if (clone_flags & CLONE_VM) {
        mm_count_inc(oldmm);
        proc->mm = oldmm;
        proc->pgdir = current->pgdir;
        return 0;
    }
    ...
}
```

内核线程可以没有独立用户 mm，此时子线程继续使用启动页表。`CLONE_VM` 表示共享地址空间，只递增 mm 引用计数，不复制 VMA 和页面；普通用户 fork 则创建新的 mm 和页目录，成功完成 `dup_mmap` 后才把它交给子进程并增加该 mm 的拥有者计数。

```c
if ((ret = setup_kstack(proc)) != 0) { kfree(proc); return ret; }
if ((ret = copy_mm(clone_flags, proc)) != 0) {
    put_kstack(proc);
    kfree(proc);
    return ret;
}
proc->parent = current;
copy_thread(proc, stack, tf);
proc->pid = get_pid();
```

资源按建立顺序申请，失败时释放已成功申请的资源。`copy_thread` 将父 trapframe 复制到子内核栈上的 trapframe，并把子 `a0` 设为 0；父侧系统调用处理器把 `do_fork` 返回的 PID 写入父 trapframe 的 `a0`，因此形成父进程得到 PID、子进程得到 0 的语义。

```c
mm_map(to, vma->vm_start, vma->vm_end - vma->vm_start,
       vma->vm_flags, NULL);
copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, 0);
```

`dup_mmap` 对父 mm 的每个 VMA 创建同范围、同标志的子 VMA，并复制其中已经存在的用户页。未映射页面跳过，不会凭空为父子进程分配页面。

```c
struct Page *dst_page = alloc_page();
if (dst_page == NULL) return -E_NO_MEM;
memcpy(page2kva(dst_page), page2kva(src_page), PGSIZE);
page_insert(to, dst_page, la, perm);
```

普通 fork 为映射页面分配独立物理页，整页复制内容，并从父页表项保留读、写、执行、用户等权限。`page_insert` 建立子页表映射并增加页面引用计数。若后续复制失败，`copy_mm` 将新 mm 的计数设为零，解除已经建立的映射、释放页目录和 VMA，再由 `do_fork` 释放内核栈与 PCB。

子进程完成链表登记后调用 `wakeup_proc` 进入 runnable 状态；调度器之后可选择该进程。其初始上下文返回到 `forkret`，再通过 trapframe 恢复开始执行。

#### 4.3.4 与其他模块的关系及注意事项

模块三使用 Lab2 的页分配与引用计数、Lab4 的 VMA 和页表操作，并依赖 Lab3 的上下文切换和 TrapFrame 格式。`CLONE_VM` 共享 mm 的计数在进程退出时递减，只有最后一个使用者退出才释放地址空间。普通 fork 不采用 COW；COW 扩展由 Challenge 负责人补充，本报告不描述其实现。

### 4.4 功能模块四：进程退出、让出与终止

**负责人：2411112 徐子恩**

#### 4.4.1 模块功能与设计思路

进程生命周期中，退出、等待和回收分为不同阶段。`do_exit` 释放进程不再使用的地址空间并将 PCB 留在进程表中作为僵尸；父进程通过 `do_wait` 读取退出码后再删除 PID 索引、进程关系、内核栈和 PCB。PCB 延后释放，是因为父进程仍需读取退出状态并定位该子进程。

`do_yield` 只提出重新调度请求，由调度路径决定切换时机。`do_kill` 不直接释放目标进程，而是设置 `PF_EXITING`；目标若在等待则先唤醒，在返回用户态的 Trap 路径检查退出标记后进入退出处理。idleproc 和 initproc 受保护，避免系统失去空闲调度实体或孤儿进程的收养者。

#### 4.4.2 核心函数及职责

| 函数 | 职责 |
|---|---|
| `do_exit` | 拒绝 idleproc/initproc 退出；转移子进程；释放最后一个共享 mm；记录退出码、设为僵尸并唤醒父进程。 |
| `do_wait` | 查找当前进程的子进程；没有僵尸时睡眠等待；找到僵尸后传递退出码并回收 PCB 与内核栈。 |
| `do_yield` | 设置 `need_resched`，让返回路径或调度循环重新选择进程。 |
| `do_kill` | 查找目标、拒绝无效/受保护/已僵尸目标、设置 `PF_EXITING`，并在目标睡眠时唤醒。 |
| `wakeup_proc` | 将睡眠进程改为 runnable 并清除等待状态。 |
| `schedule` | 选择 runnable 进程并调用 `proc_run` 切换执行上下文。 |

#### 4.4.3 核心实现代码

```c
while (current->cptr != NULL) {
    struct proc_struct *child = current->cptr;
    current->cptr = child->optr;
    if (current->cptr != NULL) current->cptr->yptr = NULL;
    child->parent = initproc;
    child->optr = initproc->cptr;
    child->yptr = NULL;
    if (initproc->cptr != NULL) initproc->cptr->yptr = child;
    initproc->cptr = child;
    if (child->state == PROC_ZOMBIE && initproc->state == PROC_SLEEPING)
        wakeup_proc(initproc);
}
```

父进程退出前逐个摘下自己的子进程，并将其挂到 initproc 的孩子链表头部，同时更新 `parent`、`optr`、`yptr`。已是僵尸的子进程若遇到正在等待的 initproc，会触发唤醒。这个修改避免父进程 PCB 被 wait 回收后，子进程仍指向已释放 PCB，并使转交来的僵尸仍可被 initproc 等待回收。

```c
if (current->mm != NULL) {
    struct mm_struct *mm = current->mm;
    current->mm = NULL;
    if (mm_count_dec(mm) == 0) {
        exit_mmap(mm);
        put_pgdir(mm);
        mm_destroy(mm);
    }
    current->pgdir = boot_pgdir_pa;
    write_csr(satp, (1UL << 63) | (boot_pgdir_pa >> PGSHIFT));
    asm volatile("sfence.vma" ::: "memory");
}
current->state = PROC_ZOMBIE;
current->exit_code = error_code;
if (current->parent != NULL && current->parent->state == PROC_SLEEPING)
    wakeup_proc(current->parent);
schedule();
```

退出进程先解除自身对 mm 的引用。若引用计数归零，再释放 VMA 映射、页目录和 mm；若仍有 `CLONE_VM` 使用者，地址空间继续保留。随后切回内核页表，记录僵尸状态和退出码，并唤醒等待中的父进程。进程此时保留 PCB 和内核栈，等待 `do_wait` 最终回收。

```c
int do_yield(void) {
    if (current == NULL) return -E_INVAL;
    current->need_resched = 1;
    return 0;
}
```

yield 不在服务函数内手动切换栈，而是设置当前进程的调度标记，由陷阱返回路径或 idle 调度循环调用调度器，避免把策略和底层切换混在系统调用服务中。

```c
local_intr_save(intr_flag);
struct proc_struct *p = find_proc(pid);
if (p == NULL || p == idleproc || p == initproc || p->state == PROC_ZOMBIE) {
    local_intr_restore(intr_flag);
    return -E_INVAL;
}
p->flags |= PF_EXITING;
if (p->state == PROC_SLEEPING) wakeup_proc(p);
local_intr_restore(intr_flag);
```

`do_kill` 在短临界区中查找并标记目标，使进程集合状态检查与标记不会被本地中断切换打断；对睡眠目标调用 `wakeup_proc`，让其有机会被调度并处理退出标志。该机制是标记退出请求，不代表调用 kill 的进程立即释放目标资源。

`do_wait` 在子进程仍运行时将父进程设为 `PROC_SLEEPING`、记录 `WT_CHILD` 并调度；子进程退出时唤醒父进程。发现僵尸后，wait 先写回退出码，再在关中断临界区摘除 PID 哈希和父子关系，最后释放内核栈与 PCB。这样退出状态可被读取，进程链表和哈希表也在回收时同步更新。

#### 4.4.4 与其他模块的关系及注意事项

模块四连接模块一的 `SYS_exit`、`SYS_wait`、`SYS_yield`、`SYS_kill` 和模块三创建的子进程。进程退出会影响共享 mm 引用计数；父进程等待依赖正确的父子链表；kill 标记需由陷阱返回路径和调度流程实际处理。父子关系变更和 PID/链表登记、摘除均在本地关中断区域内完成；这不是多核锁保护，当前实现针对单核调度路径。

## 五、测试与验证

以下测试结果依据已有实验记录整理。记录显示 `make` 成功生成 `bin/kernel` 和 `bin/ucore.img`；编译期间 `testbss.c` 有数组越界 warning，但未阻止链接。没有执行过的自动评分、性能测试及异常边界场景不列为通过。

### 5.1 Hello 用户程序测试

**测试目的：**检查用户程序装载、进入用户态、正常退出及父进程等待链路。

**测试方法：**构建并运行 Hello 用户程序，观察控制台输出和父进程 wait 结果。

**测试截图：**

![Hello 用户程序测试结果](images/01_Hello_Test.png)

**结果分析：**记录输出包含 `Hello world!!`、`hello pass.`，并显示 `wait=0 code=0`。这说明该次运行中的用户程序成功执行、正常退出，父进程 wait 返回成功并取得退出码 0。

### 5.2 Yield 系统调用测试

**测试目的：**检查用户程序发出 yield 请求后能够继续执行，并最终正常退出。

**测试方法：**构建并运行 Yield 用户程序，观察多轮迭代输出、通过标志和退出等待结果。

**测试截图：**

![Yield 用户程序测试结果](images/02_Yield_Test.png)

**结果分析：**记录中出现多次迭代输出、`yield pass.` 和 `wait=0 code=0`。该结果支持本次运行中 yield 调用可返回、程序继续执行并由父进程正常回收；不代表已验证所有调度时序。

### 5.3 Forktest 集成测试

**测试目的：**在集成版本中检查 fork 创建多个子进程，以及父子进程调度、退出和等待回收主流程。

**测试方法：**在模块三、四修改后的代码上运行 `make` 和 `make qemu`，使用 `forktest` 用户程序，观察子进程输出和最终结果。已有记录输出包括 `kernel_execve: pid = 2, name = "forktest".`、多个 `I am child ...`、`forktest pass.` 和 `user process pid=2 exited: wait=0 code=0`。

**测试截图：**

![Forktest 集成测试结果](images/03_Forktest_Integration.png)

**结果分析：**多条 `I am child ...` 是多个子进程执行时的预期输出，不是测试失败。`forktest pass.` 是测试成功标志；末尾 wait 返回 0、退出码为 0，表明本次运行的主创建、执行、退出和回收流程正常。该项属于小组集成测试，不能据此声称所有 fork 错误回滚或边界情况均已覆盖。

### 5.4 Waitkill 进程终止测试

**测试目的：**观察 waitkill 用户程序创建进程、发出 kill 请求以及父进程等待终止进程的主路径。

**测试方法：**运行 `waitkill` 用户程序。已有控制台记录如下：

```text
kernel_execve: pid = 2, name = "waitkill".
Switching to user page table...
wait child 1.
child 1.
child 2.
kill parent ok.
kill child1 ok.
user process pid=2 exited: wait=0 code=-9
```

**测试截图：**

![Waitkill 进程终止测试结果](images/waitkill.png)

**结果分析：**输出表明程序成功启动并执行到等待及 kill 相关逻辑；`kill parent ok.` 和 `kill child1 ok.` 表明程序中的对应 kill 调用返回成功。`wait=0` 表示父进程成功等待并回收目标进程；退出码 `-9` 表示该进程以被终止状态退出，不应简单视为测试失败。该次运行没有覆盖所有孤儿进程场景或 kill 边界条件，不能据此扩大测试结论。

### 5.5 测试结果汇总

| 测试项目 | 记录结果 | 结论范围 |
|---|---|---|
| Hello | `hello pass.`；`wait=0 code=0` | 本次用户程序执行和退出等待链路正常 |
| Yield | 多轮输出；`yield pass.`；退出码 0 | 本次 yield 调用后程序继续执行并退出 |
| Forktest | 多个子进程输出；`forktest pass.`；退出码 0 | 集成版本的 fork 与退出等待主流程正常 |
| Waitkill | 两条 kill 成功提示；`wait=0 code=-9` | 本次 kill/wait 路径执行到预期结果 |

## 六、实验总结与收获

### 6.1 对操作系统的理解

Lab5 展示了用户态和内核态之间的边界如何由 Trap 与系统调用连接。用户程序通过 `ecall` 请求内核服务；TrapFrame 保存其寄存器状态，使内核在处理后能够恢复原执行现场。系统调用分发不只是函数跳转，还依赖寄存器约定、异常返回地址和特权级状态一致。

进程管理也不只是分配一个 PCB。PCB、内核栈、trapframe、页表和 mm 共同描述一个可调度的执行实体。fork 复制现场并为普通进程建立独立地址空间；共享地址空间则通过引用计数延长 mm 生命周期。进程状态决定调度器是否可选中它，而父子关系决定退出状态由谁读取和回收。

退出与回收被拆成两个阶段：进程先释放不再使用的地址空间并成为僵尸，父进程 wait 取得状态后再释放 PCB 和内核栈。父进程退出时需要转移子进程关系，否则子进程会保留悬空父指针，也可能使僵尸无人回收。由此可见，进程状态、页引用计数和关系链表必须协同维护。

### 6.2 AI 协作开发的经验

本次使用 Codex 阅读 Lab5 源码并进行静态检查，再围绕本人负责的模块三、四检查已有实现，尽量保留原有正确逻辑，只补充缺失功能和确定的问题。修改重点是退出时转交子进程、保持父子链表关系一致，以及在进程管理状态更新处使用已有的本地临界区保护。随后根据已有的 make、QEMU 和用户程序运行记录整理测试结果；未实际执行或未覆盖的测试没有写成通过。
