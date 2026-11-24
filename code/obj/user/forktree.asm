
obj/__user_forktree.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	13a000ef          	jal	ra,80015a <umain>
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
  80002e:	0e8000ef          	jal	ra,800116 <sys_putc>
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
  80006a:	182000ef          	jal	ra,8001ec <vprintfmt>
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

000000000080009e <sys_fork>:

int sys_fork(void) {
  80009e:	7139                	addi	sp,sp,-64
  8000a0:	4789                	li	a5,2
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
    return syscall(SYS_fork, 0, 0, 0, 0, 0);
}
  8000c0:	4532                	lw	a0,12(sp)
  8000c2:	6121                	addi	sp,sp,64
  8000c4:	8082                	ret

00000000008000c6 <sys_yield>:

int sys_wait(int64_t pid, int *store) {
    return syscall(SYS_wait, pid, (uintptr_t)store, 0, 0, 0);
}

int sys_yield(void) {
  8000c6:	7139                	addi	sp,sp,-64
  8000c8:	47a9                	li	a5,10
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
    return syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  8000e8:	4532                	lw	a0,12(sp)
  8000ea:	6121                	addi	sp,sp,64
  8000ec:	8082                	ret

00000000008000ee <sys_getpid>:

int sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid, 0, 0, 0, 0);
}

int sys_getpid(void) {
  8000ee:	7139                	addi	sp,sp,-64
  8000f0:	47c9                	li	a5,18
  8000f2:	e83e                	sd	a5,16(sp)
  8000f4:	ec02                	sd	zero,24(sp)
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
    return syscall(SYS_getpid, 0, 0, 0, 0, 0);
}
  800110:	4532                	lw	a0,12(sp)
  800112:	6121                	addi	sp,sp,64
  800114:	8082                	ret

0000000000800116 <sys_putc>:

int sys_putc(int64_t c) {
  800116:	7139                	addi	sp,sp,-64
  800118:	47f9                	li	a5,30
  80011a:	e83e                	sd	a5,16(sp)
  80011c:	ec2a                	sd	a0,24(sp)
  80011e:	f002                	sd	zero,32(sp)
  800120:	f402                	sd	zero,40(sp)
  800122:	f802                	sd	zero,48(sp)
  800124:	fc02                	sd	zero,56(sp)
    asm volatile (
  800126:	6542                	ld	a0,16(sp)
  800128:	65e2                	ld	a1,24(sp)
  80012a:	7602                	ld	a2,32(sp)
  80012c:	76a2                	ld	a3,40(sp)
  80012e:	7742                	ld	a4,48(sp)
  800130:	77e2                	ld	a5,56(sp)
  800132:	00000073          	ecall
  800136:	c62a                	sw	a0,12(sp)
    return syscall(SYS_putc, c, 0, 0, 0, 0);
}
  800138:	4532                	lw	a0,12(sp)
  80013a:	6121                	addi	sp,sp,64
  80013c:	8082                	ret

000000000080013e <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80013e:	1141                	addi	sp,sp,-16
  800140:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800142:	f35ff0ef          	jal	ra,800076 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800146:	00000517          	auipc	a0,0x0
  80014a:	57250513          	addi	a0,a0,1394 # 8006b8 <main+0x1e>
  80014e:	ef3ff0ef          	jal	ra,800040 <cprintf>
    while (1);
  800152:	a001                	j	800152 <exit+0x14>

0000000000800154 <fork>:
}

