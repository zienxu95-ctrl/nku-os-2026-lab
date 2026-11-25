# Lab5 提示词

本文件面向 RISC-V 64 位、Sv39 的 uCore Lab5。程浩轩负责用户态系统调用和第一个用户进程，徐子恩负责进程复制与退出、让出、终止，胡家华负责 Copy on Write 扩展和系统调用的双重 GDB 观察。每项任务都按实验手册的四段式书写，可单独交给 AI 编程工具。提示词依据当前源码和指导书整理，不表示这些文字都曾在历史对话中逐字发送。代码片段只列出真实接口，不给出完整函数体。

| 编号 | 练习位置 | 提示词作用 | 主要文件 |
|---|---|---|---|
| 任务 1 | 功能模块一 · 2411102-程浩轩 | 用户态 `ecall` 进入内核并返回 | `code/kern/trap/trap.c`、`code/kern/syscall/syscall.c`、`code/kern/trap/trapentry.S` |
| 任务 2 | 功能模块二 · 2411102-程浩轩 | 创建并装载第一个用户进程 | `code/kern/process/proc.c` |
| 任务 3 | 功能模块三 · 2411112-徐子恩 | 复制用户进程 | `code/kern/process/proc.c`、`code/kern/mm/vmm.c`、`code/kern/mm/pmm.c` |
| 任务 4 | 功能模块四 · 2411112-徐子恩 | 退出、让出和终止 | `code/kern/process/proc.c` |
| 任务 5 | Challenge · 2410935-胡家华 | Copy on Write | `code/kern/mm/pmm.c`、`code/kern/mm/vmm.c`、`code/kern/trap/trap.c` |
| 任务 6 | GDB · 2410935-胡家华 | 观察 `ecall` 与 `sret` | `code/user/libs/syscall.c`、QEMU RISC-V 翻译器 |

源码现状：`libs/unistd.h` 中 `SYS_exit=1`、`SYS_fork=2`、`SYS_wait=3`、`SYS_exec=4`、`SYS_yield=10`、`SYS_kill=12`、`SYS_getpid=18`、`SYS_putc=30`、`SYS_pgdir=31`。用户库把系统调用号放在 `a0`，五个参数放在 `a1` 到 `a5`。`mm->pgdir` 是内核虚拟地址，`proc->pgdir` 是对应物理地址。用户程序由 `tools/user.ld` 链接到 `0x800020`，再以二进制方式链入内核。

---

# 任务 1：用户态系统调用

### [PROMPT]

**任务**：在 `code/kern/trap/trap.c` 和 `code/kern/syscall/syscall.c` 中完成用户态系统调用入口。`exception_handler` 识别 U 态和 S 态 `ecall`，`syscall` 按编号分发，各 `sys_*` 调用已经存在的 `do_*`。同时核对 `RESTORE_ALL` 能返回用户态。

**操作要求**：必须修改工程中的实际文件。保留时钟中断、断点处理和进程退出检查。不要重写 `do_fork`、`do_exit`、`do_wait`、`do_kill`、`do_yield`。

**输出要求**：直接改文件。接口、编号和寄存器约定以当前源码为准，不要引入新的系统调用号。

### [RELY]

```c
#define SYS_exit 1
#define SYS_fork 2
#define SYS_wait 3
#define SYS_exec 4
#define SYS_yield 10
#define SYS_kill 12
#define SYS_getpid 18
#define SYS_putc 30
#define SYS_pgdir 31
struct trapframe { struct pushregs gpr; uintptr_t status, epc, tval, cause; };
int do_exit(int error_code);
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
int do_wait(int pid, int *code_store);
int do_execve(const char *name, size_t len, unsigned char *binary, size_t size);
int do_yield(void);
int do_kill(int pid);
```

用户侧 `user/libs/syscall.c` 在内联汇编中执行 `ecall`。RISC-V 中 U 态 `ecall` 的 `scause` 是 8，S 态 `ecall` 是 9。`ecall` 长度为 4 字节。

### [GUARANTEE]

```c
void exception_handler(struct trapframe *tf);
void syscall(void);
static int sys_exit(uint64_t args[]);
static int sys_fork(uint64_t args[]);
static int sys_wait(uint64_t args[]);
static int sys_exec(uint64_t args[]);
static int sys_yield(uint64_t args[]);
static int sys_kill(uint64_t args[]);
static int sys_getpid(uint64_t args[]);
static int sys_putc(uint64_t args[]);
static int sys_pgdir(uint64_t args[]);
```

