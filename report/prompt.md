# Lab4 提示词

本文件面向 RISC-V 64 位、Sv39 的 uCore Lab4。三位成员分别负责页表映射、进程创建与初始化、进程调度与上下文切换；末尾另有全组联调提示词。每项任务均可独立复制给 AI 编程工具执行。提示词依据当前源码、实验报告和开发过程整理，**不表示这些文字都曾在历史对话中逐字发送**。代码片段只摘录接口和布局，不提供完整函数答案；未完成的功能和运行结果均写为待执行要求。

| 编号 | 练习位置 | 提示词作用 | 主要文件 |
|---|---|---|---|
| 任务 1-A | 功能模块一 · 2411102-程浩轩 | 建立或替换虚拟页映射 | `code/kern/mm/pmm.c` |
| 任务 1-B | 功能模块一 · 2411102-程浩轩 | 删除虚拟页映射 | `code/kern/mm/pmm.c` |
| 任务 2-A | 功能模块二 · 2411112-徐子恩 | 分配并初始化 PCB | `code/kern/process/proc.c` |
| 任务 2-B | 功能模块二 · 2411112-徐子恩 | 准备线程现场与内核地址空间 | `code/kern/process/proc.c`、`entry.S` |
| 任务 2-C | 功能模块二 · 2411112-徐子恩 | 创建内核线程并初始化进程管理 | `code/kern/process/proc.c` |
| 任务 3-A | 功能模块三 · 2410935-胡家华 | 调度与 idleproc 空闲循环 | `code/kern/schedule/sched.c`、`code/kern/process/proc.c` |
| 任务 3-B | 功能模块三 · 2410935-胡家华 | 进程切换与 RISC-V context 保存恢复 | `code/kern/process/proc.c`、`switch.S` |
| 任务 4 | 全组联调 | 构建、QEMU 运行、自检与验收 | `code/Makefile`、`code/tools/`、各模块 |

源码现状：`get_pte()`、`get_page()`、`wakeup_proc()` 已提供；没有 `page_remove_pte()`，不应将其列为必做函数。`page_insert()`、`page_remove()` 与模块二六个函数在当前工作树中已有实现，任务 1、2 适合复核或重做对应范围。`schedule()`、`cpu_idle()`、`proc_run()`、`switch_to()` 尚待完成。仓库中未找到实验指导书或 README；如课程另外提供指导书，执行者应先核对其必做范围。

---

# 任务 1-A：建立虚拟页映射

### [PROMPT]

**任务**：在 `code/kern/mm/pmm.c` 中实现或复核 `page_insert()`，负责将虚拟地址映射到物理页，并处理替换映射、权限、引用计数和 TLB。

**输出要求**：直接修改目标函数的必要代码；若当前实现已正确，只报告核对结果。保留 `pmm_init()`、页分配器、既有页表辅助函数、测试断言及其他成员代码，不重写文件。

**输入要求**：先阅读 `code/kern/mm/pmm.c`、`pmm.h`、`mmu.h`、`memlayout.h`、`code/libs/error.h`、`code/tools/test_lab4.c`，核对 Sv39 PTE 构造方式和现有自检。不得假定其他版本的 uCore 使用相同页表布局。

### [RELY]

当前框架的关键类型、标志和接口摘录：

```c
typedef uintptr_t pte_t;
typedef uintptr_t pde_t;
struct Page { int ref; uint_t flags; unsigned int property;
              list_entry_t page_link; list_entry_t pra_page_link;
              uintptr_t pra_vaddr; };
#define PTE_V 0x001
#define PTE_R 0x002
#define PTE_W 0x004
#define PTE_X 0x008
#define PTE_U 0x010
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create);
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store);
struct Page *alloc_pages(size_t n);
void free_pages(struct Page *base, size_t n);
void tlb_invalidate(pde_t *pgdir, uintptr_t la);
```

`pmm.h` 还提供 `page2pa()`、`page2ppn()`、`pte2page()`、`page_ref()`、`page_ref_inc()`、`page_ref_dec()` 及 `alloc_page()`、`free_page()`；`mmu.h` 提供 PTE 位，`pmm.c` 当前用 `pte_create(page2ppn(page), perm)` 构造叶子 PTE。`get_pte(..., 1)` 可在中间页表缺失时申请页表页；若无法取得 PTE，返回 `NULL`。本框架没有 `page_remove_pte()`。

### [GUARANTEE]

需要保持的接口：

```c
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm);
```

- 只改 `page_insert()` 对应实现，不改变函数签名、错误码或其他内存管理函数。
- 映射成功后 PTE 指向目标页，具有要求的权限和有效位；目标页引用计数只增加实际新增的映射数。
- 替换旧页时正确减少旧页引用；当前页表变化后执行工程提供的 TLB 失效接口。
- 保留 `check_pgdir()`、`check_boot_pgdir()` 与现有模块一成果。

### [SPECIFICATION]

#### page_insert()

**Pre-Condition**：`pgdir` 是有效内核虚拟地址；`page` 是可管理的 `Page`；`la` 为待映射虚拟地址；`perm` 由当前框架的 PTE 权限位组成。调用方负责提供有效参数。

**Post-Condition**：成功返回 `0`，`la` 的有效叶子 PTE 指向 `page`，权限更新，引用计数与实际映射数一致，旧 TLB 转换失效。获取页表失败返回 `-E_NO_MEM`，不增加目标页引用，也不改变原有效映射。

**Case 1：叶子 PTE 所在页表不存在。** 调用已有 `get_pte(pgdir, la, 1)` 创建必要的中间页表；取得 PTE 后再触碰目标页引用计数。