int
fork(void) {
    return sys_fork();
  800154:	b7a9                	j	80009e <sys_fork>

0000000000800156 <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  800156:	bf85                	j	8000c6 <sys_yield>

0000000000800158 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  800158:	bf59                	j	8000ee <sys_getpid>

000000000080015a <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80015a:	1141                	addi	sp,sp,-16
  80015c:	e406                	sd	ra,8(sp)
    int ret = main();
  80015e:	53c000ef          	jal	ra,80069a <main>
    exit(ret);
  800162:	fddff0ef          	jal	ra,80013e <exit>

0000000000800166 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800166:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80016a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80016c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800170:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800172:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800176:	f022                	sd	s0,32(sp)
  800178:	ec26                	sd	s1,24(sp)
  80017a:	e84a                	sd	s2,16(sp)
  80017c:	f406                	sd	ra,40(sp)
  80017e:	e44e                	sd	s3,8(sp)
  800180:	84aa                	mv	s1,a0
  800182:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800184:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800188:	2a01                	sext.w	s4,s4
    if (num >= base) {
  80018a:	03067e63          	bgeu	a2,a6,8001c6 <printnum+0x60>
  80018e:	89be                	mv	s3,a5
        while (-- width > 0)
  800190:	00805763          	blez	s0,80019e <printnum+0x38>
  800194:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800196:	85ca                	mv	a1,s2
  800198:	854e                	mv	a0,s3
  80019a:	9482                	jalr	s1
        while (-- width > 0)
  80019c:	fc65                	bnez	s0,800194 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80019e:	1a02                	slli	s4,s4,0x20
  8001a0:	00000797          	auipc	a5,0x0
  8001a4:	53078793          	addi	a5,a5,1328 # 8006d0 <main+0x36>
  8001a8:	020a5a13          	srli	s4,s4,0x20
  8001ac:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001ae:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b0:	000a4503          	lbu	a0,0(s4)
}
  8001b4:	70a2                	ld	ra,40(sp)
  8001b6:	69a2                	ld	s3,8(sp)
  8001b8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ba:	85ca                	mv	a1,s2
  8001bc:	87a6                	mv	a5,s1
}
  8001be:	6942                	ld	s2,16(sp)
  8001c0:	64e2                	ld	s1,24(sp)
  8001c2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001c4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001c6:	03065633          	divu	a2,a2,a6
  8001ca:	8722                	mv	a4,s0
  8001cc:	f9bff0ef          	jal	ra,800166 <printnum>
  8001d0:	b7f9                	j	80019e <printnum+0x38>

00000000008001d2 <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
  8001d2:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
  8001d4:	6198                	ld	a4,0(a1)
  8001d6:	6594                	ld	a3,8(a1)
    b->cnt ++;
  8001d8:	2785                	addiw	a5,a5,1
  8001da:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
  8001dc:	00d77763          	bgeu	a4,a3,8001ea <sprintputch+0x18>
        *b->buf ++ = ch;
  8001e0:	00170793          	addi	a5,a4,1
  8001e4:	e19c                	sd	a5,0(a1)
  8001e6:	00a70023          	sb	a0,0(a4)
    }
}
  8001ea:	8082                	ret

