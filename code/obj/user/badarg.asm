
obj/__user_badarg.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	19c000ef          	jal	ra,8001bc <umain>
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
  80003a:	68a50513          	addi	a0,a0,1674 # 8006c0 <main+0xee>
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
  800056:	00001517          	auipc	a0,0x1
  80005a:	9c250513          	addi	a0,a0,-1598 # 800a18 <error_string+0xd0>
  80005e:	044000ef          	jal	ra,8000a2 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	13c000ef          	jal	ra,8001a0 <exit>

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
  800070:	108000ef          	jal	ra,800178 <sys_putc>
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
  800096:	19e000ef          	jal	ra,800234 <vprintfmt>
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
  8000cc:	168000ef          	jal	ra,800234 <vprintfmt>
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

0000000000800178 <sys_putc>:

int sys_getpid(void) {
    return syscall(SYS_getpid, 0, 0, 0, 0, 0);
}

int sys_putc(int64_t c) {
  800178:	7139                	addi	sp,sp,-64
  80017a:	47f9                	li	a5,30
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
    return syscall(SYS_putc, c, 0, 0, 0, 0);
}
  80019a:	4532                	lw	a0,12(sp)
  80019c:	6121                	addi	sp,sp,64
  80019e:	8082                	ret

00000000008001a0 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8001a0:	1141                	addi	sp,sp,-16
  8001a2:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8001a4:	f35ff0ef          	jal	ra,8000d8 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8001a8:	00000517          	auipc	a0,0x0
  8001ac:	53850513          	addi	a0,a0,1336 # 8006e0 <main+0x10e>
  8001b0:	ef3ff0ef          	jal	ra,8000a2 <cprintf>
    while (1);
  8001b4:	a001                	j	8001b4 <exit+0x14>

00000000008001b6 <fork>:
}

int
fork(void) {
    return sys_fork();
  8001b6:	b7a9                	j	800100 <sys_fork>

00000000008001b8 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8001b8:	bf85                	j	800128 <sys_wait>

00000000008001ba <yield>:
}

void
yield(void) {
    sys_yield();
  8001ba:	bf59                	j	800150 <sys_yield>

00000000008001bc <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8001bc:	1141                	addi	sp,sp,-16
  8001be:	e406                	sd	ra,8(sp)
    int ret = main();
  8001c0:	412000ef          	jal	ra,8005d2 <main>
    exit(ret);
  8001c4:	fddff0ef          	jal	ra,8001a0 <exit>

00000000008001c8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8001c8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8001cc:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8001ce:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8001d2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8001d4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8001d8:	f022                	sd	s0,32(sp)
  8001da:	ec26                	sd	s1,24(sp)
  8001dc:	e84a                	sd	s2,16(sp)
  8001de:	f406                	sd	ra,40(sp)
  8001e0:	e44e                	sd	s3,8(sp)
  8001e2:	84aa                	mv	s1,a0
  8001e4:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001e6:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8001ea:	2a01                	sext.w	s4,s4
    if (num >= base) {
  8001ec:	03067e63          	bgeu	a2,a6,800228 <printnum+0x60>
  8001f0:	89be                	mv	s3,a5
        while (-- width > 0)
  8001f2:	00805763          	blez	s0,800200 <printnum+0x38>
  8001f6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001f8:	85ca                	mv	a1,s2
  8001fa:	854e                	mv	a0,s3
  8001fc:	9482                	jalr	s1
        while (-- width > 0)
  8001fe:	fc65                	bnez	s0,8001f6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800200:	1a02                	slli	s4,s4,0x20
  800202:	00000797          	auipc	a5,0x0
  800206:	4f678793          	addi	a5,a5,1270 # 8006f8 <main+0x126>
  80020a:	020a5a13          	srli	s4,s4,0x20
  80020e:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800210:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800212:	000a4503          	lbu	a0,0(s4)
}
  800216:	70a2                	ld	ra,40(sp)
  800218:	69a2                	ld	s3,8(sp)
  80021a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80021c:	85ca                	mv	a1,s2
  80021e:	87a6                	mv	a5,s1
}
  800220:	6942                	ld	s2,16(sp)
  800222:	64e2                	ld	s1,24(sp)
  800224:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800226:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800228:	03065633          	divu	a2,a2,a6
  80022c:	8722                	mv	a4,s0
  80022e:	f9bff0ef          	jal	ra,8001c8 <printnum>
  800232:	b7f9                	j	800200 <printnum+0x38>

