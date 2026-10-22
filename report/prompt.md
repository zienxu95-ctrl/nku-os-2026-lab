# Lab2 提示词

本文件对应练习中的全部编程任务，共 6 份提示词：


| 编号     | 练习位置                | 提示词作用              |
| ------ | ------------------- | ------------------ |
| 任务 1   | 功能模块一 · 任务一         | 实现 `page_init()`   |
| 任务 2   | 功能模块二 · 任务二         | 实现 Best-Fit 并切换管理器 |
| 任务 3-A | 功能模块二 · 任务三         | 从零生成 Buddy 模块      |
| 任务 3-B | 功能模块二 · 任务三         | 为 Buddy 生成测试       |
| 任务 4-A | 扩展 Challenge · SLUB | 从零生成 SLUB 模块       |
| 任务 4-B | 扩展 Challenge · SLUB | 为 SLUB 生成测试        |




---

# 任务 1　功能模块一：实现 `page_init()`

[PROMPT]
**任务**：修改文件 `kern/mm/pmm.c`，实现 `page_init`。

**输出要求**：请直接修改目标实现文件，而不是只展示代码。只在标记位置补全，不要重写整个文件，不要删除已有逻辑。

**输入要求**：直接阅读文件，不要转述文件中的所有代码。实现或修改的代码应出现在下列相应的位置。请使用下面 `[RELY]`、`[GUARANTEE]`、`[SPECIFICATION]` 提供的信息，以工程中的实现为准，不要引入无关功能。

[RELY]

```c
#define PGSIZE 4096
#define PGSHIFT 12
#define PPN(la) (((uintptr_t)(la)) >> PGSHIFT)
#define DRAM_BASE 0x80000000
#define PHYSICAL_MEMORY_END 0x88000000
#define PHYSICAL_MEMORY_OFFSET 0xFFFFFFFF40000000
#define KERNEL_BEGIN_PADDR 0x80200000
#define ROUNDUP(a, n) ...
#define ROUNDDOWN(a, n) ...
#define PADDR(kva) ((kva) - va_pa_offset)   /* kva 必须 >= KERNBASE */

extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;          /* DRAM_BASE / PGSIZE */
extern uint64_t va_pa_offset;
extern char end[];

struct Page { int ref; uint64_t flags; unsigned int property; list_entry_t page_link; };

uint64_t get_memory_base(void);
uint64_t get_memory_size(void);
void panic(const char *fmt, ...);
void cprintf(const char *fmt, ...);
static void init_memmap(struct Page *base, size_t n);
struct Page *pa2page(uintptr_t pa);
void set_page_ref(struct Page *page, int val);
void SetPageReserved(struct Page *page);
```

[GUARANTEE]
需要实现的接口：

```c
static void page_init(void);
```

- 该函数保持 `static`，由 `pmm_init()` 调用。
- 不要修改 `pmm_init()`、`init_memmap()`、`alloc_pages()` 的函数签名。
- 不要修改 `YOUR CODE` 以外的已有函数。

[SPECIFICATION]

## page_init

**Pre-Condition**:

- `dtb_init()` 已执行，可通过 `get_memory_base()` / `get_memory_size()` 读取设备树内存信息。
- 内核镜像已加载，链接符号 `end` 指向内核映像结束后的第一个地址。
- `pages`、`npage`、`va_pa_offset` 尚未按本函数要求完成设置。

**Post-Condition**:

- 成功返回时已设置 `va_pa_offset = PHYSICAL_MEMORY_OFFSET`。
- `npage` 等于可管理物理内存上界的页号 `PPN(mem_end)`。
- `pages` 指向 `end` 向上页对齐后的 `Page` 数组，且该数组覆盖 `[nbase, npage)` 的物理页。
- OpenSBI、内核镜像和 `Page` 数组占用的页保持保留，不得进入空闲区。
- 若存在完整空闲页，则已调用 `init_memmap(pa2page(free_start), free_count)`。
- 已用 `cprintf` 输出探测到的物理内存范围。
  **Case 1**（设备树信息合法，且扣除保留区后仍有完整空闲页）:
  - 读取 `mem_base`、`mem_size`，`mem_end = min(mem_base + mem_size, PHYSICAL_MEMORY_END)`。
  - 在 `end` 之后按页对齐放置 `pages`。
  - 先将全部描述符标为保留，再把 `[free_start, free_end)` 交给当前 `pmm_manager`。
  **Case 2**（`mem_size == 0`，或 `mem_base != DRAM_BASE`，或加法溢出）:
  - 调用 `panic`，不得继续初始化。
  **Case 3**（没有完整空闲页，或描述符数组自身放不下）:
  - 调用 `panic`，不得调用 `init_memmap()`。

