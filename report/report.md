# 操作系统实验二：物理内存与页表——实验报告


> 小组成员：2411102-程浩轩，2411112-徐子恩，胡家华
> 实验环境：Windows + WSL Ubuntu、RISC-V GCC、QEMU、Git/GitHub
> 提交分支：`lab2`

## 一、实验目的

本实验的主要目的是：

1. 理解 uCore 在启动阶段如何探测物理内存、建立 `Page` 描述符并登记可用页。
2. 理解 First-Fit 连续物理内存分配器的空闲块初始化、分配、释放和相邻块合并过程。
3. 在 First-Fit 框架基础上实现 Best-Fit 分配器，并通过 AI 辅助完成代码设计、调试和测试。

---

## 二、实验环境

实验继续使用 Lab1 已配置的 WSL Ubuntu 环境，工具包括 `riscv64-unknown-elf-gcc`、`qemu-system-riscv64`、Git/GitHub，以及终端中的 AI 编程工具。代码仓库的目标分支为 `lab2`。

| 成员 | AI 编程工具 | 底层模型 | 备注 |
|---|---|---|---|
| 2411102-程浩轩 | 终端 AI 编程工具 | GPT-5 | 用于 `page_init()` 和 First-Fit 分析 |
| 2411112-徐子恩 | chatgpt | GPT-5.6 | 用于 Best-Fit 模块实现与调试 |
| 胡家华 | 待补充 | 待补充 | Buddy System |

重要文件如下：

| 文件 | 作用 |
|---|---|
| `kern/driver/dtb.c`、`dtb.h` | 获取设备树提供的物理内存起点和大小 |
| `kern/mm/pmm.c` | 组织内存管理器初始化、`page_init()`、分配测试 |
| `kern/mm/pmm.h`、`memlayout.h` | 定义 `Page`、`pmm_manager`、地址转换函数和内存范围常量 |
| `kern/mm/default_pmm.c` | 原有 First-Fit 分配器及测试 |
| `kern/mm/best_fit_pmm.c` | Best-Fit 实现文件 |
| `kern/init/entry.S` | 启动入口及早期页表相关代码 |
| `Makefile` | 编译和 QEMU 启动规则 |

---

## 三、实验整体逻辑分析

### 3.1 本章节的逻辑主线

本章围绕“如何在 uCore 中管理连续物理页”展开。内核启动后，首先需要由 `page_init()` 获取设备树中的物理内存范围，建立 `Page` 描述符数组，并排除内核和描述符本身占用的区域。随后，物理内存管理器把剩余页组织为空闲块，向上层提供连续页的分配与释放接口。实验先通过阅读完整的 First-Fit 实现理解空闲链表、页属性和相邻块合并，再在相同接口上实现 Best-Fit，并切换内核实际使用的管理器。最后通过内置检查、运行截图和评分脚本验证实现。

### 3.2 功能的逐步实现

1. 首先完成物理内存初始化，确定 `Page` 数组和真正可分配的物理页范围；这是后续所有分配器工作的基础。
2. 接着阅读 `default_pmm.c`，理解 First-Fit 如何登记、分配、回收和合并空闲块。
3. 然后根据 `pmm_manager` 接口实现 Best-Fit，遍历所有候选块并选择最小的满足块。
4. 最后把 `best_fit_pmm_manager` 注册到 `pmm.c`，确认 Best-Fit 源文件参与构建，并运行内核检查和 `make grade`。

---

## 四、实验内容与实现

### 4.1 组员分工与代码结构

| 成员 | 负责的练习/模块 |
|---|---|
| 2411102-程浩轩 | `page_init()` 物理内存探测和页描述符初始化；First-Fit 原理分析 |
| 2411112-徐子恩 | Best-Fit 连续物理内存分配算法 |
| 胡家华 | Buddy System（待补充） |

整体流程为：

```text
QEMU/OpenSBI 启动 → kern_entry → kern_init()
                                  ↓
                            pmm_init()
                                  ↓
                        init_pmm_manager()
                                  ↓
       page_init()：获取内存信息、建立 Page 数组、注册空闲页
                                  ↓
          check_alloc_page()：调用分配器自己的 check()
                                  ↓
          后续分配器实验：First-Fit → Best-Fit → Buddy System
```