**Case 2：中间页表分配失败。** `get_pte()` 返回 `NULL` 时立即返回 `-E_NO_MEM`；不得写入 PTE、提前 `page_ref_inc()` 或误释放 `page`。

**Case 3：原 PTE 无效。** 为目标页增加一次引用，写入由 `page2ppn(page)`、`perm` 构造的有效 PTE，并使相应 TLB 项失效。

**Case 4：原 PTE 已指向同一页。** 允许修改权限；净引用计数必须不变，不能因重复插入而多算映射。

**Case 5：原 PTE 指向其他页。** 从原 PTE 找到旧 `Page`，撤销旧引用；旧页引用降到零才释放。随后写入目标映射，目标页增加一次引用。

**Requirements**：不把 `page2pa()` 的物理地址当成 `Page *`；不自行实现 `page_remove_pte()`；核对 `pte_create()` 是否设置 `PTE_V`；用当前自检覆盖插入、替换、同页更新和权限位，不修改测试来制造通过结果。

---

# 任务 1-B：删除虚拟页映射

### [PROMPT]

**任务**：在 `code/kern/mm/pmm.c` 中实现或复核 `page_remove()`，移除一个虚拟地址的有效映射并维护物理页引用计数。

**输出要求**：直接修改目标函数；已有实现满足要求时保持原样。保留模块一页表插入代码、物理页管理器、自检和其他成员实现。

**输入要求**：阅读 `pmm.c`、`pmm.h`、`mmu.h`、`memlayout.h` 和 `code/tools/test_lab4.c`，确认 `get_pte()` 查找行为、`pte2page()` 的前置条件与 TLB 接口。

### [RELY]

```c
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create);
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store);
void tlb_invalidate(pde_t *pgdir, uintptr_t la);
static inline struct Page *pte2page(pte_t pte);
static inline int page_ref_dec(struct Page *page);
#define PTE_V 0x001
#define free_page(page) free_pages(page, 1)
```

`get_pte(..., 0)` 不应为删除操作创建页表；`pte2page()` 仅能用于带 `PTE_V` 的有效 PTE。`pmm.c` 内不存在 `page_remove_pte()`，本任务无须补造该接口。

### [GUARANTEE]

需要保持的接口：

```c
void page_remove(pde_t *pgdir, uintptr_t la);
```

- 只改 `page_remove()`；不改变 `get_pte()`、`page_insert()` 或页分配器签名。
- 无映射时安全返回；有效映射删除后 PTE 清零，引用计数准确，必要时释放旧页和刷新 TLB。
- 删除一个映射不得提前释放仍被其他虚拟地址引用的物理页。

### [SPECIFICATION]

#### page_remove()

**Pre-Condition**：`pgdir` 指向可访问的页表根，`la` 是待解除映射的虚拟地址；调用方满足现有页表接口的地址约束。

**Post-Condition**：无映射时无副作用；存在有效映射时删除目标 PTE，旧页引用减少一次，引用归零才释放，并使目标地址的旧 TLB 项失效。函数无返回值。

**Case 1：对应中间页表不存在。** `get_pte(pgdir, la, 0)` 返回 `NULL`，立即返回；不得申请新页表或访问空指针。

**Case 2：PTE 存在但无效。** `PTE_V` 未置位时直接返回；不得调用要求有效 PTE 的 `pte2page()`，也不得减少任何页的引用。

**Case 3：旧页仍被其他映射引用。** 取出旧 `Page`，清除 PTE，只减少一次引用；引用仍大于零时不得 `free_page()`。

**Case 4：删除后引用变为零。** 清除 PTE、减少引用后调用 `free_page()`；使 `la` 的 TLB 项失效，后续访问不得沿用旧转换。

**Requirements**：不要重复减少引用；不要把删除操作变成页表创建；保持页表自检、`page_insert()` 和其他组员代码不变；核对重复删除同一地址不会重复释放页。

---

# 任务 2-A：分配与初始化 PCB

### [PROMPT]

**任务**：在 `code/kern/process/proc.c` 实现或复核 `alloc_proc()`，只负责创建具有确定初值的 PCB，不负责完成进程登记。

**输出要求**：直接修改目标函数的必要代码；保留其他五个模块二函数、调度函数、内存管理及测试。若当前函数已正确，给出核对结论，不覆盖它。

**输入要求**：阅读 `proc.c`、`proc.h`、`code/kern/mm/kmalloc.h`、`pmm.h`、`memlayout.h`、`code/libs/list.h`，核对真实字段、页表全局变量和分配器行为。

### [RELY]

```c
struct context { uintptr_t ra, sp, s0, s1, s2, s3, s4, s5,
                 s6, s7, s8, s9, s10, s11; };
struct proc_struct {
    enum proc_state state; int pid; int runs; uintptr_t kstack;
    volatile bool need_resched; struct proc_struct *parent;
    struct mm_struct *mm; struct context context; struct trapframe *tf;
    uintptr_t pgdir; uint32_t flags; char name[PROC_NAME_LEN + 1];
    list_entry_t list_link, hash_link;
};
void *kmalloc(size_t n);
void kfree(void *objp);
void *memset(void *s, char c, size_t n);
static inline void list_init(list_entry_t *elm);
extern uintptr_t boot_pgdir_pa;
```

以上结构体代码是从真实字段压缩排版的摘录；定义位置分别为 `proc.h`、`kmalloc.h`、`list.h`、`pmm.h`，实际编写时仍以原文件为准。

### [GUARANTEE]

需要实现的接口：

```c
static struct proc_struct *alloc_proc(void);
```