可以保留文件内的 `static` 分发表，不要把 `sys_*` 改成对用户程序可见的符号。

### [SPECIFICATION]

#### exception_handler

**Pre-Condition**：`tf` 指向本次陷入保存的 trapframe，`cause` 已由硬件写入。

**Post-Condition**：合法 `ecall` 的服务已经执行，返回地址指向 `ecall` 的下一条指令。

**Case 1**：`cause` 为 8 或 9。`epc` 增加 4，然后调用 `syscall()`。

**Case 2**：`cause` 为 3。按指令低两位判断长度，把 `epc` 移过断点指令。

**Case 3**：其他原因。打印现场。若发生在用户态，当前进程以错误码退出；若发生在内核态，内核停止。

**Requirements**：不得在推进 `epc` 之前调用 `syscall()`，否则返回后会再次执行同一条 `ecall`。

#### syscall

**Pre-Condition**：`current->tf` 是用户现场。`a0` 是系统调用号，`a1` 到 `a5` 是参数。

**Post-Condition**：合法调用的返回值写入 `tf->gpr.a0`。非法编号得到 `-E_INVAL`，不会按空函数指针调用。

**Case 1**：编号小于分发表长度且对应项非空。用五个参数调用该函数。

**Case 2**：编号越界或表项为空。返回 `-E_INVAL`。

**Requirements**：`sys_fork` 把当前用户栈指针和 trapframe 交给 `do_fork`，不使用 `CLONE_VM`。`sys_putc` 输出一个字符。`sys_getpid` 返回 `current->pid`。

---

# 任务 2：创建并加载第一个用户进程

### [PROMPT]

**任务**：在 `code/kern/process/proc.c` 中把启动流程从内核线程推进到第一个用户程序。`init_main` 创建 `user_main` 并等待它，`user_main` 通过 `kernel_execve` 装入已经链入内核的用户 ELF，`load_icode` 建立用户页表、程序段和用户栈，再经 trap 返回进入用户态。

**操作要求**：必须修改实际文件。保留 PCB、内核栈和调度框架。用户程序二进制使用 `KERNEL_EXECVE` 宏引用，不要假设存在磁盘文件系统。

**输出要求**：直接改文件。地址、权限和 trapframe 字段以当前 `proc.c`、`memlayout.h` 和 `trap.h` 为准。

### [RELY]

```c
#define KERNEL_EXECVE(x) /* 引用 _binary_obj___user_##x##_out_start/size */
int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags, struct vma_struct **vma_store);
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm);
int do_wait(int pid, int *code_store);
```

`tools/user.ld` 把用户程序放在 `0x800020`。`USTACKTOP` 和 `USTACKSIZE` 决定用户栈范围。ELF 的 `ELF_PT_LOAD` 段带有读、写、执行标志。

### [GUARANTEE]

```c
static int init_main(void *arg);
static int user_main(void *arg);
static int kernel_execve(const char *name, unsigned char *binary, size_t size);
int do_execve(const char *name, size_t len, unsigned char *binary, size_t size);
static int load_icode(unsigned char *binary, size_t size);
```

### [SPECIFICATION]

#### init_main 与 user_main

**Pre-Condition**：`proc_init` 已创建 idleproc，并让 initproc 执行 `init_main`。

**Post-Condition**：一个用户进程被创建、运行，退出后由 initproc 等待。initproc 随后保持可调度，不退出。

**Case 1**：`kernel_thread(user_main)` 成功。`do_wait` 取得该进程的退出码并打印。

**Case 2**：创建失败。内核 panic，不继续假装用户程序已运行。

#### load_icode

**Pre-Condition**：`binary` 指向内核镜像中的 ELF，`size` 是该镜像长度。当前执行流仍在内核态。

**Post-Condition**：当前进程拥有新的用户 `mm` 和页表。可加载段与用户栈已映射。trapframe 的 `epc` 是 ELF 入口，`sp` 在用户栈上，`sstatus` 使 `sret` 进入 U 态并允许中断。

**Case 1**：ELF 头、程序头和地址范围合法。按段权限建立 VMA，分配页面并拷贝文件内容，BSS 对应的多出部分保持为零。

**Case 2**：格式或内存不足。释放本次已经建立的 `mm`，返回负错误码，不切换到半成品页表。

**Requirements**：只调用 `do_execve` 还不能进入用户态。`kernel_execve` 必须把执行流送入 `forkrets` 所使用的 trap 返回路径。