### 4.2 功能模块一：物理内存初始化功能

**任务一：实现物理内存探测与页描述符初始化功能。**

#### 任务要求与设计思路

实现 `kern/mm/pmm.c` 中的 `static void page_init(void)`，依据设备树信息建立物理页面描述符布局，并将排除了 OpenSBI、内核和描述符数组占用区域之后的完整空闲页交给当前 `pmm_manager`。函数不需要传参或返回值；正常完成后应正确设置 `va_pa_offset`、`npage`、`pages` 等全局量。

思路是：先取物理内存范围并验证合法性，再确定允许管理的内存上界，设置内核虚拟地址到物理地址的偏移；随后在内核末尾之后按页对齐放置 `Page` 数组，用它记录物理页状态。描述符占用的空间也不能再分配，所以将其末尾向上对齐，作为真正空闲空间的起点。最后把这些空闲页交给 `init_memmap()`。

#### 关键代码及理解

实现位置是 `pmm.c` 中原有的 `//lab2 function1 YOUR CODE` 标记处。实际使用的主要接口有 `get_memory_base()`、`get_memory_size()`、`panic()`、`PADDR()`、`pa2page()` 和 `init_memmap()`。

**（1）探测和限制物理内存范围**

```c
uint64_t mem_base = get_memory_base();
uint64_t mem_size = get_memory_size();

if (mem_size == 0 || mem_base != DRAM_BASE ||
    mem_size > ((uint64_t)-1) - mem_base) {
    panic("invalid physical memory information");
}

uint64_t mem_end = mem_base + mem_size;
if (mem_end > PHYSICAL_MEMORY_END) {
    mem_end = PHYSICAL_MEMORY_END;
}
```

这里不能直接把设备树读到的大小当成全部可用内存。程序先排除零大小、当前内核布局不支持的内存起点和加法溢出，再根据本实验的可管理上界限制 `mem_end`。`mem_base == DRAM_BASE` 是这一版代码针对当前 QEMU 内存布局采用的限制，并不是所有硬件设备都必须满足的通用条件。

**（2）设置页面范围与描述符数组**

```c
va_pa_offset = PHYSICAL_MEMORY_OFFSET;
npage = PPN(mem_end);
pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
size_t page_count = npage - nbase;
```

`va_pa_offset` 用于完成内核虚拟地址和物理地址的转换；`npage` 在这个框架中是物理页号上界，`pages` 是描述符数组的虚拟地址。需要特别注意：`Page` 并不是一页实际数据，它保存的是该物理页的引用计数、状态标志和空闲块信息。`page_count` 才是这份描述符数组要覆盖的页数。

**（3）计算空闲页范围**

```c
uintptr_t metadata_start = PADDR(pages);
uintptr_t metadata_size = page_count * sizeof(struct Page);
uintptr_t free_start = ROUNDUP(metadata_start + metadata_size, PGSIZE);
uintptr_t free_end = ROUNDDOWN(mem_end, PGSIZE);
```

描述符数组也需要占内存，因此不能把 `end` 后面的空间直接视为全部空闲页。必须先跳过 `Page` 数组，再做页对齐。实际代码还检查了描述符空间不足和没有完整空闲页的情况，对不符合要求的情形执行 `panic()`。

**（4）初始化保留页并注册空闲页**

```c
for (size_t i = 0; i < page_count; i++) {
    pages[i].flags = 0;
    pages[i].property = 0;
    set_page_ref(&pages[i], 0);
    SetPageReserved(&pages[i]);
}

size_t free_count = (free_end - free_start) / PGSIZE;
init_memmap(pa2page(free_start), free_count);
```

先把所有描述符标记为保留，确保不能误分配给其他代码；然后由当前管理器的 `init_memmap()` 将真正可用的区域改成空闲状态，并放入其管理结构。当前采用的是 `default_pmm_manager`，也就是 First-Fit 实现。

