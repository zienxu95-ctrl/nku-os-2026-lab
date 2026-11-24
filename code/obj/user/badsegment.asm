
obj/__user_badsegment.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	11e000ef          	jal	ra,80013e <umain>
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
  80003a:	53a50513          	addi	a0,a0,1338 # 800570 <main+0x1c>
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
  80005a:	53a50513          	addi	a0,a0,1338 # 800590 <main+0x3c>
  80005e:	044000ef          	jal	ra,8000a2 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	0c4000ef          	jal	ra,800128 <exit>

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
  800070:	090000ef          	jal	ra,800100 <sys_putc>
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
  800096:	120000ef          	jal	ra,8001b6 <vprintfmt>
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
  8000cc:	0ea000ef          	jal	ra,8001b6 <vprintfmt>
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

0000000000800100 <sys_putc>:

int sys_getpid(void) {
    return syscall(SYS_getpid, 0, 0, 0, 0, 0);
}

int sys_putc(int64_t c) {
  800100:	7139                	addi	sp,sp,-64
  800102:	47f9                	li	a5,30
  800104:	e83e                	sd	a5,16(sp)
  800106:	ec2a                	sd	a0,24(sp)
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
    return syscall(SYS_putc, c, 0, 0, 0, 0);
}
  800122:	4532                	lw	a0,12(sp)
  800124:	6121                	addi	sp,sp,64
  800126:	8082                	ret

0000000000800128 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800128:	1141                	addi	sp,sp,-16
  80012a:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80012c:	fadff0ef          	jal	ra,8000d8 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800130:	00000517          	auipc	a0,0x0
  800134:	46850513          	addi	a0,a0,1128 # 800598 <main+0x44>
  800138:	f6bff0ef          	jal	ra,8000a2 <cprintf>
    while (1);
  80013c:	a001                	j	80013c <exit+0x14>

000000000080013e <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80013e:	1141                	addi	sp,sp,-16
  800140:	e406                	sd	ra,8(sp)
    int ret = main();
  800142:	412000ef          	jal	ra,800554 <main>
    exit(ret);
  800146:	fe3ff0ef          	jal	ra,800128 <exit>

000000000080014a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80014a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80014e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800150:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800154:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800156:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80015a:	f022                	sd	s0,32(sp)
  80015c:	ec26                	sd	s1,24(sp)
  80015e:	e84a                	sd	s2,16(sp)
  800160:	f406                	sd	ra,40(sp)
  800162:	e44e                	sd	s3,8(sp)
  800164:	84aa                	mv	s1,a0
  800166:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800168:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80016c:	2a01                	sext.w	s4,s4
    if (num >= base) {
  80016e:	03067e63          	bgeu	a2,a6,8001aa <printnum+0x60>
  800172:	89be                	mv	s3,a5
        while (-- width > 0)
  800174:	00805763          	blez	s0,800182 <printnum+0x38>
  800178:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80017a:	85ca                	mv	a1,s2
  80017c:	854e                	mv	a0,s3
  80017e:	9482                	jalr	s1
        while (-- width > 0)
  800180:	fc65                	bnez	s0,800178 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800182:	1a02                	slli	s4,s4,0x20
  800184:	00000797          	auipc	a5,0x0
  800188:	42c78793          	addi	a5,a5,1068 # 8005b0 <main+0x5c>
  80018c:	020a5a13          	srli	s4,s4,0x20
  800190:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800192:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800194:	000a4503          	lbu	a0,0(s4)
}
  800198:	70a2                	ld	ra,40(sp)
  80019a:	69a2                	ld	s3,8(sp)
  80019c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80019e:	85ca                	mv	a1,s2
  8001a0:	87a6                	mv	a5,s1
}
  8001a2:	6942                	ld	s2,16(sp)
  8001a4:	64e2                	ld	s1,24(sp)
  8001a6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001a8:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001aa:	03065633          	divu	a2,a2,a6
  8001ae:	8722                	mv	a4,s0
  8001b0:	f9bff0ef          	jal	ra,80014a <printnum>
  8001b4:	b7f9                	j	800182 <printnum+0x38>

