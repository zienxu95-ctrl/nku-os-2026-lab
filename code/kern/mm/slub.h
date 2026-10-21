#ifndef __KERN_MM_SLUB_H__
#define __KERN_MM_SLUB_H__

#include <defs.h>

void slub_init(void);
void *slub_alloc(size_t size);
void slub_free(void *obj);
void slub_selftest(void);

#endif /* !__KERN_MM_SLUB_H__ */
