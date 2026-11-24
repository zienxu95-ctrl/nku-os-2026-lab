
obj/__user_exit.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	1a2000ef          	jal	ra,8001c2 <umain>
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
  80003a:	6ba50513          	addi	a0,a0,1722 # 8006f0 <main+0x118>
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
  80005a:	a4a50513          	addi	a0,a0,-1462 # 800aa0 <error_string+0x128>
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
  800096:	1a4000ef          	jal	ra,80023a <vprintfmt>
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
  8000cc:	16e000ef          	jal	ra,80023a <vprintfmt>
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
  8001ac:	56850513          	addi	a0,a0,1384 # 800710 <main+0x138>
  8001b0:	ef3ff0ef          	jal	ra,8000a2 <cprintf>
    while (1);
  8001b4:	a001                	j	8001b4 <exit+0x14>

00000000008001b6 <fork>:
}

int
fork(void) {
    return sys_fork();
  8001b6:	b7a9                	j	800100 <sys_fork>

00000000008001b8 <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  8001b8:	4581                	li	a1,0
  8001ba:	4501                	li	a0,0
  8001bc:	b7b5                	j	800128 <sys_wait>

00000000008001be <waitpid>:
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8001be:	b7ad                	j	800128 <sys_wait>

00000000008001c0 <yield>:
}

void
yield(void) {
    sys_yield();
  8001c0:	bf41                	j	800150 <sys_yield>

00000000008001c2 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8001c2:	1141                	addi	sp,sp,-16
  8001c4:	e406                	sd	ra,8(sp)
    int ret = main();
  8001c6:	412000ef          	jal	ra,8005d8 <main>
    exit(ret);
  8001ca:	fd7ff0ef          	jal	ra,8001a0 <exit>

00000000008001ce <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8001ce:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8001d2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8001d4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8001d8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8001da:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8001de:	f022                	sd	s0,32(sp)
  8001e0:	ec26                	sd	s1,24(sp)
  8001e2:	e84a                	sd	s2,16(sp)
  8001e4:	f406                	sd	ra,40(sp)
  8001e6:	e44e                	sd	s3,8(sp)
  8001e8:	84aa                	mv	s1,a0
  8001ea:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001ec:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8001f0:	2a01                	sext.w	s4,s4
    if (num >= base) {
  8001f2:	03067e63          	bgeu	a2,a6,80022e <printnum+0x60>
  8001f6:	89be                	mv	s3,a5
        while (-- width > 0)
  8001f8:	00805763          	blez	s0,800206 <printnum+0x38>
  8001fc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001fe:	85ca                	mv	a1,s2
  800200:	854e                	mv	a0,s3
  800202:	9482                	jalr	s1
        while (-- width > 0)
  800204:	fc65                	bnez	s0,8001fc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800206:	1a02                	slli	s4,s4,0x20
  800208:	00000797          	auipc	a5,0x0
  80020c:	52078793          	addi	a5,a5,1312 # 800728 <main+0x150>
  800210:	020a5a13          	srli	s4,s4,0x20
  800214:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800216:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800218:	000a4503          	lbu	a0,0(s4)
}
  80021c:	70a2                	ld	ra,40(sp)
  80021e:	69a2                	ld	s3,8(sp)
  800220:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800222:	85ca                	mv	a1,s2
  800224:	87a6                	mv	a5,s1
}
  800226:	6942                	ld	s2,16(sp)
  800228:	64e2                	ld	s1,24(sp)
  80022a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80022c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80022e:	03065633          	divu	a2,a2,a6
  800232:	8722                	mv	a4,s0
  800234:	f9bff0ef          	jal	ra,8001ce <printnum>
  800238:	b7f9                	j	800206 <printnum+0x38>