- 保持 `static`、返回类型与调用方不变，只修改 `proc.c` 的目标函数。
- 分配成功的 PCB 各字段确定，两个链表节点可安全入链；失败时返回 `NULL`。
- 不在此处申请内核栈、登记 PID、插入全局表或唤醒进程。

### [SPECIFICATION]

#### alloc_proc()

**Pre-Condition**：`kmalloc_init()` 已随物理内存初始化完成；`boot_pgdir_pa` 已由页表初始化提供；调用方尚未持有该新进程的资源。

**Post-Condition**：成功时返回独立 PCB，状态 `PROC_UNINIT`、PID `-1`、页表地址 `boot_pgdir_pa`，其余字段有确定初值，链表节点已初始化；失败时返回 `NULL`，无新 PCB 对外可见。

**Case 1：`kmalloc(sizeof(struct proc_struct))` 失败。** 直接返回 `NULL`；不得解引用或初始化空指针。

**Case 2：分配成功。** 用 `memset()` 清空整个结构体，覆盖 context、名称、计数、指针和 flags；再设置非零默认值及两个链表节点。

**Case 3：后续分配内核栈或地址空间失败。** 本函数没有获取这些资源，也不负责回收；由 `do_fork()` 对已返回 PCB 调用 `kfree()`。不要在 `alloc_proc()` 中提前分配 PID。

**Requirements**：区分 PCB 初始化与完整进程创建；不得把 `pgdir` 写成 x86 CR3；不得改变 `proc_struct` 定义或修改 `proc_init()`、`do_fork()` 的工作。

---

# 任务 2-B：准备线程现场与内核地址空间

### [PROMPT]

**任务**：在 `code/kern/process/proc.c` 实现或复核 `kernel_thread()`、`copy_thread()`、`copy_mm()`，准备内核线程第一次运行所需的 trapframe、context 和共享内核页表。

**输出要求**：直接修改这三个函数；已正确的部分保持原状。保留 `entry.S` 的线程入口、`proc.h` 结构体、其他组员代码和课程测试。不要代替模块三实现调度。

**输入要求**：阅读 `proc.c`、`proc.h`、`entry.S`、`code/kern/trap/trapentry.S`、`trap.h`、`pmm.h`、`memlayout.h`、`code/libs/riscv.h`，核对 `s0/s1` 约定、`sstatus` 位和栈布局。

### [RELY]

```c
struct context { uintptr_t ra, sp, s0, s1, s2, s3, s4, s5,
                 s6, s7, s8, s9, s10, s11; };
struct trapframe { struct pushregs gpr; uintptr_t status, epc, badvaddr, cause; };
/* pushregs 的相关真实字段：sp、a0、s0、s1 */
#define KSTACKPAGE 2
#define KSTACKSIZE (KSTACKPAGE * PGSIZE)
#define CLONE_VM 0x00000100
#define SSTATUS_SIE 0x00000002
#define SSTATUS_SPIE 0x00000020
#define SSTATUS_SPP 0x00000100
extern uintptr_t boot_pgdir_pa;
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
void kernel_thread_entry(void);
void forkrets(struct trapframe *tf);
```

`entry.S` 的入口约定为：

```asm
kernel_thread_entry:
    move a0, s1
    jalr s0
    jal do_exit
```

`proc.c` 中 `forkret()` 调用 `forkrets(current->tf)`；`trapentry.S` 中 `forkrets` 将 `sp` 置为传入 trapframe 地址，再跳转 `__trapret`。后者的恢复宏当前留有 Lab3 空缺，不能宣称首次运行链路已打通。

### [GUARANTEE]

三个目标接口保持原签名和修饰符：

```c
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);
static void copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf);
static int copy_mm(uint32_t clone_flags, struct proc_struct *proc);
```

- 只修改 `proc.c` 的这三个函数；不改变 `entry.S`、`trapentry.S`、`switch.S` 或模块三实现。
- 新线程得到有效初始现场和内核栈布局，地址空间按当前内核线程语义设置。
- 不宣称完整用户地址空间复制、进程调度或线程实际执行已在此任务完成。

### [SPECIFICATION]

#### kernel_thread()

**Pre-Condition**：`fn` 是可调用的内核函数，进程系统已初始化，当前进程有效；调用方传入 `arg` 和 `clone_flags`。

**Post-Condition**：构造清零的临时 trapframe，记录函数和参数，设置内核态初始返回现场；返回 `do_fork()` 的 PID 或负错误码，不自行登记进程。

**Case 1：正常创建。** 将 `fn` 放入 `gpr.s0`、`arg` 放入 `gpr.s1`，`epc` 指向 `kernel_thread_entry`；`sstatus` 置 `SPP`、`SPIE`，清 `SIE`；以 `clone_flags | CLONE_VM` 和栈参数 `0` 调用 `do_fork()`。

**Case 2：`do_fork()` 拒绝创建。** 原样向调用方返回 `-E_NO_MEM`、`-E_NO_FREE_PROC` 或其他由实际路径产生的负错误码；局部 trapframe 无需堆资源回收。

**Requirements**：按现有 `entry.S` 使用 `s0/s1`，不要误用 x86 寄存器；解释 `SPIE` 控制 `sret` 后中断状态；只准备现场，不声称已发生上下文切换。

#### copy_thread()

**Pre-Condition**：`proc` 和 `tf` 有效，`setup_kstack()` 已为新 PCB 分配 `KSTACKPAGE` 页内核栈；`esp` 为调用方指定栈指针或零。

**Post-Condition**：`proc->tf` 位于新栈顶部下方，内容来自 `tf`；子进程返回寄存器为零；`context.ra` 指向 `forkret`，`context.sp` 指向 trapframe。