00000000008001ec <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001ec:	7119                	addi	sp,sp,-128
  8001ee:	f4a6                	sd	s1,104(sp)
  8001f0:	f0ca                	sd	s2,96(sp)
  8001f2:	ecce                	sd	s3,88(sp)
  8001f4:	e8d2                	sd	s4,80(sp)
  8001f6:	e4d6                	sd	s5,72(sp)
  8001f8:	e0da                	sd	s6,64(sp)
  8001fa:	fc5e                	sd	s7,56(sp)
  8001fc:	f06a                	sd	s10,32(sp)
  8001fe:	fc86                	sd	ra,120(sp)
  800200:	f8a2                	sd	s0,112(sp)
  800202:	f862                	sd	s8,48(sp)
  800204:	f466                	sd	s9,40(sp)
  800206:	ec6e                	sd	s11,24(sp)
  800208:	892a                	mv	s2,a0
  80020a:	84ae                	mv	s1,a1
  80020c:	8d32                	mv	s10,a2
  80020e:	8a36                	mv	s4,a3
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800210:	02500993          	li	s3,37
        width = precision = -1;
  800214:	5b7d                	li	s6,-1
  800216:	00000a97          	auipc	s5,0x0
  80021a:	4eea8a93          	addi	s5,s5,1262 # 800704 <main+0x6a>
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80021e:	00000b97          	auipc	s7,0x0
  800222:	702b8b93          	addi	s7,s7,1794 # 800920 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800226:	000d4503          	lbu	a0,0(s10)
  80022a:	001d0413          	addi	s0,s10,1
  80022e:	01350a63          	beq	a0,s3,800242 <vprintfmt+0x56>
            if (ch == '\0') {
  800232:	c121                	beqz	a0,800272 <vprintfmt+0x86>
            putch(ch, putdat);
  800234:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800236:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800238:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80023a:	fff44503          	lbu	a0,-1(s0)
  80023e:	ff351ae3          	bne	a0,s3,800232 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  800242:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800246:	02000793          	li	a5,32
        lflag = altflag = 0;
  80024a:	4c81                	li	s9,0
  80024c:	4881                	li	a7,0
        width = precision = -1;
  80024e:	5c7d                	li	s8,-1
  800250:	5dfd                	li	s11,-1
  800252:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800256:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  800258:	fdd6059b          	addiw	a1,a2,-35
  80025c:	0ff5f593          	andi	a1,a1,255
  800260:	00140d13          	addi	s10,s0,1
  800264:	04b56263          	bltu	a0,a1,8002a8 <vprintfmt+0xbc>
  800268:	058a                	slli	a1,a1,0x2
  80026a:	95d6                	add	a1,a1,s5
  80026c:	4194                	lw	a3,0(a1)
  80026e:	96d6                	add	a3,a3,s5
  800270:	8682                	jr	a3
}
  800272:	70e6                	ld	ra,120(sp)
  800274:	7446                	ld	s0,112(sp)
  800276:	74a6                	ld	s1,104(sp)
  800278:	7906                	ld	s2,96(sp)
  80027a:	69e6                	ld	s3,88(sp)
  80027c:	6a46                	ld	s4,80(sp)
  80027e:	6aa6                	ld	s5,72(sp)
  800280:	6b06                	ld	s6,64(sp)
  800282:	7be2                	ld	s7,56(sp)
  800284:	7c42                	ld	s8,48(sp)
  800286:	7ca2                	ld	s9,40(sp)
  800288:	7d02                	ld	s10,32(sp)
  80028a:	6de2                	ld	s11,24(sp)
  80028c:	6109                	addi	sp,sp,128
  80028e:	8082                	ret
            padc = '0';
  800290:	87b2                	mv	a5,a2
            goto reswitch;
  800292:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800296:	846a                	mv	s0,s10
  800298:	00140d13          	addi	s10,s0,1
  80029c:	fdd6059b          	addiw	a1,a2,-35
  8002a0:	0ff5f593          	andi	a1,a1,255
  8002a4:	fcb572e3          	bgeu	a0,a1,800268 <vprintfmt+0x7c>
            putch('%', putdat);
  8002a8:	85a6                	mv	a1,s1
  8002aa:	02500513          	li	a0,37
  8002ae:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8002b0:	fff44783          	lbu	a5,-1(s0)
  8002b4:	8d22                	mv	s10,s0
  8002b6:	f73788e3          	beq	a5,s3,800226 <vprintfmt+0x3a>
  8002ba:	ffed4783          	lbu	a5,-2(s10)
  8002be:	1d7d                	addi	s10,s10,-1
  8002c0:	ff379de3          	bne	a5,s3,8002ba <vprintfmt+0xce>
  8002c4:	b78d                	j	800226 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  8002c6:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  8002ca:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002ce:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002d0:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002d4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002d8:	02d86463          	bltu	a6,a3,800300 <vprintfmt+0x114>
                ch = *fmt;
  8002dc:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002e0:	002c169b          	slliw	a3,s8,0x2
  8002e4:	0186873b          	addw	a4,a3,s8
  8002e8:	0017171b          	slliw	a4,a4,0x1
  8002ec:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002ee:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002f2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002f4:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002f8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002fc:	fed870e3          	bgeu	a6,a3,8002dc <vprintfmt+0xf0>
            if (width < 0)
  800300:	f40ddce3          	bgez	s11,800258 <vprintfmt+0x6c>
                width = precision, precision = -1;
  800304:	8de2                	mv	s11,s8
  800306:	5c7d                	li	s8,-1
  800308:	bf81                	j	800258 <vprintfmt+0x6c>
            if (width < 0)
  80030a:	fffdc693          	not	a3,s11
  80030e:	96fd                	srai	a3,a3,0x3f
  800310:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  800314:	00144603          	lbu	a2,1(s0)
  800318:	2d81                	sext.w	s11,s11
  80031a:	846a                	mv	s0,s10
            goto reswitch;
  80031c:	bf35                	j	800258 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  80031e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800322:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800326:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  800328:	846a                	mv	s0,s10
            goto process_precision;
  80032a:	bfd9                	j	800300 <vprintfmt+0x114>
    if (lflag >= 2) {
  80032c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80032e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800332:	01174463          	blt	a4,a7,80033a <vprintfmt+0x14e>
    else if (lflag) {
  800336:	1a088e63          	beqz	a7,8004f2 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  80033a:	000a3603          	ld	a2,0(s4)
  80033e:	46c1                	li	a3,16
  800340:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800342:	2781                	sext.w	a5,a5
  800344:	876e                	mv	a4,s11
  800346:	85a6                	mv	a1,s1
  800348:	854a                	mv	a0,s2
  80034a:	e1dff0ef          	jal	ra,800166 <printnum>
            break;
  80034e:	bde1                	j	800226 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  800350:	000a2503          	lw	a0,0(s4)
  800354:	85a6                	mv	a1,s1
  800356:	0a21                	addi	s4,s4,8
  800358:	9902                	jalr	s2
            break;
  80035a:	b5f1                	j	800226 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80035c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80035e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800362:	01174463          	blt	a4,a7,80036a <vprintfmt+0x17e>
    else if (lflag) {
  800366:	18088163          	beqz	a7,8004e8 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  80036a:	000a3603          	ld	a2,0(s4)
  80036e:	46a9                	li	a3,10
  800370:	8a2e                	mv	s4,a1
  800372:	bfc1                	j	800342 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800374:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800378:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  80037a:	846a                	mv	s0,s10
            goto reswitch;
  80037c:	bdf1                	j	800258 <vprintfmt+0x6c>
            putch(ch, putdat);
  80037e:	85a6                	mv	a1,s1
  800380:	02500513          	li	a0,37
  800384:	9902                	jalr	s2
            break;
  800386:	b545                	j	800226 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800388:	00144603          	lbu	a2,1(s0)
            lflag ++;
  80038c:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  80038e:	846a                	mv	s0,s10
            goto reswitch;
  800390:	b5e1                	j	800258 <vprintfmt+0x6c>
    if (lflag >= 2) {
  800392:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800394:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800398:	01174463          	blt	a4,a7,8003a0 <vprintfmt+0x1b4>
    else if (lflag) {
  80039c:	14088163          	beqz	a7,8004de <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  8003a0:	000a3603          	ld	a2,0(s4)
  8003a4:	46a1                	li	a3,8
  8003a6:	8a2e                	mv	s4,a1
  8003a8:	bf69                	j	800342 <vprintfmt+0x156>
            putch('0', putdat);
  8003aa:	03000513          	li	a0,48
  8003ae:	85a6                	mv	a1,s1
  8003b0:	e03e                	sd	a5,0(sp)
  8003b2:	9902                	jalr	s2
            putch('x', putdat);
  8003b4:	85a6                	mv	a1,s1
  8003b6:	07800513          	li	a0,120
  8003ba:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003bc:	0a21                	addi	s4,s4,8
            goto number;
  8003be:	6782                	ld	a5,0(sp)
  8003c0:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003c2:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  8003c6:	bfb5                	j	800342 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003c8:	000a3403          	ld	s0,0(s4)
  8003cc:	008a0713          	addi	a4,s4,8
  8003d0:	e03a                	sd	a4,0(sp)
  8003d2:	14040263          	beqz	s0,800516 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003d6:	0fb05763          	blez	s11,8004c4 <vprintfmt+0x2d8>
  8003da:	02d00693          	li	a3,45
  8003de:	0cd79163          	bne	a5,a3,8004a0 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003e2:	00044783          	lbu	a5,0(s0)
  8003e6:	0007851b          	sext.w	a0,a5
  8003ea:	cf85                	beqz	a5,800422 <vprintfmt+0x236>
  8003ec:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003f0:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003f4:	000c4563          	bltz	s8,8003fe <vprintfmt+0x212>
  8003f8:	3c7d                	addiw	s8,s8,-1
  8003fa:	036c0263          	beq	s8,s6,80041e <vprintfmt+0x232>
                    putch('?', putdat);
  8003fe:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800400:	0e0c8e63          	beqz	s9,8004fc <vprintfmt+0x310>
  800404:	3781                	addiw	a5,a5,-32
  800406:	0ef47b63          	bgeu	s0,a5,8004fc <vprintfmt+0x310>
                    putch('?', putdat);
  80040a:	03f00513          	li	a0,63
  80040e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800410:	000a4783          	lbu	a5,0(s4)
  800414:	3dfd                	addiw	s11,s11,-1
  800416:	0a05                	addi	s4,s4,1
  800418:	0007851b          	sext.w	a0,a5
  80041c:	ffe1                	bnez	a5,8003f4 <vprintfmt+0x208>
            for (; width > 0; width --) {
  80041e:	01b05963          	blez	s11,800430 <vprintfmt+0x244>
  800422:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800424:	85a6                	mv	a1,s1
  800426:	02000513          	li	a0,32
  80042a:	9902                	jalr	s2
            for (; width > 0; width --) {
  80042c:	fe0d9be3          	bnez	s11,800422 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  800430:	6a02                	ld	s4,0(sp)
  800432:	bbd5                	j	800226 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800434:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800436:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  80043a:	01174463          	blt	a4,a7,800442 <vprintfmt+0x256>
    else if (lflag) {
  80043e:	08088d63          	beqz	a7,8004d8 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  800442:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800446:	0a044d63          	bltz	s0,800500 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  80044a:	8622                	mv	a2,s0
  80044c:	8a66                	mv	s4,s9
  80044e:	46a9                	li	a3,10
  800450:	bdcd                	j	800342 <vprintfmt+0x156>
            err = va_arg(ap, int);
  800452:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800456:	4761                	li	a4,24
            err = va_arg(ap, int);
  800458:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80045a:	41f7d69b          	sraiw	a3,a5,0x1f
  80045e:	8fb5                	xor	a5,a5,a3
  800460:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800464:	02d74163          	blt	a4,a3,800486 <vprintfmt+0x29a>
  800468:	00369793          	slli	a5,a3,0x3
  80046c:	97de                	add	a5,a5,s7
  80046e:	639c                	ld	a5,0(a5)
  800470:	cb99                	beqz	a5,800486 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800472:	86be                	mv	a3,a5
  800474:	00000617          	auipc	a2,0x0
  800478:	28c60613          	addi	a2,a2,652 # 800700 <main+0x66>
  80047c:	85a6                	mv	a1,s1
  80047e:	854a                	mv	a0,s2
  800480:	0ce000ef          	jal	ra,80054e <printfmt>
  800484:	b34d                	j	800226 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800486:	00000617          	auipc	a2,0x0
  80048a:	26a60613          	addi	a2,a2,618 # 8006f0 <main+0x56>
  80048e:	85a6                	mv	a1,s1
  800490:	854a                	mv	a0,s2
  800492:	0bc000ef          	jal	ra,80054e <printfmt>
  800496:	bb41                	j	800226 <vprintfmt+0x3a>
                p = "(null)";
  800498:	00000417          	auipc	s0,0x0
  80049c:	25040413          	addi	s0,s0,592 # 8006e8 <main+0x4e>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a0:	85e2                	mv	a1,s8
  8004a2:	8522                	mv	a0,s0
  8004a4:	e43e                	sd	a5,8(sp)
  8004a6:	128000ef          	jal	ra,8005ce <strnlen>
  8004aa:	40ad8dbb          	subw	s11,s11,a0
  8004ae:	01b05b63          	blez	s11,8004c4 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  8004b2:	67a2                	ld	a5,8(sp)
  8004b4:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004ba:	85a6                	mv	a1,s1
  8004bc:	8552                	mv	a0,s4
  8004be:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c0:	fe0d9ce3          	bnez	s11,8004b8 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c4:	00044783          	lbu	a5,0(s0)
  8004c8:	00140a13          	addi	s4,s0,1
  8004cc:	0007851b          	sext.w	a0,a5
  8004d0:	d3a5                	beqz	a5,800430 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  8004d2:	05e00413          	li	s0,94
  8004d6:	bf39                	j	8003f4 <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004d8:	000a2403          	lw	s0,0(s4)
  8004dc:	b7ad                	j	800446 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  8004de:	000a6603          	lwu	a2,0(s4)
  8004e2:	46a1                	li	a3,8
  8004e4:	8a2e                	mv	s4,a1
  8004e6:	bdb1                	j	800342 <vprintfmt+0x156>
  8004e8:	000a6603          	lwu	a2,0(s4)
  8004ec:	46a9                	li	a3,10
  8004ee:	8a2e                	mv	s4,a1
  8004f0:	bd89                	j	800342 <vprintfmt+0x156>
  8004f2:	000a6603          	lwu	a2,0(s4)
  8004f6:	46c1                	li	a3,16
  8004f8:	8a2e                	mv	s4,a1
  8004fa:	b5a1                	j	800342 <vprintfmt+0x156>
                    putch(ch, putdat);
  8004fc:	9902                	jalr	s2
  8004fe:	bf09                	j	800410 <vprintfmt+0x224>
                putch('-', putdat);
  800500:	85a6                	mv	a1,s1
  800502:	02d00513          	li	a0,45
  800506:	e03e                	sd	a5,0(sp)
  800508:	9902                	jalr	s2
                num = -(long long)num;
  80050a:	6782                	ld	a5,0(sp)
  80050c:	8a66                	mv	s4,s9
  80050e:	40800633          	neg	a2,s0
  800512:	46a9                	li	a3,10
  800514:	b53d                	j	800342 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  800516:	03b05163          	blez	s11,800538 <vprintfmt+0x34c>
  80051a:	02d00693          	li	a3,45
  80051e:	f6d79de3          	bne	a5,a3,800498 <vprintfmt+0x2ac>
                p = "(null)";
  800522:	00000417          	auipc	s0,0x0
  800526:	1c640413          	addi	s0,s0,454 # 8006e8 <main+0x4e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80052a:	02800793          	li	a5,40
  80052e:	02800513          	li	a0,40
  800532:	00140a13          	addi	s4,s0,1
  800536:	bd6d                	j	8003f0 <vprintfmt+0x204>
  800538:	00000a17          	auipc	s4,0x0
  80053c:	1b1a0a13          	addi	s4,s4,433 # 8006e9 <main+0x4f>
  800540:	02800513          	li	a0,40
  800544:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800548:	05e00413          	li	s0,94
  80054c:	b565                	j	8003f4 <vprintfmt+0x208>

000000000080054e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800550:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800554:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800556:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800558:	ec06                	sd	ra,24(sp)
  80055a:	f83a                	sd	a4,48(sp)
  80055c:	fc3e                	sd	a5,56(sp)
  80055e:	e0c2                	sd	a6,64(sp)
  800560:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800562:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800564:	c89ff0ef          	jal	ra,8001ec <vprintfmt>
}
  800568:	60e2                	ld	ra,24(sp)
  80056a:	6161                	addi	sp,sp,80
  80056c:	8082                	ret

000000000080056e <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  80056e:	711d                	addi	sp,sp,-96
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
  800570:	15fd                	addi	a1,a1,-1
    va_start(ap, fmt);
  800572:	03810313          	addi	t1,sp,56
    struct sprintbuf b = {str, str + size - 1, 0};
  800576:	95aa                	add	a1,a1,a0
snprintf(char *str, size_t size, const char *fmt, ...) {
  800578:	f406                	sd	ra,40(sp)
  80057a:	fc36                	sd	a3,56(sp)
  80057c:	e0ba                	sd	a4,64(sp)
  80057e:	e4be                	sd	a5,72(sp)
  800580:	e8c2                	sd	a6,80(sp)
  800582:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800584:	e01a                	sd	t1,0(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  800586:	e42a                	sd	a0,8(sp)
  800588:	e82e                	sd	a1,16(sp)
  80058a:	cc02                	sw	zero,24(sp)
    if (str == NULL || b.buf > b.ebuf) {
  80058c:	c115                	beqz	a0,8005b0 <snprintf+0x42>
  80058e:	02a5e163          	bltu	a1,a0,8005b0 <snprintf+0x42>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800592:	00000517          	auipc	a0,0x0
  800596:	c4050513          	addi	a0,a0,-960 # 8001d2 <sprintputch>
  80059a:	869a                	mv	a3,t1
  80059c:	002c                	addi	a1,sp,8
  80059e:	c4fff0ef          	jal	ra,8001ec <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  8005a2:	67a2                	ld	a5,8(sp)
  8005a4:	00078023          	sb	zero,0(a5)
    return b.cnt;
  8005a8:	4562                	lw	a0,24(sp)
}
  8005aa:	70a2                	ld	ra,40(sp)
  8005ac:	6125                	addi	sp,sp,96
  8005ae:	8082                	ret
        return -E_INVAL;
  8005b0:	5575                	li	a0,-3
  8005b2:	bfe5                	j	8005aa <snprintf+0x3c>

00000000008005b4 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  8005b4:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
  8005b8:	872a                	mv	a4,a0
    size_t cnt = 0;
  8005ba:	4501                	li	a0,0
    while (*s ++ != '\0') {
  8005bc:	cb81                	beqz	a5,8005cc <strlen+0x18>
        cnt ++;
  8005be:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
  8005c0:	00a707b3          	add	a5,a4,a0
  8005c4:	0007c783          	lbu	a5,0(a5)
  8005c8:	fbfd                	bnez	a5,8005be <strlen+0xa>
  8005ca:	8082                	ret
    }
    return cnt;
}
  8005cc:	8082                	ret

00000000008005ce <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8005ce:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8005d0:	e589                	bnez	a1,8005da <strnlen+0xc>
  8005d2:	a811                	j	8005e6 <strnlen+0x18>
        cnt ++;
  8005d4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8005d6:	00f58863          	beq	a1,a5,8005e6 <strnlen+0x18>
  8005da:	00f50733          	add	a4,a0,a5
  8005de:	00074703          	lbu	a4,0(a4)
  8005e2:	fb6d                	bnez	a4,8005d4 <strnlen+0x6>
  8005e4:	85be                	mv	a1,a5
    }
    return cnt;
}
  8005e6:	852e                	mv	a0,a1
  8005e8:	8082                	ret

00000000008005ea <forktree>:
        exit(0);
    }
}

void
forktree(const char *cur) {
  8005ea:	1101                	addi	sp,sp,-32
  8005ec:	ec06                	sd	ra,24(sp)
  8005ee:	e822                	sd	s0,16(sp)
  8005f0:	842a                	mv	s0,a0
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  8005f2:	b67ff0ef          	jal	ra,800158 <getpid>
  8005f6:	85aa                	mv	a1,a0
  8005f8:	8622                	mv	a2,s0
  8005fa:	00000517          	auipc	a0,0x0
  8005fe:	3ee50513          	addi	a0,a0,1006 # 8009e8 <error_string+0xc8>
  800602:	a3fff0ef          	jal	ra,800040 <cprintf>

    forkchild(cur, '0');
  800606:	03000593          	li	a1,48
  80060a:	8522                	mv	a0,s0
  80060c:	044000ef          	jal	ra,800650 <forkchild>
    if (strlen(cur) >= DEPTH)
  800610:	8522                	mv	a0,s0
  800612:	fa3ff0ef          	jal	ra,8005b4 <strlen>
  800616:	478d                	li	a5,3
  800618:	00a7f663          	bgeu	a5,a0,800624 <forktree+0x3a>
    forkchild(cur, '1');
}
  80061c:	60e2                	ld	ra,24(sp)
  80061e:	6442                	ld	s0,16(sp)
  800620:	6105                	addi	sp,sp,32
  800622:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  800624:	03100713          	li	a4,49
  800628:	86a2                	mv	a3,s0
  80062a:	00000617          	auipc	a2,0x0
  80062e:	3d660613          	addi	a2,a2,982 # 800a00 <error_string+0xe0>
  800632:	4595                	li	a1,5
  800634:	0028                	addi	a0,sp,8
  800636:	f39ff0ef          	jal	ra,80056e <snprintf>
    if (fork() == 0) {
  80063a:	b1bff0ef          	jal	ra,800154 <fork>
  80063e:	fd79                	bnez	a0,80061c <forktree+0x32>
        forktree(nxt);
  800640:	0028                	addi	a0,sp,8
  800642:	fa9ff0ef          	jal	ra,8005ea <forktree>
        yield();
  800646:	b11ff0ef          	jal	ra,800156 <yield>
        exit(0);
  80064a:	4501                	li	a0,0
  80064c:	af3ff0ef          	jal	ra,80013e <exit>

0000000000800650 <forkchild>:
forkchild(const char *cur, char branch) {
  800650:	7179                	addi	sp,sp,-48
  800652:	f022                	sd	s0,32(sp)
  800654:	ec26                	sd	s1,24(sp)
  800656:	f406                	sd	ra,40(sp)
  800658:	842a                	mv	s0,a0
  80065a:	84ae                	mv	s1,a1
    if (strlen(cur) >= DEPTH)
  80065c:	f59ff0ef          	jal	ra,8005b4 <strlen>
  800660:	478d                	li	a5,3
  800662:	00a7f763          	bgeu	a5,a0,800670 <forkchild+0x20>
}
  800666:	70a2                	ld	ra,40(sp)
  800668:	7402                	ld	s0,32(sp)
  80066a:	64e2                	ld	s1,24(sp)
  80066c:	6145                	addi	sp,sp,48
  80066e:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  800670:	8726                	mv	a4,s1
  800672:	86a2                	mv	a3,s0
  800674:	00000617          	auipc	a2,0x0
  800678:	38c60613          	addi	a2,a2,908 # 800a00 <error_string+0xe0>
  80067c:	4595                	li	a1,5
  80067e:	0028                	addi	a0,sp,8
  800680:	eefff0ef          	jal	ra,80056e <snprintf>
    if (fork() == 0) {
  800684:	ad1ff0ef          	jal	ra,800154 <fork>
  800688:	fd79                	bnez	a0,800666 <forkchild+0x16>
        forktree(nxt);
  80068a:	0028                	addi	a0,sp,8
  80068c:	f5fff0ef          	jal	ra,8005ea <forktree>
        yield();
  800690:	ac7ff0ef          	jal	ra,800156 <yield>
        exit(0);
  800694:	4501                	li	a0,0
  800696:	aa9ff0ef          	jal	ra,80013e <exit>

000000000080069a <main>:

int
main(void) {
  80069a:	1141                	addi	sp,sp,-16
    forktree("");
  80069c:	00000517          	auipc	a0,0x0
  8006a0:	35c50513          	addi	a0,a0,860 # 8009f8 <error_string+0xd8>
main(void) {
  8006a4:	e406                	sd	ra,8(sp)
    forktree("");
  8006a6:	f45ff0ef          	jal	ra,8005ea <forktree>
    return 0;
}
  8006aa:	60a2                	ld	ra,8(sp)
  8006ac:	4501                	li	a0,0
  8006ae:	0141                	addi	sp,sp,16
  8006b0:	8082                	ret
