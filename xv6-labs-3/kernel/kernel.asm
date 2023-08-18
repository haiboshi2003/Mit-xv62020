
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	94013103          	ld	sp,-1728(sp) # 80008940 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000062:	fb278793          	addi	a5,a5,-78 # 80006010 <timervec>
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
    80000096:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd77df>
    8000009a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009c:	6705                	lui	a4,0x1
    8000009e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a4:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a8:	00001797          	auipc	a5,0x1
    800000ac:	e8a78793          	addi	a5,a5,-374 # 80000f32 <main>
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
    80000112:	b54080e7          	jalr	-1196(ra) # 80000c62 <acquire>
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
    8000012c:	6f4080e7          	jalr	1780(ra) # 8000281c <either_copyin>
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
    80000154:	bc6080e7          	jalr	-1082(ra) # 80000d16 <release>

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
    800001a4:	ac2080e7          	jalr	-1342(ra) # 80000c62 <acquire>
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
    800001d4:	8ca080e7          	jalr	-1846(ra) # 80001a9a <myproc>
    800001d8:	591c                	lw	a5,48(a0)
    800001da:	eba5                	bnez	a5,8000024a <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001dc:	85ce                	mv	a1,s3
    800001de:	854a                	mv	a0,s2
    800001e0:	00002097          	auipc	ra,0x2
    800001e4:	384080e7          	jalr	900(ra) # 80002564 <sleep>
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
    80000220:	5aa080e7          	jalr	1450(ra) # 800027c6 <either_copyout>
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
    80000240:	ada080e7          	jalr	-1318(ra) # 80000d16 <release>

  return target - n;
    80000244:	414b053b          	subw	a0,s6,s4
    80000248:	a811                	j	8000025c <consoleread+0xec>
        release(&cons.lock);
    8000024a:	00011517          	auipc	a0,0x11
    8000024e:	5e650513          	addi	a0,a0,1510 # 80011830 <cons>
    80000252:	00001097          	auipc	ra,0x1
    80000256:	ac4080e7          	jalr	-1340(ra) # 80000d16 <release>
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
    800002e8:	97e080e7          	jalr	-1666(ra) # 80000c62 <acquire>

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
    8000041a:	45c080e7          	jalr	1116(ra) # 80002872 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000041e:	00011517          	auipc	a0,0x11
    80000422:	41250513          	addi	a0,a0,1042 # 80011830 <cons>
    80000426:	00001097          	auipc	ra,0x1
    8000042a:	8f0080e7          	jalr	-1808(ra) # 80000d16 <release>
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
    8000047c:	272080e7          	jalr	626(ra) # 800026ea <wakeup>
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
    8000049e:	738080e7          	jalr	1848(ra) # 80000bd2 <initlock>

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
    80000638:	62e080e7          	jalr	1582(ra) # 80000c62 <acquire>
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
    8000079e:	57c080e7          	jalr	1404(ra) # 80000d16 <release>
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
    800007c4:	412080e7          	jalr	1042(ra) # 80000bd2 <initlock>
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
    8000081a:	3bc080e7          	jalr	956(ra) # 80000bd2 <initlock>
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
    80000836:	3e4080e7          	jalr	996(ra) # 80000c16 <push_off>

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
    8000086c:	44e080e7          	jalr	1102(ra) # 80000cb6 <pop_off>
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
    800008f2:	dfc080e7          	jalr	-516(ra) # 800026ea <wakeup>
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
    80000944:	322080e7          	jalr	802(ra) # 80000c62 <acquire>
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
    800009a2:	bc6080e7          	jalr	-1082(ra) # 80002564 <sleep>
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
    800009e6:	334080e7          	jalr	820(ra) # 80000d16 <release>
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
    80000a52:	214080e7          	jalr	532(ra) # 80000c62 <acquire>
  uartstart();
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	e24080e7          	jalr	-476(ra) # 8000087a <uartstart>
  release(&uart_tx_lock);
    80000a5e:	8526                	mv	a0,s1
    80000a60:	00000097          	auipc	ra,0x0
    80000a64:	2b6080e7          	jalr	694(ra) # 80000d16 <release>
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
    80000a88:	00026797          	auipc	a5,0x26
    80000a8c:	59878793          	addi	a5,a5,1432 # 80027020 <end>
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
    80000aa4:	2be080e7          	jalr	702(ra) # 80000d5e <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000aa8:	00011917          	auipc	s2,0x11
    80000aac:	e8890913          	addi	s2,s2,-376 # 80011930 <kmem>
    80000ab0:	854a                	mv	a0,s2
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	1b0080e7          	jalr	432(ra) # 80000c62 <acquire>
  r->next = kmem.freelist;
    80000aba:	01893783          	ld	a5,24(s2)
    80000abe:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ac0:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000ac4:	854a                	mv	a0,s2
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	250080e7          	jalr	592(ra) # 80000d16 <release>
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
    80000b52:	084080e7          	jalr	132(ra) # 80000bd2 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b56:	45c5                	li	a1,17
    80000b58:	05ee                	slli	a1,a1,0x1b
    80000b5a:	00026517          	auipc	a0,0x26
    80000b5e:	4c650513          	addi	a0,a0,1222 # 80027020 <end>
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
    80000b8a:	0dc080e7          	jalr	220(ra) # 80000c62 <acquire>
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
    80000ba2:	178080e7          	jalr	376(ra) # 80000d16 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000ba6:	6605                	lui	a2,0x1
    80000ba8:	4595                	li	a1,5
    80000baa:	8526                	mv	a0,s1
    80000bac:	00000097          	auipc	ra,0x0
    80000bb0:	1b2080e7          	jalr	434(ra) # 80000d5e <memset>
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
    80000bcc:	14e080e7          	jalr	334(ra) # 80000d16 <release>
  if(r)
    80000bd0:	b7d5                	j	80000bb4 <kalloc+0x42>

0000000080000bd2 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bd2:	1141                	addi	sp,sp,-16
    80000bd4:	e422                	sd	s0,8(sp)
    80000bd6:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bd8:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bda:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bde:	00053823          	sd	zero,16(a0)
}
    80000be2:	6422                	ld	s0,8(sp)
    80000be4:	0141                	addi	sp,sp,16
    80000be6:	8082                	ret

0000000080000be8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000be8:	411c                	lw	a5,0(a0)
    80000bea:	e399                	bnez	a5,80000bf0 <holding+0x8>
    80000bec:	4501                	li	a0,0
  return r;
}
    80000bee:	8082                	ret
{
    80000bf0:	1101                	addi	sp,sp,-32
    80000bf2:	ec06                	sd	ra,24(sp)
    80000bf4:	e822                	sd	s0,16(sp)
    80000bf6:	e426                	sd	s1,8(sp)
    80000bf8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bfa:	6904                	ld	s1,16(a0)
    80000bfc:	00001097          	auipc	ra,0x1
    80000c00:	e82080e7          	jalr	-382(ra) # 80001a7e <mycpu>
    80000c04:	40a48533          	sub	a0,s1,a0
    80000c08:	00153513          	seqz	a0,a0
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	addi	sp,sp,32
    80000c14:	8082                	ret

0000000080000c16 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c16:	1101                	addi	sp,sp,-32
    80000c18:	ec06                	sd	ra,24(sp)
    80000c1a:	e822                	sd	s0,16(sp)
    80000c1c:	e426                	sd	s1,8(sp)
    80000c1e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c20:	100024f3          	csrr	s1,sstatus
    80000c24:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c28:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c2a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	e50080e7          	jalr	-432(ra) # 80001a7e <mycpu>
    80000c36:	5d3c                	lw	a5,120(a0)
    80000c38:	cf89                	beqz	a5,80000c52 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c3a:	00001097          	auipc	ra,0x1
    80000c3e:	e44080e7          	jalr	-444(ra) # 80001a7e <mycpu>
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	2785                	addiw	a5,a5,1
    80000c46:	dd3c                	sw	a5,120(a0)
}
    80000c48:	60e2                	ld	ra,24(sp)
    80000c4a:	6442                	ld	s0,16(sp)
    80000c4c:	64a2                	ld	s1,8(sp)
    80000c4e:	6105                	addi	sp,sp,32
    80000c50:	8082                	ret
    mycpu()->intena = old;
    80000c52:	00001097          	auipc	ra,0x1
    80000c56:	e2c080e7          	jalr	-468(ra) # 80001a7e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c5a:	8085                	srli	s1,s1,0x1
    80000c5c:	8885                	andi	s1,s1,1
    80000c5e:	dd64                	sw	s1,124(a0)
    80000c60:	bfe9                	j	80000c3a <push_off+0x24>

0000000080000c62 <acquire>:
{
    80000c62:	1101                	addi	sp,sp,-32
    80000c64:	ec06                	sd	ra,24(sp)
    80000c66:	e822                	sd	s0,16(sp)
    80000c68:	e426                	sd	s1,8(sp)
    80000c6a:	1000                	addi	s0,sp,32
    80000c6c:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	fa8080e7          	jalr	-88(ra) # 80000c16 <push_off>
  if(holding(lk))
    80000c76:	8526                	mv	a0,s1
    80000c78:	00000097          	auipc	ra,0x0
    80000c7c:	f70080e7          	jalr	-144(ra) # 80000be8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c80:	4705                	li	a4,1
  if(holding(lk))
    80000c82:	e115                	bnez	a0,80000ca6 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c84:	87ba                	mv	a5,a4
    80000c86:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c8a:	2781                	sext.w	a5,a5
    80000c8c:	ffe5                	bnez	a5,80000c84 <acquire+0x22>
  __sync_synchronize();
    80000c8e:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c92:	00001097          	auipc	ra,0x1
    80000c96:	dec080e7          	jalr	-532(ra) # 80001a7e <mycpu>
    80000c9a:	e888                	sd	a0,16(s1)
}
    80000c9c:	60e2                	ld	ra,24(sp)
    80000c9e:	6442                	ld	s0,16(sp)
    80000ca0:	64a2                	ld	s1,8(sp)
    80000ca2:	6105                	addi	sp,sp,32
    80000ca4:	8082                	ret
    panic("acquire");
    80000ca6:	00007517          	auipc	a0,0x7
    80000caa:	3ca50513          	addi	a0,a0,970 # 80008070 <digits+0x58>
    80000cae:	00000097          	auipc	ra,0x0
    80000cb2:	8c6080e7          	jalr	-1850(ra) # 80000574 <panic>

0000000080000cb6 <pop_off>:

void
pop_off(void)
{
    80000cb6:	1141                	addi	sp,sp,-16
    80000cb8:	e406                	sd	ra,8(sp)
    80000cba:	e022                	sd	s0,0(sp)
    80000cbc:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cbe:	00001097          	auipc	ra,0x1
    80000cc2:	dc0080e7          	jalr	-576(ra) # 80001a7e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cc6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cca:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000ccc:	e78d                	bnez	a5,80000cf6 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cce:	5d3c                	lw	a5,120(a0)
    80000cd0:	02f05b63          	blez	a5,80000d06 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000cd4:	37fd                	addiw	a5,a5,-1
    80000cd6:	0007871b          	sext.w	a4,a5
    80000cda:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cdc:	eb09                	bnez	a4,80000cee <pop_off+0x38>
    80000cde:	5d7c                	lw	a5,124(a0)
    80000ce0:	c799                	beqz	a5,80000cee <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ce2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000ce6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cea:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cee:	60a2                	ld	ra,8(sp)
    80000cf0:	6402                	ld	s0,0(sp)
    80000cf2:	0141                	addi	sp,sp,16
    80000cf4:	8082                	ret
    panic("pop_off - interruptible");
    80000cf6:	00007517          	auipc	a0,0x7
    80000cfa:	38250513          	addi	a0,a0,898 # 80008078 <digits+0x60>
    80000cfe:	00000097          	auipc	ra,0x0
    80000d02:	876080e7          	jalr	-1930(ra) # 80000574 <panic>
    panic("pop_off");
    80000d06:	00007517          	auipc	a0,0x7
    80000d0a:	38a50513          	addi	a0,a0,906 # 80008090 <digits+0x78>
    80000d0e:	00000097          	auipc	ra,0x0
    80000d12:	866080e7          	jalr	-1946(ra) # 80000574 <panic>

0000000080000d16 <release>:
{
    80000d16:	1101                	addi	sp,sp,-32
    80000d18:	ec06                	sd	ra,24(sp)
    80000d1a:	e822                	sd	s0,16(sp)
    80000d1c:	e426                	sd	s1,8(sp)
    80000d1e:	1000                	addi	s0,sp,32
    80000d20:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d22:	00000097          	auipc	ra,0x0
    80000d26:	ec6080e7          	jalr	-314(ra) # 80000be8 <holding>
    80000d2a:	c115                	beqz	a0,80000d4e <release+0x38>
  lk->cpu = 0;
    80000d2c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d30:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d34:	0f50000f          	fence	iorw,ow
    80000d38:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d3c:	00000097          	auipc	ra,0x0
    80000d40:	f7a080e7          	jalr	-134(ra) # 80000cb6 <pop_off>
}
    80000d44:	60e2                	ld	ra,24(sp)
    80000d46:	6442                	ld	s0,16(sp)
    80000d48:	64a2                	ld	s1,8(sp)
    80000d4a:	6105                	addi	sp,sp,32
    80000d4c:	8082                	ret
    panic("release");
    80000d4e:	00007517          	auipc	a0,0x7
    80000d52:	34a50513          	addi	a0,a0,842 # 80008098 <digits+0x80>
    80000d56:	00000097          	auipc	ra,0x0
    80000d5a:	81e080e7          	jalr	-2018(ra) # 80000574 <panic>

0000000080000d5e <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d5e:	1141                	addi	sp,sp,-16
    80000d60:	e422                	sd	s0,8(sp)
    80000d62:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d64:	ce09                	beqz	a2,80000d7e <memset+0x20>
    80000d66:	87aa                	mv	a5,a0
    80000d68:	fff6071b          	addiw	a4,a2,-1
    80000d6c:	1702                	slli	a4,a4,0x20
    80000d6e:	9301                	srli	a4,a4,0x20
    80000d70:	0705                	addi	a4,a4,1
    80000d72:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000d74:	00b78023          	sb	a1,0(a5) # fffffffffffff000 <end+0xffffffff7ffd7fe0>
  for(i = 0; i < n; i++){
    80000d78:	0785                	addi	a5,a5,1
    80000d7a:	fee79de3          	bne	a5,a4,80000d74 <memset+0x16>
  }
  return dst;
}
    80000d7e:	6422                	ld	s0,8(sp)
    80000d80:	0141                	addi	sp,sp,16
    80000d82:	8082                	ret

0000000080000d84 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d84:	1141                	addi	sp,sp,-16
    80000d86:	e422                	sd	s0,8(sp)
    80000d88:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d8a:	ce15                	beqz	a2,80000dc6 <memcmp+0x42>
    80000d8c:	fff6069b          	addiw	a3,a2,-1
    if(*s1 != *s2)
    80000d90:	00054783          	lbu	a5,0(a0)
    80000d94:	0005c703          	lbu	a4,0(a1)
    80000d98:	02e79063          	bne	a5,a4,80000db8 <memcmp+0x34>
    80000d9c:	1682                	slli	a3,a3,0x20
    80000d9e:	9281                	srli	a3,a3,0x20
    80000da0:	0685                	addi	a3,a3,1
    80000da2:	96aa                	add	a3,a3,a0
      return *s1 - *s2;
    s1++, s2++;
    80000da4:	0505                	addi	a0,a0,1
    80000da6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000da8:	00d50d63          	beq	a0,a3,80000dc2 <memcmp+0x3e>
    if(*s1 != *s2)
    80000dac:	00054783          	lbu	a5,0(a0)
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	fee788e3          	beq	a5,a4,80000da4 <memcmp+0x20>
      return *s1 - *s2;
    80000db8:	40e7853b          	subw	a0,a5,a4
  }

  return 0;
}
    80000dbc:	6422                	ld	s0,8(sp)
    80000dbe:	0141                	addi	sp,sp,16
    80000dc0:	8082                	ret
  return 0;
    80000dc2:	4501                	li	a0,0
    80000dc4:	bfe5                	j	80000dbc <memcmp+0x38>
    80000dc6:	4501                	li	a0,0
    80000dc8:	bfd5                	j	80000dbc <memcmp+0x38>

0000000080000dca <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dd0:	00a5f963          	bleu	a0,a1,80000de2 <memmove+0x18>
    80000dd4:	02061713          	slli	a4,a2,0x20
    80000dd8:	9301                	srli	a4,a4,0x20
    80000dda:	00e587b3          	add	a5,a1,a4
    80000dde:	02f56563          	bltu	a0,a5,80000e08 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000de2:	fff6069b          	addiw	a3,a2,-1
    80000de6:	ce11                	beqz	a2,80000e02 <memmove+0x38>
    80000de8:	1682                	slli	a3,a3,0x20
    80000dea:	9281                	srli	a3,a3,0x20
    80000dec:	0685                	addi	a3,a3,1
    80000dee:	96ae                	add	a3,a3,a1
    80000df0:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000df2:	0585                	addi	a1,a1,1
    80000df4:	0785                	addi	a5,a5,1
    80000df6:	fff5c703          	lbu	a4,-1(a1)
    80000dfa:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000dfe:	fed59ae3          	bne	a1,a3,80000df2 <memmove+0x28>

  return dst;
}
    80000e02:	6422                	ld	s0,8(sp)
    80000e04:	0141                	addi	sp,sp,16
    80000e06:	8082                	ret
    d += n;
    80000e08:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000e0a:	fff6069b          	addiw	a3,a2,-1
    80000e0e:	da75                	beqz	a2,80000e02 <memmove+0x38>
    80000e10:	02069613          	slli	a2,a3,0x20
    80000e14:	9201                	srli	a2,a2,0x20
    80000e16:	fff64613          	not	a2,a2
    80000e1a:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e1c:	17fd                	addi	a5,a5,-1
    80000e1e:	177d                	addi	a4,a4,-1
    80000e20:	0007c683          	lbu	a3,0(a5)
    80000e24:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e28:	fef61ae3          	bne	a2,a5,80000e1c <memmove+0x52>
    80000e2c:	bfd9                	j	80000e02 <memmove+0x38>

0000000080000e2e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e2e:	1141                	addi	sp,sp,-16
    80000e30:	e406                	sd	ra,8(sp)
    80000e32:	e022                	sd	s0,0(sp)
    80000e34:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e36:	00000097          	auipc	ra,0x0
    80000e3a:	f94080e7          	jalr	-108(ra) # 80000dca <memmove>
}
    80000e3e:	60a2                	ld	ra,8(sp)
    80000e40:	6402                	ld	s0,0(sp)
    80000e42:	0141                	addi	sp,sp,16
    80000e44:	8082                	ret

0000000080000e46 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e46:	1141                	addi	sp,sp,-16
    80000e48:	e422                	sd	s0,8(sp)
    80000e4a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e4c:	c229                	beqz	a2,80000e8e <strncmp+0x48>
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	c795                	beqz	a5,80000e7e <strncmp+0x38>
    80000e54:	0005c703          	lbu	a4,0(a1)
    80000e58:	02f71363          	bne	a4,a5,80000e7e <strncmp+0x38>
    80000e5c:	fff6071b          	addiw	a4,a2,-1
    80000e60:	1702                	slli	a4,a4,0x20
    80000e62:	9301                	srli	a4,a4,0x20
    80000e64:	0705                	addi	a4,a4,1
    80000e66:	972a                	add	a4,a4,a0
    n--, p++, q++;
    80000e68:	0505                	addi	a0,a0,1
    80000e6a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e6c:	02e50363          	beq	a0,a4,80000e92 <strncmp+0x4c>
    80000e70:	00054783          	lbu	a5,0(a0)
    80000e74:	c789                	beqz	a5,80000e7e <strncmp+0x38>
    80000e76:	0005c683          	lbu	a3,0(a1)
    80000e7a:	fef687e3          	beq	a3,a5,80000e68 <strncmp+0x22>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
    80000e7e:	00054503          	lbu	a0,0(a0)
    80000e82:	0005c783          	lbu	a5,0(a1)
    80000e86:	9d1d                	subw	a0,a0,a5
}
    80000e88:	6422                	ld	s0,8(sp)
    80000e8a:	0141                	addi	sp,sp,16
    80000e8c:	8082                	ret
    return 0;
    80000e8e:	4501                	li	a0,0
    80000e90:	bfe5                	j	80000e88 <strncmp+0x42>
    80000e92:	4501                	li	a0,0
    80000e94:	bfd5                	j	80000e88 <strncmp+0x42>

0000000080000e96 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e96:	1141                	addi	sp,sp,-16
    80000e98:	e422                	sd	s0,8(sp)
    80000e9a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e9c:	872a                	mv	a4,a0
    80000e9e:	a011                	j	80000ea2 <strncpy+0xc>
    80000ea0:	8636                	mv	a2,a3
    80000ea2:	fff6069b          	addiw	a3,a2,-1
    80000ea6:	00c05963          	blez	a2,80000eb8 <strncpy+0x22>
    80000eaa:	0705                	addi	a4,a4,1
    80000eac:	0005c783          	lbu	a5,0(a1)
    80000eb0:	fef70fa3          	sb	a5,-1(a4)
    80000eb4:	0585                	addi	a1,a1,1
    80000eb6:	f7ed                	bnez	a5,80000ea0 <strncpy+0xa>
    ;
  while(n-- > 0)
    80000eb8:	00d05c63          	blez	a3,80000ed0 <strncpy+0x3a>
    80000ebc:	86ba                	mv	a3,a4
    *s++ = 0;
    80000ebe:	0685                	addi	a3,a3,1
    80000ec0:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000ec4:	fff6c793          	not	a5,a3
    80000ec8:	9fb9                	addw	a5,a5,a4
    80000eca:	9fb1                	addw	a5,a5,a2
    80000ecc:	fef049e3          	bgtz	a5,80000ebe <strncpy+0x28>
  return os;
}
    80000ed0:	6422                	ld	s0,8(sp)
    80000ed2:	0141                	addi	sp,sp,16
    80000ed4:	8082                	ret

0000000080000ed6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ed6:	1141                	addi	sp,sp,-16
    80000ed8:	e422                	sd	s0,8(sp)
    80000eda:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000edc:	02c05363          	blez	a2,80000f02 <safestrcpy+0x2c>
    80000ee0:	fff6069b          	addiw	a3,a2,-1
    80000ee4:	1682                	slli	a3,a3,0x20
    80000ee6:	9281                	srli	a3,a3,0x20
    80000ee8:	96ae                	add	a3,a3,a1
    80000eea:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000eec:	00d58963          	beq	a1,a3,80000efe <safestrcpy+0x28>
    80000ef0:	0585                	addi	a1,a1,1
    80000ef2:	0785                	addi	a5,a5,1
    80000ef4:	fff5c703          	lbu	a4,-1(a1)
    80000ef8:	fee78fa3          	sb	a4,-1(a5)
    80000efc:	fb65                	bnez	a4,80000eec <safestrcpy+0x16>
    ;
  *s = 0;
    80000efe:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f02:	6422                	ld	s0,8(sp)
    80000f04:	0141                	addi	sp,sp,16
    80000f06:	8082                	ret

0000000080000f08 <strlen>:

int
strlen(const char *s)
{
    80000f08:	1141                	addi	sp,sp,-16
    80000f0a:	e422                	sd	s0,8(sp)
    80000f0c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f0e:	00054783          	lbu	a5,0(a0)
    80000f12:	cf91                	beqz	a5,80000f2e <strlen+0x26>
    80000f14:	0505                	addi	a0,a0,1
    80000f16:	87aa                	mv	a5,a0
    80000f18:	4685                	li	a3,1
    80000f1a:	9e89                	subw	a3,a3,a0
    80000f1c:	00f6853b          	addw	a0,a3,a5
    80000f20:	0785                	addi	a5,a5,1
    80000f22:	fff7c703          	lbu	a4,-1(a5)
    80000f26:	fb7d                	bnez	a4,80000f1c <strlen+0x14>
    ;
  return n;
}
    80000f28:	6422                	ld	s0,8(sp)
    80000f2a:	0141                	addi	sp,sp,16
    80000f2c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f2e:	4501                	li	a0,0
    80000f30:	bfe5                	j	80000f28 <strlen+0x20>

0000000080000f32 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f32:	1141                	addi	sp,sp,-16
    80000f34:	e406                	sd	ra,8(sp)
    80000f36:	e022                	sd	s0,0(sp)
    80000f38:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f3a:	00001097          	auipc	ra,0x1
    80000f3e:	b34080e7          	jalr	-1228(ra) # 80001a6e <cpuid>
#endif    
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f42:	00008717          	auipc	a4,0x8
    80000f46:	0ca70713          	addi	a4,a4,202 # 8000900c <started>
  if(cpuid() == 0){
    80000f4a:	c139                	beqz	a0,80000f90 <main+0x5e>
    while(started == 0)
    80000f4c:	431c                	lw	a5,0(a4)
    80000f4e:	2781                	sext.w	a5,a5
    80000f50:	dff5                	beqz	a5,80000f4c <main+0x1a>
      ;
    __sync_synchronize();
    80000f52:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f56:	00001097          	auipc	ra,0x1
    80000f5a:	b18080e7          	jalr	-1256(ra) # 80001a6e <cpuid>
    80000f5e:	85aa                	mv	a1,a0
    80000f60:	00007517          	auipc	a0,0x7
    80000f64:	15850513          	addi	a0,a0,344 # 800080b8 <digits+0xa0>
    80000f68:	fffff097          	auipc	ra,0xfffff
    80000f6c:	656080e7          	jalr	1622(ra) # 800005be <printf>
    kvminithart();    // turn on paging
    80000f70:	00000097          	auipc	ra,0x0
    80000f74:	0e0080e7          	jalr	224(ra) # 80001050 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f78:	00002097          	auipc	ra,0x2
    80000f7c:	a3c080e7          	jalr	-1476(ra) # 800029b4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f80:	00005097          	auipc	ra,0x5
    80000f84:	0d0080e7          	jalr	208(ra) # 80006050 <plicinithart>
  }

  scheduler();        
    80000f88:	00001097          	auipc	ra,0x1
    80000f8c:	2d2080e7          	jalr	722(ra) # 8000225a <scheduler>
    consoleinit();
    80000f90:	fffff097          	auipc	ra,0xfffff
    80000f94:	4f2080e7          	jalr	1266(ra) # 80000482 <consoleinit>
    statsinit();
    80000f98:	00006097          	auipc	ra,0x6
    80000f9c:	8cc080e7          	jalr	-1844(ra) # 80006864 <statsinit>
    printfinit();
    80000fa0:	00000097          	auipc	ra,0x0
    80000fa4:	804080e7          	jalr	-2044(ra) # 800007a4 <printfinit>
    printf("\n");
    80000fa8:	00007517          	auipc	a0,0x7
    80000fac:	12050513          	addi	a0,a0,288 # 800080c8 <digits+0xb0>
    80000fb0:	fffff097          	auipc	ra,0xfffff
    80000fb4:	60e080e7          	jalr	1550(ra) # 800005be <printf>
    printf("xv6 kernel is booting\n");
    80000fb8:	00007517          	auipc	a0,0x7
    80000fbc:	0e850513          	addi	a0,a0,232 # 800080a0 <digits+0x88>
    80000fc0:	fffff097          	auipc	ra,0xfffff
    80000fc4:	5fe080e7          	jalr	1534(ra) # 800005be <printf>
    printf("\n");
    80000fc8:	00007517          	auipc	a0,0x7
    80000fcc:	10050513          	addi	a0,a0,256 # 800080c8 <digits+0xb0>
    80000fd0:	fffff097          	auipc	ra,0xfffff
    80000fd4:	5ee080e7          	jalr	1518(ra) # 800005be <printf>
    kinit();         // physical page allocator
    80000fd8:	00000097          	auipc	ra,0x0
    80000fdc:	b5e080e7          	jalr	-1186(ra) # 80000b36 <kinit>
    kvminit();       // create kernel page table
    80000fe0:	00000097          	auipc	ra,0x0
    80000fe4:	2ac080e7          	jalr	684(ra) # 8000128c <kvminit>
    kvminithart();   // turn on paging
    80000fe8:	00000097          	auipc	ra,0x0
    80000fec:	068080e7          	jalr	104(ra) # 80001050 <kvminithart>
    procinit();      // process table
    80000ff0:	00001097          	auipc	ra,0x1
    80000ff4:	a16080e7          	jalr	-1514(ra) # 80001a06 <procinit>
    trapinit();      // trap vectors
    80000ff8:	00002097          	auipc	ra,0x2
    80000ffc:	994080e7          	jalr	-1644(ra) # 8000298c <trapinit>
    trapinithart();  // install kernel trap vector
    80001000:	00002097          	auipc	ra,0x2
    80001004:	9b4080e7          	jalr	-1612(ra) # 800029b4 <trapinithart>
    plicinit();      // set up interrupt controller
    80001008:	00005097          	auipc	ra,0x5
    8000100c:	032080e7          	jalr	50(ra) # 8000603a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001010:	00005097          	auipc	ra,0x5
    80001014:	040080e7          	jalr	64(ra) # 80006050 <plicinithart>
    binit();         // buffer cache
    80001018:	00002097          	auipc	ra,0x2
    8000101c:	0ec080e7          	jalr	236(ra) # 80003104 <binit>
    iinit();         // inode cache
    80001020:	00002097          	auipc	ra,0x2
    80001024:	7be080e7          	jalr	1982(ra) # 800037de <iinit>
    fileinit();      // file table
    80001028:	00003097          	auipc	ra,0x3
    8000102c:	784080e7          	jalr	1924(ra) # 800047ac <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001030:	00005097          	auipc	ra,0x5
    80001034:	12a080e7          	jalr	298(ra) # 8000615a <virtio_disk_init>
    userinit();      // first user process
    80001038:	00001097          	auipc	ra,0x1
    8000103c:	f24080e7          	jalr	-220(ra) # 80001f5c <userinit>
    __sync_synchronize();
    80001040:	0ff0000f          	fence
    started = 1;
    80001044:	4785                	li	a5,1
    80001046:	00008717          	auipc	a4,0x8
    8000104a:	fcf72323          	sw	a5,-58(a4) # 8000900c <started>
    8000104e:	bf2d                	j	80000f88 <main+0x56>

0000000080001050 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001050:	1141                	addi	sp,sp,-16
    80001052:	e422                	sd	s0,8(sp)
    80001054:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001056:	00008797          	auipc	a5,0x8
    8000105a:	fba78793          	addi	a5,a5,-70 # 80009010 <kernel_pagetable>
    8000105e:	639c                	ld	a5,0(a5)
    80001060:	83b1                	srli	a5,a5,0xc
    80001062:	577d                	li	a4,-1
    80001064:	177e                	slli	a4,a4,0x3f
    80001066:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001068:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000106c:	12000073          	sfence.vma
  sfence_vma();
}
    80001070:	6422                	ld	s0,8(sp)
    80001072:	0141                	addi	sp,sp,16
    80001074:	8082                	ret

0000000080001076 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001076:	7139                	addi	sp,sp,-64
    80001078:	fc06                	sd	ra,56(sp)
    8000107a:	f822                	sd	s0,48(sp)
    8000107c:	f426                	sd	s1,40(sp)
    8000107e:	f04a                	sd	s2,32(sp)
    80001080:	ec4e                	sd	s3,24(sp)
    80001082:	e852                	sd	s4,16(sp)
    80001084:	e456                	sd	s5,8(sp)
    80001086:	e05a                	sd	s6,0(sp)
    80001088:	0080                	addi	s0,sp,64
    8000108a:	84aa                	mv	s1,a0
    8000108c:	89ae                	mv	s3,a1
    8000108e:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80001090:	57fd                	li	a5,-1
    80001092:	83e9                	srli	a5,a5,0x1a
    80001094:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001096:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80001098:	04b7f263          	bleu	a1,a5,800010dc <walk+0x66>
    panic("walk");
    8000109c:	00007517          	auipc	a0,0x7
    800010a0:	03450513          	addi	a0,a0,52 # 800080d0 <digits+0xb8>
    800010a4:	fffff097          	auipc	ra,0xfffff
    800010a8:	4d0080e7          	jalr	1232(ra) # 80000574 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010ac:	060b0663          	beqz	s6,80001118 <walk+0xa2>
    800010b0:	00000097          	auipc	ra,0x0
    800010b4:	ac2080e7          	jalr	-1342(ra) # 80000b72 <kalloc>
    800010b8:	84aa                	mv	s1,a0
    800010ba:	c529                	beqz	a0,80001104 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800010bc:	6605                	lui	a2,0x1
    800010be:	4581                	li	a1,0
    800010c0:	00000097          	auipc	ra,0x0
    800010c4:	c9e080e7          	jalr	-866(ra) # 80000d5e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010c8:	00c4d793          	srli	a5,s1,0xc
    800010cc:	07aa                	slli	a5,a5,0xa
    800010ce:	0017e793          	ori	a5,a5,1
    800010d2:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010d6:	3a5d                	addiw	s4,s4,-9
    800010d8:	035a0063          	beq	s4,s5,800010f8 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010dc:	0149d933          	srl	s2,s3,s4
    800010e0:	1ff97913          	andi	s2,s2,511
    800010e4:	090e                	slli	s2,s2,0x3
    800010e6:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010e8:	00093483          	ld	s1,0(s2)
    800010ec:	0014f793          	andi	a5,s1,1
    800010f0:	dfd5                	beqz	a5,800010ac <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010f2:	80a9                	srli	s1,s1,0xa
    800010f4:	04b2                	slli	s1,s1,0xc
    800010f6:	b7c5                	j	800010d6 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010f8:	00c9d513          	srli	a0,s3,0xc
    800010fc:	1ff57513          	andi	a0,a0,511
    80001100:	050e                	slli	a0,a0,0x3
    80001102:	9526                	add	a0,a0,s1
}
    80001104:	70e2                	ld	ra,56(sp)
    80001106:	7442                	ld	s0,48(sp)
    80001108:	74a2                	ld	s1,40(sp)
    8000110a:	7902                	ld	s2,32(sp)
    8000110c:	69e2                	ld	s3,24(sp)
    8000110e:	6a42                	ld	s4,16(sp)
    80001110:	6aa2                	ld	s5,8(sp)
    80001112:	6b02                	ld	s6,0(sp)
    80001114:	6121                	addi	sp,sp,64
    80001116:	8082                	ret
        return 0;
    80001118:	4501                	li	a0,0
    8000111a:	b7ed                	j	80001104 <walk+0x8e>

000000008000111c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000111c:	57fd                	li	a5,-1
    8000111e:	83e9                	srli	a5,a5,0x1a
    80001120:	00b7f463          	bleu	a1,a5,80001128 <walkaddr+0xc>
    return 0;
    80001124:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001126:	8082                	ret
{
    80001128:	1141                	addi	sp,sp,-16
    8000112a:	e406                	sd	ra,8(sp)
    8000112c:	e022                	sd	s0,0(sp)
    8000112e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001130:	4601                	li	a2,0
    80001132:	00000097          	auipc	ra,0x0
    80001136:	f44080e7          	jalr	-188(ra) # 80001076 <walk>
  if(pte == 0)
    8000113a:	c105                	beqz	a0,8000115a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000113c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000113e:	0117f693          	andi	a3,a5,17
    80001142:	4745                	li	a4,17
    return 0;
    80001144:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001146:	00e68663          	beq	a3,a4,80001152 <walkaddr+0x36>
}
    8000114a:	60a2                	ld	ra,8(sp)
    8000114c:	6402                	ld	s0,0(sp)
    8000114e:	0141                	addi	sp,sp,16
    80001150:	8082                	ret
  pa = PTE2PA(*pte);
    80001152:	00a7d513          	srli	a0,a5,0xa
    80001156:	0532                	slli	a0,a0,0xc
  return pa;
    80001158:	bfcd                	j	8000114a <walkaddr+0x2e>
    return 0;
    8000115a:	4501                	li	a0,0
    8000115c:	b7fd                	j	8000114a <walkaddr+0x2e>

000000008000115e <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    8000115e:	1101                	addi	sp,sp,-32
    80001160:	ec06                	sd	ra,24(sp)
    80001162:	e822                	sd	s0,16(sp)
    80001164:	e426                	sd	s1,8(sp)
    80001166:	e04a                	sd	s2,0(sp)
    80001168:	1000                	addi	s0,sp,32
    8000116a:	892a                	mv	s2,a0
  uint64 off = va % PGSIZE;
    8000116c:	6505                	lui	a0,0x1
    8000116e:	157d                	addi	a0,a0,-1
    80001170:	00a974b3          	and	s1,s2,a0
  pte_t *pte;
  uint64 pa;
  
  pte = walk(myproc()->kpagetable, va, 0);
    80001174:	00001097          	auipc	ra,0x1
    80001178:	926080e7          	jalr	-1754(ra) # 80001a9a <myproc>
    8000117c:	4601                	li	a2,0
    8000117e:	85ca                	mv	a1,s2
    80001180:	6d28                	ld	a0,88(a0)
    80001182:	00000097          	auipc	ra,0x0
    80001186:	ef4080e7          	jalr	-268(ra) # 80001076 <walk>
  if(pte == 0)
    8000118a:	cd11                	beqz	a0,800011a6 <kvmpa+0x48>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    8000118c:	6108                	ld	a0,0(a0)
    8000118e:	00157793          	andi	a5,a0,1
    80001192:	c395                	beqz	a5,800011b6 <kvmpa+0x58>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001194:	8129                	srli	a0,a0,0xa
    80001196:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    80001198:	9526                	add	a0,a0,s1
    8000119a:	60e2                	ld	ra,24(sp)
    8000119c:	6442                	ld	s0,16(sp)
    8000119e:	64a2                	ld	s1,8(sp)
    800011a0:	6902                	ld	s2,0(sp)
    800011a2:	6105                	addi	sp,sp,32
    800011a4:	8082                	ret
    panic("kvmpa");
    800011a6:	00007517          	auipc	a0,0x7
    800011aa:	f3250513          	addi	a0,a0,-206 # 800080d8 <digits+0xc0>
    800011ae:	fffff097          	auipc	ra,0xfffff
    800011b2:	3c6080e7          	jalr	966(ra) # 80000574 <panic>
    panic("kvmpa");
    800011b6:	00007517          	auipc	a0,0x7
    800011ba:	f2250513          	addi	a0,a0,-222 # 800080d8 <digits+0xc0>
    800011be:	fffff097          	auipc	ra,0xfffff
    800011c2:	3b6080e7          	jalr	950(ra) # 80000574 <panic>

00000000800011c6 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800011c6:	715d                	addi	sp,sp,-80
    800011c8:	e486                	sd	ra,72(sp)
    800011ca:	e0a2                	sd	s0,64(sp)
    800011cc:	fc26                	sd	s1,56(sp)
    800011ce:	f84a                	sd	s2,48(sp)
    800011d0:	f44e                	sd	s3,40(sp)
    800011d2:	f052                	sd	s4,32(sp)
    800011d4:	ec56                	sd	s5,24(sp)
    800011d6:	e85a                	sd	s6,16(sp)
    800011d8:	e45e                	sd	s7,8(sp)
    800011da:	0880                	addi	s0,sp,80
    800011dc:	8aaa                	mv	s5,a0
    800011de:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800011e0:	79fd                	lui	s3,0xfffff
    800011e2:	0135fa33          	and	s4,a1,s3
  last = PGROUNDDOWN(va + size - 1);
    800011e6:	167d                	addi	a2,a2,-1
    800011e8:	962e                	add	a2,a2,a1
    800011ea:	013679b3          	and	s3,a2,s3
  a = PGROUNDDOWN(va);
    800011ee:	8952                	mv	s2,s4
    800011f0:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011f4:	6b85                	lui	s7,0x1
    800011f6:	a811                	j	8000120a <mappages+0x44>
      panic("remap");
    800011f8:	00007517          	auipc	a0,0x7
    800011fc:	ee850513          	addi	a0,a0,-280 # 800080e0 <digits+0xc8>
    80001200:	fffff097          	auipc	ra,0xfffff
    80001204:	374080e7          	jalr	884(ra) # 80000574 <panic>
    a += PGSIZE;
    80001208:	995e                	add	s2,s2,s7
  for(;;){
    8000120a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000120e:	4605                	li	a2,1
    80001210:	85ca                	mv	a1,s2
    80001212:	8556                	mv	a0,s5
    80001214:	00000097          	auipc	ra,0x0
    80001218:	e62080e7          	jalr	-414(ra) # 80001076 <walk>
    8000121c:	cd19                	beqz	a0,8000123a <mappages+0x74>
    if(*pte & PTE_V)
    8000121e:	611c                	ld	a5,0(a0)
    80001220:	8b85                	andi	a5,a5,1
    80001222:	fbf9                	bnez	a5,800011f8 <mappages+0x32>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001224:	80b1                	srli	s1,s1,0xc
    80001226:	04aa                	slli	s1,s1,0xa
    80001228:	0164e4b3          	or	s1,s1,s6
    8000122c:	0014e493          	ori	s1,s1,1
    80001230:	e104                	sd	s1,0(a0)
    if(a == last)
    80001232:	fd391be3          	bne	s2,s3,80001208 <mappages+0x42>
    pa += PGSIZE;
  }
  return 0;
    80001236:	4501                	li	a0,0
    80001238:	a011                	j	8000123c <mappages+0x76>
      return -1;
    8000123a:	557d                	li	a0,-1
}
    8000123c:	60a6                	ld	ra,72(sp)
    8000123e:	6406                	ld	s0,64(sp)
    80001240:	74e2                	ld	s1,56(sp)
    80001242:	7942                	ld	s2,48(sp)
    80001244:	79a2                	ld	s3,40(sp)
    80001246:	7a02                	ld	s4,32(sp)
    80001248:	6ae2                	ld	s5,24(sp)
    8000124a:	6b42                	ld	s6,16(sp)
    8000124c:	6ba2                	ld	s7,8(sp)
    8000124e:	6161                	addi	sp,sp,80
    80001250:	8082                	ret

0000000080001252 <kvmmap>:
{
    80001252:	1141                	addi	sp,sp,-16
    80001254:	e406                	sd	ra,8(sp)
    80001256:	e022                	sd	s0,0(sp)
    80001258:	0800                	addi	s0,sp,16
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    8000125a:	8736                	mv	a4,a3
    8000125c:	86ae                	mv	a3,a1
    8000125e:	85aa                	mv	a1,a0
    80001260:	00008797          	auipc	a5,0x8
    80001264:	db078793          	addi	a5,a5,-592 # 80009010 <kernel_pagetable>
    80001268:	6388                	ld	a0,0(a5)
    8000126a:	00000097          	auipc	ra,0x0
    8000126e:	f5c080e7          	jalr	-164(ra) # 800011c6 <mappages>
    80001272:	e509                	bnez	a0,8000127c <kvmmap+0x2a>
}
    80001274:	60a2                	ld	ra,8(sp)
    80001276:	6402                	ld	s0,0(sp)
    80001278:	0141                	addi	sp,sp,16
    8000127a:	8082                	ret
    panic("kvmmap");
    8000127c:	00007517          	auipc	a0,0x7
    80001280:	e6c50513          	addi	a0,a0,-404 # 800080e8 <digits+0xd0>
    80001284:	fffff097          	auipc	ra,0xfffff
    80001288:	2f0080e7          	jalr	752(ra) # 80000574 <panic>

000000008000128c <kvminit>:
{
    8000128c:	1101                	addi	sp,sp,-32
    8000128e:	ec06                	sd	ra,24(sp)
    80001290:	e822                	sd	s0,16(sp)
    80001292:	e426                	sd	s1,8(sp)
    80001294:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001296:	00000097          	auipc	ra,0x0
    8000129a:	8dc080e7          	jalr	-1828(ra) # 80000b72 <kalloc>
    8000129e:	00008797          	auipc	a5,0x8
    800012a2:	d6a7b923          	sd	a0,-654(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800012a6:	6605                	lui	a2,0x1
    800012a8:	4581                	li	a1,0
    800012aa:	00000097          	auipc	ra,0x0
    800012ae:	ab4080e7          	jalr	-1356(ra) # 80000d5e <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012b2:	4699                	li	a3,6
    800012b4:	6605                	lui	a2,0x1
    800012b6:	100005b7          	lui	a1,0x10000
    800012ba:	10000537          	lui	a0,0x10000
    800012be:	00000097          	auipc	ra,0x0
    800012c2:	f94080e7          	jalr	-108(ra) # 80001252 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012c6:	4699                	li	a3,6
    800012c8:	6605                	lui	a2,0x1
    800012ca:	100015b7          	lui	a1,0x10001
    800012ce:	10001537          	lui	a0,0x10001
    800012d2:	00000097          	auipc	ra,0x0
    800012d6:	f80080e7          	jalr	-128(ra) # 80001252 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    800012da:	4699                	li	a3,6
    800012dc:	6641                	lui	a2,0x10
    800012de:	020005b7          	lui	a1,0x2000
    800012e2:	02000537          	lui	a0,0x2000
    800012e6:	00000097          	auipc	ra,0x0
    800012ea:	f6c080e7          	jalr	-148(ra) # 80001252 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012ee:	4699                	li	a3,6
    800012f0:	00400637          	lui	a2,0x400
    800012f4:	0c0005b7          	lui	a1,0xc000
    800012f8:	0c000537          	lui	a0,0xc000
    800012fc:	00000097          	auipc	ra,0x0
    80001300:	f56080e7          	jalr	-170(ra) # 80001252 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001304:	00007497          	auipc	s1,0x7
    80001308:	cfc48493          	addi	s1,s1,-772 # 80008000 <etext>
    8000130c:	46a9                	li	a3,10
    8000130e:	80007617          	auipc	a2,0x80007
    80001312:	cf260613          	addi	a2,a2,-782 # 8000 <_entry-0x7fff8000>
    80001316:	4585                	li	a1,1
    80001318:	05fe                	slli	a1,a1,0x1f
    8000131a:	852e                	mv	a0,a1
    8000131c:	00000097          	auipc	ra,0x0
    80001320:	f36080e7          	jalr	-202(ra) # 80001252 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001324:	4699                	li	a3,6
    80001326:	4645                	li	a2,17
    80001328:	066e                	slli	a2,a2,0x1b
    8000132a:	8e05                	sub	a2,a2,s1
    8000132c:	85a6                	mv	a1,s1
    8000132e:	8526                	mv	a0,s1
    80001330:	00000097          	auipc	ra,0x0
    80001334:	f22080e7          	jalr	-222(ra) # 80001252 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001338:	46a9                	li	a3,10
    8000133a:	6605                	lui	a2,0x1
    8000133c:	00006597          	auipc	a1,0x6
    80001340:	cc458593          	addi	a1,a1,-828 # 80007000 <_trampoline>
    80001344:	04000537          	lui	a0,0x4000
    80001348:	157d                	addi	a0,a0,-1
    8000134a:	0532                	slli	a0,a0,0xc
    8000134c:	00000097          	auipc	ra,0x0
    80001350:	f06080e7          	jalr	-250(ra) # 80001252 <kvmmap>
}
    80001354:	60e2                	ld	ra,24(sp)
    80001356:	6442                	ld	s0,16(sp)
    80001358:	64a2                	ld	s1,8(sp)
    8000135a:	6105                	addi	sp,sp,32
    8000135c:	8082                	ret

000000008000135e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000135e:	715d                	addi	sp,sp,-80
    80001360:	e486                	sd	ra,72(sp)
    80001362:	e0a2                	sd	s0,64(sp)
    80001364:	fc26                	sd	s1,56(sp)
    80001366:	f84a                	sd	s2,48(sp)
    80001368:	f44e                	sd	s3,40(sp)
    8000136a:	f052                	sd	s4,32(sp)
    8000136c:	ec56                	sd	s5,24(sp)
    8000136e:	e85a                	sd	s6,16(sp)
    80001370:	e45e                	sd	s7,8(sp)
    80001372:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001374:	6785                	lui	a5,0x1
    80001376:	17fd                	addi	a5,a5,-1
    80001378:	8fed                	and	a5,a5,a1
    8000137a:	e795                	bnez	a5,800013a6 <uvmunmap+0x48>
    8000137c:	8a2a                	mv	s4,a0
    8000137e:	84ae                	mv	s1,a1
    80001380:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001382:	0632                	slli	a2,a2,0xc
    80001384:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001388:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000138a:	6b05                	lui	s6,0x1
    8000138c:	0735e863          	bltu	a1,s3,800013fc <uvmunmap+0x9e>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001390:	60a6                	ld	ra,72(sp)
    80001392:	6406                	ld	s0,64(sp)
    80001394:	74e2                	ld	s1,56(sp)
    80001396:	7942                	ld	s2,48(sp)
    80001398:	79a2                	ld	s3,40(sp)
    8000139a:	7a02                	ld	s4,32(sp)
    8000139c:	6ae2                	ld	s5,24(sp)
    8000139e:	6b42                	ld	s6,16(sp)
    800013a0:	6ba2                	ld	s7,8(sp)
    800013a2:	6161                	addi	sp,sp,80
    800013a4:	8082                	ret
    panic("uvmunmap: not aligned");
    800013a6:	00007517          	auipc	a0,0x7
    800013aa:	d4a50513          	addi	a0,a0,-694 # 800080f0 <digits+0xd8>
    800013ae:	fffff097          	auipc	ra,0xfffff
    800013b2:	1c6080e7          	jalr	454(ra) # 80000574 <panic>
      panic("uvmunmap: walk");
    800013b6:	00007517          	auipc	a0,0x7
    800013ba:	d5250513          	addi	a0,a0,-686 # 80008108 <digits+0xf0>
    800013be:	fffff097          	auipc	ra,0xfffff
    800013c2:	1b6080e7          	jalr	438(ra) # 80000574 <panic>
      panic("uvmunmap: not mapped");
    800013c6:	00007517          	auipc	a0,0x7
    800013ca:	d5250513          	addi	a0,a0,-686 # 80008118 <digits+0x100>
    800013ce:	fffff097          	auipc	ra,0xfffff
    800013d2:	1a6080e7          	jalr	422(ra) # 80000574 <panic>
      panic("uvmunmap: not a leaf");
    800013d6:	00007517          	auipc	a0,0x7
    800013da:	d5a50513          	addi	a0,a0,-678 # 80008130 <digits+0x118>
    800013de:	fffff097          	auipc	ra,0xfffff
    800013e2:	196080e7          	jalr	406(ra) # 80000574 <panic>
      uint64 pa = PTE2PA(*pte);
    800013e6:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013e8:	0532                	slli	a0,a0,0xc
    800013ea:	fffff097          	auipc	ra,0xfffff
    800013ee:	688080e7          	jalr	1672(ra) # 80000a72 <kfree>
    *pte = 0;
    800013f2:	00093023          	sd	zero,0(s2)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013f6:	94da                	add	s1,s1,s6
    800013f8:	f934fce3          	bleu	s3,s1,80001390 <uvmunmap+0x32>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013fc:	4601                	li	a2,0
    800013fe:	85a6                	mv	a1,s1
    80001400:	8552                	mv	a0,s4
    80001402:	00000097          	auipc	ra,0x0
    80001406:	c74080e7          	jalr	-908(ra) # 80001076 <walk>
    8000140a:	892a                	mv	s2,a0
    8000140c:	d54d                	beqz	a0,800013b6 <uvmunmap+0x58>
    if((*pte & PTE_V) == 0)
    8000140e:	6108                	ld	a0,0(a0)
    80001410:	00157793          	andi	a5,a0,1
    80001414:	dbcd                	beqz	a5,800013c6 <uvmunmap+0x68>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001416:	3ff57793          	andi	a5,a0,1023
    8000141a:	fb778ee3          	beq	a5,s7,800013d6 <uvmunmap+0x78>
    if(do_free){
    8000141e:	fc0a8ae3          	beqz	s5,800013f2 <uvmunmap+0x94>
    80001422:	b7d1                	j	800013e6 <uvmunmap+0x88>

0000000080001424 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001424:	1101                	addi	sp,sp,-32
    80001426:	ec06                	sd	ra,24(sp)
    80001428:	e822                	sd	s0,16(sp)
    8000142a:	e426                	sd	s1,8(sp)
    8000142c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000142e:	fffff097          	auipc	ra,0xfffff
    80001432:	744080e7          	jalr	1860(ra) # 80000b72 <kalloc>
    80001436:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001438:	c519                	beqz	a0,80001446 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000143a:	6605                	lui	a2,0x1
    8000143c:	4581                	li	a1,0
    8000143e:	00000097          	auipc	ra,0x0
    80001442:	920080e7          	jalr	-1760(ra) # 80000d5e <memset>
  return pagetable;
}
    80001446:	8526                	mv	a0,s1
    80001448:	60e2                	ld	ra,24(sp)
    8000144a:	6442                	ld	s0,16(sp)
    8000144c:	64a2                	ld	s1,8(sp)
    8000144e:	6105                	addi	sp,sp,32
    80001450:	8082                	ret

0000000080001452 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001452:	7179                	addi	sp,sp,-48
    80001454:	f406                	sd	ra,40(sp)
    80001456:	f022                	sd	s0,32(sp)
    80001458:	ec26                	sd	s1,24(sp)
    8000145a:	e84a                	sd	s2,16(sp)
    8000145c:	e44e                	sd	s3,8(sp)
    8000145e:	e052                	sd	s4,0(sp)
    80001460:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001462:	6785                	lui	a5,0x1
    80001464:	04f67863          	bleu	a5,a2,800014b4 <uvminit+0x62>
    80001468:	8a2a                	mv	s4,a0
    8000146a:	89ae                	mv	s3,a1
    8000146c:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000146e:	fffff097          	auipc	ra,0xfffff
    80001472:	704080e7          	jalr	1796(ra) # 80000b72 <kalloc>
    80001476:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001478:	6605                	lui	a2,0x1
    8000147a:	4581                	li	a1,0
    8000147c:	00000097          	auipc	ra,0x0
    80001480:	8e2080e7          	jalr	-1822(ra) # 80000d5e <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001484:	4779                	li	a4,30
    80001486:	86ca                	mv	a3,s2
    80001488:	6605                	lui	a2,0x1
    8000148a:	4581                	li	a1,0
    8000148c:	8552                	mv	a0,s4
    8000148e:	00000097          	auipc	ra,0x0
    80001492:	d38080e7          	jalr	-712(ra) # 800011c6 <mappages>
  memmove(mem, src, sz);
    80001496:	8626                	mv	a2,s1
    80001498:	85ce                	mv	a1,s3
    8000149a:	854a                	mv	a0,s2
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	92e080e7          	jalr	-1746(ra) # 80000dca <memmove>
}
    800014a4:	70a2                	ld	ra,40(sp)
    800014a6:	7402                	ld	s0,32(sp)
    800014a8:	64e2                	ld	s1,24(sp)
    800014aa:	6942                	ld	s2,16(sp)
    800014ac:	69a2                	ld	s3,8(sp)
    800014ae:	6a02                	ld	s4,0(sp)
    800014b0:	6145                	addi	sp,sp,48
    800014b2:	8082                	ret
    panic("inituvm: more than a page");
    800014b4:	00007517          	auipc	a0,0x7
    800014b8:	c9450513          	addi	a0,a0,-876 # 80008148 <digits+0x130>
    800014bc:	fffff097          	auipc	ra,0xfffff
    800014c0:	0b8080e7          	jalr	184(ra) # 80000574 <panic>

00000000800014c4 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800014c4:	1101                	addi	sp,sp,-32
    800014c6:	ec06                	sd	ra,24(sp)
    800014c8:	e822                	sd	s0,16(sp)
    800014ca:	e426                	sd	s1,8(sp)
    800014cc:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800014ce:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800014d0:	00b67d63          	bleu	a1,a2,800014ea <uvmdealloc+0x26>
    800014d4:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800014d6:	6605                	lui	a2,0x1
    800014d8:	167d                	addi	a2,a2,-1
    800014da:	00c487b3          	add	a5,s1,a2
    800014de:	777d                	lui	a4,0xfffff
    800014e0:	8ff9                	and	a5,a5,a4
    800014e2:	962e                	add	a2,a2,a1
    800014e4:	8e79                	and	a2,a2,a4
    800014e6:	00c7e863          	bltu	a5,a2,800014f6 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014ea:	8526                	mv	a0,s1
    800014ec:	60e2                	ld	ra,24(sp)
    800014ee:	6442                	ld	s0,16(sp)
    800014f0:	64a2                	ld	s1,8(sp)
    800014f2:	6105                	addi	sp,sp,32
    800014f4:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014f6:	8e1d                	sub	a2,a2,a5
    800014f8:	8231                	srli	a2,a2,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014fa:	4685                	li	a3,1
    800014fc:	2601                	sext.w	a2,a2
    800014fe:	85be                	mv	a1,a5
    80001500:	00000097          	auipc	ra,0x0
    80001504:	e5e080e7          	jalr	-418(ra) # 8000135e <uvmunmap>
    80001508:	b7cd                	j	800014ea <uvmdealloc+0x26>

000000008000150a <uvmalloc>:
  if(newsz < oldsz)
    8000150a:	0ab66163          	bltu	a2,a1,800015ac <uvmalloc+0xa2>
{
    8000150e:	7139                	addi	sp,sp,-64
    80001510:	fc06                	sd	ra,56(sp)
    80001512:	f822                	sd	s0,48(sp)
    80001514:	f426                	sd	s1,40(sp)
    80001516:	f04a                	sd	s2,32(sp)
    80001518:	ec4e                	sd	s3,24(sp)
    8000151a:	e852                	sd	s4,16(sp)
    8000151c:	e456                	sd	s5,8(sp)
    8000151e:	0080                	addi	s0,sp,64
  oldsz = PGROUNDUP(oldsz);
    80001520:	6a05                	lui	s4,0x1
    80001522:	1a7d                	addi	s4,s4,-1
    80001524:	95d2                	add	a1,a1,s4
    80001526:	7a7d                	lui	s4,0xfffff
    80001528:	0145fa33          	and	s4,a1,s4
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000152c:	08ca7263          	bleu	a2,s4,800015b0 <uvmalloc+0xa6>
    80001530:	89b2                	mv	s3,a2
    80001532:	8aaa                	mv	s5,a0
    80001534:	8952                	mv	s2,s4
    mem = kalloc();
    80001536:	fffff097          	auipc	ra,0xfffff
    8000153a:	63c080e7          	jalr	1596(ra) # 80000b72 <kalloc>
    8000153e:	84aa                	mv	s1,a0
    if(mem == 0){
    80001540:	c51d                	beqz	a0,8000156e <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001542:	6605                	lui	a2,0x1
    80001544:	4581                	li	a1,0
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	818080e7          	jalr	-2024(ra) # 80000d5e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000154e:	4779                	li	a4,30
    80001550:	86a6                	mv	a3,s1
    80001552:	6605                	lui	a2,0x1
    80001554:	85ca                	mv	a1,s2
    80001556:	8556                	mv	a0,s5
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	c6e080e7          	jalr	-914(ra) # 800011c6 <mappages>
    80001560:	e905                	bnez	a0,80001590 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001562:	6785                	lui	a5,0x1
    80001564:	993e                	add	s2,s2,a5
    80001566:	fd3968e3          	bltu	s2,s3,80001536 <uvmalloc+0x2c>
  return newsz;
    8000156a:	854e                	mv	a0,s3
    8000156c:	a809                	j	8000157e <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000156e:	8652                	mv	a2,s4
    80001570:	85ca                	mv	a1,s2
    80001572:	8556                	mv	a0,s5
    80001574:	00000097          	auipc	ra,0x0
    80001578:	f50080e7          	jalr	-176(ra) # 800014c4 <uvmdealloc>
      return 0;
    8000157c:	4501                	li	a0,0
}
    8000157e:	70e2                	ld	ra,56(sp)
    80001580:	7442                	ld	s0,48(sp)
    80001582:	74a2                	ld	s1,40(sp)
    80001584:	7902                	ld	s2,32(sp)
    80001586:	69e2                	ld	s3,24(sp)
    80001588:	6a42                	ld	s4,16(sp)
    8000158a:	6aa2                	ld	s5,8(sp)
    8000158c:	6121                	addi	sp,sp,64
    8000158e:	8082                	ret
      kfree(mem);
    80001590:	8526                	mv	a0,s1
    80001592:	fffff097          	auipc	ra,0xfffff
    80001596:	4e0080e7          	jalr	1248(ra) # 80000a72 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000159a:	8652                	mv	a2,s4
    8000159c:	85ca                	mv	a1,s2
    8000159e:	8556                	mv	a0,s5
    800015a0:	00000097          	auipc	ra,0x0
    800015a4:	f24080e7          	jalr	-220(ra) # 800014c4 <uvmdealloc>
      return 0;
    800015a8:	4501                	li	a0,0
    800015aa:	bfd1                	j	8000157e <uvmalloc+0x74>
    return oldsz;
    800015ac:	852e                	mv	a0,a1
}
    800015ae:	8082                	ret
  return newsz;
    800015b0:	8532                	mv	a0,a2
    800015b2:	b7f1                	j	8000157e <uvmalloc+0x74>

00000000800015b4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800015b4:	7179                	addi	sp,sp,-48
    800015b6:	f406                	sd	ra,40(sp)
    800015b8:	f022                	sd	s0,32(sp)
    800015ba:	ec26                	sd	s1,24(sp)
    800015bc:	e84a                	sd	s2,16(sp)
    800015be:	e44e                	sd	s3,8(sp)
    800015c0:	e052                	sd	s4,0(sp)
    800015c2:	1800                	addi	s0,sp,48
    800015c4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800015c6:	84aa                	mv	s1,a0
    800015c8:	6905                	lui	s2,0x1
    800015ca:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015cc:	4985                	li	s3,1
    800015ce:	a821                	j	800015e6 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015d0:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800015d2:	0532                	slli	a0,a0,0xc
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	fe0080e7          	jalr	-32(ra) # 800015b4 <freewalk>
      pagetable[i] = 0;
    800015dc:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015e0:	04a1                	addi	s1,s1,8
    800015e2:	03248163          	beq	s1,s2,80001604 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800015e6:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015e8:	00f57793          	andi	a5,a0,15
    800015ec:	ff3782e3          	beq	a5,s3,800015d0 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015f0:	8905                	andi	a0,a0,1
    800015f2:	d57d                	beqz	a0,800015e0 <freewalk+0x2c>
      panic("freewalk: leaf");
    800015f4:	00007517          	auipc	a0,0x7
    800015f8:	b7450513          	addi	a0,a0,-1164 # 80008168 <digits+0x150>
    800015fc:	fffff097          	auipc	ra,0xfffff
    80001600:	f78080e7          	jalr	-136(ra) # 80000574 <panic>
    }
  }
  kfree((void*)pagetable);
    80001604:	8552                	mv	a0,s4
    80001606:	fffff097          	auipc	ra,0xfffff
    8000160a:	46c080e7          	jalr	1132(ra) # 80000a72 <kfree>
}
    8000160e:	70a2                	ld	ra,40(sp)
    80001610:	7402                	ld	s0,32(sp)
    80001612:	64e2                	ld	s1,24(sp)
    80001614:	6942                	ld	s2,16(sp)
    80001616:	69a2                	ld	s3,8(sp)
    80001618:	6a02                	ld	s4,0(sp)
    8000161a:	6145                	addi	sp,sp,48
    8000161c:	8082                	ret

000000008000161e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000161e:	1101                	addi	sp,sp,-32
    80001620:	ec06                	sd	ra,24(sp)
    80001622:	e822                	sd	s0,16(sp)
    80001624:	e426                	sd	s1,8(sp)
    80001626:	1000                	addi	s0,sp,32
    80001628:	84aa                	mv	s1,a0
  if(sz > 0)
    8000162a:	e999                	bnez	a1,80001640 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000162c:	8526                	mv	a0,s1
    8000162e:	00000097          	auipc	ra,0x0
    80001632:	f86080e7          	jalr	-122(ra) # 800015b4 <freewalk>
}
    80001636:	60e2                	ld	ra,24(sp)
    80001638:	6442                	ld	s0,16(sp)
    8000163a:	64a2                	ld	s1,8(sp)
    8000163c:	6105                	addi	sp,sp,32
    8000163e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001640:	6605                	lui	a2,0x1
    80001642:	167d                	addi	a2,a2,-1
    80001644:	962e                	add	a2,a2,a1
    80001646:	4685                	li	a3,1
    80001648:	8231                	srli	a2,a2,0xc
    8000164a:	4581                	li	a1,0
    8000164c:	00000097          	auipc	ra,0x0
    80001650:	d12080e7          	jalr	-750(ra) # 8000135e <uvmunmap>
    80001654:	bfe1                	j	8000162c <uvmfree+0xe>

0000000080001656 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001656:	c679                	beqz	a2,80001724 <uvmcopy+0xce>
{
    80001658:	715d                	addi	sp,sp,-80
    8000165a:	e486                	sd	ra,72(sp)
    8000165c:	e0a2                	sd	s0,64(sp)
    8000165e:	fc26                	sd	s1,56(sp)
    80001660:	f84a                	sd	s2,48(sp)
    80001662:	f44e                	sd	s3,40(sp)
    80001664:	f052                	sd	s4,32(sp)
    80001666:	ec56                	sd	s5,24(sp)
    80001668:	e85a                	sd	s6,16(sp)
    8000166a:	e45e                	sd	s7,8(sp)
    8000166c:	0880                	addi	s0,sp,80
    8000166e:	8ab2                	mv	s5,a2
    80001670:	8b2e                	mv	s6,a1
    80001672:	8baa                	mv	s7,a0
  for(i = 0; i < sz; i += PGSIZE){
    80001674:	4901                	li	s2,0
    if((pte = walk(old, i, 0)) == 0)
    80001676:	4601                	li	a2,0
    80001678:	85ca                	mv	a1,s2
    8000167a:	855e                	mv	a0,s7
    8000167c:	00000097          	auipc	ra,0x0
    80001680:	9fa080e7          	jalr	-1542(ra) # 80001076 <walk>
    80001684:	c531                	beqz	a0,800016d0 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001686:	6118                	ld	a4,0(a0)
    80001688:	00177793          	andi	a5,a4,1
    8000168c:	cbb1                	beqz	a5,800016e0 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000168e:	00a75593          	srli	a1,a4,0xa
    80001692:	00c59993          	slli	s3,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001696:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000169a:	fffff097          	auipc	ra,0xfffff
    8000169e:	4d8080e7          	jalr	1240(ra) # 80000b72 <kalloc>
    800016a2:	8a2a                	mv	s4,a0
    800016a4:	c939                	beqz	a0,800016fa <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016a6:	6605                	lui	a2,0x1
    800016a8:	85ce                	mv	a1,s3
    800016aa:	fffff097          	auipc	ra,0xfffff
    800016ae:	720080e7          	jalr	1824(ra) # 80000dca <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800016b2:	8726                	mv	a4,s1
    800016b4:	86d2                	mv	a3,s4
    800016b6:	6605                	lui	a2,0x1
    800016b8:	85ca                	mv	a1,s2
    800016ba:	855a                	mv	a0,s6
    800016bc:	00000097          	auipc	ra,0x0
    800016c0:	b0a080e7          	jalr	-1270(ra) # 800011c6 <mappages>
    800016c4:	e515                	bnez	a0,800016f0 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800016c6:	6785                	lui	a5,0x1
    800016c8:	993e                	add	s2,s2,a5
    800016ca:	fb5966e3          	bltu	s2,s5,80001676 <uvmcopy+0x20>
    800016ce:	a081                	j	8000170e <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800016d0:	00007517          	auipc	a0,0x7
    800016d4:	aa850513          	addi	a0,a0,-1368 # 80008178 <digits+0x160>
    800016d8:	fffff097          	auipc	ra,0xfffff
    800016dc:	e9c080e7          	jalr	-356(ra) # 80000574 <panic>
      panic("uvmcopy: page not present");
    800016e0:	00007517          	auipc	a0,0x7
    800016e4:	ab850513          	addi	a0,a0,-1352 # 80008198 <digits+0x180>
    800016e8:	fffff097          	auipc	ra,0xfffff
    800016ec:	e8c080e7          	jalr	-372(ra) # 80000574 <panic>
      kfree(mem);
    800016f0:	8552                	mv	a0,s4
    800016f2:	fffff097          	auipc	ra,0xfffff
    800016f6:	380080e7          	jalr	896(ra) # 80000a72 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016fa:	4685                	li	a3,1
    800016fc:	00c95613          	srli	a2,s2,0xc
    80001700:	4581                	li	a1,0
    80001702:	855a                	mv	a0,s6
    80001704:	00000097          	auipc	ra,0x0
    80001708:	c5a080e7          	jalr	-934(ra) # 8000135e <uvmunmap>
  return -1;
    8000170c:	557d                	li	a0,-1
}
    8000170e:	60a6                	ld	ra,72(sp)
    80001710:	6406                	ld	s0,64(sp)
    80001712:	74e2                	ld	s1,56(sp)
    80001714:	7942                	ld	s2,48(sp)
    80001716:	79a2                	ld	s3,40(sp)
    80001718:	7a02                	ld	s4,32(sp)
    8000171a:	6ae2                	ld	s5,24(sp)
    8000171c:	6b42                	ld	s6,16(sp)
    8000171e:	6ba2                	ld	s7,8(sp)
    80001720:	6161                	addi	sp,sp,80
    80001722:	8082                	ret
  return 0;
    80001724:	4501                	li	a0,0
}
    80001726:	8082                	ret

0000000080001728 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001728:	1141                	addi	sp,sp,-16
    8000172a:	e406                	sd	ra,8(sp)
    8000172c:	e022                	sd	s0,0(sp)
    8000172e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001730:	4601                	li	a2,0
    80001732:	00000097          	auipc	ra,0x0
    80001736:	944080e7          	jalr	-1724(ra) # 80001076 <walk>
  if(pte == 0)
    8000173a:	c901                	beqz	a0,8000174a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000173c:	611c                	ld	a5,0(a0)
    8000173e:	9bbd                	andi	a5,a5,-17
    80001740:	e11c                	sd	a5,0(a0)
}
    80001742:	60a2                	ld	ra,8(sp)
    80001744:	6402                	ld	s0,0(sp)
    80001746:	0141                	addi	sp,sp,16
    80001748:	8082                	ret
    panic("uvmclear");
    8000174a:	00007517          	auipc	a0,0x7
    8000174e:	a6e50513          	addi	a0,a0,-1426 # 800081b8 <digits+0x1a0>
    80001752:	fffff097          	auipc	ra,0xfffff
    80001756:	e22080e7          	jalr	-478(ra) # 80000574 <panic>

000000008000175a <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000175a:	c6bd                	beqz	a3,800017c8 <copyout+0x6e>
{
    8000175c:	715d                	addi	sp,sp,-80
    8000175e:	e486                	sd	ra,72(sp)
    80001760:	e0a2                	sd	s0,64(sp)
    80001762:	fc26                	sd	s1,56(sp)
    80001764:	f84a                	sd	s2,48(sp)
    80001766:	f44e                	sd	s3,40(sp)
    80001768:	f052                	sd	s4,32(sp)
    8000176a:	ec56                	sd	s5,24(sp)
    8000176c:	e85a                	sd	s6,16(sp)
    8000176e:	e45e                	sd	s7,8(sp)
    80001770:	e062                	sd	s8,0(sp)
    80001772:	0880                	addi	s0,sp,80
    80001774:	8baa                	mv	s7,a0
    80001776:	8a2e                	mv	s4,a1
    80001778:	8ab2                	mv	s5,a2
    8000177a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000177c:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000177e:	6b05                	lui	s6,0x1
    80001780:	a015                	j	800017a4 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001782:	9552                	add	a0,a0,s4
    80001784:	0004861b          	sext.w	a2,s1
    80001788:	85d6                	mv	a1,s5
    8000178a:	41250533          	sub	a0,a0,s2
    8000178e:	fffff097          	auipc	ra,0xfffff
    80001792:	63c080e7          	jalr	1596(ra) # 80000dca <memmove>

    len -= n;
    80001796:	409989b3          	sub	s3,s3,s1
    src += n;
    8000179a:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    8000179c:	01690a33          	add	s4,s2,s6
  while(len > 0){
    800017a0:	02098263          	beqz	s3,800017c4 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800017a4:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    800017a8:	85ca                	mv	a1,s2
    800017aa:	855e                	mv	a0,s7
    800017ac:	00000097          	auipc	ra,0x0
    800017b0:	970080e7          	jalr	-1680(ra) # 8000111c <walkaddr>
    if(pa0 == 0)
    800017b4:	cd01                	beqz	a0,800017cc <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800017b6:	414904b3          	sub	s1,s2,s4
    800017ba:	94da                	add	s1,s1,s6
    if(n > len)
    800017bc:	fc99f3e3          	bleu	s1,s3,80001782 <copyout+0x28>
    800017c0:	84ce                	mv	s1,s3
    800017c2:	b7c1                	j	80001782 <copyout+0x28>
  }
  return 0;
    800017c4:	4501                	li	a0,0
    800017c6:	a021                	j	800017ce <copyout+0x74>
    800017c8:	4501                	li	a0,0
}
    800017ca:	8082                	ret
      return -1;
    800017cc:	557d                	li	a0,-1
}
    800017ce:	60a6                	ld	ra,72(sp)
    800017d0:	6406                	ld	s0,64(sp)
    800017d2:	74e2                	ld	s1,56(sp)
    800017d4:	7942                	ld	s2,48(sp)
    800017d6:	79a2                	ld	s3,40(sp)
    800017d8:	7a02                	ld	s4,32(sp)
    800017da:	6ae2                	ld	s5,24(sp)
    800017dc:	6b42                	ld	s6,16(sp)
    800017de:	6ba2                	ld	s7,8(sp)
    800017e0:	6c02                	ld	s8,0(sp)
    800017e2:	6161                	addi	sp,sp,80
    800017e4:	8082                	ret

00000000800017e6 <copyin>:
// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
    800017e6:	1141                	addi	sp,sp,-16
    800017e8:	e406                	sd	ra,8(sp)
    800017ea:	e022                	sd	s0,0(sp)
    800017ec:	0800                	addi	s0,sp,16
  return copyin_new(pagetable, dst, srcva, len);
    800017ee:	00005097          	auipc	ra,0x5
    800017f2:	ea8080e7          	jalr	-344(ra) # 80006696 <copyin_new>
}
    800017f6:	60a2                	ld	ra,8(sp)
    800017f8:	6402                	ld	s0,0(sp)
    800017fa:	0141                	addi	sp,sp,16
    800017fc:	8082                	ret

00000000800017fe <copyinstr>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    800017fe:	1141                	addi	sp,sp,-16
    80001800:	e406                	sd	ra,8(sp)
    80001802:	e022                	sd	s0,0(sp)
    80001804:	0800                	addi	s0,sp,16
  return copyinstr_new(pagetable, dst, srcva, max);
    80001806:	00005097          	auipc	ra,0x5
    8000180a:	ef8080e7          	jalr	-264(ra) # 800066fe <copyinstr_new>
}
    8000180e:	60a2                	ld	ra,8(sp)
    80001810:	6402                	ld	s0,0(sp)
    80001812:	0141                	addi	sp,sp,16
    80001814:	8082                	ret

0000000080001816 <printwalk>:

void printwalk(pagetable_t pagetable, uint level) {
    80001816:	715d                	addi	sp,sp,-80
    80001818:	e486                	sd	ra,72(sp)
    8000181a:	e0a2                	sd	s0,64(sp)
    8000181c:	fc26                	sd	s1,56(sp)
    8000181e:	f84a                	sd	s2,48(sp)
    80001820:	f44e                	sd	s3,40(sp)
    80001822:	f052                	sd	s4,32(sp)
    80001824:	ec56                	sd	s5,24(sp)
    80001826:	e85a                	sd	s6,16(sp)
    80001828:	e45e                	sd	s7,8(sp)
    8000182a:	e062                	sd	s8,0(sp)
    8000182c:	0880                	addi	s0,sp,80
  char* prefix;
  if (level == 2) prefix = "..";
    8000182e:	4789                	li	a5,2
    80001830:	00007b17          	auipc	s6,0x7
    80001834:	998b0b13          	addi	s6,s6,-1640 # 800081c8 <digits+0x1b0>
    80001838:	00f58d63          	beq	a1,a5,80001852 <printwalk+0x3c>
  else if (level == 1) prefix = ".. ..";
    8000183c:	4785                	li	a5,1
    8000183e:	00007b17          	auipc	s6,0x7
    80001842:	992b0b13          	addi	s6,s6,-1646 # 800081d0 <digits+0x1b8>
    80001846:	00f58663          	beq	a1,a5,80001852 <printwalk+0x3c>
  else prefix = ".. .. ..";
    8000184a:	00007b17          	auipc	s6,0x7
    8000184e:	98eb0b13          	addi	s6,s6,-1650 # 800081d8 <digits+0x1c0>

  for(int i = 0; i < 512; i++){
    80001852:	89aa                	mv	s3,a0
    80001854:	4901                	li	s2,0
    pte_t pte = pagetable[i];
    if(pte & PTE_V){
      uint64 pa = PTE2PA(pte);
      printf("%s%d: pte %p pa %p\n", prefix, i, pte, pa);
    80001856:	00007b97          	auipc	s7,0x7
    8000185a:	992b8b93          	addi	s7,s7,-1646 # 800081e8 <digits+0x1d0>
      if((pte & (PTE_R|PTE_W|PTE_X)) == 0){
        printwalk((pagetable_t)pa, level - 1);
    8000185e:	fff58c1b          	addiw	s8,a1,-1
  for(int i = 0; i < 512; i++){
    80001862:	20000a93          	li	s5,512
    80001866:	a819                	j	8000187c <printwalk+0x66>
        printwalk((pagetable_t)pa, level - 1);
    80001868:	85e2                	mv	a1,s8
    8000186a:	8552                	mv	a0,s4
    8000186c:	00000097          	auipc	ra,0x0
    80001870:	faa080e7          	jalr	-86(ra) # 80001816 <printwalk>
  for(int i = 0; i < 512; i++){
    80001874:	2905                	addiw	s2,s2,1
    80001876:	09a1                	addi	s3,s3,8
    80001878:	03590663          	beq	s2,s5,800018a4 <printwalk+0x8e>
    pte_t pte = pagetable[i];
    8000187c:	0009b483          	ld	s1,0(s3) # fffffffffffff000 <end+0xffffffff7ffd7fe0>
    if(pte & PTE_V){
    80001880:	0014f793          	andi	a5,s1,1
    80001884:	dbe5                	beqz	a5,80001874 <printwalk+0x5e>
      uint64 pa = PTE2PA(pte);
    80001886:	00a4da13          	srli	s4,s1,0xa
    8000188a:	0a32                	slli	s4,s4,0xc
      printf("%s%d: pte %p pa %p\n", prefix, i, pte, pa);
    8000188c:	8752                	mv	a4,s4
    8000188e:	86a6                	mv	a3,s1
    80001890:	864a                	mv	a2,s2
    80001892:	85da                	mv	a1,s6
    80001894:	855e                	mv	a0,s7
    80001896:	fffff097          	auipc	ra,0xfffff
    8000189a:	d28080e7          	jalr	-728(ra) # 800005be <printf>
      if((pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000189e:	88b9                	andi	s1,s1,14
    800018a0:	f8f1                	bnez	s1,80001874 <printwalk+0x5e>
    800018a2:	b7d9                	j	80001868 <printwalk+0x52>
      }
    }
  }
}
    800018a4:	60a6                	ld	ra,72(sp)
    800018a6:	6406                	ld	s0,64(sp)
    800018a8:	74e2                	ld	s1,56(sp)
    800018aa:	7942                	ld	s2,48(sp)
    800018ac:	79a2                	ld	s3,40(sp)
    800018ae:	7a02                	ld	s4,32(sp)
    800018b0:	6ae2                	ld	s5,24(sp)
    800018b2:	6b42                	ld	s6,16(sp)
    800018b4:	6ba2                	ld	s7,8(sp)
    800018b6:	6c02                	ld	s8,0(sp)
    800018b8:	6161                	addi	sp,sp,80
    800018ba:	8082                	ret

00000000800018bc <vmprint>:

void
vmprint(pagetable_t pagetable) {
    800018bc:	1101                	addi	sp,sp,-32
    800018be:	ec06                	sd	ra,24(sp)
    800018c0:	e822                	sd	s0,16(sp)
    800018c2:	e426                	sd	s1,8(sp)
    800018c4:	1000                	addi	s0,sp,32
    800018c6:	84aa                	mv	s1,a0
  printf("page table %p\n", pagetable);
    800018c8:	85aa                	mv	a1,a0
    800018ca:	00007517          	auipc	a0,0x7
    800018ce:	93650513          	addi	a0,a0,-1738 # 80008200 <digits+0x1e8>
    800018d2:	fffff097          	auipc	ra,0xfffff
    800018d6:	cec080e7          	jalr	-788(ra) # 800005be <printf>
  printwalk(pagetable, 2);
    800018da:	4589                	li	a1,2
    800018dc:	8526                	mv	a0,s1
    800018de:	00000097          	auipc	ra,0x0
    800018e2:	f38080e7          	jalr	-200(ra) # 80001816 <printwalk>
}
    800018e6:	60e2                	ld	ra,24(sp)
    800018e8:	6442                	ld	s0,16(sp)
    800018ea:	64a2                	ld	s1,8(sp)
    800018ec:	6105                	addi	sp,sp,32
    800018ee:	8082                	ret

00000000800018f0 <ukvmmap>:

// add a mapping to the user kernel page table.
void
ukvmmap(pagetable_t pagetable ,uint64 va, uint64 pa, uint64 sz, int perm)
{
    800018f0:	1141                	addi	sp,sp,-16
    800018f2:	e406                	sd	ra,8(sp)
    800018f4:	e022                	sd	s0,0(sp)
    800018f6:	0800                	addi	s0,sp,16
    800018f8:	87b6                	mv	a5,a3
  if(mappages(pagetable, va, sz, pa, perm) != 0)
    800018fa:	86b2                	mv	a3,a2
    800018fc:	863e                	mv	a2,a5
    800018fe:	00000097          	auipc	ra,0x0
    80001902:	8c8080e7          	jalr	-1848(ra) # 800011c6 <mappages>
    80001906:	e509                	bnez	a0,80001910 <ukvmmap+0x20>
    panic("ukvmmap");
}
    80001908:	60a2                	ld	ra,8(sp)
    8000190a:	6402                	ld	s0,0(sp)
    8000190c:	0141                	addi	sp,sp,16
    8000190e:	8082                	ret
    panic("ukvmmap");
    80001910:	00007517          	auipc	a0,0x7
    80001914:	90050513          	addi	a0,a0,-1792 # 80008210 <digits+0x1f8>
    80001918:	fffff097          	auipc	ra,0xfffff
    8000191c:	c5c080e7          	jalr	-932(ra) # 80000574 <panic>

0000000080001920 <ukvmcopy>:
ukvmcopy(pagetable_t pagetable, pagetable_t kpagetable, uint64 oldsz, uint64 newsz)
{
  pte_t *src, *dest;
  uint64 cur;

  if (newsz < oldsz)
    80001920:	0ac6e063          	bltu	a3,a2,800019c0 <ukvmcopy+0xa0>
{
    80001924:	715d                	addi	sp,sp,-80
    80001926:	e486                	sd	ra,72(sp)
    80001928:	e0a2                	sd	s0,64(sp)
    8000192a:	fc26                	sd	s1,56(sp)
    8000192c:	f84a                	sd	s2,48(sp)
    8000192e:	f44e                	sd	s3,40(sp)
    80001930:	f052                	sd	s4,32(sp)
    80001932:	ec56                	sd	s5,24(sp)
    80001934:	e85a                	sd	s6,16(sp)
    80001936:	e45e                	sd	s7,8(sp)
    80001938:	0880                	addi	s0,sp,80
    return;

  oldsz = PGROUNDUP(oldsz);
    8000193a:	6485                	lui	s1,0x1
    8000193c:	14fd                	addi	s1,s1,-1
    8000193e:	9626                	add	a2,a2,s1
    80001940:	74fd                	lui	s1,0xfffff
    80001942:	8cf1                	and	s1,s1,a2
  for(cur = oldsz; cur < newsz; cur += PGSIZE){
    80001944:	04d4f363          	bleu	a3,s1,8000198a <ukvmcopy+0x6a>
    80001948:	89b6                	mv	s3,a3
    8000194a:	8aae                	mv	s5,a1
    8000194c:	8a2a                	mv	s4,a0
      panic("ukvmcopy: pte not exist");
    if ((dest = walk(kpagetable, cur, 1)) == 0)
      panic("ukvmcopy: pte alloc failed");
    
    uint64 pa = PTE2PA(*src);
    *dest = PA2PTE(pa) | (PTE_FLAGS(*src) & (~PTE_U));
    8000194e:	fbf00b13          	li	s6,-65
    80001952:	002b5b13          	srli	s6,s6,0x2
  for(cur = oldsz; cur < newsz; cur += PGSIZE){
    80001956:	6b85                	lui	s7,0x1
    if ((src = walk(pagetable, cur, 0)) == 0)
    80001958:	4601                	li	a2,0
    8000195a:	85a6                	mv	a1,s1
    8000195c:	8552                	mv	a0,s4
    8000195e:	fffff097          	auipc	ra,0xfffff
    80001962:	718080e7          	jalr	1816(ra) # 80001076 <walk>
    80001966:	892a                	mv	s2,a0
    80001968:	cd05                	beqz	a0,800019a0 <ukvmcopy+0x80>
    if ((dest = walk(kpagetable, cur, 1)) == 0)
    8000196a:	4605                	li	a2,1
    8000196c:	85a6                	mv	a1,s1
    8000196e:	8556                	mv	a0,s5
    80001970:	fffff097          	auipc	ra,0xfffff
    80001974:	706080e7          	jalr	1798(ra) # 80001076 <walk>
    80001978:	cd05                	beqz	a0,800019b0 <ukvmcopy+0x90>
    *dest = PA2PTE(pa) | (PTE_FLAGS(*src) & (~PTE_U));
    8000197a:	00093783          	ld	a5,0(s2) # 1000 <_entry-0x7ffff000>
    8000197e:	0167f7b3          	and	a5,a5,s6
    80001982:	e11c                	sd	a5,0(a0)
  for(cur = oldsz; cur < newsz; cur += PGSIZE){
    80001984:	94de                	add	s1,s1,s7
    80001986:	fd34e9e3          	bltu	s1,s3,80001958 <ukvmcopy+0x38>
  }
}
    8000198a:	60a6                	ld	ra,72(sp)
    8000198c:	6406                	ld	s0,64(sp)
    8000198e:	74e2                	ld	s1,56(sp)
    80001990:	7942                	ld	s2,48(sp)
    80001992:	79a2                	ld	s3,40(sp)
    80001994:	7a02                	ld	s4,32(sp)
    80001996:	6ae2                	ld	s5,24(sp)
    80001998:	6b42                	ld	s6,16(sp)
    8000199a:	6ba2                	ld	s7,8(sp)
    8000199c:	6161                	addi	sp,sp,80
    8000199e:	8082                	ret
      panic("ukvmcopy: pte not exist");
    800019a0:	00007517          	auipc	a0,0x7
    800019a4:	87850513          	addi	a0,a0,-1928 # 80008218 <digits+0x200>
    800019a8:	fffff097          	auipc	ra,0xfffff
    800019ac:	bcc080e7          	jalr	-1076(ra) # 80000574 <panic>
      panic("ukvmcopy: pte alloc failed");
    800019b0:	00007517          	auipc	a0,0x7
    800019b4:	88050513          	addi	a0,a0,-1920 # 80008230 <digits+0x218>
    800019b8:	fffff097          	auipc	ra,0xfffff
    800019bc:	bbc080e7          	jalr	-1092(ra) # 80000574 <panic>
    800019c0:	8082                	ret

00000000800019c2 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800019c2:	1101                	addi	sp,sp,-32
    800019c4:	ec06                	sd	ra,24(sp)
    800019c6:	e822                	sd	s0,16(sp)
    800019c8:	e426                	sd	s1,8(sp)
    800019ca:	1000                	addi	s0,sp,32
    800019cc:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800019ce:	fffff097          	auipc	ra,0xfffff
    800019d2:	21a080e7          	jalr	538(ra) # 80000be8 <holding>
    800019d6:	c909                	beqz	a0,800019e8 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800019d8:	749c                	ld	a5,40(s1)
    800019da:	00978f63          	beq	a5,s1,800019f8 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    800019de:	60e2                	ld	ra,24(sp)
    800019e0:	6442                	ld	s0,16(sp)
    800019e2:	64a2                	ld	s1,8(sp)
    800019e4:	6105                	addi	sp,sp,32
    800019e6:	8082                	ret
    panic("wakeup1");
    800019e8:	00007517          	auipc	a0,0x7
    800019ec:	89050513          	addi	a0,a0,-1904 # 80008278 <states.1778+0x28>
    800019f0:	fffff097          	auipc	ra,0xfffff
    800019f4:	b84080e7          	jalr	-1148(ra) # 80000574 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    800019f8:	4c98                	lw	a4,24(s1)
    800019fa:	4785                	li	a5,1
    800019fc:	fef711e3          	bne	a4,a5,800019de <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001a00:	4789                	li	a5,2
    80001a02:	cc9c                	sw	a5,24(s1)
}
    80001a04:	bfe9                	j	800019de <wakeup1+0x1c>

0000000080001a06 <procinit>:
{
    80001a06:	7179                	addi	sp,sp,-48
    80001a08:	f406                	sd	ra,40(sp)
    80001a0a:	f022                	sd	s0,32(sp)
    80001a0c:	ec26                	sd	s1,24(sp)
    80001a0e:	e84a                	sd	s2,16(sp)
    80001a10:	e44e                	sd	s3,8(sp)
    80001a12:	1800                	addi	s0,sp,48
  initlock(&pid_lock, "nextpid");
    80001a14:	00007597          	auipc	a1,0x7
    80001a18:	86c58593          	addi	a1,a1,-1940 # 80008280 <states.1778+0x30>
    80001a1c:	00010517          	auipc	a0,0x10
    80001a20:	f3450513          	addi	a0,a0,-204 # 80011950 <pid_lock>
    80001a24:	fffff097          	auipc	ra,0xfffff
    80001a28:	1ae080e7          	jalr	430(ra) # 80000bd2 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a2c:	00010497          	auipc	s1,0x10
    80001a30:	33c48493          	addi	s1,s1,828 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001a34:	00007997          	auipc	s3,0x7
    80001a38:	85498993          	addi	s3,s3,-1964 # 80008288 <states.1778+0x38>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a3c:	00016917          	auipc	s2,0x16
    80001a40:	f2c90913          	addi	s2,s2,-212 # 80017968 <tickslock>
      initlock(&p->lock, "proc");
    80001a44:	85ce                	mv	a1,s3
    80001a46:	8526                	mv	a0,s1
    80001a48:	fffff097          	auipc	ra,0xfffff
    80001a4c:	18a080e7          	jalr	394(ra) # 80000bd2 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a50:	17048493          	addi	s1,s1,368
    80001a54:	ff2498e3          	bne	s1,s2,80001a44 <procinit+0x3e>
  kvminithart();
    80001a58:	fffff097          	auipc	ra,0xfffff
    80001a5c:	5f8080e7          	jalr	1528(ra) # 80001050 <kvminithart>
}
    80001a60:	70a2                	ld	ra,40(sp)
    80001a62:	7402                	ld	s0,32(sp)
    80001a64:	64e2                	ld	s1,24(sp)
    80001a66:	6942                	ld	s2,16(sp)
    80001a68:	69a2                	ld	s3,8(sp)
    80001a6a:	6145                	addi	sp,sp,48
    80001a6c:	8082                	ret

0000000080001a6e <cpuid>:
{
    80001a6e:	1141                	addi	sp,sp,-16
    80001a70:	e422                	sd	s0,8(sp)
    80001a72:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a74:	8512                	mv	a0,tp
}
    80001a76:	2501                	sext.w	a0,a0
    80001a78:	6422                	ld	s0,8(sp)
    80001a7a:	0141                	addi	sp,sp,16
    80001a7c:	8082                	ret

0000000080001a7e <mycpu>:
mycpu(void) {
    80001a7e:	1141                	addi	sp,sp,-16
    80001a80:	e422                	sd	s0,8(sp)
    80001a82:	0800                	addi	s0,sp,16
    80001a84:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a86:	2781                	sext.w	a5,a5
    80001a88:	079e                	slli	a5,a5,0x7
}
    80001a8a:	00010517          	auipc	a0,0x10
    80001a8e:	ede50513          	addi	a0,a0,-290 # 80011968 <cpus>
    80001a92:	953e                	add	a0,a0,a5
    80001a94:	6422                	ld	s0,8(sp)
    80001a96:	0141                	addi	sp,sp,16
    80001a98:	8082                	ret

0000000080001a9a <myproc>:
myproc(void) {
    80001a9a:	1101                	addi	sp,sp,-32
    80001a9c:	ec06                	sd	ra,24(sp)
    80001a9e:	e822                	sd	s0,16(sp)
    80001aa0:	e426                	sd	s1,8(sp)
    80001aa2:	1000                	addi	s0,sp,32
  push_off();
    80001aa4:	fffff097          	auipc	ra,0xfffff
    80001aa8:	172080e7          	jalr	370(ra) # 80000c16 <push_off>
    80001aac:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001aae:	2781                	sext.w	a5,a5
    80001ab0:	079e                	slli	a5,a5,0x7
    80001ab2:	00010717          	auipc	a4,0x10
    80001ab6:	e9e70713          	addi	a4,a4,-354 # 80011950 <pid_lock>
    80001aba:	97ba                	add	a5,a5,a4
    80001abc:	6f84                	ld	s1,24(a5)
  pop_off();
    80001abe:	fffff097          	auipc	ra,0xfffff
    80001ac2:	1f8080e7          	jalr	504(ra) # 80000cb6 <pop_off>
}
    80001ac6:	8526                	mv	a0,s1
    80001ac8:	60e2                	ld	ra,24(sp)
    80001aca:	6442                	ld	s0,16(sp)
    80001acc:	64a2                	ld	s1,8(sp)
    80001ace:	6105                	addi	sp,sp,32
    80001ad0:	8082                	ret

0000000080001ad2 <forkret>:
{
    80001ad2:	1141                	addi	sp,sp,-16
    80001ad4:	e406                	sd	ra,8(sp)
    80001ad6:	e022                	sd	s0,0(sp)
    80001ad8:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001ada:	00000097          	auipc	ra,0x0
    80001ade:	fc0080e7          	jalr	-64(ra) # 80001a9a <myproc>
    80001ae2:	fffff097          	auipc	ra,0xfffff
    80001ae6:	234080e7          	jalr	564(ra) # 80000d16 <release>
  if (first) {
    80001aea:	00007797          	auipc	a5,0x7
    80001aee:	e0678793          	addi	a5,a5,-506 # 800088f0 <first.1738>
    80001af2:	439c                	lw	a5,0(a5)
    80001af4:	eb89                	bnez	a5,80001b06 <forkret+0x34>
  usertrapret();
    80001af6:	00001097          	auipc	ra,0x1
    80001afa:	ed6080e7          	jalr	-298(ra) # 800029cc <usertrapret>
}
    80001afe:	60a2                	ld	ra,8(sp)
    80001b00:	6402                	ld	s0,0(sp)
    80001b02:	0141                	addi	sp,sp,16
    80001b04:	8082                	ret
    first = 0;
    80001b06:	00007797          	auipc	a5,0x7
    80001b0a:	de07a523          	sw	zero,-534(a5) # 800088f0 <first.1738>
    fsinit(ROOTDEV);
    80001b0e:	4505                	li	a0,1
    80001b10:	00002097          	auipc	ra,0x2
    80001b14:	c50080e7          	jalr	-944(ra) # 80003760 <fsinit>
    80001b18:	bff9                	j	80001af6 <forkret+0x24>

0000000080001b1a <allocpid>:
allocpid() {
    80001b1a:	1101                	addi	sp,sp,-32
    80001b1c:	ec06                	sd	ra,24(sp)
    80001b1e:	e822                	sd	s0,16(sp)
    80001b20:	e426                	sd	s1,8(sp)
    80001b22:	e04a                	sd	s2,0(sp)
    80001b24:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b26:	00010917          	auipc	s2,0x10
    80001b2a:	e2a90913          	addi	s2,s2,-470 # 80011950 <pid_lock>
    80001b2e:	854a                	mv	a0,s2
    80001b30:	fffff097          	auipc	ra,0xfffff
    80001b34:	132080e7          	jalr	306(ra) # 80000c62 <acquire>
  pid = nextpid;
    80001b38:	00007797          	auipc	a5,0x7
    80001b3c:	dbc78793          	addi	a5,a5,-580 # 800088f4 <nextpid>
    80001b40:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b42:	0014871b          	addiw	a4,s1,1
    80001b46:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b48:	854a                	mv	a0,s2
    80001b4a:	fffff097          	auipc	ra,0xfffff
    80001b4e:	1cc080e7          	jalr	460(ra) # 80000d16 <release>
}
    80001b52:	8526                	mv	a0,s1
    80001b54:	60e2                	ld	ra,24(sp)
    80001b56:	6442                	ld	s0,16(sp)
    80001b58:	64a2                	ld	s1,8(sp)
    80001b5a:	6902                	ld	s2,0(sp)
    80001b5c:	6105                	addi	sp,sp,32
    80001b5e:	8082                	ret

0000000080001b60 <proc_pagetable>:
{
    80001b60:	1101                	addi	sp,sp,-32
    80001b62:	ec06                	sd	ra,24(sp)
    80001b64:	e822                	sd	s0,16(sp)
    80001b66:	e426                	sd	s1,8(sp)
    80001b68:	e04a                	sd	s2,0(sp)
    80001b6a:	1000                	addi	s0,sp,32
    80001b6c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b6e:	00000097          	auipc	ra,0x0
    80001b72:	8b6080e7          	jalr	-1866(ra) # 80001424 <uvmcreate>
    80001b76:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b78:	c121                	beqz	a0,80001bb8 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b7a:	4729                	li	a4,10
    80001b7c:	00005697          	auipc	a3,0x5
    80001b80:	48468693          	addi	a3,a3,1156 # 80007000 <_trampoline>
    80001b84:	6605                	lui	a2,0x1
    80001b86:	040005b7          	lui	a1,0x4000
    80001b8a:	15fd                	addi	a1,a1,-1
    80001b8c:	05b2                	slli	a1,a1,0xc
    80001b8e:	fffff097          	auipc	ra,0xfffff
    80001b92:	638080e7          	jalr	1592(ra) # 800011c6 <mappages>
    80001b96:	02054863          	bltz	a0,80001bc6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b9a:	4719                	li	a4,6
    80001b9c:	06093683          	ld	a3,96(s2)
    80001ba0:	6605                	lui	a2,0x1
    80001ba2:	020005b7          	lui	a1,0x2000
    80001ba6:	15fd                	addi	a1,a1,-1
    80001ba8:	05b6                	slli	a1,a1,0xd
    80001baa:	8526                	mv	a0,s1
    80001bac:	fffff097          	auipc	ra,0xfffff
    80001bb0:	61a080e7          	jalr	1562(ra) # 800011c6 <mappages>
    80001bb4:	02054163          	bltz	a0,80001bd6 <proc_pagetable+0x76>
}
    80001bb8:	8526                	mv	a0,s1
    80001bba:	60e2                	ld	ra,24(sp)
    80001bbc:	6442                	ld	s0,16(sp)
    80001bbe:	64a2                	ld	s1,8(sp)
    80001bc0:	6902                	ld	s2,0(sp)
    80001bc2:	6105                	addi	sp,sp,32
    80001bc4:	8082                	ret
    uvmfree(pagetable, 0);
    80001bc6:	4581                	li	a1,0
    80001bc8:	8526                	mv	a0,s1
    80001bca:	00000097          	auipc	ra,0x0
    80001bce:	a54080e7          	jalr	-1452(ra) # 8000161e <uvmfree>
    return 0;
    80001bd2:	4481                	li	s1,0
    80001bd4:	b7d5                	j	80001bb8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bd6:	4681                	li	a3,0
    80001bd8:	4605                	li	a2,1
    80001bda:	040005b7          	lui	a1,0x4000
    80001bde:	15fd                	addi	a1,a1,-1
    80001be0:	05b2                	slli	a1,a1,0xc
    80001be2:	8526                	mv	a0,s1
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	77a080e7          	jalr	1914(ra) # 8000135e <uvmunmap>
    uvmfree(pagetable, 0);
    80001bec:	4581                	li	a1,0
    80001bee:	8526                	mv	a0,s1
    80001bf0:	00000097          	auipc	ra,0x0
    80001bf4:	a2e080e7          	jalr	-1490(ra) # 8000161e <uvmfree>
    return 0;
    80001bf8:	4481                	li	s1,0
    80001bfa:	bf7d                	j	80001bb8 <proc_pagetable+0x58>

0000000080001bfc <proc_kpagetable>:
proc_kpagetable(struct proc *p) {
    80001bfc:	7179                	addi	sp,sp,-48
    80001bfe:	f406                	sd	ra,40(sp)
    80001c00:	f022                	sd	s0,32(sp)
    80001c02:	ec26                	sd	s1,24(sp)
    80001c04:	e84a                	sd	s2,16(sp)
    80001c06:	e44e                	sd	s3,8(sp)
    80001c08:	1800                	addi	s0,sp,48
    80001c0a:	89aa                	mv	s3,a0
  kpagetable = uvmcreate();
    80001c0c:	00000097          	auipc	ra,0x0
    80001c10:	818080e7          	jalr	-2024(ra) # 80001424 <uvmcreate>
    80001c14:	84aa                	mv	s1,a0
  if(kpagetable == 0)
    80001c16:	c95d                	beqz	a0,80001ccc <proc_kpagetable+0xd0>
  ukvmmap(kpagetable, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001c18:	4719                	li	a4,6
    80001c1a:	6685                	lui	a3,0x1
    80001c1c:	10000637          	lui	a2,0x10000
    80001c20:	100005b7          	lui	a1,0x10000
    80001c24:	00000097          	auipc	ra,0x0
    80001c28:	ccc080e7          	jalr	-820(ra) # 800018f0 <ukvmmap>
  ukvmmap(kpagetable, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001c2c:	4719                	li	a4,6
    80001c2e:	6685                	lui	a3,0x1
    80001c30:	10001637          	lui	a2,0x10001
    80001c34:	100015b7          	lui	a1,0x10001
    80001c38:	8526                	mv	a0,s1
    80001c3a:	00000097          	auipc	ra,0x0
    80001c3e:	cb6080e7          	jalr	-842(ra) # 800018f0 <ukvmmap>
  ukvmmap(kpagetable, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001c42:	4719                	li	a4,6
    80001c44:	004006b7          	lui	a3,0x400
    80001c48:	0c000637          	lui	a2,0xc000
    80001c4c:	0c0005b7          	lui	a1,0xc000
    80001c50:	8526                	mv	a0,s1
    80001c52:	00000097          	auipc	ra,0x0
    80001c56:	c9e080e7          	jalr	-866(ra) # 800018f0 <ukvmmap>
  ukvmmap(kpagetable, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001c5a:	00006917          	auipc	s2,0x6
    80001c5e:	3a690913          	addi	s2,s2,934 # 80008000 <etext>
    80001c62:	4729                	li	a4,10
    80001c64:	80006697          	auipc	a3,0x80006
    80001c68:	39c68693          	addi	a3,a3,924 # 8000 <_entry-0x7fff8000>
    80001c6c:	4605                	li	a2,1
    80001c6e:	067e                	slli	a2,a2,0x1f
    80001c70:	85b2                	mv	a1,a2
    80001c72:	8526                	mv	a0,s1
    80001c74:	00000097          	auipc	ra,0x0
    80001c78:	c7c080e7          	jalr	-900(ra) # 800018f0 <ukvmmap>
  ukvmmap(kpagetable, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001c7c:	4719                	li	a4,6
    80001c7e:	46c5                	li	a3,17
    80001c80:	06ee                	slli	a3,a3,0x1b
    80001c82:	412686b3          	sub	a3,a3,s2
    80001c86:	864a                	mv	a2,s2
    80001c88:	85ca                	mv	a1,s2
    80001c8a:	8526                	mv	a0,s1
    80001c8c:	00000097          	auipc	ra,0x0
    80001c90:	c64080e7          	jalr	-924(ra) # 800018f0 <ukvmmap>
  ukvmmap(kpagetable, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001c94:	4729                	li	a4,10
    80001c96:	6685                	lui	a3,0x1
    80001c98:	00005617          	auipc	a2,0x5
    80001c9c:	36860613          	addi	a2,a2,872 # 80007000 <_trampoline>
    80001ca0:	040005b7          	lui	a1,0x4000
    80001ca4:	15fd                	addi	a1,a1,-1
    80001ca6:	05b2                	slli	a1,a1,0xc
    80001ca8:	8526                	mv	a0,s1
    80001caa:	00000097          	auipc	ra,0x0
    80001cae:	c46080e7          	jalr	-954(ra) # 800018f0 <ukvmmap>
  ukvmmap(kpagetable, TRAPFRAME, (uint64)(p->trapframe), PGSIZE, PTE_R | PTE_W);
    80001cb2:	4719                	li	a4,6
    80001cb4:	6685                	lui	a3,0x1
    80001cb6:	0609b603          	ld	a2,96(s3)
    80001cba:	020005b7          	lui	a1,0x2000
    80001cbe:	15fd                	addi	a1,a1,-1
    80001cc0:	05b6                	slli	a1,a1,0xd
    80001cc2:	8526                	mv	a0,s1
    80001cc4:	00000097          	auipc	ra,0x0
    80001cc8:	c2c080e7          	jalr	-980(ra) # 800018f0 <ukvmmap>
}
    80001ccc:	8526                	mv	a0,s1
    80001cce:	70a2                	ld	ra,40(sp)
    80001cd0:	7402                	ld	s0,32(sp)
    80001cd2:	64e2                	ld	s1,24(sp)
    80001cd4:	6942                	ld	s2,16(sp)
    80001cd6:	69a2                	ld	s3,8(sp)
    80001cd8:	6145                	addi	sp,sp,48
    80001cda:	8082                	ret

0000000080001cdc <proc_freepagetable>:
{
    80001cdc:	1101                	addi	sp,sp,-32
    80001cde:	ec06                	sd	ra,24(sp)
    80001ce0:	e822                	sd	s0,16(sp)
    80001ce2:	e426                	sd	s1,8(sp)
    80001ce4:	e04a                	sd	s2,0(sp)
    80001ce6:	1000                	addi	s0,sp,32
    80001ce8:	84aa                	mv	s1,a0
    80001cea:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cec:	4681                	li	a3,0
    80001cee:	4605                	li	a2,1
    80001cf0:	040005b7          	lui	a1,0x4000
    80001cf4:	15fd                	addi	a1,a1,-1
    80001cf6:	05b2                	slli	a1,a1,0xc
    80001cf8:	fffff097          	auipc	ra,0xfffff
    80001cfc:	666080e7          	jalr	1638(ra) # 8000135e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d00:	4681                	li	a3,0
    80001d02:	4605                	li	a2,1
    80001d04:	020005b7          	lui	a1,0x2000
    80001d08:	15fd                	addi	a1,a1,-1
    80001d0a:	05b6                	slli	a1,a1,0xd
    80001d0c:	8526                	mv	a0,s1
    80001d0e:	fffff097          	auipc	ra,0xfffff
    80001d12:	650080e7          	jalr	1616(ra) # 8000135e <uvmunmap>
  uvmfree(pagetable, sz);
    80001d16:	85ca                	mv	a1,s2
    80001d18:	8526                	mv	a0,s1
    80001d1a:	00000097          	auipc	ra,0x0
    80001d1e:	904080e7          	jalr	-1788(ra) # 8000161e <uvmfree>
}
    80001d22:	60e2                	ld	ra,24(sp)
    80001d24:	6442                	ld	s0,16(sp)
    80001d26:	64a2                	ld	s1,8(sp)
    80001d28:	6902                	ld	s2,0(sp)
    80001d2a:	6105                	addi	sp,sp,32
    80001d2c:	8082                	ret

0000000080001d2e <proc_freekpagetable>:
{
    80001d2e:	7179                	addi	sp,sp,-48
    80001d30:	f406                	sd	ra,40(sp)
    80001d32:	f022                	sd	s0,32(sp)
    80001d34:	ec26                	sd	s1,24(sp)
    80001d36:	e84a                	sd	s2,16(sp)
    80001d38:	e44e                	sd	s3,8(sp)
    80001d3a:	1800                	addi	s0,sp,48
    80001d3c:	89aa                	mv	s3,a0
  for (int i = 0; i < 512; i++) {
    80001d3e:	84aa                	mv	s1,a0
    80001d40:	6905                	lui	s2,0x1
    80001d42:	992a                	add	s2,s2,a0
    80001d44:	a811                	j	80001d58 <proc_freekpagetable+0x2a>
				uint64 child = PTE2PA(pte);
    80001d46:	8129                	srli	a0,a0,0xa
				proc_freekpagetable((pagetable_t)child);
    80001d48:	0532                	slli	a0,a0,0xc
    80001d4a:	00000097          	auipc	ra,0x0
    80001d4e:	fe4080e7          	jalr	-28(ra) # 80001d2e <proc_freekpagetable>
  for (int i = 0; i < 512; i++) {
    80001d52:	04a1                	addi	s1,s1,8
    80001d54:	01248a63          	beq	s1,s2,80001d68 <proc_freekpagetable+0x3a>
		pte_t pte = kpagetable[i];
    80001d58:	6088                	ld	a0,0(s1)
		if (pte & PTE_V) {
    80001d5a:	00157793          	andi	a5,a0,1
    80001d5e:	dbf5                	beqz	a5,80001d52 <proc_freekpagetable+0x24>
			if ((pte & (PTE_R|PTE_W|PTE_X)) == 0) {
    80001d60:	00e57793          	andi	a5,a0,14
    80001d64:	f7fd                	bnez	a5,80001d52 <proc_freekpagetable+0x24>
    80001d66:	b7c5                	j	80001d46 <proc_freekpagetable+0x18>
	kfree((void*)kpagetable);
    80001d68:	854e                	mv	a0,s3
    80001d6a:	fffff097          	auipc	ra,0xfffff
    80001d6e:	d08080e7          	jalr	-760(ra) # 80000a72 <kfree>
}
    80001d72:	70a2                	ld	ra,40(sp)
    80001d74:	7402                	ld	s0,32(sp)
    80001d76:	64e2                	ld	s1,24(sp)
    80001d78:	6942                	ld	s2,16(sp)
    80001d7a:	69a2                	ld	s3,8(sp)
    80001d7c:	6145                	addi	sp,sp,48
    80001d7e:	8082                	ret

0000000080001d80 <freeproc>:
{
    80001d80:	1101                	addi	sp,sp,-32
    80001d82:	ec06                	sd	ra,24(sp)
    80001d84:	e822                	sd	s0,16(sp)
    80001d86:	e426                	sd	s1,8(sp)
    80001d88:	1000                	addi	s0,sp,32
    80001d8a:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001d8c:	7128                	ld	a0,96(a0)
    80001d8e:	c509                	beqz	a0,80001d98 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001d90:	fffff097          	auipc	ra,0xfffff
    80001d94:	ce2080e7          	jalr	-798(ra) # 80000a72 <kfree>
  p->trapframe = 0;
    80001d98:	0604b023          	sd	zero,96(s1)
  pte_t *pte = walk(p->kpagetable, p->kstack, 0);
    80001d9c:	4601                	li	a2,0
    80001d9e:	60ac                	ld	a1,64(s1)
    80001da0:	6ca8                	ld	a0,88(s1)
    80001da2:	fffff097          	auipc	ra,0xfffff
    80001da6:	2d4080e7          	jalr	724(ra) # 80001076 <walk>
  if(pte == 0)
    80001daa:	cd31                	beqz	a0,80001e06 <freeproc+0x86>
  kfree((void*)PTE2PA(*pte));
    80001dac:	6108                	ld	a0,0(a0)
    80001dae:	8129                	srli	a0,a0,0xa
    80001db0:	0532                	slli	a0,a0,0xc
    80001db2:	fffff097          	auipc	ra,0xfffff
    80001db6:	cc0080e7          	jalr	-832(ra) # 80000a72 <kfree>
  p->kstack = 0;
    80001dba:	0404b023          	sd	zero,64(s1)
  if(p->pagetable)
    80001dbe:	68a8                	ld	a0,80(s1)
    80001dc0:	c511                	beqz	a0,80001dcc <freeproc+0x4c>
    proc_freepagetable(p->pagetable, p->sz);
    80001dc2:	64ac                	ld	a1,72(s1)
    80001dc4:	00000097          	auipc	ra,0x0
    80001dc8:	f18080e7          	jalr	-232(ra) # 80001cdc <proc_freepagetable>
  if(p->kpagetable)
    80001dcc:	6ca8                	ld	a0,88(s1)
    80001dce:	c509                	beqz	a0,80001dd8 <freeproc+0x58>
    proc_freekpagetable(p->kpagetable);
    80001dd0:	00000097          	auipc	ra,0x0
    80001dd4:	f5e080e7          	jalr	-162(ra) # 80001d2e <proc_freekpagetable>
  p->pagetable = 0;
    80001dd8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ddc:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001de0:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001de4:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001de8:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001dec:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001df0:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001df4:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001df8:	0004ac23          	sw	zero,24(s1)
}
    80001dfc:	60e2                	ld	ra,24(sp)
    80001dfe:	6442                	ld	s0,16(sp)
    80001e00:	64a2                	ld	s1,8(sp)
    80001e02:	6105                	addi	sp,sp,32
    80001e04:	8082                	ret
    panic("freeproc: free kstack");
    80001e06:	00006517          	auipc	a0,0x6
    80001e0a:	48a50513          	addi	a0,a0,1162 # 80008290 <states.1778+0x40>
    80001e0e:	ffffe097          	auipc	ra,0xffffe
    80001e12:	766080e7          	jalr	1894(ra) # 80000574 <panic>

0000000080001e16 <allocproc>:
{
    80001e16:	1101                	addi	sp,sp,-32
    80001e18:	ec06                	sd	ra,24(sp)
    80001e1a:	e822                	sd	s0,16(sp)
    80001e1c:	e426                	sd	s1,8(sp)
    80001e1e:	e04a                	sd	s2,0(sp)
    80001e20:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e22:	00010497          	auipc	s1,0x10
    80001e26:	f4648493          	addi	s1,s1,-186 # 80011d68 <proc>
    80001e2a:	00016917          	auipc	s2,0x16
    80001e2e:	b3e90913          	addi	s2,s2,-1218 # 80017968 <tickslock>
    acquire(&p->lock);
    80001e32:	8526                	mv	a0,s1
    80001e34:	fffff097          	auipc	ra,0xfffff
    80001e38:	e2e080e7          	jalr	-466(ra) # 80000c62 <acquire>
    if(p->state == UNUSED) {
    80001e3c:	4c9c                	lw	a5,24(s1)
    80001e3e:	cf81                	beqz	a5,80001e56 <allocproc+0x40>
      release(&p->lock);
    80001e40:	8526                	mv	a0,s1
    80001e42:	fffff097          	auipc	ra,0xfffff
    80001e46:	ed4080e7          	jalr	-300(ra) # 80000d16 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e4a:	17048493          	addi	s1,s1,368
    80001e4e:	ff2492e3          	bne	s1,s2,80001e32 <allocproc+0x1c>
  return 0;
    80001e52:	4481                	li	s1,0
    80001e54:	a075                	j	80001f00 <allocproc+0xea>
  p->pid = allocpid();
    80001e56:	00000097          	auipc	ra,0x0
    80001e5a:	cc4080e7          	jalr	-828(ra) # 80001b1a <allocpid>
    80001e5e:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001e60:	fffff097          	auipc	ra,0xfffff
    80001e64:	d12080e7          	jalr	-750(ra) # 80000b72 <kalloc>
    80001e68:	892a                	mv	s2,a0
    80001e6a:	f0a8                	sd	a0,96(s1)
    80001e6c:	c14d                	beqz	a0,80001f0e <allocproc+0xf8>
  p->pagetable = proc_pagetable(p);
    80001e6e:	8526                	mv	a0,s1
    80001e70:	00000097          	auipc	ra,0x0
    80001e74:	cf0080e7          	jalr	-784(ra) # 80001b60 <proc_pagetable>
    80001e78:	892a                	mv	s2,a0
    80001e7a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001e7c:	c145                	beqz	a0,80001f1c <allocproc+0x106>
  p->kpagetable = proc_kpagetable(p);
    80001e7e:	8526                	mv	a0,s1
    80001e80:	00000097          	auipc	ra,0x0
    80001e84:	d7c080e7          	jalr	-644(ra) # 80001bfc <proc_kpagetable>
    80001e88:	892a                	mv	s2,a0
    80001e8a:	eca8                	sd	a0,88(s1)
  if(p->kpagetable == 0){
    80001e8c:	c545                	beqz	a0,80001f34 <allocproc+0x11e>
  char *pa = kalloc();
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	ce4080e7          	jalr	-796(ra) # 80000b72 <kalloc>
    80001e96:	862a                	mv	a2,a0
  if(pa == 0)
    80001e98:	c955                	beqz	a0,80001f4c <allocproc+0x136>
  uint64 va = KSTACK((int) (p - proc));
    80001e9a:	00010797          	auipc	a5,0x10
    80001e9e:	ece78793          	addi	a5,a5,-306 # 80011d68 <proc>
    80001ea2:	40f487b3          	sub	a5,s1,a5
    80001ea6:	8791                	srai	a5,a5,0x4
    80001ea8:	00006717          	auipc	a4,0x6
    80001eac:	15870713          	addi	a4,a4,344 # 80008000 <etext>
    80001eb0:	6318                	ld	a4,0(a4)
    80001eb2:	02e787b3          	mul	a5,a5,a4
    80001eb6:	2785                	addiw	a5,a5,1
    80001eb8:	00d7979b          	slliw	a5,a5,0xd
    80001ebc:	04000937          	lui	s2,0x4000
    80001ec0:	197d                	addi	s2,s2,-1
    80001ec2:	0932                	slli	s2,s2,0xc
    80001ec4:	40f90933          	sub	s2,s2,a5
  ukvmmap(p->kpagetable, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001ec8:	4719                	li	a4,6
    80001eca:	6685                	lui	a3,0x1
    80001ecc:	85ca                	mv	a1,s2
    80001ece:	6ca8                	ld	a0,88(s1)
    80001ed0:	00000097          	auipc	ra,0x0
    80001ed4:	a20080e7          	jalr	-1504(ra) # 800018f0 <ukvmmap>
  p->kstack = va;
    80001ed8:	0524b023          	sd	s2,64(s1)
  memset(&p->context, 0, sizeof(p->context));
    80001edc:	07000613          	li	a2,112
    80001ee0:	4581                	li	a1,0
    80001ee2:	06848513          	addi	a0,s1,104
    80001ee6:	fffff097          	auipc	ra,0xfffff
    80001eea:	e78080e7          	jalr	-392(ra) # 80000d5e <memset>
  p->context.ra = (uint64)forkret;
    80001eee:	00000797          	auipc	a5,0x0
    80001ef2:	be478793          	addi	a5,a5,-1052 # 80001ad2 <forkret>
    80001ef6:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ef8:	60bc                	ld	a5,64(s1)
    80001efa:	6705                	lui	a4,0x1
    80001efc:	97ba                	add	a5,a5,a4
    80001efe:	f8bc                	sd	a5,112(s1)
}
    80001f00:	8526                	mv	a0,s1
    80001f02:	60e2                	ld	ra,24(sp)
    80001f04:	6442                	ld	s0,16(sp)
    80001f06:	64a2                	ld	s1,8(sp)
    80001f08:	6902                	ld	s2,0(sp)
    80001f0a:	6105                	addi	sp,sp,32
    80001f0c:	8082                	ret
    release(&p->lock);
    80001f0e:	8526                	mv	a0,s1
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	e06080e7          	jalr	-506(ra) # 80000d16 <release>
    return 0;
    80001f18:	84ca                	mv	s1,s2
    80001f1a:	b7dd                	j	80001f00 <allocproc+0xea>
    freeproc(p);
    80001f1c:	8526                	mv	a0,s1
    80001f1e:	00000097          	auipc	ra,0x0
    80001f22:	e62080e7          	jalr	-414(ra) # 80001d80 <freeproc>
    release(&p->lock);
    80001f26:	8526                	mv	a0,s1
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	dee080e7          	jalr	-530(ra) # 80000d16 <release>
    return 0;
    80001f30:	84ca                	mv	s1,s2
    80001f32:	b7f9                	j	80001f00 <allocproc+0xea>
    freeproc(p);
    80001f34:	8526                	mv	a0,s1
    80001f36:	00000097          	auipc	ra,0x0
    80001f3a:	e4a080e7          	jalr	-438(ra) # 80001d80 <freeproc>
    release(&p->lock);
    80001f3e:	8526                	mv	a0,s1
    80001f40:	fffff097          	auipc	ra,0xfffff
    80001f44:	dd6080e7          	jalr	-554(ra) # 80000d16 <release>
    return 0;
    80001f48:	84ca                	mv	s1,s2
    80001f4a:	bf5d                	j	80001f00 <allocproc+0xea>
    panic("kalloc");
    80001f4c:	00006517          	auipc	a0,0x6
    80001f50:	35c50513          	addi	a0,a0,860 # 800082a8 <states.1778+0x58>
    80001f54:	ffffe097          	auipc	ra,0xffffe
    80001f58:	620080e7          	jalr	1568(ra) # 80000574 <panic>

0000000080001f5c <userinit>:
{
    80001f5c:	1101                	addi	sp,sp,-32
    80001f5e:	ec06                	sd	ra,24(sp)
    80001f60:	e822                	sd	s0,16(sp)
    80001f62:	e426                	sd	s1,8(sp)
    80001f64:	e04a                	sd	s2,0(sp)
    80001f66:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f68:	00000097          	auipc	ra,0x0
    80001f6c:	eae080e7          	jalr	-338(ra) # 80001e16 <allocproc>
    80001f70:	84aa                	mv	s1,a0
  initproc = p;
    80001f72:	00007797          	auipc	a5,0x7
    80001f76:	0aa7b323          	sd	a0,166(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001f7a:	03400613          	li	a2,52
    80001f7e:	00007597          	auipc	a1,0x7
    80001f82:	98258593          	addi	a1,a1,-1662 # 80008900 <initcode>
    80001f86:	6928                	ld	a0,80(a0)
    80001f88:	fffff097          	auipc	ra,0xfffff
    80001f8c:	4ca080e7          	jalr	1226(ra) # 80001452 <uvminit>
  p->sz = PGSIZE;
    80001f90:	6905                	lui	s2,0x1
    80001f92:	0524b423          	sd	s2,72(s1)
  ukvmcopy(p->pagetable, p->kpagetable, 0, p->sz);
    80001f96:	6685                	lui	a3,0x1
    80001f98:	4601                	li	a2,0
    80001f9a:	6cac                	ld	a1,88(s1)
    80001f9c:	68a8                	ld	a0,80(s1)
    80001f9e:	00000097          	auipc	ra,0x0
    80001fa2:	982080e7          	jalr	-1662(ra) # 80001920 <ukvmcopy>
  p->trapframe->epc = 0;      // user program counter
    80001fa6:	70bc                	ld	a5,96(s1)
    80001fa8:	0007bc23          	sd	zero,24(a5)
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001fac:	70bc                	ld	a5,96(s1)
    80001fae:	0327b823          	sd	s2,48(a5)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001fb2:	4641                	li	a2,16
    80001fb4:	00006597          	auipc	a1,0x6
    80001fb8:	2fc58593          	addi	a1,a1,764 # 800082b0 <states.1778+0x60>
    80001fbc:	16048513          	addi	a0,s1,352
    80001fc0:	fffff097          	auipc	ra,0xfffff
    80001fc4:	f16080e7          	jalr	-234(ra) # 80000ed6 <safestrcpy>
  p->cwd = namei("/");
    80001fc8:	00006517          	auipc	a0,0x6
    80001fcc:	2f850513          	addi	a0,a0,760 # 800082c0 <states.1778+0x70>
    80001fd0:	00002097          	auipc	ra,0x2
    80001fd4:	1c4080e7          	jalr	452(ra) # 80004194 <namei>
    80001fd8:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001fdc:	4789                	li	a5,2
    80001fde:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001fe0:	8526                	mv	a0,s1
    80001fe2:	fffff097          	auipc	ra,0xfffff
    80001fe6:	d34080e7          	jalr	-716(ra) # 80000d16 <release>
}
    80001fea:	60e2                	ld	ra,24(sp)
    80001fec:	6442                	ld	s0,16(sp)
    80001fee:	64a2                	ld	s1,8(sp)
    80001ff0:	6902                	ld	s2,0(sp)
    80001ff2:	6105                	addi	sp,sp,32
    80001ff4:	8082                	ret

0000000080001ff6 <growproc>:
{
    80001ff6:	7179                	addi	sp,sp,-48
    80001ff8:	f406                	sd	ra,40(sp)
    80001ffa:	f022                	sd	s0,32(sp)
    80001ffc:	ec26                	sd	s1,24(sp)
    80001ffe:	e84a                	sd	s2,16(sp)
    80002000:	e44e                	sd	s3,8(sp)
    80002002:	e052                	sd	s4,0(sp)
    80002004:	1800                	addi	s0,sp,48
    80002006:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002008:	00000097          	auipc	ra,0x0
    8000200c:	a92080e7          	jalr	-1390(ra) # 80001a9a <myproc>
    80002010:	89aa                	mv	s3,a0
  sz = p->sz;
    80002012:	652c                	ld	a1,72(a0)
    80002014:	0005849b          	sext.w	s1,a1
  if(n > 0){
    80002018:	07205963          	blez	s2,8000208a <growproc+0x94>
    if (PGROUNDUP(sz + n) >= PLIC)
    8000201c:	2901                	sext.w	s2,s2
    8000201e:	009904bb          	addw	s1,s2,s1
    80002022:	6785                	lui	a5,0x1
    80002024:	37fd                	addiw	a5,a5,-1
    80002026:	9fa5                	addw	a5,a5,s1
    80002028:	777d                	lui	a4,0xfffff
    8000202a:	8ff9                	and	a5,a5,a4
    8000202c:	2781                	sext.w	a5,a5
    8000202e:	0c000737          	lui	a4,0xc000
    80002032:	08e7ff63          	bleu	a4,a5,800020d0 <growproc+0xda>
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80002036:	02049613          	slli	a2,s1,0x20
    8000203a:	9201                	srli	a2,a2,0x20
    8000203c:	1582                	slli	a1,a1,0x20
    8000203e:	9181                	srli	a1,a1,0x20
    80002040:	6928                	ld	a0,80(a0)
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	4c8080e7          	jalr	1224(ra) # 8000150a <uvmalloc>
    8000204a:	0005049b          	sext.w	s1,a0
    8000204e:	c0d9                	beqz	s1,800020d4 <growproc+0xde>
    ukvmcopy(p->pagetable, p->kpagetable, sz - n, sz);
    80002050:	4124893b          	subw	s2,s1,s2
    80002054:	02051693          	slli	a3,a0,0x20
    80002058:	9281                	srli	a3,a3,0x20
    8000205a:	02091613          	slli	a2,s2,0x20
    8000205e:	9201                	srli	a2,a2,0x20
    80002060:	0589b583          	ld	a1,88(s3)
    80002064:	0509b503          	ld	a0,80(s3)
    80002068:	00000097          	auipc	ra,0x0
    8000206c:	8b8080e7          	jalr	-1864(ra) # 80001920 <ukvmcopy>
  p->sz = sz;
    80002070:	1482                	slli	s1,s1,0x20
    80002072:	9081                	srli	s1,s1,0x20
    80002074:	0499b423          	sd	s1,72(s3)
  return 0;
    80002078:	4501                	li	a0,0
}
    8000207a:	70a2                	ld	ra,40(sp)
    8000207c:	7402                	ld	s0,32(sp)
    8000207e:	64e2                	ld	s1,24(sp)
    80002080:	6942                	ld	s2,16(sp)
    80002082:	69a2                	ld	s3,8(sp)
    80002084:	6a02                	ld	s4,0(sp)
    80002086:	6145                	addi	sp,sp,48
    80002088:	8082                	ret
  } else if(n < 0){
    8000208a:	fe0953e3          	bgez	s2,80002070 <growproc+0x7a>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000208e:	2901                	sext.w	s2,s2
    80002090:	0099063b          	addw	a2,s2,s1
    80002094:	5a7d                	li	s4,-1
    80002096:	020a5a13          	srli	s4,s4,0x20
    8000209a:	1602                	slli	a2,a2,0x20
    8000209c:	9201                	srli	a2,a2,0x20
    8000209e:	0145f5b3          	and	a1,a1,s4
    800020a2:	6928                	ld	a0,80(a0)
    800020a4:	fffff097          	auipc	ra,0xfffff
    800020a8:	420080e7          	jalr	1056(ra) # 800014c4 <uvmdealloc>
    800020ac:	0005049b          	sext.w	s1,a0
    ukvmcopy(p->pagetable, p->kpagetable, sz, sz - n);
    800020b0:	4124893b          	subw	s2,s1,s2
    800020b4:	02091693          	slli	a3,s2,0x20
    800020b8:	9281                	srli	a3,a3,0x20
    800020ba:	01457633          	and	a2,a0,s4
    800020be:	0589b583          	ld	a1,88(s3)
    800020c2:	0509b503          	ld	a0,80(s3)
    800020c6:	00000097          	auipc	ra,0x0
    800020ca:	85a080e7          	jalr	-1958(ra) # 80001920 <ukvmcopy>
    800020ce:	b74d                	j	80002070 <growproc+0x7a>
      return -1;
    800020d0:	557d                	li	a0,-1
    800020d2:	b765                	j	8000207a <growproc+0x84>
      return -1;
    800020d4:	557d                	li	a0,-1
    800020d6:	b755                	j	8000207a <growproc+0x84>

00000000800020d8 <fork>:
{
    800020d8:	7179                	addi	sp,sp,-48
    800020da:	f406                	sd	ra,40(sp)
    800020dc:	f022                	sd	s0,32(sp)
    800020de:	ec26                	sd	s1,24(sp)
    800020e0:	e84a                	sd	s2,16(sp)
    800020e2:	e44e                	sd	s3,8(sp)
    800020e4:	e052                	sd	s4,0(sp)
    800020e6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020e8:	00000097          	auipc	ra,0x0
    800020ec:	9b2080e7          	jalr	-1614(ra) # 80001a9a <myproc>
    800020f0:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    800020f2:	00000097          	auipc	ra,0x0
    800020f6:	d24080e7          	jalr	-732(ra) # 80001e16 <allocproc>
    800020fa:	c97d                	beqz	a0,800021f0 <fork+0x118>
    800020fc:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800020fe:	04893603          	ld	a2,72(s2) # 1048 <_entry-0x7fffefb8>
    80002102:	692c                	ld	a1,80(a0)
    80002104:	05093503          	ld	a0,80(s2)
    80002108:	fffff097          	auipc	ra,0xfffff
    8000210c:	54e080e7          	jalr	1358(ra) # 80001656 <uvmcopy>
    80002110:	06054163          	bltz	a0,80002172 <fork+0x9a>
  np->sz = p->sz;
    80002114:	04893683          	ld	a3,72(s2)
    80002118:	04d9b423          	sd	a3,72(s3)
  ukvmcopy(np->pagetable, np->kpagetable, 0, np->sz);
    8000211c:	4601                	li	a2,0
    8000211e:	0589b583          	ld	a1,88(s3)
    80002122:	0509b503          	ld	a0,80(s3)
    80002126:	fffff097          	auipc	ra,0xfffff
    8000212a:	7fa080e7          	jalr	2042(ra) # 80001920 <ukvmcopy>
  np->parent = p;
    8000212e:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80002132:	06093683          	ld	a3,96(s2)
    80002136:	87b6                	mv	a5,a3
    80002138:	0609b703          	ld	a4,96(s3)
    8000213c:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80002140:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002144:	6788                	ld	a0,8(a5)
    80002146:	6b8c                	ld	a1,16(a5)
    80002148:	6f90                	ld	a2,24(a5)
    8000214a:	01073023          	sd	a6,0(a4) # c000000 <_entry-0x74000000>
    8000214e:	e708                	sd	a0,8(a4)
    80002150:	eb0c                	sd	a1,16(a4)
    80002152:	ef10                	sd	a2,24(a4)
    80002154:	02078793          	addi	a5,a5,32
    80002158:	02070713          	addi	a4,a4,32
    8000215c:	fed792e3          	bne	a5,a3,80002140 <fork+0x68>
  np->trapframe->a0 = 0;
    80002160:	0609b783          	ld	a5,96(s3)
    80002164:	0607b823          	sd	zero,112(a5)
    80002168:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    8000216c:	15800a13          	li	s4,344
    80002170:	a03d                	j	8000219e <fork+0xc6>
    freeproc(np);
    80002172:	854e                	mv	a0,s3
    80002174:	00000097          	auipc	ra,0x0
    80002178:	c0c080e7          	jalr	-1012(ra) # 80001d80 <freeproc>
    release(&np->lock);
    8000217c:	854e                	mv	a0,s3
    8000217e:	fffff097          	auipc	ra,0xfffff
    80002182:	b98080e7          	jalr	-1128(ra) # 80000d16 <release>
    return -1;
    80002186:	54fd                	li	s1,-1
    80002188:	a899                	j	800021de <fork+0x106>
      np->ofile[i] = filedup(p->ofile[i]);
    8000218a:	00002097          	auipc	ra,0x2
    8000218e:	6c8080e7          	jalr	1736(ra) # 80004852 <filedup>
    80002192:	009987b3          	add	a5,s3,s1
    80002196:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80002198:	04a1                	addi	s1,s1,8
    8000219a:	01448763          	beq	s1,s4,800021a8 <fork+0xd0>
    if(p->ofile[i])
    8000219e:	009907b3          	add	a5,s2,s1
    800021a2:	6388                	ld	a0,0(a5)
    800021a4:	f17d                	bnez	a0,8000218a <fork+0xb2>
    800021a6:	bfcd                	j	80002198 <fork+0xc0>
  np->cwd = idup(p->cwd);
    800021a8:	15893503          	ld	a0,344(s2)
    800021ac:	00001097          	auipc	ra,0x1
    800021b0:	7f0080e7          	jalr	2032(ra) # 8000399c <idup>
    800021b4:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800021b8:	4641                	li	a2,16
    800021ba:	16090593          	addi	a1,s2,352
    800021be:	16098513          	addi	a0,s3,352
    800021c2:	fffff097          	auipc	ra,0xfffff
    800021c6:	d14080e7          	jalr	-748(ra) # 80000ed6 <safestrcpy>
  pid = np->pid;
    800021ca:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    800021ce:	4789                	li	a5,2
    800021d0:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800021d4:	854e                	mv	a0,s3
    800021d6:	fffff097          	auipc	ra,0xfffff
    800021da:	b40080e7          	jalr	-1216(ra) # 80000d16 <release>
}
    800021de:	8526                	mv	a0,s1
    800021e0:	70a2                	ld	ra,40(sp)
    800021e2:	7402                	ld	s0,32(sp)
    800021e4:	64e2                	ld	s1,24(sp)
    800021e6:	6942                	ld	s2,16(sp)
    800021e8:	69a2                	ld	s3,8(sp)
    800021ea:	6a02                	ld	s4,0(sp)
    800021ec:	6145                	addi	sp,sp,48
    800021ee:	8082                	ret
    return -1;
    800021f0:	54fd                	li	s1,-1
    800021f2:	b7f5                	j	800021de <fork+0x106>

00000000800021f4 <reparent>:
{
    800021f4:	7179                	addi	sp,sp,-48
    800021f6:	f406                	sd	ra,40(sp)
    800021f8:	f022                	sd	s0,32(sp)
    800021fa:	ec26                	sd	s1,24(sp)
    800021fc:	e84a                	sd	s2,16(sp)
    800021fe:	e44e                	sd	s3,8(sp)
    80002200:	e052                	sd	s4,0(sp)
    80002202:	1800                	addi	s0,sp,48
    80002204:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002206:	00010497          	auipc	s1,0x10
    8000220a:	b6248493          	addi	s1,s1,-1182 # 80011d68 <proc>
      pp->parent = initproc;
    8000220e:	00007a17          	auipc	s4,0x7
    80002212:	e0aa0a13          	addi	s4,s4,-502 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002216:	00015917          	auipc	s2,0x15
    8000221a:	75290913          	addi	s2,s2,1874 # 80017968 <tickslock>
    8000221e:	a029                	j	80002228 <reparent+0x34>
    80002220:	17048493          	addi	s1,s1,368
    80002224:	03248363          	beq	s1,s2,8000224a <reparent+0x56>
    if(pp->parent == p){
    80002228:	709c                	ld	a5,32(s1)
    8000222a:	ff379be3          	bne	a5,s3,80002220 <reparent+0x2c>
      acquire(&pp->lock);
    8000222e:	8526                	mv	a0,s1
    80002230:	fffff097          	auipc	ra,0xfffff
    80002234:	a32080e7          	jalr	-1486(ra) # 80000c62 <acquire>
      pp->parent = initproc;
    80002238:	000a3783          	ld	a5,0(s4)
    8000223c:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    8000223e:	8526                	mv	a0,s1
    80002240:	fffff097          	auipc	ra,0xfffff
    80002244:	ad6080e7          	jalr	-1322(ra) # 80000d16 <release>
    80002248:	bfe1                	j	80002220 <reparent+0x2c>
}
    8000224a:	70a2                	ld	ra,40(sp)
    8000224c:	7402                	ld	s0,32(sp)
    8000224e:	64e2                	ld	s1,24(sp)
    80002250:	6942                	ld	s2,16(sp)
    80002252:	69a2                	ld	s3,8(sp)
    80002254:	6a02                	ld	s4,0(sp)
    80002256:	6145                	addi	sp,sp,48
    80002258:	8082                	ret

000000008000225a <scheduler>:
{
    8000225a:	715d                	addi	sp,sp,-80
    8000225c:	e486                	sd	ra,72(sp)
    8000225e:	e0a2                	sd	s0,64(sp)
    80002260:	fc26                	sd	s1,56(sp)
    80002262:	f84a                	sd	s2,48(sp)
    80002264:	f44e                	sd	s3,40(sp)
    80002266:	f052                	sd	s4,32(sp)
    80002268:	ec56                	sd	s5,24(sp)
    8000226a:	e85a                	sd	s6,16(sp)
    8000226c:	e45e                	sd	s7,8(sp)
    8000226e:	e062                	sd	s8,0(sp)
    80002270:	0880                	addi	s0,sp,80
    80002272:	8792                	mv	a5,tp
  int id = r_tp();
    80002274:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002276:	00779b93          	slli	s7,a5,0x7
    8000227a:	0000f717          	auipc	a4,0xf
    8000227e:	6d670713          	addi	a4,a4,1750 # 80011950 <pid_lock>
    80002282:	975e                	add	a4,a4,s7
    80002284:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80002288:	0000f717          	auipc	a4,0xf
    8000228c:	6e870713          	addi	a4,a4,1768 # 80011970 <cpus+0x8>
    80002290:	9bba                	add	s7,s7,a4
        c->proc = p;
    80002292:	079e                	slli	a5,a5,0x7
    80002294:	0000fa17          	auipc	s4,0xf
    80002298:	6bca0a13          	addi	s4,s4,1724 # 80011950 <pid_lock>
    8000229c:	9a3e                	add	s4,s4,a5
        w_satp(MAKE_SATP(p->kpagetable));
    8000229e:	5b7d                	li	s6,-1
    800022a0:	1b7e                	slli	s6,s6,0x3f
    for(p = proc; p < &proc[NPROC]; p++) {
    800022a2:	00015997          	auipc	s3,0x15
    800022a6:	6c698993          	addi	s3,s3,1734 # 80017968 <tickslock>
    800022aa:	a8bd                	j	80002328 <scheduler+0xce>
        p->state = RUNNING;
    800022ac:	0154ac23          	sw	s5,24(s1)
        c->proc = p;
    800022b0:	009a3c23          	sd	s1,24(s4)
        w_satp(MAKE_SATP(p->kpagetable));
    800022b4:	6cbc                	ld	a5,88(s1)
    800022b6:	83b1                	srli	a5,a5,0xc
    800022b8:	0167e7b3          	or	a5,a5,s6
  asm volatile("csrw satp, %0" : : "r" (x));
    800022bc:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800022c0:	12000073          	sfence.vma
        swtch(&c->context, &p->context);
    800022c4:	06848593          	addi	a1,s1,104
    800022c8:	855e                	mv	a0,s7
    800022ca:	00000097          	auipc	ra,0x0
    800022ce:	658080e7          	jalr	1624(ra) # 80002922 <swtch>
        c->proc = 0;
    800022d2:	000a3c23          	sd	zero,24(s4)
        found = 1;
    800022d6:	4c05                	li	s8,1
      release(&p->lock);
    800022d8:	8526                	mv	a0,s1
    800022da:	fffff097          	auipc	ra,0xfffff
    800022de:	a3c080e7          	jalr	-1476(ra) # 80000d16 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800022e2:	17048493          	addi	s1,s1,368
    800022e6:	01348b63          	beq	s1,s3,800022fc <scheduler+0xa2>
      acquire(&p->lock);
    800022ea:	8526                	mv	a0,s1
    800022ec:	fffff097          	auipc	ra,0xfffff
    800022f0:	976080e7          	jalr	-1674(ra) # 80000c62 <acquire>
      if(p->state == RUNNABLE) {
    800022f4:	4c9c                	lw	a5,24(s1)
    800022f6:	ff2791e3          	bne	a5,s2,800022d8 <scheduler+0x7e>
    800022fa:	bf4d                	j	800022ac <scheduler+0x52>
    if(found == 0) {
    800022fc:	020c1663          	bnez	s8,80002328 <scheduler+0xce>
      w_satp(MAKE_SATP(kernel_pagetable));
    80002300:	00007797          	auipc	a5,0x7
    80002304:	d1078793          	addi	a5,a5,-752 # 80009010 <kernel_pagetable>
    80002308:	639c                	ld	a5,0(a5)
    8000230a:	83b1                	srli	a5,a5,0xc
    8000230c:	0167e7b3          	or	a5,a5,s6
  asm volatile("csrw satp, %0" : : "r" (x));
    80002310:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80002314:	12000073          	sfence.vma
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002318:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000231c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002320:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80002324:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002328:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000232c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002330:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002334:	4c01                	li	s8,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002336:	00010497          	auipc	s1,0x10
    8000233a:	a3248493          	addi	s1,s1,-1486 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    8000233e:	4909                	li	s2,2
        p->state = RUNNING;
    80002340:	4a8d                	li	s5,3
    80002342:	b765                	j	800022ea <scheduler+0x90>

0000000080002344 <sched>:
{
    80002344:	7179                	addi	sp,sp,-48
    80002346:	f406                	sd	ra,40(sp)
    80002348:	f022                	sd	s0,32(sp)
    8000234a:	ec26                	sd	s1,24(sp)
    8000234c:	e84a                	sd	s2,16(sp)
    8000234e:	e44e                	sd	s3,8(sp)
    80002350:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	748080e7          	jalr	1864(ra) # 80001a9a <myproc>
    8000235a:	892a                	mv	s2,a0
  if(!holding(&p->lock))
    8000235c:	fffff097          	auipc	ra,0xfffff
    80002360:	88c080e7          	jalr	-1908(ra) # 80000be8 <holding>
    80002364:	cd25                	beqz	a0,800023dc <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002366:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002368:	2781                	sext.w	a5,a5
    8000236a:	079e                	slli	a5,a5,0x7
    8000236c:	0000f717          	auipc	a4,0xf
    80002370:	5e470713          	addi	a4,a4,1508 # 80011950 <pid_lock>
    80002374:	97ba                	add	a5,a5,a4
    80002376:	0907a703          	lw	a4,144(a5)
    8000237a:	4785                	li	a5,1
    8000237c:	06f71863          	bne	a4,a5,800023ec <sched+0xa8>
  if(p->state == RUNNING)
    80002380:	01892703          	lw	a4,24(s2)
    80002384:	478d                	li	a5,3
    80002386:	06f70b63          	beq	a4,a5,800023fc <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000238a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000238e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002390:	efb5                	bnez	a5,8000240c <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002392:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002394:	0000f497          	auipc	s1,0xf
    80002398:	5bc48493          	addi	s1,s1,1468 # 80011950 <pid_lock>
    8000239c:	2781                	sext.w	a5,a5
    8000239e:	079e                	slli	a5,a5,0x7
    800023a0:	97a6                	add	a5,a5,s1
    800023a2:	0947a983          	lw	s3,148(a5)
    800023a6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800023a8:	2781                	sext.w	a5,a5
    800023aa:	079e                	slli	a5,a5,0x7
    800023ac:	0000f597          	auipc	a1,0xf
    800023b0:	5c458593          	addi	a1,a1,1476 # 80011970 <cpus+0x8>
    800023b4:	95be                	add	a1,a1,a5
    800023b6:	06890513          	addi	a0,s2,104
    800023ba:	00000097          	auipc	ra,0x0
    800023be:	568080e7          	jalr	1384(ra) # 80002922 <swtch>
    800023c2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800023c4:	2781                	sext.w	a5,a5
    800023c6:	079e                	slli	a5,a5,0x7
    800023c8:	97a6                	add	a5,a5,s1
    800023ca:	0937aa23          	sw	s3,148(a5)
}
    800023ce:	70a2                	ld	ra,40(sp)
    800023d0:	7402                	ld	s0,32(sp)
    800023d2:	64e2                	ld	s1,24(sp)
    800023d4:	6942                	ld	s2,16(sp)
    800023d6:	69a2                	ld	s3,8(sp)
    800023d8:	6145                	addi	sp,sp,48
    800023da:	8082                	ret
    panic("sched p->lock");
    800023dc:	00006517          	auipc	a0,0x6
    800023e0:	eec50513          	addi	a0,a0,-276 # 800082c8 <states.1778+0x78>
    800023e4:	ffffe097          	auipc	ra,0xffffe
    800023e8:	190080e7          	jalr	400(ra) # 80000574 <panic>
    panic("sched locks");
    800023ec:	00006517          	auipc	a0,0x6
    800023f0:	eec50513          	addi	a0,a0,-276 # 800082d8 <states.1778+0x88>
    800023f4:	ffffe097          	auipc	ra,0xffffe
    800023f8:	180080e7          	jalr	384(ra) # 80000574 <panic>
    panic("sched running");
    800023fc:	00006517          	auipc	a0,0x6
    80002400:	eec50513          	addi	a0,a0,-276 # 800082e8 <states.1778+0x98>
    80002404:	ffffe097          	auipc	ra,0xffffe
    80002408:	170080e7          	jalr	368(ra) # 80000574 <panic>
    panic("sched interruptible");
    8000240c:	00006517          	auipc	a0,0x6
    80002410:	eec50513          	addi	a0,a0,-276 # 800082f8 <states.1778+0xa8>
    80002414:	ffffe097          	auipc	ra,0xffffe
    80002418:	160080e7          	jalr	352(ra) # 80000574 <panic>

000000008000241c <exit>:
{
    8000241c:	7179                	addi	sp,sp,-48
    8000241e:	f406                	sd	ra,40(sp)
    80002420:	f022                	sd	s0,32(sp)
    80002422:	ec26                	sd	s1,24(sp)
    80002424:	e84a                	sd	s2,16(sp)
    80002426:	e44e                	sd	s3,8(sp)
    80002428:	e052                	sd	s4,0(sp)
    8000242a:	1800                	addi	s0,sp,48
    8000242c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000242e:	fffff097          	auipc	ra,0xfffff
    80002432:	66c080e7          	jalr	1644(ra) # 80001a9a <myproc>
    80002436:	89aa                	mv	s3,a0
  if(p == initproc)
    80002438:	00007797          	auipc	a5,0x7
    8000243c:	be078793          	addi	a5,a5,-1056 # 80009018 <initproc>
    80002440:	639c                	ld	a5,0(a5)
    80002442:	0d850493          	addi	s1,a0,216
    80002446:	15850913          	addi	s2,a0,344
    8000244a:	02a79363          	bne	a5,a0,80002470 <exit+0x54>
    panic("init exiting");
    8000244e:	00006517          	auipc	a0,0x6
    80002452:	ec250513          	addi	a0,a0,-318 # 80008310 <states.1778+0xc0>
    80002456:	ffffe097          	auipc	ra,0xffffe
    8000245a:	11e080e7          	jalr	286(ra) # 80000574 <panic>
      fileclose(f);
    8000245e:	00002097          	auipc	ra,0x2
    80002462:	446080e7          	jalr	1094(ra) # 800048a4 <fileclose>
      p->ofile[fd] = 0;
    80002466:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000246a:	04a1                	addi	s1,s1,8
    8000246c:	01248563          	beq	s1,s2,80002476 <exit+0x5a>
    if(p->ofile[fd]){
    80002470:	6088                	ld	a0,0(s1)
    80002472:	f575                	bnez	a0,8000245e <exit+0x42>
    80002474:	bfdd                	j	8000246a <exit+0x4e>
  begin_op();
    80002476:	00002097          	auipc	ra,0x2
    8000247a:	f2c080e7          	jalr	-212(ra) # 800043a2 <begin_op>
  iput(p->cwd);
    8000247e:	1589b503          	ld	a0,344(s3)
    80002482:	00001097          	auipc	ra,0x1
    80002486:	714080e7          	jalr	1812(ra) # 80003b96 <iput>
  end_op();
    8000248a:	00002097          	auipc	ra,0x2
    8000248e:	f98080e7          	jalr	-104(ra) # 80004422 <end_op>
  p->cwd = 0;
    80002492:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    80002496:	00007497          	auipc	s1,0x7
    8000249a:	b8248493          	addi	s1,s1,-1150 # 80009018 <initproc>
    8000249e:	6088                	ld	a0,0(s1)
    800024a0:	ffffe097          	auipc	ra,0xffffe
    800024a4:	7c2080e7          	jalr	1986(ra) # 80000c62 <acquire>
  wakeup1(initproc);
    800024a8:	6088                	ld	a0,0(s1)
    800024aa:	fffff097          	auipc	ra,0xfffff
    800024ae:	518080e7          	jalr	1304(ra) # 800019c2 <wakeup1>
  release(&initproc->lock);
    800024b2:	6088                	ld	a0,0(s1)
    800024b4:	fffff097          	auipc	ra,0xfffff
    800024b8:	862080e7          	jalr	-1950(ra) # 80000d16 <release>
  acquire(&p->lock);
    800024bc:	854e                	mv	a0,s3
    800024be:	ffffe097          	auipc	ra,0xffffe
    800024c2:	7a4080e7          	jalr	1956(ra) # 80000c62 <acquire>
  struct proc *original_parent = p->parent;
    800024c6:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    800024ca:	854e                	mv	a0,s3
    800024cc:	fffff097          	auipc	ra,0xfffff
    800024d0:	84a080e7          	jalr	-1974(ra) # 80000d16 <release>
  acquire(&original_parent->lock);
    800024d4:	8526                	mv	a0,s1
    800024d6:	ffffe097          	auipc	ra,0xffffe
    800024da:	78c080e7          	jalr	1932(ra) # 80000c62 <acquire>
  acquire(&p->lock);
    800024de:	854e                	mv	a0,s3
    800024e0:	ffffe097          	auipc	ra,0xffffe
    800024e4:	782080e7          	jalr	1922(ra) # 80000c62 <acquire>
  reparent(p);
    800024e8:	854e                	mv	a0,s3
    800024ea:	00000097          	auipc	ra,0x0
    800024ee:	d0a080e7          	jalr	-758(ra) # 800021f4 <reparent>
  wakeup1(original_parent);
    800024f2:	8526                	mv	a0,s1
    800024f4:	fffff097          	auipc	ra,0xfffff
    800024f8:	4ce080e7          	jalr	1230(ra) # 800019c2 <wakeup1>
  p->xstate = status;
    800024fc:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80002500:	4791                	li	a5,4
    80002502:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    80002506:	8526                	mv	a0,s1
    80002508:	fffff097          	auipc	ra,0xfffff
    8000250c:	80e080e7          	jalr	-2034(ra) # 80000d16 <release>
  sched();
    80002510:	00000097          	auipc	ra,0x0
    80002514:	e34080e7          	jalr	-460(ra) # 80002344 <sched>
  panic("zombie exit");
    80002518:	00006517          	auipc	a0,0x6
    8000251c:	e0850513          	addi	a0,a0,-504 # 80008320 <states.1778+0xd0>
    80002520:	ffffe097          	auipc	ra,0xffffe
    80002524:	054080e7          	jalr	84(ra) # 80000574 <panic>

0000000080002528 <yield>:
{
    80002528:	1101                	addi	sp,sp,-32
    8000252a:	ec06                	sd	ra,24(sp)
    8000252c:	e822                	sd	s0,16(sp)
    8000252e:	e426                	sd	s1,8(sp)
    80002530:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002532:	fffff097          	auipc	ra,0xfffff
    80002536:	568080e7          	jalr	1384(ra) # 80001a9a <myproc>
    8000253a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000253c:	ffffe097          	auipc	ra,0xffffe
    80002540:	726080e7          	jalr	1830(ra) # 80000c62 <acquire>
  p->state = RUNNABLE;
    80002544:	4789                	li	a5,2
    80002546:	cc9c                	sw	a5,24(s1)
  sched();
    80002548:	00000097          	auipc	ra,0x0
    8000254c:	dfc080e7          	jalr	-516(ra) # 80002344 <sched>
  release(&p->lock);
    80002550:	8526                	mv	a0,s1
    80002552:	ffffe097          	auipc	ra,0xffffe
    80002556:	7c4080e7          	jalr	1988(ra) # 80000d16 <release>
}
    8000255a:	60e2                	ld	ra,24(sp)
    8000255c:	6442                	ld	s0,16(sp)
    8000255e:	64a2                	ld	s1,8(sp)
    80002560:	6105                	addi	sp,sp,32
    80002562:	8082                	ret

0000000080002564 <sleep>:
{
    80002564:	7179                	addi	sp,sp,-48
    80002566:	f406                	sd	ra,40(sp)
    80002568:	f022                	sd	s0,32(sp)
    8000256a:	ec26                	sd	s1,24(sp)
    8000256c:	e84a                	sd	s2,16(sp)
    8000256e:	e44e                	sd	s3,8(sp)
    80002570:	1800                	addi	s0,sp,48
    80002572:	89aa                	mv	s3,a0
    80002574:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002576:	fffff097          	auipc	ra,0xfffff
    8000257a:	524080e7          	jalr	1316(ra) # 80001a9a <myproc>
    8000257e:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002580:	05250663          	beq	a0,s2,800025cc <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002584:	ffffe097          	auipc	ra,0xffffe
    80002588:	6de080e7          	jalr	1758(ra) # 80000c62 <acquire>
    release(lk);
    8000258c:	854a                	mv	a0,s2
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	788080e7          	jalr	1928(ra) # 80000d16 <release>
  p->chan = chan;
    80002596:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    8000259a:	4785                	li	a5,1
    8000259c:	cc9c                	sw	a5,24(s1)
  sched();
    8000259e:	00000097          	auipc	ra,0x0
    800025a2:	da6080e7          	jalr	-602(ra) # 80002344 <sched>
  p->chan = 0;
    800025a6:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800025aa:	8526                	mv	a0,s1
    800025ac:	ffffe097          	auipc	ra,0xffffe
    800025b0:	76a080e7          	jalr	1898(ra) # 80000d16 <release>
    acquire(lk);
    800025b4:	854a                	mv	a0,s2
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	6ac080e7          	jalr	1708(ra) # 80000c62 <acquire>
}
    800025be:	70a2                	ld	ra,40(sp)
    800025c0:	7402                	ld	s0,32(sp)
    800025c2:	64e2                	ld	s1,24(sp)
    800025c4:	6942                	ld	s2,16(sp)
    800025c6:	69a2                	ld	s3,8(sp)
    800025c8:	6145                	addi	sp,sp,48
    800025ca:	8082                	ret
  p->chan = chan;
    800025cc:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800025d0:	4785                	li	a5,1
    800025d2:	cd1c                	sw	a5,24(a0)
  sched();
    800025d4:	00000097          	auipc	ra,0x0
    800025d8:	d70080e7          	jalr	-656(ra) # 80002344 <sched>
  p->chan = 0;
    800025dc:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800025e0:	bff9                	j	800025be <sleep+0x5a>

00000000800025e2 <wait>:
{
    800025e2:	715d                	addi	sp,sp,-80
    800025e4:	e486                	sd	ra,72(sp)
    800025e6:	e0a2                	sd	s0,64(sp)
    800025e8:	fc26                	sd	s1,56(sp)
    800025ea:	f84a                	sd	s2,48(sp)
    800025ec:	f44e                	sd	s3,40(sp)
    800025ee:	f052                	sd	s4,32(sp)
    800025f0:	ec56                	sd	s5,24(sp)
    800025f2:	e85a                	sd	s6,16(sp)
    800025f4:	e45e                	sd	s7,8(sp)
    800025f6:	e062                	sd	s8,0(sp)
    800025f8:	0880                	addi	s0,sp,80
    800025fa:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800025fc:	fffff097          	auipc	ra,0xfffff
    80002600:	49e080e7          	jalr	1182(ra) # 80001a9a <myproc>
    80002604:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002606:	8c2a                	mv	s8,a0
    80002608:	ffffe097          	auipc	ra,0xffffe
    8000260c:	65a080e7          	jalr	1626(ra) # 80000c62 <acquire>
    havekids = 0;
    80002610:	4b01                	li	s6,0
        if(np->state == ZOMBIE){
    80002612:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    80002614:	00015997          	auipc	s3,0x15
    80002618:	35498993          	addi	s3,s3,852 # 80017968 <tickslock>
        havekids = 1;
    8000261c:	4a85                	li	s5,1
    havekids = 0;
    8000261e:	875a                	mv	a4,s6
    for(np = proc; np < &proc[NPROC]; np++){
    80002620:	0000f497          	auipc	s1,0xf
    80002624:	74848493          	addi	s1,s1,1864 # 80011d68 <proc>
    80002628:	a08d                	j	8000268a <wait+0xa8>
          pid = np->pid;
    8000262a:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000262e:	000b8e63          	beqz	s7,8000264a <wait+0x68>
    80002632:	4691                	li	a3,4
    80002634:	03448613          	addi	a2,s1,52
    80002638:	85de                	mv	a1,s7
    8000263a:	05093503          	ld	a0,80(s2)
    8000263e:	fffff097          	auipc	ra,0xfffff
    80002642:	11c080e7          	jalr	284(ra) # 8000175a <copyout>
    80002646:	02054263          	bltz	a0,8000266a <wait+0x88>
          freeproc(np);
    8000264a:	8526                	mv	a0,s1
    8000264c:	fffff097          	auipc	ra,0xfffff
    80002650:	734080e7          	jalr	1844(ra) # 80001d80 <freeproc>
          release(&np->lock);
    80002654:	8526                	mv	a0,s1
    80002656:	ffffe097          	auipc	ra,0xffffe
    8000265a:	6c0080e7          	jalr	1728(ra) # 80000d16 <release>
          release(&p->lock);
    8000265e:	854a                	mv	a0,s2
    80002660:	ffffe097          	auipc	ra,0xffffe
    80002664:	6b6080e7          	jalr	1718(ra) # 80000d16 <release>
          return pid;
    80002668:	a8a9                	j	800026c2 <wait+0xe0>
            release(&np->lock);
    8000266a:	8526                	mv	a0,s1
    8000266c:	ffffe097          	auipc	ra,0xffffe
    80002670:	6aa080e7          	jalr	1706(ra) # 80000d16 <release>
            release(&p->lock);
    80002674:	854a                	mv	a0,s2
    80002676:	ffffe097          	auipc	ra,0xffffe
    8000267a:	6a0080e7          	jalr	1696(ra) # 80000d16 <release>
            return -1;
    8000267e:	59fd                	li	s3,-1
    80002680:	a089                	j	800026c2 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002682:	17048493          	addi	s1,s1,368
    80002686:	03348463          	beq	s1,s3,800026ae <wait+0xcc>
      if(np->parent == p){
    8000268a:	709c                	ld	a5,32(s1)
    8000268c:	ff279be3          	bne	a5,s2,80002682 <wait+0xa0>
        acquire(&np->lock);
    80002690:	8526                	mv	a0,s1
    80002692:	ffffe097          	auipc	ra,0xffffe
    80002696:	5d0080e7          	jalr	1488(ra) # 80000c62 <acquire>
        if(np->state == ZOMBIE){
    8000269a:	4c9c                	lw	a5,24(s1)
    8000269c:	f94787e3          	beq	a5,s4,8000262a <wait+0x48>
        release(&np->lock);
    800026a0:	8526                	mv	a0,s1
    800026a2:	ffffe097          	auipc	ra,0xffffe
    800026a6:	674080e7          	jalr	1652(ra) # 80000d16 <release>
        havekids = 1;
    800026aa:	8756                	mv	a4,s5
    800026ac:	bfd9                	j	80002682 <wait+0xa0>
    if(!havekids || p->killed){
    800026ae:	c701                	beqz	a4,800026b6 <wait+0xd4>
    800026b0:	03092783          	lw	a5,48(s2)
    800026b4:	c785                	beqz	a5,800026dc <wait+0xfa>
      release(&p->lock);
    800026b6:	854a                	mv	a0,s2
    800026b8:	ffffe097          	auipc	ra,0xffffe
    800026bc:	65e080e7          	jalr	1630(ra) # 80000d16 <release>
      return -1;
    800026c0:	59fd                	li	s3,-1
}
    800026c2:	854e                	mv	a0,s3
    800026c4:	60a6                	ld	ra,72(sp)
    800026c6:	6406                	ld	s0,64(sp)
    800026c8:	74e2                	ld	s1,56(sp)
    800026ca:	7942                	ld	s2,48(sp)
    800026cc:	79a2                	ld	s3,40(sp)
    800026ce:	7a02                	ld	s4,32(sp)
    800026d0:	6ae2                	ld	s5,24(sp)
    800026d2:	6b42                	ld	s6,16(sp)
    800026d4:	6ba2                	ld	s7,8(sp)
    800026d6:	6c02                	ld	s8,0(sp)
    800026d8:	6161                	addi	sp,sp,80
    800026da:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800026dc:	85e2                	mv	a1,s8
    800026de:	854a                	mv	a0,s2
    800026e0:	00000097          	auipc	ra,0x0
    800026e4:	e84080e7          	jalr	-380(ra) # 80002564 <sleep>
    havekids = 0;
    800026e8:	bf1d                	j	8000261e <wait+0x3c>

00000000800026ea <wakeup>:
{
    800026ea:	7139                	addi	sp,sp,-64
    800026ec:	fc06                	sd	ra,56(sp)
    800026ee:	f822                	sd	s0,48(sp)
    800026f0:	f426                	sd	s1,40(sp)
    800026f2:	f04a                	sd	s2,32(sp)
    800026f4:	ec4e                	sd	s3,24(sp)
    800026f6:	e852                	sd	s4,16(sp)
    800026f8:	e456                	sd	s5,8(sp)
    800026fa:	0080                	addi	s0,sp,64
    800026fc:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800026fe:	0000f497          	auipc	s1,0xf
    80002702:	66a48493          	addi	s1,s1,1642 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002706:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002708:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    8000270a:	00015917          	auipc	s2,0x15
    8000270e:	25e90913          	addi	s2,s2,606 # 80017968 <tickslock>
    80002712:	a821                	j	8000272a <wakeup+0x40>
      p->state = RUNNABLE;
    80002714:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    80002718:	8526                	mv	a0,s1
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	5fc080e7          	jalr	1532(ra) # 80000d16 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002722:	17048493          	addi	s1,s1,368
    80002726:	01248e63          	beq	s1,s2,80002742 <wakeup+0x58>
    acquire(&p->lock);
    8000272a:	8526                	mv	a0,s1
    8000272c:	ffffe097          	auipc	ra,0xffffe
    80002730:	536080e7          	jalr	1334(ra) # 80000c62 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002734:	4c9c                	lw	a5,24(s1)
    80002736:	ff3791e3          	bne	a5,s3,80002718 <wakeup+0x2e>
    8000273a:	749c                	ld	a5,40(s1)
    8000273c:	fd479ee3          	bne	a5,s4,80002718 <wakeup+0x2e>
    80002740:	bfd1                	j	80002714 <wakeup+0x2a>
}
    80002742:	70e2                	ld	ra,56(sp)
    80002744:	7442                	ld	s0,48(sp)
    80002746:	74a2                	ld	s1,40(sp)
    80002748:	7902                	ld	s2,32(sp)
    8000274a:	69e2                	ld	s3,24(sp)
    8000274c:	6a42                	ld	s4,16(sp)
    8000274e:	6aa2                	ld	s5,8(sp)
    80002750:	6121                	addi	sp,sp,64
    80002752:	8082                	ret

0000000080002754 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002754:	7179                	addi	sp,sp,-48
    80002756:	f406                	sd	ra,40(sp)
    80002758:	f022                	sd	s0,32(sp)
    8000275a:	ec26                	sd	s1,24(sp)
    8000275c:	e84a                	sd	s2,16(sp)
    8000275e:	e44e                	sd	s3,8(sp)
    80002760:	1800                	addi	s0,sp,48
    80002762:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002764:	0000f497          	auipc	s1,0xf
    80002768:	60448493          	addi	s1,s1,1540 # 80011d68 <proc>
    8000276c:	00015997          	auipc	s3,0x15
    80002770:	1fc98993          	addi	s3,s3,508 # 80017968 <tickslock>
    acquire(&p->lock);
    80002774:	8526                	mv	a0,s1
    80002776:	ffffe097          	auipc	ra,0xffffe
    8000277a:	4ec080e7          	jalr	1260(ra) # 80000c62 <acquire>
    if(p->pid == pid){
    8000277e:	5c9c                	lw	a5,56(s1)
    80002780:	01278d63          	beq	a5,s2,8000279a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002784:	8526                	mv	a0,s1
    80002786:	ffffe097          	auipc	ra,0xffffe
    8000278a:	590080e7          	jalr	1424(ra) # 80000d16 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000278e:	17048493          	addi	s1,s1,368
    80002792:	ff3491e3          	bne	s1,s3,80002774 <kill+0x20>
  }
  return -1;
    80002796:	557d                	li	a0,-1
    80002798:	a829                	j	800027b2 <kill+0x5e>
      p->killed = 1;
    8000279a:	4785                	li	a5,1
    8000279c:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    8000279e:	4c98                	lw	a4,24(s1)
    800027a0:	4785                	li	a5,1
    800027a2:	00f70f63          	beq	a4,a5,800027c0 <kill+0x6c>
      release(&p->lock);
    800027a6:	8526                	mv	a0,s1
    800027a8:	ffffe097          	auipc	ra,0xffffe
    800027ac:	56e080e7          	jalr	1390(ra) # 80000d16 <release>
      return 0;
    800027b0:	4501                	li	a0,0
}
    800027b2:	70a2                	ld	ra,40(sp)
    800027b4:	7402                	ld	s0,32(sp)
    800027b6:	64e2                	ld	s1,24(sp)
    800027b8:	6942                	ld	s2,16(sp)
    800027ba:	69a2                	ld	s3,8(sp)
    800027bc:	6145                	addi	sp,sp,48
    800027be:	8082                	ret
        p->state = RUNNABLE;
    800027c0:	4789                	li	a5,2
    800027c2:	cc9c                	sw	a5,24(s1)
    800027c4:	b7cd                	j	800027a6 <kill+0x52>

00000000800027c6 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800027c6:	7179                	addi	sp,sp,-48
    800027c8:	f406                	sd	ra,40(sp)
    800027ca:	f022                	sd	s0,32(sp)
    800027cc:	ec26                	sd	s1,24(sp)
    800027ce:	e84a                	sd	s2,16(sp)
    800027d0:	e44e                	sd	s3,8(sp)
    800027d2:	e052                	sd	s4,0(sp)
    800027d4:	1800                	addi	s0,sp,48
    800027d6:	84aa                	mv	s1,a0
    800027d8:	892e                	mv	s2,a1
    800027da:	89b2                	mv	s3,a2
    800027dc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027de:	fffff097          	auipc	ra,0xfffff
    800027e2:	2bc080e7          	jalr	700(ra) # 80001a9a <myproc>
  if(user_dst){
    800027e6:	c08d                	beqz	s1,80002808 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800027e8:	86d2                	mv	a3,s4
    800027ea:	864e                	mv	a2,s3
    800027ec:	85ca                	mv	a1,s2
    800027ee:	6928                	ld	a0,80(a0)
    800027f0:	fffff097          	auipc	ra,0xfffff
    800027f4:	f6a080e7          	jalr	-150(ra) # 8000175a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800027f8:	70a2                	ld	ra,40(sp)
    800027fa:	7402                	ld	s0,32(sp)
    800027fc:	64e2                	ld	s1,24(sp)
    800027fe:	6942                	ld	s2,16(sp)
    80002800:	69a2                	ld	s3,8(sp)
    80002802:	6a02                	ld	s4,0(sp)
    80002804:	6145                	addi	sp,sp,48
    80002806:	8082                	ret
    memmove((char *)dst, src, len);
    80002808:	000a061b          	sext.w	a2,s4
    8000280c:	85ce                	mv	a1,s3
    8000280e:	854a                	mv	a0,s2
    80002810:	ffffe097          	auipc	ra,0xffffe
    80002814:	5ba080e7          	jalr	1466(ra) # 80000dca <memmove>
    return 0;
    80002818:	8526                	mv	a0,s1
    8000281a:	bff9                	j	800027f8 <either_copyout+0x32>

000000008000281c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000281c:	7179                	addi	sp,sp,-48
    8000281e:	f406                	sd	ra,40(sp)
    80002820:	f022                	sd	s0,32(sp)
    80002822:	ec26                	sd	s1,24(sp)
    80002824:	e84a                	sd	s2,16(sp)
    80002826:	e44e                	sd	s3,8(sp)
    80002828:	e052                	sd	s4,0(sp)
    8000282a:	1800                	addi	s0,sp,48
    8000282c:	892a                	mv	s2,a0
    8000282e:	84ae                	mv	s1,a1
    80002830:	89b2                	mv	s3,a2
    80002832:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002834:	fffff097          	auipc	ra,0xfffff
    80002838:	266080e7          	jalr	614(ra) # 80001a9a <myproc>
  if(user_src){
    8000283c:	c08d                	beqz	s1,8000285e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000283e:	86d2                	mv	a3,s4
    80002840:	864e                	mv	a2,s3
    80002842:	85ca                	mv	a1,s2
    80002844:	6928                	ld	a0,80(a0)
    80002846:	fffff097          	auipc	ra,0xfffff
    8000284a:	fa0080e7          	jalr	-96(ra) # 800017e6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000284e:	70a2                	ld	ra,40(sp)
    80002850:	7402                	ld	s0,32(sp)
    80002852:	64e2                	ld	s1,24(sp)
    80002854:	6942                	ld	s2,16(sp)
    80002856:	69a2                	ld	s3,8(sp)
    80002858:	6a02                	ld	s4,0(sp)
    8000285a:	6145                	addi	sp,sp,48
    8000285c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000285e:	000a061b          	sext.w	a2,s4
    80002862:	85ce                	mv	a1,s3
    80002864:	854a                	mv	a0,s2
    80002866:	ffffe097          	auipc	ra,0xffffe
    8000286a:	564080e7          	jalr	1380(ra) # 80000dca <memmove>
    return 0;
    8000286e:	8526                	mv	a0,s1
    80002870:	bff9                	j	8000284e <either_copyin+0x32>

0000000080002872 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002872:	715d                	addi	sp,sp,-80
    80002874:	e486                	sd	ra,72(sp)
    80002876:	e0a2                	sd	s0,64(sp)
    80002878:	fc26                	sd	s1,56(sp)
    8000287a:	f84a                	sd	s2,48(sp)
    8000287c:	f44e                	sd	s3,40(sp)
    8000287e:	f052                	sd	s4,32(sp)
    80002880:	ec56                	sd	s5,24(sp)
    80002882:	e85a                	sd	s6,16(sp)
    80002884:	e45e                	sd	s7,8(sp)
    80002886:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002888:	00006517          	auipc	a0,0x6
    8000288c:	84050513          	addi	a0,a0,-1984 # 800080c8 <digits+0xb0>
    80002890:	ffffe097          	auipc	ra,0xffffe
    80002894:	d2e080e7          	jalr	-722(ra) # 800005be <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002898:	0000f497          	auipc	s1,0xf
    8000289c:	63048493          	addi	s1,s1,1584 # 80011ec8 <proc+0x160>
    800028a0:	00015917          	auipc	s2,0x15
    800028a4:	22890913          	addi	s2,s2,552 # 80017ac8 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028a8:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800028aa:	00006997          	auipc	s3,0x6
    800028ae:	a8698993          	addi	s3,s3,-1402 # 80008330 <states.1778+0xe0>
    printf("%d %s %s", p->pid, state, p->name);
    800028b2:	00006a97          	auipc	s5,0x6
    800028b6:	a86a8a93          	addi	s5,s5,-1402 # 80008338 <states.1778+0xe8>
    printf("\n");
    800028ba:	00006a17          	auipc	s4,0x6
    800028be:	80ea0a13          	addi	s4,s4,-2034 # 800080c8 <digits+0xb0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028c2:	00006b97          	auipc	s7,0x6
    800028c6:	98eb8b93          	addi	s7,s7,-1650 # 80008250 <states.1778>
    800028ca:	a015                	j	800028ee <procdump+0x7c>
    printf("%d %s %s", p->pid, state, p->name);
    800028cc:	86ba                	mv	a3,a4
    800028ce:	ed872583          	lw	a1,-296(a4)
    800028d2:	8556                	mv	a0,s5
    800028d4:	ffffe097          	auipc	ra,0xffffe
    800028d8:	cea080e7          	jalr	-790(ra) # 800005be <printf>
    printf("\n");
    800028dc:	8552                	mv	a0,s4
    800028de:	ffffe097          	auipc	ra,0xffffe
    800028e2:	ce0080e7          	jalr	-800(ra) # 800005be <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028e6:	17048493          	addi	s1,s1,368
    800028ea:	03248163          	beq	s1,s2,8000290c <procdump+0x9a>
    if(p->state == UNUSED)
    800028ee:	8726                	mv	a4,s1
    800028f0:	eb84a783          	lw	a5,-328(s1)
    800028f4:	dbed                	beqz	a5,800028e6 <procdump+0x74>
      state = "???";
    800028f6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028f8:	fcfb6ae3          	bltu	s6,a5,800028cc <procdump+0x5a>
    800028fc:	1782                	slli	a5,a5,0x20
    800028fe:	9381                	srli	a5,a5,0x20
    80002900:	078e                	slli	a5,a5,0x3
    80002902:	97de                	add	a5,a5,s7
    80002904:	6390                	ld	a2,0(a5)
    80002906:	f279                	bnez	a2,800028cc <procdump+0x5a>
      state = "???";
    80002908:	864e                	mv	a2,s3
    8000290a:	b7c9                	j	800028cc <procdump+0x5a>
  }
}
    8000290c:	60a6                	ld	ra,72(sp)
    8000290e:	6406                	ld	s0,64(sp)
    80002910:	74e2                	ld	s1,56(sp)
    80002912:	7942                	ld	s2,48(sp)
    80002914:	79a2                	ld	s3,40(sp)
    80002916:	7a02                	ld	s4,32(sp)
    80002918:	6ae2                	ld	s5,24(sp)
    8000291a:	6b42                	ld	s6,16(sp)
    8000291c:	6ba2                	ld	s7,8(sp)
    8000291e:	6161                	addi	sp,sp,80
    80002920:	8082                	ret

0000000080002922 <swtch>:
    80002922:	00153023          	sd	ra,0(a0)
    80002926:	00253423          	sd	sp,8(a0)
    8000292a:	e900                	sd	s0,16(a0)
    8000292c:	ed04                	sd	s1,24(a0)
    8000292e:	03253023          	sd	s2,32(a0)
    80002932:	03353423          	sd	s3,40(a0)
    80002936:	03453823          	sd	s4,48(a0)
    8000293a:	03553c23          	sd	s5,56(a0)
    8000293e:	05653023          	sd	s6,64(a0)
    80002942:	05753423          	sd	s7,72(a0)
    80002946:	05853823          	sd	s8,80(a0)
    8000294a:	05953c23          	sd	s9,88(a0)
    8000294e:	07a53023          	sd	s10,96(a0)
    80002952:	07b53423          	sd	s11,104(a0)
    80002956:	0005b083          	ld	ra,0(a1)
    8000295a:	0085b103          	ld	sp,8(a1)
    8000295e:	6980                	ld	s0,16(a1)
    80002960:	6d84                	ld	s1,24(a1)
    80002962:	0205b903          	ld	s2,32(a1)
    80002966:	0285b983          	ld	s3,40(a1)
    8000296a:	0305ba03          	ld	s4,48(a1)
    8000296e:	0385ba83          	ld	s5,56(a1)
    80002972:	0405bb03          	ld	s6,64(a1)
    80002976:	0485bb83          	ld	s7,72(a1)
    8000297a:	0505bc03          	ld	s8,80(a1)
    8000297e:	0585bc83          	ld	s9,88(a1)
    80002982:	0605bd03          	ld	s10,96(a1)
    80002986:	0685bd83          	ld	s11,104(a1)
    8000298a:	8082                	ret

000000008000298c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000298c:	1141                	addi	sp,sp,-16
    8000298e:	e406                	sd	ra,8(sp)
    80002990:	e022                	sd	s0,0(sp)
    80002992:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002994:	00006597          	auipc	a1,0x6
    80002998:	9dc58593          	addi	a1,a1,-1572 # 80008370 <states.1778+0x120>
    8000299c:	00015517          	auipc	a0,0x15
    800029a0:	fcc50513          	addi	a0,a0,-52 # 80017968 <tickslock>
    800029a4:	ffffe097          	auipc	ra,0xffffe
    800029a8:	22e080e7          	jalr	558(ra) # 80000bd2 <initlock>
}
    800029ac:	60a2                	ld	ra,8(sp)
    800029ae:	6402                	ld	s0,0(sp)
    800029b0:	0141                	addi	sp,sp,16
    800029b2:	8082                	ret

00000000800029b4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800029b4:	1141                	addi	sp,sp,-16
    800029b6:	e422                	sd	s0,8(sp)
    800029b8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029ba:	00003797          	auipc	a5,0x3
    800029be:	5c678793          	addi	a5,a5,1478 # 80005f80 <kernelvec>
    800029c2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029c6:	6422                	ld	s0,8(sp)
    800029c8:	0141                	addi	sp,sp,16
    800029ca:	8082                	ret

00000000800029cc <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800029cc:	1141                	addi	sp,sp,-16
    800029ce:	e406                	sd	ra,8(sp)
    800029d0:	e022                	sd	s0,0(sp)
    800029d2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800029d4:	fffff097          	auipc	ra,0xfffff
    800029d8:	0c6080e7          	jalr	198(ra) # 80001a9a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029dc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029e0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029e2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800029e6:	00004617          	auipc	a2,0x4
    800029ea:	61a60613          	addi	a2,a2,1562 # 80007000 <_trampoline>
    800029ee:	00004697          	auipc	a3,0x4
    800029f2:	61268693          	addi	a3,a3,1554 # 80007000 <_trampoline>
    800029f6:	8e91                	sub	a3,a3,a2
    800029f8:	040007b7          	lui	a5,0x4000
    800029fc:	17fd                	addi	a5,a5,-1
    800029fe:	07b2                	slli	a5,a5,0xc
    80002a00:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a02:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a06:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a08:	180026f3          	csrr	a3,satp
    80002a0c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a0e:	7138                	ld	a4,96(a0)
    80002a10:	6134                	ld	a3,64(a0)
    80002a12:	6585                	lui	a1,0x1
    80002a14:	96ae                	add	a3,a3,a1
    80002a16:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a18:	7138                	ld	a4,96(a0)
    80002a1a:	00000697          	auipc	a3,0x0
    80002a1e:	13868693          	addi	a3,a3,312 # 80002b52 <usertrap>
    80002a22:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a24:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a26:	8692                	mv	a3,tp
    80002a28:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a2a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a2e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a32:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a36:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a3a:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a3c:	6f18                	ld	a4,24(a4)
    80002a3e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a42:	692c                	ld	a1,80(a0)
    80002a44:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002a46:	00004717          	auipc	a4,0x4
    80002a4a:	64a70713          	addi	a4,a4,1610 # 80007090 <userret>
    80002a4e:	8f11                	sub	a4,a4,a2
    80002a50:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002a52:	577d                	li	a4,-1
    80002a54:	177e                	slli	a4,a4,0x3f
    80002a56:	8dd9                	or	a1,a1,a4
    80002a58:	02000537          	lui	a0,0x2000
    80002a5c:	157d                	addi	a0,a0,-1
    80002a5e:	0536                	slli	a0,a0,0xd
    80002a60:	9782                	jalr	a5
}
    80002a62:	60a2                	ld	ra,8(sp)
    80002a64:	6402                	ld	s0,0(sp)
    80002a66:	0141                	addi	sp,sp,16
    80002a68:	8082                	ret

0000000080002a6a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a6a:	1101                	addi	sp,sp,-32
    80002a6c:	ec06                	sd	ra,24(sp)
    80002a6e:	e822                	sd	s0,16(sp)
    80002a70:	e426                	sd	s1,8(sp)
    80002a72:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a74:	00015497          	auipc	s1,0x15
    80002a78:	ef448493          	addi	s1,s1,-268 # 80017968 <tickslock>
    80002a7c:	8526                	mv	a0,s1
    80002a7e:	ffffe097          	auipc	ra,0xffffe
    80002a82:	1e4080e7          	jalr	484(ra) # 80000c62 <acquire>
  ticks++;
    80002a86:	00006517          	auipc	a0,0x6
    80002a8a:	59a50513          	addi	a0,a0,1434 # 80009020 <ticks>
    80002a8e:	411c                	lw	a5,0(a0)
    80002a90:	2785                	addiw	a5,a5,1
    80002a92:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a94:	00000097          	auipc	ra,0x0
    80002a98:	c56080e7          	jalr	-938(ra) # 800026ea <wakeup>
  release(&tickslock);
    80002a9c:	8526                	mv	a0,s1
    80002a9e:	ffffe097          	auipc	ra,0xffffe
    80002aa2:	278080e7          	jalr	632(ra) # 80000d16 <release>
}
    80002aa6:	60e2                	ld	ra,24(sp)
    80002aa8:	6442                	ld	s0,16(sp)
    80002aaa:	64a2                	ld	s1,8(sp)
    80002aac:	6105                	addi	sp,sp,32
    80002aae:	8082                	ret

0000000080002ab0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002ab0:	1101                	addi	sp,sp,-32
    80002ab2:	ec06                	sd	ra,24(sp)
    80002ab4:	e822                	sd	s0,16(sp)
    80002ab6:	e426                	sd	s1,8(sp)
    80002ab8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aba:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002abe:	00074d63          	bltz	a4,80002ad8 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002ac2:	57fd                	li	a5,-1
    80002ac4:	17fe                	slli	a5,a5,0x3f
    80002ac6:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002ac8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002aca:	06f70363          	beq	a4,a5,80002b30 <devintr+0x80>
  }
}
    80002ace:	60e2                	ld	ra,24(sp)
    80002ad0:	6442                	ld	s0,16(sp)
    80002ad2:	64a2                	ld	s1,8(sp)
    80002ad4:	6105                	addi	sp,sp,32
    80002ad6:	8082                	ret
     (scause & 0xff) == 9){
    80002ad8:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002adc:	46a5                	li	a3,9
    80002ade:	fed792e3          	bne	a5,a3,80002ac2 <devintr+0x12>
    int irq = plic_claim();
    80002ae2:	00003097          	auipc	ra,0x3
    80002ae6:	5a6080e7          	jalr	1446(ra) # 80006088 <plic_claim>
    80002aea:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002aec:	47a9                	li	a5,10
    80002aee:	02f50763          	beq	a0,a5,80002b1c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002af2:	4785                	li	a5,1
    80002af4:	02f50963          	beq	a0,a5,80002b26 <devintr+0x76>
    return 1;
    80002af8:	4505                	li	a0,1
    } else if(irq){
    80002afa:	d8f1                	beqz	s1,80002ace <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002afc:	85a6                	mv	a1,s1
    80002afe:	00006517          	auipc	a0,0x6
    80002b02:	87a50513          	addi	a0,a0,-1926 # 80008378 <states.1778+0x128>
    80002b06:	ffffe097          	auipc	ra,0xffffe
    80002b0a:	ab8080e7          	jalr	-1352(ra) # 800005be <printf>
      plic_complete(irq);
    80002b0e:	8526                	mv	a0,s1
    80002b10:	00003097          	auipc	ra,0x3
    80002b14:	59c080e7          	jalr	1436(ra) # 800060ac <plic_complete>
    return 1;
    80002b18:	4505                	li	a0,1
    80002b1a:	bf55                	j	80002ace <devintr+0x1e>
      uartintr();
    80002b1c:	ffffe097          	auipc	ra,0xffffe
    80002b20:	f06080e7          	jalr	-250(ra) # 80000a22 <uartintr>
    80002b24:	b7ed                	j	80002b0e <devintr+0x5e>
      virtio_disk_intr();
    80002b26:	00004097          	auipc	ra,0x4
    80002b2a:	a32080e7          	jalr	-1486(ra) # 80006558 <virtio_disk_intr>
    80002b2e:	b7c5                	j	80002b0e <devintr+0x5e>
    if(cpuid() == 0){
    80002b30:	fffff097          	auipc	ra,0xfffff
    80002b34:	f3e080e7          	jalr	-194(ra) # 80001a6e <cpuid>
    80002b38:	c901                	beqz	a0,80002b48 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b3a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b3e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b40:	14479073          	csrw	sip,a5
    return 2;
    80002b44:	4509                	li	a0,2
    80002b46:	b761                	j	80002ace <devintr+0x1e>
      clockintr();
    80002b48:	00000097          	auipc	ra,0x0
    80002b4c:	f22080e7          	jalr	-222(ra) # 80002a6a <clockintr>
    80002b50:	b7ed                	j	80002b3a <devintr+0x8a>

0000000080002b52 <usertrap>:
{
    80002b52:	1101                	addi	sp,sp,-32
    80002b54:	ec06                	sd	ra,24(sp)
    80002b56:	e822                	sd	s0,16(sp)
    80002b58:	e426                	sd	s1,8(sp)
    80002b5a:	e04a                	sd	s2,0(sp)
    80002b5c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b5e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b62:	1007f793          	andi	a5,a5,256
    80002b66:	e3ad                	bnez	a5,80002bc8 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b68:	00003797          	auipc	a5,0x3
    80002b6c:	41878793          	addi	a5,a5,1048 # 80005f80 <kernelvec>
    80002b70:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b74:	fffff097          	auipc	ra,0xfffff
    80002b78:	f26080e7          	jalr	-218(ra) # 80001a9a <myproc>
    80002b7c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b7e:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b80:	14102773          	csrr	a4,sepc
    80002b84:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b86:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b8a:	47a1                	li	a5,8
    80002b8c:	04f71c63          	bne	a4,a5,80002be4 <usertrap+0x92>
    if(p->killed)
    80002b90:	591c                	lw	a5,48(a0)
    80002b92:	e3b9                	bnez	a5,80002bd8 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002b94:	70b8                	ld	a4,96(s1)
    80002b96:	6f1c                	ld	a5,24(a4)
    80002b98:	0791                	addi	a5,a5,4
    80002b9a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ba0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ba4:	10079073          	csrw	sstatus,a5
    syscall();
    80002ba8:	00000097          	auipc	ra,0x0
    80002bac:	2e6080e7          	jalr	742(ra) # 80002e8e <syscall>
  if(p->killed)
    80002bb0:	589c                	lw	a5,48(s1)
    80002bb2:	ebc1                	bnez	a5,80002c42 <usertrap+0xf0>
  usertrapret();
    80002bb4:	00000097          	auipc	ra,0x0
    80002bb8:	e18080e7          	jalr	-488(ra) # 800029cc <usertrapret>
}
    80002bbc:	60e2                	ld	ra,24(sp)
    80002bbe:	6442                	ld	s0,16(sp)
    80002bc0:	64a2                	ld	s1,8(sp)
    80002bc2:	6902                	ld	s2,0(sp)
    80002bc4:	6105                	addi	sp,sp,32
    80002bc6:	8082                	ret
    panic("usertrap: not from user mode");
    80002bc8:	00005517          	auipc	a0,0x5
    80002bcc:	7d050513          	addi	a0,a0,2000 # 80008398 <states.1778+0x148>
    80002bd0:	ffffe097          	auipc	ra,0xffffe
    80002bd4:	9a4080e7          	jalr	-1628(ra) # 80000574 <panic>
      exit(-1);
    80002bd8:	557d                	li	a0,-1
    80002bda:	00000097          	auipc	ra,0x0
    80002bde:	842080e7          	jalr	-1982(ra) # 8000241c <exit>
    80002be2:	bf4d                	j	80002b94 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002be4:	00000097          	auipc	ra,0x0
    80002be8:	ecc080e7          	jalr	-308(ra) # 80002ab0 <devintr>
    80002bec:	892a                	mv	s2,a0
    80002bee:	c501                	beqz	a0,80002bf6 <usertrap+0xa4>
  if(p->killed)
    80002bf0:	589c                	lw	a5,48(s1)
    80002bf2:	c3a1                	beqz	a5,80002c32 <usertrap+0xe0>
    80002bf4:	a815                	j	80002c28 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bf6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002bfa:	5c90                	lw	a2,56(s1)
    80002bfc:	00005517          	auipc	a0,0x5
    80002c00:	7bc50513          	addi	a0,a0,1980 # 800083b8 <states.1778+0x168>
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	9ba080e7          	jalr	-1606(ra) # 800005be <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c0c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c10:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c14:	00005517          	auipc	a0,0x5
    80002c18:	7d450513          	addi	a0,a0,2004 # 800083e8 <states.1778+0x198>
    80002c1c:	ffffe097          	auipc	ra,0xffffe
    80002c20:	9a2080e7          	jalr	-1630(ra) # 800005be <printf>
    p->killed = 1;
    80002c24:	4785                	li	a5,1
    80002c26:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002c28:	557d                	li	a0,-1
    80002c2a:	fffff097          	auipc	ra,0xfffff
    80002c2e:	7f2080e7          	jalr	2034(ra) # 8000241c <exit>
  if(which_dev == 2)
    80002c32:	4789                	li	a5,2
    80002c34:	f8f910e3          	bne	s2,a5,80002bb4 <usertrap+0x62>
    yield();
    80002c38:	00000097          	auipc	ra,0x0
    80002c3c:	8f0080e7          	jalr	-1808(ra) # 80002528 <yield>
    80002c40:	bf95                	j	80002bb4 <usertrap+0x62>
  int which_dev = 0;
    80002c42:	4901                	li	s2,0
    80002c44:	b7d5                	j	80002c28 <usertrap+0xd6>

0000000080002c46 <kerneltrap>:
{
    80002c46:	7179                	addi	sp,sp,-48
    80002c48:	f406                	sd	ra,40(sp)
    80002c4a:	f022                	sd	s0,32(sp)
    80002c4c:	ec26                	sd	s1,24(sp)
    80002c4e:	e84a                	sd	s2,16(sp)
    80002c50:	e44e                	sd	s3,8(sp)
    80002c52:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c54:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c58:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c5c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c60:	1004f793          	andi	a5,s1,256
    80002c64:	cb85                	beqz	a5,80002c94 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c66:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c6a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c6c:	ef85                	bnez	a5,80002ca4 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c6e:	00000097          	auipc	ra,0x0
    80002c72:	e42080e7          	jalr	-446(ra) # 80002ab0 <devintr>
    80002c76:	cd1d                	beqz	a0,80002cb4 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c78:	4789                	li	a5,2
    80002c7a:	06f50a63          	beq	a0,a5,80002cee <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c7e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c82:	10049073          	csrw	sstatus,s1
}
    80002c86:	70a2                	ld	ra,40(sp)
    80002c88:	7402                	ld	s0,32(sp)
    80002c8a:	64e2                	ld	s1,24(sp)
    80002c8c:	6942                	ld	s2,16(sp)
    80002c8e:	69a2                	ld	s3,8(sp)
    80002c90:	6145                	addi	sp,sp,48
    80002c92:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c94:	00005517          	auipc	a0,0x5
    80002c98:	77450513          	addi	a0,a0,1908 # 80008408 <states.1778+0x1b8>
    80002c9c:	ffffe097          	auipc	ra,0xffffe
    80002ca0:	8d8080e7          	jalr	-1832(ra) # 80000574 <panic>
    panic("kerneltrap: interrupts enabled");
    80002ca4:	00005517          	auipc	a0,0x5
    80002ca8:	78c50513          	addi	a0,a0,1932 # 80008430 <states.1778+0x1e0>
    80002cac:	ffffe097          	auipc	ra,0xffffe
    80002cb0:	8c8080e7          	jalr	-1848(ra) # 80000574 <panic>
    printf("scause %p\n", scause);
    80002cb4:	85ce                	mv	a1,s3
    80002cb6:	00005517          	auipc	a0,0x5
    80002cba:	79a50513          	addi	a0,a0,1946 # 80008450 <states.1778+0x200>
    80002cbe:	ffffe097          	auipc	ra,0xffffe
    80002cc2:	900080e7          	jalr	-1792(ra) # 800005be <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cc6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cca:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cce:	00005517          	auipc	a0,0x5
    80002cd2:	79250513          	addi	a0,a0,1938 # 80008460 <states.1778+0x210>
    80002cd6:	ffffe097          	auipc	ra,0xffffe
    80002cda:	8e8080e7          	jalr	-1816(ra) # 800005be <printf>
    panic("kerneltrap");
    80002cde:	00005517          	auipc	a0,0x5
    80002ce2:	79a50513          	addi	a0,a0,1946 # 80008478 <states.1778+0x228>
    80002ce6:	ffffe097          	auipc	ra,0xffffe
    80002cea:	88e080e7          	jalr	-1906(ra) # 80000574 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cee:	fffff097          	auipc	ra,0xfffff
    80002cf2:	dac080e7          	jalr	-596(ra) # 80001a9a <myproc>
    80002cf6:	d541                	beqz	a0,80002c7e <kerneltrap+0x38>
    80002cf8:	fffff097          	auipc	ra,0xfffff
    80002cfc:	da2080e7          	jalr	-606(ra) # 80001a9a <myproc>
    80002d00:	4d18                	lw	a4,24(a0)
    80002d02:	478d                	li	a5,3
    80002d04:	f6f71de3          	bne	a4,a5,80002c7e <kerneltrap+0x38>
    yield();
    80002d08:	00000097          	auipc	ra,0x0
    80002d0c:	820080e7          	jalr	-2016(ra) # 80002528 <yield>
    80002d10:	b7bd                	j	80002c7e <kerneltrap+0x38>

0000000080002d12 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d12:	1101                	addi	sp,sp,-32
    80002d14:	ec06                	sd	ra,24(sp)
    80002d16:	e822                	sd	s0,16(sp)
    80002d18:	e426                	sd	s1,8(sp)
    80002d1a:	1000                	addi	s0,sp,32
    80002d1c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d1e:	fffff097          	auipc	ra,0xfffff
    80002d22:	d7c080e7          	jalr	-644(ra) # 80001a9a <myproc>
  switch (n) {
    80002d26:	4795                	li	a5,5
    80002d28:	0497e363          	bltu	a5,s1,80002d6e <argraw+0x5c>
    80002d2c:	1482                	slli	s1,s1,0x20
    80002d2e:	9081                	srli	s1,s1,0x20
    80002d30:	048a                	slli	s1,s1,0x2
    80002d32:	00005717          	auipc	a4,0x5
    80002d36:	75670713          	addi	a4,a4,1878 # 80008488 <states.1778+0x238>
    80002d3a:	94ba                	add	s1,s1,a4
    80002d3c:	409c                	lw	a5,0(s1)
    80002d3e:	97ba                	add	a5,a5,a4
    80002d40:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d42:	713c                	ld	a5,96(a0)
    80002d44:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d46:	60e2                	ld	ra,24(sp)
    80002d48:	6442                	ld	s0,16(sp)
    80002d4a:	64a2                	ld	s1,8(sp)
    80002d4c:	6105                	addi	sp,sp,32
    80002d4e:	8082                	ret
    return p->trapframe->a1;
    80002d50:	713c                	ld	a5,96(a0)
    80002d52:	7fa8                	ld	a0,120(a5)
    80002d54:	bfcd                	j	80002d46 <argraw+0x34>
    return p->trapframe->a2;
    80002d56:	713c                	ld	a5,96(a0)
    80002d58:	63c8                	ld	a0,128(a5)
    80002d5a:	b7f5                	j	80002d46 <argraw+0x34>
    return p->trapframe->a3;
    80002d5c:	713c                	ld	a5,96(a0)
    80002d5e:	67c8                	ld	a0,136(a5)
    80002d60:	b7dd                	j	80002d46 <argraw+0x34>
    return p->trapframe->a4;
    80002d62:	713c                	ld	a5,96(a0)
    80002d64:	6bc8                	ld	a0,144(a5)
    80002d66:	b7c5                	j	80002d46 <argraw+0x34>
    return p->trapframe->a5;
    80002d68:	713c                	ld	a5,96(a0)
    80002d6a:	6fc8                	ld	a0,152(a5)
    80002d6c:	bfe9                	j	80002d46 <argraw+0x34>
  panic("argraw");
    80002d6e:	00005517          	auipc	a0,0x5
    80002d72:	7e250513          	addi	a0,a0,2018 # 80008550 <syscalls+0xb0>
    80002d76:	ffffd097          	auipc	ra,0xffffd
    80002d7a:	7fe080e7          	jalr	2046(ra) # 80000574 <panic>

0000000080002d7e <fetchaddr>:
{
    80002d7e:	1101                	addi	sp,sp,-32
    80002d80:	ec06                	sd	ra,24(sp)
    80002d82:	e822                	sd	s0,16(sp)
    80002d84:	e426                	sd	s1,8(sp)
    80002d86:	e04a                	sd	s2,0(sp)
    80002d88:	1000                	addi	s0,sp,32
    80002d8a:	84aa                	mv	s1,a0
    80002d8c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d8e:	fffff097          	auipc	ra,0xfffff
    80002d92:	d0c080e7          	jalr	-756(ra) # 80001a9a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002d96:	653c                	ld	a5,72(a0)
    80002d98:	02f4f963          	bleu	a5,s1,80002dca <fetchaddr+0x4c>
    80002d9c:	00848713          	addi	a4,s1,8
    80002da0:	02e7e763          	bltu	a5,a4,80002dce <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002da4:	46a1                	li	a3,8
    80002da6:	8626                	mv	a2,s1
    80002da8:	85ca                	mv	a1,s2
    80002daa:	6928                	ld	a0,80(a0)
    80002dac:	fffff097          	auipc	ra,0xfffff
    80002db0:	a3a080e7          	jalr	-1478(ra) # 800017e6 <copyin>
    80002db4:	00a03533          	snez	a0,a0
    80002db8:	40a0053b          	negw	a0,a0
    80002dbc:	2501                	sext.w	a0,a0
}
    80002dbe:	60e2                	ld	ra,24(sp)
    80002dc0:	6442                	ld	s0,16(sp)
    80002dc2:	64a2                	ld	s1,8(sp)
    80002dc4:	6902                	ld	s2,0(sp)
    80002dc6:	6105                	addi	sp,sp,32
    80002dc8:	8082                	ret
    return -1;
    80002dca:	557d                	li	a0,-1
    80002dcc:	bfcd                	j	80002dbe <fetchaddr+0x40>
    80002dce:	557d                	li	a0,-1
    80002dd0:	b7fd                	j	80002dbe <fetchaddr+0x40>

0000000080002dd2 <fetchstr>:
{
    80002dd2:	7179                	addi	sp,sp,-48
    80002dd4:	f406                	sd	ra,40(sp)
    80002dd6:	f022                	sd	s0,32(sp)
    80002dd8:	ec26                	sd	s1,24(sp)
    80002dda:	e84a                	sd	s2,16(sp)
    80002ddc:	e44e                	sd	s3,8(sp)
    80002dde:	1800                	addi	s0,sp,48
    80002de0:	892a                	mv	s2,a0
    80002de2:	84ae                	mv	s1,a1
    80002de4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002de6:	fffff097          	auipc	ra,0xfffff
    80002dea:	cb4080e7          	jalr	-844(ra) # 80001a9a <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002dee:	86ce                	mv	a3,s3
    80002df0:	864a                	mv	a2,s2
    80002df2:	85a6                	mv	a1,s1
    80002df4:	6928                	ld	a0,80(a0)
    80002df6:	fffff097          	auipc	ra,0xfffff
    80002dfa:	a08080e7          	jalr	-1528(ra) # 800017fe <copyinstr>
  if(err < 0)
    80002dfe:	00054763          	bltz	a0,80002e0c <fetchstr+0x3a>
  return strlen(buf);
    80002e02:	8526                	mv	a0,s1
    80002e04:	ffffe097          	auipc	ra,0xffffe
    80002e08:	104080e7          	jalr	260(ra) # 80000f08 <strlen>
}
    80002e0c:	70a2                	ld	ra,40(sp)
    80002e0e:	7402                	ld	s0,32(sp)
    80002e10:	64e2                	ld	s1,24(sp)
    80002e12:	6942                	ld	s2,16(sp)
    80002e14:	69a2                	ld	s3,8(sp)
    80002e16:	6145                	addi	sp,sp,48
    80002e18:	8082                	ret

0000000080002e1a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002e1a:	1101                	addi	sp,sp,-32
    80002e1c:	ec06                	sd	ra,24(sp)
    80002e1e:	e822                	sd	s0,16(sp)
    80002e20:	e426                	sd	s1,8(sp)
    80002e22:	1000                	addi	s0,sp,32
    80002e24:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e26:	00000097          	auipc	ra,0x0
    80002e2a:	eec080e7          	jalr	-276(ra) # 80002d12 <argraw>
    80002e2e:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e30:	4501                	li	a0,0
    80002e32:	60e2                	ld	ra,24(sp)
    80002e34:	6442                	ld	s0,16(sp)
    80002e36:	64a2                	ld	s1,8(sp)
    80002e38:	6105                	addi	sp,sp,32
    80002e3a:	8082                	ret

0000000080002e3c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002e3c:	1101                	addi	sp,sp,-32
    80002e3e:	ec06                	sd	ra,24(sp)
    80002e40:	e822                	sd	s0,16(sp)
    80002e42:	e426                	sd	s1,8(sp)
    80002e44:	1000                	addi	s0,sp,32
    80002e46:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e48:	00000097          	auipc	ra,0x0
    80002e4c:	eca080e7          	jalr	-310(ra) # 80002d12 <argraw>
    80002e50:	e088                	sd	a0,0(s1)
  return 0;
}
    80002e52:	4501                	li	a0,0
    80002e54:	60e2                	ld	ra,24(sp)
    80002e56:	6442                	ld	s0,16(sp)
    80002e58:	64a2                	ld	s1,8(sp)
    80002e5a:	6105                	addi	sp,sp,32
    80002e5c:	8082                	ret

0000000080002e5e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e5e:	1101                	addi	sp,sp,-32
    80002e60:	ec06                	sd	ra,24(sp)
    80002e62:	e822                	sd	s0,16(sp)
    80002e64:	e426                	sd	s1,8(sp)
    80002e66:	e04a                	sd	s2,0(sp)
    80002e68:	1000                	addi	s0,sp,32
    80002e6a:	84ae                	mv	s1,a1
    80002e6c:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002e6e:	00000097          	auipc	ra,0x0
    80002e72:	ea4080e7          	jalr	-348(ra) # 80002d12 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002e76:	864a                	mv	a2,s2
    80002e78:	85a6                	mv	a1,s1
    80002e7a:	00000097          	auipc	ra,0x0
    80002e7e:	f58080e7          	jalr	-168(ra) # 80002dd2 <fetchstr>
}
    80002e82:	60e2                	ld	ra,24(sp)
    80002e84:	6442                	ld	s0,16(sp)
    80002e86:	64a2                	ld	s1,8(sp)
    80002e88:	6902                	ld	s2,0(sp)
    80002e8a:	6105                	addi	sp,sp,32
    80002e8c:	8082                	ret

0000000080002e8e <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002e8e:	1101                	addi	sp,sp,-32
    80002e90:	ec06                	sd	ra,24(sp)
    80002e92:	e822                	sd	s0,16(sp)
    80002e94:	e426                	sd	s1,8(sp)
    80002e96:	e04a                	sd	s2,0(sp)
    80002e98:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e9a:	fffff097          	auipc	ra,0xfffff
    80002e9e:	c00080e7          	jalr	-1024(ra) # 80001a9a <myproc>
    80002ea2:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ea4:	06053903          	ld	s2,96(a0)
    80002ea8:	0a893783          	ld	a5,168(s2)
    80002eac:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002eb0:	37fd                	addiw	a5,a5,-1
    80002eb2:	4751                	li	a4,20
    80002eb4:	00f76f63          	bltu	a4,a5,80002ed2 <syscall+0x44>
    80002eb8:	00369713          	slli	a4,a3,0x3
    80002ebc:	00005797          	auipc	a5,0x5
    80002ec0:	5e478793          	addi	a5,a5,1508 # 800084a0 <syscalls>
    80002ec4:	97ba                	add	a5,a5,a4
    80002ec6:	639c                	ld	a5,0(a5)
    80002ec8:	c789                	beqz	a5,80002ed2 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002eca:	9782                	jalr	a5
    80002ecc:	06a93823          	sd	a0,112(s2)
    80002ed0:	a839                	j	80002eee <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002ed2:	16048613          	addi	a2,s1,352
    80002ed6:	5c8c                	lw	a1,56(s1)
    80002ed8:	00005517          	auipc	a0,0x5
    80002edc:	68050513          	addi	a0,a0,1664 # 80008558 <syscalls+0xb8>
    80002ee0:	ffffd097          	auipc	ra,0xffffd
    80002ee4:	6de080e7          	jalr	1758(ra) # 800005be <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ee8:	70bc                	ld	a5,96(s1)
    80002eea:	577d                	li	a4,-1
    80002eec:	fbb8                	sd	a4,112(a5)
  }
}
    80002eee:	60e2                	ld	ra,24(sp)
    80002ef0:	6442                	ld	s0,16(sp)
    80002ef2:	64a2                	ld	s1,8(sp)
    80002ef4:	6902                	ld	s2,0(sp)
    80002ef6:	6105                	addi	sp,sp,32
    80002ef8:	8082                	ret

0000000080002efa <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002efa:	1101                	addi	sp,sp,-32
    80002efc:	ec06                	sd	ra,24(sp)
    80002efe:	e822                	sd	s0,16(sp)
    80002f00:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002f02:	fec40593          	addi	a1,s0,-20
    80002f06:	4501                	li	a0,0
    80002f08:	00000097          	auipc	ra,0x0
    80002f0c:	f12080e7          	jalr	-238(ra) # 80002e1a <argint>
    return -1;
    80002f10:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f12:	00054963          	bltz	a0,80002f24 <sys_exit+0x2a>
  exit(n);
    80002f16:	fec42503          	lw	a0,-20(s0)
    80002f1a:	fffff097          	auipc	ra,0xfffff
    80002f1e:	502080e7          	jalr	1282(ra) # 8000241c <exit>
  return 0;  // not reached
    80002f22:	4781                	li	a5,0
}
    80002f24:	853e                	mv	a0,a5
    80002f26:	60e2                	ld	ra,24(sp)
    80002f28:	6442                	ld	s0,16(sp)
    80002f2a:	6105                	addi	sp,sp,32
    80002f2c:	8082                	ret

0000000080002f2e <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f2e:	1141                	addi	sp,sp,-16
    80002f30:	e406                	sd	ra,8(sp)
    80002f32:	e022                	sd	s0,0(sp)
    80002f34:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f36:	fffff097          	auipc	ra,0xfffff
    80002f3a:	b64080e7          	jalr	-1180(ra) # 80001a9a <myproc>
}
    80002f3e:	5d08                	lw	a0,56(a0)
    80002f40:	60a2                	ld	ra,8(sp)
    80002f42:	6402                	ld	s0,0(sp)
    80002f44:	0141                	addi	sp,sp,16
    80002f46:	8082                	ret

0000000080002f48 <sys_fork>:

uint64
sys_fork(void)
{
    80002f48:	1141                	addi	sp,sp,-16
    80002f4a:	e406                	sd	ra,8(sp)
    80002f4c:	e022                	sd	s0,0(sp)
    80002f4e:	0800                	addi	s0,sp,16
  return fork();
    80002f50:	fffff097          	auipc	ra,0xfffff
    80002f54:	188080e7          	jalr	392(ra) # 800020d8 <fork>
}
    80002f58:	60a2                	ld	ra,8(sp)
    80002f5a:	6402                	ld	s0,0(sp)
    80002f5c:	0141                	addi	sp,sp,16
    80002f5e:	8082                	ret

0000000080002f60 <sys_wait>:

uint64
sys_wait(void)
{
    80002f60:	1101                	addi	sp,sp,-32
    80002f62:	ec06                	sd	ra,24(sp)
    80002f64:	e822                	sd	s0,16(sp)
    80002f66:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002f68:	fe840593          	addi	a1,s0,-24
    80002f6c:	4501                	li	a0,0
    80002f6e:	00000097          	auipc	ra,0x0
    80002f72:	ece080e7          	jalr	-306(ra) # 80002e3c <argaddr>
    return -1;
    80002f76:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    80002f78:	00054963          	bltz	a0,80002f8a <sys_wait+0x2a>
  return wait(p);
    80002f7c:	fe843503          	ld	a0,-24(s0)
    80002f80:	fffff097          	auipc	ra,0xfffff
    80002f84:	662080e7          	jalr	1634(ra) # 800025e2 <wait>
    80002f88:	87aa                	mv	a5,a0
}
    80002f8a:	853e                	mv	a0,a5
    80002f8c:	60e2                	ld	ra,24(sp)
    80002f8e:	6442                	ld	s0,16(sp)
    80002f90:	6105                	addi	sp,sp,32
    80002f92:	8082                	ret

0000000080002f94 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f94:	7179                	addi	sp,sp,-48
    80002f96:	f406                	sd	ra,40(sp)
    80002f98:	f022                	sd	s0,32(sp)
    80002f9a:	ec26                	sd	s1,24(sp)
    80002f9c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002f9e:	fdc40593          	addi	a1,s0,-36
    80002fa2:	4501                	li	a0,0
    80002fa4:	00000097          	auipc	ra,0x0
    80002fa8:	e76080e7          	jalr	-394(ra) # 80002e1a <argint>
    return -1;
    80002fac:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002fae:	00054f63          	bltz	a0,80002fcc <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002fb2:	fffff097          	auipc	ra,0xfffff
    80002fb6:	ae8080e7          	jalr	-1304(ra) # 80001a9a <myproc>
    80002fba:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002fbc:	fdc42503          	lw	a0,-36(s0)
    80002fc0:	fffff097          	auipc	ra,0xfffff
    80002fc4:	036080e7          	jalr	54(ra) # 80001ff6 <growproc>
    80002fc8:	00054863          	bltz	a0,80002fd8 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002fcc:	8526                	mv	a0,s1
    80002fce:	70a2                	ld	ra,40(sp)
    80002fd0:	7402                	ld	s0,32(sp)
    80002fd2:	64e2                	ld	s1,24(sp)
    80002fd4:	6145                	addi	sp,sp,48
    80002fd6:	8082                	ret
    return -1;
    80002fd8:	54fd                	li	s1,-1
    80002fda:	bfcd                	j	80002fcc <sys_sbrk+0x38>

0000000080002fdc <sys_sleep>:

uint64
sys_sleep(void)
{
    80002fdc:	7139                	addi	sp,sp,-64
    80002fde:	fc06                	sd	ra,56(sp)
    80002fe0:	f822                	sd	s0,48(sp)
    80002fe2:	f426                	sd	s1,40(sp)
    80002fe4:	f04a                	sd	s2,32(sp)
    80002fe6:	ec4e                	sd	s3,24(sp)
    80002fe8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002fea:	fcc40593          	addi	a1,s0,-52
    80002fee:	4501                	li	a0,0
    80002ff0:	00000097          	auipc	ra,0x0
    80002ff4:	e2a080e7          	jalr	-470(ra) # 80002e1a <argint>
    return -1;
    80002ff8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ffa:	06054763          	bltz	a0,80003068 <sys_sleep+0x8c>
  acquire(&tickslock);
    80002ffe:	00015517          	auipc	a0,0x15
    80003002:	96a50513          	addi	a0,a0,-1686 # 80017968 <tickslock>
    80003006:	ffffe097          	auipc	ra,0xffffe
    8000300a:	c5c080e7          	jalr	-932(ra) # 80000c62 <acquire>
  ticks0 = ticks;
    8000300e:	00006797          	auipc	a5,0x6
    80003012:	01278793          	addi	a5,a5,18 # 80009020 <ticks>
    80003016:	0007a903          	lw	s2,0(a5)
  while(ticks - ticks0 < n){
    8000301a:	fcc42783          	lw	a5,-52(s0)
    8000301e:	cf85                	beqz	a5,80003056 <sys_sleep+0x7a>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003020:	00015997          	auipc	s3,0x15
    80003024:	94898993          	addi	s3,s3,-1720 # 80017968 <tickslock>
    80003028:	00006497          	auipc	s1,0x6
    8000302c:	ff848493          	addi	s1,s1,-8 # 80009020 <ticks>
    if(myproc()->killed){
    80003030:	fffff097          	auipc	ra,0xfffff
    80003034:	a6a080e7          	jalr	-1430(ra) # 80001a9a <myproc>
    80003038:	591c                	lw	a5,48(a0)
    8000303a:	ef9d                	bnez	a5,80003078 <sys_sleep+0x9c>
    sleep(&ticks, &tickslock);
    8000303c:	85ce                	mv	a1,s3
    8000303e:	8526                	mv	a0,s1
    80003040:	fffff097          	auipc	ra,0xfffff
    80003044:	524080e7          	jalr	1316(ra) # 80002564 <sleep>
  while(ticks - ticks0 < n){
    80003048:	409c                	lw	a5,0(s1)
    8000304a:	412787bb          	subw	a5,a5,s2
    8000304e:	fcc42703          	lw	a4,-52(s0)
    80003052:	fce7efe3          	bltu	a5,a4,80003030 <sys_sleep+0x54>
  }
  release(&tickslock);
    80003056:	00015517          	auipc	a0,0x15
    8000305a:	91250513          	addi	a0,a0,-1774 # 80017968 <tickslock>
    8000305e:	ffffe097          	auipc	ra,0xffffe
    80003062:	cb8080e7          	jalr	-840(ra) # 80000d16 <release>
  return 0;
    80003066:	4781                	li	a5,0
}
    80003068:	853e                	mv	a0,a5
    8000306a:	70e2                	ld	ra,56(sp)
    8000306c:	7442                	ld	s0,48(sp)
    8000306e:	74a2                	ld	s1,40(sp)
    80003070:	7902                	ld	s2,32(sp)
    80003072:	69e2                	ld	s3,24(sp)
    80003074:	6121                	addi	sp,sp,64
    80003076:	8082                	ret
      release(&tickslock);
    80003078:	00015517          	auipc	a0,0x15
    8000307c:	8f050513          	addi	a0,a0,-1808 # 80017968 <tickslock>
    80003080:	ffffe097          	auipc	ra,0xffffe
    80003084:	c96080e7          	jalr	-874(ra) # 80000d16 <release>
      return -1;
    80003088:	57fd                	li	a5,-1
    8000308a:	bff9                	j	80003068 <sys_sleep+0x8c>

000000008000308c <sys_kill>:

uint64
sys_kill(void)
{
    8000308c:	1101                	addi	sp,sp,-32
    8000308e:	ec06                	sd	ra,24(sp)
    80003090:	e822                	sd	s0,16(sp)
    80003092:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003094:	fec40593          	addi	a1,s0,-20
    80003098:	4501                	li	a0,0
    8000309a:	00000097          	auipc	ra,0x0
    8000309e:	d80080e7          	jalr	-640(ra) # 80002e1a <argint>
    return -1;
    800030a2:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    800030a4:	00054963          	bltz	a0,800030b6 <sys_kill+0x2a>
  return kill(pid);
    800030a8:	fec42503          	lw	a0,-20(s0)
    800030ac:	fffff097          	auipc	ra,0xfffff
    800030b0:	6a8080e7          	jalr	1704(ra) # 80002754 <kill>
    800030b4:	87aa                	mv	a5,a0
}
    800030b6:	853e                	mv	a0,a5
    800030b8:	60e2                	ld	ra,24(sp)
    800030ba:	6442                	ld	s0,16(sp)
    800030bc:	6105                	addi	sp,sp,32
    800030be:	8082                	ret

00000000800030c0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030c0:	1101                	addi	sp,sp,-32
    800030c2:	ec06                	sd	ra,24(sp)
    800030c4:	e822                	sd	s0,16(sp)
    800030c6:	e426                	sd	s1,8(sp)
    800030c8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030ca:	00015517          	auipc	a0,0x15
    800030ce:	89e50513          	addi	a0,a0,-1890 # 80017968 <tickslock>
    800030d2:	ffffe097          	auipc	ra,0xffffe
    800030d6:	b90080e7          	jalr	-1136(ra) # 80000c62 <acquire>
  xticks = ticks;
    800030da:	00006797          	auipc	a5,0x6
    800030de:	f4678793          	addi	a5,a5,-186 # 80009020 <ticks>
    800030e2:	4384                	lw	s1,0(a5)
  release(&tickslock);
    800030e4:	00015517          	auipc	a0,0x15
    800030e8:	88450513          	addi	a0,a0,-1916 # 80017968 <tickslock>
    800030ec:	ffffe097          	auipc	ra,0xffffe
    800030f0:	c2a080e7          	jalr	-982(ra) # 80000d16 <release>
  return xticks;
}
    800030f4:	02049513          	slli	a0,s1,0x20
    800030f8:	9101                	srli	a0,a0,0x20
    800030fa:	60e2                	ld	ra,24(sp)
    800030fc:	6442                	ld	s0,16(sp)
    800030fe:	64a2                	ld	s1,8(sp)
    80003100:	6105                	addi	sp,sp,32
    80003102:	8082                	ret

0000000080003104 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003104:	7179                	addi	sp,sp,-48
    80003106:	f406                	sd	ra,40(sp)
    80003108:	f022                	sd	s0,32(sp)
    8000310a:	ec26                	sd	s1,24(sp)
    8000310c:	e84a                	sd	s2,16(sp)
    8000310e:	e44e                	sd	s3,8(sp)
    80003110:	e052                	sd	s4,0(sp)
    80003112:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003114:	00005597          	auipc	a1,0x5
    80003118:	46458593          	addi	a1,a1,1124 # 80008578 <syscalls+0xd8>
    8000311c:	00015517          	auipc	a0,0x15
    80003120:	86450513          	addi	a0,a0,-1948 # 80017980 <bcache>
    80003124:	ffffe097          	auipc	ra,0xffffe
    80003128:	aae080e7          	jalr	-1362(ra) # 80000bd2 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000312c:	0001d797          	auipc	a5,0x1d
    80003130:	85478793          	addi	a5,a5,-1964 # 8001f980 <bcache+0x8000>
    80003134:	0001d717          	auipc	a4,0x1d
    80003138:	ab470713          	addi	a4,a4,-1356 # 8001fbe8 <bcache+0x8268>
    8000313c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003140:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003144:	00015497          	auipc	s1,0x15
    80003148:	85448493          	addi	s1,s1,-1964 # 80017998 <bcache+0x18>
    b->next = bcache.head.next;
    8000314c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000314e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003150:	00005a17          	auipc	s4,0x5
    80003154:	430a0a13          	addi	s4,s4,1072 # 80008580 <syscalls+0xe0>
    b->next = bcache.head.next;
    80003158:	2b893783          	ld	a5,696(s2)
    8000315c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000315e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003162:	85d2                	mv	a1,s4
    80003164:	01048513          	addi	a0,s1,16
    80003168:	00001097          	auipc	ra,0x1
    8000316c:	51a080e7          	jalr	1306(ra) # 80004682 <initsleeplock>
    bcache.head.next->prev = b;
    80003170:	2b893783          	ld	a5,696(s2)
    80003174:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003176:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000317a:	45848493          	addi	s1,s1,1112
    8000317e:	fd349de3          	bne	s1,s3,80003158 <binit+0x54>
  }
}
    80003182:	70a2                	ld	ra,40(sp)
    80003184:	7402                	ld	s0,32(sp)
    80003186:	64e2                	ld	s1,24(sp)
    80003188:	6942                	ld	s2,16(sp)
    8000318a:	69a2                	ld	s3,8(sp)
    8000318c:	6a02                	ld	s4,0(sp)
    8000318e:	6145                	addi	sp,sp,48
    80003190:	8082                	ret

0000000080003192 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003192:	7179                	addi	sp,sp,-48
    80003194:	f406                	sd	ra,40(sp)
    80003196:	f022                	sd	s0,32(sp)
    80003198:	ec26                	sd	s1,24(sp)
    8000319a:	e84a                	sd	s2,16(sp)
    8000319c:	e44e                	sd	s3,8(sp)
    8000319e:	1800                	addi	s0,sp,48
    800031a0:	89aa                	mv	s3,a0
    800031a2:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800031a4:	00014517          	auipc	a0,0x14
    800031a8:	7dc50513          	addi	a0,a0,2012 # 80017980 <bcache>
    800031ac:	ffffe097          	auipc	ra,0xffffe
    800031b0:	ab6080e7          	jalr	-1354(ra) # 80000c62 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031b4:	0001c797          	auipc	a5,0x1c
    800031b8:	7cc78793          	addi	a5,a5,1996 # 8001f980 <bcache+0x8000>
    800031bc:	2b87b483          	ld	s1,696(a5)
    800031c0:	0001d797          	auipc	a5,0x1d
    800031c4:	a2878793          	addi	a5,a5,-1496 # 8001fbe8 <bcache+0x8268>
    800031c8:	02f48f63          	beq	s1,a5,80003206 <bread+0x74>
    800031cc:	873e                	mv	a4,a5
    800031ce:	a021                	j	800031d6 <bread+0x44>
    800031d0:	68a4                	ld	s1,80(s1)
    800031d2:	02e48a63          	beq	s1,a4,80003206 <bread+0x74>
    if(b->dev == dev && b->blockno == blockno){
    800031d6:	449c                	lw	a5,8(s1)
    800031d8:	ff379ce3          	bne	a5,s3,800031d0 <bread+0x3e>
    800031dc:	44dc                	lw	a5,12(s1)
    800031de:	ff2799e3          	bne	a5,s2,800031d0 <bread+0x3e>
      b->refcnt++;
    800031e2:	40bc                	lw	a5,64(s1)
    800031e4:	2785                	addiw	a5,a5,1
    800031e6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031e8:	00014517          	auipc	a0,0x14
    800031ec:	79850513          	addi	a0,a0,1944 # 80017980 <bcache>
    800031f0:	ffffe097          	auipc	ra,0xffffe
    800031f4:	b26080e7          	jalr	-1242(ra) # 80000d16 <release>
      acquiresleep(&b->lock);
    800031f8:	01048513          	addi	a0,s1,16
    800031fc:	00001097          	auipc	ra,0x1
    80003200:	4c0080e7          	jalr	1216(ra) # 800046bc <acquiresleep>
      return b;
    80003204:	a8b1                	j	80003260 <bread+0xce>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003206:	0001c797          	auipc	a5,0x1c
    8000320a:	77a78793          	addi	a5,a5,1914 # 8001f980 <bcache+0x8000>
    8000320e:	2b07b483          	ld	s1,688(a5)
    80003212:	0001d797          	auipc	a5,0x1d
    80003216:	9d678793          	addi	a5,a5,-1578 # 8001fbe8 <bcache+0x8268>
    8000321a:	04f48d63          	beq	s1,a5,80003274 <bread+0xe2>
    if(b->refcnt == 0) {
    8000321e:	40bc                	lw	a5,64(s1)
    80003220:	cb91                	beqz	a5,80003234 <bread+0xa2>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003222:	0001d717          	auipc	a4,0x1d
    80003226:	9c670713          	addi	a4,a4,-1594 # 8001fbe8 <bcache+0x8268>
    8000322a:	64a4                	ld	s1,72(s1)
    8000322c:	04e48463          	beq	s1,a4,80003274 <bread+0xe2>
    if(b->refcnt == 0) {
    80003230:	40bc                	lw	a5,64(s1)
    80003232:	ffe5                	bnez	a5,8000322a <bread+0x98>
      b->dev = dev;
    80003234:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003238:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    8000323c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003240:	4785                	li	a5,1
    80003242:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003244:	00014517          	auipc	a0,0x14
    80003248:	73c50513          	addi	a0,a0,1852 # 80017980 <bcache>
    8000324c:	ffffe097          	auipc	ra,0xffffe
    80003250:	aca080e7          	jalr	-1334(ra) # 80000d16 <release>
      acquiresleep(&b->lock);
    80003254:	01048513          	addi	a0,s1,16
    80003258:	00001097          	auipc	ra,0x1
    8000325c:	464080e7          	jalr	1124(ra) # 800046bc <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003260:	409c                	lw	a5,0(s1)
    80003262:	c38d                	beqz	a5,80003284 <bread+0xf2>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003264:	8526                	mv	a0,s1
    80003266:	70a2                	ld	ra,40(sp)
    80003268:	7402                	ld	s0,32(sp)
    8000326a:	64e2                	ld	s1,24(sp)
    8000326c:	6942                	ld	s2,16(sp)
    8000326e:	69a2                	ld	s3,8(sp)
    80003270:	6145                	addi	sp,sp,48
    80003272:	8082                	ret
  panic("bget: no buffers");
    80003274:	00005517          	auipc	a0,0x5
    80003278:	31450513          	addi	a0,a0,788 # 80008588 <syscalls+0xe8>
    8000327c:	ffffd097          	auipc	ra,0xffffd
    80003280:	2f8080e7          	jalr	760(ra) # 80000574 <panic>
    virtio_disk_rw(b, 0);
    80003284:	4581                	li	a1,0
    80003286:	8526                	mv	a0,s1
    80003288:	00003097          	auipc	ra,0x3
    8000328c:	016080e7          	jalr	22(ra) # 8000629e <virtio_disk_rw>
    b->valid = 1;
    80003290:	4785                	li	a5,1
    80003292:	c09c                	sw	a5,0(s1)
  return b;
    80003294:	bfc1                	j	80003264 <bread+0xd2>

0000000080003296 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003296:	1101                	addi	sp,sp,-32
    80003298:	ec06                	sd	ra,24(sp)
    8000329a:	e822                	sd	s0,16(sp)
    8000329c:	e426                	sd	s1,8(sp)
    8000329e:	1000                	addi	s0,sp,32
    800032a0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032a2:	0541                	addi	a0,a0,16
    800032a4:	00001097          	auipc	ra,0x1
    800032a8:	4b2080e7          	jalr	1202(ra) # 80004756 <holdingsleep>
    800032ac:	cd01                	beqz	a0,800032c4 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032ae:	4585                	li	a1,1
    800032b0:	8526                	mv	a0,s1
    800032b2:	00003097          	auipc	ra,0x3
    800032b6:	fec080e7          	jalr	-20(ra) # 8000629e <virtio_disk_rw>
}
    800032ba:	60e2                	ld	ra,24(sp)
    800032bc:	6442                	ld	s0,16(sp)
    800032be:	64a2                	ld	s1,8(sp)
    800032c0:	6105                	addi	sp,sp,32
    800032c2:	8082                	ret
    panic("bwrite");
    800032c4:	00005517          	auipc	a0,0x5
    800032c8:	2dc50513          	addi	a0,a0,732 # 800085a0 <syscalls+0x100>
    800032cc:	ffffd097          	auipc	ra,0xffffd
    800032d0:	2a8080e7          	jalr	680(ra) # 80000574 <panic>

00000000800032d4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032d4:	1101                	addi	sp,sp,-32
    800032d6:	ec06                	sd	ra,24(sp)
    800032d8:	e822                	sd	s0,16(sp)
    800032da:	e426                	sd	s1,8(sp)
    800032dc:	e04a                	sd	s2,0(sp)
    800032de:	1000                	addi	s0,sp,32
    800032e0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032e2:	01050913          	addi	s2,a0,16
    800032e6:	854a                	mv	a0,s2
    800032e8:	00001097          	auipc	ra,0x1
    800032ec:	46e080e7          	jalr	1134(ra) # 80004756 <holdingsleep>
    800032f0:	c92d                	beqz	a0,80003362 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800032f2:	854a                	mv	a0,s2
    800032f4:	00001097          	auipc	ra,0x1
    800032f8:	41e080e7          	jalr	1054(ra) # 80004712 <releasesleep>

  acquire(&bcache.lock);
    800032fc:	00014517          	auipc	a0,0x14
    80003300:	68450513          	addi	a0,a0,1668 # 80017980 <bcache>
    80003304:	ffffe097          	auipc	ra,0xffffe
    80003308:	95e080e7          	jalr	-1698(ra) # 80000c62 <acquire>
  b->refcnt--;
    8000330c:	40bc                	lw	a5,64(s1)
    8000330e:	37fd                	addiw	a5,a5,-1
    80003310:	0007871b          	sext.w	a4,a5
    80003314:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003316:	eb05                	bnez	a4,80003346 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003318:	68bc                	ld	a5,80(s1)
    8000331a:	64b8                	ld	a4,72(s1)
    8000331c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000331e:	64bc                	ld	a5,72(s1)
    80003320:	68b8                	ld	a4,80(s1)
    80003322:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003324:	0001c797          	auipc	a5,0x1c
    80003328:	65c78793          	addi	a5,a5,1628 # 8001f980 <bcache+0x8000>
    8000332c:	2b87b703          	ld	a4,696(a5)
    80003330:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003332:	0001d717          	auipc	a4,0x1d
    80003336:	8b670713          	addi	a4,a4,-1866 # 8001fbe8 <bcache+0x8268>
    8000333a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000333c:	2b87b703          	ld	a4,696(a5)
    80003340:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003342:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003346:	00014517          	auipc	a0,0x14
    8000334a:	63a50513          	addi	a0,a0,1594 # 80017980 <bcache>
    8000334e:	ffffe097          	auipc	ra,0xffffe
    80003352:	9c8080e7          	jalr	-1592(ra) # 80000d16 <release>
}
    80003356:	60e2                	ld	ra,24(sp)
    80003358:	6442                	ld	s0,16(sp)
    8000335a:	64a2                	ld	s1,8(sp)
    8000335c:	6902                	ld	s2,0(sp)
    8000335e:	6105                	addi	sp,sp,32
    80003360:	8082                	ret
    panic("brelse");
    80003362:	00005517          	auipc	a0,0x5
    80003366:	24650513          	addi	a0,a0,582 # 800085a8 <syscalls+0x108>
    8000336a:	ffffd097          	auipc	ra,0xffffd
    8000336e:	20a080e7          	jalr	522(ra) # 80000574 <panic>

0000000080003372 <bpin>:

void
bpin(struct buf *b) {
    80003372:	1101                	addi	sp,sp,-32
    80003374:	ec06                	sd	ra,24(sp)
    80003376:	e822                	sd	s0,16(sp)
    80003378:	e426                	sd	s1,8(sp)
    8000337a:	1000                	addi	s0,sp,32
    8000337c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000337e:	00014517          	auipc	a0,0x14
    80003382:	60250513          	addi	a0,a0,1538 # 80017980 <bcache>
    80003386:	ffffe097          	auipc	ra,0xffffe
    8000338a:	8dc080e7          	jalr	-1828(ra) # 80000c62 <acquire>
  b->refcnt++;
    8000338e:	40bc                	lw	a5,64(s1)
    80003390:	2785                	addiw	a5,a5,1
    80003392:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003394:	00014517          	auipc	a0,0x14
    80003398:	5ec50513          	addi	a0,a0,1516 # 80017980 <bcache>
    8000339c:	ffffe097          	auipc	ra,0xffffe
    800033a0:	97a080e7          	jalr	-1670(ra) # 80000d16 <release>
}
    800033a4:	60e2                	ld	ra,24(sp)
    800033a6:	6442                	ld	s0,16(sp)
    800033a8:	64a2                	ld	s1,8(sp)
    800033aa:	6105                	addi	sp,sp,32
    800033ac:	8082                	ret

00000000800033ae <bunpin>:

void
bunpin(struct buf *b) {
    800033ae:	1101                	addi	sp,sp,-32
    800033b0:	ec06                	sd	ra,24(sp)
    800033b2:	e822                	sd	s0,16(sp)
    800033b4:	e426                	sd	s1,8(sp)
    800033b6:	1000                	addi	s0,sp,32
    800033b8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033ba:	00014517          	auipc	a0,0x14
    800033be:	5c650513          	addi	a0,a0,1478 # 80017980 <bcache>
    800033c2:	ffffe097          	auipc	ra,0xffffe
    800033c6:	8a0080e7          	jalr	-1888(ra) # 80000c62 <acquire>
  b->refcnt--;
    800033ca:	40bc                	lw	a5,64(s1)
    800033cc:	37fd                	addiw	a5,a5,-1
    800033ce:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033d0:	00014517          	auipc	a0,0x14
    800033d4:	5b050513          	addi	a0,a0,1456 # 80017980 <bcache>
    800033d8:	ffffe097          	auipc	ra,0xffffe
    800033dc:	93e080e7          	jalr	-1730(ra) # 80000d16 <release>
}
    800033e0:	60e2                	ld	ra,24(sp)
    800033e2:	6442                	ld	s0,16(sp)
    800033e4:	64a2                	ld	s1,8(sp)
    800033e6:	6105                	addi	sp,sp,32
    800033e8:	8082                	ret

00000000800033ea <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033ea:	1101                	addi	sp,sp,-32
    800033ec:	ec06                	sd	ra,24(sp)
    800033ee:	e822                	sd	s0,16(sp)
    800033f0:	e426                	sd	s1,8(sp)
    800033f2:	e04a                	sd	s2,0(sp)
    800033f4:	1000                	addi	s0,sp,32
    800033f6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033f8:	00d5d59b          	srliw	a1,a1,0xd
    800033fc:	0001d797          	auipc	a5,0x1d
    80003400:	c4478793          	addi	a5,a5,-956 # 80020040 <sb>
    80003404:	4fdc                	lw	a5,28(a5)
    80003406:	9dbd                	addw	a1,a1,a5
    80003408:	00000097          	auipc	ra,0x0
    8000340c:	d8a080e7          	jalr	-630(ra) # 80003192 <bread>
  bi = b % BPB;
    80003410:	2481                	sext.w	s1,s1
  m = 1 << (bi % 8);
    80003412:	0074f793          	andi	a5,s1,7
    80003416:	4705                	li	a4,1
    80003418:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    8000341c:	6789                	lui	a5,0x2
    8000341e:	17fd                	addi	a5,a5,-1
    80003420:	8cfd                	and	s1,s1,a5
  if((bp->data[bi/8] & m) == 0)
    80003422:	41f4d79b          	sraiw	a5,s1,0x1f
    80003426:	01d7d79b          	srliw	a5,a5,0x1d
    8000342a:	9fa5                	addw	a5,a5,s1
    8000342c:	4037d79b          	sraiw	a5,a5,0x3
    80003430:	00f506b3          	add	a3,a0,a5
    80003434:	0586c683          	lbu	a3,88(a3)
    80003438:	00d77633          	and	a2,a4,a3
    8000343c:	c61d                	beqz	a2,8000346a <bfree+0x80>
    8000343e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003440:	97aa                	add	a5,a5,a0
    80003442:	fff74713          	not	a4,a4
    80003446:	8f75                	and	a4,a4,a3
    80003448:	04e78c23          	sb	a4,88(a5) # 2058 <_entry-0x7fffdfa8>
  log_write(bp);
    8000344c:	00001097          	auipc	ra,0x1
    80003450:	132080e7          	jalr	306(ra) # 8000457e <log_write>
  brelse(bp);
    80003454:	854a                	mv	a0,s2
    80003456:	00000097          	auipc	ra,0x0
    8000345a:	e7e080e7          	jalr	-386(ra) # 800032d4 <brelse>
}
    8000345e:	60e2                	ld	ra,24(sp)
    80003460:	6442                	ld	s0,16(sp)
    80003462:	64a2                	ld	s1,8(sp)
    80003464:	6902                	ld	s2,0(sp)
    80003466:	6105                	addi	sp,sp,32
    80003468:	8082                	ret
    panic("freeing free block");
    8000346a:	00005517          	auipc	a0,0x5
    8000346e:	14650513          	addi	a0,a0,326 # 800085b0 <syscalls+0x110>
    80003472:	ffffd097          	auipc	ra,0xffffd
    80003476:	102080e7          	jalr	258(ra) # 80000574 <panic>

000000008000347a <balloc>:
{
    8000347a:	711d                	addi	sp,sp,-96
    8000347c:	ec86                	sd	ra,88(sp)
    8000347e:	e8a2                	sd	s0,80(sp)
    80003480:	e4a6                	sd	s1,72(sp)
    80003482:	e0ca                	sd	s2,64(sp)
    80003484:	fc4e                	sd	s3,56(sp)
    80003486:	f852                	sd	s4,48(sp)
    80003488:	f456                	sd	s5,40(sp)
    8000348a:	f05a                	sd	s6,32(sp)
    8000348c:	ec5e                	sd	s7,24(sp)
    8000348e:	e862                	sd	s8,16(sp)
    80003490:	e466                	sd	s9,8(sp)
    80003492:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003494:	0001d797          	auipc	a5,0x1d
    80003498:	bac78793          	addi	a5,a5,-1108 # 80020040 <sb>
    8000349c:	43dc                	lw	a5,4(a5)
    8000349e:	10078e63          	beqz	a5,800035ba <balloc+0x140>
    800034a2:	8baa                	mv	s7,a0
    800034a4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034a6:	0001db17          	auipc	s6,0x1d
    800034aa:	b9ab0b13          	addi	s6,s6,-1126 # 80020040 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034ae:	4c05                	li	s8,1
      m = 1 << (bi % 8);
    800034b0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034b2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800034b4:	6c89                	lui	s9,0x2
    800034b6:	a079                	j	80003544 <balloc+0xca>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034b8:	8942                	mv	s2,a6
      m = 1 << (bi % 8);
    800034ba:	4705                	li	a4,1
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034bc:	4681                	li	a3,0
        bp->data[bi/8] |= m;  // Mark block in use.
    800034be:	96a6                	add	a3,a3,s1
    800034c0:	8f51                	or	a4,a4,a2
    800034c2:	04e68c23          	sb	a4,88(a3)
        log_write(bp);
    800034c6:	8526                	mv	a0,s1
    800034c8:	00001097          	auipc	ra,0x1
    800034cc:	0b6080e7          	jalr	182(ra) # 8000457e <log_write>
        brelse(bp);
    800034d0:	8526                	mv	a0,s1
    800034d2:	00000097          	auipc	ra,0x0
    800034d6:	e02080e7          	jalr	-510(ra) # 800032d4 <brelse>
  bp = bread(dev, bno);
    800034da:	85ca                	mv	a1,s2
    800034dc:	855e                	mv	a0,s7
    800034de:	00000097          	auipc	ra,0x0
    800034e2:	cb4080e7          	jalr	-844(ra) # 80003192 <bread>
    800034e6:	84aa                	mv	s1,a0
  memset(bp->data, 0, BSIZE);
    800034e8:	40000613          	li	a2,1024
    800034ec:	4581                	li	a1,0
    800034ee:	05850513          	addi	a0,a0,88
    800034f2:	ffffe097          	auipc	ra,0xffffe
    800034f6:	86c080e7          	jalr	-1940(ra) # 80000d5e <memset>
  log_write(bp);
    800034fa:	8526                	mv	a0,s1
    800034fc:	00001097          	auipc	ra,0x1
    80003500:	082080e7          	jalr	130(ra) # 8000457e <log_write>
  brelse(bp);
    80003504:	8526                	mv	a0,s1
    80003506:	00000097          	auipc	ra,0x0
    8000350a:	dce080e7          	jalr	-562(ra) # 800032d4 <brelse>
}
    8000350e:	854a                	mv	a0,s2
    80003510:	60e6                	ld	ra,88(sp)
    80003512:	6446                	ld	s0,80(sp)
    80003514:	64a6                	ld	s1,72(sp)
    80003516:	6906                	ld	s2,64(sp)
    80003518:	79e2                	ld	s3,56(sp)
    8000351a:	7a42                	ld	s4,48(sp)
    8000351c:	7aa2                	ld	s5,40(sp)
    8000351e:	7b02                	ld	s6,32(sp)
    80003520:	6be2                	ld	s7,24(sp)
    80003522:	6c42                	ld	s8,16(sp)
    80003524:	6ca2                	ld	s9,8(sp)
    80003526:	6125                	addi	sp,sp,96
    80003528:	8082                	ret
    brelse(bp);
    8000352a:	8526                	mv	a0,s1
    8000352c:	00000097          	auipc	ra,0x0
    80003530:	da8080e7          	jalr	-600(ra) # 800032d4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003534:	015c87bb          	addw	a5,s9,s5
    80003538:	00078a9b          	sext.w	s5,a5
    8000353c:	004b2703          	lw	a4,4(s6)
    80003540:	06eafd63          	bleu	a4,s5,800035ba <balloc+0x140>
    bp = bread(dev, BBLOCK(b, sb));
    80003544:	41fad79b          	sraiw	a5,s5,0x1f
    80003548:	0137d79b          	srliw	a5,a5,0x13
    8000354c:	015787bb          	addw	a5,a5,s5
    80003550:	40d7d79b          	sraiw	a5,a5,0xd
    80003554:	01cb2583          	lw	a1,28(s6)
    80003558:	9dbd                	addw	a1,a1,a5
    8000355a:	855e                	mv	a0,s7
    8000355c:	00000097          	auipc	ra,0x0
    80003560:	c36080e7          	jalr	-970(ra) # 80003192 <bread>
    80003564:	84aa                	mv	s1,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003566:	000a881b          	sext.w	a6,s5
    8000356a:	004b2503          	lw	a0,4(s6)
    8000356e:	faa87ee3          	bleu	a0,a6,8000352a <balloc+0xb0>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003572:	0584c603          	lbu	a2,88(s1)
    80003576:	00167793          	andi	a5,a2,1
    8000357a:	df9d                	beqz	a5,800034b8 <balloc+0x3e>
    8000357c:	4105053b          	subw	a0,a0,a6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003580:	87e2                	mv	a5,s8
    80003582:	0107893b          	addw	s2,a5,a6
    80003586:	faa782e3          	beq	a5,a0,8000352a <balloc+0xb0>
      m = 1 << (bi % 8);
    8000358a:	41f7d71b          	sraiw	a4,a5,0x1f
    8000358e:	01d7561b          	srliw	a2,a4,0x1d
    80003592:	00f606bb          	addw	a3,a2,a5
    80003596:	0076f713          	andi	a4,a3,7
    8000359a:	9f11                	subw	a4,a4,a2
    8000359c:	00e9973b          	sllw	a4,s3,a4
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800035a0:	4036d69b          	sraiw	a3,a3,0x3
    800035a4:	00d48633          	add	a2,s1,a3
    800035a8:	05864603          	lbu	a2,88(a2)
    800035ac:	00c775b3          	and	a1,a4,a2
    800035b0:	d599                	beqz	a1,800034be <balloc+0x44>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035b2:	2785                	addiw	a5,a5,1
    800035b4:	fd4797e3          	bne	a5,s4,80003582 <balloc+0x108>
    800035b8:	bf8d                	j	8000352a <balloc+0xb0>
  panic("balloc: out of blocks");
    800035ba:	00005517          	auipc	a0,0x5
    800035be:	00e50513          	addi	a0,a0,14 # 800085c8 <syscalls+0x128>
    800035c2:	ffffd097          	auipc	ra,0xffffd
    800035c6:	fb2080e7          	jalr	-78(ra) # 80000574 <panic>

00000000800035ca <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800035ca:	7179                	addi	sp,sp,-48
    800035cc:	f406                	sd	ra,40(sp)
    800035ce:	f022                	sd	s0,32(sp)
    800035d0:	ec26                	sd	s1,24(sp)
    800035d2:	e84a                	sd	s2,16(sp)
    800035d4:	e44e                	sd	s3,8(sp)
    800035d6:	e052                	sd	s4,0(sp)
    800035d8:	1800                	addi	s0,sp,48
    800035da:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035dc:	47ad                	li	a5,11
    800035de:	04b7fe63          	bleu	a1,a5,8000363a <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800035e2:	ff45849b          	addiw	s1,a1,-12
    800035e6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800035ea:	0ff00793          	li	a5,255
    800035ee:	0ae7e363          	bltu	a5,a4,80003694 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800035f2:	08052583          	lw	a1,128(a0)
    800035f6:	c5ad                	beqz	a1,80003660 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800035f8:	0009a503          	lw	a0,0(s3)
    800035fc:	00000097          	auipc	ra,0x0
    80003600:	b96080e7          	jalr	-1130(ra) # 80003192 <bread>
    80003604:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003606:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000360a:	02049593          	slli	a1,s1,0x20
    8000360e:	9181                	srli	a1,a1,0x20
    80003610:	058a                	slli	a1,a1,0x2
    80003612:	00b784b3          	add	s1,a5,a1
    80003616:	0004a903          	lw	s2,0(s1)
    8000361a:	04090d63          	beqz	s2,80003674 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000361e:	8552                	mv	a0,s4
    80003620:	00000097          	auipc	ra,0x0
    80003624:	cb4080e7          	jalr	-844(ra) # 800032d4 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003628:	854a                	mv	a0,s2
    8000362a:	70a2                	ld	ra,40(sp)
    8000362c:	7402                	ld	s0,32(sp)
    8000362e:	64e2                	ld	s1,24(sp)
    80003630:	6942                	ld	s2,16(sp)
    80003632:	69a2                	ld	s3,8(sp)
    80003634:	6a02                	ld	s4,0(sp)
    80003636:	6145                	addi	sp,sp,48
    80003638:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000363a:	02059493          	slli	s1,a1,0x20
    8000363e:	9081                	srli	s1,s1,0x20
    80003640:	048a                	slli	s1,s1,0x2
    80003642:	94aa                	add	s1,s1,a0
    80003644:	0504a903          	lw	s2,80(s1)
    80003648:	fe0910e3          	bnez	s2,80003628 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000364c:	4108                	lw	a0,0(a0)
    8000364e:	00000097          	auipc	ra,0x0
    80003652:	e2c080e7          	jalr	-468(ra) # 8000347a <balloc>
    80003656:	0005091b          	sext.w	s2,a0
    8000365a:	0524a823          	sw	s2,80(s1)
    8000365e:	b7e9                	j	80003628 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003660:	4108                	lw	a0,0(a0)
    80003662:	00000097          	auipc	ra,0x0
    80003666:	e18080e7          	jalr	-488(ra) # 8000347a <balloc>
    8000366a:	0005059b          	sext.w	a1,a0
    8000366e:	08b9a023          	sw	a1,128(s3)
    80003672:	b759                	j	800035f8 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003674:	0009a503          	lw	a0,0(s3)
    80003678:	00000097          	auipc	ra,0x0
    8000367c:	e02080e7          	jalr	-510(ra) # 8000347a <balloc>
    80003680:	0005091b          	sext.w	s2,a0
    80003684:	0124a023          	sw	s2,0(s1)
      log_write(bp);
    80003688:	8552                	mv	a0,s4
    8000368a:	00001097          	auipc	ra,0x1
    8000368e:	ef4080e7          	jalr	-268(ra) # 8000457e <log_write>
    80003692:	b771                	j	8000361e <bmap+0x54>
  panic("bmap: out of range");
    80003694:	00005517          	auipc	a0,0x5
    80003698:	f4c50513          	addi	a0,a0,-180 # 800085e0 <syscalls+0x140>
    8000369c:	ffffd097          	auipc	ra,0xffffd
    800036a0:	ed8080e7          	jalr	-296(ra) # 80000574 <panic>

00000000800036a4 <iget>:
{
    800036a4:	7179                	addi	sp,sp,-48
    800036a6:	f406                	sd	ra,40(sp)
    800036a8:	f022                	sd	s0,32(sp)
    800036aa:	ec26                	sd	s1,24(sp)
    800036ac:	e84a                	sd	s2,16(sp)
    800036ae:	e44e                	sd	s3,8(sp)
    800036b0:	e052                	sd	s4,0(sp)
    800036b2:	1800                	addi	s0,sp,48
    800036b4:	89aa                	mv	s3,a0
    800036b6:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800036b8:	0001d517          	auipc	a0,0x1d
    800036bc:	9a850513          	addi	a0,a0,-1624 # 80020060 <icache>
    800036c0:	ffffd097          	auipc	ra,0xffffd
    800036c4:	5a2080e7          	jalr	1442(ra) # 80000c62 <acquire>
  empty = 0;
    800036c8:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800036ca:	0001d497          	auipc	s1,0x1d
    800036ce:	9ae48493          	addi	s1,s1,-1618 # 80020078 <icache+0x18>
    800036d2:	0001e697          	auipc	a3,0x1e
    800036d6:	43668693          	addi	a3,a3,1078 # 80021b08 <log>
    800036da:	a039                	j	800036e8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036dc:	02090b63          	beqz	s2,80003712 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800036e0:	08848493          	addi	s1,s1,136
    800036e4:	02d48a63          	beq	s1,a3,80003718 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800036e8:	449c                	lw	a5,8(s1)
    800036ea:	fef059e3          	blez	a5,800036dc <iget+0x38>
    800036ee:	4098                	lw	a4,0(s1)
    800036f0:	ff3716e3          	bne	a4,s3,800036dc <iget+0x38>
    800036f4:	40d8                	lw	a4,4(s1)
    800036f6:	ff4713e3          	bne	a4,s4,800036dc <iget+0x38>
      ip->ref++;
    800036fa:	2785                	addiw	a5,a5,1
    800036fc:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800036fe:	0001d517          	auipc	a0,0x1d
    80003702:	96250513          	addi	a0,a0,-1694 # 80020060 <icache>
    80003706:	ffffd097          	auipc	ra,0xffffd
    8000370a:	610080e7          	jalr	1552(ra) # 80000d16 <release>
      return ip;
    8000370e:	8926                	mv	s2,s1
    80003710:	a03d                	j	8000373e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003712:	f7f9                	bnez	a5,800036e0 <iget+0x3c>
    80003714:	8926                	mv	s2,s1
    80003716:	b7e9                	j	800036e0 <iget+0x3c>
  if(empty == 0)
    80003718:	02090c63          	beqz	s2,80003750 <iget+0xac>
  ip->dev = dev;
    8000371c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003720:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003724:	4785                	li	a5,1
    80003726:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000372a:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    8000372e:	0001d517          	auipc	a0,0x1d
    80003732:	93250513          	addi	a0,a0,-1742 # 80020060 <icache>
    80003736:	ffffd097          	auipc	ra,0xffffd
    8000373a:	5e0080e7          	jalr	1504(ra) # 80000d16 <release>
}
    8000373e:	854a                	mv	a0,s2
    80003740:	70a2                	ld	ra,40(sp)
    80003742:	7402                	ld	s0,32(sp)
    80003744:	64e2                	ld	s1,24(sp)
    80003746:	6942                	ld	s2,16(sp)
    80003748:	69a2                	ld	s3,8(sp)
    8000374a:	6a02                	ld	s4,0(sp)
    8000374c:	6145                	addi	sp,sp,48
    8000374e:	8082                	ret
    panic("iget: no inodes");
    80003750:	00005517          	auipc	a0,0x5
    80003754:	ea850513          	addi	a0,a0,-344 # 800085f8 <syscalls+0x158>
    80003758:	ffffd097          	auipc	ra,0xffffd
    8000375c:	e1c080e7          	jalr	-484(ra) # 80000574 <panic>

0000000080003760 <fsinit>:
fsinit(int dev) {
    80003760:	7179                	addi	sp,sp,-48
    80003762:	f406                	sd	ra,40(sp)
    80003764:	f022                	sd	s0,32(sp)
    80003766:	ec26                	sd	s1,24(sp)
    80003768:	e84a                	sd	s2,16(sp)
    8000376a:	e44e                	sd	s3,8(sp)
    8000376c:	1800                	addi	s0,sp,48
    8000376e:	89aa                	mv	s3,a0
  bp = bread(dev, 1);
    80003770:	4585                	li	a1,1
    80003772:	00000097          	auipc	ra,0x0
    80003776:	a20080e7          	jalr	-1504(ra) # 80003192 <bread>
    8000377a:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000377c:	0001d497          	auipc	s1,0x1d
    80003780:	8c448493          	addi	s1,s1,-1852 # 80020040 <sb>
    80003784:	02000613          	li	a2,32
    80003788:	05850593          	addi	a1,a0,88
    8000378c:	8526                	mv	a0,s1
    8000378e:	ffffd097          	auipc	ra,0xffffd
    80003792:	63c080e7          	jalr	1596(ra) # 80000dca <memmove>
  brelse(bp);
    80003796:	854a                	mv	a0,s2
    80003798:	00000097          	auipc	ra,0x0
    8000379c:	b3c080e7          	jalr	-1220(ra) # 800032d4 <brelse>
  if(sb.magic != FSMAGIC)
    800037a0:	4098                	lw	a4,0(s1)
    800037a2:	102037b7          	lui	a5,0x10203
    800037a6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037aa:	02f71263          	bne	a4,a5,800037ce <fsinit+0x6e>
  initlog(dev, &sb);
    800037ae:	0001d597          	auipc	a1,0x1d
    800037b2:	89258593          	addi	a1,a1,-1902 # 80020040 <sb>
    800037b6:	854e                	mv	a0,s3
    800037b8:	00001097          	auipc	ra,0x1
    800037bc:	b48080e7          	jalr	-1208(ra) # 80004300 <initlog>
}
    800037c0:	70a2                	ld	ra,40(sp)
    800037c2:	7402                	ld	s0,32(sp)
    800037c4:	64e2                	ld	s1,24(sp)
    800037c6:	6942                	ld	s2,16(sp)
    800037c8:	69a2                	ld	s3,8(sp)
    800037ca:	6145                	addi	sp,sp,48
    800037cc:	8082                	ret
    panic("invalid file system");
    800037ce:	00005517          	auipc	a0,0x5
    800037d2:	e3a50513          	addi	a0,a0,-454 # 80008608 <syscalls+0x168>
    800037d6:	ffffd097          	auipc	ra,0xffffd
    800037da:	d9e080e7          	jalr	-610(ra) # 80000574 <panic>

00000000800037de <iinit>:
{
    800037de:	7179                	addi	sp,sp,-48
    800037e0:	f406                	sd	ra,40(sp)
    800037e2:	f022                	sd	s0,32(sp)
    800037e4:	ec26                	sd	s1,24(sp)
    800037e6:	e84a                	sd	s2,16(sp)
    800037e8:	e44e                	sd	s3,8(sp)
    800037ea:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800037ec:	00005597          	auipc	a1,0x5
    800037f0:	e3458593          	addi	a1,a1,-460 # 80008620 <syscalls+0x180>
    800037f4:	0001d517          	auipc	a0,0x1d
    800037f8:	86c50513          	addi	a0,a0,-1940 # 80020060 <icache>
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	3d6080e7          	jalr	982(ra) # 80000bd2 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003804:	0001d497          	auipc	s1,0x1d
    80003808:	88448493          	addi	s1,s1,-1916 # 80020088 <icache+0x28>
    8000380c:	0001e997          	auipc	s3,0x1e
    80003810:	30c98993          	addi	s3,s3,780 # 80021b18 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003814:	00005917          	auipc	s2,0x5
    80003818:	e1490913          	addi	s2,s2,-492 # 80008628 <syscalls+0x188>
    8000381c:	85ca                	mv	a1,s2
    8000381e:	8526                	mv	a0,s1
    80003820:	00001097          	auipc	ra,0x1
    80003824:	e62080e7          	jalr	-414(ra) # 80004682 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003828:	08848493          	addi	s1,s1,136
    8000382c:	ff3498e3          	bne	s1,s3,8000381c <iinit+0x3e>
}
    80003830:	70a2                	ld	ra,40(sp)
    80003832:	7402                	ld	s0,32(sp)
    80003834:	64e2                	ld	s1,24(sp)
    80003836:	6942                	ld	s2,16(sp)
    80003838:	69a2                	ld	s3,8(sp)
    8000383a:	6145                	addi	sp,sp,48
    8000383c:	8082                	ret

000000008000383e <ialloc>:
{
    8000383e:	715d                	addi	sp,sp,-80
    80003840:	e486                	sd	ra,72(sp)
    80003842:	e0a2                	sd	s0,64(sp)
    80003844:	fc26                	sd	s1,56(sp)
    80003846:	f84a                	sd	s2,48(sp)
    80003848:	f44e                	sd	s3,40(sp)
    8000384a:	f052                	sd	s4,32(sp)
    8000384c:	ec56                	sd	s5,24(sp)
    8000384e:	e85a                	sd	s6,16(sp)
    80003850:	e45e                	sd	s7,8(sp)
    80003852:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003854:	0001c797          	auipc	a5,0x1c
    80003858:	7ec78793          	addi	a5,a5,2028 # 80020040 <sb>
    8000385c:	47d8                	lw	a4,12(a5)
    8000385e:	4785                	li	a5,1
    80003860:	04e7fa63          	bleu	a4,a5,800038b4 <ialloc+0x76>
    80003864:	8a2a                	mv	s4,a0
    80003866:	8b2e                	mv	s6,a1
    80003868:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000386a:	0001c997          	auipc	s3,0x1c
    8000386e:	7d698993          	addi	s3,s3,2006 # 80020040 <sb>
    80003872:	00048a9b          	sext.w	s5,s1
    80003876:	0044d593          	srli	a1,s1,0x4
    8000387a:	0189a783          	lw	a5,24(s3)
    8000387e:	9dbd                	addw	a1,a1,a5
    80003880:	8552                	mv	a0,s4
    80003882:	00000097          	auipc	ra,0x0
    80003886:	910080e7          	jalr	-1776(ra) # 80003192 <bread>
    8000388a:	8baa                	mv	s7,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000388c:	05850913          	addi	s2,a0,88
    80003890:	00f4f793          	andi	a5,s1,15
    80003894:	079a                	slli	a5,a5,0x6
    80003896:	993e                	add	s2,s2,a5
    if(dip->type == 0){  // a free inode
    80003898:	00091783          	lh	a5,0(s2)
    8000389c:	c785                	beqz	a5,800038c4 <ialloc+0x86>
    brelse(bp);
    8000389e:	00000097          	auipc	ra,0x0
    800038a2:	a36080e7          	jalr	-1482(ra) # 800032d4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800038a6:	0485                	addi	s1,s1,1
    800038a8:	00c9a703          	lw	a4,12(s3)
    800038ac:	0004879b          	sext.w	a5,s1
    800038b0:	fce7e1e3          	bltu	a5,a4,80003872 <ialloc+0x34>
  panic("ialloc: no inodes");
    800038b4:	00005517          	auipc	a0,0x5
    800038b8:	d7c50513          	addi	a0,a0,-644 # 80008630 <syscalls+0x190>
    800038bc:	ffffd097          	auipc	ra,0xffffd
    800038c0:	cb8080e7          	jalr	-840(ra) # 80000574 <panic>
      memset(dip, 0, sizeof(*dip));
    800038c4:	04000613          	li	a2,64
    800038c8:	4581                	li	a1,0
    800038ca:	854a                	mv	a0,s2
    800038cc:	ffffd097          	auipc	ra,0xffffd
    800038d0:	492080e7          	jalr	1170(ra) # 80000d5e <memset>
      dip->type = type;
    800038d4:	01691023          	sh	s6,0(s2)
      log_write(bp);   // mark it allocated on the disk
    800038d8:	855e                	mv	a0,s7
    800038da:	00001097          	auipc	ra,0x1
    800038de:	ca4080e7          	jalr	-860(ra) # 8000457e <log_write>
      brelse(bp);
    800038e2:	855e                	mv	a0,s7
    800038e4:	00000097          	auipc	ra,0x0
    800038e8:	9f0080e7          	jalr	-1552(ra) # 800032d4 <brelse>
      return iget(dev, inum);
    800038ec:	85d6                	mv	a1,s5
    800038ee:	8552                	mv	a0,s4
    800038f0:	00000097          	auipc	ra,0x0
    800038f4:	db4080e7          	jalr	-588(ra) # 800036a4 <iget>
}
    800038f8:	60a6                	ld	ra,72(sp)
    800038fa:	6406                	ld	s0,64(sp)
    800038fc:	74e2                	ld	s1,56(sp)
    800038fe:	7942                	ld	s2,48(sp)
    80003900:	79a2                	ld	s3,40(sp)
    80003902:	7a02                	ld	s4,32(sp)
    80003904:	6ae2                	ld	s5,24(sp)
    80003906:	6b42                	ld	s6,16(sp)
    80003908:	6ba2                	ld	s7,8(sp)
    8000390a:	6161                	addi	sp,sp,80
    8000390c:	8082                	ret

000000008000390e <iupdate>:
{
    8000390e:	1101                	addi	sp,sp,-32
    80003910:	ec06                	sd	ra,24(sp)
    80003912:	e822                	sd	s0,16(sp)
    80003914:	e426                	sd	s1,8(sp)
    80003916:	e04a                	sd	s2,0(sp)
    80003918:	1000                	addi	s0,sp,32
    8000391a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000391c:	415c                	lw	a5,4(a0)
    8000391e:	0047d79b          	srliw	a5,a5,0x4
    80003922:	0001c717          	auipc	a4,0x1c
    80003926:	71e70713          	addi	a4,a4,1822 # 80020040 <sb>
    8000392a:	4f0c                	lw	a1,24(a4)
    8000392c:	9dbd                	addw	a1,a1,a5
    8000392e:	4108                	lw	a0,0(a0)
    80003930:	00000097          	auipc	ra,0x0
    80003934:	862080e7          	jalr	-1950(ra) # 80003192 <bread>
    80003938:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000393a:	05850513          	addi	a0,a0,88
    8000393e:	40dc                	lw	a5,4(s1)
    80003940:	8bbd                	andi	a5,a5,15
    80003942:	079a                	slli	a5,a5,0x6
    80003944:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003946:	04449783          	lh	a5,68(s1)
    8000394a:	00f51023          	sh	a5,0(a0)
  dip->major = ip->major;
    8000394e:	04649783          	lh	a5,70(s1)
    80003952:	00f51123          	sh	a5,2(a0)
  dip->minor = ip->minor;
    80003956:	04849783          	lh	a5,72(s1)
    8000395a:	00f51223          	sh	a5,4(a0)
  dip->nlink = ip->nlink;
    8000395e:	04a49783          	lh	a5,74(s1)
    80003962:	00f51323          	sh	a5,6(a0)
  dip->size = ip->size;
    80003966:	44fc                	lw	a5,76(s1)
    80003968:	c51c                	sw	a5,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000396a:	03400613          	li	a2,52
    8000396e:	05048593          	addi	a1,s1,80
    80003972:	0531                	addi	a0,a0,12
    80003974:	ffffd097          	auipc	ra,0xffffd
    80003978:	456080e7          	jalr	1110(ra) # 80000dca <memmove>
  log_write(bp);
    8000397c:	854a                	mv	a0,s2
    8000397e:	00001097          	auipc	ra,0x1
    80003982:	c00080e7          	jalr	-1024(ra) # 8000457e <log_write>
  brelse(bp);
    80003986:	854a                	mv	a0,s2
    80003988:	00000097          	auipc	ra,0x0
    8000398c:	94c080e7          	jalr	-1716(ra) # 800032d4 <brelse>
}
    80003990:	60e2                	ld	ra,24(sp)
    80003992:	6442                	ld	s0,16(sp)
    80003994:	64a2                	ld	s1,8(sp)
    80003996:	6902                	ld	s2,0(sp)
    80003998:	6105                	addi	sp,sp,32
    8000399a:	8082                	ret

000000008000399c <idup>:
{
    8000399c:	1101                	addi	sp,sp,-32
    8000399e:	ec06                	sd	ra,24(sp)
    800039a0:	e822                	sd	s0,16(sp)
    800039a2:	e426                	sd	s1,8(sp)
    800039a4:	1000                	addi	s0,sp,32
    800039a6:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800039a8:	0001c517          	auipc	a0,0x1c
    800039ac:	6b850513          	addi	a0,a0,1720 # 80020060 <icache>
    800039b0:	ffffd097          	auipc	ra,0xffffd
    800039b4:	2b2080e7          	jalr	690(ra) # 80000c62 <acquire>
  ip->ref++;
    800039b8:	449c                	lw	a5,8(s1)
    800039ba:	2785                	addiw	a5,a5,1
    800039bc:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800039be:	0001c517          	auipc	a0,0x1c
    800039c2:	6a250513          	addi	a0,a0,1698 # 80020060 <icache>
    800039c6:	ffffd097          	auipc	ra,0xffffd
    800039ca:	350080e7          	jalr	848(ra) # 80000d16 <release>
}
    800039ce:	8526                	mv	a0,s1
    800039d0:	60e2                	ld	ra,24(sp)
    800039d2:	6442                	ld	s0,16(sp)
    800039d4:	64a2                	ld	s1,8(sp)
    800039d6:	6105                	addi	sp,sp,32
    800039d8:	8082                	ret

00000000800039da <ilock>:
{
    800039da:	1101                	addi	sp,sp,-32
    800039dc:	ec06                	sd	ra,24(sp)
    800039de:	e822                	sd	s0,16(sp)
    800039e0:	e426                	sd	s1,8(sp)
    800039e2:	e04a                	sd	s2,0(sp)
    800039e4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039e6:	c115                	beqz	a0,80003a0a <ilock+0x30>
    800039e8:	84aa                	mv	s1,a0
    800039ea:	451c                	lw	a5,8(a0)
    800039ec:	00f05f63          	blez	a5,80003a0a <ilock+0x30>
  acquiresleep(&ip->lock);
    800039f0:	0541                	addi	a0,a0,16
    800039f2:	00001097          	auipc	ra,0x1
    800039f6:	cca080e7          	jalr	-822(ra) # 800046bc <acquiresleep>
  if(ip->valid == 0){
    800039fa:	40bc                	lw	a5,64(s1)
    800039fc:	cf99                	beqz	a5,80003a1a <ilock+0x40>
}
    800039fe:	60e2                	ld	ra,24(sp)
    80003a00:	6442                	ld	s0,16(sp)
    80003a02:	64a2                	ld	s1,8(sp)
    80003a04:	6902                	ld	s2,0(sp)
    80003a06:	6105                	addi	sp,sp,32
    80003a08:	8082                	ret
    panic("ilock");
    80003a0a:	00005517          	auipc	a0,0x5
    80003a0e:	c3e50513          	addi	a0,a0,-962 # 80008648 <syscalls+0x1a8>
    80003a12:	ffffd097          	auipc	ra,0xffffd
    80003a16:	b62080e7          	jalr	-1182(ra) # 80000574 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a1a:	40dc                	lw	a5,4(s1)
    80003a1c:	0047d79b          	srliw	a5,a5,0x4
    80003a20:	0001c717          	auipc	a4,0x1c
    80003a24:	62070713          	addi	a4,a4,1568 # 80020040 <sb>
    80003a28:	4f0c                	lw	a1,24(a4)
    80003a2a:	9dbd                	addw	a1,a1,a5
    80003a2c:	4088                	lw	a0,0(s1)
    80003a2e:	fffff097          	auipc	ra,0xfffff
    80003a32:	764080e7          	jalr	1892(ra) # 80003192 <bread>
    80003a36:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a38:	05850593          	addi	a1,a0,88
    80003a3c:	40dc                	lw	a5,4(s1)
    80003a3e:	8bbd                	andi	a5,a5,15
    80003a40:	079a                	slli	a5,a5,0x6
    80003a42:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a44:	00059783          	lh	a5,0(a1)
    80003a48:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a4c:	00259783          	lh	a5,2(a1)
    80003a50:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a54:	00459783          	lh	a5,4(a1)
    80003a58:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a5c:	00659783          	lh	a5,6(a1)
    80003a60:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a64:	459c                	lw	a5,8(a1)
    80003a66:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a68:	03400613          	li	a2,52
    80003a6c:	05b1                	addi	a1,a1,12
    80003a6e:	05048513          	addi	a0,s1,80
    80003a72:	ffffd097          	auipc	ra,0xffffd
    80003a76:	358080e7          	jalr	856(ra) # 80000dca <memmove>
    brelse(bp);
    80003a7a:	854a                	mv	a0,s2
    80003a7c:	00000097          	auipc	ra,0x0
    80003a80:	858080e7          	jalr	-1960(ra) # 800032d4 <brelse>
    ip->valid = 1;
    80003a84:	4785                	li	a5,1
    80003a86:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a88:	04449783          	lh	a5,68(s1)
    80003a8c:	fbad                	bnez	a5,800039fe <ilock+0x24>
      panic("ilock: no type");
    80003a8e:	00005517          	auipc	a0,0x5
    80003a92:	bc250513          	addi	a0,a0,-1086 # 80008650 <syscalls+0x1b0>
    80003a96:	ffffd097          	auipc	ra,0xffffd
    80003a9a:	ade080e7          	jalr	-1314(ra) # 80000574 <panic>

0000000080003a9e <iunlock>:
{
    80003a9e:	1101                	addi	sp,sp,-32
    80003aa0:	ec06                	sd	ra,24(sp)
    80003aa2:	e822                	sd	s0,16(sp)
    80003aa4:	e426                	sd	s1,8(sp)
    80003aa6:	e04a                	sd	s2,0(sp)
    80003aa8:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003aaa:	c905                	beqz	a0,80003ada <iunlock+0x3c>
    80003aac:	84aa                	mv	s1,a0
    80003aae:	01050913          	addi	s2,a0,16
    80003ab2:	854a                	mv	a0,s2
    80003ab4:	00001097          	auipc	ra,0x1
    80003ab8:	ca2080e7          	jalr	-862(ra) # 80004756 <holdingsleep>
    80003abc:	cd19                	beqz	a0,80003ada <iunlock+0x3c>
    80003abe:	449c                	lw	a5,8(s1)
    80003ac0:	00f05d63          	blez	a5,80003ada <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ac4:	854a                	mv	a0,s2
    80003ac6:	00001097          	auipc	ra,0x1
    80003aca:	c4c080e7          	jalr	-948(ra) # 80004712 <releasesleep>
}
    80003ace:	60e2                	ld	ra,24(sp)
    80003ad0:	6442                	ld	s0,16(sp)
    80003ad2:	64a2                	ld	s1,8(sp)
    80003ad4:	6902                	ld	s2,0(sp)
    80003ad6:	6105                	addi	sp,sp,32
    80003ad8:	8082                	ret
    panic("iunlock");
    80003ada:	00005517          	auipc	a0,0x5
    80003ade:	b8650513          	addi	a0,a0,-1146 # 80008660 <syscalls+0x1c0>
    80003ae2:	ffffd097          	auipc	ra,0xffffd
    80003ae6:	a92080e7          	jalr	-1390(ra) # 80000574 <panic>

0000000080003aea <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003aea:	7179                	addi	sp,sp,-48
    80003aec:	f406                	sd	ra,40(sp)
    80003aee:	f022                	sd	s0,32(sp)
    80003af0:	ec26                	sd	s1,24(sp)
    80003af2:	e84a                	sd	s2,16(sp)
    80003af4:	e44e                	sd	s3,8(sp)
    80003af6:	e052                	sd	s4,0(sp)
    80003af8:	1800                	addi	s0,sp,48
    80003afa:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003afc:	05050493          	addi	s1,a0,80
    80003b00:	08050913          	addi	s2,a0,128
    80003b04:	a821                	j	80003b1c <itrunc+0x32>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    80003b06:	0009a503          	lw	a0,0(s3)
    80003b0a:	00000097          	auipc	ra,0x0
    80003b0e:	8e0080e7          	jalr	-1824(ra) # 800033ea <bfree>
      ip->addrs[i] = 0;
    80003b12:	0004a023          	sw	zero,0(s1)
  for(i = 0; i < NDIRECT; i++){
    80003b16:	0491                	addi	s1,s1,4
    80003b18:	01248563          	beq	s1,s2,80003b22 <itrunc+0x38>
    if(ip->addrs[i]){
    80003b1c:	408c                	lw	a1,0(s1)
    80003b1e:	dde5                	beqz	a1,80003b16 <itrunc+0x2c>
    80003b20:	b7dd                	j	80003b06 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b22:	0809a583          	lw	a1,128(s3)
    80003b26:	e185                	bnez	a1,80003b46 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b28:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b2c:	854e                	mv	a0,s3
    80003b2e:	00000097          	auipc	ra,0x0
    80003b32:	de0080e7          	jalr	-544(ra) # 8000390e <iupdate>
}
    80003b36:	70a2                	ld	ra,40(sp)
    80003b38:	7402                	ld	s0,32(sp)
    80003b3a:	64e2                	ld	s1,24(sp)
    80003b3c:	6942                	ld	s2,16(sp)
    80003b3e:	69a2                	ld	s3,8(sp)
    80003b40:	6a02                	ld	s4,0(sp)
    80003b42:	6145                	addi	sp,sp,48
    80003b44:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b46:	0009a503          	lw	a0,0(s3)
    80003b4a:	fffff097          	auipc	ra,0xfffff
    80003b4e:	648080e7          	jalr	1608(ra) # 80003192 <bread>
    80003b52:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b54:	05850493          	addi	s1,a0,88
    80003b58:	45850913          	addi	s2,a0,1112
    80003b5c:	a811                	j	80003b70 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003b5e:	0009a503          	lw	a0,0(s3)
    80003b62:	00000097          	auipc	ra,0x0
    80003b66:	888080e7          	jalr	-1912(ra) # 800033ea <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003b6a:	0491                	addi	s1,s1,4
    80003b6c:	01248563          	beq	s1,s2,80003b76 <itrunc+0x8c>
      if(a[j])
    80003b70:	408c                	lw	a1,0(s1)
    80003b72:	dde5                	beqz	a1,80003b6a <itrunc+0x80>
    80003b74:	b7ed                	j	80003b5e <itrunc+0x74>
    brelse(bp);
    80003b76:	8552                	mv	a0,s4
    80003b78:	fffff097          	auipc	ra,0xfffff
    80003b7c:	75c080e7          	jalr	1884(ra) # 800032d4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b80:	0809a583          	lw	a1,128(s3)
    80003b84:	0009a503          	lw	a0,0(s3)
    80003b88:	00000097          	auipc	ra,0x0
    80003b8c:	862080e7          	jalr	-1950(ra) # 800033ea <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b90:	0809a023          	sw	zero,128(s3)
    80003b94:	bf51                	j	80003b28 <itrunc+0x3e>

0000000080003b96 <iput>:
{
    80003b96:	1101                	addi	sp,sp,-32
    80003b98:	ec06                	sd	ra,24(sp)
    80003b9a:	e822                	sd	s0,16(sp)
    80003b9c:	e426                	sd	s1,8(sp)
    80003b9e:	e04a                	sd	s2,0(sp)
    80003ba0:	1000                	addi	s0,sp,32
    80003ba2:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003ba4:	0001c517          	auipc	a0,0x1c
    80003ba8:	4bc50513          	addi	a0,a0,1212 # 80020060 <icache>
    80003bac:	ffffd097          	auipc	ra,0xffffd
    80003bb0:	0b6080e7          	jalr	182(ra) # 80000c62 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bb4:	4498                	lw	a4,8(s1)
    80003bb6:	4785                	li	a5,1
    80003bb8:	02f70363          	beq	a4,a5,80003bde <iput+0x48>
  ip->ref--;
    80003bbc:	449c                	lw	a5,8(s1)
    80003bbe:	37fd                	addiw	a5,a5,-1
    80003bc0:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003bc2:	0001c517          	auipc	a0,0x1c
    80003bc6:	49e50513          	addi	a0,a0,1182 # 80020060 <icache>
    80003bca:	ffffd097          	auipc	ra,0xffffd
    80003bce:	14c080e7          	jalr	332(ra) # 80000d16 <release>
}
    80003bd2:	60e2                	ld	ra,24(sp)
    80003bd4:	6442                	ld	s0,16(sp)
    80003bd6:	64a2                	ld	s1,8(sp)
    80003bd8:	6902                	ld	s2,0(sp)
    80003bda:	6105                	addi	sp,sp,32
    80003bdc:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bde:	40bc                	lw	a5,64(s1)
    80003be0:	dff1                	beqz	a5,80003bbc <iput+0x26>
    80003be2:	04a49783          	lh	a5,74(s1)
    80003be6:	fbf9                	bnez	a5,80003bbc <iput+0x26>
    acquiresleep(&ip->lock);
    80003be8:	01048913          	addi	s2,s1,16
    80003bec:	854a                	mv	a0,s2
    80003bee:	00001097          	auipc	ra,0x1
    80003bf2:	ace080e7          	jalr	-1330(ra) # 800046bc <acquiresleep>
    release(&icache.lock);
    80003bf6:	0001c517          	auipc	a0,0x1c
    80003bfa:	46a50513          	addi	a0,a0,1130 # 80020060 <icache>
    80003bfe:	ffffd097          	auipc	ra,0xffffd
    80003c02:	118080e7          	jalr	280(ra) # 80000d16 <release>
    itrunc(ip);
    80003c06:	8526                	mv	a0,s1
    80003c08:	00000097          	auipc	ra,0x0
    80003c0c:	ee2080e7          	jalr	-286(ra) # 80003aea <itrunc>
    ip->type = 0;
    80003c10:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c14:	8526                	mv	a0,s1
    80003c16:	00000097          	auipc	ra,0x0
    80003c1a:	cf8080e7          	jalr	-776(ra) # 8000390e <iupdate>
    ip->valid = 0;
    80003c1e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c22:	854a                	mv	a0,s2
    80003c24:	00001097          	auipc	ra,0x1
    80003c28:	aee080e7          	jalr	-1298(ra) # 80004712 <releasesleep>
    acquire(&icache.lock);
    80003c2c:	0001c517          	auipc	a0,0x1c
    80003c30:	43450513          	addi	a0,a0,1076 # 80020060 <icache>
    80003c34:	ffffd097          	auipc	ra,0xffffd
    80003c38:	02e080e7          	jalr	46(ra) # 80000c62 <acquire>
    80003c3c:	b741                	j	80003bbc <iput+0x26>

0000000080003c3e <iunlockput>:
{
    80003c3e:	1101                	addi	sp,sp,-32
    80003c40:	ec06                	sd	ra,24(sp)
    80003c42:	e822                	sd	s0,16(sp)
    80003c44:	e426                	sd	s1,8(sp)
    80003c46:	1000                	addi	s0,sp,32
    80003c48:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c4a:	00000097          	auipc	ra,0x0
    80003c4e:	e54080e7          	jalr	-428(ra) # 80003a9e <iunlock>
  iput(ip);
    80003c52:	8526                	mv	a0,s1
    80003c54:	00000097          	auipc	ra,0x0
    80003c58:	f42080e7          	jalr	-190(ra) # 80003b96 <iput>
}
    80003c5c:	60e2                	ld	ra,24(sp)
    80003c5e:	6442                	ld	s0,16(sp)
    80003c60:	64a2                	ld	s1,8(sp)
    80003c62:	6105                	addi	sp,sp,32
    80003c64:	8082                	ret

0000000080003c66 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c66:	1141                	addi	sp,sp,-16
    80003c68:	e422                	sd	s0,8(sp)
    80003c6a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c6c:	411c                	lw	a5,0(a0)
    80003c6e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c70:	415c                	lw	a5,4(a0)
    80003c72:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c74:	04451783          	lh	a5,68(a0)
    80003c78:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c7c:	04a51783          	lh	a5,74(a0)
    80003c80:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c84:	04c56783          	lwu	a5,76(a0)
    80003c88:	e99c                	sd	a5,16(a1)
}
    80003c8a:	6422                	ld	s0,8(sp)
    80003c8c:	0141                	addi	sp,sp,16
    80003c8e:	8082                	ret

0000000080003c90 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c90:	457c                	lw	a5,76(a0)
    80003c92:	0ed7e863          	bltu	a5,a3,80003d82 <readi+0xf2>
{
    80003c96:	7159                	addi	sp,sp,-112
    80003c98:	f486                	sd	ra,104(sp)
    80003c9a:	f0a2                	sd	s0,96(sp)
    80003c9c:	eca6                	sd	s1,88(sp)
    80003c9e:	e8ca                	sd	s2,80(sp)
    80003ca0:	e4ce                	sd	s3,72(sp)
    80003ca2:	e0d2                	sd	s4,64(sp)
    80003ca4:	fc56                	sd	s5,56(sp)
    80003ca6:	f85a                	sd	s6,48(sp)
    80003ca8:	f45e                	sd	s7,40(sp)
    80003caa:	f062                	sd	s8,32(sp)
    80003cac:	ec66                	sd	s9,24(sp)
    80003cae:	e86a                	sd	s10,16(sp)
    80003cb0:	e46e                	sd	s11,8(sp)
    80003cb2:	1880                	addi	s0,sp,112
    80003cb4:	8baa                	mv	s7,a0
    80003cb6:	8c2e                	mv	s8,a1
    80003cb8:	8a32                	mv	s4,a2
    80003cba:	84b6                	mv	s1,a3
    80003cbc:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cbe:	9f35                	addw	a4,a4,a3
    return 0;
    80003cc0:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003cc2:	08d76f63          	bltu	a4,a3,80003d60 <readi+0xd0>
  if(off + n > ip->size)
    80003cc6:	00e7f463          	bleu	a4,a5,80003cce <readi+0x3e>
    n = ip->size - off;
    80003cca:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cce:	0a0b0863          	beqz	s6,80003d7e <readi+0xee>
    80003cd2:	4901                	li	s2,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cd4:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003cd8:	5cfd                	li	s9,-1
    80003cda:	a82d                	j	80003d14 <readi+0x84>
    80003cdc:	02099d93          	slli	s11,s3,0x20
    80003ce0:	020ddd93          	srli	s11,s11,0x20
    80003ce4:	058a8613          	addi	a2,s5,88
    80003ce8:	86ee                	mv	a3,s11
    80003cea:	963a                	add	a2,a2,a4
    80003cec:	85d2                	mv	a1,s4
    80003cee:	8562                	mv	a0,s8
    80003cf0:	fffff097          	auipc	ra,0xfffff
    80003cf4:	ad6080e7          	jalr	-1322(ra) # 800027c6 <either_copyout>
    80003cf8:	05950d63          	beq	a0,s9,80003d52 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003cfc:	8556                	mv	a0,s5
    80003cfe:	fffff097          	auipc	ra,0xfffff
    80003d02:	5d6080e7          	jalr	1494(ra) # 800032d4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d06:	0129893b          	addw	s2,s3,s2
    80003d0a:	009984bb          	addw	s1,s3,s1
    80003d0e:	9a6e                	add	s4,s4,s11
    80003d10:	05697663          	bleu	s6,s2,80003d5c <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d14:	000ba983          	lw	s3,0(s7)
    80003d18:	00a4d59b          	srliw	a1,s1,0xa
    80003d1c:	855e                	mv	a0,s7
    80003d1e:	00000097          	auipc	ra,0x0
    80003d22:	8ac080e7          	jalr	-1876(ra) # 800035ca <bmap>
    80003d26:	0005059b          	sext.w	a1,a0
    80003d2a:	854e                	mv	a0,s3
    80003d2c:	fffff097          	auipc	ra,0xfffff
    80003d30:	466080e7          	jalr	1126(ra) # 80003192 <bread>
    80003d34:	8aaa                	mv	s5,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d36:	3ff4f713          	andi	a4,s1,1023
    80003d3a:	40ed07bb          	subw	a5,s10,a4
    80003d3e:	412b06bb          	subw	a3,s6,s2
    80003d42:	89be                	mv	s3,a5
    80003d44:	2781                	sext.w	a5,a5
    80003d46:	0006861b          	sext.w	a2,a3
    80003d4a:	f8f679e3          	bleu	a5,a2,80003cdc <readi+0x4c>
    80003d4e:	89b6                	mv	s3,a3
    80003d50:	b771                	j	80003cdc <readi+0x4c>
      brelse(bp);
    80003d52:	8556                	mv	a0,s5
    80003d54:	fffff097          	auipc	ra,0xfffff
    80003d58:	580080e7          	jalr	1408(ra) # 800032d4 <brelse>
  }
  return tot;
    80003d5c:	0009051b          	sext.w	a0,s2
}
    80003d60:	70a6                	ld	ra,104(sp)
    80003d62:	7406                	ld	s0,96(sp)
    80003d64:	64e6                	ld	s1,88(sp)
    80003d66:	6946                	ld	s2,80(sp)
    80003d68:	69a6                	ld	s3,72(sp)
    80003d6a:	6a06                	ld	s4,64(sp)
    80003d6c:	7ae2                	ld	s5,56(sp)
    80003d6e:	7b42                	ld	s6,48(sp)
    80003d70:	7ba2                	ld	s7,40(sp)
    80003d72:	7c02                	ld	s8,32(sp)
    80003d74:	6ce2                	ld	s9,24(sp)
    80003d76:	6d42                	ld	s10,16(sp)
    80003d78:	6da2                	ld	s11,8(sp)
    80003d7a:	6165                	addi	sp,sp,112
    80003d7c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d7e:	895a                	mv	s2,s6
    80003d80:	bff1                	j	80003d5c <readi+0xcc>
    return 0;
    80003d82:	4501                	li	a0,0
}
    80003d84:	8082                	ret

0000000080003d86 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d86:	457c                	lw	a5,76(a0)
    80003d88:	10d7e663          	bltu	a5,a3,80003e94 <writei+0x10e>
{
    80003d8c:	7159                	addi	sp,sp,-112
    80003d8e:	f486                	sd	ra,104(sp)
    80003d90:	f0a2                	sd	s0,96(sp)
    80003d92:	eca6                	sd	s1,88(sp)
    80003d94:	e8ca                	sd	s2,80(sp)
    80003d96:	e4ce                	sd	s3,72(sp)
    80003d98:	e0d2                	sd	s4,64(sp)
    80003d9a:	fc56                	sd	s5,56(sp)
    80003d9c:	f85a                	sd	s6,48(sp)
    80003d9e:	f45e                	sd	s7,40(sp)
    80003da0:	f062                	sd	s8,32(sp)
    80003da2:	ec66                	sd	s9,24(sp)
    80003da4:	e86a                	sd	s10,16(sp)
    80003da6:	e46e                	sd	s11,8(sp)
    80003da8:	1880                	addi	s0,sp,112
    80003daa:	8baa                	mv	s7,a0
    80003dac:	8c2e                	mv	s8,a1
    80003dae:	8ab2                	mv	s5,a2
    80003db0:	84b6                	mv	s1,a3
    80003db2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003db4:	00e687bb          	addw	a5,a3,a4
    80003db8:	0ed7e063          	bltu	a5,a3,80003e98 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003dbc:	00043737          	lui	a4,0x43
    80003dc0:	0cf76e63          	bltu	a4,a5,80003e9c <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dc4:	0a0b0763          	beqz	s6,80003e72 <writei+0xec>
    80003dc8:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dca:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003dce:	5cfd                	li	s9,-1
    80003dd0:	a091                	j	80003e14 <writei+0x8e>
    80003dd2:	02091d93          	slli	s11,s2,0x20
    80003dd6:	020ddd93          	srli	s11,s11,0x20
    80003dda:	05898513          	addi	a0,s3,88
    80003dde:	86ee                	mv	a3,s11
    80003de0:	8656                	mv	a2,s5
    80003de2:	85e2                	mv	a1,s8
    80003de4:	953a                	add	a0,a0,a4
    80003de6:	fffff097          	auipc	ra,0xfffff
    80003dea:	a36080e7          	jalr	-1482(ra) # 8000281c <either_copyin>
    80003dee:	07950263          	beq	a0,s9,80003e52 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003df2:	854e                	mv	a0,s3
    80003df4:	00000097          	auipc	ra,0x0
    80003df8:	78a080e7          	jalr	1930(ra) # 8000457e <log_write>
    brelse(bp);
    80003dfc:	854e                	mv	a0,s3
    80003dfe:	fffff097          	auipc	ra,0xfffff
    80003e02:	4d6080e7          	jalr	1238(ra) # 800032d4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e06:	01490a3b          	addw	s4,s2,s4
    80003e0a:	009904bb          	addw	s1,s2,s1
    80003e0e:	9aee                	add	s5,s5,s11
    80003e10:	056a7663          	bleu	s6,s4,80003e5c <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003e14:	000ba903          	lw	s2,0(s7)
    80003e18:	00a4d59b          	srliw	a1,s1,0xa
    80003e1c:	855e                	mv	a0,s7
    80003e1e:	fffff097          	auipc	ra,0xfffff
    80003e22:	7ac080e7          	jalr	1964(ra) # 800035ca <bmap>
    80003e26:	0005059b          	sext.w	a1,a0
    80003e2a:	854a                	mv	a0,s2
    80003e2c:	fffff097          	auipc	ra,0xfffff
    80003e30:	366080e7          	jalr	870(ra) # 80003192 <bread>
    80003e34:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e36:	3ff4f713          	andi	a4,s1,1023
    80003e3a:	40ed07bb          	subw	a5,s10,a4
    80003e3e:	414b06bb          	subw	a3,s6,s4
    80003e42:	893e                	mv	s2,a5
    80003e44:	2781                	sext.w	a5,a5
    80003e46:	0006861b          	sext.w	a2,a3
    80003e4a:	f8f674e3          	bleu	a5,a2,80003dd2 <writei+0x4c>
    80003e4e:	8936                	mv	s2,a3
    80003e50:	b749                	j	80003dd2 <writei+0x4c>
      brelse(bp);
    80003e52:	854e                	mv	a0,s3
    80003e54:	fffff097          	auipc	ra,0xfffff
    80003e58:	480080e7          	jalr	1152(ra) # 800032d4 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003e5c:	04cba783          	lw	a5,76(s7)
    80003e60:	0097f463          	bleu	s1,a5,80003e68 <writei+0xe2>
      ip->size = off;
    80003e64:	049ba623          	sw	s1,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003e68:	855e                	mv	a0,s7
    80003e6a:	00000097          	auipc	ra,0x0
    80003e6e:	aa4080e7          	jalr	-1372(ra) # 8000390e <iupdate>
  }

  return n;
    80003e72:	000b051b          	sext.w	a0,s6
}
    80003e76:	70a6                	ld	ra,104(sp)
    80003e78:	7406                	ld	s0,96(sp)
    80003e7a:	64e6                	ld	s1,88(sp)
    80003e7c:	6946                	ld	s2,80(sp)
    80003e7e:	69a6                	ld	s3,72(sp)
    80003e80:	6a06                	ld	s4,64(sp)
    80003e82:	7ae2                	ld	s5,56(sp)
    80003e84:	7b42                	ld	s6,48(sp)
    80003e86:	7ba2                	ld	s7,40(sp)
    80003e88:	7c02                	ld	s8,32(sp)
    80003e8a:	6ce2                	ld	s9,24(sp)
    80003e8c:	6d42                	ld	s10,16(sp)
    80003e8e:	6da2                	ld	s11,8(sp)
    80003e90:	6165                	addi	sp,sp,112
    80003e92:	8082                	ret
    return -1;
    80003e94:	557d                	li	a0,-1
}
    80003e96:	8082                	ret
    return -1;
    80003e98:	557d                	li	a0,-1
    80003e9a:	bff1                	j	80003e76 <writei+0xf0>
    return -1;
    80003e9c:	557d                	li	a0,-1
    80003e9e:	bfe1                	j	80003e76 <writei+0xf0>

0000000080003ea0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ea0:	1141                	addi	sp,sp,-16
    80003ea2:	e406                	sd	ra,8(sp)
    80003ea4:	e022                	sd	s0,0(sp)
    80003ea6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ea8:	4639                	li	a2,14
    80003eaa:	ffffd097          	auipc	ra,0xffffd
    80003eae:	f9c080e7          	jalr	-100(ra) # 80000e46 <strncmp>
}
    80003eb2:	60a2                	ld	ra,8(sp)
    80003eb4:	6402                	ld	s0,0(sp)
    80003eb6:	0141                	addi	sp,sp,16
    80003eb8:	8082                	ret

0000000080003eba <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003eba:	7139                	addi	sp,sp,-64
    80003ebc:	fc06                	sd	ra,56(sp)
    80003ebe:	f822                	sd	s0,48(sp)
    80003ec0:	f426                	sd	s1,40(sp)
    80003ec2:	f04a                	sd	s2,32(sp)
    80003ec4:	ec4e                	sd	s3,24(sp)
    80003ec6:	e852                	sd	s4,16(sp)
    80003ec8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003eca:	04451703          	lh	a4,68(a0)
    80003ece:	4785                	li	a5,1
    80003ed0:	00f71a63          	bne	a4,a5,80003ee4 <dirlookup+0x2a>
    80003ed4:	892a                	mv	s2,a0
    80003ed6:	89ae                	mv	s3,a1
    80003ed8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eda:	457c                	lw	a5,76(a0)
    80003edc:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ede:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ee0:	e79d                	bnez	a5,80003f0e <dirlookup+0x54>
    80003ee2:	a8a5                	j	80003f5a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ee4:	00004517          	auipc	a0,0x4
    80003ee8:	78450513          	addi	a0,a0,1924 # 80008668 <syscalls+0x1c8>
    80003eec:	ffffc097          	auipc	ra,0xffffc
    80003ef0:	688080e7          	jalr	1672(ra) # 80000574 <panic>
      panic("dirlookup read");
    80003ef4:	00004517          	auipc	a0,0x4
    80003ef8:	78c50513          	addi	a0,a0,1932 # 80008680 <syscalls+0x1e0>
    80003efc:	ffffc097          	auipc	ra,0xffffc
    80003f00:	678080e7          	jalr	1656(ra) # 80000574 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f04:	24c1                	addiw	s1,s1,16
    80003f06:	04c92783          	lw	a5,76(s2)
    80003f0a:	04f4f763          	bleu	a5,s1,80003f58 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f0e:	4741                	li	a4,16
    80003f10:	86a6                	mv	a3,s1
    80003f12:	fc040613          	addi	a2,s0,-64
    80003f16:	4581                	li	a1,0
    80003f18:	854a                	mv	a0,s2
    80003f1a:	00000097          	auipc	ra,0x0
    80003f1e:	d76080e7          	jalr	-650(ra) # 80003c90 <readi>
    80003f22:	47c1                	li	a5,16
    80003f24:	fcf518e3          	bne	a0,a5,80003ef4 <dirlookup+0x3a>
    if(de.inum == 0)
    80003f28:	fc045783          	lhu	a5,-64(s0)
    80003f2c:	dfe1                	beqz	a5,80003f04 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f2e:	fc240593          	addi	a1,s0,-62
    80003f32:	854e                	mv	a0,s3
    80003f34:	00000097          	auipc	ra,0x0
    80003f38:	f6c080e7          	jalr	-148(ra) # 80003ea0 <namecmp>
    80003f3c:	f561                	bnez	a0,80003f04 <dirlookup+0x4a>
      if(poff)
    80003f3e:	000a0463          	beqz	s4,80003f46 <dirlookup+0x8c>
        *poff = off;
    80003f42:	009a2023          	sw	s1,0(s4) # 2000 <_entry-0x7fffe000>
      return iget(dp->dev, inum);
    80003f46:	fc045583          	lhu	a1,-64(s0)
    80003f4a:	00092503          	lw	a0,0(s2)
    80003f4e:	fffff097          	auipc	ra,0xfffff
    80003f52:	756080e7          	jalr	1878(ra) # 800036a4 <iget>
    80003f56:	a011                	j	80003f5a <dirlookup+0xa0>
  return 0;
    80003f58:	4501                	li	a0,0
}
    80003f5a:	70e2                	ld	ra,56(sp)
    80003f5c:	7442                	ld	s0,48(sp)
    80003f5e:	74a2                	ld	s1,40(sp)
    80003f60:	7902                	ld	s2,32(sp)
    80003f62:	69e2                	ld	s3,24(sp)
    80003f64:	6a42                	ld	s4,16(sp)
    80003f66:	6121                	addi	sp,sp,64
    80003f68:	8082                	ret

0000000080003f6a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f6a:	711d                	addi	sp,sp,-96
    80003f6c:	ec86                	sd	ra,88(sp)
    80003f6e:	e8a2                	sd	s0,80(sp)
    80003f70:	e4a6                	sd	s1,72(sp)
    80003f72:	e0ca                	sd	s2,64(sp)
    80003f74:	fc4e                	sd	s3,56(sp)
    80003f76:	f852                	sd	s4,48(sp)
    80003f78:	f456                	sd	s5,40(sp)
    80003f7a:	f05a                	sd	s6,32(sp)
    80003f7c:	ec5e                	sd	s7,24(sp)
    80003f7e:	e862                	sd	s8,16(sp)
    80003f80:	e466                	sd	s9,8(sp)
    80003f82:	1080                	addi	s0,sp,96
    80003f84:	84aa                	mv	s1,a0
    80003f86:	8bae                	mv	s7,a1
    80003f88:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f8a:	00054703          	lbu	a4,0(a0)
    80003f8e:	02f00793          	li	a5,47
    80003f92:	02f70363          	beq	a4,a5,80003fb8 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f96:	ffffe097          	auipc	ra,0xffffe
    80003f9a:	b04080e7          	jalr	-1276(ra) # 80001a9a <myproc>
    80003f9e:	15853503          	ld	a0,344(a0)
    80003fa2:	00000097          	auipc	ra,0x0
    80003fa6:	9fa080e7          	jalr	-1542(ra) # 8000399c <idup>
    80003faa:	89aa                	mv	s3,a0
  while(*path == '/')
    80003fac:	02f00913          	li	s2,47
  len = path - s;
    80003fb0:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003fb2:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003fb4:	4c05                	li	s8,1
    80003fb6:	a865                	j	8000406e <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003fb8:	4585                	li	a1,1
    80003fba:	4505                	li	a0,1
    80003fbc:	fffff097          	auipc	ra,0xfffff
    80003fc0:	6e8080e7          	jalr	1768(ra) # 800036a4 <iget>
    80003fc4:	89aa                	mv	s3,a0
    80003fc6:	b7dd                	j	80003fac <namex+0x42>
      iunlockput(ip);
    80003fc8:	854e                	mv	a0,s3
    80003fca:	00000097          	auipc	ra,0x0
    80003fce:	c74080e7          	jalr	-908(ra) # 80003c3e <iunlockput>
      return 0;
    80003fd2:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003fd4:	854e                	mv	a0,s3
    80003fd6:	60e6                	ld	ra,88(sp)
    80003fd8:	6446                	ld	s0,80(sp)
    80003fda:	64a6                	ld	s1,72(sp)
    80003fdc:	6906                	ld	s2,64(sp)
    80003fde:	79e2                	ld	s3,56(sp)
    80003fe0:	7a42                	ld	s4,48(sp)
    80003fe2:	7aa2                	ld	s5,40(sp)
    80003fe4:	7b02                	ld	s6,32(sp)
    80003fe6:	6be2                	ld	s7,24(sp)
    80003fe8:	6c42                	ld	s8,16(sp)
    80003fea:	6ca2                	ld	s9,8(sp)
    80003fec:	6125                	addi	sp,sp,96
    80003fee:	8082                	ret
      iunlock(ip);
    80003ff0:	854e                	mv	a0,s3
    80003ff2:	00000097          	auipc	ra,0x0
    80003ff6:	aac080e7          	jalr	-1364(ra) # 80003a9e <iunlock>
      return ip;
    80003ffa:	bfe9                	j	80003fd4 <namex+0x6a>
      iunlockput(ip);
    80003ffc:	854e                	mv	a0,s3
    80003ffe:	00000097          	auipc	ra,0x0
    80004002:	c40080e7          	jalr	-960(ra) # 80003c3e <iunlockput>
      return 0;
    80004006:	89d2                	mv	s3,s4
    80004008:	b7f1                	j	80003fd4 <namex+0x6a>
  len = path - s;
    8000400a:	40b48633          	sub	a2,s1,a1
    8000400e:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004012:	094cd663          	ble	s4,s9,8000409e <namex+0x134>
    memmove(name, s, DIRSIZ);
    80004016:	4639                	li	a2,14
    80004018:	8556                	mv	a0,s5
    8000401a:	ffffd097          	auipc	ra,0xffffd
    8000401e:	db0080e7          	jalr	-592(ra) # 80000dca <memmove>
  while(*path == '/')
    80004022:	0004c783          	lbu	a5,0(s1)
    80004026:	01279763          	bne	a5,s2,80004034 <namex+0xca>
    path++;
    8000402a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000402c:	0004c783          	lbu	a5,0(s1)
    80004030:	ff278de3          	beq	a5,s2,8000402a <namex+0xc0>
    ilock(ip);
    80004034:	854e                	mv	a0,s3
    80004036:	00000097          	auipc	ra,0x0
    8000403a:	9a4080e7          	jalr	-1628(ra) # 800039da <ilock>
    if(ip->type != T_DIR){
    8000403e:	04499783          	lh	a5,68(s3)
    80004042:	f98793e3          	bne	a5,s8,80003fc8 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004046:	000b8563          	beqz	s7,80004050 <namex+0xe6>
    8000404a:	0004c783          	lbu	a5,0(s1)
    8000404e:	d3cd                	beqz	a5,80003ff0 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004050:	865a                	mv	a2,s6
    80004052:	85d6                	mv	a1,s5
    80004054:	854e                	mv	a0,s3
    80004056:	00000097          	auipc	ra,0x0
    8000405a:	e64080e7          	jalr	-412(ra) # 80003eba <dirlookup>
    8000405e:	8a2a                	mv	s4,a0
    80004060:	dd51                	beqz	a0,80003ffc <namex+0x92>
    iunlockput(ip);
    80004062:	854e                	mv	a0,s3
    80004064:	00000097          	auipc	ra,0x0
    80004068:	bda080e7          	jalr	-1062(ra) # 80003c3e <iunlockput>
    ip = next;
    8000406c:	89d2                	mv	s3,s4
  while(*path == '/')
    8000406e:	0004c783          	lbu	a5,0(s1)
    80004072:	05279d63          	bne	a5,s2,800040cc <namex+0x162>
    path++;
    80004076:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004078:	0004c783          	lbu	a5,0(s1)
    8000407c:	ff278de3          	beq	a5,s2,80004076 <namex+0x10c>
  if(*path == 0)
    80004080:	cf8d                	beqz	a5,800040ba <namex+0x150>
  while(*path != '/' && *path != 0)
    80004082:	01278b63          	beq	a5,s2,80004098 <namex+0x12e>
    80004086:	c795                	beqz	a5,800040b2 <namex+0x148>
    path++;
    80004088:	85a6                	mv	a1,s1
    path++;
    8000408a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000408c:	0004c783          	lbu	a5,0(s1)
    80004090:	f7278de3          	beq	a5,s2,8000400a <namex+0xa0>
    80004094:	fbfd                	bnez	a5,8000408a <namex+0x120>
    80004096:	bf95                	j	8000400a <namex+0xa0>
    80004098:	85a6                	mv	a1,s1
  len = path - s;
    8000409a:	8a5a                	mv	s4,s6
    8000409c:	865a                	mv	a2,s6
    memmove(name, s, len);
    8000409e:	2601                	sext.w	a2,a2
    800040a0:	8556                	mv	a0,s5
    800040a2:	ffffd097          	auipc	ra,0xffffd
    800040a6:	d28080e7          	jalr	-728(ra) # 80000dca <memmove>
    name[len] = 0;
    800040aa:	9a56                	add	s4,s4,s5
    800040ac:	000a0023          	sb	zero,0(s4)
    800040b0:	bf8d                	j	80004022 <namex+0xb8>
  while(*path != '/' && *path != 0)
    800040b2:	85a6                	mv	a1,s1
  len = path - s;
    800040b4:	8a5a                	mv	s4,s6
    800040b6:	865a                	mv	a2,s6
    800040b8:	b7dd                	j	8000409e <namex+0x134>
  if(nameiparent){
    800040ba:	f00b8de3          	beqz	s7,80003fd4 <namex+0x6a>
    iput(ip);
    800040be:	854e                	mv	a0,s3
    800040c0:	00000097          	auipc	ra,0x0
    800040c4:	ad6080e7          	jalr	-1322(ra) # 80003b96 <iput>
    return 0;
    800040c8:	4981                	li	s3,0
    800040ca:	b729                	j	80003fd4 <namex+0x6a>
  if(*path == 0)
    800040cc:	d7fd                	beqz	a5,800040ba <namex+0x150>
    800040ce:	85a6                	mv	a1,s1
    800040d0:	bf6d                	j	8000408a <namex+0x120>

00000000800040d2 <dirlink>:
{
    800040d2:	7139                	addi	sp,sp,-64
    800040d4:	fc06                	sd	ra,56(sp)
    800040d6:	f822                	sd	s0,48(sp)
    800040d8:	f426                	sd	s1,40(sp)
    800040da:	f04a                	sd	s2,32(sp)
    800040dc:	ec4e                	sd	s3,24(sp)
    800040de:	e852                	sd	s4,16(sp)
    800040e0:	0080                	addi	s0,sp,64
    800040e2:	892a                	mv	s2,a0
    800040e4:	8a2e                	mv	s4,a1
    800040e6:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800040e8:	4601                	li	a2,0
    800040ea:	00000097          	auipc	ra,0x0
    800040ee:	dd0080e7          	jalr	-560(ra) # 80003eba <dirlookup>
    800040f2:	e93d                	bnez	a0,80004168 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040f4:	04c92483          	lw	s1,76(s2)
    800040f8:	c49d                	beqz	s1,80004126 <dirlink+0x54>
    800040fa:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040fc:	4741                	li	a4,16
    800040fe:	86a6                	mv	a3,s1
    80004100:	fc040613          	addi	a2,s0,-64
    80004104:	4581                	li	a1,0
    80004106:	854a                	mv	a0,s2
    80004108:	00000097          	auipc	ra,0x0
    8000410c:	b88080e7          	jalr	-1144(ra) # 80003c90 <readi>
    80004110:	47c1                	li	a5,16
    80004112:	06f51163          	bne	a0,a5,80004174 <dirlink+0xa2>
    if(de.inum == 0)
    80004116:	fc045783          	lhu	a5,-64(s0)
    8000411a:	c791                	beqz	a5,80004126 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000411c:	24c1                	addiw	s1,s1,16
    8000411e:	04c92783          	lw	a5,76(s2)
    80004122:	fcf4ede3          	bltu	s1,a5,800040fc <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004126:	4639                	li	a2,14
    80004128:	85d2                	mv	a1,s4
    8000412a:	fc240513          	addi	a0,s0,-62
    8000412e:	ffffd097          	auipc	ra,0xffffd
    80004132:	d68080e7          	jalr	-664(ra) # 80000e96 <strncpy>
  de.inum = inum;
    80004136:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000413a:	4741                	li	a4,16
    8000413c:	86a6                	mv	a3,s1
    8000413e:	fc040613          	addi	a2,s0,-64
    80004142:	4581                	li	a1,0
    80004144:	854a                	mv	a0,s2
    80004146:	00000097          	auipc	ra,0x0
    8000414a:	c40080e7          	jalr	-960(ra) # 80003d86 <writei>
    8000414e:	4741                	li	a4,16
  return 0;
    80004150:	4781                	li	a5,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004152:	02e51963          	bne	a0,a4,80004184 <dirlink+0xb2>
}
    80004156:	853e                	mv	a0,a5
    80004158:	70e2                	ld	ra,56(sp)
    8000415a:	7442                	ld	s0,48(sp)
    8000415c:	74a2                	ld	s1,40(sp)
    8000415e:	7902                	ld	s2,32(sp)
    80004160:	69e2                	ld	s3,24(sp)
    80004162:	6a42                	ld	s4,16(sp)
    80004164:	6121                	addi	sp,sp,64
    80004166:	8082                	ret
    iput(ip);
    80004168:	00000097          	auipc	ra,0x0
    8000416c:	a2e080e7          	jalr	-1490(ra) # 80003b96 <iput>
    return -1;
    80004170:	57fd                	li	a5,-1
    80004172:	b7d5                	j	80004156 <dirlink+0x84>
      panic("dirlink read");
    80004174:	00004517          	auipc	a0,0x4
    80004178:	51c50513          	addi	a0,a0,1308 # 80008690 <syscalls+0x1f0>
    8000417c:	ffffc097          	auipc	ra,0xffffc
    80004180:	3f8080e7          	jalr	1016(ra) # 80000574 <panic>
    panic("dirlink");
    80004184:	00004517          	auipc	a0,0x4
    80004188:	62450513          	addi	a0,a0,1572 # 800087a8 <syscalls+0x308>
    8000418c:	ffffc097          	auipc	ra,0xffffc
    80004190:	3e8080e7          	jalr	1000(ra) # 80000574 <panic>

0000000080004194 <namei>:

struct inode*
namei(char *path)
{
    80004194:	1101                	addi	sp,sp,-32
    80004196:	ec06                	sd	ra,24(sp)
    80004198:	e822                	sd	s0,16(sp)
    8000419a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000419c:	fe040613          	addi	a2,s0,-32
    800041a0:	4581                	li	a1,0
    800041a2:	00000097          	auipc	ra,0x0
    800041a6:	dc8080e7          	jalr	-568(ra) # 80003f6a <namex>
}
    800041aa:	60e2                	ld	ra,24(sp)
    800041ac:	6442                	ld	s0,16(sp)
    800041ae:	6105                	addi	sp,sp,32
    800041b0:	8082                	ret

00000000800041b2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800041b2:	1141                	addi	sp,sp,-16
    800041b4:	e406                	sd	ra,8(sp)
    800041b6:	e022                	sd	s0,0(sp)
    800041b8:	0800                	addi	s0,sp,16
  return namex(path, 1, name);
    800041ba:	862e                	mv	a2,a1
    800041bc:	4585                	li	a1,1
    800041be:	00000097          	auipc	ra,0x0
    800041c2:	dac080e7          	jalr	-596(ra) # 80003f6a <namex>
}
    800041c6:	60a2                	ld	ra,8(sp)
    800041c8:	6402                	ld	s0,0(sp)
    800041ca:	0141                	addi	sp,sp,16
    800041cc:	8082                	ret

00000000800041ce <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800041ce:	1101                	addi	sp,sp,-32
    800041d0:	ec06                	sd	ra,24(sp)
    800041d2:	e822                	sd	s0,16(sp)
    800041d4:	e426                	sd	s1,8(sp)
    800041d6:	e04a                	sd	s2,0(sp)
    800041d8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800041da:	0001e917          	auipc	s2,0x1e
    800041de:	92e90913          	addi	s2,s2,-1746 # 80021b08 <log>
    800041e2:	01892583          	lw	a1,24(s2)
    800041e6:	02892503          	lw	a0,40(s2)
    800041ea:	fffff097          	auipc	ra,0xfffff
    800041ee:	fa8080e7          	jalr	-88(ra) # 80003192 <bread>
    800041f2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800041f4:	02c92683          	lw	a3,44(s2)
    800041f8:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800041fa:	02d05763          	blez	a3,80004228 <write_head+0x5a>
    800041fe:	0001e797          	auipc	a5,0x1e
    80004202:	93a78793          	addi	a5,a5,-1734 # 80021b38 <log+0x30>
    80004206:	05c50713          	addi	a4,a0,92
    8000420a:	36fd                	addiw	a3,a3,-1
    8000420c:	1682                	slli	a3,a3,0x20
    8000420e:	9281                	srli	a3,a3,0x20
    80004210:	068a                	slli	a3,a3,0x2
    80004212:	0001e617          	auipc	a2,0x1e
    80004216:	92a60613          	addi	a2,a2,-1750 # 80021b3c <log+0x34>
    8000421a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000421c:	4390                	lw	a2,0(a5)
    8000421e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004220:	0791                	addi	a5,a5,4
    80004222:	0711                	addi	a4,a4,4
    80004224:	fed79ce3          	bne	a5,a3,8000421c <write_head+0x4e>
  }
  bwrite(buf);
    80004228:	8526                	mv	a0,s1
    8000422a:	fffff097          	auipc	ra,0xfffff
    8000422e:	06c080e7          	jalr	108(ra) # 80003296 <bwrite>
  brelse(buf);
    80004232:	8526                	mv	a0,s1
    80004234:	fffff097          	auipc	ra,0xfffff
    80004238:	0a0080e7          	jalr	160(ra) # 800032d4 <brelse>
}
    8000423c:	60e2                	ld	ra,24(sp)
    8000423e:	6442                	ld	s0,16(sp)
    80004240:	64a2                	ld	s1,8(sp)
    80004242:	6902                	ld	s2,0(sp)
    80004244:	6105                	addi	sp,sp,32
    80004246:	8082                	ret

0000000080004248 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004248:	0001e797          	auipc	a5,0x1e
    8000424c:	8c078793          	addi	a5,a5,-1856 # 80021b08 <log>
    80004250:	57dc                	lw	a5,44(a5)
    80004252:	0af05663          	blez	a5,800042fe <install_trans+0xb6>
{
    80004256:	7139                	addi	sp,sp,-64
    80004258:	fc06                	sd	ra,56(sp)
    8000425a:	f822                	sd	s0,48(sp)
    8000425c:	f426                	sd	s1,40(sp)
    8000425e:	f04a                	sd	s2,32(sp)
    80004260:	ec4e                	sd	s3,24(sp)
    80004262:	e852                	sd	s4,16(sp)
    80004264:	e456                	sd	s5,8(sp)
    80004266:	0080                	addi	s0,sp,64
    80004268:	0001ea17          	auipc	s4,0x1e
    8000426c:	8d0a0a13          	addi	s4,s4,-1840 # 80021b38 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004270:	4981                	li	s3,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004272:	0001e917          	auipc	s2,0x1e
    80004276:	89690913          	addi	s2,s2,-1898 # 80021b08 <log>
    8000427a:	01892583          	lw	a1,24(s2)
    8000427e:	013585bb          	addw	a1,a1,s3
    80004282:	2585                	addiw	a1,a1,1
    80004284:	02892503          	lw	a0,40(s2)
    80004288:	fffff097          	auipc	ra,0xfffff
    8000428c:	f0a080e7          	jalr	-246(ra) # 80003192 <bread>
    80004290:	8aaa                	mv	s5,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004292:	000a2583          	lw	a1,0(s4)
    80004296:	02892503          	lw	a0,40(s2)
    8000429a:	fffff097          	auipc	ra,0xfffff
    8000429e:	ef8080e7          	jalr	-264(ra) # 80003192 <bread>
    800042a2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800042a4:	40000613          	li	a2,1024
    800042a8:	058a8593          	addi	a1,s5,88
    800042ac:	05850513          	addi	a0,a0,88
    800042b0:	ffffd097          	auipc	ra,0xffffd
    800042b4:	b1a080e7          	jalr	-1254(ra) # 80000dca <memmove>
    bwrite(dbuf);  // write dst to disk
    800042b8:	8526                	mv	a0,s1
    800042ba:	fffff097          	auipc	ra,0xfffff
    800042be:	fdc080e7          	jalr	-36(ra) # 80003296 <bwrite>
    bunpin(dbuf);
    800042c2:	8526                	mv	a0,s1
    800042c4:	fffff097          	auipc	ra,0xfffff
    800042c8:	0ea080e7          	jalr	234(ra) # 800033ae <bunpin>
    brelse(lbuf);
    800042cc:	8556                	mv	a0,s5
    800042ce:	fffff097          	auipc	ra,0xfffff
    800042d2:	006080e7          	jalr	6(ra) # 800032d4 <brelse>
    brelse(dbuf);
    800042d6:	8526                	mv	a0,s1
    800042d8:	fffff097          	auipc	ra,0xfffff
    800042dc:	ffc080e7          	jalr	-4(ra) # 800032d4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042e0:	2985                	addiw	s3,s3,1
    800042e2:	0a11                	addi	s4,s4,4
    800042e4:	02c92783          	lw	a5,44(s2)
    800042e8:	f8f9c9e3          	blt	s3,a5,8000427a <install_trans+0x32>
}
    800042ec:	70e2                	ld	ra,56(sp)
    800042ee:	7442                	ld	s0,48(sp)
    800042f0:	74a2                	ld	s1,40(sp)
    800042f2:	7902                	ld	s2,32(sp)
    800042f4:	69e2                	ld	s3,24(sp)
    800042f6:	6a42                	ld	s4,16(sp)
    800042f8:	6aa2                	ld	s5,8(sp)
    800042fa:	6121                	addi	sp,sp,64
    800042fc:	8082                	ret
    800042fe:	8082                	ret

0000000080004300 <initlog>:
{
    80004300:	7179                	addi	sp,sp,-48
    80004302:	f406                	sd	ra,40(sp)
    80004304:	f022                	sd	s0,32(sp)
    80004306:	ec26                	sd	s1,24(sp)
    80004308:	e84a                	sd	s2,16(sp)
    8000430a:	e44e                	sd	s3,8(sp)
    8000430c:	1800                	addi	s0,sp,48
    8000430e:	892a                	mv	s2,a0
    80004310:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004312:	0001d497          	auipc	s1,0x1d
    80004316:	7f648493          	addi	s1,s1,2038 # 80021b08 <log>
    8000431a:	00004597          	auipc	a1,0x4
    8000431e:	38658593          	addi	a1,a1,902 # 800086a0 <syscalls+0x200>
    80004322:	8526                	mv	a0,s1
    80004324:	ffffd097          	auipc	ra,0xffffd
    80004328:	8ae080e7          	jalr	-1874(ra) # 80000bd2 <initlock>
  log.start = sb->logstart;
    8000432c:	0149a583          	lw	a1,20(s3)
    80004330:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004332:	0109a783          	lw	a5,16(s3)
    80004336:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004338:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000433c:	854a                	mv	a0,s2
    8000433e:	fffff097          	auipc	ra,0xfffff
    80004342:	e54080e7          	jalr	-428(ra) # 80003192 <bread>
  log.lh.n = lh->n;
    80004346:	4d3c                	lw	a5,88(a0)
    80004348:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000434a:	02f05563          	blez	a5,80004374 <initlog+0x74>
    8000434e:	05c50713          	addi	a4,a0,92
    80004352:	0001d697          	auipc	a3,0x1d
    80004356:	7e668693          	addi	a3,a3,2022 # 80021b38 <log+0x30>
    8000435a:	37fd                	addiw	a5,a5,-1
    8000435c:	1782                	slli	a5,a5,0x20
    8000435e:	9381                	srli	a5,a5,0x20
    80004360:	078a                	slli	a5,a5,0x2
    80004362:	06050613          	addi	a2,a0,96
    80004366:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004368:	4310                	lw	a2,0(a4)
    8000436a:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000436c:	0711                	addi	a4,a4,4
    8000436e:	0691                	addi	a3,a3,4
    80004370:	fef71ce3          	bne	a4,a5,80004368 <initlog+0x68>
  brelse(buf);
    80004374:	fffff097          	auipc	ra,0xfffff
    80004378:	f60080e7          	jalr	-160(ra) # 800032d4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    8000437c:	00000097          	auipc	ra,0x0
    80004380:	ecc080e7          	jalr	-308(ra) # 80004248 <install_trans>
  log.lh.n = 0;
    80004384:	0001d797          	auipc	a5,0x1d
    80004388:	7a07a823          	sw	zero,1968(a5) # 80021b34 <log+0x2c>
  write_head(); // clear the log
    8000438c:	00000097          	auipc	ra,0x0
    80004390:	e42080e7          	jalr	-446(ra) # 800041ce <write_head>
}
    80004394:	70a2                	ld	ra,40(sp)
    80004396:	7402                	ld	s0,32(sp)
    80004398:	64e2                	ld	s1,24(sp)
    8000439a:	6942                	ld	s2,16(sp)
    8000439c:	69a2                	ld	s3,8(sp)
    8000439e:	6145                	addi	sp,sp,48
    800043a0:	8082                	ret

00000000800043a2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800043a2:	1101                	addi	sp,sp,-32
    800043a4:	ec06                	sd	ra,24(sp)
    800043a6:	e822                	sd	s0,16(sp)
    800043a8:	e426                	sd	s1,8(sp)
    800043aa:	e04a                	sd	s2,0(sp)
    800043ac:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800043ae:	0001d517          	auipc	a0,0x1d
    800043b2:	75a50513          	addi	a0,a0,1882 # 80021b08 <log>
    800043b6:	ffffd097          	auipc	ra,0xffffd
    800043ba:	8ac080e7          	jalr	-1876(ra) # 80000c62 <acquire>
  while(1){
    if(log.committing){
    800043be:	0001d497          	auipc	s1,0x1d
    800043c2:	74a48493          	addi	s1,s1,1866 # 80021b08 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043c6:	4979                	li	s2,30
    800043c8:	a039                	j	800043d6 <begin_op+0x34>
      sleep(&log, &log.lock);
    800043ca:	85a6                	mv	a1,s1
    800043cc:	8526                	mv	a0,s1
    800043ce:	ffffe097          	auipc	ra,0xffffe
    800043d2:	196080e7          	jalr	406(ra) # 80002564 <sleep>
    if(log.committing){
    800043d6:	50dc                	lw	a5,36(s1)
    800043d8:	fbed                	bnez	a5,800043ca <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043da:	509c                	lw	a5,32(s1)
    800043dc:	0017871b          	addiw	a4,a5,1
    800043e0:	0007069b          	sext.w	a3,a4
    800043e4:	0027179b          	slliw	a5,a4,0x2
    800043e8:	9fb9                	addw	a5,a5,a4
    800043ea:	0017979b          	slliw	a5,a5,0x1
    800043ee:	54d8                	lw	a4,44(s1)
    800043f0:	9fb9                	addw	a5,a5,a4
    800043f2:	00f95963          	ble	a5,s2,80004404 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800043f6:	85a6                	mv	a1,s1
    800043f8:	8526                	mv	a0,s1
    800043fa:	ffffe097          	auipc	ra,0xffffe
    800043fe:	16a080e7          	jalr	362(ra) # 80002564 <sleep>
    80004402:	bfd1                	j	800043d6 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004404:	0001d517          	auipc	a0,0x1d
    80004408:	70450513          	addi	a0,a0,1796 # 80021b08 <log>
    8000440c:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000440e:	ffffd097          	auipc	ra,0xffffd
    80004412:	908080e7          	jalr	-1784(ra) # 80000d16 <release>
      break;
    }
  }
}
    80004416:	60e2                	ld	ra,24(sp)
    80004418:	6442                	ld	s0,16(sp)
    8000441a:	64a2                	ld	s1,8(sp)
    8000441c:	6902                	ld	s2,0(sp)
    8000441e:	6105                	addi	sp,sp,32
    80004420:	8082                	ret

0000000080004422 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004422:	7139                	addi	sp,sp,-64
    80004424:	fc06                	sd	ra,56(sp)
    80004426:	f822                	sd	s0,48(sp)
    80004428:	f426                	sd	s1,40(sp)
    8000442a:	f04a                	sd	s2,32(sp)
    8000442c:	ec4e                	sd	s3,24(sp)
    8000442e:	e852                	sd	s4,16(sp)
    80004430:	e456                	sd	s5,8(sp)
    80004432:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004434:	0001d917          	auipc	s2,0x1d
    80004438:	6d490913          	addi	s2,s2,1748 # 80021b08 <log>
    8000443c:	854a                	mv	a0,s2
    8000443e:	ffffd097          	auipc	ra,0xffffd
    80004442:	824080e7          	jalr	-2012(ra) # 80000c62 <acquire>
  log.outstanding -= 1;
    80004446:	02092783          	lw	a5,32(s2)
    8000444a:	37fd                	addiw	a5,a5,-1
    8000444c:	0007849b          	sext.w	s1,a5
    80004450:	02f92023          	sw	a5,32(s2)
  if(log.committing)
    80004454:	02492783          	lw	a5,36(s2)
    80004458:	eba1                	bnez	a5,800044a8 <end_op+0x86>
    panic("log.committing");
  if(log.outstanding == 0){
    8000445a:	ecb9                	bnez	s1,800044b8 <end_op+0x96>
    do_commit = 1;
    log.committing = 1;
    8000445c:	0001d917          	auipc	s2,0x1d
    80004460:	6ac90913          	addi	s2,s2,1708 # 80021b08 <log>
    80004464:	4785                	li	a5,1
    80004466:	02f92223          	sw	a5,36(s2)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000446a:	854a                	mv	a0,s2
    8000446c:	ffffd097          	auipc	ra,0xffffd
    80004470:	8aa080e7          	jalr	-1878(ra) # 80000d16 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004474:	02c92783          	lw	a5,44(s2)
    80004478:	06f04763          	bgtz	a5,800044e6 <end_op+0xc4>
    acquire(&log.lock);
    8000447c:	0001d497          	auipc	s1,0x1d
    80004480:	68c48493          	addi	s1,s1,1676 # 80021b08 <log>
    80004484:	8526                	mv	a0,s1
    80004486:	ffffc097          	auipc	ra,0xffffc
    8000448a:	7dc080e7          	jalr	2012(ra) # 80000c62 <acquire>
    log.committing = 0;
    8000448e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004492:	8526                	mv	a0,s1
    80004494:	ffffe097          	auipc	ra,0xffffe
    80004498:	256080e7          	jalr	598(ra) # 800026ea <wakeup>
    release(&log.lock);
    8000449c:	8526                	mv	a0,s1
    8000449e:	ffffd097          	auipc	ra,0xffffd
    800044a2:	878080e7          	jalr	-1928(ra) # 80000d16 <release>
}
    800044a6:	a03d                	j	800044d4 <end_op+0xb2>
    panic("log.committing");
    800044a8:	00004517          	auipc	a0,0x4
    800044ac:	20050513          	addi	a0,a0,512 # 800086a8 <syscalls+0x208>
    800044b0:	ffffc097          	auipc	ra,0xffffc
    800044b4:	0c4080e7          	jalr	196(ra) # 80000574 <panic>
    wakeup(&log);
    800044b8:	0001d497          	auipc	s1,0x1d
    800044bc:	65048493          	addi	s1,s1,1616 # 80021b08 <log>
    800044c0:	8526                	mv	a0,s1
    800044c2:	ffffe097          	auipc	ra,0xffffe
    800044c6:	228080e7          	jalr	552(ra) # 800026ea <wakeup>
  release(&log.lock);
    800044ca:	8526                	mv	a0,s1
    800044cc:	ffffd097          	auipc	ra,0xffffd
    800044d0:	84a080e7          	jalr	-1974(ra) # 80000d16 <release>
}
    800044d4:	70e2                	ld	ra,56(sp)
    800044d6:	7442                	ld	s0,48(sp)
    800044d8:	74a2                	ld	s1,40(sp)
    800044da:	7902                	ld	s2,32(sp)
    800044dc:	69e2                	ld	s3,24(sp)
    800044de:	6a42                	ld	s4,16(sp)
    800044e0:	6aa2                	ld	s5,8(sp)
    800044e2:	6121                	addi	sp,sp,64
    800044e4:	8082                	ret
    800044e6:	0001da17          	auipc	s4,0x1d
    800044ea:	652a0a13          	addi	s4,s4,1618 # 80021b38 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800044ee:	0001d917          	auipc	s2,0x1d
    800044f2:	61a90913          	addi	s2,s2,1562 # 80021b08 <log>
    800044f6:	01892583          	lw	a1,24(s2)
    800044fa:	9da5                	addw	a1,a1,s1
    800044fc:	2585                	addiw	a1,a1,1
    800044fe:	02892503          	lw	a0,40(s2)
    80004502:	fffff097          	auipc	ra,0xfffff
    80004506:	c90080e7          	jalr	-880(ra) # 80003192 <bread>
    8000450a:	89aa                	mv	s3,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000450c:	000a2583          	lw	a1,0(s4)
    80004510:	02892503          	lw	a0,40(s2)
    80004514:	fffff097          	auipc	ra,0xfffff
    80004518:	c7e080e7          	jalr	-898(ra) # 80003192 <bread>
    8000451c:	8aaa                	mv	s5,a0
    memmove(to->data, from->data, BSIZE);
    8000451e:	40000613          	li	a2,1024
    80004522:	05850593          	addi	a1,a0,88
    80004526:	05898513          	addi	a0,s3,88
    8000452a:	ffffd097          	auipc	ra,0xffffd
    8000452e:	8a0080e7          	jalr	-1888(ra) # 80000dca <memmove>
    bwrite(to);  // write the log
    80004532:	854e                	mv	a0,s3
    80004534:	fffff097          	auipc	ra,0xfffff
    80004538:	d62080e7          	jalr	-670(ra) # 80003296 <bwrite>
    brelse(from);
    8000453c:	8556                	mv	a0,s5
    8000453e:	fffff097          	auipc	ra,0xfffff
    80004542:	d96080e7          	jalr	-618(ra) # 800032d4 <brelse>
    brelse(to);
    80004546:	854e                	mv	a0,s3
    80004548:	fffff097          	auipc	ra,0xfffff
    8000454c:	d8c080e7          	jalr	-628(ra) # 800032d4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004550:	2485                	addiw	s1,s1,1
    80004552:	0a11                	addi	s4,s4,4
    80004554:	02c92783          	lw	a5,44(s2)
    80004558:	f8f4cfe3          	blt	s1,a5,800044f6 <end_op+0xd4>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000455c:	00000097          	auipc	ra,0x0
    80004560:	c72080e7          	jalr	-910(ra) # 800041ce <write_head>
    install_trans(); // Now install writes to home locations
    80004564:	00000097          	auipc	ra,0x0
    80004568:	ce4080e7          	jalr	-796(ra) # 80004248 <install_trans>
    log.lh.n = 0;
    8000456c:	0001d797          	auipc	a5,0x1d
    80004570:	5c07a423          	sw	zero,1480(a5) # 80021b34 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004574:	00000097          	auipc	ra,0x0
    80004578:	c5a080e7          	jalr	-934(ra) # 800041ce <write_head>
    8000457c:	b701                	j	8000447c <end_op+0x5a>

000000008000457e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000457e:	1101                	addi	sp,sp,-32
    80004580:	ec06                	sd	ra,24(sp)
    80004582:	e822                	sd	s0,16(sp)
    80004584:	e426                	sd	s1,8(sp)
    80004586:	e04a                	sd	s2,0(sp)
    80004588:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000458a:	0001d797          	auipc	a5,0x1d
    8000458e:	57e78793          	addi	a5,a5,1406 # 80021b08 <log>
    80004592:	57d8                	lw	a4,44(a5)
    80004594:	47f5                	li	a5,29
    80004596:	08e7c563          	blt	a5,a4,80004620 <log_write+0xa2>
    8000459a:	892a                	mv	s2,a0
    8000459c:	0001d797          	auipc	a5,0x1d
    800045a0:	56c78793          	addi	a5,a5,1388 # 80021b08 <log>
    800045a4:	4fdc                	lw	a5,28(a5)
    800045a6:	37fd                	addiw	a5,a5,-1
    800045a8:	06f75c63          	ble	a5,a4,80004620 <log_write+0xa2>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800045ac:	0001d797          	auipc	a5,0x1d
    800045b0:	55c78793          	addi	a5,a5,1372 # 80021b08 <log>
    800045b4:	539c                	lw	a5,32(a5)
    800045b6:	06f05d63          	blez	a5,80004630 <log_write+0xb2>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800045ba:	0001d497          	auipc	s1,0x1d
    800045be:	54e48493          	addi	s1,s1,1358 # 80021b08 <log>
    800045c2:	8526                	mv	a0,s1
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	69e080e7          	jalr	1694(ra) # 80000c62 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800045cc:	54d0                	lw	a2,44(s1)
    800045ce:	0ac05063          	blez	a2,8000466e <log_write+0xf0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800045d2:	00c92583          	lw	a1,12(s2)
    800045d6:	589c                	lw	a5,48(s1)
    800045d8:	0ab78363          	beq	a5,a1,8000467e <log_write+0x100>
    800045dc:	0001d717          	auipc	a4,0x1d
    800045e0:	56070713          	addi	a4,a4,1376 # 80021b3c <log+0x34>
  for (i = 0; i < log.lh.n; i++) {
    800045e4:	4781                	li	a5,0
    800045e6:	2785                	addiw	a5,a5,1
    800045e8:	04c78c63          	beq	a5,a2,80004640 <log_write+0xc2>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800045ec:	4314                	lw	a3,0(a4)
    800045ee:	0711                	addi	a4,a4,4
    800045f0:	feb69be3          	bne	a3,a1,800045e6 <log_write+0x68>
      break;
  }
  log.lh.block[i] = b->blockno;
    800045f4:	07a1                	addi	a5,a5,8
    800045f6:	078a                	slli	a5,a5,0x2
    800045f8:	0001d717          	auipc	a4,0x1d
    800045fc:	51070713          	addi	a4,a4,1296 # 80021b08 <log>
    80004600:	97ba                	add	a5,a5,a4
    80004602:	cb8c                	sw	a1,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    log.lh.n++;
  }
  release(&log.lock);
    80004604:	0001d517          	auipc	a0,0x1d
    80004608:	50450513          	addi	a0,a0,1284 # 80021b08 <log>
    8000460c:	ffffc097          	auipc	ra,0xffffc
    80004610:	70a080e7          	jalr	1802(ra) # 80000d16 <release>
}
    80004614:	60e2                	ld	ra,24(sp)
    80004616:	6442                	ld	s0,16(sp)
    80004618:	64a2                	ld	s1,8(sp)
    8000461a:	6902                	ld	s2,0(sp)
    8000461c:	6105                	addi	sp,sp,32
    8000461e:	8082                	ret
    panic("too big a transaction");
    80004620:	00004517          	auipc	a0,0x4
    80004624:	09850513          	addi	a0,a0,152 # 800086b8 <syscalls+0x218>
    80004628:	ffffc097          	auipc	ra,0xffffc
    8000462c:	f4c080e7          	jalr	-180(ra) # 80000574 <panic>
    panic("log_write outside of trans");
    80004630:	00004517          	auipc	a0,0x4
    80004634:	0a050513          	addi	a0,a0,160 # 800086d0 <syscalls+0x230>
    80004638:	ffffc097          	auipc	ra,0xffffc
    8000463c:	f3c080e7          	jalr	-196(ra) # 80000574 <panic>
  log.lh.block[i] = b->blockno;
    80004640:	0621                	addi	a2,a2,8
    80004642:	060a                	slli	a2,a2,0x2
    80004644:	0001d797          	auipc	a5,0x1d
    80004648:	4c478793          	addi	a5,a5,1220 # 80021b08 <log>
    8000464c:	963e                	add	a2,a2,a5
    8000464e:	00c92783          	lw	a5,12(s2)
    80004652:	ca1c                	sw	a5,16(a2)
    bpin(b);
    80004654:	854a                	mv	a0,s2
    80004656:	fffff097          	auipc	ra,0xfffff
    8000465a:	d1c080e7          	jalr	-740(ra) # 80003372 <bpin>
    log.lh.n++;
    8000465e:	0001d717          	auipc	a4,0x1d
    80004662:	4aa70713          	addi	a4,a4,1194 # 80021b08 <log>
    80004666:	575c                	lw	a5,44(a4)
    80004668:	2785                	addiw	a5,a5,1
    8000466a:	d75c                	sw	a5,44(a4)
    8000466c:	bf61                	j	80004604 <log_write+0x86>
  log.lh.block[i] = b->blockno;
    8000466e:	00c92783          	lw	a5,12(s2)
    80004672:	0001d717          	auipc	a4,0x1d
    80004676:	4cf72323          	sw	a5,1222(a4) # 80021b38 <log+0x30>
  if (i == log.lh.n) {  // Add new block to log?
    8000467a:	f649                	bnez	a2,80004604 <log_write+0x86>
    8000467c:	bfe1                	j	80004654 <log_write+0xd6>
  for (i = 0; i < log.lh.n; i++) {
    8000467e:	4781                	li	a5,0
    80004680:	bf95                	j	800045f4 <log_write+0x76>

0000000080004682 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004682:	1101                	addi	sp,sp,-32
    80004684:	ec06                	sd	ra,24(sp)
    80004686:	e822                	sd	s0,16(sp)
    80004688:	e426                	sd	s1,8(sp)
    8000468a:	e04a                	sd	s2,0(sp)
    8000468c:	1000                	addi	s0,sp,32
    8000468e:	84aa                	mv	s1,a0
    80004690:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004692:	00004597          	auipc	a1,0x4
    80004696:	05e58593          	addi	a1,a1,94 # 800086f0 <syscalls+0x250>
    8000469a:	0521                	addi	a0,a0,8
    8000469c:	ffffc097          	auipc	ra,0xffffc
    800046a0:	536080e7          	jalr	1334(ra) # 80000bd2 <initlock>
  lk->name = name;
    800046a4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800046a8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046ac:	0204a423          	sw	zero,40(s1)
}
    800046b0:	60e2                	ld	ra,24(sp)
    800046b2:	6442                	ld	s0,16(sp)
    800046b4:	64a2                	ld	s1,8(sp)
    800046b6:	6902                	ld	s2,0(sp)
    800046b8:	6105                	addi	sp,sp,32
    800046ba:	8082                	ret

00000000800046bc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800046bc:	1101                	addi	sp,sp,-32
    800046be:	ec06                	sd	ra,24(sp)
    800046c0:	e822                	sd	s0,16(sp)
    800046c2:	e426                	sd	s1,8(sp)
    800046c4:	e04a                	sd	s2,0(sp)
    800046c6:	1000                	addi	s0,sp,32
    800046c8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046ca:	00850913          	addi	s2,a0,8
    800046ce:	854a                	mv	a0,s2
    800046d0:	ffffc097          	auipc	ra,0xffffc
    800046d4:	592080e7          	jalr	1426(ra) # 80000c62 <acquire>
  while (lk->locked) {
    800046d8:	409c                	lw	a5,0(s1)
    800046da:	cb89                	beqz	a5,800046ec <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800046dc:	85ca                	mv	a1,s2
    800046de:	8526                	mv	a0,s1
    800046e0:	ffffe097          	auipc	ra,0xffffe
    800046e4:	e84080e7          	jalr	-380(ra) # 80002564 <sleep>
  while (lk->locked) {
    800046e8:	409c                	lw	a5,0(s1)
    800046ea:	fbed                	bnez	a5,800046dc <acquiresleep+0x20>
  }
  lk->locked = 1;
    800046ec:	4785                	li	a5,1
    800046ee:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800046f0:	ffffd097          	auipc	ra,0xffffd
    800046f4:	3aa080e7          	jalr	938(ra) # 80001a9a <myproc>
    800046f8:	5d1c                	lw	a5,56(a0)
    800046fa:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800046fc:	854a                	mv	a0,s2
    800046fe:	ffffc097          	auipc	ra,0xffffc
    80004702:	618080e7          	jalr	1560(ra) # 80000d16 <release>
}
    80004706:	60e2                	ld	ra,24(sp)
    80004708:	6442                	ld	s0,16(sp)
    8000470a:	64a2                	ld	s1,8(sp)
    8000470c:	6902                	ld	s2,0(sp)
    8000470e:	6105                	addi	sp,sp,32
    80004710:	8082                	ret

0000000080004712 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004712:	1101                	addi	sp,sp,-32
    80004714:	ec06                	sd	ra,24(sp)
    80004716:	e822                	sd	s0,16(sp)
    80004718:	e426                	sd	s1,8(sp)
    8000471a:	e04a                	sd	s2,0(sp)
    8000471c:	1000                	addi	s0,sp,32
    8000471e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004720:	00850913          	addi	s2,a0,8
    80004724:	854a                	mv	a0,s2
    80004726:	ffffc097          	auipc	ra,0xffffc
    8000472a:	53c080e7          	jalr	1340(ra) # 80000c62 <acquire>
  lk->locked = 0;
    8000472e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004732:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004736:	8526                	mv	a0,s1
    80004738:	ffffe097          	auipc	ra,0xffffe
    8000473c:	fb2080e7          	jalr	-78(ra) # 800026ea <wakeup>
  release(&lk->lk);
    80004740:	854a                	mv	a0,s2
    80004742:	ffffc097          	auipc	ra,0xffffc
    80004746:	5d4080e7          	jalr	1492(ra) # 80000d16 <release>
}
    8000474a:	60e2                	ld	ra,24(sp)
    8000474c:	6442                	ld	s0,16(sp)
    8000474e:	64a2                	ld	s1,8(sp)
    80004750:	6902                	ld	s2,0(sp)
    80004752:	6105                	addi	sp,sp,32
    80004754:	8082                	ret

0000000080004756 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004756:	7179                	addi	sp,sp,-48
    80004758:	f406                	sd	ra,40(sp)
    8000475a:	f022                	sd	s0,32(sp)
    8000475c:	ec26                	sd	s1,24(sp)
    8000475e:	e84a                	sd	s2,16(sp)
    80004760:	e44e                	sd	s3,8(sp)
    80004762:	1800                	addi	s0,sp,48
    80004764:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004766:	00850913          	addi	s2,a0,8
    8000476a:	854a                	mv	a0,s2
    8000476c:	ffffc097          	auipc	ra,0xffffc
    80004770:	4f6080e7          	jalr	1270(ra) # 80000c62 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004774:	409c                	lw	a5,0(s1)
    80004776:	ef99                	bnez	a5,80004794 <holdingsleep+0x3e>
    80004778:	4481                	li	s1,0
  release(&lk->lk);
    8000477a:	854a                	mv	a0,s2
    8000477c:	ffffc097          	auipc	ra,0xffffc
    80004780:	59a080e7          	jalr	1434(ra) # 80000d16 <release>
  return r;
}
    80004784:	8526                	mv	a0,s1
    80004786:	70a2                	ld	ra,40(sp)
    80004788:	7402                	ld	s0,32(sp)
    8000478a:	64e2                	ld	s1,24(sp)
    8000478c:	6942                	ld	s2,16(sp)
    8000478e:	69a2                	ld	s3,8(sp)
    80004790:	6145                	addi	sp,sp,48
    80004792:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004794:	0284a983          	lw	s3,40(s1)
    80004798:	ffffd097          	auipc	ra,0xffffd
    8000479c:	302080e7          	jalr	770(ra) # 80001a9a <myproc>
    800047a0:	5d04                	lw	s1,56(a0)
    800047a2:	413484b3          	sub	s1,s1,s3
    800047a6:	0014b493          	seqz	s1,s1
    800047aa:	bfc1                	j	8000477a <holdingsleep+0x24>

00000000800047ac <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800047ac:	1141                	addi	sp,sp,-16
    800047ae:	e406                	sd	ra,8(sp)
    800047b0:	e022                	sd	s0,0(sp)
    800047b2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800047b4:	00004597          	auipc	a1,0x4
    800047b8:	f4c58593          	addi	a1,a1,-180 # 80008700 <syscalls+0x260>
    800047bc:	0001d517          	auipc	a0,0x1d
    800047c0:	49450513          	addi	a0,a0,1172 # 80021c50 <ftable>
    800047c4:	ffffc097          	auipc	ra,0xffffc
    800047c8:	40e080e7          	jalr	1038(ra) # 80000bd2 <initlock>
}
    800047cc:	60a2                	ld	ra,8(sp)
    800047ce:	6402                	ld	s0,0(sp)
    800047d0:	0141                	addi	sp,sp,16
    800047d2:	8082                	ret

00000000800047d4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800047d4:	1101                	addi	sp,sp,-32
    800047d6:	ec06                	sd	ra,24(sp)
    800047d8:	e822                	sd	s0,16(sp)
    800047da:	e426                	sd	s1,8(sp)
    800047dc:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800047de:	0001d517          	auipc	a0,0x1d
    800047e2:	47250513          	addi	a0,a0,1138 # 80021c50 <ftable>
    800047e6:	ffffc097          	auipc	ra,0xffffc
    800047ea:	47c080e7          	jalr	1148(ra) # 80000c62 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
    800047ee:	0001d797          	auipc	a5,0x1d
    800047f2:	46278793          	addi	a5,a5,1122 # 80021c50 <ftable>
    800047f6:	4fdc                	lw	a5,28(a5)
    800047f8:	cb8d                	beqz	a5,8000482a <filealloc+0x56>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047fa:	0001d497          	auipc	s1,0x1d
    800047fe:	49648493          	addi	s1,s1,1174 # 80021c90 <ftable+0x40>
    80004802:	0001e717          	auipc	a4,0x1e
    80004806:	40670713          	addi	a4,a4,1030 # 80022c08 <ftable+0xfb8>
    if(f->ref == 0){
    8000480a:	40dc                	lw	a5,4(s1)
    8000480c:	c39d                	beqz	a5,80004832 <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000480e:	02848493          	addi	s1,s1,40
    80004812:	fee49ce3          	bne	s1,a4,8000480a <filealloc+0x36>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004816:	0001d517          	auipc	a0,0x1d
    8000481a:	43a50513          	addi	a0,a0,1082 # 80021c50 <ftable>
    8000481e:	ffffc097          	auipc	ra,0xffffc
    80004822:	4f8080e7          	jalr	1272(ra) # 80000d16 <release>
  return 0;
    80004826:	4481                	li	s1,0
    80004828:	a839                	j	80004846 <filealloc+0x72>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000482a:	0001d497          	auipc	s1,0x1d
    8000482e:	43e48493          	addi	s1,s1,1086 # 80021c68 <ftable+0x18>
      f->ref = 1;
    80004832:	4785                	li	a5,1
    80004834:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004836:	0001d517          	auipc	a0,0x1d
    8000483a:	41a50513          	addi	a0,a0,1050 # 80021c50 <ftable>
    8000483e:	ffffc097          	auipc	ra,0xffffc
    80004842:	4d8080e7          	jalr	1240(ra) # 80000d16 <release>
}
    80004846:	8526                	mv	a0,s1
    80004848:	60e2                	ld	ra,24(sp)
    8000484a:	6442                	ld	s0,16(sp)
    8000484c:	64a2                	ld	s1,8(sp)
    8000484e:	6105                	addi	sp,sp,32
    80004850:	8082                	ret

0000000080004852 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004852:	1101                	addi	sp,sp,-32
    80004854:	ec06                	sd	ra,24(sp)
    80004856:	e822                	sd	s0,16(sp)
    80004858:	e426                	sd	s1,8(sp)
    8000485a:	1000                	addi	s0,sp,32
    8000485c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000485e:	0001d517          	auipc	a0,0x1d
    80004862:	3f250513          	addi	a0,a0,1010 # 80021c50 <ftable>
    80004866:	ffffc097          	auipc	ra,0xffffc
    8000486a:	3fc080e7          	jalr	1020(ra) # 80000c62 <acquire>
  if(f->ref < 1)
    8000486e:	40dc                	lw	a5,4(s1)
    80004870:	02f05263          	blez	a5,80004894 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004874:	2785                	addiw	a5,a5,1
    80004876:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004878:	0001d517          	auipc	a0,0x1d
    8000487c:	3d850513          	addi	a0,a0,984 # 80021c50 <ftable>
    80004880:	ffffc097          	auipc	ra,0xffffc
    80004884:	496080e7          	jalr	1174(ra) # 80000d16 <release>
  return f;
}
    80004888:	8526                	mv	a0,s1
    8000488a:	60e2                	ld	ra,24(sp)
    8000488c:	6442                	ld	s0,16(sp)
    8000488e:	64a2                	ld	s1,8(sp)
    80004890:	6105                	addi	sp,sp,32
    80004892:	8082                	ret
    panic("filedup");
    80004894:	00004517          	auipc	a0,0x4
    80004898:	e7450513          	addi	a0,a0,-396 # 80008708 <syscalls+0x268>
    8000489c:	ffffc097          	auipc	ra,0xffffc
    800048a0:	cd8080e7          	jalr	-808(ra) # 80000574 <panic>

00000000800048a4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800048a4:	7139                	addi	sp,sp,-64
    800048a6:	fc06                	sd	ra,56(sp)
    800048a8:	f822                	sd	s0,48(sp)
    800048aa:	f426                	sd	s1,40(sp)
    800048ac:	f04a                	sd	s2,32(sp)
    800048ae:	ec4e                	sd	s3,24(sp)
    800048b0:	e852                	sd	s4,16(sp)
    800048b2:	e456                	sd	s5,8(sp)
    800048b4:	0080                	addi	s0,sp,64
    800048b6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800048b8:	0001d517          	auipc	a0,0x1d
    800048bc:	39850513          	addi	a0,a0,920 # 80021c50 <ftable>
    800048c0:	ffffc097          	auipc	ra,0xffffc
    800048c4:	3a2080e7          	jalr	930(ra) # 80000c62 <acquire>
  if(f->ref < 1)
    800048c8:	40dc                	lw	a5,4(s1)
    800048ca:	06f05163          	blez	a5,8000492c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800048ce:	37fd                	addiw	a5,a5,-1
    800048d0:	0007871b          	sext.w	a4,a5
    800048d4:	c0dc                	sw	a5,4(s1)
    800048d6:	06e04363          	bgtz	a4,8000493c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800048da:	0004a903          	lw	s2,0(s1)
    800048de:	0094ca83          	lbu	s5,9(s1)
    800048e2:	0104ba03          	ld	s4,16(s1)
    800048e6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800048ea:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800048ee:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800048f2:	0001d517          	auipc	a0,0x1d
    800048f6:	35e50513          	addi	a0,a0,862 # 80021c50 <ftable>
    800048fa:	ffffc097          	auipc	ra,0xffffc
    800048fe:	41c080e7          	jalr	1052(ra) # 80000d16 <release>

  if(ff.type == FD_PIPE){
    80004902:	4785                	li	a5,1
    80004904:	04f90d63          	beq	s2,a5,8000495e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004908:	3979                	addiw	s2,s2,-2
    8000490a:	4785                	li	a5,1
    8000490c:	0527e063          	bltu	a5,s2,8000494c <fileclose+0xa8>
    begin_op();
    80004910:	00000097          	auipc	ra,0x0
    80004914:	a92080e7          	jalr	-1390(ra) # 800043a2 <begin_op>
    iput(ff.ip);
    80004918:	854e                	mv	a0,s3
    8000491a:	fffff097          	auipc	ra,0xfffff
    8000491e:	27c080e7          	jalr	636(ra) # 80003b96 <iput>
    end_op();
    80004922:	00000097          	auipc	ra,0x0
    80004926:	b00080e7          	jalr	-1280(ra) # 80004422 <end_op>
    8000492a:	a00d                	j	8000494c <fileclose+0xa8>
    panic("fileclose");
    8000492c:	00004517          	auipc	a0,0x4
    80004930:	de450513          	addi	a0,a0,-540 # 80008710 <syscalls+0x270>
    80004934:	ffffc097          	auipc	ra,0xffffc
    80004938:	c40080e7          	jalr	-960(ra) # 80000574 <panic>
    release(&ftable.lock);
    8000493c:	0001d517          	auipc	a0,0x1d
    80004940:	31450513          	addi	a0,a0,788 # 80021c50 <ftable>
    80004944:	ffffc097          	auipc	ra,0xffffc
    80004948:	3d2080e7          	jalr	978(ra) # 80000d16 <release>
  }
}
    8000494c:	70e2                	ld	ra,56(sp)
    8000494e:	7442                	ld	s0,48(sp)
    80004950:	74a2                	ld	s1,40(sp)
    80004952:	7902                	ld	s2,32(sp)
    80004954:	69e2                	ld	s3,24(sp)
    80004956:	6a42                	ld	s4,16(sp)
    80004958:	6aa2                	ld	s5,8(sp)
    8000495a:	6121                	addi	sp,sp,64
    8000495c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000495e:	85d6                	mv	a1,s5
    80004960:	8552                	mv	a0,s4
    80004962:	00000097          	auipc	ra,0x0
    80004966:	364080e7          	jalr	868(ra) # 80004cc6 <pipeclose>
    8000496a:	b7cd                	j	8000494c <fileclose+0xa8>

000000008000496c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000496c:	715d                	addi	sp,sp,-80
    8000496e:	e486                	sd	ra,72(sp)
    80004970:	e0a2                	sd	s0,64(sp)
    80004972:	fc26                	sd	s1,56(sp)
    80004974:	f84a                	sd	s2,48(sp)
    80004976:	f44e                	sd	s3,40(sp)
    80004978:	0880                	addi	s0,sp,80
    8000497a:	84aa                	mv	s1,a0
    8000497c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000497e:	ffffd097          	auipc	ra,0xffffd
    80004982:	11c080e7          	jalr	284(ra) # 80001a9a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004986:	409c                	lw	a5,0(s1)
    80004988:	37f9                	addiw	a5,a5,-2
    8000498a:	4705                	li	a4,1
    8000498c:	04f76763          	bltu	a4,a5,800049da <filestat+0x6e>
    80004990:	892a                	mv	s2,a0
    ilock(f->ip);
    80004992:	6c88                	ld	a0,24(s1)
    80004994:	fffff097          	auipc	ra,0xfffff
    80004998:	046080e7          	jalr	70(ra) # 800039da <ilock>
    stati(f->ip, &st);
    8000499c:	fb840593          	addi	a1,s0,-72
    800049a0:	6c88                	ld	a0,24(s1)
    800049a2:	fffff097          	auipc	ra,0xfffff
    800049a6:	2c4080e7          	jalr	708(ra) # 80003c66 <stati>
    iunlock(f->ip);
    800049aa:	6c88                	ld	a0,24(s1)
    800049ac:	fffff097          	auipc	ra,0xfffff
    800049b0:	0f2080e7          	jalr	242(ra) # 80003a9e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800049b4:	46e1                	li	a3,24
    800049b6:	fb840613          	addi	a2,s0,-72
    800049ba:	85ce                	mv	a1,s3
    800049bc:	05093503          	ld	a0,80(s2)
    800049c0:	ffffd097          	auipc	ra,0xffffd
    800049c4:	d9a080e7          	jalr	-614(ra) # 8000175a <copyout>
    800049c8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800049cc:	60a6                	ld	ra,72(sp)
    800049ce:	6406                	ld	s0,64(sp)
    800049d0:	74e2                	ld	s1,56(sp)
    800049d2:	7942                	ld	s2,48(sp)
    800049d4:	79a2                	ld	s3,40(sp)
    800049d6:	6161                	addi	sp,sp,80
    800049d8:	8082                	ret
  return -1;
    800049da:	557d                	li	a0,-1
    800049dc:	bfc5                	j	800049cc <filestat+0x60>

00000000800049de <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800049de:	7179                	addi	sp,sp,-48
    800049e0:	f406                	sd	ra,40(sp)
    800049e2:	f022                	sd	s0,32(sp)
    800049e4:	ec26                	sd	s1,24(sp)
    800049e6:	e84a                	sd	s2,16(sp)
    800049e8:	e44e                	sd	s3,8(sp)
    800049ea:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800049ec:	00854783          	lbu	a5,8(a0)
    800049f0:	c3d5                	beqz	a5,80004a94 <fileread+0xb6>
    800049f2:	89b2                	mv	s3,a2
    800049f4:	892e                	mv	s2,a1
    800049f6:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    800049f8:	411c                	lw	a5,0(a0)
    800049fa:	4705                	li	a4,1
    800049fc:	04e78963          	beq	a5,a4,80004a4e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a00:	470d                	li	a4,3
    80004a02:	04e78d63          	beq	a5,a4,80004a5c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a06:	4709                	li	a4,2
    80004a08:	06e79e63          	bne	a5,a4,80004a84 <fileread+0xa6>
    ilock(f->ip);
    80004a0c:	6d08                	ld	a0,24(a0)
    80004a0e:	fffff097          	auipc	ra,0xfffff
    80004a12:	fcc080e7          	jalr	-52(ra) # 800039da <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004a16:	874e                	mv	a4,s3
    80004a18:	5094                	lw	a3,32(s1)
    80004a1a:	864a                	mv	a2,s2
    80004a1c:	4585                	li	a1,1
    80004a1e:	6c88                	ld	a0,24(s1)
    80004a20:	fffff097          	auipc	ra,0xfffff
    80004a24:	270080e7          	jalr	624(ra) # 80003c90 <readi>
    80004a28:	892a                	mv	s2,a0
    80004a2a:	00a05563          	blez	a0,80004a34 <fileread+0x56>
      f->off += r;
    80004a2e:	509c                	lw	a5,32(s1)
    80004a30:	9fa9                	addw	a5,a5,a0
    80004a32:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a34:	6c88                	ld	a0,24(s1)
    80004a36:	fffff097          	auipc	ra,0xfffff
    80004a3a:	068080e7          	jalr	104(ra) # 80003a9e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004a3e:	854a                	mv	a0,s2
    80004a40:	70a2                	ld	ra,40(sp)
    80004a42:	7402                	ld	s0,32(sp)
    80004a44:	64e2                	ld	s1,24(sp)
    80004a46:	6942                	ld	s2,16(sp)
    80004a48:	69a2                	ld	s3,8(sp)
    80004a4a:	6145                	addi	sp,sp,48
    80004a4c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a4e:	6908                	ld	a0,16(a0)
    80004a50:	00000097          	auipc	ra,0x0
    80004a54:	416080e7          	jalr	1046(ra) # 80004e66 <piperead>
    80004a58:	892a                	mv	s2,a0
    80004a5a:	b7d5                	j	80004a3e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a5c:	02451783          	lh	a5,36(a0)
    80004a60:	03079693          	slli	a3,a5,0x30
    80004a64:	92c1                	srli	a3,a3,0x30
    80004a66:	4725                	li	a4,9
    80004a68:	02d76863          	bltu	a4,a3,80004a98 <fileread+0xba>
    80004a6c:	0792                	slli	a5,a5,0x4
    80004a6e:	0001d717          	auipc	a4,0x1d
    80004a72:	14270713          	addi	a4,a4,322 # 80021bb0 <devsw>
    80004a76:	97ba                	add	a5,a5,a4
    80004a78:	639c                	ld	a5,0(a5)
    80004a7a:	c38d                	beqz	a5,80004a9c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004a7c:	4505                	li	a0,1
    80004a7e:	9782                	jalr	a5
    80004a80:	892a                	mv	s2,a0
    80004a82:	bf75                	j	80004a3e <fileread+0x60>
    panic("fileread");
    80004a84:	00004517          	auipc	a0,0x4
    80004a88:	c9c50513          	addi	a0,a0,-868 # 80008720 <syscalls+0x280>
    80004a8c:	ffffc097          	auipc	ra,0xffffc
    80004a90:	ae8080e7          	jalr	-1304(ra) # 80000574 <panic>
    return -1;
    80004a94:	597d                	li	s2,-1
    80004a96:	b765                	j	80004a3e <fileread+0x60>
      return -1;
    80004a98:	597d                	li	s2,-1
    80004a9a:	b755                	j	80004a3e <fileread+0x60>
    80004a9c:	597d                	li	s2,-1
    80004a9e:	b745                	j	80004a3e <fileread+0x60>

0000000080004aa0 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004aa0:	00954783          	lbu	a5,9(a0)
    80004aa4:	12078e63          	beqz	a5,80004be0 <filewrite+0x140>
{
    80004aa8:	715d                	addi	sp,sp,-80
    80004aaa:	e486                	sd	ra,72(sp)
    80004aac:	e0a2                	sd	s0,64(sp)
    80004aae:	fc26                	sd	s1,56(sp)
    80004ab0:	f84a                	sd	s2,48(sp)
    80004ab2:	f44e                	sd	s3,40(sp)
    80004ab4:	f052                	sd	s4,32(sp)
    80004ab6:	ec56                	sd	s5,24(sp)
    80004ab8:	e85a                	sd	s6,16(sp)
    80004aba:	e45e                	sd	s7,8(sp)
    80004abc:	e062                	sd	s8,0(sp)
    80004abe:	0880                	addi	s0,sp,80
    80004ac0:	8ab2                	mv	s5,a2
    80004ac2:	8b2e                	mv	s6,a1
    80004ac4:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80004ac6:	411c                	lw	a5,0(a0)
    80004ac8:	4705                	li	a4,1
    80004aca:	02e78263          	beq	a5,a4,80004aee <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ace:	470d                	li	a4,3
    80004ad0:	02e78563          	beq	a5,a4,80004afa <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ad4:	4709                	li	a4,2
    80004ad6:	0ee79d63          	bne	a5,a4,80004bd0 <filewrite+0x130>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004ada:	0ec05763          	blez	a2,80004bc8 <filewrite+0x128>
    int i = 0;
    80004ade:	4901                	li	s2,0
    80004ae0:	6b85                	lui	s7,0x1
    80004ae2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004ae6:	6c05                	lui	s8,0x1
    80004ae8:	c00c0c1b          	addiw	s8,s8,-1024
    80004aec:	a061                	j	80004b74 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    80004aee:	6908                	ld	a0,16(a0)
    80004af0:	00000097          	auipc	ra,0x0
    80004af4:	246080e7          	jalr	582(ra) # 80004d36 <pipewrite>
    80004af8:	a065                	j	80004ba0 <filewrite+0x100>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004afa:	02451783          	lh	a5,36(a0)
    80004afe:	03079693          	slli	a3,a5,0x30
    80004b02:	92c1                	srli	a3,a3,0x30
    80004b04:	4725                	li	a4,9
    80004b06:	0cd76f63          	bltu	a4,a3,80004be4 <filewrite+0x144>
    80004b0a:	0792                	slli	a5,a5,0x4
    80004b0c:	0001d717          	auipc	a4,0x1d
    80004b10:	0a470713          	addi	a4,a4,164 # 80021bb0 <devsw>
    80004b14:	97ba                	add	a5,a5,a4
    80004b16:	679c                	ld	a5,8(a5)
    80004b18:	cbe1                	beqz	a5,80004be8 <filewrite+0x148>
    ret = devsw[f->major].write(1, addr, n);
    80004b1a:	4505                	li	a0,1
    80004b1c:	9782                	jalr	a5
    80004b1e:	a049                	j	80004ba0 <filewrite+0x100>
    80004b20:	00098a1b          	sext.w	s4,s3
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004b24:	00000097          	auipc	ra,0x0
    80004b28:	87e080e7          	jalr	-1922(ra) # 800043a2 <begin_op>
      ilock(f->ip);
    80004b2c:	6c88                	ld	a0,24(s1)
    80004b2e:	fffff097          	auipc	ra,0xfffff
    80004b32:	eac080e7          	jalr	-340(ra) # 800039da <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b36:	8752                	mv	a4,s4
    80004b38:	5094                	lw	a3,32(s1)
    80004b3a:	01690633          	add	a2,s2,s6
    80004b3e:	4585                	li	a1,1
    80004b40:	6c88                	ld	a0,24(s1)
    80004b42:	fffff097          	auipc	ra,0xfffff
    80004b46:	244080e7          	jalr	580(ra) # 80003d86 <writei>
    80004b4a:	89aa                	mv	s3,a0
    80004b4c:	02a05c63          	blez	a0,80004b84 <filewrite+0xe4>
        f->off += r;
    80004b50:	509c                	lw	a5,32(s1)
    80004b52:	9fa9                	addw	a5,a5,a0
    80004b54:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004b56:	6c88                	ld	a0,24(s1)
    80004b58:	fffff097          	auipc	ra,0xfffff
    80004b5c:	f46080e7          	jalr	-186(ra) # 80003a9e <iunlock>
      end_op();
    80004b60:	00000097          	auipc	ra,0x0
    80004b64:	8c2080e7          	jalr	-1854(ra) # 80004422 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004b68:	05499863          	bne	s3,s4,80004bb8 <filewrite+0x118>
        panic("short filewrite");
      i += r;
    80004b6c:	012a093b          	addw	s2,s4,s2
    while(i < n){
    80004b70:	03595563          	ble	s5,s2,80004b9a <filewrite+0xfa>
      int n1 = n - i;
    80004b74:	412a87bb          	subw	a5,s5,s2
      if(n1 > max)
    80004b78:	89be                	mv	s3,a5
    80004b7a:	2781                	sext.w	a5,a5
    80004b7c:	fafbd2e3          	ble	a5,s7,80004b20 <filewrite+0x80>
    80004b80:	89e2                	mv	s3,s8
    80004b82:	bf79                	j	80004b20 <filewrite+0x80>
      iunlock(f->ip);
    80004b84:	6c88                	ld	a0,24(s1)
    80004b86:	fffff097          	auipc	ra,0xfffff
    80004b8a:	f18080e7          	jalr	-232(ra) # 80003a9e <iunlock>
      end_op();
    80004b8e:	00000097          	auipc	ra,0x0
    80004b92:	894080e7          	jalr	-1900(ra) # 80004422 <end_op>
      if(r < 0)
    80004b96:	fc09d9e3          	bgez	s3,80004b68 <filewrite+0xc8>
    }
    ret = (i == n ? n : -1);
    80004b9a:	8556                	mv	a0,s5
    80004b9c:	032a9863          	bne	s5,s2,80004bcc <filewrite+0x12c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ba0:	60a6                	ld	ra,72(sp)
    80004ba2:	6406                	ld	s0,64(sp)
    80004ba4:	74e2                	ld	s1,56(sp)
    80004ba6:	7942                	ld	s2,48(sp)
    80004ba8:	79a2                	ld	s3,40(sp)
    80004baa:	7a02                	ld	s4,32(sp)
    80004bac:	6ae2                	ld	s5,24(sp)
    80004bae:	6b42                	ld	s6,16(sp)
    80004bb0:	6ba2                	ld	s7,8(sp)
    80004bb2:	6c02                	ld	s8,0(sp)
    80004bb4:	6161                	addi	sp,sp,80
    80004bb6:	8082                	ret
        panic("short filewrite");
    80004bb8:	00004517          	auipc	a0,0x4
    80004bbc:	b7850513          	addi	a0,a0,-1160 # 80008730 <syscalls+0x290>
    80004bc0:	ffffc097          	auipc	ra,0xffffc
    80004bc4:	9b4080e7          	jalr	-1612(ra) # 80000574 <panic>
    int i = 0;
    80004bc8:	4901                	li	s2,0
    80004bca:	bfc1                	j	80004b9a <filewrite+0xfa>
    ret = (i == n ? n : -1);
    80004bcc:	557d                	li	a0,-1
    80004bce:	bfc9                	j	80004ba0 <filewrite+0x100>
    panic("filewrite");
    80004bd0:	00004517          	auipc	a0,0x4
    80004bd4:	b7050513          	addi	a0,a0,-1168 # 80008740 <syscalls+0x2a0>
    80004bd8:	ffffc097          	auipc	ra,0xffffc
    80004bdc:	99c080e7          	jalr	-1636(ra) # 80000574 <panic>
    return -1;
    80004be0:	557d                	li	a0,-1
}
    80004be2:	8082                	ret
      return -1;
    80004be4:	557d                	li	a0,-1
    80004be6:	bf6d                	j	80004ba0 <filewrite+0x100>
    80004be8:	557d                	li	a0,-1
    80004bea:	bf5d                	j	80004ba0 <filewrite+0x100>

0000000080004bec <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004bec:	7179                	addi	sp,sp,-48
    80004bee:	f406                	sd	ra,40(sp)
    80004bf0:	f022                	sd	s0,32(sp)
    80004bf2:	ec26                	sd	s1,24(sp)
    80004bf4:	e84a                	sd	s2,16(sp)
    80004bf6:	e44e                	sd	s3,8(sp)
    80004bf8:	e052                	sd	s4,0(sp)
    80004bfa:	1800                	addi	s0,sp,48
    80004bfc:	84aa                	mv	s1,a0
    80004bfe:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c00:	0005b023          	sd	zero,0(a1)
    80004c04:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c08:	00000097          	auipc	ra,0x0
    80004c0c:	bcc080e7          	jalr	-1076(ra) # 800047d4 <filealloc>
    80004c10:	e088                	sd	a0,0(s1)
    80004c12:	c551                	beqz	a0,80004c9e <pipealloc+0xb2>
    80004c14:	00000097          	auipc	ra,0x0
    80004c18:	bc0080e7          	jalr	-1088(ra) # 800047d4 <filealloc>
    80004c1c:	00a93023          	sd	a0,0(s2)
    80004c20:	c92d                	beqz	a0,80004c92 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004c22:	ffffc097          	auipc	ra,0xffffc
    80004c26:	f50080e7          	jalr	-176(ra) # 80000b72 <kalloc>
    80004c2a:	89aa                	mv	s3,a0
    80004c2c:	c125                	beqz	a0,80004c8c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004c2e:	4a05                	li	s4,1
    80004c30:	23452023          	sw	s4,544(a0)
  pi->writeopen = 1;
    80004c34:	23452223          	sw	s4,548(a0)
  pi->nwrite = 0;
    80004c38:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004c3c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004c40:	00004597          	auipc	a1,0x4
    80004c44:	b1058593          	addi	a1,a1,-1264 # 80008750 <syscalls+0x2b0>
    80004c48:	ffffc097          	auipc	ra,0xffffc
    80004c4c:	f8a080e7          	jalr	-118(ra) # 80000bd2 <initlock>
  (*f0)->type = FD_PIPE;
    80004c50:	609c                	ld	a5,0(s1)
    80004c52:	0147a023          	sw	s4,0(a5)
  (*f0)->readable = 1;
    80004c56:	609c                	ld	a5,0(s1)
    80004c58:	01478423          	sb	s4,8(a5)
  (*f0)->writable = 0;
    80004c5c:	609c                	ld	a5,0(s1)
    80004c5e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c62:	609c                	ld	a5,0(s1)
    80004c64:	0137b823          	sd	s3,16(a5)
  (*f1)->type = FD_PIPE;
    80004c68:	00093783          	ld	a5,0(s2)
    80004c6c:	0147a023          	sw	s4,0(a5)
  (*f1)->readable = 0;
    80004c70:	00093783          	ld	a5,0(s2)
    80004c74:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c78:	00093783          	ld	a5,0(s2)
    80004c7c:	014784a3          	sb	s4,9(a5)
  (*f1)->pipe = pi;
    80004c80:	00093783          	ld	a5,0(s2)
    80004c84:	0137b823          	sd	s3,16(a5)
  return 0;
    80004c88:	4501                	li	a0,0
    80004c8a:	a025                	j	80004cb2 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c8c:	6088                	ld	a0,0(s1)
    80004c8e:	e501                	bnez	a0,80004c96 <pipealloc+0xaa>
    80004c90:	a039                	j	80004c9e <pipealloc+0xb2>
    80004c92:	6088                	ld	a0,0(s1)
    80004c94:	c51d                	beqz	a0,80004cc2 <pipealloc+0xd6>
    fileclose(*f0);
    80004c96:	00000097          	auipc	ra,0x0
    80004c9a:	c0e080e7          	jalr	-1010(ra) # 800048a4 <fileclose>
  if(*f1)
    80004c9e:	00093783          	ld	a5,0(s2)
    fileclose(*f1);
  return -1;
    80004ca2:	557d                	li	a0,-1
  if(*f1)
    80004ca4:	c799                	beqz	a5,80004cb2 <pipealloc+0xc6>
    fileclose(*f1);
    80004ca6:	853e                	mv	a0,a5
    80004ca8:	00000097          	auipc	ra,0x0
    80004cac:	bfc080e7          	jalr	-1028(ra) # 800048a4 <fileclose>
  return -1;
    80004cb0:	557d                	li	a0,-1
}
    80004cb2:	70a2                	ld	ra,40(sp)
    80004cb4:	7402                	ld	s0,32(sp)
    80004cb6:	64e2                	ld	s1,24(sp)
    80004cb8:	6942                	ld	s2,16(sp)
    80004cba:	69a2                	ld	s3,8(sp)
    80004cbc:	6a02                	ld	s4,0(sp)
    80004cbe:	6145                	addi	sp,sp,48
    80004cc0:	8082                	ret
  return -1;
    80004cc2:	557d                	li	a0,-1
    80004cc4:	b7fd                	j	80004cb2 <pipealloc+0xc6>

0000000080004cc6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004cc6:	1101                	addi	sp,sp,-32
    80004cc8:	ec06                	sd	ra,24(sp)
    80004cca:	e822                	sd	s0,16(sp)
    80004ccc:	e426                	sd	s1,8(sp)
    80004cce:	e04a                	sd	s2,0(sp)
    80004cd0:	1000                	addi	s0,sp,32
    80004cd2:	84aa                	mv	s1,a0
    80004cd4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004cd6:	ffffc097          	auipc	ra,0xffffc
    80004cda:	f8c080e7          	jalr	-116(ra) # 80000c62 <acquire>
  if(writable){
    80004cde:	02090d63          	beqz	s2,80004d18 <pipeclose+0x52>
    pi->writeopen = 0;
    80004ce2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004ce6:	21848513          	addi	a0,s1,536
    80004cea:	ffffe097          	auipc	ra,0xffffe
    80004cee:	a00080e7          	jalr	-1536(ra) # 800026ea <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004cf2:	2204b783          	ld	a5,544(s1)
    80004cf6:	eb95                	bnez	a5,80004d2a <pipeclose+0x64>
    release(&pi->lock);
    80004cf8:	8526                	mv	a0,s1
    80004cfa:	ffffc097          	auipc	ra,0xffffc
    80004cfe:	01c080e7          	jalr	28(ra) # 80000d16 <release>
    kfree((char*)pi);
    80004d02:	8526                	mv	a0,s1
    80004d04:	ffffc097          	auipc	ra,0xffffc
    80004d08:	d6e080e7          	jalr	-658(ra) # 80000a72 <kfree>
  } else
    release(&pi->lock);
}
    80004d0c:	60e2                	ld	ra,24(sp)
    80004d0e:	6442                	ld	s0,16(sp)
    80004d10:	64a2                	ld	s1,8(sp)
    80004d12:	6902                	ld	s2,0(sp)
    80004d14:	6105                	addi	sp,sp,32
    80004d16:	8082                	ret
    pi->readopen = 0;
    80004d18:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004d1c:	21c48513          	addi	a0,s1,540
    80004d20:	ffffe097          	auipc	ra,0xffffe
    80004d24:	9ca080e7          	jalr	-1590(ra) # 800026ea <wakeup>
    80004d28:	b7e9                	j	80004cf2 <pipeclose+0x2c>
    release(&pi->lock);
    80004d2a:	8526                	mv	a0,s1
    80004d2c:	ffffc097          	auipc	ra,0xffffc
    80004d30:	fea080e7          	jalr	-22(ra) # 80000d16 <release>
}
    80004d34:	bfe1                	j	80004d0c <pipeclose+0x46>

0000000080004d36 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004d36:	7119                	addi	sp,sp,-128
    80004d38:	fc86                	sd	ra,120(sp)
    80004d3a:	f8a2                	sd	s0,112(sp)
    80004d3c:	f4a6                	sd	s1,104(sp)
    80004d3e:	f0ca                	sd	s2,96(sp)
    80004d40:	ecce                	sd	s3,88(sp)
    80004d42:	e8d2                	sd	s4,80(sp)
    80004d44:	e4d6                	sd	s5,72(sp)
    80004d46:	e0da                	sd	s6,64(sp)
    80004d48:	fc5e                	sd	s7,56(sp)
    80004d4a:	f862                	sd	s8,48(sp)
    80004d4c:	f466                	sd	s9,40(sp)
    80004d4e:	f06a                	sd	s10,32(sp)
    80004d50:	ec6e                	sd	s11,24(sp)
    80004d52:	0100                	addi	s0,sp,128
    80004d54:	84aa                	mv	s1,a0
    80004d56:	8d2e                	mv	s10,a1
    80004d58:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004d5a:	ffffd097          	auipc	ra,0xffffd
    80004d5e:	d40080e7          	jalr	-704(ra) # 80001a9a <myproc>
    80004d62:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004d64:	8526                	mv	a0,s1
    80004d66:	ffffc097          	auipc	ra,0xffffc
    80004d6a:	efc080e7          	jalr	-260(ra) # 80000c62 <acquire>
  for(i = 0; i < n; i++){
    80004d6e:	0d605f63          	blez	s6,80004e4c <pipewrite+0x116>
    80004d72:	89a6                	mv	s3,s1
    80004d74:	3b7d                	addiw	s6,s6,-1
    80004d76:	1b02                	slli	s6,s6,0x20
    80004d78:	020b5b13          	srli	s6,s6,0x20
    80004d7c:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004d7e:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d82:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d86:	5dfd                	li	s11,-1
    80004d88:	000b8c9b          	sext.w	s9,s7
    80004d8c:	8c66                	mv	s8,s9
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004d8e:	2184a783          	lw	a5,536(s1)
    80004d92:	21c4a703          	lw	a4,540(s1)
    80004d96:	2007879b          	addiw	a5,a5,512
    80004d9a:	06f71763          	bne	a4,a5,80004e08 <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004d9e:	2204a783          	lw	a5,544(s1)
    80004da2:	cf8d                	beqz	a5,80004ddc <pipewrite+0xa6>
    80004da4:	03092783          	lw	a5,48(s2)
    80004da8:	eb95                	bnez	a5,80004ddc <pipewrite+0xa6>
      wakeup(&pi->nread);
    80004daa:	8556                	mv	a0,s5
    80004dac:	ffffe097          	auipc	ra,0xffffe
    80004db0:	93e080e7          	jalr	-1730(ra) # 800026ea <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004db4:	85ce                	mv	a1,s3
    80004db6:	8552                	mv	a0,s4
    80004db8:	ffffd097          	auipc	ra,0xffffd
    80004dbc:	7ac080e7          	jalr	1964(ra) # 80002564 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004dc0:	2184a783          	lw	a5,536(s1)
    80004dc4:	21c4a703          	lw	a4,540(s1)
    80004dc8:	2007879b          	addiw	a5,a5,512
    80004dcc:	02f71e63          	bne	a4,a5,80004e08 <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004dd0:	2204a783          	lw	a5,544(s1)
    80004dd4:	c781                	beqz	a5,80004ddc <pipewrite+0xa6>
    80004dd6:	03092783          	lw	a5,48(s2)
    80004dda:	dbe1                	beqz	a5,80004daa <pipewrite+0x74>
        release(&pi->lock);
    80004ddc:	8526                	mv	a0,s1
    80004dde:	ffffc097          	auipc	ra,0xffffc
    80004de2:	f38080e7          	jalr	-200(ra) # 80000d16 <release>
        return -1;
    80004de6:	5c7d                	li	s8,-1
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004de8:	8562                	mv	a0,s8
    80004dea:	70e6                	ld	ra,120(sp)
    80004dec:	7446                	ld	s0,112(sp)
    80004dee:	74a6                	ld	s1,104(sp)
    80004df0:	7906                	ld	s2,96(sp)
    80004df2:	69e6                	ld	s3,88(sp)
    80004df4:	6a46                	ld	s4,80(sp)
    80004df6:	6aa6                	ld	s5,72(sp)
    80004df8:	6b06                	ld	s6,64(sp)
    80004dfa:	7be2                	ld	s7,56(sp)
    80004dfc:	7c42                	ld	s8,48(sp)
    80004dfe:	7ca2                	ld	s9,40(sp)
    80004e00:	7d02                	ld	s10,32(sp)
    80004e02:	6de2                	ld	s11,24(sp)
    80004e04:	6109                	addi	sp,sp,128
    80004e06:	8082                	ret
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e08:	4685                	li	a3,1
    80004e0a:	01ab8633          	add	a2,s7,s10
    80004e0e:	f8f40593          	addi	a1,s0,-113
    80004e12:	05093503          	ld	a0,80(s2)
    80004e16:	ffffd097          	auipc	ra,0xffffd
    80004e1a:	9d0080e7          	jalr	-1584(ra) # 800017e6 <copyin>
    80004e1e:	03b50863          	beq	a0,s11,80004e4e <pipewrite+0x118>
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004e22:	21c4a783          	lw	a5,540(s1)
    80004e26:	0017871b          	addiw	a4,a5,1
    80004e2a:	20e4ae23          	sw	a4,540(s1)
    80004e2e:	1ff7f793          	andi	a5,a5,511
    80004e32:	97a6                	add	a5,a5,s1
    80004e34:	f8f44703          	lbu	a4,-113(s0)
    80004e38:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004e3c:	001c8c1b          	addiw	s8,s9,1
    80004e40:	001b8793          	addi	a5,s7,1
    80004e44:	016b8563          	beq	s7,s6,80004e4e <pipewrite+0x118>
    80004e48:	8bbe                	mv	s7,a5
    80004e4a:	bf3d                	j	80004d88 <pipewrite+0x52>
    80004e4c:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004e4e:	21848513          	addi	a0,s1,536
    80004e52:	ffffe097          	auipc	ra,0xffffe
    80004e56:	898080e7          	jalr	-1896(ra) # 800026ea <wakeup>
  release(&pi->lock);
    80004e5a:	8526                	mv	a0,s1
    80004e5c:	ffffc097          	auipc	ra,0xffffc
    80004e60:	eba080e7          	jalr	-326(ra) # 80000d16 <release>
  return i;
    80004e64:	b751                	j	80004de8 <pipewrite+0xb2>

0000000080004e66 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e66:	715d                	addi	sp,sp,-80
    80004e68:	e486                	sd	ra,72(sp)
    80004e6a:	e0a2                	sd	s0,64(sp)
    80004e6c:	fc26                	sd	s1,56(sp)
    80004e6e:	f84a                	sd	s2,48(sp)
    80004e70:	f44e                	sd	s3,40(sp)
    80004e72:	f052                	sd	s4,32(sp)
    80004e74:	ec56                	sd	s5,24(sp)
    80004e76:	e85a                	sd	s6,16(sp)
    80004e78:	0880                	addi	s0,sp,80
    80004e7a:	84aa                	mv	s1,a0
    80004e7c:	89ae                	mv	s3,a1
    80004e7e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e80:	ffffd097          	auipc	ra,0xffffd
    80004e84:	c1a080e7          	jalr	-998(ra) # 80001a9a <myproc>
    80004e88:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e8a:	8526                	mv	a0,s1
    80004e8c:	ffffc097          	auipc	ra,0xffffc
    80004e90:	dd6080e7          	jalr	-554(ra) # 80000c62 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e94:	2184a703          	lw	a4,536(s1)
    80004e98:	21c4a783          	lw	a5,540(s1)
    80004e9c:	06f71b63          	bne	a4,a5,80004f12 <piperead+0xac>
    80004ea0:	8926                	mv	s2,s1
    80004ea2:	2244a783          	lw	a5,548(s1)
    80004ea6:	cf9d                	beqz	a5,80004ee4 <piperead+0x7e>
    if(pr->killed){
    80004ea8:	030a2783          	lw	a5,48(s4)
    80004eac:	e78d                	bnez	a5,80004ed6 <piperead+0x70>
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004eae:	21848b13          	addi	s6,s1,536
    80004eb2:	85ca                	mv	a1,s2
    80004eb4:	855a                	mv	a0,s6
    80004eb6:	ffffd097          	auipc	ra,0xffffd
    80004eba:	6ae080e7          	jalr	1710(ra) # 80002564 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ebe:	2184a703          	lw	a4,536(s1)
    80004ec2:	21c4a783          	lw	a5,540(s1)
    80004ec6:	04f71663          	bne	a4,a5,80004f12 <piperead+0xac>
    80004eca:	2244a783          	lw	a5,548(s1)
    80004ece:	cb99                	beqz	a5,80004ee4 <piperead+0x7e>
    if(pr->killed){
    80004ed0:	030a2783          	lw	a5,48(s4)
    80004ed4:	dff9                	beqz	a5,80004eb2 <piperead+0x4c>
      release(&pi->lock);
    80004ed6:	8526                	mv	a0,s1
    80004ed8:	ffffc097          	auipc	ra,0xffffc
    80004edc:	e3e080e7          	jalr	-450(ra) # 80000d16 <release>
      return -1;
    80004ee0:	597d                	li	s2,-1
    80004ee2:	a829                	j	80004efc <piperead+0x96>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(pi->nread == pi->nwrite)
    80004ee4:	4901                	li	s2,0
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ee6:	21c48513          	addi	a0,s1,540
    80004eea:	ffffe097          	auipc	ra,0xffffe
    80004eee:	800080e7          	jalr	-2048(ra) # 800026ea <wakeup>
  release(&pi->lock);
    80004ef2:	8526                	mv	a0,s1
    80004ef4:	ffffc097          	auipc	ra,0xffffc
    80004ef8:	e22080e7          	jalr	-478(ra) # 80000d16 <release>
  return i;
}
    80004efc:	854a                	mv	a0,s2
    80004efe:	60a6                	ld	ra,72(sp)
    80004f00:	6406                	ld	s0,64(sp)
    80004f02:	74e2                	ld	s1,56(sp)
    80004f04:	7942                	ld	s2,48(sp)
    80004f06:	79a2                	ld	s3,40(sp)
    80004f08:	7a02                	ld	s4,32(sp)
    80004f0a:	6ae2                	ld	s5,24(sp)
    80004f0c:	6b42                	ld	s6,16(sp)
    80004f0e:	6161                	addi	sp,sp,80
    80004f10:	8082                	ret
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f12:	4901                	li	s2,0
    80004f14:	fd5059e3          	blez	s5,80004ee6 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004f18:	2184a783          	lw	a5,536(s1)
    80004f1c:	4901                	li	s2,0
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f1e:	5b7d                	li	s6,-1
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004f20:	0017871b          	addiw	a4,a5,1
    80004f24:	20e4ac23          	sw	a4,536(s1)
    80004f28:	1ff7f793          	andi	a5,a5,511
    80004f2c:	97a6                	add	a5,a5,s1
    80004f2e:	0187c783          	lbu	a5,24(a5)
    80004f32:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f36:	4685                	li	a3,1
    80004f38:	fbf40613          	addi	a2,s0,-65
    80004f3c:	85ce                	mv	a1,s3
    80004f3e:	050a3503          	ld	a0,80(s4)
    80004f42:	ffffd097          	auipc	ra,0xffffd
    80004f46:	818080e7          	jalr	-2024(ra) # 8000175a <copyout>
    80004f4a:	f9650ee3          	beq	a0,s6,80004ee6 <piperead+0x80>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f4e:	2905                	addiw	s2,s2,1
    80004f50:	f92a8be3          	beq	s5,s2,80004ee6 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004f54:	2184a783          	lw	a5,536(s1)
    80004f58:	0985                	addi	s3,s3,1
    80004f5a:	21c4a703          	lw	a4,540(s1)
    80004f5e:	fcf711e3          	bne	a4,a5,80004f20 <piperead+0xba>
    80004f62:	b751                	j	80004ee6 <piperead+0x80>

0000000080004f64 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004f64:	de010113          	addi	sp,sp,-544
    80004f68:	20113c23          	sd	ra,536(sp)
    80004f6c:	20813823          	sd	s0,528(sp)
    80004f70:	20913423          	sd	s1,520(sp)
    80004f74:	21213023          	sd	s2,512(sp)
    80004f78:	ffce                	sd	s3,504(sp)
    80004f7a:	fbd2                	sd	s4,496(sp)
    80004f7c:	f7d6                	sd	s5,488(sp)
    80004f7e:	f3da                	sd	s6,480(sp)
    80004f80:	efde                	sd	s7,472(sp)
    80004f82:	ebe2                	sd	s8,464(sp)
    80004f84:	e7e6                	sd	s9,456(sp)
    80004f86:	e3ea                	sd	s10,448(sp)
    80004f88:	ff6e                	sd	s11,440(sp)
    80004f8a:	1400                	addi	s0,sp,544
    80004f8c:	892a                	mv	s2,a0
    80004f8e:	dea43823          	sd	a0,-528(s0)
    80004f92:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f96:	ffffd097          	auipc	ra,0xffffd
    80004f9a:	b04080e7          	jalr	-1276(ra) # 80001a9a <myproc>
    80004f9e:	84aa                	mv	s1,a0

  begin_op();
    80004fa0:	fffff097          	auipc	ra,0xfffff
    80004fa4:	402080e7          	jalr	1026(ra) # 800043a2 <begin_op>

  if((ip = namei(path)) == 0){
    80004fa8:	854a                	mv	a0,s2
    80004faa:	fffff097          	auipc	ra,0xfffff
    80004fae:	1ea080e7          	jalr	490(ra) # 80004194 <namei>
    80004fb2:	c93d                	beqz	a0,80005028 <exec+0xc4>
    80004fb4:	892a                	mv	s2,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004fb6:	fffff097          	auipc	ra,0xfffff
    80004fba:	a24080e7          	jalr	-1500(ra) # 800039da <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004fbe:	04000713          	li	a4,64
    80004fc2:	4681                	li	a3,0
    80004fc4:	e4840613          	addi	a2,s0,-440
    80004fc8:	4581                	li	a1,0
    80004fca:	854a                	mv	a0,s2
    80004fcc:	fffff097          	auipc	ra,0xfffff
    80004fd0:	cc4080e7          	jalr	-828(ra) # 80003c90 <readi>
    80004fd4:	04000793          	li	a5,64
    80004fd8:	00f51a63          	bne	a0,a5,80004fec <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004fdc:	e4842703          	lw	a4,-440(s0)
    80004fe0:	464c47b7          	lui	a5,0x464c4
    80004fe4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004fe8:	04f70663          	beq	a4,a5,80005034 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004fec:	854a                	mv	a0,s2
    80004fee:	fffff097          	auipc	ra,0xfffff
    80004ff2:	c50080e7          	jalr	-944(ra) # 80003c3e <iunlockput>
    end_op();
    80004ff6:	fffff097          	auipc	ra,0xfffff
    80004ffa:	42c080e7          	jalr	1068(ra) # 80004422 <end_op>
  }
  return -1;
    80004ffe:	557d                	li	a0,-1
}
    80005000:	21813083          	ld	ra,536(sp)
    80005004:	21013403          	ld	s0,528(sp)
    80005008:	20813483          	ld	s1,520(sp)
    8000500c:	20013903          	ld	s2,512(sp)
    80005010:	79fe                	ld	s3,504(sp)
    80005012:	7a5e                	ld	s4,496(sp)
    80005014:	7abe                	ld	s5,488(sp)
    80005016:	7b1e                	ld	s6,480(sp)
    80005018:	6bfe                	ld	s7,472(sp)
    8000501a:	6c5e                	ld	s8,464(sp)
    8000501c:	6cbe                	ld	s9,456(sp)
    8000501e:	6d1e                	ld	s10,448(sp)
    80005020:	7dfa                	ld	s11,440(sp)
    80005022:	22010113          	addi	sp,sp,544
    80005026:	8082                	ret
    end_op();
    80005028:	fffff097          	auipc	ra,0xfffff
    8000502c:	3fa080e7          	jalr	1018(ra) # 80004422 <end_op>
    return -1;
    80005030:	557d                	li	a0,-1
    80005032:	b7f9                	j	80005000 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005034:	8526                	mv	a0,s1
    80005036:	ffffd097          	auipc	ra,0xffffd
    8000503a:	b2a080e7          	jalr	-1238(ra) # 80001b60 <proc_pagetable>
    8000503e:	e0a43423          	sd	a0,-504(s0)
    80005042:	d54d                	beqz	a0,80004fec <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005044:	e6842983          	lw	s3,-408(s0)
    80005048:	e8045783          	lhu	a5,-384(s0)
    8000504c:	c7ad                	beqz	a5,800050b6 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000504e:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005050:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80005052:	6c05                	lui	s8,0x1
    80005054:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    80005058:	def43423          	sd	a5,-536(s0)
    8000505c:	7cfd                	lui	s9,0xfffff
    8000505e:	a485                	j	800052be <exec+0x35a>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005060:	00003517          	auipc	a0,0x3
    80005064:	6f850513          	addi	a0,a0,1784 # 80008758 <syscalls+0x2b8>
    80005068:	ffffb097          	auipc	ra,0xffffb
    8000506c:	50c080e7          	jalr	1292(ra) # 80000574 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005070:	8756                	mv	a4,s5
    80005072:	009d86bb          	addw	a3,s11,s1
    80005076:	4581                	li	a1,0
    80005078:	854a                	mv	a0,s2
    8000507a:	fffff097          	auipc	ra,0xfffff
    8000507e:	c16080e7          	jalr	-1002(ra) # 80003c90 <readi>
    80005082:	2501                	sext.w	a0,a0
    80005084:	1eaa9363          	bne	s5,a0,8000526a <exec+0x306>
  for(i = 0; i < sz; i += PGSIZE){
    80005088:	6785                	lui	a5,0x1
    8000508a:	9cbd                	addw	s1,s1,a5
    8000508c:	014c8a3b          	addw	s4,s9,s4
    80005090:	2174fe63          	bleu	s7,s1,800052ac <exec+0x348>
    pa = walkaddr(pagetable, va + i);
    80005094:	02049593          	slli	a1,s1,0x20
    80005098:	9181                	srli	a1,a1,0x20
    8000509a:	95ea                	add	a1,a1,s10
    8000509c:	e0843503          	ld	a0,-504(s0)
    800050a0:	ffffc097          	auipc	ra,0xffffc
    800050a4:	07c080e7          	jalr	124(ra) # 8000111c <walkaddr>
    800050a8:	862a                	mv	a2,a0
    if(pa == 0)
    800050aa:	d95d                	beqz	a0,80005060 <exec+0xfc>
      n = PGSIZE;
    800050ac:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    800050ae:	fd8a71e3          	bleu	s8,s4,80005070 <exec+0x10c>
      n = sz - i;
    800050b2:	8ad2                	mv	s5,s4
    800050b4:	bf75                	j	80005070 <exec+0x10c>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800050b6:	4481                	li	s1,0
  iunlockput(ip);
    800050b8:	854a                	mv	a0,s2
    800050ba:	fffff097          	auipc	ra,0xfffff
    800050be:	b84080e7          	jalr	-1148(ra) # 80003c3e <iunlockput>
  end_op();
    800050c2:	fffff097          	auipc	ra,0xfffff
    800050c6:	360080e7          	jalr	864(ra) # 80004422 <end_op>
  p = myproc();
    800050ca:	ffffd097          	auipc	ra,0xffffd
    800050ce:	9d0080e7          	jalr	-1584(ra) # 80001a9a <myproc>
    800050d2:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800050d4:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800050d8:	6785                	lui	a5,0x1
    800050da:	17fd                	addi	a5,a5,-1
    800050dc:	94be                	add	s1,s1,a5
    800050de:	77fd                	lui	a5,0xfffff
    800050e0:	8fe5                	and	a5,a5,s1
    800050e2:	e0f43023          	sd	a5,-512(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800050e6:	6609                	lui	a2,0x2
    800050e8:	963e                	add	a2,a2,a5
    800050ea:	85be                	mv	a1,a5
    800050ec:	e0843483          	ld	s1,-504(s0)
    800050f0:	8526                	mv	a0,s1
    800050f2:	ffffc097          	auipc	ra,0xffffc
    800050f6:	418080e7          	jalr	1048(ra) # 8000150a <uvmalloc>
    800050fa:	8b2a                	mv	s6,a0
  ip = 0;
    800050fc:	4901                	li	s2,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800050fe:	16050663          	beqz	a0,8000526a <exec+0x306>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005102:	75f9                	lui	a1,0xffffe
    80005104:	95aa                	add	a1,a1,a0
    80005106:	8526                	mv	a0,s1
    80005108:	ffffc097          	auipc	ra,0xffffc
    8000510c:	620080e7          	jalr	1568(ra) # 80001728 <uvmclear>
  stackbase = sp - PGSIZE;
    80005110:	7bfd                	lui	s7,0xfffff
    80005112:	9bda                	add	s7,s7,s6
  ukvmcopy(pagetable, p->kpagetable, 0, sz);
    80005114:	86da                	mv	a3,s6
    80005116:	4601                	li	a2,0
    80005118:	058ab583          	ld	a1,88(s5)
    8000511c:	8526                	mv	a0,s1
    8000511e:	ffffd097          	auipc	ra,0xffffd
    80005122:	802080e7          	jalr	-2046(ra) # 80001920 <ukvmcopy>
  for(argc = 0; argv[argc]; argc++) {
    80005126:	df843783          	ld	a5,-520(s0)
    8000512a:	6388                	ld	a0,0(a5)
    8000512c:	c925                	beqz	a0,8000519c <exec+0x238>
    8000512e:	e8840993          	addi	s3,s0,-376
    80005132:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80005136:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005138:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000513a:	ffffc097          	auipc	ra,0xffffc
    8000513e:	dce080e7          	jalr	-562(ra) # 80000f08 <strlen>
    80005142:	2505                	addiw	a0,a0,1
    80005144:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005148:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000514c:	15796463          	bltu	s2,s7,80005294 <exec+0x330>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005150:	df843c83          	ld	s9,-520(s0)
    80005154:	000cba03          	ld	s4,0(s9) # fffffffffffff000 <end+0xffffffff7ffd7fe0>
    80005158:	8552                	mv	a0,s4
    8000515a:	ffffc097          	auipc	ra,0xffffc
    8000515e:	dae080e7          	jalr	-594(ra) # 80000f08 <strlen>
    80005162:	0015069b          	addiw	a3,a0,1
    80005166:	8652                	mv	a2,s4
    80005168:	85ca                	mv	a1,s2
    8000516a:	e0843503          	ld	a0,-504(s0)
    8000516e:	ffffc097          	auipc	ra,0xffffc
    80005172:	5ec080e7          	jalr	1516(ra) # 8000175a <copyout>
    80005176:	12054363          	bltz	a0,8000529c <exec+0x338>
    ustack[argc] = sp;
    8000517a:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000517e:	0485                	addi	s1,s1,1
    80005180:	008c8793          	addi	a5,s9,8
    80005184:	def43c23          	sd	a5,-520(s0)
    80005188:	008cb503          	ld	a0,8(s9)
    8000518c:	c911                	beqz	a0,800051a0 <exec+0x23c>
    if(argc >= MAXARG)
    8000518e:	09a1                	addi	s3,s3,8
    80005190:	fb8995e3          	bne	s3,s8,8000513a <exec+0x1d6>
  sz = sz1;
    80005194:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005198:	4901                	li	s2,0
    8000519a:	a8c1                	j	8000526a <exec+0x306>
  sp = sz;
    8000519c:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    8000519e:	4481                	li	s1,0
  ustack[argc] = 0;
    800051a0:	00349793          	slli	a5,s1,0x3
    800051a4:	f9040713          	addi	a4,s0,-112
    800051a8:	97ba                	add	a5,a5,a4
    800051aa:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd7ed8>
  sp -= (argc+1) * sizeof(uint64);
    800051ae:	00148693          	addi	a3,s1,1
    800051b2:	068e                	slli	a3,a3,0x3
    800051b4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800051b8:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800051bc:	01797663          	bleu	s7,s2,800051c8 <exec+0x264>
  sz = sz1;
    800051c0:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    800051c4:	4901                	li	s2,0
    800051c6:	a055                	j	8000526a <exec+0x306>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800051c8:	e8840613          	addi	a2,s0,-376
    800051cc:	85ca                	mv	a1,s2
    800051ce:	e0843503          	ld	a0,-504(s0)
    800051d2:	ffffc097          	auipc	ra,0xffffc
    800051d6:	588080e7          	jalr	1416(ra) # 8000175a <copyout>
    800051da:	0c054563          	bltz	a0,800052a4 <exec+0x340>
  p->trapframe->a1 = sp;
    800051de:	060ab783          	ld	a5,96(s5)
    800051e2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800051e6:	df043783          	ld	a5,-528(s0)
    800051ea:	0007c703          	lbu	a4,0(a5)
    800051ee:	cf11                	beqz	a4,8000520a <exec+0x2a6>
    800051f0:	0785                	addi	a5,a5,1
    if(*s == '/')
    800051f2:	02f00693          	li	a3,47
    800051f6:	a029                	j	80005200 <exec+0x29c>
  for(last=s=path; *s; s++)
    800051f8:	0785                	addi	a5,a5,1
    800051fa:	fff7c703          	lbu	a4,-1(a5)
    800051fe:	c711                	beqz	a4,8000520a <exec+0x2a6>
    if(*s == '/')
    80005200:	fed71ce3          	bne	a4,a3,800051f8 <exec+0x294>
      last = s+1;
    80005204:	def43823          	sd	a5,-528(s0)
    80005208:	bfc5                	j	800051f8 <exec+0x294>
  safestrcpy(p->name, last, sizeof(p->name));
    8000520a:	4641                	li	a2,16
    8000520c:	df043583          	ld	a1,-528(s0)
    80005210:	160a8513          	addi	a0,s5,352
    80005214:	ffffc097          	auipc	ra,0xffffc
    80005218:	cc2080e7          	jalr	-830(ra) # 80000ed6 <safestrcpy>
  oldpagetable = p->pagetable;
    8000521c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005220:	e0843783          	ld	a5,-504(s0)
    80005224:	04fab823          	sd	a5,80(s5)
  p->sz = sz;
    80005228:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000522c:	060ab783          	ld	a5,96(s5)
    80005230:	e6043703          	ld	a4,-416(s0)
    80005234:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005236:	060ab783          	ld	a5,96(s5)
    8000523a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000523e:	85ea                	mv	a1,s10
    80005240:	ffffd097          	auipc	ra,0xffffd
    80005244:	a9c080e7          	jalr	-1380(ra) # 80001cdc <proc_freepagetable>
  if(p->pid==1) vmprint(p->pagetable);
    80005248:	038aa703          	lw	a4,56(s5)
    8000524c:	4785                	li	a5,1
    8000524e:	00f70563          	beq	a4,a5,80005258 <exec+0x2f4>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005252:	0004851b          	sext.w	a0,s1
    80005256:	b36d                	j	80005000 <exec+0x9c>
  if(p->pid==1) vmprint(p->pagetable);
    80005258:	050ab503          	ld	a0,80(s5)
    8000525c:	ffffc097          	auipc	ra,0xffffc
    80005260:	660080e7          	jalr	1632(ra) # 800018bc <vmprint>
    80005264:	b7fd                	j	80005252 <exec+0x2ee>
    80005266:	e0943023          	sd	s1,-512(s0)
    proc_freepagetable(pagetable, sz);
    8000526a:	e0043583          	ld	a1,-512(s0)
    8000526e:	e0843503          	ld	a0,-504(s0)
    80005272:	ffffd097          	auipc	ra,0xffffd
    80005276:	a6a080e7          	jalr	-1430(ra) # 80001cdc <proc_freepagetable>
  if(ip){
    8000527a:	d60919e3          	bnez	s2,80004fec <exec+0x88>
  return -1;
    8000527e:	557d                	li	a0,-1
    80005280:	b341                	j	80005000 <exec+0x9c>
    80005282:	e0943023          	sd	s1,-512(s0)
    80005286:	b7d5                	j	8000526a <exec+0x306>
    80005288:	e0943023          	sd	s1,-512(s0)
    8000528c:	bff9                	j	8000526a <exec+0x306>
    8000528e:	e0943023          	sd	s1,-512(s0)
    80005292:	bfe1                	j	8000526a <exec+0x306>
  sz = sz1;
    80005294:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005298:	4901                	li	s2,0
    8000529a:	bfc1                	j	8000526a <exec+0x306>
  sz = sz1;
    8000529c:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    800052a0:	4901                	li	s2,0
    800052a2:	b7e1                	j	8000526a <exec+0x306>
  sz = sz1;
    800052a4:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    800052a8:	4901                	li	s2,0
    800052aa:	b7c1                	j	8000526a <exec+0x306>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800052ac:	e0043483          	ld	s1,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052b0:	2b05                	addiw	s6,s6,1
    800052b2:	0389899b          	addiw	s3,s3,56
    800052b6:	e8045783          	lhu	a5,-384(s0)
    800052ba:	defb5fe3          	ble	a5,s6,800050b8 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800052be:	2981                	sext.w	s3,s3
    800052c0:	03800713          	li	a4,56
    800052c4:	86ce                	mv	a3,s3
    800052c6:	e1040613          	addi	a2,s0,-496
    800052ca:	4581                	li	a1,0
    800052cc:	854a                	mv	a0,s2
    800052ce:	fffff097          	auipc	ra,0xfffff
    800052d2:	9c2080e7          	jalr	-1598(ra) # 80003c90 <readi>
    800052d6:	03800793          	li	a5,56
    800052da:	f8f516e3          	bne	a0,a5,80005266 <exec+0x302>
    if(ph.type != ELF_PROG_LOAD)
    800052de:	e1042783          	lw	a5,-496(s0)
    800052e2:	4705                	li	a4,1
    800052e4:	fce796e3          	bne	a5,a4,800052b0 <exec+0x34c>
    if(ph.memsz < ph.filesz)
    800052e8:	e3843603          	ld	a2,-456(s0)
    800052ec:	e3043783          	ld	a5,-464(s0)
    800052f0:	f8f669e3          	bltu	a2,a5,80005282 <exec+0x31e>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800052f4:	e2043783          	ld	a5,-480(s0)
    800052f8:	963e                	add	a2,a2,a5
    800052fa:	f8f667e3          	bltu	a2,a5,80005288 <exec+0x324>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800052fe:	85a6                	mv	a1,s1
    80005300:	e0843503          	ld	a0,-504(s0)
    80005304:	ffffc097          	auipc	ra,0xffffc
    80005308:	206080e7          	jalr	518(ra) # 8000150a <uvmalloc>
    8000530c:	e0a43023          	sd	a0,-512(s0)
    80005310:	dd3d                	beqz	a0,8000528e <exec+0x32a>
    if(ph.vaddr % PGSIZE != 0)
    80005312:	e2043d03          	ld	s10,-480(s0)
    80005316:	de843783          	ld	a5,-536(s0)
    8000531a:	00fd77b3          	and	a5,s10,a5
    8000531e:	f7b1                	bnez	a5,8000526a <exec+0x306>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005320:	e1842d83          	lw	s11,-488(s0)
    80005324:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005328:	f80b82e3          	beqz	s7,800052ac <exec+0x348>
    8000532c:	8a5e                	mv	s4,s7
    8000532e:	4481                	li	s1,0
    80005330:	b395                	j	80005094 <exec+0x130>

0000000080005332 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005332:	7179                	addi	sp,sp,-48
    80005334:	f406                	sd	ra,40(sp)
    80005336:	f022                	sd	s0,32(sp)
    80005338:	ec26                	sd	s1,24(sp)
    8000533a:	e84a                	sd	s2,16(sp)
    8000533c:	1800                	addi	s0,sp,48
    8000533e:	892e                	mv	s2,a1
    80005340:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005342:	fdc40593          	addi	a1,s0,-36
    80005346:	ffffe097          	auipc	ra,0xffffe
    8000534a:	ad4080e7          	jalr	-1324(ra) # 80002e1a <argint>
    8000534e:	04054063          	bltz	a0,8000538e <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005352:	fdc42703          	lw	a4,-36(s0)
    80005356:	47bd                	li	a5,15
    80005358:	02e7ed63          	bltu	a5,a4,80005392 <argfd+0x60>
    8000535c:	ffffc097          	auipc	ra,0xffffc
    80005360:	73e080e7          	jalr	1854(ra) # 80001a9a <myproc>
    80005364:	fdc42703          	lw	a4,-36(s0)
    80005368:	01a70793          	addi	a5,a4,26
    8000536c:	078e                	slli	a5,a5,0x3
    8000536e:	953e                	add	a0,a0,a5
    80005370:	651c                	ld	a5,8(a0)
    80005372:	c395                	beqz	a5,80005396 <argfd+0x64>
    return -1;
  if(pfd)
    80005374:	00090463          	beqz	s2,8000537c <argfd+0x4a>
    *pfd = fd;
    80005378:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000537c:	4501                	li	a0,0
  if(pf)
    8000537e:	c091                	beqz	s1,80005382 <argfd+0x50>
    *pf = f;
    80005380:	e09c                	sd	a5,0(s1)
}
    80005382:	70a2                	ld	ra,40(sp)
    80005384:	7402                	ld	s0,32(sp)
    80005386:	64e2                	ld	s1,24(sp)
    80005388:	6942                	ld	s2,16(sp)
    8000538a:	6145                	addi	sp,sp,48
    8000538c:	8082                	ret
    return -1;
    8000538e:	557d                	li	a0,-1
    80005390:	bfcd                	j	80005382 <argfd+0x50>
    return -1;
    80005392:	557d                	li	a0,-1
    80005394:	b7fd                	j	80005382 <argfd+0x50>
    80005396:	557d                	li	a0,-1
    80005398:	b7ed                	j	80005382 <argfd+0x50>

000000008000539a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000539a:	1101                	addi	sp,sp,-32
    8000539c:	ec06                	sd	ra,24(sp)
    8000539e:	e822                	sd	s0,16(sp)
    800053a0:	e426                	sd	s1,8(sp)
    800053a2:	1000                	addi	s0,sp,32
    800053a4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800053a6:	ffffc097          	auipc	ra,0xffffc
    800053aa:	6f4080e7          	jalr	1780(ra) # 80001a9a <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
    800053ae:	6d7c                	ld	a5,216(a0)
    800053b0:	c395                	beqz	a5,800053d4 <fdalloc+0x3a>
    800053b2:	0e050713          	addi	a4,a0,224
  for(fd = 0; fd < NOFILE; fd++){
    800053b6:	4785                	li	a5,1
    800053b8:	4641                	li	a2,16
    if(p->ofile[fd] == 0){
    800053ba:	6314                	ld	a3,0(a4)
    800053bc:	ce89                	beqz	a3,800053d6 <fdalloc+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
    800053be:	2785                	addiw	a5,a5,1
    800053c0:	0721                	addi	a4,a4,8
    800053c2:	fec79ce3          	bne	a5,a2,800053ba <fdalloc+0x20>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800053c6:	57fd                	li	a5,-1
}
    800053c8:	853e                	mv	a0,a5
    800053ca:	60e2                	ld	ra,24(sp)
    800053cc:	6442                	ld	s0,16(sp)
    800053ce:	64a2                	ld	s1,8(sp)
    800053d0:	6105                	addi	sp,sp,32
    800053d2:	8082                	ret
  for(fd = 0; fd < NOFILE; fd++){
    800053d4:	4781                	li	a5,0
      p->ofile[fd] = f;
    800053d6:	01a78713          	addi	a4,a5,26
    800053da:	070e                	slli	a4,a4,0x3
    800053dc:	953a                	add	a0,a0,a4
    800053de:	e504                	sd	s1,8(a0)
      return fd;
    800053e0:	b7e5                	j	800053c8 <fdalloc+0x2e>

00000000800053e2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800053e2:	715d                	addi	sp,sp,-80
    800053e4:	e486                	sd	ra,72(sp)
    800053e6:	e0a2                	sd	s0,64(sp)
    800053e8:	fc26                	sd	s1,56(sp)
    800053ea:	f84a                	sd	s2,48(sp)
    800053ec:	f44e                	sd	s3,40(sp)
    800053ee:	f052                	sd	s4,32(sp)
    800053f0:	ec56                	sd	s5,24(sp)
    800053f2:	0880                	addi	s0,sp,80
    800053f4:	89ae                	mv	s3,a1
    800053f6:	8ab2                	mv	s5,a2
    800053f8:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800053fa:	fb040593          	addi	a1,s0,-80
    800053fe:	fffff097          	auipc	ra,0xfffff
    80005402:	db4080e7          	jalr	-588(ra) # 800041b2 <nameiparent>
    80005406:	892a                	mv	s2,a0
    80005408:	12050f63          	beqz	a0,80005546 <create+0x164>
    return 0;

  ilock(dp);
    8000540c:	ffffe097          	auipc	ra,0xffffe
    80005410:	5ce080e7          	jalr	1486(ra) # 800039da <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005414:	4601                	li	a2,0
    80005416:	fb040593          	addi	a1,s0,-80
    8000541a:	854a                	mv	a0,s2
    8000541c:	fffff097          	auipc	ra,0xfffff
    80005420:	a9e080e7          	jalr	-1378(ra) # 80003eba <dirlookup>
    80005424:	84aa                	mv	s1,a0
    80005426:	c921                	beqz	a0,80005476 <create+0x94>
    iunlockput(dp);
    80005428:	854a                	mv	a0,s2
    8000542a:	fffff097          	auipc	ra,0xfffff
    8000542e:	814080e7          	jalr	-2028(ra) # 80003c3e <iunlockput>
    ilock(ip);
    80005432:	8526                	mv	a0,s1
    80005434:	ffffe097          	auipc	ra,0xffffe
    80005438:	5a6080e7          	jalr	1446(ra) # 800039da <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000543c:	2981                	sext.w	s3,s3
    8000543e:	4789                	li	a5,2
    80005440:	02f99463          	bne	s3,a5,80005468 <create+0x86>
    80005444:	0444d783          	lhu	a5,68(s1)
    80005448:	37f9                	addiw	a5,a5,-2
    8000544a:	17c2                	slli	a5,a5,0x30
    8000544c:	93c1                	srli	a5,a5,0x30
    8000544e:	4705                	li	a4,1
    80005450:	00f76c63          	bltu	a4,a5,80005468 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005454:	8526                	mv	a0,s1
    80005456:	60a6                	ld	ra,72(sp)
    80005458:	6406                	ld	s0,64(sp)
    8000545a:	74e2                	ld	s1,56(sp)
    8000545c:	7942                	ld	s2,48(sp)
    8000545e:	79a2                	ld	s3,40(sp)
    80005460:	7a02                	ld	s4,32(sp)
    80005462:	6ae2                	ld	s5,24(sp)
    80005464:	6161                	addi	sp,sp,80
    80005466:	8082                	ret
    iunlockput(ip);
    80005468:	8526                	mv	a0,s1
    8000546a:	ffffe097          	auipc	ra,0xffffe
    8000546e:	7d4080e7          	jalr	2004(ra) # 80003c3e <iunlockput>
    return 0;
    80005472:	4481                	li	s1,0
    80005474:	b7c5                	j	80005454 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005476:	85ce                	mv	a1,s3
    80005478:	00092503          	lw	a0,0(s2)
    8000547c:	ffffe097          	auipc	ra,0xffffe
    80005480:	3c2080e7          	jalr	962(ra) # 8000383e <ialloc>
    80005484:	84aa                	mv	s1,a0
    80005486:	c529                	beqz	a0,800054d0 <create+0xee>
  ilock(ip);
    80005488:	ffffe097          	auipc	ra,0xffffe
    8000548c:	552080e7          	jalr	1362(ra) # 800039da <ilock>
  ip->major = major;
    80005490:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005494:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005498:	4785                	li	a5,1
    8000549a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000549e:	8526                	mv	a0,s1
    800054a0:	ffffe097          	auipc	ra,0xffffe
    800054a4:	46e080e7          	jalr	1134(ra) # 8000390e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800054a8:	2981                	sext.w	s3,s3
    800054aa:	4785                	li	a5,1
    800054ac:	02f98a63          	beq	s3,a5,800054e0 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800054b0:	40d0                	lw	a2,4(s1)
    800054b2:	fb040593          	addi	a1,s0,-80
    800054b6:	854a                	mv	a0,s2
    800054b8:	fffff097          	auipc	ra,0xfffff
    800054bc:	c1a080e7          	jalr	-998(ra) # 800040d2 <dirlink>
    800054c0:	06054b63          	bltz	a0,80005536 <create+0x154>
  iunlockput(dp);
    800054c4:	854a                	mv	a0,s2
    800054c6:	ffffe097          	auipc	ra,0xffffe
    800054ca:	778080e7          	jalr	1912(ra) # 80003c3e <iunlockput>
  return ip;
    800054ce:	b759                	j	80005454 <create+0x72>
    panic("create: ialloc");
    800054d0:	00003517          	auipc	a0,0x3
    800054d4:	2a850513          	addi	a0,a0,680 # 80008778 <syscalls+0x2d8>
    800054d8:	ffffb097          	auipc	ra,0xffffb
    800054dc:	09c080e7          	jalr	156(ra) # 80000574 <panic>
    dp->nlink++;  // for ".."
    800054e0:	04a95783          	lhu	a5,74(s2)
    800054e4:	2785                	addiw	a5,a5,1
    800054e6:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800054ea:	854a                	mv	a0,s2
    800054ec:	ffffe097          	auipc	ra,0xffffe
    800054f0:	422080e7          	jalr	1058(ra) # 8000390e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800054f4:	40d0                	lw	a2,4(s1)
    800054f6:	00003597          	auipc	a1,0x3
    800054fa:	29258593          	addi	a1,a1,658 # 80008788 <syscalls+0x2e8>
    800054fe:	8526                	mv	a0,s1
    80005500:	fffff097          	auipc	ra,0xfffff
    80005504:	bd2080e7          	jalr	-1070(ra) # 800040d2 <dirlink>
    80005508:	00054f63          	bltz	a0,80005526 <create+0x144>
    8000550c:	00492603          	lw	a2,4(s2)
    80005510:	00003597          	auipc	a1,0x3
    80005514:	cb858593          	addi	a1,a1,-840 # 800081c8 <digits+0x1b0>
    80005518:	8526                	mv	a0,s1
    8000551a:	fffff097          	auipc	ra,0xfffff
    8000551e:	bb8080e7          	jalr	-1096(ra) # 800040d2 <dirlink>
    80005522:	f80557e3          	bgez	a0,800054b0 <create+0xce>
      panic("create dots");
    80005526:	00003517          	auipc	a0,0x3
    8000552a:	26a50513          	addi	a0,a0,618 # 80008790 <syscalls+0x2f0>
    8000552e:	ffffb097          	auipc	ra,0xffffb
    80005532:	046080e7          	jalr	70(ra) # 80000574 <panic>
    panic("create: dirlink");
    80005536:	00003517          	auipc	a0,0x3
    8000553a:	26a50513          	addi	a0,a0,618 # 800087a0 <syscalls+0x300>
    8000553e:	ffffb097          	auipc	ra,0xffffb
    80005542:	036080e7          	jalr	54(ra) # 80000574 <panic>
    return 0;
    80005546:	84aa                	mv	s1,a0
    80005548:	b731                	j	80005454 <create+0x72>

000000008000554a <sys_dup>:
{
    8000554a:	7179                	addi	sp,sp,-48
    8000554c:	f406                	sd	ra,40(sp)
    8000554e:	f022                	sd	s0,32(sp)
    80005550:	ec26                	sd	s1,24(sp)
    80005552:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005554:	fd840613          	addi	a2,s0,-40
    80005558:	4581                	li	a1,0
    8000555a:	4501                	li	a0,0
    8000555c:	00000097          	auipc	ra,0x0
    80005560:	dd6080e7          	jalr	-554(ra) # 80005332 <argfd>
    return -1;
    80005564:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005566:	02054363          	bltz	a0,8000558c <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000556a:	fd843503          	ld	a0,-40(s0)
    8000556e:	00000097          	auipc	ra,0x0
    80005572:	e2c080e7          	jalr	-468(ra) # 8000539a <fdalloc>
    80005576:	84aa                	mv	s1,a0
    return -1;
    80005578:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000557a:	00054963          	bltz	a0,8000558c <sys_dup+0x42>
  filedup(f);
    8000557e:	fd843503          	ld	a0,-40(s0)
    80005582:	fffff097          	auipc	ra,0xfffff
    80005586:	2d0080e7          	jalr	720(ra) # 80004852 <filedup>
  return fd;
    8000558a:	87a6                	mv	a5,s1
}
    8000558c:	853e                	mv	a0,a5
    8000558e:	70a2                	ld	ra,40(sp)
    80005590:	7402                	ld	s0,32(sp)
    80005592:	64e2                	ld	s1,24(sp)
    80005594:	6145                	addi	sp,sp,48
    80005596:	8082                	ret

0000000080005598 <sys_read>:
{
    80005598:	7179                	addi	sp,sp,-48
    8000559a:	f406                	sd	ra,40(sp)
    8000559c:	f022                	sd	s0,32(sp)
    8000559e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055a0:	fe840613          	addi	a2,s0,-24
    800055a4:	4581                	li	a1,0
    800055a6:	4501                	li	a0,0
    800055a8:	00000097          	auipc	ra,0x0
    800055ac:	d8a080e7          	jalr	-630(ra) # 80005332 <argfd>
    return -1;
    800055b0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055b2:	04054163          	bltz	a0,800055f4 <sys_read+0x5c>
    800055b6:	fe440593          	addi	a1,s0,-28
    800055ba:	4509                	li	a0,2
    800055bc:	ffffe097          	auipc	ra,0xffffe
    800055c0:	85e080e7          	jalr	-1954(ra) # 80002e1a <argint>
    return -1;
    800055c4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055c6:	02054763          	bltz	a0,800055f4 <sys_read+0x5c>
    800055ca:	fd840593          	addi	a1,s0,-40
    800055ce:	4505                	li	a0,1
    800055d0:	ffffe097          	auipc	ra,0xffffe
    800055d4:	86c080e7          	jalr	-1940(ra) # 80002e3c <argaddr>
    return -1;
    800055d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055da:	00054d63          	bltz	a0,800055f4 <sys_read+0x5c>
  return fileread(f, p, n);
    800055de:	fe442603          	lw	a2,-28(s0)
    800055e2:	fd843583          	ld	a1,-40(s0)
    800055e6:	fe843503          	ld	a0,-24(s0)
    800055ea:	fffff097          	auipc	ra,0xfffff
    800055ee:	3f4080e7          	jalr	1012(ra) # 800049de <fileread>
    800055f2:	87aa                	mv	a5,a0
}
    800055f4:	853e                	mv	a0,a5
    800055f6:	70a2                	ld	ra,40(sp)
    800055f8:	7402                	ld	s0,32(sp)
    800055fa:	6145                	addi	sp,sp,48
    800055fc:	8082                	ret

00000000800055fe <sys_write>:
{
    800055fe:	7179                	addi	sp,sp,-48
    80005600:	f406                	sd	ra,40(sp)
    80005602:	f022                	sd	s0,32(sp)
    80005604:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005606:	fe840613          	addi	a2,s0,-24
    8000560a:	4581                	li	a1,0
    8000560c:	4501                	li	a0,0
    8000560e:	00000097          	auipc	ra,0x0
    80005612:	d24080e7          	jalr	-732(ra) # 80005332 <argfd>
    return -1;
    80005616:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005618:	04054163          	bltz	a0,8000565a <sys_write+0x5c>
    8000561c:	fe440593          	addi	a1,s0,-28
    80005620:	4509                	li	a0,2
    80005622:	ffffd097          	auipc	ra,0xffffd
    80005626:	7f8080e7          	jalr	2040(ra) # 80002e1a <argint>
    return -1;
    8000562a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000562c:	02054763          	bltz	a0,8000565a <sys_write+0x5c>
    80005630:	fd840593          	addi	a1,s0,-40
    80005634:	4505                	li	a0,1
    80005636:	ffffe097          	auipc	ra,0xffffe
    8000563a:	806080e7          	jalr	-2042(ra) # 80002e3c <argaddr>
    return -1;
    8000563e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005640:	00054d63          	bltz	a0,8000565a <sys_write+0x5c>
  return filewrite(f, p, n);
    80005644:	fe442603          	lw	a2,-28(s0)
    80005648:	fd843583          	ld	a1,-40(s0)
    8000564c:	fe843503          	ld	a0,-24(s0)
    80005650:	fffff097          	auipc	ra,0xfffff
    80005654:	450080e7          	jalr	1104(ra) # 80004aa0 <filewrite>
    80005658:	87aa                	mv	a5,a0
}
    8000565a:	853e                	mv	a0,a5
    8000565c:	70a2                	ld	ra,40(sp)
    8000565e:	7402                	ld	s0,32(sp)
    80005660:	6145                	addi	sp,sp,48
    80005662:	8082                	ret

0000000080005664 <sys_close>:
{
    80005664:	1101                	addi	sp,sp,-32
    80005666:	ec06                	sd	ra,24(sp)
    80005668:	e822                	sd	s0,16(sp)
    8000566a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000566c:	fe040613          	addi	a2,s0,-32
    80005670:	fec40593          	addi	a1,s0,-20
    80005674:	4501                	li	a0,0
    80005676:	00000097          	auipc	ra,0x0
    8000567a:	cbc080e7          	jalr	-836(ra) # 80005332 <argfd>
    return -1;
    8000567e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005680:	02054463          	bltz	a0,800056a8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005684:	ffffc097          	auipc	ra,0xffffc
    80005688:	416080e7          	jalr	1046(ra) # 80001a9a <myproc>
    8000568c:	fec42783          	lw	a5,-20(s0)
    80005690:	07e9                	addi	a5,a5,26
    80005692:	078e                	slli	a5,a5,0x3
    80005694:	953e                	add	a0,a0,a5
    80005696:	00053423          	sd	zero,8(a0)
  fileclose(f);
    8000569a:	fe043503          	ld	a0,-32(s0)
    8000569e:	fffff097          	auipc	ra,0xfffff
    800056a2:	206080e7          	jalr	518(ra) # 800048a4 <fileclose>
  return 0;
    800056a6:	4781                	li	a5,0
}
    800056a8:	853e                	mv	a0,a5
    800056aa:	60e2                	ld	ra,24(sp)
    800056ac:	6442                	ld	s0,16(sp)
    800056ae:	6105                	addi	sp,sp,32
    800056b0:	8082                	ret

00000000800056b2 <sys_fstat>:
{
    800056b2:	1101                	addi	sp,sp,-32
    800056b4:	ec06                	sd	ra,24(sp)
    800056b6:	e822                	sd	s0,16(sp)
    800056b8:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056ba:	fe840613          	addi	a2,s0,-24
    800056be:	4581                	li	a1,0
    800056c0:	4501                	li	a0,0
    800056c2:	00000097          	auipc	ra,0x0
    800056c6:	c70080e7          	jalr	-912(ra) # 80005332 <argfd>
    return -1;
    800056ca:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056cc:	02054563          	bltz	a0,800056f6 <sys_fstat+0x44>
    800056d0:	fe040593          	addi	a1,s0,-32
    800056d4:	4505                	li	a0,1
    800056d6:	ffffd097          	auipc	ra,0xffffd
    800056da:	766080e7          	jalr	1894(ra) # 80002e3c <argaddr>
    return -1;
    800056de:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056e0:	00054b63          	bltz	a0,800056f6 <sys_fstat+0x44>
  return filestat(f, st);
    800056e4:	fe043583          	ld	a1,-32(s0)
    800056e8:	fe843503          	ld	a0,-24(s0)
    800056ec:	fffff097          	auipc	ra,0xfffff
    800056f0:	280080e7          	jalr	640(ra) # 8000496c <filestat>
    800056f4:	87aa                	mv	a5,a0
}
    800056f6:	853e                	mv	a0,a5
    800056f8:	60e2                	ld	ra,24(sp)
    800056fa:	6442                	ld	s0,16(sp)
    800056fc:	6105                	addi	sp,sp,32
    800056fe:	8082                	ret

0000000080005700 <sys_link>:
{
    80005700:	7169                	addi	sp,sp,-304
    80005702:	f606                	sd	ra,296(sp)
    80005704:	f222                	sd	s0,288(sp)
    80005706:	ee26                	sd	s1,280(sp)
    80005708:	ea4a                	sd	s2,272(sp)
    8000570a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000570c:	08000613          	li	a2,128
    80005710:	ed040593          	addi	a1,s0,-304
    80005714:	4501                	li	a0,0
    80005716:	ffffd097          	auipc	ra,0xffffd
    8000571a:	748080e7          	jalr	1864(ra) # 80002e5e <argstr>
    return -1;
    8000571e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005720:	10054e63          	bltz	a0,8000583c <sys_link+0x13c>
    80005724:	08000613          	li	a2,128
    80005728:	f5040593          	addi	a1,s0,-176
    8000572c:	4505                	li	a0,1
    8000572e:	ffffd097          	auipc	ra,0xffffd
    80005732:	730080e7          	jalr	1840(ra) # 80002e5e <argstr>
    return -1;
    80005736:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005738:	10054263          	bltz	a0,8000583c <sys_link+0x13c>
  begin_op();
    8000573c:	fffff097          	auipc	ra,0xfffff
    80005740:	c66080e7          	jalr	-922(ra) # 800043a2 <begin_op>
  if((ip = namei(old)) == 0){
    80005744:	ed040513          	addi	a0,s0,-304
    80005748:	fffff097          	auipc	ra,0xfffff
    8000574c:	a4c080e7          	jalr	-1460(ra) # 80004194 <namei>
    80005750:	84aa                	mv	s1,a0
    80005752:	c551                	beqz	a0,800057de <sys_link+0xde>
  ilock(ip);
    80005754:	ffffe097          	auipc	ra,0xffffe
    80005758:	286080e7          	jalr	646(ra) # 800039da <ilock>
  if(ip->type == T_DIR){
    8000575c:	04449703          	lh	a4,68(s1)
    80005760:	4785                	li	a5,1
    80005762:	08f70463          	beq	a4,a5,800057ea <sys_link+0xea>
  ip->nlink++;
    80005766:	04a4d783          	lhu	a5,74(s1)
    8000576a:	2785                	addiw	a5,a5,1
    8000576c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005770:	8526                	mv	a0,s1
    80005772:	ffffe097          	auipc	ra,0xffffe
    80005776:	19c080e7          	jalr	412(ra) # 8000390e <iupdate>
  iunlock(ip);
    8000577a:	8526                	mv	a0,s1
    8000577c:	ffffe097          	auipc	ra,0xffffe
    80005780:	322080e7          	jalr	802(ra) # 80003a9e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005784:	fd040593          	addi	a1,s0,-48
    80005788:	f5040513          	addi	a0,s0,-176
    8000578c:	fffff097          	auipc	ra,0xfffff
    80005790:	a26080e7          	jalr	-1498(ra) # 800041b2 <nameiparent>
    80005794:	892a                	mv	s2,a0
    80005796:	c935                	beqz	a0,8000580a <sys_link+0x10a>
  ilock(dp);
    80005798:	ffffe097          	auipc	ra,0xffffe
    8000579c:	242080e7          	jalr	578(ra) # 800039da <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800057a0:	00092703          	lw	a4,0(s2)
    800057a4:	409c                	lw	a5,0(s1)
    800057a6:	04f71d63          	bne	a4,a5,80005800 <sys_link+0x100>
    800057aa:	40d0                	lw	a2,4(s1)
    800057ac:	fd040593          	addi	a1,s0,-48
    800057b0:	854a                	mv	a0,s2
    800057b2:	fffff097          	auipc	ra,0xfffff
    800057b6:	920080e7          	jalr	-1760(ra) # 800040d2 <dirlink>
    800057ba:	04054363          	bltz	a0,80005800 <sys_link+0x100>
  iunlockput(dp);
    800057be:	854a                	mv	a0,s2
    800057c0:	ffffe097          	auipc	ra,0xffffe
    800057c4:	47e080e7          	jalr	1150(ra) # 80003c3e <iunlockput>
  iput(ip);
    800057c8:	8526                	mv	a0,s1
    800057ca:	ffffe097          	auipc	ra,0xffffe
    800057ce:	3cc080e7          	jalr	972(ra) # 80003b96 <iput>
  end_op();
    800057d2:	fffff097          	auipc	ra,0xfffff
    800057d6:	c50080e7          	jalr	-944(ra) # 80004422 <end_op>
  return 0;
    800057da:	4781                	li	a5,0
    800057dc:	a085                	j	8000583c <sys_link+0x13c>
    end_op();
    800057de:	fffff097          	auipc	ra,0xfffff
    800057e2:	c44080e7          	jalr	-956(ra) # 80004422 <end_op>
    return -1;
    800057e6:	57fd                	li	a5,-1
    800057e8:	a891                	j	8000583c <sys_link+0x13c>
    iunlockput(ip);
    800057ea:	8526                	mv	a0,s1
    800057ec:	ffffe097          	auipc	ra,0xffffe
    800057f0:	452080e7          	jalr	1106(ra) # 80003c3e <iunlockput>
    end_op();
    800057f4:	fffff097          	auipc	ra,0xfffff
    800057f8:	c2e080e7          	jalr	-978(ra) # 80004422 <end_op>
    return -1;
    800057fc:	57fd                	li	a5,-1
    800057fe:	a83d                	j	8000583c <sys_link+0x13c>
    iunlockput(dp);
    80005800:	854a                	mv	a0,s2
    80005802:	ffffe097          	auipc	ra,0xffffe
    80005806:	43c080e7          	jalr	1084(ra) # 80003c3e <iunlockput>
  ilock(ip);
    8000580a:	8526                	mv	a0,s1
    8000580c:	ffffe097          	auipc	ra,0xffffe
    80005810:	1ce080e7          	jalr	462(ra) # 800039da <ilock>
  ip->nlink--;
    80005814:	04a4d783          	lhu	a5,74(s1)
    80005818:	37fd                	addiw	a5,a5,-1
    8000581a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000581e:	8526                	mv	a0,s1
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	0ee080e7          	jalr	238(ra) # 8000390e <iupdate>
  iunlockput(ip);
    80005828:	8526                	mv	a0,s1
    8000582a:	ffffe097          	auipc	ra,0xffffe
    8000582e:	414080e7          	jalr	1044(ra) # 80003c3e <iunlockput>
  end_op();
    80005832:	fffff097          	auipc	ra,0xfffff
    80005836:	bf0080e7          	jalr	-1040(ra) # 80004422 <end_op>
  return -1;
    8000583a:	57fd                	li	a5,-1
}
    8000583c:	853e                	mv	a0,a5
    8000583e:	70b2                	ld	ra,296(sp)
    80005840:	7412                	ld	s0,288(sp)
    80005842:	64f2                	ld	s1,280(sp)
    80005844:	6952                	ld	s2,272(sp)
    80005846:	6155                	addi	sp,sp,304
    80005848:	8082                	ret

000000008000584a <sys_unlink>:
{
    8000584a:	7151                	addi	sp,sp,-240
    8000584c:	f586                	sd	ra,232(sp)
    8000584e:	f1a2                	sd	s0,224(sp)
    80005850:	eda6                	sd	s1,216(sp)
    80005852:	e9ca                	sd	s2,208(sp)
    80005854:	e5ce                	sd	s3,200(sp)
    80005856:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005858:	08000613          	li	a2,128
    8000585c:	f3040593          	addi	a1,s0,-208
    80005860:	4501                	li	a0,0
    80005862:	ffffd097          	auipc	ra,0xffffd
    80005866:	5fc080e7          	jalr	1532(ra) # 80002e5e <argstr>
    8000586a:	16054f63          	bltz	a0,800059e8 <sys_unlink+0x19e>
  begin_op();
    8000586e:	fffff097          	auipc	ra,0xfffff
    80005872:	b34080e7          	jalr	-1228(ra) # 800043a2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005876:	fb040593          	addi	a1,s0,-80
    8000587a:	f3040513          	addi	a0,s0,-208
    8000587e:	fffff097          	auipc	ra,0xfffff
    80005882:	934080e7          	jalr	-1740(ra) # 800041b2 <nameiparent>
    80005886:	89aa                	mv	s3,a0
    80005888:	c979                	beqz	a0,8000595e <sys_unlink+0x114>
  ilock(dp);
    8000588a:	ffffe097          	auipc	ra,0xffffe
    8000588e:	150080e7          	jalr	336(ra) # 800039da <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005892:	00003597          	auipc	a1,0x3
    80005896:	ef658593          	addi	a1,a1,-266 # 80008788 <syscalls+0x2e8>
    8000589a:	fb040513          	addi	a0,s0,-80
    8000589e:	ffffe097          	auipc	ra,0xffffe
    800058a2:	602080e7          	jalr	1538(ra) # 80003ea0 <namecmp>
    800058a6:	14050863          	beqz	a0,800059f6 <sys_unlink+0x1ac>
    800058aa:	00003597          	auipc	a1,0x3
    800058ae:	91e58593          	addi	a1,a1,-1762 # 800081c8 <digits+0x1b0>
    800058b2:	fb040513          	addi	a0,s0,-80
    800058b6:	ffffe097          	auipc	ra,0xffffe
    800058ba:	5ea080e7          	jalr	1514(ra) # 80003ea0 <namecmp>
    800058be:	12050c63          	beqz	a0,800059f6 <sys_unlink+0x1ac>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800058c2:	f2c40613          	addi	a2,s0,-212
    800058c6:	fb040593          	addi	a1,s0,-80
    800058ca:	854e                	mv	a0,s3
    800058cc:	ffffe097          	auipc	ra,0xffffe
    800058d0:	5ee080e7          	jalr	1518(ra) # 80003eba <dirlookup>
    800058d4:	84aa                	mv	s1,a0
    800058d6:	12050063          	beqz	a0,800059f6 <sys_unlink+0x1ac>
  ilock(ip);
    800058da:	ffffe097          	auipc	ra,0xffffe
    800058de:	100080e7          	jalr	256(ra) # 800039da <ilock>
  if(ip->nlink < 1)
    800058e2:	04a49783          	lh	a5,74(s1)
    800058e6:	08f05263          	blez	a5,8000596a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800058ea:	04449703          	lh	a4,68(s1)
    800058ee:	4785                	li	a5,1
    800058f0:	08f70563          	beq	a4,a5,8000597a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800058f4:	4641                	li	a2,16
    800058f6:	4581                	li	a1,0
    800058f8:	fc040513          	addi	a0,s0,-64
    800058fc:	ffffb097          	auipc	ra,0xffffb
    80005900:	462080e7          	jalr	1122(ra) # 80000d5e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005904:	4741                	li	a4,16
    80005906:	f2c42683          	lw	a3,-212(s0)
    8000590a:	fc040613          	addi	a2,s0,-64
    8000590e:	4581                	li	a1,0
    80005910:	854e                	mv	a0,s3
    80005912:	ffffe097          	auipc	ra,0xffffe
    80005916:	474080e7          	jalr	1140(ra) # 80003d86 <writei>
    8000591a:	47c1                	li	a5,16
    8000591c:	0af51363          	bne	a0,a5,800059c2 <sys_unlink+0x178>
  if(ip->type == T_DIR){
    80005920:	04449703          	lh	a4,68(s1)
    80005924:	4785                	li	a5,1
    80005926:	0af70663          	beq	a4,a5,800059d2 <sys_unlink+0x188>
  iunlockput(dp);
    8000592a:	854e                	mv	a0,s3
    8000592c:	ffffe097          	auipc	ra,0xffffe
    80005930:	312080e7          	jalr	786(ra) # 80003c3e <iunlockput>
  ip->nlink--;
    80005934:	04a4d783          	lhu	a5,74(s1)
    80005938:	37fd                	addiw	a5,a5,-1
    8000593a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000593e:	8526                	mv	a0,s1
    80005940:	ffffe097          	auipc	ra,0xffffe
    80005944:	fce080e7          	jalr	-50(ra) # 8000390e <iupdate>
  iunlockput(ip);
    80005948:	8526                	mv	a0,s1
    8000594a:	ffffe097          	auipc	ra,0xffffe
    8000594e:	2f4080e7          	jalr	756(ra) # 80003c3e <iunlockput>
  end_op();
    80005952:	fffff097          	auipc	ra,0xfffff
    80005956:	ad0080e7          	jalr	-1328(ra) # 80004422 <end_op>
  return 0;
    8000595a:	4501                	li	a0,0
    8000595c:	a07d                	j	80005a0a <sys_unlink+0x1c0>
    end_op();
    8000595e:	fffff097          	auipc	ra,0xfffff
    80005962:	ac4080e7          	jalr	-1340(ra) # 80004422 <end_op>
    return -1;
    80005966:	557d                	li	a0,-1
    80005968:	a04d                	j	80005a0a <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    8000596a:	00003517          	auipc	a0,0x3
    8000596e:	e4650513          	addi	a0,a0,-442 # 800087b0 <syscalls+0x310>
    80005972:	ffffb097          	auipc	ra,0xffffb
    80005976:	c02080e7          	jalr	-1022(ra) # 80000574 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000597a:	44f8                	lw	a4,76(s1)
    8000597c:	02000793          	li	a5,32
    80005980:	f6e7fae3          	bleu	a4,a5,800058f4 <sys_unlink+0xaa>
    80005984:	02000913          	li	s2,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005988:	4741                	li	a4,16
    8000598a:	86ca                	mv	a3,s2
    8000598c:	f1840613          	addi	a2,s0,-232
    80005990:	4581                	li	a1,0
    80005992:	8526                	mv	a0,s1
    80005994:	ffffe097          	auipc	ra,0xffffe
    80005998:	2fc080e7          	jalr	764(ra) # 80003c90 <readi>
    8000599c:	47c1                	li	a5,16
    8000599e:	00f51a63          	bne	a0,a5,800059b2 <sys_unlink+0x168>
    if(de.inum != 0)
    800059a2:	f1845783          	lhu	a5,-232(s0)
    800059a6:	e3b9                	bnez	a5,800059ec <sys_unlink+0x1a2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059a8:	2941                	addiw	s2,s2,16
    800059aa:	44fc                	lw	a5,76(s1)
    800059ac:	fcf96ee3          	bltu	s2,a5,80005988 <sys_unlink+0x13e>
    800059b0:	b791                	j	800058f4 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800059b2:	00003517          	auipc	a0,0x3
    800059b6:	e1650513          	addi	a0,a0,-490 # 800087c8 <syscalls+0x328>
    800059ba:	ffffb097          	auipc	ra,0xffffb
    800059be:	bba080e7          	jalr	-1094(ra) # 80000574 <panic>
    panic("unlink: writei");
    800059c2:	00003517          	auipc	a0,0x3
    800059c6:	e1e50513          	addi	a0,a0,-482 # 800087e0 <syscalls+0x340>
    800059ca:	ffffb097          	auipc	ra,0xffffb
    800059ce:	baa080e7          	jalr	-1110(ra) # 80000574 <panic>
    dp->nlink--;
    800059d2:	04a9d783          	lhu	a5,74(s3)
    800059d6:	37fd                	addiw	a5,a5,-1
    800059d8:	04f99523          	sh	a5,74(s3)
    iupdate(dp);
    800059dc:	854e                	mv	a0,s3
    800059de:	ffffe097          	auipc	ra,0xffffe
    800059e2:	f30080e7          	jalr	-208(ra) # 8000390e <iupdate>
    800059e6:	b791                	j	8000592a <sys_unlink+0xe0>
    return -1;
    800059e8:	557d                	li	a0,-1
    800059ea:	a005                	j	80005a0a <sys_unlink+0x1c0>
    iunlockput(ip);
    800059ec:	8526                	mv	a0,s1
    800059ee:	ffffe097          	auipc	ra,0xffffe
    800059f2:	250080e7          	jalr	592(ra) # 80003c3e <iunlockput>
  iunlockput(dp);
    800059f6:	854e                	mv	a0,s3
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	246080e7          	jalr	582(ra) # 80003c3e <iunlockput>
  end_op();
    80005a00:	fffff097          	auipc	ra,0xfffff
    80005a04:	a22080e7          	jalr	-1502(ra) # 80004422 <end_op>
  return -1;
    80005a08:	557d                	li	a0,-1
}
    80005a0a:	70ae                	ld	ra,232(sp)
    80005a0c:	740e                	ld	s0,224(sp)
    80005a0e:	64ee                	ld	s1,216(sp)
    80005a10:	694e                	ld	s2,208(sp)
    80005a12:	69ae                	ld	s3,200(sp)
    80005a14:	616d                	addi	sp,sp,240
    80005a16:	8082                	ret

0000000080005a18 <sys_open>:

uint64
sys_open(void)
{
    80005a18:	7131                	addi	sp,sp,-192
    80005a1a:	fd06                	sd	ra,184(sp)
    80005a1c:	f922                	sd	s0,176(sp)
    80005a1e:	f526                	sd	s1,168(sp)
    80005a20:	f14a                	sd	s2,160(sp)
    80005a22:	ed4e                	sd	s3,152(sp)
    80005a24:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a26:	08000613          	li	a2,128
    80005a2a:	f5040593          	addi	a1,s0,-176
    80005a2e:	4501                	li	a0,0
    80005a30:	ffffd097          	auipc	ra,0xffffd
    80005a34:	42e080e7          	jalr	1070(ra) # 80002e5e <argstr>
    return -1;
    80005a38:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a3a:	0c054163          	bltz	a0,80005afc <sys_open+0xe4>
    80005a3e:	f4c40593          	addi	a1,s0,-180
    80005a42:	4505                	li	a0,1
    80005a44:	ffffd097          	auipc	ra,0xffffd
    80005a48:	3d6080e7          	jalr	982(ra) # 80002e1a <argint>
    80005a4c:	0a054863          	bltz	a0,80005afc <sys_open+0xe4>

  begin_op();
    80005a50:	fffff097          	auipc	ra,0xfffff
    80005a54:	952080e7          	jalr	-1710(ra) # 800043a2 <begin_op>

  if(omode & O_CREATE){
    80005a58:	f4c42783          	lw	a5,-180(s0)
    80005a5c:	2007f793          	andi	a5,a5,512
    80005a60:	cbdd                	beqz	a5,80005b16 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005a62:	4681                	li	a3,0
    80005a64:	4601                	li	a2,0
    80005a66:	4589                	li	a1,2
    80005a68:	f5040513          	addi	a0,s0,-176
    80005a6c:	00000097          	auipc	ra,0x0
    80005a70:	976080e7          	jalr	-1674(ra) # 800053e2 <create>
    80005a74:	892a                	mv	s2,a0
    if(ip == 0){
    80005a76:	c959                	beqz	a0,80005b0c <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a78:	04491703          	lh	a4,68(s2)
    80005a7c:	478d                	li	a5,3
    80005a7e:	00f71763          	bne	a4,a5,80005a8c <sys_open+0x74>
    80005a82:	04695703          	lhu	a4,70(s2)
    80005a86:	47a5                	li	a5,9
    80005a88:	0ce7ec63          	bltu	a5,a4,80005b60 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005a8c:	fffff097          	auipc	ra,0xfffff
    80005a90:	d48080e7          	jalr	-696(ra) # 800047d4 <filealloc>
    80005a94:	89aa                	mv	s3,a0
    80005a96:	10050263          	beqz	a0,80005b9a <sys_open+0x182>
    80005a9a:	00000097          	auipc	ra,0x0
    80005a9e:	900080e7          	jalr	-1792(ra) # 8000539a <fdalloc>
    80005aa2:	84aa                	mv	s1,a0
    80005aa4:	0e054663          	bltz	a0,80005b90 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005aa8:	04491703          	lh	a4,68(s2)
    80005aac:	478d                	li	a5,3
    80005aae:	0cf70463          	beq	a4,a5,80005b76 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ab2:	4789                	li	a5,2
    80005ab4:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005ab8:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005abc:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005ac0:	f4c42783          	lw	a5,-180(s0)
    80005ac4:	0017c713          	xori	a4,a5,1
    80005ac8:	8b05                	andi	a4,a4,1
    80005aca:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005ace:	0037f713          	andi	a4,a5,3
    80005ad2:	00e03733          	snez	a4,a4
    80005ad6:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005ada:	4007f793          	andi	a5,a5,1024
    80005ade:	c791                	beqz	a5,80005aea <sys_open+0xd2>
    80005ae0:	04491703          	lh	a4,68(s2)
    80005ae4:	4789                	li	a5,2
    80005ae6:	08f70f63          	beq	a4,a5,80005b84 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005aea:	854a                	mv	a0,s2
    80005aec:	ffffe097          	auipc	ra,0xffffe
    80005af0:	fb2080e7          	jalr	-78(ra) # 80003a9e <iunlock>
  end_op();
    80005af4:	fffff097          	auipc	ra,0xfffff
    80005af8:	92e080e7          	jalr	-1746(ra) # 80004422 <end_op>

  return fd;
}
    80005afc:	8526                	mv	a0,s1
    80005afe:	70ea                	ld	ra,184(sp)
    80005b00:	744a                	ld	s0,176(sp)
    80005b02:	74aa                	ld	s1,168(sp)
    80005b04:	790a                	ld	s2,160(sp)
    80005b06:	69ea                	ld	s3,152(sp)
    80005b08:	6129                	addi	sp,sp,192
    80005b0a:	8082                	ret
      end_op();
    80005b0c:	fffff097          	auipc	ra,0xfffff
    80005b10:	916080e7          	jalr	-1770(ra) # 80004422 <end_op>
      return -1;
    80005b14:	b7e5                	j	80005afc <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005b16:	f5040513          	addi	a0,s0,-176
    80005b1a:	ffffe097          	auipc	ra,0xffffe
    80005b1e:	67a080e7          	jalr	1658(ra) # 80004194 <namei>
    80005b22:	892a                	mv	s2,a0
    80005b24:	c905                	beqz	a0,80005b54 <sys_open+0x13c>
    ilock(ip);
    80005b26:	ffffe097          	auipc	ra,0xffffe
    80005b2a:	eb4080e7          	jalr	-332(ra) # 800039da <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b2e:	04491703          	lh	a4,68(s2)
    80005b32:	4785                	li	a5,1
    80005b34:	f4f712e3          	bne	a4,a5,80005a78 <sys_open+0x60>
    80005b38:	f4c42783          	lw	a5,-180(s0)
    80005b3c:	dba1                	beqz	a5,80005a8c <sys_open+0x74>
      iunlockput(ip);
    80005b3e:	854a                	mv	a0,s2
    80005b40:	ffffe097          	auipc	ra,0xffffe
    80005b44:	0fe080e7          	jalr	254(ra) # 80003c3e <iunlockput>
      end_op();
    80005b48:	fffff097          	auipc	ra,0xfffff
    80005b4c:	8da080e7          	jalr	-1830(ra) # 80004422 <end_op>
      return -1;
    80005b50:	54fd                	li	s1,-1
    80005b52:	b76d                	j	80005afc <sys_open+0xe4>
      end_op();
    80005b54:	fffff097          	auipc	ra,0xfffff
    80005b58:	8ce080e7          	jalr	-1842(ra) # 80004422 <end_op>
      return -1;
    80005b5c:	54fd                	li	s1,-1
    80005b5e:	bf79                	j	80005afc <sys_open+0xe4>
    iunlockput(ip);
    80005b60:	854a                	mv	a0,s2
    80005b62:	ffffe097          	auipc	ra,0xffffe
    80005b66:	0dc080e7          	jalr	220(ra) # 80003c3e <iunlockput>
    end_op();
    80005b6a:	fffff097          	auipc	ra,0xfffff
    80005b6e:	8b8080e7          	jalr	-1864(ra) # 80004422 <end_op>
    return -1;
    80005b72:	54fd                	li	s1,-1
    80005b74:	b761                	j	80005afc <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005b76:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005b7a:	04691783          	lh	a5,70(s2)
    80005b7e:	02f99223          	sh	a5,36(s3)
    80005b82:	bf2d                	j	80005abc <sys_open+0xa4>
    itrunc(ip);
    80005b84:	854a                	mv	a0,s2
    80005b86:	ffffe097          	auipc	ra,0xffffe
    80005b8a:	f64080e7          	jalr	-156(ra) # 80003aea <itrunc>
    80005b8e:	bfb1                	j	80005aea <sys_open+0xd2>
      fileclose(f);
    80005b90:	854e                	mv	a0,s3
    80005b92:	fffff097          	auipc	ra,0xfffff
    80005b96:	d12080e7          	jalr	-750(ra) # 800048a4 <fileclose>
    iunlockput(ip);
    80005b9a:	854a                	mv	a0,s2
    80005b9c:	ffffe097          	auipc	ra,0xffffe
    80005ba0:	0a2080e7          	jalr	162(ra) # 80003c3e <iunlockput>
    end_op();
    80005ba4:	fffff097          	auipc	ra,0xfffff
    80005ba8:	87e080e7          	jalr	-1922(ra) # 80004422 <end_op>
    return -1;
    80005bac:	54fd                	li	s1,-1
    80005bae:	b7b9                	j	80005afc <sys_open+0xe4>

0000000080005bb0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005bb0:	7175                	addi	sp,sp,-144
    80005bb2:	e506                	sd	ra,136(sp)
    80005bb4:	e122                	sd	s0,128(sp)
    80005bb6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005bb8:	ffffe097          	auipc	ra,0xffffe
    80005bbc:	7ea080e7          	jalr	2026(ra) # 800043a2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005bc0:	08000613          	li	a2,128
    80005bc4:	f7040593          	addi	a1,s0,-144
    80005bc8:	4501                	li	a0,0
    80005bca:	ffffd097          	auipc	ra,0xffffd
    80005bce:	294080e7          	jalr	660(ra) # 80002e5e <argstr>
    80005bd2:	02054963          	bltz	a0,80005c04 <sys_mkdir+0x54>
    80005bd6:	4681                	li	a3,0
    80005bd8:	4601                	li	a2,0
    80005bda:	4585                	li	a1,1
    80005bdc:	f7040513          	addi	a0,s0,-144
    80005be0:	00000097          	auipc	ra,0x0
    80005be4:	802080e7          	jalr	-2046(ra) # 800053e2 <create>
    80005be8:	cd11                	beqz	a0,80005c04 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bea:	ffffe097          	auipc	ra,0xffffe
    80005bee:	054080e7          	jalr	84(ra) # 80003c3e <iunlockput>
  end_op();
    80005bf2:	fffff097          	auipc	ra,0xfffff
    80005bf6:	830080e7          	jalr	-2000(ra) # 80004422 <end_op>
  return 0;
    80005bfa:	4501                	li	a0,0
}
    80005bfc:	60aa                	ld	ra,136(sp)
    80005bfe:	640a                	ld	s0,128(sp)
    80005c00:	6149                	addi	sp,sp,144
    80005c02:	8082                	ret
    end_op();
    80005c04:	fffff097          	auipc	ra,0xfffff
    80005c08:	81e080e7          	jalr	-2018(ra) # 80004422 <end_op>
    return -1;
    80005c0c:	557d                	li	a0,-1
    80005c0e:	b7fd                	j	80005bfc <sys_mkdir+0x4c>

0000000080005c10 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c10:	7135                	addi	sp,sp,-160
    80005c12:	ed06                	sd	ra,152(sp)
    80005c14:	e922                	sd	s0,144(sp)
    80005c16:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c18:	ffffe097          	auipc	ra,0xffffe
    80005c1c:	78a080e7          	jalr	1930(ra) # 800043a2 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c20:	08000613          	li	a2,128
    80005c24:	f7040593          	addi	a1,s0,-144
    80005c28:	4501                	li	a0,0
    80005c2a:	ffffd097          	auipc	ra,0xffffd
    80005c2e:	234080e7          	jalr	564(ra) # 80002e5e <argstr>
    80005c32:	04054a63          	bltz	a0,80005c86 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005c36:	f6c40593          	addi	a1,s0,-148
    80005c3a:	4505                	li	a0,1
    80005c3c:	ffffd097          	auipc	ra,0xffffd
    80005c40:	1de080e7          	jalr	478(ra) # 80002e1a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c44:	04054163          	bltz	a0,80005c86 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005c48:	f6840593          	addi	a1,s0,-152
    80005c4c:	4509                	li	a0,2
    80005c4e:	ffffd097          	auipc	ra,0xffffd
    80005c52:	1cc080e7          	jalr	460(ra) # 80002e1a <argint>
     argint(1, &major) < 0 ||
    80005c56:	02054863          	bltz	a0,80005c86 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c5a:	f6841683          	lh	a3,-152(s0)
    80005c5e:	f6c41603          	lh	a2,-148(s0)
    80005c62:	458d                	li	a1,3
    80005c64:	f7040513          	addi	a0,s0,-144
    80005c68:	fffff097          	auipc	ra,0xfffff
    80005c6c:	77a080e7          	jalr	1914(ra) # 800053e2 <create>
     argint(2, &minor) < 0 ||
    80005c70:	c919                	beqz	a0,80005c86 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c72:	ffffe097          	auipc	ra,0xffffe
    80005c76:	fcc080e7          	jalr	-52(ra) # 80003c3e <iunlockput>
  end_op();
    80005c7a:	ffffe097          	auipc	ra,0xffffe
    80005c7e:	7a8080e7          	jalr	1960(ra) # 80004422 <end_op>
  return 0;
    80005c82:	4501                	li	a0,0
    80005c84:	a031                	j	80005c90 <sys_mknod+0x80>
    end_op();
    80005c86:	ffffe097          	auipc	ra,0xffffe
    80005c8a:	79c080e7          	jalr	1948(ra) # 80004422 <end_op>
    return -1;
    80005c8e:	557d                	li	a0,-1
}
    80005c90:	60ea                	ld	ra,152(sp)
    80005c92:	644a                	ld	s0,144(sp)
    80005c94:	610d                	addi	sp,sp,160
    80005c96:	8082                	ret

0000000080005c98 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c98:	7135                	addi	sp,sp,-160
    80005c9a:	ed06                	sd	ra,152(sp)
    80005c9c:	e922                	sd	s0,144(sp)
    80005c9e:	e526                	sd	s1,136(sp)
    80005ca0:	e14a                	sd	s2,128(sp)
    80005ca2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ca4:	ffffc097          	auipc	ra,0xffffc
    80005ca8:	df6080e7          	jalr	-522(ra) # 80001a9a <myproc>
    80005cac:	892a                	mv	s2,a0
  
  begin_op();
    80005cae:	ffffe097          	auipc	ra,0xffffe
    80005cb2:	6f4080e7          	jalr	1780(ra) # 800043a2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005cb6:	08000613          	li	a2,128
    80005cba:	f6040593          	addi	a1,s0,-160
    80005cbe:	4501                	li	a0,0
    80005cc0:	ffffd097          	auipc	ra,0xffffd
    80005cc4:	19e080e7          	jalr	414(ra) # 80002e5e <argstr>
    80005cc8:	04054b63          	bltz	a0,80005d1e <sys_chdir+0x86>
    80005ccc:	f6040513          	addi	a0,s0,-160
    80005cd0:	ffffe097          	auipc	ra,0xffffe
    80005cd4:	4c4080e7          	jalr	1220(ra) # 80004194 <namei>
    80005cd8:	84aa                	mv	s1,a0
    80005cda:	c131                	beqz	a0,80005d1e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005cdc:	ffffe097          	auipc	ra,0xffffe
    80005ce0:	cfe080e7          	jalr	-770(ra) # 800039da <ilock>
  if(ip->type != T_DIR){
    80005ce4:	04449703          	lh	a4,68(s1)
    80005ce8:	4785                	li	a5,1
    80005cea:	04f71063          	bne	a4,a5,80005d2a <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005cee:	8526                	mv	a0,s1
    80005cf0:	ffffe097          	auipc	ra,0xffffe
    80005cf4:	dae080e7          	jalr	-594(ra) # 80003a9e <iunlock>
  iput(p->cwd);
    80005cf8:	15893503          	ld	a0,344(s2)
    80005cfc:	ffffe097          	auipc	ra,0xffffe
    80005d00:	e9a080e7          	jalr	-358(ra) # 80003b96 <iput>
  end_op();
    80005d04:	ffffe097          	auipc	ra,0xffffe
    80005d08:	71e080e7          	jalr	1822(ra) # 80004422 <end_op>
  p->cwd = ip;
    80005d0c:	14993c23          	sd	s1,344(s2)
  return 0;
    80005d10:	4501                	li	a0,0
}
    80005d12:	60ea                	ld	ra,152(sp)
    80005d14:	644a                	ld	s0,144(sp)
    80005d16:	64aa                	ld	s1,136(sp)
    80005d18:	690a                	ld	s2,128(sp)
    80005d1a:	610d                	addi	sp,sp,160
    80005d1c:	8082                	ret
    end_op();
    80005d1e:	ffffe097          	auipc	ra,0xffffe
    80005d22:	704080e7          	jalr	1796(ra) # 80004422 <end_op>
    return -1;
    80005d26:	557d                	li	a0,-1
    80005d28:	b7ed                	j	80005d12 <sys_chdir+0x7a>
    iunlockput(ip);
    80005d2a:	8526                	mv	a0,s1
    80005d2c:	ffffe097          	auipc	ra,0xffffe
    80005d30:	f12080e7          	jalr	-238(ra) # 80003c3e <iunlockput>
    end_op();
    80005d34:	ffffe097          	auipc	ra,0xffffe
    80005d38:	6ee080e7          	jalr	1774(ra) # 80004422 <end_op>
    return -1;
    80005d3c:	557d                	li	a0,-1
    80005d3e:	bfd1                	j	80005d12 <sys_chdir+0x7a>

0000000080005d40 <sys_exec>:

uint64
sys_exec(void)
{
    80005d40:	7145                	addi	sp,sp,-464
    80005d42:	e786                	sd	ra,456(sp)
    80005d44:	e3a2                	sd	s0,448(sp)
    80005d46:	ff26                	sd	s1,440(sp)
    80005d48:	fb4a                	sd	s2,432(sp)
    80005d4a:	f74e                	sd	s3,424(sp)
    80005d4c:	f352                	sd	s4,416(sp)
    80005d4e:	ef56                	sd	s5,408(sp)
    80005d50:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d52:	08000613          	li	a2,128
    80005d56:	f4040593          	addi	a1,s0,-192
    80005d5a:	4501                	li	a0,0
    80005d5c:	ffffd097          	auipc	ra,0xffffd
    80005d60:	102080e7          	jalr	258(ra) # 80002e5e <argstr>
    return -1;
    80005d64:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d66:	0e054c63          	bltz	a0,80005e5e <sys_exec+0x11e>
    80005d6a:	e3840593          	addi	a1,s0,-456
    80005d6e:	4505                	li	a0,1
    80005d70:	ffffd097          	auipc	ra,0xffffd
    80005d74:	0cc080e7          	jalr	204(ra) # 80002e3c <argaddr>
    80005d78:	0e054363          	bltz	a0,80005e5e <sys_exec+0x11e>
  }
  memset(argv, 0, sizeof(argv));
    80005d7c:	e4040913          	addi	s2,s0,-448
    80005d80:	10000613          	li	a2,256
    80005d84:	4581                	li	a1,0
    80005d86:	854a                	mv	a0,s2
    80005d88:	ffffb097          	auipc	ra,0xffffb
    80005d8c:	fd6080e7          	jalr	-42(ra) # 80000d5e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d90:	89ca                	mv	s3,s2
  memset(argv, 0, sizeof(argv));
    80005d92:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005d94:	02000a93          	li	s5,32
    80005d98:	00048a1b          	sext.w	s4,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d9c:	00349513          	slli	a0,s1,0x3
    80005da0:	e3040593          	addi	a1,s0,-464
    80005da4:	e3843783          	ld	a5,-456(s0)
    80005da8:	953e                	add	a0,a0,a5
    80005daa:	ffffd097          	auipc	ra,0xffffd
    80005dae:	fd4080e7          	jalr	-44(ra) # 80002d7e <fetchaddr>
    80005db2:	02054a63          	bltz	a0,80005de6 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005db6:	e3043783          	ld	a5,-464(s0)
    80005dba:	cfa9                	beqz	a5,80005e14 <sys_exec+0xd4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005dbc:	ffffb097          	auipc	ra,0xffffb
    80005dc0:	db6080e7          	jalr	-586(ra) # 80000b72 <kalloc>
    80005dc4:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80005dc8:	cd19                	beqz	a0,80005de6 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005dca:	6605                	lui	a2,0x1
    80005dcc:	85aa                	mv	a1,a0
    80005dce:	e3043503          	ld	a0,-464(s0)
    80005dd2:	ffffd097          	auipc	ra,0xffffd
    80005dd6:	000080e7          	jalr	ra # 80002dd2 <fetchstr>
    80005dda:	00054663          	bltz	a0,80005de6 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005dde:	0485                	addi	s1,s1,1
    80005de0:	0921                	addi	s2,s2,8
    80005de2:	fb549be3          	bne	s1,s5,80005d98 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005de6:	e4043503          	ld	a0,-448(s0)
    kfree(argv[i]);
  return -1;
    80005dea:	597d                	li	s2,-1
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dec:	c92d                	beqz	a0,80005e5e <sys_exec+0x11e>
    kfree(argv[i]);
    80005dee:	ffffb097          	auipc	ra,0xffffb
    80005df2:	c84080e7          	jalr	-892(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005df6:	e4840493          	addi	s1,s0,-440
    80005dfa:	10098993          	addi	s3,s3,256
    80005dfe:	6088                	ld	a0,0(s1)
    80005e00:	cd31                	beqz	a0,80005e5c <sys_exec+0x11c>
    kfree(argv[i]);
    80005e02:	ffffb097          	auipc	ra,0xffffb
    80005e06:	c70080e7          	jalr	-912(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e0a:	04a1                	addi	s1,s1,8
    80005e0c:	ff3499e3          	bne	s1,s3,80005dfe <sys_exec+0xbe>
  return -1;
    80005e10:	597d                	li	s2,-1
    80005e12:	a0b1                	j	80005e5e <sys_exec+0x11e>
      argv[i] = 0;
    80005e14:	0a0e                	slli	s4,s4,0x3
    80005e16:	fc040793          	addi	a5,s0,-64
    80005e1a:	9a3e                	add	s4,s4,a5
    80005e1c:	e80a3023          	sd	zero,-384(s4)
  int ret = exec(path, argv);
    80005e20:	e4040593          	addi	a1,s0,-448
    80005e24:	f4040513          	addi	a0,s0,-192
    80005e28:	fffff097          	auipc	ra,0xfffff
    80005e2c:	13c080e7          	jalr	316(ra) # 80004f64 <exec>
    80005e30:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e32:	e4043503          	ld	a0,-448(s0)
    80005e36:	c505                	beqz	a0,80005e5e <sys_exec+0x11e>
    kfree(argv[i]);
    80005e38:	ffffb097          	auipc	ra,0xffffb
    80005e3c:	c3a080e7          	jalr	-966(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e40:	e4840493          	addi	s1,s0,-440
    80005e44:	10098993          	addi	s3,s3,256
    80005e48:	6088                	ld	a0,0(s1)
    80005e4a:	c911                	beqz	a0,80005e5e <sys_exec+0x11e>
    kfree(argv[i]);
    80005e4c:	ffffb097          	auipc	ra,0xffffb
    80005e50:	c26080e7          	jalr	-986(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e54:	04a1                	addi	s1,s1,8
    80005e56:	ff3499e3          	bne	s1,s3,80005e48 <sys_exec+0x108>
    80005e5a:	a011                	j	80005e5e <sys_exec+0x11e>
  return -1;
    80005e5c:	597d                	li	s2,-1
}
    80005e5e:	854a                	mv	a0,s2
    80005e60:	60be                	ld	ra,456(sp)
    80005e62:	641e                	ld	s0,448(sp)
    80005e64:	74fa                	ld	s1,440(sp)
    80005e66:	795a                	ld	s2,432(sp)
    80005e68:	79ba                	ld	s3,424(sp)
    80005e6a:	7a1a                	ld	s4,416(sp)
    80005e6c:	6afa                	ld	s5,408(sp)
    80005e6e:	6179                	addi	sp,sp,464
    80005e70:	8082                	ret

0000000080005e72 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e72:	7139                	addi	sp,sp,-64
    80005e74:	fc06                	sd	ra,56(sp)
    80005e76:	f822                	sd	s0,48(sp)
    80005e78:	f426                	sd	s1,40(sp)
    80005e7a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e7c:	ffffc097          	auipc	ra,0xffffc
    80005e80:	c1e080e7          	jalr	-994(ra) # 80001a9a <myproc>
    80005e84:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005e86:	fd840593          	addi	a1,s0,-40
    80005e8a:	4501                	li	a0,0
    80005e8c:	ffffd097          	auipc	ra,0xffffd
    80005e90:	fb0080e7          	jalr	-80(ra) # 80002e3c <argaddr>
    return -1;
    80005e94:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005e96:	0c054f63          	bltz	a0,80005f74 <sys_pipe+0x102>
  if(pipealloc(&rf, &wf) < 0)
    80005e9a:	fc840593          	addi	a1,s0,-56
    80005e9e:	fd040513          	addi	a0,s0,-48
    80005ea2:	fffff097          	auipc	ra,0xfffff
    80005ea6:	d4a080e7          	jalr	-694(ra) # 80004bec <pipealloc>
    return -1;
    80005eaa:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005eac:	0c054463          	bltz	a0,80005f74 <sys_pipe+0x102>
  fd0 = -1;
    80005eb0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005eb4:	fd043503          	ld	a0,-48(s0)
    80005eb8:	fffff097          	auipc	ra,0xfffff
    80005ebc:	4e2080e7          	jalr	1250(ra) # 8000539a <fdalloc>
    80005ec0:	fca42223          	sw	a0,-60(s0)
    80005ec4:	08054b63          	bltz	a0,80005f5a <sys_pipe+0xe8>
    80005ec8:	fc843503          	ld	a0,-56(s0)
    80005ecc:	fffff097          	auipc	ra,0xfffff
    80005ed0:	4ce080e7          	jalr	1230(ra) # 8000539a <fdalloc>
    80005ed4:	fca42023          	sw	a0,-64(s0)
    80005ed8:	06054863          	bltz	a0,80005f48 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005edc:	4691                	li	a3,4
    80005ede:	fc440613          	addi	a2,s0,-60
    80005ee2:	fd843583          	ld	a1,-40(s0)
    80005ee6:	68a8                	ld	a0,80(s1)
    80005ee8:	ffffc097          	auipc	ra,0xffffc
    80005eec:	872080e7          	jalr	-1934(ra) # 8000175a <copyout>
    80005ef0:	02054063          	bltz	a0,80005f10 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005ef4:	4691                	li	a3,4
    80005ef6:	fc040613          	addi	a2,s0,-64
    80005efa:	fd843583          	ld	a1,-40(s0)
    80005efe:	0591                	addi	a1,a1,4
    80005f00:	68a8                	ld	a0,80(s1)
    80005f02:	ffffc097          	auipc	ra,0xffffc
    80005f06:	858080e7          	jalr	-1960(ra) # 8000175a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f0a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f0c:	06055463          	bgez	a0,80005f74 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80005f10:	fc442783          	lw	a5,-60(s0)
    80005f14:	07e9                	addi	a5,a5,26
    80005f16:	078e                	slli	a5,a5,0x3
    80005f18:	97a6                	add	a5,a5,s1
    80005f1a:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005f1e:	fc042783          	lw	a5,-64(s0)
    80005f22:	07e9                	addi	a5,a5,26
    80005f24:	078e                	slli	a5,a5,0x3
    80005f26:	94be                	add	s1,s1,a5
    80005f28:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005f2c:	fd043503          	ld	a0,-48(s0)
    80005f30:	fffff097          	auipc	ra,0xfffff
    80005f34:	974080e7          	jalr	-1676(ra) # 800048a4 <fileclose>
    fileclose(wf);
    80005f38:	fc843503          	ld	a0,-56(s0)
    80005f3c:	fffff097          	auipc	ra,0xfffff
    80005f40:	968080e7          	jalr	-1688(ra) # 800048a4 <fileclose>
    return -1;
    80005f44:	57fd                	li	a5,-1
    80005f46:	a03d                	j	80005f74 <sys_pipe+0x102>
    if(fd0 >= 0)
    80005f48:	fc442783          	lw	a5,-60(s0)
    80005f4c:	0007c763          	bltz	a5,80005f5a <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005f50:	07e9                	addi	a5,a5,26
    80005f52:	078e                	slli	a5,a5,0x3
    80005f54:	94be                	add	s1,s1,a5
    80005f56:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005f5a:	fd043503          	ld	a0,-48(s0)
    80005f5e:	fffff097          	auipc	ra,0xfffff
    80005f62:	946080e7          	jalr	-1722(ra) # 800048a4 <fileclose>
    fileclose(wf);
    80005f66:	fc843503          	ld	a0,-56(s0)
    80005f6a:	fffff097          	auipc	ra,0xfffff
    80005f6e:	93a080e7          	jalr	-1734(ra) # 800048a4 <fileclose>
    return -1;
    80005f72:	57fd                	li	a5,-1
}
    80005f74:	853e                	mv	a0,a5
    80005f76:	70e2                	ld	ra,56(sp)
    80005f78:	7442                	ld	s0,48(sp)
    80005f7a:	74a2                	ld	s1,40(sp)
    80005f7c:	6121                	addi	sp,sp,64
    80005f7e:	8082                	ret

0000000080005f80 <kernelvec>:
    80005f80:	7111                	addi	sp,sp,-256
    80005f82:	e006                	sd	ra,0(sp)
    80005f84:	e40a                	sd	sp,8(sp)
    80005f86:	e80e                	sd	gp,16(sp)
    80005f88:	ec12                	sd	tp,24(sp)
    80005f8a:	f016                	sd	t0,32(sp)
    80005f8c:	f41a                	sd	t1,40(sp)
    80005f8e:	f81e                	sd	t2,48(sp)
    80005f90:	fc22                	sd	s0,56(sp)
    80005f92:	e0a6                	sd	s1,64(sp)
    80005f94:	e4aa                	sd	a0,72(sp)
    80005f96:	e8ae                	sd	a1,80(sp)
    80005f98:	ecb2                	sd	a2,88(sp)
    80005f9a:	f0b6                	sd	a3,96(sp)
    80005f9c:	f4ba                	sd	a4,104(sp)
    80005f9e:	f8be                	sd	a5,112(sp)
    80005fa0:	fcc2                	sd	a6,120(sp)
    80005fa2:	e146                	sd	a7,128(sp)
    80005fa4:	e54a                	sd	s2,136(sp)
    80005fa6:	e94e                	sd	s3,144(sp)
    80005fa8:	ed52                	sd	s4,152(sp)
    80005faa:	f156                	sd	s5,160(sp)
    80005fac:	f55a                	sd	s6,168(sp)
    80005fae:	f95e                	sd	s7,176(sp)
    80005fb0:	fd62                	sd	s8,184(sp)
    80005fb2:	e1e6                	sd	s9,192(sp)
    80005fb4:	e5ea                	sd	s10,200(sp)
    80005fb6:	e9ee                	sd	s11,208(sp)
    80005fb8:	edf2                	sd	t3,216(sp)
    80005fba:	f1f6                	sd	t4,224(sp)
    80005fbc:	f5fa                	sd	t5,232(sp)
    80005fbe:	f9fe                	sd	t6,240(sp)
    80005fc0:	c87fc0ef          	jal	ra,80002c46 <kerneltrap>
    80005fc4:	6082                	ld	ra,0(sp)
    80005fc6:	6122                	ld	sp,8(sp)
    80005fc8:	61c2                	ld	gp,16(sp)
    80005fca:	7282                	ld	t0,32(sp)
    80005fcc:	7322                	ld	t1,40(sp)
    80005fce:	73c2                	ld	t2,48(sp)
    80005fd0:	7462                	ld	s0,56(sp)
    80005fd2:	6486                	ld	s1,64(sp)
    80005fd4:	6526                	ld	a0,72(sp)
    80005fd6:	65c6                	ld	a1,80(sp)
    80005fd8:	6666                	ld	a2,88(sp)
    80005fda:	7686                	ld	a3,96(sp)
    80005fdc:	7726                	ld	a4,104(sp)
    80005fde:	77c6                	ld	a5,112(sp)
    80005fe0:	7866                	ld	a6,120(sp)
    80005fe2:	688a                	ld	a7,128(sp)
    80005fe4:	692a                	ld	s2,136(sp)
    80005fe6:	69ca                	ld	s3,144(sp)
    80005fe8:	6a6a                	ld	s4,152(sp)
    80005fea:	7a8a                	ld	s5,160(sp)
    80005fec:	7b2a                	ld	s6,168(sp)
    80005fee:	7bca                	ld	s7,176(sp)
    80005ff0:	7c6a                	ld	s8,184(sp)
    80005ff2:	6c8e                	ld	s9,192(sp)
    80005ff4:	6d2e                	ld	s10,200(sp)
    80005ff6:	6dce                	ld	s11,208(sp)
    80005ff8:	6e6e                	ld	t3,216(sp)
    80005ffa:	7e8e                	ld	t4,224(sp)
    80005ffc:	7f2e                	ld	t5,232(sp)
    80005ffe:	7fce                	ld	t6,240(sp)
    80006000:	6111                	addi	sp,sp,256
    80006002:	10200073          	sret
    80006006:	00000013          	nop
    8000600a:	00000013          	nop
    8000600e:	0001                	nop

0000000080006010 <timervec>:
    80006010:	34051573          	csrrw	a0,mscratch,a0
    80006014:	e10c                	sd	a1,0(a0)
    80006016:	e510                	sd	a2,8(a0)
    80006018:	e914                	sd	a3,16(a0)
    8000601a:	710c                	ld	a1,32(a0)
    8000601c:	7510                	ld	a2,40(a0)
    8000601e:	6194                	ld	a3,0(a1)
    80006020:	96b2                	add	a3,a3,a2
    80006022:	e194                	sd	a3,0(a1)
    80006024:	4589                	li	a1,2
    80006026:	14459073          	csrw	sip,a1
    8000602a:	6914                	ld	a3,16(a0)
    8000602c:	6510                	ld	a2,8(a0)
    8000602e:	610c                	ld	a1,0(a0)
    80006030:	34051573          	csrrw	a0,mscratch,a0
    80006034:	30200073          	mret
	...

000000008000603a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000603a:	1141                	addi	sp,sp,-16
    8000603c:	e422                	sd	s0,8(sp)
    8000603e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006040:	0c0007b7          	lui	a5,0xc000
    80006044:	4705                	li	a4,1
    80006046:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006048:	c3d8                	sw	a4,4(a5)
}
    8000604a:	6422                	ld	s0,8(sp)
    8000604c:	0141                	addi	sp,sp,16
    8000604e:	8082                	ret

0000000080006050 <plicinithart>:

void
plicinithart(void)
{
    80006050:	1141                	addi	sp,sp,-16
    80006052:	e406                	sd	ra,8(sp)
    80006054:	e022                	sd	s0,0(sp)
    80006056:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006058:	ffffc097          	auipc	ra,0xffffc
    8000605c:	a16080e7          	jalr	-1514(ra) # 80001a6e <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006060:	0085171b          	slliw	a4,a0,0x8
    80006064:	0c0027b7          	lui	a5,0xc002
    80006068:	97ba                	add	a5,a5,a4
    8000606a:	40200713          	li	a4,1026
    8000606e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006072:	00d5151b          	slliw	a0,a0,0xd
    80006076:	0c2017b7          	lui	a5,0xc201
    8000607a:	953e                	add	a0,a0,a5
    8000607c:	00052023          	sw	zero,0(a0)
}
    80006080:	60a2                	ld	ra,8(sp)
    80006082:	6402                	ld	s0,0(sp)
    80006084:	0141                	addi	sp,sp,16
    80006086:	8082                	ret

0000000080006088 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006088:	1141                	addi	sp,sp,-16
    8000608a:	e406                	sd	ra,8(sp)
    8000608c:	e022                	sd	s0,0(sp)
    8000608e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006090:	ffffc097          	auipc	ra,0xffffc
    80006094:	9de080e7          	jalr	-1570(ra) # 80001a6e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006098:	00d5151b          	slliw	a0,a0,0xd
    8000609c:	0c2017b7          	lui	a5,0xc201
    800060a0:	97aa                	add	a5,a5,a0
  return irq;
}
    800060a2:	43c8                	lw	a0,4(a5)
    800060a4:	60a2                	ld	ra,8(sp)
    800060a6:	6402                	ld	s0,0(sp)
    800060a8:	0141                	addi	sp,sp,16
    800060aa:	8082                	ret

00000000800060ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800060ac:	1101                	addi	sp,sp,-32
    800060ae:	ec06                	sd	ra,24(sp)
    800060b0:	e822                	sd	s0,16(sp)
    800060b2:	e426                	sd	s1,8(sp)
    800060b4:	1000                	addi	s0,sp,32
    800060b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800060b8:	ffffc097          	auipc	ra,0xffffc
    800060bc:	9b6080e7          	jalr	-1610(ra) # 80001a6e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800060c0:	00d5151b          	slliw	a0,a0,0xd
    800060c4:	0c2017b7          	lui	a5,0xc201
    800060c8:	97aa                	add	a5,a5,a0
    800060ca:	c3c4                	sw	s1,4(a5)
}
    800060cc:	60e2                	ld	ra,24(sp)
    800060ce:	6442                	ld	s0,16(sp)
    800060d0:	64a2                	ld	s1,8(sp)
    800060d2:	6105                	addi	sp,sp,32
    800060d4:	8082                	ret

00000000800060d6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800060d6:	1141                	addi	sp,sp,-16
    800060d8:	e406                	sd	ra,8(sp)
    800060da:	e022                	sd	s0,0(sp)
    800060dc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800060de:	479d                	li	a5,7
    800060e0:	04a7cd63          	blt	a5,a0,8000613a <free_desc+0x64>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    800060e4:	0001d797          	auipc	a5,0x1d
    800060e8:	f1c78793          	addi	a5,a5,-228 # 80023000 <disk>
    800060ec:	00a78733          	add	a4,a5,a0
    800060f0:	6789                	lui	a5,0x2
    800060f2:	97ba                	add	a5,a5,a4
    800060f4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800060f8:	eba9                	bnez	a5,8000614a <free_desc+0x74>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    800060fa:	0001f797          	auipc	a5,0x1f
    800060fe:	f0678793          	addi	a5,a5,-250 # 80025000 <disk+0x2000>
    80006102:	639c                	ld	a5,0(a5)
    80006104:	00451713          	slli	a4,a0,0x4
    80006108:	97ba                	add	a5,a5,a4
    8000610a:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    8000610e:	0001d797          	auipc	a5,0x1d
    80006112:	ef278793          	addi	a5,a5,-270 # 80023000 <disk>
    80006116:	97aa                	add	a5,a5,a0
    80006118:	6509                	lui	a0,0x2
    8000611a:	953e                	add	a0,a0,a5
    8000611c:	4785                	li	a5,1
    8000611e:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006122:	0001f517          	auipc	a0,0x1f
    80006126:	ef650513          	addi	a0,a0,-266 # 80025018 <disk+0x2018>
    8000612a:	ffffc097          	auipc	ra,0xffffc
    8000612e:	5c0080e7          	jalr	1472(ra) # 800026ea <wakeup>
}
    80006132:	60a2                	ld	ra,8(sp)
    80006134:	6402                	ld	s0,0(sp)
    80006136:	0141                	addi	sp,sp,16
    80006138:	8082                	ret
    panic("virtio_disk_intr 1");
    8000613a:	00002517          	auipc	a0,0x2
    8000613e:	6b650513          	addi	a0,a0,1718 # 800087f0 <syscalls+0x350>
    80006142:	ffffa097          	auipc	ra,0xffffa
    80006146:	432080e7          	jalr	1074(ra) # 80000574 <panic>
    panic("virtio_disk_intr 2");
    8000614a:	00002517          	auipc	a0,0x2
    8000614e:	6be50513          	addi	a0,a0,1726 # 80008808 <syscalls+0x368>
    80006152:	ffffa097          	auipc	ra,0xffffa
    80006156:	422080e7          	jalr	1058(ra) # 80000574 <panic>

000000008000615a <virtio_disk_init>:
{
    8000615a:	1101                	addi	sp,sp,-32
    8000615c:	ec06                	sd	ra,24(sp)
    8000615e:	e822                	sd	s0,16(sp)
    80006160:	e426                	sd	s1,8(sp)
    80006162:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006164:	00002597          	auipc	a1,0x2
    80006168:	6bc58593          	addi	a1,a1,1724 # 80008820 <syscalls+0x380>
    8000616c:	0001f517          	auipc	a0,0x1f
    80006170:	f3c50513          	addi	a0,a0,-196 # 800250a8 <disk+0x20a8>
    80006174:	ffffb097          	auipc	ra,0xffffb
    80006178:	a5e080e7          	jalr	-1442(ra) # 80000bd2 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000617c:	100017b7          	lui	a5,0x10001
    80006180:	4398                	lw	a4,0(a5)
    80006182:	2701                	sext.w	a4,a4
    80006184:	747277b7          	lui	a5,0x74727
    80006188:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000618c:	0ef71163          	bne	a4,a5,8000626e <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006190:	100017b7          	lui	a5,0x10001
    80006194:	43dc                	lw	a5,4(a5)
    80006196:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006198:	4705                	li	a4,1
    8000619a:	0ce79a63          	bne	a5,a4,8000626e <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000619e:	100017b7          	lui	a5,0x10001
    800061a2:	479c                	lw	a5,8(a5)
    800061a4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800061a6:	4709                	li	a4,2
    800061a8:	0ce79363          	bne	a5,a4,8000626e <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800061ac:	100017b7          	lui	a5,0x10001
    800061b0:	47d8                	lw	a4,12(a5)
    800061b2:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061b4:	554d47b7          	lui	a5,0x554d4
    800061b8:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800061bc:	0af71963          	bne	a4,a5,8000626e <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061c0:	100017b7          	lui	a5,0x10001
    800061c4:	4705                	li	a4,1
    800061c6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061c8:	470d                	li	a4,3
    800061ca:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800061cc:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800061ce:	c7ffe737          	lui	a4,0xc7ffe
    800061d2:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd773f>
    800061d6:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061d8:	2701                	sext.w	a4,a4
    800061da:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061dc:	472d                	li	a4,11
    800061de:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061e0:	473d                	li	a4,15
    800061e2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800061e4:	6705                	lui	a4,0x1
    800061e6:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800061e8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800061ec:	5bdc                	lw	a5,52(a5)
    800061ee:	2781                	sext.w	a5,a5
  if(max == 0)
    800061f0:	c7d9                	beqz	a5,8000627e <virtio_disk_init+0x124>
  if(max < NUM)
    800061f2:	471d                	li	a4,7
    800061f4:	08f77d63          	bleu	a5,a4,8000628e <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061f8:	100014b7          	lui	s1,0x10001
    800061fc:	47a1                	li	a5,8
    800061fe:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006200:	6609                	lui	a2,0x2
    80006202:	4581                	li	a1,0
    80006204:	0001d517          	auipc	a0,0x1d
    80006208:	dfc50513          	addi	a0,a0,-516 # 80023000 <disk>
    8000620c:	ffffb097          	auipc	ra,0xffffb
    80006210:	b52080e7          	jalr	-1198(ra) # 80000d5e <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006214:	0001d717          	auipc	a4,0x1d
    80006218:	dec70713          	addi	a4,a4,-532 # 80023000 <disk>
    8000621c:	00c75793          	srli	a5,a4,0xc
    80006220:	2781                	sext.w	a5,a5
    80006222:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80006224:	0001f797          	auipc	a5,0x1f
    80006228:	ddc78793          	addi	a5,a5,-548 # 80025000 <disk+0x2000>
    8000622c:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    8000622e:	0001d717          	auipc	a4,0x1d
    80006232:	e5270713          	addi	a4,a4,-430 # 80023080 <disk+0x80>
    80006236:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80006238:	0001e717          	auipc	a4,0x1e
    8000623c:	dc870713          	addi	a4,a4,-568 # 80024000 <disk+0x1000>
    80006240:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006242:	4705                	li	a4,1
    80006244:	00e78c23          	sb	a4,24(a5)
    80006248:	00e78ca3          	sb	a4,25(a5)
    8000624c:	00e78d23          	sb	a4,26(a5)
    80006250:	00e78da3          	sb	a4,27(a5)
    80006254:	00e78e23          	sb	a4,28(a5)
    80006258:	00e78ea3          	sb	a4,29(a5)
    8000625c:	00e78f23          	sb	a4,30(a5)
    80006260:	00e78fa3          	sb	a4,31(a5)
}
    80006264:	60e2                	ld	ra,24(sp)
    80006266:	6442                	ld	s0,16(sp)
    80006268:	64a2                	ld	s1,8(sp)
    8000626a:	6105                	addi	sp,sp,32
    8000626c:	8082                	ret
    panic("could not find virtio disk");
    8000626e:	00002517          	auipc	a0,0x2
    80006272:	5c250513          	addi	a0,a0,1474 # 80008830 <syscalls+0x390>
    80006276:	ffffa097          	auipc	ra,0xffffa
    8000627a:	2fe080e7          	jalr	766(ra) # 80000574 <panic>
    panic("virtio disk has no queue 0");
    8000627e:	00002517          	auipc	a0,0x2
    80006282:	5d250513          	addi	a0,a0,1490 # 80008850 <syscalls+0x3b0>
    80006286:	ffffa097          	auipc	ra,0xffffa
    8000628a:	2ee080e7          	jalr	750(ra) # 80000574 <panic>
    panic("virtio disk max queue too short");
    8000628e:	00002517          	auipc	a0,0x2
    80006292:	5e250513          	addi	a0,a0,1506 # 80008870 <syscalls+0x3d0>
    80006296:	ffffa097          	auipc	ra,0xffffa
    8000629a:	2de080e7          	jalr	734(ra) # 80000574 <panic>

000000008000629e <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000629e:	7159                	addi	sp,sp,-112
    800062a0:	f486                	sd	ra,104(sp)
    800062a2:	f0a2                	sd	s0,96(sp)
    800062a4:	eca6                	sd	s1,88(sp)
    800062a6:	e8ca                	sd	s2,80(sp)
    800062a8:	e4ce                	sd	s3,72(sp)
    800062aa:	e0d2                	sd	s4,64(sp)
    800062ac:	fc56                	sd	s5,56(sp)
    800062ae:	f85a                	sd	s6,48(sp)
    800062b0:	f45e                	sd	s7,40(sp)
    800062b2:	f062                	sd	s8,32(sp)
    800062b4:	1880                	addi	s0,sp,112
    800062b6:	892a                	mv	s2,a0
    800062b8:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062ba:	00c52b83          	lw	s7,12(a0)
    800062be:	001b9b9b          	slliw	s7,s7,0x1
    800062c2:	1b82                	slli	s7,s7,0x20
    800062c4:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800062c8:	0001f517          	auipc	a0,0x1f
    800062cc:	de050513          	addi	a0,a0,-544 # 800250a8 <disk+0x20a8>
    800062d0:	ffffb097          	auipc	ra,0xffffb
    800062d4:	992080e7          	jalr	-1646(ra) # 80000c62 <acquire>
    if(disk.free[i]){
    800062d8:	0001f997          	auipc	s3,0x1f
    800062dc:	d2898993          	addi	s3,s3,-728 # 80025000 <disk+0x2000>
  for(int i = 0; i < NUM; i++){
    800062e0:	4b21                	li	s6,8
      disk.free[i] = 0;
    800062e2:	0001da97          	auipc	s5,0x1d
    800062e6:	d1ea8a93          	addi	s5,s5,-738 # 80023000 <disk>
  for(int i = 0; i < 3; i++){
    800062ea:	4a0d                	li	s4,3
    800062ec:	a079                	j	8000637a <virtio_disk_rw+0xdc>
      disk.free[i] = 0;
    800062ee:	00fa86b3          	add	a3,s5,a5
    800062f2:	96ae                	add	a3,a3,a1
    800062f4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800062f8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800062fa:	0207ca63          	bltz	a5,8000632e <virtio_disk_rw+0x90>
  for(int i = 0; i < 3; i++){
    800062fe:	2485                	addiw	s1,s1,1
    80006300:	0711                	addi	a4,a4,4
    80006302:	25448163          	beq	s1,s4,80006544 <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80006306:	863a                	mv	a2,a4
    if(disk.free[i]){
    80006308:	0189c783          	lbu	a5,24(s3)
    8000630c:	24079163          	bnez	a5,8000654e <virtio_disk_rw+0x2b0>
    80006310:	0001f697          	auipc	a3,0x1f
    80006314:	d0968693          	addi	a3,a3,-759 # 80025019 <disk+0x2019>
  for(int i = 0; i < NUM; i++){
    80006318:	87aa                	mv	a5,a0
    if(disk.free[i]){
    8000631a:	0006c803          	lbu	a6,0(a3)
    8000631e:	fc0818e3          	bnez	a6,800062ee <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80006322:	2785                	addiw	a5,a5,1
    80006324:	0685                	addi	a3,a3,1
    80006326:	ff679ae3          	bne	a5,s6,8000631a <virtio_disk_rw+0x7c>
    idx[i] = alloc_desc();
    8000632a:	57fd                	li	a5,-1
    8000632c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000632e:	02905a63          	blez	s1,80006362 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    80006332:	fa042503          	lw	a0,-96(s0)
    80006336:	00000097          	auipc	ra,0x0
    8000633a:	da0080e7          	jalr	-608(ra) # 800060d6 <free_desc>
      for(int j = 0; j < i; j++)
    8000633e:	4785                	li	a5,1
    80006340:	0297d163          	ble	s1,a5,80006362 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    80006344:	fa442503          	lw	a0,-92(s0)
    80006348:	00000097          	auipc	ra,0x0
    8000634c:	d8e080e7          	jalr	-626(ra) # 800060d6 <free_desc>
      for(int j = 0; j < i; j++)
    80006350:	4789                	li	a5,2
    80006352:	0097d863          	ble	s1,a5,80006362 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    80006356:	fa842503          	lw	a0,-88(s0)
    8000635a:	00000097          	auipc	ra,0x0
    8000635e:	d7c080e7          	jalr	-644(ra) # 800060d6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006362:	0001f597          	auipc	a1,0x1f
    80006366:	d4658593          	addi	a1,a1,-698 # 800250a8 <disk+0x20a8>
    8000636a:	0001f517          	auipc	a0,0x1f
    8000636e:	cae50513          	addi	a0,a0,-850 # 80025018 <disk+0x2018>
    80006372:	ffffc097          	auipc	ra,0xffffc
    80006376:	1f2080e7          	jalr	498(ra) # 80002564 <sleep>
  for(int i = 0; i < 3; i++){
    8000637a:	fa040713          	addi	a4,s0,-96
    8000637e:	4481                	li	s1,0
  for(int i = 0; i < NUM; i++){
    80006380:	4505                	li	a0,1
      disk.free[i] = 0;
    80006382:	6589                	lui	a1,0x2
    80006384:	b749                	j	80006306 <virtio_disk_rw+0x68>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    80006386:	4785                	li	a5,1
    80006388:	f8f42823          	sw	a5,-112(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    8000638c:	f8042a23          	sw	zero,-108(s0)
  buf0.sector = sector;
    80006390:	f9743c23          	sd	s7,-104(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006394:	fa042983          	lw	s3,-96(s0)
    80006398:	00499493          	slli	s1,s3,0x4
    8000639c:	0001fa17          	auipc	s4,0x1f
    800063a0:	c64a0a13          	addi	s4,s4,-924 # 80025000 <disk+0x2000>
    800063a4:	000a3a83          	ld	s5,0(s4)
    800063a8:	9aa6                	add	s5,s5,s1
    800063aa:	f9040513          	addi	a0,s0,-112
    800063ae:	ffffb097          	auipc	ra,0xffffb
    800063b2:	db0080e7          	jalr	-592(ra) # 8000115e <kvmpa>
    800063b6:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    800063ba:	000a3783          	ld	a5,0(s4)
    800063be:	97a6                	add	a5,a5,s1
    800063c0:	4741                	li	a4,16
    800063c2:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063c4:	000a3783          	ld	a5,0(s4)
    800063c8:	97a6                	add	a5,a5,s1
    800063ca:	4705                	li	a4,1
    800063cc:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    800063d0:	fa442703          	lw	a4,-92(s0)
    800063d4:	000a3783          	ld	a5,0(s4)
    800063d8:	97a6                	add	a5,a5,s1
    800063da:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800063de:	0712                	slli	a4,a4,0x4
    800063e0:	000a3783          	ld	a5,0(s4)
    800063e4:	97ba                	add	a5,a5,a4
    800063e6:	05890693          	addi	a3,s2,88
    800063ea:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    800063ec:	000a3783          	ld	a5,0(s4)
    800063f0:	97ba                	add	a5,a5,a4
    800063f2:	40000693          	li	a3,1024
    800063f6:	c794                	sw	a3,8(a5)
  if(write)
    800063f8:	100c0863          	beqz	s8,80006508 <virtio_disk_rw+0x26a>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800063fc:	000a3783          	ld	a5,0(s4)
    80006400:	97ba                	add	a5,a5,a4
    80006402:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006406:	0001d517          	auipc	a0,0x1d
    8000640a:	bfa50513          	addi	a0,a0,-1030 # 80023000 <disk>
    8000640e:	0001f797          	auipc	a5,0x1f
    80006412:	bf278793          	addi	a5,a5,-1038 # 80025000 <disk+0x2000>
    80006416:	6394                	ld	a3,0(a5)
    80006418:	96ba                	add	a3,a3,a4
    8000641a:	00c6d603          	lhu	a2,12(a3)
    8000641e:	00166613          	ori	a2,a2,1
    80006422:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006426:	fa842683          	lw	a3,-88(s0)
    8000642a:	6390                	ld	a2,0(a5)
    8000642c:	9732                	add	a4,a4,a2
    8000642e:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    80006432:	20098613          	addi	a2,s3,512
    80006436:	0612                	slli	a2,a2,0x4
    80006438:	962a                	add	a2,a2,a0
    8000643a:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000643e:	00469713          	slli	a4,a3,0x4
    80006442:	6394                	ld	a3,0(a5)
    80006444:	96ba                	add	a3,a3,a4
    80006446:	6589                	lui	a1,0x2
    80006448:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    8000644c:	94ae                	add	s1,s1,a1
    8000644e:	94aa                	add	s1,s1,a0
    80006450:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    80006452:	6394                	ld	a3,0(a5)
    80006454:	96ba                	add	a3,a3,a4
    80006456:	4585                	li	a1,1
    80006458:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000645a:	6394                	ld	a3,0(a5)
    8000645c:	96ba                	add	a3,a3,a4
    8000645e:	4509                	li	a0,2
    80006460:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    80006464:	6394                	ld	a3,0(a5)
    80006466:	9736                	add	a4,a4,a3
    80006468:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000646c:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006470:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    80006474:	6794                	ld	a3,8(a5)
    80006476:	0026d703          	lhu	a4,2(a3)
    8000647a:	8b1d                	andi	a4,a4,7
    8000647c:	2709                	addiw	a4,a4,2
    8000647e:	0706                	slli	a4,a4,0x1
    80006480:	9736                	add	a4,a4,a3
    80006482:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    80006486:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    8000648a:	6798                	ld	a4,8(a5)
    8000648c:	00275783          	lhu	a5,2(a4)
    80006490:	2785                	addiw	a5,a5,1
    80006492:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006496:	100017b7          	lui	a5,0x10001
    8000649a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000649e:	00492703          	lw	a4,4(s2)
    800064a2:	4785                	li	a5,1
    800064a4:	02f71163          	bne	a4,a5,800064c6 <virtio_disk_rw+0x228>
    sleep(b, &disk.vdisk_lock);
    800064a8:	0001f997          	auipc	s3,0x1f
    800064ac:	c0098993          	addi	s3,s3,-1024 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    800064b0:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800064b2:	85ce                	mv	a1,s3
    800064b4:	854a                	mv	a0,s2
    800064b6:	ffffc097          	auipc	ra,0xffffc
    800064ba:	0ae080e7          	jalr	174(ra) # 80002564 <sleep>
  while(b->disk == 1) {
    800064be:	00492783          	lw	a5,4(s2)
    800064c2:	fe9788e3          	beq	a5,s1,800064b2 <virtio_disk_rw+0x214>
  }

  disk.info[idx[0]].b = 0;
    800064c6:	fa042483          	lw	s1,-96(s0)
    800064ca:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    800064ce:	00479713          	slli	a4,a5,0x4
    800064d2:	0001d797          	auipc	a5,0x1d
    800064d6:	b2e78793          	addi	a5,a5,-1234 # 80023000 <disk>
    800064da:	97ba                	add	a5,a5,a4
    800064dc:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800064e0:	0001f917          	auipc	s2,0x1f
    800064e4:	b2090913          	addi	s2,s2,-1248 # 80025000 <disk+0x2000>
    free_desc(i);
    800064e8:	8526                	mv	a0,s1
    800064ea:	00000097          	auipc	ra,0x0
    800064ee:	bec080e7          	jalr	-1044(ra) # 800060d6 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800064f2:	0492                	slli	s1,s1,0x4
    800064f4:	00093783          	ld	a5,0(s2)
    800064f8:	94be                	add	s1,s1,a5
    800064fa:	00c4d783          	lhu	a5,12(s1)
    800064fe:	8b85                	andi	a5,a5,1
    80006500:	cf91                	beqz	a5,8000651c <virtio_disk_rw+0x27e>
      i = disk.desc[i].next;
    80006502:	00e4d483          	lhu	s1,14(s1)
  while(1){
    80006506:	b7cd                	j	800064e8 <virtio_disk_rw+0x24a>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006508:	0001f797          	auipc	a5,0x1f
    8000650c:	af878793          	addi	a5,a5,-1288 # 80025000 <disk+0x2000>
    80006510:	639c                	ld	a5,0(a5)
    80006512:	97ba                	add	a5,a5,a4
    80006514:	4689                	li	a3,2
    80006516:	00d79623          	sh	a3,12(a5)
    8000651a:	b5f5                	j	80006406 <virtio_disk_rw+0x168>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000651c:	0001f517          	auipc	a0,0x1f
    80006520:	b8c50513          	addi	a0,a0,-1140 # 800250a8 <disk+0x20a8>
    80006524:	ffffa097          	auipc	ra,0xffffa
    80006528:	7f2080e7          	jalr	2034(ra) # 80000d16 <release>
}
    8000652c:	70a6                	ld	ra,104(sp)
    8000652e:	7406                	ld	s0,96(sp)
    80006530:	64e6                	ld	s1,88(sp)
    80006532:	6946                	ld	s2,80(sp)
    80006534:	69a6                	ld	s3,72(sp)
    80006536:	6a06                	ld	s4,64(sp)
    80006538:	7ae2                	ld	s5,56(sp)
    8000653a:	7b42                	ld	s6,48(sp)
    8000653c:	7ba2                	ld	s7,40(sp)
    8000653e:	7c02                	ld	s8,32(sp)
    80006540:	6165                	addi	sp,sp,112
    80006542:	8082                	ret
  if(write)
    80006544:	e40c11e3          	bnez	s8,80006386 <virtio_disk_rw+0xe8>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006548:	f8042823          	sw	zero,-112(s0)
    8000654c:	b581                	j	8000638c <virtio_disk_rw+0xee>
      disk.free[i] = 0;
    8000654e:	00098c23          	sb	zero,24(s3)
    idx[i] = alloc_desc();
    80006552:	00072023          	sw	zero,0(a4)
    if(idx[i] < 0){
    80006556:	b365                	j	800062fe <virtio_disk_rw+0x60>

0000000080006558 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006558:	1101                	addi	sp,sp,-32
    8000655a:	ec06                	sd	ra,24(sp)
    8000655c:	e822                	sd	s0,16(sp)
    8000655e:	e426                	sd	s1,8(sp)
    80006560:	e04a                	sd	s2,0(sp)
    80006562:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006564:	0001f517          	auipc	a0,0x1f
    80006568:	b4450513          	addi	a0,a0,-1212 # 800250a8 <disk+0x20a8>
    8000656c:	ffffa097          	auipc	ra,0xffffa
    80006570:	6f6080e7          	jalr	1782(ra) # 80000c62 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006574:	0001f797          	auipc	a5,0x1f
    80006578:	a8c78793          	addi	a5,a5,-1396 # 80025000 <disk+0x2000>
    8000657c:	0207d683          	lhu	a3,32(a5)
    80006580:	6b98                	ld	a4,16(a5)
    80006582:	00275783          	lhu	a5,2(a4)
    80006586:	8fb5                	xor	a5,a5,a3
    80006588:	8b9d                	andi	a5,a5,7
    8000658a:	c7c9                	beqz	a5,80006614 <virtio_disk_intr+0xbc>
    int id = disk.used->elems[disk.used_idx].id;
    8000658c:	068e                	slli	a3,a3,0x3
    8000658e:	9736                	add	a4,a4,a3
    80006590:	435c                	lw	a5,4(a4)

    if(disk.info[id].status != 0)
    80006592:	20078713          	addi	a4,a5,512
    80006596:	00471693          	slli	a3,a4,0x4
    8000659a:	0001d717          	auipc	a4,0x1d
    8000659e:	a6670713          	addi	a4,a4,-1434 # 80023000 <disk>
    800065a2:	9736                	add	a4,a4,a3
    800065a4:	03074703          	lbu	a4,48(a4)
    800065a8:	ef31                	bnez	a4,80006604 <virtio_disk_intr+0xac>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    800065aa:	0001d917          	auipc	s2,0x1d
    800065ae:	a5690913          	addi	s2,s2,-1450 # 80023000 <disk>
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    800065b2:	0001f497          	auipc	s1,0x1f
    800065b6:	a4e48493          	addi	s1,s1,-1458 # 80025000 <disk+0x2000>
    disk.info[id].b->disk = 0;   // disk is done with buf
    800065ba:	20078793          	addi	a5,a5,512
    800065be:	0792                	slli	a5,a5,0x4
    800065c0:	97ca                	add	a5,a5,s2
    800065c2:	7798                	ld	a4,40(a5)
    800065c4:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    800065c8:	7788                	ld	a0,40(a5)
    800065ca:	ffffc097          	auipc	ra,0xffffc
    800065ce:	120080e7          	jalr	288(ra) # 800026ea <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    800065d2:	0204d783          	lhu	a5,32(s1)
    800065d6:	2785                	addiw	a5,a5,1
    800065d8:	8b9d                	andi	a5,a5,7
    800065da:	03079613          	slli	a2,a5,0x30
    800065de:	9241                	srli	a2,a2,0x30
    800065e0:	02c49023          	sh	a2,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800065e4:	6898                	ld	a4,16(s1)
    800065e6:	00275683          	lhu	a3,2(a4)
    800065ea:	8a9d                	andi	a3,a3,7
    800065ec:	02c68463          	beq	a3,a2,80006614 <virtio_disk_intr+0xbc>
    int id = disk.used->elems[disk.used_idx].id;
    800065f0:	078e                	slli	a5,a5,0x3
    800065f2:	97ba                	add	a5,a5,a4
    800065f4:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    800065f6:	20078713          	addi	a4,a5,512
    800065fa:	0712                	slli	a4,a4,0x4
    800065fc:	974a                	add	a4,a4,s2
    800065fe:	03074703          	lbu	a4,48(a4)
    80006602:	df45                	beqz	a4,800065ba <virtio_disk_intr+0x62>
      panic("virtio_disk_intr status");
    80006604:	00002517          	auipc	a0,0x2
    80006608:	28c50513          	addi	a0,a0,652 # 80008890 <syscalls+0x3f0>
    8000660c:	ffffa097          	auipc	ra,0xffffa
    80006610:	f68080e7          	jalr	-152(ra) # 80000574 <panic>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006614:	10001737          	lui	a4,0x10001
    80006618:	533c                	lw	a5,96(a4)
    8000661a:	8b8d                	andi	a5,a5,3
    8000661c:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    8000661e:	0001f517          	auipc	a0,0x1f
    80006622:	a8a50513          	addi	a0,a0,-1398 # 800250a8 <disk+0x20a8>
    80006626:	ffffa097          	auipc	ra,0xffffa
    8000662a:	6f0080e7          	jalr	1776(ra) # 80000d16 <release>
}
    8000662e:	60e2                	ld	ra,24(sp)
    80006630:	6442                	ld	s0,16(sp)
    80006632:	64a2                	ld	s1,8(sp)
    80006634:	6902                	ld	s2,0(sp)
    80006636:	6105                	addi	sp,sp,32
    80006638:	8082                	ret

000000008000663a <statscopyin>:
  int ncopyin;
  int ncopyinstr;
} stats;

int
statscopyin(char *buf, int sz) {
    8000663a:	7179                	addi	sp,sp,-48
    8000663c:	f406                	sd	ra,40(sp)
    8000663e:	f022                	sd	s0,32(sp)
    80006640:	ec26                	sd	s1,24(sp)
    80006642:	e84a                	sd	s2,16(sp)
    80006644:	e44e                	sd	s3,8(sp)
    80006646:	e052                	sd	s4,0(sp)
    80006648:	1800                	addi	s0,sp,48
    8000664a:	89aa                	mv	s3,a0
    8000664c:	8a2e                	mv	s4,a1
  int n;
  n = snprintf(buf, sz, "copyin: %d\n", stats.ncopyin);
    8000664e:	00003917          	auipc	s2,0x3
    80006652:	9da90913          	addi	s2,s2,-1574 # 80009028 <stats>
    80006656:	00092683          	lw	a3,0(s2)
    8000665a:	00002617          	auipc	a2,0x2
    8000665e:	24e60613          	addi	a2,a2,590 # 800088a8 <syscalls+0x408>
    80006662:	00000097          	auipc	ra,0x0
    80006666:	2e2080e7          	jalr	738(ra) # 80006944 <snprintf>
    8000666a:	84aa                	mv	s1,a0
  n += snprintf(buf+n, sz, "copyinstr: %d\n", stats.ncopyinstr);
    8000666c:	00492683          	lw	a3,4(s2)
    80006670:	00002617          	auipc	a2,0x2
    80006674:	24860613          	addi	a2,a2,584 # 800088b8 <syscalls+0x418>
    80006678:	85d2                	mv	a1,s4
    8000667a:	954e                	add	a0,a0,s3
    8000667c:	00000097          	auipc	ra,0x0
    80006680:	2c8080e7          	jalr	712(ra) # 80006944 <snprintf>
  return n;
}
    80006684:	9d25                	addw	a0,a0,s1
    80006686:	70a2                	ld	ra,40(sp)
    80006688:	7402                	ld	s0,32(sp)
    8000668a:	64e2                	ld	s1,24(sp)
    8000668c:	6942                	ld	s2,16(sp)
    8000668e:	69a2                	ld	s3,8(sp)
    80006690:	6a02                	ld	s4,0(sp)
    80006692:	6145                	addi	sp,sp,48
    80006694:	8082                	ret

0000000080006696 <copyin_new>:
// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin_new(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
    80006696:	7179                	addi	sp,sp,-48
    80006698:	f406                	sd	ra,40(sp)
    8000669a:	f022                	sd	s0,32(sp)
    8000669c:	ec26                	sd	s1,24(sp)
    8000669e:	e84a                	sd	s2,16(sp)
    800066a0:	e44e                	sd	s3,8(sp)
    800066a2:	1800                	addi	s0,sp,48
    800066a4:	89ae                	mv	s3,a1
    800066a6:	84b2                	mv	s1,a2
    800066a8:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800066aa:	ffffb097          	auipc	ra,0xffffb
    800066ae:	3f0080e7          	jalr	1008(ra) # 80001a9a <myproc>

  if (srcva >= p->sz || srcva+len >= p->sz || srcva+len < srcva)
    800066b2:	653c                	ld	a5,72(a0)
    800066b4:	02f4ff63          	bleu	a5,s1,800066f2 <copyin_new+0x5c>
    800066b8:	01248733          	add	a4,s1,s2
    800066bc:	02f77d63          	bleu	a5,a4,800066f6 <copyin_new+0x60>
    800066c0:	02976d63          	bltu	a4,s1,800066fa <copyin_new+0x64>
    return -1;
  memmove((void *) dst, (void *)srcva, len);
    800066c4:	0009061b          	sext.w	a2,s2
    800066c8:	85a6                	mv	a1,s1
    800066ca:	854e                	mv	a0,s3
    800066cc:	ffffa097          	auipc	ra,0xffffa
    800066d0:	6fe080e7          	jalr	1790(ra) # 80000dca <memmove>
  stats.ncopyin++;   // XXX lock
    800066d4:	00003717          	auipc	a4,0x3
    800066d8:	95470713          	addi	a4,a4,-1708 # 80009028 <stats>
    800066dc:	431c                	lw	a5,0(a4)
    800066de:	2785                	addiw	a5,a5,1
    800066e0:	c31c                	sw	a5,0(a4)
  return 0;
    800066e2:	4501                	li	a0,0
}
    800066e4:	70a2                	ld	ra,40(sp)
    800066e6:	7402                	ld	s0,32(sp)
    800066e8:	64e2                	ld	s1,24(sp)
    800066ea:	6942                	ld	s2,16(sp)
    800066ec:	69a2                	ld	s3,8(sp)
    800066ee:	6145                	addi	sp,sp,48
    800066f0:	8082                	ret
    return -1;
    800066f2:	557d                	li	a0,-1
    800066f4:	bfc5                	j	800066e4 <copyin_new+0x4e>
    800066f6:	557d                	li	a0,-1
    800066f8:	b7f5                	j	800066e4 <copyin_new+0x4e>
    800066fa:	557d                	li	a0,-1
    800066fc:	b7e5                	j	800066e4 <copyin_new+0x4e>

00000000800066fe <copyinstr_new>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr_new(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    800066fe:	7179                	addi	sp,sp,-48
    80006700:	f406                	sd	ra,40(sp)
    80006702:	f022                	sd	s0,32(sp)
    80006704:	ec26                	sd	s1,24(sp)
    80006706:	e84a                	sd	s2,16(sp)
    80006708:	e44e                	sd	s3,8(sp)
    8000670a:	1800                	addi	s0,sp,48
    8000670c:	89ae                	mv	s3,a1
    8000670e:	84b2                	mv	s1,a2
    80006710:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80006712:	ffffb097          	auipc	ra,0xffffb
    80006716:	388080e7          	jalr	904(ra) # 80001a9a <myproc>
  char *s = (char *) srcva;
  
  stats.ncopyinstr++;   // XXX lock
    8000671a:	00003717          	auipc	a4,0x3
    8000671e:	90e70713          	addi	a4,a4,-1778 # 80009028 <stats>
    80006722:	435c                	lw	a5,4(a4)
    80006724:	2785                	addiw	a5,a5,1
    80006726:	c35c                	sw	a5,4(a4)
  for(int i = 0; i < max && srcva + i < p->sz; i++){
    80006728:	04090063          	beqz	s2,80006768 <copyinstr_new+0x6a>
    8000672c:	653c                	ld	a5,72(a0)
    8000672e:	02f4ff63          	bleu	a5,s1,8000676c <copyinstr_new+0x6e>
    dst[i] = s[i];
    80006732:	0004c783          	lbu	a5,0(s1)
    80006736:	00f98023          	sb	a5,0(s3)
    if(s[i] == '\0')
    8000673a:	cb9d                	beqz	a5,80006770 <copyinstr_new+0x72>
    8000673c:	00148793          	addi	a5,s1,1
    80006740:	012486b3          	add	a3,s1,s2
  for(int i = 0; i < max && srcva + i < p->sz; i++){
    80006744:	02d78863          	beq	a5,a3,80006774 <copyinstr_new+0x76>
    80006748:	6538                	ld	a4,72(a0)
    8000674a:	00e7fd63          	bleu	a4,a5,80006764 <copyinstr_new+0x66>
    dst[i] = s[i];
    8000674e:	0007c603          	lbu	a2,0(a5)
    80006752:	40978733          	sub	a4,a5,s1
    80006756:	974e                	add	a4,a4,s3
    80006758:	00c70023          	sb	a2,0(a4)
    if(s[i] == '\0')
    8000675c:	0785                	addi	a5,a5,1
    8000675e:	f27d                	bnez	a2,80006744 <copyinstr_new+0x46>
      return 0;
    80006760:	4501                	li	a0,0
    80006762:	a811                	j	80006776 <copyinstr_new+0x78>
  }
  return -1;
    80006764:	557d                	li	a0,-1
    80006766:	a801                	j	80006776 <copyinstr_new+0x78>
    80006768:	557d                	li	a0,-1
    8000676a:	a031                	j	80006776 <copyinstr_new+0x78>
    8000676c:	557d                	li	a0,-1
    8000676e:	a021                	j	80006776 <copyinstr_new+0x78>
      return 0;
    80006770:	4501                	li	a0,0
    80006772:	a011                	j	80006776 <copyinstr_new+0x78>
  return -1;
    80006774:	557d                	li	a0,-1
}
    80006776:	70a2                	ld	ra,40(sp)
    80006778:	7402                	ld	s0,32(sp)
    8000677a:	64e2                	ld	s1,24(sp)
    8000677c:	6942                	ld	s2,16(sp)
    8000677e:	69a2                	ld	s3,8(sp)
    80006780:	6145                	addi	sp,sp,48
    80006782:	8082                	ret

0000000080006784 <statswrite>:
int statscopyin(char*, int);
int statslock(char*, int);
  
int
statswrite(int user_src, uint64 src, int n)
{
    80006784:	1141                	addi	sp,sp,-16
    80006786:	e422                	sd	s0,8(sp)
    80006788:	0800                	addi	s0,sp,16
  return -1;
}
    8000678a:	557d                	li	a0,-1
    8000678c:	6422                	ld	s0,8(sp)
    8000678e:	0141                	addi	sp,sp,16
    80006790:	8082                	ret

0000000080006792 <statsread>:

int
statsread(int user_dst, uint64 dst, int n)
{
    80006792:	7179                	addi	sp,sp,-48
    80006794:	f406                	sd	ra,40(sp)
    80006796:	f022                	sd	s0,32(sp)
    80006798:	ec26                	sd	s1,24(sp)
    8000679a:	e84a                	sd	s2,16(sp)
    8000679c:	e44e                	sd	s3,8(sp)
    8000679e:	e052                	sd	s4,0(sp)
    800067a0:	1800                	addi	s0,sp,48
    800067a2:	89aa                	mv	s3,a0
    800067a4:	8a2e                	mv	s4,a1
    800067a6:	8932                	mv	s2,a2
  int m;

  acquire(&stats.lock);
    800067a8:	00020517          	auipc	a0,0x20
    800067ac:	85850513          	addi	a0,a0,-1960 # 80026000 <stats>
    800067b0:	ffffa097          	auipc	ra,0xffffa
    800067b4:	4b2080e7          	jalr	1202(ra) # 80000c62 <acquire>

  if(stats.sz == 0) {
    800067b8:	00021797          	auipc	a5,0x21
    800067bc:	84878793          	addi	a5,a5,-1976 # 80027000 <stats+0x1000>
    800067c0:	4f9c                	lw	a5,24(a5)
    800067c2:	cbad                	beqz	a5,80006834 <statsread+0xa2>
#endif
#ifdef LAB_LOCK
    stats.sz = statslock(stats.buf, BUFSZ);
#endif
  }
  m = stats.sz - stats.off;
    800067c4:	00021797          	auipc	a5,0x21
    800067c8:	83c78793          	addi	a5,a5,-1988 # 80027000 <stats+0x1000>
    800067cc:	4fd8                	lw	a4,28(a5)
    800067ce:	4f9c                	lw	a5,24(a5)
    800067d0:	9f99                	subw	a5,a5,a4
    800067d2:	0007869b          	sext.w	a3,a5

  if (m > 0) {
    800067d6:	06d05d63          	blez	a3,80006850 <statsread+0xbe>
    if(m > n)
    800067da:	84be                	mv	s1,a5
    800067dc:	00d95363          	ble	a3,s2,800067e2 <statsread+0x50>
    800067e0:	84ca                	mv	s1,s2
    800067e2:	0004891b          	sext.w	s2,s1
      m  = n;
    if(either_copyout(user_dst, dst, stats.buf+stats.off, m) != -1) {
    800067e6:	86ca                	mv	a3,s2
    800067e8:	00020617          	auipc	a2,0x20
    800067ec:	83060613          	addi	a2,a2,-2000 # 80026018 <stats+0x18>
    800067f0:	963a                	add	a2,a2,a4
    800067f2:	85d2                	mv	a1,s4
    800067f4:	854e                	mv	a0,s3
    800067f6:	ffffc097          	auipc	ra,0xffffc
    800067fa:	fd0080e7          	jalr	-48(ra) # 800027c6 <either_copyout>
    800067fe:	57fd                	li	a5,-1
    80006800:	00f50963          	beq	a0,a5,80006812 <statsread+0x80>
      stats.off += m;
    80006804:	00020717          	auipc	a4,0x20
    80006808:	7fc70713          	addi	a4,a4,2044 # 80027000 <stats+0x1000>
    8000680c:	4f5c                	lw	a5,28(a4)
    8000680e:	9cbd                	addw	s1,s1,a5
    80006810:	cf44                	sw	s1,28(a4)
  } else {
    m = -1;
    stats.sz = 0;
    stats.off = 0;
  }
  release(&stats.lock);
    80006812:	0001f517          	auipc	a0,0x1f
    80006816:	7ee50513          	addi	a0,a0,2030 # 80026000 <stats>
    8000681a:	ffffa097          	auipc	ra,0xffffa
    8000681e:	4fc080e7          	jalr	1276(ra) # 80000d16 <release>
  return m;
}
    80006822:	854a                	mv	a0,s2
    80006824:	70a2                	ld	ra,40(sp)
    80006826:	7402                	ld	s0,32(sp)
    80006828:	64e2                	ld	s1,24(sp)
    8000682a:	6942                	ld	s2,16(sp)
    8000682c:	69a2                	ld	s3,8(sp)
    8000682e:	6a02                	ld	s4,0(sp)
    80006830:	6145                	addi	sp,sp,48
    80006832:	8082                	ret
    stats.sz = statscopyin(stats.buf, BUFSZ);
    80006834:	6585                	lui	a1,0x1
    80006836:	0001f517          	auipc	a0,0x1f
    8000683a:	7e250513          	addi	a0,a0,2018 # 80026018 <stats+0x18>
    8000683e:	00000097          	auipc	ra,0x0
    80006842:	dfc080e7          	jalr	-516(ra) # 8000663a <statscopyin>
    80006846:	00020797          	auipc	a5,0x20
    8000684a:	7ca7a923          	sw	a0,2002(a5) # 80027018 <stats+0x1018>
    8000684e:	bf9d                	j	800067c4 <statsread+0x32>
    stats.sz = 0;
    80006850:	00020797          	auipc	a5,0x20
    80006854:	7b078793          	addi	a5,a5,1968 # 80027000 <stats+0x1000>
    80006858:	0007ac23          	sw	zero,24(a5)
    stats.off = 0;
    8000685c:	0007ae23          	sw	zero,28(a5)
    m = -1;
    80006860:	597d                	li	s2,-1
    80006862:	bf45                	j	80006812 <statsread+0x80>

0000000080006864 <statsinit>:

void
statsinit(void)
{
    80006864:	1141                	addi	sp,sp,-16
    80006866:	e406                	sd	ra,8(sp)
    80006868:	e022                	sd	s0,0(sp)
    8000686a:	0800                	addi	s0,sp,16
  initlock(&stats.lock, "stats");
    8000686c:	00002597          	auipc	a1,0x2
    80006870:	05c58593          	addi	a1,a1,92 # 800088c8 <syscalls+0x428>
    80006874:	0001f517          	auipc	a0,0x1f
    80006878:	78c50513          	addi	a0,a0,1932 # 80026000 <stats>
    8000687c:	ffffa097          	auipc	ra,0xffffa
    80006880:	356080e7          	jalr	854(ra) # 80000bd2 <initlock>

  devsw[STATS].read = statsread;
    80006884:	0001b797          	auipc	a5,0x1b
    80006888:	32c78793          	addi	a5,a5,812 # 80021bb0 <devsw>
    8000688c:	00000717          	auipc	a4,0x0
    80006890:	f0670713          	addi	a4,a4,-250 # 80006792 <statsread>
    80006894:	f398                	sd	a4,32(a5)
  devsw[STATS].write = statswrite;
    80006896:	00000717          	auipc	a4,0x0
    8000689a:	eee70713          	addi	a4,a4,-274 # 80006784 <statswrite>
    8000689e:	f798                	sd	a4,40(a5)
}
    800068a0:	60a2                	ld	ra,8(sp)
    800068a2:	6402                	ld	s0,0(sp)
    800068a4:	0141                	addi	sp,sp,16
    800068a6:	8082                	ret

00000000800068a8 <sprintint>:
  return 1;
}

static int
sprintint(char *s, int xx, int base, int sign)
{
    800068a8:	1101                	addi	sp,sp,-32
    800068aa:	ec22                	sd	s0,24(sp)
    800068ac:	1000                	addi	s0,sp,32
  char buf[16];
  int i, n;
  uint x;

  if(sign && (sign = xx < 0))
    800068ae:	c299                	beqz	a3,800068b4 <sprintint+0xc>
    800068b0:	0005cd63          	bltz	a1,800068ca <sprintint+0x22>
    x = -xx;
  else
    x = xx;
    800068b4:	2581                	sext.w	a1,a1
    800068b6:	4301                	li	t1,0

  i = 0;
    800068b8:	fe040713          	addi	a4,s0,-32
    800068bc:	4801                	li	a6,0
  do {
    buf[i++] = digits[x % base];
    800068be:	2601                	sext.w	a2,a2
    800068c0:	00002897          	auipc	a7,0x2
    800068c4:	01088893          	addi	a7,a7,16 # 800088d0 <digits>
    800068c8:	a801                	j	800068d8 <sprintint+0x30>
    x = -xx;
    800068ca:	40b005bb          	negw	a1,a1
    800068ce:	2581                	sext.w	a1,a1
  if(sign && (sign = xx < 0))
    800068d0:	4305                	li	t1,1
    x = -xx;
    800068d2:	b7dd                	j	800068b8 <sprintint+0x10>
  } while((x /= base) != 0);
    800068d4:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
    800068d6:	8836                	mv	a6,a3
    800068d8:	0018069b          	addiw	a3,a6,1
    800068dc:	02c5f7bb          	remuw	a5,a1,a2
    800068e0:	1782                	slli	a5,a5,0x20
    800068e2:	9381                	srli	a5,a5,0x20
    800068e4:	97c6                	add	a5,a5,a7
    800068e6:	0007c783          	lbu	a5,0(a5)
    800068ea:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    800068ee:	0705                	addi	a4,a4,1
    800068f0:	02c5d7bb          	divuw	a5,a1,a2
    800068f4:	fec5f0e3          	bleu	a2,a1,800068d4 <sprintint+0x2c>

  if(sign)
    800068f8:	00030b63          	beqz	t1,8000690e <sprintint+0x66>
    buf[i++] = '-';
    800068fc:	ff040793          	addi	a5,s0,-16
    80006900:	96be                	add	a3,a3,a5
    80006902:	02d00793          	li	a5,45
    80006906:	fef68823          	sb	a5,-16(a3)
    8000690a:	0028069b          	addiw	a3,a6,2

  n = 0;
  while(--i >= 0)
    8000690e:	02d05963          	blez	a3,80006940 <sprintint+0x98>
    80006912:	fe040793          	addi	a5,s0,-32
    80006916:	00d78733          	add	a4,a5,a3
    8000691a:	87aa                	mv	a5,a0
    8000691c:	0505                	addi	a0,a0,1
    8000691e:	fff6861b          	addiw	a2,a3,-1
    80006922:	1602                	slli	a2,a2,0x20
    80006924:	9201                	srli	a2,a2,0x20
    80006926:	9532                	add	a0,a0,a2
  *s = c;
    80006928:	fff74603          	lbu	a2,-1(a4)
    8000692c:	00c78023          	sb	a2,0(a5)
  while(--i >= 0)
    80006930:	177d                	addi	a4,a4,-1
    80006932:	0785                	addi	a5,a5,1
    80006934:	fea79ae3          	bne	a5,a0,80006928 <sprintint+0x80>
    n += sputc(s+n, buf[i]);
  return n;
}
    80006938:	8536                	mv	a0,a3
    8000693a:	6462                	ld	s0,24(sp)
    8000693c:	6105                	addi	sp,sp,32
    8000693e:	8082                	ret
  while(--i >= 0)
    80006940:	4681                	li	a3,0
    80006942:	bfdd                	j	80006938 <sprintint+0x90>

0000000080006944 <snprintf>:

int
snprintf(char *buf, int sz, char *fmt, ...)
{
    80006944:	7171                	addi	sp,sp,-176
    80006946:	fc86                	sd	ra,120(sp)
    80006948:	f8a2                	sd	s0,112(sp)
    8000694a:	f4a6                	sd	s1,104(sp)
    8000694c:	f0ca                	sd	s2,96(sp)
    8000694e:	ecce                	sd	s3,88(sp)
    80006950:	e8d2                	sd	s4,80(sp)
    80006952:	e4d6                	sd	s5,72(sp)
    80006954:	e0da                	sd	s6,64(sp)
    80006956:	fc5e                	sd	s7,56(sp)
    80006958:	f862                	sd	s8,48(sp)
    8000695a:	f466                	sd	s9,40(sp)
    8000695c:	f06a                	sd	s10,32(sp)
    8000695e:	ec6e                	sd	s11,24(sp)
    80006960:	0100                	addi	s0,sp,128
    80006962:	e414                	sd	a3,8(s0)
    80006964:	e818                	sd	a4,16(s0)
    80006966:	ec1c                	sd	a5,24(s0)
    80006968:	03043023          	sd	a6,32(s0)
    8000696c:	03143423          	sd	a7,40(s0)
  va_list ap;
  int i, c;
  int off = 0;
  char *s;

  if (fmt == 0)
    80006970:	ce1d                	beqz	a2,800069ae <snprintf+0x6a>
    80006972:	8baa                	mv	s7,a0
    80006974:	89ae                	mv	s3,a1
    80006976:	8a32                	mv	s4,a2
    panic("null fmt");

  va_start(ap, fmt);
    80006978:	00840793          	addi	a5,s0,8
    8000697c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    80006980:	14b05263          	blez	a1,80006ac4 <snprintf+0x180>
    80006984:	00064703          	lbu	a4,0(a2)
    80006988:	0007079b          	sext.w	a5,a4
    8000698c:	12078e63          	beqz	a5,80006ac8 <snprintf+0x184>
  int off = 0;
    80006990:	4481                	li	s1,0
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    80006992:	4901                	li	s2,0
    if(c != '%'){
    80006994:	02500a93          	li	s5,37
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    80006998:	06400b13          	li	s6,100
  *s = c;
    8000699c:	02500d13          	li	s10,37
    switch(c){
    800069a0:	07300c93          	li	s9,115
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
      break;
    case 's':
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s && off < sz; s++)
    800069a4:	02800d93          	li	s11,40
    switch(c){
    800069a8:	07800c13          	li	s8,120
    800069ac:	a805                	j	800069dc <snprintf+0x98>
    panic("null fmt");
    800069ae:	00001517          	auipc	a0,0x1
    800069b2:	69250513          	addi	a0,a0,1682 # 80008040 <digits+0x28>
    800069b6:	ffffa097          	auipc	ra,0xffffa
    800069ba:	bbe080e7          	jalr	-1090(ra) # 80000574 <panic>
  *s = c;
    800069be:	009b87b3          	add	a5,s7,s1
    800069c2:	00e78023          	sb	a4,0(a5)
      off += sputc(buf+off, c);
    800069c6:	2485                	addiw	s1,s1,1
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    800069c8:	2905                	addiw	s2,s2,1
    800069ca:	0b34dc63          	ble	s3,s1,80006a82 <snprintf+0x13e>
    800069ce:	012a07b3          	add	a5,s4,s2
    800069d2:	0007c703          	lbu	a4,0(a5)
    800069d6:	0007079b          	sext.w	a5,a4
    800069da:	c7c5                	beqz	a5,80006a82 <snprintf+0x13e>
    if(c != '%'){
    800069dc:	ff5791e3          	bne	a5,s5,800069be <snprintf+0x7a>
    c = fmt[++i] & 0xff;
    800069e0:	2905                	addiw	s2,s2,1
    800069e2:	012a07b3          	add	a5,s4,s2
    800069e6:	0007c783          	lbu	a5,0(a5)
    if(c == 0)
    800069ea:	cfc1                	beqz	a5,80006a82 <snprintf+0x13e>
    switch(c){
    800069ec:	05678163          	beq	a5,s6,80006a2e <snprintf+0xea>
    800069f0:	02fb7763          	bleu	a5,s6,80006a1e <snprintf+0xda>
    800069f4:	05978e63          	beq	a5,s9,80006a50 <snprintf+0x10c>
    800069f8:	0b879b63          	bne	a5,s8,80006aae <snprintf+0x16a>
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
    800069fc:	f8843783          	ld	a5,-120(s0)
    80006a00:	00878713          	addi	a4,a5,8
    80006a04:	f8e43423          	sd	a4,-120(s0)
    80006a08:	4685                	li	a3,1
    80006a0a:	4641                	li	a2,16
    80006a0c:	438c                	lw	a1,0(a5)
    80006a0e:	009b8533          	add	a0,s7,s1
    80006a12:	00000097          	auipc	ra,0x0
    80006a16:	e96080e7          	jalr	-362(ra) # 800068a8 <sprintint>
    80006a1a:	9ca9                	addw	s1,s1,a0
      break;
    80006a1c:	b775                	j	800069c8 <snprintf+0x84>
    switch(c){
    80006a1e:	09579863          	bne	a5,s5,80006aae <snprintf+0x16a>
  *s = c;
    80006a22:	009b87b3          	add	a5,s7,s1
    80006a26:	01a78023          	sb	s10,0(a5)
        off += sputc(buf+off, *s);
      break;
    case '%':
      off += sputc(buf+off, '%');
    80006a2a:	2485                	addiw	s1,s1,1
      break;
    80006a2c:	bf71                	j	800069c8 <snprintf+0x84>
      off += sprintint(buf+off, va_arg(ap, int), 10, 1);
    80006a2e:	f8843783          	ld	a5,-120(s0)
    80006a32:	00878713          	addi	a4,a5,8
    80006a36:	f8e43423          	sd	a4,-120(s0)
    80006a3a:	4685                	li	a3,1
    80006a3c:	4629                	li	a2,10
    80006a3e:	438c                	lw	a1,0(a5)
    80006a40:	009b8533          	add	a0,s7,s1
    80006a44:	00000097          	auipc	ra,0x0
    80006a48:	e64080e7          	jalr	-412(ra) # 800068a8 <sprintint>
    80006a4c:	9ca9                	addw	s1,s1,a0
      break;
    80006a4e:	bfad                	j	800069c8 <snprintf+0x84>
      if((s = va_arg(ap, char*)) == 0)
    80006a50:	f8843783          	ld	a5,-120(s0)
    80006a54:	00878713          	addi	a4,a5,8
    80006a58:	f8e43423          	sd	a4,-120(s0)
    80006a5c:	639c                	ld	a5,0(a5)
    80006a5e:	c3b1                	beqz	a5,80006aa2 <snprintf+0x15e>
      for(; *s && off < sz; s++)
    80006a60:	0007c703          	lbu	a4,0(a5)
    80006a64:	d335                	beqz	a4,800069c8 <snprintf+0x84>
    80006a66:	0134de63          	ble	s3,s1,80006a82 <snprintf+0x13e>
    80006a6a:	009b86b3          	add	a3,s7,s1
  *s = c;
    80006a6e:	00e68023          	sb	a4,0(a3)
        off += sputc(buf+off, *s);
    80006a72:	2485                	addiw	s1,s1,1
      for(; *s && off < sz; s++)
    80006a74:	0785                	addi	a5,a5,1
    80006a76:	0007c703          	lbu	a4,0(a5)
    80006a7a:	d739                	beqz	a4,800069c8 <snprintf+0x84>
    80006a7c:	0685                	addi	a3,a3,1
    80006a7e:	fe9998e3          	bne	s3,s1,80006a6e <snprintf+0x12a>
      off += sputc(buf+off, c);
      break;
    }
  }
  return off;
}
    80006a82:	8526                	mv	a0,s1
    80006a84:	70e6                	ld	ra,120(sp)
    80006a86:	7446                	ld	s0,112(sp)
    80006a88:	74a6                	ld	s1,104(sp)
    80006a8a:	7906                	ld	s2,96(sp)
    80006a8c:	69e6                	ld	s3,88(sp)
    80006a8e:	6a46                	ld	s4,80(sp)
    80006a90:	6aa6                	ld	s5,72(sp)
    80006a92:	6b06                	ld	s6,64(sp)
    80006a94:	7be2                	ld	s7,56(sp)
    80006a96:	7c42                	ld	s8,48(sp)
    80006a98:	7ca2                	ld	s9,40(sp)
    80006a9a:	7d02                	ld	s10,32(sp)
    80006a9c:	6de2                	ld	s11,24(sp)
    80006a9e:	614d                	addi	sp,sp,176
    80006aa0:	8082                	ret
      for(; *s && off < sz; s++)
    80006aa2:	876e                	mv	a4,s11
        s = "(null)";
    80006aa4:	00001797          	auipc	a5,0x1
    80006aa8:	59478793          	addi	a5,a5,1428 # 80008038 <digits+0x20>
    80006aac:	bf6d                	j	80006a66 <snprintf+0x122>
  *s = c;
    80006aae:	009b8733          	add	a4,s7,s1
    80006ab2:	01a70023          	sb	s10,0(a4)
      off += sputc(buf+off, c);
    80006ab6:	0014871b          	addiw	a4,s1,1
  *s = c;
    80006aba:	975e                	add	a4,a4,s7
    80006abc:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    80006ac0:	2489                	addiw	s1,s1,2
      break;
    80006ac2:	b719                	j	800069c8 <snprintf+0x84>
  int off = 0;
    80006ac4:	4481                	li	s1,0
    80006ac6:	bf75                	j	80006a82 <snprintf+0x13e>
    80006ac8:	84be                	mv	s1,a5
    80006aca:	bf65                	j	80006a82 <snprintf+0x13e>
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
