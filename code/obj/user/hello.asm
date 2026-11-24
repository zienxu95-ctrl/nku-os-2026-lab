
obj/__user_hello.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0e6000ef          	jal	ra,800106 <umain>
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
  80002e:	098000ef          	jal	ra,8000c6 <sys_putc>
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
  80006a:	114000ef          	jal	ra,80017e <vprintfmt>
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

000000000080009e <sys_getpid>:

int sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid, 0, 0, 0, 0);
}

int sys_getpid(void) {
  80009e:	7139                	addi	sp,sp,-64
  8000a0:	47c9                	li	a5,18
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
    return syscall(SYS_getpid, 0, 0, 0, 0, 0);
}
  8000c0:	4532                	lw	a0,12(sp)
  8000c2:	6121                	addi	sp,sp,64
  8000c4:	8082                	ret

00000000008000c6 <sys_putc>:

int sys_putc(int64_t c) {
  8000c6:	7139                	addi	sp,sp,-64
  8000c8:	47f9                	li	a5,30
  8000ca:	e83e                	sd	a5,16(sp)
  8000cc:	ec2a                	sd	a0,24(sp)
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
    return syscall(SYS_putc, c, 0, 0, 0, 0);
}
  8000e8:	4532                	lw	a0,12(sp)
  8000ea:	6121                	addi	sp,sp,64
  8000ec:	8082                	ret

00000000008000ee <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000ee:	1141                	addi	sp,sp,-16
  8000f0:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000f2:	f85ff0ef          	jal	ra,800076 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000f6:	00000517          	auipc	a0,0x0
  8000fa:	46250513          	addi	a0,a0,1122 # 800558 <main+0x3c>
  8000fe:	f43ff0ef          	jal	ra,800040 <cprintf>
    while (1);
  800102:	a001                	j	800102 <exit+0x14>

0000000000800104 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  800104:	bf69                	j	80009e <sys_getpid>

0000000000800106 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800106:	1141                	addi	sp,sp,-16
  800108:	e406                	sd	ra,8(sp)
    int ret = main();
  80010a:	412000ef          	jal	ra,80051c <main>
    exit(ret);
  80010e:	fe1ff0ef          	jal	ra,8000ee <exit>

0000000000800112 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800112:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800116:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800118:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80011c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80011e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800122:	f022                	sd	s0,32(sp)
  800124:	ec26                	sd	s1,24(sp)
  800126:	e84a                	sd	s2,16(sp)
  800128:	f406                	sd	ra,40(sp)
  80012a:	e44e                	sd	s3,8(sp)
  80012c:	84aa                	mv	s1,a0
  80012e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800130:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800134:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800136:	03067e63          	bgeu	a2,a6,800172 <printnum+0x60>
  80013a:	89be                	mv	s3,a5
        while (-- width > 0)
  80013c:	00805763          	blez	s0,80014a <printnum+0x38>
  800140:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800142:	85ca                	mv	a1,s2
  800144:	854e                	mv	a0,s3
  800146:	9482                	jalr	s1
        while (-- width > 0)
  800148:	fc65                	bnez	s0,800140 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80014a:	1a02                	slli	s4,s4,0x20
  80014c:	00000797          	auipc	a5,0x0
  800150:	42478793          	addi	a5,a5,1060 # 800570 <main+0x54>
  800154:	020a5a13          	srli	s4,s4,0x20
  800158:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80015a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80015c:	000a4503          	lbu	a0,0(s4)
}
  800160:	70a2                	ld	ra,40(sp)
  800162:	69a2                	ld	s3,8(sp)
  800164:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800166:	85ca                	mv	a1,s2
  800168:	87a6                	mv	a5,s1
}
  80016a:	6942                	ld	s2,16(sp)
  80016c:	64e2                	ld	s1,24(sp)
  80016e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800170:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800172:	03065633          	divu	a2,a2,a6
  800176:	8722                	mv	a4,s0
  800178:	f9bff0ef          	jal	ra,800112 <printnum>
  80017c:	b7f9                	j	80014a <printnum+0x38>