**Case 1：`esp == 0`。** 线程的初始 `gpr.sp` 取 `proc->kstack + KSTACKSIZE`，保留从栈顶向下增长的空间。

**Case 2：`esp != 0`。** 将给定 `esp` 作为初始 `gpr.sp`；调用方负责传入满足当前 ABI 的栈指针。

**Case 3：首次切换准备。** 复制完整 trapframe 后令 `gpr.a0 = 0`；`context.ra` 使首次切换进入 `forkret`。`context` 是 switch_to 使用的内核切换现场，`trapframe` 是 Trap 返回所需的寄存器现场，二者不能混用。

**Requirements**：按实际 `sizeof(struct trapframe)` 从栈顶留空间并检查 RISC-V 16 字节栈对齐；不在本函数分配或释放栈；不修改传入的原 trapframe。

#### copy_mm()

**Pre-Condition**：`proc` 已分配，`current` 有效；本实验阶段只创建内核线程。

**Post-Condition**：成功返回 `0`，`proc->mm == NULL`，`proc->pgdir == boot_pgdir_pa`；失败返回 `-E_INVAL`，不向进程链表公开半成品。

**Case 1：`current->mm == NULL`。** 新线程使用启动页表；当前代码显式忽略 `clone_flags`，只处理内核地址空间。

**Case 2：`current->mm != NULL`。** 返回 `-E_INVAL`，交由 `do_fork()` 回收已申请资源；不尝试复制用户 VMA 或页表。

**Requirements**：不得把 `CLONE_VM` 标志解释为已实现完整共享用户地址空间语义；不得提前实现用户进程地址空间复制，也不得引入独立用户页表。

---

# 任务 2-C：创建进程并初始化管理系统

### [PROMPT]

**任务**：在 `code/kern/process/proc.c` 实现或复核 `do_fork()`、`proc_init()`，完成 PCB 和内核栈申请、PID 登记、状态转换，以及 idleproc、initproc 初始化。

**输出要求**：直接修改两个目标函数的必要代码；已实现且正确的逻辑保留。不得修改页映射、调度汇编、课程测试或其他成员代码。

**输入要求**：阅读 `proc.c`、`proc.h`、`pmm.h`、`memlayout.h`、`sched.h`、`sync.h`、`list.h`、`error.h`、`code/kern/init/entry.S` 与 `code/tools/test_lab4.c`，核对辅助函数定义、错误码及 bootstack 来源。

### [RELY]

```c
static struct proc_struct *alloc_proc(void);
static int setup_kstack(struct proc_struct *proc);
static void put_kstack(struct proc_struct *proc);
static int copy_mm(uint32_t clone_flags, struct proc_struct *proc);
static void copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf);
static int get_pid(void);
static void hash_proc(struct proc_struct *proc);
struct proc_struct *find_proc(int pid);
void wakeup_proc(struct proc_struct *proc);
char *set_proc_name(struct proc_struct *proc, const char *name);
extern list_entry_t proc_list;
extern struct proc_struct *idleproc, *initproc, *current;
extern char bootstack[], bootstacktop[];
#define MAX_PROCESS 4096
#define E_NO_MEM 4
#define E_NO_FREE_PROC 5
#define E_INVAL 3
```

`hash_list[HASH_LIST_SIZE]`、`nr_process`、`init_main()` 均为 `proc.c` 内部对象；`setup_kstack()` 调用 `alloc_pages(KSTACKPAGE)`，`put_kstack()` 归还这些页。`local_intr_save(flag)`、`local_intr_restore(flag)` 来自 `code/kern/sync/sync.h`。`entry.S` 已预留 `bootstack`，idleproc 不需要新栈。

### [GUARANTEE]

必须保持的接口：

```c
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
void proc_init(void);
```

- 只改 `proc.c` 的两个目标函数，不改上述辅助函数签名、`proc_struct` 布局或调度模块。
- 成功创建的普通内核线程具有唯一 PID、独立内核栈、完整初始现场，且在登记后才成为 `PROC_RUNNABLE`。
- 失败时 PCB、内核栈按逆序回收，`nr_process` 和全局链表、哈希表无半成品。
- `proc_init()` 建立 PID 0 的 idleproc 和首个 initproc，保留断言与名称设置。

### [SPECIFICATION]

#### do_fork()

**Pre-Condition**：进程链表及哈希表已初始化；`current` 指向合法当前进程；`tf` 指向可复制的 trapframe；本阶段满足 `copy_mm()` 的内核地址空间限制。

**Post-Condition**：成功返回新 PID，进程在全局链表与 PID 哈希表可见，计数增加一次，状态为 `PROC_RUNNABLE`。失败返回负错误码，既有进程登记不变、已申请资源回收。

**Case 1：`nr_process >= MAX_PROCESS`。** 返回 `-E_NO_FREE_PROC`；不调用 PCB 或栈分配器。

**Case 2：`tf == NULL`。** 返回 `-E_INVAL`；不改变任何进程登记。

**Case 3：`alloc_proc()` 返回 `NULL`。** 返回 `-E_NO_MEM`，无 PCB 可释放，也不得更新数量。

**Case 4：`setup_kstack()` 失败。** 已有 PCB、尚无栈；进入 `bad_proc` 调用 `kfree(proc)`，返回实际栈分配错误。

**Case 5：`copy_mm()` 失败。** 已有 PCB 和栈；从 `bad_kstack` 调用 `put_kstack(proc)`，再落入 `bad_proc` 释放 PCB；不得先登记 PID。

**Case 6：完整创建成功。** 顺序执行 `alloc_proc → parent=current → setup_kstack → copy_mm → copy_thread`；随后保存并关闭本地中断，调用 `get_pid()`，用 `hash_proc()` 和 `list_add()` 登记，增加 `nr_process`，用 `wakeup_proc()` 转为可运行，恢复原中断状态并返回 PID。

