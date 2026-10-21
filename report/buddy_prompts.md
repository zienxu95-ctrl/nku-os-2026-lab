# Lab2 任务三：Buddy System 提示词

## Prompt 1：从零生成 Buddy 分配模块并接入内核

请参考当前 ucore 物理内存管理框架，从零实现 Buddy System 物理页分配器，并接入内核。不要修改 First-Fit / Best-Fit 已有实现，也不要改 `basic_check` / `best_fit_check`。

背景：
- 物理页分配接口定义在 `kern/mm/pmm.h` 的 `struct pmm_manager`。
- 现有实现可参考 `kern/mm/default_pmm.c` 和 `kern/mm/best_fit_pmm.c`。
- `page_init()` 已经把空闲物理页交给当前 `pmm_manager`。当前默认管理器仍是 Best-Fit，评分测试依赖它。
- 页描述符是 `struct Page`，可用 `property`、`page_link`、`PageProperty` 等宏。

实现要求：
1. 新增 `kern/mm/buddy_pmm.h` 和 `kern/mm/buddy_pmm.c`。
2. 空闲块大小必须是 2 的幂：1、2、4、8… 页。为每个阶维护一条空闲链表。
3. `init`：初始化各阶空闲链表。
4. `init_memmap(base, n)`：把一段连续空闲页拆成地址对齐的 2 的幂块并挂入对应阶。
5. `alloc_pages(n)`：分配不少于 n 页的最小 2 的幂块；没有刚好的块时拆更大的块。
6. `free_pages(base, n)`：按同样规则把 n 向上取整到 2 的幂后释放；仅当伙伴空闲时合并。伙伴用页下标异或计算：`idx ^ (1 << order)`。
7. 申请 3 页应实际占用 4 页；`free_pages(p, 3)` 也必须释放这 4 页。
8. `nr_free_pages` 返回当前空闲页数（按实际占用的 2 的幂块统计）。
9. 定义 `buddy_pmm_manager` 并实现 `check`。
10. 接入方式：保留 Best-Fit 作为默认 `pmm_manager`，在 `pmm_init()` 里 Best-Fit 自检通过后，从 Best-Fit 暂借一段连续页作为沙箱，切换到 Buddy 跑自检，再还回 Best-Fit。这样既验证 Buddy，又不破坏 Lab 评分。
11. 代码风格与现有 `kern/mm` 保持一致，能通过 `-Werror` 编译。

## Prompt 2：为上面的 Buddy 实现生成测试

请针对刚刚生成的 Buddy System 分配器编写测试，检验实现是否正确。测试放在 Buddy 模块的 `check` / `buddy_selftest` 中，启动内核时应打印：

`[Test 3] Buddy System: PASS`

测试至少覆盖：
1. 基本分配：连续申请 1 页、1 页、3 页（应升为 4 页），返回的页互不相同，且 4 页块按 4 页对齐。
2. 空闲计数：分配后 `nr_free_pages` 减少的是实际上占用的 2 的幂页数，而不是原始请求 n。
3. 释放还原：把上述块全部释放后，空闲页数回到测试前。
4. 拆分与合并：先释放一个 4 页块，再申请两个 2 页块，二者必须互为伙伴（地址相邻且 2 页对齐）；再释放后申请 4 页，应拿回合并后的原块。
5. 边界：申请超过当前空闲页数应返回 NULL。
6. 对齐：申请 16 页时，块起始页下标必须 16 对齐。
7. 完整性：各阶空闲链表上的块大小、块数应与 `nr_free` 一致。

说明为什么这些测试有效：它们分别打到 Buddy 的取整、拆大块、只与伙伴合并、对齐约束和溢出失败，而不是只测“能 alloc/free”。若合并条件写错、3 页只释放 3 页、或对齐错误，这些断言会失败。
