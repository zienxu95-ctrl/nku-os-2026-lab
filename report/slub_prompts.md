# Lab2 Challenge：SLUB 提示词

## Prompt 1：从零生成 SLUB 并接入内核

请在没有现成 SLUB 框架的情况下，为当前 ucore 内核实现一个简化的两层 SLUB 分配器。

背景：
- 第一层已经存在：`alloc_pages` / `free_pages`（当前默认是 Best-Fit）。
- 第二层需要把从第一层拿到的物理页切成固定大小的对象，再按对象分配。
- 物理页可通过 `page2pa(page) + va_pa_offset` 转成内核虚拟地址。启动时已用 Sv39 把 `0x80000000` 映射到 `0xFFFFFFFFC0000000`。
- 不要改 Best-Fit / Buddy 的已有逻辑，也不要改评分注入用的测试。

实现要求：
1. 新增 `kern/mm/slub.h`、`kern/mm/slub.c`。
2. 对象大小分档：16、32、64、128、256、512、1024、2048 字节。大于 2048 或 size 为 0 时返回 NULL。
3. 每个 slab 占用一页。页开头放 slab 元数据，其余空间切成该档对象。空闲对象用对象自身前 8 字节串成 freelist。
4. `slub_alloc(size)`：向上靠档；当前档没有空闲对象时 `alloc_page()` 新建 slab。
5. `slub_free(obj)`：按页对齐找回 slab，把对象挂回 freelist；若该页 `inuse==0`，把页 `free_page` 还给第一层。
6. 在 `pmm_init()` 里，Buddy 自检之后调用 `slub_selftest()`。
7. 能通过 `-Werror` 编译。可简化，但必须能看出“页分配 + 页内对象分配”两层结构。

## Prompt 2：为上面的 SLUB 生成测试

请为该简化 SLUB 编写 `slub_selftest()`，内核启动时应打印：

`[Test 4] SLUB: PASS`

测试至少覆盖：
1. 不同大小：申请 24 字节（进 32 档）和 100 字节（进 128 档），指针非空且互不相同，可写入并读回。
2. 复用：释放后再申请同类小对象，应拿到刚释放的地址。
3. 还页：释放全部对象后，`nr_free_pages()` 回到测试前，说明空 slab 还给了第一层。
4. 跨页：连续申请 80 个 64 字节对象（超过一页容量），地址互不重叠，空闲页数应减少；全部释放后再回到原值。
5. 边界：`slub_alloc(0)` 和 `slub_alloc(4096)` 返回 NULL。

这些测试能检验：分档、对象不重叠、freelist 复用、空页归还、以及需要时向第一层再要页。若只在页分配器上直接 `alloc_page` 而不切对象，跨页计数和复用断言会对不上。