**Requirements**：登记前必须完成全部资源与执行现场初始化；不要把 `wakeup_proc()` 当成立即运行；失败路径不得漏掉栈或 PCB；本地关中断仅是当前单核框架的临界区做法，不能称为完整多核同步；不得修改 `MAX_PROCESS` 绕开上限。

#### proc_init()

**Pre-Condition**：`pmm_init()` 已建立启动页表及 `boot_pgdir_pa`，启动汇编已提供 `bootstack`，进程系统尚未初始化。

**Post-Condition**：`proc_list` 与各 PID 哈希桶初始化；`idleproc` 的 PID 为 0、状态可运行、栈为 `bootstack`、`current == idleproc`、`nr_process == 1`；成功创建 initproc 后进程数为 2，`find_proc(pid)` 可找到它。

**Case 1：初始化管理结构。** 用 `list_init()` 建立空 `proc_list` 和所有 `hash_list` 桶；不得把未初始化链表交给 `get_pid()`。

**Case 2：创建 idleproc。** 用 `alloc_proc()` 分配 PCB，断言成功；设置 PID 0、`PROC_RUNNABLE`、`kstack=(uintptr_t)bootstack`、`need_resched=1`、名称、数量及 `current`。idleproc 不经 `setup_kstack()`，当前实现也不把它插入普通进程链表或 PID 哈希表。

**Case 3：创建 initproc。** 调用 `kernel_thread(init_main, "Hello world!!", 0)`，检查返回 PID；通过 `find_proc(pid)` 取得 PCB，断言指针与 PID 正确，设置名称 `init`，断言最终 `nr_process == 2`。

**Case 4：分配失败。** 当前初始化路径使用断言暴露无法建立 idleproc 或 initproc 的致命启动问题；不得虚构可继续运行的降级路径。

**Requirements**：区分 idleproc 复用启动栈与 initproc 经 `do_fork()` 新建栈；不为 PID 0 调用 `get_pid()`；保持已有初始化断言和进程名称；不要把创建成功描述为 initproc 已获得 CPU。

完整创建链：`proc_init → kernel_thread → do_fork → alloc_proc → setup_kstack → copy_mm → copy_thread → get_pid/hash_proc/入链表 → wakeup_proc`。模块二最终向调度器提供一个已登记、`PROC_RUNNABLE` 的 initproc；实际选择和切换由模块三完成。

---

# 任务 3-A：调度与空闲进程管理

### [PROMPT]

**任务**：由 2410935-胡家华负责，在 `code/kern/schedule/sched.c` 完成 `schedule()`，并在 `code/kern/process/proc.c` 完成 `cpu_idle()`；核对已提供的 `wakeup_proc()`，仅在确有缺陷时修改它。

**输出要求**：直接修改目标函数的必要代码，不重写模块二创建流程、`proc.h`、测试文件或模块一实现。保持现有简单链表调度框架，不擅加优先级调度器。

**输入要求**：阅读 `sched.c`、`sched.h`、`proc.c`、`proc.h`、`list.h`、`sync.h`、`code/kern/init/init.c` 和 `code/tools/test_lab4.c`，确认状态断言、进程链表遍历及调用关系。

### [RELY]

```c
enum proc_state { PROC_UNINIT = 0, PROC_SLEEPING, PROC_RUNNABLE, PROC_ZOMBIE };
struct proc_struct {
    enum proc_state state; int pid; int runs; uintptr_t kstack;
    volatile bool need_resched; struct proc_struct *parent;
    struct mm_struct *mm; struct context context; struct trapframe *tf;
    uintptr_t pgdir; uint32_t flags; char name[PROC_NAME_LEN + 1];
    list_entry_t list_link, hash_link;
};
extern list_entry_t proc_list;
extern struct proc_struct *idleproc, *initproc, *current;
void proc_run(struct proc_struct *proc);
void schedule(void);
```

`list_next()`、`le2proc()` 和 `local_intr_save/restore()` 已存在。`proc_init()` 将 idleproc 设为当前进程并置 `need_resched=1`；`kern_init()` 最后调用 `cpu_idle()`。当前 `wakeup_proc()` 的实际逻辑：

```c
assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
proc->state = PROC_RUNNABLE;
```

### [GUARANTEE]

目标及现有接口：

```c
void schedule(void);
void cpu_idle(void) __attribute__((noreturn));
void wakeup_proc(struct proc_struct *proc); /* 已有实现，优先保持 */
```

- `schedule()` 只选 `PROC_RUNNABLE`，必要时回退到 idleproc；`cpu_idle()` 保持可持续空闲循环。
- 不破坏 `do_fork()` 已建立的 PID、链表和状态；不在唤醒时直接把进程视为已执行。
- 修改范围限于模块三目标函数；运行计数、`need_resched` 和中断状态按当前框架维护。

### [SPECIFICATION]

#### wakeup_proc()：现有依赖的核对

**Pre-Condition**：`proc` 指向合法 PCB；当前实现断言其既不是 `PROC_ZOMBIE`，也不是 `PROC_RUNNABLE`。

**Post-Condition**：允许唤醒的进程转为 `PROC_RUNNABLE`，链表与 PID 不变；并未立即得到 CPU。

**Case 1：状态为 `PROC_UNINIT` 或 `PROC_SLEEPING`。** 可按已有逻辑设置可运行状态。

**Case 2：状态为僵尸或已可运行。** 现有断言拒绝该调用；不得删除断言掩盖调用者错误。

