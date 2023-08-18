
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	89013103          	ld	sp,-1904(sp) # 80008890 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	072000ef          	jal	ra,80000088 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	2781                	sext.w	a5,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000028:	0037969b          	slliw	a3,a5,0x3
    8000002c:	02004737          	lui	a4,0x2004
    80000030:	96ba                	add	a3,a3,a4
    80000032:	0200c737          	lui	a4,0x200c
    80000036:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003a:	000f4737          	lui	a4,0xf4
    8000003e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000042:	963a                	add	a2,a2,a4
    80000044:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000046:	0057979b          	slliw	a5,a5,0x5
    8000004a:	078e                	slli	a5,a5,0x3
    8000004c:	00009617          	auipc	a2,0x9
    80000050:	fe460613          	addi	a2,a2,-28 # 80009030 <mscratch0>
    80000054:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000056:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000058:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005a:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005e:	00006797          	auipc	a5,0x6
    80000062:	e4278793          	addi	a5,a5,-446 # 80005ea0 <timervec>
    80000066:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006a:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006e:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000072:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000076:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007a:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007e:	30479073          	csrw	mie,a5
}
    80000082:	6422                	ld	s0,8(sp)
    80000084:	0141                	addi	sp,sp,16
    80000086:	8082                	ret

0000000080000088 <start>:
{
    80000088:	1141                	addi	sp,sp,-16
    8000008a:	e406                	sd	ra,8(sp)
    8000008c:	e022                	sd	s0,0(sp)
    8000008e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000090:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000094:	7779                	lui	a4,0xffffe
    80000096:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd77ff>
    8000009a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009c:	6705                	lui	a4,0x1
    8000009e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a4:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a8:	00001797          	auipc	a5,0x1
    800000ac:	eee78793          	addi	a5,a5,-274 # 80000f96 <main>
    800000b0:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b4:	4781                	li	a5,0
    800000b6:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000ba:	67c1                	lui	a5,0x10
    800000bc:	17fd                	addi	a5,a5,-1
    800000be:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c2:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c6:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ca:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000ce:	10479073          	csrw	sie,a5
  timerinit();
    800000d2:	00000097          	auipc	ra,0x0
    800000d6:	f4a080e7          	jalr	-182(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000da:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000de:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e0:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e2:	30200073          	mret
}
    800000e6:	60a2                	ld	ra,8(sp)
    800000e8:	6402                	ld	s0,0(sp)
    800000ea:	0141                	addi	sp,sp,16
    800000ec:	8082                	ret

00000000800000ee <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000ee:	715d                	addi	sp,sp,-80
    800000f0:	e486                	sd	ra,72(sp)
    800000f2:	e0a2                	sd	s0,64(sp)
    800000f4:	fc26                	sd	s1,56(sp)
    800000f6:	f84a                	sd	s2,48(sp)
    800000f8:	f44e                	sd	s3,40(sp)
    800000fa:	f052                	sd	s4,32(sp)
    800000fc:	ec56                	sd	s5,24(sp)
    800000fe:	0880                	addi	s0,sp,80
    80000100:	8a2a                	mv	s4,a0
    80000102:	892e                	mv	s2,a1
    80000104:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000106:	00011517          	auipc	a0,0x11
    8000010a:	72a50513          	addi	a0,a0,1834 # 80011830 <cons>
    8000010e:	00001097          	auipc	ra,0x1
    80000112:	bb8080e7          	jalr	-1096(ra) # 80000cc6 <acquire>
  for(i = 0; i < n; i++){
    80000116:	05305b63          	blez	s3,8000016c <consolewrite+0x7e>
    8000011a:	4481                	li	s1,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011c:	5afd                	li	s5,-1
    8000011e:	4685                	li	a3,1
    80000120:	864a                	mv	a2,s2
    80000122:	85d2                	mv	a1,s4
    80000124:	fbf40513          	addi	a0,s0,-65
    80000128:	00002097          	auipc	ra,0x2
    8000012c:	4a4080e7          	jalr	1188(ra) # 800025cc <either_copyin>
    80000130:	01550c63          	beq	a0,s5,80000148 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000134:	fbf44503          	lbu	a0,-65(s0)
    80000138:	00001097          	auipc	ra,0x1
    8000013c:	852080e7          	jalr	-1966(ra) # 8000098a <uartputc>
  for(i = 0; i < n; i++){
    80000140:	2485                	addiw	s1,s1,1
    80000142:	0905                	addi	s2,s2,1
    80000144:	fc999de3          	bne	s3,s1,8000011e <consolewrite+0x30>
  }
  release(&cons.lock);
    80000148:	00011517          	auipc	a0,0x11
    8000014c:	6e850513          	addi	a0,a0,1768 # 80011830 <cons>
    80000150:	00001097          	auipc	ra,0x1
    80000154:	c2a080e7          	jalr	-982(ra) # 80000d7a <release>

  return i;
}
    80000158:	8526                	mv	a0,s1
    8000015a:	60a6                	ld	ra,72(sp)
    8000015c:	6406                	ld	s0,64(sp)
    8000015e:	74e2                	ld	s1,56(sp)
    80000160:	7942                	ld	s2,48(sp)
    80000162:	79a2                	ld	s3,40(sp)
    80000164:	7a02                	ld	s4,32(sp)
    80000166:	6ae2                	ld	s5,24(sp)
    80000168:	6161                	addi	sp,sp,80
    8000016a:	8082                	ret
  for(i = 0; i < n; i++){
    8000016c:	4481                	li	s1,0
    8000016e:	bfe9                	j	80000148 <consolewrite+0x5a>

0000000080000170 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000170:	7119                	addi	sp,sp,-128
    80000172:	fc86                	sd	ra,120(sp)
    80000174:	f8a2                	sd	s0,112(sp)
    80000176:	f4a6                	sd	s1,104(sp)
    80000178:	f0ca                	sd	s2,96(sp)
    8000017a:	ecce                	sd	s3,88(sp)
    8000017c:	e8d2                	sd	s4,80(sp)
    8000017e:	e4d6                	sd	s5,72(sp)
    80000180:	e0da                	sd	s6,64(sp)
    80000182:	fc5e                	sd	s7,56(sp)
    80000184:	f862                	sd	s8,48(sp)
    80000186:	f466                	sd	s9,40(sp)
    80000188:	f06a                	sd	s10,32(sp)
    8000018a:	ec6e                	sd	s11,24(sp)
    8000018c:	0100                	addi	s0,sp,128
    8000018e:	8caa                	mv	s9,a0
    80000190:	8aae                	mv	s5,a1
    80000192:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000194:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000198:	00011517          	auipc	a0,0x11
    8000019c:	69850513          	addi	a0,a0,1688 # 80011830 <cons>
    800001a0:	00001097          	auipc	ra,0x1
    800001a4:	b26080e7          	jalr	-1242(ra) # 80000cc6 <acquire>
  while(n > 0){
    800001a8:	09405663          	blez	s4,80000234 <consoleread+0xc4>
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001ac:	00011497          	auipc	s1,0x11
    800001b0:	68448493          	addi	s1,s1,1668 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b4:	89a6                	mv	s3,s1
    800001b6:	00011917          	auipc	s2,0x11
    800001ba:	71290913          	addi	s2,s2,1810 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001be:	4c11                	li	s8,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c0:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001c2:	4da9                	li	s11,10
    while(cons.r == cons.w){
    800001c4:	0984a783          	lw	a5,152(s1)
    800001c8:	09c4a703          	lw	a4,156(s1)
    800001cc:	02f71463          	bne	a4,a5,800001f4 <consoleread+0x84>
      if(myproc()->killed){
    800001d0:	00002097          	auipc	ra,0x2
    800001d4:	904080e7          	jalr	-1788(ra) # 80001ad4 <myproc>
    800001d8:	591c                	lw	a5,48(a0)
    800001da:	eba5                	bnez	a5,8000024a <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001dc:	85ce                	mv	a1,s3
    800001de:	854a                	mv	a0,s2
    800001e0:	00002097          	auipc	ra,0x2
    800001e4:	134080e7          	jalr	308(ra) # 80002314 <sleep>
    while(cons.r == cons.w){
    800001e8:	0984a783          	lw	a5,152(s1)
    800001ec:	09c4a703          	lw	a4,156(s1)
    800001f0:	fef700e3          	beq	a4,a5,800001d0 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f4:	0017871b          	addiw	a4,a5,1
    800001f8:	08e4ac23          	sw	a4,152(s1)
    800001fc:	07f7f713          	andi	a4,a5,127
    80000200:	9726                	add	a4,a4,s1
    80000202:	01874703          	lbu	a4,24(a4)
    80000206:	00070b9b          	sext.w	s7,a4
    if(c == C('D')){  // end-of-file
    8000020a:	078b8863          	beq	s7,s8,8000027a <consoleread+0x10a>
    cbuf = c;
    8000020e:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000212:	4685                	li	a3,1
    80000214:	f8f40613          	addi	a2,s0,-113
    80000218:	85d6                	mv	a1,s5
    8000021a:	8566                	mv	a0,s9
    8000021c:	00002097          	auipc	ra,0x2
    80000220:	35a080e7          	jalr	858(ra) # 80002576 <either_copyout>
    80000224:	01a50863          	beq	a0,s10,80000234 <consoleread+0xc4>
    dst++;
    80000228:	0a85                	addi	s5,s5,1
    --n;
    8000022a:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    8000022c:	01bb8463          	beq	s7,s11,80000234 <consoleread+0xc4>
  while(n > 0){
    80000230:	f80a1ae3          	bnez	s4,800001c4 <consoleread+0x54>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000234:	00011517          	auipc	a0,0x11
    80000238:	5fc50513          	addi	a0,a0,1532 # 80011830 <cons>
    8000023c:	00001097          	auipc	ra,0x1
    80000240:	b3e080e7          	jalr	-1218(ra) # 80000d7a <release>

  return target - n;
    80000244:	414b053b          	subw	a0,s6,s4
    80000248:	a811                	j	8000025c <consoleread+0xec>
        release(&cons.lock);
    8000024a:	00011517          	auipc	a0,0x11
    8000024e:	5e650513          	addi	a0,a0,1510 # 80011830 <cons>
    80000252:	00001097          	auipc	ra,0x1
    80000256:	b28080e7          	jalr	-1240(ra) # 80000d7a <release>
        return -1;
    8000025a:	557d                	li	a0,-1
}
    8000025c:	70e6                	ld	ra,120(sp)
    8000025e:	7446                	ld	s0,112(sp)
    80000260:	74a6                	ld	s1,104(sp)
    80000262:	7906                	ld	s2,96(sp)
    80000264:	69e6                	ld	s3,88(sp)
    80000266:	6a46                	ld	s4,80(sp)
    80000268:	6aa6                	ld	s5,72(sp)
    8000026a:	6b06                	ld	s6,64(sp)
    8000026c:	7be2                	ld	s7,56(sp)
    8000026e:	7c42                	ld	s8,48(sp)
    80000270:	7ca2                	ld	s9,40(sp)
    80000272:	7d02                	ld	s10,32(sp)
    80000274:	6de2                	ld	s11,24(sp)
    80000276:	6109                	addi	sp,sp,128
    80000278:	8082                	ret
      if(n < target){
    8000027a:	000a071b          	sext.w	a4,s4
    8000027e:	fb677be3          	bleu	s6,a4,80000234 <consoleread+0xc4>
        cons.r--;
    80000282:	00011717          	auipc	a4,0x11
    80000286:	64f72323          	sw	a5,1606(a4) # 800118c8 <cons+0x98>
    8000028a:	b76d                	j	80000234 <consoleread+0xc4>

000000008000028c <consputc>:
{
    8000028c:	1141                	addi	sp,sp,-16
    8000028e:	e406                	sd	ra,8(sp)
    80000290:	e022                	sd	s0,0(sp)
    80000292:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000294:	10000793          	li	a5,256
    80000298:	00f50a63          	beq	a0,a5,800002ac <consputc+0x20>
    uartputc_sync(c);
    8000029c:	00000097          	auipc	ra,0x0
    800002a0:	5ee080e7          	jalr	1518(ra) # 8000088a <uartputc_sync>
}
    800002a4:	60a2                	ld	ra,8(sp)
    800002a6:	6402                	ld	s0,0(sp)
    800002a8:	0141                	addi	sp,sp,16
    800002aa:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002ac:	4521                	li	a0,8
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	5dc080e7          	jalr	1500(ra) # 8000088a <uartputc_sync>
    800002b6:	02000513          	li	a0,32
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	5d0080e7          	jalr	1488(ra) # 8000088a <uartputc_sync>
    800002c2:	4521                	li	a0,8
    800002c4:	00000097          	auipc	ra,0x0
    800002c8:	5c6080e7          	jalr	1478(ra) # 8000088a <uartputc_sync>
    800002cc:	bfe1                	j	800002a4 <consputc+0x18>

00000000800002ce <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ce:	1101                	addi	sp,sp,-32
    800002d0:	ec06                	sd	ra,24(sp)
    800002d2:	e822                	sd	s0,16(sp)
    800002d4:	e426                	sd	s1,8(sp)
    800002d6:	e04a                	sd	s2,0(sp)
    800002d8:	1000                	addi	s0,sp,32
    800002da:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002dc:	00011517          	auipc	a0,0x11
    800002e0:	55450513          	addi	a0,a0,1364 # 80011830 <cons>
    800002e4:	00001097          	auipc	ra,0x1
    800002e8:	9e2080e7          	jalr	-1566(ra) # 80000cc6 <acquire>

  switch(c){
    800002ec:	47c1                	li	a5,16
    800002ee:	12f48463          	beq	s1,a5,80000416 <consoleintr+0x148>
    800002f2:	0297df63          	ble	s1,a5,80000330 <consoleintr+0x62>
    800002f6:	47d5                	li	a5,21
    800002f8:	0af48863          	beq	s1,a5,800003a8 <consoleintr+0xda>
    800002fc:	07f00793          	li	a5,127
    80000300:	02f49b63          	bne	s1,a5,80000336 <consoleintr+0x68>
      consputc(BACKSPACE);
    }
    break;
  case C('H'): // Backspace
  case '\x7f':
    if(cons.e != cons.w){
    80000304:	00011717          	auipc	a4,0x11
    80000308:	52c70713          	addi	a4,a4,1324 # 80011830 <cons>
    8000030c:	0a072783          	lw	a5,160(a4)
    80000310:	09c72703          	lw	a4,156(a4)
    80000314:	10f70563          	beq	a4,a5,8000041e <consoleintr+0x150>
      cons.e--;
    80000318:	37fd                	addiw	a5,a5,-1
    8000031a:	00011717          	auipc	a4,0x11
    8000031e:	5af72b23          	sw	a5,1462(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    80000322:	10000513          	li	a0,256
    80000326:	00000097          	auipc	ra,0x0
    8000032a:	f66080e7          	jalr	-154(ra) # 8000028c <consputc>
    8000032e:	a8c5                	j	8000041e <consoleintr+0x150>
  switch(c){
    80000330:	47a1                	li	a5,8
    80000332:	fcf489e3          	beq	s1,a5,80000304 <consoleintr+0x36>
    }
    break;
  default:
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000336:	c4e5                	beqz	s1,8000041e <consoleintr+0x150>
    80000338:	00011717          	auipc	a4,0x11
    8000033c:	4f870713          	addi	a4,a4,1272 # 80011830 <cons>
    80000340:	0a072783          	lw	a5,160(a4)
    80000344:	09872703          	lw	a4,152(a4)
    80000348:	9f99                	subw	a5,a5,a4
    8000034a:	07f00713          	li	a4,127
    8000034e:	0cf76863          	bltu	a4,a5,8000041e <consoleintr+0x150>
      c = (c == '\r') ? '\n' : c;
    80000352:	47b5                	li	a5,13
    80000354:	0ef48363          	beq	s1,a5,8000043a <consoleintr+0x16c>

      // echo back to the user.
      consputc(c);
    80000358:	8526                	mv	a0,s1
    8000035a:	00000097          	auipc	ra,0x0
    8000035e:	f32080e7          	jalr	-206(ra) # 8000028c <consputc>

      // store for consumption by consoleread().
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000362:	00011797          	auipc	a5,0x11
    80000366:	4ce78793          	addi	a5,a5,1230 # 80011830 <cons>
    8000036a:	0a07a703          	lw	a4,160(a5)
    8000036e:	0017069b          	addiw	a3,a4,1
    80000372:	0006861b          	sext.w	a2,a3
    80000376:	0ad7a023          	sw	a3,160(a5)
    8000037a:	07f77713          	andi	a4,a4,127
    8000037e:	97ba                	add	a5,a5,a4
    80000380:	00978c23          	sb	s1,24(a5)

      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000384:	47a9                	li	a5,10
    80000386:	0ef48163          	beq	s1,a5,80000468 <consoleintr+0x19a>
    8000038a:	4791                	li	a5,4
    8000038c:	0cf48e63          	beq	s1,a5,80000468 <consoleintr+0x19a>
    80000390:	00011797          	auipc	a5,0x11
    80000394:	4a078793          	addi	a5,a5,1184 # 80011830 <cons>
    80000398:	0987a783          	lw	a5,152(a5)
    8000039c:	0807879b          	addiw	a5,a5,128
    800003a0:	06f61f63          	bne	a2,a5,8000041e <consoleintr+0x150>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003a4:	863e                	mv	a2,a5
    800003a6:	a0c9                	j	80000468 <consoleintr+0x19a>
    while(cons.e != cons.w &&
    800003a8:	00011717          	auipc	a4,0x11
    800003ac:	48870713          	addi	a4,a4,1160 # 80011830 <cons>
    800003b0:	0a072783          	lw	a5,160(a4)
    800003b4:	09c72703          	lw	a4,156(a4)
    800003b8:	06f70363          	beq	a4,a5,8000041e <consoleintr+0x150>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003bc:	37fd                	addiw	a5,a5,-1
    800003be:	0007871b          	sext.w	a4,a5
    800003c2:	07f7f793          	andi	a5,a5,127
    800003c6:	00011697          	auipc	a3,0x11
    800003ca:	46a68693          	addi	a3,a3,1130 # 80011830 <cons>
    800003ce:	97b6                	add	a5,a5,a3
    while(cons.e != cons.w &&
    800003d0:	0187c683          	lbu	a3,24(a5)
    800003d4:	47a9                	li	a5,10
      cons.e--;
    800003d6:	00011497          	auipc	s1,0x11
    800003da:	45a48493          	addi	s1,s1,1114 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003de:	4929                	li	s2,10
    800003e0:	02f68f63          	beq	a3,a5,8000041e <consoleintr+0x150>
      cons.e--;
    800003e4:	0ae4a023          	sw	a4,160(s1)
      consputc(BACKSPACE);
    800003e8:	10000513          	li	a0,256
    800003ec:	00000097          	auipc	ra,0x0
    800003f0:	ea0080e7          	jalr	-352(ra) # 8000028c <consputc>
    while(cons.e != cons.w &&
    800003f4:	0a04a783          	lw	a5,160(s1)
    800003f8:	09c4a703          	lw	a4,156(s1)
    800003fc:	02f70163          	beq	a4,a5,8000041e <consoleintr+0x150>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000400:	37fd                	addiw	a5,a5,-1
    80000402:	0007871b          	sext.w	a4,a5
    80000406:	07f7f793          	andi	a5,a5,127
    8000040a:	97a6                	add	a5,a5,s1
    while(cons.e != cons.w &&
    8000040c:	0187c783          	lbu	a5,24(a5)
    80000410:	fd279ae3          	bne	a5,s2,800003e4 <consoleintr+0x116>
    80000414:	a029                	j	8000041e <consoleintr+0x150>
    procdump();
    80000416:	00002097          	auipc	ra,0x2
    8000041a:	20c080e7          	jalr	524(ra) # 80002622 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000041e:	00011517          	auipc	a0,0x11
    80000422:	41250513          	addi	a0,a0,1042 # 80011830 <cons>
    80000426:	00001097          	auipc	ra,0x1
    8000042a:	954080e7          	jalr	-1708(ra) # 80000d7a <release>
}
    8000042e:	60e2                	ld	ra,24(sp)
    80000430:	6442                	ld	s0,16(sp)
    80000432:	64a2                	ld	s1,8(sp)
    80000434:	6902                	ld	s2,0(sp)
    80000436:	6105                	addi	sp,sp,32
    80000438:	8082                	ret
      consputc(c);
    8000043a:	4529                	li	a0,10
    8000043c:	00000097          	auipc	ra,0x0
    80000440:	e50080e7          	jalr	-432(ra) # 8000028c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000444:	00011797          	auipc	a5,0x11
    80000448:	3ec78793          	addi	a5,a5,1004 # 80011830 <cons>
    8000044c:	0a07a703          	lw	a4,160(a5)
    80000450:	0017069b          	addiw	a3,a4,1
    80000454:	0006861b          	sext.w	a2,a3
    80000458:	0ad7a023          	sw	a3,160(a5)
    8000045c:	07f77713          	andi	a4,a4,127
    80000460:	97ba                	add	a5,a5,a4
    80000462:	4729                	li	a4,10
    80000464:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000468:	00011797          	auipc	a5,0x11
    8000046c:	46c7a223          	sw	a2,1124(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000470:	00011517          	auipc	a0,0x11
    80000474:	45850513          	addi	a0,a0,1112 # 800118c8 <cons+0x98>
    80000478:	00002097          	auipc	ra,0x2
    8000047c:	022080e7          	jalr	34(ra) # 8000249a <wakeup>
    80000480:	bf79                	j	8000041e <consoleintr+0x150>

0000000080000482 <consoleinit>:

void
consoleinit(void)
{
    80000482:	1141                	addi	sp,sp,-16
    80000484:	e406                	sd	ra,8(sp)
    80000486:	e022                	sd	s0,0(sp)
    80000488:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000048a:	00008597          	auipc	a1,0x8
    8000048e:	b8658593          	addi	a1,a1,-1146 # 80008010 <etext+0x10>
    80000492:	00011517          	auipc	a0,0x11
    80000496:	39e50513          	addi	a0,a0,926 # 80011830 <cons>
    8000049a:	00000097          	auipc	ra,0x0
    8000049e:	79c080e7          	jalr	1948(ra) # 80000c36 <initlock>

  uartinit();
    800004a2:	00000097          	auipc	ra,0x0
    800004a6:	398080e7          	jalr	920(ra) # 8000083a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004aa:	00022797          	auipc	a5,0x22
    800004ae:	b0678793          	addi	a5,a5,-1274 # 80021fb0 <devsw>
    800004b2:	00000717          	auipc	a4,0x0
    800004b6:	cbe70713          	addi	a4,a4,-834 # 80000170 <consoleread>
    800004ba:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004bc:	00000717          	auipc	a4,0x0
    800004c0:	c3270713          	addi	a4,a4,-974 # 800000ee <consolewrite>
    800004c4:	ef98                	sd	a4,24(a5)
}
    800004c6:	60a2                	ld	ra,8(sp)
    800004c8:	6402                	ld	s0,0(sp)
    800004ca:	0141                	addi	sp,sp,16
    800004cc:	8082                	ret

00000000800004ce <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004ce:	7179                	addi	sp,sp,-48
    800004d0:	f406                	sd	ra,40(sp)
    800004d2:	f022                	sd	s0,32(sp)
    800004d4:	ec26                	sd	s1,24(sp)
    800004d6:	e84a                	sd	s2,16(sp)
    800004d8:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004da:	c219                	beqz	a2,800004e0 <printint+0x12>
    800004dc:	00054d63          	bltz	a0,800004f6 <printint+0x28>
    x = -xx;
  else
    x = xx;
    800004e0:	2501                	sext.w	a0,a0
    800004e2:	4881                	li	a7,0
    800004e4:	fd040713          	addi	a4,s0,-48

  i = 0;
    800004e8:	4601                	li	a2,0
  do {
    buf[i++] = digits[x % base];
    800004ea:	2581                	sext.w	a1,a1
    800004ec:	00008817          	auipc	a6,0x8
    800004f0:	b2c80813          	addi	a6,a6,-1236 # 80008018 <digits>
    800004f4:	a801                	j	80000504 <printint+0x36>
    x = -xx;
    800004f6:	40a0053b          	negw	a0,a0
    800004fa:	2501                	sext.w	a0,a0
  if(sign && (sign = xx < 0))
    800004fc:	4885                	li	a7,1
    x = -xx;
    800004fe:	b7dd                	j	800004e4 <printint+0x16>
  } while((x /= base) != 0);
    80000500:	853e                	mv	a0,a5
    buf[i++] = digits[x % base];
    80000502:	8636                	mv	a2,a3
    80000504:	0016069b          	addiw	a3,a2,1
    80000508:	02b577bb          	remuw	a5,a0,a1
    8000050c:	1782                	slli	a5,a5,0x20
    8000050e:	9381                	srli	a5,a5,0x20
    80000510:	97c2                	add	a5,a5,a6
    80000512:	0007c783          	lbu	a5,0(a5)
    80000516:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    8000051a:	0705                	addi	a4,a4,1
    8000051c:	02b557bb          	divuw	a5,a0,a1
    80000520:	feb570e3          	bleu	a1,a0,80000500 <printint+0x32>

  if(sign)
    80000524:	00088b63          	beqz	a7,8000053a <printint+0x6c>
    buf[i++] = '-';
    80000528:	fe040793          	addi	a5,s0,-32
    8000052c:	96be                	add	a3,a3,a5
    8000052e:	02d00793          	li	a5,45
    80000532:	fef68823          	sb	a5,-16(a3)
    80000536:	0026069b          	addiw	a3,a2,2

  while(--i >= 0)
    8000053a:	02d05763          	blez	a3,80000568 <printint+0x9a>
    8000053e:	fd040793          	addi	a5,s0,-48
    80000542:	00d784b3          	add	s1,a5,a3
    80000546:	fff78913          	addi	s2,a5,-1
    8000054a:	9936                	add	s2,s2,a3
    8000054c:	36fd                	addiw	a3,a3,-1
    8000054e:	1682                	slli	a3,a3,0x20
    80000550:	9281                	srli	a3,a3,0x20
    80000552:	40d90933          	sub	s2,s2,a3
    consputc(buf[i]);
    80000556:	fff4c503          	lbu	a0,-1(s1)
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	d32080e7          	jalr	-718(ra) # 8000028c <consputc>
  while(--i >= 0)
    80000562:	14fd                	addi	s1,s1,-1
    80000564:	ff2499e3          	bne	s1,s2,80000556 <printint+0x88>
}
    80000568:	70a2                	ld	ra,40(sp)
    8000056a:	7402                	ld	s0,32(sp)
    8000056c:	64e2                	ld	s1,24(sp)
    8000056e:	6942                	ld	s2,16(sp)
    80000570:	6145                	addi	sp,sp,48
    80000572:	8082                	ret

0000000080000574 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000574:	1101                	addi	sp,sp,-32
    80000576:	ec06                	sd	ra,24(sp)
    80000578:	e822                	sd	s0,16(sp)
    8000057a:	e426                	sd	s1,8(sp)
    8000057c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000057e:	00011497          	auipc	s1,0x11
    80000582:	35a48493          	addi	s1,s1,858 # 800118d8 <pr>
    80000586:	00008597          	auipc	a1,0x8
    8000058a:	aaa58593          	addi	a1,a1,-1366 # 80008030 <digits+0x18>
    8000058e:	8526                	mv	a0,s1
    80000590:	00000097          	auipc	ra,0x0
    80000594:	6a6080e7          	jalr	1702(ra) # 80000c36 <initlock>
  pr.locking = 1;
    80000598:	4785                	li	a5,1
    8000059a:	cc9c                	sw	a5,24(s1)
}
    8000059c:	60e2                	ld	ra,24(sp)
    8000059e:	6442                	ld	s0,16(sp)
    800005a0:	64a2                	ld	s1,8(sp)
    800005a2:	6105                	addi	sp,sp,32
    800005a4:	8082                	ret

00000000800005a6 <backtrace>:

void
backtrace(void)
{
    800005a6:	7179                	addi	sp,sp,-48
    800005a8:	f406                	sd	ra,40(sp)
    800005aa:	f022                	sd	s0,32(sp)
    800005ac:	ec26                	sd	s1,24(sp)
    800005ae:	e84a                	sd	s2,16(sp)
    800005b0:	e44e                	sd	s3,8(sp)
    800005b2:	1800                	addi	s0,sp,48
  printf("backtrace:\n");
    800005b4:	00008517          	auipc	a0,0x8
    800005b8:	a8450513          	addi	a0,a0,-1404 # 80008038 <digits+0x20>
    800005bc:	00000097          	auipc	ra,0x0
    800005c0:	098080e7          	jalr	152(ra) # 80000654 <printf>

static inline uint64
r_fp()
{
  uint64 x;
  asm volatile("mv %0, s0" : "=r" (x) );
    800005c4:	84a2                	mv	s1,s0
  uint64 fp = r_fp();
  uint64 base = PGROUNDUP(fp);
    800005c6:	6905                	lui	s2,0x1
    800005c8:	197d                	addi	s2,s2,-1
    800005ca:	9926                	add	s2,s2,s1
    800005cc:	77fd                	lui	a5,0xfffff
    800005ce:	00f97933          	and	s2,s2,a5
  while(fp < base) {
    800005d2:	0324f163          	bleu	s2,s1,800005f4 <backtrace+0x4e>
    printf("%p\n", *((uint64*)(fp - 8)));
    800005d6:	00008997          	auipc	s3,0x8
    800005da:	a7298993          	addi	s3,s3,-1422 # 80008048 <digits+0x30>
    800005de:	ff84b583          	ld	a1,-8(s1)
    800005e2:	854e                	mv	a0,s3
    800005e4:	00000097          	auipc	ra,0x0
    800005e8:	070080e7          	jalr	112(ra) # 80000654 <printf>
    fp = *((uint64*)(fp - 16));
    800005ec:	ff04b483          	ld	s1,-16(s1)
  while(fp < base) {
    800005f0:	ff24e7e3          	bltu	s1,s2,800005de <backtrace+0x38>
  }
}
    800005f4:	70a2                	ld	ra,40(sp)
    800005f6:	7402                	ld	s0,32(sp)
    800005f8:	64e2                	ld	s1,24(sp)
    800005fa:	6942                	ld	s2,16(sp)
    800005fc:	69a2                	ld	s3,8(sp)
    800005fe:	6145                	addi	sp,sp,48
    80000600:	8082                	ret

0000000080000602 <panic>:
{
    80000602:	1101                	addi	sp,sp,-32
    80000604:	ec06                	sd	ra,24(sp)
    80000606:	e822                	sd	s0,16(sp)
    80000608:	e426                	sd	s1,8(sp)
    8000060a:	1000                	addi	s0,sp,32
    8000060c:	84aa                	mv	s1,a0
  backtrace();
    8000060e:	00000097          	auipc	ra,0x0
    80000612:	f98080e7          	jalr	-104(ra) # 800005a6 <backtrace>
  pr.locking = 0;
    80000616:	00011797          	auipc	a5,0x11
    8000061a:	2c07ad23          	sw	zero,730(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    8000061e:	00008517          	auipc	a0,0x8
    80000622:	a3250513          	addi	a0,a0,-1486 # 80008050 <digits+0x38>
    80000626:	00000097          	auipc	ra,0x0
    8000062a:	02e080e7          	jalr	46(ra) # 80000654 <printf>
  printf(s);
    8000062e:	8526                	mv	a0,s1
    80000630:	00000097          	auipc	ra,0x0
    80000634:	024080e7          	jalr	36(ra) # 80000654 <printf>
  printf("\n");
    80000638:	00008517          	auipc	a0,0x8
    8000063c:	aa850513          	addi	a0,a0,-1368 # 800080e0 <digits+0xc8>
    80000640:	00000097          	auipc	ra,0x0
    80000644:	014080e7          	jalr	20(ra) # 80000654 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000648:	4785                	li	a5,1
    8000064a:	00009717          	auipc	a4,0x9
    8000064e:	9af72b23          	sw	a5,-1610(a4) # 80009000 <panicked>
  for(;;)
    80000652:	a001                	j	80000652 <panic+0x50>

0000000080000654 <printf>:
{
    80000654:	7131                	addi	sp,sp,-192
    80000656:	fc86                	sd	ra,120(sp)
    80000658:	f8a2                	sd	s0,112(sp)
    8000065a:	f4a6                	sd	s1,104(sp)
    8000065c:	f0ca                	sd	s2,96(sp)
    8000065e:	ecce                	sd	s3,88(sp)
    80000660:	e8d2                	sd	s4,80(sp)
    80000662:	e4d6                	sd	s5,72(sp)
    80000664:	e0da                	sd	s6,64(sp)
    80000666:	fc5e                	sd	s7,56(sp)
    80000668:	f862                	sd	s8,48(sp)
    8000066a:	f466                	sd	s9,40(sp)
    8000066c:	f06a                	sd	s10,32(sp)
    8000066e:	ec6e                	sd	s11,24(sp)
    80000670:	0100                	addi	s0,sp,128
    80000672:	8aaa                	mv	s5,a0
    80000674:	e40c                	sd	a1,8(s0)
    80000676:	e810                	sd	a2,16(s0)
    80000678:	ec14                	sd	a3,24(s0)
    8000067a:	f018                	sd	a4,32(s0)
    8000067c:	f41c                	sd	a5,40(s0)
    8000067e:	03043823          	sd	a6,48(s0)
    80000682:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80000686:	00011797          	auipc	a5,0x11
    8000068a:	25278793          	addi	a5,a5,594 # 800118d8 <pr>
    8000068e:	0187ad83          	lw	s11,24(a5)
  if(locking)
    80000692:	020d9b63          	bnez	s11,800006c8 <printf+0x74>
  if (fmt == 0)
    80000696:	020a8f63          	beqz	s5,800006d4 <printf+0x80>
  va_start(ap, fmt);
    8000069a:	00840793          	addi	a5,s0,8
    8000069e:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800006a2:	000ac503          	lbu	a0,0(s5)
    800006a6:	16050063          	beqz	a0,80000806 <printf+0x1b2>
    800006aa:	4481                	li	s1,0
    if(c != '%'){
    800006ac:	02500a13          	li	s4,37
    switch(c){
    800006b0:	07000b13          	li	s6,112
  consputc('x');
    800006b4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006b6:	00008b97          	auipc	s7,0x8
    800006ba:	962b8b93          	addi	s7,s7,-1694 # 80008018 <digits>
    switch(c){
    800006be:	07300c93          	li	s9,115
    800006c2:	06400c13          	li	s8,100
    800006c6:	a815                	j	800006fa <printf+0xa6>
    acquire(&pr.lock);
    800006c8:	853e                	mv	a0,a5
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	5fc080e7          	jalr	1532(ra) # 80000cc6 <acquire>
    800006d2:	b7d1                	j	80000696 <printf+0x42>
    panic("null fmt");
    800006d4:	00008517          	auipc	a0,0x8
    800006d8:	98c50513          	addi	a0,a0,-1652 # 80008060 <digits+0x48>
    800006dc:	00000097          	auipc	ra,0x0
    800006e0:	f26080e7          	jalr	-218(ra) # 80000602 <panic>
      consputc(c);
    800006e4:	00000097          	auipc	ra,0x0
    800006e8:	ba8080e7          	jalr	-1112(ra) # 8000028c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800006ec:	2485                	addiw	s1,s1,1
    800006ee:	009a87b3          	add	a5,s5,s1
    800006f2:	0007c503          	lbu	a0,0(a5)
    800006f6:	10050863          	beqz	a0,80000806 <printf+0x1b2>
    if(c != '%'){
    800006fa:	ff4515e3          	bne	a0,s4,800006e4 <printf+0x90>
    c = fmt[++i] & 0xff;
    800006fe:	2485                	addiw	s1,s1,1
    80000700:	009a87b3          	add	a5,s5,s1
    80000704:	0007c783          	lbu	a5,0(a5)
    80000708:	0007891b          	sext.w	s2,a5
    if(c == 0)
    8000070c:	0e090d63          	beqz	s2,80000806 <printf+0x1b2>
    switch(c){
    80000710:	05678a63          	beq	a5,s6,80000764 <printf+0x110>
    80000714:	02fb7663          	bleu	a5,s6,80000740 <printf+0xec>
    80000718:	09978963          	beq	a5,s9,800007aa <printf+0x156>
    8000071c:	07800713          	li	a4,120
    80000720:	0ce79863          	bne	a5,a4,800007f0 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000724:	f8843783          	ld	a5,-120(s0)
    80000728:	00878713          	addi	a4,a5,8
    8000072c:	f8e43423          	sd	a4,-120(s0)
    80000730:	4605                	li	a2,1
    80000732:	85ea                	mv	a1,s10
    80000734:	4388                	lw	a0,0(a5)
    80000736:	00000097          	auipc	ra,0x0
    8000073a:	d98080e7          	jalr	-616(ra) # 800004ce <printint>
      break;
    8000073e:	b77d                	j	800006ec <printf+0x98>
    switch(c){
    80000740:	0b478263          	beq	a5,s4,800007e4 <printf+0x190>
    80000744:	0b879663          	bne	a5,s8,800007f0 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000748:	f8843783          	ld	a5,-120(s0)
    8000074c:	00878713          	addi	a4,a5,8
    80000750:	f8e43423          	sd	a4,-120(s0)
    80000754:	4605                	li	a2,1
    80000756:	45a9                	li	a1,10
    80000758:	4388                	lw	a0,0(a5)
    8000075a:	00000097          	auipc	ra,0x0
    8000075e:	d74080e7          	jalr	-652(ra) # 800004ce <printint>
      break;
    80000762:	b769                	j	800006ec <printf+0x98>
      printptr(va_arg(ap, uint64));
    80000764:	f8843783          	ld	a5,-120(s0)
    80000768:	00878713          	addi	a4,a5,8
    8000076c:	f8e43423          	sd	a4,-120(s0)
    80000770:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000774:	03000513          	li	a0,48
    80000778:	00000097          	auipc	ra,0x0
    8000077c:	b14080e7          	jalr	-1260(ra) # 8000028c <consputc>
  consputc('x');
    80000780:	07800513          	li	a0,120
    80000784:	00000097          	auipc	ra,0x0
    80000788:	b08080e7          	jalr	-1272(ra) # 8000028c <consputc>
    8000078c:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000078e:	03c9d793          	srli	a5,s3,0x3c
    80000792:	97de                	add	a5,a5,s7
    80000794:	0007c503          	lbu	a0,0(a5)
    80000798:	00000097          	auipc	ra,0x0
    8000079c:	af4080e7          	jalr	-1292(ra) # 8000028c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800007a0:	0992                	slli	s3,s3,0x4
    800007a2:	397d                	addiw	s2,s2,-1
    800007a4:	fe0915e3          	bnez	s2,8000078e <printf+0x13a>
    800007a8:	b791                	j	800006ec <printf+0x98>
      if((s = va_arg(ap, char*)) == 0)
    800007aa:	f8843783          	ld	a5,-120(s0)
    800007ae:	00878713          	addi	a4,a5,8
    800007b2:	f8e43423          	sd	a4,-120(s0)
    800007b6:	0007b903          	ld	s2,0(a5)
    800007ba:	00090e63          	beqz	s2,800007d6 <printf+0x182>
      for(; *s; s++)
    800007be:	00094503          	lbu	a0,0(s2) # 1000 <_entry-0x7ffff000>
    800007c2:	d50d                	beqz	a0,800006ec <printf+0x98>
        consputc(*s);
    800007c4:	00000097          	auipc	ra,0x0
    800007c8:	ac8080e7          	jalr	-1336(ra) # 8000028c <consputc>
      for(; *s; s++)
    800007cc:	0905                	addi	s2,s2,1
    800007ce:	00094503          	lbu	a0,0(s2)
    800007d2:	f96d                	bnez	a0,800007c4 <printf+0x170>
    800007d4:	bf21                	j	800006ec <printf+0x98>
        s = "(null)";
    800007d6:	00008917          	auipc	s2,0x8
    800007da:	88290913          	addi	s2,s2,-1918 # 80008058 <digits+0x40>
      for(; *s; s++)
    800007de:	02800513          	li	a0,40
    800007e2:	b7cd                	j	800007c4 <printf+0x170>
      consputc('%');
    800007e4:	8552                	mv	a0,s4
    800007e6:	00000097          	auipc	ra,0x0
    800007ea:	aa6080e7          	jalr	-1370(ra) # 8000028c <consputc>
      break;
    800007ee:	bdfd                	j	800006ec <printf+0x98>
      consputc('%');
    800007f0:	8552                	mv	a0,s4
    800007f2:	00000097          	auipc	ra,0x0
    800007f6:	a9a080e7          	jalr	-1382(ra) # 8000028c <consputc>
      consputc(c);
    800007fa:	854a                	mv	a0,s2
    800007fc:	00000097          	auipc	ra,0x0
    80000800:	a90080e7          	jalr	-1392(ra) # 8000028c <consputc>
      break;
    80000804:	b5e5                	j	800006ec <printf+0x98>
  if(locking)
    80000806:	020d9163          	bnez	s11,80000828 <printf+0x1d4>
}
    8000080a:	70e6                	ld	ra,120(sp)
    8000080c:	7446                	ld	s0,112(sp)
    8000080e:	74a6                	ld	s1,104(sp)
    80000810:	7906                	ld	s2,96(sp)
    80000812:	69e6                	ld	s3,88(sp)
    80000814:	6a46                	ld	s4,80(sp)
    80000816:	6aa6                	ld	s5,72(sp)
    80000818:	6b06                	ld	s6,64(sp)
    8000081a:	7be2                	ld	s7,56(sp)
    8000081c:	7c42                	ld	s8,48(sp)
    8000081e:	7ca2                	ld	s9,40(sp)
    80000820:	7d02                	ld	s10,32(sp)
    80000822:	6de2                	ld	s11,24(sp)
    80000824:	6129                	addi	sp,sp,192
    80000826:	8082                	ret
    release(&pr.lock);
    80000828:	00011517          	auipc	a0,0x11
    8000082c:	0b050513          	addi	a0,a0,176 # 800118d8 <pr>
    80000830:	00000097          	auipc	ra,0x0
    80000834:	54a080e7          	jalr	1354(ra) # 80000d7a <release>
}
    80000838:	bfc9                	j	8000080a <printf+0x1b6>

000000008000083a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000083a:	1141                	addi	sp,sp,-16
    8000083c:	e406                	sd	ra,8(sp)
    8000083e:	e022                	sd	s0,0(sp)
    80000840:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000842:	100007b7          	lui	a5,0x10000
    80000846:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000084a:	f8000713          	li	a4,-128
    8000084e:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000852:	470d                	li	a4,3
    80000854:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000858:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000085c:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000860:	469d                	li	a3,7
    80000862:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000866:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000086a:	00008597          	auipc	a1,0x8
    8000086e:	80658593          	addi	a1,a1,-2042 # 80008070 <digits+0x58>
    80000872:	00011517          	auipc	a0,0x11
    80000876:	08650513          	addi	a0,a0,134 # 800118f8 <uart_tx_lock>
    8000087a:	00000097          	auipc	ra,0x0
    8000087e:	3bc080e7          	jalr	956(ra) # 80000c36 <initlock>
}
    80000882:	60a2                	ld	ra,8(sp)
    80000884:	6402                	ld	s0,0(sp)
    80000886:	0141                	addi	sp,sp,16
    80000888:	8082                	ret

000000008000088a <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000088a:	1101                	addi	sp,sp,-32
    8000088c:	ec06                	sd	ra,24(sp)
    8000088e:	e822                	sd	s0,16(sp)
    80000890:	e426                	sd	s1,8(sp)
    80000892:	1000                	addi	s0,sp,32
    80000894:	84aa                	mv	s1,a0
  push_off();
    80000896:	00000097          	auipc	ra,0x0
    8000089a:	3e4080e7          	jalr	996(ra) # 80000c7a <push_off>

  if(panicked){
    8000089e:	00008797          	auipc	a5,0x8
    800008a2:	76278793          	addi	a5,a5,1890 # 80009000 <panicked>
    800008a6:	439c                	lw	a5,0(a5)
    800008a8:	2781                	sext.w	a5,a5
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800008aa:	10000737          	lui	a4,0x10000
  if(panicked){
    800008ae:	c391                	beqz	a5,800008b2 <uartputc_sync+0x28>
    for(;;)
    800008b0:	a001                	j	800008b0 <uartputc_sync+0x26>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800008b2:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800008b6:	0ff7f793          	andi	a5,a5,255
    800008ba:	0207f793          	andi	a5,a5,32
    800008be:	dbf5                	beqz	a5,800008b2 <uartputc_sync+0x28>
    ;
  WriteReg(THR, c);
    800008c0:	0ff4f793          	andi	a5,s1,255
    800008c4:	10000737          	lui	a4,0x10000
    800008c8:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    800008cc:	00000097          	auipc	ra,0x0
    800008d0:	44e080e7          	jalr	1102(ra) # 80000d1a <pop_off>
}
    800008d4:	60e2                	ld	ra,24(sp)
    800008d6:	6442                	ld	s0,16(sp)
    800008d8:	64a2                	ld	s1,8(sp)
    800008da:	6105                	addi	sp,sp,32
    800008dc:	8082                	ret

00000000800008de <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	72678793          	addi	a5,a5,1830 # 80009004 <uart_tx_r>
    800008e6:	439c                	lw	a5,0(a5)
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	72070713          	addi	a4,a4,1824 # 80009008 <uart_tx_w>
    800008f0:	4318                	lw	a4,0(a4)
    800008f2:	08f70b63          	beq	a4,a5,80000988 <uartstart+0xaa>
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008f6:	10000737          	lui	a4,0x10000
    800008fa:	00574703          	lbu	a4,5(a4) # 10000005 <_entry-0x6ffffffb>
    800008fe:	0ff77713          	andi	a4,a4,255
    80000902:	02077713          	andi	a4,a4,32
    80000906:	c349                	beqz	a4,80000988 <uartstart+0xaa>
{
    80000908:	7139                	addi	sp,sp,-64
    8000090a:	fc06                	sd	ra,56(sp)
    8000090c:	f822                	sd	s0,48(sp)
    8000090e:	f426                	sd	s1,40(sp)
    80000910:	f04a                	sd	s2,32(sp)
    80000912:	ec4e                	sd	s3,24(sp)
    80000914:	e852                	sd	s4,16(sp)
    80000916:	e456                	sd	s5,8(sp)
    80000918:	0080                	addi	s0,sp,64
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    8000091a:	00011a17          	auipc	s4,0x11
    8000091e:	fdea0a13          	addi	s4,s4,-34 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    80000922:	00008497          	auipc	s1,0x8
    80000926:	6e248493          	addi	s1,s1,1762 # 80009004 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    8000092a:	10000937          	lui	s2,0x10000
    if(uart_tx_w == uart_tx_r){
    8000092e:	00008997          	auipc	s3,0x8
    80000932:	6da98993          	addi	s3,s3,1754 # 80009008 <uart_tx_w>
    int c = uart_tx_buf[uart_tx_r];
    80000936:	00fa0733          	add	a4,s4,a5
    8000093a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000093e:	2785                	addiw	a5,a5,1
    80000940:	41f7d71b          	sraiw	a4,a5,0x1f
    80000944:	01b7571b          	srliw	a4,a4,0x1b
    80000948:	9fb9                	addw	a5,a5,a4
    8000094a:	8bfd                	andi	a5,a5,31
    8000094c:	9f99                	subw	a5,a5,a4
    8000094e:	c09c                	sw	a5,0(s1)
    wakeup(&uart_tx_r);
    80000950:	8526                	mv	a0,s1
    80000952:	00002097          	auipc	ra,0x2
    80000956:	b48080e7          	jalr	-1208(ra) # 8000249a <wakeup>
    WriteReg(THR, c);
    8000095a:	01590023          	sb	s5,0(s2) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    8000095e:	409c                	lw	a5,0(s1)
    80000960:	0009a703          	lw	a4,0(s3)
    80000964:	00f70963          	beq	a4,a5,80000976 <uartstart+0x98>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000968:	00594703          	lbu	a4,5(s2)
    8000096c:	0ff77713          	andi	a4,a4,255
    80000970:	02077713          	andi	a4,a4,32
    80000974:	f369                	bnez	a4,80000936 <uartstart+0x58>
  }
}
    80000976:	70e2                	ld	ra,56(sp)
    80000978:	7442                	ld	s0,48(sp)
    8000097a:	74a2                	ld	s1,40(sp)
    8000097c:	7902                	ld	s2,32(sp)
    8000097e:	69e2                	ld	s3,24(sp)
    80000980:	6a42                	ld	s4,16(sp)
    80000982:	6aa2                	ld	s5,8(sp)
    80000984:	6121                	addi	sp,sp,64
    80000986:	8082                	ret
    80000988:	8082                	ret

000000008000098a <uartputc>:
{
    8000098a:	7179                	addi	sp,sp,-48
    8000098c:	f406                	sd	ra,40(sp)
    8000098e:	f022                	sd	s0,32(sp)
    80000990:	ec26                	sd	s1,24(sp)
    80000992:	e84a                	sd	s2,16(sp)
    80000994:	e44e                	sd	s3,8(sp)
    80000996:	e052                	sd	s4,0(sp)
    80000998:	1800                	addi	s0,sp,48
    8000099a:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    8000099c:	00011517          	auipc	a0,0x11
    800009a0:	f5c50513          	addi	a0,a0,-164 # 800118f8 <uart_tx_lock>
    800009a4:	00000097          	auipc	ra,0x0
    800009a8:	322080e7          	jalr	802(ra) # 80000cc6 <acquire>
  if(panicked){
    800009ac:	00008797          	auipc	a5,0x8
    800009b0:	65478793          	addi	a5,a5,1620 # 80009000 <panicked>
    800009b4:	439c                	lw	a5,0(a5)
    800009b6:	2781                	sext.w	a5,a5
    800009b8:	c391                	beqz	a5,800009bc <uartputc+0x32>
    for(;;)
    800009ba:	a001                	j	800009ba <uartputc+0x30>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800009bc:	00008797          	auipc	a5,0x8
    800009c0:	64c78793          	addi	a5,a5,1612 # 80009008 <uart_tx_w>
    800009c4:	4398                	lw	a4,0(a5)
    800009c6:	0017079b          	addiw	a5,a4,1
    800009ca:	41f7d69b          	sraiw	a3,a5,0x1f
    800009ce:	01b6d69b          	srliw	a3,a3,0x1b
    800009d2:	9fb5                	addw	a5,a5,a3
    800009d4:	8bfd                	andi	a5,a5,31
    800009d6:	9f95                	subw	a5,a5,a3
    800009d8:	00008697          	auipc	a3,0x8
    800009dc:	62c68693          	addi	a3,a3,1580 # 80009004 <uart_tx_r>
    800009e0:	4294                	lw	a3,0(a3)
    800009e2:	04f69263          	bne	a3,a5,80000a26 <uartputc+0x9c>
      sleep(&uart_tx_r, &uart_tx_lock);
    800009e6:	00011a17          	auipc	s4,0x11
    800009ea:	f12a0a13          	addi	s4,s4,-238 # 800118f8 <uart_tx_lock>
    800009ee:	00008497          	auipc	s1,0x8
    800009f2:	61648493          	addi	s1,s1,1558 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800009f6:	00008917          	auipc	s2,0x8
    800009fa:	61290913          	addi	s2,s2,1554 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    800009fe:	85d2                	mv	a1,s4
    80000a00:	8526                	mv	a0,s1
    80000a02:	00002097          	auipc	ra,0x2
    80000a06:	912080e7          	jalr	-1774(ra) # 80002314 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000a0a:	00092703          	lw	a4,0(s2)
    80000a0e:	0017079b          	addiw	a5,a4,1
    80000a12:	41f7d69b          	sraiw	a3,a5,0x1f
    80000a16:	01b6d69b          	srliw	a3,a3,0x1b
    80000a1a:	9fb5                	addw	a5,a5,a3
    80000a1c:	8bfd                	andi	a5,a5,31
    80000a1e:	9f95                	subw	a5,a5,a3
    80000a20:	4094                	lw	a3,0(s1)
    80000a22:	fcf68ee3          	beq	a3,a5,800009fe <uartputc+0x74>
      uart_tx_buf[uart_tx_w] = c;
    80000a26:	00011497          	auipc	s1,0x11
    80000a2a:	ed248493          	addi	s1,s1,-302 # 800118f8 <uart_tx_lock>
    80000a2e:	9726                	add	a4,a4,s1
    80000a30:	01370c23          	sb	s3,24(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000a34:	00008717          	auipc	a4,0x8
    80000a38:	5cf72a23          	sw	a5,1492(a4) # 80009008 <uart_tx_w>
      uartstart();
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	ea2080e7          	jalr	-350(ra) # 800008de <uartstart>
      release(&uart_tx_lock);
    80000a44:	8526                	mv	a0,s1
    80000a46:	00000097          	auipc	ra,0x0
    80000a4a:	334080e7          	jalr	820(ra) # 80000d7a <release>
}
    80000a4e:	70a2                	ld	ra,40(sp)
    80000a50:	7402                	ld	s0,32(sp)
    80000a52:	64e2                	ld	s1,24(sp)
    80000a54:	6942                	ld	s2,16(sp)
    80000a56:	69a2                	ld	s3,8(sp)
    80000a58:	6a02                	ld	s4,0(sp)
    80000a5a:	6145                	addi	sp,sp,48
    80000a5c:	8082                	ret

0000000080000a5e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000a5e:	1141                	addi	sp,sp,-16
    80000a60:	e422                	sd	s0,8(sp)
    80000a62:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000a64:	100007b7          	lui	a5,0x10000
    80000a68:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a6c:	8b85                	andi	a5,a5,1
    80000a6e:	cb91                	beqz	a5,80000a82 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000a70:	100007b7          	lui	a5,0x10000
    80000a74:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000a78:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000a7c:	6422                	ld	s0,8(sp)
    80000a7e:	0141                	addi	sp,sp,16
    80000a80:	8082                	ret
    return -1;
    80000a82:	557d                	li	a0,-1
    80000a84:	bfe5                	j	80000a7c <uartgetc+0x1e>

0000000080000a86 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000a86:	1101                	addi	sp,sp,-32
    80000a88:	ec06                	sd	ra,24(sp)
    80000a8a:	e822                	sd	s0,16(sp)
    80000a8c:	e426                	sd	s1,8(sp)
    80000a8e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a90:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a92:	00000097          	auipc	ra,0x0
    80000a96:	fcc080e7          	jalr	-52(ra) # 80000a5e <uartgetc>
    if(c == -1)
    80000a9a:	00950763          	beq	a0,s1,80000aa8 <uartintr+0x22>
      break;
    consoleintr(c);
    80000a9e:	00000097          	auipc	ra,0x0
    80000aa2:	830080e7          	jalr	-2000(ra) # 800002ce <consoleintr>
  while(1){
    80000aa6:	b7f5                	j	80000a92 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000aa8:	00011497          	auipc	s1,0x11
    80000aac:	e5048493          	addi	s1,s1,-432 # 800118f8 <uart_tx_lock>
    80000ab0:	8526                	mv	a0,s1
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	214080e7          	jalr	532(ra) # 80000cc6 <acquire>
  uartstart();
    80000aba:	00000097          	auipc	ra,0x0
    80000abe:	e24080e7          	jalr	-476(ra) # 800008de <uartstart>
  release(&uart_tx_lock);
    80000ac2:	8526                	mv	a0,s1
    80000ac4:	00000097          	auipc	ra,0x0
    80000ac8:	2b6080e7          	jalr	694(ra) # 80000d7a <release>
}
    80000acc:	60e2                	ld	ra,24(sp)
    80000ace:	6442                	ld	s0,16(sp)
    80000ad0:	64a2                	ld	s1,8(sp)
    80000ad2:	6105                	addi	sp,sp,32
    80000ad4:	8082                	ret

0000000080000ad6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000ad6:	1101                	addi	sp,sp,-32
    80000ad8:	ec06                	sd	ra,24(sp)
    80000ada:	e822                	sd	s0,16(sp)
    80000adc:	e426                	sd	s1,8(sp)
    80000ade:	e04a                	sd	s2,0(sp)
    80000ae0:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000ae2:	6785                	lui	a5,0x1
    80000ae4:	17fd                	addi	a5,a5,-1
    80000ae6:	8fe9                	and	a5,a5,a0
    80000ae8:	ebb9                	bnez	a5,80000b3e <kfree+0x68>
    80000aea:	84aa                	mv	s1,a0
    80000aec:	00026797          	auipc	a5,0x26
    80000af0:	51478793          	addi	a5,a5,1300 # 80027000 <end>
    80000af4:	04f56563          	bltu	a0,a5,80000b3e <kfree+0x68>
    80000af8:	47c5                	li	a5,17
    80000afa:	07ee                	slli	a5,a5,0x1b
    80000afc:	04f57163          	bleu	a5,a0,80000b3e <kfree+0x68>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000b00:	6605                	lui	a2,0x1
    80000b02:	4585                	li	a1,1
    80000b04:	00000097          	auipc	ra,0x0
    80000b08:	2be080e7          	jalr	702(ra) # 80000dc2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000b0c:	00011917          	auipc	s2,0x11
    80000b10:	e2490913          	addi	s2,s2,-476 # 80011930 <kmem>
    80000b14:	854a                	mv	a0,s2
    80000b16:	00000097          	auipc	ra,0x0
    80000b1a:	1b0080e7          	jalr	432(ra) # 80000cc6 <acquire>
  r->next = kmem.freelist;
    80000b1e:	01893783          	ld	a5,24(s2)
    80000b22:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000b24:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000b28:	854a                	mv	a0,s2
    80000b2a:	00000097          	auipc	ra,0x0
    80000b2e:	250080e7          	jalr	592(ra) # 80000d7a <release>
}
    80000b32:	60e2                	ld	ra,24(sp)
    80000b34:	6442                	ld	s0,16(sp)
    80000b36:	64a2                	ld	s1,8(sp)
    80000b38:	6902                	ld	s2,0(sp)
    80000b3a:	6105                	addi	sp,sp,32
    80000b3c:	8082                	ret
    panic("kfree");
    80000b3e:	00007517          	auipc	a0,0x7
    80000b42:	53a50513          	addi	a0,a0,1338 # 80008078 <digits+0x60>
    80000b46:	00000097          	auipc	ra,0x0
    80000b4a:	abc080e7          	jalr	-1348(ra) # 80000602 <panic>

0000000080000b4e <freerange>:
{
    80000b4e:	7179                	addi	sp,sp,-48
    80000b50:	f406                	sd	ra,40(sp)
    80000b52:	f022                	sd	s0,32(sp)
    80000b54:	ec26                	sd	s1,24(sp)
    80000b56:	e84a                	sd	s2,16(sp)
    80000b58:	e44e                	sd	s3,8(sp)
    80000b5a:	e052                	sd	s4,0(sp)
    80000b5c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b5e:	6705                	lui	a4,0x1
    80000b60:	fff70793          	addi	a5,a4,-1 # fff <_entry-0x7ffff001>
    80000b64:	00f504b3          	add	s1,a0,a5
    80000b68:	77fd                	lui	a5,0xfffff
    80000b6a:	8cfd                	and	s1,s1,a5
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b6c:	94ba                	add	s1,s1,a4
    80000b6e:	0095ee63          	bltu	a1,s1,80000b8a <freerange+0x3c>
    80000b72:	892e                	mv	s2,a1
    kfree(p);
    80000b74:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b76:	6985                	lui	s3,0x1
    kfree(p);
    80000b78:	01448533          	add	a0,s1,s4
    80000b7c:	00000097          	auipc	ra,0x0
    80000b80:	f5a080e7          	jalr	-166(ra) # 80000ad6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b84:	94ce                	add	s1,s1,s3
    80000b86:	fe9979e3          	bleu	s1,s2,80000b78 <freerange+0x2a>
}
    80000b8a:	70a2                	ld	ra,40(sp)
    80000b8c:	7402                	ld	s0,32(sp)
    80000b8e:	64e2                	ld	s1,24(sp)
    80000b90:	6942                	ld	s2,16(sp)
    80000b92:	69a2                	ld	s3,8(sp)
    80000b94:	6a02                	ld	s4,0(sp)
    80000b96:	6145                	addi	sp,sp,48
    80000b98:	8082                	ret

0000000080000b9a <kinit>:
{
    80000b9a:	1141                	addi	sp,sp,-16
    80000b9c:	e406                	sd	ra,8(sp)
    80000b9e:	e022                	sd	s0,0(sp)
    80000ba0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ba2:	00007597          	auipc	a1,0x7
    80000ba6:	4de58593          	addi	a1,a1,1246 # 80008080 <digits+0x68>
    80000baa:	00011517          	auipc	a0,0x11
    80000bae:	d8650513          	addi	a0,a0,-634 # 80011930 <kmem>
    80000bb2:	00000097          	auipc	ra,0x0
    80000bb6:	084080e7          	jalr	132(ra) # 80000c36 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000bba:	45c5                	li	a1,17
    80000bbc:	05ee                	slli	a1,a1,0x1b
    80000bbe:	00026517          	auipc	a0,0x26
    80000bc2:	44250513          	addi	a0,a0,1090 # 80027000 <end>
    80000bc6:	00000097          	auipc	ra,0x0
    80000bca:	f88080e7          	jalr	-120(ra) # 80000b4e <freerange>
}
    80000bce:	60a2                	ld	ra,8(sp)
    80000bd0:	6402                	ld	s0,0(sp)
    80000bd2:	0141                	addi	sp,sp,16
    80000bd4:	8082                	ret

0000000080000bd6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000be0:	00011497          	auipc	s1,0x11
    80000be4:	d5048493          	addi	s1,s1,-688 # 80011930 <kmem>
    80000be8:	8526                	mv	a0,s1
    80000bea:	00000097          	auipc	ra,0x0
    80000bee:	0dc080e7          	jalr	220(ra) # 80000cc6 <acquire>
  r = kmem.freelist;
    80000bf2:	6c84                	ld	s1,24(s1)
  if(r)
    80000bf4:	c885                	beqz	s1,80000c24 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000bf6:	609c                	ld	a5,0(s1)
    80000bf8:	00011517          	auipc	a0,0x11
    80000bfc:	d3850513          	addi	a0,a0,-712 # 80011930 <kmem>
    80000c00:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000c02:	00000097          	auipc	ra,0x0
    80000c06:	178080e7          	jalr	376(ra) # 80000d7a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000c0a:	6605                	lui	a2,0x1
    80000c0c:	4595                	li	a1,5
    80000c0e:	8526                	mv	a0,s1
    80000c10:	00000097          	auipc	ra,0x0
    80000c14:	1b2080e7          	jalr	434(ra) # 80000dc2 <memset>
  return (void*)r;
}
    80000c18:	8526                	mv	a0,s1
    80000c1a:	60e2                	ld	ra,24(sp)
    80000c1c:	6442                	ld	s0,16(sp)
    80000c1e:	64a2                	ld	s1,8(sp)
    80000c20:	6105                	addi	sp,sp,32
    80000c22:	8082                	ret
  release(&kmem.lock);
    80000c24:	00011517          	auipc	a0,0x11
    80000c28:	d0c50513          	addi	a0,a0,-756 # 80011930 <kmem>
    80000c2c:	00000097          	auipc	ra,0x0
    80000c30:	14e080e7          	jalr	334(ra) # 80000d7a <release>
  if(r)
    80000c34:	b7d5                	j	80000c18 <kalloc+0x42>

0000000080000c36 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c36:	1141                	addi	sp,sp,-16
    80000c38:	e422                	sd	s0,8(sp)
    80000c3a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c3c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c3e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c42:	00053823          	sd	zero,16(a0)
}
    80000c46:	6422                	ld	s0,8(sp)
    80000c48:	0141                	addi	sp,sp,16
    80000c4a:	8082                	ret

0000000080000c4c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c4c:	411c                	lw	a5,0(a0)
    80000c4e:	e399                	bnez	a5,80000c54 <holding+0x8>
    80000c50:	4501                	li	a0,0
  return r;
}
    80000c52:	8082                	ret
{
    80000c54:	1101                	addi	sp,sp,-32
    80000c56:	ec06                	sd	ra,24(sp)
    80000c58:	e822                	sd	s0,16(sp)
    80000c5a:	e426                	sd	s1,8(sp)
    80000c5c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c5e:	6904                	ld	s1,16(a0)
    80000c60:	00001097          	auipc	ra,0x1
    80000c64:	e58080e7          	jalr	-424(ra) # 80001ab8 <mycpu>
    80000c68:	40a48533          	sub	a0,s1,a0
    80000c6c:	00153513          	seqz	a0,a0
}
    80000c70:	60e2                	ld	ra,24(sp)
    80000c72:	6442                	ld	s0,16(sp)
    80000c74:	64a2                	ld	s1,8(sp)
    80000c76:	6105                	addi	sp,sp,32
    80000c78:	8082                	ret

0000000080000c7a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c7a:	1101                	addi	sp,sp,-32
    80000c7c:	ec06                	sd	ra,24(sp)
    80000c7e:	e822                	sd	s0,16(sp)
    80000c80:	e426                	sd	s1,8(sp)
    80000c82:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c84:	100024f3          	csrr	s1,sstatus
    80000c88:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c8c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c8e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c92:	00001097          	auipc	ra,0x1
    80000c96:	e26080e7          	jalr	-474(ra) # 80001ab8 <mycpu>
    80000c9a:	5d3c                	lw	a5,120(a0)
    80000c9c:	cf89                	beqz	a5,80000cb6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c9e:	00001097          	auipc	ra,0x1
    80000ca2:	e1a080e7          	jalr	-486(ra) # 80001ab8 <mycpu>
    80000ca6:	5d3c                	lw	a5,120(a0)
    80000ca8:	2785                	addiw	a5,a5,1
    80000caa:	dd3c                	sw	a5,120(a0)
}
    80000cac:	60e2                	ld	ra,24(sp)
    80000cae:	6442                	ld	s0,16(sp)
    80000cb0:	64a2                	ld	s1,8(sp)
    80000cb2:	6105                	addi	sp,sp,32
    80000cb4:	8082                	ret
    mycpu()->intena = old;
    80000cb6:	00001097          	auipc	ra,0x1
    80000cba:	e02080e7          	jalr	-510(ra) # 80001ab8 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000cbe:	8085                	srli	s1,s1,0x1
    80000cc0:	8885                	andi	s1,s1,1
    80000cc2:	dd64                	sw	s1,124(a0)
    80000cc4:	bfe9                	j	80000c9e <push_off+0x24>

0000000080000cc6 <acquire>:
{
    80000cc6:	1101                	addi	sp,sp,-32
    80000cc8:	ec06                	sd	ra,24(sp)
    80000cca:	e822                	sd	s0,16(sp)
    80000ccc:	e426                	sd	s1,8(sp)
    80000cce:	1000                	addi	s0,sp,32
    80000cd0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000cd2:	00000097          	auipc	ra,0x0
    80000cd6:	fa8080e7          	jalr	-88(ra) # 80000c7a <push_off>
  if(holding(lk))
    80000cda:	8526                	mv	a0,s1
    80000cdc:	00000097          	auipc	ra,0x0
    80000ce0:	f70080e7          	jalr	-144(ra) # 80000c4c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000ce4:	4705                	li	a4,1
  if(holding(lk))
    80000ce6:	e115                	bnez	a0,80000d0a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000ce8:	87ba                	mv	a5,a4
    80000cea:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cee:	2781                	sext.w	a5,a5
    80000cf0:	ffe5                	bnez	a5,80000ce8 <acquire+0x22>
  __sync_synchronize();
    80000cf2:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000cf6:	00001097          	auipc	ra,0x1
    80000cfa:	dc2080e7          	jalr	-574(ra) # 80001ab8 <mycpu>
    80000cfe:	e888                	sd	a0,16(s1)
}
    80000d00:	60e2                	ld	ra,24(sp)
    80000d02:	6442                	ld	s0,16(sp)
    80000d04:	64a2                	ld	s1,8(sp)
    80000d06:	6105                	addi	sp,sp,32
    80000d08:	8082                	ret
    panic("acquire");
    80000d0a:	00007517          	auipc	a0,0x7
    80000d0e:	37e50513          	addi	a0,a0,894 # 80008088 <digits+0x70>
    80000d12:	00000097          	auipc	ra,0x0
    80000d16:	8f0080e7          	jalr	-1808(ra) # 80000602 <panic>

0000000080000d1a <pop_off>:

void
pop_off(void)
{
    80000d1a:	1141                	addi	sp,sp,-16
    80000d1c:	e406                	sd	ra,8(sp)
    80000d1e:	e022                	sd	s0,0(sp)
    80000d20:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d22:	00001097          	auipc	ra,0x1
    80000d26:	d96080e7          	jalr	-618(ra) # 80001ab8 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d2a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d2e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d30:	e78d                	bnez	a5,80000d5a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d32:	5d3c                	lw	a5,120(a0)
    80000d34:	02f05b63          	blez	a5,80000d6a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d38:	37fd                	addiw	a5,a5,-1
    80000d3a:	0007871b          	sext.w	a4,a5
    80000d3e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d40:	eb09                	bnez	a4,80000d52 <pop_off+0x38>
    80000d42:	5d7c                	lw	a5,124(a0)
    80000d44:	c799                	beqz	a5,80000d52 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d46:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d4a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d4e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d52:	60a2                	ld	ra,8(sp)
    80000d54:	6402                	ld	s0,0(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
    panic("pop_off - interruptible");
    80000d5a:	00007517          	auipc	a0,0x7
    80000d5e:	33650513          	addi	a0,a0,822 # 80008090 <digits+0x78>
    80000d62:	00000097          	auipc	ra,0x0
    80000d66:	8a0080e7          	jalr	-1888(ra) # 80000602 <panic>
    panic("pop_off");
    80000d6a:	00007517          	auipc	a0,0x7
    80000d6e:	33e50513          	addi	a0,a0,830 # 800080a8 <digits+0x90>
    80000d72:	00000097          	auipc	ra,0x0
    80000d76:	890080e7          	jalr	-1904(ra) # 80000602 <panic>

0000000080000d7a <release>:
{
    80000d7a:	1101                	addi	sp,sp,-32
    80000d7c:	ec06                	sd	ra,24(sp)
    80000d7e:	e822                	sd	s0,16(sp)
    80000d80:	e426                	sd	s1,8(sp)
    80000d82:	1000                	addi	s0,sp,32
    80000d84:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	ec6080e7          	jalr	-314(ra) # 80000c4c <holding>
    80000d8e:	c115                	beqz	a0,80000db2 <release+0x38>
  lk->cpu = 0;
    80000d90:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d94:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d98:	0f50000f          	fence	iorw,ow
    80000d9c:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000da0:	00000097          	auipc	ra,0x0
    80000da4:	f7a080e7          	jalr	-134(ra) # 80000d1a <pop_off>
}
    80000da8:	60e2                	ld	ra,24(sp)
    80000daa:	6442                	ld	s0,16(sp)
    80000dac:	64a2                	ld	s1,8(sp)
    80000dae:	6105                	addi	sp,sp,32
    80000db0:	8082                	ret
    panic("release");
    80000db2:	00007517          	auipc	a0,0x7
    80000db6:	2fe50513          	addi	a0,a0,766 # 800080b0 <digits+0x98>
    80000dba:	00000097          	auipc	ra,0x0
    80000dbe:	848080e7          	jalr	-1976(ra) # 80000602 <panic>

0000000080000dc2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000dc2:	1141                	addi	sp,sp,-16
    80000dc4:	e422                	sd	s0,8(sp)
    80000dc6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000dc8:	ce09                	beqz	a2,80000de2 <memset+0x20>
    80000dca:	87aa                	mv	a5,a0
    80000dcc:	fff6071b          	addiw	a4,a2,-1
    80000dd0:	1702                	slli	a4,a4,0x20
    80000dd2:	9301                	srli	a4,a4,0x20
    80000dd4:	0705                	addi	a4,a4,1
    80000dd6:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000dd8:	00b78023          	sb	a1,0(a5) # fffffffffffff000 <end+0xffffffff7ffd8000>
  for(i = 0; i < n; i++){
    80000ddc:	0785                	addi	a5,a5,1
    80000dde:	fee79de3          	bne	a5,a4,80000dd8 <memset+0x16>
  }
  return dst;
}
    80000de2:	6422                	ld	s0,8(sp)
    80000de4:	0141                	addi	sp,sp,16
    80000de6:	8082                	ret

0000000080000de8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000de8:	1141                	addi	sp,sp,-16
    80000dea:	e422                	sd	s0,8(sp)
    80000dec:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000dee:	ce15                	beqz	a2,80000e2a <memcmp+0x42>
    80000df0:	fff6069b          	addiw	a3,a2,-1
    if(*s1 != *s2)
    80000df4:	00054783          	lbu	a5,0(a0)
    80000df8:	0005c703          	lbu	a4,0(a1)
    80000dfc:	02e79063          	bne	a5,a4,80000e1c <memcmp+0x34>
    80000e00:	1682                	slli	a3,a3,0x20
    80000e02:	9281                	srli	a3,a3,0x20
    80000e04:	0685                	addi	a3,a3,1
    80000e06:	96aa                	add	a3,a3,a0
      return *s1 - *s2;
    s1++, s2++;
    80000e08:	0505                	addi	a0,a0,1
    80000e0a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000e0c:	00d50d63          	beq	a0,a3,80000e26 <memcmp+0x3e>
    if(*s1 != *s2)
    80000e10:	00054783          	lbu	a5,0(a0)
    80000e14:	0005c703          	lbu	a4,0(a1)
    80000e18:	fee788e3          	beq	a5,a4,80000e08 <memcmp+0x20>
      return *s1 - *s2;
    80000e1c:	40e7853b          	subw	a0,a5,a4
  }

  return 0;
}
    80000e20:	6422                	ld	s0,8(sp)
    80000e22:	0141                	addi	sp,sp,16
    80000e24:	8082                	ret
  return 0;
    80000e26:	4501                	li	a0,0
    80000e28:	bfe5                	j	80000e20 <memcmp+0x38>
    80000e2a:	4501                	li	a0,0
    80000e2c:	bfd5                	j	80000e20 <memcmp+0x38>

0000000080000e2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e2e:	1141                	addi	sp,sp,-16
    80000e30:	e422                	sd	s0,8(sp)
    80000e32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e34:	00a5f963          	bleu	a0,a1,80000e46 <memmove+0x18>
    80000e38:	02061713          	slli	a4,a2,0x20
    80000e3c:	9301                	srli	a4,a4,0x20
    80000e3e:	00e587b3          	add	a5,a1,a4
    80000e42:	02f56563          	bltu	a0,a5,80000e6c <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e46:	fff6069b          	addiw	a3,a2,-1
    80000e4a:	ce11                	beqz	a2,80000e66 <memmove+0x38>
    80000e4c:	1682                	slli	a3,a3,0x20
    80000e4e:	9281                	srli	a3,a3,0x20
    80000e50:	0685                	addi	a3,a3,1
    80000e52:	96ae                	add	a3,a3,a1
    80000e54:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000e56:	0585                	addi	a1,a1,1
    80000e58:	0785                	addi	a5,a5,1
    80000e5a:	fff5c703          	lbu	a4,-1(a1)
    80000e5e:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000e62:	fed59ae3          	bne	a1,a3,80000e56 <memmove+0x28>

  return dst;
}
    80000e66:	6422                	ld	s0,8(sp)
    80000e68:	0141                	addi	sp,sp,16
    80000e6a:	8082                	ret
    d += n;
    80000e6c:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000e6e:	fff6069b          	addiw	a3,a2,-1
    80000e72:	da75                	beqz	a2,80000e66 <memmove+0x38>
    80000e74:	02069613          	slli	a2,a3,0x20
    80000e78:	9201                	srli	a2,a2,0x20
    80000e7a:	fff64613          	not	a2,a2
    80000e7e:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e80:	17fd                	addi	a5,a5,-1
    80000e82:	177d                	addi	a4,a4,-1
    80000e84:	0007c683          	lbu	a3,0(a5)
    80000e88:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e8c:	fef61ae3          	bne	a2,a5,80000e80 <memmove+0x52>
    80000e90:	bfd9                	j	80000e66 <memmove+0x38>

0000000080000e92 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e92:	1141                	addi	sp,sp,-16
    80000e94:	e406                	sd	ra,8(sp)
    80000e96:	e022                	sd	s0,0(sp)
    80000e98:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e9a:	00000097          	auipc	ra,0x0
    80000e9e:	f94080e7          	jalr	-108(ra) # 80000e2e <memmove>
}
    80000ea2:	60a2                	ld	ra,8(sp)
    80000ea4:	6402                	ld	s0,0(sp)
    80000ea6:	0141                	addi	sp,sp,16
    80000ea8:	8082                	ret

0000000080000eaa <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000eaa:	1141                	addi	sp,sp,-16
    80000eac:	e422                	sd	s0,8(sp)
    80000eae:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000eb0:	c229                	beqz	a2,80000ef2 <strncmp+0x48>
    80000eb2:	00054783          	lbu	a5,0(a0)
    80000eb6:	c795                	beqz	a5,80000ee2 <strncmp+0x38>
    80000eb8:	0005c703          	lbu	a4,0(a1)
    80000ebc:	02f71363          	bne	a4,a5,80000ee2 <strncmp+0x38>
    80000ec0:	fff6071b          	addiw	a4,a2,-1
    80000ec4:	1702                	slli	a4,a4,0x20
    80000ec6:	9301                	srli	a4,a4,0x20
    80000ec8:	0705                	addi	a4,a4,1
    80000eca:	972a                	add	a4,a4,a0
    n--, p++, q++;
    80000ecc:	0505                	addi	a0,a0,1
    80000ece:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000ed0:	02e50363          	beq	a0,a4,80000ef6 <strncmp+0x4c>
    80000ed4:	00054783          	lbu	a5,0(a0)
    80000ed8:	c789                	beqz	a5,80000ee2 <strncmp+0x38>
    80000eda:	0005c683          	lbu	a3,0(a1)
    80000ede:	fef687e3          	beq	a3,a5,80000ecc <strncmp+0x22>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
    80000ee2:	00054503          	lbu	a0,0(a0)
    80000ee6:	0005c783          	lbu	a5,0(a1)
    80000eea:	9d1d                	subw	a0,a0,a5
}
    80000eec:	6422                	ld	s0,8(sp)
    80000eee:	0141                	addi	sp,sp,16
    80000ef0:	8082                	ret
    return 0;
    80000ef2:	4501                	li	a0,0
    80000ef4:	bfe5                	j	80000eec <strncmp+0x42>
    80000ef6:	4501                	li	a0,0
    80000ef8:	bfd5                	j	80000eec <strncmp+0x42>

0000000080000efa <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000efa:	1141                	addi	sp,sp,-16
    80000efc:	e422                	sd	s0,8(sp)
    80000efe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000f00:	872a                	mv	a4,a0
    80000f02:	a011                	j	80000f06 <strncpy+0xc>
    80000f04:	8636                	mv	a2,a3
    80000f06:	fff6069b          	addiw	a3,a2,-1
    80000f0a:	00c05963          	blez	a2,80000f1c <strncpy+0x22>
    80000f0e:	0705                	addi	a4,a4,1
    80000f10:	0005c783          	lbu	a5,0(a1)
    80000f14:	fef70fa3          	sb	a5,-1(a4)
    80000f18:	0585                	addi	a1,a1,1
    80000f1a:	f7ed                	bnez	a5,80000f04 <strncpy+0xa>
    ;
  while(n-- > 0)
    80000f1c:	00d05c63          	blez	a3,80000f34 <strncpy+0x3a>
    80000f20:	86ba                	mv	a3,a4
    *s++ = 0;
    80000f22:	0685                	addi	a3,a3,1
    80000f24:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000f28:	fff6c793          	not	a5,a3
    80000f2c:	9fb9                	addw	a5,a5,a4
    80000f2e:	9fb1                	addw	a5,a5,a2
    80000f30:	fef049e3          	bgtz	a5,80000f22 <strncpy+0x28>
  return os;
}
    80000f34:	6422                	ld	s0,8(sp)
    80000f36:	0141                	addi	sp,sp,16
    80000f38:	8082                	ret

0000000080000f3a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f3a:	1141                	addi	sp,sp,-16
    80000f3c:	e422                	sd	s0,8(sp)
    80000f3e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f40:	02c05363          	blez	a2,80000f66 <safestrcpy+0x2c>
    80000f44:	fff6069b          	addiw	a3,a2,-1
    80000f48:	1682                	slli	a3,a3,0x20
    80000f4a:	9281                	srli	a3,a3,0x20
    80000f4c:	96ae                	add	a3,a3,a1
    80000f4e:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f50:	00d58963          	beq	a1,a3,80000f62 <safestrcpy+0x28>
    80000f54:	0585                	addi	a1,a1,1
    80000f56:	0785                	addi	a5,a5,1
    80000f58:	fff5c703          	lbu	a4,-1(a1)
    80000f5c:	fee78fa3          	sb	a4,-1(a5)
    80000f60:	fb65                	bnez	a4,80000f50 <safestrcpy+0x16>
    ;
  *s = 0;
    80000f62:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f66:	6422                	ld	s0,8(sp)
    80000f68:	0141                	addi	sp,sp,16
    80000f6a:	8082                	ret

0000000080000f6c <strlen>:

int
strlen(const char *s)
{
    80000f6c:	1141                	addi	sp,sp,-16
    80000f6e:	e422                	sd	s0,8(sp)
    80000f70:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f72:	00054783          	lbu	a5,0(a0)
    80000f76:	cf91                	beqz	a5,80000f92 <strlen+0x26>
    80000f78:	0505                	addi	a0,a0,1
    80000f7a:	87aa                	mv	a5,a0
    80000f7c:	4685                	li	a3,1
    80000f7e:	9e89                	subw	a3,a3,a0
    80000f80:	00f6853b          	addw	a0,a3,a5
    80000f84:	0785                	addi	a5,a5,1
    80000f86:	fff7c703          	lbu	a4,-1(a5)
    80000f8a:	fb7d                	bnez	a4,80000f80 <strlen+0x14>
    ;
  return n;
}
    80000f8c:	6422                	ld	s0,8(sp)
    80000f8e:	0141                	addi	sp,sp,16
    80000f90:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f92:	4501                	li	a0,0
    80000f94:	bfe5                	j	80000f8c <strlen+0x20>

0000000080000f96 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f96:	1141                	addi	sp,sp,-16
    80000f98:	e406                	sd	ra,8(sp)
    80000f9a:	e022                	sd	s0,0(sp)
    80000f9c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f9e:	00001097          	auipc	ra,0x1
    80000fa2:	b0a080e7          	jalr	-1270(ra) # 80001aa8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000fa6:	00008717          	auipc	a4,0x8
    80000faa:	06670713          	addi	a4,a4,102 # 8000900c <started>
  if(cpuid() == 0){
    80000fae:	c139                	beqz	a0,80000ff4 <main+0x5e>
    while(started == 0)
    80000fb0:	431c                	lw	a5,0(a4)
    80000fb2:	2781                	sext.w	a5,a5
    80000fb4:	dff5                	beqz	a5,80000fb0 <main+0x1a>
      ;
    __sync_synchronize();
    80000fb6:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000fba:	00001097          	auipc	ra,0x1
    80000fbe:	aee080e7          	jalr	-1298(ra) # 80001aa8 <cpuid>
    80000fc2:	85aa                	mv	a1,a0
    80000fc4:	00007517          	auipc	a0,0x7
    80000fc8:	10c50513          	addi	a0,a0,268 # 800080d0 <digits+0xb8>
    80000fcc:	fffff097          	auipc	ra,0xfffff
    80000fd0:	688080e7          	jalr	1672(ra) # 80000654 <printf>
    kvminithart();    // turn on paging
    80000fd4:	00000097          	auipc	ra,0x0
    80000fd8:	0d8080e7          	jalr	216(ra) # 800010ac <kvminithart>
    trapinithart();   // install kernel trap vector
    80000fdc:	00001097          	auipc	ra,0x1
    80000fe0:	788080e7          	jalr	1928(ra) # 80002764 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000fe4:	00005097          	auipc	ra,0x5
    80000fe8:	efc080e7          	jalr	-260(ra) # 80005ee0 <plicinithart>
  }

  scheduler();        
    80000fec:	00001097          	auipc	ra,0x1
    80000ff0:	048080e7          	jalr	72(ra) # 80002034 <scheduler>
    consoleinit();
    80000ff4:	fffff097          	auipc	ra,0xfffff
    80000ff8:	48e080e7          	jalr	1166(ra) # 80000482 <consoleinit>
    printfinit();
    80000ffc:	fffff097          	auipc	ra,0xfffff
    80001000:	578080e7          	jalr	1400(ra) # 80000574 <printfinit>
    printf("\n");
    80001004:	00007517          	auipc	a0,0x7
    80001008:	0dc50513          	addi	a0,a0,220 # 800080e0 <digits+0xc8>
    8000100c:	fffff097          	auipc	ra,0xfffff
    80001010:	648080e7          	jalr	1608(ra) # 80000654 <printf>
    printf("xv6 kernel is booting\n");
    80001014:	00007517          	auipc	a0,0x7
    80001018:	0a450513          	addi	a0,a0,164 # 800080b8 <digits+0xa0>
    8000101c:	fffff097          	auipc	ra,0xfffff
    80001020:	638080e7          	jalr	1592(ra) # 80000654 <printf>
    printf("\n");
    80001024:	00007517          	auipc	a0,0x7
    80001028:	0bc50513          	addi	a0,a0,188 # 800080e0 <digits+0xc8>
    8000102c:	fffff097          	auipc	ra,0xfffff
    80001030:	628080e7          	jalr	1576(ra) # 80000654 <printf>
    kinit();         // physical page allocator
    80001034:	00000097          	auipc	ra,0x0
    80001038:	b66080e7          	jalr	-1178(ra) # 80000b9a <kinit>
    kvminit();       // create kernel page table
    8000103c:	00000097          	auipc	ra,0x0
    80001040:	2a6080e7          	jalr	678(ra) # 800012e2 <kvminit>
    kvminithart();   // turn on paging
    80001044:	00000097          	auipc	ra,0x0
    80001048:	068080e7          	jalr	104(ra) # 800010ac <kvminithart>
    procinit();      // process table
    8000104c:	00001097          	auipc	ra,0x1
    80001050:	98c080e7          	jalr	-1652(ra) # 800019d8 <procinit>
    trapinit();      // trap vectors
    80001054:	00001097          	auipc	ra,0x1
    80001058:	6e8080e7          	jalr	1768(ra) # 8000273c <trapinit>
    trapinithart();  // install kernel trap vector
    8000105c:	00001097          	auipc	ra,0x1
    80001060:	708080e7          	jalr	1800(ra) # 80002764 <trapinithart>
    plicinit();      // set up interrupt controller
    80001064:	00005097          	auipc	ra,0x5
    80001068:	e66080e7          	jalr	-410(ra) # 80005eca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000106c:	00005097          	auipc	ra,0x5
    80001070:	e74080e7          	jalr	-396(ra) # 80005ee0 <plicinithart>
    binit();         // buffer cache
    80001074:	00002097          	auipc	ra,0x2
    80001078:	ea2080e7          	jalr	-350(ra) # 80002f16 <binit>
    iinit();         // inode cache
    8000107c:	00002097          	auipc	ra,0x2
    80001080:	574080e7          	jalr	1396(ra) # 800035f0 <iinit>
    fileinit();      // file table
    80001084:	00003097          	auipc	ra,0x3
    80001088:	53a080e7          	jalr	1338(ra) # 800045be <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000108c:	00005097          	auipc	ra,0x5
    80001090:	f5e080e7          	jalr	-162(ra) # 80005fea <virtio_disk_init>
    userinit();      // first user process
    80001094:	00001097          	auipc	ra,0x1
    80001098:	d36080e7          	jalr	-714(ra) # 80001dca <userinit>
    __sync_synchronize();
    8000109c:	0ff0000f          	fence
    started = 1;
    800010a0:	4785                	li	a5,1
    800010a2:	00008717          	auipc	a4,0x8
    800010a6:	f6f72523          	sw	a5,-150(a4) # 8000900c <started>
    800010aa:	b789                	j	80000fec <main+0x56>

00000000800010ac <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800010ac:	1141                	addi	sp,sp,-16
    800010ae:	e422                	sd	s0,8(sp)
    800010b0:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    800010b2:	00008797          	auipc	a5,0x8
    800010b6:	f5e78793          	addi	a5,a5,-162 # 80009010 <kernel_pagetable>
    800010ba:	639c                	ld	a5,0(a5)
    800010bc:	83b1                	srli	a5,a5,0xc
    800010be:	577d                	li	a4,-1
    800010c0:	177e                	slli	a4,a4,0x3f
    800010c2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800010c4:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800010c8:	12000073          	sfence.vma
  sfence_vma();
}
    800010cc:	6422                	ld	s0,8(sp)
    800010ce:	0141                	addi	sp,sp,16
    800010d0:	8082                	ret

00000000800010d2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800010d2:	7139                	addi	sp,sp,-64
    800010d4:	fc06                	sd	ra,56(sp)
    800010d6:	f822                	sd	s0,48(sp)
    800010d8:	f426                	sd	s1,40(sp)
    800010da:	f04a                	sd	s2,32(sp)
    800010dc:	ec4e                	sd	s3,24(sp)
    800010de:	e852                	sd	s4,16(sp)
    800010e0:	e456                	sd	s5,8(sp)
    800010e2:	e05a                	sd	s6,0(sp)
    800010e4:	0080                	addi	s0,sp,64
    800010e6:	84aa                	mv	s1,a0
    800010e8:	89ae                	mv	s3,a1
    800010ea:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    800010ec:	57fd                	li	a5,-1
    800010ee:	83e9                	srli	a5,a5,0x1a
    800010f0:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800010f2:	4ab1                	li	s5,12
  if(va >= MAXVA)
    800010f4:	04b7f263          	bleu	a1,a5,80001138 <walk+0x66>
    panic("walk");
    800010f8:	00007517          	auipc	a0,0x7
    800010fc:	ff050513          	addi	a0,a0,-16 # 800080e8 <digits+0xd0>
    80001100:	fffff097          	auipc	ra,0xfffff
    80001104:	502080e7          	jalr	1282(ra) # 80000602 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001108:	060b0663          	beqz	s6,80001174 <walk+0xa2>
    8000110c:	00000097          	auipc	ra,0x0
    80001110:	aca080e7          	jalr	-1334(ra) # 80000bd6 <kalloc>
    80001114:	84aa                	mv	s1,a0
    80001116:	c529                	beqz	a0,80001160 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001118:	6605                	lui	a2,0x1
    8000111a:	4581                	li	a1,0
    8000111c:	00000097          	auipc	ra,0x0
    80001120:	ca6080e7          	jalr	-858(ra) # 80000dc2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001124:	00c4d793          	srli	a5,s1,0xc
    80001128:	07aa                	slli	a5,a5,0xa
    8000112a:	0017e793          	ori	a5,a5,1
    8000112e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001132:	3a5d                	addiw	s4,s4,-9
    80001134:	035a0063          	beq	s4,s5,80001154 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001138:	0149d933          	srl	s2,s3,s4
    8000113c:	1ff97913          	andi	s2,s2,511
    80001140:	090e                	slli	s2,s2,0x3
    80001142:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001144:	00093483          	ld	s1,0(s2)
    80001148:	0014f793          	andi	a5,s1,1
    8000114c:	dfd5                	beqz	a5,80001108 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000114e:	80a9                	srli	s1,s1,0xa
    80001150:	04b2                	slli	s1,s1,0xc
    80001152:	b7c5                	j	80001132 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001154:	00c9d513          	srli	a0,s3,0xc
    80001158:	1ff57513          	andi	a0,a0,511
    8000115c:	050e                	slli	a0,a0,0x3
    8000115e:	9526                	add	a0,a0,s1
}
    80001160:	70e2                	ld	ra,56(sp)
    80001162:	7442                	ld	s0,48(sp)
    80001164:	74a2                	ld	s1,40(sp)
    80001166:	7902                	ld	s2,32(sp)
    80001168:	69e2                	ld	s3,24(sp)
    8000116a:	6a42                	ld	s4,16(sp)
    8000116c:	6aa2                	ld	s5,8(sp)
    8000116e:	6b02                	ld	s6,0(sp)
    80001170:	6121                	addi	sp,sp,64
    80001172:	8082                	ret
        return 0;
    80001174:	4501                	li	a0,0
    80001176:	b7ed                	j	80001160 <walk+0x8e>

0000000080001178 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001178:	57fd                	li	a5,-1
    8000117a:	83e9                	srli	a5,a5,0x1a
    8000117c:	00b7f463          	bleu	a1,a5,80001184 <walkaddr+0xc>
    return 0;
    80001180:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001182:	8082                	ret
{
    80001184:	1141                	addi	sp,sp,-16
    80001186:	e406                	sd	ra,8(sp)
    80001188:	e022                	sd	s0,0(sp)
    8000118a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000118c:	4601                	li	a2,0
    8000118e:	00000097          	auipc	ra,0x0
    80001192:	f44080e7          	jalr	-188(ra) # 800010d2 <walk>
  if(pte == 0)
    80001196:	c105                	beqz	a0,800011b6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001198:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000119a:	0117f693          	andi	a3,a5,17
    8000119e:	4745                	li	a4,17
    return 0;
    800011a0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800011a2:	00e68663          	beq	a3,a4,800011ae <walkaddr+0x36>
}
    800011a6:	60a2                	ld	ra,8(sp)
    800011a8:	6402                	ld	s0,0(sp)
    800011aa:	0141                	addi	sp,sp,16
    800011ac:	8082                	ret
  pa = PTE2PA(*pte);
    800011ae:	00a7d513          	srli	a0,a5,0xa
    800011b2:	0532                	slli	a0,a0,0xc
  return pa;
    800011b4:	bfcd                	j	800011a6 <walkaddr+0x2e>
    return 0;
    800011b6:	4501                	li	a0,0
    800011b8:	b7fd                	j	800011a6 <walkaddr+0x2e>

00000000800011ba <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    800011ba:	1101                	addi	sp,sp,-32
    800011bc:	ec06                	sd	ra,24(sp)
    800011be:	e822                	sd	s0,16(sp)
    800011c0:	e426                	sd	s1,8(sp)
    800011c2:	1000                	addi	s0,sp,32
    800011c4:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800011c6:	6785                	lui	a5,0x1
    800011c8:	17fd                	addi	a5,a5,-1
    800011ca:	00f574b3          	and	s1,a0,a5
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    800011ce:	4601                	li	a2,0
    800011d0:	00008797          	auipc	a5,0x8
    800011d4:	e4078793          	addi	a5,a5,-448 # 80009010 <kernel_pagetable>
    800011d8:	6388                	ld	a0,0(a5)
    800011da:	00000097          	auipc	ra,0x0
    800011de:	ef8080e7          	jalr	-264(ra) # 800010d2 <walk>
  if(pte == 0)
    800011e2:	cd09                	beqz	a0,800011fc <kvmpa+0x42>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    800011e4:	6108                	ld	a0,0(a0)
    800011e6:	00157793          	andi	a5,a0,1
    800011ea:	c38d                	beqz	a5,8000120c <kvmpa+0x52>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    800011ec:	8129                	srli	a0,a0,0xa
    800011ee:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    800011f0:	9526                	add	a0,a0,s1
    800011f2:	60e2                	ld	ra,24(sp)
    800011f4:	6442                	ld	s0,16(sp)
    800011f6:	64a2                	ld	s1,8(sp)
    800011f8:	6105                	addi	sp,sp,32
    800011fa:	8082                	ret
    panic("kvmpa");
    800011fc:	00007517          	auipc	a0,0x7
    80001200:	ef450513          	addi	a0,a0,-268 # 800080f0 <digits+0xd8>
    80001204:	fffff097          	auipc	ra,0xfffff
    80001208:	3fe080e7          	jalr	1022(ra) # 80000602 <panic>
    panic("kvmpa");
    8000120c:	00007517          	auipc	a0,0x7
    80001210:	ee450513          	addi	a0,a0,-284 # 800080f0 <digits+0xd8>
    80001214:	fffff097          	auipc	ra,0xfffff
    80001218:	3ee080e7          	jalr	1006(ra) # 80000602 <panic>

000000008000121c <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000121c:	715d                	addi	sp,sp,-80
    8000121e:	e486                	sd	ra,72(sp)
    80001220:	e0a2                	sd	s0,64(sp)
    80001222:	fc26                	sd	s1,56(sp)
    80001224:	f84a                	sd	s2,48(sp)
    80001226:	f44e                	sd	s3,40(sp)
    80001228:	f052                	sd	s4,32(sp)
    8000122a:	ec56                	sd	s5,24(sp)
    8000122c:	e85a                	sd	s6,16(sp)
    8000122e:	e45e                	sd	s7,8(sp)
    80001230:	0880                	addi	s0,sp,80
    80001232:	8aaa                	mv	s5,a0
    80001234:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001236:	79fd                	lui	s3,0xfffff
    80001238:	0135fa33          	and	s4,a1,s3
  last = PGROUNDDOWN(va + size - 1);
    8000123c:	167d                	addi	a2,a2,-1
    8000123e:	962e                	add	a2,a2,a1
    80001240:	013679b3          	and	s3,a2,s3
  a = PGROUNDDOWN(va);
    80001244:	8952                	mv	s2,s4
    80001246:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000124a:	6b85                	lui	s7,0x1
    8000124c:	a811                	j	80001260 <mappages+0x44>
      panic("remap");
    8000124e:	00007517          	auipc	a0,0x7
    80001252:	eaa50513          	addi	a0,a0,-342 # 800080f8 <digits+0xe0>
    80001256:	fffff097          	auipc	ra,0xfffff
    8000125a:	3ac080e7          	jalr	940(ra) # 80000602 <panic>
    a += PGSIZE;
    8000125e:	995e                	add	s2,s2,s7
  for(;;){
    80001260:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001264:	4605                	li	a2,1
    80001266:	85ca                	mv	a1,s2
    80001268:	8556                	mv	a0,s5
    8000126a:	00000097          	auipc	ra,0x0
    8000126e:	e68080e7          	jalr	-408(ra) # 800010d2 <walk>
    80001272:	cd19                	beqz	a0,80001290 <mappages+0x74>
    if(*pte & PTE_V)
    80001274:	611c                	ld	a5,0(a0)
    80001276:	8b85                	andi	a5,a5,1
    80001278:	fbf9                	bnez	a5,8000124e <mappages+0x32>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000127a:	80b1                	srli	s1,s1,0xc
    8000127c:	04aa                	slli	s1,s1,0xa
    8000127e:	0164e4b3          	or	s1,s1,s6
    80001282:	0014e493          	ori	s1,s1,1
    80001286:	e104                	sd	s1,0(a0)
    if(a == last)
    80001288:	fd391be3          	bne	s2,s3,8000125e <mappages+0x42>
    pa += PGSIZE;
  }
  return 0;
    8000128c:	4501                	li	a0,0
    8000128e:	a011                	j	80001292 <mappages+0x76>
      return -1;
    80001290:	557d                	li	a0,-1
}
    80001292:	60a6                	ld	ra,72(sp)
    80001294:	6406                	ld	s0,64(sp)
    80001296:	74e2                	ld	s1,56(sp)
    80001298:	7942                	ld	s2,48(sp)
    8000129a:	79a2                	ld	s3,40(sp)
    8000129c:	7a02                	ld	s4,32(sp)
    8000129e:	6ae2                	ld	s5,24(sp)
    800012a0:	6b42                	ld	s6,16(sp)
    800012a2:	6ba2                	ld	s7,8(sp)
    800012a4:	6161                	addi	sp,sp,80
    800012a6:	8082                	ret

00000000800012a8 <kvmmap>:
{
    800012a8:	1141                	addi	sp,sp,-16
    800012aa:	e406                	sd	ra,8(sp)
    800012ac:	e022                	sd	s0,0(sp)
    800012ae:	0800                	addi	s0,sp,16
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800012b0:	8736                	mv	a4,a3
    800012b2:	86ae                	mv	a3,a1
    800012b4:	85aa                	mv	a1,a0
    800012b6:	00008797          	auipc	a5,0x8
    800012ba:	d5a78793          	addi	a5,a5,-678 # 80009010 <kernel_pagetable>
    800012be:	6388                	ld	a0,0(a5)
    800012c0:	00000097          	auipc	ra,0x0
    800012c4:	f5c080e7          	jalr	-164(ra) # 8000121c <mappages>
    800012c8:	e509                	bnez	a0,800012d2 <kvmmap+0x2a>
}
    800012ca:	60a2                	ld	ra,8(sp)
    800012cc:	6402                	ld	s0,0(sp)
    800012ce:	0141                	addi	sp,sp,16
    800012d0:	8082                	ret
    panic("kvmmap");
    800012d2:	00007517          	auipc	a0,0x7
    800012d6:	e2e50513          	addi	a0,a0,-466 # 80008100 <digits+0xe8>
    800012da:	fffff097          	auipc	ra,0xfffff
    800012de:	328080e7          	jalr	808(ra) # 80000602 <panic>

00000000800012e2 <kvminit>:
{
    800012e2:	1101                	addi	sp,sp,-32
    800012e4:	ec06                	sd	ra,24(sp)
    800012e6:	e822                	sd	s0,16(sp)
    800012e8:	e426                	sd	s1,8(sp)
    800012ea:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800012ec:	00000097          	auipc	ra,0x0
    800012f0:	8ea080e7          	jalr	-1814(ra) # 80000bd6 <kalloc>
    800012f4:	00008797          	auipc	a5,0x8
    800012f8:	d0a7be23          	sd	a0,-740(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800012fc:	6605                	lui	a2,0x1
    800012fe:	4581                	li	a1,0
    80001300:	00000097          	auipc	ra,0x0
    80001304:	ac2080e7          	jalr	-1342(ra) # 80000dc2 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001308:	4699                	li	a3,6
    8000130a:	6605                	lui	a2,0x1
    8000130c:	100005b7          	lui	a1,0x10000
    80001310:	10000537          	lui	a0,0x10000
    80001314:	00000097          	auipc	ra,0x0
    80001318:	f94080e7          	jalr	-108(ra) # 800012a8 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000131c:	4699                	li	a3,6
    8000131e:	6605                	lui	a2,0x1
    80001320:	100015b7          	lui	a1,0x10001
    80001324:	10001537          	lui	a0,0x10001
    80001328:	00000097          	auipc	ra,0x0
    8000132c:	f80080e7          	jalr	-128(ra) # 800012a8 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001330:	4699                	li	a3,6
    80001332:	6641                	lui	a2,0x10
    80001334:	020005b7          	lui	a1,0x2000
    80001338:	02000537          	lui	a0,0x2000
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	f6c080e7          	jalr	-148(ra) # 800012a8 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001344:	4699                	li	a3,6
    80001346:	00400637          	lui	a2,0x400
    8000134a:	0c0005b7          	lui	a1,0xc000
    8000134e:	0c000537          	lui	a0,0xc000
    80001352:	00000097          	auipc	ra,0x0
    80001356:	f56080e7          	jalr	-170(ra) # 800012a8 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000135a:	00007497          	auipc	s1,0x7
    8000135e:	ca648493          	addi	s1,s1,-858 # 80008000 <etext>
    80001362:	46a9                	li	a3,10
    80001364:	80007617          	auipc	a2,0x80007
    80001368:	c9c60613          	addi	a2,a2,-868 # 8000 <_entry-0x7fff8000>
    8000136c:	4585                	li	a1,1
    8000136e:	05fe                	slli	a1,a1,0x1f
    80001370:	852e                	mv	a0,a1
    80001372:	00000097          	auipc	ra,0x0
    80001376:	f36080e7          	jalr	-202(ra) # 800012a8 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000137a:	4699                	li	a3,6
    8000137c:	4645                	li	a2,17
    8000137e:	066e                	slli	a2,a2,0x1b
    80001380:	8e05                	sub	a2,a2,s1
    80001382:	85a6                	mv	a1,s1
    80001384:	8526                	mv	a0,s1
    80001386:	00000097          	auipc	ra,0x0
    8000138a:	f22080e7          	jalr	-222(ra) # 800012a8 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000138e:	46a9                	li	a3,10
    80001390:	6605                	lui	a2,0x1
    80001392:	00006597          	auipc	a1,0x6
    80001396:	c6e58593          	addi	a1,a1,-914 # 80007000 <_trampoline>
    8000139a:	04000537          	lui	a0,0x4000
    8000139e:	157d                	addi	a0,a0,-1
    800013a0:	0532                	slli	a0,a0,0xc
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	f06080e7          	jalr	-250(ra) # 800012a8 <kvmmap>
}
    800013aa:	60e2                	ld	ra,24(sp)
    800013ac:	6442                	ld	s0,16(sp)
    800013ae:	64a2                	ld	s1,8(sp)
    800013b0:	6105                	addi	sp,sp,32
    800013b2:	8082                	ret

00000000800013b4 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800013b4:	715d                	addi	sp,sp,-80
    800013b6:	e486                	sd	ra,72(sp)
    800013b8:	e0a2                	sd	s0,64(sp)
    800013ba:	fc26                	sd	s1,56(sp)
    800013bc:	f84a                	sd	s2,48(sp)
    800013be:	f44e                	sd	s3,40(sp)
    800013c0:	f052                	sd	s4,32(sp)
    800013c2:	ec56                	sd	s5,24(sp)
    800013c4:	e85a                	sd	s6,16(sp)
    800013c6:	e45e                	sd	s7,8(sp)
    800013c8:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800013ca:	6785                	lui	a5,0x1
    800013cc:	17fd                	addi	a5,a5,-1
    800013ce:	8fed                	and	a5,a5,a1
    800013d0:	e795                	bnez	a5,800013fc <uvmunmap+0x48>
    800013d2:	8a2a                	mv	s4,a0
    800013d4:	84ae                	mv	s1,a1
    800013d6:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013d8:	0632                	slli	a2,a2,0xc
    800013da:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800013de:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013e0:	6b05                	lui	s6,0x1
    800013e2:	0735e863          	bltu	a1,s3,80001452 <uvmunmap+0x9e>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800013e6:	60a6                	ld	ra,72(sp)
    800013e8:	6406                	ld	s0,64(sp)
    800013ea:	74e2                	ld	s1,56(sp)
    800013ec:	7942                	ld	s2,48(sp)
    800013ee:	79a2                	ld	s3,40(sp)
    800013f0:	7a02                	ld	s4,32(sp)
    800013f2:	6ae2                	ld	s5,24(sp)
    800013f4:	6b42                	ld	s6,16(sp)
    800013f6:	6ba2                	ld	s7,8(sp)
    800013f8:	6161                	addi	sp,sp,80
    800013fa:	8082                	ret
    panic("uvmunmap: not aligned");
    800013fc:	00007517          	auipc	a0,0x7
    80001400:	d0c50513          	addi	a0,a0,-756 # 80008108 <digits+0xf0>
    80001404:	fffff097          	auipc	ra,0xfffff
    80001408:	1fe080e7          	jalr	510(ra) # 80000602 <panic>
      panic("uvmunmap: walk");
    8000140c:	00007517          	auipc	a0,0x7
    80001410:	d1450513          	addi	a0,a0,-748 # 80008120 <digits+0x108>
    80001414:	fffff097          	auipc	ra,0xfffff
    80001418:	1ee080e7          	jalr	494(ra) # 80000602 <panic>
      panic("uvmunmap: not mapped");
    8000141c:	00007517          	auipc	a0,0x7
    80001420:	d1450513          	addi	a0,a0,-748 # 80008130 <digits+0x118>
    80001424:	fffff097          	auipc	ra,0xfffff
    80001428:	1de080e7          	jalr	478(ra) # 80000602 <panic>
      panic("uvmunmap: not a leaf");
    8000142c:	00007517          	auipc	a0,0x7
    80001430:	d1c50513          	addi	a0,a0,-740 # 80008148 <digits+0x130>
    80001434:	fffff097          	auipc	ra,0xfffff
    80001438:	1ce080e7          	jalr	462(ra) # 80000602 <panic>
      uint64 pa = PTE2PA(*pte);
    8000143c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000143e:	0532                	slli	a0,a0,0xc
    80001440:	fffff097          	auipc	ra,0xfffff
    80001444:	696080e7          	jalr	1686(ra) # 80000ad6 <kfree>
    *pte = 0;
    80001448:	00093023          	sd	zero,0(s2)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000144c:	94da                	add	s1,s1,s6
    8000144e:	f934fce3          	bleu	s3,s1,800013e6 <uvmunmap+0x32>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001452:	4601                	li	a2,0
    80001454:	85a6                	mv	a1,s1
    80001456:	8552                	mv	a0,s4
    80001458:	00000097          	auipc	ra,0x0
    8000145c:	c7a080e7          	jalr	-902(ra) # 800010d2 <walk>
    80001460:	892a                	mv	s2,a0
    80001462:	d54d                	beqz	a0,8000140c <uvmunmap+0x58>
    if((*pte & PTE_V) == 0)
    80001464:	6108                	ld	a0,0(a0)
    80001466:	00157793          	andi	a5,a0,1
    8000146a:	dbcd                	beqz	a5,8000141c <uvmunmap+0x68>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000146c:	3ff57793          	andi	a5,a0,1023
    80001470:	fb778ee3          	beq	a5,s7,8000142c <uvmunmap+0x78>
    if(do_free){
    80001474:	fc0a8ae3          	beqz	s5,80001448 <uvmunmap+0x94>
    80001478:	b7d1                	j	8000143c <uvmunmap+0x88>

000000008000147a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000147a:	1101                	addi	sp,sp,-32
    8000147c:	ec06                	sd	ra,24(sp)
    8000147e:	e822                	sd	s0,16(sp)
    80001480:	e426                	sd	s1,8(sp)
    80001482:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001484:	fffff097          	auipc	ra,0xfffff
    80001488:	752080e7          	jalr	1874(ra) # 80000bd6 <kalloc>
    8000148c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000148e:	c519                	beqz	a0,8000149c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001490:	6605                	lui	a2,0x1
    80001492:	4581                	li	a1,0
    80001494:	00000097          	auipc	ra,0x0
    80001498:	92e080e7          	jalr	-1746(ra) # 80000dc2 <memset>
  return pagetable;
}
    8000149c:	8526                	mv	a0,s1
    8000149e:	60e2                	ld	ra,24(sp)
    800014a0:	6442                	ld	s0,16(sp)
    800014a2:	64a2                	ld	s1,8(sp)
    800014a4:	6105                	addi	sp,sp,32
    800014a6:	8082                	ret

00000000800014a8 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800014a8:	7179                	addi	sp,sp,-48
    800014aa:	f406                	sd	ra,40(sp)
    800014ac:	f022                	sd	s0,32(sp)
    800014ae:	ec26                	sd	s1,24(sp)
    800014b0:	e84a                	sd	s2,16(sp)
    800014b2:	e44e                	sd	s3,8(sp)
    800014b4:	e052                	sd	s4,0(sp)
    800014b6:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800014b8:	6785                	lui	a5,0x1
    800014ba:	04f67863          	bleu	a5,a2,8000150a <uvminit+0x62>
    800014be:	8a2a                	mv	s4,a0
    800014c0:	89ae                	mv	s3,a1
    800014c2:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800014c4:	fffff097          	auipc	ra,0xfffff
    800014c8:	712080e7          	jalr	1810(ra) # 80000bd6 <kalloc>
    800014cc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800014ce:	6605                	lui	a2,0x1
    800014d0:	4581                	li	a1,0
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	8f0080e7          	jalr	-1808(ra) # 80000dc2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800014da:	4779                	li	a4,30
    800014dc:	86ca                	mv	a3,s2
    800014de:	6605                	lui	a2,0x1
    800014e0:	4581                	li	a1,0
    800014e2:	8552                	mv	a0,s4
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	d38080e7          	jalr	-712(ra) # 8000121c <mappages>
  memmove(mem, src, sz);
    800014ec:	8626                	mv	a2,s1
    800014ee:	85ce                	mv	a1,s3
    800014f0:	854a                	mv	a0,s2
    800014f2:	00000097          	auipc	ra,0x0
    800014f6:	93c080e7          	jalr	-1732(ra) # 80000e2e <memmove>
}
    800014fa:	70a2                	ld	ra,40(sp)
    800014fc:	7402                	ld	s0,32(sp)
    800014fe:	64e2                	ld	s1,24(sp)
    80001500:	6942                	ld	s2,16(sp)
    80001502:	69a2                	ld	s3,8(sp)
    80001504:	6a02                	ld	s4,0(sp)
    80001506:	6145                	addi	sp,sp,48
    80001508:	8082                	ret
    panic("inituvm: more than a page");
    8000150a:	00007517          	auipc	a0,0x7
    8000150e:	c5650513          	addi	a0,a0,-938 # 80008160 <digits+0x148>
    80001512:	fffff097          	auipc	ra,0xfffff
    80001516:	0f0080e7          	jalr	240(ra) # 80000602 <panic>

000000008000151a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000151a:	1101                	addi	sp,sp,-32
    8000151c:	ec06                	sd	ra,24(sp)
    8000151e:	e822                	sd	s0,16(sp)
    80001520:	e426                	sd	s1,8(sp)
    80001522:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001524:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001526:	00b67d63          	bleu	a1,a2,80001540 <uvmdealloc+0x26>
    8000152a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000152c:	6605                	lui	a2,0x1
    8000152e:	167d                	addi	a2,a2,-1
    80001530:	00c487b3          	add	a5,s1,a2
    80001534:	777d                	lui	a4,0xfffff
    80001536:	8ff9                	and	a5,a5,a4
    80001538:	962e                	add	a2,a2,a1
    8000153a:	8e79                	and	a2,a2,a4
    8000153c:	00c7e863          	bltu	a5,a2,8000154c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001540:	8526                	mv	a0,s1
    80001542:	60e2                	ld	ra,24(sp)
    80001544:	6442                	ld	s0,16(sp)
    80001546:	64a2                	ld	s1,8(sp)
    80001548:	6105                	addi	sp,sp,32
    8000154a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000154c:	8e1d                	sub	a2,a2,a5
    8000154e:	8231                	srli	a2,a2,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001550:	4685                	li	a3,1
    80001552:	2601                	sext.w	a2,a2
    80001554:	85be                	mv	a1,a5
    80001556:	00000097          	auipc	ra,0x0
    8000155a:	e5e080e7          	jalr	-418(ra) # 800013b4 <uvmunmap>
    8000155e:	b7cd                	j	80001540 <uvmdealloc+0x26>

0000000080001560 <uvmalloc>:
  if(newsz < oldsz)
    80001560:	0ab66163          	bltu	a2,a1,80001602 <uvmalloc+0xa2>
{
    80001564:	7139                	addi	sp,sp,-64
    80001566:	fc06                	sd	ra,56(sp)
    80001568:	f822                	sd	s0,48(sp)
    8000156a:	f426                	sd	s1,40(sp)
    8000156c:	f04a                	sd	s2,32(sp)
    8000156e:	ec4e                	sd	s3,24(sp)
    80001570:	e852                	sd	s4,16(sp)
    80001572:	e456                	sd	s5,8(sp)
    80001574:	0080                	addi	s0,sp,64
  oldsz = PGROUNDUP(oldsz);
    80001576:	6a05                	lui	s4,0x1
    80001578:	1a7d                	addi	s4,s4,-1
    8000157a:	95d2                	add	a1,a1,s4
    8000157c:	7a7d                	lui	s4,0xfffff
    8000157e:	0145fa33          	and	s4,a1,s4
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001582:	08ca7263          	bleu	a2,s4,80001606 <uvmalloc+0xa6>
    80001586:	89b2                	mv	s3,a2
    80001588:	8aaa                	mv	s5,a0
    8000158a:	8952                	mv	s2,s4
    mem = kalloc();
    8000158c:	fffff097          	auipc	ra,0xfffff
    80001590:	64a080e7          	jalr	1610(ra) # 80000bd6 <kalloc>
    80001594:	84aa                	mv	s1,a0
    if(mem == 0){
    80001596:	c51d                	beqz	a0,800015c4 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001598:	6605                	lui	a2,0x1
    8000159a:	4581                	li	a1,0
    8000159c:	00000097          	auipc	ra,0x0
    800015a0:	826080e7          	jalr	-2010(ra) # 80000dc2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800015a4:	4779                	li	a4,30
    800015a6:	86a6                	mv	a3,s1
    800015a8:	6605                	lui	a2,0x1
    800015aa:	85ca                	mv	a1,s2
    800015ac:	8556                	mv	a0,s5
    800015ae:	00000097          	auipc	ra,0x0
    800015b2:	c6e080e7          	jalr	-914(ra) # 8000121c <mappages>
    800015b6:	e905                	bnez	a0,800015e6 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015b8:	6785                	lui	a5,0x1
    800015ba:	993e                	add	s2,s2,a5
    800015bc:	fd3968e3          	bltu	s2,s3,8000158c <uvmalloc+0x2c>
  return newsz;
    800015c0:	854e                	mv	a0,s3
    800015c2:	a809                	j	800015d4 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800015c4:	8652                	mv	a2,s4
    800015c6:	85ca                	mv	a1,s2
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	f50080e7          	jalr	-176(ra) # 8000151a <uvmdealloc>
      return 0;
    800015d2:	4501                	li	a0,0
}
    800015d4:	70e2                	ld	ra,56(sp)
    800015d6:	7442                	ld	s0,48(sp)
    800015d8:	74a2                	ld	s1,40(sp)
    800015da:	7902                	ld	s2,32(sp)
    800015dc:	69e2                	ld	s3,24(sp)
    800015de:	6a42                	ld	s4,16(sp)
    800015e0:	6aa2                	ld	s5,8(sp)
    800015e2:	6121                	addi	sp,sp,64
    800015e4:	8082                	ret
      kfree(mem);
    800015e6:	8526                	mv	a0,s1
    800015e8:	fffff097          	auipc	ra,0xfffff
    800015ec:	4ee080e7          	jalr	1262(ra) # 80000ad6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800015f0:	8652                	mv	a2,s4
    800015f2:	85ca                	mv	a1,s2
    800015f4:	8556                	mv	a0,s5
    800015f6:	00000097          	auipc	ra,0x0
    800015fa:	f24080e7          	jalr	-220(ra) # 8000151a <uvmdealloc>
      return 0;
    800015fe:	4501                	li	a0,0
    80001600:	bfd1                	j	800015d4 <uvmalloc+0x74>
    return oldsz;
    80001602:	852e                	mv	a0,a1
}
    80001604:	8082                	ret
  return newsz;
    80001606:	8532                	mv	a0,a2
    80001608:	b7f1                	j	800015d4 <uvmalloc+0x74>

000000008000160a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000160a:	7179                	addi	sp,sp,-48
    8000160c:	f406                	sd	ra,40(sp)
    8000160e:	f022                	sd	s0,32(sp)
    80001610:	ec26                	sd	s1,24(sp)
    80001612:	e84a                	sd	s2,16(sp)
    80001614:	e44e                	sd	s3,8(sp)
    80001616:	e052                	sd	s4,0(sp)
    80001618:	1800                	addi	s0,sp,48
    8000161a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000161c:	84aa                	mv	s1,a0
    8000161e:	6905                	lui	s2,0x1
    80001620:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001622:	4985                	li	s3,1
    80001624:	a821                	j	8000163c <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001626:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001628:	0532                	slli	a0,a0,0xc
    8000162a:	00000097          	auipc	ra,0x0
    8000162e:	fe0080e7          	jalr	-32(ra) # 8000160a <freewalk>
      pagetable[i] = 0;
    80001632:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001636:	04a1                	addi	s1,s1,8
    80001638:	03248163          	beq	s1,s2,8000165a <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000163c:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000163e:	00f57793          	andi	a5,a0,15
    80001642:	ff3782e3          	beq	a5,s3,80001626 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001646:	8905                	andi	a0,a0,1
    80001648:	d57d                	beqz	a0,80001636 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000164a:	00007517          	auipc	a0,0x7
    8000164e:	b3650513          	addi	a0,a0,-1226 # 80008180 <digits+0x168>
    80001652:	fffff097          	auipc	ra,0xfffff
    80001656:	fb0080e7          	jalr	-80(ra) # 80000602 <panic>
    }
  }
  kfree((void*)pagetable);
    8000165a:	8552                	mv	a0,s4
    8000165c:	fffff097          	auipc	ra,0xfffff
    80001660:	47a080e7          	jalr	1146(ra) # 80000ad6 <kfree>
}
    80001664:	70a2                	ld	ra,40(sp)
    80001666:	7402                	ld	s0,32(sp)
    80001668:	64e2                	ld	s1,24(sp)
    8000166a:	6942                	ld	s2,16(sp)
    8000166c:	69a2                	ld	s3,8(sp)
    8000166e:	6a02                	ld	s4,0(sp)
    80001670:	6145                	addi	sp,sp,48
    80001672:	8082                	ret

0000000080001674 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001674:	1101                	addi	sp,sp,-32
    80001676:	ec06                	sd	ra,24(sp)
    80001678:	e822                	sd	s0,16(sp)
    8000167a:	e426                	sd	s1,8(sp)
    8000167c:	1000                	addi	s0,sp,32
    8000167e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001680:	e999                	bnez	a1,80001696 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001682:	8526                	mv	a0,s1
    80001684:	00000097          	auipc	ra,0x0
    80001688:	f86080e7          	jalr	-122(ra) # 8000160a <freewalk>
}
    8000168c:	60e2                	ld	ra,24(sp)
    8000168e:	6442                	ld	s0,16(sp)
    80001690:	64a2                	ld	s1,8(sp)
    80001692:	6105                	addi	sp,sp,32
    80001694:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001696:	6605                	lui	a2,0x1
    80001698:	167d                	addi	a2,a2,-1
    8000169a:	962e                	add	a2,a2,a1
    8000169c:	4685                	li	a3,1
    8000169e:	8231                	srli	a2,a2,0xc
    800016a0:	4581                	li	a1,0
    800016a2:	00000097          	auipc	ra,0x0
    800016a6:	d12080e7          	jalr	-750(ra) # 800013b4 <uvmunmap>
    800016aa:	bfe1                	j	80001682 <uvmfree+0xe>

00000000800016ac <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800016ac:	c679                	beqz	a2,8000177a <uvmcopy+0xce>
{
    800016ae:	715d                	addi	sp,sp,-80
    800016b0:	e486                	sd	ra,72(sp)
    800016b2:	e0a2                	sd	s0,64(sp)
    800016b4:	fc26                	sd	s1,56(sp)
    800016b6:	f84a                	sd	s2,48(sp)
    800016b8:	f44e                	sd	s3,40(sp)
    800016ba:	f052                	sd	s4,32(sp)
    800016bc:	ec56                	sd	s5,24(sp)
    800016be:	e85a                	sd	s6,16(sp)
    800016c0:	e45e                	sd	s7,8(sp)
    800016c2:	0880                	addi	s0,sp,80
    800016c4:	8ab2                	mv	s5,a2
    800016c6:	8b2e                	mv	s6,a1
    800016c8:	8baa                	mv	s7,a0
  for(i = 0; i < sz; i += PGSIZE){
    800016ca:	4901                	li	s2,0
    if((pte = walk(old, i, 0)) == 0)
    800016cc:	4601                	li	a2,0
    800016ce:	85ca                	mv	a1,s2
    800016d0:	855e                	mv	a0,s7
    800016d2:	00000097          	auipc	ra,0x0
    800016d6:	a00080e7          	jalr	-1536(ra) # 800010d2 <walk>
    800016da:	c531                	beqz	a0,80001726 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800016dc:	6118                	ld	a4,0(a0)
    800016de:	00177793          	andi	a5,a4,1
    800016e2:	cbb1                	beqz	a5,80001736 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800016e4:	00a75593          	srli	a1,a4,0xa
    800016e8:	00c59993          	slli	s3,a1,0xc
    flags = PTE_FLAGS(*pte);
    800016ec:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800016f0:	fffff097          	auipc	ra,0xfffff
    800016f4:	4e6080e7          	jalr	1254(ra) # 80000bd6 <kalloc>
    800016f8:	8a2a                	mv	s4,a0
    800016fa:	c939                	beqz	a0,80001750 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016fc:	6605                	lui	a2,0x1
    800016fe:	85ce                	mv	a1,s3
    80001700:	fffff097          	auipc	ra,0xfffff
    80001704:	72e080e7          	jalr	1838(ra) # 80000e2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001708:	8726                	mv	a4,s1
    8000170a:	86d2                	mv	a3,s4
    8000170c:	6605                	lui	a2,0x1
    8000170e:	85ca                	mv	a1,s2
    80001710:	855a                	mv	a0,s6
    80001712:	00000097          	auipc	ra,0x0
    80001716:	b0a080e7          	jalr	-1270(ra) # 8000121c <mappages>
    8000171a:	e515                	bnez	a0,80001746 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000171c:	6785                	lui	a5,0x1
    8000171e:	993e                	add	s2,s2,a5
    80001720:	fb5966e3          	bltu	s2,s5,800016cc <uvmcopy+0x20>
    80001724:	a081                	j	80001764 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001726:	00007517          	auipc	a0,0x7
    8000172a:	a6a50513          	addi	a0,a0,-1430 # 80008190 <digits+0x178>
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	ed4080e7          	jalr	-300(ra) # 80000602 <panic>
      panic("uvmcopy: page not present");
    80001736:	00007517          	auipc	a0,0x7
    8000173a:	a7a50513          	addi	a0,a0,-1414 # 800081b0 <digits+0x198>
    8000173e:	fffff097          	auipc	ra,0xfffff
    80001742:	ec4080e7          	jalr	-316(ra) # 80000602 <panic>
      kfree(mem);
    80001746:	8552                	mv	a0,s4
    80001748:	fffff097          	auipc	ra,0xfffff
    8000174c:	38e080e7          	jalr	910(ra) # 80000ad6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001750:	4685                	li	a3,1
    80001752:	00c95613          	srli	a2,s2,0xc
    80001756:	4581                	li	a1,0
    80001758:	855a                	mv	a0,s6
    8000175a:	00000097          	auipc	ra,0x0
    8000175e:	c5a080e7          	jalr	-934(ra) # 800013b4 <uvmunmap>
  return -1;
    80001762:	557d                	li	a0,-1
}
    80001764:	60a6                	ld	ra,72(sp)
    80001766:	6406                	ld	s0,64(sp)
    80001768:	74e2                	ld	s1,56(sp)
    8000176a:	7942                	ld	s2,48(sp)
    8000176c:	79a2                	ld	s3,40(sp)
    8000176e:	7a02                	ld	s4,32(sp)
    80001770:	6ae2                	ld	s5,24(sp)
    80001772:	6b42                	ld	s6,16(sp)
    80001774:	6ba2                	ld	s7,8(sp)
    80001776:	6161                	addi	sp,sp,80
    80001778:	8082                	ret
  return 0;
    8000177a:	4501                	li	a0,0
}
    8000177c:	8082                	ret

000000008000177e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000177e:	1141                	addi	sp,sp,-16
    80001780:	e406                	sd	ra,8(sp)
    80001782:	e022                	sd	s0,0(sp)
    80001784:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001786:	4601                	li	a2,0
    80001788:	00000097          	auipc	ra,0x0
    8000178c:	94a080e7          	jalr	-1718(ra) # 800010d2 <walk>
  if(pte == 0)
    80001790:	c901                	beqz	a0,800017a0 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001792:	611c                	ld	a5,0(a0)
    80001794:	9bbd                	andi	a5,a5,-17
    80001796:	e11c                	sd	a5,0(a0)
}
    80001798:	60a2                	ld	ra,8(sp)
    8000179a:	6402                	ld	s0,0(sp)
    8000179c:	0141                	addi	sp,sp,16
    8000179e:	8082                	ret
    panic("uvmclear");
    800017a0:	00007517          	auipc	a0,0x7
    800017a4:	a3050513          	addi	a0,a0,-1488 # 800081d0 <digits+0x1b8>
    800017a8:	fffff097          	auipc	ra,0xfffff
    800017ac:	e5a080e7          	jalr	-422(ra) # 80000602 <panic>

00000000800017b0 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017b0:	c6bd                	beqz	a3,8000181e <copyout+0x6e>
{
    800017b2:	715d                	addi	sp,sp,-80
    800017b4:	e486                	sd	ra,72(sp)
    800017b6:	e0a2                	sd	s0,64(sp)
    800017b8:	fc26                	sd	s1,56(sp)
    800017ba:	f84a                	sd	s2,48(sp)
    800017bc:	f44e                	sd	s3,40(sp)
    800017be:	f052                	sd	s4,32(sp)
    800017c0:	ec56                	sd	s5,24(sp)
    800017c2:	e85a                	sd	s6,16(sp)
    800017c4:	e45e                	sd	s7,8(sp)
    800017c6:	e062                	sd	s8,0(sp)
    800017c8:	0880                	addi	s0,sp,80
    800017ca:	8baa                	mv	s7,a0
    800017cc:	8a2e                	mv	s4,a1
    800017ce:	8ab2                	mv	s5,a2
    800017d0:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800017d2:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800017d4:	6b05                	lui	s6,0x1
    800017d6:	a015                	j	800017fa <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017d8:	9552                	add	a0,a0,s4
    800017da:	0004861b          	sext.w	a2,s1
    800017de:	85d6                	mv	a1,s5
    800017e0:	41250533          	sub	a0,a0,s2
    800017e4:	fffff097          	auipc	ra,0xfffff
    800017e8:	64a080e7          	jalr	1610(ra) # 80000e2e <memmove>

    len -= n;
    800017ec:	409989b3          	sub	s3,s3,s1
    src += n;
    800017f0:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    800017f2:	01690a33          	add	s4,s2,s6
  while(len > 0){
    800017f6:	02098263          	beqz	s3,8000181a <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800017fa:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    800017fe:	85ca                	mv	a1,s2
    80001800:	855e                	mv	a0,s7
    80001802:	00000097          	auipc	ra,0x0
    80001806:	976080e7          	jalr	-1674(ra) # 80001178 <walkaddr>
    if(pa0 == 0)
    8000180a:	cd01                	beqz	a0,80001822 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000180c:	414904b3          	sub	s1,s2,s4
    80001810:	94da                	add	s1,s1,s6
    if(n > len)
    80001812:	fc99f3e3          	bleu	s1,s3,800017d8 <copyout+0x28>
    80001816:	84ce                	mv	s1,s3
    80001818:	b7c1                	j	800017d8 <copyout+0x28>
  }
  return 0;
    8000181a:	4501                	li	a0,0
    8000181c:	a021                	j	80001824 <copyout+0x74>
    8000181e:	4501                	li	a0,0
}
    80001820:	8082                	ret
      return -1;
    80001822:	557d                	li	a0,-1
}
    80001824:	60a6                	ld	ra,72(sp)
    80001826:	6406                	ld	s0,64(sp)
    80001828:	74e2                	ld	s1,56(sp)
    8000182a:	7942                	ld	s2,48(sp)
    8000182c:	79a2                	ld	s3,40(sp)
    8000182e:	7a02                	ld	s4,32(sp)
    80001830:	6ae2                	ld	s5,24(sp)
    80001832:	6b42                	ld	s6,16(sp)
    80001834:	6ba2                	ld	s7,8(sp)
    80001836:	6c02                	ld	s8,0(sp)
    80001838:	6161                	addi	sp,sp,80
    8000183a:	8082                	ret

000000008000183c <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000183c:	caa5                	beqz	a3,800018ac <copyin+0x70>
{
    8000183e:	715d                	addi	sp,sp,-80
    80001840:	e486                	sd	ra,72(sp)
    80001842:	e0a2                	sd	s0,64(sp)
    80001844:	fc26                	sd	s1,56(sp)
    80001846:	f84a                	sd	s2,48(sp)
    80001848:	f44e                	sd	s3,40(sp)
    8000184a:	f052                	sd	s4,32(sp)
    8000184c:	ec56                	sd	s5,24(sp)
    8000184e:	e85a                	sd	s6,16(sp)
    80001850:	e45e                	sd	s7,8(sp)
    80001852:	e062                	sd	s8,0(sp)
    80001854:	0880                	addi	s0,sp,80
    80001856:	8baa                	mv	s7,a0
    80001858:	8aae                	mv	s5,a1
    8000185a:	8a32                	mv	s4,a2
    8000185c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000185e:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001860:	6b05                	lui	s6,0x1
    80001862:	a01d                	j	80001888 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001864:	014505b3          	add	a1,a0,s4
    80001868:	0004861b          	sext.w	a2,s1
    8000186c:	412585b3          	sub	a1,a1,s2
    80001870:	8556                	mv	a0,s5
    80001872:	fffff097          	auipc	ra,0xfffff
    80001876:	5bc080e7          	jalr	1468(ra) # 80000e2e <memmove>

    len -= n;
    8000187a:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000187e:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001880:	01690a33          	add	s4,s2,s6
  while(len > 0){
    80001884:	02098263          	beqz	s3,800018a8 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001888:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    8000188c:	85ca                	mv	a1,s2
    8000188e:	855e                	mv	a0,s7
    80001890:	00000097          	auipc	ra,0x0
    80001894:	8e8080e7          	jalr	-1816(ra) # 80001178 <walkaddr>
    if(pa0 == 0)
    80001898:	cd01                	beqz	a0,800018b0 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000189a:	414904b3          	sub	s1,s2,s4
    8000189e:	94da                	add	s1,s1,s6
    if(n > len)
    800018a0:	fc99f2e3          	bleu	s1,s3,80001864 <copyin+0x28>
    800018a4:	84ce                	mv	s1,s3
    800018a6:	bf7d                	j	80001864 <copyin+0x28>
  }
  return 0;
    800018a8:	4501                	li	a0,0
    800018aa:	a021                	j	800018b2 <copyin+0x76>
    800018ac:	4501                	li	a0,0
}
    800018ae:	8082                	ret
      return -1;
    800018b0:	557d                	li	a0,-1
}
    800018b2:	60a6                	ld	ra,72(sp)
    800018b4:	6406                	ld	s0,64(sp)
    800018b6:	74e2                	ld	s1,56(sp)
    800018b8:	7942                	ld	s2,48(sp)
    800018ba:	79a2                	ld	s3,40(sp)
    800018bc:	7a02                	ld	s4,32(sp)
    800018be:	6ae2                	ld	s5,24(sp)
    800018c0:	6b42                	ld	s6,16(sp)
    800018c2:	6ba2                	ld	s7,8(sp)
    800018c4:	6c02                	ld	s8,0(sp)
    800018c6:	6161                	addi	sp,sp,80
    800018c8:	8082                	ret

00000000800018ca <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800018ca:	ced5                	beqz	a3,80001986 <copyinstr+0xbc>
{
    800018cc:	715d                	addi	sp,sp,-80
    800018ce:	e486                	sd	ra,72(sp)
    800018d0:	e0a2                	sd	s0,64(sp)
    800018d2:	fc26                	sd	s1,56(sp)
    800018d4:	f84a                	sd	s2,48(sp)
    800018d6:	f44e                	sd	s3,40(sp)
    800018d8:	f052                	sd	s4,32(sp)
    800018da:	ec56                	sd	s5,24(sp)
    800018dc:	e85a                	sd	s6,16(sp)
    800018de:	e45e                	sd	s7,8(sp)
    800018e0:	e062                	sd	s8,0(sp)
    800018e2:	0880                	addi	s0,sp,80
    800018e4:	8aaa                	mv	s5,a0
    800018e6:	84ae                	mv	s1,a1
    800018e8:	8c32                	mv	s8,a2
    800018ea:	8bb6                	mv	s7,a3
    va0 = PGROUNDDOWN(srcva);
    800018ec:	7a7d                	lui	s4,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018ee:	6985                	lui	s3,0x1
    800018f0:	4b05                	li	s6,1
    800018f2:	a801                	j	80001902 <copyinstr+0x38>
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
    800018f4:	87a6                	mv	a5,s1
    800018f6:	a085                	j	80001956 <copyinstr+0x8c>
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    800018f8:	84b2                	mv	s1,a2
    }

    srcva = va0 + PGSIZE;
    800018fa:	01390c33          	add	s8,s2,s3
  while(got_null == 0 && max > 0){
    800018fe:	080b8063          	beqz	s7,8000197e <copyinstr+0xb4>
    va0 = PGROUNDDOWN(srcva);
    80001902:	014c7933          	and	s2,s8,s4
    pa0 = walkaddr(pagetable, va0);
    80001906:	85ca                	mv	a1,s2
    80001908:	8556                	mv	a0,s5
    8000190a:	00000097          	auipc	ra,0x0
    8000190e:	86e080e7          	jalr	-1938(ra) # 80001178 <walkaddr>
    if(pa0 == 0)
    80001912:	c925                	beqz	a0,80001982 <copyinstr+0xb8>
    n = PGSIZE - (srcva - va0);
    80001914:	41890633          	sub	a2,s2,s8
    80001918:	964e                	add	a2,a2,s3
    if(n > max)
    8000191a:	00cbf363          	bleu	a2,s7,80001920 <copyinstr+0x56>
    8000191e:	865e                	mv	a2,s7
    char *p = (char *) (pa0 + (srcva - va0));
    80001920:	9562                	add	a0,a0,s8
    80001922:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001926:	da71                	beqz	a2,800018fa <copyinstr+0x30>
      if(*p == '\0'){
    80001928:	00054703          	lbu	a4,0(a0)
    8000192c:	d761                	beqz	a4,800018f4 <copyinstr+0x2a>
    8000192e:	9626                	add	a2,a2,s1
    80001930:	87a6                	mv	a5,s1
    80001932:	1bfd                	addi	s7,s7,-1
    80001934:	009b86b3          	add	a3,s7,s1
    80001938:	409b04b3          	sub	s1,s6,s1
    8000193c:	94aa                	add	s1,s1,a0
        *dst = *p;
    8000193e:	00e78023          	sb	a4,0(a5) # 1000 <_entry-0x7ffff000>
      --max;
    80001942:	40f68bb3          	sub	s7,a3,a5
      p++;
    80001946:	00f48733          	add	a4,s1,a5
      dst++;
    8000194a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000194c:	faf606e3          	beq	a2,a5,800018f8 <copyinstr+0x2e>
      if(*p == '\0'){
    80001950:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd8000>
    80001954:	f76d                	bnez	a4,8000193e <copyinstr+0x74>
        *dst = '\0';
    80001956:	00078023          	sb	zero,0(a5)
    8000195a:	4785                	li	a5,1
  }
  if(got_null){
    8000195c:	0017b513          	seqz	a0,a5
    80001960:	40a0053b          	negw	a0,a0
    80001964:	2501                	sext.w	a0,a0
    return 0;
  } else {
    return -1;
  }
}
    80001966:	60a6                	ld	ra,72(sp)
    80001968:	6406                	ld	s0,64(sp)
    8000196a:	74e2                	ld	s1,56(sp)
    8000196c:	7942                	ld	s2,48(sp)
    8000196e:	79a2                	ld	s3,40(sp)
    80001970:	7a02                	ld	s4,32(sp)
    80001972:	6ae2                	ld	s5,24(sp)
    80001974:	6b42                	ld	s6,16(sp)
    80001976:	6ba2                	ld	s7,8(sp)
    80001978:	6c02                	ld	s8,0(sp)
    8000197a:	6161                	addi	sp,sp,80
    8000197c:	8082                	ret
    8000197e:	4781                	li	a5,0
    80001980:	bff1                	j	8000195c <copyinstr+0x92>
      return -1;
    80001982:	557d                	li	a0,-1
    80001984:	b7cd                	j	80001966 <copyinstr+0x9c>
  int got_null = 0;
    80001986:	4781                	li	a5,0
  if(got_null){
    80001988:	0017b513          	seqz	a0,a5
    8000198c:	40a0053b          	negw	a0,a0
    80001990:	2501                	sext.w	a0,a0
}
    80001992:	8082                	ret

0000000080001994 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001994:	1101                	addi	sp,sp,-32
    80001996:	ec06                	sd	ra,24(sp)
    80001998:	e822                	sd	s0,16(sp)
    8000199a:	e426                	sd	s1,8(sp)
    8000199c:	1000                	addi	s0,sp,32
    8000199e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800019a0:	fffff097          	auipc	ra,0xfffff
    800019a4:	2ac080e7          	jalr	684(ra) # 80000c4c <holding>
    800019a8:	c909                	beqz	a0,800019ba <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800019aa:	749c                	ld	a5,40(s1)
    800019ac:	00978f63          	beq	a5,s1,800019ca <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    800019b0:	60e2                	ld	ra,24(sp)
    800019b2:	6442                	ld	s0,16(sp)
    800019b4:	64a2                	ld	s1,8(sp)
    800019b6:	6105                	addi	sp,sp,32
    800019b8:	8082                	ret
    panic("wakeup1");
    800019ba:	00007517          	auipc	a0,0x7
    800019be:	84e50513          	addi	a0,a0,-1970 # 80008208 <states.1731+0x28>
    800019c2:	fffff097          	auipc	ra,0xfffff
    800019c6:	c40080e7          	jalr	-960(ra) # 80000602 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    800019ca:	4c98                	lw	a4,24(s1)
    800019cc:	4785                	li	a5,1
    800019ce:	fef711e3          	bne	a4,a5,800019b0 <wakeup1+0x1c>
    p->state = RUNNABLE;
    800019d2:	4789                	li	a5,2
    800019d4:	cc9c                	sw	a5,24(s1)
}
    800019d6:	bfe9                	j	800019b0 <wakeup1+0x1c>

00000000800019d8 <procinit>:
{
    800019d8:	715d                	addi	sp,sp,-80
    800019da:	e486                	sd	ra,72(sp)
    800019dc:	e0a2                	sd	s0,64(sp)
    800019de:	fc26                	sd	s1,56(sp)
    800019e0:	f84a                	sd	s2,48(sp)
    800019e2:	f44e                	sd	s3,40(sp)
    800019e4:	f052                	sd	s4,32(sp)
    800019e6:	ec56                	sd	s5,24(sp)
    800019e8:	e85a                	sd	s6,16(sp)
    800019ea:	e45e                	sd	s7,8(sp)
    800019ec:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    800019ee:	00007597          	auipc	a1,0x7
    800019f2:	82258593          	addi	a1,a1,-2014 # 80008210 <states.1731+0x30>
    800019f6:	00010517          	auipc	a0,0x10
    800019fa:	f5a50513          	addi	a0,a0,-166 # 80011950 <pid_lock>
    800019fe:	fffff097          	auipc	ra,0xfffff
    80001a02:	238080e7          	jalr	568(ra) # 80000c36 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a06:	00010917          	auipc	s2,0x10
    80001a0a:	36290913          	addi	s2,s2,866 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001a0e:	00007b97          	auipc	s7,0x7
    80001a12:	80ab8b93          	addi	s7,s7,-2038 # 80008218 <states.1731+0x38>
      uint64 va = KSTACK((int) (p - proc));
    80001a16:	8b4a                	mv	s6,s2
    80001a18:	00006a97          	auipc	s5,0x6
    80001a1c:	5e8a8a93          	addi	s5,s5,1512 # 80008000 <etext>
    80001a20:	040009b7          	lui	s3,0x4000
    80001a24:	19fd                	addi	s3,s3,-1
    80001a26:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a28:	00016a17          	auipc	s4,0x16
    80001a2c:	340a0a13          	addi	s4,s4,832 # 80017d68 <tickslock>
      initlock(&p->lock, "proc");
    80001a30:	85de                	mv	a1,s7
    80001a32:	854a                	mv	a0,s2
    80001a34:	fffff097          	auipc	ra,0xfffff
    80001a38:	202080e7          	jalr	514(ra) # 80000c36 <initlock>
      char *pa = kalloc();
    80001a3c:	fffff097          	auipc	ra,0xfffff
    80001a40:	19a080e7          	jalr	410(ra) # 80000bd6 <kalloc>
    80001a44:	85aa                	mv	a1,a0
      if(pa == 0)
    80001a46:	c929                	beqz	a0,80001a98 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001a48:	416904b3          	sub	s1,s2,s6
    80001a4c:	849d                	srai	s1,s1,0x7
    80001a4e:	000ab783          	ld	a5,0(s5)
    80001a52:	02f484b3          	mul	s1,s1,a5
    80001a56:	2485                	addiw	s1,s1,1
    80001a58:	00d4949b          	slliw	s1,s1,0xd
    80001a5c:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a60:	4699                	li	a3,6
    80001a62:	6605                	lui	a2,0x1
    80001a64:	8526                	mv	a0,s1
    80001a66:	00000097          	auipc	ra,0x0
    80001a6a:	842080e7          	jalr	-1982(ra) # 800012a8 <kvmmap>
      p->kstack = va;
    80001a6e:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a72:	18090913          	addi	s2,s2,384
    80001a76:	fb491de3          	bne	s2,s4,80001a30 <procinit+0x58>
  kvminithart();
    80001a7a:	fffff097          	auipc	ra,0xfffff
    80001a7e:	632080e7          	jalr	1586(ra) # 800010ac <kvminithart>
}
    80001a82:	60a6                	ld	ra,72(sp)
    80001a84:	6406                	ld	s0,64(sp)
    80001a86:	74e2                	ld	s1,56(sp)
    80001a88:	7942                	ld	s2,48(sp)
    80001a8a:	79a2                	ld	s3,40(sp)
    80001a8c:	7a02                	ld	s4,32(sp)
    80001a8e:	6ae2                	ld	s5,24(sp)
    80001a90:	6b42                	ld	s6,16(sp)
    80001a92:	6ba2                	ld	s7,8(sp)
    80001a94:	6161                	addi	sp,sp,80
    80001a96:	8082                	ret
        panic("kalloc");
    80001a98:	00006517          	auipc	a0,0x6
    80001a9c:	78850513          	addi	a0,a0,1928 # 80008220 <states.1731+0x40>
    80001aa0:	fffff097          	auipc	ra,0xfffff
    80001aa4:	b62080e7          	jalr	-1182(ra) # 80000602 <panic>

0000000080001aa8 <cpuid>:
{
    80001aa8:	1141                	addi	sp,sp,-16
    80001aaa:	e422                	sd	s0,8(sp)
    80001aac:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001aae:	8512                	mv	a0,tp
}
    80001ab0:	2501                	sext.w	a0,a0
    80001ab2:	6422                	ld	s0,8(sp)
    80001ab4:	0141                	addi	sp,sp,16
    80001ab6:	8082                	ret

0000000080001ab8 <mycpu>:
mycpu(void) {
    80001ab8:	1141                	addi	sp,sp,-16
    80001aba:	e422                	sd	s0,8(sp)
    80001abc:	0800                	addi	s0,sp,16
    80001abe:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001ac0:	2781                	sext.w	a5,a5
    80001ac2:	079e                	slli	a5,a5,0x7
}
    80001ac4:	00010517          	auipc	a0,0x10
    80001ac8:	ea450513          	addi	a0,a0,-348 # 80011968 <cpus>
    80001acc:	953e                	add	a0,a0,a5
    80001ace:	6422                	ld	s0,8(sp)
    80001ad0:	0141                	addi	sp,sp,16
    80001ad2:	8082                	ret

0000000080001ad4 <myproc>:
myproc(void) {
    80001ad4:	1101                	addi	sp,sp,-32
    80001ad6:	ec06                	sd	ra,24(sp)
    80001ad8:	e822                	sd	s0,16(sp)
    80001ada:	e426                	sd	s1,8(sp)
    80001adc:	1000                	addi	s0,sp,32
  push_off();
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	19c080e7          	jalr	412(ra) # 80000c7a <push_off>
    80001ae6:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001ae8:	2781                	sext.w	a5,a5
    80001aea:	079e                	slli	a5,a5,0x7
    80001aec:	00010717          	auipc	a4,0x10
    80001af0:	e6470713          	addi	a4,a4,-412 # 80011950 <pid_lock>
    80001af4:	97ba                	add	a5,a5,a4
    80001af6:	6f84                	ld	s1,24(a5)
  pop_off();
    80001af8:	fffff097          	auipc	ra,0xfffff
    80001afc:	222080e7          	jalr	546(ra) # 80000d1a <pop_off>
}
    80001b00:	8526                	mv	a0,s1
    80001b02:	60e2                	ld	ra,24(sp)
    80001b04:	6442                	ld	s0,16(sp)
    80001b06:	64a2                	ld	s1,8(sp)
    80001b08:	6105                	addi	sp,sp,32
    80001b0a:	8082                	ret

0000000080001b0c <forkret>:
{
    80001b0c:	1141                	addi	sp,sp,-16
    80001b0e:	e406                	sd	ra,8(sp)
    80001b10:	e022                	sd	s0,0(sp)
    80001b12:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001b14:	00000097          	auipc	ra,0x0
    80001b18:	fc0080e7          	jalr	-64(ra) # 80001ad4 <myproc>
    80001b1c:	fffff097          	auipc	ra,0xfffff
    80001b20:	25e080e7          	jalr	606(ra) # 80000d7a <release>
  if (first) {
    80001b24:	00007797          	auipc	a5,0x7
    80001b28:	d1c78793          	addi	a5,a5,-740 # 80008840 <first.1691>
    80001b2c:	439c                	lw	a5,0(a5)
    80001b2e:	eb89                	bnez	a5,80001b40 <forkret+0x34>
  usertrapret();
    80001b30:	00001097          	auipc	ra,0x1
    80001b34:	c4c080e7          	jalr	-948(ra) # 8000277c <usertrapret>
}
    80001b38:	60a2                	ld	ra,8(sp)
    80001b3a:	6402                	ld	s0,0(sp)
    80001b3c:	0141                	addi	sp,sp,16
    80001b3e:	8082                	ret
    first = 0;
    80001b40:	00007797          	auipc	a5,0x7
    80001b44:	d007a023          	sw	zero,-768(a5) # 80008840 <first.1691>
    fsinit(ROOTDEV);
    80001b48:	4505                	li	a0,1
    80001b4a:	00002097          	auipc	ra,0x2
    80001b4e:	a28080e7          	jalr	-1496(ra) # 80003572 <fsinit>
    80001b52:	bff9                	j	80001b30 <forkret+0x24>

0000000080001b54 <allocpid>:
allocpid() {
    80001b54:	1101                	addi	sp,sp,-32
    80001b56:	ec06                	sd	ra,24(sp)
    80001b58:	e822                	sd	s0,16(sp)
    80001b5a:	e426                	sd	s1,8(sp)
    80001b5c:	e04a                	sd	s2,0(sp)
    80001b5e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b60:	00010917          	auipc	s2,0x10
    80001b64:	df090913          	addi	s2,s2,-528 # 80011950 <pid_lock>
    80001b68:	854a                	mv	a0,s2
    80001b6a:	fffff097          	auipc	ra,0xfffff
    80001b6e:	15c080e7          	jalr	348(ra) # 80000cc6 <acquire>
  pid = nextpid;
    80001b72:	00007797          	auipc	a5,0x7
    80001b76:	cd278793          	addi	a5,a5,-814 # 80008844 <nextpid>
    80001b7a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b7c:	0014871b          	addiw	a4,s1,1
    80001b80:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b82:	854a                	mv	a0,s2
    80001b84:	fffff097          	auipc	ra,0xfffff
    80001b88:	1f6080e7          	jalr	502(ra) # 80000d7a <release>
}
    80001b8c:	8526                	mv	a0,s1
    80001b8e:	60e2                	ld	ra,24(sp)
    80001b90:	6442                	ld	s0,16(sp)
    80001b92:	64a2                	ld	s1,8(sp)
    80001b94:	6902                	ld	s2,0(sp)
    80001b96:	6105                	addi	sp,sp,32
    80001b98:	8082                	ret

0000000080001b9a <proc_pagetable>:
{
    80001b9a:	1101                	addi	sp,sp,-32
    80001b9c:	ec06                	sd	ra,24(sp)
    80001b9e:	e822                	sd	s0,16(sp)
    80001ba0:	e426                	sd	s1,8(sp)
    80001ba2:	e04a                	sd	s2,0(sp)
    80001ba4:	1000                	addi	s0,sp,32
    80001ba6:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ba8:	00000097          	auipc	ra,0x0
    80001bac:	8d2080e7          	jalr	-1838(ra) # 8000147a <uvmcreate>
    80001bb0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001bb2:	c121                	beqz	a0,80001bf2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bb4:	4729                	li	a4,10
    80001bb6:	00005697          	auipc	a3,0x5
    80001bba:	44a68693          	addi	a3,a3,1098 # 80007000 <_trampoline>
    80001bbe:	6605                	lui	a2,0x1
    80001bc0:	040005b7          	lui	a1,0x4000
    80001bc4:	15fd                	addi	a1,a1,-1
    80001bc6:	05b2                	slli	a1,a1,0xc
    80001bc8:	fffff097          	auipc	ra,0xfffff
    80001bcc:	654080e7          	jalr	1620(ra) # 8000121c <mappages>
    80001bd0:	02054863          	bltz	a0,80001c00 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001bd4:	4719                	li	a4,6
    80001bd6:	05893683          	ld	a3,88(s2)
    80001bda:	6605                	lui	a2,0x1
    80001bdc:	020005b7          	lui	a1,0x2000
    80001be0:	15fd                	addi	a1,a1,-1
    80001be2:	05b6                	slli	a1,a1,0xd
    80001be4:	8526                	mv	a0,s1
    80001be6:	fffff097          	auipc	ra,0xfffff
    80001bea:	636080e7          	jalr	1590(ra) # 8000121c <mappages>
    80001bee:	02054163          	bltz	a0,80001c10 <proc_pagetable+0x76>
}
    80001bf2:	8526                	mv	a0,s1
    80001bf4:	60e2                	ld	ra,24(sp)
    80001bf6:	6442                	ld	s0,16(sp)
    80001bf8:	64a2                	ld	s1,8(sp)
    80001bfa:	6902                	ld	s2,0(sp)
    80001bfc:	6105                	addi	sp,sp,32
    80001bfe:	8082                	ret
    uvmfree(pagetable, 0);
    80001c00:	4581                	li	a1,0
    80001c02:	8526                	mv	a0,s1
    80001c04:	00000097          	auipc	ra,0x0
    80001c08:	a70080e7          	jalr	-1424(ra) # 80001674 <uvmfree>
    return 0;
    80001c0c:	4481                	li	s1,0
    80001c0e:	b7d5                	j	80001bf2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c10:	4681                	li	a3,0
    80001c12:	4605                	li	a2,1
    80001c14:	040005b7          	lui	a1,0x4000
    80001c18:	15fd                	addi	a1,a1,-1
    80001c1a:	05b2                	slli	a1,a1,0xc
    80001c1c:	8526                	mv	a0,s1
    80001c1e:	fffff097          	auipc	ra,0xfffff
    80001c22:	796080e7          	jalr	1942(ra) # 800013b4 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c26:	4581                	li	a1,0
    80001c28:	8526                	mv	a0,s1
    80001c2a:	00000097          	auipc	ra,0x0
    80001c2e:	a4a080e7          	jalr	-1462(ra) # 80001674 <uvmfree>
    return 0;
    80001c32:	4481                	li	s1,0
    80001c34:	bf7d                	j	80001bf2 <proc_pagetable+0x58>

0000000080001c36 <proc_freepagetable>:
{
    80001c36:	1101                	addi	sp,sp,-32
    80001c38:	ec06                	sd	ra,24(sp)
    80001c3a:	e822                	sd	s0,16(sp)
    80001c3c:	e426                	sd	s1,8(sp)
    80001c3e:	e04a                	sd	s2,0(sp)
    80001c40:	1000                	addi	s0,sp,32
    80001c42:	84aa                	mv	s1,a0
    80001c44:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c46:	4681                	li	a3,0
    80001c48:	4605                	li	a2,1
    80001c4a:	040005b7          	lui	a1,0x4000
    80001c4e:	15fd                	addi	a1,a1,-1
    80001c50:	05b2                	slli	a1,a1,0xc
    80001c52:	fffff097          	auipc	ra,0xfffff
    80001c56:	762080e7          	jalr	1890(ra) # 800013b4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c5a:	4681                	li	a3,0
    80001c5c:	4605                	li	a2,1
    80001c5e:	020005b7          	lui	a1,0x2000
    80001c62:	15fd                	addi	a1,a1,-1
    80001c64:	05b6                	slli	a1,a1,0xd
    80001c66:	8526                	mv	a0,s1
    80001c68:	fffff097          	auipc	ra,0xfffff
    80001c6c:	74c080e7          	jalr	1868(ra) # 800013b4 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c70:	85ca                	mv	a1,s2
    80001c72:	8526                	mv	a0,s1
    80001c74:	00000097          	auipc	ra,0x0
    80001c78:	a00080e7          	jalr	-1536(ra) # 80001674 <uvmfree>
}
    80001c7c:	60e2                	ld	ra,24(sp)
    80001c7e:	6442                	ld	s0,16(sp)
    80001c80:	64a2                	ld	s1,8(sp)
    80001c82:	6902                	ld	s2,0(sp)
    80001c84:	6105                	addi	sp,sp,32
    80001c86:	8082                	ret

0000000080001c88 <freeproc>:
{
    80001c88:	1101                	addi	sp,sp,-32
    80001c8a:	ec06                	sd	ra,24(sp)
    80001c8c:	e822                	sd	s0,16(sp)
    80001c8e:	e426                	sd	s1,8(sp)
    80001c90:	1000                	addi	s0,sp,32
    80001c92:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c94:	6d28                	ld	a0,88(a0)
    80001c96:	c509                	beqz	a0,80001ca0 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c98:	fffff097          	auipc	ra,0xfffff
    80001c9c:	e3e080e7          	jalr	-450(ra) # 80000ad6 <kfree>
  p->trapframe = 0;
    80001ca0:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001ca4:	68a8                	ld	a0,80(s1)
    80001ca6:	c511                	beqz	a0,80001cb2 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001ca8:	64ac                	ld	a1,72(s1)
    80001caa:	00000097          	auipc	ra,0x0
    80001cae:	f8c080e7          	jalr	-116(ra) # 80001c36 <proc_freepagetable>
  p->pagetable = 0;
    80001cb2:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001cb6:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001cba:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001cbe:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001cc2:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001cc6:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001cca:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001cce:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001cd2:	0004ac23          	sw	zero,24(s1)
  p->alarm = 0;
    80001cd6:	1604a623          	sw	zero,364(s1)
  p->duration = 0;
    80001cda:	1604a423          	sw	zero,360(s1)
  p->handler = 0;
    80001cde:	1604b823          	sd	zero,368(s1)
  if(p->alarm_trapframe)
    80001ce2:	1784b503          	ld	a0,376(s1)
    80001ce6:	c509                	beqz	a0,80001cf0 <freeproc+0x68>
    kfree((void*)p->alarm_trapframe);
    80001ce8:	fffff097          	auipc	ra,0xfffff
    80001cec:	dee080e7          	jalr	-530(ra) # 80000ad6 <kfree>
  p->alarm_trapframe = 0;
    80001cf0:	1604bc23          	sd	zero,376(s1)
}
    80001cf4:	60e2                	ld	ra,24(sp)
    80001cf6:	6442                	ld	s0,16(sp)
    80001cf8:	64a2                	ld	s1,8(sp)
    80001cfa:	6105                	addi	sp,sp,32
    80001cfc:	8082                	ret

0000000080001cfe <allocproc>:
{
    80001cfe:	1101                	addi	sp,sp,-32
    80001d00:	ec06                	sd	ra,24(sp)
    80001d02:	e822                	sd	s0,16(sp)
    80001d04:	e426                	sd	s1,8(sp)
    80001d06:	e04a                	sd	s2,0(sp)
    80001d08:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d0a:	00010497          	auipc	s1,0x10
    80001d0e:	05e48493          	addi	s1,s1,94 # 80011d68 <proc>
    80001d12:	00016917          	auipc	s2,0x16
    80001d16:	05690913          	addi	s2,s2,86 # 80017d68 <tickslock>
    acquire(&p->lock);
    80001d1a:	8526                	mv	a0,s1
    80001d1c:	fffff097          	auipc	ra,0xfffff
    80001d20:	faa080e7          	jalr	-86(ra) # 80000cc6 <acquire>
    if(p->state == UNUSED) {
    80001d24:	4c9c                	lw	a5,24(s1)
    80001d26:	cf81                	beqz	a5,80001d3e <allocproc+0x40>
      release(&p->lock);
    80001d28:	8526                	mv	a0,s1
    80001d2a:	fffff097          	auipc	ra,0xfffff
    80001d2e:	050080e7          	jalr	80(ra) # 80000d7a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d32:	18048493          	addi	s1,s1,384
    80001d36:	ff2492e3          	bne	s1,s2,80001d1a <allocproc+0x1c>
  return 0;
    80001d3a:	4481                	li	s1,0
    80001d3c:	a8a9                	j	80001d96 <allocproc+0x98>
  p->pid = allocpid();
    80001d3e:	00000097          	auipc	ra,0x0
    80001d42:	e16080e7          	jalr	-490(ra) # 80001b54 <allocpid>
    80001d46:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	e8e080e7          	jalr	-370(ra) # 80000bd6 <kalloc>
    80001d50:	892a                	mv	s2,a0
    80001d52:	eca8                	sd	a0,88(s1)
    80001d54:	c921                	beqz	a0,80001da4 <allocproc+0xa6>
  p->pagetable = proc_pagetable(p);
    80001d56:	8526                	mv	a0,s1
    80001d58:	00000097          	auipc	ra,0x0
    80001d5c:	e42080e7          	jalr	-446(ra) # 80001b9a <proc_pagetable>
    80001d60:	892a                	mv	s2,a0
    80001d62:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d64:	c539                	beqz	a0,80001db2 <allocproc+0xb4>
  memset(&p->context, 0, sizeof(p->context));
    80001d66:	07000613          	li	a2,112
    80001d6a:	4581                	li	a1,0
    80001d6c:	06048513          	addi	a0,s1,96
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	052080e7          	jalr	82(ra) # 80000dc2 <memset>
  p->context.ra = (uint64)forkret;
    80001d78:	00000797          	auipc	a5,0x0
    80001d7c:	d9478793          	addi	a5,a5,-620 # 80001b0c <forkret>
    80001d80:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d82:	60bc                	ld	a5,64(s1)
    80001d84:	6705                	lui	a4,0x1
    80001d86:	97ba                	add	a5,a5,a4
    80001d88:	f4bc                	sd	a5,104(s1)
  p->alarm = 0;
    80001d8a:	1604a623          	sw	zero,364(s1)
  p->duration = 0;
    80001d8e:	1604a423          	sw	zero,360(s1)
  p->handler = 0;
    80001d92:	1604b823          	sd	zero,368(s1)
}
    80001d96:	8526                	mv	a0,s1
    80001d98:	60e2                	ld	ra,24(sp)
    80001d9a:	6442                	ld	s0,16(sp)
    80001d9c:	64a2                	ld	s1,8(sp)
    80001d9e:	6902                	ld	s2,0(sp)
    80001da0:	6105                	addi	sp,sp,32
    80001da2:	8082                	ret
    release(&p->lock);
    80001da4:	8526                	mv	a0,s1
    80001da6:	fffff097          	auipc	ra,0xfffff
    80001daa:	fd4080e7          	jalr	-44(ra) # 80000d7a <release>
    return 0;
    80001dae:	84ca                	mv	s1,s2
    80001db0:	b7dd                	j	80001d96 <allocproc+0x98>
    freeproc(p);
    80001db2:	8526                	mv	a0,s1
    80001db4:	00000097          	auipc	ra,0x0
    80001db8:	ed4080e7          	jalr	-300(ra) # 80001c88 <freeproc>
    release(&p->lock);
    80001dbc:	8526                	mv	a0,s1
    80001dbe:	fffff097          	auipc	ra,0xfffff
    80001dc2:	fbc080e7          	jalr	-68(ra) # 80000d7a <release>
    return 0;
    80001dc6:	84ca                	mv	s1,s2
    80001dc8:	b7f9                	j	80001d96 <allocproc+0x98>

0000000080001dca <userinit>:
{
    80001dca:	1101                	addi	sp,sp,-32
    80001dcc:	ec06                	sd	ra,24(sp)
    80001dce:	e822                	sd	s0,16(sp)
    80001dd0:	e426                	sd	s1,8(sp)
    80001dd2:	1000                	addi	s0,sp,32
  p = allocproc();
    80001dd4:	00000097          	auipc	ra,0x0
    80001dd8:	f2a080e7          	jalr	-214(ra) # 80001cfe <allocproc>
    80001ddc:	84aa                	mv	s1,a0
  initproc = p;
    80001dde:	00007797          	auipc	a5,0x7
    80001de2:	22a7bd23          	sd	a0,570(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001de6:	03400613          	li	a2,52
    80001dea:	00007597          	auipc	a1,0x7
    80001dee:	a6658593          	addi	a1,a1,-1434 # 80008850 <initcode>
    80001df2:	6928                	ld	a0,80(a0)
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	6b4080e7          	jalr	1716(ra) # 800014a8 <uvminit>
  p->sz = PGSIZE;
    80001dfc:	6785                	lui	a5,0x1
    80001dfe:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001e00:	6cb8                	ld	a4,88(s1)
    80001e02:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001e06:	6cb8                	ld	a4,88(s1)
    80001e08:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e0a:	4641                	li	a2,16
    80001e0c:	00006597          	auipc	a1,0x6
    80001e10:	41c58593          	addi	a1,a1,1052 # 80008228 <states.1731+0x48>
    80001e14:	15848513          	addi	a0,s1,344
    80001e18:	fffff097          	auipc	ra,0xfffff
    80001e1c:	122080e7          	jalr	290(ra) # 80000f3a <safestrcpy>
  p->cwd = namei("/");
    80001e20:	00006517          	auipc	a0,0x6
    80001e24:	41850513          	addi	a0,a0,1048 # 80008238 <states.1731+0x58>
    80001e28:	00002097          	auipc	ra,0x2
    80001e2c:	17e080e7          	jalr	382(ra) # 80003fa6 <namei>
    80001e30:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e34:	4789                	li	a5,2
    80001e36:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e38:	8526                	mv	a0,s1
    80001e3a:	fffff097          	auipc	ra,0xfffff
    80001e3e:	f40080e7          	jalr	-192(ra) # 80000d7a <release>
}
    80001e42:	60e2                	ld	ra,24(sp)
    80001e44:	6442                	ld	s0,16(sp)
    80001e46:	64a2                	ld	s1,8(sp)
    80001e48:	6105                	addi	sp,sp,32
    80001e4a:	8082                	ret

0000000080001e4c <growproc>:
{
    80001e4c:	1101                	addi	sp,sp,-32
    80001e4e:	ec06                	sd	ra,24(sp)
    80001e50:	e822                	sd	s0,16(sp)
    80001e52:	e426                	sd	s1,8(sp)
    80001e54:	e04a                	sd	s2,0(sp)
    80001e56:	1000                	addi	s0,sp,32
    80001e58:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e5a:	00000097          	auipc	ra,0x0
    80001e5e:	c7a080e7          	jalr	-902(ra) # 80001ad4 <myproc>
    80001e62:	892a                	mv	s2,a0
  sz = p->sz;
    80001e64:	652c                	ld	a1,72(a0)
    80001e66:	0005851b          	sext.w	a0,a1
  if(n > 0){
    80001e6a:	00904f63          	bgtz	s1,80001e88 <growproc+0x3c>
  } else if(n < 0){
    80001e6e:	0204cd63          	bltz	s1,80001ea8 <growproc+0x5c>
  p->sz = sz;
    80001e72:	1502                	slli	a0,a0,0x20
    80001e74:	9101                	srli	a0,a0,0x20
    80001e76:	04a93423          	sd	a0,72(s2)
  return 0;
    80001e7a:	4501                	li	a0,0
}
    80001e7c:	60e2                	ld	ra,24(sp)
    80001e7e:	6442                	ld	s0,16(sp)
    80001e80:	64a2                	ld	s1,8(sp)
    80001e82:	6902                	ld	s2,0(sp)
    80001e84:	6105                	addi	sp,sp,32
    80001e86:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001e88:	00a4863b          	addw	a2,s1,a0
    80001e8c:	1602                	slli	a2,a2,0x20
    80001e8e:	9201                	srli	a2,a2,0x20
    80001e90:	1582                	slli	a1,a1,0x20
    80001e92:	9181                	srli	a1,a1,0x20
    80001e94:	05093503          	ld	a0,80(s2)
    80001e98:	fffff097          	auipc	ra,0xfffff
    80001e9c:	6c8080e7          	jalr	1736(ra) # 80001560 <uvmalloc>
    80001ea0:	2501                	sext.w	a0,a0
    80001ea2:	f961                	bnez	a0,80001e72 <growproc+0x26>
      return -1;
    80001ea4:	557d                	li	a0,-1
    80001ea6:	bfd9                	j	80001e7c <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ea8:	00a4863b          	addw	a2,s1,a0
    80001eac:	1602                	slli	a2,a2,0x20
    80001eae:	9201                	srli	a2,a2,0x20
    80001eb0:	1582                	slli	a1,a1,0x20
    80001eb2:	9181                	srli	a1,a1,0x20
    80001eb4:	05093503          	ld	a0,80(s2)
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	662080e7          	jalr	1634(ra) # 8000151a <uvmdealloc>
    80001ec0:	2501                	sext.w	a0,a0
    80001ec2:	bf45                	j	80001e72 <growproc+0x26>

0000000080001ec4 <fork>:
{
    80001ec4:	7179                	addi	sp,sp,-48
    80001ec6:	f406                	sd	ra,40(sp)
    80001ec8:	f022                	sd	s0,32(sp)
    80001eca:	ec26                	sd	s1,24(sp)
    80001ecc:	e84a                	sd	s2,16(sp)
    80001ece:	e44e                	sd	s3,8(sp)
    80001ed0:	e052                	sd	s4,0(sp)
    80001ed2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ed4:	00000097          	auipc	ra,0x0
    80001ed8:	c00080e7          	jalr	-1024(ra) # 80001ad4 <myproc>
    80001edc:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001ede:	00000097          	auipc	ra,0x0
    80001ee2:	e20080e7          	jalr	-480(ra) # 80001cfe <allocproc>
    80001ee6:	c175                	beqz	a0,80001fca <fork+0x106>
    80001ee8:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001eea:	04893603          	ld	a2,72(s2)
    80001eee:	692c                	ld	a1,80(a0)
    80001ef0:	05093503          	ld	a0,80(s2)
    80001ef4:	fffff097          	auipc	ra,0xfffff
    80001ef8:	7b8080e7          	jalr	1976(ra) # 800016ac <uvmcopy>
    80001efc:	04054863          	bltz	a0,80001f4c <fork+0x88>
  np->sz = p->sz;
    80001f00:	04893783          	ld	a5,72(s2)
    80001f04:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80001f08:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80001f0c:	05893683          	ld	a3,88(s2)
    80001f10:	87b6                	mv	a5,a3
    80001f12:	0589b703          	ld	a4,88(s3)
    80001f16:	12068693          	addi	a3,a3,288
    80001f1a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f1e:	6788                	ld	a0,8(a5)
    80001f20:	6b8c                	ld	a1,16(a5)
    80001f22:	6f90                	ld	a2,24(a5)
    80001f24:	01073023          	sd	a6,0(a4)
    80001f28:	e708                	sd	a0,8(a4)
    80001f2a:	eb0c                	sd	a1,16(a4)
    80001f2c:	ef10                	sd	a2,24(a4)
    80001f2e:	02078793          	addi	a5,a5,32
    80001f32:	02070713          	addi	a4,a4,32
    80001f36:	fed792e3          	bne	a5,a3,80001f1a <fork+0x56>
  np->trapframe->a0 = 0;
    80001f3a:	0589b783          	ld	a5,88(s3)
    80001f3e:	0607b823          	sd	zero,112(a5)
    80001f42:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001f46:	15000a13          	li	s4,336
    80001f4a:	a03d                	j	80001f78 <fork+0xb4>
    freeproc(np);
    80001f4c:	854e                	mv	a0,s3
    80001f4e:	00000097          	auipc	ra,0x0
    80001f52:	d3a080e7          	jalr	-710(ra) # 80001c88 <freeproc>
    release(&np->lock);
    80001f56:	854e                	mv	a0,s3
    80001f58:	fffff097          	auipc	ra,0xfffff
    80001f5c:	e22080e7          	jalr	-478(ra) # 80000d7a <release>
    return -1;
    80001f60:	54fd                	li	s1,-1
    80001f62:	a899                	j	80001fb8 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f64:	00002097          	auipc	ra,0x2
    80001f68:	700080e7          	jalr	1792(ra) # 80004664 <filedup>
    80001f6c:	009987b3          	add	a5,s3,s1
    80001f70:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001f72:	04a1                	addi	s1,s1,8
    80001f74:	01448763          	beq	s1,s4,80001f82 <fork+0xbe>
    if(p->ofile[i])
    80001f78:	009907b3          	add	a5,s2,s1
    80001f7c:	6388                	ld	a0,0(a5)
    80001f7e:	f17d                	bnez	a0,80001f64 <fork+0xa0>
    80001f80:	bfcd                	j	80001f72 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001f82:	15093503          	ld	a0,336(s2)
    80001f86:	00002097          	auipc	ra,0x2
    80001f8a:	828080e7          	jalr	-2008(ra) # 800037ae <idup>
    80001f8e:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f92:	4641                	li	a2,16
    80001f94:	15890593          	addi	a1,s2,344
    80001f98:	15898513          	addi	a0,s3,344
    80001f9c:	fffff097          	auipc	ra,0xfffff
    80001fa0:	f9e080e7          	jalr	-98(ra) # 80000f3a <safestrcpy>
  pid = np->pid;
    80001fa4:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001fa8:	4789                	li	a5,2
    80001faa:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001fae:	854e                	mv	a0,s3
    80001fb0:	fffff097          	auipc	ra,0xfffff
    80001fb4:	dca080e7          	jalr	-566(ra) # 80000d7a <release>
}
    80001fb8:	8526                	mv	a0,s1
    80001fba:	70a2                	ld	ra,40(sp)
    80001fbc:	7402                	ld	s0,32(sp)
    80001fbe:	64e2                	ld	s1,24(sp)
    80001fc0:	6942                	ld	s2,16(sp)
    80001fc2:	69a2                	ld	s3,8(sp)
    80001fc4:	6a02                	ld	s4,0(sp)
    80001fc6:	6145                	addi	sp,sp,48
    80001fc8:	8082                	ret
    return -1;
    80001fca:	54fd                	li	s1,-1
    80001fcc:	b7f5                	j	80001fb8 <fork+0xf4>

0000000080001fce <reparent>:
{
    80001fce:	7179                	addi	sp,sp,-48
    80001fd0:	f406                	sd	ra,40(sp)
    80001fd2:	f022                	sd	s0,32(sp)
    80001fd4:	ec26                	sd	s1,24(sp)
    80001fd6:	e84a                	sd	s2,16(sp)
    80001fd8:	e44e                	sd	s3,8(sp)
    80001fda:	e052                	sd	s4,0(sp)
    80001fdc:	1800                	addi	s0,sp,48
    80001fde:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fe0:	00010497          	auipc	s1,0x10
    80001fe4:	d8848493          	addi	s1,s1,-632 # 80011d68 <proc>
      pp->parent = initproc;
    80001fe8:	00007a17          	auipc	s4,0x7
    80001fec:	030a0a13          	addi	s4,s4,48 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ff0:	00016917          	auipc	s2,0x16
    80001ff4:	d7890913          	addi	s2,s2,-648 # 80017d68 <tickslock>
    80001ff8:	a029                	j	80002002 <reparent+0x34>
    80001ffa:	18048493          	addi	s1,s1,384
    80001ffe:	03248363          	beq	s1,s2,80002024 <reparent+0x56>
    if(pp->parent == p){
    80002002:	709c                	ld	a5,32(s1)
    80002004:	ff379be3          	bne	a5,s3,80001ffa <reparent+0x2c>
      acquire(&pp->lock);
    80002008:	8526                	mv	a0,s1
    8000200a:	fffff097          	auipc	ra,0xfffff
    8000200e:	cbc080e7          	jalr	-836(ra) # 80000cc6 <acquire>
      pp->parent = initproc;
    80002012:	000a3783          	ld	a5,0(s4)
    80002016:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80002018:	8526                	mv	a0,s1
    8000201a:	fffff097          	auipc	ra,0xfffff
    8000201e:	d60080e7          	jalr	-672(ra) # 80000d7a <release>
    80002022:	bfe1                	j	80001ffa <reparent+0x2c>
}
    80002024:	70a2                	ld	ra,40(sp)
    80002026:	7402                	ld	s0,32(sp)
    80002028:	64e2                	ld	s1,24(sp)
    8000202a:	6942                	ld	s2,16(sp)
    8000202c:	69a2                	ld	s3,8(sp)
    8000202e:	6a02                	ld	s4,0(sp)
    80002030:	6145                	addi	sp,sp,48
    80002032:	8082                	ret

0000000080002034 <scheduler>:
{
    80002034:	715d                	addi	sp,sp,-80
    80002036:	e486                	sd	ra,72(sp)
    80002038:	e0a2                	sd	s0,64(sp)
    8000203a:	fc26                	sd	s1,56(sp)
    8000203c:	f84a                	sd	s2,48(sp)
    8000203e:	f44e                	sd	s3,40(sp)
    80002040:	f052                	sd	s4,32(sp)
    80002042:	ec56                	sd	s5,24(sp)
    80002044:	e85a                	sd	s6,16(sp)
    80002046:	e45e                	sd	s7,8(sp)
    80002048:	e062                	sd	s8,0(sp)
    8000204a:	0880                	addi	s0,sp,80
    8000204c:	8792                	mv	a5,tp
  int id = r_tp();
    8000204e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002050:	00779b13          	slli	s6,a5,0x7
    80002054:	00010717          	auipc	a4,0x10
    80002058:	8fc70713          	addi	a4,a4,-1796 # 80011950 <pid_lock>
    8000205c:	975a                	add	a4,a4,s6
    8000205e:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80002062:	00010717          	auipc	a4,0x10
    80002066:	90e70713          	addi	a4,a4,-1778 # 80011970 <cpus+0x8>
    8000206a:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    8000206c:	4c0d                	li	s8,3
        c->proc = p;
    8000206e:	079e                	slli	a5,a5,0x7
    80002070:	00010a17          	auipc	s4,0x10
    80002074:	8e0a0a13          	addi	s4,s4,-1824 # 80011950 <pid_lock>
    80002078:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000207a:	00016997          	auipc	s3,0x16
    8000207e:	cee98993          	addi	s3,s3,-786 # 80017d68 <tickslock>
        found = 1;
    80002082:	4b85                	li	s7,1
    80002084:	a899                	j	800020da <scheduler+0xa6>
        p->state = RUNNING;
    80002086:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000208a:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    8000208e:	06048593          	addi	a1,s1,96
    80002092:	855a                	mv	a0,s6
    80002094:	00000097          	auipc	ra,0x0
    80002098:	63e080e7          	jalr	1598(ra) # 800026d2 <swtch>
        c->proc = 0;
    8000209c:	000a3c23          	sd	zero,24(s4)
        found = 1;
    800020a0:	8ade                	mv	s5,s7
      release(&p->lock);
    800020a2:	8526                	mv	a0,s1
    800020a4:	fffff097          	auipc	ra,0xfffff
    800020a8:	cd6080e7          	jalr	-810(ra) # 80000d7a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800020ac:	18048493          	addi	s1,s1,384
    800020b0:	01348b63          	beq	s1,s3,800020c6 <scheduler+0x92>
      acquire(&p->lock);
    800020b4:	8526                	mv	a0,s1
    800020b6:	fffff097          	auipc	ra,0xfffff
    800020ba:	c10080e7          	jalr	-1008(ra) # 80000cc6 <acquire>
      if(p->state == RUNNABLE) {
    800020be:	4c9c                	lw	a5,24(s1)
    800020c0:	ff2791e3          	bne	a5,s2,800020a2 <scheduler+0x6e>
    800020c4:	b7c9                	j	80002086 <scheduler+0x52>
    if(found == 0) {
    800020c6:	000a9a63          	bnez	s5,800020da <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020ca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020ce:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020d2:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    800020d6:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020da:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020de:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020e2:	10079073          	csrw	sstatus,a5
    int found = 0;
    800020e6:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800020e8:	00010497          	auipc	s1,0x10
    800020ec:	c8048493          	addi	s1,s1,-896 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    800020f0:	4909                	li	s2,2
    800020f2:	b7c9                	j	800020b4 <scheduler+0x80>

00000000800020f4 <sched>:
{
    800020f4:	7179                	addi	sp,sp,-48
    800020f6:	f406                	sd	ra,40(sp)
    800020f8:	f022                	sd	s0,32(sp)
    800020fa:	ec26                	sd	s1,24(sp)
    800020fc:	e84a                	sd	s2,16(sp)
    800020fe:	e44e                	sd	s3,8(sp)
    80002100:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002102:	00000097          	auipc	ra,0x0
    80002106:	9d2080e7          	jalr	-1582(ra) # 80001ad4 <myproc>
    8000210a:	892a                	mv	s2,a0
  if(!holding(&p->lock))
    8000210c:	fffff097          	auipc	ra,0xfffff
    80002110:	b40080e7          	jalr	-1216(ra) # 80000c4c <holding>
    80002114:	cd25                	beqz	a0,8000218c <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002116:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002118:	2781                	sext.w	a5,a5
    8000211a:	079e                	slli	a5,a5,0x7
    8000211c:	00010717          	auipc	a4,0x10
    80002120:	83470713          	addi	a4,a4,-1996 # 80011950 <pid_lock>
    80002124:	97ba                	add	a5,a5,a4
    80002126:	0907a703          	lw	a4,144(a5)
    8000212a:	4785                	li	a5,1
    8000212c:	06f71863          	bne	a4,a5,8000219c <sched+0xa8>
  if(p->state == RUNNING)
    80002130:	01892703          	lw	a4,24(s2)
    80002134:	478d                	li	a5,3
    80002136:	06f70b63          	beq	a4,a5,800021ac <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000213a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000213e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002140:	efb5                	bnez	a5,800021bc <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002142:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002144:	00010497          	auipc	s1,0x10
    80002148:	80c48493          	addi	s1,s1,-2036 # 80011950 <pid_lock>
    8000214c:	2781                	sext.w	a5,a5
    8000214e:	079e                	slli	a5,a5,0x7
    80002150:	97a6                	add	a5,a5,s1
    80002152:	0947a983          	lw	s3,148(a5)
    80002156:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002158:	2781                	sext.w	a5,a5
    8000215a:	079e                	slli	a5,a5,0x7
    8000215c:	00010597          	auipc	a1,0x10
    80002160:	81458593          	addi	a1,a1,-2028 # 80011970 <cpus+0x8>
    80002164:	95be                	add	a1,a1,a5
    80002166:	06090513          	addi	a0,s2,96
    8000216a:	00000097          	auipc	ra,0x0
    8000216e:	568080e7          	jalr	1384(ra) # 800026d2 <swtch>
    80002172:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002174:	2781                	sext.w	a5,a5
    80002176:	079e                	slli	a5,a5,0x7
    80002178:	97a6                	add	a5,a5,s1
    8000217a:	0937aa23          	sw	s3,148(a5)
}
    8000217e:	70a2                	ld	ra,40(sp)
    80002180:	7402                	ld	s0,32(sp)
    80002182:	64e2                	ld	s1,24(sp)
    80002184:	6942                	ld	s2,16(sp)
    80002186:	69a2                	ld	s3,8(sp)
    80002188:	6145                	addi	sp,sp,48
    8000218a:	8082                	ret
    panic("sched p->lock");
    8000218c:	00006517          	auipc	a0,0x6
    80002190:	0b450513          	addi	a0,a0,180 # 80008240 <states.1731+0x60>
    80002194:	ffffe097          	auipc	ra,0xffffe
    80002198:	46e080e7          	jalr	1134(ra) # 80000602 <panic>
    panic("sched locks");
    8000219c:	00006517          	auipc	a0,0x6
    800021a0:	0b450513          	addi	a0,a0,180 # 80008250 <states.1731+0x70>
    800021a4:	ffffe097          	auipc	ra,0xffffe
    800021a8:	45e080e7          	jalr	1118(ra) # 80000602 <panic>
    panic("sched running");
    800021ac:	00006517          	auipc	a0,0x6
    800021b0:	0b450513          	addi	a0,a0,180 # 80008260 <states.1731+0x80>
    800021b4:	ffffe097          	auipc	ra,0xffffe
    800021b8:	44e080e7          	jalr	1102(ra) # 80000602 <panic>
    panic("sched interruptible");
    800021bc:	00006517          	auipc	a0,0x6
    800021c0:	0b450513          	addi	a0,a0,180 # 80008270 <states.1731+0x90>
    800021c4:	ffffe097          	auipc	ra,0xffffe
    800021c8:	43e080e7          	jalr	1086(ra) # 80000602 <panic>

00000000800021cc <exit>:
{
    800021cc:	7179                	addi	sp,sp,-48
    800021ce:	f406                	sd	ra,40(sp)
    800021d0:	f022                	sd	s0,32(sp)
    800021d2:	ec26                	sd	s1,24(sp)
    800021d4:	e84a                	sd	s2,16(sp)
    800021d6:	e44e                	sd	s3,8(sp)
    800021d8:	e052                	sd	s4,0(sp)
    800021da:	1800                	addi	s0,sp,48
    800021dc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021de:	00000097          	auipc	ra,0x0
    800021e2:	8f6080e7          	jalr	-1802(ra) # 80001ad4 <myproc>
    800021e6:	89aa                	mv	s3,a0
  if(p == initproc)
    800021e8:	00007797          	auipc	a5,0x7
    800021ec:	e3078793          	addi	a5,a5,-464 # 80009018 <initproc>
    800021f0:	639c                	ld	a5,0(a5)
    800021f2:	0d050493          	addi	s1,a0,208
    800021f6:	15050913          	addi	s2,a0,336
    800021fa:	02a79363          	bne	a5,a0,80002220 <exit+0x54>
    panic("init exiting");
    800021fe:	00006517          	auipc	a0,0x6
    80002202:	08a50513          	addi	a0,a0,138 # 80008288 <states.1731+0xa8>
    80002206:	ffffe097          	auipc	ra,0xffffe
    8000220a:	3fc080e7          	jalr	1020(ra) # 80000602 <panic>
      fileclose(f);
    8000220e:	00002097          	auipc	ra,0x2
    80002212:	4a8080e7          	jalr	1192(ra) # 800046b6 <fileclose>
      p->ofile[fd] = 0;
    80002216:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000221a:	04a1                	addi	s1,s1,8
    8000221c:	01248563          	beq	s1,s2,80002226 <exit+0x5a>
    if(p->ofile[fd]){
    80002220:	6088                	ld	a0,0(s1)
    80002222:	f575                	bnez	a0,8000220e <exit+0x42>
    80002224:	bfdd                	j	8000221a <exit+0x4e>
  begin_op();
    80002226:	00002097          	auipc	ra,0x2
    8000222a:	f8e080e7          	jalr	-114(ra) # 800041b4 <begin_op>
  iput(p->cwd);
    8000222e:	1509b503          	ld	a0,336(s3)
    80002232:	00001097          	auipc	ra,0x1
    80002236:	776080e7          	jalr	1910(ra) # 800039a8 <iput>
  end_op();
    8000223a:	00002097          	auipc	ra,0x2
    8000223e:	ffa080e7          	jalr	-6(ra) # 80004234 <end_op>
  p->cwd = 0;
    80002242:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    80002246:	00007497          	auipc	s1,0x7
    8000224a:	dd248493          	addi	s1,s1,-558 # 80009018 <initproc>
    8000224e:	6088                	ld	a0,0(s1)
    80002250:	fffff097          	auipc	ra,0xfffff
    80002254:	a76080e7          	jalr	-1418(ra) # 80000cc6 <acquire>
  wakeup1(initproc);
    80002258:	6088                	ld	a0,0(s1)
    8000225a:	fffff097          	auipc	ra,0xfffff
    8000225e:	73a080e7          	jalr	1850(ra) # 80001994 <wakeup1>
  release(&initproc->lock);
    80002262:	6088                	ld	a0,0(s1)
    80002264:	fffff097          	auipc	ra,0xfffff
    80002268:	b16080e7          	jalr	-1258(ra) # 80000d7a <release>
  acquire(&p->lock);
    8000226c:	854e                	mv	a0,s3
    8000226e:	fffff097          	auipc	ra,0xfffff
    80002272:	a58080e7          	jalr	-1448(ra) # 80000cc6 <acquire>
  struct proc *original_parent = p->parent;
    80002276:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    8000227a:	854e                	mv	a0,s3
    8000227c:	fffff097          	auipc	ra,0xfffff
    80002280:	afe080e7          	jalr	-1282(ra) # 80000d7a <release>
  acquire(&original_parent->lock);
    80002284:	8526                	mv	a0,s1
    80002286:	fffff097          	auipc	ra,0xfffff
    8000228a:	a40080e7          	jalr	-1472(ra) # 80000cc6 <acquire>
  acquire(&p->lock);
    8000228e:	854e                	mv	a0,s3
    80002290:	fffff097          	auipc	ra,0xfffff
    80002294:	a36080e7          	jalr	-1482(ra) # 80000cc6 <acquire>
  reparent(p);
    80002298:	854e                	mv	a0,s3
    8000229a:	00000097          	auipc	ra,0x0
    8000229e:	d34080e7          	jalr	-716(ra) # 80001fce <reparent>
  wakeup1(original_parent);
    800022a2:	8526                	mv	a0,s1
    800022a4:	fffff097          	auipc	ra,0xfffff
    800022a8:	6f0080e7          	jalr	1776(ra) # 80001994 <wakeup1>
  p->xstate = status;
    800022ac:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800022b0:	4791                	li	a5,4
    800022b2:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800022b6:	8526                	mv	a0,s1
    800022b8:	fffff097          	auipc	ra,0xfffff
    800022bc:	ac2080e7          	jalr	-1342(ra) # 80000d7a <release>
  sched();
    800022c0:	00000097          	auipc	ra,0x0
    800022c4:	e34080e7          	jalr	-460(ra) # 800020f4 <sched>
  panic("zombie exit");
    800022c8:	00006517          	auipc	a0,0x6
    800022cc:	fd050513          	addi	a0,a0,-48 # 80008298 <states.1731+0xb8>
    800022d0:	ffffe097          	auipc	ra,0xffffe
    800022d4:	332080e7          	jalr	818(ra) # 80000602 <panic>

00000000800022d8 <yield>:
{
    800022d8:	1101                	addi	sp,sp,-32
    800022da:	ec06                	sd	ra,24(sp)
    800022dc:	e822                	sd	s0,16(sp)
    800022de:	e426                	sd	s1,8(sp)
    800022e0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800022e2:	fffff097          	auipc	ra,0xfffff
    800022e6:	7f2080e7          	jalr	2034(ra) # 80001ad4 <myproc>
    800022ea:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022ec:	fffff097          	auipc	ra,0xfffff
    800022f0:	9da080e7          	jalr	-1574(ra) # 80000cc6 <acquire>
  p->state = RUNNABLE;
    800022f4:	4789                	li	a5,2
    800022f6:	cc9c                	sw	a5,24(s1)
  sched();
    800022f8:	00000097          	auipc	ra,0x0
    800022fc:	dfc080e7          	jalr	-516(ra) # 800020f4 <sched>
  release(&p->lock);
    80002300:	8526                	mv	a0,s1
    80002302:	fffff097          	auipc	ra,0xfffff
    80002306:	a78080e7          	jalr	-1416(ra) # 80000d7a <release>
}
    8000230a:	60e2                	ld	ra,24(sp)
    8000230c:	6442                	ld	s0,16(sp)
    8000230e:	64a2                	ld	s1,8(sp)
    80002310:	6105                	addi	sp,sp,32
    80002312:	8082                	ret

0000000080002314 <sleep>:
{
    80002314:	7179                	addi	sp,sp,-48
    80002316:	f406                	sd	ra,40(sp)
    80002318:	f022                	sd	s0,32(sp)
    8000231a:	ec26                	sd	s1,24(sp)
    8000231c:	e84a                	sd	s2,16(sp)
    8000231e:	e44e                	sd	s3,8(sp)
    80002320:	1800                	addi	s0,sp,48
    80002322:	89aa                	mv	s3,a0
    80002324:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002326:	fffff097          	auipc	ra,0xfffff
    8000232a:	7ae080e7          	jalr	1966(ra) # 80001ad4 <myproc>
    8000232e:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002330:	05250663          	beq	a0,s2,8000237c <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002334:	fffff097          	auipc	ra,0xfffff
    80002338:	992080e7          	jalr	-1646(ra) # 80000cc6 <acquire>
    release(lk);
    8000233c:	854a                	mv	a0,s2
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	a3c080e7          	jalr	-1476(ra) # 80000d7a <release>
  p->chan = chan;
    80002346:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    8000234a:	4785                	li	a5,1
    8000234c:	cc9c                	sw	a5,24(s1)
  sched();
    8000234e:	00000097          	auipc	ra,0x0
    80002352:	da6080e7          	jalr	-602(ra) # 800020f4 <sched>
  p->chan = 0;
    80002356:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    8000235a:	8526                	mv	a0,s1
    8000235c:	fffff097          	auipc	ra,0xfffff
    80002360:	a1e080e7          	jalr	-1506(ra) # 80000d7a <release>
    acquire(lk);
    80002364:	854a                	mv	a0,s2
    80002366:	fffff097          	auipc	ra,0xfffff
    8000236a:	960080e7          	jalr	-1696(ra) # 80000cc6 <acquire>
}
    8000236e:	70a2                	ld	ra,40(sp)
    80002370:	7402                	ld	s0,32(sp)
    80002372:	64e2                	ld	s1,24(sp)
    80002374:	6942                	ld	s2,16(sp)
    80002376:	69a2                	ld	s3,8(sp)
    80002378:	6145                	addi	sp,sp,48
    8000237a:	8082                	ret
  p->chan = chan;
    8000237c:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002380:	4785                	li	a5,1
    80002382:	cd1c                	sw	a5,24(a0)
  sched();
    80002384:	00000097          	auipc	ra,0x0
    80002388:	d70080e7          	jalr	-656(ra) # 800020f4 <sched>
  p->chan = 0;
    8000238c:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002390:	bff9                	j	8000236e <sleep+0x5a>

0000000080002392 <wait>:
{
    80002392:	715d                	addi	sp,sp,-80
    80002394:	e486                	sd	ra,72(sp)
    80002396:	e0a2                	sd	s0,64(sp)
    80002398:	fc26                	sd	s1,56(sp)
    8000239a:	f84a                	sd	s2,48(sp)
    8000239c:	f44e                	sd	s3,40(sp)
    8000239e:	f052                	sd	s4,32(sp)
    800023a0:	ec56                	sd	s5,24(sp)
    800023a2:	e85a                	sd	s6,16(sp)
    800023a4:	e45e                	sd	s7,8(sp)
    800023a6:	e062                	sd	s8,0(sp)
    800023a8:	0880                	addi	s0,sp,80
    800023aa:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800023ac:	fffff097          	auipc	ra,0xfffff
    800023b0:	728080e7          	jalr	1832(ra) # 80001ad4 <myproc>
    800023b4:	892a                	mv	s2,a0
  acquire(&p->lock);
    800023b6:	8c2a                	mv	s8,a0
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	90e080e7          	jalr	-1778(ra) # 80000cc6 <acquire>
    havekids = 0;
    800023c0:	4b01                	li	s6,0
        if(np->state == ZOMBIE){
    800023c2:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800023c4:	00016997          	auipc	s3,0x16
    800023c8:	9a498993          	addi	s3,s3,-1628 # 80017d68 <tickslock>
        havekids = 1;
    800023cc:	4a85                	li	s5,1
    havekids = 0;
    800023ce:	875a                	mv	a4,s6
    for(np = proc; np < &proc[NPROC]; np++){
    800023d0:	00010497          	auipc	s1,0x10
    800023d4:	99848493          	addi	s1,s1,-1640 # 80011d68 <proc>
    800023d8:	a08d                	j	8000243a <wait+0xa8>
          pid = np->pid;
    800023da:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800023de:	000b8e63          	beqz	s7,800023fa <wait+0x68>
    800023e2:	4691                	li	a3,4
    800023e4:	03448613          	addi	a2,s1,52
    800023e8:	85de                	mv	a1,s7
    800023ea:	05093503          	ld	a0,80(s2)
    800023ee:	fffff097          	auipc	ra,0xfffff
    800023f2:	3c2080e7          	jalr	962(ra) # 800017b0 <copyout>
    800023f6:	02054263          	bltz	a0,8000241a <wait+0x88>
          freeproc(np);
    800023fa:	8526                	mv	a0,s1
    800023fc:	00000097          	auipc	ra,0x0
    80002400:	88c080e7          	jalr	-1908(ra) # 80001c88 <freeproc>
          release(&np->lock);
    80002404:	8526                	mv	a0,s1
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	974080e7          	jalr	-1676(ra) # 80000d7a <release>
          release(&p->lock);
    8000240e:	854a                	mv	a0,s2
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	96a080e7          	jalr	-1686(ra) # 80000d7a <release>
          return pid;
    80002418:	a8a9                	j	80002472 <wait+0xe0>
            release(&np->lock);
    8000241a:	8526                	mv	a0,s1
    8000241c:	fffff097          	auipc	ra,0xfffff
    80002420:	95e080e7          	jalr	-1698(ra) # 80000d7a <release>
            release(&p->lock);
    80002424:	854a                	mv	a0,s2
    80002426:	fffff097          	auipc	ra,0xfffff
    8000242a:	954080e7          	jalr	-1708(ra) # 80000d7a <release>
            return -1;
    8000242e:	59fd                	li	s3,-1
    80002430:	a089                	j	80002472 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002432:	18048493          	addi	s1,s1,384
    80002436:	03348463          	beq	s1,s3,8000245e <wait+0xcc>
      if(np->parent == p){
    8000243a:	709c                	ld	a5,32(s1)
    8000243c:	ff279be3          	bne	a5,s2,80002432 <wait+0xa0>
        acquire(&np->lock);
    80002440:	8526                	mv	a0,s1
    80002442:	fffff097          	auipc	ra,0xfffff
    80002446:	884080e7          	jalr	-1916(ra) # 80000cc6 <acquire>
        if(np->state == ZOMBIE){
    8000244a:	4c9c                	lw	a5,24(s1)
    8000244c:	f94787e3          	beq	a5,s4,800023da <wait+0x48>
        release(&np->lock);
    80002450:	8526                	mv	a0,s1
    80002452:	fffff097          	auipc	ra,0xfffff
    80002456:	928080e7          	jalr	-1752(ra) # 80000d7a <release>
        havekids = 1;
    8000245a:	8756                	mv	a4,s5
    8000245c:	bfd9                	j	80002432 <wait+0xa0>
    if(!havekids || p->killed){
    8000245e:	c701                	beqz	a4,80002466 <wait+0xd4>
    80002460:	03092783          	lw	a5,48(s2)
    80002464:	c785                	beqz	a5,8000248c <wait+0xfa>
      release(&p->lock);
    80002466:	854a                	mv	a0,s2
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	912080e7          	jalr	-1774(ra) # 80000d7a <release>
      return -1;
    80002470:	59fd                	li	s3,-1
}
    80002472:	854e                	mv	a0,s3
    80002474:	60a6                	ld	ra,72(sp)
    80002476:	6406                	ld	s0,64(sp)
    80002478:	74e2                	ld	s1,56(sp)
    8000247a:	7942                	ld	s2,48(sp)
    8000247c:	79a2                	ld	s3,40(sp)
    8000247e:	7a02                	ld	s4,32(sp)
    80002480:	6ae2                	ld	s5,24(sp)
    80002482:	6b42                	ld	s6,16(sp)
    80002484:	6ba2                	ld	s7,8(sp)
    80002486:	6c02                	ld	s8,0(sp)
    80002488:	6161                	addi	sp,sp,80
    8000248a:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000248c:	85e2                	mv	a1,s8
    8000248e:	854a                	mv	a0,s2
    80002490:	00000097          	auipc	ra,0x0
    80002494:	e84080e7          	jalr	-380(ra) # 80002314 <sleep>
    havekids = 0;
    80002498:	bf1d                	j	800023ce <wait+0x3c>

000000008000249a <wakeup>:
{
    8000249a:	7139                	addi	sp,sp,-64
    8000249c:	fc06                	sd	ra,56(sp)
    8000249e:	f822                	sd	s0,48(sp)
    800024a0:	f426                	sd	s1,40(sp)
    800024a2:	f04a                	sd	s2,32(sp)
    800024a4:	ec4e                	sd	s3,24(sp)
    800024a6:	e852                	sd	s4,16(sp)
    800024a8:	e456                	sd	s5,8(sp)
    800024aa:	0080                	addi	s0,sp,64
    800024ac:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800024ae:	00010497          	auipc	s1,0x10
    800024b2:	8ba48493          	addi	s1,s1,-1862 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800024b6:	4985                	li	s3,1
      p->state = RUNNABLE;
    800024b8:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800024ba:	00016917          	auipc	s2,0x16
    800024be:	8ae90913          	addi	s2,s2,-1874 # 80017d68 <tickslock>
    800024c2:	a821                	j	800024da <wakeup+0x40>
      p->state = RUNNABLE;
    800024c4:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    800024c8:	8526                	mv	a0,s1
    800024ca:	fffff097          	auipc	ra,0xfffff
    800024ce:	8b0080e7          	jalr	-1872(ra) # 80000d7a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800024d2:	18048493          	addi	s1,s1,384
    800024d6:	01248e63          	beq	s1,s2,800024f2 <wakeup+0x58>
    acquire(&p->lock);
    800024da:	8526                	mv	a0,s1
    800024dc:	ffffe097          	auipc	ra,0xffffe
    800024e0:	7ea080e7          	jalr	2026(ra) # 80000cc6 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800024e4:	4c9c                	lw	a5,24(s1)
    800024e6:	ff3791e3          	bne	a5,s3,800024c8 <wakeup+0x2e>
    800024ea:	749c                	ld	a5,40(s1)
    800024ec:	fd479ee3          	bne	a5,s4,800024c8 <wakeup+0x2e>
    800024f0:	bfd1                	j	800024c4 <wakeup+0x2a>
}
    800024f2:	70e2                	ld	ra,56(sp)
    800024f4:	7442                	ld	s0,48(sp)
    800024f6:	74a2                	ld	s1,40(sp)
    800024f8:	7902                	ld	s2,32(sp)
    800024fa:	69e2                	ld	s3,24(sp)
    800024fc:	6a42                	ld	s4,16(sp)
    800024fe:	6aa2                	ld	s5,8(sp)
    80002500:	6121                	addi	sp,sp,64
    80002502:	8082                	ret

0000000080002504 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002504:	7179                	addi	sp,sp,-48
    80002506:	f406                	sd	ra,40(sp)
    80002508:	f022                	sd	s0,32(sp)
    8000250a:	ec26                	sd	s1,24(sp)
    8000250c:	e84a                	sd	s2,16(sp)
    8000250e:	e44e                	sd	s3,8(sp)
    80002510:	1800                	addi	s0,sp,48
    80002512:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002514:	00010497          	auipc	s1,0x10
    80002518:	85448493          	addi	s1,s1,-1964 # 80011d68 <proc>
    8000251c:	00016997          	auipc	s3,0x16
    80002520:	84c98993          	addi	s3,s3,-1972 # 80017d68 <tickslock>
    acquire(&p->lock);
    80002524:	8526                	mv	a0,s1
    80002526:	ffffe097          	auipc	ra,0xffffe
    8000252a:	7a0080e7          	jalr	1952(ra) # 80000cc6 <acquire>
    if(p->pid == pid){
    8000252e:	5c9c                	lw	a5,56(s1)
    80002530:	01278d63          	beq	a5,s2,8000254a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002534:	8526                	mv	a0,s1
    80002536:	fffff097          	auipc	ra,0xfffff
    8000253a:	844080e7          	jalr	-1980(ra) # 80000d7a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000253e:	18048493          	addi	s1,s1,384
    80002542:	ff3491e3          	bne	s1,s3,80002524 <kill+0x20>
  }
  return -1;
    80002546:	557d                	li	a0,-1
    80002548:	a829                	j	80002562 <kill+0x5e>
      p->killed = 1;
    8000254a:	4785                	li	a5,1
    8000254c:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    8000254e:	4c98                	lw	a4,24(s1)
    80002550:	4785                	li	a5,1
    80002552:	00f70f63          	beq	a4,a5,80002570 <kill+0x6c>
      release(&p->lock);
    80002556:	8526                	mv	a0,s1
    80002558:	fffff097          	auipc	ra,0xfffff
    8000255c:	822080e7          	jalr	-2014(ra) # 80000d7a <release>
      return 0;
    80002560:	4501                	li	a0,0
}
    80002562:	70a2                	ld	ra,40(sp)
    80002564:	7402                	ld	s0,32(sp)
    80002566:	64e2                	ld	s1,24(sp)
    80002568:	6942                	ld	s2,16(sp)
    8000256a:	69a2                	ld	s3,8(sp)
    8000256c:	6145                	addi	sp,sp,48
    8000256e:	8082                	ret
        p->state = RUNNABLE;
    80002570:	4789                	li	a5,2
    80002572:	cc9c                	sw	a5,24(s1)
    80002574:	b7cd                	j	80002556 <kill+0x52>

0000000080002576 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002576:	7179                	addi	sp,sp,-48
    80002578:	f406                	sd	ra,40(sp)
    8000257a:	f022                	sd	s0,32(sp)
    8000257c:	ec26                	sd	s1,24(sp)
    8000257e:	e84a                	sd	s2,16(sp)
    80002580:	e44e                	sd	s3,8(sp)
    80002582:	e052                	sd	s4,0(sp)
    80002584:	1800                	addi	s0,sp,48
    80002586:	84aa                	mv	s1,a0
    80002588:	892e                	mv	s2,a1
    8000258a:	89b2                	mv	s3,a2
    8000258c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000258e:	fffff097          	auipc	ra,0xfffff
    80002592:	546080e7          	jalr	1350(ra) # 80001ad4 <myproc>
  if(user_dst){
    80002596:	c08d                	beqz	s1,800025b8 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002598:	86d2                	mv	a3,s4
    8000259a:	864e                	mv	a2,s3
    8000259c:	85ca                	mv	a1,s2
    8000259e:	6928                	ld	a0,80(a0)
    800025a0:	fffff097          	auipc	ra,0xfffff
    800025a4:	210080e7          	jalr	528(ra) # 800017b0 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025a8:	70a2                	ld	ra,40(sp)
    800025aa:	7402                	ld	s0,32(sp)
    800025ac:	64e2                	ld	s1,24(sp)
    800025ae:	6942                	ld	s2,16(sp)
    800025b0:	69a2                	ld	s3,8(sp)
    800025b2:	6a02                	ld	s4,0(sp)
    800025b4:	6145                	addi	sp,sp,48
    800025b6:	8082                	ret
    memmove((char *)dst, src, len);
    800025b8:	000a061b          	sext.w	a2,s4
    800025bc:	85ce                	mv	a1,s3
    800025be:	854a                	mv	a0,s2
    800025c0:	fffff097          	auipc	ra,0xfffff
    800025c4:	86e080e7          	jalr	-1938(ra) # 80000e2e <memmove>
    return 0;
    800025c8:	8526                	mv	a0,s1
    800025ca:	bff9                	j	800025a8 <either_copyout+0x32>

00000000800025cc <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025cc:	7179                	addi	sp,sp,-48
    800025ce:	f406                	sd	ra,40(sp)
    800025d0:	f022                	sd	s0,32(sp)
    800025d2:	ec26                	sd	s1,24(sp)
    800025d4:	e84a                	sd	s2,16(sp)
    800025d6:	e44e                	sd	s3,8(sp)
    800025d8:	e052                	sd	s4,0(sp)
    800025da:	1800                	addi	s0,sp,48
    800025dc:	892a                	mv	s2,a0
    800025de:	84ae                	mv	s1,a1
    800025e0:	89b2                	mv	s3,a2
    800025e2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025e4:	fffff097          	auipc	ra,0xfffff
    800025e8:	4f0080e7          	jalr	1264(ra) # 80001ad4 <myproc>
  if(user_src){
    800025ec:	c08d                	beqz	s1,8000260e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800025ee:	86d2                	mv	a3,s4
    800025f0:	864e                	mv	a2,s3
    800025f2:	85ca                	mv	a1,s2
    800025f4:	6928                	ld	a0,80(a0)
    800025f6:	fffff097          	auipc	ra,0xfffff
    800025fa:	246080e7          	jalr	582(ra) # 8000183c <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025fe:	70a2                	ld	ra,40(sp)
    80002600:	7402                	ld	s0,32(sp)
    80002602:	64e2                	ld	s1,24(sp)
    80002604:	6942                	ld	s2,16(sp)
    80002606:	69a2                	ld	s3,8(sp)
    80002608:	6a02                	ld	s4,0(sp)
    8000260a:	6145                	addi	sp,sp,48
    8000260c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000260e:	000a061b          	sext.w	a2,s4
    80002612:	85ce                	mv	a1,s3
    80002614:	854a                	mv	a0,s2
    80002616:	fffff097          	auipc	ra,0xfffff
    8000261a:	818080e7          	jalr	-2024(ra) # 80000e2e <memmove>
    return 0;
    8000261e:	8526                	mv	a0,s1
    80002620:	bff9                	j	800025fe <either_copyin+0x32>

0000000080002622 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002622:	715d                	addi	sp,sp,-80
    80002624:	e486                	sd	ra,72(sp)
    80002626:	e0a2                	sd	s0,64(sp)
    80002628:	fc26                	sd	s1,56(sp)
    8000262a:	f84a                	sd	s2,48(sp)
    8000262c:	f44e                	sd	s3,40(sp)
    8000262e:	f052                	sd	s4,32(sp)
    80002630:	ec56                	sd	s5,24(sp)
    80002632:	e85a                	sd	s6,16(sp)
    80002634:	e45e                	sd	s7,8(sp)
    80002636:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002638:	00006517          	auipc	a0,0x6
    8000263c:	aa850513          	addi	a0,a0,-1368 # 800080e0 <digits+0xc8>
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	014080e7          	jalr	20(ra) # 80000654 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002648:	00010497          	auipc	s1,0x10
    8000264c:	87848493          	addi	s1,s1,-1928 # 80011ec0 <proc+0x158>
    80002650:	00016917          	auipc	s2,0x16
    80002654:	87090913          	addi	s2,s2,-1936 # 80017ec0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002658:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    8000265a:	00006997          	auipc	s3,0x6
    8000265e:	c4e98993          	addi	s3,s3,-946 # 800082a8 <states.1731+0xc8>
    printf("%d %s %s", p->pid, state, p->name);
    80002662:	00006a97          	auipc	s5,0x6
    80002666:	c4ea8a93          	addi	s5,s5,-946 # 800082b0 <states.1731+0xd0>
    printf("\n");
    8000266a:	00006a17          	auipc	s4,0x6
    8000266e:	a76a0a13          	addi	s4,s4,-1418 # 800080e0 <digits+0xc8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002672:	00006b97          	auipc	s7,0x6
    80002676:	b6eb8b93          	addi	s7,s7,-1170 # 800081e0 <states.1731>
    8000267a:	a015                	j	8000269e <procdump+0x7c>
    printf("%d %s %s", p->pid, state, p->name);
    8000267c:	86ba                	mv	a3,a4
    8000267e:	ee072583          	lw	a1,-288(a4)
    80002682:	8556                	mv	a0,s5
    80002684:	ffffe097          	auipc	ra,0xffffe
    80002688:	fd0080e7          	jalr	-48(ra) # 80000654 <printf>
    printf("\n");
    8000268c:	8552                	mv	a0,s4
    8000268e:	ffffe097          	auipc	ra,0xffffe
    80002692:	fc6080e7          	jalr	-58(ra) # 80000654 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002696:	18048493          	addi	s1,s1,384
    8000269a:	03248163          	beq	s1,s2,800026bc <procdump+0x9a>
    if(p->state == UNUSED)
    8000269e:	8726                	mv	a4,s1
    800026a0:	ec04a783          	lw	a5,-320(s1)
    800026a4:	dbed                	beqz	a5,80002696 <procdump+0x74>
      state = "???";
    800026a6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026a8:	fcfb6ae3          	bltu	s6,a5,8000267c <procdump+0x5a>
    800026ac:	1782                	slli	a5,a5,0x20
    800026ae:	9381                	srli	a5,a5,0x20
    800026b0:	078e                	slli	a5,a5,0x3
    800026b2:	97de                	add	a5,a5,s7
    800026b4:	6390                	ld	a2,0(a5)
    800026b6:	f279                	bnez	a2,8000267c <procdump+0x5a>
      state = "???";
    800026b8:	864e                	mv	a2,s3
    800026ba:	b7c9                	j	8000267c <procdump+0x5a>
  }
}
    800026bc:	60a6                	ld	ra,72(sp)
    800026be:	6406                	ld	s0,64(sp)
    800026c0:	74e2                	ld	s1,56(sp)
    800026c2:	7942                	ld	s2,48(sp)
    800026c4:	79a2                	ld	s3,40(sp)
    800026c6:	7a02                	ld	s4,32(sp)
    800026c8:	6ae2                	ld	s5,24(sp)
    800026ca:	6b42                	ld	s6,16(sp)
    800026cc:	6ba2                	ld	s7,8(sp)
    800026ce:	6161                	addi	sp,sp,80
    800026d0:	8082                	ret

00000000800026d2 <swtch>:
    800026d2:	00153023          	sd	ra,0(a0)
    800026d6:	00253423          	sd	sp,8(a0)
    800026da:	e900                	sd	s0,16(a0)
    800026dc:	ed04                	sd	s1,24(a0)
    800026de:	03253023          	sd	s2,32(a0)
    800026e2:	03353423          	sd	s3,40(a0)
    800026e6:	03453823          	sd	s4,48(a0)
    800026ea:	03553c23          	sd	s5,56(a0)
    800026ee:	05653023          	sd	s6,64(a0)
    800026f2:	05753423          	sd	s7,72(a0)
    800026f6:	05853823          	sd	s8,80(a0)
    800026fa:	05953c23          	sd	s9,88(a0)
    800026fe:	07a53023          	sd	s10,96(a0)
    80002702:	07b53423          	sd	s11,104(a0)
    80002706:	0005b083          	ld	ra,0(a1)
    8000270a:	0085b103          	ld	sp,8(a1)
    8000270e:	6980                	ld	s0,16(a1)
    80002710:	6d84                	ld	s1,24(a1)
    80002712:	0205b903          	ld	s2,32(a1)
    80002716:	0285b983          	ld	s3,40(a1)
    8000271a:	0305ba03          	ld	s4,48(a1)
    8000271e:	0385ba83          	ld	s5,56(a1)
    80002722:	0405bb03          	ld	s6,64(a1)
    80002726:	0485bb83          	ld	s7,72(a1)
    8000272a:	0505bc03          	ld	s8,80(a1)
    8000272e:	0585bc83          	ld	s9,88(a1)
    80002732:	0605bd03          	ld	s10,96(a1)
    80002736:	0685bd83          	ld	s11,104(a1)
    8000273a:	8082                	ret

000000008000273c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000273c:	1141                	addi	sp,sp,-16
    8000273e:	e406                	sd	ra,8(sp)
    80002740:	e022                	sd	s0,0(sp)
    80002742:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002744:	00006597          	auipc	a1,0x6
    80002748:	ba458593          	addi	a1,a1,-1116 # 800082e8 <states.1731+0x108>
    8000274c:	00015517          	auipc	a0,0x15
    80002750:	61c50513          	addi	a0,a0,1564 # 80017d68 <tickslock>
    80002754:	ffffe097          	auipc	ra,0xffffe
    80002758:	4e2080e7          	jalr	1250(ra) # 80000c36 <initlock>
}
    8000275c:	60a2                	ld	ra,8(sp)
    8000275e:	6402                	ld	s0,0(sp)
    80002760:	0141                	addi	sp,sp,16
    80002762:	8082                	ret

0000000080002764 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002764:	1141                	addi	sp,sp,-16
    80002766:	e422                	sd	s0,8(sp)
    80002768:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000276a:	00003797          	auipc	a5,0x3
    8000276e:	6a678793          	addi	a5,a5,1702 # 80005e10 <kernelvec>
    80002772:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002776:	6422                	ld	s0,8(sp)
    80002778:	0141                	addi	sp,sp,16
    8000277a:	8082                	ret

000000008000277c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000277c:	1141                	addi	sp,sp,-16
    8000277e:	e406                	sd	ra,8(sp)
    80002780:	e022                	sd	s0,0(sp)
    80002782:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002784:	fffff097          	auipc	ra,0xfffff
    80002788:	350080e7          	jalr	848(ra) # 80001ad4 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000278c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002790:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002792:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002796:	00005617          	auipc	a2,0x5
    8000279a:	86a60613          	addi	a2,a2,-1942 # 80007000 <_trampoline>
    8000279e:	00005697          	auipc	a3,0x5
    800027a2:	86268693          	addi	a3,a3,-1950 # 80007000 <_trampoline>
    800027a6:	8e91                	sub	a3,a3,a2
    800027a8:	040007b7          	lui	a5,0x4000
    800027ac:	17fd                	addi	a5,a5,-1
    800027ae:	07b2                	slli	a5,a5,0xc
    800027b0:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027b2:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027b6:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027b8:	180026f3          	csrr	a3,satp
    800027bc:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027be:	6d38                	ld	a4,88(a0)
    800027c0:	6134                	ld	a3,64(a0)
    800027c2:	6585                	lui	a1,0x1
    800027c4:	96ae                	add	a3,a3,a1
    800027c6:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027c8:	6d38                	ld	a4,88(a0)
    800027ca:	00000697          	auipc	a3,0x0
    800027ce:	13868693          	addi	a3,a3,312 # 80002902 <usertrap>
    800027d2:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027d4:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027d6:	8692                	mv	a3,tp
    800027d8:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027da:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027de:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027e2:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027e6:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027ea:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027ec:	6f18                	ld	a4,24(a4)
    800027ee:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800027f2:	692c                	ld	a1,80(a0)
    800027f4:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800027f6:	00005717          	auipc	a4,0x5
    800027fa:	89a70713          	addi	a4,a4,-1894 # 80007090 <userret>
    800027fe:	8f11                	sub	a4,a4,a2
    80002800:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002802:	577d                	li	a4,-1
    80002804:	177e                	slli	a4,a4,0x3f
    80002806:	8dd9                	or	a1,a1,a4
    80002808:	02000537          	lui	a0,0x2000
    8000280c:	157d                	addi	a0,a0,-1
    8000280e:	0536                	slli	a0,a0,0xd
    80002810:	9782                	jalr	a5
}
    80002812:	60a2                	ld	ra,8(sp)
    80002814:	6402                	ld	s0,0(sp)
    80002816:	0141                	addi	sp,sp,16
    80002818:	8082                	ret

000000008000281a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000281a:	1101                	addi	sp,sp,-32
    8000281c:	ec06                	sd	ra,24(sp)
    8000281e:	e822                	sd	s0,16(sp)
    80002820:	e426                	sd	s1,8(sp)
    80002822:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002824:	00015497          	auipc	s1,0x15
    80002828:	54448493          	addi	s1,s1,1348 # 80017d68 <tickslock>
    8000282c:	8526                	mv	a0,s1
    8000282e:	ffffe097          	auipc	ra,0xffffe
    80002832:	498080e7          	jalr	1176(ra) # 80000cc6 <acquire>
  ticks++;
    80002836:	00006517          	auipc	a0,0x6
    8000283a:	7ea50513          	addi	a0,a0,2026 # 80009020 <ticks>
    8000283e:	411c                	lw	a5,0(a0)
    80002840:	2785                	addiw	a5,a5,1
    80002842:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002844:	00000097          	auipc	ra,0x0
    80002848:	c56080e7          	jalr	-938(ra) # 8000249a <wakeup>
  release(&tickslock);
    8000284c:	8526                	mv	a0,s1
    8000284e:	ffffe097          	auipc	ra,0xffffe
    80002852:	52c080e7          	jalr	1324(ra) # 80000d7a <release>
}
    80002856:	60e2                	ld	ra,24(sp)
    80002858:	6442                	ld	s0,16(sp)
    8000285a:	64a2                	ld	s1,8(sp)
    8000285c:	6105                	addi	sp,sp,32
    8000285e:	8082                	ret

0000000080002860 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002860:	1101                	addi	sp,sp,-32
    80002862:	ec06                	sd	ra,24(sp)
    80002864:	e822                	sd	s0,16(sp)
    80002866:	e426                	sd	s1,8(sp)
    80002868:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000286a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000286e:	00074d63          	bltz	a4,80002888 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002872:	57fd                	li	a5,-1
    80002874:	17fe                	slli	a5,a5,0x3f
    80002876:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002878:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000287a:	06f70363          	beq	a4,a5,800028e0 <devintr+0x80>
  }
}
    8000287e:	60e2                	ld	ra,24(sp)
    80002880:	6442                	ld	s0,16(sp)
    80002882:	64a2                	ld	s1,8(sp)
    80002884:	6105                	addi	sp,sp,32
    80002886:	8082                	ret
     (scause & 0xff) == 9){
    80002888:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000288c:	46a5                	li	a3,9
    8000288e:	fed792e3          	bne	a5,a3,80002872 <devintr+0x12>
    int irq = plic_claim();
    80002892:	00003097          	auipc	ra,0x3
    80002896:	686080e7          	jalr	1670(ra) # 80005f18 <plic_claim>
    8000289a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000289c:	47a9                	li	a5,10
    8000289e:	02f50763          	beq	a0,a5,800028cc <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800028a2:	4785                	li	a5,1
    800028a4:	02f50963          	beq	a0,a5,800028d6 <devintr+0x76>
    return 1;
    800028a8:	4505                	li	a0,1
    } else if(irq){
    800028aa:	d8f1                	beqz	s1,8000287e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800028ac:	85a6                	mv	a1,s1
    800028ae:	00006517          	auipc	a0,0x6
    800028b2:	a4250513          	addi	a0,a0,-1470 # 800082f0 <states.1731+0x110>
    800028b6:	ffffe097          	auipc	ra,0xffffe
    800028ba:	d9e080e7          	jalr	-610(ra) # 80000654 <printf>
      plic_complete(irq);
    800028be:	8526                	mv	a0,s1
    800028c0:	00003097          	auipc	ra,0x3
    800028c4:	67c080e7          	jalr	1660(ra) # 80005f3c <plic_complete>
    return 1;
    800028c8:	4505                	li	a0,1
    800028ca:	bf55                	j	8000287e <devintr+0x1e>
      uartintr();
    800028cc:	ffffe097          	auipc	ra,0xffffe
    800028d0:	1ba080e7          	jalr	442(ra) # 80000a86 <uartintr>
    800028d4:	b7ed                	j	800028be <devintr+0x5e>
      virtio_disk_intr();
    800028d6:	00004097          	auipc	ra,0x4
    800028da:	b12080e7          	jalr	-1262(ra) # 800063e8 <virtio_disk_intr>
    800028de:	b7c5                	j	800028be <devintr+0x5e>
    if(cpuid() == 0){
    800028e0:	fffff097          	auipc	ra,0xfffff
    800028e4:	1c8080e7          	jalr	456(ra) # 80001aa8 <cpuid>
    800028e8:	c901                	beqz	a0,800028f8 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800028ea:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800028ee:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800028f0:	14479073          	csrw	sip,a5
    return 2;
    800028f4:	4509                	li	a0,2
    800028f6:	b761                	j	8000287e <devintr+0x1e>
      clockintr();
    800028f8:	00000097          	auipc	ra,0x0
    800028fc:	f22080e7          	jalr	-222(ra) # 8000281a <clockintr>
    80002900:	b7ed                	j	800028ea <devintr+0x8a>

0000000080002902 <usertrap>:
{
    80002902:	1101                	addi	sp,sp,-32
    80002904:	ec06                	sd	ra,24(sp)
    80002906:	e822                	sd	s0,16(sp)
    80002908:	e426                	sd	s1,8(sp)
    8000290a:	e04a                	sd	s2,0(sp)
    8000290c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000290e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002912:	1007f793          	andi	a5,a5,256
    80002916:	e3ad                	bnez	a5,80002978 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002918:	00003797          	auipc	a5,0x3
    8000291c:	4f878793          	addi	a5,a5,1272 # 80005e10 <kernelvec>
    80002920:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002924:	fffff097          	auipc	ra,0xfffff
    80002928:	1b0080e7          	jalr	432(ra) # 80001ad4 <myproc>
    8000292c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000292e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002930:	14102773          	csrr	a4,sepc
    80002934:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002936:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000293a:	47a1                	li	a5,8
    8000293c:	04f71c63          	bne	a4,a5,80002994 <usertrap+0x92>
    if(p->killed)
    80002940:	591c                	lw	a5,48(a0)
    80002942:	e3b9                	bnez	a5,80002988 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002944:	6cb8                	ld	a4,88(s1)
    80002946:	6f1c                	ld	a5,24(a4)
    80002948:	0791                	addi	a5,a5,4
    8000294a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000294c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002950:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002954:	10079073          	csrw	sstatus,a5
    syscall();
    80002958:	00000097          	auipc	ra,0x0
    8000295c:	340080e7          	jalr	832(ra) # 80002c98 <syscall>
  if(p->killed)
    80002960:	589c                	lw	a5,48(s1)
    80002962:	ebcd                	bnez	a5,80002a14 <usertrap+0x112>
  usertrapret();
    80002964:	00000097          	auipc	ra,0x0
    80002968:	e18080e7          	jalr	-488(ra) # 8000277c <usertrapret>
}
    8000296c:	60e2                	ld	ra,24(sp)
    8000296e:	6442                	ld	s0,16(sp)
    80002970:	64a2                	ld	s1,8(sp)
    80002972:	6902                	ld	s2,0(sp)
    80002974:	6105                	addi	sp,sp,32
    80002976:	8082                	ret
    panic("usertrap: not from user mode");
    80002978:	00006517          	auipc	a0,0x6
    8000297c:	99850513          	addi	a0,a0,-1640 # 80008310 <states.1731+0x130>
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	c82080e7          	jalr	-894(ra) # 80000602 <panic>
      exit(-1);
    80002988:	557d                	li	a0,-1
    8000298a:	00000097          	auipc	ra,0x0
    8000298e:	842080e7          	jalr	-1982(ra) # 800021cc <exit>
    80002992:	bf4d                	j	80002944 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002994:	00000097          	auipc	ra,0x0
    80002998:	ecc080e7          	jalr	-308(ra) # 80002860 <devintr>
    8000299c:	892a                	mv	s2,a0
    8000299e:	c501                	beqz	a0,800029a6 <usertrap+0xa4>
  if(p->killed)
    800029a0:	589c                	lw	a5,48(s1)
    800029a2:	c3a1                	beqz	a5,800029e2 <usertrap+0xe0>
    800029a4:	a815                	j	800029d8 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029a6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029aa:	5c90                	lw	a2,56(s1)
    800029ac:	00006517          	auipc	a0,0x6
    800029b0:	98450513          	addi	a0,a0,-1660 # 80008330 <states.1731+0x150>
    800029b4:	ffffe097          	auipc	ra,0xffffe
    800029b8:	ca0080e7          	jalr	-864(ra) # 80000654 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029bc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029c0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029c4:	00006517          	auipc	a0,0x6
    800029c8:	99c50513          	addi	a0,a0,-1636 # 80008360 <states.1731+0x180>
    800029cc:	ffffe097          	auipc	ra,0xffffe
    800029d0:	c88080e7          	jalr	-888(ra) # 80000654 <printf>
    p->killed = 1;
    800029d4:	4785                	li	a5,1
    800029d6:	d89c                	sw	a5,48(s1)
    exit(-1);
    800029d8:	557d                	li	a0,-1
    800029da:	fffff097          	auipc	ra,0xfffff
    800029de:	7f2080e7          	jalr	2034(ra) # 800021cc <exit>
  if(which_dev == 2){
    800029e2:	4789                	li	a5,2
    800029e4:	f8f910e3          	bne	s2,a5,80002964 <usertrap+0x62>
    if(p->alarm != 0){
    800029e8:	16c4a703          	lw	a4,364(s1)
    800029ec:	cf29                	beqz	a4,80002a46 <usertrap+0x144>
      p->duration++;
    800029ee:	1684a783          	lw	a5,360(s1)
    800029f2:	2785                	addiw	a5,a5,1
    800029f4:	0007869b          	sext.w	a3,a5
    800029f8:	16f4a423          	sw	a5,360(s1)
      if(p->duration == p->alarm){
    800029fc:	04d71063          	bne	a4,a3,80002a3c <usertrap+0x13a>
        p->duration = 0;
    80002a00:	1604a423          	sw	zero,360(s1)
        if(p->alarm_trapframe == 0){
    80002a04:	1784b783          	ld	a5,376(s1)
    80002a08:	cb81                	beqz	a5,80002a18 <usertrap+0x116>
          yield();
    80002a0a:	00000097          	auipc	ra,0x0
    80002a0e:	8ce080e7          	jalr	-1842(ra) # 800022d8 <yield>
    80002a12:	bf89                	j	80002964 <usertrap+0x62>
  int which_dev = 0;
    80002a14:	4901                	li	s2,0
    80002a16:	b7c9                	j	800029d8 <usertrap+0xd6>
          p->alarm_trapframe = kalloc();
    80002a18:	ffffe097          	auipc	ra,0xffffe
    80002a1c:	1be080e7          	jalr	446(ra) # 80000bd6 <kalloc>
    80002a20:	16a4bc23          	sd	a0,376(s1)
          memmove(p->alarm_trapframe, p->trapframe, 512);
    80002a24:	20000613          	li	a2,512
    80002a28:	6cac                	ld	a1,88(s1)
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	404080e7          	jalr	1028(ra) # 80000e2e <memmove>
          p->trapframe->epc = p->handler;
    80002a32:	6cbc                	ld	a5,88(s1)
    80002a34:	1704b703          	ld	a4,368(s1)
    80002a38:	ef98                	sd	a4,24(a5)
    80002a3a:	b72d                	j	80002964 <usertrap+0x62>
        yield();
    80002a3c:	00000097          	auipc	ra,0x0
    80002a40:	89c080e7          	jalr	-1892(ra) # 800022d8 <yield>
    80002a44:	b705                	j	80002964 <usertrap+0x62>
      yield();
    80002a46:	00000097          	auipc	ra,0x0
    80002a4a:	892080e7          	jalr	-1902(ra) # 800022d8 <yield>
    80002a4e:	bf19                	j	80002964 <usertrap+0x62>

0000000080002a50 <kerneltrap>:
{
    80002a50:	7179                	addi	sp,sp,-48
    80002a52:	f406                	sd	ra,40(sp)
    80002a54:	f022                	sd	s0,32(sp)
    80002a56:	ec26                	sd	s1,24(sp)
    80002a58:	e84a                	sd	s2,16(sp)
    80002a5a:	e44e                	sd	s3,8(sp)
    80002a5c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a5e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a62:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a66:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a6a:	1004f793          	andi	a5,s1,256
    80002a6e:	cb85                	beqz	a5,80002a9e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a70:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a74:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a76:	ef85                	bnez	a5,80002aae <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a78:	00000097          	auipc	ra,0x0
    80002a7c:	de8080e7          	jalr	-536(ra) # 80002860 <devintr>
    80002a80:	cd1d                	beqz	a0,80002abe <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a82:	4789                	li	a5,2
    80002a84:	06f50a63          	beq	a0,a5,80002af8 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a88:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a8c:	10049073          	csrw	sstatus,s1
}
    80002a90:	70a2                	ld	ra,40(sp)
    80002a92:	7402                	ld	s0,32(sp)
    80002a94:	64e2                	ld	s1,24(sp)
    80002a96:	6942                	ld	s2,16(sp)
    80002a98:	69a2                	ld	s3,8(sp)
    80002a9a:	6145                	addi	sp,sp,48
    80002a9c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a9e:	00006517          	auipc	a0,0x6
    80002aa2:	8e250513          	addi	a0,a0,-1822 # 80008380 <states.1731+0x1a0>
    80002aa6:	ffffe097          	auipc	ra,0xffffe
    80002aaa:	b5c080e7          	jalr	-1188(ra) # 80000602 <panic>
    panic("kerneltrap: interrupts enabled");
    80002aae:	00006517          	auipc	a0,0x6
    80002ab2:	8fa50513          	addi	a0,a0,-1798 # 800083a8 <states.1731+0x1c8>
    80002ab6:	ffffe097          	auipc	ra,0xffffe
    80002aba:	b4c080e7          	jalr	-1204(ra) # 80000602 <panic>
    printf("scause %p\n", scause);
    80002abe:	85ce                	mv	a1,s3
    80002ac0:	00006517          	auipc	a0,0x6
    80002ac4:	90850513          	addi	a0,a0,-1784 # 800083c8 <states.1731+0x1e8>
    80002ac8:	ffffe097          	auipc	ra,0xffffe
    80002acc:	b8c080e7          	jalr	-1140(ra) # 80000654 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ad0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ad4:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ad8:	00006517          	auipc	a0,0x6
    80002adc:	90050513          	addi	a0,a0,-1792 # 800083d8 <states.1731+0x1f8>
    80002ae0:	ffffe097          	auipc	ra,0xffffe
    80002ae4:	b74080e7          	jalr	-1164(ra) # 80000654 <printf>
    panic("kerneltrap");
    80002ae8:	00006517          	auipc	a0,0x6
    80002aec:	90850513          	addi	a0,a0,-1784 # 800083f0 <states.1731+0x210>
    80002af0:	ffffe097          	auipc	ra,0xffffe
    80002af4:	b12080e7          	jalr	-1262(ra) # 80000602 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002af8:	fffff097          	auipc	ra,0xfffff
    80002afc:	fdc080e7          	jalr	-36(ra) # 80001ad4 <myproc>
    80002b00:	d541                	beqz	a0,80002a88 <kerneltrap+0x38>
    80002b02:	fffff097          	auipc	ra,0xfffff
    80002b06:	fd2080e7          	jalr	-46(ra) # 80001ad4 <myproc>
    80002b0a:	4d18                	lw	a4,24(a0)
    80002b0c:	478d                	li	a5,3
    80002b0e:	f6f71de3          	bne	a4,a5,80002a88 <kerneltrap+0x38>
    yield();
    80002b12:	fffff097          	auipc	ra,0xfffff
    80002b16:	7c6080e7          	jalr	1990(ra) # 800022d8 <yield>
    80002b1a:	b7bd                	j	80002a88 <kerneltrap+0x38>

0000000080002b1c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b1c:	1101                	addi	sp,sp,-32
    80002b1e:	ec06                	sd	ra,24(sp)
    80002b20:	e822                	sd	s0,16(sp)
    80002b22:	e426                	sd	s1,8(sp)
    80002b24:	1000                	addi	s0,sp,32
    80002b26:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b28:	fffff097          	auipc	ra,0xfffff
    80002b2c:	fac080e7          	jalr	-84(ra) # 80001ad4 <myproc>
  switch (n) {
    80002b30:	4795                	li	a5,5
    80002b32:	0497e363          	bltu	a5,s1,80002b78 <argraw+0x5c>
    80002b36:	1482                	slli	s1,s1,0x20
    80002b38:	9081                	srli	s1,s1,0x20
    80002b3a:	048a                	slli	s1,s1,0x2
    80002b3c:	00006717          	auipc	a4,0x6
    80002b40:	8c470713          	addi	a4,a4,-1852 # 80008400 <states.1731+0x220>
    80002b44:	94ba                	add	s1,s1,a4
    80002b46:	409c                	lw	a5,0(s1)
    80002b48:	97ba                	add	a5,a5,a4
    80002b4a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b4c:	6d3c                	ld	a5,88(a0)
    80002b4e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b50:	60e2                	ld	ra,24(sp)
    80002b52:	6442                	ld	s0,16(sp)
    80002b54:	64a2                	ld	s1,8(sp)
    80002b56:	6105                	addi	sp,sp,32
    80002b58:	8082                	ret
    return p->trapframe->a1;
    80002b5a:	6d3c                	ld	a5,88(a0)
    80002b5c:	7fa8                	ld	a0,120(a5)
    80002b5e:	bfcd                	j	80002b50 <argraw+0x34>
    return p->trapframe->a2;
    80002b60:	6d3c                	ld	a5,88(a0)
    80002b62:	63c8                	ld	a0,128(a5)
    80002b64:	b7f5                	j	80002b50 <argraw+0x34>
    return p->trapframe->a3;
    80002b66:	6d3c                	ld	a5,88(a0)
    80002b68:	67c8                	ld	a0,136(a5)
    80002b6a:	b7dd                	j	80002b50 <argraw+0x34>
    return p->trapframe->a4;
    80002b6c:	6d3c                	ld	a5,88(a0)
    80002b6e:	6bc8                	ld	a0,144(a5)
    80002b70:	b7c5                	j	80002b50 <argraw+0x34>
    return p->trapframe->a5;
    80002b72:	6d3c                	ld	a5,88(a0)
    80002b74:	6fc8                	ld	a0,152(a5)
    80002b76:	bfe9                	j	80002b50 <argraw+0x34>
  panic("argraw");
    80002b78:	00006517          	auipc	a0,0x6
    80002b7c:	96050513          	addi	a0,a0,-1696 # 800084d8 <syscalls+0xc0>
    80002b80:	ffffe097          	auipc	ra,0xffffe
    80002b84:	a82080e7          	jalr	-1406(ra) # 80000602 <panic>

0000000080002b88 <fetchaddr>:
{
    80002b88:	1101                	addi	sp,sp,-32
    80002b8a:	ec06                	sd	ra,24(sp)
    80002b8c:	e822                	sd	s0,16(sp)
    80002b8e:	e426                	sd	s1,8(sp)
    80002b90:	e04a                	sd	s2,0(sp)
    80002b92:	1000                	addi	s0,sp,32
    80002b94:	84aa                	mv	s1,a0
    80002b96:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b98:	fffff097          	auipc	ra,0xfffff
    80002b9c:	f3c080e7          	jalr	-196(ra) # 80001ad4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002ba0:	653c                	ld	a5,72(a0)
    80002ba2:	02f4f963          	bleu	a5,s1,80002bd4 <fetchaddr+0x4c>
    80002ba6:	00848713          	addi	a4,s1,8
    80002baa:	02e7e763          	bltu	a5,a4,80002bd8 <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002bae:	46a1                	li	a3,8
    80002bb0:	8626                	mv	a2,s1
    80002bb2:	85ca                	mv	a1,s2
    80002bb4:	6928                	ld	a0,80(a0)
    80002bb6:	fffff097          	auipc	ra,0xfffff
    80002bba:	c86080e7          	jalr	-890(ra) # 8000183c <copyin>
    80002bbe:	00a03533          	snez	a0,a0
    80002bc2:	40a0053b          	negw	a0,a0
    80002bc6:	2501                	sext.w	a0,a0
}
    80002bc8:	60e2                	ld	ra,24(sp)
    80002bca:	6442                	ld	s0,16(sp)
    80002bcc:	64a2                	ld	s1,8(sp)
    80002bce:	6902                	ld	s2,0(sp)
    80002bd0:	6105                	addi	sp,sp,32
    80002bd2:	8082                	ret
    return -1;
    80002bd4:	557d                	li	a0,-1
    80002bd6:	bfcd                	j	80002bc8 <fetchaddr+0x40>
    80002bd8:	557d                	li	a0,-1
    80002bda:	b7fd                	j	80002bc8 <fetchaddr+0x40>

0000000080002bdc <fetchstr>:
{
    80002bdc:	7179                	addi	sp,sp,-48
    80002bde:	f406                	sd	ra,40(sp)
    80002be0:	f022                	sd	s0,32(sp)
    80002be2:	ec26                	sd	s1,24(sp)
    80002be4:	e84a                	sd	s2,16(sp)
    80002be6:	e44e                	sd	s3,8(sp)
    80002be8:	1800                	addi	s0,sp,48
    80002bea:	892a                	mv	s2,a0
    80002bec:	84ae                	mv	s1,a1
    80002bee:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002bf0:	fffff097          	auipc	ra,0xfffff
    80002bf4:	ee4080e7          	jalr	-284(ra) # 80001ad4 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002bf8:	86ce                	mv	a3,s3
    80002bfa:	864a                	mv	a2,s2
    80002bfc:	85a6                	mv	a1,s1
    80002bfe:	6928                	ld	a0,80(a0)
    80002c00:	fffff097          	auipc	ra,0xfffff
    80002c04:	cca080e7          	jalr	-822(ra) # 800018ca <copyinstr>
  if(err < 0)
    80002c08:	00054763          	bltz	a0,80002c16 <fetchstr+0x3a>
  return strlen(buf);
    80002c0c:	8526                	mv	a0,s1
    80002c0e:	ffffe097          	auipc	ra,0xffffe
    80002c12:	35e080e7          	jalr	862(ra) # 80000f6c <strlen>
}
    80002c16:	70a2                	ld	ra,40(sp)
    80002c18:	7402                	ld	s0,32(sp)
    80002c1a:	64e2                	ld	s1,24(sp)
    80002c1c:	6942                	ld	s2,16(sp)
    80002c1e:	69a2                	ld	s3,8(sp)
    80002c20:	6145                	addi	sp,sp,48
    80002c22:	8082                	ret

0000000080002c24 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002c24:	1101                	addi	sp,sp,-32
    80002c26:	ec06                	sd	ra,24(sp)
    80002c28:	e822                	sd	s0,16(sp)
    80002c2a:	e426                	sd	s1,8(sp)
    80002c2c:	1000                	addi	s0,sp,32
    80002c2e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c30:	00000097          	auipc	ra,0x0
    80002c34:	eec080e7          	jalr	-276(ra) # 80002b1c <argraw>
    80002c38:	c088                	sw	a0,0(s1)
  return 0;
}
    80002c3a:	4501                	li	a0,0
    80002c3c:	60e2                	ld	ra,24(sp)
    80002c3e:	6442                	ld	s0,16(sp)
    80002c40:	64a2                	ld	s1,8(sp)
    80002c42:	6105                	addi	sp,sp,32
    80002c44:	8082                	ret

0000000080002c46 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002c46:	1101                	addi	sp,sp,-32
    80002c48:	ec06                	sd	ra,24(sp)
    80002c4a:	e822                	sd	s0,16(sp)
    80002c4c:	e426                	sd	s1,8(sp)
    80002c4e:	1000                	addi	s0,sp,32
    80002c50:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c52:	00000097          	auipc	ra,0x0
    80002c56:	eca080e7          	jalr	-310(ra) # 80002b1c <argraw>
    80002c5a:	e088                	sd	a0,0(s1)
  return 0;
}
    80002c5c:	4501                	li	a0,0
    80002c5e:	60e2                	ld	ra,24(sp)
    80002c60:	6442                	ld	s0,16(sp)
    80002c62:	64a2                	ld	s1,8(sp)
    80002c64:	6105                	addi	sp,sp,32
    80002c66:	8082                	ret

0000000080002c68 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c68:	1101                	addi	sp,sp,-32
    80002c6a:	ec06                	sd	ra,24(sp)
    80002c6c:	e822                	sd	s0,16(sp)
    80002c6e:	e426                	sd	s1,8(sp)
    80002c70:	e04a                	sd	s2,0(sp)
    80002c72:	1000                	addi	s0,sp,32
    80002c74:	84ae                	mv	s1,a1
    80002c76:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002c78:	00000097          	auipc	ra,0x0
    80002c7c:	ea4080e7          	jalr	-348(ra) # 80002b1c <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c80:	864a                	mv	a2,s2
    80002c82:	85a6                	mv	a1,s1
    80002c84:	00000097          	auipc	ra,0x0
    80002c88:	f58080e7          	jalr	-168(ra) # 80002bdc <fetchstr>
}
    80002c8c:	60e2                	ld	ra,24(sp)
    80002c8e:	6442                	ld	s0,16(sp)
    80002c90:	64a2                	ld	s1,8(sp)
    80002c92:	6902                	ld	s2,0(sp)
    80002c94:	6105                	addi	sp,sp,32
    80002c96:	8082                	ret

0000000080002c98 <syscall>:
[SYS_sigreturn] sys_sigreturn,
};

void
syscall(void)
{
    80002c98:	1101                	addi	sp,sp,-32
    80002c9a:	ec06                	sd	ra,24(sp)
    80002c9c:	e822                	sd	s0,16(sp)
    80002c9e:	e426                	sd	s1,8(sp)
    80002ca0:	e04a                	sd	s2,0(sp)
    80002ca2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ca4:	fffff097          	auipc	ra,0xfffff
    80002ca8:	e30080e7          	jalr	-464(ra) # 80001ad4 <myproc>
    80002cac:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002cae:	05853903          	ld	s2,88(a0)
    80002cb2:	0a893783          	ld	a5,168(s2)
    80002cb6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002cba:	37fd                	addiw	a5,a5,-1
    80002cbc:	4759                	li	a4,22
    80002cbe:	00f76f63          	bltu	a4,a5,80002cdc <syscall+0x44>
    80002cc2:	00369713          	slli	a4,a3,0x3
    80002cc6:	00005797          	auipc	a5,0x5
    80002cca:	75278793          	addi	a5,a5,1874 # 80008418 <syscalls>
    80002cce:	97ba                	add	a5,a5,a4
    80002cd0:	639c                	ld	a5,0(a5)
    80002cd2:	c789                	beqz	a5,80002cdc <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002cd4:	9782                	jalr	a5
    80002cd6:	06a93823          	sd	a0,112(s2)
    80002cda:	a839                	j	80002cf8 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002cdc:	15848613          	addi	a2,s1,344
    80002ce0:	5c8c                	lw	a1,56(s1)
    80002ce2:	00005517          	auipc	a0,0x5
    80002ce6:	7fe50513          	addi	a0,a0,2046 # 800084e0 <syscalls+0xc8>
    80002cea:	ffffe097          	auipc	ra,0xffffe
    80002cee:	96a080e7          	jalr	-1686(ra) # 80000654 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002cf2:	6cbc                	ld	a5,88(s1)
    80002cf4:	577d                	li	a4,-1
    80002cf6:	fbb8                	sd	a4,112(a5)
  }
}
    80002cf8:	60e2                	ld	ra,24(sp)
    80002cfa:	6442                	ld	s0,16(sp)
    80002cfc:	64a2                	ld	s1,8(sp)
    80002cfe:	6902                	ld	s2,0(sp)
    80002d00:	6105                	addi	sp,sp,32
    80002d02:	8082                	ret

0000000080002d04 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d04:	1101                	addi	sp,sp,-32
    80002d06:	ec06                	sd	ra,24(sp)
    80002d08:	e822                	sd	s0,16(sp)
    80002d0a:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002d0c:	fec40593          	addi	a1,s0,-20
    80002d10:	4501                	li	a0,0
    80002d12:	00000097          	auipc	ra,0x0
    80002d16:	f12080e7          	jalr	-238(ra) # 80002c24 <argint>
    return -1;
    80002d1a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d1c:	00054963          	bltz	a0,80002d2e <sys_exit+0x2a>
  exit(n);
    80002d20:	fec42503          	lw	a0,-20(s0)
    80002d24:	fffff097          	auipc	ra,0xfffff
    80002d28:	4a8080e7          	jalr	1192(ra) # 800021cc <exit>
  return 0;  // not reached
    80002d2c:	4781                	li	a5,0
}
    80002d2e:	853e                	mv	a0,a5
    80002d30:	60e2                	ld	ra,24(sp)
    80002d32:	6442                	ld	s0,16(sp)
    80002d34:	6105                	addi	sp,sp,32
    80002d36:	8082                	ret

0000000080002d38 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d38:	1141                	addi	sp,sp,-16
    80002d3a:	e406                	sd	ra,8(sp)
    80002d3c:	e022                	sd	s0,0(sp)
    80002d3e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d40:	fffff097          	auipc	ra,0xfffff
    80002d44:	d94080e7          	jalr	-620(ra) # 80001ad4 <myproc>
}
    80002d48:	5d08                	lw	a0,56(a0)
    80002d4a:	60a2                	ld	ra,8(sp)
    80002d4c:	6402                	ld	s0,0(sp)
    80002d4e:	0141                	addi	sp,sp,16
    80002d50:	8082                	ret

0000000080002d52 <sys_fork>:

uint64
sys_fork(void)
{
    80002d52:	1141                	addi	sp,sp,-16
    80002d54:	e406                	sd	ra,8(sp)
    80002d56:	e022                	sd	s0,0(sp)
    80002d58:	0800                	addi	s0,sp,16
  return fork();
    80002d5a:	fffff097          	auipc	ra,0xfffff
    80002d5e:	16a080e7          	jalr	362(ra) # 80001ec4 <fork>
}
    80002d62:	60a2                	ld	ra,8(sp)
    80002d64:	6402                	ld	s0,0(sp)
    80002d66:	0141                	addi	sp,sp,16
    80002d68:	8082                	ret

0000000080002d6a <sys_wait>:

uint64
sys_wait(void)
{
    80002d6a:	1101                	addi	sp,sp,-32
    80002d6c:	ec06                	sd	ra,24(sp)
    80002d6e:	e822                	sd	s0,16(sp)
    80002d70:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002d72:	fe840593          	addi	a1,s0,-24
    80002d76:	4501                	li	a0,0
    80002d78:	00000097          	auipc	ra,0x0
    80002d7c:	ece080e7          	jalr	-306(ra) # 80002c46 <argaddr>
    return -1;
    80002d80:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    80002d82:	00054963          	bltz	a0,80002d94 <sys_wait+0x2a>
  return wait(p);
    80002d86:	fe843503          	ld	a0,-24(s0)
    80002d8a:	fffff097          	auipc	ra,0xfffff
    80002d8e:	608080e7          	jalr	1544(ra) # 80002392 <wait>
    80002d92:	87aa                	mv	a5,a0
}
    80002d94:	853e                	mv	a0,a5
    80002d96:	60e2                	ld	ra,24(sp)
    80002d98:	6442                	ld	s0,16(sp)
    80002d9a:	6105                	addi	sp,sp,32
    80002d9c:	8082                	ret

0000000080002d9e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d9e:	7179                	addi	sp,sp,-48
    80002da0:	f406                	sd	ra,40(sp)
    80002da2:	f022                	sd	s0,32(sp)
    80002da4:	ec26                	sd	s1,24(sp)
    80002da6:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002da8:	fdc40593          	addi	a1,s0,-36
    80002dac:	4501                	li	a0,0
    80002dae:	00000097          	auipc	ra,0x0
    80002db2:	e76080e7          	jalr	-394(ra) # 80002c24 <argint>
    return -1;
    80002db6:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002db8:	00054f63          	bltz	a0,80002dd6 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002dbc:	fffff097          	auipc	ra,0xfffff
    80002dc0:	d18080e7          	jalr	-744(ra) # 80001ad4 <myproc>
    80002dc4:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002dc6:	fdc42503          	lw	a0,-36(s0)
    80002dca:	fffff097          	auipc	ra,0xfffff
    80002dce:	082080e7          	jalr	130(ra) # 80001e4c <growproc>
    80002dd2:	00054863          	bltz	a0,80002de2 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002dd6:	8526                	mv	a0,s1
    80002dd8:	70a2                	ld	ra,40(sp)
    80002dda:	7402                	ld	s0,32(sp)
    80002ddc:	64e2                	ld	s1,24(sp)
    80002dde:	6145                	addi	sp,sp,48
    80002de0:	8082                	ret
    return -1;
    80002de2:	54fd                	li	s1,-1
    80002de4:	bfcd                	j	80002dd6 <sys_sbrk+0x38>

0000000080002de6 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002de6:	7139                	addi	sp,sp,-64
    80002de8:	fc06                	sd	ra,56(sp)
    80002dea:	f822                	sd	s0,48(sp)
    80002dec:	f426                	sd	s1,40(sp)
    80002dee:	f04a                	sd	s2,32(sp)
    80002df0:	ec4e                	sd	s3,24(sp)
    80002df2:	0080                	addi	s0,sp,64
  backtrace();
    80002df4:	ffffd097          	auipc	ra,0xffffd
    80002df8:	7b2080e7          	jalr	1970(ra) # 800005a6 <backtrace>
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002dfc:	fcc40593          	addi	a1,s0,-52
    80002e00:	4501                	li	a0,0
    80002e02:	00000097          	auipc	ra,0x0
    80002e06:	e22080e7          	jalr	-478(ra) # 80002c24 <argint>
    return -1;
    80002e0a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e0c:	06054763          	bltz	a0,80002e7a <sys_sleep+0x94>
  acquire(&tickslock);
    80002e10:	00015517          	auipc	a0,0x15
    80002e14:	f5850513          	addi	a0,a0,-168 # 80017d68 <tickslock>
    80002e18:	ffffe097          	auipc	ra,0xffffe
    80002e1c:	eae080e7          	jalr	-338(ra) # 80000cc6 <acquire>
  ticks0 = ticks;
    80002e20:	00006797          	auipc	a5,0x6
    80002e24:	20078793          	addi	a5,a5,512 # 80009020 <ticks>
    80002e28:	0007a903          	lw	s2,0(a5)
  while(ticks - ticks0 < n){
    80002e2c:	fcc42783          	lw	a5,-52(s0)
    80002e30:	cf85                	beqz	a5,80002e68 <sys_sleep+0x82>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e32:	00015997          	auipc	s3,0x15
    80002e36:	f3698993          	addi	s3,s3,-202 # 80017d68 <tickslock>
    80002e3a:	00006497          	auipc	s1,0x6
    80002e3e:	1e648493          	addi	s1,s1,486 # 80009020 <ticks>
    if(myproc()->killed){
    80002e42:	fffff097          	auipc	ra,0xfffff
    80002e46:	c92080e7          	jalr	-878(ra) # 80001ad4 <myproc>
    80002e4a:	591c                	lw	a5,48(a0)
    80002e4c:	ef9d                	bnez	a5,80002e8a <sys_sleep+0xa4>
    sleep(&ticks, &tickslock);
    80002e4e:	85ce                	mv	a1,s3
    80002e50:	8526                	mv	a0,s1
    80002e52:	fffff097          	auipc	ra,0xfffff
    80002e56:	4c2080e7          	jalr	1218(ra) # 80002314 <sleep>
  while(ticks - ticks0 < n){
    80002e5a:	409c                	lw	a5,0(s1)
    80002e5c:	412787bb          	subw	a5,a5,s2
    80002e60:	fcc42703          	lw	a4,-52(s0)
    80002e64:	fce7efe3          	bltu	a5,a4,80002e42 <sys_sleep+0x5c>
  }
  release(&tickslock);
    80002e68:	00015517          	auipc	a0,0x15
    80002e6c:	f0050513          	addi	a0,a0,-256 # 80017d68 <tickslock>
    80002e70:	ffffe097          	auipc	ra,0xffffe
    80002e74:	f0a080e7          	jalr	-246(ra) # 80000d7a <release>
  return 0;
    80002e78:	4781                	li	a5,0
}
    80002e7a:	853e                	mv	a0,a5
    80002e7c:	70e2                	ld	ra,56(sp)
    80002e7e:	7442                	ld	s0,48(sp)
    80002e80:	74a2                	ld	s1,40(sp)
    80002e82:	7902                	ld	s2,32(sp)
    80002e84:	69e2                	ld	s3,24(sp)
    80002e86:	6121                	addi	sp,sp,64
    80002e88:	8082                	ret
      release(&tickslock);
    80002e8a:	00015517          	auipc	a0,0x15
    80002e8e:	ede50513          	addi	a0,a0,-290 # 80017d68 <tickslock>
    80002e92:	ffffe097          	auipc	ra,0xffffe
    80002e96:	ee8080e7          	jalr	-280(ra) # 80000d7a <release>
      return -1;
    80002e9a:	57fd                	li	a5,-1
    80002e9c:	bff9                	j	80002e7a <sys_sleep+0x94>

0000000080002e9e <sys_kill>:

uint64
sys_kill(void)
{
    80002e9e:	1101                	addi	sp,sp,-32
    80002ea0:	ec06                	sd	ra,24(sp)
    80002ea2:	e822                	sd	s0,16(sp)
    80002ea4:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002ea6:	fec40593          	addi	a1,s0,-20
    80002eaa:	4501                	li	a0,0
    80002eac:	00000097          	auipc	ra,0x0
    80002eb0:	d78080e7          	jalr	-648(ra) # 80002c24 <argint>
    return -1;
    80002eb4:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    80002eb6:	00054963          	bltz	a0,80002ec8 <sys_kill+0x2a>
  return kill(pid);
    80002eba:	fec42503          	lw	a0,-20(s0)
    80002ebe:	fffff097          	auipc	ra,0xfffff
    80002ec2:	646080e7          	jalr	1606(ra) # 80002504 <kill>
    80002ec6:	87aa                	mv	a5,a0
}
    80002ec8:	853e                	mv	a0,a5
    80002eca:	60e2                	ld	ra,24(sp)
    80002ecc:	6442                	ld	s0,16(sp)
    80002ece:	6105                	addi	sp,sp,32
    80002ed0:	8082                	ret

0000000080002ed2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ed2:	1101                	addi	sp,sp,-32
    80002ed4:	ec06                	sd	ra,24(sp)
    80002ed6:	e822                	sd	s0,16(sp)
    80002ed8:	e426                	sd	s1,8(sp)
    80002eda:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002edc:	00015517          	auipc	a0,0x15
    80002ee0:	e8c50513          	addi	a0,a0,-372 # 80017d68 <tickslock>
    80002ee4:	ffffe097          	auipc	ra,0xffffe
    80002ee8:	de2080e7          	jalr	-542(ra) # 80000cc6 <acquire>
  xticks = ticks;
    80002eec:	00006797          	auipc	a5,0x6
    80002ef0:	13478793          	addi	a5,a5,308 # 80009020 <ticks>
    80002ef4:	4384                	lw	s1,0(a5)
  release(&tickslock);
    80002ef6:	00015517          	auipc	a0,0x15
    80002efa:	e7250513          	addi	a0,a0,-398 # 80017d68 <tickslock>
    80002efe:	ffffe097          	auipc	ra,0xffffe
    80002f02:	e7c080e7          	jalr	-388(ra) # 80000d7a <release>
  return xticks;
}
    80002f06:	02049513          	slli	a0,s1,0x20
    80002f0a:	9101                	srli	a0,a0,0x20
    80002f0c:	60e2                	ld	ra,24(sp)
    80002f0e:	6442                	ld	s0,16(sp)
    80002f10:	64a2                	ld	s1,8(sp)
    80002f12:	6105                	addi	sp,sp,32
    80002f14:	8082                	ret

0000000080002f16 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f16:	7179                	addi	sp,sp,-48
    80002f18:	f406                	sd	ra,40(sp)
    80002f1a:	f022                	sd	s0,32(sp)
    80002f1c:	ec26                	sd	s1,24(sp)
    80002f1e:	e84a                	sd	s2,16(sp)
    80002f20:	e44e                	sd	s3,8(sp)
    80002f22:	e052                	sd	s4,0(sp)
    80002f24:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f26:	00005597          	auipc	a1,0x5
    80002f2a:	5da58593          	addi	a1,a1,1498 # 80008500 <syscalls+0xe8>
    80002f2e:	00015517          	auipc	a0,0x15
    80002f32:	e5250513          	addi	a0,a0,-430 # 80017d80 <bcache>
    80002f36:	ffffe097          	auipc	ra,0xffffe
    80002f3a:	d00080e7          	jalr	-768(ra) # 80000c36 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f3e:	0001d797          	auipc	a5,0x1d
    80002f42:	e4278793          	addi	a5,a5,-446 # 8001fd80 <bcache+0x8000>
    80002f46:	0001d717          	auipc	a4,0x1d
    80002f4a:	0a270713          	addi	a4,a4,162 # 8001ffe8 <bcache+0x8268>
    80002f4e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f52:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f56:	00015497          	auipc	s1,0x15
    80002f5a:	e4248493          	addi	s1,s1,-446 # 80017d98 <bcache+0x18>
    b->next = bcache.head.next;
    80002f5e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f60:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f62:	00005a17          	auipc	s4,0x5
    80002f66:	5a6a0a13          	addi	s4,s4,1446 # 80008508 <syscalls+0xf0>
    b->next = bcache.head.next;
    80002f6a:	2b893783          	ld	a5,696(s2)
    80002f6e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f70:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f74:	85d2                	mv	a1,s4
    80002f76:	01048513          	addi	a0,s1,16
    80002f7a:	00001097          	auipc	ra,0x1
    80002f7e:	51a080e7          	jalr	1306(ra) # 80004494 <initsleeplock>
    bcache.head.next->prev = b;
    80002f82:	2b893783          	ld	a5,696(s2)
    80002f86:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f88:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f8c:	45848493          	addi	s1,s1,1112
    80002f90:	fd349de3          	bne	s1,s3,80002f6a <binit+0x54>
  }
}
    80002f94:	70a2                	ld	ra,40(sp)
    80002f96:	7402                	ld	s0,32(sp)
    80002f98:	64e2                	ld	s1,24(sp)
    80002f9a:	6942                	ld	s2,16(sp)
    80002f9c:	69a2                	ld	s3,8(sp)
    80002f9e:	6a02                	ld	s4,0(sp)
    80002fa0:	6145                	addi	sp,sp,48
    80002fa2:	8082                	ret

0000000080002fa4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002fa4:	7179                	addi	sp,sp,-48
    80002fa6:	f406                	sd	ra,40(sp)
    80002fa8:	f022                	sd	s0,32(sp)
    80002faa:	ec26                	sd	s1,24(sp)
    80002fac:	e84a                	sd	s2,16(sp)
    80002fae:	e44e                	sd	s3,8(sp)
    80002fb0:	1800                	addi	s0,sp,48
    80002fb2:	89aa                	mv	s3,a0
    80002fb4:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002fb6:	00015517          	auipc	a0,0x15
    80002fba:	dca50513          	addi	a0,a0,-566 # 80017d80 <bcache>
    80002fbe:	ffffe097          	auipc	ra,0xffffe
    80002fc2:	d08080e7          	jalr	-760(ra) # 80000cc6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002fc6:	0001d797          	auipc	a5,0x1d
    80002fca:	dba78793          	addi	a5,a5,-582 # 8001fd80 <bcache+0x8000>
    80002fce:	2b87b483          	ld	s1,696(a5)
    80002fd2:	0001d797          	auipc	a5,0x1d
    80002fd6:	01678793          	addi	a5,a5,22 # 8001ffe8 <bcache+0x8268>
    80002fda:	02f48f63          	beq	s1,a5,80003018 <bread+0x74>
    80002fde:	873e                	mv	a4,a5
    80002fe0:	a021                	j	80002fe8 <bread+0x44>
    80002fe2:	68a4                	ld	s1,80(s1)
    80002fe4:	02e48a63          	beq	s1,a4,80003018 <bread+0x74>
    if(b->dev == dev && b->blockno == blockno){
    80002fe8:	449c                	lw	a5,8(s1)
    80002fea:	ff379ce3          	bne	a5,s3,80002fe2 <bread+0x3e>
    80002fee:	44dc                	lw	a5,12(s1)
    80002ff0:	ff2799e3          	bne	a5,s2,80002fe2 <bread+0x3e>
      b->refcnt++;
    80002ff4:	40bc                	lw	a5,64(s1)
    80002ff6:	2785                	addiw	a5,a5,1
    80002ff8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ffa:	00015517          	auipc	a0,0x15
    80002ffe:	d8650513          	addi	a0,a0,-634 # 80017d80 <bcache>
    80003002:	ffffe097          	auipc	ra,0xffffe
    80003006:	d78080e7          	jalr	-648(ra) # 80000d7a <release>
      acquiresleep(&b->lock);
    8000300a:	01048513          	addi	a0,s1,16
    8000300e:	00001097          	auipc	ra,0x1
    80003012:	4c0080e7          	jalr	1216(ra) # 800044ce <acquiresleep>
      return b;
    80003016:	a8b1                	j	80003072 <bread+0xce>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003018:	0001d797          	auipc	a5,0x1d
    8000301c:	d6878793          	addi	a5,a5,-664 # 8001fd80 <bcache+0x8000>
    80003020:	2b07b483          	ld	s1,688(a5)
    80003024:	0001d797          	auipc	a5,0x1d
    80003028:	fc478793          	addi	a5,a5,-60 # 8001ffe8 <bcache+0x8268>
    8000302c:	04f48d63          	beq	s1,a5,80003086 <bread+0xe2>
    if(b->refcnt == 0) {
    80003030:	40bc                	lw	a5,64(s1)
    80003032:	cb91                	beqz	a5,80003046 <bread+0xa2>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003034:	0001d717          	auipc	a4,0x1d
    80003038:	fb470713          	addi	a4,a4,-76 # 8001ffe8 <bcache+0x8268>
    8000303c:	64a4                	ld	s1,72(s1)
    8000303e:	04e48463          	beq	s1,a4,80003086 <bread+0xe2>
    if(b->refcnt == 0) {
    80003042:	40bc                	lw	a5,64(s1)
    80003044:	ffe5                	bnez	a5,8000303c <bread+0x98>
      b->dev = dev;
    80003046:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000304a:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    8000304e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003052:	4785                	li	a5,1
    80003054:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003056:	00015517          	auipc	a0,0x15
    8000305a:	d2a50513          	addi	a0,a0,-726 # 80017d80 <bcache>
    8000305e:	ffffe097          	auipc	ra,0xffffe
    80003062:	d1c080e7          	jalr	-740(ra) # 80000d7a <release>
      acquiresleep(&b->lock);
    80003066:	01048513          	addi	a0,s1,16
    8000306a:	00001097          	auipc	ra,0x1
    8000306e:	464080e7          	jalr	1124(ra) # 800044ce <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003072:	409c                	lw	a5,0(s1)
    80003074:	c38d                	beqz	a5,80003096 <bread+0xf2>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003076:	8526                	mv	a0,s1
    80003078:	70a2                	ld	ra,40(sp)
    8000307a:	7402                	ld	s0,32(sp)
    8000307c:	64e2                	ld	s1,24(sp)
    8000307e:	6942                	ld	s2,16(sp)
    80003080:	69a2                	ld	s3,8(sp)
    80003082:	6145                	addi	sp,sp,48
    80003084:	8082                	ret
  panic("bget: no buffers");
    80003086:	00005517          	auipc	a0,0x5
    8000308a:	48a50513          	addi	a0,a0,1162 # 80008510 <syscalls+0xf8>
    8000308e:	ffffd097          	auipc	ra,0xffffd
    80003092:	574080e7          	jalr	1396(ra) # 80000602 <panic>
    virtio_disk_rw(b, 0);
    80003096:	4581                	li	a1,0
    80003098:	8526                	mv	a0,s1
    8000309a:	00003097          	auipc	ra,0x3
    8000309e:	094080e7          	jalr	148(ra) # 8000612e <virtio_disk_rw>
    b->valid = 1;
    800030a2:	4785                	li	a5,1
    800030a4:	c09c                	sw	a5,0(s1)
  return b;
    800030a6:	bfc1                	j	80003076 <bread+0xd2>

00000000800030a8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800030a8:	1101                	addi	sp,sp,-32
    800030aa:	ec06                	sd	ra,24(sp)
    800030ac:	e822                	sd	s0,16(sp)
    800030ae:	e426                	sd	s1,8(sp)
    800030b0:	1000                	addi	s0,sp,32
    800030b2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030b4:	0541                	addi	a0,a0,16
    800030b6:	00001097          	auipc	ra,0x1
    800030ba:	4b2080e7          	jalr	1202(ra) # 80004568 <holdingsleep>
    800030be:	cd01                	beqz	a0,800030d6 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800030c0:	4585                	li	a1,1
    800030c2:	8526                	mv	a0,s1
    800030c4:	00003097          	auipc	ra,0x3
    800030c8:	06a080e7          	jalr	106(ra) # 8000612e <virtio_disk_rw>
}
    800030cc:	60e2                	ld	ra,24(sp)
    800030ce:	6442                	ld	s0,16(sp)
    800030d0:	64a2                	ld	s1,8(sp)
    800030d2:	6105                	addi	sp,sp,32
    800030d4:	8082                	ret
    panic("bwrite");
    800030d6:	00005517          	auipc	a0,0x5
    800030da:	45250513          	addi	a0,a0,1106 # 80008528 <syscalls+0x110>
    800030de:	ffffd097          	auipc	ra,0xffffd
    800030e2:	524080e7          	jalr	1316(ra) # 80000602 <panic>

00000000800030e6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800030e6:	1101                	addi	sp,sp,-32
    800030e8:	ec06                	sd	ra,24(sp)
    800030ea:	e822                	sd	s0,16(sp)
    800030ec:	e426                	sd	s1,8(sp)
    800030ee:	e04a                	sd	s2,0(sp)
    800030f0:	1000                	addi	s0,sp,32
    800030f2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030f4:	01050913          	addi	s2,a0,16
    800030f8:	854a                	mv	a0,s2
    800030fa:	00001097          	auipc	ra,0x1
    800030fe:	46e080e7          	jalr	1134(ra) # 80004568 <holdingsleep>
    80003102:	c92d                	beqz	a0,80003174 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003104:	854a                	mv	a0,s2
    80003106:	00001097          	auipc	ra,0x1
    8000310a:	41e080e7          	jalr	1054(ra) # 80004524 <releasesleep>

  acquire(&bcache.lock);
    8000310e:	00015517          	auipc	a0,0x15
    80003112:	c7250513          	addi	a0,a0,-910 # 80017d80 <bcache>
    80003116:	ffffe097          	auipc	ra,0xffffe
    8000311a:	bb0080e7          	jalr	-1104(ra) # 80000cc6 <acquire>
  b->refcnt--;
    8000311e:	40bc                	lw	a5,64(s1)
    80003120:	37fd                	addiw	a5,a5,-1
    80003122:	0007871b          	sext.w	a4,a5
    80003126:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003128:	eb05                	bnez	a4,80003158 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000312a:	68bc                	ld	a5,80(s1)
    8000312c:	64b8                	ld	a4,72(s1)
    8000312e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003130:	64bc                	ld	a5,72(s1)
    80003132:	68b8                	ld	a4,80(s1)
    80003134:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003136:	0001d797          	auipc	a5,0x1d
    8000313a:	c4a78793          	addi	a5,a5,-950 # 8001fd80 <bcache+0x8000>
    8000313e:	2b87b703          	ld	a4,696(a5)
    80003142:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003144:	0001d717          	auipc	a4,0x1d
    80003148:	ea470713          	addi	a4,a4,-348 # 8001ffe8 <bcache+0x8268>
    8000314c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000314e:	2b87b703          	ld	a4,696(a5)
    80003152:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003154:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003158:	00015517          	auipc	a0,0x15
    8000315c:	c2850513          	addi	a0,a0,-984 # 80017d80 <bcache>
    80003160:	ffffe097          	auipc	ra,0xffffe
    80003164:	c1a080e7          	jalr	-998(ra) # 80000d7a <release>
}
    80003168:	60e2                	ld	ra,24(sp)
    8000316a:	6442                	ld	s0,16(sp)
    8000316c:	64a2                	ld	s1,8(sp)
    8000316e:	6902                	ld	s2,0(sp)
    80003170:	6105                	addi	sp,sp,32
    80003172:	8082                	ret
    panic("brelse");
    80003174:	00005517          	auipc	a0,0x5
    80003178:	3bc50513          	addi	a0,a0,956 # 80008530 <syscalls+0x118>
    8000317c:	ffffd097          	auipc	ra,0xffffd
    80003180:	486080e7          	jalr	1158(ra) # 80000602 <panic>

0000000080003184 <bpin>:

void
bpin(struct buf *b) {
    80003184:	1101                	addi	sp,sp,-32
    80003186:	ec06                	sd	ra,24(sp)
    80003188:	e822                	sd	s0,16(sp)
    8000318a:	e426                	sd	s1,8(sp)
    8000318c:	1000                	addi	s0,sp,32
    8000318e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003190:	00015517          	auipc	a0,0x15
    80003194:	bf050513          	addi	a0,a0,-1040 # 80017d80 <bcache>
    80003198:	ffffe097          	auipc	ra,0xffffe
    8000319c:	b2e080e7          	jalr	-1234(ra) # 80000cc6 <acquire>
  b->refcnt++;
    800031a0:	40bc                	lw	a5,64(s1)
    800031a2:	2785                	addiw	a5,a5,1
    800031a4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031a6:	00015517          	auipc	a0,0x15
    800031aa:	bda50513          	addi	a0,a0,-1062 # 80017d80 <bcache>
    800031ae:	ffffe097          	auipc	ra,0xffffe
    800031b2:	bcc080e7          	jalr	-1076(ra) # 80000d7a <release>
}
    800031b6:	60e2                	ld	ra,24(sp)
    800031b8:	6442                	ld	s0,16(sp)
    800031ba:	64a2                	ld	s1,8(sp)
    800031bc:	6105                	addi	sp,sp,32
    800031be:	8082                	ret

00000000800031c0 <bunpin>:

void
bunpin(struct buf *b) {
    800031c0:	1101                	addi	sp,sp,-32
    800031c2:	ec06                	sd	ra,24(sp)
    800031c4:	e822                	sd	s0,16(sp)
    800031c6:	e426                	sd	s1,8(sp)
    800031c8:	1000                	addi	s0,sp,32
    800031ca:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031cc:	00015517          	auipc	a0,0x15
    800031d0:	bb450513          	addi	a0,a0,-1100 # 80017d80 <bcache>
    800031d4:	ffffe097          	auipc	ra,0xffffe
    800031d8:	af2080e7          	jalr	-1294(ra) # 80000cc6 <acquire>
  b->refcnt--;
    800031dc:	40bc                	lw	a5,64(s1)
    800031de:	37fd                	addiw	a5,a5,-1
    800031e0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031e2:	00015517          	auipc	a0,0x15
    800031e6:	b9e50513          	addi	a0,a0,-1122 # 80017d80 <bcache>
    800031ea:	ffffe097          	auipc	ra,0xffffe
    800031ee:	b90080e7          	jalr	-1136(ra) # 80000d7a <release>
}
    800031f2:	60e2                	ld	ra,24(sp)
    800031f4:	6442                	ld	s0,16(sp)
    800031f6:	64a2                	ld	s1,8(sp)
    800031f8:	6105                	addi	sp,sp,32
    800031fa:	8082                	ret

00000000800031fc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031fc:	1101                	addi	sp,sp,-32
    800031fe:	ec06                	sd	ra,24(sp)
    80003200:	e822                	sd	s0,16(sp)
    80003202:	e426                	sd	s1,8(sp)
    80003204:	e04a                	sd	s2,0(sp)
    80003206:	1000                	addi	s0,sp,32
    80003208:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000320a:	00d5d59b          	srliw	a1,a1,0xd
    8000320e:	0001d797          	auipc	a5,0x1d
    80003212:	23278793          	addi	a5,a5,562 # 80020440 <sb>
    80003216:	4fdc                	lw	a5,28(a5)
    80003218:	9dbd                	addw	a1,a1,a5
    8000321a:	00000097          	auipc	ra,0x0
    8000321e:	d8a080e7          	jalr	-630(ra) # 80002fa4 <bread>
  bi = b % BPB;
    80003222:	2481                	sext.w	s1,s1
  m = 1 << (bi % 8);
    80003224:	0074f793          	andi	a5,s1,7
    80003228:	4705                	li	a4,1
    8000322a:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    8000322e:	6789                	lui	a5,0x2
    80003230:	17fd                	addi	a5,a5,-1
    80003232:	8cfd                	and	s1,s1,a5
  if((bp->data[bi/8] & m) == 0)
    80003234:	41f4d79b          	sraiw	a5,s1,0x1f
    80003238:	01d7d79b          	srliw	a5,a5,0x1d
    8000323c:	9fa5                	addw	a5,a5,s1
    8000323e:	4037d79b          	sraiw	a5,a5,0x3
    80003242:	00f506b3          	add	a3,a0,a5
    80003246:	0586c683          	lbu	a3,88(a3)
    8000324a:	00d77633          	and	a2,a4,a3
    8000324e:	c61d                	beqz	a2,8000327c <bfree+0x80>
    80003250:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003252:	97aa                	add	a5,a5,a0
    80003254:	fff74713          	not	a4,a4
    80003258:	8f75                	and	a4,a4,a3
    8000325a:	04e78c23          	sb	a4,88(a5) # 2058 <_entry-0x7fffdfa8>
  log_write(bp);
    8000325e:	00001097          	auipc	ra,0x1
    80003262:	132080e7          	jalr	306(ra) # 80004390 <log_write>
  brelse(bp);
    80003266:	854a                	mv	a0,s2
    80003268:	00000097          	auipc	ra,0x0
    8000326c:	e7e080e7          	jalr	-386(ra) # 800030e6 <brelse>
}
    80003270:	60e2                	ld	ra,24(sp)
    80003272:	6442                	ld	s0,16(sp)
    80003274:	64a2                	ld	s1,8(sp)
    80003276:	6902                	ld	s2,0(sp)
    80003278:	6105                	addi	sp,sp,32
    8000327a:	8082                	ret
    panic("freeing free block");
    8000327c:	00005517          	auipc	a0,0x5
    80003280:	2bc50513          	addi	a0,a0,700 # 80008538 <syscalls+0x120>
    80003284:	ffffd097          	auipc	ra,0xffffd
    80003288:	37e080e7          	jalr	894(ra) # 80000602 <panic>

000000008000328c <balloc>:
{
    8000328c:	711d                	addi	sp,sp,-96
    8000328e:	ec86                	sd	ra,88(sp)
    80003290:	e8a2                	sd	s0,80(sp)
    80003292:	e4a6                	sd	s1,72(sp)
    80003294:	e0ca                	sd	s2,64(sp)
    80003296:	fc4e                	sd	s3,56(sp)
    80003298:	f852                	sd	s4,48(sp)
    8000329a:	f456                	sd	s5,40(sp)
    8000329c:	f05a                	sd	s6,32(sp)
    8000329e:	ec5e                	sd	s7,24(sp)
    800032a0:	e862                	sd	s8,16(sp)
    800032a2:	e466                	sd	s9,8(sp)
    800032a4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800032a6:	0001d797          	auipc	a5,0x1d
    800032aa:	19a78793          	addi	a5,a5,410 # 80020440 <sb>
    800032ae:	43dc                	lw	a5,4(a5)
    800032b0:	10078e63          	beqz	a5,800033cc <balloc+0x140>
    800032b4:	8baa                	mv	s7,a0
    800032b6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800032b8:	0001db17          	auipc	s6,0x1d
    800032bc:	188b0b13          	addi	s6,s6,392 # 80020440 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032c0:	4c05                	li	s8,1
      m = 1 << (bi % 8);
    800032c2:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032c4:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800032c6:	6c89                	lui	s9,0x2
    800032c8:	a079                	j	80003356 <balloc+0xca>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032ca:	8942                	mv	s2,a6
      m = 1 << (bi % 8);
    800032cc:	4705                	li	a4,1
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032ce:	4681                	li	a3,0
        bp->data[bi/8] |= m;  // Mark block in use.
    800032d0:	96a6                	add	a3,a3,s1
    800032d2:	8f51                	or	a4,a4,a2
    800032d4:	04e68c23          	sb	a4,88(a3)
        log_write(bp);
    800032d8:	8526                	mv	a0,s1
    800032da:	00001097          	auipc	ra,0x1
    800032de:	0b6080e7          	jalr	182(ra) # 80004390 <log_write>
        brelse(bp);
    800032e2:	8526                	mv	a0,s1
    800032e4:	00000097          	auipc	ra,0x0
    800032e8:	e02080e7          	jalr	-510(ra) # 800030e6 <brelse>
  bp = bread(dev, bno);
    800032ec:	85ca                	mv	a1,s2
    800032ee:	855e                	mv	a0,s7
    800032f0:	00000097          	auipc	ra,0x0
    800032f4:	cb4080e7          	jalr	-844(ra) # 80002fa4 <bread>
    800032f8:	84aa                	mv	s1,a0
  memset(bp->data, 0, BSIZE);
    800032fa:	40000613          	li	a2,1024
    800032fe:	4581                	li	a1,0
    80003300:	05850513          	addi	a0,a0,88
    80003304:	ffffe097          	auipc	ra,0xffffe
    80003308:	abe080e7          	jalr	-1346(ra) # 80000dc2 <memset>
  log_write(bp);
    8000330c:	8526                	mv	a0,s1
    8000330e:	00001097          	auipc	ra,0x1
    80003312:	082080e7          	jalr	130(ra) # 80004390 <log_write>
  brelse(bp);
    80003316:	8526                	mv	a0,s1
    80003318:	00000097          	auipc	ra,0x0
    8000331c:	dce080e7          	jalr	-562(ra) # 800030e6 <brelse>
}
    80003320:	854a                	mv	a0,s2
    80003322:	60e6                	ld	ra,88(sp)
    80003324:	6446                	ld	s0,80(sp)
    80003326:	64a6                	ld	s1,72(sp)
    80003328:	6906                	ld	s2,64(sp)
    8000332a:	79e2                	ld	s3,56(sp)
    8000332c:	7a42                	ld	s4,48(sp)
    8000332e:	7aa2                	ld	s5,40(sp)
    80003330:	7b02                	ld	s6,32(sp)
    80003332:	6be2                	ld	s7,24(sp)
    80003334:	6c42                	ld	s8,16(sp)
    80003336:	6ca2                	ld	s9,8(sp)
    80003338:	6125                	addi	sp,sp,96
    8000333a:	8082                	ret
    brelse(bp);
    8000333c:	8526                	mv	a0,s1
    8000333e:	00000097          	auipc	ra,0x0
    80003342:	da8080e7          	jalr	-600(ra) # 800030e6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003346:	015c87bb          	addw	a5,s9,s5
    8000334a:	00078a9b          	sext.w	s5,a5
    8000334e:	004b2703          	lw	a4,4(s6)
    80003352:	06eafd63          	bleu	a4,s5,800033cc <balloc+0x140>
    bp = bread(dev, BBLOCK(b, sb));
    80003356:	41fad79b          	sraiw	a5,s5,0x1f
    8000335a:	0137d79b          	srliw	a5,a5,0x13
    8000335e:	015787bb          	addw	a5,a5,s5
    80003362:	40d7d79b          	sraiw	a5,a5,0xd
    80003366:	01cb2583          	lw	a1,28(s6)
    8000336a:	9dbd                	addw	a1,a1,a5
    8000336c:	855e                	mv	a0,s7
    8000336e:	00000097          	auipc	ra,0x0
    80003372:	c36080e7          	jalr	-970(ra) # 80002fa4 <bread>
    80003376:	84aa                	mv	s1,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003378:	000a881b          	sext.w	a6,s5
    8000337c:	004b2503          	lw	a0,4(s6)
    80003380:	faa87ee3          	bleu	a0,a6,8000333c <balloc+0xb0>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003384:	0584c603          	lbu	a2,88(s1)
    80003388:	00167793          	andi	a5,a2,1
    8000338c:	df9d                	beqz	a5,800032ca <balloc+0x3e>
    8000338e:	4105053b          	subw	a0,a0,a6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003392:	87e2                	mv	a5,s8
    80003394:	0107893b          	addw	s2,a5,a6
    80003398:	faa782e3          	beq	a5,a0,8000333c <balloc+0xb0>
      m = 1 << (bi % 8);
    8000339c:	41f7d71b          	sraiw	a4,a5,0x1f
    800033a0:	01d7561b          	srliw	a2,a4,0x1d
    800033a4:	00f606bb          	addw	a3,a2,a5
    800033a8:	0076f713          	andi	a4,a3,7
    800033ac:	9f11                	subw	a4,a4,a2
    800033ae:	00e9973b          	sllw	a4,s3,a4
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800033b2:	4036d69b          	sraiw	a3,a3,0x3
    800033b6:	00d48633          	add	a2,s1,a3
    800033ba:	05864603          	lbu	a2,88(a2)
    800033be:	00c775b3          	and	a1,a4,a2
    800033c2:	d599                	beqz	a1,800032d0 <balloc+0x44>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033c4:	2785                	addiw	a5,a5,1
    800033c6:	fd4797e3          	bne	a5,s4,80003394 <balloc+0x108>
    800033ca:	bf8d                	j	8000333c <balloc+0xb0>
  panic("balloc: out of blocks");
    800033cc:	00005517          	auipc	a0,0x5
    800033d0:	18450513          	addi	a0,a0,388 # 80008550 <syscalls+0x138>
    800033d4:	ffffd097          	auipc	ra,0xffffd
    800033d8:	22e080e7          	jalr	558(ra) # 80000602 <panic>

00000000800033dc <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800033dc:	7179                	addi	sp,sp,-48
    800033de:	f406                	sd	ra,40(sp)
    800033e0:	f022                	sd	s0,32(sp)
    800033e2:	ec26                	sd	s1,24(sp)
    800033e4:	e84a                	sd	s2,16(sp)
    800033e6:	e44e                	sd	s3,8(sp)
    800033e8:	e052                	sd	s4,0(sp)
    800033ea:	1800                	addi	s0,sp,48
    800033ec:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800033ee:	47ad                	li	a5,11
    800033f0:	04b7fe63          	bleu	a1,a5,8000344c <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800033f4:	ff45849b          	addiw	s1,a1,-12
    800033f8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033fc:	0ff00793          	li	a5,255
    80003400:	0ae7e363          	bltu	a5,a4,800034a6 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003404:	08052583          	lw	a1,128(a0)
    80003408:	c5ad                	beqz	a1,80003472 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000340a:	0009a503          	lw	a0,0(s3)
    8000340e:	00000097          	auipc	ra,0x0
    80003412:	b96080e7          	jalr	-1130(ra) # 80002fa4 <bread>
    80003416:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003418:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000341c:	02049593          	slli	a1,s1,0x20
    80003420:	9181                	srli	a1,a1,0x20
    80003422:	058a                	slli	a1,a1,0x2
    80003424:	00b784b3          	add	s1,a5,a1
    80003428:	0004a903          	lw	s2,0(s1)
    8000342c:	04090d63          	beqz	s2,80003486 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003430:	8552                	mv	a0,s4
    80003432:	00000097          	auipc	ra,0x0
    80003436:	cb4080e7          	jalr	-844(ra) # 800030e6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000343a:	854a                	mv	a0,s2
    8000343c:	70a2                	ld	ra,40(sp)
    8000343e:	7402                	ld	s0,32(sp)
    80003440:	64e2                	ld	s1,24(sp)
    80003442:	6942                	ld	s2,16(sp)
    80003444:	69a2                	ld	s3,8(sp)
    80003446:	6a02                	ld	s4,0(sp)
    80003448:	6145                	addi	sp,sp,48
    8000344a:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000344c:	02059493          	slli	s1,a1,0x20
    80003450:	9081                	srli	s1,s1,0x20
    80003452:	048a                	slli	s1,s1,0x2
    80003454:	94aa                	add	s1,s1,a0
    80003456:	0504a903          	lw	s2,80(s1)
    8000345a:	fe0910e3          	bnez	s2,8000343a <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000345e:	4108                	lw	a0,0(a0)
    80003460:	00000097          	auipc	ra,0x0
    80003464:	e2c080e7          	jalr	-468(ra) # 8000328c <balloc>
    80003468:	0005091b          	sext.w	s2,a0
    8000346c:	0524a823          	sw	s2,80(s1)
    80003470:	b7e9                	j	8000343a <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003472:	4108                	lw	a0,0(a0)
    80003474:	00000097          	auipc	ra,0x0
    80003478:	e18080e7          	jalr	-488(ra) # 8000328c <balloc>
    8000347c:	0005059b          	sext.w	a1,a0
    80003480:	08b9a023          	sw	a1,128(s3)
    80003484:	b759                	j	8000340a <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003486:	0009a503          	lw	a0,0(s3)
    8000348a:	00000097          	auipc	ra,0x0
    8000348e:	e02080e7          	jalr	-510(ra) # 8000328c <balloc>
    80003492:	0005091b          	sext.w	s2,a0
    80003496:	0124a023          	sw	s2,0(s1)
      log_write(bp);
    8000349a:	8552                	mv	a0,s4
    8000349c:	00001097          	auipc	ra,0x1
    800034a0:	ef4080e7          	jalr	-268(ra) # 80004390 <log_write>
    800034a4:	b771                	j	80003430 <bmap+0x54>
  panic("bmap: out of range");
    800034a6:	00005517          	auipc	a0,0x5
    800034aa:	0c250513          	addi	a0,a0,194 # 80008568 <syscalls+0x150>
    800034ae:	ffffd097          	auipc	ra,0xffffd
    800034b2:	154080e7          	jalr	340(ra) # 80000602 <panic>

00000000800034b6 <iget>:
{
    800034b6:	7179                	addi	sp,sp,-48
    800034b8:	f406                	sd	ra,40(sp)
    800034ba:	f022                	sd	s0,32(sp)
    800034bc:	ec26                	sd	s1,24(sp)
    800034be:	e84a                	sd	s2,16(sp)
    800034c0:	e44e                	sd	s3,8(sp)
    800034c2:	e052                	sd	s4,0(sp)
    800034c4:	1800                	addi	s0,sp,48
    800034c6:	89aa                	mv	s3,a0
    800034c8:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800034ca:	0001d517          	auipc	a0,0x1d
    800034ce:	f9650513          	addi	a0,a0,-106 # 80020460 <icache>
    800034d2:	ffffd097          	auipc	ra,0xffffd
    800034d6:	7f4080e7          	jalr	2036(ra) # 80000cc6 <acquire>
  empty = 0;
    800034da:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800034dc:	0001d497          	auipc	s1,0x1d
    800034e0:	f9c48493          	addi	s1,s1,-100 # 80020478 <icache+0x18>
    800034e4:	0001f697          	auipc	a3,0x1f
    800034e8:	a2468693          	addi	a3,a3,-1500 # 80021f08 <log>
    800034ec:	a039                	j	800034fa <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034ee:	02090b63          	beqz	s2,80003524 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800034f2:	08848493          	addi	s1,s1,136
    800034f6:	02d48a63          	beq	s1,a3,8000352a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034fa:	449c                	lw	a5,8(s1)
    800034fc:	fef059e3          	blez	a5,800034ee <iget+0x38>
    80003500:	4098                	lw	a4,0(s1)
    80003502:	ff3716e3          	bne	a4,s3,800034ee <iget+0x38>
    80003506:	40d8                	lw	a4,4(s1)
    80003508:	ff4713e3          	bne	a4,s4,800034ee <iget+0x38>
      ip->ref++;
    8000350c:	2785                	addiw	a5,a5,1
    8000350e:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003510:	0001d517          	auipc	a0,0x1d
    80003514:	f5050513          	addi	a0,a0,-176 # 80020460 <icache>
    80003518:	ffffe097          	auipc	ra,0xffffe
    8000351c:	862080e7          	jalr	-1950(ra) # 80000d7a <release>
      return ip;
    80003520:	8926                	mv	s2,s1
    80003522:	a03d                	j	80003550 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003524:	f7f9                	bnez	a5,800034f2 <iget+0x3c>
    80003526:	8926                	mv	s2,s1
    80003528:	b7e9                	j	800034f2 <iget+0x3c>
  if(empty == 0)
    8000352a:	02090c63          	beqz	s2,80003562 <iget+0xac>
  ip->dev = dev;
    8000352e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003532:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003536:	4785                	li	a5,1
    80003538:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000353c:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003540:	0001d517          	auipc	a0,0x1d
    80003544:	f2050513          	addi	a0,a0,-224 # 80020460 <icache>
    80003548:	ffffe097          	auipc	ra,0xffffe
    8000354c:	832080e7          	jalr	-1998(ra) # 80000d7a <release>
}
    80003550:	854a                	mv	a0,s2
    80003552:	70a2                	ld	ra,40(sp)
    80003554:	7402                	ld	s0,32(sp)
    80003556:	64e2                	ld	s1,24(sp)
    80003558:	6942                	ld	s2,16(sp)
    8000355a:	69a2                	ld	s3,8(sp)
    8000355c:	6a02                	ld	s4,0(sp)
    8000355e:	6145                	addi	sp,sp,48
    80003560:	8082                	ret
    panic("iget: no inodes");
    80003562:	00005517          	auipc	a0,0x5
    80003566:	01e50513          	addi	a0,a0,30 # 80008580 <syscalls+0x168>
    8000356a:	ffffd097          	auipc	ra,0xffffd
    8000356e:	098080e7          	jalr	152(ra) # 80000602 <panic>

0000000080003572 <fsinit>:
fsinit(int dev) {
    80003572:	7179                	addi	sp,sp,-48
    80003574:	f406                	sd	ra,40(sp)
    80003576:	f022                	sd	s0,32(sp)
    80003578:	ec26                	sd	s1,24(sp)
    8000357a:	e84a                	sd	s2,16(sp)
    8000357c:	e44e                	sd	s3,8(sp)
    8000357e:	1800                	addi	s0,sp,48
    80003580:	89aa                	mv	s3,a0
  bp = bread(dev, 1);
    80003582:	4585                	li	a1,1
    80003584:	00000097          	auipc	ra,0x0
    80003588:	a20080e7          	jalr	-1504(ra) # 80002fa4 <bread>
    8000358c:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000358e:	0001d497          	auipc	s1,0x1d
    80003592:	eb248493          	addi	s1,s1,-334 # 80020440 <sb>
    80003596:	02000613          	li	a2,32
    8000359a:	05850593          	addi	a1,a0,88
    8000359e:	8526                	mv	a0,s1
    800035a0:	ffffe097          	auipc	ra,0xffffe
    800035a4:	88e080e7          	jalr	-1906(ra) # 80000e2e <memmove>
  brelse(bp);
    800035a8:	854a                	mv	a0,s2
    800035aa:	00000097          	auipc	ra,0x0
    800035ae:	b3c080e7          	jalr	-1220(ra) # 800030e6 <brelse>
  if(sb.magic != FSMAGIC)
    800035b2:	4098                	lw	a4,0(s1)
    800035b4:	102037b7          	lui	a5,0x10203
    800035b8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035bc:	02f71263          	bne	a4,a5,800035e0 <fsinit+0x6e>
  initlog(dev, &sb);
    800035c0:	0001d597          	auipc	a1,0x1d
    800035c4:	e8058593          	addi	a1,a1,-384 # 80020440 <sb>
    800035c8:	854e                	mv	a0,s3
    800035ca:	00001097          	auipc	ra,0x1
    800035ce:	b48080e7          	jalr	-1208(ra) # 80004112 <initlog>
}
    800035d2:	70a2                	ld	ra,40(sp)
    800035d4:	7402                	ld	s0,32(sp)
    800035d6:	64e2                	ld	s1,24(sp)
    800035d8:	6942                	ld	s2,16(sp)
    800035da:	69a2                	ld	s3,8(sp)
    800035dc:	6145                	addi	sp,sp,48
    800035de:	8082                	ret
    panic("invalid file system");
    800035e0:	00005517          	auipc	a0,0x5
    800035e4:	fb050513          	addi	a0,a0,-80 # 80008590 <syscalls+0x178>
    800035e8:	ffffd097          	auipc	ra,0xffffd
    800035ec:	01a080e7          	jalr	26(ra) # 80000602 <panic>

00000000800035f0 <iinit>:
{
    800035f0:	7179                	addi	sp,sp,-48
    800035f2:	f406                	sd	ra,40(sp)
    800035f4:	f022                	sd	s0,32(sp)
    800035f6:	ec26                	sd	s1,24(sp)
    800035f8:	e84a                	sd	s2,16(sp)
    800035fa:	e44e                	sd	s3,8(sp)
    800035fc:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800035fe:	00005597          	auipc	a1,0x5
    80003602:	faa58593          	addi	a1,a1,-86 # 800085a8 <syscalls+0x190>
    80003606:	0001d517          	auipc	a0,0x1d
    8000360a:	e5a50513          	addi	a0,a0,-422 # 80020460 <icache>
    8000360e:	ffffd097          	auipc	ra,0xffffd
    80003612:	628080e7          	jalr	1576(ra) # 80000c36 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003616:	0001d497          	auipc	s1,0x1d
    8000361a:	e7248493          	addi	s1,s1,-398 # 80020488 <icache+0x28>
    8000361e:	0001f997          	auipc	s3,0x1f
    80003622:	8fa98993          	addi	s3,s3,-1798 # 80021f18 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003626:	00005917          	auipc	s2,0x5
    8000362a:	f8a90913          	addi	s2,s2,-118 # 800085b0 <syscalls+0x198>
    8000362e:	85ca                	mv	a1,s2
    80003630:	8526                	mv	a0,s1
    80003632:	00001097          	auipc	ra,0x1
    80003636:	e62080e7          	jalr	-414(ra) # 80004494 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000363a:	08848493          	addi	s1,s1,136
    8000363e:	ff3498e3          	bne	s1,s3,8000362e <iinit+0x3e>
}
    80003642:	70a2                	ld	ra,40(sp)
    80003644:	7402                	ld	s0,32(sp)
    80003646:	64e2                	ld	s1,24(sp)
    80003648:	6942                	ld	s2,16(sp)
    8000364a:	69a2                	ld	s3,8(sp)
    8000364c:	6145                	addi	sp,sp,48
    8000364e:	8082                	ret

0000000080003650 <ialloc>:
{
    80003650:	715d                	addi	sp,sp,-80
    80003652:	e486                	sd	ra,72(sp)
    80003654:	e0a2                	sd	s0,64(sp)
    80003656:	fc26                	sd	s1,56(sp)
    80003658:	f84a                	sd	s2,48(sp)
    8000365a:	f44e                	sd	s3,40(sp)
    8000365c:	f052                	sd	s4,32(sp)
    8000365e:	ec56                	sd	s5,24(sp)
    80003660:	e85a                	sd	s6,16(sp)
    80003662:	e45e                	sd	s7,8(sp)
    80003664:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003666:	0001d797          	auipc	a5,0x1d
    8000366a:	dda78793          	addi	a5,a5,-550 # 80020440 <sb>
    8000366e:	47d8                	lw	a4,12(a5)
    80003670:	4785                	li	a5,1
    80003672:	04e7fa63          	bleu	a4,a5,800036c6 <ialloc+0x76>
    80003676:	8a2a                	mv	s4,a0
    80003678:	8b2e                	mv	s6,a1
    8000367a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000367c:	0001d997          	auipc	s3,0x1d
    80003680:	dc498993          	addi	s3,s3,-572 # 80020440 <sb>
    80003684:	00048a9b          	sext.w	s5,s1
    80003688:	0044d593          	srli	a1,s1,0x4
    8000368c:	0189a783          	lw	a5,24(s3)
    80003690:	9dbd                	addw	a1,a1,a5
    80003692:	8552                	mv	a0,s4
    80003694:	00000097          	auipc	ra,0x0
    80003698:	910080e7          	jalr	-1776(ra) # 80002fa4 <bread>
    8000369c:	8baa                	mv	s7,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000369e:	05850913          	addi	s2,a0,88
    800036a2:	00f4f793          	andi	a5,s1,15
    800036a6:	079a                	slli	a5,a5,0x6
    800036a8:	993e                	add	s2,s2,a5
    if(dip->type == 0){  // a free inode
    800036aa:	00091783          	lh	a5,0(s2)
    800036ae:	c785                	beqz	a5,800036d6 <ialloc+0x86>
    brelse(bp);
    800036b0:	00000097          	auipc	ra,0x0
    800036b4:	a36080e7          	jalr	-1482(ra) # 800030e6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800036b8:	0485                	addi	s1,s1,1
    800036ba:	00c9a703          	lw	a4,12(s3)
    800036be:	0004879b          	sext.w	a5,s1
    800036c2:	fce7e1e3          	bltu	a5,a4,80003684 <ialloc+0x34>
  panic("ialloc: no inodes");
    800036c6:	00005517          	auipc	a0,0x5
    800036ca:	ef250513          	addi	a0,a0,-270 # 800085b8 <syscalls+0x1a0>
    800036ce:	ffffd097          	auipc	ra,0xffffd
    800036d2:	f34080e7          	jalr	-204(ra) # 80000602 <panic>
      memset(dip, 0, sizeof(*dip));
    800036d6:	04000613          	li	a2,64
    800036da:	4581                	li	a1,0
    800036dc:	854a                	mv	a0,s2
    800036de:	ffffd097          	auipc	ra,0xffffd
    800036e2:	6e4080e7          	jalr	1764(ra) # 80000dc2 <memset>
      dip->type = type;
    800036e6:	01691023          	sh	s6,0(s2)
      log_write(bp);   // mark it allocated on the disk
    800036ea:	855e                	mv	a0,s7
    800036ec:	00001097          	auipc	ra,0x1
    800036f0:	ca4080e7          	jalr	-860(ra) # 80004390 <log_write>
      brelse(bp);
    800036f4:	855e                	mv	a0,s7
    800036f6:	00000097          	auipc	ra,0x0
    800036fa:	9f0080e7          	jalr	-1552(ra) # 800030e6 <brelse>
      return iget(dev, inum);
    800036fe:	85d6                	mv	a1,s5
    80003700:	8552                	mv	a0,s4
    80003702:	00000097          	auipc	ra,0x0
    80003706:	db4080e7          	jalr	-588(ra) # 800034b6 <iget>
}
    8000370a:	60a6                	ld	ra,72(sp)
    8000370c:	6406                	ld	s0,64(sp)
    8000370e:	74e2                	ld	s1,56(sp)
    80003710:	7942                	ld	s2,48(sp)
    80003712:	79a2                	ld	s3,40(sp)
    80003714:	7a02                	ld	s4,32(sp)
    80003716:	6ae2                	ld	s5,24(sp)
    80003718:	6b42                	ld	s6,16(sp)
    8000371a:	6ba2                	ld	s7,8(sp)
    8000371c:	6161                	addi	sp,sp,80
    8000371e:	8082                	ret

0000000080003720 <iupdate>:
{
    80003720:	1101                	addi	sp,sp,-32
    80003722:	ec06                	sd	ra,24(sp)
    80003724:	e822                	sd	s0,16(sp)
    80003726:	e426                	sd	s1,8(sp)
    80003728:	e04a                	sd	s2,0(sp)
    8000372a:	1000                	addi	s0,sp,32
    8000372c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000372e:	415c                	lw	a5,4(a0)
    80003730:	0047d79b          	srliw	a5,a5,0x4
    80003734:	0001d717          	auipc	a4,0x1d
    80003738:	d0c70713          	addi	a4,a4,-756 # 80020440 <sb>
    8000373c:	4f0c                	lw	a1,24(a4)
    8000373e:	9dbd                	addw	a1,a1,a5
    80003740:	4108                	lw	a0,0(a0)
    80003742:	00000097          	auipc	ra,0x0
    80003746:	862080e7          	jalr	-1950(ra) # 80002fa4 <bread>
    8000374a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000374c:	05850513          	addi	a0,a0,88
    80003750:	40dc                	lw	a5,4(s1)
    80003752:	8bbd                	andi	a5,a5,15
    80003754:	079a                	slli	a5,a5,0x6
    80003756:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003758:	04449783          	lh	a5,68(s1)
    8000375c:	00f51023          	sh	a5,0(a0)
  dip->major = ip->major;
    80003760:	04649783          	lh	a5,70(s1)
    80003764:	00f51123          	sh	a5,2(a0)
  dip->minor = ip->minor;
    80003768:	04849783          	lh	a5,72(s1)
    8000376c:	00f51223          	sh	a5,4(a0)
  dip->nlink = ip->nlink;
    80003770:	04a49783          	lh	a5,74(s1)
    80003774:	00f51323          	sh	a5,6(a0)
  dip->size = ip->size;
    80003778:	44fc                	lw	a5,76(s1)
    8000377a:	c51c                	sw	a5,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000377c:	03400613          	li	a2,52
    80003780:	05048593          	addi	a1,s1,80
    80003784:	0531                	addi	a0,a0,12
    80003786:	ffffd097          	auipc	ra,0xffffd
    8000378a:	6a8080e7          	jalr	1704(ra) # 80000e2e <memmove>
  log_write(bp);
    8000378e:	854a                	mv	a0,s2
    80003790:	00001097          	auipc	ra,0x1
    80003794:	c00080e7          	jalr	-1024(ra) # 80004390 <log_write>
  brelse(bp);
    80003798:	854a                	mv	a0,s2
    8000379a:	00000097          	auipc	ra,0x0
    8000379e:	94c080e7          	jalr	-1716(ra) # 800030e6 <brelse>
}
    800037a2:	60e2                	ld	ra,24(sp)
    800037a4:	6442                	ld	s0,16(sp)
    800037a6:	64a2                	ld	s1,8(sp)
    800037a8:	6902                	ld	s2,0(sp)
    800037aa:	6105                	addi	sp,sp,32
    800037ac:	8082                	ret

00000000800037ae <idup>:
{
    800037ae:	1101                	addi	sp,sp,-32
    800037b0:	ec06                	sd	ra,24(sp)
    800037b2:	e822                	sd	s0,16(sp)
    800037b4:	e426                	sd	s1,8(sp)
    800037b6:	1000                	addi	s0,sp,32
    800037b8:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800037ba:	0001d517          	auipc	a0,0x1d
    800037be:	ca650513          	addi	a0,a0,-858 # 80020460 <icache>
    800037c2:	ffffd097          	auipc	ra,0xffffd
    800037c6:	504080e7          	jalr	1284(ra) # 80000cc6 <acquire>
  ip->ref++;
    800037ca:	449c                	lw	a5,8(s1)
    800037cc:	2785                	addiw	a5,a5,1
    800037ce:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800037d0:	0001d517          	auipc	a0,0x1d
    800037d4:	c9050513          	addi	a0,a0,-880 # 80020460 <icache>
    800037d8:	ffffd097          	auipc	ra,0xffffd
    800037dc:	5a2080e7          	jalr	1442(ra) # 80000d7a <release>
}
    800037e0:	8526                	mv	a0,s1
    800037e2:	60e2                	ld	ra,24(sp)
    800037e4:	6442                	ld	s0,16(sp)
    800037e6:	64a2                	ld	s1,8(sp)
    800037e8:	6105                	addi	sp,sp,32
    800037ea:	8082                	ret

00000000800037ec <ilock>:
{
    800037ec:	1101                	addi	sp,sp,-32
    800037ee:	ec06                	sd	ra,24(sp)
    800037f0:	e822                	sd	s0,16(sp)
    800037f2:	e426                	sd	s1,8(sp)
    800037f4:	e04a                	sd	s2,0(sp)
    800037f6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800037f8:	c115                	beqz	a0,8000381c <ilock+0x30>
    800037fa:	84aa                	mv	s1,a0
    800037fc:	451c                	lw	a5,8(a0)
    800037fe:	00f05f63          	blez	a5,8000381c <ilock+0x30>
  acquiresleep(&ip->lock);
    80003802:	0541                	addi	a0,a0,16
    80003804:	00001097          	auipc	ra,0x1
    80003808:	cca080e7          	jalr	-822(ra) # 800044ce <acquiresleep>
  if(ip->valid == 0){
    8000380c:	40bc                	lw	a5,64(s1)
    8000380e:	cf99                	beqz	a5,8000382c <ilock+0x40>
}
    80003810:	60e2                	ld	ra,24(sp)
    80003812:	6442                	ld	s0,16(sp)
    80003814:	64a2                	ld	s1,8(sp)
    80003816:	6902                	ld	s2,0(sp)
    80003818:	6105                	addi	sp,sp,32
    8000381a:	8082                	ret
    panic("ilock");
    8000381c:	00005517          	auipc	a0,0x5
    80003820:	db450513          	addi	a0,a0,-588 # 800085d0 <syscalls+0x1b8>
    80003824:	ffffd097          	auipc	ra,0xffffd
    80003828:	dde080e7          	jalr	-546(ra) # 80000602 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000382c:	40dc                	lw	a5,4(s1)
    8000382e:	0047d79b          	srliw	a5,a5,0x4
    80003832:	0001d717          	auipc	a4,0x1d
    80003836:	c0e70713          	addi	a4,a4,-1010 # 80020440 <sb>
    8000383a:	4f0c                	lw	a1,24(a4)
    8000383c:	9dbd                	addw	a1,a1,a5
    8000383e:	4088                	lw	a0,0(s1)
    80003840:	fffff097          	auipc	ra,0xfffff
    80003844:	764080e7          	jalr	1892(ra) # 80002fa4 <bread>
    80003848:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000384a:	05850593          	addi	a1,a0,88
    8000384e:	40dc                	lw	a5,4(s1)
    80003850:	8bbd                	andi	a5,a5,15
    80003852:	079a                	slli	a5,a5,0x6
    80003854:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003856:	00059783          	lh	a5,0(a1)
    8000385a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000385e:	00259783          	lh	a5,2(a1)
    80003862:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003866:	00459783          	lh	a5,4(a1)
    8000386a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000386e:	00659783          	lh	a5,6(a1)
    80003872:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003876:	459c                	lw	a5,8(a1)
    80003878:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000387a:	03400613          	li	a2,52
    8000387e:	05b1                	addi	a1,a1,12
    80003880:	05048513          	addi	a0,s1,80
    80003884:	ffffd097          	auipc	ra,0xffffd
    80003888:	5aa080e7          	jalr	1450(ra) # 80000e2e <memmove>
    brelse(bp);
    8000388c:	854a                	mv	a0,s2
    8000388e:	00000097          	auipc	ra,0x0
    80003892:	858080e7          	jalr	-1960(ra) # 800030e6 <brelse>
    ip->valid = 1;
    80003896:	4785                	li	a5,1
    80003898:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000389a:	04449783          	lh	a5,68(s1)
    8000389e:	fbad                	bnez	a5,80003810 <ilock+0x24>
      panic("ilock: no type");
    800038a0:	00005517          	auipc	a0,0x5
    800038a4:	d3850513          	addi	a0,a0,-712 # 800085d8 <syscalls+0x1c0>
    800038a8:	ffffd097          	auipc	ra,0xffffd
    800038ac:	d5a080e7          	jalr	-678(ra) # 80000602 <panic>

00000000800038b0 <iunlock>:
{
    800038b0:	1101                	addi	sp,sp,-32
    800038b2:	ec06                	sd	ra,24(sp)
    800038b4:	e822                	sd	s0,16(sp)
    800038b6:	e426                	sd	s1,8(sp)
    800038b8:	e04a                	sd	s2,0(sp)
    800038ba:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800038bc:	c905                	beqz	a0,800038ec <iunlock+0x3c>
    800038be:	84aa                	mv	s1,a0
    800038c0:	01050913          	addi	s2,a0,16
    800038c4:	854a                	mv	a0,s2
    800038c6:	00001097          	auipc	ra,0x1
    800038ca:	ca2080e7          	jalr	-862(ra) # 80004568 <holdingsleep>
    800038ce:	cd19                	beqz	a0,800038ec <iunlock+0x3c>
    800038d0:	449c                	lw	a5,8(s1)
    800038d2:	00f05d63          	blez	a5,800038ec <iunlock+0x3c>
  releasesleep(&ip->lock);
    800038d6:	854a                	mv	a0,s2
    800038d8:	00001097          	auipc	ra,0x1
    800038dc:	c4c080e7          	jalr	-948(ra) # 80004524 <releasesleep>
}
    800038e0:	60e2                	ld	ra,24(sp)
    800038e2:	6442                	ld	s0,16(sp)
    800038e4:	64a2                	ld	s1,8(sp)
    800038e6:	6902                	ld	s2,0(sp)
    800038e8:	6105                	addi	sp,sp,32
    800038ea:	8082                	ret
    panic("iunlock");
    800038ec:	00005517          	auipc	a0,0x5
    800038f0:	cfc50513          	addi	a0,a0,-772 # 800085e8 <syscalls+0x1d0>
    800038f4:	ffffd097          	auipc	ra,0xffffd
    800038f8:	d0e080e7          	jalr	-754(ra) # 80000602 <panic>

00000000800038fc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038fc:	7179                	addi	sp,sp,-48
    800038fe:	f406                	sd	ra,40(sp)
    80003900:	f022                	sd	s0,32(sp)
    80003902:	ec26                	sd	s1,24(sp)
    80003904:	e84a                	sd	s2,16(sp)
    80003906:	e44e                	sd	s3,8(sp)
    80003908:	e052                	sd	s4,0(sp)
    8000390a:	1800                	addi	s0,sp,48
    8000390c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000390e:	05050493          	addi	s1,a0,80
    80003912:	08050913          	addi	s2,a0,128
    80003916:	a821                	j	8000392e <itrunc+0x32>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    80003918:	0009a503          	lw	a0,0(s3)
    8000391c:	00000097          	auipc	ra,0x0
    80003920:	8e0080e7          	jalr	-1824(ra) # 800031fc <bfree>
      ip->addrs[i] = 0;
    80003924:	0004a023          	sw	zero,0(s1)
  for(i = 0; i < NDIRECT; i++){
    80003928:	0491                	addi	s1,s1,4
    8000392a:	01248563          	beq	s1,s2,80003934 <itrunc+0x38>
    if(ip->addrs[i]){
    8000392e:	408c                	lw	a1,0(s1)
    80003930:	dde5                	beqz	a1,80003928 <itrunc+0x2c>
    80003932:	b7dd                	j	80003918 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003934:	0809a583          	lw	a1,128(s3)
    80003938:	e185                	bnez	a1,80003958 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000393a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000393e:	854e                	mv	a0,s3
    80003940:	00000097          	auipc	ra,0x0
    80003944:	de0080e7          	jalr	-544(ra) # 80003720 <iupdate>
}
    80003948:	70a2                	ld	ra,40(sp)
    8000394a:	7402                	ld	s0,32(sp)
    8000394c:	64e2                	ld	s1,24(sp)
    8000394e:	6942                	ld	s2,16(sp)
    80003950:	69a2                	ld	s3,8(sp)
    80003952:	6a02                	ld	s4,0(sp)
    80003954:	6145                	addi	sp,sp,48
    80003956:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003958:	0009a503          	lw	a0,0(s3)
    8000395c:	fffff097          	auipc	ra,0xfffff
    80003960:	648080e7          	jalr	1608(ra) # 80002fa4 <bread>
    80003964:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003966:	05850493          	addi	s1,a0,88
    8000396a:	45850913          	addi	s2,a0,1112
    8000396e:	a811                	j	80003982 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003970:	0009a503          	lw	a0,0(s3)
    80003974:	00000097          	auipc	ra,0x0
    80003978:	888080e7          	jalr	-1912(ra) # 800031fc <bfree>
    for(j = 0; j < NINDIRECT; j++){
    8000397c:	0491                	addi	s1,s1,4
    8000397e:	01248563          	beq	s1,s2,80003988 <itrunc+0x8c>
      if(a[j])
    80003982:	408c                	lw	a1,0(s1)
    80003984:	dde5                	beqz	a1,8000397c <itrunc+0x80>
    80003986:	b7ed                	j	80003970 <itrunc+0x74>
    brelse(bp);
    80003988:	8552                	mv	a0,s4
    8000398a:	fffff097          	auipc	ra,0xfffff
    8000398e:	75c080e7          	jalr	1884(ra) # 800030e6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003992:	0809a583          	lw	a1,128(s3)
    80003996:	0009a503          	lw	a0,0(s3)
    8000399a:	00000097          	auipc	ra,0x0
    8000399e:	862080e7          	jalr	-1950(ra) # 800031fc <bfree>
    ip->addrs[NDIRECT] = 0;
    800039a2:	0809a023          	sw	zero,128(s3)
    800039a6:	bf51                	j	8000393a <itrunc+0x3e>

00000000800039a8 <iput>:
{
    800039a8:	1101                	addi	sp,sp,-32
    800039aa:	ec06                	sd	ra,24(sp)
    800039ac:	e822                	sd	s0,16(sp)
    800039ae:	e426                	sd	s1,8(sp)
    800039b0:	e04a                	sd	s2,0(sp)
    800039b2:	1000                	addi	s0,sp,32
    800039b4:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800039b6:	0001d517          	auipc	a0,0x1d
    800039ba:	aaa50513          	addi	a0,a0,-1366 # 80020460 <icache>
    800039be:	ffffd097          	auipc	ra,0xffffd
    800039c2:	308080e7          	jalr	776(ra) # 80000cc6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039c6:	4498                	lw	a4,8(s1)
    800039c8:	4785                	li	a5,1
    800039ca:	02f70363          	beq	a4,a5,800039f0 <iput+0x48>
  ip->ref--;
    800039ce:	449c                	lw	a5,8(s1)
    800039d0:	37fd                	addiw	a5,a5,-1
    800039d2:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800039d4:	0001d517          	auipc	a0,0x1d
    800039d8:	a8c50513          	addi	a0,a0,-1396 # 80020460 <icache>
    800039dc:	ffffd097          	auipc	ra,0xffffd
    800039e0:	39e080e7          	jalr	926(ra) # 80000d7a <release>
}
    800039e4:	60e2                	ld	ra,24(sp)
    800039e6:	6442                	ld	s0,16(sp)
    800039e8:	64a2                	ld	s1,8(sp)
    800039ea:	6902                	ld	s2,0(sp)
    800039ec:	6105                	addi	sp,sp,32
    800039ee:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039f0:	40bc                	lw	a5,64(s1)
    800039f2:	dff1                	beqz	a5,800039ce <iput+0x26>
    800039f4:	04a49783          	lh	a5,74(s1)
    800039f8:	fbf9                	bnez	a5,800039ce <iput+0x26>
    acquiresleep(&ip->lock);
    800039fa:	01048913          	addi	s2,s1,16
    800039fe:	854a                	mv	a0,s2
    80003a00:	00001097          	auipc	ra,0x1
    80003a04:	ace080e7          	jalr	-1330(ra) # 800044ce <acquiresleep>
    release(&icache.lock);
    80003a08:	0001d517          	auipc	a0,0x1d
    80003a0c:	a5850513          	addi	a0,a0,-1448 # 80020460 <icache>
    80003a10:	ffffd097          	auipc	ra,0xffffd
    80003a14:	36a080e7          	jalr	874(ra) # 80000d7a <release>
    itrunc(ip);
    80003a18:	8526                	mv	a0,s1
    80003a1a:	00000097          	auipc	ra,0x0
    80003a1e:	ee2080e7          	jalr	-286(ra) # 800038fc <itrunc>
    ip->type = 0;
    80003a22:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a26:	8526                	mv	a0,s1
    80003a28:	00000097          	auipc	ra,0x0
    80003a2c:	cf8080e7          	jalr	-776(ra) # 80003720 <iupdate>
    ip->valid = 0;
    80003a30:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003a34:	854a                	mv	a0,s2
    80003a36:	00001097          	auipc	ra,0x1
    80003a3a:	aee080e7          	jalr	-1298(ra) # 80004524 <releasesleep>
    acquire(&icache.lock);
    80003a3e:	0001d517          	auipc	a0,0x1d
    80003a42:	a2250513          	addi	a0,a0,-1502 # 80020460 <icache>
    80003a46:	ffffd097          	auipc	ra,0xffffd
    80003a4a:	280080e7          	jalr	640(ra) # 80000cc6 <acquire>
    80003a4e:	b741                	j	800039ce <iput+0x26>

0000000080003a50 <iunlockput>:
{
    80003a50:	1101                	addi	sp,sp,-32
    80003a52:	ec06                	sd	ra,24(sp)
    80003a54:	e822                	sd	s0,16(sp)
    80003a56:	e426                	sd	s1,8(sp)
    80003a58:	1000                	addi	s0,sp,32
    80003a5a:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a5c:	00000097          	auipc	ra,0x0
    80003a60:	e54080e7          	jalr	-428(ra) # 800038b0 <iunlock>
  iput(ip);
    80003a64:	8526                	mv	a0,s1
    80003a66:	00000097          	auipc	ra,0x0
    80003a6a:	f42080e7          	jalr	-190(ra) # 800039a8 <iput>
}
    80003a6e:	60e2                	ld	ra,24(sp)
    80003a70:	6442                	ld	s0,16(sp)
    80003a72:	64a2                	ld	s1,8(sp)
    80003a74:	6105                	addi	sp,sp,32
    80003a76:	8082                	ret

0000000080003a78 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a78:	1141                	addi	sp,sp,-16
    80003a7a:	e422                	sd	s0,8(sp)
    80003a7c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a7e:	411c                	lw	a5,0(a0)
    80003a80:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a82:	415c                	lw	a5,4(a0)
    80003a84:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a86:	04451783          	lh	a5,68(a0)
    80003a8a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a8e:	04a51783          	lh	a5,74(a0)
    80003a92:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a96:	04c56783          	lwu	a5,76(a0)
    80003a9a:	e99c                	sd	a5,16(a1)
}
    80003a9c:	6422                	ld	s0,8(sp)
    80003a9e:	0141                	addi	sp,sp,16
    80003aa0:	8082                	ret

0000000080003aa2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003aa2:	457c                	lw	a5,76(a0)
    80003aa4:	0ed7e863          	bltu	a5,a3,80003b94 <readi+0xf2>
{
    80003aa8:	7159                	addi	sp,sp,-112
    80003aaa:	f486                	sd	ra,104(sp)
    80003aac:	f0a2                	sd	s0,96(sp)
    80003aae:	eca6                	sd	s1,88(sp)
    80003ab0:	e8ca                	sd	s2,80(sp)
    80003ab2:	e4ce                	sd	s3,72(sp)
    80003ab4:	e0d2                	sd	s4,64(sp)
    80003ab6:	fc56                	sd	s5,56(sp)
    80003ab8:	f85a                	sd	s6,48(sp)
    80003aba:	f45e                	sd	s7,40(sp)
    80003abc:	f062                	sd	s8,32(sp)
    80003abe:	ec66                	sd	s9,24(sp)
    80003ac0:	e86a                	sd	s10,16(sp)
    80003ac2:	e46e                	sd	s11,8(sp)
    80003ac4:	1880                	addi	s0,sp,112
    80003ac6:	8baa                	mv	s7,a0
    80003ac8:	8c2e                	mv	s8,a1
    80003aca:	8a32                	mv	s4,a2
    80003acc:	84b6                	mv	s1,a3
    80003ace:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ad0:	9f35                	addw	a4,a4,a3
    return 0;
    80003ad2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ad4:	08d76f63          	bltu	a4,a3,80003b72 <readi+0xd0>
  if(off + n > ip->size)
    80003ad8:	00e7f463          	bleu	a4,a5,80003ae0 <readi+0x3e>
    n = ip->size - off;
    80003adc:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ae0:	0a0b0863          	beqz	s6,80003b90 <readi+0xee>
    80003ae4:	4901                	li	s2,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ae6:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003aea:	5cfd                	li	s9,-1
    80003aec:	a82d                	j	80003b26 <readi+0x84>
    80003aee:	02099d93          	slli	s11,s3,0x20
    80003af2:	020ddd93          	srli	s11,s11,0x20
    80003af6:	058a8613          	addi	a2,s5,88
    80003afa:	86ee                	mv	a3,s11
    80003afc:	963a                	add	a2,a2,a4
    80003afe:	85d2                	mv	a1,s4
    80003b00:	8562                	mv	a0,s8
    80003b02:	fffff097          	auipc	ra,0xfffff
    80003b06:	a74080e7          	jalr	-1420(ra) # 80002576 <either_copyout>
    80003b0a:	05950d63          	beq	a0,s9,80003b64 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003b0e:	8556                	mv	a0,s5
    80003b10:	fffff097          	auipc	ra,0xfffff
    80003b14:	5d6080e7          	jalr	1494(ra) # 800030e6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b18:	0129893b          	addw	s2,s3,s2
    80003b1c:	009984bb          	addw	s1,s3,s1
    80003b20:	9a6e                	add	s4,s4,s11
    80003b22:	05697663          	bleu	s6,s2,80003b6e <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b26:	000ba983          	lw	s3,0(s7)
    80003b2a:	00a4d59b          	srliw	a1,s1,0xa
    80003b2e:	855e                	mv	a0,s7
    80003b30:	00000097          	auipc	ra,0x0
    80003b34:	8ac080e7          	jalr	-1876(ra) # 800033dc <bmap>
    80003b38:	0005059b          	sext.w	a1,a0
    80003b3c:	854e                	mv	a0,s3
    80003b3e:	fffff097          	auipc	ra,0xfffff
    80003b42:	466080e7          	jalr	1126(ra) # 80002fa4 <bread>
    80003b46:	8aaa                	mv	s5,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b48:	3ff4f713          	andi	a4,s1,1023
    80003b4c:	40ed07bb          	subw	a5,s10,a4
    80003b50:	412b06bb          	subw	a3,s6,s2
    80003b54:	89be                	mv	s3,a5
    80003b56:	2781                	sext.w	a5,a5
    80003b58:	0006861b          	sext.w	a2,a3
    80003b5c:	f8f679e3          	bleu	a5,a2,80003aee <readi+0x4c>
    80003b60:	89b6                	mv	s3,a3
    80003b62:	b771                	j	80003aee <readi+0x4c>
      brelse(bp);
    80003b64:	8556                	mv	a0,s5
    80003b66:	fffff097          	auipc	ra,0xfffff
    80003b6a:	580080e7          	jalr	1408(ra) # 800030e6 <brelse>
  }
  return tot;
    80003b6e:	0009051b          	sext.w	a0,s2
}
    80003b72:	70a6                	ld	ra,104(sp)
    80003b74:	7406                	ld	s0,96(sp)
    80003b76:	64e6                	ld	s1,88(sp)
    80003b78:	6946                	ld	s2,80(sp)
    80003b7a:	69a6                	ld	s3,72(sp)
    80003b7c:	6a06                	ld	s4,64(sp)
    80003b7e:	7ae2                	ld	s5,56(sp)
    80003b80:	7b42                	ld	s6,48(sp)
    80003b82:	7ba2                	ld	s7,40(sp)
    80003b84:	7c02                	ld	s8,32(sp)
    80003b86:	6ce2                	ld	s9,24(sp)
    80003b88:	6d42                	ld	s10,16(sp)
    80003b8a:	6da2                	ld	s11,8(sp)
    80003b8c:	6165                	addi	sp,sp,112
    80003b8e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b90:	895a                	mv	s2,s6
    80003b92:	bff1                	j	80003b6e <readi+0xcc>
    return 0;
    80003b94:	4501                	li	a0,0
}
    80003b96:	8082                	ret

0000000080003b98 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b98:	457c                	lw	a5,76(a0)
    80003b9a:	10d7e663          	bltu	a5,a3,80003ca6 <writei+0x10e>
{
    80003b9e:	7159                	addi	sp,sp,-112
    80003ba0:	f486                	sd	ra,104(sp)
    80003ba2:	f0a2                	sd	s0,96(sp)
    80003ba4:	eca6                	sd	s1,88(sp)
    80003ba6:	e8ca                	sd	s2,80(sp)
    80003ba8:	e4ce                	sd	s3,72(sp)
    80003baa:	e0d2                	sd	s4,64(sp)
    80003bac:	fc56                	sd	s5,56(sp)
    80003bae:	f85a                	sd	s6,48(sp)
    80003bb0:	f45e                	sd	s7,40(sp)
    80003bb2:	f062                	sd	s8,32(sp)
    80003bb4:	ec66                	sd	s9,24(sp)
    80003bb6:	e86a                	sd	s10,16(sp)
    80003bb8:	e46e                	sd	s11,8(sp)
    80003bba:	1880                	addi	s0,sp,112
    80003bbc:	8baa                	mv	s7,a0
    80003bbe:	8c2e                	mv	s8,a1
    80003bc0:	8ab2                	mv	s5,a2
    80003bc2:	84b6                	mv	s1,a3
    80003bc4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003bc6:	00e687bb          	addw	a5,a3,a4
    80003bca:	0ed7e063          	bltu	a5,a3,80003caa <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003bce:	00043737          	lui	a4,0x43
    80003bd2:	0cf76e63          	bltu	a4,a5,80003cae <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bd6:	0a0b0763          	beqz	s6,80003c84 <writei+0xec>
    80003bda:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bdc:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003be0:	5cfd                	li	s9,-1
    80003be2:	a091                	j	80003c26 <writei+0x8e>
    80003be4:	02091d93          	slli	s11,s2,0x20
    80003be8:	020ddd93          	srli	s11,s11,0x20
    80003bec:	05898513          	addi	a0,s3,88
    80003bf0:	86ee                	mv	a3,s11
    80003bf2:	8656                	mv	a2,s5
    80003bf4:	85e2                	mv	a1,s8
    80003bf6:	953a                	add	a0,a0,a4
    80003bf8:	fffff097          	auipc	ra,0xfffff
    80003bfc:	9d4080e7          	jalr	-1580(ra) # 800025cc <either_copyin>
    80003c00:	07950263          	beq	a0,s9,80003c64 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c04:	854e                	mv	a0,s3
    80003c06:	00000097          	auipc	ra,0x0
    80003c0a:	78a080e7          	jalr	1930(ra) # 80004390 <log_write>
    brelse(bp);
    80003c0e:	854e                	mv	a0,s3
    80003c10:	fffff097          	auipc	ra,0xfffff
    80003c14:	4d6080e7          	jalr	1238(ra) # 800030e6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c18:	01490a3b          	addw	s4,s2,s4
    80003c1c:	009904bb          	addw	s1,s2,s1
    80003c20:	9aee                	add	s5,s5,s11
    80003c22:	056a7663          	bleu	s6,s4,80003c6e <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c26:	000ba903          	lw	s2,0(s7)
    80003c2a:	00a4d59b          	srliw	a1,s1,0xa
    80003c2e:	855e                	mv	a0,s7
    80003c30:	fffff097          	auipc	ra,0xfffff
    80003c34:	7ac080e7          	jalr	1964(ra) # 800033dc <bmap>
    80003c38:	0005059b          	sext.w	a1,a0
    80003c3c:	854a                	mv	a0,s2
    80003c3e:	fffff097          	auipc	ra,0xfffff
    80003c42:	366080e7          	jalr	870(ra) # 80002fa4 <bread>
    80003c46:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c48:	3ff4f713          	andi	a4,s1,1023
    80003c4c:	40ed07bb          	subw	a5,s10,a4
    80003c50:	414b06bb          	subw	a3,s6,s4
    80003c54:	893e                	mv	s2,a5
    80003c56:	2781                	sext.w	a5,a5
    80003c58:	0006861b          	sext.w	a2,a3
    80003c5c:	f8f674e3          	bleu	a5,a2,80003be4 <writei+0x4c>
    80003c60:	8936                	mv	s2,a3
    80003c62:	b749                	j	80003be4 <writei+0x4c>
      brelse(bp);
    80003c64:	854e                	mv	a0,s3
    80003c66:	fffff097          	auipc	ra,0xfffff
    80003c6a:	480080e7          	jalr	1152(ra) # 800030e6 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003c6e:	04cba783          	lw	a5,76(s7)
    80003c72:	0097f463          	bleu	s1,a5,80003c7a <writei+0xe2>
      ip->size = off;
    80003c76:	049ba623          	sw	s1,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003c7a:	855e                	mv	a0,s7
    80003c7c:	00000097          	auipc	ra,0x0
    80003c80:	aa4080e7          	jalr	-1372(ra) # 80003720 <iupdate>
  }

  return n;
    80003c84:	000b051b          	sext.w	a0,s6
}
    80003c88:	70a6                	ld	ra,104(sp)
    80003c8a:	7406                	ld	s0,96(sp)
    80003c8c:	64e6                	ld	s1,88(sp)
    80003c8e:	6946                	ld	s2,80(sp)
    80003c90:	69a6                	ld	s3,72(sp)
    80003c92:	6a06                	ld	s4,64(sp)
    80003c94:	7ae2                	ld	s5,56(sp)
    80003c96:	7b42                	ld	s6,48(sp)
    80003c98:	7ba2                	ld	s7,40(sp)
    80003c9a:	7c02                	ld	s8,32(sp)
    80003c9c:	6ce2                	ld	s9,24(sp)
    80003c9e:	6d42                	ld	s10,16(sp)
    80003ca0:	6da2                	ld	s11,8(sp)
    80003ca2:	6165                	addi	sp,sp,112
    80003ca4:	8082                	ret
    return -1;
    80003ca6:	557d                	li	a0,-1
}
    80003ca8:	8082                	ret
    return -1;
    80003caa:	557d                	li	a0,-1
    80003cac:	bff1                	j	80003c88 <writei+0xf0>
    return -1;
    80003cae:	557d                	li	a0,-1
    80003cb0:	bfe1                	j	80003c88 <writei+0xf0>

0000000080003cb2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003cb2:	1141                	addi	sp,sp,-16
    80003cb4:	e406                	sd	ra,8(sp)
    80003cb6:	e022                	sd	s0,0(sp)
    80003cb8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003cba:	4639                	li	a2,14
    80003cbc:	ffffd097          	auipc	ra,0xffffd
    80003cc0:	1ee080e7          	jalr	494(ra) # 80000eaa <strncmp>
}
    80003cc4:	60a2                	ld	ra,8(sp)
    80003cc6:	6402                	ld	s0,0(sp)
    80003cc8:	0141                	addi	sp,sp,16
    80003cca:	8082                	ret

0000000080003ccc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ccc:	7139                	addi	sp,sp,-64
    80003cce:	fc06                	sd	ra,56(sp)
    80003cd0:	f822                	sd	s0,48(sp)
    80003cd2:	f426                	sd	s1,40(sp)
    80003cd4:	f04a                	sd	s2,32(sp)
    80003cd6:	ec4e                	sd	s3,24(sp)
    80003cd8:	e852                	sd	s4,16(sp)
    80003cda:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003cdc:	04451703          	lh	a4,68(a0)
    80003ce0:	4785                	li	a5,1
    80003ce2:	00f71a63          	bne	a4,a5,80003cf6 <dirlookup+0x2a>
    80003ce6:	892a                	mv	s2,a0
    80003ce8:	89ae                	mv	s3,a1
    80003cea:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cec:	457c                	lw	a5,76(a0)
    80003cee:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003cf0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cf2:	e79d                	bnez	a5,80003d20 <dirlookup+0x54>
    80003cf4:	a8a5                	j	80003d6c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003cf6:	00005517          	auipc	a0,0x5
    80003cfa:	8fa50513          	addi	a0,a0,-1798 # 800085f0 <syscalls+0x1d8>
    80003cfe:	ffffd097          	auipc	ra,0xffffd
    80003d02:	904080e7          	jalr	-1788(ra) # 80000602 <panic>
      panic("dirlookup read");
    80003d06:	00005517          	auipc	a0,0x5
    80003d0a:	90250513          	addi	a0,a0,-1790 # 80008608 <syscalls+0x1f0>
    80003d0e:	ffffd097          	auipc	ra,0xffffd
    80003d12:	8f4080e7          	jalr	-1804(ra) # 80000602 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d16:	24c1                	addiw	s1,s1,16
    80003d18:	04c92783          	lw	a5,76(s2)
    80003d1c:	04f4f763          	bleu	a5,s1,80003d6a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d20:	4741                	li	a4,16
    80003d22:	86a6                	mv	a3,s1
    80003d24:	fc040613          	addi	a2,s0,-64
    80003d28:	4581                	li	a1,0
    80003d2a:	854a                	mv	a0,s2
    80003d2c:	00000097          	auipc	ra,0x0
    80003d30:	d76080e7          	jalr	-650(ra) # 80003aa2 <readi>
    80003d34:	47c1                	li	a5,16
    80003d36:	fcf518e3          	bne	a0,a5,80003d06 <dirlookup+0x3a>
    if(de.inum == 0)
    80003d3a:	fc045783          	lhu	a5,-64(s0)
    80003d3e:	dfe1                	beqz	a5,80003d16 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003d40:	fc240593          	addi	a1,s0,-62
    80003d44:	854e                	mv	a0,s3
    80003d46:	00000097          	auipc	ra,0x0
    80003d4a:	f6c080e7          	jalr	-148(ra) # 80003cb2 <namecmp>
    80003d4e:	f561                	bnez	a0,80003d16 <dirlookup+0x4a>
      if(poff)
    80003d50:	000a0463          	beqz	s4,80003d58 <dirlookup+0x8c>
        *poff = off;
    80003d54:	009a2023          	sw	s1,0(s4) # 2000 <_entry-0x7fffe000>
      return iget(dp->dev, inum);
    80003d58:	fc045583          	lhu	a1,-64(s0)
    80003d5c:	00092503          	lw	a0,0(s2)
    80003d60:	fffff097          	auipc	ra,0xfffff
    80003d64:	756080e7          	jalr	1878(ra) # 800034b6 <iget>
    80003d68:	a011                	j	80003d6c <dirlookup+0xa0>
  return 0;
    80003d6a:	4501                	li	a0,0
}
    80003d6c:	70e2                	ld	ra,56(sp)
    80003d6e:	7442                	ld	s0,48(sp)
    80003d70:	74a2                	ld	s1,40(sp)
    80003d72:	7902                	ld	s2,32(sp)
    80003d74:	69e2                	ld	s3,24(sp)
    80003d76:	6a42                	ld	s4,16(sp)
    80003d78:	6121                	addi	sp,sp,64
    80003d7a:	8082                	ret

0000000080003d7c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d7c:	711d                	addi	sp,sp,-96
    80003d7e:	ec86                	sd	ra,88(sp)
    80003d80:	e8a2                	sd	s0,80(sp)
    80003d82:	e4a6                	sd	s1,72(sp)
    80003d84:	e0ca                	sd	s2,64(sp)
    80003d86:	fc4e                	sd	s3,56(sp)
    80003d88:	f852                	sd	s4,48(sp)
    80003d8a:	f456                	sd	s5,40(sp)
    80003d8c:	f05a                	sd	s6,32(sp)
    80003d8e:	ec5e                	sd	s7,24(sp)
    80003d90:	e862                	sd	s8,16(sp)
    80003d92:	e466                	sd	s9,8(sp)
    80003d94:	1080                	addi	s0,sp,96
    80003d96:	84aa                	mv	s1,a0
    80003d98:	8bae                	mv	s7,a1
    80003d9a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d9c:	00054703          	lbu	a4,0(a0)
    80003da0:	02f00793          	li	a5,47
    80003da4:	02f70363          	beq	a4,a5,80003dca <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003da8:	ffffe097          	auipc	ra,0xffffe
    80003dac:	d2c080e7          	jalr	-724(ra) # 80001ad4 <myproc>
    80003db0:	15053503          	ld	a0,336(a0)
    80003db4:	00000097          	auipc	ra,0x0
    80003db8:	9fa080e7          	jalr	-1542(ra) # 800037ae <idup>
    80003dbc:	89aa                	mv	s3,a0
  while(*path == '/')
    80003dbe:	02f00913          	li	s2,47
  len = path - s;
    80003dc2:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003dc4:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003dc6:	4c05                	li	s8,1
    80003dc8:	a865                	j	80003e80 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003dca:	4585                	li	a1,1
    80003dcc:	4505                	li	a0,1
    80003dce:	fffff097          	auipc	ra,0xfffff
    80003dd2:	6e8080e7          	jalr	1768(ra) # 800034b6 <iget>
    80003dd6:	89aa                	mv	s3,a0
    80003dd8:	b7dd                	j	80003dbe <namex+0x42>
      iunlockput(ip);
    80003dda:	854e                	mv	a0,s3
    80003ddc:	00000097          	auipc	ra,0x0
    80003de0:	c74080e7          	jalr	-908(ra) # 80003a50 <iunlockput>
      return 0;
    80003de4:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003de6:	854e                	mv	a0,s3
    80003de8:	60e6                	ld	ra,88(sp)
    80003dea:	6446                	ld	s0,80(sp)
    80003dec:	64a6                	ld	s1,72(sp)
    80003dee:	6906                	ld	s2,64(sp)
    80003df0:	79e2                	ld	s3,56(sp)
    80003df2:	7a42                	ld	s4,48(sp)
    80003df4:	7aa2                	ld	s5,40(sp)
    80003df6:	7b02                	ld	s6,32(sp)
    80003df8:	6be2                	ld	s7,24(sp)
    80003dfa:	6c42                	ld	s8,16(sp)
    80003dfc:	6ca2                	ld	s9,8(sp)
    80003dfe:	6125                	addi	sp,sp,96
    80003e00:	8082                	ret
      iunlock(ip);
    80003e02:	854e                	mv	a0,s3
    80003e04:	00000097          	auipc	ra,0x0
    80003e08:	aac080e7          	jalr	-1364(ra) # 800038b0 <iunlock>
      return ip;
    80003e0c:	bfe9                	j	80003de6 <namex+0x6a>
      iunlockput(ip);
    80003e0e:	854e                	mv	a0,s3
    80003e10:	00000097          	auipc	ra,0x0
    80003e14:	c40080e7          	jalr	-960(ra) # 80003a50 <iunlockput>
      return 0;
    80003e18:	89d2                	mv	s3,s4
    80003e1a:	b7f1                	j	80003de6 <namex+0x6a>
  len = path - s;
    80003e1c:	40b48633          	sub	a2,s1,a1
    80003e20:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003e24:	094cd663          	ble	s4,s9,80003eb0 <namex+0x134>
    memmove(name, s, DIRSIZ);
    80003e28:	4639                	li	a2,14
    80003e2a:	8556                	mv	a0,s5
    80003e2c:	ffffd097          	auipc	ra,0xffffd
    80003e30:	002080e7          	jalr	2(ra) # 80000e2e <memmove>
  while(*path == '/')
    80003e34:	0004c783          	lbu	a5,0(s1)
    80003e38:	01279763          	bne	a5,s2,80003e46 <namex+0xca>
    path++;
    80003e3c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e3e:	0004c783          	lbu	a5,0(s1)
    80003e42:	ff278de3          	beq	a5,s2,80003e3c <namex+0xc0>
    ilock(ip);
    80003e46:	854e                	mv	a0,s3
    80003e48:	00000097          	auipc	ra,0x0
    80003e4c:	9a4080e7          	jalr	-1628(ra) # 800037ec <ilock>
    if(ip->type != T_DIR){
    80003e50:	04499783          	lh	a5,68(s3)
    80003e54:	f98793e3          	bne	a5,s8,80003dda <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003e58:	000b8563          	beqz	s7,80003e62 <namex+0xe6>
    80003e5c:	0004c783          	lbu	a5,0(s1)
    80003e60:	d3cd                	beqz	a5,80003e02 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e62:	865a                	mv	a2,s6
    80003e64:	85d6                	mv	a1,s5
    80003e66:	854e                	mv	a0,s3
    80003e68:	00000097          	auipc	ra,0x0
    80003e6c:	e64080e7          	jalr	-412(ra) # 80003ccc <dirlookup>
    80003e70:	8a2a                	mv	s4,a0
    80003e72:	dd51                	beqz	a0,80003e0e <namex+0x92>
    iunlockput(ip);
    80003e74:	854e                	mv	a0,s3
    80003e76:	00000097          	auipc	ra,0x0
    80003e7a:	bda080e7          	jalr	-1062(ra) # 80003a50 <iunlockput>
    ip = next;
    80003e7e:	89d2                	mv	s3,s4
  while(*path == '/')
    80003e80:	0004c783          	lbu	a5,0(s1)
    80003e84:	05279d63          	bne	a5,s2,80003ede <namex+0x162>
    path++;
    80003e88:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e8a:	0004c783          	lbu	a5,0(s1)
    80003e8e:	ff278de3          	beq	a5,s2,80003e88 <namex+0x10c>
  if(*path == 0)
    80003e92:	cf8d                	beqz	a5,80003ecc <namex+0x150>
  while(*path != '/' && *path != 0)
    80003e94:	01278b63          	beq	a5,s2,80003eaa <namex+0x12e>
    80003e98:	c795                	beqz	a5,80003ec4 <namex+0x148>
    path++;
    80003e9a:	85a6                	mv	a1,s1
    path++;
    80003e9c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003e9e:	0004c783          	lbu	a5,0(s1)
    80003ea2:	f7278de3          	beq	a5,s2,80003e1c <namex+0xa0>
    80003ea6:	fbfd                	bnez	a5,80003e9c <namex+0x120>
    80003ea8:	bf95                	j	80003e1c <namex+0xa0>
    80003eaa:	85a6                	mv	a1,s1
  len = path - s;
    80003eac:	8a5a                	mv	s4,s6
    80003eae:	865a                	mv	a2,s6
    memmove(name, s, len);
    80003eb0:	2601                	sext.w	a2,a2
    80003eb2:	8556                	mv	a0,s5
    80003eb4:	ffffd097          	auipc	ra,0xffffd
    80003eb8:	f7a080e7          	jalr	-134(ra) # 80000e2e <memmove>
    name[len] = 0;
    80003ebc:	9a56                	add	s4,s4,s5
    80003ebe:	000a0023          	sb	zero,0(s4)
    80003ec2:	bf8d                	j	80003e34 <namex+0xb8>
  while(*path != '/' && *path != 0)
    80003ec4:	85a6                	mv	a1,s1
  len = path - s;
    80003ec6:	8a5a                	mv	s4,s6
    80003ec8:	865a                	mv	a2,s6
    80003eca:	b7dd                	j	80003eb0 <namex+0x134>
  if(nameiparent){
    80003ecc:	f00b8de3          	beqz	s7,80003de6 <namex+0x6a>
    iput(ip);
    80003ed0:	854e                	mv	a0,s3
    80003ed2:	00000097          	auipc	ra,0x0
    80003ed6:	ad6080e7          	jalr	-1322(ra) # 800039a8 <iput>
    return 0;
    80003eda:	4981                	li	s3,0
    80003edc:	b729                	j	80003de6 <namex+0x6a>
  if(*path == 0)
    80003ede:	d7fd                	beqz	a5,80003ecc <namex+0x150>
    80003ee0:	85a6                	mv	a1,s1
    80003ee2:	bf6d                	j	80003e9c <namex+0x120>

0000000080003ee4 <dirlink>:
{
    80003ee4:	7139                	addi	sp,sp,-64
    80003ee6:	fc06                	sd	ra,56(sp)
    80003ee8:	f822                	sd	s0,48(sp)
    80003eea:	f426                	sd	s1,40(sp)
    80003eec:	f04a                	sd	s2,32(sp)
    80003eee:	ec4e                	sd	s3,24(sp)
    80003ef0:	e852                	sd	s4,16(sp)
    80003ef2:	0080                	addi	s0,sp,64
    80003ef4:	892a                	mv	s2,a0
    80003ef6:	8a2e                	mv	s4,a1
    80003ef8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003efa:	4601                	li	a2,0
    80003efc:	00000097          	auipc	ra,0x0
    80003f00:	dd0080e7          	jalr	-560(ra) # 80003ccc <dirlookup>
    80003f04:	e93d                	bnez	a0,80003f7a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f06:	04c92483          	lw	s1,76(s2)
    80003f0a:	c49d                	beqz	s1,80003f38 <dirlink+0x54>
    80003f0c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f0e:	4741                	li	a4,16
    80003f10:	86a6                	mv	a3,s1
    80003f12:	fc040613          	addi	a2,s0,-64
    80003f16:	4581                	li	a1,0
    80003f18:	854a                	mv	a0,s2
    80003f1a:	00000097          	auipc	ra,0x0
    80003f1e:	b88080e7          	jalr	-1144(ra) # 80003aa2 <readi>
    80003f22:	47c1                	li	a5,16
    80003f24:	06f51163          	bne	a0,a5,80003f86 <dirlink+0xa2>
    if(de.inum == 0)
    80003f28:	fc045783          	lhu	a5,-64(s0)
    80003f2c:	c791                	beqz	a5,80003f38 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f2e:	24c1                	addiw	s1,s1,16
    80003f30:	04c92783          	lw	a5,76(s2)
    80003f34:	fcf4ede3          	bltu	s1,a5,80003f0e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003f38:	4639                	li	a2,14
    80003f3a:	85d2                	mv	a1,s4
    80003f3c:	fc240513          	addi	a0,s0,-62
    80003f40:	ffffd097          	auipc	ra,0xffffd
    80003f44:	fba080e7          	jalr	-70(ra) # 80000efa <strncpy>
  de.inum = inum;
    80003f48:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f4c:	4741                	li	a4,16
    80003f4e:	86a6                	mv	a3,s1
    80003f50:	fc040613          	addi	a2,s0,-64
    80003f54:	4581                	li	a1,0
    80003f56:	854a                	mv	a0,s2
    80003f58:	00000097          	auipc	ra,0x0
    80003f5c:	c40080e7          	jalr	-960(ra) # 80003b98 <writei>
    80003f60:	4741                	li	a4,16
  return 0;
    80003f62:	4781                	li	a5,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f64:	02e51963          	bne	a0,a4,80003f96 <dirlink+0xb2>
}
    80003f68:	853e                	mv	a0,a5
    80003f6a:	70e2                	ld	ra,56(sp)
    80003f6c:	7442                	ld	s0,48(sp)
    80003f6e:	74a2                	ld	s1,40(sp)
    80003f70:	7902                	ld	s2,32(sp)
    80003f72:	69e2                	ld	s3,24(sp)
    80003f74:	6a42                	ld	s4,16(sp)
    80003f76:	6121                	addi	sp,sp,64
    80003f78:	8082                	ret
    iput(ip);
    80003f7a:	00000097          	auipc	ra,0x0
    80003f7e:	a2e080e7          	jalr	-1490(ra) # 800039a8 <iput>
    return -1;
    80003f82:	57fd                	li	a5,-1
    80003f84:	b7d5                	j	80003f68 <dirlink+0x84>
      panic("dirlink read");
    80003f86:	00004517          	auipc	a0,0x4
    80003f8a:	69250513          	addi	a0,a0,1682 # 80008618 <syscalls+0x200>
    80003f8e:	ffffc097          	auipc	ra,0xffffc
    80003f92:	674080e7          	jalr	1652(ra) # 80000602 <panic>
    panic("dirlink");
    80003f96:	00004517          	auipc	a0,0x4
    80003f9a:	7a250513          	addi	a0,a0,1954 # 80008738 <syscalls+0x320>
    80003f9e:	ffffc097          	auipc	ra,0xffffc
    80003fa2:	664080e7          	jalr	1636(ra) # 80000602 <panic>

0000000080003fa6 <namei>:

struct inode*
namei(char *path)
{
    80003fa6:	1101                	addi	sp,sp,-32
    80003fa8:	ec06                	sd	ra,24(sp)
    80003faa:	e822                	sd	s0,16(sp)
    80003fac:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003fae:	fe040613          	addi	a2,s0,-32
    80003fb2:	4581                	li	a1,0
    80003fb4:	00000097          	auipc	ra,0x0
    80003fb8:	dc8080e7          	jalr	-568(ra) # 80003d7c <namex>
}
    80003fbc:	60e2                	ld	ra,24(sp)
    80003fbe:	6442                	ld	s0,16(sp)
    80003fc0:	6105                	addi	sp,sp,32
    80003fc2:	8082                	ret

0000000080003fc4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003fc4:	1141                	addi	sp,sp,-16
    80003fc6:	e406                	sd	ra,8(sp)
    80003fc8:	e022                	sd	s0,0(sp)
    80003fca:	0800                	addi	s0,sp,16
  return namex(path, 1, name);
    80003fcc:	862e                	mv	a2,a1
    80003fce:	4585                	li	a1,1
    80003fd0:	00000097          	auipc	ra,0x0
    80003fd4:	dac080e7          	jalr	-596(ra) # 80003d7c <namex>
}
    80003fd8:	60a2                	ld	ra,8(sp)
    80003fda:	6402                	ld	s0,0(sp)
    80003fdc:	0141                	addi	sp,sp,16
    80003fde:	8082                	ret

0000000080003fe0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003fe0:	1101                	addi	sp,sp,-32
    80003fe2:	ec06                	sd	ra,24(sp)
    80003fe4:	e822                	sd	s0,16(sp)
    80003fe6:	e426                	sd	s1,8(sp)
    80003fe8:	e04a                	sd	s2,0(sp)
    80003fea:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003fec:	0001e917          	auipc	s2,0x1e
    80003ff0:	f1c90913          	addi	s2,s2,-228 # 80021f08 <log>
    80003ff4:	01892583          	lw	a1,24(s2)
    80003ff8:	02892503          	lw	a0,40(s2)
    80003ffc:	fffff097          	auipc	ra,0xfffff
    80004000:	fa8080e7          	jalr	-88(ra) # 80002fa4 <bread>
    80004004:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004006:	02c92683          	lw	a3,44(s2)
    8000400a:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000400c:	02d05763          	blez	a3,8000403a <write_head+0x5a>
    80004010:	0001e797          	auipc	a5,0x1e
    80004014:	f2878793          	addi	a5,a5,-216 # 80021f38 <log+0x30>
    80004018:	05c50713          	addi	a4,a0,92
    8000401c:	36fd                	addiw	a3,a3,-1
    8000401e:	1682                	slli	a3,a3,0x20
    80004020:	9281                	srli	a3,a3,0x20
    80004022:	068a                	slli	a3,a3,0x2
    80004024:	0001e617          	auipc	a2,0x1e
    80004028:	f1860613          	addi	a2,a2,-232 # 80021f3c <log+0x34>
    8000402c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000402e:	4390                	lw	a2,0(a5)
    80004030:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004032:	0791                	addi	a5,a5,4
    80004034:	0711                	addi	a4,a4,4
    80004036:	fed79ce3          	bne	a5,a3,8000402e <write_head+0x4e>
  }
  bwrite(buf);
    8000403a:	8526                	mv	a0,s1
    8000403c:	fffff097          	auipc	ra,0xfffff
    80004040:	06c080e7          	jalr	108(ra) # 800030a8 <bwrite>
  brelse(buf);
    80004044:	8526                	mv	a0,s1
    80004046:	fffff097          	auipc	ra,0xfffff
    8000404a:	0a0080e7          	jalr	160(ra) # 800030e6 <brelse>
}
    8000404e:	60e2                	ld	ra,24(sp)
    80004050:	6442                	ld	s0,16(sp)
    80004052:	64a2                	ld	s1,8(sp)
    80004054:	6902                	ld	s2,0(sp)
    80004056:	6105                	addi	sp,sp,32
    80004058:	8082                	ret

000000008000405a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000405a:	0001e797          	auipc	a5,0x1e
    8000405e:	eae78793          	addi	a5,a5,-338 # 80021f08 <log>
    80004062:	57dc                	lw	a5,44(a5)
    80004064:	0af05663          	blez	a5,80004110 <install_trans+0xb6>
{
    80004068:	7139                	addi	sp,sp,-64
    8000406a:	fc06                	sd	ra,56(sp)
    8000406c:	f822                	sd	s0,48(sp)
    8000406e:	f426                	sd	s1,40(sp)
    80004070:	f04a                	sd	s2,32(sp)
    80004072:	ec4e                	sd	s3,24(sp)
    80004074:	e852                	sd	s4,16(sp)
    80004076:	e456                	sd	s5,8(sp)
    80004078:	0080                	addi	s0,sp,64
    8000407a:	0001ea17          	auipc	s4,0x1e
    8000407e:	ebea0a13          	addi	s4,s4,-322 # 80021f38 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004082:	4981                	li	s3,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004084:	0001e917          	auipc	s2,0x1e
    80004088:	e8490913          	addi	s2,s2,-380 # 80021f08 <log>
    8000408c:	01892583          	lw	a1,24(s2)
    80004090:	013585bb          	addw	a1,a1,s3
    80004094:	2585                	addiw	a1,a1,1
    80004096:	02892503          	lw	a0,40(s2)
    8000409a:	fffff097          	auipc	ra,0xfffff
    8000409e:	f0a080e7          	jalr	-246(ra) # 80002fa4 <bread>
    800040a2:	8aaa                	mv	s5,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800040a4:	000a2583          	lw	a1,0(s4)
    800040a8:	02892503          	lw	a0,40(s2)
    800040ac:	fffff097          	auipc	ra,0xfffff
    800040b0:	ef8080e7          	jalr	-264(ra) # 80002fa4 <bread>
    800040b4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800040b6:	40000613          	li	a2,1024
    800040ba:	058a8593          	addi	a1,s5,88
    800040be:	05850513          	addi	a0,a0,88
    800040c2:	ffffd097          	auipc	ra,0xffffd
    800040c6:	d6c080e7          	jalr	-660(ra) # 80000e2e <memmove>
    bwrite(dbuf);  // write dst to disk
    800040ca:	8526                	mv	a0,s1
    800040cc:	fffff097          	auipc	ra,0xfffff
    800040d0:	fdc080e7          	jalr	-36(ra) # 800030a8 <bwrite>
    bunpin(dbuf);
    800040d4:	8526                	mv	a0,s1
    800040d6:	fffff097          	auipc	ra,0xfffff
    800040da:	0ea080e7          	jalr	234(ra) # 800031c0 <bunpin>
    brelse(lbuf);
    800040de:	8556                	mv	a0,s5
    800040e0:	fffff097          	auipc	ra,0xfffff
    800040e4:	006080e7          	jalr	6(ra) # 800030e6 <brelse>
    brelse(dbuf);
    800040e8:	8526                	mv	a0,s1
    800040ea:	fffff097          	auipc	ra,0xfffff
    800040ee:	ffc080e7          	jalr	-4(ra) # 800030e6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040f2:	2985                	addiw	s3,s3,1
    800040f4:	0a11                	addi	s4,s4,4
    800040f6:	02c92783          	lw	a5,44(s2)
    800040fa:	f8f9c9e3          	blt	s3,a5,8000408c <install_trans+0x32>
}
    800040fe:	70e2                	ld	ra,56(sp)
    80004100:	7442                	ld	s0,48(sp)
    80004102:	74a2                	ld	s1,40(sp)
    80004104:	7902                	ld	s2,32(sp)
    80004106:	69e2                	ld	s3,24(sp)
    80004108:	6a42                	ld	s4,16(sp)
    8000410a:	6aa2                	ld	s5,8(sp)
    8000410c:	6121                	addi	sp,sp,64
    8000410e:	8082                	ret
    80004110:	8082                	ret

0000000080004112 <initlog>:
{
    80004112:	7179                	addi	sp,sp,-48
    80004114:	f406                	sd	ra,40(sp)
    80004116:	f022                	sd	s0,32(sp)
    80004118:	ec26                	sd	s1,24(sp)
    8000411a:	e84a                	sd	s2,16(sp)
    8000411c:	e44e                	sd	s3,8(sp)
    8000411e:	1800                	addi	s0,sp,48
    80004120:	892a                	mv	s2,a0
    80004122:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004124:	0001e497          	auipc	s1,0x1e
    80004128:	de448493          	addi	s1,s1,-540 # 80021f08 <log>
    8000412c:	00004597          	auipc	a1,0x4
    80004130:	4fc58593          	addi	a1,a1,1276 # 80008628 <syscalls+0x210>
    80004134:	8526                	mv	a0,s1
    80004136:	ffffd097          	auipc	ra,0xffffd
    8000413a:	b00080e7          	jalr	-1280(ra) # 80000c36 <initlock>
  log.start = sb->logstart;
    8000413e:	0149a583          	lw	a1,20(s3)
    80004142:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004144:	0109a783          	lw	a5,16(s3)
    80004148:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000414a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000414e:	854a                	mv	a0,s2
    80004150:	fffff097          	auipc	ra,0xfffff
    80004154:	e54080e7          	jalr	-428(ra) # 80002fa4 <bread>
  log.lh.n = lh->n;
    80004158:	4d3c                	lw	a5,88(a0)
    8000415a:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000415c:	02f05563          	blez	a5,80004186 <initlog+0x74>
    80004160:	05c50713          	addi	a4,a0,92
    80004164:	0001e697          	auipc	a3,0x1e
    80004168:	dd468693          	addi	a3,a3,-556 # 80021f38 <log+0x30>
    8000416c:	37fd                	addiw	a5,a5,-1
    8000416e:	1782                	slli	a5,a5,0x20
    80004170:	9381                	srli	a5,a5,0x20
    80004172:	078a                	slli	a5,a5,0x2
    80004174:	06050613          	addi	a2,a0,96
    80004178:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    8000417a:	4310                	lw	a2,0(a4)
    8000417c:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000417e:	0711                	addi	a4,a4,4
    80004180:	0691                	addi	a3,a3,4
    80004182:	fef71ce3          	bne	a4,a5,8000417a <initlog+0x68>
  brelse(buf);
    80004186:	fffff097          	auipc	ra,0xfffff
    8000418a:	f60080e7          	jalr	-160(ra) # 800030e6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    8000418e:	00000097          	auipc	ra,0x0
    80004192:	ecc080e7          	jalr	-308(ra) # 8000405a <install_trans>
  log.lh.n = 0;
    80004196:	0001e797          	auipc	a5,0x1e
    8000419a:	d807af23          	sw	zero,-610(a5) # 80021f34 <log+0x2c>
  write_head(); // clear the log
    8000419e:	00000097          	auipc	ra,0x0
    800041a2:	e42080e7          	jalr	-446(ra) # 80003fe0 <write_head>
}
    800041a6:	70a2                	ld	ra,40(sp)
    800041a8:	7402                	ld	s0,32(sp)
    800041aa:	64e2                	ld	s1,24(sp)
    800041ac:	6942                	ld	s2,16(sp)
    800041ae:	69a2                	ld	s3,8(sp)
    800041b0:	6145                	addi	sp,sp,48
    800041b2:	8082                	ret

00000000800041b4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800041b4:	1101                	addi	sp,sp,-32
    800041b6:	ec06                	sd	ra,24(sp)
    800041b8:	e822                	sd	s0,16(sp)
    800041ba:	e426                	sd	s1,8(sp)
    800041bc:	e04a                	sd	s2,0(sp)
    800041be:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800041c0:	0001e517          	auipc	a0,0x1e
    800041c4:	d4850513          	addi	a0,a0,-696 # 80021f08 <log>
    800041c8:	ffffd097          	auipc	ra,0xffffd
    800041cc:	afe080e7          	jalr	-1282(ra) # 80000cc6 <acquire>
  while(1){
    if(log.committing){
    800041d0:	0001e497          	auipc	s1,0x1e
    800041d4:	d3848493          	addi	s1,s1,-712 # 80021f08 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041d8:	4979                	li	s2,30
    800041da:	a039                	j	800041e8 <begin_op+0x34>
      sleep(&log, &log.lock);
    800041dc:	85a6                	mv	a1,s1
    800041de:	8526                	mv	a0,s1
    800041e0:	ffffe097          	auipc	ra,0xffffe
    800041e4:	134080e7          	jalr	308(ra) # 80002314 <sleep>
    if(log.committing){
    800041e8:	50dc                	lw	a5,36(s1)
    800041ea:	fbed                	bnez	a5,800041dc <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041ec:	509c                	lw	a5,32(s1)
    800041ee:	0017871b          	addiw	a4,a5,1
    800041f2:	0007069b          	sext.w	a3,a4
    800041f6:	0027179b          	slliw	a5,a4,0x2
    800041fa:	9fb9                	addw	a5,a5,a4
    800041fc:	0017979b          	slliw	a5,a5,0x1
    80004200:	54d8                	lw	a4,44(s1)
    80004202:	9fb9                	addw	a5,a5,a4
    80004204:	00f95963          	ble	a5,s2,80004216 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004208:	85a6                	mv	a1,s1
    8000420a:	8526                	mv	a0,s1
    8000420c:	ffffe097          	auipc	ra,0xffffe
    80004210:	108080e7          	jalr	264(ra) # 80002314 <sleep>
    80004214:	bfd1                	j	800041e8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004216:	0001e517          	auipc	a0,0x1e
    8000421a:	cf250513          	addi	a0,a0,-782 # 80021f08 <log>
    8000421e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004220:	ffffd097          	auipc	ra,0xffffd
    80004224:	b5a080e7          	jalr	-1190(ra) # 80000d7a <release>
      break;
    }
  }
}
    80004228:	60e2                	ld	ra,24(sp)
    8000422a:	6442                	ld	s0,16(sp)
    8000422c:	64a2                	ld	s1,8(sp)
    8000422e:	6902                	ld	s2,0(sp)
    80004230:	6105                	addi	sp,sp,32
    80004232:	8082                	ret

0000000080004234 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004234:	7139                	addi	sp,sp,-64
    80004236:	fc06                	sd	ra,56(sp)
    80004238:	f822                	sd	s0,48(sp)
    8000423a:	f426                	sd	s1,40(sp)
    8000423c:	f04a                	sd	s2,32(sp)
    8000423e:	ec4e                	sd	s3,24(sp)
    80004240:	e852                	sd	s4,16(sp)
    80004242:	e456                	sd	s5,8(sp)
    80004244:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004246:	0001e917          	auipc	s2,0x1e
    8000424a:	cc290913          	addi	s2,s2,-830 # 80021f08 <log>
    8000424e:	854a                	mv	a0,s2
    80004250:	ffffd097          	auipc	ra,0xffffd
    80004254:	a76080e7          	jalr	-1418(ra) # 80000cc6 <acquire>
  log.outstanding -= 1;
    80004258:	02092783          	lw	a5,32(s2)
    8000425c:	37fd                	addiw	a5,a5,-1
    8000425e:	0007849b          	sext.w	s1,a5
    80004262:	02f92023          	sw	a5,32(s2)
  if(log.committing)
    80004266:	02492783          	lw	a5,36(s2)
    8000426a:	eba1                	bnez	a5,800042ba <end_op+0x86>
    panic("log.committing");
  if(log.outstanding == 0){
    8000426c:	ecb9                	bnez	s1,800042ca <end_op+0x96>
    do_commit = 1;
    log.committing = 1;
    8000426e:	0001e917          	auipc	s2,0x1e
    80004272:	c9a90913          	addi	s2,s2,-870 # 80021f08 <log>
    80004276:	4785                	li	a5,1
    80004278:	02f92223          	sw	a5,36(s2)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000427c:	854a                	mv	a0,s2
    8000427e:	ffffd097          	auipc	ra,0xffffd
    80004282:	afc080e7          	jalr	-1284(ra) # 80000d7a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004286:	02c92783          	lw	a5,44(s2)
    8000428a:	06f04763          	bgtz	a5,800042f8 <end_op+0xc4>
    acquire(&log.lock);
    8000428e:	0001e497          	auipc	s1,0x1e
    80004292:	c7a48493          	addi	s1,s1,-902 # 80021f08 <log>
    80004296:	8526                	mv	a0,s1
    80004298:	ffffd097          	auipc	ra,0xffffd
    8000429c:	a2e080e7          	jalr	-1490(ra) # 80000cc6 <acquire>
    log.committing = 0;
    800042a0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800042a4:	8526                	mv	a0,s1
    800042a6:	ffffe097          	auipc	ra,0xffffe
    800042aa:	1f4080e7          	jalr	500(ra) # 8000249a <wakeup>
    release(&log.lock);
    800042ae:	8526                	mv	a0,s1
    800042b0:	ffffd097          	auipc	ra,0xffffd
    800042b4:	aca080e7          	jalr	-1334(ra) # 80000d7a <release>
}
    800042b8:	a03d                	j	800042e6 <end_op+0xb2>
    panic("log.committing");
    800042ba:	00004517          	auipc	a0,0x4
    800042be:	37650513          	addi	a0,a0,886 # 80008630 <syscalls+0x218>
    800042c2:	ffffc097          	auipc	ra,0xffffc
    800042c6:	340080e7          	jalr	832(ra) # 80000602 <panic>
    wakeup(&log);
    800042ca:	0001e497          	auipc	s1,0x1e
    800042ce:	c3e48493          	addi	s1,s1,-962 # 80021f08 <log>
    800042d2:	8526                	mv	a0,s1
    800042d4:	ffffe097          	auipc	ra,0xffffe
    800042d8:	1c6080e7          	jalr	454(ra) # 8000249a <wakeup>
  release(&log.lock);
    800042dc:	8526                	mv	a0,s1
    800042de:	ffffd097          	auipc	ra,0xffffd
    800042e2:	a9c080e7          	jalr	-1380(ra) # 80000d7a <release>
}
    800042e6:	70e2                	ld	ra,56(sp)
    800042e8:	7442                	ld	s0,48(sp)
    800042ea:	74a2                	ld	s1,40(sp)
    800042ec:	7902                	ld	s2,32(sp)
    800042ee:	69e2                	ld	s3,24(sp)
    800042f0:	6a42                	ld	s4,16(sp)
    800042f2:	6aa2                	ld	s5,8(sp)
    800042f4:	6121                	addi	sp,sp,64
    800042f6:	8082                	ret
    800042f8:	0001ea17          	auipc	s4,0x1e
    800042fc:	c40a0a13          	addi	s4,s4,-960 # 80021f38 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004300:	0001e917          	auipc	s2,0x1e
    80004304:	c0890913          	addi	s2,s2,-1016 # 80021f08 <log>
    80004308:	01892583          	lw	a1,24(s2)
    8000430c:	9da5                	addw	a1,a1,s1
    8000430e:	2585                	addiw	a1,a1,1
    80004310:	02892503          	lw	a0,40(s2)
    80004314:	fffff097          	auipc	ra,0xfffff
    80004318:	c90080e7          	jalr	-880(ra) # 80002fa4 <bread>
    8000431c:	89aa                	mv	s3,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000431e:	000a2583          	lw	a1,0(s4)
    80004322:	02892503          	lw	a0,40(s2)
    80004326:	fffff097          	auipc	ra,0xfffff
    8000432a:	c7e080e7          	jalr	-898(ra) # 80002fa4 <bread>
    8000432e:	8aaa                	mv	s5,a0
    memmove(to->data, from->data, BSIZE);
    80004330:	40000613          	li	a2,1024
    80004334:	05850593          	addi	a1,a0,88
    80004338:	05898513          	addi	a0,s3,88
    8000433c:	ffffd097          	auipc	ra,0xffffd
    80004340:	af2080e7          	jalr	-1294(ra) # 80000e2e <memmove>
    bwrite(to);  // write the log
    80004344:	854e                	mv	a0,s3
    80004346:	fffff097          	auipc	ra,0xfffff
    8000434a:	d62080e7          	jalr	-670(ra) # 800030a8 <bwrite>
    brelse(from);
    8000434e:	8556                	mv	a0,s5
    80004350:	fffff097          	auipc	ra,0xfffff
    80004354:	d96080e7          	jalr	-618(ra) # 800030e6 <brelse>
    brelse(to);
    80004358:	854e                	mv	a0,s3
    8000435a:	fffff097          	auipc	ra,0xfffff
    8000435e:	d8c080e7          	jalr	-628(ra) # 800030e6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004362:	2485                	addiw	s1,s1,1
    80004364:	0a11                	addi	s4,s4,4
    80004366:	02c92783          	lw	a5,44(s2)
    8000436a:	f8f4cfe3          	blt	s1,a5,80004308 <end_op+0xd4>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000436e:	00000097          	auipc	ra,0x0
    80004372:	c72080e7          	jalr	-910(ra) # 80003fe0 <write_head>
    install_trans(); // Now install writes to home locations
    80004376:	00000097          	auipc	ra,0x0
    8000437a:	ce4080e7          	jalr	-796(ra) # 8000405a <install_trans>
    log.lh.n = 0;
    8000437e:	0001e797          	auipc	a5,0x1e
    80004382:	ba07ab23          	sw	zero,-1098(a5) # 80021f34 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004386:	00000097          	auipc	ra,0x0
    8000438a:	c5a080e7          	jalr	-934(ra) # 80003fe0 <write_head>
    8000438e:	b701                	j	8000428e <end_op+0x5a>

0000000080004390 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004390:	1101                	addi	sp,sp,-32
    80004392:	ec06                	sd	ra,24(sp)
    80004394:	e822                	sd	s0,16(sp)
    80004396:	e426                	sd	s1,8(sp)
    80004398:	e04a                	sd	s2,0(sp)
    8000439a:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000439c:	0001e797          	auipc	a5,0x1e
    800043a0:	b6c78793          	addi	a5,a5,-1172 # 80021f08 <log>
    800043a4:	57d8                	lw	a4,44(a5)
    800043a6:	47f5                	li	a5,29
    800043a8:	08e7c563          	blt	a5,a4,80004432 <log_write+0xa2>
    800043ac:	892a                	mv	s2,a0
    800043ae:	0001e797          	auipc	a5,0x1e
    800043b2:	b5a78793          	addi	a5,a5,-1190 # 80021f08 <log>
    800043b6:	4fdc                	lw	a5,28(a5)
    800043b8:	37fd                	addiw	a5,a5,-1
    800043ba:	06f75c63          	ble	a5,a4,80004432 <log_write+0xa2>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800043be:	0001e797          	auipc	a5,0x1e
    800043c2:	b4a78793          	addi	a5,a5,-1206 # 80021f08 <log>
    800043c6:	539c                	lw	a5,32(a5)
    800043c8:	06f05d63          	blez	a5,80004442 <log_write+0xb2>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800043cc:	0001e497          	auipc	s1,0x1e
    800043d0:	b3c48493          	addi	s1,s1,-1220 # 80021f08 <log>
    800043d4:	8526                	mv	a0,s1
    800043d6:	ffffd097          	auipc	ra,0xffffd
    800043da:	8f0080e7          	jalr	-1808(ra) # 80000cc6 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800043de:	54d0                	lw	a2,44(s1)
    800043e0:	0ac05063          	blez	a2,80004480 <log_write+0xf0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800043e4:	00c92583          	lw	a1,12(s2)
    800043e8:	589c                	lw	a5,48(s1)
    800043ea:	0ab78363          	beq	a5,a1,80004490 <log_write+0x100>
    800043ee:	0001e717          	auipc	a4,0x1e
    800043f2:	b4e70713          	addi	a4,a4,-1202 # 80021f3c <log+0x34>
  for (i = 0; i < log.lh.n; i++) {
    800043f6:	4781                	li	a5,0
    800043f8:	2785                	addiw	a5,a5,1
    800043fa:	04c78c63          	beq	a5,a2,80004452 <log_write+0xc2>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800043fe:	4314                	lw	a3,0(a4)
    80004400:	0711                	addi	a4,a4,4
    80004402:	feb69be3          	bne	a3,a1,800043f8 <log_write+0x68>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004406:	07a1                	addi	a5,a5,8
    80004408:	078a                	slli	a5,a5,0x2
    8000440a:	0001e717          	auipc	a4,0x1e
    8000440e:	afe70713          	addi	a4,a4,-1282 # 80021f08 <log>
    80004412:	97ba                	add	a5,a5,a4
    80004414:	cb8c                	sw	a1,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    log.lh.n++;
  }
  release(&log.lock);
    80004416:	0001e517          	auipc	a0,0x1e
    8000441a:	af250513          	addi	a0,a0,-1294 # 80021f08 <log>
    8000441e:	ffffd097          	auipc	ra,0xffffd
    80004422:	95c080e7          	jalr	-1700(ra) # 80000d7a <release>
}
    80004426:	60e2                	ld	ra,24(sp)
    80004428:	6442                	ld	s0,16(sp)
    8000442a:	64a2                	ld	s1,8(sp)
    8000442c:	6902                	ld	s2,0(sp)
    8000442e:	6105                	addi	sp,sp,32
    80004430:	8082                	ret
    panic("too big a transaction");
    80004432:	00004517          	auipc	a0,0x4
    80004436:	20e50513          	addi	a0,a0,526 # 80008640 <syscalls+0x228>
    8000443a:	ffffc097          	auipc	ra,0xffffc
    8000443e:	1c8080e7          	jalr	456(ra) # 80000602 <panic>
    panic("log_write outside of trans");
    80004442:	00004517          	auipc	a0,0x4
    80004446:	21650513          	addi	a0,a0,534 # 80008658 <syscalls+0x240>
    8000444a:	ffffc097          	auipc	ra,0xffffc
    8000444e:	1b8080e7          	jalr	440(ra) # 80000602 <panic>
  log.lh.block[i] = b->blockno;
    80004452:	0621                	addi	a2,a2,8
    80004454:	060a                	slli	a2,a2,0x2
    80004456:	0001e797          	auipc	a5,0x1e
    8000445a:	ab278793          	addi	a5,a5,-1358 # 80021f08 <log>
    8000445e:	963e                	add	a2,a2,a5
    80004460:	00c92783          	lw	a5,12(s2)
    80004464:	ca1c                	sw	a5,16(a2)
    bpin(b);
    80004466:	854a                	mv	a0,s2
    80004468:	fffff097          	auipc	ra,0xfffff
    8000446c:	d1c080e7          	jalr	-740(ra) # 80003184 <bpin>
    log.lh.n++;
    80004470:	0001e717          	auipc	a4,0x1e
    80004474:	a9870713          	addi	a4,a4,-1384 # 80021f08 <log>
    80004478:	575c                	lw	a5,44(a4)
    8000447a:	2785                	addiw	a5,a5,1
    8000447c:	d75c                	sw	a5,44(a4)
    8000447e:	bf61                	j	80004416 <log_write+0x86>
  log.lh.block[i] = b->blockno;
    80004480:	00c92783          	lw	a5,12(s2)
    80004484:	0001e717          	auipc	a4,0x1e
    80004488:	aaf72a23          	sw	a5,-1356(a4) # 80021f38 <log+0x30>
  if (i == log.lh.n) {  // Add new block to log?
    8000448c:	f649                	bnez	a2,80004416 <log_write+0x86>
    8000448e:	bfe1                	j	80004466 <log_write+0xd6>
  for (i = 0; i < log.lh.n; i++) {
    80004490:	4781                	li	a5,0
    80004492:	bf95                	j	80004406 <log_write+0x76>

0000000080004494 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004494:	1101                	addi	sp,sp,-32
    80004496:	ec06                	sd	ra,24(sp)
    80004498:	e822                	sd	s0,16(sp)
    8000449a:	e426                	sd	s1,8(sp)
    8000449c:	e04a                	sd	s2,0(sp)
    8000449e:	1000                	addi	s0,sp,32
    800044a0:	84aa                	mv	s1,a0
    800044a2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800044a4:	00004597          	auipc	a1,0x4
    800044a8:	1d458593          	addi	a1,a1,468 # 80008678 <syscalls+0x260>
    800044ac:	0521                	addi	a0,a0,8
    800044ae:	ffffc097          	auipc	ra,0xffffc
    800044b2:	788080e7          	jalr	1928(ra) # 80000c36 <initlock>
  lk->name = name;
    800044b6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800044ba:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044be:	0204a423          	sw	zero,40(s1)
}
    800044c2:	60e2                	ld	ra,24(sp)
    800044c4:	6442                	ld	s0,16(sp)
    800044c6:	64a2                	ld	s1,8(sp)
    800044c8:	6902                	ld	s2,0(sp)
    800044ca:	6105                	addi	sp,sp,32
    800044cc:	8082                	ret

00000000800044ce <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800044ce:	1101                	addi	sp,sp,-32
    800044d0:	ec06                	sd	ra,24(sp)
    800044d2:	e822                	sd	s0,16(sp)
    800044d4:	e426                	sd	s1,8(sp)
    800044d6:	e04a                	sd	s2,0(sp)
    800044d8:	1000                	addi	s0,sp,32
    800044da:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044dc:	00850913          	addi	s2,a0,8
    800044e0:	854a                	mv	a0,s2
    800044e2:	ffffc097          	auipc	ra,0xffffc
    800044e6:	7e4080e7          	jalr	2020(ra) # 80000cc6 <acquire>
  while (lk->locked) {
    800044ea:	409c                	lw	a5,0(s1)
    800044ec:	cb89                	beqz	a5,800044fe <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800044ee:	85ca                	mv	a1,s2
    800044f0:	8526                	mv	a0,s1
    800044f2:	ffffe097          	auipc	ra,0xffffe
    800044f6:	e22080e7          	jalr	-478(ra) # 80002314 <sleep>
  while (lk->locked) {
    800044fa:	409c                	lw	a5,0(s1)
    800044fc:	fbed                	bnez	a5,800044ee <acquiresleep+0x20>
  }
  lk->locked = 1;
    800044fe:	4785                	li	a5,1
    80004500:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004502:	ffffd097          	auipc	ra,0xffffd
    80004506:	5d2080e7          	jalr	1490(ra) # 80001ad4 <myproc>
    8000450a:	5d1c                	lw	a5,56(a0)
    8000450c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000450e:	854a                	mv	a0,s2
    80004510:	ffffd097          	auipc	ra,0xffffd
    80004514:	86a080e7          	jalr	-1942(ra) # 80000d7a <release>
}
    80004518:	60e2                	ld	ra,24(sp)
    8000451a:	6442                	ld	s0,16(sp)
    8000451c:	64a2                	ld	s1,8(sp)
    8000451e:	6902                	ld	s2,0(sp)
    80004520:	6105                	addi	sp,sp,32
    80004522:	8082                	ret

0000000080004524 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004524:	1101                	addi	sp,sp,-32
    80004526:	ec06                	sd	ra,24(sp)
    80004528:	e822                	sd	s0,16(sp)
    8000452a:	e426                	sd	s1,8(sp)
    8000452c:	e04a                	sd	s2,0(sp)
    8000452e:	1000                	addi	s0,sp,32
    80004530:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004532:	00850913          	addi	s2,a0,8
    80004536:	854a                	mv	a0,s2
    80004538:	ffffc097          	auipc	ra,0xffffc
    8000453c:	78e080e7          	jalr	1934(ra) # 80000cc6 <acquire>
  lk->locked = 0;
    80004540:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004544:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004548:	8526                	mv	a0,s1
    8000454a:	ffffe097          	auipc	ra,0xffffe
    8000454e:	f50080e7          	jalr	-176(ra) # 8000249a <wakeup>
  release(&lk->lk);
    80004552:	854a                	mv	a0,s2
    80004554:	ffffd097          	auipc	ra,0xffffd
    80004558:	826080e7          	jalr	-2010(ra) # 80000d7a <release>
}
    8000455c:	60e2                	ld	ra,24(sp)
    8000455e:	6442                	ld	s0,16(sp)
    80004560:	64a2                	ld	s1,8(sp)
    80004562:	6902                	ld	s2,0(sp)
    80004564:	6105                	addi	sp,sp,32
    80004566:	8082                	ret

0000000080004568 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004568:	7179                	addi	sp,sp,-48
    8000456a:	f406                	sd	ra,40(sp)
    8000456c:	f022                	sd	s0,32(sp)
    8000456e:	ec26                	sd	s1,24(sp)
    80004570:	e84a                	sd	s2,16(sp)
    80004572:	e44e                	sd	s3,8(sp)
    80004574:	1800                	addi	s0,sp,48
    80004576:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004578:	00850913          	addi	s2,a0,8
    8000457c:	854a                	mv	a0,s2
    8000457e:	ffffc097          	auipc	ra,0xffffc
    80004582:	748080e7          	jalr	1864(ra) # 80000cc6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004586:	409c                	lw	a5,0(s1)
    80004588:	ef99                	bnez	a5,800045a6 <holdingsleep+0x3e>
    8000458a:	4481                	li	s1,0
  release(&lk->lk);
    8000458c:	854a                	mv	a0,s2
    8000458e:	ffffc097          	auipc	ra,0xffffc
    80004592:	7ec080e7          	jalr	2028(ra) # 80000d7a <release>
  return r;
}
    80004596:	8526                	mv	a0,s1
    80004598:	70a2                	ld	ra,40(sp)
    8000459a:	7402                	ld	s0,32(sp)
    8000459c:	64e2                	ld	s1,24(sp)
    8000459e:	6942                	ld	s2,16(sp)
    800045a0:	69a2                	ld	s3,8(sp)
    800045a2:	6145                	addi	sp,sp,48
    800045a4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800045a6:	0284a983          	lw	s3,40(s1)
    800045aa:	ffffd097          	auipc	ra,0xffffd
    800045ae:	52a080e7          	jalr	1322(ra) # 80001ad4 <myproc>
    800045b2:	5d04                	lw	s1,56(a0)
    800045b4:	413484b3          	sub	s1,s1,s3
    800045b8:	0014b493          	seqz	s1,s1
    800045bc:	bfc1                	j	8000458c <holdingsleep+0x24>

00000000800045be <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800045be:	1141                	addi	sp,sp,-16
    800045c0:	e406                	sd	ra,8(sp)
    800045c2:	e022                	sd	s0,0(sp)
    800045c4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800045c6:	00004597          	auipc	a1,0x4
    800045ca:	0c258593          	addi	a1,a1,194 # 80008688 <syscalls+0x270>
    800045ce:	0001e517          	auipc	a0,0x1e
    800045d2:	a8250513          	addi	a0,a0,-1406 # 80022050 <ftable>
    800045d6:	ffffc097          	auipc	ra,0xffffc
    800045da:	660080e7          	jalr	1632(ra) # 80000c36 <initlock>
}
    800045de:	60a2                	ld	ra,8(sp)
    800045e0:	6402                	ld	s0,0(sp)
    800045e2:	0141                	addi	sp,sp,16
    800045e4:	8082                	ret

00000000800045e6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800045e6:	1101                	addi	sp,sp,-32
    800045e8:	ec06                	sd	ra,24(sp)
    800045ea:	e822                	sd	s0,16(sp)
    800045ec:	e426                	sd	s1,8(sp)
    800045ee:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800045f0:	0001e517          	auipc	a0,0x1e
    800045f4:	a6050513          	addi	a0,a0,-1440 # 80022050 <ftable>
    800045f8:	ffffc097          	auipc	ra,0xffffc
    800045fc:	6ce080e7          	jalr	1742(ra) # 80000cc6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
    80004600:	0001e797          	auipc	a5,0x1e
    80004604:	a5078793          	addi	a5,a5,-1456 # 80022050 <ftable>
    80004608:	4fdc                	lw	a5,28(a5)
    8000460a:	cb8d                	beqz	a5,8000463c <filealloc+0x56>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000460c:	0001e497          	auipc	s1,0x1e
    80004610:	a8448493          	addi	s1,s1,-1404 # 80022090 <ftable+0x40>
    80004614:	0001f717          	auipc	a4,0x1f
    80004618:	9f470713          	addi	a4,a4,-1548 # 80023008 <ftable+0xfb8>
    if(f->ref == 0){
    8000461c:	40dc                	lw	a5,4(s1)
    8000461e:	c39d                	beqz	a5,80004644 <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004620:	02848493          	addi	s1,s1,40
    80004624:	fee49ce3          	bne	s1,a4,8000461c <filealloc+0x36>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004628:	0001e517          	auipc	a0,0x1e
    8000462c:	a2850513          	addi	a0,a0,-1496 # 80022050 <ftable>
    80004630:	ffffc097          	auipc	ra,0xffffc
    80004634:	74a080e7          	jalr	1866(ra) # 80000d7a <release>
  return 0;
    80004638:	4481                	li	s1,0
    8000463a:	a839                	j	80004658 <filealloc+0x72>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000463c:	0001e497          	auipc	s1,0x1e
    80004640:	a2c48493          	addi	s1,s1,-1492 # 80022068 <ftable+0x18>
      f->ref = 1;
    80004644:	4785                	li	a5,1
    80004646:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004648:	0001e517          	auipc	a0,0x1e
    8000464c:	a0850513          	addi	a0,a0,-1528 # 80022050 <ftable>
    80004650:	ffffc097          	auipc	ra,0xffffc
    80004654:	72a080e7          	jalr	1834(ra) # 80000d7a <release>
}
    80004658:	8526                	mv	a0,s1
    8000465a:	60e2                	ld	ra,24(sp)
    8000465c:	6442                	ld	s0,16(sp)
    8000465e:	64a2                	ld	s1,8(sp)
    80004660:	6105                	addi	sp,sp,32
    80004662:	8082                	ret

0000000080004664 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004664:	1101                	addi	sp,sp,-32
    80004666:	ec06                	sd	ra,24(sp)
    80004668:	e822                	sd	s0,16(sp)
    8000466a:	e426                	sd	s1,8(sp)
    8000466c:	1000                	addi	s0,sp,32
    8000466e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004670:	0001e517          	auipc	a0,0x1e
    80004674:	9e050513          	addi	a0,a0,-1568 # 80022050 <ftable>
    80004678:	ffffc097          	auipc	ra,0xffffc
    8000467c:	64e080e7          	jalr	1614(ra) # 80000cc6 <acquire>
  if(f->ref < 1)
    80004680:	40dc                	lw	a5,4(s1)
    80004682:	02f05263          	blez	a5,800046a6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004686:	2785                	addiw	a5,a5,1
    80004688:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000468a:	0001e517          	auipc	a0,0x1e
    8000468e:	9c650513          	addi	a0,a0,-1594 # 80022050 <ftable>
    80004692:	ffffc097          	auipc	ra,0xffffc
    80004696:	6e8080e7          	jalr	1768(ra) # 80000d7a <release>
  return f;
}
    8000469a:	8526                	mv	a0,s1
    8000469c:	60e2                	ld	ra,24(sp)
    8000469e:	6442                	ld	s0,16(sp)
    800046a0:	64a2                	ld	s1,8(sp)
    800046a2:	6105                	addi	sp,sp,32
    800046a4:	8082                	ret
    panic("filedup");
    800046a6:	00004517          	auipc	a0,0x4
    800046aa:	fea50513          	addi	a0,a0,-22 # 80008690 <syscalls+0x278>
    800046ae:	ffffc097          	auipc	ra,0xffffc
    800046b2:	f54080e7          	jalr	-172(ra) # 80000602 <panic>

00000000800046b6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800046b6:	7139                	addi	sp,sp,-64
    800046b8:	fc06                	sd	ra,56(sp)
    800046ba:	f822                	sd	s0,48(sp)
    800046bc:	f426                	sd	s1,40(sp)
    800046be:	f04a                	sd	s2,32(sp)
    800046c0:	ec4e                	sd	s3,24(sp)
    800046c2:	e852                	sd	s4,16(sp)
    800046c4:	e456                	sd	s5,8(sp)
    800046c6:	0080                	addi	s0,sp,64
    800046c8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800046ca:	0001e517          	auipc	a0,0x1e
    800046ce:	98650513          	addi	a0,a0,-1658 # 80022050 <ftable>
    800046d2:	ffffc097          	auipc	ra,0xffffc
    800046d6:	5f4080e7          	jalr	1524(ra) # 80000cc6 <acquire>
  if(f->ref < 1)
    800046da:	40dc                	lw	a5,4(s1)
    800046dc:	06f05163          	blez	a5,8000473e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800046e0:	37fd                	addiw	a5,a5,-1
    800046e2:	0007871b          	sext.w	a4,a5
    800046e6:	c0dc                	sw	a5,4(s1)
    800046e8:	06e04363          	bgtz	a4,8000474e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800046ec:	0004a903          	lw	s2,0(s1)
    800046f0:	0094ca83          	lbu	s5,9(s1)
    800046f4:	0104ba03          	ld	s4,16(s1)
    800046f8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800046fc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004700:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004704:	0001e517          	auipc	a0,0x1e
    80004708:	94c50513          	addi	a0,a0,-1716 # 80022050 <ftable>
    8000470c:	ffffc097          	auipc	ra,0xffffc
    80004710:	66e080e7          	jalr	1646(ra) # 80000d7a <release>

  if(ff.type == FD_PIPE){
    80004714:	4785                	li	a5,1
    80004716:	04f90d63          	beq	s2,a5,80004770 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000471a:	3979                	addiw	s2,s2,-2
    8000471c:	4785                	li	a5,1
    8000471e:	0527e063          	bltu	a5,s2,8000475e <fileclose+0xa8>
    begin_op();
    80004722:	00000097          	auipc	ra,0x0
    80004726:	a92080e7          	jalr	-1390(ra) # 800041b4 <begin_op>
    iput(ff.ip);
    8000472a:	854e                	mv	a0,s3
    8000472c:	fffff097          	auipc	ra,0xfffff
    80004730:	27c080e7          	jalr	636(ra) # 800039a8 <iput>
    end_op();
    80004734:	00000097          	auipc	ra,0x0
    80004738:	b00080e7          	jalr	-1280(ra) # 80004234 <end_op>
    8000473c:	a00d                	j	8000475e <fileclose+0xa8>
    panic("fileclose");
    8000473e:	00004517          	auipc	a0,0x4
    80004742:	f5a50513          	addi	a0,a0,-166 # 80008698 <syscalls+0x280>
    80004746:	ffffc097          	auipc	ra,0xffffc
    8000474a:	ebc080e7          	jalr	-324(ra) # 80000602 <panic>
    release(&ftable.lock);
    8000474e:	0001e517          	auipc	a0,0x1e
    80004752:	90250513          	addi	a0,a0,-1790 # 80022050 <ftable>
    80004756:	ffffc097          	auipc	ra,0xffffc
    8000475a:	624080e7          	jalr	1572(ra) # 80000d7a <release>
  }
}
    8000475e:	70e2                	ld	ra,56(sp)
    80004760:	7442                	ld	s0,48(sp)
    80004762:	74a2                	ld	s1,40(sp)
    80004764:	7902                	ld	s2,32(sp)
    80004766:	69e2                	ld	s3,24(sp)
    80004768:	6a42                	ld	s4,16(sp)
    8000476a:	6aa2                	ld	s5,8(sp)
    8000476c:	6121                	addi	sp,sp,64
    8000476e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004770:	85d6                	mv	a1,s5
    80004772:	8552                	mv	a0,s4
    80004774:	00000097          	auipc	ra,0x0
    80004778:	364080e7          	jalr	868(ra) # 80004ad8 <pipeclose>
    8000477c:	b7cd                	j	8000475e <fileclose+0xa8>

000000008000477e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000477e:	715d                	addi	sp,sp,-80
    80004780:	e486                	sd	ra,72(sp)
    80004782:	e0a2                	sd	s0,64(sp)
    80004784:	fc26                	sd	s1,56(sp)
    80004786:	f84a                	sd	s2,48(sp)
    80004788:	f44e                	sd	s3,40(sp)
    8000478a:	0880                	addi	s0,sp,80
    8000478c:	84aa                	mv	s1,a0
    8000478e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004790:	ffffd097          	auipc	ra,0xffffd
    80004794:	344080e7          	jalr	836(ra) # 80001ad4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004798:	409c                	lw	a5,0(s1)
    8000479a:	37f9                	addiw	a5,a5,-2
    8000479c:	4705                	li	a4,1
    8000479e:	04f76763          	bltu	a4,a5,800047ec <filestat+0x6e>
    800047a2:	892a                	mv	s2,a0
    ilock(f->ip);
    800047a4:	6c88                	ld	a0,24(s1)
    800047a6:	fffff097          	auipc	ra,0xfffff
    800047aa:	046080e7          	jalr	70(ra) # 800037ec <ilock>
    stati(f->ip, &st);
    800047ae:	fb840593          	addi	a1,s0,-72
    800047b2:	6c88                	ld	a0,24(s1)
    800047b4:	fffff097          	auipc	ra,0xfffff
    800047b8:	2c4080e7          	jalr	708(ra) # 80003a78 <stati>
    iunlock(f->ip);
    800047bc:	6c88                	ld	a0,24(s1)
    800047be:	fffff097          	auipc	ra,0xfffff
    800047c2:	0f2080e7          	jalr	242(ra) # 800038b0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800047c6:	46e1                	li	a3,24
    800047c8:	fb840613          	addi	a2,s0,-72
    800047cc:	85ce                	mv	a1,s3
    800047ce:	05093503          	ld	a0,80(s2)
    800047d2:	ffffd097          	auipc	ra,0xffffd
    800047d6:	fde080e7          	jalr	-34(ra) # 800017b0 <copyout>
    800047da:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800047de:	60a6                	ld	ra,72(sp)
    800047e0:	6406                	ld	s0,64(sp)
    800047e2:	74e2                	ld	s1,56(sp)
    800047e4:	7942                	ld	s2,48(sp)
    800047e6:	79a2                	ld	s3,40(sp)
    800047e8:	6161                	addi	sp,sp,80
    800047ea:	8082                	ret
  return -1;
    800047ec:	557d                	li	a0,-1
    800047ee:	bfc5                	j	800047de <filestat+0x60>

00000000800047f0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800047f0:	7179                	addi	sp,sp,-48
    800047f2:	f406                	sd	ra,40(sp)
    800047f4:	f022                	sd	s0,32(sp)
    800047f6:	ec26                	sd	s1,24(sp)
    800047f8:	e84a                	sd	s2,16(sp)
    800047fa:	e44e                	sd	s3,8(sp)
    800047fc:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800047fe:	00854783          	lbu	a5,8(a0)
    80004802:	c3d5                	beqz	a5,800048a6 <fileread+0xb6>
    80004804:	89b2                	mv	s3,a2
    80004806:	892e                	mv	s2,a1
    80004808:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    8000480a:	411c                	lw	a5,0(a0)
    8000480c:	4705                	li	a4,1
    8000480e:	04e78963          	beq	a5,a4,80004860 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004812:	470d                	li	a4,3
    80004814:	04e78d63          	beq	a5,a4,8000486e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004818:	4709                	li	a4,2
    8000481a:	06e79e63          	bne	a5,a4,80004896 <fileread+0xa6>
    ilock(f->ip);
    8000481e:	6d08                	ld	a0,24(a0)
    80004820:	fffff097          	auipc	ra,0xfffff
    80004824:	fcc080e7          	jalr	-52(ra) # 800037ec <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004828:	874e                	mv	a4,s3
    8000482a:	5094                	lw	a3,32(s1)
    8000482c:	864a                	mv	a2,s2
    8000482e:	4585                	li	a1,1
    80004830:	6c88                	ld	a0,24(s1)
    80004832:	fffff097          	auipc	ra,0xfffff
    80004836:	270080e7          	jalr	624(ra) # 80003aa2 <readi>
    8000483a:	892a                	mv	s2,a0
    8000483c:	00a05563          	blez	a0,80004846 <fileread+0x56>
      f->off += r;
    80004840:	509c                	lw	a5,32(s1)
    80004842:	9fa9                	addw	a5,a5,a0
    80004844:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004846:	6c88                	ld	a0,24(s1)
    80004848:	fffff097          	auipc	ra,0xfffff
    8000484c:	068080e7          	jalr	104(ra) # 800038b0 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004850:	854a                	mv	a0,s2
    80004852:	70a2                	ld	ra,40(sp)
    80004854:	7402                	ld	s0,32(sp)
    80004856:	64e2                	ld	s1,24(sp)
    80004858:	6942                	ld	s2,16(sp)
    8000485a:	69a2                	ld	s3,8(sp)
    8000485c:	6145                	addi	sp,sp,48
    8000485e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004860:	6908                	ld	a0,16(a0)
    80004862:	00000097          	auipc	ra,0x0
    80004866:	416080e7          	jalr	1046(ra) # 80004c78 <piperead>
    8000486a:	892a                	mv	s2,a0
    8000486c:	b7d5                	j	80004850 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000486e:	02451783          	lh	a5,36(a0)
    80004872:	03079693          	slli	a3,a5,0x30
    80004876:	92c1                	srli	a3,a3,0x30
    80004878:	4725                	li	a4,9
    8000487a:	02d76863          	bltu	a4,a3,800048aa <fileread+0xba>
    8000487e:	0792                	slli	a5,a5,0x4
    80004880:	0001d717          	auipc	a4,0x1d
    80004884:	73070713          	addi	a4,a4,1840 # 80021fb0 <devsw>
    80004888:	97ba                	add	a5,a5,a4
    8000488a:	639c                	ld	a5,0(a5)
    8000488c:	c38d                	beqz	a5,800048ae <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000488e:	4505                	li	a0,1
    80004890:	9782                	jalr	a5
    80004892:	892a                	mv	s2,a0
    80004894:	bf75                	j	80004850 <fileread+0x60>
    panic("fileread");
    80004896:	00004517          	auipc	a0,0x4
    8000489a:	e1250513          	addi	a0,a0,-494 # 800086a8 <syscalls+0x290>
    8000489e:	ffffc097          	auipc	ra,0xffffc
    800048a2:	d64080e7          	jalr	-668(ra) # 80000602 <panic>
    return -1;
    800048a6:	597d                	li	s2,-1
    800048a8:	b765                	j	80004850 <fileread+0x60>
      return -1;
    800048aa:	597d                	li	s2,-1
    800048ac:	b755                	j	80004850 <fileread+0x60>
    800048ae:	597d                	li	s2,-1
    800048b0:	b745                	j	80004850 <fileread+0x60>

00000000800048b2 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800048b2:	00954783          	lbu	a5,9(a0)
    800048b6:	12078e63          	beqz	a5,800049f2 <filewrite+0x140>
{
    800048ba:	715d                	addi	sp,sp,-80
    800048bc:	e486                	sd	ra,72(sp)
    800048be:	e0a2                	sd	s0,64(sp)
    800048c0:	fc26                	sd	s1,56(sp)
    800048c2:	f84a                	sd	s2,48(sp)
    800048c4:	f44e                	sd	s3,40(sp)
    800048c6:	f052                	sd	s4,32(sp)
    800048c8:	ec56                	sd	s5,24(sp)
    800048ca:	e85a                	sd	s6,16(sp)
    800048cc:	e45e                	sd	s7,8(sp)
    800048ce:	e062                	sd	s8,0(sp)
    800048d0:	0880                	addi	s0,sp,80
    800048d2:	8ab2                	mv	s5,a2
    800048d4:	8b2e                	mv	s6,a1
    800048d6:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    800048d8:	411c                	lw	a5,0(a0)
    800048da:	4705                	li	a4,1
    800048dc:	02e78263          	beq	a5,a4,80004900 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048e0:	470d                	li	a4,3
    800048e2:	02e78563          	beq	a5,a4,8000490c <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800048e6:	4709                	li	a4,2
    800048e8:	0ee79d63          	bne	a5,a4,800049e2 <filewrite+0x130>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800048ec:	0ec05763          	blez	a2,800049da <filewrite+0x128>
    int i = 0;
    800048f0:	4901                	li	s2,0
    800048f2:	6b85                	lui	s7,0x1
    800048f4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800048f8:	6c05                	lui	s8,0x1
    800048fa:	c00c0c1b          	addiw	s8,s8,-1024
    800048fe:	a061                	j	80004986 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    80004900:	6908                	ld	a0,16(a0)
    80004902:	00000097          	auipc	ra,0x0
    80004906:	246080e7          	jalr	582(ra) # 80004b48 <pipewrite>
    8000490a:	a065                	j	800049b2 <filewrite+0x100>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000490c:	02451783          	lh	a5,36(a0)
    80004910:	03079693          	slli	a3,a5,0x30
    80004914:	92c1                	srli	a3,a3,0x30
    80004916:	4725                	li	a4,9
    80004918:	0cd76f63          	bltu	a4,a3,800049f6 <filewrite+0x144>
    8000491c:	0792                	slli	a5,a5,0x4
    8000491e:	0001d717          	auipc	a4,0x1d
    80004922:	69270713          	addi	a4,a4,1682 # 80021fb0 <devsw>
    80004926:	97ba                	add	a5,a5,a4
    80004928:	679c                	ld	a5,8(a5)
    8000492a:	cbe1                	beqz	a5,800049fa <filewrite+0x148>
    ret = devsw[f->major].write(1, addr, n);
    8000492c:	4505                	li	a0,1
    8000492e:	9782                	jalr	a5
    80004930:	a049                	j	800049b2 <filewrite+0x100>
    80004932:	00098a1b          	sext.w	s4,s3
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004936:	00000097          	auipc	ra,0x0
    8000493a:	87e080e7          	jalr	-1922(ra) # 800041b4 <begin_op>
      ilock(f->ip);
    8000493e:	6c88                	ld	a0,24(s1)
    80004940:	fffff097          	auipc	ra,0xfffff
    80004944:	eac080e7          	jalr	-340(ra) # 800037ec <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004948:	8752                	mv	a4,s4
    8000494a:	5094                	lw	a3,32(s1)
    8000494c:	01690633          	add	a2,s2,s6
    80004950:	4585                	li	a1,1
    80004952:	6c88                	ld	a0,24(s1)
    80004954:	fffff097          	auipc	ra,0xfffff
    80004958:	244080e7          	jalr	580(ra) # 80003b98 <writei>
    8000495c:	89aa                	mv	s3,a0
    8000495e:	02a05c63          	blez	a0,80004996 <filewrite+0xe4>
        f->off += r;
    80004962:	509c                	lw	a5,32(s1)
    80004964:	9fa9                	addw	a5,a5,a0
    80004966:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004968:	6c88                	ld	a0,24(s1)
    8000496a:	fffff097          	auipc	ra,0xfffff
    8000496e:	f46080e7          	jalr	-186(ra) # 800038b0 <iunlock>
      end_op();
    80004972:	00000097          	auipc	ra,0x0
    80004976:	8c2080e7          	jalr	-1854(ra) # 80004234 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    8000497a:	05499863          	bne	s3,s4,800049ca <filewrite+0x118>
        panic("short filewrite");
      i += r;
    8000497e:	012a093b          	addw	s2,s4,s2
    while(i < n){
    80004982:	03595563          	ble	s5,s2,800049ac <filewrite+0xfa>
      int n1 = n - i;
    80004986:	412a87bb          	subw	a5,s5,s2
      if(n1 > max)
    8000498a:	89be                	mv	s3,a5
    8000498c:	2781                	sext.w	a5,a5
    8000498e:	fafbd2e3          	ble	a5,s7,80004932 <filewrite+0x80>
    80004992:	89e2                	mv	s3,s8
    80004994:	bf79                	j	80004932 <filewrite+0x80>
      iunlock(f->ip);
    80004996:	6c88                	ld	a0,24(s1)
    80004998:	fffff097          	auipc	ra,0xfffff
    8000499c:	f18080e7          	jalr	-232(ra) # 800038b0 <iunlock>
      end_op();
    800049a0:	00000097          	auipc	ra,0x0
    800049a4:	894080e7          	jalr	-1900(ra) # 80004234 <end_op>
      if(r < 0)
    800049a8:	fc09d9e3          	bgez	s3,8000497a <filewrite+0xc8>
    }
    ret = (i == n ? n : -1);
    800049ac:	8556                	mv	a0,s5
    800049ae:	032a9863          	bne	s5,s2,800049de <filewrite+0x12c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800049b2:	60a6                	ld	ra,72(sp)
    800049b4:	6406                	ld	s0,64(sp)
    800049b6:	74e2                	ld	s1,56(sp)
    800049b8:	7942                	ld	s2,48(sp)
    800049ba:	79a2                	ld	s3,40(sp)
    800049bc:	7a02                	ld	s4,32(sp)
    800049be:	6ae2                	ld	s5,24(sp)
    800049c0:	6b42                	ld	s6,16(sp)
    800049c2:	6ba2                	ld	s7,8(sp)
    800049c4:	6c02                	ld	s8,0(sp)
    800049c6:	6161                	addi	sp,sp,80
    800049c8:	8082                	ret
        panic("short filewrite");
    800049ca:	00004517          	auipc	a0,0x4
    800049ce:	cee50513          	addi	a0,a0,-786 # 800086b8 <syscalls+0x2a0>
    800049d2:	ffffc097          	auipc	ra,0xffffc
    800049d6:	c30080e7          	jalr	-976(ra) # 80000602 <panic>
    int i = 0;
    800049da:	4901                	li	s2,0
    800049dc:	bfc1                	j	800049ac <filewrite+0xfa>
    ret = (i == n ? n : -1);
    800049de:	557d                	li	a0,-1
    800049e0:	bfc9                	j	800049b2 <filewrite+0x100>
    panic("filewrite");
    800049e2:	00004517          	auipc	a0,0x4
    800049e6:	ce650513          	addi	a0,a0,-794 # 800086c8 <syscalls+0x2b0>
    800049ea:	ffffc097          	auipc	ra,0xffffc
    800049ee:	c18080e7          	jalr	-1000(ra) # 80000602 <panic>
    return -1;
    800049f2:	557d                	li	a0,-1
}
    800049f4:	8082                	ret
      return -1;
    800049f6:	557d                	li	a0,-1
    800049f8:	bf6d                	j	800049b2 <filewrite+0x100>
    800049fa:	557d                	li	a0,-1
    800049fc:	bf5d                	j	800049b2 <filewrite+0x100>

00000000800049fe <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800049fe:	7179                	addi	sp,sp,-48
    80004a00:	f406                	sd	ra,40(sp)
    80004a02:	f022                	sd	s0,32(sp)
    80004a04:	ec26                	sd	s1,24(sp)
    80004a06:	e84a                	sd	s2,16(sp)
    80004a08:	e44e                	sd	s3,8(sp)
    80004a0a:	e052                	sd	s4,0(sp)
    80004a0c:	1800                	addi	s0,sp,48
    80004a0e:	84aa                	mv	s1,a0
    80004a10:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a12:	0005b023          	sd	zero,0(a1)
    80004a16:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a1a:	00000097          	auipc	ra,0x0
    80004a1e:	bcc080e7          	jalr	-1076(ra) # 800045e6 <filealloc>
    80004a22:	e088                	sd	a0,0(s1)
    80004a24:	c551                	beqz	a0,80004ab0 <pipealloc+0xb2>
    80004a26:	00000097          	auipc	ra,0x0
    80004a2a:	bc0080e7          	jalr	-1088(ra) # 800045e6 <filealloc>
    80004a2e:	00a93023          	sd	a0,0(s2)
    80004a32:	c92d                	beqz	a0,80004aa4 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a34:	ffffc097          	auipc	ra,0xffffc
    80004a38:	1a2080e7          	jalr	418(ra) # 80000bd6 <kalloc>
    80004a3c:	89aa                	mv	s3,a0
    80004a3e:	c125                	beqz	a0,80004a9e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004a40:	4a05                	li	s4,1
    80004a42:	23452023          	sw	s4,544(a0)
  pi->writeopen = 1;
    80004a46:	23452223          	sw	s4,548(a0)
  pi->nwrite = 0;
    80004a4a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004a4e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004a52:	00004597          	auipc	a1,0x4
    80004a56:	c8658593          	addi	a1,a1,-890 # 800086d8 <syscalls+0x2c0>
    80004a5a:	ffffc097          	auipc	ra,0xffffc
    80004a5e:	1dc080e7          	jalr	476(ra) # 80000c36 <initlock>
  (*f0)->type = FD_PIPE;
    80004a62:	609c                	ld	a5,0(s1)
    80004a64:	0147a023          	sw	s4,0(a5)
  (*f0)->readable = 1;
    80004a68:	609c                	ld	a5,0(s1)
    80004a6a:	01478423          	sb	s4,8(a5)
  (*f0)->writable = 0;
    80004a6e:	609c                	ld	a5,0(s1)
    80004a70:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a74:	609c                	ld	a5,0(s1)
    80004a76:	0137b823          	sd	s3,16(a5)
  (*f1)->type = FD_PIPE;
    80004a7a:	00093783          	ld	a5,0(s2)
    80004a7e:	0147a023          	sw	s4,0(a5)
  (*f1)->readable = 0;
    80004a82:	00093783          	ld	a5,0(s2)
    80004a86:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a8a:	00093783          	ld	a5,0(s2)
    80004a8e:	014784a3          	sb	s4,9(a5)
  (*f1)->pipe = pi;
    80004a92:	00093783          	ld	a5,0(s2)
    80004a96:	0137b823          	sd	s3,16(a5)
  return 0;
    80004a9a:	4501                	li	a0,0
    80004a9c:	a025                	j	80004ac4 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a9e:	6088                	ld	a0,0(s1)
    80004aa0:	e501                	bnez	a0,80004aa8 <pipealloc+0xaa>
    80004aa2:	a039                	j	80004ab0 <pipealloc+0xb2>
    80004aa4:	6088                	ld	a0,0(s1)
    80004aa6:	c51d                	beqz	a0,80004ad4 <pipealloc+0xd6>
    fileclose(*f0);
    80004aa8:	00000097          	auipc	ra,0x0
    80004aac:	c0e080e7          	jalr	-1010(ra) # 800046b6 <fileclose>
  if(*f1)
    80004ab0:	00093783          	ld	a5,0(s2)
    fileclose(*f1);
  return -1;
    80004ab4:	557d                	li	a0,-1
  if(*f1)
    80004ab6:	c799                	beqz	a5,80004ac4 <pipealloc+0xc6>
    fileclose(*f1);
    80004ab8:	853e                	mv	a0,a5
    80004aba:	00000097          	auipc	ra,0x0
    80004abe:	bfc080e7          	jalr	-1028(ra) # 800046b6 <fileclose>
  return -1;
    80004ac2:	557d                	li	a0,-1
}
    80004ac4:	70a2                	ld	ra,40(sp)
    80004ac6:	7402                	ld	s0,32(sp)
    80004ac8:	64e2                	ld	s1,24(sp)
    80004aca:	6942                	ld	s2,16(sp)
    80004acc:	69a2                	ld	s3,8(sp)
    80004ace:	6a02                	ld	s4,0(sp)
    80004ad0:	6145                	addi	sp,sp,48
    80004ad2:	8082                	ret
  return -1;
    80004ad4:	557d                	li	a0,-1
    80004ad6:	b7fd                	j	80004ac4 <pipealloc+0xc6>

0000000080004ad8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004ad8:	1101                	addi	sp,sp,-32
    80004ada:	ec06                	sd	ra,24(sp)
    80004adc:	e822                	sd	s0,16(sp)
    80004ade:	e426                	sd	s1,8(sp)
    80004ae0:	e04a                	sd	s2,0(sp)
    80004ae2:	1000                	addi	s0,sp,32
    80004ae4:	84aa                	mv	s1,a0
    80004ae6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004ae8:	ffffc097          	auipc	ra,0xffffc
    80004aec:	1de080e7          	jalr	478(ra) # 80000cc6 <acquire>
  if(writable){
    80004af0:	02090d63          	beqz	s2,80004b2a <pipeclose+0x52>
    pi->writeopen = 0;
    80004af4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004af8:	21848513          	addi	a0,s1,536
    80004afc:	ffffe097          	auipc	ra,0xffffe
    80004b00:	99e080e7          	jalr	-1634(ra) # 8000249a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b04:	2204b783          	ld	a5,544(s1)
    80004b08:	eb95                	bnez	a5,80004b3c <pipeclose+0x64>
    release(&pi->lock);
    80004b0a:	8526                	mv	a0,s1
    80004b0c:	ffffc097          	auipc	ra,0xffffc
    80004b10:	26e080e7          	jalr	622(ra) # 80000d7a <release>
    kfree((char*)pi);
    80004b14:	8526                	mv	a0,s1
    80004b16:	ffffc097          	auipc	ra,0xffffc
    80004b1a:	fc0080e7          	jalr	-64(ra) # 80000ad6 <kfree>
  } else
    release(&pi->lock);
}
    80004b1e:	60e2                	ld	ra,24(sp)
    80004b20:	6442                	ld	s0,16(sp)
    80004b22:	64a2                	ld	s1,8(sp)
    80004b24:	6902                	ld	s2,0(sp)
    80004b26:	6105                	addi	sp,sp,32
    80004b28:	8082                	ret
    pi->readopen = 0;
    80004b2a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b2e:	21c48513          	addi	a0,s1,540
    80004b32:	ffffe097          	auipc	ra,0xffffe
    80004b36:	968080e7          	jalr	-1688(ra) # 8000249a <wakeup>
    80004b3a:	b7e9                	j	80004b04 <pipeclose+0x2c>
    release(&pi->lock);
    80004b3c:	8526                	mv	a0,s1
    80004b3e:	ffffc097          	auipc	ra,0xffffc
    80004b42:	23c080e7          	jalr	572(ra) # 80000d7a <release>
}
    80004b46:	bfe1                	j	80004b1e <pipeclose+0x46>

0000000080004b48 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b48:	7119                	addi	sp,sp,-128
    80004b4a:	fc86                	sd	ra,120(sp)
    80004b4c:	f8a2                	sd	s0,112(sp)
    80004b4e:	f4a6                	sd	s1,104(sp)
    80004b50:	f0ca                	sd	s2,96(sp)
    80004b52:	ecce                	sd	s3,88(sp)
    80004b54:	e8d2                	sd	s4,80(sp)
    80004b56:	e4d6                	sd	s5,72(sp)
    80004b58:	e0da                	sd	s6,64(sp)
    80004b5a:	fc5e                	sd	s7,56(sp)
    80004b5c:	f862                	sd	s8,48(sp)
    80004b5e:	f466                	sd	s9,40(sp)
    80004b60:	f06a                	sd	s10,32(sp)
    80004b62:	ec6e                	sd	s11,24(sp)
    80004b64:	0100                	addi	s0,sp,128
    80004b66:	84aa                	mv	s1,a0
    80004b68:	8d2e                	mv	s10,a1
    80004b6a:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004b6c:	ffffd097          	auipc	ra,0xffffd
    80004b70:	f68080e7          	jalr	-152(ra) # 80001ad4 <myproc>
    80004b74:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004b76:	8526                	mv	a0,s1
    80004b78:	ffffc097          	auipc	ra,0xffffc
    80004b7c:	14e080e7          	jalr	334(ra) # 80000cc6 <acquire>
  for(i = 0; i < n; i++){
    80004b80:	0d605f63          	blez	s6,80004c5e <pipewrite+0x116>
    80004b84:	89a6                	mv	s3,s1
    80004b86:	3b7d                	addiw	s6,s6,-1
    80004b88:	1b02                	slli	s6,s6,0x20
    80004b8a:	020b5b13          	srli	s6,s6,0x20
    80004b8e:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004b90:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004b94:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b98:	5dfd                	li	s11,-1
    80004b9a:	000b8c9b          	sext.w	s9,s7
    80004b9e:	8c66                	mv	s8,s9
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004ba0:	2184a783          	lw	a5,536(s1)
    80004ba4:	21c4a703          	lw	a4,540(s1)
    80004ba8:	2007879b          	addiw	a5,a5,512
    80004bac:	06f71763          	bne	a4,a5,80004c1a <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004bb0:	2204a783          	lw	a5,544(s1)
    80004bb4:	cf8d                	beqz	a5,80004bee <pipewrite+0xa6>
    80004bb6:	03092783          	lw	a5,48(s2)
    80004bba:	eb95                	bnez	a5,80004bee <pipewrite+0xa6>
      wakeup(&pi->nread);
    80004bbc:	8556                	mv	a0,s5
    80004bbe:	ffffe097          	auipc	ra,0xffffe
    80004bc2:	8dc080e7          	jalr	-1828(ra) # 8000249a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004bc6:	85ce                	mv	a1,s3
    80004bc8:	8552                	mv	a0,s4
    80004bca:	ffffd097          	auipc	ra,0xffffd
    80004bce:	74a080e7          	jalr	1866(ra) # 80002314 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004bd2:	2184a783          	lw	a5,536(s1)
    80004bd6:	21c4a703          	lw	a4,540(s1)
    80004bda:	2007879b          	addiw	a5,a5,512
    80004bde:	02f71e63          	bne	a4,a5,80004c1a <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004be2:	2204a783          	lw	a5,544(s1)
    80004be6:	c781                	beqz	a5,80004bee <pipewrite+0xa6>
    80004be8:	03092783          	lw	a5,48(s2)
    80004bec:	dbe1                	beqz	a5,80004bbc <pipewrite+0x74>
        release(&pi->lock);
    80004bee:	8526                	mv	a0,s1
    80004bf0:	ffffc097          	auipc	ra,0xffffc
    80004bf4:	18a080e7          	jalr	394(ra) # 80000d7a <release>
        return -1;
    80004bf8:	5c7d                	li	s8,-1
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004bfa:	8562                	mv	a0,s8
    80004bfc:	70e6                	ld	ra,120(sp)
    80004bfe:	7446                	ld	s0,112(sp)
    80004c00:	74a6                	ld	s1,104(sp)
    80004c02:	7906                	ld	s2,96(sp)
    80004c04:	69e6                	ld	s3,88(sp)
    80004c06:	6a46                	ld	s4,80(sp)
    80004c08:	6aa6                	ld	s5,72(sp)
    80004c0a:	6b06                	ld	s6,64(sp)
    80004c0c:	7be2                	ld	s7,56(sp)
    80004c0e:	7c42                	ld	s8,48(sp)
    80004c10:	7ca2                	ld	s9,40(sp)
    80004c12:	7d02                	ld	s10,32(sp)
    80004c14:	6de2                	ld	s11,24(sp)
    80004c16:	6109                	addi	sp,sp,128
    80004c18:	8082                	ret
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c1a:	4685                	li	a3,1
    80004c1c:	01ab8633          	add	a2,s7,s10
    80004c20:	f8f40593          	addi	a1,s0,-113
    80004c24:	05093503          	ld	a0,80(s2)
    80004c28:	ffffd097          	auipc	ra,0xffffd
    80004c2c:	c14080e7          	jalr	-1004(ra) # 8000183c <copyin>
    80004c30:	03b50863          	beq	a0,s11,80004c60 <pipewrite+0x118>
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c34:	21c4a783          	lw	a5,540(s1)
    80004c38:	0017871b          	addiw	a4,a5,1
    80004c3c:	20e4ae23          	sw	a4,540(s1)
    80004c40:	1ff7f793          	andi	a5,a5,511
    80004c44:	97a6                	add	a5,a5,s1
    80004c46:	f8f44703          	lbu	a4,-113(s0)
    80004c4a:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004c4e:	001c8c1b          	addiw	s8,s9,1
    80004c52:	001b8793          	addi	a5,s7,1
    80004c56:	016b8563          	beq	s7,s6,80004c60 <pipewrite+0x118>
    80004c5a:	8bbe                	mv	s7,a5
    80004c5c:	bf3d                	j	80004b9a <pipewrite+0x52>
    80004c5e:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004c60:	21848513          	addi	a0,s1,536
    80004c64:	ffffe097          	auipc	ra,0xffffe
    80004c68:	836080e7          	jalr	-1994(ra) # 8000249a <wakeup>
  release(&pi->lock);
    80004c6c:	8526                	mv	a0,s1
    80004c6e:	ffffc097          	auipc	ra,0xffffc
    80004c72:	10c080e7          	jalr	268(ra) # 80000d7a <release>
  return i;
    80004c76:	b751                	j	80004bfa <pipewrite+0xb2>

0000000080004c78 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c78:	715d                	addi	sp,sp,-80
    80004c7a:	e486                	sd	ra,72(sp)
    80004c7c:	e0a2                	sd	s0,64(sp)
    80004c7e:	fc26                	sd	s1,56(sp)
    80004c80:	f84a                	sd	s2,48(sp)
    80004c82:	f44e                	sd	s3,40(sp)
    80004c84:	f052                	sd	s4,32(sp)
    80004c86:	ec56                	sd	s5,24(sp)
    80004c88:	e85a                	sd	s6,16(sp)
    80004c8a:	0880                	addi	s0,sp,80
    80004c8c:	84aa                	mv	s1,a0
    80004c8e:	89ae                	mv	s3,a1
    80004c90:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c92:	ffffd097          	auipc	ra,0xffffd
    80004c96:	e42080e7          	jalr	-446(ra) # 80001ad4 <myproc>
    80004c9a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004c9c:	8526                	mv	a0,s1
    80004c9e:	ffffc097          	auipc	ra,0xffffc
    80004ca2:	028080e7          	jalr	40(ra) # 80000cc6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ca6:	2184a703          	lw	a4,536(s1)
    80004caa:	21c4a783          	lw	a5,540(s1)
    80004cae:	06f71b63          	bne	a4,a5,80004d24 <piperead+0xac>
    80004cb2:	8926                	mv	s2,s1
    80004cb4:	2244a783          	lw	a5,548(s1)
    80004cb8:	cf9d                	beqz	a5,80004cf6 <piperead+0x7e>
    if(pr->killed){
    80004cba:	030a2783          	lw	a5,48(s4)
    80004cbe:	e78d                	bnez	a5,80004ce8 <piperead+0x70>
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cc0:	21848b13          	addi	s6,s1,536
    80004cc4:	85ca                	mv	a1,s2
    80004cc6:	855a                	mv	a0,s6
    80004cc8:	ffffd097          	auipc	ra,0xffffd
    80004ccc:	64c080e7          	jalr	1612(ra) # 80002314 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cd0:	2184a703          	lw	a4,536(s1)
    80004cd4:	21c4a783          	lw	a5,540(s1)
    80004cd8:	04f71663          	bne	a4,a5,80004d24 <piperead+0xac>
    80004cdc:	2244a783          	lw	a5,548(s1)
    80004ce0:	cb99                	beqz	a5,80004cf6 <piperead+0x7e>
    if(pr->killed){
    80004ce2:	030a2783          	lw	a5,48(s4)
    80004ce6:	dff9                	beqz	a5,80004cc4 <piperead+0x4c>
      release(&pi->lock);
    80004ce8:	8526                	mv	a0,s1
    80004cea:	ffffc097          	auipc	ra,0xffffc
    80004cee:	090080e7          	jalr	144(ra) # 80000d7a <release>
      return -1;
    80004cf2:	597d                	li	s2,-1
    80004cf4:	a829                	j	80004d0e <piperead+0x96>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(pi->nread == pi->nwrite)
    80004cf6:	4901                	li	s2,0
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004cf8:	21c48513          	addi	a0,s1,540
    80004cfc:	ffffd097          	auipc	ra,0xffffd
    80004d00:	79e080e7          	jalr	1950(ra) # 8000249a <wakeup>
  release(&pi->lock);
    80004d04:	8526                	mv	a0,s1
    80004d06:	ffffc097          	auipc	ra,0xffffc
    80004d0a:	074080e7          	jalr	116(ra) # 80000d7a <release>
  return i;
}
    80004d0e:	854a                	mv	a0,s2
    80004d10:	60a6                	ld	ra,72(sp)
    80004d12:	6406                	ld	s0,64(sp)
    80004d14:	74e2                	ld	s1,56(sp)
    80004d16:	7942                	ld	s2,48(sp)
    80004d18:	79a2                	ld	s3,40(sp)
    80004d1a:	7a02                	ld	s4,32(sp)
    80004d1c:	6ae2                	ld	s5,24(sp)
    80004d1e:	6b42                	ld	s6,16(sp)
    80004d20:	6161                	addi	sp,sp,80
    80004d22:	8082                	ret
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d24:	4901                	li	s2,0
    80004d26:	fd5059e3          	blez	s5,80004cf8 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004d2a:	2184a783          	lw	a5,536(s1)
    80004d2e:	4901                	li	s2,0
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d30:	5b7d                	li	s6,-1
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d32:	0017871b          	addiw	a4,a5,1
    80004d36:	20e4ac23          	sw	a4,536(s1)
    80004d3a:	1ff7f793          	andi	a5,a5,511
    80004d3e:	97a6                	add	a5,a5,s1
    80004d40:	0187c783          	lbu	a5,24(a5)
    80004d44:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d48:	4685                	li	a3,1
    80004d4a:	fbf40613          	addi	a2,s0,-65
    80004d4e:	85ce                	mv	a1,s3
    80004d50:	050a3503          	ld	a0,80(s4)
    80004d54:	ffffd097          	auipc	ra,0xffffd
    80004d58:	a5c080e7          	jalr	-1444(ra) # 800017b0 <copyout>
    80004d5c:	f9650ee3          	beq	a0,s6,80004cf8 <piperead+0x80>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d60:	2905                	addiw	s2,s2,1
    80004d62:	f92a8be3          	beq	s5,s2,80004cf8 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004d66:	2184a783          	lw	a5,536(s1)
    80004d6a:	0985                	addi	s3,s3,1
    80004d6c:	21c4a703          	lw	a4,540(s1)
    80004d70:	fcf711e3          	bne	a4,a5,80004d32 <piperead+0xba>
    80004d74:	b751                	j	80004cf8 <piperead+0x80>

0000000080004d76 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004d76:	de010113          	addi	sp,sp,-544
    80004d7a:	20113c23          	sd	ra,536(sp)
    80004d7e:	20813823          	sd	s0,528(sp)
    80004d82:	20913423          	sd	s1,520(sp)
    80004d86:	21213023          	sd	s2,512(sp)
    80004d8a:	ffce                	sd	s3,504(sp)
    80004d8c:	fbd2                	sd	s4,496(sp)
    80004d8e:	f7d6                	sd	s5,488(sp)
    80004d90:	f3da                	sd	s6,480(sp)
    80004d92:	efde                	sd	s7,472(sp)
    80004d94:	ebe2                	sd	s8,464(sp)
    80004d96:	e7e6                	sd	s9,456(sp)
    80004d98:	e3ea                	sd	s10,448(sp)
    80004d9a:	ff6e                	sd	s11,440(sp)
    80004d9c:	1400                	addi	s0,sp,544
    80004d9e:	892a                	mv	s2,a0
    80004da0:	dea43823          	sd	a0,-528(s0)
    80004da4:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004da8:	ffffd097          	auipc	ra,0xffffd
    80004dac:	d2c080e7          	jalr	-724(ra) # 80001ad4 <myproc>
    80004db0:	84aa                	mv	s1,a0

  begin_op();
    80004db2:	fffff097          	auipc	ra,0xfffff
    80004db6:	402080e7          	jalr	1026(ra) # 800041b4 <begin_op>

  if((ip = namei(path)) == 0){
    80004dba:	854a                	mv	a0,s2
    80004dbc:	fffff097          	auipc	ra,0xfffff
    80004dc0:	1ea080e7          	jalr	490(ra) # 80003fa6 <namei>
    80004dc4:	c93d                	beqz	a0,80004e3a <exec+0xc4>
    80004dc6:	892a                	mv	s2,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004dc8:	fffff097          	auipc	ra,0xfffff
    80004dcc:	a24080e7          	jalr	-1500(ra) # 800037ec <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004dd0:	04000713          	li	a4,64
    80004dd4:	4681                	li	a3,0
    80004dd6:	e4840613          	addi	a2,s0,-440
    80004dda:	4581                	li	a1,0
    80004ddc:	854a                	mv	a0,s2
    80004dde:	fffff097          	auipc	ra,0xfffff
    80004de2:	cc4080e7          	jalr	-828(ra) # 80003aa2 <readi>
    80004de6:	04000793          	li	a5,64
    80004dea:	00f51a63          	bne	a0,a5,80004dfe <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004dee:	e4842703          	lw	a4,-440(s0)
    80004df2:	464c47b7          	lui	a5,0x464c4
    80004df6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004dfa:	04f70663          	beq	a4,a5,80004e46 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004dfe:	854a                	mv	a0,s2
    80004e00:	fffff097          	auipc	ra,0xfffff
    80004e04:	c50080e7          	jalr	-944(ra) # 80003a50 <iunlockput>
    end_op();
    80004e08:	fffff097          	auipc	ra,0xfffff
    80004e0c:	42c080e7          	jalr	1068(ra) # 80004234 <end_op>
  }
  return -1;
    80004e10:	557d                	li	a0,-1
}
    80004e12:	21813083          	ld	ra,536(sp)
    80004e16:	21013403          	ld	s0,528(sp)
    80004e1a:	20813483          	ld	s1,520(sp)
    80004e1e:	20013903          	ld	s2,512(sp)
    80004e22:	79fe                	ld	s3,504(sp)
    80004e24:	7a5e                	ld	s4,496(sp)
    80004e26:	7abe                	ld	s5,488(sp)
    80004e28:	7b1e                	ld	s6,480(sp)
    80004e2a:	6bfe                	ld	s7,472(sp)
    80004e2c:	6c5e                	ld	s8,464(sp)
    80004e2e:	6cbe                	ld	s9,456(sp)
    80004e30:	6d1e                	ld	s10,448(sp)
    80004e32:	7dfa                	ld	s11,440(sp)
    80004e34:	22010113          	addi	sp,sp,544
    80004e38:	8082                	ret
    end_op();
    80004e3a:	fffff097          	auipc	ra,0xfffff
    80004e3e:	3fa080e7          	jalr	1018(ra) # 80004234 <end_op>
    return -1;
    80004e42:	557d                	li	a0,-1
    80004e44:	b7f9                	j	80004e12 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e46:	8526                	mv	a0,s1
    80004e48:	ffffd097          	auipc	ra,0xffffd
    80004e4c:	d52080e7          	jalr	-686(ra) # 80001b9a <proc_pagetable>
    80004e50:	e0a43423          	sd	a0,-504(s0)
    80004e54:	d54d                	beqz	a0,80004dfe <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e56:	e6842983          	lw	s3,-408(s0)
    80004e5a:	e8045783          	lhu	a5,-384(s0)
    80004e5e:	c7ad                	beqz	a5,80004ec8 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004e60:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e62:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004e64:	6c05                	lui	s8,0x1
    80004e66:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    80004e6a:	def43423          	sd	a5,-536(s0)
    80004e6e:	7cfd                	lui	s9,0xfffff
    80004e70:	ac1d                	j	800050a6 <exec+0x330>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004e72:	00004517          	auipc	a0,0x4
    80004e76:	86e50513          	addi	a0,a0,-1938 # 800086e0 <syscalls+0x2c8>
    80004e7a:	ffffb097          	auipc	ra,0xffffb
    80004e7e:	788080e7          	jalr	1928(ra) # 80000602 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004e82:	8756                	mv	a4,s5
    80004e84:	009d86bb          	addw	a3,s11,s1
    80004e88:	4581                	li	a1,0
    80004e8a:	854a                	mv	a0,s2
    80004e8c:	fffff097          	auipc	ra,0xfffff
    80004e90:	c16080e7          	jalr	-1002(ra) # 80003aa2 <readi>
    80004e94:	2501                	sext.w	a0,a0
    80004e96:	1aaa9e63          	bne	s5,a0,80005052 <exec+0x2dc>
  for(i = 0; i < sz; i += PGSIZE){
    80004e9a:	6785                	lui	a5,0x1
    80004e9c:	9cbd                	addw	s1,s1,a5
    80004e9e:	014c8a3b          	addw	s4,s9,s4
    80004ea2:	1f74f963          	bleu	s7,s1,80005094 <exec+0x31e>
    pa = walkaddr(pagetable, va + i);
    80004ea6:	02049593          	slli	a1,s1,0x20
    80004eaa:	9181                	srli	a1,a1,0x20
    80004eac:	95ea                	add	a1,a1,s10
    80004eae:	e0843503          	ld	a0,-504(s0)
    80004eb2:	ffffc097          	auipc	ra,0xffffc
    80004eb6:	2c6080e7          	jalr	710(ra) # 80001178 <walkaddr>
    80004eba:	862a                	mv	a2,a0
    if(pa == 0)
    80004ebc:	d95d                	beqz	a0,80004e72 <exec+0xfc>
      n = PGSIZE;
    80004ebe:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    80004ec0:	fd8a71e3          	bleu	s8,s4,80004e82 <exec+0x10c>
      n = sz - i;
    80004ec4:	8ad2                	mv	s5,s4
    80004ec6:	bf75                	j	80004e82 <exec+0x10c>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004ec8:	4481                	li	s1,0
  iunlockput(ip);
    80004eca:	854a                	mv	a0,s2
    80004ecc:	fffff097          	auipc	ra,0xfffff
    80004ed0:	b84080e7          	jalr	-1148(ra) # 80003a50 <iunlockput>
  end_op();
    80004ed4:	fffff097          	auipc	ra,0xfffff
    80004ed8:	360080e7          	jalr	864(ra) # 80004234 <end_op>
  p = myproc();
    80004edc:	ffffd097          	auipc	ra,0xffffd
    80004ee0:	bf8080e7          	jalr	-1032(ra) # 80001ad4 <myproc>
    80004ee4:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004ee6:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004eea:	6785                	lui	a5,0x1
    80004eec:	17fd                	addi	a5,a5,-1
    80004eee:	94be                	add	s1,s1,a5
    80004ef0:	77fd                	lui	a5,0xfffff
    80004ef2:	8fe5                	and	a5,a5,s1
    80004ef4:	e0f43023          	sd	a5,-512(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004ef8:	6609                	lui	a2,0x2
    80004efa:	963e                	add	a2,a2,a5
    80004efc:	85be                	mv	a1,a5
    80004efe:	e0843483          	ld	s1,-504(s0)
    80004f02:	8526                	mv	a0,s1
    80004f04:	ffffc097          	auipc	ra,0xffffc
    80004f08:	65c080e7          	jalr	1628(ra) # 80001560 <uvmalloc>
    80004f0c:	8b2a                	mv	s6,a0
  ip = 0;
    80004f0e:	4901                	li	s2,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f10:	14050163          	beqz	a0,80005052 <exec+0x2dc>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f14:	75f9                	lui	a1,0xffffe
    80004f16:	95aa                	add	a1,a1,a0
    80004f18:	8526                	mv	a0,s1
    80004f1a:	ffffd097          	auipc	ra,0xffffd
    80004f1e:	864080e7          	jalr	-1948(ra) # 8000177e <uvmclear>
  stackbase = sp - PGSIZE;
    80004f22:	7bfd                	lui	s7,0xfffff
    80004f24:	9bda                	add	s7,s7,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f26:	df843783          	ld	a5,-520(s0)
    80004f2a:	6388                	ld	a0,0(a5)
    80004f2c:	c925                	beqz	a0,80004f9c <exec+0x226>
    80004f2e:	e8840993          	addi	s3,s0,-376
    80004f32:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80004f36:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f38:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004f3a:	ffffc097          	auipc	ra,0xffffc
    80004f3e:	032080e7          	jalr	50(ra) # 80000f6c <strlen>
    80004f42:	2505                	addiw	a0,a0,1
    80004f44:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f48:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004f4c:	13796863          	bltu	s2,s7,8000507c <exec+0x306>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f50:	df843c83          	ld	s9,-520(s0)
    80004f54:	000cba03          	ld	s4,0(s9) # fffffffffffff000 <end+0xffffffff7ffd8000>
    80004f58:	8552                	mv	a0,s4
    80004f5a:	ffffc097          	auipc	ra,0xffffc
    80004f5e:	012080e7          	jalr	18(ra) # 80000f6c <strlen>
    80004f62:	0015069b          	addiw	a3,a0,1
    80004f66:	8652                	mv	a2,s4
    80004f68:	85ca                	mv	a1,s2
    80004f6a:	e0843503          	ld	a0,-504(s0)
    80004f6e:	ffffd097          	auipc	ra,0xffffd
    80004f72:	842080e7          	jalr	-1982(ra) # 800017b0 <copyout>
    80004f76:	10054763          	bltz	a0,80005084 <exec+0x30e>
    ustack[argc] = sp;
    80004f7a:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004f7e:	0485                	addi	s1,s1,1
    80004f80:	008c8793          	addi	a5,s9,8
    80004f84:	def43c23          	sd	a5,-520(s0)
    80004f88:	008cb503          	ld	a0,8(s9)
    80004f8c:	c911                	beqz	a0,80004fa0 <exec+0x22a>
    if(argc >= MAXARG)
    80004f8e:	09a1                	addi	s3,s3,8
    80004f90:	fb8995e3          	bne	s3,s8,80004f3a <exec+0x1c4>
  sz = sz1;
    80004f94:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80004f98:	4901                	li	s2,0
    80004f9a:	a865                	j	80005052 <exec+0x2dc>
  sp = sz;
    80004f9c:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f9e:	4481                	li	s1,0
  ustack[argc] = 0;
    80004fa0:	00349793          	slli	a5,s1,0x3
    80004fa4:	f9040713          	addi	a4,s0,-112
    80004fa8:	97ba                	add	a5,a5,a4
    80004faa:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd7ef8>
  sp -= (argc+1) * sizeof(uint64);
    80004fae:	00148693          	addi	a3,s1,1
    80004fb2:	068e                	slli	a3,a3,0x3
    80004fb4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004fb8:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004fbc:	01797663          	bleu	s7,s2,80004fc8 <exec+0x252>
  sz = sz1;
    80004fc0:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80004fc4:	4901                	li	s2,0
    80004fc6:	a071                	j	80005052 <exec+0x2dc>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004fc8:	e8840613          	addi	a2,s0,-376
    80004fcc:	85ca                	mv	a1,s2
    80004fce:	e0843503          	ld	a0,-504(s0)
    80004fd2:	ffffc097          	auipc	ra,0xffffc
    80004fd6:	7de080e7          	jalr	2014(ra) # 800017b0 <copyout>
    80004fda:	0a054963          	bltz	a0,8000508c <exec+0x316>
  p->trapframe->a1 = sp;
    80004fde:	058ab783          	ld	a5,88(s5)
    80004fe2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004fe6:	df043783          	ld	a5,-528(s0)
    80004fea:	0007c703          	lbu	a4,0(a5)
    80004fee:	cf11                	beqz	a4,8000500a <exec+0x294>
    80004ff0:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004ff2:	02f00693          	li	a3,47
    80004ff6:	a029                	j	80005000 <exec+0x28a>
  for(last=s=path; *s; s++)
    80004ff8:	0785                	addi	a5,a5,1
    80004ffa:	fff7c703          	lbu	a4,-1(a5)
    80004ffe:	c711                	beqz	a4,8000500a <exec+0x294>
    if(*s == '/')
    80005000:	fed71ce3          	bne	a4,a3,80004ff8 <exec+0x282>
      last = s+1;
    80005004:	def43823          	sd	a5,-528(s0)
    80005008:	bfc5                	j	80004ff8 <exec+0x282>
  safestrcpy(p->name, last, sizeof(p->name));
    8000500a:	4641                	li	a2,16
    8000500c:	df043583          	ld	a1,-528(s0)
    80005010:	158a8513          	addi	a0,s5,344
    80005014:	ffffc097          	auipc	ra,0xffffc
    80005018:	f26080e7          	jalr	-218(ra) # 80000f3a <safestrcpy>
  oldpagetable = p->pagetable;
    8000501c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005020:	e0843783          	ld	a5,-504(s0)
    80005024:	04fab823          	sd	a5,80(s5)
  p->sz = sz;
    80005028:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000502c:	058ab783          	ld	a5,88(s5)
    80005030:	e6043703          	ld	a4,-416(s0)
    80005034:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005036:	058ab783          	ld	a5,88(s5)
    8000503a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000503e:	85ea                	mv	a1,s10
    80005040:	ffffd097          	auipc	ra,0xffffd
    80005044:	bf6080e7          	jalr	-1034(ra) # 80001c36 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005048:	0004851b          	sext.w	a0,s1
    8000504c:	b3d9                	j	80004e12 <exec+0x9c>
    8000504e:	e0943023          	sd	s1,-512(s0)
    proc_freepagetable(pagetable, sz);
    80005052:	e0043583          	ld	a1,-512(s0)
    80005056:	e0843503          	ld	a0,-504(s0)
    8000505a:	ffffd097          	auipc	ra,0xffffd
    8000505e:	bdc080e7          	jalr	-1060(ra) # 80001c36 <proc_freepagetable>
  if(ip){
    80005062:	d8091ee3          	bnez	s2,80004dfe <exec+0x88>
  return -1;
    80005066:	557d                	li	a0,-1
    80005068:	b36d                	j	80004e12 <exec+0x9c>
    8000506a:	e0943023          	sd	s1,-512(s0)
    8000506e:	b7d5                	j	80005052 <exec+0x2dc>
    80005070:	e0943023          	sd	s1,-512(s0)
    80005074:	bff9                	j	80005052 <exec+0x2dc>
    80005076:	e0943023          	sd	s1,-512(s0)
    8000507a:	bfe1                	j	80005052 <exec+0x2dc>
  sz = sz1;
    8000507c:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005080:	4901                	li	s2,0
    80005082:	bfc1                	j	80005052 <exec+0x2dc>
  sz = sz1;
    80005084:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005088:	4901                	li	s2,0
    8000508a:	b7e1                	j	80005052 <exec+0x2dc>
  sz = sz1;
    8000508c:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005090:	4901                	li	s2,0
    80005092:	b7c1                	j	80005052 <exec+0x2dc>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005094:	e0043483          	ld	s1,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005098:	2b05                	addiw	s6,s6,1
    8000509a:	0389899b          	addiw	s3,s3,56
    8000509e:	e8045783          	lhu	a5,-384(s0)
    800050a2:	e2fb54e3          	ble	a5,s6,80004eca <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800050a6:	2981                	sext.w	s3,s3
    800050a8:	03800713          	li	a4,56
    800050ac:	86ce                	mv	a3,s3
    800050ae:	e1040613          	addi	a2,s0,-496
    800050b2:	4581                	li	a1,0
    800050b4:	854a                	mv	a0,s2
    800050b6:	fffff097          	auipc	ra,0xfffff
    800050ba:	9ec080e7          	jalr	-1556(ra) # 80003aa2 <readi>
    800050be:	03800793          	li	a5,56
    800050c2:	f8f516e3          	bne	a0,a5,8000504e <exec+0x2d8>
    if(ph.type != ELF_PROG_LOAD)
    800050c6:	e1042783          	lw	a5,-496(s0)
    800050ca:	4705                	li	a4,1
    800050cc:	fce796e3          	bne	a5,a4,80005098 <exec+0x322>
    if(ph.memsz < ph.filesz)
    800050d0:	e3843603          	ld	a2,-456(s0)
    800050d4:	e3043783          	ld	a5,-464(s0)
    800050d8:	f8f669e3          	bltu	a2,a5,8000506a <exec+0x2f4>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800050dc:	e2043783          	ld	a5,-480(s0)
    800050e0:	963e                	add	a2,a2,a5
    800050e2:	f8f667e3          	bltu	a2,a5,80005070 <exec+0x2fa>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800050e6:	85a6                	mv	a1,s1
    800050e8:	e0843503          	ld	a0,-504(s0)
    800050ec:	ffffc097          	auipc	ra,0xffffc
    800050f0:	474080e7          	jalr	1140(ra) # 80001560 <uvmalloc>
    800050f4:	e0a43023          	sd	a0,-512(s0)
    800050f8:	dd3d                	beqz	a0,80005076 <exec+0x300>
    if(ph.vaddr % PGSIZE != 0)
    800050fa:	e2043d03          	ld	s10,-480(s0)
    800050fe:	de843783          	ld	a5,-536(s0)
    80005102:	00fd77b3          	and	a5,s10,a5
    80005106:	f7b1                	bnez	a5,80005052 <exec+0x2dc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005108:	e1842d83          	lw	s11,-488(s0)
    8000510c:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005110:	f80b82e3          	beqz	s7,80005094 <exec+0x31e>
    80005114:	8a5e                	mv	s4,s7
    80005116:	4481                	li	s1,0
    80005118:	b379                	j	80004ea6 <exec+0x130>

000000008000511a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000511a:	7179                	addi	sp,sp,-48
    8000511c:	f406                	sd	ra,40(sp)
    8000511e:	f022                	sd	s0,32(sp)
    80005120:	ec26                	sd	s1,24(sp)
    80005122:	e84a                	sd	s2,16(sp)
    80005124:	1800                	addi	s0,sp,48
    80005126:	892e                	mv	s2,a1
    80005128:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000512a:	fdc40593          	addi	a1,s0,-36
    8000512e:	ffffe097          	auipc	ra,0xffffe
    80005132:	af6080e7          	jalr	-1290(ra) # 80002c24 <argint>
    80005136:	04054063          	bltz	a0,80005176 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000513a:	fdc42703          	lw	a4,-36(s0)
    8000513e:	47bd                	li	a5,15
    80005140:	02e7ed63          	bltu	a5,a4,8000517a <argfd+0x60>
    80005144:	ffffd097          	auipc	ra,0xffffd
    80005148:	990080e7          	jalr	-1648(ra) # 80001ad4 <myproc>
    8000514c:	fdc42703          	lw	a4,-36(s0)
    80005150:	01a70793          	addi	a5,a4,26
    80005154:	078e                	slli	a5,a5,0x3
    80005156:	953e                	add	a0,a0,a5
    80005158:	611c                	ld	a5,0(a0)
    8000515a:	c395                	beqz	a5,8000517e <argfd+0x64>
    return -1;
  if(pfd)
    8000515c:	00090463          	beqz	s2,80005164 <argfd+0x4a>
    *pfd = fd;
    80005160:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005164:	4501                	li	a0,0
  if(pf)
    80005166:	c091                	beqz	s1,8000516a <argfd+0x50>
    *pf = f;
    80005168:	e09c                	sd	a5,0(s1)
}
    8000516a:	70a2                	ld	ra,40(sp)
    8000516c:	7402                	ld	s0,32(sp)
    8000516e:	64e2                	ld	s1,24(sp)
    80005170:	6942                	ld	s2,16(sp)
    80005172:	6145                	addi	sp,sp,48
    80005174:	8082                	ret
    return -1;
    80005176:	557d                	li	a0,-1
    80005178:	bfcd                	j	8000516a <argfd+0x50>
    return -1;
    8000517a:	557d                	li	a0,-1
    8000517c:	b7fd                	j	8000516a <argfd+0x50>
    8000517e:	557d                	li	a0,-1
    80005180:	b7ed                	j	8000516a <argfd+0x50>

0000000080005182 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005182:	1101                	addi	sp,sp,-32
    80005184:	ec06                	sd	ra,24(sp)
    80005186:	e822                	sd	s0,16(sp)
    80005188:	e426                	sd	s1,8(sp)
    8000518a:	1000                	addi	s0,sp,32
    8000518c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000518e:	ffffd097          	auipc	ra,0xffffd
    80005192:	946080e7          	jalr	-1722(ra) # 80001ad4 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
    80005196:	697c                	ld	a5,208(a0)
    80005198:	c395                	beqz	a5,800051bc <fdalloc+0x3a>
    8000519a:	0d850713          	addi	a4,a0,216
  for(fd = 0; fd < NOFILE; fd++){
    8000519e:	4785                	li	a5,1
    800051a0:	4641                	li	a2,16
    if(p->ofile[fd] == 0){
    800051a2:	6314                	ld	a3,0(a4)
    800051a4:	ce89                	beqz	a3,800051be <fdalloc+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
    800051a6:	2785                	addiw	a5,a5,1
    800051a8:	0721                	addi	a4,a4,8
    800051aa:	fec79ce3          	bne	a5,a2,800051a2 <fdalloc+0x20>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800051ae:	57fd                	li	a5,-1
}
    800051b0:	853e                	mv	a0,a5
    800051b2:	60e2                	ld	ra,24(sp)
    800051b4:	6442                	ld	s0,16(sp)
    800051b6:	64a2                	ld	s1,8(sp)
    800051b8:	6105                	addi	sp,sp,32
    800051ba:	8082                	ret
  for(fd = 0; fd < NOFILE; fd++){
    800051bc:	4781                	li	a5,0
      p->ofile[fd] = f;
    800051be:	01a78713          	addi	a4,a5,26
    800051c2:	070e                	slli	a4,a4,0x3
    800051c4:	953a                	add	a0,a0,a4
    800051c6:	e104                	sd	s1,0(a0)
      return fd;
    800051c8:	b7e5                	j	800051b0 <fdalloc+0x2e>

00000000800051ca <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800051ca:	715d                	addi	sp,sp,-80
    800051cc:	e486                	sd	ra,72(sp)
    800051ce:	e0a2                	sd	s0,64(sp)
    800051d0:	fc26                	sd	s1,56(sp)
    800051d2:	f84a                	sd	s2,48(sp)
    800051d4:	f44e                	sd	s3,40(sp)
    800051d6:	f052                	sd	s4,32(sp)
    800051d8:	ec56                	sd	s5,24(sp)
    800051da:	0880                	addi	s0,sp,80
    800051dc:	89ae                	mv	s3,a1
    800051de:	8ab2                	mv	s5,a2
    800051e0:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800051e2:	fb040593          	addi	a1,s0,-80
    800051e6:	fffff097          	auipc	ra,0xfffff
    800051ea:	dde080e7          	jalr	-546(ra) # 80003fc4 <nameiparent>
    800051ee:	892a                	mv	s2,a0
    800051f0:	12050f63          	beqz	a0,8000532e <create+0x164>
    return 0;

  ilock(dp);
    800051f4:	ffffe097          	auipc	ra,0xffffe
    800051f8:	5f8080e7          	jalr	1528(ra) # 800037ec <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800051fc:	4601                	li	a2,0
    800051fe:	fb040593          	addi	a1,s0,-80
    80005202:	854a                	mv	a0,s2
    80005204:	fffff097          	auipc	ra,0xfffff
    80005208:	ac8080e7          	jalr	-1336(ra) # 80003ccc <dirlookup>
    8000520c:	84aa                	mv	s1,a0
    8000520e:	c921                	beqz	a0,8000525e <create+0x94>
    iunlockput(dp);
    80005210:	854a                	mv	a0,s2
    80005212:	fffff097          	auipc	ra,0xfffff
    80005216:	83e080e7          	jalr	-1986(ra) # 80003a50 <iunlockput>
    ilock(ip);
    8000521a:	8526                	mv	a0,s1
    8000521c:	ffffe097          	auipc	ra,0xffffe
    80005220:	5d0080e7          	jalr	1488(ra) # 800037ec <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005224:	2981                	sext.w	s3,s3
    80005226:	4789                	li	a5,2
    80005228:	02f99463          	bne	s3,a5,80005250 <create+0x86>
    8000522c:	0444d783          	lhu	a5,68(s1)
    80005230:	37f9                	addiw	a5,a5,-2
    80005232:	17c2                	slli	a5,a5,0x30
    80005234:	93c1                	srli	a5,a5,0x30
    80005236:	4705                	li	a4,1
    80005238:	00f76c63          	bltu	a4,a5,80005250 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000523c:	8526                	mv	a0,s1
    8000523e:	60a6                	ld	ra,72(sp)
    80005240:	6406                	ld	s0,64(sp)
    80005242:	74e2                	ld	s1,56(sp)
    80005244:	7942                	ld	s2,48(sp)
    80005246:	79a2                	ld	s3,40(sp)
    80005248:	7a02                	ld	s4,32(sp)
    8000524a:	6ae2                	ld	s5,24(sp)
    8000524c:	6161                	addi	sp,sp,80
    8000524e:	8082                	ret
    iunlockput(ip);
    80005250:	8526                	mv	a0,s1
    80005252:	ffffe097          	auipc	ra,0xffffe
    80005256:	7fe080e7          	jalr	2046(ra) # 80003a50 <iunlockput>
    return 0;
    8000525a:	4481                	li	s1,0
    8000525c:	b7c5                	j	8000523c <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000525e:	85ce                	mv	a1,s3
    80005260:	00092503          	lw	a0,0(s2)
    80005264:	ffffe097          	auipc	ra,0xffffe
    80005268:	3ec080e7          	jalr	1004(ra) # 80003650 <ialloc>
    8000526c:	84aa                	mv	s1,a0
    8000526e:	c529                	beqz	a0,800052b8 <create+0xee>
  ilock(ip);
    80005270:	ffffe097          	auipc	ra,0xffffe
    80005274:	57c080e7          	jalr	1404(ra) # 800037ec <ilock>
  ip->major = major;
    80005278:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000527c:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005280:	4785                	li	a5,1
    80005282:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005286:	8526                	mv	a0,s1
    80005288:	ffffe097          	auipc	ra,0xffffe
    8000528c:	498080e7          	jalr	1176(ra) # 80003720 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005290:	2981                	sext.w	s3,s3
    80005292:	4785                	li	a5,1
    80005294:	02f98a63          	beq	s3,a5,800052c8 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005298:	40d0                	lw	a2,4(s1)
    8000529a:	fb040593          	addi	a1,s0,-80
    8000529e:	854a                	mv	a0,s2
    800052a0:	fffff097          	auipc	ra,0xfffff
    800052a4:	c44080e7          	jalr	-956(ra) # 80003ee4 <dirlink>
    800052a8:	06054b63          	bltz	a0,8000531e <create+0x154>
  iunlockput(dp);
    800052ac:	854a                	mv	a0,s2
    800052ae:	ffffe097          	auipc	ra,0xffffe
    800052b2:	7a2080e7          	jalr	1954(ra) # 80003a50 <iunlockput>
  return ip;
    800052b6:	b759                	j	8000523c <create+0x72>
    panic("create: ialloc");
    800052b8:	00003517          	auipc	a0,0x3
    800052bc:	44850513          	addi	a0,a0,1096 # 80008700 <syscalls+0x2e8>
    800052c0:	ffffb097          	auipc	ra,0xffffb
    800052c4:	342080e7          	jalr	834(ra) # 80000602 <panic>
    dp->nlink++;  // for ".."
    800052c8:	04a95783          	lhu	a5,74(s2)
    800052cc:	2785                	addiw	a5,a5,1
    800052ce:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800052d2:	854a                	mv	a0,s2
    800052d4:	ffffe097          	auipc	ra,0xffffe
    800052d8:	44c080e7          	jalr	1100(ra) # 80003720 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800052dc:	40d0                	lw	a2,4(s1)
    800052de:	00003597          	auipc	a1,0x3
    800052e2:	43258593          	addi	a1,a1,1074 # 80008710 <syscalls+0x2f8>
    800052e6:	8526                	mv	a0,s1
    800052e8:	fffff097          	auipc	ra,0xfffff
    800052ec:	bfc080e7          	jalr	-1028(ra) # 80003ee4 <dirlink>
    800052f0:	00054f63          	bltz	a0,8000530e <create+0x144>
    800052f4:	00492603          	lw	a2,4(s2)
    800052f8:	00003597          	auipc	a1,0x3
    800052fc:	42058593          	addi	a1,a1,1056 # 80008718 <syscalls+0x300>
    80005300:	8526                	mv	a0,s1
    80005302:	fffff097          	auipc	ra,0xfffff
    80005306:	be2080e7          	jalr	-1054(ra) # 80003ee4 <dirlink>
    8000530a:	f80557e3          	bgez	a0,80005298 <create+0xce>
      panic("create dots");
    8000530e:	00003517          	auipc	a0,0x3
    80005312:	41250513          	addi	a0,a0,1042 # 80008720 <syscalls+0x308>
    80005316:	ffffb097          	auipc	ra,0xffffb
    8000531a:	2ec080e7          	jalr	748(ra) # 80000602 <panic>
    panic("create: dirlink");
    8000531e:	00003517          	auipc	a0,0x3
    80005322:	41250513          	addi	a0,a0,1042 # 80008730 <syscalls+0x318>
    80005326:	ffffb097          	auipc	ra,0xffffb
    8000532a:	2dc080e7          	jalr	732(ra) # 80000602 <panic>
    return 0;
    8000532e:	84aa                	mv	s1,a0
    80005330:	b731                	j	8000523c <create+0x72>

0000000080005332 <sys_dup>:
{
    80005332:	7179                	addi	sp,sp,-48
    80005334:	f406                	sd	ra,40(sp)
    80005336:	f022                	sd	s0,32(sp)
    80005338:	ec26                	sd	s1,24(sp)
    8000533a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000533c:	fd840613          	addi	a2,s0,-40
    80005340:	4581                	li	a1,0
    80005342:	4501                	li	a0,0
    80005344:	00000097          	auipc	ra,0x0
    80005348:	dd6080e7          	jalr	-554(ra) # 8000511a <argfd>
    return -1;
    8000534c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000534e:	02054363          	bltz	a0,80005374 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005352:	fd843503          	ld	a0,-40(s0)
    80005356:	00000097          	auipc	ra,0x0
    8000535a:	e2c080e7          	jalr	-468(ra) # 80005182 <fdalloc>
    8000535e:	84aa                	mv	s1,a0
    return -1;
    80005360:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005362:	00054963          	bltz	a0,80005374 <sys_dup+0x42>
  filedup(f);
    80005366:	fd843503          	ld	a0,-40(s0)
    8000536a:	fffff097          	auipc	ra,0xfffff
    8000536e:	2fa080e7          	jalr	762(ra) # 80004664 <filedup>
  return fd;
    80005372:	87a6                	mv	a5,s1
}
    80005374:	853e                	mv	a0,a5
    80005376:	70a2                	ld	ra,40(sp)
    80005378:	7402                	ld	s0,32(sp)
    8000537a:	64e2                	ld	s1,24(sp)
    8000537c:	6145                	addi	sp,sp,48
    8000537e:	8082                	ret

0000000080005380 <sys_read>:
{
    80005380:	7179                	addi	sp,sp,-48
    80005382:	f406                	sd	ra,40(sp)
    80005384:	f022                	sd	s0,32(sp)
    80005386:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005388:	fe840613          	addi	a2,s0,-24
    8000538c:	4581                	li	a1,0
    8000538e:	4501                	li	a0,0
    80005390:	00000097          	auipc	ra,0x0
    80005394:	d8a080e7          	jalr	-630(ra) # 8000511a <argfd>
    return -1;
    80005398:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000539a:	04054163          	bltz	a0,800053dc <sys_read+0x5c>
    8000539e:	fe440593          	addi	a1,s0,-28
    800053a2:	4509                	li	a0,2
    800053a4:	ffffe097          	auipc	ra,0xffffe
    800053a8:	880080e7          	jalr	-1920(ra) # 80002c24 <argint>
    return -1;
    800053ac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053ae:	02054763          	bltz	a0,800053dc <sys_read+0x5c>
    800053b2:	fd840593          	addi	a1,s0,-40
    800053b6:	4505                	li	a0,1
    800053b8:	ffffe097          	auipc	ra,0xffffe
    800053bc:	88e080e7          	jalr	-1906(ra) # 80002c46 <argaddr>
    return -1;
    800053c0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053c2:	00054d63          	bltz	a0,800053dc <sys_read+0x5c>
  return fileread(f, p, n);
    800053c6:	fe442603          	lw	a2,-28(s0)
    800053ca:	fd843583          	ld	a1,-40(s0)
    800053ce:	fe843503          	ld	a0,-24(s0)
    800053d2:	fffff097          	auipc	ra,0xfffff
    800053d6:	41e080e7          	jalr	1054(ra) # 800047f0 <fileread>
    800053da:	87aa                	mv	a5,a0
}
    800053dc:	853e                	mv	a0,a5
    800053de:	70a2                	ld	ra,40(sp)
    800053e0:	7402                	ld	s0,32(sp)
    800053e2:	6145                	addi	sp,sp,48
    800053e4:	8082                	ret

00000000800053e6 <sys_write>:
{
    800053e6:	7179                	addi	sp,sp,-48
    800053e8:	f406                	sd	ra,40(sp)
    800053ea:	f022                	sd	s0,32(sp)
    800053ec:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053ee:	fe840613          	addi	a2,s0,-24
    800053f2:	4581                	li	a1,0
    800053f4:	4501                	li	a0,0
    800053f6:	00000097          	auipc	ra,0x0
    800053fa:	d24080e7          	jalr	-732(ra) # 8000511a <argfd>
    return -1;
    800053fe:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005400:	04054163          	bltz	a0,80005442 <sys_write+0x5c>
    80005404:	fe440593          	addi	a1,s0,-28
    80005408:	4509                	li	a0,2
    8000540a:	ffffe097          	auipc	ra,0xffffe
    8000540e:	81a080e7          	jalr	-2022(ra) # 80002c24 <argint>
    return -1;
    80005412:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005414:	02054763          	bltz	a0,80005442 <sys_write+0x5c>
    80005418:	fd840593          	addi	a1,s0,-40
    8000541c:	4505                	li	a0,1
    8000541e:	ffffe097          	auipc	ra,0xffffe
    80005422:	828080e7          	jalr	-2008(ra) # 80002c46 <argaddr>
    return -1;
    80005426:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005428:	00054d63          	bltz	a0,80005442 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000542c:	fe442603          	lw	a2,-28(s0)
    80005430:	fd843583          	ld	a1,-40(s0)
    80005434:	fe843503          	ld	a0,-24(s0)
    80005438:	fffff097          	auipc	ra,0xfffff
    8000543c:	47a080e7          	jalr	1146(ra) # 800048b2 <filewrite>
    80005440:	87aa                	mv	a5,a0
}
    80005442:	853e                	mv	a0,a5
    80005444:	70a2                	ld	ra,40(sp)
    80005446:	7402                	ld	s0,32(sp)
    80005448:	6145                	addi	sp,sp,48
    8000544a:	8082                	ret

000000008000544c <sys_close>:
{
    8000544c:	1101                	addi	sp,sp,-32
    8000544e:	ec06                	sd	ra,24(sp)
    80005450:	e822                	sd	s0,16(sp)
    80005452:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005454:	fe040613          	addi	a2,s0,-32
    80005458:	fec40593          	addi	a1,s0,-20
    8000545c:	4501                	li	a0,0
    8000545e:	00000097          	auipc	ra,0x0
    80005462:	cbc080e7          	jalr	-836(ra) # 8000511a <argfd>
    return -1;
    80005466:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005468:	02054463          	bltz	a0,80005490 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000546c:	ffffc097          	auipc	ra,0xffffc
    80005470:	668080e7          	jalr	1640(ra) # 80001ad4 <myproc>
    80005474:	fec42783          	lw	a5,-20(s0)
    80005478:	07e9                	addi	a5,a5,26
    8000547a:	078e                	slli	a5,a5,0x3
    8000547c:	953e                	add	a0,a0,a5
    8000547e:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005482:	fe043503          	ld	a0,-32(s0)
    80005486:	fffff097          	auipc	ra,0xfffff
    8000548a:	230080e7          	jalr	560(ra) # 800046b6 <fileclose>
  return 0;
    8000548e:	4781                	li	a5,0
}
    80005490:	853e                	mv	a0,a5
    80005492:	60e2                	ld	ra,24(sp)
    80005494:	6442                	ld	s0,16(sp)
    80005496:	6105                	addi	sp,sp,32
    80005498:	8082                	ret

000000008000549a <sys_fstat>:
{
    8000549a:	1101                	addi	sp,sp,-32
    8000549c:	ec06                	sd	ra,24(sp)
    8000549e:	e822                	sd	s0,16(sp)
    800054a0:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800054a2:	fe840613          	addi	a2,s0,-24
    800054a6:	4581                	li	a1,0
    800054a8:	4501                	li	a0,0
    800054aa:	00000097          	auipc	ra,0x0
    800054ae:	c70080e7          	jalr	-912(ra) # 8000511a <argfd>
    return -1;
    800054b2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800054b4:	02054563          	bltz	a0,800054de <sys_fstat+0x44>
    800054b8:	fe040593          	addi	a1,s0,-32
    800054bc:	4505                	li	a0,1
    800054be:	ffffd097          	auipc	ra,0xffffd
    800054c2:	788080e7          	jalr	1928(ra) # 80002c46 <argaddr>
    return -1;
    800054c6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800054c8:	00054b63          	bltz	a0,800054de <sys_fstat+0x44>
  return filestat(f, st);
    800054cc:	fe043583          	ld	a1,-32(s0)
    800054d0:	fe843503          	ld	a0,-24(s0)
    800054d4:	fffff097          	auipc	ra,0xfffff
    800054d8:	2aa080e7          	jalr	682(ra) # 8000477e <filestat>
    800054dc:	87aa                	mv	a5,a0
}
    800054de:	853e                	mv	a0,a5
    800054e0:	60e2                	ld	ra,24(sp)
    800054e2:	6442                	ld	s0,16(sp)
    800054e4:	6105                	addi	sp,sp,32
    800054e6:	8082                	ret

00000000800054e8 <sys_link>:
{
    800054e8:	7169                	addi	sp,sp,-304
    800054ea:	f606                	sd	ra,296(sp)
    800054ec:	f222                	sd	s0,288(sp)
    800054ee:	ee26                	sd	s1,280(sp)
    800054f0:	ea4a                	sd	s2,272(sp)
    800054f2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054f4:	08000613          	li	a2,128
    800054f8:	ed040593          	addi	a1,s0,-304
    800054fc:	4501                	li	a0,0
    800054fe:	ffffd097          	auipc	ra,0xffffd
    80005502:	76a080e7          	jalr	1898(ra) # 80002c68 <argstr>
    return -1;
    80005506:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005508:	10054e63          	bltz	a0,80005624 <sys_link+0x13c>
    8000550c:	08000613          	li	a2,128
    80005510:	f5040593          	addi	a1,s0,-176
    80005514:	4505                	li	a0,1
    80005516:	ffffd097          	auipc	ra,0xffffd
    8000551a:	752080e7          	jalr	1874(ra) # 80002c68 <argstr>
    return -1;
    8000551e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005520:	10054263          	bltz	a0,80005624 <sys_link+0x13c>
  begin_op();
    80005524:	fffff097          	auipc	ra,0xfffff
    80005528:	c90080e7          	jalr	-880(ra) # 800041b4 <begin_op>
  if((ip = namei(old)) == 0){
    8000552c:	ed040513          	addi	a0,s0,-304
    80005530:	fffff097          	auipc	ra,0xfffff
    80005534:	a76080e7          	jalr	-1418(ra) # 80003fa6 <namei>
    80005538:	84aa                	mv	s1,a0
    8000553a:	c551                	beqz	a0,800055c6 <sys_link+0xde>
  ilock(ip);
    8000553c:	ffffe097          	auipc	ra,0xffffe
    80005540:	2b0080e7          	jalr	688(ra) # 800037ec <ilock>
  if(ip->type == T_DIR){
    80005544:	04449703          	lh	a4,68(s1)
    80005548:	4785                	li	a5,1
    8000554a:	08f70463          	beq	a4,a5,800055d2 <sys_link+0xea>
  ip->nlink++;
    8000554e:	04a4d783          	lhu	a5,74(s1)
    80005552:	2785                	addiw	a5,a5,1
    80005554:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005558:	8526                	mv	a0,s1
    8000555a:	ffffe097          	auipc	ra,0xffffe
    8000555e:	1c6080e7          	jalr	454(ra) # 80003720 <iupdate>
  iunlock(ip);
    80005562:	8526                	mv	a0,s1
    80005564:	ffffe097          	auipc	ra,0xffffe
    80005568:	34c080e7          	jalr	844(ra) # 800038b0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000556c:	fd040593          	addi	a1,s0,-48
    80005570:	f5040513          	addi	a0,s0,-176
    80005574:	fffff097          	auipc	ra,0xfffff
    80005578:	a50080e7          	jalr	-1456(ra) # 80003fc4 <nameiparent>
    8000557c:	892a                	mv	s2,a0
    8000557e:	c935                	beqz	a0,800055f2 <sys_link+0x10a>
  ilock(dp);
    80005580:	ffffe097          	auipc	ra,0xffffe
    80005584:	26c080e7          	jalr	620(ra) # 800037ec <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005588:	00092703          	lw	a4,0(s2)
    8000558c:	409c                	lw	a5,0(s1)
    8000558e:	04f71d63          	bne	a4,a5,800055e8 <sys_link+0x100>
    80005592:	40d0                	lw	a2,4(s1)
    80005594:	fd040593          	addi	a1,s0,-48
    80005598:	854a                	mv	a0,s2
    8000559a:	fffff097          	auipc	ra,0xfffff
    8000559e:	94a080e7          	jalr	-1718(ra) # 80003ee4 <dirlink>
    800055a2:	04054363          	bltz	a0,800055e8 <sys_link+0x100>
  iunlockput(dp);
    800055a6:	854a                	mv	a0,s2
    800055a8:	ffffe097          	auipc	ra,0xffffe
    800055ac:	4a8080e7          	jalr	1192(ra) # 80003a50 <iunlockput>
  iput(ip);
    800055b0:	8526                	mv	a0,s1
    800055b2:	ffffe097          	auipc	ra,0xffffe
    800055b6:	3f6080e7          	jalr	1014(ra) # 800039a8 <iput>
  end_op();
    800055ba:	fffff097          	auipc	ra,0xfffff
    800055be:	c7a080e7          	jalr	-902(ra) # 80004234 <end_op>
  return 0;
    800055c2:	4781                	li	a5,0
    800055c4:	a085                	j	80005624 <sys_link+0x13c>
    end_op();
    800055c6:	fffff097          	auipc	ra,0xfffff
    800055ca:	c6e080e7          	jalr	-914(ra) # 80004234 <end_op>
    return -1;
    800055ce:	57fd                	li	a5,-1
    800055d0:	a891                	j	80005624 <sys_link+0x13c>
    iunlockput(ip);
    800055d2:	8526                	mv	a0,s1
    800055d4:	ffffe097          	auipc	ra,0xffffe
    800055d8:	47c080e7          	jalr	1148(ra) # 80003a50 <iunlockput>
    end_op();
    800055dc:	fffff097          	auipc	ra,0xfffff
    800055e0:	c58080e7          	jalr	-936(ra) # 80004234 <end_op>
    return -1;
    800055e4:	57fd                	li	a5,-1
    800055e6:	a83d                	j	80005624 <sys_link+0x13c>
    iunlockput(dp);
    800055e8:	854a                	mv	a0,s2
    800055ea:	ffffe097          	auipc	ra,0xffffe
    800055ee:	466080e7          	jalr	1126(ra) # 80003a50 <iunlockput>
  ilock(ip);
    800055f2:	8526                	mv	a0,s1
    800055f4:	ffffe097          	auipc	ra,0xffffe
    800055f8:	1f8080e7          	jalr	504(ra) # 800037ec <ilock>
  ip->nlink--;
    800055fc:	04a4d783          	lhu	a5,74(s1)
    80005600:	37fd                	addiw	a5,a5,-1
    80005602:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005606:	8526                	mv	a0,s1
    80005608:	ffffe097          	auipc	ra,0xffffe
    8000560c:	118080e7          	jalr	280(ra) # 80003720 <iupdate>
  iunlockput(ip);
    80005610:	8526                	mv	a0,s1
    80005612:	ffffe097          	auipc	ra,0xffffe
    80005616:	43e080e7          	jalr	1086(ra) # 80003a50 <iunlockput>
  end_op();
    8000561a:	fffff097          	auipc	ra,0xfffff
    8000561e:	c1a080e7          	jalr	-998(ra) # 80004234 <end_op>
  return -1;
    80005622:	57fd                	li	a5,-1
}
    80005624:	853e                	mv	a0,a5
    80005626:	70b2                	ld	ra,296(sp)
    80005628:	7412                	ld	s0,288(sp)
    8000562a:	64f2                	ld	s1,280(sp)
    8000562c:	6952                	ld	s2,272(sp)
    8000562e:	6155                	addi	sp,sp,304
    80005630:	8082                	ret

0000000080005632 <sys_unlink>:
{
    80005632:	7151                	addi	sp,sp,-240
    80005634:	f586                	sd	ra,232(sp)
    80005636:	f1a2                	sd	s0,224(sp)
    80005638:	eda6                	sd	s1,216(sp)
    8000563a:	e9ca                	sd	s2,208(sp)
    8000563c:	e5ce                	sd	s3,200(sp)
    8000563e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005640:	08000613          	li	a2,128
    80005644:	f3040593          	addi	a1,s0,-208
    80005648:	4501                	li	a0,0
    8000564a:	ffffd097          	auipc	ra,0xffffd
    8000564e:	61e080e7          	jalr	1566(ra) # 80002c68 <argstr>
    80005652:	16054f63          	bltz	a0,800057d0 <sys_unlink+0x19e>
  begin_op();
    80005656:	fffff097          	auipc	ra,0xfffff
    8000565a:	b5e080e7          	jalr	-1186(ra) # 800041b4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000565e:	fb040593          	addi	a1,s0,-80
    80005662:	f3040513          	addi	a0,s0,-208
    80005666:	fffff097          	auipc	ra,0xfffff
    8000566a:	95e080e7          	jalr	-1698(ra) # 80003fc4 <nameiparent>
    8000566e:	89aa                	mv	s3,a0
    80005670:	c979                	beqz	a0,80005746 <sys_unlink+0x114>
  ilock(dp);
    80005672:	ffffe097          	auipc	ra,0xffffe
    80005676:	17a080e7          	jalr	378(ra) # 800037ec <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000567a:	00003597          	auipc	a1,0x3
    8000567e:	09658593          	addi	a1,a1,150 # 80008710 <syscalls+0x2f8>
    80005682:	fb040513          	addi	a0,s0,-80
    80005686:	ffffe097          	auipc	ra,0xffffe
    8000568a:	62c080e7          	jalr	1580(ra) # 80003cb2 <namecmp>
    8000568e:	14050863          	beqz	a0,800057de <sys_unlink+0x1ac>
    80005692:	00003597          	auipc	a1,0x3
    80005696:	08658593          	addi	a1,a1,134 # 80008718 <syscalls+0x300>
    8000569a:	fb040513          	addi	a0,s0,-80
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	614080e7          	jalr	1556(ra) # 80003cb2 <namecmp>
    800056a6:	12050c63          	beqz	a0,800057de <sys_unlink+0x1ac>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800056aa:	f2c40613          	addi	a2,s0,-212
    800056ae:	fb040593          	addi	a1,s0,-80
    800056b2:	854e                	mv	a0,s3
    800056b4:	ffffe097          	auipc	ra,0xffffe
    800056b8:	618080e7          	jalr	1560(ra) # 80003ccc <dirlookup>
    800056bc:	84aa                	mv	s1,a0
    800056be:	12050063          	beqz	a0,800057de <sys_unlink+0x1ac>
  ilock(ip);
    800056c2:	ffffe097          	auipc	ra,0xffffe
    800056c6:	12a080e7          	jalr	298(ra) # 800037ec <ilock>
  if(ip->nlink < 1)
    800056ca:	04a49783          	lh	a5,74(s1)
    800056ce:	08f05263          	blez	a5,80005752 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800056d2:	04449703          	lh	a4,68(s1)
    800056d6:	4785                	li	a5,1
    800056d8:	08f70563          	beq	a4,a5,80005762 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800056dc:	4641                	li	a2,16
    800056de:	4581                	li	a1,0
    800056e0:	fc040513          	addi	a0,s0,-64
    800056e4:	ffffb097          	auipc	ra,0xffffb
    800056e8:	6de080e7          	jalr	1758(ra) # 80000dc2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056ec:	4741                	li	a4,16
    800056ee:	f2c42683          	lw	a3,-212(s0)
    800056f2:	fc040613          	addi	a2,s0,-64
    800056f6:	4581                	li	a1,0
    800056f8:	854e                	mv	a0,s3
    800056fa:	ffffe097          	auipc	ra,0xffffe
    800056fe:	49e080e7          	jalr	1182(ra) # 80003b98 <writei>
    80005702:	47c1                	li	a5,16
    80005704:	0af51363          	bne	a0,a5,800057aa <sys_unlink+0x178>
  if(ip->type == T_DIR){
    80005708:	04449703          	lh	a4,68(s1)
    8000570c:	4785                	li	a5,1
    8000570e:	0af70663          	beq	a4,a5,800057ba <sys_unlink+0x188>
  iunlockput(dp);
    80005712:	854e                	mv	a0,s3
    80005714:	ffffe097          	auipc	ra,0xffffe
    80005718:	33c080e7          	jalr	828(ra) # 80003a50 <iunlockput>
  ip->nlink--;
    8000571c:	04a4d783          	lhu	a5,74(s1)
    80005720:	37fd                	addiw	a5,a5,-1
    80005722:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005726:	8526                	mv	a0,s1
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	ff8080e7          	jalr	-8(ra) # 80003720 <iupdate>
  iunlockput(ip);
    80005730:	8526                	mv	a0,s1
    80005732:	ffffe097          	auipc	ra,0xffffe
    80005736:	31e080e7          	jalr	798(ra) # 80003a50 <iunlockput>
  end_op();
    8000573a:	fffff097          	auipc	ra,0xfffff
    8000573e:	afa080e7          	jalr	-1286(ra) # 80004234 <end_op>
  return 0;
    80005742:	4501                	li	a0,0
    80005744:	a07d                	j	800057f2 <sys_unlink+0x1c0>
    end_op();
    80005746:	fffff097          	auipc	ra,0xfffff
    8000574a:	aee080e7          	jalr	-1298(ra) # 80004234 <end_op>
    return -1;
    8000574e:	557d                	li	a0,-1
    80005750:	a04d                	j	800057f2 <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    80005752:	00003517          	auipc	a0,0x3
    80005756:	fee50513          	addi	a0,a0,-18 # 80008740 <syscalls+0x328>
    8000575a:	ffffb097          	auipc	ra,0xffffb
    8000575e:	ea8080e7          	jalr	-344(ra) # 80000602 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005762:	44f8                	lw	a4,76(s1)
    80005764:	02000793          	li	a5,32
    80005768:	f6e7fae3          	bleu	a4,a5,800056dc <sys_unlink+0xaa>
    8000576c:	02000913          	li	s2,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005770:	4741                	li	a4,16
    80005772:	86ca                	mv	a3,s2
    80005774:	f1840613          	addi	a2,s0,-232
    80005778:	4581                	li	a1,0
    8000577a:	8526                	mv	a0,s1
    8000577c:	ffffe097          	auipc	ra,0xffffe
    80005780:	326080e7          	jalr	806(ra) # 80003aa2 <readi>
    80005784:	47c1                	li	a5,16
    80005786:	00f51a63          	bne	a0,a5,8000579a <sys_unlink+0x168>
    if(de.inum != 0)
    8000578a:	f1845783          	lhu	a5,-232(s0)
    8000578e:	e3b9                	bnez	a5,800057d4 <sys_unlink+0x1a2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005790:	2941                	addiw	s2,s2,16
    80005792:	44fc                	lw	a5,76(s1)
    80005794:	fcf96ee3          	bltu	s2,a5,80005770 <sys_unlink+0x13e>
    80005798:	b791                	j	800056dc <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000579a:	00003517          	auipc	a0,0x3
    8000579e:	fbe50513          	addi	a0,a0,-66 # 80008758 <syscalls+0x340>
    800057a2:	ffffb097          	auipc	ra,0xffffb
    800057a6:	e60080e7          	jalr	-416(ra) # 80000602 <panic>
    panic("unlink: writei");
    800057aa:	00003517          	auipc	a0,0x3
    800057ae:	fc650513          	addi	a0,a0,-58 # 80008770 <syscalls+0x358>
    800057b2:	ffffb097          	auipc	ra,0xffffb
    800057b6:	e50080e7          	jalr	-432(ra) # 80000602 <panic>
    dp->nlink--;
    800057ba:	04a9d783          	lhu	a5,74(s3)
    800057be:	37fd                	addiw	a5,a5,-1
    800057c0:	04f99523          	sh	a5,74(s3)
    iupdate(dp);
    800057c4:	854e                	mv	a0,s3
    800057c6:	ffffe097          	auipc	ra,0xffffe
    800057ca:	f5a080e7          	jalr	-166(ra) # 80003720 <iupdate>
    800057ce:	b791                	j	80005712 <sys_unlink+0xe0>
    return -1;
    800057d0:	557d                	li	a0,-1
    800057d2:	a005                	j	800057f2 <sys_unlink+0x1c0>
    iunlockput(ip);
    800057d4:	8526                	mv	a0,s1
    800057d6:	ffffe097          	auipc	ra,0xffffe
    800057da:	27a080e7          	jalr	634(ra) # 80003a50 <iunlockput>
  iunlockput(dp);
    800057de:	854e                	mv	a0,s3
    800057e0:	ffffe097          	auipc	ra,0xffffe
    800057e4:	270080e7          	jalr	624(ra) # 80003a50 <iunlockput>
  end_op();
    800057e8:	fffff097          	auipc	ra,0xfffff
    800057ec:	a4c080e7          	jalr	-1460(ra) # 80004234 <end_op>
  return -1;
    800057f0:	557d                	li	a0,-1
}
    800057f2:	70ae                	ld	ra,232(sp)
    800057f4:	740e                	ld	s0,224(sp)
    800057f6:	64ee                	ld	s1,216(sp)
    800057f8:	694e                	ld	s2,208(sp)
    800057fa:	69ae                	ld	s3,200(sp)
    800057fc:	616d                	addi	sp,sp,240
    800057fe:	8082                	ret

0000000080005800 <sys_open>:

uint64
sys_open(void)
{
    80005800:	7131                	addi	sp,sp,-192
    80005802:	fd06                	sd	ra,184(sp)
    80005804:	f922                	sd	s0,176(sp)
    80005806:	f526                	sd	s1,168(sp)
    80005808:	f14a                	sd	s2,160(sp)
    8000580a:	ed4e                	sd	s3,152(sp)
    8000580c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000580e:	08000613          	li	a2,128
    80005812:	f5040593          	addi	a1,s0,-176
    80005816:	4501                	li	a0,0
    80005818:	ffffd097          	auipc	ra,0xffffd
    8000581c:	450080e7          	jalr	1104(ra) # 80002c68 <argstr>
    return -1;
    80005820:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005822:	0c054163          	bltz	a0,800058e4 <sys_open+0xe4>
    80005826:	f4c40593          	addi	a1,s0,-180
    8000582a:	4505                	li	a0,1
    8000582c:	ffffd097          	auipc	ra,0xffffd
    80005830:	3f8080e7          	jalr	1016(ra) # 80002c24 <argint>
    80005834:	0a054863          	bltz	a0,800058e4 <sys_open+0xe4>

  begin_op();
    80005838:	fffff097          	auipc	ra,0xfffff
    8000583c:	97c080e7          	jalr	-1668(ra) # 800041b4 <begin_op>

  if(omode & O_CREATE){
    80005840:	f4c42783          	lw	a5,-180(s0)
    80005844:	2007f793          	andi	a5,a5,512
    80005848:	cbdd                	beqz	a5,800058fe <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000584a:	4681                	li	a3,0
    8000584c:	4601                	li	a2,0
    8000584e:	4589                	li	a1,2
    80005850:	f5040513          	addi	a0,s0,-176
    80005854:	00000097          	auipc	ra,0x0
    80005858:	976080e7          	jalr	-1674(ra) # 800051ca <create>
    8000585c:	892a                	mv	s2,a0
    if(ip == 0){
    8000585e:	c959                	beqz	a0,800058f4 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005860:	04491703          	lh	a4,68(s2)
    80005864:	478d                	li	a5,3
    80005866:	00f71763          	bne	a4,a5,80005874 <sys_open+0x74>
    8000586a:	04695703          	lhu	a4,70(s2)
    8000586e:	47a5                	li	a5,9
    80005870:	0ce7ec63          	bltu	a5,a4,80005948 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005874:	fffff097          	auipc	ra,0xfffff
    80005878:	d72080e7          	jalr	-654(ra) # 800045e6 <filealloc>
    8000587c:	89aa                	mv	s3,a0
    8000587e:	10050263          	beqz	a0,80005982 <sys_open+0x182>
    80005882:	00000097          	auipc	ra,0x0
    80005886:	900080e7          	jalr	-1792(ra) # 80005182 <fdalloc>
    8000588a:	84aa                	mv	s1,a0
    8000588c:	0e054663          	bltz	a0,80005978 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005890:	04491703          	lh	a4,68(s2)
    80005894:	478d                	li	a5,3
    80005896:	0cf70463          	beq	a4,a5,8000595e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000589a:	4789                	li	a5,2
    8000589c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800058a0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800058a4:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800058a8:	f4c42783          	lw	a5,-180(s0)
    800058ac:	0017c713          	xori	a4,a5,1
    800058b0:	8b05                	andi	a4,a4,1
    800058b2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800058b6:	0037f713          	andi	a4,a5,3
    800058ba:	00e03733          	snez	a4,a4
    800058be:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800058c2:	4007f793          	andi	a5,a5,1024
    800058c6:	c791                	beqz	a5,800058d2 <sys_open+0xd2>
    800058c8:	04491703          	lh	a4,68(s2)
    800058cc:	4789                	li	a5,2
    800058ce:	08f70f63          	beq	a4,a5,8000596c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800058d2:	854a                	mv	a0,s2
    800058d4:	ffffe097          	auipc	ra,0xffffe
    800058d8:	fdc080e7          	jalr	-36(ra) # 800038b0 <iunlock>
  end_op();
    800058dc:	fffff097          	auipc	ra,0xfffff
    800058e0:	958080e7          	jalr	-1704(ra) # 80004234 <end_op>

  return fd;
}
    800058e4:	8526                	mv	a0,s1
    800058e6:	70ea                	ld	ra,184(sp)
    800058e8:	744a                	ld	s0,176(sp)
    800058ea:	74aa                	ld	s1,168(sp)
    800058ec:	790a                	ld	s2,160(sp)
    800058ee:	69ea                	ld	s3,152(sp)
    800058f0:	6129                	addi	sp,sp,192
    800058f2:	8082                	ret
      end_op();
    800058f4:	fffff097          	auipc	ra,0xfffff
    800058f8:	940080e7          	jalr	-1728(ra) # 80004234 <end_op>
      return -1;
    800058fc:	b7e5                	j	800058e4 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800058fe:	f5040513          	addi	a0,s0,-176
    80005902:	ffffe097          	auipc	ra,0xffffe
    80005906:	6a4080e7          	jalr	1700(ra) # 80003fa6 <namei>
    8000590a:	892a                	mv	s2,a0
    8000590c:	c905                	beqz	a0,8000593c <sys_open+0x13c>
    ilock(ip);
    8000590e:	ffffe097          	auipc	ra,0xffffe
    80005912:	ede080e7          	jalr	-290(ra) # 800037ec <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005916:	04491703          	lh	a4,68(s2)
    8000591a:	4785                	li	a5,1
    8000591c:	f4f712e3          	bne	a4,a5,80005860 <sys_open+0x60>
    80005920:	f4c42783          	lw	a5,-180(s0)
    80005924:	dba1                	beqz	a5,80005874 <sys_open+0x74>
      iunlockput(ip);
    80005926:	854a                	mv	a0,s2
    80005928:	ffffe097          	auipc	ra,0xffffe
    8000592c:	128080e7          	jalr	296(ra) # 80003a50 <iunlockput>
      end_op();
    80005930:	fffff097          	auipc	ra,0xfffff
    80005934:	904080e7          	jalr	-1788(ra) # 80004234 <end_op>
      return -1;
    80005938:	54fd                	li	s1,-1
    8000593a:	b76d                	j	800058e4 <sys_open+0xe4>
      end_op();
    8000593c:	fffff097          	auipc	ra,0xfffff
    80005940:	8f8080e7          	jalr	-1800(ra) # 80004234 <end_op>
      return -1;
    80005944:	54fd                	li	s1,-1
    80005946:	bf79                	j	800058e4 <sys_open+0xe4>
    iunlockput(ip);
    80005948:	854a                	mv	a0,s2
    8000594a:	ffffe097          	auipc	ra,0xffffe
    8000594e:	106080e7          	jalr	262(ra) # 80003a50 <iunlockput>
    end_op();
    80005952:	fffff097          	auipc	ra,0xfffff
    80005956:	8e2080e7          	jalr	-1822(ra) # 80004234 <end_op>
    return -1;
    8000595a:	54fd                	li	s1,-1
    8000595c:	b761                	j	800058e4 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000595e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005962:	04691783          	lh	a5,70(s2)
    80005966:	02f99223          	sh	a5,36(s3)
    8000596a:	bf2d                	j	800058a4 <sys_open+0xa4>
    itrunc(ip);
    8000596c:	854a                	mv	a0,s2
    8000596e:	ffffe097          	auipc	ra,0xffffe
    80005972:	f8e080e7          	jalr	-114(ra) # 800038fc <itrunc>
    80005976:	bfb1                	j	800058d2 <sys_open+0xd2>
      fileclose(f);
    80005978:	854e                	mv	a0,s3
    8000597a:	fffff097          	auipc	ra,0xfffff
    8000597e:	d3c080e7          	jalr	-708(ra) # 800046b6 <fileclose>
    iunlockput(ip);
    80005982:	854a                	mv	a0,s2
    80005984:	ffffe097          	auipc	ra,0xffffe
    80005988:	0cc080e7          	jalr	204(ra) # 80003a50 <iunlockput>
    end_op();
    8000598c:	fffff097          	auipc	ra,0xfffff
    80005990:	8a8080e7          	jalr	-1880(ra) # 80004234 <end_op>
    return -1;
    80005994:	54fd                	li	s1,-1
    80005996:	b7b9                	j	800058e4 <sys_open+0xe4>

0000000080005998 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005998:	7175                	addi	sp,sp,-144
    8000599a:	e506                	sd	ra,136(sp)
    8000599c:	e122                	sd	s0,128(sp)
    8000599e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800059a0:	fffff097          	auipc	ra,0xfffff
    800059a4:	814080e7          	jalr	-2028(ra) # 800041b4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800059a8:	08000613          	li	a2,128
    800059ac:	f7040593          	addi	a1,s0,-144
    800059b0:	4501                	li	a0,0
    800059b2:	ffffd097          	auipc	ra,0xffffd
    800059b6:	2b6080e7          	jalr	694(ra) # 80002c68 <argstr>
    800059ba:	02054963          	bltz	a0,800059ec <sys_mkdir+0x54>
    800059be:	4681                	li	a3,0
    800059c0:	4601                	li	a2,0
    800059c2:	4585                	li	a1,1
    800059c4:	f7040513          	addi	a0,s0,-144
    800059c8:	00000097          	auipc	ra,0x0
    800059cc:	802080e7          	jalr	-2046(ra) # 800051ca <create>
    800059d0:	cd11                	beqz	a0,800059ec <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059d2:	ffffe097          	auipc	ra,0xffffe
    800059d6:	07e080e7          	jalr	126(ra) # 80003a50 <iunlockput>
  end_op();
    800059da:	fffff097          	auipc	ra,0xfffff
    800059de:	85a080e7          	jalr	-1958(ra) # 80004234 <end_op>
  return 0;
    800059e2:	4501                	li	a0,0
}
    800059e4:	60aa                	ld	ra,136(sp)
    800059e6:	640a                	ld	s0,128(sp)
    800059e8:	6149                	addi	sp,sp,144
    800059ea:	8082                	ret
    end_op();
    800059ec:	fffff097          	auipc	ra,0xfffff
    800059f0:	848080e7          	jalr	-1976(ra) # 80004234 <end_op>
    return -1;
    800059f4:	557d                	li	a0,-1
    800059f6:	b7fd                	j	800059e4 <sys_mkdir+0x4c>

00000000800059f8 <sys_mknod>:

uint64
sys_mknod(void)
{
    800059f8:	7135                	addi	sp,sp,-160
    800059fa:	ed06                	sd	ra,152(sp)
    800059fc:	e922                	sd	s0,144(sp)
    800059fe:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a00:	ffffe097          	auipc	ra,0xffffe
    80005a04:	7b4080e7          	jalr	1972(ra) # 800041b4 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a08:	08000613          	li	a2,128
    80005a0c:	f7040593          	addi	a1,s0,-144
    80005a10:	4501                	li	a0,0
    80005a12:	ffffd097          	auipc	ra,0xffffd
    80005a16:	256080e7          	jalr	598(ra) # 80002c68 <argstr>
    80005a1a:	04054a63          	bltz	a0,80005a6e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005a1e:	f6c40593          	addi	a1,s0,-148
    80005a22:	4505                	li	a0,1
    80005a24:	ffffd097          	auipc	ra,0xffffd
    80005a28:	200080e7          	jalr	512(ra) # 80002c24 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a2c:	04054163          	bltz	a0,80005a6e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005a30:	f6840593          	addi	a1,s0,-152
    80005a34:	4509                	li	a0,2
    80005a36:	ffffd097          	auipc	ra,0xffffd
    80005a3a:	1ee080e7          	jalr	494(ra) # 80002c24 <argint>
     argint(1, &major) < 0 ||
    80005a3e:	02054863          	bltz	a0,80005a6e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a42:	f6841683          	lh	a3,-152(s0)
    80005a46:	f6c41603          	lh	a2,-148(s0)
    80005a4a:	458d                	li	a1,3
    80005a4c:	f7040513          	addi	a0,s0,-144
    80005a50:	fffff097          	auipc	ra,0xfffff
    80005a54:	77a080e7          	jalr	1914(ra) # 800051ca <create>
     argint(2, &minor) < 0 ||
    80005a58:	c919                	beqz	a0,80005a6e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	ff6080e7          	jalr	-10(ra) # 80003a50 <iunlockput>
  end_op();
    80005a62:	ffffe097          	auipc	ra,0xffffe
    80005a66:	7d2080e7          	jalr	2002(ra) # 80004234 <end_op>
  return 0;
    80005a6a:	4501                	li	a0,0
    80005a6c:	a031                	j	80005a78 <sys_mknod+0x80>
    end_op();
    80005a6e:	ffffe097          	auipc	ra,0xffffe
    80005a72:	7c6080e7          	jalr	1990(ra) # 80004234 <end_op>
    return -1;
    80005a76:	557d                	li	a0,-1
}
    80005a78:	60ea                	ld	ra,152(sp)
    80005a7a:	644a                	ld	s0,144(sp)
    80005a7c:	610d                	addi	sp,sp,160
    80005a7e:	8082                	ret

0000000080005a80 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a80:	7135                	addi	sp,sp,-160
    80005a82:	ed06                	sd	ra,152(sp)
    80005a84:	e922                	sd	s0,144(sp)
    80005a86:	e526                	sd	s1,136(sp)
    80005a88:	e14a                	sd	s2,128(sp)
    80005a8a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a8c:	ffffc097          	auipc	ra,0xffffc
    80005a90:	048080e7          	jalr	72(ra) # 80001ad4 <myproc>
    80005a94:	892a                	mv	s2,a0
  
  begin_op();
    80005a96:	ffffe097          	auipc	ra,0xffffe
    80005a9a:	71e080e7          	jalr	1822(ra) # 800041b4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a9e:	08000613          	li	a2,128
    80005aa2:	f6040593          	addi	a1,s0,-160
    80005aa6:	4501                	li	a0,0
    80005aa8:	ffffd097          	auipc	ra,0xffffd
    80005aac:	1c0080e7          	jalr	448(ra) # 80002c68 <argstr>
    80005ab0:	04054b63          	bltz	a0,80005b06 <sys_chdir+0x86>
    80005ab4:	f6040513          	addi	a0,s0,-160
    80005ab8:	ffffe097          	auipc	ra,0xffffe
    80005abc:	4ee080e7          	jalr	1262(ra) # 80003fa6 <namei>
    80005ac0:	84aa                	mv	s1,a0
    80005ac2:	c131                	beqz	a0,80005b06 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ac4:	ffffe097          	auipc	ra,0xffffe
    80005ac8:	d28080e7          	jalr	-728(ra) # 800037ec <ilock>
  if(ip->type != T_DIR){
    80005acc:	04449703          	lh	a4,68(s1)
    80005ad0:	4785                	li	a5,1
    80005ad2:	04f71063          	bne	a4,a5,80005b12 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ad6:	8526                	mv	a0,s1
    80005ad8:	ffffe097          	auipc	ra,0xffffe
    80005adc:	dd8080e7          	jalr	-552(ra) # 800038b0 <iunlock>
  iput(p->cwd);
    80005ae0:	15093503          	ld	a0,336(s2)
    80005ae4:	ffffe097          	auipc	ra,0xffffe
    80005ae8:	ec4080e7          	jalr	-316(ra) # 800039a8 <iput>
  end_op();
    80005aec:	ffffe097          	auipc	ra,0xffffe
    80005af0:	748080e7          	jalr	1864(ra) # 80004234 <end_op>
  p->cwd = ip;
    80005af4:	14993823          	sd	s1,336(s2)
  return 0;
    80005af8:	4501                	li	a0,0
}
    80005afa:	60ea                	ld	ra,152(sp)
    80005afc:	644a                	ld	s0,144(sp)
    80005afe:	64aa                	ld	s1,136(sp)
    80005b00:	690a                	ld	s2,128(sp)
    80005b02:	610d                	addi	sp,sp,160
    80005b04:	8082                	ret
    end_op();
    80005b06:	ffffe097          	auipc	ra,0xffffe
    80005b0a:	72e080e7          	jalr	1838(ra) # 80004234 <end_op>
    return -1;
    80005b0e:	557d                	li	a0,-1
    80005b10:	b7ed                	j	80005afa <sys_chdir+0x7a>
    iunlockput(ip);
    80005b12:	8526                	mv	a0,s1
    80005b14:	ffffe097          	auipc	ra,0xffffe
    80005b18:	f3c080e7          	jalr	-196(ra) # 80003a50 <iunlockput>
    end_op();
    80005b1c:	ffffe097          	auipc	ra,0xffffe
    80005b20:	718080e7          	jalr	1816(ra) # 80004234 <end_op>
    return -1;
    80005b24:	557d                	li	a0,-1
    80005b26:	bfd1                	j	80005afa <sys_chdir+0x7a>

0000000080005b28 <sys_exec>:

uint64
sys_exec(void)
{
    80005b28:	7145                	addi	sp,sp,-464
    80005b2a:	e786                	sd	ra,456(sp)
    80005b2c:	e3a2                	sd	s0,448(sp)
    80005b2e:	ff26                	sd	s1,440(sp)
    80005b30:	fb4a                	sd	s2,432(sp)
    80005b32:	f74e                	sd	s3,424(sp)
    80005b34:	f352                	sd	s4,416(sp)
    80005b36:	ef56                	sd	s5,408(sp)
    80005b38:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005b3a:	08000613          	li	a2,128
    80005b3e:	f4040593          	addi	a1,s0,-192
    80005b42:	4501                	li	a0,0
    80005b44:	ffffd097          	auipc	ra,0xffffd
    80005b48:	124080e7          	jalr	292(ra) # 80002c68 <argstr>
    return -1;
    80005b4c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005b4e:	0e054c63          	bltz	a0,80005c46 <sys_exec+0x11e>
    80005b52:	e3840593          	addi	a1,s0,-456
    80005b56:	4505                	li	a0,1
    80005b58:	ffffd097          	auipc	ra,0xffffd
    80005b5c:	0ee080e7          	jalr	238(ra) # 80002c46 <argaddr>
    80005b60:	0e054363          	bltz	a0,80005c46 <sys_exec+0x11e>
  }
  memset(argv, 0, sizeof(argv));
    80005b64:	e4040913          	addi	s2,s0,-448
    80005b68:	10000613          	li	a2,256
    80005b6c:	4581                	li	a1,0
    80005b6e:	854a                	mv	a0,s2
    80005b70:	ffffb097          	auipc	ra,0xffffb
    80005b74:	252080e7          	jalr	594(ra) # 80000dc2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b78:	89ca                	mv	s3,s2
  memset(argv, 0, sizeof(argv));
    80005b7a:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005b7c:	02000a93          	li	s5,32
    80005b80:	00048a1b          	sext.w	s4,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b84:	00349513          	slli	a0,s1,0x3
    80005b88:	e3040593          	addi	a1,s0,-464
    80005b8c:	e3843783          	ld	a5,-456(s0)
    80005b90:	953e                	add	a0,a0,a5
    80005b92:	ffffd097          	auipc	ra,0xffffd
    80005b96:	ff6080e7          	jalr	-10(ra) # 80002b88 <fetchaddr>
    80005b9a:	02054a63          	bltz	a0,80005bce <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005b9e:	e3043783          	ld	a5,-464(s0)
    80005ba2:	cfa9                	beqz	a5,80005bfc <sys_exec+0xd4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005ba4:	ffffb097          	auipc	ra,0xffffb
    80005ba8:	032080e7          	jalr	50(ra) # 80000bd6 <kalloc>
    80005bac:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80005bb0:	cd19                	beqz	a0,80005bce <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005bb2:	6605                	lui	a2,0x1
    80005bb4:	85aa                	mv	a1,a0
    80005bb6:	e3043503          	ld	a0,-464(s0)
    80005bba:	ffffd097          	auipc	ra,0xffffd
    80005bbe:	022080e7          	jalr	34(ra) # 80002bdc <fetchstr>
    80005bc2:	00054663          	bltz	a0,80005bce <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005bc6:	0485                	addi	s1,s1,1
    80005bc8:	0921                	addi	s2,s2,8
    80005bca:	fb549be3          	bne	s1,s5,80005b80 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bce:	e4043503          	ld	a0,-448(s0)
    kfree(argv[i]);
  return -1;
    80005bd2:	597d                	li	s2,-1
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bd4:	c92d                	beqz	a0,80005c46 <sys_exec+0x11e>
    kfree(argv[i]);
    80005bd6:	ffffb097          	auipc	ra,0xffffb
    80005bda:	f00080e7          	jalr	-256(ra) # 80000ad6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bde:	e4840493          	addi	s1,s0,-440
    80005be2:	10098993          	addi	s3,s3,256
    80005be6:	6088                	ld	a0,0(s1)
    80005be8:	cd31                	beqz	a0,80005c44 <sys_exec+0x11c>
    kfree(argv[i]);
    80005bea:	ffffb097          	auipc	ra,0xffffb
    80005bee:	eec080e7          	jalr	-276(ra) # 80000ad6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bf2:	04a1                	addi	s1,s1,8
    80005bf4:	ff3499e3          	bne	s1,s3,80005be6 <sys_exec+0xbe>
  return -1;
    80005bf8:	597d                	li	s2,-1
    80005bfa:	a0b1                	j	80005c46 <sys_exec+0x11e>
      argv[i] = 0;
    80005bfc:	0a0e                	slli	s4,s4,0x3
    80005bfe:	fc040793          	addi	a5,s0,-64
    80005c02:	9a3e                	add	s4,s4,a5
    80005c04:	e80a3023          	sd	zero,-384(s4)
  int ret = exec(path, argv);
    80005c08:	e4040593          	addi	a1,s0,-448
    80005c0c:	f4040513          	addi	a0,s0,-192
    80005c10:	fffff097          	auipc	ra,0xfffff
    80005c14:	166080e7          	jalr	358(ra) # 80004d76 <exec>
    80005c18:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c1a:	e4043503          	ld	a0,-448(s0)
    80005c1e:	c505                	beqz	a0,80005c46 <sys_exec+0x11e>
    kfree(argv[i]);
    80005c20:	ffffb097          	auipc	ra,0xffffb
    80005c24:	eb6080e7          	jalr	-330(ra) # 80000ad6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c28:	e4840493          	addi	s1,s0,-440
    80005c2c:	10098993          	addi	s3,s3,256
    80005c30:	6088                	ld	a0,0(s1)
    80005c32:	c911                	beqz	a0,80005c46 <sys_exec+0x11e>
    kfree(argv[i]);
    80005c34:	ffffb097          	auipc	ra,0xffffb
    80005c38:	ea2080e7          	jalr	-350(ra) # 80000ad6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c3c:	04a1                	addi	s1,s1,8
    80005c3e:	ff3499e3          	bne	s1,s3,80005c30 <sys_exec+0x108>
    80005c42:	a011                	j	80005c46 <sys_exec+0x11e>
  return -1;
    80005c44:	597d                	li	s2,-1
}
    80005c46:	854a                	mv	a0,s2
    80005c48:	60be                	ld	ra,456(sp)
    80005c4a:	641e                	ld	s0,448(sp)
    80005c4c:	74fa                	ld	s1,440(sp)
    80005c4e:	795a                	ld	s2,432(sp)
    80005c50:	79ba                	ld	s3,424(sp)
    80005c52:	7a1a                	ld	s4,416(sp)
    80005c54:	6afa                	ld	s5,408(sp)
    80005c56:	6179                	addi	sp,sp,464
    80005c58:	8082                	ret

0000000080005c5a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c5a:	7139                	addi	sp,sp,-64
    80005c5c:	fc06                	sd	ra,56(sp)
    80005c5e:	f822                	sd	s0,48(sp)
    80005c60:	f426                	sd	s1,40(sp)
    80005c62:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c64:	ffffc097          	auipc	ra,0xffffc
    80005c68:	e70080e7          	jalr	-400(ra) # 80001ad4 <myproc>
    80005c6c:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005c6e:	fd840593          	addi	a1,s0,-40
    80005c72:	4501                	li	a0,0
    80005c74:	ffffd097          	auipc	ra,0xffffd
    80005c78:	fd2080e7          	jalr	-46(ra) # 80002c46 <argaddr>
    return -1;
    80005c7c:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005c7e:	0c054f63          	bltz	a0,80005d5c <sys_pipe+0x102>
  if(pipealloc(&rf, &wf) < 0)
    80005c82:	fc840593          	addi	a1,s0,-56
    80005c86:	fd040513          	addi	a0,s0,-48
    80005c8a:	fffff097          	auipc	ra,0xfffff
    80005c8e:	d74080e7          	jalr	-652(ra) # 800049fe <pipealloc>
    return -1;
    80005c92:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c94:	0c054463          	bltz	a0,80005d5c <sys_pipe+0x102>
  fd0 = -1;
    80005c98:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c9c:	fd043503          	ld	a0,-48(s0)
    80005ca0:	fffff097          	auipc	ra,0xfffff
    80005ca4:	4e2080e7          	jalr	1250(ra) # 80005182 <fdalloc>
    80005ca8:	fca42223          	sw	a0,-60(s0)
    80005cac:	08054b63          	bltz	a0,80005d42 <sys_pipe+0xe8>
    80005cb0:	fc843503          	ld	a0,-56(s0)
    80005cb4:	fffff097          	auipc	ra,0xfffff
    80005cb8:	4ce080e7          	jalr	1230(ra) # 80005182 <fdalloc>
    80005cbc:	fca42023          	sw	a0,-64(s0)
    80005cc0:	06054863          	bltz	a0,80005d30 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cc4:	4691                	li	a3,4
    80005cc6:	fc440613          	addi	a2,s0,-60
    80005cca:	fd843583          	ld	a1,-40(s0)
    80005cce:	68a8                	ld	a0,80(s1)
    80005cd0:	ffffc097          	auipc	ra,0xffffc
    80005cd4:	ae0080e7          	jalr	-1312(ra) # 800017b0 <copyout>
    80005cd8:	02054063          	bltz	a0,80005cf8 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005cdc:	4691                	li	a3,4
    80005cde:	fc040613          	addi	a2,s0,-64
    80005ce2:	fd843583          	ld	a1,-40(s0)
    80005ce6:	0591                	addi	a1,a1,4
    80005ce8:	68a8                	ld	a0,80(s1)
    80005cea:	ffffc097          	auipc	ra,0xffffc
    80005cee:	ac6080e7          	jalr	-1338(ra) # 800017b0 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005cf2:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cf4:	06055463          	bgez	a0,80005d5c <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80005cf8:	fc442783          	lw	a5,-60(s0)
    80005cfc:	07e9                	addi	a5,a5,26
    80005cfe:	078e                	slli	a5,a5,0x3
    80005d00:	97a6                	add	a5,a5,s1
    80005d02:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d06:	fc042783          	lw	a5,-64(s0)
    80005d0a:	07e9                	addi	a5,a5,26
    80005d0c:	078e                	slli	a5,a5,0x3
    80005d0e:	94be                	add	s1,s1,a5
    80005d10:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d14:	fd043503          	ld	a0,-48(s0)
    80005d18:	fffff097          	auipc	ra,0xfffff
    80005d1c:	99e080e7          	jalr	-1634(ra) # 800046b6 <fileclose>
    fileclose(wf);
    80005d20:	fc843503          	ld	a0,-56(s0)
    80005d24:	fffff097          	auipc	ra,0xfffff
    80005d28:	992080e7          	jalr	-1646(ra) # 800046b6 <fileclose>
    return -1;
    80005d2c:	57fd                	li	a5,-1
    80005d2e:	a03d                	j	80005d5c <sys_pipe+0x102>
    if(fd0 >= 0)
    80005d30:	fc442783          	lw	a5,-60(s0)
    80005d34:	0007c763          	bltz	a5,80005d42 <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005d38:	07e9                	addi	a5,a5,26
    80005d3a:	078e                	slli	a5,a5,0x3
    80005d3c:	94be                	add	s1,s1,a5
    80005d3e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d42:	fd043503          	ld	a0,-48(s0)
    80005d46:	fffff097          	auipc	ra,0xfffff
    80005d4a:	970080e7          	jalr	-1680(ra) # 800046b6 <fileclose>
    fileclose(wf);
    80005d4e:	fc843503          	ld	a0,-56(s0)
    80005d52:	fffff097          	auipc	ra,0xfffff
    80005d56:	964080e7          	jalr	-1692(ra) # 800046b6 <fileclose>
    return -1;
    80005d5a:	57fd                	li	a5,-1
}
    80005d5c:	853e                	mv	a0,a5
    80005d5e:	70e2                	ld	ra,56(sp)
    80005d60:	7442                	ld	s0,48(sp)
    80005d62:	74a2                	ld	s1,40(sp)
    80005d64:	6121                	addi	sp,sp,64
    80005d66:	8082                	ret

0000000080005d68 <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    80005d68:	1101                	addi	sp,sp,-32
    80005d6a:	ec06                	sd	ra,24(sp)
    80005d6c:	e822                	sd	s0,16(sp)
    80005d6e:	1000                	addi	s0,sp,32
  int ticks;
  uint64 handler;
  if(argint(0, &ticks) < 0)
    80005d70:	fec40593          	addi	a1,s0,-20
    80005d74:	4501                	li	a0,0
    80005d76:	ffffd097          	auipc	ra,0xffffd
    80005d7a:	eae080e7          	jalr	-338(ra) # 80002c24 <argint>
    return -1;
    80005d7e:	57fd                	li	a5,-1
  if(argint(0, &ticks) < 0)
    80005d80:	02054d63          	bltz	a0,80005dba <sys_sigalarm+0x52>
  if(argaddr(1, &handler) < 0)
    80005d84:	fe040593          	addi	a1,s0,-32
    80005d88:	4505                	li	a0,1
    80005d8a:	ffffd097          	auipc	ra,0xffffd
    80005d8e:	ebc080e7          	jalr	-324(ra) # 80002c46 <argaddr>
    return -1;
    80005d92:	57fd                	li	a5,-1
  if(argaddr(1, &handler) < 0)
    80005d94:	02054363          	bltz	a0,80005dba <sys_sigalarm+0x52>
  
  struct proc* p = myproc();
    80005d98:	ffffc097          	auipc	ra,0xffffc
    80005d9c:	d3c080e7          	jalr	-708(ra) # 80001ad4 <myproc>
  p->alarm = ticks;
    80005da0:	fec42783          	lw	a5,-20(s0)
    80005da4:	16f52623          	sw	a5,364(a0)
  p->handler = handler;
    80005da8:	fe043783          	ld	a5,-32(s0)
    80005dac:	16f53823          	sd	a5,368(a0)
  p->duration = 0;
    80005db0:	16052423          	sw	zero,360(a0)
  p->alarm_trapframe = 0;
    80005db4:	16053c23          	sd	zero,376(a0)
  return 0;
    80005db8:	4781                	li	a5,0
}
    80005dba:	853e                	mv	a0,a5
    80005dbc:	60e2                	ld	ra,24(sp)
    80005dbe:	6442                	ld	s0,16(sp)
    80005dc0:	6105                	addi	sp,sp,32
    80005dc2:	8082                	ret

0000000080005dc4 <sys_sigreturn>:

uint64
sys_sigreturn(void)
{
    80005dc4:	1101                	addi	sp,sp,-32
    80005dc6:	ec06                	sd	ra,24(sp)
    80005dc8:	e822                	sd	s0,16(sp)
    80005dca:	e426                	sd	s1,8(sp)
    80005dcc:	1000                	addi	s0,sp,32
  struct proc* p = myproc();
    80005dce:	ffffc097          	auipc	ra,0xffffc
    80005dd2:	d06080e7          	jalr	-762(ra) # 80001ad4 <myproc>
  if(p->alarm_trapframe != 0){
    80005dd6:	17853583          	ld	a1,376(a0)
    80005dda:	c18d                	beqz	a1,80005dfc <sys_sigreturn+0x38>
    80005ddc:	84aa                	mv	s1,a0
    memmove(p->trapframe, p->alarm_trapframe, 512);
    80005dde:	20000613          	li	a2,512
    80005de2:	6d28                	ld	a0,88(a0)
    80005de4:	ffffb097          	auipc	ra,0xffffb
    80005de8:	04a080e7          	jalr	74(ra) # 80000e2e <memmove>
    kfree(p->alarm_trapframe);
    80005dec:	1784b503          	ld	a0,376(s1)
    80005df0:	ffffb097          	auipc	ra,0xffffb
    80005df4:	ce6080e7          	jalr	-794(ra) # 80000ad6 <kfree>
    p->alarm_trapframe = 0;
    80005df8:	1604bc23          	sd	zero,376(s1)
  }
  return 0;
}
    80005dfc:	4501                	li	a0,0
    80005dfe:	60e2                	ld	ra,24(sp)
    80005e00:	6442                	ld	s0,16(sp)
    80005e02:	64a2                	ld	s1,8(sp)
    80005e04:	6105                	addi	sp,sp,32
    80005e06:	8082                	ret
	...

0000000080005e10 <kernelvec>:
    80005e10:	7111                	addi	sp,sp,-256
    80005e12:	e006                	sd	ra,0(sp)
    80005e14:	e40a                	sd	sp,8(sp)
    80005e16:	e80e                	sd	gp,16(sp)
    80005e18:	ec12                	sd	tp,24(sp)
    80005e1a:	f016                	sd	t0,32(sp)
    80005e1c:	f41a                	sd	t1,40(sp)
    80005e1e:	f81e                	sd	t2,48(sp)
    80005e20:	fc22                	sd	s0,56(sp)
    80005e22:	e0a6                	sd	s1,64(sp)
    80005e24:	e4aa                	sd	a0,72(sp)
    80005e26:	e8ae                	sd	a1,80(sp)
    80005e28:	ecb2                	sd	a2,88(sp)
    80005e2a:	f0b6                	sd	a3,96(sp)
    80005e2c:	f4ba                	sd	a4,104(sp)
    80005e2e:	f8be                	sd	a5,112(sp)
    80005e30:	fcc2                	sd	a6,120(sp)
    80005e32:	e146                	sd	a7,128(sp)
    80005e34:	e54a                	sd	s2,136(sp)
    80005e36:	e94e                	sd	s3,144(sp)
    80005e38:	ed52                	sd	s4,152(sp)
    80005e3a:	f156                	sd	s5,160(sp)
    80005e3c:	f55a                	sd	s6,168(sp)
    80005e3e:	f95e                	sd	s7,176(sp)
    80005e40:	fd62                	sd	s8,184(sp)
    80005e42:	e1e6                	sd	s9,192(sp)
    80005e44:	e5ea                	sd	s10,200(sp)
    80005e46:	e9ee                	sd	s11,208(sp)
    80005e48:	edf2                	sd	t3,216(sp)
    80005e4a:	f1f6                	sd	t4,224(sp)
    80005e4c:	f5fa                	sd	t5,232(sp)
    80005e4e:	f9fe                	sd	t6,240(sp)
    80005e50:	c01fc0ef          	jal	ra,80002a50 <kerneltrap>
    80005e54:	6082                	ld	ra,0(sp)
    80005e56:	6122                	ld	sp,8(sp)
    80005e58:	61c2                	ld	gp,16(sp)
    80005e5a:	7282                	ld	t0,32(sp)
    80005e5c:	7322                	ld	t1,40(sp)
    80005e5e:	73c2                	ld	t2,48(sp)
    80005e60:	7462                	ld	s0,56(sp)
    80005e62:	6486                	ld	s1,64(sp)
    80005e64:	6526                	ld	a0,72(sp)
    80005e66:	65c6                	ld	a1,80(sp)
    80005e68:	6666                	ld	a2,88(sp)
    80005e6a:	7686                	ld	a3,96(sp)
    80005e6c:	7726                	ld	a4,104(sp)
    80005e6e:	77c6                	ld	a5,112(sp)
    80005e70:	7866                	ld	a6,120(sp)
    80005e72:	688a                	ld	a7,128(sp)
    80005e74:	692a                	ld	s2,136(sp)
    80005e76:	69ca                	ld	s3,144(sp)
    80005e78:	6a6a                	ld	s4,152(sp)
    80005e7a:	7a8a                	ld	s5,160(sp)
    80005e7c:	7b2a                	ld	s6,168(sp)
    80005e7e:	7bca                	ld	s7,176(sp)
    80005e80:	7c6a                	ld	s8,184(sp)
    80005e82:	6c8e                	ld	s9,192(sp)
    80005e84:	6d2e                	ld	s10,200(sp)
    80005e86:	6dce                	ld	s11,208(sp)
    80005e88:	6e6e                	ld	t3,216(sp)
    80005e8a:	7e8e                	ld	t4,224(sp)
    80005e8c:	7f2e                	ld	t5,232(sp)
    80005e8e:	7fce                	ld	t6,240(sp)
    80005e90:	6111                	addi	sp,sp,256
    80005e92:	10200073          	sret
    80005e96:	00000013          	nop
    80005e9a:	00000013          	nop
    80005e9e:	0001                	nop

0000000080005ea0 <timervec>:
    80005ea0:	34051573          	csrrw	a0,mscratch,a0
    80005ea4:	e10c                	sd	a1,0(a0)
    80005ea6:	e510                	sd	a2,8(a0)
    80005ea8:	e914                	sd	a3,16(a0)
    80005eaa:	710c                	ld	a1,32(a0)
    80005eac:	7510                	ld	a2,40(a0)
    80005eae:	6194                	ld	a3,0(a1)
    80005eb0:	96b2                	add	a3,a3,a2
    80005eb2:	e194                	sd	a3,0(a1)
    80005eb4:	4589                	li	a1,2
    80005eb6:	14459073          	csrw	sip,a1
    80005eba:	6914                	ld	a3,16(a0)
    80005ebc:	6510                	ld	a2,8(a0)
    80005ebe:	610c                	ld	a1,0(a0)
    80005ec0:	34051573          	csrrw	a0,mscratch,a0
    80005ec4:	30200073          	mret
	...

0000000080005eca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eca:	1141                	addi	sp,sp,-16
    80005ecc:	e422                	sd	s0,8(sp)
    80005ece:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ed0:	0c0007b7          	lui	a5,0xc000
    80005ed4:	4705                	li	a4,1
    80005ed6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ed8:	c3d8                	sw	a4,4(a5)
}
    80005eda:	6422                	ld	s0,8(sp)
    80005edc:	0141                	addi	sp,sp,16
    80005ede:	8082                	ret

0000000080005ee0 <plicinithart>:

void
plicinithart(void)
{
    80005ee0:	1141                	addi	sp,sp,-16
    80005ee2:	e406                	sd	ra,8(sp)
    80005ee4:	e022                	sd	s0,0(sp)
    80005ee6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ee8:	ffffc097          	auipc	ra,0xffffc
    80005eec:	bc0080e7          	jalr	-1088(ra) # 80001aa8 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ef0:	0085171b          	slliw	a4,a0,0x8
    80005ef4:	0c0027b7          	lui	a5,0xc002
    80005ef8:	97ba                	add	a5,a5,a4
    80005efa:	40200713          	li	a4,1026
    80005efe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f02:	00d5151b          	slliw	a0,a0,0xd
    80005f06:	0c2017b7          	lui	a5,0xc201
    80005f0a:	953e                	add	a0,a0,a5
    80005f0c:	00052023          	sw	zero,0(a0)
}
    80005f10:	60a2                	ld	ra,8(sp)
    80005f12:	6402                	ld	s0,0(sp)
    80005f14:	0141                	addi	sp,sp,16
    80005f16:	8082                	ret

0000000080005f18 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f18:	1141                	addi	sp,sp,-16
    80005f1a:	e406                	sd	ra,8(sp)
    80005f1c:	e022                	sd	s0,0(sp)
    80005f1e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f20:	ffffc097          	auipc	ra,0xffffc
    80005f24:	b88080e7          	jalr	-1144(ra) # 80001aa8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f28:	00d5151b          	slliw	a0,a0,0xd
    80005f2c:	0c2017b7          	lui	a5,0xc201
    80005f30:	97aa                	add	a5,a5,a0
  return irq;
}
    80005f32:	43c8                	lw	a0,4(a5)
    80005f34:	60a2                	ld	ra,8(sp)
    80005f36:	6402                	ld	s0,0(sp)
    80005f38:	0141                	addi	sp,sp,16
    80005f3a:	8082                	ret

0000000080005f3c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f3c:	1101                	addi	sp,sp,-32
    80005f3e:	ec06                	sd	ra,24(sp)
    80005f40:	e822                	sd	s0,16(sp)
    80005f42:	e426                	sd	s1,8(sp)
    80005f44:	1000                	addi	s0,sp,32
    80005f46:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f48:	ffffc097          	auipc	ra,0xffffc
    80005f4c:	b60080e7          	jalr	-1184(ra) # 80001aa8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f50:	00d5151b          	slliw	a0,a0,0xd
    80005f54:	0c2017b7          	lui	a5,0xc201
    80005f58:	97aa                	add	a5,a5,a0
    80005f5a:	c3c4                	sw	s1,4(a5)
}
    80005f5c:	60e2                	ld	ra,24(sp)
    80005f5e:	6442                	ld	s0,16(sp)
    80005f60:	64a2                	ld	s1,8(sp)
    80005f62:	6105                	addi	sp,sp,32
    80005f64:	8082                	ret

0000000080005f66 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f66:	1141                	addi	sp,sp,-16
    80005f68:	e406                	sd	ra,8(sp)
    80005f6a:	e022                	sd	s0,0(sp)
    80005f6c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f6e:	479d                	li	a5,7
    80005f70:	04a7cd63          	blt	a5,a0,80005fca <free_desc+0x64>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005f74:	0001e797          	auipc	a5,0x1e
    80005f78:	08c78793          	addi	a5,a5,140 # 80024000 <disk>
    80005f7c:	00a78733          	add	a4,a5,a0
    80005f80:	6789                	lui	a5,0x2
    80005f82:	97ba                	add	a5,a5,a4
    80005f84:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005f88:	eba9                	bnez	a5,80005fda <free_desc+0x74>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005f8a:	00020797          	auipc	a5,0x20
    80005f8e:	07678793          	addi	a5,a5,118 # 80026000 <disk+0x2000>
    80005f92:	639c                	ld	a5,0(a5)
    80005f94:	00451713          	slli	a4,a0,0x4
    80005f98:	97ba                	add	a5,a5,a4
    80005f9a:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005f9e:	0001e797          	auipc	a5,0x1e
    80005fa2:	06278793          	addi	a5,a5,98 # 80024000 <disk>
    80005fa6:	97aa                	add	a5,a5,a0
    80005fa8:	6509                	lui	a0,0x2
    80005faa:	953e                	add	a0,a0,a5
    80005fac:	4785                	li	a5,1
    80005fae:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005fb2:	00020517          	auipc	a0,0x20
    80005fb6:	06650513          	addi	a0,a0,102 # 80026018 <disk+0x2018>
    80005fba:	ffffc097          	auipc	ra,0xffffc
    80005fbe:	4e0080e7          	jalr	1248(ra) # 8000249a <wakeup>
}
    80005fc2:	60a2                	ld	ra,8(sp)
    80005fc4:	6402                	ld	s0,0(sp)
    80005fc6:	0141                	addi	sp,sp,16
    80005fc8:	8082                	ret
    panic("virtio_disk_intr 1");
    80005fca:	00002517          	auipc	a0,0x2
    80005fce:	7b650513          	addi	a0,a0,1974 # 80008780 <syscalls+0x368>
    80005fd2:	ffffa097          	auipc	ra,0xffffa
    80005fd6:	630080e7          	jalr	1584(ra) # 80000602 <panic>
    panic("virtio_disk_intr 2");
    80005fda:	00002517          	auipc	a0,0x2
    80005fde:	7be50513          	addi	a0,a0,1982 # 80008798 <syscalls+0x380>
    80005fe2:	ffffa097          	auipc	ra,0xffffa
    80005fe6:	620080e7          	jalr	1568(ra) # 80000602 <panic>

0000000080005fea <virtio_disk_init>:
{
    80005fea:	1101                	addi	sp,sp,-32
    80005fec:	ec06                	sd	ra,24(sp)
    80005fee:	e822                	sd	s0,16(sp)
    80005ff0:	e426                	sd	s1,8(sp)
    80005ff2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ff4:	00002597          	auipc	a1,0x2
    80005ff8:	7bc58593          	addi	a1,a1,1980 # 800087b0 <syscalls+0x398>
    80005ffc:	00020517          	auipc	a0,0x20
    80006000:	0ac50513          	addi	a0,a0,172 # 800260a8 <disk+0x20a8>
    80006004:	ffffb097          	auipc	ra,0xffffb
    80006008:	c32080e7          	jalr	-974(ra) # 80000c36 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000600c:	100017b7          	lui	a5,0x10001
    80006010:	4398                	lw	a4,0(a5)
    80006012:	2701                	sext.w	a4,a4
    80006014:	747277b7          	lui	a5,0x74727
    80006018:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000601c:	0ef71163          	bne	a4,a5,800060fe <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006020:	100017b7          	lui	a5,0x10001
    80006024:	43dc                	lw	a5,4(a5)
    80006026:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006028:	4705                	li	a4,1
    8000602a:	0ce79a63          	bne	a5,a4,800060fe <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000602e:	100017b7          	lui	a5,0x10001
    80006032:	479c                	lw	a5,8(a5)
    80006034:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006036:	4709                	li	a4,2
    80006038:	0ce79363          	bne	a5,a4,800060fe <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000603c:	100017b7          	lui	a5,0x10001
    80006040:	47d8                	lw	a4,12(a5)
    80006042:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006044:	554d47b7          	lui	a5,0x554d4
    80006048:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000604c:	0af71963          	bne	a4,a5,800060fe <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006050:	100017b7          	lui	a5,0x10001
    80006054:	4705                	li	a4,1
    80006056:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006058:	470d                	li	a4,3
    8000605a:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000605c:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000605e:	c7ffe737          	lui	a4,0xc7ffe
    80006062:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd775f>
    80006066:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006068:	2701                	sext.w	a4,a4
    8000606a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000606c:	472d                	li	a4,11
    8000606e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006070:	473d                	li	a4,15
    80006072:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006074:	6705                	lui	a4,0x1
    80006076:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006078:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000607c:	5bdc                	lw	a5,52(a5)
    8000607e:	2781                	sext.w	a5,a5
  if(max == 0)
    80006080:	c7d9                	beqz	a5,8000610e <virtio_disk_init+0x124>
  if(max < NUM)
    80006082:	471d                	li	a4,7
    80006084:	08f77d63          	bleu	a5,a4,8000611e <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006088:	100014b7          	lui	s1,0x10001
    8000608c:	47a1                	li	a5,8
    8000608e:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006090:	6609                	lui	a2,0x2
    80006092:	4581                	li	a1,0
    80006094:	0001e517          	auipc	a0,0x1e
    80006098:	f6c50513          	addi	a0,a0,-148 # 80024000 <disk>
    8000609c:	ffffb097          	auipc	ra,0xffffb
    800060a0:	d26080e7          	jalr	-730(ra) # 80000dc2 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800060a4:	0001e717          	auipc	a4,0x1e
    800060a8:	f5c70713          	addi	a4,a4,-164 # 80024000 <disk>
    800060ac:	00c75793          	srli	a5,a4,0xc
    800060b0:	2781                	sext.w	a5,a5
    800060b2:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    800060b4:	00020797          	auipc	a5,0x20
    800060b8:	f4c78793          	addi	a5,a5,-180 # 80026000 <disk+0x2000>
    800060bc:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    800060be:	0001e717          	auipc	a4,0x1e
    800060c2:	fc270713          	addi	a4,a4,-62 # 80024080 <disk+0x80>
    800060c6:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    800060c8:	0001f717          	auipc	a4,0x1f
    800060cc:	f3870713          	addi	a4,a4,-200 # 80025000 <disk+0x1000>
    800060d0:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800060d2:	4705                	li	a4,1
    800060d4:	00e78c23          	sb	a4,24(a5)
    800060d8:	00e78ca3          	sb	a4,25(a5)
    800060dc:	00e78d23          	sb	a4,26(a5)
    800060e0:	00e78da3          	sb	a4,27(a5)
    800060e4:	00e78e23          	sb	a4,28(a5)
    800060e8:	00e78ea3          	sb	a4,29(a5)
    800060ec:	00e78f23          	sb	a4,30(a5)
    800060f0:	00e78fa3          	sb	a4,31(a5)
}
    800060f4:	60e2                	ld	ra,24(sp)
    800060f6:	6442                	ld	s0,16(sp)
    800060f8:	64a2                	ld	s1,8(sp)
    800060fa:	6105                	addi	sp,sp,32
    800060fc:	8082                	ret
    panic("could not find virtio disk");
    800060fe:	00002517          	auipc	a0,0x2
    80006102:	6c250513          	addi	a0,a0,1730 # 800087c0 <syscalls+0x3a8>
    80006106:	ffffa097          	auipc	ra,0xffffa
    8000610a:	4fc080e7          	jalr	1276(ra) # 80000602 <panic>
    panic("virtio disk has no queue 0");
    8000610e:	00002517          	auipc	a0,0x2
    80006112:	6d250513          	addi	a0,a0,1746 # 800087e0 <syscalls+0x3c8>
    80006116:	ffffa097          	auipc	ra,0xffffa
    8000611a:	4ec080e7          	jalr	1260(ra) # 80000602 <panic>
    panic("virtio disk max queue too short");
    8000611e:	00002517          	auipc	a0,0x2
    80006122:	6e250513          	addi	a0,a0,1762 # 80008800 <syscalls+0x3e8>
    80006126:	ffffa097          	auipc	ra,0xffffa
    8000612a:	4dc080e7          	jalr	1244(ra) # 80000602 <panic>

000000008000612e <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000612e:	7159                	addi	sp,sp,-112
    80006130:	f486                	sd	ra,104(sp)
    80006132:	f0a2                	sd	s0,96(sp)
    80006134:	eca6                	sd	s1,88(sp)
    80006136:	e8ca                	sd	s2,80(sp)
    80006138:	e4ce                	sd	s3,72(sp)
    8000613a:	e0d2                	sd	s4,64(sp)
    8000613c:	fc56                	sd	s5,56(sp)
    8000613e:	f85a                	sd	s6,48(sp)
    80006140:	f45e                	sd	s7,40(sp)
    80006142:	f062                	sd	s8,32(sp)
    80006144:	1880                	addi	s0,sp,112
    80006146:	892a                	mv	s2,a0
    80006148:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000614a:	00c52b83          	lw	s7,12(a0)
    8000614e:	001b9b9b          	slliw	s7,s7,0x1
    80006152:	1b82                	slli	s7,s7,0x20
    80006154:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80006158:	00020517          	auipc	a0,0x20
    8000615c:	f5050513          	addi	a0,a0,-176 # 800260a8 <disk+0x20a8>
    80006160:	ffffb097          	auipc	ra,0xffffb
    80006164:	b66080e7          	jalr	-1178(ra) # 80000cc6 <acquire>
    if(disk.free[i]){
    80006168:	00020997          	auipc	s3,0x20
    8000616c:	e9898993          	addi	s3,s3,-360 # 80026000 <disk+0x2000>
  for(int i = 0; i < NUM; i++){
    80006170:	4b21                	li	s6,8
      disk.free[i] = 0;
    80006172:	0001ea97          	auipc	s5,0x1e
    80006176:	e8ea8a93          	addi	s5,s5,-370 # 80024000 <disk>
  for(int i = 0; i < 3; i++){
    8000617a:	4a0d                	li	s4,3
    8000617c:	a079                	j	8000620a <virtio_disk_rw+0xdc>
      disk.free[i] = 0;
    8000617e:	00fa86b3          	add	a3,s5,a5
    80006182:	96ae                	add	a3,a3,a1
    80006184:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006188:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000618a:	0207ca63          	bltz	a5,800061be <virtio_disk_rw+0x90>
  for(int i = 0; i < 3; i++){
    8000618e:	2485                	addiw	s1,s1,1
    80006190:	0711                	addi	a4,a4,4
    80006192:	25448163          	beq	s1,s4,800063d4 <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80006196:	863a                	mv	a2,a4
    if(disk.free[i]){
    80006198:	0189c783          	lbu	a5,24(s3)
    8000619c:	24079163          	bnez	a5,800063de <virtio_disk_rw+0x2b0>
    800061a0:	00020697          	auipc	a3,0x20
    800061a4:	e7968693          	addi	a3,a3,-391 # 80026019 <disk+0x2019>
  for(int i = 0; i < NUM; i++){
    800061a8:	87aa                	mv	a5,a0
    if(disk.free[i]){
    800061aa:	0006c803          	lbu	a6,0(a3)
    800061ae:	fc0818e3          	bnez	a6,8000617e <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800061b2:	2785                	addiw	a5,a5,1
    800061b4:	0685                	addi	a3,a3,1
    800061b6:	ff679ae3          	bne	a5,s6,800061aa <virtio_disk_rw+0x7c>
    idx[i] = alloc_desc();
    800061ba:	57fd                	li	a5,-1
    800061bc:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800061be:	02905a63          	blez	s1,800061f2 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800061c2:	fa042503          	lw	a0,-96(s0)
    800061c6:	00000097          	auipc	ra,0x0
    800061ca:	da0080e7          	jalr	-608(ra) # 80005f66 <free_desc>
      for(int j = 0; j < i; j++)
    800061ce:	4785                	li	a5,1
    800061d0:	0297d163          	ble	s1,a5,800061f2 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800061d4:	fa442503          	lw	a0,-92(s0)
    800061d8:	00000097          	auipc	ra,0x0
    800061dc:	d8e080e7          	jalr	-626(ra) # 80005f66 <free_desc>
      for(int j = 0; j < i; j++)
    800061e0:	4789                	li	a5,2
    800061e2:	0097d863          	ble	s1,a5,800061f2 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800061e6:	fa842503          	lw	a0,-88(s0)
    800061ea:	00000097          	auipc	ra,0x0
    800061ee:	d7c080e7          	jalr	-644(ra) # 80005f66 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061f2:	00020597          	auipc	a1,0x20
    800061f6:	eb658593          	addi	a1,a1,-330 # 800260a8 <disk+0x20a8>
    800061fa:	00020517          	auipc	a0,0x20
    800061fe:	e1e50513          	addi	a0,a0,-482 # 80026018 <disk+0x2018>
    80006202:	ffffc097          	auipc	ra,0xffffc
    80006206:	112080e7          	jalr	274(ra) # 80002314 <sleep>
  for(int i = 0; i < 3; i++){
    8000620a:	fa040713          	addi	a4,s0,-96
    8000620e:	4481                	li	s1,0
  for(int i = 0; i < NUM; i++){
    80006210:	4505                	li	a0,1
      disk.free[i] = 0;
    80006212:	6589                	lui	a1,0x2
    80006214:	b749                	j	80006196 <virtio_disk_rw+0x68>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    80006216:	4785                	li	a5,1
    80006218:	f8f42823          	sw	a5,-112(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    8000621c:	f8042a23          	sw	zero,-108(s0)
  buf0.sector = sector;
    80006220:	f9743c23          	sd	s7,-104(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006224:	fa042983          	lw	s3,-96(s0)
    80006228:	00499493          	slli	s1,s3,0x4
    8000622c:	00020a17          	auipc	s4,0x20
    80006230:	dd4a0a13          	addi	s4,s4,-556 # 80026000 <disk+0x2000>
    80006234:	000a3a83          	ld	s5,0(s4)
    80006238:	9aa6                	add	s5,s5,s1
    8000623a:	f9040513          	addi	a0,s0,-112
    8000623e:	ffffb097          	auipc	ra,0xffffb
    80006242:	f7c080e7          	jalr	-132(ra) # 800011ba <kvmpa>
    80006246:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    8000624a:	000a3783          	ld	a5,0(s4)
    8000624e:	97a6                	add	a5,a5,s1
    80006250:	4741                	li	a4,16
    80006252:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006254:	000a3783          	ld	a5,0(s4)
    80006258:	97a6                	add	a5,a5,s1
    8000625a:	4705                	li	a4,1
    8000625c:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80006260:	fa442703          	lw	a4,-92(s0)
    80006264:	000a3783          	ld	a5,0(s4)
    80006268:	97a6                	add	a5,a5,s1
    8000626a:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000626e:	0712                	slli	a4,a4,0x4
    80006270:	000a3783          	ld	a5,0(s4)
    80006274:	97ba                	add	a5,a5,a4
    80006276:	05890693          	addi	a3,s2,88
    8000627a:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    8000627c:	000a3783          	ld	a5,0(s4)
    80006280:	97ba                	add	a5,a5,a4
    80006282:	40000693          	li	a3,1024
    80006286:	c794                	sw	a3,8(a5)
  if(write)
    80006288:	100c0863          	beqz	s8,80006398 <virtio_disk_rw+0x26a>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000628c:	000a3783          	ld	a5,0(s4)
    80006290:	97ba                	add	a5,a5,a4
    80006292:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006296:	0001e517          	auipc	a0,0x1e
    8000629a:	d6a50513          	addi	a0,a0,-662 # 80024000 <disk>
    8000629e:	00020797          	auipc	a5,0x20
    800062a2:	d6278793          	addi	a5,a5,-670 # 80026000 <disk+0x2000>
    800062a6:	6394                	ld	a3,0(a5)
    800062a8:	96ba                	add	a3,a3,a4
    800062aa:	00c6d603          	lhu	a2,12(a3)
    800062ae:	00166613          	ori	a2,a2,1
    800062b2:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800062b6:	fa842683          	lw	a3,-88(s0)
    800062ba:	6390                	ld	a2,0(a5)
    800062bc:	9732                	add	a4,a4,a2
    800062be:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    800062c2:	20098613          	addi	a2,s3,512
    800062c6:	0612                	slli	a2,a2,0x4
    800062c8:	962a                	add	a2,a2,a0
    800062ca:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800062ce:	00469713          	slli	a4,a3,0x4
    800062d2:	6394                	ld	a3,0(a5)
    800062d4:	96ba                	add	a3,a3,a4
    800062d6:	6589                	lui	a1,0x2
    800062d8:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    800062dc:	94ae                	add	s1,s1,a1
    800062de:	94aa                	add	s1,s1,a0
    800062e0:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    800062e2:	6394                	ld	a3,0(a5)
    800062e4:	96ba                	add	a3,a3,a4
    800062e6:	4585                	li	a1,1
    800062e8:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800062ea:	6394                	ld	a3,0(a5)
    800062ec:	96ba                	add	a3,a3,a4
    800062ee:	4509                	li	a0,2
    800062f0:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    800062f4:	6394                	ld	a3,0(a5)
    800062f6:	9736                	add	a4,a4,a3
    800062f8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062fc:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006300:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    80006304:	6794                	ld	a3,8(a5)
    80006306:	0026d703          	lhu	a4,2(a3)
    8000630a:	8b1d                	andi	a4,a4,7
    8000630c:	2709                	addiw	a4,a4,2
    8000630e:	0706                	slli	a4,a4,0x1
    80006310:	9736                	add	a4,a4,a3
    80006312:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    80006316:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    8000631a:	6798                	ld	a4,8(a5)
    8000631c:	00275783          	lhu	a5,2(a4)
    80006320:	2785                	addiw	a5,a5,1
    80006322:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006326:	100017b7          	lui	a5,0x10001
    8000632a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000632e:	00492703          	lw	a4,4(s2)
    80006332:	4785                	li	a5,1
    80006334:	02f71163          	bne	a4,a5,80006356 <virtio_disk_rw+0x228>
    sleep(b, &disk.vdisk_lock);
    80006338:	00020997          	auipc	s3,0x20
    8000633c:	d7098993          	addi	s3,s3,-656 # 800260a8 <disk+0x20a8>
  while(b->disk == 1) {
    80006340:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006342:	85ce                	mv	a1,s3
    80006344:	854a                	mv	a0,s2
    80006346:	ffffc097          	auipc	ra,0xffffc
    8000634a:	fce080e7          	jalr	-50(ra) # 80002314 <sleep>
  while(b->disk == 1) {
    8000634e:	00492783          	lw	a5,4(s2)
    80006352:	fe9788e3          	beq	a5,s1,80006342 <virtio_disk_rw+0x214>
  }

  disk.info[idx[0]].b = 0;
    80006356:	fa042483          	lw	s1,-96(s0)
    8000635a:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    8000635e:	00479713          	slli	a4,a5,0x4
    80006362:	0001e797          	auipc	a5,0x1e
    80006366:	c9e78793          	addi	a5,a5,-866 # 80024000 <disk>
    8000636a:	97ba                	add	a5,a5,a4
    8000636c:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006370:	00020917          	auipc	s2,0x20
    80006374:	c9090913          	addi	s2,s2,-880 # 80026000 <disk+0x2000>
    free_desc(i);
    80006378:	8526                	mv	a0,s1
    8000637a:	00000097          	auipc	ra,0x0
    8000637e:	bec080e7          	jalr	-1044(ra) # 80005f66 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006382:	0492                	slli	s1,s1,0x4
    80006384:	00093783          	ld	a5,0(s2)
    80006388:	94be                	add	s1,s1,a5
    8000638a:	00c4d783          	lhu	a5,12(s1)
    8000638e:	8b85                	andi	a5,a5,1
    80006390:	cf91                	beqz	a5,800063ac <virtio_disk_rw+0x27e>
      i = disk.desc[i].next;
    80006392:	00e4d483          	lhu	s1,14(s1)
  while(1){
    80006396:	b7cd                	j	80006378 <virtio_disk_rw+0x24a>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006398:	00020797          	auipc	a5,0x20
    8000639c:	c6878793          	addi	a5,a5,-920 # 80026000 <disk+0x2000>
    800063a0:	639c                	ld	a5,0(a5)
    800063a2:	97ba                	add	a5,a5,a4
    800063a4:	4689                	li	a3,2
    800063a6:	00d79623          	sh	a3,12(a5)
    800063aa:	b5f5                	j	80006296 <virtio_disk_rw+0x168>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063ac:	00020517          	auipc	a0,0x20
    800063b0:	cfc50513          	addi	a0,a0,-772 # 800260a8 <disk+0x20a8>
    800063b4:	ffffb097          	auipc	ra,0xffffb
    800063b8:	9c6080e7          	jalr	-1594(ra) # 80000d7a <release>
}
    800063bc:	70a6                	ld	ra,104(sp)
    800063be:	7406                	ld	s0,96(sp)
    800063c0:	64e6                	ld	s1,88(sp)
    800063c2:	6946                	ld	s2,80(sp)
    800063c4:	69a6                	ld	s3,72(sp)
    800063c6:	6a06                	ld	s4,64(sp)
    800063c8:	7ae2                	ld	s5,56(sp)
    800063ca:	7b42                	ld	s6,48(sp)
    800063cc:	7ba2                	ld	s7,40(sp)
    800063ce:	7c02                	ld	s8,32(sp)
    800063d0:	6165                	addi	sp,sp,112
    800063d2:	8082                	ret
  if(write)
    800063d4:	e40c11e3          	bnez	s8,80006216 <virtio_disk_rw+0xe8>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    800063d8:	f8042823          	sw	zero,-112(s0)
    800063dc:	b581                	j	8000621c <virtio_disk_rw+0xee>
      disk.free[i] = 0;
    800063de:	00098c23          	sb	zero,24(s3)
    idx[i] = alloc_desc();
    800063e2:	00072023          	sw	zero,0(a4)
    if(idx[i] < 0){
    800063e6:	b365                	j	8000618e <virtio_disk_rw+0x60>

00000000800063e8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800063e8:	1101                	addi	sp,sp,-32
    800063ea:	ec06                	sd	ra,24(sp)
    800063ec:	e822                	sd	s0,16(sp)
    800063ee:	e426                	sd	s1,8(sp)
    800063f0:	e04a                	sd	s2,0(sp)
    800063f2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800063f4:	00020517          	auipc	a0,0x20
    800063f8:	cb450513          	addi	a0,a0,-844 # 800260a8 <disk+0x20a8>
    800063fc:	ffffb097          	auipc	ra,0xffffb
    80006400:	8ca080e7          	jalr	-1846(ra) # 80000cc6 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006404:	00020797          	auipc	a5,0x20
    80006408:	bfc78793          	addi	a5,a5,-1028 # 80026000 <disk+0x2000>
    8000640c:	0207d683          	lhu	a3,32(a5)
    80006410:	6b98                	ld	a4,16(a5)
    80006412:	00275783          	lhu	a5,2(a4)
    80006416:	8fb5                	xor	a5,a5,a3
    80006418:	8b9d                	andi	a5,a5,7
    8000641a:	c7c9                	beqz	a5,800064a4 <virtio_disk_intr+0xbc>
    int id = disk.used->elems[disk.used_idx].id;
    8000641c:	068e                	slli	a3,a3,0x3
    8000641e:	9736                	add	a4,a4,a3
    80006420:	435c                	lw	a5,4(a4)

    if(disk.info[id].status != 0)
    80006422:	20078713          	addi	a4,a5,512
    80006426:	00471693          	slli	a3,a4,0x4
    8000642a:	0001e717          	auipc	a4,0x1e
    8000642e:	bd670713          	addi	a4,a4,-1066 # 80024000 <disk>
    80006432:	9736                	add	a4,a4,a3
    80006434:	03074703          	lbu	a4,48(a4)
    80006438:	ef31                	bnez	a4,80006494 <virtio_disk_intr+0xac>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000643a:	0001e917          	auipc	s2,0x1e
    8000643e:	bc690913          	addi	s2,s2,-1082 # 80024000 <disk>
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006442:	00020497          	auipc	s1,0x20
    80006446:	bbe48493          	addi	s1,s1,-1090 # 80026000 <disk+0x2000>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000644a:	20078793          	addi	a5,a5,512
    8000644e:	0792                	slli	a5,a5,0x4
    80006450:	97ca                	add	a5,a5,s2
    80006452:	7798                	ld	a4,40(a5)
    80006454:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    80006458:	7788                	ld	a0,40(a5)
    8000645a:	ffffc097          	auipc	ra,0xffffc
    8000645e:	040080e7          	jalr	64(ra) # 8000249a <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006462:	0204d783          	lhu	a5,32(s1)
    80006466:	2785                	addiw	a5,a5,1
    80006468:	8b9d                	andi	a5,a5,7
    8000646a:	03079613          	slli	a2,a5,0x30
    8000646e:	9241                	srli	a2,a2,0x30
    80006470:	02c49023          	sh	a2,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006474:	6898                	ld	a4,16(s1)
    80006476:	00275683          	lhu	a3,2(a4)
    8000647a:	8a9d                	andi	a3,a3,7
    8000647c:	02c68463          	beq	a3,a2,800064a4 <virtio_disk_intr+0xbc>
    int id = disk.used->elems[disk.used_idx].id;
    80006480:	078e                	slli	a5,a5,0x3
    80006482:	97ba                	add	a5,a5,a4
    80006484:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006486:	20078713          	addi	a4,a5,512
    8000648a:	0712                	slli	a4,a4,0x4
    8000648c:	974a                	add	a4,a4,s2
    8000648e:	03074703          	lbu	a4,48(a4)
    80006492:	df45                	beqz	a4,8000644a <virtio_disk_intr+0x62>
      panic("virtio_disk_intr status");
    80006494:	00002517          	auipc	a0,0x2
    80006498:	38c50513          	addi	a0,a0,908 # 80008820 <syscalls+0x408>
    8000649c:	ffffa097          	auipc	ra,0xffffa
    800064a0:	166080e7          	jalr	358(ra) # 80000602 <panic>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800064a4:	10001737          	lui	a4,0x10001
    800064a8:	533c                	lw	a5,96(a4)
    800064aa:	8b8d                	andi	a5,a5,3
    800064ac:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    800064ae:	00020517          	auipc	a0,0x20
    800064b2:	bfa50513          	addi	a0,a0,-1030 # 800260a8 <disk+0x20a8>
    800064b6:	ffffb097          	auipc	ra,0xffffb
    800064ba:	8c4080e7          	jalr	-1852(ra) # 80000d7a <release>
}
    800064be:	60e2                	ld	ra,24(sp)
    800064c0:	6442                	ld	s0,16(sp)
    800064c2:	64a2                	ld	s1,8(sp)
    800064c4:	6902                	ld	s2,0(sp)
    800064c6:	6105                	addi	sp,sp,32
    800064c8:	8082                	ret
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
