#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>
#include <riscv.h>
#include <mmu.h>

/* ------------- process/thread mechanism design&implementation -------------
(an simplified Linux process/thread mechanism )
introduction:
  ucore implements a simple process/thread mechanism. process contains the independent memory sapce, at least one threads
for execution, the kernel data(for management), processor state (for context switch), files(in lab6), etc. ucore needs to
manage all these details efficiently. In ucore, a thread is just a special kind of process(share process's memory).
------------------------------
process state       :     meaning               -- reason
    PROC_UNINIT     :   uninitialized           -- alloc_proc
    PROC_SLEEPING   :   sleeping                -- try_free_pages, do_wait, do_sleep
    PROC_RUNNABLE   :   runnable(maybe running) -- proc_init, wakeup_proc,
    PROC_ZOMBIE     :   almost dead             -- do_exit

-----------------------------
process state changing:

  alloc_proc                                 RUNNING
      +                                   +--<----<--+
      +                                   + proc_run +
      V                                   +-->---->--+
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                           +
                                           |      +--- do_exit --> PROC_ZOMBIE                                +
                                           +                                                                  +
                                           -----------------------wakeup_proc----------------------------------
-----------------------------
process relations
parent:           proc->parent  (proc is children)
children:         proc->cptr    (proc is parent)
older sibling:    proc->optr    (proc is younger sibling)
younger sibling:  proc->yptr    (proc is older sibling)
-----------------------------
related syscall for process:
SYS_exit        : process exit,                           -->do_exit
SYS_fork        : create child process, dup mm            -->do_fork-->wakeup_proc
SYS_wait        : wait process                            -->do_wait
SYS_exec        : after fork, process execute a program   -->load a program and refresh the mm
SYS_clone       : create child thread                     -->do_fork-->wakeup_proc
SYS_yield       : process flag itself need resecheduling, -- proc->need_sched=1, then scheduler will rescheule this process
SYS_sleep       : process sleep                           -->do_sleep
SYS_kill        : kill process                            -->do_kill-->proc->flags |= PF_EXITING
                                                                 -->wakeup_proc-->do_wait-->do_exit
SYS_getpid      : get the process's pid

*/

// the process set's list
list_entry_t proc_list;

#define HASH_SHIFT 10
#define HASH_LIST_SIZE (1 << HASH_SHIFT)
#define pid_hashfn(x) (hash32(x, HASH_SHIFT))

// has list for process set based on pid
static list_entry_t hash_list[HASH_LIST_SIZE];

// idle proc
struct proc_struct *idleproc = NULL;
// init proc
struct proc_struct *initproc = NULL;
// current proc
struct proc_struct *current = NULL;

static int nr_process = 0;

void kernel_thread_entry(void);
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);


static void forkret(void);

static struct proc_struct *alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc == NULL) return NULL;
    memset(proc, 0, sizeof(*proc));
    proc->state = PROC_UNINIT;
    proc->pid = -1;
    proc->pgdir = boot_pgdir_pa;
    list_init(&proc->list_link);
    list_init(&proc->hash_link);
    return proc;
}

static void copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
    *(proc->tf) = *tf;
    proc->tf->gpr.a0 = 0;
    proc->tf->gpr.sp = (esp != 0) ? esp : (uintptr_t)proc->tf;
    proc->context.ra = (uintptr_t)forkret;
    proc->context.sp = (uintptr_t)proc->tf;
}



// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name)
{
    memset(proc->name, 0, sizeof(proc->name));
    return memcpy(proc->name, name, PROC_NAME_LEN);
}

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc)
{
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc)
{
    list_add(&proc_list, &(proc->list_link));
    proc->yptr = NULL;
    if ((proc->optr = proc->parent->cptr) != NULL)
    {
        proc->optr->yptr = proc;
    }
    proc->parent->cptr = proc;
    nr_process++;
}

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc)
{
    list_del(&(proc->list_link));
    if (proc->optr != NULL)
    {
        proc->optr->yptr = proc->yptr;
    }
    if (proc->yptr != NULL)
    {
        proc->yptr->optr = proc->optr;
    }
    else
    {
        proc->parent->cptr = proc->optr;
    }
    nr_process--;
}

// get_pid - alloc a unique pid for process
static int
get_pid(void)
{
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++last_pid >= MAX_PID)
    {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe)
    {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list)
        {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid)
            {
                if (++last_pid >= next_safe)
                {
                    if (last_pid >= MAX_PID)
                    {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid)
            {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}






// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
}

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc)
{
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc)
{
    list_del(&(proc->hash_link));
}

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid)
{
    if (0 < pid && pid < MAX_PID)
    {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list)
        {
            struct proc_struct *proc = le2proc(le, hash_link);
            if (proc->pid == pid)
            {
                return proc;
            }
        }
    }
    return NULL;
}