---

# 任务 3：复制用户进程

### [PROMPT]

**任务**：在 `do_fork`、`copy_mm`、`dup_mmap`、`copy_range` 中完成用户进程复制。父进程得到子进程 PID，子进程从系统调用得到 0。普通 fork 得到独立的 `mm` 和页表；`CLONE_VM` 只增加原 `mm` 的引用计数。

**操作要求**：必须修改实际文件。内核线程没有用户 `mm` 时，子线程继续使用启动页表。失败路径按申请的逆序释放 PCB、内核栈和新 `mm`。

**输出要求**：直接改文件。不要在这个任务里实现写时复制；页面内容的复制方式留在 Challenge 中替换。

### [RELY]

```c
#define CLONE_VM 0x00000100
int dup_mmap(struct mm_struct *to, struct mm_struct *from);
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share);
struct mm_struct *mm_create(void);
int setup_pgdir(struct mm_struct *mm);
void copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf);
```

`copy_thread` 已把子进程的 `a0` 设为 0，并把 `context.ra` 设为 `forkret`。父进程的返回值由系统调用分发写回父 trapframe 的 `a0`。

### [GUARANTEE]

```c
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
static int copy_mm(uint32_t clone_flags, struct proc_struct *proc);
int dup_mmap(struct mm_struct *to, struct mm_struct *from);
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share);
```

### [SPECIFICATION]

#### do_fork

**Pre-Condition**：`current` 有效，`tf` 是父进程要继承的现场。

**Post-Condition**：成功时子进程已加入 PID 哈希和进程链表，状态可运行，父进程得到正的 PID。

**Case 1**：进程数量已达上限，或 PCB、内核栈、地址空间分配失败。返回负错误码，不留下已登记的子进程。

**Case 2**：资源全部就绪。设置父子关系，复制 trapframe，登记 PID，再 `wakeup_proc`。

#### copy_mm

**Pre-Condition**：子 PCB 已分配，尚未对外公布。

**Post-Condition**：子进程的 `mm` 和 `pgdir` 与所选共享策略一致。

**Case 1**：父进程没有用户 `mm`。子进程 `mm` 为空，`pgdir` 为 `boot_pgdir_pa`。

**Case 2**：标志包含 `CLONE_VM`。父子共用同一个 `mm`，引用计数增加，不复制 VMA。

**Case 3**：普通用户 fork。新建 `mm` 和页目录，`dup_mmap` 成功后把页目录物理地址写入 `proc->pgdir`。

#### dup_mmap 与 copy_range

**Pre-Condition**：两边页目录都已建立。

**Post-Condition**：子地址空间具有与父进程相同范围和权限的 VMA。父进程中已经映射的用户页在子页表中有对应映射。

**Case 1**：某一段映射失败。停止后续复制并返回错误，调用者销毁新 `mm`。

**Requirements**：复制 VMA 时保持按起始地址排序，拒绝重叠区间。

---

# 任务 4：退出、让出和终止

### [PROMPT]

**任务**：在 `code/kern/process/proc.c` 中完成 `do_exit`、`do_yield`、`do_kill`，并与已有的 `do_wait` 配合。退出进程先释放自己不再使用的地址空间，再变成僵尸；父进程 wait 之后才释放 PCB 和内核栈。

**操作要求**：必须修改实际文件。idleproc 和 initproc 不能退出，也不能被 kill。父子链表、PID 哈希和等待状态的修改放在本地关中断的临界区里。

**输出要求**：直接改文件。不要把 `do_yield` 写成在系统调用内部直接切换栈。

### [RELY]

```c
#define PF_EXITING  /* 进程标志：请求退出 */
#define PROC_ZOMBIE
#define PROC_SLEEPING
#define WT_CHILD
void exit_mmap(struct mm_struct *mm);
void wakeup_proc(struct proc_struct *proc);
void schedule(void);
struct proc_struct *find_proc(int pid);
```

`trap` 在返回用户态之前检查 `PF_EXITING` 和 `need_resched`。

### [GUARANTEE]

```c
int do_exit(int error_code);
int do_yield(void);
int do_kill(int pid);
```

### [SPECIFICATION]

#### do_exit

**Pre-Condition**：当前进程准备结束，`error_code` 是退出码。

**Post-Condition**：当前进程变为僵尸，地址空间引用已经放下。若它是该 `mm` 的最后一个使用者，映射、页目录和 `mm` 被释放，并切回启动页表。父进程若在等待则被唤醒。函数通过调度离开，不返回到已退出的用户代码。

