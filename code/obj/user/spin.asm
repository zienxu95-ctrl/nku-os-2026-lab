
obj/__user_spin.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	1c6000ef          	jal	ra,8001e6 <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800026:	715d                	addi	sp,sp,-80
  800028:	8e2e                	mv	t3,a1
  80002a:	e822                	sd	s0,16(sp)
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("user panic at %s:%d:\n    ", file, line);
  80002c:	85aa                	mv	a1,a0
__panic(const char *file, int line, const char *fmt, ...) {
  80002e:	8432                	mv	s0,a2
  800030:	fc3e                	sd	a5,56(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800032:	8672                	mv	a2,t3
    va_start(ap, fmt);
  800034:	103c                	addi	a5,sp,40
    cprintf("user panic at %s:%d:\n    ", file, line);
  800036:	00000517          	auipc	a0,0x0
  80003a:	69250513          	addi	a0,a0,1682 # 8006c8 <main+0xcc>
__panic(const char *file, int line, const char *fmt, ...) {
  80003e:	ec06                	sd	ra,24(sp)
  800040:	f436                	sd	a3,40(sp)
  800042:	f83a                	sd	a4,48(sp)
  800044:	e0c2                	sd	a6,64(sp)
  800046:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800048:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  80004a:	058000ef          	jal	ra,8000a2 <cprintf>
    vcprintf(fmt, ap);
  80004e:	65a2                	ld	a1,8(sp)
  800050:	8522                	mv	a0,s0
  800052:	030000ef          	jal	ra,800082 <vcprintf>
    cprintf("\n");
  800056:	00000517          	auipc	a0,0x0
  80005a:	69250513          	addi	a0,a0,1682 # 8006e8 <main+0xec>
  80005e:	044000ef          	jal	ra,8000a2 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	164000ef          	jal	ra,8001c8 <exit>

0000000000800068 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800068:	1141                	addi	sp,sp,-16
  80006a:	e022                	sd	s0,0(sp)
  80006c:	e406                	sd	ra,8(sp)
  80006e:	842e                	mv	s0,a1
    sys_putc(c);
  800070:	130000ef          	jal	ra,8001a0 <sys_putc>
    (*cnt) ++;
  800074:	401c                	lw	a5,0(s0)
}
  800076:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800078:	2785                	addiw	a5,a5,1
  80007a:	c01c                	sw	a5,0(s0)
}
  80007c:	6402                	ld	s0,0(sp)
  80007e:	0141                	addi	sp,sp,16
  800080:	8082                	ret

0000000000800082 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800082:	1101                	addi	sp,sp,-32
  800084:	862a                	mv	a2,a0
  800086:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800088:	00000517          	auipc	a0,0x0
  80008c:	fe050513          	addi	a0,a0,-32 # 800068 <cputch>
  800090:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800092:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800094:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800096:	1c8000ef          	jal	ra,80025e <vprintfmt>
    return cnt;
}
  80009a:	60e2                	ld	ra,24(sp)
  80009c:	4532                	lw	a0,12(sp)
  80009e:	6105                	addi	sp,sp,32
  8000a0:	8082                	ret

00000000008000a2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000a2:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000a4:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000a8:	8e2a                	mv	t3,a0
  8000aa:	f42e                	sd	a1,40(sp)
  8000ac:	f832                	sd	a2,48(sp)
  8000ae:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000b0:	00000517          	auipc	a0,0x0
  8000b4:	fb850513          	addi	a0,a0,-72 # 800068 <cputch>
  8000b8:	004c                	addi	a1,sp,4
  8000ba:	869a                	mv	a3,t1
  8000bc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  8000be:	ec06                	sd	ra,24(sp)
  8000c0:	e0ba                	sd	a4,64(sp)
  8000c2:	e4be                	sd	a5,72(sp)
  8000c4:	e8c2                	sd	a6,80(sp)
  8000c6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000c8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000ca:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000cc:	192000ef          	jal	ra,80025e <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000d0:	60e2                	ld	ra,24(sp)
  8000d2:	4512                	lw	a0,4(sp)
  8000d4:	6125                	addi	sp,sp,96
  8000d6:	8082                	ret

00000000008000d8 <sys_exit>:
    );

    return ret;
}