> 说明：以上摘录的是本次实际编写逻辑中的关键语句，不是全部函数。完整实现以 GitHub `lab2` 分支中的 `kern/mm/pmm.c` 为准；正式提交前应将标记中的 `YOUR CODE` 按指导书要求替换为组员 A 的学号，并保留 `lab2` 注释。

### 4.3 Challenge：硬件的可用物理内存范围获取方法

如果操作系统无法预先知道硬件的可用物理内存范围，可以在启动阶段通过固件或硬件提供的描述信息获取。RISC-V uCore 当前使用设备树接口读取内存节点中的起始地址和长度；在其他平台上，也可以使用 BIOS/UEFI 提供的内存映射、固件接口或 ACPI 的内存表。操作系统拿到这些区域后，还要扣除固件、内核、页表、设备映射和页描述符数组占用的范围，并按页对齐后交给物理内存管理器。这样做比假定固定地址范围更适合不同硬件配置，也能避免把保留区域误当作可分配内存。

### 4.4 功能模块二：First-Fit 连续物理内存分配算法

**任务一：理解 First-Fit 连续物理内存分配算法。**

#### 整体数据结构

`default_pmm.c` 使用 `free_area_t free_area` 保存空闲链表 `free_list` 与空闲页计数 `nr_free`。`Page` 结构中的 `property` 保存连续空闲块的页数，`PG_property` 标志表明该 `Page` 是空闲块头部。

空闲链表中的每个节点只对应一个连续空闲块的首页。比如一个块包含 8 个页面，只有第一个 `Page` 挂入 `free_list`，并令其 `property = 8`；其余页面不作为独立节点。这样既能表示连续范围，也能让分裂和合并只修改块头及链表关系。

#### 核心函数理解

- **`default_init()`（第 11～15 行）**：初始化链表头并把空闲页数量清零。
- **`default_init_memmap()`（第 17～43 行）**：清除待管理页的保留状态、设置首个页的 `property=n`，按物理页地址顺序插入空闲链表。
- **`default_alloc_pages()`（第 45～73 行）**：从链表头开始寻找第一个 `property >= n` 的空闲块。若块比所需大，则将剩余部分分裂成新空闲块；分配完成后减少 `nr_free`。
- **`default_free_pages()`（第 75～123 行）**：释放连续页面，按地址顺序插入链表，并分别检查前后相邻块是否能够合并。
- **`default_nr_free_pages()`（第 125～128 行）**：返回空闲物理页数量。
- **`basic_check()`、`default_check()`（第 130～244 行）**：测试分配、回收、连续块分裂与合并及页数一致性。按指导书要求不修改它们。

初始化时，`default_init_memmap()` 先清除每个页面的保留状态和旧属性，再把整个区域登记为一个块：

```c
for (p = base; p != base + n; p ++) {
    assert(PageReserved(p));
    p->flags = p->property = 0;
    set_page_ref(p, 0);
}
base->property = n;
SetPageProperty(base);
nr_free += n;
```

随后按页面地址顺序把 `base` 插入 `free_list`。因此初始化完成后，链表描述的是所有可分配的连续区间，而 `nr_free` 是这些区间长度之和。

分配时，First-Fit 从链表头向后遍历，遇到第一个满足 `p->property >= n` 的块就停止：

```c
while ((le = list_next(le)) != &free_list) {
    struct Page *p = le2page(le, page_link);
    if (p->property >= n) {
        page = p;
        break;
    }
}
if (page != NULL) {
    list_entry_t *prev = list_prev(&page->page_link);
    list_del(&page->page_link);
    if (page->property > n) {
        struct Page *rest = page + n;
        rest->property = page->property - n;
        SetPageProperty(rest);
        list_add(prev, &rest->page_link);
    }
    nr_free -= n;
    ClearPageProperty(page);
}
```

这里的关键是“取走块头、必要时从块尾分裂剩余区间”。分配返回的 `page` 不再带有 `PG_property`，而剩余块的新首页面获得该标志。

释放时，`default_free_pages()` 先把待释放区间按地址插入链表，再检查前后节点：若前块末尾正好等于当前块起始地址，就把当前块长度加到前块；随后若当前块末尾正好等于后块起始地址，也进行合并。合并过程中只保留最终块首页的 `property` 和 `PG_property`，并删除被吸收块的链表节点。

