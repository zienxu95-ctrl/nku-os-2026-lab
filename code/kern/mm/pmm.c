#include <default_pmm.h>
#include <best_fit_pmm.h>
#include <buddy_pmm.h>
#include <slub.h>
#include <defs.h>
#include <error.h>
#include <memlayout.h>
#include <mmu.h>
#include <pmm.h>
#include <sbi.h>
#include <stdio.h>
#include <string.h>
#include <riscv.h>
#include <dtb.h>

// virtual address of physical page array
struct Page *pages;
// amount of physical memory (in pages)
size_t npage = 0;
// the kernel image is mapped at VA=KERNBASE and PA=info.base
uint64_t va_pa_offset;
// memory starts at 0x80000000 in RISC-V
// DRAM_BASE defined in riscv.h as 0x80000000
const size_t nbase = DRAM_BASE / PGSIZE;

// virtual address of boot-time page directory
uintptr_t *satp_virtual = NULL;
// physical address of boot-time page directory
uintptr_t satp_physical;

// physical memory management
const struct pmm_manager *pmm_manager;


static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &best_fit_pmm_manager;
    cprintf("memory management: %s\n", pmm_manager->name);
    pmm_manager->init();
}

// init_memmap - call pmm->init_memmap to build Page struct for free memory
static void init_memmap(struct Page *base, size_t n) {
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
// of current free memory
size_t nr_free_pages(void) {
    return pmm_manager->nr_free_pages();
}

//lab2 function1 YOUR CODE
static void page_init(void) {
    extern char end[];

    // 获取设备树中的物理内存信息
    uint64_t mem_base = get_memory_base();
    uint64_t mem_size = get_memory_size();

    if (mem_size == 0 || mem_base != DRAM_BASE ||
        mem_size > ((uint64_t)-1) - mem_base) {
        panic("invalid physical memory information");
    }

    // 确定内核能够管理的物理内存范围
    uint64_t mem_end = mem_base + mem_size;
    if (mem_end > PHYSICAL_MEMORY_END) {
        mem_end = PHYSICAL_MEMORY_END;
    }

    if (mem_end <= KERNEL_BEGIN_PADDR) {
        panic("no usable physical memory");
    }

    // 设置虚拟地址与物理地址的偏移
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;

    // 计算物理页数量
    npage = PPN(mem_end);

    // 在内核结束位置之后放置 Page 描述符数组
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);

    size_t page_count = npage - nbase;

    // 计算描述符数组结束后的第一个空闲物理页
    uintptr_t metadata_start = PADDR(pages);
    uintptr_t metadata_size = page_count * sizeof(struct Page);

    if (metadata_start >= mem_end ||
        metadata_size > mem_end - metadata_start) {
        panic("not enough memory for page descriptors");
    }

    uintptr_t free_start =
        ROUNDUP(metadata_start + metadata_size, PGSIZE);
    uintptr_t free_end = ROUNDDOWN(mem_end, PGSIZE);

    if (free_start >= free_end) {
        panic("no complete free pages");
    }

    // 初始化所有页面描述符，默认全部标记为保留
    for (size_t i = 0; i < page_count; i++) {
        pages[i].flags = 0;
        pages[i].property = 0;
        set_page_ref(&pages[i], 0);
        SetPageReserved(&pages[i]);
    }

    // 将真正空闲的物理页交给内存管理器
    size_t free_count = (free_end - free_start) / PGSIZE;
    init_memmap(pa2page(free_start), free_count);

    cprintf("physical memory map:\n");
    cprintf("  memory: [0x%016lx, 0x%016lx]\n",
            mem_base, mem_end - 1);
    cprintf("  free:   [0x%016lx, 0x%016lx]\n",
            free_start, free_end - 1);
    cprintf("  free pages: %lu\n", free_count);
}


/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
    // We need to alloc/free the physical memory (granularity is 4KB or other size).
    // So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    // First we should init a physical memory manager(pmm) based on the framework.
    // Then pmm can alloc/free the physical memory.
    // Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();

    // use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
    buddy_selftest();
    slub_selftest();

    extern char boot_page_table_sv39[];
    satp_virtual = (pte_t*)boot_page_table_sv39;
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}
