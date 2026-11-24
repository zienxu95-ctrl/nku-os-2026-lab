
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	0000a297          	auipc	t0,0xa
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc020a000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	0000a297          	auipc	t0,0xa
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc020a008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200034:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200038:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc020003c:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
void grade_backtrace(void);

int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc020004a:	000ac517          	auipc	a0,0xac
ffffffffc020004e:	24650513          	addi	a0,a0,582 # ffffffffc02ac290 <buf>
ffffffffc0200052:	000b0617          	auipc	a2,0xb0
ffffffffc0200056:	6e260613          	addi	a2,a2,1762 # ffffffffc02b0734 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	020050ef          	jal	ra,ffffffffc0205082 <memset>
    dtb_init();
ffffffffc0200066:	558000ef          	jal	ra,ffffffffc02005be <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	4e2000ef          	jal	ra,ffffffffc020054c <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00005597          	auipc	a1,0x5
ffffffffc0200072:	04258593          	addi	a1,a1,66 # ffffffffc02050b0 <etext+0x4>
ffffffffc0200076:	00005517          	auipc	a0,0x5
ffffffffc020007a:	05a50513          	addi	a0,a0,90 # ffffffffc02050d0 <etext+0x24>
ffffffffc020007e:	116000ef          	jal	ra,ffffffffc0200194 <cprintf>

    print_kerninfo();
ffffffffc0200082:	15a000ef          	jal	ra,ffffffffc02001dc <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	318020ef          	jal	ra,ffffffffc020239e <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	0f1000ef          	jal	ra,ffffffffc020097a <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	0ef000ef          	jal	ra,ffffffffc020097c <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	470030ef          	jal	ra,ffffffffc0203502 <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	7c4040ef          	jal	ra,ffffffffc020485a <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	460000ef          	jal	ra,ffffffffc02004fa <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	0d1000ef          	jal	ra,ffffffffc020096e <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	5cf030ef          	jal	ra,ffffffffc0203e70 <cpu_idle>

ffffffffc02000a6 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02000a6:	715d                	addi	sp,sp,-80
ffffffffc02000a8:	e486                	sd	ra,72(sp)
ffffffffc02000aa:	e0a6                	sd	s1,64(sp)
ffffffffc02000ac:	fc4a                	sd	s2,56(sp)
ffffffffc02000ae:	f84e                	sd	s3,48(sp)
ffffffffc02000b0:	f452                	sd	s4,40(sp)
ffffffffc02000b2:	f056                	sd	s5,32(sp)
ffffffffc02000b4:	ec5a                	sd	s6,24(sp)
ffffffffc02000b6:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000b8:	c901                	beqz	a0,ffffffffc02000c8 <readline+0x22>
ffffffffc02000ba:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000bc:	00005517          	auipc	a0,0x5
ffffffffc02000c0:	01c50513          	addi	a0,a0,28 # ffffffffc02050d8 <etext+0x2c>
ffffffffc02000c4:	0d0000ef          	jal	ra,ffffffffc0200194 <cprintf>
readline(const char *prompt) {
ffffffffc02000c8:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000ca:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000cc:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ce:	4aa9                	li	s5,10
ffffffffc02000d0:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000d2:	000acb97          	auipc	s7,0xac
ffffffffc02000d6:	1beb8b93          	addi	s7,s7,446 # ffffffffc02ac290 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000de:	0ee000ef          	jal	ra,ffffffffc02001cc <getchar>
        if (c < 0) {
ffffffffc02000e2:	00054a63          	bltz	a0,ffffffffc02000f6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000e6:	00a95a63          	bge	s2,a0,ffffffffc02000fa <readline+0x54>
ffffffffc02000ea:	029a5263          	bge	s4,s1,ffffffffc020010e <readline+0x68>
        c = getchar();
ffffffffc02000ee:	0de000ef          	jal	ra,ffffffffc02001cc <getchar>
        if (c < 0) {
ffffffffc02000f2:	fe055ae3          	bgez	a0,ffffffffc02000e6 <readline+0x40>
            return NULL;
ffffffffc02000f6:	4501                	li	a0,0
ffffffffc02000f8:	a091                	j	ffffffffc020013c <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000fa:	03351463          	bne	a0,s3,ffffffffc0200122 <readline+0x7c>
ffffffffc02000fe:	e8a9                	bnez	s1,ffffffffc0200150 <readline+0xaa>
        c = getchar();
ffffffffc0200100:	0cc000ef          	jal	ra,ffffffffc02001cc <getchar>
        if (c < 0) {
ffffffffc0200104:	fe0549e3          	bltz	a0,ffffffffc02000f6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200108:	fea959e3          	bge	s2,a0,ffffffffc02000fa <readline+0x54>
ffffffffc020010c:	4481                	li	s1,0
            cputchar(c);
ffffffffc020010e:	e42a                	sd	a0,8(sp)
ffffffffc0200110:	0ba000ef          	jal	ra,ffffffffc02001ca <cputchar>
            buf[i ++] = c;
ffffffffc0200114:	6522                	ld	a0,8(sp)
ffffffffc0200116:	009b87b3          	add	a5,s7,s1
ffffffffc020011a:	2485                	addiw	s1,s1,1
ffffffffc020011c:	00a78023          	sb	a0,0(a5)
ffffffffc0200120:	bf7d                	j	ffffffffc02000de <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0200122:	01550463          	beq	a0,s5,ffffffffc020012a <readline+0x84>
ffffffffc0200126:	fb651ce3          	bne	a0,s6,ffffffffc02000de <readline+0x38>
            cputchar(c);
ffffffffc020012a:	0a0000ef          	jal	ra,ffffffffc02001ca <cputchar>
            buf[i] = '\0';
ffffffffc020012e:	000ac517          	auipc	a0,0xac
ffffffffc0200132:	16250513          	addi	a0,a0,354 # ffffffffc02ac290 <buf>
ffffffffc0200136:	94aa                	add	s1,s1,a0
ffffffffc0200138:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020013c:	60a6                	ld	ra,72(sp)
ffffffffc020013e:	6486                	ld	s1,64(sp)
ffffffffc0200140:	7962                	ld	s2,56(sp)
ffffffffc0200142:	79c2                	ld	s3,48(sp)
ffffffffc0200144:	7a22                	ld	s4,40(sp)
ffffffffc0200146:	7a82                	ld	s5,32(sp)
ffffffffc0200148:	6b62                	ld	s6,24(sp)
ffffffffc020014a:	6bc2                	ld	s7,16(sp)
ffffffffc020014c:	6161                	addi	sp,sp,80
ffffffffc020014e:	8082                	ret
            cputchar(c);
ffffffffc0200150:	4521                	li	a0,8
ffffffffc0200152:	078000ef          	jal	ra,ffffffffc02001ca <cputchar>
            i --;
ffffffffc0200156:	34fd                	addiw	s1,s1,-1
ffffffffc0200158:	b759                	j	ffffffffc02000de <readline+0x38>

ffffffffc020015a <cputch>:
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
ffffffffc020015a:	1141                	addi	sp,sp,-16
ffffffffc020015c:	e022                	sd	s0,0(sp)
ffffffffc020015e:	e406                	sd	ra,8(sp)
ffffffffc0200160:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200162:	3ec000ef          	jal	ra,ffffffffc020054e <cons_putc>
    (*cnt)++;
ffffffffc0200166:	401c                	lw	a5,0(s0)
}
ffffffffc0200168:	60a2                	ld	ra,8(sp)
    (*cnt)++;
ffffffffc020016a:	2785                	addiw	a5,a5,1
ffffffffc020016c:	c01c                	sw	a5,0(s0)
}
ffffffffc020016e:	6402                	ld	s0,0(sp)
ffffffffc0200170:	0141                	addi	sp,sp,16
ffffffffc0200172:	8082                	ret

ffffffffc0200174 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc0200174:	1101                	addi	sp,sp,-32
ffffffffc0200176:	862a                	mv	a2,a0
ffffffffc0200178:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020017a:	00000517          	auipc	a0,0x0
ffffffffc020017e:	fe050513          	addi	a0,a0,-32 # ffffffffc020015a <cputch>
ffffffffc0200182:	006c                	addi	a1,sp,12
{
ffffffffc0200184:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200186:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc0200188:	2d7040ef          	jal	ra,ffffffffc0204c5e <vprintfmt>
    return cnt;
}
ffffffffc020018c:	60e2                	ld	ra,24(sp)
ffffffffc020018e:	4532                	lw	a0,12(sp)
ffffffffc0200190:	6105                	addi	sp,sp,32
ffffffffc0200192:	8082                	ret

ffffffffc0200194 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc0200194:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200196:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
{
ffffffffc020019a:	8e2a                	mv	t3,a0
ffffffffc020019c:	f42e                	sd	a1,40(sp)
ffffffffc020019e:	f832                	sd	a2,48(sp)
ffffffffc02001a0:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001a2:	00000517          	auipc	a0,0x0
ffffffffc02001a6:	fb850513          	addi	a0,a0,-72 # ffffffffc020015a <cputch>
ffffffffc02001aa:	004c                	addi	a1,sp,4
ffffffffc02001ac:	869a                	mv	a3,t1
ffffffffc02001ae:	8672                	mv	a2,t3
{
ffffffffc02001b0:	ec06                	sd	ra,24(sp)
ffffffffc02001b2:	e0ba                	sd	a4,64(sp)
ffffffffc02001b4:	e4be                	sd	a5,72(sp)
ffffffffc02001b6:	e8c2                	sd	a6,80(sp)
ffffffffc02001b8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001ba:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001bc:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001be:	2a1040ef          	jal	ra,ffffffffc0204c5e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001c2:	60e2                	ld	ra,24(sp)
ffffffffc02001c4:	4512                	lw	a0,4(sp)
ffffffffc02001c6:	6125                	addi	sp,sp,96
ffffffffc02001c8:	8082                	ret

ffffffffc02001ca <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c)
{
    cons_putc(c);
ffffffffc02001ca:	a651                	j	ffffffffc020054e <cons_putc>

ffffffffc02001cc <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc02001cc:	1141                	addi	sp,sp,-16
ffffffffc02001ce:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001d0:	3b2000ef          	jal	ra,ffffffffc0200582 <cons_getc>
ffffffffc02001d4:	dd75                	beqz	a0,ffffffffc02001d0 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001d6:	60a2                	ld	ra,8(sp)
ffffffffc02001d8:	0141                	addi	sp,sp,16
ffffffffc02001da:	8082                	ret

ffffffffc02001dc <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
ffffffffc02001dc:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001de:	00005517          	auipc	a0,0x5
ffffffffc02001e2:	f0250513          	addi	a0,a0,-254 # ffffffffc02050e0 <etext+0x34>
{
ffffffffc02001e6:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001e8:	fadff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001ec:	00000597          	auipc	a1,0x0
ffffffffc02001f0:	e5e58593          	addi	a1,a1,-418 # ffffffffc020004a <kern_init>
ffffffffc02001f4:	00005517          	auipc	a0,0x5
ffffffffc02001f8:	f0c50513          	addi	a0,a0,-244 # ffffffffc0205100 <etext+0x54>
ffffffffc02001fc:	f99ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200200:	00005597          	auipc	a1,0x5
ffffffffc0200204:	eac58593          	addi	a1,a1,-340 # ffffffffc02050ac <etext>
ffffffffc0200208:	00005517          	auipc	a0,0x5
ffffffffc020020c:	f1850513          	addi	a0,a0,-232 # ffffffffc0205120 <etext+0x74>
ffffffffc0200210:	f85ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200214:	000ac597          	auipc	a1,0xac
ffffffffc0200218:	07c58593          	addi	a1,a1,124 # ffffffffc02ac290 <buf>
ffffffffc020021c:	00005517          	auipc	a0,0x5
ffffffffc0200220:	f2450513          	addi	a0,a0,-220 # ffffffffc0205140 <etext+0x94>
ffffffffc0200224:	f71ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200228:	000b0597          	auipc	a1,0xb0
ffffffffc020022c:	50c58593          	addi	a1,a1,1292 # ffffffffc02b0734 <end>
ffffffffc0200230:	00005517          	auipc	a0,0x5
ffffffffc0200234:	f3050513          	addi	a0,a0,-208 # ffffffffc0205160 <etext+0xb4>
ffffffffc0200238:	f5dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020023c:	000b1597          	auipc	a1,0xb1
ffffffffc0200240:	8f758593          	addi	a1,a1,-1801 # ffffffffc02b0b33 <end+0x3ff>
ffffffffc0200244:	00000797          	auipc	a5,0x0
ffffffffc0200248:	e0678793          	addi	a5,a5,-506 # ffffffffc020004a <kern_init>
ffffffffc020024c:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200250:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200254:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200256:	3ff5f593          	andi	a1,a1,1023
ffffffffc020025a:	95be                	add	a1,a1,a5
ffffffffc020025c:	85a9                	srai	a1,a1,0xa
ffffffffc020025e:	00005517          	auipc	a0,0x5
ffffffffc0200262:	f2250513          	addi	a0,a0,-222 # ffffffffc0205180 <etext+0xd4>
}
ffffffffc0200266:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200268:	b735                	j	ffffffffc0200194 <cprintf>

ffffffffc020026a <print_stackframe>:
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void)
{
ffffffffc020026a:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc020026c:	00005617          	auipc	a2,0x5
ffffffffc0200270:	f4460613          	addi	a2,a2,-188 # ffffffffc02051b0 <etext+0x104>
ffffffffc0200274:	04f00593          	li	a1,79
ffffffffc0200278:	00005517          	auipc	a0,0x5
ffffffffc020027c:	f5050513          	addi	a0,a0,-176 # ffffffffc02051c8 <etext+0x11c>
{
ffffffffc0200280:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200282:	1cc000ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0200286 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int mon_help(int argc, char **argv, struct trapframe *tf)
{
ffffffffc0200286:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i++)
    {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200288:	00005617          	auipc	a2,0x5
ffffffffc020028c:	f5860613          	addi	a2,a2,-168 # ffffffffc02051e0 <etext+0x134>
ffffffffc0200290:	00005597          	auipc	a1,0x5
ffffffffc0200294:	f7058593          	addi	a1,a1,-144 # ffffffffc0205200 <etext+0x154>
ffffffffc0200298:	00005517          	auipc	a0,0x5
ffffffffc020029c:	f7050513          	addi	a0,a0,-144 # ffffffffc0205208 <etext+0x15c>
{
ffffffffc02002a0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002a2:	ef3ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002a6:	00005617          	auipc	a2,0x5
ffffffffc02002aa:	f7260613          	addi	a2,a2,-142 # ffffffffc0205218 <etext+0x16c>
ffffffffc02002ae:	00005597          	auipc	a1,0x5
ffffffffc02002b2:	f9258593          	addi	a1,a1,-110 # ffffffffc0205240 <etext+0x194>
ffffffffc02002b6:	00005517          	auipc	a0,0x5
ffffffffc02002ba:	f5250513          	addi	a0,a0,-174 # ffffffffc0205208 <etext+0x15c>
ffffffffc02002be:	ed7ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002c2:	00005617          	auipc	a2,0x5
ffffffffc02002c6:	f8e60613          	addi	a2,a2,-114 # ffffffffc0205250 <etext+0x1a4>
ffffffffc02002ca:	00005597          	auipc	a1,0x5
ffffffffc02002ce:	fa658593          	addi	a1,a1,-90 # ffffffffc0205270 <etext+0x1c4>
ffffffffc02002d2:	00005517          	auipc	a0,0x5
ffffffffc02002d6:	f3650513          	addi	a0,a0,-202 # ffffffffc0205208 <etext+0x15c>
ffffffffc02002da:	ebbff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    }
    return 0;
}
ffffffffc02002de:	60a2                	ld	ra,8(sp)
ffffffffc02002e0:	4501                	li	a0,0
ffffffffc02002e2:	0141                	addi	sp,sp,16
ffffffffc02002e4:	8082                	ret

ffffffffc02002e6 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int mon_kerninfo(int argc, char **argv, struct trapframe *tf)
{
ffffffffc02002e6:	1141                	addi	sp,sp,-16
ffffffffc02002e8:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002ea:	ef3ff0ef          	jal	ra,ffffffffc02001dc <print_kerninfo>
    return 0;
}
ffffffffc02002ee:	60a2                	ld	ra,8(sp)
ffffffffc02002f0:	4501                	li	a0,0
ffffffffc02002f2:	0141                	addi	sp,sp,16
ffffffffc02002f4:	8082                	ret

ffffffffc02002f6 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int mon_backtrace(int argc, char **argv, struct trapframe *tf)
{
ffffffffc02002f6:	1141                	addi	sp,sp,-16
ffffffffc02002f8:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002fa:	f71ff0ef          	jal	ra,ffffffffc020026a <print_stackframe>
    return 0;
}
ffffffffc02002fe:	60a2                	ld	ra,8(sp)
ffffffffc0200300:	4501                	li	a0,0
ffffffffc0200302:	0141                	addi	sp,sp,16
ffffffffc0200304:	8082                	ret

ffffffffc0200306 <kmonitor>:
{
ffffffffc0200306:	7115                	addi	sp,sp,-224
ffffffffc0200308:	ed5e                	sd	s7,152(sp)
ffffffffc020030a:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020030c:	00005517          	auipc	a0,0x5
ffffffffc0200310:	f7450513          	addi	a0,a0,-140 # ffffffffc0205280 <etext+0x1d4>
{
ffffffffc0200314:	ed86                	sd	ra,216(sp)
ffffffffc0200316:	e9a2                	sd	s0,208(sp)
ffffffffc0200318:	e5a6                	sd	s1,200(sp)
ffffffffc020031a:	e1ca                	sd	s2,192(sp)
ffffffffc020031c:	fd4e                	sd	s3,184(sp)
ffffffffc020031e:	f952                	sd	s4,176(sp)
ffffffffc0200320:	f556                	sd	s5,168(sp)
ffffffffc0200322:	f15a                	sd	s6,160(sp)
ffffffffc0200324:	e962                	sd	s8,144(sp)
ffffffffc0200326:	e566                	sd	s9,136(sp)
ffffffffc0200328:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020032a:	e6bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020032e:	00005517          	auipc	a0,0x5
ffffffffc0200332:	f7a50513          	addi	a0,a0,-134 # ffffffffc02052a8 <etext+0x1fc>
ffffffffc0200336:	e5fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if (tf != NULL)
ffffffffc020033a:	000b8563          	beqz	s7,ffffffffc0200344 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020033e:	855e                	mv	a0,s7
ffffffffc0200340:	025000ef          	jal	ra,ffffffffc0200b64 <print_trapframe>
ffffffffc0200344:	00005c17          	auipc	s8,0x5
ffffffffc0200348:	fd4c0c13          	addi	s8,s8,-44 # ffffffffc0205318 <commands>
        if ((buf = readline("K> ")) != NULL)
ffffffffc020034c:	00005917          	auipc	s2,0x5
ffffffffc0200350:	f8490913          	addi	s2,s2,-124 # ffffffffc02052d0 <etext+0x224>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200354:	00005497          	auipc	s1,0x5
ffffffffc0200358:	f8448493          	addi	s1,s1,-124 # ffffffffc02052d8 <etext+0x22c>
        if (argc == MAXARGS - 1)
ffffffffc020035c:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035e:	00005b17          	auipc	s6,0x5
ffffffffc0200362:	f82b0b13          	addi	s6,s6,-126 # ffffffffc02052e0 <etext+0x234>
        argv[argc++] = buf;
ffffffffc0200366:	00005a17          	auipc	s4,0x5
ffffffffc020036a:	e9aa0a13          	addi	s4,s4,-358 # ffffffffc0205200 <etext+0x154>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc020036e:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL)
ffffffffc0200370:	854a                	mv	a0,s2
ffffffffc0200372:	d35ff0ef          	jal	ra,ffffffffc02000a6 <readline>
ffffffffc0200376:	842a                	mv	s0,a0
ffffffffc0200378:	dd65                	beqz	a0,ffffffffc0200370 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc020037a:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020037e:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200380:	e1bd                	bnez	a1,ffffffffc02003e6 <kmonitor+0xe0>
    if (argc == 0)
ffffffffc0200382:	fe0c87e3          	beqz	s9,ffffffffc0200370 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200386:	6582                	ld	a1,0(sp)
ffffffffc0200388:	00005d17          	auipc	s10,0x5
ffffffffc020038c:	f90d0d13          	addi	s10,s10,-112 # ffffffffc0205318 <commands>
        argv[argc++] = buf;
ffffffffc0200390:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc0200392:	4401                	li	s0,0
ffffffffc0200394:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200396:	493040ef          	jal	ra,ffffffffc0205028 <strcmp>
ffffffffc020039a:	c919                	beqz	a0,ffffffffc02003b0 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc020039c:	2405                	addiw	s0,s0,1
ffffffffc020039e:	0b540063          	beq	s0,s5,ffffffffc020043e <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003a2:	000d3503          	ld	a0,0(s10)
ffffffffc02003a6:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003a8:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003aa:	47f040ef          	jal	ra,ffffffffc0205028 <strcmp>
ffffffffc02003ae:	f57d                	bnez	a0,ffffffffc020039c <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003b0:	00141793          	slli	a5,s0,0x1
ffffffffc02003b4:	97a2                	add	a5,a5,s0
ffffffffc02003b6:	078e                	slli	a5,a5,0x3
ffffffffc02003b8:	97e2                	add	a5,a5,s8
ffffffffc02003ba:	6b9c                	ld	a5,16(a5)
ffffffffc02003bc:	865e                	mv	a2,s7
ffffffffc02003be:	002c                	addi	a1,sp,8
ffffffffc02003c0:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003c4:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0)
ffffffffc02003c6:	fa0555e3          	bgez	a0,ffffffffc0200370 <kmonitor+0x6a>
}
ffffffffc02003ca:	60ee                	ld	ra,216(sp)
ffffffffc02003cc:	644e                	ld	s0,208(sp)
ffffffffc02003ce:	64ae                	ld	s1,200(sp)
ffffffffc02003d0:	690e                	ld	s2,192(sp)
ffffffffc02003d2:	79ea                	ld	s3,184(sp)
ffffffffc02003d4:	7a4a                	ld	s4,176(sp)
ffffffffc02003d6:	7aaa                	ld	s5,168(sp)
ffffffffc02003d8:	7b0a                	ld	s6,160(sp)
ffffffffc02003da:	6bea                	ld	s7,152(sp)
ffffffffc02003dc:	6c4a                	ld	s8,144(sp)
ffffffffc02003de:	6caa                	ld	s9,136(sp)
ffffffffc02003e0:	6d0a                	ld	s10,128(sp)
ffffffffc02003e2:	612d                	addi	sp,sp,224
ffffffffc02003e4:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02003e6:	8526                	mv	a0,s1
ffffffffc02003e8:	485040ef          	jal	ra,ffffffffc020506c <strchr>
ffffffffc02003ec:	c901                	beqz	a0,ffffffffc02003fc <kmonitor+0xf6>
ffffffffc02003ee:	00144583          	lbu	a1,1(s0)
            *buf++ = '\0';
ffffffffc02003f2:	00040023          	sb	zero,0(s0)
ffffffffc02003f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02003f8:	d5c9                	beqz	a1,ffffffffc0200382 <kmonitor+0x7c>
ffffffffc02003fa:	b7f5                	j	ffffffffc02003e6 <kmonitor+0xe0>
        if (*buf == '\0')
ffffffffc02003fc:	00044783          	lbu	a5,0(s0)
ffffffffc0200400:	d3c9                	beqz	a5,ffffffffc0200382 <kmonitor+0x7c>
        if (argc == MAXARGS - 1)
ffffffffc0200402:	033c8963          	beq	s9,s3,ffffffffc0200434 <kmonitor+0x12e>
        argv[argc++] = buf;
ffffffffc0200406:	003c9793          	slli	a5,s9,0x3
ffffffffc020040a:	0118                	addi	a4,sp,128
ffffffffc020040c:	97ba                	add	a5,a5,a4
ffffffffc020040e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200412:	00044583          	lbu	a1,0(s0)
        argv[argc++] = buf;
ffffffffc0200416:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200418:	e591                	bnez	a1,ffffffffc0200424 <kmonitor+0x11e>
ffffffffc020041a:	b7b5                	j	ffffffffc0200386 <kmonitor+0x80>
ffffffffc020041c:	00144583          	lbu	a1,1(s0)
            buf++;
ffffffffc0200420:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200422:	d1a5                	beqz	a1,ffffffffc0200382 <kmonitor+0x7c>
ffffffffc0200424:	8526                	mv	a0,s1
ffffffffc0200426:	447040ef          	jal	ra,ffffffffc020506c <strchr>
ffffffffc020042a:	d96d                	beqz	a0,ffffffffc020041c <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc020042c:	00044583          	lbu	a1,0(s0)
ffffffffc0200430:	d9a9                	beqz	a1,ffffffffc0200382 <kmonitor+0x7c>
ffffffffc0200432:	bf55                	j	ffffffffc02003e6 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200434:	45c1                	li	a1,16
ffffffffc0200436:	855a                	mv	a0,s6
ffffffffc0200438:	d5dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc020043c:	b7e9                	j	ffffffffc0200406 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020043e:	6582                	ld	a1,0(sp)
ffffffffc0200440:	00005517          	auipc	a0,0x5
ffffffffc0200444:	ec050513          	addi	a0,a0,-320 # ffffffffc0205300 <etext+0x254>
ffffffffc0200448:	d4dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
ffffffffc020044c:	b715                	j	ffffffffc0200370 <kmonitor+0x6a>

ffffffffc020044e <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void __panic(const char *file, int line, const char *fmt, ...)
{
    if (is_panic)
ffffffffc020044e:	000b0317          	auipc	t1,0xb0
ffffffffc0200452:	26a30313          	addi	t1,t1,618 # ffffffffc02b06b8 <is_panic>
ffffffffc0200456:	00033e03          	ld	t3,0(t1)
{
ffffffffc020045a:	715d                	addi	sp,sp,-80
ffffffffc020045c:	ec06                	sd	ra,24(sp)
ffffffffc020045e:	e822                	sd	s0,16(sp)
ffffffffc0200460:	f436                	sd	a3,40(sp)
ffffffffc0200462:	f83a                	sd	a4,48(sp)
ffffffffc0200464:	fc3e                	sd	a5,56(sp)
ffffffffc0200466:	e0c2                	sd	a6,64(sp)
ffffffffc0200468:	e4c6                	sd	a7,72(sp)
    if (is_panic)
ffffffffc020046a:	020e1a63          	bnez	t3,ffffffffc020049e <__panic+0x50>
    {
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020046e:	4785                	li	a5,1
ffffffffc0200470:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200474:	8432                	mv	s0,a2
ffffffffc0200476:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200478:	862e                	mv	a2,a1
ffffffffc020047a:	85aa                	mv	a1,a0
ffffffffc020047c:	00005517          	auipc	a0,0x5
ffffffffc0200480:	ee450513          	addi	a0,a0,-284 # ffffffffc0205360 <commands+0x48>
    va_start(ap, fmt);
ffffffffc0200484:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200486:	d0fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020048a:	65a2                	ld	a1,8(sp)
ffffffffc020048c:	8522                	mv	a0,s0
ffffffffc020048e:	ce7ff0ef          	jal	ra,ffffffffc0200174 <vcprintf>
    cprintf("\n");
ffffffffc0200492:	00006517          	auipc	a0,0x6
ffffffffc0200496:	c9e50513          	addi	a0,a0,-866 # ffffffffc0206130 <default_pmm_manager+0x5f8>
ffffffffc020049a:	cfbff0ef          	jal	ra,ffffffffc0200194 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020049e:	4501                	li	a0,0
ffffffffc02004a0:	4581                	li	a1,0
ffffffffc02004a2:	4601                	li	a2,0
ffffffffc02004a4:	48a1                	li	a7,8
ffffffffc02004a6:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004aa:	4ca000ef          	jal	ra,ffffffffc0200974 <intr_disable>
    while (1)
    {
        kmonitor(NULL);
ffffffffc02004ae:	4501                	li	a0,0
ffffffffc02004b0:	e57ff0ef          	jal	ra,ffffffffc0200306 <kmonitor>
    while (1)
ffffffffc02004b4:	bfed                	j	ffffffffc02004ae <__panic+0x60>

ffffffffc02004b6 <__warn>:
    }
}

/* __warn - like panic, but don't */
void __warn(const char *file, int line, const char *fmt, ...)
{
ffffffffc02004b6:	715d                	addi	sp,sp,-80
ffffffffc02004b8:	832e                	mv	t1,a1
ffffffffc02004ba:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004bc:	85aa                	mv	a1,a0
{
ffffffffc02004be:	8432                	mv	s0,a2
ffffffffc02004c0:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004c2:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc02004c4:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004c6:	00005517          	auipc	a0,0x5
ffffffffc02004ca:	eba50513          	addi	a0,a0,-326 # ffffffffc0205380 <commands+0x68>
{
ffffffffc02004ce:	ec06                	sd	ra,24(sp)
ffffffffc02004d0:	f436                	sd	a3,40(sp)
ffffffffc02004d2:	f83a                	sd	a4,48(sp)
ffffffffc02004d4:	e0c2                	sd	a6,64(sp)
ffffffffc02004d6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02004d8:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004da:	cbbff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004de:	65a2                	ld	a1,8(sp)
ffffffffc02004e0:	8522                	mv	a0,s0
ffffffffc02004e2:	c93ff0ef          	jal	ra,ffffffffc0200174 <vcprintf>
    cprintf("\n");
ffffffffc02004e6:	00006517          	auipc	a0,0x6
ffffffffc02004ea:	c4a50513          	addi	a0,a0,-950 # ffffffffc0206130 <default_pmm_manager+0x5f8>
ffffffffc02004ee:	ca7ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    va_end(ap);
}
ffffffffc02004f2:	60e2                	ld	ra,24(sp)
ffffffffc02004f4:	6442                	ld	s0,16(sp)
ffffffffc02004f6:	6161                	addi	sp,sp,80
ffffffffc02004f8:	8082                	ret

ffffffffc02004fa <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004fa:	67e1                	lui	a5,0x18
ffffffffc02004fc:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xce38>
ffffffffc0200500:	000b0717          	auipc	a4,0xb0
ffffffffc0200504:	1cf73423          	sd	a5,456(a4) # ffffffffc02b06c8 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200508:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020050c:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020050e:	953e                	add	a0,a0,a5
ffffffffc0200510:	4601                	li	a2,0
ffffffffc0200512:	4881                	li	a7,0
ffffffffc0200514:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200518:	02000793          	li	a5,32
ffffffffc020051c:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200520:	00005517          	auipc	a0,0x5
ffffffffc0200524:	e8050513          	addi	a0,a0,-384 # ffffffffc02053a0 <commands+0x88>
    ticks = 0;
ffffffffc0200528:	000b0797          	auipc	a5,0xb0
ffffffffc020052c:	1807bc23          	sd	zero,408(a5) # ffffffffc02b06c0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200530:	b195                	j	ffffffffc0200194 <cprintf>

ffffffffc0200532 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200532:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200536:	000b0797          	auipc	a5,0xb0
ffffffffc020053a:	1927b783          	ld	a5,402(a5) # ffffffffc02b06c8 <timebase>
ffffffffc020053e:	953e                	add	a0,a0,a5
ffffffffc0200540:	4581                	li	a1,0
ffffffffc0200542:	4601                	li	a2,0
ffffffffc0200544:	4881                	li	a7,0
ffffffffc0200546:	00000073          	ecall
ffffffffc020054a:	8082                	ret

ffffffffc020054c <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020054c:	8082                	ret

ffffffffc020054e <cons_putc>:
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020054e:	100027f3          	csrr	a5,sstatus
ffffffffc0200552:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200554:	0ff57513          	andi	a0,a0,255
ffffffffc0200558:	e799                	bnez	a5,ffffffffc0200566 <cons_putc+0x18>
ffffffffc020055a:	4581                	li	a1,0
ffffffffc020055c:	4601                	li	a2,0
ffffffffc020055e:	4885                	li	a7,1
ffffffffc0200560:	00000073          	ecall
    return 0;
}

static inline void __intr_restore(bool flag)
{
    if (flag)
ffffffffc0200564:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200566:	1101                	addi	sp,sp,-32
ffffffffc0200568:	ec06                	sd	ra,24(sp)
ffffffffc020056a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020056c:	408000ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc0200570:	6522                	ld	a0,8(sp)
ffffffffc0200572:	4581                	li	a1,0
ffffffffc0200574:	4601                	li	a2,0
ffffffffc0200576:	4885                	li	a7,1
ffffffffc0200578:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc020057c:	60e2                	ld	ra,24(sp)
ffffffffc020057e:	6105                	addi	sp,sp,32
    {
        intr_enable();
ffffffffc0200580:	a6fd                	j	ffffffffc020096e <intr_enable>

ffffffffc0200582 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0200582:	100027f3          	csrr	a5,sstatus
ffffffffc0200586:	8b89                	andi	a5,a5,2
ffffffffc0200588:	eb89                	bnez	a5,ffffffffc020059a <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020058a:	4501                	li	a0,0
ffffffffc020058c:	4581                	li	a1,0
ffffffffc020058e:	4601                	li	a2,0
ffffffffc0200590:	4889                	li	a7,2
ffffffffc0200592:	00000073          	ecall
ffffffffc0200596:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200598:	8082                	ret
int cons_getc(void) {
ffffffffc020059a:	1101                	addi	sp,sp,-32
ffffffffc020059c:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020059e:	3d6000ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc02005a2:	4501                	li	a0,0
ffffffffc02005a4:	4581                	li	a1,0
ffffffffc02005a6:	4601                	li	a2,0
ffffffffc02005a8:	4889                	li	a7,2
ffffffffc02005aa:	00000073          	ecall
ffffffffc02005ae:	2501                	sext.w	a0,a0
ffffffffc02005b0:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005b2:	3bc000ef          	jal	ra,ffffffffc020096e <intr_enable>
}
ffffffffc02005b6:	60e2                	ld	ra,24(sp)
ffffffffc02005b8:	6522                	ld	a0,8(sp)
ffffffffc02005ba:	6105                	addi	sp,sp,32
ffffffffc02005bc:	8082                	ret

ffffffffc02005be <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc02005be:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc02005c0:	00005517          	auipc	a0,0x5
ffffffffc02005c4:	e0050513          	addi	a0,a0,-512 # ffffffffc02053c0 <commands+0xa8>
void dtb_init(void) {
ffffffffc02005c8:	fc86                	sd	ra,120(sp)
ffffffffc02005ca:	f8a2                	sd	s0,112(sp)
ffffffffc02005cc:	e8d2                	sd	s4,80(sp)
ffffffffc02005ce:	f4a6                	sd	s1,104(sp)
ffffffffc02005d0:	f0ca                	sd	s2,96(sp)
ffffffffc02005d2:	ecce                	sd	s3,88(sp)
ffffffffc02005d4:	e4d6                	sd	s5,72(sp)
ffffffffc02005d6:	e0da                	sd	s6,64(sp)
ffffffffc02005d8:	fc5e                	sd	s7,56(sp)
ffffffffc02005da:	f862                	sd	s8,48(sp)
ffffffffc02005dc:	f466                	sd	s9,40(sp)
ffffffffc02005de:	f06a                	sd	s10,32(sp)
ffffffffc02005e0:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc02005e2:	bb3ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02005e6:	0000a597          	auipc	a1,0xa
ffffffffc02005ea:	a1a5b583          	ld	a1,-1510(a1) # ffffffffc020a000 <boot_hartid>
ffffffffc02005ee:	00005517          	auipc	a0,0x5
ffffffffc02005f2:	de250513          	addi	a0,a0,-542 # ffffffffc02053d0 <commands+0xb8>
ffffffffc02005f6:	b9fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02005fa:	0000a417          	auipc	s0,0xa
ffffffffc02005fe:	a0e40413          	addi	s0,s0,-1522 # ffffffffc020a008 <boot_dtb>
ffffffffc0200602:	600c                	ld	a1,0(s0)
ffffffffc0200604:	00005517          	auipc	a0,0x5
ffffffffc0200608:	ddc50513          	addi	a0,a0,-548 # ffffffffc02053e0 <commands+0xc8>
ffffffffc020060c:	b89ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200610:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200614:	00005517          	auipc	a0,0x5
ffffffffc0200618:	de450513          	addi	a0,a0,-540 # ffffffffc02053f8 <commands+0xe0>
    if (boot_dtb == 0) {
ffffffffc020061c:	120a0463          	beqz	s4,ffffffffc0200744 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200620:	57f5                	li	a5,-3
ffffffffc0200622:	07fa                	slli	a5,a5,0x1e
ffffffffc0200624:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200628:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020062a:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020062e:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200630:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200634:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200638:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020063c:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200640:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200644:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200646:	8ec9                	or	a3,a3,a0
ffffffffc0200648:	0087979b          	slliw	a5,a5,0x8
ffffffffc020064c:	1b7d                	addi	s6,s6,-1
ffffffffc020064e:	0167f7b3          	and	a5,a5,s6
ffffffffc0200652:	8dd5                	or	a1,a1,a3
ffffffffc0200654:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc0200656:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020065a:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc020065c:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe2f7b9>
ffffffffc0200660:	10f59163          	bne	a1,a5,ffffffffc0200762 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc0200664:	471c                	lw	a5,8(a4)
ffffffffc0200666:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc0200668:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020066a:	0087d59b          	srliw	a1,a5,0x8
ffffffffc020066e:	0086d51b          	srliw	a0,a3,0x8
ffffffffc0200672:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200676:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020067a:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020067e:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200682:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200686:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020068a:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020068e:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200692:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200694:	01146433          	or	s0,s0,a7
ffffffffc0200698:	0086969b          	slliw	a3,a3,0x8
ffffffffc020069c:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006a0:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006a2:	0087979b          	slliw	a5,a5,0x8
ffffffffc02006a6:	8c49                	or	s0,s0,a0
ffffffffc02006a8:	0166f6b3          	and	a3,a3,s6
ffffffffc02006ac:	00ca6a33          	or	s4,s4,a2
ffffffffc02006b0:	0167f7b3          	and	a5,a5,s6
ffffffffc02006b4:	8c55                	or	s0,s0,a3
ffffffffc02006b6:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02006ba:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02006bc:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02006be:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02006c0:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02006c4:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02006c6:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006c8:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc02006cc:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006ce:	00005917          	auipc	s2,0x5
ffffffffc02006d2:	d7a90913          	addi	s2,s2,-646 # ffffffffc0205448 <commands+0x130>
ffffffffc02006d6:	49bd                	li	s3,15
        switch (token) {
ffffffffc02006d8:	4d91                	li	s11,4
ffffffffc02006da:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02006dc:	00005497          	auipc	s1,0x5
ffffffffc02006e0:	d6448493          	addi	s1,s1,-668 # ffffffffc0205440 <commands+0x128>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006e4:	000a2703          	lw	a4,0(s4)
ffffffffc02006e8:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ec:	0087569b          	srliw	a3,a4,0x8
ffffffffc02006f0:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006f4:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006f8:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006fc:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200700:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200702:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200706:	0087171b          	slliw	a4,a4,0x8
ffffffffc020070a:	8fd5                	or	a5,a5,a3
ffffffffc020070c:	00eb7733          	and	a4,s6,a4
ffffffffc0200710:	8fd9                	or	a5,a5,a4
ffffffffc0200712:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200714:	09778c63          	beq	a5,s7,ffffffffc02007ac <dtb_init+0x1ee>
ffffffffc0200718:	00fbea63          	bltu	s7,a5,ffffffffc020072c <dtb_init+0x16e>
ffffffffc020071c:	07a78663          	beq	a5,s10,ffffffffc0200788 <dtb_init+0x1ca>
ffffffffc0200720:	4709                	li	a4,2
ffffffffc0200722:	00e79763          	bne	a5,a4,ffffffffc0200730 <dtb_init+0x172>
ffffffffc0200726:	4c81                	li	s9,0
ffffffffc0200728:	8a56                	mv	s4,s5
ffffffffc020072a:	bf6d                	j	ffffffffc02006e4 <dtb_init+0x126>
ffffffffc020072c:	ffb78ee3          	beq	a5,s11,ffffffffc0200728 <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200730:	00005517          	auipc	a0,0x5
ffffffffc0200734:	d9050513          	addi	a0,a0,-624 # ffffffffc02054c0 <commands+0x1a8>
ffffffffc0200738:	a5dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020073c:	00005517          	auipc	a0,0x5
ffffffffc0200740:	dbc50513          	addi	a0,a0,-580 # ffffffffc02054f8 <commands+0x1e0>
}
ffffffffc0200744:	7446                	ld	s0,112(sp)
ffffffffc0200746:	70e6                	ld	ra,120(sp)
ffffffffc0200748:	74a6                	ld	s1,104(sp)
ffffffffc020074a:	7906                	ld	s2,96(sp)
ffffffffc020074c:	69e6                	ld	s3,88(sp)
ffffffffc020074e:	6a46                	ld	s4,80(sp)
ffffffffc0200750:	6aa6                	ld	s5,72(sp)
ffffffffc0200752:	6b06                	ld	s6,64(sp)
ffffffffc0200754:	7be2                	ld	s7,56(sp)
ffffffffc0200756:	7c42                	ld	s8,48(sp)
ffffffffc0200758:	7ca2                	ld	s9,40(sp)
ffffffffc020075a:	7d02                	ld	s10,32(sp)
ffffffffc020075c:	6de2                	ld	s11,24(sp)
ffffffffc020075e:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc0200760:	bc15                	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200762:	7446                	ld	s0,112(sp)
ffffffffc0200764:	70e6                	ld	ra,120(sp)
ffffffffc0200766:	74a6                	ld	s1,104(sp)
ffffffffc0200768:	7906                	ld	s2,96(sp)
ffffffffc020076a:	69e6                	ld	s3,88(sp)
ffffffffc020076c:	6a46                	ld	s4,80(sp)
ffffffffc020076e:	6aa6                	ld	s5,72(sp)
ffffffffc0200770:	6b06                	ld	s6,64(sp)
ffffffffc0200772:	7be2                	ld	s7,56(sp)
ffffffffc0200774:	7c42                	ld	s8,48(sp)
ffffffffc0200776:	7ca2                	ld	s9,40(sp)
ffffffffc0200778:	7d02                	ld	s10,32(sp)
ffffffffc020077a:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc020077c:	00005517          	auipc	a0,0x5
ffffffffc0200780:	c9c50513          	addi	a0,a0,-868 # ffffffffc0205418 <commands+0x100>
}
ffffffffc0200784:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200786:	b439                	j	ffffffffc0200194 <cprintf>
                int name_len = strlen(name);
ffffffffc0200788:	8556                	mv	a0,s5
ffffffffc020078a:	057040ef          	jal	ra,ffffffffc0204fe0 <strlen>
ffffffffc020078e:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200790:	4619                	li	a2,6
ffffffffc0200792:	85a6                	mv	a1,s1
ffffffffc0200794:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc0200796:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200798:	0af040ef          	jal	ra,ffffffffc0205046 <strncmp>
ffffffffc020079c:	e111                	bnez	a0,ffffffffc02007a0 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc020079e:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02007a0:	0a91                	addi	s5,s5,4
ffffffffc02007a2:	9ad2                	add	s5,s5,s4
ffffffffc02007a4:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc02007a8:	8a56                	mv	s4,s5
ffffffffc02007aa:	bf2d                	j	ffffffffc02006e4 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc02007ac:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02007b0:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007b4:	0087d71b          	srliw	a4,a5,0x8
ffffffffc02007b8:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007bc:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007c0:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007c4:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02007c8:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007cc:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007d0:	0087979b          	slliw	a5,a5,0x8
ffffffffc02007d4:	00eaeab3          	or	s5,s5,a4
ffffffffc02007d8:	00fb77b3          	and	a5,s6,a5
ffffffffc02007dc:	00faeab3          	or	s5,s5,a5
ffffffffc02007e0:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02007e2:	000c9c63          	bnez	s9,ffffffffc02007fa <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc02007e6:	1a82                	slli	s5,s5,0x20
ffffffffc02007e8:	00368793          	addi	a5,a3,3
ffffffffc02007ec:	020ada93          	srli	s5,s5,0x20
ffffffffc02007f0:	9abe                	add	s5,s5,a5
ffffffffc02007f2:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc02007f6:	8a56                	mv	s4,s5
ffffffffc02007f8:	b5f5                	j	ffffffffc02006e4 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02007fa:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02007fe:	85ca                	mv	a1,s2
ffffffffc0200800:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200802:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200806:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020080a:	0187971b          	slliw	a4,a5,0x18
ffffffffc020080e:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200812:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200816:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200818:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020081c:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200820:	8d59                	or	a0,a0,a4
ffffffffc0200822:	00fb77b3          	and	a5,s6,a5
ffffffffc0200826:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200828:	1502                	slli	a0,a0,0x20
ffffffffc020082a:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020082c:	9522                	add	a0,a0,s0
ffffffffc020082e:	7fa040ef          	jal	ra,ffffffffc0205028 <strcmp>
ffffffffc0200832:	66a2                	ld	a3,8(sp)
ffffffffc0200834:	f94d                	bnez	a0,ffffffffc02007e6 <dtb_init+0x228>
ffffffffc0200836:	fb59f8e3          	bgeu	s3,s5,ffffffffc02007e6 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020083a:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020083e:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200842:	00005517          	auipc	a0,0x5
ffffffffc0200846:	c0e50513          	addi	a0,a0,-1010 # ffffffffc0205450 <commands+0x138>
           fdt32_to_cpu(x >> 32);
ffffffffc020084a:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020084e:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc0200852:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200856:	0187de1b          	srliw	t3,a5,0x18
ffffffffc020085a:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020085e:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200862:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200866:	0187d693          	srli	a3,a5,0x18
ffffffffc020086a:	01861f1b          	slliw	t5,a2,0x18
ffffffffc020086e:	0087579b          	srliw	a5,a4,0x8
ffffffffc0200872:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200876:	0106561b          	srliw	a2,a2,0x10
ffffffffc020087a:	010f6f33          	or	t5,t5,a6
ffffffffc020087e:	0187529b          	srliw	t0,a4,0x18
ffffffffc0200882:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200886:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020088a:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020088e:	0186f6b3          	and	a3,a3,s8
ffffffffc0200892:	01859e1b          	slliw	t3,a1,0x18
ffffffffc0200896:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020089a:	0107581b          	srliw	a6,a4,0x10
ffffffffc020089e:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008a2:	8361                	srli	a4,a4,0x18
ffffffffc02008a4:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008a8:	0105d59b          	srliw	a1,a1,0x10
ffffffffc02008ac:	01e6e6b3          	or	a3,a3,t5
ffffffffc02008b0:	00cb7633          	and	a2,s6,a2
ffffffffc02008b4:	0088181b          	slliw	a6,a6,0x8
ffffffffc02008b8:	0085959b          	slliw	a1,a1,0x8
ffffffffc02008bc:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008c0:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008c4:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008c8:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008cc:	0088989b          	slliw	a7,a7,0x8
ffffffffc02008d0:	011b78b3          	and	a7,s6,a7
ffffffffc02008d4:	005eeeb3          	or	t4,t4,t0
ffffffffc02008d8:	00c6e733          	or	a4,a3,a2
ffffffffc02008dc:	006c6c33          	or	s8,s8,t1
ffffffffc02008e0:	010b76b3          	and	a3,s6,a6
ffffffffc02008e4:	00bb7b33          	and	s6,s6,a1
ffffffffc02008e8:	01d7e7b3          	or	a5,a5,t4
ffffffffc02008ec:	016c6b33          	or	s6,s8,s6
ffffffffc02008f0:	01146433          	or	s0,s0,a7
ffffffffc02008f4:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc02008f6:	1702                	slli	a4,a4,0x20
ffffffffc02008f8:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02008fa:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc02008fc:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02008fe:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200900:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200904:	0167eb33          	or	s6,a5,s6
ffffffffc0200908:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc020090a:	88bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc020090e:	85a2                	mv	a1,s0
ffffffffc0200910:	00005517          	auipc	a0,0x5
ffffffffc0200914:	b6050513          	addi	a0,a0,-1184 # ffffffffc0205470 <commands+0x158>
ffffffffc0200918:	87dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020091c:	014b5613          	srli	a2,s6,0x14
ffffffffc0200920:	85da                	mv	a1,s6
ffffffffc0200922:	00005517          	auipc	a0,0x5
ffffffffc0200926:	b6650513          	addi	a0,a0,-1178 # ffffffffc0205488 <commands+0x170>
ffffffffc020092a:	86bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc020092e:	008b05b3          	add	a1,s6,s0
ffffffffc0200932:	15fd                	addi	a1,a1,-1
ffffffffc0200934:	00005517          	auipc	a0,0x5
ffffffffc0200938:	b7450513          	addi	a0,a0,-1164 # ffffffffc02054a8 <commands+0x190>
ffffffffc020093c:	859ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200940:	00005517          	auipc	a0,0x5
ffffffffc0200944:	bb850513          	addi	a0,a0,-1096 # ffffffffc02054f8 <commands+0x1e0>
        memory_base = mem_base;
ffffffffc0200948:	000b0797          	auipc	a5,0xb0
ffffffffc020094c:	d887b423          	sd	s0,-632(a5) # ffffffffc02b06d0 <memory_base>
        memory_size = mem_size;
ffffffffc0200950:	000b0797          	auipc	a5,0xb0
ffffffffc0200954:	d967b423          	sd	s6,-632(a5) # ffffffffc02b06d8 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc0200958:	b3f5                	j	ffffffffc0200744 <dtb_init+0x186>

ffffffffc020095a <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc020095a:	000b0517          	auipc	a0,0xb0
ffffffffc020095e:	d7653503          	ld	a0,-650(a0) # ffffffffc02b06d0 <memory_base>
ffffffffc0200962:	8082                	ret

ffffffffc0200964 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc0200964:	000b0517          	auipc	a0,0xb0
ffffffffc0200968:	d7453503          	ld	a0,-652(a0) # ffffffffc02b06d8 <memory_size>
ffffffffc020096c:	8082                	ret

ffffffffc020096e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020096e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200972:	8082                	ret

ffffffffc0200974 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200974:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200978:	8082                	ret

ffffffffc020097a <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020097a:	8082                	ret

ffffffffc020097c <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020097c:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200980:	00000797          	auipc	a5,0x0
ffffffffc0200984:	3b078793          	addi	a5,a5,944 # ffffffffc0200d30 <__alltraps>
ffffffffc0200988:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020098c:	000407b7          	lui	a5,0x40
ffffffffc0200990:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200994:	8082                	ret

ffffffffc0200996 <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200996:	610c                	ld	a1,0(a0)
{
ffffffffc0200998:	1141                	addi	sp,sp,-16
ffffffffc020099a:	e022                	sd	s0,0(sp)
ffffffffc020099c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020099e:	00005517          	auipc	a0,0x5
ffffffffc02009a2:	b7250513          	addi	a0,a0,-1166 # ffffffffc0205510 <commands+0x1f8>
{
ffffffffc02009a6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009a8:	fecff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009ac:	640c                	ld	a1,8(s0)
ffffffffc02009ae:	00005517          	auipc	a0,0x5
ffffffffc02009b2:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0205528 <commands+0x210>
ffffffffc02009b6:	fdeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009ba:	680c                	ld	a1,16(s0)
ffffffffc02009bc:	00005517          	auipc	a0,0x5
ffffffffc02009c0:	b8450513          	addi	a0,a0,-1148 # ffffffffc0205540 <commands+0x228>
ffffffffc02009c4:	fd0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02009c8:	6c0c                	ld	a1,24(s0)
ffffffffc02009ca:	00005517          	auipc	a0,0x5
ffffffffc02009ce:	b8e50513          	addi	a0,a0,-1138 # ffffffffc0205558 <commands+0x240>
ffffffffc02009d2:	fc2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02009d6:	700c                	ld	a1,32(s0)
ffffffffc02009d8:	00005517          	auipc	a0,0x5
ffffffffc02009dc:	b9850513          	addi	a0,a0,-1128 # ffffffffc0205570 <commands+0x258>
ffffffffc02009e0:	fb4ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02009e4:	740c                	ld	a1,40(s0)
ffffffffc02009e6:	00005517          	auipc	a0,0x5
ffffffffc02009ea:	ba250513          	addi	a0,a0,-1118 # ffffffffc0205588 <commands+0x270>
ffffffffc02009ee:	fa6ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02009f2:	780c                	ld	a1,48(s0)
ffffffffc02009f4:	00005517          	auipc	a0,0x5
ffffffffc02009f8:	bac50513          	addi	a0,a0,-1108 # ffffffffc02055a0 <commands+0x288>
ffffffffc02009fc:	f98ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a00:	7c0c                	ld	a1,56(s0)
ffffffffc0200a02:	00005517          	auipc	a0,0x5
ffffffffc0200a06:	bb650513          	addi	a0,a0,-1098 # ffffffffc02055b8 <commands+0x2a0>
ffffffffc0200a0a:	f8aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a0e:	602c                	ld	a1,64(s0)
ffffffffc0200a10:	00005517          	auipc	a0,0x5
ffffffffc0200a14:	bc050513          	addi	a0,a0,-1088 # ffffffffc02055d0 <commands+0x2b8>
ffffffffc0200a18:	f7cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a1c:	642c                	ld	a1,72(s0)
ffffffffc0200a1e:	00005517          	auipc	a0,0x5
ffffffffc0200a22:	bca50513          	addi	a0,a0,-1078 # ffffffffc02055e8 <commands+0x2d0>
ffffffffc0200a26:	f6eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a2a:	682c                	ld	a1,80(s0)
ffffffffc0200a2c:	00005517          	auipc	a0,0x5
ffffffffc0200a30:	bd450513          	addi	a0,a0,-1068 # ffffffffc0205600 <commands+0x2e8>
ffffffffc0200a34:	f60ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a38:	6c2c                	ld	a1,88(s0)
ffffffffc0200a3a:	00005517          	auipc	a0,0x5
ffffffffc0200a3e:	bde50513          	addi	a0,a0,-1058 # ffffffffc0205618 <commands+0x300>
ffffffffc0200a42:	f52ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a46:	702c                	ld	a1,96(s0)
ffffffffc0200a48:	00005517          	auipc	a0,0x5
ffffffffc0200a4c:	be850513          	addi	a0,a0,-1048 # ffffffffc0205630 <commands+0x318>
ffffffffc0200a50:	f44ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a54:	742c                	ld	a1,104(s0)
ffffffffc0200a56:	00005517          	auipc	a0,0x5
ffffffffc0200a5a:	bf250513          	addi	a0,a0,-1038 # ffffffffc0205648 <commands+0x330>
ffffffffc0200a5e:	f36ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200a62:	782c                	ld	a1,112(s0)
ffffffffc0200a64:	00005517          	auipc	a0,0x5
ffffffffc0200a68:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0205660 <commands+0x348>
ffffffffc0200a6c:	f28ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200a70:	7c2c                	ld	a1,120(s0)
ffffffffc0200a72:	00005517          	auipc	a0,0x5
ffffffffc0200a76:	c0650513          	addi	a0,a0,-1018 # ffffffffc0205678 <commands+0x360>
ffffffffc0200a7a:	f1aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200a7e:	604c                	ld	a1,128(s0)
ffffffffc0200a80:	00005517          	auipc	a0,0x5
ffffffffc0200a84:	c1050513          	addi	a0,a0,-1008 # ffffffffc0205690 <commands+0x378>
ffffffffc0200a88:	f0cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200a8c:	644c                	ld	a1,136(s0)
ffffffffc0200a8e:	00005517          	auipc	a0,0x5
ffffffffc0200a92:	c1a50513          	addi	a0,a0,-998 # ffffffffc02056a8 <commands+0x390>
ffffffffc0200a96:	efeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200a9a:	684c                	ld	a1,144(s0)
ffffffffc0200a9c:	00005517          	auipc	a0,0x5
ffffffffc0200aa0:	c2450513          	addi	a0,a0,-988 # ffffffffc02056c0 <commands+0x3a8>
ffffffffc0200aa4:	ef0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200aa8:	6c4c                	ld	a1,152(s0)
ffffffffc0200aaa:	00005517          	auipc	a0,0x5
ffffffffc0200aae:	c2e50513          	addi	a0,a0,-978 # ffffffffc02056d8 <commands+0x3c0>
ffffffffc0200ab2:	ee2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200ab6:	704c                	ld	a1,160(s0)
ffffffffc0200ab8:	00005517          	auipc	a0,0x5
ffffffffc0200abc:	c3850513          	addi	a0,a0,-968 # ffffffffc02056f0 <commands+0x3d8>
ffffffffc0200ac0:	ed4ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200ac4:	744c                	ld	a1,168(s0)
ffffffffc0200ac6:	00005517          	auipc	a0,0x5
ffffffffc0200aca:	c4250513          	addi	a0,a0,-958 # ffffffffc0205708 <commands+0x3f0>
ffffffffc0200ace:	ec6ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200ad2:	784c                	ld	a1,176(s0)
ffffffffc0200ad4:	00005517          	auipc	a0,0x5
ffffffffc0200ad8:	c4c50513          	addi	a0,a0,-948 # ffffffffc0205720 <commands+0x408>
ffffffffc0200adc:	eb8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200ae0:	7c4c                	ld	a1,184(s0)
ffffffffc0200ae2:	00005517          	auipc	a0,0x5
ffffffffc0200ae6:	c5650513          	addi	a0,a0,-938 # ffffffffc0205738 <commands+0x420>
ffffffffc0200aea:	eaaff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200aee:	606c                	ld	a1,192(s0)
ffffffffc0200af0:	00005517          	auipc	a0,0x5
ffffffffc0200af4:	c6050513          	addi	a0,a0,-928 # ffffffffc0205750 <commands+0x438>
ffffffffc0200af8:	e9cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200afc:	646c                	ld	a1,200(s0)
ffffffffc0200afe:	00005517          	auipc	a0,0x5
ffffffffc0200b02:	c6a50513          	addi	a0,a0,-918 # ffffffffc0205768 <commands+0x450>
ffffffffc0200b06:	e8eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b0a:	686c                	ld	a1,208(s0)
ffffffffc0200b0c:	00005517          	auipc	a0,0x5
ffffffffc0200b10:	c7450513          	addi	a0,a0,-908 # ffffffffc0205780 <commands+0x468>
ffffffffc0200b14:	e80ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b18:	6c6c                	ld	a1,216(s0)
ffffffffc0200b1a:	00005517          	auipc	a0,0x5
ffffffffc0200b1e:	c7e50513          	addi	a0,a0,-898 # ffffffffc0205798 <commands+0x480>
ffffffffc0200b22:	e72ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b26:	706c                	ld	a1,224(s0)
ffffffffc0200b28:	00005517          	auipc	a0,0x5
ffffffffc0200b2c:	c8850513          	addi	a0,a0,-888 # ffffffffc02057b0 <commands+0x498>
ffffffffc0200b30:	e64ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b34:	746c                	ld	a1,232(s0)
ffffffffc0200b36:	00005517          	auipc	a0,0x5
ffffffffc0200b3a:	c9250513          	addi	a0,a0,-878 # ffffffffc02057c8 <commands+0x4b0>
ffffffffc0200b3e:	e56ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b42:	786c                	ld	a1,240(s0)
ffffffffc0200b44:	00005517          	auipc	a0,0x5
ffffffffc0200b48:	c9c50513          	addi	a0,a0,-868 # ffffffffc02057e0 <commands+0x4c8>
ffffffffc0200b4c:	e48ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b50:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b52:	6402                	ld	s0,0(sp)
ffffffffc0200b54:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b56:	00005517          	auipc	a0,0x5
ffffffffc0200b5a:	ca250513          	addi	a0,a0,-862 # ffffffffc02057f8 <commands+0x4e0>
}
ffffffffc0200b5e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b60:	e34ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200b64 <print_trapframe>:
{
ffffffffc0200b64:	1141                	addi	sp,sp,-16
ffffffffc0200b66:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b68:	85aa                	mv	a1,a0
{
ffffffffc0200b6a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b6c:	00005517          	auipc	a0,0x5
ffffffffc0200b70:	ca450513          	addi	a0,a0,-860 # ffffffffc0205810 <commands+0x4f8>
{
ffffffffc0200b74:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b76:	e1eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200b7a:	8522                	mv	a0,s0
ffffffffc0200b7c:	e1bff0ef          	jal	ra,ffffffffc0200996 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200b80:	10043583          	ld	a1,256(s0)
ffffffffc0200b84:	00005517          	auipc	a0,0x5
ffffffffc0200b88:	ca450513          	addi	a0,a0,-860 # ffffffffc0205828 <commands+0x510>
ffffffffc0200b8c:	e08ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200b90:	10843583          	ld	a1,264(s0)
ffffffffc0200b94:	00005517          	auipc	a0,0x5
ffffffffc0200b98:	cac50513          	addi	a0,a0,-852 # ffffffffc0205840 <commands+0x528>
ffffffffc0200b9c:	df8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200ba0:	11043583          	ld	a1,272(s0)
ffffffffc0200ba4:	00005517          	auipc	a0,0x5
ffffffffc0200ba8:	cb450513          	addi	a0,a0,-844 # ffffffffc0205858 <commands+0x540>
ffffffffc0200bac:	de8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bb0:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bb4:	6402                	ld	s0,0(sp)
ffffffffc0200bb6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bb8:	00005517          	auipc	a0,0x5
ffffffffc0200bbc:	cb050513          	addi	a0,a0,-848 # ffffffffc0205868 <commands+0x550>
}
ffffffffc0200bc0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bc2:	dd2ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200bc6 <exception_handler>:
        break;
    }
}

static void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
ffffffffc0200bc6:	11853583          	ld	a1,280(a0)
static void exception_handler(struct trapframe *tf) {
ffffffffc0200bca:	1141                	addi	sp,sp,-16
ffffffffc0200bcc:	e022                	sd	s0,0(sp)
ffffffffc0200bce:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
ffffffffc0200bd0:	478d                	li	a5,3
    case 8: /* ECALL from U mode */
        tf->epc += 4;
ffffffffc0200bd2:	10853603          	ld	a2,264(a0)
static void exception_handler(struct trapframe *tf) {
ffffffffc0200bd6:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc0200bd8:	00f58f63          	beq	a1,a5,ffffffffc0200bf6 <exception_handler+0x30>
ffffffffc0200bdc:	ff858793          	addi	a5,a1,-8
ffffffffc0200be0:	4705                	li	a4,1
ffffffffc0200be2:	02f76863          	bltu	a4,a5,ffffffffc0200c12 <exception_handler+0x4c>
                tf->cause, tf->epc, tf->tval);
        print_trapframe(tf);
        if (current != NULL && !trap_in_kernel(tf)) do_exit(-E_FAULT);
        panic("unhandled kernel exception");
    }
}
ffffffffc0200be6:	6402                	ld	s0,0(sp)
ffffffffc0200be8:	60a2                	ld	ra,8(sp)
        tf->epc += 4;
ffffffffc0200bea:	0611                	addi	a2,a2,4
ffffffffc0200bec:	10c53423          	sd	a2,264(a0)
}
ffffffffc0200bf0:	0141                	addi	sp,sp,16
        syscall();
ffffffffc0200bf2:	79b0306f          	j	ffffffffc0204b8c <syscall>
        tf->epc += ((*(uint16_t *)(tf->epc) & 3) == 3) ? 4 : 2;
ffffffffc0200bf6:	00065703          	lhu	a4,0(a2) # ff0000 <_binary_obj___user_exit_out_size+0xfe4798>
ffffffffc0200bfa:	4791                	li	a5,4
ffffffffc0200bfc:	8b0d                	andi	a4,a4,3
ffffffffc0200bfe:	00b70363          	beq	a4,a1,ffffffffc0200c04 <exception_handler+0x3e>
ffffffffc0200c02:	4789                	li	a5,2
ffffffffc0200c04:	963e                	add	a2,a2,a5
}
ffffffffc0200c06:	60a2                	ld	ra,8(sp)
        tf->epc += ((*(uint16_t *)(tf->epc) & 3) == 3) ? 4 : 2;
ffffffffc0200c08:	10c43423          	sd	a2,264(s0)
}
ffffffffc0200c0c:	6402                	ld	s0,0(sp)
ffffffffc0200c0e:	0141                	addi	sp,sp,16
ffffffffc0200c10:	8082                	ret
        cprintf("unhandled exception: cause=%lx epc=%lx tval=%lx\n",
ffffffffc0200c12:	11053683          	ld	a3,272(a0)
ffffffffc0200c16:	00005517          	auipc	a0,0x5
ffffffffc0200c1a:	c6a50513          	addi	a0,a0,-918 # ffffffffc0205880 <commands+0x568>
ffffffffc0200c1e:	d76ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        print_trapframe(tf);
ffffffffc0200c22:	8522                	mv	a0,s0
ffffffffc0200c24:	f41ff0ef          	jal	ra,ffffffffc0200b64 <print_trapframe>
        if (current != NULL && !trap_in_kernel(tf)) do_exit(-E_FAULT);
ffffffffc0200c28:	000b0797          	auipc	a5,0xb0
ffffffffc0200c2c:	af07b783          	ld	a5,-1296(a5) # ffffffffc02b0718 <current>
ffffffffc0200c30:	c791                	beqz	a5,ffffffffc0200c3c <exception_handler+0x76>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c32:	10043783          	ld	a5,256(s0)
ffffffffc0200c36:	1007f793          	andi	a5,a5,256
        if (current != NULL && !trap_in_kernel(tf)) do_exit(-E_FAULT);
ffffffffc0200c3a:	cf89                	beqz	a5,ffffffffc0200c54 <exception_handler+0x8e>
        panic("unhandled kernel exception");
ffffffffc0200c3c:	00005617          	auipc	a2,0x5
ffffffffc0200c40:	c7c60613          	addi	a2,a2,-900 # ffffffffc02058b8 <commands+0x5a0>
ffffffffc0200c44:	08200593          	li	a1,130
ffffffffc0200c48:	00005517          	auipc	a0,0x5
ffffffffc0200c4c:	c9050513          	addi	a0,a0,-880 # ffffffffc02058d8 <commands+0x5c0>
ffffffffc0200c50:	ffeff0ef          	jal	ra,ffffffffc020044e <__panic>
        if (current != NULL && !trap_in_kernel(tf)) do_exit(-E_FAULT);
ffffffffc0200c54:	5569                	li	a0,-6
ffffffffc0200c56:	238030ef          	jal	ra,ffffffffc0203e8e <do_exit>
ffffffffc0200c5a:	b7cd                	j	ffffffffc0200c3c <exception_handler+0x76>

ffffffffc0200c5c <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
ffffffffc0200c5c:	1101                	addi	sp,sp,-32
ffffffffc0200c5e:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200c60:	000b0417          	auipc	s0,0xb0
ffffffffc0200c64:	ab840413          	addi	s0,s0,-1352 # ffffffffc02b0718 <current>
ffffffffc0200c68:	6018                	ld	a4,0(s0)
{
ffffffffc0200c6a:	ec06                	sd	ra,24(sp)
ffffffffc0200c6c:	e426                	sd	s1,8(sp)
ffffffffc0200c6e:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200c70:	11853583          	ld	a1,280(a0)
    if (current == NULL)
ffffffffc0200c74:	cb31                	beqz	a4,ffffffffc0200cc8 <trap+0x6c>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c76:	10053483          	ld	s1,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200c7a:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c7e:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c80:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0)
ffffffffc0200c84:	0205c463          	bltz	a1,ffffffffc0200cac <trap+0x50>
        exception_handler(tf);
ffffffffc0200c88:	f3fff0ef          	jal	ra,ffffffffc0200bc6 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c8c:	601c                	ld	a5,0(s0)
ffffffffc0200c8e:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel)
ffffffffc0200c92:	e499                	bnez	s1,ffffffffc0200ca0 <trap+0x44>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200c94:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c98:	8b05                	andi	a4,a4,1
ffffffffc0200c9a:	ef35                	bnez	a4,ffffffffc0200d16 <trap+0xba>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200c9c:	6f9c                	ld	a5,24(a5)
ffffffffc0200c9e:	e7ad                	bnez	a5,ffffffffc0200d08 <trap+0xac>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200ca0:	60e2                	ld	ra,24(sp)
ffffffffc0200ca2:	6442                	ld	s0,16(sp)
ffffffffc0200ca4:	64a2                	ld	s1,8(sp)
ffffffffc0200ca6:	6902                	ld	s2,0(sp)
ffffffffc0200ca8:	6105                	addi	sp,sp,32
ffffffffc0200caa:	8082                	ret
    switch ((uint64_t)tf->cause & 0x7fffffffffffffffUL) {
ffffffffc0200cac:	00159793          	slli	a5,a1,0x1
ffffffffc0200cb0:	8385                	srli	a5,a5,0x1
ffffffffc0200cb2:	4715                	li	a4,5
ffffffffc0200cb4:	04e78363          	beq	a5,a4,ffffffffc0200cfa <trap+0x9e>
        cprintf("unexpected interrupt: cause=%lx\n", tf->cause);
ffffffffc0200cb8:	00005517          	auipc	a0,0x5
ffffffffc0200cbc:	c3850513          	addi	a0,a0,-968 # ffffffffc02058f0 <commands+0x5d8>
ffffffffc0200cc0:	cd4ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        current->tf = otf;
ffffffffc0200cc4:	601c                	ld	a5,0(s0)
        break;
ffffffffc0200cc6:	b7e1                	j	ffffffffc0200c8e <trap+0x32>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200cc8:	0005c863          	bltz	a1,ffffffffc0200cd8 <trap+0x7c>
}
ffffffffc0200ccc:	6442                	ld	s0,16(sp)
ffffffffc0200cce:	60e2                	ld	ra,24(sp)
ffffffffc0200cd0:	64a2                	ld	s1,8(sp)
ffffffffc0200cd2:	6902                	ld	s2,0(sp)
ffffffffc0200cd4:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cd6:	bdc5                	j	ffffffffc0200bc6 <exception_handler>
    switch ((uint64_t)tf->cause & 0x7fffffffffffffffUL) {
ffffffffc0200cd8:	00159793          	slli	a5,a1,0x1
ffffffffc0200cdc:	8385                	srli	a5,a5,0x1
ffffffffc0200cde:	4715                	li	a4,5
ffffffffc0200ce0:	04e78063          	beq	a5,a4,ffffffffc0200d20 <trap+0xc4>
}
ffffffffc0200ce4:	6442                	ld	s0,16(sp)
ffffffffc0200ce6:	60e2                	ld	ra,24(sp)
ffffffffc0200ce8:	64a2                	ld	s1,8(sp)
ffffffffc0200cea:	6902                	ld	s2,0(sp)
        cprintf("unexpected interrupt: cause=%lx\n", tf->cause);
ffffffffc0200cec:	00005517          	auipc	a0,0x5
ffffffffc0200cf0:	c0450513          	addi	a0,a0,-1020 # ffffffffc02058f0 <commands+0x5d8>
}
ffffffffc0200cf4:	6105                	addi	sp,sp,32
        cprintf("unexpected interrupt: cause=%lx\n", tf->cause);
ffffffffc0200cf6:	c9eff06f          	j	ffffffffc0200194 <cprintf>
        clock_set_next_event();
ffffffffc0200cfa:	839ff0ef          	jal	ra,ffffffffc0200532 <clock_set_next_event>
        if (current != NULL) current->need_resched = 1;
ffffffffc0200cfe:	601c                	ld	a5,0(s0)
ffffffffc0200d00:	d7d9                	beqz	a5,ffffffffc0200c8e <trap+0x32>
ffffffffc0200d02:	4705                	li	a4,1
ffffffffc0200d04:	ef98                	sd	a4,24(a5)
ffffffffc0200d06:	b761                	j	ffffffffc0200c8e <trap+0x32>
}
ffffffffc0200d08:	6442                	ld	s0,16(sp)
ffffffffc0200d0a:	60e2                	ld	ra,24(sp)
ffffffffc0200d0c:	64a2                	ld	s1,8(sp)
ffffffffc0200d0e:	6902                	ld	s2,0(sp)
ffffffffc0200d10:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200d12:	5850306f          	j	ffffffffc0204a96 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200d16:	555d                	li	a0,-9
ffffffffc0200d18:	176030ef          	jal	ra,ffffffffc0203e8e <do_exit>
            if (current->need_resched)
ffffffffc0200d1c:	601c                	ld	a5,0(s0)
ffffffffc0200d1e:	bfbd                	j	ffffffffc0200c9c <trap+0x40>
        clock_set_next_event();
ffffffffc0200d20:	813ff0ef          	jal	ra,ffffffffc0200532 <clock_set_next_event>
        if (current != NULL) current->need_resched = 1;
ffffffffc0200d24:	601c                	ld	a5,0(s0)
ffffffffc0200d26:	dfad                	beqz	a5,ffffffffc0200ca0 <trap+0x44>
ffffffffc0200d28:	4705                	li	a4,1
ffffffffc0200d2a:	ef98                	sd	a4,24(a5)
ffffffffc0200d2c:	bf95                	j	ffffffffc0200ca0 <trap+0x44>
	...

ffffffffc0200d30 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200d30:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200d34:	00011463          	bnez	sp,ffffffffc0200d3c <__alltraps+0xc>
ffffffffc0200d38:	14002173          	csrr	sp,sscratch
ffffffffc0200d3c:	712d                	addi	sp,sp,-288
ffffffffc0200d3e:	e002                	sd	zero,0(sp)
ffffffffc0200d40:	e406                	sd	ra,8(sp)
ffffffffc0200d42:	ec0e                	sd	gp,24(sp)
ffffffffc0200d44:	f012                	sd	tp,32(sp)
ffffffffc0200d46:	f416                	sd	t0,40(sp)
ffffffffc0200d48:	f81a                	sd	t1,48(sp)
ffffffffc0200d4a:	fc1e                	sd	t2,56(sp)
ffffffffc0200d4c:	e0a2                	sd	s0,64(sp)
ffffffffc0200d4e:	e4a6                	sd	s1,72(sp)
ffffffffc0200d50:	e8aa                	sd	a0,80(sp)
ffffffffc0200d52:	ecae                	sd	a1,88(sp)
ffffffffc0200d54:	f0b2                	sd	a2,96(sp)
ffffffffc0200d56:	f4b6                	sd	a3,104(sp)
ffffffffc0200d58:	f8ba                	sd	a4,112(sp)
ffffffffc0200d5a:	fcbe                	sd	a5,120(sp)
ffffffffc0200d5c:	e142                	sd	a6,128(sp)
ffffffffc0200d5e:	e546                	sd	a7,136(sp)
ffffffffc0200d60:	e94a                	sd	s2,144(sp)
ffffffffc0200d62:	ed4e                	sd	s3,152(sp)
ffffffffc0200d64:	f152                	sd	s4,160(sp)
ffffffffc0200d66:	f556                	sd	s5,168(sp)
ffffffffc0200d68:	f95a                	sd	s6,176(sp)
ffffffffc0200d6a:	fd5e                	sd	s7,184(sp)
ffffffffc0200d6c:	e1e2                	sd	s8,192(sp)
ffffffffc0200d6e:	e5e6                	sd	s9,200(sp)
ffffffffc0200d70:	e9ea                	sd	s10,208(sp)
ffffffffc0200d72:	edee                	sd	s11,216(sp)
ffffffffc0200d74:	f1f2                	sd	t3,224(sp)
ffffffffc0200d76:	f5f6                	sd	t4,232(sp)
ffffffffc0200d78:	f9fa                	sd	t5,240(sp)
ffffffffc0200d7a:	fdfe                	sd	t6,248(sp)
ffffffffc0200d7c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d80:	100024f3          	csrr	s1,sstatus
ffffffffc0200d84:	14102973          	csrr	s2,sepc
ffffffffc0200d88:	143029f3          	csrr	s3,stval
ffffffffc0200d8c:	14202a73          	csrr	s4,scause
ffffffffc0200d90:	e011                	bnez	s0,ffffffffc0200d94 <__alltraps+0x64>
ffffffffc0200d92:	1200                	addi	s0,sp,288
ffffffffc0200d94:	e822                	sd	s0,16(sp)
ffffffffc0200d96:	e226                	sd	s1,256(sp)
ffffffffc0200d98:	e64a                	sd	s2,264(sp)
ffffffffc0200d9a:	ea4e                	sd	s3,272(sp)
ffffffffc0200d9c:	ee52                	sd	s4,280(sp)

    mv a0, sp
ffffffffc0200d9e:	850a                	mv	a0,sp
    call trap
ffffffffc0200da0:	ebdff0ef          	jal	ra,ffffffffc0200c5c <trap>

ffffffffc0200da4 <__trapret>:

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200da4:	6292                	ld	t0,256(sp)
ffffffffc0200da6:	6332                	ld	t1,264(sp)
ffffffffc0200da8:	10029073          	csrw	sstatus,t0
ffffffffc0200dac:	14131073          	csrw	sepc,t1
ffffffffc0200db0:	1002f313          	andi	t1,t0,256
ffffffffc0200db4:	00031763          	bnez	t1,ffffffffc0200dc2 <__trapret+0x1e>
ffffffffc0200db8:	12010313          	addi	t1,sp,288
ffffffffc0200dbc:	14031073          	csrw	sscratch,t1
ffffffffc0200dc0:	a019                	j	ffffffffc0200dc6 <__trapret+0x22>
ffffffffc0200dc2:	14001073          	csrw	sscratch,zero
ffffffffc0200dc6:	60a2                	ld	ra,8(sp)
ffffffffc0200dc8:	61e2                	ld	gp,24(sp)
ffffffffc0200dca:	7202                	ld	tp,32(sp)
ffffffffc0200dcc:	72a2                	ld	t0,40(sp)
ffffffffc0200dce:	7342                	ld	t1,48(sp)
ffffffffc0200dd0:	73e2                	ld	t2,56(sp)
ffffffffc0200dd2:	6406                	ld	s0,64(sp)
ffffffffc0200dd4:	64a6                	ld	s1,72(sp)
ffffffffc0200dd6:	6546                	ld	a0,80(sp)
ffffffffc0200dd8:	65e6                	ld	a1,88(sp)
ffffffffc0200dda:	7606                	ld	a2,96(sp)
ffffffffc0200ddc:	76a6                	ld	a3,104(sp)
ffffffffc0200dde:	7746                	ld	a4,112(sp)
ffffffffc0200de0:	77e6                	ld	a5,120(sp)
ffffffffc0200de2:	680a                	ld	a6,128(sp)
ffffffffc0200de4:	68aa                	ld	a7,136(sp)
ffffffffc0200de6:	694a                	ld	s2,144(sp)
ffffffffc0200de8:	69ea                	ld	s3,152(sp)
ffffffffc0200dea:	7a0a                	ld	s4,160(sp)
ffffffffc0200dec:	7aaa                	ld	s5,168(sp)
ffffffffc0200dee:	7b4a                	ld	s6,176(sp)
ffffffffc0200df0:	7bea                	ld	s7,184(sp)
ffffffffc0200df2:	6c0e                	ld	s8,192(sp)
ffffffffc0200df4:	6cae                	ld	s9,200(sp)
ffffffffc0200df6:	6d4e                	ld	s10,208(sp)
ffffffffc0200df8:	6dee                	ld	s11,216(sp)
ffffffffc0200dfa:	7e0e                	ld	t3,224(sp)
ffffffffc0200dfc:	7eae                	ld	t4,232(sp)
ffffffffc0200dfe:	7f4e                	ld	t5,240(sp)
ffffffffc0200e00:	7fee                	ld	t6,248(sp)
ffffffffc0200e02:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200e04:	10200073          	sret

ffffffffc0200e08 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200e08:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200e0a:	bf69                	j	ffffffffc0200da4 <__trapret>
	...

ffffffffc0200e0e <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e0e:	000ac797          	auipc	a5,0xac
ffffffffc0200e12:	88278793          	addi	a5,a5,-1918 # ffffffffc02ac690 <free_area>
ffffffffc0200e16:	e79c                	sd	a5,8(a5)
ffffffffc0200e18:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e1a:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e1e:	8082                	ret

ffffffffc0200e20 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e20:	000ac517          	auipc	a0,0xac
ffffffffc0200e24:	88056503          	lwu	a0,-1920(a0) # ffffffffc02ac6a0 <free_area+0x10>
ffffffffc0200e28:	8082                	ret

ffffffffc0200e2a <basic_check>:



// Framework tests: students must not modify basic_check or best_fit_check.
static void
basic_check(void) {
ffffffffc0200e2a:	715d                	addi	sp,sp,-80
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e2c:	4505                	li	a0,1
basic_check(void) {
ffffffffc0200e2e:	e486                	sd	ra,72(sp)
ffffffffc0200e30:	e0a2                	sd	s0,64(sp)
ffffffffc0200e32:	fc26                	sd	s1,56(sp)
ffffffffc0200e34:	f84a                	sd	s2,48(sp)
ffffffffc0200e36:	f44e                	sd	s3,40(sp)
ffffffffc0200e38:	f052                	sd	s4,32(sp)
ffffffffc0200e3a:	ec56                	sd	s5,24(sp)
ffffffffc0200e3c:	e85a                	sd	s6,16(sp)
ffffffffc0200e3e:	e45e                	sd	s7,8(sp)
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e40:	2ad000ef          	jal	ra,ffffffffc02018ec <alloc_pages>
ffffffffc0200e44:	2a050d63          	beqz	a0,ffffffffc02010fe <basic_check+0x2d4>
ffffffffc0200e48:	84aa                	mv	s1,a0
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e4a:	4505                	li	a0,1
ffffffffc0200e4c:	2a1000ef          	jal	ra,ffffffffc02018ec <alloc_pages>
ffffffffc0200e50:	892a                	mv	s2,a0
ffffffffc0200e52:	28050663          	beqz	a0,ffffffffc02010de <basic_check+0x2b4>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e56:	4505                	li	a0,1
ffffffffc0200e58:	295000ef          	jal	ra,ffffffffc02018ec <alloc_pages>
ffffffffc0200e5c:	89aa                	mv	s3,a0
ffffffffc0200e5e:	1e050063          	beqz	a0,ffffffffc020103e <basic_check+0x214>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e62:	13248e63          	beq	s1,s2,ffffffffc0200f9e <basic_check+0x174>
ffffffffc0200e66:	12a48c63          	beq	s1,a0,ffffffffc0200f9e <basic_check+0x174>
ffffffffc0200e6a:	12a90a63          	beq	s2,a0,ffffffffc0200f9e <basic_check+0x174>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e6e:	409c                	lw	a5,0(s1)
ffffffffc0200e70:	14079763          	bnez	a5,ffffffffc0200fbe <basic_check+0x194>
ffffffffc0200e74:	00092783          	lw	a5,0(s2)
ffffffffc0200e78:	14079363          	bnez	a5,ffffffffc0200fbe <basic_check+0x194>
ffffffffc0200e7c:	411c                	lw	a5,0(a0)
ffffffffc0200e7e:	14079063          	bnez	a5,ffffffffc0200fbe <basic_check+0x194>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc0200e82:	000b0797          	auipc	a5,0xb0
ffffffffc0200e86:	87e7b783          	ld	a5,-1922(a5) # ffffffffc02b0700 <pages>
ffffffffc0200e8a:	40f48733          	sub	a4,s1,a5
ffffffffc0200e8e:	00006617          	auipc	a2,0x6
ffffffffc0200e92:	0f263603          	ld	a2,242(a2) # ffffffffc0206f80 <nbase>
ffffffffc0200e96:	8719                	srai	a4,a4,0x6
ffffffffc0200e98:	9732                	add	a4,a4,a2

    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e9a:	000b0697          	auipc	a3,0xb0
ffffffffc0200e9e:	85e6b683          	ld	a3,-1954(a3) # ffffffffc02b06f8 <npage>
ffffffffc0200ea2:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ea4:	0732                	slli	a4,a4,0xc
ffffffffc0200ea6:	20d77c63          	bgeu	a4,a3,ffffffffc02010be <basic_check+0x294>
    return page - pages + nbase;
ffffffffc0200eaa:	40f90733          	sub	a4,s2,a5
ffffffffc0200eae:	8719                	srai	a4,a4,0x6
ffffffffc0200eb0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200eb2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200eb4:	30d77563          	bgeu	a4,a3,ffffffffc02011be <basic_check+0x394>
    return page - pages + nbase;
ffffffffc0200eb8:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ebc:	8799                	srai	a5,a5,0x6
ffffffffc0200ebe:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ec0:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ec2:	14d7fe63          	bgeu	a5,a3,ffffffffc020101e <basic_check+0x1f4>

    list_entry_t free_list_store = free_list;
ffffffffc0200ec6:	000ab417          	auipc	s0,0xab
ffffffffc0200eca:	7ca40413          	addi	s0,s0,1994 # ffffffffc02ac690 <free_area>
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);
ffffffffc0200ece:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ed0:	00043b83          	ld	s7,0(s0)
ffffffffc0200ed4:	00843b03          	ld	s6,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200ed8:	01042a83          	lw	s5,16(s0)
ffffffffc0200edc:	e400                	sd	s0,8(s0)
ffffffffc0200ede:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200ee0:	000ab797          	auipc	a5,0xab
ffffffffc0200ee4:	7c07a023          	sw	zero,1984(a5) # ffffffffc02ac6a0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200ee8:	205000ef          	jal	ra,ffffffffc02018ec <alloc_pages>
ffffffffc0200eec:	0e051963          	bnez	a0,ffffffffc0200fde <basic_check+0x1b4>

    free_page(p0);
ffffffffc0200ef0:	4585                	li	a1,1
ffffffffc0200ef2:	8526                	mv	a0,s1
ffffffffc0200ef4:	237000ef          	jal	ra,ffffffffc020192a <free_pages>
    free_page(p1);
ffffffffc0200ef8:	4585                	li	a1,1
ffffffffc0200efa:	854a                	mv	a0,s2
ffffffffc0200efc:	22f000ef          	jal	ra,ffffffffc020192a <free_pages>
    free_page(p2);
ffffffffc0200f00:	4585                	li	a1,1
ffffffffc0200f02:	854e                	mv	a0,s3
ffffffffc0200f04:	227000ef          	jal	ra,ffffffffc020192a <free_pages>
    assert(nr_free == 3);
ffffffffc0200f08:	4818                	lw	a4,16(s0)
ffffffffc0200f0a:	478d                	li	a5,3
ffffffffc0200f0c:	18f71963          	bne	a4,a5,ffffffffc020109e <basic_check+0x274>

    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f10:	4505                	li	a0,1
ffffffffc0200f12:	1db000ef          	jal	ra,ffffffffc02018ec <alloc_pages>
ffffffffc0200f16:	84aa                	mv	s1,a0
ffffffffc0200f18:	16050363          	beqz	a0,ffffffffc020107e <basic_check+0x254>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f1c:	4505                	li	a0,1
ffffffffc0200f1e:	1cf000ef          	jal	ra,ffffffffc02018ec <alloc_pages>
ffffffffc0200f22:	892a                	mv	s2,a0
ffffffffc0200f24:	12050d63          	beqz	a0,ffffffffc020105e <basic_check+0x234>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f28:	4505                	li	a0,1
ffffffffc0200f2a:	1c3000ef          	jal	ra,ffffffffc02018ec <alloc_pages>
ffffffffc0200f2e:	89aa                	mv	s3,a0
ffffffffc0200f30:	c579                	beqz	a0,ffffffffc0200ffe <basic_check+0x1d4>

    assert(alloc_page() == NULL);
ffffffffc0200f32:	4505                	li	a0,1
ffffffffc0200f34:	1b9000ef          	jal	ra,ffffffffc02018ec <alloc_pages>
ffffffffc0200f38:	26051363          	bnez	a0,ffffffffc020119e <basic_check+0x374>

    free_page(p0);
ffffffffc0200f3c:	4585                	li	a1,1
ffffffffc0200f3e:	8526                	mv	a0,s1
ffffffffc0200f40:	1eb000ef          	jal	ra,ffffffffc020192a <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200f44:	641c                	ld	a5,8(s0)
ffffffffc0200f46:	22878c63          	beq	a5,s0,ffffffffc020117e <basic_check+0x354>

    struct Page *p;
    assert((p = alloc_page()) == p0);
ffffffffc0200f4a:	4505                	li	a0,1
ffffffffc0200f4c:	1a1000ef          	jal	ra,ffffffffc02018ec <alloc_pages>
ffffffffc0200f50:	8a2a                	mv	s4,a0
ffffffffc0200f52:	20a49663          	bne	s1,a0,ffffffffc020115e <basic_check+0x334>
    assert(alloc_page() == NULL);
ffffffffc0200f56:	4505                	li	a0,1
ffffffffc0200f58:	195000ef          	jal	ra,ffffffffc02018ec <alloc_pages>
ffffffffc0200f5c:	1e051163          	bnez	a0,ffffffffc020113e <basic_check+0x314>

    assert(nr_free == 0);
ffffffffc0200f60:	481c                	lw	a5,16(s0)
ffffffffc0200f62:	1a079e63          	bnez	a5,ffffffffc020111e <basic_check+0x2f4>
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
ffffffffc0200f66:	8552                	mv	a0,s4
ffffffffc0200f68:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200f6a:	01743023          	sd	s7,0(s0)
ffffffffc0200f6e:	01643423          	sd	s6,8(s0)
    nr_free = nr_free_store;
ffffffffc0200f72:	01542823          	sw	s5,16(s0)
    free_page(p);
ffffffffc0200f76:	1b5000ef          	jal	ra,ffffffffc020192a <free_pages>
    free_page(p1);
ffffffffc0200f7a:	854a                	mv	a0,s2
ffffffffc0200f7c:	4585                	li	a1,1
ffffffffc0200f7e:	1ad000ef          	jal	ra,ffffffffc020192a <free_pages>
    free_page(p2);
}
ffffffffc0200f82:	6406                	ld	s0,64(sp)
ffffffffc0200f84:	60a6                	ld	ra,72(sp)
ffffffffc0200f86:	74e2                	ld	s1,56(sp)
ffffffffc0200f88:	7942                	ld	s2,48(sp)
ffffffffc0200f8a:	7a02                	ld	s4,32(sp)
ffffffffc0200f8c:	6ae2                	ld	s5,24(sp)
ffffffffc0200f8e:	6b42                	ld	s6,16(sp)
ffffffffc0200f90:	6ba2                	ld	s7,8(sp)
    free_page(p2);
ffffffffc0200f92:	854e                	mv	a0,s3
}
ffffffffc0200f94:	79a2                	ld	s3,40(sp)
    free_page(p2);
ffffffffc0200f96:	4585                	li	a1,1
}
ffffffffc0200f98:	6161                	addi	sp,sp,80
    free_page(p2);
ffffffffc0200f9a:	1910006f          	j	ffffffffc020192a <free_pages>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200f9e:	00005697          	auipc	a3,0x5
ffffffffc0200fa2:	a0a68693          	addi	a3,a3,-1526 # ffffffffc02059a8 <commands+0x690>
ffffffffc0200fa6:	00005617          	auipc	a2,0x5
ffffffffc0200faa:	99260613          	addi	a2,a2,-1646 # ffffffffc0205938 <commands+0x620>
ffffffffc0200fae:	08f00593          	li	a1,143
ffffffffc0200fb2:	00005517          	auipc	a0,0x5
ffffffffc0200fb6:	99e50513          	addi	a0,a0,-1634 # ffffffffc0205950 <commands+0x638>
ffffffffc0200fba:	c94ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200fbe:	00005697          	auipc	a3,0x5
ffffffffc0200fc2:	a1268693          	addi	a3,a3,-1518 # ffffffffc02059d0 <commands+0x6b8>
ffffffffc0200fc6:	00005617          	auipc	a2,0x5
ffffffffc0200fca:	97260613          	addi	a2,a2,-1678 # ffffffffc0205938 <commands+0x620>
ffffffffc0200fce:	09000593          	li	a1,144
ffffffffc0200fd2:	00005517          	auipc	a0,0x5
ffffffffc0200fd6:	97e50513          	addi	a0,a0,-1666 # ffffffffc0205950 <commands+0x638>
ffffffffc0200fda:	c74ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fde:	00005697          	auipc	a3,0x5
ffffffffc0200fe2:	a9268693          	addi	a3,a3,-1390 # ffffffffc0205a70 <commands+0x758>
ffffffffc0200fe6:	00005617          	auipc	a2,0x5
ffffffffc0200fea:	95260613          	addi	a2,a2,-1710 # ffffffffc0205938 <commands+0x620>
ffffffffc0200fee:	09d00593          	li	a1,157
ffffffffc0200ff2:	00005517          	auipc	a0,0x5
ffffffffc0200ff6:	95e50513          	addi	a0,a0,-1698 # ffffffffc0205950 <commands+0x638>
ffffffffc0200ffa:	c54ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ffe:	00005697          	auipc	a3,0x5
ffffffffc0201002:	98a68693          	addi	a3,a3,-1654 # ffffffffc0205988 <commands+0x670>
ffffffffc0201006:	00005617          	auipc	a2,0x5
ffffffffc020100a:	93260613          	addi	a2,a2,-1742 # ffffffffc0205938 <commands+0x620>
ffffffffc020100e:	0a600593          	li	a1,166
ffffffffc0201012:	00005517          	auipc	a0,0x5
ffffffffc0201016:	93e50513          	addi	a0,a0,-1730 # ffffffffc0205950 <commands+0x638>
ffffffffc020101a:	c34ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020101e:	00005697          	auipc	a3,0x5
ffffffffc0201022:	a3268693          	addi	a3,a3,-1486 # ffffffffc0205a50 <commands+0x738>
ffffffffc0201026:	00005617          	auipc	a2,0x5
ffffffffc020102a:	91260613          	addi	a2,a2,-1774 # ffffffffc0205938 <commands+0x620>
ffffffffc020102e:	09400593          	li	a1,148
ffffffffc0201032:	00005517          	auipc	a0,0x5
ffffffffc0201036:	91e50513          	addi	a0,a0,-1762 # ffffffffc0205950 <commands+0x638>
ffffffffc020103a:	c14ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020103e:	00005697          	auipc	a3,0x5
ffffffffc0201042:	94a68693          	addi	a3,a3,-1718 # ffffffffc0205988 <commands+0x670>
ffffffffc0201046:	00005617          	auipc	a2,0x5
ffffffffc020104a:	8f260613          	addi	a2,a2,-1806 # ffffffffc0205938 <commands+0x620>
ffffffffc020104e:	08d00593          	li	a1,141
ffffffffc0201052:	00005517          	auipc	a0,0x5
ffffffffc0201056:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0205950 <commands+0x638>
ffffffffc020105a:	bf4ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020105e:	00005697          	auipc	a3,0x5
ffffffffc0201062:	90a68693          	addi	a3,a3,-1782 # ffffffffc0205968 <commands+0x650>
ffffffffc0201066:	00005617          	auipc	a2,0x5
ffffffffc020106a:	8d260613          	addi	a2,a2,-1838 # ffffffffc0205938 <commands+0x620>
ffffffffc020106e:	0a500593          	li	a1,165
ffffffffc0201072:	00005517          	auipc	a0,0x5
ffffffffc0201076:	8de50513          	addi	a0,a0,-1826 # ffffffffc0205950 <commands+0x638>
ffffffffc020107a:	bd4ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020107e:	00005697          	auipc	a3,0x5
ffffffffc0201082:	89a68693          	addi	a3,a3,-1894 # ffffffffc0205918 <commands+0x600>
ffffffffc0201086:	00005617          	auipc	a2,0x5
ffffffffc020108a:	8b260613          	addi	a2,a2,-1870 # ffffffffc0205938 <commands+0x620>
ffffffffc020108e:	0a400593          	li	a1,164
ffffffffc0201092:	00005517          	auipc	a0,0x5
ffffffffc0201096:	8be50513          	addi	a0,a0,-1858 # ffffffffc0205950 <commands+0x638>
ffffffffc020109a:	bb4ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(nr_free == 3);
ffffffffc020109e:	00005697          	auipc	a3,0x5
ffffffffc02010a2:	9ea68693          	addi	a3,a3,-1558 # ffffffffc0205a88 <commands+0x770>
ffffffffc02010a6:	00005617          	auipc	a2,0x5
ffffffffc02010aa:	89260613          	addi	a2,a2,-1902 # ffffffffc0205938 <commands+0x620>
ffffffffc02010ae:	0a200593          	li	a1,162
ffffffffc02010b2:	00005517          	auipc	a0,0x5
ffffffffc02010b6:	89e50513          	addi	a0,a0,-1890 # ffffffffc0205950 <commands+0x638>
ffffffffc02010ba:	b94ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02010be:	00005697          	auipc	a3,0x5
ffffffffc02010c2:	95268693          	addi	a3,a3,-1710 # ffffffffc0205a10 <commands+0x6f8>
ffffffffc02010c6:	00005617          	auipc	a2,0x5
ffffffffc02010ca:	87260613          	addi	a2,a2,-1934 # ffffffffc0205938 <commands+0x620>
ffffffffc02010ce:	09200593          	li	a1,146
ffffffffc02010d2:	00005517          	auipc	a0,0x5
ffffffffc02010d6:	87e50513          	addi	a0,a0,-1922 # ffffffffc0205950 <commands+0x638>
ffffffffc02010da:	b74ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02010de:	00005697          	auipc	a3,0x5
ffffffffc02010e2:	88a68693          	addi	a3,a3,-1910 # ffffffffc0205968 <commands+0x650>
ffffffffc02010e6:	00005617          	auipc	a2,0x5
ffffffffc02010ea:	85260613          	addi	a2,a2,-1966 # ffffffffc0205938 <commands+0x620>
ffffffffc02010ee:	08c00593          	li	a1,140
ffffffffc02010f2:	00005517          	auipc	a0,0x5
ffffffffc02010f6:	85e50513          	addi	a0,a0,-1954 # ffffffffc0205950 <commands+0x638>
ffffffffc02010fa:	b54ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02010fe:	00005697          	auipc	a3,0x5
ffffffffc0201102:	81a68693          	addi	a3,a3,-2022 # ffffffffc0205918 <commands+0x600>
ffffffffc0201106:	00005617          	auipc	a2,0x5
ffffffffc020110a:	83260613          	addi	a2,a2,-1998 # ffffffffc0205938 <commands+0x620>
ffffffffc020110e:	08b00593          	li	a1,139
ffffffffc0201112:	00005517          	auipc	a0,0x5
ffffffffc0201116:	83e50513          	addi	a0,a0,-1986 # ffffffffc0205950 <commands+0x638>
ffffffffc020111a:	b34ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(nr_free == 0);
ffffffffc020111e:	00005697          	auipc	a3,0x5
ffffffffc0201122:	9b268693          	addi	a3,a3,-1614 # ffffffffc0205ad0 <commands+0x7b8>
ffffffffc0201126:	00005617          	auipc	a2,0x5
ffffffffc020112a:	81260613          	addi	a2,a2,-2030 # ffffffffc0205938 <commands+0x620>
ffffffffc020112e:	0b100593          	li	a1,177
ffffffffc0201132:	00005517          	auipc	a0,0x5
ffffffffc0201136:	81e50513          	addi	a0,a0,-2018 # ffffffffc0205950 <commands+0x638>
ffffffffc020113a:	b14ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(alloc_page() == NULL);
ffffffffc020113e:	00005697          	auipc	a3,0x5
ffffffffc0201142:	93268693          	addi	a3,a3,-1742 # ffffffffc0205a70 <commands+0x758>
ffffffffc0201146:	00004617          	auipc	a2,0x4
ffffffffc020114a:	7f260613          	addi	a2,a2,2034 # ffffffffc0205938 <commands+0x620>
ffffffffc020114e:	0af00593          	li	a1,175
ffffffffc0201152:	00004517          	auipc	a0,0x4
ffffffffc0201156:	7fe50513          	addi	a0,a0,2046 # ffffffffc0205950 <commands+0x638>
ffffffffc020115a:	af4ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020115e:	00005697          	auipc	a3,0x5
ffffffffc0201162:	95268693          	addi	a3,a3,-1710 # ffffffffc0205ab0 <commands+0x798>
ffffffffc0201166:	00004617          	auipc	a2,0x4
ffffffffc020116a:	7d260613          	addi	a2,a2,2002 # ffffffffc0205938 <commands+0x620>
ffffffffc020116e:	0ae00593          	li	a1,174
ffffffffc0201172:	00004517          	auipc	a0,0x4
ffffffffc0201176:	7de50513          	addi	a0,a0,2014 # ffffffffc0205950 <commands+0x638>
ffffffffc020117a:	ad4ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(!list_empty(&free_list));
ffffffffc020117e:	00005697          	auipc	a3,0x5
ffffffffc0201182:	91a68693          	addi	a3,a3,-1766 # ffffffffc0205a98 <commands+0x780>
ffffffffc0201186:	00004617          	auipc	a2,0x4
ffffffffc020118a:	7b260613          	addi	a2,a2,1970 # ffffffffc0205938 <commands+0x620>
ffffffffc020118e:	0ab00593          	li	a1,171
ffffffffc0201192:	00004517          	auipc	a0,0x4
ffffffffc0201196:	7be50513          	addi	a0,a0,1982 # ffffffffc0205950 <commands+0x638>
ffffffffc020119a:	ab4ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(alloc_page() == NULL);
ffffffffc020119e:	00005697          	auipc	a3,0x5
ffffffffc02011a2:	8d268693          	addi	a3,a3,-1838 # ffffffffc0205a70 <commands+0x758>
ffffffffc02011a6:	00004617          	auipc	a2,0x4
ffffffffc02011aa:	79260613          	addi	a2,a2,1938 # ffffffffc0205938 <commands+0x620>
ffffffffc02011ae:	0a800593          	li	a1,168
ffffffffc02011b2:	00004517          	auipc	a0,0x4
ffffffffc02011b6:	79e50513          	addi	a0,a0,1950 # ffffffffc0205950 <commands+0x638>
ffffffffc02011ba:	a94ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02011be:	00005697          	auipc	a3,0x5
ffffffffc02011c2:	87268693          	addi	a3,a3,-1934 # ffffffffc0205a30 <commands+0x718>
ffffffffc02011c6:	00004617          	auipc	a2,0x4
ffffffffc02011ca:	77260613          	addi	a2,a2,1906 # ffffffffc0205938 <commands+0x620>
ffffffffc02011ce:	09300593          	li	a1,147
ffffffffc02011d2:	00004517          	auipc	a0,0x4
ffffffffc02011d6:	77e50513          	addi	a0,a0,1918 # ffffffffc0205950 <commands+0x638>
ffffffffc02011da:	a74ff0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02011de <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02011de:	1141                	addi	sp,sp,-16
ffffffffc02011e0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011e2:	12058f63          	beqz	a1,ffffffffc0201320 <default_free_pages+0x142>
    for (; p != base + n; p ++) {
ffffffffc02011e6:	00659693          	slli	a3,a1,0x6
ffffffffc02011ea:	96aa                	add	a3,a3,a0
ffffffffc02011ec:	87aa                	mv	a5,a0
ffffffffc02011ee:	02d50263          	beq	a0,a3,ffffffffc0201212 <default_free_pages+0x34>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02011f2:	6798                	ld	a4,8(a5)
ffffffffc02011f4:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02011f6:	10071563          	bnez	a4,ffffffffc0201300 <default_free_pages+0x122>
ffffffffc02011fa:	6798                	ld	a4,8(a5)
ffffffffc02011fc:	8b09                	andi	a4,a4,2
ffffffffc02011fe:	10071163          	bnez	a4,ffffffffc0201300 <default_free_pages+0x122>
        p->flags = 0;
ffffffffc0201202:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc0201206:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020120a:	04078793          	addi	a5,a5,64
ffffffffc020120e:	fed792e3          	bne	a5,a3,ffffffffc02011f2 <default_free_pages+0x14>
    base->property = n;
ffffffffc0201212:	2581                	sext.w	a1,a1
ffffffffc0201214:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201216:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020121a:	4789                	li	a5,2
ffffffffc020121c:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201220:	000ab697          	auipc	a3,0xab
ffffffffc0201224:	47068693          	addi	a3,a3,1136 # ffffffffc02ac690 <free_area>
ffffffffc0201228:	4a98                	lw	a4,16(a3)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc020122a:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020122c:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201230:	9db9                	addw	a1,a1,a4
ffffffffc0201232:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201234:	08d78f63          	beq	a5,a3,ffffffffc02012d2 <default_free_pages+0xf4>
            struct Page* page = le2page(le, page_link);
ffffffffc0201238:	fe878713          	addi	a4,a5,-24
ffffffffc020123c:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201240:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201242:	00e56a63          	bltu	a0,a4,ffffffffc0201256 <default_free_pages+0x78>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201246:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201248:	04d70a63          	beq	a4,a3,ffffffffc020129c <default_free_pages+0xbe>
    for (; p != base + n; p ++) {
ffffffffc020124c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020124e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201252:	fee57ae3          	bgeu	a0,a4,ffffffffc0201246 <default_free_pages+0x68>
ffffffffc0201256:	c199                	beqz	a1,ffffffffc020125c <default_free_pages+0x7e>
ffffffffc0201258:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020125c:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020125e:	e390                	sd	a2,0(a5)
ffffffffc0201260:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201262:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201264:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201266:	00d70c63          	beq	a4,a3,ffffffffc020127e <default_free_pages+0xa0>
        if (p + p->property == base) {
ffffffffc020126a:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc020126e:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201272:	02059793          	slli	a5,a1,0x20
ffffffffc0201276:	83e9                	srli	a5,a5,0x1a
ffffffffc0201278:	97b2                	add	a5,a5,a2
ffffffffc020127a:	02f50b63          	beq	a0,a5,ffffffffc02012b0 <default_free_pages+0xd2>
    return listelm->next;
ffffffffc020127e:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0201280:	00d70b63          	beq	a4,a3,ffffffffc0201296 <default_free_pages+0xb8>
        if (base + base->property == p) {
ffffffffc0201284:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201286:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc020128a:	02061793          	slli	a5,a2,0x20
ffffffffc020128e:	83e9                	srli	a5,a5,0x1a
ffffffffc0201290:	97aa                	add	a5,a5,a0
ffffffffc0201292:	04f68763          	beq	a3,a5,ffffffffc02012e0 <default_free_pages+0x102>
}
ffffffffc0201296:	60a2                	ld	ra,8(sp)
ffffffffc0201298:	0141                	addi	sp,sp,16
ffffffffc020129a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020129c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020129e:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02012a0:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02012a2:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02012a4:	02d70463          	beq	a4,a3,ffffffffc02012cc <default_free_pages+0xee>
    prev->next = next->prev = elm;
ffffffffc02012a8:	8832                	mv	a6,a2
ffffffffc02012aa:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02012ac:	87ba                	mv	a5,a4
ffffffffc02012ae:	b745                	j	ffffffffc020124e <default_free_pages+0x70>
            p->property += base->property;
ffffffffc02012b0:	491c                	lw	a5,16(a0)
ffffffffc02012b2:	9dbd                	addw	a1,a1,a5
ffffffffc02012b4:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02012b8:	57f5                	li	a5,-3
ffffffffc02012ba:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02012be:	6d0c                	ld	a1,24(a0)
ffffffffc02012c0:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc02012c2:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02012c4:	e59c                	sd	a5,8(a1)
    return listelm->next;
ffffffffc02012c6:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02012c8:	e38c                	sd	a1,0(a5)
ffffffffc02012ca:	bf5d                	j	ffffffffc0201280 <default_free_pages+0xa2>
ffffffffc02012cc:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02012ce:	873e                	mv	a4,a5
ffffffffc02012d0:	bf69                	j	ffffffffc020126a <default_free_pages+0x8c>
}
ffffffffc02012d2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02012d4:	e390                	sd	a2,0(a5)
ffffffffc02012d6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02012d8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02012da:	ed1c                	sd	a5,24(a0)
ffffffffc02012dc:	0141                	addi	sp,sp,16
ffffffffc02012de:	8082                	ret
            base->property += p->property;
ffffffffc02012e0:	ff872783          	lw	a5,-8(a4)
ffffffffc02012e4:	ff070693          	addi	a3,a4,-16
ffffffffc02012e8:	9e3d                	addw	a2,a2,a5
ffffffffc02012ea:	c910                	sw	a2,16(a0)
ffffffffc02012ec:	57f5                	li	a5,-3
ffffffffc02012ee:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02012f2:	6314                	ld	a3,0(a4)
ffffffffc02012f4:	671c                	ld	a5,8(a4)
}
ffffffffc02012f6:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02012f8:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02012fa:	e394                	sd	a3,0(a5)
ffffffffc02012fc:	0141                	addi	sp,sp,16
ffffffffc02012fe:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201300:	00004697          	auipc	a3,0x4
ffffffffc0201304:	7e868693          	addi	a3,a3,2024 # ffffffffc0205ae8 <commands+0x7d0>
ffffffffc0201308:	00004617          	auipc	a2,0x4
ffffffffc020130c:	63060613          	addi	a2,a2,1584 # ffffffffc0205938 <commands+0x620>
ffffffffc0201310:	05200593          	li	a1,82
ffffffffc0201314:	00004517          	auipc	a0,0x4
ffffffffc0201318:	63c50513          	addi	a0,a0,1596 # ffffffffc0205950 <commands+0x638>
ffffffffc020131c:	932ff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(n > 0);
ffffffffc0201320:	00004697          	auipc	a3,0x4
ffffffffc0201324:	7c068693          	addi	a3,a3,1984 # ffffffffc0205ae0 <commands+0x7c8>
ffffffffc0201328:	00004617          	auipc	a2,0x4
ffffffffc020132c:	61060613          	addi	a2,a2,1552 # ffffffffc0205938 <commands+0x620>
ffffffffc0201330:	04f00593          	li	a1,79
ffffffffc0201334:	00004517          	auipc	a0,0x4
ffffffffc0201338:	61c50513          	addi	a0,a0,1564 # ffffffffc0205950 <commands+0x638>
ffffffffc020133c:	912ff0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0201340 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201340:	c941                	beqz	a0,ffffffffc02013d0 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc0201342:	000ab597          	auipc	a1,0xab
ffffffffc0201346:	34e58593          	addi	a1,a1,846 # ffffffffc02ac690 <free_area>
ffffffffc020134a:	0105a803          	lw	a6,16(a1)
ffffffffc020134e:	872a                	mv	a4,a0
ffffffffc0201350:	02081793          	slli	a5,a6,0x20
ffffffffc0201354:	9381                	srli	a5,a5,0x20
ffffffffc0201356:	00a7ee63          	bltu	a5,a0,ffffffffc0201372 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020135a:	87ae                	mv	a5,a1
ffffffffc020135c:	a801                	j	ffffffffc020136c <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020135e:	ff87a683          	lw	a3,-8(a5)
ffffffffc0201362:	02069613          	slli	a2,a3,0x20
ffffffffc0201366:	9201                	srli	a2,a2,0x20
ffffffffc0201368:	00e67763          	bgeu	a2,a4,ffffffffc0201376 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020136c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020136e:	feb798e3          	bne	a5,a1,ffffffffc020135e <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201372:	4501                	li	a0,0
}
ffffffffc0201374:	8082                	ret
    return listelm->prev;
ffffffffc0201376:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020137a:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc020137e:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0201382:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0201386:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020138a:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020138e:	02c77863          	bgeu	a4,a2,ffffffffc02013be <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0201392:	071a                	slli	a4,a4,0x6
ffffffffc0201394:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201396:	41c686bb          	subw	a3,a3,t3
ffffffffc020139a:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020139c:	00870613          	addi	a2,a4,8
ffffffffc02013a0:	4689                	li	a3,2
ffffffffc02013a2:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02013a6:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02013aa:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc02013ae:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02013b2:	e290                	sd	a2,0(a3)
ffffffffc02013b4:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02013b8:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02013ba:	01173c23          	sd	a7,24(a4)
ffffffffc02013be:	41c8083b          	subw	a6,a6,t3
ffffffffc02013c2:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02013c6:	5775                	li	a4,-3
ffffffffc02013c8:	17c1                	addi	a5,a5,-16
ffffffffc02013ca:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02013ce:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02013d0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02013d2:	00004697          	auipc	a3,0x4
ffffffffc02013d6:	70e68693          	addi	a3,a3,1806 # ffffffffc0205ae0 <commands+0x7c8>
ffffffffc02013da:	00004617          	auipc	a2,0x4
ffffffffc02013de:	55e60613          	addi	a2,a2,1374 # ffffffffc0205938 <commands+0x620>
ffffffffc02013e2:	03100593          	li	a1,49
ffffffffc02013e6:	00004517          	auipc	a0,0x4
ffffffffc02013ea:	56a50513          	addi	a0,a0,1386 # ffffffffc0205950 <commands+0x638>
default_alloc_pages(size_t n) {
ffffffffc02013ee:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02013f0:	85eff0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02013f4 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02013f4:	1141                	addi	sp,sp,-16
ffffffffc02013f6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02013f8:	c5e9                	beqz	a1,ffffffffc02014c2 <default_init_memmap+0xce>
    for (; p != base + n; p ++) {
ffffffffc02013fa:	00659693          	slli	a3,a1,0x6
ffffffffc02013fe:	96aa                	add	a3,a3,a0
ffffffffc0201400:	87aa                	mv	a5,a0
ffffffffc0201402:	00d50f63          	beq	a0,a3,ffffffffc0201420 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201406:	6798                	ld	a4,8(a5)
ffffffffc0201408:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc020140a:	cf49                	beqz	a4,ffffffffc02014a4 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc020140c:	0007a823          	sw	zero,16(a5)
ffffffffc0201410:	0007b423          	sd	zero,8(a5)
ffffffffc0201414:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201418:	04078793          	addi	a5,a5,64
ffffffffc020141c:	fed795e3          	bne	a5,a3,ffffffffc0201406 <default_init_memmap+0x12>
    base->property = n;
ffffffffc0201420:	2581                	sext.w	a1,a1
ffffffffc0201422:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201424:	4789                	li	a5,2
ffffffffc0201426:	00850713          	addi	a4,a0,8
ffffffffc020142a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020142e:	000ab697          	auipc	a3,0xab
ffffffffc0201432:	26268693          	addi	a3,a3,610 # ffffffffc02ac690 <free_area>
ffffffffc0201436:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201438:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020143a:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020143e:	9db9                	addw	a1,a1,a4
ffffffffc0201440:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201442:	04d78a63          	beq	a5,a3,ffffffffc0201496 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0201446:	fe878713          	addi	a4,a5,-24
ffffffffc020144a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020144e:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201450:	00e56a63          	bltu	a0,a4,ffffffffc0201464 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201454:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201456:	02d70263          	beq	a4,a3,ffffffffc020147a <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc020145a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020145c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201460:	fee57ae3          	bgeu	a0,a4,ffffffffc0201454 <default_init_memmap+0x60>
ffffffffc0201464:	c199                	beqz	a1,ffffffffc020146a <default_init_memmap+0x76>
ffffffffc0201466:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020146a:	6398                	ld	a4,0(a5)
}
ffffffffc020146c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020146e:	e390                	sd	a2,0(a5)
ffffffffc0201470:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201472:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201474:	ed18                	sd	a4,24(a0)
ffffffffc0201476:	0141                	addi	sp,sp,16
ffffffffc0201478:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020147a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020147c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020147e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201480:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201482:	00d70663          	beq	a4,a3,ffffffffc020148e <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0201486:	8832                	mv	a6,a2
ffffffffc0201488:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020148a:	87ba                	mv	a5,a4
ffffffffc020148c:	bfc1                	j	ffffffffc020145c <default_init_memmap+0x68>
}
ffffffffc020148e:	60a2                	ld	ra,8(sp)
ffffffffc0201490:	e290                	sd	a2,0(a3)
ffffffffc0201492:	0141                	addi	sp,sp,16
ffffffffc0201494:	8082                	ret
ffffffffc0201496:	60a2                	ld	ra,8(sp)
ffffffffc0201498:	e390                	sd	a2,0(a5)
ffffffffc020149a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020149c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020149e:	ed1c                	sd	a5,24(a0)
ffffffffc02014a0:	0141                	addi	sp,sp,16
ffffffffc02014a2:	8082                	ret
        assert(PageReserved(p));
ffffffffc02014a4:	00004697          	auipc	a3,0x4
ffffffffc02014a8:	66c68693          	addi	a3,a3,1644 # ffffffffc0205b10 <commands+0x7f8>
ffffffffc02014ac:	00004617          	auipc	a2,0x4
ffffffffc02014b0:	48c60613          	addi	a2,a2,1164 # ffffffffc0205938 <commands+0x620>
ffffffffc02014b4:	45e1                	li	a1,24
ffffffffc02014b6:	00004517          	auipc	a0,0x4
ffffffffc02014ba:	49a50513          	addi	a0,a0,1178 # ffffffffc0205950 <commands+0x638>
ffffffffc02014be:	f91fe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(n > 0);
ffffffffc02014c2:	00004697          	auipc	a3,0x4
ffffffffc02014c6:	61e68693          	addi	a3,a3,1566 # ffffffffc0205ae0 <commands+0x7c8>
ffffffffc02014ca:	00004617          	auipc	a2,0x4
ffffffffc02014ce:	46e60613          	addi	a2,a2,1134 # ffffffffc0205938 <commands+0x620>
ffffffffc02014d2:	45d5                	li	a1,21
ffffffffc02014d4:	00004517          	auipc	a0,0x4
ffffffffc02014d8:	47c50513          	addi	a0,a0,1148 # ffffffffc0205950 <commands+0x638>
ffffffffc02014dc:	f73fe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02014e0 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02014e0:	c94d                	beqz	a0,ffffffffc0201592 <slob_free+0xb2>
{
ffffffffc02014e2:	1141                	addi	sp,sp,-16
ffffffffc02014e4:	e022                	sd	s0,0(sp)
ffffffffc02014e6:	e406                	sd	ra,8(sp)
ffffffffc02014e8:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02014ea:	e9c1                	bnez	a1,ffffffffc020157a <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02014ec:	100027f3          	csrr	a5,sstatus
ffffffffc02014f0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02014f2:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02014f4:	ebd9                	bnez	a5,ffffffffc020158a <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02014f6:	000ab617          	auipc	a2,0xab
ffffffffc02014fa:	d8a60613          	addi	a2,a2,-630 # ffffffffc02ac280 <slobfree>
ffffffffc02014fe:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201500:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201502:	679c                	ld	a5,8(a5)
ffffffffc0201504:	02877a63          	bgeu	a4,s0,ffffffffc0201538 <slob_free+0x58>
ffffffffc0201508:	00f46463          	bltu	s0,a5,ffffffffc0201510 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020150c:	fef76ae3          	bltu	a4,a5,ffffffffc0201500 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc0201510:	400c                	lw	a1,0(s0)
ffffffffc0201512:	00459693          	slli	a3,a1,0x4
ffffffffc0201516:	96a2                	add	a3,a3,s0
ffffffffc0201518:	02d78a63          	beq	a5,a3,ffffffffc020154c <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc020151c:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc020151e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201520:	00469793          	slli	a5,a3,0x4
ffffffffc0201524:	97ba                	add	a5,a5,a4
ffffffffc0201526:	02f40e63          	beq	s0,a5,ffffffffc0201562 <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc020152a:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc020152c:	e218                	sd	a4,0(a2)
    if (flag)
ffffffffc020152e:	e129                	bnez	a0,ffffffffc0201570 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201530:	60a2                	ld	ra,8(sp)
ffffffffc0201532:	6402                	ld	s0,0(sp)
ffffffffc0201534:	0141                	addi	sp,sp,16
ffffffffc0201536:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201538:	fcf764e3          	bltu	a4,a5,ffffffffc0201500 <slob_free+0x20>
ffffffffc020153c:	fcf472e3          	bgeu	s0,a5,ffffffffc0201500 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc0201540:	400c                	lw	a1,0(s0)
ffffffffc0201542:	00459693          	slli	a3,a1,0x4
ffffffffc0201546:	96a2                	add	a3,a3,s0
ffffffffc0201548:	fcd79ae3          	bne	a5,a3,ffffffffc020151c <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc020154c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020154e:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201550:	9db5                	addw	a1,a1,a3
ffffffffc0201552:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc0201554:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201556:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201558:	00469793          	slli	a5,a3,0x4
ffffffffc020155c:	97ba                	add	a5,a5,a4
ffffffffc020155e:	fcf416e3          	bne	s0,a5,ffffffffc020152a <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201562:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201564:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201566:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201568:	9ebd                	addw	a3,a3,a5
ffffffffc020156a:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc020156c:	e70c                	sd	a1,8(a4)
ffffffffc020156e:	d169                	beqz	a0,ffffffffc0201530 <slob_free+0x50>
}
ffffffffc0201570:	6402                	ld	s0,0(sp)
ffffffffc0201572:	60a2                	ld	ra,8(sp)
ffffffffc0201574:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201576:	bf8ff06f          	j	ffffffffc020096e <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc020157a:	25bd                	addiw	a1,a1,15
ffffffffc020157c:	8191                	srli	a1,a1,0x4
ffffffffc020157e:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201580:	100027f3          	csrr	a5,sstatus
ffffffffc0201584:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201586:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201588:	d7bd                	beqz	a5,ffffffffc02014f6 <slob_free+0x16>
        intr_disable();
ffffffffc020158a:	beaff0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        return 1;
ffffffffc020158e:	4505                	li	a0,1
ffffffffc0201590:	b79d                	j	ffffffffc02014f6 <slob_free+0x16>
ffffffffc0201592:	8082                	ret

ffffffffc0201594 <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201594:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201596:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201598:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020159c:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc020159e:	34e000ef          	jal	ra,ffffffffc02018ec <alloc_pages>
	if (!page)
ffffffffc02015a2:	c91d                	beqz	a0,ffffffffc02015d8 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc02015a4:	000af697          	auipc	a3,0xaf
ffffffffc02015a8:	15c6b683          	ld	a3,348(a3) # ffffffffc02b0700 <pages>
ffffffffc02015ac:	8d15                	sub	a0,a0,a3
ffffffffc02015ae:	8519                	srai	a0,a0,0x6
ffffffffc02015b0:	00006697          	auipc	a3,0x6
ffffffffc02015b4:	9d06b683          	ld	a3,-1584(a3) # ffffffffc0206f80 <nbase>
ffffffffc02015b8:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02015ba:	00c51793          	slli	a5,a0,0xc
ffffffffc02015be:	83b1                	srli	a5,a5,0xc
ffffffffc02015c0:	000af717          	auipc	a4,0xaf
ffffffffc02015c4:	13873703          	ld	a4,312(a4) # ffffffffc02b06f8 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02015c8:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02015ca:	00e7fa63          	bgeu	a5,a4,ffffffffc02015de <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02015ce:	000af697          	auipc	a3,0xaf
ffffffffc02015d2:	1426b683          	ld	a3,322(a3) # ffffffffc02b0710 <va_pa_offset>
ffffffffc02015d6:	9536                	add	a0,a0,a3
}
ffffffffc02015d8:	60a2                	ld	ra,8(sp)
ffffffffc02015da:	0141                	addi	sp,sp,16
ffffffffc02015dc:	8082                	ret
ffffffffc02015de:	86aa                	mv	a3,a0
ffffffffc02015e0:	00004617          	auipc	a2,0x4
ffffffffc02015e4:	59060613          	addi	a2,a2,1424 # ffffffffc0205b70 <default_pmm_manager+0x38>
ffffffffc02015e8:	07100593          	li	a1,113
ffffffffc02015ec:	00004517          	auipc	a0,0x4
ffffffffc02015f0:	5ac50513          	addi	a0,a0,1452 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc02015f4:	e5bfe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02015f8 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02015f8:	1101                	addi	sp,sp,-32
ffffffffc02015fa:	ec06                	sd	ra,24(sp)
ffffffffc02015fc:	e822                	sd	s0,16(sp)
ffffffffc02015fe:	e426                	sd	s1,8(sp)
ffffffffc0201600:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201602:	01050713          	addi	a4,a0,16
ffffffffc0201606:	6785                	lui	a5,0x1
ffffffffc0201608:	0cf77363          	bgeu	a4,a5,ffffffffc02016ce <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc020160c:	00f50493          	addi	s1,a0,15
ffffffffc0201610:	8091                	srli	s1,s1,0x4
ffffffffc0201612:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201614:	10002673          	csrr	a2,sstatus
ffffffffc0201618:	8a09                	andi	a2,a2,2
ffffffffc020161a:	e25d                	bnez	a2,ffffffffc02016c0 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc020161c:	000ab917          	auipc	s2,0xab
ffffffffc0201620:	c6490913          	addi	s2,s2,-924 # ffffffffc02ac280 <slobfree>
ffffffffc0201624:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201628:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc020162a:	4398                	lw	a4,0(a5)
ffffffffc020162c:	08975e63          	bge	a4,s1,ffffffffc02016c8 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc0201630:	00f68b63          	beq	a3,a5,ffffffffc0201646 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201634:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201636:	4018                	lw	a4,0(s0)
ffffffffc0201638:	02975a63          	bge	a4,s1,ffffffffc020166c <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc020163c:	00093683          	ld	a3,0(s2)
ffffffffc0201640:	87a2                	mv	a5,s0
ffffffffc0201642:	fef699e3          	bne	a3,a5,ffffffffc0201634 <slob_alloc.constprop.0+0x3c>
    if (flag)
ffffffffc0201646:	ee31                	bnez	a2,ffffffffc02016a2 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201648:	4501                	li	a0,0
ffffffffc020164a:	f4bff0ef          	jal	ra,ffffffffc0201594 <__slob_get_free_pages.constprop.0>
ffffffffc020164e:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201650:	cd05                	beqz	a0,ffffffffc0201688 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201652:	6585                	lui	a1,0x1
ffffffffc0201654:	e8dff0ef          	jal	ra,ffffffffc02014e0 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201658:	10002673          	csrr	a2,sstatus
ffffffffc020165c:	8a09                	andi	a2,a2,2
ffffffffc020165e:	ee05                	bnez	a2,ffffffffc0201696 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201660:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201664:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201666:	4018                	lw	a4,0(s0)
ffffffffc0201668:	fc974ae3          	blt	a4,s1,ffffffffc020163c <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc020166c:	04e48763          	beq	s1,a4,ffffffffc02016ba <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201670:	00449693          	slli	a3,s1,0x4
ffffffffc0201674:	96a2                	add	a3,a3,s0
ffffffffc0201676:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201678:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc020167a:	9f05                	subw	a4,a4,s1
ffffffffc020167c:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc020167e:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201680:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201682:	00f93023          	sd	a5,0(s2)
    if (flag)
ffffffffc0201686:	e20d                	bnez	a2,ffffffffc02016a8 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201688:	60e2                	ld	ra,24(sp)
ffffffffc020168a:	8522                	mv	a0,s0
ffffffffc020168c:	6442                	ld	s0,16(sp)
ffffffffc020168e:	64a2                	ld	s1,8(sp)
ffffffffc0201690:	6902                	ld	s2,0(sp)
ffffffffc0201692:	6105                	addi	sp,sp,32
ffffffffc0201694:	8082                	ret
        intr_disable();
ffffffffc0201696:	adeff0ef          	jal	ra,ffffffffc0200974 <intr_disable>
			cur = slobfree;
ffffffffc020169a:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc020169e:	4605                	li	a2,1
ffffffffc02016a0:	b7d1                	j	ffffffffc0201664 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc02016a2:	accff0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc02016a6:	b74d                	j	ffffffffc0201648 <slob_alloc.constprop.0+0x50>
ffffffffc02016a8:	ac6ff0ef          	jal	ra,ffffffffc020096e <intr_enable>
}
ffffffffc02016ac:	60e2                	ld	ra,24(sp)
ffffffffc02016ae:	8522                	mv	a0,s0
ffffffffc02016b0:	6442                	ld	s0,16(sp)
ffffffffc02016b2:	64a2                	ld	s1,8(sp)
ffffffffc02016b4:	6902                	ld	s2,0(sp)
ffffffffc02016b6:	6105                	addi	sp,sp,32
ffffffffc02016b8:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02016ba:	6418                	ld	a4,8(s0)
ffffffffc02016bc:	e798                	sd	a4,8(a5)
ffffffffc02016be:	b7d1                	j	ffffffffc0201682 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc02016c0:	ab4ff0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        return 1;
ffffffffc02016c4:	4605                	li	a2,1
ffffffffc02016c6:	bf99                	j	ffffffffc020161c <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc02016c8:	843e                	mv	s0,a5
ffffffffc02016ca:	87b6                	mv	a5,a3
ffffffffc02016cc:	b745                	j	ffffffffc020166c <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc02016ce:	00004697          	auipc	a3,0x4
ffffffffc02016d2:	4da68693          	addi	a3,a3,1242 # ffffffffc0205ba8 <default_pmm_manager+0x70>
ffffffffc02016d6:	00004617          	auipc	a2,0x4
ffffffffc02016da:	26260613          	addi	a2,a2,610 # ffffffffc0205938 <commands+0x620>
ffffffffc02016de:	06300593          	li	a1,99
ffffffffc02016e2:	00004517          	auipc	a0,0x4
ffffffffc02016e6:	4e650513          	addi	a0,a0,1254 # ffffffffc0205bc8 <default_pmm_manager+0x90>
ffffffffc02016ea:	d65fe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02016ee <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc02016ee:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc02016f0:	00004517          	auipc	a0,0x4
ffffffffc02016f4:	4f050513          	addi	a0,a0,1264 # ffffffffc0205be0 <default_pmm_manager+0xa8>
{
ffffffffc02016f8:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc02016fa:	a9bfe0ef          	jal	ra,ffffffffc0200194 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02016fe:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201700:	00004517          	auipc	a0,0x4
ffffffffc0201704:	4f850513          	addi	a0,a0,1272 # ffffffffc0205bf8 <default_pmm_manager+0xc0>
}
ffffffffc0201708:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc020170a:	a8bfe06f          	j	ffffffffc0200194 <cprintf>

ffffffffc020170e <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc020170e:	1101                	addi	sp,sp,-32
ffffffffc0201710:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201712:	6905                	lui	s2,0x1
{
ffffffffc0201714:	e822                	sd	s0,16(sp)
ffffffffc0201716:	ec06                	sd	ra,24(sp)
ffffffffc0201718:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc020171a:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x9301>
{
ffffffffc020171e:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201720:	04a7f963          	bgeu	a5,a0,ffffffffc0201772 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201724:	4561                	li	a0,24
ffffffffc0201726:	ed3ff0ef          	jal	ra,ffffffffc02015f8 <slob_alloc.constprop.0>
ffffffffc020172a:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc020172c:	c929                	beqz	a0,ffffffffc020177e <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc020172e:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201732:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201734:	00f95763          	bge	s2,a5,ffffffffc0201742 <kmalloc+0x34>
ffffffffc0201738:	6705                	lui	a4,0x1
ffffffffc020173a:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc020173c:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc020173e:	fef74ee3          	blt	a4,a5,ffffffffc020173a <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201742:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201744:	e51ff0ef          	jal	ra,ffffffffc0201594 <__slob_get_free_pages.constprop.0>
ffffffffc0201748:	e488                	sd	a0,8(s1)
ffffffffc020174a:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc020174c:	c525                	beqz	a0,ffffffffc02017b4 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020174e:	100027f3          	csrr	a5,sstatus
ffffffffc0201752:	8b89                	andi	a5,a5,2
ffffffffc0201754:	ef8d                	bnez	a5,ffffffffc020178e <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201756:	000af797          	auipc	a5,0xaf
ffffffffc020175a:	f8a78793          	addi	a5,a5,-118 # ffffffffc02b06e0 <bigblocks>
ffffffffc020175e:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201760:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201762:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc0201764:	60e2                	ld	ra,24(sp)
ffffffffc0201766:	8522                	mv	a0,s0
ffffffffc0201768:	6442                	ld	s0,16(sp)
ffffffffc020176a:	64a2                	ld	s1,8(sp)
ffffffffc020176c:	6902                	ld	s2,0(sp)
ffffffffc020176e:	6105                	addi	sp,sp,32
ffffffffc0201770:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201772:	0541                	addi	a0,a0,16
ffffffffc0201774:	e85ff0ef          	jal	ra,ffffffffc02015f8 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201778:	01050413          	addi	s0,a0,16
ffffffffc020177c:	f565                	bnez	a0,ffffffffc0201764 <kmalloc+0x56>
ffffffffc020177e:	4401                	li	s0,0
}
ffffffffc0201780:	60e2                	ld	ra,24(sp)
ffffffffc0201782:	8522                	mv	a0,s0
ffffffffc0201784:	6442                	ld	s0,16(sp)
ffffffffc0201786:	64a2                	ld	s1,8(sp)
ffffffffc0201788:	6902                	ld	s2,0(sp)
ffffffffc020178a:	6105                	addi	sp,sp,32
ffffffffc020178c:	8082                	ret
        intr_disable();
ffffffffc020178e:	9e6ff0ef          	jal	ra,ffffffffc0200974 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201792:	000af797          	auipc	a5,0xaf
ffffffffc0201796:	f4e78793          	addi	a5,a5,-178 # ffffffffc02b06e0 <bigblocks>
ffffffffc020179a:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020179c:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020179e:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc02017a0:	9ceff0ef          	jal	ra,ffffffffc020096e <intr_enable>
		return bb->pages;
ffffffffc02017a4:	6480                	ld	s0,8(s1)
}
ffffffffc02017a6:	60e2                	ld	ra,24(sp)
ffffffffc02017a8:	64a2                	ld	s1,8(sp)
ffffffffc02017aa:	8522                	mv	a0,s0
ffffffffc02017ac:	6442                	ld	s0,16(sp)
ffffffffc02017ae:	6902                	ld	s2,0(sp)
ffffffffc02017b0:	6105                	addi	sp,sp,32
ffffffffc02017b2:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc02017b4:	45e1                	li	a1,24
ffffffffc02017b6:	8526                	mv	a0,s1
ffffffffc02017b8:	d29ff0ef          	jal	ra,ffffffffc02014e0 <slob_free>
	return __kmalloc(size, 0);
ffffffffc02017bc:	b765                	j	ffffffffc0201764 <kmalloc+0x56>

ffffffffc02017be <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc02017be:	c169                	beqz	a0,ffffffffc0201880 <kfree+0xc2>
{
ffffffffc02017c0:	1101                	addi	sp,sp,-32
ffffffffc02017c2:	e822                	sd	s0,16(sp)
ffffffffc02017c4:	ec06                	sd	ra,24(sp)
ffffffffc02017c6:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc02017c8:	03451793          	slli	a5,a0,0x34
ffffffffc02017cc:	842a                	mv	s0,a0
ffffffffc02017ce:	e3d9                	bnez	a5,ffffffffc0201854 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02017d0:	100027f3          	csrr	a5,sstatus
ffffffffc02017d4:	8b89                	andi	a5,a5,2
ffffffffc02017d6:	e7d9                	bnez	a5,ffffffffc0201864 <kfree+0xa6>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc02017d8:	000af797          	auipc	a5,0xaf
ffffffffc02017dc:	f087b783          	ld	a5,-248(a5) # ffffffffc02b06e0 <bigblocks>
    return 0;
ffffffffc02017e0:	4601                	li	a2,0
ffffffffc02017e2:	cbad                	beqz	a5,ffffffffc0201854 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc02017e4:	000af697          	auipc	a3,0xaf
ffffffffc02017e8:	efc68693          	addi	a3,a3,-260 # ffffffffc02b06e0 <bigblocks>
ffffffffc02017ec:	a021                	j	ffffffffc02017f4 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc02017ee:	01048693          	addi	a3,s1,16
ffffffffc02017f2:	c3a5                	beqz	a5,ffffffffc0201852 <kfree+0x94>
		{
			if (bb->pages == block)
ffffffffc02017f4:	6798                	ld	a4,8(a5)
ffffffffc02017f6:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc02017f8:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc02017fa:	fe871ae3          	bne	a4,s0,ffffffffc02017ee <kfree+0x30>
				*last = bb->next;
ffffffffc02017fe:	e29c                	sd	a5,0(a3)
    if (flag)
ffffffffc0201800:	ee2d                	bnez	a2,ffffffffc020187a <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201802:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201806:	4098                	lw	a4,0(s1)
ffffffffc0201808:	08f46963          	bltu	s0,a5,ffffffffc020189a <kfree+0xdc>
ffffffffc020180c:	000af697          	auipc	a3,0xaf
ffffffffc0201810:	f046b683          	ld	a3,-252(a3) # ffffffffc02b0710 <va_pa_offset>
ffffffffc0201814:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc0201816:	8031                	srli	s0,s0,0xc
ffffffffc0201818:	000af797          	auipc	a5,0xaf
ffffffffc020181c:	ee07b783          	ld	a5,-288(a5) # ffffffffc02b06f8 <npage>
ffffffffc0201820:	06f47163          	bgeu	s0,a5,ffffffffc0201882 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201824:	00005517          	auipc	a0,0x5
ffffffffc0201828:	75c53503          	ld	a0,1884(a0) # ffffffffc0206f80 <nbase>
ffffffffc020182c:	8c09                	sub	s0,s0,a0
ffffffffc020182e:	041a                	slli	s0,s0,0x6
	free_pages(kva2page((void *)kva), 1 << order);
ffffffffc0201830:	000af517          	auipc	a0,0xaf
ffffffffc0201834:	ed053503          	ld	a0,-304(a0) # ffffffffc02b0700 <pages>
ffffffffc0201838:	4585                	li	a1,1
ffffffffc020183a:	9522                	add	a0,a0,s0
ffffffffc020183c:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201840:	0ea000ef          	jal	ra,ffffffffc020192a <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201844:	6442                	ld	s0,16(sp)
ffffffffc0201846:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201848:	8526                	mv	a0,s1
}
ffffffffc020184a:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020184c:	45e1                	li	a1,24
}
ffffffffc020184e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201850:	b941                	j	ffffffffc02014e0 <slob_free>
ffffffffc0201852:	e20d                	bnez	a2,ffffffffc0201874 <kfree+0xb6>
ffffffffc0201854:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201858:	6442                	ld	s0,16(sp)
ffffffffc020185a:	60e2                	ld	ra,24(sp)
ffffffffc020185c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020185e:	4581                	li	a1,0
}
ffffffffc0201860:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201862:	b9bd                	j	ffffffffc02014e0 <slob_free>
        intr_disable();
ffffffffc0201864:	910ff0ef          	jal	ra,ffffffffc0200974 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201868:	000af797          	auipc	a5,0xaf
ffffffffc020186c:	e787b783          	ld	a5,-392(a5) # ffffffffc02b06e0 <bigblocks>
        return 1;
ffffffffc0201870:	4605                	li	a2,1
ffffffffc0201872:	fbad                	bnez	a5,ffffffffc02017e4 <kfree+0x26>
        intr_enable();
ffffffffc0201874:	8faff0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0201878:	bff1                	j	ffffffffc0201854 <kfree+0x96>
ffffffffc020187a:	8f4ff0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc020187e:	b751                	j	ffffffffc0201802 <kfree+0x44>
ffffffffc0201880:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201882:	00004617          	auipc	a2,0x4
ffffffffc0201886:	3be60613          	addi	a2,a2,958 # ffffffffc0205c40 <default_pmm_manager+0x108>
ffffffffc020188a:	06900593          	li	a1,105
ffffffffc020188e:	00004517          	auipc	a0,0x4
ffffffffc0201892:	30a50513          	addi	a0,a0,778 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc0201896:	bb9fe0ef          	jal	ra,ffffffffc020044e <__panic>
    return pa2page(PADDR(kva));
ffffffffc020189a:	86a2                	mv	a3,s0
ffffffffc020189c:	00004617          	auipc	a2,0x4
ffffffffc02018a0:	37c60613          	addi	a2,a2,892 # ffffffffc0205c18 <default_pmm_manager+0xe0>
ffffffffc02018a4:	07700593          	li	a1,119
ffffffffc02018a8:	00004517          	auipc	a0,0x4
ffffffffc02018ac:	2f050513          	addi	a0,a0,752 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc02018b0:	b9ffe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02018b4 <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc02018b4:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02018b6:	00004617          	auipc	a2,0x4
ffffffffc02018ba:	38a60613          	addi	a2,a2,906 # ffffffffc0205c40 <default_pmm_manager+0x108>
ffffffffc02018be:	06900593          	li	a1,105
ffffffffc02018c2:	00004517          	auipc	a0,0x4
ffffffffc02018c6:	2d650513          	addi	a0,a0,726 # ffffffffc0205b98 <default_pmm_manager+0x60>
pa2page(uintptr_t pa)
ffffffffc02018ca:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02018cc:	b83fe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02018d0 <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc02018d0:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02018d2:	00004617          	auipc	a2,0x4
ffffffffc02018d6:	38e60613          	addi	a2,a2,910 # ffffffffc0205c60 <default_pmm_manager+0x128>
ffffffffc02018da:	07f00593          	li	a1,127
ffffffffc02018de:	00004517          	auipc	a0,0x4
ffffffffc02018e2:	2ba50513          	addi	a0,a0,698 # ffffffffc0205b98 <default_pmm_manager+0x60>
pte2page(pte_t pte)
ffffffffc02018e6:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02018e8:	b67fe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02018ec <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02018ec:	100027f3          	csrr	a5,sstatus
ffffffffc02018f0:	8b89                	andi	a5,a5,2
ffffffffc02018f2:	e799                	bnez	a5,ffffffffc0201900 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02018f4:	000af797          	auipc	a5,0xaf
ffffffffc02018f8:	e147b783          	ld	a5,-492(a5) # ffffffffc02b0708 <pmm_manager>
ffffffffc02018fc:	6f9c                	ld	a5,24(a5)
ffffffffc02018fe:	8782                	jr	a5
{
ffffffffc0201900:	1141                	addi	sp,sp,-16
ffffffffc0201902:	e406                	sd	ra,8(sp)
ffffffffc0201904:	e022                	sd	s0,0(sp)
ffffffffc0201906:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201908:	86cff0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020190c:	000af797          	auipc	a5,0xaf
ffffffffc0201910:	dfc7b783          	ld	a5,-516(a5) # ffffffffc02b0708 <pmm_manager>
ffffffffc0201914:	6f9c                	ld	a5,24(a5)
ffffffffc0201916:	8522                	mv	a0,s0
ffffffffc0201918:	9782                	jalr	a5
ffffffffc020191a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020191c:	852ff0ef          	jal	ra,ffffffffc020096e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201920:	60a2                	ld	ra,8(sp)
ffffffffc0201922:	8522                	mv	a0,s0
ffffffffc0201924:	6402                	ld	s0,0(sp)
ffffffffc0201926:	0141                	addi	sp,sp,16
ffffffffc0201928:	8082                	ret

ffffffffc020192a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020192a:	100027f3          	csrr	a5,sstatus
ffffffffc020192e:	8b89                	andi	a5,a5,2
ffffffffc0201930:	e799                	bnez	a5,ffffffffc020193e <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201932:	000af797          	auipc	a5,0xaf
ffffffffc0201936:	dd67b783          	ld	a5,-554(a5) # ffffffffc02b0708 <pmm_manager>
ffffffffc020193a:	739c                	ld	a5,32(a5)
ffffffffc020193c:	8782                	jr	a5
{
ffffffffc020193e:	1101                	addi	sp,sp,-32
ffffffffc0201940:	ec06                	sd	ra,24(sp)
ffffffffc0201942:	e822                	sd	s0,16(sp)
ffffffffc0201944:	e426                	sd	s1,8(sp)
ffffffffc0201946:	842a                	mv	s0,a0
ffffffffc0201948:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020194a:	82aff0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020194e:	000af797          	auipc	a5,0xaf
ffffffffc0201952:	dba7b783          	ld	a5,-582(a5) # ffffffffc02b0708 <pmm_manager>
ffffffffc0201956:	739c                	ld	a5,32(a5)
ffffffffc0201958:	85a6                	mv	a1,s1
ffffffffc020195a:	8522                	mv	a0,s0
ffffffffc020195c:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020195e:	6442                	ld	s0,16(sp)
ffffffffc0201960:	60e2                	ld	ra,24(sp)
ffffffffc0201962:	64a2                	ld	s1,8(sp)
ffffffffc0201964:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201966:	808ff06f          	j	ffffffffc020096e <intr_enable>

ffffffffc020196a <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020196a:	01e5d793          	srli	a5,a1,0x1e
ffffffffc020196e:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0201972:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201974:	078e                	slli	a5,a5,0x3
{
ffffffffc0201976:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201978:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc020197c:	6094                	ld	a3,0(s1)
{
ffffffffc020197e:	f04a                	sd	s2,32(sp)
ffffffffc0201980:	ec4e                	sd	s3,24(sp)
ffffffffc0201982:	e852                	sd	s4,16(sp)
ffffffffc0201984:	fc06                	sd	ra,56(sp)
ffffffffc0201986:	f822                	sd	s0,48(sp)
ffffffffc0201988:	e456                	sd	s5,8(sp)
ffffffffc020198a:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc020198c:	0016f793          	andi	a5,a3,1
{
ffffffffc0201990:	892e                	mv	s2,a1
ffffffffc0201992:	8a32                	mv	s4,a2
ffffffffc0201994:	000af997          	auipc	s3,0xaf
ffffffffc0201998:	d6498993          	addi	s3,s3,-668 # ffffffffc02b06f8 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc020199c:	efbd                	bnez	a5,ffffffffc0201a1a <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc020199e:	14060c63          	beqz	a2,ffffffffc0201af6 <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02019a2:	100027f3          	csrr	a5,sstatus
ffffffffc02019a6:	8b89                	andi	a5,a5,2
ffffffffc02019a8:	14079963          	bnez	a5,ffffffffc0201afa <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc02019ac:	000af797          	auipc	a5,0xaf
ffffffffc02019b0:	d5c7b783          	ld	a5,-676(a5) # ffffffffc02b0708 <pmm_manager>
ffffffffc02019b4:	6f9c                	ld	a5,24(a5)
ffffffffc02019b6:	4505                	li	a0,1
ffffffffc02019b8:	9782                	jalr	a5
ffffffffc02019ba:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02019bc:	12040d63          	beqz	s0,ffffffffc0201af6 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc02019c0:	000afb17          	auipc	s6,0xaf
ffffffffc02019c4:	d40b0b13          	addi	s6,s6,-704 # ffffffffc02b0700 <pages>
ffffffffc02019c8:	000b3503          	ld	a0,0(s6)
ffffffffc02019cc:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02019d0:	000af997          	auipc	s3,0xaf
ffffffffc02019d4:	d2898993          	addi	s3,s3,-728 # ffffffffc02b06f8 <npage>
ffffffffc02019d8:	40a40533          	sub	a0,s0,a0
ffffffffc02019dc:	8519                	srai	a0,a0,0x6
ffffffffc02019de:	9556                	add	a0,a0,s5
ffffffffc02019e0:	0009b703          	ld	a4,0(s3)
ffffffffc02019e4:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02019e8:	4685                	li	a3,1
ffffffffc02019ea:	c014                	sw	a3,0(s0)
ffffffffc02019ec:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02019ee:	0532                	slli	a0,a0,0xc
ffffffffc02019f0:	16e7f763          	bgeu	a5,a4,ffffffffc0201b5e <get_pte+0x1f4>
ffffffffc02019f4:	000af797          	auipc	a5,0xaf
ffffffffc02019f8:	d1c7b783          	ld	a5,-740(a5) # ffffffffc02b0710 <va_pa_offset>
ffffffffc02019fc:	6605                	lui	a2,0x1
ffffffffc02019fe:	4581                	li	a1,0
ffffffffc0201a00:	953e                	add	a0,a0,a5
ffffffffc0201a02:	680030ef          	jal	ra,ffffffffc0205082 <memset>
    return page - pages + nbase;
ffffffffc0201a06:	000b3683          	ld	a3,0(s6)
ffffffffc0201a0a:	40d406b3          	sub	a3,s0,a3
ffffffffc0201a0e:	8699                	srai	a3,a3,0x6
ffffffffc0201a10:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a12:	06aa                	slli	a3,a3,0xa
ffffffffc0201a14:	0016e693          	ori	a3,a3,1
        *pdep1 = pte_create(page2ppn(page), PTE_V);
ffffffffc0201a18:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201a1a:	77fd                	lui	a5,0xfffff
ffffffffc0201a1c:	068a                	slli	a3,a3,0x2
ffffffffc0201a1e:	0009b703          	ld	a4,0(s3)
ffffffffc0201a22:	8efd                	and	a3,a3,a5
ffffffffc0201a24:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201a28:	10e7ff63          	bgeu	a5,a4,ffffffffc0201b46 <get_pte+0x1dc>
ffffffffc0201a2c:	000afa97          	auipc	s5,0xaf
ffffffffc0201a30:	ce4a8a93          	addi	s5,s5,-796 # ffffffffc02b0710 <va_pa_offset>
ffffffffc0201a34:	000ab403          	ld	s0,0(s5)
ffffffffc0201a38:	01595793          	srli	a5,s2,0x15
ffffffffc0201a3c:	1ff7f793          	andi	a5,a5,511
ffffffffc0201a40:	96a2                	add	a3,a3,s0
ffffffffc0201a42:	00379413          	slli	s0,a5,0x3
ffffffffc0201a46:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0201a48:	6014                	ld	a3,0(s0)
ffffffffc0201a4a:	0016f793          	andi	a5,a3,1
ffffffffc0201a4e:	ebad                	bnez	a5,ffffffffc0201ac0 <get_pte+0x156>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201a50:	0a0a0363          	beqz	s4,ffffffffc0201af6 <get_pte+0x18c>
ffffffffc0201a54:	100027f3          	csrr	a5,sstatus
ffffffffc0201a58:	8b89                	andi	a5,a5,2
ffffffffc0201a5a:	efcd                	bnez	a5,ffffffffc0201b14 <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201a5c:	000af797          	auipc	a5,0xaf
ffffffffc0201a60:	cac7b783          	ld	a5,-852(a5) # ffffffffc02b0708 <pmm_manager>
ffffffffc0201a64:	6f9c                	ld	a5,24(a5)
ffffffffc0201a66:	4505                	li	a0,1
ffffffffc0201a68:	9782                	jalr	a5
ffffffffc0201a6a:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201a6c:	c4c9                	beqz	s1,ffffffffc0201af6 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201a6e:	000afb17          	auipc	s6,0xaf
ffffffffc0201a72:	c92b0b13          	addi	s6,s6,-878 # ffffffffc02b0700 <pages>
ffffffffc0201a76:	000b3503          	ld	a0,0(s6)
ffffffffc0201a7a:	00080a37          	lui	s4,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201a7e:	0009b703          	ld	a4,0(s3)
ffffffffc0201a82:	40a48533          	sub	a0,s1,a0
ffffffffc0201a86:	8519                	srai	a0,a0,0x6
ffffffffc0201a88:	9552                	add	a0,a0,s4
ffffffffc0201a8a:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201a8e:	4685                	li	a3,1
ffffffffc0201a90:	c094                	sw	a3,0(s1)
ffffffffc0201a92:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201a94:	0532                	slli	a0,a0,0xc
ffffffffc0201a96:	0ee7f163          	bgeu	a5,a4,ffffffffc0201b78 <get_pte+0x20e>
ffffffffc0201a9a:	000ab783          	ld	a5,0(s5)
ffffffffc0201a9e:	6605                	lui	a2,0x1
ffffffffc0201aa0:	4581                	li	a1,0
ffffffffc0201aa2:	953e                	add	a0,a0,a5
ffffffffc0201aa4:	5de030ef          	jal	ra,ffffffffc0205082 <memset>
    return page - pages + nbase;
ffffffffc0201aa8:	000b3683          	ld	a3,0(s6)
ffffffffc0201aac:	40d486b3          	sub	a3,s1,a3
ffffffffc0201ab0:	8699                	srai	a3,a3,0x6
ffffffffc0201ab2:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ab4:	06aa                	slli	a3,a3,0xa
ffffffffc0201ab6:	0016e693          	ori	a3,a3,1
        *pdep0 = pte_create(page2ppn(page), PTE_V);
ffffffffc0201aba:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201abc:	0009b703          	ld	a4,0(s3)
ffffffffc0201ac0:	068a                	slli	a3,a3,0x2
ffffffffc0201ac2:	757d                	lui	a0,0xfffff
ffffffffc0201ac4:	8ee9                	and	a3,a3,a0
ffffffffc0201ac6:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201aca:	06e7f263          	bgeu	a5,a4,ffffffffc0201b2e <get_pte+0x1c4>
ffffffffc0201ace:	000ab503          	ld	a0,0(s5)
ffffffffc0201ad2:	00c95913          	srli	s2,s2,0xc
ffffffffc0201ad6:	1ff97913          	andi	s2,s2,511
ffffffffc0201ada:	96aa                	add	a3,a3,a0
ffffffffc0201adc:	00391513          	slli	a0,s2,0x3
ffffffffc0201ae0:	9536                	add	a0,a0,a3
}
ffffffffc0201ae2:	70e2                	ld	ra,56(sp)
ffffffffc0201ae4:	7442                	ld	s0,48(sp)
ffffffffc0201ae6:	74a2                	ld	s1,40(sp)
ffffffffc0201ae8:	7902                	ld	s2,32(sp)
ffffffffc0201aea:	69e2                	ld	s3,24(sp)
ffffffffc0201aec:	6a42                	ld	s4,16(sp)
ffffffffc0201aee:	6aa2                	ld	s5,8(sp)
ffffffffc0201af0:	6b02                	ld	s6,0(sp)
ffffffffc0201af2:	6121                	addi	sp,sp,64
ffffffffc0201af4:	8082                	ret
            return NULL;
ffffffffc0201af6:	4501                	li	a0,0
ffffffffc0201af8:	b7ed                	j	ffffffffc0201ae2 <get_pte+0x178>
        intr_disable();
ffffffffc0201afa:	e7bfe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201afe:	000af797          	auipc	a5,0xaf
ffffffffc0201b02:	c0a7b783          	ld	a5,-1014(a5) # ffffffffc02b0708 <pmm_manager>
ffffffffc0201b06:	6f9c                	ld	a5,24(a5)
ffffffffc0201b08:	4505                	li	a0,1
ffffffffc0201b0a:	9782                	jalr	a5
ffffffffc0201b0c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201b0e:	e61fe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0201b12:	b56d                	j	ffffffffc02019bc <get_pte+0x52>
        intr_disable();
ffffffffc0201b14:	e61fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc0201b18:	000af797          	auipc	a5,0xaf
ffffffffc0201b1c:	bf07b783          	ld	a5,-1040(a5) # ffffffffc02b0708 <pmm_manager>
ffffffffc0201b20:	6f9c                	ld	a5,24(a5)
ffffffffc0201b22:	4505                	li	a0,1
ffffffffc0201b24:	9782                	jalr	a5
ffffffffc0201b26:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc0201b28:	e47fe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0201b2c:	b781                	j	ffffffffc0201a6c <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201b2e:	00004617          	auipc	a2,0x4
ffffffffc0201b32:	04260613          	addi	a2,a2,66 # ffffffffc0205b70 <default_pmm_manager+0x38>
ffffffffc0201b36:	11000593          	li	a1,272
ffffffffc0201b3a:	00004517          	auipc	a0,0x4
ffffffffc0201b3e:	14e50513          	addi	a0,a0,334 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0201b42:	90dfe0ef          	jal	ra,ffffffffc020044e <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201b46:	00004617          	auipc	a2,0x4
ffffffffc0201b4a:	02a60613          	addi	a2,a2,42 # ffffffffc0205b70 <default_pmm_manager+0x38>
ffffffffc0201b4e:	10300593          	li	a1,259
ffffffffc0201b52:	00004517          	auipc	a0,0x4
ffffffffc0201b56:	13650513          	addi	a0,a0,310 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0201b5a:	8f5fe0ef          	jal	ra,ffffffffc020044e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201b5e:	86aa                	mv	a3,a0
ffffffffc0201b60:	00004617          	auipc	a2,0x4
ffffffffc0201b64:	01060613          	addi	a2,a2,16 # ffffffffc0205b70 <default_pmm_manager+0x38>
ffffffffc0201b68:	0ff00593          	li	a1,255
ffffffffc0201b6c:	00004517          	auipc	a0,0x4
ffffffffc0201b70:	11c50513          	addi	a0,a0,284 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0201b74:	8dbfe0ef          	jal	ra,ffffffffc020044e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201b78:	86aa                	mv	a3,a0
ffffffffc0201b7a:	00004617          	auipc	a2,0x4
ffffffffc0201b7e:	ff660613          	addi	a2,a2,-10 # ffffffffc0205b70 <default_pmm_manager+0x38>
ffffffffc0201b82:	10d00593          	li	a1,269
ffffffffc0201b86:	00004517          	auipc	a0,0x4
ffffffffc0201b8a:	10250513          	addi	a0,a0,258 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0201b8e:	8c1fe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0201b92 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0201b92:	1141                	addi	sp,sp,-16
ffffffffc0201b94:	e022                	sd	s0,0(sp)
ffffffffc0201b96:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201b98:	4601                	li	a2,0
{
ffffffffc0201b9a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201b9c:	dcfff0ef          	jal	ra,ffffffffc020196a <get_pte>
    if (ptep_store != NULL)
ffffffffc0201ba0:	c011                	beqz	s0,ffffffffc0201ba4 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0201ba2:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0201ba4:	c511                	beqz	a0,ffffffffc0201bb0 <get_page+0x1e>
ffffffffc0201ba6:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201ba8:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0201baa:	0017f713          	andi	a4,a5,1
ffffffffc0201bae:	e709                	bnez	a4,ffffffffc0201bb8 <get_page+0x26>
}
ffffffffc0201bb0:	60a2                	ld	ra,8(sp)
ffffffffc0201bb2:	6402                	ld	s0,0(sp)
ffffffffc0201bb4:	0141                	addi	sp,sp,16
ffffffffc0201bb6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201bb8:	078a                	slli	a5,a5,0x2
ffffffffc0201bba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201bbc:	000af717          	auipc	a4,0xaf
ffffffffc0201bc0:	b3c73703          	ld	a4,-1220(a4) # ffffffffc02b06f8 <npage>
ffffffffc0201bc4:	00e7ff63          	bgeu	a5,a4,ffffffffc0201be2 <get_page+0x50>
ffffffffc0201bc8:	60a2                	ld	ra,8(sp)
ffffffffc0201bca:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201bcc:	fff80537          	lui	a0,0xfff80
ffffffffc0201bd0:	97aa                	add	a5,a5,a0
ffffffffc0201bd2:	079a                	slli	a5,a5,0x6
ffffffffc0201bd4:	000af517          	auipc	a0,0xaf
ffffffffc0201bd8:	b2c53503          	ld	a0,-1236(a0) # ffffffffc02b0700 <pages>
ffffffffc0201bdc:	953e                	add	a0,a0,a5
ffffffffc0201bde:	0141                	addi	sp,sp,16
ffffffffc0201be0:	8082                	ret
ffffffffc0201be2:	cd3ff0ef          	jal	ra,ffffffffc02018b4 <pa2page.part.0>

ffffffffc0201be6 <unmap_range>:
        tlb_invalidate(pgdir, la);
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc0201be6:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201be8:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0201bec:	f486                	sd	ra,104(sp)
ffffffffc0201bee:	f0a2                	sd	s0,96(sp)
ffffffffc0201bf0:	eca6                	sd	s1,88(sp)
ffffffffc0201bf2:	e8ca                	sd	s2,80(sp)
ffffffffc0201bf4:	e4ce                	sd	s3,72(sp)
ffffffffc0201bf6:	e0d2                	sd	s4,64(sp)
ffffffffc0201bf8:	fc56                	sd	s5,56(sp)
ffffffffc0201bfa:	f85a                	sd	s6,48(sp)
ffffffffc0201bfc:	f45e                	sd	s7,40(sp)
ffffffffc0201bfe:	f062                	sd	s8,32(sp)
ffffffffc0201c00:	ec66                	sd	s9,24(sp)
ffffffffc0201c02:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201c04:	17d2                	slli	a5,a5,0x34
ffffffffc0201c06:	e3ed                	bnez	a5,ffffffffc0201ce8 <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc0201c08:	002007b7          	lui	a5,0x200
ffffffffc0201c0c:	842e                	mv	s0,a1
ffffffffc0201c0e:	0ef5ed63          	bltu	a1,a5,ffffffffc0201d08 <unmap_range+0x122>
ffffffffc0201c12:	8932                	mv	s2,a2
ffffffffc0201c14:	0ec5fa63          	bgeu	a1,a2,ffffffffc0201d08 <unmap_range+0x122>
ffffffffc0201c18:	4785                	li	a5,1
ffffffffc0201c1a:	07fe                	slli	a5,a5,0x1f
ffffffffc0201c1c:	0ec7e663          	bltu	a5,a2,ffffffffc0201d08 <unmap_range+0x122>
ffffffffc0201c20:	89aa                	mv	s3,a0
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0201c22:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc0201c24:	000afc97          	auipc	s9,0xaf
ffffffffc0201c28:	ad4c8c93          	addi	s9,s9,-1324 # ffffffffc02b06f8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c2c:	000afc17          	auipc	s8,0xaf
ffffffffc0201c30:	ad4c0c13          	addi	s8,s8,-1324 # ffffffffc02b0700 <pages>
ffffffffc0201c34:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0201c38:	000afd17          	auipc	s10,0xaf
ffffffffc0201c3c:	ad0d0d13          	addi	s10,s10,-1328 # ffffffffc02b0708 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0201c40:	00200b37          	lui	s6,0x200
ffffffffc0201c44:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0201c48:	4601                	li	a2,0
ffffffffc0201c4a:	85a2                	mv	a1,s0
ffffffffc0201c4c:	854e                	mv	a0,s3
ffffffffc0201c4e:	d1dff0ef          	jal	ra,ffffffffc020196a <get_pte>
ffffffffc0201c52:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc0201c54:	cd29                	beqz	a0,ffffffffc0201cae <unmap_range+0xc8>
        if (*ptep != 0)
ffffffffc0201c56:	611c                	ld	a5,0(a0)
ffffffffc0201c58:	e395                	bnez	a5,ffffffffc0201c7c <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0201c5a:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0201c5c:	ff2466e3          	bltu	s0,s2,ffffffffc0201c48 <unmap_range+0x62>
}
ffffffffc0201c60:	70a6                	ld	ra,104(sp)
ffffffffc0201c62:	7406                	ld	s0,96(sp)
ffffffffc0201c64:	64e6                	ld	s1,88(sp)
ffffffffc0201c66:	6946                	ld	s2,80(sp)
ffffffffc0201c68:	69a6                	ld	s3,72(sp)
ffffffffc0201c6a:	6a06                	ld	s4,64(sp)
ffffffffc0201c6c:	7ae2                	ld	s5,56(sp)
ffffffffc0201c6e:	7b42                	ld	s6,48(sp)
ffffffffc0201c70:	7ba2                	ld	s7,40(sp)
ffffffffc0201c72:	7c02                	ld	s8,32(sp)
ffffffffc0201c74:	6ce2                	ld	s9,24(sp)
ffffffffc0201c76:	6d42                	ld	s10,16(sp)
ffffffffc0201c78:	6165                	addi	sp,sp,112
ffffffffc0201c7a:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc0201c7c:	0017f713          	andi	a4,a5,1
ffffffffc0201c80:	df69                	beqz	a4,ffffffffc0201c5a <unmap_range+0x74>
    if (PPN(pa) >= npage)
ffffffffc0201c82:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201c86:	078a                	slli	a5,a5,0x2
ffffffffc0201c88:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201c8a:	08e7ff63          	bgeu	a5,a4,ffffffffc0201d28 <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c8e:	000c3503          	ld	a0,0(s8)
ffffffffc0201c92:	97de                	add	a5,a5,s7
ffffffffc0201c94:	079a                	slli	a5,a5,0x6
ffffffffc0201c96:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201c98:	411c                	lw	a5,0(a0)
ffffffffc0201c9a:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201c9e:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc0201ca0:	cf11                	beqz	a4,ffffffffc0201cbc <unmap_range+0xd6>
        *ptep = 0;
ffffffffc0201ca2:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201ca6:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0201caa:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0201cac:	bf45                	j	ffffffffc0201c5c <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0201cae:	945a                	add	s0,s0,s6
ffffffffc0201cb0:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0201cb4:	d455                	beqz	s0,ffffffffc0201c60 <unmap_range+0x7a>
ffffffffc0201cb6:	f92469e3          	bltu	s0,s2,ffffffffc0201c48 <unmap_range+0x62>
ffffffffc0201cba:	b75d                	j	ffffffffc0201c60 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201cbc:	100027f3          	csrr	a5,sstatus
ffffffffc0201cc0:	8b89                	andi	a5,a5,2
ffffffffc0201cc2:	e799                	bnez	a5,ffffffffc0201cd0 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc0201cc4:	000d3783          	ld	a5,0(s10)
ffffffffc0201cc8:	4585                	li	a1,1
ffffffffc0201cca:	739c                	ld	a5,32(a5)
ffffffffc0201ccc:	9782                	jalr	a5
    if (flag)
ffffffffc0201cce:	bfd1                	j	ffffffffc0201ca2 <unmap_range+0xbc>
ffffffffc0201cd0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201cd2:	ca3fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc0201cd6:	000d3783          	ld	a5,0(s10)
ffffffffc0201cda:	6522                	ld	a0,8(sp)
ffffffffc0201cdc:	4585                	li	a1,1
ffffffffc0201cde:	739c                	ld	a5,32(a5)
ffffffffc0201ce0:	9782                	jalr	a5
        intr_enable();
ffffffffc0201ce2:	c8dfe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0201ce6:	bf75                	j	ffffffffc0201ca2 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201ce8:	00004697          	auipc	a3,0x4
ffffffffc0201cec:	fb068693          	addi	a3,a3,-80 # ffffffffc0205c98 <default_pmm_manager+0x160>
ffffffffc0201cf0:	00004617          	auipc	a2,0x4
ffffffffc0201cf4:	c4860613          	addi	a2,a2,-952 # ffffffffc0205938 <commands+0x620>
ffffffffc0201cf8:	13600593          	li	a1,310
ffffffffc0201cfc:	00004517          	auipc	a0,0x4
ffffffffc0201d00:	f8c50513          	addi	a0,a0,-116 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0201d04:	f4afe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0201d08:	00004697          	auipc	a3,0x4
ffffffffc0201d0c:	fc068693          	addi	a3,a3,-64 # ffffffffc0205cc8 <default_pmm_manager+0x190>
ffffffffc0201d10:	00004617          	auipc	a2,0x4
ffffffffc0201d14:	c2860613          	addi	a2,a2,-984 # ffffffffc0205938 <commands+0x620>
ffffffffc0201d18:	13700593          	li	a1,311
ffffffffc0201d1c:	00004517          	auipc	a0,0x4
ffffffffc0201d20:	f6c50513          	addi	a0,a0,-148 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0201d24:	f2afe0ef          	jal	ra,ffffffffc020044e <__panic>
ffffffffc0201d28:	b8dff0ef          	jal	ra,ffffffffc02018b4 <pa2page.part.0>

ffffffffc0201d2c <exit_range>:
{
ffffffffc0201d2c:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201d2e:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0201d32:	fc86                	sd	ra,120(sp)
ffffffffc0201d34:	f8a2                	sd	s0,112(sp)
ffffffffc0201d36:	f4a6                	sd	s1,104(sp)
ffffffffc0201d38:	f0ca                	sd	s2,96(sp)
ffffffffc0201d3a:	ecce                	sd	s3,88(sp)
ffffffffc0201d3c:	e8d2                	sd	s4,80(sp)
ffffffffc0201d3e:	e4d6                	sd	s5,72(sp)
ffffffffc0201d40:	e0da                	sd	s6,64(sp)
ffffffffc0201d42:	fc5e                	sd	s7,56(sp)
ffffffffc0201d44:	f862                	sd	s8,48(sp)
ffffffffc0201d46:	f466                	sd	s9,40(sp)
ffffffffc0201d48:	f06a                	sd	s10,32(sp)
ffffffffc0201d4a:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201d4c:	17d2                	slli	a5,a5,0x34
ffffffffc0201d4e:	20079a63          	bnez	a5,ffffffffc0201f62 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc0201d52:	002007b7          	lui	a5,0x200
ffffffffc0201d56:	24f5e463          	bltu	a1,a5,ffffffffc0201f9e <exit_range+0x272>
ffffffffc0201d5a:	8ab2                	mv	s5,a2
ffffffffc0201d5c:	24c5f163          	bgeu	a1,a2,ffffffffc0201f9e <exit_range+0x272>
ffffffffc0201d60:	4785                	li	a5,1
ffffffffc0201d62:	07fe                	slli	a5,a5,0x1f
ffffffffc0201d64:	22c7ed63          	bltu	a5,a2,ffffffffc0201f9e <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0201d68:	c00009b7          	lui	s3,0xc0000
ffffffffc0201d6c:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0201d70:	ffe00937          	lui	s2,0xffe00
ffffffffc0201d74:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc0201d78:	5cfd                	li	s9,-1
ffffffffc0201d7a:	8c2a                	mv	s8,a0
ffffffffc0201d7c:	0125f933          	and	s2,a1,s2
ffffffffc0201d80:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage)
ffffffffc0201d82:	000afd17          	auipc	s10,0xaf
ffffffffc0201d86:	976d0d13          	addi	s10,s10,-1674 # ffffffffc02b06f8 <npage>
    return KADDR(page2pa(page));
ffffffffc0201d8a:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0201d8e:	000af717          	auipc	a4,0xaf
ffffffffc0201d92:	97270713          	addi	a4,a4,-1678 # ffffffffc02b0700 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc0201d96:	000afd97          	auipc	s11,0xaf
ffffffffc0201d9a:	972d8d93          	addi	s11,s11,-1678 # ffffffffc02b0708 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0201d9e:	c0000437          	lui	s0,0xc0000
ffffffffc0201da2:	944e                	add	s0,s0,s3
ffffffffc0201da4:	8079                	srli	s0,s0,0x1e
ffffffffc0201da6:	1ff47413          	andi	s0,s0,511
ffffffffc0201daa:	040e                	slli	s0,s0,0x3
ffffffffc0201dac:	9462                	add	s0,s0,s8
ffffffffc0201dae:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4798>
        if (pde1 & PTE_V)
ffffffffc0201db2:	001a7793          	andi	a5,s4,1
ffffffffc0201db6:	eb99                	bnez	a5,ffffffffc0201dcc <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc0201db8:	12098463          	beqz	s3,ffffffffc0201ee0 <exit_range+0x1b4>
ffffffffc0201dbc:	400007b7          	lui	a5,0x40000
ffffffffc0201dc0:	97ce                	add	a5,a5,s3
ffffffffc0201dc2:	894e                	mv	s2,s3
ffffffffc0201dc4:	1159fe63          	bgeu	s3,s5,ffffffffc0201ee0 <exit_range+0x1b4>
ffffffffc0201dc8:	89be                	mv	s3,a5
ffffffffc0201dca:	bfd1                	j	ffffffffc0201d9e <exit_range+0x72>
    if (PPN(pa) >= npage)
ffffffffc0201dcc:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201dd0:	0a0a                	slli	s4,s4,0x2
ffffffffc0201dd2:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage)
ffffffffc0201dd6:	1cfa7263          	bgeu	s4,a5,ffffffffc0201f9a <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201dda:	fff80637          	lui	a2,0xfff80
ffffffffc0201dde:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0201de0:	000806b7          	lui	a3,0x80
ffffffffc0201de4:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0201de6:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0201dea:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201dec:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201dee:	18f5fa63          	bgeu	a1,a5,ffffffffc0201f82 <exit_range+0x256>
ffffffffc0201df2:	000af817          	auipc	a6,0xaf
ffffffffc0201df6:	91e80813          	addi	a6,a6,-1762 # ffffffffc02b0710 <va_pa_offset>
ffffffffc0201dfa:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0201dfe:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0201e00:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0201e04:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0201e06:	00080337          	lui	t1,0x80
ffffffffc0201e0a:	6885                	lui	a7,0x1
ffffffffc0201e0c:	a819                	j	ffffffffc0201e22 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc0201e0e:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0201e10:	002007b7          	lui	a5,0x200
ffffffffc0201e14:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0201e16:	08090c63          	beqz	s2,ffffffffc0201eae <exit_range+0x182>
ffffffffc0201e1a:	09397a63          	bgeu	s2,s3,ffffffffc0201eae <exit_range+0x182>
ffffffffc0201e1e:	0f597063          	bgeu	s2,s5,ffffffffc0201efe <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0201e22:	01595493          	srli	s1,s2,0x15
ffffffffc0201e26:	1ff4f493          	andi	s1,s1,511
ffffffffc0201e2a:	048e                	slli	s1,s1,0x3
ffffffffc0201e2c:	94da                	add	s1,s1,s6
ffffffffc0201e2e:	609c                	ld	a5,0(s1)
                if (pde0 & PTE_V)
ffffffffc0201e30:	0017f693          	andi	a3,a5,1
ffffffffc0201e34:	dee9                	beqz	a3,ffffffffc0201e0e <exit_range+0xe2>
    if (PPN(pa) >= npage)
ffffffffc0201e36:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e3a:	078a                	slli	a5,a5,0x2
ffffffffc0201e3c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201e3e:	14b7fe63          	bgeu	a5,a1,ffffffffc0201f9a <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e42:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0201e44:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc0201e48:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0201e4c:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e50:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201e52:	12bef863          	bgeu	t4,a1,ffffffffc0201f82 <exit_range+0x256>
ffffffffc0201e56:	00083783          	ld	a5,0(a6)
ffffffffc0201e5a:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0201e5c:	011685b3          	add	a1,a3,a7
                        if (pt[i] & PTE_V)
ffffffffc0201e60:	629c                	ld	a5,0(a3)
ffffffffc0201e62:	8b85                	andi	a5,a5,1
ffffffffc0201e64:	f7d5                	bnez	a5,ffffffffc0201e10 <exit_range+0xe4>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0201e66:	06a1                	addi	a3,a3,8
ffffffffc0201e68:	fed59ce3          	bne	a1,a3,ffffffffc0201e60 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e6c:	631c                	ld	a5,0(a4)
ffffffffc0201e6e:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e70:	100027f3          	csrr	a5,sstatus
ffffffffc0201e74:	8b89                	andi	a5,a5,2
ffffffffc0201e76:	e7d9                	bnez	a5,ffffffffc0201f04 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0201e78:	000db783          	ld	a5,0(s11)
ffffffffc0201e7c:	4585                	li	a1,1
ffffffffc0201e7e:	e032                	sd	a2,0(sp)
ffffffffc0201e80:	739c                	ld	a5,32(a5)
ffffffffc0201e82:	9782                	jalr	a5
    if (flag)
ffffffffc0201e84:	6602                	ld	a2,0(sp)
ffffffffc0201e86:	000af817          	auipc	a6,0xaf
ffffffffc0201e8a:	88a80813          	addi	a6,a6,-1910 # ffffffffc02b0710 <va_pa_offset>
ffffffffc0201e8e:	fff80e37          	lui	t3,0xfff80
ffffffffc0201e92:	00080337          	lui	t1,0x80
ffffffffc0201e96:	6885                	lui	a7,0x1
ffffffffc0201e98:	000af717          	auipc	a4,0xaf
ffffffffc0201e9c:	86870713          	addi	a4,a4,-1944 # ffffffffc02b0700 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0201ea0:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0201ea4:	002007b7          	lui	a5,0x200
ffffffffc0201ea8:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0201eaa:	f60918e3          	bnez	s2,ffffffffc0201e1a <exit_range+0xee>
            if (free_pd0)
ffffffffc0201eae:	f00b85e3          	beqz	s7,ffffffffc0201db8 <exit_range+0x8c>
    if (PPN(pa) >= npage)
ffffffffc0201eb2:	000d3783          	ld	a5,0(s10)
ffffffffc0201eb6:	0efa7263          	bgeu	s4,a5,ffffffffc0201f9a <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eba:	6308                	ld	a0,0(a4)
ffffffffc0201ebc:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201ebe:	100027f3          	csrr	a5,sstatus
ffffffffc0201ec2:	8b89                	andi	a5,a5,2
ffffffffc0201ec4:	efad                	bnez	a5,ffffffffc0201f3e <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc0201ec6:	000db783          	ld	a5,0(s11)
ffffffffc0201eca:	4585                	li	a1,1
ffffffffc0201ecc:	739c                	ld	a5,32(a5)
ffffffffc0201ece:	9782                	jalr	a5
ffffffffc0201ed0:	000af717          	auipc	a4,0xaf
ffffffffc0201ed4:	83070713          	addi	a4,a4,-2000 # ffffffffc02b0700 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0201ed8:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0201edc:	ee0990e3          	bnez	s3,ffffffffc0201dbc <exit_range+0x90>
}
ffffffffc0201ee0:	70e6                	ld	ra,120(sp)
ffffffffc0201ee2:	7446                	ld	s0,112(sp)
ffffffffc0201ee4:	74a6                	ld	s1,104(sp)
ffffffffc0201ee6:	7906                	ld	s2,96(sp)
ffffffffc0201ee8:	69e6                	ld	s3,88(sp)
ffffffffc0201eea:	6a46                	ld	s4,80(sp)
ffffffffc0201eec:	6aa6                	ld	s5,72(sp)
ffffffffc0201eee:	6b06                	ld	s6,64(sp)
ffffffffc0201ef0:	7be2                	ld	s7,56(sp)
ffffffffc0201ef2:	7c42                	ld	s8,48(sp)
ffffffffc0201ef4:	7ca2                	ld	s9,40(sp)
ffffffffc0201ef6:	7d02                	ld	s10,32(sp)
ffffffffc0201ef8:	6de2                	ld	s11,24(sp)
ffffffffc0201efa:	6109                	addi	sp,sp,128
ffffffffc0201efc:	8082                	ret
            if (free_pd0)
ffffffffc0201efe:	ea0b8fe3          	beqz	s7,ffffffffc0201dbc <exit_range+0x90>
ffffffffc0201f02:	bf45                	j	ffffffffc0201eb2 <exit_range+0x186>
ffffffffc0201f04:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0201f06:	e42a                	sd	a0,8(sp)
ffffffffc0201f08:	a6dfe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f0c:	000db783          	ld	a5,0(s11)
ffffffffc0201f10:	6522                	ld	a0,8(sp)
ffffffffc0201f12:	4585                	li	a1,1
ffffffffc0201f14:	739c                	ld	a5,32(a5)
ffffffffc0201f16:	9782                	jalr	a5
        intr_enable();
ffffffffc0201f18:	a57fe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0201f1c:	6602                	ld	a2,0(sp)
ffffffffc0201f1e:	000ae717          	auipc	a4,0xae
ffffffffc0201f22:	7e270713          	addi	a4,a4,2018 # ffffffffc02b0700 <pages>
ffffffffc0201f26:	6885                	lui	a7,0x1
ffffffffc0201f28:	00080337          	lui	t1,0x80
ffffffffc0201f2c:	fff80e37          	lui	t3,0xfff80
ffffffffc0201f30:	000ae817          	auipc	a6,0xae
ffffffffc0201f34:	7e080813          	addi	a6,a6,2016 # ffffffffc02b0710 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0201f38:	0004b023          	sd	zero,0(s1)
ffffffffc0201f3c:	b7a5                	j	ffffffffc0201ea4 <exit_range+0x178>
ffffffffc0201f3e:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0201f40:	a35fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f44:	000db783          	ld	a5,0(s11)
ffffffffc0201f48:	6502                	ld	a0,0(sp)
ffffffffc0201f4a:	4585                	li	a1,1
ffffffffc0201f4c:	739c                	ld	a5,32(a5)
ffffffffc0201f4e:	9782                	jalr	a5
        intr_enable();
ffffffffc0201f50:	a1ffe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0201f54:	000ae717          	auipc	a4,0xae
ffffffffc0201f58:	7ac70713          	addi	a4,a4,1964 # ffffffffc02b0700 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0201f5c:	00043023          	sd	zero,0(s0)
ffffffffc0201f60:	bfb5                	j	ffffffffc0201edc <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201f62:	00004697          	auipc	a3,0x4
ffffffffc0201f66:	d3668693          	addi	a3,a3,-714 # ffffffffc0205c98 <default_pmm_manager+0x160>
ffffffffc0201f6a:	00004617          	auipc	a2,0x4
ffffffffc0201f6e:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0205938 <commands+0x620>
ffffffffc0201f72:	14b00593          	li	a1,331
ffffffffc0201f76:	00004517          	auipc	a0,0x4
ffffffffc0201f7a:	d1250513          	addi	a0,a0,-750 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0201f7e:	cd0fe0ef          	jal	ra,ffffffffc020044e <__panic>
    return KADDR(page2pa(page));
ffffffffc0201f82:	00004617          	auipc	a2,0x4
ffffffffc0201f86:	bee60613          	addi	a2,a2,-1042 # ffffffffc0205b70 <default_pmm_manager+0x38>
ffffffffc0201f8a:	07100593          	li	a1,113
ffffffffc0201f8e:	00004517          	auipc	a0,0x4
ffffffffc0201f92:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc0201f96:	cb8fe0ef          	jal	ra,ffffffffc020044e <__panic>
ffffffffc0201f9a:	91bff0ef          	jal	ra,ffffffffc02018b4 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0201f9e:	00004697          	auipc	a3,0x4
ffffffffc0201fa2:	d2a68693          	addi	a3,a3,-726 # ffffffffc0205cc8 <default_pmm_manager+0x190>
ffffffffc0201fa6:	00004617          	auipc	a2,0x4
ffffffffc0201faa:	99260613          	addi	a2,a2,-1646 # ffffffffc0205938 <commands+0x620>
ffffffffc0201fae:	14c00593          	li	a1,332
ffffffffc0201fb2:	00004517          	auipc	a0,0x4
ffffffffc0201fb6:	cd650513          	addi	a0,a0,-810 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0201fba:	c94fe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0201fbe <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201fbe:	715d                	addi	sp,sp,-80
ffffffffc0201fc0:	f052                	sd	s4,32(sp)
ffffffffc0201fc2:	8a32                	mv	s4,a2
ffffffffc0201fc4:	e0a2                	sd	s0,64(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201fc6:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201fc8:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201fca:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201fcc:	fc26                	sd	s1,56(sp)
ffffffffc0201fce:	e486                	sd	ra,72(sp)
ffffffffc0201fd0:	f84a                	sd	s2,48(sp)
ffffffffc0201fd2:	f44e                	sd	s3,40(sp)
ffffffffc0201fd4:	ec56                	sd	s5,24(sp)
ffffffffc0201fd6:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201fd8:	993ff0ef          	jal	ra,ffffffffc020196a <get_pte>
    if (ptep == NULL) return -E_NO_MEM;
ffffffffc0201fdc:	c171                	beqz	a0,ffffffffc02020a0 <page_insert+0xe2>
    page->ref += 1;
ffffffffc0201fde:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201fe0:	611c                	ld	a5,0(a0)
ffffffffc0201fe2:	89aa                	mv	s3,a0
ffffffffc0201fe4:	0016871b          	addiw	a4,a3,1
ffffffffc0201fe8:	c018                	sw	a4,0(s0)
ffffffffc0201fea:	0017f713          	andi	a4,a5,1
ffffffffc0201fee:	ef05                	bnez	a4,ffffffffc0202026 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0201ff0:	000ae717          	auipc	a4,0xae
ffffffffc0201ff4:	71073703          	ld	a4,1808(a4) # ffffffffc02b0700 <pages>
ffffffffc0201ff8:	8c19                	sub	s0,s0,a4
ffffffffc0201ffa:	000807b7          	lui	a5,0x80
ffffffffc0201ffe:	8419                	srai	s0,s0,0x6
ffffffffc0202000:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202002:	042a                	slli	s0,s0,0xa
ffffffffc0202004:	8cc1                	or	s1,s1,s0
ffffffffc0202006:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), perm | PTE_V);
ffffffffc020200a:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4798>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020200e:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0202012:	4501                	li	a0,0
}
ffffffffc0202014:	60a6                	ld	ra,72(sp)
ffffffffc0202016:	6406                	ld	s0,64(sp)
ffffffffc0202018:	74e2                	ld	s1,56(sp)
ffffffffc020201a:	7942                	ld	s2,48(sp)
ffffffffc020201c:	79a2                	ld	s3,40(sp)
ffffffffc020201e:	7a02                	ld	s4,32(sp)
ffffffffc0202020:	6ae2                	ld	s5,24(sp)
ffffffffc0202022:	6161                	addi	sp,sp,80
ffffffffc0202024:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202026:	078a                	slli	a5,a5,0x2
ffffffffc0202028:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020202a:	000ae717          	auipc	a4,0xae
ffffffffc020202e:	6ce73703          	ld	a4,1742(a4) # ffffffffc02b06f8 <npage>
ffffffffc0202032:	06e7f963          	bgeu	a5,a4,ffffffffc02020a4 <page_insert+0xe6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202036:	000aea97          	auipc	s5,0xae
ffffffffc020203a:	6caa8a93          	addi	s5,s5,1738 # ffffffffc02b0700 <pages>
ffffffffc020203e:	000ab703          	ld	a4,0(s5)
ffffffffc0202042:	fff80937          	lui	s2,0xfff80
ffffffffc0202046:	993e                	add	s2,s2,a5
ffffffffc0202048:	091a                	slli	s2,s2,0x6
ffffffffc020204a:	01270533          	add	a0,a4,s2
        if (old == page) page_ref_dec(page);
ffffffffc020204e:	02a40763          	beq	s0,a0,ffffffffc020207c <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0202052:	411c                	lw	a5,0(a0)
            *ptep = 0;
ffffffffc0202054:	0009b023          	sd	zero,0(s3)
ffffffffc0202058:	fff7869b          	addiw	a3,a5,-1
ffffffffc020205c:	c114                	sw	a3,0(a0)
            if (page_ref_dec(old) == 0) free_page(old);
ffffffffc020205e:	fec9                	bnez	a3,ffffffffc0201ff8 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202060:	100027f3          	csrr	a5,sstatus
ffffffffc0202064:	8b89                	andi	a5,a5,2
ffffffffc0202066:	ef89                	bnez	a5,ffffffffc0202080 <page_insert+0xc2>
        pmm_manager->free_pages(base, n);
ffffffffc0202068:	000ae797          	auipc	a5,0xae
ffffffffc020206c:	6a07b783          	ld	a5,1696(a5) # ffffffffc02b0708 <pmm_manager>
ffffffffc0202070:	739c                	ld	a5,32(a5)
ffffffffc0202072:	4585                	li	a1,1
ffffffffc0202074:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0202076:	000ab703          	ld	a4,0(s5)
ffffffffc020207a:	bfbd                	j	ffffffffc0201ff8 <page_insert+0x3a>
    page->ref -= 1;
ffffffffc020207c:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020207e:	bfad                	j	ffffffffc0201ff8 <page_insert+0x3a>
        intr_disable();
ffffffffc0202080:	e42a                	sd	a0,8(sp)
ffffffffc0202082:	8f3fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc0202086:	000ae797          	auipc	a5,0xae
ffffffffc020208a:	6827b783          	ld	a5,1666(a5) # ffffffffc02b0708 <pmm_manager>
ffffffffc020208e:	739c                	ld	a5,32(a5)
ffffffffc0202090:	6522                	ld	a0,8(sp)
ffffffffc0202092:	4585                	li	a1,1
ffffffffc0202094:	9782                	jalr	a5
        intr_enable();
ffffffffc0202096:	8d9fe0ef          	jal	ra,ffffffffc020096e <intr_enable>
    return page - pages + nbase;
ffffffffc020209a:	000ab703          	ld	a4,0(s5)
ffffffffc020209e:	bfa9                	j	ffffffffc0201ff8 <page_insert+0x3a>
    if (ptep == NULL) return -E_NO_MEM;
ffffffffc02020a0:	5571                	li	a0,-4
ffffffffc02020a2:	bf8d                	j	ffffffffc0202014 <page_insert+0x56>
ffffffffc02020a4:	811ff0ef          	jal	ra,ffffffffc02018b4 <pa2page.part.0>

ffffffffc02020a8 <copy_range>:
{
ffffffffc02020a8:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020aa:	00d667b3          	or	a5,a2,a3
{
ffffffffc02020ae:	e4d6                	sd	s5,72(sp)
ffffffffc02020b0:	fc86                	sd	ra,120(sp)
ffffffffc02020b2:	8aba                	mv	s5,a4
ffffffffc02020b4:	f8a2                	sd	s0,112(sp)
ffffffffc02020b6:	f4a6                	sd	s1,104(sp)
ffffffffc02020b8:	f0ca                	sd	s2,96(sp)
ffffffffc02020ba:	ecce                	sd	s3,88(sp)
ffffffffc02020bc:	e8d2                	sd	s4,80(sp)
ffffffffc02020be:	e0da                	sd	s6,64(sp)
ffffffffc02020c0:	fc5e                	sd	s7,56(sp)
ffffffffc02020c2:	f862                	sd	s8,48(sp)
ffffffffc02020c4:	f466                	sd	s9,40(sp)
ffffffffc02020c6:	f06a                	sd	s10,32(sp)
ffffffffc02020c8:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020ca:	03479713          	slli	a4,a5,0x34
ffffffffc02020ce:	20071763          	bnez	a4,ffffffffc02022dc <copy_range+0x234>
    assert(USER_ACCESS(start, end));
ffffffffc02020d2:	002007b7          	lui	a5,0x200
ffffffffc02020d6:	8db2                	mv	s11,a2
ffffffffc02020d8:	1ef66263          	bltu	a2,a5,ffffffffc02022bc <copy_range+0x214>
ffffffffc02020dc:	1ed67063          	bgeu	a2,a3,ffffffffc02022bc <copy_range+0x214>
ffffffffc02020e0:	4785                	li	a5,1
ffffffffc02020e2:	07fe                	slli	a5,a5,0x1f
ffffffffc02020e4:	1cd7ec63          	bltu	a5,a3,ffffffffc02022bc <copy_range+0x214>
ffffffffc02020e8:	fff68413          	addi	s0,a3,-1
ffffffffc02020ec:	77fd                	lui	a5,0xfffff
ffffffffc02020ee:	8c11                	sub	s0,s0,a2
ffffffffc02020f0:	8c7d                	and	s0,s0,a5
ffffffffc02020f2:	6785                	lui	a5,0x1
ffffffffc02020f4:	97b2                	add	a5,a5,a2
    return KADDR(page2pa(page));
ffffffffc02020f6:	5bfd                	li	s7,-1
ffffffffc02020f8:	943e                	add	s0,s0,a5
ffffffffc02020fa:	00cbd793          	srli	a5,s7,0xc
ffffffffc02020fe:	8b2a                	mv	s6,a0
ffffffffc0202100:	84ae                	mv	s1,a1
        if (ptep == NULL || !(*ptep & PTE_V) || !(*ptep & PTE_U))
ffffffffc0202102:	4945                	li	s2,17
    if (PPN(pa) >= npage)
ffffffffc0202104:	000aea17          	auipc	s4,0xae
ffffffffc0202108:	5f4a0a13          	addi	s4,s4,1524 # ffffffffc02b06f8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020210c:	000ae997          	auipc	s3,0xae
ffffffffc0202110:	5f498993          	addi	s3,s3,1524 # ffffffffc02b0700 <pages>
    return KADDR(page2pa(page));
ffffffffc0202114:	e43e                	sd	a5,8(sp)
        page = pmm_manager->alloc_pages(n);
ffffffffc0202116:	000aec97          	auipc	s9,0xae
ffffffffc020211a:	5f2c8c93          	addi	s9,s9,1522 # ffffffffc02b0708 <pmm_manager>
ffffffffc020211e:	a029                	j	ffffffffc0202128 <copy_range+0x80>
    for (uintptr_t la = start; la < end; la += PGSIZE)
ffffffffc0202120:	6785                	lui	a5,0x1
ffffffffc0202122:	9dbe                	add	s11,s11,a5
ffffffffc0202124:	0e8d8963          	beq	s11,s0,ffffffffc0202216 <copy_range+0x16e>
        pte_t *ptep = get_pte(from, la, 0);
ffffffffc0202128:	4601                	li	a2,0
ffffffffc020212a:	85ee                	mv	a1,s11
ffffffffc020212c:	8526                	mv	a0,s1
ffffffffc020212e:	83dff0ef          	jal	ra,ffffffffc020196a <get_pte>
        if (ptep == NULL || !(*ptep & PTE_V) || !(*ptep & PTE_U))
ffffffffc0202132:	d57d                	beqz	a0,ffffffffc0202120 <copy_range+0x78>
ffffffffc0202134:	6114                	ld	a3,0(a0)
ffffffffc0202136:	0116f793          	andi	a5,a3,17
ffffffffc020213a:	ff2793e3          	bne	a5,s2,ffffffffc0202120 <copy_range+0x78>
    if (!(pte & PTE_V))
ffffffffc020213e:	0016f793          	andi	a5,a3,1
ffffffffc0202142:	16078163          	beqz	a5,ffffffffc02022a4 <copy_range+0x1fc>
    if (PPN(pa) >= npage)
ffffffffc0202146:	000a3703          	ld	a4,0(s4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020214a:	00269793          	slli	a5,a3,0x2
ffffffffc020214e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202150:	12e7f163          	bgeu	a5,a4,ffffffffc0202272 <copy_range+0x1ca>
    return &pages[PPN(pa) - nbase];
ffffffffc0202154:	0009b703          	ld	a4,0(s3)
ffffffffc0202158:	fff80637          	lui	a2,0xfff80
ffffffffc020215c:	97b2                	add	a5,a5,a2
ffffffffc020215e:	079a                	slli	a5,a5,0x6
ffffffffc0202160:	00f70d33          	add	s10,a4,a5
        uint32_t perm = *ptep & (PTE_R | PTE_W | PTE_X | PTE_U | PTE_G | PTE_A | PTE_D);
ffffffffc0202164:	0fe6fb93          	andi	s7,a3,254
        if (!share)
ffffffffc0202168:	060a9363          	bnez	s5,ffffffffc02021ce <copy_range+0x126>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020216c:	10002773          	csrr	a4,sstatus
ffffffffc0202170:	8b09                	andi	a4,a4,2
ffffffffc0202172:	e759                	bnez	a4,ffffffffc0202200 <copy_range+0x158>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202174:	000cb703          	ld	a4,0(s9)
ffffffffc0202178:	4505                	li	a0,1
ffffffffc020217a:	6f18                	ld	a4,24(a4)
ffffffffc020217c:	9702                	jalr	a4
ffffffffc020217e:	8c2a                	mv	s8,a0
            if ((dst_page = alloc_page()) == NULL)
ffffffffc0202180:	0a0c0c63          	beqz	s8,ffffffffc0202238 <copy_range+0x190>
    return page - pages + nbase;
ffffffffc0202184:	0009b703          	ld	a4,0(s3)
    return KADDR(page2pa(page));
ffffffffc0202188:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc020218a:	00080537          	lui	a0,0x80
ffffffffc020218e:	40ec0633          	sub	a2,s8,a4
ffffffffc0202192:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0202194:	000a3883          	ld	a7,0(s4)
    return page - pages + nbase;
ffffffffc0202198:	962a                	add	a2,a2,a0
    return KADDR(page2pa(page));
ffffffffc020219a:	00f675b3          	and	a1,a2,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc020219e:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02021a0:	0b15fc63          	bgeu	a1,a7,ffffffffc0202258 <copy_range+0x1b0>
    return page - pages + nbase;
ffffffffc02021a4:	40ed07b3          	sub	a5,s10,a4
    return KADDR(page2pa(page));
ffffffffc02021a8:	000ae717          	auipc	a4,0xae
ffffffffc02021ac:	56870713          	addi	a4,a4,1384 # ffffffffc02b0710 <va_pa_offset>
ffffffffc02021b0:	630c                	ld	a1,0(a4)
ffffffffc02021b2:	6722                	ld	a4,8(sp)
    return page - pages + nbase;
ffffffffc02021b4:	8799                	srai	a5,a5,0x6
ffffffffc02021b6:	97aa                	add	a5,a5,a0
    return KADDR(page2pa(page));
ffffffffc02021b8:	8f7d                	and	a4,a4,a5
ffffffffc02021ba:	00b60533          	add	a0,a2,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc02021be:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02021c0:	0d177563          	bgeu	a4,a7,ffffffffc020228a <copy_range+0x1e2>
            memcpy(page2kva(dst_page), page2kva(src_page), PGSIZE);
ffffffffc02021c4:	6605                	lui	a2,0x1
ffffffffc02021c6:	95be                	add	a1,a1,a5
ffffffffc02021c8:	6cd020ef          	jal	ra,ffffffffc0205094 <memcpy>
ffffffffc02021cc:	8d62                	mv	s10,s8
        int ret = page_insert(to, dst_page, la, perm);
ffffffffc02021ce:	86de                	mv	a3,s7
ffffffffc02021d0:	866e                	mv	a2,s11
ffffffffc02021d2:	85ea                	mv	a1,s10
ffffffffc02021d4:	855a                	mv	a0,s6
ffffffffc02021d6:	de9ff0ef          	jal	ra,ffffffffc0201fbe <page_insert>
ffffffffc02021da:	872a                	mv	a4,a0
        if (ret != 0)
ffffffffc02021dc:	d131                	beqz	a0,ffffffffc0202120 <copy_range+0x78>
            if (!share)
ffffffffc02021de:	020a9d63          	bnez	s5,ffffffffc0202218 <copy_range+0x170>
ffffffffc02021e2:	100026f3          	csrr	a3,sstatus
ffffffffc02021e6:	8a89                	andi	a3,a3,2
ffffffffc02021e8:	e42a                	sd	a0,8(sp)
ffffffffc02021ea:	eaa9                	bnez	a3,ffffffffc020223c <copy_range+0x194>
        pmm_manager->free_pages(base, n);
ffffffffc02021ec:	000ae697          	auipc	a3,0xae
ffffffffc02021f0:	51c6b683          	ld	a3,1308(a3) # ffffffffc02b0708 <pmm_manager>
ffffffffc02021f4:	7294                	ld	a3,32(a3)
ffffffffc02021f6:	4585                	li	a1,1
ffffffffc02021f8:	856a                	mv	a0,s10
ffffffffc02021fa:	9682                	jalr	a3
    if (flag)
ffffffffc02021fc:	6722                	ld	a4,8(sp)
ffffffffc02021fe:	a829                	j	ffffffffc0202218 <copy_range+0x170>
        intr_disable();
ffffffffc0202200:	f74fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202204:	000cb703          	ld	a4,0(s9)
ffffffffc0202208:	4505                	li	a0,1
ffffffffc020220a:	6f18                	ld	a4,24(a4)
ffffffffc020220c:	9702                	jalr	a4
ffffffffc020220e:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202210:	f5efe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202214:	b7b5                	j	ffffffffc0202180 <copy_range+0xd8>
    return 0;
ffffffffc0202216:	4701                	li	a4,0
}
ffffffffc0202218:	70e6                	ld	ra,120(sp)
ffffffffc020221a:	7446                	ld	s0,112(sp)
ffffffffc020221c:	74a6                	ld	s1,104(sp)
ffffffffc020221e:	7906                	ld	s2,96(sp)
ffffffffc0202220:	69e6                	ld	s3,88(sp)
ffffffffc0202222:	6a46                	ld	s4,80(sp)
ffffffffc0202224:	6aa6                	ld	s5,72(sp)
ffffffffc0202226:	6b06                	ld	s6,64(sp)
ffffffffc0202228:	7be2                	ld	s7,56(sp)
ffffffffc020222a:	7c42                	ld	s8,48(sp)
ffffffffc020222c:	7ca2                	ld	s9,40(sp)
ffffffffc020222e:	7d02                	ld	s10,32(sp)
ffffffffc0202230:	6de2                	ld	s11,24(sp)
ffffffffc0202232:	853a                	mv	a0,a4
ffffffffc0202234:	6109                	addi	sp,sp,128
ffffffffc0202236:	8082                	ret
                return -E_NO_MEM;
ffffffffc0202238:	5771                	li	a4,-4
ffffffffc020223a:	bff9                	j	ffffffffc0202218 <copy_range+0x170>
        intr_disable();
ffffffffc020223c:	f38fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202240:	000ae697          	auipc	a3,0xae
ffffffffc0202244:	4c86b683          	ld	a3,1224(a3) # ffffffffc02b0708 <pmm_manager>
ffffffffc0202248:	7294                	ld	a3,32(a3)
ffffffffc020224a:	4585                	li	a1,1
ffffffffc020224c:	856a                	mv	a0,s10
ffffffffc020224e:	9682                	jalr	a3
        intr_enable();
ffffffffc0202250:	f1efe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202254:	6722                	ld	a4,8(sp)
ffffffffc0202256:	b7c9                	j	ffffffffc0202218 <copy_range+0x170>
ffffffffc0202258:	86b2                	mv	a3,a2
ffffffffc020225a:	07100593          	li	a1,113
ffffffffc020225e:	00004617          	auipc	a2,0x4
ffffffffc0202262:	91260613          	addi	a2,a2,-1774 # ffffffffc0205b70 <default_pmm_manager+0x38>
ffffffffc0202266:	00004517          	auipc	a0,0x4
ffffffffc020226a:	93250513          	addi	a0,a0,-1742 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc020226e:	9e0fe0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202272:	00004617          	auipc	a2,0x4
ffffffffc0202276:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0205c40 <default_pmm_manager+0x108>
ffffffffc020227a:	06900593          	li	a1,105
ffffffffc020227e:	00004517          	auipc	a0,0x4
ffffffffc0202282:	91a50513          	addi	a0,a0,-1766 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc0202286:	9c8fe0ef          	jal	ra,ffffffffc020044e <__panic>
    return KADDR(page2pa(page));
ffffffffc020228a:	86be                	mv	a3,a5
ffffffffc020228c:	00004617          	auipc	a2,0x4
ffffffffc0202290:	8e460613          	addi	a2,a2,-1820 # ffffffffc0205b70 <default_pmm_manager+0x38>
ffffffffc0202294:	07100593          	li	a1,113
ffffffffc0202298:	00004517          	auipc	a0,0x4
ffffffffc020229c:	90050513          	addi	a0,a0,-1792 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc02022a0:	9aefe0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02022a4:	00004617          	auipc	a2,0x4
ffffffffc02022a8:	9bc60613          	addi	a2,a2,-1604 # ffffffffc0205c60 <default_pmm_manager+0x128>
ffffffffc02022ac:	07f00593          	li	a1,127
ffffffffc02022b0:	00004517          	auipc	a0,0x4
ffffffffc02022b4:	8e850513          	addi	a0,a0,-1816 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc02022b8:	996fe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02022bc:	00004697          	auipc	a3,0x4
ffffffffc02022c0:	a0c68693          	addi	a3,a3,-1524 # ffffffffc0205cc8 <default_pmm_manager+0x190>
ffffffffc02022c4:	00003617          	auipc	a2,0x3
ffffffffc02022c8:	67460613          	addi	a2,a2,1652 # ffffffffc0205938 <commands+0x620>
ffffffffc02022cc:	18d00593          	li	a1,397
ffffffffc02022d0:	00004517          	auipc	a0,0x4
ffffffffc02022d4:	9b850513          	addi	a0,a0,-1608 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc02022d8:	976fe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022dc:	00004697          	auipc	a3,0x4
ffffffffc02022e0:	9bc68693          	addi	a3,a3,-1604 # ffffffffc0205c98 <default_pmm_manager+0x160>
ffffffffc02022e4:	00003617          	auipc	a2,0x3
ffffffffc02022e8:	65460613          	addi	a2,a2,1620 # ffffffffc0205938 <commands+0x620>
ffffffffc02022ec:	18c00593          	li	a1,396
ffffffffc02022f0:	00004517          	auipc	a0,0x4
ffffffffc02022f4:	99850513          	addi	a0,a0,-1640 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc02022f8:	956fe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02022fc <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02022fc:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02022fe:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202300:	e822                	sd	s0,16(sp)
ffffffffc0202302:	ec06                	sd	ra,24(sp)
ffffffffc0202304:	e426                	sd	s1,8(sp)
ffffffffc0202306:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202308:	e62ff0ef          	jal	ra,ffffffffc020196a <get_pte>
    if (ptep != NULL && (*ptep & PTE_V)) {
ffffffffc020230c:	c509                	beqz	a0,ffffffffc0202316 <page_remove+0x1a>
ffffffffc020230e:	611c                	ld	a5,0(a0)
ffffffffc0202310:	0017f713          	andi	a4,a5,1
ffffffffc0202314:	e711                	bnez	a4,ffffffffc0202320 <page_remove+0x24>
}
ffffffffc0202316:	60e2                	ld	ra,24(sp)
ffffffffc0202318:	6442                	ld	s0,16(sp)
ffffffffc020231a:	64a2                	ld	s1,8(sp)
ffffffffc020231c:	6105                	addi	sp,sp,32
ffffffffc020231e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202320:	078a                	slli	a5,a5,0x2
ffffffffc0202322:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202324:	000ae717          	auipc	a4,0xae
ffffffffc0202328:	3d473703          	ld	a4,980(a4) # ffffffffc02b06f8 <npage>
ffffffffc020232c:	06e7f763          	bgeu	a5,a4,ffffffffc020239a <page_remove+0x9e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202330:	fff80737          	lui	a4,0xfff80
ffffffffc0202334:	97ba                	add	a5,a5,a4
ffffffffc0202336:	000ae497          	auipc	s1,0xae
ffffffffc020233a:	3ca4b483          	ld	s1,970(s1) # ffffffffc02b0700 <pages>
ffffffffc020233e:	079a                	slli	a5,a5,0x6
ffffffffc0202340:	94be                	add	s1,s1,a5
    page->ref -= 1;
ffffffffc0202342:	409c                	lw	a5,0(s1)
        *ptep = 0;
ffffffffc0202344:	00053023          	sd	zero,0(a0)
ffffffffc0202348:	fff7871b          	addiw	a4,a5,-1
ffffffffc020234c:	c098                	sw	a4,0(s1)
        if (page_ref_dec(page) == 0) free_page(page);
ffffffffc020234e:	cb01                	beqz	a4,ffffffffc020235e <page_remove+0x62>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202350:	12040073          	sfence.vma	s0
}
ffffffffc0202354:	60e2                	ld	ra,24(sp)
ffffffffc0202356:	6442                	ld	s0,16(sp)
ffffffffc0202358:	64a2                	ld	s1,8(sp)
ffffffffc020235a:	6105                	addi	sp,sp,32
ffffffffc020235c:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020235e:	100027f3          	csrr	a5,sstatus
ffffffffc0202362:	8b89                	andi	a5,a5,2
ffffffffc0202364:	ef81                	bnez	a5,ffffffffc020237c <page_remove+0x80>
        pmm_manager->free_pages(base, n);
ffffffffc0202366:	000ae797          	auipc	a5,0xae
ffffffffc020236a:	3a27b783          	ld	a5,930(a5) # ffffffffc02b0708 <pmm_manager>
ffffffffc020236e:	739c                	ld	a5,32(a5)
ffffffffc0202370:	4585                	li	a1,1
ffffffffc0202372:	8526                	mv	a0,s1
ffffffffc0202374:	9782                	jalr	a5
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202376:	12040073          	sfence.vma	s0
ffffffffc020237a:	bfe9                	j	ffffffffc0202354 <page_remove+0x58>
        intr_disable();
ffffffffc020237c:	df8fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202380:	000ae797          	auipc	a5,0xae
ffffffffc0202384:	3887b783          	ld	a5,904(a5) # ffffffffc02b0708 <pmm_manager>
ffffffffc0202388:	739c                	ld	a5,32(a5)
ffffffffc020238a:	4585                	li	a1,1
ffffffffc020238c:	8526                	mv	a0,s1
ffffffffc020238e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202390:	ddefe0ef          	jal	ra,ffffffffc020096e <intr_enable>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202394:	12040073          	sfence.vma	s0
ffffffffc0202398:	bf75                	j	ffffffffc0202354 <page_remove+0x58>
ffffffffc020239a:	d1aff0ef          	jal	ra,ffffffffc02018b4 <pa2page.part.0>

ffffffffc020239e <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020239e:	00003797          	auipc	a5,0x3
ffffffffc02023a2:	79a78793          	addi	a5,a5,1946 # ffffffffc0205b38 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02023a6:	638c                	ld	a1,0(a5)
{
ffffffffc02023a8:	7159                	addi	sp,sp,-112
ffffffffc02023aa:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02023ac:	00004517          	auipc	a0,0x4
ffffffffc02023b0:	93450513          	addi	a0,a0,-1740 # ffffffffc0205ce0 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc02023b4:	000aeb17          	auipc	s6,0xae
ffffffffc02023b8:	354b0b13          	addi	s6,s6,852 # ffffffffc02b0708 <pmm_manager>
{
ffffffffc02023bc:	f486                	sd	ra,104(sp)
ffffffffc02023be:	f0a2                	sd	s0,96(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02023c0:	00fb3023          	sd	a5,0(s6)
{
ffffffffc02023c4:	eca6                	sd	s1,88(sp)
ffffffffc02023c6:	e8ca                	sd	s2,80(sp)
ffffffffc02023c8:	e4ce                	sd	s3,72(sp)
ffffffffc02023ca:	e0d2                	sd	s4,64(sp)
ffffffffc02023cc:	fc56                	sd	s5,56(sp)
ffffffffc02023ce:	f45e                	sd	s7,40(sp)
ffffffffc02023d0:	f062                	sd	s8,32(sp)
ffffffffc02023d2:	ec66                	sd	s9,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02023d4:	dc1fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    pmm_manager->init();
ffffffffc02023d8:	000b3783          	ld	a5,0(s6)
ffffffffc02023dc:	679c                	ld	a5,8(a5)
ffffffffc02023de:	9782                	jalr	a5
    uint64_t mem_base = get_memory_base();
ffffffffc02023e0:	d7afe0ef          	jal	ra,ffffffffc020095a <get_memory_base>
ffffffffc02023e4:	842a                	mv	s0,a0
    uint64_t mem_size = get_memory_size();
ffffffffc02023e6:	d7efe0ef          	jal	ra,ffffffffc0200964 <get_memory_size>
    if (mem_size == 0 || mem_base != DRAM_BASE ||
ffffffffc02023ea:	800007b7          	lui	a5,0x80000
ffffffffc02023ee:	fff50713          	addi	a4,a0,-1
ffffffffc02023f2:	17f9                	addi	a5,a5,-2
ffffffffc02023f4:	3ee7eee3          	bltu	a5,a4,ffffffffc0202ff0 <pmm_init+0xc52>
ffffffffc02023f8:	4785                	li	a5,1
ffffffffc02023fa:	07fe                	slli	a5,a5,0x1f
ffffffffc02023fc:	3ef41ae3          	bne	s0,a5,ffffffffc0202ff0 <pmm_init+0xc52>
    if (mem_end > (DRAM_BASE + KMEMSIZE)) {
ffffffffc0202400:	43f00793          	li	a5,1087
    uint64_t mem_end = mem_base + mem_size;
ffffffffc0202404:	942a                	add	s0,s0,a0
    if (mem_end > (DRAM_BASE + KMEMSIZE)) {
ffffffffc0202406:	07d6                	slli	a5,a5,0x15
ffffffffc0202408:	5c87e563          	bltu	a5,s0,ffffffffc02029d2 <pmm_init+0x634>
    if (mem_end <= (DRAM_BASE + 0x200000)) {
ffffffffc020240c:	40100793          	li	a5,1025
ffffffffc0202410:	07d6                	slli	a5,a5,0x15
ffffffffc0202412:	3e87fbe3          	bgeu	a5,s0,ffffffffc0203008 <pmm_init+0xc6a>
    npage = PPN(mem_end);
ffffffffc0202416:	00c45613          	srli	a2,s0,0xc
    size_t page_count = npage - nbase;
ffffffffc020241a:	fff80737          	lui	a4,0xfff80
ffffffffc020241e:	9732                	add	a4,a4,a2
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202420:	7afd                	lui	s5,0xfffff
ffffffffc0202422:	57f5                	li	a5,-3
ffffffffc0202424:	000af697          	auipc	a3,0xaf
ffffffffc0202428:	30f68693          	addi	a3,a3,783 # ffffffffc02b1733 <end+0xfff>
ffffffffc020242c:	000ae997          	auipc	s3,0xae
ffffffffc0202430:	2e498993          	addi	s3,s3,740 # ffffffffc02b0710 <va_pa_offset>
ffffffffc0202434:	07fa                	slli	a5,a5,0x1e
    npage = PPN(mem_end);
ffffffffc0202436:	000ae917          	auipc	s2,0xae
ffffffffc020243a:	2c290913          	addi	s2,s2,706 # ffffffffc02b06f8 <npage>
ffffffffc020243e:	0156f6b3          	and	a3,a3,s5
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0202442:	000aeb97          	auipc	s7,0xae
ffffffffc0202446:	2beb8b93          	addi	s7,s7,702 # ffffffffc02b0700 <pages>
    npage = PPN(mem_end);
ffffffffc020244a:	00c93023          	sd	a2,0(s2)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020244e:	00f9b023          	sd	a5,0(s3)
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0202452:	00dbb023          	sd	a3,0(s7)
    uintptr_t metadata_start = PADDR(pages);
ffffffffc0202456:	c0200637          	lui	a2,0xc0200
ffffffffc020245a:	3cc6e3e3          	bltu	a3,a2,ffffffffc0203020 <pmm_init+0xc82>
ffffffffc020245e:	460d                	li	a2,3
ffffffffc0202460:	067a                	slli	a2,a2,0x1e
ffffffffc0202462:	9636                	add	a2,a2,a3
    uintptr_t metadata_size = page_count * sizeof(struct Page);
ffffffffc0202464:	071a                	slli	a4,a4,0x6
    if (metadata_start >= mem_end ||
ffffffffc0202466:	3c8679e3          	bgeu	a2,s0,ffffffffc0203038 <pmm_init+0xc9a>
        metadata_size > mem_end - metadata_start) {
ffffffffc020246a:	8f95                	sub	a5,a5,a3
ffffffffc020246c:	97a2                	add	a5,a5,s0
    if (metadata_start >= mem_end ||
ffffffffc020246e:	3ce7e5e3          	bltu	a5,a4,ffffffffc0203038 <pmm_init+0xc9a>
        ROUNDUP(metadata_start + metadata_size, PGSIZE);
ffffffffc0202472:	00005497          	auipc	s1,0x5
ffffffffc0202476:	b064b483          	ld	s1,-1274(s1) # ffffffffc0206f78 <error_string+0xc8>
ffffffffc020247a:	94b6                	add	s1,s1,a3
ffffffffc020247c:	94ba                	add	s1,s1,a4
ffffffffc020247e:	0154f4b3          	and	s1,s1,s5
    uintptr_t free_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0202482:	01547ab3          	and	s5,s0,s5
    if (free_start >= free_end) {
ffffffffc0202486:	4781                	li	a5,0
ffffffffc0202488:	4a05                	li	s4,1
ffffffffc020248a:	0154e663          	bltu	s1,s5,ffffffffc0202496 <pmm_init+0xf8>
ffffffffc020248e:	3c30006f          	j	ffffffffc0203050 <pmm_init+0xcb2>
        pages[i].flags = 0;
ffffffffc0202492:	000bb683          	ld	a3,0(s7)
ffffffffc0202496:	96be                	add	a3,a3,a5
ffffffffc0202498:	0006b423          	sd	zero,8(a3)
        pages[i].property = 0;
ffffffffc020249c:	0006a823          	sw	zero,16(a3)
    page->ref = val;
ffffffffc02024a0:	0006a023          	sw	zero,0(a3)
ffffffffc02024a4:	06a1                	addi	a3,a3,8
ffffffffc02024a6:	4146b02f          	amoor.d	zero,s4,(a3)
    for (size_t i = 0; i < page_count; i++) {
ffffffffc02024aa:	04078793          	addi	a5,a5,64 # ffffffff80000040 <_binary_obj___user_exit_out_size+0xffffffff7fff47d8>
ffffffffc02024ae:	fef712e3          	bne	a4,a5,ffffffffc0202492 <pmm_init+0xf4>
    if (PPN(pa) >= npage)
ffffffffc02024b2:	00093703          	ld	a4,0(s2)
    size_t free_count = (free_end - free_start) / PGSIZE;
ffffffffc02024b6:	409a8c33          	sub	s8,s5,s1
ffffffffc02024ba:	00c4d793          	srli	a5,s1,0xc
ffffffffc02024be:	00cc5c13          	srli	s8,s8,0xc
ffffffffc02024c2:	68e7f263          	bgeu	a5,a4,ffffffffc0202b46 <pmm_init+0x7a8>
    pmm_manager->init_memmap(base, n);
ffffffffc02024c6:	000b3703          	ld	a4,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc02024ca:	fff806b7          	lui	a3,0xfff80
ffffffffc02024ce:	000bb503          	ld	a0,0(s7)
ffffffffc02024d2:	97b6                	add	a5,a5,a3
ffffffffc02024d4:	6b18                	ld	a4,16(a4)
ffffffffc02024d6:	079a                	slli	a5,a5,0x6
ffffffffc02024d8:	953e                	add	a0,a0,a5
ffffffffc02024da:	85e2                	mv	a1,s8
ffffffffc02024dc:	9702                	jalr	a4
    cprintf("physical memory map:\n");
ffffffffc02024de:	00004517          	auipc	a0,0x4
ffffffffc02024e2:	8a250513          	addi	a0,a0,-1886 # ffffffffc0205d80 <default_pmm_manager+0x248>
ffffffffc02024e6:	caffd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  memory: [0x%016lx, 0x%016lx]\n",
ffffffffc02024ea:	fff40613          	addi	a2,s0,-1
ffffffffc02024ee:	01fa1593          	slli	a1,s4,0x1f
ffffffffc02024f2:	00004517          	auipc	a0,0x4
ffffffffc02024f6:	8a650513          	addi	a0,a0,-1882 # ffffffffc0205d98 <default_pmm_manager+0x260>
ffffffffc02024fa:	c9bfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  free:   [0x%016lx, 0x%016lx]\n",
ffffffffc02024fe:	fffa8613          	addi	a2,s5,-1 # ffffffffffffefff <end+0x3fd4e8cb>
ffffffffc0202502:	85a6                	mv	a1,s1
ffffffffc0202504:	00004517          	auipc	a0,0x4
ffffffffc0202508:	8b450513          	addi	a0,a0,-1868 # ffffffffc0205db8 <default_pmm_manager+0x280>
ffffffffc020250c:	c89fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  free pages: %lu\n", free_count);
ffffffffc0202510:	85e2                	mv	a1,s8
ffffffffc0202512:	00004517          	auipc	a0,0x4
ffffffffc0202516:	8c650513          	addi	a0,a0,-1850 # ffffffffc0205dd8 <default_pmm_manager+0x2a0>
ffffffffc020251a:	c7bfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc020251e:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202522:	000ae497          	auipc	s1,0xae
ffffffffc0202526:	1ce48493          	addi	s1,s1,462 # ffffffffc02b06f0 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc020252a:	7b9c                	ld	a5,48(a5)
ffffffffc020252c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020252e:	00004517          	auipc	a0,0x4
ffffffffc0202532:	8c250513          	addi	a0,a0,-1854 # ffffffffc0205df0 <default_pmm_manager+0x2b8>
ffffffffc0202536:	c5ffd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc020253a:	00007697          	auipc	a3,0x7
ffffffffc020253e:	ac668693          	addi	a3,a3,-1338 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0202542:	e094                	sd	a3,0(s1)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0202544:	c02007b7          	lui	a5,0xc0200
ffffffffc0202548:	74f6ec63          	bltu	a3,a5,ffffffffc0202ca0 <pmm_init+0x902>
ffffffffc020254c:	0009b783          	ld	a5,0(s3)
ffffffffc0202550:	8e9d                	sub	a3,a3,a5
ffffffffc0202552:	000ae797          	auipc	a5,0xae
ffffffffc0202556:	18d7bb23          	sd	a3,406(a5) # ffffffffc02b06e8 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020255a:	100027f3          	csrr	a5,sstatus
ffffffffc020255e:	8b89                	andi	a5,a5,2
ffffffffc0202560:	48079d63          	bnez	a5,ffffffffc02029fa <pmm_init+0x65c>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202564:	000b3783          	ld	a5,0(s6)
ffffffffc0202568:	779c                	ld	a5,40(a5)
ffffffffc020256a:	9782                	jalr	a5
ffffffffc020256c:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020256e:	00093703          	ld	a4,0(s2)
ffffffffc0202572:	c80007b7          	lui	a5,0xc8000
ffffffffc0202576:	83b1                	srli	a5,a5,0xc
ffffffffc0202578:	76e7e063          	bltu	a5,a4,ffffffffc0202cd8 <pmm_init+0x93a>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc020257c:	6088                	ld	a0,0(s1)
ffffffffc020257e:	76050d63          	beqz	a0,ffffffffc0202cf8 <pmm_init+0x95a>
ffffffffc0202582:	03451793          	slli	a5,a0,0x34
ffffffffc0202586:	76079963          	bnez	a5,ffffffffc0202cf8 <pmm_init+0x95a>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc020258a:	4601                	li	a2,0
ffffffffc020258c:	4581                	li	a1,0
ffffffffc020258e:	e04ff0ef          	jal	ra,ffffffffc0201b92 <get_page>
ffffffffc0202592:	5a051c63          	bnez	a0,ffffffffc0202b4a <pmm_init+0x7ac>
ffffffffc0202596:	100027f3          	csrr	a5,sstatus
ffffffffc020259a:	8b89                	andi	a5,a5,2
ffffffffc020259c:	44079463          	bnez	a5,ffffffffc02029e4 <pmm_init+0x646>
        page = pmm_manager->alloc_pages(n);
ffffffffc02025a0:	000b3783          	ld	a5,0(s6)
ffffffffc02025a4:	4505                	li	a0,1
ffffffffc02025a6:	6f9c                	ld	a5,24(a5)
ffffffffc02025a8:	9782                	jalr	a5
ffffffffc02025aa:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02025ac:	6088                	ld	a0,0(s1)
ffffffffc02025ae:	4681                	li	a3,0
ffffffffc02025b0:	4601                	li	a2,0
ffffffffc02025b2:	85d2                	mv	a1,s4
ffffffffc02025b4:	a0bff0ef          	jal	ra,ffffffffc0201fbe <page_insert>
ffffffffc02025b8:	5a051963          	bnez	a0,ffffffffc0202b6a <pmm_init+0x7cc>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc02025bc:	6088                	ld	a0,0(s1)
ffffffffc02025be:	4601                	li	a2,0
ffffffffc02025c0:	4581                	li	a1,0
ffffffffc02025c2:	ba8ff0ef          	jal	ra,ffffffffc020196a <get_pte>
ffffffffc02025c6:	5c050263          	beqz	a0,ffffffffc0202b8a <pmm_init+0x7ec>
    assert(pte2page(*ptep) == p1);
ffffffffc02025ca:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc02025cc:	0017f713          	andi	a4,a5,1
ffffffffc02025d0:	5c070d63          	beqz	a4,ffffffffc0202baa <pmm_init+0x80c>
    if (PPN(pa) >= npage)
ffffffffc02025d4:	00093703          	ld	a4,0(s2)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025d8:	078a                	slli	a5,a5,0x2
ffffffffc02025da:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02025dc:	56e7f563          	bgeu	a5,a4,ffffffffc0202b46 <pmm_init+0x7a8>
    return &pages[PPN(pa) - nbase];
ffffffffc02025e0:	000bb683          	ld	a3,0(s7)
ffffffffc02025e4:	fff80637          	lui	a2,0xfff80
ffffffffc02025e8:	97b2                	add	a5,a5,a2
ffffffffc02025ea:	079a                	slli	a5,a5,0x6
ffffffffc02025ec:	97b6                	add	a5,a5,a3
ffffffffc02025ee:	5cfa1063          	bne	s4,a5,ffffffffc0202bae <pmm_init+0x810>
    assert(page_ref(p1) == 1);
ffffffffc02025f2:	000a2683          	lw	a3,0(s4)
ffffffffc02025f6:	4785                	li	a5,1
ffffffffc02025f8:	5cf69b63          	bne	a3,a5,ffffffffc0202bce <pmm_init+0x830>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc02025fc:	6088                	ld	a0,0(s1)
ffffffffc02025fe:	77fd                	lui	a5,0xfffff
ffffffffc0202600:	6114                	ld	a3,0(a0)
ffffffffc0202602:	068a                	slli	a3,a3,0x2
ffffffffc0202604:	8efd                	and	a3,a3,a5
ffffffffc0202606:	00c6d613          	srli	a2,a3,0xc
ffffffffc020260a:	5ee67263          	bgeu	a2,a4,ffffffffc0202bee <pmm_init+0x850>
ffffffffc020260e:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202612:	96e2                	add	a3,a3,s8
ffffffffc0202614:	0006ba83          	ld	s5,0(a3)
ffffffffc0202618:	0a8a                	slli	s5,s5,0x2
ffffffffc020261a:	00fafab3          	and	s5,s5,a5
ffffffffc020261e:	00cad793          	srli	a5,s5,0xc
ffffffffc0202622:	5ee7f263          	bgeu	a5,a4,ffffffffc0202c06 <pmm_init+0x868>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202626:	4601                	li	a2,0
ffffffffc0202628:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020262a:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc020262c:	b3eff0ef          	jal	ra,ffffffffc020196a <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202630:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202632:	5f551763          	bne	a0,s5,ffffffffc0202c20 <pmm_init+0x882>
ffffffffc0202636:	100027f3          	csrr	a5,sstatus
ffffffffc020263a:	8b89                	andi	a5,a5,2
ffffffffc020263c:	3c079963          	bnez	a5,ffffffffc0202a0e <pmm_init+0x670>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202640:	000b3783          	ld	a5,0(s6)
ffffffffc0202644:	4505                	li	a0,1
ffffffffc0202646:	6f9c                	ld	a5,24(a5)
ffffffffc0202648:	9782                	jalr	a5
ffffffffc020264a:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020264c:	6088                	ld	a0,0(s1)
ffffffffc020264e:	46d1                	li	a3,20
ffffffffc0202650:	6605                	lui	a2,0x1
ffffffffc0202652:	85e2                	mv	a1,s8
ffffffffc0202654:	96bff0ef          	jal	ra,ffffffffc0201fbe <page_insert>
ffffffffc0202658:	5e051463          	bnez	a0,ffffffffc0202c40 <pmm_init+0x8a2>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc020265c:	6088                	ld	a0,0(s1)
ffffffffc020265e:	4601                	li	a2,0
ffffffffc0202660:	6585                	lui	a1,0x1
ffffffffc0202662:	b08ff0ef          	jal	ra,ffffffffc020196a <get_pte>
ffffffffc0202666:	5e050d63          	beqz	a0,ffffffffc0202c60 <pmm_init+0x8c2>
    assert(*ptep & PTE_U);
ffffffffc020266a:	611c                	ld	a5,0(a0)
ffffffffc020266c:	0107f713          	andi	a4,a5,16
ffffffffc0202670:	60070863          	beqz	a4,ffffffffc0202c80 <pmm_init+0x8e2>
    assert(*ptep & PTE_W);
ffffffffc0202674:	8b91                	andi	a5,a5,4
ffffffffc0202676:	020781e3          	beqz	a5,ffffffffc0202e98 <pmm_init+0xafa>
    assert(boot_pgdir_va[0] & PTE_V);
ffffffffc020267a:	6088                	ld	a0,0(s1)
ffffffffc020267c:	611c                	ld	a5,0(a0)
ffffffffc020267e:	8b85                	andi	a5,a5,1
ffffffffc0202680:	72078c63          	beqz	a5,ffffffffc0202db8 <pmm_init+0xa1a>
    assert(page_ref(p2) == 1);
ffffffffc0202684:	000c2703          	lw	a4,0(s8)
ffffffffc0202688:	4785                	li	a5,1
ffffffffc020268a:	74f71763          	bne	a4,a5,ffffffffc0202dd8 <pmm_init+0xa3a>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc020268e:	4681                	li	a3,0
ffffffffc0202690:	6605                	lui	a2,0x1
ffffffffc0202692:	85d2                	mv	a1,s4
ffffffffc0202694:	92bff0ef          	jal	ra,ffffffffc0201fbe <page_insert>
ffffffffc0202698:	76051063          	bnez	a0,ffffffffc0202df8 <pmm_init+0xa5a>
    assert(page_ref(p1) == 2);
ffffffffc020269c:	000a2703          	lw	a4,0(s4)
ffffffffc02026a0:	4789                	li	a5,2
ffffffffc02026a2:	76f71b63          	bne	a4,a5,ffffffffc0202e18 <pmm_init+0xa7a>
    assert(page_ref(p2) == 0);
ffffffffc02026a6:	000c2783          	lw	a5,0(s8)
ffffffffc02026aa:	78079763          	bnez	a5,ffffffffc0202e38 <pmm_init+0xa9a>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02026ae:	6088                	ld	a0,0(s1)
ffffffffc02026b0:	4601                	li	a2,0
ffffffffc02026b2:	6585                	lui	a1,0x1
ffffffffc02026b4:	ab6ff0ef          	jal	ra,ffffffffc020196a <get_pte>
ffffffffc02026b8:	7a050063          	beqz	a0,ffffffffc0202e58 <pmm_init+0xaba>
    assert(pte2page(*ptep) == p1);
ffffffffc02026bc:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc02026be:	00177793          	andi	a5,a4,1
ffffffffc02026c2:	4e078463          	beqz	a5,ffffffffc0202baa <pmm_init+0x80c>
    if (PPN(pa) >= npage)
ffffffffc02026c6:	00093683          	ld	a3,0(s2)
    return pa2page(PTE_ADDR(pte));
ffffffffc02026ca:	00271793          	slli	a5,a4,0x2
ffffffffc02026ce:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02026d0:	46d7fb63          	bgeu	a5,a3,ffffffffc0202b46 <pmm_init+0x7a8>
    return &pages[PPN(pa) - nbase];
ffffffffc02026d4:	000bb683          	ld	a3,0(s7)
ffffffffc02026d8:	fff80ab7          	lui	s5,0xfff80
ffffffffc02026dc:	97d6                	add	a5,a5,s5
ffffffffc02026de:	079a                	slli	a5,a5,0x6
ffffffffc02026e0:	97b6                	add	a5,a5,a3
ffffffffc02026e2:	78fa1b63          	bne	s4,a5,ffffffffc0202e78 <pmm_init+0xada>
    assert((*ptep & PTE_U) == 0);
ffffffffc02026e6:	8b41                	andi	a4,a4,16
ffffffffc02026e8:	62071863          	bnez	a4,ffffffffc0202d18 <pmm_init+0x97a>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc02026ec:	6088                	ld	a0,0(s1)
ffffffffc02026ee:	4581                	li	a1,0
ffffffffc02026f0:	c0dff0ef          	jal	ra,ffffffffc02022fc <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02026f4:	000a2c83          	lw	s9,0(s4)
ffffffffc02026f8:	4785                	li	a5,1
ffffffffc02026fa:	62fc9f63          	bne	s9,a5,ffffffffc0202d38 <pmm_init+0x99a>
    assert(page_ref(p2) == 0);
ffffffffc02026fe:	000c2783          	lw	a5,0(s8)
ffffffffc0202702:	64079b63          	bnez	a5,ffffffffc0202d58 <pmm_init+0x9ba>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202706:	6088                	ld	a0,0(s1)
ffffffffc0202708:	6585                	lui	a1,0x1
ffffffffc020270a:	bf3ff0ef          	jal	ra,ffffffffc02022fc <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020270e:	000a2783          	lw	a5,0(s4)
ffffffffc0202712:	66079363          	bnez	a5,ffffffffc0202d78 <pmm_init+0x9da>
    assert(page_ref(p2) == 0);
ffffffffc0202716:	000c2783          	lw	a5,0(s8)
ffffffffc020271a:	58079f63          	bnez	a5,ffffffffc0202cb8 <pmm_init+0x91a>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc020271e:	0004ba03          	ld	s4,0(s1)
    if (PPN(pa) >= npage)
ffffffffc0202722:	00093703          	ld	a4,0(s2)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202726:	000a3683          	ld	a3,0(s4)
ffffffffc020272a:	068a                	slli	a3,a3,0x2
ffffffffc020272c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc020272e:	40e6fc63          	bgeu	a3,a4,ffffffffc0202b46 <pmm_init+0x7a8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202732:	000bb503          	ld	a0,0(s7)
ffffffffc0202736:	96d6                	add	a3,a3,s5
ffffffffc0202738:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc020273a:	00d507b3          	add	a5,a0,a3
ffffffffc020273e:	439c                	lw	a5,0(a5)
ffffffffc0202740:	03979ce3          	bne	a5,s9,ffffffffc0202f78 <pmm_init+0xbda>
    return page - pages + nbase;
ffffffffc0202744:	8699                	srai	a3,a3,0x6
ffffffffc0202746:	000805b7          	lui	a1,0x80
ffffffffc020274a:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc020274c:	00c69613          	slli	a2,a3,0xc
ffffffffc0202750:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202752:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202754:	04e672e3          	bgeu	a2,a4,ffffffffc0202f98 <pmm_init+0xbfa>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202758:	0009b603          	ld	a2,0(s3)
ffffffffc020275c:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc020275e:	629c                	ld	a5,0(a3)
ffffffffc0202760:	078a                	slli	a5,a5,0x2
ffffffffc0202762:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202764:	3ee7f163          	bgeu	a5,a4,ffffffffc0202b46 <pmm_init+0x7a8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202768:	8f8d                	sub	a5,a5,a1
ffffffffc020276a:	079a                	slli	a5,a5,0x6
ffffffffc020276c:	953e                	add	a0,a0,a5
ffffffffc020276e:	100027f3          	csrr	a5,sstatus
ffffffffc0202772:	8b89                	andi	a5,a5,2
ffffffffc0202774:	2a079863          	bnez	a5,ffffffffc0202a24 <pmm_init+0x686>
        pmm_manager->free_pages(base, n);
ffffffffc0202778:	000b3783          	ld	a5,0(s6)
ffffffffc020277c:	4585                	li	a1,1
ffffffffc020277e:	739c                	ld	a5,32(a5)
ffffffffc0202780:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202782:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202786:	00093703          	ld	a4,0(s2)
    return pa2page(PDE_ADDR(pde));
ffffffffc020278a:	078a                	slli	a5,a5,0x2
ffffffffc020278c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020278e:	3ae7fc63          	bgeu	a5,a4,ffffffffc0202b46 <pmm_init+0x7a8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202792:	000bb503          	ld	a0,0(s7)
ffffffffc0202796:	fff80737          	lui	a4,0xfff80
ffffffffc020279a:	97ba                	add	a5,a5,a4
ffffffffc020279c:	079a                	slli	a5,a5,0x6
ffffffffc020279e:	953e                	add	a0,a0,a5
ffffffffc02027a0:	100027f3          	csrr	a5,sstatus
ffffffffc02027a4:	8b89                	andi	a5,a5,2
ffffffffc02027a6:	2a079563          	bnez	a5,ffffffffc0202a50 <pmm_init+0x6b2>
ffffffffc02027aa:	000b3783          	ld	a5,0(s6)
ffffffffc02027ae:	4585                	li	a1,1
ffffffffc02027b0:	739c                	ld	a5,32(a5)
ffffffffc02027b2:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc02027b4:	609c                	ld	a5,0(s1)
ffffffffc02027b6:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd4e8cc>
    asm volatile("sfence.vma");
ffffffffc02027ba:	12000073          	sfence.vma
ffffffffc02027be:	100027f3          	csrr	a5,sstatus
ffffffffc02027c2:	8b89                	andi	a5,a5,2
ffffffffc02027c4:	26079c63          	bnez	a5,ffffffffc0202a3c <pmm_init+0x69e>
        ret = pmm_manager->nr_free_pages();
ffffffffc02027c8:	000b3783          	ld	a5,0(s6)
ffffffffc02027cc:	779c                	ld	a5,40(a5)
ffffffffc02027ce:	9782                	jalr	a5
ffffffffc02027d0:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc02027d2:	5d441363          	bne	s0,s4,ffffffffc0202d98 <pmm_init+0x9fa>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02027d6:	00004517          	auipc	a0,0x4
ffffffffc02027da:	94250513          	addi	a0,a0,-1726 # ffffffffc0206118 <default_pmm_manager+0x5e0>
ffffffffc02027de:	9b7fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02027e2:	100027f3          	csrr	a5,sstatus
ffffffffc02027e6:	8b89                	andi	a5,a5,2
ffffffffc02027e8:	28079063          	bnez	a5,ffffffffc0202a68 <pmm_init+0x6ca>
        ret = pmm_manager->nr_free_pages();
ffffffffc02027ec:	000b3783          	ld	a5,0(s6)
ffffffffc02027f0:	779c                	ld	a5,40(a5)
ffffffffc02027f2:	9782                	jalr	a5
ffffffffc02027f4:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc02027f6:	00093703          	ld	a4,0(s2)
ffffffffc02027fa:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02027fe:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202800:	00c71793          	slli	a5,a4,0xc
ffffffffc0202804:	6a05                	lui	s4,0x1
ffffffffc0202806:	02f47c63          	bgeu	s0,a5,ffffffffc020283e <pmm_init+0x4a0>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020280a:	00c45793          	srli	a5,s0,0xc
ffffffffc020280e:	6088                	ld	a0,0(s1)
ffffffffc0202810:	2ce7fe63          	bgeu	a5,a4,ffffffffc0202aec <pmm_init+0x74e>
ffffffffc0202814:	0009b583          	ld	a1,0(s3)
ffffffffc0202818:	4601                	li	a2,0
ffffffffc020281a:	95a2                	add	a1,a1,s0
ffffffffc020281c:	94eff0ef          	jal	ra,ffffffffc020196a <get_pte>
ffffffffc0202820:	2e050363          	beqz	a0,ffffffffc0202b06 <pmm_init+0x768>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202824:	611c                	ld	a5,0(a0)
ffffffffc0202826:	078a                	slli	a5,a5,0x2
ffffffffc0202828:	0157f7b3          	and	a5,a5,s5
ffffffffc020282c:	2e879d63          	bne	a5,s0,ffffffffc0202b26 <pmm_init+0x788>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202830:	00093703          	ld	a4,0(s2)
ffffffffc0202834:	9452                	add	s0,s0,s4
ffffffffc0202836:	00c71793          	slli	a5,a4,0xc
ffffffffc020283a:	fcf468e3          	bltu	s0,a5,ffffffffc020280a <pmm_init+0x46c>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc020283e:	609c                	ld	a5,0(s1)
ffffffffc0202840:	639c                	ld	a5,0(a5)
ffffffffc0202842:	6e079b63          	bnez	a5,ffffffffc0202f38 <pmm_init+0xb9a>
ffffffffc0202846:	100027f3          	csrr	a5,sstatus
ffffffffc020284a:	8b89                	andi	a5,a5,2
ffffffffc020284c:	22079863          	bnez	a5,ffffffffc0202a7c <pmm_init+0x6de>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202850:	000b3783          	ld	a5,0(s6)
ffffffffc0202854:	4505                	li	a0,1
ffffffffc0202856:	6f9c                	ld	a5,24(a5)
ffffffffc0202858:	9782                	jalr	a5
ffffffffc020285a:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020285c:	6088                	ld	a0,0(s1)
ffffffffc020285e:	4699                	li	a3,6
ffffffffc0202860:	10000613          	li	a2,256
ffffffffc0202864:	85d2                	mv	a1,s4
ffffffffc0202866:	f58ff0ef          	jal	ra,ffffffffc0201fbe <page_insert>
ffffffffc020286a:	6e051763          	bnez	a0,ffffffffc0202f58 <pmm_init+0xbba>
    assert(page_ref(p) == 1);
ffffffffc020286e:	000a2703          	lw	a4,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x92f0>
ffffffffc0202872:	4785                	li	a5,1
ffffffffc0202874:	64f71263          	bne	a4,a5,ffffffffc0202eb8 <pmm_init+0xb1a>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202878:	6088                	ld	a0,0(s1)
ffffffffc020287a:	6405                	lui	s0,0x1
ffffffffc020287c:	4699                	li	a3,6
ffffffffc020287e:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x91f0>
ffffffffc0202882:	85d2                	mv	a1,s4
ffffffffc0202884:	f3aff0ef          	jal	ra,ffffffffc0201fbe <page_insert>
ffffffffc0202888:	64051863          	bnez	a0,ffffffffc0202ed8 <pmm_init+0xb3a>
    assert(page_ref(p) == 2);
ffffffffc020288c:	000a2703          	lw	a4,0(s4)
ffffffffc0202890:	4789                	li	a5,2
ffffffffc0202892:	66f71363          	bne	a4,a5,ffffffffc0202ef8 <pmm_init+0xb5a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202896:	00004597          	auipc	a1,0x4
ffffffffc020289a:	9ca58593          	addi	a1,a1,-1590 # ffffffffc0206260 <default_pmm_manager+0x728>
ffffffffc020289e:	10000513          	li	a0,256
ffffffffc02028a2:	774020ef          	jal	ra,ffffffffc0205016 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02028a6:	10040593          	addi	a1,s0,256
ffffffffc02028aa:	10000513          	li	a0,256
ffffffffc02028ae:	77a020ef          	jal	ra,ffffffffc0205028 <strcmp>
ffffffffc02028b2:	66051363          	bnez	a0,ffffffffc0202f18 <pmm_init+0xb7a>
    return page - pages + nbase;
ffffffffc02028b6:	000bb683          	ld	a3,0(s7)
ffffffffc02028ba:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02028be:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02028c0:	40da06b3          	sub	a3,s4,a3
ffffffffc02028c4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02028c6:	00093783          	ld	a5,0(s2)
    return page - pages + nbase;
ffffffffc02028ca:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02028cc:	8031                	srli	s0,s0,0xc
ffffffffc02028ce:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc02028d2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02028d4:	6cf77263          	bgeu	a4,a5,ffffffffc0202f98 <pmm_init+0xbfa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02028d8:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02028dc:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02028e0:	96be                	add	a3,a3,a5
ffffffffc02028e2:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02028e6:	6fa020ef          	jal	ra,ffffffffc0204fe0 <strlen>
ffffffffc02028ea:	6c051363          	bnez	a0,ffffffffc0202fb0 <pmm_init+0xc12>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc02028ee:	0004ba83          	ld	s5,0(s1)
    if (PPN(pa) >= npage)
ffffffffc02028f2:	00093783          	ld	a5,0(s2)
    return pa2page(PDE_ADDR(pde));
ffffffffc02028f6:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd4e8cc>
ffffffffc02028fa:	068a                	slli	a3,a3,0x2
ffffffffc02028fc:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc02028fe:	24f6f463          	bgeu	a3,a5,ffffffffc0202b46 <pmm_init+0x7a8>
    return KADDR(page2pa(page));
ffffffffc0202902:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202904:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202906:	68f47963          	bgeu	s0,a5,ffffffffc0202f98 <pmm_init+0xbfa>
ffffffffc020290a:	0009b403          	ld	s0,0(s3)
ffffffffc020290e:	9436                	add	s0,s0,a3
ffffffffc0202910:	100027f3          	csrr	a5,sstatus
ffffffffc0202914:	8b89                	andi	a5,a5,2
ffffffffc0202916:	1c079063          	bnez	a5,ffffffffc0202ad6 <pmm_init+0x738>
        pmm_manager->free_pages(base, n);
ffffffffc020291a:	000b3783          	ld	a5,0(s6)
ffffffffc020291e:	4585                	li	a1,1
ffffffffc0202920:	8552                	mv	a0,s4
ffffffffc0202922:	739c                	ld	a5,32(a5)
ffffffffc0202924:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202926:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0202928:	00093703          	ld	a4,0(s2)
    return pa2page(PDE_ADDR(pde));
ffffffffc020292c:	078a                	slli	a5,a5,0x2
ffffffffc020292e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202930:	20e7fb63          	bgeu	a5,a4,ffffffffc0202b46 <pmm_init+0x7a8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202934:	000bb503          	ld	a0,0(s7)
ffffffffc0202938:	fff80737          	lui	a4,0xfff80
ffffffffc020293c:	97ba                	add	a5,a5,a4
ffffffffc020293e:	079a                	slli	a5,a5,0x6
ffffffffc0202940:	953e                	add	a0,a0,a5
ffffffffc0202942:	100027f3          	csrr	a5,sstatus
ffffffffc0202946:	8b89                	andi	a5,a5,2
ffffffffc0202948:	16079b63          	bnez	a5,ffffffffc0202abe <pmm_init+0x720>
ffffffffc020294c:	000b3783          	ld	a5,0(s6)
ffffffffc0202950:	4585                	li	a1,1
ffffffffc0202952:	739c                	ld	a5,32(a5)
ffffffffc0202954:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202956:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc020295a:	00093703          	ld	a4,0(s2)
    return pa2page(PDE_ADDR(pde));
ffffffffc020295e:	078a                	slli	a5,a5,0x2
ffffffffc0202960:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202962:	1ee7f263          	bgeu	a5,a4,ffffffffc0202b46 <pmm_init+0x7a8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202966:	000bb503          	ld	a0,0(s7)
ffffffffc020296a:	fff80737          	lui	a4,0xfff80
ffffffffc020296e:	97ba                	add	a5,a5,a4
ffffffffc0202970:	079a                	slli	a5,a5,0x6
ffffffffc0202972:	953e                	add	a0,a0,a5
ffffffffc0202974:	100027f3          	csrr	a5,sstatus
ffffffffc0202978:	8b89                	andi	a5,a5,2
ffffffffc020297a:	12079663          	bnez	a5,ffffffffc0202aa6 <pmm_init+0x708>
ffffffffc020297e:	000b3783          	ld	a5,0(s6)
ffffffffc0202982:	4585                	li	a1,1
ffffffffc0202984:	739c                	ld	a5,32(a5)
ffffffffc0202986:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202988:	609c                	ld	a5,0(s1)
ffffffffc020298a:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc020298e:	12000073          	sfence.vma
ffffffffc0202992:	100027f3          	csrr	a5,sstatus
ffffffffc0202996:	8b89                	andi	a5,a5,2
ffffffffc0202998:	0e079d63          	bnez	a5,ffffffffc0202a92 <pmm_init+0x6f4>
        ret = pmm_manager->nr_free_pages();
ffffffffc020299c:	000b3783          	ld	a5,0(s6)
ffffffffc02029a0:	779c                	ld	a5,40(a5)
ffffffffc02029a2:	9782                	jalr	a5
ffffffffc02029a4:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc02029a6:	628c1563          	bne	s8,s0,ffffffffc0202fd0 <pmm_init+0xc32>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02029aa:	00004517          	auipc	a0,0x4
ffffffffc02029ae:	92e50513          	addi	a0,a0,-1746 # ffffffffc02062d8 <default_pmm_manager+0x7a0>
ffffffffc02029b2:	fe2fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc02029b6:	7406                	ld	s0,96(sp)
ffffffffc02029b8:	70a6                	ld	ra,104(sp)
ffffffffc02029ba:	64e6                	ld	s1,88(sp)
ffffffffc02029bc:	6946                	ld	s2,80(sp)
ffffffffc02029be:	69a6                	ld	s3,72(sp)
ffffffffc02029c0:	6a06                	ld	s4,64(sp)
ffffffffc02029c2:	7ae2                	ld	s5,56(sp)
ffffffffc02029c4:	7b42                	ld	s6,48(sp)
ffffffffc02029c6:	7ba2                	ld	s7,40(sp)
ffffffffc02029c8:	7c02                	ld	s8,32(sp)
ffffffffc02029ca:	6ce2                	ld	s9,24(sp)
ffffffffc02029cc:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc02029ce:	d21fe06f          	j	ffffffffc02016ee <kmalloc_init>
ffffffffc02029d2:	6721                	lui	a4,0x8
ffffffffc02029d4:	00088637          	lui	a2,0x88
ffffffffc02029d8:	e0070713          	addi	a4,a4,-512 # 7e00 <_binary_obj___user_faultread_out_size-0x24f0>
ffffffffc02029dc:	e0060613          	addi	a2,a2,-512 # 87e00 <_binary_obj___user_exit_out_size+0x7c598>
        mem_end = (DRAM_BASE + KMEMSIZE);
ffffffffc02029e0:	843e                	mv	s0,a5
ffffffffc02029e2:	bc3d                	j	ffffffffc0202420 <pmm_init+0x82>
        intr_disable();
ffffffffc02029e4:	f91fd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02029e8:	000b3783          	ld	a5,0(s6)
ffffffffc02029ec:	4505                	li	a0,1
ffffffffc02029ee:	6f9c                	ld	a5,24(a5)
ffffffffc02029f0:	9782                	jalr	a5
ffffffffc02029f2:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02029f4:	f7bfd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc02029f8:	be55                	j	ffffffffc02025ac <pmm_init+0x20e>
        intr_disable();
ffffffffc02029fa:	f7bfd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02029fe:	000b3783          	ld	a5,0(s6)
ffffffffc0202a02:	779c                	ld	a5,40(a5)
ffffffffc0202a04:	9782                	jalr	a5
ffffffffc0202a06:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202a08:	f67fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202a0c:	b68d                	j	ffffffffc020256e <pmm_init+0x1d0>
        intr_disable();
ffffffffc0202a0e:	f67fd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a12:	000b3783          	ld	a5,0(s6)
ffffffffc0202a16:	4505                	li	a0,1
ffffffffc0202a18:	6f9c                	ld	a5,24(a5)
ffffffffc0202a1a:	9782                	jalr	a5
ffffffffc0202a1c:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202a1e:	f51fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202a22:	b12d                	j	ffffffffc020264c <pmm_init+0x2ae>
ffffffffc0202a24:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202a26:	f4ffd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202a2a:	000b3783          	ld	a5,0(s6)
ffffffffc0202a2e:	6522                	ld	a0,8(sp)
ffffffffc0202a30:	4585                	li	a1,1
ffffffffc0202a32:	739c                	ld	a5,32(a5)
ffffffffc0202a34:	9782                	jalr	a5
        intr_enable();
ffffffffc0202a36:	f39fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202a3a:	b3a1                	j	ffffffffc0202782 <pmm_init+0x3e4>
        intr_disable();
ffffffffc0202a3c:	f39fd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202a40:	000b3783          	ld	a5,0(s6)
ffffffffc0202a44:	779c                	ld	a5,40(a5)
ffffffffc0202a46:	9782                	jalr	a5
ffffffffc0202a48:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202a4a:	f25fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202a4e:	b351                	j	ffffffffc02027d2 <pmm_init+0x434>
ffffffffc0202a50:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202a52:	f23fd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202a56:	000b3783          	ld	a5,0(s6)
ffffffffc0202a5a:	6522                	ld	a0,8(sp)
ffffffffc0202a5c:	4585                	li	a1,1
ffffffffc0202a5e:	739c                	ld	a5,32(a5)
ffffffffc0202a60:	9782                	jalr	a5
        intr_enable();
ffffffffc0202a62:	f0dfd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202a66:	b3b9                	j	ffffffffc02027b4 <pmm_init+0x416>
        intr_disable();
ffffffffc0202a68:	f0dfd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202a6c:	000b3783          	ld	a5,0(s6)
ffffffffc0202a70:	779c                	ld	a5,40(a5)
ffffffffc0202a72:	9782                	jalr	a5
ffffffffc0202a74:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202a76:	ef9fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202a7a:	bbb5                	j	ffffffffc02027f6 <pmm_init+0x458>
        intr_disable();
ffffffffc0202a7c:	ef9fd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a80:	000b3783          	ld	a5,0(s6)
ffffffffc0202a84:	4505                	li	a0,1
ffffffffc0202a86:	6f9c                	ld	a5,24(a5)
ffffffffc0202a88:	9782                	jalr	a5
ffffffffc0202a8a:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202a8c:	ee3fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202a90:	b3f1                	j	ffffffffc020285c <pmm_init+0x4be>
        intr_disable();
ffffffffc0202a92:	ee3fd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202a96:	000b3783          	ld	a5,0(s6)
ffffffffc0202a9a:	779c                	ld	a5,40(a5)
ffffffffc0202a9c:	9782                	jalr	a5
ffffffffc0202a9e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202aa0:	ecffd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202aa4:	b709                	j	ffffffffc02029a6 <pmm_init+0x608>
ffffffffc0202aa6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202aa8:	ecdfd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202aac:	000b3783          	ld	a5,0(s6)
ffffffffc0202ab0:	6522                	ld	a0,8(sp)
ffffffffc0202ab2:	4585                	li	a1,1
ffffffffc0202ab4:	739c                	ld	a5,32(a5)
ffffffffc0202ab6:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ab8:	eb7fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202abc:	b5f1                	j	ffffffffc0202988 <pmm_init+0x5ea>
ffffffffc0202abe:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202ac0:	eb5fd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc0202ac4:	000b3783          	ld	a5,0(s6)
ffffffffc0202ac8:	6522                	ld	a0,8(sp)
ffffffffc0202aca:	4585                	li	a1,1
ffffffffc0202acc:	739c                	ld	a5,32(a5)
ffffffffc0202ace:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ad0:	e9ffd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202ad4:	b549                	j	ffffffffc0202956 <pmm_init+0x5b8>
        intr_disable();
ffffffffc0202ad6:	e9ffd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc0202ada:	000b3783          	ld	a5,0(s6)
ffffffffc0202ade:	4585                	li	a1,1
ffffffffc0202ae0:	8552                	mv	a0,s4
ffffffffc0202ae2:	739c                	ld	a5,32(a5)
ffffffffc0202ae4:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ae6:	e89fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202aea:	bd35                	j	ffffffffc0202926 <pmm_init+0x588>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202aec:	86a2                	mv	a3,s0
ffffffffc0202aee:	00003617          	auipc	a2,0x3
ffffffffc0202af2:	08260613          	addi	a2,a2,130 # ffffffffc0205b70 <default_pmm_manager+0x38>
ffffffffc0202af6:	23c00593          	li	a1,572
ffffffffc0202afa:	00003517          	auipc	a0,0x3
ffffffffc0202afe:	18e50513          	addi	a0,a0,398 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202b02:	94dfd0ef          	jal	ra,ffffffffc020044e <__panic>
ffffffffc0202b06:	00003697          	auipc	a3,0x3
ffffffffc0202b0a:	63268693          	addi	a3,a3,1586 # ffffffffc0206138 <default_pmm_manager+0x600>
ffffffffc0202b0e:	00003617          	auipc	a2,0x3
ffffffffc0202b12:	e2a60613          	addi	a2,a2,-470 # ffffffffc0205938 <commands+0x620>
ffffffffc0202b16:	23c00593          	li	a1,572
ffffffffc0202b1a:	00003517          	auipc	a0,0x3
ffffffffc0202b1e:	16e50513          	addi	a0,a0,366 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202b22:	92dfd0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202b26:	00003697          	auipc	a3,0x3
ffffffffc0202b2a:	65268693          	addi	a3,a3,1618 # ffffffffc0206178 <default_pmm_manager+0x640>
ffffffffc0202b2e:	00003617          	auipc	a2,0x3
ffffffffc0202b32:	e0a60613          	addi	a2,a2,-502 # ffffffffc0205938 <commands+0x620>
ffffffffc0202b36:	23d00593          	li	a1,573
ffffffffc0202b3a:	00003517          	auipc	a0,0x3
ffffffffc0202b3e:	14e50513          	addi	a0,a0,334 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202b42:	90dfd0ef          	jal	ra,ffffffffc020044e <__panic>
ffffffffc0202b46:	d6ffe0ef          	jal	ra,ffffffffc02018b4 <pa2page.part.0>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202b4a:	00003697          	auipc	a3,0x3
ffffffffc0202b4e:	32668693          	addi	a3,a3,806 # ffffffffc0205e70 <default_pmm_manager+0x338>
ffffffffc0202b52:	00003617          	auipc	a2,0x3
ffffffffc0202b56:	de660613          	addi	a2,a2,-538 # ffffffffc0205938 <commands+0x620>
ffffffffc0202b5a:	1ff00593          	li	a1,511
ffffffffc0202b5e:	00003517          	auipc	a0,0x3
ffffffffc0202b62:	12a50513          	addi	a0,a0,298 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202b66:	8e9fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202b6a:	00003697          	auipc	a3,0x3
ffffffffc0202b6e:	33668693          	addi	a3,a3,822 # ffffffffc0205ea0 <default_pmm_manager+0x368>
ffffffffc0202b72:	00003617          	auipc	a2,0x3
ffffffffc0202b76:	dc660613          	addi	a2,a2,-570 # ffffffffc0205938 <commands+0x620>
ffffffffc0202b7a:	20300593          	li	a1,515
ffffffffc0202b7e:	00003517          	auipc	a0,0x3
ffffffffc0202b82:	10a50513          	addi	a0,a0,266 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202b86:	8c9fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202b8a:	00003697          	auipc	a3,0x3
ffffffffc0202b8e:	34668693          	addi	a3,a3,838 # ffffffffc0205ed0 <default_pmm_manager+0x398>
ffffffffc0202b92:	00003617          	auipc	a2,0x3
ffffffffc0202b96:	da660613          	addi	a2,a2,-602 # ffffffffc0205938 <commands+0x620>
ffffffffc0202b9a:	20600593          	li	a1,518
ffffffffc0202b9e:	00003517          	auipc	a0,0x3
ffffffffc0202ba2:	0ea50513          	addi	a0,a0,234 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202ba6:	8a9fd0ef          	jal	ra,ffffffffc020044e <__panic>
ffffffffc0202baa:	d27fe0ef          	jal	ra,ffffffffc02018d0 <pte2page.part.0>
    assert(pte2page(*ptep) == p1);
ffffffffc0202bae:	00003697          	auipc	a3,0x3
ffffffffc0202bb2:	35268693          	addi	a3,a3,850 # ffffffffc0205f00 <default_pmm_manager+0x3c8>
ffffffffc0202bb6:	00003617          	auipc	a2,0x3
ffffffffc0202bba:	d8260613          	addi	a2,a2,-638 # ffffffffc0205938 <commands+0x620>
ffffffffc0202bbe:	20700593          	li	a1,519
ffffffffc0202bc2:	00003517          	auipc	a0,0x3
ffffffffc0202bc6:	0c650513          	addi	a0,a0,198 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202bca:	885fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202bce:	00003697          	auipc	a3,0x3
ffffffffc0202bd2:	34a68693          	addi	a3,a3,842 # ffffffffc0205f18 <default_pmm_manager+0x3e0>
ffffffffc0202bd6:	00003617          	auipc	a2,0x3
ffffffffc0202bda:	d6260613          	addi	a2,a2,-670 # ffffffffc0205938 <commands+0x620>
ffffffffc0202bde:	20800593          	li	a1,520
ffffffffc0202be2:	00003517          	auipc	a0,0x3
ffffffffc0202be6:	0a650513          	addi	a0,a0,166 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202bea:	865fd0ef          	jal	ra,ffffffffc020044e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202bee:	00003617          	auipc	a2,0x3
ffffffffc0202bf2:	f8260613          	addi	a2,a2,-126 # ffffffffc0205b70 <default_pmm_manager+0x38>
ffffffffc0202bf6:	20a00593          	li	a1,522
ffffffffc0202bfa:	00003517          	auipc	a0,0x3
ffffffffc0202bfe:	08e50513          	addi	a0,a0,142 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202c02:	84dfd0ef          	jal	ra,ffffffffc020044e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202c06:	86d6                	mv	a3,s5
ffffffffc0202c08:	00003617          	auipc	a2,0x3
ffffffffc0202c0c:	f6860613          	addi	a2,a2,-152 # ffffffffc0205b70 <default_pmm_manager+0x38>
ffffffffc0202c10:	20b00593          	li	a1,523
ffffffffc0202c14:	00003517          	auipc	a0,0x3
ffffffffc0202c18:	07450513          	addi	a0,a0,116 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202c1c:	833fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202c20:	00003697          	auipc	a3,0x3
ffffffffc0202c24:	31068693          	addi	a3,a3,784 # ffffffffc0205f30 <default_pmm_manager+0x3f8>
ffffffffc0202c28:	00003617          	auipc	a2,0x3
ffffffffc0202c2c:	d1060613          	addi	a2,a2,-752 # ffffffffc0205938 <commands+0x620>
ffffffffc0202c30:	20c00593          	li	a1,524
ffffffffc0202c34:	00003517          	auipc	a0,0x3
ffffffffc0202c38:	05450513          	addi	a0,a0,84 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202c3c:	813fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202c40:	00003697          	auipc	a3,0x3
ffffffffc0202c44:	32068693          	addi	a3,a3,800 # ffffffffc0205f60 <default_pmm_manager+0x428>
ffffffffc0202c48:	00003617          	auipc	a2,0x3
ffffffffc0202c4c:	cf060613          	addi	a2,a2,-784 # ffffffffc0205938 <commands+0x620>
ffffffffc0202c50:	20f00593          	li	a1,527
ffffffffc0202c54:	00003517          	auipc	a0,0x3
ffffffffc0202c58:	03450513          	addi	a0,a0,52 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202c5c:	ff2fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202c60:	00003697          	auipc	a3,0x3
ffffffffc0202c64:	34068693          	addi	a3,a3,832 # ffffffffc0205fa0 <default_pmm_manager+0x468>
ffffffffc0202c68:	00003617          	auipc	a2,0x3
ffffffffc0202c6c:	cd060613          	addi	a2,a2,-816 # ffffffffc0205938 <commands+0x620>
ffffffffc0202c70:	21000593          	li	a1,528
ffffffffc0202c74:	00003517          	auipc	a0,0x3
ffffffffc0202c78:	01450513          	addi	a0,a0,20 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202c7c:	fd2fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202c80:	00003697          	auipc	a3,0x3
ffffffffc0202c84:	35868693          	addi	a3,a3,856 # ffffffffc0205fd8 <default_pmm_manager+0x4a0>
ffffffffc0202c88:	00003617          	auipc	a2,0x3
ffffffffc0202c8c:	cb060613          	addi	a2,a2,-848 # ffffffffc0205938 <commands+0x620>
ffffffffc0202c90:	21100593          	li	a1,529
ffffffffc0202c94:	00003517          	auipc	a0,0x3
ffffffffc0202c98:	ff450513          	addi	a0,a0,-12 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202c9c:	fb2fd0ef          	jal	ra,ffffffffc020044e <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0202ca0:	00003617          	auipc	a2,0x3
ffffffffc0202ca4:	f7860613          	addi	a2,a2,-136 # ffffffffc0205c18 <default_pmm_manager+0xe0>
ffffffffc0202ca8:	0df00593          	li	a1,223
ffffffffc0202cac:	00003517          	auipc	a0,0x3
ffffffffc0202cb0:	fdc50513          	addi	a0,a0,-36 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202cb4:	f9afd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202cb8:	00003697          	auipc	a3,0x3
ffffffffc0202cbc:	3c068693          	addi	a3,a3,960 # ffffffffc0206078 <default_pmm_manager+0x540>
ffffffffc0202cc0:	00003617          	auipc	a2,0x3
ffffffffc0202cc4:	c7860613          	addi	a2,a2,-904 # ffffffffc0205938 <commands+0x620>
ffffffffc0202cc8:	22300593          	li	a1,547
ffffffffc0202ccc:	00003517          	auipc	a0,0x3
ffffffffc0202cd0:	fbc50513          	addi	a0,a0,-68 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202cd4:	f7afd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202cd8:	00003697          	auipc	a3,0x3
ffffffffc0202cdc:	13868693          	addi	a3,a3,312 # ffffffffc0205e10 <default_pmm_manager+0x2d8>
ffffffffc0202ce0:	00003617          	auipc	a2,0x3
ffffffffc0202ce4:	c5860613          	addi	a2,a2,-936 # ffffffffc0205938 <commands+0x620>
ffffffffc0202ce8:	1fd00593          	li	a1,509
ffffffffc0202cec:	00003517          	auipc	a0,0x3
ffffffffc0202cf0:	f9c50513          	addi	a0,a0,-100 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202cf4:	f5afd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202cf8:	00003697          	auipc	a3,0x3
ffffffffc0202cfc:	13868693          	addi	a3,a3,312 # ffffffffc0205e30 <default_pmm_manager+0x2f8>
ffffffffc0202d00:	00003617          	auipc	a2,0x3
ffffffffc0202d04:	c3860613          	addi	a2,a2,-968 # ffffffffc0205938 <commands+0x620>
ffffffffc0202d08:	1fe00593          	li	a1,510
ffffffffc0202d0c:	00003517          	auipc	a0,0x3
ffffffffc0202d10:	f7c50513          	addi	a0,a0,-132 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202d14:	f3afd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202d18:	00003697          	auipc	a3,0x3
ffffffffc0202d1c:	37868693          	addi	a3,a3,888 # ffffffffc0206090 <default_pmm_manager+0x558>
ffffffffc0202d20:	00003617          	auipc	a2,0x3
ffffffffc0202d24:	c1860613          	addi	a2,a2,-1000 # ffffffffc0205938 <commands+0x620>
ffffffffc0202d28:	21b00593          	li	a1,539
ffffffffc0202d2c:	00003517          	auipc	a0,0x3
ffffffffc0202d30:	f5c50513          	addi	a0,a0,-164 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202d34:	f1afd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202d38:	00003697          	auipc	a3,0x3
ffffffffc0202d3c:	1e068693          	addi	a3,a3,480 # ffffffffc0205f18 <default_pmm_manager+0x3e0>
ffffffffc0202d40:	00003617          	auipc	a2,0x3
ffffffffc0202d44:	bf860613          	addi	a2,a2,-1032 # ffffffffc0205938 <commands+0x620>
ffffffffc0202d48:	21e00593          	li	a1,542
ffffffffc0202d4c:	00003517          	auipc	a0,0x3
ffffffffc0202d50:	f3c50513          	addi	a0,a0,-196 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202d54:	efafd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202d58:	00003697          	auipc	a3,0x3
ffffffffc0202d5c:	32068693          	addi	a3,a3,800 # ffffffffc0206078 <default_pmm_manager+0x540>
ffffffffc0202d60:	00003617          	auipc	a2,0x3
ffffffffc0202d64:	bd860613          	addi	a2,a2,-1064 # ffffffffc0205938 <commands+0x620>
ffffffffc0202d68:	21f00593          	li	a1,543
ffffffffc0202d6c:	00003517          	auipc	a0,0x3
ffffffffc0202d70:	f1c50513          	addi	a0,a0,-228 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202d74:	edafd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202d78:	00003697          	auipc	a3,0x3
ffffffffc0202d7c:	33068693          	addi	a3,a3,816 # ffffffffc02060a8 <default_pmm_manager+0x570>
ffffffffc0202d80:	00003617          	auipc	a2,0x3
ffffffffc0202d84:	bb860613          	addi	a2,a2,-1096 # ffffffffc0205938 <commands+0x620>
ffffffffc0202d88:	22200593          	li	a1,546
ffffffffc0202d8c:	00003517          	auipc	a0,0x3
ffffffffc0202d90:	efc50513          	addi	a0,a0,-260 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202d94:	ebafd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202d98:	00003697          	auipc	a3,0x3
ffffffffc0202d9c:	35868693          	addi	a3,a3,856 # ffffffffc02060f0 <default_pmm_manager+0x5b8>
ffffffffc0202da0:	00003617          	auipc	a2,0x3
ffffffffc0202da4:	b9860613          	addi	a2,a2,-1128 # ffffffffc0205938 <commands+0x620>
ffffffffc0202da8:	22d00593          	li	a1,557
ffffffffc0202dac:	00003517          	auipc	a0,0x3
ffffffffc0202db0:	edc50513          	addi	a0,a0,-292 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202db4:	e9afd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(boot_pgdir_va[0] & PTE_V);
ffffffffc0202db8:	00003697          	auipc	a3,0x3
ffffffffc0202dbc:	24068693          	addi	a3,a3,576 # ffffffffc0205ff8 <default_pmm_manager+0x4c0>
ffffffffc0202dc0:	00003617          	auipc	a2,0x3
ffffffffc0202dc4:	b7860613          	addi	a2,a2,-1160 # ffffffffc0205938 <commands+0x620>
ffffffffc0202dc8:	21300593          	li	a1,531
ffffffffc0202dcc:	00003517          	auipc	a0,0x3
ffffffffc0202dd0:	ebc50513          	addi	a0,a0,-324 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202dd4:	e7afd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202dd8:	00003697          	auipc	a3,0x3
ffffffffc0202ddc:	24068693          	addi	a3,a3,576 # ffffffffc0206018 <default_pmm_manager+0x4e0>
ffffffffc0202de0:	00003617          	auipc	a2,0x3
ffffffffc0202de4:	b5860613          	addi	a2,a2,-1192 # ffffffffc0205938 <commands+0x620>
ffffffffc0202de8:	21400593          	li	a1,532
ffffffffc0202dec:	00003517          	auipc	a0,0x3
ffffffffc0202df0:	e9c50513          	addi	a0,a0,-356 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202df4:	e5afd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202df8:	00003697          	auipc	a3,0x3
ffffffffc0202dfc:	23868693          	addi	a3,a3,568 # ffffffffc0206030 <default_pmm_manager+0x4f8>
ffffffffc0202e00:	00003617          	auipc	a2,0x3
ffffffffc0202e04:	b3860613          	addi	a2,a2,-1224 # ffffffffc0205938 <commands+0x620>
ffffffffc0202e08:	21600593          	li	a1,534
ffffffffc0202e0c:	00003517          	auipc	a0,0x3
ffffffffc0202e10:	e7c50513          	addi	a0,a0,-388 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202e14:	e3afd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202e18:	00003697          	auipc	a3,0x3
ffffffffc0202e1c:	24868693          	addi	a3,a3,584 # ffffffffc0206060 <default_pmm_manager+0x528>
ffffffffc0202e20:	00003617          	auipc	a2,0x3
ffffffffc0202e24:	b1860613          	addi	a2,a2,-1256 # ffffffffc0205938 <commands+0x620>
ffffffffc0202e28:	21700593          	li	a1,535
ffffffffc0202e2c:	00003517          	auipc	a0,0x3
ffffffffc0202e30:	e5c50513          	addi	a0,a0,-420 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202e34:	e1afd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202e38:	00003697          	auipc	a3,0x3
ffffffffc0202e3c:	24068693          	addi	a3,a3,576 # ffffffffc0206078 <default_pmm_manager+0x540>
ffffffffc0202e40:	00003617          	auipc	a2,0x3
ffffffffc0202e44:	af860613          	addi	a2,a2,-1288 # ffffffffc0205938 <commands+0x620>
ffffffffc0202e48:	21800593          	li	a1,536
ffffffffc0202e4c:	00003517          	auipc	a0,0x3
ffffffffc0202e50:	e3c50513          	addi	a0,a0,-452 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202e54:	dfafd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202e58:	00003697          	auipc	a3,0x3
ffffffffc0202e5c:	14868693          	addi	a3,a3,328 # ffffffffc0205fa0 <default_pmm_manager+0x468>
ffffffffc0202e60:	00003617          	auipc	a2,0x3
ffffffffc0202e64:	ad860613          	addi	a2,a2,-1320 # ffffffffc0205938 <commands+0x620>
ffffffffc0202e68:	21900593          	li	a1,537
ffffffffc0202e6c:	00003517          	auipc	a0,0x3
ffffffffc0202e70:	e1c50513          	addi	a0,a0,-484 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202e74:	ddafd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202e78:	00003697          	auipc	a3,0x3
ffffffffc0202e7c:	08868693          	addi	a3,a3,136 # ffffffffc0205f00 <default_pmm_manager+0x3c8>
ffffffffc0202e80:	00003617          	auipc	a2,0x3
ffffffffc0202e84:	ab860613          	addi	a2,a2,-1352 # ffffffffc0205938 <commands+0x620>
ffffffffc0202e88:	21a00593          	li	a1,538
ffffffffc0202e8c:	00003517          	auipc	a0,0x3
ffffffffc0202e90:	dfc50513          	addi	a0,a0,-516 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202e94:	dbafd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202e98:	00003697          	auipc	a3,0x3
ffffffffc0202e9c:	15068693          	addi	a3,a3,336 # ffffffffc0205fe8 <default_pmm_manager+0x4b0>
ffffffffc0202ea0:	00003617          	auipc	a2,0x3
ffffffffc0202ea4:	a9860613          	addi	a2,a2,-1384 # ffffffffc0205938 <commands+0x620>
ffffffffc0202ea8:	21200593          	li	a1,530
ffffffffc0202eac:	00003517          	auipc	a0,0x3
ffffffffc0202eb0:	ddc50513          	addi	a0,a0,-548 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202eb4:	d9afd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202eb8:	00003697          	auipc	a3,0x3
ffffffffc0202ebc:	33068693          	addi	a3,a3,816 # ffffffffc02061e8 <default_pmm_manager+0x6b0>
ffffffffc0202ec0:	00003617          	auipc	a2,0x3
ffffffffc0202ec4:	a7860613          	addi	a2,a2,-1416 # ffffffffc0205938 <commands+0x620>
ffffffffc0202ec8:	24500593          	li	a1,581
ffffffffc0202ecc:	00003517          	auipc	a0,0x3
ffffffffc0202ed0:	dbc50513          	addi	a0,a0,-580 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202ed4:	d7afd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202ed8:	00003697          	auipc	a3,0x3
ffffffffc0202edc:	32868693          	addi	a3,a3,808 # ffffffffc0206200 <default_pmm_manager+0x6c8>
ffffffffc0202ee0:	00003617          	auipc	a2,0x3
ffffffffc0202ee4:	a5860613          	addi	a2,a2,-1448 # ffffffffc0205938 <commands+0x620>
ffffffffc0202ee8:	24600593          	li	a1,582
ffffffffc0202eec:	00003517          	auipc	a0,0x3
ffffffffc0202ef0:	d9c50513          	addi	a0,a0,-612 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202ef4:	d5afd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202ef8:	00003697          	auipc	a3,0x3
ffffffffc0202efc:	35068693          	addi	a3,a3,848 # ffffffffc0206248 <default_pmm_manager+0x710>
ffffffffc0202f00:	00003617          	auipc	a2,0x3
ffffffffc0202f04:	a3860613          	addi	a2,a2,-1480 # ffffffffc0205938 <commands+0x620>
ffffffffc0202f08:	24700593          	li	a1,583
ffffffffc0202f0c:	00003517          	auipc	a0,0x3
ffffffffc0202f10:	d7c50513          	addi	a0,a0,-644 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202f14:	d3afd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202f18:	00003697          	auipc	a3,0x3
ffffffffc0202f1c:	36068693          	addi	a3,a3,864 # ffffffffc0206278 <default_pmm_manager+0x740>
ffffffffc0202f20:	00003617          	auipc	a2,0x3
ffffffffc0202f24:	a1860613          	addi	a2,a2,-1512 # ffffffffc0205938 <commands+0x620>
ffffffffc0202f28:	24b00593          	li	a1,587
ffffffffc0202f2c:	00003517          	auipc	a0,0x3
ffffffffc0202f30:	d5c50513          	addi	a0,a0,-676 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202f34:	d1afd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc0202f38:	00003697          	auipc	a3,0x3
ffffffffc0202f3c:	25868693          	addi	a3,a3,600 # ffffffffc0206190 <default_pmm_manager+0x658>
ffffffffc0202f40:	00003617          	auipc	a2,0x3
ffffffffc0202f44:	9f860613          	addi	a2,a2,-1544 # ffffffffc0205938 <commands+0x620>
ffffffffc0202f48:	24000593          	li	a1,576
ffffffffc0202f4c:	00003517          	auipc	a0,0x3
ffffffffc0202f50:	d3c50513          	addi	a0,a0,-708 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202f54:	cfafd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202f58:	00003697          	auipc	a3,0x3
ffffffffc0202f5c:	25068693          	addi	a3,a3,592 # ffffffffc02061a8 <default_pmm_manager+0x670>
ffffffffc0202f60:	00003617          	auipc	a2,0x3
ffffffffc0202f64:	9d860613          	addi	a2,a2,-1576 # ffffffffc0205938 <commands+0x620>
ffffffffc0202f68:	24400593          	li	a1,580
ffffffffc0202f6c:	00003517          	auipc	a0,0x3
ffffffffc0202f70:	d1c50513          	addi	a0,a0,-740 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202f74:	cdafd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202f78:	00003697          	auipc	a3,0x3
ffffffffc0202f7c:	14868693          	addi	a3,a3,328 # ffffffffc02060c0 <default_pmm_manager+0x588>
ffffffffc0202f80:	00003617          	auipc	a2,0x3
ffffffffc0202f84:	9b860613          	addi	a2,a2,-1608 # ffffffffc0205938 <commands+0x620>
ffffffffc0202f88:	22500593          	li	a1,549
ffffffffc0202f8c:	00003517          	auipc	a0,0x3
ffffffffc0202f90:	cfc50513          	addi	a0,a0,-772 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202f94:	cbafd0ef          	jal	ra,ffffffffc020044e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202f98:	00003617          	auipc	a2,0x3
ffffffffc0202f9c:	bd860613          	addi	a2,a2,-1064 # ffffffffc0205b70 <default_pmm_manager+0x38>
ffffffffc0202fa0:	07100593          	li	a1,113
ffffffffc0202fa4:	00003517          	auipc	a0,0x3
ffffffffc0202fa8:	bf450513          	addi	a0,a0,-1036 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc0202fac:	ca2fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202fb0:	00003697          	auipc	a3,0x3
ffffffffc0202fb4:	30068693          	addi	a3,a3,768 # ffffffffc02062b0 <default_pmm_manager+0x778>
ffffffffc0202fb8:	00003617          	auipc	a2,0x3
ffffffffc0202fbc:	98060613          	addi	a2,a2,-1664 # ffffffffc0205938 <commands+0x620>
ffffffffc0202fc0:	24e00593          	li	a1,590
ffffffffc0202fc4:	00003517          	auipc	a0,0x3
ffffffffc0202fc8:	cc450513          	addi	a0,a0,-828 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202fcc:	c82fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202fd0:	00003697          	auipc	a3,0x3
ffffffffc0202fd4:	12068693          	addi	a3,a3,288 # ffffffffc02060f0 <default_pmm_manager+0x5b8>
ffffffffc0202fd8:	00003617          	auipc	a2,0x3
ffffffffc0202fdc:	96060613          	addi	a2,a2,-1696 # ffffffffc0205938 <commands+0x620>
ffffffffc0202fe0:	25700593          	li	a1,599
ffffffffc0202fe4:	00003517          	auipc	a0,0x3
ffffffffc0202fe8:	ca450513          	addi	a0,a0,-860 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0202fec:	c62fd0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("invalid physical memory information");
ffffffffc0202ff0:	00003617          	auipc	a2,0x3
ffffffffc0202ff4:	d0860613          	addi	a2,a2,-760 # ffffffffc0205cf8 <default_pmm_manager+0x1c0>
ffffffffc0202ff8:	06300593          	li	a1,99
ffffffffc0202ffc:	00003517          	auipc	a0,0x3
ffffffffc0203000:	c8c50513          	addi	a0,a0,-884 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0203004:	c4afd0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("no usable physical memory");
ffffffffc0203008:	00003617          	auipc	a2,0x3
ffffffffc020300c:	d1860613          	addi	a2,a2,-744 # ffffffffc0205d20 <default_pmm_manager+0x1e8>
ffffffffc0203010:	06d00593          	li	a1,109
ffffffffc0203014:	00003517          	auipc	a0,0x3
ffffffffc0203018:	c7450513          	addi	a0,a0,-908 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc020301c:	c32fd0ef          	jal	ra,ffffffffc020044e <__panic>
    uintptr_t metadata_start = PADDR(pages);
ffffffffc0203020:	00003617          	auipc	a2,0x3
ffffffffc0203024:	bf860613          	addi	a2,a2,-1032 # ffffffffc0205c18 <default_pmm_manager+0xe0>
ffffffffc0203028:	07c00593          	li	a1,124
ffffffffc020302c:	00003517          	auipc	a0,0x3
ffffffffc0203030:	c5c50513          	addi	a0,a0,-932 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0203034:	c1afd0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("not enough memory for page descriptors");
ffffffffc0203038:	00003617          	auipc	a2,0x3
ffffffffc020303c:	d0860613          	addi	a2,a2,-760 # ffffffffc0205d40 <default_pmm_manager+0x208>
ffffffffc0203040:	08100593          	li	a1,129
ffffffffc0203044:	00003517          	auipc	a0,0x3
ffffffffc0203048:	c4450513          	addi	a0,a0,-956 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc020304c:	c02fd0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("no complete free pages");
ffffffffc0203050:	00003617          	auipc	a2,0x3
ffffffffc0203054:	d1860613          	addi	a2,a2,-744 # ffffffffc0205d68 <default_pmm_manager+0x230>
ffffffffc0203058:	08900593          	li	a1,137
ffffffffc020305c:	00003517          	auipc	a0,0x3
ffffffffc0203060:	c2c50513          	addi	a0,a0,-980 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0203064:	beafd0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0203068 <pgdir_alloc_page>:
{
ffffffffc0203068:	7179                	addi	sp,sp,-48
ffffffffc020306a:	ec26                	sd	s1,24(sp)
ffffffffc020306c:	e84a                	sd	s2,16(sp)
ffffffffc020306e:	e052                	sd	s4,0(sp)
ffffffffc0203070:	f406                	sd	ra,40(sp)
ffffffffc0203072:	f022                	sd	s0,32(sp)
ffffffffc0203074:	e44e                	sd	s3,8(sp)
ffffffffc0203076:	8a2a                	mv	s4,a0
ffffffffc0203078:	84ae                	mv	s1,a1
ffffffffc020307a:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020307c:	100027f3          	csrr	a5,sstatus
ffffffffc0203080:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc0203082:	000ad997          	auipc	s3,0xad
ffffffffc0203086:	68698993          	addi	s3,s3,1670 # ffffffffc02b0708 <pmm_manager>
ffffffffc020308a:	ef8d                	bnez	a5,ffffffffc02030c4 <pgdir_alloc_page+0x5c>
ffffffffc020308c:	0009b783          	ld	a5,0(s3)
ffffffffc0203090:	4505                	li	a0,1
ffffffffc0203092:	6f9c                	ld	a5,24(a5)
ffffffffc0203094:	9782                	jalr	a5
ffffffffc0203096:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc0203098:	cc09                	beqz	s0,ffffffffc02030b2 <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc020309a:	86ca                	mv	a3,s2
ffffffffc020309c:	8626                	mv	a2,s1
ffffffffc020309e:	85a2                	mv	a1,s0
ffffffffc02030a0:	8552                	mv	a0,s4
ffffffffc02030a2:	f1dfe0ef          	jal	ra,ffffffffc0201fbe <page_insert>
ffffffffc02030a6:	e915                	bnez	a0,ffffffffc02030da <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc02030a8:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc02030aa:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc02030ac:	4785                	li	a5,1
ffffffffc02030ae:	04f71e63          	bne	a4,a5,ffffffffc020310a <pgdir_alloc_page+0xa2>
}
ffffffffc02030b2:	70a2                	ld	ra,40(sp)
ffffffffc02030b4:	8522                	mv	a0,s0
ffffffffc02030b6:	7402                	ld	s0,32(sp)
ffffffffc02030b8:	64e2                	ld	s1,24(sp)
ffffffffc02030ba:	6942                	ld	s2,16(sp)
ffffffffc02030bc:	69a2                	ld	s3,8(sp)
ffffffffc02030be:	6a02                	ld	s4,0(sp)
ffffffffc02030c0:	6145                	addi	sp,sp,48
ffffffffc02030c2:	8082                	ret
        intr_disable();
ffffffffc02030c4:	8b1fd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02030c8:	0009b783          	ld	a5,0(s3)
ffffffffc02030cc:	4505                	li	a0,1
ffffffffc02030ce:	6f9c                	ld	a5,24(a5)
ffffffffc02030d0:	9782                	jalr	a5
ffffffffc02030d2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02030d4:	89bfd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc02030d8:	b7c1                	j	ffffffffc0203098 <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02030da:	100027f3          	csrr	a5,sstatus
ffffffffc02030de:	8b89                	andi	a5,a5,2
ffffffffc02030e0:	eb89                	bnez	a5,ffffffffc02030f2 <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc02030e2:	0009b783          	ld	a5,0(s3)
ffffffffc02030e6:	8522                	mv	a0,s0
ffffffffc02030e8:	4585                	li	a1,1
ffffffffc02030ea:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02030ec:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02030ee:	9782                	jalr	a5
    if (flag)
ffffffffc02030f0:	b7c9                	j	ffffffffc02030b2 <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc02030f2:	883fd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc02030f6:	0009b783          	ld	a5,0(s3)
ffffffffc02030fa:	8522                	mv	a0,s0
ffffffffc02030fc:	4585                	li	a1,1
ffffffffc02030fe:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc0203100:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc0203102:	9782                	jalr	a5
        intr_enable();
ffffffffc0203104:	86bfd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0203108:	b76d                	j	ffffffffc02030b2 <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc020310a:	00003697          	auipc	a3,0x3
ffffffffc020310e:	1ee68693          	addi	a3,a3,494 # ffffffffc02062f8 <default_pmm_manager+0x7c0>
ffffffffc0203112:	00003617          	auipc	a2,0x3
ffffffffc0203116:	82660613          	addi	a2,a2,-2010 # ffffffffc0205938 <commands+0x620>
ffffffffc020311a:	1e400593          	li	a1,484
ffffffffc020311e:	00003517          	auipc	a0,0x3
ffffffffc0203122:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0205c88 <default_pmm_manager+0x150>
ffffffffc0203126:	b28fd0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc020312a <print_pgdir>:
    }
    return 0;
}

void print_pgdir(void) {
    cprintf("current page-directory root: 0x%lx\n", (unsigned long)read_csr(satp));
ffffffffc020312a:	180025f3          	csrr	a1,satp
ffffffffc020312e:	00003517          	auipc	a0,0x3
ffffffffc0203132:	1e250513          	addi	a0,a0,482 # ffffffffc0206310 <default_pmm_manager+0x7d8>
ffffffffc0203136:	85efd06f          	j	ffffffffc0200194 <cprintf>

ffffffffc020313a <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc020313a:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020313c:	00003697          	auipc	a3,0x3
ffffffffc0203140:	1fc68693          	addi	a3,a3,508 # ffffffffc0206338 <default_pmm_manager+0x800>
ffffffffc0203144:	00002617          	auipc	a2,0x2
ffffffffc0203148:	7f460613          	addi	a2,a2,2036 # ffffffffc0205938 <commands+0x620>
ffffffffc020314c:	07400593          	li	a1,116
ffffffffc0203150:	00003517          	auipc	a0,0x3
ffffffffc0203154:	20850513          	addi	a0,a0,520 # ffffffffc0206358 <default_pmm_manager+0x820>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203158:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020315a:	af4fd0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc020315e <mm_create>:
{
ffffffffc020315e:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203160:	04000513          	li	a0,64
{
ffffffffc0203164:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203166:	da8fe0ef          	jal	ra,ffffffffc020170e <kmalloc>
    if (mm != NULL)
ffffffffc020316a:	cd19                	beqz	a0,ffffffffc0203188 <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc020316c:	e508                	sd	a0,8(a0)
ffffffffc020316e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203170:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203174:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203178:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc020317c:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc0203180:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc0203184:	02053c23          	sd	zero,56(a0)
}
ffffffffc0203188:	60a2                	ld	ra,8(sp)
ffffffffc020318a:	0141                	addi	sp,sp,16
ffffffffc020318c:	8082                	ret

ffffffffc020318e <find_vma>:
{
ffffffffc020318e:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc0203190:	c505                	beqz	a0,ffffffffc02031b8 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203192:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203194:	c501                	beqz	a0,ffffffffc020319c <find_vma+0xe>
ffffffffc0203196:	651c                	ld	a5,8(a0)
ffffffffc0203198:	02f5f263          	bgeu	a1,a5,ffffffffc02031bc <find_vma+0x2e>
    return listelm->next;
ffffffffc020319c:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc020319e:	00f68d63          	beq	a3,a5,ffffffffc02031b8 <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc02031a2:	fe87b703          	ld	a4,-24(a5)
ffffffffc02031a6:	00e5e663          	bltu	a1,a4,ffffffffc02031b2 <find_vma+0x24>
ffffffffc02031aa:	ff07b703          	ld	a4,-16(a5)
ffffffffc02031ae:	00e5ec63          	bltu	a1,a4,ffffffffc02031c6 <find_vma+0x38>
ffffffffc02031b2:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc02031b4:	fef697e3          	bne	a3,a5,ffffffffc02031a2 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc02031b8:	4501                	li	a0,0
}
ffffffffc02031ba:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc02031bc:	691c                	ld	a5,16(a0)
ffffffffc02031be:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020319c <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc02031c2:	ea88                	sd	a0,16(a3)
ffffffffc02031c4:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc02031c6:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc02031ca:	ea88                	sd	a0,16(a3)
ffffffffc02031cc:	8082                	ret

ffffffffc02031ce <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc02031ce:	6590                	ld	a2,8(a1)
ffffffffc02031d0:	0105b803          	ld	a6,16(a1)
{
ffffffffc02031d4:	1141                	addi	sp,sp,-16
ffffffffc02031d6:	e406                	sd	ra,8(sp)
ffffffffc02031d8:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02031da:	01066763          	bltu	a2,a6,ffffffffc02031e8 <insert_vma_struct+0x1a>
ffffffffc02031de:	a085                	j	ffffffffc020323e <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02031e0:	fe87b703          	ld	a4,-24(a5)
ffffffffc02031e4:	04e66863          	bltu	a2,a4,ffffffffc0203234 <insert_vma_struct+0x66>
ffffffffc02031e8:	86be                	mv	a3,a5
ffffffffc02031ea:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc02031ec:	fef51ae3          	bne	a0,a5,ffffffffc02031e0 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc02031f0:	02a68463          	beq	a3,a0,ffffffffc0203218 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02031f4:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02031f8:	fe86b883          	ld	a7,-24(a3)
ffffffffc02031fc:	08e8f163          	bgeu	a7,a4,ffffffffc020327e <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203200:	04e66f63          	bltu	a2,a4,ffffffffc020325e <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc0203204:	00f50a63          	beq	a0,a5,ffffffffc0203218 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0203208:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020320c:	05076963          	bltu	a4,a6,ffffffffc020325e <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0203210:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203214:	02c77363          	bgeu	a4,a2,ffffffffc020323a <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0203218:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc020321a:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020321c:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203220:	e390                	sd	a2,0(a5)
ffffffffc0203222:	e690                	sd	a2,8(a3)
}
ffffffffc0203224:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203226:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203228:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc020322a:	0017079b          	addiw	a5,a4,1
ffffffffc020322e:	d11c                	sw	a5,32(a0)
}
ffffffffc0203230:	0141                	addi	sp,sp,16
ffffffffc0203232:	8082                	ret
    if (le_prev != list)
ffffffffc0203234:	fca690e3          	bne	a3,a0,ffffffffc02031f4 <insert_vma_struct+0x26>
ffffffffc0203238:	bfd1                	j	ffffffffc020320c <insert_vma_struct+0x3e>
ffffffffc020323a:	f01ff0ef          	jal	ra,ffffffffc020313a <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020323e:	00003697          	auipc	a3,0x3
ffffffffc0203242:	12a68693          	addi	a3,a3,298 # ffffffffc0206368 <default_pmm_manager+0x830>
ffffffffc0203246:	00002617          	auipc	a2,0x2
ffffffffc020324a:	6f260613          	addi	a2,a2,1778 # ffffffffc0205938 <commands+0x620>
ffffffffc020324e:	07a00593          	li	a1,122
ffffffffc0203252:	00003517          	auipc	a0,0x3
ffffffffc0203256:	10650513          	addi	a0,a0,262 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc020325a:	9f4fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020325e:	00003697          	auipc	a3,0x3
ffffffffc0203262:	14a68693          	addi	a3,a3,330 # ffffffffc02063a8 <default_pmm_manager+0x870>
ffffffffc0203266:	00002617          	auipc	a2,0x2
ffffffffc020326a:	6d260613          	addi	a2,a2,1746 # ffffffffc0205938 <commands+0x620>
ffffffffc020326e:	07300593          	li	a1,115
ffffffffc0203272:	00003517          	auipc	a0,0x3
ffffffffc0203276:	0e650513          	addi	a0,a0,230 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc020327a:	9d4fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020327e:	00003697          	auipc	a3,0x3
ffffffffc0203282:	10a68693          	addi	a3,a3,266 # ffffffffc0206388 <default_pmm_manager+0x850>
ffffffffc0203286:	00002617          	auipc	a2,0x2
ffffffffc020328a:	6b260613          	addi	a2,a2,1714 # ffffffffc0205938 <commands+0x620>
ffffffffc020328e:	07200593          	li	a1,114
ffffffffc0203292:	00003517          	auipc	a0,0x3
ffffffffc0203296:	0c650513          	addi	a0,a0,198 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc020329a:	9b4fd0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc020329e <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc020329e:	591c                	lw	a5,48(a0)
{
ffffffffc02032a0:	1141                	addi	sp,sp,-16
ffffffffc02032a2:	e406                	sd	ra,8(sp)
ffffffffc02032a4:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc02032a6:	e78d                	bnez	a5,ffffffffc02032d0 <mm_destroy+0x32>
ffffffffc02032a8:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02032aa:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc02032ac:	00a40c63          	beq	s0,a0,ffffffffc02032c4 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02032b0:	6118                	ld	a4,0(a0)
ffffffffc02032b2:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc02032b4:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02032b6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02032b8:	e398                	sd	a4,0(a5)
ffffffffc02032ba:	d04fe0ef          	jal	ra,ffffffffc02017be <kfree>
    return listelm->next;
ffffffffc02032be:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc02032c0:	fea418e3          	bne	s0,a0,ffffffffc02032b0 <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc02032c4:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc02032c6:	6402                	ld	s0,0(sp)
ffffffffc02032c8:	60a2                	ld	ra,8(sp)
ffffffffc02032ca:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc02032cc:	cf2fe06f          	j	ffffffffc02017be <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02032d0:	00003697          	auipc	a3,0x3
ffffffffc02032d4:	0f868693          	addi	a3,a3,248 # ffffffffc02063c8 <default_pmm_manager+0x890>
ffffffffc02032d8:	00002617          	auipc	a2,0x2
ffffffffc02032dc:	66060613          	addi	a2,a2,1632 # ffffffffc0205938 <commands+0x620>
ffffffffc02032e0:	09e00593          	li	a1,158
ffffffffc02032e4:	00003517          	auipc	a0,0x3
ffffffffc02032e8:	07450513          	addi	a0,a0,116 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc02032ec:	962fd0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02032f0 <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc02032f0:	7139                	addi	sp,sp,-64
ffffffffc02032f2:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02032f4:	6405                	lui	s0,0x1
ffffffffc02032f6:	147d                	addi	s0,s0,-1
ffffffffc02032f8:	77fd                	lui	a5,0xfffff
ffffffffc02032fa:	9622                	add	a2,a2,s0
ffffffffc02032fc:	962e                	add	a2,a2,a1
{
ffffffffc02032fe:	f426                	sd	s1,40(sp)
ffffffffc0203300:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203302:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc0203306:	f04a                	sd	s2,32(sp)
ffffffffc0203308:	ec4e                	sd	s3,24(sp)
ffffffffc020330a:	e852                	sd	s4,16(sp)
ffffffffc020330c:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end))
ffffffffc020330e:	002005b7          	lui	a1,0x200
ffffffffc0203312:	00f67433          	and	s0,a2,a5
ffffffffc0203316:	06b4e363          	bltu	s1,a1,ffffffffc020337c <mm_map+0x8c>
ffffffffc020331a:	0684f163          	bgeu	s1,s0,ffffffffc020337c <mm_map+0x8c>
ffffffffc020331e:	4785                	li	a5,1
ffffffffc0203320:	07fe                	slli	a5,a5,0x1f
ffffffffc0203322:	0487ed63          	bltu	a5,s0,ffffffffc020337c <mm_map+0x8c>
ffffffffc0203326:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0203328:	cd21                	beqz	a0,ffffffffc0203380 <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc020332a:	85a6                	mv	a1,s1
ffffffffc020332c:	8ab6                	mv	s5,a3
ffffffffc020332e:	8a3a                	mv	s4,a4
ffffffffc0203330:	e5fff0ef          	jal	ra,ffffffffc020318e <find_vma>
ffffffffc0203334:	c501                	beqz	a0,ffffffffc020333c <mm_map+0x4c>
ffffffffc0203336:	651c                	ld	a5,8(a0)
ffffffffc0203338:	0487e263          	bltu	a5,s0,ffffffffc020337c <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020333c:	03000513          	li	a0,48
ffffffffc0203340:	bcefe0ef          	jal	ra,ffffffffc020170e <kmalloc>
ffffffffc0203344:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0203346:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc0203348:	02090163          	beqz	s2,ffffffffc020336a <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc020334c:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc020334e:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0203352:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0203356:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc020335a:	85ca                	mv	a1,s2
ffffffffc020335c:	e73ff0ef          	jal	ra,ffffffffc02031ce <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0203360:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc0203362:	000a0463          	beqz	s4,ffffffffc020336a <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0203366:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc020336a:	70e2                	ld	ra,56(sp)
ffffffffc020336c:	7442                	ld	s0,48(sp)
ffffffffc020336e:	74a2                	ld	s1,40(sp)
ffffffffc0203370:	7902                	ld	s2,32(sp)
ffffffffc0203372:	69e2                	ld	s3,24(sp)
ffffffffc0203374:	6a42                	ld	s4,16(sp)
ffffffffc0203376:	6aa2                	ld	s5,8(sp)
ffffffffc0203378:	6121                	addi	sp,sp,64
ffffffffc020337a:	8082                	ret
        return -E_INVAL;
ffffffffc020337c:	5575                	li	a0,-3
ffffffffc020337e:	b7f5                	j	ffffffffc020336a <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0203380:	00003697          	auipc	a3,0x3
ffffffffc0203384:	06068693          	addi	a3,a3,96 # ffffffffc02063e0 <default_pmm_manager+0x8a8>
ffffffffc0203388:	00002617          	auipc	a2,0x2
ffffffffc020338c:	5b060613          	addi	a2,a2,1456 # ffffffffc0205938 <commands+0x620>
ffffffffc0203390:	0b300593          	li	a1,179
ffffffffc0203394:	00003517          	auipc	a0,0x3
ffffffffc0203398:	fc450513          	addi	a0,a0,-60 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc020339c:	8b2fd0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02033a0 <dup_mmap>:

// Duplicate all VMAs and their mapped user pages from from to to.
int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc02033a0:	7179                	addi	sp,sp,-48
ffffffffc02033a2:	f406                	sd	ra,40(sp)
ffffffffc02033a4:	f022                	sd	s0,32(sp)
ffffffffc02033a6:	ec26                	sd	s1,24(sp)
ffffffffc02033a8:	e84a                	sd	s2,16(sp)
ffffffffc02033aa:	e44e                	sd	s3,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02033ac:	c545                	beqz	a0,ffffffffc0203454 <dup_mmap+0xb4>
ffffffffc02033ae:	84ae                	mv	s1,a1
ffffffffc02033b0:	c1d5                	beqz	a1,ffffffffc0203454 <dup_mmap+0xb4>
    assert(to->pgdir != NULL && from->pgdir != NULL);
ffffffffc02033b2:	6d1c                	ld	a5,24(a0)
ffffffffc02033b4:	892a                	mv	s2,a0
ffffffffc02033b6:	cfbd                	beqz	a5,ffffffffc0203434 <dup_mmap+0x94>
ffffffffc02033b8:	6d9c                	ld	a5,24(a1)
ffffffffc02033ba:	cfad                	beqz	a5,ffffffffc0203434 <dup_mmap+0x94>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc02033bc:	03858413          	addi	s0,a1,56 # 200038 <_binary_obj___user_exit_out_size+0x1f47d0>
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02033c0:	4785                	li	a5,1
ffffffffc02033c2:	40f437af          	amoor.d	a5,a5,(s0)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc02033c6:	8b85                	andi	a5,a5,1
ffffffffc02033c8:	cb81                	beqz	a5,ffffffffc02033d8 <dup_mmap+0x38>
ffffffffc02033ca:	4985                	li	s3,1
    {
        schedule();
ffffffffc02033cc:	6ca010ef          	jal	ra,ffffffffc0204a96 <schedule>
ffffffffc02033d0:	413437af          	amoor.d	a5,s3,(s0)
    while (!try_lock(lock))
ffffffffc02033d4:	8b85                	andi	a5,a5,1
ffffffffc02033d6:	fbfd                	bnez	a5,ffffffffc02033cc <dup_mmap+0x2c>
ffffffffc02033d8:	6480                	ld	s0,8(s1)

    int ret = 0;
    lock_mm(from);
    list_entry_t *list = &from->mmap_list;
    for (list_entry_t *le = list_next(list); le != list; le = list_next(le))
ffffffffc02033da:	02849163          	bne	s1,s0,ffffffffc02033fc <dup_mmap+0x5c>
ffffffffc02033de:	a889                	j	ffffffffc0203430 <dup_mmap+0x90>
                          vma->vm_end - vma->vm_start,
                          vma->vm_flags, NULL)) != 0)
        {
            break;
        }
        if ((ret = copy_range(to->pgdir, from->pgdir,
ffffffffc02033e0:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x9300>
ffffffffc02033e4:	fe843603          	ld	a2,-24(s0)
ffffffffc02033e8:	6c8c                	ld	a1,24(s1)
ffffffffc02033ea:	01893503          	ld	a0,24(s2)
ffffffffc02033ee:	4701                	li	a4,0
ffffffffc02033f0:	cb9fe0ef          	jal	ra,ffffffffc02020a8 <copy_range>
ffffffffc02033f4:	e105                	bnez	a0,ffffffffc0203414 <dup_mmap+0x74>
ffffffffc02033f6:	6400                	ld	s0,8(s0)
    for (list_entry_t *le = list_next(list); le != list; le = list_next(le))
ffffffffc02033f8:	02848c63          	beq	s1,s0,ffffffffc0203430 <dup_mmap+0x90>
        if ((ret = mm_map(to, vma->vm_start,
ffffffffc02033fc:	fe843583          	ld	a1,-24(s0)
ffffffffc0203400:	ff043603          	ld	a2,-16(s0)
ffffffffc0203404:	ff842683          	lw	a3,-8(s0)
ffffffffc0203408:	4701                	li	a4,0
ffffffffc020340a:	8e0d                	sub	a2,a2,a1
ffffffffc020340c:	854a                	mv	a0,s2
ffffffffc020340e:	ee3ff0ef          	jal	ra,ffffffffc02032f0 <mm_map>
ffffffffc0203412:	d579                	beqz	a0,ffffffffc02033e0 <dup_mmap+0x40>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203414:	57f9                	li	a5,-2
ffffffffc0203416:	03848713          	addi	a4,s1,56
ffffffffc020341a:	60f737af          	amoand.d	a5,a5,(a4)
ffffffffc020341e:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc0203420:	cbb1                	beqz	a5,ffffffffc0203474 <dup_mmap+0xd4>
            break;
        }
    }
    unlock_mm(from);
    return ret;
}
ffffffffc0203422:	70a2                	ld	ra,40(sp)
ffffffffc0203424:	7402                	ld	s0,32(sp)
ffffffffc0203426:	64e2                	ld	s1,24(sp)
ffffffffc0203428:	6942                	ld	s2,16(sp)
ffffffffc020342a:	69a2                	ld	s3,8(sp)
ffffffffc020342c:	6145                	addi	sp,sp,48
ffffffffc020342e:	8082                	ret
{
ffffffffc0203430:	4501                	li	a0,0
ffffffffc0203432:	b7cd                	j	ffffffffc0203414 <dup_mmap+0x74>
    assert(to->pgdir != NULL && from->pgdir != NULL);
ffffffffc0203434:	00003697          	auipc	a3,0x3
ffffffffc0203438:	fdc68693          	addi	a3,a3,-36 # ffffffffc0206410 <default_pmm_manager+0x8d8>
ffffffffc020343c:	00002617          	auipc	a2,0x2
ffffffffc0203440:	4fc60613          	addi	a2,a2,1276 # ffffffffc0205938 <commands+0x620>
ffffffffc0203444:	0d100593          	li	a1,209
ffffffffc0203448:	00003517          	auipc	a0,0x3
ffffffffc020344c:	f1050513          	addi	a0,a0,-240 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc0203450:	ffffc0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(to != NULL && from != NULL);
ffffffffc0203454:	00003697          	auipc	a3,0x3
ffffffffc0203458:	f9c68693          	addi	a3,a3,-100 # ffffffffc02063f0 <default_pmm_manager+0x8b8>
ffffffffc020345c:	00002617          	auipc	a2,0x2
ffffffffc0203460:	4dc60613          	addi	a2,a2,1244 # ffffffffc0205938 <commands+0x620>
ffffffffc0203464:	0d000593          	li	a1,208
ffffffffc0203468:	00003517          	auipc	a0,0x3
ffffffffc020346c:	ef050513          	addi	a0,a0,-272 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc0203470:	fdffc0ef          	jal	ra,ffffffffc020044e <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc0203474:	00003617          	auipc	a2,0x3
ffffffffc0203478:	fcc60613          	addi	a2,a2,-52 # ffffffffc0206440 <default_pmm_manager+0x908>
ffffffffc020347c:	03f00593          	li	a1,63
ffffffffc0203480:	00003517          	auipc	a0,0x3
ffffffffc0203484:	fd050513          	addi	a0,a0,-48 # ffffffffc0206450 <default_pmm_manager+0x918>
ffffffffc0203488:	fc7fc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc020348c <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc020348c:	1101                	addi	sp,sp,-32
ffffffffc020348e:	ec06                	sd	ra,24(sp)
ffffffffc0203490:	e822                	sd	s0,16(sp)
ffffffffc0203492:	e426                	sd	s1,8(sp)
ffffffffc0203494:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203496:	c531                	beqz	a0,ffffffffc02034e2 <exit_mmap+0x56>
ffffffffc0203498:	591c                	lw	a5,48(a0)
ffffffffc020349a:	84aa                	mv	s1,a0
ffffffffc020349c:	e3b9                	bnez	a5,ffffffffc02034e2 <exit_mmap+0x56>
ffffffffc020349e:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02034a0:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc02034a4:	02850663          	beq	a0,s0,ffffffffc02034d0 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02034a8:	ff043603          	ld	a2,-16(s0)
ffffffffc02034ac:	fe843583          	ld	a1,-24(s0)
ffffffffc02034b0:	854a                	mv	a0,s2
ffffffffc02034b2:	f34fe0ef          	jal	ra,ffffffffc0201be6 <unmap_range>
ffffffffc02034b6:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc02034b8:	fe8498e3          	bne	s1,s0,ffffffffc02034a8 <exit_mmap+0x1c>
ffffffffc02034bc:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc02034be:	00848c63          	beq	s1,s0,ffffffffc02034d6 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02034c2:	ff043603          	ld	a2,-16(s0)
ffffffffc02034c6:	fe843583          	ld	a1,-24(s0)
ffffffffc02034ca:	854a                	mv	a0,s2
ffffffffc02034cc:	861fe0ef          	jal	ra,ffffffffc0201d2c <exit_range>
ffffffffc02034d0:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc02034d2:	fe8498e3          	bne	s1,s0,ffffffffc02034c2 <exit_mmap+0x36>
    }
}
ffffffffc02034d6:	60e2                	ld	ra,24(sp)
ffffffffc02034d8:	6442                	ld	s0,16(sp)
ffffffffc02034da:	64a2                	ld	s1,8(sp)
ffffffffc02034dc:	6902                	ld	s2,0(sp)
ffffffffc02034de:	6105                	addi	sp,sp,32
ffffffffc02034e0:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02034e2:	00003697          	auipc	a3,0x3
ffffffffc02034e6:	f8668693          	addi	a3,a3,-122 # ffffffffc0206468 <default_pmm_manager+0x930>
ffffffffc02034ea:	00002617          	auipc	a2,0x2
ffffffffc02034ee:	44e60613          	addi	a2,a2,1102 # ffffffffc0205938 <commands+0x620>
ffffffffc02034f2:	0eb00593          	li	a1,235
ffffffffc02034f6:	00003517          	auipc	a0,0x3
ffffffffc02034fa:	e6250513          	addi	a0,a0,-414 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc02034fe:	f51fc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0203502 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203502:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203504:	04000513          	li	a0,64
{
ffffffffc0203508:	fc06                	sd	ra,56(sp)
ffffffffc020350a:	f822                	sd	s0,48(sp)
ffffffffc020350c:	f426                	sd	s1,40(sp)
ffffffffc020350e:	f04a                	sd	s2,32(sp)
ffffffffc0203510:	ec4e                	sd	s3,24(sp)
ffffffffc0203512:	e852                	sd	s4,16(sp)
ffffffffc0203514:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203516:	9f8fe0ef          	jal	ra,ffffffffc020170e <kmalloc>
    if (mm != NULL)
ffffffffc020351a:	2e050663          	beqz	a0,ffffffffc0203806 <vmm_init+0x304>
ffffffffc020351e:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc0203520:	e508                	sd	a0,8(a0)
ffffffffc0203522:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203524:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203528:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020352c:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203530:	02053423          	sd	zero,40(a0)
    mm->mm_count = val;
ffffffffc0203534:	02052823          	sw	zero,48(a0)
    *lock = 0;
ffffffffc0203538:	02053c23          	sd	zero,56(a0)
ffffffffc020353c:	03200413          	li	s0,50
ffffffffc0203540:	a811                	j	ffffffffc0203554 <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc0203542:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203544:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203546:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc020354a:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020354c:	8526                	mv	a0,s1
ffffffffc020354e:	c81ff0ef          	jal	ra,ffffffffc02031ce <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0203552:	c80d                	beqz	s0,ffffffffc0203584 <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203554:	03000513          	li	a0,48
ffffffffc0203558:	9b6fe0ef          	jal	ra,ffffffffc020170e <kmalloc>
ffffffffc020355c:	85aa                	mv	a1,a0
ffffffffc020355e:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203562:	f165                	bnez	a0,ffffffffc0203542 <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc0203564:	00003697          	auipc	a3,0x3
ffffffffc0203568:	09c68693          	addi	a3,a3,156 # ffffffffc0206600 <default_pmm_manager+0xac8>
ffffffffc020356c:	00002617          	auipc	a2,0x2
ffffffffc0203570:	3cc60613          	addi	a2,a2,972 # ffffffffc0205938 <commands+0x620>
ffffffffc0203574:	12f00593          	li	a1,303
ffffffffc0203578:	00003517          	auipc	a0,0x3
ffffffffc020357c:	de050513          	addi	a0,a0,-544 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc0203580:	ecffc0ef          	jal	ra,ffffffffc020044e <__panic>
ffffffffc0203584:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203588:	1f900913          	li	s2,505
ffffffffc020358c:	a819                	j	ffffffffc02035a2 <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc020358e:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203590:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203592:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203596:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203598:	8526                	mv	a0,s1
ffffffffc020359a:	c35ff0ef          	jal	ra,ffffffffc02031ce <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc020359e:	03240a63          	beq	s0,s2,ffffffffc02035d2 <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02035a2:	03000513          	li	a0,48
ffffffffc02035a6:	968fe0ef          	jal	ra,ffffffffc020170e <kmalloc>
ffffffffc02035aa:	85aa                	mv	a1,a0
ffffffffc02035ac:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc02035b0:	fd79                	bnez	a0,ffffffffc020358e <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc02035b2:	00003697          	auipc	a3,0x3
ffffffffc02035b6:	04e68693          	addi	a3,a3,78 # ffffffffc0206600 <default_pmm_manager+0xac8>
ffffffffc02035ba:	00002617          	auipc	a2,0x2
ffffffffc02035be:	37e60613          	addi	a2,a2,894 # ffffffffc0205938 <commands+0x620>
ffffffffc02035c2:	13600593          	li	a1,310
ffffffffc02035c6:	00003517          	auipc	a0,0x3
ffffffffc02035ca:	d9250513          	addi	a0,a0,-622 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc02035ce:	e81fc0ef          	jal	ra,ffffffffc020044e <__panic>
    return listelm->next;
ffffffffc02035d2:	649c                	ld	a5,8(s1)
ffffffffc02035d4:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc02035d6:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc02035da:	16f48663          	beq	s1,a5,ffffffffc0203746 <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02035de:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd4e8b4>
ffffffffc02035e2:	ffe70693          	addi	a3,a4,-2
ffffffffc02035e6:	10d61063          	bne	a2,a3,ffffffffc02036e6 <vmm_init+0x1e4>
ffffffffc02035ea:	ff07b683          	ld	a3,-16(a5)
ffffffffc02035ee:	0ed71c63          	bne	a4,a3,ffffffffc02036e6 <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc02035f2:	0715                	addi	a4,a4,5
ffffffffc02035f4:	679c                	ld	a5,8(a5)
ffffffffc02035f6:	feb712e3          	bne	a4,a1,ffffffffc02035da <vmm_init+0xd8>
ffffffffc02035fa:	4a1d                	li	s4,7
ffffffffc02035fc:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc02035fe:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203602:	85a2                	mv	a1,s0
ffffffffc0203604:	8526                	mv	a0,s1
ffffffffc0203606:	b89ff0ef          	jal	ra,ffffffffc020318e <find_vma>
ffffffffc020360a:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc020360c:	16050d63          	beqz	a0,ffffffffc0203786 <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203610:	00140593          	addi	a1,s0,1
ffffffffc0203614:	8526                	mv	a0,s1
ffffffffc0203616:	b79ff0ef          	jal	ra,ffffffffc020318e <find_vma>
ffffffffc020361a:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020361c:	14050563          	beqz	a0,ffffffffc0203766 <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203620:	85d2                	mv	a1,s4
ffffffffc0203622:	8526                	mv	a0,s1
ffffffffc0203624:	b6bff0ef          	jal	ra,ffffffffc020318e <find_vma>
        assert(vma3 == NULL);
ffffffffc0203628:	16051f63          	bnez	a0,ffffffffc02037a6 <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc020362c:	00340593          	addi	a1,s0,3
ffffffffc0203630:	8526                	mv	a0,s1
ffffffffc0203632:	b5dff0ef          	jal	ra,ffffffffc020318e <find_vma>
        assert(vma4 == NULL);
ffffffffc0203636:	1a051863          	bnez	a0,ffffffffc02037e6 <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc020363a:	00440593          	addi	a1,s0,4
ffffffffc020363e:	8526                	mv	a0,s1
ffffffffc0203640:	b4fff0ef          	jal	ra,ffffffffc020318e <find_vma>
        assert(vma5 == NULL);
ffffffffc0203644:	18051163          	bnez	a0,ffffffffc02037c6 <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203648:	00893783          	ld	a5,8(s2)
ffffffffc020364c:	0a879d63          	bne	a5,s0,ffffffffc0203706 <vmm_init+0x204>
ffffffffc0203650:	01093783          	ld	a5,16(s2)
ffffffffc0203654:	0b479963          	bne	a5,s4,ffffffffc0203706 <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203658:	0089b783          	ld	a5,8(s3)
ffffffffc020365c:	0c879563          	bne	a5,s0,ffffffffc0203726 <vmm_init+0x224>
ffffffffc0203660:	0109b783          	ld	a5,16(s3)
ffffffffc0203664:	0d479163          	bne	a5,s4,ffffffffc0203726 <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203668:	0415                	addi	s0,s0,5
ffffffffc020366a:	0a15                	addi	s4,s4,5
ffffffffc020366c:	f9541be3          	bne	s0,s5,ffffffffc0203602 <vmm_init+0x100>
ffffffffc0203670:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203672:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203674:	85a2                	mv	a1,s0
ffffffffc0203676:	8526                	mv	a0,s1
ffffffffc0203678:	b17ff0ef          	jal	ra,ffffffffc020318e <find_vma>
ffffffffc020367c:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0203680:	c90d                	beqz	a0,ffffffffc02036b2 <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203682:	6914                	ld	a3,16(a0)
ffffffffc0203684:	6510                	ld	a2,8(a0)
ffffffffc0203686:	00003517          	auipc	a0,0x3
ffffffffc020368a:	f0250513          	addi	a0,a0,-254 # ffffffffc0206588 <default_pmm_manager+0xa50>
ffffffffc020368e:	b07fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203692:	00003697          	auipc	a3,0x3
ffffffffc0203696:	f1e68693          	addi	a3,a3,-226 # ffffffffc02065b0 <default_pmm_manager+0xa78>
ffffffffc020369a:	00002617          	auipc	a2,0x2
ffffffffc020369e:	29e60613          	addi	a2,a2,670 # ffffffffc0205938 <commands+0x620>
ffffffffc02036a2:	15c00593          	li	a1,348
ffffffffc02036a6:	00003517          	auipc	a0,0x3
ffffffffc02036aa:	cb250513          	addi	a0,a0,-846 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc02036ae:	da1fc0ef          	jal	ra,ffffffffc020044e <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc02036b2:	147d                	addi	s0,s0,-1
ffffffffc02036b4:	fd2410e3          	bne	s0,s2,ffffffffc0203674 <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc02036b8:	8526                	mv	a0,s1
ffffffffc02036ba:	be5ff0ef          	jal	ra,ffffffffc020329e <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02036be:	00003517          	auipc	a0,0x3
ffffffffc02036c2:	f0a50513          	addi	a0,a0,-246 # ffffffffc02065c8 <default_pmm_manager+0xa90>
ffffffffc02036c6:	acffc0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc02036ca:	7442                	ld	s0,48(sp)
ffffffffc02036cc:	70e2                	ld	ra,56(sp)
ffffffffc02036ce:	74a2                	ld	s1,40(sp)
ffffffffc02036d0:	7902                	ld	s2,32(sp)
ffffffffc02036d2:	69e2                	ld	s3,24(sp)
ffffffffc02036d4:	6a42                	ld	s4,16(sp)
ffffffffc02036d6:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02036d8:	00003517          	auipc	a0,0x3
ffffffffc02036dc:	f1050513          	addi	a0,a0,-240 # ffffffffc02065e8 <default_pmm_manager+0xab0>
}
ffffffffc02036e0:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02036e2:	ab3fc06f          	j	ffffffffc0200194 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02036e6:	00003697          	auipc	a3,0x3
ffffffffc02036ea:	dba68693          	addi	a3,a3,-582 # ffffffffc02064a0 <default_pmm_manager+0x968>
ffffffffc02036ee:	00002617          	auipc	a2,0x2
ffffffffc02036f2:	24a60613          	addi	a2,a2,586 # ffffffffc0205938 <commands+0x620>
ffffffffc02036f6:	14000593          	li	a1,320
ffffffffc02036fa:	00003517          	auipc	a0,0x3
ffffffffc02036fe:	c5e50513          	addi	a0,a0,-930 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc0203702:	d4dfc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203706:	00003697          	auipc	a3,0x3
ffffffffc020370a:	e2268693          	addi	a3,a3,-478 # ffffffffc0206528 <default_pmm_manager+0x9f0>
ffffffffc020370e:	00002617          	auipc	a2,0x2
ffffffffc0203712:	22a60613          	addi	a2,a2,554 # ffffffffc0205938 <commands+0x620>
ffffffffc0203716:	15100593          	li	a1,337
ffffffffc020371a:	00003517          	auipc	a0,0x3
ffffffffc020371e:	c3e50513          	addi	a0,a0,-962 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc0203722:	d2dfc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203726:	00003697          	auipc	a3,0x3
ffffffffc020372a:	e3268693          	addi	a3,a3,-462 # ffffffffc0206558 <default_pmm_manager+0xa20>
ffffffffc020372e:	00002617          	auipc	a2,0x2
ffffffffc0203732:	20a60613          	addi	a2,a2,522 # ffffffffc0205938 <commands+0x620>
ffffffffc0203736:	15200593          	li	a1,338
ffffffffc020373a:	00003517          	auipc	a0,0x3
ffffffffc020373e:	c1e50513          	addi	a0,a0,-994 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc0203742:	d0dfc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203746:	00003697          	auipc	a3,0x3
ffffffffc020374a:	d4268693          	addi	a3,a3,-702 # ffffffffc0206488 <default_pmm_manager+0x950>
ffffffffc020374e:	00002617          	auipc	a2,0x2
ffffffffc0203752:	1ea60613          	addi	a2,a2,490 # ffffffffc0205938 <commands+0x620>
ffffffffc0203756:	13e00593          	li	a1,318
ffffffffc020375a:	00003517          	auipc	a0,0x3
ffffffffc020375e:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc0203762:	cedfc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(vma2 != NULL);
ffffffffc0203766:	00003697          	auipc	a3,0x3
ffffffffc020376a:	d8268693          	addi	a3,a3,-638 # ffffffffc02064e8 <default_pmm_manager+0x9b0>
ffffffffc020376e:	00002617          	auipc	a2,0x2
ffffffffc0203772:	1ca60613          	addi	a2,a2,458 # ffffffffc0205938 <commands+0x620>
ffffffffc0203776:	14900593          	li	a1,329
ffffffffc020377a:	00003517          	auipc	a0,0x3
ffffffffc020377e:	bde50513          	addi	a0,a0,-1058 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc0203782:	ccdfc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(vma1 != NULL);
ffffffffc0203786:	00003697          	auipc	a3,0x3
ffffffffc020378a:	d5268693          	addi	a3,a3,-686 # ffffffffc02064d8 <default_pmm_manager+0x9a0>
ffffffffc020378e:	00002617          	auipc	a2,0x2
ffffffffc0203792:	1aa60613          	addi	a2,a2,426 # ffffffffc0205938 <commands+0x620>
ffffffffc0203796:	14700593          	li	a1,327
ffffffffc020379a:	00003517          	auipc	a0,0x3
ffffffffc020379e:	bbe50513          	addi	a0,a0,-1090 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc02037a2:	cadfc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(vma3 == NULL);
ffffffffc02037a6:	00003697          	auipc	a3,0x3
ffffffffc02037aa:	d5268693          	addi	a3,a3,-686 # ffffffffc02064f8 <default_pmm_manager+0x9c0>
ffffffffc02037ae:	00002617          	auipc	a2,0x2
ffffffffc02037b2:	18a60613          	addi	a2,a2,394 # ffffffffc0205938 <commands+0x620>
ffffffffc02037b6:	14b00593          	li	a1,331
ffffffffc02037ba:	00003517          	auipc	a0,0x3
ffffffffc02037be:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc02037c2:	c8dfc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(vma5 == NULL);
ffffffffc02037c6:	00003697          	auipc	a3,0x3
ffffffffc02037ca:	d5268693          	addi	a3,a3,-686 # ffffffffc0206518 <default_pmm_manager+0x9e0>
ffffffffc02037ce:	00002617          	auipc	a2,0x2
ffffffffc02037d2:	16a60613          	addi	a2,a2,362 # ffffffffc0205938 <commands+0x620>
ffffffffc02037d6:	14f00593          	li	a1,335
ffffffffc02037da:	00003517          	auipc	a0,0x3
ffffffffc02037de:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc02037e2:	c6dfc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(vma4 == NULL);
ffffffffc02037e6:	00003697          	auipc	a3,0x3
ffffffffc02037ea:	d2268693          	addi	a3,a3,-734 # ffffffffc0206508 <default_pmm_manager+0x9d0>
ffffffffc02037ee:	00002617          	auipc	a2,0x2
ffffffffc02037f2:	14a60613          	addi	a2,a2,330 # ffffffffc0205938 <commands+0x620>
ffffffffc02037f6:	14d00593          	li	a1,333
ffffffffc02037fa:	00003517          	auipc	a0,0x3
ffffffffc02037fe:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc0203802:	c4dfc0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(mm != NULL);
ffffffffc0203806:	00003697          	auipc	a3,0x3
ffffffffc020380a:	bda68693          	addi	a3,a3,-1062 # ffffffffc02063e0 <default_pmm_manager+0x8a8>
ffffffffc020380e:	00002617          	auipc	a2,0x2
ffffffffc0203812:	12a60613          	addi	a2,a2,298 # ffffffffc0205938 <commands+0x620>
ffffffffc0203816:	12700593          	li	a1,295
ffffffffc020381a:	00003517          	auipc	a0,0x3
ffffffffc020381e:	b3e50513          	addi	a0,a0,-1218 # ffffffffc0206358 <default_pmm_manager+0x820>
ffffffffc0203822:	c2dfc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0203826 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203826:	7179                	addi	sp,sp,-48
ffffffffc0203828:	f022                	sd	s0,32(sp)
ffffffffc020382a:	f406                	sd	ra,40(sp)
ffffffffc020382c:	ec26                	sd	s1,24(sp)
ffffffffc020382e:	e84a                	sd	s2,16(sp)
ffffffffc0203830:	e44e                	sd	s3,8(sp)
ffffffffc0203832:	e052                	sd	s4,0(sp)
ffffffffc0203834:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203836:	c135                	beqz	a0,ffffffffc020389a <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203838:	002007b7          	lui	a5,0x200
ffffffffc020383c:	04f5e663          	bltu	a1,a5,ffffffffc0203888 <user_mem_check+0x62>
ffffffffc0203840:	00c584b3          	add	s1,a1,a2
ffffffffc0203844:	0495f263          	bgeu	a1,s1,ffffffffc0203888 <user_mem_check+0x62>
ffffffffc0203848:	4785                	li	a5,1
ffffffffc020384a:	07fe                	slli	a5,a5,0x1f
ffffffffc020384c:	0297ee63          	bltu	a5,s1,ffffffffc0203888 <user_mem_check+0x62>
ffffffffc0203850:	892a                	mv	s2,a0
ffffffffc0203852:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203854:	6a05                	lui	s4,0x1
ffffffffc0203856:	a821                	j	ffffffffc020386e <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203858:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc020385c:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc020385e:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203860:	c685                	beqz	a3,ffffffffc0203888 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203862:	c399                	beqz	a5,ffffffffc0203868 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203864:	02e46263          	bltu	s0,a4,ffffffffc0203888 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203868:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc020386a:	04947663          	bgeu	s0,s1,ffffffffc02038b6 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc020386e:	85a2                	mv	a1,s0
ffffffffc0203870:	854a                	mv	a0,s2
ffffffffc0203872:	91dff0ef          	jal	ra,ffffffffc020318e <find_vma>
ffffffffc0203876:	c909                	beqz	a0,ffffffffc0203888 <user_mem_check+0x62>
ffffffffc0203878:	6518                	ld	a4,8(a0)
ffffffffc020387a:	00e46763          	bltu	s0,a4,ffffffffc0203888 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc020387e:	4d1c                	lw	a5,24(a0)
ffffffffc0203880:	fc099ce3          	bnez	s3,ffffffffc0203858 <user_mem_check+0x32>
ffffffffc0203884:	8b85                	andi	a5,a5,1
ffffffffc0203886:	f3ed                	bnez	a5,ffffffffc0203868 <user_mem_check+0x42>
            return 0;
ffffffffc0203888:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
ffffffffc020388a:	70a2                	ld	ra,40(sp)
ffffffffc020388c:	7402                	ld	s0,32(sp)
ffffffffc020388e:	64e2                	ld	s1,24(sp)
ffffffffc0203890:	6942                	ld	s2,16(sp)
ffffffffc0203892:	69a2                	ld	s3,8(sp)
ffffffffc0203894:	6a02                	ld	s4,0(sp)
ffffffffc0203896:	6145                	addi	sp,sp,48
ffffffffc0203898:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc020389a:	c02007b7          	lui	a5,0xc0200
ffffffffc020389e:	4501                	li	a0,0
ffffffffc02038a0:	fef5e5e3          	bltu	a1,a5,ffffffffc020388a <user_mem_check+0x64>
ffffffffc02038a4:	962e                	add	a2,a2,a1
ffffffffc02038a6:	fec5f2e3          	bgeu	a1,a2,ffffffffc020388a <user_mem_check+0x64>
ffffffffc02038aa:	c8000537          	lui	a0,0xc8000
ffffffffc02038ae:	0505                	addi	a0,a0,1
ffffffffc02038b0:	00a63533          	sltu	a0,a2,a0
ffffffffc02038b4:	bfd9                	j	ffffffffc020388a <user_mem_check+0x64>
        return 1;
ffffffffc02038b6:	4505                	li	a0,1
ffffffffc02038b8:	bfc9                	j	ffffffffc020388a <user_mem_check+0x64>

ffffffffc02038ba <copy_to_user>:
{
ffffffffc02038ba:	1101                	addi	sp,sp,-32
ffffffffc02038bc:	e822                	sd	s0,16(sp)
ffffffffc02038be:	8436                	mv	s0,a3
ffffffffc02038c0:	e04a                	sd	s2,0(sp)
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1))
ffffffffc02038c2:	4685                	li	a3,1
{
ffffffffc02038c4:	8932                	mv	s2,a2
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1))
ffffffffc02038c6:	8622                	mv	a2,s0
{
ffffffffc02038c8:	e426                	sd	s1,8(sp)
ffffffffc02038ca:	ec06                	sd	ra,24(sp)
ffffffffc02038cc:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1))
ffffffffc02038ce:	f59ff0ef          	jal	ra,ffffffffc0203826 <user_mem_check>
ffffffffc02038d2:	c519                	beqz	a0,ffffffffc02038e0 <copy_to_user+0x26>
    memcpy(dst, src, len);
ffffffffc02038d4:	8622                	mv	a2,s0
ffffffffc02038d6:	85ca                	mv	a1,s2
ffffffffc02038d8:	8526                	mv	a0,s1
ffffffffc02038da:	7ba010ef          	jal	ra,ffffffffc0205094 <memcpy>
    return 1;
ffffffffc02038de:	4505                	li	a0,1
}
ffffffffc02038e0:	60e2                	ld	ra,24(sp)
ffffffffc02038e2:	6442                	ld	s0,16(sp)
ffffffffc02038e4:	64a2                	ld	s1,8(sp)
ffffffffc02038e6:	6902                	ld	s2,0(sp)
ffffffffc02038e8:	6105                	addi	sp,sp,32
ffffffffc02038ea:	8082                	ret

ffffffffc02038ec <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc02038ec:	8526                	mv	a0,s1
	jalr s0
ffffffffc02038ee:	9402                	jalr	s0

	jal do_exit
ffffffffc02038f0:	59e000ef          	jal	ra,ffffffffc0203e8e <do_exit>

ffffffffc02038f4 <alloc_proc>:
void switch_to(struct context *from, struct context *to);


static void forkret(void);

static struct proc_struct *alloc_proc(void) {
ffffffffc02038f4:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02038f6:	10800513          	li	a0,264
static struct proc_struct *alloc_proc(void) {
ffffffffc02038fa:	e022                	sd	s0,0(sp)
ffffffffc02038fc:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02038fe:	e11fd0ef          	jal	ra,ffffffffc020170e <kmalloc>
ffffffffc0203902:	842a                	mv	s0,a0
    if (proc == NULL) return NULL;
ffffffffc0203904:	c515                	beqz	a0,ffffffffc0203930 <alloc_proc+0x3c>
    memset(proc, 0, sizeof(*proc));
ffffffffc0203906:	10800613          	li	a2,264
ffffffffc020390a:	4581                	li	a1,0
ffffffffc020390c:	776010ef          	jal	ra,ffffffffc0205082 <memset>
    proc->state = PROC_UNINIT;
ffffffffc0203910:	57fd                	li	a5,-1
ffffffffc0203912:	1782                	slli	a5,a5,0x20
ffffffffc0203914:	e01c                	sd	a5,0(s0)
    proc->pid = -1;
    proc->pgdir = boot_pgdir_pa;
    list_init(&proc->list_link);
ffffffffc0203916:	0c840713          	addi	a4,s0,200
    list_init(&proc->hash_link);
ffffffffc020391a:	0d840793          	addi	a5,s0,216
    proc->pgdir = boot_pgdir_pa;
ffffffffc020391e:	000ad697          	auipc	a3,0xad
ffffffffc0203922:	dca6b683          	ld	a3,-566(a3) # ffffffffc02b06e8 <boot_pgdir_pa>
ffffffffc0203926:	f454                	sd	a3,168(s0)
    elm->prev = elm->next = elm;
ffffffffc0203928:	e878                	sd	a4,208(s0)
ffffffffc020392a:	e478                	sd	a4,200(s0)
ffffffffc020392c:	f07c                	sd	a5,224(s0)
ffffffffc020392e:	ec7c                	sd	a5,216(s0)
    return proc;
}
ffffffffc0203930:	60a2                	ld	ra,8(sp)
ffffffffc0203932:	8522                	mv	a0,s0
ffffffffc0203934:	6402                	ld	s0,0(sp)
ffffffffc0203936:	0141                	addi	sp,sp,16
ffffffffc0203938:	8082                	ret

ffffffffc020393a <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc020393a:	000ad797          	auipc	a5,0xad
ffffffffc020393e:	dde7b783          	ld	a5,-546(a5) # ffffffffc02b0718 <current>
ffffffffc0203942:	73c8                	ld	a0,160(a5)
ffffffffc0203944:	cc4fd06f          	j	ffffffffc0200e08 <forkrets>

ffffffffc0203948 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0203948:	6d14                	ld	a3,24(a0)
}

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm)
{
ffffffffc020394a:	1141                	addi	sp,sp,-16
ffffffffc020394c:	e406                	sd	ra,8(sp)
ffffffffc020394e:	c02007b7          	lui	a5,0xc0200
ffffffffc0203952:	02f6ee63          	bltu	a3,a5,ffffffffc020398e <put_pgdir+0x46>
ffffffffc0203956:	000ad517          	auipc	a0,0xad
ffffffffc020395a:	dba53503          	ld	a0,-582(a0) # ffffffffc02b0710 <va_pa_offset>
ffffffffc020395e:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc0203960:	82b1                	srli	a3,a3,0xc
ffffffffc0203962:	000ad797          	auipc	a5,0xad
ffffffffc0203966:	d967b783          	ld	a5,-618(a5) # ffffffffc02b06f8 <npage>
ffffffffc020396a:	02f6fe63          	bgeu	a3,a5,ffffffffc02039a6 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020396e:	00003517          	auipc	a0,0x3
ffffffffc0203972:	61253503          	ld	a0,1554(a0) # ffffffffc0206f80 <nbase>
    free_page(kva2page(mm->pgdir));
}
ffffffffc0203976:	60a2                	ld	ra,8(sp)
ffffffffc0203978:	8e89                	sub	a3,a3,a0
ffffffffc020397a:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc020397c:	000ad517          	auipc	a0,0xad
ffffffffc0203980:	d8453503          	ld	a0,-636(a0) # ffffffffc02b0700 <pages>
ffffffffc0203984:	4585                	li	a1,1
ffffffffc0203986:	9536                	add	a0,a0,a3
}
ffffffffc0203988:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc020398a:	fa1fd06f          	j	ffffffffc020192a <free_pages>
    return pa2page(PADDR(kva));
ffffffffc020398e:	00002617          	auipc	a2,0x2
ffffffffc0203992:	28a60613          	addi	a2,a2,650 # ffffffffc0205c18 <default_pmm_manager+0xe0>
ffffffffc0203996:	07700593          	li	a1,119
ffffffffc020399a:	00002517          	auipc	a0,0x2
ffffffffc020399e:	1fe50513          	addi	a0,a0,510 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc02039a2:	aadfc0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02039a6:	00002617          	auipc	a2,0x2
ffffffffc02039aa:	29a60613          	addi	a2,a2,666 # ffffffffc0205c40 <default_pmm_manager+0x108>
ffffffffc02039ae:	06900593          	li	a1,105
ffffffffc02039b2:	00002517          	auipc	a0,0x2
ffffffffc02039b6:	1e650513          	addi	a0,a0,486 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc02039ba:	a95fc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02039be <do_fork>:
    return 0;
}

// do_fork - create a child process, copying or sharing its address space.
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
ffffffffc02039be:	7159                	addi	sp,sp,-112
ffffffffc02039c0:	eca6                	sd	s1,88(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc02039c2:	000ad497          	auipc	s1,0xad
ffffffffc02039c6:	d6e48493          	addi	s1,s1,-658 # ffffffffc02b0730 <nr_process>
ffffffffc02039ca:	4098                	lw	a4,0(s1)
{
ffffffffc02039cc:	f486                	sd	ra,104(sp)
ffffffffc02039ce:	f0a2                	sd	s0,96(sp)
ffffffffc02039d0:	e8ca                	sd	s2,80(sp)
ffffffffc02039d2:	e4ce                	sd	s3,72(sp)
ffffffffc02039d4:	e0d2                	sd	s4,64(sp)
ffffffffc02039d6:	fc56                	sd	s5,56(sp)
ffffffffc02039d8:	f85a                	sd	s6,48(sp)
ffffffffc02039da:	f45e                	sd	s7,40(sp)
ffffffffc02039dc:	f062                	sd	s8,32(sp)
ffffffffc02039de:	ec66                	sd	s9,24(sp)
ffffffffc02039e0:	e86a                	sd	s10,16(sp)
ffffffffc02039e2:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc02039e4:	6785                	lui	a5,0x1
ffffffffc02039e6:	34f75263          	bge	a4,a5,ffffffffc0203d2a <do_fork+0x36c>
    {
        return -E_NO_FREE_PROC;
    }
    if (current == NULL || tf == NULL)
ffffffffc02039ea:	000ada17          	auipc	s4,0xad
ffffffffc02039ee:	d2ea0a13          	addi	s4,s4,-722 # ffffffffc02b0718 <current>
ffffffffc02039f2:	000a3783          	ld	a5,0(s4)
ffffffffc02039f6:	32078863          	beqz	a5,ffffffffc0203d26 <do_fork+0x368>
ffffffffc02039fa:	8432                	mv	s0,a2
ffffffffc02039fc:	32060563          	beqz	a2,ffffffffc0203d26 <do_fork+0x368>
ffffffffc0203a00:	892a                	mv	s2,a0
ffffffffc0203a02:	89ae                	mv	s3,a1
    {
        return -E_INVAL;
    }

    int ret;
    struct proc_struct *proc = alloc_proc();
ffffffffc0203a04:	ef1ff0ef          	jal	ra,ffffffffc02038f4 <alloc_proc>
ffffffffc0203a08:	8aaa                	mv	s5,a0
    if (proc == NULL)
ffffffffc0203a0a:	32050263          	beqz	a0,ffffffffc0203d2e <do_fork+0x370>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0203a0e:	4509                	li	a0,2
ffffffffc0203a10:	eddfd0ef          	jal	ra,ffffffffc02018ec <alloc_pages>
    if (page != NULL)
ffffffffc0203a14:	2a050163          	beqz	a0,ffffffffc0203cb6 <do_fork+0x2f8>
    return page - pages + nbase;
ffffffffc0203a18:	000adb97          	auipc	s7,0xad
ffffffffc0203a1c:	ce8b8b93          	addi	s7,s7,-792 # ffffffffc02b0700 <pages>
ffffffffc0203a20:	000bb683          	ld	a3,0(s7)
ffffffffc0203a24:	00003b17          	auipc	s6,0x3
ffffffffc0203a28:	55cb3b03          	ld	s6,1372(s6) # ffffffffc0206f80 <nbase>
    return KADDR(page2pa(page));
ffffffffc0203a2c:	000adc17          	auipc	s8,0xad
ffffffffc0203a30:	cccc0c13          	addi	s8,s8,-820 # ffffffffc02b06f8 <npage>
    return page - pages + nbase;
ffffffffc0203a34:	40d506b3          	sub	a3,a0,a3
ffffffffc0203a38:	8699                	srai	a3,a3,0x6
ffffffffc0203a3a:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc0203a3c:	000c3703          	ld	a4,0(s8)
ffffffffc0203a40:	00c69793          	slli	a5,a3,0xc
ffffffffc0203a44:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203a46:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203a48:	2ee7fc63          	bgeu	a5,a4,ffffffffc0203d40 <do_fork+0x382>
    struct mm_struct *oldmm = current->mm;
ffffffffc0203a4c:	000a3783          	ld	a5,0(s4)
ffffffffc0203a50:	000add17          	auipc	s10,0xad
ffffffffc0203a54:	cc0d0d13          	addi	s10,s10,-832 # ffffffffc02b0710 <va_pa_offset>
ffffffffc0203a58:	000d3703          	ld	a4,0(s10)
ffffffffc0203a5c:	0287bc83          	ld	s9,40(a5) # 1028 <_binary_obj___user_faultread_out_size-0x92c8>
ffffffffc0203a60:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0203a62:	00dab823          	sd	a3,16(s5)
    if (oldmm == NULL)
ffffffffc0203a66:	280c8763          	beqz	s9,ffffffffc0203cf4 <do_fork+0x336>
    if (clone_flags & CLONE_VM)
ffffffffc0203a6a:	10097913          	andi	s2,s2,256
ffffffffc0203a6e:	12090963          	beqz	s2,ffffffffc0203ba0 <do_fork+0x1e2>
    mm->mm_count += 1;
ffffffffc0203a72:	030ca703          	lw	a4,48(s9)
        proc->pgdir = current->pgdir;
ffffffffc0203a76:	77d0                	ld	a2,168(a5)
ffffffffc0203a78:	2705                	addiw	a4,a4,1
ffffffffc0203a7a:	02eca823          	sw	a4,48(s9)
        proc->mm = oldmm;
ffffffffc0203a7e:	039ab423          	sd	s9,40(s5)
        proc->pgdir = current->pgdir;
ffffffffc0203a82:	0acab423          	sd	a2,168(s5)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203a86:	6709                	lui	a4,0x2
ffffffffc0203a88:	ee070713          	addi	a4,a4,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x8410>
ffffffffc0203a8c:	96ba                	add	a3,a3,a4
        put_kstack(proc);
        kfree(proc);
        return ret;
    }

    proc->parent = current;
ffffffffc0203a8e:	02fab023          	sd	a5,32(s5)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203a92:	0adab023          	sd	a3,160(s5)
    *(proc->tf) = *tf;
ffffffffc0203a96:	87b6                	mv	a5,a3
ffffffffc0203a98:	12040813          	addi	a6,s0,288
ffffffffc0203a9c:	6008                	ld	a0,0(s0)
ffffffffc0203a9e:	640c                	ld	a1,8(s0)
ffffffffc0203aa0:	6810                	ld	a2,16(s0)
ffffffffc0203aa2:	6c18                	ld	a4,24(s0)
ffffffffc0203aa4:	e388                	sd	a0,0(a5)
ffffffffc0203aa6:	e78c                	sd	a1,8(a5)
ffffffffc0203aa8:	eb90                	sd	a2,16(a5)
ffffffffc0203aaa:	ef98                	sd	a4,24(a5)
ffffffffc0203aac:	02040413          	addi	s0,s0,32
ffffffffc0203ab0:	02078793          	addi	a5,a5,32
ffffffffc0203ab4:	ff0414e3          	bne	s0,a6,ffffffffc0203a9c <do_fork+0xde>
    proc->tf->gpr.a0 = 0;
ffffffffc0203ab8:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp != 0) ? esp : (uintptr_t)proc->tf;
ffffffffc0203abc:	00099363          	bnez	s3,ffffffffc0203ac2 <do_fork+0x104>
ffffffffc0203ac0:	89b6                	mv	s3,a3
    if (++last_pid >= MAX_PID)
ffffffffc0203ac2:	000a8817          	auipc	a6,0xa8
ffffffffc0203ac6:	7c680813          	addi	a6,a6,1990 # ffffffffc02ac288 <last_pid.1>
ffffffffc0203aca:	00082783          	lw	a5,0(a6)
    proc->tf->gpr.sp = (esp != 0) ? esp : (uintptr_t)proc->tf;
ffffffffc0203ace:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203ad2:	00000717          	auipc	a4,0x0
ffffffffc0203ad6:	e6870713          	addi	a4,a4,-408 # ffffffffc020393a <forkret>
    if (++last_pid >= MAX_PID)
ffffffffc0203ada:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203ade:	02eab823          	sd	a4,48(s5)
    proc->context.sp = (uintptr_t)proc->tf;
ffffffffc0203ae2:	02dabc23          	sd	a3,56(s5)
    if (++last_pid >= MAX_PID)
ffffffffc0203ae6:	00a82023          	sw	a0,0(a6)
ffffffffc0203aea:	6789                	lui	a5,0x2
ffffffffc0203aec:	14f55e63          	bge	a0,a5,ffffffffc0203c48 <do_fork+0x28a>
    if (last_pid >= next_safe)
ffffffffc0203af0:	000a8317          	auipc	t1,0xa8
ffffffffc0203af4:	79c30313          	addi	t1,t1,1948 # ffffffffc02ac28c <next_safe.0>
ffffffffc0203af8:	00032783          	lw	a5,0(t1)
ffffffffc0203afc:	000ad417          	auipc	s0,0xad
ffffffffc0203b00:	bac40413          	addi	s0,s0,-1108 # ffffffffc02b06a8 <proc_list>
ffffffffc0203b04:	14f55a63          	bge	a0,a5,ffffffffc0203c58 <do_fork+0x29a>
    copy_thread(proc, stack, tf);
    proc->pid = get_pid();
ffffffffc0203b08:	00aaa223          	sw	a0,4(s5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203b0c:	100027f3          	csrr	a5,sstatus
ffffffffc0203b10:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203b12:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203b14:	1e079e63          	bnez	a5,ffffffffc0203d10 <do_fork+0x352>
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0203b18:	45a9                	li	a1,10
ffffffffc0203b1a:	2501                	sext.w	a0,a0
ffffffffc0203b1c:	0c0010ef          	jal	ra,ffffffffc0204bdc <hash32>
ffffffffc0203b20:	02051793          	slli	a5,a0,0x20
ffffffffc0203b24:	000a9717          	auipc	a4,0xa9
ffffffffc0203b28:	b8470713          	addi	a4,a4,-1148 # ffffffffc02ac6a8 <hash_list>
ffffffffc0203b2c:	83f1                	srli	a5,a5,0x1c
ffffffffc0203b2e:	97ba                	add	a5,a5,a4
    __list_add(elm, listelm, listelm->next);
ffffffffc0203b30:	6788                	ld	a0,8(a5)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0203b32:	020ab603          	ld	a2,32(s5)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0203b36:	0d8a8713          	addi	a4,s5,216
    prev->next = next->prev = elm;
ffffffffc0203b3a:	e118                	sd	a4,0(a0)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203b3c:	640c                	ld	a1,8(s0)
    prev->next = next->prev = elm;
ffffffffc0203b3e:	e798                	sd	a4,8(a5)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0203b40:	7a74                	ld	a3,240(a2)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0203b42:	0c8a8713          	addi	a4,s5,200
    elm->next = next;
ffffffffc0203b46:	0eaab023          	sd	a0,224(s5)
    elm->prev = prev;
ffffffffc0203b4a:	0cfabc23          	sd	a5,216(s5)
    prev->next = next->prev = elm;
ffffffffc0203b4e:	e198                	sd	a4,0(a1)
ffffffffc0203b50:	e418                	sd	a4,8(s0)
    elm->next = next;
ffffffffc0203b52:	0cbab823          	sd	a1,208(s5)
    elm->prev = prev;
ffffffffc0203b56:	0c8ab423          	sd	s0,200(s5)
    proc->yptr = NULL;
ffffffffc0203b5a:	0e0abc23          	sd	zero,248(s5)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0203b5e:	10dab023          	sd	a3,256(s5)
ffffffffc0203b62:	c299                	beqz	a3,ffffffffc0203b68 <do_fork+0x1aa>
        proc->optr->yptr = proc;
ffffffffc0203b64:	0f56bc23          	sd	s5,248(a3)
    nr_process++;
ffffffffc0203b68:	409c                	lw	a5,0(s1)
    proc->parent->cptr = proc;
ffffffffc0203b6a:	0f563823          	sd	s5,240(a2)
    nr_process++;
ffffffffc0203b6e:	2785                	addiw	a5,a5,1
ffffffffc0203b70:	c09c                	sw	a5,0(s1)
    if (flag)
ffffffffc0203b72:	16091e63          	bnez	s2,ffffffffc0203cee <do_fork+0x330>
    local_intr_save(intr_flag);
    hash_proc(proc);
    set_links(proc);
    local_intr_restore(intr_flag);

    wakeup_proc(proc);
ffffffffc0203b76:	8556                	mv	a0,s5
ffffffffc0203b78:	69f000ef          	jal	ra,ffffffffc0204a16 <wakeup_proc>
    return proc->pid;
ffffffffc0203b7c:	004aa903          	lw	s2,4(s5)
}
ffffffffc0203b80:	70a6                	ld	ra,104(sp)
ffffffffc0203b82:	7406                	ld	s0,96(sp)
ffffffffc0203b84:	64e6                	ld	s1,88(sp)
ffffffffc0203b86:	69a6                	ld	s3,72(sp)
ffffffffc0203b88:	6a06                	ld	s4,64(sp)
ffffffffc0203b8a:	7ae2                	ld	s5,56(sp)
ffffffffc0203b8c:	7b42                	ld	s6,48(sp)
ffffffffc0203b8e:	7ba2                	ld	s7,40(sp)
ffffffffc0203b90:	7c02                	ld	s8,32(sp)
ffffffffc0203b92:	6ce2                	ld	s9,24(sp)
ffffffffc0203b94:	6d42                	ld	s10,16(sp)
ffffffffc0203b96:	6da2                	ld	s11,8(sp)
ffffffffc0203b98:	854a                	mv	a0,s2
ffffffffc0203b9a:	6946                	ld	s2,80(sp)
ffffffffc0203b9c:	6165                	addi	sp,sp,112
ffffffffc0203b9e:	8082                	ret
    struct mm_struct *mm = mm_create();
ffffffffc0203ba0:	dbeff0ef          	jal	ra,ffffffffc020315e <mm_create>
ffffffffc0203ba4:	8daa                	mv	s11,a0
    if (mm == NULL)
ffffffffc0203ba6:	18050963          	beqz	a0,ffffffffc0203d38 <do_fork+0x37a>
    if ((page = alloc_page()) == NULL)
ffffffffc0203baa:	4505                	li	a0,1
ffffffffc0203bac:	d41fd0ef          	jal	ra,ffffffffc02018ec <alloc_pages>
ffffffffc0203bb0:	18050663          	beqz	a0,ffffffffc0203d3c <do_fork+0x37e>
    return page - pages + nbase;
ffffffffc0203bb4:	000bb683          	ld	a3,0(s7)
    return KADDR(page2pa(page));
ffffffffc0203bb8:	000c3703          	ld	a4,0(s8)
    return page - pages + nbase;
ffffffffc0203bbc:	40d506b3          	sub	a3,a0,a3
ffffffffc0203bc0:	8699                	srai	a3,a3,0x6
ffffffffc0203bc2:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc0203bc4:	00c69793          	slli	a5,a3,0xc
ffffffffc0203bc8:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203bca:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203bcc:	16e7fa63          	bgeu	a5,a4,ffffffffc0203d40 <do_fork+0x382>
ffffffffc0203bd0:	000d3903          	ld	s2,0(s10)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0203bd4:	6605                	lui	a2,0x1
ffffffffc0203bd6:	000ad597          	auipc	a1,0xad
ffffffffc0203bda:	b1a5b583          	ld	a1,-1254(a1) # ffffffffc02b06f0 <boot_pgdir_va>
ffffffffc0203bde:	9936                	add	s2,s2,a3
ffffffffc0203be0:	854a                	mv	a0,s2
ffffffffc0203be2:	4b2010ef          	jal	ra,ffffffffc0205094 <memcpy>
        ret = dup_mmap(mm, oldmm);
ffffffffc0203be6:	85e6                	mv	a1,s9
    mm->pgdir = pgdir;
ffffffffc0203be8:	012dbc23          	sd	s2,24(s11)
        ret = dup_mmap(mm, oldmm);
ffffffffc0203bec:	856e                	mv	a0,s11
ffffffffc0203bee:	fb2ff0ef          	jal	ra,ffffffffc02033a0 <dup_mmap>
ffffffffc0203bf2:	892a                	mv	s2,a0
    if (ret != 0)
ffffffffc0203bf4:	c571                	beqz	a0,ffffffffc0203cc0 <do_fork+0x302>
        if (mm->pgdir != NULL)
ffffffffc0203bf6:	018db783          	ld	a5,24(s11)
    mm->mm_count = val;
ffffffffc0203bfa:	020da823          	sw	zero,48(s11)
ffffffffc0203bfe:	c799                	beqz	a5,ffffffffc0203c0c <do_fork+0x24e>
            exit_mmap(mm);
ffffffffc0203c00:	856e                	mv	a0,s11
ffffffffc0203c02:	88bff0ef          	jal	ra,ffffffffc020348c <exit_mmap>
            put_pgdir(mm);
ffffffffc0203c06:	856e                	mv	a0,s11
ffffffffc0203c08:	d41ff0ef          	jal	ra,ffffffffc0203948 <put_pgdir>
        mm_destroy(mm);
ffffffffc0203c0c:	856e                	mv	a0,s11
ffffffffc0203c0e:	e90ff0ef          	jal	ra,ffffffffc020329e <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0203c12:	010ab683          	ld	a3,16(s5)
    return pa2page(PADDR(kva));
ffffffffc0203c16:	c02007b7          	lui	a5,0xc0200
ffffffffc0203c1a:	14f6eb63          	bltu	a3,a5,ffffffffc0203d70 <do_fork+0x3b2>
ffffffffc0203c1e:	000d3703          	ld	a4,0(s10)
    if (PPN(pa) >= npage)
ffffffffc0203c22:	000c3783          	ld	a5,0(s8)
    return pa2page(PADDR(kva));
ffffffffc0203c26:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc0203c28:	82b1                	srli	a3,a3,0xc
ffffffffc0203c2a:	12f6f763          	bgeu	a3,a5,ffffffffc0203d58 <do_fork+0x39a>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c2e:	000bb503          	ld	a0,0(s7)
ffffffffc0203c32:	416686b3          	sub	a3,a3,s6
ffffffffc0203c36:	069a                	slli	a3,a3,0x6
ffffffffc0203c38:	9536                	add	a0,a0,a3
ffffffffc0203c3a:	4589                	li	a1,2
ffffffffc0203c3c:	ceffd0ef          	jal	ra,ffffffffc020192a <free_pages>
        kfree(proc);
ffffffffc0203c40:	8556                	mv	a0,s5
ffffffffc0203c42:	b7dfd0ef          	jal	ra,ffffffffc02017be <kfree>
        return ret;
ffffffffc0203c46:	bf2d                	j	ffffffffc0203b80 <do_fork+0x1c2>
        last_pid = 1;
ffffffffc0203c48:	4785                	li	a5,1
ffffffffc0203c4a:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0203c4e:	4505                	li	a0,1
ffffffffc0203c50:	000a8317          	auipc	t1,0xa8
ffffffffc0203c54:	63c30313          	addi	t1,t1,1596 # ffffffffc02ac28c <next_safe.0>
    return listelm->next;
ffffffffc0203c58:	000ad417          	auipc	s0,0xad
ffffffffc0203c5c:	a5040413          	addi	s0,s0,-1456 # ffffffffc02b06a8 <proc_list>
ffffffffc0203c60:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc0203c64:	6789                	lui	a5,0x2
ffffffffc0203c66:	00f32023          	sw	a5,0(t1)
ffffffffc0203c6a:	86aa                	mv	a3,a0
ffffffffc0203c6c:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc0203c6e:	6e89                	lui	t4,0x2
ffffffffc0203c70:	0a8e0663          	beq	t3,s0,ffffffffc0203d1c <do_fork+0x35e>
ffffffffc0203c74:	88ae                	mv	a7,a1
ffffffffc0203c76:	87f2                	mv	a5,t3
ffffffffc0203c78:	6609                	lui	a2,0x2
ffffffffc0203c7a:	a811                	j	ffffffffc0203c8e <do_fork+0x2d0>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0203c7c:	00e6d663          	bge	a3,a4,ffffffffc0203c88 <do_fork+0x2ca>
ffffffffc0203c80:	00c75463          	bge	a4,a2,ffffffffc0203c88 <do_fork+0x2ca>
ffffffffc0203c84:	863a                	mv	a2,a4
ffffffffc0203c86:	4885                	li	a7,1
ffffffffc0203c88:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0203c8a:	00878d63          	beq	a5,s0,ffffffffc0203ca4 <do_fork+0x2e6>
            if (proc->pid == last_pid)
ffffffffc0203c8e:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x83b4>
ffffffffc0203c92:	fed715e3          	bne	a4,a3,ffffffffc0203c7c <do_fork+0x2be>
                if (++last_pid >= next_safe)
ffffffffc0203c96:	2685                	addiw	a3,a3,1
ffffffffc0203c98:	06c6d763          	bge	a3,a2,ffffffffc0203d06 <do_fork+0x348>
ffffffffc0203c9c:	679c                	ld	a5,8(a5)
ffffffffc0203c9e:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0203ca0:	fe8797e3          	bne	a5,s0,ffffffffc0203c8e <do_fork+0x2d0>
ffffffffc0203ca4:	c581                	beqz	a1,ffffffffc0203cac <do_fork+0x2ee>
ffffffffc0203ca6:	00d82023          	sw	a3,0(a6)
ffffffffc0203caa:	8536                	mv	a0,a3
ffffffffc0203cac:	e4088ee3          	beqz	a7,ffffffffc0203b08 <do_fork+0x14a>
ffffffffc0203cb0:	00c32023          	sw	a2,0(t1)
ffffffffc0203cb4:	bd91                	j	ffffffffc0203b08 <do_fork+0x14a>
        kfree(proc);
ffffffffc0203cb6:	8556                	mv	a0,s5
ffffffffc0203cb8:	b07fd0ef          	jal	ra,ffffffffc02017be <kfree>
    return -E_NO_MEM;
ffffffffc0203cbc:	5971                	li	s2,-4
        return ret;
ffffffffc0203cbe:	b5c9                	j	ffffffffc0203b80 <do_fork+0x1c2>
    mm->mm_count += 1;
ffffffffc0203cc0:	030da783          	lw	a5,48(s11)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203cc4:	018db703          	ld	a4,24(s11)
    proc->mm = mm;
ffffffffc0203cc8:	03bab423          	sd	s11,40(s5)
ffffffffc0203ccc:	2785                	addiw	a5,a5,1
ffffffffc0203cce:	02fda823          	sw	a5,48(s11)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203cd2:	c02007b7          	lui	a5,0xc0200
ffffffffc0203cd6:	0af76963          	bltu	a4,a5,ffffffffc0203d88 <do_fork+0x3ca>
ffffffffc0203cda:	000d3603          	ld	a2,0(s10)
    proc->parent = current;
ffffffffc0203cde:	000a3783          	ld	a5,0(s4)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203ce2:	010ab683          	ld	a3,16(s5)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203ce6:	8f11                	sub	a4,a4,a2
ffffffffc0203ce8:	0aeab423          	sd	a4,168(s5)
    return 0;
ffffffffc0203cec:	bb69                	j	ffffffffc0203a86 <do_fork+0xc8>
        intr_enable();
ffffffffc0203cee:	c81fc0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0203cf2:	b551                	j	ffffffffc0203b76 <do_fork+0x1b8>
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203cf4:	000ad717          	auipc	a4,0xad
ffffffffc0203cf8:	9f473703          	ld	a4,-1548(a4) # ffffffffc02b06e8 <boot_pgdir_pa>
        proc->mm = NULL;
ffffffffc0203cfc:	020ab423          	sd	zero,40(s5)
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203d00:	0aeab423          	sd	a4,168(s5)
        return 0;
ffffffffc0203d04:	b349                	j	ffffffffc0203a86 <do_fork+0xc8>
                    if (last_pid >= MAX_PID)
ffffffffc0203d06:	01d6c363          	blt	a3,t4,ffffffffc0203d0c <do_fork+0x34e>
                        last_pid = 1;
ffffffffc0203d0a:	4685                	li	a3,1
                    goto repeat;
ffffffffc0203d0c:	4585                	li	a1,1
ffffffffc0203d0e:	b78d                	j	ffffffffc0203c70 <do_fork+0x2b2>
        intr_disable();
ffffffffc0203d10:	c65fc0ef          	jal	ra,ffffffffc0200974 <intr_disable>
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0203d14:	004aa503          	lw	a0,4(s5)
        return 1;
ffffffffc0203d18:	4905                	li	s2,1
ffffffffc0203d1a:	bbfd                	j	ffffffffc0203b18 <do_fork+0x15a>
ffffffffc0203d1c:	c999                	beqz	a1,ffffffffc0203d32 <do_fork+0x374>
ffffffffc0203d1e:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc0203d22:	8536                	mv	a0,a3
ffffffffc0203d24:	b3d5                	j	ffffffffc0203b08 <do_fork+0x14a>
        return -E_INVAL;
ffffffffc0203d26:	5975                	li	s2,-3
ffffffffc0203d28:	bda1                	j	ffffffffc0203b80 <do_fork+0x1c2>
        return -E_NO_FREE_PROC;
ffffffffc0203d2a:	596d                	li	s2,-5
ffffffffc0203d2c:	bd91                	j	ffffffffc0203b80 <do_fork+0x1c2>
        return -E_NO_MEM;
ffffffffc0203d2e:	5971                	li	s2,-4
ffffffffc0203d30:	bd81                	j	ffffffffc0203b80 <do_fork+0x1c2>
    return last_pid;
ffffffffc0203d32:	00082503          	lw	a0,0(a6)
ffffffffc0203d36:	bbc9                	j	ffffffffc0203b08 <do_fork+0x14a>
        return -E_NO_MEM;
ffffffffc0203d38:	5971                	li	s2,-4
ffffffffc0203d3a:	bde1                	j	ffffffffc0203c12 <do_fork+0x254>
        return -E_NO_MEM;
ffffffffc0203d3c:	5971                	li	s2,-4
ffffffffc0203d3e:	bd65                	j	ffffffffc0203bf6 <do_fork+0x238>
    return KADDR(page2pa(page));
ffffffffc0203d40:	00002617          	auipc	a2,0x2
ffffffffc0203d44:	e3060613          	addi	a2,a2,-464 # ffffffffc0205b70 <default_pmm_manager+0x38>
ffffffffc0203d48:	07100593          	li	a1,113
ffffffffc0203d4c:	00002517          	auipc	a0,0x2
ffffffffc0203d50:	e4c50513          	addi	a0,a0,-436 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc0203d54:	efafc0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203d58:	00002617          	auipc	a2,0x2
ffffffffc0203d5c:	ee860613          	addi	a2,a2,-280 # ffffffffc0205c40 <default_pmm_manager+0x108>
ffffffffc0203d60:	06900593          	li	a1,105
ffffffffc0203d64:	00002517          	auipc	a0,0x2
ffffffffc0203d68:	e3450513          	addi	a0,a0,-460 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc0203d6c:	ee2fc0ef          	jal	ra,ffffffffc020044e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0203d70:	00002617          	auipc	a2,0x2
ffffffffc0203d74:	ea860613          	addi	a2,a2,-344 # ffffffffc0205c18 <default_pmm_manager+0xe0>
ffffffffc0203d78:	07700593          	li	a1,119
ffffffffc0203d7c:	00002517          	auipc	a0,0x2
ffffffffc0203d80:	e1c50513          	addi	a0,a0,-484 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc0203d84:	ecafc0ef          	jal	ra,ffffffffc020044e <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203d88:	86ba                	mv	a3,a4
ffffffffc0203d8a:	00002617          	auipc	a2,0x2
ffffffffc0203d8e:	e8e60613          	addi	a2,a2,-370 # ffffffffc0205c18 <default_pmm_manager+0xe0>
ffffffffc0203d92:	16300593          	li	a1,355
ffffffffc0203d96:	00003517          	auipc	a0,0x3
ffffffffc0203d9a:	87a50513          	addi	a0,a0,-1926 # ffffffffc0206610 <default_pmm_manager+0xad8>
ffffffffc0203d9e:	eb0fc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0203da2 <kernel_thread>:
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0203da2:	7129                	addi	sp,sp,-320
ffffffffc0203da4:	fa22                	sd	s0,304(sp)
ffffffffc0203da6:	f626                	sd	s1,296(sp)
ffffffffc0203da8:	f24a                	sd	s2,288(sp)
ffffffffc0203daa:	84ae                	mv	s1,a1
ffffffffc0203dac:	892a                	mv	s2,a0
ffffffffc0203dae:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(tf));
ffffffffc0203db0:	4581                	li	a1,0
ffffffffc0203db2:	12000613          	li	a2,288
ffffffffc0203db6:	850a                	mv	a0,sp
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0203db8:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(tf));
ffffffffc0203dba:	2c8010ef          	jal	ra,ffffffffc0205082 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0203dbe:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0203dc0:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0203dc2:	100027f3          	csrr	a5,sstatus
ffffffffc0203dc6:	edd7f793          	andi	a5,a5,-291
ffffffffc0203dca:	1207e793          	ori	a5,a5,288
ffffffffc0203dce:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0203dd0:	860a                	mv	a2,sp
ffffffffc0203dd2:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0203dd6:	00000797          	auipc	a5,0x0
ffffffffc0203dda:	b1678793          	addi	a5,a5,-1258 # ffffffffc02038ec <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0203dde:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0203de0:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0203de2:	bddff0ef          	jal	ra,ffffffffc02039be <do_fork>
}
ffffffffc0203de6:	70f2                	ld	ra,312(sp)
ffffffffc0203de8:	7452                	ld	s0,304(sp)
ffffffffc0203dea:	74b2                	ld	s1,296(sp)
ffffffffc0203dec:	7912                	ld	s2,288(sp)
ffffffffc0203dee:	6131                	addi	sp,sp,320
ffffffffc0203df0:	8082                	ret

ffffffffc0203df2 <proc_run>:

void proc_run(struct proc_struct *proc) {
ffffffffc0203df2:	7179                	addi	sp,sp,-48
ffffffffc0203df4:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0203df6:	000ad497          	auipc	s1,0xad
ffffffffc0203dfa:	92248493          	addi	s1,s1,-1758 # ffffffffc02b0718 <current>
ffffffffc0203dfe:	6098                	ld	a4,0(s1)
void proc_run(struct proc_struct *proc) {
ffffffffc0203e00:	f406                	sd	ra,40(sp)
ffffffffc0203e02:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0203e04:	02a70963          	beq	a4,a0,ffffffffc0203e36 <proc_run+0x44>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203e08:	100027f3          	csrr	a5,sstatus
ffffffffc0203e0c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203e0e:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203e10:	ef95                	bnez	a5,ffffffffc0203e4c <proc_run+0x5a>
        bool intr_flag;
        local_intr_save(intr_flag);
        struct proc_struct *prev = current;
        current = proc;
        write_csr(satp, (1UL << 63) | (proc->pgdir >> PGSHIFT));
ffffffffc0203e12:	755c                	ld	a5,168(a0)
ffffffffc0203e14:	56fd                	li	a3,-1
ffffffffc0203e16:	16fe                	slli	a3,a3,0x3f
ffffffffc0203e18:	83b1                	srli	a5,a5,0xc
        current = proc;
ffffffffc0203e1a:	e088                	sd	a0,0(s1)
        write_csr(satp, (1UL << 63) | (proc->pgdir >> PGSHIFT));
ffffffffc0203e1c:	8fd5                	or	a5,a5,a3
ffffffffc0203e1e:	18079073          	csrw	satp,a5
        asm volatile("sfence.vma" ::: "memory");
ffffffffc0203e22:	12000073          	sfence.vma
        switch_to(&prev->context, &proc->context);
ffffffffc0203e26:	03050593          	addi	a1,a0,48
ffffffffc0203e2a:	03070513          	addi	a0,a4,48
ffffffffc0203e2e:	37f000ef          	jal	ra,ffffffffc02049ac <switch_to>
    if (flag)
ffffffffc0203e32:	00091763          	bnez	s2,ffffffffc0203e40 <proc_run+0x4e>
        local_intr_restore(intr_flag);
    }
}
ffffffffc0203e36:	70a2                	ld	ra,40(sp)
ffffffffc0203e38:	7482                	ld	s1,32(sp)
ffffffffc0203e3a:	6962                	ld	s2,24(sp)
ffffffffc0203e3c:	6145                	addi	sp,sp,48
ffffffffc0203e3e:	8082                	ret
ffffffffc0203e40:	70a2                	ld	ra,40(sp)
ffffffffc0203e42:	7482                	ld	s1,32(sp)
ffffffffc0203e44:	6962                	ld	s2,24(sp)
ffffffffc0203e46:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0203e48:	b27fc06f          	j	ffffffffc020096e <intr_enable>
ffffffffc0203e4c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203e4e:	b27fc0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        struct proc_struct *prev = current;
ffffffffc0203e52:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc0203e54:	6522                	ld	a0,8(sp)
ffffffffc0203e56:	4905                	li	s2,1
ffffffffc0203e58:	bf6d                	j	ffffffffc0203e12 <proc_run+0x20>

ffffffffc0203e5a <do_yield>:

int do_yield(void) {
    if (current == NULL) return -E_INVAL;
ffffffffc0203e5a:	000ad797          	auipc	a5,0xad
ffffffffc0203e5e:	8be7b783          	ld	a5,-1858(a5) # ffffffffc02b0718 <current>
ffffffffc0203e62:	c789                	beqz	a5,ffffffffc0203e6c <do_yield+0x12>
    current->need_resched = 1;
ffffffffc0203e64:	4705                	li	a4,1
ffffffffc0203e66:	ef98                	sd	a4,24(a5)
    return 0;
ffffffffc0203e68:	4501                	li	a0,0
ffffffffc0203e6a:	8082                	ret
    if (current == NULL) return -E_INVAL;
ffffffffc0203e6c:	5575                	li	a0,-3
}
ffffffffc0203e6e:	8082                	ret

ffffffffc0203e70 <cpu_idle>:

void cpu_idle(void) {
ffffffffc0203e70:	1141                	addi	sp,sp,-16
ffffffffc0203e72:	e022                	sd	s0,0(sp)
ffffffffc0203e74:	e406                	sd	ra,8(sp)
ffffffffc0203e76:	000ad417          	auipc	s0,0xad
ffffffffc0203e7a:	8a240413          	addi	s0,s0,-1886 # ffffffffc02b0718 <current>
    while (1) {
        if (current->need_resched) schedule();
ffffffffc0203e7e:	601c                	ld	a5,0(s0)
ffffffffc0203e80:	6f9c                	ld	a5,24(a5)
ffffffffc0203e82:	c399                	beqz	a5,ffffffffc0203e88 <cpu_idle+0x18>
ffffffffc0203e84:	413000ef          	jal	ra,ffffffffc0204a96 <schedule>
        asm volatile("wfi");
ffffffffc0203e88:	10500073          	wfi
        if (current->need_resched) schedule();
ffffffffc0203e8c:	bfcd                	j	ffffffffc0203e7e <cpu_idle+0xe>

ffffffffc0203e8e <do_exit>:
    }
}

int do_exit(int error_code) {
ffffffffc0203e8e:	7139                	addi	sp,sp,-64
ffffffffc0203e90:	f822                	sd	s0,48(sp)
    if (current == idleproc || current == initproc) panic("cannot exit idle/init");
ffffffffc0203e92:	000ad417          	auipc	s0,0xad
ffffffffc0203e96:	88640413          	addi	s0,s0,-1914 # ffffffffc02b0718 <current>
ffffffffc0203e9a:	6018                	ld	a4,0(s0)
int do_exit(int error_code) {
ffffffffc0203e9c:	fc06                	sd	ra,56(sp)
ffffffffc0203e9e:	f426                	sd	s1,40(sp)
ffffffffc0203ea0:	f04a                	sd	s2,32(sp)
ffffffffc0203ea2:	ec4e                	sd	s3,24(sp)
ffffffffc0203ea4:	e852                	sd	s4,16(sp)
ffffffffc0203ea6:	e456                	sd	s5,8(sp)
    if (current == idleproc || current == initproc) panic("cannot exit idle/init");
ffffffffc0203ea8:	000ad797          	auipc	a5,0xad
ffffffffc0203eac:	8787b783          	ld	a5,-1928(a5) # ffffffffc02b0720 <idleproc>
ffffffffc0203eb0:	0cf70463          	beq	a4,a5,ffffffffc0203f78 <do_exit+0xea>
ffffffffc0203eb4:	000ad497          	auipc	s1,0xad
ffffffffc0203eb8:	87448493          	addi	s1,s1,-1932 # ffffffffc02b0728 <initproc>
ffffffffc0203ebc:	609c                	ld	a5,0(s1)
ffffffffc0203ebe:	0af70d63          	beq	a4,a5,ffffffffc0203f78 <do_exit+0xea>
ffffffffc0203ec2:	8a2a                	mv	s4,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203ec4:	100027f3          	csrr	a5,sstatus
ffffffffc0203ec8:	8b89                	andi	a5,a5,2
ffffffffc0203eca:	e3f9                	bnez	a5,ffffffffc0203f90 <do_exit+0x102>

    /* Reparent children before this PCB can be reaped by its parent. */
    bool intr_flag;
    local_intr_save(intr_flag);
    while (current->cptr != NULL) {
ffffffffc0203ecc:	7b7c                	ld	a5,240(a4)
    return 0;
ffffffffc0203ece:	4a81                	li	s5,0
ffffffffc0203ed0:	c3b1                	beqz	a5,ffffffffc0203f14 <do_exit+0x86>
        child->parent = initproc;
        child->optr = initproc->cptr;
        child->yptr = NULL;
        if (initproc->cptr != NULL) initproc->cptr->yptr = child;
        initproc->cptr = child;
        if (child->state == PROC_ZOMBIE && initproc->state == PROC_SLEEPING)
ffffffffc0203ed2:	490d                	li	s2,3
ffffffffc0203ed4:	4985                	li	s3,1
ffffffffc0203ed6:	a021                	j	ffffffffc0203ede <do_exit+0x50>
    while (current->cptr != NULL) {
ffffffffc0203ed8:	6018                	ld	a4,0(s0)
ffffffffc0203eda:	7b7c                	ld	a5,240(a4)
ffffffffc0203edc:	cb95                	beqz	a5,ffffffffc0203f10 <do_exit+0x82>
        current->cptr = child->optr;
ffffffffc0203ede:	1007b683          	ld	a3,256(a5)
ffffffffc0203ee2:	fb74                	sd	a3,240(a4)
        if (current->cptr != NULL) current->cptr->yptr = NULL;
ffffffffc0203ee4:	c299                	beqz	a3,ffffffffc0203eea <do_exit+0x5c>
ffffffffc0203ee6:	0e06bc23          	sd	zero,248(a3)
        child->parent = initproc;
ffffffffc0203eea:	6088                	ld	a0,0(s1)
        child->optr = initproc->cptr;
ffffffffc0203eec:	7978                	ld	a4,240(a0)
        child->parent = initproc;
ffffffffc0203eee:	f388                	sd	a0,32(a5)
        child->yptr = NULL;
ffffffffc0203ef0:	0e07bc23          	sd	zero,248(a5)
        child->optr = initproc->cptr;
ffffffffc0203ef4:	10e7b023          	sd	a4,256(a5)
        if (initproc->cptr != NULL) initproc->cptr->yptr = child;
ffffffffc0203ef8:	c311                	beqz	a4,ffffffffc0203efc <do_exit+0x6e>
ffffffffc0203efa:	ff7c                	sd	a5,248(a4)
        if (child->state == PROC_ZOMBIE && initproc->state == PROC_SLEEPING)
ffffffffc0203efc:	4398                	lw	a4,0(a5)
        initproc->cptr = child;
ffffffffc0203efe:	f97c                	sd	a5,240(a0)
        if (child->state == PROC_ZOMBIE && initproc->state == PROC_SLEEPING)
ffffffffc0203f00:	fd271ce3          	bne	a4,s2,ffffffffc0203ed8 <do_exit+0x4a>
ffffffffc0203f04:	411c                	lw	a5,0(a0)
ffffffffc0203f06:	fd3799e3          	bne	a5,s3,ffffffffc0203ed8 <do_exit+0x4a>
            wakeup_proc(initproc);
ffffffffc0203f0a:	30d000ef          	jal	ra,ffffffffc0204a16 <wakeup_proc>
ffffffffc0203f0e:	b7e9                	j	ffffffffc0203ed8 <do_exit+0x4a>
    if (flag)
ffffffffc0203f10:	080a9663          	bnez	s5,ffffffffc0203f9c <do_exit+0x10e>
    }
    local_intr_restore(intr_flag);

    if (current->mm != NULL) {
ffffffffc0203f14:	6018                	ld	a4,0(s0)
ffffffffc0203f16:	7704                	ld	s1,40(a4)
ffffffffc0203f18:	c49d                	beqz	s1,ffffffffc0203f46 <do_exit+0xb8>
    mm->mm_count -= 1;
ffffffffc0203f1a:	589c                	lw	a5,48(s1)
        struct mm_struct *mm = current->mm;
        current->mm = NULL;
ffffffffc0203f1c:	02073423          	sd	zero,40(a4)
ffffffffc0203f20:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203f24:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc0203f26:	cf35                	beqz	a4,ffffffffc0203fa2 <do_exit+0x114>
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->pgdir = boot_pgdir_pa;
ffffffffc0203f28:	6014                	ld	a3,0(s0)
ffffffffc0203f2a:	000ac717          	auipc	a4,0xac
ffffffffc0203f2e:	7be73703          	ld	a4,1982(a4) # ffffffffc02b06e8 <boot_pgdir_pa>
        write_csr(satp, (1UL << 63) | (boot_pgdir_pa >> PGSHIFT));
ffffffffc0203f32:	00c75793          	srli	a5,a4,0xc
        current->pgdir = boot_pgdir_pa;
ffffffffc0203f36:	f6d8                	sd	a4,168(a3)
        write_csr(satp, (1UL << 63) | (boot_pgdir_pa >> PGSHIFT));
ffffffffc0203f38:	577d                	li	a4,-1
ffffffffc0203f3a:	177e                	slli	a4,a4,0x3f
ffffffffc0203f3c:	8fd9                	or	a5,a5,a4
ffffffffc0203f3e:	18079073          	csrw	satp,a5
        asm volatile("sfence.vma" ::: "memory");
ffffffffc0203f42:	12000073          	sfence.vma
    }
    current->state = PROC_ZOMBIE;
ffffffffc0203f46:	601c                	ld	a5,0(s0)
ffffffffc0203f48:	470d                	li	a4,3
    current->exit_code = error_code;
    if (current->parent != NULL && current->parent->state == PROC_SLEEPING)
ffffffffc0203f4a:	7388                	ld	a0,32(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0203f4c:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0203f4e:	0f47a423          	sw	s4,232(a5)
    if (current->parent != NULL && current->parent->state == PROC_SLEEPING)
ffffffffc0203f52:	c509                	beqz	a0,ffffffffc0203f5c <do_exit+0xce>
ffffffffc0203f54:	4118                	lw	a4,0(a0)
ffffffffc0203f56:	4785                	li	a5,1
ffffffffc0203f58:	04f70f63          	beq	a4,a5,ffffffffc0203fb6 <do_exit+0x128>
        wakeup_proc(current->parent);
    schedule();
ffffffffc0203f5c:	33b000ef          	jal	ra,ffffffffc0204a96 <schedule>
    panic("do_exit returned");
ffffffffc0203f60:	00002617          	auipc	a2,0x2
ffffffffc0203f64:	6e060613          	addi	a2,a2,1760 # ffffffffc0206640 <default_pmm_manager+0xb08>
ffffffffc0203f68:	1d400593          	li	a1,468
ffffffffc0203f6c:	00002517          	auipc	a0,0x2
ffffffffc0203f70:	6a450513          	addi	a0,a0,1700 # ffffffffc0206610 <default_pmm_manager+0xad8>
ffffffffc0203f74:	cdafc0ef          	jal	ra,ffffffffc020044e <__panic>
    if (current == idleproc || current == initproc) panic("cannot exit idle/init");
ffffffffc0203f78:	00002617          	auipc	a2,0x2
ffffffffc0203f7c:	6b060613          	addi	a2,a2,1712 # ffffffffc0206628 <default_pmm_manager+0xaf0>
ffffffffc0203f80:	1af00593          	li	a1,431
ffffffffc0203f84:	00002517          	auipc	a0,0x2
ffffffffc0203f88:	68c50513          	addi	a0,a0,1676 # ffffffffc0206610 <default_pmm_manager+0xad8>
ffffffffc0203f8c:	cc2fc0ef          	jal	ra,ffffffffc020044e <__panic>
        intr_disable();
ffffffffc0203f90:	9e5fc0ef          	jal	ra,ffffffffc0200974 <intr_disable>
    while (current->cptr != NULL) {
ffffffffc0203f94:	6018                	ld	a4,0(s0)
        return 1;
ffffffffc0203f96:	4a85                	li	s5,1
ffffffffc0203f98:	7b7c                	ld	a5,240(a4)
ffffffffc0203f9a:	ff85                	bnez	a5,ffffffffc0203ed2 <do_exit+0x44>
        intr_enable();
ffffffffc0203f9c:	9d3fc0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0203fa0:	bf95                	j	ffffffffc0203f14 <do_exit+0x86>
            exit_mmap(mm);
ffffffffc0203fa2:	8526                	mv	a0,s1
ffffffffc0203fa4:	ce8ff0ef          	jal	ra,ffffffffc020348c <exit_mmap>
            put_pgdir(mm);
ffffffffc0203fa8:	8526                	mv	a0,s1
ffffffffc0203faa:	99fff0ef          	jal	ra,ffffffffc0203948 <put_pgdir>
            mm_destroy(mm);
ffffffffc0203fae:	8526                	mv	a0,s1
ffffffffc0203fb0:	aeeff0ef          	jal	ra,ffffffffc020329e <mm_destroy>
ffffffffc0203fb4:	bf95                	j	ffffffffc0203f28 <do_exit+0x9a>
        wakeup_proc(current->parent);
ffffffffc0203fb6:	261000ef          	jal	ra,ffffffffc0204a16 <wakeup_proc>
ffffffffc0203fba:	b74d                	j	ffffffffc0203f5c <do_exit+0xce>

ffffffffc0203fbc <do_wait>:
}

int do_wait(int pid, int *code_store) {
ffffffffc0203fbc:	7139                	addi	sp,sp,-64
ffffffffc0203fbe:	e456                	sd	s5,8(sp)
    if (current == NULL || pid < 0) return -E_BAD_PROC;
ffffffffc0203fc0:	000aca97          	auipc	s5,0xac
ffffffffc0203fc4:	758a8a93          	addi	s5,s5,1880 # ffffffffc02b0718 <current>
ffffffffc0203fc8:	000ab683          	ld	a3,0(s5)
int do_wait(int pid, int *code_store) {
ffffffffc0203fcc:	fc06                	sd	ra,56(sp)
ffffffffc0203fce:	f822                	sd	s0,48(sp)
ffffffffc0203fd0:	f426                	sd	s1,40(sp)
ffffffffc0203fd2:	f04a                	sd	s2,32(sp)
ffffffffc0203fd4:	ec4e                	sd	s3,24(sp)
ffffffffc0203fd6:	e852                	sd	s4,16(sp)
ffffffffc0203fd8:	e05a                	sd	s6,0(sp)
    if (current == NULL || pid < 0) return -E_BAD_PROC;
ffffffffc0203fda:	ce9d                	beqz	a3,ffffffffc0204018 <do_wait+0x5c>
ffffffffc0203fdc:	84aa                	mv	s1,a0
ffffffffc0203fde:	02054d63          	bltz	a0,ffffffffc0204018 <do_wait+0x5c>
    struct proc_struct *p;
    bool has_child;
    while (1) {
        has_child = 0;
        p = current->cptr;
ffffffffc0203fe2:	7ae0                	ld	s0,240(a3)
            }
            p = p->optr;
        }
        if (!has_child) return -E_BAD_PROC;
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;
ffffffffc0203fe4:	80000a37          	lui	s4,0x80000
ffffffffc0203fe8:	89ae                	mv	s3,a1
                if (p->state == PROC_ZOMBIE) goto found;
ffffffffc0203fea:	490d                	li	s2,3
                has_child = 1;
ffffffffc0203fec:	4b05                	li	s6,1
        current->wait_state = WT_CHILD;
ffffffffc0203fee:	0a05                	addi	s4,s4,1
        while (p != NULL) {
ffffffffc0203ff0:	c405                	beqz	s0,ffffffffc0204018 <do_wait+0x5c>
        has_child = 0;
ffffffffc0203ff2:	4701                	li	a4,0
            if (pid == 0 || p->pid == pid) {
ffffffffc0203ff4:	c485                	beqz	s1,ffffffffc020401c <do_wait+0x60>
ffffffffc0203ff6:	405c                	lw	a5,4(s0)
ffffffffc0203ff8:	02978263          	beq	a5,s1,ffffffffc020401c <do_wait+0x60>
            p = p->optr;
ffffffffc0203ffc:	10043403          	ld	s0,256(s0)
        while (p != NULL) {
ffffffffc0204000:	f875                	bnez	s0,ffffffffc0203ff4 <do_wait+0x38>
        if (!has_child) return -E_BAD_PROC;
ffffffffc0204002:	cb19                	beqz	a4,ffffffffc0204018 <do_wait+0x5c>
        current->state = PROC_SLEEPING;
ffffffffc0204004:	0166a023          	sw	s6,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0204008:	0f46a623          	sw	s4,236(a3)
        schedule();
ffffffffc020400c:	28b000ef          	jal	ra,ffffffffc0204a96 <schedule>
        p = current->cptr;
ffffffffc0204010:	000ab683          	ld	a3,0(s5)
ffffffffc0204014:	7ae0                	ld	s0,240(a3)
        while (p != NULL) {
ffffffffc0204016:	fc71                	bnez	s0,ffffffffc0203ff2 <do_wait+0x36>
    if (current == NULL || pid < 0) return -E_BAD_PROC;
ffffffffc0204018:	5579                	li	a0,-2
ffffffffc020401a:	a075                	j	ffffffffc02040c6 <do_wait+0x10a>
                if (p->state == PROC_ZOMBIE) goto found;
ffffffffc020401c:	401c                	lw	a5,0(s0)
ffffffffc020401e:	01278463          	beq	a5,s2,ffffffffc0204026 <do_wait+0x6a>
                has_child = 1;
ffffffffc0204022:	4705                	li	a4,1
ffffffffc0204024:	bfe1                	j	ffffffffc0203ffc <do_wait+0x40>
    }
found:
    if (code_store != NULL) {
ffffffffc0204026:	00098f63          	beqz	s3,ffffffffc0204044 <do_wait+0x88>
        if (current->mm != NULL && !copy_to_user(current->mm, code_store, &p->exit_code, sizeof(int)))
ffffffffc020402a:	7688                	ld	a0,40(a3)
ffffffffc020402c:	c55d                	beqz	a0,ffffffffc02040da <do_wait+0x11e>
ffffffffc020402e:	4691                	li	a3,4
ffffffffc0204030:	0e840613          	addi	a2,s0,232
ffffffffc0204034:	85ce                	mv	a1,s3
ffffffffc0204036:	885ff0ef          	jal	ra,ffffffffc02038ba <copy_to_user>
ffffffffc020403a:	c179                	beqz	a0,ffffffffc0204100 <do_wait+0x144>
            return -E_FAULT;
        if (current->mm == NULL) *code_store = p->exit_code;
ffffffffc020403c:	000ab783          	ld	a5,0(s5)
ffffffffc0204040:	779c                	ld	a5,40(a5)
ffffffffc0204042:	cfc1                	beqz	a5,ffffffffc02040da <do_wait+0x11e>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204044:	100027f3          	csrr	a5,sstatus
ffffffffc0204048:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020404a:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020404c:	e3c5                	bnez	a5,ffffffffc02040ec <do_wait+0x130>
    __list_del(listelm->prev, listelm->next);
ffffffffc020404e:	6c70                	ld	a2,216(s0)
ffffffffc0204050:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc0204052:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc0204056:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0204058:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020405a:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020405c:	6470                	ld	a2,200(s0)
ffffffffc020405e:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0204060:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204062:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc0204064:	c319                	beqz	a4,ffffffffc020406a <do_wait+0xae>
        proc->optr->yptr = proc->yptr;
ffffffffc0204066:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc0204068:	7c7c                	ld	a5,248(s0)
ffffffffc020406a:	cbc1                	beqz	a5,ffffffffc02040fa <do_wait+0x13e>
        proc->yptr->optr = proc->optr;
ffffffffc020406c:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc0204070:	000ac717          	auipc	a4,0xac
ffffffffc0204074:	6c070713          	addi	a4,a4,1728 # ffffffffc02b0730 <nr_process>
ffffffffc0204078:	431c                	lw	a5,0(a4)
ffffffffc020407a:	37fd                	addiw	a5,a5,-1
ffffffffc020407c:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc020407e:	e9bd                	bnez	a1,ffffffffc02040f4 <do_wait+0x138>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204080:	6814                	ld	a3,16(s0)
ffffffffc0204082:	c02007b7          	lui	a5,0xc0200
ffffffffc0204086:	06f6ef63          	bltu	a3,a5,ffffffffc0204104 <do_wait+0x148>
ffffffffc020408a:	000ac797          	auipc	a5,0xac
ffffffffc020408e:	6867b783          	ld	a5,1670(a5) # ffffffffc02b0710 <va_pa_offset>
ffffffffc0204092:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204094:	82b1                	srli	a3,a3,0xc
ffffffffc0204096:	000ac797          	auipc	a5,0xac
ffffffffc020409a:	6627b783          	ld	a5,1634(a5) # ffffffffc02b06f8 <npage>
ffffffffc020409e:	06f6ff63          	bgeu	a3,a5,ffffffffc020411c <do_wait+0x160>
    return &pages[PPN(pa) - nbase];
ffffffffc02040a2:	00003517          	auipc	a0,0x3
ffffffffc02040a6:	ede53503          	ld	a0,-290(a0) # ffffffffc0206f80 <nbase>
ffffffffc02040aa:	8e89                	sub	a3,a3,a0
ffffffffc02040ac:	069a                	slli	a3,a3,0x6
ffffffffc02040ae:	000ac517          	auipc	a0,0xac
ffffffffc02040b2:	65253503          	ld	a0,1618(a0) # ffffffffc02b0700 <pages>
ffffffffc02040b6:	9536                	add	a0,a0,a3
ffffffffc02040b8:	4589                	li	a1,2
ffffffffc02040ba:	871fd0ef          	jal	ra,ffffffffc020192a <free_pages>
    local_intr_save(intr_flag);
    unhash_proc(p);
    remove_links(p);
    local_intr_restore(intr_flag);
    put_kstack(p);
    kfree(p);
ffffffffc02040be:	8522                	mv	a0,s0
ffffffffc02040c0:	efefd0ef          	jal	ra,ffffffffc02017be <kfree>
    return 0;
ffffffffc02040c4:	4501                	li	a0,0
}
ffffffffc02040c6:	70e2                	ld	ra,56(sp)
ffffffffc02040c8:	7442                	ld	s0,48(sp)
ffffffffc02040ca:	74a2                	ld	s1,40(sp)
ffffffffc02040cc:	7902                	ld	s2,32(sp)
ffffffffc02040ce:	69e2                	ld	s3,24(sp)
ffffffffc02040d0:	6a42                	ld	s4,16(sp)
ffffffffc02040d2:	6aa2                	ld	s5,8(sp)
ffffffffc02040d4:	6b02                	ld	s6,0(sp)
ffffffffc02040d6:	6121                	addi	sp,sp,64
ffffffffc02040d8:	8082                	ret
        if (current->mm == NULL) *code_store = p->exit_code;
ffffffffc02040da:	0e842783          	lw	a5,232(s0)
ffffffffc02040de:	00f9a023          	sw	a5,0(s3)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02040e2:	100027f3          	csrr	a5,sstatus
ffffffffc02040e6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02040e8:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02040ea:	d3b5                	beqz	a5,ffffffffc020404e <do_wait+0x92>
        intr_disable();
ffffffffc02040ec:	889fc0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        return 1;
ffffffffc02040f0:	4585                	li	a1,1
ffffffffc02040f2:	bfb1                	j	ffffffffc020404e <do_wait+0x92>
        intr_enable();
ffffffffc02040f4:	87bfc0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc02040f8:	b761                	j	ffffffffc0204080 <do_wait+0xc4>
        proc->parent->cptr = proc->optr;
ffffffffc02040fa:	701c                	ld	a5,32(s0)
ffffffffc02040fc:	fbf8                	sd	a4,240(a5)
ffffffffc02040fe:	bf8d                	j	ffffffffc0204070 <do_wait+0xb4>
            return -E_FAULT;
ffffffffc0204100:	5569                	li	a0,-6
ffffffffc0204102:	b7d1                	j	ffffffffc02040c6 <do_wait+0x10a>
    return pa2page(PADDR(kva));
ffffffffc0204104:	00002617          	auipc	a2,0x2
ffffffffc0204108:	b1460613          	addi	a2,a2,-1260 # ffffffffc0205c18 <default_pmm_manager+0xe0>
ffffffffc020410c:	07700593          	li	a1,119
ffffffffc0204110:	00002517          	auipc	a0,0x2
ffffffffc0204114:	a8850513          	addi	a0,a0,-1400 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc0204118:	b36fc0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020411c:	00002617          	auipc	a2,0x2
ffffffffc0204120:	b2460613          	addi	a2,a2,-1244 # ffffffffc0205c40 <default_pmm_manager+0x108>
ffffffffc0204124:	06900593          	li	a1,105
ffffffffc0204128:	00002517          	auipc	a0,0x2
ffffffffc020412c:	a7050513          	addi	a0,a0,-1424 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc0204130:	b1efc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0204134 <init_main>:
    (void)arg;
    int ret = KERNEL_EXECVE(waitkill);
    panic("kernel_execve failed: %d", ret);
}

static int init_main(void *arg) {
ffffffffc0204134:	7179                	addi	sp,sp,-48
    (void)arg;
    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0204136:	4601                	li	a2,0
ffffffffc0204138:	4581                	li	a1,0
ffffffffc020413a:	00000517          	auipc	a0,0x0
ffffffffc020413e:	5ea50513          	addi	a0,a0,1514 # ffffffffc0204724 <user_main>
static int init_main(void *arg) {
ffffffffc0204142:	f022                	sd	s0,32(sp)
ffffffffc0204144:	f406                	sd	ra,40(sp)
ffffffffc0204146:	ec26                	sd	s1,24(sp)
    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0204148:	c5bff0ef          	jal	ra,ffffffffc0203da2 <kernel_thread>
ffffffffc020414c:	842a                	mv	s0,a0
    if (pid < 0) panic("create user process failed: %d", pid);
ffffffffc020414e:	02054963          	bltz	a0,ffffffffc0204180 <init_main+0x4c>
    int code = 0;
    int ret = do_wait(pid, &code);
ffffffffc0204152:	006c                	addi	a1,sp,12
    int code = 0;
ffffffffc0204154:	c602                	sw	zero,12(sp)
    int ret = do_wait(pid, &code);
ffffffffc0204156:	e67ff0ef          	jal	ra,ffffffffc0203fbc <do_wait>
    cprintf("user process pid=%d exited: wait=%d code=%d\n", pid, ret, code);
ffffffffc020415a:	46b2                	lw	a3,12(sp)
    int ret = do_wait(pid, &code);
ffffffffc020415c:	862a                	mv	a2,a0
    cprintf("user process pid=%d exited: wait=%d code=%d\n", pid, ret, code);
ffffffffc020415e:	85a2                	mv	a1,s0
ffffffffc0204160:	00002517          	auipc	a0,0x2
ffffffffc0204164:	51850513          	addi	a0,a0,1304 # ffffffffc0206678 <default_pmm_manager+0xb40>
ffffffffc0204168:	82cfc0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc020416c:	000ac497          	auipc	s1,0xac
ffffffffc0204170:	5ac48493          	addi	s1,s1,1452 # ffffffffc02b0718 <current>
    while (1) { current->need_resched = 1; schedule(); }
ffffffffc0204174:	4405                	li	s0,1
ffffffffc0204176:	609c                	ld	a5,0(s1)
ffffffffc0204178:	ef80                	sd	s0,24(a5)
ffffffffc020417a:	11d000ef          	jal	ra,ffffffffc0204a96 <schedule>
ffffffffc020417e:	bfe5                	j	ffffffffc0204176 <init_main+0x42>
    if (pid < 0) panic("create user process failed: %d", pid);
ffffffffc0204180:	86aa                	mv	a3,a0
ffffffffc0204182:	00002617          	auipc	a2,0x2
ffffffffc0204186:	4d660613          	addi	a2,a2,1238 # ffffffffc0206658 <default_pmm_manager+0xb20>
ffffffffc020418a:	2aa00593          	li	a1,682
ffffffffc020418e:	00002517          	auipc	a0,0x2
ffffffffc0204192:	48250513          	addi	a0,a0,1154 # ffffffffc0206610 <default_pmm_manager+0xad8>
ffffffffc0204196:	ab8fc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc020419a <do_kill>:
int do_kill(int pid) {
ffffffffc020419a:	7179                	addi	sp,sp,-48
ffffffffc020419c:	f022                	sd	s0,32(sp)
ffffffffc020419e:	f406                	sd	ra,40(sp)
ffffffffc02041a0:	ec26                	sd	s1,24(sp)
ffffffffc02041a2:	e84a                	sd	s2,16(sp)
ffffffffc02041a4:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02041a6:	100027f3          	csrr	a5,sstatus
ffffffffc02041aa:	8b89                	andi	a5,a5,2
    if (0 < pid && pid < MAX_PID)
ffffffffc02041ac:	2501                	sext.w	a0,a0
ffffffffc02041ae:	fff4049b          	addiw	s1,s0,-1
ffffffffc02041b2:	e3d5                	bnez	a5,ffffffffc0204256 <do_kill+0xbc>
ffffffffc02041b4:	6789                	lui	a5,0x2
ffffffffc02041b6:	17f9                	addi	a5,a5,-2
    return 0;
ffffffffc02041b8:	4901                	li	s2,0
ffffffffc02041ba:	0297e863          	bltu	a5,s1,ffffffffc02041ea <do_kill+0x50>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02041be:	45a9                	li	a1,10
ffffffffc02041c0:	21d000ef          	jal	ra,ffffffffc0204bdc <hash32>
ffffffffc02041c4:	02051693          	slli	a3,a0,0x20
ffffffffc02041c8:	000a8797          	auipc	a5,0xa8
ffffffffc02041cc:	4e078793          	addi	a5,a5,1248 # ffffffffc02ac6a8 <hash_list>
ffffffffc02041d0:	82f1                	srli	a3,a3,0x1c
ffffffffc02041d2:	96be                	add	a3,a3,a5
ffffffffc02041d4:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc02041d6:	a029                	j	ffffffffc02041e0 <do_kill+0x46>
            if (proc->pid == pid)
ffffffffc02041d8:	f2c7a703          	lw	a4,-212(a5)
ffffffffc02041dc:	00870e63          	beq	a4,s0,ffffffffc02041f8 <do_kill+0x5e>
    return listelm->next;
ffffffffc02041e0:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02041e2:	fef69be3          	bne	a3,a5,ffffffffc02041d8 <do_kill+0x3e>
    if (flag)
ffffffffc02041e6:	08091163          	bnez	s2,ffffffffc0204268 <do_kill+0xce>
        return -E_INVAL;
ffffffffc02041ea:	5575                	li	a0,-3
}
ffffffffc02041ec:	70a2                	ld	ra,40(sp)
ffffffffc02041ee:	7402                	ld	s0,32(sp)
ffffffffc02041f0:	64e2                	ld	s1,24(sp)
ffffffffc02041f2:	6942                	ld	s2,16(sp)
ffffffffc02041f4:	6145                	addi	sp,sp,48
ffffffffc02041f6:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02041f8:	f2878513          	addi	a0,a5,-216
    if (p == NULL || p == idleproc || p == initproc || p->state == PROC_ZOMBIE) {
ffffffffc02041fc:	000ac717          	auipc	a4,0xac
ffffffffc0204200:	52473703          	ld	a4,1316(a4) # ffffffffc02b0720 <idleproc>
ffffffffc0204204:	fea701e3          	beq	a4,a0,ffffffffc02041e6 <do_kill+0x4c>
ffffffffc0204208:	000ac717          	auipc	a4,0xac
ffffffffc020420c:	52073703          	ld	a4,1312(a4) # ffffffffc02b0728 <initproc>
ffffffffc0204210:	fca70be3          	beq	a4,a0,ffffffffc02041e6 <do_kill+0x4c>
ffffffffc0204214:	f287a683          	lw	a3,-216(a5)
ffffffffc0204218:	470d                	li	a4,3
ffffffffc020421a:	fce686e3          	beq	a3,a4,ffffffffc02041e6 <do_kill+0x4c>
    p->flags |= PF_EXITING;
ffffffffc020421e:	fd87a703          	lw	a4,-40(a5)
    if (p->state == PROC_SLEEPING) wakeup_proc(p);
ffffffffc0204222:	4605                	li	a2,1
    p->flags |= PF_EXITING;
ffffffffc0204224:	00176713          	ori	a4,a4,1
ffffffffc0204228:	fce7ac23          	sw	a4,-40(a5)
    if (p->state == PROC_SLEEPING) wakeup_proc(p);
ffffffffc020422c:	04c68263          	beq	a3,a2,ffffffffc0204270 <do_kill+0xd6>
    return 0;
ffffffffc0204230:	4501                	li	a0,0
ffffffffc0204232:	00091863          	bnez	s2,ffffffffc0204242 <do_kill+0xa8>
}
ffffffffc0204236:	70a2                	ld	ra,40(sp)
ffffffffc0204238:	7402                	ld	s0,32(sp)
ffffffffc020423a:	64e2                	ld	s1,24(sp)
ffffffffc020423c:	6942                	ld	s2,16(sp)
ffffffffc020423e:	6145                	addi	sp,sp,48
ffffffffc0204240:	8082                	ret
ffffffffc0204242:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0204244:	f2afc0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0204248:	70a2                	ld	ra,40(sp)
ffffffffc020424a:	7402                	ld	s0,32(sp)
ffffffffc020424c:	6522                	ld	a0,8(sp)
ffffffffc020424e:	64e2                	ld	s1,24(sp)
ffffffffc0204250:	6942                	ld	s2,16(sp)
ffffffffc0204252:	6145                	addi	sp,sp,48
ffffffffc0204254:	8082                	ret
ffffffffc0204256:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204258:	f1cfc0ef          	jal	ra,ffffffffc0200974 <intr_disable>
    if (0 < pid && pid < MAX_PID)
ffffffffc020425c:	6789                	lui	a5,0x2
ffffffffc020425e:	17f9                	addi	a5,a5,-2
ffffffffc0204260:	6522                	ld	a0,8(sp)
        return 1;
ffffffffc0204262:	4905                	li	s2,1
ffffffffc0204264:	f497fde3          	bgeu	a5,s1,ffffffffc02041be <do_kill+0x24>
        intr_enable();
ffffffffc0204268:	f06fc0ef          	jal	ra,ffffffffc020096e <intr_enable>
        return -E_INVAL;
ffffffffc020426c:	5575                	li	a0,-3
ffffffffc020426e:	bfbd                	j	ffffffffc02041ec <do_kill+0x52>
    if (p->state == PROC_SLEEPING) wakeup_proc(p);
ffffffffc0204270:	7a6000ef          	jal	ra,ffffffffc0204a16 <wakeup_proc>
ffffffffc0204274:	bf75                	j	ffffffffc0204230 <do_kill+0x96>

ffffffffc0204276 <do_execve>:
int do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0204276:	7135                	addi	sp,sp,-160
ffffffffc0204278:	e14a                	sd	s2,128(sp)
ffffffffc020427a:	892a                	mv	s2,a0
    cprintf("[DEBUG-2] entered do_execve\n");
ffffffffc020427c:	00002517          	auipc	a0,0x2
ffffffffc0204280:	42c50513          	addi	a0,a0,1068 # ffffffffc02066a8 <default_pmm_manager+0xb70>
int do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0204284:	e922                	sd	s0,144(sp)
ffffffffc0204286:	e526                	sd	s1,136(sp)
ffffffffc0204288:	fcce                	sd	s3,120(sp)
ffffffffc020428a:	ed06                	sd	ra,152(sp)
ffffffffc020428c:	f8d2                	sd	s4,112(sp)
ffffffffc020428e:	f4d6                	sd	s5,104(sp)
ffffffffc0204290:	f0da                	sd	s6,96(sp)
ffffffffc0204292:	ecde                	sd	s7,88(sp)
ffffffffc0204294:	e8e2                	sd	s8,80(sp)
ffffffffc0204296:	e4e6                	sd	s9,72(sp)
ffffffffc0204298:	e0ea                	sd	s10,64(sp)
ffffffffc020429a:	fc6e                	sd	s11,56(sp)
ffffffffc020429c:	842e                	mv	s0,a1
ffffffffc020429e:	84b2                	mv	s1,a2
ffffffffc02042a0:	89b6                	mv	s3,a3
ffffffffc02042a2:	ec36                	sd	a3,24(sp)
    cprintf("[DEBUG-2] entered do_execve\n");
ffffffffc02042a4:	ef1fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if (name == NULL || len == 0 || len > PROC_NAME_LEN || binary == NULL) return -E_INVAL;
ffffffffc02042a8:	44090763          	beqz	s2,ffffffffc02046f6 <do_execve+0x480>
ffffffffc02042ac:	fff40793          	addi	a5,s0,-1
ffffffffc02042b0:	4739                	li	a4,14
ffffffffc02042b2:	44f76263          	bltu	a4,a5,ffffffffc02046f6 <do_execve+0x480>
ffffffffc02042b6:	44048063          	beqz	s1,ffffffffc02046f6 <do_execve+0x480>
    if (current->mm != NULL) return -E_UNIMP;
ffffffffc02042ba:	000ac797          	auipc	a5,0xac
ffffffffc02042be:	45e78793          	addi	a5,a5,1118 # ffffffffc02b0718 <current>
ffffffffc02042c2:	639c                	ld	a5,0(a5)
ffffffffc02042c4:	779c                	ld	a5,40(a5)
ffffffffc02042c6:	42079663          	bnez	a5,ffffffffc02046f2 <do_execve+0x47c>
    memcpy(local_name, name, len);
ffffffffc02042ca:	8622                	mv	a2,s0
ffffffffc02042cc:	85ca                	mv	a1,s2
ffffffffc02042ce:	1008                	addi	a0,sp,32
ffffffffc02042d0:	5c5000ef          	jal	ra,ffffffffc0205094 <memcpy>
    local_name[len] = 0;
ffffffffc02042d4:	181c                	addi	a5,sp,48
ffffffffc02042d6:	943e                	add	s0,s0,a5
    cprintf("[DEBUG-3] entered load_icode\n");
ffffffffc02042d8:	00002517          	auipc	a0,0x2
ffffffffc02042dc:	3f050513          	addi	a0,a0,1008 # ffffffffc02066c8 <default_pmm_manager+0xb90>
    local_name[len] = 0;
ffffffffc02042e0:	fe040823          	sb	zero,-16(s0)
    cprintf("[DEBUG-3] entered load_icode\n");
ffffffffc02042e4:	eb1fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if (binary == NULL || size < sizeof(struct elfhdr)) return ret;
ffffffffc02042e8:	03f00793          	li	a5,63
ffffffffc02042ec:	4137f163          	bgeu	a5,s3,ffffffffc02046ee <do_execve+0x478>
    if (elf->e_magic != ELF_MAGIC || elf->e_phentsize != sizeof(struct proghdr) ||
ffffffffc02042f0:	4098                	lw	a4,0(s1)
ffffffffc02042f2:	464c47b7          	lui	a5,0x464c4
ffffffffc02042f6:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b8d17>
ffffffffc02042fa:	3ef71a63          	bne	a4,a5,ffffffffc02046ee <do_execve+0x478>
ffffffffc02042fe:	0364d703          	lhu	a4,54(s1)
ffffffffc0204302:	03800793          	li	a5,56
ffffffffc0204306:	3ef71463          	bne	a4,a5,ffffffffc02046ee <do_execve+0x478>
        elf->e_phoff > size || elf->e_phnum > (size - elf->e_phoff) / sizeof(struct proghdr))
ffffffffc020430a:	709c                	ld	a5,32(s1)
    if (elf->e_magic != ELF_MAGIC || elf->e_phentsize != sizeof(struct proghdr) ||
ffffffffc020430c:	3ef9e163          	bltu	s3,a5,ffffffffc02046ee <do_execve+0x478>
        elf->e_phoff > size || elf->e_phnum > (size - elf->e_phoff) / sizeof(struct proghdr))
ffffffffc0204310:	40f987b3          	sub	a5,s3,a5
ffffffffc0204314:	02e7d7b3          	divu	a5,a5,a4
ffffffffc0204318:	0384d603          	lhu	a2,56(s1)
ffffffffc020431c:	3cc7e963          	bltu	a5,a2,ffffffffc02046ee <do_execve+0x478>
    cprintf("[STAGE-1] ELF header validated, entry=0x%lx, phnum=%d\\n",
ffffffffc0204320:	6c8c                	ld	a1,24(s1)
ffffffffc0204322:	00002517          	auipc	a0,0x2
ffffffffc0204326:	3c650513          	addi	a0,a0,966 # ffffffffc02066e8 <default_pmm_manager+0xbb0>
ffffffffc020432a:	e6bfb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("[STAGE-2] before mm_create\\n");
ffffffffc020432e:	00002517          	auipc	a0,0x2
ffffffffc0204332:	3f250513          	addi	a0,a0,1010 # ffffffffc0206720 <default_pmm_manager+0xbe8>
ffffffffc0204336:	e5ffb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    struct mm_struct *mm = mm_create();
ffffffffc020433a:	e25fe0ef          	jal	ra,ffffffffc020315e <mm_create>
ffffffffc020433e:	892a                	mv	s2,a0
    if (mm == NULL) return -E_NO_MEM;
ffffffffc0204340:	3a050d63          	beqz	a0,ffffffffc02046fa <do_execve+0x484>
    cprintf("[STAGE-3] mm_create completed: mm=%p\\n", mm);
ffffffffc0204344:	85aa                	mv	a1,a0
ffffffffc0204346:	00002517          	auipc	a0,0x2
ffffffffc020434a:	3fa50513          	addi	a0,a0,1018 # ffffffffc0206740 <default_pmm_manager+0xc08>
ffffffffc020434e:	e47fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("[STAGE-4] before setup_pgdir\\n");
ffffffffc0204352:	00002517          	auipc	a0,0x2
ffffffffc0204356:	41650513          	addi	a0,a0,1046 # ffffffffc0206768 <default_pmm_manager+0xc30>
ffffffffc020435a:	e3bfb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if ((page = alloc_page()) == NULL)
ffffffffc020435e:	4505                	li	a0,1
ffffffffc0204360:	d8cfd0ef          	jal	ra,ffffffffc02018ec <alloc_pages>
ffffffffc0204364:	38050d63          	beqz	a0,ffffffffc02046fe <do_execve+0x488>
    return page - pages + nbase;
ffffffffc0204368:	000acc97          	auipc	s9,0xac
ffffffffc020436c:	398c8c93          	addi	s9,s9,920 # ffffffffc02b0700 <pages>
ffffffffc0204370:	000cb683          	ld	a3,0(s9)
ffffffffc0204374:	00003717          	auipc	a4,0x3
ffffffffc0204378:	c0c73703          	ld	a4,-1012(a4) # ffffffffc0206f80 <nbase>
    return KADDR(page2pa(page));
ffffffffc020437c:	000acd17          	auipc	s10,0xac
ffffffffc0204380:	37cd0d13          	addi	s10,s10,892 # ffffffffc02b06f8 <npage>
    return page - pages + nbase;
ffffffffc0204384:	40d506b3          	sub	a3,a0,a3
ffffffffc0204388:	8699                	srai	a3,a3,0x6
ffffffffc020438a:	96ba                	add	a3,a3,a4
ffffffffc020438c:	e43a                	sd	a4,8(sp)
    return KADDR(page2pa(page));
ffffffffc020438e:	000d3783          	ld	a5,0(s10)
ffffffffc0204392:	577d                	li	a4,-1
ffffffffc0204394:	8331                	srli	a4,a4,0xc
ffffffffc0204396:	e83a                	sd	a4,16(sp)
ffffffffc0204398:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020439a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020439c:	20f77563          	bgeu	a4,a5,ffffffffc02045a6 <do_execve+0x330>
ffffffffc02043a0:	000acc17          	auipc	s8,0xac
ffffffffc02043a4:	370c0c13          	addi	s8,s8,880 # ffffffffc02b0710 <va_pa_offset>
ffffffffc02043a8:	000c3403          	ld	s0,0(s8)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc02043ac:	6605                	lui	a2,0x1
ffffffffc02043ae:	000ac597          	auipc	a1,0xac
ffffffffc02043b2:	3425b583          	ld	a1,834(a1) # ffffffffc02b06f0 <boot_pgdir_va>
ffffffffc02043b6:	9436                	add	s0,s0,a3
ffffffffc02043b8:	8522                	mv	a0,s0
ffffffffc02043ba:	4db000ef          	jal	ra,ffffffffc0205094 <memcpy>
    cprintf("[STAGE-5] setup_pgdir completed: pgdir=%p\\n", mm->pgdir);
ffffffffc02043be:	85a2                	mv	a1,s0
    mm->pgdir = pgdir;
ffffffffc02043c0:	00893c23          	sd	s0,24(s2)
    cprintf("[STAGE-5] setup_pgdir completed: pgdir=%p\\n", mm->pgdir);
ffffffffc02043c4:	00002517          	auipc	a0,0x2
ffffffffc02043c8:	3c450513          	addi	a0,a0,964 # ffffffffc0206788 <default_pmm_manager+0xc50>
ffffffffc02043cc:	dc9fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    for (size_t i = 0; i < elf->e_phnum; i++) {
ffffffffc02043d0:	0384d783          	lhu	a5,56(s1)
ffffffffc02043d4:	22078363          	beqz	a5,ffffffffc02045fa <do_execve+0x384>
        uintptr_t end = ROUNDUP(ph->p_va + ph->p_memsz, PGSIZE);
ffffffffc02043d8:	6a85                	lui	s5,0x1
    for (size_t i = 0; i < elf->e_phnum; i++) {
ffffffffc02043da:	4b01                	li	s6,0
ffffffffc02043dc:	4981                	li	s3,0
            cprintf("[STAGE-11] allocating va=0x%lx\\n", va);
ffffffffc02043de:	00002b97          	auipc	s7,0x2
ffffffffc02043e2:	4a2b8b93          	addi	s7,s7,1186 # ffffffffc0206880 <default_pmm_manager+0xd48>
ffffffffc02043e6:	a801                	j	ffffffffc02043f6 <do_execve+0x180>
    for (size_t i = 0; i < elf->e_phnum; i++) {
ffffffffc02043e8:	0384d783          	lhu	a5,56(s1)
ffffffffc02043ec:	0985                	addi	s3,s3,1
ffffffffc02043ee:	038b0b13          	addi	s6,s6,56
ffffffffc02043f2:	20f9f463          	bgeu	s3,a5,ffffffffc02045fa <do_execve+0x384>
        struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff + i * sizeof(struct proghdr));
ffffffffc02043f6:	7080                	ld	s0,32(s1)
        cprintf("[STAGE-6] program header %d, type=%d\\n",
ffffffffc02043f8:	0009859b          	sext.w	a1,s3
ffffffffc02043fc:	00002517          	auipc	a0,0x2
ffffffffc0204400:	3bc50513          	addi	a0,a0,956 # ffffffffc02067b8 <default_pmm_manager+0xc80>
        struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff + i * sizeof(struct proghdr));
ffffffffc0204404:	945a                	add	s0,s0,s6
ffffffffc0204406:	9426                	add	s0,s0,s1
        cprintf("[STAGE-6] program header %d, type=%d\\n",
ffffffffc0204408:	4010                	lw	a2,0(s0)
ffffffffc020440a:	d8bfb0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if (ph->p_type != ELF_PT_LOAD) continue;
ffffffffc020440e:	401c                	lw	a5,0(s0)
ffffffffc0204410:	4705                	li	a4,1
ffffffffc0204412:	fce79be3          	bne	a5,a4,ffffffffc02043e8 <do_execve+0x172>
        cprintf("[STAGE-7] LOAD: va=0x%lx filesz=%lu memsz=%lu\\n",
ffffffffc0204416:	7414                	ld	a3,40(s0)
ffffffffc0204418:	7010                	ld	a2,32(s0)
ffffffffc020441a:	680c                	ld	a1,16(s0)
ffffffffc020441c:	00002517          	auipc	a0,0x2
ffffffffc0204420:	3c450513          	addi	a0,a0,964 # ffffffffc02067e0 <default_pmm_manager+0xca8>
ffffffffc0204424:	d71fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if (ph->p_filesz > ph->p_memsz || ph->p_offset > size || ph->p_filesz > size - ph->p_offset ||
ffffffffc0204428:	7014                	ld	a3,32(s0)
ffffffffc020442a:	741c                	ld	a5,40(s0)
ffffffffc020442c:	18d7e963          	bltu	a5,a3,ffffffffc02045be <do_execve+0x348>
ffffffffc0204430:	6418                	ld	a4,8(s0)
ffffffffc0204432:	6662                	ld	a2,24(sp)
ffffffffc0204434:	18e66563          	bltu	a2,a4,ffffffffc02045be <do_execve+0x348>
ffffffffc0204438:	40e60733          	sub	a4,a2,a4
ffffffffc020443c:	18d76163          	bltu	a4,a3,ffffffffc02045be <do_execve+0x348>
ffffffffc0204440:	16078f63          	beqz	a5,ffffffffc02045be <do_execve+0x348>
            ph->p_memsz == 0 || ph->p_va + ph->p_memsz < ph->p_va ||
ffffffffc0204444:	6818                	ld	a4,16(s0)
ffffffffc0204446:	97ba                	add	a5,a5,a4
ffffffffc0204448:	16e7eb63          	bltu	a5,a4,ffffffffc02045be <do_execve+0x348>
ffffffffc020444c:	002006b7          	lui	a3,0x200
ffffffffc0204450:	16d76763          	bltu	a4,a3,ffffffffc02045be <do_execve+0x348>
            !USER_ACCESS(ph->p_va, ph->p_va + ph->p_memsz)) { ret = -E_INVAL_ELF; goto bad; }
ffffffffc0204454:	16f70563          	beq	a4,a5,ffffffffc02045be <do_execve+0x348>
ffffffffc0204458:	4705                	li	a4,1
ffffffffc020445a:	077e                	slli	a4,a4,0x1f
ffffffffc020445c:	16f76163          	bltu	a4,a5,ffffffffc02045be <do_execve+0x348>
        if (ph->p_flags & ELF_PF_R) flags |= VM_READ;
ffffffffc0204460:	405c                	lw	a5,4(s0)
ffffffffc0204462:	4027da1b          	sraiw	s4,a5,0x2
        if (ph->p_flags & ELF_PF_W) flags |= VM_WRITE;
ffffffffc0204466:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) flags |= VM_READ;
ffffffffc020446a:	001a7a13          	andi	s4,s4,1
        if (ph->p_flags & ELF_PF_W) flags |= VM_WRITE;
ffffffffc020446e:	c319                	beqz	a4,ffffffffc0204474 <do_execve+0x1fe>
ffffffffc0204470:	002a6a13          	ori	s4,s4,2
        if (ph->p_flags & ELF_PF_X) flags |= VM_EXEC;
ffffffffc0204474:	8b85                	andi	a5,a5,1
ffffffffc0204476:	c399                	beqz	a5,ffffffffc020447c <do_execve+0x206>
ffffffffc0204478:	004a6a13          	ori	s4,s4,4
        cprintf("[STAGE-8] before mm_map\\n");
ffffffffc020447c:	00002517          	auipc	a0,0x2
ffffffffc0204480:	39450513          	addi	a0,a0,916 # ffffffffc0206810 <default_pmm_manager+0xcd8>
ffffffffc0204484:	d11fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, flags, NULL)) != 0) goto bad;
ffffffffc0204488:	7410                	ld	a2,40(s0)
ffffffffc020448a:	680c                	ld	a1,16(s0)
ffffffffc020448c:	86d2                	mv	a3,s4
ffffffffc020448e:	4701                	li	a4,0
ffffffffc0204490:	854a                	mv	a0,s2
ffffffffc0204492:	e5ffe0ef          	jal	ra,ffffffffc02032f0 <mm_map>
ffffffffc0204496:	8a2a                	mv	s4,a0
ffffffffc0204498:	12051463          	bnez	a0,ffffffffc02045c0 <do_execve+0x34a>
        cprintf("[STAGE-9] mm_map completed\\n");
ffffffffc020449c:	00002517          	auipc	a0,0x2
ffffffffc02044a0:	39450513          	addi	a0,a0,916 # ffffffffc0206830 <default_pmm_manager+0xcf8>
ffffffffc02044a4:	cf1fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
        uintptr_t start = ROUNDDOWN(ph->p_va, PGSIZE);
ffffffffc02044a8:	6818                	ld	a4,16(s0)
        uintptr_t end = ROUNDUP(ph->p_va + ph->p_memsz, PGSIZE);
ffffffffc02044aa:	02843a03          	ld	s4,40(s0)
ffffffffc02044ae:	6785                	lui	a5,0x1
ffffffffc02044b0:	17fd                	addi	a5,a5,-1
ffffffffc02044b2:	9a3a                	add	s4,s4,a4
        uintptr_t start = ROUNDDOWN(ph->p_va, PGSIZE);
ffffffffc02044b4:	76fd                	lui	a3,0xfffff
        uintptr_t end = ROUNDUP(ph->p_va + ph->p_memsz, PGSIZE);
ffffffffc02044b6:	9a3e                	add	s4,s4,a5
        uintptr_t start = ROUNDDOWN(ph->p_va, PGSIZE);
ffffffffc02044b8:	00d77db3          	and	s11,a4,a3
        uintptr_t end = ROUNDUP(ph->p_va + ph->p_memsz, PGSIZE);
ffffffffc02044bc:	00da7a33          	and	s4,s4,a3
        cprintf("[STAGE-10] before allocating LOAD pages\\n");
ffffffffc02044c0:	00002517          	auipc	a0,0x2
ffffffffc02044c4:	39050513          	addi	a0,a0,912 # ffffffffc0206850 <default_pmm_manager+0xd18>
ffffffffc02044c8:	ccdfb0ef          	jal	ra,ffffffffc0200194 <cprintf>
        for (uintptr_t va = start; va < end; va += PGSIZE) {
ffffffffc02044cc:	014de663          	bltu	s11,s4,ffffffffc02044d8 <do_execve+0x262>
ffffffffc02044d0:	a8b9                	j	ffffffffc020452e <do_execve+0x2b8>
ffffffffc02044d2:	9dd6                	add	s11,s11,s5
ffffffffc02044d4:	054dfd63          	bgeu	s11,s4,ffffffffc020452e <do_execve+0x2b8>
            cprintf("[STAGE-11] allocating va=0x%lx\\n", va);
ffffffffc02044d8:	85ee                	mv	a1,s11
ffffffffc02044da:	855e                	mv	a0,s7
ffffffffc02044dc:	cb9fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
            struct Page *page = get_page(mm->pgdir, va, NULL);
ffffffffc02044e0:	01893503          	ld	a0,24(s2)
ffffffffc02044e4:	4601                	li	a2,0
ffffffffc02044e6:	85ee                	mv	a1,s11
ffffffffc02044e8:	eaafd0ef          	jal	ra,ffffffffc0201b92 <get_page>
            if (page == NULL) {
ffffffffc02044ec:	f17d                	bnez	a0,ffffffffc02044d2 <do_execve+0x25c>
                page = pgdir_alloc_page(mm->pgdir, va, PTE_U | PTE_R | PTE_W | PTE_X);
ffffffffc02044ee:	01893503          	ld	a0,24(s2)
ffffffffc02044f2:	4679                	li	a2,30
ffffffffc02044f4:	85ee                	mv	a1,s11
ffffffffc02044f6:	b73fe0ef          	jal	ra,ffffffffc0203068 <pgdir_alloc_page>
                if (page == NULL) { ret = -E_NO_MEM; goto bad; }
ffffffffc02044fa:	0e050e63          	beqz	a0,ffffffffc02045f6 <do_execve+0x380>
    return page - pages + nbase;
ffffffffc02044fe:	000cb683          	ld	a3,0(s9)
ffffffffc0204502:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc0204504:	000d3703          	ld	a4,0(s10)
    return page - pages + nbase;
ffffffffc0204508:	8d15                	sub	a0,a0,a3
ffffffffc020450a:	8519                	srai	a0,a0,0x6
ffffffffc020450c:	953e                	add	a0,a0,a5
    return KADDR(page2pa(page));
ffffffffc020450e:	67c2                	ld	a5,16(sp)
ffffffffc0204510:	00f576b3          	and	a3,a0,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204514:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0204516:	1ee6f963          	bgeu	a3,a4,ffffffffc0204708 <do_execve+0x492>
ffffffffc020451a:	000c3703          	ld	a4,0(s8)
                memset(page2kva(page), 0, PGSIZE);
ffffffffc020451e:	6605                	lui	a2,0x1
ffffffffc0204520:	4581                	li	a1,0
ffffffffc0204522:	953a                	add	a0,a0,a4
        for (uintptr_t va = start; va < end; va += PGSIZE) {
ffffffffc0204524:	9dd6                	add	s11,s11,s5
                memset(page2kva(page), 0, PGSIZE);
ffffffffc0204526:	35d000ef          	jal	ra,ffffffffc0205082 <memset>
        for (uintptr_t va = start; va < end; va += PGSIZE) {
ffffffffc020452a:	fb4de7e3          	bltu	s11,s4,ffffffffc02044d8 <do_execve+0x262>
        cprintf("[STAGE-12] LOAD pages allocated\\n");
ffffffffc020452e:	00002517          	auipc	a0,0x2
ffffffffc0204532:	37a50513          	addi	a0,a0,890 # ffffffffc02068a8 <default_pmm_manager+0xd70>
ffffffffc0204536:	c5ffb0ef          	jal	ra,ffffffffc0200194 <cprintf>
        for (size_t pos = 0; pos < ph->p_filesz;) {
ffffffffc020453a:	7018                	ld	a4,32(s0)
ffffffffc020453c:	ea0706e3          	beqz	a4,ffffffffc02043e8 <do_execve+0x172>
ffffffffc0204540:	4a01                	li	s4,0
ffffffffc0204542:	a839                	j	ffffffffc0204560 <do_execve+0x2ea>
            memcpy((char *)page2kva(pg) + PGOFF(va), binary + ph->p_offset + pos, n);
ffffffffc0204544:	640c                	ld	a1,8(s0)
ffffffffc0204546:	000c3503          	ld	a0,0(s8)
ffffffffc020454a:	866e                	mv	a2,s11
ffffffffc020454c:	95d2                	add	a1,a1,s4
ffffffffc020454e:	9536                	add	a0,a0,a3
ffffffffc0204550:	953a                	add	a0,a0,a4
ffffffffc0204552:	95a6                	add	a1,a1,s1
ffffffffc0204554:	341000ef          	jal	ra,ffffffffc0205094 <memcpy>
        for (size_t pos = 0; pos < ph->p_filesz;) {
ffffffffc0204558:	7018                	ld	a4,32(s0)
            pos += n;
ffffffffc020455a:	9a6e                	add	s4,s4,s11
        for (size_t pos = 0; pos < ph->p_filesz;) {
ffffffffc020455c:	e8ea76e3          	bgeu	s4,a4,ffffffffc02043e8 <do_execve+0x172>
            uintptr_t va = ph->p_va + pos;
ffffffffc0204560:	680c                	ld	a1,16(s0)
            size_t n = PGSIZE - PGOFF(va);
ffffffffc0204562:	6785                	lui	a5,0x1
ffffffffc0204564:	17fd                	addi	a5,a5,-1
            uintptr_t va = ph->p_va + pos;
ffffffffc0204566:	95d2                	add	a1,a1,s4
            if (n > ph->p_filesz - pos) n = ph->p_filesz - pos;
ffffffffc0204568:	41470db3          	sub	s11,a4,s4
            size_t n = PGSIZE - PGOFF(va);
ffffffffc020456c:	00f5f733          	and	a4,a1,a5
ffffffffc0204570:	40ea86b3          	sub	a3,s5,a4
            if (n > ph->p_filesz - pos) n = ph->p_filesz - pos;
ffffffffc0204574:	01b6f363          	bgeu	a3,s11,ffffffffc020457a <do_execve+0x304>
ffffffffc0204578:	8db6                	mv	s11,a3
            struct Page *pg = get_page(mm->pgdir, va, NULL);
ffffffffc020457a:	01893503          	ld	a0,24(s2)
ffffffffc020457e:	4601                	li	a2,0
ffffffffc0204580:	e03a                	sd	a4,0(sp)
ffffffffc0204582:	e10fd0ef          	jal	ra,ffffffffc0201b92 <get_page>
    return page - pages + nbase;
ffffffffc0204586:	000cb683          	ld	a3,0(s9)
ffffffffc020458a:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc020458c:	000d3603          	ld	a2,0(s10)
    return page - pages + nbase;
ffffffffc0204590:	40d506b3          	sub	a3,a0,a3
ffffffffc0204594:	8699                	srai	a3,a3,0x6
ffffffffc0204596:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204598:	67c2                	ld	a5,16(sp)
ffffffffc020459a:	6702                	ld	a4,0(sp)
ffffffffc020459c:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02045a0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02045a2:	fac5e1e3          	bltu	a1,a2,ffffffffc0204544 <do_execve+0x2ce>
ffffffffc02045a6:	00001617          	auipc	a2,0x1
ffffffffc02045aa:	5ca60613          	addi	a2,a2,1482 # ffffffffc0205b70 <default_pmm_manager+0x38>
ffffffffc02045ae:	07100593          	li	a1,113
ffffffffc02045b2:	00001517          	auipc	a0,0x1
ffffffffc02045b6:	5e650513          	addi	a0,a0,1510 # ffffffffc0205b98 <default_pmm_manager+0x60>
ffffffffc02045ba:	e95fb0ef          	jal	ra,ffffffffc020044e <__panic>
            !USER_ACCESS(ph->p_va, ph->p_va + ph->p_memsz)) { ret = -E_INVAL_ELF; goto bad; }
ffffffffc02045be:	5a61                	li	s4,-8
    exit_mmap(mm);
ffffffffc02045c0:	854a                	mv	a0,s2
    mm->mm_count = val;
ffffffffc02045c2:	02092823          	sw	zero,48(s2)
ffffffffc02045c6:	ec7fe0ef          	jal	ra,ffffffffc020348c <exit_mmap>
    put_pgdir(mm);
ffffffffc02045ca:	854a                	mv	a0,s2
ffffffffc02045cc:	b7cff0ef          	jal	ra,ffffffffc0203948 <put_pgdir>
    mm_destroy(mm);
ffffffffc02045d0:	854a                	mv	a0,s2
ffffffffc02045d2:	ccdfe0ef          	jal	ra,ffffffffc020329e <mm_destroy>
}
ffffffffc02045d6:	60ea                	ld	ra,152(sp)
ffffffffc02045d8:	644a                	ld	s0,144(sp)
ffffffffc02045da:	64aa                	ld	s1,136(sp)
ffffffffc02045dc:	690a                	ld	s2,128(sp)
ffffffffc02045de:	79e6                	ld	s3,120(sp)
ffffffffc02045e0:	7aa6                	ld	s5,104(sp)
ffffffffc02045e2:	7b06                	ld	s6,96(sp)
ffffffffc02045e4:	6be6                	ld	s7,88(sp)
ffffffffc02045e6:	6c46                	ld	s8,80(sp)
ffffffffc02045e8:	6ca6                	ld	s9,72(sp)
ffffffffc02045ea:	6d06                	ld	s10,64(sp)
ffffffffc02045ec:	7de2                	ld	s11,56(sp)
ffffffffc02045ee:	8552                	mv	a0,s4
ffffffffc02045f0:	7a46                	ld	s4,112(sp)
ffffffffc02045f2:	610d                	addi	sp,sp,160
ffffffffc02045f4:	8082                	ret
                if (page == NULL) { ret = -E_NO_MEM; goto bad; }
ffffffffc02045f6:	5a71                	li	s4,-4
ffffffffc02045f8:	b7e1                	j	ffffffffc02045c0 <do_execve+0x34a>
    cprintf("[STAGE-13] ELF content copied\\n");
ffffffffc02045fa:	00002517          	auipc	a0,0x2
ffffffffc02045fe:	2d650513          	addi	a0,a0,726 # ffffffffc02068d0 <default_pmm_manager+0xd98>
ffffffffc0204602:	b93fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("[STAGE-14] before mapping user stack\\n");
ffffffffc0204606:	00002517          	auipc	a0,0x2
ffffffffc020460a:	2ea50513          	addi	a0,a0,746 # ffffffffc02068f0 <default_pmm_manager+0xdb8>
ffffffffc020460e:	b87fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE,
ffffffffc0204612:	4701                	li	a4,0
ffffffffc0204614:	46ad                	li	a3,11
ffffffffc0204616:	00100637          	lui	a2,0x100
ffffffffc020461a:	7ff005b7          	lui	a1,0x7ff00
ffffffffc020461e:	854a                	mv	a0,s2
ffffffffc0204620:	cd1fe0ef          	jal	ra,ffffffffc02032f0 <mm_map>
ffffffffc0204624:	8a2a                	mv	s4,a0
ffffffffc0204626:	fd49                	bnez	a0,ffffffffc02045c0 <do_execve+0x34a>
ffffffffc0204628:	59fd                	li	s3,-1
    for (uintptr_t va = USTACKTOP - 4 * PGSIZE; va < USTACKTOP; va += PGSIZE) {
ffffffffc020462a:	4405                	li	s0,1
ffffffffc020462c:	7fffcab7          	lui	s5,0x7fffc
ffffffffc0204630:	00c9d993          	srli	s3,s3,0xc
ffffffffc0204634:	047e                	slli	s0,s0,0x1f
        struct Page *page = pgdir_alloc_page(mm->pgdir, va, PTE_U | PTE_R | PTE_W);
ffffffffc0204636:	01893503          	ld	a0,24(s2)
ffffffffc020463a:	4659                	li	a2,22
ffffffffc020463c:	85d6                	mv	a1,s5
ffffffffc020463e:	a2bfe0ef          	jal	ra,ffffffffc0203068 <pgdir_alloc_page>
        if (page == NULL) { ret = -E_NO_MEM; goto bad; }
ffffffffc0204642:	d955                	beqz	a0,ffffffffc02045f6 <do_execve+0x380>
    return page - pages + nbase;
ffffffffc0204644:	000cb683          	ld	a3,0(s9)
ffffffffc0204648:	6722                	ld	a4,8(sp)
    return KADDR(page2pa(page));
ffffffffc020464a:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc020464e:	40d506b3          	sub	a3,a0,a3
ffffffffc0204652:	8699                	srai	a3,a3,0x6
ffffffffc0204654:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0204656:	0136f733          	and	a4,a3,s3
    return page2ppn(page) << PGSHIFT;
ffffffffc020465a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020465c:	f4f775e3          	bgeu	a4,a5,ffffffffc02045a6 <do_execve+0x330>
ffffffffc0204660:	000c3503          	ld	a0,0(s8)
        memset(page2kva(page), 0, PGSIZE);
ffffffffc0204664:	6605                	lui	a2,0x1
ffffffffc0204666:	4581                	li	a1,0
ffffffffc0204668:	9536                	add	a0,a0,a3
ffffffffc020466a:	219000ef          	jal	ra,ffffffffc0205082 <memset>
    for (uintptr_t va = USTACKTOP - 4 * PGSIZE; va < USTACKTOP; va += PGSIZE) {
ffffffffc020466e:	6785                	lui	a5,0x1
ffffffffc0204670:	9abe                	add	s5,s5,a5
ffffffffc0204672:	fc8a92e3          	bne	s5,s0,ffffffffc0204636 <do_execve+0x3c0>
    current->mm = mm;
ffffffffc0204676:	000ac797          	auipc	a5,0xac
ffffffffc020467a:	0a278793          	addi	a5,a5,162 # ffffffffc02b0718 <current>
    mm->mm_count += 1;
ffffffffc020467e:	03092703          	lw	a4,48(s2)
ffffffffc0204682:	639c                	ld	a5,0(a5)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204684:	01893683          	ld	a3,24(s2)
ffffffffc0204688:	2705                	addiw	a4,a4,1
    current->mm = mm;
ffffffffc020468a:	0327b423          	sd	s2,40(a5)
ffffffffc020468e:	02e92823          	sw	a4,48(s2)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204692:	c0200737          	lui	a4,0xc0200
ffffffffc0204696:	06e6eb63          	bltu	a3,a4,ffffffffc020470c <do_execve+0x496>
ffffffffc020469a:	000c3703          	ld	a4,0(s8)
    memset(current->tf, 0, sizeof(struct trapframe));
ffffffffc020469e:	73c8                	ld	a0,160(a5)
ffffffffc02046a0:	12000613          	li	a2,288
    current->pgdir = PADDR(mm->pgdir);
ffffffffc02046a4:	8e99                	sub	a3,a3,a4
ffffffffc02046a6:	f7d4                	sd	a3,168(a5)
    memset(current->tf, 0, sizeof(struct trapframe));
ffffffffc02046a8:	4581                	li	a1,0
ffffffffc02046aa:	1d9000ef          	jal	ra,ffffffffc0205082 <memset>
    current->tf->gpr.sp = USTACKTOP;
ffffffffc02046ae:	000ac797          	auipc	a5,0xac
ffffffffc02046b2:	06a78793          	addi	a5,a5,106 # ffffffffc02b0718 <current>
ffffffffc02046b6:	6380                	ld	s0,0(a5)
    current->tf->epc = elf->e_entry;
ffffffffc02046b8:	6c9c                	ld	a5,24(s1)
    current->tf->gpr.sp = USTACKTOP;
ffffffffc02046ba:	7058                	ld	a4,160(s0)
ffffffffc02046bc:	01573823          	sd	s5,16(a4) # ffffffffc0200010 <kern_entry+0x10>
    current->tf->epc = elf->e_entry;
ffffffffc02046c0:	10f73423          	sd	a5,264(a4)
    current->tf->status = (read_csr(sstatus) | SSTATUS_SPIE) & ~(SSTATUS_SPP | SSTATUS_SIE);
ffffffffc02046c4:	100027f3          	csrr	a5,sstatus
ffffffffc02046c8:	edd7f793          	andi	a5,a5,-291
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02046cc:	0b440413          	addi	s0,s0,180
    current->tf->status = (read_csr(sstatus) | SSTATUS_SPIE) & ~(SSTATUS_SPP | SSTATUS_SIE);
ffffffffc02046d0:	0207e793          	ori	a5,a5,32
ffffffffc02046d4:	10f73023          	sd	a5,256(a4)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02046d8:	4641                	li	a2,16
ffffffffc02046da:	4581                	li	a1,0
ffffffffc02046dc:	8522                	mv	a0,s0
ffffffffc02046de:	1a5000ef          	jal	ra,ffffffffc0205082 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02046e2:	463d                	li	a2,15
ffffffffc02046e4:	100c                	addi	a1,sp,32
ffffffffc02046e6:	8522                	mv	a0,s0
ffffffffc02046e8:	1ad000ef          	jal	ra,ffffffffc0205094 <memcpy>
ffffffffc02046ec:	b5ed                	j	ffffffffc02045d6 <do_execve+0x360>
    if (binary == NULL || size < sizeof(struct elfhdr)) return ret;
ffffffffc02046ee:	5a61                	li	s4,-8
ffffffffc02046f0:	b5dd                	j	ffffffffc02045d6 <do_execve+0x360>
    if (current->mm != NULL) return -E_UNIMP;
ffffffffc02046f2:	5a31                	li	s4,-20
ffffffffc02046f4:	b5cd                	j	ffffffffc02045d6 <do_execve+0x360>
    if (name == NULL || len == 0 || len > PROC_NAME_LEN || binary == NULL) return -E_INVAL;
ffffffffc02046f6:	5a75                	li	s4,-3
ffffffffc02046f8:	bdf9                	j	ffffffffc02045d6 <do_execve+0x360>
    if (mm == NULL) return -E_NO_MEM;
ffffffffc02046fa:	5a71                	li	s4,-4
ffffffffc02046fc:	bde9                	j	ffffffffc02045d6 <do_execve+0x360>
    if ((ret = setup_pgdir(mm)) != 0) { mm_destroy(mm); return ret; }
ffffffffc02046fe:	854a                	mv	a0,s2
ffffffffc0204700:	b9ffe0ef          	jal	ra,ffffffffc020329e <mm_destroy>
        return -E_NO_MEM;
ffffffffc0204704:	5a71                	li	s4,-4
    if ((ret = setup_pgdir(mm)) != 0) { mm_destroy(mm); return ret; }
ffffffffc0204706:	bdc1                	j	ffffffffc02045d6 <do_execve+0x360>
ffffffffc0204708:	86aa                	mv	a3,a0
ffffffffc020470a:	bd71                	j	ffffffffc02045a6 <do_execve+0x330>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc020470c:	00001617          	auipc	a2,0x1
ffffffffc0204710:	50c60613          	addi	a2,a2,1292 # ffffffffc0205c18 <default_pmm_manager+0xe0>
ffffffffc0204714:	25400593          	li	a1,596
ffffffffc0204718:	00002517          	auipc	a0,0x2
ffffffffc020471c:	ef850513          	addi	a0,a0,-264 # ffffffffc0206610 <default_pmm_manager+0xad8>
ffffffffc0204720:	d2ffb0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0204724 <user_main>:
static int user_main(void *arg) {
ffffffffc0204724:	1101                	addi	sp,sp,-32
ffffffffc0204726:	e426                	sd	s1,8(sp)
    int ret = KERNEL_EXECVE(waitkill);
ffffffffc0204728:	000ac497          	auipc	s1,0xac
ffffffffc020472c:	ff048493          	addi	s1,s1,-16 # ffffffffc02b0718 <current>
ffffffffc0204730:	609c                	ld	a5,0(s1)
ffffffffc0204732:	00002617          	auipc	a2,0x2
ffffffffc0204736:	1e660613          	addi	a2,a2,486 # ffffffffc0206918 <default_pmm_manager+0xde0>
ffffffffc020473a:	00002517          	auipc	a0,0x2
ffffffffc020473e:	1ee50513          	addi	a0,a0,494 # ffffffffc0206928 <default_pmm_manager+0xdf0>
ffffffffc0204742:	43cc                	lw	a1,4(a5)
static int user_main(void *arg) {
ffffffffc0204744:	ec06                	sd	ra,24(sp)
ffffffffc0204746:	e822                	sd	s0,16(sp)
    int ret = KERNEL_EXECVE(waitkill);
ffffffffc0204748:	a4dfb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("\n[DEBUG-1] entered kernel_execve\n");
ffffffffc020474c:	00002517          	auipc	a0,0x2
ffffffffc0204750:	20450513          	addi	a0,a0,516 # ffffffffc0206950 <default_pmm_manager+0xe18>
ffffffffc0204754:	a41fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    int ret = do_execve(name, strlen(name), binary, size);
ffffffffc0204758:	00002517          	auipc	a0,0x2
ffffffffc020475c:	1c050513          	addi	a0,a0,448 # ffffffffc0206918 <default_pmm_manager+0xde0>
ffffffffc0204760:	081000ef          	jal	ra,ffffffffc0204fe0 <strlen>
ffffffffc0204764:	85aa                	mv	a1,a0
ffffffffc0204766:	3fe07697          	auipc	a3,0x3fe07
ffffffffc020476a:	07a68693          	addi	a3,a3,122 # b7e0 <_binary_obj___user_waitkill_out_size>
ffffffffc020476e:	00092617          	auipc	a2,0x92
ffffffffc0204772:	c4a60613          	addi	a2,a2,-950 # ffffffffc02963b8 <_binary_obj___user_waitkill_out_start>
ffffffffc0204776:	00002517          	auipc	a0,0x2
ffffffffc020477a:	1a250513          	addi	a0,a0,418 # ffffffffc0206918 <default_pmm_manager+0xde0>
ffffffffc020477e:	af9ff0ef          	jal	ra,ffffffffc0204276 <do_execve>
ffffffffc0204782:	842a                	mv	s0,a0
    cprintf("\n========== BEFORE SATP DEBUG ==========\n");
ffffffffc0204784:	00002517          	auipc	a0,0x2
ffffffffc0204788:	1f450513          	addi	a0,a0,500 # ffffffffc0206978 <default_pmm_manager+0xe40>
ffffffffc020478c:	a09fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("ret    = %d\n", ret);
ffffffffc0204790:	85a2                	mv	a1,s0
ffffffffc0204792:	00002517          	auipc	a0,0x2
ffffffffc0204796:	21650513          	addi	a0,a0,534 # ffffffffc02069a8 <default_pmm_manager+0xe70>
ffffffffc020479a:	9fbfb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if (ret == 0) {
ffffffffc020479e:	c40d                	beqz	s0,ffffffffc02047c8 <user_main+0xa4>
    cprintf("kernel_execve failed: %d\n", ret);
ffffffffc02047a0:	85a2                	mv	a1,s0
ffffffffc02047a2:	00002517          	auipc	a0,0x2
ffffffffc02047a6:	2be50513          	addi	a0,a0,702 # ffffffffc0206a60 <default_pmm_manager+0xf28>
ffffffffc02047aa:	9ebfb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    panic("kernel_execve failed: %d", ret);
ffffffffc02047ae:	86a2                	mv	a3,s0
ffffffffc02047b0:	00002617          	auipc	a2,0x2
ffffffffc02047b4:	2d060613          	addi	a2,a2,720 # ffffffffc0206a80 <default_pmm_manager+0xf48>
ffffffffc02047b8:	2a400593          	li	a1,676
ffffffffc02047bc:	00002517          	auipc	a0,0x2
ffffffffc02047c0:	e5450513          	addi	a0,a0,-428 # ffffffffc0206610 <default_pmm_manager+0xad8>
ffffffffc02047c4:	c8bfb0ef          	jal	ra,ffffffffc020044e <__panic>
        cprintf("current = %p\n", current);
ffffffffc02047c8:	608c                	ld	a1,0(s1)
ffffffffc02047ca:	00002517          	auipc	a0,0x2
ffffffffc02047ce:	1ee50513          	addi	a0,a0,494 # ffffffffc02069b8 <default_pmm_manager+0xe80>
ffffffffc02047d2:	9c3fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("tf      = %p\n", current->tf);
ffffffffc02047d6:	609c                	ld	a5,0(s1)
ffffffffc02047d8:	00002517          	auipc	a0,0x2
ffffffffc02047dc:	1f050513          	addi	a0,a0,496 # ffffffffc02069c8 <default_pmm_manager+0xe90>
ffffffffc02047e0:	73cc                	ld	a1,160(a5)
ffffffffc02047e2:	9b3fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("pgdir   = 0x%lx\n", current->pgdir);
ffffffffc02047e6:	609c                	ld	a5,0(s1)
ffffffffc02047e8:	00002517          	auipc	a0,0x2
ffffffffc02047ec:	1f050513          	addi	a0,a0,496 # ffffffffc02069d8 <default_pmm_manager+0xea0>
ffffffffc02047f0:	77cc                	ld	a1,168(a5)
ffffffffc02047f2:	9a3fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("epc     = 0x%lx\n", current->tf->epc);
ffffffffc02047f6:	609c                	ld	a5,0(s1)
ffffffffc02047f8:	00002517          	auipc	a0,0x2
ffffffffc02047fc:	1f850513          	addi	a0,a0,504 # ffffffffc02069f0 <default_pmm_manager+0xeb8>
ffffffffc0204800:	73dc                	ld	a5,160(a5)
ffffffffc0204802:	1087b583          	ld	a1,264(a5)
ffffffffc0204806:	98ffb0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("sp      = 0x%lx\n", current->tf->gpr.sp);
ffffffffc020480a:	609c                	ld	a5,0(s1)
ffffffffc020480c:	00002517          	auipc	a0,0x2
ffffffffc0204810:	1fc50513          	addi	a0,a0,508 # ffffffffc0206a08 <default_pmm_manager+0xed0>
ffffffffc0204814:	73dc                	ld	a5,160(a5)
ffffffffc0204816:	6b8c                	ld	a1,16(a5)
ffffffffc0204818:	97dfb0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("status  = 0x%lx\n", current->tf->status);
ffffffffc020481c:	609c                	ld	a5,0(s1)
ffffffffc020481e:	00002517          	auipc	a0,0x2
ffffffffc0204822:	20250513          	addi	a0,a0,514 # ffffffffc0206a20 <default_pmm_manager+0xee8>
ffffffffc0204826:	73dc                	ld	a5,160(a5)
ffffffffc0204828:	1007b583          	ld	a1,256(a5)
ffffffffc020482c:	969fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("Switching to user page table...\n");
ffffffffc0204830:	00002517          	auipc	a0,0x2
ffffffffc0204834:	20850513          	addi	a0,a0,520 # ffffffffc0206a38 <default_pmm_manager+0xf00>
ffffffffc0204838:	95dfb0ef          	jal	ra,ffffffffc0200194 <cprintf>
        write_csr(satp, (1UL << 63) | (current->pgdir >> PGSHIFT));
ffffffffc020483c:	609c                	ld	a5,0(s1)
ffffffffc020483e:	577d                	li	a4,-1
ffffffffc0204840:	177e                	slli	a4,a4,0x3f
ffffffffc0204842:	77dc                	ld	a5,168(a5)
ffffffffc0204844:	83b1                	srli	a5,a5,0xc
ffffffffc0204846:	8fd9                	or	a5,a5,a4
ffffffffc0204848:	18079073          	csrw	satp,a5
        asm volatile("sfence.vma zero, zero" ::: "memory");
ffffffffc020484c:	12000073          	sfence.vma
        forkrets(current->tf);
ffffffffc0204850:	609c                	ld	a5,0(s1)
ffffffffc0204852:	73c8                	ld	a0,160(a5)
ffffffffc0204854:	db4fc0ef          	jal	ra,ffffffffc0200e08 <forkrets>
ffffffffc0204858:	b7a1                	j	ffffffffc02047a0 <user_main+0x7c>

ffffffffc020485a <proc_init>:
}

void proc_init(void) {
ffffffffc020485a:	7179                	addi	sp,sp,-48
ffffffffc020485c:	ec26                	sd	s1,24(sp)
    elm->prev = elm->next = elm;
ffffffffc020485e:	000ac797          	auipc	a5,0xac
ffffffffc0204862:	e4a78793          	addi	a5,a5,-438 # ffffffffc02b06a8 <proc_list>
ffffffffc0204866:	f406                	sd	ra,40(sp)
ffffffffc0204868:	f022                	sd	s0,32(sp)
ffffffffc020486a:	e84a                	sd	s2,16(sp)
ffffffffc020486c:	e44e                	sd	s3,8(sp)
ffffffffc020486e:	000a8497          	auipc	s1,0xa8
ffffffffc0204872:	e3a48493          	addi	s1,s1,-454 # ffffffffc02ac6a8 <hash_list>
ffffffffc0204876:	e79c                	sd	a5,8(a5)
ffffffffc0204878:	e39c                	sd	a5,0(a5)
    list_init(&proc_list);
    for (int i = 0; i < HASH_LIST_SIZE; i++) list_init(&hash_list[i]);
ffffffffc020487a:	000ac717          	auipc	a4,0xac
ffffffffc020487e:	e2e70713          	addi	a4,a4,-466 # ffffffffc02b06a8 <proc_list>
ffffffffc0204882:	87a6                	mv	a5,s1
ffffffffc0204884:	e79c                	sd	a5,8(a5)
ffffffffc0204886:	e39c                	sd	a5,0(a5)
ffffffffc0204888:	07c1                	addi	a5,a5,16
ffffffffc020488a:	fee79de3          	bne	a5,a4,ffffffffc0204884 <proc_init+0x2a>
    idleproc = alloc_proc();
ffffffffc020488e:	866ff0ef          	jal	ra,ffffffffc02038f4 <alloc_proc>
ffffffffc0204892:	000ac917          	auipc	s2,0xac
ffffffffc0204896:	e8e90913          	addi	s2,s2,-370 # ffffffffc02b0720 <idleproc>
ffffffffc020489a:	00a93023          	sd	a0,0(s2)
    if (idleproc == NULL) panic("cannot allocate idleproc");
ffffffffc020489e:	0e050a63          	beqz	a0,ffffffffc0204992 <proc_init+0x138>
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02048a2:	4789                	li	a5,2
    idleproc->need_resched = 1;
ffffffffc02048a4:	4405                	li	s0,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02048a6:	0b450993          	addi	s3,a0,180
    idleproc->state = PROC_RUNNABLE;
ffffffffc02048aa:	e11c                	sd	a5,0(a0)
    idleproc->need_resched = 1;
ffffffffc02048ac:	ed00                	sd	s0,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02048ae:	4641                	li	a2,16
ffffffffc02048b0:	4581                	li	a1,0
    idleproc->runs = 0;
ffffffffc02048b2:	00052423          	sw	zero,8(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02048b6:	854e                	mv	a0,s3
ffffffffc02048b8:	7ca000ef          	jal	ra,ffffffffc0205082 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02048bc:	463d                	li	a2,15
ffffffffc02048be:	00002597          	auipc	a1,0x2
ffffffffc02048c2:	20258593          	addi	a1,a1,514 # ffffffffc0206ac0 <default_pmm_manager+0xf88>
ffffffffc02048c6:	854e                	mv	a0,s3
ffffffffc02048c8:	7cc000ef          	jal	ra,ffffffffc0205094 <memcpy>
    set_proc_name(idleproc, "idle");
    current = idleproc;
ffffffffc02048cc:	00093783          	ld	a5,0(s2)
    nr_process = 1;
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02048d0:	4601                	li	a2,0
ffffffffc02048d2:	4581                	li	a1,0
ffffffffc02048d4:	00000517          	auipc	a0,0x0
ffffffffc02048d8:	86050513          	addi	a0,a0,-1952 # ffffffffc0204134 <init_main>
    current = idleproc;
ffffffffc02048dc:	000ac717          	auipc	a4,0xac
ffffffffc02048e0:	e2f73e23          	sd	a5,-452(a4) # ffffffffc02b0718 <current>
    nr_process = 1;
ffffffffc02048e4:	000ac797          	auipc	a5,0xac
ffffffffc02048e8:	e487a623          	sw	s0,-436(a5) # ffffffffc02b0730 <nr_process>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02048ec:	cb6ff0ef          	jal	ra,ffffffffc0203da2 <kernel_thread>
ffffffffc02048f0:	842a                	mv	s0,a0
    if (pid < 0 || (initproc = find_proc(pid)) == NULL) panic("cannot create initproc");
ffffffffc02048f2:	02054d63          	bltz	a0,ffffffffc020492c <proc_init+0xd2>
    if (0 < pid && pid < MAX_PID)
ffffffffc02048f6:	6789                	lui	a5,0x2
ffffffffc02048f8:	fff5071b          	addiw	a4,a0,-1
ffffffffc02048fc:	17f9                	addi	a5,a5,-2
ffffffffc02048fe:	2501                	sext.w	a0,a0
ffffffffc0204900:	02e7e263          	bltu	a5,a4,ffffffffc0204924 <proc_init+0xca>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204904:	45a9                	li	a1,10
ffffffffc0204906:	2d6000ef          	jal	ra,ffffffffc0204bdc <hash32>
ffffffffc020490a:	02051693          	slli	a3,a0,0x20
ffffffffc020490e:	82f1                	srli	a3,a3,0x1c
ffffffffc0204910:	96a6                	add	a3,a3,s1
ffffffffc0204912:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0204914:	a029                	j	ffffffffc020491e <proc_init+0xc4>
            if (proc->pid == pid)
ffffffffc0204916:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x83c4>
ffffffffc020491a:	02870563          	beq	a4,s0,ffffffffc0204944 <proc_init+0xea>
    return listelm->next;
ffffffffc020491e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204920:	fef69be3          	bne	a3,a5,ffffffffc0204916 <proc_init+0xbc>
    if (pid < 0 || (initproc = find_proc(pid)) == NULL) panic("cannot create initproc");
ffffffffc0204924:	000ac797          	auipc	a5,0xac
ffffffffc0204928:	e007b223          	sd	zero,-508(a5) # ffffffffc02b0728 <initproc>
ffffffffc020492c:	00002617          	auipc	a2,0x2
ffffffffc0204930:	19c60613          	addi	a2,a2,412 # ffffffffc0206ac8 <default_pmm_manager+0xf90>
ffffffffc0204934:	2be00593          	li	a1,702
ffffffffc0204938:	00002517          	auipc	a0,0x2
ffffffffc020493c:	cd850513          	addi	a0,a0,-808 # ffffffffc0206610 <default_pmm_manager+0xad8>
ffffffffc0204940:	b0ffb0ef          	jal	ra,ffffffffc020044e <__panic>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204944:	fdc78493          	addi	s1,a5,-36
    if (pid < 0 || (initproc = find_proc(pid)) == NULL) panic("cannot create initproc");
ffffffffc0204948:	000ac417          	auipc	s0,0xac
ffffffffc020494c:	de040413          	addi	s0,s0,-544 # ffffffffc02b0728 <initproc>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204950:	f2878793          	addi	a5,a5,-216
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204954:	4641                	li	a2,16
ffffffffc0204956:	4581                	li	a1,0
ffffffffc0204958:	8526                	mv	a0,s1
    if (pid < 0 || (initproc = find_proc(pid)) == NULL) panic("cannot create initproc");
ffffffffc020495a:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020495c:	726000ef          	jal	ra,ffffffffc0205082 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204960:	463d                	li	a2,15
ffffffffc0204962:	00002597          	auipc	a1,0x2
ffffffffc0204966:	17e58593          	addi	a1,a1,382 # ffffffffc0206ae0 <default_pmm_manager+0xfa8>
ffffffffc020496a:	8526                	mv	a0,s1
ffffffffc020496c:	728000ef          	jal	ra,ffffffffc0205094 <memcpy>
    set_proc_name(initproc, "init");
    cprintf("proc_init succeeded: idle=%d init=%d\n", idleproc->pid, initproc->pid);
ffffffffc0204970:	6018                	ld	a4,0(s0)
ffffffffc0204972:	00093783          	ld	a5,0(s2)
}
ffffffffc0204976:	7402                	ld	s0,32(sp)
ffffffffc0204978:	70a2                	ld	ra,40(sp)
ffffffffc020497a:	64e2                	ld	s1,24(sp)
ffffffffc020497c:	6942                	ld	s2,16(sp)
ffffffffc020497e:	69a2                	ld	s3,8(sp)
    cprintf("proc_init succeeded: idle=%d init=%d\n", idleproc->pid, initproc->pid);
ffffffffc0204980:	4350                	lw	a2,4(a4)
ffffffffc0204982:	43cc                	lw	a1,4(a5)
ffffffffc0204984:	00002517          	auipc	a0,0x2
ffffffffc0204988:	16450513          	addi	a0,a0,356 # ffffffffc0206ae8 <default_pmm_manager+0xfb0>
}
ffffffffc020498c:	6145                	addi	sp,sp,48
    cprintf("proc_init succeeded: idle=%d init=%d\n", idleproc->pid, initproc->pid);
ffffffffc020498e:	807fb06f          	j	ffffffffc0200194 <cprintf>
    if (idleproc == NULL) panic("cannot allocate idleproc");
ffffffffc0204992:	00002617          	auipc	a2,0x2
ffffffffc0204996:	10e60613          	addi	a2,a2,270 # ffffffffc0206aa0 <default_pmm_manager+0xf68>
ffffffffc020499a:	2b500593          	li	a1,693
ffffffffc020499e:	00002517          	auipc	a0,0x2
ffffffffc02049a2:	c7250513          	addi	a0,a0,-910 # ffffffffc0206610 <default_pmm_manager+0xad8>
ffffffffc02049a6:	aa9fb0ef          	jal	ra,ffffffffc020044e <__panic>
	...

ffffffffc02049ac <switch_to>:
# Save callee-saved registers and switch kernel stack.
.text
.align 2
.globl switch_to
switch_to:
    sd ra, 0(a0)
ffffffffc02049ac:	00153023          	sd	ra,0(a0)
    sd sp, 8(a0)
ffffffffc02049b0:	00253423          	sd	sp,8(a0)
    sd s0, 16(a0)
ffffffffc02049b4:	e900                	sd	s0,16(a0)
    sd s1, 24(a0)
ffffffffc02049b6:	ed04                	sd	s1,24(a0)
    sd s2, 32(a0)
ffffffffc02049b8:	03253023          	sd	s2,32(a0)
    sd s3, 40(a0)
ffffffffc02049bc:	03353423          	sd	s3,40(a0)
    sd s4, 48(a0)
ffffffffc02049c0:	03453823          	sd	s4,48(a0)
    sd s5, 56(a0)
ffffffffc02049c4:	03553c23          	sd	s5,56(a0)
    sd s6, 64(a0)
ffffffffc02049c8:	05653023          	sd	s6,64(a0)
    sd s7, 72(a0)
ffffffffc02049cc:	05753423          	sd	s7,72(a0)
    sd s8, 80(a0)
ffffffffc02049d0:	05853823          	sd	s8,80(a0)
    sd s9, 88(a0)
ffffffffc02049d4:	05953c23          	sd	s9,88(a0)
    sd s10, 96(a0)
ffffffffc02049d8:	07a53023          	sd	s10,96(a0)
    sd s11, 104(a0)
ffffffffc02049dc:	07b53423          	sd	s11,104(a0)
    ld ra, 0(a1)
ffffffffc02049e0:	0005b083          	ld	ra,0(a1)
    ld sp, 8(a1)
ffffffffc02049e4:	0085b103          	ld	sp,8(a1)
    ld s0, 16(a1)
ffffffffc02049e8:	6980                	ld	s0,16(a1)
    ld s1, 24(a1)
ffffffffc02049ea:	6d84                	ld	s1,24(a1)
    ld s2, 32(a1)
ffffffffc02049ec:	0205b903          	ld	s2,32(a1)
    ld s3, 40(a1)
ffffffffc02049f0:	0285b983          	ld	s3,40(a1)
    ld s4, 48(a1)
ffffffffc02049f4:	0305ba03          	ld	s4,48(a1)
    ld s5, 56(a1)
ffffffffc02049f8:	0385ba83          	ld	s5,56(a1)
    ld s6, 64(a1)
ffffffffc02049fc:	0405bb03          	ld	s6,64(a1)
    ld s7, 72(a1)
ffffffffc0204a00:	0485bb83          	ld	s7,72(a1)
    ld s8, 80(a1)
ffffffffc0204a04:	0505bc03          	ld	s8,80(a1)
    ld s9, 88(a1)
ffffffffc0204a08:	0585bc83          	ld	s9,88(a1)
    ld s10, 96(a1)
ffffffffc0204a0c:	0605bd03          	ld	s10,96(a1)
    ld s11, 104(a1)
ffffffffc0204a10:	0685bd83          	ld	s11,104(a1)
    ret
ffffffffc0204a14:	8082                	ret

ffffffffc0204a16 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0204a16:	4118                	lw	a4,0(a0)
{
ffffffffc0204a18:	1101                	addi	sp,sp,-32
ffffffffc0204a1a:	ec06                	sd	ra,24(sp)
ffffffffc0204a1c:	e822                	sd	s0,16(sp)
ffffffffc0204a1e:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0204a20:	478d                	li	a5,3
ffffffffc0204a22:	04f70b63          	beq	a4,a5,ffffffffc0204a78 <wakeup_proc+0x62>
ffffffffc0204a26:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204a28:	100027f3          	csrr	a5,sstatus
ffffffffc0204a2c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204a2e:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204a30:	ef9d                	bnez	a5,ffffffffc0204a6e <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc0204a32:	4789                	li	a5,2
ffffffffc0204a34:	02f70163          	beq	a4,a5,ffffffffc0204a56 <wakeup_proc+0x40>
        {
            proc->state = PROC_RUNNABLE;
ffffffffc0204a38:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0204a3a:	0e042623          	sw	zero,236(s0)
    if (flag)
ffffffffc0204a3e:	e491                	bnez	s1,ffffffffc0204a4a <wakeup_proc+0x34>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0204a40:	60e2                	ld	ra,24(sp)
ffffffffc0204a42:	6442                	ld	s0,16(sp)
ffffffffc0204a44:	64a2                	ld	s1,8(sp)
ffffffffc0204a46:	6105                	addi	sp,sp,32
ffffffffc0204a48:	8082                	ret
ffffffffc0204a4a:	6442                	ld	s0,16(sp)
ffffffffc0204a4c:	60e2                	ld	ra,24(sp)
ffffffffc0204a4e:	64a2                	ld	s1,8(sp)
ffffffffc0204a50:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204a52:	f1dfb06f          	j	ffffffffc020096e <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0204a56:	00002617          	auipc	a2,0x2
ffffffffc0204a5a:	0f260613          	addi	a2,a2,242 # ffffffffc0206b48 <default_pmm_manager+0x1010>
ffffffffc0204a5e:	45d1                	li	a1,20
ffffffffc0204a60:	00002517          	auipc	a0,0x2
ffffffffc0204a64:	0d050513          	addi	a0,a0,208 # ffffffffc0206b30 <default_pmm_manager+0xff8>
ffffffffc0204a68:	a4ffb0ef          	jal	ra,ffffffffc02004b6 <__warn>
ffffffffc0204a6c:	bfc9                	j	ffffffffc0204a3e <wakeup_proc+0x28>
        intr_disable();
ffffffffc0204a6e:	f07fb0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc0204a72:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0204a74:	4485                	li	s1,1
ffffffffc0204a76:	bf75                	j	ffffffffc0204a32 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0204a78:	00002697          	auipc	a3,0x2
ffffffffc0204a7c:	09868693          	addi	a3,a3,152 # ffffffffc0206b10 <default_pmm_manager+0xfd8>
ffffffffc0204a80:	00001617          	auipc	a2,0x1
ffffffffc0204a84:	eb860613          	addi	a2,a2,-328 # ffffffffc0205938 <commands+0x620>
ffffffffc0204a88:	45a5                	li	a1,9
ffffffffc0204a8a:	00002517          	auipc	a0,0x2
ffffffffc0204a8e:	0a650513          	addi	a0,a0,166 # ffffffffc0206b30 <default_pmm_manager+0xff8>
ffffffffc0204a92:	9bdfb0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0204a96 <schedule>:


void schedule(void) {
ffffffffc0204a96:	1141                	addi	sp,sp,-16
ffffffffc0204a98:	e406                	sd	ra,8(sp)
ffffffffc0204a9a:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204a9c:	100027f3          	csrr	a5,sstatus
ffffffffc0204aa0:	8b89                	andi	a5,a5,2
ffffffffc0204aa2:	4401                	li	s0,0
ffffffffc0204aa4:	efb5                	bnez	a5,ffffffffc0204b20 <schedule+0x8a>
    bool intr_flag;
    local_intr_save(intr_flag);
    struct proc_struct *next = idleproc;
ffffffffc0204aa6:	000ac517          	auipc	a0,0xac
ffffffffc0204aaa:	c7a53503          	ld	a0,-902(a0) # ffffffffc02b0720 <idleproc>
    list_entry_t *list = &proc_list;
    list_entry_t *le = (current == idleproc) ? list : &current->list_link;
ffffffffc0204aae:	000ac897          	auipc	a7,0xac
ffffffffc0204ab2:	c6a8b883          	ld	a7,-918(a7) # ffffffffc02b0718 <current>
ffffffffc0204ab6:	04a88f63          	beq	a7,a0,ffffffffc0204b14 <schedule+0x7e>
ffffffffc0204aba:	0c888793          	addi	a5,a7,200
ffffffffc0204abe:	000ac617          	auipc	a2,0xac
ffffffffc0204ac2:	bea60613          	addi	a2,a2,-1046 # ffffffffc02b06a8 <proc_list>
ffffffffc0204ac6:	00863803          	ld	a6,8(a2)
ffffffffc0204aca:	6705                	lui	a4,0x1
    for (int i = 0; i < MAX_PROCESS; i++) {
        le = list_next(le);
        if (le == list) le = list_next(le);
        if (le == list) break;
        struct proc_struct *p = le2proc(le, list_link);
        if (p->state == PROC_RUNNABLE) { next = p; break; }
ffffffffc0204acc:	4589                	li	a1,2
ffffffffc0204ace:	a031                	j	ffffffffc0204ada <schedule+0x44>
ffffffffc0204ad0:	f387a683          	lw	a3,-200(a5)
ffffffffc0204ad4:	00b68e63          	beq	a3,a1,ffffffffc0204af0 <schedule+0x5a>
    for (int i = 0; i < MAX_PROCESS; i++) {
ffffffffc0204ad8:	cf11                	beqz	a4,ffffffffc0204af4 <schedule+0x5e>
ffffffffc0204ada:	679c                	ld	a5,8(a5)
ffffffffc0204adc:	377d                	addiw	a4,a4,-1
        if (le == list) le = list_next(le);
ffffffffc0204ade:	fec799e3          	bne	a5,a2,ffffffffc0204ad0 <schedule+0x3a>
        if (le == list) break;
ffffffffc0204ae2:	00f80963          	beq	a6,a5,ffffffffc0204af4 <schedule+0x5e>
ffffffffc0204ae6:	87c2                	mv	a5,a6
        if (p->state == PROC_RUNNABLE) { next = p; break; }
ffffffffc0204ae8:	f387a683          	lw	a3,-200(a5)
ffffffffc0204aec:	feb696e3          	bne	a3,a1,ffffffffc0204ad8 <schedule+0x42>
        struct proc_struct *p = le2proc(le, list_link);
ffffffffc0204af0:	f3878513          	addi	a0,a5,-200
    }
    current->need_resched = 0;
ffffffffc0204af4:	0008bc23          	sd	zero,24(a7)
    if (next != current) proc_run(next);
ffffffffc0204af8:	00a88463          	beq	a7,a0,ffffffffc0204b00 <schedule+0x6a>
ffffffffc0204afc:	af6ff0ef          	jal	ra,ffffffffc0203df2 <proc_run>
    if (flag)
ffffffffc0204b00:	e409                	bnez	s0,ffffffffc0204b0a <schedule+0x74>
    local_intr_restore(intr_flag);
}
ffffffffc0204b02:	60a2                	ld	ra,8(sp)
ffffffffc0204b04:	6402                	ld	s0,0(sp)
ffffffffc0204b06:	0141                	addi	sp,sp,16
ffffffffc0204b08:	8082                	ret
ffffffffc0204b0a:	6402                	ld	s0,0(sp)
ffffffffc0204b0c:	60a2                	ld	ra,8(sp)
ffffffffc0204b0e:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0204b10:	e5ffb06f          	j	ffffffffc020096e <intr_enable>
    list_entry_t *le = (current == idleproc) ? list : &current->list_link;
ffffffffc0204b14:	000ac617          	auipc	a2,0xac
ffffffffc0204b18:	b9460613          	addi	a2,a2,-1132 # ffffffffc02b06a8 <proc_list>
ffffffffc0204b1c:	87b2                	mv	a5,a2
ffffffffc0204b1e:	b765                	j	ffffffffc0204ac6 <schedule+0x30>
        intr_disable();
ffffffffc0204b20:	e55fb0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        return 1;
ffffffffc0204b24:	4405                	li	s0,1
ffffffffc0204b26:	b741                	j	ffffffffc0204aa6 <schedule+0x10>

ffffffffc0204b28 <sys_getpid>:
    return do_kill((int)args[0]);
}

static int sys_getpid(uint64_t args[]) {
    (void)args;
    return current->pid;
ffffffffc0204b28:	000ac797          	auipc	a5,0xac
ffffffffc0204b2c:	bf07b783          	ld	a5,-1040(a5) # ffffffffc02b0718 <current>
}
ffffffffc0204b30:	43c8                	lw	a0,4(a5)
ffffffffc0204b32:	8082                	ret

ffffffffc0204b34 <sys_pgdir>:
static int sys_putc(uint64_t args[]) {
    cons_putc((int)args[0]);
    return 0;
}

static int sys_pgdir(uint64_t args[]) {
ffffffffc0204b34:	1141                	addi	sp,sp,-16
ffffffffc0204b36:	e406                	sd	ra,8(sp)
    (void)args;
    print_pgdir();
ffffffffc0204b38:	df2fe0ef          	jal	ra,ffffffffc020312a <print_pgdir>
    return 0;
}
ffffffffc0204b3c:	60a2                	ld	ra,8(sp)
ffffffffc0204b3e:	4501                	li	a0,0
ffffffffc0204b40:	0141                	addi	sp,sp,16
ffffffffc0204b42:	8082                	ret

ffffffffc0204b44 <sys_putc>:
    cons_putc((int)args[0]);
ffffffffc0204b44:	4108                	lw	a0,0(a0)
static int sys_putc(uint64_t args[]) {
ffffffffc0204b46:	1141                	addi	sp,sp,-16
ffffffffc0204b48:	e406                	sd	ra,8(sp)
    cons_putc((int)args[0]);
ffffffffc0204b4a:	a05fb0ef          	jal	ra,ffffffffc020054e <cons_putc>
}
ffffffffc0204b4e:	60a2                	ld	ra,8(sp)
ffffffffc0204b50:	4501                	li	a0,0
ffffffffc0204b52:	0141                	addi	sp,sp,16
ffffffffc0204b54:	8082                	ret

ffffffffc0204b56 <sys_kill>:
    return do_kill((int)args[0]);
ffffffffc0204b56:	4108                	lw	a0,0(a0)
ffffffffc0204b58:	e42ff06f          	j	ffffffffc020419a <do_kill>

ffffffffc0204b5c <sys_yield>:
    return do_yield();
ffffffffc0204b5c:	afeff06f          	j	ffffffffc0203e5a <do_yield>

ffffffffc0204b60 <sys_exec>:
    return do_execve((const char *)(uintptr_t)args[0], (size_t)args[1],
ffffffffc0204b60:	6d14                	ld	a3,24(a0)
ffffffffc0204b62:	6910                	ld	a2,16(a0)
ffffffffc0204b64:	650c                	ld	a1,8(a0)
ffffffffc0204b66:	6108                	ld	a0,0(a0)
ffffffffc0204b68:	f0eff06f          	j	ffffffffc0204276 <do_execve>

ffffffffc0204b6c <sys_wait>:
    return do_wait((int)args[0], (int *)(uintptr_t)args[1]);
ffffffffc0204b6c:	650c                	ld	a1,8(a0)
ffffffffc0204b6e:	4108                	lw	a0,0(a0)
ffffffffc0204b70:	c4cff06f          	j	ffffffffc0203fbc <do_wait>

ffffffffc0204b74 <sys_fork>:
    return do_fork(0, current->tf->gpr.sp, current->tf);
ffffffffc0204b74:	000ac797          	auipc	a5,0xac
ffffffffc0204b78:	ba47b783          	ld	a5,-1116(a5) # ffffffffc02b0718 <current>
ffffffffc0204b7c:	73d0                	ld	a2,160(a5)
ffffffffc0204b7e:	4501                	li	a0,0
ffffffffc0204b80:	6a0c                	ld	a1,16(a2)
ffffffffc0204b82:	e3dfe06f          	j	ffffffffc02039be <do_fork>

ffffffffc0204b86 <sys_exit>:
    return do_exit((int)args[0]);
ffffffffc0204b86:	4108                	lw	a0,0(a0)
ffffffffc0204b88:	b06ff06f          	j	ffffffffc0203e8e <do_exit>

ffffffffc0204b8c <syscall>:

#define NUM_SYSCALLS (sizeof(syscalls) / sizeof(syscalls[0]))

/* user/libs/syscall.c passes a0=number, a1..a5=arguments.
 * Store result in a0 so trap return delivers it to user mode. */
void syscall(void) {
ffffffffc0204b8c:	7139                	addi	sp,sp,-64
    struct trapframe *tf = current->tf;
ffffffffc0204b8e:	000ac797          	auipc	a5,0xac
ffffffffc0204b92:	b8a7b783          	ld	a5,-1142(a5) # ffffffffc02b0718 <current>
void syscall(void) {
ffffffffc0204b96:	f822                	sd	s0,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0204b98:	73c0                	ld	s0,160(a5)
void syscall(void) {
ffffffffc0204b9a:	fc06                	sd	ra,56(sp)
    uint64_t args[5] = {
        tf->gpr.a1, tf->gpr.a2, tf->gpr.a3, tf->gpr.a4, tf->gpr.a5
    };

    int ret = -E_INVAL;
    if (num < NUM_SYSCALLS && syscalls[num] != NULL) {
ffffffffc0204b9c:	477d                	li	a4,31
    uint64_t args[5] = {
ffffffffc0204b9e:	05843883          	ld	a7,88(s0)
ffffffffc0204ba2:	06043803          	ld	a6,96(s0)
ffffffffc0204ba6:	742c                	ld	a1,104(s0)
ffffffffc0204ba8:	7830                	ld	a2,112(s0)
ffffffffc0204baa:	7c34                	ld	a3,120(s0)
    uint64_t num = tf->gpr.a0;
ffffffffc0204bac:	683c                	ld	a5,80(s0)
    uint64_t args[5] = {
ffffffffc0204bae:	e446                	sd	a7,8(sp)
ffffffffc0204bb0:	e842                	sd	a6,16(sp)
ffffffffc0204bb2:	ec2e                	sd	a1,24(sp)
ffffffffc0204bb4:	f032                	sd	a2,32(sp)
ffffffffc0204bb6:	f436                	sd	a3,40(sp)
    if (num < NUM_SYSCALLS && syscalls[num] != NULL) {
ffffffffc0204bb8:	5575                	li	a0,-3
ffffffffc0204bba:	00f76c63          	bltu	a4,a5,ffffffffc0204bd2 <syscall+0x46>
ffffffffc0204bbe:	078e                	slli	a5,a5,0x3
ffffffffc0204bc0:	00002717          	auipc	a4,0x2
ffffffffc0204bc4:	fa870713          	addi	a4,a4,-88 # ffffffffc0206b68 <syscalls>
ffffffffc0204bc8:	97ba                	add	a5,a5,a4
ffffffffc0204bca:	639c                	ld	a5,0(a5)
ffffffffc0204bcc:	c399                	beqz	a5,ffffffffc0204bd2 <syscall+0x46>
        ret = syscalls[num](args);
ffffffffc0204bce:	0028                	addi	a0,sp,8
ffffffffc0204bd0:	9782                	jalr	a5
    }
    tf->gpr.a0 = (uintptr_t)ret;
}
ffffffffc0204bd2:	70e2                	ld	ra,56(sp)
    tf->gpr.a0 = (uintptr_t)ret;
ffffffffc0204bd4:	e828                	sd	a0,80(s0)
}
ffffffffc0204bd6:	7442                	ld	s0,48(sp)
ffffffffc0204bd8:	6121                	addi	sp,sp,64
ffffffffc0204bda:	8082                	ret

ffffffffc0204bdc <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204bdc:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204be0:	2785                	addiw	a5,a5,1
ffffffffc0204be2:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0204be6:	02000793          	li	a5,32
ffffffffc0204bea:	9f8d                	subw	a5,a5,a1
}
ffffffffc0204bec:	00f5553b          	srlw	a0,a0,a5
ffffffffc0204bf0:	8082                	ret

ffffffffc0204bf2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204bf2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204bf6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204bf8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204bfc:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204bfe:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204c02:	f022                	sd	s0,32(sp)
ffffffffc0204c04:	ec26                	sd	s1,24(sp)
ffffffffc0204c06:	e84a                	sd	s2,16(sp)
ffffffffc0204c08:	f406                	sd	ra,40(sp)
ffffffffc0204c0a:	e44e                	sd	s3,8(sp)
ffffffffc0204c0c:	84aa                	mv	s1,a0
ffffffffc0204c0e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204c10:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204c14:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0204c16:	03067e63          	bgeu	a2,a6,ffffffffc0204c52 <printnum+0x60>
ffffffffc0204c1a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0204c1c:	00805763          	blez	s0,ffffffffc0204c2a <printnum+0x38>
ffffffffc0204c20:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204c22:	85ca                	mv	a1,s2
ffffffffc0204c24:	854e                	mv	a0,s3
ffffffffc0204c26:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204c28:	fc65                	bnez	s0,ffffffffc0204c20 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204c2a:	1a02                	slli	s4,s4,0x20
ffffffffc0204c2c:	00002797          	auipc	a5,0x2
ffffffffc0204c30:	03c78793          	addi	a5,a5,60 # ffffffffc0206c68 <syscalls+0x100>
ffffffffc0204c34:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204c38:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0204c3a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204c3c:	000a4503          	lbu	a0,0(s4) # ffffffff80000000 <_binary_obj___user_exit_out_size+0xffffffff7fff4798>
}
ffffffffc0204c40:	70a2                	ld	ra,40(sp)
ffffffffc0204c42:	69a2                	ld	s3,8(sp)
ffffffffc0204c44:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204c46:	85ca                	mv	a1,s2
ffffffffc0204c48:	87a6                	mv	a5,s1
}
ffffffffc0204c4a:	6942                	ld	s2,16(sp)
ffffffffc0204c4c:	64e2                	ld	s1,24(sp)
ffffffffc0204c4e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204c50:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204c52:	03065633          	divu	a2,a2,a6
ffffffffc0204c56:	8722                	mv	a4,s0
ffffffffc0204c58:	f9bff0ef          	jal	ra,ffffffffc0204bf2 <printnum>
ffffffffc0204c5c:	b7f9                	j	ffffffffc0204c2a <printnum+0x38>

ffffffffc0204c5e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204c5e:	7119                	addi	sp,sp,-128
ffffffffc0204c60:	f4a6                	sd	s1,104(sp)
ffffffffc0204c62:	f0ca                	sd	s2,96(sp)
ffffffffc0204c64:	ecce                	sd	s3,88(sp)
ffffffffc0204c66:	e8d2                	sd	s4,80(sp)
ffffffffc0204c68:	e4d6                	sd	s5,72(sp)
ffffffffc0204c6a:	e0da                	sd	s6,64(sp)
ffffffffc0204c6c:	fc5e                	sd	s7,56(sp)
ffffffffc0204c6e:	f06a                	sd	s10,32(sp)
ffffffffc0204c70:	fc86                	sd	ra,120(sp)
ffffffffc0204c72:	f8a2                	sd	s0,112(sp)
ffffffffc0204c74:	f862                	sd	s8,48(sp)
ffffffffc0204c76:	f466                	sd	s9,40(sp)
ffffffffc0204c78:	ec6e                	sd	s11,24(sp)
ffffffffc0204c7a:	892a                	mv	s2,a0
ffffffffc0204c7c:	84ae                	mv	s1,a1
ffffffffc0204c7e:	8d32                	mv	s10,a2
ffffffffc0204c80:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204c82:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204c86:	5b7d                	li	s6,-1
ffffffffc0204c88:	00002a97          	auipc	s5,0x2
ffffffffc0204c8c:	00ca8a93          	addi	s5,s5,12 # ffffffffc0206c94 <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204c90:	00002b97          	auipc	s7,0x2
ffffffffc0204c94:	220b8b93          	addi	s7,s7,544 # ffffffffc0206eb0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204c98:	000d4503          	lbu	a0,0(s10)
ffffffffc0204c9c:	001d0413          	addi	s0,s10,1
ffffffffc0204ca0:	01350a63          	beq	a0,s3,ffffffffc0204cb4 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204ca4:	c121                	beqz	a0,ffffffffc0204ce4 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204ca6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204ca8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204caa:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204cac:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204cb0:	ff351ae3          	bne	a0,s3,ffffffffc0204ca4 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cb4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204cb8:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204cbc:	4c81                	li	s9,0
ffffffffc0204cbe:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204cc0:	5c7d                	li	s8,-1
ffffffffc0204cc2:	5dfd                	li	s11,-1
ffffffffc0204cc4:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0204cc8:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cca:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204cce:	0ff5f593          	andi	a1,a1,255
ffffffffc0204cd2:	00140d13          	addi	s10,s0,1
ffffffffc0204cd6:	04b56263          	bltu	a0,a1,ffffffffc0204d1a <vprintfmt+0xbc>
ffffffffc0204cda:	058a                	slli	a1,a1,0x2
ffffffffc0204cdc:	95d6                	add	a1,a1,s5
ffffffffc0204cde:	4194                	lw	a3,0(a1)
ffffffffc0204ce0:	96d6                	add	a3,a3,s5
ffffffffc0204ce2:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204ce4:	70e6                	ld	ra,120(sp)
ffffffffc0204ce6:	7446                	ld	s0,112(sp)
ffffffffc0204ce8:	74a6                	ld	s1,104(sp)
ffffffffc0204cea:	7906                	ld	s2,96(sp)
ffffffffc0204cec:	69e6                	ld	s3,88(sp)
ffffffffc0204cee:	6a46                	ld	s4,80(sp)
ffffffffc0204cf0:	6aa6                	ld	s5,72(sp)
ffffffffc0204cf2:	6b06                	ld	s6,64(sp)
ffffffffc0204cf4:	7be2                	ld	s7,56(sp)
ffffffffc0204cf6:	7c42                	ld	s8,48(sp)
ffffffffc0204cf8:	7ca2                	ld	s9,40(sp)
ffffffffc0204cfa:	7d02                	ld	s10,32(sp)
ffffffffc0204cfc:	6de2                	ld	s11,24(sp)
ffffffffc0204cfe:	6109                	addi	sp,sp,128
ffffffffc0204d00:	8082                	ret
            padc = '0';
ffffffffc0204d02:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204d04:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d08:	846a                	mv	s0,s10
ffffffffc0204d0a:	00140d13          	addi	s10,s0,1
ffffffffc0204d0e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204d12:	0ff5f593          	andi	a1,a1,255
ffffffffc0204d16:	fcb572e3          	bgeu	a0,a1,ffffffffc0204cda <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0204d1a:	85a6                	mv	a1,s1
ffffffffc0204d1c:	02500513          	li	a0,37
ffffffffc0204d20:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204d22:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204d26:	8d22                	mv	s10,s0
ffffffffc0204d28:	f73788e3          	beq	a5,s3,ffffffffc0204c98 <vprintfmt+0x3a>
ffffffffc0204d2c:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204d30:	1d7d                	addi	s10,s10,-1
ffffffffc0204d32:	ff379de3          	bne	a5,s3,ffffffffc0204d2c <vprintfmt+0xce>
ffffffffc0204d36:	b78d                	j	ffffffffc0204c98 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204d38:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204d3c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d40:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204d42:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204d46:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204d4a:	02d86463          	bltu	a6,a3,ffffffffc0204d72 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0204d4e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204d52:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204d56:	0186873b          	addw	a4,a3,s8
ffffffffc0204d5a:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204d5e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204d60:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204d64:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204d66:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204d6a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204d6e:	fed870e3          	bgeu	a6,a3,ffffffffc0204d4e <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204d72:	f40ddce3          	bgez	s11,ffffffffc0204cca <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204d76:	8de2                	mv	s11,s8
ffffffffc0204d78:	5c7d                	li	s8,-1
ffffffffc0204d7a:	bf81                	j	ffffffffc0204cca <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204d7c:	fffdc693          	not	a3,s11
ffffffffc0204d80:	96fd                	srai	a3,a3,0x3f
ffffffffc0204d82:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d86:	00144603          	lbu	a2,1(s0)
ffffffffc0204d8a:	2d81                	sext.w	s11,s11
ffffffffc0204d8c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204d8e:	bf35                	j	ffffffffc0204cca <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204d90:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d94:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204d98:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d9a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204d9c:	bfd9                	j	ffffffffc0204d72 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204d9e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204da0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204da4:	01174463          	blt	a4,a7,ffffffffc0204dac <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204da8:	1a088e63          	beqz	a7,ffffffffc0204f64 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204dac:	000a3603          	ld	a2,0(s4)
ffffffffc0204db0:	46c1                	li	a3,16
ffffffffc0204db2:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204db4:	2781                	sext.w	a5,a5
ffffffffc0204db6:	876e                	mv	a4,s11
ffffffffc0204db8:	85a6                	mv	a1,s1
ffffffffc0204dba:	854a                	mv	a0,s2
ffffffffc0204dbc:	e37ff0ef          	jal	ra,ffffffffc0204bf2 <printnum>
            break;
ffffffffc0204dc0:	bde1                	j	ffffffffc0204c98 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204dc2:	000a2503          	lw	a0,0(s4)
ffffffffc0204dc6:	85a6                	mv	a1,s1
ffffffffc0204dc8:	0a21                	addi	s4,s4,8
ffffffffc0204dca:	9902                	jalr	s2
            break;
ffffffffc0204dcc:	b5f1                	j	ffffffffc0204c98 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204dce:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204dd0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204dd4:	01174463          	blt	a4,a7,ffffffffc0204ddc <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204dd8:	18088163          	beqz	a7,ffffffffc0204f5a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204ddc:	000a3603          	ld	a2,0(s4)
ffffffffc0204de0:	46a9                	li	a3,10
ffffffffc0204de2:	8a2e                	mv	s4,a1
ffffffffc0204de4:	bfc1                	j	ffffffffc0204db4 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204de6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204dea:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204dec:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204dee:	bdf1                	j	ffffffffc0204cca <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204df0:	85a6                	mv	a1,s1
ffffffffc0204df2:	02500513          	li	a0,37
ffffffffc0204df6:	9902                	jalr	s2
            break;
ffffffffc0204df8:	b545                	j	ffffffffc0204c98 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204dfa:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0204dfe:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204e00:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204e02:	b5e1                	j	ffffffffc0204cca <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204e04:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204e06:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204e0a:	01174463          	blt	a4,a7,ffffffffc0204e12 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0204e0e:	14088163          	beqz	a7,ffffffffc0204f50 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204e12:	000a3603          	ld	a2,0(s4)
ffffffffc0204e16:	46a1                	li	a3,8
ffffffffc0204e18:	8a2e                	mv	s4,a1
ffffffffc0204e1a:	bf69                	j	ffffffffc0204db4 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204e1c:	03000513          	li	a0,48
ffffffffc0204e20:	85a6                	mv	a1,s1
ffffffffc0204e22:	e03e                	sd	a5,0(sp)
ffffffffc0204e24:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204e26:	85a6                	mv	a1,s1
ffffffffc0204e28:	07800513          	li	a0,120
ffffffffc0204e2c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204e2e:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204e30:	6782                	ld	a5,0(sp)
ffffffffc0204e32:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204e34:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204e38:	bfb5                	j	ffffffffc0204db4 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204e3a:	000a3403          	ld	s0,0(s4)
ffffffffc0204e3e:	008a0713          	addi	a4,s4,8
ffffffffc0204e42:	e03a                	sd	a4,0(sp)
ffffffffc0204e44:	14040263          	beqz	s0,ffffffffc0204f88 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204e48:	0fb05763          	blez	s11,ffffffffc0204f36 <vprintfmt+0x2d8>
ffffffffc0204e4c:	02d00693          	li	a3,45
ffffffffc0204e50:	0cd79163          	bne	a5,a3,ffffffffc0204f12 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e54:	00044783          	lbu	a5,0(s0)
ffffffffc0204e58:	0007851b          	sext.w	a0,a5
ffffffffc0204e5c:	cf85                	beqz	a5,ffffffffc0204e94 <vprintfmt+0x236>
ffffffffc0204e5e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204e62:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e66:	000c4563          	bltz	s8,ffffffffc0204e70 <vprintfmt+0x212>
ffffffffc0204e6a:	3c7d                	addiw	s8,s8,-1
ffffffffc0204e6c:	036c0263          	beq	s8,s6,ffffffffc0204e90 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204e70:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204e72:	0e0c8e63          	beqz	s9,ffffffffc0204f6e <vprintfmt+0x310>
ffffffffc0204e76:	3781                	addiw	a5,a5,-32
ffffffffc0204e78:	0ef47b63          	bgeu	s0,a5,ffffffffc0204f6e <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204e7c:	03f00513          	li	a0,63
ffffffffc0204e80:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e82:	000a4783          	lbu	a5,0(s4)
ffffffffc0204e86:	3dfd                	addiw	s11,s11,-1
ffffffffc0204e88:	0a05                	addi	s4,s4,1
ffffffffc0204e8a:	0007851b          	sext.w	a0,a5
ffffffffc0204e8e:	ffe1                	bnez	a5,ffffffffc0204e66 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204e90:	01b05963          	blez	s11,ffffffffc0204ea2 <vprintfmt+0x244>
ffffffffc0204e94:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204e96:	85a6                	mv	a1,s1
ffffffffc0204e98:	02000513          	li	a0,32
ffffffffc0204e9c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204e9e:	fe0d9be3          	bnez	s11,ffffffffc0204e94 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204ea2:	6a02                	ld	s4,0(sp)
ffffffffc0204ea4:	bbd5                	j	ffffffffc0204c98 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204ea6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204ea8:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204eac:	01174463          	blt	a4,a7,ffffffffc0204eb4 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204eb0:	08088d63          	beqz	a7,ffffffffc0204f4a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204eb4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204eb8:	0a044d63          	bltz	s0,ffffffffc0204f72 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204ebc:	8622                	mv	a2,s0
ffffffffc0204ebe:	8a66                	mv	s4,s9
ffffffffc0204ec0:	46a9                	li	a3,10
ffffffffc0204ec2:	bdcd                	j	ffffffffc0204db4 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204ec4:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204ec8:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0204eca:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204ecc:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204ed0:	8fb5                	xor	a5,a5,a3
ffffffffc0204ed2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204ed6:	02d74163          	blt	a4,a3,ffffffffc0204ef8 <vprintfmt+0x29a>
ffffffffc0204eda:	00369793          	slli	a5,a3,0x3
ffffffffc0204ede:	97de                	add	a5,a5,s7
ffffffffc0204ee0:	639c                	ld	a5,0(a5)
ffffffffc0204ee2:	cb99                	beqz	a5,ffffffffc0204ef8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204ee4:	86be                	mv	a3,a5
ffffffffc0204ee6:	00000617          	auipc	a2,0x0
ffffffffc0204eea:	1f260613          	addi	a2,a2,498 # ffffffffc02050d8 <etext+0x2c>
ffffffffc0204eee:	85a6                	mv	a1,s1
ffffffffc0204ef0:	854a                	mv	a0,s2
ffffffffc0204ef2:	0ce000ef          	jal	ra,ffffffffc0204fc0 <printfmt>
ffffffffc0204ef6:	b34d                	j	ffffffffc0204c98 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204ef8:	00002617          	auipc	a2,0x2
ffffffffc0204efc:	d9060613          	addi	a2,a2,-624 # ffffffffc0206c88 <syscalls+0x120>
ffffffffc0204f00:	85a6                	mv	a1,s1
ffffffffc0204f02:	854a                	mv	a0,s2
ffffffffc0204f04:	0bc000ef          	jal	ra,ffffffffc0204fc0 <printfmt>
ffffffffc0204f08:	bb41                	j	ffffffffc0204c98 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204f0a:	00002417          	auipc	s0,0x2
ffffffffc0204f0e:	d7640413          	addi	s0,s0,-650 # ffffffffc0206c80 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204f12:	85e2                	mv	a1,s8
ffffffffc0204f14:	8522                	mv	a0,s0
ffffffffc0204f16:	e43e                	sd	a5,8(sp)
ffffffffc0204f18:	0e2000ef          	jal	ra,ffffffffc0204ffa <strnlen>
ffffffffc0204f1c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204f20:	01b05b63          	blez	s11,ffffffffc0204f36 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204f24:	67a2                	ld	a5,8(sp)
ffffffffc0204f26:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204f2a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204f2c:	85a6                	mv	a1,s1
ffffffffc0204f2e:	8552                	mv	a0,s4
ffffffffc0204f30:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204f32:	fe0d9ce3          	bnez	s11,ffffffffc0204f2a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204f36:	00044783          	lbu	a5,0(s0)
ffffffffc0204f3a:	00140a13          	addi	s4,s0,1
ffffffffc0204f3e:	0007851b          	sext.w	a0,a5
ffffffffc0204f42:	d3a5                	beqz	a5,ffffffffc0204ea2 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204f44:	05e00413          	li	s0,94
ffffffffc0204f48:	bf39                	j	ffffffffc0204e66 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204f4a:	000a2403          	lw	s0,0(s4)
ffffffffc0204f4e:	b7ad                	j	ffffffffc0204eb8 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204f50:	000a6603          	lwu	a2,0(s4)
ffffffffc0204f54:	46a1                	li	a3,8
ffffffffc0204f56:	8a2e                	mv	s4,a1
ffffffffc0204f58:	bdb1                	j	ffffffffc0204db4 <vprintfmt+0x156>
ffffffffc0204f5a:	000a6603          	lwu	a2,0(s4)
ffffffffc0204f5e:	46a9                	li	a3,10
ffffffffc0204f60:	8a2e                	mv	s4,a1
ffffffffc0204f62:	bd89                	j	ffffffffc0204db4 <vprintfmt+0x156>
ffffffffc0204f64:	000a6603          	lwu	a2,0(s4)
ffffffffc0204f68:	46c1                	li	a3,16
ffffffffc0204f6a:	8a2e                	mv	s4,a1
ffffffffc0204f6c:	b5a1                	j	ffffffffc0204db4 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204f6e:	9902                	jalr	s2
ffffffffc0204f70:	bf09                	j	ffffffffc0204e82 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204f72:	85a6                	mv	a1,s1
ffffffffc0204f74:	02d00513          	li	a0,45
ffffffffc0204f78:	e03e                	sd	a5,0(sp)
ffffffffc0204f7a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204f7c:	6782                	ld	a5,0(sp)
ffffffffc0204f7e:	8a66                	mv	s4,s9
ffffffffc0204f80:	40800633          	neg	a2,s0
ffffffffc0204f84:	46a9                	li	a3,10
ffffffffc0204f86:	b53d                	j	ffffffffc0204db4 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204f88:	03b05163          	blez	s11,ffffffffc0204faa <vprintfmt+0x34c>
ffffffffc0204f8c:	02d00693          	li	a3,45
ffffffffc0204f90:	f6d79de3          	bne	a5,a3,ffffffffc0204f0a <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204f94:	00002417          	auipc	s0,0x2
ffffffffc0204f98:	cec40413          	addi	s0,s0,-788 # ffffffffc0206c80 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204f9c:	02800793          	li	a5,40
ffffffffc0204fa0:	02800513          	li	a0,40
ffffffffc0204fa4:	00140a13          	addi	s4,s0,1
ffffffffc0204fa8:	bd6d                	j	ffffffffc0204e62 <vprintfmt+0x204>
ffffffffc0204faa:	00002a17          	auipc	s4,0x2
ffffffffc0204fae:	cd7a0a13          	addi	s4,s4,-809 # ffffffffc0206c81 <syscalls+0x119>
ffffffffc0204fb2:	02800513          	li	a0,40
ffffffffc0204fb6:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204fba:	05e00413          	li	s0,94
ffffffffc0204fbe:	b565                	j	ffffffffc0204e66 <vprintfmt+0x208>

ffffffffc0204fc0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204fc0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204fc2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204fc6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204fc8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204fca:	ec06                	sd	ra,24(sp)
ffffffffc0204fcc:	f83a                	sd	a4,48(sp)
ffffffffc0204fce:	fc3e                	sd	a5,56(sp)
ffffffffc0204fd0:	e0c2                	sd	a6,64(sp)
ffffffffc0204fd2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204fd4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204fd6:	c89ff0ef          	jal	ra,ffffffffc0204c5e <vprintfmt>
}
ffffffffc0204fda:	60e2                	ld	ra,24(sp)
ffffffffc0204fdc:	6161                	addi	sp,sp,80
ffffffffc0204fde:	8082                	ret

ffffffffc0204fe0 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204fe0:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0204fe4:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0204fe6:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0204fe8:	cb81                	beqz	a5,ffffffffc0204ff8 <strlen+0x18>
        cnt ++;
ffffffffc0204fea:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204fec:	00a707b3          	add	a5,a4,a0
ffffffffc0204ff0:	0007c783          	lbu	a5,0(a5)
ffffffffc0204ff4:	fbfd                	bnez	a5,ffffffffc0204fea <strlen+0xa>
ffffffffc0204ff6:	8082                	ret
    }
    return cnt;
}
ffffffffc0204ff8:	8082                	ret

ffffffffc0204ffa <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0204ffa:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204ffc:	e589                	bnez	a1,ffffffffc0205006 <strnlen+0xc>
ffffffffc0204ffe:	a811                	j	ffffffffc0205012 <strnlen+0x18>
        cnt ++;
ffffffffc0205000:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205002:	00f58863          	beq	a1,a5,ffffffffc0205012 <strnlen+0x18>
ffffffffc0205006:	00f50733          	add	a4,a0,a5
ffffffffc020500a:	00074703          	lbu	a4,0(a4)
ffffffffc020500e:	fb6d                	bnez	a4,ffffffffc0205000 <strnlen+0x6>
ffffffffc0205010:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0205012:	852e                	mv	a0,a1
ffffffffc0205014:	8082                	ret

ffffffffc0205016 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205016:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0205018:	0005c703          	lbu	a4,0(a1)
ffffffffc020501c:	0785                	addi	a5,a5,1
ffffffffc020501e:	0585                	addi	a1,a1,1
ffffffffc0205020:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205024:	fb75                	bnez	a4,ffffffffc0205018 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205026:	8082                	ret

ffffffffc0205028 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205028:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020502c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205030:	cb89                	beqz	a5,ffffffffc0205042 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0205032:	0505                	addi	a0,a0,1
ffffffffc0205034:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205036:	fee789e3          	beq	a5,a4,ffffffffc0205028 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020503a:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020503e:	9d19                	subw	a0,a0,a4
ffffffffc0205040:	8082                	ret
ffffffffc0205042:	4501                	li	a0,0
ffffffffc0205044:	bfed                	j	ffffffffc020503e <strcmp+0x16>

ffffffffc0205046 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205046:	c20d                	beqz	a2,ffffffffc0205068 <strncmp+0x22>
ffffffffc0205048:	962e                	add	a2,a2,a1
ffffffffc020504a:	a031                	j	ffffffffc0205056 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc020504c:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020504e:	00e79a63          	bne	a5,a4,ffffffffc0205062 <strncmp+0x1c>
ffffffffc0205052:	00b60b63          	beq	a2,a1,ffffffffc0205068 <strncmp+0x22>
ffffffffc0205056:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc020505a:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020505c:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0205060:	f7f5                	bnez	a5,ffffffffc020504c <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205062:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0205066:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205068:	4501                	li	a0,0
ffffffffc020506a:	8082                	ret

ffffffffc020506c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020506c:	00054783          	lbu	a5,0(a0)
ffffffffc0205070:	c799                	beqz	a5,ffffffffc020507e <strchr+0x12>
        if (*s == c) {
ffffffffc0205072:	00f58763          	beq	a1,a5,ffffffffc0205080 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0205076:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020507a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020507c:	fbfd                	bnez	a5,ffffffffc0205072 <strchr+0x6>
    }
    return NULL;
ffffffffc020507e:	4501                	li	a0,0
}
ffffffffc0205080:	8082                	ret

ffffffffc0205082 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0205082:	ca01                	beqz	a2,ffffffffc0205092 <memset+0x10>
ffffffffc0205084:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0205086:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0205088:	0785                	addi	a5,a5,1
ffffffffc020508a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020508e:	fec79de3          	bne	a5,a2,ffffffffc0205088 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205092:	8082                	ret

ffffffffc0205094 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0205094:	ca19                	beqz	a2,ffffffffc02050aa <memcpy+0x16>
ffffffffc0205096:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0205098:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020509a:	0005c703          	lbu	a4,0(a1)
ffffffffc020509e:	0585                	addi	a1,a1,1
ffffffffc02050a0:	0785                	addi	a5,a5,1
ffffffffc02050a2:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02050a6:	fec59ae3          	bne	a1,a2,ffffffffc020509a <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02050aa:	8082                	ret
