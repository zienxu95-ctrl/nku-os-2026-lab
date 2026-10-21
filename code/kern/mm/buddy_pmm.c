#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <buddy_pmm.h>

/* 2^14 pages = 64MB, enough for QEMU's physical memory window. */
#define MAX_ORDER 14

static free_area_t free_area[MAX_ORDER + 1];
static size_t nr_free = 0;
static struct Page *buddy_area_base;
static size_t buddy_area_npages;

static size_t
page_idx(struct Page *page) {
    return page - pages;
}

static size_t
order_of(size_t n) {
    size_t order = 0;
    size_t size = 1;
    while (size < n) {
        size <<= 1;
        order++;
        assert(order <= MAX_ORDER);
    }
    return order;
}

static void
add_block(struct Page *base, size_t order) {
    base->property = (1U << order);
    SetPageProperty(base);
    list_add(&(free_area[order].free_list), &(base->page_link));
    free_area[order].nr_free++;
}

static void
del_block(struct Page *base, size_t order) {
    list_del(&(base->page_link));
    ClearPageProperty(base);
    base->property = 0;
    free_area[order].nr_free--;
}

static struct Page *
get_buddy(struct Page *base, size_t order) {
    size_t idx = page_idx(base);
    size_t buddy_idx = idx ^ (1UL << order);
    struct Page *buddy = pages + buddy_idx;
    size_t size = 1UL << order;
    if (buddy < buddy_area_base ||
        buddy + size > buddy_area_base + buddy_area_npages) {
        return NULL;
    }
    return buddy;
}

static int
is_free_buddy(struct Page *buddy, size_t order) {
    if (buddy == NULL || !PageProperty(buddy)) {
        return 0;
    }
    if (buddy->property != (1U << order)) {
        return 0;
    }
    list_entry_t *le = &(free_area[order].free_list);
    while ((le = list_next(le)) != &(free_area[order].free_list)) {
        if (le2page(le, page_link) == buddy) {
            return 1;
        }
    }
    return 0;
}

static void
buddy_init(void) {
    for (int i = 0; i <= MAX_ORDER; i++) {
        list_init(&(free_area[i].free_list));
        free_area[i].nr_free = 0;
    }
    nr_free = 0;
    buddy_area_base = NULL;
    buddy_area_npages = 0;
}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        p->flags = 0;
        p->property = 0;
        set_page_ref(p, 0);
    }

    buddy_area_base = base;
    buddy_area_npages = n;
    nr_free += n;

    p = base;
    size_t left = n;
    while (left > 0) {
        size_t idx = page_idx(p);
        size_t order = 0;
        while (order < MAX_ORDER &&
               ((size_t)1 << (order + 1)) <= left &&
               (idx & (((size_t)1 << (order + 1)) - 1)) == 0) {
            order++;
        }
        add_block(p, order);
        p += (1U << order);
        left -= (1U << order);
    }
}

static struct Page *
buddy_alloc_pages(size_t n) {
    assert(n > 0);
    size_t order = order_of(n);
    size_t size = (size_t)1 << order;
    if (n > nr_free || size > nr_free) {
        return NULL;
    }

    size_t cur = order;
    while (cur <= MAX_ORDER && list_empty(&(free_area[cur].free_list))) {
        cur++;
    }
    if (cur > MAX_ORDER) {
        return NULL;
    }

    struct Page *block = le2page(list_next(&(free_area[cur].free_list)), page_link);
    del_block(block, cur);

    while (cur > order) {
        cur--;
        struct Page *right = block + (1U << cur);
        add_block(right, cur);
    }

    nr_free -= size;
    return block;
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    size_t order = order_of(n);
    size_t size = (size_t)1 << order;

    struct Page *p = base;
    for (; p != base + size; p++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        p->property = 0;
        set_page_ref(p, 0);
    }

    nr_free += size;

    while (order < MAX_ORDER) {
        struct Page *buddy = get_buddy(base, order);
        if (!is_free_buddy(buddy, order)) {
            break;
        }
        del_block(buddy, order);
        if (buddy < base) {
            base = buddy;
        }
        order++;
    }
    add_block(base, order);
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}

static size_t
count_free_pages(void) {
    size_t total = 0;
    for (int order = 0; order <= MAX_ORDER; order++) {
        size_t blocks = 0;
        list_entry_t *le = &(free_area[order].free_list);
        while ((le = list_next(le)) != &(free_area[order].free_list)) {
            struct Page *p = le2page(le, page_link);
            assert(PageProperty(p));
            assert(p->property == (1U << order));
            blocks++;
            total += p->property;
        }
        assert(blocks == free_area[order].nr_free);
    }
    return total;
}

static void
buddy_check(void) {
    size_t nr = nr_free_pages();
    assert(nr >= 32);
    assert(count_free_pages() == nr);

    struct Page *p1 = alloc_pages(1);
    struct Page *p2 = alloc_pages(1);
    struct Page *p3 = alloc_pages(3);
    assert(p1 != NULL && p2 != NULL && p3 != NULL);
    assert(p1 != p2 && p1 != p3 && p2 != p3);
    assert(!PageProperty(p1) && !PageProperty(p2) && !PageProperty(p3));
    assert((page_idx(p3) & 3) == 0);
    assert(nr_free_pages() == nr - 1 - 1 - 4);
    assert(count_free_pages() == nr_free_pages());

    free_pages(p1, 1);
    free_pages(p2, 1);
    free_pages(p3, 3);
    assert(nr_free_pages() == nr);
    assert(count_free_pages() == nr);

    struct Page *a = alloc_pages(4);
    assert(a != NULL);
    assert((page_idx(a) & 3) == 0);
    free_pages(a, 4);

    struct Page *left = alloc_pages(2);
    struct Page *right = alloc_pages(2);
    assert(left != NULL && right != NULL);
    assert((page_idx(left) & 1) == 0);
    assert((page_idx(right) & 1) == 0);
    assert(left + 2 == right || right + 2 == left);

    struct Page *first = (left < right) ? left : right;
    free_pages(left, 2);
    free_pages(right, 2);

    struct Page *merged = alloc_pages(4);
    assert(merged == first);
    free_pages(merged, 4);
    assert(nr_free_pages() == nr);

    assert(alloc_pages(nr + 1) == NULL);

    struct Page *big = alloc_pages(16);
    assert(big != NULL);
    assert((page_idx(big) & 15) == 0);
    free_pages(big, 16);
    assert(nr_free_pages() == nr);
    assert(count_free_pages() == nr);

    cprintf("[Test 3] Buddy System: PASS\n");
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};

void
buddy_selftest(void) {
    const size_t sandbox_n = 128;
    struct Page *area = alloc_pages(sandbox_n);
    assert(area != NULL);

    const struct pmm_manager *saved = pmm_manager;
    pmm_manager = &buddy_pmm_manager;

    buddy_pmm_manager.init();
    for (size_t i = 0; i < sandbox_n; i++) {
        area[i].flags = 0;
        area[i].property = 0;
        set_page_ref(&area[i], 0);
        SetPageReserved(&area[i]);
    }
    buddy_pmm_manager.init_memmap(area, sandbox_n);
    buddy_pmm_manager.check();

    pmm_manager = saved;
    for (size_t i = 0; i < sandbox_n; i++) {
        area[i].flags = 0;
        area[i].property = 0;
        set_page_ref(&area[i], 0);
    }
    free_pages(area, sandbox_n);
}
