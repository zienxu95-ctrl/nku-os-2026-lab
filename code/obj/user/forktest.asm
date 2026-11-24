
obj/__user_forktest.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	176000ef          	jal	ra,800196 <umain>
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
  80003a:	62250513          	addi	a0,a0,1570 # 800658 <main+0xac>
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
  80005a:	62250513          	addi	a0,a0,1570 # 800678 <main+0xcc>
  80005e:	044000ef          	jal	ra,8000a2 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	114000ef          	jal	ra,800178 <exit>

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
  800070:	0e0000ef          	jal	ra,800150 <sys_putc>
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
  800096:	178000ef          	jal	ra,80020e <vprintfmt>
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
  8000cc:	142000ef          	jal	ra,80020e <vprintfmt>
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

0000000000800150 <sys_putc>:

int sys_getpid(void) {
    return syscall(SYS_getpid, 0, 0, 0, 0, 0);
}

int sys_putc(int64_t c) {
  800150:	7139                	addi	sp,sp,-64
  800152:	47f9                	li	a5,30
  800154:	e83e                	sd	a5,16(sp)
  800156:	ec2a                	sd	a0,24(sp)
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
    return syscall(SYS_putc, c, 0, 0, 0, 0);
}
  800172:	4532                	lw	a0,12(sp)
  800174:	6121                	addi	sp,sp,64
  800176:	8082                	ret

0000000000800178 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800178:	1141                	addi	sp,sp,-16
  80017a:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80017c:	f5dff0ef          	jal	ra,8000d8 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800180:	00000517          	auipc	a0,0x0
  800184:	50050513          	addi	a0,a0,1280 # 800680 <main+0xd4>
  800188:	f1bff0ef          	jal	ra,8000a2 <cprintf>
    while (1);
  80018c:	a001                	j	80018c <exit+0x14>

000000000080018e <fork>:
}

int
fork(void) {
    return sys_fork();
  80018e:	bf8d                	j	800100 <sys_fork>

0000000000800190 <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  800190:	4581                	li	a1,0
  800192:	4501                	li	a0,0
  800194:	bf51                	j	800128 <sys_wait>

0000000000800196 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800196:	1141                	addi	sp,sp,-16
  800198:	e406                	sd	ra,8(sp)
    int ret = main();
  80019a:	412000ef          	jal	ra,8005ac <main>
    exit(ret);
  80019e:	fdbff0ef          	jal	ra,800178 <exit>

00000000008001a2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8001a2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8001a6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8001a8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8001ac:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8001ae:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8001b2:	f022                	sd	s0,32(sp)
  8001b4:	ec26                	sd	s1,24(sp)
  8001b6:	e84a                	sd	s2,16(sp)
  8001b8:	f406                	sd	ra,40(sp)
  8001ba:	e44e                	sd	s3,8(sp)
  8001bc:	84aa                	mv	s1,a0
  8001be:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001c0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8001c4:	2a01                	sext.w	s4,s4
    if (num >= base) {
  8001c6:	03067e63          	bgeu	a2,a6,800202 <printnum+0x60>
  8001ca:	89be                	mv	s3,a5
        while (-- width > 0)
  8001cc:	00805763          	blez	s0,8001da <printnum+0x38>
  8001d0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001d2:	85ca                	mv	a1,s2
  8001d4:	854e                	mv	a0,s3
  8001d6:	9482                	jalr	s1
        while (-- width > 0)
  8001d8:	fc65                	bnez	s0,8001d0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001da:	1a02                	slli	s4,s4,0x20
  8001dc:	00000797          	auipc	a5,0x0
  8001e0:	4bc78793          	addi	a5,a5,1212 # 800698 <main+0xec>
  8001e4:	020a5a13          	srli	s4,s4,0x20
  8001e8:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001ea:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ec:	000a4503          	lbu	a0,0(s4)
}
  8001f0:	70a2                	ld	ra,40(sp)
  8001f2:	69a2                	ld	s3,8(sp)
  8001f4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001f6:	85ca                	mv	a1,s2
  8001f8:	87a6                	mv	a5,s1
}
  8001fa:	6942                	ld	s2,16(sp)
  8001fc:	64e2                	ld	s1,24(sp)
  8001fe:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800200:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800202:	03065633          	divu	a2,a2,a6
  800206:	8722                	mv	a4,s0
  800208:	f9bff0ef          	jal	ra,8001a2 <printnum>
  80020c:	b7f9                	j	8001da <printnum+0x38>