0000000000800234 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800234:	7119                	addi	sp,sp,-128
  800236:	f4a6                	sd	s1,104(sp)
  800238:	f0ca                	sd	s2,96(sp)
  80023a:	ecce                	sd	s3,88(sp)
  80023c:	e8d2                	sd	s4,80(sp)
  80023e:	e4d6                	sd	s5,72(sp)
  800240:	e0da                	sd	s6,64(sp)
  800242:	fc5e                	sd	s7,56(sp)
  800244:	f06a                	sd	s10,32(sp)
  800246:	fc86                	sd	ra,120(sp)
  800248:	f8a2                	sd	s0,112(sp)
  80024a:	f862                	sd	s8,48(sp)
  80024c:	f466                	sd	s9,40(sp)
  80024e:	ec6e                	sd	s11,24(sp)
  800250:	892a                	mv	s2,a0
  800252:	84ae                	mv	s1,a1
  800254:	8d32                	mv	s10,a2
  800256:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800258:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  80025c:	5b7d                	li	s6,-1
  80025e:	00000a97          	auipc	s5,0x0
  800262:	4cea8a93          	addi	s5,s5,1230 # 80072c <main+0x15a>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800266:	00000b97          	auipc	s7,0x0
  80026a:	6e2b8b93          	addi	s7,s7,1762 # 800948 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80026e:	000d4503          	lbu	a0,0(s10)
  800272:	001d0413          	addi	s0,s10,1
  800276:	01350a63          	beq	a0,s3,80028a <vprintfmt+0x56>
            if (ch == '\0') {
  80027a:	c121                	beqz	a0,8002ba <vprintfmt+0x86>
            putch(ch, putdat);
  80027c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80027e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800280:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800282:	fff44503          	lbu	a0,-1(s0)
  800286:	ff351ae3          	bne	a0,s3,80027a <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  80028a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80028e:	02000793          	li	a5,32
        lflag = altflag = 0;
  800292:	4c81                	li	s9,0
  800294:	4881                	li	a7,0
        width = precision = -1;
  800296:	5c7d                	li	s8,-1
  800298:	5dfd                	li	s11,-1
  80029a:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  80029e:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  8002a0:	fdd6059b          	addiw	a1,a2,-35
  8002a4:	0ff5f593          	andi	a1,a1,255
  8002a8:	00140d13          	addi	s10,s0,1
  8002ac:	04b56263          	bltu	a0,a1,8002f0 <vprintfmt+0xbc>
  8002b0:	058a                	slli	a1,a1,0x2
  8002b2:	95d6                	add	a1,a1,s5
  8002b4:	4194                	lw	a3,0(a1)
  8002b6:	96d6                	add	a3,a3,s5
  8002b8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8002ba:	70e6                	ld	ra,120(sp)
  8002bc:	7446                	ld	s0,112(sp)
  8002be:	74a6                	ld	s1,104(sp)
  8002c0:	7906                	ld	s2,96(sp)
  8002c2:	69e6                	ld	s3,88(sp)
  8002c4:	6a46                	ld	s4,80(sp)
  8002c6:	6aa6                	ld	s5,72(sp)
  8002c8:	6b06                	ld	s6,64(sp)
  8002ca:	7be2                	ld	s7,56(sp)
  8002cc:	7c42                	ld	s8,48(sp)
  8002ce:	7ca2                	ld	s9,40(sp)
  8002d0:	7d02                	ld	s10,32(sp)
  8002d2:	6de2                	ld	s11,24(sp)
  8002d4:	6109                	addi	sp,sp,128
  8002d6:	8082                	ret
            padc = '0';
  8002d8:	87b2                	mv	a5,a2
            goto reswitch;
  8002da:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002de:	846a                	mv	s0,s10
  8002e0:	00140d13          	addi	s10,s0,1
  8002e4:	fdd6059b          	addiw	a1,a2,-35
  8002e8:	0ff5f593          	andi	a1,a1,255
  8002ec:	fcb572e3          	bgeu	a0,a1,8002b0 <vprintfmt+0x7c>
            putch('%', putdat);
  8002f0:	85a6                	mv	a1,s1
  8002f2:	02500513          	li	a0,37
  8002f6:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8002f8:	fff44783          	lbu	a5,-1(s0)
  8002fc:	8d22                	mv	s10,s0
  8002fe:	f73788e3          	beq	a5,s3,80026e <vprintfmt+0x3a>
  800302:	ffed4783          	lbu	a5,-2(s10)
  800306:	1d7d                	addi	s10,s10,-1
  800308:	ff379de3          	bne	a5,s3,800302 <vprintfmt+0xce>
  80030c:	b78d                	j	80026e <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  80030e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  800312:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800316:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800318:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80031c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800320:	02d86463          	bltu	a6,a3,800348 <vprintfmt+0x114>
                ch = *fmt;
  800324:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  800328:	002c169b          	slliw	a3,s8,0x2
  80032c:	0186873b          	addw	a4,a3,s8
  800330:	0017171b          	slliw	a4,a4,0x1
  800334:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  800336:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  80033a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80033c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  800340:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800344:	fed870e3          	bgeu	a6,a3,800324 <vprintfmt+0xf0>
            if (width < 0)
  800348:	f40ddce3          	bgez	s11,8002a0 <vprintfmt+0x6c>
                width = precision, precision = -1;
  80034c:	8de2                	mv	s11,s8
  80034e:	5c7d                	li	s8,-1
  800350:	bf81                	j	8002a0 <vprintfmt+0x6c>
            if (width < 0)
  800352:	fffdc693          	not	a3,s11
  800356:	96fd                	srai	a3,a3,0x3f
  800358:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  80035c:	00144603          	lbu	a2,1(s0)
  800360:	2d81                	sext.w	s11,s11
  800362:	846a                	mv	s0,s10
            goto reswitch;
  800364:	bf35                	j	8002a0 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  800366:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80036a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  80036e:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  800370:	846a                	mv	s0,s10
            goto process_precision;
  800372:	bfd9                	j	800348 <vprintfmt+0x114>
    if (lflag >= 2) {
  800374:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800376:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80037a:	01174463          	blt	a4,a7,800382 <vprintfmt+0x14e>
    else if (lflag) {
  80037e:	1a088e63          	beqz	a7,80053a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  800382:	000a3603          	ld	a2,0(s4)
  800386:	46c1                	li	a3,16
  800388:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  80038a:	2781                	sext.w	a5,a5
  80038c:	876e                	mv	a4,s11
  80038e:	85a6                	mv	a1,s1
  800390:	854a                	mv	a0,s2
  800392:	e37ff0ef          	jal	ra,8001c8 <printnum>
            break;
  800396:	bde1                	j	80026e <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  800398:	000a2503          	lw	a0,0(s4)
  80039c:	85a6                	mv	a1,s1
  80039e:	0a21                	addi	s4,s4,8
  8003a0:	9902                	jalr	s2
            break;
  8003a2:	b5f1                	j	80026e <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003a4:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003a6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8003aa:	01174463          	blt	a4,a7,8003b2 <vprintfmt+0x17e>
    else if (lflag) {
  8003ae:	18088163          	beqz	a7,800530 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  8003b2:	000a3603          	ld	a2,0(s4)
  8003b6:	46a9                	li	a3,10
  8003b8:	8a2e                	mv	s4,a1
  8003ba:	bfc1                	j	80038a <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  8003bc:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8003c0:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003c2:	846a                	mv	s0,s10
            goto reswitch;
  8003c4:	bdf1                	j	8002a0 <vprintfmt+0x6c>
            putch(ch, putdat);
  8003c6:	85a6                	mv	a1,s1
  8003c8:	02500513          	li	a0,37
  8003cc:	9902                	jalr	s2
            break;
  8003ce:	b545                	j	80026e <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  8003d0:	00144603          	lbu	a2,1(s0)
            lflag ++;
  8003d4:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003d6:	846a                	mv	s0,s10
            goto reswitch;
  8003d8:	b5e1                	j	8002a0 <vprintfmt+0x6c>
    if (lflag >= 2) {
  8003da:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003dc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8003e0:	01174463          	blt	a4,a7,8003e8 <vprintfmt+0x1b4>
    else if (lflag) {
  8003e4:	14088163          	beqz	a7,800526 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  8003e8:	000a3603          	ld	a2,0(s4)
  8003ec:	46a1                	li	a3,8
  8003ee:	8a2e                	mv	s4,a1
  8003f0:	bf69                	j	80038a <vprintfmt+0x156>
            putch('0', putdat);
  8003f2:	03000513          	li	a0,48
  8003f6:	85a6                	mv	a1,s1
  8003f8:	e03e                	sd	a5,0(sp)
  8003fa:	9902                	jalr	s2
            putch('x', putdat);
  8003fc:	85a6                	mv	a1,s1
  8003fe:	07800513          	li	a0,120
  800402:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800404:	0a21                	addi	s4,s4,8
            goto number;
  800406:	6782                	ld	a5,0(sp)
  800408:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80040a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  80040e:	bfb5                	j	80038a <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  800410:	000a3403          	ld	s0,0(s4)
  800414:	008a0713          	addi	a4,s4,8
  800418:	e03a                	sd	a4,0(sp)
  80041a:	14040263          	beqz	s0,80055e <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  80041e:	0fb05763          	blez	s11,80050c <vprintfmt+0x2d8>
  800422:	02d00693          	li	a3,45
  800426:	0cd79163          	bne	a5,a3,8004e8 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80042a:	00044783          	lbu	a5,0(s0)
  80042e:	0007851b          	sext.w	a0,a5
  800432:	cf85                	beqz	a5,80046a <vprintfmt+0x236>
  800434:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  800438:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80043c:	000c4563          	bltz	s8,800446 <vprintfmt+0x212>
  800440:	3c7d                	addiw	s8,s8,-1
  800442:	036c0263          	beq	s8,s6,800466 <vprintfmt+0x232>
                    putch('?', putdat);
  800446:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800448:	0e0c8e63          	beqz	s9,800544 <vprintfmt+0x310>
  80044c:	3781                	addiw	a5,a5,-32
  80044e:	0ef47b63          	bgeu	s0,a5,800544 <vprintfmt+0x310>
                    putch('?', putdat);
  800452:	03f00513          	li	a0,63
  800456:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800458:	000a4783          	lbu	a5,0(s4)
  80045c:	3dfd                	addiw	s11,s11,-1
  80045e:	0a05                	addi	s4,s4,1
  800460:	0007851b          	sext.w	a0,a5
  800464:	ffe1                	bnez	a5,80043c <vprintfmt+0x208>
            for (; width > 0; width --) {
  800466:	01b05963          	blez	s11,800478 <vprintfmt+0x244>
  80046a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80046c:	85a6                	mv	a1,s1
  80046e:	02000513          	li	a0,32
  800472:	9902                	jalr	s2
            for (; width > 0; width --) {
  800474:	fe0d9be3          	bnez	s11,80046a <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  800478:	6a02                	ld	s4,0(sp)
  80047a:	bbd5                	j	80026e <vprintfmt+0x3a>
    if (lflag >= 2) {
  80047c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80047e:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  800482:	01174463          	blt	a4,a7,80048a <vprintfmt+0x256>
    else if (lflag) {
  800486:	08088d63          	beqz	a7,800520 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  80048a:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  80048e:	0a044d63          	bltz	s0,800548 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  800492:	8622                	mv	a2,s0
  800494:	8a66                	mv	s4,s9
  800496:	46a9                	li	a3,10
  800498:	bdcd                	j	80038a <vprintfmt+0x156>
            err = va_arg(ap, int);
  80049a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80049e:	4761                	li	a4,24
            err = va_arg(ap, int);
  8004a0:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8004a2:	41f7d69b          	sraiw	a3,a5,0x1f
  8004a6:	8fb5                	xor	a5,a5,a3
  8004a8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8004ac:	02d74163          	blt	a4,a3,8004ce <vprintfmt+0x29a>
  8004b0:	00369793          	slli	a5,a3,0x3
  8004b4:	97de                	add	a5,a5,s7
  8004b6:	639c                	ld	a5,0(a5)
  8004b8:	cb99                	beqz	a5,8004ce <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  8004ba:	86be                	mv	a3,a5
  8004bc:	00000617          	auipc	a2,0x0
  8004c0:	26c60613          	addi	a2,a2,620 # 800728 <main+0x156>
  8004c4:	85a6                	mv	a1,s1
  8004c6:	854a                	mv	a0,s2
  8004c8:	0ce000ef          	jal	ra,800596 <printfmt>
  8004cc:	b34d                	j	80026e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8004ce:	00000617          	auipc	a2,0x0
  8004d2:	24a60613          	addi	a2,a2,586 # 800718 <main+0x146>
  8004d6:	85a6                	mv	a1,s1
  8004d8:	854a                	mv	a0,s2
  8004da:	0bc000ef          	jal	ra,800596 <printfmt>
  8004de:	bb41                	j	80026e <vprintfmt+0x3a>
                p = "(null)";
  8004e0:	00000417          	auipc	s0,0x0
  8004e4:	23040413          	addi	s0,s0,560 # 800710 <main+0x13e>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e8:	85e2                	mv	a1,s8
  8004ea:	8522                	mv	a0,s0
  8004ec:	e43e                	sd	a5,8(sp)
  8004ee:	0c8000ef          	jal	ra,8005b6 <strnlen>
  8004f2:	40ad8dbb          	subw	s11,s11,a0
  8004f6:	01b05b63          	blez	s11,80050c <vprintfmt+0x2d8>
                    putch(padc, putdat);
  8004fa:	67a2                	ld	a5,8(sp)
  8004fc:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800500:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800502:	85a6                	mv	a1,s1
  800504:	8552                	mv	a0,s4
  800506:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800508:	fe0d9ce3          	bnez	s11,800500 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80050c:	00044783          	lbu	a5,0(s0)
  800510:	00140a13          	addi	s4,s0,1
  800514:	0007851b          	sext.w	a0,a5
  800518:	d3a5                	beqz	a5,800478 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  80051a:	05e00413          	li	s0,94
  80051e:	bf39                	j	80043c <vprintfmt+0x208>
        return va_arg(*ap, int);
  800520:	000a2403          	lw	s0,0(s4)
  800524:	b7ad                	j	80048e <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  800526:	000a6603          	lwu	a2,0(s4)
  80052a:	46a1                	li	a3,8
  80052c:	8a2e                	mv	s4,a1
  80052e:	bdb1                	j	80038a <vprintfmt+0x156>
  800530:	000a6603          	lwu	a2,0(s4)
  800534:	46a9                	li	a3,10
  800536:	8a2e                	mv	s4,a1
  800538:	bd89                	j	80038a <vprintfmt+0x156>
  80053a:	000a6603          	lwu	a2,0(s4)
  80053e:	46c1                	li	a3,16
  800540:	8a2e                	mv	s4,a1
  800542:	b5a1                	j	80038a <vprintfmt+0x156>
                    putch(ch, putdat);
  800544:	9902                	jalr	s2
  800546:	bf09                	j	800458 <vprintfmt+0x224>
                putch('-', putdat);
  800548:	85a6                	mv	a1,s1
  80054a:	02d00513          	li	a0,45
  80054e:	e03e                	sd	a5,0(sp)
  800550:	9902                	jalr	s2
                num = -(long long)num;
  800552:	6782                	ld	a5,0(sp)
  800554:	8a66                	mv	s4,s9
  800556:	40800633          	neg	a2,s0
  80055a:	46a9                	li	a3,10
  80055c:	b53d                	j	80038a <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  80055e:	03b05163          	blez	s11,800580 <vprintfmt+0x34c>
  800562:	02d00693          	li	a3,45
  800566:	f6d79de3          	bne	a5,a3,8004e0 <vprintfmt+0x2ac>
                p = "(null)";
  80056a:	00000417          	auipc	s0,0x0
  80056e:	1a640413          	addi	s0,s0,422 # 800710 <main+0x13e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800572:	02800793          	li	a5,40
  800576:	02800513          	li	a0,40
  80057a:	00140a13          	addi	s4,s0,1
  80057e:	bd6d                	j	800438 <vprintfmt+0x204>
  800580:	00000a17          	auipc	s4,0x0
  800584:	191a0a13          	addi	s4,s4,401 # 800711 <main+0x13f>
  800588:	02800513          	li	a0,40
  80058c:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800590:	05e00413          	li	s0,94
  800594:	b565                	j	80043c <vprintfmt+0x208>

0000000000800596 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800596:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800598:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80059c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80059e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8005a0:	ec06                	sd	ra,24(sp)
  8005a2:	f83a                	sd	a4,48(sp)
  8005a4:	fc3e                	sd	a5,56(sp)
  8005a6:	e0c2                	sd	a6,64(sp)
  8005a8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8005aa:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8005ac:	c89ff0ef          	jal	ra,800234 <vprintfmt>
}
  8005b0:	60e2                	ld	ra,24(sp)
  8005b2:	6161                	addi	sp,sp,80
  8005b4:	8082                	ret

00000000008005b6 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8005b6:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8005b8:	e589                	bnez	a1,8005c2 <strnlen+0xc>
  8005ba:	a811                	j	8005ce <strnlen+0x18>
        cnt ++;
  8005bc:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8005be:	00f58863          	beq	a1,a5,8005ce <strnlen+0x18>
  8005c2:	00f50733          	add	a4,a0,a5
  8005c6:	00074703          	lbu	a4,0(a4)
  8005ca:	fb6d                	bnez	a4,8005bc <strnlen+0x6>
  8005cc:	85be                	mv	a1,a5
    }
    return cnt;
}
  8005ce:	852e                	mv	a0,a1
  8005d0:	8082                	ret

00000000008005d2 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8005d2:	1101                	addi	sp,sp,-32
  8005d4:	ec06                	sd	ra,24(sp)
  8005d6:	e822                	sd	s0,16(sp)
    int pid, exit_code;
    if ((pid = fork()) == 0) {
  8005d8:	bdfff0ef          	jal	ra,8001b6 <fork>
  8005dc:	c169                	beqz	a0,80069e <main+0xcc>
  8005de:	842a                	mv	s0,a0
        for (i = 0; i < 10; i ++) {
            yield();
        }
        exit(0xbeaf);
    }
    assert(pid > 0);
  8005e0:	0aa05063          	blez	a0,800680 <main+0xae>
    assert(waitpid(-1, NULL) != 0);
  8005e4:	4581                	li	a1,0
  8005e6:	557d                	li	a0,-1
  8005e8:	bd1ff0ef          	jal	ra,8001b8 <waitpid>
  8005ec:	c93d                	beqz	a0,800662 <main+0x90>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  8005ee:	458d                	li	a1,3
  8005f0:	05fa                	slli	a1,a1,0x1e
  8005f2:	8522                	mv	a0,s0
  8005f4:	bc5ff0ef          	jal	ra,8001b8 <waitpid>
  8005f8:	c531                	beqz	a0,800644 <main+0x72>
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  8005fa:	006c                	addi	a1,sp,12
  8005fc:	8522                	mv	a0,s0
  8005fe:	bbbff0ef          	jal	ra,8001b8 <waitpid>
  800602:	e115                	bnez	a0,800626 <main+0x54>
  800604:	4732                	lw	a4,12(sp)
  800606:	67b1                	lui	a5,0xc
  800608:	eaf78793          	addi	a5,a5,-337 # beaf <_start-0x7f4171>
  80060c:	00f71d63          	bne	a4,a5,800626 <main+0x54>
    cprintf("badarg pass.\n");
  800610:	00000517          	auipc	a0,0x0
  800614:	4b850513          	addi	a0,a0,1208 # 800ac8 <error_string+0x180>
  800618:	a8bff0ef          	jal	ra,8000a2 <cprintf>
    return 0;
}
  80061c:	60e2                	ld	ra,24(sp)
  80061e:	6442                	ld	s0,16(sp)
  800620:	4501                	li	a0,0
  800622:	6105                	addi	sp,sp,32
  800624:	8082                	ret
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  800626:	00000697          	auipc	a3,0x0
  80062a:	46a68693          	addi	a3,a3,1130 # 800a90 <error_string+0x148>
  80062e:	00000617          	auipc	a2,0x0
  800632:	3fa60613          	addi	a2,a2,1018 # 800a28 <error_string+0xe0>
  800636:	45c9                	li	a1,18
  800638:	00000517          	auipc	a0,0x0
  80063c:	40850513          	addi	a0,a0,1032 # 800a40 <error_string+0xf8>
  800640:	9e7ff0ef          	jal	ra,800026 <__panic>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  800644:	00000697          	auipc	a3,0x0
  800648:	42468693          	addi	a3,a3,1060 # 800a68 <error_string+0x120>
  80064c:	00000617          	auipc	a2,0x0
  800650:	3dc60613          	addi	a2,a2,988 # 800a28 <error_string+0xe0>
  800654:	45c5                	li	a1,17
  800656:	00000517          	auipc	a0,0x0
  80065a:	3ea50513          	addi	a0,a0,1002 # 800a40 <error_string+0xf8>
  80065e:	9c9ff0ef          	jal	ra,800026 <__panic>
    assert(waitpid(-1, NULL) != 0);
  800662:	00000697          	auipc	a3,0x0
  800666:	3ee68693          	addi	a3,a3,1006 # 800a50 <error_string+0x108>
  80066a:	00000617          	auipc	a2,0x0
  80066e:	3be60613          	addi	a2,a2,958 # 800a28 <error_string+0xe0>
  800672:	45c1                	li	a1,16
  800674:	00000517          	auipc	a0,0x0
  800678:	3cc50513          	addi	a0,a0,972 # 800a40 <error_string+0xf8>
  80067c:	9abff0ef          	jal	ra,800026 <__panic>
    assert(pid > 0);
  800680:	00000697          	auipc	a3,0x0
  800684:	3a068693          	addi	a3,a3,928 # 800a20 <error_string+0xd8>
  800688:	00000617          	auipc	a2,0x0
  80068c:	3a060613          	addi	a2,a2,928 # 800a28 <error_string+0xe0>
  800690:	45bd                	li	a1,15
  800692:	00000517          	auipc	a0,0x0
  800696:	3ae50513          	addi	a0,a0,942 # 800a40 <error_string+0xf8>
  80069a:	98dff0ef          	jal	ra,800026 <__panic>
        cprintf("fork ok.\n");
  80069e:	00000517          	auipc	a0,0x0
  8006a2:	37250513          	addi	a0,a0,882 # 800a10 <error_string+0xc8>
  8006a6:	9fdff0ef          	jal	ra,8000a2 <cprintf>
  8006aa:	4429                	li	s0,10
        for (i = 0; i < 10; i ++) {
  8006ac:	347d                	addiw	s0,s0,-1
            yield();
  8006ae:	b0dff0ef          	jal	ra,8001ba <yield>
        for (i = 0; i < 10; i ++) {
  8006b2:	fc6d                	bnez	s0,8006ac <main+0xda>
        exit(0xbeaf);
  8006b4:	6531                	lui	a0,0xc
  8006b6:	eaf50513          	addi	a0,a0,-337 # beaf <_start-0x7f4171>
  8006ba:	ae7ff0ef          	jal	ra,8001a0 <exit>
