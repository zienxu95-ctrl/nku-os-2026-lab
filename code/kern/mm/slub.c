#include <assert.h>
#include <defs.h>
#include <memlayout.h>
#include <pmm.h>
#include <stdio.h>
#include <string.h>
#include <slub.h>

#define SLUB_ALIGN 8
#define SLUB_MAX_CLASS 8

static const size_t slub_sizes[SLUB_MAX_CLASS] = {
    16, 32, 64, 128, 256, 512, 1024, 2048
};

struct slub_slab {
    struct slub_slab *next;
    size_t objsize;
    unsigned int inuse;
    unsigned int capacity;
    void *freelist;
};

struct slub_cache {
    size_t objsize;
    struct slub_slab *partial;
};

static struct slub_cache slub_caches[SLUB_MAX_CLASS];

static void *
page2kva(struct Page *page) {
    return (void *)(page2pa(page) + va_pa_offset);
}

static struct Page *
kva2page(void *kva) {
    return pa2page((uintptr_t)kva - va_pa_offset);
}

static size_t
align_up(size_t n, size_t align) {
    return (n + align - 1) & ~(align - 1);
}

static int
size_to_index(size_t size) {
    for (int i = 0; i < SLUB_MAX_CLASS; i++) {
        if (slub_sizes[i] >= size) {
            return i;
        }
    }
    return -1;
}

void
slub_init(void) {
    for (int i = 0; i < SLUB_MAX_CLASS; i++) {
        slub_caches[i].objsize = slub_sizes[i];
        slub_caches[i].partial = NULL;
    }
}

static struct slub_slab *
slub_new_slab(struct slub_cache *cache) {
    struct Page *page = alloc_page();
    if (page == NULL) {
        return NULL;
    }

    struct slub_slab *slab = (struct slub_slab *)page2kva(page);
    memset(slab, 0, PGSIZE);
    slab->objsize = cache->objsize;
    slab->inuse = 0;
    slab->freelist = NULL;
    slab->next = NULL;

    size_t header = align_up(sizeof(struct slub_slab), SLUB_ALIGN);
    char *obj = (char *)slab + header;
    unsigned int capacity = 0;
    while (obj + cache->objsize <= (char *)slab + PGSIZE) {
        *(void **)obj = slab->freelist;
        slab->freelist = obj;
        obj += cache->objsize;
        capacity++;
    }
    slab->capacity = capacity;
    assert(capacity > 0);

    slab->next = cache->partial;
    cache->partial = slab;
    return slab;
}

void *
slub_alloc(size_t size) {
    if (size == 0) {
        return NULL;
    }
    int idx = size_to_index(size);
    if (idx < 0) {
        return NULL;
    }

    struct slub_cache *cache = &slub_caches[idx];
    struct slub_slab *slab = cache->partial;
    while (slab != NULL && slab->freelist == NULL) {
        slab = slab->next;
    }
    if (slab == NULL) {
        slab = slub_new_slab(cache);
        if (slab == NULL) {
            return NULL;
        }
    }

    void *obj = slab->freelist;
    slab->freelist = *(void **)obj;
    slab->inuse++;
    return obj;
}

void
slub_free(void *obj) {
    if (obj == NULL) {
        return;
    }

    uintptr_t page_kva = ROUNDDOWN((uintptr_t)obj, PGSIZE);
    struct slub_slab *slab = (struct slub_slab *)page_kva;
    assert(slab->objsize >= sizeof(void *));
    assert(slab->inuse > 0);

    *(void **)obj = slab->freelist;
    slab->freelist = obj;
    slab->inuse--;

    if (slab->inuse != 0) {
        return;
    }

    int idx = size_to_index(slab->objsize);
    assert(idx >= 0);
    struct slub_cache *cache = &slub_caches[idx];
    struct slub_slab **pp = &cache->partial;
    while (*pp != NULL && *pp != slab) {
        pp = &(*pp)->next;
    }
    assert(*pp == slab);
    *pp = slab->next;

    struct Page *page = kva2page(slab);
    memset(slab, 0, sizeof(struct slub_slab));
    free_page(page);
}

void
slub_selftest(void) {
    slub_init();

    size_t nr = nr_free_pages();
    assert(nr > 8);

    void *a = slub_alloc(24);
    void *b = slub_alloc(24);
    void *c = slub_alloc(100);
    assert(a != NULL && b != NULL && c != NULL);
    assert(a != b && a != c && b != c);

    memset(a, 0x11, 24);
    memset(b, 0x22, 24);
    memset(c, 0x33, 100);
    assert(((char *)a)[0] == 0x11);
    assert(((char *)b)[0] == 0x22);
    assert(((char *)c)[0] == 0x33);

    slub_free(a);
    void *a2 = slub_alloc(16);
    assert(a2 == a);

    slub_free(a2);
    slub_free(b);
    slub_free(c);
    assert(nr_free_pages() == nr);

    const int nobj = 80;
    void *objs[80];
    for (int i = 0; i < nobj; i++) {
        objs[i] = slub_alloc(64);
        assert(objs[i] != NULL);
        memset(objs[i], (char)(i + 1), 64);
    }
    for (int i = 0; i < nobj; i++) {
        for (int j = i + 1; j < nobj; j++) {
            assert(objs[i] != objs[j]);
        }
        assert(((char *)objs[i])[0] == (char)(i + 1));
    }
    assert(nr_free_pages() < nr);

    assert(slub_alloc(0) == NULL);
    assert(slub_alloc(4096) == NULL);

    for (int i = 0; i < nobj; i++) {
        slub_free(objs[i]);
    }
    assert(nr_free_pages() == nr);

    cprintf("[Test 4] SLUB: PASS\n");
}