000000000080023a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80023a:	7119                	addi	sp,sp,-128
  80023c:	f4a6                	sd	s1,104(sp)
  80023e:	f0ca                	sd	s2,96(sp)
  800240:	ecce                	sd	s3,88(sp)
  800242:	e8d2                	sd	s4,80(sp)
  800244:	e4d6                	sd	s5,72(sp)
  800246:	e0da                	sd	s6,64(sp)
  800248:	fc5e                	sd	s7,56(sp)
  80024a:	f06a                	sd	s10,32(sp)
  80024c:	fc86                	sd	ra,120(sp)
  80024e:	f8a2                	sd	s0,112(sp)
  800250:	f862                	sd	s8,48(sp)
  800252:	f466                	sd	s9,40(sp)
  800254:	ec6e                	sd	s11,24(sp)
  800256:	892a                	mv	s2,a0
  800258:	84ae                	mv	s1,a1
  80025a:	8d32                	mv	s10,a2
  80025c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80025e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800262:	5b7d                	li	s6,-1
  800264:	00000a97          	auipc	s5,0x0
  800268:	4f8a8a93          	addi	s5,s5,1272 # 80075c <main+0x184>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80026c:	00000b97          	auipc	s7,0x0
  800270:	70cb8b93          	addi	s7,s7,1804 # 800978 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800274:	000d4503          	lbu	a0,0(s10)
  800278:	001d0413          	addi	s0,s10,1
  80027c:	01350a63          	beq	a0,s3,800290 <vprintfmt+0x56>
            if (ch == '\0') {
  800280:	c121                	beqz	a0,8002c0 <vprintfmt+0x86>
            putch(ch, putdat);
  800282:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800284:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800286:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800288:	fff44503          	lbu	a0,-1(s0)
  80028c:	ff351ae3          	bne	a0,s3,800280 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  800290:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800294:	02000793          	li	a5,32
        lflag = altflag = 0;
  800298:	4c81                	li	s9,0
  80029a:	4881                	li	a7,0
        width = precision = -1;
  80029c:	5c7d                	li	s8,-1
  80029e:	5dfd                	li	s11,-1
  8002a0:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  8002a4:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  8002a6:	fdd6059b          	addiw	a1,a2,-35
  8002aa:	0ff5f593          	andi	a1,a1,255
  8002ae:	00140d13          	addi	s10,s0,1
  8002b2:	04b56263          	bltu	a0,a1,8002f6 <vprintfmt+0xbc>
  8002b6:	058a                	slli	a1,a1,0x2
  8002b8:	95d6                	add	a1,a1,s5
  8002ba:	4194                	lw	a3,0(a1)
  8002bc:	96d6                	add	a3,a3,s5
  8002be:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8002c0:	70e6                	ld	ra,120(sp)
  8002c2:	7446                	ld	s0,112(sp)
  8002c4:	74a6                	ld	s1,104(sp)
  8002c6:	7906                	ld	s2,96(sp)
  8002c8:	69e6                	ld	s3,88(sp)
  8002ca:	6a46                	ld	s4,80(sp)
  8002cc:	6aa6                	ld	s5,72(sp)
  8002ce:	6b06                	ld	s6,64(sp)
  8002d0:	7be2                	ld	s7,56(sp)
  8002d2:	7c42                	ld	s8,48(sp)
  8002d4:	7ca2                	ld	s9,40(sp)
  8002d6:	7d02                	ld	s10,32(sp)
  8002d8:	6de2                	ld	s11,24(sp)
  8002da:	6109                	addi	sp,sp,128
  8002dc:	8082                	ret
            padc = '0';
  8002de:	87b2                	mv	a5,a2
            goto reswitch;
  8002e0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002e4:	846a                	mv	s0,s10
  8002e6:	00140d13          	addi	s10,s0,1
  8002ea:	fdd6059b          	addiw	a1,a2,-35
  8002ee:	0ff5f593          	andi	a1,a1,255
  8002f2:	fcb572e3          	bgeu	a0,a1,8002b6 <vprintfmt+0x7c>
            putch('%', putdat);
  8002f6:	85a6                	mv	a1,s1
  8002f8:	02500513          	li	a0,37
  8002fc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8002fe:	fff44783          	lbu	a5,-1(s0)
  800302:	8d22                	mv	s10,s0
  800304:	f73788e3          	beq	a5,s3,800274 <vprintfmt+0x3a>
  800308:	ffed4783          	lbu	a5,-2(s10)
  80030c:	1d7d                	addi	s10,s10,-1
  80030e:	ff379de3          	bne	a5,s3,800308 <vprintfmt+0xce>
  800312:	b78d                	j	800274 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  800314:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  800318:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80031c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80031e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800322:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800326:	02d86463          	bltu	a6,a3,80034e <vprintfmt+0x114>
                ch = *fmt;
  80032a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  80032e:	002c169b          	slliw	a3,s8,0x2
  800332:	0186873b          	addw	a4,a3,s8
  800336:	0017171b          	slliw	a4,a4,0x1
  80033a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  80033c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  800340:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800342:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  800346:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  80034a:	fed870e3          	bgeu	a6,a3,80032a <vprintfmt+0xf0>
            if (width < 0)
  80034e:	f40ddce3          	bgez	s11,8002a6 <vprintfmt+0x6c>
                width = precision, precision = -1;
  800352:	8de2                	mv	s11,s8
  800354:	5c7d                	li	s8,-1
  800356:	bf81                	j	8002a6 <vprintfmt+0x6c>
            if (width < 0)
  800358:	fffdc693          	not	a3,s11
  80035c:	96fd                	srai	a3,a3,0x3f
  80035e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  800362:	00144603          	lbu	a2,1(s0)
  800366:	2d81                	sext.w	s11,s11
  800368:	846a                	mv	s0,s10
            goto reswitch;
  80036a:	bf35                	j	8002a6 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  80036c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800370:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800374:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  800376:	846a                	mv	s0,s10
            goto process_precision;
  800378:	bfd9                	j	80034e <vprintfmt+0x114>
    if (lflag >= 2) {
  80037a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80037c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800380:	01174463          	blt	a4,a7,800388 <vprintfmt+0x14e>
    else if (lflag) {
  800384:	1a088e63          	beqz	a7,800540 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  800388:	000a3603          	ld	a2,0(s4)
  80038c:	46c1                	li	a3,16
  80038e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800390:	2781                	sext.w	a5,a5
  800392:	876e                	mv	a4,s11
  800394:	85a6                	mv	a1,s1
  800396:	854a                	mv	a0,s2
  800398:	e37ff0ef          	jal	ra,8001ce <printnum>
            break;
  80039c:	bde1                	j	800274 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  80039e:	000a2503          	lw	a0,0(s4)
  8003a2:	85a6                	mv	a1,s1
  8003a4:	0a21                	addi	s4,s4,8
  8003a6:	9902                	jalr	s2
            break;
  8003a8:	b5f1                	j	800274 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003aa:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003ac:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8003b0:	01174463          	blt	a4,a7,8003b8 <vprintfmt+0x17e>
    else if (lflag) {
  8003b4:	18088163          	beqz	a7,800536 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  8003b8:	000a3603          	ld	a2,0(s4)
  8003bc:	46a9                	li	a3,10
  8003be:	8a2e                	mv	s4,a1
  8003c0:	bfc1                	j	800390 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  8003c2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8003c6:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003c8:	846a                	mv	s0,s10
            goto reswitch;
  8003ca:	bdf1                	j	8002a6 <vprintfmt+0x6c>
            putch(ch, putdat);
  8003cc:	85a6                	mv	a1,s1
  8003ce:	02500513          	li	a0,37
  8003d2:	9902                	jalr	s2
            break;
  8003d4:	b545                	j	800274 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  8003d6:	00144603          	lbu	a2,1(s0)
            lflag ++;
  8003da:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003dc:	846a                	mv	s0,s10
            goto reswitch;
  8003de:	b5e1                	j	8002a6 <vprintfmt+0x6c>
    if (lflag >= 2) {
  8003e0:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003e2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8003e6:	01174463          	blt	a4,a7,8003ee <vprintfmt+0x1b4>
    else if (lflag) {
  8003ea:	14088163          	beqz	a7,80052c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  8003ee:	000a3603          	ld	a2,0(s4)
  8003f2:	46a1                	li	a3,8
  8003f4:	8a2e                	mv	s4,a1
  8003f6:	bf69                	j	800390 <vprintfmt+0x156>
            putch('0', putdat);
  8003f8:	03000513          	li	a0,48
  8003fc:	85a6                	mv	a1,s1
  8003fe:	e03e                	sd	a5,0(sp)
  800400:	9902                	jalr	s2
            putch('x', putdat);
  800402:	85a6                	mv	a1,s1
  800404:	07800513          	li	a0,120
  800408:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80040a:	0a21                	addi	s4,s4,8
            goto number;
  80040c:	6782                	ld	a5,0(sp)
  80040e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800410:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  800414:	bfb5                	j	800390 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  800416:	000a3403          	ld	s0,0(s4)
  80041a:	008a0713          	addi	a4,s4,8
  80041e:	e03a                	sd	a4,0(sp)
  800420:	14040263          	beqz	s0,800564 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  800424:	0fb05763          	blez	s11,800512 <vprintfmt+0x2d8>
  800428:	02d00693          	li	a3,45
  80042c:	0cd79163          	bne	a5,a3,8004ee <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800430:	00044783          	lbu	a5,0(s0)
  800434:	0007851b          	sext.w	a0,a5
  800438:	cf85                	beqz	a5,800470 <vprintfmt+0x236>
  80043a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  80043e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800442:	000c4563          	bltz	s8,80044c <vprintfmt+0x212>
  800446:	3c7d                	addiw	s8,s8,-1
  800448:	036c0263          	beq	s8,s6,80046c <vprintfmt+0x232>
                    putch('?', putdat);
  80044c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80044e:	0e0c8e63          	beqz	s9,80054a <vprintfmt+0x310>
  800452:	3781                	addiw	a5,a5,-32
  800454:	0ef47b63          	bgeu	s0,a5,80054a <vprintfmt+0x310>
                    putch('?', putdat);
  800458:	03f00513          	li	a0,63
  80045c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80045e:	000a4783          	lbu	a5,0(s4)
  800462:	3dfd                	addiw	s11,s11,-1
  800464:	0a05                	addi	s4,s4,1
  800466:	0007851b          	sext.w	a0,a5
  80046a:	ffe1                	bnez	a5,800442 <vprintfmt+0x208>
            for (; width > 0; width --) {
  80046c:	01b05963          	blez	s11,80047e <vprintfmt+0x244>
  800470:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800472:	85a6                	mv	a1,s1
  800474:	02000513          	li	a0,32
  800478:	9902                	jalr	s2
            for (; width > 0; width --) {
  80047a:	fe0d9be3          	bnez	s11,800470 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  80047e:	6a02                	ld	s4,0(sp)
  800480:	bbd5                	j	800274 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800482:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800484:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  800488:	01174463          	blt	a4,a7,800490 <vprintfmt+0x256>
    else if (lflag) {
  80048c:	08088d63          	beqz	a7,800526 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  800490:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800494:	0a044d63          	bltz	s0,80054e <vprintfmt+0x314>
            num = getint(&ap, lflag);
  800498:	8622                	mv	a2,s0
  80049a:	8a66                	mv	s4,s9
  80049c:	46a9                	li	a3,10
  80049e:	bdcd                	j	800390 <vprintfmt+0x156>
            err = va_arg(ap, int);
  8004a0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8004a4:	4761                	li	a4,24
            err = va_arg(ap, int);
  8004a6:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8004a8:	41f7d69b          	sraiw	a3,a5,0x1f
  8004ac:	8fb5                	xor	a5,a5,a3
  8004ae:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8004b2:	02d74163          	blt	a4,a3,8004d4 <vprintfmt+0x29a>
  8004b6:	00369793          	slli	a5,a3,0x3
  8004ba:	97de                	add	a5,a5,s7
  8004bc:	639c                	ld	a5,0(a5)
  8004be:	cb99                	beqz	a5,8004d4 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  8004c0:	86be                	mv	a3,a5
  8004c2:	00000617          	auipc	a2,0x0
  8004c6:	29660613          	addi	a2,a2,662 # 800758 <main+0x180>
  8004ca:	85a6                	mv	a1,s1
  8004cc:	854a                	mv	a0,s2
  8004ce:	0ce000ef          	jal	ra,80059c <printfmt>
  8004d2:	b34d                	j	800274 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8004d4:	00000617          	auipc	a2,0x0
  8004d8:	27460613          	addi	a2,a2,628 # 800748 <main+0x170>
  8004dc:	85a6                	mv	a1,s1
  8004de:	854a                	mv	a0,s2
  8004e0:	0bc000ef          	jal	ra,80059c <printfmt>
  8004e4:	bb41                	j	800274 <vprintfmt+0x3a>
                p = "(null)";
  8004e6:	00000417          	auipc	s0,0x0
  8004ea:	25a40413          	addi	s0,s0,602 # 800740 <main+0x168>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ee:	85e2                	mv	a1,s8
  8004f0:	8522                	mv	a0,s0
  8004f2:	e43e                	sd	a5,8(sp)
  8004f4:	0c8000ef          	jal	ra,8005bc <strnlen>
  8004f8:	40ad8dbb          	subw	s11,s11,a0
  8004fc:	01b05b63          	blez	s11,800512 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  800500:	67a2                	ld	a5,8(sp)
  800502:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800506:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800508:	85a6                	mv	a1,s1
  80050a:	8552                	mv	a0,s4
  80050c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80050e:	fe0d9ce3          	bnez	s11,800506 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800512:	00044783          	lbu	a5,0(s0)
  800516:	00140a13          	addi	s4,s0,1
  80051a:	0007851b          	sext.w	a0,a5
  80051e:	d3a5                	beqz	a5,80047e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  800520:	05e00413          	li	s0,94
  800524:	bf39                	j	800442 <vprintfmt+0x208>
        return va_arg(*ap, int);
  800526:	000a2403          	lw	s0,0(s4)
  80052a:	b7ad                	j	800494 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  80052c:	000a6603          	lwu	a2,0(s4)
  800530:	46a1                	li	a3,8
  800532:	8a2e                	mv	s4,a1
  800534:	bdb1                	j	800390 <vprintfmt+0x156>
  800536:	000a6603          	lwu	a2,0(s4)
  80053a:	46a9                	li	a3,10
  80053c:	8a2e                	mv	s4,a1
  80053e:	bd89                	j	800390 <vprintfmt+0x156>
  800540:	000a6603          	lwu	a2,0(s4)
  800544:	46c1                	li	a3,16
  800546:	8a2e                	mv	s4,a1
  800548:	b5a1                	j	800390 <vprintfmt+0x156>
                    putch(ch, putdat);
  80054a:	9902                	jalr	s2
  80054c:	bf09                	j	80045e <vprintfmt+0x224>
                putch('-', putdat);
  80054e:	85a6                	mv	a1,s1
  800550:	02d00513          	li	a0,45
  800554:	e03e                	sd	a5,0(sp)
  800556:	9902                	jalr	s2
                num = -(long long)num;
  800558:	6782                	ld	a5,0(sp)
  80055a:	8a66                	mv	s4,s9
  80055c:	40800633          	neg	a2,s0
  800560:	46a9                	li	a3,10
  800562:	b53d                	j	800390 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  800564:	03b05163          	blez	s11,800586 <vprintfmt+0x34c>
  800568:	02d00693          	li	a3,45
  80056c:	f6d79de3          	bne	a5,a3,8004e6 <vprintfmt+0x2ac>
                p = "(null)";
  800570:	00000417          	auipc	s0,0x0
  800574:	1d040413          	addi	s0,s0,464 # 800740 <main+0x168>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800578:	02800793          	li	a5,40
  80057c:	02800513          	li	a0,40
  800580:	00140a13          	addi	s4,s0,1
  800584:	bd6d                	j	80043e <vprintfmt+0x204>
  800586:	00000a17          	auipc	s4,0x0
  80058a:	1bba0a13          	addi	s4,s4,443 # 800741 <main+0x169>
  80058e:	02800513          	li	a0,40
  800592:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800596:	05e00413          	li	s0,94
  80059a:	b565                	j	800442 <vprintfmt+0x208>

000000000080059c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80059c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80059e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8005a2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8005a4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8005a6:	ec06                	sd	ra,24(sp)
  8005a8:	f83a                	sd	a4,48(sp)
  8005aa:	fc3e                	sd	a5,56(sp)
  8005ac:	e0c2                	sd	a6,64(sp)
  8005ae:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8005b0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8005b2:	c89ff0ef          	jal	ra,80023a <vprintfmt>
}
  8005b6:	60e2                	ld	ra,24(sp)
  8005b8:	6161                	addi	sp,sp,80
  8005ba:	8082                	ret

00000000008005bc <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8005bc:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8005be:	e589                	bnez	a1,8005c8 <strnlen+0xc>
  8005c0:	a811                	j	8005d4 <strnlen+0x18>
        cnt ++;
  8005c2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8005c4:	00f58863          	beq	a1,a5,8005d4 <strnlen+0x18>
  8005c8:	00f50733          	add	a4,a0,a5
  8005cc:	00074703          	lbu	a4,0(a4)
  8005d0:	fb6d                	bnez	a4,8005c2 <strnlen+0x6>
  8005d2:	85be                	mv	a1,a5
    }
    return cnt;
}
  8005d4:	852e                	mv	a0,a1
  8005d6:	8082                	ret

00000000008005d8 <main>:
#include <ulib.h>

int magic = -0x10384;

int
main(void) {
  8005d8:	1101                	addi	sp,sp,-32
    int pid, code;
    cprintf("I am the parent. Forking the child...\n");
  8005da:	00000517          	auipc	a0,0x0
  8005de:	46650513          	addi	a0,a0,1126 # 800a40 <error_string+0xc8>
main(void) {
  8005e2:	ec06                	sd	ra,24(sp)
  8005e4:	e822                	sd	s0,16(sp)
    cprintf("I am the parent. Forking the child...\n");
  8005e6:	abdff0ef          	jal	ra,8000a2 <cprintf>
    if ((pid = fork()) == 0) {
  8005ea:	bcdff0ef          	jal	ra,8001b6 <fork>
  8005ee:	c561                	beqz	a0,8006b6 <main+0xde>
  8005f0:	842a                	mv	s0,a0
        yield();
        yield();
        exit(magic);
    }
    else {
        cprintf("I am parent, fork a child pid %d\n",pid);
  8005f2:	85aa                	mv	a1,a0
  8005f4:	00000517          	auipc	a0,0x0
  8005f8:	48c50513          	addi	a0,a0,1164 # 800a80 <error_string+0x108>
  8005fc:	aa7ff0ef          	jal	ra,8000a2 <cprintf>
    }
    assert(pid > 0);
  800600:	08805c63          	blez	s0,800698 <main+0xc0>
    cprintf("I am the parent, waiting now..\n");
  800604:	00000517          	auipc	a0,0x0
  800608:	4d450513          	addi	a0,a0,1236 # 800ad8 <error_string+0x160>
  80060c:	a97ff0ef          	jal	ra,8000a2 <cprintf>

    assert(waitpid(pid, &code) == 0 && code == magic);
  800610:	006c                	addi	a1,sp,12
  800612:	8522                	mv	a0,s0
  800614:	babff0ef          	jal	ra,8001be <waitpid>
  800618:	e131                	bnez	a0,80065c <main+0x84>
  80061a:	4732                	lw	a4,12(sp)
  80061c:	00001797          	auipc	a5,0x1
  800620:	9e47a783          	lw	a5,-1564(a5) # 801000 <magic>
  800624:	02f71c63          	bne	a4,a5,80065c <main+0x84>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  800628:	006c                	addi	a1,sp,12
  80062a:	8522                	mv	a0,s0
  80062c:	b93ff0ef          	jal	ra,8001be <waitpid>
  800630:	c529                	beqz	a0,80067a <main+0xa2>
  800632:	b87ff0ef          	jal	ra,8001b8 <wait>
  800636:	c131                	beqz	a0,80067a <main+0xa2>
    cprintf("waitpid %d ok.\n", pid);
  800638:	85a2                	mv	a1,s0
  80063a:	00000517          	auipc	a0,0x0
  80063e:	51650513          	addi	a0,a0,1302 # 800b50 <error_string+0x1d8>
  800642:	a61ff0ef          	jal	ra,8000a2 <cprintf>

    cprintf("exit pass.\n");
  800646:	00000517          	auipc	a0,0x0
  80064a:	51a50513          	addi	a0,a0,1306 # 800b60 <error_string+0x1e8>
  80064e:	a55ff0ef          	jal	ra,8000a2 <cprintf>
    return 0;
}
  800652:	60e2                	ld	ra,24(sp)
  800654:	6442                	ld	s0,16(sp)
  800656:	4501                	li	a0,0
  800658:	6105                	addi	sp,sp,32
  80065a:	8082                	ret
    assert(waitpid(pid, &code) == 0 && code == magic);
  80065c:	00000697          	auipc	a3,0x0
  800660:	49c68693          	addi	a3,a3,1180 # 800af8 <error_string+0x180>
  800664:	00000617          	auipc	a2,0x0
  800668:	44c60613          	addi	a2,a2,1100 # 800ab0 <error_string+0x138>
  80066c:	45ed                	li	a1,27
  80066e:	00000517          	auipc	a0,0x0
  800672:	45a50513          	addi	a0,a0,1114 # 800ac8 <error_string+0x150>
  800676:	9b1ff0ef          	jal	ra,800026 <__panic>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  80067a:	00000697          	auipc	a3,0x0
  80067e:	4ae68693          	addi	a3,a3,1198 # 800b28 <error_string+0x1b0>
  800682:	00000617          	auipc	a2,0x0
  800686:	42e60613          	addi	a2,a2,1070 # 800ab0 <error_string+0x138>
  80068a:	45f1                	li	a1,28
  80068c:	00000517          	auipc	a0,0x0
  800690:	43c50513          	addi	a0,a0,1084 # 800ac8 <error_string+0x150>
  800694:	993ff0ef          	jal	ra,800026 <__panic>
    assert(pid > 0);
  800698:	00000697          	auipc	a3,0x0
  80069c:	41068693          	addi	a3,a3,1040 # 800aa8 <error_string+0x130>
  8006a0:	00000617          	auipc	a2,0x0
  8006a4:	41060613          	addi	a2,a2,1040 # 800ab0 <error_string+0x138>
  8006a8:	45e1                	li	a1,24
  8006aa:	00000517          	auipc	a0,0x0
  8006ae:	41e50513          	addi	a0,a0,1054 # 800ac8 <error_string+0x150>
  8006b2:	975ff0ef          	jal	ra,800026 <__panic>
        cprintf("I am the child.\n");
  8006b6:	00000517          	auipc	a0,0x0
  8006ba:	3b250513          	addi	a0,a0,946 # 800a68 <error_string+0xf0>
  8006be:	9e5ff0ef          	jal	ra,8000a2 <cprintf>
        yield();
  8006c2:	affff0ef          	jal	ra,8001c0 <yield>
        yield();
  8006c6:	afbff0ef          	jal	ra,8001c0 <yield>
        yield();
  8006ca:	af7ff0ef          	jal	ra,8001c0 <yield>
        yield();
  8006ce:	af3ff0ef          	jal	ra,8001c0 <yield>
        yield();
  8006d2:	aefff0ef          	jal	ra,8001c0 <yield>
        yield();
  8006d6:	aebff0ef          	jal	ra,8001c0 <yield>
        yield();
  8006da:	ae7ff0ef          	jal	ra,8001c0 <yield>
        exit(magic);
  8006de:	00001517          	auipc	a0,0x1
  8006e2:	92252503          	lw	a0,-1758(a0) # 801000 <magic>
  8006e6:	abbff0ef          	jal	ra,8001a0 <exit>