int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
    struct trapframe tf;
    memset(&tf, 0, sizeof(tf));
    tf.gpr.s0 = (uintptr_t)fn;
    tf.gpr.s1 = (uintptr_t)arg;
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
    tf.epc = (uintptr_t)kernel_thread_entry;
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}



// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc)
{
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL)
    {
        proc->kstack = (uintptr_t)page2kva(page);
        return 0;
    }
    return -E_NO_MEM;
}

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc)
{
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
}

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm)
{
    struct Page *page;
    if ((page = alloc_page()) == NULL)
    {
        return -E_NO_MEM;
    }
    pde_t *pgdir = page2kva(page);
    memcpy(pgdir, boot_pgdir_va, PGSIZE);

    mm->pgdir = pgdir;
    return 0;
}

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm)
{
    free_page(kva2page(mm->pgdir));
}

// copy_mm - share or duplicate the current process address space.
static int copy_mm(uint32_t clone_flags, struct proc_struct *proc)
{
    struct mm_struct *oldmm = current->mm;
    if (oldmm == NULL)
    {
        proc->mm = NULL;
        proc->pgdir = boot_pgdir_pa;
        return 0;
    }

    if (clone_flags & CLONE_VM)
    {
        mm_count_inc(oldmm);
        proc->mm = oldmm;
        proc->pgdir = current->pgdir;
        return 0;
    }

    struct mm_struct *mm = mm_create();
    if (mm == NULL)
    {
        return -E_NO_MEM;
    }

    int ret = setup_pgdir(mm);
    if (ret == 0)
    {
        ret = dup_mmap(mm, oldmm);
    }
    if (ret != 0)
    {
        // dup_mmap may have installed some VMAs/pages before failing.
        set_mm_count(mm, 0);
        if (mm->pgdir != NULL)
        {
            exit_mmap(mm);
            put_pgdir(mm);
        }
        mm_destroy(mm);
        return ret;
    }

    proc->mm = mm;
    mm_count_inc(mm);
    proc->pgdir = PADDR(mm->pgdir);
    return 0;
}

// do_fork - create a child process, copying or sharing its address space.
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
    if (nr_process >= MAX_PROCESS)
    {
        return -E_NO_FREE_PROC;
    }
    if (current == NULL || tf == NULL)
    {
        return -E_INVAL;
    }

    int ret;
    struct proc_struct *proc = alloc_proc();
    if (proc == NULL)
    {
        return -E_NO_MEM;
    }

    if ((ret = setup_kstack(proc)) != 0)
    {
        kfree(proc);
        return ret;
    }
    if ((ret = copy_mm(clone_flags, proc)) != 0)
    {
        put_kstack(proc);
        kfree(proc);
        return ret;
    }

    proc->parent = current;
    copy_thread(proc, stack, tf);
    proc->pid = get_pid();

    bool intr_flag;
    local_intr_save(intr_flag);
    hash_proc(proc);
    set_links(proc);
    local_intr_restore(intr_flag);

    wakeup_proc(proc);
    return proc->pid;
}

void proc_run(struct proc_struct *proc) {
    if (proc != current) {
        bool intr_flag;
        local_intr_save(intr_flag);
        struct proc_struct *prev = current;
        current = proc;
        write_csr(satp, (1UL << 63) | (proc->pgdir >> PGSHIFT));
        asm volatile("sfence.vma" ::: "memory");
        switch_to(&prev->context, &proc->context);
        local_intr_restore(intr_flag);
    }
}

int do_yield(void) { current->need_resched = 1; return 0; }

void cpu_idle(void) {
    while (1) {
        if (current->need_resched) schedule();
        asm volatile("wfi");
    }
}

int do_exit(int error_code) {
    if (current == idleproc || current == initproc) panic("cannot exit idle/init");
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
    panic("do_exit returned");
}

int do_wait(int pid, int *code_store) {
    struct proc_struct *p;
    bool has_child;
    while (1) {
        has_child = 0;
        p = current->cptr;
        while (p != NULL) {
            if (pid == 0 || p->pid == pid) {
                has_child = 1;
                if (p->state == PROC_ZOMBIE) goto found;
            }
            p = p->optr;
        }
        if (!has_child) return -E_BAD_PROC;
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;
        schedule();
    }
found:
    if (code_store != NULL) {
        if (current->mm != NULL && !copy_to_user(current->mm, code_store, &p->exit_code, sizeof(int)))
            return -E_FAULT;
        if (current->mm == NULL) *code_store = p->exit_code;
    }
    bool intr_flag;
    local_intr_save(intr_flag);
    unhash_proc(p);
    remove_links(p);
    local_intr_restore(intr_flag);
    put_kstack(p);
    kfree(p);
    return 0;
}

