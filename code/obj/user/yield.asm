
obj/__user_yield.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	110000ef          	jal	ra,800130 <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800026:	1141                	addi	sp,sp,-16
  800028:	e022                	sd	s0,0(sp)
  80002a:	e406                	sd	ra,8(sp)
  80002c:	842e                	mv	s0,a1
    sys_putc(c);
  80002e:	0c0000ef          	jal	ra,8000ee <sys_putc>
    (*cnt) ++;
  800032:	401c                	lw	a5,0(s0)
}
  800034:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800036:	2785                	addiw	a5,a5,1
  800038:	c01c                	sw	a5,0(s0)
}
  80003a:	6402                	ld	s0,0(sp)
  80003c:	0141                	addi	sp,sp,16
  80003e:	8082                	ret

0000000000800040 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800040:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800042:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800046:	8e2a                	mv	t3,a0
  800048:	f42e                	sd	a1,40(sp)
  80004a:	f832                	sd	a2,48(sp)
  80004c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80004e:	00000517          	auipc	a0,0x0
  800052:	fd850513          	addi	a0,a0,-40 # 800026 <cputch>
  800056:	004c                	addi	a1,sp,4
  800058:	869a                	mv	a3,t1
  80005a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  80005c:	ec06                	sd	ra,24(sp)
  80005e:	e0ba                	sd	a4,64(sp)
  800060:	e4be                	sd	a5,72(sp)
  800062:	e8c2                	sd	a6,80(sp)
  800064:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800066:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800068:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80006a:	13e000ef          	jal	ra,8001a8 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80006e:	60e2                	ld	ra,24(sp)
  800070:	4512                	lw	a0,4(sp)
  800072:	6125                	addi	sp,sp,96
  800074:	8082                	ret

0000000000800076 <sys_exit>:
    );

    return ret;
}