#### 思考题：First-Fit 有没有改进空间？

我认为有。First-Fit 比较容易实现，遍历链表时找到第一个满足大小的空闲块就分配；但空闲块多了以后查找可能变慢，反复分配与释放也可能造成外部碎片。原实现已经通过合并前后相邻空闲块减少碎片，但不能保证完全消除。可以考虑 Best-Fit 或 Buddy System 等方案：Best-Fit 选择更接近请求大小的块，但可能留下难以利用的小块；Buddy System 更方便按固定阶数分裂和合并，但也可能带来内部碎片，不能说一定全面优于 First-Fit。

### 4.5 功能模块二：Best-Fit 连续物理内存分配算法

**任务二：实现 Best-Fit 连续物理内存分配算法。**

**负责人：** 2411112-徐子恩

#### 任务要求与设计思路

本任务在现有 uCore 物理内存管理框架上实现 Best-Fit 连续物理页分配器，并将其注册为内核实际使用的 `pmm_manager`。任务一要求阅读 `kern/mm/default_pmm.c`，理解 First-Fit 的初始化、分配、释放和相邻空闲块合并过程；前面的章节已保留相关原理及 First-Fit 分析，本节重点说明 Best-Fit 的实现。

Best-Fit 与 First-Fit 使用相同的页描述符和管理接口，但选择空闲块的规则不同。First-Fit 从空闲链表头开始，遇到第一个容量不少于申请页数的空闲块就停止；Best-Fit 则检查所有空闲块，并从满足 `property >= n` 的候选块中选择 `property` 最小者。这样可以优先使用最接近申请大小的空闲块，减少大块空间被小请求占用的情况，但不保证在所有工作负载下都能减少碎片。

实现沿用框架中 `struct pmm_manager` 的接口，并在 `kern/mm/best_fit_pmm.c` 中维护空闲链表和空闲页计数。空闲块头部的 `Page.property` 记录该连续块包含的页数，`PG_property` 标志用于识别空闲块头部；块内其余页面不单独登记为链表节点。该设计与原有 First-Fit 框架一致，能够复用现有的 `alloc_pages()`、`free_pages()` 等上层调用。

#### 核心函数与代码

涉及的核心函数和对象为：

```c
static void best_fit_init(void);
static void best_fit_init_memmap(struct Page *base, size_t n);
static struct Page *best_fit_alloc_pages(size_t n);
static void best_fit_free_pages(struct Page *base, size_t n);
static size_t best_fit_nr_free_pages(void);
const struct pmm_manager best_fit_pmm_manager;
```

Best-Fit 模块实现了以下管理函数，并通过 `best_fit_pmm_manager` 对外注册：

| 函数/对象 | 作用 |
|---|---|
| `best_fit_init()` | 初始化空闲链表和空闲页计数。 |
| `best_fit_init_memmap()` | 将传入的连续页面初始化为一个空闲块，并登记块大小。 |
| `best_fit_alloc_pages(size_t n)` | 搜索所有空闲块，选择满足申请大小且最小的块；必要时拆分剩余空间。 |
| `best_fit_free_pages(struct Page *base, size_t n)` | 回收连续页面，将其重新加入空闲链表，并合并地址相邻的空闲块。 |
| `best_fit_nr_free_pages()` | 返回当前空闲页总数。 |
| `best_fit_pmm_manager` | 将上述函数与框架的 `pmm_manager` 接口连接起来。 |

分配过程的核心是遍历所有候选块并记录最小满足块，其逻辑可概括为：

```c
best = NULL;
for (each free block p) {
    if (p->property >= n &&
        (best == NULL || p->property < best->property)) {
        best = p;
    }
}
```

实际代码中，管理器先处理申请大于总空闲页数的情况，再遍历链表；找到 `best` 后先保存其前驱节点并删除原块，若需要分裂，则把 `best + n` 作为剩余块重新插回原位置附近：