int do_kill(int pid) {
    struct proc_struct *p = find_proc(pid);
    if (p == NULL || p == idleproc || p == initproc) return -E_INVAL;
    p->flags |= PF_EXITING;
    if (p->state == PROC_SLEEPING) wakeup_proc(p);
    return 0;
}




/* load_icode: allocate a user address space and copy PT_LOAD segments. */
static int load_icode(unsigned char *binary, size_t size) {
    cprintf("[DEBUG-3] entered load_icode\n");
    int ret = -E_INVAL_ELF;
    if (binary == NULL || size < sizeof(struct elfhdr)) return ret;
    struct elfhdr *elf = (struct elfhdr *)binary;
    if (elf->e_magic != ELF_MAGIC || elf->e_phentsize != sizeof(struct proghdr) ||
        elf->e_phoff > size || elf->e_phnum > (size - elf->e_phoff) / sizeof(struct proghdr))
        return ret;
    cprintf("[STAGE-1] ELF header validated, entry=0x%lx, phnum=%d\\n",
            (uintptr_t)elf->e_entry, elf->e_phnum);

    cprintf("[STAGE-2] before mm_create\\n");
    struct mm_struct *mm = mm_create();
    if (mm == NULL) return -E_NO_MEM;
    cprintf("[STAGE-3] mm_create completed: mm=%p\\n", mm);
    cprintf("[STAGE-4] before setup_pgdir\\n");
    if ((ret = setup_pgdir(mm)) != 0) { mm_destroy(mm); return ret; }
    cprintf("[STAGE-5] setup_pgdir completed: pgdir=%p\\n", mm->pgdir);
    for (size_t i = 0; i < elf->e_phnum; i++) {
        struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff + i * sizeof(struct proghdr));
        cprintf("[STAGE-6] program header %d, type=%d\\n",
                (int)i, ph->p_type);
        if (ph->p_type != ELF_PT_LOAD) continue;
        cprintf("[STAGE-7] LOAD: va=0x%lx filesz=%lu memsz=%lu\\n",
                (uintptr_t)ph->p_va,
                (uintptr_t)ph->p_filesz,
                (uintptr_t)ph->p_memsz);
        if (ph->p_filesz > ph->p_memsz || ph->p_offset > size || ph->p_filesz > size - ph->p_offset ||
            ph->p_memsz == 0 || ph->p_va + ph->p_memsz < ph->p_va ||
            !USER_ACCESS(ph->p_va, ph->p_va + ph->p_memsz)) { ret = -E_INVAL_ELF; goto bad; }
        uint32_t flags = 0;
        if (ph->p_flags & ELF_PF_R) flags |= VM_READ;
        if (ph->p_flags & ELF_PF_W) flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_X) flags |= VM_EXEC;
        cprintf("[STAGE-8] before mm_map\\n");
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, flags, NULL)) != 0) goto bad;
        cprintf("[STAGE-9] mm_map completed\\n");
        /* Permissions are intentionally inclusive for the initial loader. */
        uintptr_t start = ROUNDDOWN(ph->p_va, PGSIZE);
        uintptr_t end = ROUNDUP(ph->p_va + ph->p_memsz, PGSIZE);
        cprintf("[STAGE-10] before allocating LOAD pages\\n");
        for (uintptr_t va = start; va < end; va += PGSIZE) {
            cprintf("[STAGE-11] allocating va=0x%lx\\n", va);
            struct Page *page = get_page(mm->pgdir, va, NULL);
            if (page == NULL) {
                page = pgdir_alloc_page(mm->pgdir, va, PTE_U | PTE_R | PTE_W | PTE_X);
                if (page == NULL) { ret = -E_NO_MEM; goto bad; }
                memset(page2kva(page), 0, PGSIZE);
            }
        }
        cprintf("[STAGE-12] LOAD pages allocated\\n");
        for (size_t pos = 0; pos < ph->p_filesz;) {
            uintptr_t va = ph->p_va + pos;
            size_t n = PGSIZE - PGOFF(va);
            if (n > ph->p_filesz - pos) n = ph->p_filesz - pos;
            struct Page *pg = get_page(mm->pgdir, va, NULL);
            memcpy((char *)page2kva(pg) + PGOFF(va), binary + ph->p_offset + pos, n);
            pos += n;
        }
    }
    cprintf("[STAGE-13] ELF content copied\\n");
    cprintf("[STAGE-14] before mapping user stack\\n");
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE,
                      VM_READ | VM_WRITE | VM_STACK, NULL)) != 0) goto bad;
    /* The initial process only needs a small physical stack; map 4 pages. */
    for (uintptr_t va = USTACKTOP - 4 * PGSIZE; va < USTACKTOP; va += PGSIZE) {
        struct Page *page = pgdir_alloc_page(mm->pgdir, va, PTE_U | PTE_R | PTE_W);
        if (page == NULL) { ret = -E_NO_MEM; goto bad; }
        memset(page2kva(page), 0, PGSIZE);
    }
    current->mm = mm;
    mm_count_inc(mm);
    current->pgdir = PADDR(mm->pgdir);
    memset(current->tf, 0, sizeof(struct trapframe));
    current->tf->gpr.sp = USTACKTOP;
    current->tf->epc = elf->e_entry;
    current->tf->status = (read_csr(sstatus) | SSTATUS_SPIE) & ~(SSTATUS_SPP | SSTATUS_SIE);
    return 0;
