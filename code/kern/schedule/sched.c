#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
        {
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;
        }
        else
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}


void schedule(void) {
    bool intr_flag;
    local_intr_save(intr_flag);
    struct proc_struct *next = idleproc;
    list_entry_t *list = &proc_list;
    list_entry_t *le = (current == idleproc) ? list : &current->list_link;
    for (int i = 0; i < MAX_PROCESS; i++) {
        le = list_next(le);
        if (le == list) le = list_next(le);
        if (le == list) break;
        struct proc_struct *p = le2proc(le, list_link);
        if (p->state == PROC_RUNNABLE) { next = p; break; }
    }
    current->need_resched = 0;
    if (next != current) proc_run(next);
    local_intr_restore(intr_flag);
}