```c
if (n > nr_free) {
    return NULL;
}
struct Page *best = NULL;
list_entry_t *le = &free_list;
while ((le = list_next(le)) != &free_list) {
    struct Page *page = le2page(le, page_link);
    if (page->property >= n &&
        (best == NULL || page->property < best->property)) {
        best = page;
    }
}
if (best == NULL) {
    return NULL;
}
list_entry_t *prev = list_prev(&best->page_link);
list_del(&best->page_link);
if (best->property > n) {
    struct Page *remainder = best + n;
    remainder->property = best->property - n;
    SetPageProperty(remainder);
    list_add(prev, &remainder->page_link);
}
nr_free -= n;
ClearPageProperty(best);
return best;
```

以上为算法逻辑示意，实际实现以 `kern/mm/best_fit_pmm.c` 中的代码为准。找到候选块后，如果块大小恰好等于申请页数，则直接取走该块；如果块更大，则把剩余部分登记为新的空闲块。分配和释放都同步更新 `nr_free`，并维护 `Page.property`、`PG_property` 和链表节点状态，避免已分配页面仍被当作空闲块头部。

释放页面时，分配器把页面重新插入空闲链表，并检查前后相邻块的物理地址是否连续。若连续，就合并为一个更大的空闲块，同时把 `property` 设置在合并后块的首页面。合并只能发生在地址连续的空闲块之间，不能跨越中间的已分配页面。

释放前，代码会逐页清除旧状态并恢复引用计数；释放区间插入后，前向合并和后向合并分别使用指针加上块长度判断物理连续性：

```c
if (prev + prev->property == base) {
    prev->property += base->property;
    ClearPageProperty(base);
    list_del(&base->page_link);
    base = prev;
}
if (base + base->property == next) {
    base->property += next->property;
    ClearPageProperty(next);
    list_del(&next->page_link);
}
```

最后，`best_fit_pmm_manager` 将这些函数接入统一接口，`pmm.c` 中的 `init_pmm_manager()` 再把全局管理器指针切换到它：

```c
const struct pmm_manager best_fit_pmm_manager = {
    .name = "best_fit_pmm_manager",
    .init = best_fit_init,
    .init_memmap = best_fit_init_memmap,
    .alloc_pages = best_fit_alloc_pages,
    .free_pages = best_fit_free_pages,
    .nr_free_pages = best_fit_nr_free_pages,
    .check = best_fit_check,
};
```

除实现分配器本身外，还完成了两项接入工作：在 `kern/mm/pmm.c` 的 `init_pmm_manager()` 中将当前管理器切换为 `best_fit_pmm_manager`，使 `pmm_init()` 后续使用 Best-Fit；同时修改 `Makefile` 的源文件筛选规则，让 `kern/mm/best_fit_pmm.c` 参与内核编译。原有的 `basic_check()` 和 `best_fit_check()` 测试函数没有修改。

#### 思考题：Best-Fit 算法是否还有改进空间？

有。当前实现需要遍历空闲链表寻找最小满足块，若空闲块数量为 (F)，一次分配的搜索时间复杂度最坏为 (O(F))。对于本实验的内存规模，这种实现简单、容易检查，足以满足要求；但在空闲块很多的系统中，可以考虑按块大小建立有序树或分级空闲链表，以缩短查找时间。

此外，Best-Fit 并不能彻底消除外部碎片：多次分配可能留下许多很小、难以满足后续请求的空闲块。释放时合并物理地址相邻的空闲块有助于缓解这一问题。若同时需要快速按大小查找和快速按地址合并，可以维护按大小与按地址组织的辅助索引，但这会增加数据结构维护成本。因此，算法改进需要在搜索速度、碎片情况和实现复杂度之间权衡。

### 4.6 任务三：Buddy System 伙伴分配算法（选做，未实现）

> **此节由 C 完成，暂不填入未经实际执行的结果。**

Buddy System 将空闲块按 (2^n) 页组织为不同阶的空闲链表。分配时向上取能够容纳请求的最小阶，并在必要时逐级拆分；释放时根据伙伴地址和阶数检查能否合并，再逐级向上合并。该算法能够较快地定位固定阶数的块，并且合并规则明确，但可能产生内部碎片。本组当前没有在工程中实现 Buddy System，也没有生成对应的测试，因此本部分不填写虚构的代码、运行结果或测试截图。