**Requirements**：仅在课程要求与实际调用证明需要时调整；不要重复实现已有正确逻辑。

#### schedule()

**Pre-Condition**：进程系统完成初始化，`current`、`idleproc` 有效，普通进程以 `list_link` 登记在 `proc_list` 中。

**Post-Condition**：完成一次调度决策，清理当前进程的重调度标志；需要切换时调用 `proc_run()`。中断状态最终按进入函数前的状态恢复。

**Case 1：存在其他可运行进程。** 从当前进程在链表中的位置继续循环查找；当前为未入链的 idleproc 时从链表头开始；选择状态为 `PROC_RUNNABLE` 的候选进程。

**Case 2：只有当前普通进程可运行。** 可选回自身并避免无意义的 `proc_run()`，保持其运行。

**Case 3：普通进程链表没有可运行进程。** 回退到 idleproc；不要把睡眠进程当作可运行候选。

**Case 4：链表含睡眠、未初始化或僵尸进程。** 跳过它们，继续循环寻找；不得因遇到第一个不可运行节点就停止搜索。

**Requirements**：用本地中断保存与恢复保护决策和共享状态；核对 `runs` 应在何处递增，避免一次切换重复计数；不擅加优先级、时间片或多核调度逻辑；根据实际 `proc_run()` 返回语义核对中断恢复位置。

#### cpu_idle()

**Pre-Condition**：`current == idleproc`，进程系统和时钟中断已由 `kern_init()` 初始化。

**Post-Condition**：不返回到 `kern_init()`，持续执行空闲循环，并在 `need_resched` 指示时调用 `schedule()`。

**Case 1：需要调度。** 调用 `schedule()`，允许可运行内核线程获得 CPU。

**Case 2：没有其他可运行进程。** 保持空闲循环；若采用 `wfi`，必须核对中断状态，不能永久关中断造成无法唤醒。

**Requirements**：idleproc 是兜底执行实体；不要在循环中重复创建进程、无条件 panic 或吞掉中断。

---

# 任务 3-B：进程切换与 RISC-V 上下文切换

### [PROMPT]

**任务**：由 2410935-胡家华负责，在 `code/kern/process/proc.c` 完成 `proc_run()`，在 `code/kern/process/switch.S` 完成 `switch_to()`。让调度器选中的进程得到正确的内核上下文，首次运行时进入 `forkret`。

**输出要求**：直接修改这两个目标实现，不重写 `copy_thread()`、`kernel_thread_entry`、`trapentry.S` 或其他组员代码。保留 RISC-V ABI 和现有结构体字段顺序，不引用 x86 的 CR3、TSS。

**输入要求**：阅读 `proc.h`、`proc.c`、`switch.S`、`entry.S`、`sched.c`、`trapentry.S`、`trap.h`、`pmm.c`、`pmm.h`、`code/libs/riscv.h`，核对当前 `satp`/Sv39 切换方式、栈布局、首次执行路径与 Lab3 的 Trap 依赖。

### [RELY]

当前 `struct context` 的字段顺序与 RV64 偏移如下，单位为字节：

```c
struct context {
    uintptr_t ra;  // 0
    uintptr_t sp;  // 8
    uintptr_t s0;  // 16
    uintptr_t s1;  // 24
    uintptr_t s2;  // 32
    uintptr_t s3;  // 40
    uintptr_t s4;  // 48
    uintptr_t s5;  // 56
    uintptr_t s6;  // 64
    uintptr_t s7;  // 72
    uintptr_t s8;  // 80
    uintptr_t s9;  // 88
    uintptr_t s10; // 96
    uintptr_t s11; // 104
};
```

上面的偏移注释按当前 RV64 `uintptr_t` 宽度推得，执行前应与编译目标核对。其余真实依赖：

```c
void switch_to(struct context *from, struct context *to);
extern struct proc_struct *current;
extern uintptr_t boot_pgdir_pa;
#define SSTATUS_SIE 0x00000002
#define REGBYTES (1 << LOG_REGBYTES)
/* RV64 分支：#define STORE sd，#define LOAD ld */
```

`proc_struct` 中的 `context`、`pgdir`、`kstack`、`tf` 均见 `proc.h`。`pmm.c` 启用分页时使用 `satp` 的 Sv39 模式位及 `boot_pgdir_pa >> RISCV_PGSHIFT`，随后刷新 TLB；新内核线程的 `pgdir` 目前是 `boot_pgdir_pa`。`copy_thread()` 已令 `context.ra = forkret`、`context.sp = (uintptr_t)proc->tf`。

### [GUARANTEE]

需要实现的接口：

```c
void proc_run(struct proc_struct *proc);
void switch_to(struct context *from, struct context *to);
```

- `proc_run()` 在目标不同于 `current` 时更新当前进程、按真实页表机制处理地址空间，再把旧、新 context 传给 `switch_to()`。
- `switch_to()` 保存和恢复 `ra`、`sp`、`s0` 至 `s11`，偏移与 `proc.h` 完全一致。
- 不在切换代码中分配 PCB 或内核栈，不替其他模块补上用户进程复制或完整退出回收。
- 保留模块二构造的首次运行现场、`forkrets` 符号及课程测试。

### [SPECIFICATION]

#### proc_run()

**Pre-Condition**：`proc` 是有效且可运行的 PCB，其 `context`、内核栈和 `pgdir` 已由创建路径初始化；`current` 指向当前执行进程。

**Post-Condition**：目标与当前相同时无上下文切换；目标不同时保存旧 current、更新 current，切换到目标进程现场；旧进程将来恢复时，原先保存的中断状态被正确恢复。