**Case 1**：当前进程是 idleproc 或 initproc。拒绝退出。

**Case 2**：当前进程仍有子进程。把这些子进程改挂到 initproc 名下，并维持 `parent`、`cptr`、`optr`、`yptr` 一致。已经是僵尸的子进程要能唤醒正在等待的 initproc。

#### do_yield

**Pre-Condition**：`current` 指向正在运行的进程。

**Post-Condition**：`current->need_resched` 为真，函数返回 0。真正的进程切换由 trap 返回路径或 idle 循环完成。

#### do_kill

**Pre-Condition**：`pid` 是目标进程号。

**Post-Condition**：合法目标带有 `PF_EXITING`。目标若在睡眠，被改为可运行。调用者不释放目标的 PCB。

**Case 1**：目标不存在、是 idleproc、initproc 或已经是僵尸。返回 `-E_INVAL`。

**Case 2**：目标合法。设置退出标志；睡眠中的目标被 `wakeup_proc`。

---

# 任务 5：Copy on Write

### [PROMPT]

**任务**：由 2410935-胡家华负责，把普通用户 fork 的整页复制改成写时复制。涉及 `code/kern/mm/mmu.h`、`code/libs/riscv.h`、`code/kern/mm/pmm.c` 的 `copy_range`、`code/kern/mm/vmm.c` 的 `do_pgfault`，以及 `code/kern/trap/trap.c` 的页错误分发。补一个用户程序，证明子进程写入后父进程仍看到原来的数据。

**操作要求**：必须修改实际文件。保留 `CLONE_VM` 的共享写权限路径。不要改模块一到模块四已经成立的 PID、trapframe 和等待逻辑。软件标志只能使用 RISC-V PTE 的 RSW 位。

**输出要求**：直接改文件。缺页处理必须先复制到新物理页，再替换页表项；不能先把共享页改成可写。

### [RELY]

```c
#define PTE_V 0x001
#define PTE_R 0x002
#define PTE_W 0x004
#define PTE_X 0x008
#define PTE_U 0x010
#define PTE_SOFT 0x300
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm);
void page_remove(pde_t *pgdir, uintptr_t la);
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create);
struct Page *pte2page(pte_t pte);
int page_ref(struct Page *page);
struct vma_struct *find_vma(struct mm_struct *mm, uintptr_t addr);
#define VM_READ 0x1
#define VM_WRITE 0x2
#define VM_EXEC 0x4
```

RISC-V 异常号：12 是取指页错误，13 是加载页错误，15 是存储页错误。`tf->tval` 保存故障地址。`load_icode` 给用户页同时设置 `PTE_U | PTE_R | PTE_W | PTE_X`，因此数据页和当前加载器下的代码页在 fork 前都是可写的。`dup_mmap` 对普通 fork 调用 `copy_range(..., 0)`。

### [GUARANTEE]

```c
#define PTE_COW 0x100
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share);
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr);
```

可以在 `exception_handler` 中增加页错误分支。可以新增 `code/user/cowtest.c`。不要新增公开的进程管理系统调用。

### [SPECIFICATION]

#### copy_range

**Pre-Condition**：`start`、`end` 按页对齐，且位于用户地址范围。`from` 是父页表，`to` 是子页表。

**Post-Condition**：父进程中每个有效的用户页，在子页表的同一虚拟地址上有映射。可写页不再被两边同时以可写方式映射。

**Case 1**：`share` 为真。子页表映射同一物理页，权限保持不变，引用计数增加。

**Case 2**：`share` 为假，源页表项可写或已经带有 `PTE_COW`。父子两边都去掉 `PTE_W` 并置 `PTE_COW`，继续共享该物理页。父页表项修改后刷新对应 TLB。

**Case 3**：`share` 为假，源页只读且没有 `PTE_COW`。子页表按原权限共享该页，不把它变成写时复制页。

**Case 4**：建立映射失败。返回负错误码。已经改成 `PTE_COW` 的父页仍可由最后一次写入者在引用计数为 1 时恢复可写。

**Requirements**：此函数不再为普通 fork 分配新页并 `memcpy`。引用计数只通过 `page_insert` 增加一次。

#### do_pgfault

**Pre-Condition**：`mm` 是发生页错误的地址空间，`addr` 是故障虚拟地址，`error_code` 是 `scause`。调用期间该 `mm` 的锁被持有，检查、复制和替换不能拆成可被另一次缺页插进中间的三步。