bad:
    set_mm_count(mm, 0);
    exit_mmap(mm);
    put_pgdir(mm);
    mm_destroy(mm);
    return ret;
}

int do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
    cprintf("[DEBUG-2] entered do_execve\n");
    char local_name[PROC_NAME_LEN + 1];
    if (name == NULL || len == 0 || len > PROC_NAME_LEN || binary == NULL) return -E_INVAL;
    /* Only the initial kernel-launched binary is in scope for function 2. */
    if (current->mm != NULL) return -E_UNIMP;
    memcpy(local_name, name, len);
    local_name[len] = 0;
    int ret = load_icode(binary, size);
    if (ret == 0) set_proc_name(current, local_name);
    return ret;
}

static int kernel_execve(const char *name, unsigned char *binary, size_t size) {
    cprintf("\n[DEBUG-1] entered kernel_execve\n");
    int ret = do_execve(name, strlen(name), binary, size);

    // Debug before changing SATP.
    cprintf("\n========== BEFORE SATP DEBUG ==========\n");
    cprintf("ret    = %d\n", ret);

    if (ret == 0) {
        cprintf("current = %p\n", current);
        cprintf("tf      = %p\n", current->tf);
        cprintf("pgdir   = 0x%lx\n", current->pgdir);
        cprintf("epc     = 0x%lx\n", current->tf->epc);
        cprintf("sp      = 0x%lx\n", current->tf->gpr.sp);
        cprintf("status  = 0x%lx\n", current->tf->status);

        cprintf("Switching to user page table...\n");

        write_csr(satp, (1UL << 63) | (current->pgdir >> PGSHIFT));
        asm volatile("sfence.vma zero, zero" ::: "memory");

        forkrets(current->tf);
    }

    cprintf("kernel_execve failed: %d\n", ret);
    return ret;
}

#define __KERNEL_EXECVE(name, binary, size) ({           \
    cprintf("kernel_execve: pid = %d, name = \"%s\".\n", \
            current->pid, name);                         \
    kernel_execve(name, binary, (size_t)(size));         \
})

#define KERNEL_EXECVE(x) ({                                    \
    extern unsigned char _binary_obj___user_##x##_out_start[], \
        _binary_obj___user_##x##_out_size[];                   \
    __KERNEL_EXECVE(#x, _binary_obj___user_##x##_out_start,    \
                    _binary_obj___user_##x##_out_size);        \
})

#define __KERNEL_EXECVE2(x, xstart, xsize) ({   \
    extern unsigned char xstart[], xsize[];     \
    __KERNEL_EXECVE(#x, xstart, (size_t)xsize); \
})

#define KERNEL_EXECVE2(x, xstart, xsize) __KERNEL_EXECVE2(x, xstart, xsize)



static int user_main(void *arg) {
    (void)arg;
    int ret = KERNEL_EXECVE(forktest);
    panic("kernel_execve failed: %d", ret);
}

static int init_main(void *arg) {
    (void)arg;
    int pid = kernel_thread(user_main, NULL, 0);
    if (pid < 0) panic("create user process failed: %d", pid);
    int code = 0;
    int ret = do_wait(pid, &code);
    cprintf("user process pid=%d exited: wait=%d code=%d\n", pid, ret, code);
    while (1) { current->need_resched = 1; schedule(); }
}

void proc_init(void) {
    list_init(&proc_list);
    for (int i = 0; i < HASH_LIST_SIZE; i++) list_init(&hash_list[i]);
    idleproc = alloc_proc();
    if (idleproc == NULL) panic("cannot allocate idleproc");
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
    idleproc->need_resched = 1;
    idleproc->runs = 0;
    set_proc_name(idleproc, "idle");
    current = idleproc;
    nr_process = 1;
    int pid = kernel_thread(init_main, NULL, 0);
    if (pid < 0 || (initproc = find_proc(pid)) == NULL) panic("cannot create initproc");
    set_proc_name(initproc, "init");
    cprintf("proc_init succeeded: idle=%d init=%d\n", idleproc->pid, initproc->pid);
}

