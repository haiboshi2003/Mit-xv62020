
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	84013103          	ld	sp,-1984(sp) # 80008840 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    8000012c:	54e080e7          	jalr	1358(ra) # 80002676 <either_copyin>
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
    800001d4:	9d4080e7          	jalr	-1580(ra) # 80001ba4 <myproc>
    800001d8:	591c                	lw	a5,48(a0)
    800001da:	eba5                	bnez	a5,8000024a <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001dc:	85ce                	mv	a1,s3
    800001de:	854a                	mv	a0,s2
    800001e0:	00002097          	auipc	ra,0x2
    800001e4:	1de080e7          	jalr	478(ra) # 800023be <sleep>
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
    80000220:	404080e7          	jalr	1028(ra) # 80002620 <either_copyout>
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
    8000041a:	2b6080e7          	jalr	694(ra) # 800026cc <procdump>
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
    8000047c:	0cc080e7          	jalr	204(ra) # 80002544 <wakeup>
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
    800004ae:	50678793          	addi	a5,a5,1286 # 800219b0 <devsw>
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
    800008f2:	c56080e7          	jalr	-938(ra) # 80002544 <wakeup>
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
    800009a2:	a20080e7          	jalr	-1504(ra) # 800023be <sleep>
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
    80000c00:	f8c080e7          	jalr	-116(ra) # 80001b88 <mycpu>
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
    80000c32:	f5a080e7          	jalr	-166(ra) # 80001b88 <mycpu>
    80000c36:	5d3c                	lw	a5,120(a0)
    80000c38:	cf89                	beqz	a5,80000c52 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c3a:	00001097          	auipc	ra,0x1
    80000c3e:	f4e080e7          	jalr	-178(ra) # 80001b88 <mycpu>
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
    80000c56:	f36080e7          	jalr	-202(ra) # 80001b88 <mycpu>
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
    80000c96:	ef6080e7          	jalr	-266(ra) # 80001b88 <mycpu>
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
    80000cc2:	eca080e7          	jalr	-310(ra) # 80001b88 <mycpu>
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
    80000d74:	00b78023          	sb	a1,0(a5) # fffffffffffff000 <end+0xffffffff7ffd9000>
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
    80000f3e:	c3e080e7          	jalr	-962(ra) # 80001b78 <cpuid>
    virtio_disk_init(); // emulated hard disk
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
    80000f5a:	c22080e7          	jalr	-990(ra) # 80001b78 <cpuid>
    80000f5e:	85aa                	mv	a1,a0
    80000f60:	00007517          	auipc	a0,0x7
    80000f64:	15850513          	addi	a0,a0,344 # 800080b8 <digits+0xa0>
    80000f68:	fffff097          	auipc	ra,0xfffff
    80000f6c:	656080e7          	jalr	1622(ra) # 800005be <printf>
    kvminithart();    // turn on paging
    80000f70:	00000097          	auipc	ra,0x0
    80000f74:	0d8080e7          	jalr	216(ra) # 80001048 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f78:	00002097          	auipc	ra,0x2
    80000f7c:	896080e7          	jalr	-1898(ra) # 8000280e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f80:	00005097          	auipc	ra,0x5
    80000f84:	f60080e7          	jalr	-160(ra) # 80005ee0 <plicinithart>
  }

  scheduler();        
    80000f88:	00001097          	auipc	ra,0x1
    80000f8c:	152080e7          	jalr	338(ra) # 800020da <scheduler>
    consoleinit();
    80000f90:	fffff097          	auipc	ra,0xfffff
    80000f94:	4f2080e7          	jalr	1266(ra) # 80000482 <consoleinit>
    printfinit();
    80000f98:	00000097          	auipc	ra,0x0
    80000f9c:	80c080e7          	jalr	-2036(ra) # 800007a4 <printfinit>
    printf("\n");
    80000fa0:	00007517          	auipc	a0,0x7
    80000fa4:	12850513          	addi	a0,a0,296 # 800080c8 <digits+0xb0>
    80000fa8:	fffff097          	auipc	ra,0xfffff
    80000fac:	616080e7          	jalr	1558(ra) # 800005be <printf>
    printf("xv6 kernel is booting\n");
    80000fb0:	00007517          	auipc	a0,0x7
    80000fb4:	0f050513          	addi	a0,a0,240 # 800080a0 <digits+0x88>
    80000fb8:	fffff097          	auipc	ra,0xfffff
    80000fbc:	606080e7          	jalr	1542(ra) # 800005be <printf>
    printf("\n");
    80000fc0:	00007517          	auipc	a0,0x7
    80000fc4:	10850513          	addi	a0,a0,264 # 800080c8 <digits+0xb0>
    80000fc8:	fffff097          	auipc	ra,0xfffff
    80000fcc:	5f6080e7          	jalr	1526(ra) # 800005be <printf>
    kinit();         // physical page allocator
    80000fd0:	00000097          	auipc	ra,0x0
    80000fd4:	b66080e7          	jalr	-1178(ra) # 80000b36 <kinit>
    kvminit();       // create kernel page table
    80000fd8:	00000097          	auipc	ra,0x0
    80000fdc:	264080e7          	jalr	612(ra) # 8000123c <kvminit>
    kvminithart();   // turn on paging
    80000fe0:	00000097          	auipc	ra,0x0
    80000fe4:	068080e7          	jalr	104(ra) # 80001048 <kvminithart>
    procinit();      // process table
    80000fe8:	00001097          	auipc	ra,0x1
    80000fec:	ac0080e7          	jalr	-1344(ra) # 80001aa8 <procinit>
    trapinit();      // trap vectors
    80000ff0:	00001097          	auipc	ra,0x1
    80000ff4:	7f6080e7          	jalr	2038(ra) # 800027e6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ff8:	00002097          	auipc	ra,0x2
    80000ffc:	816080e7          	jalr	-2026(ra) # 8000280e <trapinithart>
    plicinit();      // set up interrupt controller
    80001000:	00005097          	auipc	ra,0x5
    80001004:	eca080e7          	jalr	-310(ra) # 80005eca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001008:	00005097          	auipc	ra,0x5
    8000100c:	ed8080e7          	jalr	-296(ra) # 80005ee0 <plicinithart>
    binit();         // buffer cache
    80001010:	00002097          	auipc	ra,0x2
    80001014:	f8e080e7          	jalr	-114(ra) # 80002f9e <binit>
    iinit();         // inode cache
    80001018:	00002097          	auipc	ra,0x2
    8000101c:	660080e7          	jalr	1632(ra) # 80003678 <iinit>
    fileinit();      // file table
    80001020:	00003097          	auipc	ra,0x3
    80001024:	62a080e7          	jalr	1578(ra) # 8000464a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001028:	00005097          	auipc	ra,0x5
    8000102c:	fc2080e7          	jalr	-62(ra) # 80005fea <virtio_disk_init>
    userinit();      // first user process
    80001030:	00001097          	auipc	ra,0x1
    80001034:	e40080e7          	jalr	-448(ra) # 80001e70 <userinit>
    __sync_synchronize();
    80001038:	0ff0000f          	fence
    started = 1;
    8000103c:	4785                	li	a5,1
    8000103e:	00008717          	auipc	a4,0x8
    80001042:	fcf72723          	sw	a5,-50(a4) # 8000900c <started>
    80001046:	b789                	j	80000f88 <main+0x56>

0000000080001048 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001048:	1141                	addi	sp,sp,-16
    8000104a:	e422                	sd	s0,8(sp)
    8000104c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000104e:	00008797          	auipc	a5,0x8
    80001052:	fc278793          	addi	a5,a5,-62 # 80009010 <kernel_pagetable>
    80001056:	639c                	ld	a5,0(a5)
    80001058:	83b1                	srli	a5,a5,0xc
    8000105a:	577d                	li	a4,-1
    8000105c:	177e                	slli	a4,a4,0x3f
    8000105e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001060:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001064:	12000073          	sfence.vma
  sfence_vma();
}
    80001068:	6422                	ld	s0,8(sp)
    8000106a:	0141                	addi	sp,sp,16
    8000106c:	8082                	ret

000000008000106e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000106e:	7139                	addi	sp,sp,-64
    80001070:	fc06                	sd	ra,56(sp)
    80001072:	f822                	sd	s0,48(sp)
    80001074:	f426                	sd	s1,40(sp)
    80001076:	f04a                	sd	s2,32(sp)
    80001078:	ec4e                	sd	s3,24(sp)
    8000107a:	e852                	sd	s4,16(sp)
    8000107c:	e456                	sd	s5,8(sp)
    8000107e:	e05a                	sd	s6,0(sp)
    80001080:	0080                	addi	s0,sp,64
    80001082:	84aa                	mv	s1,a0
    80001084:	89ae                	mv	s3,a1
    80001086:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80001088:	57fd                	li	a5,-1
    8000108a:	83e9                	srli	a5,a5,0x1a
    8000108c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000108e:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80001090:	04b7f263          	bleu	a1,a5,800010d4 <walk+0x66>
    panic("walk");
    80001094:	00007517          	auipc	a0,0x7
    80001098:	03c50513          	addi	a0,a0,60 # 800080d0 <digits+0xb8>
    8000109c:	fffff097          	auipc	ra,0xfffff
    800010a0:	4d8080e7          	jalr	1240(ra) # 80000574 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010a4:	060b0663          	beqz	s6,80001110 <walk+0xa2>
    800010a8:	00000097          	auipc	ra,0x0
    800010ac:	aca080e7          	jalr	-1334(ra) # 80000b72 <kalloc>
    800010b0:	84aa                	mv	s1,a0
    800010b2:	c529                	beqz	a0,800010fc <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800010b4:	6605                	lui	a2,0x1
    800010b6:	4581                	li	a1,0
    800010b8:	00000097          	auipc	ra,0x0
    800010bc:	ca6080e7          	jalr	-858(ra) # 80000d5e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010c0:	00c4d793          	srli	a5,s1,0xc
    800010c4:	07aa                	slli	a5,a5,0xa
    800010c6:	0017e793          	ori	a5,a5,1
    800010ca:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010ce:	3a5d                	addiw	s4,s4,-9
    800010d0:	035a0063          	beq	s4,s5,800010f0 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010d4:	0149d933          	srl	s2,s3,s4
    800010d8:	1ff97913          	andi	s2,s2,511
    800010dc:	090e                	slli	s2,s2,0x3
    800010de:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010e0:	00093483          	ld	s1,0(s2)
    800010e4:	0014f793          	andi	a5,s1,1
    800010e8:	dfd5                	beqz	a5,800010a4 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010ea:	80a9                	srli	s1,s1,0xa
    800010ec:	04b2                	slli	s1,s1,0xc
    800010ee:	b7c5                	j	800010ce <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010f0:	00c9d513          	srli	a0,s3,0xc
    800010f4:	1ff57513          	andi	a0,a0,511
    800010f8:	050e                	slli	a0,a0,0x3
    800010fa:	9526                	add	a0,a0,s1
}
    800010fc:	70e2                	ld	ra,56(sp)
    800010fe:	7442                	ld	s0,48(sp)
    80001100:	74a2                	ld	s1,40(sp)
    80001102:	7902                	ld	s2,32(sp)
    80001104:	69e2                	ld	s3,24(sp)
    80001106:	6a42                	ld	s4,16(sp)
    80001108:	6aa2                	ld	s5,8(sp)
    8000110a:	6b02                	ld	s6,0(sp)
    8000110c:	6121                	addi	sp,sp,64
    8000110e:	8082                	ret
        return 0;
    80001110:	4501                	li	a0,0
    80001112:	b7ed                	j	800010fc <walk+0x8e>

0000000080001114 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    80001114:	1101                	addi	sp,sp,-32
    80001116:	ec06                	sd	ra,24(sp)
    80001118:	e822                	sd	s0,16(sp)
    8000111a:	e426                	sd	s1,8(sp)
    8000111c:	1000                	addi	s0,sp,32
    8000111e:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80001120:	6785                	lui	a5,0x1
    80001122:	17fd                	addi	a5,a5,-1
    80001124:	00f574b3          	and	s1,a0,a5
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    80001128:	4601                	li	a2,0
    8000112a:	00008797          	auipc	a5,0x8
    8000112e:	ee678793          	addi	a5,a5,-282 # 80009010 <kernel_pagetable>
    80001132:	6388                	ld	a0,0(a5)
    80001134:	00000097          	auipc	ra,0x0
    80001138:	f3a080e7          	jalr	-198(ra) # 8000106e <walk>
  if(pte == 0)
    8000113c:	cd09                	beqz	a0,80001156 <kvmpa+0x42>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    8000113e:	6108                	ld	a0,0(a0)
    80001140:	00157793          	andi	a5,a0,1
    80001144:	c38d                	beqz	a5,80001166 <kvmpa+0x52>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001146:	8129                	srli	a0,a0,0xa
    80001148:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    8000114a:	9526                	add	a0,a0,s1
    8000114c:	60e2                	ld	ra,24(sp)
    8000114e:	6442                	ld	s0,16(sp)
    80001150:	64a2                	ld	s1,8(sp)
    80001152:	6105                	addi	sp,sp,32
    80001154:	8082                	ret
    panic("kvmpa");
    80001156:	00007517          	auipc	a0,0x7
    8000115a:	f8250513          	addi	a0,a0,-126 # 800080d8 <digits+0xc0>
    8000115e:	fffff097          	auipc	ra,0xfffff
    80001162:	416080e7          	jalr	1046(ra) # 80000574 <panic>
    panic("kvmpa");
    80001166:	00007517          	auipc	a0,0x7
    8000116a:	f7250513          	addi	a0,a0,-142 # 800080d8 <digits+0xc0>
    8000116e:	fffff097          	auipc	ra,0xfffff
    80001172:	406080e7          	jalr	1030(ra) # 80000574 <panic>

0000000080001176 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001176:	715d                	addi	sp,sp,-80
    80001178:	e486                	sd	ra,72(sp)
    8000117a:	e0a2                	sd	s0,64(sp)
    8000117c:	fc26                	sd	s1,56(sp)
    8000117e:	f84a                	sd	s2,48(sp)
    80001180:	f44e                	sd	s3,40(sp)
    80001182:	f052                	sd	s4,32(sp)
    80001184:	ec56                	sd	s5,24(sp)
    80001186:	e85a                	sd	s6,16(sp)
    80001188:	e45e                	sd	s7,8(sp)
    8000118a:	0880                	addi	s0,sp,80
    8000118c:	8aaa                	mv	s5,a0
    8000118e:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001190:	79fd                	lui	s3,0xfffff
    80001192:	0135fa33          	and	s4,a1,s3
  last = PGROUNDDOWN(va + size - 1);
    80001196:	167d                	addi	a2,a2,-1
    80001198:	962e                	add	a2,a2,a1
    8000119a:	013679b3          	and	s3,a2,s3
  a = PGROUNDDOWN(va);
    8000119e:	8952                	mv	s2,s4
    800011a0:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011a4:	6b85                	lui	s7,0x1
    800011a6:	a811                	j	800011ba <mappages+0x44>
      panic("remap");
    800011a8:	00007517          	auipc	a0,0x7
    800011ac:	f3850513          	addi	a0,a0,-200 # 800080e0 <digits+0xc8>
    800011b0:	fffff097          	auipc	ra,0xfffff
    800011b4:	3c4080e7          	jalr	964(ra) # 80000574 <panic>
    a += PGSIZE;
    800011b8:	995e                	add	s2,s2,s7
  for(;;){
    800011ba:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011be:	4605                	li	a2,1
    800011c0:	85ca                	mv	a1,s2
    800011c2:	8556                	mv	a0,s5
    800011c4:	00000097          	auipc	ra,0x0
    800011c8:	eaa080e7          	jalr	-342(ra) # 8000106e <walk>
    800011cc:	cd19                	beqz	a0,800011ea <mappages+0x74>
    if(*pte & PTE_V)
    800011ce:	611c                	ld	a5,0(a0)
    800011d0:	8b85                	andi	a5,a5,1
    800011d2:	fbf9                	bnez	a5,800011a8 <mappages+0x32>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011d4:	80b1                	srli	s1,s1,0xc
    800011d6:	04aa                	slli	s1,s1,0xa
    800011d8:	0164e4b3          	or	s1,s1,s6
    800011dc:	0014e493          	ori	s1,s1,1
    800011e0:	e104                	sd	s1,0(a0)
    if(a == last)
    800011e2:	fd391be3          	bne	s2,s3,800011b8 <mappages+0x42>
    pa += PGSIZE;
  }
  return 0;
    800011e6:	4501                	li	a0,0
    800011e8:	a011                	j	800011ec <mappages+0x76>
      return -1;
    800011ea:	557d                	li	a0,-1
}
    800011ec:	60a6                	ld	ra,72(sp)
    800011ee:	6406                	ld	s0,64(sp)
    800011f0:	74e2                	ld	s1,56(sp)
    800011f2:	7942                	ld	s2,48(sp)
    800011f4:	79a2                	ld	s3,40(sp)
    800011f6:	7a02                	ld	s4,32(sp)
    800011f8:	6ae2                	ld	s5,24(sp)
    800011fa:	6b42                	ld	s6,16(sp)
    800011fc:	6ba2                	ld	s7,8(sp)
    800011fe:	6161                	addi	sp,sp,80
    80001200:	8082                	ret

0000000080001202 <kvmmap>:
{
    80001202:	1141                	addi	sp,sp,-16
    80001204:	e406                	sd	ra,8(sp)
    80001206:	e022                	sd	s0,0(sp)
    80001208:	0800                	addi	s0,sp,16
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    8000120a:	8736                	mv	a4,a3
    8000120c:	86ae                	mv	a3,a1
    8000120e:	85aa                	mv	a1,a0
    80001210:	00008797          	auipc	a5,0x8
    80001214:	e0078793          	addi	a5,a5,-512 # 80009010 <kernel_pagetable>
    80001218:	6388                	ld	a0,0(a5)
    8000121a:	00000097          	auipc	ra,0x0
    8000121e:	f5c080e7          	jalr	-164(ra) # 80001176 <mappages>
    80001222:	e509                	bnez	a0,8000122c <kvmmap+0x2a>
}
    80001224:	60a2                	ld	ra,8(sp)
    80001226:	6402                	ld	s0,0(sp)
    80001228:	0141                	addi	sp,sp,16
    8000122a:	8082                	ret
    panic("kvmmap");
    8000122c:	00007517          	auipc	a0,0x7
    80001230:	ebc50513          	addi	a0,a0,-324 # 800080e8 <digits+0xd0>
    80001234:	fffff097          	auipc	ra,0xfffff
    80001238:	340080e7          	jalr	832(ra) # 80000574 <panic>

000000008000123c <kvminit>:
{
    8000123c:	1101                	addi	sp,sp,-32
    8000123e:	ec06                	sd	ra,24(sp)
    80001240:	e822                	sd	s0,16(sp)
    80001242:	e426                	sd	s1,8(sp)
    80001244:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	92c080e7          	jalr	-1748(ra) # 80000b72 <kalloc>
    8000124e:	00008797          	auipc	a5,0x8
    80001252:	dca7b123          	sd	a0,-574(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001256:	6605                	lui	a2,0x1
    80001258:	4581                	li	a1,0
    8000125a:	00000097          	auipc	ra,0x0
    8000125e:	b04080e7          	jalr	-1276(ra) # 80000d5e <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001262:	4699                	li	a3,6
    80001264:	6605                	lui	a2,0x1
    80001266:	100005b7          	lui	a1,0x10000
    8000126a:	10000537          	lui	a0,0x10000
    8000126e:	00000097          	auipc	ra,0x0
    80001272:	f94080e7          	jalr	-108(ra) # 80001202 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001276:	4699                	li	a3,6
    80001278:	6605                	lui	a2,0x1
    8000127a:	100015b7          	lui	a1,0x10001
    8000127e:	10001537          	lui	a0,0x10001
    80001282:	00000097          	auipc	ra,0x0
    80001286:	f80080e7          	jalr	-128(ra) # 80001202 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    8000128a:	4699                	li	a3,6
    8000128c:	6641                	lui	a2,0x10
    8000128e:	020005b7          	lui	a1,0x2000
    80001292:	02000537          	lui	a0,0x2000
    80001296:	00000097          	auipc	ra,0x0
    8000129a:	f6c080e7          	jalr	-148(ra) # 80001202 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000129e:	4699                	li	a3,6
    800012a0:	00400637          	lui	a2,0x400
    800012a4:	0c0005b7          	lui	a1,0xc000
    800012a8:	0c000537          	lui	a0,0xc000
    800012ac:	00000097          	auipc	ra,0x0
    800012b0:	f56080e7          	jalr	-170(ra) # 80001202 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012b4:	00007497          	auipc	s1,0x7
    800012b8:	d4c48493          	addi	s1,s1,-692 # 80008000 <etext>
    800012bc:	46a9                	li	a3,10
    800012be:	80007617          	auipc	a2,0x80007
    800012c2:	d4260613          	addi	a2,a2,-702 # 8000 <_entry-0x7fff8000>
    800012c6:	4585                	li	a1,1
    800012c8:	05fe                	slli	a1,a1,0x1f
    800012ca:	852e                	mv	a0,a1
    800012cc:	00000097          	auipc	ra,0x0
    800012d0:	f36080e7          	jalr	-202(ra) # 80001202 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012d4:	4699                	li	a3,6
    800012d6:	4645                	li	a2,17
    800012d8:	066e                	slli	a2,a2,0x1b
    800012da:	8e05                	sub	a2,a2,s1
    800012dc:	85a6                	mv	a1,s1
    800012de:	8526                	mv	a0,s1
    800012e0:	00000097          	auipc	ra,0x0
    800012e4:	f22080e7          	jalr	-222(ra) # 80001202 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012e8:	46a9                	li	a3,10
    800012ea:	6605                	lui	a2,0x1
    800012ec:	00006597          	auipc	a1,0x6
    800012f0:	d1458593          	addi	a1,a1,-748 # 80007000 <_trampoline>
    800012f4:	04000537          	lui	a0,0x4000
    800012f8:	157d                	addi	a0,a0,-1
    800012fa:	0532                	slli	a0,a0,0xc
    800012fc:	00000097          	auipc	ra,0x0
    80001300:	f06080e7          	jalr	-250(ra) # 80001202 <kvmmap>
}
    80001304:	60e2                	ld	ra,24(sp)
    80001306:	6442                	ld	s0,16(sp)
    80001308:	64a2                	ld	s1,8(sp)
    8000130a:	6105                	addi	sp,sp,32
    8000130c:	8082                	ret

000000008000130e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000130e:	715d                	addi	sp,sp,-80
    80001310:	e486                	sd	ra,72(sp)
    80001312:	e0a2                	sd	s0,64(sp)
    80001314:	fc26                	sd	s1,56(sp)
    80001316:	f84a                	sd	s2,48(sp)
    80001318:	f44e                	sd	s3,40(sp)
    8000131a:	f052                	sd	s4,32(sp)
    8000131c:	ec56                	sd	s5,24(sp)
    8000131e:	e85a                	sd	s6,16(sp)
    80001320:	e45e                	sd	s7,8(sp)
    80001322:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001324:	6785                	lui	a5,0x1
    80001326:	17fd                	addi	a5,a5,-1
    80001328:	8fed                	and	a5,a5,a1
    8000132a:	e795                	bnez	a5,80001356 <uvmunmap+0x48>
    8000132c:	8a2a                	mv	s4,a0
    8000132e:	84ae                	mv	s1,a1
    80001330:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001332:	0632                	slli	a2,a2,0xc
    80001334:	00b609b3          	add	s3,a2,a1
      continue;
      // panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      continue;
      //panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001338:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000133a:	6b05                	lui	s6,0x1
    8000133c:	0535e863          	bltu	a1,s3,8000138c <uvmunmap+0x7e>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001340:	60a6                	ld	ra,72(sp)
    80001342:	6406                	ld	s0,64(sp)
    80001344:	74e2                	ld	s1,56(sp)
    80001346:	7942                	ld	s2,48(sp)
    80001348:	79a2                	ld	s3,40(sp)
    8000134a:	7a02                	ld	s4,32(sp)
    8000134c:	6ae2                	ld	s5,24(sp)
    8000134e:	6b42                	ld	s6,16(sp)
    80001350:	6ba2                	ld	s7,8(sp)
    80001352:	6161                	addi	sp,sp,80
    80001354:	8082                	ret
    panic("uvmunmap: not aligned");
    80001356:	00007517          	auipc	a0,0x7
    8000135a:	d9a50513          	addi	a0,a0,-614 # 800080f0 <digits+0xd8>
    8000135e:	fffff097          	auipc	ra,0xfffff
    80001362:	216080e7          	jalr	534(ra) # 80000574 <panic>
      panic("uvmunmap: not a leaf");
    80001366:	00007517          	auipc	a0,0x7
    8000136a:	da250513          	addi	a0,a0,-606 # 80008108 <digits+0xf0>
    8000136e:	fffff097          	auipc	ra,0xfffff
    80001372:	206080e7          	jalr	518(ra) # 80000574 <panic>
      uint64 pa = PTE2PA(*pte);
    80001376:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001378:	0532                	slli	a0,a0,0xc
    8000137a:	fffff097          	auipc	ra,0xfffff
    8000137e:	6f8080e7          	jalr	1784(ra) # 80000a72 <kfree>
    *pte = 0;
    80001382:	00093023          	sd	zero,0(s2)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001386:	94da                	add	s1,s1,s6
    80001388:	fb34fce3          	bleu	s3,s1,80001340 <uvmunmap+0x32>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000138c:	4601                	li	a2,0
    8000138e:	85a6                	mv	a1,s1
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	cdc080e7          	jalr	-804(ra) # 8000106e <walk>
    8000139a:	892a                	mv	s2,a0
    8000139c:	d56d                	beqz	a0,80001386 <uvmunmap+0x78>
    if((*pte & PTE_V) == 0)
    8000139e:	6108                	ld	a0,0(a0)
    800013a0:	00157793          	andi	a5,a0,1
    800013a4:	d3ed                	beqz	a5,80001386 <uvmunmap+0x78>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013a6:	3ff57793          	andi	a5,a0,1023
    800013aa:	fb778ee3          	beq	a5,s7,80001366 <uvmunmap+0x58>
    if(do_free){
    800013ae:	fc0a8ae3          	beqz	s5,80001382 <uvmunmap+0x74>
    800013b2:	b7d1                	j	80001376 <uvmunmap+0x68>

00000000800013b4 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013b4:	1101                	addi	sp,sp,-32
    800013b6:	ec06                	sd	ra,24(sp)
    800013b8:	e822                	sd	s0,16(sp)
    800013ba:	e426                	sd	s1,8(sp)
    800013bc:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013be:	fffff097          	auipc	ra,0xfffff
    800013c2:	7b4080e7          	jalr	1972(ra) # 80000b72 <kalloc>
    800013c6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013c8:	c519                	beqz	a0,800013d6 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013ca:	6605                	lui	a2,0x1
    800013cc:	4581                	li	a1,0
    800013ce:	00000097          	auipc	ra,0x0
    800013d2:	990080e7          	jalr	-1648(ra) # 80000d5e <memset>
  return pagetable;
}
    800013d6:	8526                	mv	a0,s1
    800013d8:	60e2                	ld	ra,24(sp)
    800013da:	6442                	ld	s0,16(sp)
    800013dc:	64a2                	ld	s1,8(sp)
    800013de:	6105                	addi	sp,sp,32
    800013e0:	8082                	ret

00000000800013e2 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800013e2:	7179                	addi	sp,sp,-48
    800013e4:	f406                	sd	ra,40(sp)
    800013e6:	f022                	sd	s0,32(sp)
    800013e8:	ec26                	sd	s1,24(sp)
    800013ea:	e84a                	sd	s2,16(sp)
    800013ec:	e44e                	sd	s3,8(sp)
    800013ee:	e052                	sd	s4,0(sp)
    800013f0:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013f2:	6785                	lui	a5,0x1
    800013f4:	04f67863          	bleu	a5,a2,80001444 <uvminit+0x62>
    800013f8:	8a2a                	mv	s4,a0
    800013fa:	89ae                	mv	s3,a1
    800013fc:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013fe:	fffff097          	auipc	ra,0xfffff
    80001402:	774080e7          	jalr	1908(ra) # 80000b72 <kalloc>
    80001406:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001408:	6605                	lui	a2,0x1
    8000140a:	4581                	li	a1,0
    8000140c:	00000097          	auipc	ra,0x0
    80001410:	952080e7          	jalr	-1710(ra) # 80000d5e <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001414:	4779                	li	a4,30
    80001416:	86ca                	mv	a3,s2
    80001418:	6605                	lui	a2,0x1
    8000141a:	4581                	li	a1,0
    8000141c:	8552                	mv	a0,s4
    8000141e:	00000097          	auipc	ra,0x0
    80001422:	d58080e7          	jalr	-680(ra) # 80001176 <mappages>
  memmove(mem, src, sz);
    80001426:	8626                	mv	a2,s1
    80001428:	85ce                	mv	a1,s3
    8000142a:	854a                	mv	a0,s2
    8000142c:	00000097          	auipc	ra,0x0
    80001430:	99e080e7          	jalr	-1634(ra) # 80000dca <memmove>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret
    panic("inituvm: more than a page");
    80001444:	00007517          	auipc	a0,0x7
    80001448:	cdc50513          	addi	a0,a0,-804 # 80008120 <digits+0x108>
    8000144c:	fffff097          	auipc	ra,0xfffff
    80001450:	128080e7          	jalr	296(ra) # 80000574 <panic>

0000000080001454 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001454:	1101                	addi	sp,sp,-32
    80001456:	ec06                	sd	ra,24(sp)
    80001458:	e822                	sd	s0,16(sp)
    8000145a:	e426                	sd	s1,8(sp)
    8000145c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000145e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001460:	00b67d63          	bleu	a1,a2,8000147a <uvmdealloc+0x26>
    80001464:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001466:	6605                	lui	a2,0x1
    80001468:	167d                	addi	a2,a2,-1
    8000146a:	00c487b3          	add	a5,s1,a2
    8000146e:	777d                	lui	a4,0xfffff
    80001470:	8ff9                	and	a5,a5,a4
    80001472:	962e                	add	a2,a2,a1
    80001474:	8e79                	and	a2,a2,a4
    80001476:	00c7e863          	bltu	a5,a2,80001486 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000147a:	8526                	mv	a0,s1
    8000147c:	60e2                	ld	ra,24(sp)
    8000147e:	6442                	ld	s0,16(sp)
    80001480:	64a2                	ld	s1,8(sp)
    80001482:	6105                	addi	sp,sp,32
    80001484:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001486:	8e1d                	sub	a2,a2,a5
    80001488:	8231                	srli	a2,a2,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000148a:	4685                	li	a3,1
    8000148c:	2601                	sext.w	a2,a2
    8000148e:	85be                	mv	a1,a5
    80001490:	00000097          	auipc	ra,0x0
    80001494:	e7e080e7          	jalr	-386(ra) # 8000130e <uvmunmap>
    80001498:	b7cd                	j	8000147a <uvmdealloc+0x26>

000000008000149a <uvmalloc>:
  if(newsz < oldsz)
    8000149a:	0ab66163          	bltu	a2,a1,8000153c <uvmalloc+0xa2>
{
    8000149e:	7139                	addi	sp,sp,-64
    800014a0:	fc06                	sd	ra,56(sp)
    800014a2:	f822                	sd	s0,48(sp)
    800014a4:	f426                	sd	s1,40(sp)
    800014a6:	f04a                	sd	s2,32(sp)
    800014a8:	ec4e                	sd	s3,24(sp)
    800014aa:	e852                	sd	s4,16(sp)
    800014ac:	e456                	sd	s5,8(sp)
    800014ae:	0080                	addi	s0,sp,64
  oldsz = PGROUNDUP(oldsz);
    800014b0:	6a05                	lui	s4,0x1
    800014b2:	1a7d                	addi	s4,s4,-1
    800014b4:	95d2                	add	a1,a1,s4
    800014b6:	7a7d                	lui	s4,0xfffff
    800014b8:	0145fa33          	and	s4,a1,s4
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014bc:	08ca7263          	bleu	a2,s4,80001540 <uvmalloc+0xa6>
    800014c0:	89b2                	mv	s3,a2
    800014c2:	8aaa                	mv	s5,a0
    800014c4:	8952                	mv	s2,s4
    mem = kalloc();
    800014c6:	fffff097          	auipc	ra,0xfffff
    800014ca:	6ac080e7          	jalr	1708(ra) # 80000b72 <kalloc>
    800014ce:	84aa                	mv	s1,a0
    if(mem == 0){
    800014d0:	c51d                	beqz	a0,800014fe <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800014d2:	6605                	lui	a2,0x1
    800014d4:	4581                	li	a1,0
    800014d6:	00000097          	auipc	ra,0x0
    800014da:	888080e7          	jalr	-1912(ra) # 80000d5e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014de:	4779                	li	a4,30
    800014e0:	86a6                	mv	a3,s1
    800014e2:	6605                	lui	a2,0x1
    800014e4:	85ca                	mv	a1,s2
    800014e6:	8556                	mv	a0,s5
    800014e8:	00000097          	auipc	ra,0x0
    800014ec:	c8e080e7          	jalr	-882(ra) # 80001176 <mappages>
    800014f0:	e905                	bnez	a0,80001520 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014f2:	6785                	lui	a5,0x1
    800014f4:	993e                	add	s2,s2,a5
    800014f6:	fd3968e3          	bltu	s2,s3,800014c6 <uvmalloc+0x2c>
  return newsz;
    800014fa:	854e                	mv	a0,s3
    800014fc:	a809                	j	8000150e <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800014fe:	8652                	mv	a2,s4
    80001500:	85ca                	mv	a1,s2
    80001502:	8556                	mv	a0,s5
    80001504:	00000097          	auipc	ra,0x0
    80001508:	f50080e7          	jalr	-176(ra) # 80001454 <uvmdealloc>
      return 0;
    8000150c:	4501                	li	a0,0
}
    8000150e:	70e2                	ld	ra,56(sp)
    80001510:	7442                	ld	s0,48(sp)
    80001512:	74a2                	ld	s1,40(sp)
    80001514:	7902                	ld	s2,32(sp)
    80001516:	69e2                	ld	s3,24(sp)
    80001518:	6a42                	ld	s4,16(sp)
    8000151a:	6aa2                	ld	s5,8(sp)
    8000151c:	6121                	addi	sp,sp,64
    8000151e:	8082                	ret
      kfree(mem);
    80001520:	8526                	mv	a0,s1
    80001522:	fffff097          	auipc	ra,0xfffff
    80001526:	550080e7          	jalr	1360(ra) # 80000a72 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000152a:	8652                	mv	a2,s4
    8000152c:	85ca                	mv	a1,s2
    8000152e:	8556                	mv	a0,s5
    80001530:	00000097          	auipc	ra,0x0
    80001534:	f24080e7          	jalr	-220(ra) # 80001454 <uvmdealloc>
      return 0;
    80001538:	4501                	li	a0,0
    8000153a:	bfd1                	j	8000150e <uvmalloc+0x74>
    return oldsz;
    8000153c:	852e                	mv	a0,a1
}
    8000153e:	8082                	ret
  return newsz;
    80001540:	8532                	mv	a0,a2
    80001542:	b7f1                	j	8000150e <uvmalloc+0x74>

0000000080001544 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001544:	7179                	addi	sp,sp,-48
    80001546:	f406                	sd	ra,40(sp)
    80001548:	f022                	sd	s0,32(sp)
    8000154a:	ec26                	sd	s1,24(sp)
    8000154c:	e84a                	sd	s2,16(sp)
    8000154e:	e44e                	sd	s3,8(sp)
    80001550:	e052                	sd	s4,0(sp)
    80001552:	1800                	addi	s0,sp,48
    80001554:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001556:	84aa                	mv	s1,a0
    80001558:	6905                	lui	s2,0x1
    8000155a:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000155c:	4985                	li	s3,1
    8000155e:	a821                	j	80001576 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001560:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001562:	0532                	slli	a0,a0,0xc
    80001564:	00000097          	auipc	ra,0x0
    80001568:	fe0080e7          	jalr	-32(ra) # 80001544 <freewalk>
      pagetable[i] = 0;
    8000156c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001570:	04a1                	addi	s1,s1,8
    80001572:	01248863          	beq	s1,s2,80001582 <freewalk+0x3e>
    pte_t pte = pagetable[i];
    80001576:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001578:	00f57793          	andi	a5,a0,15
    8000157c:	ff379ae3          	bne	a5,s3,80001570 <freewalk+0x2c>
    80001580:	b7c5                	j	80001560 <freewalk+0x1c>
    } else if(pte & PTE_V){
      // panic("freewalk: leaf");
    }
  }
  kfree((void*)pagetable);
    80001582:	8552                	mv	a0,s4
    80001584:	fffff097          	auipc	ra,0xfffff
    80001588:	4ee080e7          	jalr	1262(ra) # 80000a72 <kfree>
}
    8000158c:	70a2                	ld	ra,40(sp)
    8000158e:	7402                	ld	s0,32(sp)
    80001590:	64e2                	ld	s1,24(sp)
    80001592:	6942                	ld	s2,16(sp)
    80001594:	69a2                	ld	s3,8(sp)
    80001596:	6a02                	ld	s4,0(sp)
    80001598:	6145                	addi	sp,sp,48
    8000159a:	8082                	ret

000000008000159c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000159c:	1101                	addi	sp,sp,-32
    8000159e:	ec06                	sd	ra,24(sp)
    800015a0:	e822                	sd	s0,16(sp)
    800015a2:	e426                	sd	s1,8(sp)
    800015a4:	1000                	addi	s0,sp,32
    800015a6:	84aa                	mv	s1,a0
  if(sz > 0)
    800015a8:	e999                	bnez	a1,800015be <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015aa:	8526                	mv	a0,s1
    800015ac:	00000097          	auipc	ra,0x0
    800015b0:	f98080e7          	jalr	-104(ra) # 80001544 <freewalk>
}
    800015b4:	60e2                	ld	ra,24(sp)
    800015b6:	6442                	ld	s0,16(sp)
    800015b8:	64a2                	ld	s1,8(sp)
    800015ba:	6105                	addi	sp,sp,32
    800015bc:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015be:	6605                	lui	a2,0x1
    800015c0:	167d                	addi	a2,a2,-1
    800015c2:	962e                	add	a2,a2,a1
    800015c4:	4685                	li	a3,1
    800015c6:	8231                	srli	a2,a2,0xc
    800015c8:	4581                	li	a1,0
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	d44080e7          	jalr	-700(ra) # 8000130e <uvmunmap>
    800015d2:	bfe1                	j	800015aa <uvmfree+0xe>

00000000800015d4 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015d4:	ca4d                	beqz	a2,80001686 <uvmcopy+0xb2>
{
    800015d6:	715d                	addi	sp,sp,-80
    800015d8:	e486                	sd	ra,72(sp)
    800015da:	e0a2                	sd	s0,64(sp)
    800015dc:	fc26                	sd	s1,56(sp)
    800015de:	f84a                	sd	s2,48(sp)
    800015e0:	f44e                	sd	s3,40(sp)
    800015e2:	f052                	sd	s4,32(sp)
    800015e4:	ec56                	sd	s5,24(sp)
    800015e6:	e85a                	sd	s6,16(sp)
    800015e8:	e45e                	sd	s7,8(sp)
    800015ea:	0880                	addi	s0,sp,80
    800015ec:	8a32                	mv	s4,a2
    800015ee:	8b2e                	mv	s6,a1
    800015f0:	8aaa                	mv	s5,a0
  for(i = 0; i < sz; i += PGSIZE){
    800015f2:	4481                	li	s1,0
    800015f4:	a029                	j	800015fe <uvmcopy+0x2a>
    800015f6:	6785                	lui	a5,0x1
    800015f8:	94be                	add	s1,s1,a5
    800015fa:	0744fa63          	bleu	s4,s1,8000166e <uvmcopy+0x9a>
    if((pte = walk(old, i, 0)) == 0)
    800015fe:	4601                	li	a2,0
    80001600:	85a6                	mv	a1,s1
    80001602:	8556                	mv	a0,s5
    80001604:	00000097          	auipc	ra,0x0
    80001608:	a6a080e7          	jalr	-1430(ra) # 8000106e <walk>
    8000160c:	d56d                	beqz	a0,800015f6 <uvmcopy+0x22>
      continue;
      // panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000160e:	6118                	ld	a4,0(a0)
    80001610:	00177793          	andi	a5,a4,1
    80001614:	d3ed                	beqz	a5,800015f6 <uvmcopy+0x22>
      continue;
      // panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001616:	00a75793          	srli	a5,a4,0xa
    8000161a:	00c79b93          	slli	s7,a5,0xc
    flags = PTE_FLAGS(*pte);
    8000161e:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001622:	fffff097          	auipc	ra,0xfffff
    80001626:	550080e7          	jalr	1360(ra) # 80000b72 <kalloc>
    8000162a:	89aa                	mv	s3,a0
    8000162c:	c515                	beqz	a0,80001658 <uvmcopy+0x84>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000162e:	6605                	lui	a2,0x1
    80001630:	85de                	mv	a1,s7
    80001632:	fffff097          	auipc	ra,0xfffff
    80001636:	798080e7          	jalr	1944(ra) # 80000dca <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000163a:	874a                	mv	a4,s2
    8000163c:	86ce                	mv	a3,s3
    8000163e:	6605                	lui	a2,0x1
    80001640:	85a6                	mv	a1,s1
    80001642:	855a                	mv	a0,s6
    80001644:	00000097          	auipc	ra,0x0
    80001648:	b32080e7          	jalr	-1230(ra) # 80001176 <mappages>
    8000164c:	d54d                	beqz	a0,800015f6 <uvmcopy+0x22>
      kfree(mem);
    8000164e:	854e                	mv	a0,s3
    80001650:	fffff097          	auipc	ra,0xfffff
    80001654:	422080e7          	jalr	1058(ra) # 80000a72 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001658:	4685                	li	a3,1
    8000165a:	00c4d613          	srli	a2,s1,0xc
    8000165e:	4581                	li	a1,0
    80001660:	855a                	mv	a0,s6
    80001662:	00000097          	auipc	ra,0x0
    80001666:	cac080e7          	jalr	-852(ra) # 8000130e <uvmunmap>
  return -1;
    8000166a:	557d                	li	a0,-1
    8000166c:	a011                	j	80001670 <uvmcopy+0x9c>
  return 0;
    8000166e:	4501                	li	a0,0
}
    80001670:	60a6                	ld	ra,72(sp)
    80001672:	6406                	ld	s0,64(sp)
    80001674:	74e2                	ld	s1,56(sp)
    80001676:	7942                	ld	s2,48(sp)
    80001678:	79a2                	ld	s3,40(sp)
    8000167a:	7a02                	ld	s4,32(sp)
    8000167c:	6ae2                	ld	s5,24(sp)
    8000167e:	6b42                	ld	s6,16(sp)
    80001680:	6ba2                	ld	s7,8(sp)
    80001682:	6161                	addi	sp,sp,80
    80001684:	8082                	ret
  return 0;
    80001686:	4501                	li	a0,0
}
    80001688:	8082                	ret

000000008000168a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000168a:	1141                	addi	sp,sp,-16
    8000168c:	e406                	sd	ra,8(sp)
    8000168e:	e022                	sd	s0,0(sp)
    80001690:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001692:	4601                	li	a2,0
    80001694:	00000097          	auipc	ra,0x0
    80001698:	9da080e7          	jalr	-1574(ra) # 8000106e <walk>
  if(pte == 0)
    8000169c:	c901                	beqz	a0,800016ac <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000169e:	611c                	ld	a5,0(a0)
    800016a0:	9bbd                	andi	a5,a5,-17
    800016a2:	e11c                	sd	a5,0(a0)
}
    800016a4:	60a2                	ld	ra,8(sp)
    800016a6:	6402                	ld	s0,0(sp)
    800016a8:	0141                	addi	sp,sp,16
    800016aa:	8082                	ret
    panic("uvmclear");
    800016ac:	00007517          	auipc	a0,0x7
    800016b0:	a9450513          	addi	a0,a0,-1388 # 80008140 <digits+0x128>
    800016b4:	fffff097          	auipc	ra,0xfffff
    800016b8:	ec0080e7          	jalr	-320(ra) # 80000574 <panic>

00000000800016bc <lazy_alloc>:
    return -1;
  }
}

int
lazy_alloc(uint64 addr) {
    800016bc:	7179                	addi	sp,sp,-48
    800016be:	f406                	sd	ra,40(sp)
    800016c0:	f022                	sd	s0,32(sp)
    800016c2:	ec26                	sd	s1,24(sp)
    800016c4:	e84a                	sd	s2,16(sp)
    800016c6:	e44e                	sd	s3,8(sp)
    800016c8:	1800                	addi	s0,sp,48
    800016ca:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800016cc:	00000097          	auipc	ra,0x0
    800016d0:	4d8080e7          	jalr	1240(ra) # 80001ba4 <myproc>
  // page-faults on a virtual memory address higher than any allocated with sbrk()
  // this should be >= not > !!!
  if (addr >= p->sz) {
    800016d4:	653c                	ld	a5,72(a0)
    800016d6:	04f4fe63          	bleu	a5,s1,80001732 <lazy_alloc+0x76>
    800016da:	892a                	mv	s2,a0
    // printf("lazy_alloc: access invalid address");
    return -1;
  }

  if (addr < p->trapframe->sp) {
    800016dc:	6d3c                	ld	a5,88(a0)
    800016de:	7b9c                	ld	a5,48(a5)
    800016e0:	04f4eb63          	bltu	s1,a5,80001736 <lazy_alloc+0x7a>
    // printf("lazy_alloc: access address below stack");
    return -2;
  }
  
  uint64 pa = PGROUNDDOWN(addr);
    800016e4:	77fd                	lui	a5,0xfffff
    800016e6:	8cfd                	and	s1,s1,a5
  char* mem = kalloc();
    800016e8:	fffff097          	auipc	ra,0xfffff
    800016ec:	48a080e7          	jalr	1162(ra) # 80000b72 <kalloc>
    800016f0:	89aa                	mv	s3,a0
  if (mem == 0) {
    800016f2:	c521                	beqz	a0,8000173a <lazy_alloc+0x7e>
    // printf("lazy_alloc: kalloc failed");
    return -3;
  }
  
  memset(mem, 0, PGSIZE);
    800016f4:	6605                	lui	a2,0x1
    800016f6:	4581                	li	a1,0
    800016f8:	fffff097          	auipc	ra,0xfffff
    800016fc:	666080e7          	jalr	1638(ra) # 80000d5e <memset>
  if(mappages(p->pagetable, pa, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001700:	4779                	li	a4,30
    80001702:	86ce                	mv	a3,s3
    80001704:	6605                	lui	a2,0x1
    80001706:	85a6                	mv	a1,s1
    80001708:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    8000170c:	00000097          	auipc	ra,0x0
    80001710:	a6a080e7          	jalr	-1430(ra) # 80001176 <mappages>
    80001714:	e901                	bnez	a0,80001724 <lazy_alloc+0x68>
    kfree(mem);
    return -4;
  }
  return 0;
}
    80001716:	70a2                	ld	ra,40(sp)
    80001718:	7402                	ld	s0,32(sp)
    8000171a:	64e2                	ld	s1,24(sp)
    8000171c:	6942                	ld	s2,16(sp)
    8000171e:	69a2                	ld	s3,8(sp)
    80001720:	6145                	addi	sp,sp,48
    80001722:	8082                	ret
    kfree(mem);
    80001724:	854e                	mv	a0,s3
    80001726:	fffff097          	auipc	ra,0xfffff
    8000172a:	34c080e7          	jalr	844(ra) # 80000a72 <kfree>
    return -4;
    8000172e:	5571                	li	a0,-4
    80001730:	b7dd                	j	80001716 <lazy_alloc+0x5a>
    return -1;
    80001732:	557d                	li	a0,-1
    80001734:	b7cd                	j	80001716 <lazy_alloc+0x5a>
    return -2;
    80001736:	5579                	li	a0,-2
    80001738:	bff9                	j	80001716 <lazy_alloc+0x5a>
    return -3;
    8000173a:	5575                	li	a0,-3
    8000173c:	bfe9                	j	80001716 <lazy_alloc+0x5a>

000000008000173e <walkaddr>:
  if(va >= MAXVA)
    8000173e:	57fd                	li	a5,-1
    80001740:	83e9                	srli	a5,a5,0x1a
    80001742:	00b7f563          	bleu	a1,a5,8000174c <walkaddr+0xe>
    return 0;
    80001746:	4781                	li	a5,0
}
    80001748:	853e                	mv	a0,a5
    8000174a:	8082                	ret
{
    8000174c:	1101                	addi	sp,sp,-32
    8000174e:	ec06                	sd	ra,24(sp)
    80001750:	e822                	sd	s0,16(sp)
    80001752:	e426                	sd	s1,8(sp)
    80001754:	e04a                	sd	s2,0(sp)
    80001756:	1000                	addi	s0,sp,32
    80001758:	84ae                	mv	s1,a1
    8000175a:	892a                	mv	s2,a0
  pte = walk(pagetable, va, 0);
    8000175c:	4601                	li	a2,0
    8000175e:	00000097          	auipc	ra,0x0
    80001762:	910080e7          	jalr	-1776(ra) # 8000106e <walk>
  if(pte == 0 || (*pte & PTE_V) == 0) {
    80001766:	c501                	beqz	a0,8000176e <walkaddr+0x30>
    80001768:	611c                	ld	a5,0(a0)
    8000176a:	8b85                	andi	a5,a5,1
    8000176c:	ef99                	bnez	a5,8000178a <walkaddr+0x4c>
    if (lazy_alloc(va) == 0) {
    8000176e:	8526                	mv	a0,s1
    80001770:	00000097          	auipc	ra,0x0
    80001774:	f4c080e7          	jalr	-180(ra) # 800016bc <lazy_alloc>
      return 0;
    80001778:	4781                	li	a5,0
    if (lazy_alloc(va) == 0) {
    8000177a:	ed19                	bnez	a0,80001798 <walkaddr+0x5a>
      pte = walk(pagetable, va, 0);
    8000177c:	4601                	li	a2,0
    8000177e:	85a6                	mv	a1,s1
    80001780:	854a                	mv	a0,s2
    80001782:	00000097          	auipc	ra,0x0
    80001786:	8ec080e7          	jalr	-1812(ra) # 8000106e <walk>
  if((*pte & PTE_U) == 0)
    8000178a:	6118                	ld	a4,0(a0)
    8000178c:	01077793          	andi	a5,a4,16
    80001790:	c781                	beqz	a5,80001798 <walkaddr+0x5a>
  pa = PTE2PA(*pte);
    80001792:	00a75793          	srli	a5,a4,0xa
    80001796:	07b2                	slli	a5,a5,0xc
}
    80001798:	853e                	mv	a0,a5
    8000179a:	60e2                	ld	ra,24(sp)
    8000179c:	6442                	ld	s0,16(sp)
    8000179e:	64a2                	ld	s1,8(sp)
    800017a0:	6902                	ld	s2,0(sp)
    800017a2:	6105                	addi	sp,sp,32
    800017a4:	8082                	ret

00000000800017a6 <copyout>:
  while(len > 0){
    800017a6:	c6bd                	beqz	a3,80001814 <copyout+0x6e>
{
    800017a8:	715d                	addi	sp,sp,-80
    800017aa:	e486                	sd	ra,72(sp)
    800017ac:	e0a2                	sd	s0,64(sp)
    800017ae:	fc26                	sd	s1,56(sp)
    800017b0:	f84a                	sd	s2,48(sp)
    800017b2:	f44e                	sd	s3,40(sp)
    800017b4:	f052                	sd	s4,32(sp)
    800017b6:	ec56                	sd	s5,24(sp)
    800017b8:	e85a                	sd	s6,16(sp)
    800017ba:	e45e                	sd	s7,8(sp)
    800017bc:	e062                	sd	s8,0(sp)
    800017be:	0880                	addi	s0,sp,80
    800017c0:	8baa                	mv	s7,a0
    800017c2:	8a2e                	mv	s4,a1
    800017c4:	8ab2                	mv	s5,a2
    800017c6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800017c8:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (dstva - va0);
    800017ca:	6b05                	lui	s6,0x1
    800017cc:	a015                	j	800017f0 <copyout+0x4a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017ce:	9552                	add	a0,a0,s4
    800017d0:	0004861b          	sext.w	a2,s1
    800017d4:	85d6                	mv	a1,s5
    800017d6:	41250533          	sub	a0,a0,s2
    800017da:	fffff097          	auipc	ra,0xfffff
    800017de:	5f0080e7          	jalr	1520(ra) # 80000dca <memmove>
    len -= n;
    800017e2:	409989b3          	sub	s3,s3,s1
    src += n;
    800017e6:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    800017e8:	01690a33          	add	s4,s2,s6
  while(len > 0){
    800017ec:	02098263          	beqz	s3,80001810 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800017f0:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    800017f4:	85ca                	mv	a1,s2
    800017f6:	855e                	mv	a0,s7
    800017f8:	00000097          	auipc	ra,0x0
    800017fc:	f46080e7          	jalr	-186(ra) # 8000173e <walkaddr>
    if(pa0 == 0)
    80001800:	cd01                	beqz	a0,80001818 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001802:	414904b3          	sub	s1,s2,s4
    80001806:	94da                	add	s1,s1,s6
    if(n > len)
    80001808:	fc99f3e3          	bleu	s1,s3,800017ce <copyout+0x28>
    8000180c:	84ce                	mv	s1,s3
    8000180e:	b7c1                	j	800017ce <copyout+0x28>
  return 0;
    80001810:	4501                	li	a0,0
    80001812:	a021                	j	8000181a <copyout+0x74>
    80001814:	4501                	li	a0,0
}
    80001816:	8082                	ret
      return -1;
    80001818:	557d                	li	a0,-1
}
    8000181a:	60a6                	ld	ra,72(sp)
    8000181c:	6406                	ld	s0,64(sp)
    8000181e:	74e2                	ld	s1,56(sp)
    80001820:	7942                	ld	s2,48(sp)
    80001822:	79a2                	ld	s3,40(sp)
    80001824:	7a02                	ld	s4,32(sp)
    80001826:	6ae2                	ld	s5,24(sp)
    80001828:	6b42                	ld	s6,16(sp)
    8000182a:	6ba2                	ld	s7,8(sp)
    8000182c:	6c02                	ld	s8,0(sp)
    8000182e:	6161                	addi	sp,sp,80
    80001830:	8082                	ret

0000000080001832 <copyin>:
  while(len > 0){
    80001832:	caa5                	beqz	a3,800018a2 <copyin+0x70>
{
    80001834:	715d                	addi	sp,sp,-80
    80001836:	e486                	sd	ra,72(sp)
    80001838:	e0a2                	sd	s0,64(sp)
    8000183a:	fc26                	sd	s1,56(sp)
    8000183c:	f84a                	sd	s2,48(sp)
    8000183e:	f44e                	sd	s3,40(sp)
    80001840:	f052                	sd	s4,32(sp)
    80001842:	ec56                	sd	s5,24(sp)
    80001844:	e85a                	sd	s6,16(sp)
    80001846:	e45e                	sd	s7,8(sp)
    80001848:	e062                	sd	s8,0(sp)
    8000184a:	0880                	addi	s0,sp,80
    8000184c:	8baa                	mv	s7,a0
    8000184e:	8aae                	mv	s5,a1
    80001850:	8a32                	mv	s4,a2
    80001852:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001854:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001856:	6b05                	lui	s6,0x1
    80001858:	a01d                	j	8000187e <copyin+0x4c>
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000185a:	014505b3          	add	a1,a0,s4
    8000185e:	0004861b          	sext.w	a2,s1
    80001862:	412585b3          	sub	a1,a1,s2
    80001866:	8556                	mv	a0,s5
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	562080e7          	jalr	1378(ra) # 80000dca <memmove>
    len -= n;
    80001870:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001874:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001876:	01690a33          	add	s4,s2,s6
  while(len > 0){
    8000187a:	02098263          	beqz	s3,8000189e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000187e:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    80001882:	85ca                	mv	a1,s2
    80001884:	855e                	mv	a0,s7
    80001886:	00000097          	auipc	ra,0x0
    8000188a:	eb8080e7          	jalr	-328(ra) # 8000173e <walkaddr>
    if(pa0 == 0)
    8000188e:	cd01                	beqz	a0,800018a6 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001890:	414904b3          	sub	s1,s2,s4
    80001894:	94da                	add	s1,s1,s6
    if(n > len)
    80001896:	fc99f2e3          	bleu	s1,s3,8000185a <copyin+0x28>
    8000189a:	84ce                	mv	s1,s3
    8000189c:	bf7d                	j	8000185a <copyin+0x28>
  return 0;
    8000189e:	4501                	li	a0,0
    800018a0:	a021                	j	800018a8 <copyin+0x76>
    800018a2:	4501                	li	a0,0
}
    800018a4:	8082                	ret
      return -1;
    800018a6:	557d                	li	a0,-1
}
    800018a8:	60a6                	ld	ra,72(sp)
    800018aa:	6406                	ld	s0,64(sp)
    800018ac:	74e2                	ld	s1,56(sp)
    800018ae:	7942                	ld	s2,48(sp)
    800018b0:	79a2                	ld	s3,40(sp)
    800018b2:	7a02                	ld	s4,32(sp)
    800018b4:	6ae2                	ld	s5,24(sp)
    800018b6:	6b42                	ld	s6,16(sp)
    800018b8:	6ba2                	ld	s7,8(sp)
    800018ba:	6c02                	ld	s8,0(sp)
    800018bc:	6161                	addi	sp,sp,80
    800018be:	8082                	ret

00000000800018c0 <copyinstr>:
  while(got_null == 0 && max > 0){
    800018c0:	ced5                	beqz	a3,8000197c <copyinstr+0xbc>
{
    800018c2:	715d                	addi	sp,sp,-80
    800018c4:	e486                	sd	ra,72(sp)
    800018c6:	e0a2                	sd	s0,64(sp)
    800018c8:	fc26                	sd	s1,56(sp)
    800018ca:	f84a                	sd	s2,48(sp)
    800018cc:	f44e                	sd	s3,40(sp)
    800018ce:	f052                	sd	s4,32(sp)
    800018d0:	ec56                	sd	s5,24(sp)
    800018d2:	e85a                	sd	s6,16(sp)
    800018d4:	e45e                	sd	s7,8(sp)
    800018d6:	e062                	sd	s8,0(sp)
    800018d8:	0880                	addi	s0,sp,80
    800018da:	8aaa                	mv	s5,a0
    800018dc:	84ae                	mv	s1,a1
    800018de:	8c32                	mv	s8,a2
    800018e0:	8bb6                	mv	s7,a3
    va0 = PGROUNDDOWN(srcva);
    800018e2:	7a7d                	lui	s4,0xfffff
    n = PGSIZE - (srcva - va0);
    800018e4:	6985                	lui	s3,0x1
    800018e6:	4b05                	li	s6,1
    800018e8:	a801                	j	800018f8 <copyinstr+0x38>
      if(*p == '\0'){
    800018ea:	87a6                	mv	a5,s1
    800018ec:	a085                	j	8000194c <copyinstr+0x8c>
      dst++;
    800018ee:	84b2                	mv	s1,a2
    srcva = va0 + PGSIZE;
    800018f0:	01390c33          	add	s8,s2,s3
  while(got_null == 0 && max > 0){
    800018f4:	080b8063          	beqz	s7,80001974 <copyinstr+0xb4>
    va0 = PGROUNDDOWN(srcva);
    800018f8:	014c7933          	and	s2,s8,s4
    pa0 = walkaddr(pagetable, va0);
    800018fc:	85ca                	mv	a1,s2
    800018fe:	8556                	mv	a0,s5
    80001900:	00000097          	auipc	ra,0x0
    80001904:	e3e080e7          	jalr	-450(ra) # 8000173e <walkaddr>
    if(pa0 == 0){
    80001908:	c925                	beqz	a0,80001978 <copyinstr+0xb8>
    n = PGSIZE - (srcva - va0);
    8000190a:	41890633          	sub	a2,s2,s8
    8000190e:	964e                	add	a2,a2,s3
    if(n > max)
    80001910:	00cbf363          	bleu	a2,s7,80001916 <copyinstr+0x56>
    80001914:	865e                	mv	a2,s7
    char *p = (char *) (pa0 + (srcva - va0));
    80001916:	9562                	add	a0,a0,s8
    80001918:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000191c:	da71                	beqz	a2,800018f0 <copyinstr+0x30>
      if(*p == '\0'){
    8000191e:	00054703          	lbu	a4,0(a0)
    80001922:	d761                	beqz	a4,800018ea <copyinstr+0x2a>
    80001924:	9626                	add	a2,a2,s1
    80001926:	87a6                	mv	a5,s1
    80001928:	1bfd                	addi	s7,s7,-1
    8000192a:	009b86b3          	add	a3,s7,s1
    8000192e:	409b04b3          	sub	s1,s6,s1
    80001932:	94aa                	add	s1,s1,a0
        *dst = *p;
    80001934:	00e78023          	sb	a4,0(a5) # fffffffffffff000 <end+0xffffffff7ffd9000>
      --max;
    80001938:	40f68bb3          	sub	s7,a3,a5
      p++;
    8000193c:	00f48733          	add	a4,s1,a5
      dst++;
    80001940:	0785                	addi	a5,a5,1
    while(n > 0){
    80001942:	faf606e3          	beq	a2,a5,800018ee <copyinstr+0x2e>
      if(*p == '\0'){
    80001946:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    8000194a:	f76d                	bnez	a4,80001934 <copyinstr+0x74>
        *dst = '\0';
    8000194c:	00078023          	sb	zero,0(a5)
    80001950:	4785                	li	a5,1
  if(got_null){
    80001952:	0017b513          	seqz	a0,a5
    80001956:	40a0053b          	negw	a0,a0
    8000195a:	2501                	sext.w	a0,a0
}
    8000195c:	60a6                	ld	ra,72(sp)
    8000195e:	6406                	ld	s0,64(sp)
    80001960:	74e2                	ld	s1,56(sp)
    80001962:	7942                	ld	s2,48(sp)
    80001964:	79a2                	ld	s3,40(sp)
    80001966:	7a02                	ld	s4,32(sp)
    80001968:	6ae2                	ld	s5,24(sp)
    8000196a:	6b42                	ld	s6,16(sp)
    8000196c:	6ba2                	ld	s7,8(sp)
    8000196e:	6c02                	ld	s8,0(sp)
    80001970:	6161                	addi	sp,sp,80
    80001972:	8082                	ret
    80001974:	4781                	li	a5,0
    80001976:	bff1                	j	80001952 <copyinstr+0x92>
      return -1;
    80001978:	557d                	li	a0,-1
    8000197a:	b7cd                	j	8000195c <copyinstr+0x9c>
  int got_null = 0;
    8000197c:	4781                	li	a5,0
  if(got_null){
    8000197e:	0017b513          	seqz	a0,a5
    80001982:	40a0053b          	negw	a0,a0
    80001986:	2501                	sext.w	a0,a0
}
    80001988:	8082                	ret

000000008000198a <printwalk>:

void printwalk(pagetable_t pagetable, uint level) {
    8000198a:	715d                	addi	sp,sp,-80
    8000198c:	e486                	sd	ra,72(sp)
    8000198e:	e0a2                	sd	s0,64(sp)
    80001990:	fc26                	sd	s1,56(sp)
    80001992:	f84a                	sd	s2,48(sp)
    80001994:	f44e                	sd	s3,40(sp)
    80001996:	f052                	sd	s4,32(sp)
    80001998:	ec56                	sd	s5,24(sp)
    8000199a:	e85a                	sd	s6,16(sp)
    8000199c:	e45e                	sd	s7,8(sp)
    8000199e:	e062                	sd	s8,0(sp)
    800019a0:	0880                	addi	s0,sp,80
  char* prefix;
  if (level == 2) prefix = "..";
    800019a2:	4789                	li	a5,2
    800019a4:	00006b17          	auipc	s6,0x6
    800019a8:	7acb0b13          	addi	s6,s6,1964 # 80008150 <digits+0x138>
    800019ac:	00f58d63          	beq	a1,a5,800019c6 <printwalk+0x3c>
  else if (level == 1) prefix = ".. ..";
    800019b0:	4785                	li	a5,1
    800019b2:	00006b17          	auipc	s6,0x6
    800019b6:	7a6b0b13          	addi	s6,s6,1958 # 80008158 <digits+0x140>
    800019ba:	00f58663          	beq	a1,a5,800019c6 <printwalk+0x3c>
  else prefix = ".. .. ..";
    800019be:	00006b17          	auipc	s6,0x6
    800019c2:	7a2b0b13          	addi	s6,s6,1954 # 80008160 <digits+0x148>

  for(int i = 0; i < 512; i++){
    800019c6:	89aa                	mv	s3,a0
    800019c8:	4901                	li	s2,0
    pte_t pte = pagetable[i];
    if(pte & PTE_V){
      uint64 pa = PTE2PA(pte);
      printf("%s%d: pte %p pa %p\n", prefix, i, pte, pa);
    800019ca:	00006b97          	auipc	s7,0x6
    800019ce:	7a6b8b93          	addi	s7,s7,1958 # 80008170 <digits+0x158>
      if((pte & (PTE_R|PTE_W|PTE_X)) == 0){
        printwalk((pagetable_t)pa, level - 1);
    800019d2:	fff58c1b          	addiw	s8,a1,-1
  for(int i = 0; i < 512; i++){
    800019d6:	20000a93          	li	s5,512
    800019da:	a819                	j	800019f0 <printwalk+0x66>
        printwalk((pagetable_t)pa, level - 1);
    800019dc:	85e2                	mv	a1,s8
    800019de:	8552                	mv	a0,s4
    800019e0:	00000097          	auipc	ra,0x0
    800019e4:	faa080e7          	jalr	-86(ra) # 8000198a <printwalk>
  for(int i = 0; i < 512; i++){
    800019e8:	2905                	addiw	s2,s2,1
    800019ea:	09a1                	addi	s3,s3,8
    800019ec:	03590663          	beq	s2,s5,80001a18 <printwalk+0x8e>
    pte_t pte = pagetable[i];
    800019f0:	0009b483          	ld	s1,0(s3) # 1000 <_entry-0x7ffff000>
    if(pte & PTE_V){
    800019f4:	0014f793          	andi	a5,s1,1
    800019f8:	dbe5                	beqz	a5,800019e8 <printwalk+0x5e>
      uint64 pa = PTE2PA(pte);
    800019fa:	00a4da13          	srli	s4,s1,0xa
    800019fe:	0a32                	slli	s4,s4,0xc
      printf("%s%d: pte %p pa %p\n", prefix, i, pte, pa);
    80001a00:	8752                	mv	a4,s4
    80001a02:	86a6                	mv	a3,s1
    80001a04:	864a                	mv	a2,s2
    80001a06:	85da                	mv	a1,s6
    80001a08:	855e                	mv	a0,s7
    80001a0a:	fffff097          	auipc	ra,0xfffff
    80001a0e:	bb4080e7          	jalr	-1100(ra) # 800005be <printf>
      if((pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001a12:	88b9                	andi	s1,s1,14
    80001a14:	f8f1                	bnez	s1,800019e8 <printwalk+0x5e>
    80001a16:	b7d9                	j	800019dc <printwalk+0x52>
      }
    }
  }
}
    80001a18:	60a6                	ld	ra,72(sp)
    80001a1a:	6406                	ld	s0,64(sp)
    80001a1c:	74e2                	ld	s1,56(sp)
    80001a1e:	7942                	ld	s2,48(sp)
    80001a20:	79a2                	ld	s3,40(sp)
    80001a22:	7a02                	ld	s4,32(sp)
    80001a24:	6ae2                	ld	s5,24(sp)
    80001a26:	6b42                	ld	s6,16(sp)
    80001a28:	6ba2                	ld	s7,8(sp)
    80001a2a:	6c02                	ld	s8,0(sp)
    80001a2c:	6161                	addi	sp,sp,80
    80001a2e:	8082                	ret

0000000080001a30 <vmprint>:

void
vmprint(pagetable_t pagetable) {
    80001a30:	1101                	addi	sp,sp,-32
    80001a32:	ec06                	sd	ra,24(sp)
    80001a34:	e822                	sd	s0,16(sp)
    80001a36:	e426                	sd	s1,8(sp)
    80001a38:	1000                	addi	s0,sp,32
    80001a3a:	84aa                	mv	s1,a0
  printf("page table %p\n", pagetable);
    80001a3c:	85aa                	mv	a1,a0
    80001a3e:	00006517          	auipc	a0,0x6
    80001a42:	74a50513          	addi	a0,a0,1866 # 80008188 <digits+0x170>
    80001a46:	fffff097          	auipc	ra,0xfffff
    80001a4a:	b78080e7          	jalr	-1160(ra) # 800005be <printf>
  printwalk(pagetable, 2);
    80001a4e:	4589                	li	a1,2
    80001a50:	8526                	mv	a0,s1
    80001a52:	00000097          	auipc	ra,0x0
    80001a56:	f38080e7          	jalr	-200(ra) # 8000198a <printwalk>
}
    80001a5a:	60e2                	ld	ra,24(sp)
    80001a5c:	6442                	ld	s0,16(sp)
    80001a5e:	64a2                	ld	s1,8(sp)
    80001a60:	6105                	addi	sp,sp,32
    80001a62:	8082                	ret

0000000080001a64 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001a64:	1101                	addi	sp,sp,-32
    80001a66:	ec06                	sd	ra,24(sp)
    80001a68:	e822                	sd	s0,16(sp)
    80001a6a:	e426                	sd	s1,8(sp)
    80001a6c:	1000                	addi	s0,sp,32
    80001a6e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	178080e7          	jalr	376(ra) # 80000be8 <holding>
    80001a78:	c909                	beqz	a0,80001a8a <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001a7a:	749c                	ld	a5,40(s1)
    80001a7c:	00978f63          	beq	a5,s1,80001a9a <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001a80:	60e2                	ld	ra,24(sp)
    80001a82:	6442                	ld	s0,16(sp)
    80001a84:	64a2                	ld	s1,8(sp)
    80001a86:	6105                	addi	sp,sp,32
    80001a88:	8082                	ret
    panic("wakeup1");
    80001a8a:	00006517          	auipc	a0,0x6
    80001a8e:	73650513          	addi	a0,a0,1846 # 800081c0 <states.1726+0x28>
    80001a92:	fffff097          	auipc	ra,0xfffff
    80001a96:	ae2080e7          	jalr	-1310(ra) # 80000574 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001a9a:	4c98                	lw	a4,24(s1)
    80001a9c:	4785                	li	a5,1
    80001a9e:	fef711e3          	bne	a4,a5,80001a80 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001aa2:	4789                	li	a5,2
    80001aa4:	cc9c                	sw	a5,24(s1)
}
    80001aa6:	bfe9                	j	80001a80 <wakeup1+0x1c>

0000000080001aa8 <procinit>:
{
    80001aa8:	715d                	addi	sp,sp,-80
    80001aaa:	e486                	sd	ra,72(sp)
    80001aac:	e0a2                	sd	s0,64(sp)
    80001aae:	fc26                	sd	s1,56(sp)
    80001ab0:	f84a                	sd	s2,48(sp)
    80001ab2:	f44e                	sd	s3,40(sp)
    80001ab4:	f052                	sd	s4,32(sp)
    80001ab6:	ec56                	sd	s5,24(sp)
    80001ab8:	e85a                	sd	s6,16(sp)
    80001aba:	e45e                	sd	s7,8(sp)
    80001abc:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001abe:	00006597          	auipc	a1,0x6
    80001ac2:	70a58593          	addi	a1,a1,1802 # 800081c8 <states.1726+0x30>
    80001ac6:	00010517          	auipc	a0,0x10
    80001aca:	e8a50513          	addi	a0,a0,-374 # 80011950 <pid_lock>
    80001ace:	fffff097          	auipc	ra,0xfffff
    80001ad2:	104080e7          	jalr	260(ra) # 80000bd2 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ad6:	00010917          	auipc	s2,0x10
    80001ada:	29290913          	addi	s2,s2,658 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001ade:	00006b97          	auipc	s7,0x6
    80001ae2:	6f2b8b93          	addi	s7,s7,1778 # 800081d0 <states.1726+0x38>
      uint64 va = KSTACK((int) (p - proc));
    80001ae6:	8b4a                	mv	s6,s2
    80001ae8:	00006a97          	auipc	s5,0x6
    80001aec:	518a8a93          	addi	s5,s5,1304 # 80008000 <etext>
    80001af0:	040009b7          	lui	s3,0x4000
    80001af4:	19fd                	addi	s3,s3,-1
    80001af6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001af8:	00016a17          	auipc	s4,0x16
    80001afc:	c70a0a13          	addi	s4,s4,-912 # 80017768 <tickslock>
      initlock(&p->lock, "proc");
    80001b00:	85de                	mv	a1,s7
    80001b02:	854a                	mv	a0,s2
    80001b04:	fffff097          	auipc	ra,0xfffff
    80001b08:	0ce080e7          	jalr	206(ra) # 80000bd2 <initlock>
      char *pa = kalloc();
    80001b0c:	fffff097          	auipc	ra,0xfffff
    80001b10:	066080e7          	jalr	102(ra) # 80000b72 <kalloc>
    80001b14:	85aa                	mv	a1,a0
      if(pa == 0)
    80001b16:	c929                	beqz	a0,80001b68 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001b18:	416904b3          	sub	s1,s2,s6
    80001b1c:	848d                	srai	s1,s1,0x3
    80001b1e:	000ab783          	ld	a5,0(s5)
    80001b22:	02f484b3          	mul	s1,s1,a5
    80001b26:	2485                	addiw	s1,s1,1
    80001b28:	00d4949b          	slliw	s1,s1,0xd
    80001b2c:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b30:	4699                	li	a3,6
    80001b32:	6605                	lui	a2,0x1
    80001b34:	8526                	mv	a0,s1
    80001b36:	fffff097          	auipc	ra,0xfffff
    80001b3a:	6cc080e7          	jalr	1740(ra) # 80001202 <kvmmap>
      p->kstack = va;
    80001b3e:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b42:	16890913          	addi	s2,s2,360
    80001b46:	fb491de3          	bne	s2,s4,80001b00 <procinit+0x58>
  kvminithart();
    80001b4a:	fffff097          	auipc	ra,0xfffff
    80001b4e:	4fe080e7          	jalr	1278(ra) # 80001048 <kvminithart>
}
    80001b52:	60a6                	ld	ra,72(sp)
    80001b54:	6406                	ld	s0,64(sp)
    80001b56:	74e2                	ld	s1,56(sp)
    80001b58:	7942                	ld	s2,48(sp)
    80001b5a:	79a2                	ld	s3,40(sp)
    80001b5c:	7a02                	ld	s4,32(sp)
    80001b5e:	6ae2                	ld	s5,24(sp)
    80001b60:	6b42                	ld	s6,16(sp)
    80001b62:	6ba2                	ld	s7,8(sp)
    80001b64:	6161                	addi	sp,sp,80
    80001b66:	8082                	ret
        panic("kalloc");
    80001b68:	00006517          	auipc	a0,0x6
    80001b6c:	67050513          	addi	a0,a0,1648 # 800081d8 <states.1726+0x40>
    80001b70:	fffff097          	auipc	ra,0xfffff
    80001b74:	a04080e7          	jalr	-1532(ra) # 80000574 <panic>

0000000080001b78 <cpuid>:
{
    80001b78:	1141                	addi	sp,sp,-16
    80001b7a:	e422                	sd	s0,8(sp)
    80001b7c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b7e:	8512                	mv	a0,tp
}
    80001b80:	2501                	sext.w	a0,a0
    80001b82:	6422                	ld	s0,8(sp)
    80001b84:	0141                	addi	sp,sp,16
    80001b86:	8082                	ret

0000000080001b88 <mycpu>:
mycpu(void) {
    80001b88:	1141                	addi	sp,sp,-16
    80001b8a:	e422                	sd	s0,8(sp)
    80001b8c:	0800                	addi	s0,sp,16
    80001b8e:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001b90:	2781                	sext.w	a5,a5
    80001b92:	079e                	slli	a5,a5,0x7
}
    80001b94:	00010517          	auipc	a0,0x10
    80001b98:	dd450513          	addi	a0,a0,-556 # 80011968 <cpus>
    80001b9c:	953e                	add	a0,a0,a5
    80001b9e:	6422                	ld	s0,8(sp)
    80001ba0:	0141                	addi	sp,sp,16
    80001ba2:	8082                	ret

0000000080001ba4 <myproc>:
myproc(void) {
    80001ba4:	1101                	addi	sp,sp,-32
    80001ba6:	ec06                	sd	ra,24(sp)
    80001ba8:	e822                	sd	s0,16(sp)
    80001baa:	e426                	sd	s1,8(sp)
    80001bac:	1000                	addi	s0,sp,32
  push_off();
    80001bae:	fffff097          	auipc	ra,0xfffff
    80001bb2:	068080e7          	jalr	104(ra) # 80000c16 <push_off>
    80001bb6:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001bb8:	2781                	sext.w	a5,a5
    80001bba:	079e                	slli	a5,a5,0x7
    80001bbc:	00010717          	auipc	a4,0x10
    80001bc0:	d9470713          	addi	a4,a4,-620 # 80011950 <pid_lock>
    80001bc4:	97ba                	add	a5,a5,a4
    80001bc6:	6f84                	ld	s1,24(a5)
  pop_off();
    80001bc8:	fffff097          	auipc	ra,0xfffff
    80001bcc:	0ee080e7          	jalr	238(ra) # 80000cb6 <pop_off>
}
    80001bd0:	8526                	mv	a0,s1
    80001bd2:	60e2                	ld	ra,24(sp)
    80001bd4:	6442                	ld	s0,16(sp)
    80001bd6:	64a2                	ld	s1,8(sp)
    80001bd8:	6105                	addi	sp,sp,32
    80001bda:	8082                	ret

0000000080001bdc <forkret>:
{
    80001bdc:	1141                	addi	sp,sp,-16
    80001bde:	e406                	sd	ra,8(sp)
    80001be0:	e022                	sd	s0,0(sp)
    80001be2:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001be4:	00000097          	auipc	ra,0x0
    80001be8:	fc0080e7          	jalr	-64(ra) # 80001ba4 <myproc>
    80001bec:	fffff097          	auipc	ra,0xfffff
    80001bf0:	12a080e7          	jalr	298(ra) # 80000d16 <release>
  if (first) {
    80001bf4:	00007797          	auipc	a5,0x7
    80001bf8:	bfc78793          	addi	a5,a5,-1028 # 800087f0 <first.1686>
    80001bfc:	439c                	lw	a5,0(a5)
    80001bfe:	eb89                	bnez	a5,80001c10 <forkret+0x34>
  usertrapret();
    80001c00:	00001097          	auipc	ra,0x1
    80001c04:	c26080e7          	jalr	-986(ra) # 80002826 <usertrapret>
}
    80001c08:	60a2                	ld	ra,8(sp)
    80001c0a:	6402                	ld	s0,0(sp)
    80001c0c:	0141                	addi	sp,sp,16
    80001c0e:	8082                	ret
    first = 0;
    80001c10:	00007797          	auipc	a5,0x7
    80001c14:	be07a023          	sw	zero,-1056(a5) # 800087f0 <first.1686>
    fsinit(ROOTDEV);
    80001c18:	4505                	li	a0,1
    80001c1a:	00002097          	auipc	ra,0x2
    80001c1e:	9e0080e7          	jalr	-1568(ra) # 800035fa <fsinit>
    80001c22:	bff9                	j	80001c00 <forkret+0x24>

0000000080001c24 <allocpid>:
allocpid() {
    80001c24:	1101                	addi	sp,sp,-32
    80001c26:	ec06                	sd	ra,24(sp)
    80001c28:	e822                	sd	s0,16(sp)
    80001c2a:	e426                	sd	s1,8(sp)
    80001c2c:	e04a                	sd	s2,0(sp)
    80001c2e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c30:	00010917          	auipc	s2,0x10
    80001c34:	d2090913          	addi	s2,s2,-736 # 80011950 <pid_lock>
    80001c38:	854a                	mv	a0,s2
    80001c3a:	fffff097          	auipc	ra,0xfffff
    80001c3e:	028080e7          	jalr	40(ra) # 80000c62 <acquire>
  pid = nextpid;
    80001c42:	00007797          	auipc	a5,0x7
    80001c46:	bb278793          	addi	a5,a5,-1102 # 800087f4 <nextpid>
    80001c4a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c4c:	0014871b          	addiw	a4,s1,1
    80001c50:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c52:	854a                	mv	a0,s2
    80001c54:	fffff097          	auipc	ra,0xfffff
    80001c58:	0c2080e7          	jalr	194(ra) # 80000d16 <release>
}
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	60e2                	ld	ra,24(sp)
    80001c60:	6442                	ld	s0,16(sp)
    80001c62:	64a2                	ld	s1,8(sp)
    80001c64:	6902                	ld	s2,0(sp)
    80001c66:	6105                	addi	sp,sp,32
    80001c68:	8082                	ret

0000000080001c6a <proc_pagetable>:
{
    80001c6a:	1101                	addi	sp,sp,-32
    80001c6c:	ec06                	sd	ra,24(sp)
    80001c6e:	e822                	sd	s0,16(sp)
    80001c70:	e426                	sd	s1,8(sp)
    80001c72:	e04a                	sd	s2,0(sp)
    80001c74:	1000                	addi	s0,sp,32
    80001c76:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	73c080e7          	jalr	1852(ra) # 800013b4 <uvmcreate>
    80001c80:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c82:	c121                	beqz	a0,80001cc2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c84:	4729                	li	a4,10
    80001c86:	00005697          	auipc	a3,0x5
    80001c8a:	37a68693          	addi	a3,a3,890 # 80007000 <_trampoline>
    80001c8e:	6605                	lui	a2,0x1
    80001c90:	040005b7          	lui	a1,0x4000
    80001c94:	15fd                	addi	a1,a1,-1
    80001c96:	05b2                	slli	a1,a1,0xc
    80001c98:	fffff097          	auipc	ra,0xfffff
    80001c9c:	4de080e7          	jalr	1246(ra) # 80001176 <mappages>
    80001ca0:	02054863          	bltz	a0,80001cd0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ca4:	4719                	li	a4,6
    80001ca6:	05893683          	ld	a3,88(s2)
    80001caa:	6605                	lui	a2,0x1
    80001cac:	020005b7          	lui	a1,0x2000
    80001cb0:	15fd                	addi	a1,a1,-1
    80001cb2:	05b6                	slli	a1,a1,0xd
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	fffff097          	auipc	ra,0xfffff
    80001cba:	4c0080e7          	jalr	1216(ra) # 80001176 <mappages>
    80001cbe:	02054163          	bltz	a0,80001ce0 <proc_pagetable+0x76>
}
    80001cc2:	8526                	mv	a0,s1
    80001cc4:	60e2                	ld	ra,24(sp)
    80001cc6:	6442                	ld	s0,16(sp)
    80001cc8:	64a2                	ld	s1,8(sp)
    80001cca:	6902                	ld	s2,0(sp)
    80001ccc:	6105                	addi	sp,sp,32
    80001cce:	8082                	ret
    uvmfree(pagetable, 0);
    80001cd0:	4581                	li	a1,0
    80001cd2:	8526                	mv	a0,s1
    80001cd4:	00000097          	auipc	ra,0x0
    80001cd8:	8c8080e7          	jalr	-1848(ra) # 8000159c <uvmfree>
    return 0;
    80001cdc:	4481                	li	s1,0
    80001cde:	b7d5                	j	80001cc2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ce0:	4681                	li	a3,0
    80001ce2:	4605                	li	a2,1
    80001ce4:	040005b7          	lui	a1,0x4000
    80001ce8:	15fd                	addi	a1,a1,-1
    80001cea:	05b2                	slli	a1,a1,0xc
    80001cec:	8526                	mv	a0,s1
    80001cee:	fffff097          	auipc	ra,0xfffff
    80001cf2:	620080e7          	jalr	1568(ra) # 8000130e <uvmunmap>
    uvmfree(pagetable, 0);
    80001cf6:	4581                	li	a1,0
    80001cf8:	8526                	mv	a0,s1
    80001cfa:	00000097          	auipc	ra,0x0
    80001cfe:	8a2080e7          	jalr	-1886(ra) # 8000159c <uvmfree>
    return 0;
    80001d02:	4481                	li	s1,0
    80001d04:	bf7d                	j	80001cc2 <proc_pagetable+0x58>

0000000080001d06 <proc_freepagetable>:
{
    80001d06:	1101                	addi	sp,sp,-32
    80001d08:	ec06                	sd	ra,24(sp)
    80001d0a:	e822                	sd	s0,16(sp)
    80001d0c:	e426                	sd	s1,8(sp)
    80001d0e:	e04a                	sd	s2,0(sp)
    80001d10:	1000                	addi	s0,sp,32
    80001d12:	84aa                	mv	s1,a0
    80001d14:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d16:	4681                	li	a3,0
    80001d18:	4605                	li	a2,1
    80001d1a:	040005b7          	lui	a1,0x4000
    80001d1e:	15fd                	addi	a1,a1,-1
    80001d20:	05b2                	slli	a1,a1,0xc
    80001d22:	fffff097          	auipc	ra,0xfffff
    80001d26:	5ec080e7          	jalr	1516(ra) # 8000130e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d2a:	4681                	li	a3,0
    80001d2c:	4605                	li	a2,1
    80001d2e:	020005b7          	lui	a1,0x2000
    80001d32:	15fd                	addi	a1,a1,-1
    80001d34:	05b6                	slli	a1,a1,0xd
    80001d36:	8526                	mv	a0,s1
    80001d38:	fffff097          	auipc	ra,0xfffff
    80001d3c:	5d6080e7          	jalr	1494(ra) # 8000130e <uvmunmap>
  uvmfree(pagetable, sz);
    80001d40:	85ca                	mv	a1,s2
    80001d42:	8526                	mv	a0,s1
    80001d44:	00000097          	auipc	ra,0x0
    80001d48:	858080e7          	jalr	-1960(ra) # 8000159c <uvmfree>
}
    80001d4c:	60e2                	ld	ra,24(sp)
    80001d4e:	6442                	ld	s0,16(sp)
    80001d50:	64a2                	ld	s1,8(sp)
    80001d52:	6902                	ld	s2,0(sp)
    80001d54:	6105                	addi	sp,sp,32
    80001d56:	8082                	ret

0000000080001d58 <freeproc>:
{
    80001d58:	1101                	addi	sp,sp,-32
    80001d5a:	ec06                	sd	ra,24(sp)
    80001d5c:	e822                	sd	s0,16(sp)
    80001d5e:	e426                	sd	s1,8(sp)
    80001d60:	1000                	addi	s0,sp,32
    80001d62:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001d64:	6d28                	ld	a0,88(a0)
    80001d66:	c509                	beqz	a0,80001d70 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001d68:	fffff097          	auipc	ra,0xfffff
    80001d6c:	d0a080e7          	jalr	-758(ra) # 80000a72 <kfree>
  p->trapframe = 0;
    80001d70:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001d74:	68a8                	ld	a0,80(s1)
    80001d76:	c511                	beqz	a0,80001d82 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001d78:	64ac                	ld	a1,72(s1)
    80001d7a:	00000097          	auipc	ra,0x0
    80001d7e:	f8c080e7          	jalr	-116(ra) # 80001d06 <proc_freepagetable>
  p->pagetable = 0;
    80001d82:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001d86:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001d8a:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001d8e:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001d92:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d96:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001d9a:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001d9e:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001da2:	0004ac23          	sw	zero,24(s1)
}
    80001da6:	60e2                	ld	ra,24(sp)
    80001da8:	6442                	ld	s0,16(sp)
    80001daa:	64a2                	ld	s1,8(sp)
    80001dac:	6105                	addi	sp,sp,32
    80001dae:	8082                	ret

0000000080001db0 <allocproc>:
{
    80001db0:	1101                	addi	sp,sp,-32
    80001db2:	ec06                	sd	ra,24(sp)
    80001db4:	e822                	sd	s0,16(sp)
    80001db6:	e426                	sd	s1,8(sp)
    80001db8:	e04a                	sd	s2,0(sp)
    80001dba:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dbc:	00010497          	auipc	s1,0x10
    80001dc0:	fac48493          	addi	s1,s1,-84 # 80011d68 <proc>
    80001dc4:	00016917          	auipc	s2,0x16
    80001dc8:	9a490913          	addi	s2,s2,-1628 # 80017768 <tickslock>
    acquire(&p->lock);
    80001dcc:	8526                	mv	a0,s1
    80001dce:	fffff097          	auipc	ra,0xfffff
    80001dd2:	e94080e7          	jalr	-364(ra) # 80000c62 <acquire>
    if(p->state == UNUSED) {
    80001dd6:	4c9c                	lw	a5,24(s1)
    80001dd8:	cf81                	beqz	a5,80001df0 <allocproc+0x40>
      release(&p->lock);
    80001dda:	8526                	mv	a0,s1
    80001ddc:	fffff097          	auipc	ra,0xfffff
    80001de0:	f3a080e7          	jalr	-198(ra) # 80000d16 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001de4:	16848493          	addi	s1,s1,360
    80001de8:	ff2492e3          	bne	s1,s2,80001dcc <allocproc+0x1c>
  return 0;
    80001dec:	4481                	li	s1,0
    80001dee:	a0b9                	j	80001e3c <allocproc+0x8c>
  p->pid = allocpid();
    80001df0:	00000097          	auipc	ra,0x0
    80001df4:	e34080e7          	jalr	-460(ra) # 80001c24 <allocpid>
    80001df8:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001dfa:	fffff097          	auipc	ra,0xfffff
    80001dfe:	d78080e7          	jalr	-648(ra) # 80000b72 <kalloc>
    80001e02:	892a                	mv	s2,a0
    80001e04:	eca8                	sd	a0,88(s1)
    80001e06:	c131                	beqz	a0,80001e4a <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001e08:	8526                	mv	a0,s1
    80001e0a:	00000097          	auipc	ra,0x0
    80001e0e:	e60080e7          	jalr	-416(ra) # 80001c6a <proc_pagetable>
    80001e12:	892a                	mv	s2,a0
    80001e14:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001e16:	c129                	beqz	a0,80001e58 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001e18:	07000613          	li	a2,112
    80001e1c:	4581                	li	a1,0
    80001e1e:	06048513          	addi	a0,s1,96
    80001e22:	fffff097          	auipc	ra,0xfffff
    80001e26:	f3c080e7          	jalr	-196(ra) # 80000d5e <memset>
  p->context.ra = (uint64)forkret;
    80001e2a:	00000797          	auipc	a5,0x0
    80001e2e:	db278793          	addi	a5,a5,-590 # 80001bdc <forkret>
    80001e32:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001e34:	60bc                	ld	a5,64(s1)
    80001e36:	6705                	lui	a4,0x1
    80001e38:	97ba                	add	a5,a5,a4
    80001e3a:	f4bc                	sd	a5,104(s1)
}
    80001e3c:	8526                	mv	a0,s1
    80001e3e:	60e2                	ld	ra,24(sp)
    80001e40:	6442                	ld	s0,16(sp)
    80001e42:	64a2                	ld	s1,8(sp)
    80001e44:	6902                	ld	s2,0(sp)
    80001e46:	6105                	addi	sp,sp,32
    80001e48:	8082                	ret
    release(&p->lock);
    80001e4a:	8526                	mv	a0,s1
    80001e4c:	fffff097          	auipc	ra,0xfffff
    80001e50:	eca080e7          	jalr	-310(ra) # 80000d16 <release>
    return 0;
    80001e54:	84ca                	mv	s1,s2
    80001e56:	b7dd                	j	80001e3c <allocproc+0x8c>
    freeproc(p);
    80001e58:	8526                	mv	a0,s1
    80001e5a:	00000097          	auipc	ra,0x0
    80001e5e:	efe080e7          	jalr	-258(ra) # 80001d58 <freeproc>
    release(&p->lock);
    80001e62:	8526                	mv	a0,s1
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	eb2080e7          	jalr	-334(ra) # 80000d16 <release>
    return 0;
    80001e6c:	84ca                	mv	s1,s2
    80001e6e:	b7f9                	j	80001e3c <allocproc+0x8c>

0000000080001e70 <userinit>:
{
    80001e70:	1101                	addi	sp,sp,-32
    80001e72:	ec06                	sd	ra,24(sp)
    80001e74:	e822                	sd	s0,16(sp)
    80001e76:	e426                	sd	s1,8(sp)
    80001e78:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e7a:	00000097          	auipc	ra,0x0
    80001e7e:	f36080e7          	jalr	-202(ra) # 80001db0 <allocproc>
    80001e82:	84aa                	mv	s1,a0
  initproc = p;
    80001e84:	00007797          	auipc	a5,0x7
    80001e88:	18a7ba23          	sd	a0,404(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001e8c:	03400613          	li	a2,52
    80001e90:	00007597          	auipc	a1,0x7
    80001e94:	97058593          	addi	a1,a1,-1680 # 80008800 <initcode>
    80001e98:	6928                	ld	a0,80(a0)
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	548080e7          	jalr	1352(ra) # 800013e2 <uvminit>
  p->sz = PGSIZE;
    80001ea2:	6785                	lui	a5,0x1
    80001ea4:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001ea6:	6cb8                	ld	a4,88(s1)
    80001ea8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001eac:	6cb8                	ld	a4,88(s1)
    80001eae:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001eb0:	4641                	li	a2,16
    80001eb2:	00006597          	auipc	a1,0x6
    80001eb6:	32e58593          	addi	a1,a1,814 # 800081e0 <states.1726+0x48>
    80001eba:	15848513          	addi	a0,s1,344
    80001ebe:	fffff097          	auipc	ra,0xfffff
    80001ec2:	018080e7          	jalr	24(ra) # 80000ed6 <safestrcpy>
  p->cwd = namei("/");
    80001ec6:	00006517          	auipc	a0,0x6
    80001eca:	32a50513          	addi	a0,a0,810 # 800081f0 <states.1726+0x58>
    80001ece:	00002097          	auipc	ra,0x2
    80001ed2:	164080e7          	jalr	356(ra) # 80004032 <namei>
    80001ed6:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001eda:	4789                	li	a5,2
    80001edc:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ede:	8526                	mv	a0,s1
    80001ee0:	fffff097          	auipc	ra,0xfffff
    80001ee4:	e36080e7          	jalr	-458(ra) # 80000d16 <release>
}
    80001ee8:	60e2                	ld	ra,24(sp)
    80001eea:	6442                	ld	s0,16(sp)
    80001eec:	64a2                	ld	s1,8(sp)
    80001eee:	6105                	addi	sp,sp,32
    80001ef0:	8082                	ret

0000000080001ef2 <growproc>:
{
    80001ef2:	1101                	addi	sp,sp,-32
    80001ef4:	ec06                	sd	ra,24(sp)
    80001ef6:	e822                	sd	s0,16(sp)
    80001ef8:	e426                	sd	s1,8(sp)
    80001efa:	e04a                	sd	s2,0(sp)
    80001efc:	1000                	addi	s0,sp,32
    80001efe:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f00:	00000097          	auipc	ra,0x0
    80001f04:	ca4080e7          	jalr	-860(ra) # 80001ba4 <myproc>
    80001f08:	892a                	mv	s2,a0
  sz = p->sz;
    80001f0a:	652c                	ld	a1,72(a0)
    80001f0c:	0005851b          	sext.w	a0,a1
  if(n > 0){
    80001f10:	00904f63          	bgtz	s1,80001f2e <growproc+0x3c>
  } else if(n < 0){
    80001f14:	0204cd63          	bltz	s1,80001f4e <growproc+0x5c>
  p->sz = sz;
    80001f18:	1502                	slli	a0,a0,0x20
    80001f1a:	9101                	srli	a0,a0,0x20
    80001f1c:	04a93423          	sd	a0,72(s2)
  return 0;
    80001f20:	4501                	li	a0,0
}
    80001f22:	60e2                	ld	ra,24(sp)
    80001f24:	6442                	ld	s0,16(sp)
    80001f26:	64a2                	ld	s1,8(sp)
    80001f28:	6902                	ld	s2,0(sp)
    80001f2a:	6105                	addi	sp,sp,32
    80001f2c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001f2e:	00a4863b          	addw	a2,s1,a0
    80001f32:	1602                	slli	a2,a2,0x20
    80001f34:	9201                	srli	a2,a2,0x20
    80001f36:	1582                	slli	a1,a1,0x20
    80001f38:	9181                	srli	a1,a1,0x20
    80001f3a:	05093503          	ld	a0,80(s2)
    80001f3e:	fffff097          	auipc	ra,0xfffff
    80001f42:	55c080e7          	jalr	1372(ra) # 8000149a <uvmalloc>
    80001f46:	2501                	sext.w	a0,a0
    80001f48:	f961                	bnez	a0,80001f18 <growproc+0x26>
      return -1;
    80001f4a:	557d                	li	a0,-1
    80001f4c:	bfd9                	j	80001f22 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f4e:	00a4863b          	addw	a2,s1,a0
    80001f52:	1602                	slli	a2,a2,0x20
    80001f54:	9201                	srli	a2,a2,0x20
    80001f56:	1582                	slli	a1,a1,0x20
    80001f58:	9181                	srli	a1,a1,0x20
    80001f5a:	05093503          	ld	a0,80(s2)
    80001f5e:	fffff097          	auipc	ra,0xfffff
    80001f62:	4f6080e7          	jalr	1270(ra) # 80001454 <uvmdealloc>
    80001f66:	2501                	sext.w	a0,a0
    80001f68:	bf45                	j	80001f18 <growproc+0x26>

0000000080001f6a <fork>:
{
    80001f6a:	7179                	addi	sp,sp,-48
    80001f6c:	f406                	sd	ra,40(sp)
    80001f6e:	f022                	sd	s0,32(sp)
    80001f70:	ec26                	sd	s1,24(sp)
    80001f72:	e84a                	sd	s2,16(sp)
    80001f74:	e44e                	sd	s3,8(sp)
    80001f76:	e052                	sd	s4,0(sp)
    80001f78:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f7a:	00000097          	auipc	ra,0x0
    80001f7e:	c2a080e7          	jalr	-982(ra) # 80001ba4 <myproc>
    80001f82:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001f84:	00000097          	auipc	ra,0x0
    80001f88:	e2c080e7          	jalr	-468(ra) # 80001db0 <allocproc>
    80001f8c:	c175                	beqz	a0,80002070 <fork+0x106>
    80001f8e:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f90:	04893603          	ld	a2,72(s2)
    80001f94:	692c                	ld	a1,80(a0)
    80001f96:	05093503          	ld	a0,80(s2)
    80001f9a:	fffff097          	auipc	ra,0xfffff
    80001f9e:	63a080e7          	jalr	1594(ra) # 800015d4 <uvmcopy>
    80001fa2:	04054863          	bltz	a0,80001ff2 <fork+0x88>
  np->sz = p->sz;
    80001fa6:	04893783          	ld	a5,72(s2)
    80001faa:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80001fae:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80001fb2:	05893683          	ld	a3,88(s2)
    80001fb6:	87b6                	mv	a5,a3
    80001fb8:	0589b703          	ld	a4,88(s3)
    80001fbc:	12068693          	addi	a3,a3,288
    80001fc0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001fc4:	6788                	ld	a0,8(a5)
    80001fc6:	6b8c                	ld	a1,16(a5)
    80001fc8:	6f90                	ld	a2,24(a5)
    80001fca:	01073023          	sd	a6,0(a4)
    80001fce:	e708                	sd	a0,8(a4)
    80001fd0:	eb0c                	sd	a1,16(a4)
    80001fd2:	ef10                	sd	a2,24(a4)
    80001fd4:	02078793          	addi	a5,a5,32
    80001fd8:	02070713          	addi	a4,a4,32
    80001fdc:	fed792e3          	bne	a5,a3,80001fc0 <fork+0x56>
  np->trapframe->a0 = 0;
    80001fe0:	0589b783          	ld	a5,88(s3)
    80001fe4:	0607b823          	sd	zero,112(a5)
    80001fe8:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001fec:	15000a13          	li	s4,336
    80001ff0:	a03d                	j	8000201e <fork+0xb4>
    freeproc(np);
    80001ff2:	854e                	mv	a0,s3
    80001ff4:	00000097          	auipc	ra,0x0
    80001ff8:	d64080e7          	jalr	-668(ra) # 80001d58 <freeproc>
    release(&np->lock);
    80001ffc:	854e                	mv	a0,s3
    80001ffe:	fffff097          	auipc	ra,0xfffff
    80002002:	d18080e7          	jalr	-744(ra) # 80000d16 <release>
    return -1;
    80002006:	54fd                	li	s1,-1
    80002008:	a899                	j	8000205e <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    8000200a:	00002097          	auipc	ra,0x2
    8000200e:	6e6080e7          	jalr	1766(ra) # 800046f0 <filedup>
    80002012:	009987b3          	add	a5,s3,s1
    80002016:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80002018:	04a1                	addi	s1,s1,8
    8000201a:	01448763          	beq	s1,s4,80002028 <fork+0xbe>
    if(p->ofile[i])
    8000201e:	009907b3          	add	a5,s2,s1
    80002022:	6388                	ld	a0,0(a5)
    80002024:	f17d                	bnez	a0,8000200a <fork+0xa0>
    80002026:	bfcd                	j	80002018 <fork+0xae>
  np->cwd = idup(p->cwd);
    80002028:	15093503          	ld	a0,336(s2)
    8000202c:	00002097          	auipc	ra,0x2
    80002030:	80a080e7          	jalr	-2038(ra) # 80003836 <idup>
    80002034:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002038:	4641                	li	a2,16
    8000203a:	15890593          	addi	a1,s2,344
    8000203e:	15898513          	addi	a0,s3,344
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	e94080e7          	jalr	-364(ra) # 80000ed6 <safestrcpy>
  pid = np->pid;
    8000204a:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    8000204e:	4789                	li	a5,2
    80002050:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002054:	854e                	mv	a0,s3
    80002056:	fffff097          	auipc	ra,0xfffff
    8000205a:	cc0080e7          	jalr	-832(ra) # 80000d16 <release>
}
    8000205e:	8526                	mv	a0,s1
    80002060:	70a2                	ld	ra,40(sp)
    80002062:	7402                	ld	s0,32(sp)
    80002064:	64e2                	ld	s1,24(sp)
    80002066:	6942                	ld	s2,16(sp)
    80002068:	69a2                	ld	s3,8(sp)
    8000206a:	6a02                	ld	s4,0(sp)
    8000206c:	6145                	addi	sp,sp,48
    8000206e:	8082                	ret
    return -1;
    80002070:	54fd                	li	s1,-1
    80002072:	b7f5                	j	8000205e <fork+0xf4>

0000000080002074 <reparent>:
{
    80002074:	7179                	addi	sp,sp,-48
    80002076:	f406                	sd	ra,40(sp)
    80002078:	f022                	sd	s0,32(sp)
    8000207a:	ec26                	sd	s1,24(sp)
    8000207c:	e84a                	sd	s2,16(sp)
    8000207e:	e44e                	sd	s3,8(sp)
    80002080:	e052                	sd	s4,0(sp)
    80002082:	1800                	addi	s0,sp,48
    80002084:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002086:	00010497          	auipc	s1,0x10
    8000208a:	ce248493          	addi	s1,s1,-798 # 80011d68 <proc>
      pp->parent = initproc;
    8000208e:	00007a17          	auipc	s4,0x7
    80002092:	f8aa0a13          	addi	s4,s4,-118 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002096:	00015917          	auipc	s2,0x15
    8000209a:	6d290913          	addi	s2,s2,1746 # 80017768 <tickslock>
    8000209e:	a029                	j	800020a8 <reparent+0x34>
    800020a0:	16848493          	addi	s1,s1,360
    800020a4:	03248363          	beq	s1,s2,800020ca <reparent+0x56>
    if(pp->parent == p){
    800020a8:	709c                	ld	a5,32(s1)
    800020aa:	ff379be3          	bne	a5,s3,800020a0 <reparent+0x2c>
      acquire(&pp->lock);
    800020ae:	8526                	mv	a0,s1
    800020b0:	fffff097          	auipc	ra,0xfffff
    800020b4:	bb2080e7          	jalr	-1102(ra) # 80000c62 <acquire>
      pp->parent = initproc;
    800020b8:	000a3783          	ld	a5,0(s4)
    800020bc:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    800020be:	8526                	mv	a0,s1
    800020c0:	fffff097          	auipc	ra,0xfffff
    800020c4:	c56080e7          	jalr	-938(ra) # 80000d16 <release>
    800020c8:	bfe1                	j	800020a0 <reparent+0x2c>
}
    800020ca:	70a2                	ld	ra,40(sp)
    800020cc:	7402                	ld	s0,32(sp)
    800020ce:	64e2                	ld	s1,24(sp)
    800020d0:	6942                	ld	s2,16(sp)
    800020d2:	69a2                	ld	s3,8(sp)
    800020d4:	6a02                	ld	s4,0(sp)
    800020d6:	6145                	addi	sp,sp,48
    800020d8:	8082                	ret

00000000800020da <scheduler>:
{
    800020da:	711d                	addi	sp,sp,-96
    800020dc:	ec86                	sd	ra,88(sp)
    800020de:	e8a2                	sd	s0,80(sp)
    800020e0:	e4a6                	sd	s1,72(sp)
    800020e2:	e0ca                	sd	s2,64(sp)
    800020e4:	fc4e                	sd	s3,56(sp)
    800020e6:	f852                	sd	s4,48(sp)
    800020e8:	f456                	sd	s5,40(sp)
    800020ea:	f05a                	sd	s6,32(sp)
    800020ec:	ec5e                	sd	s7,24(sp)
    800020ee:	e862                	sd	s8,16(sp)
    800020f0:	e466                	sd	s9,8(sp)
    800020f2:	1080                	addi	s0,sp,96
    800020f4:	8792                	mv	a5,tp
  int id = r_tp();
    800020f6:	2781                	sext.w	a5,a5
  c->proc = 0;
    800020f8:	00779c13          	slli	s8,a5,0x7
    800020fc:	00010717          	auipc	a4,0x10
    80002100:	85470713          	addi	a4,a4,-1964 # 80011950 <pid_lock>
    80002104:	9762                	add	a4,a4,s8
    80002106:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    8000210a:	00010717          	auipc	a4,0x10
    8000210e:	86670713          	addi	a4,a4,-1946 # 80011970 <cpus+0x8>
    80002112:	9c3a                	add	s8,s8,a4
      if(p->state == RUNNABLE) {
    80002114:	4a89                	li	s5,2
        c->proc = p;
    80002116:	079e                	slli	a5,a5,0x7
    80002118:	00010b17          	auipc	s6,0x10
    8000211c:	838b0b13          	addi	s6,s6,-1992 # 80011950 <pid_lock>
    80002120:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002122:	00015a17          	auipc	s4,0x15
    80002126:	646a0a13          	addi	s4,s4,1606 # 80017768 <tickslock>
    int nproc = 0;
    8000212a:	4c81                	li	s9,0
    8000212c:	a8a1                	j	80002184 <scheduler+0xaa>
        p->state = RUNNING;
    8000212e:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80002132:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    80002136:	06048593          	addi	a1,s1,96
    8000213a:	8562                	mv	a0,s8
    8000213c:	00000097          	auipc	ra,0x0
    80002140:	640080e7          	jalr	1600(ra) # 8000277c <swtch>
        c->proc = 0;
    80002144:	000b3c23          	sd	zero,24(s6)
      release(&p->lock);
    80002148:	8526                	mv	a0,s1
    8000214a:	fffff097          	auipc	ra,0xfffff
    8000214e:	bcc080e7          	jalr	-1076(ra) # 80000d16 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002152:	16848493          	addi	s1,s1,360
    80002156:	01448d63          	beq	s1,s4,80002170 <scheduler+0x96>
      acquire(&p->lock);
    8000215a:	8526                	mv	a0,s1
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	b06080e7          	jalr	-1274(ra) # 80000c62 <acquire>
      if(p->state != UNUSED) {
    80002164:	4c9c                	lw	a5,24(s1)
    80002166:	d3ed                	beqz	a5,80002148 <scheduler+0x6e>
        nproc++;
    80002168:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    8000216a:	fd579fe3          	bne	a5,s5,80002148 <scheduler+0x6e>
    8000216e:	b7c1                	j	8000212e <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    80002170:	013aca63          	blt	s5,s3,80002184 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002174:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002178:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000217c:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80002180:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002184:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002188:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000218c:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    80002190:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    80002192:	00010497          	auipc	s1,0x10
    80002196:	bd648493          	addi	s1,s1,-1066 # 80011d68 <proc>
        p->state = RUNNING;
    8000219a:	4b8d                	li	s7,3
    8000219c:	bf7d                	j	8000215a <scheduler+0x80>

000000008000219e <sched>:
{
    8000219e:	7179                	addi	sp,sp,-48
    800021a0:	f406                	sd	ra,40(sp)
    800021a2:	f022                	sd	s0,32(sp)
    800021a4:	ec26                	sd	s1,24(sp)
    800021a6:	e84a                	sd	s2,16(sp)
    800021a8:	e44e                	sd	s3,8(sp)
    800021aa:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800021ac:	00000097          	auipc	ra,0x0
    800021b0:	9f8080e7          	jalr	-1544(ra) # 80001ba4 <myproc>
    800021b4:	892a                	mv	s2,a0
  if(!holding(&p->lock))
    800021b6:	fffff097          	auipc	ra,0xfffff
    800021ba:	a32080e7          	jalr	-1486(ra) # 80000be8 <holding>
    800021be:	cd25                	beqz	a0,80002236 <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021c0:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800021c2:	2781                	sext.w	a5,a5
    800021c4:	079e                	slli	a5,a5,0x7
    800021c6:	0000f717          	auipc	a4,0xf
    800021ca:	78a70713          	addi	a4,a4,1930 # 80011950 <pid_lock>
    800021ce:	97ba                	add	a5,a5,a4
    800021d0:	0907a703          	lw	a4,144(a5)
    800021d4:	4785                	li	a5,1
    800021d6:	06f71863          	bne	a4,a5,80002246 <sched+0xa8>
  if(p->state == RUNNING)
    800021da:	01892703          	lw	a4,24(s2)
    800021de:	478d                	li	a5,3
    800021e0:	06f70b63          	beq	a4,a5,80002256 <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021e4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800021e8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800021ea:	efb5                	bnez	a5,80002266 <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021ec:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800021ee:	0000f497          	auipc	s1,0xf
    800021f2:	76248493          	addi	s1,s1,1890 # 80011950 <pid_lock>
    800021f6:	2781                	sext.w	a5,a5
    800021f8:	079e                	slli	a5,a5,0x7
    800021fa:	97a6                	add	a5,a5,s1
    800021fc:	0947a983          	lw	s3,148(a5)
    80002200:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002202:	2781                	sext.w	a5,a5
    80002204:	079e                	slli	a5,a5,0x7
    80002206:	0000f597          	auipc	a1,0xf
    8000220a:	76a58593          	addi	a1,a1,1898 # 80011970 <cpus+0x8>
    8000220e:	95be                	add	a1,a1,a5
    80002210:	06090513          	addi	a0,s2,96
    80002214:	00000097          	auipc	ra,0x0
    80002218:	568080e7          	jalr	1384(ra) # 8000277c <swtch>
    8000221c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000221e:	2781                	sext.w	a5,a5
    80002220:	079e                	slli	a5,a5,0x7
    80002222:	97a6                	add	a5,a5,s1
    80002224:	0937aa23          	sw	s3,148(a5)
}
    80002228:	70a2                	ld	ra,40(sp)
    8000222a:	7402                	ld	s0,32(sp)
    8000222c:	64e2                	ld	s1,24(sp)
    8000222e:	6942                	ld	s2,16(sp)
    80002230:	69a2                	ld	s3,8(sp)
    80002232:	6145                	addi	sp,sp,48
    80002234:	8082                	ret
    panic("sched p->lock");
    80002236:	00006517          	auipc	a0,0x6
    8000223a:	fc250513          	addi	a0,a0,-62 # 800081f8 <states.1726+0x60>
    8000223e:	ffffe097          	auipc	ra,0xffffe
    80002242:	336080e7          	jalr	822(ra) # 80000574 <panic>
    panic("sched locks");
    80002246:	00006517          	auipc	a0,0x6
    8000224a:	fc250513          	addi	a0,a0,-62 # 80008208 <states.1726+0x70>
    8000224e:	ffffe097          	auipc	ra,0xffffe
    80002252:	326080e7          	jalr	806(ra) # 80000574 <panic>
    panic("sched running");
    80002256:	00006517          	auipc	a0,0x6
    8000225a:	fc250513          	addi	a0,a0,-62 # 80008218 <states.1726+0x80>
    8000225e:	ffffe097          	auipc	ra,0xffffe
    80002262:	316080e7          	jalr	790(ra) # 80000574 <panic>
    panic("sched interruptible");
    80002266:	00006517          	auipc	a0,0x6
    8000226a:	fc250513          	addi	a0,a0,-62 # 80008228 <states.1726+0x90>
    8000226e:	ffffe097          	auipc	ra,0xffffe
    80002272:	306080e7          	jalr	774(ra) # 80000574 <panic>

0000000080002276 <exit>:
{
    80002276:	7179                	addi	sp,sp,-48
    80002278:	f406                	sd	ra,40(sp)
    8000227a:	f022                	sd	s0,32(sp)
    8000227c:	ec26                	sd	s1,24(sp)
    8000227e:	e84a                	sd	s2,16(sp)
    80002280:	e44e                	sd	s3,8(sp)
    80002282:	e052                	sd	s4,0(sp)
    80002284:	1800                	addi	s0,sp,48
    80002286:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002288:	00000097          	auipc	ra,0x0
    8000228c:	91c080e7          	jalr	-1764(ra) # 80001ba4 <myproc>
    80002290:	89aa                	mv	s3,a0
  if(p == initproc)
    80002292:	00007797          	auipc	a5,0x7
    80002296:	d8678793          	addi	a5,a5,-634 # 80009018 <initproc>
    8000229a:	639c                	ld	a5,0(a5)
    8000229c:	0d050493          	addi	s1,a0,208
    800022a0:	15050913          	addi	s2,a0,336
    800022a4:	02a79363          	bne	a5,a0,800022ca <exit+0x54>
    panic("init exiting");
    800022a8:	00006517          	auipc	a0,0x6
    800022ac:	f9850513          	addi	a0,a0,-104 # 80008240 <states.1726+0xa8>
    800022b0:	ffffe097          	auipc	ra,0xffffe
    800022b4:	2c4080e7          	jalr	708(ra) # 80000574 <panic>
      fileclose(f);
    800022b8:	00002097          	auipc	ra,0x2
    800022bc:	48a080e7          	jalr	1162(ra) # 80004742 <fileclose>
      p->ofile[fd] = 0;
    800022c0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800022c4:	04a1                	addi	s1,s1,8
    800022c6:	01248563          	beq	s1,s2,800022d0 <exit+0x5a>
    if(p->ofile[fd]){
    800022ca:	6088                	ld	a0,0(s1)
    800022cc:	f575                	bnez	a0,800022b8 <exit+0x42>
    800022ce:	bfdd                	j	800022c4 <exit+0x4e>
  begin_op();
    800022d0:	00002097          	auipc	ra,0x2
    800022d4:	f70080e7          	jalr	-144(ra) # 80004240 <begin_op>
  iput(p->cwd);
    800022d8:	1509b503          	ld	a0,336(s3)
    800022dc:	00001097          	auipc	ra,0x1
    800022e0:	754080e7          	jalr	1876(ra) # 80003a30 <iput>
  end_op();
    800022e4:	00002097          	auipc	ra,0x2
    800022e8:	fdc080e7          	jalr	-36(ra) # 800042c0 <end_op>
  p->cwd = 0;
    800022ec:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    800022f0:	00007497          	auipc	s1,0x7
    800022f4:	d2848493          	addi	s1,s1,-728 # 80009018 <initproc>
    800022f8:	6088                	ld	a0,0(s1)
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	968080e7          	jalr	-1688(ra) # 80000c62 <acquire>
  wakeup1(initproc);
    80002302:	6088                	ld	a0,0(s1)
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	760080e7          	jalr	1888(ra) # 80001a64 <wakeup1>
  release(&initproc->lock);
    8000230c:	6088                	ld	a0,0(s1)
    8000230e:	fffff097          	auipc	ra,0xfffff
    80002312:	a08080e7          	jalr	-1528(ra) # 80000d16 <release>
  acquire(&p->lock);
    80002316:	854e                	mv	a0,s3
    80002318:	fffff097          	auipc	ra,0xfffff
    8000231c:	94a080e7          	jalr	-1718(ra) # 80000c62 <acquire>
  struct proc *original_parent = p->parent;
    80002320:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002324:	854e                	mv	a0,s3
    80002326:	fffff097          	auipc	ra,0xfffff
    8000232a:	9f0080e7          	jalr	-1552(ra) # 80000d16 <release>
  acquire(&original_parent->lock);
    8000232e:	8526                	mv	a0,s1
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	932080e7          	jalr	-1742(ra) # 80000c62 <acquire>
  acquire(&p->lock);
    80002338:	854e                	mv	a0,s3
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	928080e7          	jalr	-1752(ra) # 80000c62 <acquire>
  reparent(p);
    80002342:	854e                	mv	a0,s3
    80002344:	00000097          	auipc	ra,0x0
    80002348:	d30080e7          	jalr	-720(ra) # 80002074 <reparent>
  wakeup1(original_parent);
    8000234c:	8526                	mv	a0,s1
    8000234e:	fffff097          	auipc	ra,0xfffff
    80002352:	716080e7          	jalr	1814(ra) # 80001a64 <wakeup1>
  p->xstate = status;
    80002356:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    8000235a:	4791                	li	a5,4
    8000235c:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    80002360:	8526                	mv	a0,s1
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	9b4080e7          	jalr	-1612(ra) # 80000d16 <release>
  sched();
    8000236a:	00000097          	auipc	ra,0x0
    8000236e:	e34080e7          	jalr	-460(ra) # 8000219e <sched>
  panic("zombie exit");
    80002372:	00006517          	auipc	a0,0x6
    80002376:	ede50513          	addi	a0,a0,-290 # 80008250 <states.1726+0xb8>
    8000237a:	ffffe097          	auipc	ra,0xffffe
    8000237e:	1fa080e7          	jalr	506(ra) # 80000574 <panic>

0000000080002382 <yield>:
{
    80002382:	1101                	addi	sp,sp,-32
    80002384:	ec06                	sd	ra,24(sp)
    80002386:	e822                	sd	s0,16(sp)
    80002388:	e426                	sd	s1,8(sp)
    8000238a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000238c:	00000097          	auipc	ra,0x0
    80002390:	818080e7          	jalr	-2024(ra) # 80001ba4 <myproc>
    80002394:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002396:	fffff097          	auipc	ra,0xfffff
    8000239a:	8cc080e7          	jalr	-1844(ra) # 80000c62 <acquire>
  p->state = RUNNABLE;
    8000239e:	4789                	li	a5,2
    800023a0:	cc9c                	sw	a5,24(s1)
  sched();
    800023a2:	00000097          	auipc	ra,0x0
    800023a6:	dfc080e7          	jalr	-516(ra) # 8000219e <sched>
  release(&p->lock);
    800023aa:	8526                	mv	a0,s1
    800023ac:	fffff097          	auipc	ra,0xfffff
    800023b0:	96a080e7          	jalr	-1686(ra) # 80000d16 <release>
}
    800023b4:	60e2                	ld	ra,24(sp)
    800023b6:	6442                	ld	s0,16(sp)
    800023b8:	64a2                	ld	s1,8(sp)
    800023ba:	6105                	addi	sp,sp,32
    800023bc:	8082                	ret

00000000800023be <sleep>:
{
    800023be:	7179                	addi	sp,sp,-48
    800023c0:	f406                	sd	ra,40(sp)
    800023c2:	f022                	sd	s0,32(sp)
    800023c4:	ec26                	sd	s1,24(sp)
    800023c6:	e84a                	sd	s2,16(sp)
    800023c8:	e44e                	sd	s3,8(sp)
    800023ca:	1800                	addi	s0,sp,48
    800023cc:	89aa                	mv	s3,a0
    800023ce:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	7d4080e7          	jalr	2004(ra) # 80001ba4 <myproc>
    800023d8:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800023da:	05250663          	beq	a0,s2,80002426 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800023de:	fffff097          	auipc	ra,0xfffff
    800023e2:	884080e7          	jalr	-1916(ra) # 80000c62 <acquire>
    release(lk);
    800023e6:	854a                	mv	a0,s2
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	92e080e7          	jalr	-1746(ra) # 80000d16 <release>
  p->chan = chan;
    800023f0:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    800023f4:	4785                	li	a5,1
    800023f6:	cc9c                	sw	a5,24(s1)
  sched();
    800023f8:	00000097          	auipc	ra,0x0
    800023fc:	da6080e7          	jalr	-602(ra) # 8000219e <sched>
  p->chan = 0;
    80002400:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002404:	8526                	mv	a0,s1
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	910080e7          	jalr	-1776(ra) # 80000d16 <release>
    acquire(lk);
    8000240e:	854a                	mv	a0,s2
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	852080e7          	jalr	-1966(ra) # 80000c62 <acquire>
}
    80002418:	70a2                	ld	ra,40(sp)
    8000241a:	7402                	ld	s0,32(sp)
    8000241c:	64e2                	ld	s1,24(sp)
    8000241e:	6942                	ld	s2,16(sp)
    80002420:	69a2                	ld	s3,8(sp)
    80002422:	6145                	addi	sp,sp,48
    80002424:	8082                	ret
  p->chan = chan;
    80002426:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    8000242a:	4785                	li	a5,1
    8000242c:	cd1c                	sw	a5,24(a0)
  sched();
    8000242e:	00000097          	auipc	ra,0x0
    80002432:	d70080e7          	jalr	-656(ra) # 8000219e <sched>
  p->chan = 0;
    80002436:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    8000243a:	bff9                	j	80002418 <sleep+0x5a>

000000008000243c <wait>:
{
    8000243c:	715d                	addi	sp,sp,-80
    8000243e:	e486                	sd	ra,72(sp)
    80002440:	e0a2                	sd	s0,64(sp)
    80002442:	fc26                	sd	s1,56(sp)
    80002444:	f84a                	sd	s2,48(sp)
    80002446:	f44e                	sd	s3,40(sp)
    80002448:	f052                	sd	s4,32(sp)
    8000244a:	ec56                	sd	s5,24(sp)
    8000244c:	e85a                	sd	s6,16(sp)
    8000244e:	e45e                	sd	s7,8(sp)
    80002450:	e062                	sd	s8,0(sp)
    80002452:	0880                	addi	s0,sp,80
    80002454:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	74e080e7          	jalr	1870(ra) # 80001ba4 <myproc>
    8000245e:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002460:	8c2a                	mv	s8,a0
    80002462:	fffff097          	auipc	ra,0xfffff
    80002466:	800080e7          	jalr	-2048(ra) # 80000c62 <acquire>
    havekids = 0;
    8000246a:	4b01                	li	s6,0
        if(np->state == ZOMBIE){
    8000246c:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    8000246e:	00015997          	auipc	s3,0x15
    80002472:	2fa98993          	addi	s3,s3,762 # 80017768 <tickslock>
        havekids = 1;
    80002476:	4a85                	li	s5,1
    havekids = 0;
    80002478:	875a                	mv	a4,s6
    for(np = proc; np < &proc[NPROC]; np++){
    8000247a:	00010497          	auipc	s1,0x10
    8000247e:	8ee48493          	addi	s1,s1,-1810 # 80011d68 <proc>
    80002482:	a08d                	j	800024e4 <wait+0xa8>
          pid = np->pid;
    80002484:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002488:	000b8e63          	beqz	s7,800024a4 <wait+0x68>
    8000248c:	4691                	li	a3,4
    8000248e:	03448613          	addi	a2,s1,52
    80002492:	85de                	mv	a1,s7
    80002494:	05093503          	ld	a0,80(s2)
    80002498:	fffff097          	auipc	ra,0xfffff
    8000249c:	30e080e7          	jalr	782(ra) # 800017a6 <copyout>
    800024a0:	02054263          	bltz	a0,800024c4 <wait+0x88>
          freeproc(np);
    800024a4:	8526                	mv	a0,s1
    800024a6:	00000097          	auipc	ra,0x0
    800024aa:	8b2080e7          	jalr	-1870(ra) # 80001d58 <freeproc>
          release(&np->lock);
    800024ae:	8526                	mv	a0,s1
    800024b0:	fffff097          	auipc	ra,0xfffff
    800024b4:	866080e7          	jalr	-1946(ra) # 80000d16 <release>
          release(&p->lock);
    800024b8:	854a                	mv	a0,s2
    800024ba:	fffff097          	auipc	ra,0xfffff
    800024be:	85c080e7          	jalr	-1956(ra) # 80000d16 <release>
          return pid;
    800024c2:	a8a9                	j	8000251c <wait+0xe0>
            release(&np->lock);
    800024c4:	8526                	mv	a0,s1
    800024c6:	fffff097          	auipc	ra,0xfffff
    800024ca:	850080e7          	jalr	-1968(ra) # 80000d16 <release>
            release(&p->lock);
    800024ce:	854a                	mv	a0,s2
    800024d0:	fffff097          	auipc	ra,0xfffff
    800024d4:	846080e7          	jalr	-1978(ra) # 80000d16 <release>
            return -1;
    800024d8:	59fd                	li	s3,-1
    800024da:	a089                	j	8000251c <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    800024dc:	16848493          	addi	s1,s1,360
    800024e0:	03348463          	beq	s1,s3,80002508 <wait+0xcc>
      if(np->parent == p){
    800024e4:	709c                	ld	a5,32(s1)
    800024e6:	ff279be3          	bne	a5,s2,800024dc <wait+0xa0>
        acquire(&np->lock);
    800024ea:	8526                	mv	a0,s1
    800024ec:	ffffe097          	auipc	ra,0xffffe
    800024f0:	776080e7          	jalr	1910(ra) # 80000c62 <acquire>
        if(np->state == ZOMBIE){
    800024f4:	4c9c                	lw	a5,24(s1)
    800024f6:	f94787e3          	beq	a5,s4,80002484 <wait+0x48>
        release(&np->lock);
    800024fa:	8526                	mv	a0,s1
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	81a080e7          	jalr	-2022(ra) # 80000d16 <release>
        havekids = 1;
    80002504:	8756                	mv	a4,s5
    80002506:	bfd9                	j	800024dc <wait+0xa0>
    if(!havekids || p->killed){
    80002508:	c701                	beqz	a4,80002510 <wait+0xd4>
    8000250a:	03092783          	lw	a5,48(s2)
    8000250e:	c785                	beqz	a5,80002536 <wait+0xfa>
      release(&p->lock);
    80002510:	854a                	mv	a0,s2
    80002512:	fffff097          	auipc	ra,0xfffff
    80002516:	804080e7          	jalr	-2044(ra) # 80000d16 <release>
      return -1;
    8000251a:	59fd                	li	s3,-1
}
    8000251c:	854e                	mv	a0,s3
    8000251e:	60a6                	ld	ra,72(sp)
    80002520:	6406                	ld	s0,64(sp)
    80002522:	74e2                	ld	s1,56(sp)
    80002524:	7942                	ld	s2,48(sp)
    80002526:	79a2                	ld	s3,40(sp)
    80002528:	7a02                	ld	s4,32(sp)
    8000252a:	6ae2                	ld	s5,24(sp)
    8000252c:	6b42                	ld	s6,16(sp)
    8000252e:	6ba2                	ld	s7,8(sp)
    80002530:	6c02                	ld	s8,0(sp)
    80002532:	6161                	addi	sp,sp,80
    80002534:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002536:	85e2                	mv	a1,s8
    80002538:	854a                	mv	a0,s2
    8000253a:	00000097          	auipc	ra,0x0
    8000253e:	e84080e7          	jalr	-380(ra) # 800023be <sleep>
    havekids = 0;
    80002542:	bf1d                	j	80002478 <wait+0x3c>

0000000080002544 <wakeup>:
{
    80002544:	7139                	addi	sp,sp,-64
    80002546:	fc06                	sd	ra,56(sp)
    80002548:	f822                	sd	s0,48(sp)
    8000254a:	f426                	sd	s1,40(sp)
    8000254c:	f04a                	sd	s2,32(sp)
    8000254e:	ec4e                	sd	s3,24(sp)
    80002550:	e852                	sd	s4,16(sp)
    80002552:	e456                	sd	s5,8(sp)
    80002554:	0080                	addi	s0,sp,64
    80002556:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002558:	00010497          	auipc	s1,0x10
    8000255c:	81048493          	addi	s1,s1,-2032 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002560:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002562:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002564:	00015917          	auipc	s2,0x15
    80002568:	20490913          	addi	s2,s2,516 # 80017768 <tickslock>
    8000256c:	a821                	j	80002584 <wakeup+0x40>
      p->state = RUNNABLE;
    8000256e:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    80002572:	8526                	mv	a0,s1
    80002574:	ffffe097          	auipc	ra,0xffffe
    80002578:	7a2080e7          	jalr	1954(ra) # 80000d16 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000257c:	16848493          	addi	s1,s1,360
    80002580:	01248e63          	beq	s1,s2,8000259c <wakeup+0x58>
    acquire(&p->lock);
    80002584:	8526                	mv	a0,s1
    80002586:	ffffe097          	auipc	ra,0xffffe
    8000258a:	6dc080e7          	jalr	1756(ra) # 80000c62 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000258e:	4c9c                	lw	a5,24(s1)
    80002590:	ff3791e3          	bne	a5,s3,80002572 <wakeup+0x2e>
    80002594:	749c                	ld	a5,40(s1)
    80002596:	fd479ee3          	bne	a5,s4,80002572 <wakeup+0x2e>
    8000259a:	bfd1                	j	8000256e <wakeup+0x2a>
}
    8000259c:	70e2                	ld	ra,56(sp)
    8000259e:	7442                	ld	s0,48(sp)
    800025a0:	74a2                	ld	s1,40(sp)
    800025a2:	7902                	ld	s2,32(sp)
    800025a4:	69e2                	ld	s3,24(sp)
    800025a6:	6a42                	ld	s4,16(sp)
    800025a8:	6aa2                	ld	s5,8(sp)
    800025aa:	6121                	addi	sp,sp,64
    800025ac:	8082                	ret

00000000800025ae <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800025ae:	7179                	addi	sp,sp,-48
    800025b0:	f406                	sd	ra,40(sp)
    800025b2:	f022                	sd	s0,32(sp)
    800025b4:	ec26                	sd	s1,24(sp)
    800025b6:	e84a                	sd	s2,16(sp)
    800025b8:	e44e                	sd	s3,8(sp)
    800025ba:	1800                	addi	s0,sp,48
    800025bc:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800025be:	0000f497          	auipc	s1,0xf
    800025c2:	7aa48493          	addi	s1,s1,1962 # 80011d68 <proc>
    800025c6:	00015997          	auipc	s3,0x15
    800025ca:	1a298993          	addi	s3,s3,418 # 80017768 <tickslock>
    acquire(&p->lock);
    800025ce:	8526                	mv	a0,s1
    800025d0:	ffffe097          	auipc	ra,0xffffe
    800025d4:	692080e7          	jalr	1682(ra) # 80000c62 <acquire>
    if(p->pid == pid){
    800025d8:	5c9c                	lw	a5,56(s1)
    800025da:	01278d63          	beq	a5,s2,800025f4 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800025de:	8526                	mv	a0,s1
    800025e0:	ffffe097          	auipc	ra,0xffffe
    800025e4:	736080e7          	jalr	1846(ra) # 80000d16 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800025e8:	16848493          	addi	s1,s1,360
    800025ec:	ff3491e3          	bne	s1,s3,800025ce <kill+0x20>
  }
  return -1;
    800025f0:	557d                	li	a0,-1
    800025f2:	a829                	j	8000260c <kill+0x5e>
      p->killed = 1;
    800025f4:	4785                	li	a5,1
    800025f6:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800025f8:	4c98                	lw	a4,24(s1)
    800025fa:	4785                	li	a5,1
    800025fc:	00f70f63          	beq	a4,a5,8000261a <kill+0x6c>
      release(&p->lock);
    80002600:	8526                	mv	a0,s1
    80002602:	ffffe097          	auipc	ra,0xffffe
    80002606:	714080e7          	jalr	1812(ra) # 80000d16 <release>
      return 0;
    8000260a:	4501                	li	a0,0
}
    8000260c:	70a2                	ld	ra,40(sp)
    8000260e:	7402                	ld	s0,32(sp)
    80002610:	64e2                	ld	s1,24(sp)
    80002612:	6942                	ld	s2,16(sp)
    80002614:	69a2                	ld	s3,8(sp)
    80002616:	6145                	addi	sp,sp,48
    80002618:	8082                	ret
        p->state = RUNNABLE;
    8000261a:	4789                	li	a5,2
    8000261c:	cc9c                	sw	a5,24(s1)
    8000261e:	b7cd                	j	80002600 <kill+0x52>

0000000080002620 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002620:	7179                	addi	sp,sp,-48
    80002622:	f406                	sd	ra,40(sp)
    80002624:	f022                	sd	s0,32(sp)
    80002626:	ec26                	sd	s1,24(sp)
    80002628:	e84a                	sd	s2,16(sp)
    8000262a:	e44e                	sd	s3,8(sp)
    8000262c:	e052                	sd	s4,0(sp)
    8000262e:	1800                	addi	s0,sp,48
    80002630:	84aa                	mv	s1,a0
    80002632:	892e                	mv	s2,a1
    80002634:	89b2                	mv	s3,a2
    80002636:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002638:	fffff097          	auipc	ra,0xfffff
    8000263c:	56c080e7          	jalr	1388(ra) # 80001ba4 <myproc>
  if(user_dst){
    80002640:	c08d                	beqz	s1,80002662 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002642:	86d2                	mv	a3,s4
    80002644:	864e                	mv	a2,s3
    80002646:	85ca                	mv	a1,s2
    80002648:	6928                	ld	a0,80(a0)
    8000264a:	fffff097          	auipc	ra,0xfffff
    8000264e:	15c080e7          	jalr	348(ra) # 800017a6 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002652:	70a2                	ld	ra,40(sp)
    80002654:	7402                	ld	s0,32(sp)
    80002656:	64e2                	ld	s1,24(sp)
    80002658:	6942                	ld	s2,16(sp)
    8000265a:	69a2                	ld	s3,8(sp)
    8000265c:	6a02                	ld	s4,0(sp)
    8000265e:	6145                	addi	sp,sp,48
    80002660:	8082                	ret
    memmove((char *)dst, src, len);
    80002662:	000a061b          	sext.w	a2,s4
    80002666:	85ce                	mv	a1,s3
    80002668:	854a                	mv	a0,s2
    8000266a:	ffffe097          	auipc	ra,0xffffe
    8000266e:	760080e7          	jalr	1888(ra) # 80000dca <memmove>
    return 0;
    80002672:	8526                	mv	a0,s1
    80002674:	bff9                	j	80002652 <either_copyout+0x32>

0000000080002676 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002676:	7179                	addi	sp,sp,-48
    80002678:	f406                	sd	ra,40(sp)
    8000267a:	f022                	sd	s0,32(sp)
    8000267c:	ec26                	sd	s1,24(sp)
    8000267e:	e84a                	sd	s2,16(sp)
    80002680:	e44e                	sd	s3,8(sp)
    80002682:	e052                	sd	s4,0(sp)
    80002684:	1800                	addi	s0,sp,48
    80002686:	892a                	mv	s2,a0
    80002688:	84ae                	mv	s1,a1
    8000268a:	89b2                	mv	s3,a2
    8000268c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000268e:	fffff097          	auipc	ra,0xfffff
    80002692:	516080e7          	jalr	1302(ra) # 80001ba4 <myproc>
  if(user_src){
    80002696:	c08d                	beqz	s1,800026b8 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002698:	86d2                	mv	a3,s4
    8000269a:	864e                	mv	a2,s3
    8000269c:	85ca                	mv	a1,s2
    8000269e:	6928                	ld	a0,80(a0)
    800026a0:	fffff097          	auipc	ra,0xfffff
    800026a4:	192080e7          	jalr	402(ra) # 80001832 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800026a8:	70a2                	ld	ra,40(sp)
    800026aa:	7402                	ld	s0,32(sp)
    800026ac:	64e2                	ld	s1,24(sp)
    800026ae:	6942                	ld	s2,16(sp)
    800026b0:	69a2                	ld	s3,8(sp)
    800026b2:	6a02                	ld	s4,0(sp)
    800026b4:	6145                	addi	sp,sp,48
    800026b6:	8082                	ret
    memmove(dst, (char*)src, len);
    800026b8:	000a061b          	sext.w	a2,s4
    800026bc:	85ce                	mv	a1,s3
    800026be:	854a                	mv	a0,s2
    800026c0:	ffffe097          	auipc	ra,0xffffe
    800026c4:	70a080e7          	jalr	1802(ra) # 80000dca <memmove>
    return 0;
    800026c8:	8526                	mv	a0,s1
    800026ca:	bff9                	j	800026a8 <either_copyin+0x32>

00000000800026cc <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800026cc:	715d                	addi	sp,sp,-80
    800026ce:	e486                	sd	ra,72(sp)
    800026d0:	e0a2                	sd	s0,64(sp)
    800026d2:	fc26                	sd	s1,56(sp)
    800026d4:	f84a                	sd	s2,48(sp)
    800026d6:	f44e                	sd	s3,40(sp)
    800026d8:	f052                	sd	s4,32(sp)
    800026da:	ec56                	sd	s5,24(sp)
    800026dc:	e85a                	sd	s6,16(sp)
    800026de:	e45e                	sd	s7,8(sp)
    800026e0:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800026e2:	00006517          	auipc	a0,0x6
    800026e6:	9e650513          	addi	a0,a0,-1562 # 800080c8 <digits+0xb0>
    800026ea:	ffffe097          	auipc	ra,0xffffe
    800026ee:	ed4080e7          	jalr	-300(ra) # 800005be <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026f2:	0000f497          	auipc	s1,0xf
    800026f6:	7ce48493          	addi	s1,s1,1998 # 80011ec0 <proc+0x158>
    800026fa:	00015917          	auipc	s2,0x15
    800026fe:	1c690913          	addi	s2,s2,454 # 800178c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002702:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002704:	00006997          	auipc	s3,0x6
    80002708:	b5c98993          	addi	s3,s3,-1188 # 80008260 <states.1726+0xc8>
    printf("%d %s %s", p->pid, state, p->name);
    8000270c:	00006a97          	auipc	s5,0x6
    80002710:	b5ca8a93          	addi	s5,s5,-1188 # 80008268 <states.1726+0xd0>
    printf("\n");
    80002714:	00006a17          	auipc	s4,0x6
    80002718:	9b4a0a13          	addi	s4,s4,-1612 # 800080c8 <digits+0xb0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000271c:	00006b97          	auipc	s7,0x6
    80002720:	a7cb8b93          	addi	s7,s7,-1412 # 80008198 <states.1726>
    80002724:	a015                	j	80002748 <procdump+0x7c>
    printf("%d %s %s", p->pid, state, p->name);
    80002726:	86ba                	mv	a3,a4
    80002728:	ee072583          	lw	a1,-288(a4)
    8000272c:	8556                	mv	a0,s5
    8000272e:	ffffe097          	auipc	ra,0xffffe
    80002732:	e90080e7          	jalr	-368(ra) # 800005be <printf>
    printf("\n");
    80002736:	8552                	mv	a0,s4
    80002738:	ffffe097          	auipc	ra,0xffffe
    8000273c:	e86080e7          	jalr	-378(ra) # 800005be <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002740:	16848493          	addi	s1,s1,360
    80002744:	03248163          	beq	s1,s2,80002766 <procdump+0x9a>
    if(p->state == UNUSED)
    80002748:	8726                	mv	a4,s1
    8000274a:	ec04a783          	lw	a5,-320(s1)
    8000274e:	dbed                	beqz	a5,80002740 <procdump+0x74>
      state = "???";
    80002750:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002752:	fcfb6ae3          	bltu	s6,a5,80002726 <procdump+0x5a>
    80002756:	1782                	slli	a5,a5,0x20
    80002758:	9381                	srli	a5,a5,0x20
    8000275a:	078e                	slli	a5,a5,0x3
    8000275c:	97de                	add	a5,a5,s7
    8000275e:	6390                	ld	a2,0(a5)
    80002760:	f279                	bnez	a2,80002726 <procdump+0x5a>
      state = "???";
    80002762:	864e                	mv	a2,s3
    80002764:	b7c9                	j	80002726 <procdump+0x5a>
  }
}
    80002766:	60a6                	ld	ra,72(sp)
    80002768:	6406                	ld	s0,64(sp)
    8000276a:	74e2                	ld	s1,56(sp)
    8000276c:	7942                	ld	s2,48(sp)
    8000276e:	79a2                	ld	s3,40(sp)
    80002770:	7a02                	ld	s4,32(sp)
    80002772:	6ae2                	ld	s5,24(sp)
    80002774:	6b42                	ld	s6,16(sp)
    80002776:	6ba2                	ld	s7,8(sp)
    80002778:	6161                	addi	sp,sp,80
    8000277a:	8082                	ret

000000008000277c <swtch>:
    8000277c:	00153023          	sd	ra,0(a0)
    80002780:	00253423          	sd	sp,8(a0)
    80002784:	e900                	sd	s0,16(a0)
    80002786:	ed04                	sd	s1,24(a0)
    80002788:	03253023          	sd	s2,32(a0)
    8000278c:	03353423          	sd	s3,40(a0)
    80002790:	03453823          	sd	s4,48(a0)
    80002794:	03553c23          	sd	s5,56(a0)
    80002798:	05653023          	sd	s6,64(a0)
    8000279c:	05753423          	sd	s7,72(a0)
    800027a0:	05853823          	sd	s8,80(a0)
    800027a4:	05953c23          	sd	s9,88(a0)
    800027a8:	07a53023          	sd	s10,96(a0)
    800027ac:	07b53423          	sd	s11,104(a0)
    800027b0:	0005b083          	ld	ra,0(a1)
    800027b4:	0085b103          	ld	sp,8(a1)
    800027b8:	6980                	ld	s0,16(a1)
    800027ba:	6d84                	ld	s1,24(a1)
    800027bc:	0205b903          	ld	s2,32(a1)
    800027c0:	0285b983          	ld	s3,40(a1)
    800027c4:	0305ba03          	ld	s4,48(a1)
    800027c8:	0385ba83          	ld	s5,56(a1)
    800027cc:	0405bb03          	ld	s6,64(a1)
    800027d0:	0485bb83          	ld	s7,72(a1)
    800027d4:	0505bc03          	ld	s8,80(a1)
    800027d8:	0585bc83          	ld	s9,88(a1)
    800027dc:	0605bd03          	ld	s10,96(a1)
    800027e0:	0685bd83          	ld	s11,104(a1)
    800027e4:	8082                	ret

00000000800027e6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800027e6:	1141                	addi	sp,sp,-16
    800027e8:	e406                	sd	ra,8(sp)
    800027ea:	e022                	sd	s0,0(sp)
    800027ec:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800027ee:	00006597          	auipc	a1,0x6
    800027f2:	ab258593          	addi	a1,a1,-1358 # 800082a0 <states.1726+0x108>
    800027f6:	00015517          	auipc	a0,0x15
    800027fa:	f7250513          	addi	a0,a0,-142 # 80017768 <tickslock>
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	3d4080e7          	jalr	980(ra) # 80000bd2 <initlock>
}
    80002806:	60a2                	ld	ra,8(sp)
    80002808:	6402                	ld	s0,0(sp)
    8000280a:	0141                	addi	sp,sp,16
    8000280c:	8082                	ret

000000008000280e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000280e:	1141                	addi	sp,sp,-16
    80002810:	e422                	sd	s0,8(sp)
    80002812:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002814:	00003797          	auipc	a5,0x3
    80002818:	5fc78793          	addi	a5,a5,1532 # 80005e10 <kernelvec>
    8000281c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002820:	6422                	ld	s0,8(sp)
    80002822:	0141                	addi	sp,sp,16
    80002824:	8082                	ret

0000000080002826 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002826:	1141                	addi	sp,sp,-16
    80002828:	e406                	sd	ra,8(sp)
    8000282a:	e022                	sd	s0,0(sp)
    8000282c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000282e:	fffff097          	auipc	ra,0xfffff
    80002832:	376080e7          	jalr	886(ra) # 80001ba4 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002836:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000283a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000283c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002840:	00004617          	auipc	a2,0x4
    80002844:	7c060613          	addi	a2,a2,1984 # 80007000 <_trampoline>
    80002848:	00004697          	auipc	a3,0x4
    8000284c:	7b868693          	addi	a3,a3,1976 # 80007000 <_trampoline>
    80002850:	8e91                	sub	a3,a3,a2
    80002852:	040007b7          	lui	a5,0x4000
    80002856:	17fd                	addi	a5,a5,-1
    80002858:	07b2                	slli	a5,a5,0xc
    8000285a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000285c:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002860:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002862:	180026f3          	csrr	a3,satp
    80002866:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002868:	6d38                	ld	a4,88(a0)
    8000286a:	6134                	ld	a3,64(a0)
    8000286c:	6585                	lui	a1,0x1
    8000286e:	96ae                	add	a3,a3,a1
    80002870:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002872:	6d38                	ld	a4,88(a0)
    80002874:	00000697          	auipc	a3,0x0
    80002878:	13868693          	addi	a3,a3,312 # 800029ac <usertrap>
    8000287c:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000287e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002880:	8692                	mv	a3,tp
    80002882:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002884:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002888:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000288c:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002890:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002894:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002896:	6f18                	ld	a4,24(a4)
    80002898:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000289c:	692c                	ld	a1,80(a0)
    8000289e:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800028a0:	00004717          	auipc	a4,0x4
    800028a4:	7f070713          	addi	a4,a4,2032 # 80007090 <userret>
    800028a8:	8f11                	sub	a4,a4,a2
    800028aa:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800028ac:	577d                	li	a4,-1
    800028ae:	177e                	slli	a4,a4,0x3f
    800028b0:	8dd9                	or	a1,a1,a4
    800028b2:	02000537          	lui	a0,0x2000
    800028b6:	157d                	addi	a0,a0,-1
    800028b8:	0536                	slli	a0,a0,0xd
    800028ba:	9782                	jalr	a5
}
    800028bc:	60a2                	ld	ra,8(sp)
    800028be:	6402                	ld	s0,0(sp)
    800028c0:	0141                	addi	sp,sp,16
    800028c2:	8082                	ret

00000000800028c4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800028c4:	1101                	addi	sp,sp,-32
    800028c6:	ec06                	sd	ra,24(sp)
    800028c8:	e822                	sd	s0,16(sp)
    800028ca:	e426                	sd	s1,8(sp)
    800028cc:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800028ce:	00015497          	auipc	s1,0x15
    800028d2:	e9a48493          	addi	s1,s1,-358 # 80017768 <tickslock>
    800028d6:	8526                	mv	a0,s1
    800028d8:	ffffe097          	auipc	ra,0xffffe
    800028dc:	38a080e7          	jalr	906(ra) # 80000c62 <acquire>
  ticks++;
    800028e0:	00006517          	auipc	a0,0x6
    800028e4:	74050513          	addi	a0,a0,1856 # 80009020 <ticks>
    800028e8:	411c                	lw	a5,0(a0)
    800028ea:	2785                	addiw	a5,a5,1
    800028ec:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800028ee:	00000097          	auipc	ra,0x0
    800028f2:	c56080e7          	jalr	-938(ra) # 80002544 <wakeup>
  release(&tickslock);
    800028f6:	8526                	mv	a0,s1
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	41e080e7          	jalr	1054(ra) # 80000d16 <release>
}
    80002900:	60e2                	ld	ra,24(sp)
    80002902:	6442                	ld	s0,16(sp)
    80002904:	64a2                	ld	s1,8(sp)
    80002906:	6105                	addi	sp,sp,32
    80002908:	8082                	ret

000000008000290a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000290a:	1101                	addi	sp,sp,-32
    8000290c:	ec06                	sd	ra,24(sp)
    8000290e:	e822                	sd	s0,16(sp)
    80002910:	e426                	sd	s1,8(sp)
    80002912:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002914:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002918:	00074d63          	bltz	a4,80002932 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000291c:	57fd                	li	a5,-1
    8000291e:	17fe                	slli	a5,a5,0x3f
    80002920:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002922:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002924:	06f70363          	beq	a4,a5,8000298a <devintr+0x80>
  }
}
    80002928:	60e2                	ld	ra,24(sp)
    8000292a:	6442                	ld	s0,16(sp)
    8000292c:	64a2                	ld	s1,8(sp)
    8000292e:	6105                	addi	sp,sp,32
    80002930:	8082                	ret
     (scause & 0xff) == 9){
    80002932:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002936:	46a5                	li	a3,9
    80002938:	fed792e3          	bne	a5,a3,8000291c <devintr+0x12>
    int irq = plic_claim();
    8000293c:	00003097          	auipc	ra,0x3
    80002940:	5dc080e7          	jalr	1500(ra) # 80005f18 <plic_claim>
    80002944:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002946:	47a9                	li	a5,10
    80002948:	02f50763          	beq	a0,a5,80002976 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000294c:	4785                	li	a5,1
    8000294e:	02f50963          	beq	a0,a5,80002980 <devintr+0x76>
    return 1;
    80002952:	4505                	li	a0,1
    } else if(irq){
    80002954:	d8f1                	beqz	s1,80002928 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002956:	85a6                	mv	a1,s1
    80002958:	00006517          	auipc	a0,0x6
    8000295c:	95050513          	addi	a0,a0,-1712 # 800082a8 <states.1726+0x110>
    80002960:	ffffe097          	auipc	ra,0xffffe
    80002964:	c5e080e7          	jalr	-930(ra) # 800005be <printf>
      plic_complete(irq);
    80002968:	8526                	mv	a0,s1
    8000296a:	00003097          	auipc	ra,0x3
    8000296e:	5d2080e7          	jalr	1490(ra) # 80005f3c <plic_complete>
    return 1;
    80002972:	4505                	li	a0,1
    80002974:	bf55                	j	80002928 <devintr+0x1e>
      uartintr();
    80002976:	ffffe097          	auipc	ra,0xffffe
    8000297a:	0ac080e7          	jalr	172(ra) # 80000a22 <uartintr>
    8000297e:	b7ed                	j	80002968 <devintr+0x5e>
      virtio_disk_intr();
    80002980:	00004097          	auipc	ra,0x4
    80002984:	a68080e7          	jalr	-1432(ra) # 800063e8 <virtio_disk_intr>
    80002988:	b7c5                	j	80002968 <devintr+0x5e>
    if(cpuid() == 0){
    8000298a:	fffff097          	auipc	ra,0xfffff
    8000298e:	1ee080e7          	jalr	494(ra) # 80001b78 <cpuid>
    80002992:	c901                	beqz	a0,800029a2 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002994:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002998:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000299a:	14479073          	csrw	sip,a5
    return 2;
    8000299e:	4509                	li	a0,2
    800029a0:	b761                	j	80002928 <devintr+0x1e>
      clockintr();
    800029a2:	00000097          	auipc	ra,0x0
    800029a6:	f22080e7          	jalr	-222(ra) # 800028c4 <clockintr>
    800029aa:	b7ed                	j	80002994 <devintr+0x8a>

00000000800029ac <usertrap>:
{
    800029ac:	1101                	addi	sp,sp,-32
    800029ae:	ec06                	sd	ra,24(sp)
    800029b0:	e822                	sd	s0,16(sp)
    800029b2:	e426                	sd	s1,8(sp)
    800029b4:	e04a                	sd	s2,0(sp)
    800029b6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029b8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800029bc:	1007f793          	andi	a5,a5,256
    800029c0:	e3ad                	bnez	a5,80002a22 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029c2:	00003797          	auipc	a5,0x3
    800029c6:	44e78793          	addi	a5,a5,1102 # 80005e10 <kernelvec>
    800029ca:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800029ce:	fffff097          	auipc	ra,0xfffff
    800029d2:	1d6080e7          	jalr	470(ra) # 80001ba4 <myproc>
    800029d6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800029d8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029da:	14102773          	csrr	a4,sepc
    800029de:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029e0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800029e4:	47a1                	li	a5,8
    800029e6:	04f71c63          	bne	a4,a5,80002a3e <usertrap+0x92>
    if(p->killed)
    800029ea:	591c                	lw	a5,48(a0)
    800029ec:	e3b9                	bnez	a5,80002a32 <usertrap+0x86>
    p->trapframe->epc += 4;
    800029ee:	6cb8                	ld	a4,88(s1)
    800029f0:	6f1c                	ld	a5,24(a4)
    800029f2:	0791                	addi	a5,a5,4
    800029f4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029f6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800029fa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029fe:	10079073          	csrw	sstatus,a5
    syscall();
    80002a02:	00000097          	auipc	ra,0x0
    80002a06:	310080e7          	jalr	784(ra) # 80002d12 <syscall>
  if(p->killed)
    80002a0a:	589c                	lw	a5,48(s1)
    80002a0c:	e3cd                	bnez	a5,80002aae <usertrap+0x102>
  usertrapret();
    80002a0e:	00000097          	auipc	ra,0x0
    80002a12:	e18080e7          	jalr	-488(ra) # 80002826 <usertrapret>
}
    80002a16:	60e2                	ld	ra,24(sp)
    80002a18:	6442                	ld	s0,16(sp)
    80002a1a:	64a2                	ld	s1,8(sp)
    80002a1c:	6902                	ld	s2,0(sp)
    80002a1e:	6105                	addi	sp,sp,32
    80002a20:	8082                	ret
    panic("usertrap: not from user mode");
    80002a22:	00006517          	auipc	a0,0x6
    80002a26:	8a650513          	addi	a0,a0,-1882 # 800082c8 <states.1726+0x130>
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	b4a080e7          	jalr	-1206(ra) # 80000574 <panic>
      exit(-1);
    80002a32:	557d                	li	a0,-1
    80002a34:	00000097          	auipc	ra,0x0
    80002a38:	842080e7          	jalr	-1982(ra) # 80002276 <exit>
    80002a3c:	bf4d                	j	800029ee <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002a3e:	00000097          	auipc	ra,0x0
    80002a42:	ecc080e7          	jalr	-308(ra) # 8000290a <devintr>
    80002a46:	892a                	mv	s2,a0
    80002a48:	e125                	bnez	a0,80002aa8 <usertrap+0xfc>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a4a:	14202773          	csrr	a4,scause
  } else if (r_scause() == 13 || r_scause() == 15) {
    80002a4e:	47b5                	li	a5,13
    80002a50:	00f70763          	beq	a4,a5,80002a5e <usertrap+0xb2>
    80002a54:	14202773          	csrr	a4,scause
    80002a58:	47bd                	li	a5,15
    80002a5a:	00f71d63          	bne	a4,a5,80002a74 <usertrap+0xc8>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a5e:	14302573          	csrr	a0,stval
    if (lazy_alloc(addr) < 0) {
    80002a62:	fffff097          	auipc	ra,0xfffff
    80002a66:	c5a080e7          	jalr	-934(ra) # 800016bc <lazy_alloc>
    80002a6a:	fa0550e3          	bgez	a0,80002a0a <usertrap+0x5e>
      p->killed = 1;
    80002a6e:	4785                	li	a5,1
    80002a70:	d89c                	sw	a5,48(s1)
    80002a72:	a83d                	j	80002ab0 <usertrap+0x104>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a74:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002a78:	5c90                	lw	a2,56(s1)
    80002a7a:	00006517          	auipc	a0,0x6
    80002a7e:	86e50513          	addi	a0,a0,-1938 # 800082e8 <states.1726+0x150>
    80002a82:	ffffe097          	auipc	ra,0xffffe
    80002a86:	b3c080e7          	jalr	-1220(ra) # 800005be <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a8a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a8e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a92:	00006517          	auipc	a0,0x6
    80002a96:	88650513          	addi	a0,a0,-1914 # 80008318 <states.1726+0x180>
    80002a9a:	ffffe097          	auipc	ra,0xffffe
    80002a9e:	b24080e7          	jalr	-1244(ra) # 800005be <printf>
    p->killed = 1;
    80002aa2:	4785                	li	a5,1
    80002aa4:	d89c                	sw	a5,48(s1)
    80002aa6:	a029                	j	80002ab0 <usertrap+0x104>
  if(p->killed)
    80002aa8:	589c                	lw	a5,48(s1)
    80002aaa:	cb81                	beqz	a5,80002aba <usertrap+0x10e>
    80002aac:	a011                	j	80002ab0 <usertrap+0x104>
    80002aae:	4901                	li	s2,0
    exit(-1);
    80002ab0:	557d                	li	a0,-1
    80002ab2:	fffff097          	auipc	ra,0xfffff
    80002ab6:	7c4080e7          	jalr	1988(ra) # 80002276 <exit>
  if(which_dev == 2)
    80002aba:	4789                	li	a5,2
    80002abc:	f4f919e3          	bne	s2,a5,80002a0e <usertrap+0x62>
    yield();
    80002ac0:	00000097          	auipc	ra,0x0
    80002ac4:	8c2080e7          	jalr	-1854(ra) # 80002382 <yield>
    80002ac8:	b799                	j	80002a0e <usertrap+0x62>

0000000080002aca <kerneltrap>:
{
    80002aca:	7179                	addi	sp,sp,-48
    80002acc:	f406                	sd	ra,40(sp)
    80002ace:	f022                	sd	s0,32(sp)
    80002ad0:	ec26                	sd	s1,24(sp)
    80002ad2:	e84a                	sd	s2,16(sp)
    80002ad4:	e44e                	sd	s3,8(sp)
    80002ad6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ad8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002adc:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ae0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002ae4:	1004f793          	andi	a5,s1,256
    80002ae8:	cb85                	beqz	a5,80002b18 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aea:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002aee:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002af0:	ef85                	bnez	a5,80002b28 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002af2:	00000097          	auipc	ra,0x0
    80002af6:	e18080e7          	jalr	-488(ra) # 8000290a <devintr>
    80002afa:	cd1d                	beqz	a0,80002b38 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002afc:	4789                	li	a5,2
    80002afe:	06f50a63          	beq	a0,a5,80002b72 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b02:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b06:	10049073          	csrw	sstatus,s1
}
    80002b0a:	70a2                	ld	ra,40(sp)
    80002b0c:	7402                	ld	s0,32(sp)
    80002b0e:	64e2                	ld	s1,24(sp)
    80002b10:	6942                	ld	s2,16(sp)
    80002b12:	69a2                	ld	s3,8(sp)
    80002b14:	6145                	addi	sp,sp,48
    80002b16:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b18:	00006517          	auipc	a0,0x6
    80002b1c:	82050513          	addi	a0,a0,-2016 # 80008338 <states.1726+0x1a0>
    80002b20:	ffffe097          	auipc	ra,0xffffe
    80002b24:	a54080e7          	jalr	-1452(ra) # 80000574 <panic>
    panic("kerneltrap: interrupts enabled");
    80002b28:	00006517          	auipc	a0,0x6
    80002b2c:	83850513          	addi	a0,a0,-1992 # 80008360 <states.1726+0x1c8>
    80002b30:	ffffe097          	auipc	ra,0xffffe
    80002b34:	a44080e7          	jalr	-1468(ra) # 80000574 <panic>
    printf("scause %p\n", scause);
    80002b38:	85ce                	mv	a1,s3
    80002b3a:	00006517          	auipc	a0,0x6
    80002b3e:	84650513          	addi	a0,a0,-1978 # 80008380 <states.1726+0x1e8>
    80002b42:	ffffe097          	auipc	ra,0xffffe
    80002b46:	a7c080e7          	jalr	-1412(ra) # 800005be <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b4a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b4e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b52:	00006517          	auipc	a0,0x6
    80002b56:	83e50513          	addi	a0,a0,-1986 # 80008390 <states.1726+0x1f8>
    80002b5a:	ffffe097          	auipc	ra,0xffffe
    80002b5e:	a64080e7          	jalr	-1436(ra) # 800005be <printf>
    panic("kerneltrap");
    80002b62:	00006517          	auipc	a0,0x6
    80002b66:	84650513          	addi	a0,a0,-1978 # 800083a8 <states.1726+0x210>
    80002b6a:	ffffe097          	auipc	ra,0xffffe
    80002b6e:	a0a080e7          	jalr	-1526(ra) # 80000574 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b72:	fffff097          	auipc	ra,0xfffff
    80002b76:	032080e7          	jalr	50(ra) # 80001ba4 <myproc>
    80002b7a:	d541                	beqz	a0,80002b02 <kerneltrap+0x38>
    80002b7c:	fffff097          	auipc	ra,0xfffff
    80002b80:	028080e7          	jalr	40(ra) # 80001ba4 <myproc>
    80002b84:	4d18                	lw	a4,24(a0)
    80002b86:	478d                	li	a5,3
    80002b88:	f6f71de3          	bne	a4,a5,80002b02 <kerneltrap+0x38>
    yield();
    80002b8c:	fffff097          	auipc	ra,0xfffff
    80002b90:	7f6080e7          	jalr	2038(ra) # 80002382 <yield>
    80002b94:	b7bd                	j	80002b02 <kerneltrap+0x38>

0000000080002b96 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b96:	1101                	addi	sp,sp,-32
    80002b98:	ec06                	sd	ra,24(sp)
    80002b9a:	e822                	sd	s0,16(sp)
    80002b9c:	e426                	sd	s1,8(sp)
    80002b9e:	1000                	addi	s0,sp,32
    80002ba0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ba2:	fffff097          	auipc	ra,0xfffff
    80002ba6:	002080e7          	jalr	2(ra) # 80001ba4 <myproc>
  switch (n) {
    80002baa:	4795                	li	a5,5
    80002bac:	0497e363          	bltu	a5,s1,80002bf2 <argraw+0x5c>
    80002bb0:	1482                	slli	s1,s1,0x20
    80002bb2:	9081                	srli	s1,s1,0x20
    80002bb4:	048a                	slli	s1,s1,0x2
    80002bb6:	00006717          	auipc	a4,0x6
    80002bba:	80270713          	addi	a4,a4,-2046 # 800083b8 <states.1726+0x220>
    80002bbe:	94ba                	add	s1,s1,a4
    80002bc0:	409c                	lw	a5,0(s1)
    80002bc2:	97ba                	add	a5,a5,a4
    80002bc4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002bc6:	6d3c                	ld	a5,88(a0)
    80002bc8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002bca:	60e2                	ld	ra,24(sp)
    80002bcc:	6442                	ld	s0,16(sp)
    80002bce:	64a2                	ld	s1,8(sp)
    80002bd0:	6105                	addi	sp,sp,32
    80002bd2:	8082                	ret
    return p->trapframe->a1;
    80002bd4:	6d3c                	ld	a5,88(a0)
    80002bd6:	7fa8                	ld	a0,120(a5)
    80002bd8:	bfcd                	j	80002bca <argraw+0x34>
    return p->trapframe->a2;
    80002bda:	6d3c                	ld	a5,88(a0)
    80002bdc:	63c8                	ld	a0,128(a5)
    80002bde:	b7f5                	j	80002bca <argraw+0x34>
    return p->trapframe->a3;
    80002be0:	6d3c                	ld	a5,88(a0)
    80002be2:	67c8                	ld	a0,136(a5)
    80002be4:	b7dd                	j	80002bca <argraw+0x34>
    return p->trapframe->a4;
    80002be6:	6d3c                	ld	a5,88(a0)
    80002be8:	6bc8                	ld	a0,144(a5)
    80002bea:	b7c5                	j	80002bca <argraw+0x34>
    return p->trapframe->a5;
    80002bec:	6d3c                	ld	a5,88(a0)
    80002bee:	6fc8                	ld	a0,152(a5)
    80002bf0:	bfe9                	j	80002bca <argraw+0x34>
  panic("argraw");
    80002bf2:	00006517          	auipc	a0,0x6
    80002bf6:	88e50513          	addi	a0,a0,-1906 # 80008480 <syscalls+0xb0>
    80002bfa:	ffffe097          	auipc	ra,0xffffe
    80002bfe:	97a080e7          	jalr	-1670(ra) # 80000574 <panic>

0000000080002c02 <fetchaddr>:
{
    80002c02:	1101                	addi	sp,sp,-32
    80002c04:	ec06                	sd	ra,24(sp)
    80002c06:	e822                	sd	s0,16(sp)
    80002c08:	e426                	sd	s1,8(sp)
    80002c0a:	e04a                	sd	s2,0(sp)
    80002c0c:	1000                	addi	s0,sp,32
    80002c0e:	84aa                	mv	s1,a0
    80002c10:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c12:	fffff097          	auipc	ra,0xfffff
    80002c16:	f92080e7          	jalr	-110(ra) # 80001ba4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002c1a:	653c                	ld	a5,72(a0)
    80002c1c:	02f4f963          	bleu	a5,s1,80002c4e <fetchaddr+0x4c>
    80002c20:	00848713          	addi	a4,s1,8
    80002c24:	02e7e763          	bltu	a5,a4,80002c52 <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c28:	46a1                	li	a3,8
    80002c2a:	8626                	mv	a2,s1
    80002c2c:	85ca                	mv	a1,s2
    80002c2e:	6928                	ld	a0,80(a0)
    80002c30:	fffff097          	auipc	ra,0xfffff
    80002c34:	c02080e7          	jalr	-1022(ra) # 80001832 <copyin>
    80002c38:	00a03533          	snez	a0,a0
    80002c3c:	40a0053b          	negw	a0,a0
    80002c40:	2501                	sext.w	a0,a0
}
    80002c42:	60e2                	ld	ra,24(sp)
    80002c44:	6442                	ld	s0,16(sp)
    80002c46:	64a2                	ld	s1,8(sp)
    80002c48:	6902                	ld	s2,0(sp)
    80002c4a:	6105                	addi	sp,sp,32
    80002c4c:	8082                	ret
    return -1;
    80002c4e:	557d                	li	a0,-1
    80002c50:	bfcd                	j	80002c42 <fetchaddr+0x40>
    80002c52:	557d                	li	a0,-1
    80002c54:	b7fd                	j	80002c42 <fetchaddr+0x40>

0000000080002c56 <fetchstr>:
{
    80002c56:	7179                	addi	sp,sp,-48
    80002c58:	f406                	sd	ra,40(sp)
    80002c5a:	f022                	sd	s0,32(sp)
    80002c5c:	ec26                	sd	s1,24(sp)
    80002c5e:	e84a                	sd	s2,16(sp)
    80002c60:	e44e                	sd	s3,8(sp)
    80002c62:	1800                	addi	s0,sp,48
    80002c64:	892a                	mv	s2,a0
    80002c66:	84ae                	mv	s1,a1
    80002c68:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c6a:	fffff097          	auipc	ra,0xfffff
    80002c6e:	f3a080e7          	jalr	-198(ra) # 80001ba4 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002c72:	86ce                	mv	a3,s3
    80002c74:	864a                	mv	a2,s2
    80002c76:	85a6                	mv	a1,s1
    80002c78:	6928                	ld	a0,80(a0)
    80002c7a:	fffff097          	auipc	ra,0xfffff
    80002c7e:	c46080e7          	jalr	-954(ra) # 800018c0 <copyinstr>
  if(err < 0)
    80002c82:	00054763          	bltz	a0,80002c90 <fetchstr+0x3a>
  return strlen(buf);
    80002c86:	8526                	mv	a0,s1
    80002c88:	ffffe097          	auipc	ra,0xffffe
    80002c8c:	280080e7          	jalr	640(ra) # 80000f08 <strlen>
}
    80002c90:	70a2                	ld	ra,40(sp)
    80002c92:	7402                	ld	s0,32(sp)
    80002c94:	64e2                	ld	s1,24(sp)
    80002c96:	6942                	ld	s2,16(sp)
    80002c98:	69a2                	ld	s3,8(sp)
    80002c9a:	6145                	addi	sp,sp,48
    80002c9c:	8082                	ret

0000000080002c9e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002c9e:	1101                	addi	sp,sp,-32
    80002ca0:	ec06                	sd	ra,24(sp)
    80002ca2:	e822                	sd	s0,16(sp)
    80002ca4:	e426                	sd	s1,8(sp)
    80002ca6:	1000                	addi	s0,sp,32
    80002ca8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002caa:	00000097          	auipc	ra,0x0
    80002cae:	eec080e7          	jalr	-276(ra) # 80002b96 <argraw>
    80002cb2:	c088                	sw	a0,0(s1)
  return 0;
}
    80002cb4:	4501                	li	a0,0
    80002cb6:	60e2                	ld	ra,24(sp)
    80002cb8:	6442                	ld	s0,16(sp)
    80002cba:	64a2                	ld	s1,8(sp)
    80002cbc:	6105                	addi	sp,sp,32
    80002cbe:	8082                	ret

0000000080002cc0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002cc0:	1101                	addi	sp,sp,-32
    80002cc2:	ec06                	sd	ra,24(sp)
    80002cc4:	e822                	sd	s0,16(sp)
    80002cc6:	e426                	sd	s1,8(sp)
    80002cc8:	1000                	addi	s0,sp,32
    80002cca:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ccc:	00000097          	auipc	ra,0x0
    80002cd0:	eca080e7          	jalr	-310(ra) # 80002b96 <argraw>
    80002cd4:	e088                	sd	a0,0(s1)
  return 0;
}
    80002cd6:	4501                	li	a0,0
    80002cd8:	60e2                	ld	ra,24(sp)
    80002cda:	6442                	ld	s0,16(sp)
    80002cdc:	64a2                	ld	s1,8(sp)
    80002cde:	6105                	addi	sp,sp,32
    80002ce0:	8082                	ret

0000000080002ce2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ce2:	1101                	addi	sp,sp,-32
    80002ce4:	ec06                	sd	ra,24(sp)
    80002ce6:	e822                	sd	s0,16(sp)
    80002ce8:	e426                	sd	s1,8(sp)
    80002cea:	e04a                	sd	s2,0(sp)
    80002cec:	1000                	addi	s0,sp,32
    80002cee:	84ae                	mv	s1,a1
    80002cf0:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002cf2:	00000097          	auipc	ra,0x0
    80002cf6:	ea4080e7          	jalr	-348(ra) # 80002b96 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002cfa:	864a                	mv	a2,s2
    80002cfc:	85a6                	mv	a1,s1
    80002cfe:	00000097          	auipc	ra,0x0
    80002d02:	f58080e7          	jalr	-168(ra) # 80002c56 <fetchstr>
}
    80002d06:	60e2                	ld	ra,24(sp)
    80002d08:	6442                	ld	s0,16(sp)
    80002d0a:	64a2                	ld	s1,8(sp)
    80002d0c:	6902                	ld	s2,0(sp)
    80002d0e:	6105                	addi	sp,sp,32
    80002d10:	8082                	ret

0000000080002d12 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002d12:	1101                	addi	sp,sp,-32
    80002d14:	ec06                	sd	ra,24(sp)
    80002d16:	e822                	sd	s0,16(sp)
    80002d18:	e426                	sd	s1,8(sp)
    80002d1a:	e04a                	sd	s2,0(sp)
    80002d1c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d1e:	fffff097          	auipc	ra,0xfffff
    80002d22:	e86080e7          	jalr	-378(ra) # 80001ba4 <myproc>
    80002d26:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d28:	05853903          	ld	s2,88(a0)
    80002d2c:	0a893783          	ld	a5,168(s2)
    80002d30:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d34:	37fd                	addiw	a5,a5,-1
    80002d36:	4751                	li	a4,20
    80002d38:	00f76f63          	bltu	a4,a5,80002d56 <syscall+0x44>
    80002d3c:	00369713          	slli	a4,a3,0x3
    80002d40:	00005797          	auipc	a5,0x5
    80002d44:	69078793          	addi	a5,a5,1680 # 800083d0 <syscalls>
    80002d48:	97ba                	add	a5,a5,a4
    80002d4a:	639c                	ld	a5,0(a5)
    80002d4c:	c789                	beqz	a5,80002d56 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002d4e:	9782                	jalr	a5
    80002d50:	06a93823          	sd	a0,112(s2)
    80002d54:	a839                	j	80002d72 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002d56:	15848613          	addi	a2,s1,344
    80002d5a:	5c8c                	lw	a1,56(s1)
    80002d5c:	00005517          	auipc	a0,0x5
    80002d60:	72c50513          	addi	a0,a0,1836 # 80008488 <syscalls+0xb8>
    80002d64:	ffffe097          	auipc	ra,0xffffe
    80002d68:	85a080e7          	jalr	-1958(ra) # 800005be <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d6c:	6cbc                	ld	a5,88(s1)
    80002d6e:	577d                	li	a4,-1
    80002d70:	fbb8                	sd	a4,112(a5)
  }
}
    80002d72:	60e2                	ld	ra,24(sp)
    80002d74:	6442                	ld	s0,16(sp)
    80002d76:	64a2                	ld	s1,8(sp)
    80002d78:	6902                	ld	s2,0(sp)
    80002d7a:	6105                	addi	sp,sp,32
    80002d7c:	8082                	ret

0000000080002d7e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d7e:	1101                	addi	sp,sp,-32
    80002d80:	ec06                	sd	ra,24(sp)
    80002d82:	e822                	sd	s0,16(sp)
    80002d84:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002d86:	fec40593          	addi	a1,s0,-20
    80002d8a:	4501                	li	a0,0
    80002d8c:	00000097          	auipc	ra,0x0
    80002d90:	f12080e7          	jalr	-238(ra) # 80002c9e <argint>
    return -1;
    80002d94:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d96:	00054963          	bltz	a0,80002da8 <sys_exit+0x2a>
  exit(n);
    80002d9a:	fec42503          	lw	a0,-20(s0)
    80002d9e:	fffff097          	auipc	ra,0xfffff
    80002da2:	4d8080e7          	jalr	1240(ra) # 80002276 <exit>
  return 0;  // not reached
    80002da6:	4781                	li	a5,0
}
    80002da8:	853e                	mv	a0,a5
    80002daa:	60e2                	ld	ra,24(sp)
    80002dac:	6442                	ld	s0,16(sp)
    80002dae:	6105                	addi	sp,sp,32
    80002db0:	8082                	ret

0000000080002db2 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002db2:	1141                	addi	sp,sp,-16
    80002db4:	e406                	sd	ra,8(sp)
    80002db6:	e022                	sd	s0,0(sp)
    80002db8:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002dba:	fffff097          	auipc	ra,0xfffff
    80002dbe:	dea080e7          	jalr	-534(ra) # 80001ba4 <myproc>
}
    80002dc2:	5d08                	lw	a0,56(a0)
    80002dc4:	60a2                	ld	ra,8(sp)
    80002dc6:	6402                	ld	s0,0(sp)
    80002dc8:	0141                	addi	sp,sp,16
    80002dca:	8082                	ret

0000000080002dcc <sys_fork>:

uint64
sys_fork(void)
{
    80002dcc:	1141                	addi	sp,sp,-16
    80002dce:	e406                	sd	ra,8(sp)
    80002dd0:	e022                	sd	s0,0(sp)
    80002dd2:	0800                	addi	s0,sp,16
  return fork();
    80002dd4:	fffff097          	auipc	ra,0xfffff
    80002dd8:	196080e7          	jalr	406(ra) # 80001f6a <fork>
}
    80002ddc:	60a2                	ld	ra,8(sp)
    80002dde:	6402                	ld	s0,0(sp)
    80002de0:	0141                	addi	sp,sp,16
    80002de2:	8082                	ret

0000000080002de4 <sys_wait>:

uint64
sys_wait(void)
{
    80002de4:	1101                	addi	sp,sp,-32
    80002de6:	ec06                	sd	ra,24(sp)
    80002de8:	e822                	sd	s0,16(sp)
    80002dea:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002dec:	fe840593          	addi	a1,s0,-24
    80002df0:	4501                	li	a0,0
    80002df2:	00000097          	auipc	ra,0x0
    80002df6:	ece080e7          	jalr	-306(ra) # 80002cc0 <argaddr>
    return -1;
    80002dfa:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    80002dfc:	00054963          	bltz	a0,80002e0e <sys_wait+0x2a>
  return wait(p);
    80002e00:	fe843503          	ld	a0,-24(s0)
    80002e04:	fffff097          	auipc	ra,0xfffff
    80002e08:	638080e7          	jalr	1592(ra) # 8000243c <wait>
    80002e0c:	87aa                	mv	a5,a0
}
    80002e0e:	853e                	mv	a0,a5
    80002e10:	60e2                	ld	ra,24(sp)
    80002e12:	6442                	ld	s0,16(sp)
    80002e14:	6105                	addi	sp,sp,32
    80002e16:	8082                	ret

0000000080002e18 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e18:	7179                	addi	sp,sp,-48
    80002e1a:	f406                	sd	ra,40(sp)
    80002e1c:	f022                	sd	s0,32(sp)
    80002e1e:	ec26                	sd	s1,24(sp)
    80002e20:	e84a                	sd	s2,16(sp)
    80002e22:	1800                	addi	s0,sp,48
  int addr;
  int n;
  if(argint(0, &n) < 0)
    80002e24:	fdc40593          	addi	a1,s0,-36
    80002e28:	4501                	li	a0,0
    80002e2a:	00000097          	auipc	ra,0x0
    80002e2e:	e74080e7          	jalr	-396(ra) # 80002c9e <argint>
    return -1;
    80002e32:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002e34:	02054063          	bltz	a0,80002e54 <sys_sbrk+0x3c>

  struct proc *p = myproc();
    80002e38:	fffff097          	auipc	ra,0xfffff
    80002e3c:	d6c080e7          	jalr	-660(ra) # 80001ba4 <myproc>
    80002e40:	892a                	mv	s2,a0
  addr = p->sz;
    80002e42:	653c                	ld	a5,72(a0)
    80002e44:	0007849b          	sext.w	s1,a5
  p->sz += n;
    80002e48:	fdc42603          	lw	a2,-36(s0)
    80002e4c:	97b2                	add	a5,a5,a2
    80002e4e:	e53c                	sd	a5,72(a0)
  if(n < 0) {
    80002e50:	00064963          	bltz	a2,80002e62 <sys_sbrk+0x4a>
    p->sz = uvmdealloc(p->pagetable, addr, addr + n);
  }
  // if(growproc(n) < 0)
  //  return -1;
  return addr;
}
    80002e54:	8526                	mv	a0,s1
    80002e56:	70a2                	ld	ra,40(sp)
    80002e58:	7402                	ld	s0,32(sp)
    80002e5a:	64e2                	ld	s1,24(sp)
    80002e5c:	6942                	ld	s2,16(sp)
    80002e5e:	6145                	addi	sp,sp,48
    80002e60:	8082                	ret
    p->sz = uvmdealloc(p->pagetable, addr, addr + n);
    80002e62:	9e25                	addw	a2,a2,s1
    80002e64:	85a6                	mv	a1,s1
    80002e66:	6928                	ld	a0,80(a0)
    80002e68:	ffffe097          	auipc	ra,0xffffe
    80002e6c:	5ec080e7          	jalr	1516(ra) # 80001454 <uvmdealloc>
    80002e70:	04a93423          	sd	a0,72(s2)
  return addr;
    80002e74:	b7c5                	j	80002e54 <sys_sbrk+0x3c>

0000000080002e76 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e76:	7139                	addi	sp,sp,-64
    80002e78:	fc06                	sd	ra,56(sp)
    80002e7a:	f822                	sd	s0,48(sp)
    80002e7c:	f426                	sd	s1,40(sp)
    80002e7e:	f04a                	sd	s2,32(sp)
    80002e80:	ec4e                	sd	s3,24(sp)
    80002e82:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002e84:	fcc40593          	addi	a1,s0,-52
    80002e88:	4501                	li	a0,0
    80002e8a:	00000097          	auipc	ra,0x0
    80002e8e:	e14080e7          	jalr	-492(ra) # 80002c9e <argint>
    return -1;
    80002e92:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e94:	06054763          	bltz	a0,80002f02 <sys_sleep+0x8c>
  acquire(&tickslock);
    80002e98:	00015517          	auipc	a0,0x15
    80002e9c:	8d050513          	addi	a0,a0,-1840 # 80017768 <tickslock>
    80002ea0:	ffffe097          	auipc	ra,0xffffe
    80002ea4:	dc2080e7          	jalr	-574(ra) # 80000c62 <acquire>
  ticks0 = ticks;
    80002ea8:	00006797          	auipc	a5,0x6
    80002eac:	17878793          	addi	a5,a5,376 # 80009020 <ticks>
    80002eb0:	0007a903          	lw	s2,0(a5)
  while(ticks - ticks0 < n){
    80002eb4:	fcc42783          	lw	a5,-52(s0)
    80002eb8:	cf85                	beqz	a5,80002ef0 <sys_sleep+0x7a>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002eba:	00015997          	auipc	s3,0x15
    80002ebe:	8ae98993          	addi	s3,s3,-1874 # 80017768 <tickslock>
    80002ec2:	00006497          	auipc	s1,0x6
    80002ec6:	15e48493          	addi	s1,s1,350 # 80009020 <ticks>
    if(myproc()->killed){
    80002eca:	fffff097          	auipc	ra,0xfffff
    80002ece:	cda080e7          	jalr	-806(ra) # 80001ba4 <myproc>
    80002ed2:	591c                	lw	a5,48(a0)
    80002ed4:	ef9d                	bnez	a5,80002f12 <sys_sleep+0x9c>
    sleep(&ticks, &tickslock);
    80002ed6:	85ce                	mv	a1,s3
    80002ed8:	8526                	mv	a0,s1
    80002eda:	fffff097          	auipc	ra,0xfffff
    80002ede:	4e4080e7          	jalr	1252(ra) # 800023be <sleep>
  while(ticks - ticks0 < n){
    80002ee2:	409c                	lw	a5,0(s1)
    80002ee4:	412787bb          	subw	a5,a5,s2
    80002ee8:	fcc42703          	lw	a4,-52(s0)
    80002eec:	fce7efe3          	bltu	a5,a4,80002eca <sys_sleep+0x54>
  }
  release(&tickslock);
    80002ef0:	00015517          	auipc	a0,0x15
    80002ef4:	87850513          	addi	a0,a0,-1928 # 80017768 <tickslock>
    80002ef8:	ffffe097          	auipc	ra,0xffffe
    80002efc:	e1e080e7          	jalr	-482(ra) # 80000d16 <release>
  return 0;
    80002f00:	4781                	li	a5,0
}
    80002f02:	853e                	mv	a0,a5
    80002f04:	70e2                	ld	ra,56(sp)
    80002f06:	7442                	ld	s0,48(sp)
    80002f08:	74a2                	ld	s1,40(sp)
    80002f0a:	7902                	ld	s2,32(sp)
    80002f0c:	69e2                	ld	s3,24(sp)
    80002f0e:	6121                	addi	sp,sp,64
    80002f10:	8082                	ret
      release(&tickslock);
    80002f12:	00015517          	auipc	a0,0x15
    80002f16:	85650513          	addi	a0,a0,-1962 # 80017768 <tickslock>
    80002f1a:	ffffe097          	auipc	ra,0xffffe
    80002f1e:	dfc080e7          	jalr	-516(ra) # 80000d16 <release>
      return -1;
    80002f22:	57fd                	li	a5,-1
    80002f24:	bff9                	j	80002f02 <sys_sleep+0x8c>

0000000080002f26 <sys_kill>:

uint64
sys_kill(void)
{
    80002f26:	1101                	addi	sp,sp,-32
    80002f28:	ec06                	sd	ra,24(sp)
    80002f2a:	e822                	sd	s0,16(sp)
    80002f2c:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002f2e:	fec40593          	addi	a1,s0,-20
    80002f32:	4501                	li	a0,0
    80002f34:	00000097          	auipc	ra,0x0
    80002f38:	d6a080e7          	jalr	-662(ra) # 80002c9e <argint>
    return -1;
    80002f3c:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    80002f3e:	00054963          	bltz	a0,80002f50 <sys_kill+0x2a>
  return kill(pid);
    80002f42:	fec42503          	lw	a0,-20(s0)
    80002f46:	fffff097          	auipc	ra,0xfffff
    80002f4a:	668080e7          	jalr	1640(ra) # 800025ae <kill>
    80002f4e:	87aa                	mv	a5,a0
}
    80002f50:	853e                	mv	a0,a5
    80002f52:	60e2                	ld	ra,24(sp)
    80002f54:	6442                	ld	s0,16(sp)
    80002f56:	6105                	addi	sp,sp,32
    80002f58:	8082                	ret

0000000080002f5a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f5a:	1101                	addi	sp,sp,-32
    80002f5c:	ec06                	sd	ra,24(sp)
    80002f5e:	e822                	sd	s0,16(sp)
    80002f60:	e426                	sd	s1,8(sp)
    80002f62:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f64:	00015517          	auipc	a0,0x15
    80002f68:	80450513          	addi	a0,a0,-2044 # 80017768 <tickslock>
    80002f6c:	ffffe097          	auipc	ra,0xffffe
    80002f70:	cf6080e7          	jalr	-778(ra) # 80000c62 <acquire>
  xticks = ticks;
    80002f74:	00006797          	auipc	a5,0x6
    80002f78:	0ac78793          	addi	a5,a5,172 # 80009020 <ticks>
    80002f7c:	4384                	lw	s1,0(a5)
  release(&tickslock);
    80002f7e:	00014517          	auipc	a0,0x14
    80002f82:	7ea50513          	addi	a0,a0,2026 # 80017768 <tickslock>
    80002f86:	ffffe097          	auipc	ra,0xffffe
    80002f8a:	d90080e7          	jalr	-624(ra) # 80000d16 <release>
  return xticks;
}
    80002f8e:	02049513          	slli	a0,s1,0x20
    80002f92:	9101                	srli	a0,a0,0x20
    80002f94:	60e2                	ld	ra,24(sp)
    80002f96:	6442                	ld	s0,16(sp)
    80002f98:	64a2                	ld	s1,8(sp)
    80002f9a:	6105                	addi	sp,sp,32
    80002f9c:	8082                	ret

0000000080002f9e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f9e:	7179                	addi	sp,sp,-48
    80002fa0:	f406                	sd	ra,40(sp)
    80002fa2:	f022                	sd	s0,32(sp)
    80002fa4:	ec26                	sd	s1,24(sp)
    80002fa6:	e84a                	sd	s2,16(sp)
    80002fa8:	e44e                	sd	s3,8(sp)
    80002faa:	e052                	sd	s4,0(sp)
    80002fac:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002fae:	00005597          	auipc	a1,0x5
    80002fb2:	4fa58593          	addi	a1,a1,1274 # 800084a8 <syscalls+0xd8>
    80002fb6:	00014517          	auipc	a0,0x14
    80002fba:	7ca50513          	addi	a0,a0,1994 # 80017780 <bcache>
    80002fbe:	ffffe097          	auipc	ra,0xffffe
    80002fc2:	c14080e7          	jalr	-1004(ra) # 80000bd2 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002fc6:	0001c797          	auipc	a5,0x1c
    80002fca:	7ba78793          	addi	a5,a5,1978 # 8001f780 <bcache+0x8000>
    80002fce:	0001d717          	auipc	a4,0x1d
    80002fd2:	a1a70713          	addi	a4,a4,-1510 # 8001f9e8 <bcache+0x8268>
    80002fd6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002fda:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fde:	00014497          	auipc	s1,0x14
    80002fe2:	7ba48493          	addi	s1,s1,1978 # 80017798 <bcache+0x18>
    b->next = bcache.head.next;
    80002fe6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002fe8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002fea:	00005a17          	auipc	s4,0x5
    80002fee:	4c6a0a13          	addi	s4,s4,1222 # 800084b0 <syscalls+0xe0>
    b->next = bcache.head.next;
    80002ff2:	2b893783          	ld	a5,696(s2)
    80002ff6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ff8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ffc:	85d2                	mv	a1,s4
    80002ffe:	01048513          	addi	a0,s1,16
    80003002:	00001097          	auipc	ra,0x1
    80003006:	51e080e7          	jalr	1310(ra) # 80004520 <initsleeplock>
    bcache.head.next->prev = b;
    8000300a:	2b893783          	ld	a5,696(s2)
    8000300e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003010:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003014:	45848493          	addi	s1,s1,1112
    80003018:	fd349de3          	bne	s1,s3,80002ff2 <binit+0x54>
  }
}
    8000301c:	70a2                	ld	ra,40(sp)
    8000301e:	7402                	ld	s0,32(sp)
    80003020:	64e2                	ld	s1,24(sp)
    80003022:	6942                	ld	s2,16(sp)
    80003024:	69a2                	ld	s3,8(sp)
    80003026:	6a02                	ld	s4,0(sp)
    80003028:	6145                	addi	sp,sp,48
    8000302a:	8082                	ret

000000008000302c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000302c:	7179                	addi	sp,sp,-48
    8000302e:	f406                	sd	ra,40(sp)
    80003030:	f022                	sd	s0,32(sp)
    80003032:	ec26                	sd	s1,24(sp)
    80003034:	e84a                	sd	s2,16(sp)
    80003036:	e44e                	sd	s3,8(sp)
    80003038:	1800                	addi	s0,sp,48
    8000303a:	89aa                	mv	s3,a0
    8000303c:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000303e:	00014517          	auipc	a0,0x14
    80003042:	74250513          	addi	a0,a0,1858 # 80017780 <bcache>
    80003046:	ffffe097          	auipc	ra,0xffffe
    8000304a:	c1c080e7          	jalr	-996(ra) # 80000c62 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000304e:	0001c797          	auipc	a5,0x1c
    80003052:	73278793          	addi	a5,a5,1842 # 8001f780 <bcache+0x8000>
    80003056:	2b87b483          	ld	s1,696(a5)
    8000305a:	0001d797          	auipc	a5,0x1d
    8000305e:	98e78793          	addi	a5,a5,-1650 # 8001f9e8 <bcache+0x8268>
    80003062:	02f48f63          	beq	s1,a5,800030a0 <bread+0x74>
    80003066:	873e                	mv	a4,a5
    80003068:	a021                	j	80003070 <bread+0x44>
    8000306a:	68a4                	ld	s1,80(s1)
    8000306c:	02e48a63          	beq	s1,a4,800030a0 <bread+0x74>
    if(b->dev == dev && b->blockno == blockno){
    80003070:	449c                	lw	a5,8(s1)
    80003072:	ff379ce3          	bne	a5,s3,8000306a <bread+0x3e>
    80003076:	44dc                	lw	a5,12(s1)
    80003078:	ff2799e3          	bne	a5,s2,8000306a <bread+0x3e>
      b->refcnt++;
    8000307c:	40bc                	lw	a5,64(s1)
    8000307e:	2785                	addiw	a5,a5,1
    80003080:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003082:	00014517          	auipc	a0,0x14
    80003086:	6fe50513          	addi	a0,a0,1790 # 80017780 <bcache>
    8000308a:	ffffe097          	auipc	ra,0xffffe
    8000308e:	c8c080e7          	jalr	-884(ra) # 80000d16 <release>
      acquiresleep(&b->lock);
    80003092:	01048513          	addi	a0,s1,16
    80003096:	00001097          	auipc	ra,0x1
    8000309a:	4c4080e7          	jalr	1220(ra) # 8000455a <acquiresleep>
      return b;
    8000309e:	a8b1                	j	800030fa <bread+0xce>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030a0:	0001c797          	auipc	a5,0x1c
    800030a4:	6e078793          	addi	a5,a5,1760 # 8001f780 <bcache+0x8000>
    800030a8:	2b07b483          	ld	s1,688(a5)
    800030ac:	0001d797          	auipc	a5,0x1d
    800030b0:	93c78793          	addi	a5,a5,-1732 # 8001f9e8 <bcache+0x8268>
    800030b4:	04f48d63          	beq	s1,a5,8000310e <bread+0xe2>
    if(b->refcnt == 0) {
    800030b8:	40bc                	lw	a5,64(s1)
    800030ba:	cb91                	beqz	a5,800030ce <bread+0xa2>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030bc:	0001d717          	auipc	a4,0x1d
    800030c0:	92c70713          	addi	a4,a4,-1748 # 8001f9e8 <bcache+0x8268>
    800030c4:	64a4                	ld	s1,72(s1)
    800030c6:	04e48463          	beq	s1,a4,8000310e <bread+0xe2>
    if(b->refcnt == 0) {
    800030ca:	40bc                	lw	a5,64(s1)
    800030cc:	ffe5                	bnez	a5,800030c4 <bread+0x98>
      b->dev = dev;
    800030ce:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800030d2:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800030d6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800030da:	4785                	li	a5,1
    800030dc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030de:	00014517          	auipc	a0,0x14
    800030e2:	6a250513          	addi	a0,a0,1698 # 80017780 <bcache>
    800030e6:	ffffe097          	auipc	ra,0xffffe
    800030ea:	c30080e7          	jalr	-976(ra) # 80000d16 <release>
      acquiresleep(&b->lock);
    800030ee:	01048513          	addi	a0,s1,16
    800030f2:	00001097          	auipc	ra,0x1
    800030f6:	468080e7          	jalr	1128(ra) # 8000455a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800030fa:	409c                	lw	a5,0(s1)
    800030fc:	c38d                	beqz	a5,8000311e <bread+0xf2>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800030fe:	8526                	mv	a0,s1
    80003100:	70a2                	ld	ra,40(sp)
    80003102:	7402                	ld	s0,32(sp)
    80003104:	64e2                	ld	s1,24(sp)
    80003106:	6942                	ld	s2,16(sp)
    80003108:	69a2                	ld	s3,8(sp)
    8000310a:	6145                	addi	sp,sp,48
    8000310c:	8082                	ret
  panic("bget: no buffers");
    8000310e:	00005517          	auipc	a0,0x5
    80003112:	3aa50513          	addi	a0,a0,938 # 800084b8 <syscalls+0xe8>
    80003116:	ffffd097          	auipc	ra,0xffffd
    8000311a:	45e080e7          	jalr	1118(ra) # 80000574 <panic>
    virtio_disk_rw(b, 0);
    8000311e:	4581                	li	a1,0
    80003120:	8526                	mv	a0,s1
    80003122:	00003097          	auipc	ra,0x3
    80003126:	00c080e7          	jalr	12(ra) # 8000612e <virtio_disk_rw>
    b->valid = 1;
    8000312a:	4785                	li	a5,1
    8000312c:	c09c                	sw	a5,0(s1)
  return b;
    8000312e:	bfc1                	j	800030fe <bread+0xd2>

0000000080003130 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003130:	1101                	addi	sp,sp,-32
    80003132:	ec06                	sd	ra,24(sp)
    80003134:	e822                	sd	s0,16(sp)
    80003136:	e426                	sd	s1,8(sp)
    80003138:	1000                	addi	s0,sp,32
    8000313a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000313c:	0541                	addi	a0,a0,16
    8000313e:	00001097          	auipc	ra,0x1
    80003142:	4b6080e7          	jalr	1206(ra) # 800045f4 <holdingsleep>
    80003146:	cd01                	beqz	a0,8000315e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003148:	4585                	li	a1,1
    8000314a:	8526                	mv	a0,s1
    8000314c:	00003097          	auipc	ra,0x3
    80003150:	fe2080e7          	jalr	-30(ra) # 8000612e <virtio_disk_rw>
}
    80003154:	60e2                	ld	ra,24(sp)
    80003156:	6442                	ld	s0,16(sp)
    80003158:	64a2                	ld	s1,8(sp)
    8000315a:	6105                	addi	sp,sp,32
    8000315c:	8082                	ret
    panic("bwrite");
    8000315e:	00005517          	auipc	a0,0x5
    80003162:	37250513          	addi	a0,a0,882 # 800084d0 <syscalls+0x100>
    80003166:	ffffd097          	auipc	ra,0xffffd
    8000316a:	40e080e7          	jalr	1038(ra) # 80000574 <panic>

000000008000316e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000316e:	1101                	addi	sp,sp,-32
    80003170:	ec06                	sd	ra,24(sp)
    80003172:	e822                	sd	s0,16(sp)
    80003174:	e426                	sd	s1,8(sp)
    80003176:	e04a                	sd	s2,0(sp)
    80003178:	1000                	addi	s0,sp,32
    8000317a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000317c:	01050913          	addi	s2,a0,16
    80003180:	854a                	mv	a0,s2
    80003182:	00001097          	auipc	ra,0x1
    80003186:	472080e7          	jalr	1138(ra) # 800045f4 <holdingsleep>
    8000318a:	c92d                	beqz	a0,800031fc <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000318c:	854a                	mv	a0,s2
    8000318e:	00001097          	auipc	ra,0x1
    80003192:	422080e7          	jalr	1058(ra) # 800045b0 <releasesleep>

  acquire(&bcache.lock);
    80003196:	00014517          	auipc	a0,0x14
    8000319a:	5ea50513          	addi	a0,a0,1514 # 80017780 <bcache>
    8000319e:	ffffe097          	auipc	ra,0xffffe
    800031a2:	ac4080e7          	jalr	-1340(ra) # 80000c62 <acquire>
  b->refcnt--;
    800031a6:	40bc                	lw	a5,64(s1)
    800031a8:	37fd                	addiw	a5,a5,-1
    800031aa:	0007871b          	sext.w	a4,a5
    800031ae:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031b0:	eb05                	bnez	a4,800031e0 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031b2:	68bc                	ld	a5,80(s1)
    800031b4:	64b8                	ld	a4,72(s1)
    800031b6:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800031b8:	64bc                	ld	a5,72(s1)
    800031ba:	68b8                	ld	a4,80(s1)
    800031bc:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800031be:	0001c797          	auipc	a5,0x1c
    800031c2:	5c278793          	addi	a5,a5,1474 # 8001f780 <bcache+0x8000>
    800031c6:	2b87b703          	ld	a4,696(a5)
    800031ca:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800031cc:	0001d717          	auipc	a4,0x1d
    800031d0:	81c70713          	addi	a4,a4,-2020 # 8001f9e8 <bcache+0x8268>
    800031d4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800031d6:	2b87b703          	ld	a4,696(a5)
    800031da:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800031dc:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800031e0:	00014517          	auipc	a0,0x14
    800031e4:	5a050513          	addi	a0,a0,1440 # 80017780 <bcache>
    800031e8:	ffffe097          	auipc	ra,0xffffe
    800031ec:	b2e080e7          	jalr	-1234(ra) # 80000d16 <release>
}
    800031f0:	60e2                	ld	ra,24(sp)
    800031f2:	6442                	ld	s0,16(sp)
    800031f4:	64a2                	ld	s1,8(sp)
    800031f6:	6902                	ld	s2,0(sp)
    800031f8:	6105                	addi	sp,sp,32
    800031fa:	8082                	ret
    panic("brelse");
    800031fc:	00005517          	auipc	a0,0x5
    80003200:	2dc50513          	addi	a0,a0,732 # 800084d8 <syscalls+0x108>
    80003204:	ffffd097          	auipc	ra,0xffffd
    80003208:	370080e7          	jalr	880(ra) # 80000574 <panic>

000000008000320c <bpin>:

void
bpin(struct buf *b) {
    8000320c:	1101                	addi	sp,sp,-32
    8000320e:	ec06                	sd	ra,24(sp)
    80003210:	e822                	sd	s0,16(sp)
    80003212:	e426                	sd	s1,8(sp)
    80003214:	1000                	addi	s0,sp,32
    80003216:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003218:	00014517          	auipc	a0,0x14
    8000321c:	56850513          	addi	a0,a0,1384 # 80017780 <bcache>
    80003220:	ffffe097          	auipc	ra,0xffffe
    80003224:	a42080e7          	jalr	-1470(ra) # 80000c62 <acquire>
  b->refcnt++;
    80003228:	40bc                	lw	a5,64(s1)
    8000322a:	2785                	addiw	a5,a5,1
    8000322c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000322e:	00014517          	auipc	a0,0x14
    80003232:	55250513          	addi	a0,a0,1362 # 80017780 <bcache>
    80003236:	ffffe097          	auipc	ra,0xffffe
    8000323a:	ae0080e7          	jalr	-1312(ra) # 80000d16 <release>
}
    8000323e:	60e2                	ld	ra,24(sp)
    80003240:	6442                	ld	s0,16(sp)
    80003242:	64a2                	ld	s1,8(sp)
    80003244:	6105                	addi	sp,sp,32
    80003246:	8082                	ret

0000000080003248 <bunpin>:

void
bunpin(struct buf *b) {
    80003248:	1101                	addi	sp,sp,-32
    8000324a:	ec06                	sd	ra,24(sp)
    8000324c:	e822                	sd	s0,16(sp)
    8000324e:	e426                	sd	s1,8(sp)
    80003250:	1000                	addi	s0,sp,32
    80003252:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003254:	00014517          	auipc	a0,0x14
    80003258:	52c50513          	addi	a0,a0,1324 # 80017780 <bcache>
    8000325c:	ffffe097          	auipc	ra,0xffffe
    80003260:	a06080e7          	jalr	-1530(ra) # 80000c62 <acquire>
  b->refcnt--;
    80003264:	40bc                	lw	a5,64(s1)
    80003266:	37fd                	addiw	a5,a5,-1
    80003268:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000326a:	00014517          	auipc	a0,0x14
    8000326e:	51650513          	addi	a0,a0,1302 # 80017780 <bcache>
    80003272:	ffffe097          	auipc	ra,0xffffe
    80003276:	aa4080e7          	jalr	-1372(ra) # 80000d16 <release>
}
    8000327a:	60e2                	ld	ra,24(sp)
    8000327c:	6442                	ld	s0,16(sp)
    8000327e:	64a2                	ld	s1,8(sp)
    80003280:	6105                	addi	sp,sp,32
    80003282:	8082                	ret

0000000080003284 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003284:	1101                	addi	sp,sp,-32
    80003286:	ec06                	sd	ra,24(sp)
    80003288:	e822                	sd	s0,16(sp)
    8000328a:	e426                	sd	s1,8(sp)
    8000328c:	e04a                	sd	s2,0(sp)
    8000328e:	1000                	addi	s0,sp,32
    80003290:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003292:	00d5d59b          	srliw	a1,a1,0xd
    80003296:	0001d797          	auipc	a5,0x1d
    8000329a:	baa78793          	addi	a5,a5,-1110 # 8001fe40 <sb>
    8000329e:	4fdc                	lw	a5,28(a5)
    800032a0:	9dbd                	addw	a1,a1,a5
    800032a2:	00000097          	auipc	ra,0x0
    800032a6:	d8a080e7          	jalr	-630(ra) # 8000302c <bread>
  bi = b % BPB;
    800032aa:	2481                	sext.w	s1,s1
  m = 1 << (bi % 8);
    800032ac:	0074f793          	andi	a5,s1,7
    800032b0:	4705                	li	a4,1
    800032b2:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    800032b6:	6789                	lui	a5,0x2
    800032b8:	17fd                	addi	a5,a5,-1
    800032ba:	8cfd                	and	s1,s1,a5
  if((bp->data[bi/8] & m) == 0)
    800032bc:	41f4d79b          	sraiw	a5,s1,0x1f
    800032c0:	01d7d79b          	srliw	a5,a5,0x1d
    800032c4:	9fa5                	addw	a5,a5,s1
    800032c6:	4037d79b          	sraiw	a5,a5,0x3
    800032ca:	00f506b3          	add	a3,a0,a5
    800032ce:	0586c683          	lbu	a3,88(a3)
    800032d2:	00d77633          	and	a2,a4,a3
    800032d6:	c61d                	beqz	a2,80003304 <bfree+0x80>
    800032d8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800032da:	97aa                	add	a5,a5,a0
    800032dc:	fff74713          	not	a4,a4
    800032e0:	8f75                	and	a4,a4,a3
    800032e2:	04e78c23          	sb	a4,88(a5) # 2058 <_entry-0x7fffdfa8>
  log_write(bp);
    800032e6:	00001097          	auipc	ra,0x1
    800032ea:	136080e7          	jalr	310(ra) # 8000441c <log_write>
  brelse(bp);
    800032ee:	854a                	mv	a0,s2
    800032f0:	00000097          	auipc	ra,0x0
    800032f4:	e7e080e7          	jalr	-386(ra) # 8000316e <brelse>
}
    800032f8:	60e2                	ld	ra,24(sp)
    800032fa:	6442                	ld	s0,16(sp)
    800032fc:	64a2                	ld	s1,8(sp)
    800032fe:	6902                	ld	s2,0(sp)
    80003300:	6105                	addi	sp,sp,32
    80003302:	8082                	ret
    panic("freeing free block");
    80003304:	00005517          	auipc	a0,0x5
    80003308:	1dc50513          	addi	a0,a0,476 # 800084e0 <syscalls+0x110>
    8000330c:	ffffd097          	auipc	ra,0xffffd
    80003310:	268080e7          	jalr	616(ra) # 80000574 <panic>

0000000080003314 <balloc>:
{
    80003314:	711d                	addi	sp,sp,-96
    80003316:	ec86                	sd	ra,88(sp)
    80003318:	e8a2                	sd	s0,80(sp)
    8000331a:	e4a6                	sd	s1,72(sp)
    8000331c:	e0ca                	sd	s2,64(sp)
    8000331e:	fc4e                	sd	s3,56(sp)
    80003320:	f852                	sd	s4,48(sp)
    80003322:	f456                	sd	s5,40(sp)
    80003324:	f05a                	sd	s6,32(sp)
    80003326:	ec5e                	sd	s7,24(sp)
    80003328:	e862                	sd	s8,16(sp)
    8000332a:	e466                	sd	s9,8(sp)
    8000332c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000332e:	0001d797          	auipc	a5,0x1d
    80003332:	b1278793          	addi	a5,a5,-1262 # 8001fe40 <sb>
    80003336:	43dc                	lw	a5,4(a5)
    80003338:	10078e63          	beqz	a5,80003454 <balloc+0x140>
    8000333c:	8baa                	mv	s7,a0
    8000333e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003340:	0001db17          	auipc	s6,0x1d
    80003344:	b00b0b13          	addi	s6,s6,-1280 # 8001fe40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003348:	4c05                	li	s8,1
      m = 1 << (bi % 8);
    8000334a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000334c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000334e:	6c89                	lui	s9,0x2
    80003350:	a079                	j	800033de <balloc+0xca>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003352:	8942                	mv	s2,a6
      m = 1 << (bi % 8);
    80003354:	4705                	li	a4,1
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003356:	4681                	li	a3,0
        bp->data[bi/8] |= m;  // Mark block in use.
    80003358:	96a6                	add	a3,a3,s1
    8000335a:	8f51                	or	a4,a4,a2
    8000335c:	04e68c23          	sb	a4,88(a3)
        log_write(bp);
    80003360:	8526                	mv	a0,s1
    80003362:	00001097          	auipc	ra,0x1
    80003366:	0ba080e7          	jalr	186(ra) # 8000441c <log_write>
        brelse(bp);
    8000336a:	8526                	mv	a0,s1
    8000336c:	00000097          	auipc	ra,0x0
    80003370:	e02080e7          	jalr	-510(ra) # 8000316e <brelse>
  bp = bread(dev, bno);
    80003374:	85ca                	mv	a1,s2
    80003376:	855e                	mv	a0,s7
    80003378:	00000097          	auipc	ra,0x0
    8000337c:	cb4080e7          	jalr	-844(ra) # 8000302c <bread>
    80003380:	84aa                	mv	s1,a0
  memset(bp->data, 0, BSIZE);
    80003382:	40000613          	li	a2,1024
    80003386:	4581                	li	a1,0
    80003388:	05850513          	addi	a0,a0,88
    8000338c:	ffffe097          	auipc	ra,0xffffe
    80003390:	9d2080e7          	jalr	-1582(ra) # 80000d5e <memset>
  log_write(bp);
    80003394:	8526                	mv	a0,s1
    80003396:	00001097          	auipc	ra,0x1
    8000339a:	086080e7          	jalr	134(ra) # 8000441c <log_write>
  brelse(bp);
    8000339e:	8526                	mv	a0,s1
    800033a0:	00000097          	auipc	ra,0x0
    800033a4:	dce080e7          	jalr	-562(ra) # 8000316e <brelse>
}
    800033a8:	854a                	mv	a0,s2
    800033aa:	60e6                	ld	ra,88(sp)
    800033ac:	6446                	ld	s0,80(sp)
    800033ae:	64a6                	ld	s1,72(sp)
    800033b0:	6906                	ld	s2,64(sp)
    800033b2:	79e2                	ld	s3,56(sp)
    800033b4:	7a42                	ld	s4,48(sp)
    800033b6:	7aa2                	ld	s5,40(sp)
    800033b8:	7b02                	ld	s6,32(sp)
    800033ba:	6be2                	ld	s7,24(sp)
    800033bc:	6c42                	ld	s8,16(sp)
    800033be:	6ca2                	ld	s9,8(sp)
    800033c0:	6125                	addi	sp,sp,96
    800033c2:	8082                	ret
    brelse(bp);
    800033c4:	8526                	mv	a0,s1
    800033c6:	00000097          	auipc	ra,0x0
    800033ca:	da8080e7          	jalr	-600(ra) # 8000316e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033ce:	015c87bb          	addw	a5,s9,s5
    800033d2:	00078a9b          	sext.w	s5,a5
    800033d6:	004b2703          	lw	a4,4(s6)
    800033da:	06eafd63          	bleu	a4,s5,80003454 <balloc+0x140>
    bp = bread(dev, BBLOCK(b, sb));
    800033de:	41fad79b          	sraiw	a5,s5,0x1f
    800033e2:	0137d79b          	srliw	a5,a5,0x13
    800033e6:	015787bb          	addw	a5,a5,s5
    800033ea:	40d7d79b          	sraiw	a5,a5,0xd
    800033ee:	01cb2583          	lw	a1,28(s6)
    800033f2:	9dbd                	addw	a1,a1,a5
    800033f4:	855e                	mv	a0,s7
    800033f6:	00000097          	auipc	ra,0x0
    800033fa:	c36080e7          	jalr	-970(ra) # 8000302c <bread>
    800033fe:	84aa                	mv	s1,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003400:	000a881b          	sext.w	a6,s5
    80003404:	004b2503          	lw	a0,4(s6)
    80003408:	faa87ee3          	bleu	a0,a6,800033c4 <balloc+0xb0>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000340c:	0584c603          	lbu	a2,88(s1)
    80003410:	00167793          	andi	a5,a2,1
    80003414:	df9d                	beqz	a5,80003352 <balloc+0x3e>
    80003416:	4105053b          	subw	a0,a0,a6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000341a:	87e2                	mv	a5,s8
    8000341c:	0107893b          	addw	s2,a5,a6
    80003420:	faa782e3          	beq	a5,a0,800033c4 <balloc+0xb0>
      m = 1 << (bi % 8);
    80003424:	41f7d71b          	sraiw	a4,a5,0x1f
    80003428:	01d7561b          	srliw	a2,a4,0x1d
    8000342c:	00f606bb          	addw	a3,a2,a5
    80003430:	0076f713          	andi	a4,a3,7
    80003434:	9f11                	subw	a4,a4,a2
    80003436:	00e9973b          	sllw	a4,s3,a4
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000343a:	4036d69b          	sraiw	a3,a3,0x3
    8000343e:	00d48633          	add	a2,s1,a3
    80003442:	05864603          	lbu	a2,88(a2)
    80003446:	00c775b3          	and	a1,a4,a2
    8000344a:	d599                	beqz	a1,80003358 <balloc+0x44>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000344c:	2785                	addiw	a5,a5,1
    8000344e:	fd4797e3          	bne	a5,s4,8000341c <balloc+0x108>
    80003452:	bf8d                	j	800033c4 <balloc+0xb0>
  panic("balloc: out of blocks");
    80003454:	00005517          	auipc	a0,0x5
    80003458:	0a450513          	addi	a0,a0,164 # 800084f8 <syscalls+0x128>
    8000345c:	ffffd097          	auipc	ra,0xffffd
    80003460:	118080e7          	jalr	280(ra) # 80000574 <panic>

0000000080003464 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003464:	7179                	addi	sp,sp,-48
    80003466:	f406                	sd	ra,40(sp)
    80003468:	f022                	sd	s0,32(sp)
    8000346a:	ec26                	sd	s1,24(sp)
    8000346c:	e84a                	sd	s2,16(sp)
    8000346e:	e44e                	sd	s3,8(sp)
    80003470:	e052                	sd	s4,0(sp)
    80003472:	1800                	addi	s0,sp,48
    80003474:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003476:	47ad                	li	a5,11
    80003478:	04b7fe63          	bleu	a1,a5,800034d4 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000347c:	ff45849b          	addiw	s1,a1,-12
    80003480:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003484:	0ff00793          	li	a5,255
    80003488:	0ae7e363          	bltu	a5,a4,8000352e <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000348c:	08052583          	lw	a1,128(a0)
    80003490:	c5ad                	beqz	a1,800034fa <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003492:	0009a503          	lw	a0,0(s3)
    80003496:	00000097          	auipc	ra,0x0
    8000349a:	b96080e7          	jalr	-1130(ra) # 8000302c <bread>
    8000349e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034a0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800034a4:	02049593          	slli	a1,s1,0x20
    800034a8:	9181                	srli	a1,a1,0x20
    800034aa:	058a                	slli	a1,a1,0x2
    800034ac:	00b784b3          	add	s1,a5,a1
    800034b0:	0004a903          	lw	s2,0(s1)
    800034b4:	04090d63          	beqz	s2,8000350e <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800034b8:	8552                	mv	a0,s4
    800034ba:	00000097          	auipc	ra,0x0
    800034be:	cb4080e7          	jalr	-844(ra) # 8000316e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800034c2:	854a                	mv	a0,s2
    800034c4:	70a2                	ld	ra,40(sp)
    800034c6:	7402                	ld	s0,32(sp)
    800034c8:	64e2                	ld	s1,24(sp)
    800034ca:	6942                	ld	s2,16(sp)
    800034cc:	69a2                	ld	s3,8(sp)
    800034ce:	6a02                	ld	s4,0(sp)
    800034d0:	6145                	addi	sp,sp,48
    800034d2:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800034d4:	02059493          	slli	s1,a1,0x20
    800034d8:	9081                	srli	s1,s1,0x20
    800034da:	048a                	slli	s1,s1,0x2
    800034dc:	94aa                	add	s1,s1,a0
    800034de:	0504a903          	lw	s2,80(s1)
    800034e2:	fe0910e3          	bnez	s2,800034c2 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800034e6:	4108                	lw	a0,0(a0)
    800034e8:	00000097          	auipc	ra,0x0
    800034ec:	e2c080e7          	jalr	-468(ra) # 80003314 <balloc>
    800034f0:	0005091b          	sext.w	s2,a0
    800034f4:	0524a823          	sw	s2,80(s1)
    800034f8:	b7e9                	j	800034c2 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800034fa:	4108                	lw	a0,0(a0)
    800034fc:	00000097          	auipc	ra,0x0
    80003500:	e18080e7          	jalr	-488(ra) # 80003314 <balloc>
    80003504:	0005059b          	sext.w	a1,a0
    80003508:	08b9a023          	sw	a1,128(s3)
    8000350c:	b759                	j	80003492 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000350e:	0009a503          	lw	a0,0(s3)
    80003512:	00000097          	auipc	ra,0x0
    80003516:	e02080e7          	jalr	-510(ra) # 80003314 <balloc>
    8000351a:	0005091b          	sext.w	s2,a0
    8000351e:	0124a023          	sw	s2,0(s1)
      log_write(bp);
    80003522:	8552                	mv	a0,s4
    80003524:	00001097          	auipc	ra,0x1
    80003528:	ef8080e7          	jalr	-264(ra) # 8000441c <log_write>
    8000352c:	b771                	j	800034b8 <bmap+0x54>
  panic("bmap: out of range");
    8000352e:	00005517          	auipc	a0,0x5
    80003532:	fe250513          	addi	a0,a0,-30 # 80008510 <syscalls+0x140>
    80003536:	ffffd097          	auipc	ra,0xffffd
    8000353a:	03e080e7          	jalr	62(ra) # 80000574 <panic>

000000008000353e <iget>:
{
    8000353e:	7179                	addi	sp,sp,-48
    80003540:	f406                	sd	ra,40(sp)
    80003542:	f022                	sd	s0,32(sp)
    80003544:	ec26                	sd	s1,24(sp)
    80003546:	e84a                	sd	s2,16(sp)
    80003548:	e44e                	sd	s3,8(sp)
    8000354a:	e052                	sd	s4,0(sp)
    8000354c:	1800                	addi	s0,sp,48
    8000354e:	89aa                	mv	s3,a0
    80003550:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003552:	0001d517          	auipc	a0,0x1d
    80003556:	90e50513          	addi	a0,a0,-1778 # 8001fe60 <icache>
    8000355a:	ffffd097          	auipc	ra,0xffffd
    8000355e:	708080e7          	jalr	1800(ra) # 80000c62 <acquire>
  empty = 0;
    80003562:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003564:	0001d497          	auipc	s1,0x1d
    80003568:	91448493          	addi	s1,s1,-1772 # 8001fe78 <icache+0x18>
    8000356c:	0001e697          	auipc	a3,0x1e
    80003570:	39c68693          	addi	a3,a3,924 # 80021908 <log>
    80003574:	a039                	j	80003582 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003576:	02090b63          	beqz	s2,800035ac <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000357a:	08848493          	addi	s1,s1,136
    8000357e:	02d48a63          	beq	s1,a3,800035b2 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003582:	449c                	lw	a5,8(s1)
    80003584:	fef059e3          	blez	a5,80003576 <iget+0x38>
    80003588:	4098                	lw	a4,0(s1)
    8000358a:	ff3716e3          	bne	a4,s3,80003576 <iget+0x38>
    8000358e:	40d8                	lw	a4,4(s1)
    80003590:	ff4713e3          	bne	a4,s4,80003576 <iget+0x38>
      ip->ref++;
    80003594:	2785                	addiw	a5,a5,1
    80003596:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003598:	0001d517          	auipc	a0,0x1d
    8000359c:	8c850513          	addi	a0,a0,-1848 # 8001fe60 <icache>
    800035a0:	ffffd097          	auipc	ra,0xffffd
    800035a4:	776080e7          	jalr	1910(ra) # 80000d16 <release>
      return ip;
    800035a8:	8926                	mv	s2,s1
    800035aa:	a03d                	j	800035d8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035ac:	f7f9                	bnez	a5,8000357a <iget+0x3c>
    800035ae:	8926                	mv	s2,s1
    800035b0:	b7e9                	j	8000357a <iget+0x3c>
  if(empty == 0)
    800035b2:	02090c63          	beqz	s2,800035ea <iget+0xac>
  ip->dev = dev;
    800035b6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035ba:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035be:	4785                	li	a5,1
    800035c0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035c4:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800035c8:	0001d517          	auipc	a0,0x1d
    800035cc:	89850513          	addi	a0,a0,-1896 # 8001fe60 <icache>
    800035d0:	ffffd097          	auipc	ra,0xffffd
    800035d4:	746080e7          	jalr	1862(ra) # 80000d16 <release>
}
    800035d8:	854a                	mv	a0,s2
    800035da:	70a2                	ld	ra,40(sp)
    800035dc:	7402                	ld	s0,32(sp)
    800035de:	64e2                	ld	s1,24(sp)
    800035e0:	6942                	ld	s2,16(sp)
    800035e2:	69a2                	ld	s3,8(sp)
    800035e4:	6a02                	ld	s4,0(sp)
    800035e6:	6145                	addi	sp,sp,48
    800035e8:	8082                	ret
    panic("iget: no inodes");
    800035ea:	00005517          	auipc	a0,0x5
    800035ee:	f3e50513          	addi	a0,a0,-194 # 80008528 <syscalls+0x158>
    800035f2:	ffffd097          	auipc	ra,0xffffd
    800035f6:	f82080e7          	jalr	-126(ra) # 80000574 <panic>

00000000800035fa <fsinit>:
fsinit(int dev) {
    800035fa:	7179                	addi	sp,sp,-48
    800035fc:	f406                	sd	ra,40(sp)
    800035fe:	f022                	sd	s0,32(sp)
    80003600:	ec26                	sd	s1,24(sp)
    80003602:	e84a                	sd	s2,16(sp)
    80003604:	e44e                	sd	s3,8(sp)
    80003606:	1800                	addi	s0,sp,48
    80003608:	89aa                	mv	s3,a0
  bp = bread(dev, 1);
    8000360a:	4585                	li	a1,1
    8000360c:	00000097          	auipc	ra,0x0
    80003610:	a20080e7          	jalr	-1504(ra) # 8000302c <bread>
    80003614:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003616:	0001d497          	auipc	s1,0x1d
    8000361a:	82a48493          	addi	s1,s1,-2006 # 8001fe40 <sb>
    8000361e:	02000613          	li	a2,32
    80003622:	05850593          	addi	a1,a0,88
    80003626:	8526                	mv	a0,s1
    80003628:	ffffd097          	auipc	ra,0xffffd
    8000362c:	7a2080e7          	jalr	1954(ra) # 80000dca <memmove>
  brelse(bp);
    80003630:	854a                	mv	a0,s2
    80003632:	00000097          	auipc	ra,0x0
    80003636:	b3c080e7          	jalr	-1220(ra) # 8000316e <brelse>
  if(sb.magic != FSMAGIC)
    8000363a:	4098                	lw	a4,0(s1)
    8000363c:	102037b7          	lui	a5,0x10203
    80003640:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003644:	02f71263          	bne	a4,a5,80003668 <fsinit+0x6e>
  initlog(dev, &sb);
    80003648:	0001c597          	auipc	a1,0x1c
    8000364c:	7f858593          	addi	a1,a1,2040 # 8001fe40 <sb>
    80003650:	854e                	mv	a0,s3
    80003652:	00001097          	auipc	ra,0x1
    80003656:	b4c080e7          	jalr	-1204(ra) # 8000419e <initlog>
}
    8000365a:	70a2                	ld	ra,40(sp)
    8000365c:	7402                	ld	s0,32(sp)
    8000365e:	64e2                	ld	s1,24(sp)
    80003660:	6942                	ld	s2,16(sp)
    80003662:	69a2                	ld	s3,8(sp)
    80003664:	6145                	addi	sp,sp,48
    80003666:	8082                	ret
    panic("invalid file system");
    80003668:	00005517          	auipc	a0,0x5
    8000366c:	ed050513          	addi	a0,a0,-304 # 80008538 <syscalls+0x168>
    80003670:	ffffd097          	auipc	ra,0xffffd
    80003674:	f04080e7          	jalr	-252(ra) # 80000574 <panic>

0000000080003678 <iinit>:
{
    80003678:	7179                	addi	sp,sp,-48
    8000367a:	f406                	sd	ra,40(sp)
    8000367c:	f022                	sd	s0,32(sp)
    8000367e:	ec26                	sd	s1,24(sp)
    80003680:	e84a                	sd	s2,16(sp)
    80003682:	e44e                	sd	s3,8(sp)
    80003684:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003686:	00005597          	auipc	a1,0x5
    8000368a:	eca58593          	addi	a1,a1,-310 # 80008550 <syscalls+0x180>
    8000368e:	0001c517          	auipc	a0,0x1c
    80003692:	7d250513          	addi	a0,a0,2002 # 8001fe60 <icache>
    80003696:	ffffd097          	auipc	ra,0xffffd
    8000369a:	53c080e7          	jalr	1340(ra) # 80000bd2 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000369e:	0001c497          	auipc	s1,0x1c
    800036a2:	7ea48493          	addi	s1,s1,2026 # 8001fe88 <icache+0x28>
    800036a6:	0001e997          	auipc	s3,0x1e
    800036aa:	27298993          	addi	s3,s3,626 # 80021918 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800036ae:	00005917          	auipc	s2,0x5
    800036b2:	eaa90913          	addi	s2,s2,-342 # 80008558 <syscalls+0x188>
    800036b6:	85ca                	mv	a1,s2
    800036b8:	8526                	mv	a0,s1
    800036ba:	00001097          	auipc	ra,0x1
    800036be:	e66080e7          	jalr	-410(ra) # 80004520 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036c2:	08848493          	addi	s1,s1,136
    800036c6:	ff3498e3          	bne	s1,s3,800036b6 <iinit+0x3e>
}
    800036ca:	70a2                	ld	ra,40(sp)
    800036cc:	7402                	ld	s0,32(sp)
    800036ce:	64e2                	ld	s1,24(sp)
    800036d0:	6942                	ld	s2,16(sp)
    800036d2:	69a2                	ld	s3,8(sp)
    800036d4:	6145                	addi	sp,sp,48
    800036d6:	8082                	ret

00000000800036d8 <ialloc>:
{
    800036d8:	715d                	addi	sp,sp,-80
    800036da:	e486                	sd	ra,72(sp)
    800036dc:	e0a2                	sd	s0,64(sp)
    800036de:	fc26                	sd	s1,56(sp)
    800036e0:	f84a                	sd	s2,48(sp)
    800036e2:	f44e                	sd	s3,40(sp)
    800036e4:	f052                	sd	s4,32(sp)
    800036e6:	ec56                	sd	s5,24(sp)
    800036e8:	e85a                	sd	s6,16(sp)
    800036ea:	e45e                	sd	s7,8(sp)
    800036ec:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800036ee:	0001c797          	auipc	a5,0x1c
    800036f2:	75278793          	addi	a5,a5,1874 # 8001fe40 <sb>
    800036f6:	47d8                	lw	a4,12(a5)
    800036f8:	4785                	li	a5,1
    800036fa:	04e7fa63          	bleu	a4,a5,8000374e <ialloc+0x76>
    800036fe:	8a2a                	mv	s4,a0
    80003700:	8b2e                	mv	s6,a1
    80003702:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003704:	0001c997          	auipc	s3,0x1c
    80003708:	73c98993          	addi	s3,s3,1852 # 8001fe40 <sb>
    8000370c:	00048a9b          	sext.w	s5,s1
    80003710:	0044d593          	srli	a1,s1,0x4
    80003714:	0189a783          	lw	a5,24(s3)
    80003718:	9dbd                	addw	a1,a1,a5
    8000371a:	8552                	mv	a0,s4
    8000371c:	00000097          	auipc	ra,0x0
    80003720:	910080e7          	jalr	-1776(ra) # 8000302c <bread>
    80003724:	8baa                	mv	s7,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003726:	05850913          	addi	s2,a0,88
    8000372a:	00f4f793          	andi	a5,s1,15
    8000372e:	079a                	slli	a5,a5,0x6
    80003730:	993e                	add	s2,s2,a5
    if(dip->type == 0){  // a free inode
    80003732:	00091783          	lh	a5,0(s2)
    80003736:	c785                	beqz	a5,8000375e <ialloc+0x86>
    brelse(bp);
    80003738:	00000097          	auipc	ra,0x0
    8000373c:	a36080e7          	jalr	-1482(ra) # 8000316e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003740:	0485                	addi	s1,s1,1
    80003742:	00c9a703          	lw	a4,12(s3)
    80003746:	0004879b          	sext.w	a5,s1
    8000374a:	fce7e1e3          	bltu	a5,a4,8000370c <ialloc+0x34>
  panic("ialloc: no inodes");
    8000374e:	00005517          	auipc	a0,0x5
    80003752:	e1250513          	addi	a0,a0,-494 # 80008560 <syscalls+0x190>
    80003756:	ffffd097          	auipc	ra,0xffffd
    8000375a:	e1e080e7          	jalr	-482(ra) # 80000574 <panic>
      memset(dip, 0, sizeof(*dip));
    8000375e:	04000613          	li	a2,64
    80003762:	4581                	li	a1,0
    80003764:	854a                	mv	a0,s2
    80003766:	ffffd097          	auipc	ra,0xffffd
    8000376a:	5f8080e7          	jalr	1528(ra) # 80000d5e <memset>
      dip->type = type;
    8000376e:	01691023          	sh	s6,0(s2)
      log_write(bp);   // mark it allocated on the disk
    80003772:	855e                	mv	a0,s7
    80003774:	00001097          	auipc	ra,0x1
    80003778:	ca8080e7          	jalr	-856(ra) # 8000441c <log_write>
      brelse(bp);
    8000377c:	855e                	mv	a0,s7
    8000377e:	00000097          	auipc	ra,0x0
    80003782:	9f0080e7          	jalr	-1552(ra) # 8000316e <brelse>
      return iget(dev, inum);
    80003786:	85d6                	mv	a1,s5
    80003788:	8552                	mv	a0,s4
    8000378a:	00000097          	auipc	ra,0x0
    8000378e:	db4080e7          	jalr	-588(ra) # 8000353e <iget>
}
    80003792:	60a6                	ld	ra,72(sp)
    80003794:	6406                	ld	s0,64(sp)
    80003796:	74e2                	ld	s1,56(sp)
    80003798:	7942                	ld	s2,48(sp)
    8000379a:	79a2                	ld	s3,40(sp)
    8000379c:	7a02                	ld	s4,32(sp)
    8000379e:	6ae2                	ld	s5,24(sp)
    800037a0:	6b42                	ld	s6,16(sp)
    800037a2:	6ba2                	ld	s7,8(sp)
    800037a4:	6161                	addi	sp,sp,80
    800037a6:	8082                	ret

00000000800037a8 <iupdate>:
{
    800037a8:	1101                	addi	sp,sp,-32
    800037aa:	ec06                	sd	ra,24(sp)
    800037ac:	e822                	sd	s0,16(sp)
    800037ae:	e426                	sd	s1,8(sp)
    800037b0:	e04a                	sd	s2,0(sp)
    800037b2:	1000                	addi	s0,sp,32
    800037b4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037b6:	415c                	lw	a5,4(a0)
    800037b8:	0047d79b          	srliw	a5,a5,0x4
    800037bc:	0001c717          	auipc	a4,0x1c
    800037c0:	68470713          	addi	a4,a4,1668 # 8001fe40 <sb>
    800037c4:	4f0c                	lw	a1,24(a4)
    800037c6:	9dbd                	addw	a1,a1,a5
    800037c8:	4108                	lw	a0,0(a0)
    800037ca:	00000097          	auipc	ra,0x0
    800037ce:	862080e7          	jalr	-1950(ra) # 8000302c <bread>
    800037d2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037d4:	05850513          	addi	a0,a0,88
    800037d8:	40dc                	lw	a5,4(s1)
    800037da:	8bbd                	andi	a5,a5,15
    800037dc:	079a                	slli	a5,a5,0x6
    800037de:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800037e0:	04449783          	lh	a5,68(s1)
    800037e4:	00f51023          	sh	a5,0(a0)
  dip->major = ip->major;
    800037e8:	04649783          	lh	a5,70(s1)
    800037ec:	00f51123          	sh	a5,2(a0)
  dip->minor = ip->minor;
    800037f0:	04849783          	lh	a5,72(s1)
    800037f4:	00f51223          	sh	a5,4(a0)
  dip->nlink = ip->nlink;
    800037f8:	04a49783          	lh	a5,74(s1)
    800037fc:	00f51323          	sh	a5,6(a0)
  dip->size = ip->size;
    80003800:	44fc                	lw	a5,76(s1)
    80003802:	c51c                	sw	a5,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003804:	03400613          	li	a2,52
    80003808:	05048593          	addi	a1,s1,80
    8000380c:	0531                	addi	a0,a0,12
    8000380e:	ffffd097          	auipc	ra,0xffffd
    80003812:	5bc080e7          	jalr	1468(ra) # 80000dca <memmove>
  log_write(bp);
    80003816:	854a                	mv	a0,s2
    80003818:	00001097          	auipc	ra,0x1
    8000381c:	c04080e7          	jalr	-1020(ra) # 8000441c <log_write>
  brelse(bp);
    80003820:	854a                	mv	a0,s2
    80003822:	00000097          	auipc	ra,0x0
    80003826:	94c080e7          	jalr	-1716(ra) # 8000316e <brelse>
}
    8000382a:	60e2                	ld	ra,24(sp)
    8000382c:	6442                	ld	s0,16(sp)
    8000382e:	64a2                	ld	s1,8(sp)
    80003830:	6902                	ld	s2,0(sp)
    80003832:	6105                	addi	sp,sp,32
    80003834:	8082                	ret

0000000080003836 <idup>:
{
    80003836:	1101                	addi	sp,sp,-32
    80003838:	ec06                	sd	ra,24(sp)
    8000383a:	e822                	sd	s0,16(sp)
    8000383c:	e426                	sd	s1,8(sp)
    8000383e:	1000                	addi	s0,sp,32
    80003840:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003842:	0001c517          	auipc	a0,0x1c
    80003846:	61e50513          	addi	a0,a0,1566 # 8001fe60 <icache>
    8000384a:	ffffd097          	auipc	ra,0xffffd
    8000384e:	418080e7          	jalr	1048(ra) # 80000c62 <acquire>
  ip->ref++;
    80003852:	449c                	lw	a5,8(s1)
    80003854:	2785                	addiw	a5,a5,1
    80003856:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003858:	0001c517          	auipc	a0,0x1c
    8000385c:	60850513          	addi	a0,a0,1544 # 8001fe60 <icache>
    80003860:	ffffd097          	auipc	ra,0xffffd
    80003864:	4b6080e7          	jalr	1206(ra) # 80000d16 <release>
}
    80003868:	8526                	mv	a0,s1
    8000386a:	60e2                	ld	ra,24(sp)
    8000386c:	6442                	ld	s0,16(sp)
    8000386e:	64a2                	ld	s1,8(sp)
    80003870:	6105                	addi	sp,sp,32
    80003872:	8082                	ret

0000000080003874 <ilock>:
{
    80003874:	1101                	addi	sp,sp,-32
    80003876:	ec06                	sd	ra,24(sp)
    80003878:	e822                	sd	s0,16(sp)
    8000387a:	e426                	sd	s1,8(sp)
    8000387c:	e04a                	sd	s2,0(sp)
    8000387e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003880:	c115                	beqz	a0,800038a4 <ilock+0x30>
    80003882:	84aa                	mv	s1,a0
    80003884:	451c                	lw	a5,8(a0)
    80003886:	00f05f63          	blez	a5,800038a4 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000388a:	0541                	addi	a0,a0,16
    8000388c:	00001097          	auipc	ra,0x1
    80003890:	cce080e7          	jalr	-818(ra) # 8000455a <acquiresleep>
  if(ip->valid == 0){
    80003894:	40bc                	lw	a5,64(s1)
    80003896:	cf99                	beqz	a5,800038b4 <ilock+0x40>
}
    80003898:	60e2                	ld	ra,24(sp)
    8000389a:	6442                	ld	s0,16(sp)
    8000389c:	64a2                	ld	s1,8(sp)
    8000389e:	6902                	ld	s2,0(sp)
    800038a0:	6105                	addi	sp,sp,32
    800038a2:	8082                	ret
    panic("ilock");
    800038a4:	00005517          	auipc	a0,0x5
    800038a8:	cd450513          	addi	a0,a0,-812 # 80008578 <syscalls+0x1a8>
    800038ac:	ffffd097          	auipc	ra,0xffffd
    800038b0:	cc8080e7          	jalr	-824(ra) # 80000574 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038b4:	40dc                	lw	a5,4(s1)
    800038b6:	0047d79b          	srliw	a5,a5,0x4
    800038ba:	0001c717          	auipc	a4,0x1c
    800038be:	58670713          	addi	a4,a4,1414 # 8001fe40 <sb>
    800038c2:	4f0c                	lw	a1,24(a4)
    800038c4:	9dbd                	addw	a1,a1,a5
    800038c6:	4088                	lw	a0,0(s1)
    800038c8:	fffff097          	auipc	ra,0xfffff
    800038cc:	764080e7          	jalr	1892(ra) # 8000302c <bread>
    800038d0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038d2:	05850593          	addi	a1,a0,88
    800038d6:	40dc                	lw	a5,4(s1)
    800038d8:	8bbd                	andi	a5,a5,15
    800038da:	079a                	slli	a5,a5,0x6
    800038dc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038de:	00059783          	lh	a5,0(a1)
    800038e2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038e6:	00259783          	lh	a5,2(a1)
    800038ea:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800038ee:	00459783          	lh	a5,4(a1)
    800038f2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800038f6:	00659783          	lh	a5,6(a1)
    800038fa:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800038fe:	459c                	lw	a5,8(a1)
    80003900:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003902:	03400613          	li	a2,52
    80003906:	05b1                	addi	a1,a1,12
    80003908:	05048513          	addi	a0,s1,80
    8000390c:	ffffd097          	auipc	ra,0xffffd
    80003910:	4be080e7          	jalr	1214(ra) # 80000dca <memmove>
    brelse(bp);
    80003914:	854a                	mv	a0,s2
    80003916:	00000097          	auipc	ra,0x0
    8000391a:	858080e7          	jalr	-1960(ra) # 8000316e <brelse>
    ip->valid = 1;
    8000391e:	4785                	li	a5,1
    80003920:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003922:	04449783          	lh	a5,68(s1)
    80003926:	fbad                	bnez	a5,80003898 <ilock+0x24>
      panic("ilock: no type");
    80003928:	00005517          	auipc	a0,0x5
    8000392c:	c5850513          	addi	a0,a0,-936 # 80008580 <syscalls+0x1b0>
    80003930:	ffffd097          	auipc	ra,0xffffd
    80003934:	c44080e7          	jalr	-956(ra) # 80000574 <panic>

0000000080003938 <iunlock>:
{
    80003938:	1101                	addi	sp,sp,-32
    8000393a:	ec06                	sd	ra,24(sp)
    8000393c:	e822                	sd	s0,16(sp)
    8000393e:	e426                	sd	s1,8(sp)
    80003940:	e04a                	sd	s2,0(sp)
    80003942:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003944:	c905                	beqz	a0,80003974 <iunlock+0x3c>
    80003946:	84aa                	mv	s1,a0
    80003948:	01050913          	addi	s2,a0,16
    8000394c:	854a                	mv	a0,s2
    8000394e:	00001097          	auipc	ra,0x1
    80003952:	ca6080e7          	jalr	-858(ra) # 800045f4 <holdingsleep>
    80003956:	cd19                	beqz	a0,80003974 <iunlock+0x3c>
    80003958:	449c                	lw	a5,8(s1)
    8000395a:	00f05d63          	blez	a5,80003974 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000395e:	854a                	mv	a0,s2
    80003960:	00001097          	auipc	ra,0x1
    80003964:	c50080e7          	jalr	-944(ra) # 800045b0 <releasesleep>
}
    80003968:	60e2                	ld	ra,24(sp)
    8000396a:	6442                	ld	s0,16(sp)
    8000396c:	64a2                	ld	s1,8(sp)
    8000396e:	6902                	ld	s2,0(sp)
    80003970:	6105                	addi	sp,sp,32
    80003972:	8082                	ret
    panic("iunlock");
    80003974:	00005517          	auipc	a0,0x5
    80003978:	c1c50513          	addi	a0,a0,-996 # 80008590 <syscalls+0x1c0>
    8000397c:	ffffd097          	auipc	ra,0xffffd
    80003980:	bf8080e7          	jalr	-1032(ra) # 80000574 <panic>

0000000080003984 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003984:	7179                	addi	sp,sp,-48
    80003986:	f406                	sd	ra,40(sp)
    80003988:	f022                	sd	s0,32(sp)
    8000398a:	ec26                	sd	s1,24(sp)
    8000398c:	e84a                	sd	s2,16(sp)
    8000398e:	e44e                	sd	s3,8(sp)
    80003990:	e052                	sd	s4,0(sp)
    80003992:	1800                	addi	s0,sp,48
    80003994:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003996:	05050493          	addi	s1,a0,80
    8000399a:	08050913          	addi	s2,a0,128
    8000399e:	a821                	j	800039b6 <itrunc+0x32>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    800039a0:	0009a503          	lw	a0,0(s3)
    800039a4:	00000097          	auipc	ra,0x0
    800039a8:	8e0080e7          	jalr	-1824(ra) # 80003284 <bfree>
      ip->addrs[i] = 0;
    800039ac:	0004a023          	sw	zero,0(s1)
  for(i = 0; i < NDIRECT; i++){
    800039b0:	0491                	addi	s1,s1,4
    800039b2:	01248563          	beq	s1,s2,800039bc <itrunc+0x38>
    if(ip->addrs[i]){
    800039b6:	408c                	lw	a1,0(s1)
    800039b8:	dde5                	beqz	a1,800039b0 <itrunc+0x2c>
    800039ba:	b7dd                	j	800039a0 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039bc:	0809a583          	lw	a1,128(s3)
    800039c0:	e185                	bnez	a1,800039e0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039c2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039c6:	854e                	mv	a0,s3
    800039c8:	00000097          	auipc	ra,0x0
    800039cc:	de0080e7          	jalr	-544(ra) # 800037a8 <iupdate>
}
    800039d0:	70a2                	ld	ra,40(sp)
    800039d2:	7402                	ld	s0,32(sp)
    800039d4:	64e2                	ld	s1,24(sp)
    800039d6:	6942                	ld	s2,16(sp)
    800039d8:	69a2                	ld	s3,8(sp)
    800039da:	6a02                	ld	s4,0(sp)
    800039dc:	6145                	addi	sp,sp,48
    800039de:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039e0:	0009a503          	lw	a0,0(s3)
    800039e4:	fffff097          	auipc	ra,0xfffff
    800039e8:	648080e7          	jalr	1608(ra) # 8000302c <bread>
    800039ec:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039ee:	05850493          	addi	s1,a0,88
    800039f2:	45850913          	addi	s2,a0,1112
    800039f6:	a811                	j	80003a0a <itrunc+0x86>
        bfree(ip->dev, a[j]);
    800039f8:	0009a503          	lw	a0,0(s3)
    800039fc:	00000097          	auipc	ra,0x0
    80003a00:	888080e7          	jalr	-1912(ra) # 80003284 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003a04:	0491                	addi	s1,s1,4
    80003a06:	01248563          	beq	s1,s2,80003a10 <itrunc+0x8c>
      if(a[j])
    80003a0a:	408c                	lw	a1,0(s1)
    80003a0c:	dde5                	beqz	a1,80003a04 <itrunc+0x80>
    80003a0e:	b7ed                	j	800039f8 <itrunc+0x74>
    brelse(bp);
    80003a10:	8552                	mv	a0,s4
    80003a12:	fffff097          	auipc	ra,0xfffff
    80003a16:	75c080e7          	jalr	1884(ra) # 8000316e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a1a:	0809a583          	lw	a1,128(s3)
    80003a1e:	0009a503          	lw	a0,0(s3)
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	862080e7          	jalr	-1950(ra) # 80003284 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a2a:	0809a023          	sw	zero,128(s3)
    80003a2e:	bf51                	j	800039c2 <itrunc+0x3e>

0000000080003a30 <iput>:
{
    80003a30:	1101                	addi	sp,sp,-32
    80003a32:	ec06                	sd	ra,24(sp)
    80003a34:	e822                	sd	s0,16(sp)
    80003a36:	e426                	sd	s1,8(sp)
    80003a38:	e04a                	sd	s2,0(sp)
    80003a3a:	1000                	addi	s0,sp,32
    80003a3c:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003a3e:	0001c517          	auipc	a0,0x1c
    80003a42:	42250513          	addi	a0,a0,1058 # 8001fe60 <icache>
    80003a46:	ffffd097          	auipc	ra,0xffffd
    80003a4a:	21c080e7          	jalr	540(ra) # 80000c62 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a4e:	4498                	lw	a4,8(s1)
    80003a50:	4785                	li	a5,1
    80003a52:	02f70363          	beq	a4,a5,80003a78 <iput+0x48>
  ip->ref--;
    80003a56:	449c                	lw	a5,8(s1)
    80003a58:	37fd                	addiw	a5,a5,-1
    80003a5a:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003a5c:	0001c517          	auipc	a0,0x1c
    80003a60:	40450513          	addi	a0,a0,1028 # 8001fe60 <icache>
    80003a64:	ffffd097          	auipc	ra,0xffffd
    80003a68:	2b2080e7          	jalr	690(ra) # 80000d16 <release>
}
    80003a6c:	60e2                	ld	ra,24(sp)
    80003a6e:	6442                	ld	s0,16(sp)
    80003a70:	64a2                	ld	s1,8(sp)
    80003a72:	6902                	ld	s2,0(sp)
    80003a74:	6105                	addi	sp,sp,32
    80003a76:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a78:	40bc                	lw	a5,64(s1)
    80003a7a:	dff1                	beqz	a5,80003a56 <iput+0x26>
    80003a7c:	04a49783          	lh	a5,74(s1)
    80003a80:	fbf9                	bnez	a5,80003a56 <iput+0x26>
    acquiresleep(&ip->lock);
    80003a82:	01048913          	addi	s2,s1,16
    80003a86:	854a                	mv	a0,s2
    80003a88:	00001097          	auipc	ra,0x1
    80003a8c:	ad2080e7          	jalr	-1326(ra) # 8000455a <acquiresleep>
    release(&icache.lock);
    80003a90:	0001c517          	auipc	a0,0x1c
    80003a94:	3d050513          	addi	a0,a0,976 # 8001fe60 <icache>
    80003a98:	ffffd097          	auipc	ra,0xffffd
    80003a9c:	27e080e7          	jalr	638(ra) # 80000d16 <release>
    itrunc(ip);
    80003aa0:	8526                	mv	a0,s1
    80003aa2:	00000097          	auipc	ra,0x0
    80003aa6:	ee2080e7          	jalr	-286(ra) # 80003984 <itrunc>
    ip->type = 0;
    80003aaa:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003aae:	8526                	mv	a0,s1
    80003ab0:	00000097          	auipc	ra,0x0
    80003ab4:	cf8080e7          	jalr	-776(ra) # 800037a8 <iupdate>
    ip->valid = 0;
    80003ab8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003abc:	854a                	mv	a0,s2
    80003abe:	00001097          	auipc	ra,0x1
    80003ac2:	af2080e7          	jalr	-1294(ra) # 800045b0 <releasesleep>
    acquire(&icache.lock);
    80003ac6:	0001c517          	auipc	a0,0x1c
    80003aca:	39a50513          	addi	a0,a0,922 # 8001fe60 <icache>
    80003ace:	ffffd097          	auipc	ra,0xffffd
    80003ad2:	194080e7          	jalr	404(ra) # 80000c62 <acquire>
    80003ad6:	b741                	j	80003a56 <iput+0x26>

0000000080003ad8 <iunlockput>:
{
    80003ad8:	1101                	addi	sp,sp,-32
    80003ada:	ec06                	sd	ra,24(sp)
    80003adc:	e822                	sd	s0,16(sp)
    80003ade:	e426                	sd	s1,8(sp)
    80003ae0:	1000                	addi	s0,sp,32
    80003ae2:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ae4:	00000097          	auipc	ra,0x0
    80003ae8:	e54080e7          	jalr	-428(ra) # 80003938 <iunlock>
  iput(ip);
    80003aec:	8526                	mv	a0,s1
    80003aee:	00000097          	auipc	ra,0x0
    80003af2:	f42080e7          	jalr	-190(ra) # 80003a30 <iput>
}
    80003af6:	60e2                	ld	ra,24(sp)
    80003af8:	6442                	ld	s0,16(sp)
    80003afa:	64a2                	ld	s1,8(sp)
    80003afc:	6105                	addi	sp,sp,32
    80003afe:	8082                	ret

0000000080003b00 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b00:	1141                	addi	sp,sp,-16
    80003b02:	e422                	sd	s0,8(sp)
    80003b04:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b06:	411c                	lw	a5,0(a0)
    80003b08:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b0a:	415c                	lw	a5,4(a0)
    80003b0c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b0e:	04451783          	lh	a5,68(a0)
    80003b12:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b16:	04a51783          	lh	a5,74(a0)
    80003b1a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b1e:	04c56783          	lwu	a5,76(a0)
    80003b22:	e99c                	sd	a5,16(a1)
}
    80003b24:	6422                	ld	s0,8(sp)
    80003b26:	0141                	addi	sp,sp,16
    80003b28:	8082                	ret

0000000080003b2a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b2a:	457c                	lw	a5,76(a0)
    80003b2c:	0ed7e963          	bltu	a5,a3,80003c1e <readi+0xf4>
{
    80003b30:	7159                	addi	sp,sp,-112
    80003b32:	f486                	sd	ra,104(sp)
    80003b34:	f0a2                	sd	s0,96(sp)
    80003b36:	eca6                	sd	s1,88(sp)
    80003b38:	e8ca                	sd	s2,80(sp)
    80003b3a:	e4ce                	sd	s3,72(sp)
    80003b3c:	e0d2                	sd	s4,64(sp)
    80003b3e:	fc56                	sd	s5,56(sp)
    80003b40:	f85a                	sd	s6,48(sp)
    80003b42:	f45e                	sd	s7,40(sp)
    80003b44:	f062                	sd	s8,32(sp)
    80003b46:	ec66                	sd	s9,24(sp)
    80003b48:	e86a                	sd	s10,16(sp)
    80003b4a:	e46e                	sd	s11,8(sp)
    80003b4c:	1880                	addi	s0,sp,112
    80003b4e:	8baa                	mv	s7,a0
    80003b50:	8c2e                	mv	s8,a1
    80003b52:	8a32                	mv	s4,a2
    80003b54:	84b6                	mv	s1,a3
    80003b56:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b58:	9f35                	addw	a4,a4,a3
    return 0;
    80003b5a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b5c:	0ad76063          	bltu	a4,a3,80003bfc <readi+0xd2>
  if(off + n > ip->size)
    80003b60:	00e7f463          	bleu	a4,a5,80003b68 <readi+0x3e>
    n = ip->size - off;
    80003b64:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b68:	0a0b0963          	beqz	s6,80003c1a <readi+0xf0>
    80003b6c:	4901                	li	s2,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b6e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b72:	5cfd                	li	s9,-1
    80003b74:	a82d                	j	80003bae <readi+0x84>
    80003b76:	02099d93          	slli	s11,s3,0x20
    80003b7a:	020ddd93          	srli	s11,s11,0x20
    80003b7e:	058a8613          	addi	a2,s5,88
    80003b82:	86ee                	mv	a3,s11
    80003b84:	963a                	add	a2,a2,a4
    80003b86:	85d2                	mv	a1,s4
    80003b88:	8562                	mv	a0,s8
    80003b8a:	fffff097          	auipc	ra,0xfffff
    80003b8e:	a96080e7          	jalr	-1386(ra) # 80002620 <either_copyout>
    80003b92:	05950d63          	beq	a0,s9,80003bec <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b96:	8556                	mv	a0,s5
    80003b98:	fffff097          	auipc	ra,0xfffff
    80003b9c:	5d6080e7          	jalr	1494(ra) # 8000316e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ba0:	0129893b          	addw	s2,s3,s2
    80003ba4:	009984bb          	addw	s1,s3,s1
    80003ba8:	9a6e                	add	s4,s4,s11
    80003baa:	05697763          	bleu	s6,s2,80003bf8 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003bae:	000ba983          	lw	s3,0(s7)
    80003bb2:	00a4d59b          	srliw	a1,s1,0xa
    80003bb6:	855e                	mv	a0,s7
    80003bb8:	00000097          	auipc	ra,0x0
    80003bbc:	8ac080e7          	jalr	-1876(ra) # 80003464 <bmap>
    80003bc0:	0005059b          	sext.w	a1,a0
    80003bc4:	854e                	mv	a0,s3
    80003bc6:	fffff097          	auipc	ra,0xfffff
    80003bca:	466080e7          	jalr	1126(ra) # 8000302c <bread>
    80003bce:	8aaa                	mv	s5,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bd0:	3ff4f713          	andi	a4,s1,1023
    80003bd4:	40ed07bb          	subw	a5,s10,a4
    80003bd8:	412b06bb          	subw	a3,s6,s2
    80003bdc:	89be                	mv	s3,a5
    80003bde:	2781                	sext.w	a5,a5
    80003be0:	0006861b          	sext.w	a2,a3
    80003be4:	f8f679e3          	bleu	a5,a2,80003b76 <readi+0x4c>
    80003be8:	89b6                	mv	s3,a3
    80003bea:	b771                	j	80003b76 <readi+0x4c>
      brelse(bp);
    80003bec:	8556                	mv	a0,s5
    80003bee:	fffff097          	auipc	ra,0xfffff
    80003bf2:	580080e7          	jalr	1408(ra) # 8000316e <brelse>
      tot = -1;
    80003bf6:	597d                	li	s2,-1
  }
  return tot;
    80003bf8:	0009051b          	sext.w	a0,s2
}
    80003bfc:	70a6                	ld	ra,104(sp)
    80003bfe:	7406                	ld	s0,96(sp)
    80003c00:	64e6                	ld	s1,88(sp)
    80003c02:	6946                	ld	s2,80(sp)
    80003c04:	69a6                	ld	s3,72(sp)
    80003c06:	6a06                	ld	s4,64(sp)
    80003c08:	7ae2                	ld	s5,56(sp)
    80003c0a:	7b42                	ld	s6,48(sp)
    80003c0c:	7ba2                	ld	s7,40(sp)
    80003c0e:	7c02                	ld	s8,32(sp)
    80003c10:	6ce2                	ld	s9,24(sp)
    80003c12:	6d42                	ld	s10,16(sp)
    80003c14:	6da2                	ld	s11,8(sp)
    80003c16:	6165                	addi	sp,sp,112
    80003c18:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c1a:	895a                	mv	s2,s6
    80003c1c:	bff1                	j	80003bf8 <readi+0xce>
    return 0;
    80003c1e:	4501                	li	a0,0
}
    80003c20:	8082                	ret

0000000080003c22 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c22:	457c                	lw	a5,76(a0)
    80003c24:	10d7e763          	bltu	a5,a3,80003d32 <writei+0x110>
{
    80003c28:	7159                	addi	sp,sp,-112
    80003c2a:	f486                	sd	ra,104(sp)
    80003c2c:	f0a2                	sd	s0,96(sp)
    80003c2e:	eca6                	sd	s1,88(sp)
    80003c30:	e8ca                	sd	s2,80(sp)
    80003c32:	e4ce                	sd	s3,72(sp)
    80003c34:	e0d2                	sd	s4,64(sp)
    80003c36:	fc56                	sd	s5,56(sp)
    80003c38:	f85a                	sd	s6,48(sp)
    80003c3a:	f45e                	sd	s7,40(sp)
    80003c3c:	f062                	sd	s8,32(sp)
    80003c3e:	ec66                	sd	s9,24(sp)
    80003c40:	e86a                	sd	s10,16(sp)
    80003c42:	e46e                	sd	s11,8(sp)
    80003c44:	1880                	addi	s0,sp,112
    80003c46:	8baa                	mv	s7,a0
    80003c48:	8c2e                	mv	s8,a1
    80003c4a:	8ab2                	mv	s5,a2
    80003c4c:	84b6                	mv	s1,a3
    80003c4e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c50:	00e687bb          	addw	a5,a3,a4
    80003c54:	0ed7e163          	bltu	a5,a3,80003d36 <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c58:	00043737          	lui	a4,0x43
    80003c5c:	0cf76f63          	bltu	a4,a5,80003d3a <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c60:	0a0b0863          	beqz	s6,80003d10 <writei+0xee>
    80003c64:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c66:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c6a:	5cfd                	li	s9,-1
    80003c6c:	a091                	j	80003cb0 <writei+0x8e>
    80003c6e:	02091d93          	slli	s11,s2,0x20
    80003c72:	020ddd93          	srli	s11,s11,0x20
    80003c76:	05898513          	addi	a0,s3,88
    80003c7a:	86ee                	mv	a3,s11
    80003c7c:	8656                	mv	a2,s5
    80003c7e:	85e2                	mv	a1,s8
    80003c80:	953a                	add	a0,a0,a4
    80003c82:	fffff097          	auipc	ra,0xfffff
    80003c86:	9f4080e7          	jalr	-1548(ra) # 80002676 <either_copyin>
    80003c8a:	07950263          	beq	a0,s9,80003cee <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80003c8e:	854e                	mv	a0,s3
    80003c90:	00000097          	auipc	ra,0x0
    80003c94:	78c080e7          	jalr	1932(ra) # 8000441c <log_write>
    brelse(bp);
    80003c98:	854e                	mv	a0,s3
    80003c9a:	fffff097          	auipc	ra,0xfffff
    80003c9e:	4d4080e7          	jalr	1236(ra) # 8000316e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ca2:	01490a3b          	addw	s4,s2,s4
    80003ca6:	009904bb          	addw	s1,s2,s1
    80003caa:	9aee                	add	s5,s5,s11
    80003cac:	056a7763          	bleu	s6,s4,80003cfa <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003cb0:	000ba903          	lw	s2,0(s7)
    80003cb4:	00a4d59b          	srliw	a1,s1,0xa
    80003cb8:	855e                	mv	a0,s7
    80003cba:	fffff097          	auipc	ra,0xfffff
    80003cbe:	7aa080e7          	jalr	1962(ra) # 80003464 <bmap>
    80003cc2:	0005059b          	sext.w	a1,a0
    80003cc6:	854a                	mv	a0,s2
    80003cc8:	fffff097          	auipc	ra,0xfffff
    80003ccc:	364080e7          	jalr	868(ra) # 8000302c <bread>
    80003cd0:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cd2:	3ff4f713          	andi	a4,s1,1023
    80003cd6:	40ed07bb          	subw	a5,s10,a4
    80003cda:	414b06bb          	subw	a3,s6,s4
    80003cde:	893e                	mv	s2,a5
    80003ce0:	2781                	sext.w	a5,a5
    80003ce2:	0006861b          	sext.w	a2,a3
    80003ce6:	f8f674e3          	bleu	a5,a2,80003c6e <writei+0x4c>
    80003cea:	8936                	mv	s2,a3
    80003cec:	b749                	j	80003c6e <writei+0x4c>
      brelse(bp);
    80003cee:	854e                	mv	a0,s3
    80003cf0:	fffff097          	auipc	ra,0xfffff
    80003cf4:	47e080e7          	jalr	1150(ra) # 8000316e <brelse>
      n = -1;
    80003cf8:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003cfa:	04cba783          	lw	a5,76(s7)
    80003cfe:	0097f463          	bleu	s1,a5,80003d06 <writei+0xe4>
      ip->size = off;
    80003d02:	049ba623          	sw	s1,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003d06:	855e                	mv	a0,s7
    80003d08:	00000097          	auipc	ra,0x0
    80003d0c:	aa0080e7          	jalr	-1376(ra) # 800037a8 <iupdate>
  }

  return n;
    80003d10:	000b051b          	sext.w	a0,s6
}
    80003d14:	70a6                	ld	ra,104(sp)
    80003d16:	7406                	ld	s0,96(sp)
    80003d18:	64e6                	ld	s1,88(sp)
    80003d1a:	6946                	ld	s2,80(sp)
    80003d1c:	69a6                	ld	s3,72(sp)
    80003d1e:	6a06                	ld	s4,64(sp)
    80003d20:	7ae2                	ld	s5,56(sp)
    80003d22:	7b42                	ld	s6,48(sp)
    80003d24:	7ba2                	ld	s7,40(sp)
    80003d26:	7c02                	ld	s8,32(sp)
    80003d28:	6ce2                	ld	s9,24(sp)
    80003d2a:	6d42                	ld	s10,16(sp)
    80003d2c:	6da2                	ld	s11,8(sp)
    80003d2e:	6165                	addi	sp,sp,112
    80003d30:	8082                	ret
    return -1;
    80003d32:	557d                	li	a0,-1
}
    80003d34:	8082                	ret
    return -1;
    80003d36:	557d                	li	a0,-1
    80003d38:	bff1                	j	80003d14 <writei+0xf2>
    return -1;
    80003d3a:	557d                	li	a0,-1
    80003d3c:	bfe1                	j	80003d14 <writei+0xf2>

0000000080003d3e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d3e:	1141                	addi	sp,sp,-16
    80003d40:	e406                	sd	ra,8(sp)
    80003d42:	e022                	sd	s0,0(sp)
    80003d44:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d46:	4639                	li	a2,14
    80003d48:	ffffd097          	auipc	ra,0xffffd
    80003d4c:	0fe080e7          	jalr	254(ra) # 80000e46 <strncmp>
}
    80003d50:	60a2                	ld	ra,8(sp)
    80003d52:	6402                	ld	s0,0(sp)
    80003d54:	0141                	addi	sp,sp,16
    80003d56:	8082                	ret

0000000080003d58 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d58:	7139                	addi	sp,sp,-64
    80003d5a:	fc06                	sd	ra,56(sp)
    80003d5c:	f822                	sd	s0,48(sp)
    80003d5e:	f426                	sd	s1,40(sp)
    80003d60:	f04a                	sd	s2,32(sp)
    80003d62:	ec4e                	sd	s3,24(sp)
    80003d64:	e852                	sd	s4,16(sp)
    80003d66:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d68:	04451703          	lh	a4,68(a0)
    80003d6c:	4785                	li	a5,1
    80003d6e:	00f71a63          	bne	a4,a5,80003d82 <dirlookup+0x2a>
    80003d72:	892a                	mv	s2,a0
    80003d74:	89ae                	mv	s3,a1
    80003d76:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d78:	457c                	lw	a5,76(a0)
    80003d7a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d7c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d7e:	e79d                	bnez	a5,80003dac <dirlookup+0x54>
    80003d80:	a8a5                	j	80003df8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d82:	00005517          	auipc	a0,0x5
    80003d86:	81650513          	addi	a0,a0,-2026 # 80008598 <syscalls+0x1c8>
    80003d8a:	ffffc097          	auipc	ra,0xffffc
    80003d8e:	7ea080e7          	jalr	2026(ra) # 80000574 <panic>
      panic("dirlookup read");
    80003d92:	00005517          	auipc	a0,0x5
    80003d96:	81e50513          	addi	a0,a0,-2018 # 800085b0 <syscalls+0x1e0>
    80003d9a:	ffffc097          	auipc	ra,0xffffc
    80003d9e:	7da080e7          	jalr	2010(ra) # 80000574 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003da2:	24c1                	addiw	s1,s1,16
    80003da4:	04c92783          	lw	a5,76(s2)
    80003da8:	04f4f763          	bleu	a5,s1,80003df6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dac:	4741                	li	a4,16
    80003dae:	86a6                	mv	a3,s1
    80003db0:	fc040613          	addi	a2,s0,-64
    80003db4:	4581                	li	a1,0
    80003db6:	854a                	mv	a0,s2
    80003db8:	00000097          	auipc	ra,0x0
    80003dbc:	d72080e7          	jalr	-654(ra) # 80003b2a <readi>
    80003dc0:	47c1                	li	a5,16
    80003dc2:	fcf518e3          	bne	a0,a5,80003d92 <dirlookup+0x3a>
    if(de.inum == 0)
    80003dc6:	fc045783          	lhu	a5,-64(s0)
    80003dca:	dfe1                	beqz	a5,80003da2 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003dcc:	fc240593          	addi	a1,s0,-62
    80003dd0:	854e                	mv	a0,s3
    80003dd2:	00000097          	auipc	ra,0x0
    80003dd6:	f6c080e7          	jalr	-148(ra) # 80003d3e <namecmp>
    80003dda:	f561                	bnez	a0,80003da2 <dirlookup+0x4a>
      if(poff)
    80003ddc:	000a0463          	beqz	s4,80003de4 <dirlookup+0x8c>
        *poff = off;
    80003de0:	009a2023          	sw	s1,0(s4) # 2000 <_entry-0x7fffe000>
      return iget(dp->dev, inum);
    80003de4:	fc045583          	lhu	a1,-64(s0)
    80003de8:	00092503          	lw	a0,0(s2)
    80003dec:	fffff097          	auipc	ra,0xfffff
    80003df0:	752080e7          	jalr	1874(ra) # 8000353e <iget>
    80003df4:	a011                	j	80003df8 <dirlookup+0xa0>
  return 0;
    80003df6:	4501                	li	a0,0
}
    80003df8:	70e2                	ld	ra,56(sp)
    80003dfa:	7442                	ld	s0,48(sp)
    80003dfc:	74a2                	ld	s1,40(sp)
    80003dfe:	7902                	ld	s2,32(sp)
    80003e00:	69e2                	ld	s3,24(sp)
    80003e02:	6a42                	ld	s4,16(sp)
    80003e04:	6121                	addi	sp,sp,64
    80003e06:	8082                	ret

0000000080003e08 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e08:	711d                	addi	sp,sp,-96
    80003e0a:	ec86                	sd	ra,88(sp)
    80003e0c:	e8a2                	sd	s0,80(sp)
    80003e0e:	e4a6                	sd	s1,72(sp)
    80003e10:	e0ca                	sd	s2,64(sp)
    80003e12:	fc4e                	sd	s3,56(sp)
    80003e14:	f852                	sd	s4,48(sp)
    80003e16:	f456                	sd	s5,40(sp)
    80003e18:	f05a                	sd	s6,32(sp)
    80003e1a:	ec5e                	sd	s7,24(sp)
    80003e1c:	e862                	sd	s8,16(sp)
    80003e1e:	e466                	sd	s9,8(sp)
    80003e20:	1080                	addi	s0,sp,96
    80003e22:	84aa                	mv	s1,a0
    80003e24:	8bae                	mv	s7,a1
    80003e26:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e28:	00054703          	lbu	a4,0(a0)
    80003e2c:	02f00793          	li	a5,47
    80003e30:	02f70363          	beq	a4,a5,80003e56 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e34:	ffffe097          	auipc	ra,0xffffe
    80003e38:	d70080e7          	jalr	-656(ra) # 80001ba4 <myproc>
    80003e3c:	15053503          	ld	a0,336(a0)
    80003e40:	00000097          	auipc	ra,0x0
    80003e44:	9f6080e7          	jalr	-1546(ra) # 80003836 <idup>
    80003e48:	89aa                	mv	s3,a0
  while(*path == '/')
    80003e4a:	02f00913          	li	s2,47
  len = path - s;
    80003e4e:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003e50:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e52:	4c05                	li	s8,1
    80003e54:	a865                	j	80003f0c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003e56:	4585                	li	a1,1
    80003e58:	4505                	li	a0,1
    80003e5a:	fffff097          	auipc	ra,0xfffff
    80003e5e:	6e4080e7          	jalr	1764(ra) # 8000353e <iget>
    80003e62:	89aa                	mv	s3,a0
    80003e64:	b7dd                	j	80003e4a <namex+0x42>
      iunlockput(ip);
    80003e66:	854e                	mv	a0,s3
    80003e68:	00000097          	auipc	ra,0x0
    80003e6c:	c70080e7          	jalr	-912(ra) # 80003ad8 <iunlockput>
      return 0;
    80003e70:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e72:	854e                	mv	a0,s3
    80003e74:	60e6                	ld	ra,88(sp)
    80003e76:	6446                	ld	s0,80(sp)
    80003e78:	64a6                	ld	s1,72(sp)
    80003e7a:	6906                	ld	s2,64(sp)
    80003e7c:	79e2                	ld	s3,56(sp)
    80003e7e:	7a42                	ld	s4,48(sp)
    80003e80:	7aa2                	ld	s5,40(sp)
    80003e82:	7b02                	ld	s6,32(sp)
    80003e84:	6be2                	ld	s7,24(sp)
    80003e86:	6c42                	ld	s8,16(sp)
    80003e88:	6ca2                	ld	s9,8(sp)
    80003e8a:	6125                	addi	sp,sp,96
    80003e8c:	8082                	ret
      iunlock(ip);
    80003e8e:	854e                	mv	a0,s3
    80003e90:	00000097          	auipc	ra,0x0
    80003e94:	aa8080e7          	jalr	-1368(ra) # 80003938 <iunlock>
      return ip;
    80003e98:	bfe9                	j	80003e72 <namex+0x6a>
      iunlockput(ip);
    80003e9a:	854e                	mv	a0,s3
    80003e9c:	00000097          	auipc	ra,0x0
    80003ea0:	c3c080e7          	jalr	-964(ra) # 80003ad8 <iunlockput>
      return 0;
    80003ea4:	89d2                	mv	s3,s4
    80003ea6:	b7f1                	j	80003e72 <namex+0x6a>
  len = path - s;
    80003ea8:	40b48633          	sub	a2,s1,a1
    80003eac:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003eb0:	094cd663          	ble	s4,s9,80003f3c <namex+0x134>
    memmove(name, s, DIRSIZ);
    80003eb4:	4639                	li	a2,14
    80003eb6:	8556                	mv	a0,s5
    80003eb8:	ffffd097          	auipc	ra,0xffffd
    80003ebc:	f12080e7          	jalr	-238(ra) # 80000dca <memmove>
  while(*path == '/')
    80003ec0:	0004c783          	lbu	a5,0(s1)
    80003ec4:	01279763          	bne	a5,s2,80003ed2 <namex+0xca>
    path++;
    80003ec8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003eca:	0004c783          	lbu	a5,0(s1)
    80003ece:	ff278de3          	beq	a5,s2,80003ec8 <namex+0xc0>
    ilock(ip);
    80003ed2:	854e                	mv	a0,s3
    80003ed4:	00000097          	auipc	ra,0x0
    80003ed8:	9a0080e7          	jalr	-1632(ra) # 80003874 <ilock>
    if(ip->type != T_DIR){
    80003edc:	04499783          	lh	a5,68(s3)
    80003ee0:	f98793e3          	bne	a5,s8,80003e66 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003ee4:	000b8563          	beqz	s7,80003eee <namex+0xe6>
    80003ee8:	0004c783          	lbu	a5,0(s1)
    80003eec:	d3cd                	beqz	a5,80003e8e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003eee:	865a                	mv	a2,s6
    80003ef0:	85d6                	mv	a1,s5
    80003ef2:	854e                	mv	a0,s3
    80003ef4:	00000097          	auipc	ra,0x0
    80003ef8:	e64080e7          	jalr	-412(ra) # 80003d58 <dirlookup>
    80003efc:	8a2a                	mv	s4,a0
    80003efe:	dd51                	beqz	a0,80003e9a <namex+0x92>
    iunlockput(ip);
    80003f00:	854e                	mv	a0,s3
    80003f02:	00000097          	auipc	ra,0x0
    80003f06:	bd6080e7          	jalr	-1066(ra) # 80003ad8 <iunlockput>
    ip = next;
    80003f0a:	89d2                	mv	s3,s4
  while(*path == '/')
    80003f0c:	0004c783          	lbu	a5,0(s1)
    80003f10:	05279d63          	bne	a5,s2,80003f6a <namex+0x162>
    path++;
    80003f14:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f16:	0004c783          	lbu	a5,0(s1)
    80003f1a:	ff278de3          	beq	a5,s2,80003f14 <namex+0x10c>
  if(*path == 0)
    80003f1e:	cf8d                	beqz	a5,80003f58 <namex+0x150>
  while(*path != '/' && *path != 0)
    80003f20:	01278b63          	beq	a5,s2,80003f36 <namex+0x12e>
    80003f24:	c795                	beqz	a5,80003f50 <namex+0x148>
    path++;
    80003f26:	85a6                	mv	a1,s1
    path++;
    80003f28:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003f2a:	0004c783          	lbu	a5,0(s1)
    80003f2e:	f7278de3          	beq	a5,s2,80003ea8 <namex+0xa0>
    80003f32:	fbfd                	bnez	a5,80003f28 <namex+0x120>
    80003f34:	bf95                	j	80003ea8 <namex+0xa0>
    80003f36:	85a6                	mv	a1,s1
  len = path - s;
    80003f38:	8a5a                	mv	s4,s6
    80003f3a:	865a                	mv	a2,s6
    memmove(name, s, len);
    80003f3c:	2601                	sext.w	a2,a2
    80003f3e:	8556                	mv	a0,s5
    80003f40:	ffffd097          	auipc	ra,0xffffd
    80003f44:	e8a080e7          	jalr	-374(ra) # 80000dca <memmove>
    name[len] = 0;
    80003f48:	9a56                	add	s4,s4,s5
    80003f4a:	000a0023          	sb	zero,0(s4)
    80003f4e:	bf8d                	j	80003ec0 <namex+0xb8>
  while(*path != '/' && *path != 0)
    80003f50:	85a6                	mv	a1,s1
  len = path - s;
    80003f52:	8a5a                	mv	s4,s6
    80003f54:	865a                	mv	a2,s6
    80003f56:	b7dd                	j	80003f3c <namex+0x134>
  if(nameiparent){
    80003f58:	f00b8de3          	beqz	s7,80003e72 <namex+0x6a>
    iput(ip);
    80003f5c:	854e                	mv	a0,s3
    80003f5e:	00000097          	auipc	ra,0x0
    80003f62:	ad2080e7          	jalr	-1326(ra) # 80003a30 <iput>
    return 0;
    80003f66:	4981                	li	s3,0
    80003f68:	b729                	j	80003e72 <namex+0x6a>
  if(*path == 0)
    80003f6a:	d7fd                	beqz	a5,80003f58 <namex+0x150>
    80003f6c:	85a6                	mv	a1,s1
    80003f6e:	bf6d                	j	80003f28 <namex+0x120>

0000000080003f70 <dirlink>:
{
    80003f70:	7139                	addi	sp,sp,-64
    80003f72:	fc06                	sd	ra,56(sp)
    80003f74:	f822                	sd	s0,48(sp)
    80003f76:	f426                	sd	s1,40(sp)
    80003f78:	f04a                	sd	s2,32(sp)
    80003f7a:	ec4e                	sd	s3,24(sp)
    80003f7c:	e852                	sd	s4,16(sp)
    80003f7e:	0080                	addi	s0,sp,64
    80003f80:	892a                	mv	s2,a0
    80003f82:	8a2e                	mv	s4,a1
    80003f84:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f86:	4601                	li	a2,0
    80003f88:	00000097          	auipc	ra,0x0
    80003f8c:	dd0080e7          	jalr	-560(ra) # 80003d58 <dirlookup>
    80003f90:	e93d                	bnez	a0,80004006 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f92:	04c92483          	lw	s1,76(s2)
    80003f96:	c49d                	beqz	s1,80003fc4 <dirlink+0x54>
    80003f98:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f9a:	4741                	li	a4,16
    80003f9c:	86a6                	mv	a3,s1
    80003f9e:	fc040613          	addi	a2,s0,-64
    80003fa2:	4581                	li	a1,0
    80003fa4:	854a                	mv	a0,s2
    80003fa6:	00000097          	auipc	ra,0x0
    80003faa:	b84080e7          	jalr	-1148(ra) # 80003b2a <readi>
    80003fae:	47c1                	li	a5,16
    80003fb0:	06f51163          	bne	a0,a5,80004012 <dirlink+0xa2>
    if(de.inum == 0)
    80003fb4:	fc045783          	lhu	a5,-64(s0)
    80003fb8:	c791                	beqz	a5,80003fc4 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fba:	24c1                	addiw	s1,s1,16
    80003fbc:	04c92783          	lw	a5,76(s2)
    80003fc0:	fcf4ede3          	bltu	s1,a5,80003f9a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003fc4:	4639                	li	a2,14
    80003fc6:	85d2                	mv	a1,s4
    80003fc8:	fc240513          	addi	a0,s0,-62
    80003fcc:	ffffd097          	auipc	ra,0xffffd
    80003fd0:	eca080e7          	jalr	-310(ra) # 80000e96 <strncpy>
  de.inum = inum;
    80003fd4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fd8:	4741                	li	a4,16
    80003fda:	86a6                	mv	a3,s1
    80003fdc:	fc040613          	addi	a2,s0,-64
    80003fe0:	4581                	li	a1,0
    80003fe2:	854a                	mv	a0,s2
    80003fe4:	00000097          	auipc	ra,0x0
    80003fe8:	c3e080e7          	jalr	-962(ra) # 80003c22 <writei>
    80003fec:	4741                	li	a4,16
  return 0;
    80003fee:	4781                	li	a5,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ff0:	02e51963          	bne	a0,a4,80004022 <dirlink+0xb2>
}
    80003ff4:	853e                	mv	a0,a5
    80003ff6:	70e2                	ld	ra,56(sp)
    80003ff8:	7442                	ld	s0,48(sp)
    80003ffa:	74a2                	ld	s1,40(sp)
    80003ffc:	7902                	ld	s2,32(sp)
    80003ffe:	69e2                	ld	s3,24(sp)
    80004000:	6a42                	ld	s4,16(sp)
    80004002:	6121                	addi	sp,sp,64
    80004004:	8082                	ret
    iput(ip);
    80004006:	00000097          	auipc	ra,0x0
    8000400a:	a2a080e7          	jalr	-1494(ra) # 80003a30 <iput>
    return -1;
    8000400e:	57fd                	li	a5,-1
    80004010:	b7d5                	j	80003ff4 <dirlink+0x84>
      panic("dirlink read");
    80004012:	00004517          	auipc	a0,0x4
    80004016:	5ae50513          	addi	a0,a0,1454 # 800085c0 <syscalls+0x1f0>
    8000401a:	ffffc097          	auipc	ra,0xffffc
    8000401e:	55a080e7          	jalr	1370(ra) # 80000574 <panic>
    panic("dirlink");
    80004022:	00004517          	auipc	a0,0x4
    80004026:	6b650513          	addi	a0,a0,1718 # 800086d8 <syscalls+0x308>
    8000402a:	ffffc097          	auipc	ra,0xffffc
    8000402e:	54a080e7          	jalr	1354(ra) # 80000574 <panic>

0000000080004032 <namei>:

struct inode*
namei(char *path)
{
    80004032:	1101                	addi	sp,sp,-32
    80004034:	ec06                	sd	ra,24(sp)
    80004036:	e822                	sd	s0,16(sp)
    80004038:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000403a:	fe040613          	addi	a2,s0,-32
    8000403e:	4581                	li	a1,0
    80004040:	00000097          	auipc	ra,0x0
    80004044:	dc8080e7          	jalr	-568(ra) # 80003e08 <namex>
}
    80004048:	60e2                	ld	ra,24(sp)
    8000404a:	6442                	ld	s0,16(sp)
    8000404c:	6105                	addi	sp,sp,32
    8000404e:	8082                	ret

0000000080004050 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004050:	1141                	addi	sp,sp,-16
    80004052:	e406                	sd	ra,8(sp)
    80004054:	e022                	sd	s0,0(sp)
    80004056:	0800                	addi	s0,sp,16
  return namex(path, 1, name);
    80004058:	862e                	mv	a2,a1
    8000405a:	4585                	li	a1,1
    8000405c:	00000097          	auipc	ra,0x0
    80004060:	dac080e7          	jalr	-596(ra) # 80003e08 <namex>
}
    80004064:	60a2                	ld	ra,8(sp)
    80004066:	6402                	ld	s0,0(sp)
    80004068:	0141                	addi	sp,sp,16
    8000406a:	8082                	ret

000000008000406c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000406c:	1101                	addi	sp,sp,-32
    8000406e:	ec06                	sd	ra,24(sp)
    80004070:	e822                	sd	s0,16(sp)
    80004072:	e426                	sd	s1,8(sp)
    80004074:	e04a                	sd	s2,0(sp)
    80004076:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004078:	0001e917          	auipc	s2,0x1e
    8000407c:	89090913          	addi	s2,s2,-1904 # 80021908 <log>
    80004080:	01892583          	lw	a1,24(s2)
    80004084:	02892503          	lw	a0,40(s2)
    80004088:	fffff097          	auipc	ra,0xfffff
    8000408c:	fa4080e7          	jalr	-92(ra) # 8000302c <bread>
    80004090:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004092:	02c92683          	lw	a3,44(s2)
    80004096:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004098:	02d05763          	blez	a3,800040c6 <write_head+0x5a>
    8000409c:	0001e797          	auipc	a5,0x1e
    800040a0:	89c78793          	addi	a5,a5,-1892 # 80021938 <log+0x30>
    800040a4:	05c50713          	addi	a4,a0,92
    800040a8:	36fd                	addiw	a3,a3,-1
    800040aa:	1682                	slli	a3,a3,0x20
    800040ac:	9281                	srli	a3,a3,0x20
    800040ae:	068a                	slli	a3,a3,0x2
    800040b0:	0001e617          	auipc	a2,0x1e
    800040b4:	88c60613          	addi	a2,a2,-1908 # 8002193c <log+0x34>
    800040b8:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800040ba:	4390                	lw	a2,0(a5)
    800040bc:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040be:	0791                	addi	a5,a5,4
    800040c0:	0711                	addi	a4,a4,4
    800040c2:	fed79ce3          	bne	a5,a3,800040ba <write_head+0x4e>
  }
  bwrite(buf);
    800040c6:	8526                	mv	a0,s1
    800040c8:	fffff097          	auipc	ra,0xfffff
    800040cc:	068080e7          	jalr	104(ra) # 80003130 <bwrite>
  brelse(buf);
    800040d0:	8526                	mv	a0,s1
    800040d2:	fffff097          	auipc	ra,0xfffff
    800040d6:	09c080e7          	jalr	156(ra) # 8000316e <brelse>
}
    800040da:	60e2                	ld	ra,24(sp)
    800040dc:	6442                	ld	s0,16(sp)
    800040de:	64a2                	ld	s1,8(sp)
    800040e0:	6902                	ld	s2,0(sp)
    800040e2:	6105                	addi	sp,sp,32
    800040e4:	8082                	ret

00000000800040e6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040e6:	0001e797          	auipc	a5,0x1e
    800040ea:	82278793          	addi	a5,a5,-2014 # 80021908 <log>
    800040ee:	57dc                	lw	a5,44(a5)
    800040f0:	0af05663          	blez	a5,8000419c <install_trans+0xb6>
{
    800040f4:	7139                	addi	sp,sp,-64
    800040f6:	fc06                	sd	ra,56(sp)
    800040f8:	f822                	sd	s0,48(sp)
    800040fa:	f426                	sd	s1,40(sp)
    800040fc:	f04a                	sd	s2,32(sp)
    800040fe:	ec4e                	sd	s3,24(sp)
    80004100:	e852                	sd	s4,16(sp)
    80004102:	e456                	sd	s5,8(sp)
    80004104:	0080                	addi	s0,sp,64
    80004106:	0001ea17          	auipc	s4,0x1e
    8000410a:	832a0a13          	addi	s4,s4,-1998 # 80021938 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000410e:	4981                	li	s3,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004110:	0001d917          	auipc	s2,0x1d
    80004114:	7f890913          	addi	s2,s2,2040 # 80021908 <log>
    80004118:	01892583          	lw	a1,24(s2)
    8000411c:	013585bb          	addw	a1,a1,s3
    80004120:	2585                	addiw	a1,a1,1
    80004122:	02892503          	lw	a0,40(s2)
    80004126:	fffff097          	auipc	ra,0xfffff
    8000412a:	f06080e7          	jalr	-250(ra) # 8000302c <bread>
    8000412e:	8aaa                	mv	s5,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004130:	000a2583          	lw	a1,0(s4)
    80004134:	02892503          	lw	a0,40(s2)
    80004138:	fffff097          	auipc	ra,0xfffff
    8000413c:	ef4080e7          	jalr	-268(ra) # 8000302c <bread>
    80004140:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004142:	40000613          	li	a2,1024
    80004146:	058a8593          	addi	a1,s5,88
    8000414a:	05850513          	addi	a0,a0,88
    8000414e:	ffffd097          	auipc	ra,0xffffd
    80004152:	c7c080e7          	jalr	-900(ra) # 80000dca <memmove>
    bwrite(dbuf);  // write dst to disk
    80004156:	8526                	mv	a0,s1
    80004158:	fffff097          	auipc	ra,0xfffff
    8000415c:	fd8080e7          	jalr	-40(ra) # 80003130 <bwrite>
    bunpin(dbuf);
    80004160:	8526                	mv	a0,s1
    80004162:	fffff097          	auipc	ra,0xfffff
    80004166:	0e6080e7          	jalr	230(ra) # 80003248 <bunpin>
    brelse(lbuf);
    8000416a:	8556                	mv	a0,s5
    8000416c:	fffff097          	auipc	ra,0xfffff
    80004170:	002080e7          	jalr	2(ra) # 8000316e <brelse>
    brelse(dbuf);
    80004174:	8526                	mv	a0,s1
    80004176:	fffff097          	auipc	ra,0xfffff
    8000417a:	ff8080e7          	jalr	-8(ra) # 8000316e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000417e:	2985                	addiw	s3,s3,1
    80004180:	0a11                	addi	s4,s4,4
    80004182:	02c92783          	lw	a5,44(s2)
    80004186:	f8f9c9e3          	blt	s3,a5,80004118 <install_trans+0x32>
}
    8000418a:	70e2                	ld	ra,56(sp)
    8000418c:	7442                	ld	s0,48(sp)
    8000418e:	74a2                	ld	s1,40(sp)
    80004190:	7902                	ld	s2,32(sp)
    80004192:	69e2                	ld	s3,24(sp)
    80004194:	6a42                	ld	s4,16(sp)
    80004196:	6aa2                	ld	s5,8(sp)
    80004198:	6121                	addi	sp,sp,64
    8000419a:	8082                	ret
    8000419c:	8082                	ret

000000008000419e <initlog>:
{
    8000419e:	7179                	addi	sp,sp,-48
    800041a0:	f406                	sd	ra,40(sp)
    800041a2:	f022                	sd	s0,32(sp)
    800041a4:	ec26                	sd	s1,24(sp)
    800041a6:	e84a                	sd	s2,16(sp)
    800041a8:	e44e                	sd	s3,8(sp)
    800041aa:	1800                	addi	s0,sp,48
    800041ac:	892a                	mv	s2,a0
    800041ae:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041b0:	0001d497          	auipc	s1,0x1d
    800041b4:	75848493          	addi	s1,s1,1880 # 80021908 <log>
    800041b8:	00004597          	auipc	a1,0x4
    800041bc:	41858593          	addi	a1,a1,1048 # 800085d0 <syscalls+0x200>
    800041c0:	8526                	mv	a0,s1
    800041c2:	ffffd097          	auipc	ra,0xffffd
    800041c6:	a10080e7          	jalr	-1520(ra) # 80000bd2 <initlock>
  log.start = sb->logstart;
    800041ca:	0149a583          	lw	a1,20(s3)
    800041ce:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041d0:	0109a783          	lw	a5,16(s3)
    800041d4:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041d6:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041da:	854a                	mv	a0,s2
    800041dc:	fffff097          	auipc	ra,0xfffff
    800041e0:	e50080e7          	jalr	-432(ra) # 8000302c <bread>
  log.lh.n = lh->n;
    800041e4:	4d3c                	lw	a5,88(a0)
    800041e6:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041e8:	02f05563          	blez	a5,80004212 <initlog+0x74>
    800041ec:	05c50713          	addi	a4,a0,92
    800041f0:	0001d697          	auipc	a3,0x1d
    800041f4:	74868693          	addi	a3,a3,1864 # 80021938 <log+0x30>
    800041f8:	37fd                	addiw	a5,a5,-1
    800041fa:	1782                	slli	a5,a5,0x20
    800041fc:	9381                	srli	a5,a5,0x20
    800041fe:	078a                	slli	a5,a5,0x2
    80004200:	06050613          	addi	a2,a0,96
    80004204:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004206:	4310                	lw	a2,0(a4)
    80004208:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000420a:	0711                	addi	a4,a4,4
    8000420c:	0691                	addi	a3,a3,4
    8000420e:	fef71ce3          	bne	a4,a5,80004206 <initlog+0x68>
  brelse(buf);
    80004212:	fffff097          	auipc	ra,0xfffff
    80004216:	f5c080e7          	jalr	-164(ra) # 8000316e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    8000421a:	00000097          	auipc	ra,0x0
    8000421e:	ecc080e7          	jalr	-308(ra) # 800040e6 <install_trans>
  log.lh.n = 0;
    80004222:	0001d797          	auipc	a5,0x1d
    80004226:	7007a923          	sw	zero,1810(a5) # 80021934 <log+0x2c>
  write_head(); // clear the log
    8000422a:	00000097          	auipc	ra,0x0
    8000422e:	e42080e7          	jalr	-446(ra) # 8000406c <write_head>
}
    80004232:	70a2                	ld	ra,40(sp)
    80004234:	7402                	ld	s0,32(sp)
    80004236:	64e2                	ld	s1,24(sp)
    80004238:	6942                	ld	s2,16(sp)
    8000423a:	69a2                	ld	s3,8(sp)
    8000423c:	6145                	addi	sp,sp,48
    8000423e:	8082                	ret

0000000080004240 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004240:	1101                	addi	sp,sp,-32
    80004242:	ec06                	sd	ra,24(sp)
    80004244:	e822                	sd	s0,16(sp)
    80004246:	e426                	sd	s1,8(sp)
    80004248:	e04a                	sd	s2,0(sp)
    8000424a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000424c:	0001d517          	auipc	a0,0x1d
    80004250:	6bc50513          	addi	a0,a0,1724 # 80021908 <log>
    80004254:	ffffd097          	auipc	ra,0xffffd
    80004258:	a0e080e7          	jalr	-1522(ra) # 80000c62 <acquire>
  while(1){
    if(log.committing){
    8000425c:	0001d497          	auipc	s1,0x1d
    80004260:	6ac48493          	addi	s1,s1,1708 # 80021908 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004264:	4979                	li	s2,30
    80004266:	a039                	j	80004274 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004268:	85a6                	mv	a1,s1
    8000426a:	8526                	mv	a0,s1
    8000426c:	ffffe097          	auipc	ra,0xffffe
    80004270:	152080e7          	jalr	338(ra) # 800023be <sleep>
    if(log.committing){
    80004274:	50dc                	lw	a5,36(s1)
    80004276:	fbed                	bnez	a5,80004268 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004278:	509c                	lw	a5,32(s1)
    8000427a:	0017871b          	addiw	a4,a5,1
    8000427e:	0007069b          	sext.w	a3,a4
    80004282:	0027179b          	slliw	a5,a4,0x2
    80004286:	9fb9                	addw	a5,a5,a4
    80004288:	0017979b          	slliw	a5,a5,0x1
    8000428c:	54d8                	lw	a4,44(s1)
    8000428e:	9fb9                	addw	a5,a5,a4
    80004290:	00f95963          	ble	a5,s2,800042a2 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004294:	85a6                	mv	a1,s1
    80004296:	8526                	mv	a0,s1
    80004298:	ffffe097          	auipc	ra,0xffffe
    8000429c:	126080e7          	jalr	294(ra) # 800023be <sleep>
    800042a0:	bfd1                	j	80004274 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800042a2:	0001d517          	auipc	a0,0x1d
    800042a6:	66650513          	addi	a0,a0,1638 # 80021908 <log>
    800042aa:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800042ac:	ffffd097          	auipc	ra,0xffffd
    800042b0:	a6a080e7          	jalr	-1430(ra) # 80000d16 <release>
      break;
    }
  }
}
    800042b4:	60e2                	ld	ra,24(sp)
    800042b6:	6442                	ld	s0,16(sp)
    800042b8:	64a2                	ld	s1,8(sp)
    800042ba:	6902                	ld	s2,0(sp)
    800042bc:	6105                	addi	sp,sp,32
    800042be:	8082                	ret

00000000800042c0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042c0:	7139                	addi	sp,sp,-64
    800042c2:	fc06                	sd	ra,56(sp)
    800042c4:	f822                	sd	s0,48(sp)
    800042c6:	f426                	sd	s1,40(sp)
    800042c8:	f04a                	sd	s2,32(sp)
    800042ca:	ec4e                	sd	s3,24(sp)
    800042cc:	e852                	sd	s4,16(sp)
    800042ce:	e456                	sd	s5,8(sp)
    800042d0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042d2:	0001d917          	auipc	s2,0x1d
    800042d6:	63690913          	addi	s2,s2,1590 # 80021908 <log>
    800042da:	854a                	mv	a0,s2
    800042dc:	ffffd097          	auipc	ra,0xffffd
    800042e0:	986080e7          	jalr	-1658(ra) # 80000c62 <acquire>
  log.outstanding -= 1;
    800042e4:	02092783          	lw	a5,32(s2)
    800042e8:	37fd                	addiw	a5,a5,-1
    800042ea:	0007849b          	sext.w	s1,a5
    800042ee:	02f92023          	sw	a5,32(s2)
  if(log.committing)
    800042f2:	02492783          	lw	a5,36(s2)
    800042f6:	eba1                	bnez	a5,80004346 <end_op+0x86>
    panic("log.committing");
  if(log.outstanding == 0){
    800042f8:	ecb9                	bnez	s1,80004356 <end_op+0x96>
    do_commit = 1;
    log.committing = 1;
    800042fa:	0001d917          	auipc	s2,0x1d
    800042fe:	60e90913          	addi	s2,s2,1550 # 80021908 <log>
    80004302:	4785                	li	a5,1
    80004304:	02f92223          	sw	a5,36(s2)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004308:	854a                	mv	a0,s2
    8000430a:	ffffd097          	auipc	ra,0xffffd
    8000430e:	a0c080e7          	jalr	-1524(ra) # 80000d16 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004312:	02c92783          	lw	a5,44(s2)
    80004316:	06f04763          	bgtz	a5,80004384 <end_op+0xc4>
    acquire(&log.lock);
    8000431a:	0001d497          	auipc	s1,0x1d
    8000431e:	5ee48493          	addi	s1,s1,1518 # 80021908 <log>
    80004322:	8526                	mv	a0,s1
    80004324:	ffffd097          	auipc	ra,0xffffd
    80004328:	93e080e7          	jalr	-1730(ra) # 80000c62 <acquire>
    log.committing = 0;
    8000432c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004330:	8526                	mv	a0,s1
    80004332:	ffffe097          	auipc	ra,0xffffe
    80004336:	212080e7          	jalr	530(ra) # 80002544 <wakeup>
    release(&log.lock);
    8000433a:	8526                	mv	a0,s1
    8000433c:	ffffd097          	auipc	ra,0xffffd
    80004340:	9da080e7          	jalr	-1574(ra) # 80000d16 <release>
}
    80004344:	a03d                	j	80004372 <end_op+0xb2>
    panic("log.committing");
    80004346:	00004517          	auipc	a0,0x4
    8000434a:	29250513          	addi	a0,a0,658 # 800085d8 <syscalls+0x208>
    8000434e:	ffffc097          	auipc	ra,0xffffc
    80004352:	226080e7          	jalr	550(ra) # 80000574 <panic>
    wakeup(&log);
    80004356:	0001d497          	auipc	s1,0x1d
    8000435a:	5b248493          	addi	s1,s1,1458 # 80021908 <log>
    8000435e:	8526                	mv	a0,s1
    80004360:	ffffe097          	auipc	ra,0xffffe
    80004364:	1e4080e7          	jalr	484(ra) # 80002544 <wakeup>
  release(&log.lock);
    80004368:	8526                	mv	a0,s1
    8000436a:	ffffd097          	auipc	ra,0xffffd
    8000436e:	9ac080e7          	jalr	-1620(ra) # 80000d16 <release>
}
    80004372:	70e2                	ld	ra,56(sp)
    80004374:	7442                	ld	s0,48(sp)
    80004376:	74a2                	ld	s1,40(sp)
    80004378:	7902                	ld	s2,32(sp)
    8000437a:	69e2                	ld	s3,24(sp)
    8000437c:	6a42                	ld	s4,16(sp)
    8000437e:	6aa2                	ld	s5,8(sp)
    80004380:	6121                	addi	sp,sp,64
    80004382:	8082                	ret
    80004384:	0001da17          	auipc	s4,0x1d
    80004388:	5b4a0a13          	addi	s4,s4,1460 # 80021938 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000438c:	0001d917          	auipc	s2,0x1d
    80004390:	57c90913          	addi	s2,s2,1404 # 80021908 <log>
    80004394:	01892583          	lw	a1,24(s2)
    80004398:	9da5                	addw	a1,a1,s1
    8000439a:	2585                	addiw	a1,a1,1
    8000439c:	02892503          	lw	a0,40(s2)
    800043a0:	fffff097          	auipc	ra,0xfffff
    800043a4:	c8c080e7          	jalr	-884(ra) # 8000302c <bread>
    800043a8:	89aa                	mv	s3,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043aa:	000a2583          	lw	a1,0(s4)
    800043ae:	02892503          	lw	a0,40(s2)
    800043b2:	fffff097          	auipc	ra,0xfffff
    800043b6:	c7a080e7          	jalr	-902(ra) # 8000302c <bread>
    800043ba:	8aaa                	mv	s5,a0
    memmove(to->data, from->data, BSIZE);
    800043bc:	40000613          	li	a2,1024
    800043c0:	05850593          	addi	a1,a0,88
    800043c4:	05898513          	addi	a0,s3,88
    800043c8:	ffffd097          	auipc	ra,0xffffd
    800043cc:	a02080e7          	jalr	-1534(ra) # 80000dca <memmove>
    bwrite(to);  // write the log
    800043d0:	854e                	mv	a0,s3
    800043d2:	fffff097          	auipc	ra,0xfffff
    800043d6:	d5e080e7          	jalr	-674(ra) # 80003130 <bwrite>
    brelse(from);
    800043da:	8556                	mv	a0,s5
    800043dc:	fffff097          	auipc	ra,0xfffff
    800043e0:	d92080e7          	jalr	-622(ra) # 8000316e <brelse>
    brelse(to);
    800043e4:	854e                	mv	a0,s3
    800043e6:	fffff097          	auipc	ra,0xfffff
    800043ea:	d88080e7          	jalr	-632(ra) # 8000316e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043ee:	2485                	addiw	s1,s1,1
    800043f0:	0a11                	addi	s4,s4,4
    800043f2:	02c92783          	lw	a5,44(s2)
    800043f6:	f8f4cfe3          	blt	s1,a5,80004394 <end_op+0xd4>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043fa:	00000097          	auipc	ra,0x0
    800043fe:	c72080e7          	jalr	-910(ra) # 8000406c <write_head>
    install_trans(); // Now install writes to home locations
    80004402:	00000097          	auipc	ra,0x0
    80004406:	ce4080e7          	jalr	-796(ra) # 800040e6 <install_trans>
    log.lh.n = 0;
    8000440a:	0001d797          	auipc	a5,0x1d
    8000440e:	5207a523          	sw	zero,1322(a5) # 80021934 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004412:	00000097          	auipc	ra,0x0
    80004416:	c5a080e7          	jalr	-934(ra) # 8000406c <write_head>
    8000441a:	b701                	j	8000431a <end_op+0x5a>

000000008000441c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000441c:	1101                	addi	sp,sp,-32
    8000441e:	ec06                	sd	ra,24(sp)
    80004420:	e822                	sd	s0,16(sp)
    80004422:	e426                	sd	s1,8(sp)
    80004424:	e04a                	sd	s2,0(sp)
    80004426:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004428:	0001d797          	auipc	a5,0x1d
    8000442c:	4e078793          	addi	a5,a5,1248 # 80021908 <log>
    80004430:	57d8                	lw	a4,44(a5)
    80004432:	47f5                	li	a5,29
    80004434:	08e7c563          	blt	a5,a4,800044be <log_write+0xa2>
    80004438:	892a                	mv	s2,a0
    8000443a:	0001d797          	auipc	a5,0x1d
    8000443e:	4ce78793          	addi	a5,a5,1230 # 80021908 <log>
    80004442:	4fdc                	lw	a5,28(a5)
    80004444:	37fd                	addiw	a5,a5,-1
    80004446:	06f75c63          	ble	a5,a4,800044be <log_write+0xa2>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000444a:	0001d797          	auipc	a5,0x1d
    8000444e:	4be78793          	addi	a5,a5,1214 # 80021908 <log>
    80004452:	539c                	lw	a5,32(a5)
    80004454:	06f05d63          	blez	a5,800044ce <log_write+0xb2>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004458:	0001d497          	auipc	s1,0x1d
    8000445c:	4b048493          	addi	s1,s1,1200 # 80021908 <log>
    80004460:	8526                	mv	a0,s1
    80004462:	ffffd097          	auipc	ra,0xffffd
    80004466:	800080e7          	jalr	-2048(ra) # 80000c62 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    8000446a:	54d0                	lw	a2,44(s1)
    8000446c:	0ac05063          	blez	a2,8000450c <log_write+0xf0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004470:	00c92583          	lw	a1,12(s2)
    80004474:	589c                	lw	a5,48(s1)
    80004476:	0ab78363          	beq	a5,a1,8000451c <log_write+0x100>
    8000447a:	0001d717          	auipc	a4,0x1d
    8000447e:	4c270713          	addi	a4,a4,1218 # 8002193c <log+0x34>
  for (i = 0; i < log.lh.n; i++) {
    80004482:	4781                	li	a5,0
    80004484:	2785                	addiw	a5,a5,1
    80004486:	04c78c63          	beq	a5,a2,800044de <log_write+0xc2>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000448a:	4314                	lw	a3,0(a4)
    8000448c:	0711                	addi	a4,a4,4
    8000448e:	feb69be3          	bne	a3,a1,80004484 <log_write+0x68>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004492:	07a1                	addi	a5,a5,8
    80004494:	078a                	slli	a5,a5,0x2
    80004496:	0001d717          	auipc	a4,0x1d
    8000449a:	47270713          	addi	a4,a4,1138 # 80021908 <log>
    8000449e:	97ba                	add	a5,a5,a4
    800044a0:	cb8c                	sw	a1,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    log.lh.n++;
  }
  release(&log.lock);
    800044a2:	0001d517          	auipc	a0,0x1d
    800044a6:	46650513          	addi	a0,a0,1126 # 80021908 <log>
    800044aa:	ffffd097          	auipc	ra,0xffffd
    800044ae:	86c080e7          	jalr	-1940(ra) # 80000d16 <release>
}
    800044b2:	60e2                	ld	ra,24(sp)
    800044b4:	6442                	ld	s0,16(sp)
    800044b6:	64a2                	ld	s1,8(sp)
    800044b8:	6902                	ld	s2,0(sp)
    800044ba:	6105                	addi	sp,sp,32
    800044bc:	8082                	ret
    panic("too big a transaction");
    800044be:	00004517          	auipc	a0,0x4
    800044c2:	12a50513          	addi	a0,a0,298 # 800085e8 <syscalls+0x218>
    800044c6:	ffffc097          	auipc	ra,0xffffc
    800044ca:	0ae080e7          	jalr	174(ra) # 80000574 <panic>
    panic("log_write outside of trans");
    800044ce:	00004517          	auipc	a0,0x4
    800044d2:	13250513          	addi	a0,a0,306 # 80008600 <syscalls+0x230>
    800044d6:	ffffc097          	auipc	ra,0xffffc
    800044da:	09e080e7          	jalr	158(ra) # 80000574 <panic>
  log.lh.block[i] = b->blockno;
    800044de:	0621                	addi	a2,a2,8
    800044e0:	060a                	slli	a2,a2,0x2
    800044e2:	0001d797          	auipc	a5,0x1d
    800044e6:	42678793          	addi	a5,a5,1062 # 80021908 <log>
    800044ea:	963e                	add	a2,a2,a5
    800044ec:	00c92783          	lw	a5,12(s2)
    800044f0:	ca1c                	sw	a5,16(a2)
    bpin(b);
    800044f2:	854a                	mv	a0,s2
    800044f4:	fffff097          	auipc	ra,0xfffff
    800044f8:	d18080e7          	jalr	-744(ra) # 8000320c <bpin>
    log.lh.n++;
    800044fc:	0001d717          	auipc	a4,0x1d
    80004500:	40c70713          	addi	a4,a4,1036 # 80021908 <log>
    80004504:	575c                	lw	a5,44(a4)
    80004506:	2785                	addiw	a5,a5,1
    80004508:	d75c                	sw	a5,44(a4)
    8000450a:	bf61                	j	800044a2 <log_write+0x86>
  log.lh.block[i] = b->blockno;
    8000450c:	00c92783          	lw	a5,12(s2)
    80004510:	0001d717          	auipc	a4,0x1d
    80004514:	42f72423          	sw	a5,1064(a4) # 80021938 <log+0x30>
  if (i == log.lh.n) {  // Add new block to log?
    80004518:	f649                	bnez	a2,800044a2 <log_write+0x86>
    8000451a:	bfe1                	j	800044f2 <log_write+0xd6>
  for (i = 0; i < log.lh.n; i++) {
    8000451c:	4781                	li	a5,0
    8000451e:	bf95                	j	80004492 <log_write+0x76>

0000000080004520 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004520:	1101                	addi	sp,sp,-32
    80004522:	ec06                	sd	ra,24(sp)
    80004524:	e822                	sd	s0,16(sp)
    80004526:	e426                	sd	s1,8(sp)
    80004528:	e04a                	sd	s2,0(sp)
    8000452a:	1000                	addi	s0,sp,32
    8000452c:	84aa                	mv	s1,a0
    8000452e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004530:	00004597          	auipc	a1,0x4
    80004534:	0f058593          	addi	a1,a1,240 # 80008620 <syscalls+0x250>
    80004538:	0521                	addi	a0,a0,8
    8000453a:	ffffc097          	auipc	ra,0xffffc
    8000453e:	698080e7          	jalr	1688(ra) # 80000bd2 <initlock>
  lk->name = name;
    80004542:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004546:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000454a:	0204a423          	sw	zero,40(s1)
}
    8000454e:	60e2                	ld	ra,24(sp)
    80004550:	6442                	ld	s0,16(sp)
    80004552:	64a2                	ld	s1,8(sp)
    80004554:	6902                	ld	s2,0(sp)
    80004556:	6105                	addi	sp,sp,32
    80004558:	8082                	ret

000000008000455a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000455a:	1101                	addi	sp,sp,-32
    8000455c:	ec06                	sd	ra,24(sp)
    8000455e:	e822                	sd	s0,16(sp)
    80004560:	e426                	sd	s1,8(sp)
    80004562:	e04a                	sd	s2,0(sp)
    80004564:	1000                	addi	s0,sp,32
    80004566:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004568:	00850913          	addi	s2,a0,8
    8000456c:	854a                	mv	a0,s2
    8000456e:	ffffc097          	auipc	ra,0xffffc
    80004572:	6f4080e7          	jalr	1780(ra) # 80000c62 <acquire>
  while (lk->locked) {
    80004576:	409c                	lw	a5,0(s1)
    80004578:	cb89                	beqz	a5,8000458a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000457a:	85ca                	mv	a1,s2
    8000457c:	8526                	mv	a0,s1
    8000457e:	ffffe097          	auipc	ra,0xffffe
    80004582:	e40080e7          	jalr	-448(ra) # 800023be <sleep>
  while (lk->locked) {
    80004586:	409c                	lw	a5,0(s1)
    80004588:	fbed                	bnez	a5,8000457a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000458a:	4785                	li	a5,1
    8000458c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000458e:	ffffd097          	auipc	ra,0xffffd
    80004592:	616080e7          	jalr	1558(ra) # 80001ba4 <myproc>
    80004596:	5d1c                	lw	a5,56(a0)
    80004598:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000459a:	854a                	mv	a0,s2
    8000459c:	ffffc097          	auipc	ra,0xffffc
    800045a0:	77a080e7          	jalr	1914(ra) # 80000d16 <release>
}
    800045a4:	60e2                	ld	ra,24(sp)
    800045a6:	6442                	ld	s0,16(sp)
    800045a8:	64a2                	ld	s1,8(sp)
    800045aa:	6902                	ld	s2,0(sp)
    800045ac:	6105                	addi	sp,sp,32
    800045ae:	8082                	ret

00000000800045b0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045b0:	1101                	addi	sp,sp,-32
    800045b2:	ec06                	sd	ra,24(sp)
    800045b4:	e822                	sd	s0,16(sp)
    800045b6:	e426                	sd	s1,8(sp)
    800045b8:	e04a                	sd	s2,0(sp)
    800045ba:	1000                	addi	s0,sp,32
    800045bc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045be:	00850913          	addi	s2,a0,8
    800045c2:	854a                	mv	a0,s2
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	69e080e7          	jalr	1694(ra) # 80000c62 <acquire>
  lk->locked = 0;
    800045cc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045d0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800045d4:	8526                	mv	a0,s1
    800045d6:	ffffe097          	auipc	ra,0xffffe
    800045da:	f6e080e7          	jalr	-146(ra) # 80002544 <wakeup>
  release(&lk->lk);
    800045de:	854a                	mv	a0,s2
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	736080e7          	jalr	1846(ra) # 80000d16 <release>
}
    800045e8:	60e2                	ld	ra,24(sp)
    800045ea:	6442                	ld	s0,16(sp)
    800045ec:	64a2                	ld	s1,8(sp)
    800045ee:	6902                	ld	s2,0(sp)
    800045f0:	6105                	addi	sp,sp,32
    800045f2:	8082                	ret

00000000800045f4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045f4:	7179                	addi	sp,sp,-48
    800045f6:	f406                	sd	ra,40(sp)
    800045f8:	f022                	sd	s0,32(sp)
    800045fa:	ec26                	sd	s1,24(sp)
    800045fc:	e84a                	sd	s2,16(sp)
    800045fe:	e44e                	sd	s3,8(sp)
    80004600:	1800                	addi	s0,sp,48
    80004602:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004604:	00850913          	addi	s2,a0,8
    80004608:	854a                	mv	a0,s2
    8000460a:	ffffc097          	auipc	ra,0xffffc
    8000460e:	658080e7          	jalr	1624(ra) # 80000c62 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004612:	409c                	lw	a5,0(s1)
    80004614:	ef99                	bnez	a5,80004632 <holdingsleep+0x3e>
    80004616:	4481                	li	s1,0
  release(&lk->lk);
    80004618:	854a                	mv	a0,s2
    8000461a:	ffffc097          	auipc	ra,0xffffc
    8000461e:	6fc080e7          	jalr	1788(ra) # 80000d16 <release>
  return r;
}
    80004622:	8526                	mv	a0,s1
    80004624:	70a2                	ld	ra,40(sp)
    80004626:	7402                	ld	s0,32(sp)
    80004628:	64e2                	ld	s1,24(sp)
    8000462a:	6942                	ld	s2,16(sp)
    8000462c:	69a2                	ld	s3,8(sp)
    8000462e:	6145                	addi	sp,sp,48
    80004630:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004632:	0284a983          	lw	s3,40(s1)
    80004636:	ffffd097          	auipc	ra,0xffffd
    8000463a:	56e080e7          	jalr	1390(ra) # 80001ba4 <myproc>
    8000463e:	5d04                	lw	s1,56(a0)
    80004640:	413484b3          	sub	s1,s1,s3
    80004644:	0014b493          	seqz	s1,s1
    80004648:	bfc1                	j	80004618 <holdingsleep+0x24>

000000008000464a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000464a:	1141                	addi	sp,sp,-16
    8000464c:	e406                	sd	ra,8(sp)
    8000464e:	e022                	sd	s0,0(sp)
    80004650:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004652:	00004597          	auipc	a1,0x4
    80004656:	fde58593          	addi	a1,a1,-34 # 80008630 <syscalls+0x260>
    8000465a:	0001d517          	auipc	a0,0x1d
    8000465e:	3f650513          	addi	a0,a0,1014 # 80021a50 <ftable>
    80004662:	ffffc097          	auipc	ra,0xffffc
    80004666:	570080e7          	jalr	1392(ra) # 80000bd2 <initlock>
}
    8000466a:	60a2                	ld	ra,8(sp)
    8000466c:	6402                	ld	s0,0(sp)
    8000466e:	0141                	addi	sp,sp,16
    80004670:	8082                	ret

0000000080004672 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004672:	1101                	addi	sp,sp,-32
    80004674:	ec06                	sd	ra,24(sp)
    80004676:	e822                	sd	s0,16(sp)
    80004678:	e426                	sd	s1,8(sp)
    8000467a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000467c:	0001d517          	auipc	a0,0x1d
    80004680:	3d450513          	addi	a0,a0,980 # 80021a50 <ftable>
    80004684:	ffffc097          	auipc	ra,0xffffc
    80004688:	5de080e7          	jalr	1502(ra) # 80000c62 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
    8000468c:	0001d797          	auipc	a5,0x1d
    80004690:	3c478793          	addi	a5,a5,964 # 80021a50 <ftable>
    80004694:	4fdc                	lw	a5,28(a5)
    80004696:	cb8d                	beqz	a5,800046c8 <filealloc+0x56>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004698:	0001d497          	auipc	s1,0x1d
    8000469c:	3f848493          	addi	s1,s1,1016 # 80021a90 <ftable+0x40>
    800046a0:	0001e717          	auipc	a4,0x1e
    800046a4:	36870713          	addi	a4,a4,872 # 80022a08 <ftable+0xfb8>
    if(f->ref == 0){
    800046a8:	40dc                	lw	a5,4(s1)
    800046aa:	c39d                	beqz	a5,800046d0 <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046ac:	02848493          	addi	s1,s1,40
    800046b0:	fee49ce3          	bne	s1,a4,800046a8 <filealloc+0x36>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046b4:	0001d517          	auipc	a0,0x1d
    800046b8:	39c50513          	addi	a0,a0,924 # 80021a50 <ftable>
    800046bc:	ffffc097          	auipc	ra,0xffffc
    800046c0:	65a080e7          	jalr	1626(ra) # 80000d16 <release>
  return 0;
    800046c4:	4481                	li	s1,0
    800046c6:	a839                	j	800046e4 <filealloc+0x72>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046c8:	0001d497          	auipc	s1,0x1d
    800046cc:	3a048493          	addi	s1,s1,928 # 80021a68 <ftable+0x18>
      f->ref = 1;
    800046d0:	4785                	li	a5,1
    800046d2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046d4:	0001d517          	auipc	a0,0x1d
    800046d8:	37c50513          	addi	a0,a0,892 # 80021a50 <ftable>
    800046dc:	ffffc097          	auipc	ra,0xffffc
    800046e0:	63a080e7          	jalr	1594(ra) # 80000d16 <release>
}
    800046e4:	8526                	mv	a0,s1
    800046e6:	60e2                	ld	ra,24(sp)
    800046e8:	6442                	ld	s0,16(sp)
    800046ea:	64a2                	ld	s1,8(sp)
    800046ec:	6105                	addi	sp,sp,32
    800046ee:	8082                	ret

00000000800046f0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046f0:	1101                	addi	sp,sp,-32
    800046f2:	ec06                	sd	ra,24(sp)
    800046f4:	e822                	sd	s0,16(sp)
    800046f6:	e426                	sd	s1,8(sp)
    800046f8:	1000                	addi	s0,sp,32
    800046fa:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046fc:	0001d517          	auipc	a0,0x1d
    80004700:	35450513          	addi	a0,a0,852 # 80021a50 <ftable>
    80004704:	ffffc097          	auipc	ra,0xffffc
    80004708:	55e080e7          	jalr	1374(ra) # 80000c62 <acquire>
  if(f->ref < 1)
    8000470c:	40dc                	lw	a5,4(s1)
    8000470e:	02f05263          	blez	a5,80004732 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004712:	2785                	addiw	a5,a5,1
    80004714:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004716:	0001d517          	auipc	a0,0x1d
    8000471a:	33a50513          	addi	a0,a0,826 # 80021a50 <ftable>
    8000471e:	ffffc097          	auipc	ra,0xffffc
    80004722:	5f8080e7          	jalr	1528(ra) # 80000d16 <release>
  return f;
}
    80004726:	8526                	mv	a0,s1
    80004728:	60e2                	ld	ra,24(sp)
    8000472a:	6442                	ld	s0,16(sp)
    8000472c:	64a2                	ld	s1,8(sp)
    8000472e:	6105                	addi	sp,sp,32
    80004730:	8082                	ret
    panic("filedup");
    80004732:	00004517          	auipc	a0,0x4
    80004736:	f0650513          	addi	a0,a0,-250 # 80008638 <syscalls+0x268>
    8000473a:	ffffc097          	auipc	ra,0xffffc
    8000473e:	e3a080e7          	jalr	-454(ra) # 80000574 <panic>

0000000080004742 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004742:	7139                	addi	sp,sp,-64
    80004744:	fc06                	sd	ra,56(sp)
    80004746:	f822                	sd	s0,48(sp)
    80004748:	f426                	sd	s1,40(sp)
    8000474a:	f04a                	sd	s2,32(sp)
    8000474c:	ec4e                	sd	s3,24(sp)
    8000474e:	e852                	sd	s4,16(sp)
    80004750:	e456                	sd	s5,8(sp)
    80004752:	0080                	addi	s0,sp,64
    80004754:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004756:	0001d517          	auipc	a0,0x1d
    8000475a:	2fa50513          	addi	a0,a0,762 # 80021a50 <ftable>
    8000475e:	ffffc097          	auipc	ra,0xffffc
    80004762:	504080e7          	jalr	1284(ra) # 80000c62 <acquire>
  if(f->ref < 1)
    80004766:	40dc                	lw	a5,4(s1)
    80004768:	06f05163          	blez	a5,800047ca <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000476c:	37fd                	addiw	a5,a5,-1
    8000476e:	0007871b          	sext.w	a4,a5
    80004772:	c0dc                	sw	a5,4(s1)
    80004774:	06e04363          	bgtz	a4,800047da <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004778:	0004a903          	lw	s2,0(s1)
    8000477c:	0094ca83          	lbu	s5,9(s1)
    80004780:	0104ba03          	ld	s4,16(s1)
    80004784:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004788:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000478c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004790:	0001d517          	auipc	a0,0x1d
    80004794:	2c050513          	addi	a0,a0,704 # 80021a50 <ftable>
    80004798:	ffffc097          	auipc	ra,0xffffc
    8000479c:	57e080e7          	jalr	1406(ra) # 80000d16 <release>

  if(ff.type == FD_PIPE){
    800047a0:	4785                	li	a5,1
    800047a2:	04f90d63          	beq	s2,a5,800047fc <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047a6:	3979                	addiw	s2,s2,-2
    800047a8:	4785                	li	a5,1
    800047aa:	0527e063          	bltu	a5,s2,800047ea <fileclose+0xa8>
    begin_op();
    800047ae:	00000097          	auipc	ra,0x0
    800047b2:	a92080e7          	jalr	-1390(ra) # 80004240 <begin_op>
    iput(ff.ip);
    800047b6:	854e                	mv	a0,s3
    800047b8:	fffff097          	auipc	ra,0xfffff
    800047bc:	278080e7          	jalr	632(ra) # 80003a30 <iput>
    end_op();
    800047c0:	00000097          	auipc	ra,0x0
    800047c4:	b00080e7          	jalr	-1280(ra) # 800042c0 <end_op>
    800047c8:	a00d                	j	800047ea <fileclose+0xa8>
    panic("fileclose");
    800047ca:	00004517          	auipc	a0,0x4
    800047ce:	e7650513          	addi	a0,a0,-394 # 80008640 <syscalls+0x270>
    800047d2:	ffffc097          	auipc	ra,0xffffc
    800047d6:	da2080e7          	jalr	-606(ra) # 80000574 <panic>
    release(&ftable.lock);
    800047da:	0001d517          	auipc	a0,0x1d
    800047de:	27650513          	addi	a0,a0,630 # 80021a50 <ftable>
    800047e2:	ffffc097          	auipc	ra,0xffffc
    800047e6:	534080e7          	jalr	1332(ra) # 80000d16 <release>
  }
}
    800047ea:	70e2                	ld	ra,56(sp)
    800047ec:	7442                	ld	s0,48(sp)
    800047ee:	74a2                	ld	s1,40(sp)
    800047f0:	7902                	ld	s2,32(sp)
    800047f2:	69e2                	ld	s3,24(sp)
    800047f4:	6a42                	ld	s4,16(sp)
    800047f6:	6aa2                	ld	s5,8(sp)
    800047f8:	6121                	addi	sp,sp,64
    800047fa:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047fc:	85d6                	mv	a1,s5
    800047fe:	8552                	mv	a0,s4
    80004800:	00000097          	auipc	ra,0x0
    80004804:	364080e7          	jalr	868(ra) # 80004b64 <pipeclose>
    80004808:	b7cd                	j	800047ea <fileclose+0xa8>

000000008000480a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000480a:	715d                	addi	sp,sp,-80
    8000480c:	e486                	sd	ra,72(sp)
    8000480e:	e0a2                	sd	s0,64(sp)
    80004810:	fc26                	sd	s1,56(sp)
    80004812:	f84a                	sd	s2,48(sp)
    80004814:	f44e                	sd	s3,40(sp)
    80004816:	0880                	addi	s0,sp,80
    80004818:	84aa                	mv	s1,a0
    8000481a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000481c:	ffffd097          	auipc	ra,0xffffd
    80004820:	388080e7          	jalr	904(ra) # 80001ba4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004824:	409c                	lw	a5,0(s1)
    80004826:	37f9                	addiw	a5,a5,-2
    80004828:	4705                	li	a4,1
    8000482a:	04f76763          	bltu	a4,a5,80004878 <filestat+0x6e>
    8000482e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004830:	6c88                	ld	a0,24(s1)
    80004832:	fffff097          	auipc	ra,0xfffff
    80004836:	042080e7          	jalr	66(ra) # 80003874 <ilock>
    stati(f->ip, &st);
    8000483a:	fb840593          	addi	a1,s0,-72
    8000483e:	6c88                	ld	a0,24(s1)
    80004840:	fffff097          	auipc	ra,0xfffff
    80004844:	2c0080e7          	jalr	704(ra) # 80003b00 <stati>
    iunlock(f->ip);
    80004848:	6c88                	ld	a0,24(s1)
    8000484a:	fffff097          	auipc	ra,0xfffff
    8000484e:	0ee080e7          	jalr	238(ra) # 80003938 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004852:	46e1                	li	a3,24
    80004854:	fb840613          	addi	a2,s0,-72
    80004858:	85ce                	mv	a1,s3
    8000485a:	05093503          	ld	a0,80(s2)
    8000485e:	ffffd097          	auipc	ra,0xffffd
    80004862:	f48080e7          	jalr	-184(ra) # 800017a6 <copyout>
    80004866:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000486a:	60a6                	ld	ra,72(sp)
    8000486c:	6406                	ld	s0,64(sp)
    8000486e:	74e2                	ld	s1,56(sp)
    80004870:	7942                	ld	s2,48(sp)
    80004872:	79a2                	ld	s3,40(sp)
    80004874:	6161                	addi	sp,sp,80
    80004876:	8082                	ret
  return -1;
    80004878:	557d                	li	a0,-1
    8000487a:	bfc5                	j	8000486a <filestat+0x60>

000000008000487c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000487c:	7179                	addi	sp,sp,-48
    8000487e:	f406                	sd	ra,40(sp)
    80004880:	f022                	sd	s0,32(sp)
    80004882:	ec26                	sd	s1,24(sp)
    80004884:	e84a                	sd	s2,16(sp)
    80004886:	e44e                	sd	s3,8(sp)
    80004888:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000488a:	00854783          	lbu	a5,8(a0)
    8000488e:	c3d5                	beqz	a5,80004932 <fileread+0xb6>
    80004890:	89b2                	mv	s3,a2
    80004892:	892e                	mv	s2,a1
    80004894:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80004896:	411c                	lw	a5,0(a0)
    80004898:	4705                	li	a4,1
    8000489a:	04e78963          	beq	a5,a4,800048ec <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000489e:	470d                	li	a4,3
    800048a0:	04e78d63          	beq	a5,a4,800048fa <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800048a4:	4709                	li	a4,2
    800048a6:	06e79e63          	bne	a5,a4,80004922 <fileread+0xa6>
    ilock(f->ip);
    800048aa:	6d08                	ld	a0,24(a0)
    800048ac:	fffff097          	auipc	ra,0xfffff
    800048b0:	fc8080e7          	jalr	-56(ra) # 80003874 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048b4:	874e                	mv	a4,s3
    800048b6:	5094                	lw	a3,32(s1)
    800048b8:	864a                	mv	a2,s2
    800048ba:	4585                	li	a1,1
    800048bc:	6c88                	ld	a0,24(s1)
    800048be:	fffff097          	auipc	ra,0xfffff
    800048c2:	26c080e7          	jalr	620(ra) # 80003b2a <readi>
    800048c6:	892a                	mv	s2,a0
    800048c8:	00a05563          	blez	a0,800048d2 <fileread+0x56>
      f->off += r;
    800048cc:	509c                	lw	a5,32(s1)
    800048ce:	9fa9                	addw	a5,a5,a0
    800048d0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048d2:	6c88                	ld	a0,24(s1)
    800048d4:	fffff097          	auipc	ra,0xfffff
    800048d8:	064080e7          	jalr	100(ra) # 80003938 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800048dc:	854a                	mv	a0,s2
    800048de:	70a2                	ld	ra,40(sp)
    800048e0:	7402                	ld	s0,32(sp)
    800048e2:	64e2                	ld	s1,24(sp)
    800048e4:	6942                	ld	s2,16(sp)
    800048e6:	69a2                	ld	s3,8(sp)
    800048e8:	6145                	addi	sp,sp,48
    800048ea:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800048ec:	6908                	ld	a0,16(a0)
    800048ee:	00000097          	auipc	ra,0x0
    800048f2:	416080e7          	jalr	1046(ra) # 80004d04 <piperead>
    800048f6:	892a                	mv	s2,a0
    800048f8:	b7d5                	j	800048dc <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048fa:	02451783          	lh	a5,36(a0)
    800048fe:	03079693          	slli	a3,a5,0x30
    80004902:	92c1                	srli	a3,a3,0x30
    80004904:	4725                	li	a4,9
    80004906:	02d76863          	bltu	a4,a3,80004936 <fileread+0xba>
    8000490a:	0792                	slli	a5,a5,0x4
    8000490c:	0001d717          	auipc	a4,0x1d
    80004910:	0a470713          	addi	a4,a4,164 # 800219b0 <devsw>
    80004914:	97ba                	add	a5,a5,a4
    80004916:	639c                	ld	a5,0(a5)
    80004918:	c38d                	beqz	a5,8000493a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000491a:	4505                	li	a0,1
    8000491c:	9782                	jalr	a5
    8000491e:	892a                	mv	s2,a0
    80004920:	bf75                	j	800048dc <fileread+0x60>
    panic("fileread");
    80004922:	00004517          	auipc	a0,0x4
    80004926:	d2e50513          	addi	a0,a0,-722 # 80008650 <syscalls+0x280>
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	c4a080e7          	jalr	-950(ra) # 80000574 <panic>
    return -1;
    80004932:	597d                	li	s2,-1
    80004934:	b765                	j	800048dc <fileread+0x60>
      return -1;
    80004936:	597d                	li	s2,-1
    80004938:	b755                	j	800048dc <fileread+0x60>
    8000493a:	597d                	li	s2,-1
    8000493c:	b745                	j	800048dc <fileread+0x60>

000000008000493e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000493e:	00954783          	lbu	a5,9(a0)
    80004942:	12078e63          	beqz	a5,80004a7e <filewrite+0x140>
{
    80004946:	715d                	addi	sp,sp,-80
    80004948:	e486                	sd	ra,72(sp)
    8000494a:	e0a2                	sd	s0,64(sp)
    8000494c:	fc26                	sd	s1,56(sp)
    8000494e:	f84a                	sd	s2,48(sp)
    80004950:	f44e                	sd	s3,40(sp)
    80004952:	f052                	sd	s4,32(sp)
    80004954:	ec56                	sd	s5,24(sp)
    80004956:	e85a                	sd	s6,16(sp)
    80004958:	e45e                	sd	s7,8(sp)
    8000495a:	e062                	sd	s8,0(sp)
    8000495c:	0880                	addi	s0,sp,80
    8000495e:	8ab2                	mv	s5,a2
    80004960:	8b2e                	mv	s6,a1
    80004962:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80004964:	411c                	lw	a5,0(a0)
    80004966:	4705                	li	a4,1
    80004968:	02e78263          	beq	a5,a4,8000498c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000496c:	470d                	li	a4,3
    8000496e:	02e78563          	beq	a5,a4,80004998 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004972:	4709                	li	a4,2
    80004974:	0ee79d63          	bne	a5,a4,80004a6e <filewrite+0x130>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004978:	0ec05763          	blez	a2,80004a66 <filewrite+0x128>
    int i = 0;
    8000497c:	4901                	li	s2,0
    8000497e:	6b85                	lui	s7,0x1
    80004980:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004984:	6c05                	lui	s8,0x1
    80004986:	c00c0c1b          	addiw	s8,s8,-1024
    8000498a:	a061                	j	80004a12 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    8000498c:	6908                	ld	a0,16(a0)
    8000498e:	00000097          	auipc	ra,0x0
    80004992:	246080e7          	jalr	582(ra) # 80004bd4 <pipewrite>
    80004996:	a065                	j	80004a3e <filewrite+0x100>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004998:	02451783          	lh	a5,36(a0)
    8000499c:	03079693          	slli	a3,a5,0x30
    800049a0:	92c1                	srli	a3,a3,0x30
    800049a2:	4725                	li	a4,9
    800049a4:	0cd76f63          	bltu	a4,a3,80004a82 <filewrite+0x144>
    800049a8:	0792                	slli	a5,a5,0x4
    800049aa:	0001d717          	auipc	a4,0x1d
    800049ae:	00670713          	addi	a4,a4,6 # 800219b0 <devsw>
    800049b2:	97ba                	add	a5,a5,a4
    800049b4:	679c                	ld	a5,8(a5)
    800049b6:	cbe1                	beqz	a5,80004a86 <filewrite+0x148>
    ret = devsw[f->major].write(1, addr, n);
    800049b8:	4505                	li	a0,1
    800049ba:	9782                	jalr	a5
    800049bc:	a049                	j	80004a3e <filewrite+0x100>
    800049be:	00098a1b          	sext.w	s4,s3
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800049c2:	00000097          	auipc	ra,0x0
    800049c6:	87e080e7          	jalr	-1922(ra) # 80004240 <begin_op>
      ilock(f->ip);
    800049ca:	6c88                	ld	a0,24(s1)
    800049cc:	fffff097          	auipc	ra,0xfffff
    800049d0:	ea8080e7          	jalr	-344(ra) # 80003874 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049d4:	8752                	mv	a4,s4
    800049d6:	5094                	lw	a3,32(s1)
    800049d8:	01690633          	add	a2,s2,s6
    800049dc:	4585                	li	a1,1
    800049de:	6c88                	ld	a0,24(s1)
    800049e0:	fffff097          	auipc	ra,0xfffff
    800049e4:	242080e7          	jalr	578(ra) # 80003c22 <writei>
    800049e8:	89aa                	mv	s3,a0
    800049ea:	02a05c63          	blez	a0,80004a22 <filewrite+0xe4>
        f->off += r;
    800049ee:	509c                	lw	a5,32(s1)
    800049f0:	9fa9                	addw	a5,a5,a0
    800049f2:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    800049f4:	6c88                	ld	a0,24(s1)
    800049f6:	fffff097          	auipc	ra,0xfffff
    800049fa:	f42080e7          	jalr	-190(ra) # 80003938 <iunlock>
      end_op();
    800049fe:	00000097          	auipc	ra,0x0
    80004a02:	8c2080e7          	jalr	-1854(ra) # 800042c0 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004a06:	05499863          	bne	s3,s4,80004a56 <filewrite+0x118>
        panic("short filewrite");
      i += r;
    80004a0a:	012a093b          	addw	s2,s4,s2
    while(i < n){
    80004a0e:	03595563          	ble	s5,s2,80004a38 <filewrite+0xfa>
      int n1 = n - i;
    80004a12:	412a87bb          	subw	a5,s5,s2
      if(n1 > max)
    80004a16:	89be                	mv	s3,a5
    80004a18:	2781                	sext.w	a5,a5
    80004a1a:	fafbd2e3          	ble	a5,s7,800049be <filewrite+0x80>
    80004a1e:	89e2                	mv	s3,s8
    80004a20:	bf79                	j	800049be <filewrite+0x80>
      iunlock(f->ip);
    80004a22:	6c88                	ld	a0,24(s1)
    80004a24:	fffff097          	auipc	ra,0xfffff
    80004a28:	f14080e7          	jalr	-236(ra) # 80003938 <iunlock>
      end_op();
    80004a2c:	00000097          	auipc	ra,0x0
    80004a30:	894080e7          	jalr	-1900(ra) # 800042c0 <end_op>
      if(r < 0)
    80004a34:	fc09d9e3          	bgez	s3,80004a06 <filewrite+0xc8>
    }
    ret = (i == n ? n : -1);
    80004a38:	8556                	mv	a0,s5
    80004a3a:	032a9863          	bne	s5,s2,80004a6a <filewrite+0x12c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a3e:	60a6                	ld	ra,72(sp)
    80004a40:	6406                	ld	s0,64(sp)
    80004a42:	74e2                	ld	s1,56(sp)
    80004a44:	7942                	ld	s2,48(sp)
    80004a46:	79a2                	ld	s3,40(sp)
    80004a48:	7a02                	ld	s4,32(sp)
    80004a4a:	6ae2                	ld	s5,24(sp)
    80004a4c:	6b42                	ld	s6,16(sp)
    80004a4e:	6ba2                	ld	s7,8(sp)
    80004a50:	6c02                	ld	s8,0(sp)
    80004a52:	6161                	addi	sp,sp,80
    80004a54:	8082                	ret
        panic("short filewrite");
    80004a56:	00004517          	auipc	a0,0x4
    80004a5a:	c0a50513          	addi	a0,a0,-1014 # 80008660 <syscalls+0x290>
    80004a5e:	ffffc097          	auipc	ra,0xffffc
    80004a62:	b16080e7          	jalr	-1258(ra) # 80000574 <panic>
    int i = 0;
    80004a66:	4901                	li	s2,0
    80004a68:	bfc1                	j	80004a38 <filewrite+0xfa>
    ret = (i == n ? n : -1);
    80004a6a:	557d                	li	a0,-1
    80004a6c:	bfc9                	j	80004a3e <filewrite+0x100>
    panic("filewrite");
    80004a6e:	00004517          	auipc	a0,0x4
    80004a72:	c0250513          	addi	a0,a0,-1022 # 80008670 <syscalls+0x2a0>
    80004a76:	ffffc097          	auipc	ra,0xffffc
    80004a7a:	afe080e7          	jalr	-1282(ra) # 80000574 <panic>
    return -1;
    80004a7e:	557d                	li	a0,-1
}
    80004a80:	8082                	ret
      return -1;
    80004a82:	557d                	li	a0,-1
    80004a84:	bf6d                	j	80004a3e <filewrite+0x100>
    80004a86:	557d                	li	a0,-1
    80004a88:	bf5d                	j	80004a3e <filewrite+0x100>

0000000080004a8a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a8a:	7179                	addi	sp,sp,-48
    80004a8c:	f406                	sd	ra,40(sp)
    80004a8e:	f022                	sd	s0,32(sp)
    80004a90:	ec26                	sd	s1,24(sp)
    80004a92:	e84a                	sd	s2,16(sp)
    80004a94:	e44e                	sd	s3,8(sp)
    80004a96:	e052                	sd	s4,0(sp)
    80004a98:	1800                	addi	s0,sp,48
    80004a9a:	84aa                	mv	s1,a0
    80004a9c:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a9e:	0005b023          	sd	zero,0(a1)
    80004aa2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004aa6:	00000097          	auipc	ra,0x0
    80004aaa:	bcc080e7          	jalr	-1076(ra) # 80004672 <filealloc>
    80004aae:	e088                	sd	a0,0(s1)
    80004ab0:	c551                	beqz	a0,80004b3c <pipealloc+0xb2>
    80004ab2:	00000097          	auipc	ra,0x0
    80004ab6:	bc0080e7          	jalr	-1088(ra) # 80004672 <filealloc>
    80004aba:	00a93023          	sd	a0,0(s2)
    80004abe:	c92d                	beqz	a0,80004b30 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ac0:	ffffc097          	auipc	ra,0xffffc
    80004ac4:	0b2080e7          	jalr	178(ra) # 80000b72 <kalloc>
    80004ac8:	89aa                	mv	s3,a0
    80004aca:	c125                	beqz	a0,80004b2a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004acc:	4a05                	li	s4,1
    80004ace:	23452023          	sw	s4,544(a0)
  pi->writeopen = 1;
    80004ad2:	23452223          	sw	s4,548(a0)
  pi->nwrite = 0;
    80004ad6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ada:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ade:	00004597          	auipc	a1,0x4
    80004ae2:	ba258593          	addi	a1,a1,-1118 # 80008680 <syscalls+0x2b0>
    80004ae6:	ffffc097          	auipc	ra,0xffffc
    80004aea:	0ec080e7          	jalr	236(ra) # 80000bd2 <initlock>
  (*f0)->type = FD_PIPE;
    80004aee:	609c                	ld	a5,0(s1)
    80004af0:	0147a023          	sw	s4,0(a5)
  (*f0)->readable = 1;
    80004af4:	609c                	ld	a5,0(s1)
    80004af6:	01478423          	sb	s4,8(a5)
  (*f0)->writable = 0;
    80004afa:	609c                	ld	a5,0(s1)
    80004afc:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b00:	609c                	ld	a5,0(s1)
    80004b02:	0137b823          	sd	s3,16(a5)
  (*f1)->type = FD_PIPE;
    80004b06:	00093783          	ld	a5,0(s2)
    80004b0a:	0147a023          	sw	s4,0(a5)
  (*f1)->readable = 0;
    80004b0e:	00093783          	ld	a5,0(s2)
    80004b12:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b16:	00093783          	ld	a5,0(s2)
    80004b1a:	014784a3          	sb	s4,9(a5)
  (*f1)->pipe = pi;
    80004b1e:	00093783          	ld	a5,0(s2)
    80004b22:	0137b823          	sd	s3,16(a5)
  return 0;
    80004b26:	4501                	li	a0,0
    80004b28:	a025                	j	80004b50 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b2a:	6088                	ld	a0,0(s1)
    80004b2c:	e501                	bnez	a0,80004b34 <pipealloc+0xaa>
    80004b2e:	a039                	j	80004b3c <pipealloc+0xb2>
    80004b30:	6088                	ld	a0,0(s1)
    80004b32:	c51d                	beqz	a0,80004b60 <pipealloc+0xd6>
    fileclose(*f0);
    80004b34:	00000097          	auipc	ra,0x0
    80004b38:	c0e080e7          	jalr	-1010(ra) # 80004742 <fileclose>
  if(*f1)
    80004b3c:	00093783          	ld	a5,0(s2)
    fileclose(*f1);
  return -1;
    80004b40:	557d                	li	a0,-1
  if(*f1)
    80004b42:	c799                	beqz	a5,80004b50 <pipealloc+0xc6>
    fileclose(*f1);
    80004b44:	853e                	mv	a0,a5
    80004b46:	00000097          	auipc	ra,0x0
    80004b4a:	bfc080e7          	jalr	-1028(ra) # 80004742 <fileclose>
  return -1;
    80004b4e:	557d                	li	a0,-1
}
    80004b50:	70a2                	ld	ra,40(sp)
    80004b52:	7402                	ld	s0,32(sp)
    80004b54:	64e2                	ld	s1,24(sp)
    80004b56:	6942                	ld	s2,16(sp)
    80004b58:	69a2                	ld	s3,8(sp)
    80004b5a:	6a02                	ld	s4,0(sp)
    80004b5c:	6145                	addi	sp,sp,48
    80004b5e:	8082                	ret
  return -1;
    80004b60:	557d                	li	a0,-1
    80004b62:	b7fd                	j	80004b50 <pipealloc+0xc6>

0000000080004b64 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b64:	1101                	addi	sp,sp,-32
    80004b66:	ec06                	sd	ra,24(sp)
    80004b68:	e822                	sd	s0,16(sp)
    80004b6a:	e426                	sd	s1,8(sp)
    80004b6c:	e04a                	sd	s2,0(sp)
    80004b6e:	1000                	addi	s0,sp,32
    80004b70:	84aa                	mv	s1,a0
    80004b72:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b74:	ffffc097          	auipc	ra,0xffffc
    80004b78:	0ee080e7          	jalr	238(ra) # 80000c62 <acquire>
  if(writable){
    80004b7c:	02090d63          	beqz	s2,80004bb6 <pipeclose+0x52>
    pi->writeopen = 0;
    80004b80:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b84:	21848513          	addi	a0,s1,536
    80004b88:	ffffe097          	auipc	ra,0xffffe
    80004b8c:	9bc080e7          	jalr	-1604(ra) # 80002544 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b90:	2204b783          	ld	a5,544(s1)
    80004b94:	eb95                	bnez	a5,80004bc8 <pipeclose+0x64>
    release(&pi->lock);
    80004b96:	8526                	mv	a0,s1
    80004b98:	ffffc097          	auipc	ra,0xffffc
    80004b9c:	17e080e7          	jalr	382(ra) # 80000d16 <release>
    kfree((char*)pi);
    80004ba0:	8526                	mv	a0,s1
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	ed0080e7          	jalr	-304(ra) # 80000a72 <kfree>
  } else
    release(&pi->lock);
}
    80004baa:	60e2                	ld	ra,24(sp)
    80004bac:	6442                	ld	s0,16(sp)
    80004bae:	64a2                	ld	s1,8(sp)
    80004bb0:	6902                	ld	s2,0(sp)
    80004bb2:	6105                	addi	sp,sp,32
    80004bb4:	8082                	ret
    pi->readopen = 0;
    80004bb6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004bba:	21c48513          	addi	a0,s1,540
    80004bbe:	ffffe097          	auipc	ra,0xffffe
    80004bc2:	986080e7          	jalr	-1658(ra) # 80002544 <wakeup>
    80004bc6:	b7e9                	j	80004b90 <pipeclose+0x2c>
    release(&pi->lock);
    80004bc8:	8526                	mv	a0,s1
    80004bca:	ffffc097          	auipc	ra,0xffffc
    80004bce:	14c080e7          	jalr	332(ra) # 80000d16 <release>
}
    80004bd2:	bfe1                	j	80004baa <pipeclose+0x46>

0000000080004bd4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004bd4:	7119                	addi	sp,sp,-128
    80004bd6:	fc86                	sd	ra,120(sp)
    80004bd8:	f8a2                	sd	s0,112(sp)
    80004bda:	f4a6                	sd	s1,104(sp)
    80004bdc:	f0ca                	sd	s2,96(sp)
    80004bde:	ecce                	sd	s3,88(sp)
    80004be0:	e8d2                	sd	s4,80(sp)
    80004be2:	e4d6                	sd	s5,72(sp)
    80004be4:	e0da                	sd	s6,64(sp)
    80004be6:	fc5e                	sd	s7,56(sp)
    80004be8:	f862                	sd	s8,48(sp)
    80004bea:	f466                	sd	s9,40(sp)
    80004bec:	f06a                	sd	s10,32(sp)
    80004bee:	ec6e                	sd	s11,24(sp)
    80004bf0:	0100                	addi	s0,sp,128
    80004bf2:	84aa                	mv	s1,a0
    80004bf4:	8d2e                	mv	s10,a1
    80004bf6:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004bf8:	ffffd097          	auipc	ra,0xffffd
    80004bfc:	fac080e7          	jalr	-84(ra) # 80001ba4 <myproc>
    80004c00:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004c02:	8526                	mv	a0,s1
    80004c04:	ffffc097          	auipc	ra,0xffffc
    80004c08:	05e080e7          	jalr	94(ra) # 80000c62 <acquire>
  for(i = 0; i < n; i++){
    80004c0c:	0d605f63          	blez	s6,80004cea <pipewrite+0x116>
    80004c10:	89a6                	mv	s3,s1
    80004c12:	3b7d                	addiw	s6,s6,-1
    80004c14:	1b02                	slli	s6,s6,0x20
    80004c16:	020b5b13          	srli	s6,s6,0x20
    80004c1a:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004c1c:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c20:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c24:	5dfd                	li	s11,-1
    80004c26:	000b8c9b          	sext.w	s9,s7
    80004c2a:	8c66                	mv	s8,s9
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c2c:	2184a783          	lw	a5,536(s1)
    80004c30:	21c4a703          	lw	a4,540(s1)
    80004c34:	2007879b          	addiw	a5,a5,512
    80004c38:	06f71763          	bne	a4,a5,80004ca6 <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004c3c:	2204a783          	lw	a5,544(s1)
    80004c40:	cf8d                	beqz	a5,80004c7a <pipewrite+0xa6>
    80004c42:	03092783          	lw	a5,48(s2)
    80004c46:	eb95                	bnez	a5,80004c7a <pipewrite+0xa6>
      wakeup(&pi->nread);
    80004c48:	8556                	mv	a0,s5
    80004c4a:	ffffe097          	auipc	ra,0xffffe
    80004c4e:	8fa080e7          	jalr	-1798(ra) # 80002544 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c52:	85ce                	mv	a1,s3
    80004c54:	8552                	mv	a0,s4
    80004c56:	ffffd097          	auipc	ra,0xffffd
    80004c5a:	768080e7          	jalr	1896(ra) # 800023be <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c5e:	2184a783          	lw	a5,536(s1)
    80004c62:	21c4a703          	lw	a4,540(s1)
    80004c66:	2007879b          	addiw	a5,a5,512
    80004c6a:	02f71e63          	bne	a4,a5,80004ca6 <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004c6e:	2204a783          	lw	a5,544(s1)
    80004c72:	c781                	beqz	a5,80004c7a <pipewrite+0xa6>
    80004c74:	03092783          	lw	a5,48(s2)
    80004c78:	dbe1                	beqz	a5,80004c48 <pipewrite+0x74>
        release(&pi->lock);
    80004c7a:	8526                	mv	a0,s1
    80004c7c:	ffffc097          	auipc	ra,0xffffc
    80004c80:	09a080e7          	jalr	154(ra) # 80000d16 <release>
        return -1;
    80004c84:	5c7d                	li	s8,-1
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004c86:	8562                	mv	a0,s8
    80004c88:	70e6                	ld	ra,120(sp)
    80004c8a:	7446                	ld	s0,112(sp)
    80004c8c:	74a6                	ld	s1,104(sp)
    80004c8e:	7906                	ld	s2,96(sp)
    80004c90:	69e6                	ld	s3,88(sp)
    80004c92:	6a46                	ld	s4,80(sp)
    80004c94:	6aa6                	ld	s5,72(sp)
    80004c96:	6b06                	ld	s6,64(sp)
    80004c98:	7be2                	ld	s7,56(sp)
    80004c9a:	7c42                	ld	s8,48(sp)
    80004c9c:	7ca2                	ld	s9,40(sp)
    80004c9e:	7d02                	ld	s10,32(sp)
    80004ca0:	6de2                	ld	s11,24(sp)
    80004ca2:	6109                	addi	sp,sp,128
    80004ca4:	8082                	ret
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ca6:	4685                	li	a3,1
    80004ca8:	01ab8633          	add	a2,s7,s10
    80004cac:	f8f40593          	addi	a1,s0,-113
    80004cb0:	05093503          	ld	a0,80(s2)
    80004cb4:	ffffd097          	auipc	ra,0xffffd
    80004cb8:	b7e080e7          	jalr	-1154(ra) # 80001832 <copyin>
    80004cbc:	03b50863          	beq	a0,s11,80004cec <pipewrite+0x118>
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cc0:	21c4a783          	lw	a5,540(s1)
    80004cc4:	0017871b          	addiw	a4,a5,1
    80004cc8:	20e4ae23          	sw	a4,540(s1)
    80004ccc:	1ff7f793          	andi	a5,a5,511
    80004cd0:	97a6                	add	a5,a5,s1
    80004cd2:	f8f44703          	lbu	a4,-113(s0)
    80004cd6:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004cda:	001c8c1b          	addiw	s8,s9,1
    80004cde:	001b8793          	addi	a5,s7,1
    80004ce2:	016b8563          	beq	s7,s6,80004cec <pipewrite+0x118>
    80004ce6:	8bbe                	mv	s7,a5
    80004ce8:	bf3d                	j	80004c26 <pipewrite+0x52>
    80004cea:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004cec:	21848513          	addi	a0,s1,536
    80004cf0:	ffffe097          	auipc	ra,0xffffe
    80004cf4:	854080e7          	jalr	-1964(ra) # 80002544 <wakeup>
  release(&pi->lock);
    80004cf8:	8526                	mv	a0,s1
    80004cfa:	ffffc097          	auipc	ra,0xffffc
    80004cfe:	01c080e7          	jalr	28(ra) # 80000d16 <release>
  return i;
    80004d02:	b751                	j	80004c86 <pipewrite+0xb2>

0000000080004d04 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d04:	715d                	addi	sp,sp,-80
    80004d06:	e486                	sd	ra,72(sp)
    80004d08:	e0a2                	sd	s0,64(sp)
    80004d0a:	fc26                	sd	s1,56(sp)
    80004d0c:	f84a                	sd	s2,48(sp)
    80004d0e:	f44e                	sd	s3,40(sp)
    80004d10:	f052                	sd	s4,32(sp)
    80004d12:	ec56                	sd	s5,24(sp)
    80004d14:	e85a                	sd	s6,16(sp)
    80004d16:	0880                	addi	s0,sp,80
    80004d18:	84aa                	mv	s1,a0
    80004d1a:	89ae                	mv	s3,a1
    80004d1c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d1e:	ffffd097          	auipc	ra,0xffffd
    80004d22:	e86080e7          	jalr	-378(ra) # 80001ba4 <myproc>
    80004d26:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d28:	8526                	mv	a0,s1
    80004d2a:	ffffc097          	auipc	ra,0xffffc
    80004d2e:	f38080e7          	jalr	-200(ra) # 80000c62 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d32:	2184a703          	lw	a4,536(s1)
    80004d36:	21c4a783          	lw	a5,540(s1)
    80004d3a:	06f71b63          	bne	a4,a5,80004db0 <piperead+0xac>
    80004d3e:	8926                	mv	s2,s1
    80004d40:	2244a783          	lw	a5,548(s1)
    80004d44:	cf9d                	beqz	a5,80004d82 <piperead+0x7e>
    if(pr->killed){
    80004d46:	030a2783          	lw	a5,48(s4)
    80004d4a:	e78d                	bnez	a5,80004d74 <piperead+0x70>
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d4c:	21848b13          	addi	s6,s1,536
    80004d50:	85ca                	mv	a1,s2
    80004d52:	855a                	mv	a0,s6
    80004d54:	ffffd097          	auipc	ra,0xffffd
    80004d58:	66a080e7          	jalr	1642(ra) # 800023be <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d5c:	2184a703          	lw	a4,536(s1)
    80004d60:	21c4a783          	lw	a5,540(s1)
    80004d64:	04f71663          	bne	a4,a5,80004db0 <piperead+0xac>
    80004d68:	2244a783          	lw	a5,548(s1)
    80004d6c:	cb99                	beqz	a5,80004d82 <piperead+0x7e>
    if(pr->killed){
    80004d6e:	030a2783          	lw	a5,48(s4)
    80004d72:	dff9                	beqz	a5,80004d50 <piperead+0x4c>
      release(&pi->lock);
    80004d74:	8526                	mv	a0,s1
    80004d76:	ffffc097          	auipc	ra,0xffffc
    80004d7a:	fa0080e7          	jalr	-96(ra) # 80000d16 <release>
      return -1;
    80004d7e:	597d                	li	s2,-1
    80004d80:	a829                	j	80004d9a <piperead+0x96>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(pi->nread == pi->nwrite)
    80004d82:	4901                	li	s2,0
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d84:	21c48513          	addi	a0,s1,540
    80004d88:	ffffd097          	auipc	ra,0xffffd
    80004d8c:	7bc080e7          	jalr	1980(ra) # 80002544 <wakeup>
  release(&pi->lock);
    80004d90:	8526                	mv	a0,s1
    80004d92:	ffffc097          	auipc	ra,0xffffc
    80004d96:	f84080e7          	jalr	-124(ra) # 80000d16 <release>
  return i;
}
    80004d9a:	854a                	mv	a0,s2
    80004d9c:	60a6                	ld	ra,72(sp)
    80004d9e:	6406                	ld	s0,64(sp)
    80004da0:	74e2                	ld	s1,56(sp)
    80004da2:	7942                	ld	s2,48(sp)
    80004da4:	79a2                	ld	s3,40(sp)
    80004da6:	7a02                	ld	s4,32(sp)
    80004da8:	6ae2                	ld	s5,24(sp)
    80004daa:	6b42                	ld	s6,16(sp)
    80004dac:	6161                	addi	sp,sp,80
    80004dae:	8082                	ret
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004db0:	4901                	li	s2,0
    80004db2:	fd5059e3          	blez	s5,80004d84 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004db6:	2184a783          	lw	a5,536(s1)
    80004dba:	4901                	li	s2,0
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dbc:	5b7d                	li	s6,-1
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004dbe:	0017871b          	addiw	a4,a5,1
    80004dc2:	20e4ac23          	sw	a4,536(s1)
    80004dc6:	1ff7f793          	andi	a5,a5,511
    80004dca:	97a6                	add	a5,a5,s1
    80004dcc:	0187c783          	lbu	a5,24(a5)
    80004dd0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dd4:	4685                	li	a3,1
    80004dd6:	fbf40613          	addi	a2,s0,-65
    80004dda:	85ce                	mv	a1,s3
    80004ddc:	050a3503          	ld	a0,80(s4)
    80004de0:	ffffd097          	auipc	ra,0xffffd
    80004de4:	9c6080e7          	jalr	-1594(ra) # 800017a6 <copyout>
    80004de8:	f9650ee3          	beq	a0,s6,80004d84 <piperead+0x80>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dec:	2905                	addiw	s2,s2,1
    80004dee:	f92a8be3          	beq	s5,s2,80004d84 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004df2:	2184a783          	lw	a5,536(s1)
    80004df6:	0985                	addi	s3,s3,1
    80004df8:	21c4a703          	lw	a4,540(s1)
    80004dfc:	fcf711e3          	bne	a4,a5,80004dbe <piperead+0xba>
    80004e00:	b751                	j	80004d84 <piperead+0x80>

0000000080004e02 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e02:	de010113          	addi	sp,sp,-544
    80004e06:	20113c23          	sd	ra,536(sp)
    80004e0a:	20813823          	sd	s0,528(sp)
    80004e0e:	20913423          	sd	s1,520(sp)
    80004e12:	21213023          	sd	s2,512(sp)
    80004e16:	ffce                	sd	s3,504(sp)
    80004e18:	fbd2                	sd	s4,496(sp)
    80004e1a:	f7d6                	sd	s5,488(sp)
    80004e1c:	f3da                	sd	s6,480(sp)
    80004e1e:	efde                	sd	s7,472(sp)
    80004e20:	ebe2                	sd	s8,464(sp)
    80004e22:	e7e6                	sd	s9,456(sp)
    80004e24:	e3ea                	sd	s10,448(sp)
    80004e26:	ff6e                	sd	s11,440(sp)
    80004e28:	1400                	addi	s0,sp,544
    80004e2a:	892a                	mv	s2,a0
    80004e2c:	dea43823          	sd	a0,-528(s0)
    80004e30:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e34:	ffffd097          	auipc	ra,0xffffd
    80004e38:	d70080e7          	jalr	-656(ra) # 80001ba4 <myproc>
    80004e3c:	84aa                	mv	s1,a0

  begin_op();
    80004e3e:	fffff097          	auipc	ra,0xfffff
    80004e42:	402080e7          	jalr	1026(ra) # 80004240 <begin_op>

  if((ip = namei(path)) == 0){
    80004e46:	854a                	mv	a0,s2
    80004e48:	fffff097          	auipc	ra,0xfffff
    80004e4c:	1ea080e7          	jalr	490(ra) # 80004032 <namei>
    80004e50:	c93d                	beqz	a0,80004ec6 <exec+0xc4>
    80004e52:	892a                	mv	s2,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e54:	fffff097          	auipc	ra,0xfffff
    80004e58:	a20080e7          	jalr	-1504(ra) # 80003874 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e5c:	04000713          	li	a4,64
    80004e60:	4681                	li	a3,0
    80004e62:	e4840613          	addi	a2,s0,-440
    80004e66:	4581                	li	a1,0
    80004e68:	854a                	mv	a0,s2
    80004e6a:	fffff097          	auipc	ra,0xfffff
    80004e6e:	cc0080e7          	jalr	-832(ra) # 80003b2a <readi>
    80004e72:	04000793          	li	a5,64
    80004e76:	00f51a63          	bne	a0,a5,80004e8a <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e7a:	e4842703          	lw	a4,-440(s0)
    80004e7e:	464c47b7          	lui	a5,0x464c4
    80004e82:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e86:	04f70663          	beq	a4,a5,80004ed2 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e8a:	854a                	mv	a0,s2
    80004e8c:	fffff097          	auipc	ra,0xfffff
    80004e90:	c4c080e7          	jalr	-948(ra) # 80003ad8 <iunlockput>
    end_op();
    80004e94:	fffff097          	auipc	ra,0xfffff
    80004e98:	42c080e7          	jalr	1068(ra) # 800042c0 <end_op>
  }
  return -1;
    80004e9c:	557d                	li	a0,-1
}
    80004e9e:	21813083          	ld	ra,536(sp)
    80004ea2:	21013403          	ld	s0,528(sp)
    80004ea6:	20813483          	ld	s1,520(sp)
    80004eaa:	20013903          	ld	s2,512(sp)
    80004eae:	79fe                	ld	s3,504(sp)
    80004eb0:	7a5e                	ld	s4,496(sp)
    80004eb2:	7abe                	ld	s5,488(sp)
    80004eb4:	7b1e                	ld	s6,480(sp)
    80004eb6:	6bfe                	ld	s7,472(sp)
    80004eb8:	6c5e                	ld	s8,464(sp)
    80004eba:	6cbe                	ld	s9,456(sp)
    80004ebc:	6d1e                	ld	s10,448(sp)
    80004ebe:	7dfa                	ld	s11,440(sp)
    80004ec0:	22010113          	addi	sp,sp,544
    80004ec4:	8082                	ret
    end_op();
    80004ec6:	fffff097          	auipc	ra,0xfffff
    80004eca:	3fa080e7          	jalr	1018(ra) # 800042c0 <end_op>
    return -1;
    80004ece:	557d                	li	a0,-1
    80004ed0:	b7f9                	j	80004e9e <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ed2:	8526                	mv	a0,s1
    80004ed4:	ffffd097          	auipc	ra,0xffffd
    80004ed8:	d96080e7          	jalr	-618(ra) # 80001c6a <proc_pagetable>
    80004edc:	e0a43423          	sd	a0,-504(s0)
    80004ee0:	d54d                	beqz	a0,80004e8a <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ee2:	e6842983          	lw	s3,-408(s0)
    80004ee6:	e8045783          	lhu	a5,-384(s0)
    80004eea:	c7ad                	beqz	a5,80004f54 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004eec:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004eee:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004ef0:	6c05                	lui	s8,0x1
    80004ef2:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    80004ef6:	def43423          	sd	a5,-536(s0)
    80004efa:	7cfd                	lui	s9,0xfffff
    80004efc:	ac1d                	j	80005132 <exec+0x330>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004efe:	00003517          	auipc	a0,0x3
    80004f02:	78a50513          	addi	a0,a0,1930 # 80008688 <syscalls+0x2b8>
    80004f06:	ffffb097          	auipc	ra,0xffffb
    80004f0a:	66e080e7          	jalr	1646(ra) # 80000574 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f0e:	8756                	mv	a4,s5
    80004f10:	009d86bb          	addw	a3,s11,s1
    80004f14:	4581                	li	a1,0
    80004f16:	854a                	mv	a0,s2
    80004f18:	fffff097          	auipc	ra,0xfffff
    80004f1c:	c12080e7          	jalr	-1006(ra) # 80003b2a <readi>
    80004f20:	2501                	sext.w	a0,a0
    80004f22:	1aaa9e63          	bne	s5,a0,800050de <exec+0x2dc>
  for(i = 0; i < sz; i += PGSIZE){
    80004f26:	6785                	lui	a5,0x1
    80004f28:	9cbd                	addw	s1,s1,a5
    80004f2a:	014c8a3b          	addw	s4,s9,s4
    80004f2e:	1f74f963          	bleu	s7,s1,80005120 <exec+0x31e>
    pa = walkaddr(pagetable, va + i);
    80004f32:	02049593          	slli	a1,s1,0x20
    80004f36:	9181                	srli	a1,a1,0x20
    80004f38:	95ea                	add	a1,a1,s10
    80004f3a:	e0843503          	ld	a0,-504(s0)
    80004f3e:	ffffd097          	auipc	ra,0xffffd
    80004f42:	800080e7          	jalr	-2048(ra) # 8000173e <walkaddr>
    80004f46:	862a                	mv	a2,a0
    if(pa == 0)
    80004f48:	d95d                	beqz	a0,80004efe <exec+0xfc>
      n = PGSIZE;
    80004f4a:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    80004f4c:	fd8a71e3          	bleu	s8,s4,80004f0e <exec+0x10c>
      n = sz - i;
    80004f50:	8ad2                	mv	s5,s4
    80004f52:	bf75                	j	80004f0e <exec+0x10c>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004f54:	4481                	li	s1,0
  iunlockput(ip);
    80004f56:	854a                	mv	a0,s2
    80004f58:	fffff097          	auipc	ra,0xfffff
    80004f5c:	b80080e7          	jalr	-1152(ra) # 80003ad8 <iunlockput>
  end_op();
    80004f60:	fffff097          	auipc	ra,0xfffff
    80004f64:	360080e7          	jalr	864(ra) # 800042c0 <end_op>
  p = myproc();
    80004f68:	ffffd097          	auipc	ra,0xffffd
    80004f6c:	c3c080e7          	jalr	-964(ra) # 80001ba4 <myproc>
    80004f70:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f72:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004f76:	6785                	lui	a5,0x1
    80004f78:	17fd                	addi	a5,a5,-1
    80004f7a:	94be                	add	s1,s1,a5
    80004f7c:	77fd                	lui	a5,0xfffff
    80004f7e:	8fe5                	and	a5,a5,s1
    80004f80:	e0f43023          	sd	a5,-512(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f84:	6609                	lui	a2,0x2
    80004f86:	963e                	add	a2,a2,a5
    80004f88:	85be                	mv	a1,a5
    80004f8a:	e0843483          	ld	s1,-504(s0)
    80004f8e:	8526                	mv	a0,s1
    80004f90:	ffffc097          	auipc	ra,0xffffc
    80004f94:	50a080e7          	jalr	1290(ra) # 8000149a <uvmalloc>
    80004f98:	8b2a                	mv	s6,a0
  ip = 0;
    80004f9a:	4901                	li	s2,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f9c:	14050163          	beqz	a0,800050de <exec+0x2dc>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fa0:	75f9                	lui	a1,0xffffe
    80004fa2:	95aa                	add	a1,a1,a0
    80004fa4:	8526                	mv	a0,s1
    80004fa6:	ffffc097          	auipc	ra,0xffffc
    80004faa:	6e4080e7          	jalr	1764(ra) # 8000168a <uvmclear>
  stackbase = sp - PGSIZE;
    80004fae:	7bfd                	lui	s7,0xfffff
    80004fb0:	9bda                	add	s7,s7,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fb2:	df843783          	ld	a5,-520(s0)
    80004fb6:	6388                	ld	a0,0(a5)
    80004fb8:	c925                	beqz	a0,80005028 <exec+0x226>
    80004fba:	e8840993          	addi	s3,s0,-376
    80004fbe:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80004fc2:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fc4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004fc6:	ffffc097          	auipc	ra,0xffffc
    80004fca:	f42080e7          	jalr	-190(ra) # 80000f08 <strlen>
    80004fce:	2505                	addiw	a0,a0,1
    80004fd0:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fd4:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004fd8:	13796863          	bltu	s2,s7,80005108 <exec+0x306>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fdc:	df843c83          	ld	s9,-520(s0)
    80004fe0:	000cba03          	ld	s4,0(s9) # fffffffffffff000 <end+0xffffffff7ffd9000>
    80004fe4:	8552                	mv	a0,s4
    80004fe6:	ffffc097          	auipc	ra,0xffffc
    80004fea:	f22080e7          	jalr	-222(ra) # 80000f08 <strlen>
    80004fee:	0015069b          	addiw	a3,a0,1
    80004ff2:	8652                	mv	a2,s4
    80004ff4:	85ca                	mv	a1,s2
    80004ff6:	e0843503          	ld	a0,-504(s0)
    80004ffa:	ffffc097          	auipc	ra,0xffffc
    80004ffe:	7ac080e7          	jalr	1964(ra) # 800017a6 <copyout>
    80005002:	10054763          	bltz	a0,80005110 <exec+0x30e>
    ustack[argc] = sp;
    80005006:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000500a:	0485                	addi	s1,s1,1
    8000500c:	008c8793          	addi	a5,s9,8
    80005010:	def43c23          	sd	a5,-520(s0)
    80005014:	008cb503          	ld	a0,8(s9)
    80005018:	c911                	beqz	a0,8000502c <exec+0x22a>
    if(argc >= MAXARG)
    8000501a:	09a1                	addi	s3,s3,8
    8000501c:	fb8995e3          	bne	s3,s8,80004fc6 <exec+0x1c4>
  sz = sz1;
    80005020:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005024:	4901                	li	s2,0
    80005026:	a865                	j	800050de <exec+0x2dc>
  sp = sz;
    80005028:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    8000502a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000502c:	00349793          	slli	a5,s1,0x3
    80005030:	f9040713          	addi	a4,s0,-112
    80005034:	97ba                	add	a5,a5,a4
    80005036:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    8000503a:	00148693          	addi	a3,s1,1
    8000503e:	068e                	slli	a3,a3,0x3
    80005040:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005044:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005048:	01797663          	bleu	s7,s2,80005054 <exec+0x252>
  sz = sz1;
    8000504c:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005050:	4901                	li	s2,0
    80005052:	a071                	j	800050de <exec+0x2dc>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005054:	e8840613          	addi	a2,s0,-376
    80005058:	85ca                	mv	a1,s2
    8000505a:	e0843503          	ld	a0,-504(s0)
    8000505e:	ffffc097          	auipc	ra,0xffffc
    80005062:	748080e7          	jalr	1864(ra) # 800017a6 <copyout>
    80005066:	0a054963          	bltz	a0,80005118 <exec+0x316>
  p->trapframe->a1 = sp;
    8000506a:	058ab783          	ld	a5,88(s5)
    8000506e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005072:	df043783          	ld	a5,-528(s0)
    80005076:	0007c703          	lbu	a4,0(a5)
    8000507a:	cf11                	beqz	a4,80005096 <exec+0x294>
    8000507c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000507e:	02f00693          	li	a3,47
    80005082:	a029                	j	8000508c <exec+0x28a>
  for(last=s=path; *s; s++)
    80005084:	0785                	addi	a5,a5,1
    80005086:	fff7c703          	lbu	a4,-1(a5)
    8000508a:	c711                	beqz	a4,80005096 <exec+0x294>
    if(*s == '/')
    8000508c:	fed71ce3          	bne	a4,a3,80005084 <exec+0x282>
      last = s+1;
    80005090:	def43823          	sd	a5,-528(s0)
    80005094:	bfc5                	j	80005084 <exec+0x282>
  safestrcpy(p->name, last, sizeof(p->name));
    80005096:	4641                	li	a2,16
    80005098:	df043583          	ld	a1,-528(s0)
    8000509c:	158a8513          	addi	a0,s5,344
    800050a0:	ffffc097          	auipc	ra,0xffffc
    800050a4:	e36080e7          	jalr	-458(ra) # 80000ed6 <safestrcpy>
  oldpagetable = p->pagetable;
    800050a8:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800050ac:	e0843783          	ld	a5,-504(s0)
    800050b0:	04fab823          	sd	a5,80(s5)
  p->sz = sz;
    800050b4:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050b8:	058ab783          	ld	a5,88(s5)
    800050bc:	e6043703          	ld	a4,-416(s0)
    800050c0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050c2:	058ab783          	ld	a5,88(s5)
    800050c6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050ca:	85ea                	mv	a1,s10
    800050cc:	ffffd097          	auipc	ra,0xffffd
    800050d0:	c3a080e7          	jalr	-966(ra) # 80001d06 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050d4:	0004851b          	sext.w	a0,s1
    800050d8:	b3d9                	j	80004e9e <exec+0x9c>
    800050da:	e0943023          	sd	s1,-512(s0)
    proc_freepagetable(pagetable, sz);
    800050de:	e0043583          	ld	a1,-512(s0)
    800050e2:	e0843503          	ld	a0,-504(s0)
    800050e6:	ffffd097          	auipc	ra,0xffffd
    800050ea:	c20080e7          	jalr	-992(ra) # 80001d06 <proc_freepagetable>
  if(ip){
    800050ee:	d8091ee3          	bnez	s2,80004e8a <exec+0x88>
  return -1;
    800050f2:	557d                	li	a0,-1
    800050f4:	b36d                	j	80004e9e <exec+0x9c>
    800050f6:	e0943023          	sd	s1,-512(s0)
    800050fa:	b7d5                	j	800050de <exec+0x2dc>
    800050fc:	e0943023          	sd	s1,-512(s0)
    80005100:	bff9                	j	800050de <exec+0x2dc>
    80005102:	e0943023          	sd	s1,-512(s0)
    80005106:	bfe1                	j	800050de <exec+0x2dc>
  sz = sz1;
    80005108:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    8000510c:	4901                	li	s2,0
    8000510e:	bfc1                	j	800050de <exec+0x2dc>
  sz = sz1;
    80005110:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005114:	4901                	li	s2,0
    80005116:	b7e1                	j	800050de <exec+0x2dc>
  sz = sz1;
    80005118:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    8000511c:	4901                	li	s2,0
    8000511e:	b7c1                	j	800050de <exec+0x2dc>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005120:	e0043483          	ld	s1,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005124:	2b05                	addiw	s6,s6,1
    80005126:	0389899b          	addiw	s3,s3,56
    8000512a:	e8045783          	lhu	a5,-384(s0)
    8000512e:	e2fb54e3          	ble	a5,s6,80004f56 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005132:	2981                	sext.w	s3,s3
    80005134:	03800713          	li	a4,56
    80005138:	86ce                	mv	a3,s3
    8000513a:	e1040613          	addi	a2,s0,-496
    8000513e:	4581                	li	a1,0
    80005140:	854a                	mv	a0,s2
    80005142:	fffff097          	auipc	ra,0xfffff
    80005146:	9e8080e7          	jalr	-1560(ra) # 80003b2a <readi>
    8000514a:	03800793          	li	a5,56
    8000514e:	f8f516e3          	bne	a0,a5,800050da <exec+0x2d8>
    if(ph.type != ELF_PROG_LOAD)
    80005152:	e1042783          	lw	a5,-496(s0)
    80005156:	4705                	li	a4,1
    80005158:	fce796e3          	bne	a5,a4,80005124 <exec+0x322>
    if(ph.memsz < ph.filesz)
    8000515c:	e3843603          	ld	a2,-456(s0)
    80005160:	e3043783          	ld	a5,-464(s0)
    80005164:	f8f669e3          	bltu	a2,a5,800050f6 <exec+0x2f4>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005168:	e2043783          	ld	a5,-480(s0)
    8000516c:	963e                	add	a2,a2,a5
    8000516e:	f8f667e3          	bltu	a2,a5,800050fc <exec+0x2fa>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005172:	85a6                	mv	a1,s1
    80005174:	e0843503          	ld	a0,-504(s0)
    80005178:	ffffc097          	auipc	ra,0xffffc
    8000517c:	322080e7          	jalr	802(ra) # 8000149a <uvmalloc>
    80005180:	e0a43023          	sd	a0,-512(s0)
    80005184:	dd3d                	beqz	a0,80005102 <exec+0x300>
    if(ph.vaddr % PGSIZE != 0)
    80005186:	e2043d03          	ld	s10,-480(s0)
    8000518a:	de843783          	ld	a5,-536(s0)
    8000518e:	00fd77b3          	and	a5,s10,a5
    80005192:	f7b1                	bnez	a5,800050de <exec+0x2dc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005194:	e1842d83          	lw	s11,-488(s0)
    80005198:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000519c:	f80b82e3          	beqz	s7,80005120 <exec+0x31e>
    800051a0:	8a5e                	mv	s4,s7
    800051a2:	4481                	li	s1,0
    800051a4:	b379                	j	80004f32 <exec+0x130>

00000000800051a6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051a6:	7179                	addi	sp,sp,-48
    800051a8:	f406                	sd	ra,40(sp)
    800051aa:	f022                	sd	s0,32(sp)
    800051ac:	ec26                	sd	s1,24(sp)
    800051ae:	e84a                	sd	s2,16(sp)
    800051b0:	1800                	addi	s0,sp,48
    800051b2:	892e                	mv	s2,a1
    800051b4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800051b6:	fdc40593          	addi	a1,s0,-36
    800051ba:	ffffe097          	auipc	ra,0xffffe
    800051be:	ae4080e7          	jalr	-1308(ra) # 80002c9e <argint>
    800051c2:	04054063          	bltz	a0,80005202 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051c6:	fdc42703          	lw	a4,-36(s0)
    800051ca:	47bd                	li	a5,15
    800051cc:	02e7ed63          	bltu	a5,a4,80005206 <argfd+0x60>
    800051d0:	ffffd097          	auipc	ra,0xffffd
    800051d4:	9d4080e7          	jalr	-1580(ra) # 80001ba4 <myproc>
    800051d8:	fdc42703          	lw	a4,-36(s0)
    800051dc:	01a70793          	addi	a5,a4,26
    800051e0:	078e                	slli	a5,a5,0x3
    800051e2:	953e                	add	a0,a0,a5
    800051e4:	611c                	ld	a5,0(a0)
    800051e6:	c395                	beqz	a5,8000520a <argfd+0x64>
    return -1;
  if(pfd)
    800051e8:	00090463          	beqz	s2,800051f0 <argfd+0x4a>
    *pfd = fd;
    800051ec:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051f0:	4501                	li	a0,0
  if(pf)
    800051f2:	c091                	beqz	s1,800051f6 <argfd+0x50>
    *pf = f;
    800051f4:	e09c                	sd	a5,0(s1)
}
    800051f6:	70a2                	ld	ra,40(sp)
    800051f8:	7402                	ld	s0,32(sp)
    800051fa:	64e2                	ld	s1,24(sp)
    800051fc:	6942                	ld	s2,16(sp)
    800051fe:	6145                	addi	sp,sp,48
    80005200:	8082                	ret
    return -1;
    80005202:	557d                	li	a0,-1
    80005204:	bfcd                	j	800051f6 <argfd+0x50>
    return -1;
    80005206:	557d                	li	a0,-1
    80005208:	b7fd                	j	800051f6 <argfd+0x50>
    8000520a:	557d                	li	a0,-1
    8000520c:	b7ed                	j	800051f6 <argfd+0x50>

000000008000520e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000520e:	1101                	addi	sp,sp,-32
    80005210:	ec06                	sd	ra,24(sp)
    80005212:	e822                	sd	s0,16(sp)
    80005214:	e426                	sd	s1,8(sp)
    80005216:	1000                	addi	s0,sp,32
    80005218:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000521a:	ffffd097          	auipc	ra,0xffffd
    8000521e:	98a080e7          	jalr	-1654(ra) # 80001ba4 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
    80005222:	697c                	ld	a5,208(a0)
    80005224:	c395                	beqz	a5,80005248 <fdalloc+0x3a>
    80005226:	0d850713          	addi	a4,a0,216
  for(fd = 0; fd < NOFILE; fd++){
    8000522a:	4785                	li	a5,1
    8000522c:	4641                	li	a2,16
    if(p->ofile[fd] == 0){
    8000522e:	6314                	ld	a3,0(a4)
    80005230:	ce89                	beqz	a3,8000524a <fdalloc+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
    80005232:	2785                	addiw	a5,a5,1
    80005234:	0721                	addi	a4,a4,8
    80005236:	fec79ce3          	bne	a5,a2,8000522e <fdalloc+0x20>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000523a:	57fd                	li	a5,-1
}
    8000523c:	853e                	mv	a0,a5
    8000523e:	60e2                	ld	ra,24(sp)
    80005240:	6442                	ld	s0,16(sp)
    80005242:	64a2                	ld	s1,8(sp)
    80005244:	6105                	addi	sp,sp,32
    80005246:	8082                	ret
  for(fd = 0; fd < NOFILE; fd++){
    80005248:	4781                	li	a5,0
      p->ofile[fd] = f;
    8000524a:	01a78713          	addi	a4,a5,26
    8000524e:	070e                	slli	a4,a4,0x3
    80005250:	953a                	add	a0,a0,a4
    80005252:	e104                	sd	s1,0(a0)
      return fd;
    80005254:	b7e5                	j	8000523c <fdalloc+0x2e>

0000000080005256 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005256:	715d                	addi	sp,sp,-80
    80005258:	e486                	sd	ra,72(sp)
    8000525a:	e0a2                	sd	s0,64(sp)
    8000525c:	fc26                	sd	s1,56(sp)
    8000525e:	f84a                	sd	s2,48(sp)
    80005260:	f44e                	sd	s3,40(sp)
    80005262:	f052                	sd	s4,32(sp)
    80005264:	ec56                	sd	s5,24(sp)
    80005266:	0880                	addi	s0,sp,80
    80005268:	89ae                	mv	s3,a1
    8000526a:	8ab2                	mv	s5,a2
    8000526c:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000526e:	fb040593          	addi	a1,s0,-80
    80005272:	fffff097          	auipc	ra,0xfffff
    80005276:	dde080e7          	jalr	-546(ra) # 80004050 <nameiparent>
    8000527a:	892a                	mv	s2,a0
    8000527c:	12050f63          	beqz	a0,800053ba <create+0x164>
    return 0;

  ilock(dp);
    80005280:	ffffe097          	auipc	ra,0xffffe
    80005284:	5f4080e7          	jalr	1524(ra) # 80003874 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005288:	4601                	li	a2,0
    8000528a:	fb040593          	addi	a1,s0,-80
    8000528e:	854a                	mv	a0,s2
    80005290:	fffff097          	auipc	ra,0xfffff
    80005294:	ac8080e7          	jalr	-1336(ra) # 80003d58 <dirlookup>
    80005298:	84aa                	mv	s1,a0
    8000529a:	c921                	beqz	a0,800052ea <create+0x94>
    iunlockput(dp);
    8000529c:	854a                	mv	a0,s2
    8000529e:	fffff097          	auipc	ra,0xfffff
    800052a2:	83a080e7          	jalr	-1990(ra) # 80003ad8 <iunlockput>
    ilock(ip);
    800052a6:	8526                	mv	a0,s1
    800052a8:	ffffe097          	auipc	ra,0xffffe
    800052ac:	5cc080e7          	jalr	1484(ra) # 80003874 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052b0:	2981                	sext.w	s3,s3
    800052b2:	4789                	li	a5,2
    800052b4:	02f99463          	bne	s3,a5,800052dc <create+0x86>
    800052b8:	0444d783          	lhu	a5,68(s1)
    800052bc:	37f9                	addiw	a5,a5,-2
    800052be:	17c2                	slli	a5,a5,0x30
    800052c0:	93c1                	srli	a5,a5,0x30
    800052c2:	4705                	li	a4,1
    800052c4:	00f76c63          	bltu	a4,a5,800052dc <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800052c8:	8526                	mv	a0,s1
    800052ca:	60a6                	ld	ra,72(sp)
    800052cc:	6406                	ld	s0,64(sp)
    800052ce:	74e2                	ld	s1,56(sp)
    800052d0:	7942                	ld	s2,48(sp)
    800052d2:	79a2                	ld	s3,40(sp)
    800052d4:	7a02                	ld	s4,32(sp)
    800052d6:	6ae2                	ld	s5,24(sp)
    800052d8:	6161                	addi	sp,sp,80
    800052da:	8082                	ret
    iunlockput(ip);
    800052dc:	8526                	mv	a0,s1
    800052de:	ffffe097          	auipc	ra,0xffffe
    800052e2:	7fa080e7          	jalr	2042(ra) # 80003ad8 <iunlockput>
    return 0;
    800052e6:	4481                	li	s1,0
    800052e8:	b7c5                	j	800052c8 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800052ea:	85ce                	mv	a1,s3
    800052ec:	00092503          	lw	a0,0(s2)
    800052f0:	ffffe097          	auipc	ra,0xffffe
    800052f4:	3e8080e7          	jalr	1000(ra) # 800036d8 <ialloc>
    800052f8:	84aa                	mv	s1,a0
    800052fa:	c529                	beqz	a0,80005344 <create+0xee>
  ilock(ip);
    800052fc:	ffffe097          	auipc	ra,0xffffe
    80005300:	578080e7          	jalr	1400(ra) # 80003874 <ilock>
  ip->major = major;
    80005304:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005308:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000530c:	4785                	li	a5,1
    8000530e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005312:	8526                	mv	a0,s1
    80005314:	ffffe097          	auipc	ra,0xffffe
    80005318:	494080e7          	jalr	1172(ra) # 800037a8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000531c:	2981                	sext.w	s3,s3
    8000531e:	4785                	li	a5,1
    80005320:	02f98a63          	beq	s3,a5,80005354 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005324:	40d0                	lw	a2,4(s1)
    80005326:	fb040593          	addi	a1,s0,-80
    8000532a:	854a                	mv	a0,s2
    8000532c:	fffff097          	auipc	ra,0xfffff
    80005330:	c44080e7          	jalr	-956(ra) # 80003f70 <dirlink>
    80005334:	06054b63          	bltz	a0,800053aa <create+0x154>
  iunlockput(dp);
    80005338:	854a                	mv	a0,s2
    8000533a:	ffffe097          	auipc	ra,0xffffe
    8000533e:	79e080e7          	jalr	1950(ra) # 80003ad8 <iunlockput>
  return ip;
    80005342:	b759                	j	800052c8 <create+0x72>
    panic("create: ialloc");
    80005344:	00003517          	auipc	a0,0x3
    80005348:	36450513          	addi	a0,a0,868 # 800086a8 <syscalls+0x2d8>
    8000534c:	ffffb097          	auipc	ra,0xffffb
    80005350:	228080e7          	jalr	552(ra) # 80000574 <panic>
    dp->nlink++;  // for ".."
    80005354:	04a95783          	lhu	a5,74(s2)
    80005358:	2785                	addiw	a5,a5,1
    8000535a:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000535e:	854a                	mv	a0,s2
    80005360:	ffffe097          	auipc	ra,0xffffe
    80005364:	448080e7          	jalr	1096(ra) # 800037a8 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005368:	40d0                	lw	a2,4(s1)
    8000536a:	00003597          	auipc	a1,0x3
    8000536e:	34e58593          	addi	a1,a1,846 # 800086b8 <syscalls+0x2e8>
    80005372:	8526                	mv	a0,s1
    80005374:	fffff097          	auipc	ra,0xfffff
    80005378:	bfc080e7          	jalr	-1028(ra) # 80003f70 <dirlink>
    8000537c:	00054f63          	bltz	a0,8000539a <create+0x144>
    80005380:	00492603          	lw	a2,4(s2)
    80005384:	00003597          	auipc	a1,0x3
    80005388:	dcc58593          	addi	a1,a1,-564 # 80008150 <digits+0x138>
    8000538c:	8526                	mv	a0,s1
    8000538e:	fffff097          	auipc	ra,0xfffff
    80005392:	be2080e7          	jalr	-1054(ra) # 80003f70 <dirlink>
    80005396:	f80557e3          	bgez	a0,80005324 <create+0xce>
      panic("create dots");
    8000539a:	00003517          	auipc	a0,0x3
    8000539e:	32650513          	addi	a0,a0,806 # 800086c0 <syscalls+0x2f0>
    800053a2:	ffffb097          	auipc	ra,0xffffb
    800053a6:	1d2080e7          	jalr	466(ra) # 80000574 <panic>
    panic("create: dirlink");
    800053aa:	00003517          	auipc	a0,0x3
    800053ae:	32650513          	addi	a0,a0,806 # 800086d0 <syscalls+0x300>
    800053b2:	ffffb097          	auipc	ra,0xffffb
    800053b6:	1c2080e7          	jalr	450(ra) # 80000574 <panic>
    return 0;
    800053ba:	84aa                	mv	s1,a0
    800053bc:	b731                	j	800052c8 <create+0x72>

00000000800053be <sys_dup>:
{
    800053be:	7179                	addi	sp,sp,-48
    800053c0:	f406                	sd	ra,40(sp)
    800053c2:	f022                	sd	s0,32(sp)
    800053c4:	ec26                	sd	s1,24(sp)
    800053c6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053c8:	fd840613          	addi	a2,s0,-40
    800053cc:	4581                	li	a1,0
    800053ce:	4501                	li	a0,0
    800053d0:	00000097          	auipc	ra,0x0
    800053d4:	dd6080e7          	jalr	-554(ra) # 800051a6 <argfd>
    return -1;
    800053d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053da:	02054363          	bltz	a0,80005400 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053de:	fd843503          	ld	a0,-40(s0)
    800053e2:	00000097          	auipc	ra,0x0
    800053e6:	e2c080e7          	jalr	-468(ra) # 8000520e <fdalloc>
    800053ea:	84aa                	mv	s1,a0
    return -1;
    800053ec:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053ee:	00054963          	bltz	a0,80005400 <sys_dup+0x42>
  filedup(f);
    800053f2:	fd843503          	ld	a0,-40(s0)
    800053f6:	fffff097          	auipc	ra,0xfffff
    800053fa:	2fa080e7          	jalr	762(ra) # 800046f0 <filedup>
  return fd;
    800053fe:	87a6                	mv	a5,s1
}
    80005400:	853e                	mv	a0,a5
    80005402:	70a2                	ld	ra,40(sp)
    80005404:	7402                	ld	s0,32(sp)
    80005406:	64e2                	ld	s1,24(sp)
    80005408:	6145                	addi	sp,sp,48
    8000540a:	8082                	ret

000000008000540c <sys_read>:
{
    8000540c:	7179                	addi	sp,sp,-48
    8000540e:	f406                	sd	ra,40(sp)
    80005410:	f022                	sd	s0,32(sp)
    80005412:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005414:	fe840613          	addi	a2,s0,-24
    80005418:	4581                	li	a1,0
    8000541a:	4501                	li	a0,0
    8000541c:	00000097          	auipc	ra,0x0
    80005420:	d8a080e7          	jalr	-630(ra) # 800051a6 <argfd>
    return -1;
    80005424:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005426:	04054163          	bltz	a0,80005468 <sys_read+0x5c>
    8000542a:	fe440593          	addi	a1,s0,-28
    8000542e:	4509                	li	a0,2
    80005430:	ffffe097          	auipc	ra,0xffffe
    80005434:	86e080e7          	jalr	-1938(ra) # 80002c9e <argint>
    return -1;
    80005438:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000543a:	02054763          	bltz	a0,80005468 <sys_read+0x5c>
    8000543e:	fd840593          	addi	a1,s0,-40
    80005442:	4505                	li	a0,1
    80005444:	ffffe097          	auipc	ra,0xffffe
    80005448:	87c080e7          	jalr	-1924(ra) # 80002cc0 <argaddr>
    return -1;
    8000544c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000544e:	00054d63          	bltz	a0,80005468 <sys_read+0x5c>
  return fileread(f, p, n);
    80005452:	fe442603          	lw	a2,-28(s0)
    80005456:	fd843583          	ld	a1,-40(s0)
    8000545a:	fe843503          	ld	a0,-24(s0)
    8000545e:	fffff097          	auipc	ra,0xfffff
    80005462:	41e080e7          	jalr	1054(ra) # 8000487c <fileread>
    80005466:	87aa                	mv	a5,a0
}
    80005468:	853e                	mv	a0,a5
    8000546a:	70a2                	ld	ra,40(sp)
    8000546c:	7402                	ld	s0,32(sp)
    8000546e:	6145                	addi	sp,sp,48
    80005470:	8082                	ret

0000000080005472 <sys_write>:
{
    80005472:	7179                	addi	sp,sp,-48
    80005474:	f406                	sd	ra,40(sp)
    80005476:	f022                	sd	s0,32(sp)
    80005478:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000547a:	fe840613          	addi	a2,s0,-24
    8000547e:	4581                	li	a1,0
    80005480:	4501                	li	a0,0
    80005482:	00000097          	auipc	ra,0x0
    80005486:	d24080e7          	jalr	-732(ra) # 800051a6 <argfd>
    return -1;
    8000548a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000548c:	04054163          	bltz	a0,800054ce <sys_write+0x5c>
    80005490:	fe440593          	addi	a1,s0,-28
    80005494:	4509                	li	a0,2
    80005496:	ffffe097          	auipc	ra,0xffffe
    8000549a:	808080e7          	jalr	-2040(ra) # 80002c9e <argint>
    return -1;
    8000549e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054a0:	02054763          	bltz	a0,800054ce <sys_write+0x5c>
    800054a4:	fd840593          	addi	a1,s0,-40
    800054a8:	4505                	li	a0,1
    800054aa:	ffffe097          	auipc	ra,0xffffe
    800054ae:	816080e7          	jalr	-2026(ra) # 80002cc0 <argaddr>
    return -1;
    800054b2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054b4:	00054d63          	bltz	a0,800054ce <sys_write+0x5c>
  return filewrite(f, p, n);
    800054b8:	fe442603          	lw	a2,-28(s0)
    800054bc:	fd843583          	ld	a1,-40(s0)
    800054c0:	fe843503          	ld	a0,-24(s0)
    800054c4:	fffff097          	auipc	ra,0xfffff
    800054c8:	47a080e7          	jalr	1146(ra) # 8000493e <filewrite>
    800054cc:	87aa                	mv	a5,a0
}
    800054ce:	853e                	mv	a0,a5
    800054d0:	70a2                	ld	ra,40(sp)
    800054d2:	7402                	ld	s0,32(sp)
    800054d4:	6145                	addi	sp,sp,48
    800054d6:	8082                	ret

00000000800054d8 <sys_close>:
{
    800054d8:	1101                	addi	sp,sp,-32
    800054da:	ec06                	sd	ra,24(sp)
    800054dc:	e822                	sd	s0,16(sp)
    800054de:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054e0:	fe040613          	addi	a2,s0,-32
    800054e4:	fec40593          	addi	a1,s0,-20
    800054e8:	4501                	li	a0,0
    800054ea:	00000097          	auipc	ra,0x0
    800054ee:	cbc080e7          	jalr	-836(ra) # 800051a6 <argfd>
    return -1;
    800054f2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054f4:	02054463          	bltz	a0,8000551c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054f8:	ffffc097          	auipc	ra,0xffffc
    800054fc:	6ac080e7          	jalr	1708(ra) # 80001ba4 <myproc>
    80005500:	fec42783          	lw	a5,-20(s0)
    80005504:	07e9                	addi	a5,a5,26
    80005506:	078e                	slli	a5,a5,0x3
    80005508:	953e                	add	a0,a0,a5
    8000550a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000550e:	fe043503          	ld	a0,-32(s0)
    80005512:	fffff097          	auipc	ra,0xfffff
    80005516:	230080e7          	jalr	560(ra) # 80004742 <fileclose>
  return 0;
    8000551a:	4781                	li	a5,0
}
    8000551c:	853e                	mv	a0,a5
    8000551e:	60e2                	ld	ra,24(sp)
    80005520:	6442                	ld	s0,16(sp)
    80005522:	6105                	addi	sp,sp,32
    80005524:	8082                	ret

0000000080005526 <sys_fstat>:
{
    80005526:	1101                	addi	sp,sp,-32
    80005528:	ec06                	sd	ra,24(sp)
    8000552a:	e822                	sd	s0,16(sp)
    8000552c:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000552e:	fe840613          	addi	a2,s0,-24
    80005532:	4581                	li	a1,0
    80005534:	4501                	li	a0,0
    80005536:	00000097          	auipc	ra,0x0
    8000553a:	c70080e7          	jalr	-912(ra) # 800051a6 <argfd>
    return -1;
    8000553e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005540:	02054563          	bltz	a0,8000556a <sys_fstat+0x44>
    80005544:	fe040593          	addi	a1,s0,-32
    80005548:	4505                	li	a0,1
    8000554a:	ffffd097          	auipc	ra,0xffffd
    8000554e:	776080e7          	jalr	1910(ra) # 80002cc0 <argaddr>
    return -1;
    80005552:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005554:	00054b63          	bltz	a0,8000556a <sys_fstat+0x44>
  return filestat(f, st);
    80005558:	fe043583          	ld	a1,-32(s0)
    8000555c:	fe843503          	ld	a0,-24(s0)
    80005560:	fffff097          	auipc	ra,0xfffff
    80005564:	2aa080e7          	jalr	682(ra) # 8000480a <filestat>
    80005568:	87aa                	mv	a5,a0
}
    8000556a:	853e                	mv	a0,a5
    8000556c:	60e2                	ld	ra,24(sp)
    8000556e:	6442                	ld	s0,16(sp)
    80005570:	6105                	addi	sp,sp,32
    80005572:	8082                	ret

0000000080005574 <sys_link>:
{
    80005574:	7169                	addi	sp,sp,-304
    80005576:	f606                	sd	ra,296(sp)
    80005578:	f222                	sd	s0,288(sp)
    8000557a:	ee26                	sd	s1,280(sp)
    8000557c:	ea4a                	sd	s2,272(sp)
    8000557e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005580:	08000613          	li	a2,128
    80005584:	ed040593          	addi	a1,s0,-304
    80005588:	4501                	li	a0,0
    8000558a:	ffffd097          	auipc	ra,0xffffd
    8000558e:	758080e7          	jalr	1880(ra) # 80002ce2 <argstr>
    return -1;
    80005592:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005594:	10054e63          	bltz	a0,800056b0 <sys_link+0x13c>
    80005598:	08000613          	li	a2,128
    8000559c:	f5040593          	addi	a1,s0,-176
    800055a0:	4505                	li	a0,1
    800055a2:	ffffd097          	auipc	ra,0xffffd
    800055a6:	740080e7          	jalr	1856(ra) # 80002ce2 <argstr>
    return -1;
    800055aa:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055ac:	10054263          	bltz	a0,800056b0 <sys_link+0x13c>
  begin_op();
    800055b0:	fffff097          	auipc	ra,0xfffff
    800055b4:	c90080e7          	jalr	-880(ra) # 80004240 <begin_op>
  if((ip = namei(old)) == 0){
    800055b8:	ed040513          	addi	a0,s0,-304
    800055bc:	fffff097          	auipc	ra,0xfffff
    800055c0:	a76080e7          	jalr	-1418(ra) # 80004032 <namei>
    800055c4:	84aa                	mv	s1,a0
    800055c6:	c551                	beqz	a0,80005652 <sys_link+0xde>
  ilock(ip);
    800055c8:	ffffe097          	auipc	ra,0xffffe
    800055cc:	2ac080e7          	jalr	684(ra) # 80003874 <ilock>
  if(ip->type == T_DIR){
    800055d0:	04449703          	lh	a4,68(s1)
    800055d4:	4785                	li	a5,1
    800055d6:	08f70463          	beq	a4,a5,8000565e <sys_link+0xea>
  ip->nlink++;
    800055da:	04a4d783          	lhu	a5,74(s1)
    800055de:	2785                	addiw	a5,a5,1
    800055e0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055e4:	8526                	mv	a0,s1
    800055e6:	ffffe097          	auipc	ra,0xffffe
    800055ea:	1c2080e7          	jalr	450(ra) # 800037a8 <iupdate>
  iunlock(ip);
    800055ee:	8526                	mv	a0,s1
    800055f0:	ffffe097          	auipc	ra,0xffffe
    800055f4:	348080e7          	jalr	840(ra) # 80003938 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055f8:	fd040593          	addi	a1,s0,-48
    800055fc:	f5040513          	addi	a0,s0,-176
    80005600:	fffff097          	auipc	ra,0xfffff
    80005604:	a50080e7          	jalr	-1456(ra) # 80004050 <nameiparent>
    80005608:	892a                	mv	s2,a0
    8000560a:	c935                	beqz	a0,8000567e <sys_link+0x10a>
  ilock(dp);
    8000560c:	ffffe097          	auipc	ra,0xffffe
    80005610:	268080e7          	jalr	616(ra) # 80003874 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005614:	00092703          	lw	a4,0(s2)
    80005618:	409c                	lw	a5,0(s1)
    8000561a:	04f71d63          	bne	a4,a5,80005674 <sys_link+0x100>
    8000561e:	40d0                	lw	a2,4(s1)
    80005620:	fd040593          	addi	a1,s0,-48
    80005624:	854a                	mv	a0,s2
    80005626:	fffff097          	auipc	ra,0xfffff
    8000562a:	94a080e7          	jalr	-1718(ra) # 80003f70 <dirlink>
    8000562e:	04054363          	bltz	a0,80005674 <sys_link+0x100>
  iunlockput(dp);
    80005632:	854a                	mv	a0,s2
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	4a4080e7          	jalr	1188(ra) # 80003ad8 <iunlockput>
  iput(ip);
    8000563c:	8526                	mv	a0,s1
    8000563e:	ffffe097          	auipc	ra,0xffffe
    80005642:	3f2080e7          	jalr	1010(ra) # 80003a30 <iput>
  end_op();
    80005646:	fffff097          	auipc	ra,0xfffff
    8000564a:	c7a080e7          	jalr	-902(ra) # 800042c0 <end_op>
  return 0;
    8000564e:	4781                	li	a5,0
    80005650:	a085                	j	800056b0 <sys_link+0x13c>
    end_op();
    80005652:	fffff097          	auipc	ra,0xfffff
    80005656:	c6e080e7          	jalr	-914(ra) # 800042c0 <end_op>
    return -1;
    8000565a:	57fd                	li	a5,-1
    8000565c:	a891                	j	800056b0 <sys_link+0x13c>
    iunlockput(ip);
    8000565e:	8526                	mv	a0,s1
    80005660:	ffffe097          	auipc	ra,0xffffe
    80005664:	478080e7          	jalr	1144(ra) # 80003ad8 <iunlockput>
    end_op();
    80005668:	fffff097          	auipc	ra,0xfffff
    8000566c:	c58080e7          	jalr	-936(ra) # 800042c0 <end_op>
    return -1;
    80005670:	57fd                	li	a5,-1
    80005672:	a83d                	j	800056b0 <sys_link+0x13c>
    iunlockput(dp);
    80005674:	854a                	mv	a0,s2
    80005676:	ffffe097          	auipc	ra,0xffffe
    8000567a:	462080e7          	jalr	1122(ra) # 80003ad8 <iunlockput>
  ilock(ip);
    8000567e:	8526                	mv	a0,s1
    80005680:	ffffe097          	auipc	ra,0xffffe
    80005684:	1f4080e7          	jalr	500(ra) # 80003874 <ilock>
  ip->nlink--;
    80005688:	04a4d783          	lhu	a5,74(s1)
    8000568c:	37fd                	addiw	a5,a5,-1
    8000568e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005692:	8526                	mv	a0,s1
    80005694:	ffffe097          	auipc	ra,0xffffe
    80005698:	114080e7          	jalr	276(ra) # 800037a8 <iupdate>
  iunlockput(ip);
    8000569c:	8526                	mv	a0,s1
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	43a080e7          	jalr	1082(ra) # 80003ad8 <iunlockput>
  end_op();
    800056a6:	fffff097          	auipc	ra,0xfffff
    800056aa:	c1a080e7          	jalr	-998(ra) # 800042c0 <end_op>
  return -1;
    800056ae:	57fd                	li	a5,-1
}
    800056b0:	853e                	mv	a0,a5
    800056b2:	70b2                	ld	ra,296(sp)
    800056b4:	7412                	ld	s0,288(sp)
    800056b6:	64f2                	ld	s1,280(sp)
    800056b8:	6952                	ld	s2,272(sp)
    800056ba:	6155                	addi	sp,sp,304
    800056bc:	8082                	ret

00000000800056be <sys_unlink>:
{
    800056be:	7151                	addi	sp,sp,-240
    800056c0:	f586                	sd	ra,232(sp)
    800056c2:	f1a2                	sd	s0,224(sp)
    800056c4:	eda6                	sd	s1,216(sp)
    800056c6:	e9ca                	sd	s2,208(sp)
    800056c8:	e5ce                	sd	s3,200(sp)
    800056ca:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056cc:	08000613          	li	a2,128
    800056d0:	f3040593          	addi	a1,s0,-208
    800056d4:	4501                	li	a0,0
    800056d6:	ffffd097          	auipc	ra,0xffffd
    800056da:	60c080e7          	jalr	1548(ra) # 80002ce2 <argstr>
    800056de:	18054963          	bltz	a0,80005870 <sys_unlink+0x1b2>
  printf("unlink: %s", path);
    800056e2:	f3040593          	addi	a1,s0,-208
    800056e6:	00003517          	auipc	a0,0x3
    800056ea:	ffa50513          	addi	a0,a0,-6 # 800086e0 <syscalls+0x310>
    800056ee:	ffffb097          	auipc	ra,0xffffb
    800056f2:	ed0080e7          	jalr	-304(ra) # 800005be <printf>
  begin_op();
    800056f6:	fffff097          	auipc	ra,0xfffff
    800056fa:	b4a080e7          	jalr	-1206(ra) # 80004240 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056fe:	fb040593          	addi	a1,s0,-80
    80005702:	f3040513          	addi	a0,s0,-208
    80005706:	fffff097          	auipc	ra,0xfffff
    8000570a:	94a080e7          	jalr	-1718(ra) # 80004050 <nameiparent>
    8000570e:	89aa                	mv	s3,a0
    80005710:	c979                	beqz	a0,800057e6 <sys_unlink+0x128>
  ilock(dp);
    80005712:	ffffe097          	auipc	ra,0xffffe
    80005716:	162080e7          	jalr	354(ra) # 80003874 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000571a:	00003597          	auipc	a1,0x3
    8000571e:	f9e58593          	addi	a1,a1,-98 # 800086b8 <syscalls+0x2e8>
    80005722:	fb040513          	addi	a0,s0,-80
    80005726:	ffffe097          	auipc	ra,0xffffe
    8000572a:	618080e7          	jalr	1560(ra) # 80003d3e <namecmp>
    8000572e:	14050863          	beqz	a0,8000587e <sys_unlink+0x1c0>
    80005732:	00003597          	auipc	a1,0x3
    80005736:	a1e58593          	addi	a1,a1,-1506 # 80008150 <digits+0x138>
    8000573a:	fb040513          	addi	a0,s0,-80
    8000573e:	ffffe097          	auipc	ra,0xffffe
    80005742:	600080e7          	jalr	1536(ra) # 80003d3e <namecmp>
    80005746:	12050c63          	beqz	a0,8000587e <sys_unlink+0x1c0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000574a:	f2c40613          	addi	a2,s0,-212
    8000574e:	fb040593          	addi	a1,s0,-80
    80005752:	854e                	mv	a0,s3
    80005754:	ffffe097          	auipc	ra,0xffffe
    80005758:	604080e7          	jalr	1540(ra) # 80003d58 <dirlookup>
    8000575c:	84aa                	mv	s1,a0
    8000575e:	12050063          	beqz	a0,8000587e <sys_unlink+0x1c0>
  ilock(ip);
    80005762:	ffffe097          	auipc	ra,0xffffe
    80005766:	112080e7          	jalr	274(ra) # 80003874 <ilock>
  if(ip->nlink < 1)
    8000576a:	04a49783          	lh	a5,74(s1)
    8000576e:	08f05263          	blez	a5,800057f2 <sys_unlink+0x134>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005772:	04449703          	lh	a4,68(s1)
    80005776:	4785                	li	a5,1
    80005778:	08f70563          	beq	a4,a5,80005802 <sys_unlink+0x144>
  memset(&de, 0, sizeof(de));
    8000577c:	4641                	li	a2,16
    8000577e:	4581                	li	a1,0
    80005780:	fc040513          	addi	a0,s0,-64
    80005784:	ffffb097          	auipc	ra,0xffffb
    80005788:	5da080e7          	jalr	1498(ra) # 80000d5e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000578c:	4741                	li	a4,16
    8000578e:	f2c42683          	lw	a3,-212(s0)
    80005792:	fc040613          	addi	a2,s0,-64
    80005796:	4581                	li	a1,0
    80005798:	854e                	mv	a0,s3
    8000579a:	ffffe097          	auipc	ra,0xffffe
    8000579e:	488080e7          	jalr	1160(ra) # 80003c22 <writei>
    800057a2:	47c1                	li	a5,16
    800057a4:	0af51363          	bne	a0,a5,8000584a <sys_unlink+0x18c>
  if(ip->type == T_DIR){
    800057a8:	04449703          	lh	a4,68(s1)
    800057ac:	4785                	li	a5,1
    800057ae:	0af70663          	beq	a4,a5,8000585a <sys_unlink+0x19c>
  iunlockput(dp);
    800057b2:	854e                	mv	a0,s3
    800057b4:	ffffe097          	auipc	ra,0xffffe
    800057b8:	324080e7          	jalr	804(ra) # 80003ad8 <iunlockput>
  ip->nlink--;
    800057bc:	04a4d783          	lhu	a5,74(s1)
    800057c0:	37fd                	addiw	a5,a5,-1
    800057c2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057c6:	8526                	mv	a0,s1
    800057c8:	ffffe097          	auipc	ra,0xffffe
    800057cc:	fe0080e7          	jalr	-32(ra) # 800037a8 <iupdate>
  iunlockput(ip);
    800057d0:	8526                	mv	a0,s1
    800057d2:	ffffe097          	auipc	ra,0xffffe
    800057d6:	306080e7          	jalr	774(ra) # 80003ad8 <iunlockput>
  end_op();
    800057da:	fffff097          	auipc	ra,0xfffff
    800057de:	ae6080e7          	jalr	-1306(ra) # 800042c0 <end_op>
  return 0;
    800057e2:	4501                	li	a0,0
    800057e4:	a07d                	j	80005892 <sys_unlink+0x1d4>
    end_op();
    800057e6:	fffff097          	auipc	ra,0xfffff
    800057ea:	ada080e7          	jalr	-1318(ra) # 800042c0 <end_op>
    return -1;
    800057ee:	557d                	li	a0,-1
    800057f0:	a04d                	j	80005892 <sys_unlink+0x1d4>
    panic("unlink: nlink < 1");
    800057f2:	00003517          	auipc	a0,0x3
    800057f6:	efe50513          	addi	a0,a0,-258 # 800086f0 <syscalls+0x320>
    800057fa:	ffffb097          	auipc	ra,0xffffb
    800057fe:	d7a080e7          	jalr	-646(ra) # 80000574 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005802:	44f8                	lw	a4,76(s1)
    80005804:	02000793          	li	a5,32
    80005808:	f6e7fae3          	bleu	a4,a5,8000577c <sys_unlink+0xbe>
    8000580c:	02000913          	li	s2,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005810:	4741                	li	a4,16
    80005812:	86ca                	mv	a3,s2
    80005814:	f1840613          	addi	a2,s0,-232
    80005818:	4581                	li	a1,0
    8000581a:	8526                	mv	a0,s1
    8000581c:	ffffe097          	auipc	ra,0xffffe
    80005820:	30e080e7          	jalr	782(ra) # 80003b2a <readi>
    80005824:	47c1                	li	a5,16
    80005826:	00f51a63          	bne	a0,a5,8000583a <sys_unlink+0x17c>
    if(de.inum != 0)
    8000582a:	f1845783          	lhu	a5,-232(s0)
    8000582e:	e3b9                	bnez	a5,80005874 <sys_unlink+0x1b6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005830:	2941                	addiw	s2,s2,16
    80005832:	44fc                	lw	a5,76(s1)
    80005834:	fcf96ee3          	bltu	s2,a5,80005810 <sys_unlink+0x152>
    80005838:	b791                	j	8000577c <sys_unlink+0xbe>
      panic("isdirempty: readi");
    8000583a:	00003517          	auipc	a0,0x3
    8000583e:	ece50513          	addi	a0,a0,-306 # 80008708 <syscalls+0x338>
    80005842:	ffffb097          	auipc	ra,0xffffb
    80005846:	d32080e7          	jalr	-718(ra) # 80000574 <panic>
    panic("unlink: writei");
    8000584a:	00003517          	auipc	a0,0x3
    8000584e:	ed650513          	addi	a0,a0,-298 # 80008720 <syscalls+0x350>
    80005852:	ffffb097          	auipc	ra,0xffffb
    80005856:	d22080e7          	jalr	-734(ra) # 80000574 <panic>
    dp->nlink--;
    8000585a:	04a9d783          	lhu	a5,74(s3)
    8000585e:	37fd                	addiw	a5,a5,-1
    80005860:	04f99523          	sh	a5,74(s3)
    iupdate(dp);
    80005864:	854e                	mv	a0,s3
    80005866:	ffffe097          	auipc	ra,0xffffe
    8000586a:	f42080e7          	jalr	-190(ra) # 800037a8 <iupdate>
    8000586e:	b791                	j	800057b2 <sys_unlink+0xf4>
    return -1;
    80005870:	557d                	li	a0,-1
    80005872:	a005                	j	80005892 <sys_unlink+0x1d4>
    iunlockput(ip);
    80005874:	8526                	mv	a0,s1
    80005876:	ffffe097          	auipc	ra,0xffffe
    8000587a:	262080e7          	jalr	610(ra) # 80003ad8 <iunlockput>
  iunlockput(dp);
    8000587e:	854e                	mv	a0,s3
    80005880:	ffffe097          	auipc	ra,0xffffe
    80005884:	258080e7          	jalr	600(ra) # 80003ad8 <iunlockput>
  end_op();
    80005888:	fffff097          	auipc	ra,0xfffff
    8000588c:	a38080e7          	jalr	-1480(ra) # 800042c0 <end_op>
  return -1;
    80005890:	557d                	li	a0,-1
}
    80005892:	70ae                	ld	ra,232(sp)
    80005894:	740e                	ld	s0,224(sp)
    80005896:	64ee                	ld	s1,216(sp)
    80005898:	694e                	ld	s2,208(sp)
    8000589a:	69ae                	ld	s3,200(sp)
    8000589c:	616d                	addi	sp,sp,240
    8000589e:	8082                	ret

00000000800058a0 <sys_open>:

uint64
sys_open(void)
{
    800058a0:	7131                	addi	sp,sp,-192
    800058a2:	fd06                	sd	ra,184(sp)
    800058a4:	f922                	sd	s0,176(sp)
    800058a6:	f526                	sd	s1,168(sp)
    800058a8:	f14a                	sd	s2,160(sp)
    800058aa:	ed4e                	sd	s3,152(sp)
    800058ac:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058ae:	08000613          	li	a2,128
    800058b2:	f5040593          	addi	a1,s0,-176
    800058b6:	4501                	li	a0,0
    800058b8:	ffffd097          	auipc	ra,0xffffd
    800058bc:	42a080e7          	jalr	1066(ra) # 80002ce2 <argstr>
    return -1;
    800058c0:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058c2:	0c054163          	bltz	a0,80005984 <sys_open+0xe4>
    800058c6:	f4c40593          	addi	a1,s0,-180
    800058ca:	4505                	li	a0,1
    800058cc:	ffffd097          	auipc	ra,0xffffd
    800058d0:	3d2080e7          	jalr	978(ra) # 80002c9e <argint>
    800058d4:	0a054863          	bltz	a0,80005984 <sys_open+0xe4>

  begin_op();
    800058d8:	fffff097          	auipc	ra,0xfffff
    800058dc:	968080e7          	jalr	-1688(ra) # 80004240 <begin_op>

  if(omode & O_CREATE){
    800058e0:	f4c42783          	lw	a5,-180(s0)
    800058e4:	2007f793          	andi	a5,a5,512
    800058e8:	cbdd                	beqz	a5,8000599e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800058ea:	4681                	li	a3,0
    800058ec:	4601                	li	a2,0
    800058ee:	4589                	li	a1,2
    800058f0:	f5040513          	addi	a0,s0,-176
    800058f4:	00000097          	auipc	ra,0x0
    800058f8:	962080e7          	jalr	-1694(ra) # 80005256 <create>
    800058fc:	892a                	mv	s2,a0
    if(ip == 0){
    800058fe:	c959                	beqz	a0,80005994 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005900:	04491703          	lh	a4,68(s2)
    80005904:	478d                	li	a5,3
    80005906:	00f71763          	bne	a4,a5,80005914 <sys_open+0x74>
    8000590a:	04695703          	lhu	a4,70(s2)
    8000590e:	47a5                	li	a5,9
    80005910:	0ce7ec63          	bltu	a5,a4,800059e8 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005914:	fffff097          	auipc	ra,0xfffff
    80005918:	d5e080e7          	jalr	-674(ra) # 80004672 <filealloc>
    8000591c:	89aa                	mv	s3,a0
    8000591e:	10050263          	beqz	a0,80005a22 <sys_open+0x182>
    80005922:	00000097          	auipc	ra,0x0
    80005926:	8ec080e7          	jalr	-1812(ra) # 8000520e <fdalloc>
    8000592a:	84aa                	mv	s1,a0
    8000592c:	0e054663          	bltz	a0,80005a18 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005930:	04491703          	lh	a4,68(s2)
    80005934:	478d                	li	a5,3
    80005936:	0cf70463          	beq	a4,a5,800059fe <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000593a:	4789                	li	a5,2
    8000593c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005940:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005944:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005948:	f4c42783          	lw	a5,-180(s0)
    8000594c:	0017c713          	xori	a4,a5,1
    80005950:	8b05                	andi	a4,a4,1
    80005952:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005956:	0037f713          	andi	a4,a5,3
    8000595a:	00e03733          	snez	a4,a4
    8000595e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005962:	4007f793          	andi	a5,a5,1024
    80005966:	c791                	beqz	a5,80005972 <sys_open+0xd2>
    80005968:	04491703          	lh	a4,68(s2)
    8000596c:	4789                	li	a5,2
    8000596e:	08f70f63          	beq	a4,a5,80005a0c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005972:	854a                	mv	a0,s2
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	fc4080e7          	jalr	-60(ra) # 80003938 <iunlock>
  end_op();
    8000597c:	fffff097          	auipc	ra,0xfffff
    80005980:	944080e7          	jalr	-1724(ra) # 800042c0 <end_op>

  return fd;
}
    80005984:	8526                	mv	a0,s1
    80005986:	70ea                	ld	ra,184(sp)
    80005988:	744a                	ld	s0,176(sp)
    8000598a:	74aa                	ld	s1,168(sp)
    8000598c:	790a                	ld	s2,160(sp)
    8000598e:	69ea                	ld	s3,152(sp)
    80005990:	6129                	addi	sp,sp,192
    80005992:	8082                	ret
      end_op();
    80005994:	fffff097          	auipc	ra,0xfffff
    80005998:	92c080e7          	jalr	-1748(ra) # 800042c0 <end_op>
      return -1;
    8000599c:	b7e5                	j	80005984 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000599e:	f5040513          	addi	a0,s0,-176
    800059a2:	ffffe097          	auipc	ra,0xffffe
    800059a6:	690080e7          	jalr	1680(ra) # 80004032 <namei>
    800059aa:	892a                	mv	s2,a0
    800059ac:	c905                	beqz	a0,800059dc <sys_open+0x13c>
    ilock(ip);
    800059ae:	ffffe097          	auipc	ra,0xffffe
    800059b2:	ec6080e7          	jalr	-314(ra) # 80003874 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059b6:	04491703          	lh	a4,68(s2)
    800059ba:	4785                	li	a5,1
    800059bc:	f4f712e3          	bne	a4,a5,80005900 <sys_open+0x60>
    800059c0:	f4c42783          	lw	a5,-180(s0)
    800059c4:	dba1                	beqz	a5,80005914 <sys_open+0x74>
      iunlockput(ip);
    800059c6:	854a                	mv	a0,s2
    800059c8:	ffffe097          	auipc	ra,0xffffe
    800059cc:	110080e7          	jalr	272(ra) # 80003ad8 <iunlockput>
      end_op();
    800059d0:	fffff097          	auipc	ra,0xfffff
    800059d4:	8f0080e7          	jalr	-1808(ra) # 800042c0 <end_op>
      return -1;
    800059d8:	54fd                	li	s1,-1
    800059da:	b76d                	j	80005984 <sys_open+0xe4>
      end_op();
    800059dc:	fffff097          	auipc	ra,0xfffff
    800059e0:	8e4080e7          	jalr	-1820(ra) # 800042c0 <end_op>
      return -1;
    800059e4:	54fd                	li	s1,-1
    800059e6:	bf79                	j	80005984 <sys_open+0xe4>
    iunlockput(ip);
    800059e8:	854a                	mv	a0,s2
    800059ea:	ffffe097          	auipc	ra,0xffffe
    800059ee:	0ee080e7          	jalr	238(ra) # 80003ad8 <iunlockput>
    end_op();
    800059f2:	fffff097          	auipc	ra,0xfffff
    800059f6:	8ce080e7          	jalr	-1842(ra) # 800042c0 <end_op>
    return -1;
    800059fa:	54fd                	li	s1,-1
    800059fc:	b761                	j	80005984 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800059fe:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a02:	04691783          	lh	a5,70(s2)
    80005a06:	02f99223          	sh	a5,36(s3)
    80005a0a:	bf2d                	j	80005944 <sys_open+0xa4>
    itrunc(ip);
    80005a0c:	854a                	mv	a0,s2
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	f76080e7          	jalr	-138(ra) # 80003984 <itrunc>
    80005a16:	bfb1                	j	80005972 <sys_open+0xd2>
      fileclose(f);
    80005a18:	854e                	mv	a0,s3
    80005a1a:	fffff097          	auipc	ra,0xfffff
    80005a1e:	d28080e7          	jalr	-728(ra) # 80004742 <fileclose>
    iunlockput(ip);
    80005a22:	854a                	mv	a0,s2
    80005a24:	ffffe097          	auipc	ra,0xffffe
    80005a28:	0b4080e7          	jalr	180(ra) # 80003ad8 <iunlockput>
    end_op();
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	894080e7          	jalr	-1900(ra) # 800042c0 <end_op>
    return -1;
    80005a34:	54fd                	li	s1,-1
    80005a36:	b7b9                	j	80005984 <sys_open+0xe4>

0000000080005a38 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a38:	7175                	addi	sp,sp,-144
    80005a3a:	e506                	sd	ra,136(sp)
    80005a3c:	e122                	sd	s0,128(sp)
    80005a3e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a40:	fffff097          	auipc	ra,0xfffff
    80005a44:	800080e7          	jalr	-2048(ra) # 80004240 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a48:	08000613          	li	a2,128
    80005a4c:	f7040593          	addi	a1,s0,-144
    80005a50:	4501                	li	a0,0
    80005a52:	ffffd097          	auipc	ra,0xffffd
    80005a56:	290080e7          	jalr	656(ra) # 80002ce2 <argstr>
    80005a5a:	02054963          	bltz	a0,80005a8c <sys_mkdir+0x54>
    80005a5e:	4681                	li	a3,0
    80005a60:	4601                	li	a2,0
    80005a62:	4585                	li	a1,1
    80005a64:	f7040513          	addi	a0,s0,-144
    80005a68:	fffff097          	auipc	ra,0xfffff
    80005a6c:	7ee080e7          	jalr	2030(ra) # 80005256 <create>
    80005a70:	cd11                	beqz	a0,80005a8c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a72:	ffffe097          	auipc	ra,0xffffe
    80005a76:	066080e7          	jalr	102(ra) # 80003ad8 <iunlockput>
  end_op();
    80005a7a:	fffff097          	auipc	ra,0xfffff
    80005a7e:	846080e7          	jalr	-1978(ra) # 800042c0 <end_op>
  return 0;
    80005a82:	4501                	li	a0,0
}
    80005a84:	60aa                	ld	ra,136(sp)
    80005a86:	640a                	ld	s0,128(sp)
    80005a88:	6149                	addi	sp,sp,144
    80005a8a:	8082                	ret
    end_op();
    80005a8c:	fffff097          	auipc	ra,0xfffff
    80005a90:	834080e7          	jalr	-1996(ra) # 800042c0 <end_op>
    return -1;
    80005a94:	557d                	li	a0,-1
    80005a96:	b7fd                	j	80005a84 <sys_mkdir+0x4c>

0000000080005a98 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a98:	7135                	addi	sp,sp,-160
    80005a9a:	ed06                	sd	ra,152(sp)
    80005a9c:	e922                	sd	s0,144(sp)
    80005a9e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005aa0:	ffffe097          	auipc	ra,0xffffe
    80005aa4:	7a0080e7          	jalr	1952(ra) # 80004240 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005aa8:	08000613          	li	a2,128
    80005aac:	f7040593          	addi	a1,s0,-144
    80005ab0:	4501                	li	a0,0
    80005ab2:	ffffd097          	auipc	ra,0xffffd
    80005ab6:	230080e7          	jalr	560(ra) # 80002ce2 <argstr>
    80005aba:	04054a63          	bltz	a0,80005b0e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005abe:	f6c40593          	addi	a1,s0,-148
    80005ac2:	4505                	li	a0,1
    80005ac4:	ffffd097          	auipc	ra,0xffffd
    80005ac8:	1da080e7          	jalr	474(ra) # 80002c9e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005acc:	04054163          	bltz	a0,80005b0e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005ad0:	f6840593          	addi	a1,s0,-152
    80005ad4:	4509                	li	a0,2
    80005ad6:	ffffd097          	auipc	ra,0xffffd
    80005ada:	1c8080e7          	jalr	456(ra) # 80002c9e <argint>
     argint(1, &major) < 0 ||
    80005ade:	02054863          	bltz	a0,80005b0e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ae2:	f6841683          	lh	a3,-152(s0)
    80005ae6:	f6c41603          	lh	a2,-148(s0)
    80005aea:	458d                	li	a1,3
    80005aec:	f7040513          	addi	a0,s0,-144
    80005af0:	fffff097          	auipc	ra,0xfffff
    80005af4:	766080e7          	jalr	1894(ra) # 80005256 <create>
     argint(2, &minor) < 0 ||
    80005af8:	c919                	beqz	a0,80005b0e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005afa:	ffffe097          	auipc	ra,0xffffe
    80005afe:	fde080e7          	jalr	-34(ra) # 80003ad8 <iunlockput>
  end_op();
    80005b02:	ffffe097          	auipc	ra,0xffffe
    80005b06:	7be080e7          	jalr	1982(ra) # 800042c0 <end_op>
  return 0;
    80005b0a:	4501                	li	a0,0
    80005b0c:	a031                	j	80005b18 <sys_mknod+0x80>
    end_op();
    80005b0e:	ffffe097          	auipc	ra,0xffffe
    80005b12:	7b2080e7          	jalr	1970(ra) # 800042c0 <end_op>
    return -1;
    80005b16:	557d                	li	a0,-1
}
    80005b18:	60ea                	ld	ra,152(sp)
    80005b1a:	644a                	ld	s0,144(sp)
    80005b1c:	610d                	addi	sp,sp,160
    80005b1e:	8082                	ret

0000000080005b20 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b20:	7135                	addi	sp,sp,-160
    80005b22:	ed06                	sd	ra,152(sp)
    80005b24:	e922                	sd	s0,144(sp)
    80005b26:	e526                	sd	s1,136(sp)
    80005b28:	e14a                	sd	s2,128(sp)
    80005b2a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b2c:	ffffc097          	auipc	ra,0xffffc
    80005b30:	078080e7          	jalr	120(ra) # 80001ba4 <myproc>
    80005b34:	892a                	mv	s2,a0
  
  begin_op();
    80005b36:	ffffe097          	auipc	ra,0xffffe
    80005b3a:	70a080e7          	jalr	1802(ra) # 80004240 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b3e:	08000613          	li	a2,128
    80005b42:	f6040593          	addi	a1,s0,-160
    80005b46:	4501                	li	a0,0
    80005b48:	ffffd097          	auipc	ra,0xffffd
    80005b4c:	19a080e7          	jalr	410(ra) # 80002ce2 <argstr>
    80005b50:	04054b63          	bltz	a0,80005ba6 <sys_chdir+0x86>
    80005b54:	f6040513          	addi	a0,s0,-160
    80005b58:	ffffe097          	auipc	ra,0xffffe
    80005b5c:	4da080e7          	jalr	1242(ra) # 80004032 <namei>
    80005b60:	84aa                	mv	s1,a0
    80005b62:	c131                	beqz	a0,80005ba6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b64:	ffffe097          	auipc	ra,0xffffe
    80005b68:	d10080e7          	jalr	-752(ra) # 80003874 <ilock>
  if(ip->type != T_DIR){
    80005b6c:	04449703          	lh	a4,68(s1)
    80005b70:	4785                	li	a5,1
    80005b72:	04f71063          	bne	a4,a5,80005bb2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b76:	8526                	mv	a0,s1
    80005b78:	ffffe097          	auipc	ra,0xffffe
    80005b7c:	dc0080e7          	jalr	-576(ra) # 80003938 <iunlock>
  iput(p->cwd);
    80005b80:	15093503          	ld	a0,336(s2)
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	eac080e7          	jalr	-340(ra) # 80003a30 <iput>
  end_op();
    80005b8c:	ffffe097          	auipc	ra,0xffffe
    80005b90:	734080e7          	jalr	1844(ra) # 800042c0 <end_op>
  p->cwd = ip;
    80005b94:	14993823          	sd	s1,336(s2)
  return 0;
    80005b98:	4501                	li	a0,0
}
    80005b9a:	60ea                	ld	ra,152(sp)
    80005b9c:	644a                	ld	s0,144(sp)
    80005b9e:	64aa                	ld	s1,136(sp)
    80005ba0:	690a                	ld	s2,128(sp)
    80005ba2:	610d                	addi	sp,sp,160
    80005ba4:	8082                	ret
    end_op();
    80005ba6:	ffffe097          	auipc	ra,0xffffe
    80005baa:	71a080e7          	jalr	1818(ra) # 800042c0 <end_op>
    return -1;
    80005bae:	557d                	li	a0,-1
    80005bb0:	b7ed                	j	80005b9a <sys_chdir+0x7a>
    iunlockput(ip);
    80005bb2:	8526                	mv	a0,s1
    80005bb4:	ffffe097          	auipc	ra,0xffffe
    80005bb8:	f24080e7          	jalr	-220(ra) # 80003ad8 <iunlockput>
    end_op();
    80005bbc:	ffffe097          	auipc	ra,0xffffe
    80005bc0:	704080e7          	jalr	1796(ra) # 800042c0 <end_op>
    return -1;
    80005bc4:	557d                	li	a0,-1
    80005bc6:	bfd1                	j	80005b9a <sys_chdir+0x7a>

0000000080005bc8 <sys_exec>:

uint64
sys_exec(void)
{
    80005bc8:	7145                	addi	sp,sp,-464
    80005bca:	e786                	sd	ra,456(sp)
    80005bcc:	e3a2                	sd	s0,448(sp)
    80005bce:	ff26                	sd	s1,440(sp)
    80005bd0:	fb4a                	sd	s2,432(sp)
    80005bd2:	f74e                	sd	s3,424(sp)
    80005bd4:	f352                	sd	s4,416(sp)
    80005bd6:	ef56                	sd	s5,408(sp)
    80005bd8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bda:	08000613          	li	a2,128
    80005bde:	f4040593          	addi	a1,s0,-192
    80005be2:	4501                	li	a0,0
    80005be4:	ffffd097          	auipc	ra,0xffffd
    80005be8:	0fe080e7          	jalr	254(ra) # 80002ce2 <argstr>
    return -1;
    80005bec:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bee:	0e054c63          	bltz	a0,80005ce6 <sys_exec+0x11e>
    80005bf2:	e3840593          	addi	a1,s0,-456
    80005bf6:	4505                	li	a0,1
    80005bf8:	ffffd097          	auipc	ra,0xffffd
    80005bfc:	0c8080e7          	jalr	200(ra) # 80002cc0 <argaddr>
    80005c00:	0e054363          	bltz	a0,80005ce6 <sys_exec+0x11e>
  }
  memset(argv, 0, sizeof(argv));
    80005c04:	e4040913          	addi	s2,s0,-448
    80005c08:	10000613          	li	a2,256
    80005c0c:	4581                	li	a1,0
    80005c0e:	854a                	mv	a0,s2
    80005c10:	ffffb097          	auipc	ra,0xffffb
    80005c14:	14e080e7          	jalr	334(ra) # 80000d5e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c18:	89ca                	mv	s3,s2
  memset(argv, 0, sizeof(argv));
    80005c1a:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005c1c:	02000a93          	li	s5,32
    80005c20:	00048a1b          	sext.w	s4,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c24:	00349513          	slli	a0,s1,0x3
    80005c28:	e3040593          	addi	a1,s0,-464
    80005c2c:	e3843783          	ld	a5,-456(s0)
    80005c30:	953e                	add	a0,a0,a5
    80005c32:	ffffd097          	auipc	ra,0xffffd
    80005c36:	fd0080e7          	jalr	-48(ra) # 80002c02 <fetchaddr>
    80005c3a:	02054a63          	bltz	a0,80005c6e <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c3e:	e3043783          	ld	a5,-464(s0)
    80005c42:	cfa9                	beqz	a5,80005c9c <sys_exec+0xd4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c44:	ffffb097          	auipc	ra,0xffffb
    80005c48:	f2e080e7          	jalr	-210(ra) # 80000b72 <kalloc>
    80005c4c:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80005c50:	cd19                	beqz	a0,80005c6e <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c52:	6605                	lui	a2,0x1
    80005c54:	85aa                	mv	a1,a0
    80005c56:	e3043503          	ld	a0,-464(s0)
    80005c5a:	ffffd097          	auipc	ra,0xffffd
    80005c5e:	ffc080e7          	jalr	-4(ra) # 80002c56 <fetchstr>
    80005c62:	00054663          	bltz	a0,80005c6e <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c66:	0485                	addi	s1,s1,1
    80005c68:	0921                	addi	s2,s2,8
    80005c6a:	fb549be3          	bne	s1,s5,80005c20 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c6e:	e4043503          	ld	a0,-448(s0)
    kfree(argv[i]);
  return -1;
    80005c72:	597d                	li	s2,-1
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c74:	c92d                	beqz	a0,80005ce6 <sys_exec+0x11e>
    kfree(argv[i]);
    80005c76:	ffffb097          	auipc	ra,0xffffb
    80005c7a:	dfc080e7          	jalr	-516(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c7e:	e4840493          	addi	s1,s0,-440
    80005c82:	10098993          	addi	s3,s3,256
    80005c86:	6088                	ld	a0,0(s1)
    80005c88:	cd31                	beqz	a0,80005ce4 <sys_exec+0x11c>
    kfree(argv[i]);
    80005c8a:	ffffb097          	auipc	ra,0xffffb
    80005c8e:	de8080e7          	jalr	-536(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c92:	04a1                	addi	s1,s1,8
    80005c94:	ff3499e3          	bne	s1,s3,80005c86 <sys_exec+0xbe>
  return -1;
    80005c98:	597d                	li	s2,-1
    80005c9a:	a0b1                	j	80005ce6 <sys_exec+0x11e>
      argv[i] = 0;
    80005c9c:	0a0e                	slli	s4,s4,0x3
    80005c9e:	fc040793          	addi	a5,s0,-64
    80005ca2:	9a3e                	add	s4,s4,a5
    80005ca4:	e80a3023          	sd	zero,-384(s4)
  int ret = exec(path, argv);
    80005ca8:	e4040593          	addi	a1,s0,-448
    80005cac:	f4040513          	addi	a0,s0,-192
    80005cb0:	fffff097          	auipc	ra,0xfffff
    80005cb4:	152080e7          	jalr	338(ra) # 80004e02 <exec>
    80005cb8:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cba:	e4043503          	ld	a0,-448(s0)
    80005cbe:	c505                	beqz	a0,80005ce6 <sys_exec+0x11e>
    kfree(argv[i]);
    80005cc0:	ffffb097          	auipc	ra,0xffffb
    80005cc4:	db2080e7          	jalr	-590(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cc8:	e4840493          	addi	s1,s0,-440
    80005ccc:	10098993          	addi	s3,s3,256
    80005cd0:	6088                	ld	a0,0(s1)
    80005cd2:	c911                	beqz	a0,80005ce6 <sys_exec+0x11e>
    kfree(argv[i]);
    80005cd4:	ffffb097          	auipc	ra,0xffffb
    80005cd8:	d9e080e7          	jalr	-610(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cdc:	04a1                	addi	s1,s1,8
    80005cde:	ff3499e3          	bne	s1,s3,80005cd0 <sys_exec+0x108>
    80005ce2:	a011                	j	80005ce6 <sys_exec+0x11e>
  return -1;
    80005ce4:	597d                	li	s2,-1
}
    80005ce6:	854a                	mv	a0,s2
    80005ce8:	60be                	ld	ra,456(sp)
    80005cea:	641e                	ld	s0,448(sp)
    80005cec:	74fa                	ld	s1,440(sp)
    80005cee:	795a                	ld	s2,432(sp)
    80005cf0:	79ba                	ld	s3,424(sp)
    80005cf2:	7a1a                	ld	s4,416(sp)
    80005cf4:	6afa                	ld	s5,408(sp)
    80005cf6:	6179                	addi	sp,sp,464
    80005cf8:	8082                	ret

0000000080005cfa <sys_pipe>:

uint64
sys_pipe(void)
{
    80005cfa:	7139                	addi	sp,sp,-64
    80005cfc:	fc06                	sd	ra,56(sp)
    80005cfe:	f822                	sd	s0,48(sp)
    80005d00:	f426                	sd	s1,40(sp)
    80005d02:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d04:	ffffc097          	auipc	ra,0xffffc
    80005d08:	ea0080e7          	jalr	-352(ra) # 80001ba4 <myproc>
    80005d0c:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d0e:	fd840593          	addi	a1,s0,-40
    80005d12:	4501                	li	a0,0
    80005d14:	ffffd097          	auipc	ra,0xffffd
    80005d18:	fac080e7          	jalr	-84(ra) # 80002cc0 <argaddr>
    return -1;
    80005d1c:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d1e:	0c054f63          	bltz	a0,80005dfc <sys_pipe+0x102>
  if(pipealloc(&rf, &wf) < 0)
    80005d22:	fc840593          	addi	a1,s0,-56
    80005d26:	fd040513          	addi	a0,s0,-48
    80005d2a:	fffff097          	auipc	ra,0xfffff
    80005d2e:	d60080e7          	jalr	-672(ra) # 80004a8a <pipealloc>
    return -1;
    80005d32:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d34:	0c054463          	bltz	a0,80005dfc <sys_pipe+0x102>
  fd0 = -1;
    80005d38:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d3c:	fd043503          	ld	a0,-48(s0)
    80005d40:	fffff097          	auipc	ra,0xfffff
    80005d44:	4ce080e7          	jalr	1230(ra) # 8000520e <fdalloc>
    80005d48:	fca42223          	sw	a0,-60(s0)
    80005d4c:	08054b63          	bltz	a0,80005de2 <sys_pipe+0xe8>
    80005d50:	fc843503          	ld	a0,-56(s0)
    80005d54:	fffff097          	auipc	ra,0xfffff
    80005d58:	4ba080e7          	jalr	1210(ra) # 8000520e <fdalloc>
    80005d5c:	fca42023          	sw	a0,-64(s0)
    80005d60:	06054863          	bltz	a0,80005dd0 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d64:	4691                	li	a3,4
    80005d66:	fc440613          	addi	a2,s0,-60
    80005d6a:	fd843583          	ld	a1,-40(s0)
    80005d6e:	68a8                	ld	a0,80(s1)
    80005d70:	ffffc097          	auipc	ra,0xffffc
    80005d74:	a36080e7          	jalr	-1482(ra) # 800017a6 <copyout>
    80005d78:	02054063          	bltz	a0,80005d98 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d7c:	4691                	li	a3,4
    80005d7e:	fc040613          	addi	a2,s0,-64
    80005d82:	fd843583          	ld	a1,-40(s0)
    80005d86:	0591                	addi	a1,a1,4
    80005d88:	68a8                	ld	a0,80(s1)
    80005d8a:	ffffc097          	auipc	ra,0xffffc
    80005d8e:	a1c080e7          	jalr	-1508(ra) # 800017a6 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d92:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d94:	06055463          	bgez	a0,80005dfc <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80005d98:	fc442783          	lw	a5,-60(s0)
    80005d9c:	07e9                	addi	a5,a5,26
    80005d9e:	078e                	slli	a5,a5,0x3
    80005da0:	97a6                	add	a5,a5,s1
    80005da2:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005da6:	fc042783          	lw	a5,-64(s0)
    80005daa:	07e9                	addi	a5,a5,26
    80005dac:	078e                	slli	a5,a5,0x3
    80005dae:	94be                	add	s1,s1,a5
    80005db0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005db4:	fd043503          	ld	a0,-48(s0)
    80005db8:	fffff097          	auipc	ra,0xfffff
    80005dbc:	98a080e7          	jalr	-1654(ra) # 80004742 <fileclose>
    fileclose(wf);
    80005dc0:	fc843503          	ld	a0,-56(s0)
    80005dc4:	fffff097          	auipc	ra,0xfffff
    80005dc8:	97e080e7          	jalr	-1666(ra) # 80004742 <fileclose>
    return -1;
    80005dcc:	57fd                	li	a5,-1
    80005dce:	a03d                	j	80005dfc <sys_pipe+0x102>
    if(fd0 >= 0)
    80005dd0:	fc442783          	lw	a5,-60(s0)
    80005dd4:	0007c763          	bltz	a5,80005de2 <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005dd8:	07e9                	addi	a5,a5,26
    80005dda:	078e                	slli	a5,a5,0x3
    80005ddc:	94be                	add	s1,s1,a5
    80005dde:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005de2:	fd043503          	ld	a0,-48(s0)
    80005de6:	fffff097          	auipc	ra,0xfffff
    80005dea:	95c080e7          	jalr	-1700(ra) # 80004742 <fileclose>
    fileclose(wf);
    80005dee:	fc843503          	ld	a0,-56(s0)
    80005df2:	fffff097          	auipc	ra,0xfffff
    80005df6:	950080e7          	jalr	-1712(ra) # 80004742 <fileclose>
    return -1;
    80005dfa:	57fd                	li	a5,-1
}
    80005dfc:	853e                	mv	a0,a5
    80005dfe:	70e2                	ld	ra,56(sp)
    80005e00:	7442                	ld	s0,48(sp)
    80005e02:	74a2                	ld	s1,40(sp)
    80005e04:	6121                	addi	sp,sp,64
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
    80005e50:	c7bfc0ef          	jal	ra,80002aca <kerneltrap>
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
    80005eec:	c90080e7          	jalr	-880(ra) # 80001b78 <cpuid>
  
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
    80005f24:	c58080e7          	jalr	-936(ra) # 80001b78 <cpuid>
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
    80005f4c:	c30080e7          	jalr	-976(ra) # 80001b78 <cpuid>
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
    80005f74:	0001d797          	auipc	a5,0x1d
    80005f78:	08c78793          	addi	a5,a5,140 # 80023000 <disk>
    80005f7c:	00a78733          	add	a4,a5,a0
    80005f80:	6789                	lui	a5,0x2
    80005f82:	97ba                	add	a5,a5,a4
    80005f84:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005f88:	eba9                	bnez	a5,80005fda <free_desc+0x74>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005f8a:	0001f797          	auipc	a5,0x1f
    80005f8e:	07678793          	addi	a5,a5,118 # 80025000 <disk+0x2000>
    80005f92:	639c                	ld	a5,0(a5)
    80005f94:	00451713          	slli	a4,a0,0x4
    80005f98:	97ba                	add	a5,a5,a4
    80005f9a:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005f9e:	0001d797          	auipc	a5,0x1d
    80005fa2:	06278793          	addi	a5,a5,98 # 80023000 <disk>
    80005fa6:	97aa                	add	a5,a5,a0
    80005fa8:	6509                	lui	a0,0x2
    80005faa:	953e                	add	a0,a0,a5
    80005fac:	4785                	li	a5,1
    80005fae:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005fb2:	0001f517          	auipc	a0,0x1f
    80005fb6:	06650513          	addi	a0,a0,102 # 80025018 <disk+0x2018>
    80005fba:	ffffc097          	auipc	ra,0xffffc
    80005fbe:	58a080e7          	jalr	1418(ra) # 80002544 <wakeup>
}
    80005fc2:	60a2                	ld	ra,8(sp)
    80005fc4:	6402                	ld	s0,0(sp)
    80005fc6:	0141                	addi	sp,sp,16
    80005fc8:	8082                	ret
    panic("virtio_disk_intr 1");
    80005fca:	00002517          	auipc	a0,0x2
    80005fce:	76650513          	addi	a0,a0,1894 # 80008730 <syscalls+0x360>
    80005fd2:	ffffa097          	auipc	ra,0xffffa
    80005fd6:	5a2080e7          	jalr	1442(ra) # 80000574 <panic>
    panic("virtio_disk_intr 2");
    80005fda:	00002517          	auipc	a0,0x2
    80005fde:	76e50513          	addi	a0,a0,1902 # 80008748 <syscalls+0x378>
    80005fe2:	ffffa097          	auipc	ra,0xffffa
    80005fe6:	592080e7          	jalr	1426(ra) # 80000574 <panic>

0000000080005fea <virtio_disk_init>:
{
    80005fea:	1101                	addi	sp,sp,-32
    80005fec:	ec06                	sd	ra,24(sp)
    80005fee:	e822                	sd	s0,16(sp)
    80005ff0:	e426                	sd	s1,8(sp)
    80005ff2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ff4:	00002597          	auipc	a1,0x2
    80005ff8:	76c58593          	addi	a1,a1,1900 # 80008760 <syscalls+0x390>
    80005ffc:	0001f517          	auipc	a0,0x1f
    80006000:	0ac50513          	addi	a0,a0,172 # 800250a8 <disk+0x20a8>
    80006004:	ffffb097          	auipc	ra,0xffffb
    80006008:	bce080e7          	jalr	-1074(ra) # 80000bd2 <initlock>
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
    80006062:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
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
    80006094:	0001d517          	auipc	a0,0x1d
    80006098:	f6c50513          	addi	a0,a0,-148 # 80023000 <disk>
    8000609c:	ffffb097          	auipc	ra,0xffffb
    800060a0:	cc2080e7          	jalr	-830(ra) # 80000d5e <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800060a4:	0001d717          	auipc	a4,0x1d
    800060a8:	f5c70713          	addi	a4,a4,-164 # 80023000 <disk>
    800060ac:	00c75793          	srli	a5,a4,0xc
    800060b0:	2781                	sext.w	a5,a5
    800060b2:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    800060b4:	0001f797          	auipc	a5,0x1f
    800060b8:	f4c78793          	addi	a5,a5,-180 # 80025000 <disk+0x2000>
    800060bc:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    800060be:	0001d717          	auipc	a4,0x1d
    800060c2:	fc270713          	addi	a4,a4,-62 # 80023080 <disk+0x80>
    800060c6:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    800060c8:	0001e717          	auipc	a4,0x1e
    800060cc:	f3870713          	addi	a4,a4,-200 # 80024000 <disk+0x1000>
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
    80006102:	67250513          	addi	a0,a0,1650 # 80008770 <syscalls+0x3a0>
    80006106:	ffffa097          	auipc	ra,0xffffa
    8000610a:	46e080e7          	jalr	1134(ra) # 80000574 <panic>
    panic("virtio disk has no queue 0");
    8000610e:	00002517          	auipc	a0,0x2
    80006112:	68250513          	addi	a0,a0,1666 # 80008790 <syscalls+0x3c0>
    80006116:	ffffa097          	auipc	ra,0xffffa
    8000611a:	45e080e7          	jalr	1118(ra) # 80000574 <panic>
    panic("virtio disk max queue too short");
    8000611e:	00002517          	auipc	a0,0x2
    80006122:	69250513          	addi	a0,a0,1682 # 800087b0 <syscalls+0x3e0>
    80006126:	ffffa097          	auipc	ra,0xffffa
    8000612a:	44e080e7          	jalr	1102(ra) # 80000574 <panic>

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
    80006158:	0001f517          	auipc	a0,0x1f
    8000615c:	f5050513          	addi	a0,a0,-176 # 800250a8 <disk+0x20a8>
    80006160:	ffffb097          	auipc	ra,0xffffb
    80006164:	b02080e7          	jalr	-1278(ra) # 80000c62 <acquire>
    if(disk.free[i]){
    80006168:	0001f997          	auipc	s3,0x1f
    8000616c:	e9898993          	addi	s3,s3,-360 # 80025000 <disk+0x2000>
  for(int i = 0; i < NUM; i++){
    80006170:	4b21                	li	s6,8
      disk.free[i] = 0;
    80006172:	0001da97          	auipc	s5,0x1d
    80006176:	e8ea8a93          	addi	s5,s5,-370 # 80023000 <disk>
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
    800061a0:	0001f697          	auipc	a3,0x1f
    800061a4:	e7968693          	addi	a3,a3,-391 # 80025019 <disk+0x2019>
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
    800061f2:	0001f597          	auipc	a1,0x1f
    800061f6:	eb658593          	addi	a1,a1,-330 # 800250a8 <disk+0x20a8>
    800061fa:	0001f517          	auipc	a0,0x1f
    800061fe:	e1e50513          	addi	a0,a0,-482 # 80025018 <disk+0x2018>
    80006202:	ffffc097          	auipc	ra,0xffffc
    80006206:	1bc080e7          	jalr	444(ra) # 800023be <sleep>
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
    8000622c:	0001fa17          	auipc	s4,0x1f
    80006230:	dd4a0a13          	addi	s4,s4,-556 # 80025000 <disk+0x2000>
    80006234:	000a3a83          	ld	s5,0(s4)
    80006238:	9aa6                	add	s5,s5,s1
    8000623a:	f9040513          	addi	a0,s0,-112
    8000623e:	ffffb097          	auipc	ra,0xffffb
    80006242:	ed6080e7          	jalr	-298(ra) # 80001114 <kvmpa>
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
    80006296:	0001d517          	auipc	a0,0x1d
    8000629a:	d6a50513          	addi	a0,a0,-662 # 80023000 <disk>
    8000629e:	0001f797          	auipc	a5,0x1f
    800062a2:	d6278793          	addi	a5,a5,-670 # 80025000 <disk+0x2000>
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
    80006338:	0001f997          	auipc	s3,0x1f
    8000633c:	d7098993          	addi	s3,s3,-656 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    80006340:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006342:	85ce                	mv	a1,s3
    80006344:	854a                	mv	a0,s2
    80006346:	ffffc097          	auipc	ra,0xffffc
    8000634a:	078080e7          	jalr	120(ra) # 800023be <sleep>
  while(b->disk == 1) {
    8000634e:	00492783          	lw	a5,4(s2)
    80006352:	fe9788e3          	beq	a5,s1,80006342 <virtio_disk_rw+0x214>
  }

  disk.info[idx[0]].b = 0;
    80006356:	fa042483          	lw	s1,-96(s0)
    8000635a:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    8000635e:	00479713          	slli	a4,a5,0x4
    80006362:	0001d797          	auipc	a5,0x1d
    80006366:	c9e78793          	addi	a5,a5,-866 # 80023000 <disk>
    8000636a:	97ba                	add	a5,a5,a4
    8000636c:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006370:	0001f917          	auipc	s2,0x1f
    80006374:	c9090913          	addi	s2,s2,-880 # 80025000 <disk+0x2000>
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
    80006398:	0001f797          	auipc	a5,0x1f
    8000639c:	c6878793          	addi	a5,a5,-920 # 80025000 <disk+0x2000>
    800063a0:	639c                	ld	a5,0(a5)
    800063a2:	97ba                	add	a5,a5,a4
    800063a4:	4689                	li	a3,2
    800063a6:	00d79623          	sh	a3,12(a5)
    800063aa:	b5f5                	j	80006296 <virtio_disk_rw+0x168>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063ac:	0001f517          	auipc	a0,0x1f
    800063b0:	cfc50513          	addi	a0,a0,-772 # 800250a8 <disk+0x20a8>
    800063b4:	ffffb097          	auipc	ra,0xffffb
    800063b8:	962080e7          	jalr	-1694(ra) # 80000d16 <release>
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
    800063f4:	0001f517          	auipc	a0,0x1f
    800063f8:	cb450513          	addi	a0,a0,-844 # 800250a8 <disk+0x20a8>
    800063fc:	ffffb097          	auipc	ra,0xffffb
    80006400:	866080e7          	jalr	-1946(ra) # 80000c62 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006404:	0001f797          	auipc	a5,0x1f
    80006408:	bfc78793          	addi	a5,a5,-1028 # 80025000 <disk+0x2000>
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
    8000642a:	0001d717          	auipc	a4,0x1d
    8000642e:	bd670713          	addi	a4,a4,-1066 # 80023000 <disk>
    80006432:	9736                	add	a4,a4,a3
    80006434:	03074703          	lbu	a4,48(a4)
    80006438:	ef31                	bnez	a4,80006494 <virtio_disk_intr+0xac>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000643a:	0001d917          	auipc	s2,0x1d
    8000643e:	bc690913          	addi	s2,s2,-1082 # 80023000 <disk>
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006442:	0001f497          	auipc	s1,0x1f
    80006446:	bbe48493          	addi	s1,s1,-1090 # 80025000 <disk+0x2000>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000644a:	20078793          	addi	a5,a5,512
    8000644e:	0792                	slli	a5,a5,0x4
    80006450:	97ca                	add	a5,a5,s2
    80006452:	7798                	ld	a4,40(a5)
    80006454:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    80006458:	7788                	ld	a0,40(a5)
    8000645a:	ffffc097          	auipc	ra,0xffffc
    8000645e:	0ea080e7          	jalr	234(ra) # 80002544 <wakeup>
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
    80006498:	33c50513          	addi	a0,a0,828 # 800087d0 <syscalls+0x400>
    8000649c:	ffffa097          	auipc	ra,0xffffa
    800064a0:	0d8080e7          	jalr	216(ra) # 80000574 <panic>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800064a4:	10001737          	lui	a4,0x10001
    800064a8:	533c                	lw	a5,96(a4)
    800064aa:	8b8d                	andi	a5,a5,3
    800064ac:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    800064ae:	0001f517          	auipc	a0,0x1f
    800064b2:	bfa50513          	addi	a0,a0,-1030 # 800250a8 <disk+0x20a8>
    800064b6:	ffffb097          	auipc	ra,0xffffb
    800064ba:	860080e7          	jalr	-1952(ra) # 80000d16 <release>
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