int sys_exit(int64_t error_code) {
  8000d8:	7139                	addi	sp,sp,-64
  8000da:	4785                	li	a5,1
  8000dc:	e83e                	sd	a5,16(sp)
  8000de:	ec2a                	sd	a0,24(sp)
  8000e0:	f002                	sd	zero,32(sp)
  8000e2:	f402                	sd	zero,40(sp)
  8000e4:	f802                	sd	zero,48(sp)
  8000e6:	fc02                	sd	zero,56(sp)
    asm volatile (
  8000e8:	6542                	ld	a0,16(sp)
  8000ea:	65e2                	ld	a1,24(sp)
  8000ec:	7602                	ld	a2,32(sp)
  8000ee:	76a2                	ld	a3,40(sp)
  8000f0:	7742                	ld	a4,48(sp)
  8000f2:	77e2                	ld	a5,56(sp)
  8000f4:	00000073          	ecall
  8000f8:	c62a                	sw	a0,12(sp)
    return syscall(SYS_exit, error_code, 0, 0, 0, 0);
}
  8000fa:	4532                	lw	a0,12(sp)
  8000fc:	6121                	addi	sp,sp,64
  8000fe:	8082                	ret

0000000000800100 <sys_fork>:

int sys_fork(void) {
  800100:	7139                	addi	sp,sp,-64
  800102:	4789                	li	a5,2
  800104:	e83e                	sd	a5,16(sp)
  800106:	ec02                	sd	zero,24(sp)
  800108:	f002                	sd	zero,32(sp)
  80010a:	f402                	sd	zero,40(sp)
  80010c:	f802                	sd	zero,48(sp)
  80010e:	fc02                	sd	zero,56(sp)
    asm volatile (
  800110:	6542                	ld	a0,16(sp)
  800112:	65e2                	ld	a1,24(sp)
  800114:	7602                	ld	a2,32(sp)
  800116:	76a2                	ld	a3,40(sp)
  800118:	7742                	ld	a4,48(sp)
  80011a:	77e2                	ld	a5,56(sp)
  80011c:	00000073          	ecall
  800120:	c62a                	sw	a0,12(sp)
    return syscall(SYS_fork, 0, 0, 0, 0, 0);
}
  800122:	4532                	lw	a0,12(sp)
  800124:	6121                	addi	sp,sp,64
  800126:	8082                	ret

0000000000800128 <sys_wait>:

int sys_wait(int64_t pid, int *store) {
  800128:	7139                	addi	sp,sp,-64
  80012a:	478d                	li	a5,3
  80012c:	e83e                	sd	a5,16(sp)
  80012e:	ec2a                	sd	a0,24(sp)
  800130:	f02e                	sd	a1,32(sp)
  800132:	f402                	sd	zero,40(sp)
  800134:	f802                	sd	zero,48(sp)
  800136:	fc02                	sd	zero,56(sp)
    asm volatile (
  800138:	6542                	ld	a0,16(sp)
  80013a:	65e2                	ld	a1,24(sp)
  80013c:	7602                	ld	a2,32(sp)
  80013e:	76a2                	ld	a3,40(sp)
  800140:	7742                	ld	a4,48(sp)
  800142:	77e2                	ld	a5,56(sp)
  800144:	00000073          	ecall
  800148:	c62a                	sw	a0,12(sp)
    return syscall(SYS_wait, pid, (uintptr_t)store, 0, 0, 0);
}
  80014a:	4532                	lw	a0,12(sp)
  80014c:	6121                	addi	sp,sp,64
  80014e:	8082                	ret

0000000000800150 <sys_yield>:

int sys_yield(void) {
  800150:	7139                	addi	sp,sp,-64
  800152:	47a9                	li	a5,10
  800154:	e83e                	sd	a5,16(sp)
  800156:	ec02                	sd	zero,24(sp)
  800158:	f002                	sd	zero,32(sp)
  80015a:	f402                	sd	zero,40(sp)
  80015c:	f802                	sd	zero,48(sp)
  80015e:	fc02                	sd	zero,56(sp)
    asm volatile (
  800160:	6542                	ld	a0,16(sp)
  800162:	65e2                	ld	a1,24(sp)
  800164:	7602                	ld	a2,32(sp)
  800166:	76a2                	ld	a3,40(sp)
  800168:	7742                	ld	a4,48(sp)
  80016a:	77e2                	ld	a5,56(sp)
  80016c:	00000073          	ecall
  800170:	c62a                	sw	a0,12(sp)
    return syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  800172:	4532                	lw	a0,12(sp)
  800174:	6121                	addi	sp,sp,64
  800176:	8082                	ret

0000000000800178 <sys_kill>:

int sys_kill(int64_t pid) {
  800178:	7139                	addi	sp,sp,-64
  80017a:	47b1                	li	a5,12
  80017c:	e83e                	sd	a5,16(sp)
  80017e:	ec2a                	sd	a0,24(sp)
  800180:	f002                	sd	zero,32(sp)
  800182:	f402                	sd	zero,40(sp)
  800184:	f802                	sd	zero,48(sp)
  800186:	fc02                	sd	zero,56(sp)
    asm volatile (
  800188:	6542                	ld	a0,16(sp)
  80018a:	65e2                	ld	a1,24(sp)
  80018c:	7602                	ld	a2,32(sp)
  80018e:	76a2                	ld	a3,40(sp)
  800190:	7742                	ld	a4,48(sp)
  800192:	77e2                	ld	a5,56(sp)
  800194:	00000073          	ecall
  800198:	c62a                	sw	a0,12(sp)
    return syscall(SYS_kill, pid, 0, 0, 0, 0);
}
  80019a:	4532                	lw	a0,12(sp)
  80019c:	6121                	addi	sp,sp,64
  80019e:	8082                	ret

00000000008001a0 <sys_putc>:

int sys_getpid(void) {
    return syscall(SYS_getpid, 0, 0, 0, 0, 0);
}

int sys_putc(int64_t c) {
  8001a0:	7139                	addi	sp,sp,-64
  8001a2:	47f9                	li	a5,30
  8001a4:	e83e                	sd	a5,16(sp)
  8001a6:	ec2a                	sd	a0,24(sp)
  8001a8:	f002                	sd	zero,32(sp)
  8001aa:	f402                	sd	zero,40(sp)
  8001ac:	f802                	sd	zero,48(sp)
  8001ae:	fc02                	sd	zero,56(sp)
    asm volatile (
  8001b0:	6542                	ld	a0,16(sp)
  8001b2:	65e2                	ld	a1,24(sp)
  8001b4:	7602                	ld	a2,32(sp)
  8001b6:	76a2                	ld	a3,40(sp)
  8001b8:	7742                	ld	a4,48(sp)
  8001ba:	77e2                	ld	a5,56(sp)
  8001bc:	00000073          	ecall
  8001c0:	c62a                	sw	a0,12(sp)
    return syscall(SYS_putc, c, 0, 0, 0, 0);
}
  8001c2:	4532                	lw	a0,12(sp)
  8001c4:	6121                	addi	sp,sp,64
  8001c6:	8082                	ret

00000000008001c8 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8001c8:	1141                	addi	sp,sp,-16
  8001ca:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8001cc:	f0dff0ef          	jal	ra,8000d8 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8001d0:	00000517          	auipc	a0,0x0
  8001d4:	52050513          	addi	a0,a0,1312 # 8006f0 <main+0xf4>
  8001d8:	ecbff0ef          	jal	ra,8000a2 <cprintf>
    while (1);
  8001dc:	a001                	j	8001dc <exit+0x14>

00000000008001de <fork>:
}

int
fork(void) {
    return sys_fork();
  8001de:	b70d                	j	800100 <sys_fork>

00000000008001e0 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8001e0:	b7a1                	j	800128 <sys_wait>

00000000008001e2 <yield>:
}

void
yield(void) {
    sys_yield();
  8001e2:	b7bd                	j	800150 <sys_yield>

00000000008001e4 <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  8001e4:	bf51                	j	800178 <sys_kill>

00000000008001e6 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8001e6:	1141                	addi	sp,sp,-16
  8001e8:	e406                	sd	ra,8(sp)
    int ret = main();
  8001ea:	412000ef          	jal	ra,8005fc <main>
    exit(ret);
  8001ee:	fdbff0ef          	jal	ra,8001c8 <exit>

00000000008001f2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8001f2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8001f6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8001f8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8001fc:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8001fe:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800202:	f022                	sd	s0,32(sp)
  800204:	ec26                	sd	s1,24(sp)
  800206:	e84a                	sd	s2,16(sp)
  800208:	f406                	sd	ra,40(sp)
  80020a:	e44e                	sd	s3,8(sp)
  80020c:	84aa                	mv	s1,a0
  80020e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800210:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800214:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800216:	03067e63          	bgeu	a2,a6,800252 <printnum+0x60>
  80021a:	89be                	mv	s3,a5
        while (-- width > 0)
  80021c:	00805763          	blez	s0,80022a <printnum+0x38>
  800220:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800222:	85ca                	mv	a1,s2
  800224:	854e                	mv	a0,s3
  800226:	9482                	jalr	s1
        while (-- width > 0)
  800228:	fc65                	bnez	s0,800220 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80022a:	1a02                	slli	s4,s4,0x20
  80022c:	00000797          	auipc	a5,0x0
  800230:	4dc78793          	addi	a5,a5,1244 # 800708 <main+0x10c>
  800234:	020a5a13          	srli	s4,s4,0x20
  800238:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80023a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80023c:	000a4503          	lbu	a0,0(s4)
}
  800240:	70a2                	ld	ra,40(sp)
  800242:	69a2                	ld	s3,8(sp)
  800244:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800246:	85ca                	mv	a1,s2
  800248:	87a6                	mv	a5,s1
}
  80024a:	6942                	ld	s2,16(sp)
  80024c:	64e2                	ld	s1,24(sp)
  80024e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800250:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800252:	03065633          	divu	a2,a2,a6
  800256:	8722                	mv	a4,s0
  800258:	f9bff0ef          	jal	ra,8001f2 <printnum>
  80025c:	b7f9                	j	80022a <printnum+0x38>

000000000080025e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80025e:	7119                	addi	sp,sp,-128
  800260:	f4a6                	sd	s1,104(sp)
  800262:	f0ca                	sd	s2,96(sp)
  800264:	ecce                	sd	s3,88(sp)
  800266:	e8d2                	sd	s4,80(sp)
  800268:	e4d6                	sd	s5,72(sp)
  80026a:	e0da                	sd	s6,64(sp)
  80026c:	fc5e                	sd	s7,56(sp)
  80026e:	f06a                	sd	s10,32(sp)
  800270:	fc86                	sd	ra,120(sp)
  800272:	f8a2                	sd	s0,112(sp)
  800274:	f862                	sd	s8,48(sp)
  800276:	f466                	sd	s9,40(sp)
  800278:	ec6e                	sd	s11,24(sp)
  80027a:	892a                	mv	s2,a0
  80027c:	84ae                	mv	s1,a1
  80027e:	8d32                	mv	s10,a2
  800280:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800282:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800286:	5b7d                	li	s6,-1
  800288:	00000a97          	auipc	s5,0x0
  80028c:	4b4a8a93          	addi	s5,s5,1204 # 80073c <main+0x140>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800290:	00000b97          	auipc	s7,0x0
  800294:	6c8b8b93          	addi	s7,s7,1736 # 800958 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800298:	000d4503          	lbu	a0,0(s10)
  80029c:	001d0413          	addi	s0,s10,1
  8002a0:	01350a63          	beq	a0,s3,8002b4 <vprintfmt+0x56>
            if (ch == '\0') {
  8002a4:	c121                	beqz	a0,8002e4 <vprintfmt+0x86>
            putch(ch, putdat);
  8002a6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8002a8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8002aa:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8002ac:	fff44503          	lbu	a0,-1(s0)
  8002b0:	ff351ae3          	bne	a0,s3,8002a4 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  8002b4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8002b8:	02000793          	li	a5,32
        lflag = altflag = 0;
  8002bc:	4c81                	li	s9,0
  8002be:	4881                	li	a7,0
        width = precision = -1;
  8002c0:	5c7d                	li	s8,-1
  8002c2:	5dfd                	li	s11,-1
  8002c4:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  8002c8:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  8002ca:	fdd6059b          	addiw	a1,a2,-35
  8002ce:	0ff5f593          	andi	a1,a1,255
  8002d2:	00140d13          	addi	s10,s0,1
  8002d6:	04b56263          	bltu	a0,a1,80031a <vprintfmt+0xbc>
  8002da:	058a                	slli	a1,a1,0x2
  8002dc:	95d6                	add	a1,a1,s5
  8002de:	4194                	lw	a3,0(a1)
  8002e0:	96d6                	add	a3,a3,s5
  8002e2:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8002e4:	70e6                	ld	ra,120(sp)
  8002e6:	7446                	ld	s0,112(sp)
  8002e8:	74a6                	ld	s1,104(sp)
  8002ea:	7906                	ld	s2,96(sp)
  8002ec:	69e6                	ld	s3,88(sp)
  8002ee:	6a46                	ld	s4,80(sp)
  8002f0:	6aa6                	ld	s5,72(sp)
  8002f2:	6b06                	ld	s6,64(sp)
  8002f4:	7be2                	ld	s7,56(sp)
  8002f6:	7c42                	ld	s8,48(sp)
  8002f8:	7ca2                	ld	s9,40(sp)
  8002fa:	7d02                	ld	s10,32(sp)
  8002fc:	6de2                	ld	s11,24(sp)
  8002fe:	6109                	addi	sp,sp,128
  800300:	8082                	ret
            padc = '0';
  800302:	87b2                	mv	a5,a2
            goto reswitch;
  800304:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800308:	846a                	mv	s0,s10
  80030a:	00140d13          	addi	s10,s0,1
  80030e:	fdd6059b          	addiw	a1,a2,-35
  800312:	0ff5f593          	andi	a1,a1,255
  800316:	fcb572e3          	bgeu	a0,a1,8002da <vprintfmt+0x7c>
            putch('%', putdat);
  80031a:	85a6                	mv	a1,s1
  80031c:	02500513          	li	a0,37
  800320:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800322:	fff44783          	lbu	a5,-1(s0)
  800326:	8d22                	mv	s10,s0
  800328:	f73788e3          	beq	a5,s3,800298 <vprintfmt+0x3a>
  80032c:	ffed4783          	lbu	a5,-2(s10)
  800330:	1d7d                	addi	s10,s10,-1
  800332:	ff379de3          	bne	a5,s3,80032c <vprintfmt+0xce>
  800336:	b78d                	j	800298 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  800338:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  80033c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800340:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800342:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800346:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  80034a:	02d86463          	bltu	a6,a3,800372 <vprintfmt+0x114>
                ch = *fmt;
  80034e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  800352:	002c169b          	slliw	a3,s8,0x2
  800356:	0186873b          	addw	a4,a3,s8
  80035a:	0017171b          	slliw	a4,a4,0x1
  80035e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  800360:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  800364:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800366:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  80036a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  80036e:	fed870e3          	bgeu	a6,a3,80034e <vprintfmt+0xf0>
            if (width < 0)
  800372:	f40ddce3          	bgez	s11,8002ca <vprintfmt+0x6c>
                width = precision, precision = -1;
  800376:	8de2                	mv	s11,s8
  800378:	5c7d                	li	s8,-1
  80037a:	bf81                	j	8002ca <vprintfmt+0x6c>
            if (width < 0)
  80037c:	fffdc693          	not	a3,s11
  800380:	96fd                	srai	a3,a3,0x3f
  800382:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  800386:	00144603          	lbu	a2,1(s0)
  80038a:	2d81                	sext.w	s11,s11
  80038c:	846a                	mv	s0,s10
            goto reswitch;
  80038e:	bf35                	j	8002ca <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  800390:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800394:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800398:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  80039a:	846a                	mv	s0,s10
            goto process_precision;
  80039c:	bfd9                	j	800372 <vprintfmt+0x114>
    if (lflag >= 2) {
  80039e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003a0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8003a4:	01174463          	blt	a4,a7,8003ac <vprintfmt+0x14e>
    else if (lflag) {
  8003a8:	1a088e63          	beqz	a7,800564 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  8003ac:	000a3603          	ld	a2,0(s4)
  8003b0:	46c1                	li	a3,16
  8003b2:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8003b4:	2781                	sext.w	a5,a5
  8003b6:	876e                	mv	a4,s11
  8003b8:	85a6                	mv	a1,s1
  8003ba:	854a                	mv	a0,s2
  8003bc:	e37ff0ef          	jal	ra,8001f2 <printnum>
            break;
  8003c0:	bde1                	j	800298 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  8003c2:	000a2503          	lw	a0,0(s4)
  8003c6:	85a6                	mv	a1,s1
  8003c8:	0a21                	addi	s4,s4,8
  8003ca:	9902                	jalr	s2
            break;
  8003cc:	b5f1                	j	800298 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003ce:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003d0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8003d4:	01174463          	blt	a4,a7,8003dc <vprintfmt+0x17e>
    else if (lflag) {
  8003d8:	18088163          	beqz	a7,80055a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  8003dc:	000a3603          	ld	a2,0(s4)
  8003e0:	46a9                	li	a3,10
  8003e2:	8a2e                	mv	s4,a1
  8003e4:	bfc1                	j	8003b4 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  8003e6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8003ea:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003ec:	846a                	mv	s0,s10
            goto reswitch;
  8003ee:	bdf1                	j	8002ca <vprintfmt+0x6c>
            putch(ch, putdat);
  8003f0:	85a6                	mv	a1,s1
  8003f2:	02500513          	li	a0,37
  8003f6:	9902                	jalr	s2
            break;
  8003f8:	b545                	j	800298 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  8003fa:	00144603          	lbu	a2,1(s0)
            lflag ++;
  8003fe:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  800400:	846a                	mv	s0,s10
            goto reswitch;
  800402:	b5e1                	j	8002ca <vprintfmt+0x6c>
    if (lflag >= 2) {
  800404:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800406:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80040a:	01174463          	blt	a4,a7,800412 <vprintfmt+0x1b4>
    else if (lflag) {
  80040e:	14088163          	beqz	a7,800550 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  800412:	000a3603          	ld	a2,0(s4)
  800416:	46a1                	li	a3,8
  800418:	8a2e                	mv	s4,a1
  80041a:	bf69                	j	8003b4 <vprintfmt+0x156>
            putch('0', putdat);
  80041c:	03000513          	li	a0,48
  800420:	85a6                	mv	a1,s1
  800422:	e03e                	sd	a5,0(sp)
  800424:	9902                	jalr	s2
            putch('x', putdat);
  800426:	85a6                	mv	a1,s1
  800428:	07800513          	li	a0,120
  80042c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80042e:	0a21                	addi	s4,s4,8
            goto number;
  800430:	6782                	ld	a5,0(sp)
  800432:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800434:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  800438:	bfb5                	j	8003b4 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  80043a:	000a3403          	ld	s0,0(s4)
  80043e:	008a0713          	addi	a4,s4,8
  800442:	e03a                	sd	a4,0(sp)
  800444:	14040263          	beqz	s0,800588 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  800448:	0fb05763          	blez	s11,800536 <vprintfmt+0x2d8>
  80044c:	02d00693          	li	a3,45
  800450:	0cd79163          	bne	a5,a3,800512 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800454:	00044783          	lbu	a5,0(s0)
  800458:	0007851b          	sext.w	a0,a5
  80045c:	cf85                	beqz	a5,800494 <vprintfmt+0x236>
  80045e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  800462:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800466:	000c4563          	bltz	s8,800470 <vprintfmt+0x212>
  80046a:	3c7d                	addiw	s8,s8,-1
  80046c:	036c0263          	beq	s8,s6,800490 <vprintfmt+0x232>
                    putch('?', putdat);
  800470:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800472:	0e0c8e63          	beqz	s9,80056e <vprintfmt+0x310>
  800476:	3781                	addiw	a5,a5,-32
  800478:	0ef47b63          	bgeu	s0,a5,80056e <vprintfmt+0x310>
                    putch('?', putdat);
  80047c:	03f00513          	li	a0,63
  800480:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800482:	000a4783          	lbu	a5,0(s4)
  800486:	3dfd                	addiw	s11,s11,-1
  800488:	0a05                	addi	s4,s4,1
  80048a:	0007851b          	sext.w	a0,a5
  80048e:	ffe1                	bnez	a5,800466 <vprintfmt+0x208>
            for (; width > 0; width --) {
  800490:	01b05963          	blez	s11,8004a2 <vprintfmt+0x244>
  800494:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800496:	85a6                	mv	a1,s1
  800498:	02000513          	li	a0,32
  80049c:	9902                	jalr	s2
            for (; width > 0; width --) {
  80049e:	fe0d9be3          	bnez	s11,800494 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004a2:	6a02                	ld	s4,0(sp)
  8004a4:	bbd5                	j	800298 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8004a6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8004a8:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  8004ac:	01174463          	blt	a4,a7,8004b4 <vprintfmt+0x256>
    else if (lflag) {
  8004b0:	08088d63          	beqz	a7,80054a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  8004b4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8004b8:	0a044d63          	bltz	s0,800572 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  8004bc:	8622                	mv	a2,s0
  8004be:	8a66                	mv	s4,s9
  8004c0:	46a9                	li	a3,10
  8004c2:	bdcd                	j	8003b4 <vprintfmt+0x156>
            err = va_arg(ap, int);
  8004c4:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8004c8:	4761                	li	a4,24
            err = va_arg(ap, int);
  8004ca:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8004cc:	41f7d69b          	sraiw	a3,a5,0x1f
  8004d0:	8fb5                	xor	a5,a5,a3
  8004d2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8004d6:	02d74163          	blt	a4,a3,8004f8 <vprintfmt+0x29a>
  8004da:	00369793          	slli	a5,a3,0x3
  8004de:	97de                	add	a5,a5,s7
  8004e0:	639c                	ld	a5,0(a5)
  8004e2:	cb99                	beqz	a5,8004f8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  8004e4:	86be                	mv	a3,a5
  8004e6:	00000617          	auipc	a2,0x0
  8004ea:	25260613          	addi	a2,a2,594 # 800738 <main+0x13c>
  8004ee:	85a6                	mv	a1,s1
  8004f0:	854a                	mv	a0,s2
  8004f2:	0ce000ef          	jal	ra,8005c0 <printfmt>
  8004f6:	b34d                	j	800298 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8004f8:	00000617          	auipc	a2,0x0
  8004fc:	23060613          	addi	a2,a2,560 # 800728 <main+0x12c>
  800500:	85a6                	mv	a1,s1
  800502:	854a                	mv	a0,s2
  800504:	0bc000ef          	jal	ra,8005c0 <printfmt>
  800508:	bb41                	j	800298 <vprintfmt+0x3a>
                p = "(null)";
  80050a:	00000417          	auipc	s0,0x0
  80050e:	21640413          	addi	s0,s0,534 # 800720 <main+0x124>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800512:	85e2                	mv	a1,s8
  800514:	8522                	mv	a0,s0
  800516:	e43e                	sd	a5,8(sp)
  800518:	0c8000ef          	jal	ra,8005e0 <strnlen>
  80051c:	40ad8dbb          	subw	s11,s11,a0
  800520:	01b05b63          	blez	s11,800536 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  800524:	67a2                	ld	a5,8(sp)
  800526:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  80052a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  80052c:	85a6                	mv	a1,s1
  80052e:	8552                	mv	a0,s4
  800530:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800532:	fe0d9ce3          	bnez	s11,80052a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800536:	00044783          	lbu	a5,0(s0)
  80053a:	00140a13          	addi	s4,s0,1
  80053e:	0007851b          	sext.w	a0,a5
  800542:	d3a5                	beqz	a5,8004a2 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  800544:	05e00413          	li	s0,94
  800548:	bf39                	j	800466 <vprintfmt+0x208>
        return va_arg(*ap, int);
  80054a:	000a2403          	lw	s0,0(s4)
  80054e:	b7ad                	j	8004b8 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  800550:	000a6603          	lwu	a2,0(s4)
  800554:	46a1                	li	a3,8
  800556:	8a2e                	mv	s4,a1
  800558:	bdb1                	j	8003b4 <vprintfmt+0x156>
  80055a:	000a6603          	lwu	a2,0(s4)
  80055e:	46a9                	li	a3,10
  800560:	8a2e                	mv	s4,a1
  800562:	bd89                	j	8003b4 <vprintfmt+0x156>
  800564:	000a6603          	lwu	a2,0(s4)
  800568:	46c1                	li	a3,16
  80056a:	8a2e                	mv	s4,a1
  80056c:	b5a1                	j	8003b4 <vprintfmt+0x156>
                    putch(ch, putdat);
  80056e:	9902                	jalr	s2
  800570:	bf09                	j	800482 <vprintfmt+0x224>
                putch('-', putdat);
  800572:	85a6                	mv	a1,s1
  800574:	02d00513          	li	a0,45
  800578:	e03e                	sd	a5,0(sp)
  80057a:	9902                	jalr	s2
                num = -(long long)num;
  80057c:	6782                	ld	a5,0(sp)
  80057e:	8a66                	mv	s4,s9
  800580:	40800633          	neg	a2,s0
  800584:	46a9                	li	a3,10
  800586:	b53d                	j	8003b4 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  800588:	03b05163          	blez	s11,8005aa <vprintfmt+0x34c>
  80058c:	02d00693          	li	a3,45
  800590:	f6d79de3          	bne	a5,a3,80050a <vprintfmt+0x2ac>
                p = "(null)";
  800594:	00000417          	auipc	s0,0x0
  800598:	18c40413          	addi	s0,s0,396 # 800720 <main+0x124>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80059c:	02800793          	li	a5,40
  8005a0:	02800513          	li	a0,40
  8005a4:	00140a13          	addi	s4,s0,1
  8005a8:	bd6d                	j	800462 <vprintfmt+0x204>
  8005aa:	00000a17          	auipc	s4,0x0
  8005ae:	177a0a13          	addi	s4,s4,375 # 800721 <main+0x125>
  8005b2:	02800513          	li	a0,40
  8005b6:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  8005ba:	05e00413          	li	s0,94
  8005be:	b565                	j	800466 <vprintfmt+0x208>

00000000008005c0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8005c0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8005c2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8005c6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8005c8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8005ca:	ec06                	sd	ra,24(sp)
  8005cc:	f83a                	sd	a4,48(sp)
  8005ce:	fc3e                	sd	a5,56(sp)
  8005d0:	e0c2                	sd	a6,64(sp)
  8005d2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8005d4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8005d6:	c89ff0ef          	jal	ra,80025e <vprintfmt>
}
  8005da:	60e2                	ld	ra,24(sp)
  8005dc:	6161                	addi	sp,sp,80
  8005de:	8082                	ret

00000000008005e0 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8005e0:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8005e2:	e589                	bnez	a1,8005ec <strnlen+0xc>
  8005e4:	a811                	j	8005f8 <strnlen+0x18>
        cnt ++;
  8005e6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8005e8:	00f58863          	beq	a1,a5,8005f8 <strnlen+0x18>
  8005ec:	00f50733          	add	a4,a0,a5
  8005f0:	00074703          	lbu	a4,0(a4)
  8005f4:	fb6d                	bnez	a4,8005e6 <strnlen+0x6>
  8005f6:	85be                	mv	a1,a5
    }
    return cnt;
}
  8005f8:	852e                	mv	a0,a1
  8005fa:	8082                	ret

00000000008005fc <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8005fc:	1141                	addi	sp,sp,-16
    int pid, ret;
    cprintf("I am the parent. Forking the child...\n");
  8005fe:	00000517          	auipc	a0,0x0
  800602:	42250513          	addi	a0,a0,1058 # 800a20 <error_string+0xc8>
main(void) {
  800606:	e406                	sd	ra,8(sp)
  800608:	e022                	sd	s0,0(sp)
    cprintf("I am the parent. Forking the child...\n");
  80060a:	a99ff0ef          	jal	ra,8000a2 <cprintf>
    if ((pid = fork()) == 0) {
  80060e:	bd1ff0ef          	jal	ra,8001de <fork>
  800612:	e901                	bnez	a0,800622 <main+0x26>
        cprintf("I am the child. spinning ...\n");
  800614:	00000517          	auipc	a0,0x0
  800618:	43450513          	addi	a0,a0,1076 # 800a48 <error_string+0xf0>
  80061c:	a87ff0ef          	jal	ra,8000a2 <cprintf>
        while (1);
  800620:	a001                	j	800620 <main+0x24>
    }
    cprintf("I am the parent. Running the child...\n");
  800622:	842a                	mv	s0,a0
  800624:	00000517          	auipc	a0,0x0
  800628:	44450513          	addi	a0,a0,1092 # 800a68 <error_string+0x110>
  80062c:	a77ff0ef          	jal	ra,8000a2 <cprintf>

    yield();
  800630:	bb3ff0ef          	jal	ra,8001e2 <yield>
    yield();
  800634:	bafff0ef          	jal	ra,8001e2 <yield>
    yield();
  800638:	babff0ef          	jal	ra,8001e2 <yield>

    cprintf("I am the parent.  Killing the child...\n");
  80063c:	00000517          	auipc	a0,0x0
  800640:	45450513          	addi	a0,a0,1108 # 800a90 <error_string+0x138>
  800644:	a5fff0ef          	jal	ra,8000a2 <cprintf>

    assert((ret = kill(pid)) == 0);
  800648:	8522                	mv	a0,s0
  80064a:	b9bff0ef          	jal	ra,8001e4 <kill>
  80064e:	ed31                	bnez	a0,8006aa <main+0xae>
    cprintf("kill returns %d\n", ret);
  800650:	4581                	li	a1,0
  800652:	00000517          	auipc	a0,0x0
  800656:	4a650513          	addi	a0,a0,1190 # 800af8 <error_string+0x1a0>
  80065a:	a49ff0ef          	jal	ra,8000a2 <cprintf>

    assert((ret = waitpid(pid, NULL)) == 0);
  80065e:	4581                	li	a1,0
  800660:	8522                	mv	a0,s0
  800662:	b7fff0ef          	jal	ra,8001e0 <waitpid>
  800666:	e11d                	bnez	a0,80068c <main+0x90>
    cprintf("wait returns %d\n", ret);
  800668:	4581                	li	a1,0
  80066a:	00000517          	auipc	a0,0x0
  80066e:	4c650513          	addi	a0,a0,1222 # 800b30 <error_string+0x1d8>
  800672:	a31ff0ef          	jal	ra,8000a2 <cprintf>

    cprintf("spin may pass.\n");
  800676:	00000517          	auipc	a0,0x0
  80067a:	4d250513          	addi	a0,a0,1234 # 800b48 <error_string+0x1f0>
  80067e:	a25ff0ef          	jal	ra,8000a2 <cprintf>
    return 0;
}
  800682:	60a2                	ld	ra,8(sp)
  800684:	6402                	ld	s0,0(sp)
  800686:	4501                	li	a0,0
  800688:	0141                	addi	sp,sp,16
  80068a:	8082                	ret
    assert((ret = waitpid(pid, NULL)) == 0);
  80068c:	00000697          	auipc	a3,0x0
  800690:	48468693          	addi	a3,a3,1156 # 800b10 <error_string+0x1b8>
  800694:	00000617          	auipc	a2,0x0
  800698:	43c60613          	addi	a2,a2,1084 # 800ad0 <error_string+0x178>
  80069c:	45dd                	li	a1,23
  80069e:	00000517          	auipc	a0,0x0
  8006a2:	44a50513          	addi	a0,a0,1098 # 800ae8 <error_string+0x190>
  8006a6:	981ff0ef          	jal	ra,800026 <__panic>
    assert((ret = kill(pid)) == 0);
  8006aa:	00000697          	auipc	a3,0x0
  8006ae:	40e68693          	addi	a3,a3,1038 # 800ab8 <error_string+0x160>
  8006b2:	00000617          	auipc	a2,0x0
  8006b6:	41e60613          	addi	a2,a2,1054 # 800ad0 <error_string+0x178>
  8006ba:	45d1                	li	a1,20
  8006bc:	00000517          	auipc	a0,0x0
  8006c0:	42c50513          	addi	a0,a0,1068 # 800ae8 <error_string+0x190>
  8006c4:	963ff0ef          	jal	ra,800026 <__panic>