**Case 1：目标就是 `current`。** 直接返回，不改 `satp`，不调用 `switch_to()`，不重复统计一次切换。

**Case 2：目标是另一个内核线程。** 用本地中断保护切换临界区，保存旧进程指针并更新 `current`；核对目标 `pgdir` 的物理地址如何写入 RISC-V `satp` 并刷新 TLB；调用 `switch_to(&old->context, &proc->context)`。

**Case 3：旧进程以后被切换回来。** `switch_to()` 返回到旧调用点后，`proc_run()` 必须恢复进入时保存的中断状态；不得把目标进程的 `need_resched` 或当前指针恢复为旧值。

**Requirements**：页表切换只能用当前 RISC-V Sv39 接口和位定义，不能照搬 x86 CR3；如果所有当前线程共用启动页表，也仍需核对课程框架对 `satp` 的要求；不在此处直接调用 `forkret()`。

#### switch_to()

**Pre-Condition**：RV64 调用约定将 `from`、`to` 分别放在 `a0`、`a1`；二者指向有效且不重叠的 `struct context`。上层已处理同一进程的情况。

**Post-Condition**：旧进程的返回地址、栈指针和被调用者保存寄存器写入 `from`；从 `to` 恢复相同寄存器并按新 `ra` 继续执行。

**Case 1：新进程首次获得 CPU。** `to->ra` 是 `forkret`、`to->sp` 是其 trapframe 地址；汇编恢复后 `ret` 进入 `forkret`，不得试图恢复一个并不存在的旧 C 调用现场。

**Case 2：此前运行过的进程再次获得 CPU。** 恢复其上次保存的 `ra`、`sp` 与 `s0` 至 `s11`，使其从原切换点继续。

**Case 3：目标与当前相同。** 由 `proc_run()` 跳过，汇编不应承担无意义的自切换。

**Requirements**：偏移以 `struct context` 的实际 RV64 布局逐项核对；`STORE`、`LOAD`、`REGBYTES` 来自 `riscv.h`；避免在恢复 `a0/a1` 之前丢失两个 context 指针；不保存无需跨普通 C 调用持久化的临时寄存器来替代 `s` 寄存器。

#### 新线程首次运行链路与边界

**Pre-Condition**：`copy_thread()` 已生成 context 与 trapframe，调度器已选择该进程；`forkrets` 和 Trap 返回代码可用。

**Post-Condition**：预期路径是 `switch_to → forkret → forkrets → __trapret → kernel_thread_entry → fn(arg)`；是否实际走通只能由完整 QEMU 运行确认。

**Case 1：context 恢复。** `ra` 决定先进入 `forkret()`；它把 `current->tf` 交给 `forkrets`。

**Case 2：Trap 返回。** `forkrets` 把 `sp` 置为 trapframe，跳 `__trapret`；后者须正确恢复 `sstatus`、`sepc` 与通用寄存器，再由 `sret` 进入 `kernel_thread_entry`。

**Case 3：线程函数返回。** `entry.S` 将 `s1` 放入 `a0` 并经 `s0` 调用函数，返回后调用 `do_exit()`；当前 `do_exit()` 仍以 `panic("process exit!!.\n")` 占位，不得声称已实现正常退出、资源回收或等待机制。

**Requirements**：`trapentry.S` 的 `RESTORE_ALL` 和 `__alltraps` 仍有 Lab3 遗留空缺，应在联调时核对并由相应负责人处理；本任务不要把全部 Lab3 中断异常处理重新列作 Lab4 新功能，也不得虚构首次运行已通过。

---

# 任务 4：全组联调、测试与验收

### [PROMPT]

**任务**：在模块一、二、三合并后，检查 `code/` 下 RISC-V uCore 内核的页映射、进程创建、调度、上下文切换与首次运行链路，记录真实构建、QEMU 和评分结果。

**输出要求**：优先定位缺失接口和模块归属，必要修复只在对应负责人授权范围内进行；保留已有源码、断言、测试和其他成员修改。不要通过注释核心路径、永久测试桩、修改评分脚本或伪造截图获得通过。

**输入要求**：阅读 `report/report.md`、`code/Makefile`、`code/tools/test_lab4.c`、`grade.sh`、`pmm.c`、`proc.c`、`sched.c`、`switch.S`、`entry.S`、`trapentry.S`、`trap.h`、`init.c` 及相关头文件；重新检查当前 Git 状态。若另有课程指导书，再核对验收指标。

### [RELY]

```c
void pmm_init(void);
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm);
void page_remove(pde_t *pgdir, uintptr_t la);
void proc_init(void);
void cpu_idle(void) __attribute__((noreturn));
void schedule(void);
void proc_run(struct proc_struct *proc);
void switch_to(struct context *from, struct context *to);
extern struct proc_struct *idleproc, *initproc, *current;
```

`pmm.c` 含 `check_alloc_page()`、`check_pgdir()`、`check_boot_pgdir()`；`test_lab4.c` 含 `test_lab4_pmm_basic()`、`test_lab4_process_create()`、`test_lab4_schedule()`，需先核对测试入口是否实际调用。`init.c` 的初始化顺序为 `pmm_init → pic_init/idt_init → vmm_init → proc_init → clock_init/intr_enable → cpu_idle`。`entry.S` 与 `trapentry.S` 提供首次运行入口和 `forkrets`；Trap 返回宏当前有空缺。

`code/Makefile` 当前有默认构建、`qemu`、`grade`、`clean` 目标；`grade` 在 `/tmp/lab4_grade` 下运行 `tools/grade.sh`。没有独立的 `make test` 目标，不要编造。当前 `qemu` 目标采用 `-device loader,file=$(UCOREIMG),addr=0x80200000`，执行前应核对是否适配现有镜像。

