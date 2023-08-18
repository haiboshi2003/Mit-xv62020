
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	9f013103          	ld	sp,-1552(sp) # 800089f0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000062:	e3278793          	addi	a5,a5,-462 # 80005e90 <timervec>
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
    80000096:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    8000009a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009c:	6705                	lui	a4,0x1
    8000009e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a4:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a8:	00001797          	auipc	a5,0x1
    800000ac:	ed478793          	addi	a5,a5,-300 # 80000f7c <main>
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
    80000112:	b9e080e7          	jalr	-1122(ra) # 80000cac <acquire>
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
    8000012c:	46c080e7          	jalr	1132(ra) # 80002594 <either_copyin>
    80000130:	01550c63          	beq	a0,s5,80000148 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000134:	fbf44503          	lbu	a0,-65(s0)
    80000138:	00000097          	auipc	ra,0x0
    8000013c:	7ee080e7          	jalr	2030(ra) # 80000926 <uartputc>
  for(i = 0; i < n; i++){
    80000140:	2485                	addiw	s1,s1,1
    80000142:	0905                	addi	s2,s2,1
    80000144:	fc999de3          	bne	s3,s1,8000011e <consolewrite+0x30>
  }
  release(&cons.lock);
    80000148:	00011517          	auipc	a0,0x11
    8000014c:	6e850513          	addi	a0,a0,1768 # 80011830 <cons>
    80000150:	00001097          	auipc	ra,0x1
    80000154:	c10080e7          	jalr	-1008(ra) # 80000d60 <release>

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
    800001a4:	b0c080e7          	jalr	-1268(ra) # 80000cac <acquire>
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
    800001d4:	8ea080e7          	jalr	-1814(ra) # 80001aba <myproc>
    800001d8:	591c                	lw	a5,48(a0)
    800001da:	eba5                	bnez	a5,8000024a <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001dc:	85ce                	mv	a1,s3
    800001de:	854a                	mv	a0,s2
    800001e0:	00002097          	auipc	ra,0x2
    800001e4:	0fc080e7          	jalr	252(ra) # 800022dc <sleep>
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
    80000220:	322080e7          	jalr	802(ra) # 8000253e <either_copyout>
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
    80000240:	b24080e7          	jalr	-1244(ra) # 80000d60 <release>

  return target - n;
    80000244:	414b053b          	subw	a0,s6,s4
    80000248:	a811                	j	8000025c <consoleread+0xec>
        release(&cons.lock);
    8000024a:	00011517          	auipc	a0,0x11
    8000024e:	5e650513          	addi	a0,a0,1510 # 80011830 <cons>
    80000252:	00001097          	auipc	ra,0x1
    80000256:	b0e080e7          	jalr	-1266(ra) # 80000d60 <release>
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
    800002a0:	58a080e7          	jalr	1418(ra) # 80000826 <uartputc_sync>
}
    800002a4:	60a2                	ld	ra,8(sp)
    800002a6:	6402                	ld	s0,0(sp)
    800002a8:	0141                	addi	sp,sp,16
    800002aa:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002ac:	4521                	li	a0,8
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	578080e7          	jalr	1400(ra) # 80000826 <uartputc_sync>
    800002b6:	02000513          	li	a0,32
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	56c080e7          	jalr	1388(ra) # 80000826 <uartputc_sync>
    800002c2:	4521                	li	a0,8
    800002c4:	00000097          	auipc	ra,0x0
    800002c8:	562080e7          	jalr	1378(ra) # 80000826 <uartputc_sync>
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
    800002e8:	9c8080e7          	jalr	-1592(ra) # 80000cac <acquire>

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
    8000041a:	1d4080e7          	jalr	468(ra) # 800025ea <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000041e:	00011517          	auipc	a0,0x11
    80000422:	41250513          	addi	a0,a0,1042 # 80011830 <cons>
    80000426:	00001097          	auipc	ra,0x1
    8000042a:	93a080e7          	jalr	-1734(ra) # 80000d60 <release>
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
    8000047c:	fea080e7          	jalr	-22(ra) # 80002462 <wakeup>
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
    8000049e:	782080e7          	jalr	1922(ra) # 80000c1c <initlock>

  uartinit();
    800004a2:	00000097          	auipc	ra,0x0
    800004a6:	334080e7          	jalr	820(ra) # 800007d6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004aa:	00021797          	auipc	a5,0x21
    800004ae:	70678793          	addi	a5,a5,1798 # 80021bb0 <devsw>
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

0000000080000574 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000574:	1101                	addi	sp,sp,-32
    80000576:	ec06                	sd	ra,24(sp)
    80000578:	e822                	sd	s0,16(sp)
    8000057a:	e426                	sd	s1,8(sp)
    8000057c:	1000                	addi	s0,sp,32
    8000057e:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000580:	00011797          	auipc	a5,0x11
    80000584:	3607a823          	sw	zero,880(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    80000588:	00008517          	auipc	a0,0x8
    8000058c:	aa850513          	addi	a0,a0,-1368 # 80008030 <digits+0x18>
    80000590:	00000097          	auipc	ra,0x0
    80000594:	02e080e7          	jalr	46(ra) # 800005be <printf>
  printf(s);
    80000598:	8526                	mv	a0,s1
    8000059a:	00000097          	auipc	ra,0x0
    8000059e:	024080e7          	jalr	36(ra) # 800005be <printf>
  printf("\n");
    800005a2:	00008517          	auipc	a0,0x8
    800005a6:	b2650513          	addi	a0,a0,-1242 # 800080c8 <digits+0xb0>
    800005aa:	00000097          	auipc	ra,0x0
    800005ae:	014080e7          	jalr	20(ra) # 800005be <printf>
  panicked = 1; // freeze uart output from other CPUs
    800005b2:	4785                	li	a5,1
    800005b4:	00009717          	auipc	a4,0x9
    800005b8:	a4f72623          	sw	a5,-1460(a4) # 80009000 <panicked>
  for(;;)
    800005bc:	a001                	j	800005bc <panic+0x48>

00000000800005be <printf>:
{
    800005be:	7131                	addi	sp,sp,-192
    800005c0:	fc86                	sd	ra,120(sp)
    800005c2:	f8a2                	sd	s0,112(sp)
    800005c4:	f4a6                	sd	s1,104(sp)
    800005c6:	f0ca                	sd	s2,96(sp)
    800005c8:	ecce                	sd	s3,88(sp)
    800005ca:	e8d2                	sd	s4,80(sp)
    800005cc:	e4d6                	sd	s5,72(sp)
    800005ce:	e0da                	sd	s6,64(sp)
    800005d0:	fc5e                	sd	s7,56(sp)
    800005d2:	f862                	sd	s8,48(sp)
    800005d4:	f466                	sd	s9,40(sp)
    800005d6:	f06a                	sd	s10,32(sp)
    800005d8:	ec6e                	sd	s11,24(sp)
    800005da:	0100                	addi	s0,sp,128
    800005dc:	8aaa                	mv	s5,a0
    800005de:	e40c                	sd	a1,8(s0)
    800005e0:	e810                	sd	a2,16(s0)
    800005e2:	ec14                	sd	a3,24(s0)
    800005e4:	f018                	sd	a4,32(s0)
    800005e6:	f41c                	sd	a5,40(s0)
    800005e8:	03043823          	sd	a6,48(s0)
    800005ec:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005f0:	00011797          	auipc	a5,0x11
    800005f4:	2e878793          	addi	a5,a5,744 # 800118d8 <pr>
    800005f8:	0187ad83          	lw	s11,24(a5)
  if(locking)
    800005fc:	020d9b63          	bnez	s11,80000632 <printf+0x74>
  if (fmt == 0)
    80000600:	020a8f63          	beqz	s5,8000063e <printf+0x80>
  va_start(ap, fmt);
    80000604:	00840793          	addi	a5,s0,8
    80000608:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000060c:	000ac503          	lbu	a0,0(s5)
    80000610:	16050063          	beqz	a0,80000770 <printf+0x1b2>
    80000614:	4481                	li	s1,0
    if(c != '%'){
    80000616:	02500a13          	li	s4,37
    switch(c){
    8000061a:	07000b13          	li	s6,112
  consputc('x');
    8000061e:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000620:	00008b97          	auipc	s7,0x8
    80000624:	9f8b8b93          	addi	s7,s7,-1544 # 80008018 <digits>
    switch(c){
    80000628:	07300c93          	li	s9,115
    8000062c:	06400c13          	li	s8,100
    80000630:	a815                	j	80000664 <printf+0xa6>
    acquire(&pr.lock);
    80000632:	853e                	mv	a0,a5
    80000634:	00000097          	auipc	ra,0x0
    80000638:	678080e7          	jalr	1656(ra) # 80000cac <acquire>
    8000063c:	b7d1                	j	80000600 <printf+0x42>
    panic("null fmt");
    8000063e:	00008517          	auipc	a0,0x8
    80000642:	a0250513          	addi	a0,a0,-1534 # 80008040 <digits+0x28>
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	f2e080e7          	jalr	-210(ra) # 80000574 <panic>
      consputc(c);
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	c3e080e7          	jalr	-962(ra) # 8000028c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000656:	2485                	addiw	s1,s1,1
    80000658:	009a87b3          	add	a5,s5,s1
    8000065c:	0007c503          	lbu	a0,0(a5)
    80000660:	10050863          	beqz	a0,80000770 <printf+0x1b2>
    if(c != '%'){
    80000664:	ff4515e3          	bne	a0,s4,8000064e <printf+0x90>
    c = fmt[++i] & 0xff;
    80000668:	2485                	addiw	s1,s1,1
    8000066a:	009a87b3          	add	a5,s5,s1
    8000066e:	0007c783          	lbu	a5,0(a5)
    80000672:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000676:	0e090d63          	beqz	s2,80000770 <printf+0x1b2>
    switch(c){
    8000067a:	05678a63          	beq	a5,s6,800006ce <printf+0x110>
    8000067e:	02fb7663          	bleu	a5,s6,800006aa <printf+0xec>
    80000682:	09978963          	beq	a5,s9,80000714 <printf+0x156>
    80000686:	07800713          	li	a4,120
    8000068a:	0ce79863          	bne	a5,a4,8000075a <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	addi	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	85ea                	mv	a1,s10
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e2e080e7          	jalr	-466(ra) # 800004ce <printint>
      break;
    800006a8:	b77d                	j	80000656 <printf+0x98>
    switch(c){
    800006aa:	0b478263          	beq	a5,s4,8000074e <printf+0x190>
    800006ae:	0b879663          	bne	a5,s8,8000075a <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4605                	li	a2,1
    800006c0:	45a9                	li	a1,10
    800006c2:	4388                	lw	a0,0(a5)
    800006c4:	00000097          	auipc	ra,0x0
    800006c8:	e0a080e7          	jalr	-502(ra) # 800004ce <printint>
      break;
    800006cc:	b769                	j	80000656 <printf+0x98>
      printptr(va_arg(ap, uint64));
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006de:	03000513          	li	a0,48
    800006e2:	00000097          	auipc	ra,0x0
    800006e6:	baa080e7          	jalr	-1110(ra) # 8000028c <consputc>
  consputc('x');
    800006ea:	07800513          	li	a0,120
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	b9e080e7          	jalr	-1122(ra) # 8000028c <consputc>
    800006f6:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f8:	03c9d793          	srli	a5,s3,0x3c
    800006fc:	97de                	add	a5,a5,s7
    800006fe:	0007c503          	lbu	a0,0(a5)
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b8a080e7          	jalr	-1142(ra) # 8000028c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070a:	0992                	slli	s3,s3,0x4
    8000070c:	397d                	addiw	s2,s2,-1
    8000070e:	fe0915e3          	bnez	s2,800006f8 <printf+0x13a>
    80000712:	b791                	j	80000656 <printf+0x98>
      if((s = va_arg(ap, char*)) == 0)
    80000714:	f8843783          	ld	a5,-120(s0)
    80000718:	00878713          	addi	a4,a5,8
    8000071c:	f8e43423          	sd	a4,-120(s0)
    80000720:	0007b903          	ld	s2,0(a5)
    80000724:	00090e63          	beqz	s2,80000740 <printf+0x182>
      for(; *s; s++)
    80000728:	00094503          	lbu	a0,0(s2)
    8000072c:	d50d                	beqz	a0,80000656 <printf+0x98>
        consputc(*s);
    8000072e:	00000097          	auipc	ra,0x0
    80000732:	b5e080e7          	jalr	-1186(ra) # 8000028c <consputc>
      for(; *s; s++)
    80000736:	0905                	addi	s2,s2,1
    80000738:	00094503          	lbu	a0,0(s2)
    8000073c:	f96d                	bnez	a0,8000072e <printf+0x170>
    8000073e:	bf21                	j	80000656 <printf+0x98>
        s = "(null)";
    80000740:	00008917          	auipc	s2,0x8
    80000744:	8f890913          	addi	s2,s2,-1800 # 80008038 <digits+0x20>
      for(; *s; s++)
    80000748:	02800513          	li	a0,40
    8000074c:	b7cd                	j	8000072e <printf+0x170>
      consputc('%');
    8000074e:	8552                	mv	a0,s4
    80000750:	00000097          	auipc	ra,0x0
    80000754:	b3c080e7          	jalr	-1220(ra) # 8000028c <consputc>
      break;
    80000758:	bdfd                	j	80000656 <printf+0x98>
      consputc('%');
    8000075a:	8552                	mv	a0,s4
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	b30080e7          	jalr	-1232(ra) # 8000028c <consputc>
      consputc(c);
    80000764:	854a                	mv	a0,s2
    80000766:	00000097          	auipc	ra,0x0
    8000076a:	b26080e7          	jalr	-1242(ra) # 8000028c <consputc>
      break;
    8000076e:	b5e5                	j	80000656 <printf+0x98>
  if(locking)
    80000770:	020d9163          	bnez	s11,80000792 <printf+0x1d4>
}
    80000774:	70e6                	ld	ra,120(sp)
    80000776:	7446                	ld	s0,112(sp)
    80000778:	74a6                	ld	s1,104(sp)
    8000077a:	7906                	ld	s2,96(sp)
    8000077c:	69e6                	ld	s3,88(sp)
    8000077e:	6a46                	ld	s4,80(sp)
    80000780:	6aa6                	ld	s5,72(sp)
    80000782:	6b06                	ld	s6,64(sp)
    80000784:	7be2                	ld	s7,56(sp)
    80000786:	7c42                	ld	s8,48(sp)
    80000788:	7ca2                	ld	s9,40(sp)
    8000078a:	7d02                	ld	s10,32(sp)
    8000078c:	6de2                	ld	s11,24(sp)
    8000078e:	6129                	addi	sp,sp,192
    80000790:	8082                	ret
    release(&pr.lock);
    80000792:	00011517          	auipc	a0,0x11
    80000796:	14650513          	addi	a0,a0,326 # 800118d8 <pr>
    8000079a:	00000097          	auipc	ra,0x0
    8000079e:	5c6080e7          	jalr	1478(ra) # 80000d60 <release>
}
    800007a2:	bfc9                	j	80000774 <printf+0x1b6>

00000000800007a4 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007a4:	1101                	addi	sp,sp,-32
    800007a6:	ec06                	sd	ra,24(sp)
    800007a8:	e822                	sd	s0,16(sp)
    800007aa:	e426                	sd	s1,8(sp)
    800007ac:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007ae:	00011497          	auipc	s1,0x11
    800007b2:	12a48493          	addi	s1,s1,298 # 800118d8 <pr>
    800007b6:	00008597          	auipc	a1,0x8
    800007ba:	89a58593          	addi	a1,a1,-1894 # 80008050 <digits+0x38>
    800007be:	8526                	mv	a0,s1
    800007c0:	00000097          	auipc	ra,0x0
    800007c4:	45c080e7          	jalr	1116(ra) # 80000c1c <initlock>
  pr.locking = 1;
    800007c8:	4785                	li	a5,1
    800007ca:	cc9c                	sw	a5,24(s1)
}
    800007cc:	60e2                	ld	ra,24(sp)
    800007ce:	6442                	ld	s0,16(sp)
    800007d0:	64a2                	ld	s1,8(sp)
    800007d2:	6105                	addi	sp,sp,32
    800007d4:	8082                	ret

00000000800007d6 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007d6:	1141                	addi	sp,sp,-16
    800007d8:	e406                	sd	ra,8(sp)
    800007da:	e022                	sd	s0,0(sp)
    800007dc:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007de:	100007b7          	lui	a5,0x10000
    800007e2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007e6:	f8000713          	li	a4,-128
    800007ea:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ee:	470d                	li	a4,3
    800007f0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007f4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007f8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007fc:	469d                	li	a3,7
    800007fe:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000802:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000806:	00008597          	auipc	a1,0x8
    8000080a:	85258593          	addi	a1,a1,-1966 # 80008058 <digits+0x40>
    8000080e:	00011517          	auipc	a0,0x11
    80000812:	0ea50513          	addi	a0,a0,234 # 800118f8 <uart_tx_lock>
    80000816:	00000097          	auipc	ra,0x0
    8000081a:	406080e7          	jalr	1030(ra) # 80000c1c <initlock>
}
    8000081e:	60a2                	ld	ra,8(sp)
    80000820:	6402                	ld	s0,0(sp)
    80000822:	0141                	addi	sp,sp,16
    80000824:	8082                	ret

0000000080000826 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000826:	1101                	addi	sp,sp,-32
    80000828:	ec06                	sd	ra,24(sp)
    8000082a:	e822                	sd	s0,16(sp)
    8000082c:	e426                	sd	s1,8(sp)
    8000082e:	1000                	addi	s0,sp,32
    80000830:	84aa                	mv	s1,a0
  push_off();
    80000832:	00000097          	auipc	ra,0x0
    80000836:	42e080e7          	jalr	1070(ra) # 80000c60 <push_off>

  if(panicked){
    8000083a:	00008797          	auipc	a5,0x8
    8000083e:	7c678793          	addi	a5,a5,1990 # 80009000 <panicked>
    80000842:	439c                	lw	a5,0(a5)
    80000844:	2781                	sext.w	a5,a5
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000846:	10000737          	lui	a4,0x10000
  if(panicked){
    8000084a:	c391                	beqz	a5,8000084e <uartputc_sync+0x28>
    for(;;)
    8000084c:	a001                	j	8000084c <uartputc_sync+0x26>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000084e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000852:	0ff7f793          	andi	a5,a5,255
    80000856:	0207f793          	andi	a5,a5,32
    8000085a:	dbf5                	beqz	a5,8000084e <uartputc_sync+0x28>
    ;
  WriteReg(THR, c);
    8000085c:	0ff4f793          	andi	a5,s1,255
    80000860:	10000737          	lui	a4,0x10000
    80000864:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000868:	00000097          	auipc	ra,0x0
    8000086c:	498080e7          	jalr	1176(ra) # 80000d00 <pop_off>
}
    80000870:	60e2                	ld	ra,24(sp)
    80000872:	6442                	ld	s0,16(sp)
    80000874:	64a2                	ld	s1,8(sp)
    80000876:	6105                	addi	sp,sp,32
    80000878:	8082                	ret

000000008000087a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000087a:	00008797          	auipc	a5,0x8
    8000087e:	78a78793          	addi	a5,a5,1930 # 80009004 <uart_tx_r>
    80000882:	439c                	lw	a5,0(a5)
    80000884:	00008717          	auipc	a4,0x8
    80000888:	78470713          	addi	a4,a4,1924 # 80009008 <uart_tx_w>
    8000088c:	4318                	lw	a4,0(a4)
    8000088e:	08f70b63          	beq	a4,a5,80000924 <uartstart+0xaa>
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000892:	10000737          	lui	a4,0x10000
    80000896:	00574703          	lbu	a4,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000089a:	0ff77713          	andi	a4,a4,255
    8000089e:	02077713          	andi	a4,a4,32
    800008a2:	c349                	beqz	a4,80000924 <uartstart+0xaa>
{
    800008a4:	7139                	addi	sp,sp,-64
    800008a6:	fc06                	sd	ra,56(sp)
    800008a8:	f822                	sd	s0,48(sp)
    800008aa:	f426                	sd	s1,40(sp)
    800008ac:	f04a                	sd	s2,32(sp)
    800008ae:	ec4e                	sd	s3,24(sp)
    800008b0:	e852                	sd	s4,16(sp)
    800008b2:	e456                	sd	s5,8(sp)
    800008b4:	0080                	addi	s0,sp,64
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    800008b6:	00011a17          	auipc	s4,0x11
    800008ba:	042a0a13          	addi	s4,s4,66 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008be:	00008497          	auipc	s1,0x8
    800008c2:	74648493          	addi	s1,s1,1862 # 80009004 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008c6:	10000937          	lui	s2,0x10000
    if(uart_tx_w == uart_tx_r){
    800008ca:	00008997          	auipc	s3,0x8
    800008ce:	73e98993          	addi	s3,s3,1854 # 80009008 <uart_tx_w>
    int c = uart_tx_buf[uart_tx_r];
    800008d2:	00fa0733          	add	a4,s4,a5
    800008d6:	01874a83          	lbu	s5,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008da:	2785                	addiw	a5,a5,1
    800008dc:	41f7d71b          	sraiw	a4,a5,0x1f
    800008e0:	01b7571b          	srliw	a4,a4,0x1b
    800008e4:	9fb9                	addw	a5,a5,a4
    800008e6:	8bfd                	andi	a5,a5,31
    800008e8:	9f99                	subw	a5,a5,a4
    800008ea:	c09c                	sw	a5,0(s1)
    wakeup(&uart_tx_r);
    800008ec:	8526                	mv	a0,s1
    800008ee:	00002097          	auipc	ra,0x2
    800008f2:	b74080e7          	jalr	-1164(ra) # 80002462 <wakeup>
    WriteReg(THR, c);
    800008f6:	01590023          	sb	s5,0(s2) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fa:	409c                	lw	a5,0(s1)
    800008fc:	0009a703          	lw	a4,0(s3)
    80000900:	00f70963          	beq	a4,a5,80000912 <uartstart+0x98>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000904:	00594703          	lbu	a4,5(s2)
    80000908:	0ff77713          	andi	a4,a4,255
    8000090c:	02077713          	andi	a4,a4,32
    80000910:	f369                	bnez	a4,800008d2 <uartstart+0x58>
  }
}
    80000912:	70e2                	ld	ra,56(sp)
    80000914:	7442                	ld	s0,48(sp)
    80000916:	74a2                	ld	s1,40(sp)
    80000918:	7902                	ld	s2,32(sp)
    8000091a:	69e2                	ld	s3,24(sp)
    8000091c:	6a42                	ld	s4,16(sp)
    8000091e:	6aa2                	ld	s5,8(sp)
    80000920:	6121                	addi	sp,sp,64
    80000922:	8082                	ret
    80000924:	8082                	ret

0000000080000926 <uartputc>:
{
    80000926:	7179                	addi	sp,sp,-48
    80000928:	f406                	sd	ra,40(sp)
    8000092a:	f022                	sd	s0,32(sp)
    8000092c:	ec26                	sd	s1,24(sp)
    8000092e:	e84a                	sd	s2,16(sp)
    80000930:	e44e                	sd	s3,8(sp)
    80000932:	e052                	sd	s4,0(sp)
    80000934:	1800                	addi	s0,sp,48
    80000936:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    80000938:	00011517          	auipc	a0,0x11
    8000093c:	fc050513          	addi	a0,a0,-64 # 800118f8 <uart_tx_lock>
    80000940:	00000097          	auipc	ra,0x0
    80000944:	36c080e7          	jalr	876(ra) # 80000cac <acquire>
  if(panicked){
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	6b878793          	addi	a5,a5,1720 # 80009000 <panicked>
    80000950:	439c                	lw	a5,0(a5)
    80000952:	2781                	sext.w	a5,a5
    80000954:	c391                	beqz	a5,80000958 <uartputc+0x32>
    for(;;)
    80000956:	a001                	j	80000956 <uartputc+0x30>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000958:	00008797          	auipc	a5,0x8
    8000095c:	6b078793          	addi	a5,a5,1712 # 80009008 <uart_tx_w>
    80000960:	4398                	lw	a4,0(a5)
    80000962:	0017079b          	addiw	a5,a4,1
    80000966:	41f7d69b          	sraiw	a3,a5,0x1f
    8000096a:	01b6d69b          	srliw	a3,a3,0x1b
    8000096e:	9fb5                	addw	a5,a5,a3
    80000970:	8bfd                	andi	a5,a5,31
    80000972:	9f95                	subw	a5,a5,a3
    80000974:	00008697          	auipc	a3,0x8
    80000978:	69068693          	addi	a3,a3,1680 # 80009004 <uart_tx_r>
    8000097c:	4294                	lw	a3,0(a3)
    8000097e:	04f69263          	bne	a3,a5,800009c2 <uartputc+0x9c>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000982:	00011a17          	auipc	s4,0x11
    80000986:	f76a0a13          	addi	s4,s4,-138 # 800118f8 <uart_tx_lock>
    8000098a:	00008497          	auipc	s1,0x8
    8000098e:	67a48493          	addi	s1,s1,1658 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000992:	00008917          	auipc	s2,0x8
    80000996:	67690913          	addi	s2,s2,1654 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000099a:	85d2                	mv	a1,s4
    8000099c:	8526                	mv	a0,s1
    8000099e:	00002097          	auipc	ra,0x2
    800009a2:	93e080e7          	jalr	-1730(ra) # 800022dc <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800009a6:	00092703          	lw	a4,0(s2)
    800009aa:	0017079b          	addiw	a5,a4,1
    800009ae:	41f7d69b          	sraiw	a3,a5,0x1f
    800009b2:	01b6d69b          	srliw	a3,a3,0x1b
    800009b6:	9fb5                	addw	a5,a5,a3
    800009b8:	8bfd                	andi	a5,a5,31
    800009ba:	9f95                	subw	a5,a5,a3
    800009bc:	4094                	lw	a3,0(s1)
    800009be:	fcf68ee3          	beq	a3,a5,8000099a <uartputc+0x74>
      uart_tx_buf[uart_tx_w] = c;
    800009c2:	00011497          	auipc	s1,0x11
    800009c6:	f3648493          	addi	s1,s1,-202 # 800118f8 <uart_tx_lock>
    800009ca:	9726                	add	a4,a4,s1
    800009cc:	01370c23          	sb	s3,24(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    800009d0:	00008717          	auipc	a4,0x8
    800009d4:	62f72c23          	sw	a5,1592(a4) # 80009008 <uart_tx_w>
      uartstart();
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	ea2080e7          	jalr	-350(ra) # 8000087a <uartstart>
      release(&uart_tx_lock);
    800009e0:	8526                	mv	a0,s1
    800009e2:	00000097          	auipc	ra,0x0
    800009e6:	37e080e7          	jalr	894(ra) # 80000d60 <release>
}
    800009ea:	70a2                	ld	ra,40(sp)
    800009ec:	7402                	ld	s0,32(sp)
    800009ee:	64e2                	ld	s1,24(sp)
    800009f0:	6942                	ld	s2,16(sp)
    800009f2:	69a2                	ld	s3,8(sp)
    800009f4:	6a02                	ld	s4,0(sp)
    800009f6:	6145                	addi	sp,sp,48
    800009f8:	8082                	ret

00000000800009fa <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009fa:	1141                	addi	sp,sp,-16
    800009fc:	e422                	sd	s0,8(sp)
    800009fe:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000a00:	100007b7          	lui	a5,0x10000
    80000a04:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a08:	8b85                	andi	a5,a5,1
    80000a0a:	cb91                	beqz	a5,80000a1e <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000a0c:	100007b7          	lui	a5,0x10000
    80000a10:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000a14:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000a18:	6422                	ld	s0,8(sp)
    80000a1a:	0141                	addi	sp,sp,16
    80000a1c:	8082                	ret
    return -1;
    80000a1e:	557d                	li	a0,-1
    80000a20:	bfe5                	j	80000a18 <uartgetc+0x1e>

0000000080000a22 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000a22:	1101                	addi	sp,sp,-32
    80000a24:	ec06                	sd	ra,24(sp)
    80000a26:	e822                	sd	s0,16(sp)
    80000a28:	e426                	sd	s1,8(sp)
    80000a2a:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a2c:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a2e:	00000097          	auipc	ra,0x0
    80000a32:	fcc080e7          	jalr	-52(ra) # 800009fa <uartgetc>
    if(c == -1)
    80000a36:	00950763          	beq	a0,s1,80000a44 <uartintr+0x22>
      break;
    consoleintr(c);
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	894080e7          	jalr	-1900(ra) # 800002ce <consoleintr>
  while(1){
    80000a42:	b7f5                	j	80000a2e <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a44:	00011497          	auipc	s1,0x11
    80000a48:	eb448493          	addi	s1,s1,-332 # 800118f8 <uart_tx_lock>
    80000a4c:	8526                	mv	a0,s1
    80000a4e:	00000097          	auipc	ra,0x0
    80000a52:	25e080e7          	jalr	606(ra) # 80000cac <acquire>
  uartstart();
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	e24080e7          	jalr	-476(ra) # 8000087a <uartstart>
  release(&uart_tx_lock);
    80000a5e:	8526                	mv	a0,s1
    80000a60:	00000097          	auipc	ra,0x0
    80000a64:	300080e7          	jalr	768(ra) # 80000d60 <release>
}
    80000a68:	60e2                	ld	ra,24(sp)
    80000a6a:	6442                	ld	s0,16(sp)
    80000a6c:	64a2                	ld	s1,8(sp)
    80000a6e:	6105                	addi	sp,sp,32
    80000a70:	8082                	ret

0000000080000a72 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a72:	1101                	addi	sp,sp,-32
    80000a74:	ec06                	sd	ra,24(sp)
    80000a76:	e822                	sd	s0,16(sp)
    80000a78:	e426                	sd	s1,8(sp)
    80000a7a:	e04a                	sd	s2,0(sp)
    80000a7c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a7e:	6785                	lui	a5,0x1
    80000a80:	17fd                	addi	a5,a5,-1
    80000a82:	8fe9                	and	a5,a5,a0
    80000a84:	ebb9                	bnez	a5,80000ada <kfree+0x68>
    80000a86:	84aa                	mv	s1,a0
    80000a88:	00025797          	auipc	a5,0x25
    80000a8c:	57878793          	addi	a5,a5,1400 # 80026000 <end>
    80000a90:	04f56563          	bltu	a0,a5,80000ada <kfree+0x68>
    80000a94:	47c5                	li	a5,17
    80000a96:	07ee                	slli	a5,a5,0x1b
    80000a98:	04f57163          	bleu	a5,a0,80000ada <kfree+0x68>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a9c:	6605                	lui	a2,0x1
    80000a9e:	4585                	li	a1,1
    80000aa0:	00000097          	auipc	ra,0x0
    80000aa4:	308080e7          	jalr	776(ra) # 80000da8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000aa8:	00011917          	auipc	s2,0x11
    80000aac:	e8890913          	addi	s2,s2,-376 # 80011930 <kmem>
    80000ab0:	854a                	mv	a0,s2
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	1fa080e7          	jalr	506(ra) # 80000cac <acquire>
  r->next = kmem.freelist;
    80000aba:	01893783          	ld	a5,24(s2)
    80000abe:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ac0:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000ac4:	854a                	mv	a0,s2
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	29a080e7          	jalr	666(ra) # 80000d60 <release>
}
    80000ace:	60e2                	ld	ra,24(sp)
    80000ad0:	6442                	ld	s0,16(sp)
    80000ad2:	64a2                	ld	s1,8(sp)
    80000ad4:	6902                	ld	s2,0(sp)
    80000ad6:	6105                	addi	sp,sp,32
    80000ad8:	8082                	ret
    panic("kfree");
    80000ada:	00007517          	auipc	a0,0x7
    80000ade:	58650513          	addi	a0,a0,1414 # 80008060 <digits+0x48>
    80000ae2:	00000097          	auipc	ra,0x0
    80000ae6:	a92080e7          	jalr	-1390(ra) # 80000574 <panic>

0000000080000aea <freerange>:
{
    80000aea:	7179                	addi	sp,sp,-48
    80000aec:	f406                	sd	ra,40(sp)
    80000aee:	f022                	sd	s0,32(sp)
    80000af0:	ec26                	sd	s1,24(sp)
    80000af2:	e84a                	sd	s2,16(sp)
    80000af4:	e44e                	sd	s3,8(sp)
    80000af6:	e052                	sd	s4,0(sp)
    80000af8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000afa:	6705                	lui	a4,0x1
    80000afc:	fff70793          	addi	a5,a4,-1 # fff <_entry-0x7ffff001>
    80000b00:	00f504b3          	add	s1,a0,a5
    80000b04:	77fd                	lui	a5,0xfffff
    80000b06:	8cfd                	and	s1,s1,a5
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b08:	94ba                	add	s1,s1,a4
    80000b0a:	0095ee63          	bltu	a1,s1,80000b26 <freerange+0x3c>
    80000b0e:	892e                	mv	s2,a1
    kfree(p);
    80000b10:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b12:	6985                	lui	s3,0x1
    kfree(p);
    80000b14:	01448533          	add	a0,s1,s4
    80000b18:	00000097          	auipc	ra,0x0
    80000b1c:	f5a080e7          	jalr	-166(ra) # 80000a72 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b20:	94ce                	add	s1,s1,s3
    80000b22:	fe9979e3          	bleu	s1,s2,80000b14 <freerange+0x2a>
}
    80000b26:	70a2                	ld	ra,40(sp)
    80000b28:	7402                	ld	s0,32(sp)
    80000b2a:	64e2                	ld	s1,24(sp)
    80000b2c:	6942                	ld	s2,16(sp)
    80000b2e:	69a2                	ld	s3,8(sp)
    80000b30:	6a02                	ld	s4,0(sp)
    80000b32:	6145                	addi	sp,sp,48
    80000b34:	8082                	ret

0000000080000b36 <kinit>:
{
    80000b36:	1141                	addi	sp,sp,-16
    80000b38:	e406                	sd	ra,8(sp)
    80000b3a:	e022                	sd	s0,0(sp)
    80000b3c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b3e:	00007597          	auipc	a1,0x7
    80000b42:	52a58593          	addi	a1,a1,1322 # 80008068 <digits+0x50>
    80000b46:	00011517          	auipc	a0,0x11
    80000b4a:	dea50513          	addi	a0,a0,-534 # 80011930 <kmem>
    80000b4e:	00000097          	auipc	ra,0x0
    80000b52:	0ce080e7          	jalr	206(ra) # 80000c1c <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b56:	45c5                	li	a1,17
    80000b58:	05ee                	slli	a1,a1,0x1b
    80000b5a:	00025517          	auipc	a0,0x25
    80000b5e:	4a650513          	addi	a0,a0,1190 # 80026000 <end>
    80000b62:	00000097          	auipc	ra,0x0
    80000b66:	f88080e7          	jalr	-120(ra) # 80000aea <freerange>
}
    80000b6a:	60a2                	ld	ra,8(sp)
    80000b6c:	6402                	ld	s0,0(sp)
    80000b6e:	0141                	addi	sp,sp,16
    80000b70:	8082                	ret

0000000080000b72 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b72:	1101                	addi	sp,sp,-32
    80000b74:	ec06                	sd	ra,24(sp)
    80000b76:	e822                	sd	s0,16(sp)
    80000b78:	e426                	sd	s1,8(sp)
    80000b7a:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b7c:	00011497          	auipc	s1,0x11
    80000b80:	db448493          	addi	s1,s1,-588 # 80011930 <kmem>
    80000b84:	8526                	mv	a0,s1
    80000b86:	00000097          	auipc	ra,0x0
    80000b8a:	126080e7          	jalr	294(ra) # 80000cac <acquire>
  r = kmem.freelist;
    80000b8e:	6c84                	ld	s1,24(s1)
  if(r)
    80000b90:	c885                	beqz	s1,80000bc0 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b92:	609c                	ld	a5,0(s1)
    80000b94:	00011517          	auipc	a0,0x11
    80000b98:	d9c50513          	addi	a0,a0,-612 # 80011930 <kmem>
    80000b9c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	1c2080e7          	jalr	450(ra) # 80000d60 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000ba6:	6605                	lui	a2,0x1
    80000ba8:	4595                	li	a1,5
    80000baa:	8526                	mv	a0,s1
    80000bac:	00000097          	auipc	ra,0x0
    80000bb0:	1fc080e7          	jalr	508(ra) # 80000da8 <memset>
  return (void*)r;
}
    80000bb4:	8526                	mv	a0,s1
    80000bb6:	60e2                	ld	ra,24(sp)
    80000bb8:	6442                	ld	s0,16(sp)
    80000bba:	64a2                	ld	s1,8(sp)
    80000bbc:	6105                	addi	sp,sp,32
    80000bbe:	8082                	ret
  release(&kmem.lock);
    80000bc0:	00011517          	auipc	a0,0x11
    80000bc4:	d7050513          	addi	a0,a0,-656 # 80011930 <kmem>
    80000bc8:	00000097          	auipc	ra,0x0
    80000bcc:	198080e7          	jalr	408(ra) # 80000d60 <release>
  if(r)
    80000bd0:	b7d5                	j	80000bb4 <kalloc+0x42>

0000000080000bd2 <kfreemem>:

// Return the number of bytes of free memory
// should be multiple of PGSIZE
uint64
kfreemem(void) {
    80000bd2:	1101                	addi	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	addi	s0,sp,32
  struct run *r;
  uint64 free = 0;
  acquire(&kmem.lock);
    80000bdc:	00011497          	auipc	s1,0x11
    80000be0:	d5448493          	addi	s1,s1,-684 # 80011930 <kmem>
    80000be4:	8526                	mv	a0,s1
    80000be6:	00000097          	auipc	ra,0x0
    80000bea:	0c6080e7          	jalr	198(ra) # 80000cac <acquire>
  r = kmem.freelist;
    80000bee:	6c9c                	ld	a5,24(s1)
  while (r) {
    80000bf0:	c785                	beqz	a5,80000c18 <kfreemem+0x46>
  uint64 free = 0;
    80000bf2:	4481                	li	s1,0
    free += PGSIZE;
    80000bf4:	6705                	lui	a4,0x1
    80000bf6:	94ba                	add	s1,s1,a4
    r = r->next;
    80000bf8:	639c                	ld	a5,0(a5)
  while (r) {
    80000bfa:	fff5                	bnez	a5,80000bf6 <kfreemem+0x24>
  }
  release(&kmem.lock);
    80000bfc:	00011517          	auipc	a0,0x11
    80000c00:	d3450513          	addi	a0,a0,-716 # 80011930 <kmem>
    80000c04:	00000097          	auipc	ra,0x0
    80000c08:	15c080e7          	jalr	348(ra) # 80000d60 <release>
  return free;
}
    80000c0c:	8526                	mv	a0,s1
    80000c0e:	60e2                	ld	ra,24(sp)
    80000c10:	6442                	ld	s0,16(sp)
    80000c12:	64a2                	ld	s1,8(sp)
    80000c14:	6105                	addi	sp,sp,32
    80000c16:	8082                	ret
  uint64 free = 0;
    80000c18:	4481                	li	s1,0
    80000c1a:	b7cd                	j	80000bfc <kfreemem+0x2a>

0000000080000c1c <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c1c:	1141                	addi	sp,sp,-16
    80000c1e:	e422                	sd	s0,8(sp)
    80000c20:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c22:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c24:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c28:	00053823          	sd	zero,16(a0)
}
    80000c2c:	6422                	ld	s0,8(sp)
    80000c2e:	0141                	addi	sp,sp,16
    80000c30:	8082                	ret

0000000080000c32 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c32:	411c                	lw	a5,0(a0)
    80000c34:	e399                	bnez	a5,80000c3a <holding+0x8>
    80000c36:	4501                	li	a0,0
  return r;
}
    80000c38:	8082                	ret
{
    80000c3a:	1101                	addi	sp,sp,-32
    80000c3c:	ec06                	sd	ra,24(sp)
    80000c3e:	e822                	sd	s0,16(sp)
    80000c40:	e426                	sd	s1,8(sp)
    80000c42:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c44:	6904                	ld	s1,16(a0)
    80000c46:	00001097          	auipc	ra,0x1
    80000c4a:	e58080e7          	jalr	-424(ra) # 80001a9e <mycpu>
    80000c4e:	40a48533          	sub	a0,s1,a0
    80000c52:	00153513          	seqz	a0,a0
}
    80000c56:	60e2                	ld	ra,24(sp)
    80000c58:	6442                	ld	s0,16(sp)
    80000c5a:	64a2                	ld	s1,8(sp)
    80000c5c:	6105                	addi	sp,sp,32
    80000c5e:	8082                	ret

0000000080000c60 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c60:	1101                	addi	sp,sp,-32
    80000c62:	ec06                	sd	ra,24(sp)
    80000c64:	e822                	sd	s0,16(sp)
    80000c66:	e426                	sd	s1,8(sp)
    80000c68:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c6a:	100024f3          	csrr	s1,sstatus
    80000c6e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c72:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c74:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c78:	00001097          	auipc	ra,0x1
    80000c7c:	e26080e7          	jalr	-474(ra) # 80001a9e <mycpu>
    80000c80:	5d3c                	lw	a5,120(a0)
    80000c82:	cf89                	beqz	a5,80000c9c <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c84:	00001097          	auipc	ra,0x1
    80000c88:	e1a080e7          	jalr	-486(ra) # 80001a9e <mycpu>
    80000c8c:	5d3c                	lw	a5,120(a0)
    80000c8e:	2785                	addiw	a5,a5,1
    80000c90:	dd3c                	sw	a5,120(a0)
}
    80000c92:	60e2                	ld	ra,24(sp)
    80000c94:	6442                	ld	s0,16(sp)
    80000c96:	64a2                	ld	s1,8(sp)
    80000c98:	6105                	addi	sp,sp,32
    80000c9a:	8082                	ret
    mycpu()->intena = old;
    80000c9c:	00001097          	auipc	ra,0x1
    80000ca0:	e02080e7          	jalr	-510(ra) # 80001a9e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000ca4:	8085                	srli	s1,s1,0x1
    80000ca6:	8885                	andi	s1,s1,1
    80000ca8:	dd64                	sw	s1,124(a0)
    80000caa:	bfe9                	j	80000c84 <push_off+0x24>

0000000080000cac <acquire>:
{
    80000cac:	1101                	addi	sp,sp,-32
    80000cae:	ec06                	sd	ra,24(sp)
    80000cb0:	e822                	sd	s0,16(sp)
    80000cb2:	e426                	sd	s1,8(sp)
    80000cb4:	1000                	addi	s0,sp,32
    80000cb6:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000cb8:	00000097          	auipc	ra,0x0
    80000cbc:	fa8080e7          	jalr	-88(ra) # 80000c60 <push_off>
  if(holding(lk))
    80000cc0:	8526                	mv	a0,s1
    80000cc2:	00000097          	auipc	ra,0x0
    80000cc6:	f70080e7          	jalr	-144(ra) # 80000c32 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cca:	4705                	li	a4,1
  if(holding(lk))
    80000ccc:	e115                	bnez	a0,80000cf0 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cce:	87ba                	mv	a5,a4
    80000cd0:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cd4:	2781                	sext.w	a5,a5
    80000cd6:	ffe5                	bnez	a5,80000cce <acquire+0x22>
  __sync_synchronize();
    80000cd8:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000cdc:	00001097          	auipc	ra,0x1
    80000ce0:	dc2080e7          	jalr	-574(ra) # 80001a9e <mycpu>
    80000ce4:	e888                	sd	a0,16(s1)
}
    80000ce6:	60e2                	ld	ra,24(sp)
    80000ce8:	6442                	ld	s0,16(sp)
    80000cea:	64a2                	ld	s1,8(sp)
    80000cec:	6105                	addi	sp,sp,32
    80000cee:	8082                	ret
    panic("acquire");
    80000cf0:	00007517          	auipc	a0,0x7
    80000cf4:	38050513          	addi	a0,a0,896 # 80008070 <digits+0x58>
    80000cf8:	00000097          	auipc	ra,0x0
    80000cfc:	87c080e7          	jalr	-1924(ra) # 80000574 <panic>

0000000080000d00 <pop_off>:

void
pop_off(void)
{
    80000d00:	1141                	addi	sp,sp,-16
    80000d02:	e406                	sd	ra,8(sp)
    80000d04:	e022                	sd	s0,0(sp)
    80000d06:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d08:	00001097          	auipc	ra,0x1
    80000d0c:	d96080e7          	jalr	-618(ra) # 80001a9e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d10:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d14:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d16:	e78d                	bnez	a5,80000d40 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d18:	5d3c                	lw	a5,120(a0)
    80000d1a:	02f05b63          	blez	a5,80000d50 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d1e:	37fd                	addiw	a5,a5,-1
    80000d20:	0007871b          	sext.w	a4,a5
    80000d24:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d26:	eb09                	bnez	a4,80000d38 <pop_off+0x38>
    80000d28:	5d7c                	lw	a5,124(a0)
    80000d2a:	c799                	beqz	a5,80000d38 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d2c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d30:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d34:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d38:	60a2                	ld	ra,8(sp)
    80000d3a:	6402                	ld	s0,0(sp)
    80000d3c:	0141                	addi	sp,sp,16
    80000d3e:	8082                	ret
    panic("pop_off - interruptible");
    80000d40:	00007517          	auipc	a0,0x7
    80000d44:	33850513          	addi	a0,a0,824 # 80008078 <digits+0x60>
    80000d48:	00000097          	auipc	ra,0x0
    80000d4c:	82c080e7          	jalr	-2004(ra) # 80000574 <panic>
    panic("pop_off");
    80000d50:	00007517          	auipc	a0,0x7
    80000d54:	34050513          	addi	a0,a0,832 # 80008090 <digits+0x78>
    80000d58:	00000097          	auipc	ra,0x0
    80000d5c:	81c080e7          	jalr	-2020(ra) # 80000574 <panic>

0000000080000d60 <release>:
{
    80000d60:	1101                	addi	sp,sp,-32
    80000d62:	ec06                	sd	ra,24(sp)
    80000d64:	e822                	sd	s0,16(sp)
    80000d66:	e426                	sd	s1,8(sp)
    80000d68:	1000                	addi	s0,sp,32
    80000d6a:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d6c:	00000097          	auipc	ra,0x0
    80000d70:	ec6080e7          	jalr	-314(ra) # 80000c32 <holding>
    80000d74:	c115                	beqz	a0,80000d98 <release+0x38>
  lk->cpu = 0;
    80000d76:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d7a:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d7e:	0f50000f          	fence	iorw,ow
    80000d82:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	f7a080e7          	jalr	-134(ra) # 80000d00 <pop_off>
}
    80000d8e:	60e2                	ld	ra,24(sp)
    80000d90:	6442                	ld	s0,16(sp)
    80000d92:	64a2                	ld	s1,8(sp)
    80000d94:	6105                	addi	sp,sp,32
    80000d96:	8082                	ret
    panic("release");
    80000d98:	00007517          	auipc	a0,0x7
    80000d9c:	30050513          	addi	a0,a0,768 # 80008098 <digits+0x80>
    80000da0:	fffff097          	auipc	ra,0xfffff
    80000da4:	7d4080e7          	jalr	2004(ra) # 80000574 <panic>

0000000080000da8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000da8:	1141                	addi	sp,sp,-16
    80000daa:	e422                	sd	s0,8(sp)
    80000dac:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000dae:	ce09                	beqz	a2,80000dc8 <memset+0x20>
    80000db0:	87aa                	mv	a5,a0
    80000db2:	fff6071b          	addiw	a4,a2,-1
    80000db6:	1702                	slli	a4,a4,0x20
    80000db8:	9301                	srli	a4,a4,0x20
    80000dba:	0705                	addi	a4,a4,1
    80000dbc:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000dbe:	00b78023          	sb	a1,0(a5) # fffffffffffff000 <end+0xffffffff7ffd9000>
  for(i = 0; i < n; i++){
    80000dc2:	0785                	addi	a5,a5,1
    80000dc4:	fee79de3          	bne	a5,a4,80000dbe <memset+0x16>
  }
  return dst;
}
    80000dc8:	6422                	ld	s0,8(sp)
    80000dca:	0141                	addi	sp,sp,16
    80000dcc:	8082                	ret

0000000080000dce <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000dce:	1141                	addi	sp,sp,-16
    80000dd0:	e422                	sd	s0,8(sp)
    80000dd2:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000dd4:	ce15                	beqz	a2,80000e10 <memcmp+0x42>
    80000dd6:	fff6069b          	addiw	a3,a2,-1
    if(*s1 != *s2)
    80000dda:	00054783          	lbu	a5,0(a0)
    80000dde:	0005c703          	lbu	a4,0(a1)
    80000de2:	02e79063          	bne	a5,a4,80000e02 <memcmp+0x34>
    80000de6:	1682                	slli	a3,a3,0x20
    80000de8:	9281                	srli	a3,a3,0x20
    80000dea:	0685                	addi	a3,a3,1
    80000dec:	96aa                	add	a3,a3,a0
      return *s1 - *s2;
    s1++, s2++;
    80000dee:	0505                	addi	a0,a0,1
    80000df0:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000df2:	00d50d63          	beq	a0,a3,80000e0c <memcmp+0x3e>
    if(*s1 != *s2)
    80000df6:	00054783          	lbu	a5,0(a0)
    80000dfa:	0005c703          	lbu	a4,0(a1)
    80000dfe:	fee788e3          	beq	a5,a4,80000dee <memcmp+0x20>
      return *s1 - *s2;
    80000e02:	40e7853b          	subw	a0,a5,a4
  }

  return 0;
}
    80000e06:	6422                	ld	s0,8(sp)
    80000e08:	0141                	addi	sp,sp,16
    80000e0a:	8082                	ret
  return 0;
    80000e0c:	4501                	li	a0,0
    80000e0e:	bfe5                	j	80000e06 <memcmp+0x38>
    80000e10:	4501                	li	a0,0
    80000e12:	bfd5                	j	80000e06 <memcmp+0x38>

0000000080000e14 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e14:	1141                	addi	sp,sp,-16
    80000e16:	e422                	sd	s0,8(sp)
    80000e18:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e1a:	00a5f963          	bleu	a0,a1,80000e2c <memmove+0x18>
    80000e1e:	02061713          	slli	a4,a2,0x20
    80000e22:	9301                	srli	a4,a4,0x20
    80000e24:	00e587b3          	add	a5,a1,a4
    80000e28:	02f56563          	bltu	a0,a5,80000e52 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e2c:	fff6069b          	addiw	a3,a2,-1
    80000e30:	ce11                	beqz	a2,80000e4c <memmove+0x38>
    80000e32:	1682                	slli	a3,a3,0x20
    80000e34:	9281                	srli	a3,a3,0x20
    80000e36:	0685                	addi	a3,a3,1
    80000e38:	96ae                	add	a3,a3,a1
    80000e3a:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000e3c:	0585                	addi	a1,a1,1
    80000e3e:	0785                	addi	a5,a5,1
    80000e40:	fff5c703          	lbu	a4,-1(a1)
    80000e44:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000e48:	fed59ae3          	bne	a1,a3,80000e3c <memmove+0x28>

  return dst;
}
    80000e4c:	6422                	ld	s0,8(sp)
    80000e4e:	0141                	addi	sp,sp,16
    80000e50:	8082                	ret
    d += n;
    80000e52:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000e54:	fff6069b          	addiw	a3,a2,-1
    80000e58:	da75                	beqz	a2,80000e4c <memmove+0x38>
    80000e5a:	02069613          	slli	a2,a3,0x20
    80000e5e:	9201                	srli	a2,a2,0x20
    80000e60:	fff64613          	not	a2,a2
    80000e64:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e66:	17fd                	addi	a5,a5,-1
    80000e68:	177d                	addi	a4,a4,-1
    80000e6a:	0007c683          	lbu	a3,0(a5)
    80000e6e:	00d70023          	sb	a3,0(a4) # 1000 <_entry-0x7ffff000>
    while(n-- > 0)
    80000e72:	fef61ae3          	bne	a2,a5,80000e66 <memmove+0x52>
    80000e76:	bfd9                	j	80000e4c <memmove+0x38>

0000000080000e78 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e80:	00000097          	auipc	ra,0x0
    80000e84:	f94080e7          	jalr	-108(ra) # 80000e14 <memmove>
}
    80000e88:	60a2                	ld	ra,8(sp)
    80000e8a:	6402                	ld	s0,0(sp)
    80000e8c:	0141                	addi	sp,sp,16
    80000e8e:	8082                	ret

0000000080000e90 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e90:	1141                	addi	sp,sp,-16
    80000e92:	e422                	sd	s0,8(sp)
    80000e94:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e96:	c229                	beqz	a2,80000ed8 <strncmp+0x48>
    80000e98:	00054783          	lbu	a5,0(a0)
    80000e9c:	c795                	beqz	a5,80000ec8 <strncmp+0x38>
    80000e9e:	0005c703          	lbu	a4,0(a1)
    80000ea2:	02f71363          	bne	a4,a5,80000ec8 <strncmp+0x38>
    80000ea6:	fff6071b          	addiw	a4,a2,-1
    80000eaa:	1702                	slli	a4,a4,0x20
    80000eac:	9301                	srli	a4,a4,0x20
    80000eae:	0705                	addi	a4,a4,1
    80000eb0:	972a                	add	a4,a4,a0
    n--, p++, q++;
    80000eb2:	0505                	addi	a0,a0,1
    80000eb4:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000eb6:	02e50363          	beq	a0,a4,80000edc <strncmp+0x4c>
    80000eba:	00054783          	lbu	a5,0(a0)
    80000ebe:	c789                	beqz	a5,80000ec8 <strncmp+0x38>
    80000ec0:	0005c683          	lbu	a3,0(a1)
    80000ec4:	fef687e3          	beq	a3,a5,80000eb2 <strncmp+0x22>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
    80000ec8:	00054503          	lbu	a0,0(a0)
    80000ecc:	0005c783          	lbu	a5,0(a1)
    80000ed0:	9d1d                	subw	a0,a0,a5
}
    80000ed2:	6422                	ld	s0,8(sp)
    80000ed4:	0141                	addi	sp,sp,16
    80000ed6:	8082                	ret
    return 0;
    80000ed8:	4501                	li	a0,0
    80000eda:	bfe5                	j	80000ed2 <strncmp+0x42>
    80000edc:	4501                	li	a0,0
    80000ede:	bfd5                	j	80000ed2 <strncmp+0x42>

0000000080000ee0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000ee0:	1141                	addi	sp,sp,-16
    80000ee2:	e422                	sd	s0,8(sp)
    80000ee4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000ee6:	872a                	mv	a4,a0
    80000ee8:	a011                	j	80000eec <strncpy+0xc>
    80000eea:	8636                	mv	a2,a3
    80000eec:	fff6069b          	addiw	a3,a2,-1
    80000ef0:	00c05963          	blez	a2,80000f02 <strncpy+0x22>
    80000ef4:	0705                	addi	a4,a4,1
    80000ef6:	0005c783          	lbu	a5,0(a1)
    80000efa:	fef70fa3          	sb	a5,-1(a4)
    80000efe:	0585                	addi	a1,a1,1
    80000f00:	f7ed                	bnez	a5,80000eea <strncpy+0xa>
    ;
  while(n-- > 0)
    80000f02:	00d05c63          	blez	a3,80000f1a <strncpy+0x3a>
    80000f06:	86ba                	mv	a3,a4
    *s++ = 0;
    80000f08:	0685                	addi	a3,a3,1
    80000f0a:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000f0e:	fff6c793          	not	a5,a3
    80000f12:	9fb9                	addw	a5,a5,a4
    80000f14:	9fb1                	addw	a5,a5,a2
    80000f16:	fef049e3          	bgtz	a5,80000f08 <strncpy+0x28>
  return os;
}
    80000f1a:	6422                	ld	s0,8(sp)
    80000f1c:	0141                	addi	sp,sp,16
    80000f1e:	8082                	ret

0000000080000f20 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f20:	1141                	addi	sp,sp,-16
    80000f22:	e422                	sd	s0,8(sp)
    80000f24:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f26:	02c05363          	blez	a2,80000f4c <safestrcpy+0x2c>
    80000f2a:	fff6069b          	addiw	a3,a2,-1
    80000f2e:	1682                	slli	a3,a3,0x20
    80000f30:	9281                	srli	a3,a3,0x20
    80000f32:	96ae                	add	a3,a3,a1
    80000f34:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f36:	00d58963          	beq	a1,a3,80000f48 <safestrcpy+0x28>
    80000f3a:	0585                	addi	a1,a1,1
    80000f3c:	0785                	addi	a5,a5,1
    80000f3e:	fff5c703          	lbu	a4,-1(a1)
    80000f42:	fee78fa3          	sb	a4,-1(a5)
    80000f46:	fb65                	bnez	a4,80000f36 <safestrcpy+0x16>
    ;
  *s = 0;
    80000f48:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f4c:	6422                	ld	s0,8(sp)
    80000f4e:	0141                	addi	sp,sp,16
    80000f50:	8082                	ret

0000000080000f52 <strlen>:

int
strlen(const char *s)
{
    80000f52:	1141                	addi	sp,sp,-16
    80000f54:	e422                	sd	s0,8(sp)
    80000f56:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f58:	00054783          	lbu	a5,0(a0)
    80000f5c:	cf91                	beqz	a5,80000f78 <strlen+0x26>
    80000f5e:	0505                	addi	a0,a0,1
    80000f60:	87aa                	mv	a5,a0
    80000f62:	4685                	li	a3,1
    80000f64:	9e89                	subw	a3,a3,a0
    80000f66:	00f6853b          	addw	a0,a3,a5
    80000f6a:	0785                	addi	a5,a5,1
    80000f6c:	fff7c703          	lbu	a4,-1(a5)
    80000f70:	fb7d                	bnez	a4,80000f66 <strlen+0x14>
    ;
  return n;
}
    80000f72:	6422                	ld	s0,8(sp)
    80000f74:	0141                	addi	sp,sp,16
    80000f76:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f78:	4501                	li	a0,0
    80000f7a:	bfe5                	j	80000f72 <strlen+0x20>

0000000080000f7c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f7c:	1141                	addi	sp,sp,-16
    80000f7e:	e406                	sd	ra,8(sp)
    80000f80:	e022                	sd	s0,0(sp)
    80000f82:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f84:	00001097          	auipc	ra,0x1
    80000f88:	b0a080e7          	jalr	-1270(ra) # 80001a8e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f8c:	00008717          	auipc	a4,0x8
    80000f90:	08070713          	addi	a4,a4,128 # 8000900c <started>
  if(cpuid() == 0){
    80000f94:	c139                	beqz	a0,80000fda <main+0x5e>
    while(started == 0)
    80000f96:	431c                	lw	a5,0(a4)
    80000f98:	2781                	sext.w	a5,a5
    80000f9a:	dff5                	beqz	a5,80000f96 <main+0x1a>
      ;
    __sync_synchronize();
    80000f9c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000fa0:	00001097          	auipc	ra,0x1
    80000fa4:	aee080e7          	jalr	-1298(ra) # 80001a8e <cpuid>
    80000fa8:	85aa                	mv	a1,a0
    80000faa:	00007517          	auipc	a0,0x7
    80000fae:	10e50513          	addi	a0,a0,270 # 800080b8 <digits+0xa0>
    80000fb2:	fffff097          	auipc	ra,0xfffff
    80000fb6:	60c080e7          	jalr	1548(ra) # 800005be <printf>
    kvminithart();    // turn on paging
    80000fba:	00000097          	auipc	ra,0x0
    80000fbe:	0d8080e7          	jalr	216(ra) # 80001092 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000fc2:	00001097          	auipc	ra,0x1
    80000fc6:	7be080e7          	jalr	1982(ra) # 80002780 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000fca:	00005097          	auipc	ra,0x5
    80000fce:	f06080e7          	jalr	-250(ra) # 80005ed0 <plicinithart>
  }

  scheduler();        
    80000fd2:	00001097          	auipc	ra,0x1
    80000fd6:	02a080e7          	jalr	42(ra) # 80001ffc <scheduler>
    consoleinit();
    80000fda:	fffff097          	auipc	ra,0xfffff
    80000fde:	4a8080e7          	jalr	1192(ra) # 80000482 <consoleinit>
    printfinit();
    80000fe2:	fffff097          	auipc	ra,0xfffff
    80000fe6:	7c2080e7          	jalr	1986(ra) # 800007a4 <printfinit>
    printf("\n");
    80000fea:	00007517          	auipc	a0,0x7
    80000fee:	0de50513          	addi	a0,a0,222 # 800080c8 <digits+0xb0>
    80000ff2:	fffff097          	auipc	ra,0xfffff
    80000ff6:	5cc080e7          	jalr	1484(ra) # 800005be <printf>
    printf("xv6 kernel is booting\n");
    80000ffa:	00007517          	auipc	a0,0x7
    80000ffe:	0a650513          	addi	a0,a0,166 # 800080a0 <digits+0x88>
    80001002:	fffff097          	auipc	ra,0xfffff
    80001006:	5bc080e7          	jalr	1468(ra) # 800005be <printf>
    printf("\n");
    8000100a:	00007517          	auipc	a0,0x7
    8000100e:	0be50513          	addi	a0,a0,190 # 800080c8 <digits+0xb0>
    80001012:	fffff097          	auipc	ra,0xfffff
    80001016:	5ac080e7          	jalr	1452(ra) # 800005be <printf>
    kinit();         // physical page allocator
    8000101a:	00000097          	auipc	ra,0x0
    8000101e:	b1c080e7          	jalr	-1252(ra) # 80000b36 <kinit>
    kvminit();       // create kernel page table
    80001022:	00000097          	auipc	ra,0x0
    80001026:	2a6080e7          	jalr	678(ra) # 800012c8 <kvminit>
    kvminithart();   // turn on paging
    8000102a:	00000097          	auipc	ra,0x0
    8000102e:	068080e7          	jalr	104(ra) # 80001092 <kvminithart>
    procinit();      // process table
    80001032:	00001097          	auipc	ra,0x1
    80001036:	98c080e7          	jalr	-1652(ra) # 800019be <procinit>
    trapinit();      // trap vectors
    8000103a:	00001097          	auipc	ra,0x1
    8000103e:	71e080e7          	jalr	1822(ra) # 80002758 <trapinit>
    trapinithart();  // install kernel trap vector
    80001042:	00001097          	auipc	ra,0x1
    80001046:	73e080e7          	jalr	1854(ra) # 80002780 <trapinithart>
    plicinit();      // set up interrupt controller
    8000104a:	00005097          	auipc	ra,0x5
    8000104e:	e70080e7          	jalr	-400(ra) # 80005eba <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001052:	00005097          	auipc	ra,0x5
    80001056:	e7e080e7          	jalr	-386(ra) # 80005ed0 <plicinithart>
    binit();         // buffer cache
    8000105a:	00002097          	auipc	ra,0x2
    8000105e:	f52080e7          	jalr	-174(ra) # 80002fac <binit>
    iinit();         // inode cache
    80001062:	00002097          	auipc	ra,0x2
    80001066:	624080e7          	jalr	1572(ra) # 80003686 <iinit>
    fileinit();      // file table
    8000106a:	00003097          	auipc	ra,0x3
    8000106e:	5ea080e7          	jalr	1514(ra) # 80004654 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001072:	00005097          	auipc	ra,0x5
    80001076:	f68080e7          	jalr	-152(ra) # 80005fda <virtio_disk_init>
    userinit();      // first user process
    8000107a:	00001097          	auipc	ra,0x1
    8000107e:	d10080e7          	jalr	-752(ra) # 80001d8a <userinit>
    __sync_synchronize();
    80001082:	0ff0000f          	fence
    started = 1;
    80001086:	4785                	li	a5,1
    80001088:	00008717          	auipc	a4,0x8
    8000108c:	f8f72223          	sw	a5,-124(a4) # 8000900c <started>
    80001090:	b789                	j	80000fd2 <main+0x56>

0000000080001092 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001092:	1141                	addi	sp,sp,-16
    80001094:	e422                	sd	s0,8(sp)
    80001096:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001098:	00008797          	auipc	a5,0x8
    8000109c:	f7878793          	addi	a5,a5,-136 # 80009010 <kernel_pagetable>
    800010a0:	639c                	ld	a5,0(a5)
    800010a2:	83b1                	srli	a5,a5,0xc
    800010a4:	577d                	li	a4,-1
    800010a6:	177e                	slli	a4,a4,0x3f
    800010a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800010aa:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800010ae:	12000073          	sfence.vma
  sfence_vma();
}
    800010b2:	6422                	ld	s0,8(sp)
    800010b4:	0141                	addi	sp,sp,16
    800010b6:	8082                	ret

00000000800010b8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800010b8:	7139                	addi	sp,sp,-64
    800010ba:	fc06                	sd	ra,56(sp)
    800010bc:	f822                	sd	s0,48(sp)
    800010be:	f426                	sd	s1,40(sp)
    800010c0:	f04a                	sd	s2,32(sp)
    800010c2:	ec4e                	sd	s3,24(sp)
    800010c4:	e852                	sd	s4,16(sp)
    800010c6:	e456                	sd	s5,8(sp)
    800010c8:	e05a                	sd	s6,0(sp)
    800010ca:	0080                	addi	s0,sp,64
    800010cc:	84aa                	mv	s1,a0
    800010ce:	89ae                	mv	s3,a1
    800010d0:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    800010d2:	57fd                	li	a5,-1
    800010d4:	83e9                	srli	a5,a5,0x1a
    800010d6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800010d8:	4ab1                	li	s5,12
  if(va >= MAXVA)
    800010da:	04b7f263          	bleu	a1,a5,8000111e <walk+0x66>
    panic("walk");
    800010de:	00007517          	auipc	a0,0x7
    800010e2:	ff250513          	addi	a0,a0,-14 # 800080d0 <digits+0xb8>
    800010e6:	fffff097          	auipc	ra,0xfffff
    800010ea:	48e080e7          	jalr	1166(ra) # 80000574 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010ee:	060b0663          	beqz	s6,8000115a <walk+0xa2>
    800010f2:	00000097          	auipc	ra,0x0
    800010f6:	a80080e7          	jalr	-1408(ra) # 80000b72 <kalloc>
    800010fa:	84aa                	mv	s1,a0
    800010fc:	c529                	beqz	a0,80001146 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	00000097          	auipc	ra,0x0
    80001106:	ca6080e7          	jalr	-858(ra) # 80000da8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000110a:	00c4d793          	srli	a5,s1,0xc
    8000110e:	07aa                	slli	a5,a5,0xa
    80001110:	0017e793          	ori	a5,a5,1
    80001114:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001118:	3a5d                	addiw	s4,s4,-9
    8000111a:	035a0063          	beq	s4,s5,8000113a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000111e:	0149d933          	srl	s2,s3,s4
    80001122:	1ff97913          	andi	s2,s2,511
    80001126:	090e                	slli	s2,s2,0x3
    80001128:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000112a:	00093483          	ld	s1,0(s2)
    8000112e:	0014f793          	andi	a5,s1,1
    80001132:	dfd5                	beqz	a5,800010ee <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001134:	80a9                	srli	s1,s1,0xa
    80001136:	04b2                	slli	s1,s1,0xc
    80001138:	b7c5                	j	80001118 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000113a:	00c9d513          	srli	a0,s3,0xc
    8000113e:	1ff57513          	andi	a0,a0,511
    80001142:	050e                	slli	a0,a0,0x3
    80001144:	9526                	add	a0,a0,s1
}
    80001146:	70e2                	ld	ra,56(sp)
    80001148:	7442                	ld	s0,48(sp)
    8000114a:	74a2                	ld	s1,40(sp)
    8000114c:	7902                	ld	s2,32(sp)
    8000114e:	69e2                	ld	s3,24(sp)
    80001150:	6a42                	ld	s4,16(sp)
    80001152:	6aa2                	ld	s5,8(sp)
    80001154:	6b02                	ld	s6,0(sp)
    80001156:	6121                	addi	sp,sp,64
    80001158:	8082                	ret
        return 0;
    8000115a:	4501                	li	a0,0
    8000115c:	b7ed                	j	80001146 <walk+0x8e>

000000008000115e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000115e:	57fd                	li	a5,-1
    80001160:	83e9                	srli	a5,a5,0x1a
    80001162:	00b7f463          	bleu	a1,a5,8000116a <walkaddr+0xc>
    return 0;
    80001166:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001168:	8082                	ret
{
    8000116a:	1141                	addi	sp,sp,-16
    8000116c:	e406                	sd	ra,8(sp)
    8000116e:	e022                	sd	s0,0(sp)
    80001170:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001172:	4601                	li	a2,0
    80001174:	00000097          	auipc	ra,0x0
    80001178:	f44080e7          	jalr	-188(ra) # 800010b8 <walk>
  if(pte == 0)
    8000117c:	c105                	beqz	a0,8000119c <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000117e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001180:	0117f693          	andi	a3,a5,17
    80001184:	4745                	li	a4,17
    return 0;
    80001186:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001188:	00e68663          	beq	a3,a4,80001194 <walkaddr+0x36>
}
    8000118c:	60a2                	ld	ra,8(sp)
    8000118e:	6402                	ld	s0,0(sp)
    80001190:	0141                	addi	sp,sp,16
    80001192:	8082                	ret
  pa = PTE2PA(*pte);
    80001194:	00a7d513          	srli	a0,a5,0xa
    80001198:	0532                	slli	a0,a0,0xc
  return pa;
    8000119a:	bfcd                	j	8000118c <walkaddr+0x2e>
    return 0;
    8000119c:	4501                	li	a0,0
    8000119e:	b7fd                	j	8000118c <walkaddr+0x2e>

00000000800011a0 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    800011a0:	1101                	addi	sp,sp,-32
    800011a2:	ec06                	sd	ra,24(sp)
    800011a4:	e822                	sd	s0,16(sp)
    800011a6:	e426                	sd	s1,8(sp)
    800011a8:	1000                	addi	s0,sp,32
    800011aa:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800011ac:	6785                	lui	a5,0x1
    800011ae:	17fd                	addi	a5,a5,-1
    800011b0:	00f574b3          	and	s1,a0,a5
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    800011b4:	4601                	li	a2,0
    800011b6:	00008797          	auipc	a5,0x8
    800011ba:	e5a78793          	addi	a5,a5,-422 # 80009010 <kernel_pagetable>
    800011be:	6388                	ld	a0,0(a5)
    800011c0:	00000097          	auipc	ra,0x0
    800011c4:	ef8080e7          	jalr	-264(ra) # 800010b8 <walk>
  if(pte == 0)
    800011c8:	cd09                	beqz	a0,800011e2 <kvmpa+0x42>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    800011ca:	6108                	ld	a0,0(a0)
    800011cc:	00157793          	andi	a5,a0,1
    800011d0:	c38d                	beqz	a5,800011f2 <kvmpa+0x52>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    800011d2:	8129                	srli	a0,a0,0xa
    800011d4:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    800011d6:	9526                	add	a0,a0,s1
    800011d8:	60e2                	ld	ra,24(sp)
    800011da:	6442                	ld	s0,16(sp)
    800011dc:	64a2                	ld	s1,8(sp)
    800011de:	6105                	addi	sp,sp,32
    800011e0:	8082                	ret
    panic("kvmpa");
    800011e2:	00007517          	auipc	a0,0x7
    800011e6:	ef650513          	addi	a0,a0,-266 # 800080d8 <digits+0xc0>
    800011ea:	fffff097          	auipc	ra,0xfffff
    800011ee:	38a080e7          	jalr	906(ra) # 80000574 <panic>
    panic("kvmpa");
    800011f2:	00007517          	auipc	a0,0x7
    800011f6:	ee650513          	addi	a0,a0,-282 # 800080d8 <digits+0xc0>
    800011fa:	fffff097          	auipc	ra,0xfffff
    800011fe:	37a080e7          	jalr	890(ra) # 80000574 <panic>

0000000080001202 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001202:	715d                	addi	sp,sp,-80
    80001204:	e486                	sd	ra,72(sp)
    80001206:	e0a2                	sd	s0,64(sp)
    80001208:	fc26                	sd	s1,56(sp)
    8000120a:	f84a                	sd	s2,48(sp)
    8000120c:	f44e                	sd	s3,40(sp)
    8000120e:	f052                	sd	s4,32(sp)
    80001210:	ec56                	sd	s5,24(sp)
    80001212:	e85a                	sd	s6,16(sp)
    80001214:	e45e                	sd	s7,8(sp)
    80001216:	0880                	addi	s0,sp,80
    80001218:	8aaa                	mv	s5,a0
    8000121a:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    8000121c:	79fd                	lui	s3,0xfffff
    8000121e:	0135fa33          	and	s4,a1,s3
  last = PGROUNDDOWN(va + size - 1);
    80001222:	167d                	addi	a2,a2,-1
    80001224:	962e                	add	a2,a2,a1
    80001226:	013679b3          	and	s3,a2,s3
  a = PGROUNDDOWN(va);
    8000122a:	8952                	mv	s2,s4
    8000122c:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001230:	6b85                	lui	s7,0x1
    80001232:	a811                	j	80001246 <mappages+0x44>
      panic("remap");
    80001234:	00007517          	auipc	a0,0x7
    80001238:	eac50513          	addi	a0,a0,-340 # 800080e0 <digits+0xc8>
    8000123c:	fffff097          	auipc	ra,0xfffff
    80001240:	338080e7          	jalr	824(ra) # 80000574 <panic>
    a += PGSIZE;
    80001244:	995e                	add	s2,s2,s7
  for(;;){
    80001246:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000124a:	4605                	li	a2,1
    8000124c:	85ca                	mv	a1,s2
    8000124e:	8556                	mv	a0,s5
    80001250:	00000097          	auipc	ra,0x0
    80001254:	e68080e7          	jalr	-408(ra) # 800010b8 <walk>
    80001258:	cd19                	beqz	a0,80001276 <mappages+0x74>
    if(*pte & PTE_V)
    8000125a:	611c                	ld	a5,0(a0)
    8000125c:	8b85                	andi	a5,a5,1
    8000125e:	fbf9                	bnez	a5,80001234 <mappages+0x32>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001260:	80b1                	srli	s1,s1,0xc
    80001262:	04aa                	slli	s1,s1,0xa
    80001264:	0164e4b3          	or	s1,s1,s6
    80001268:	0014e493          	ori	s1,s1,1
    8000126c:	e104                	sd	s1,0(a0)
    if(a == last)
    8000126e:	fd391be3          	bne	s2,s3,80001244 <mappages+0x42>
    pa += PGSIZE;
  }
  return 0;
    80001272:	4501                	li	a0,0
    80001274:	a011                	j	80001278 <mappages+0x76>
      return -1;
    80001276:	557d                	li	a0,-1
}
    80001278:	60a6                	ld	ra,72(sp)
    8000127a:	6406                	ld	s0,64(sp)
    8000127c:	74e2                	ld	s1,56(sp)
    8000127e:	7942                	ld	s2,48(sp)
    80001280:	79a2                	ld	s3,40(sp)
    80001282:	7a02                	ld	s4,32(sp)
    80001284:	6ae2                	ld	s5,24(sp)
    80001286:	6b42                	ld	s6,16(sp)
    80001288:	6ba2                	ld	s7,8(sp)
    8000128a:	6161                	addi	sp,sp,80
    8000128c:	8082                	ret

000000008000128e <kvmmap>:
{
    8000128e:	1141                	addi	sp,sp,-16
    80001290:	e406                	sd	ra,8(sp)
    80001292:	e022                	sd	s0,0(sp)
    80001294:	0800                	addi	s0,sp,16
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001296:	8736                	mv	a4,a3
    80001298:	86ae                	mv	a3,a1
    8000129a:	85aa                	mv	a1,a0
    8000129c:	00008797          	auipc	a5,0x8
    800012a0:	d7478793          	addi	a5,a5,-652 # 80009010 <kernel_pagetable>
    800012a4:	6388                	ld	a0,0(a5)
    800012a6:	00000097          	auipc	ra,0x0
    800012aa:	f5c080e7          	jalr	-164(ra) # 80001202 <mappages>
    800012ae:	e509                	bnez	a0,800012b8 <kvmmap+0x2a>
}
    800012b0:	60a2                	ld	ra,8(sp)
    800012b2:	6402                	ld	s0,0(sp)
    800012b4:	0141                	addi	sp,sp,16
    800012b6:	8082                	ret
    panic("kvmmap");
    800012b8:	00007517          	auipc	a0,0x7
    800012bc:	e3050513          	addi	a0,a0,-464 # 800080e8 <digits+0xd0>
    800012c0:	fffff097          	auipc	ra,0xfffff
    800012c4:	2b4080e7          	jalr	692(ra) # 80000574 <panic>

00000000800012c8 <kvminit>:
{
    800012c8:	1101                	addi	sp,sp,-32
    800012ca:	ec06                	sd	ra,24(sp)
    800012cc:	e822                	sd	s0,16(sp)
    800012ce:	e426                	sd	s1,8(sp)
    800012d0:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800012d2:	00000097          	auipc	ra,0x0
    800012d6:	8a0080e7          	jalr	-1888(ra) # 80000b72 <kalloc>
    800012da:	00008797          	auipc	a5,0x8
    800012de:	d2a7bb23          	sd	a0,-714(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800012e2:	6605                	lui	a2,0x1
    800012e4:	4581                	li	a1,0
    800012e6:	00000097          	auipc	ra,0x0
    800012ea:	ac2080e7          	jalr	-1342(ra) # 80000da8 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012ee:	4699                	li	a3,6
    800012f0:	6605                	lui	a2,0x1
    800012f2:	100005b7          	lui	a1,0x10000
    800012f6:	10000537          	lui	a0,0x10000
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	f94080e7          	jalr	-108(ra) # 8000128e <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001302:	4699                	li	a3,6
    80001304:	6605                	lui	a2,0x1
    80001306:	100015b7          	lui	a1,0x10001
    8000130a:	10001537          	lui	a0,0x10001
    8000130e:	00000097          	auipc	ra,0x0
    80001312:	f80080e7          	jalr	-128(ra) # 8000128e <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001316:	4699                	li	a3,6
    80001318:	6641                	lui	a2,0x10
    8000131a:	020005b7          	lui	a1,0x2000
    8000131e:	02000537          	lui	a0,0x2000
    80001322:	00000097          	auipc	ra,0x0
    80001326:	f6c080e7          	jalr	-148(ra) # 8000128e <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000132a:	4699                	li	a3,6
    8000132c:	00400637          	lui	a2,0x400
    80001330:	0c0005b7          	lui	a1,0xc000
    80001334:	0c000537          	lui	a0,0xc000
    80001338:	00000097          	auipc	ra,0x0
    8000133c:	f56080e7          	jalr	-170(ra) # 8000128e <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001340:	00007497          	auipc	s1,0x7
    80001344:	cc048493          	addi	s1,s1,-832 # 80008000 <etext>
    80001348:	46a9                	li	a3,10
    8000134a:	80007617          	auipc	a2,0x80007
    8000134e:	cb660613          	addi	a2,a2,-842 # 8000 <_entry-0x7fff8000>
    80001352:	4585                	li	a1,1
    80001354:	05fe                	slli	a1,a1,0x1f
    80001356:	852e                	mv	a0,a1
    80001358:	00000097          	auipc	ra,0x0
    8000135c:	f36080e7          	jalr	-202(ra) # 8000128e <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001360:	4699                	li	a3,6
    80001362:	4645                	li	a2,17
    80001364:	066e                	slli	a2,a2,0x1b
    80001366:	8e05                	sub	a2,a2,s1
    80001368:	85a6                	mv	a1,s1
    8000136a:	8526                	mv	a0,s1
    8000136c:	00000097          	auipc	ra,0x0
    80001370:	f22080e7          	jalr	-222(ra) # 8000128e <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001374:	46a9                	li	a3,10
    80001376:	6605                	lui	a2,0x1
    80001378:	00006597          	auipc	a1,0x6
    8000137c:	c8858593          	addi	a1,a1,-888 # 80007000 <_trampoline>
    80001380:	04000537          	lui	a0,0x4000
    80001384:	157d                	addi	a0,a0,-1
    80001386:	0532                	slli	a0,a0,0xc
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	f06080e7          	jalr	-250(ra) # 8000128e <kvmmap>
}
    80001390:	60e2                	ld	ra,24(sp)
    80001392:	6442                	ld	s0,16(sp)
    80001394:	64a2                	ld	s1,8(sp)
    80001396:	6105                	addi	sp,sp,32
    80001398:	8082                	ret

000000008000139a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000139a:	715d                	addi	sp,sp,-80
    8000139c:	e486                	sd	ra,72(sp)
    8000139e:	e0a2                	sd	s0,64(sp)
    800013a0:	fc26                	sd	s1,56(sp)
    800013a2:	f84a                	sd	s2,48(sp)
    800013a4:	f44e                	sd	s3,40(sp)
    800013a6:	f052                	sd	s4,32(sp)
    800013a8:	ec56                	sd	s5,24(sp)
    800013aa:	e85a                	sd	s6,16(sp)
    800013ac:	e45e                	sd	s7,8(sp)
    800013ae:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800013b0:	6785                	lui	a5,0x1
    800013b2:	17fd                	addi	a5,a5,-1
    800013b4:	8fed                	and	a5,a5,a1
    800013b6:	e795                	bnez	a5,800013e2 <uvmunmap+0x48>
    800013b8:	8a2a                	mv	s4,a0
    800013ba:	84ae                	mv	s1,a1
    800013bc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013be:	0632                	slli	a2,a2,0xc
    800013c0:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800013c4:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013c6:	6b05                	lui	s6,0x1
    800013c8:	0735e863          	bltu	a1,s3,80001438 <uvmunmap+0x9e>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800013cc:	60a6                	ld	ra,72(sp)
    800013ce:	6406                	ld	s0,64(sp)
    800013d0:	74e2                	ld	s1,56(sp)
    800013d2:	7942                	ld	s2,48(sp)
    800013d4:	79a2                	ld	s3,40(sp)
    800013d6:	7a02                	ld	s4,32(sp)
    800013d8:	6ae2                	ld	s5,24(sp)
    800013da:	6b42                	ld	s6,16(sp)
    800013dc:	6ba2                	ld	s7,8(sp)
    800013de:	6161                	addi	sp,sp,80
    800013e0:	8082                	ret
    panic("uvmunmap: not aligned");
    800013e2:	00007517          	auipc	a0,0x7
    800013e6:	d0e50513          	addi	a0,a0,-754 # 800080f0 <digits+0xd8>
    800013ea:	fffff097          	auipc	ra,0xfffff
    800013ee:	18a080e7          	jalr	394(ra) # 80000574 <panic>
      panic("uvmunmap: walk");
    800013f2:	00007517          	auipc	a0,0x7
    800013f6:	d1650513          	addi	a0,a0,-746 # 80008108 <digits+0xf0>
    800013fa:	fffff097          	auipc	ra,0xfffff
    800013fe:	17a080e7          	jalr	378(ra) # 80000574 <panic>
      panic("uvmunmap: not mapped");
    80001402:	00007517          	auipc	a0,0x7
    80001406:	d1650513          	addi	a0,a0,-746 # 80008118 <digits+0x100>
    8000140a:	fffff097          	auipc	ra,0xfffff
    8000140e:	16a080e7          	jalr	362(ra) # 80000574 <panic>
      panic("uvmunmap: not a leaf");
    80001412:	00007517          	auipc	a0,0x7
    80001416:	d1e50513          	addi	a0,a0,-738 # 80008130 <digits+0x118>
    8000141a:	fffff097          	auipc	ra,0xfffff
    8000141e:	15a080e7          	jalr	346(ra) # 80000574 <panic>
      uint64 pa = PTE2PA(*pte);
    80001422:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001424:	0532                	slli	a0,a0,0xc
    80001426:	fffff097          	auipc	ra,0xfffff
    8000142a:	64c080e7          	jalr	1612(ra) # 80000a72 <kfree>
    *pte = 0;
    8000142e:	00093023          	sd	zero,0(s2)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001432:	94da                	add	s1,s1,s6
    80001434:	f934fce3          	bleu	s3,s1,800013cc <uvmunmap+0x32>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001438:	4601                	li	a2,0
    8000143a:	85a6                	mv	a1,s1
    8000143c:	8552                	mv	a0,s4
    8000143e:	00000097          	auipc	ra,0x0
    80001442:	c7a080e7          	jalr	-902(ra) # 800010b8 <walk>
    80001446:	892a                	mv	s2,a0
    80001448:	d54d                	beqz	a0,800013f2 <uvmunmap+0x58>
    if((*pte & PTE_V) == 0)
    8000144a:	6108                	ld	a0,0(a0)
    8000144c:	00157793          	andi	a5,a0,1
    80001450:	dbcd                	beqz	a5,80001402 <uvmunmap+0x68>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001452:	3ff57793          	andi	a5,a0,1023
    80001456:	fb778ee3          	beq	a5,s7,80001412 <uvmunmap+0x78>
    if(do_free){
    8000145a:	fc0a8ae3          	beqz	s5,8000142e <uvmunmap+0x94>
    8000145e:	b7d1                	j	80001422 <uvmunmap+0x88>

0000000080001460 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001460:	1101                	addi	sp,sp,-32
    80001462:	ec06                	sd	ra,24(sp)
    80001464:	e822                	sd	s0,16(sp)
    80001466:	e426                	sd	s1,8(sp)
    80001468:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000146a:	fffff097          	auipc	ra,0xfffff
    8000146e:	708080e7          	jalr	1800(ra) # 80000b72 <kalloc>
    80001472:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001474:	c519                	beqz	a0,80001482 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001476:	6605                	lui	a2,0x1
    80001478:	4581                	li	a1,0
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	92e080e7          	jalr	-1746(ra) # 80000da8 <memset>
  return pagetable;
}
    80001482:	8526                	mv	a0,s1
    80001484:	60e2                	ld	ra,24(sp)
    80001486:	6442                	ld	s0,16(sp)
    80001488:	64a2                	ld	s1,8(sp)
    8000148a:	6105                	addi	sp,sp,32
    8000148c:	8082                	ret

000000008000148e <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000148e:	7179                	addi	sp,sp,-48
    80001490:	f406                	sd	ra,40(sp)
    80001492:	f022                	sd	s0,32(sp)
    80001494:	ec26                	sd	s1,24(sp)
    80001496:	e84a                	sd	s2,16(sp)
    80001498:	e44e                	sd	s3,8(sp)
    8000149a:	e052                	sd	s4,0(sp)
    8000149c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000149e:	6785                	lui	a5,0x1
    800014a0:	04f67863          	bleu	a5,a2,800014f0 <uvminit+0x62>
    800014a4:	8a2a                	mv	s4,a0
    800014a6:	89ae                	mv	s3,a1
    800014a8:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800014aa:	fffff097          	auipc	ra,0xfffff
    800014ae:	6c8080e7          	jalr	1736(ra) # 80000b72 <kalloc>
    800014b2:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800014b4:	6605                	lui	a2,0x1
    800014b6:	4581                	li	a1,0
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	8f0080e7          	jalr	-1808(ra) # 80000da8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800014c0:	4779                	li	a4,30
    800014c2:	86ca                	mv	a3,s2
    800014c4:	6605                	lui	a2,0x1
    800014c6:	4581                	li	a1,0
    800014c8:	8552                	mv	a0,s4
    800014ca:	00000097          	auipc	ra,0x0
    800014ce:	d38080e7          	jalr	-712(ra) # 80001202 <mappages>
  memmove(mem, src, sz);
    800014d2:	8626                	mv	a2,s1
    800014d4:	85ce                	mv	a1,s3
    800014d6:	854a                	mv	a0,s2
    800014d8:	00000097          	auipc	ra,0x0
    800014dc:	93c080e7          	jalr	-1732(ra) # 80000e14 <memmove>
}
    800014e0:	70a2                	ld	ra,40(sp)
    800014e2:	7402                	ld	s0,32(sp)
    800014e4:	64e2                	ld	s1,24(sp)
    800014e6:	6942                	ld	s2,16(sp)
    800014e8:	69a2                	ld	s3,8(sp)
    800014ea:	6a02                	ld	s4,0(sp)
    800014ec:	6145                	addi	sp,sp,48
    800014ee:	8082                	ret
    panic("inituvm: more than a page");
    800014f0:	00007517          	auipc	a0,0x7
    800014f4:	c5850513          	addi	a0,a0,-936 # 80008148 <digits+0x130>
    800014f8:	fffff097          	auipc	ra,0xfffff
    800014fc:	07c080e7          	jalr	124(ra) # 80000574 <panic>

0000000080001500 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001500:	1101                	addi	sp,sp,-32
    80001502:	ec06                	sd	ra,24(sp)
    80001504:	e822                	sd	s0,16(sp)
    80001506:	e426                	sd	s1,8(sp)
    80001508:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000150a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000150c:	00b67d63          	bleu	a1,a2,80001526 <uvmdealloc+0x26>
    80001510:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001512:	6605                	lui	a2,0x1
    80001514:	167d                	addi	a2,a2,-1
    80001516:	00c487b3          	add	a5,s1,a2
    8000151a:	777d                	lui	a4,0xfffff
    8000151c:	8ff9                	and	a5,a5,a4
    8000151e:	962e                	add	a2,a2,a1
    80001520:	8e79                	and	a2,a2,a4
    80001522:	00c7e863          	bltu	a5,a2,80001532 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001526:	8526                	mv	a0,s1
    80001528:	60e2                	ld	ra,24(sp)
    8000152a:	6442                	ld	s0,16(sp)
    8000152c:	64a2                	ld	s1,8(sp)
    8000152e:	6105                	addi	sp,sp,32
    80001530:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001532:	8e1d                	sub	a2,a2,a5
    80001534:	8231                	srli	a2,a2,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001536:	4685                	li	a3,1
    80001538:	2601                	sext.w	a2,a2
    8000153a:	85be                	mv	a1,a5
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	e5e080e7          	jalr	-418(ra) # 8000139a <uvmunmap>
    80001544:	b7cd                	j	80001526 <uvmdealloc+0x26>

0000000080001546 <uvmalloc>:
  if(newsz < oldsz)
    80001546:	0ab66163          	bltu	a2,a1,800015e8 <uvmalloc+0xa2>
{
    8000154a:	7139                	addi	sp,sp,-64
    8000154c:	fc06                	sd	ra,56(sp)
    8000154e:	f822                	sd	s0,48(sp)
    80001550:	f426                	sd	s1,40(sp)
    80001552:	f04a                	sd	s2,32(sp)
    80001554:	ec4e                	sd	s3,24(sp)
    80001556:	e852                	sd	s4,16(sp)
    80001558:	e456                	sd	s5,8(sp)
    8000155a:	0080                	addi	s0,sp,64
  oldsz = PGROUNDUP(oldsz);
    8000155c:	6a05                	lui	s4,0x1
    8000155e:	1a7d                	addi	s4,s4,-1
    80001560:	95d2                	add	a1,a1,s4
    80001562:	7a7d                	lui	s4,0xfffff
    80001564:	0145fa33          	and	s4,a1,s4
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001568:	08ca7263          	bleu	a2,s4,800015ec <uvmalloc+0xa6>
    8000156c:	89b2                	mv	s3,a2
    8000156e:	8aaa                	mv	s5,a0
    80001570:	8952                	mv	s2,s4
    mem = kalloc();
    80001572:	fffff097          	auipc	ra,0xfffff
    80001576:	600080e7          	jalr	1536(ra) # 80000b72 <kalloc>
    8000157a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000157c:	c51d                	beqz	a0,800015aa <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000157e:	6605                	lui	a2,0x1
    80001580:	4581                	li	a1,0
    80001582:	00000097          	auipc	ra,0x0
    80001586:	826080e7          	jalr	-2010(ra) # 80000da8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000158a:	4779                	li	a4,30
    8000158c:	86a6                	mv	a3,s1
    8000158e:	6605                	lui	a2,0x1
    80001590:	85ca                	mv	a1,s2
    80001592:	8556                	mv	a0,s5
    80001594:	00000097          	auipc	ra,0x0
    80001598:	c6e080e7          	jalr	-914(ra) # 80001202 <mappages>
    8000159c:	e905                	bnez	a0,800015cc <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000159e:	6785                	lui	a5,0x1
    800015a0:	993e                	add	s2,s2,a5
    800015a2:	fd3968e3          	bltu	s2,s3,80001572 <uvmalloc+0x2c>
  return newsz;
    800015a6:	854e                	mv	a0,s3
    800015a8:	a809                	j	800015ba <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800015aa:	8652                	mv	a2,s4
    800015ac:	85ca                	mv	a1,s2
    800015ae:	8556                	mv	a0,s5
    800015b0:	00000097          	auipc	ra,0x0
    800015b4:	f50080e7          	jalr	-176(ra) # 80001500 <uvmdealloc>
      return 0;
    800015b8:	4501                	li	a0,0
}
    800015ba:	70e2                	ld	ra,56(sp)
    800015bc:	7442                	ld	s0,48(sp)
    800015be:	74a2                	ld	s1,40(sp)
    800015c0:	7902                	ld	s2,32(sp)
    800015c2:	69e2                	ld	s3,24(sp)
    800015c4:	6a42                	ld	s4,16(sp)
    800015c6:	6aa2                	ld	s5,8(sp)
    800015c8:	6121                	addi	sp,sp,64
    800015ca:	8082                	ret
      kfree(mem);
    800015cc:	8526                	mv	a0,s1
    800015ce:	fffff097          	auipc	ra,0xfffff
    800015d2:	4a4080e7          	jalr	1188(ra) # 80000a72 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800015d6:	8652                	mv	a2,s4
    800015d8:	85ca                	mv	a1,s2
    800015da:	8556                	mv	a0,s5
    800015dc:	00000097          	auipc	ra,0x0
    800015e0:	f24080e7          	jalr	-220(ra) # 80001500 <uvmdealloc>
      return 0;
    800015e4:	4501                	li	a0,0
    800015e6:	bfd1                	j	800015ba <uvmalloc+0x74>
    return oldsz;
    800015e8:	852e                	mv	a0,a1
}
    800015ea:	8082                	ret
  return newsz;
    800015ec:	8532                	mv	a0,a2
    800015ee:	b7f1                	j	800015ba <uvmalloc+0x74>

00000000800015f0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800015f0:	7179                	addi	sp,sp,-48
    800015f2:	f406                	sd	ra,40(sp)
    800015f4:	f022                	sd	s0,32(sp)
    800015f6:	ec26                	sd	s1,24(sp)
    800015f8:	e84a                	sd	s2,16(sp)
    800015fa:	e44e                	sd	s3,8(sp)
    800015fc:	e052                	sd	s4,0(sp)
    800015fe:	1800                	addi	s0,sp,48
    80001600:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001602:	84aa                	mv	s1,a0
    80001604:	6905                	lui	s2,0x1
    80001606:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001608:	4985                	li	s3,1
    8000160a:	a821                	j	80001622 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000160c:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000160e:	0532                	slli	a0,a0,0xc
    80001610:	00000097          	auipc	ra,0x0
    80001614:	fe0080e7          	jalr	-32(ra) # 800015f0 <freewalk>
      pagetable[i] = 0;
    80001618:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000161c:	04a1                	addi	s1,s1,8
    8000161e:	03248163          	beq	s1,s2,80001640 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001622:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001624:	00f57793          	andi	a5,a0,15
    80001628:	ff3782e3          	beq	a5,s3,8000160c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000162c:	8905                	andi	a0,a0,1
    8000162e:	d57d                	beqz	a0,8000161c <freewalk+0x2c>
      panic("freewalk: leaf");
    80001630:	00007517          	auipc	a0,0x7
    80001634:	b3850513          	addi	a0,a0,-1224 # 80008168 <digits+0x150>
    80001638:	fffff097          	auipc	ra,0xfffff
    8000163c:	f3c080e7          	jalr	-196(ra) # 80000574 <panic>
    }
  }
  kfree((void*)pagetable);
    80001640:	8552                	mv	a0,s4
    80001642:	fffff097          	auipc	ra,0xfffff
    80001646:	430080e7          	jalr	1072(ra) # 80000a72 <kfree>
}
    8000164a:	70a2                	ld	ra,40(sp)
    8000164c:	7402                	ld	s0,32(sp)
    8000164e:	64e2                	ld	s1,24(sp)
    80001650:	6942                	ld	s2,16(sp)
    80001652:	69a2                	ld	s3,8(sp)
    80001654:	6a02                	ld	s4,0(sp)
    80001656:	6145                	addi	sp,sp,48
    80001658:	8082                	ret

000000008000165a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000165a:	1101                	addi	sp,sp,-32
    8000165c:	ec06                	sd	ra,24(sp)
    8000165e:	e822                	sd	s0,16(sp)
    80001660:	e426                	sd	s1,8(sp)
    80001662:	1000                	addi	s0,sp,32
    80001664:	84aa                	mv	s1,a0
  if(sz > 0)
    80001666:	e999                	bnez	a1,8000167c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001668:	8526                	mv	a0,s1
    8000166a:	00000097          	auipc	ra,0x0
    8000166e:	f86080e7          	jalr	-122(ra) # 800015f0 <freewalk>
}
    80001672:	60e2                	ld	ra,24(sp)
    80001674:	6442                	ld	s0,16(sp)
    80001676:	64a2                	ld	s1,8(sp)
    80001678:	6105                	addi	sp,sp,32
    8000167a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000167c:	6605                	lui	a2,0x1
    8000167e:	167d                	addi	a2,a2,-1
    80001680:	962e                	add	a2,a2,a1
    80001682:	4685                	li	a3,1
    80001684:	8231                	srli	a2,a2,0xc
    80001686:	4581                	li	a1,0
    80001688:	00000097          	auipc	ra,0x0
    8000168c:	d12080e7          	jalr	-750(ra) # 8000139a <uvmunmap>
    80001690:	bfe1                	j	80001668 <uvmfree+0xe>

0000000080001692 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001692:	c679                	beqz	a2,80001760 <uvmcopy+0xce>
{
    80001694:	715d                	addi	sp,sp,-80
    80001696:	e486                	sd	ra,72(sp)
    80001698:	e0a2                	sd	s0,64(sp)
    8000169a:	fc26                	sd	s1,56(sp)
    8000169c:	f84a                	sd	s2,48(sp)
    8000169e:	f44e                	sd	s3,40(sp)
    800016a0:	f052                	sd	s4,32(sp)
    800016a2:	ec56                	sd	s5,24(sp)
    800016a4:	e85a                	sd	s6,16(sp)
    800016a6:	e45e                	sd	s7,8(sp)
    800016a8:	0880                	addi	s0,sp,80
    800016aa:	8ab2                	mv	s5,a2
    800016ac:	8b2e                	mv	s6,a1
    800016ae:	8baa                	mv	s7,a0
  for(i = 0; i < sz; i += PGSIZE){
    800016b0:	4901                	li	s2,0
    if((pte = walk(old, i, 0)) == 0)
    800016b2:	4601                	li	a2,0
    800016b4:	85ca                	mv	a1,s2
    800016b6:	855e                	mv	a0,s7
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	a00080e7          	jalr	-1536(ra) # 800010b8 <walk>
    800016c0:	c531                	beqz	a0,8000170c <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800016c2:	6118                	ld	a4,0(a0)
    800016c4:	00177793          	andi	a5,a4,1
    800016c8:	cbb1                	beqz	a5,8000171c <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800016ca:	00a75593          	srli	a1,a4,0xa
    800016ce:	00c59993          	slli	s3,a1,0xc
    flags = PTE_FLAGS(*pte);
    800016d2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800016d6:	fffff097          	auipc	ra,0xfffff
    800016da:	49c080e7          	jalr	1180(ra) # 80000b72 <kalloc>
    800016de:	8a2a                	mv	s4,a0
    800016e0:	c939                	beqz	a0,80001736 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016e2:	6605                	lui	a2,0x1
    800016e4:	85ce                	mv	a1,s3
    800016e6:	fffff097          	auipc	ra,0xfffff
    800016ea:	72e080e7          	jalr	1838(ra) # 80000e14 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800016ee:	8726                	mv	a4,s1
    800016f0:	86d2                	mv	a3,s4
    800016f2:	6605                	lui	a2,0x1
    800016f4:	85ca                	mv	a1,s2
    800016f6:	855a                	mv	a0,s6
    800016f8:	00000097          	auipc	ra,0x0
    800016fc:	b0a080e7          	jalr	-1270(ra) # 80001202 <mappages>
    80001700:	e515                	bnez	a0,8000172c <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001702:	6785                	lui	a5,0x1
    80001704:	993e                	add	s2,s2,a5
    80001706:	fb5966e3          	bltu	s2,s5,800016b2 <uvmcopy+0x20>
    8000170a:	a081                	j	8000174a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    8000170c:	00007517          	auipc	a0,0x7
    80001710:	a6c50513          	addi	a0,a0,-1428 # 80008178 <digits+0x160>
    80001714:	fffff097          	auipc	ra,0xfffff
    80001718:	e60080e7          	jalr	-416(ra) # 80000574 <panic>
      panic("uvmcopy: page not present");
    8000171c:	00007517          	auipc	a0,0x7
    80001720:	a7c50513          	addi	a0,a0,-1412 # 80008198 <digits+0x180>
    80001724:	fffff097          	auipc	ra,0xfffff
    80001728:	e50080e7          	jalr	-432(ra) # 80000574 <panic>
      kfree(mem);
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	344080e7          	jalr	836(ra) # 80000a72 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001736:	4685                	li	a3,1
    80001738:	00c95613          	srli	a2,s2,0xc
    8000173c:	4581                	li	a1,0
    8000173e:	855a                	mv	a0,s6
    80001740:	00000097          	auipc	ra,0x0
    80001744:	c5a080e7          	jalr	-934(ra) # 8000139a <uvmunmap>
  return -1;
    80001748:	557d                	li	a0,-1
}
    8000174a:	60a6                	ld	ra,72(sp)
    8000174c:	6406                	ld	s0,64(sp)
    8000174e:	74e2                	ld	s1,56(sp)
    80001750:	7942                	ld	s2,48(sp)
    80001752:	79a2                	ld	s3,40(sp)
    80001754:	7a02                	ld	s4,32(sp)
    80001756:	6ae2                	ld	s5,24(sp)
    80001758:	6b42                	ld	s6,16(sp)
    8000175a:	6ba2                	ld	s7,8(sp)
    8000175c:	6161                	addi	sp,sp,80
    8000175e:	8082                	ret
  return 0;
    80001760:	4501                	li	a0,0
}
    80001762:	8082                	ret

0000000080001764 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001764:	1141                	addi	sp,sp,-16
    80001766:	e406                	sd	ra,8(sp)
    80001768:	e022                	sd	s0,0(sp)
    8000176a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000176c:	4601                	li	a2,0
    8000176e:	00000097          	auipc	ra,0x0
    80001772:	94a080e7          	jalr	-1718(ra) # 800010b8 <walk>
  if(pte == 0)
    80001776:	c901                	beqz	a0,80001786 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001778:	611c                	ld	a5,0(a0)
    8000177a:	9bbd                	andi	a5,a5,-17
    8000177c:	e11c                	sd	a5,0(a0)
}
    8000177e:	60a2                	ld	ra,8(sp)
    80001780:	6402                	ld	s0,0(sp)
    80001782:	0141                	addi	sp,sp,16
    80001784:	8082                	ret
    panic("uvmclear");
    80001786:	00007517          	auipc	a0,0x7
    8000178a:	a3250513          	addi	a0,a0,-1486 # 800081b8 <digits+0x1a0>
    8000178e:	fffff097          	auipc	ra,0xfffff
    80001792:	de6080e7          	jalr	-538(ra) # 80000574 <panic>

0000000080001796 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001796:	c6bd                	beqz	a3,80001804 <copyout+0x6e>
{
    80001798:	715d                	addi	sp,sp,-80
    8000179a:	e486                	sd	ra,72(sp)
    8000179c:	e0a2                	sd	s0,64(sp)
    8000179e:	fc26                	sd	s1,56(sp)
    800017a0:	f84a                	sd	s2,48(sp)
    800017a2:	f44e                	sd	s3,40(sp)
    800017a4:	f052                	sd	s4,32(sp)
    800017a6:	ec56                	sd	s5,24(sp)
    800017a8:	e85a                	sd	s6,16(sp)
    800017aa:	e45e                	sd	s7,8(sp)
    800017ac:	e062                	sd	s8,0(sp)
    800017ae:	0880                	addi	s0,sp,80
    800017b0:	8baa                	mv	s7,a0
    800017b2:	8a2e                	mv	s4,a1
    800017b4:	8ab2                	mv	s5,a2
    800017b6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800017b8:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800017ba:	6b05                	lui	s6,0x1
    800017bc:	a015                	j	800017e0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017be:	9552                	add	a0,a0,s4
    800017c0:	0004861b          	sext.w	a2,s1
    800017c4:	85d6                	mv	a1,s5
    800017c6:	41250533          	sub	a0,a0,s2
    800017ca:	fffff097          	auipc	ra,0xfffff
    800017ce:	64a080e7          	jalr	1610(ra) # 80000e14 <memmove>

    len -= n;
    800017d2:	409989b3          	sub	s3,s3,s1
    src += n;
    800017d6:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    800017d8:	01690a33          	add	s4,s2,s6
  while(len > 0){
    800017dc:	02098263          	beqz	s3,80001800 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800017e0:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    800017e4:	85ca                	mv	a1,s2
    800017e6:	855e                	mv	a0,s7
    800017e8:	00000097          	auipc	ra,0x0
    800017ec:	976080e7          	jalr	-1674(ra) # 8000115e <walkaddr>
    if(pa0 == 0)
    800017f0:	cd01                	beqz	a0,80001808 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800017f2:	414904b3          	sub	s1,s2,s4
    800017f6:	94da                	add	s1,s1,s6
    if(n > len)
    800017f8:	fc99f3e3          	bleu	s1,s3,800017be <copyout+0x28>
    800017fc:	84ce                	mv	s1,s3
    800017fe:	b7c1                	j	800017be <copyout+0x28>
  }
  return 0;
    80001800:	4501                	li	a0,0
    80001802:	a021                	j	8000180a <copyout+0x74>
    80001804:	4501                	li	a0,0
}
    80001806:	8082                	ret
      return -1;
    80001808:	557d                	li	a0,-1
}
    8000180a:	60a6                	ld	ra,72(sp)
    8000180c:	6406                	ld	s0,64(sp)
    8000180e:	74e2                	ld	s1,56(sp)
    80001810:	7942                	ld	s2,48(sp)
    80001812:	79a2                	ld	s3,40(sp)
    80001814:	7a02                	ld	s4,32(sp)
    80001816:	6ae2                	ld	s5,24(sp)
    80001818:	6b42                	ld	s6,16(sp)
    8000181a:	6ba2                	ld	s7,8(sp)
    8000181c:	6c02                	ld	s8,0(sp)
    8000181e:	6161                	addi	sp,sp,80
    80001820:	8082                	ret

0000000080001822 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001822:	caa5                	beqz	a3,80001892 <copyin+0x70>
{
    80001824:	715d                	addi	sp,sp,-80
    80001826:	e486                	sd	ra,72(sp)
    80001828:	e0a2                	sd	s0,64(sp)
    8000182a:	fc26                	sd	s1,56(sp)
    8000182c:	f84a                	sd	s2,48(sp)
    8000182e:	f44e                	sd	s3,40(sp)
    80001830:	f052                	sd	s4,32(sp)
    80001832:	ec56                	sd	s5,24(sp)
    80001834:	e85a                	sd	s6,16(sp)
    80001836:	e45e                	sd	s7,8(sp)
    80001838:	e062                	sd	s8,0(sp)
    8000183a:	0880                	addi	s0,sp,80
    8000183c:	8baa                	mv	s7,a0
    8000183e:	8aae                	mv	s5,a1
    80001840:	8a32                	mv	s4,a2
    80001842:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001844:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001846:	6b05                	lui	s6,0x1
    80001848:	a01d                	j	8000186e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000184a:	014505b3          	add	a1,a0,s4
    8000184e:	0004861b          	sext.w	a2,s1
    80001852:	412585b3          	sub	a1,a1,s2
    80001856:	8556                	mv	a0,s5
    80001858:	fffff097          	auipc	ra,0xfffff
    8000185c:	5bc080e7          	jalr	1468(ra) # 80000e14 <memmove>

    len -= n;
    80001860:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001864:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001866:	01690a33          	add	s4,s2,s6
  while(len > 0){
    8000186a:	02098263          	beqz	s3,8000188e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000186e:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    80001872:	85ca                	mv	a1,s2
    80001874:	855e                	mv	a0,s7
    80001876:	00000097          	auipc	ra,0x0
    8000187a:	8e8080e7          	jalr	-1816(ra) # 8000115e <walkaddr>
    if(pa0 == 0)
    8000187e:	cd01                	beqz	a0,80001896 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001880:	414904b3          	sub	s1,s2,s4
    80001884:	94da                	add	s1,s1,s6
    if(n > len)
    80001886:	fc99f2e3          	bleu	s1,s3,8000184a <copyin+0x28>
    8000188a:	84ce                	mv	s1,s3
    8000188c:	bf7d                	j	8000184a <copyin+0x28>
  }
  return 0;
    8000188e:	4501                	li	a0,0
    80001890:	a021                	j	80001898 <copyin+0x76>
    80001892:	4501                	li	a0,0
}
    80001894:	8082                	ret
      return -1;
    80001896:	557d                	li	a0,-1
}
    80001898:	60a6                	ld	ra,72(sp)
    8000189a:	6406                	ld	s0,64(sp)
    8000189c:	74e2                	ld	s1,56(sp)
    8000189e:	7942                	ld	s2,48(sp)
    800018a0:	79a2                	ld	s3,40(sp)
    800018a2:	7a02                	ld	s4,32(sp)
    800018a4:	6ae2                	ld	s5,24(sp)
    800018a6:	6b42                	ld	s6,16(sp)
    800018a8:	6ba2                	ld	s7,8(sp)
    800018aa:	6c02                	ld	s8,0(sp)
    800018ac:	6161                	addi	sp,sp,80
    800018ae:	8082                	ret

00000000800018b0 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800018b0:	ced5                	beqz	a3,8000196c <copyinstr+0xbc>
{
    800018b2:	715d                	addi	sp,sp,-80
    800018b4:	e486                	sd	ra,72(sp)
    800018b6:	e0a2                	sd	s0,64(sp)
    800018b8:	fc26                	sd	s1,56(sp)
    800018ba:	f84a                	sd	s2,48(sp)
    800018bc:	f44e                	sd	s3,40(sp)
    800018be:	f052                	sd	s4,32(sp)
    800018c0:	ec56                	sd	s5,24(sp)
    800018c2:	e85a                	sd	s6,16(sp)
    800018c4:	e45e                	sd	s7,8(sp)
    800018c6:	e062                	sd	s8,0(sp)
    800018c8:	0880                	addi	s0,sp,80
    800018ca:	8aaa                	mv	s5,a0
    800018cc:	84ae                	mv	s1,a1
    800018ce:	8c32                	mv	s8,a2
    800018d0:	8bb6                	mv	s7,a3
    va0 = PGROUNDDOWN(srcva);
    800018d2:	7a7d                	lui	s4,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018d4:	6985                	lui	s3,0x1
    800018d6:	4b05                	li	s6,1
    800018d8:	a801                	j	800018e8 <copyinstr+0x38>
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
    800018da:	87a6                	mv	a5,s1
    800018dc:	a085                	j	8000193c <copyinstr+0x8c>
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    800018de:	84b2                	mv	s1,a2
    }

    srcva = va0 + PGSIZE;
    800018e0:	01390c33          	add	s8,s2,s3
  while(got_null == 0 && max > 0){
    800018e4:	080b8063          	beqz	s7,80001964 <copyinstr+0xb4>
    va0 = PGROUNDDOWN(srcva);
    800018e8:	014c7933          	and	s2,s8,s4
    pa0 = walkaddr(pagetable, va0);
    800018ec:	85ca                	mv	a1,s2
    800018ee:	8556                	mv	a0,s5
    800018f0:	00000097          	auipc	ra,0x0
    800018f4:	86e080e7          	jalr	-1938(ra) # 8000115e <walkaddr>
    if(pa0 == 0)
    800018f8:	c925                	beqz	a0,80001968 <copyinstr+0xb8>
    n = PGSIZE - (srcva - va0);
    800018fa:	41890633          	sub	a2,s2,s8
    800018fe:	964e                	add	a2,a2,s3
    if(n > max)
    80001900:	00cbf363          	bleu	a2,s7,80001906 <copyinstr+0x56>
    80001904:	865e                	mv	a2,s7
    char *p = (char *) (pa0 + (srcva - va0));
    80001906:	9562                	add	a0,a0,s8
    80001908:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000190c:	da71                	beqz	a2,800018e0 <copyinstr+0x30>
      if(*p == '\0'){
    8000190e:	00054703          	lbu	a4,0(a0)
    80001912:	d761                	beqz	a4,800018da <copyinstr+0x2a>
    80001914:	9626                	add	a2,a2,s1
    80001916:	87a6                	mv	a5,s1
    80001918:	1bfd                	addi	s7,s7,-1
    8000191a:	009b86b3          	add	a3,s7,s1
    8000191e:	409b04b3          	sub	s1,s6,s1
    80001922:	94aa                	add	s1,s1,a0
        *dst = *p;
    80001924:	00e78023          	sb	a4,0(a5) # 1000 <_entry-0x7ffff000>
      --max;
    80001928:	40f68bb3          	sub	s7,a3,a5
      p++;
    8000192c:	00f48733          	add	a4,s1,a5
      dst++;
    80001930:	0785                	addi	a5,a5,1
    while(n > 0){
    80001932:	faf606e3          	beq	a2,a5,800018de <copyinstr+0x2e>
      if(*p == '\0'){
    80001936:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    8000193a:	f76d                	bnez	a4,80001924 <copyinstr+0x74>
        *dst = '\0';
    8000193c:	00078023          	sb	zero,0(a5)
    80001940:	4785                	li	a5,1
  }
  if(got_null){
    80001942:	0017b513          	seqz	a0,a5
    80001946:	40a0053b          	negw	a0,a0
    8000194a:	2501                	sext.w	a0,a0
    return 0;
  } else {
    return -1;
  }
}
    8000194c:	60a6                	ld	ra,72(sp)
    8000194e:	6406                	ld	s0,64(sp)
    80001950:	74e2                	ld	s1,56(sp)
    80001952:	7942                	ld	s2,48(sp)
    80001954:	79a2                	ld	s3,40(sp)
    80001956:	7a02                	ld	s4,32(sp)
    80001958:	6ae2                	ld	s5,24(sp)
    8000195a:	6b42                	ld	s6,16(sp)
    8000195c:	6ba2                	ld	s7,8(sp)
    8000195e:	6c02                	ld	s8,0(sp)
    80001960:	6161                	addi	sp,sp,80
    80001962:	8082                	ret
    80001964:	4781                	li	a5,0
    80001966:	bff1                	j	80001942 <copyinstr+0x92>
      return -1;
    80001968:	557d                	li	a0,-1
    8000196a:	b7cd                	j	8000194c <copyinstr+0x9c>
  int got_null = 0;
    8000196c:	4781                	li	a5,0
  if(got_null){
    8000196e:	0017b513          	seqz	a0,a5
    80001972:	40a0053b          	negw	a0,a0
    80001976:	2501                	sext.w	a0,a0
}
    80001978:	8082                	ret

000000008000197a <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    8000197a:	1101                	addi	sp,sp,-32
    8000197c:	ec06                	sd	ra,24(sp)
    8000197e:	e822                	sd	s0,16(sp)
    80001980:	e426                	sd	s1,8(sp)
    80001982:	1000                	addi	s0,sp,32
    80001984:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001986:	fffff097          	auipc	ra,0xfffff
    8000198a:	2ac080e7          	jalr	684(ra) # 80000c32 <holding>
    8000198e:	c909                	beqz	a0,800019a0 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001990:	749c                	ld	a5,40(s1)
    80001992:	00978f63          	beq	a5,s1,800019b0 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001996:	60e2                	ld	ra,24(sp)
    80001998:	6442                	ld	s0,16(sp)
    8000199a:	64a2                	ld	s1,8(sp)
    8000199c:	6105                	addi	sp,sp,32
    8000199e:	8082                	ret
    panic("wakeup1");
    800019a0:	00007517          	auipc	a0,0x7
    800019a4:	85050513          	addi	a0,a0,-1968 # 800081f0 <states.1727+0x28>
    800019a8:	fffff097          	auipc	ra,0xfffff
    800019ac:	bcc080e7          	jalr	-1076(ra) # 80000574 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    800019b0:	4c98                	lw	a4,24(s1)
    800019b2:	4785                	li	a5,1
    800019b4:	fef711e3          	bne	a4,a5,80001996 <wakeup1+0x1c>
    p->state = RUNNABLE;
    800019b8:	4789                	li	a5,2
    800019ba:	cc9c                	sw	a5,24(s1)
}
    800019bc:	bfe9                	j	80001996 <wakeup1+0x1c>

00000000800019be <procinit>:
{
    800019be:	715d                	addi	sp,sp,-80
    800019c0:	e486                	sd	ra,72(sp)
    800019c2:	e0a2                	sd	s0,64(sp)
    800019c4:	fc26                	sd	s1,56(sp)
    800019c6:	f84a                	sd	s2,48(sp)
    800019c8:	f44e                	sd	s3,40(sp)
    800019ca:	f052                	sd	s4,32(sp)
    800019cc:	ec56                	sd	s5,24(sp)
    800019ce:	e85a                	sd	s6,16(sp)
    800019d0:	e45e                	sd	s7,8(sp)
    800019d2:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    800019d4:	00007597          	auipc	a1,0x7
    800019d8:	82458593          	addi	a1,a1,-2012 # 800081f8 <states.1727+0x30>
    800019dc:	00010517          	auipc	a0,0x10
    800019e0:	f7450513          	addi	a0,a0,-140 # 80011950 <pid_lock>
    800019e4:	fffff097          	auipc	ra,0xfffff
    800019e8:	238080e7          	jalr	568(ra) # 80000c1c <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019ec:	00010917          	auipc	s2,0x10
    800019f0:	37c90913          	addi	s2,s2,892 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    800019f4:	00007b97          	auipc	s7,0x7
    800019f8:	80cb8b93          	addi	s7,s7,-2036 # 80008200 <states.1727+0x38>
      uint64 va = KSTACK((int) (p - proc));
    800019fc:	8b4a                	mv	s6,s2
    800019fe:	00006a97          	auipc	s5,0x6
    80001a02:	602a8a93          	addi	s5,s5,1538 # 80008000 <etext>
    80001a06:	040009b7          	lui	s3,0x4000
    80001a0a:	19fd                	addi	s3,s3,-1
    80001a0c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a0e:	00016a17          	auipc	s4,0x16
    80001a12:	f5aa0a13          	addi	s4,s4,-166 # 80017968 <tickslock>
      initlock(&p->lock, "proc");
    80001a16:	85de                	mv	a1,s7
    80001a18:	854a                	mv	a0,s2
    80001a1a:	fffff097          	auipc	ra,0xfffff
    80001a1e:	202080e7          	jalr	514(ra) # 80000c1c <initlock>
      char *pa = kalloc();
    80001a22:	fffff097          	auipc	ra,0xfffff
    80001a26:	150080e7          	jalr	336(ra) # 80000b72 <kalloc>
    80001a2a:	85aa                	mv	a1,a0
      if(pa == 0)
    80001a2c:	c929                	beqz	a0,80001a7e <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001a2e:	416904b3          	sub	s1,s2,s6
    80001a32:	8491                	srai	s1,s1,0x4
    80001a34:	000ab783          	ld	a5,0(s5)
    80001a38:	02f484b3          	mul	s1,s1,a5
    80001a3c:	2485                	addiw	s1,s1,1
    80001a3e:	00d4949b          	slliw	s1,s1,0xd
    80001a42:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a46:	4699                	li	a3,6
    80001a48:	6605                	lui	a2,0x1
    80001a4a:	8526                	mv	a0,s1
    80001a4c:	00000097          	auipc	ra,0x0
    80001a50:	842080e7          	jalr	-1982(ra) # 8000128e <kvmmap>
      p->kstack = va;
    80001a54:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a58:	17090913          	addi	s2,s2,368
    80001a5c:	fb491de3          	bne	s2,s4,80001a16 <procinit+0x58>
  kvminithart();
    80001a60:	fffff097          	auipc	ra,0xfffff
    80001a64:	632080e7          	jalr	1586(ra) # 80001092 <kvminithart>
}
    80001a68:	60a6                	ld	ra,72(sp)
    80001a6a:	6406                	ld	s0,64(sp)
    80001a6c:	74e2                	ld	s1,56(sp)
    80001a6e:	7942                	ld	s2,48(sp)
    80001a70:	79a2                	ld	s3,40(sp)
    80001a72:	7a02                	ld	s4,32(sp)
    80001a74:	6ae2                	ld	s5,24(sp)
    80001a76:	6b42                	ld	s6,16(sp)
    80001a78:	6ba2                	ld	s7,8(sp)
    80001a7a:	6161                	addi	sp,sp,80
    80001a7c:	8082                	ret
        panic("kalloc");
    80001a7e:	00006517          	auipc	a0,0x6
    80001a82:	78a50513          	addi	a0,a0,1930 # 80008208 <states.1727+0x40>
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	aee080e7          	jalr	-1298(ra) # 80000574 <panic>

0000000080001a8e <cpuid>:
{
    80001a8e:	1141                	addi	sp,sp,-16
    80001a90:	e422                	sd	s0,8(sp)
    80001a92:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a94:	8512                	mv	a0,tp
}
    80001a96:	2501                	sext.w	a0,a0
    80001a98:	6422                	ld	s0,8(sp)
    80001a9a:	0141                	addi	sp,sp,16
    80001a9c:	8082                	ret

0000000080001a9e <mycpu>:
mycpu(void) {
    80001a9e:	1141                	addi	sp,sp,-16
    80001aa0:	e422                	sd	s0,8(sp)
    80001aa2:	0800                	addi	s0,sp,16
    80001aa4:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001aa6:	2781                	sext.w	a5,a5
    80001aa8:	079e                	slli	a5,a5,0x7
}
    80001aaa:	00010517          	auipc	a0,0x10
    80001aae:	ebe50513          	addi	a0,a0,-322 # 80011968 <cpus>
    80001ab2:	953e                	add	a0,a0,a5
    80001ab4:	6422                	ld	s0,8(sp)
    80001ab6:	0141                	addi	sp,sp,16
    80001ab8:	8082                	ret

0000000080001aba <myproc>:
myproc(void) {
    80001aba:	1101                	addi	sp,sp,-32
    80001abc:	ec06                	sd	ra,24(sp)
    80001abe:	e822                	sd	s0,16(sp)
    80001ac0:	e426                	sd	s1,8(sp)
    80001ac2:	1000                	addi	s0,sp,32
  push_off();
    80001ac4:	fffff097          	auipc	ra,0xfffff
    80001ac8:	19c080e7          	jalr	412(ra) # 80000c60 <push_off>
    80001acc:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001ace:	2781                	sext.w	a5,a5
    80001ad0:	079e                	slli	a5,a5,0x7
    80001ad2:	00010717          	auipc	a4,0x10
    80001ad6:	e7e70713          	addi	a4,a4,-386 # 80011950 <pid_lock>
    80001ada:	97ba                	add	a5,a5,a4
    80001adc:	6f84                	ld	s1,24(a5)
  pop_off();
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	222080e7          	jalr	546(ra) # 80000d00 <pop_off>
}
    80001ae6:	8526                	mv	a0,s1
    80001ae8:	60e2                	ld	ra,24(sp)
    80001aea:	6442                	ld	s0,16(sp)
    80001aec:	64a2                	ld	s1,8(sp)
    80001aee:	6105                	addi	sp,sp,32
    80001af0:	8082                	ret

0000000080001af2 <forkret>:
{
    80001af2:	1141                	addi	sp,sp,-16
    80001af4:	e406                	sd	ra,8(sp)
    80001af6:	e022                	sd	s0,0(sp)
    80001af8:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001afa:	00000097          	auipc	ra,0x0
    80001afe:	fc0080e7          	jalr	-64(ra) # 80001aba <myproc>
    80001b02:	fffff097          	auipc	ra,0xfffff
    80001b06:	25e080e7          	jalr	606(ra) # 80000d60 <release>
  if (first) {
    80001b0a:	00007797          	auipc	a5,0x7
    80001b0e:	e9678793          	addi	a5,a5,-362 # 800089a0 <first.1687>
    80001b12:	439c                	lw	a5,0(a5)
    80001b14:	eb89                	bnez	a5,80001b26 <forkret+0x34>
  usertrapret();
    80001b16:	00001097          	auipc	ra,0x1
    80001b1a:	c82080e7          	jalr	-894(ra) # 80002798 <usertrapret>
}
    80001b1e:	60a2                	ld	ra,8(sp)
    80001b20:	6402                	ld	s0,0(sp)
    80001b22:	0141                	addi	sp,sp,16
    80001b24:	8082                	ret
    first = 0;
    80001b26:	00007797          	auipc	a5,0x7
    80001b2a:	e607ad23          	sw	zero,-390(a5) # 800089a0 <first.1687>
    fsinit(ROOTDEV);
    80001b2e:	4505                	li	a0,1
    80001b30:	00002097          	auipc	ra,0x2
    80001b34:	ad8080e7          	jalr	-1320(ra) # 80003608 <fsinit>
    80001b38:	bff9                	j	80001b16 <forkret+0x24>

0000000080001b3a <allocpid>:
allocpid() {
    80001b3a:	1101                	addi	sp,sp,-32
    80001b3c:	ec06                	sd	ra,24(sp)
    80001b3e:	e822                	sd	s0,16(sp)
    80001b40:	e426                	sd	s1,8(sp)
    80001b42:	e04a                	sd	s2,0(sp)
    80001b44:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b46:	00010917          	auipc	s2,0x10
    80001b4a:	e0a90913          	addi	s2,s2,-502 # 80011950 <pid_lock>
    80001b4e:	854a                	mv	a0,s2
    80001b50:	fffff097          	auipc	ra,0xfffff
    80001b54:	15c080e7          	jalr	348(ra) # 80000cac <acquire>
  pid = nextpid;
    80001b58:	00007797          	auipc	a5,0x7
    80001b5c:	e4c78793          	addi	a5,a5,-436 # 800089a4 <nextpid>
    80001b60:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b62:	0014871b          	addiw	a4,s1,1
    80001b66:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b68:	854a                	mv	a0,s2
    80001b6a:	fffff097          	auipc	ra,0xfffff
    80001b6e:	1f6080e7          	jalr	502(ra) # 80000d60 <release>
}
    80001b72:	8526                	mv	a0,s1
    80001b74:	60e2                	ld	ra,24(sp)
    80001b76:	6442                	ld	s0,16(sp)
    80001b78:	64a2                	ld	s1,8(sp)
    80001b7a:	6902                	ld	s2,0(sp)
    80001b7c:	6105                	addi	sp,sp,32
    80001b7e:	8082                	ret

0000000080001b80 <proc_pagetable>:
{
    80001b80:	1101                	addi	sp,sp,-32
    80001b82:	ec06                	sd	ra,24(sp)
    80001b84:	e822                	sd	s0,16(sp)
    80001b86:	e426                	sd	s1,8(sp)
    80001b88:	e04a                	sd	s2,0(sp)
    80001b8a:	1000                	addi	s0,sp,32
    80001b8c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b8e:	00000097          	auipc	ra,0x0
    80001b92:	8d2080e7          	jalr	-1838(ra) # 80001460 <uvmcreate>
    80001b96:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b98:	c121                	beqz	a0,80001bd8 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b9a:	4729                	li	a4,10
    80001b9c:	00005697          	auipc	a3,0x5
    80001ba0:	46468693          	addi	a3,a3,1124 # 80007000 <_trampoline>
    80001ba4:	6605                	lui	a2,0x1
    80001ba6:	040005b7          	lui	a1,0x4000
    80001baa:	15fd                	addi	a1,a1,-1
    80001bac:	05b2                	slli	a1,a1,0xc
    80001bae:	fffff097          	auipc	ra,0xfffff
    80001bb2:	654080e7          	jalr	1620(ra) # 80001202 <mappages>
    80001bb6:	02054863          	bltz	a0,80001be6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001bba:	4719                	li	a4,6
    80001bbc:	05893683          	ld	a3,88(s2)
    80001bc0:	6605                	lui	a2,0x1
    80001bc2:	020005b7          	lui	a1,0x2000
    80001bc6:	15fd                	addi	a1,a1,-1
    80001bc8:	05b6                	slli	a1,a1,0xd
    80001bca:	8526                	mv	a0,s1
    80001bcc:	fffff097          	auipc	ra,0xfffff
    80001bd0:	636080e7          	jalr	1590(ra) # 80001202 <mappages>
    80001bd4:	02054163          	bltz	a0,80001bf6 <proc_pagetable+0x76>
}
    80001bd8:	8526                	mv	a0,s1
    80001bda:	60e2                	ld	ra,24(sp)
    80001bdc:	6442                	ld	s0,16(sp)
    80001bde:	64a2                	ld	s1,8(sp)
    80001be0:	6902                	ld	s2,0(sp)
    80001be2:	6105                	addi	sp,sp,32
    80001be4:	8082                	ret
    uvmfree(pagetable, 0);
    80001be6:	4581                	li	a1,0
    80001be8:	8526                	mv	a0,s1
    80001bea:	00000097          	auipc	ra,0x0
    80001bee:	a70080e7          	jalr	-1424(ra) # 8000165a <uvmfree>
    return 0;
    80001bf2:	4481                	li	s1,0
    80001bf4:	b7d5                	j	80001bd8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bf6:	4681                	li	a3,0
    80001bf8:	4605                	li	a2,1
    80001bfa:	040005b7          	lui	a1,0x4000
    80001bfe:	15fd                	addi	a1,a1,-1
    80001c00:	05b2                	slli	a1,a1,0xc
    80001c02:	8526                	mv	a0,s1
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	796080e7          	jalr	1942(ra) # 8000139a <uvmunmap>
    uvmfree(pagetable, 0);
    80001c0c:	4581                	li	a1,0
    80001c0e:	8526                	mv	a0,s1
    80001c10:	00000097          	auipc	ra,0x0
    80001c14:	a4a080e7          	jalr	-1462(ra) # 8000165a <uvmfree>
    return 0;
    80001c18:	4481                	li	s1,0
    80001c1a:	bf7d                	j	80001bd8 <proc_pagetable+0x58>

0000000080001c1c <proc_freepagetable>:
{
    80001c1c:	1101                	addi	sp,sp,-32
    80001c1e:	ec06                	sd	ra,24(sp)
    80001c20:	e822                	sd	s0,16(sp)
    80001c22:	e426                	sd	s1,8(sp)
    80001c24:	e04a                	sd	s2,0(sp)
    80001c26:	1000                	addi	s0,sp,32
    80001c28:	84aa                	mv	s1,a0
    80001c2a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c2c:	4681                	li	a3,0
    80001c2e:	4605                	li	a2,1
    80001c30:	040005b7          	lui	a1,0x4000
    80001c34:	15fd                	addi	a1,a1,-1
    80001c36:	05b2                	slli	a1,a1,0xc
    80001c38:	fffff097          	auipc	ra,0xfffff
    80001c3c:	762080e7          	jalr	1890(ra) # 8000139a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c40:	4681                	li	a3,0
    80001c42:	4605                	li	a2,1
    80001c44:	020005b7          	lui	a1,0x2000
    80001c48:	15fd                	addi	a1,a1,-1
    80001c4a:	05b6                	slli	a1,a1,0xd
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	fffff097          	auipc	ra,0xfffff
    80001c52:	74c080e7          	jalr	1868(ra) # 8000139a <uvmunmap>
  uvmfree(pagetable, sz);
    80001c56:	85ca                	mv	a1,s2
    80001c58:	8526                	mv	a0,s1
    80001c5a:	00000097          	auipc	ra,0x0
    80001c5e:	a00080e7          	jalr	-1536(ra) # 8000165a <uvmfree>
}
    80001c62:	60e2                	ld	ra,24(sp)
    80001c64:	6442                	ld	s0,16(sp)
    80001c66:	64a2                	ld	s1,8(sp)
    80001c68:	6902                	ld	s2,0(sp)
    80001c6a:	6105                	addi	sp,sp,32
    80001c6c:	8082                	ret

0000000080001c6e <freeproc>:
{
    80001c6e:	1101                	addi	sp,sp,-32
    80001c70:	ec06                	sd	ra,24(sp)
    80001c72:	e822                	sd	s0,16(sp)
    80001c74:	e426                	sd	s1,8(sp)
    80001c76:	1000                	addi	s0,sp,32
    80001c78:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c7a:	6d28                	ld	a0,88(a0)
    80001c7c:	c509                	beqz	a0,80001c86 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	df4080e7          	jalr	-524(ra) # 80000a72 <kfree>
  p->trapframe = 0;
    80001c86:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c8a:	68a8                	ld	a0,80(s1)
    80001c8c:	c511                	beqz	a0,80001c98 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c8e:	64ac                	ld	a1,72(s1)
    80001c90:	00000097          	auipc	ra,0x0
    80001c94:	f8c080e7          	jalr	-116(ra) # 80001c1c <proc_freepagetable>
  p->pagetable = 0;
    80001c98:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c9c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ca0:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001ca4:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001ca8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001cac:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001cb0:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001cb4:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001cb8:	0004ac23          	sw	zero,24(s1)
}
    80001cbc:	60e2                	ld	ra,24(sp)
    80001cbe:	6442                	ld	s0,16(sp)
    80001cc0:	64a2                	ld	s1,8(sp)
    80001cc2:	6105                	addi	sp,sp,32
    80001cc4:	8082                	ret

0000000080001cc6 <allocproc>:
{
    80001cc6:	1101                	addi	sp,sp,-32
    80001cc8:	ec06                	sd	ra,24(sp)
    80001cca:	e822                	sd	s0,16(sp)
    80001ccc:	e426                	sd	s1,8(sp)
    80001cce:	e04a                	sd	s2,0(sp)
    80001cd0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cd2:	00010497          	auipc	s1,0x10
    80001cd6:	09648493          	addi	s1,s1,150 # 80011d68 <proc>
    80001cda:	00016917          	auipc	s2,0x16
    80001cde:	c8e90913          	addi	s2,s2,-882 # 80017968 <tickslock>
    acquire(&p->lock);
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	fffff097          	auipc	ra,0xfffff
    80001ce8:	fc8080e7          	jalr	-56(ra) # 80000cac <acquire>
    if(p->state == UNUSED) {
    80001cec:	4c9c                	lw	a5,24(s1)
    80001cee:	cf81                	beqz	a5,80001d06 <allocproc+0x40>
      release(&p->lock);
    80001cf0:	8526                	mv	a0,s1
    80001cf2:	fffff097          	auipc	ra,0xfffff
    80001cf6:	06e080e7          	jalr	110(ra) # 80000d60 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cfa:	17048493          	addi	s1,s1,368
    80001cfe:	ff2492e3          	bne	s1,s2,80001ce2 <allocproc+0x1c>
  return 0;
    80001d02:	4481                	li	s1,0
    80001d04:	a889                	j	80001d56 <allocproc+0x90>
  p->pid = allocpid();
    80001d06:	00000097          	auipc	ra,0x0
    80001d0a:	e34080e7          	jalr	-460(ra) # 80001b3a <allocpid>
    80001d0e:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d10:	fffff097          	auipc	ra,0xfffff
    80001d14:	e62080e7          	jalr	-414(ra) # 80000b72 <kalloc>
    80001d18:	892a                	mv	s2,a0
    80001d1a:	eca8                	sd	a0,88(s1)
    80001d1c:	c521                	beqz	a0,80001d64 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001d1e:	8526                	mv	a0,s1
    80001d20:	00000097          	auipc	ra,0x0
    80001d24:	e60080e7          	jalr	-416(ra) # 80001b80 <proc_pagetable>
    80001d28:	892a                	mv	s2,a0
    80001d2a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d2c:	c139                	beqz	a0,80001d72 <allocproc+0xac>
  memset(&p->context, 0, sizeof(p->context));
    80001d2e:	07000613          	li	a2,112
    80001d32:	4581                	li	a1,0
    80001d34:	06048513          	addi	a0,s1,96
    80001d38:	fffff097          	auipc	ra,0xfffff
    80001d3c:	070080e7          	jalr	112(ra) # 80000da8 <memset>
  p->context.ra = (uint64)forkret;
    80001d40:	00000797          	auipc	a5,0x0
    80001d44:	db278793          	addi	a5,a5,-590 # 80001af2 <forkret>
    80001d48:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d4a:	60bc                	ld	a5,64(s1)
    80001d4c:	6705                	lui	a4,0x1
    80001d4e:	97ba                	add	a5,a5,a4
    80001d50:	f4bc                	sd	a5,104(s1)
  p->tracemask = 0;
    80001d52:	1604b423          	sd	zero,360(s1)
}
    80001d56:	8526                	mv	a0,s1
    80001d58:	60e2                	ld	ra,24(sp)
    80001d5a:	6442                	ld	s0,16(sp)
    80001d5c:	64a2                	ld	s1,8(sp)
    80001d5e:	6902                	ld	s2,0(sp)
    80001d60:	6105                	addi	sp,sp,32
    80001d62:	8082                	ret
    release(&p->lock);
    80001d64:	8526                	mv	a0,s1
    80001d66:	fffff097          	auipc	ra,0xfffff
    80001d6a:	ffa080e7          	jalr	-6(ra) # 80000d60 <release>
    return 0;
    80001d6e:	84ca                	mv	s1,s2
    80001d70:	b7dd                	j	80001d56 <allocproc+0x90>
    freeproc(p);
    80001d72:	8526                	mv	a0,s1
    80001d74:	00000097          	auipc	ra,0x0
    80001d78:	efa080e7          	jalr	-262(ra) # 80001c6e <freeproc>
    release(&p->lock);
    80001d7c:	8526                	mv	a0,s1
    80001d7e:	fffff097          	auipc	ra,0xfffff
    80001d82:	fe2080e7          	jalr	-30(ra) # 80000d60 <release>
    return 0;
    80001d86:	84ca                	mv	s1,s2
    80001d88:	b7f9                	j	80001d56 <allocproc+0x90>

0000000080001d8a <userinit>:
{
    80001d8a:	1101                	addi	sp,sp,-32
    80001d8c:	ec06                	sd	ra,24(sp)
    80001d8e:	e822                	sd	s0,16(sp)
    80001d90:	e426                	sd	s1,8(sp)
    80001d92:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d94:	00000097          	auipc	ra,0x0
    80001d98:	f32080e7          	jalr	-206(ra) # 80001cc6 <allocproc>
    80001d9c:	84aa                	mv	s1,a0
  initproc = p;
    80001d9e:	00007797          	auipc	a5,0x7
    80001da2:	26a7bd23          	sd	a0,634(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001da6:	03400613          	li	a2,52
    80001daa:	00007597          	auipc	a1,0x7
    80001dae:	c0658593          	addi	a1,a1,-1018 # 800089b0 <initcode>
    80001db2:	6928                	ld	a0,80(a0)
    80001db4:	fffff097          	auipc	ra,0xfffff
    80001db8:	6da080e7          	jalr	1754(ra) # 8000148e <uvminit>
  p->sz = PGSIZE;
    80001dbc:	6785                	lui	a5,0x1
    80001dbe:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001dc0:	6cb8                	ld	a4,88(s1)
    80001dc2:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001dc6:	6cb8                	ld	a4,88(s1)
    80001dc8:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001dca:	4641                	li	a2,16
    80001dcc:	00006597          	auipc	a1,0x6
    80001dd0:	44458593          	addi	a1,a1,1092 # 80008210 <states.1727+0x48>
    80001dd4:	15848513          	addi	a0,s1,344
    80001dd8:	fffff097          	auipc	ra,0xfffff
    80001ddc:	148080e7          	jalr	328(ra) # 80000f20 <safestrcpy>
  p->cwd = namei("/");
    80001de0:	00006517          	auipc	a0,0x6
    80001de4:	44050513          	addi	a0,a0,1088 # 80008220 <states.1727+0x58>
    80001de8:	00002097          	auipc	ra,0x2
    80001dec:	254080e7          	jalr	596(ra) # 8000403c <namei>
    80001df0:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001df4:	4789                	li	a5,2
    80001df6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001df8:	8526                	mv	a0,s1
    80001dfa:	fffff097          	auipc	ra,0xfffff
    80001dfe:	f66080e7          	jalr	-154(ra) # 80000d60 <release>
}
    80001e02:	60e2                	ld	ra,24(sp)
    80001e04:	6442                	ld	s0,16(sp)
    80001e06:	64a2                	ld	s1,8(sp)
    80001e08:	6105                	addi	sp,sp,32
    80001e0a:	8082                	ret

0000000080001e0c <growproc>:
{
    80001e0c:	1101                	addi	sp,sp,-32
    80001e0e:	ec06                	sd	ra,24(sp)
    80001e10:	e822                	sd	s0,16(sp)
    80001e12:	e426                	sd	s1,8(sp)
    80001e14:	e04a                	sd	s2,0(sp)
    80001e16:	1000                	addi	s0,sp,32
    80001e18:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e1a:	00000097          	auipc	ra,0x0
    80001e1e:	ca0080e7          	jalr	-864(ra) # 80001aba <myproc>
    80001e22:	892a                	mv	s2,a0
  sz = p->sz;
    80001e24:	652c                	ld	a1,72(a0)
    80001e26:	0005851b          	sext.w	a0,a1
  if(n > 0){
    80001e2a:	00904f63          	bgtz	s1,80001e48 <growproc+0x3c>
  } else if(n < 0){
    80001e2e:	0204cd63          	bltz	s1,80001e68 <growproc+0x5c>
  p->sz = sz;
    80001e32:	1502                	slli	a0,a0,0x20
    80001e34:	9101                	srli	a0,a0,0x20
    80001e36:	04a93423          	sd	a0,72(s2)
  return 0;
    80001e3a:	4501                	li	a0,0
}
    80001e3c:	60e2                	ld	ra,24(sp)
    80001e3e:	6442                	ld	s0,16(sp)
    80001e40:	64a2                	ld	s1,8(sp)
    80001e42:	6902                	ld	s2,0(sp)
    80001e44:	6105                	addi	sp,sp,32
    80001e46:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001e48:	00a4863b          	addw	a2,s1,a0
    80001e4c:	1602                	slli	a2,a2,0x20
    80001e4e:	9201                	srli	a2,a2,0x20
    80001e50:	1582                	slli	a1,a1,0x20
    80001e52:	9181                	srli	a1,a1,0x20
    80001e54:	05093503          	ld	a0,80(s2)
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	6ee080e7          	jalr	1774(ra) # 80001546 <uvmalloc>
    80001e60:	2501                	sext.w	a0,a0
    80001e62:	f961                	bnez	a0,80001e32 <growproc+0x26>
      return -1;
    80001e64:	557d                	li	a0,-1
    80001e66:	bfd9                	j	80001e3c <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e68:	00a4863b          	addw	a2,s1,a0
    80001e6c:	1602                	slli	a2,a2,0x20
    80001e6e:	9201                	srli	a2,a2,0x20
    80001e70:	1582                	slli	a1,a1,0x20
    80001e72:	9181                	srli	a1,a1,0x20
    80001e74:	05093503          	ld	a0,80(s2)
    80001e78:	fffff097          	auipc	ra,0xfffff
    80001e7c:	688080e7          	jalr	1672(ra) # 80001500 <uvmdealloc>
    80001e80:	2501                	sext.w	a0,a0
    80001e82:	bf45                	j	80001e32 <growproc+0x26>

0000000080001e84 <fork>:
{
    80001e84:	7179                	addi	sp,sp,-48
    80001e86:	f406                	sd	ra,40(sp)
    80001e88:	f022                	sd	s0,32(sp)
    80001e8a:	ec26                	sd	s1,24(sp)
    80001e8c:	e84a                	sd	s2,16(sp)
    80001e8e:	e44e                	sd	s3,8(sp)
    80001e90:	e052                	sd	s4,0(sp)
    80001e92:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e94:	00000097          	auipc	ra,0x0
    80001e98:	c26080e7          	jalr	-986(ra) # 80001aba <myproc>
    80001e9c:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001e9e:	00000097          	auipc	ra,0x0
    80001ea2:	e28080e7          	jalr	-472(ra) # 80001cc6 <allocproc>
    80001ea6:	c575                	beqz	a0,80001f92 <fork+0x10e>
    80001ea8:	89aa                	mv	s3,a0
  np->tracemask = p->tracemask;  //2.1
    80001eaa:	16893783          	ld	a5,360(s2)
    80001eae:	16f53423          	sd	a5,360(a0)
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001eb2:	04893603          	ld	a2,72(s2)
    80001eb6:	692c                	ld	a1,80(a0)
    80001eb8:	05093503          	ld	a0,80(s2)
    80001ebc:	fffff097          	auipc	ra,0xfffff
    80001ec0:	7d6080e7          	jalr	2006(ra) # 80001692 <uvmcopy>
    80001ec4:	04054863          	bltz	a0,80001f14 <fork+0x90>
  np->sz = p->sz;
    80001ec8:	04893783          	ld	a5,72(s2)
    80001ecc:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80001ed0:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80001ed4:	05893683          	ld	a3,88(s2)
    80001ed8:	87b6                	mv	a5,a3
    80001eda:	0589b703          	ld	a4,88(s3)
    80001ede:	12068693          	addi	a3,a3,288
    80001ee2:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001ee6:	6788                	ld	a0,8(a5)
    80001ee8:	6b8c                	ld	a1,16(a5)
    80001eea:	6f90                	ld	a2,24(a5)
    80001eec:	01073023          	sd	a6,0(a4)
    80001ef0:	e708                	sd	a0,8(a4)
    80001ef2:	eb0c                	sd	a1,16(a4)
    80001ef4:	ef10                	sd	a2,24(a4)
    80001ef6:	02078793          	addi	a5,a5,32
    80001efa:	02070713          	addi	a4,a4,32
    80001efe:	fed792e3          	bne	a5,a3,80001ee2 <fork+0x5e>
  np->trapframe->a0 = 0;
    80001f02:	0589b783          	ld	a5,88(s3)
    80001f06:	0607b823          	sd	zero,112(a5)
    80001f0a:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001f0e:	15000a13          	li	s4,336
    80001f12:	a03d                	j	80001f40 <fork+0xbc>
    freeproc(np);
    80001f14:	854e                	mv	a0,s3
    80001f16:	00000097          	auipc	ra,0x0
    80001f1a:	d58080e7          	jalr	-680(ra) # 80001c6e <freeproc>
    release(&np->lock);
    80001f1e:	854e                	mv	a0,s3
    80001f20:	fffff097          	auipc	ra,0xfffff
    80001f24:	e40080e7          	jalr	-448(ra) # 80000d60 <release>
    return -1;
    80001f28:	54fd                	li	s1,-1
    80001f2a:	a899                	j	80001f80 <fork+0xfc>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f2c:	00002097          	auipc	ra,0x2
    80001f30:	7ce080e7          	jalr	1998(ra) # 800046fa <filedup>
    80001f34:	009987b3          	add	a5,s3,s1
    80001f38:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001f3a:	04a1                	addi	s1,s1,8
    80001f3c:	01448763          	beq	s1,s4,80001f4a <fork+0xc6>
    if(p->ofile[i])
    80001f40:	009907b3          	add	a5,s2,s1
    80001f44:	6388                	ld	a0,0(a5)
    80001f46:	f17d                	bnez	a0,80001f2c <fork+0xa8>
    80001f48:	bfcd                	j	80001f3a <fork+0xb6>
  np->cwd = idup(p->cwd);
    80001f4a:	15093503          	ld	a0,336(s2)
    80001f4e:	00002097          	auipc	ra,0x2
    80001f52:	8f6080e7          	jalr	-1802(ra) # 80003844 <idup>
    80001f56:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f5a:	4641                	li	a2,16
    80001f5c:	15890593          	addi	a1,s2,344
    80001f60:	15898513          	addi	a0,s3,344
    80001f64:	fffff097          	auipc	ra,0xfffff
    80001f68:	fbc080e7          	jalr	-68(ra) # 80000f20 <safestrcpy>
  pid = np->pid;
    80001f6c:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001f70:	4789                	li	a5,2
    80001f72:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f76:	854e                	mv	a0,s3
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	de8080e7          	jalr	-536(ra) # 80000d60 <release>
}
    80001f80:	8526                	mv	a0,s1
    80001f82:	70a2                	ld	ra,40(sp)
    80001f84:	7402                	ld	s0,32(sp)
    80001f86:	64e2                	ld	s1,24(sp)
    80001f88:	6942                	ld	s2,16(sp)
    80001f8a:	69a2                	ld	s3,8(sp)
    80001f8c:	6a02                	ld	s4,0(sp)
    80001f8e:	6145                	addi	sp,sp,48
    80001f90:	8082                	ret
    return -1;
    80001f92:	54fd                	li	s1,-1
    80001f94:	b7f5                	j	80001f80 <fork+0xfc>

0000000080001f96 <reparent>:
{
    80001f96:	7179                	addi	sp,sp,-48
    80001f98:	f406                	sd	ra,40(sp)
    80001f9a:	f022                	sd	s0,32(sp)
    80001f9c:	ec26                	sd	s1,24(sp)
    80001f9e:	e84a                	sd	s2,16(sp)
    80001fa0:	e44e                	sd	s3,8(sp)
    80001fa2:	e052                	sd	s4,0(sp)
    80001fa4:	1800                	addi	s0,sp,48
    80001fa6:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fa8:	00010497          	auipc	s1,0x10
    80001fac:	dc048493          	addi	s1,s1,-576 # 80011d68 <proc>
      pp->parent = initproc;
    80001fb0:	00007a17          	auipc	s4,0x7
    80001fb4:	068a0a13          	addi	s4,s4,104 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fb8:	00016917          	auipc	s2,0x16
    80001fbc:	9b090913          	addi	s2,s2,-1616 # 80017968 <tickslock>
    80001fc0:	a029                	j	80001fca <reparent+0x34>
    80001fc2:	17048493          	addi	s1,s1,368
    80001fc6:	03248363          	beq	s1,s2,80001fec <reparent+0x56>
    if(pp->parent == p){
    80001fca:	709c                	ld	a5,32(s1)
    80001fcc:	ff379be3          	bne	a5,s3,80001fc2 <reparent+0x2c>
      acquire(&pp->lock);
    80001fd0:	8526                	mv	a0,s1
    80001fd2:	fffff097          	auipc	ra,0xfffff
    80001fd6:	cda080e7          	jalr	-806(ra) # 80000cac <acquire>
      pp->parent = initproc;
    80001fda:	000a3783          	ld	a5,0(s4)
    80001fde:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001fe0:	8526                	mv	a0,s1
    80001fe2:	fffff097          	auipc	ra,0xfffff
    80001fe6:	d7e080e7          	jalr	-642(ra) # 80000d60 <release>
    80001fea:	bfe1                	j	80001fc2 <reparent+0x2c>
}
    80001fec:	70a2                	ld	ra,40(sp)
    80001fee:	7402                	ld	s0,32(sp)
    80001ff0:	64e2                	ld	s1,24(sp)
    80001ff2:	6942                	ld	s2,16(sp)
    80001ff4:	69a2                	ld	s3,8(sp)
    80001ff6:	6a02                	ld	s4,0(sp)
    80001ff8:	6145                	addi	sp,sp,48
    80001ffa:	8082                	ret

0000000080001ffc <scheduler>:
{
    80001ffc:	715d                	addi	sp,sp,-80
    80001ffe:	e486                	sd	ra,72(sp)
    80002000:	e0a2                	sd	s0,64(sp)
    80002002:	fc26                	sd	s1,56(sp)
    80002004:	f84a                	sd	s2,48(sp)
    80002006:	f44e                	sd	s3,40(sp)
    80002008:	f052                	sd	s4,32(sp)
    8000200a:	ec56                	sd	s5,24(sp)
    8000200c:	e85a                	sd	s6,16(sp)
    8000200e:	e45e                	sd	s7,8(sp)
    80002010:	e062                	sd	s8,0(sp)
    80002012:	0880                	addi	s0,sp,80
    80002014:	8792                	mv	a5,tp
  int id = r_tp();
    80002016:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002018:	00779b13          	slli	s6,a5,0x7
    8000201c:	00010717          	auipc	a4,0x10
    80002020:	93470713          	addi	a4,a4,-1740 # 80011950 <pid_lock>
    80002024:	975a                	add	a4,a4,s6
    80002026:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    8000202a:	00010717          	auipc	a4,0x10
    8000202e:	94670713          	addi	a4,a4,-1722 # 80011970 <cpus+0x8>
    80002032:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80002034:	4c0d                	li	s8,3
        c->proc = p;
    80002036:	079e                	slli	a5,a5,0x7
    80002038:	00010a17          	auipc	s4,0x10
    8000203c:	918a0a13          	addi	s4,s4,-1768 # 80011950 <pid_lock>
    80002040:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002042:	00016997          	auipc	s3,0x16
    80002046:	92698993          	addi	s3,s3,-1754 # 80017968 <tickslock>
        found = 1;
    8000204a:	4b85                	li	s7,1
    8000204c:	a899                	j	800020a2 <scheduler+0xa6>
        p->state = RUNNING;
    8000204e:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80002052:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    80002056:	06048593          	addi	a1,s1,96
    8000205a:	855a                	mv	a0,s6
    8000205c:	00000097          	auipc	ra,0x0
    80002060:	692080e7          	jalr	1682(ra) # 800026ee <swtch>
        c->proc = 0;
    80002064:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80002068:	8ade                	mv	s5,s7
      release(&p->lock);
    8000206a:	8526                	mv	a0,s1
    8000206c:	fffff097          	auipc	ra,0xfffff
    80002070:	cf4080e7          	jalr	-780(ra) # 80000d60 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002074:	17048493          	addi	s1,s1,368
    80002078:	01348b63          	beq	s1,s3,8000208e <scheduler+0x92>
      acquire(&p->lock);
    8000207c:	8526                	mv	a0,s1
    8000207e:	fffff097          	auipc	ra,0xfffff
    80002082:	c2e080e7          	jalr	-978(ra) # 80000cac <acquire>
      if(p->state == RUNNABLE) {
    80002086:	4c9c                	lw	a5,24(s1)
    80002088:	ff2791e3          	bne	a5,s2,8000206a <scheduler+0x6e>
    8000208c:	b7c9                	j	8000204e <scheduler+0x52>
    if(found == 0) {
    8000208e:	000a9a63          	bnez	s5,800020a2 <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002092:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002096:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000209a:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000209e:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020a2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020a6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020aa:	10079073          	csrw	sstatus,a5
    int found = 0;
    800020ae:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800020b0:	00010497          	auipc	s1,0x10
    800020b4:	cb848493          	addi	s1,s1,-840 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    800020b8:	4909                	li	s2,2
    800020ba:	b7c9                	j	8000207c <scheduler+0x80>

00000000800020bc <sched>:
{
    800020bc:	7179                	addi	sp,sp,-48
    800020be:	f406                	sd	ra,40(sp)
    800020c0:	f022                	sd	s0,32(sp)
    800020c2:	ec26                	sd	s1,24(sp)
    800020c4:	e84a                	sd	s2,16(sp)
    800020c6:	e44e                	sd	s3,8(sp)
    800020c8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020ca:	00000097          	auipc	ra,0x0
    800020ce:	9f0080e7          	jalr	-1552(ra) # 80001aba <myproc>
    800020d2:	892a                	mv	s2,a0
  if(!holding(&p->lock))
    800020d4:	fffff097          	auipc	ra,0xfffff
    800020d8:	b5e080e7          	jalr	-1186(ra) # 80000c32 <holding>
    800020dc:	cd25                	beqz	a0,80002154 <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020de:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020e0:	2781                	sext.w	a5,a5
    800020e2:	079e                	slli	a5,a5,0x7
    800020e4:	00010717          	auipc	a4,0x10
    800020e8:	86c70713          	addi	a4,a4,-1940 # 80011950 <pid_lock>
    800020ec:	97ba                	add	a5,a5,a4
    800020ee:	0907a703          	lw	a4,144(a5)
    800020f2:	4785                	li	a5,1
    800020f4:	06f71863          	bne	a4,a5,80002164 <sched+0xa8>
  if(p->state == RUNNING)
    800020f8:	01892703          	lw	a4,24(s2)
    800020fc:	478d                	li	a5,3
    800020fe:	06f70b63          	beq	a4,a5,80002174 <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002102:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002106:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002108:	efb5                	bnez	a5,80002184 <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000210a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000210c:	00010497          	auipc	s1,0x10
    80002110:	84448493          	addi	s1,s1,-1980 # 80011950 <pid_lock>
    80002114:	2781                	sext.w	a5,a5
    80002116:	079e                	slli	a5,a5,0x7
    80002118:	97a6                	add	a5,a5,s1
    8000211a:	0947a983          	lw	s3,148(a5)
    8000211e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002120:	2781                	sext.w	a5,a5
    80002122:	079e                	slli	a5,a5,0x7
    80002124:	00010597          	auipc	a1,0x10
    80002128:	84c58593          	addi	a1,a1,-1972 # 80011970 <cpus+0x8>
    8000212c:	95be                	add	a1,a1,a5
    8000212e:	06090513          	addi	a0,s2,96
    80002132:	00000097          	auipc	ra,0x0
    80002136:	5bc080e7          	jalr	1468(ra) # 800026ee <swtch>
    8000213a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000213c:	2781                	sext.w	a5,a5
    8000213e:	079e                	slli	a5,a5,0x7
    80002140:	97a6                	add	a5,a5,s1
    80002142:	0937aa23          	sw	s3,148(a5)
}
    80002146:	70a2                	ld	ra,40(sp)
    80002148:	7402                	ld	s0,32(sp)
    8000214a:	64e2                	ld	s1,24(sp)
    8000214c:	6942                	ld	s2,16(sp)
    8000214e:	69a2                	ld	s3,8(sp)
    80002150:	6145                	addi	sp,sp,48
    80002152:	8082                	ret
    panic("sched p->lock");
    80002154:	00006517          	auipc	a0,0x6
    80002158:	0d450513          	addi	a0,a0,212 # 80008228 <states.1727+0x60>
    8000215c:	ffffe097          	auipc	ra,0xffffe
    80002160:	418080e7          	jalr	1048(ra) # 80000574 <panic>
    panic("sched locks");
    80002164:	00006517          	auipc	a0,0x6
    80002168:	0d450513          	addi	a0,a0,212 # 80008238 <states.1727+0x70>
    8000216c:	ffffe097          	auipc	ra,0xffffe
    80002170:	408080e7          	jalr	1032(ra) # 80000574 <panic>
    panic("sched running");
    80002174:	00006517          	auipc	a0,0x6
    80002178:	0d450513          	addi	a0,a0,212 # 80008248 <states.1727+0x80>
    8000217c:	ffffe097          	auipc	ra,0xffffe
    80002180:	3f8080e7          	jalr	1016(ra) # 80000574 <panic>
    panic("sched interruptible");
    80002184:	00006517          	auipc	a0,0x6
    80002188:	0d450513          	addi	a0,a0,212 # 80008258 <states.1727+0x90>
    8000218c:	ffffe097          	auipc	ra,0xffffe
    80002190:	3e8080e7          	jalr	1000(ra) # 80000574 <panic>

0000000080002194 <exit>:
{
    80002194:	7179                	addi	sp,sp,-48
    80002196:	f406                	sd	ra,40(sp)
    80002198:	f022                	sd	s0,32(sp)
    8000219a:	ec26                	sd	s1,24(sp)
    8000219c:	e84a                	sd	s2,16(sp)
    8000219e:	e44e                	sd	s3,8(sp)
    800021a0:	e052                	sd	s4,0(sp)
    800021a2:	1800                	addi	s0,sp,48
    800021a4:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021a6:	00000097          	auipc	ra,0x0
    800021aa:	914080e7          	jalr	-1772(ra) # 80001aba <myproc>
    800021ae:	89aa                	mv	s3,a0
  if(p == initproc)
    800021b0:	00007797          	auipc	a5,0x7
    800021b4:	e6878793          	addi	a5,a5,-408 # 80009018 <initproc>
    800021b8:	639c                	ld	a5,0(a5)
    800021ba:	0d050493          	addi	s1,a0,208
    800021be:	15050913          	addi	s2,a0,336
    800021c2:	02a79363          	bne	a5,a0,800021e8 <exit+0x54>
    panic("init exiting");
    800021c6:	00006517          	auipc	a0,0x6
    800021ca:	0aa50513          	addi	a0,a0,170 # 80008270 <states.1727+0xa8>
    800021ce:	ffffe097          	auipc	ra,0xffffe
    800021d2:	3a6080e7          	jalr	934(ra) # 80000574 <panic>
      fileclose(f);
    800021d6:	00002097          	auipc	ra,0x2
    800021da:	576080e7          	jalr	1398(ra) # 8000474c <fileclose>
      p->ofile[fd] = 0;
    800021de:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021e2:	04a1                	addi	s1,s1,8
    800021e4:	01248563          	beq	s1,s2,800021ee <exit+0x5a>
    if(p->ofile[fd]){
    800021e8:	6088                	ld	a0,0(s1)
    800021ea:	f575                	bnez	a0,800021d6 <exit+0x42>
    800021ec:	bfdd                	j	800021e2 <exit+0x4e>
  begin_op();
    800021ee:	00002097          	auipc	ra,0x2
    800021f2:	05c080e7          	jalr	92(ra) # 8000424a <begin_op>
  iput(p->cwd);
    800021f6:	1509b503          	ld	a0,336(s3)
    800021fa:	00002097          	auipc	ra,0x2
    800021fe:	844080e7          	jalr	-1980(ra) # 80003a3e <iput>
  end_op();
    80002202:	00002097          	auipc	ra,0x2
    80002206:	0c8080e7          	jalr	200(ra) # 800042ca <end_op>
  p->cwd = 0;
    8000220a:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    8000220e:	00007497          	auipc	s1,0x7
    80002212:	e0a48493          	addi	s1,s1,-502 # 80009018 <initproc>
    80002216:	6088                	ld	a0,0(s1)
    80002218:	fffff097          	auipc	ra,0xfffff
    8000221c:	a94080e7          	jalr	-1388(ra) # 80000cac <acquire>
  wakeup1(initproc);
    80002220:	6088                	ld	a0,0(s1)
    80002222:	fffff097          	auipc	ra,0xfffff
    80002226:	758080e7          	jalr	1880(ra) # 8000197a <wakeup1>
  release(&initproc->lock);
    8000222a:	6088                	ld	a0,0(s1)
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	b34080e7          	jalr	-1228(ra) # 80000d60 <release>
  acquire(&p->lock);
    80002234:	854e                	mv	a0,s3
    80002236:	fffff097          	auipc	ra,0xfffff
    8000223a:	a76080e7          	jalr	-1418(ra) # 80000cac <acquire>
  struct proc *original_parent = p->parent;
    8000223e:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002242:	854e                	mv	a0,s3
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	b1c080e7          	jalr	-1252(ra) # 80000d60 <release>
  acquire(&original_parent->lock);
    8000224c:	8526                	mv	a0,s1
    8000224e:	fffff097          	auipc	ra,0xfffff
    80002252:	a5e080e7          	jalr	-1442(ra) # 80000cac <acquire>
  acquire(&p->lock);
    80002256:	854e                	mv	a0,s3
    80002258:	fffff097          	auipc	ra,0xfffff
    8000225c:	a54080e7          	jalr	-1452(ra) # 80000cac <acquire>
  reparent(p);
    80002260:	854e                	mv	a0,s3
    80002262:	00000097          	auipc	ra,0x0
    80002266:	d34080e7          	jalr	-716(ra) # 80001f96 <reparent>
  wakeup1(original_parent);
    8000226a:	8526                	mv	a0,s1
    8000226c:	fffff097          	auipc	ra,0xfffff
    80002270:	70e080e7          	jalr	1806(ra) # 8000197a <wakeup1>
  p->xstate = status;
    80002274:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80002278:	4791                	li	a5,4
    8000227a:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    8000227e:	8526                	mv	a0,s1
    80002280:	fffff097          	auipc	ra,0xfffff
    80002284:	ae0080e7          	jalr	-1312(ra) # 80000d60 <release>
  sched();
    80002288:	00000097          	auipc	ra,0x0
    8000228c:	e34080e7          	jalr	-460(ra) # 800020bc <sched>
  panic("zombie exit");
    80002290:	00006517          	auipc	a0,0x6
    80002294:	ff050513          	addi	a0,a0,-16 # 80008280 <states.1727+0xb8>
    80002298:	ffffe097          	auipc	ra,0xffffe
    8000229c:	2dc080e7          	jalr	732(ra) # 80000574 <panic>

00000000800022a0 <yield>:
{
    800022a0:	1101                	addi	sp,sp,-32
    800022a2:	ec06                	sd	ra,24(sp)
    800022a4:	e822                	sd	s0,16(sp)
    800022a6:	e426                	sd	s1,8(sp)
    800022a8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800022aa:	00000097          	auipc	ra,0x0
    800022ae:	810080e7          	jalr	-2032(ra) # 80001aba <myproc>
    800022b2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022b4:	fffff097          	auipc	ra,0xfffff
    800022b8:	9f8080e7          	jalr	-1544(ra) # 80000cac <acquire>
  p->state = RUNNABLE;
    800022bc:	4789                	li	a5,2
    800022be:	cc9c                	sw	a5,24(s1)
  sched();
    800022c0:	00000097          	auipc	ra,0x0
    800022c4:	dfc080e7          	jalr	-516(ra) # 800020bc <sched>
  release(&p->lock);
    800022c8:	8526                	mv	a0,s1
    800022ca:	fffff097          	auipc	ra,0xfffff
    800022ce:	a96080e7          	jalr	-1386(ra) # 80000d60 <release>
}
    800022d2:	60e2                	ld	ra,24(sp)
    800022d4:	6442                	ld	s0,16(sp)
    800022d6:	64a2                	ld	s1,8(sp)
    800022d8:	6105                	addi	sp,sp,32
    800022da:	8082                	ret

00000000800022dc <sleep>:
{
    800022dc:	7179                	addi	sp,sp,-48
    800022de:	f406                	sd	ra,40(sp)
    800022e0:	f022                	sd	s0,32(sp)
    800022e2:	ec26                	sd	s1,24(sp)
    800022e4:	e84a                	sd	s2,16(sp)
    800022e6:	e44e                	sd	s3,8(sp)
    800022e8:	1800                	addi	s0,sp,48
    800022ea:	89aa                	mv	s3,a0
    800022ec:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800022ee:	fffff097          	auipc	ra,0xfffff
    800022f2:	7cc080e7          	jalr	1996(ra) # 80001aba <myproc>
    800022f6:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800022f8:	05250663          	beq	a0,s2,80002344 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	9b0080e7          	jalr	-1616(ra) # 80000cac <acquire>
    release(lk);
    80002304:	854a                	mv	a0,s2
    80002306:	fffff097          	auipc	ra,0xfffff
    8000230a:	a5a080e7          	jalr	-1446(ra) # 80000d60 <release>
  p->chan = chan;
    8000230e:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002312:	4785                	li	a5,1
    80002314:	cc9c                	sw	a5,24(s1)
  sched();
    80002316:	00000097          	auipc	ra,0x0
    8000231a:	da6080e7          	jalr	-602(ra) # 800020bc <sched>
  p->chan = 0;
    8000231e:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002322:	8526                	mv	a0,s1
    80002324:	fffff097          	auipc	ra,0xfffff
    80002328:	a3c080e7          	jalr	-1476(ra) # 80000d60 <release>
    acquire(lk);
    8000232c:	854a                	mv	a0,s2
    8000232e:	fffff097          	auipc	ra,0xfffff
    80002332:	97e080e7          	jalr	-1666(ra) # 80000cac <acquire>
}
    80002336:	70a2                	ld	ra,40(sp)
    80002338:	7402                	ld	s0,32(sp)
    8000233a:	64e2                	ld	s1,24(sp)
    8000233c:	6942                	ld	s2,16(sp)
    8000233e:	69a2                	ld	s3,8(sp)
    80002340:	6145                	addi	sp,sp,48
    80002342:	8082                	ret
  p->chan = chan;
    80002344:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002348:	4785                	li	a5,1
    8000234a:	cd1c                	sw	a5,24(a0)
  sched();
    8000234c:	00000097          	auipc	ra,0x0
    80002350:	d70080e7          	jalr	-656(ra) # 800020bc <sched>
  p->chan = 0;
    80002354:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002358:	bff9                	j	80002336 <sleep+0x5a>

000000008000235a <wait>:
{
    8000235a:	715d                	addi	sp,sp,-80
    8000235c:	e486                	sd	ra,72(sp)
    8000235e:	e0a2                	sd	s0,64(sp)
    80002360:	fc26                	sd	s1,56(sp)
    80002362:	f84a                	sd	s2,48(sp)
    80002364:	f44e                	sd	s3,40(sp)
    80002366:	f052                	sd	s4,32(sp)
    80002368:	ec56                	sd	s5,24(sp)
    8000236a:	e85a                	sd	s6,16(sp)
    8000236c:	e45e                	sd	s7,8(sp)
    8000236e:	e062                	sd	s8,0(sp)
    80002370:	0880                	addi	s0,sp,80
    80002372:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	746080e7          	jalr	1862(ra) # 80001aba <myproc>
    8000237c:	892a                	mv	s2,a0
  acquire(&p->lock);
    8000237e:	8c2a                	mv	s8,a0
    80002380:	fffff097          	auipc	ra,0xfffff
    80002384:	92c080e7          	jalr	-1748(ra) # 80000cac <acquire>
    havekids = 0;
    80002388:	4b01                	li	s6,0
        if(np->state == ZOMBIE){
    8000238a:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    8000238c:	00015997          	auipc	s3,0x15
    80002390:	5dc98993          	addi	s3,s3,1500 # 80017968 <tickslock>
        havekids = 1;
    80002394:	4a85                	li	s5,1
    havekids = 0;
    80002396:	875a                	mv	a4,s6
    for(np = proc; np < &proc[NPROC]; np++){
    80002398:	00010497          	auipc	s1,0x10
    8000239c:	9d048493          	addi	s1,s1,-1584 # 80011d68 <proc>
    800023a0:	a08d                	j	80002402 <wait+0xa8>
          pid = np->pid;
    800023a2:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800023a6:	000b8e63          	beqz	s7,800023c2 <wait+0x68>
    800023aa:	4691                	li	a3,4
    800023ac:	03448613          	addi	a2,s1,52
    800023b0:	85de                	mv	a1,s7
    800023b2:	05093503          	ld	a0,80(s2)
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	3e0080e7          	jalr	992(ra) # 80001796 <copyout>
    800023be:	02054263          	bltz	a0,800023e2 <wait+0x88>
          freeproc(np);
    800023c2:	8526                	mv	a0,s1
    800023c4:	00000097          	auipc	ra,0x0
    800023c8:	8aa080e7          	jalr	-1878(ra) # 80001c6e <freeproc>
          release(&np->lock);
    800023cc:	8526                	mv	a0,s1
    800023ce:	fffff097          	auipc	ra,0xfffff
    800023d2:	992080e7          	jalr	-1646(ra) # 80000d60 <release>
          release(&p->lock);
    800023d6:	854a                	mv	a0,s2
    800023d8:	fffff097          	auipc	ra,0xfffff
    800023dc:	988080e7          	jalr	-1656(ra) # 80000d60 <release>
          return pid;
    800023e0:	a8a9                	j	8000243a <wait+0xe0>
            release(&np->lock);
    800023e2:	8526                	mv	a0,s1
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	97c080e7          	jalr	-1668(ra) # 80000d60 <release>
            release(&p->lock);
    800023ec:	854a                	mv	a0,s2
    800023ee:	fffff097          	auipc	ra,0xfffff
    800023f2:	972080e7          	jalr	-1678(ra) # 80000d60 <release>
            return -1;
    800023f6:	59fd                	li	s3,-1
    800023f8:	a089                	j	8000243a <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    800023fa:	17048493          	addi	s1,s1,368
    800023fe:	03348463          	beq	s1,s3,80002426 <wait+0xcc>
      if(np->parent == p){
    80002402:	709c                	ld	a5,32(s1)
    80002404:	ff279be3          	bne	a5,s2,800023fa <wait+0xa0>
        acquire(&np->lock);
    80002408:	8526                	mv	a0,s1
    8000240a:	fffff097          	auipc	ra,0xfffff
    8000240e:	8a2080e7          	jalr	-1886(ra) # 80000cac <acquire>
        if(np->state == ZOMBIE){
    80002412:	4c9c                	lw	a5,24(s1)
    80002414:	f94787e3          	beq	a5,s4,800023a2 <wait+0x48>
        release(&np->lock);
    80002418:	8526                	mv	a0,s1
    8000241a:	fffff097          	auipc	ra,0xfffff
    8000241e:	946080e7          	jalr	-1722(ra) # 80000d60 <release>
        havekids = 1;
    80002422:	8756                	mv	a4,s5
    80002424:	bfd9                	j	800023fa <wait+0xa0>
    if(!havekids || p->killed){
    80002426:	c701                	beqz	a4,8000242e <wait+0xd4>
    80002428:	03092783          	lw	a5,48(s2)
    8000242c:	c785                	beqz	a5,80002454 <wait+0xfa>
      release(&p->lock);
    8000242e:	854a                	mv	a0,s2
    80002430:	fffff097          	auipc	ra,0xfffff
    80002434:	930080e7          	jalr	-1744(ra) # 80000d60 <release>
      return -1;
    80002438:	59fd                	li	s3,-1
}
    8000243a:	854e                	mv	a0,s3
    8000243c:	60a6                	ld	ra,72(sp)
    8000243e:	6406                	ld	s0,64(sp)
    80002440:	74e2                	ld	s1,56(sp)
    80002442:	7942                	ld	s2,48(sp)
    80002444:	79a2                	ld	s3,40(sp)
    80002446:	7a02                	ld	s4,32(sp)
    80002448:	6ae2                	ld	s5,24(sp)
    8000244a:	6b42                	ld	s6,16(sp)
    8000244c:	6ba2                	ld	s7,8(sp)
    8000244e:	6c02                	ld	s8,0(sp)
    80002450:	6161                	addi	sp,sp,80
    80002452:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002454:	85e2                	mv	a1,s8
    80002456:	854a                	mv	a0,s2
    80002458:	00000097          	auipc	ra,0x0
    8000245c:	e84080e7          	jalr	-380(ra) # 800022dc <sleep>
    havekids = 0;
    80002460:	bf1d                	j	80002396 <wait+0x3c>

0000000080002462 <wakeup>:
{
    80002462:	7139                	addi	sp,sp,-64
    80002464:	fc06                	sd	ra,56(sp)
    80002466:	f822                	sd	s0,48(sp)
    80002468:	f426                	sd	s1,40(sp)
    8000246a:	f04a                	sd	s2,32(sp)
    8000246c:	ec4e                	sd	s3,24(sp)
    8000246e:	e852                	sd	s4,16(sp)
    80002470:	e456                	sd	s5,8(sp)
    80002472:	0080                	addi	s0,sp,64
    80002474:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002476:	00010497          	auipc	s1,0x10
    8000247a:	8f248493          	addi	s1,s1,-1806 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    8000247e:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002480:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002482:	00015917          	auipc	s2,0x15
    80002486:	4e690913          	addi	s2,s2,1254 # 80017968 <tickslock>
    8000248a:	a821                	j	800024a2 <wakeup+0x40>
      p->state = RUNNABLE;
    8000248c:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    80002490:	8526                	mv	a0,s1
    80002492:	fffff097          	auipc	ra,0xfffff
    80002496:	8ce080e7          	jalr	-1842(ra) # 80000d60 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000249a:	17048493          	addi	s1,s1,368
    8000249e:	01248e63          	beq	s1,s2,800024ba <wakeup+0x58>
    acquire(&p->lock);
    800024a2:	8526                	mv	a0,s1
    800024a4:	fffff097          	auipc	ra,0xfffff
    800024a8:	808080e7          	jalr	-2040(ra) # 80000cac <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800024ac:	4c9c                	lw	a5,24(s1)
    800024ae:	ff3791e3          	bne	a5,s3,80002490 <wakeup+0x2e>
    800024b2:	749c                	ld	a5,40(s1)
    800024b4:	fd479ee3          	bne	a5,s4,80002490 <wakeup+0x2e>
    800024b8:	bfd1                	j	8000248c <wakeup+0x2a>
}
    800024ba:	70e2                	ld	ra,56(sp)
    800024bc:	7442                	ld	s0,48(sp)
    800024be:	74a2                	ld	s1,40(sp)
    800024c0:	7902                	ld	s2,32(sp)
    800024c2:	69e2                	ld	s3,24(sp)
    800024c4:	6a42                	ld	s4,16(sp)
    800024c6:	6aa2                	ld	s5,8(sp)
    800024c8:	6121                	addi	sp,sp,64
    800024ca:	8082                	ret

00000000800024cc <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800024cc:	7179                	addi	sp,sp,-48
    800024ce:	f406                	sd	ra,40(sp)
    800024d0:	f022                	sd	s0,32(sp)
    800024d2:	ec26                	sd	s1,24(sp)
    800024d4:	e84a                	sd	s2,16(sp)
    800024d6:	e44e                	sd	s3,8(sp)
    800024d8:	1800                	addi	s0,sp,48
    800024da:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024dc:	00010497          	auipc	s1,0x10
    800024e0:	88c48493          	addi	s1,s1,-1908 # 80011d68 <proc>
    800024e4:	00015997          	auipc	s3,0x15
    800024e8:	48498993          	addi	s3,s3,1156 # 80017968 <tickslock>
    acquire(&p->lock);
    800024ec:	8526                	mv	a0,s1
    800024ee:	ffffe097          	auipc	ra,0xffffe
    800024f2:	7be080e7          	jalr	1982(ra) # 80000cac <acquire>
    if(p->pid == pid){
    800024f6:	5c9c                	lw	a5,56(s1)
    800024f8:	01278d63          	beq	a5,s2,80002512 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024fc:	8526                	mv	a0,s1
    800024fe:	fffff097          	auipc	ra,0xfffff
    80002502:	862080e7          	jalr	-1950(ra) # 80000d60 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002506:	17048493          	addi	s1,s1,368
    8000250a:	ff3491e3          	bne	s1,s3,800024ec <kill+0x20>
  }
  return -1;
    8000250e:	557d                	li	a0,-1
    80002510:	a829                	j	8000252a <kill+0x5e>
      p->killed = 1;
    80002512:	4785                	li	a5,1
    80002514:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002516:	4c98                	lw	a4,24(s1)
    80002518:	4785                	li	a5,1
    8000251a:	00f70f63          	beq	a4,a5,80002538 <kill+0x6c>
      release(&p->lock);
    8000251e:	8526                	mv	a0,s1
    80002520:	fffff097          	auipc	ra,0xfffff
    80002524:	840080e7          	jalr	-1984(ra) # 80000d60 <release>
      return 0;
    80002528:	4501                	li	a0,0
}
    8000252a:	70a2                	ld	ra,40(sp)
    8000252c:	7402                	ld	s0,32(sp)
    8000252e:	64e2                	ld	s1,24(sp)
    80002530:	6942                	ld	s2,16(sp)
    80002532:	69a2                	ld	s3,8(sp)
    80002534:	6145                	addi	sp,sp,48
    80002536:	8082                	ret
        p->state = RUNNABLE;
    80002538:	4789                	li	a5,2
    8000253a:	cc9c                	sw	a5,24(s1)
    8000253c:	b7cd                	j	8000251e <kill+0x52>

000000008000253e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000253e:	7179                	addi	sp,sp,-48
    80002540:	f406                	sd	ra,40(sp)
    80002542:	f022                	sd	s0,32(sp)
    80002544:	ec26                	sd	s1,24(sp)
    80002546:	e84a                	sd	s2,16(sp)
    80002548:	e44e                	sd	s3,8(sp)
    8000254a:	e052                	sd	s4,0(sp)
    8000254c:	1800                	addi	s0,sp,48
    8000254e:	84aa                	mv	s1,a0
    80002550:	892e                	mv	s2,a1
    80002552:	89b2                	mv	s3,a2
    80002554:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002556:	fffff097          	auipc	ra,0xfffff
    8000255a:	564080e7          	jalr	1380(ra) # 80001aba <myproc>
  if(user_dst){
    8000255e:	c08d                	beqz	s1,80002580 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002560:	86d2                	mv	a3,s4
    80002562:	864e                	mv	a2,s3
    80002564:	85ca                	mv	a1,s2
    80002566:	6928                	ld	a0,80(a0)
    80002568:	fffff097          	auipc	ra,0xfffff
    8000256c:	22e080e7          	jalr	558(ra) # 80001796 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002570:	70a2                	ld	ra,40(sp)
    80002572:	7402                	ld	s0,32(sp)
    80002574:	64e2                	ld	s1,24(sp)
    80002576:	6942                	ld	s2,16(sp)
    80002578:	69a2                	ld	s3,8(sp)
    8000257a:	6a02                	ld	s4,0(sp)
    8000257c:	6145                	addi	sp,sp,48
    8000257e:	8082                	ret
    memmove((char *)dst, src, len);
    80002580:	000a061b          	sext.w	a2,s4
    80002584:	85ce                	mv	a1,s3
    80002586:	854a                	mv	a0,s2
    80002588:	fffff097          	auipc	ra,0xfffff
    8000258c:	88c080e7          	jalr	-1908(ra) # 80000e14 <memmove>
    return 0;
    80002590:	8526                	mv	a0,s1
    80002592:	bff9                	j	80002570 <either_copyout+0x32>

0000000080002594 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002594:	7179                	addi	sp,sp,-48
    80002596:	f406                	sd	ra,40(sp)
    80002598:	f022                	sd	s0,32(sp)
    8000259a:	ec26                	sd	s1,24(sp)
    8000259c:	e84a                	sd	s2,16(sp)
    8000259e:	e44e                	sd	s3,8(sp)
    800025a0:	e052                	sd	s4,0(sp)
    800025a2:	1800                	addi	s0,sp,48
    800025a4:	892a                	mv	s2,a0
    800025a6:	84ae                	mv	s1,a1
    800025a8:	89b2                	mv	s3,a2
    800025aa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025ac:	fffff097          	auipc	ra,0xfffff
    800025b0:	50e080e7          	jalr	1294(ra) # 80001aba <myproc>
  if(user_src){
    800025b4:	c08d                	beqz	s1,800025d6 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800025b6:	86d2                	mv	a3,s4
    800025b8:	864e                	mv	a2,s3
    800025ba:	85ca                	mv	a1,s2
    800025bc:	6928                	ld	a0,80(a0)
    800025be:	fffff097          	auipc	ra,0xfffff
    800025c2:	264080e7          	jalr	612(ra) # 80001822 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025c6:	70a2                	ld	ra,40(sp)
    800025c8:	7402                	ld	s0,32(sp)
    800025ca:	64e2                	ld	s1,24(sp)
    800025cc:	6942                	ld	s2,16(sp)
    800025ce:	69a2                	ld	s3,8(sp)
    800025d0:	6a02                	ld	s4,0(sp)
    800025d2:	6145                	addi	sp,sp,48
    800025d4:	8082                	ret
    memmove(dst, (char*)src, len);
    800025d6:	000a061b          	sext.w	a2,s4
    800025da:	85ce                	mv	a1,s3
    800025dc:	854a                	mv	a0,s2
    800025de:	fffff097          	auipc	ra,0xfffff
    800025e2:	836080e7          	jalr	-1994(ra) # 80000e14 <memmove>
    return 0;
    800025e6:	8526                	mv	a0,s1
    800025e8:	bff9                	j	800025c6 <either_copyin+0x32>

00000000800025ea <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025ea:	715d                	addi	sp,sp,-80
    800025ec:	e486                	sd	ra,72(sp)
    800025ee:	e0a2                	sd	s0,64(sp)
    800025f0:	fc26                	sd	s1,56(sp)
    800025f2:	f84a                	sd	s2,48(sp)
    800025f4:	f44e                	sd	s3,40(sp)
    800025f6:	f052                	sd	s4,32(sp)
    800025f8:	ec56                	sd	s5,24(sp)
    800025fa:	e85a                	sd	s6,16(sp)
    800025fc:	e45e                	sd	s7,8(sp)
    800025fe:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002600:	00006517          	auipc	a0,0x6
    80002604:	ac850513          	addi	a0,a0,-1336 # 800080c8 <digits+0xb0>
    80002608:	ffffe097          	auipc	ra,0xffffe
    8000260c:	fb6080e7          	jalr	-74(ra) # 800005be <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002610:	00010497          	auipc	s1,0x10
    80002614:	8b048493          	addi	s1,s1,-1872 # 80011ec0 <proc+0x158>
    80002618:	00015917          	auipc	s2,0x15
    8000261c:	4a890913          	addi	s2,s2,1192 # 80017ac0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002620:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002622:	00006997          	auipc	s3,0x6
    80002626:	c6e98993          	addi	s3,s3,-914 # 80008290 <states.1727+0xc8>
    printf("%d %s %s", p->pid, state, p->name);
    8000262a:	00006a97          	auipc	s5,0x6
    8000262e:	c6ea8a93          	addi	s5,s5,-914 # 80008298 <states.1727+0xd0>
    printf("\n");
    80002632:	00006a17          	auipc	s4,0x6
    80002636:	a96a0a13          	addi	s4,s4,-1386 # 800080c8 <digits+0xb0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000263a:	00006b97          	auipc	s7,0x6
    8000263e:	b8eb8b93          	addi	s7,s7,-1138 # 800081c8 <states.1727>
    80002642:	a015                	j	80002666 <procdump+0x7c>
    printf("%d %s %s", p->pid, state, p->name);
    80002644:	86ba                	mv	a3,a4
    80002646:	ee072583          	lw	a1,-288(a4)
    8000264a:	8556                	mv	a0,s5
    8000264c:	ffffe097          	auipc	ra,0xffffe
    80002650:	f72080e7          	jalr	-142(ra) # 800005be <printf>
    printf("\n");
    80002654:	8552                	mv	a0,s4
    80002656:	ffffe097          	auipc	ra,0xffffe
    8000265a:	f68080e7          	jalr	-152(ra) # 800005be <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000265e:	17048493          	addi	s1,s1,368
    80002662:	03248163          	beq	s1,s2,80002684 <procdump+0x9a>
    if(p->state == UNUSED)
    80002666:	8726                	mv	a4,s1
    80002668:	ec04a783          	lw	a5,-320(s1)
    8000266c:	dbed                	beqz	a5,8000265e <procdump+0x74>
      state = "???";
    8000266e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002670:	fcfb6ae3          	bltu	s6,a5,80002644 <procdump+0x5a>
    80002674:	1782                	slli	a5,a5,0x20
    80002676:	9381                	srli	a5,a5,0x20
    80002678:	078e                	slli	a5,a5,0x3
    8000267a:	97de                	add	a5,a5,s7
    8000267c:	6390                	ld	a2,0(a5)
    8000267e:	f279                	bnez	a2,80002644 <procdump+0x5a>
      state = "???";
    80002680:	864e                	mv	a2,s3
    80002682:	b7c9                	j	80002644 <procdump+0x5a>
  }
}
    80002684:	60a6                	ld	ra,72(sp)
    80002686:	6406                	ld	s0,64(sp)
    80002688:	74e2                	ld	s1,56(sp)
    8000268a:	7942                	ld	s2,48(sp)
    8000268c:	79a2                	ld	s3,40(sp)
    8000268e:	7a02                	ld	s4,32(sp)
    80002690:	6ae2                	ld	s5,24(sp)
    80002692:	6b42                	ld	s6,16(sp)
    80002694:	6ba2                	ld	s7,8(sp)
    80002696:	6161                	addi	sp,sp,80
    80002698:	8082                	ret

000000008000269a <count_free_proc>:

// Count how many processes are not in the state of UNUSED
uint64
count_free_proc(void) {
    8000269a:	7179                	addi	sp,sp,-48
    8000269c:	f406                	sd	ra,40(sp)
    8000269e:	f022                	sd	s0,32(sp)
    800026a0:	ec26                	sd	s1,24(sp)
    800026a2:	e84a                	sd	s2,16(sp)
    800026a4:	e44e                	sd	s3,8(sp)
    800026a6:	1800                	addi	s0,sp,48
  struct proc *p;
  uint64 count = 0;
    800026a8:	4901                	li	s2,0
  for(p = proc; p < &proc[NPROC]; p++) {
    800026aa:	0000f497          	auipc	s1,0xf
    800026ae:	6be48493          	addi	s1,s1,1726 # 80011d68 <proc>
    800026b2:	00015997          	auipc	s3,0x15
    800026b6:	2b698993          	addi	s3,s3,694 # 80017968 <tickslock>
    acquire(&p->lock);
    800026ba:	8526                	mv	a0,s1
    800026bc:	ffffe097          	auipc	ra,0xffffe
    800026c0:	5f0080e7          	jalr	1520(ra) # 80000cac <acquire>
    if(p->state != UNUSED) {
    800026c4:	4c9c                	lw	a5,24(s1)
      count += 1;
    800026c6:	00f037b3          	snez	a5,a5
    800026ca:	993e                	add	s2,s2,a5
    }
    release(&p->lock);
    800026cc:	8526                	mv	a0,s1
    800026ce:	ffffe097          	auipc	ra,0xffffe
    800026d2:	692080e7          	jalr	1682(ra) # 80000d60 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800026d6:	17048493          	addi	s1,s1,368
    800026da:	ff3490e3          	bne	s1,s3,800026ba <count_free_proc+0x20>
  }
  return count;
}
    800026de:	854a                	mv	a0,s2
    800026e0:	70a2                	ld	ra,40(sp)
    800026e2:	7402                	ld	s0,32(sp)
    800026e4:	64e2                	ld	s1,24(sp)
    800026e6:	6942                	ld	s2,16(sp)
    800026e8:	69a2                	ld	s3,8(sp)
    800026ea:	6145                	addi	sp,sp,48
    800026ec:	8082                	ret

00000000800026ee <swtch>:
    800026ee:	00153023          	sd	ra,0(a0)
    800026f2:	00253423          	sd	sp,8(a0)
    800026f6:	e900                	sd	s0,16(a0)
    800026f8:	ed04                	sd	s1,24(a0)
    800026fa:	03253023          	sd	s2,32(a0)
    800026fe:	03353423          	sd	s3,40(a0)
    80002702:	03453823          	sd	s4,48(a0)
    80002706:	03553c23          	sd	s5,56(a0)
    8000270a:	05653023          	sd	s6,64(a0)
    8000270e:	05753423          	sd	s7,72(a0)
    80002712:	05853823          	sd	s8,80(a0)
    80002716:	05953c23          	sd	s9,88(a0)
    8000271a:	07a53023          	sd	s10,96(a0)
    8000271e:	07b53423          	sd	s11,104(a0)
    80002722:	0005b083          	ld	ra,0(a1)
    80002726:	0085b103          	ld	sp,8(a1)
    8000272a:	6980                	ld	s0,16(a1)
    8000272c:	6d84                	ld	s1,24(a1)
    8000272e:	0205b903          	ld	s2,32(a1)
    80002732:	0285b983          	ld	s3,40(a1)
    80002736:	0305ba03          	ld	s4,48(a1)
    8000273a:	0385ba83          	ld	s5,56(a1)
    8000273e:	0405bb03          	ld	s6,64(a1)
    80002742:	0485bb83          	ld	s7,72(a1)
    80002746:	0505bc03          	ld	s8,80(a1)
    8000274a:	0585bc83          	ld	s9,88(a1)
    8000274e:	0605bd03          	ld	s10,96(a1)
    80002752:	0685bd83          	ld	s11,104(a1)
    80002756:	8082                	ret

0000000080002758 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002758:	1141                	addi	sp,sp,-16
    8000275a:	e406                	sd	ra,8(sp)
    8000275c:	e022                	sd	s0,0(sp)
    8000275e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002760:	00006597          	auipc	a1,0x6
    80002764:	b7058593          	addi	a1,a1,-1168 # 800082d0 <states.1727+0x108>
    80002768:	00015517          	auipc	a0,0x15
    8000276c:	20050513          	addi	a0,a0,512 # 80017968 <tickslock>
    80002770:	ffffe097          	auipc	ra,0xffffe
    80002774:	4ac080e7          	jalr	1196(ra) # 80000c1c <initlock>
}
    80002778:	60a2                	ld	ra,8(sp)
    8000277a:	6402                	ld	s0,0(sp)
    8000277c:	0141                	addi	sp,sp,16
    8000277e:	8082                	ret

0000000080002780 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002780:	1141                	addi	sp,sp,-16
    80002782:	e422                	sd	s0,8(sp)
    80002784:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002786:	00003797          	auipc	a5,0x3
    8000278a:	67a78793          	addi	a5,a5,1658 # 80005e00 <kernelvec>
    8000278e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002792:	6422                	ld	s0,8(sp)
    80002794:	0141                	addi	sp,sp,16
    80002796:	8082                	ret

0000000080002798 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002798:	1141                	addi	sp,sp,-16
    8000279a:	e406                	sd	ra,8(sp)
    8000279c:	e022                	sd	s0,0(sp)
    8000279e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800027a0:	fffff097          	auipc	ra,0xfffff
    800027a4:	31a080e7          	jalr	794(ra) # 80001aba <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027a8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027ac:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027ae:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800027b2:	00005617          	auipc	a2,0x5
    800027b6:	84e60613          	addi	a2,a2,-1970 # 80007000 <_trampoline>
    800027ba:	00005697          	auipc	a3,0x5
    800027be:	84668693          	addi	a3,a3,-1978 # 80007000 <_trampoline>
    800027c2:	8e91                	sub	a3,a3,a2
    800027c4:	040007b7          	lui	a5,0x4000
    800027c8:	17fd                	addi	a5,a5,-1
    800027ca:	07b2                	slli	a5,a5,0xc
    800027cc:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027ce:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027d2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027d4:	180026f3          	csrr	a3,satp
    800027d8:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027da:	6d38                	ld	a4,88(a0)
    800027dc:	6134                	ld	a3,64(a0)
    800027de:	6585                	lui	a1,0x1
    800027e0:	96ae                	add	a3,a3,a1
    800027e2:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027e4:	6d38                	ld	a4,88(a0)
    800027e6:	00000697          	auipc	a3,0x0
    800027ea:	13868693          	addi	a3,a3,312 # 8000291e <usertrap>
    800027ee:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027f0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027f2:	8692                	mv	a3,tp
    800027f4:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027f6:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027fa:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027fe:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002802:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002806:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002808:	6f18                	ld	a4,24(a4)
    8000280a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000280e:	692c                	ld	a1,80(a0)
    80002810:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002812:	00005717          	auipc	a4,0x5
    80002816:	87e70713          	addi	a4,a4,-1922 # 80007090 <userret>
    8000281a:	8f11                	sub	a4,a4,a2
    8000281c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000281e:	577d                	li	a4,-1
    80002820:	177e                	slli	a4,a4,0x3f
    80002822:	8dd9                	or	a1,a1,a4
    80002824:	02000537          	lui	a0,0x2000
    80002828:	157d                	addi	a0,a0,-1
    8000282a:	0536                	slli	a0,a0,0xd
    8000282c:	9782                	jalr	a5
}
    8000282e:	60a2                	ld	ra,8(sp)
    80002830:	6402                	ld	s0,0(sp)
    80002832:	0141                	addi	sp,sp,16
    80002834:	8082                	ret

0000000080002836 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002836:	1101                	addi	sp,sp,-32
    80002838:	ec06                	sd	ra,24(sp)
    8000283a:	e822                	sd	s0,16(sp)
    8000283c:	e426                	sd	s1,8(sp)
    8000283e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002840:	00015497          	auipc	s1,0x15
    80002844:	12848493          	addi	s1,s1,296 # 80017968 <tickslock>
    80002848:	8526                	mv	a0,s1
    8000284a:	ffffe097          	auipc	ra,0xffffe
    8000284e:	462080e7          	jalr	1122(ra) # 80000cac <acquire>
  ticks++;
    80002852:	00006517          	auipc	a0,0x6
    80002856:	7ce50513          	addi	a0,a0,1998 # 80009020 <ticks>
    8000285a:	411c                	lw	a5,0(a0)
    8000285c:	2785                	addiw	a5,a5,1
    8000285e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002860:	00000097          	auipc	ra,0x0
    80002864:	c02080e7          	jalr	-1022(ra) # 80002462 <wakeup>
  release(&tickslock);
    80002868:	8526                	mv	a0,s1
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	4f6080e7          	jalr	1270(ra) # 80000d60 <release>
}
    80002872:	60e2                	ld	ra,24(sp)
    80002874:	6442                	ld	s0,16(sp)
    80002876:	64a2                	ld	s1,8(sp)
    80002878:	6105                	addi	sp,sp,32
    8000287a:	8082                	ret

000000008000287c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000287c:	1101                	addi	sp,sp,-32
    8000287e:	ec06                	sd	ra,24(sp)
    80002880:	e822                	sd	s0,16(sp)
    80002882:	e426                	sd	s1,8(sp)
    80002884:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002886:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000288a:	00074d63          	bltz	a4,800028a4 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000288e:	57fd                	li	a5,-1
    80002890:	17fe                	slli	a5,a5,0x3f
    80002892:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002894:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002896:	06f70363          	beq	a4,a5,800028fc <devintr+0x80>
  }
}
    8000289a:	60e2                	ld	ra,24(sp)
    8000289c:	6442                	ld	s0,16(sp)
    8000289e:	64a2                	ld	s1,8(sp)
    800028a0:	6105                	addi	sp,sp,32
    800028a2:	8082                	ret
     (scause & 0xff) == 9){
    800028a4:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800028a8:	46a5                	li	a3,9
    800028aa:	fed792e3          	bne	a5,a3,8000288e <devintr+0x12>
    int irq = plic_claim();
    800028ae:	00003097          	auipc	ra,0x3
    800028b2:	65a080e7          	jalr	1626(ra) # 80005f08 <plic_claim>
    800028b6:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028b8:	47a9                	li	a5,10
    800028ba:	02f50763          	beq	a0,a5,800028e8 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800028be:	4785                	li	a5,1
    800028c0:	02f50963          	beq	a0,a5,800028f2 <devintr+0x76>
    return 1;
    800028c4:	4505                	li	a0,1
    } else if(irq){
    800028c6:	d8f1                	beqz	s1,8000289a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800028c8:	85a6                	mv	a1,s1
    800028ca:	00006517          	auipc	a0,0x6
    800028ce:	a0e50513          	addi	a0,a0,-1522 # 800082d8 <states.1727+0x110>
    800028d2:	ffffe097          	auipc	ra,0xffffe
    800028d6:	cec080e7          	jalr	-788(ra) # 800005be <printf>
      plic_complete(irq);
    800028da:	8526                	mv	a0,s1
    800028dc:	00003097          	auipc	ra,0x3
    800028e0:	650080e7          	jalr	1616(ra) # 80005f2c <plic_complete>
    return 1;
    800028e4:	4505                	li	a0,1
    800028e6:	bf55                	j	8000289a <devintr+0x1e>
      uartintr();
    800028e8:	ffffe097          	auipc	ra,0xffffe
    800028ec:	13a080e7          	jalr	314(ra) # 80000a22 <uartintr>
    800028f0:	b7ed                	j	800028da <devintr+0x5e>
      virtio_disk_intr();
    800028f2:	00004097          	auipc	ra,0x4
    800028f6:	ae6080e7          	jalr	-1306(ra) # 800063d8 <virtio_disk_intr>
    800028fa:	b7c5                	j	800028da <devintr+0x5e>
    if(cpuid() == 0){
    800028fc:	fffff097          	auipc	ra,0xfffff
    80002900:	192080e7          	jalr	402(ra) # 80001a8e <cpuid>
    80002904:	c901                	beqz	a0,80002914 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002906:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000290a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000290c:	14479073          	csrw	sip,a5
    return 2;
    80002910:	4509                	li	a0,2
    80002912:	b761                	j	8000289a <devintr+0x1e>
      clockintr();
    80002914:	00000097          	auipc	ra,0x0
    80002918:	f22080e7          	jalr	-222(ra) # 80002836 <clockintr>
    8000291c:	b7ed                	j	80002906 <devintr+0x8a>

000000008000291e <usertrap>:
{
    8000291e:	1101                	addi	sp,sp,-32
    80002920:	ec06                	sd	ra,24(sp)
    80002922:	e822                	sd	s0,16(sp)
    80002924:	e426                	sd	s1,8(sp)
    80002926:	e04a                	sd	s2,0(sp)
    80002928:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000292a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000292e:	1007f793          	andi	a5,a5,256
    80002932:	e3ad                	bnez	a5,80002994 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002934:	00003797          	auipc	a5,0x3
    80002938:	4cc78793          	addi	a5,a5,1228 # 80005e00 <kernelvec>
    8000293c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002940:	fffff097          	auipc	ra,0xfffff
    80002944:	17a080e7          	jalr	378(ra) # 80001aba <myproc>
    80002948:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000294a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000294c:	14102773          	csrr	a4,sepc
    80002950:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002952:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002956:	47a1                	li	a5,8
    80002958:	04f71c63          	bne	a4,a5,800029b0 <usertrap+0x92>
    if(p->killed)
    8000295c:	591c                	lw	a5,48(a0)
    8000295e:	e3b9                	bnez	a5,800029a4 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002960:	6cb8                	ld	a4,88(s1)
    80002962:	6f1c                	ld	a5,24(a4)
    80002964:	0791                	addi	a5,a5,4
    80002966:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002968:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000296c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002970:	10079073          	csrw	sstatus,a5
    syscall();
    80002974:	00000097          	auipc	ra,0x0
    80002978:	2e6080e7          	jalr	742(ra) # 80002c5a <syscall>
  if(p->killed)
    8000297c:	589c                	lw	a5,48(s1)
    8000297e:	ebc1                	bnez	a5,80002a0e <usertrap+0xf0>
  usertrapret();
    80002980:	00000097          	auipc	ra,0x0
    80002984:	e18080e7          	jalr	-488(ra) # 80002798 <usertrapret>
}
    80002988:	60e2                	ld	ra,24(sp)
    8000298a:	6442                	ld	s0,16(sp)
    8000298c:	64a2                	ld	s1,8(sp)
    8000298e:	6902                	ld	s2,0(sp)
    80002990:	6105                	addi	sp,sp,32
    80002992:	8082                	ret
    panic("usertrap: not from user mode");
    80002994:	00006517          	auipc	a0,0x6
    80002998:	96450513          	addi	a0,a0,-1692 # 800082f8 <states.1727+0x130>
    8000299c:	ffffe097          	auipc	ra,0xffffe
    800029a0:	bd8080e7          	jalr	-1064(ra) # 80000574 <panic>
      exit(-1);
    800029a4:	557d                	li	a0,-1
    800029a6:	fffff097          	auipc	ra,0xfffff
    800029aa:	7ee080e7          	jalr	2030(ra) # 80002194 <exit>
    800029ae:	bf4d                	j	80002960 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800029b0:	00000097          	auipc	ra,0x0
    800029b4:	ecc080e7          	jalr	-308(ra) # 8000287c <devintr>
    800029b8:	892a                	mv	s2,a0
    800029ba:	c501                	beqz	a0,800029c2 <usertrap+0xa4>
  if(p->killed)
    800029bc:	589c                	lw	a5,48(s1)
    800029be:	c3a1                	beqz	a5,800029fe <usertrap+0xe0>
    800029c0:	a815                	j	800029f4 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029c2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029c6:	5c90                	lw	a2,56(s1)
    800029c8:	00006517          	auipc	a0,0x6
    800029cc:	95050513          	addi	a0,a0,-1712 # 80008318 <states.1727+0x150>
    800029d0:	ffffe097          	auipc	ra,0xffffe
    800029d4:	bee080e7          	jalr	-1042(ra) # 800005be <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029d8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029dc:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029e0:	00006517          	auipc	a0,0x6
    800029e4:	96850513          	addi	a0,a0,-1688 # 80008348 <states.1727+0x180>
    800029e8:	ffffe097          	auipc	ra,0xffffe
    800029ec:	bd6080e7          	jalr	-1066(ra) # 800005be <printf>
    p->killed = 1;
    800029f0:	4785                	li	a5,1
    800029f2:	d89c                	sw	a5,48(s1)
    exit(-1);
    800029f4:	557d                	li	a0,-1
    800029f6:	fffff097          	auipc	ra,0xfffff
    800029fa:	79e080e7          	jalr	1950(ra) # 80002194 <exit>
  if(which_dev == 2)
    800029fe:	4789                	li	a5,2
    80002a00:	f8f910e3          	bne	s2,a5,80002980 <usertrap+0x62>
    yield();
    80002a04:	00000097          	auipc	ra,0x0
    80002a08:	89c080e7          	jalr	-1892(ra) # 800022a0 <yield>
    80002a0c:	bf95                	j	80002980 <usertrap+0x62>
  int which_dev = 0;
    80002a0e:	4901                	li	s2,0
    80002a10:	b7d5                	j	800029f4 <usertrap+0xd6>

0000000080002a12 <kerneltrap>:
{
    80002a12:	7179                	addi	sp,sp,-48
    80002a14:	f406                	sd	ra,40(sp)
    80002a16:	f022                	sd	s0,32(sp)
    80002a18:	ec26                	sd	s1,24(sp)
    80002a1a:	e84a                	sd	s2,16(sp)
    80002a1c:	e44e                	sd	s3,8(sp)
    80002a1e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a20:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a24:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a28:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a2c:	1004f793          	andi	a5,s1,256
    80002a30:	cb85                	beqz	a5,80002a60 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a32:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a36:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a38:	ef85                	bnez	a5,80002a70 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a3a:	00000097          	auipc	ra,0x0
    80002a3e:	e42080e7          	jalr	-446(ra) # 8000287c <devintr>
    80002a42:	cd1d                	beqz	a0,80002a80 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a44:	4789                	li	a5,2
    80002a46:	06f50a63          	beq	a0,a5,80002aba <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a4a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a4e:	10049073          	csrw	sstatus,s1
}
    80002a52:	70a2                	ld	ra,40(sp)
    80002a54:	7402                	ld	s0,32(sp)
    80002a56:	64e2                	ld	s1,24(sp)
    80002a58:	6942                	ld	s2,16(sp)
    80002a5a:	69a2                	ld	s3,8(sp)
    80002a5c:	6145                	addi	sp,sp,48
    80002a5e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a60:	00006517          	auipc	a0,0x6
    80002a64:	90850513          	addi	a0,a0,-1784 # 80008368 <states.1727+0x1a0>
    80002a68:	ffffe097          	auipc	ra,0xffffe
    80002a6c:	b0c080e7          	jalr	-1268(ra) # 80000574 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a70:	00006517          	auipc	a0,0x6
    80002a74:	92050513          	addi	a0,a0,-1760 # 80008390 <states.1727+0x1c8>
    80002a78:	ffffe097          	auipc	ra,0xffffe
    80002a7c:	afc080e7          	jalr	-1284(ra) # 80000574 <panic>
    printf("scause %p\n", scause);
    80002a80:	85ce                	mv	a1,s3
    80002a82:	00006517          	auipc	a0,0x6
    80002a86:	92e50513          	addi	a0,a0,-1746 # 800083b0 <states.1727+0x1e8>
    80002a8a:	ffffe097          	auipc	ra,0xffffe
    80002a8e:	b34080e7          	jalr	-1228(ra) # 800005be <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a92:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a96:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a9a:	00006517          	auipc	a0,0x6
    80002a9e:	92650513          	addi	a0,a0,-1754 # 800083c0 <states.1727+0x1f8>
    80002aa2:	ffffe097          	auipc	ra,0xffffe
    80002aa6:	b1c080e7          	jalr	-1252(ra) # 800005be <printf>
    panic("kerneltrap");
    80002aaa:	00006517          	auipc	a0,0x6
    80002aae:	92e50513          	addi	a0,a0,-1746 # 800083d8 <states.1727+0x210>
    80002ab2:	ffffe097          	auipc	ra,0xffffe
    80002ab6:	ac2080e7          	jalr	-1342(ra) # 80000574 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002aba:	fffff097          	auipc	ra,0xfffff
    80002abe:	000080e7          	jalr	ra # 80001aba <myproc>
    80002ac2:	d541                	beqz	a0,80002a4a <kerneltrap+0x38>
    80002ac4:	fffff097          	auipc	ra,0xfffff
    80002ac8:	ff6080e7          	jalr	-10(ra) # 80001aba <myproc>
    80002acc:	4d18                	lw	a4,24(a0)
    80002ace:	478d                	li	a5,3
    80002ad0:	f6f71de3          	bne	a4,a5,80002a4a <kerneltrap+0x38>
    yield();
    80002ad4:	fffff097          	auipc	ra,0xfffff
    80002ad8:	7cc080e7          	jalr	1996(ra) # 800022a0 <yield>
    80002adc:	b7bd                	j	80002a4a <kerneltrap+0x38>

0000000080002ade <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ade:	1101                	addi	sp,sp,-32
    80002ae0:	ec06                	sd	ra,24(sp)
    80002ae2:	e822                	sd	s0,16(sp)
    80002ae4:	e426                	sd	s1,8(sp)
    80002ae6:	1000                	addi	s0,sp,32
    80002ae8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002aea:	fffff097          	auipc	ra,0xfffff
    80002aee:	fd0080e7          	jalr	-48(ra) # 80001aba <myproc>
  switch (n) {
    80002af2:	4795                	li	a5,5
    80002af4:	0497e363          	bltu	a5,s1,80002b3a <argraw+0x5c>
    80002af8:	1482                	slli	s1,s1,0x20
    80002afa:	9081                	srli	s1,s1,0x20
    80002afc:	048a                	slli	s1,s1,0x2
    80002afe:	00006717          	auipc	a4,0x6
    80002b02:	8ea70713          	addi	a4,a4,-1814 # 800083e8 <states.1727+0x220>
    80002b06:	94ba                	add	s1,s1,a4
    80002b08:	409c                	lw	a5,0(s1)
    80002b0a:	97ba                	add	a5,a5,a4
    80002b0c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b0e:	6d3c                	ld	a5,88(a0)
    80002b10:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b12:	60e2                	ld	ra,24(sp)
    80002b14:	6442                	ld	s0,16(sp)
    80002b16:	64a2                	ld	s1,8(sp)
    80002b18:	6105                	addi	sp,sp,32
    80002b1a:	8082                	ret
    return p->trapframe->a1;
    80002b1c:	6d3c                	ld	a5,88(a0)
    80002b1e:	7fa8                	ld	a0,120(a5)
    80002b20:	bfcd                	j	80002b12 <argraw+0x34>
    return p->trapframe->a2;
    80002b22:	6d3c                	ld	a5,88(a0)
    80002b24:	63c8                	ld	a0,128(a5)
    80002b26:	b7f5                	j	80002b12 <argraw+0x34>
    return p->trapframe->a3;
    80002b28:	6d3c                	ld	a5,88(a0)
    80002b2a:	67c8                	ld	a0,136(a5)
    80002b2c:	b7dd                	j	80002b12 <argraw+0x34>
    return p->trapframe->a4;
    80002b2e:	6d3c                	ld	a5,88(a0)
    80002b30:	6bc8                	ld	a0,144(a5)
    80002b32:	b7c5                	j	80002b12 <argraw+0x34>
    return p->trapframe->a5;
    80002b34:	6d3c                	ld	a5,88(a0)
    80002b36:	6fc8                	ld	a0,152(a5)
    80002b38:	bfe9                	j	80002b12 <argraw+0x34>
  panic("argraw");
    80002b3a:	00006517          	auipc	a0,0x6
    80002b3e:	a4650513          	addi	a0,a0,-1466 # 80008580 <sysnames+0xc0>
    80002b42:	ffffe097          	auipc	ra,0xffffe
    80002b46:	a32080e7          	jalr	-1486(ra) # 80000574 <panic>

0000000080002b4a <fetchaddr>:
{
    80002b4a:	1101                	addi	sp,sp,-32
    80002b4c:	ec06                	sd	ra,24(sp)
    80002b4e:	e822                	sd	s0,16(sp)
    80002b50:	e426                	sd	s1,8(sp)
    80002b52:	e04a                	sd	s2,0(sp)
    80002b54:	1000                	addi	s0,sp,32
    80002b56:	84aa                	mv	s1,a0
    80002b58:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b5a:	fffff097          	auipc	ra,0xfffff
    80002b5e:	f60080e7          	jalr	-160(ra) # 80001aba <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002b62:	653c                	ld	a5,72(a0)
    80002b64:	02f4f963          	bleu	a5,s1,80002b96 <fetchaddr+0x4c>
    80002b68:	00848713          	addi	a4,s1,8
    80002b6c:	02e7e763          	bltu	a5,a4,80002b9a <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b70:	46a1                	li	a3,8
    80002b72:	8626                	mv	a2,s1
    80002b74:	85ca                	mv	a1,s2
    80002b76:	6928                	ld	a0,80(a0)
    80002b78:	fffff097          	auipc	ra,0xfffff
    80002b7c:	caa080e7          	jalr	-854(ra) # 80001822 <copyin>
    80002b80:	00a03533          	snez	a0,a0
    80002b84:	40a0053b          	negw	a0,a0
    80002b88:	2501                	sext.w	a0,a0
}
    80002b8a:	60e2                	ld	ra,24(sp)
    80002b8c:	6442                	ld	s0,16(sp)
    80002b8e:	64a2                	ld	s1,8(sp)
    80002b90:	6902                	ld	s2,0(sp)
    80002b92:	6105                	addi	sp,sp,32
    80002b94:	8082                	ret
    return -1;
    80002b96:	557d                	li	a0,-1
    80002b98:	bfcd                	j	80002b8a <fetchaddr+0x40>
    80002b9a:	557d                	li	a0,-1
    80002b9c:	b7fd                	j	80002b8a <fetchaddr+0x40>

0000000080002b9e <fetchstr>:
{
    80002b9e:	7179                	addi	sp,sp,-48
    80002ba0:	f406                	sd	ra,40(sp)
    80002ba2:	f022                	sd	s0,32(sp)
    80002ba4:	ec26                	sd	s1,24(sp)
    80002ba6:	e84a                	sd	s2,16(sp)
    80002ba8:	e44e                	sd	s3,8(sp)
    80002baa:	1800                	addi	s0,sp,48
    80002bac:	892a                	mv	s2,a0
    80002bae:	84ae                	mv	s1,a1
    80002bb0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002bb2:	fffff097          	auipc	ra,0xfffff
    80002bb6:	f08080e7          	jalr	-248(ra) # 80001aba <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002bba:	86ce                	mv	a3,s3
    80002bbc:	864a                	mv	a2,s2
    80002bbe:	85a6                	mv	a1,s1
    80002bc0:	6928                	ld	a0,80(a0)
    80002bc2:	fffff097          	auipc	ra,0xfffff
    80002bc6:	cee080e7          	jalr	-786(ra) # 800018b0 <copyinstr>
  if(err < 0)
    80002bca:	00054763          	bltz	a0,80002bd8 <fetchstr+0x3a>
  return strlen(buf);
    80002bce:	8526                	mv	a0,s1
    80002bd0:	ffffe097          	auipc	ra,0xffffe
    80002bd4:	382080e7          	jalr	898(ra) # 80000f52 <strlen>
}
    80002bd8:	70a2                	ld	ra,40(sp)
    80002bda:	7402                	ld	s0,32(sp)
    80002bdc:	64e2                	ld	s1,24(sp)
    80002bde:	6942                	ld	s2,16(sp)
    80002be0:	69a2                	ld	s3,8(sp)
    80002be2:	6145                	addi	sp,sp,48
    80002be4:	8082                	ret

0000000080002be6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002be6:	1101                	addi	sp,sp,-32
    80002be8:	ec06                	sd	ra,24(sp)
    80002bea:	e822                	sd	s0,16(sp)
    80002bec:	e426                	sd	s1,8(sp)
    80002bee:	1000                	addi	s0,sp,32
    80002bf0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bf2:	00000097          	auipc	ra,0x0
    80002bf6:	eec080e7          	jalr	-276(ra) # 80002ade <argraw>
    80002bfa:	c088                	sw	a0,0(s1)
  return 0;
}
    80002bfc:	4501                	li	a0,0
    80002bfe:	60e2                	ld	ra,24(sp)
    80002c00:	6442                	ld	s0,16(sp)
    80002c02:	64a2                	ld	s1,8(sp)
    80002c04:	6105                	addi	sp,sp,32
    80002c06:	8082                	ret

0000000080002c08 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002c08:	1101                	addi	sp,sp,-32
    80002c0a:	ec06                	sd	ra,24(sp)
    80002c0c:	e822                	sd	s0,16(sp)
    80002c0e:	e426                	sd	s1,8(sp)
    80002c10:	1000                	addi	s0,sp,32
    80002c12:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c14:	00000097          	auipc	ra,0x0
    80002c18:	eca080e7          	jalr	-310(ra) # 80002ade <argraw>
    80002c1c:	e088                	sd	a0,0(s1)
  return 0;
}
    80002c1e:	4501                	li	a0,0
    80002c20:	60e2                	ld	ra,24(sp)
    80002c22:	6442                	ld	s0,16(sp)
    80002c24:	64a2                	ld	s1,8(sp)
    80002c26:	6105                	addi	sp,sp,32
    80002c28:	8082                	ret

0000000080002c2a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c2a:	1101                	addi	sp,sp,-32
    80002c2c:	ec06                	sd	ra,24(sp)
    80002c2e:	e822                	sd	s0,16(sp)
    80002c30:	e426                	sd	s1,8(sp)
    80002c32:	e04a                	sd	s2,0(sp)
    80002c34:	1000                	addi	s0,sp,32
    80002c36:	84ae                	mv	s1,a1
    80002c38:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002c3a:	00000097          	auipc	ra,0x0
    80002c3e:	ea4080e7          	jalr	-348(ra) # 80002ade <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c42:	864a                	mv	a2,s2
    80002c44:	85a6                	mv	a1,s1
    80002c46:	00000097          	auipc	ra,0x0
    80002c4a:	f58080e7          	jalr	-168(ra) # 80002b9e <fetchstr>
}
    80002c4e:	60e2                	ld	ra,24(sp)
    80002c50:	6442                	ld	s0,16(sp)
    80002c52:	64a2                	ld	s1,8(sp)
    80002c54:	6902                	ld	s2,0(sp)
    80002c56:	6105                	addi	sp,sp,32
    80002c58:	8082                	ret

0000000080002c5a <syscall>:
  }
}
*/
void
syscall(void)
{
    80002c5a:	7179                	addi	sp,sp,-48
    80002c5c:	f406                	sd	ra,40(sp)
    80002c5e:	f022                	sd	s0,32(sp)
    80002c60:	ec26                	sd	s1,24(sp)
    80002c62:	e84a                	sd	s2,16(sp)
    80002c64:	e44e                	sd	s3,8(sp)
    80002c66:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002c68:	fffff097          	auipc	ra,0xfffff
    80002c6c:	e52080e7          	jalr	-430(ra) # 80001aba <myproc>
    80002c70:	84aa                	mv	s1,a0

  num = p->trapframe->a7; // 系统调用代号存在a7寄存器内
    80002c72:	05853983          	ld	s3,88(a0)
    80002c76:	0a89b783          	ld	a5,168(s3)
    80002c7a:	0007891b          	sext.w	s2,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c7e:	37fd                	addiw	a5,a5,-1
    80002c80:	4759                	li	a4,22
    80002c82:	04f76963          	bltu	a4,a5,80002cd4 <syscall+0x7a>
    80002c86:	00391713          	slli	a4,s2,0x3
    80002c8a:	00005797          	auipc	a5,0x5
    80002c8e:	77678793          	addi	a5,a5,1910 # 80008400 <syscalls>
    80002c92:	97ba                	add	a5,a5,a4
    80002c94:	639c                	ld	a5,0(a5)
    80002c96:	cf9d                	beqz	a5,80002cd4 <syscall+0x7a>
    p->trapframe->a0 = syscalls[num](); // 返回值存在a0寄存器内
    80002c98:	9782                	jalr	a5
    80002c9a:	06a9b823          	sd	a0,112(s3)
    if (p->tracemask & (1 << num)) { // << 判断是否需要trace这个系统调用
    80002c9e:	4785                	li	a5,1
    80002ca0:	012797bb          	sllw	a5,a5,s2
    80002ca4:	1684b703          	ld	a4,360(s1)
    80002ca8:	8ff9                	and	a5,a5,a4
    80002caa:	c7a1                	beqz	a5,80002cf2 <syscall+0x98>
      // this process traces this sys call num
      printf("%d: syscall %s -> %d\n", p->pid, sysnames[num], p->trapframe->a0);
    80002cac:	6cb8                	ld	a4,88(s1)
    80002cae:	090e                	slli	s2,s2,0x3
    80002cb0:	00005797          	auipc	a5,0x5
    80002cb4:	75078793          	addi	a5,a5,1872 # 80008400 <syscalls>
    80002cb8:	993e                	add	s2,s2,a5
    80002cba:	7b34                	ld	a3,112(a4)
    80002cbc:	0c093603          	ld	a2,192(s2)
    80002cc0:	5c8c                	lw	a1,56(s1)
    80002cc2:	00006517          	auipc	a0,0x6
    80002cc6:	8c650513          	addi	a0,a0,-1850 # 80008588 <sysnames+0xc8>
    80002cca:	ffffe097          	auipc	ra,0xffffe
    80002cce:	8f4080e7          	jalr	-1804(ra) # 800005be <printf>
    80002cd2:	a005                	j	80002cf2 <syscall+0x98>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002cd4:	86ca                	mv	a3,s2
    80002cd6:	15848613          	addi	a2,s1,344
    80002cda:	5c8c                	lw	a1,56(s1)
    80002cdc:	00006517          	auipc	a0,0x6
    80002ce0:	8c450513          	addi	a0,a0,-1852 # 800085a0 <sysnames+0xe0>
    80002ce4:	ffffe097          	auipc	ra,0xffffe
    80002ce8:	8da080e7          	jalr	-1830(ra) # 800005be <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002cec:	6cbc                	ld	a5,88(s1)
    80002cee:	577d                	li	a4,-1
    80002cf0:	fbb8                	sd	a4,112(a5)
  }
}
    80002cf2:	70a2                	ld	ra,40(sp)
    80002cf4:	7402                	ld	s0,32(sp)
    80002cf6:	64e2                	ld	s1,24(sp)
    80002cf8:	6942                	ld	s2,16(sp)
    80002cfa:	69a2                	ld	s3,8(sp)
    80002cfc:	6145                	addi	sp,sp,48
    80002cfe:	8082                	ret

0000000080002d00 <sys_exit>:
#include "sysinfo.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d00:	1101                	addi	sp,sp,-32
    80002d02:	ec06                	sd	ra,24(sp)
    80002d04:	e822                	sd	s0,16(sp)
    80002d06:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002d08:	fec40593          	addi	a1,s0,-20
    80002d0c:	4501                	li	a0,0
    80002d0e:	00000097          	auipc	ra,0x0
    80002d12:	ed8080e7          	jalr	-296(ra) # 80002be6 <argint>
    return -1;
    80002d16:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d18:	00054963          	bltz	a0,80002d2a <sys_exit+0x2a>
  exit(n);
    80002d1c:	fec42503          	lw	a0,-20(s0)
    80002d20:	fffff097          	auipc	ra,0xfffff
    80002d24:	474080e7          	jalr	1140(ra) # 80002194 <exit>
  return 0;  // not reached
    80002d28:	4781                	li	a5,0
}
    80002d2a:	853e                	mv	a0,a5
    80002d2c:	60e2                	ld	ra,24(sp)
    80002d2e:	6442                	ld	s0,16(sp)
    80002d30:	6105                	addi	sp,sp,32
    80002d32:	8082                	ret

0000000080002d34 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d34:	1141                	addi	sp,sp,-16
    80002d36:	e406                	sd	ra,8(sp)
    80002d38:	e022                	sd	s0,0(sp)
    80002d3a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d3c:	fffff097          	auipc	ra,0xfffff
    80002d40:	d7e080e7          	jalr	-642(ra) # 80001aba <myproc>
}
    80002d44:	5d08                	lw	a0,56(a0)
    80002d46:	60a2                	ld	ra,8(sp)
    80002d48:	6402                	ld	s0,0(sp)
    80002d4a:	0141                	addi	sp,sp,16
    80002d4c:	8082                	ret

0000000080002d4e <sys_fork>:

uint64
sys_fork(void)
{
    80002d4e:	1141                	addi	sp,sp,-16
    80002d50:	e406                	sd	ra,8(sp)
    80002d52:	e022                	sd	s0,0(sp)
    80002d54:	0800                	addi	s0,sp,16
  return fork();
    80002d56:	fffff097          	auipc	ra,0xfffff
    80002d5a:	12e080e7          	jalr	302(ra) # 80001e84 <fork>
}
    80002d5e:	60a2                	ld	ra,8(sp)
    80002d60:	6402                	ld	s0,0(sp)
    80002d62:	0141                	addi	sp,sp,16
    80002d64:	8082                	ret

0000000080002d66 <sys_wait>:

uint64
sys_wait(void)
{
    80002d66:	1101                	addi	sp,sp,-32
    80002d68:	ec06                	sd	ra,24(sp)
    80002d6a:	e822                	sd	s0,16(sp)
    80002d6c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002d6e:	fe840593          	addi	a1,s0,-24
    80002d72:	4501                	li	a0,0
    80002d74:	00000097          	auipc	ra,0x0
    80002d78:	e94080e7          	jalr	-364(ra) # 80002c08 <argaddr>
    return -1;
    80002d7c:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    80002d7e:	00054963          	bltz	a0,80002d90 <sys_wait+0x2a>
  return wait(p);
    80002d82:	fe843503          	ld	a0,-24(s0)
    80002d86:	fffff097          	auipc	ra,0xfffff
    80002d8a:	5d4080e7          	jalr	1492(ra) # 8000235a <wait>
    80002d8e:	87aa                	mv	a5,a0
}
    80002d90:	853e                	mv	a0,a5
    80002d92:	60e2                	ld	ra,24(sp)
    80002d94:	6442                	ld	s0,16(sp)
    80002d96:	6105                	addi	sp,sp,32
    80002d98:	8082                	ret

0000000080002d9a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d9a:	7179                	addi	sp,sp,-48
    80002d9c:	f406                	sd	ra,40(sp)
    80002d9e:	f022                	sd	s0,32(sp)
    80002da0:	ec26                	sd	s1,24(sp)
    80002da2:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002da4:	fdc40593          	addi	a1,s0,-36
    80002da8:	4501                	li	a0,0
    80002daa:	00000097          	auipc	ra,0x0
    80002dae:	e3c080e7          	jalr	-452(ra) # 80002be6 <argint>
    return -1;
    80002db2:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002db4:	00054f63          	bltz	a0,80002dd2 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002db8:	fffff097          	auipc	ra,0xfffff
    80002dbc:	d02080e7          	jalr	-766(ra) # 80001aba <myproc>
    80002dc0:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002dc2:	fdc42503          	lw	a0,-36(s0)
    80002dc6:	fffff097          	auipc	ra,0xfffff
    80002dca:	046080e7          	jalr	70(ra) # 80001e0c <growproc>
    80002dce:	00054863          	bltz	a0,80002dde <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002dd2:	8526                	mv	a0,s1
    80002dd4:	70a2                	ld	ra,40(sp)
    80002dd6:	7402                	ld	s0,32(sp)
    80002dd8:	64e2                	ld	s1,24(sp)
    80002dda:	6145                	addi	sp,sp,48
    80002ddc:	8082                	ret
    return -1;
    80002dde:	54fd                	li	s1,-1
    80002de0:	bfcd                	j	80002dd2 <sys_sbrk+0x38>

0000000080002de2 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002de2:	7139                	addi	sp,sp,-64
    80002de4:	fc06                	sd	ra,56(sp)
    80002de6:	f822                	sd	s0,48(sp)
    80002de8:	f426                	sd	s1,40(sp)
    80002dea:	f04a                	sd	s2,32(sp)
    80002dec:	ec4e                	sd	s3,24(sp)
    80002dee:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002df0:	fcc40593          	addi	a1,s0,-52
    80002df4:	4501                	li	a0,0
    80002df6:	00000097          	auipc	ra,0x0
    80002dfa:	df0080e7          	jalr	-528(ra) # 80002be6 <argint>
    return -1;
    80002dfe:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e00:	06054763          	bltz	a0,80002e6e <sys_sleep+0x8c>
  acquire(&tickslock);
    80002e04:	00015517          	auipc	a0,0x15
    80002e08:	b6450513          	addi	a0,a0,-1180 # 80017968 <tickslock>
    80002e0c:	ffffe097          	auipc	ra,0xffffe
    80002e10:	ea0080e7          	jalr	-352(ra) # 80000cac <acquire>
  ticks0 = ticks;
    80002e14:	00006797          	auipc	a5,0x6
    80002e18:	20c78793          	addi	a5,a5,524 # 80009020 <ticks>
    80002e1c:	0007a903          	lw	s2,0(a5)
  while(ticks - ticks0 < n){
    80002e20:	fcc42783          	lw	a5,-52(s0)
    80002e24:	cf85                	beqz	a5,80002e5c <sys_sleep+0x7a>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e26:	00015997          	auipc	s3,0x15
    80002e2a:	b4298993          	addi	s3,s3,-1214 # 80017968 <tickslock>
    80002e2e:	00006497          	auipc	s1,0x6
    80002e32:	1f248493          	addi	s1,s1,498 # 80009020 <ticks>
    if(myproc()->killed){
    80002e36:	fffff097          	auipc	ra,0xfffff
    80002e3a:	c84080e7          	jalr	-892(ra) # 80001aba <myproc>
    80002e3e:	591c                	lw	a5,48(a0)
    80002e40:	ef9d                	bnez	a5,80002e7e <sys_sleep+0x9c>
    sleep(&ticks, &tickslock);
    80002e42:	85ce                	mv	a1,s3
    80002e44:	8526                	mv	a0,s1
    80002e46:	fffff097          	auipc	ra,0xfffff
    80002e4a:	496080e7          	jalr	1174(ra) # 800022dc <sleep>
  while(ticks - ticks0 < n){
    80002e4e:	409c                	lw	a5,0(s1)
    80002e50:	412787bb          	subw	a5,a5,s2
    80002e54:	fcc42703          	lw	a4,-52(s0)
    80002e58:	fce7efe3          	bltu	a5,a4,80002e36 <sys_sleep+0x54>
  }
  release(&tickslock);
    80002e5c:	00015517          	auipc	a0,0x15
    80002e60:	b0c50513          	addi	a0,a0,-1268 # 80017968 <tickslock>
    80002e64:	ffffe097          	auipc	ra,0xffffe
    80002e68:	efc080e7          	jalr	-260(ra) # 80000d60 <release>
  return 0;
    80002e6c:	4781                	li	a5,0
}
    80002e6e:	853e                	mv	a0,a5
    80002e70:	70e2                	ld	ra,56(sp)
    80002e72:	7442                	ld	s0,48(sp)
    80002e74:	74a2                	ld	s1,40(sp)
    80002e76:	7902                	ld	s2,32(sp)
    80002e78:	69e2                	ld	s3,24(sp)
    80002e7a:	6121                	addi	sp,sp,64
    80002e7c:	8082                	ret
      release(&tickslock);
    80002e7e:	00015517          	auipc	a0,0x15
    80002e82:	aea50513          	addi	a0,a0,-1302 # 80017968 <tickslock>
    80002e86:	ffffe097          	auipc	ra,0xffffe
    80002e8a:	eda080e7          	jalr	-294(ra) # 80000d60 <release>
      return -1;
    80002e8e:	57fd                	li	a5,-1
    80002e90:	bff9                	j	80002e6e <sys_sleep+0x8c>

0000000080002e92 <sys_kill>:

uint64
sys_kill(void)
{
    80002e92:	1101                	addi	sp,sp,-32
    80002e94:	ec06                	sd	ra,24(sp)
    80002e96:	e822                	sd	s0,16(sp)
    80002e98:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002e9a:	fec40593          	addi	a1,s0,-20
    80002e9e:	4501                	li	a0,0
    80002ea0:	00000097          	auipc	ra,0x0
    80002ea4:	d46080e7          	jalr	-698(ra) # 80002be6 <argint>
    return -1;
    80002ea8:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    80002eaa:	00054963          	bltz	a0,80002ebc <sys_kill+0x2a>
  return kill(pid);
    80002eae:	fec42503          	lw	a0,-20(s0)
    80002eb2:	fffff097          	auipc	ra,0xfffff
    80002eb6:	61a080e7          	jalr	1562(ra) # 800024cc <kill>
    80002eba:	87aa                	mv	a5,a0
}
    80002ebc:	853e                	mv	a0,a5
    80002ebe:	60e2                	ld	ra,24(sp)
    80002ec0:	6442                	ld	s0,16(sp)
    80002ec2:	6105                	addi	sp,sp,32
    80002ec4:	8082                	ret

0000000080002ec6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ec6:	1101                	addi	sp,sp,-32
    80002ec8:	ec06                	sd	ra,24(sp)
    80002eca:	e822                	sd	s0,16(sp)
    80002ecc:	e426                	sd	s1,8(sp)
    80002ece:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ed0:	00015517          	auipc	a0,0x15
    80002ed4:	a9850513          	addi	a0,a0,-1384 # 80017968 <tickslock>
    80002ed8:	ffffe097          	auipc	ra,0xffffe
    80002edc:	dd4080e7          	jalr	-556(ra) # 80000cac <acquire>
  xticks = ticks;
    80002ee0:	00006797          	auipc	a5,0x6
    80002ee4:	14078793          	addi	a5,a5,320 # 80009020 <ticks>
    80002ee8:	4384                	lw	s1,0(a5)
  release(&tickslock);
    80002eea:	00015517          	auipc	a0,0x15
    80002eee:	a7e50513          	addi	a0,a0,-1410 # 80017968 <tickslock>
    80002ef2:	ffffe097          	auipc	ra,0xffffe
    80002ef6:	e6e080e7          	jalr	-402(ra) # 80000d60 <release>
  return xticks;
}
    80002efa:	02049513          	slli	a0,s1,0x20
    80002efe:	9101                	srli	a0,a0,0x20
    80002f00:	60e2                	ld	ra,24(sp)
    80002f02:	6442                	ld	s0,16(sp)
    80002f04:	64a2                	ld	s1,8(sp)
    80002f06:	6105                	addi	sp,sp,32
    80002f08:	8082                	ret

0000000080002f0a <sys_trace>:

uint64 
sys_trace(void) {
    80002f0a:	1101                	addi	sp,sp,-32
    80002f0c:	ec06                	sd	ra,24(sp)
    80002f0e:	e822                	sd	s0,16(sp)
    80002f10:	1000                	addi	s0,sp,32
  int trace_sys_mask;
  if (argint(0, &trace_sys_mask) < 0)
    80002f12:	fec40593          	addi	a1,s0,-20
    80002f16:	4501                	li	a0,0
    80002f18:	00000097          	auipc	ra,0x0
    80002f1c:	cce080e7          	jalr	-818(ra) # 80002be6 <argint>
    return -1;
    80002f20:	57fd                	li	a5,-1
  if (argint(0, &trace_sys_mask) < 0)
    80002f22:	00054e63          	bltz	a0,80002f3e <sys_trace+0x34>
  myproc()->tracemask |= trace_sys_mask;
    80002f26:	fffff097          	auipc	ra,0xfffff
    80002f2a:	b94080e7          	jalr	-1132(ra) # 80001aba <myproc>
    80002f2e:	fec42703          	lw	a4,-20(s0)
    80002f32:	16853783          	ld	a5,360(a0)
    80002f36:	8fd9                	or	a5,a5,a4
    80002f38:	16f53423          	sd	a5,360(a0)
  return 0;
    80002f3c:	4781                	li	a5,0
}
    80002f3e:	853e                	mv	a0,a5
    80002f40:	60e2                	ld	ra,24(sp)
    80002f42:	6442                	ld	s0,16(sp)
    80002f44:	6105                	addi	sp,sp,32
    80002f46:	8082                	ret

0000000080002f48 <sys_sysinfo>:

// collect system info
uint64
sys_sysinfo(void) {
    80002f48:	7139                	addi	sp,sp,-64
    80002f4a:	fc06                	sd	ra,56(sp)
    80002f4c:	f822                	sd	s0,48(sp)
    80002f4e:	f426                	sd	s1,40(sp)
    80002f50:	0080                	addi	s0,sp,64
  struct proc *my_proc = myproc();
    80002f52:	fffff097          	auipc	ra,0xfffff
    80002f56:	b68080e7          	jalr	-1176(ra) # 80001aba <myproc>
    80002f5a:	84aa                	mv	s1,a0
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002f5c:	fd840593          	addi	a1,s0,-40
    80002f60:	4501                	li	a0,0
    80002f62:	00000097          	auipc	ra,0x0
    80002f66:	ca6080e7          	jalr	-858(ra) # 80002c08 <argaddr>
    return -1;
    80002f6a:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    80002f6c:	02054a63          	bltz	a0,80002fa0 <sys_sysinfo+0x58>
  // construct in kernel first
  struct sysinfo s;
  s.freemem = kfreemem();
    80002f70:	ffffe097          	auipc	ra,0xffffe
    80002f74:	c62080e7          	jalr	-926(ra) # 80000bd2 <kfreemem>
    80002f78:	fca43423          	sd	a0,-56(s0)
  s.nproc = count_free_proc();
    80002f7c:	fffff097          	auipc	ra,0xfffff
    80002f80:	71e080e7          	jalr	1822(ra) # 8000269a <count_free_proc>
    80002f84:	fca43823          	sd	a0,-48(s0)
  // copy to user space
  if(copyout(my_proc->pagetable, p, (char *)&s, sizeof(s)) < 0)
    80002f88:	46c1                	li	a3,16
    80002f8a:	fc840613          	addi	a2,s0,-56
    80002f8e:	fd843583          	ld	a1,-40(s0)
    80002f92:	68a8                	ld	a0,80(s1)
    80002f94:	fffff097          	auipc	ra,0xfffff
    80002f98:	802080e7          	jalr	-2046(ra) # 80001796 <copyout>
    80002f9c:	43f55793          	srai	a5,a0,0x3f
    return -1;
  return 0;
}
    80002fa0:	853e                	mv	a0,a5
    80002fa2:	70e2                	ld	ra,56(sp)
    80002fa4:	7442                	ld	s0,48(sp)
    80002fa6:	74a2                	ld	s1,40(sp)
    80002fa8:	6121                	addi	sp,sp,64
    80002faa:	8082                	ret

0000000080002fac <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002fac:	7179                	addi	sp,sp,-48
    80002fae:	f406                	sd	ra,40(sp)
    80002fb0:	f022                	sd	s0,32(sp)
    80002fb2:	ec26                	sd	s1,24(sp)
    80002fb4:	e84a                	sd	s2,16(sp)
    80002fb6:	e44e                	sd	s3,8(sp)
    80002fb8:	e052                	sd	s4,0(sp)
    80002fba:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002fbc:	00005597          	auipc	a1,0x5
    80002fc0:	6b458593          	addi	a1,a1,1716 # 80008670 <sysnames+0x1b0>
    80002fc4:	00015517          	auipc	a0,0x15
    80002fc8:	9bc50513          	addi	a0,a0,-1604 # 80017980 <bcache>
    80002fcc:	ffffe097          	auipc	ra,0xffffe
    80002fd0:	c50080e7          	jalr	-944(ra) # 80000c1c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002fd4:	0001d797          	auipc	a5,0x1d
    80002fd8:	9ac78793          	addi	a5,a5,-1620 # 8001f980 <bcache+0x8000>
    80002fdc:	0001d717          	auipc	a4,0x1d
    80002fe0:	c0c70713          	addi	a4,a4,-1012 # 8001fbe8 <bcache+0x8268>
    80002fe4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002fe8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fec:	00015497          	auipc	s1,0x15
    80002ff0:	9ac48493          	addi	s1,s1,-1620 # 80017998 <bcache+0x18>
    b->next = bcache.head.next;
    80002ff4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ff6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ff8:	00005a17          	auipc	s4,0x5
    80002ffc:	680a0a13          	addi	s4,s4,1664 # 80008678 <sysnames+0x1b8>
    b->next = bcache.head.next;
    80003000:	2b893783          	ld	a5,696(s2)
    80003004:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003006:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000300a:	85d2                	mv	a1,s4
    8000300c:	01048513          	addi	a0,s1,16
    80003010:	00001097          	auipc	ra,0x1
    80003014:	51a080e7          	jalr	1306(ra) # 8000452a <initsleeplock>
    bcache.head.next->prev = b;
    80003018:	2b893783          	ld	a5,696(s2)
    8000301c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000301e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003022:	45848493          	addi	s1,s1,1112
    80003026:	fd349de3          	bne	s1,s3,80003000 <binit+0x54>
  }
}
    8000302a:	70a2                	ld	ra,40(sp)
    8000302c:	7402                	ld	s0,32(sp)
    8000302e:	64e2                	ld	s1,24(sp)
    80003030:	6942                	ld	s2,16(sp)
    80003032:	69a2                	ld	s3,8(sp)
    80003034:	6a02                	ld	s4,0(sp)
    80003036:	6145                	addi	sp,sp,48
    80003038:	8082                	ret

000000008000303a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000303a:	7179                	addi	sp,sp,-48
    8000303c:	f406                	sd	ra,40(sp)
    8000303e:	f022                	sd	s0,32(sp)
    80003040:	ec26                	sd	s1,24(sp)
    80003042:	e84a                	sd	s2,16(sp)
    80003044:	e44e                	sd	s3,8(sp)
    80003046:	1800                	addi	s0,sp,48
    80003048:	89aa                	mv	s3,a0
    8000304a:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000304c:	00015517          	auipc	a0,0x15
    80003050:	93450513          	addi	a0,a0,-1740 # 80017980 <bcache>
    80003054:	ffffe097          	auipc	ra,0xffffe
    80003058:	c58080e7          	jalr	-936(ra) # 80000cac <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000305c:	0001d797          	auipc	a5,0x1d
    80003060:	92478793          	addi	a5,a5,-1756 # 8001f980 <bcache+0x8000>
    80003064:	2b87b483          	ld	s1,696(a5)
    80003068:	0001d797          	auipc	a5,0x1d
    8000306c:	b8078793          	addi	a5,a5,-1152 # 8001fbe8 <bcache+0x8268>
    80003070:	02f48f63          	beq	s1,a5,800030ae <bread+0x74>
    80003074:	873e                	mv	a4,a5
    80003076:	a021                	j	8000307e <bread+0x44>
    80003078:	68a4                	ld	s1,80(s1)
    8000307a:	02e48a63          	beq	s1,a4,800030ae <bread+0x74>
    if(b->dev == dev && b->blockno == blockno){
    8000307e:	449c                	lw	a5,8(s1)
    80003080:	ff379ce3          	bne	a5,s3,80003078 <bread+0x3e>
    80003084:	44dc                	lw	a5,12(s1)
    80003086:	ff2799e3          	bne	a5,s2,80003078 <bread+0x3e>
      b->refcnt++;
    8000308a:	40bc                	lw	a5,64(s1)
    8000308c:	2785                	addiw	a5,a5,1
    8000308e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003090:	00015517          	auipc	a0,0x15
    80003094:	8f050513          	addi	a0,a0,-1808 # 80017980 <bcache>
    80003098:	ffffe097          	auipc	ra,0xffffe
    8000309c:	cc8080e7          	jalr	-824(ra) # 80000d60 <release>
      acquiresleep(&b->lock);
    800030a0:	01048513          	addi	a0,s1,16
    800030a4:	00001097          	auipc	ra,0x1
    800030a8:	4c0080e7          	jalr	1216(ra) # 80004564 <acquiresleep>
      return b;
    800030ac:	a8b1                	j	80003108 <bread+0xce>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030ae:	0001d797          	auipc	a5,0x1d
    800030b2:	8d278793          	addi	a5,a5,-1838 # 8001f980 <bcache+0x8000>
    800030b6:	2b07b483          	ld	s1,688(a5)
    800030ba:	0001d797          	auipc	a5,0x1d
    800030be:	b2e78793          	addi	a5,a5,-1234 # 8001fbe8 <bcache+0x8268>
    800030c2:	04f48d63          	beq	s1,a5,8000311c <bread+0xe2>
    if(b->refcnt == 0) {
    800030c6:	40bc                	lw	a5,64(s1)
    800030c8:	cb91                	beqz	a5,800030dc <bread+0xa2>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030ca:	0001d717          	auipc	a4,0x1d
    800030ce:	b1e70713          	addi	a4,a4,-1250 # 8001fbe8 <bcache+0x8268>
    800030d2:	64a4                	ld	s1,72(s1)
    800030d4:	04e48463          	beq	s1,a4,8000311c <bread+0xe2>
    if(b->refcnt == 0) {
    800030d8:	40bc                	lw	a5,64(s1)
    800030da:	ffe5                	bnez	a5,800030d2 <bread+0x98>
      b->dev = dev;
    800030dc:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800030e0:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800030e4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800030e8:	4785                	li	a5,1
    800030ea:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030ec:	00015517          	auipc	a0,0x15
    800030f0:	89450513          	addi	a0,a0,-1900 # 80017980 <bcache>
    800030f4:	ffffe097          	auipc	ra,0xffffe
    800030f8:	c6c080e7          	jalr	-916(ra) # 80000d60 <release>
      acquiresleep(&b->lock);
    800030fc:	01048513          	addi	a0,s1,16
    80003100:	00001097          	auipc	ra,0x1
    80003104:	464080e7          	jalr	1124(ra) # 80004564 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003108:	409c                	lw	a5,0(s1)
    8000310a:	c38d                	beqz	a5,8000312c <bread+0xf2>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000310c:	8526                	mv	a0,s1
    8000310e:	70a2                	ld	ra,40(sp)
    80003110:	7402                	ld	s0,32(sp)
    80003112:	64e2                	ld	s1,24(sp)
    80003114:	6942                	ld	s2,16(sp)
    80003116:	69a2                	ld	s3,8(sp)
    80003118:	6145                	addi	sp,sp,48
    8000311a:	8082                	ret
  panic("bget: no buffers");
    8000311c:	00005517          	auipc	a0,0x5
    80003120:	56450513          	addi	a0,a0,1380 # 80008680 <sysnames+0x1c0>
    80003124:	ffffd097          	auipc	ra,0xffffd
    80003128:	450080e7          	jalr	1104(ra) # 80000574 <panic>
    virtio_disk_rw(b, 0);
    8000312c:	4581                	li	a1,0
    8000312e:	8526                	mv	a0,s1
    80003130:	00003097          	auipc	ra,0x3
    80003134:	fee080e7          	jalr	-18(ra) # 8000611e <virtio_disk_rw>
    b->valid = 1;
    80003138:	4785                	li	a5,1
    8000313a:	c09c                	sw	a5,0(s1)
  return b;
    8000313c:	bfc1                	j	8000310c <bread+0xd2>

000000008000313e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000313e:	1101                	addi	sp,sp,-32
    80003140:	ec06                	sd	ra,24(sp)
    80003142:	e822                	sd	s0,16(sp)
    80003144:	e426                	sd	s1,8(sp)
    80003146:	1000                	addi	s0,sp,32
    80003148:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000314a:	0541                	addi	a0,a0,16
    8000314c:	00001097          	auipc	ra,0x1
    80003150:	4b2080e7          	jalr	1202(ra) # 800045fe <holdingsleep>
    80003154:	cd01                	beqz	a0,8000316c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003156:	4585                	li	a1,1
    80003158:	8526                	mv	a0,s1
    8000315a:	00003097          	auipc	ra,0x3
    8000315e:	fc4080e7          	jalr	-60(ra) # 8000611e <virtio_disk_rw>
}
    80003162:	60e2                	ld	ra,24(sp)
    80003164:	6442                	ld	s0,16(sp)
    80003166:	64a2                	ld	s1,8(sp)
    80003168:	6105                	addi	sp,sp,32
    8000316a:	8082                	ret
    panic("bwrite");
    8000316c:	00005517          	auipc	a0,0x5
    80003170:	52c50513          	addi	a0,a0,1324 # 80008698 <sysnames+0x1d8>
    80003174:	ffffd097          	auipc	ra,0xffffd
    80003178:	400080e7          	jalr	1024(ra) # 80000574 <panic>

000000008000317c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000317c:	1101                	addi	sp,sp,-32
    8000317e:	ec06                	sd	ra,24(sp)
    80003180:	e822                	sd	s0,16(sp)
    80003182:	e426                	sd	s1,8(sp)
    80003184:	e04a                	sd	s2,0(sp)
    80003186:	1000                	addi	s0,sp,32
    80003188:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000318a:	01050913          	addi	s2,a0,16
    8000318e:	854a                	mv	a0,s2
    80003190:	00001097          	auipc	ra,0x1
    80003194:	46e080e7          	jalr	1134(ra) # 800045fe <holdingsleep>
    80003198:	c92d                	beqz	a0,8000320a <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000319a:	854a                	mv	a0,s2
    8000319c:	00001097          	auipc	ra,0x1
    800031a0:	41e080e7          	jalr	1054(ra) # 800045ba <releasesleep>

  acquire(&bcache.lock);
    800031a4:	00014517          	auipc	a0,0x14
    800031a8:	7dc50513          	addi	a0,a0,2012 # 80017980 <bcache>
    800031ac:	ffffe097          	auipc	ra,0xffffe
    800031b0:	b00080e7          	jalr	-1280(ra) # 80000cac <acquire>
  b->refcnt--;
    800031b4:	40bc                	lw	a5,64(s1)
    800031b6:	37fd                	addiw	a5,a5,-1
    800031b8:	0007871b          	sext.w	a4,a5
    800031bc:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031be:	eb05                	bnez	a4,800031ee <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031c0:	68bc                	ld	a5,80(s1)
    800031c2:	64b8                	ld	a4,72(s1)
    800031c4:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800031c6:	64bc                	ld	a5,72(s1)
    800031c8:	68b8                	ld	a4,80(s1)
    800031ca:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800031cc:	0001c797          	auipc	a5,0x1c
    800031d0:	7b478793          	addi	a5,a5,1972 # 8001f980 <bcache+0x8000>
    800031d4:	2b87b703          	ld	a4,696(a5)
    800031d8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800031da:	0001d717          	auipc	a4,0x1d
    800031de:	a0e70713          	addi	a4,a4,-1522 # 8001fbe8 <bcache+0x8268>
    800031e2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800031e4:	2b87b703          	ld	a4,696(a5)
    800031e8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800031ea:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800031ee:	00014517          	auipc	a0,0x14
    800031f2:	79250513          	addi	a0,a0,1938 # 80017980 <bcache>
    800031f6:	ffffe097          	auipc	ra,0xffffe
    800031fa:	b6a080e7          	jalr	-1174(ra) # 80000d60 <release>
}
    800031fe:	60e2                	ld	ra,24(sp)
    80003200:	6442                	ld	s0,16(sp)
    80003202:	64a2                	ld	s1,8(sp)
    80003204:	6902                	ld	s2,0(sp)
    80003206:	6105                	addi	sp,sp,32
    80003208:	8082                	ret
    panic("brelse");
    8000320a:	00005517          	auipc	a0,0x5
    8000320e:	49650513          	addi	a0,a0,1174 # 800086a0 <sysnames+0x1e0>
    80003212:	ffffd097          	auipc	ra,0xffffd
    80003216:	362080e7          	jalr	866(ra) # 80000574 <panic>

000000008000321a <bpin>:

void
bpin(struct buf *b) {
    8000321a:	1101                	addi	sp,sp,-32
    8000321c:	ec06                	sd	ra,24(sp)
    8000321e:	e822                	sd	s0,16(sp)
    80003220:	e426                	sd	s1,8(sp)
    80003222:	1000                	addi	s0,sp,32
    80003224:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003226:	00014517          	auipc	a0,0x14
    8000322a:	75a50513          	addi	a0,a0,1882 # 80017980 <bcache>
    8000322e:	ffffe097          	auipc	ra,0xffffe
    80003232:	a7e080e7          	jalr	-1410(ra) # 80000cac <acquire>
  b->refcnt++;
    80003236:	40bc                	lw	a5,64(s1)
    80003238:	2785                	addiw	a5,a5,1
    8000323a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000323c:	00014517          	auipc	a0,0x14
    80003240:	74450513          	addi	a0,a0,1860 # 80017980 <bcache>
    80003244:	ffffe097          	auipc	ra,0xffffe
    80003248:	b1c080e7          	jalr	-1252(ra) # 80000d60 <release>
}
    8000324c:	60e2                	ld	ra,24(sp)
    8000324e:	6442                	ld	s0,16(sp)
    80003250:	64a2                	ld	s1,8(sp)
    80003252:	6105                	addi	sp,sp,32
    80003254:	8082                	ret

0000000080003256 <bunpin>:

void
bunpin(struct buf *b) {
    80003256:	1101                	addi	sp,sp,-32
    80003258:	ec06                	sd	ra,24(sp)
    8000325a:	e822                	sd	s0,16(sp)
    8000325c:	e426                	sd	s1,8(sp)
    8000325e:	1000                	addi	s0,sp,32
    80003260:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003262:	00014517          	auipc	a0,0x14
    80003266:	71e50513          	addi	a0,a0,1822 # 80017980 <bcache>
    8000326a:	ffffe097          	auipc	ra,0xffffe
    8000326e:	a42080e7          	jalr	-1470(ra) # 80000cac <acquire>
  b->refcnt--;
    80003272:	40bc                	lw	a5,64(s1)
    80003274:	37fd                	addiw	a5,a5,-1
    80003276:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003278:	00014517          	auipc	a0,0x14
    8000327c:	70850513          	addi	a0,a0,1800 # 80017980 <bcache>
    80003280:	ffffe097          	auipc	ra,0xffffe
    80003284:	ae0080e7          	jalr	-1312(ra) # 80000d60 <release>
}
    80003288:	60e2                	ld	ra,24(sp)
    8000328a:	6442                	ld	s0,16(sp)
    8000328c:	64a2                	ld	s1,8(sp)
    8000328e:	6105                	addi	sp,sp,32
    80003290:	8082                	ret

0000000080003292 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003292:	1101                	addi	sp,sp,-32
    80003294:	ec06                	sd	ra,24(sp)
    80003296:	e822                	sd	s0,16(sp)
    80003298:	e426                	sd	s1,8(sp)
    8000329a:	e04a                	sd	s2,0(sp)
    8000329c:	1000                	addi	s0,sp,32
    8000329e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032a0:	00d5d59b          	srliw	a1,a1,0xd
    800032a4:	0001d797          	auipc	a5,0x1d
    800032a8:	d9c78793          	addi	a5,a5,-612 # 80020040 <sb>
    800032ac:	4fdc                	lw	a5,28(a5)
    800032ae:	9dbd                	addw	a1,a1,a5
    800032b0:	00000097          	auipc	ra,0x0
    800032b4:	d8a080e7          	jalr	-630(ra) # 8000303a <bread>
  bi = b % BPB;
    800032b8:	2481                	sext.w	s1,s1
  m = 1 << (bi % 8);
    800032ba:	0074f793          	andi	a5,s1,7
    800032be:	4705                	li	a4,1
    800032c0:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    800032c4:	6789                	lui	a5,0x2
    800032c6:	17fd                	addi	a5,a5,-1
    800032c8:	8cfd                	and	s1,s1,a5
  if((bp->data[bi/8] & m) == 0)
    800032ca:	41f4d79b          	sraiw	a5,s1,0x1f
    800032ce:	01d7d79b          	srliw	a5,a5,0x1d
    800032d2:	9fa5                	addw	a5,a5,s1
    800032d4:	4037d79b          	sraiw	a5,a5,0x3
    800032d8:	00f506b3          	add	a3,a0,a5
    800032dc:	0586c683          	lbu	a3,88(a3)
    800032e0:	00d77633          	and	a2,a4,a3
    800032e4:	c61d                	beqz	a2,80003312 <bfree+0x80>
    800032e6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800032e8:	97aa                	add	a5,a5,a0
    800032ea:	fff74713          	not	a4,a4
    800032ee:	8f75                	and	a4,a4,a3
    800032f0:	04e78c23          	sb	a4,88(a5) # 2058 <_entry-0x7fffdfa8>
  log_write(bp);
    800032f4:	00001097          	auipc	ra,0x1
    800032f8:	132080e7          	jalr	306(ra) # 80004426 <log_write>
  brelse(bp);
    800032fc:	854a                	mv	a0,s2
    800032fe:	00000097          	auipc	ra,0x0
    80003302:	e7e080e7          	jalr	-386(ra) # 8000317c <brelse>
}
    80003306:	60e2                	ld	ra,24(sp)
    80003308:	6442                	ld	s0,16(sp)
    8000330a:	64a2                	ld	s1,8(sp)
    8000330c:	6902                	ld	s2,0(sp)
    8000330e:	6105                	addi	sp,sp,32
    80003310:	8082                	ret
    panic("freeing free block");
    80003312:	00005517          	auipc	a0,0x5
    80003316:	39650513          	addi	a0,a0,918 # 800086a8 <sysnames+0x1e8>
    8000331a:	ffffd097          	auipc	ra,0xffffd
    8000331e:	25a080e7          	jalr	602(ra) # 80000574 <panic>

0000000080003322 <balloc>:
{
    80003322:	711d                	addi	sp,sp,-96
    80003324:	ec86                	sd	ra,88(sp)
    80003326:	e8a2                	sd	s0,80(sp)
    80003328:	e4a6                	sd	s1,72(sp)
    8000332a:	e0ca                	sd	s2,64(sp)
    8000332c:	fc4e                	sd	s3,56(sp)
    8000332e:	f852                	sd	s4,48(sp)
    80003330:	f456                	sd	s5,40(sp)
    80003332:	f05a                	sd	s6,32(sp)
    80003334:	ec5e                	sd	s7,24(sp)
    80003336:	e862                	sd	s8,16(sp)
    80003338:	e466                	sd	s9,8(sp)
    8000333a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000333c:	0001d797          	auipc	a5,0x1d
    80003340:	d0478793          	addi	a5,a5,-764 # 80020040 <sb>
    80003344:	43dc                	lw	a5,4(a5)
    80003346:	10078e63          	beqz	a5,80003462 <balloc+0x140>
    8000334a:	8baa                	mv	s7,a0
    8000334c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000334e:	0001db17          	auipc	s6,0x1d
    80003352:	cf2b0b13          	addi	s6,s6,-782 # 80020040 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003356:	4c05                	li	s8,1
      m = 1 << (bi % 8);
    80003358:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000335a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000335c:	6c89                	lui	s9,0x2
    8000335e:	a079                	j	800033ec <balloc+0xca>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003360:	8942                	mv	s2,a6
      m = 1 << (bi % 8);
    80003362:	4705                	li	a4,1
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003364:	4681                	li	a3,0
        bp->data[bi/8] |= m;  // Mark block in use.
    80003366:	96a6                	add	a3,a3,s1
    80003368:	8f51                	or	a4,a4,a2
    8000336a:	04e68c23          	sb	a4,88(a3)
        log_write(bp);
    8000336e:	8526                	mv	a0,s1
    80003370:	00001097          	auipc	ra,0x1
    80003374:	0b6080e7          	jalr	182(ra) # 80004426 <log_write>
        brelse(bp);
    80003378:	8526                	mv	a0,s1
    8000337a:	00000097          	auipc	ra,0x0
    8000337e:	e02080e7          	jalr	-510(ra) # 8000317c <brelse>
  bp = bread(dev, bno);
    80003382:	85ca                	mv	a1,s2
    80003384:	855e                	mv	a0,s7
    80003386:	00000097          	auipc	ra,0x0
    8000338a:	cb4080e7          	jalr	-844(ra) # 8000303a <bread>
    8000338e:	84aa                	mv	s1,a0
  memset(bp->data, 0, BSIZE);
    80003390:	40000613          	li	a2,1024
    80003394:	4581                	li	a1,0
    80003396:	05850513          	addi	a0,a0,88
    8000339a:	ffffe097          	auipc	ra,0xffffe
    8000339e:	a0e080e7          	jalr	-1522(ra) # 80000da8 <memset>
  log_write(bp);
    800033a2:	8526                	mv	a0,s1
    800033a4:	00001097          	auipc	ra,0x1
    800033a8:	082080e7          	jalr	130(ra) # 80004426 <log_write>
  brelse(bp);
    800033ac:	8526                	mv	a0,s1
    800033ae:	00000097          	auipc	ra,0x0
    800033b2:	dce080e7          	jalr	-562(ra) # 8000317c <brelse>
}
    800033b6:	854a                	mv	a0,s2
    800033b8:	60e6                	ld	ra,88(sp)
    800033ba:	6446                	ld	s0,80(sp)
    800033bc:	64a6                	ld	s1,72(sp)
    800033be:	6906                	ld	s2,64(sp)
    800033c0:	79e2                	ld	s3,56(sp)
    800033c2:	7a42                	ld	s4,48(sp)
    800033c4:	7aa2                	ld	s5,40(sp)
    800033c6:	7b02                	ld	s6,32(sp)
    800033c8:	6be2                	ld	s7,24(sp)
    800033ca:	6c42                	ld	s8,16(sp)
    800033cc:	6ca2                	ld	s9,8(sp)
    800033ce:	6125                	addi	sp,sp,96
    800033d0:	8082                	ret
    brelse(bp);
    800033d2:	8526                	mv	a0,s1
    800033d4:	00000097          	auipc	ra,0x0
    800033d8:	da8080e7          	jalr	-600(ra) # 8000317c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033dc:	015c87bb          	addw	a5,s9,s5
    800033e0:	00078a9b          	sext.w	s5,a5
    800033e4:	004b2703          	lw	a4,4(s6)
    800033e8:	06eafd63          	bleu	a4,s5,80003462 <balloc+0x140>
    bp = bread(dev, BBLOCK(b, sb));
    800033ec:	41fad79b          	sraiw	a5,s5,0x1f
    800033f0:	0137d79b          	srliw	a5,a5,0x13
    800033f4:	015787bb          	addw	a5,a5,s5
    800033f8:	40d7d79b          	sraiw	a5,a5,0xd
    800033fc:	01cb2583          	lw	a1,28(s6)
    80003400:	9dbd                	addw	a1,a1,a5
    80003402:	855e                	mv	a0,s7
    80003404:	00000097          	auipc	ra,0x0
    80003408:	c36080e7          	jalr	-970(ra) # 8000303a <bread>
    8000340c:	84aa                	mv	s1,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000340e:	000a881b          	sext.w	a6,s5
    80003412:	004b2503          	lw	a0,4(s6)
    80003416:	faa87ee3          	bleu	a0,a6,800033d2 <balloc+0xb0>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000341a:	0584c603          	lbu	a2,88(s1)
    8000341e:	00167793          	andi	a5,a2,1
    80003422:	df9d                	beqz	a5,80003360 <balloc+0x3e>
    80003424:	4105053b          	subw	a0,a0,a6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003428:	87e2                	mv	a5,s8
    8000342a:	0107893b          	addw	s2,a5,a6
    8000342e:	faa782e3          	beq	a5,a0,800033d2 <balloc+0xb0>
      m = 1 << (bi % 8);
    80003432:	41f7d71b          	sraiw	a4,a5,0x1f
    80003436:	01d7561b          	srliw	a2,a4,0x1d
    8000343a:	00f606bb          	addw	a3,a2,a5
    8000343e:	0076f713          	andi	a4,a3,7
    80003442:	9f11                	subw	a4,a4,a2
    80003444:	00e9973b          	sllw	a4,s3,a4
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003448:	4036d69b          	sraiw	a3,a3,0x3
    8000344c:	00d48633          	add	a2,s1,a3
    80003450:	05864603          	lbu	a2,88(a2)
    80003454:	00c775b3          	and	a1,a4,a2
    80003458:	d599                	beqz	a1,80003366 <balloc+0x44>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000345a:	2785                	addiw	a5,a5,1
    8000345c:	fd4797e3          	bne	a5,s4,8000342a <balloc+0x108>
    80003460:	bf8d                	j	800033d2 <balloc+0xb0>
  panic("balloc: out of blocks");
    80003462:	00005517          	auipc	a0,0x5
    80003466:	25e50513          	addi	a0,a0,606 # 800086c0 <sysnames+0x200>
    8000346a:	ffffd097          	auipc	ra,0xffffd
    8000346e:	10a080e7          	jalr	266(ra) # 80000574 <panic>

0000000080003472 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003472:	7179                	addi	sp,sp,-48
    80003474:	f406                	sd	ra,40(sp)
    80003476:	f022                	sd	s0,32(sp)
    80003478:	ec26                	sd	s1,24(sp)
    8000347a:	e84a                	sd	s2,16(sp)
    8000347c:	e44e                	sd	s3,8(sp)
    8000347e:	e052                	sd	s4,0(sp)
    80003480:	1800                	addi	s0,sp,48
    80003482:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003484:	47ad                	li	a5,11
    80003486:	04b7fe63          	bleu	a1,a5,800034e2 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000348a:	ff45849b          	addiw	s1,a1,-12
    8000348e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003492:	0ff00793          	li	a5,255
    80003496:	0ae7e363          	bltu	a5,a4,8000353c <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000349a:	08052583          	lw	a1,128(a0)
    8000349e:	c5ad                	beqz	a1,80003508 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800034a0:	0009a503          	lw	a0,0(s3)
    800034a4:	00000097          	auipc	ra,0x0
    800034a8:	b96080e7          	jalr	-1130(ra) # 8000303a <bread>
    800034ac:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034ae:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800034b2:	02049593          	slli	a1,s1,0x20
    800034b6:	9181                	srli	a1,a1,0x20
    800034b8:	058a                	slli	a1,a1,0x2
    800034ba:	00b784b3          	add	s1,a5,a1
    800034be:	0004a903          	lw	s2,0(s1)
    800034c2:	04090d63          	beqz	s2,8000351c <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800034c6:	8552                	mv	a0,s4
    800034c8:	00000097          	auipc	ra,0x0
    800034cc:	cb4080e7          	jalr	-844(ra) # 8000317c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800034d0:	854a                	mv	a0,s2
    800034d2:	70a2                	ld	ra,40(sp)
    800034d4:	7402                	ld	s0,32(sp)
    800034d6:	64e2                	ld	s1,24(sp)
    800034d8:	6942                	ld	s2,16(sp)
    800034da:	69a2                	ld	s3,8(sp)
    800034dc:	6a02                	ld	s4,0(sp)
    800034de:	6145                	addi	sp,sp,48
    800034e0:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800034e2:	02059493          	slli	s1,a1,0x20
    800034e6:	9081                	srli	s1,s1,0x20
    800034e8:	048a                	slli	s1,s1,0x2
    800034ea:	94aa                	add	s1,s1,a0
    800034ec:	0504a903          	lw	s2,80(s1)
    800034f0:	fe0910e3          	bnez	s2,800034d0 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800034f4:	4108                	lw	a0,0(a0)
    800034f6:	00000097          	auipc	ra,0x0
    800034fa:	e2c080e7          	jalr	-468(ra) # 80003322 <balloc>
    800034fe:	0005091b          	sext.w	s2,a0
    80003502:	0524a823          	sw	s2,80(s1)
    80003506:	b7e9                	j	800034d0 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003508:	4108                	lw	a0,0(a0)
    8000350a:	00000097          	auipc	ra,0x0
    8000350e:	e18080e7          	jalr	-488(ra) # 80003322 <balloc>
    80003512:	0005059b          	sext.w	a1,a0
    80003516:	08b9a023          	sw	a1,128(s3)
    8000351a:	b759                	j	800034a0 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000351c:	0009a503          	lw	a0,0(s3)
    80003520:	00000097          	auipc	ra,0x0
    80003524:	e02080e7          	jalr	-510(ra) # 80003322 <balloc>
    80003528:	0005091b          	sext.w	s2,a0
    8000352c:	0124a023          	sw	s2,0(s1)
      log_write(bp);
    80003530:	8552                	mv	a0,s4
    80003532:	00001097          	auipc	ra,0x1
    80003536:	ef4080e7          	jalr	-268(ra) # 80004426 <log_write>
    8000353a:	b771                	j	800034c6 <bmap+0x54>
  panic("bmap: out of range");
    8000353c:	00005517          	auipc	a0,0x5
    80003540:	19c50513          	addi	a0,a0,412 # 800086d8 <sysnames+0x218>
    80003544:	ffffd097          	auipc	ra,0xffffd
    80003548:	030080e7          	jalr	48(ra) # 80000574 <panic>

000000008000354c <iget>:
{
    8000354c:	7179                	addi	sp,sp,-48
    8000354e:	f406                	sd	ra,40(sp)
    80003550:	f022                	sd	s0,32(sp)
    80003552:	ec26                	sd	s1,24(sp)
    80003554:	e84a                	sd	s2,16(sp)
    80003556:	e44e                	sd	s3,8(sp)
    80003558:	e052                	sd	s4,0(sp)
    8000355a:	1800                	addi	s0,sp,48
    8000355c:	89aa                	mv	s3,a0
    8000355e:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003560:	0001d517          	auipc	a0,0x1d
    80003564:	b0050513          	addi	a0,a0,-1280 # 80020060 <icache>
    80003568:	ffffd097          	auipc	ra,0xffffd
    8000356c:	744080e7          	jalr	1860(ra) # 80000cac <acquire>
  empty = 0;
    80003570:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003572:	0001d497          	auipc	s1,0x1d
    80003576:	b0648493          	addi	s1,s1,-1274 # 80020078 <icache+0x18>
    8000357a:	0001e697          	auipc	a3,0x1e
    8000357e:	58e68693          	addi	a3,a3,1422 # 80021b08 <log>
    80003582:	a039                	j	80003590 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003584:	02090b63          	beqz	s2,800035ba <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003588:	08848493          	addi	s1,s1,136
    8000358c:	02d48a63          	beq	s1,a3,800035c0 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003590:	449c                	lw	a5,8(s1)
    80003592:	fef059e3          	blez	a5,80003584 <iget+0x38>
    80003596:	4098                	lw	a4,0(s1)
    80003598:	ff3716e3          	bne	a4,s3,80003584 <iget+0x38>
    8000359c:	40d8                	lw	a4,4(s1)
    8000359e:	ff4713e3          	bne	a4,s4,80003584 <iget+0x38>
      ip->ref++;
    800035a2:	2785                	addiw	a5,a5,1
    800035a4:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800035a6:	0001d517          	auipc	a0,0x1d
    800035aa:	aba50513          	addi	a0,a0,-1350 # 80020060 <icache>
    800035ae:	ffffd097          	auipc	ra,0xffffd
    800035b2:	7b2080e7          	jalr	1970(ra) # 80000d60 <release>
      return ip;
    800035b6:	8926                	mv	s2,s1
    800035b8:	a03d                	j	800035e6 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035ba:	f7f9                	bnez	a5,80003588 <iget+0x3c>
    800035bc:	8926                	mv	s2,s1
    800035be:	b7e9                	j	80003588 <iget+0x3c>
  if(empty == 0)
    800035c0:	02090c63          	beqz	s2,800035f8 <iget+0xac>
  ip->dev = dev;
    800035c4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035c8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035cc:	4785                	li	a5,1
    800035ce:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035d2:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800035d6:	0001d517          	auipc	a0,0x1d
    800035da:	a8a50513          	addi	a0,a0,-1398 # 80020060 <icache>
    800035de:	ffffd097          	auipc	ra,0xffffd
    800035e2:	782080e7          	jalr	1922(ra) # 80000d60 <release>
}
    800035e6:	854a                	mv	a0,s2
    800035e8:	70a2                	ld	ra,40(sp)
    800035ea:	7402                	ld	s0,32(sp)
    800035ec:	64e2                	ld	s1,24(sp)
    800035ee:	6942                	ld	s2,16(sp)
    800035f0:	69a2                	ld	s3,8(sp)
    800035f2:	6a02                	ld	s4,0(sp)
    800035f4:	6145                	addi	sp,sp,48
    800035f6:	8082                	ret
    panic("iget: no inodes");
    800035f8:	00005517          	auipc	a0,0x5
    800035fc:	0f850513          	addi	a0,a0,248 # 800086f0 <sysnames+0x230>
    80003600:	ffffd097          	auipc	ra,0xffffd
    80003604:	f74080e7          	jalr	-140(ra) # 80000574 <panic>

0000000080003608 <fsinit>:
fsinit(int dev) {
    80003608:	7179                	addi	sp,sp,-48
    8000360a:	f406                	sd	ra,40(sp)
    8000360c:	f022                	sd	s0,32(sp)
    8000360e:	ec26                	sd	s1,24(sp)
    80003610:	e84a                	sd	s2,16(sp)
    80003612:	e44e                	sd	s3,8(sp)
    80003614:	1800                	addi	s0,sp,48
    80003616:	89aa                	mv	s3,a0
  bp = bread(dev, 1);
    80003618:	4585                	li	a1,1
    8000361a:	00000097          	auipc	ra,0x0
    8000361e:	a20080e7          	jalr	-1504(ra) # 8000303a <bread>
    80003622:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003624:	0001d497          	auipc	s1,0x1d
    80003628:	a1c48493          	addi	s1,s1,-1508 # 80020040 <sb>
    8000362c:	02000613          	li	a2,32
    80003630:	05850593          	addi	a1,a0,88
    80003634:	8526                	mv	a0,s1
    80003636:	ffffd097          	auipc	ra,0xffffd
    8000363a:	7de080e7          	jalr	2014(ra) # 80000e14 <memmove>
  brelse(bp);
    8000363e:	854a                	mv	a0,s2
    80003640:	00000097          	auipc	ra,0x0
    80003644:	b3c080e7          	jalr	-1220(ra) # 8000317c <brelse>
  if(sb.magic != FSMAGIC)
    80003648:	4098                	lw	a4,0(s1)
    8000364a:	102037b7          	lui	a5,0x10203
    8000364e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003652:	02f71263          	bne	a4,a5,80003676 <fsinit+0x6e>
  initlog(dev, &sb);
    80003656:	0001d597          	auipc	a1,0x1d
    8000365a:	9ea58593          	addi	a1,a1,-1558 # 80020040 <sb>
    8000365e:	854e                	mv	a0,s3
    80003660:	00001097          	auipc	ra,0x1
    80003664:	b48080e7          	jalr	-1208(ra) # 800041a8 <initlog>
}
    80003668:	70a2                	ld	ra,40(sp)
    8000366a:	7402                	ld	s0,32(sp)
    8000366c:	64e2                	ld	s1,24(sp)
    8000366e:	6942                	ld	s2,16(sp)
    80003670:	69a2                	ld	s3,8(sp)
    80003672:	6145                	addi	sp,sp,48
    80003674:	8082                	ret
    panic("invalid file system");
    80003676:	00005517          	auipc	a0,0x5
    8000367a:	08a50513          	addi	a0,a0,138 # 80008700 <sysnames+0x240>
    8000367e:	ffffd097          	auipc	ra,0xffffd
    80003682:	ef6080e7          	jalr	-266(ra) # 80000574 <panic>

0000000080003686 <iinit>:
{
    80003686:	7179                	addi	sp,sp,-48
    80003688:	f406                	sd	ra,40(sp)
    8000368a:	f022                	sd	s0,32(sp)
    8000368c:	ec26                	sd	s1,24(sp)
    8000368e:	e84a                	sd	s2,16(sp)
    80003690:	e44e                	sd	s3,8(sp)
    80003692:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003694:	00005597          	auipc	a1,0x5
    80003698:	08458593          	addi	a1,a1,132 # 80008718 <sysnames+0x258>
    8000369c:	0001d517          	auipc	a0,0x1d
    800036a0:	9c450513          	addi	a0,a0,-1596 # 80020060 <icache>
    800036a4:	ffffd097          	auipc	ra,0xffffd
    800036a8:	578080e7          	jalr	1400(ra) # 80000c1c <initlock>
  for(i = 0; i < NINODE; i++) {
    800036ac:	0001d497          	auipc	s1,0x1d
    800036b0:	9dc48493          	addi	s1,s1,-1572 # 80020088 <icache+0x28>
    800036b4:	0001e997          	auipc	s3,0x1e
    800036b8:	46498993          	addi	s3,s3,1124 # 80021b18 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800036bc:	00005917          	auipc	s2,0x5
    800036c0:	06490913          	addi	s2,s2,100 # 80008720 <sysnames+0x260>
    800036c4:	85ca                	mv	a1,s2
    800036c6:	8526                	mv	a0,s1
    800036c8:	00001097          	auipc	ra,0x1
    800036cc:	e62080e7          	jalr	-414(ra) # 8000452a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036d0:	08848493          	addi	s1,s1,136
    800036d4:	ff3498e3          	bne	s1,s3,800036c4 <iinit+0x3e>
}
    800036d8:	70a2                	ld	ra,40(sp)
    800036da:	7402                	ld	s0,32(sp)
    800036dc:	64e2                	ld	s1,24(sp)
    800036de:	6942                	ld	s2,16(sp)
    800036e0:	69a2                	ld	s3,8(sp)
    800036e2:	6145                	addi	sp,sp,48
    800036e4:	8082                	ret

00000000800036e6 <ialloc>:
{
    800036e6:	715d                	addi	sp,sp,-80
    800036e8:	e486                	sd	ra,72(sp)
    800036ea:	e0a2                	sd	s0,64(sp)
    800036ec:	fc26                	sd	s1,56(sp)
    800036ee:	f84a                	sd	s2,48(sp)
    800036f0:	f44e                	sd	s3,40(sp)
    800036f2:	f052                	sd	s4,32(sp)
    800036f4:	ec56                	sd	s5,24(sp)
    800036f6:	e85a                	sd	s6,16(sp)
    800036f8:	e45e                	sd	s7,8(sp)
    800036fa:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800036fc:	0001d797          	auipc	a5,0x1d
    80003700:	94478793          	addi	a5,a5,-1724 # 80020040 <sb>
    80003704:	47d8                	lw	a4,12(a5)
    80003706:	4785                	li	a5,1
    80003708:	04e7fa63          	bleu	a4,a5,8000375c <ialloc+0x76>
    8000370c:	8a2a                	mv	s4,a0
    8000370e:	8b2e                	mv	s6,a1
    80003710:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003712:	0001d997          	auipc	s3,0x1d
    80003716:	92e98993          	addi	s3,s3,-1746 # 80020040 <sb>
    8000371a:	00048a9b          	sext.w	s5,s1
    8000371e:	0044d593          	srli	a1,s1,0x4
    80003722:	0189a783          	lw	a5,24(s3)
    80003726:	9dbd                	addw	a1,a1,a5
    80003728:	8552                	mv	a0,s4
    8000372a:	00000097          	auipc	ra,0x0
    8000372e:	910080e7          	jalr	-1776(ra) # 8000303a <bread>
    80003732:	8baa                	mv	s7,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003734:	05850913          	addi	s2,a0,88
    80003738:	00f4f793          	andi	a5,s1,15
    8000373c:	079a                	slli	a5,a5,0x6
    8000373e:	993e                	add	s2,s2,a5
    if(dip->type == 0){  // a free inode
    80003740:	00091783          	lh	a5,0(s2)
    80003744:	c785                	beqz	a5,8000376c <ialloc+0x86>
    brelse(bp);
    80003746:	00000097          	auipc	ra,0x0
    8000374a:	a36080e7          	jalr	-1482(ra) # 8000317c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000374e:	0485                	addi	s1,s1,1
    80003750:	00c9a703          	lw	a4,12(s3)
    80003754:	0004879b          	sext.w	a5,s1
    80003758:	fce7e1e3          	bltu	a5,a4,8000371a <ialloc+0x34>
  panic("ialloc: no inodes");
    8000375c:	00005517          	auipc	a0,0x5
    80003760:	fcc50513          	addi	a0,a0,-52 # 80008728 <sysnames+0x268>
    80003764:	ffffd097          	auipc	ra,0xffffd
    80003768:	e10080e7          	jalr	-496(ra) # 80000574 <panic>
      memset(dip, 0, sizeof(*dip));
    8000376c:	04000613          	li	a2,64
    80003770:	4581                	li	a1,0
    80003772:	854a                	mv	a0,s2
    80003774:	ffffd097          	auipc	ra,0xffffd
    80003778:	634080e7          	jalr	1588(ra) # 80000da8 <memset>
      dip->type = type;
    8000377c:	01691023          	sh	s6,0(s2)
      log_write(bp);   // mark it allocated on the disk
    80003780:	855e                	mv	a0,s7
    80003782:	00001097          	auipc	ra,0x1
    80003786:	ca4080e7          	jalr	-860(ra) # 80004426 <log_write>
      brelse(bp);
    8000378a:	855e                	mv	a0,s7
    8000378c:	00000097          	auipc	ra,0x0
    80003790:	9f0080e7          	jalr	-1552(ra) # 8000317c <brelse>
      return iget(dev, inum);
    80003794:	85d6                	mv	a1,s5
    80003796:	8552                	mv	a0,s4
    80003798:	00000097          	auipc	ra,0x0
    8000379c:	db4080e7          	jalr	-588(ra) # 8000354c <iget>
}
    800037a0:	60a6                	ld	ra,72(sp)
    800037a2:	6406                	ld	s0,64(sp)
    800037a4:	74e2                	ld	s1,56(sp)
    800037a6:	7942                	ld	s2,48(sp)
    800037a8:	79a2                	ld	s3,40(sp)
    800037aa:	7a02                	ld	s4,32(sp)
    800037ac:	6ae2                	ld	s5,24(sp)
    800037ae:	6b42                	ld	s6,16(sp)
    800037b0:	6ba2                	ld	s7,8(sp)
    800037b2:	6161                	addi	sp,sp,80
    800037b4:	8082                	ret

00000000800037b6 <iupdate>:
{
    800037b6:	1101                	addi	sp,sp,-32
    800037b8:	ec06                	sd	ra,24(sp)
    800037ba:	e822                	sd	s0,16(sp)
    800037bc:	e426                	sd	s1,8(sp)
    800037be:	e04a                	sd	s2,0(sp)
    800037c0:	1000                	addi	s0,sp,32
    800037c2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037c4:	415c                	lw	a5,4(a0)
    800037c6:	0047d79b          	srliw	a5,a5,0x4
    800037ca:	0001d717          	auipc	a4,0x1d
    800037ce:	87670713          	addi	a4,a4,-1930 # 80020040 <sb>
    800037d2:	4f0c                	lw	a1,24(a4)
    800037d4:	9dbd                	addw	a1,a1,a5
    800037d6:	4108                	lw	a0,0(a0)
    800037d8:	00000097          	auipc	ra,0x0
    800037dc:	862080e7          	jalr	-1950(ra) # 8000303a <bread>
    800037e0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037e2:	05850513          	addi	a0,a0,88
    800037e6:	40dc                	lw	a5,4(s1)
    800037e8:	8bbd                	andi	a5,a5,15
    800037ea:	079a                	slli	a5,a5,0x6
    800037ec:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800037ee:	04449783          	lh	a5,68(s1)
    800037f2:	00f51023          	sh	a5,0(a0)
  dip->major = ip->major;
    800037f6:	04649783          	lh	a5,70(s1)
    800037fa:	00f51123          	sh	a5,2(a0)
  dip->minor = ip->minor;
    800037fe:	04849783          	lh	a5,72(s1)
    80003802:	00f51223          	sh	a5,4(a0)
  dip->nlink = ip->nlink;
    80003806:	04a49783          	lh	a5,74(s1)
    8000380a:	00f51323          	sh	a5,6(a0)
  dip->size = ip->size;
    8000380e:	44fc                	lw	a5,76(s1)
    80003810:	c51c                	sw	a5,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003812:	03400613          	li	a2,52
    80003816:	05048593          	addi	a1,s1,80
    8000381a:	0531                	addi	a0,a0,12
    8000381c:	ffffd097          	auipc	ra,0xffffd
    80003820:	5f8080e7          	jalr	1528(ra) # 80000e14 <memmove>
  log_write(bp);
    80003824:	854a                	mv	a0,s2
    80003826:	00001097          	auipc	ra,0x1
    8000382a:	c00080e7          	jalr	-1024(ra) # 80004426 <log_write>
  brelse(bp);
    8000382e:	854a                	mv	a0,s2
    80003830:	00000097          	auipc	ra,0x0
    80003834:	94c080e7          	jalr	-1716(ra) # 8000317c <brelse>
}
    80003838:	60e2                	ld	ra,24(sp)
    8000383a:	6442                	ld	s0,16(sp)
    8000383c:	64a2                	ld	s1,8(sp)
    8000383e:	6902                	ld	s2,0(sp)
    80003840:	6105                	addi	sp,sp,32
    80003842:	8082                	ret

0000000080003844 <idup>:
{
    80003844:	1101                	addi	sp,sp,-32
    80003846:	ec06                	sd	ra,24(sp)
    80003848:	e822                	sd	s0,16(sp)
    8000384a:	e426                	sd	s1,8(sp)
    8000384c:	1000                	addi	s0,sp,32
    8000384e:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003850:	0001d517          	auipc	a0,0x1d
    80003854:	81050513          	addi	a0,a0,-2032 # 80020060 <icache>
    80003858:	ffffd097          	auipc	ra,0xffffd
    8000385c:	454080e7          	jalr	1108(ra) # 80000cac <acquire>
  ip->ref++;
    80003860:	449c                	lw	a5,8(s1)
    80003862:	2785                	addiw	a5,a5,1
    80003864:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003866:	0001c517          	auipc	a0,0x1c
    8000386a:	7fa50513          	addi	a0,a0,2042 # 80020060 <icache>
    8000386e:	ffffd097          	auipc	ra,0xffffd
    80003872:	4f2080e7          	jalr	1266(ra) # 80000d60 <release>
}
    80003876:	8526                	mv	a0,s1
    80003878:	60e2                	ld	ra,24(sp)
    8000387a:	6442                	ld	s0,16(sp)
    8000387c:	64a2                	ld	s1,8(sp)
    8000387e:	6105                	addi	sp,sp,32
    80003880:	8082                	ret

0000000080003882 <ilock>:
{
    80003882:	1101                	addi	sp,sp,-32
    80003884:	ec06                	sd	ra,24(sp)
    80003886:	e822                	sd	s0,16(sp)
    80003888:	e426                	sd	s1,8(sp)
    8000388a:	e04a                	sd	s2,0(sp)
    8000388c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000388e:	c115                	beqz	a0,800038b2 <ilock+0x30>
    80003890:	84aa                	mv	s1,a0
    80003892:	451c                	lw	a5,8(a0)
    80003894:	00f05f63          	blez	a5,800038b2 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003898:	0541                	addi	a0,a0,16
    8000389a:	00001097          	auipc	ra,0x1
    8000389e:	cca080e7          	jalr	-822(ra) # 80004564 <acquiresleep>
  if(ip->valid == 0){
    800038a2:	40bc                	lw	a5,64(s1)
    800038a4:	cf99                	beqz	a5,800038c2 <ilock+0x40>
}
    800038a6:	60e2                	ld	ra,24(sp)
    800038a8:	6442                	ld	s0,16(sp)
    800038aa:	64a2                	ld	s1,8(sp)
    800038ac:	6902                	ld	s2,0(sp)
    800038ae:	6105                	addi	sp,sp,32
    800038b0:	8082                	ret
    panic("ilock");
    800038b2:	00005517          	auipc	a0,0x5
    800038b6:	e8e50513          	addi	a0,a0,-370 # 80008740 <sysnames+0x280>
    800038ba:	ffffd097          	auipc	ra,0xffffd
    800038be:	cba080e7          	jalr	-838(ra) # 80000574 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038c2:	40dc                	lw	a5,4(s1)
    800038c4:	0047d79b          	srliw	a5,a5,0x4
    800038c8:	0001c717          	auipc	a4,0x1c
    800038cc:	77870713          	addi	a4,a4,1912 # 80020040 <sb>
    800038d0:	4f0c                	lw	a1,24(a4)
    800038d2:	9dbd                	addw	a1,a1,a5
    800038d4:	4088                	lw	a0,0(s1)
    800038d6:	fffff097          	auipc	ra,0xfffff
    800038da:	764080e7          	jalr	1892(ra) # 8000303a <bread>
    800038de:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038e0:	05850593          	addi	a1,a0,88
    800038e4:	40dc                	lw	a5,4(s1)
    800038e6:	8bbd                	andi	a5,a5,15
    800038e8:	079a                	slli	a5,a5,0x6
    800038ea:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038ec:	00059783          	lh	a5,0(a1)
    800038f0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038f4:	00259783          	lh	a5,2(a1)
    800038f8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800038fc:	00459783          	lh	a5,4(a1)
    80003900:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003904:	00659783          	lh	a5,6(a1)
    80003908:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000390c:	459c                	lw	a5,8(a1)
    8000390e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003910:	03400613          	li	a2,52
    80003914:	05b1                	addi	a1,a1,12
    80003916:	05048513          	addi	a0,s1,80
    8000391a:	ffffd097          	auipc	ra,0xffffd
    8000391e:	4fa080e7          	jalr	1274(ra) # 80000e14 <memmove>
    brelse(bp);
    80003922:	854a                	mv	a0,s2
    80003924:	00000097          	auipc	ra,0x0
    80003928:	858080e7          	jalr	-1960(ra) # 8000317c <brelse>
    ip->valid = 1;
    8000392c:	4785                	li	a5,1
    8000392e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003930:	04449783          	lh	a5,68(s1)
    80003934:	fbad                	bnez	a5,800038a6 <ilock+0x24>
      panic("ilock: no type");
    80003936:	00005517          	auipc	a0,0x5
    8000393a:	e1250513          	addi	a0,a0,-494 # 80008748 <sysnames+0x288>
    8000393e:	ffffd097          	auipc	ra,0xffffd
    80003942:	c36080e7          	jalr	-970(ra) # 80000574 <panic>

0000000080003946 <iunlock>:
{
    80003946:	1101                	addi	sp,sp,-32
    80003948:	ec06                	sd	ra,24(sp)
    8000394a:	e822                	sd	s0,16(sp)
    8000394c:	e426                	sd	s1,8(sp)
    8000394e:	e04a                	sd	s2,0(sp)
    80003950:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003952:	c905                	beqz	a0,80003982 <iunlock+0x3c>
    80003954:	84aa                	mv	s1,a0
    80003956:	01050913          	addi	s2,a0,16
    8000395a:	854a                	mv	a0,s2
    8000395c:	00001097          	auipc	ra,0x1
    80003960:	ca2080e7          	jalr	-862(ra) # 800045fe <holdingsleep>
    80003964:	cd19                	beqz	a0,80003982 <iunlock+0x3c>
    80003966:	449c                	lw	a5,8(s1)
    80003968:	00f05d63          	blez	a5,80003982 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000396c:	854a                	mv	a0,s2
    8000396e:	00001097          	auipc	ra,0x1
    80003972:	c4c080e7          	jalr	-948(ra) # 800045ba <releasesleep>
}
    80003976:	60e2                	ld	ra,24(sp)
    80003978:	6442                	ld	s0,16(sp)
    8000397a:	64a2                	ld	s1,8(sp)
    8000397c:	6902                	ld	s2,0(sp)
    8000397e:	6105                	addi	sp,sp,32
    80003980:	8082                	ret
    panic("iunlock");
    80003982:	00005517          	auipc	a0,0x5
    80003986:	dd650513          	addi	a0,a0,-554 # 80008758 <sysnames+0x298>
    8000398a:	ffffd097          	auipc	ra,0xffffd
    8000398e:	bea080e7          	jalr	-1046(ra) # 80000574 <panic>

0000000080003992 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003992:	7179                	addi	sp,sp,-48
    80003994:	f406                	sd	ra,40(sp)
    80003996:	f022                	sd	s0,32(sp)
    80003998:	ec26                	sd	s1,24(sp)
    8000399a:	e84a                	sd	s2,16(sp)
    8000399c:	e44e                	sd	s3,8(sp)
    8000399e:	e052                	sd	s4,0(sp)
    800039a0:	1800                	addi	s0,sp,48
    800039a2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800039a4:	05050493          	addi	s1,a0,80
    800039a8:	08050913          	addi	s2,a0,128
    800039ac:	a821                	j	800039c4 <itrunc+0x32>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    800039ae:	0009a503          	lw	a0,0(s3)
    800039b2:	00000097          	auipc	ra,0x0
    800039b6:	8e0080e7          	jalr	-1824(ra) # 80003292 <bfree>
      ip->addrs[i] = 0;
    800039ba:	0004a023          	sw	zero,0(s1)
  for(i = 0; i < NDIRECT; i++){
    800039be:	0491                	addi	s1,s1,4
    800039c0:	01248563          	beq	s1,s2,800039ca <itrunc+0x38>
    if(ip->addrs[i]){
    800039c4:	408c                	lw	a1,0(s1)
    800039c6:	dde5                	beqz	a1,800039be <itrunc+0x2c>
    800039c8:	b7dd                	j	800039ae <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039ca:	0809a583          	lw	a1,128(s3)
    800039ce:	e185                	bnez	a1,800039ee <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039d0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039d4:	854e                	mv	a0,s3
    800039d6:	00000097          	auipc	ra,0x0
    800039da:	de0080e7          	jalr	-544(ra) # 800037b6 <iupdate>
}
    800039de:	70a2                	ld	ra,40(sp)
    800039e0:	7402                	ld	s0,32(sp)
    800039e2:	64e2                	ld	s1,24(sp)
    800039e4:	6942                	ld	s2,16(sp)
    800039e6:	69a2                	ld	s3,8(sp)
    800039e8:	6a02                	ld	s4,0(sp)
    800039ea:	6145                	addi	sp,sp,48
    800039ec:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039ee:	0009a503          	lw	a0,0(s3)
    800039f2:	fffff097          	auipc	ra,0xfffff
    800039f6:	648080e7          	jalr	1608(ra) # 8000303a <bread>
    800039fa:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039fc:	05850493          	addi	s1,a0,88
    80003a00:	45850913          	addi	s2,a0,1112
    80003a04:	a811                	j	80003a18 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003a06:	0009a503          	lw	a0,0(s3)
    80003a0a:	00000097          	auipc	ra,0x0
    80003a0e:	888080e7          	jalr	-1912(ra) # 80003292 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003a12:	0491                	addi	s1,s1,4
    80003a14:	01248563          	beq	s1,s2,80003a1e <itrunc+0x8c>
      if(a[j])
    80003a18:	408c                	lw	a1,0(s1)
    80003a1a:	dde5                	beqz	a1,80003a12 <itrunc+0x80>
    80003a1c:	b7ed                	j	80003a06 <itrunc+0x74>
    brelse(bp);
    80003a1e:	8552                	mv	a0,s4
    80003a20:	fffff097          	auipc	ra,0xfffff
    80003a24:	75c080e7          	jalr	1884(ra) # 8000317c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a28:	0809a583          	lw	a1,128(s3)
    80003a2c:	0009a503          	lw	a0,0(s3)
    80003a30:	00000097          	auipc	ra,0x0
    80003a34:	862080e7          	jalr	-1950(ra) # 80003292 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a38:	0809a023          	sw	zero,128(s3)
    80003a3c:	bf51                	j	800039d0 <itrunc+0x3e>

0000000080003a3e <iput>:
{
    80003a3e:	1101                	addi	sp,sp,-32
    80003a40:	ec06                	sd	ra,24(sp)
    80003a42:	e822                	sd	s0,16(sp)
    80003a44:	e426                	sd	s1,8(sp)
    80003a46:	e04a                	sd	s2,0(sp)
    80003a48:	1000                	addi	s0,sp,32
    80003a4a:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003a4c:	0001c517          	auipc	a0,0x1c
    80003a50:	61450513          	addi	a0,a0,1556 # 80020060 <icache>
    80003a54:	ffffd097          	auipc	ra,0xffffd
    80003a58:	258080e7          	jalr	600(ra) # 80000cac <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a5c:	4498                	lw	a4,8(s1)
    80003a5e:	4785                	li	a5,1
    80003a60:	02f70363          	beq	a4,a5,80003a86 <iput+0x48>
  ip->ref--;
    80003a64:	449c                	lw	a5,8(s1)
    80003a66:	37fd                	addiw	a5,a5,-1
    80003a68:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003a6a:	0001c517          	auipc	a0,0x1c
    80003a6e:	5f650513          	addi	a0,a0,1526 # 80020060 <icache>
    80003a72:	ffffd097          	auipc	ra,0xffffd
    80003a76:	2ee080e7          	jalr	750(ra) # 80000d60 <release>
}
    80003a7a:	60e2                	ld	ra,24(sp)
    80003a7c:	6442                	ld	s0,16(sp)
    80003a7e:	64a2                	ld	s1,8(sp)
    80003a80:	6902                	ld	s2,0(sp)
    80003a82:	6105                	addi	sp,sp,32
    80003a84:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a86:	40bc                	lw	a5,64(s1)
    80003a88:	dff1                	beqz	a5,80003a64 <iput+0x26>
    80003a8a:	04a49783          	lh	a5,74(s1)
    80003a8e:	fbf9                	bnez	a5,80003a64 <iput+0x26>
    acquiresleep(&ip->lock);
    80003a90:	01048913          	addi	s2,s1,16
    80003a94:	854a                	mv	a0,s2
    80003a96:	00001097          	auipc	ra,0x1
    80003a9a:	ace080e7          	jalr	-1330(ra) # 80004564 <acquiresleep>
    release(&icache.lock);
    80003a9e:	0001c517          	auipc	a0,0x1c
    80003aa2:	5c250513          	addi	a0,a0,1474 # 80020060 <icache>
    80003aa6:	ffffd097          	auipc	ra,0xffffd
    80003aaa:	2ba080e7          	jalr	698(ra) # 80000d60 <release>
    itrunc(ip);
    80003aae:	8526                	mv	a0,s1
    80003ab0:	00000097          	auipc	ra,0x0
    80003ab4:	ee2080e7          	jalr	-286(ra) # 80003992 <itrunc>
    ip->type = 0;
    80003ab8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003abc:	8526                	mv	a0,s1
    80003abe:	00000097          	auipc	ra,0x0
    80003ac2:	cf8080e7          	jalr	-776(ra) # 800037b6 <iupdate>
    ip->valid = 0;
    80003ac6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003aca:	854a                	mv	a0,s2
    80003acc:	00001097          	auipc	ra,0x1
    80003ad0:	aee080e7          	jalr	-1298(ra) # 800045ba <releasesleep>
    acquire(&icache.lock);
    80003ad4:	0001c517          	auipc	a0,0x1c
    80003ad8:	58c50513          	addi	a0,a0,1420 # 80020060 <icache>
    80003adc:	ffffd097          	auipc	ra,0xffffd
    80003ae0:	1d0080e7          	jalr	464(ra) # 80000cac <acquire>
    80003ae4:	b741                	j	80003a64 <iput+0x26>

0000000080003ae6 <iunlockput>:
{
    80003ae6:	1101                	addi	sp,sp,-32
    80003ae8:	ec06                	sd	ra,24(sp)
    80003aea:	e822                	sd	s0,16(sp)
    80003aec:	e426                	sd	s1,8(sp)
    80003aee:	1000                	addi	s0,sp,32
    80003af0:	84aa                	mv	s1,a0
  iunlock(ip);
    80003af2:	00000097          	auipc	ra,0x0
    80003af6:	e54080e7          	jalr	-428(ra) # 80003946 <iunlock>
  iput(ip);
    80003afa:	8526                	mv	a0,s1
    80003afc:	00000097          	auipc	ra,0x0
    80003b00:	f42080e7          	jalr	-190(ra) # 80003a3e <iput>
}
    80003b04:	60e2                	ld	ra,24(sp)
    80003b06:	6442                	ld	s0,16(sp)
    80003b08:	64a2                	ld	s1,8(sp)
    80003b0a:	6105                	addi	sp,sp,32
    80003b0c:	8082                	ret

0000000080003b0e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b0e:	1141                	addi	sp,sp,-16
    80003b10:	e422                	sd	s0,8(sp)
    80003b12:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b14:	411c                	lw	a5,0(a0)
    80003b16:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b18:	415c                	lw	a5,4(a0)
    80003b1a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b1c:	04451783          	lh	a5,68(a0)
    80003b20:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b24:	04a51783          	lh	a5,74(a0)
    80003b28:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b2c:	04c56783          	lwu	a5,76(a0)
    80003b30:	e99c                	sd	a5,16(a1)
}
    80003b32:	6422                	ld	s0,8(sp)
    80003b34:	0141                	addi	sp,sp,16
    80003b36:	8082                	ret

0000000080003b38 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b38:	457c                	lw	a5,76(a0)
    80003b3a:	0ed7e863          	bltu	a5,a3,80003c2a <readi+0xf2>
{
    80003b3e:	7159                	addi	sp,sp,-112
    80003b40:	f486                	sd	ra,104(sp)
    80003b42:	f0a2                	sd	s0,96(sp)
    80003b44:	eca6                	sd	s1,88(sp)
    80003b46:	e8ca                	sd	s2,80(sp)
    80003b48:	e4ce                	sd	s3,72(sp)
    80003b4a:	e0d2                	sd	s4,64(sp)
    80003b4c:	fc56                	sd	s5,56(sp)
    80003b4e:	f85a                	sd	s6,48(sp)
    80003b50:	f45e                	sd	s7,40(sp)
    80003b52:	f062                	sd	s8,32(sp)
    80003b54:	ec66                	sd	s9,24(sp)
    80003b56:	e86a                	sd	s10,16(sp)
    80003b58:	e46e                	sd	s11,8(sp)
    80003b5a:	1880                	addi	s0,sp,112
    80003b5c:	8baa                	mv	s7,a0
    80003b5e:	8c2e                	mv	s8,a1
    80003b60:	8a32                	mv	s4,a2
    80003b62:	84b6                	mv	s1,a3
    80003b64:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b66:	9f35                	addw	a4,a4,a3
    return 0;
    80003b68:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b6a:	08d76f63          	bltu	a4,a3,80003c08 <readi+0xd0>
  if(off + n > ip->size)
    80003b6e:	00e7f463          	bleu	a4,a5,80003b76 <readi+0x3e>
    n = ip->size - off;
    80003b72:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b76:	0a0b0863          	beqz	s6,80003c26 <readi+0xee>
    80003b7a:	4901                	li	s2,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b7c:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b80:	5cfd                	li	s9,-1
    80003b82:	a82d                	j	80003bbc <readi+0x84>
    80003b84:	02099d93          	slli	s11,s3,0x20
    80003b88:	020ddd93          	srli	s11,s11,0x20
    80003b8c:	058a8613          	addi	a2,s5,88
    80003b90:	86ee                	mv	a3,s11
    80003b92:	963a                	add	a2,a2,a4
    80003b94:	85d2                	mv	a1,s4
    80003b96:	8562                	mv	a0,s8
    80003b98:	fffff097          	auipc	ra,0xfffff
    80003b9c:	9a6080e7          	jalr	-1626(ra) # 8000253e <either_copyout>
    80003ba0:	05950d63          	beq	a0,s9,80003bfa <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003ba4:	8556                	mv	a0,s5
    80003ba6:	fffff097          	auipc	ra,0xfffff
    80003baa:	5d6080e7          	jalr	1494(ra) # 8000317c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bae:	0129893b          	addw	s2,s3,s2
    80003bb2:	009984bb          	addw	s1,s3,s1
    80003bb6:	9a6e                	add	s4,s4,s11
    80003bb8:	05697663          	bleu	s6,s2,80003c04 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003bbc:	000ba983          	lw	s3,0(s7)
    80003bc0:	00a4d59b          	srliw	a1,s1,0xa
    80003bc4:	855e                	mv	a0,s7
    80003bc6:	00000097          	auipc	ra,0x0
    80003bca:	8ac080e7          	jalr	-1876(ra) # 80003472 <bmap>
    80003bce:	0005059b          	sext.w	a1,a0
    80003bd2:	854e                	mv	a0,s3
    80003bd4:	fffff097          	auipc	ra,0xfffff
    80003bd8:	466080e7          	jalr	1126(ra) # 8000303a <bread>
    80003bdc:	8aaa                	mv	s5,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bde:	3ff4f713          	andi	a4,s1,1023
    80003be2:	40ed07bb          	subw	a5,s10,a4
    80003be6:	412b06bb          	subw	a3,s6,s2
    80003bea:	89be                	mv	s3,a5
    80003bec:	2781                	sext.w	a5,a5
    80003bee:	0006861b          	sext.w	a2,a3
    80003bf2:	f8f679e3          	bleu	a5,a2,80003b84 <readi+0x4c>
    80003bf6:	89b6                	mv	s3,a3
    80003bf8:	b771                	j	80003b84 <readi+0x4c>
      brelse(bp);
    80003bfa:	8556                	mv	a0,s5
    80003bfc:	fffff097          	auipc	ra,0xfffff
    80003c00:	580080e7          	jalr	1408(ra) # 8000317c <brelse>
  }
  return tot;
    80003c04:	0009051b          	sext.w	a0,s2
}
    80003c08:	70a6                	ld	ra,104(sp)
    80003c0a:	7406                	ld	s0,96(sp)
    80003c0c:	64e6                	ld	s1,88(sp)
    80003c0e:	6946                	ld	s2,80(sp)
    80003c10:	69a6                	ld	s3,72(sp)
    80003c12:	6a06                	ld	s4,64(sp)
    80003c14:	7ae2                	ld	s5,56(sp)
    80003c16:	7b42                	ld	s6,48(sp)
    80003c18:	7ba2                	ld	s7,40(sp)
    80003c1a:	7c02                	ld	s8,32(sp)
    80003c1c:	6ce2                	ld	s9,24(sp)
    80003c1e:	6d42                	ld	s10,16(sp)
    80003c20:	6da2                	ld	s11,8(sp)
    80003c22:	6165                	addi	sp,sp,112
    80003c24:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c26:	895a                	mv	s2,s6
    80003c28:	bff1                	j	80003c04 <readi+0xcc>
    return 0;
    80003c2a:	4501                	li	a0,0
}
    80003c2c:	8082                	ret

0000000080003c2e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c2e:	457c                	lw	a5,76(a0)
    80003c30:	10d7e663          	bltu	a5,a3,80003d3c <writei+0x10e>
{
    80003c34:	7159                	addi	sp,sp,-112
    80003c36:	f486                	sd	ra,104(sp)
    80003c38:	f0a2                	sd	s0,96(sp)
    80003c3a:	eca6                	sd	s1,88(sp)
    80003c3c:	e8ca                	sd	s2,80(sp)
    80003c3e:	e4ce                	sd	s3,72(sp)
    80003c40:	e0d2                	sd	s4,64(sp)
    80003c42:	fc56                	sd	s5,56(sp)
    80003c44:	f85a                	sd	s6,48(sp)
    80003c46:	f45e                	sd	s7,40(sp)
    80003c48:	f062                	sd	s8,32(sp)
    80003c4a:	ec66                	sd	s9,24(sp)
    80003c4c:	e86a                	sd	s10,16(sp)
    80003c4e:	e46e                	sd	s11,8(sp)
    80003c50:	1880                	addi	s0,sp,112
    80003c52:	8baa                	mv	s7,a0
    80003c54:	8c2e                	mv	s8,a1
    80003c56:	8ab2                	mv	s5,a2
    80003c58:	84b6                	mv	s1,a3
    80003c5a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c5c:	00e687bb          	addw	a5,a3,a4
    80003c60:	0ed7e063          	bltu	a5,a3,80003d40 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c64:	00043737          	lui	a4,0x43
    80003c68:	0cf76e63          	bltu	a4,a5,80003d44 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c6c:	0a0b0763          	beqz	s6,80003d1a <writei+0xec>
    80003c70:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c72:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c76:	5cfd                	li	s9,-1
    80003c78:	a091                	j	80003cbc <writei+0x8e>
    80003c7a:	02091d93          	slli	s11,s2,0x20
    80003c7e:	020ddd93          	srli	s11,s11,0x20
    80003c82:	05898513          	addi	a0,s3,88
    80003c86:	86ee                	mv	a3,s11
    80003c88:	8656                	mv	a2,s5
    80003c8a:	85e2                	mv	a1,s8
    80003c8c:	953a                	add	a0,a0,a4
    80003c8e:	fffff097          	auipc	ra,0xfffff
    80003c92:	906080e7          	jalr	-1786(ra) # 80002594 <either_copyin>
    80003c96:	07950263          	beq	a0,s9,80003cfa <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c9a:	854e                	mv	a0,s3
    80003c9c:	00000097          	auipc	ra,0x0
    80003ca0:	78a080e7          	jalr	1930(ra) # 80004426 <log_write>
    brelse(bp);
    80003ca4:	854e                	mv	a0,s3
    80003ca6:	fffff097          	auipc	ra,0xfffff
    80003caa:	4d6080e7          	jalr	1238(ra) # 8000317c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cae:	01490a3b          	addw	s4,s2,s4
    80003cb2:	009904bb          	addw	s1,s2,s1
    80003cb6:	9aee                	add	s5,s5,s11
    80003cb8:	056a7663          	bleu	s6,s4,80003d04 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003cbc:	000ba903          	lw	s2,0(s7)
    80003cc0:	00a4d59b          	srliw	a1,s1,0xa
    80003cc4:	855e                	mv	a0,s7
    80003cc6:	fffff097          	auipc	ra,0xfffff
    80003cca:	7ac080e7          	jalr	1964(ra) # 80003472 <bmap>
    80003cce:	0005059b          	sext.w	a1,a0
    80003cd2:	854a                	mv	a0,s2
    80003cd4:	fffff097          	auipc	ra,0xfffff
    80003cd8:	366080e7          	jalr	870(ra) # 8000303a <bread>
    80003cdc:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cde:	3ff4f713          	andi	a4,s1,1023
    80003ce2:	40ed07bb          	subw	a5,s10,a4
    80003ce6:	414b06bb          	subw	a3,s6,s4
    80003cea:	893e                	mv	s2,a5
    80003cec:	2781                	sext.w	a5,a5
    80003cee:	0006861b          	sext.w	a2,a3
    80003cf2:	f8f674e3          	bleu	a5,a2,80003c7a <writei+0x4c>
    80003cf6:	8936                	mv	s2,a3
    80003cf8:	b749                	j	80003c7a <writei+0x4c>
      brelse(bp);
    80003cfa:	854e                	mv	a0,s3
    80003cfc:	fffff097          	auipc	ra,0xfffff
    80003d00:	480080e7          	jalr	1152(ra) # 8000317c <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003d04:	04cba783          	lw	a5,76(s7)
    80003d08:	0097f463          	bleu	s1,a5,80003d10 <writei+0xe2>
      ip->size = off;
    80003d0c:	049ba623          	sw	s1,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003d10:	855e                	mv	a0,s7
    80003d12:	00000097          	auipc	ra,0x0
    80003d16:	aa4080e7          	jalr	-1372(ra) # 800037b6 <iupdate>
  }

  return n;
    80003d1a:	000b051b          	sext.w	a0,s6
}
    80003d1e:	70a6                	ld	ra,104(sp)
    80003d20:	7406                	ld	s0,96(sp)
    80003d22:	64e6                	ld	s1,88(sp)
    80003d24:	6946                	ld	s2,80(sp)
    80003d26:	69a6                	ld	s3,72(sp)
    80003d28:	6a06                	ld	s4,64(sp)
    80003d2a:	7ae2                	ld	s5,56(sp)
    80003d2c:	7b42                	ld	s6,48(sp)
    80003d2e:	7ba2                	ld	s7,40(sp)
    80003d30:	7c02                	ld	s8,32(sp)
    80003d32:	6ce2                	ld	s9,24(sp)
    80003d34:	6d42                	ld	s10,16(sp)
    80003d36:	6da2                	ld	s11,8(sp)
    80003d38:	6165                	addi	sp,sp,112
    80003d3a:	8082                	ret
    return -1;
    80003d3c:	557d                	li	a0,-1
}
    80003d3e:	8082                	ret
    return -1;
    80003d40:	557d                	li	a0,-1
    80003d42:	bff1                	j	80003d1e <writei+0xf0>
    return -1;
    80003d44:	557d                	li	a0,-1
    80003d46:	bfe1                	j	80003d1e <writei+0xf0>

0000000080003d48 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d48:	1141                	addi	sp,sp,-16
    80003d4a:	e406                	sd	ra,8(sp)
    80003d4c:	e022                	sd	s0,0(sp)
    80003d4e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d50:	4639                	li	a2,14
    80003d52:	ffffd097          	auipc	ra,0xffffd
    80003d56:	13e080e7          	jalr	318(ra) # 80000e90 <strncmp>
}
    80003d5a:	60a2                	ld	ra,8(sp)
    80003d5c:	6402                	ld	s0,0(sp)
    80003d5e:	0141                	addi	sp,sp,16
    80003d60:	8082                	ret

0000000080003d62 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d62:	7139                	addi	sp,sp,-64
    80003d64:	fc06                	sd	ra,56(sp)
    80003d66:	f822                	sd	s0,48(sp)
    80003d68:	f426                	sd	s1,40(sp)
    80003d6a:	f04a                	sd	s2,32(sp)
    80003d6c:	ec4e                	sd	s3,24(sp)
    80003d6e:	e852                	sd	s4,16(sp)
    80003d70:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d72:	04451703          	lh	a4,68(a0)
    80003d76:	4785                	li	a5,1
    80003d78:	00f71a63          	bne	a4,a5,80003d8c <dirlookup+0x2a>
    80003d7c:	892a                	mv	s2,a0
    80003d7e:	89ae                	mv	s3,a1
    80003d80:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d82:	457c                	lw	a5,76(a0)
    80003d84:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d86:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d88:	e79d                	bnez	a5,80003db6 <dirlookup+0x54>
    80003d8a:	a8a5                	j	80003e02 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d8c:	00005517          	auipc	a0,0x5
    80003d90:	9d450513          	addi	a0,a0,-1580 # 80008760 <sysnames+0x2a0>
    80003d94:	ffffc097          	auipc	ra,0xffffc
    80003d98:	7e0080e7          	jalr	2016(ra) # 80000574 <panic>
      panic("dirlookup read");
    80003d9c:	00005517          	auipc	a0,0x5
    80003da0:	9dc50513          	addi	a0,a0,-1572 # 80008778 <sysnames+0x2b8>
    80003da4:	ffffc097          	auipc	ra,0xffffc
    80003da8:	7d0080e7          	jalr	2000(ra) # 80000574 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dac:	24c1                	addiw	s1,s1,16
    80003dae:	04c92783          	lw	a5,76(s2)
    80003db2:	04f4f763          	bleu	a5,s1,80003e00 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003db6:	4741                	li	a4,16
    80003db8:	86a6                	mv	a3,s1
    80003dba:	fc040613          	addi	a2,s0,-64
    80003dbe:	4581                	li	a1,0
    80003dc0:	854a                	mv	a0,s2
    80003dc2:	00000097          	auipc	ra,0x0
    80003dc6:	d76080e7          	jalr	-650(ra) # 80003b38 <readi>
    80003dca:	47c1                	li	a5,16
    80003dcc:	fcf518e3          	bne	a0,a5,80003d9c <dirlookup+0x3a>
    if(de.inum == 0)
    80003dd0:	fc045783          	lhu	a5,-64(s0)
    80003dd4:	dfe1                	beqz	a5,80003dac <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003dd6:	fc240593          	addi	a1,s0,-62
    80003dda:	854e                	mv	a0,s3
    80003ddc:	00000097          	auipc	ra,0x0
    80003de0:	f6c080e7          	jalr	-148(ra) # 80003d48 <namecmp>
    80003de4:	f561                	bnez	a0,80003dac <dirlookup+0x4a>
      if(poff)
    80003de6:	000a0463          	beqz	s4,80003dee <dirlookup+0x8c>
        *poff = off;
    80003dea:	009a2023          	sw	s1,0(s4) # 2000 <_entry-0x7fffe000>
      return iget(dp->dev, inum);
    80003dee:	fc045583          	lhu	a1,-64(s0)
    80003df2:	00092503          	lw	a0,0(s2)
    80003df6:	fffff097          	auipc	ra,0xfffff
    80003dfa:	756080e7          	jalr	1878(ra) # 8000354c <iget>
    80003dfe:	a011                	j	80003e02 <dirlookup+0xa0>
  return 0;
    80003e00:	4501                	li	a0,0
}
    80003e02:	70e2                	ld	ra,56(sp)
    80003e04:	7442                	ld	s0,48(sp)
    80003e06:	74a2                	ld	s1,40(sp)
    80003e08:	7902                	ld	s2,32(sp)
    80003e0a:	69e2                	ld	s3,24(sp)
    80003e0c:	6a42                	ld	s4,16(sp)
    80003e0e:	6121                	addi	sp,sp,64
    80003e10:	8082                	ret

0000000080003e12 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e12:	711d                	addi	sp,sp,-96
    80003e14:	ec86                	sd	ra,88(sp)
    80003e16:	e8a2                	sd	s0,80(sp)
    80003e18:	e4a6                	sd	s1,72(sp)
    80003e1a:	e0ca                	sd	s2,64(sp)
    80003e1c:	fc4e                	sd	s3,56(sp)
    80003e1e:	f852                	sd	s4,48(sp)
    80003e20:	f456                	sd	s5,40(sp)
    80003e22:	f05a                	sd	s6,32(sp)
    80003e24:	ec5e                	sd	s7,24(sp)
    80003e26:	e862                	sd	s8,16(sp)
    80003e28:	e466                	sd	s9,8(sp)
    80003e2a:	1080                	addi	s0,sp,96
    80003e2c:	84aa                	mv	s1,a0
    80003e2e:	8bae                	mv	s7,a1
    80003e30:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e32:	00054703          	lbu	a4,0(a0)
    80003e36:	02f00793          	li	a5,47
    80003e3a:	02f70363          	beq	a4,a5,80003e60 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e3e:	ffffe097          	auipc	ra,0xffffe
    80003e42:	c7c080e7          	jalr	-900(ra) # 80001aba <myproc>
    80003e46:	15053503          	ld	a0,336(a0)
    80003e4a:	00000097          	auipc	ra,0x0
    80003e4e:	9fa080e7          	jalr	-1542(ra) # 80003844 <idup>
    80003e52:	89aa                	mv	s3,a0
  while(*path == '/')
    80003e54:	02f00913          	li	s2,47
  len = path - s;
    80003e58:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003e5a:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e5c:	4c05                	li	s8,1
    80003e5e:	a865                	j	80003f16 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003e60:	4585                	li	a1,1
    80003e62:	4505                	li	a0,1
    80003e64:	fffff097          	auipc	ra,0xfffff
    80003e68:	6e8080e7          	jalr	1768(ra) # 8000354c <iget>
    80003e6c:	89aa                	mv	s3,a0
    80003e6e:	b7dd                	j	80003e54 <namex+0x42>
      iunlockput(ip);
    80003e70:	854e                	mv	a0,s3
    80003e72:	00000097          	auipc	ra,0x0
    80003e76:	c74080e7          	jalr	-908(ra) # 80003ae6 <iunlockput>
      return 0;
    80003e7a:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e7c:	854e                	mv	a0,s3
    80003e7e:	60e6                	ld	ra,88(sp)
    80003e80:	6446                	ld	s0,80(sp)
    80003e82:	64a6                	ld	s1,72(sp)
    80003e84:	6906                	ld	s2,64(sp)
    80003e86:	79e2                	ld	s3,56(sp)
    80003e88:	7a42                	ld	s4,48(sp)
    80003e8a:	7aa2                	ld	s5,40(sp)
    80003e8c:	7b02                	ld	s6,32(sp)
    80003e8e:	6be2                	ld	s7,24(sp)
    80003e90:	6c42                	ld	s8,16(sp)
    80003e92:	6ca2                	ld	s9,8(sp)
    80003e94:	6125                	addi	sp,sp,96
    80003e96:	8082                	ret
      iunlock(ip);
    80003e98:	854e                	mv	a0,s3
    80003e9a:	00000097          	auipc	ra,0x0
    80003e9e:	aac080e7          	jalr	-1364(ra) # 80003946 <iunlock>
      return ip;
    80003ea2:	bfe9                	j	80003e7c <namex+0x6a>
      iunlockput(ip);
    80003ea4:	854e                	mv	a0,s3
    80003ea6:	00000097          	auipc	ra,0x0
    80003eaa:	c40080e7          	jalr	-960(ra) # 80003ae6 <iunlockput>
      return 0;
    80003eae:	89d2                	mv	s3,s4
    80003eb0:	b7f1                	j	80003e7c <namex+0x6a>
  len = path - s;
    80003eb2:	40b48633          	sub	a2,s1,a1
    80003eb6:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003eba:	094cd663          	ble	s4,s9,80003f46 <namex+0x134>
    memmove(name, s, DIRSIZ);
    80003ebe:	4639                	li	a2,14
    80003ec0:	8556                	mv	a0,s5
    80003ec2:	ffffd097          	auipc	ra,0xffffd
    80003ec6:	f52080e7          	jalr	-174(ra) # 80000e14 <memmove>
  while(*path == '/')
    80003eca:	0004c783          	lbu	a5,0(s1)
    80003ece:	01279763          	bne	a5,s2,80003edc <namex+0xca>
    path++;
    80003ed2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ed4:	0004c783          	lbu	a5,0(s1)
    80003ed8:	ff278de3          	beq	a5,s2,80003ed2 <namex+0xc0>
    ilock(ip);
    80003edc:	854e                	mv	a0,s3
    80003ede:	00000097          	auipc	ra,0x0
    80003ee2:	9a4080e7          	jalr	-1628(ra) # 80003882 <ilock>
    if(ip->type != T_DIR){
    80003ee6:	04499783          	lh	a5,68(s3)
    80003eea:	f98793e3          	bne	a5,s8,80003e70 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003eee:	000b8563          	beqz	s7,80003ef8 <namex+0xe6>
    80003ef2:	0004c783          	lbu	a5,0(s1)
    80003ef6:	d3cd                	beqz	a5,80003e98 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ef8:	865a                	mv	a2,s6
    80003efa:	85d6                	mv	a1,s5
    80003efc:	854e                	mv	a0,s3
    80003efe:	00000097          	auipc	ra,0x0
    80003f02:	e64080e7          	jalr	-412(ra) # 80003d62 <dirlookup>
    80003f06:	8a2a                	mv	s4,a0
    80003f08:	dd51                	beqz	a0,80003ea4 <namex+0x92>
    iunlockput(ip);
    80003f0a:	854e                	mv	a0,s3
    80003f0c:	00000097          	auipc	ra,0x0
    80003f10:	bda080e7          	jalr	-1062(ra) # 80003ae6 <iunlockput>
    ip = next;
    80003f14:	89d2                	mv	s3,s4
  while(*path == '/')
    80003f16:	0004c783          	lbu	a5,0(s1)
    80003f1a:	05279d63          	bne	a5,s2,80003f74 <namex+0x162>
    path++;
    80003f1e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f20:	0004c783          	lbu	a5,0(s1)
    80003f24:	ff278de3          	beq	a5,s2,80003f1e <namex+0x10c>
  if(*path == 0)
    80003f28:	cf8d                	beqz	a5,80003f62 <namex+0x150>
  while(*path != '/' && *path != 0)
    80003f2a:	01278b63          	beq	a5,s2,80003f40 <namex+0x12e>
    80003f2e:	c795                	beqz	a5,80003f5a <namex+0x148>
    path++;
    80003f30:	85a6                	mv	a1,s1
    path++;
    80003f32:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003f34:	0004c783          	lbu	a5,0(s1)
    80003f38:	f7278de3          	beq	a5,s2,80003eb2 <namex+0xa0>
    80003f3c:	fbfd                	bnez	a5,80003f32 <namex+0x120>
    80003f3e:	bf95                	j	80003eb2 <namex+0xa0>
    80003f40:	85a6                	mv	a1,s1
  len = path - s;
    80003f42:	8a5a                	mv	s4,s6
    80003f44:	865a                	mv	a2,s6
    memmove(name, s, len);
    80003f46:	2601                	sext.w	a2,a2
    80003f48:	8556                	mv	a0,s5
    80003f4a:	ffffd097          	auipc	ra,0xffffd
    80003f4e:	eca080e7          	jalr	-310(ra) # 80000e14 <memmove>
    name[len] = 0;
    80003f52:	9a56                	add	s4,s4,s5
    80003f54:	000a0023          	sb	zero,0(s4)
    80003f58:	bf8d                	j	80003eca <namex+0xb8>
  while(*path != '/' && *path != 0)
    80003f5a:	85a6                	mv	a1,s1
  len = path - s;
    80003f5c:	8a5a                	mv	s4,s6
    80003f5e:	865a                	mv	a2,s6
    80003f60:	b7dd                	j	80003f46 <namex+0x134>
  if(nameiparent){
    80003f62:	f00b8de3          	beqz	s7,80003e7c <namex+0x6a>
    iput(ip);
    80003f66:	854e                	mv	a0,s3
    80003f68:	00000097          	auipc	ra,0x0
    80003f6c:	ad6080e7          	jalr	-1322(ra) # 80003a3e <iput>
    return 0;
    80003f70:	4981                	li	s3,0
    80003f72:	b729                	j	80003e7c <namex+0x6a>
  if(*path == 0)
    80003f74:	d7fd                	beqz	a5,80003f62 <namex+0x150>
    80003f76:	85a6                	mv	a1,s1
    80003f78:	bf6d                	j	80003f32 <namex+0x120>

0000000080003f7a <dirlink>:
{
    80003f7a:	7139                	addi	sp,sp,-64
    80003f7c:	fc06                	sd	ra,56(sp)
    80003f7e:	f822                	sd	s0,48(sp)
    80003f80:	f426                	sd	s1,40(sp)
    80003f82:	f04a                	sd	s2,32(sp)
    80003f84:	ec4e                	sd	s3,24(sp)
    80003f86:	e852                	sd	s4,16(sp)
    80003f88:	0080                	addi	s0,sp,64
    80003f8a:	892a                	mv	s2,a0
    80003f8c:	8a2e                	mv	s4,a1
    80003f8e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f90:	4601                	li	a2,0
    80003f92:	00000097          	auipc	ra,0x0
    80003f96:	dd0080e7          	jalr	-560(ra) # 80003d62 <dirlookup>
    80003f9a:	e93d                	bnez	a0,80004010 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f9c:	04c92483          	lw	s1,76(s2)
    80003fa0:	c49d                	beqz	s1,80003fce <dirlink+0x54>
    80003fa2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fa4:	4741                	li	a4,16
    80003fa6:	86a6                	mv	a3,s1
    80003fa8:	fc040613          	addi	a2,s0,-64
    80003fac:	4581                	li	a1,0
    80003fae:	854a                	mv	a0,s2
    80003fb0:	00000097          	auipc	ra,0x0
    80003fb4:	b88080e7          	jalr	-1144(ra) # 80003b38 <readi>
    80003fb8:	47c1                	li	a5,16
    80003fba:	06f51163          	bne	a0,a5,8000401c <dirlink+0xa2>
    if(de.inum == 0)
    80003fbe:	fc045783          	lhu	a5,-64(s0)
    80003fc2:	c791                	beqz	a5,80003fce <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fc4:	24c1                	addiw	s1,s1,16
    80003fc6:	04c92783          	lw	a5,76(s2)
    80003fca:	fcf4ede3          	bltu	s1,a5,80003fa4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003fce:	4639                	li	a2,14
    80003fd0:	85d2                	mv	a1,s4
    80003fd2:	fc240513          	addi	a0,s0,-62
    80003fd6:	ffffd097          	auipc	ra,0xffffd
    80003fda:	f0a080e7          	jalr	-246(ra) # 80000ee0 <strncpy>
  de.inum = inum;
    80003fde:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fe2:	4741                	li	a4,16
    80003fe4:	86a6                	mv	a3,s1
    80003fe6:	fc040613          	addi	a2,s0,-64
    80003fea:	4581                	li	a1,0
    80003fec:	854a                	mv	a0,s2
    80003fee:	00000097          	auipc	ra,0x0
    80003ff2:	c40080e7          	jalr	-960(ra) # 80003c2e <writei>
    80003ff6:	4741                	li	a4,16
  return 0;
    80003ff8:	4781                	li	a5,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ffa:	02e51963          	bne	a0,a4,8000402c <dirlink+0xb2>
}
    80003ffe:	853e                	mv	a0,a5
    80004000:	70e2                	ld	ra,56(sp)
    80004002:	7442                	ld	s0,48(sp)
    80004004:	74a2                	ld	s1,40(sp)
    80004006:	7902                	ld	s2,32(sp)
    80004008:	69e2                	ld	s3,24(sp)
    8000400a:	6a42                	ld	s4,16(sp)
    8000400c:	6121                	addi	sp,sp,64
    8000400e:	8082                	ret
    iput(ip);
    80004010:	00000097          	auipc	ra,0x0
    80004014:	a2e080e7          	jalr	-1490(ra) # 80003a3e <iput>
    return -1;
    80004018:	57fd                	li	a5,-1
    8000401a:	b7d5                	j	80003ffe <dirlink+0x84>
      panic("dirlink read");
    8000401c:	00004517          	auipc	a0,0x4
    80004020:	76c50513          	addi	a0,a0,1900 # 80008788 <sysnames+0x2c8>
    80004024:	ffffc097          	auipc	ra,0xffffc
    80004028:	550080e7          	jalr	1360(ra) # 80000574 <panic>
    panic("dirlink");
    8000402c:	00005517          	auipc	a0,0x5
    80004030:	87450513          	addi	a0,a0,-1932 # 800088a0 <sysnames+0x3e0>
    80004034:	ffffc097          	auipc	ra,0xffffc
    80004038:	540080e7          	jalr	1344(ra) # 80000574 <panic>

000000008000403c <namei>:

struct inode*
namei(char *path)
{
    8000403c:	1101                	addi	sp,sp,-32
    8000403e:	ec06                	sd	ra,24(sp)
    80004040:	e822                	sd	s0,16(sp)
    80004042:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004044:	fe040613          	addi	a2,s0,-32
    80004048:	4581                	li	a1,0
    8000404a:	00000097          	auipc	ra,0x0
    8000404e:	dc8080e7          	jalr	-568(ra) # 80003e12 <namex>
}
    80004052:	60e2                	ld	ra,24(sp)
    80004054:	6442                	ld	s0,16(sp)
    80004056:	6105                	addi	sp,sp,32
    80004058:	8082                	ret

000000008000405a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000405a:	1141                	addi	sp,sp,-16
    8000405c:	e406                	sd	ra,8(sp)
    8000405e:	e022                	sd	s0,0(sp)
    80004060:	0800                	addi	s0,sp,16
  return namex(path, 1, name);
    80004062:	862e                	mv	a2,a1
    80004064:	4585                	li	a1,1
    80004066:	00000097          	auipc	ra,0x0
    8000406a:	dac080e7          	jalr	-596(ra) # 80003e12 <namex>
}
    8000406e:	60a2                	ld	ra,8(sp)
    80004070:	6402                	ld	s0,0(sp)
    80004072:	0141                	addi	sp,sp,16
    80004074:	8082                	ret

0000000080004076 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004076:	1101                	addi	sp,sp,-32
    80004078:	ec06                	sd	ra,24(sp)
    8000407a:	e822                	sd	s0,16(sp)
    8000407c:	e426                	sd	s1,8(sp)
    8000407e:	e04a                	sd	s2,0(sp)
    80004080:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004082:	0001e917          	auipc	s2,0x1e
    80004086:	a8690913          	addi	s2,s2,-1402 # 80021b08 <log>
    8000408a:	01892583          	lw	a1,24(s2)
    8000408e:	02892503          	lw	a0,40(s2)
    80004092:	fffff097          	auipc	ra,0xfffff
    80004096:	fa8080e7          	jalr	-88(ra) # 8000303a <bread>
    8000409a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000409c:	02c92683          	lw	a3,44(s2)
    800040a0:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040a2:	02d05763          	blez	a3,800040d0 <write_head+0x5a>
    800040a6:	0001e797          	auipc	a5,0x1e
    800040aa:	a9278793          	addi	a5,a5,-1390 # 80021b38 <log+0x30>
    800040ae:	05c50713          	addi	a4,a0,92
    800040b2:	36fd                	addiw	a3,a3,-1
    800040b4:	1682                	slli	a3,a3,0x20
    800040b6:	9281                	srli	a3,a3,0x20
    800040b8:	068a                	slli	a3,a3,0x2
    800040ba:	0001e617          	auipc	a2,0x1e
    800040be:	a8260613          	addi	a2,a2,-1406 # 80021b3c <log+0x34>
    800040c2:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800040c4:	4390                	lw	a2,0(a5)
    800040c6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040c8:	0791                	addi	a5,a5,4
    800040ca:	0711                	addi	a4,a4,4
    800040cc:	fed79ce3          	bne	a5,a3,800040c4 <write_head+0x4e>
  }
  bwrite(buf);
    800040d0:	8526                	mv	a0,s1
    800040d2:	fffff097          	auipc	ra,0xfffff
    800040d6:	06c080e7          	jalr	108(ra) # 8000313e <bwrite>
  brelse(buf);
    800040da:	8526                	mv	a0,s1
    800040dc:	fffff097          	auipc	ra,0xfffff
    800040e0:	0a0080e7          	jalr	160(ra) # 8000317c <brelse>
}
    800040e4:	60e2                	ld	ra,24(sp)
    800040e6:	6442                	ld	s0,16(sp)
    800040e8:	64a2                	ld	s1,8(sp)
    800040ea:	6902                	ld	s2,0(sp)
    800040ec:	6105                	addi	sp,sp,32
    800040ee:	8082                	ret

00000000800040f0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040f0:	0001e797          	auipc	a5,0x1e
    800040f4:	a1878793          	addi	a5,a5,-1512 # 80021b08 <log>
    800040f8:	57dc                	lw	a5,44(a5)
    800040fa:	0af05663          	blez	a5,800041a6 <install_trans+0xb6>
{
    800040fe:	7139                	addi	sp,sp,-64
    80004100:	fc06                	sd	ra,56(sp)
    80004102:	f822                	sd	s0,48(sp)
    80004104:	f426                	sd	s1,40(sp)
    80004106:	f04a                	sd	s2,32(sp)
    80004108:	ec4e                	sd	s3,24(sp)
    8000410a:	e852                	sd	s4,16(sp)
    8000410c:	e456                	sd	s5,8(sp)
    8000410e:	0080                	addi	s0,sp,64
    80004110:	0001ea17          	auipc	s4,0x1e
    80004114:	a28a0a13          	addi	s4,s4,-1496 # 80021b38 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004118:	4981                	li	s3,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000411a:	0001e917          	auipc	s2,0x1e
    8000411e:	9ee90913          	addi	s2,s2,-1554 # 80021b08 <log>
    80004122:	01892583          	lw	a1,24(s2)
    80004126:	013585bb          	addw	a1,a1,s3
    8000412a:	2585                	addiw	a1,a1,1
    8000412c:	02892503          	lw	a0,40(s2)
    80004130:	fffff097          	auipc	ra,0xfffff
    80004134:	f0a080e7          	jalr	-246(ra) # 8000303a <bread>
    80004138:	8aaa                	mv	s5,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000413a:	000a2583          	lw	a1,0(s4)
    8000413e:	02892503          	lw	a0,40(s2)
    80004142:	fffff097          	auipc	ra,0xfffff
    80004146:	ef8080e7          	jalr	-264(ra) # 8000303a <bread>
    8000414a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000414c:	40000613          	li	a2,1024
    80004150:	058a8593          	addi	a1,s5,88
    80004154:	05850513          	addi	a0,a0,88
    80004158:	ffffd097          	auipc	ra,0xffffd
    8000415c:	cbc080e7          	jalr	-836(ra) # 80000e14 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004160:	8526                	mv	a0,s1
    80004162:	fffff097          	auipc	ra,0xfffff
    80004166:	fdc080e7          	jalr	-36(ra) # 8000313e <bwrite>
    bunpin(dbuf);
    8000416a:	8526                	mv	a0,s1
    8000416c:	fffff097          	auipc	ra,0xfffff
    80004170:	0ea080e7          	jalr	234(ra) # 80003256 <bunpin>
    brelse(lbuf);
    80004174:	8556                	mv	a0,s5
    80004176:	fffff097          	auipc	ra,0xfffff
    8000417a:	006080e7          	jalr	6(ra) # 8000317c <brelse>
    brelse(dbuf);
    8000417e:	8526                	mv	a0,s1
    80004180:	fffff097          	auipc	ra,0xfffff
    80004184:	ffc080e7          	jalr	-4(ra) # 8000317c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004188:	2985                	addiw	s3,s3,1
    8000418a:	0a11                	addi	s4,s4,4
    8000418c:	02c92783          	lw	a5,44(s2)
    80004190:	f8f9c9e3          	blt	s3,a5,80004122 <install_trans+0x32>
}
    80004194:	70e2                	ld	ra,56(sp)
    80004196:	7442                	ld	s0,48(sp)
    80004198:	74a2                	ld	s1,40(sp)
    8000419a:	7902                	ld	s2,32(sp)
    8000419c:	69e2                	ld	s3,24(sp)
    8000419e:	6a42                	ld	s4,16(sp)
    800041a0:	6aa2                	ld	s5,8(sp)
    800041a2:	6121                	addi	sp,sp,64
    800041a4:	8082                	ret
    800041a6:	8082                	ret

00000000800041a8 <initlog>:
{
    800041a8:	7179                	addi	sp,sp,-48
    800041aa:	f406                	sd	ra,40(sp)
    800041ac:	f022                	sd	s0,32(sp)
    800041ae:	ec26                	sd	s1,24(sp)
    800041b0:	e84a                	sd	s2,16(sp)
    800041b2:	e44e                	sd	s3,8(sp)
    800041b4:	1800                	addi	s0,sp,48
    800041b6:	892a                	mv	s2,a0
    800041b8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041ba:	0001e497          	auipc	s1,0x1e
    800041be:	94e48493          	addi	s1,s1,-1714 # 80021b08 <log>
    800041c2:	00004597          	auipc	a1,0x4
    800041c6:	5d658593          	addi	a1,a1,1494 # 80008798 <sysnames+0x2d8>
    800041ca:	8526                	mv	a0,s1
    800041cc:	ffffd097          	auipc	ra,0xffffd
    800041d0:	a50080e7          	jalr	-1456(ra) # 80000c1c <initlock>
  log.start = sb->logstart;
    800041d4:	0149a583          	lw	a1,20(s3)
    800041d8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041da:	0109a783          	lw	a5,16(s3)
    800041de:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041e0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041e4:	854a                	mv	a0,s2
    800041e6:	fffff097          	auipc	ra,0xfffff
    800041ea:	e54080e7          	jalr	-428(ra) # 8000303a <bread>
  log.lh.n = lh->n;
    800041ee:	4d3c                	lw	a5,88(a0)
    800041f0:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041f2:	02f05563          	blez	a5,8000421c <initlog+0x74>
    800041f6:	05c50713          	addi	a4,a0,92
    800041fa:	0001e697          	auipc	a3,0x1e
    800041fe:	93e68693          	addi	a3,a3,-1730 # 80021b38 <log+0x30>
    80004202:	37fd                	addiw	a5,a5,-1
    80004204:	1782                	slli	a5,a5,0x20
    80004206:	9381                	srli	a5,a5,0x20
    80004208:	078a                	slli	a5,a5,0x2
    8000420a:	06050613          	addi	a2,a0,96
    8000420e:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004210:	4310                	lw	a2,0(a4)
    80004212:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004214:	0711                	addi	a4,a4,4
    80004216:	0691                	addi	a3,a3,4
    80004218:	fef71ce3          	bne	a4,a5,80004210 <initlog+0x68>
  brelse(buf);
    8000421c:	fffff097          	auipc	ra,0xfffff
    80004220:	f60080e7          	jalr	-160(ra) # 8000317c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80004224:	00000097          	auipc	ra,0x0
    80004228:	ecc080e7          	jalr	-308(ra) # 800040f0 <install_trans>
  log.lh.n = 0;
    8000422c:	0001e797          	auipc	a5,0x1e
    80004230:	9007a423          	sw	zero,-1784(a5) # 80021b34 <log+0x2c>
  write_head(); // clear the log
    80004234:	00000097          	auipc	ra,0x0
    80004238:	e42080e7          	jalr	-446(ra) # 80004076 <write_head>
}
    8000423c:	70a2                	ld	ra,40(sp)
    8000423e:	7402                	ld	s0,32(sp)
    80004240:	64e2                	ld	s1,24(sp)
    80004242:	6942                	ld	s2,16(sp)
    80004244:	69a2                	ld	s3,8(sp)
    80004246:	6145                	addi	sp,sp,48
    80004248:	8082                	ret

000000008000424a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000424a:	1101                	addi	sp,sp,-32
    8000424c:	ec06                	sd	ra,24(sp)
    8000424e:	e822                	sd	s0,16(sp)
    80004250:	e426                	sd	s1,8(sp)
    80004252:	e04a                	sd	s2,0(sp)
    80004254:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004256:	0001e517          	auipc	a0,0x1e
    8000425a:	8b250513          	addi	a0,a0,-1870 # 80021b08 <log>
    8000425e:	ffffd097          	auipc	ra,0xffffd
    80004262:	a4e080e7          	jalr	-1458(ra) # 80000cac <acquire>
  while(1){
    if(log.committing){
    80004266:	0001e497          	auipc	s1,0x1e
    8000426a:	8a248493          	addi	s1,s1,-1886 # 80021b08 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000426e:	4979                	li	s2,30
    80004270:	a039                	j	8000427e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004272:	85a6                	mv	a1,s1
    80004274:	8526                	mv	a0,s1
    80004276:	ffffe097          	auipc	ra,0xffffe
    8000427a:	066080e7          	jalr	102(ra) # 800022dc <sleep>
    if(log.committing){
    8000427e:	50dc                	lw	a5,36(s1)
    80004280:	fbed                	bnez	a5,80004272 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004282:	509c                	lw	a5,32(s1)
    80004284:	0017871b          	addiw	a4,a5,1
    80004288:	0007069b          	sext.w	a3,a4
    8000428c:	0027179b          	slliw	a5,a4,0x2
    80004290:	9fb9                	addw	a5,a5,a4
    80004292:	0017979b          	slliw	a5,a5,0x1
    80004296:	54d8                	lw	a4,44(s1)
    80004298:	9fb9                	addw	a5,a5,a4
    8000429a:	00f95963          	ble	a5,s2,800042ac <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000429e:	85a6                	mv	a1,s1
    800042a0:	8526                	mv	a0,s1
    800042a2:	ffffe097          	auipc	ra,0xffffe
    800042a6:	03a080e7          	jalr	58(ra) # 800022dc <sleep>
    800042aa:	bfd1                	j	8000427e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800042ac:	0001e517          	auipc	a0,0x1e
    800042b0:	85c50513          	addi	a0,a0,-1956 # 80021b08 <log>
    800042b4:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800042b6:	ffffd097          	auipc	ra,0xffffd
    800042ba:	aaa080e7          	jalr	-1366(ra) # 80000d60 <release>
      break;
    }
  }
}
    800042be:	60e2                	ld	ra,24(sp)
    800042c0:	6442                	ld	s0,16(sp)
    800042c2:	64a2                	ld	s1,8(sp)
    800042c4:	6902                	ld	s2,0(sp)
    800042c6:	6105                	addi	sp,sp,32
    800042c8:	8082                	ret

00000000800042ca <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042ca:	7139                	addi	sp,sp,-64
    800042cc:	fc06                	sd	ra,56(sp)
    800042ce:	f822                	sd	s0,48(sp)
    800042d0:	f426                	sd	s1,40(sp)
    800042d2:	f04a                	sd	s2,32(sp)
    800042d4:	ec4e                	sd	s3,24(sp)
    800042d6:	e852                	sd	s4,16(sp)
    800042d8:	e456                	sd	s5,8(sp)
    800042da:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042dc:	0001e917          	auipc	s2,0x1e
    800042e0:	82c90913          	addi	s2,s2,-2004 # 80021b08 <log>
    800042e4:	854a                	mv	a0,s2
    800042e6:	ffffd097          	auipc	ra,0xffffd
    800042ea:	9c6080e7          	jalr	-1594(ra) # 80000cac <acquire>
  log.outstanding -= 1;
    800042ee:	02092783          	lw	a5,32(s2)
    800042f2:	37fd                	addiw	a5,a5,-1
    800042f4:	0007849b          	sext.w	s1,a5
    800042f8:	02f92023          	sw	a5,32(s2)
  if(log.committing)
    800042fc:	02492783          	lw	a5,36(s2)
    80004300:	eba1                	bnez	a5,80004350 <end_op+0x86>
    panic("log.committing");
  if(log.outstanding == 0){
    80004302:	ecb9                	bnez	s1,80004360 <end_op+0x96>
    do_commit = 1;
    log.committing = 1;
    80004304:	0001e917          	auipc	s2,0x1e
    80004308:	80490913          	addi	s2,s2,-2044 # 80021b08 <log>
    8000430c:	4785                	li	a5,1
    8000430e:	02f92223          	sw	a5,36(s2)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004312:	854a                	mv	a0,s2
    80004314:	ffffd097          	auipc	ra,0xffffd
    80004318:	a4c080e7          	jalr	-1460(ra) # 80000d60 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000431c:	02c92783          	lw	a5,44(s2)
    80004320:	06f04763          	bgtz	a5,8000438e <end_op+0xc4>
    acquire(&log.lock);
    80004324:	0001d497          	auipc	s1,0x1d
    80004328:	7e448493          	addi	s1,s1,2020 # 80021b08 <log>
    8000432c:	8526                	mv	a0,s1
    8000432e:	ffffd097          	auipc	ra,0xffffd
    80004332:	97e080e7          	jalr	-1666(ra) # 80000cac <acquire>
    log.committing = 0;
    80004336:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000433a:	8526                	mv	a0,s1
    8000433c:	ffffe097          	auipc	ra,0xffffe
    80004340:	126080e7          	jalr	294(ra) # 80002462 <wakeup>
    release(&log.lock);
    80004344:	8526                	mv	a0,s1
    80004346:	ffffd097          	auipc	ra,0xffffd
    8000434a:	a1a080e7          	jalr	-1510(ra) # 80000d60 <release>
}
    8000434e:	a03d                	j	8000437c <end_op+0xb2>
    panic("log.committing");
    80004350:	00004517          	auipc	a0,0x4
    80004354:	45050513          	addi	a0,a0,1104 # 800087a0 <sysnames+0x2e0>
    80004358:	ffffc097          	auipc	ra,0xffffc
    8000435c:	21c080e7          	jalr	540(ra) # 80000574 <panic>
    wakeup(&log);
    80004360:	0001d497          	auipc	s1,0x1d
    80004364:	7a848493          	addi	s1,s1,1960 # 80021b08 <log>
    80004368:	8526                	mv	a0,s1
    8000436a:	ffffe097          	auipc	ra,0xffffe
    8000436e:	0f8080e7          	jalr	248(ra) # 80002462 <wakeup>
  release(&log.lock);
    80004372:	8526                	mv	a0,s1
    80004374:	ffffd097          	auipc	ra,0xffffd
    80004378:	9ec080e7          	jalr	-1556(ra) # 80000d60 <release>
}
    8000437c:	70e2                	ld	ra,56(sp)
    8000437e:	7442                	ld	s0,48(sp)
    80004380:	74a2                	ld	s1,40(sp)
    80004382:	7902                	ld	s2,32(sp)
    80004384:	69e2                	ld	s3,24(sp)
    80004386:	6a42                	ld	s4,16(sp)
    80004388:	6aa2                	ld	s5,8(sp)
    8000438a:	6121                	addi	sp,sp,64
    8000438c:	8082                	ret
    8000438e:	0001da17          	auipc	s4,0x1d
    80004392:	7aaa0a13          	addi	s4,s4,1962 # 80021b38 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004396:	0001d917          	auipc	s2,0x1d
    8000439a:	77290913          	addi	s2,s2,1906 # 80021b08 <log>
    8000439e:	01892583          	lw	a1,24(s2)
    800043a2:	9da5                	addw	a1,a1,s1
    800043a4:	2585                	addiw	a1,a1,1
    800043a6:	02892503          	lw	a0,40(s2)
    800043aa:	fffff097          	auipc	ra,0xfffff
    800043ae:	c90080e7          	jalr	-880(ra) # 8000303a <bread>
    800043b2:	89aa                	mv	s3,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043b4:	000a2583          	lw	a1,0(s4)
    800043b8:	02892503          	lw	a0,40(s2)
    800043bc:	fffff097          	auipc	ra,0xfffff
    800043c0:	c7e080e7          	jalr	-898(ra) # 8000303a <bread>
    800043c4:	8aaa                	mv	s5,a0
    memmove(to->data, from->data, BSIZE);
    800043c6:	40000613          	li	a2,1024
    800043ca:	05850593          	addi	a1,a0,88
    800043ce:	05898513          	addi	a0,s3,88
    800043d2:	ffffd097          	auipc	ra,0xffffd
    800043d6:	a42080e7          	jalr	-1470(ra) # 80000e14 <memmove>
    bwrite(to);  // write the log
    800043da:	854e                	mv	a0,s3
    800043dc:	fffff097          	auipc	ra,0xfffff
    800043e0:	d62080e7          	jalr	-670(ra) # 8000313e <bwrite>
    brelse(from);
    800043e4:	8556                	mv	a0,s5
    800043e6:	fffff097          	auipc	ra,0xfffff
    800043ea:	d96080e7          	jalr	-618(ra) # 8000317c <brelse>
    brelse(to);
    800043ee:	854e                	mv	a0,s3
    800043f0:	fffff097          	auipc	ra,0xfffff
    800043f4:	d8c080e7          	jalr	-628(ra) # 8000317c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043f8:	2485                	addiw	s1,s1,1
    800043fa:	0a11                	addi	s4,s4,4
    800043fc:	02c92783          	lw	a5,44(s2)
    80004400:	f8f4cfe3          	blt	s1,a5,8000439e <end_op+0xd4>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004404:	00000097          	auipc	ra,0x0
    80004408:	c72080e7          	jalr	-910(ra) # 80004076 <write_head>
    install_trans(); // Now install writes to home locations
    8000440c:	00000097          	auipc	ra,0x0
    80004410:	ce4080e7          	jalr	-796(ra) # 800040f0 <install_trans>
    log.lh.n = 0;
    80004414:	0001d797          	auipc	a5,0x1d
    80004418:	7207a023          	sw	zero,1824(a5) # 80021b34 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000441c:	00000097          	auipc	ra,0x0
    80004420:	c5a080e7          	jalr	-934(ra) # 80004076 <write_head>
    80004424:	b701                	j	80004324 <end_op+0x5a>

0000000080004426 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004426:	1101                	addi	sp,sp,-32
    80004428:	ec06                	sd	ra,24(sp)
    8000442a:	e822                	sd	s0,16(sp)
    8000442c:	e426                	sd	s1,8(sp)
    8000442e:	e04a                	sd	s2,0(sp)
    80004430:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004432:	0001d797          	auipc	a5,0x1d
    80004436:	6d678793          	addi	a5,a5,1750 # 80021b08 <log>
    8000443a:	57d8                	lw	a4,44(a5)
    8000443c:	47f5                	li	a5,29
    8000443e:	08e7c563          	blt	a5,a4,800044c8 <log_write+0xa2>
    80004442:	892a                	mv	s2,a0
    80004444:	0001d797          	auipc	a5,0x1d
    80004448:	6c478793          	addi	a5,a5,1732 # 80021b08 <log>
    8000444c:	4fdc                	lw	a5,28(a5)
    8000444e:	37fd                	addiw	a5,a5,-1
    80004450:	06f75c63          	ble	a5,a4,800044c8 <log_write+0xa2>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004454:	0001d797          	auipc	a5,0x1d
    80004458:	6b478793          	addi	a5,a5,1716 # 80021b08 <log>
    8000445c:	539c                	lw	a5,32(a5)
    8000445e:	06f05d63          	blez	a5,800044d8 <log_write+0xb2>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004462:	0001d497          	auipc	s1,0x1d
    80004466:	6a648493          	addi	s1,s1,1702 # 80021b08 <log>
    8000446a:	8526                	mv	a0,s1
    8000446c:	ffffd097          	auipc	ra,0xffffd
    80004470:	840080e7          	jalr	-1984(ra) # 80000cac <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004474:	54d0                	lw	a2,44(s1)
    80004476:	0ac05063          	blez	a2,80004516 <log_write+0xf0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000447a:	00c92583          	lw	a1,12(s2)
    8000447e:	589c                	lw	a5,48(s1)
    80004480:	0ab78363          	beq	a5,a1,80004526 <log_write+0x100>
    80004484:	0001d717          	auipc	a4,0x1d
    80004488:	6b870713          	addi	a4,a4,1720 # 80021b3c <log+0x34>
  for (i = 0; i < log.lh.n; i++) {
    8000448c:	4781                	li	a5,0
    8000448e:	2785                	addiw	a5,a5,1
    80004490:	04c78c63          	beq	a5,a2,800044e8 <log_write+0xc2>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004494:	4314                	lw	a3,0(a4)
    80004496:	0711                	addi	a4,a4,4
    80004498:	feb69be3          	bne	a3,a1,8000448e <log_write+0x68>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000449c:	07a1                	addi	a5,a5,8
    8000449e:	078a                	slli	a5,a5,0x2
    800044a0:	0001d717          	auipc	a4,0x1d
    800044a4:	66870713          	addi	a4,a4,1640 # 80021b08 <log>
    800044a8:	97ba                	add	a5,a5,a4
    800044aa:	cb8c                	sw	a1,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    log.lh.n++;
  }
  release(&log.lock);
    800044ac:	0001d517          	auipc	a0,0x1d
    800044b0:	65c50513          	addi	a0,a0,1628 # 80021b08 <log>
    800044b4:	ffffd097          	auipc	ra,0xffffd
    800044b8:	8ac080e7          	jalr	-1876(ra) # 80000d60 <release>
}
    800044bc:	60e2                	ld	ra,24(sp)
    800044be:	6442                	ld	s0,16(sp)
    800044c0:	64a2                	ld	s1,8(sp)
    800044c2:	6902                	ld	s2,0(sp)
    800044c4:	6105                	addi	sp,sp,32
    800044c6:	8082                	ret
    panic("too big a transaction");
    800044c8:	00004517          	auipc	a0,0x4
    800044cc:	2e850513          	addi	a0,a0,744 # 800087b0 <sysnames+0x2f0>
    800044d0:	ffffc097          	auipc	ra,0xffffc
    800044d4:	0a4080e7          	jalr	164(ra) # 80000574 <panic>
    panic("log_write outside of trans");
    800044d8:	00004517          	auipc	a0,0x4
    800044dc:	2f050513          	addi	a0,a0,752 # 800087c8 <sysnames+0x308>
    800044e0:	ffffc097          	auipc	ra,0xffffc
    800044e4:	094080e7          	jalr	148(ra) # 80000574 <panic>
  log.lh.block[i] = b->blockno;
    800044e8:	0621                	addi	a2,a2,8
    800044ea:	060a                	slli	a2,a2,0x2
    800044ec:	0001d797          	auipc	a5,0x1d
    800044f0:	61c78793          	addi	a5,a5,1564 # 80021b08 <log>
    800044f4:	963e                	add	a2,a2,a5
    800044f6:	00c92783          	lw	a5,12(s2)
    800044fa:	ca1c                	sw	a5,16(a2)
    bpin(b);
    800044fc:	854a                	mv	a0,s2
    800044fe:	fffff097          	auipc	ra,0xfffff
    80004502:	d1c080e7          	jalr	-740(ra) # 8000321a <bpin>
    log.lh.n++;
    80004506:	0001d717          	auipc	a4,0x1d
    8000450a:	60270713          	addi	a4,a4,1538 # 80021b08 <log>
    8000450e:	575c                	lw	a5,44(a4)
    80004510:	2785                	addiw	a5,a5,1
    80004512:	d75c                	sw	a5,44(a4)
    80004514:	bf61                	j	800044ac <log_write+0x86>
  log.lh.block[i] = b->blockno;
    80004516:	00c92783          	lw	a5,12(s2)
    8000451a:	0001d717          	auipc	a4,0x1d
    8000451e:	60f72f23          	sw	a5,1566(a4) # 80021b38 <log+0x30>
  if (i == log.lh.n) {  // Add new block to log?
    80004522:	f649                	bnez	a2,800044ac <log_write+0x86>
    80004524:	bfe1                	j	800044fc <log_write+0xd6>
  for (i = 0; i < log.lh.n; i++) {
    80004526:	4781                	li	a5,0
    80004528:	bf95                	j	8000449c <log_write+0x76>

000000008000452a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000452a:	1101                	addi	sp,sp,-32
    8000452c:	ec06                	sd	ra,24(sp)
    8000452e:	e822                	sd	s0,16(sp)
    80004530:	e426                	sd	s1,8(sp)
    80004532:	e04a                	sd	s2,0(sp)
    80004534:	1000                	addi	s0,sp,32
    80004536:	84aa                	mv	s1,a0
    80004538:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000453a:	00004597          	auipc	a1,0x4
    8000453e:	2ae58593          	addi	a1,a1,686 # 800087e8 <sysnames+0x328>
    80004542:	0521                	addi	a0,a0,8
    80004544:	ffffc097          	auipc	ra,0xffffc
    80004548:	6d8080e7          	jalr	1752(ra) # 80000c1c <initlock>
  lk->name = name;
    8000454c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004550:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004554:	0204a423          	sw	zero,40(s1)
}
    80004558:	60e2                	ld	ra,24(sp)
    8000455a:	6442                	ld	s0,16(sp)
    8000455c:	64a2                	ld	s1,8(sp)
    8000455e:	6902                	ld	s2,0(sp)
    80004560:	6105                	addi	sp,sp,32
    80004562:	8082                	ret

0000000080004564 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004564:	1101                	addi	sp,sp,-32
    80004566:	ec06                	sd	ra,24(sp)
    80004568:	e822                	sd	s0,16(sp)
    8000456a:	e426                	sd	s1,8(sp)
    8000456c:	e04a                	sd	s2,0(sp)
    8000456e:	1000                	addi	s0,sp,32
    80004570:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004572:	00850913          	addi	s2,a0,8
    80004576:	854a                	mv	a0,s2
    80004578:	ffffc097          	auipc	ra,0xffffc
    8000457c:	734080e7          	jalr	1844(ra) # 80000cac <acquire>
  while (lk->locked) {
    80004580:	409c                	lw	a5,0(s1)
    80004582:	cb89                	beqz	a5,80004594 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004584:	85ca                	mv	a1,s2
    80004586:	8526                	mv	a0,s1
    80004588:	ffffe097          	auipc	ra,0xffffe
    8000458c:	d54080e7          	jalr	-684(ra) # 800022dc <sleep>
  while (lk->locked) {
    80004590:	409c                	lw	a5,0(s1)
    80004592:	fbed                	bnez	a5,80004584 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004594:	4785                	li	a5,1
    80004596:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004598:	ffffd097          	auipc	ra,0xffffd
    8000459c:	522080e7          	jalr	1314(ra) # 80001aba <myproc>
    800045a0:	5d1c                	lw	a5,56(a0)
    800045a2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800045a4:	854a                	mv	a0,s2
    800045a6:	ffffc097          	auipc	ra,0xffffc
    800045aa:	7ba080e7          	jalr	1978(ra) # 80000d60 <release>
}
    800045ae:	60e2                	ld	ra,24(sp)
    800045b0:	6442                	ld	s0,16(sp)
    800045b2:	64a2                	ld	s1,8(sp)
    800045b4:	6902                	ld	s2,0(sp)
    800045b6:	6105                	addi	sp,sp,32
    800045b8:	8082                	ret

00000000800045ba <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045ba:	1101                	addi	sp,sp,-32
    800045bc:	ec06                	sd	ra,24(sp)
    800045be:	e822                	sd	s0,16(sp)
    800045c0:	e426                	sd	s1,8(sp)
    800045c2:	e04a                	sd	s2,0(sp)
    800045c4:	1000                	addi	s0,sp,32
    800045c6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045c8:	00850913          	addi	s2,a0,8
    800045cc:	854a                	mv	a0,s2
    800045ce:	ffffc097          	auipc	ra,0xffffc
    800045d2:	6de080e7          	jalr	1758(ra) # 80000cac <acquire>
  lk->locked = 0;
    800045d6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045da:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800045de:	8526                	mv	a0,s1
    800045e0:	ffffe097          	auipc	ra,0xffffe
    800045e4:	e82080e7          	jalr	-382(ra) # 80002462 <wakeup>
  release(&lk->lk);
    800045e8:	854a                	mv	a0,s2
    800045ea:	ffffc097          	auipc	ra,0xffffc
    800045ee:	776080e7          	jalr	1910(ra) # 80000d60 <release>
}
    800045f2:	60e2                	ld	ra,24(sp)
    800045f4:	6442                	ld	s0,16(sp)
    800045f6:	64a2                	ld	s1,8(sp)
    800045f8:	6902                	ld	s2,0(sp)
    800045fa:	6105                	addi	sp,sp,32
    800045fc:	8082                	ret

00000000800045fe <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045fe:	7179                	addi	sp,sp,-48
    80004600:	f406                	sd	ra,40(sp)
    80004602:	f022                	sd	s0,32(sp)
    80004604:	ec26                	sd	s1,24(sp)
    80004606:	e84a                	sd	s2,16(sp)
    80004608:	e44e                	sd	s3,8(sp)
    8000460a:	1800                	addi	s0,sp,48
    8000460c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000460e:	00850913          	addi	s2,a0,8
    80004612:	854a                	mv	a0,s2
    80004614:	ffffc097          	auipc	ra,0xffffc
    80004618:	698080e7          	jalr	1688(ra) # 80000cac <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000461c:	409c                	lw	a5,0(s1)
    8000461e:	ef99                	bnez	a5,8000463c <holdingsleep+0x3e>
    80004620:	4481                	li	s1,0
  release(&lk->lk);
    80004622:	854a                	mv	a0,s2
    80004624:	ffffc097          	auipc	ra,0xffffc
    80004628:	73c080e7          	jalr	1852(ra) # 80000d60 <release>
  return r;
}
    8000462c:	8526                	mv	a0,s1
    8000462e:	70a2                	ld	ra,40(sp)
    80004630:	7402                	ld	s0,32(sp)
    80004632:	64e2                	ld	s1,24(sp)
    80004634:	6942                	ld	s2,16(sp)
    80004636:	69a2                	ld	s3,8(sp)
    80004638:	6145                	addi	sp,sp,48
    8000463a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000463c:	0284a983          	lw	s3,40(s1)
    80004640:	ffffd097          	auipc	ra,0xffffd
    80004644:	47a080e7          	jalr	1146(ra) # 80001aba <myproc>
    80004648:	5d04                	lw	s1,56(a0)
    8000464a:	413484b3          	sub	s1,s1,s3
    8000464e:	0014b493          	seqz	s1,s1
    80004652:	bfc1                	j	80004622 <holdingsleep+0x24>

0000000080004654 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004654:	1141                	addi	sp,sp,-16
    80004656:	e406                	sd	ra,8(sp)
    80004658:	e022                	sd	s0,0(sp)
    8000465a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000465c:	00004597          	auipc	a1,0x4
    80004660:	19c58593          	addi	a1,a1,412 # 800087f8 <sysnames+0x338>
    80004664:	0001d517          	auipc	a0,0x1d
    80004668:	5ec50513          	addi	a0,a0,1516 # 80021c50 <ftable>
    8000466c:	ffffc097          	auipc	ra,0xffffc
    80004670:	5b0080e7          	jalr	1456(ra) # 80000c1c <initlock>
}
    80004674:	60a2                	ld	ra,8(sp)
    80004676:	6402                	ld	s0,0(sp)
    80004678:	0141                	addi	sp,sp,16
    8000467a:	8082                	ret

000000008000467c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000467c:	1101                	addi	sp,sp,-32
    8000467e:	ec06                	sd	ra,24(sp)
    80004680:	e822                	sd	s0,16(sp)
    80004682:	e426                	sd	s1,8(sp)
    80004684:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004686:	0001d517          	auipc	a0,0x1d
    8000468a:	5ca50513          	addi	a0,a0,1482 # 80021c50 <ftable>
    8000468e:	ffffc097          	auipc	ra,0xffffc
    80004692:	61e080e7          	jalr	1566(ra) # 80000cac <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
    80004696:	0001d797          	auipc	a5,0x1d
    8000469a:	5ba78793          	addi	a5,a5,1466 # 80021c50 <ftable>
    8000469e:	4fdc                	lw	a5,28(a5)
    800046a0:	cb8d                	beqz	a5,800046d2 <filealloc+0x56>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046a2:	0001d497          	auipc	s1,0x1d
    800046a6:	5ee48493          	addi	s1,s1,1518 # 80021c90 <ftable+0x40>
    800046aa:	0001e717          	auipc	a4,0x1e
    800046ae:	55e70713          	addi	a4,a4,1374 # 80022c08 <ftable+0xfb8>
    if(f->ref == 0){
    800046b2:	40dc                	lw	a5,4(s1)
    800046b4:	c39d                	beqz	a5,800046da <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046b6:	02848493          	addi	s1,s1,40
    800046ba:	fee49ce3          	bne	s1,a4,800046b2 <filealloc+0x36>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046be:	0001d517          	auipc	a0,0x1d
    800046c2:	59250513          	addi	a0,a0,1426 # 80021c50 <ftable>
    800046c6:	ffffc097          	auipc	ra,0xffffc
    800046ca:	69a080e7          	jalr	1690(ra) # 80000d60 <release>
  return 0;
    800046ce:	4481                	li	s1,0
    800046d0:	a839                	j	800046ee <filealloc+0x72>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046d2:	0001d497          	auipc	s1,0x1d
    800046d6:	59648493          	addi	s1,s1,1430 # 80021c68 <ftable+0x18>
      f->ref = 1;
    800046da:	4785                	li	a5,1
    800046dc:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046de:	0001d517          	auipc	a0,0x1d
    800046e2:	57250513          	addi	a0,a0,1394 # 80021c50 <ftable>
    800046e6:	ffffc097          	auipc	ra,0xffffc
    800046ea:	67a080e7          	jalr	1658(ra) # 80000d60 <release>
}
    800046ee:	8526                	mv	a0,s1
    800046f0:	60e2                	ld	ra,24(sp)
    800046f2:	6442                	ld	s0,16(sp)
    800046f4:	64a2                	ld	s1,8(sp)
    800046f6:	6105                	addi	sp,sp,32
    800046f8:	8082                	ret

00000000800046fa <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046fa:	1101                	addi	sp,sp,-32
    800046fc:	ec06                	sd	ra,24(sp)
    800046fe:	e822                	sd	s0,16(sp)
    80004700:	e426                	sd	s1,8(sp)
    80004702:	1000                	addi	s0,sp,32
    80004704:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004706:	0001d517          	auipc	a0,0x1d
    8000470a:	54a50513          	addi	a0,a0,1354 # 80021c50 <ftable>
    8000470e:	ffffc097          	auipc	ra,0xffffc
    80004712:	59e080e7          	jalr	1438(ra) # 80000cac <acquire>
  if(f->ref < 1)
    80004716:	40dc                	lw	a5,4(s1)
    80004718:	02f05263          	blez	a5,8000473c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000471c:	2785                	addiw	a5,a5,1
    8000471e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004720:	0001d517          	auipc	a0,0x1d
    80004724:	53050513          	addi	a0,a0,1328 # 80021c50 <ftable>
    80004728:	ffffc097          	auipc	ra,0xffffc
    8000472c:	638080e7          	jalr	1592(ra) # 80000d60 <release>
  return f;
}
    80004730:	8526                	mv	a0,s1
    80004732:	60e2                	ld	ra,24(sp)
    80004734:	6442                	ld	s0,16(sp)
    80004736:	64a2                	ld	s1,8(sp)
    80004738:	6105                	addi	sp,sp,32
    8000473a:	8082                	ret
    panic("filedup");
    8000473c:	00004517          	auipc	a0,0x4
    80004740:	0c450513          	addi	a0,a0,196 # 80008800 <sysnames+0x340>
    80004744:	ffffc097          	auipc	ra,0xffffc
    80004748:	e30080e7          	jalr	-464(ra) # 80000574 <panic>

000000008000474c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000474c:	7139                	addi	sp,sp,-64
    8000474e:	fc06                	sd	ra,56(sp)
    80004750:	f822                	sd	s0,48(sp)
    80004752:	f426                	sd	s1,40(sp)
    80004754:	f04a                	sd	s2,32(sp)
    80004756:	ec4e                	sd	s3,24(sp)
    80004758:	e852                	sd	s4,16(sp)
    8000475a:	e456                	sd	s5,8(sp)
    8000475c:	0080                	addi	s0,sp,64
    8000475e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004760:	0001d517          	auipc	a0,0x1d
    80004764:	4f050513          	addi	a0,a0,1264 # 80021c50 <ftable>
    80004768:	ffffc097          	auipc	ra,0xffffc
    8000476c:	544080e7          	jalr	1348(ra) # 80000cac <acquire>
  if(f->ref < 1)
    80004770:	40dc                	lw	a5,4(s1)
    80004772:	06f05163          	blez	a5,800047d4 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004776:	37fd                	addiw	a5,a5,-1
    80004778:	0007871b          	sext.w	a4,a5
    8000477c:	c0dc                	sw	a5,4(s1)
    8000477e:	06e04363          	bgtz	a4,800047e4 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004782:	0004a903          	lw	s2,0(s1)
    80004786:	0094ca83          	lbu	s5,9(s1)
    8000478a:	0104ba03          	ld	s4,16(s1)
    8000478e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004792:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004796:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000479a:	0001d517          	auipc	a0,0x1d
    8000479e:	4b650513          	addi	a0,a0,1206 # 80021c50 <ftable>
    800047a2:	ffffc097          	auipc	ra,0xffffc
    800047a6:	5be080e7          	jalr	1470(ra) # 80000d60 <release>

  if(ff.type == FD_PIPE){
    800047aa:	4785                	li	a5,1
    800047ac:	04f90d63          	beq	s2,a5,80004806 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047b0:	3979                	addiw	s2,s2,-2
    800047b2:	4785                	li	a5,1
    800047b4:	0527e063          	bltu	a5,s2,800047f4 <fileclose+0xa8>
    begin_op();
    800047b8:	00000097          	auipc	ra,0x0
    800047bc:	a92080e7          	jalr	-1390(ra) # 8000424a <begin_op>
    iput(ff.ip);
    800047c0:	854e                	mv	a0,s3
    800047c2:	fffff097          	auipc	ra,0xfffff
    800047c6:	27c080e7          	jalr	636(ra) # 80003a3e <iput>
    end_op();
    800047ca:	00000097          	auipc	ra,0x0
    800047ce:	b00080e7          	jalr	-1280(ra) # 800042ca <end_op>
    800047d2:	a00d                	j	800047f4 <fileclose+0xa8>
    panic("fileclose");
    800047d4:	00004517          	auipc	a0,0x4
    800047d8:	03450513          	addi	a0,a0,52 # 80008808 <sysnames+0x348>
    800047dc:	ffffc097          	auipc	ra,0xffffc
    800047e0:	d98080e7          	jalr	-616(ra) # 80000574 <panic>
    release(&ftable.lock);
    800047e4:	0001d517          	auipc	a0,0x1d
    800047e8:	46c50513          	addi	a0,a0,1132 # 80021c50 <ftable>
    800047ec:	ffffc097          	auipc	ra,0xffffc
    800047f0:	574080e7          	jalr	1396(ra) # 80000d60 <release>
  }
}
    800047f4:	70e2                	ld	ra,56(sp)
    800047f6:	7442                	ld	s0,48(sp)
    800047f8:	74a2                	ld	s1,40(sp)
    800047fa:	7902                	ld	s2,32(sp)
    800047fc:	69e2                	ld	s3,24(sp)
    800047fe:	6a42                	ld	s4,16(sp)
    80004800:	6aa2                	ld	s5,8(sp)
    80004802:	6121                	addi	sp,sp,64
    80004804:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004806:	85d6                	mv	a1,s5
    80004808:	8552                	mv	a0,s4
    8000480a:	00000097          	auipc	ra,0x0
    8000480e:	364080e7          	jalr	868(ra) # 80004b6e <pipeclose>
    80004812:	b7cd                	j	800047f4 <fileclose+0xa8>

0000000080004814 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004814:	715d                	addi	sp,sp,-80
    80004816:	e486                	sd	ra,72(sp)
    80004818:	e0a2                	sd	s0,64(sp)
    8000481a:	fc26                	sd	s1,56(sp)
    8000481c:	f84a                	sd	s2,48(sp)
    8000481e:	f44e                	sd	s3,40(sp)
    80004820:	0880                	addi	s0,sp,80
    80004822:	84aa                	mv	s1,a0
    80004824:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004826:	ffffd097          	auipc	ra,0xffffd
    8000482a:	294080e7          	jalr	660(ra) # 80001aba <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000482e:	409c                	lw	a5,0(s1)
    80004830:	37f9                	addiw	a5,a5,-2
    80004832:	4705                	li	a4,1
    80004834:	04f76763          	bltu	a4,a5,80004882 <filestat+0x6e>
    80004838:	892a                	mv	s2,a0
    ilock(f->ip);
    8000483a:	6c88                	ld	a0,24(s1)
    8000483c:	fffff097          	auipc	ra,0xfffff
    80004840:	046080e7          	jalr	70(ra) # 80003882 <ilock>
    stati(f->ip, &st);
    80004844:	fb840593          	addi	a1,s0,-72
    80004848:	6c88                	ld	a0,24(s1)
    8000484a:	fffff097          	auipc	ra,0xfffff
    8000484e:	2c4080e7          	jalr	708(ra) # 80003b0e <stati>
    iunlock(f->ip);
    80004852:	6c88                	ld	a0,24(s1)
    80004854:	fffff097          	auipc	ra,0xfffff
    80004858:	0f2080e7          	jalr	242(ra) # 80003946 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000485c:	46e1                	li	a3,24
    8000485e:	fb840613          	addi	a2,s0,-72
    80004862:	85ce                	mv	a1,s3
    80004864:	05093503          	ld	a0,80(s2)
    80004868:	ffffd097          	auipc	ra,0xffffd
    8000486c:	f2e080e7          	jalr	-210(ra) # 80001796 <copyout>
    80004870:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004874:	60a6                	ld	ra,72(sp)
    80004876:	6406                	ld	s0,64(sp)
    80004878:	74e2                	ld	s1,56(sp)
    8000487a:	7942                	ld	s2,48(sp)
    8000487c:	79a2                	ld	s3,40(sp)
    8000487e:	6161                	addi	sp,sp,80
    80004880:	8082                	ret
  return -1;
    80004882:	557d                	li	a0,-1
    80004884:	bfc5                	j	80004874 <filestat+0x60>

0000000080004886 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004886:	7179                	addi	sp,sp,-48
    80004888:	f406                	sd	ra,40(sp)
    8000488a:	f022                	sd	s0,32(sp)
    8000488c:	ec26                	sd	s1,24(sp)
    8000488e:	e84a                	sd	s2,16(sp)
    80004890:	e44e                	sd	s3,8(sp)
    80004892:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004894:	00854783          	lbu	a5,8(a0)
    80004898:	c3d5                	beqz	a5,8000493c <fileread+0xb6>
    8000489a:	89b2                	mv	s3,a2
    8000489c:	892e                	mv	s2,a1
    8000489e:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    800048a0:	411c                	lw	a5,0(a0)
    800048a2:	4705                	li	a4,1
    800048a4:	04e78963          	beq	a5,a4,800048f6 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048a8:	470d                	li	a4,3
    800048aa:	04e78d63          	beq	a5,a4,80004904 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800048ae:	4709                	li	a4,2
    800048b0:	06e79e63          	bne	a5,a4,8000492c <fileread+0xa6>
    ilock(f->ip);
    800048b4:	6d08                	ld	a0,24(a0)
    800048b6:	fffff097          	auipc	ra,0xfffff
    800048ba:	fcc080e7          	jalr	-52(ra) # 80003882 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048be:	874e                	mv	a4,s3
    800048c0:	5094                	lw	a3,32(s1)
    800048c2:	864a                	mv	a2,s2
    800048c4:	4585                	li	a1,1
    800048c6:	6c88                	ld	a0,24(s1)
    800048c8:	fffff097          	auipc	ra,0xfffff
    800048cc:	270080e7          	jalr	624(ra) # 80003b38 <readi>
    800048d0:	892a                	mv	s2,a0
    800048d2:	00a05563          	blez	a0,800048dc <fileread+0x56>
      f->off += r;
    800048d6:	509c                	lw	a5,32(s1)
    800048d8:	9fa9                	addw	a5,a5,a0
    800048da:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048dc:	6c88                	ld	a0,24(s1)
    800048de:	fffff097          	auipc	ra,0xfffff
    800048e2:	068080e7          	jalr	104(ra) # 80003946 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800048e6:	854a                	mv	a0,s2
    800048e8:	70a2                	ld	ra,40(sp)
    800048ea:	7402                	ld	s0,32(sp)
    800048ec:	64e2                	ld	s1,24(sp)
    800048ee:	6942                	ld	s2,16(sp)
    800048f0:	69a2                	ld	s3,8(sp)
    800048f2:	6145                	addi	sp,sp,48
    800048f4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800048f6:	6908                	ld	a0,16(a0)
    800048f8:	00000097          	auipc	ra,0x0
    800048fc:	416080e7          	jalr	1046(ra) # 80004d0e <piperead>
    80004900:	892a                	mv	s2,a0
    80004902:	b7d5                	j	800048e6 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004904:	02451783          	lh	a5,36(a0)
    80004908:	03079693          	slli	a3,a5,0x30
    8000490c:	92c1                	srli	a3,a3,0x30
    8000490e:	4725                	li	a4,9
    80004910:	02d76863          	bltu	a4,a3,80004940 <fileread+0xba>
    80004914:	0792                	slli	a5,a5,0x4
    80004916:	0001d717          	auipc	a4,0x1d
    8000491a:	29a70713          	addi	a4,a4,666 # 80021bb0 <devsw>
    8000491e:	97ba                	add	a5,a5,a4
    80004920:	639c                	ld	a5,0(a5)
    80004922:	c38d                	beqz	a5,80004944 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004924:	4505                	li	a0,1
    80004926:	9782                	jalr	a5
    80004928:	892a                	mv	s2,a0
    8000492a:	bf75                	j	800048e6 <fileread+0x60>
    panic("fileread");
    8000492c:	00004517          	auipc	a0,0x4
    80004930:	eec50513          	addi	a0,a0,-276 # 80008818 <sysnames+0x358>
    80004934:	ffffc097          	auipc	ra,0xffffc
    80004938:	c40080e7          	jalr	-960(ra) # 80000574 <panic>
    return -1;
    8000493c:	597d                	li	s2,-1
    8000493e:	b765                	j	800048e6 <fileread+0x60>
      return -1;
    80004940:	597d                	li	s2,-1
    80004942:	b755                	j	800048e6 <fileread+0x60>
    80004944:	597d                	li	s2,-1
    80004946:	b745                	j	800048e6 <fileread+0x60>

0000000080004948 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004948:	00954783          	lbu	a5,9(a0)
    8000494c:	12078e63          	beqz	a5,80004a88 <filewrite+0x140>
{
    80004950:	715d                	addi	sp,sp,-80
    80004952:	e486                	sd	ra,72(sp)
    80004954:	e0a2                	sd	s0,64(sp)
    80004956:	fc26                	sd	s1,56(sp)
    80004958:	f84a                	sd	s2,48(sp)
    8000495a:	f44e                	sd	s3,40(sp)
    8000495c:	f052                	sd	s4,32(sp)
    8000495e:	ec56                	sd	s5,24(sp)
    80004960:	e85a                	sd	s6,16(sp)
    80004962:	e45e                	sd	s7,8(sp)
    80004964:	e062                	sd	s8,0(sp)
    80004966:	0880                	addi	s0,sp,80
    80004968:	8ab2                	mv	s5,a2
    8000496a:	8b2e                	mv	s6,a1
    8000496c:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    8000496e:	411c                	lw	a5,0(a0)
    80004970:	4705                	li	a4,1
    80004972:	02e78263          	beq	a5,a4,80004996 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004976:	470d                	li	a4,3
    80004978:	02e78563          	beq	a5,a4,800049a2 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000497c:	4709                	li	a4,2
    8000497e:	0ee79d63          	bne	a5,a4,80004a78 <filewrite+0x130>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004982:	0ec05763          	blez	a2,80004a70 <filewrite+0x128>
    int i = 0;
    80004986:	4901                	li	s2,0
    80004988:	6b85                	lui	s7,0x1
    8000498a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000498e:	6c05                	lui	s8,0x1
    80004990:	c00c0c1b          	addiw	s8,s8,-1024
    80004994:	a061                	j	80004a1c <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    80004996:	6908                	ld	a0,16(a0)
    80004998:	00000097          	auipc	ra,0x0
    8000499c:	246080e7          	jalr	582(ra) # 80004bde <pipewrite>
    800049a0:	a065                	j	80004a48 <filewrite+0x100>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049a2:	02451783          	lh	a5,36(a0)
    800049a6:	03079693          	slli	a3,a5,0x30
    800049aa:	92c1                	srli	a3,a3,0x30
    800049ac:	4725                	li	a4,9
    800049ae:	0cd76f63          	bltu	a4,a3,80004a8c <filewrite+0x144>
    800049b2:	0792                	slli	a5,a5,0x4
    800049b4:	0001d717          	auipc	a4,0x1d
    800049b8:	1fc70713          	addi	a4,a4,508 # 80021bb0 <devsw>
    800049bc:	97ba                	add	a5,a5,a4
    800049be:	679c                	ld	a5,8(a5)
    800049c0:	cbe1                	beqz	a5,80004a90 <filewrite+0x148>
    ret = devsw[f->major].write(1, addr, n);
    800049c2:	4505                	li	a0,1
    800049c4:	9782                	jalr	a5
    800049c6:	a049                	j	80004a48 <filewrite+0x100>
    800049c8:	00098a1b          	sext.w	s4,s3
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800049cc:	00000097          	auipc	ra,0x0
    800049d0:	87e080e7          	jalr	-1922(ra) # 8000424a <begin_op>
      ilock(f->ip);
    800049d4:	6c88                	ld	a0,24(s1)
    800049d6:	fffff097          	auipc	ra,0xfffff
    800049da:	eac080e7          	jalr	-340(ra) # 80003882 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049de:	8752                	mv	a4,s4
    800049e0:	5094                	lw	a3,32(s1)
    800049e2:	01690633          	add	a2,s2,s6
    800049e6:	4585                	li	a1,1
    800049e8:	6c88                	ld	a0,24(s1)
    800049ea:	fffff097          	auipc	ra,0xfffff
    800049ee:	244080e7          	jalr	580(ra) # 80003c2e <writei>
    800049f2:	89aa                	mv	s3,a0
    800049f4:	02a05c63          	blez	a0,80004a2c <filewrite+0xe4>
        f->off += r;
    800049f8:	509c                	lw	a5,32(s1)
    800049fa:	9fa9                	addw	a5,a5,a0
    800049fc:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    800049fe:	6c88                	ld	a0,24(s1)
    80004a00:	fffff097          	auipc	ra,0xfffff
    80004a04:	f46080e7          	jalr	-186(ra) # 80003946 <iunlock>
      end_op();
    80004a08:	00000097          	auipc	ra,0x0
    80004a0c:	8c2080e7          	jalr	-1854(ra) # 800042ca <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004a10:	05499863          	bne	s3,s4,80004a60 <filewrite+0x118>
        panic("short filewrite");
      i += r;
    80004a14:	012a093b          	addw	s2,s4,s2
    while(i < n){
    80004a18:	03595563          	ble	s5,s2,80004a42 <filewrite+0xfa>
      int n1 = n - i;
    80004a1c:	412a87bb          	subw	a5,s5,s2
      if(n1 > max)
    80004a20:	89be                	mv	s3,a5
    80004a22:	2781                	sext.w	a5,a5
    80004a24:	fafbd2e3          	ble	a5,s7,800049c8 <filewrite+0x80>
    80004a28:	89e2                	mv	s3,s8
    80004a2a:	bf79                	j	800049c8 <filewrite+0x80>
      iunlock(f->ip);
    80004a2c:	6c88                	ld	a0,24(s1)
    80004a2e:	fffff097          	auipc	ra,0xfffff
    80004a32:	f18080e7          	jalr	-232(ra) # 80003946 <iunlock>
      end_op();
    80004a36:	00000097          	auipc	ra,0x0
    80004a3a:	894080e7          	jalr	-1900(ra) # 800042ca <end_op>
      if(r < 0)
    80004a3e:	fc09d9e3          	bgez	s3,80004a10 <filewrite+0xc8>
    }
    ret = (i == n ? n : -1);
    80004a42:	8556                	mv	a0,s5
    80004a44:	032a9863          	bne	s5,s2,80004a74 <filewrite+0x12c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a48:	60a6                	ld	ra,72(sp)
    80004a4a:	6406                	ld	s0,64(sp)
    80004a4c:	74e2                	ld	s1,56(sp)
    80004a4e:	7942                	ld	s2,48(sp)
    80004a50:	79a2                	ld	s3,40(sp)
    80004a52:	7a02                	ld	s4,32(sp)
    80004a54:	6ae2                	ld	s5,24(sp)
    80004a56:	6b42                	ld	s6,16(sp)
    80004a58:	6ba2                	ld	s7,8(sp)
    80004a5a:	6c02                	ld	s8,0(sp)
    80004a5c:	6161                	addi	sp,sp,80
    80004a5e:	8082                	ret
        panic("short filewrite");
    80004a60:	00004517          	auipc	a0,0x4
    80004a64:	dc850513          	addi	a0,a0,-568 # 80008828 <sysnames+0x368>
    80004a68:	ffffc097          	auipc	ra,0xffffc
    80004a6c:	b0c080e7          	jalr	-1268(ra) # 80000574 <panic>
    int i = 0;
    80004a70:	4901                	li	s2,0
    80004a72:	bfc1                	j	80004a42 <filewrite+0xfa>
    ret = (i == n ? n : -1);
    80004a74:	557d                	li	a0,-1
    80004a76:	bfc9                	j	80004a48 <filewrite+0x100>
    panic("filewrite");
    80004a78:	00004517          	auipc	a0,0x4
    80004a7c:	dc050513          	addi	a0,a0,-576 # 80008838 <sysnames+0x378>
    80004a80:	ffffc097          	auipc	ra,0xffffc
    80004a84:	af4080e7          	jalr	-1292(ra) # 80000574 <panic>
    return -1;
    80004a88:	557d                	li	a0,-1
}
    80004a8a:	8082                	ret
      return -1;
    80004a8c:	557d                	li	a0,-1
    80004a8e:	bf6d                	j	80004a48 <filewrite+0x100>
    80004a90:	557d                	li	a0,-1
    80004a92:	bf5d                	j	80004a48 <filewrite+0x100>

0000000080004a94 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a94:	7179                	addi	sp,sp,-48
    80004a96:	f406                	sd	ra,40(sp)
    80004a98:	f022                	sd	s0,32(sp)
    80004a9a:	ec26                	sd	s1,24(sp)
    80004a9c:	e84a                	sd	s2,16(sp)
    80004a9e:	e44e                	sd	s3,8(sp)
    80004aa0:	e052                	sd	s4,0(sp)
    80004aa2:	1800                	addi	s0,sp,48
    80004aa4:	84aa                	mv	s1,a0
    80004aa6:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004aa8:	0005b023          	sd	zero,0(a1)
    80004aac:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ab0:	00000097          	auipc	ra,0x0
    80004ab4:	bcc080e7          	jalr	-1076(ra) # 8000467c <filealloc>
    80004ab8:	e088                	sd	a0,0(s1)
    80004aba:	c551                	beqz	a0,80004b46 <pipealloc+0xb2>
    80004abc:	00000097          	auipc	ra,0x0
    80004ac0:	bc0080e7          	jalr	-1088(ra) # 8000467c <filealloc>
    80004ac4:	00a93023          	sd	a0,0(s2)
    80004ac8:	c92d                	beqz	a0,80004b3a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004aca:	ffffc097          	auipc	ra,0xffffc
    80004ace:	0a8080e7          	jalr	168(ra) # 80000b72 <kalloc>
    80004ad2:	89aa                	mv	s3,a0
    80004ad4:	c125                	beqz	a0,80004b34 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ad6:	4a05                	li	s4,1
    80004ad8:	23452023          	sw	s4,544(a0)
  pi->writeopen = 1;
    80004adc:	23452223          	sw	s4,548(a0)
  pi->nwrite = 0;
    80004ae0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ae4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ae8:	00004597          	auipc	a1,0x4
    80004aec:	af058593          	addi	a1,a1,-1296 # 800085d8 <sysnames+0x118>
    80004af0:	ffffc097          	auipc	ra,0xffffc
    80004af4:	12c080e7          	jalr	300(ra) # 80000c1c <initlock>
  (*f0)->type = FD_PIPE;
    80004af8:	609c                	ld	a5,0(s1)
    80004afa:	0147a023          	sw	s4,0(a5)
  (*f0)->readable = 1;
    80004afe:	609c                	ld	a5,0(s1)
    80004b00:	01478423          	sb	s4,8(a5)
  (*f0)->writable = 0;
    80004b04:	609c                	ld	a5,0(s1)
    80004b06:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b0a:	609c                	ld	a5,0(s1)
    80004b0c:	0137b823          	sd	s3,16(a5)
  (*f1)->type = FD_PIPE;
    80004b10:	00093783          	ld	a5,0(s2)
    80004b14:	0147a023          	sw	s4,0(a5)
  (*f1)->readable = 0;
    80004b18:	00093783          	ld	a5,0(s2)
    80004b1c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b20:	00093783          	ld	a5,0(s2)
    80004b24:	014784a3          	sb	s4,9(a5)
  (*f1)->pipe = pi;
    80004b28:	00093783          	ld	a5,0(s2)
    80004b2c:	0137b823          	sd	s3,16(a5)
  return 0;
    80004b30:	4501                	li	a0,0
    80004b32:	a025                	j	80004b5a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b34:	6088                	ld	a0,0(s1)
    80004b36:	e501                	bnez	a0,80004b3e <pipealloc+0xaa>
    80004b38:	a039                	j	80004b46 <pipealloc+0xb2>
    80004b3a:	6088                	ld	a0,0(s1)
    80004b3c:	c51d                	beqz	a0,80004b6a <pipealloc+0xd6>
    fileclose(*f0);
    80004b3e:	00000097          	auipc	ra,0x0
    80004b42:	c0e080e7          	jalr	-1010(ra) # 8000474c <fileclose>
  if(*f1)
    80004b46:	00093783          	ld	a5,0(s2)
    fileclose(*f1);
  return -1;
    80004b4a:	557d                	li	a0,-1
  if(*f1)
    80004b4c:	c799                	beqz	a5,80004b5a <pipealloc+0xc6>
    fileclose(*f1);
    80004b4e:	853e                	mv	a0,a5
    80004b50:	00000097          	auipc	ra,0x0
    80004b54:	bfc080e7          	jalr	-1028(ra) # 8000474c <fileclose>
  return -1;
    80004b58:	557d                	li	a0,-1
}
    80004b5a:	70a2                	ld	ra,40(sp)
    80004b5c:	7402                	ld	s0,32(sp)
    80004b5e:	64e2                	ld	s1,24(sp)
    80004b60:	6942                	ld	s2,16(sp)
    80004b62:	69a2                	ld	s3,8(sp)
    80004b64:	6a02                	ld	s4,0(sp)
    80004b66:	6145                	addi	sp,sp,48
    80004b68:	8082                	ret
  return -1;
    80004b6a:	557d                	li	a0,-1
    80004b6c:	b7fd                	j	80004b5a <pipealloc+0xc6>

0000000080004b6e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b6e:	1101                	addi	sp,sp,-32
    80004b70:	ec06                	sd	ra,24(sp)
    80004b72:	e822                	sd	s0,16(sp)
    80004b74:	e426                	sd	s1,8(sp)
    80004b76:	e04a                	sd	s2,0(sp)
    80004b78:	1000                	addi	s0,sp,32
    80004b7a:	84aa                	mv	s1,a0
    80004b7c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b7e:	ffffc097          	auipc	ra,0xffffc
    80004b82:	12e080e7          	jalr	302(ra) # 80000cac <acquire>
  if(writable){
    80004b86:	02090d63          	beqz	s2,80004bc0 <pipeclose+0x52>
    pi->writeopen = 0;
    80004b8a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b8e:	21848513          	addi	a0,s1,536
    80004b92:	ffffe097          	auipc	ra,0xffffe
    80004b96:	8d0080e7          	jalr	-1840(ra) # 80002462 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b9a:	2204b783          	ld	a5,544(s1)
    80004b9e:	eb95                	bnez	a5,80004bd2 <pipeclose+0x64>
    release(&pi->lock);
    80004ba0:	8526                	mv	a0,s1
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	1be080e7          	jalr	446(ra) # 80000d60 <release>
    kfree((char*)pi);
    80004baa:	8526                	mv	a0,s1
    80004bac:	ffffc097          	auipc	ra,0xffffc
    80004bb0:	ec6080e7          	jalr	-314(ra) # 80000a72 <kfree>
  } else
    release(&pi->lock);
}
    80004bb4:	60e2                	ld	ra,24(sp)
    80004bb6:	6442                	ld	s0,16(sp)
    80004bb8:	64a2                	ld	s1,8(sp)
    80004bba:	6902                	ld	s2,0(sp)
    80004bbc:	6105                	addi	sp,sp,32
    80004bbe:	8082                	ret
    pi->readopen = 0;
    80004bc0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004bc4:	21c48513          	addi	a0,s1,540
    80004bc8:	ffffe097          	auipc	ra,0xffffe
    80004bcc:	89a080e7          	jalr	-1894(ra) # 80002462 <wakeup>
    80004bd0:	b7e9                	j	80004b9a <pipeclose+0x2c>
    release(&pi->lock);
    80004bd2:	8526                	mv	a0,s1
    80004bd4:	ffffc097          	auipc	ra,0xffffc
    80004bd8:	18c080e7          	jalr	396(ra) # 80000d60 <release>
}
    80004bdc:	bfe1                	j	80004bb4 <pipeclose+0x46>

0000000080004bde <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004bde:	7119                	addi	sp,sp,-128
    80004be0:	fc86                	sd	ra,120(sp)
    80004be2:	f8a2                	sd	s0,112(sp)
    80004be4:	f4a6                	sd	s1,104(sp)
    80004be6:	f0ca                	sd	s2,96(sp)
    80004be8:	ecce                	sd	s3,88(sp)
    80004bea:	e8d2                	sd	s4,80(sp)
    80004bec:	e4d6                	sd	s5,72(sp)
    80004bee:	e0da                	sd	s6,64(sp)
    80004bf0:	fc5e                	sd	s7,56(sp)
    80004bf2:	f862                	sd	s8,48(sp)
    80004bf4:	f466                	sd	s9,40(sp)
    80004bf6:	f06a                	sd	s10,32(sp)
    80004bf8:	ec6e                	sd	s11,24(sp)
    80004bfa:	0100                	addi	s0,sp,128
    80004bfc:	84aa                	mv	s1,a0
    80004bfe:	8d2e                	mv	s10,a1
    80004c00:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004c02:	ffffd097          	auipc	ra,0xffffd
    80004c06:	eb8080e7          	jalr	-328(ra) # 80001aba <myproc>
    80004c0a:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004c0c:	8526                	mv	a0,s1
    80004c0e:	ffffc097          	auipc	ra,0xffffc
    80004c12:	09e080e7          	jalr	158(ra) # 80000cac <acquire>
  for(i = 0; i < n; i++){
    80004c16:	0d605f63          	blez	s6,80004cf4 <pipewrite+0x116>
    80004c1a:	89a6                	mv	s3,s1
    80004c1c:	3b7d                	addiw	s6,s6,-1
    80004c1e:	1b02                	slli	s6,s6,0x20
    80004c20:	020b5b13          	srli	s6,s6,0x20
    80004c24:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004c26:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c2a:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c2e:	5dfd                	li	s11,-1
    80004c30:	000b8c9b          	sext.w	s9,s7
    80004c34:	8c66                	mv	s8,s9
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c36:	2184a783          	lw	a5,536(s1)
    80004c3a:	21c4a703          	lw	a4,540(s1)
    80004c3e:	2007879b          	addiw	a5,a5,512
    80004c42:	06f71763          	bne	a4,a5,80004cb0 <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004c46:	2204a783          	lw	a5,544(s1)
    80004c4a:	cf8d                	beqz	a5,80004c84 <pipewrite+0xa6>
    80004c4c:	03092783          	lw	a5,48(s2)
    80004c50:	eb95                	bnez	a5,80004c84 <pipewrite+0xa6>
      wakeup(&pi->nread);
    80004c52:	8556                	mv	a0,s5
    80004c54:	ffffe097          	auipc	ra,0xffffe
    80004c58:	80e080e7          	jalr	-2034(ra) # 80002462 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c5c:	85ce                	mv	a1,s3
    80004c5e:	8552                	mv	a0,s4
    80004c60:	ffffd097          	auipc	ra,0xffffd
    80004c64:	67c080e7          	jalr	1660(ra) # 800022dc <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c68:	2184a783          	lw	a5,536(s1)
    80004c6c:	21c4a703          	lw	a4,540(s1)
    80004c70:	2007879b          	addiw	a5,a5,512
    80004c74:	02f71e63          	bne	a4,a5,80004cb0 <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004c78:	2204a783          	lw	a5,544(s1)
    80004c7c:	c781                	beqz	a5,80004c84 <pipewrite+0xa6>
    80004c7e:	03092783          	lw	a5,48(s2)
    80004c82:	dbe1                	beqz	a5,80004c52 <pipewrite+0x74>
        release(&pi->lock);
    80004c84:	8526                	mv	a0,s1
    80004c86:	ffffc097          	auipc	ra,0xffffc
    80004c8a:	0da080e7          	jalr	218(ra) # 80000d60 <release>
        return -1;
    80004c8e:	5c7d                	li	s8,-1
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004c90:	8562                	mv	a0,s8
    80004c92:	70e6                	ld	ra,120(sp)
    80004c94:	7446                	ld	s0,112(sp)
    80004c96:	74a6                	ld	s1,104(sp)
    80004c98:	7906                	ld	s2,96(sp)
    80004c9a:	69e6                	ld	s3,88(sp)
    80004c9c:	6a46                	ld	s4,80(sp)
    80004c9e:	6aa6                	ld	s5,72(sp)
    80004ca0:	6b06                	ld	s6,64(sp)
    80004ca2:	7be2                	ld	s7,56(sp)
    80004ca4:	7c42                	ld	s8,48(sp)
    80004ca6:	7ca2                	ld	s9,40(sp)
    80004ca8:	7d02                	ld	s10,32(sp)
    80004caa:	6de2                	ld	s11,24(sp)
    80004cac:	6109                	addi	sp,sp,128
    80004cae:	8082                	ret
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cb0:	4685                	li	a3,1
    80004cb2:	01ab8633          	add	a2,s7,s10
    80004cb6:	f8f40593          	addi	a1,s0,-113
    80004cba:	05093503          	ld	a0,80(s2)
    80004cbe:	ffffd097          	auipc	ra,0xffffd
    80004cc2:	b64080e7          	jalr	-1180(ra) # 80001822 <copyin>
    80004cc6:	03b50863          	beq	a0,s11,80004cf6 <pipewrite+0x118>
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cca:	21c4a783          	lw	a5,540(s1)
    80004cce:	0017871b          	addiw	a4,a5,1
    80004cd2:	20e4ae23          	sw	a4,540(s1)
    80004cd6:	1ff7f793          	andi	a5,a5,511
    80004cda:	97a6                	add	a5,a5,s1
    80004cdc:	f8f44703          	lbu	a4,-113(s0)
    80004ce0:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004ce4:	001c8c1b          	addiw	s8,s9,1
    80004ce8:	001b8793          	addi	a5,s7,1
    80004cec:	016b8563          	beq	s7,s6,80004cf6 <pipewrite+0x118>
    80004cf0:	8bbe                	mv	s7,a5
    80004cf2:	bf3d                	j	80004c30 <pipewrite+0x52>
    80004cf4:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004cf6:	21848513          	addi	a0,s1,536
    80004cfa:	ffffd097          	auipc	ra,0xffffd
    80004cfe:	768080e7          	jalr	1896(ra) # 80002462 <wakeup>
  release(&pi->lock);
    80004d02:	8526                	mv	a0,s1
    80004d04:	ffffc097          	auipc	ra,0xffffc
    80004d08:	05c080e7          	jalr	92(ra) # 80000d60 <release>
  return i;
    80004d0c:	b751                	j	80004c90 <pipewrite+0xb2>

0000000080004d0e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d0e:	715d                	addi	sp,sp,-80
    80004d10:	e486                	sd	ra,72(sp)
    80004d12:	e0a2                	sd	s0,64(sp)
    80004d14:	fc26                	sd	s1,56(sp)
    80004d16:	f84a                	sd	s2,48(sp)
    80004d18:	f44e                	sd	s3,40(sp)
    80004d1a:	f052                	sd	s4,32(sp)
    80004d1c:	ec56                	sd	s5,24(sp)
    80004d1e:	e85a                	sd	s6,16(sp)
    80004d20:	0880                	addi	s0,sp,80
    80004d22:	84aa                	mv	s1,a0
    80004d24:	89ae                	mv	s3,a1
    80004d26:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d28:	ffffd097          	auipc	ra,0xffffd
    80004d2c:	d92080e7          	jalr	-622(ra) # 80001aba <myproc>
    80004d30:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d32:	8526                	mv	a0,s1
    80004d34:	ffffc097          	auipc	ra,0xffffc
    80004d38:	f78080e7          	jalr	-136(ra) # 80000cac <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d3c:	2184a703          	lw	a4,536(s1)
    80004d40:	21c4a783          	lw	a5,540(s1)
    80004d44:	06f71b63          	bne	a4,a5,80004dba <piperead+0xac>
    80004d48:	8926                	mv	s2,s1
    80004d4a:	2244a783          	lw	a5,548(s1)
    80004d4e:	cf9d                	beqz	a5,80004d8c <piperead+0x7e>
    if(pr->killed){
    80004d50:	030a2783          	lw	a5,48(s4)
    80004d54:	e78d                	bnez	a5,80004d7e <piperead+0x70>
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d56:	21848b13          	addi	s6,s1,536
    80004d5a:	85ca                	mv	a1,s2
    80004d5c:	855a                	mv	a0,s6
    80004d5e:	ffffd097          	auipc	ra,0xffffd
    80004d62:	57e080e7          	jalr	1406(ra) # 800022dc <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d66:	2184a703          	lw	a4,536(s1)
    80004d6a:	21c4a783          	lw	a5,540(s1)
    80004d6e:	04f71663          	bne	a4,a5,80004dba <piperead+0xac>
    80004d72:	2244a783          	lw	a5,548(s1)
    80004d76:	cb99                	beqz	a5,80004d8c <piperead+0x7e>
    if(pr->killed){
    80004d78:	030a2783          	lw	a5,48(s4)
    80004d7c:	dff9                	beqz	a5,80004d5a <piperead+0x4c>
      release(&pi->lock);
    80004d7e:	8526                	mv	a0,s1
    80004d80:	ffffc097          	auipc	ra,0xffffc
    80004d84:	fe0080e7          	jalr	-32(ra) # 80000d60 <release>
      return -1;
    80004d88:	597d                	li	s2,-1
    80004d8a:	a829                	j	80004da4 <piperead+0x96>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(pi->nread == pi->nwrite)
    80004d8c:	4901                	li	s2,0
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d8e:	21c48513          	addi	a0,s1,540
    80004d92:	ffffd097          	auipc	ra,0xffffd
    80004d96:	6d0080e7          	jalr	1744(ra) # 80002462 <wakeup>
  release(&pi->lock);
    80004d9a:	8526                	mv	a0,s1
    80004d9c:	ffffc097          	auipc	ra,0xffffc
    80004da0:	fc4080e7          	jalr	-60(ra) # 80000d60 <release>
  return i;
}
    80004da4:	854a                	mv	a0,s2
    80004da6:	60a6                	ld	ra,72(sp)
    80004da8:	6406                	ld	s0,64(sp)
    80004daa:	74e2                	ld	s1,56(sp)
    80004dac:	7942                	ld	s2,48(sp)
    80004dae:	79a2                	ld	s3,40(sp)
    80004db0:	7a02                	ld	s4,32(sp)
    80004db2:	6ae2                	ld	s5,24(sp)
    80004db4:	6b42                	ld	s6,16(sp)
    80004db6:	6161                	addi	sp,sp,80
    80004db8:	8082                	ret
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dba:	4901                	li	s2,0
    80004dbc:	fd5059e3          	blez	s5,80004d8e <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004dc0:	2184a783          	lw	a5,536(s1)
    80004dc4:	4901                	li	s2,0
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dc6:	5b7d                	li	s6,-1
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004dc8:	0017871b          	addiw	a4,a5,1
    80004dcc:	20e4ac23          	sw	a4,536(s1)
    80004dd0:	1ff7f793          	andi	a5,a5,511
    80004dd4:	97a6                	add	a5,a5,s1
    80004dd6:	0187c783          	lbu	a5,24(a5)
    80004dda:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dde:	4685                	li	a3,1
    80004de0:	fbf40613          	addi	a2,s0,-65
    80004de4:	85ce                	mv	a1,s3
    80004de6:	050a3503          	ld	a0,80(s4)
    80004dea:	ffffd097          	auipc	ra,0xffffd
    80004dee:	9ac080e7          	jalr	-1620(ra) # 80001796 <copyout>
    80004df2:	f9650ee3          	beq	a0,s6,80004d8e <piperead+0x80>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004df6:	2905                	addiw	s2,s2,1
    80004df8:	f92a8be3          	beq	s5,s2,80004d8e <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004dfc:	2184a783          	lw	a5,536(s1)
    80004e00:	0985                	addi	s3,s3,1
    80004e02:	21c4a703          	lw	a4,540(s1)
    80004e06:	fcf711e3          	bne	a4,a5,80004dc8 <piperead+0xba>
    80004e0a:	b751                	j	80004d8e <piperead+0x80>

0000000080004e0c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e0c:	de010113          	addi	sp,sp,-544
    80004e10:	20113c23          	sd	ra,536(sp)
    80004e14:	20813823          	sd	s0,528(sp)
    80004e18:	20913423          	sd	s1,520(sp)
    80004e1c:	21213023          	sd	s2,512(sp)
    80004e20:	ffce                	sd	s3,504(sp)
    80004e22:	fbd2                	sd	s4,496(sp)
    80004e24:	f7d6                	sd	s5,488(sp)
    80004e26:	f3da                	sd	s6,480(sp)
    80004e28:	efde                	sd	s7,472(sp)
    80004e2a:	ebe2                	sd	s8,464(sp)
    80004e2c:	e7e6                	sd	s9,456(sp)
    80004e2e:	e3ea                	sd	s10,448(sp)
    80004e30:	ff6e                	sd	s11,440(sp)
    80004e32:	1400                	addi	s0,sp,544
    80004e34:	892a                	mv	s2,a0
    80004e36:	dea43823          	sd	a0,-528(s0)
    80004e3a:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e3e:	ffffd097          	auipc	ra,0xffffd
    80004e42:	c7c080e7          	jalr	-900(ra) # 80001aba <myproc>
    80004e46:	84aa                	mv	s1,a0

  begin_op();
    80004e48:	fffff097          	auipc	ra,0xfffff
    80004e4c:	402080e7          	jalr	1026(ra) # 8000424a <begin_op>

  if((ip = namei(path)) == 0){
    80004e50:	854a                	mv	a0,s2
    80004e52:	fffff097          	auipc	ra,0xfffff
    80004e56:	1ea080e7          	jalr	490(ra) # 8000403c <namei>
    80004e5a:	c93d                	beqz	a0,80004ed0 <exec+0xc4>
    80004e5c:	892a                	mv	s2,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e5e:	fffff097          	auipc	ra,0xfffff
    80004e62:	a24080e7          	jalr	-1500(ra) # 80003882 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e66:	04000713          	li	a4,64
    80004e6a:	4681                	li	a3,0
    80004e6c:	e4840613          	addi	a2,s0,-440
    80004e70:	4581                	li	a1,0
    80004e72:	854a                	mv	a0,s2
    80004e74:	fffff097          	auipc	ra,0xfffff
    80004e78:	cc4080e7          	jalr	-828(ra) # 80003b38 <readi>
    80004e7c:	04000793          	li	a5,64
    80004e80:	00f51a63          	bne	a0,a5,80004e94 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e84:	e4842703          	lw	a4,-440(s0)
    80004e88:	464c47b7          	lui	a5,0x464c4
    80004e8c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e90:	04f70663          	beq	a4,a5,80004edc <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e94:	854a                	mv	a0,s2
    80004e96:	fffff097          	auipc	ra,0xfffff
    80004e9a:	c50080e7          	jalr	-944(ra) # 80003ae6 <iunlockput>
    end_op();
    80004e9e:	fffff097          	auipc	ra,0xfffff
    80004ea2:	42c080e7          	jalr	1068(ra) # 800042ca <end_op>
  }
  return -1;
    80004ea6:	557d                	li	a0,-1
}
    80004ea8:	21813083          	ld	ra,536(sp)
    80004eac:	21013403          	ld	s0,528(sp)
    80004eb0:	20813483          	ld	s1,520(sp)
    80004eb4:	20013903          	ld	s2,512(sp)
    80004eb8:	79fe                	ld	s3,504(sp)
    80004eba:	7a5e                	ld	s4,496(sp)
    80004ebc:	7abe                	ld	s5,488(sp)
    80004ebe:	7b1e                	ld	s6,480(sp)
    80004ec0:	6bfe                	ld	s7,472(sp)
    80004ec2:	6c5e                	ld	s8,464(sp)
    80004ec4:	6cbe                	ld	s9,456(sp)
    80004ec6:	6d1e                	ld	s10,448(sp)
    80004ec8:	7dfa                	ld	s11,440(sp)
    80004eca:	22010113          	addi	sp,sp,544
    80004ece:	8082                	ret
    end_op();
    80004ed0:	fffff097          	auipc	ra,0xfffff
    80004ed4:	3fa080e7          	jalr	1018(ra) # 800042ca <end_op>
    return -1;
    80004ed8:	557d                	li	a0,-1
    80004eda:	b7f9                	j	80004ea8 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004edc:	8526                	mv	a0,s1
    80004ede:	ffffd097          	auipc	ra,0xffffd
    80004ee2:	ca2080e7          	jalr	-862(ra) # 80001b80 <proc_pagetable>
    80004ee6:	e0a43423          	sd	a0,-504(s0)
    80004eea:	d54d                	beqz	a0,80004e94 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004eec:	e6842983          	lw	s3,-408(s0)
    80004ef0:	e8045783          	lhu	a5,-384(s0)
    80004ef4:	c7ad                	beqz	a5,80004f5e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004ef6:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ef8:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004efa:	6c05                	lui	s8,0x1
    80004efc:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    80004f00:	def43423          	sd	a5,-536(s0)
    80004f04:	7cfd                	lui	s9,0xfffff
    80004f06:	ac1d                	j	8000513c <exec+0x330>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f08:	00004517          	auipc	a0,0x4
    80004f0c:	94050513          	addi	a0,a0,-1728 # 80008848 <sysnames+0x388>
    80004f10:	ffffb097          	auipc	ra,0xffffb
    80004f14:	664080e7          	jalr	1636(ra) # 80000574 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f18:	8756                	mv	a4,s5
    80004f1a:	009d86bb          	addw	a3,s11,s1
    80004f1e:	4581                	li	a1,0
    80004f20:	854a                	mv	a0,s2
    80004f22:	fffff097          	auipc	ra,0xfffff
    80004f26:	c16080e7          	jalr	-1002(ra) # 80003b38 <readi>
    80004f2a:	2501                	sext.w	a0,a0
    80004f2c:	1aaa9e63          	bne	s5,a0,800050e8 <exec+0x2dc>
  for(i = 0; i < sz; i += PGSIZE){
    80004f30:	6785                	lui	a5,0x1
    80004f32:	9cbd                	addw	s1,s1,a5
    80004f34:	014c8a3b          	addw	s4,s9,s4
    80004f38:	1f74f963          	bleu	s7,s1,8000512a <exec+0x31e>
    pa = walkaddr(pagetable, va + i);
    80004f3c:	02049593          	slli	a1,s1,0x20
    80004f40:	9181                	srli	a1,a1,0x20
    80004f42:	95ea                	add	a1,a1,s10
    80004f44:	e0843503          	ld	a0,-504(s0)
    80004f48:	ffffc097          	auipc	ra,0xffffc
    80004f4c:	216080e7          	jalr	534(ra) # 8000115e <walkaddr>
    80004f50:	862a                	mv	a2,a0
    if(pa == 0)
    80004f52:	d95d                	beqz	a0,80004f08 <exec+0xfc>
      n = PGSIZE;
    80004f54:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    80004f56:	fd8a71e3          	bleu	s8,s4,80004f18 <exec+0x10c>
      n = sz - i;
    80004f5a:	8ad2                	mv	s5,s4
    80004f5c:	bf75                	j	80004f18 <exec+0x10c>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004f5e:	4481                	li	s1,0
  iunlockput(ip);
    80004f60:	854a                	mv	a0,s2
    80004f62:	fffff097          	auipc	ra,0xfffff
    80004f66:	b84080e7          	jalr	-1148(ra) # 80003ae6 <iunlockput>
  end_op();
    80004f6a:	fffff097          	auipc	ra,0xfffff
    80004f6e:	360080e7          	jalr	864(ra) # 800042ca <end_op>
  p = myproc();
    80004f72:	ffffd097          	auipc	ra,0xffffd
    80004f76:	b48080e7          	jalr	-1208(ra) # 80001aba <myproc>
    80004f7a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f7c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004f80:	6785                	lui	a5,0x1
    80004f82:	17fd                	addi	a5,a5,-1
    80004f84:	94be                	add	s1,s1,a5
    80004f86:	77fd                	lui	a5,0xfffff
    80004f88:	8fe5                	and	a5,a5,s1
    80004f8a:	e0f43023          	sd	a5,-512(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f8e:	6609                	lui	a2,0x2
    80004f90:	963e                	add	a2,a2,a5
    80004f92:	85be                	mv	a1,a5
    80004f94:	e0843483          	ld	s1,-504(s0)
    80004f98:	8526                	mv	a0,s1
    80004f9a:	ffffc097          	auipc	ra,0xffffc
    80004f9e:	5ac080e7          	jalr	1452(ra) # 80001546 <uvmalloc>
    80004fa2:	8b2a                	mv	s6,a0
  ip = 0;
    80004fa4:	4901                	li	s2,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fa6:	14050163          	beqz	a0,800050e8 <exec+0x2dc>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004faa:	75f9                	lui	a1,0xffffe
    80004fac:	95aa                	add	a1,a1,a0
    80004fae:	8526                	mv	a0,s1
    80004fb0:	ffffc097          	auipc	ra,0xffffc
    80004fb4:	7b4080e7          	jalr	1972(ra) # 80001764 <uvmclear>
  stackbase = sp - PGSIZE;
    80004fb8:	7bfd                	lui	s7,0xfffff
    80004fba:	9bda                	add	s7,s7,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fbc:	df843783          	ld	a5,-520(s0)
    80004fc0:	6388                	ld	a0,0(a5)
    80004fc2:	c925                	beqz	a0,80005032 <exec+0x226>
    80004fc4:	e8840993          	addi	s3,s0,-376
    80004fc8:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80004fcc:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fce:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004fd0:	ffffc097          	auipc	ra,0xffffc
    80004fd4:	f82080e7          	jalr	-126(ra) # 80000f52 <strlen>
    80004fd8:	2505                	addiw	a0,a0,1
    80004fda:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fde:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004fe2:	13796863          	bltu	s2,s7,80005112 <exec+0x306>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fe6:	df843c83          	ld	s9,-520(s0)
    80004fea:	000cba03          	ld	s4,0(s9) # fffffffffffff000 <end+0xffffffff7ffd9000>
    80004fee:	8552                	mv	a0,s4
    80004ff0:	ffffc097          	auipc	ra,0xffffc
    80004ff4:	f62080e7          	jalr	-158(ra) # 80000f52 <strlen>
    80004ff8:	0015069b          	addiw	a3,a0,1
    80004ffc:	8652                	mv	a2,s4
    80004ffe:	85ca                	mv	a1,s2
    80005000:	e0843503          	ld	a0,-504(s0)
    80005004:	ffffc097          	auipc	ra,0xffffc
    80005008:	792080e7          	jalr	1938(ra) # 80001796 <copyout>
    8000500c:	10054763          	bltz	a0,8000511a <exec+0x30e>
    ustack[argc] = sp;
    80005010:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005014:	0485                	addi	s1,s1,1
    80005016:	008c8793          	addi	a5,s9,8
    8000501a:	def43c23          	sd	a5,-520(s0)
    8000501e:	008cb503          	ld	a0,8(s9)
    80005022:	c911                	beqz	a0,80005036 <exec+0x22a>
    if(argc >= MAXARG)
    80005024:	09a1                	addi	s3,s3,8
    80005026:	fb8995e3          	bne	s3,s8,80004fd0 <exec+0x1c4>
  sz = sz1;
    8000502a:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    8000502e:	4901                	li	s2,0
    80005030:	a865                	j	800050e8 <exec+0x2dc>
  sp = sz;
    80005032:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005034:	4481                	li	s1,0
  ustack[argc] = 0;
    80005036:	00349793          	slli	a5,s1,0x3
    8000503a:	f9040713          	addi	a4,s0,-112
    8000503e:	97ba                	add	a5,a5,a4
    80005040:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    80005044:	00148693          	addi	a3,s1,1
    80005048:	068e                	slli	a3,a3,0x3
    8000504a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000504e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005052:	01797663          	bleu	s7,s2,8000505e <exec+0x252>
  sz = sz1;
    80005056:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    8000505a:	4901                	li	s2,0
    8000505c:	a071                	j	800050e8 <exec+0x2dc>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000505e:	e8840613          	addi	a2,s0,-376
    80005062:	85ca                	mv	a1,s2
    80005064:	e0843503          	ld	a0,-504(s0)
    80005068:	ffffc097          	auipc	ra,0xffffc
    8000506c:	72e080e7          	jalr	1838(ra) # 80001796 <copyout>
    80005070:	0a054963          	bltz	a0,80005122 <exec+0x316>
  p->trapframe->a1 = sp;
    80005074:	058ab783          	ld	a5,88(s5)
    80005078:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000507c:	df043783          	ld	a5,-528(s0)
    80005080:	0007c703          	lbu	a4,0(a5)
    80005084:	cf11                	beqz	a4,800050a0 <exec+0x294>
    80005086:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005088:	02f00693          	li	a3,47
    8000508c:	a029                	j	80005096 <exec+0x28a>
  for(last=s=path; *s; s++)
    8000508e:	0785                	addi	a5,a5,1
    80005090:	fff7c703          	lbu	a4,-1(a5)
    80005094:	c711                	beqz	a4,800050a0 <exec+0x294>
    if(*s == '/')
    80005096:	fed71ce3          	bne	a4,a3,8000508e <exec+0x282>
      last = s+1;
    8000509a:	def43823          	sd	a5,-528(s0)
    8000509e:	bfc5                	j	8000508e <exec+0x282>
  safestrcpy(p->name, last, sizeof(p->name));
    800050a0:	4641                	li	a2,16
    800050a2:	df043583          	ld	a1,-528(s0)
    800050a6:	158a8513          	addi	a0,s5,344
    800050aa:	ffffc097          	auipc	ra,0xffffc
    800050ae:	e76080e7          	jalr	-394(ra) # 80000f20 <safestrcpy>
  oldpagetable = p->pagetable;
    800050b2:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800050b6:	e0843783          	ld	a5,-504(s0)
    800050ba:	04fab823          	sd	a5,80(s5)
  p->sz = sz;
    800050be:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050c2:	058ab783          	ld	a5,88(s5)
    800050c6:	e6043703          	ld	a4,-416(s0)
    800050ca:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050cc:	058ab783          	ld	a5,88(s5)
    800050d0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050d4:	85ea                	mv	a1,s10
    800050d6:	ffffd097          	auipc	ra,0xffffd
    800050da:	b46080e7          	jalr	-1210(ra) # 80001c1c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050de:	0004851b          	sext.w	a0,s1
    800050e2:	b3d9                	j	80004ea8 <exec+0x9c>
    800050e4:	e0943023          	sd	s1,-512(s0)
    proc_freepagetable(pagetable, sz);
    800050e8:	e0043583          	ld	a1,-512(s0)
    800050ec:	e0843503          	ld	a0,-504(s0)
    800050f0:	ffffd097          	auipc	ra,0xffffd
    800050f4:	b2c080e7          	jalr	-1236(ra) # 80001c1c <proc_freepagetable>
  if(ip){
    800050f8:	d8091ee3          	bnez	s2,80004e94 <exec+0x88>
  return -1;
    800050fc:	557d                	li	a0,-1
    800050fe:	b36d                	j	80004ea8 <exec+0x9c>
    80005100:	e0943023          	sd	s1,-512(s0)
    80005104:	b7d5                	j	800050e8 <exec+0x2dc>
    80005106:	e0943023          	sd	s1,-512(s0)
    8000510a:	bff9                	j	800050e8 <exec+0x2dc>
    8000510c:	e0943023          	sd	s1,-512(s0)
    80005110:	bfe1                	j	800050e8 <exec+0x2dc>
  sz = sz1;
    80005112:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005116:	4901                	li	s2,0
    80005118:	bfc1                	j	800050e8 <exec+0x2dc>
  sz = sz1;
    8000511a:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    8000511e:	4901                	li	s2,0
    80005120:	b7e1                	j	800050e8 <exec+0x2dc>
  sz = sz1;
    80005122:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005126:	4901                	li	s2,0
    80005128:	b7c1                	j	800050e8 <exec+0x2dc>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000512a:	e0043483          	ld	s1,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000512e:	2b05                	addiw	s6,s6,1
    80005130:	0389899b          	addiw	s3,s3,56
    80005134:	e8045783          	lhu	a5,-384(s0)
    80005138:	e2fb54e3          	ble	a5,s6,80004f60 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000513c:	2981                	sext.w	s3,s3
    8000513e:	03800713          	li	a4,56
    80005142:	86ce                	mv	a3,s3
    80005144:	e1040613          	addi	a2,s0,-496
    80005148:	4581                	li	a1,0
    8000514a:	854a                	mv	a0,s2
    8000514c:	fffff097          	auipc	ra,0xfffff
    80005150:	9ec080e7          	jalr	-1556(ra) # 80003b38 <readi>
    80005154:	03800793          	li	a5,56
    80005158:	f8f516e3          	bne	a0,a5,800050e4 <exec+0x2d8>
    if(ph.type != ELF_PROG_LOAD)
    8000515c:	e1042783          	lw	a5,-496(s0)
    80005160:	4705                	li	a4,1
    80005162:	fce796e3          	bne	a5,a4,8000512e <exec+0x322>
    if(ph.memsz < ph.filesz)
    80005166:	e3843603          	ld	a2,-456(s0)
    8000516a:	e3043783          	ld	a5,-464(s0)
    8000516e:	f8f669e3          	bltu	a2,a5,80005100 <exec+0x2f4>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005172:	e2043783          	ld	a5,-480(s0)
    80005176:	963e                	add	a2,a2,a5
    80005178:	f8f667e3          	bltu	a2,a5,80005106 <exec+0x2fa>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000517c:	85a6                	mv	a1,s1
    8000517e:	e0843503          	ld	a0,-504(s0)
    80005182:	ffffc097          	auipc	ra,0xffffc
    80005186:	3c4080e7          	jalr	964(ra) # 80001546 <uvmalloc>
    8000518a:	e0a43023          	sd	a0,-512(s0)
    8000518e:	dd3d                	beqz	a0,8000510c <exec+0x300>
    if(ph.vaddr % PGSIZE != 0)
    80005190:	e2043d03          	ld	s10,-480(s0)
    80005194:	de843783          	ld	a5,-536(s0)
    80005198:	00fd77b3          	and	a5,s10,a5
    8000519c:	f7b1                	bnez	a5,800050e8 <exec+0x2dc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000519e:	e1842d83          	lw	s11,-488(s0)
    800051a2:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800051a6:	f80b82e3          	beqz	s7,8000512a <exec+0x31e>
    800051aa:	8a5e                	mv	s4,s7
    800051ac:	4481                	li	s1,0
    800051ae:	b379                	j	80004f3c <exec+0x130>

00000000800051b0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051b0:	7179                	addi	sp,sp,-48
    800051b2:	f406                	sd	ra,40(sp)
    800051b4:	f022                	sd	s0,32(sp)
    800051b6:	ec26                	sd	s1,24(sp)
    800051b8:	e84a                	sd	s2,16(sp)
    800051ba:	1800                	addi	s0,sp,48
    800051bc:	892e                	mv	s2,a1
    800051be:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800051c0:	fdc40593          	addi	a1,s0,-36
    800051c4:	ffffe097          	auipc	ra,0xffffe
    800051c8:	a22080e7          	jalr	-1502(ra) # 80002be6 <argint>
    800051cc:	04054063          	bltz	a0,8000520c <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051d0:	fdc42703          	lw	a4,-36(s0)
    800051d4:	47bd                	li	a5,15
    800051d6:	02e7ed63          	bltu	a5,a4,80005210 <argfd+0x60>
    800051da:	ffffd097          	auipc	ra,0xffffd
    800051de:	8e0080e7          	jalr	-1824(ra) # 80001aba <myproc>
    800051e2:	fdc42703          	lw	a4,-36(s0)
    800051e6:	01a70793          	addi	a5,a4,26
    800051ea:	078e                	slli	a5,a5,0x3
    800051ec:	953e                	add	a0,a0,a5
    800051ee:	611c                	ld	a5,0(a0)
    800051f0:	c395                	beqz	a5,80005214 <argfd+0x64>
    return -1;
  if(pfd)
    800051f2:	00090463          	beqz	s2,800051fa <argfd+0x4a>
    *pfd = fd;
    800051f6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051fa:	4501                	li	a0,0
  if(pf)
    800051fc:	c091                	beqz	s1,80005200 <argfd+0x50>
    *pf = f;
    800051fe:	e09c                	sd	a5,0(s1)
}
    80005200:	70a2                	ld	ra,40(sp)
    80005202:	7402                	ld	s0,32(sp)
    80005204:	64e2                	ld	s1,24(sp)
    80005206:	6942                	ld	s2,16(sp)
    80005208:	6145                	addi	sp,sp,48
    8000520a:	8082                	ret
    return -1;
    8000520c:	557d                	li	a0,-1
    8000520e:	bfcd                	j	80005200 <argfd+0x50>
    return -1;
    80005210:	557d                	li	a0,-1
    80005212:	b7fd                	j	80005200 <argfd+0x50>
    80005214:	557d                	li	a0,-1
    80005216:	b7ed                	j	80005200 <argfd+0x50>

0000000080005218 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005218:	1101                	addi	sp,sp,-32
    8000521a:	ec06                	sd	ra,24(sp)
    8000521c:	e822                	sd	s0,16(sp)
    8000521e:	e426                	sd	s1,8(sp)
    80005220:	1000                	addi	s0,sp,32
    80005222:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005224:	ffffd097          	auipc	ra,0xffffd
    80005228:	896080e7          	jalr	-1898(ra) # 80001aba <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
    8000522c:	697c                	ld	a5,208(a0)
    8000522e:	c395                	beqz	a5,80005252 <fdalloc+0x3a>
    80005230:	0d850713          	addi	a4,a0,216
  for(fd = 0; fd < NOFILE; fd++){
    80005234:	4785                	li	a5,1
    80005236:	4641                	li	a2,16
    if(p->ofile[fd] == 0){
    80005238:	6314                	ld	a3,0(a4)
    8000523a:	ce89                	beqz	a3,80005254 <fdalloc+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
    8000523c:	2785                	addiw	a5,a5,1
    8000523e:	0721                	addi	a4,a4,8
    80005240:	fec79ce3          	bne	a5,a2,80005238 <fdalloc+0x20>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005244:	57fd                	li	a5,-1
}
    80005246:	853e                	mv	a0,a5
    80005248:	60e2                	ld	ra,24(sp)
    8000524a:	6442                	ld	s0,16(sp)
    8000524c:	64a2                	ld	s1,8(sp)
    8000524e:	6105                	addi	sp,sp,32
    80005250:	8082                	ret
  for(fd = 0; fd < NOFILE; fd++){
    80005252:	4781                	li	a5,0
      p->ofile[fd] = f;
    80005254:	01a78713          	addi	a4,a5,26
    80005258:	070e                	slli	a4,a4,0x3
    8000525a:	953a                	add	a0,a0,a4
    8000525c:	e104                	sd	s1,0(a0)
      return fd;
    8000525e:	b7e5                	j	80005246 <fdalloc+0x2e>

0000000080005260 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005260:	715d                	addi	sp,sp,-80
    80005262:	e486                	sd	ra,72(sp)
    80005264:	e0a2                	sd	s0,64(sp)
    80005266:	fc26                	sd	s1,56(sp)
    80005268:	f84a                	sd	s2,48(sp)
    8000526a:	f44e                	sd	s3,40(sp)
    8000526c:	f052                	sd	s4,32(sp)
    8000526e:	ec56                	sd	s5,24(sp)
    80005270:	0880                	addi	s0,sp,80
    80005272:	89ae                	mv	s3,a1
    80005274:	8ab2                	mv	s5,a2
    80005276:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005278:	fb040593          	addi	a1,s0,-80
    8000527c:	fffff097          	auipc	ra,0xfffff
    80005280:	dde080e7          	jalr	-546(ra) # 8000405a <nameiparent>
    80005284:	892a                	mv	s2,a0
    80005286:	12050f63          	beqz	a0,800053c4 <create+0x164>
    return 0;

  ilock(dp);
    8000528a:	ffffe097          	auipc	ra,0xffffe
    8000528e:	5f8080e7          	jalr	1528(ra) # 80003882 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005292:	4601                	li	a2,0
    80005294:	fb040593          	addi	a1,s0,-80
    80005298:	854a                	mv	a0,s2
    8000529a:	fffff097          	auipc	ra,0xfffff
    8000529e:	ac8080e7          	jalr	-1336(ra) # 80003d62 <dirlookup>
    800052a2:	84aa                	mv	s1,a0
    800052a4:	c921                	beqz	a0,800052f4 <create+0x94>
    iunlockput(dp);
    800052a6:	854a                	mv	a0,s2
    800052a8:	fffff097          	auipc	ra,0xfffff
    800052ac:	83e080e7          	jalr	-1986(ra) # 80003ae6 <iunlockput>
    ilock(ip);
    800052b0:	8526                	mv	a0,s1
    800052b2:	ffffe097          	auipc	ra,0xffffe
    800052b6:	5d0080e7          	jalr	1488(ra) # 80003882 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052ba:	2981                	sext.w	s3,s3
    800052bc:	4789                	li	a5,2
    800052be:	02f99463          	bne	s3,a5,800052e6 <create+0x86>
    800052c2:	0444d783          	lhu	a5,68(s1)
    800052c6:	37f9                	addiw	a5,a5,-2
    800052c8:	17c2                	slli	a5,a5,0x30
    800052ca:	93c1                	srli	a5,a5,0x30
    800052cc:	4705                	li	a4,1
    800052ce:	00f76c63          	bltu	a4,a5,800052e6 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800052d2:	8526                	mv	a0,s1
    800052d4:	60a6                	ld	ra,72(sp)
    800052d6:	6406                	ld	s0,64(sp)
    800052d8:	74e2                	ld	s1,56(sp)
    800052da:	7942                	ld	s2,48(sp)
    800052dc:	79a2                	ld	s3,40(sp)
    800052de:	7a02                	ld	s4,32(sp)
    800052e0:	6ae2                	ld	s5,24(sp)
    800052e2:	6161                	addi	sp,sp,80
    800052e4:	8082                	ret
    iunlockput(ip);
    800052e6:	8526                	mv	a0,s1
    800052e8:	ffffe097          	auipc	ra,0xffffe
    800052ec:	7fe080e7          	jalr	2046(ra) # 80003ae6 <iunlockput>
    return 0;
    800052f0:	4481                	li	s1,0
    800052f2:	b7c5                	j	800052d2 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800052f4:	85ce                	mv	a1,s3
    800052f6:	00092503          	lw	a0,0(s2)
    800052fa:	ffffe097          	auipc	ra,0xffffe
    800052fe:	3ec080e7          	jalr	1004(ra) # 800036e6 <ialloc>
    80005302:	84aa                	mv	s1,a0
    80005304:	c529                	beqz	a0,8000534e <create+0xee>
  ilock(ip);
    80005306:	ffffe097          	auipc	ra,0xffffe
    8000530a:	57c080e7          	jalr	1404(ra) # 80003882 <ilock>
  ip->major = major;
    8000530e:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005312:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005316:	4785                	li	a5,1
    80005318:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000531c:	8526                	mv	a0,s1
    8000531e:	ffffe097          	auipc	ra,0xffffe
    80005322:	498080e7          	jalr	1176(ra) # 800037b6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005326:	2981                	sext.w	s3,s3
    80005328:	4785                	li	a5,1
    8000532a:	02f98a63          	beq	s3,a5,8000535e <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000532e:	40d0                	lw	a2,4(s1)
    80005330:	fb040593          	addi	a1,s0,-80
    80005334:	854a                	mv	a0,s2
    80005336:	fffff097          	auipc	ra,0xfffff
    8000533a:	c44080e7          	jalr	-956(ra) # 80003f7a <dirlink>
    8000533e:	06054b63          	bltz	a0,800053b4 <create+0x154>
  iunlockput(dp);
    80005342:	854a                	mv	a0,s2
    80005344:	ffffe097          	auipc	ra,0xffffe
    80005348:	7a2080e7          	jalr	1954(ra) # 80003ae6 <iunlockput>
  return ip;
    8000534c:	b759                	j	800052d2 <create+0x72>
    panic("create: ialloc");
    8000534e:	00003517          	auipc	a0,0x3
    80005352:	51a50513          	addi	a0,a0,1306 # 80008868 <sysnames+0x3a8>
    80005356:	ffffb097          	auipc	ra,0xffffb
    8000535a:	21e080e7          	jalr	542(ra) # 80000574 <panic>
    dp->nlink++;  // for ".."
    8000535e:	04a95783          	lhu	a5,74(s2)
    80005362:	2785                	addiw	a5,a5,1
    80005364:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005368:	854a                	mv	a0,s2
    8000536a:	ffffe097          	auipc	ra,0xffffe
    8000536e:	44c080e7          	jalr	1100(ra) # 800037b6 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005372:	40d0                	lw	a2,4(s1)
    80005374:	00003597          	auipc	a1,0x3
    80005378:	50458593          	addi	a1,a1,1284 # 80008878 <sysnames+0x3b8>
    8000537c:	8526                	mv	a0,s1
    8000537e:	fffff097          	auipc	ra,0xfffff
    80005382:	bfc080e7          	jalr	-1028(ra) # 80003f7a <dirlink>
    80005386:	00054f63          	bltz	a0,800053a4 <create+0x144>
    8000538a:	00492603          	lw	a2,4(s2)
    8000538e:	00003597          	auipc	a1,0x3
    80005392:	4f258593          	addi	a1,a1,1266 # 80008880 <sysnames+0x3c0>
    80005396:	8526                	mv	a0,s1
    80005398:	fffff097          	auipc	ra,0xfffff
    8000539c:	be2080e7          	jalr	-1054(ra) # 80003f7a <dirlink>
    800053a0:	f80557e3          	bgez	a0,8000532e <create+0xce>
      panic("create dots");
    800053a4:	00003517          	auipc	a0,0x3
    800053a8:	4e450513          	addi	a0,a0,1252 # 80008888 <sysnames+0x3c8>
    800053ac:	ffffb097          	auipc	ra,0xffffb
    800053b0:	1c8080e7          	jalr	456(ra) # 80000574 <panic>
    panic("create: dirlink");
    800053b4:	00003517          	auipc	a0,0x3
    800053b8:	4e450513          	addi	a0,a0,1252 # 80008898 <sysnames+0x3d8>
    800053bc:	ffffb097          	auipc	ra,0xffffb
    800053c0:	1b8080e7          	jalr	440(ra) # 80000574 <panic>
    return 0;
    800053c4:	84aa                	mv	s1,a0
    800053c6:	b731                	j	800052d2 <create+0x72>

00000000800053c8 <sys_dup>:
{
    800053c8:	7179                	addi	sp,sp,-48
    800053ca:	f406                	sd	ra,40(sp)
    800053cc:	f022                	sd	s0,32(sp)
    800053ce:	ec26                	sd	s1,24(sp)
    800053d0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053d2:	fd840613          	addi	a2,s0,-40
    800053d6:	4581                	li	a1,0
    800053d8:	4501                	li	a0,0
    800053da:	00000097          	auipc	ra,0x0
    800053de:	dd6080e7          	jalr	-554(ra) # 800051b0 <argfd>
    return -1;
    800053e2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053e4:	02054363          	bltz	a0,8000540a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053e8:	fd843503          	ld	a0,-40(s0)
    800053ec:	00000097          	auipc	ra,0x0
    800053f0:	e2c080e7          	jalr	-468(ra) # 80005218 <fdalloc>
    800053f4:	84aa                	mv	s1,a0
    return -1;
    800053f6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053f8:	00054963          	bltz	a0,8000540a <sys_dup+0x42>
  filedup(f);
    800053fc:	fd843503          	ld	a0,-40(s0)
    80005400:	fffff097          	auipc	ra,0xfffff
    80005404:	2fa080e7          	jalr	762(ra) # 800046fa <filedup>
  return fd;
    80005408:	87a6                	mv	a5,s1
}
    8000540a:	853e                	mv	a0,a5
    8000540c:	70a2                	ld	ra,40(sp)
    8000540e:	7402                	ld	s0,32(sp)
    80005410:	64e2                	ld	s1,24(sp)
    80005412:	6145                	addi	sp,sp,48
    80005414:	8082                	ret

0000000080005416 <sys_read>:
{
    80005416:	7179                	addi	sp,sp,-48
    80005418:	f406                	sd	ra,40(sp)
    8000541a:	f022                	sd	s0,32(sp)
    8000541c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000541e:	fe840613          	addi	a2,s0,-24
    80005422:	4581                	li	a1,0
    80005424:	4501                	li	a0,0
    80005426:	00000097          	auipc	ra,0x0
    8000542a:	d8a080e7          	jalr	-630(ra) # 800051b0 <argfd>
    return -1;
    8000542e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005430:	04054163          	bltz	a0,80005472 <sys_read+0x5c>
    80005434:	fe440593          	addi	a1,s0,-28
    80005438:	4509                	li	a0,2
    8000543a:	ffffd097          	auipc	ra,0xffffd
    8000543e:	7ac080e7          	jalr	1964(ra) # 80002be6 <argint>
    return -1;
    80005442:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005444:	02054763          	bltz	a0,80005472 <sys_read+0x5c>
    80005448:	fd840593          	addi	a1,s0,-40
    8000544c:	4505                	li	a0,1
    8000544e:	ffffd097          	auipc	ra,0xffffd
    80005452:	7ba080e7          	jalr	1978(ra) # 80002c08 <argaddr>
    return -1;
    80005456:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005458:	00054d63          	bltz	a0,80005472 <sys_read+0x5c>
  return fileread(f, p, n);
    8000545c:	fe442603          	lw	a2,-28(s0)
    80005460:	fd843583          	ld	a1,-40(s0)
    80005464:	fe843503          	ld	a0,-24(s0)
    80005468:	fffff097          	auipc	ra,0xfffff
    8000546c:	41e080e7          	jalr	1054(ra) # 80004886 <fileread>
    80005470:	87aa                	mv	a5,a0
}
    80005472:	853e                	mv	a0,a5
    80005474:	70a2                	ld	ra,40(sp)
    80005476:	7402                	ld	s0,32(sp)
    80005478:	6145                	addi	sp,sp,48
    8000547a:	8082                	ret

000000008000547c <sys_write>:
{
    8000547c:	7179                	addi	sp,sp,-48
    8000547e:	f406                	sd	ra,40(sp)
    80005480:	f022                	sd	s0,32(sp)
    80005482:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005484:	fe840613          	addi	a2,s0,-24
    80005488:	4581                	li	a1,0
    8000548a:	4501                	li	a0,0
    8000548c:	00000097          	auipc	ra,0x0
    80005490:	d24080e7          	jalr	-732(ra) # 800051b0 <argfd>
    return -1;
    80005494:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005496:	04054163          	bltz	a0,800054d8 <sys_write+0x5c>
    8000549a:	fe440593          	addi	a1,s0,-28
    8000549e:	4509                	li	a0,2
    800054a0:	ffffd097          	auipc	ra,0xffffd
    800054a4:	746080e7          	jalr	1862(ra) # 80002be6 <argint>
    return -1;
    800054a8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054aa:	02054763          	bltz	a0,800054d8 <sys_write+0x5c>
    800054ae:	fd840593          	addi	a1,s0,-40
    800054b2:	4505                	li	a0,1
    800054b4:	ffffd097          	auipc	ra,0xffffd
    800054b8:	754080e7          	jalr	1876(ra) # 80002c08 <argaddr>
    return -1;
    800054bc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054be:	00054d63          	bltz	a0,800054d8 <sys_write+0x5c>
  return filewrite(f, p, n);
    800054c2:	fe442603          	lw	a2,-28(s0)
    800054c6:	fd843583          	ld	a1,-40(s0)
    800054ca:	fe843503          	ld	a0,-24(s0)
    800054ce:	fffff097          	auipc	ra,0xfffff
    800054d2:	47a080e7          	jalr	1146(ra) # 80004948 <filewrite>
    800054d6:	87aa                	mv	a5,a0
}
    800054d8:	853e                	mv	a0,a5
    800054da:	70a2                	ld	ra,40(sp)
    800054dc:	7402                	ld	s0,32(sp)
    800054de:	6145                	addi	sp,sp,48
    800054e0:	8082                	ret

00000000800054e2 <sys_close>:
{
    800054e2:	1101                	addi	sp,sp,-32
    800054e4:	ec06                	sd	ra,24(sp)
    800054e6:	e822                	sd	s0,16(sp)
    800054e8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054ea:	fe040613          	addi	a2,s0,-32
    800054ee:	fec40593          	addi	a1,s0,-20
    800054f2:	4501                	li	a0,0
    800054f4:	00000097          	auipc	ra,0x0
    800054f8:	cbc080e7          	jalr	-836(ra) # 800051b0 <argfd>
    return -1;
    800054fc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054fe:	02054463          	bltz	a0,80005526 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005502:	ffffc097          	auipc	ra,0xffffc
    80005506:	5b8080e7          	jalr	1464(ra) # 80001aba <myproc>
    8000550a:	fec42783          	lw	a5,-20(s0)
    8000550e:	07e9                	addi	a5,a5,26
    80005510:	078e                	slli	a5,a5,0x3
    80005512:	953e                	add	a0,a0,a5
    80005514:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005518:	fe043503          	ld	a0,-32(s0)
    8000551c:	fffff097          	auipc	ra,0xfffff
    80005520:	230080e7          	jalr	560(ra) # 8000474c <fileclose>
  return 0;
    80005524:	4781                	li	a5,0
}
    80005526:	853e                	mv	a0,a5
    80005528:	60e2                	ld	ra,24(sp)
    8000552a:	6442                	ld	s0,16(sp)
    8000552c:	6105                	addi	sp,sp,32
    8000552e:	8082                	ret

0000000080005530 <sys_fstat>:
{
    80005530:	1101                	addi	sp,sp,-32
    80005532:	ec06                	sd	ra,24(sp)
    80005534:	e822                	sd	s0,16(sp)
    80005536:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005538:	fe840613          	addi	a2,s0,-24
    8000553c:	4581                	li	a1,0
    8000553e:	4501                	li	a0,0
    80005540:	00000097          	auipc	ra,0x0
    80005544:	c70080e7          	jalr	-912(ra) # 800051b0 <argfd>
    return -1;
    80005548:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000554a:	02054563          	bltz	a0,80005574 <sys_fstat+0x44>
    8000554e:	fe040593          	addi	a1,s0,-32
    80005552:	4505                	li	a0,1
    80005554:	ffffd097          	auipc	ra,0xffffd
    80005558:	6b4080e7          	jalr	1716(ra) # 80002c08 <argaddr>
    return -1;
    8000555c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000555e:	00054b63          	bltz	a0,80005574 <sys_fstat+0x44>
  return filestat(f, st);
    80005562:	fe043583          	ld	a1,-32(s0)
    80005566:	fe843503          	ld	a0,-24(s0)
    8000556a:	fffff097          	auipc	ra,0xfffff
    8000556e:	2aa080e7          	jalr	682(ra) # 80004814 <filestat>
    80005572:	87aa                	mv	a5,a0
}
    80005574:	853e                	mv	a0,a5
    80005576:	60e2                	ld	ra,24(sp)
    80005578:	6442                	ld	s0,16(sp)
    8000557a:	6105                	addi	sp,sp,32
    8000557c:	8082                	ret

000000008000557e <sys_link>:
{
    8000557e:	7169                	addi	sp,sp,-304
    80005580:	f606                	sd	ra,296(sp)
    80005582:	f222                	sd	s0,288(sp)
    80005584:	ee26                	sd	s1,280(sp)
    80005586:	ea4a                	sd	s2,272(sp)
    80005588:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000558a:	08000613          	li	a2,128
    8000558e:	ed040593          	addi	a1,s0,-304
    80005592:	4501                	li	a0,0
    80005594:	ffffd097          	auipc	ra,0xffffd
    80005598:	696080e7          	jalr	1686(ra) # 80002c2a <argstr>
    return -1;
    8000559c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000559e:	10054e63          	bltz	a0,800056ba <sys_link+0x13c>
    800055a2:	08000613          	li	a2,128
    800055a6:	f5040593          	addi	a1,s0,-176
    800055aa:	4505                	li	a0,1
    800055ac:	ffffd097          	auipc	ra,0xffffd
    800055b0:	67e080e7          	jalr	1662(ra) # 80002c2a <argstr>
    return -1;
    800055b4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055b6:	10054263          	bltz	a0,800056ba <sys_link+0x13c>
  begin_op();
    800055ba:	fffff097          	auipc	ra,0xfffff
    800055be:	c90080e7          	jalr	-880(ra) # 8000424a <begin_op>
  if((ip = namei(old)) == 0){
    800055c2:	ed040513          	addi	a0,s0,-304
    800055c6:	fffff097          	auipc	ra,0xfffff
    800055ca:	a76080e7          	jalr	-1418(ra) # 8000403c <namei>
    800055ce:	84aa                	mv	s1,a0
    800055d0:	c551                	beqz	a0,8000565c <sys_link+0xde>
  ilock(ip);
    800055d2:	ffffe097          	auipc	ra,0xffffe
    800055d6:	2b0080e7          	jalr	688(ra) # 80003882 <ilock>
  if(ip->type == T_DIR){
    800055da:	04449703          	lh	a4,68(s1)
    800055de:	4785                	li	a5,1
    800055e0:	08f70463          	beq	a4,a5,80005668 <sys_link+0xea>
  ip->nlink++;
    800055e4:	04a4d783          	lhu	a5,74(s1)
    800055e8:	2785                	addiw	a5,a5,1
    800055ea:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055ee:	8526                	mv	a0,s1
    800055f0:	ffffe097          	auipc	ra,0xffffe
    800055f4:	1c6080e7          	jalr	454(ra) # 800037b6 <iupdate>
  iunlock(ip);
    800055f8:	8526                	mv	a0,s1
    800055fa:	ffffe097          	auipc	ra,0xffffe
    800055fe:	34c080e7          	jalr	844(ra) # 80003946 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005602:	fd040593          	addi	a1,s0,-48
    80005606:	f5040513          	addi	a0,s0,-176
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	a50080e7          	jalr	-1456(ra) # 8000405a <nameiparent>
    80005612:	892a                	mv	s2,a0
    80005614:	c935                	beqz	a0,80005688 <sys_link+0x10a>
  ilock(dp);
    80005616:	ffffe097          	auipc	ra,0xffffe
    8000561a:	26c080e7          	jalr	620(ra) # 80003882 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000561e:	00092703          	lw	a4,0(s2)
    80005622:	409c                	lw	a5,0(s1)
    80005624:	04f71d63          	bne	a4,a5,8000567e <sys_link+0x100>
    80005628:	40d0                	lw	a2,4(s1)
    8000562a:	fd040593          	addi	a1,s0,-48
    8000562e:	854a                	mv	a0,s2
    80005630:	fffff097          	auipc	ra,0xfffff
    80005634:	94a080e7          	jalr	-1718(ra) # 80003f7a <dirlink>
    80005638:	04054363          	bltz	a0,8000567e <sys_link+0x100>
  iunlockput(dp);
    8000563c:	854a                	mv	a0,s2
    8000563e:	ffffe097          	auipc	ra,0xffffe
    80005642:	4a8080e7          	jalr	1192(ra) # 80003ae6 <iunlockput>
  iput(ip);
    80005646:	8526                	mv	a0,s1
    80005648:	ffffe097          	auipc	ra,0xffffe
    8000564c:	3f6080e7          	jalr	1014(ra) # 80003a3e <iput>
  end_op();
    80005650:	fffff097          	auipc	ra,0xfffff
    80005654:	c7a080e7          	jalr	-902(ra) # 800042ca <end_op>
  return 0;
    80005658:	4781                	li	a5,0
    8000565a:	a085                	j	800056ba <sys_link+0x13c>
    end_op();
    8000565c:	fffff097          	auipc	ra,0xfffff
    80005660:	c6e080e7          	jalr	-914(ra) # 800042ca <end_op>
    return -1;
    80005664:	57fd                	li	a5,-1
    80005666:	a891                	j	800056ba <sys_link+0x13c>
    iunlockput(ip);
    80005668:	8526                	mv	a0,s1
    8000566a:	ffffe097          	auipc	ra,0xffffe
    8000566e:	47c080e7          	jalr	1148(ra) # 80003ae6 <iunlockput>
    end_op();
    80005672:	fffff097          	auipc	ra,0xfffff
    80005676:	c58080e7          	jalr	-936(ra) # 800042ca <end_op>
    return -1;
    8000567a:	57fd                	li	a5,-1
    8000567c:	a83d                	j	800056ba <sys_link+0x13c>
    iunlockput(dp);
    8000567e:	854a                	mv	a0,s2
    80005680:	ffffe097          	auipc	ra,0xffffe
    80005684:	466080e7          	jalr	1126(ra) # 80003ae6 <iunlockput>
  ilock(ip);
    80005688:	8526                	mv	a0,s1
    8000568a:	ffffe097          	auipc	ra,0xffffe
    8000568e:	1f8080e7          	jalr	504(ra) # 80003882 <ilock>
  ip->nlink--;
    80005692:	04a4d783          	lhu	a5,74(s1)
    80005696:	37fd                	addiw	a5,a5,-1
    80005698:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000569c:	8526                	mv	a0,s1
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	118080e7          	jalr	280(ra) # 800037b6 <iupdate>
  iunlockput(ip);
    800056a6:	8526                	mv	a0,s1
    800056a8:	ffffe097          	auipc	ra,0xffffe
    800056ac:	43e080e7          	jalr	1086(ra) # 80003ae6 <iunlockput>
  end_op();
    800056b0:	fffff097          	auipc	ra,0xfffff
    800056b4:	c1a080e7          	jalr	-998(ra) # 800042ca <end_op>
  return -1;
    800056b8:	57fd                	li	a5,-1
}
    800056ba:	853e                	mv	a0,a5
    800056bc:	70b2                	ld	ra,296(sp)
    800056be:	7412                	ld	s0,288(sp)
    800056c0:	64f2                	ld	s1,280(sp)
    800056c2:	6952                	ld	s2,272(sp)
    800056c4:	6155                	addi	sp,sp,304
    800056c6:	8082                	ret

00000000800056c8 <sys_unlink>:
{
    800056c8:	7151                	addi	sp,sp,-240
    800056ca:	f586                	sd	ra,232(sp)
    800056cc:	f1a2                	sd	s0,224(sp)
    800056ce:	eda6                	sd	s1,216(sp)
    800056d0:	e9ca                	sd	s2,208(sp)
    800056d2:	e5ce                	sd	s3,200(sp)
    800056d4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056d6:	08000613          	li	a2,128
    800056da:	f3040593          	addi	a1,s0,-208
    800056de:	4501                	li	a0,0
    800056e0:	ffffd097          	auipc	ra,0xffffd
    800056e4:	54a080e7          	jalr	1354(ra) # 80002c2a <argstr>
    800056e8:	16054f63          	bltz	a0,80005866 <sys_unlink+0x19e>
  begin_op();
    800056ec:	fffff097          	auipc	ra,0xfffff
    800056f0:	b5e080e7          	jalr	-1186(ra) # 8000424a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056f4:	fb040593          	addi	a1,s0,-80
    800056f8:	f3040513          	addi	a0,s0,-208
    800056fc:	fffff097          	auipc	ra,0xfffff
    80005700:	95e080e7          	jalr	-1698(ra) # 8000405a <nameiparent>
    80005704:	89aa                	mv	s3,a0
    80005706:	c979                	beqz	a0,800057dc <sys_unlink+0x114>
  ilock(dp);
    80005708:	ffffe097          	auipc	ra,0xffffe
    8000570c:	17a080e7          	jalr	378(ra) # 80003882 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005710:	00003597          	auipc	a1,0x3
    80005714:	16858593          	addi	a1,a1,360 # 80008878 <sysnames+0x3b8>
    80005718:	fb040513          	addi	a0,s0,-80
    8000571c:	ffffe097          	auipc	ra,0xffffe
    80005720:	62c080e7          	jalr	1580(ra) # 80003d48 <namecmp>
    80005724:	14050863          	beqz	a0,80005874 <sys_unlink+0x1ac>
    80005728:	00003597          	auipc	a1,0x3
    8000572c:	15858593          	addi	a1,a1,344 # 80008880 <sysnames+0x3c0>
    80005730:	fb040513          	addi	a0,s0,-80
    80005734:	ffffe097          	auipc	ra,0xffffe
    80005738:	614080e7          	jalr	1556(ra) # 80003d48 <namecmp>
    8000573c:	12050c63          	beqz	a0,80005874 <sys_unlink+0x1ac>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005740:	f2c40613          	addi	a2,s0,-212
    80005744:	fb040593          	addi	a1,s0,-80
    80005748:	854e                	mv	a0,s3
    8000574a:	ffffe097          	auipc	ra,0xffffe
    8000574e:	618080e7          	jalr	1560(ra) # 80003d62 <dirlookup>
    80005752:	84aa                	mv	s1,a0
    80005754:	12050063          	beqz	a0,80005874 <sys_unlink+0x1ac>
  ilock(ip);
    80005758:	ffffe097          	auipc	ra,0xffffe
    8000575c:	12a080e7          	jalr	298(ra) # 80003882 <ilock>
  if(ip->nlink < 1)
    80005760:	04a49783          	lh	a5,74(s1)
    80005764:	08f05263          	blez	a5,800057e8 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005768:	04449703          	lh	a4,68(s1)
    8000576c:	4785                	li	a5,1
    8000576e:	08f70563          	beq	a4,a5,800057f8 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005772:	4641                	li	a2,16
    80005774:	4581                	li	a1,0
    80005776:	fc040513          	addi	a0,s0,-64
    8000577a:	ffffb097          	auipc	ra,0xffffb
    8000577e:	62e080e7          	jalr	1582(ra) # 80000da8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005782:	4741                	li	a4,16
    80005784:	f2c42683          	lw	a3,-212(s0)
    80005788:	fc040613          	addi	a2,s0,-64
    8000578c:	4581                	li	a1,0
    8000578e:	854e                	mv	a0,s3
    80005790:	ffffe097          	auipc	ra,0xffffe
    80005794:	49e080e7          	jalr	1182(ra) # 80003c2e <writei>
    80005798:	47c1                	li	a5,16
    8000579a:	0af51363          	bne	a0,a5,80005840 <sys_unlink+0x178>
  if(ip->type == T_DIR){
    8000579e:	04449703          	lh	a4,68(s1)
    800057a2:	4785                	li	a5,1
    800057a4:	0af70663          	beq	a4,a5,80005850 <sys_unlink+0x188>
  iunlockput(dp);
    800057a8:	854e                	mv	a0,s3
    800057aa:	ffffe097          	auipc	ra,0xffffe
    800057ae:	33c080e7          	jalr	828(ra) # 80003ae6 <iunlockput>
  ip->nlink--;
    800057b2:	04a4d783          	lhu	a5,74(s1)
    800057b6:	37fd                	addiw	a5,a5,-1
    800057b8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057bc:	8526                	mv	a0,s1
    800057be:	ffffe097          	auipc	ra,0xffffe
    800057c2:	ff8080e7          	jalr	-8(ra) # 800037b6 <iupdate>
  iunlockput(ip);
    800057c6:	8526                	mv	a0,s1
    800057c8:	ffffe097          	auipc	ra,0xffffe
    800057cc:	31e080e7          	jalr	798(ra) # 80003ae6 <iunlockput>
  end_op();
    800057d0:	fffff097          	auipc	ra,0xfffff
    800057d4:	afa080e7          	jalr	-1286(ra) # 800042ca <end_op>
  return 0;
    800057d8:	4501                	li	a0,0
    800057da:	a07d                	j	80005888 <sys_unlink+0x1c0>
    end_op();
    800057dc:	fffff097          	auipc	ra,0xfffff
    800057e0:	aee080e7          	jalr	-1298(ra) # 800042ca <end_op>
    return -1;
    800057e4:	557d                	li	a0,-1
    800057e6:	a04d                	j	80005888 <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    800057e8:	00003517          	auipc	a0,0x3
    800057ec:	0c050513          	addi	a0,a0,192 # 800088a8 <sysnames+0x3e8>
    800057f0:	ffffb097          	auipc	ra,0xffffb
    800057f4:	d84080e7          	jalr	-636(ra) # 80000574 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057f8:	44f8                	lw	a4,76(s1)
    800057fa:	02000793          	li	a5,32
    800057fe:	f6e7fae3          	bleu	a4,a5,80005772 <sys_unlink+0xaa>
    80005802:	02000913          	li	s2,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005806:	4741                	li	a4,16
    80005808:	86ca                	mv	a3,s2
    8000580a:	f1840613          	addi	a2,s0,-232
    8000580e:	4581                	li	a1,0
    80005810:	8526                	mv	a0,s1
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	326080e7          	jalr	806(ra) # 80003b38 <readi>
    8000581a:	47c1                	li	a5,16
    8000581c:	00f51a63          	bne	a0,a5,80005830 <sys_unlink+0x168>
    if(de.inum != 0)
    80005820:	f1845783          	lhu	a5,-232(s0)
    80005824:	e3b9                	bnez	a5,8000586a <sys_unlink+0x1a2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005826:	2941                	addiw	s2,s2,16
    80005828:	44fc                	lw	a5,76(s1)
    8000582a:	fcf96ee3          	bltu	s2,a5,80005806 <sys_unlink+0x13e>
    8000582e:	b791                	j	80005772 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005830:	00003517          	auipc	a0,0x3
    80005834:	09050513          	addi	a0,a0,144 # 800088c0 <sysnames+0x400>
    80005838:	ffffb097          	auipc	ra,0xffffb
    8000583c:	d3c080e7          	jalr	-708(ra) # 80000574 <panic>
    panic("unlink: writei");
    80005840:	00003517          	auipc	a0,0x3
    80005844:	09850513          	addi	a0,a0,152 # 800088d8 <sysnames+0x418>
    80005848:	ffffb097          	auipc	ra,0xffffb
    8000584c:	d2c080e7          	jalr	-724(ra) # 80000574 <panic>
    dp->nlink--;
    80005850:	04a9d783          	lhu	a5,74(s3)
    80005854:	37fd                	addiw	a5,a5,-1
    80005856:	04f99523          	sh	a5,74(s3)
    iupdate(dp);
    8000585a:	854e                	mv	a0,s3
    8000585c:	ffffe097          	auipc	ra,0xffffe
    80005860:	f5a080e7          	jalr	-166(ra) # 800037b6 <iupdate>
    80005864:	b791                	j	800057a8 <sys_unlink+0xe0>
    return -1;
    80005866:	557d                	li	a0,-1
    80005868:	a005                	j	80005888 <sys_unlink+0x1c0>
    iunlockput(ip);
    8000586a:	8526                	mv	a0,s1
    8000586c:	ffffe097          	auipc	ra,0xffffe
    80005870:	27a080e7          	jalr	634(ra) # 80003ae6 <iunlockput>
  iunlockput(dp);
    80005874:	854e                	mv	a0,s3
    80005876:	ffffe097          	auipc	ra,0xffffe
    8000587a:	270080e7          	jalr	624(ra) # 80003ae6 <iunlockput>
  end_op();
    8000587e:	fffff097          	auipc	ra,0xfffff
    80005882:	a4c080e7          	jalr	-1460(ra) # 800042ca <end_op>
  return -1;
    80005886:	557d                	li	a0,-1
}
    80005888:	70ae                	ld	ra,232(sp)
    8000588a:	740e                	ld	s0,224(sp)
    8000588c:	64ee                	ld	s1,216(sp)
    8000588e:	694e                	ld	s2,208(sp)
    80005890:	69ae                	ld	s3,200(sp)
    80005892:	616d                	addi	sp,sp,240
    80005894:	8082                	ret

0000000080005896 <sys_open>:

uint64
sys_open(void)
{
    80005896:	7131                	addi	sp,sp,-192
    80005898:	fd06                	sd	ra,184(sp)
    8000589a:	f922                	sd	s0,176(sp)
    8000589c:	f526                	sd	s1,168(sp)
    8000589e:	f14a                	sd	s2,160(sp)
    800058a0:	ed4e                	sd	s3,152(sp)
    800058a2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058a4:	08000613          	li	a2,128
    800058a8:	f5040593          	addi	a1,s0,-176
    800058ac:	4501                	li	a0,0
    800058ae:	ffffd097          	auipc	ra,0xffffd
    800058b2:	37c080e7          	jalr	892(ra) # 80002c2a <argstr>
    return -1;
    800058b6:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058b8:	0c054163          	bltz	a0,8000597a <sys_open+0xe4>
    800058bc:	f4c40593          	addi	a1,s0,-180
    800058c0:	4505                	li	a0,1
    800058c2:	ffffd097          	auipc	ra,0xffffd
    800058c6:	324080e7          	jalr	804(ra) # 80002be6 <argint>
    800058ca:	0a054863          	bltz	a0,8000597a <sys_open+0xe4>

  begin_op();
    800058ce:	fffff097          	auipc	ra,0xfffff
    800058d2:	97c080e7          	jalr	-1668(ra) # 8000424a <begin_op>

  if(omode & O_CREATE){
    800058d6:	f4c42783          	lw	a5,-180(s0)
    800058da:	2007f793          	andi	a5,a5,512
    800058de:	cbdd                	beqz	a5,80005994 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800058e0:	4681                	li	a3,0
    800058e2:	4601                	li	a2,0
    800058e4:	4589                	li	a1,2
    800058e6:	f5040513          	addi	a0,s0,-176
    800058ea:	00000097          	auipc	ra,0x0
    800058ee:	976080e7          	jalr	-1674(ra) # 80005260 <create>
    800058f2:	892a                	mv	s2,a0
    if(ip == 0){
    800058f4:	c959                	beqz	a0,8000598a <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058f6:	04491703          	lh	a4,68(s2)
    800058fa:	478d                	li	a5,3
    800058fc:	00f71763          	bne	a4,a5,8000590a <sys_open+0x74>
    80005900:	04695703          	lhu	a4,70(s2)
    80005904:	47a5                	li	a5,9
    80005906:	0ce7ec63          	bltu	a5,a4,800059de <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000590a:	fffff097          	auipc	ra,0xfffff
    8000590e:	d72080e7          	jalr	-654(ra) # 8000467c <filealloc>
    80005912:	89aa                	mv	s3,a0
    80005914:	10050263          	beqz	a0,80005a18 <sys_open+0x182>
    80005918:	00000097          	auipc	ra,0x0
    8000591c:	900080e7          	jalr	-1792(ra) # 80005218 <fdalloc>
    80005920:	84aa                	mv	s1,a0
    80005922:	0e054663          	bltz	a0,80005a0e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005926:	04491703          	lh	a4,68(s2)
    8000592a:	478d                	li	a5,3
    8000592c:	0cf70463          	beq	a4,a5,800059f4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005930:	4789                	li	a5,2
    80005932:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005936:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000593a:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000593e:	f4c42783          	lw	a5,-180(s0)
    80005942:	0017c713          	xori	a4,a5,1
    80005946:	8b05                	andi	a4,a4,1
    80005948:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000594c:	0037f713          	andi	a4,a5,3
    80005950:	00e03733          	snez	a4,a4
    80005954:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005958:	4007f793          	andi	a5,a5,1024
    8000595c:	c791                	beqz	a5,80005968 <sys_open+0xd2>
    8000595e:	04491703          	lh	a4,68(s2)
    80005962:	4789                	li	a5,2
    80005964:	08f70f63          	beq	a4,a5,80005a02 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005968:	854a                	mv	a0,s2
    8000596a:	ffffe097          	auipc	ra,0xffffe
    8000596e:	fdc080e7          	jalr	-36(ra) # 80003946 <iunlock>
  end_op();
    80005972:	fffff097          	auipc	ra,0xfffff
    80005976:	958080e7          	jalr	-1704(ra) # 800042ca <end_op>

  return fd;
}
    8000597a:	8526                	mv	a0,s1
    8000597c:	70ea                	ld	ra,184(sp)
    8000597e:	744a                	ld	s0,176(sp)
    80005980:	74aa                	ld	s1,168(sp)
    80005982:	790a                	ld	s2,160(sp)
    80005984:	69ea                	ld	s3,152(sp)
    80005986:	6129                	addi	sp,sp,192
    80005988:	8082                	ret
      end_op();
    8000598a:	fffff097          	auipc	ra,0xfffff
    8000598e:	940080e7          	jalr	-1728(ra) # 800042ca <end_op>
      return -1;
    80005992:	b7e5                	j	8000597a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005994:	f5040513          	addi	a0,s0,-176
    80005998:	ffffe097          	auipc	ra,0xffffe
    8000599c:	6a4080e7          	jalr	1700(ra) # 8000403c <namei>
    800059a0:	892a                	mv	s2,a0
    800059a2:	c905                	beqz	a0,800059d2 <sys_open+0x13c>
    ilock(ip);
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	ede080e7          	jalr	-290(ra) # 80003882 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059ac:	04491703          	lh	a4,68(s2)
    800059b0:	4785                	li	a5,1
    800059b2:	f4f712e3          	bne	a4,a5,800058f6 <sys_open+0x60>
    800059b6:	f4c42783          	lw	a5,-180(s0)
    800059ba:	dba1                	beqz	a5,8000590a <sys_open+0x74>
      iunlockput(ip);
    800059bc:	854a                	mv	a0,s2
    800059be:	ffffe097          	auipc	ra,0xffffe
    800059c2:	128080e7          	jalr	296(ra) # 80003ae6 <iunlockput>
      end_op();
    800059c6:	fffff097          	auipc	ra,0xfffff
    800059ca:	904080e7          	jalr	-1788(ra) # 800042ca <end_op>
      return -1;
    800059ce:	54fd                	li	s1,-1
    800059d0:	b76d                	j	8000597a <sys_open+0xe4>
      end_op();
    800059d2:	fffff097          	auipc	ra,0xfffff
    800059d6:	8f8080e7          	jalr	-1800(ra) # 800042ca <end_op>
      return -1;
    800059da:	54fd                	li	s1,-1
    800059dc:	bf79                	j	8000597a <sys_open+0xe4>
    iunlockput(ip);
    800059de:	854a                	mv	a0,s2
    800059e0:	ffffe097          	auipc	ra,0xffffe
    800059e4:	106080e7          	jalr	262(ra) # 80003ae6 <iunlockput>
    end_op();
    800059e8:	fffff097          	auipc	ra,0xfffff
    800059ec:	8e2080e7          	jalr	-1822(ra) # 800042ca <end_op>
    return -1;
    800059f0:	54fd                	li	s1,-1
    800059f2:	b761                	j	8000597a <sys_open+0xe4>
    f->type = FD_DEVICE;
    800059f4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059f8:	04691783          	lh	a5,70(s2)
    800059fc:	02f99223          	sh	a5,36(s3)
    80005a00:	bf2d                	j	8000593a <sys_open+0xa4>
    itrunc(ip);
    80005a02:	854a                	mv	a0,s2
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	f8e080e7          	jalr	-114(ra) # 80003992 <itrunc>
    80005a0c:	bfb1                	j	80005968 <sys_open+0xd2>
      fileclose(f);
    80005a0e:	854e                	mv	a0,s3
    80005a10:	fffff097          	auipc	ra,0xfffff
    80005a14:	d3c080e7          	jalr	-708(ra) # 8000474c <fileclose>
    iunlockput(ip);
    80005a18:	854a                	mv	a0,s2
    80005a1a:	ffffe097          	auipc	ra,0xffffe
    80005a1e:	0cc080e7          	jalr	204(ra) # 80003ae6 <iunlockput>
    end_op();
    80005a22:	fffff097          	auipc	ra,0xfffff
    80005a26:	8a8080e7          	jalr	-1880(ra) # 800042ca <end_op>
    return -1;
    80005a2a:	54fd                	li	s1,-1
    80005a2c:	b7b9                	j	8000597a <sys_open+0xe4>

0000000080005a2e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a2e:	7175                	addi	sp,sp,-144
    80005a30:	e506                	sd	ra,136(sp)
    80005a32:	e122                	sd	s0,128(sp)
    80005a34:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a36:	fffff097          	auipc	ra,0xfffff
    80005a3a:	814080e7          	jalr	-2028(ra) # 8000424a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a3e:	08000613          	li	a2,128
    80005a42:	f7040593          	addi	a1,s0,-144
    80005a46:	4501                	li	a0,0
    80005a48:	ffffd097          	auipc	ra,0xffffd
    80005a4c:	1e2080e7          	jalr	482(ra) # 80002c2a <argstr>
    80005a50:	02054963          	bltz	a0,80005a82 <sys_mkdir+0x54>
    80005a54:	4681                	li	a3,0
    80005a56:	4601                	li	a2,0
    80005a58:	4585                	li	a1,1
    80005a5a:	f7040513          	addi	a0,s0,-144
    80005a5e:	00000097          	auipc	ra,0x0
    80005a62:	802080e7          	jalr	-2046(ra) # 80005260 <create>
    80005a66:	cd11                	beqz	a0,80005a82 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a68:	ffffe097          	auipc	ra,0xffffe
    80005a6c:	07e080e7          	jalr	126(ra) # 80003ae6 <iunlockput>
  end_op();
    80005a70:	fffff097          	auipc	ra,0xfffff
    80005a74:	85a080e7          	jalr	-1958(ra) # 800042ca <end_op>
  return 0;
    80005a78:	4501                	li	a0,0
}
    80005a7a:	60aa                	ld	ra,136(sp)
    80005a7c:	640a                	ld	s0,128(sp)
    80005a7e:	6149                	addi	sp,sp,144
    80005a80:	8082                	ret
    end_op();
    80005a82:	fffff097          	auipc	ra,0xfffff
    80005a86:	848080e7          	jalr	-1976(ra) # 800042ca <end_op>
    return -1;
    80005a8a:	557d                	li	a0,-1
    80005a8c:	b7fd                	j	80005a7a <sys_mkdir+0x4c>

0000000080005a8e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a8e:	7135                	addi	sp,sp,-160
    80005a90:	ed06                	sd	ra,152(sp)
    80005a92:	e922                	sd	s0,144(sp)
    80005a94:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a96:	ffffe097          	auipc	ra,0xffffe
    80005a9a:	7b4080e7          	jalr	1972(ra) # 8000424a <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a9e:	08000613          	li	a2,128
    80005aa2:	f7040593          	addi	a1,s0,-144
    80005aa6:	4501                	li	a0,0
    80005aa8:	ffffd097          	auipc	ra,0xffffd
    80005aac:	182080e7          	jalr	386(ra) # 80002c2a <argstr>
    80005ab0:	04054a63          	bltz	a0,80005b04 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005ab4:	f6c40593          	addi	a1,s0,-148
    80005ab8:	4505                	li	a0,1
    80005aba:	ffffd097          	auipc	ra,0xffffd
    80005abe:	12c080e7          	jalr	300(ra) # 80002be6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ac2:	04054163          	bltz	a0,80005b04 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005ac6:	f6840593          	addi	a1,s0,-152
    80005aca:	4509                	li	a0,2
    80005acc:	ffffd097          	auipc	ra,0xffffd
    80005ad0:	11a080e7          	jalr	282(ra) # 80002be6 <argint>
     argint(1, &major) < 0 ||
    80005ad4:	02054863          	bltz	a0,80005b04 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ad8:	f6841683          	lh	a3,-152(s0)
    80005adc:	f6c41603          	lh	a2,-148(s0)
    80005ae0:	458d                	li	a1,3
    80005ae2:	f7040513          	addi	a0,s0,-144
    80005ae6:	fffff097          	auipc	ra,0xfffff
    80005aea:	77a080e7          	jalr	1914(ra) # 80005260 <create>
     argint(2, &minor) < 0 ||
    80005aee:	c919                	beqz	a0,80005b04 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005af0:	ffffe097          	auipc	ra,0xffffe
    80005af4:	ff6080e7          	jalr	-10(ra) # 80003ae6 <iunlockput>
  end_op();
    80005af8:	ffffe097          	auipc	ra,0xffffe
    80005afc:	7d2080e7          	jalr	2002(ra) # 800042ca <end_op>
  return 0;
    80005b00:	4501                	li	a0,0
    80005b02:	a031                	j	80005b0e <sys_mknod+0x80>
    end_op();
    80005b04:	ffffe097          	auipc	ra,0xffffe
    80005b08:	7c6080e7          	jalr	1990(ra) # 800042ca <end_op>
    return -1;
    80005b0c:	557d                	li	a0,-1
}
    80005b0e:	60ea                	ld	ra,152(sp)
    80005b10:	644a                	ld	s0,144(sp)
    80005b12:	610d                	addi	sp,sp,160
    80005b14:	8082                	ret

0000000080005b16 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b16:	7135                	addi	sp,sp,-160
    80005b18:	ed06                	sd	ra,152(sp)
    80005b1a:	e922                	sd	s0,144(sp)
    80005b1c:	e526                	sd	s1,136(sp)
    80005b1e:	e14a                	sd	s2,128(sp)
    80005b20:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b22:	ffffc097          	auipc	ra,0xffffc
    80005b26:	f98080e7          	jalr	-104(ra) # 80001aba <myproc>
    80005b2a:	892a                	mv	s2,a0
  
  begin_op();
    80005b2c:	ffffe097          	auipc	ra,0xffffe
    80005b30:	71e080e7          	jalr	1822(ra) # 8000424a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b34:	08000613          	li	a2,128
    80005b38:	f6040593          	addi	a1,s0,-160
    80005b3c:	4501                	li	a0,0
    80005b3e:	ffffd097          	auipc	ra,0xffffd
    80005b42:	0ec080e7          	jalr	236(ra) # 80002c2a <argstr>
    80005b46:	04054b63          	bltz	a0,80005b9c <sys_chdir+0x86>
    80005b4a:	f6040513          	addi	a0,s0,-160
    80005b4e:	ffffe097          	auipc	ra,0xffffe
    80005b52:	4ee080e7          	jalr	1262(ra) # 8000403c <namei>
    80005b56:	84aa                	mv	s1,a0
    80005b58:	c131                	beqz	a0,80005b9c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b5a:	ffffe097          	auipc	ra,0xffffe
    80005b5e:	d28080e7          	jalr	-728(ra) # 80003882 <ilock>
  if(ip->type != T_DIR){
    80005b62:	04449703          	lh	a4,68(s1)
    80005b66:	4785                	li	a5,1
    80005b68:	04f71063          	bne	a4,a5,80005ba8 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b6c:	8526                	mv	a0,s1
    80005b6e:	ffffe097          	auipc	ra,0xffffe
    80005b72:	dd8080e7          	jalr	-552(ra) # 80003946 <iunlock>
  iput(p->cwd);
    80005b76:	15093503          	ld	a0,336(s2)
    80005b7a:	ffffe097          	auipc	ra,0xffffe
    80005b7e:	ec4080e7          	jalr	-316(ra) # 80003a3e <iput>
  end_op();
    80005b82:	ffffe097          	auipc	ra,0xffffe
    80005b86:	748080e7          	jalr	1864(ra) # 800042ca <end_op>
  p->cwd = ip;
    80005b8a:	14993823          	sd	s1,336(s2)
  return 0;
    80005b8e:	4501                	li	a0,0
}
    80005b90:	60ea                	ld	ra,152(sp)
    80005b92:	644a                	ld	s0,144(sp)
    80005b94:	64aa                	ld	s1,136(sp)
    80005b96:	690a                	ld	s2,128(sp)
    80005b98:	610d                	addi	sp,sp,160
    80005b9a:	8082                	ret
    end_op();
    80005b9c:	ffffe097          	auipc	ra,0xffffe
    80005ba0:	72e080e7          	jalr	1838(ra) # 800042ca <end_op>
    return -1;
    80005ba4:	557d                	li	a0,-1
    80005ba6:	b7ed                	j	80005b90 <sys_chdir+0x7a>
    iunlockput(ip);
    80005ba8:	8526                	mv	a0,s1
    80005baa:	ffffe097          	auipc	ra,0xffffe
    80005bae:	f3c080e7          	jalr	-196(ra) # 80003ae6 <iunlockput>
    end_op();
    80005bb2:	ffffe097          	auipc	ra,0xffffe
    80005bb6:	718080e7          	jalr	1816(ra) # 800042ca <end_op>
    return -1;
    80005bba:	557d                	li	a0,-1
    80005bbc:	bfd1                	j	80005b90 <sys_chdir+0x7a>

0000000080005bbe <sys_exec>:

uint64
sys_exec(void)
{
    80005bbe:	7145                	addi	sp,sp,-464
    80005bc0:	e786                	sd	ra,456(sp)
    80005bc2:	e3a2                	sd	s0,448(sp)
    80005bc4:	ff26                	sd	s1,440(sp)
    80005bc6:	fb4a                	sd	s2,432(sp)
    80005bc8:	f74e                	sd	s3,424(sp)
    80005bca:	f352                	sd	s4,416(sp)
    80005bcc:	ef56                	sd	s5,408(sp)
    80005bce:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bd0:	08000613          	li	a2,128
    80005bd4:	f4040593          	addi	a1,s0,-192
    80005bd8:	4501                	li	a0,0
    80005bda:	ffffd097          	auipc	ra,0xffffd
    80005bde:	050080e7          	jalr	80(ra) # 80002c2a <argstr>
    return -1;
    80005be2:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005be4:	0e054c63          	bltz	a0,80005cdc <sys_exec+0x11e>
    80005be8:	e3840593          	addi	a1,s0,-456
    80005bec:	4505                	li	a0,1
    80005bee:	ffffd097          	auipc	ra,0xffffd
    80005bf2:	01a080e7          	jalr	26(ra) # 80002c08 <argaddr>
    80005bf6:	0e054363          	bltz	a0,80005cdc <sys_exec+0x11e>
  }
  memset(argv, 0, sizeof(argv));
    80005bfa:	e4040913          	addi	s2,s0,-448
    80005bfe:	10000613          	li	a2,256
    80005c02:	4581                	li	a1,0
    80005c04:	854a                	mv	a0,s2
    80005c06:	ffffb097          	auipc	ra,0xffffb
    80005c0a:	1a2080e7          	jalr	418(ra) # 80000da8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c0e:	89ca                	mv	s3,s2
  memset(argv, 0, sizeof(argv));
    80005c10:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005c12:	02000a93          	li	s5,32
    80005c16:	00048a1b          	sext.w	s4,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c1a:	00349513          	slli	a0,s1,0x3
    80005c1e:	e3040593          	addi	a1,s0,-464
    80005c22:	e3843783          	ld	a5,-456(s0)
    80005c26:	953e                	add	a0,a0,a5
    80005c28:	ffffd097          	auipc	ra,0xffffd
    80005c2c:	f22080e7          	jalr	-222(ra) # 80002b4a <fetchaddr>
    80005c30:	02054a63          	bltz	a0,80005c64 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c34:	e3043783          	ld	a5,-464(s0)
    80005c38:	cfa9                	beqz	a5,80005c92 <sys_exec+0xd4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c3a:	ffffb097          	auipc	ra,0xffffb
    80005c3e:	f38080e7          	jalr	-200(ra) # 80000b72 <kalloc>
    80005c42:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80005c46:	cd19                	beqz	a0,80005c64 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c48:	6605                	lui	a2,0x1
    80005c4a:	85aa                	mv	a1,a0
    80005c4c:	e3043503          	ld	a0,-464(s0)
    80005c50:	ffffd097          	auipc	ra,0xffffd
    80005c54:	f4e080e7          	jalr	-178(ra) # 80002b9e <fetchstr>
    80005c58:	00054663          	bltz	a0,80005c64 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c5c:	0485                	addi	s1,s1,1
    80005c5e:	0921                	addi	s2,s2,8
    80005c60:	fb549be3          	bne	s1,s5,80005c16 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c64:	e4043503          	ld	a0,-448(s0)
    kfree(argv[i]);
  return -1;
    80005c68:	597d                	li	s2,-1
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c6a:	c92d                	beqz	a0,80005cdc <sys_exec+0x11e>
    kfree(argv[i]);
    80005c6c:	ffffb097          	auipc	ra,0xffffb
    80005c70:	e06080e7          	jalr	-506(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c74:	e4840493          	addi	s1,s0,-440
    80005c78:	10098993          	addi	s3,s3,256
    80005c7c:	6088                	ld	a0,0(s1)
    80005c7e:	cd31                	beqz	a0,80005cda <sys_exec+0x11c>
    kfree(argv[i]);
    80005c80:	ffffb097          	auipc	ra,0xffffb
    80005c84:	df2080e7          	jalr	-526(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c88:	04a1                	addi	s1,s1,8
    80005c8a:	ff3499e3          	bne	s1,s3,80005c7c <sys_exec+0xbe>
  return -1;
    80005c8e:	597d                	li	s2,-1
    80005c90:	a0b1                	j	80005cdc <sys_exec+0x11e>
      argv[i] = 0;
    80005c92:	0a0e                	slli	s4,s4,0x3
    80005c94:	fc040793          	addi	a5,s0,-64
    80005c98:	9a3e                	add	s4,s4,a5
    80005c9a:	e80a3023          	sd	zero,-384(s4)
  int ret = exec(path, argv);
    80005c9e:	e4040593          	addi	a1,s0,-448
    80005ca2:	f4040513          	addi	a0,s0,-192
    80005ca6:	fffff097          	auipc	ra,0xfffff
    80005caa:	166080e7          	jalr	358(ra) # 80004e0c <exec>
    80005cae:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cb0:	e4043503          	ld	a0,-448(s0)
    80005cb4:	c505                	beqz	a0,80005cdc <sys_exec+0x11e>
    kfree(argv[i]);
    80005cb6:	ffffb097          	auipc	ra,0xffffb
    80005cba:	dbc080e7          	jalr	-580(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cbe:	e4840493          	addi	s1,s0,-440
    80005cc2:	10098993          	addi	s3,s3,256
    80005cc6:	6088                	ld	a0,0(s1)
    80005cc8:	c911                	beqz	a0,80005cdc <sys_exec+0x11e>
    kfree(argv[i]);
    80005cca:	ffffb097          	auipc	ra,0xffffb
    80005cce:	da8080e7          	jalr	-600(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cd2:	04a1                	addi	s1,s1,8
    80005cd4:	ff3499e3          	bne	s1,s3,80005cc6 <sys_exec+0x108>
    80005cd8:	a011                	j	80005cdc <sys_exec+0x11e>
  return -1;
    80005cda:	597d                	li	s2,-1
}
    80005cdc:	854a                	mv	a0,s2
    80005cde:	60be                	ld	ra,456(sp)
    80005ce0:	641e                	ld	s0,448(sp)
    80005ce2:	74fa                	ld	s1,440(sp)
    80005ce4:	795a                	ld	s2,432(sp)
    80005ce6:	79ba                	ld	s3,424(sp)
    80005ce8:	7a1a                	ld	s4,416(sp)
    80005cea:	6afa                	ld	s5,408(sp)
    80005cec:	6179                	addi	sp,sp,464
    80005cee:	8082                	ret

0000000080005cf0 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005cf0:	7139                	addi	sp,sp,-64
    80005cf2:	fc06                	sd	ra,56(sp)
    80005cf4:	f822                	sd	s0,48(sp)
    80005cf6:	f426                	sd	s1,40(sp)
    80005cf8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005cfa:	ffffc097          	auipc	ra,0xffffc
    80005cfe:	dc0080e7          	jalr	-576(ra) # 80001aba <myproc>
    80005d02:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d04:	fd840593          	addi	a1,s0,-40
    80005d08:	4501                	li	a0,0
    80005d0a:	ffffd097          	auipc	ra,0xffffd
    80005d0e:	efe080e7          	jalr	-258(ra) # 80002c08 <argaddr>
    return -1;
    80005d12:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d14:	0c054f63          	bltz	a0,80005df2 <sys_pipe+0x102>
  if(pipealloc(&rf, &wf) < 0)
    80005d18:	fc840593          	addi	a1,s0,-56
    80005d1c:	fd040513          	addi	a0,s0,-48
    80005d20:	fffff097          	auipc	ra,0xfffff
    80005d24:	d74080e7          	jalr	-652(ra) # 80004a94 <pipealloc>
    return -1;
    80005d28:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d2a:	0c054463          	bltz	a0,80005df2 <sys_pipe+0x102>
  fd0 = -1;
    80005d2e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d32:	fd043503          	ld	a0,-48(s0)
    80005d36:	fffff097          	auipc	ra,0xfffff
    80005d3a:	4e2080e7          	jalr	1250(ra) # 80005218 <fdalloc>
    80005d3e:	fca42223          	sw	a0,-60(s0)
    80005d42:	08054b63          	bltz	a0,80005dd8 <sys_pipe+0xe8>
    80005d46:	fc843503          	ld	a0,-56(s0)
    80005d4a:	fffff097          	auipc	ra,0xfffff
    80005d4e:	4ce080e7          	jalr	1230(ra) # 80005218 <fdalloc>
    80005d52:	fca42023          	sw	a0,-64(s0)
    80005d56:	06054863          	bltz	a0,80005dc6 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d5a:	4691                	li	a3,4
    80005d5c:	fc440613          	addi	a2,s0,-60
    80005d60:	fd843583          	ld	a1,-40(s0)
    80005d64:	68a8                	ld	a0,80(s1)
    80005d66:	ffffc097          	auipc	ra,0xffffc
    80005d6a:	a30080e7          	jalr	-1488(ra) # 80001796 <copyout>
    80005d6e:	02054063          	bltz	a0,80005d8e <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d72:	4691                	li	a3,4
    80005d74:	fc040613          	addi	a2,s0,-64
    80005d78:	fd843583          	ld	a1,-40(s0)
    80005d7c:	0591                	addi	a1,a1,4
    80005d7e:	68a8                	ld	a0,80(s1)
    80005d80:	ffffc097          	auipc	ra,0xffffc
    80005d84:	a16080e7          	jalr	-1514(ra) # 80001796 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d88:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d8a:	06055463          	bgez	a0,80005df2 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80005d8e:	fc442783          	lw	a5,-60(s0)
    80005d92:	07e9                	addi	a5,a5,26
    80005d94:	078e                	slli	a5,a5,0x3
    80005d96:	97a6                	add	a5,a5,s1
    80005d98:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d9c:	fc042783          	lw	a5,-64(s0)
    80005da0:	07e9                	addi	a5,a5,26
    80005da2:	078e                	slli	a5,a5,0x3
    80005da4:	94be                	add	s1,s1,a5
    80005da6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005daa:	fd043503          	ld	a0,-48(s0)
    80005dae:	fffff097          	auipc	ra,0xfffff
    80005db2:	99e080e7          	jalr	-1634(ra) # 8000474c <fileclose>
    fileclose(wf);
    80005db6:	fc843503          	ld	a0,-56(s0)
    80005dba:	fffff097          	auipc	ra,0xfffff
    80005dbe:	992080e7          	jalr	-1646(ra) # 8000474c <fileclose>
    return -1;
    80005dc2:	57fd                	li	a5,-1
    80005dc4:	a03d                	j	80005df2 <sys_pipe+0x102>
    if(fd0 >= 0)
    80005dc6:	fc442783          	lw	a5,-60(s0)
    80005dca:	0007c763          	bltz	a5,80005dd8 <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005dce:	07e9                	addi	a5,a5,26
    80005dd0:	078e                	slli	a5,a5,0x3
    80005dd2:	94be                	add	s1,s1,a5
    80005dd4:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005dd8:	fd043503          	ld	a0,-48(s0)
    80005ddc:	fffff097          	auipc	ra,0xfffff
    80005de0:	970080e7          	jalr	-1680(ra) # 8000474c <fileclose>
    fileclose(wf);
    80005de4:	fc843503          	ld	a0,-56(s0)
    80005de8:	fffff097          	auipc	ra,0xfffff
    80005dec:	964080e7          	jalr	-1692(ra) # 8000474c <fileclose>
    return -1;
    80005df0:	57fd                	li	a5,-1
}
    80005df2:	853e                	mv	a0,a5
    80005df4:	70e2                	ld	ra,56(sp)
    80005df6:	7442                	ld	s0,48(sp)
    80005df8:	74a2                	ld	s1,40(sp)
    80005dfa:	6121                	addi	sp,sp,64
    80005dfc:	8082                	ret
	...

0000000080005e00 <kernelvec>:
    80005e00:	7111                	addi	sp,sp,-256
    80005e02:	e006                	sd	ra,0(sp)
    80005e04:	e40a                	sd	sp,8(sp)
    80005e06:	e80e                	sd	gp,16(sp)
    80005e08:	ec12                	sd	tp,24(sp)
    80005e0a:	f016                	sd	t0,32(sp)
    80005e0c:	f41a                	sd	t1,40(sp)
    80005e0e:	f81e                	sd	t2,48(sp)
    80005e10:	fc22                	sd	s0,56(sp)
    80005e12:	e0a6                	sd	s1,64(sp)
    80005e14:	e4aa                	sd	a0,72(sp)
    80005e16:	e8ae                	sd	a1,80(sp)
    80005e18:	ecb2                	sd	a2,88(sp)
    80005e1a:	f0b6                	sd	a3,96(sp)
    80005e1c:	f4ba                	sd	a4,104(sp)
    80005e1e:	f8be                	sd	a5,112(sp)
    80005e20:	fcc2                	sd	a6,120(sp)
    80005e22:	e146                	sd	a7,128(sp)
    80005e24:	e54a                	sd	s2,136(sp)
    80005e26:	e94e                	sd	s3,144(sp)
    80005e28:	ed52                	sd	s4,152(sp)
    80005e2a:	f156                	sd	s5,160(sp)
    80005e2c:	f55a                	sd	s6,168(sp)
    80005e2e:	f95e                	sd	s7,176(sp)
    80005e30:	fd62                	sd	s8,184(sp)
    80005e32:	e1e6                	sd	s9,192(sp)
    80005e34:	e5ea                	sd	s10,200(sp)
    80005e36:	e9ee                	sd	s11,208(sp)
    80005e38:	edf2                	sd	t3,216(sp)
    80005e3a:	f1f6                	sd	t4,224(sp)
    80005e3c:	f5fa                	sd	t5,232(sp)
    80005e3e:	f9fe                	sd	t6,240(sp)
    80005e40:	bd3fc0ef          	jal	ra,80002a12 <kerneltrap>
    80005e44:	6082                	ld	ra,0(sp)
    80005e46:	6122                	ld	sp,8(sp)
    80005e48:	61c2                	ld	gp,16(sp)
    80005e4a:	7282                	ld	t0,32(sp)
    80005e4c:	7322                	ld	t1,40(sp)
    80005e4e:	73c2                	ld	t2,48(sp)
    80005e50:	7462                	ld	s0,56(sp)
    80005e52:	6486                	ld	s1,64(sp)
    80005e54:	6526                	ld	a0,72(sp)
    80005e56:	65c6                	ld	a1,80(sp)
    80005e58:	6666                	ld	a2,88(sp)
    80005e5a:	7686                	ld	a3,96(sp)
    80005e5c:	7726                	ld	a4,104(sp)
    80005e5e:	77c6                	ld	a5,112(sp)
    80005e60:	7866                	ld	a6,120(sp)
    80005e62:	688a                	ld	a7,128(sp)
    80005e64:	692a                	ld	s2,136(sp)
    80005e66:	69ca                	ld	s3,144(sp)
    80005e68:	6a6a                	ld	s4,152(sp)
    80005e6a:	7a8a                	ld	s5,160(sp)
    80005e6c:	7b2a                	ld	s6,168(sp)
    80005e6e:	7bca                	ld	s7,176(sp)
    80005e70:	7c6a                	ld	s8,184(sp)
    80005e72:	6c8e                	ld	s9,192(sp)
    80005e74:	6d2e                	ld	s10,200(sp)
    80005e76:	6dce                	ld	s11,208(sp)
    80005e78:	6e6e                	ld	t3,216(sp)
    80005e7a:	7e8e                	ld	t4,224(sp)
    80005e7c:	7f2e                	ld	t5,232(sp)
    80005e7e:	7fce                	ld	t6,240(sp)
    80005e80:	6111                	addi	sp,sp,256
    80005e82:	10200073          	sret
    80005e86:	00000013          	nop
    80005e8a:	00000013          	nop
    80005e8e:	0001                	nop

0000000080005e90 <timervec>:
    80005e90:	34051573          	csrrw	a0,mscratch,a0
    80005e94:	e10c                	sd	a1,0(a0)
    80005e96:	e510                	sd	a2,8(a0)
    80005e98:	e914                	sd	a3,16(a0)
    80005e9a:	710c                	ld	a1,32(a0)
    80005e9c:	7510                	ld	a2,40(a0)
    80005e9e:	6194                	ld	a3,0(a1)
    80005ea0:	96b2                	add	a3,a3,a2
    80005ea2:	e194                	sd	a3,0(a1)
    80005ea4:	4589                	li	a1,2
    80005ea6:	14459073          	csrw	sip,a1
    80005eaa:	6914                	ld	a3,16(a0)
    80005eac:	6510                	ld	a2,8(a0)
    80005eae:	610c                	ld	a1,0(a0)
    80005eb0:	34051573          	csrrw	a0,mscratch,a0
    80005eb4:	30200073          	mret
	...

0000000080005eba <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eba:	1141                	addi	sp,sp,-16
    80005ebc:	e422                	sd	s0,8(sp)
    80005ebe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ec0:	0c0007b7          	lui	a5,0xc000
    80005ec4:	4705                	li	a4,1
    80005ec6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ec8:	c3d8                	sw	a4,4(a5)
}
    80005eca:	6422                	ld	s0,8(sp)
    80005ecc:	0141                	addi	sp,sp,16
    80005ece:	8082                	ret

0000000080005ed0 <plicinithart>:

void
plicinithart(void)
{
    80005ed0:	1141                	addi	sp,sp,-16
    80005ed2:	e406                	sd	ra,8(sp)
    80005ed4:	e022                	sd	s0,0(sp)
    80005ed6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ed8:	ffffc097          	auipc	ra,0xffffc
    80005edc:	bb6080e7          	jalr	-1098(ra) # 80001a8e <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ee0:	0085171b          	slliw	a4,a0,0x8
    80005ee4:	0c0027b7          	lui	a5,0xc002
    80005ee8:	97ba                	add	a5,a5,a4
    80005eea:	40200713          	li	a4,1026
    80005eee:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ef2:	00d5151b          	slliw	a0,a0,0xd
    80005ef6:	0c2017b7          	lui	a5,0xc201
    80005efa:	953e                	add	a0,a0,a5
    80005efc:	00052023          	sw	zero,0(a0)
}
    80005f00:	60a2                	ld	ra,8(sp)
    80005f02:	6402                	ld	s0,0(sp)
    80005f04:	0141                	addi	sp,sp,16
    80005f06:	8082                	ret

0000000080005f08 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f08:	1141                	addi	sp,sp,-16
    80005f0a:	e406                	sd	ra,8(sp)
    80005f0c:	e022                	sd	s0,0(sp)
    80005f0e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f10:	ffffc097          	auipc	ra,0xffffc
    80005f14:	b7e080e7          	jalr	-1154(ra) # 80001a8e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f18:	00d5151b          	slliw	a0,a0,0xd
    80005f1c:	0c2017b7          	lui	a5,0xc201
    80005f20:	97aa                	add	a5,a5,a0
  return irq;
}
    80005f22:	43c8                	lw	a0,4(a5)
    80005f24:	60a2                	ld	ra,8(sp)
    80005f26:	6402                	ld	s0,0(sp)
    80005f28:	0141                	addi	sp,sp,16
    80005f2a:	8082                	ret

0000000080005f2c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f2c:	1101                	addi	sp,sp,-32
    80005f2e:	ec06                	sd	ra,24(sp)
    80005f30:	e822                	sd	s0,16(sp)
    80005f32:	e426                	sd	s1,8(sp)
    80005f34:	1000                	addi	s0,sp,32
    80005f36:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f38:	ffffc097          	auipc	ra,0xffffc
    80005f3c:	b56080e7          	jalr	-1194(ra) # 80001a8e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f40:	00d5151b          	slliw	a0,a0,0xd
    80005f44:	0c2017b7          	lui	a5,0xc201
    80005f48:	97aa                	add	a5,a5,a0
    80005f4a:	c3c4                	sw	s1,4(a5)
}
    80005f4c:	60e2                	ld	ra,24(sp)
    80005f4e:	6442                	ld	s0,16(sp)
    80005f50:	64a2                	ld	s1,8(sp)
    80005f52:	6105                	addi	sp,sp,32
    80005f54:	8082                	ret

0000000080005f56 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f56:	1141                	addi	sp,sp,-16
    80005f58:	e406                	sd	ra,8(sp)
    80005f5a:	e022                	sd	s0,0(sp)
    80005f5c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f5e:	479d                	li	a5,7
    80005f60:	04a7cd63          	blt	a5,a0,80005fba <free_desc+0x64>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005f64:	0001d797          	auipc	a5,0x1d
    80005f68:	09c78793          	addi	a5,a5,156 # 80023000 <disk>
    80005f6c:	00a78733          	add	a4,a5,a0
    80005f70:	6789                	lui	a5,0x2
    80005f72:	97ba                	add	a5,a5,a4
    80005f74:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005f78:	eba9                	bnez	a5,80005fca <free_desc+0x74>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005f7a:	0001f797          	auipc	a5,0x1f
    80005f7e:	08678793          	addi	a5,a5,134 # 80025000 <disk+0x2000>
    80005f82:	639c                	ld	a5,0(a5)
    80005f84:	00451713          	slli	a4,a0,0x4
    80005f88:	97ba                	add	a5,a5,a4
    80005f8a:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005f8e:	0001d797          	auipc	a5,0x1d
    80005f92:	07278793          	addi	a5,a5,114 # 80023000 <disk>
    80005f96:	97aa                	add	a5,a5,a0
    80005f98:	6509                	lui	a0,0x2
    80005f9a:	953e                	add	a0,a0,a5
    80005f9c:	4785                	li	a5,1
    80005f9e:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005fa2:	0001f517          	auipc	a0,0x1f
    80005fa6:	07650513          	addi	a0,a0,118 # 80025018 <disk+0x2018>
    80005faa:	ffffc097          	auipc	ra,0xffffc
    80005fae:	4b8080e7          	jalr	1208(ra) # 80002462 <wakeup>
}
    80005fb2:	60a2                	ld	ra,8(sp)
    80005fb4:	6402                	ld	s0,0(sp)
    80005fb6:	0141                	addi	sp,sp,16
    80005fb8:	8082                	ret
    panic("virtio_disk_intr 1");
    80005fba:	00003517          	auipc	a0,0x3
    80005fbe:	92e50513          	addi	a0,a0,-1746 # 800088e8 <sysnames+0x428>
    80005fc2:	ffffa097          	auipc	ra,0xffffa
    80005fc6:	5b2080e7          	jalr	1458(ra) # 80000574 <panic>
    panic("virtio_disk_intr 2");
    80005fca:	00003517          	auipc	a0,0x3
    80005fce:	93650513          	addi	a0,a0,-1738 # 80008900 <sysnames+0x440>
    80005fd2:	ffffa097          	auipc	ra,0xffffa
    80005fd6:	5a2080e7          	jalr	1442(ra) # 80000574 <panic>

0000000080005fda <virtio_disk_init>:
{
    80005fda:	1101                	addi	sp,sp,-32
    80005fdc:	ec06                	sd	ra,24(sp)
    80005fde:	e822                	sd	s0,16(sp)
    80005fe0:	e426                	sd	s1,8(sp)
    80005fe2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005fe4:	00003597          	auipc	a1,0x3
    80005fe8:	93458593          	addi	a1,a1,-1740 # 80008918 <sysnames+0x458>
    80005fec:	0001f517          	auipc	a0,0x1f
    80005ff0:	0bc50513          	addi	a0,a0,188 # 800250a8 <disk+0x20a8>
    80005ff4:	ffffb097          	auipc	ra,0xffffb
    80005ff8:	c28080e7          	jalr	-984(ra) # 80000c1c <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ffc:	100017b7          	lui	a5,0x10001
    80006000:	4398                	lw	a4,0(a5)
    80006002:	2701                	sext.w	a4,a4
    80006004:	747277b7          	lui	a5,0x74727
    80006008:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000600c:	0ef71163          	bne	a4,a5,800060ee <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006010:	100017b7          	lui	a5,0x10001
    80006014:	43dc                	lw	a5,4(a5)
    80006016:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006018:	4705                	li	a4,1
    8000601a:	0ce79a63          	bne	a5,a4,800060ee <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000601e:	100017b7          	lui	a5,0x10001
    80006022:	479c                	lw	a5,8(a5)
    80006024:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006026:	4709                	li	a4,2
    80006028:	0ce79363          	bne	a5,a4,800060ee <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000602c:	100017b7          	lui	a5,0x10001
    80006030:	47d8                	lw	a4,12(a5)
    80006032:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006034:	554d47b7          	lui	a5,0x554d4
    80006038:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000603c:	0af71963          	bne	a4,a5,800060ee <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006040:	100017b7          	lui	a5,0x10001
    80006044:	4705                	li	a4,1
    80006046:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006048:	470d                	li	a4,3
    8000604a:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000604c:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000604e:	c7ffe737          	lui	a4,0xc7ffe
    80006052:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80006056:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006058:	2701                	sext.w	a4,a4
    8000605a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000605c:	472d                	li	a4,11
    8000605e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006060:	473d                	li	a4,15
    80006062:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006064:	6705                	lui	a4,0x1
    80006066:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006068:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000606c:	5bdc                	lw	a5,52(a5)
    8000606e:	2781                	sext.w	a5,a5
  if(max == 0)
    80006070:	c7d9                	beqz	a5,800060fe <virtio_disk_init+0x124>
  if(max < NUM)
    80006072:	471d                	li	a4,7
    80006074:	08f77d63          	bleu	a5,a4,8000610e <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006078:	100014b7          	lui	s1,0x10001
    8000607c:	47a1                	li	a5,8
    8000607e:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006080:	6609                	lui	a2,0x2
    80006082:	4581                	li	a1,0
    80006084:	0001d517          	auipc	a0,0x1d
    80006088:	f7c50513          	addi	a0,a0,-132 # 80023000 <disk>
    8000608c:	ffffb097          	auipc	ra,0xffffb
    80006090:	d1c080e7          	jalr	-740(ra) # 80000da8 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006094:	0001d717          	auipc	a4,0x1d
    80006098:	f6c70713          	addi	a4,a4,-148 # 80023000 <disk>
    8000609c:	00c75793          	srli	a5,a4,0xc
    800060a0:	2781                	sext.w	a5,a5
    800060a2:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    800060a4:	0001f797          	auipc	a5,0x1f
    800060a8:	f5c78793          	addi	a5,a5,-164 # 80025000 <disk+0x2000>
    800060ac:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    800060ae:	0001d717          	auipc	a4,0x1d
    800060b2:	fd270713          	addi	a4,a4,-46 # 80023080 <disk+0x80>
    800060b6:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    800060b8:	0001e717          	auipc	a4,0x1e
    800060bc:	f4870713          	addi	a4,a4,-184 # 80024000 <disk+0x1000>
    800060c0:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800060c2:	4705                	li	a4,1
    800060c4:	00e78c23          	sb	a4,24(a5)
    800060c8:	00e78ca3          	sb	a4,25(a5)
    800060cc:	00e78d23          	sb	a4,26(a5)
    800060d0:	00e78da3          	sb	a4,27(a5)
    800060d4:	00e78e23          	sb	a4,28(a5)
    800060d8:	00e78ea3          	sb	a4,29(a5)
    800060dc:	00e78f23          	sb	a4,30(a5)
    800060e0:	00e78fa3          	sb	a4,31(a5)
}
    800060e4:	60e2                	ld	ra,24(sp)
    800060e6:	6442                	ld	s0,16(sp)
    800060e8:	64a2                	ld	s1,8(sp)
    800060ea:	6105                	addi	sp,sp,32
    800060ec:	8082                	ret
    panic("could not find virtio disk");
    800060ee:	00003517          	auipc	a0,0x3
    800060f2:	83a50513          	addi	a0,a0,-1990 # 80008928 <sysnames+0x468>
    800060f6:	ffffa097          	auipc	ra,0xffffa
    800060fa:	47e080e7          	jalr	1150(ra) # 80000574 <panic>
    panic("virtio disk has no queue 0");
    800060fe:	00003517          	auipc	a0,0x3
    80006102:	84a50513          	addi	a0,a0,-1974 # 80008948 <sysnames+0x488>
    80006106:	ffffa097          	auipc	ra,0xffffa
    8000610a:	46e080e7          	jalr	1134(ra) # 80000574 <panic>
    panic("virtio disk max queue too short");
    8000610e:	00003517          	auipc	a0,0x3
    80006112:	85a50513          	addi	a0,a0,-1958 # 80008968 <sysnames+0x4a8>
    80006116:	ffffa097          	auipc	ra,0xffffa
    8000611a:	45e080e7          	jalr	1118(ra) # 80000574 <panic>

000000008000611e <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000611e:	7159                	addi	sp,sp,-112
    80006120:	f486                	sd	ra,104(sp)
    80006122:	f0a2                	sd	s0,96(sp)
    80006124:	eca6                	sd	s1,88(sp)
    80006126:	e8ca                	sd	s2,80(sp)
    80006128:	e4ce                	sd	s3,72(sp)
    8000612a:	e0d2                	sd	s4,64(sp)
    8000612c:	fc56                	sd	s5,56(sp)
    8000612e:	f85a                	sd	s6,48(sp)
    80006130:	f45e                	sd	s7,40(sp)
    80006132:	f062                	sd	s8,32(sp)
    80006134:	1880                	addi	s0,sp,112
    80006136:	892a                	mv	s2,a0
    80006138:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000613a:	00c52b83          	lw	s7,12(a0)
    8000613e:	001b9b9b          	slliw	s7,s7,0x1
    80006142:	1b82                	slli	s7,s7,0x20
    80006144:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80006148:	0001f517          	auipc	a0,0x1f
    8000614c:	f6050513          	addi	a0,a0,-160 # 800250a8 <disk+0x20a8>
    80006150:	ffffb097          	auipc	ra,0xffffb
    80006154:	b5c080e7          	jalr	-1188(ra) # 80000cac <acquire>
    if(disk.free[i]){
    80006158:	0001f997          	auipc	s3,0x1f
    8000615c:	ea898993          	addi	s3,s3,-344 # 80025000 <disk+0x2000>
  for(int i = 0; i < NUM; i++){
    80006160:	4b21                	li	s6,8
      disk.free[i] = 0;
    80006162:	0001da97          	auipc	s5,0x1d
    80006166:	e9ea8a93          	addi	s5,s5,-354 # 80023000 <disk>
  for(int i = 0; i < 3; i++){
    8000616a:	4a0d                	li	s4,3
    8000616c:	a079                	j	800061fa <virtio_disk_rw+0xdc>
      disk.free[i] = 0;
    8000616e:	00fa86b3          	add	a3,s5,a5
    80006172:	96ae                	add	a3,a3,a1
    80006174:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006178:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000617a:	0207ca63          	bltz	a5,800061ae <virtio_disk_rw+0x90>
  for(int i = 0; i < 3; i++){
    8000617e:	2485                	addiw	s1,s1,1
    80006180:	0711                	addi	a4,a4,4
    80006182:	25448163          	beq	s1,s4,800063c4 <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80006186:	863a                	mv	a2,a4
    if(disk.free[i]){
    80006188:	0189c783          	lbu	a5,24(s3)
    8000618c:	24079163          	bnez	a5,800063ce <virtio_disk_rw+0x2b0>
    80006190:	0001f697          	auipc	a3,0x1f
    80006194:	e8968693          	addi	a3,a3,-375 # 80025019 <disk+0x2019>
  for(int i = 0; i < NUM; i++){
    80006198:	87aa                	mv	a5,a0
    if(disk.free[i]){
    8000619a:	0006c803          	lbu	a6,0(a3)
    8000619e:	fc0818e3          	bnez	a6,8000616e <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800061a2:	2785                	addiw	a5,a5,1
    800061a4:	0685                	addi	a3,a3,1
    800061a6:	ff679ae3          	bne	a5,s6,8000619a <virtio_disk_rw+0x7c>
    idx[i] = alloc_desc();
    800061aa:	57fd                	li	a5,-1
    800061ac:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800061ae:	02905a63          	blez	s1,800061e2 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800061b2:	fa042503          	lw	a0,-96(s0)
    800061b6:	00000097          	auipc	ra,0x0
    800061ba:	da0080e7          	jalr	-608(ra) # 80005f56 <free_desc>
      for(int j = 0; j < i; j++)
    800061be:	4785                	li	a5,1
    800061c0:	0297d163          	ble	s1,a5,800061e2 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800061c4:	fa442503          	lw	a0,-92(s0)
    800061c8:	00000097          	auipc	ra,0x0
    800061cc:	d8e080e7          	jalr	-626(ra) # 80005f56 <free_desc>
      for(int j = 0; j < i; j++)
    800061d0:	4789                	li	a5,2
    800061d2:	0097d863          	ble	s1,a5,800061e2 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800061d6:	fa842503          	lw	a0,-88(s0)
    800061da:	00000097          	auipc	ra,0x0
    800061de:	d7c080e7          	jalr	-644(ra) # 80005f56 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061e2:	0001f597          	auipc	a1,0x1f
    800061e6:	ec658593          	addi	a1,a1,-314 # 800250a8 <disk+0x20a8>
    800061ea:	0001f517          	auipc	a0,0x1f
    800061ee:	e2e50513          	addi	a0,a0,-466 # 80025018 <disk+0x2018>
    800061f2:	ffffc097          	auipc	ra,0xffffc
    800061f6:	0ea080e7          	jalr	234(ra) # 800022dc <sleep>
  for(int i = 0; i < 3; i++){
    800061fa:	fa040713          	addi	a4,s0,-96
    800061fe:	4481                	li	s1,0
  for(int i = 0; i < NUM; i++){
    80006200:	4505                	li	a0,1
      disk.free[i] = 0;
    80006202:	6589                	lui	a1,0x2
    80006204:	b749                	j	80006186 <virtio_disk_rw+0x68>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    80006206:	4785                	li	a5,1
    80006208:	f8f42823          	sw	a5,-112(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    8000620c:	f8042a23          	sw	zero,-108(s0)
  buf0.sector = sector;
    80006210:	f9743c23          	sd	s7,-104(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006214:	fa042983          	lw	s3,-96(s0)
    80006218:	00499493          	slli	s1,s3,0x4
    8000621c:	0001fa17          	auipc	s4,0x1f
    80006220:	de4a0a13          	addi	s4,s4,-540 # 80025000 <disk+0x2000>
    80006224:	000a3a83          	ld	s5,0(s4)
    80006228:	9aa6                	add	s5,s5,s1
    8000622a:	f9040513          	addi	a0,s0,-112
    8000622e:	ffffb097          	auipc	ra,0xffffb
    80006232:	f72080e7          	jalr	-142(ra) # 800011a0 <kvmpa>
    80006236:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    8000623a:	000a3783          	ld	a5,0(s4)
    8000623e:	97a6                	add	a5,a5,s1
    80006240:	4741                	li	a4,16
    80006242:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006244:	000a3783          	ld	a5,0(s4)
    80006248:	97a6                	add	a5,a5,s1
    8000624a:	4705                	li	a4,1
    8000624c:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80006250:	fa442703          	lw	a4,-92(s0)
    80006254:	000a3783          	ld	a5,0(s4)
    80006258:	97a6                	add	a5,a5,s1
    8000625a:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000625e:	0712                	slli	a4,a4,0x4
    80006260:	000a3783          	ld	a5,0(s4)
    80006264:	97ba                	add	a5,a5,a4
    80006266:	05890693          	addi	a3,s2,88
    8000626a:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    8000626c:	000a3783          	ld	a5,0(s4)
    80006270:	97ba                	add	a5,a5,a4
    80006272:	40000693          	li	a3,1024
    80006276:	c794                	sw	a3,8(a5)
  if(write)
    80006278:	100c0863          	beqz	s8,80006388 <virtio_disk_rw+0x26a>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000627c:	000a3783          	ld	a5,0(s4)
    80006280:	97ba                	add	a5,a5,a4
    80006282:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006286:	0001d517          	auipc	a0,0x1d
    8000628a:	d7a50513          	addi	a0,a0,-646 # 80023000 <disk>
    8000628e:	0001f797          	auipc	a5,0x1f
    80006292:	d7278793          	addi	a5,a5,-654 # 80025000 <disk+0x2000>
    80006296:	6394                	ld	a3,0(a5)
    80006298:	96ba                	add	a3,a3,a4
    8000629a:	00c6d603          	lhu	a2,12(a3)
    8000629e:	00166613          	ori	a2,a2,1
    800062a2:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800062a6:	fa842683          	lw	a3,-88(s0)
    800062aa:	6390                	ld	a2,0(a5)
    800062ac:	9732                	add	a4,a4,a2
    800062ae:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    800062b2:	20098613          	addi	a2,s3,512
    800062b6:	0612                	slli	a2,a2,0x4
    800062b8:	962a                	add	a2,a2,a0
    800062ba:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800062be:	00469713          	slli	a4,a3,0x4
    800062c2:	6394                	ld	a3,0(a5)
    800062c4:	96ba                	add	a3,a3,a4
    800062c6:	6589                	lui	a1,0x2
    800062c8:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    800062cc:	94ae                	add	s1,s1,a1
    800062ce:	94aa                	add	s1,s1,a0
    800062d0:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    800062d2:	6394                	ld	a3,0(a5)
    800062d4:	96ba                	add	a3,a3,a4
    800062d6:	4585                	li	a1,1
    800062d8:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800062da:	6394                	ld	a3,0(a5)
    800062dc:	96ba                	add	a3,a3,a4
    800062de:	4509                	li	a0,2
    800062e0:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    800062e4:	6394                	ld	a3,0(a5)
    800062e6:	9736                	add	a4,a4,a3
    800062e8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062ec:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800062f0:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    800062f4:	6794                	ld	a3,8(a5)
    800062f6:	0026d703          	lhu	a4,2(a3)
    800062fa:	8b1d                	andi	a4,a4,7
    800062fc:	2709                	addiw	a4,a4,2
    800062fe:	0706                	slli	a4,a4,0x1
    80006300:	9736                	add	a4,a4,a3
    80006302:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    80006306:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    8000630a:	6798                	ld	a4,8(a5)
    8000630c:	00275783          	lhu	a5,2(a4)
    80006310:	2785                	addiw	a5,a5,1
    80006312:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006316:	100017b7          	lui	a5,0x10001
    8000631a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000631e:	00492703          	lw	a4,4(s2)
    80006322:	4785                	li	a5,1
    80006324:	02f71163          	bne	a4,a5,80006346 <virtio_disk_rw+0x228>
    sleep(b, &disk.vdisk_lock);
    80006328:	0001f997          	auipc	s3,0x1f
    8000632c:	d8098993          	addi	s3,s3,-640 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    80006330:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006332:	85ce                	mv	a1,s3
    80006334:	854a                	mv	a0,s2
    80006336:	ffffc097          	auipc	ra,0xffffc
    8000633a:	fa6080e7          	jalr	-90(ra) # 800022dc <sleep>
  while(b->disk == 1) {
    8000633e:	00492783          	lw	a5,4(s2)
    80006342:	fe9788e3          	beq	a5,s1,80006332 <virtio_disk_rw+0x214>
  }

  disk.info[idx[0]].b = 0;
    80006346:	fa042483          	lw	s1,-96(s0)
    8000634a:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    8000634e:	00479713          	slli	a4,a5,0x4
    80006352:	0001d797          	auipc	a5,0x1d
    80006356:	cae78793          	addi	a5,a5,-850 # 80023000 <disk>
    8000635a:	97ba                	add	a5,a5,a4
    8000635c:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006360:	0001f917          	auipc	s2,0x1f
    80006364:	ca090913          	addi	s2,s2,-864 # 80025000 <disk+0x2000>
    free_desc(i);
    80006368:	8526                	mv	a0,s1
    8000636a:	00000097          	auipc	ra,0x0
    8000636e:	bec080e7          	jalr	-1044(ra) # 80005f56 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006372:	0492                	slli	s1,s1,0x4
    80006374:	00093783          	ld	a5,0(s2)
    80006378:	94be                	add	s1,s1,a5
    8000637a:	00c4d783          	lhu	a5,12(s1)
    8000637e:	8b85                	andi	a5,a5,1
    80006380:	cf91                	beqz	a5,8000639c <virtio_disk_rw+0x27e>
      i = disk.desc[i].next;
    80006382:	00e4d483          	lhu	s1,14(s1)
  while(1){
    80006386:	b7cd                	j	80006368 <virtio_disk_rw+0x24a>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006388:	0001f797          	auipc	a5,0x1f
    8000638c:	c7878793          	addi	a5,a5,-904 # 80025000 <disk+0x2000>
    80006390:	639c                	ld	a5,0(a5)
    80006392:	97ba                	add	a5,a5,a4
    80006394:	4689                	li	a3,2
    80006396:	00d79623          	sh	a3,12(a5)
    8000639a:	b5f5                	j	80006286 <virtio_disk_rw+0x168>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000639c:	0001f517          	auipc	a0,0x1f
    800063a0:	d0c50513          	addi	a0,a0,-756 # 800250a8 <disk+0x20a8>
    800063a4:	ffffb097          	auipc	ra,0xffffb
    800063a8:	9bc080e7          	jalr	-1604(ra) # 80000d60 <release>
}
    800063ac:	70a6                	ld	ra,104(sp)
    800063ae:	7406                	ld	s0,96(sp)
    800063b0:	64e6                	ld	s1,88(sp)
    800063b2:	6946                	ld	s2,80(sp)
    800063b4:	69a6                	ld	s3,72(sp)
    800063b6:	6a06                	ld	s4,64(sp)
    800063b8:	7ae2                	ld	s5,56(sp)
    800063ba:	7b42                	ld	s6,48(sp)
    800063bc:	7ba2                	ld	s7,40(sp)
    800063be:	7c02                	ld	s8,32(sp)
    800063c0:	6165                	addi	sp,sp,112
    800063c2:	8082                	ret
  if(write)
    800063c4:	e40c11e3          	bnez	s8,80006206 <virtio_disk_rw+0xe8>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    800063c8:	f8042823          	sw	zero,-112(s0)
    800063cc:	b581                	j	8000620c <virtio_disk_rw+0xee>
      disk.free[i] = 0;
    800063ce:	00098c23          	sb	zero,24(s3)
    idx[i] = alloc_desc();
    800063d2:	00072023          	sw	zero,0(a4)
    if(idx[i] < 0){
    800063d6:	b365                	j	8000617e <virtio_disk_rw+0x60>

00000000800063d8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800063d8:	1101                	addi	sp,sp,-32
    800063da:	ec06                	sd	ra,24(sp)
    800063dc:	e822                	sd	s0,16(sp)
    800063de:	e426                	sd	s1,8(sp)
    800063e0:	e04a                	sd	s2,0(sp)
    800063e2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800063e4:	0001f517          	auipc	a0,0x1f
    800063e8:	cc450513          	addi	a0,a0,-828 # 800250a8 <disk+0x20a8>
    800063ec:	ffffb097          	auipc	ra,0xffffb
    800063f0:	8c0080e7          	jalr	-1856(ra) # 80000cac <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800063f4:	0001f797          	auipc	a5,0x1f
    800063f8:	c0c78793          	addi	a5,a5,-1012 # 80025000 <disk+0x2000>
    800063fc:	0207d683          	lhu	a3,32(a5)
    80006400:	6b98                	ld	a4,16(a5)
    80006402:	00275783          	lhu	a5,2(a4)
    80006406:	8fb5                	xor	a5,a5,a3
    80006408:	8b9d                	andi	a5,a5,7
    8000640a:	c7c9                	beqz	a5,80006494 <virtio_disk_intr+0xbc>
    int id = disk.used->elems[disk.used_idx].id;
    8000640c:	068e                	slli	a3,a3,0x3
    8000640e:	9736                	add	a4,a4,a3
    80006410:	435c                	lw	a5,4(a4)

    if(disk.info[id].status != 0)
    80006412:	20078713          	addi	a4,a5,512
    80006416:	00471693          	slli	a3,a4,0x4
    8000641a:	0001d717          	auipc	a4,0x1d
    8000641e:	be670713          	addi	a4,a4,-1050 # 80023000 <disk>
    80006422:	9736                	add	a4,a4,a3
    80006424:	03074703          	lbu	a4,48(a4)
    80006428:	ef31                	bnez	a4,80006484 <virtio_disk_intr+0xac>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000642a:	0001d917          	auipc	s2,0x1d
    8000642e:	bd690913          	addi	s2,s2,-1066 # 80023000 <disk>
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006432:	0001f497          	auipc	s1,0x1f
    80006436:	bce48493          	addi	s1,s1,-1074 # 80025000 <disk+0x2000>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000643a:	20078793          	addi	a5,a5,512
    8000643e:	0792                	slli	a5,a5,0x4
    80006440:	97ca                	add	a5,a5,s2
    80006442:	7798                	ld	a4,40(a5)
    80006444:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    80006448:	7788                	ld	a0,40(a5)
    8000644a:	ffffc097          	auipc	ra,0xffffc
    8000644e:	018080e7          	jalr	24(ra) # 80002462 <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006452:	0204d783          	lhu	a5,32(s1)
    80006456:	2785                	addiw	a5,a5,1
    80006458:	8b9d                	andi	a5,a5,7
    8000645a:	03079613          	slli	a2,a5,0x30
    8000645e:	9241                	srli	a2,a2,0x30
    80006460:	02c49023          	sh	a2,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006464:	6898                	ld	a4,16(s1)
    80006466:	00275683          	lhu	a3,2(a4)
    8000646a:	8a9d                	andi	a3,a3,7
    8000646c:	02c68463          	beq	a3,a2,80006494 <virtio_disk_intr+0xbc>
    int id = disk.used->elems[disk.used_idx].id;
    80006470:	078e                	slli	a5,a5,0x3
    80006472:	97ba                	add	a5,a5,a4
    80006474:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006476:	20078713          	addi	a4,a5,512
    8000647a:	0712                	slli	a4,a4,0x4
    8000647c:	974a                	add	a4,a4,s2
    8000647e:	03074703          	lbu	a4,48(a4)
    80006482:	df45                	beqz	a4,8000643a <virtio_disk_intr+0x62>
      panic("virtio_disk_intr status");
    80006484:	00002517          	auipc	a0,0x2
    80006488:	50450513          	addi	a0,a0,1284 # 80008988 <sysnames+0x4c8>
    8000648c:	ffffa097          	auipc	ra,0xffffa
    80006490:	0e8080e7          	jalr	232(ra) # 80000574 <panic>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006494:	10001737          	lui	a4,0x10001
    80006498:	533c                	lw	a5,96(a4)
    8000649a:	8b8d                	andi	a5,a5,3
    8000649c:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    8000649e:	0001f517          	auipc	a0,0x1f
    800064a2:	c0a50513          	addi	a0,a0,-1014 # 800250a8 <disk+0x20a8>
    800064a6:	ffffb097          	auipc	ra,0xffffb
    800064aa:	8ba080e7          	jalr	-1862(ra) # 80000d60 <release>
}
    800064ae:	60e2                	ld	ra,24(sp)
    800064b0:	6442                	ld	s0,16(sp)
    800064b2:	64a2                	ld	s1,8(sp)
    800064b4:	6902                	ld	s2,0(sp)
    800064b6:	6105                	addi	sp,sp,32
    800064b8:	8082                	ret
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