000000000080017e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80017e:	7119                	addi	sp,sp,-128
  800180:	f4a6                	sd	s1,104(sp)
  800182:	f0ca                	sd	s2,96(sp)
  800184:	ecce                	sd	s3,88(sp)
  800186:	e8d2                	sd	s4,80(sp)
  800188:	e4d6                	sd	s5,72(sp)
  80018a:	e0da                	sd	s6,64(sp)
  80018c:	fc5e                	sd	s7,56(sp)
  80018e:	f06a                	sd	s10,32(sp)
  800190:	fc86                	sd	ra,120(sp)
  800192:	f8a2                	sd	s0,112(sp)
  800194:	f862                	sd	s8,48(sp)
  800196:	f466                	sd	s9,40(sp)
  800198:	ec6e                	sd	s11,24(sp)
  80019a:	892a                	mv	s2,a0
  80019c:	84ae                	mv	s1,a1
  80019e:	8d32                	mv	s10,a2
  8001a0:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a2:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001a6:	5b7d                	li	s6,-1
  8001a8:	00000a97          	auipc	s5,0x0
  8001ac:	3fca8a93          	addi	s5,s5,1020 # 8005a4 <main+0x88>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001b0:	00000b97          	auipc	s7,0x0
  8001b4:	610b8b93          	addi	s7,s7,1552 # 8007c0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001b8:	000d4503          	lbu	a0,0(s10)
  8001bc:	001d0413          	addi	s0,s10,1
  8001c0:	01350a63          	beq	a0,s3,8001d4 <vprintfmt+0x56>
            if (ch == '\0') {
  8001c4:	c121                	beqz	a0,800204 <vprintfmt+0x86>
            putch(ch, putdat);
  8001c6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001ca:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001cc:	fff44503          	lbu	a0,-1(s0)
  8001d0:	ff351ae3          	bne	a0,s3,8001c4 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  8001d4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001d8:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001dc:	4c81                	li	s9,0
  8001de:	4881                	li	a7,0
        width = precision = -1;
  8001e0:	5c7d                	li	s8,-1
  8001e2:	5dfd                	li	s11,-1
  8001e4:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  8001e8:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001ea:	fdd6059b          	addiw	a1,a2,-35
  8001ee:	0ff5f593          	andi	a1,a1,255
  8001f2:	00140d13          	addi	s10,s0,1
  8001f6:	04b56263          	bltu	a0,a1,80023a <vprintfmt+0xbc>
  8001fa:	058a                	slli	a1,a1,0x2
  8001fc:	95d6                	add	a1,a1,s5
  8001fe:	4194                	lw	a3,0(a1)
  800200:	96d6                	add	a3,a3,s5
  800202:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800204:	70e6                	ld	ra,120(sp)
  800206:	7446                	ld	s0,112(sp)
  800208:	74a6                	ld	s1,104(sp)
  80020a:	7906                	ld	s2,96(sp)
  80020c:	69e6                	ld	s3,88(sp)
  80020e:	6a46                	ld	s4,80(sp)
  800210:	6aa6                	ld	s5,72(sp)
  800212:	6b06                	ld	s6,64(sp)
  800214:	7be2                	ld	s7,56(sp)
  800216:	7c42                	ld	s8,48(sp)
  800218:	7ca2                	ld	s9,40(sp)
  80021a:	7d02                	ld	s10,32(sp)
  80021c:	6de2                	ld	s11,24(sp)
  80021e:	6109                	addi	sp,sp,128
  800220:	8082                	ret
            padc = '0';
  800222:	87b2                	mv	a5,a2
            goto reswitch;
  800224:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800228:	846a                	mv	s0,s10
  80022a:	00140d13          	addi	s10,s0,1
  80022e:	fdd6059b          	addiw	a1,a2,-35
  800232:	0ff5f593          	andi	a1,a1,255
  800236:	fcb572e3          	bgeu	a0,a1,8001fa <vprintfmt+0x7c>
            putch('%', putdat);
  80023a:	85a6                	mv	a1,s1
  80023c:	02500513          	li	a0,37
  800240:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800242:	fff44783          	lbu	a5,-1(s0)
  800246:	8d22                	mv	s10,s0
  800248:	f73788e3          	beq	a5,s3,8001b8 <vprintfmt+0x3a>
  80024c:	ffed4783          	lbu	a5,-2(s10)
  800250:	1d7d                	addi	s10,s10,-1
  800252:	ff379de3          	bne	a5,s3,80024c <vprintfmt+0xce>
  800256:	b78d                	j	8001b8 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  800258:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  80025c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800260:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800262:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800266:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  80026a:	02d86463          	bltu	a6,a3,800292 <vprintfmt+0x114>
                ch = *fmt;
  80026e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  800272:	002c169b          	slliw	a3,s8,0x2
  800276:	0186873b          	addw	a4,a3,s8
  80027a:	0017171b          	slliw	a4,a4,0x1
  80027e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  800280:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  800284:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800286:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  80028a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  80028e:	fed870e3          	bgeu	a6,a3,80026e <vprintfmt+0xf0>
            if (width < 0)
  800292:	f40ddce3          	bgez	s11,8001ea <vprintfmt+0x6c>
                width = precision, precision = -1;
  800296:	8de2                	mv	s11,s8
  800298:	5c7d                	li	s8,-1
  80029a:	bf81                	j	8001ea <vprintfmt+0x6c>
            if (width < 0)
  80029c:	fffdc693          	not	a3,s11
  8002a0:	96fd                	srai	a3,a3,0x3f
  8002a2:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  8002a6:	00144603          	lbu	a2,1(s0)
  8002aa:	2d81                	sext.w	s11,s11
  8002ac:	846a                	mv	s0,s10
            goto reswitch;
  8002ae:	bf35                	j	8001ea <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  8002b0:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002b4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002b8:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002ba:	846a                	mv	s0,s10
            goto process_precision;
  8002bc:	bfd9                	j	800292 <vprintfmt+0x114>
    if (lflag >= 2) {
  8002be:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002c0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002c4:	01174463          	blt	a4,a7,8002cc <vprintfmt+0x14e>
    else if (lflag) {
  8002c8:	1a088e63          	beqz	a7,800484 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  8002cc:	000a3603          	ld	a2,0(s4)
  8002d0:	46c1                	li	a3,16
  8002d2:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002d4:	2781                	sext.w	a5,a5
  8002d6:	876e                	mv	a4,s11
  8002d8:	85a6                	mv	a1,s1
  8002da:	854a                	mv	a0,s2
  8002dc:	e37ff0ef          	jal	ra,800112 <printnum>
            break;
  8002e0:	bde1                	j	8001b8 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  8002e2:	000a2503          	lw	a0,0(s4)
  8002e6:	85a6                	mv	a1,s1
  8002e8:	0a21                	addi	s4,s4,8
  8002ea:	9902                	jalr	s2
            break;
  8002ec:	b5f1                	j	8001b8 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002ee:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002f0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002f4:	01174463          	blt	a4,a7,8002fc <vprintfmt+0x17e>
    else if (lflag) {
  8002f8:	18088163          	beqz	a7,80047a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  8002fc:	000a3603          	ld	a2,0(s4)
  800300:	46a9                	li	a3,10
  800302:	8a2e                	mv	s4,a1
  800304:	bfc1                	j	8002d4 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800306:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80030a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  80030c:	846a                	mv	s0,s10
            goto reswitch;
  80030e:	bdf1                	j	8001ea <vprintfmt+0x6c>
            putch(ch, putdat);
  800310:	85a6                	mv	a1,s1
  800312:	02500513          	li	a0,37
  800316:	9902                	jalr	s2
            break;
  800318:	b545                	j	8001b8 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  80031a:	00144603          	lbu	a2,1(s0)
            lflag ++;
  80031e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  800320:	846a                	mv	s0,s10
            goto reswitch;
  800322:	b5e1                	j	8001ea <vprintfmt+0x6c>
    if (lflag >= 2) {
  800324:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800326:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80032a:	01174463          	blt	a4,a7,800332 <vprintfmt+0x1b4>
    else if (lflag) {
  80032e:	14088163          	beqz	a7,800470 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  800332:	000a3603          	ld	a2,0(s4)
  800336:	46a1                	li	a3,8
  800338:	8a2e                	mv	s4,a1
  80033a:	bf69                	j	8002d4 <vprintfmt+0x156>
            putch('0', putdat);
  80033c:	03000513          	li	a0,48
  800340:	85a6                	mv	a1,s1
  800342:	e03e                	sd	a5,0(sp)
  800344:	9902                	jalr	s2
            putch('x', putdat);
  800346:	85a6                	mv	a1,s1
  800348:	07800513          	li	a0,120
  80034c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80034e:	0a21                	addi	s4,s4,8
            goto number;
  800350:	6782                	ld	a5,0(sp)
  800352:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800354:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  800358:	bfb5                	j	8002d4 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  80035a:	000a3403          	ld	s0,0(s4)
  80035e:	008a0713          	addi	a4,s4,8
  800362:	e03a                	sd	a4,0(sp)
  800364:	14040263          	beqz	s0,8004a8 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  800368:	0fb05763          	blez	s11,800456 <vprintfmt+0x2d8>
  80036c:	02d00693          	li	a3,45
  800370:	0cd79163          	bne	a5,a3,800432 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800374:	00044783          	lbu	a5,0(s0)
  800378:	0007851b          	sext.w	a0,a5
  80037c:	cf85                	beqz	a5,8003b4 <vprintfmt+0x236>
  80037e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  800382:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800386:	000c4563          	bltz	s8,800390 <vprintfmt+0x212>
  80038a:	3c7d                	addiw	s8,s8,-1
  80038c:	036c0263          	beq	s8,s6,8003b0 <vprintfmt+0x232>
                    putch('?', putdat);
  800390:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800392:	0e0c8e63          	beqz	s9,80048e <vprintfmt+0x310>
  800396:	3781                	addiw	a5,a5,-32
  800398:	0ef47b63          	bgeu	s0,a5,80048e <vprintfmt+0x310>
                    putch('?', putdat);
  80039c:	03f00513          	li	a0,63
  8003a0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a2:	000a4783          	lbu	a5,0(s4)
  8003a6:	3dfd                	addiw	s11,s11,-1
  8003a8:	0a05                	addi	s4,s4,1
  8003aa:	0007851b          	sext.w	a0,a5
  8003ae:	ffe1                	bnez	a5,800386 <vprintfmt+0x208>
            for (; width > 0; width --) {
  8003b0:	01b05963          	blez	s11,8003c2 <vprintfmt+0x244>
  8003b4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003b6:	85a6                	mv	a1,s1
  8003b8:	02000513          	li	a0,32
  8003bc:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003be:	fe0d9be3          	bnez	s11,8003b4 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003c2:	6a02                	ld	s4,0(sp)
  8003c4:	bbd5                	j	8001b8 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003c6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003c8:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  8003cc:	01174463          	blt	a4,a7,8003d4 <vprintfmt+0x256>
    else if (lflag) {
  8003d0:	08088d63          	beqz	a7,80046a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  8003d4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003d8:	0a044d63          	bltz	s0,800492 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  8003dc:	8622                	mv	a2,s0
  8003de:	8a66                	mv	s4,s9
  8003e0:	46a9                	li	a3,10
  8003e2:	bdcd                	j	8002d4 <vprintfmt+0x156>
            err = va_arg(ap, int);
  8003e4:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003e8:	4761                	li	a4,24
            err = va_arg(ap, int);
  8003ea:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003ec:	41f7d69b          	sraiw	a3,a5,0x1f
  8003f0:	8fb5                	xor	a5,a5,a3
  8003f2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003f6:	02d74163          	blt	a4,a3,800418 <vprintfmt+0x29a>
  8003fa:	00369793          	slli	a5,a3,0x3
  8003fe:	97de                	add	a5,a5,s7
  800400:	639c                	ld	a5,0(a5)
  800402:	cb99                	beqz	a5,800418 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800404:	86be                	mv	a3,a5
  800406:	00000617          	auipc	a2,0x0
  80040a:	19a60613          	addi	a2,a2,410 # 8005a0 <main+0x84>
  80040e:	85a6                	mv	a1,s1
  800410:	854a                	mv	a0,s2
  800412:	0ce000ef          	jal	ra,8004e0 <printfmt>
  800416:	b34d                	j	8001b8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800418:	00000617          	auipc	a2,0x0
  80041c:	17860613          	addi	a2,a2,376 # 800590 <main+0x74>
  800420:	85a6                	mv	a1,s1
  800422:	854a                	mv	a0,s2
  800424:	0bc000ef          	jal	ra,8004e0 <printfmt>
  800428:	bb41                	j	8001b8 <vprintfmt+0x3a>
                p = "(null)";
  80042a:	00000417          	auipc	s0,0x0
  80042e:	15e40413          	addi	s0,s0,350 # 800588 <main+0x6c>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800432:	85e2                	mv	a1,s8
  800434:	8522                	mv	a0,s0
  800436:	e43e                	sd	a5,8(sp)
  800438:	0c8000ef          	jal	ra,800500 <strnlen>
  80043c:	40ad8dbb          	subw	s11,s11,a0
  800440:	01b05b63          	blez	s11,800456 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  800444:	67a2                	ld	a5,8(sp)
  800446:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  80044a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  80044c:	85a6                	mv	a1,s1
  80044e:	8552                	mv	a0,s4
  800450:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800452:	fe0d9ce3          	bnez	s11,80044a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800456:	00044783          	lbu	a5,0(s0)
  80045a:	00140a13          	addi	s4,s0,1
  80045e:	0007851b          	sext.w	a0,a5
  800462:	d3a5                	beqz	a5,8003c2 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  800464:	05e00413          	li	s0,94
  800468:	bf39                	j	800386 <vprintfmt+0x208>
        return va_arg(*ap, int);
  80046a:	000a2403          	lw	s0,0(s4)
  80046e:	b7ad                	j	8003d8 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  800470:	000a6603          	lwu	a2,0(s4)
  800474:	46a1                	li	a3,8
  800476:	8a2e                	mv	s4,a1
  800478:	bdb1                	j	8002d4 <vprintfmt+0x156>
  80047a:	000a6603          	lwu	a2,0(s4)
  80047e:	46a9                	li	a3,10
  800480:	8a2e                	mv	s4,a1
  800482:	bd89                	j	8002d4 <vprintfmt+0x156>
  800484:	000a6603          	lwu	a2,0(s4)
  800488:	46c1                	li	a3,16
  80048a:	8a2e                	mv	s4,a1
  80048c:	b5a1                	j	8002d4 <vprintfmt+0x156>
                    putch(ch, putdat);
  80048e:	9902                	jalr	s2
  800490:	bf09                	j	8003a2 <vprintfmt+0x224>
                putch('-', putdat);
  800492:	85a6                	mv	a1,s1
  800494:	02d00513          	li	a0,45
  800498:	e03e                	sd	a5,0(sp)
  80049a:	9902                	jalr	s2
                num = -(long long)num;
  80049c:	6782                	ld	a5,0(sp)
  80049e:	8a66                	mv	s4,s9
  8004a0:	40800633          	neg	a2,s0
  8004a4:	46a9                	li	a3,10
  8004a6:	b53d                	j	8002d4 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  8004a8:	03b05163          	blez	s11,8004ca <vprintfmt+0x34c>
  8004ac:	02d00693          	li	a3,45
  8004b0:	f6d79de3          	bne	a5,a3,80042a <vprintfmt+0x2ac>
                p = "(null)";
  8004b4:	00000417          	auipc	s0,0x0
  8004b8:	0d440413          	addi	s0,s0,212 # 800588 <main+0x6c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004bc:	02800793          	li	a5,40
  8004c0:	02800513          	li	a0,40
  8004c4:	00140a13          	addi	s4,s0,1
  8004c8:	bd6d                	j	800382 <vprintfmt+0x204>
  8004ca:	00000a17          	auipc	s4,0x0
  8004ce:	0bfa0a13          	addi	s4,s4,191 # 800589 <main+0x6d>
  8004d2:	02800513          	li	a0,40
  8004d6:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  8004da:	05e00413          	li	s0,94
  8004de:	b565                	j	800386 <vprintfmt+0x208>

00000000008004e0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004e0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004e2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004e6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004e8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ea:	ec06                	sd	ra,24(sp)
  8004ec:	f83a                	sd	a4,48(sp)
  8004ee:	fc3e                	sd	a5,56(sp)
  8004f0:	e0c2                	sd	a6,64(sp)
  8004f2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004f4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004f6:	c89ff0ef          	jal	ra,80017e <vprintfmt>
}
  8004fa:	60e2                	ld	ra,24(sp)
  8004fc:	6161                	addi	sp,sp,80
  8004fe:	8082                	ret

0000000000800500 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800500:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800502:	e589                	bnez	a1,80050c <strnlen+0xc>
  800504:	a811                	j	800518 <strnlen+0x18>
        cnt ++;
  800506:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800508:	00f58863          	beq	a1,a5,800518 <strnlen+0x18>
  80050c:	00f50733          	add	a4,a0,a5
  800510:	00074703          	lbu	a4,0(a4)
  800514:	fb6d                	bnez	a4,800506 <strnlen+0x6>
  800516:	85be                	mv	a1,a5
    }
    return cnt;
}
  800518:	852e                	mv	a0,a1
  80051a:	8082                	ret

000000000080051c <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  80051c:	1141                	addi	sp,sp,-16
    cprintf("Hello world!!.\n");
  80051e:	00000517          	auipc	a0,0x0
  800522:	36a50513          	addi	a0,a0,874 # 800888 <error_string+0xc8>
main(void) {
  800526:	e406                	sd	ra,8(sp)
    cprintf("Hello world!!.\n");
  800528:	b19ff0ef          	jal	ra,800040 <cprintf>
    cprintf("I am process %d.\n", getpid());
  80052c:	bd9ff0ef          	jal	ra,800104 <getpid>
  800530:	85aa                	mv	a1,a0
  800532:	00000517          	auipc	a0,0x0
  800536:	36650513          	addi	a0,a0,870 # 800898 <error_string+0xd8>
  80053a:	b07ff0ef          	jal	ra,800040 <cprintf>
    cprintf("hello pass.\n");
  80053e:	00000517          	auipc	a0,0x0
  800542:	37250513          	addi	a0,a0,882 # 8008b0 <error_string+0xf0>
  800546:	afbff0ef          	jal	ra,800040 <cprintf>
    return 0;
}
  80054a:	60a2                	ld	ra,8(sp)
  80054c:	4501                	li	a0,0
  80054e:	0141                	addi	sp,sp,16
  800550:	8082                	ret