### [GUARANTEE]

本任务不是新增必做函数；必须核对的接口为：

```c
void proc_init(void);
void cpu_idle(void) __attribute__((noreturn));
void schedule(void);
void proc_run(struct proc_struct *proc);
void switch_to(struct context *from, struct context *to);
```

- 分别报告单文件编译、完整链接、QEMU 运行和评分的结果，不把一个层次的成功替代其他层次。
- 验证页映射自检、idleproc/initproc 字段、PID 与状态、从 idleproc 到 initproc 的调度和线程入口实际输出。
- 保留课程任务标记、原有断言和测试；最终检查 Git 差异、临时测试代码与图片、日志真实性。

### [SPECIFICATION]

#### 阶段一：构建验证

**Pre-Condition**：三位成员的源码已合并，运行环境具有当前 Makefile 要求的 RISC-V 交叉工具链。

**Post-Condition**：记录各目标的真实退出码和关键日志；编译、链接问题按文件和函数归属处理。

**Case 1：先编译关键对象。** 在 `code/` 执行 `make -B obj/kern/process/proc.o`，并按 Makefile 规则检查页映射与调度对象；此前 `proc.o` 的独立编译曾成功，但不代表完整内核运行通过。

**Case 2：完整构建。** 执行 `make clean`、`make`；此前完整构建曾因 `cpu_idle` 未定义而链接失败。若最新源码已补齐，应把它记录为历史集成问题，不再称当前仍失败。

**Case 3：时间戳警告。** 将 `Clock skew detected` 与真正的编译/链接错误区分；不能仅凭警告认定代码失败，也不能忽略错误退出码。

**Requirements**：`make clean` 会清理构建产物，执行前确认工作区；不得删除源文件或未备份的用户数据。

#### 阶段二：内核启动与页映射验证

**Pre-Condition**：完整内核已成功链接，QEMU 启动参数与镜像方式已经核对。

**Post-Condition**：用真实日志确认物理内存初始化、页表操作及页引用计数自检是否完成。

**Case 1：`make qemu` 正常启动。** 检查框架自检 `check_alloc_page()`、`check_pgdir()`、`check_boot_pgdir()` 输出或断言，关注插入、替换、同页更新、删除与 TLB 行为。

**Case 2：QEMU 无法启动或提前异常。** 区分构建、装载、页表、Trap、调度问题；记录首个错误位置，不通过跳过断言或改测试掩盖问题。

**Requirements**：模块一报告中的独立 QEMU 截图仅证明当时的独立测试，不能当作此处整组联合运行证据。

#### 阶段三：进程创建验证

**Pre-Condition**：`proc_init()` 被 `kern_init()` 调用，内核已通过前置内存初始化。

**Post-Condition**：idleproc、initproc 的 PCB 字段与登记状态符合当前源码和测试要求。

**Case 1：idleproc。** 检查 PID 0、`current == idleproc`、状态可运行、栈为 `bootstack`、`mm == NULL`，并确认进程数初值。

**Case 2：initproc。** 检查合法 PID、父进程关系、独立内核栈、trapframe/context、启动页表、全局链表和 PID 哈希登记及 `PROC_RUNNABLE` 状态。

**Case 3：分配或地址空间失败。** 若有可执行的失败注入条件，检查负错误码、资源回收和进程数量不变；没有时明确标为未测，不伪造结果。

**Requirements**：`test_lab4_process_create()` 中的断言可作为依据，但须先核对该函数实际是否进入构建和运行路径。

#### 阶段四：调度与首次上下文切换

**Pre-Condition**：`cpu_idle()`、`schedule()`、`proc_run()`、`switch_to()` 与 Trap 返回路径均已完成，内核可以进入 idleproc 循环。

**Post-Condition**：真实运行日志或调试现场能证明 initproc 曾获得 CPU 并执行 `init_main()`。

**Case 1：选择可运行进程。** 检查 `schedule()` 跳过睡眠进程、选中 initproc，`proc_run()` 更新 `current`，`switch_to()` 保存并恢复对应 context。

**Case 2：首次运行。** 检查 `switch_to → forkret → forkrets → __trapret → kernel_thread_entry → init_main`；源码中的预期打印包括 `this initproc, pid = ...`、`To U: "Hello world!!".`、`To U: "en.., Bye, Bye. :)"`，具体格式以实际源码和输出核对。

**Case 3：线程函数返回。** 当前 `do_exit()` 使用 panic 占位；即使打印已经出现，也不能声称线程已正常退出、回收资源或关机。

**Requirements**：预期打印不是已获得的 QEMU 结果；如运行中 Trap 返回失败，应检查 `trapentry.S` 的 Lab3 遗留空缺，再定位模块三汇编。

#### 阶段五：最终验收与提交检查

**Pre-Condition**：前三个模块均已实现，已取得完整构建和实际运行记录。

**Post-Condition**：列出通过、失败和未测项目，保留真实日志与截图，工作区只包含预期改动。

**Case 1：课程评分目标可运行。** 使用当前 Makefile 的 `make grade`，记录分数和失败项；不得编辑 `grade.sh` 或 `test_lab4.c` 换取通过。

**Case 2：评分受环境或依赖阻断。** 说明具体命令、错误和阻断范围，不编造评分。

**Case 3：Git 审查。** 运行 `git status --short`、`git diff --check`，检查必做 TODO、重复定义、临时测试桩和各成员修改范围；未跟踪文件须单独检查，因为普通 `git diff` 不会显示其内容。

**Requirements**：不要自动提交或推送；不将模块一独立截图、模块二对象编译或预期线程输出冒充整组验收通过。