**Requirements**:

- 区分虚拟地址、物理地址、物理页号和 `Page` 描述符地址。
- `free_start` 向上页对齐，`free_end` 向下页对齐。
- 代码写在 `pmm.c` 中 `//lab2 function1 YOUR CODE` 标记处。

---

# 任务 2　功能模块二：实现 Best-Fit 分配模块

[PROMPT]
**任务**：修改文件 `kern/mm/best_fit_pmm.c`，实现完整 Best-Fit 物理内存管理模块；并修改 `kern/mm/pmm.c` 中的 `init_pmm_manager()`，将当前管理器切换为 `best_fit_pmm_manager`。

**输出要求**：请直接修改目标实现文件，而不是只展示代码。只在标记位置补全，不要重写整个文件。不得修改 `basic_check()` 和 `best_fit_check()`。

**输入要求**：直接阅读 `best_fit_pmm.c`、`pmm.h`、`default_pmm.c`，不要转述全部代码。请使用下面 `[RELY]`、`[GUARANTEE]`、`[SPECIFICATION]` 提供的信息。

[RELY]

```c
struct pmm_manager {
    const char *name;
    void (*init)(void);
    void (*init_memmap)(struct Page *base, size_t n);
    struct Page *(*alloc_pages)(size_t n);
    void (*free_pages)(struct Page *base, size_t n);
    size_t (*nr_free_pages)(void);
    void (*check)(void);
};

typedef struct {
    list_entry_t free_list;
    unsigned int nr_free;
} free_area_t;

/* Page.property：空闲块首页保存该连续空闲块的页数 */
/* PG_property：该 Page 是空闲块头部 */

struct Page *alloc_pages(size_t n);   /* 转调 pmm_manager->alloc_pages */
void free_pages(struct Page *base, size_t n);
size_t nr_free_pages(void);
#define alloc_page() alloc_pages(1)
#define free_page(page) free_pages(page, 1)
#define le2page(le, member) to_struct((le), struct Page, member)
```

参考实现：`kern/mm/default_pmm.c` 中的 First-Fit。测试函数 `basic_check()`、`best_fit_check()` 已存在，约定空闲链表按地址有序、`property` 表示块大小、释放后合并相邻空闲块。

[GUARANTEE]
需要实现并注册：

```c
static void best_fit_init(void);
static void best_fit_init_memmap(struct Page *base, size_t n);
static struct Page *best_fit_alloc_pages(size_t n);
static void best_fit_free_pages(struct Page *base, size_t n);
static size_t best_fit_nr_free_pages(void);
const struct pmm_manager best_fit_pmm_manager;
```

需要修改：

```c
static void init_pmm_manager(void);   /* pmm.c：pmm_manager = &best_fit_pmm_manager */
```

- 管理函数可为 `static`。
- 不得修改 `basic_check`、`best_fit_check` 的函数体和签名。
- 内部使用 `free_area_t` 保存空闲链表和 `nr_free`。

[SPECIFICATION]

## best_fit_init

**Pre-Condition**: 模块尚未初始化。
**Post-Condition**: `free_list` 为空，`nr_free = 0`。

## best_fit_init_memmap

**Pre-Condition**: `base` 起连续 `n > 0` 页当前为保留页。
**Post-Condition**: 这 `n` 页成为一个空闲块，首页 `property = n` 且 `PageProperty` 置位，按地址插入空闲链表，`nr_free += n`。

## best_fit_alloc_pages

**Pre-Condition**: 空闲链表描述当前全部空闲块。
**Post-Condition**:
  **Case 1**（存在 `property >= n` 的块）: 在所有满足块中选 `property` 最小者；取走前 `n` 页；若有剩余则把剩余块插回原位置附近；`nr_free -= n`；返回首页，且该页不再是空闲块头。
  **Case 2**（`n > nr_free` 或找不到满足块）: 返回 `NULL`，不改动空闲链表。

## best_fit_free_pages

**Pre-Condition**: `[base, base+n)` 是已分配页，不是保留页，也不是空闲块头。
**Post-Condition**: 这 `n` 页重新成为空闲块并按地址插入链表；若与前块或后块物理地址连续，则合并；`nr_free += n`。

## init_pmm_manager

**Pre-Condition**: `pmm_init()` 即将初始化物理内存管理器。
**Post-Condition**: `pmm_manager` 指向 `best_fit_pmm_manager`，并已调用其 `init()`。

**Requirements**:

- 分配策略必须是 Best-Fit，不能写成 First-Fit（找到第一个满足块就停）。
- 实现须能通过未修改的 `basic_check()` 与 `best_fit_check()`。

---

# 任务 3-A　Buddy System：从零生成分配模块