int sys_exit(int64_t error_code) {
  800076:	7139                	addi	sp,sp,-64
  800078:	4785                	li	a5,1
  80007a:	e83e                	sd	a5,16(sp)
  80007c:	ec2a                	sd	a0,24(sp)
  80007e:	f002                	sd	zero,32(sp)
  800080:	f402                	sd	zero,40(sp)
  800082:	f802                	sd	zero,48(sp)
  800084:	fc02                	sd	zero,56(sp)
    asm volatile (
  800086:	6542                	ld	a0,16(sp)
  800088:	65e2                	ld	a1,24(sp)
  80008a:	7602                	ld	a2,32(sp)
  80008c:	76a2                	ld	a3,40(sp)
  80008e:	7742                	ld	a4,48(sp)
  800090:	77e2                	ld	a5,56(sp)
  800092:	00000073          	ecall
  800096:	c62a                	sw	a0,12(sp)
    return syscall(SYS_exit, error_code, 0, 0, 0, 0);
}
  800098:	4532                	lw	a0,12(sp)
  80009a:	6121                	addi	sp,sp,64
  80009c:	8082                	ret

000000000080009e <sys_yield>:

int sys_wait(int64_t pid, int *store) {
    return syscall(SYS_wait, pid, (uintptr_t)store, 0, 0, 0);
}

int sys_yield(void) {
  80009e:	7139                	addi	sp,sp,-64
  8000a0:	47a9                	li	a5,10
  8000a2:	e83e                	sd	a5,16(sp)
  8000a4:	ec02                	sd	zero,24(sp)
  8000a6:	f002                	sd	zero,32(sp)
  8000a8:	f402                	sd	zero,40(sp)
  8000aa:	f802                	sd	zero,48(sp)
  8000ac:	fc02                	sd	zero,56(sp)
    asm volatile (
  8000ae:	6542                	ld	a0,16(sp)
  8000b0:	65e2                	ld	a1,24(sp)
  8000b2:	7602                	ld	a2,32(sp)
  8000b4:	76a2                	ld	a3,40(sp)
  8000b6:	7742                	ld	a4,48(sp)
  8000b8:	77e2                	ld	a5,56(sp)
  8000ba:	00000073          	ecall
  8000be:	c62a                	sw	a0,12(sp)
    return syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  8000c0:	4532                	lw	a0,12(sp)
  8000c2:	6121                	addi	sp,sp,64
  8000c4:	8082                	ret

00000000008000c6 <sys_getpid>:

int sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid, 0, 0, 0, 0);
}

int sys_getpid(void) {
  8000c6:	7139                	addi	sp,sp,-64
  8000c8:	47c9                	li	a5,18
  8000ca:	e83e                	sd	a5,16(sp)
  8000cc:	ec02                	sd	zero,24(sp)
  8000ce:	f002                	sd	zero,32(sp)
  8000d0:	f402                	sd	zero,40(sp)
  8000d2:	f802                	sd	zero,48(sp)
  8000d4:	fc02                	sd	zero,56(sp)
    asm volatile (
  8000d6:	6542                	ld	a0,16(sp)
  8000d8:	65e2                	ld	a1,24(sp)
  8000da:	7602                	ld	a2,32(sp)
  8000dc:	76a2                	ld	a3,40(sp)
  8000de:	7742                	ld	a4,48(sp)
  8000e0:	77e2                	ld	a5,56(sp)
  8000e2:	00000073          	ecall
  8000e6:	c62a                	sw	a0,12(sp)
    return syscall(SYS_getpid, 0, 0, 0, 0, 0);
}
  8000e8:	4532                	lw	a0,12(sp)
  8000ea:	6121                	addi	sp,sp,64
  8000ec:	8082                	ret

00000000008000ee <sys_putc>:

int sys_putc(int64_t c) {
  8000ee:	7139                	addi	sp,sp,-64
  8000f0:	47f9                	li	a5,30
  8000f2:	e83e                	sd	a5,16(sp)
  8000f4:	ec2a                	sd	a0,24(sp)
  8000f6:	f002                	sd	zero,32(sp)
  8000f8:	f402                	sd	zero,40(sp)
  8000fa:	f802                	sd	zero,48(sp)
  8000fc:	fc02                	sd	zero,56(sp)
    asm volatile (
  8000fe:	6542                	ld	a0,16(sp)
  800100:	65e2                	ld	a1,24(sp)
  800102:	7602                	ld	a2,32(sp)
  800104:	76a2                	ld	a3,40(sp)
  800106:	7742                	ld	a4,48(sp)
  800108:	77e2                	ld	a5,56(sp)
  80010a:	00000073          	ecall
  80010e:	c62a                	sw	a0,12(sp)
    return syscall(SYS_putc, c, 0, 0, 0, 0);
}
  800110:	4532                	lw	a0,12(sp)
  800112:	6121                	addi	sp,sp,64
  800114:	8082                	ret

0000000000800116 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800116:	1141                	addi	sp,sp,-16
  800118:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80011a:	f5dff0ef          	jal	ra,800076 <sys_exit>
    cprintf("BUG: exit failed.\n");
  80011e:	00000517          	auipc	a0,0x0
  800122:	49a50513          	addi	a0,a0,1178 # 8005b8 <main+0x72>
  800126:	f1bff0ef          	jal	ra,800040 <cprintf>
    while (1);
  80012a:	a001                	j	80012a <exit+0x14>

000000000080012c <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  80012c:	bf8d                	j	80009e <sys_yield>

000000000080012e <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  80012e:	bf61                	j	8000c6 <sys_getpid>

0000000000800130 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800130:	1141                	addi	sp,sp,-16
  800132:	e406                	sd	ra,8(sp)
    int ret = main();
  800134:	412000ef          	jal	ra,800546 <main>
    exit(ret);
  800138:	fdfff0ef          	jal	ra,800116 <exit>

000000000080013c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80013c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800140:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800142:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800146:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800148:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80014c:	f022                	sd	s0,32(sp)
  80014e:	ec26                	sd	s1,24(sp)
  800150:	e84a                	sd	s2,16(sp)
  800152:	f406                	sd	ra,40(sp)
  800154:	e44e                	sd	s3,8(sp)
  800156:	84aa                	mv	s1,a0
  800158:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80015a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80015e:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800160:	03067e63          	bgeu	a2,a6,80019c <printnum+0x60>
  800164:	89be                	mv	s3,a5
        while (-- width > 0)
  800166:	00805763          	blez	s0,800174 <printnum+0x38>
  80016a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80016c:	85ca                	mv	a1,s2
  80016e:	854e                	mv	a0,s3
  800170:	9482                	jalr	s1
        while (-- width > 0)
  800172:	fc65                	bnez	s0,80016a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800174:	1a02                	slli	s4,s4,0x20
  800176:	00000797          	auipc	a5,0x0
  80017a:	45a78793          	addi	a5,a5,1114 # 8005d0 <main+0x8a>
  80017e:	020a5a13          	srli	s4,s4,0x20
  800182:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800184:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800186:	000a4503          	lbu	a0,0(s4)
}
  80018a:	70a2                	ld	ra,40(sp)
  80018c:	69a2                	ld	s3,8(sp)
  80018e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800190:	85ca                	mv	a1,s2
  800192:	87a6                	mv	a5,s1
}
  800194:	6942                	ld	s2,16(sp)
  800196:	64e2                	ld	s1,24(sp)
  800198:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80019a:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80019c:	03065633          	divu	a2,a2,a6
  8001a0:	8722                	mv	a4,s0
  8001a2:	f9bff0ef          	jal	ra,80013c <printnum>
  8001a6:	b7f9                	j	800174 <printnum+0x38>

00000000008001a8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001a8:	7119                	addi	sp,sp,-128
  8001aa:	f4a6                	sd	s1,104(sp)
  8001ac:	f0ca                	sd	s2,96(sp)
  8001ae:	ecce                	sd	s3,88(sp)
  8001b0:	e8d2                	sd	s4,80(sp)
  8001b2:	e4d6                	sd	s5,72(sp)
  8001b4:	e0da                	sd	s6,64(sp)
  8001b6:	fc5e                	sd	s7,56(sp)
  8001b8:	f06a                	sd	s10,32(sp)
  8001ba:	fc86                	sd	ra,120(sp)
  8001bc:	f8a2                	sd	s0,112(sp)
  8001be:	f862                	sd	s8,48(sp)
  8001c0:	f466                	sd	s9,40(sp)
  8001c2:	ec6e                	sd	s11,24(sp)
  8001c4:	892a                	mv	s2,a0
  8001c6:	84ae                	mv	s1,a1
  8001c8:	8d32                	mv	s10,a2
  8001ca:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001cc:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001d0:	5b7d                	li	s6,-1
  8001d2:	00000a97          	auipc	s5,0x0
  8001d6:	432a8a93          	addi	s5,s5,1074 # 800604 <main+0xbe>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001da:	00000b97          	auipc	s7,0x0
  8001de:	646b8b93          	addi	s7,s7,1606 # 800820 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e2:	000d4503          	lbu	a0,0(s10)
  8001e6:	001d0413          	addi	s0,s10,1
  8001ea:	01350a63          	beq	a0,s3,8001fe <vprintfmt+0x56>
            if (ch == '\0') {
  8001ee:	c121                	beqz	a0,80022e <vprintfmt+0x86>
            putch(ch, putdat);
  8001f0:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f2:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001f4:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f6:	fff44503          	lbu	a0,-1(s0)
  8001fa:	ff351ae3          	bne	a0,s3,8001ee <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  8001fe:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800202:	02000793          	li	a5,32
        lflag = altflag = 0;
  800206:	4c81                	li	s9,0
  800208:	4881                	li	a7,0
        width = precision = -1;
  80020a:	5c7d                	li	s8,-1
  80020c:	5dfd                	li	s11,-1
  80020e:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800212:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  800214:	fdd6059b          	addiw	a1,a2,-35
  800218:	0ff5f593          	andi	a1,a1,255
  80021c:	00140d13          	addi	s10,s0,1
  800220:	04b56263          	bltu	a0,a1,800264 <vprintfmt+0xbc>
  800224:	058a                	slli	a1,a1,0x2
  800226:	95d6                	add	a1,a1,s5
  800228:	4194                	lw	a3,0(a1)
  80022a:	96d6                	add	a3,a3,s5
  80022c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80022e:	70e6                	ld	ra,120(sp)
  800230:	7446                	ld	s0,112(sp)
  800232:	74a6                	ld	s1,104(sp)
  800234:	7906                	ld	s2,96(sp)
  800236:	69e6                	ld	s3,88(sp)
  800238:	6a46                	ld	s4,80(sp)
  80023a:	6aa6                	ld	s5,72(sp)
  80023c:	6b06                	ld	s6,64(sp)
  80023e:	7be2                	ld	s7,56(sp)
  800240:	7c42                	ld	s8,48(sp)
  800242:	7ca2                	ld	s9,40(sp)
  800244:	7d02                	ld	s10,32(sp)
  800246:	6de2                	ld	s11,24(sp)
  800248:	6109                	addi	sp,sp,128
  80024a:	8082                	ret
            padc = '0';
  80024c:	87b2                	mv	a5,a2
            goto reswitch;
  80024e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800252:	846a                	mv	s0,s10
  800254:	00140d13          	addi	s10,s0,1
  800258:	fdd6059b          	addiw	a1,a2,-35
  80025c:	0ff5f593          	andi	a1,a1,255
  800260:	fcb572e3          	bgeu	a0,a1,800224 <vprintfmt+0x7c>
            putch('%', putdat);
  800264:	85a6                	mv	a1,s1
  800266:	02500513          	li	a0,37
  80026a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80026c:	fff44783          	lbu	a5,-1(s0)
  800270:	8d22                	mv	s10,s0
  800272:	f73788e3          	beq	a5,s3,8001e2 <vprintfmt+0x3a>
  800276:	ffed4783          	lbu	a5,-2(s10)
  80027a:	1d7d                	addi	s10,s10,-1
  80027c:	ff379de3          	bne	a5,s3,800276 <vprintfmt+0xce>
  800280:	b78d                	j	8001e2 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  800282:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  800286:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80028a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80028c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800290:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800294:	02d86463          	bltu	a6,a3,8002bc <vprintfmt+0x114>
                ch = *fmt;
  800298:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  80029c:	002c169b          	slliw	a3,s8,0x2
  8002a0:	0186873b          	addw	a4,a3,s8
  8002a4:	0017171b          	slliw	a4,a4,0x1
  8002a8:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002aa:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002ae:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002b0:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002b4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002b8:	fed870e3          	bgeu	a6,a3,800298 <vprintfmt+0xf0>
            if (width < 0)
  8002bc:	f40ddce3          	bgez	s11,800214 <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002c0:	8de2                	mv	s11,s8
  8002c2:	5c7d                	li	s8,-1
  8002c4:	bf81                	j	800214 <vprintfmt+0x6c>
            if (width < 0)
  8002c6:	fffdc693          	not	a3,s11
  8002ca:	96fd                	srai	a3,a3,0x3f
  8002cc:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  8002d0:	00144603          	lbu	a2,1(s0)
  8002d4:	2d81                	sext.w	s11,s11
  8002d6:	846a                	mv	s0,s10
            goto reswitch;
  8002d8:	bf35                	j	800214 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  8002da:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002de:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002e2:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002e4:	846a                	mv	s0,s10
            goto process_precision;
  8002e6:	bfd9                	j	8002bc <vprintfmt+0x114>
    if (lflag >= 2) {
  8002e8:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002ea:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002ee:	01174463          	blt	a4,a7,8002f6 <vprintfmt+0x14e>
    else if (lflag) {
  8002f2:	1a088e63          	beqz	a7,8004ae <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  8002f6:	000a3603          	ld	a2,0(s4)
  8002fa:	46c1                	li	a3,16
  8002fc:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002fe:	2781                	sext.w	a5,a5
  800300:	876e                	mv	a4,s11
  800302:	85a6                	mv	a1,s1
  800304:	854a                	mv	a0,s2
  800306:	e37ff0ef          	jal	ra,80013c <printnum>
            break;
  80030a:	bde1                	j	8001e2 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  80030c:	000a2503          	lw	a0,0(s4)
  800310:	85a6                	mv	a1,s1
  800312:	0a21                	addi	s4,s4,8
  800314:	9902                	jalr	s2
            break;
  800316:	b5f1                	j	8001e2 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800318:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80031a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80031e:	01174463          	blt	a4,a7,800326 <vprintfmt+0x17e>
    else if (lflag) {
  800322:	18088163          	beqz	a7,8004a4 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  800326:	000a3603          	ld	a2,0(s4)
  80032a:	46a9                	li	a3,10
  80032c:	8a2e                	mv	s4,a1
  80032e:	bfc1                	j	8002fe <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800330:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800334:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  800336:	846a                	mv	s0,s10
            goto reswitch;
  800338:	bdf1                	j	800214 <vprintfmt+0x6c>
            putch(ch, putdat);
  80033a:	85a6                	mv	a1,s1
  80033c:	02500513          	li	a0,37
  800340:	9902                	jalr	s2
            break;
  800342:	b545                	j	8001e2 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800344:	00144603          	lbu	a2,1(s0)
            lflag ++;
  800348:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  80034a:	846a                	mv	s0,s10
            goto reswitch;
  80034c:	b5e1                	j	800214 <vprintfmt+0x6c>
    if (lflag >= 2) {
  80034e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800350:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800354:	01174463          	blt	a4,a7,80035c <vprintfmt+0x1b4>
    else if (lflag) {
  800358:	14088163          	beqz	a7,80049a <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  80035c:	000a3603          	ld	a2,0(s4)
  800360:	46a1                	li	a3,8
  800362:	8a2e                	mv	s4,a1
  800364:	bf69                	j	8002fe <vprintfmt+0x156>
            putch('0', putdat);
  800366:	03000513          	li	a0,48
  80036a:	85a6                	mv	a1,s1
  80036c:	e03e                	sd	a5,0(sp)
  80036e:	9902                	jalr	s2
            putch('x', putdat);
  800370:	85a6                	mv	a1,s1
  800372:	07800513          	li	a0,120
  800376:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800378:	0a21                	addi	s4,s4,8
            goto number;
  80037a:	6782                	ld	a5,0(sp)
  80037c:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80037e:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  800382:	bfb5                	j	8002fe <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  800384:	000a3403          	ld	s0,0(s4)
  800388:	008a0713          	addi	a4,s4,8
  80038c:	e03a                	sd	a4,0(sp)
  80038e:	14040263          	beqz	s0,8004d2 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  800392:	0fb05763          	blez	s11,800480 <vprintfmt+0x2d8>
  800396:	02d00693          	li	a3,45
  80039a:	0cd79163          	bne	a5,a3,80045c <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80039e:	00044783          	lbu	a5,0(s0)
  8003a2:	0007851b          	sext.w	a0,a5
  8003a6:	cf85                	beqz	a5,8003de <vprintfmt+0x236>
  8003a8:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ac:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b0:	000c4563          	bltz	s8,8003ba <vprintfmt+0x212>
  8003b4:	3c7d                	addiw	s8,s8,-1
  8003b6:	036c0263          	beq	s8,s6,8003da <vprintfmt+0x232>
                    putch('?', putdat);
  8003ba:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003bc:	0e0c8e63          	beqz	s9,8004b8 <vprintfmt+0x310>
  8003c0:	3781                	addiw	a5,a5,-32
  8003c2:	0ef47b63          	bgeu	s0,a5,8004b8 <vprintfmt+0x310>
                    putch('?', putdat);
  8003c6:	03f00513          	li	a0,63
  8003ca:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003cc:	000a4783          	lbu	a5,0(s4)
  8003d0:	3dfd                	addiw	s11,s11,-1
  8003d2:	0a05                	addi	s4,s4,1
  8003d4:	0007851b          	sext.w	a0,a5
  8003d8:	ffe1                	bnez	a5,8003b0 <vprintfmt+0x208>
            for (; width > 0; width --) {
  8003da:	01b05963          	blez	s11,8003ec <vprintfmt+0x244>
  8003de:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003e0:	85a6                	mv	a1,s1
  8003e2:	02000513          	li	a0,32
  8003e6:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003e8:	fe0d9be3          	bnez	s11,8003de <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003ec:	6a02                	ld	s4,0(sp)
  8003ee:	bbd5                	j	8001e2 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003f0:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003f2:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  8003f6:	01174463          	blt	a4,a7,8003fe <vprintfmt+0x256>
    else if (lflag) {
  8003fa:	08088d63          	beqz	a7,800494 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  8003fe:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800402:	0a044d63          	bltz	s0,8004bc <vprintfmt+0x314>
            num = getint(&ap, lflag);
  800406:	8622                	mv	a2,s0
  800408:	8a66                	mv	s4,s9
  80040a:	46a9                	li	a3,10
  80040c:	bdcd                	j	8002fe <vprintfmt+0x156>
            err = va_arg(ap, int);
  80040e:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800412:	4761                	li	a4,24
            err = va_arg(ap, int);
  800414:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800416:	41f7d69b          	sraiw	a3,a5,0x1f
  80041a:	8fb5                	xor	a5,a5,a3
  80041c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800420:	02d74163          	blt	a4,a3,800442 <vprintfmt+0x29a>
  800424:	00369793          	slli	a5,a3,0x3
  800428:	97de                	add	a5,a5,s7
  80042a:	639c                	ld	a5,0(a5)
  80042c:	cb99                	beqz	a5,800442 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  80042e:	86be                	mv	a3,a5
  800430:	00000617          	auipc	a2,0x0
  800434:	1d060613          	addi	a2,a2,464 # 800600 <main+0xba>
  800438:	85a6                	mv	a1,s1
  80043a:	854a                	mv	a0,s2
  80043c:	0ce000ef          	jal	ra,80050a <printfmt>
  800440:	b34d                	j	8001e2 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800442:	00000617          	auipc	a2,0x0
  800446:	1ae60613          	addi	a2,a2,430 # 8005f0 <main+0xaa>
  80044a:	85a6                	mv	a1,s1
  80044c:	854a                	mv	a0,s2
  80044e:	0bc000ef          	jal	ra,80050a <printfmt>
  800452:	bb41                	j	8001e2 <vprintfmt+0x3a>
                p = "(null)";
  800454:	00000417          	auipc	s0,0x0
  800458:	19440413          	addi	s0,s0,404 # 8005e8 <main+0xa2>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80045c:	85e2                	mv	a1,s8
  80045e:	8522                	mv	a0,s0
  800460:	e43e                	sd	a5,8(sp)
  800462:	0c8000ef          	jal	ra,80052a <strnlen>
  800466:	40ad8dbb          	subw	s11,s11,a0
  80046a:	01b05b63          	blez	s11,800480 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  80046e:	67a2                	ld	a5,8(sp)
  800470:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800474:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800476:	85a6                	mv	a1,s1
  800478:	8552                	mv	a0,s4
  80047a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80047c:	fe0d9ce3          	bnez	s11,800474 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800480:	00044783          	lbu	a5,0(s0)
  800484:	00140a13          	addi	s4,s0,1
  800488:	0007851b          	sext.w	a0,a5
  80048c:	d3a5                	beqz	a5,8003ec <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  80048e:	05e00413          	li	s0,94
  800492:	bf39                	j	8003b0 <vprintfmt+0x208>
        return va_arg(*ap, int);
  800494:	000a2403          	lw	s0,0(s4)
  800498:	b7ad                	j	800402 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  80049a:	000a6603          	lwu	a2,0(s4)
  80049e:	46a1                	li	a3,8
  8004a0:	8a2e                	mv	s4,a1
  8004a2:	bdb1                	j	8002fe <vprintfmt+0x156>
  8004a4:	000a6603          	lwu	a2,0(s4)
  8004a8:	46a9                	li	a3,10
  8004aa:	8a2e                	mv	s4,a1
  8004ac:	bd89                	j	8002fe <vprintfmt+0x156>
  8004ae:	000a6603          	lwu	a2,0(s4)
  8004b2:	46c1                	li	a3,16
  8004b4:	8a2e                	mv	s4,a1
  8004b6:	b5a1                	j	8002fe <vprintfmt+0x156>
                    putch(ch, putdat);
  8004b8:	9902                	jalr	s2
  8004ba:	bf09                	j	8003cc <vprintfmt+0x224>
                putch('-', putdat);
  8004bc:	85a6                	mv	a1,s1
  8004be:	02d00513          	li	a0,45
  8004c2:	e03e                	sd	a5,0(sp)
  8004c4:	9902                	jalr	s2
                num = -(long long)num;
  8004c6:	6782                	ld	a5,0(sp)
  8004c8:	8a66                	mv	s4,s9
  8004ca:	40800633          	neg	a2,s0
  8004ce:	46a9                	li	a3,10
  8004d0:	b53d                	j	8002fe <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  8004d2:	03b05163          	blez	s11,8004f4 <vprintfmt+0x34c>
  8004d6:	02d00693          	li	a3,45
  8004da:	f6d79de3          	bne	a5,a3,800454 <vprintfmt+0x2ac>
                p = "(null)";
  8004de:	00000417          	auipc	s0,0x0
  8004e2:	10a40413          	addi	s0,s0,266 # 8005e8 <main+0xa2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e6:	02800793          	li	a5,40
  8004ea:	02800513          	li	a0,40
  8004ee:	00140a13          	addi	s4,s0,1
  8004f2:	bd6d                	j	8003ac <vprintfmt+0x204>
  8004f4:	00000a17          	auipc	s4,0x0
  8004f8:	0f5a0a13          	addi	s4,s4,245 # 8005e9 <main+0xa3>
  8004fc:	02800513          	li	a0,40
  800500:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800504:	05e00413          	li	s0,94
  800508:	b565                	j	8003b0 <vprintfmt+0x208>

000000000080050a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80050c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800510:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800512:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800514:	ec06                	sd	ra,24(sp)
  800516:	f83a                	sd	a4,48(sp)
  800518:	fc3e                	sd	a5,56(sp)
  80051a:	e0c2                	sd	a6,64(sp)
  80051c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80051e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800520:	c89ff0ef          	jal	ra,8001a8 <vprintfmt>
}
  800524:	60e2                	ld	ra,24(sp)
  800526:	6161                	addi	sp,sp,80
  800528:	8082                	ret

000000000080052a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80052a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80052c:	e589                	bnez	a1,800536 <strnlen+0xc>
  80052e:	a811                	j	800542 <strnlen+0x18>
        cnt ++;
  800530:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800532:	00f58863          	beq	a1,a5,800542 <strnlen+0x18>
  800536:	00f50733          	add	a4,a0,a5
  80053a:	00074703          	lbu	a4,0(a4)
  80053e:	fb6d                	bnez	a4,800530 <strnlen+0x6>
  800540:	85be                	mv	a1,a5
    }
    return cnt;
}
  800542:	852e                	mv	a0,a1
  800544:	8082                	ret

0000000000800546 <main>:
#include <ulib.h>
#include <stdio.h>

int
main(void) {
  800546:	1101                	addi	sp,sp,-32
  800548:	ec06                	sd	ra,24(sp)
  80054a:	e822                	sd	s0,16(sp)
  80054c:	e426                	sd	s1,8(sp)
  80054e:	e04a                	sd	s2,0(sp)
    int i;
    cprintf("Hello, I am process %d.\n", getpid());
  800550:	bdfff0ef          	jal	ra,80012e <getpid>
  800554:	85aa                	mv	a1,a0
  800556:	00000517          	auipc	a0,0x0
  80055a:	39250513          	addi	a0,a0,914 # 8008e8 <error_string+0xc8>
  80055e:	ae3ff0ef          	jal	ra,800040 <cprintf>
    for (i = 0; i < 5; i ++) {
  800562:	4401                	li	s0,0
        yield();
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800564:	00000917          	auipc	s2,0x0
  800568:	3a490913          	addi	s2,s2,932 # 800908 <error_string+0xe8>
    for (i = 0; i < 5; i ++) {
  80056c:	4495                	li	s1,5
        yield();
  80056e:	bbfff0ef          	jal	ra,80012c <yield>
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800572:	bbdff0ef          	jal	ra,80012e <getpid>
  800576:	85aa                	mv	a1,a0
  800578:	8622                	mv	a2,s0
  80057a:	854a                	mv	a0,s2
    for (i = 0; i < 5; i ++) {
  80057c:	2405                	addiw	s0,s0,1
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  80057e:	ac3ff0ef          	jal	ra,800040 <cprintf>
    for (i = 0; i < 5; i ++) {
  800582:	fe9416e3          	bne	s0,s1,80056e <main+0x28>
    }
    cprintf("All done in process %d.\n", getpid());
  800586:	ba9ff0ef          	jal	ra,80012e <getpid>
  80058a:	85aa                	mv	a1,a0
  80058c:	00000517          	auipc	a0,0x0
  800590:	3a450513          	addi	a0,a0,932 # 800930 <error_string+0x110>
  800594:	aadff0ef          	jal	ra,800040 <cprintf>
    cprintf("yield pass.\n");
  800598:	00000517          	auipc	a0,0x0
  80059c:	3b850513          	addi	a0,a0,952 # 800950 <error_string+0x130>
  8005a0:	aa1ff0ef          	jal	ra,800040 <cprintf>
    return 0;
}
  8005a4:	60e2                	ld	ra,24(sp)
  8005a6:	6442                	ld	s0,16(sp)
  8005a8:	64a2                	ld	s1,8(sp)
  8005aa:	6902                	ld	s2,0(sp)
  8005ac:	4501                	li	a0,0
  8005ae:	6105                	addi	sp,sp,32
  8005b0:	8082                	ret