000000000080020e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80020e:	7119                	addi	sp,sp,-128
  800210:	f4a6                	sd	s1,104(sp)
  800212:	f0ca                	sd	s2,96(sp)
  800214:	ecce                	sd	s3,88(sp)
  800216:	e8d2                	sd	s4,80(sp)
  800218:	e4d6                	sd	s5,72(sp)
  80021a:	e0da                	sd	s6,64(sp)
  80021c:	fc5e                	sd	s7,56(sp)
  80021e:	f06a                	sd	s10,32(sp)
  800220:	fc86                	sd	ra,120(sp)
  800222:	f8a2                	sd	s0,112(sp)
  800224:	f862                	sd	s8,48(sp)
  800226:	f466                	sd	s9,40(sp)
  800228:	ec6e                	sd	s11,24(sp)
  80022a:	892a                	mv	s2,a0
  80022c:	84ae                	mv	s1,a1
  80022e:	8d32                	mv	s10,a2
  800230:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800232:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800236:	5b7d                	li	s6,-1
  800238:	00000a97          	auipc	s5,0x0
  80023c:	494a8a93          	addi	s5,s5,1172 # 8006cc <main+0x120>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800240:	00000b97          	auipc	s7,0x0
  800244:	6a8b8b93          	addi	s7,s7,1704 # 8008e8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800248:	000d4503          	lbu	a0,0(s10)
  80024c:	001d0413          	addi	s0,s10,1
  800250:	01350a63          	beq	a0,s3,800264 <vprintfmt+0x56>
            if (ch == '\0') {
  800254:	c121                	beqz	a0,800294 <vprintfmt+0x86>
            putch(ch, putdat);
  800256:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800258:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80025a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80025c:	fff44503          	lbu	a0,-1(s0)
  800260:	ff351ae3          	bne	a0,s3,800254 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  800264:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800268:	02000793          	li	a5,32
        lflag = altflag = 0;
  80026c:	4c81                	li	s9,0
  80026e:	4881                	li	a7,0
        width = precision = -1;
  800270:	5c7d                	li	s8,-1
  800272:	5dfd                	li	s11,-1
  800274:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800278:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  80027a:	fdd6059b          	addiw	a1,a2,-35
  80027e:	0ff5f593          	andi	a1,a1,255
  800282:	00140d13          	addi	s10,s0,1
  800286:	04b56263          	bltu	a0,a1,8002ca <vprintfmt+0xbc>
  80028a:	058a                	slli	a1,a1,0x2
  80028c:	95d6                	add	a1,a1,s5
  80028e:	4194                	lw	a3,0(a1)
  800290:	96d6                	add	a3,a3,s5
  800292:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800294:	70e6                	ld	ra,120(sp)
  800296:	7446                	ld	s0,112(sp)
  800298:	74a6                	ld	s1,104(sp)
  80029a:	7906                	ld	s2,96(sp)
  80029c:	69e6                	ld	s3,88(sp)
  80029e:	6a46                	ld	s4,80(sp)
  8002a0:	6aa6                	ld	s5,72(sp)
  8002a2:	6b06                	ld	s6,64(sp)
  8002a4:	7be2                	ld	s7,56(sp)
  8002a6:	7c42                	ld	s8,48(sp)
  8002a8:	7ca2                	ld	s9,40(sp)
  8002aa:	7d02                	ld	s10,32(sp)
  8002ac:	6de2                	ld	s11,24(sp)
  8002ae:	6109                	addi	sp,sp,128
  8002b0:	8082                	ret
            padc = '0';
  8002b2:	87b2                	mv	a5,a2
            goto reswitch;
  8002b4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002b8:	846a                	mv	s0,s10
  8002ba:	00140d13          	addi	s10,s0,1
  8002be:	fdd6059b          	addiw	a1,a2,-35
  8002c2:	0ff5f593          	andi	a1,a1,255
  8002c6:	fcb572e3          	bgeu	a0,a1,80028a <vprintfmt+0x7c>
            putch('%', putdat);
  8002ca:	85a6                	mv	a1,s1
  8002cc:	02500513          	li	a0,37
  8002d0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8002d2:	fff44783          	lbu	a5,-1(s0)
  8002d6:	8d22                	mv	s10,s0
  8002d8:	f73788e3          	beq	a5,s3,800248 <vprintfmt+0x3a>
  8002dc:	ffed4783          	lbu	a5,-2(s10)
  8002e0:	1d7d                	addi	s10,s10,-1
  8002e2:	ff379de3          	bne	a5,s3,8002dc <vprintfmt+0xce>
  8002e6:	b78d                	j	800248 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  8002e8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  8002ec:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002f0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002f2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002f6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002fa:	02d86463          	bltu	a6,a3,800322 <vprintfmt+0x114>
                ch = *fmt;
  8002fe:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  800302:	002c169b          	slliw	a3,s8,0x2
  800306:	0186873b          	addw	a4,a3,s8
  80030a:	0017171b          	slliw	a4,a4,0x1
  80030e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  800310:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  800314:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800316:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  80031a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  80031e:	fed870e3          	bgeu	a6,a3,8002fe <vprintfmt+0xf0>
            if (width < 0)
  800322:	f40ddce3          	bgez	s11,80027a <vprintfmt+0x6c>
                width = precision, precision = -1;
  800326:	8de2                	mv	s11,s8
  800328:	5c7d                	li	s8,-1
  80032a:	bf81                	j	80027a <vprintfmt+0x6c>
            if (width < 0)
  80032c:	fffdc693          	not	a3,s11
  800330:	96fd                	srai	a3,a3,0x3f
  800332:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  800336:	00144603          	lbu	a2,1(s0)
  80033a:	2d81                	sext.w	s11,s11
  80033c:	846a                	mv	s0,s10
            goto reswitch;
  80033e:	bf35                	j	80027a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  800340:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800344:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800348:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  80034a:	846a                	mv	s0,s10
            goto process_precision;
  80034c:	bfd9                	j	800322 <vprintfmt+0x114>
    if (lflag >= 2) {
  80034e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800350:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800354:	01174463          	blt	a4,a7,80035c <vprintfmt+0x14e>
    else if (lflag) {
  800358:	1a088e63          	beqz	a7,800514 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  80035c:	000a3603          	ld	a2,0(s4)
  800360:	46c1                	li	a3,16
  800362:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800364:	2781                	sext.w	a5,a5
  800366:	876e                	mv	a4,s11
  800368:	85a6                	mv	a1,s1
  80036a:	854a                	mv	a0,s2
  80036c:	e37ff0ef          	jal	ra,8001a2 <printnum>
            break;
  800370:	bde1                	j	800248 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  800372:	000a2503          	lw	a0,0(s4)
  800376:	85a6                	mv	a1,s1
  800378:	0a21                	addi	s4,s4,8
  80037a:	9902                	jalr	s2
            break;
  80037c:	b5f1                	j	800248 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80037e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800380:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800384:	01174463          	blt	a4,a7,80038c <vprintfmt+0x17e>
    else if (lflag) {
  800388:	18088163          	beqz	a7,80050a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  80038c:	000a3603          	ld	a2,0(s4)
  800390:	46a9                	li	a3,10
  800392:	8a2e                	mv	s4,a1
  800394:	bfc1                	j	800364 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800396:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80039a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  80039c:	846a                	mv	s0,s10
            goto reswitch;
  80039e:	bdf1                	j	80027a <vprintfmt+0x6c>
            putch(ch, putdat);
  8003a0:	85a6                	mv	a1,s1
  8003a2:	02500513          	li	a0,37
  8003a6:	9902                	jalr	s2
            break;
  8003a8:	b545                	j	800248 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  8003aa:	00144603          	lbu	a2,1(s0)
            lflag ++;
  8003ae:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003b0:	846a                	mv	s0,s10
            goto reswitch;
  8003b2:	b5e1                	j	80027a <vprintfmt+0x6c>
    if (lflag >= 2) {
  8003b4:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003b6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8003ba:	01174463          	blt	a4,a7,8003c2 <vprintfmt+0x1b4>
    else if (lflag) {
  8003be:	14088163          	beqz	a7,800500 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  8003c2:	000a3603          	ld	a2,0(s4)
  8003c6:	46a1                	li	a3,8
  8003c8:	8a2e                	mv	s4,a1
  8003ca:	bf69                	j	800364 <vprintfmt+0x156>
            putch('0', putdat);
  8003cc:	03000513          	li	a0,48
  8003d0:	85a6                	mv	a1,s1
  8003d2:	e03e                	sd	a5,0(sp)
  8003d4:	9902                	jalr	s2
            putch('x', putdat);
  8003d6:	85a6                	mv	a1,s1
  8003d8:	07800513          	li	a0,120
  8003dc:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003de:	0a21                	addi	s4,s4,8
            goto number;
  8003e0:	6782                	ld	a5,0(sp)
  8003e2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003e4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  8003e8:	bfb5                	j	800364 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003ea:	000a3403          	ld	s0,0(s4)
  8003ee:	008a0713          	addi	a4,s4,8
  8003f2:	e03a                	sd	a4,0(sp)
  8003f4:	14040263          	beqz	s0,800538 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003f8:	0fb05763          	blez	s11,8004e6 <vprintfmt+0x2d8>
  8003fc:	02d00693          	li	a3,45
  800400:	0cd79163          	bne	a5,a3,8004c2 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800404:	00044783          	lbu	a5,0(s0)
  800408:	0007851b          	sext.w	a0,a5
  80040c:	cf85                	beqz	a5,800444 <vprintfmt+0x236>
  80040e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  800412:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800416:	000c4563          	bltz	s8,800420 <vprintfmt+0x212>
  80041a:	3c7d                	addiw	s8,s8,-1
  80041c:	036c0263          	beq	s8,s6,800440 <vprintfmt+0x232>
                    putch('?', putdat);
  800420:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800422:	0e0c8e63          	beqz	s9,80051e <vprintfmt+0x310>
  800426:	3781                	addiw	a5,a5,-32
  800428:	0ef47b63          	bgeu	s0,a5,80051e <vprintfmt+0x310>
                    putch('?', putdat);
  80042c:	03f00513          	li	a0,63
  800430:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800432:	000a4783          	lbu	a5,0(s4)
  800436:	3dfd                	addiw	s11,s11,-1
  800438:	0a05                	addi	s4,s4,1
  80043a:	0007851b          	sext.w	a0,a5
  80043e:	ffe1                	bnez	a5,800416 <vprintfmt+0x208>
            for (; width > 0; width --) {
  800440:	01b05963          	blez	s11,800452 <vprintfmt+0x244>
  800444:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800446:	85a6                	mv	a1,s1
  800448:	02000513          	li	a0,32
  80044c:	9902                	jalr	s2
            for (; width > 0; width --) {
  80044e:	fe0d9be3          	bnez	s11,800444 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  800452:	6a02                	ld	s4,0(sp)
  800454:	bbd5                	j	800248 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800456:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800458:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  80045c:	01174463          	blt	a4,a7,800464 <vprintfmt+0x256>
    else if (lflag) {
  800460:	08088d63          	beqz	a7,8004fa <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  800464:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800468:	0a044d63          	bltz	s0,800522 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  80046c:	8622                	mv	a2,s0
  80046e:	8a66                	mv	s4,s9
  800470:	46a9                	li	a3,10
  800472:	bdcd                	j	800364 <vprintfmt+0x156>
            err = va_arg(ap, int);
  800474:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800478:	4761                	li	a4,24
            err = va_arg(ap, int);
  80047a:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80047c:	41f7d69b          	sraiw	a3,a5,0x1f
  800480:	8fb5                	xor	a5,a5,a3
  800482:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800486:	02d74163          	blt	a4,a3,8004a8 <vprintfmt+0x29a>
  80048a:	00369793          	slli	a5,a3,0x3
  80048e:	97de                	add	a5,a5,s7
  800490:	639c                	ld	a5,0(a5)
  800492:	cb99                	beqz	a5,8004a8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800494:	86be                	mv	a3,a5
  800496:	00000617          	auipc	a2,0x0
  80049a:	23260613          	addi	a2,a2,562 # 8006c8 <main+0x11c>
  80049e:	85a6                	mv	a1,s1
  8004a0:	854a                	mv	a0,s2
  8004a2:	0ce000ef          	jal	ra,800570 <printfmt>
  8004a6:	b34d                	j	800248 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8004a8:	00000617          	auipc	a2,0x0
  8004ac:	21060613          	addi	a2,a2,528 # 8006b8 <main+0x10c>
  8004b0:	85a6                	mv	a1,s1
  8004b2:	854a                	mv	a0,s2
  8004b4:	0bc000ef          	jal	ra,800570 <printfmt>
  8004b8:	bb41                	j	800248 <vprintfmt+0x3a>
                p = "(null)";
  8004ba:	00000417          	auipc	s0,0x0
  8004be:	1f640413          	addi	s0,s0,502 # 8006b0 <main+0x104>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c2:	85e2                	mv	a1,s8
  8004c4:	8522                	mv	a0,s0
  8004c6:	e43e                	sd	a5,8(sp)
  8004c8:	0c8000ef          	jal	ra,800590 <strnlen>
  8004cc:	40ad8dbb          	subw	s11,s11,a0
  8004d0:	01b05b63          	blez	s11,8004e6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  8004d4:	67a2                	ld	a5,8(sp)
  8004d6:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004da:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004dc:	85a6                	mv	a1,s1
  8004de:	8552                	mv	a0,s4
  8004e0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e2:	fe0d9ce3          	bnez	s11,8004da <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e6:	00044783          	lbu	a5,0(s0)
  8004ea:	00140a13          	addi	s4,s0,1
  8004ee:	0007851b          	sext.w	a0,a5
  8004f2:	d3a5                	beqz	a5,800452 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  8004f4:	05e00413          	li	s0,94
  8004f8:	bf39                	j	800416 <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004fa:	000a2403          	lw	s0,0(s4)
  8004fe:	b7ad                	j	800468 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  800500:	000a6603          	lwu	a2,0(s4)
  800504:	46a1                	li	a3,8
  800506:	8a2e                	mv	s4,a1
  800508:	bdb1                	j	800364 <vprintfmt+0x156>
  80050a:	000a6603          	lwu	a2,0(s4)
  80050e:	46a9                	li	a3,10
  800510:	8a2e                	mv	s4,a1
  800512:	bd89                	j	800364 <vprintfmt+0x156>
  800514:	000a6603          	lwu	a2,0(s4)
  800518:	46c1                	li	a3,16
  80051a:	8a2e                	mv	s4,a1
  80051c:	b5a1                	j	800364 <vprintfmt+0x156>
                    putch(ch, putdat);
  80051e:	9902                	jalr	s2
  800520:	bf09                	j	800432 <vprintfmt+0x224>
                putch('-', putdat);
  800522:	85a6                	mv	a1,s1
  800524:	02d00513          	li	a0,45
  800528:	e03e                	sd	a5,0(sp)
  80052a:	9902                	jalr	s2
                num = -(long long)num;
  80052c:	6782                	ld	a5,0(sp)
  80052e:	8a66                	mv	s4,s9
  800530:	40800633          	neg	a2,s0
  800534:	46a9                	li	a3,10
  800536:	b53d                	j	800364 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  800538:	03b05163          	blez	s11,80055a <vprintfmt+0x34c>
  80053c:	02d00693          	li	a3,45
  800540:	f6d79de3          	bne	a5,a3,8004ba <vprintfmt+0x2ac>
                p = "(null)";
  800544:	00000417          	auipc	s0,0x0
  800548:	16c40413          	addi	s0,s0,364 # 8006b0 <main+0x104>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80054c:	02800793          	li	a5,40
  800550:	02800513          	li	a0,40
  800554:	00140a13          	addi	s4,s0,1
  800558:	bd6d                	j	800412 <vprintfmt+0x204>
  80055a:	00000a17          	auipc	s4,0x0
  80055e:	157a0a13          	addi	s4,s4,343 # 8006b1 <main+0x105>
  800562:	02800513          	li	a0,40
  800566:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  80056a:	05e00413          	li	s0,94
  80056e:	b565                	j	800416 <vprintfmt+0x208>

0000000000800570 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800570:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800572:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800576:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800578:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80057a:	ec06                	sd	ra,24(sp)
  80057c:	f83a                	sd	a4,48(sp)
  80057e:	fc3e                	sd	a5,56(sp)
  800580:	e0c2                	sd	a6,64(sp)
  800582:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800584:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800586:	c89ff0ef          	jal	ra,80020e <vprintfmt>
}
  80058a:	60e2                	ld	ra,24(sp)
  80058c:	6161                	addi	sp,sp,80
  80058e:	8082                	ret

0000000000800590 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800590:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800592:	e589                	bnez	a1,80059c <strnlen+0xc>
  800594:	a811                	j	8005a8 <strnlen+0x18>
        cnt ++;
  800596:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800598:	00f58863          	beq	a1,a5,8005a8 <strnlen+0x18>
  80059c:	00f50733          	add	a4,a0,a5
  8005a0:	00074703          	lbu	a4,0(a4)
  8005a4:	fb6d                	bnez	a4,800596 <strnlen+0x6>
  8005a6:	85be                	mv	a1,a5
    }
    return cnt;
}
  8005a8:	852e                	mv	a0,a1
  8005aa:	8082                	ret

00000000008005ac <main>:
#include <stdio.h>

const int max_child = 32;

int
main(void) {
  8005ac:	1101                	addi	sp,sp,-32
  8005ae:	e822                	sd	s0,16(sp)
  8005b0:	e426                	sd	s1,8(sp)
  8005b2:	ec06                	sd	ra,24(sp)
    int n, pid;
    for (n = 0; n < max_child; n ++) {
  8005b4:	4401                	li	s0,0
  8005b6:	02000493          	li	s1,32
        if ((pid = fork()) == 0) {
  8005ba:	bd5ff0ef          	jal	ra,80018e <fork>
  8005be:	cd05                	beqz	a0,8005f6 <main+0x4a>
            cprintf("I am child %d\n", n);
            exit(0);
        }
        assert(pid > 0);
  8005c0:	06a05063          	blez	a0,800620 <main+0x74>
    for (n = 0; n < max_child; n ++) {
  8005c4:	2405                	addiw	s0,s0,1
  8005c6:	fe941ae3          	bne	s0,s1,8005ba <main+0xe>
  8005ca:	02000413          	li	s0,32
    if (n > max_child) {
        panic("fork claimed to work %d times!\n", n);
    }

    for (; n > 0; n --) {
        if (wait() != 0) {
  8005ce:	bc3ff0ef          	jal	ra,800190 <wait>
  8005d2:	ed05                	bnez	a0,80060a <main+0x5e>
    for (; n > 0; n --) {
  8005d4:	347d                	addiw	s0,s0,-1
  8005d6:	fc65                	bnez	s0,8005ce <main+0x22>
            panic("wait stopped early\n");
        }
    }

    if (wait() == 0) {
  8005d8:	bb9ff0ef          	jal	ra,800190 <wait>
  8005dc:	c12d                	beqz	a0,80063e <main+0x92>
        panic("wait got too many\n");
    }

    cprintf("forktest pass.\n");
  8005de:	00000517          	auipc	a0,0x0
  8005e2:	44250513          	addi	a0,a0,1090 # 800a20 <error_string+0x138>
  8005e6:	abdff0ef          	jal	ra,8000a2 <cprintf>
    return 0;
}
  8005ea:	60e2                	ld	ra,24(sp)
  8005ec:	6442                	ld	s0,16(sp)
  8005ee:	64a2                	ld	s1,8(sp)
  8005f0:	4501                	li	a0,0
  8005f2:	6105                	addi	sp,sp,32
  8005f4:	8082                	ret
            cprintf("I am child %d\n", n);
  8005f6:	85a2                	mv	a1,s0
  8005f8:	00000517          	auipc	a0,0x0
  8005fc:	3b850513          	addi	a0,a0,952 # 8009b0 <error_string+0xc8>
  800600:	aa3ff0ef          	jal	ra,8000a2 <cprintf>
            exit(0);
  800604:	4501                	li	a0,0
  800606:	b73ff0ef          	jal	ra,800178 <exit>
            panic("wait stopped early\n");
  80060a:	00000617          	auipc	a2,0x0
  80060e:	3e660613          	addi	a2,a2,998 # 8009f0 <error_string+0x108>
  800612:	45dd                	li	a1,23
  800614:	00000517          	auipc	a0,0x0
  800618:	3cc50513          	addi	a0,a0,972 # 8009e0 <error_string+0xf8>
  80061c:	a0bff0ef          	jal	ra,800026 <__panic>
        assert(pid > 0);
  800620:	00000697          	auipc	a3,0x0
  800624:	3a068693          	addi	a3,a3,928 # 8009c0 <error_string+0xd8>
  800628:	00000617          	auipc	a2,0x0
  80062c:	3a060613          	addi	a2,a2,928 # 8009c8 <error_string+0xe0>
  800630:	45b9                	li	a1,14
  800632:	00000517          	auipc	a0,0x0
  800636:	3ae50513          	addi	a0,a0,942 # 8009e0 <error_string+0xf8>
  80063a:	9edff0ef          	jal	ra,800026 <__panic>
        panic("wait got too many\n");
  80063e:	00000617          	auipc	a2,0x0
  800642:	3ca60613          	addi	a2,a2,970 # 800a08 <error_string+0x120>
  800646:	45f1                	li	a1,28
  800648:	00000517          	auipc	a0,0x0
  80064c:	39850513          	addi	a0,a0,920 # 8009e0 <error_string+0xf8>
  800650:	9d7ff0ef          	jal	ra,800026 <__panic>