[PROMPT]
**任务**：新增文件 `kern/mm/buddy_pmm.h`、`kern/mm/buddy_pmm.c`，从零实现 Buddy System 物理页分配器；在 `kern/mm/pmm.c` 的 `pmm_init()` 中于 Best-Fit 检查之后调用自检入口，但不要把默认 `pmm_manager` 改成 Buddy。

**输出要求**：请直接创建并修改目标实现文件。不要重写 First-Fit / Best-Fit，不要修改 `basic_check` / `best_fit_check`。

**输入要求**：直接阅读现有 `pmm_manager` 框架和 `default_pmm.c`。请使用下面各节信息，以工程为准。

[RELY]

```c
struct pmm_manager { /* 同任务二 */ };
struct Page { ... property, page_link, flags ... };
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;

#define PGSIZE 4096
#define le2page(le, member) to_struct((le), struct Page, member)
struct Page *alloc_pages(size_t n);  /* 当前默认仍是 Best-Fit */
void free_pages(struct Page *base, size_t n);
```

伙伴下标：`buddy_idx = (page - pages) XOR (1 << order)`。空闲块大小只能是 `2^order` 页。

[GUARANTEE]
需要实现：

```c
static void buddy_init(void);
static void buddy_init_memmap(struct Page *base, size_t n);
static struct Page *buddy_alloc_pages(size_t n);
static void buddy_free_pages(struct Page *base, size_t n);
static size_t buddy_nr_free_pages(void);
static void buddy_check(void);
const struct pmm_manager buddy_pmm_manager;
void buddy_selftest(void);
```

- 默认管理器保持 `best_fit_pmm_manager`。
- `buddy_selftest()`：从 Best-Fit 暂借一段连续页作为沙箱，切换到 Buddy 运行 `check`，再归还。
- 各阶空闲链表、`MAX_ORDER` 等为模块内部静态状态。

[SPECIFICATION]

## buddy_init

**Pre-Condition**: 无。
**Post-Condition**: 各阶空闲链表为空，`nr_free = 0`。

## buddy_init_memmap

**Pre-Condition**: `[base, base+n)` 为保留页。
**Post-Condition**: 将该区间拆成地址对齐的 2 的幂块，挂入对应阶空闲链表；`nr_free += n`。

## buddy_alloc_pages

**Pre-Condition**: `n > 0`。
**Post-Condition**:
  **Case 1**: 将 `n` 向上取到 `2^k`；从阶 `k` 或更高阶取块，必要时拆成两个伙伴；`nr_free` 减少 `2^k`；返回对齐到 `2^k` 的首页。
  **Case 2**: 空闲不足则返回 `NULL`。

## buddy_free_pages

**Pre-Condition**: `[base, base+2^k)` 为先前按 `n` 申请得到的块，其中 `2^k >= n`。
**Post-Condition**: 按同样规则把 `n` 升成 `2^k` 后释放；仅当伙伴同阶、空闲且落在本模块管理区内才合并；`nr_free` 增加 `2^k`。

**Requirements**:

- `alloc_pages(3)` 实际占用 4 页；`free_pages(p, 3)` 也必须释放这 4 页。
- 不能把任意地址相邻块当成伙伴。
- 不得破坏 Best-Fit 评分路径。

---

# 任务 3-B　Buddy System：生成测试函数

[PROMPT]
**任务**：修改文件 `kern/mm/buddy_pmm.c`，为上一份提示词生成的 Buddy 分配器实现 `buddy_check()` / `buddy_selftest()`。

**输出要求**：请直接修改目标实现文件。不要改 Best-Fit 测试函数。测试失败应 `assert`/`panic`，成功打印 `[Test 3] Buddy System: PASS`。

**输入要求**：直接阅读 Buddy 模块已有实现。请使用下面各节信息。

[RELY]
Buddy 模块已提供 `buddy_pmm_manager` 的 `alloc_pages` / `free_pages` / `nr_free_pages`。`alloc_pages(n)` 会向上取整到 2 的幂。`page - pages` 为页下标，用于检查对齐。`buddy_selftest()` 已能提供不少于 32 页的沙箱。

[GUARANTEE]
需要实现或补全：

```c
static void buddy_check(void);
void buddy_selftest(void);
```

不要修改 `struct pmm_manager` 的对外签名。

[SPECIFICATION]

## buddy_check