00000000008001b6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001b6:	7119                	addi	sp,sp,-128
  8001b8:	f4a6                	sd	s1,104(sp)
  8001ba:	f0ca                	sd	s2,96(sp)
  8001bc:	ecce                	sd	s3,88(sp)
  8001be:	e8d2                	sd	s4,80(sp)
  8001c0:	e4d6                	sd	s5,72(sp)
  8001c2:	e0da                	sd	s6,64(sp)
  8001c4:	fc5e                	sd	s7,56(sp)
  8001c6:	f06a                	sd	s10,32(sp)
  8001c8:	fc86                	sd	ra,120(sp)
  8001ca:	f8a2                	sd	s0,112(sp)
  8001cc:	f862                	sd	s8,48(sp)
  8001ce:	f466                	sd	s9,40(sp)
  8001d0:	ec6e                	sd	s11,24(sp)
  8001d2:	892a                	mv	s2,a0
  8001d4:	84ae                	mv	s1,a1
  8001d6:	8d32                	mv	s10,a2
  8001d8:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001da:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001de:	5b7d                	li	s6,-1
  8001e0:	00000a97          	auipc	s5,0x0
  8001e4:	404a8a93          	addi	s5,s5,1028 # 8005e4 <main+0x90>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001e8:	00000b97          	auipc	s7,0x0
  8001ec:	618b8b93          	addi	s7,s7,1560 # 800800 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f0:	000d4503          	lbu	a0,0(s10)
  8001f4:	001d0413          	addi	s0,s10,1
  8001f8:	01350a63          	beq	a0,s3,80020c <vprintfmt+0x56>
            if (ch == '\0') {
  8001fc:	c121                	beqz	a0,80023c <vprintfmt+0x86>
            putch(ch, putdat);
  8001fe:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800200:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800202:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800204:	fff44503          	lbu	a0,-1(s0)
  800208:	ff351ae3          	bne	a0,s3,8001fc <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  80020c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800210:	02000793          	li	a5,32
        lflag = altflag = 0;
  800214:	4c81                	li	s9,0
  800216:	4881                	li	a7,0
        width = precision = -1;
  800218:	5c7d                	li	s8,-1
  80021a:	5dfd                	li	s11,-1
  80021c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800220:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  800222:	fdd6059b          	addiw	a1,a2,-35
  800226:	0ff5f593          	andi	a1,a1,255
  80022a:	00140d13          	addi	s10,s0,1
  80022e:	04b56263          	bltu	a0,a1,800272 <vprintfmt+0xbc>
  800232:	058a                	slli	a1,a1,0x2
  800234:	95d6                	add	a1,a1,s5
  800236:	4194                	lw	a3,0(a1)
  800238:	96d6                	add	a3,a3,s5
  80023a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80023c:	70e6                	ld	ra,120(sp)
  80023e:	7446                	ld	s0,112(sp)
  800240:	74a6                	ld	s1,104(sp)
  800242:	7906                	ld	s2,96(sp)
  800244:	69e6                	ld	s3,88(sp)
  800246:	6a46                	ld	s4,80(sp)
  800248:	6aa6                	ld	s5,72(sp)
  80024a:	6b06                	ld	s6,64(sp)
  80024c:	7be2                	ld	s7,56(sp)
  80024e:	7c42                	ld	s8,48(sp)
  800250:	7ca2                	ld	s9,40(sp)
  800252:	7d02                	ld	s10,32(sp)
  800254:	6de2                	ld	s11,24(sp)
  800256:	6109                	addi	sp,sp,128
  800258:	8082                	ret
            padc = '0';
  80025a:	87b2                	mv	a5,a2
            goto reswitch;
  80025c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800260:	846a                	mv	s0,s10
  800262:	00140d13          	addi	s10,s0,1
  800266:	fdd6059b          	addiw	a1,a2,-35
  80026a:	0ff5f593          	andi	a1,a1,255
  80026e:	fcb572e3          	bgeu	a0,a1,800232 <vprintfmt+0x7c>
            putch('%', putdat);
  800272:	85a6                	mv	a1,s1
  800274:	02500513          	li	a0,37
  800278:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80027a:	fff44783          	lbu	a5,-1(s0)
  80027e:	8d22                	mv	s10,s0
  800280:	f73788e3          	beq	a5,s3,8001f0 <vprintfmt+0x3a>
  800284:	ffed4783          	lbu	a5,-2(s10)
  800288:	1d7d                	addi	s10,s10,-1
  80028a:	ff379de3          	bne	a5,s3,800284 <vprintfmt+0xce>
  80028e:	b78d                	j	8001f0 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  800290:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  800294:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800298:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80029a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80029e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002a2:	02d86463          	bltu	a6,a3,8002ca <vprintfmt+0x114>
                ch = *fmt;
  8002a6:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002aa:	002c169b          	slliw	a3,s8,0x2
  8002ae:	0186873b          	addw	a4,a3,s8
  8002b2:	0017171b          	slliw	a4,a4,0x1
  8002b6:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002b8:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002bc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002be:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002c2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002c6:	fed870e3          	bgeu	a6,a3,8002a6 <vprintfmt+0xf0>
            if (width < 0)
  8002ca:	f40ddce3          	bgez	s11,800222 <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002ce:	8de2                	mv	s11,s8
  8002d0:	5c7d                	li	s8,-1
  8002d2:	bf81                	j	800222 <vprintfmt+0x6c>
            if (width < 0)
  8002d4:	fffdc693          	not	a3,s11
  8002d8:	96fd                	srai	a3,a3,0x3f
  8002da:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  8002de:	00144603          	lbu	a2,1(s0)
  8002e2:	2d81                	sext.w	s11,s11
  8002e4:	846a                	mv	s0,s10
            goto reswitch;
  8002e6:	bf35                	j	800222 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  8002e8:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002ec:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002f0:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002f2:	846a                	mv	s0,s10
            goto process_precision;
  8002f4:	bfd9                	j	8002ca <vprintfmt+0x114>
    if (lflag >= 2) {
  8002f6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002f8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002fc:	01174463          	blt	a4,a7,800304 <vprintfmt+0x14e>
    else if (lflag) {
  800300:	1a088e63          	beqz	a7,8004bc <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  800304:	000a3603          	ld	a2,0(s4)
  800308:	46c1                	li	a3,16
  80030a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  80030c:	2781                	sext.w	a5,a5
  80030e:	876e                	mv	a4,s11
  800310:	85a6                	mv	a1,s1
  800312:	854a                	mv	a0,s2
  800314:	e37ff0ef          	jal	ra,80014a <printnum>
            break;
  800318:	bde1                	j	8001f0 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  80031a:	000a2503          	lw	a0,0(s4)
  80031e:	85a6                	mv	a1,s1
  800320:	0a21                	addi	s4,s4,8
  800322:	9902                	jalr	s2
            break;
  800324:	b5f1                	j	8001f0 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800326:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800328:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80032c:	01174463          	blt	a4,a7,800334 <vprintfmt+0x17e>
    else if (lflag) {
  800330:	18088163          	beqz	a7,8004b2 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  800334:	000a3603          	ld	a2,0(s4)
  800338:	46a9                	li	a3,10
  80033a:	8a2e                	mv	s4,a1
  80033c:	bfc1                	j	80030c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  80033e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800342:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  800344:	846a                	mv	s0,s10
            goto reswitch;
  800346:	bdf1                	j	800222 <vprintfmt+0x6c>
            putch(ch, putdat);
  800348:	85a6                	mv	a1,s1
  80034a:	02500513          	li	a0,37
  80034e:	9902                	jalr	s2
            break;
  800350:	b545                	j	8001f0 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800352:	00144603          	lbu	a2,1(s0)
            lflag ++;
  800356:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  800358:	846a                	mv	s0,s10
            goto reswitch;
  80035a:	b5e1                	j	800222 <vprintfmt+0x6c>
    if (lflag >= 2) {
  80035c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80035e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800362:	01174463          	blt	a4,a7,80036a <vprintfmt+0x1b4>
    else if (lflag) {
  800366:	14088163          	beqz	a7,8004a8 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  80036a:	000a3603          	ld	a2,0(s4)
  80036e:	46a1                	li	a3,8
  800370:	8a2e                	mv	s4,a1
  800372:	bf69                	j	80030c <vprintfmt+0x156>
            putch('0', putdat);
  800374:	03000513          	li	a0,48
  800378:	85a6                	mv	a1,s1
  80037a:	e03e                	sd	a5,0(sp)
  80037c:	9902                	jalr	s2
            putch('x', putdat);
  80037e:	85a6                	mv	a1,s1
  800380:	07800513          	li	a0,120
  800384:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800386:	0a21                	addi	s4,s4,8
            goto number;
  800388:	6782                	ld	a5,0(sp)
  80038a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80038c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  800390:	bfb5                	j	80030c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  800392:	000a3403          	ld	s0,0(s4)
  800396:	008a0713          	addi	a4,s4,8
  80039a:	e03a                	sd	a4,0(sp)
  80039c:	14040263          	beqz	s0,8004e0 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003a0:	0fb05763          	blez	s11,80048e <vprintfmt+0x2d8>
  8003a4:	02d00693          	li	a3,45
  8003a8:	0cd79163          	bne	a5,a3,80046a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ac:	00044783          	lbu	a5,0(s0)
  8003b0:	0007851b          	sext.w	a0,a5
  8003b4:	cf85                	beqz	a5,8003ec <vprintfmt+0x236>
  8003b6:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ba:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003be:	000c4563          	bltz	s8,8003c8 <vprintfmt+0x212>
  8003c2:	3c7d                	addiw	s8,s8,-1
  8003c4:	036c0263          	beq	s8,s6,8003e8 <vprintfmt+0x232>
                    putch('?', putdat);
  8003c8:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ca:	0e0c8e63          	beqz	s9,8004c6 <vprintfmt+0x310>
  8003ce:	3781                	addiw	a5,a5,-32
  8003d0:	0ef47b63          	bgeu	s0,a5,8004c6 <vprintfmt+0x310>
                    putch('?', putdat);
  8003d4:	03f00513          	li	a0,63
  8003d8:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003da:	000a4783          	lbu	a5,0(s4)
  8003de:	3dfd                	addiw	s11,s11,-1
  8003e0:	0a05                	addi	s4,s4,1
  8003e2:	0007851b          	sext.w	a0,a5
  8003e6:	ffe1                	bnez	a5,8003be <vprintfmt+0x208>
            for (; width > 0; width --) {
  8003e8:	01b05963          	blez	s11,8003fa <vprintfmt+0x244>
  8003ec:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003ee:	85a6                	mv	a1,s1
  8003f0:	02000513          	li	a0,32
  8003f4:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003f6:	fe0d9be3          	bnez	s11,8003ec <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003fa:	6a02                	ld	s4,0(sp)
  8003fc:	bbd5                	j	8001f0 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003fe:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800400:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  800404:	01174463          	blt	a4,a7,80040c <vprintfmt+0x256>
    else if (lflag) {
  800408:	08088d63          	beqz	a7,8004a2 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  80040c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800410:	0a044d63          	bltz	s0,8004ca <vprintfmt+0x314>
            num = getint(&ap, lflag);
  800414:	8622                	mv	a2,s0
  800416:	8a66                	mv	s4,s9
  800418:	46a9                	li	a3,10
  80041a:	bdcd                	j	80030c <vprintfmt+0x156>
            err = va_arg(ap, int);
  80041c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800420:	4761                	li	a4,24
            err = va_arg(ap, int);
  800422:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800424:	41f7d69b          	sraiw	a3,a5,0x1f
  800428:	8fb5                	xor	a5,a5,a3
  80042a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80042e:	02d74163          	blt	a4,a3,800450 <vprintfmt+0x29a>
  800432:	00369793          	slli	a5,a3,0x3
  800436:	97de                	add	a5,a5,s7
  800438:	639c                	ld	a5,0(a5)
  80043a:	cb99                	beqz	a5,800450 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  80043c:	86be                	mv	a3,a5
  80043e:	00000617          	auipc	a2,0x0
  800442:	1a260613          	addi	a2,a2,418 # 8005e0 <main+0x8c>
  800446:	85a6                	mv	a1,s1
  800448:	854a                	mv	a0,s2
  80044a:	0ce000ef          	jal	ra,800518 <printfmt>
  80044e:	b34d                	j	8001f0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800450:	00000617          	auipc	a2,0x0
  800454:	18060613          	addi	a2,a2,384 # 8005d0 <main+0x7c>
  800458:	85a6                	mv	a1,s1
  80045a:	854a                	mv	a0,s2
  80045c:	0bc000ef          	jal	ra,800518 <printfmt>
  800460:	bb41                	j	8001f0 <vprintfmt+0x3a>
                p = "(null)";
  800462:	00000417          	auipc	s0,0x0
  800466:	16640413          	addi	s0,s0,358 # 8005c8 <main+0x74>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80046a:	85e2                	mv	a1,s8
  80046c:	8522                	mv	a0,s0
  80046e:	e43e                	sd	a5,8(sp)
  800470:	0c8000ef          	jal	ra,800538 <strnlen>
  800474:	40ad8dbb          	subw	s11,s11,a0
  800478:	01b05b63          	blez	s11,80048e <vprintfmt+0x2d8>
                    putch(padc, putdat);
  80047c:	67a2                	ld	a5,8(sp)
  80047e:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800482:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800484:	85a6                	mv	a1,s1
  800486:	8552                	mv	a0,s4
  800488:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80048a:	fe0d9ce3          	bnez	s11,800482 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80048e:	00044783          	lbu	a5,0(s0)
  800492:	00140a13          	addi	s4,s0,1
  800496:	0007851b          	sext.w	a0,a5
  80049a:	d3a5                	beqz	a5,8003fa <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  80049c:	05e00413          	li	s0,94
  8004a0:	bf39                	j	8003be <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004a2:	000a2403          	lw	s0,0(s4)
  8004a6:	b7ad                	j	800410 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  8004a8:	000a6603          	lwu	a2,0(s4)
  8004ac:	46a1                	li	a3,8
  8004ae:	8a2e                	mv	s4,a1
  8004b0:	bdb1                	j	80030c <vprintfmt+0x156>
  8004b2:	000a6603          	lwu	a2,0(s4)
  8004b6:	46a9                	li	a3,10
  8004b8:	8a2e                	mv	s4,a1
  8004ba:	bd89                	j	80030c <vprintfmt+0x156>
  8004bc:	000a6603          	lwu	a2,0(s4)
  8004c0:	46c1                	li	a3,16
  8004c2:	8a2e                	mv	s4,a1
  8004c4:	b5a1                	j	80030c <vprintfmt+0x156>
                    putch(ch, putdat);
  8004c6:	9902                	jalr	s2
  8004c8:	bf09                	j	8003da <vprintfmt+0x224>
                putch('-', putdat);
  8004ca:	85a6                	mv	a1,s1
  8004cc:	02d00513          	li	a0,45
  8004d0:	e03e                	sd	a5,0(sp)
  8004d2:	9902                	jalr	s2
                num = -(long long)num;
  8004d4:	6782                	ld	a5,0(sp)
  8004d6:	8a66                	mv	s4,s9
  8004d8:	40800633          	neg	a2,s0
  8004dc:	46a9                	li	a3,10
  8004de:	b53d                	j	80030c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  8004e0:	03b05163          	blez	s11,800502 <vprintfmt+0x34c>
  8004e4:	02d00693          	li	a3,45
  8004e8:	f6d79de3          	bne	a5,a3,800462 <vprintfmt+0x2ac>
                p = "(null)";
  8004ec:	00000417          	auipc	s0,0x0
  8004f0:	0dc40413          	addi	s0,s0,220 # 8005c8 <main+0x74>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004f4:	02800793          	li	a5,40
  8004f8:	02800513          	li	a0,40
  8004fc:	00140a13          	addi	s4,s0,1
  800500:	bd6d                	j	8003ba <vprintfmt+0x204>
  800502:	00000a17          	auipc	s4,0x0
  800506:	0c7a0a13          	addi	s4,s4,199 # 8005c9 <main+0x75>
  80050a:	02800513          	li	a0,40
  80050e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800512:	05e00413          	li	s0,94
  800516:	b565                	j	8003be <vprintfmt+0x208>

0000000000800518 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800518:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80051a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80051e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800520:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800522:	ec06                	sd	ra,24(sp)
  800524:	f83a                	sd	a4,48(sp)
  800526:	fc3e                	sd	a5,56(sp)
  800528:	e0c2                	sd	a6,64(sp)
  80052a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80052c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80052e:	c89ff0ef          	jal	ra,8001b6 <vprintfmt>
}
  800532:	60e2                	ld	ra,24(sp)
  800534:	6161                	addi	sp,sp,80
  800536:	8082                	ret

0000000000800538 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800538:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80053a:	e589                	bnez	a1,800544 <strnlen+0xc>
  80053c:	a811                	j	800550 <strnlen+0x18>
        cnt ++;
  80053e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800540:	00f58863          	beq	a1,a5,800550 <strnlen+0x18>
  800544:	00f50733          	add	a4,a0,a5
  800548:	00074703          	lbu	a4,0(a4)
  80054c:	fb6d                	bnez	a4,80053e <strnlen+0x6>
  80054e:	85be                	mv	a1,a5
    }
    return cnt;
}
  800550:	852e                	mv	a0,a1
  800552:	8082                	ret

0000000000800554 <main>:
#include <ulib.h>

/* try to load the kernel's TSS selector into the DS register */

int
main(void) {
  800554:	1141                	addi	sp,sp,-16
	// There is no such thing as TSS in RISC-V
    // asm volatile("movw $0x28,%ax; movw %ax,%ds");
    panic("FAIL: T.T\n");
  800556:	00000617          	auipc	a2,0x0
  80055a:	37260613          	addi	a2,a2,882 # 8008c8 <error_string+0xc8>
  80055e:	45a9                	li	a1,10
  800560:	00000517          	auipc	a0,0x0
  800564:	37850513          	addi	a0,a0,888 # 8008d8 <error_string+0xd8>
main(void) {
  800568:	e406                	sd	ra,8(sp)
    panic("FAIL: T.T\n");
  80056a:	abdff0ef          	jal	ra,800026 <__panic>