**Post-Condition**：一次合法的写时复制完成后，故障进程对这一页拥有可写私有映射，其他仍共享旧页的进程继续看到旧内容。

**Case 1**：地址不在任何 VMA 中，或者写入一个没有 `VM_WRITE` 的区间。返回 `-E_INVAL`。

**Case 2**：存储页错误，页表项有效且带 `PTE_COW`，物理页引用计数大于 1。先把旧页内容复制到新物理页，再把新页以可写、不带 `PTE_COW` 的权限装入当前页表。旧页引用计数下降，但不被改写。

**Case 3**：同上，但引用计数已经是 1。直接去掉 `PTE_COW`、置上 `PTE_W` 并刷新 TLB，不分配新页。

**Case 4**：页表项不存在，或错误不是对 `PTE_COW` 页的存储。返回错误，由陷阱处理把用户进程送去退出。

**Requirements**：禁止先给共享页表项加上 `PTE_W` 再复制。那会让其他映射在复制完成前观察到写，和 Dirty COW 的错误顺序相同。本实验没有 `/proc/self/mem`，不能原样复现 CVE-2016-5195，但实现必须排除同类窗口。

---

# 任务 6：用双重 GDB 观察系统调用

### [PROMPT]

**任务**：使用内核 GDB 和附加到 QEMU 进程的宿主 GDB，观察用户程序执行 `ecall` 进入 S 态、内核处理后再由 `sret` 返回 U 态。记录 QEMU 如何翻译这两条指令，以及 TCG 和 Lab2 页表调试的关系。

**操作要求**：不要为了调试去改系统调用语义。先确认 `make debug` 只加载 `bin/kernel` 的符号；用户程序符号要单独加载。

**输出要求**：把操作、QEMU 的处理流程和遇到的现象写入实验报告，不把调试日志写进内核源码。

### [RELY]

```text
make debug    # QEMU -s -S，等待 GDB
make gdb      # riscv64-unknown-elf-gdb，file bin/kernel，target remote localhost:1234
tools/user.ld # 用户程序固定链接在 0x800020
user/libs/syscall.c 中的 ecall
kern/trap/trapentry.S 中的 __alltraps、__trapret、sret
```

当前默认用户程序是 `forktest`。观察某一个用户程序时，符号文件是 `obj/__user_<程序名>.out`。

### [GUARANTEE]

本任务不要求新的内核接口。报告需要说明：

- 用户符号为什么不能由 `make gdb` 自动出现。
- `ecall` 在 QEMU 中怎样变成陷入，`sret` 怎样恢复特权级、`SIE` 和 PC。
- TCG 翻译在这条路径和 Lab2 地址翻译调试中分别起什么作用。

### [SPECIFICATION]

#### 内核 GDB

**Pre-Condition**：一个终端已执行 `make debug`，另一个终端在 `code/` 下执行 `make gdb`。

**Post-Condition**：能在用户态 `ecall` 之前停下，并能在内核 `sret` 之前停下。

**Case 1**：直接 `break user/libs/syscall.c`。GDB 报告没有这个源文件，因为内核符号里没有用户程序。

**Case 2**：执行 `add-symbol-file obj/__user_forktest.out` 后再对用户库打断点。GDB 按 ELF 里的 `0x800020` 链接地址放置符号。

**Case 3**：`break syscall` 在加载用户符号之前会落到内核的 `syscall()`。用户库和内核都有这个名字，加载用户符号后必须区分。

**Requirements**：`ecall` 在内联汇编中。C 语言行断点通常停在汇编块之前，要用 `si` 和 `x/i $pc` 确认当前指令就是 `ecall`。

#### QEMU 侧

**Pre-Condition**：内核 GDB 已经停在客户机的 `ecall` 或 `sret` 前。附加到 QEMU 进程的宿主 GDB 处于 Continuing，需要 `Ctrl-C` 才能输入命令。

**Post-Condition**：能说明 QEMU 不是把 `ecall` 当作函数调用，而是在翻译指令时生成异常；`sret` 由 helper 恢复 `sepc`、`SPP` 和 `SIE`。

**Requirements**：发行版里的 `qemu-system-riscv64` 常常没有 `trans_ecall` 的本地符号。不能因为宿主 GDB 断不到这个函数，就认为 QEMU 没有翻译该指令。源码级说明以 QEMU 的 RISC-V 翻译器和异常 helper 为准。