**Pre-Condition**: 当前 `pmm_manager` 已是 Buddy，且沙箱内至少有 32 个空闲页。
**Post-Condition**: 下列检查全部通过后打印 `[Test 3] Buddy System: PASS`，空闲页数回到测试前。

  **Case 1**（基本分配）: 申请 1、1、3 页，三者非空且互异；3 页块 4 页对齐；`nr_free` 减少 1+1+4。
  **Case 2**（释放还原）: 全部释放后 `nr_free` 恢复。
  **Case 3**（拆分与合并）: 申请两个 2 页块，二者互为伙伴（相邻且 2 对齐）；释放后再申请 4 页，应拿回合并后的原块。
  **Case 4**（边界）: 申请 `nr_free+1` 返回 `NULL`；申请 16 页时起始下标 16 对齐。

**Requirements**:

- 用断言检查各阶链表块大小之和与 `nr_free` 一致。
- 测试必须能区分“只实现了任意相邻合并”和“只与伙伴合并”。

---

# 任务 4-A　Challenge：从零生成 SLUB 模块

[PROMPT]
**任务**：新增文件 `kern/mm/slub.h`、`kern/mm/slub.c`，从零实现简化两层 SLUB，并在 `pmm_init()` 中于 Buddy 自检之后调用 `slub_selftest()`。

**输出要求**：请直接创建并修改目标实现文件。不要改 Best-Fit / Buddy 的已有逻辑，不要改评分注入测试。

**输入要求**：直接阅读 `alloc_page` / `free_page` 以及 `page2pa`。物理页内核虚址为 `page2pa(page) + va_pa_offset`。

[RELY]

```c
#define PGSIZE 4096
#define alloc_page() alloc_pages(1)
#define free_page(page) free_pages(page, 1)
uintptr_t page2pa(struct Page *page);
extern uint64_t va_pa_offset;
#define ROUNDDOWN(a, n) ...
```

第一层使用现有页分配器。第二层对象分档：16、32、64、128、256、512、1024、2048 字节。

[GUARANTEE]
需要实现：

```c
void slub_init(void);
void *slub_alloc(size_t size);
void slub_free(void *obj);
void slub_selftest(void);
```

- 每个 slab 占用一页，页首为元数据，其余切成该档对象。
- 空闲对象用对象自身前 8 字节做 freelist。
- `inuse == 0` 时 `free_page` 还给第一层。

[SPECIFICATION]

## slub_alloc

**Pre-Condition**: `slub_init()` 已调用。
**Post-Condition**:
  **Case 1**（`size` 落在某档且有空闲对象）: 返回该档一个对象指针。
  **Case 2**（该档无空闲对象）: `alloc_page()` 新建 slab 后再分配。
  **Case 3**（`size == 0` 或 `size > 2048`，或没有物理页）: 返回 `NULL`。

## slub_free

**Pre-Condition**: `obj` 由 `slub_alloc` 返回。
**Post-Condition**: 对象回到所属 slab 的 freelist；若该页 `inuse` 降为 0，则从 cache 卸下并 `free_page`。

**Requirements**:

- `slub_alloc(24)` 进入 32 字节档。
- 不要替换默认 `pmm_manager`。

---

# 任务 4-B　Challenge：为 SLUB 生成测试

[PROMPT]
**任务**：修改文件 `kern/mm/slub.c`，实现 `slub_selftest()`，检验不同大小对象的分配和释放。

**输出要求**：请直接修改目标实现文件。成功打印 `[Test 4] SLUB: PASS`，失败则 `assert`。

**输入要求**：直接阅读 `slub_alloc` / `slub_free` 的分档与还页语义。

[RELY]
`slub_alloc(size)` 向上靠档。同一档释放后再申请应复用刚释放的对象（LIFO）。空 slab 会把页还给 `free_page`，因此全部释放后 `nr_free_pages()` 应回到测试前。一页约能放下 `(PGSIZE - header) / 64` 个 64 字节对象，连续申请 80 个 64 字节对象会跨页。

[GUARANTEE]
需要实现：

```c
void slub_selftest(void);
```

[SPECIFICATION]

## slub_selftest

**Pre-Condition**: Best-Fit 已初始化，`nr_free_pages() > 8`。
**Post-Condition**: 下列检查通过后打印 `[Test 4] SLUB: PASS`，空闲页数回到测试前。

  **Case 1**: `slub_alloc(24)` 与 `slub_alloc(100)` 非空且不同，可写入并读回。
  **Case 2**: 释放 24 字节对象后再 `slub_alloc(24)`，地址与刚释放的相同。不得改用 16 字节申请来测复用。
  **Case 3**: 连续申请 80 个 64 字节对象，地址互不重叠，`nr_free_pages()` 下降；全部释放后恢复。
  **Case 4**: `slub_alloc(0)` 与 `slub_alloc(4096)` 返回 `NULL`。

**Requirements**:

- 复用测试必须使用同一档大小。
- 测试应能发现“只 alloc_page 而不切对象”的错误实现。