### 4.7 扩展 Challenge：任意大小的内存单元 SLUB 分配算法（选做，未实现）

SLUB 可以在页级分配器之上增加对象缓存层：第一层从物理页管理器申请页，第二层把页切分为固定大小的对象，并维护部分使用、全部使用和空闲 slab。释放对象时将其放回对应缓存，空 slab 可以归还页级分配器。本组当前没有实现该扩展，因此不虚构模块代码、测试结果或截图。

### 4.8 GDB 调试页表查询过程

指导书将该部分作为单独的分支任务，涉及调试运行中的 uCore 内核和带调试信息的 QEMU。计划先使用内核 GDB 观察启动页表和 `satp`，再依据手册准备可以用主机 GDB 查看源代码的 QEMU，追踪模拟器的页表查询过程。

**当前尚未实际完成双 GDB 调试，因此本节不提供虚构的断点截图或调试结果。** 后续将补充：使用的命令、断点位置、`satp` 和页表项观察结果、地址转换解释及截图。


## 五、测试与验证

`page_init()` 的验证结果显示，设备树发现的物理内存范围为 128 MB，起始物理地址为 `0x80000000`，结束地址为 `0x87ffffff`；排除内核和 `Page` 描述符数组后，空闲区从 `0x80347000` 开始，共有 `31929` 页。该初始化结果说明页描述符布局、物理地址转换和初始空闲区登记符合预期。

本次验证包括内核启动检查和自动评分检查。运行截图中的实际输出表明，内核使用的是 `best_fit_pmm_manager`，设备树发现的物理内存范围为 `0x80000000` 至 `0x87ffffff`，容量为 128 MB；可用内存从 `0x80347000` 开始，共有 `31929` 个空闲页，并成功输出 `check_alloc_page() succeeded!`。

`basic_check()` 覆盖了连续申请多个页面、申请结果非空且互不相同、资源不足时返回 `NULL`、释放页面后空闲页计数恢复等行为。`best_fit_check()` 进一步构造了 2 页空闲块和 1 页空闲块，申请 1 页并检查返回地址，从而区分 Best-Fit 与 First-Fit；同时检查多页申请、连续页面释放、空闲块合并，以及链表中空闲块页数总和与 `nr_free_pages()` 的一致性。

自动评分脚本最终显示 `check page init: OK`、`check best fit: OK` 和 `Total Score: 20/20`。这些结果证明当前代码通过了已有的页初始化和 Best-Fit 接入检查，但不覆盖长期随机分配、极端内存压力和所有非法释放场景。

![Best-Fit 内核运行结果](assets/best_fit_runtime.png)

![Best-Fit 自动评分结果](assets/best_fit_grade.png)

## 六、实验总结与收获

### 对操作系统的理解

#### 本实验中的重要知识点

1. **物理页描述符与空闲块**：`Page` 保存引用计数、状态标志和连续空闲块大小；它对应 OS 原理中的物理内存页框管理。
2. **连续物理内存分配**：`alloc_pages(n)` 必须返回连续的 `n` 个物理页，对应内核中需要连续物理空间的场景。
3. **空闲链表与块分裂**：分配大空闲块的一部分时，把剩余部分重新登记为空闲块；这体现了动态分区分配中的分裂操作。
4. **相邻空闲块合并**：释放时合并地址连续的块，减少外部碎片；这对应 OS 原理中的空闲区合并。
5. **First-Fit 与 Best-Fit**：两者都在空闲区中寻找满足请求的块，区别在于 First-Fit 取第一个，Best-Fit 取最小满足块。Best-Fit 可能减少大块浪费，但搜索成本更高，也不能消除外部碎片。
6. **分配器接口抽象**：`pmm_manager` 将初始化、分配、释放、统计和检查统一成函数指针接口，使不同分配策略可以替换。

#### OS 原理中重要但本实验未直接对应的知识点

本实验主要处理内核启动后的连续物理页管理，没有覆盖虚拟内存换页、页面置换算法、TLB 管理、写时复制、内存映射文件、伙伴系统的完整实现以及用户进程地址空间隔离等内容。这些知识点同样重要，但不属于本次 Best-Fit 练习的直接实现范围。
