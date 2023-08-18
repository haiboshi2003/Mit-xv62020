
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	95013103          	ld	sp,-1712(sp) # 80008950 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000062:	f0278793          	addi	a5,a5,-254 # 80005f60 <timervec>
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
    80000096:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdb87ff>
    8000009a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009c:	6705                	lui	a4,0x1
    8000009e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a4:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a8:	00001797          	auipc	a5,0x1
    800000ac:	f8678793          	addi	a5,a5,-122 # 8000102e <main>
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
    80000112:	c50080e7          	jalr	-944(ra) # 80000d5e <acquire>
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
    8000012c:	638080e7          	jalr	1592(ra) # 80002760 <either_copyin>
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
    80000154:	cc2080e7          	jalr	-830(ra) # 80000e12 <release>

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
    800001a4:	bbe080e7          	jalr	-1090(ra) # 80000d5e <acquire>
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
    800001d4:	abe080e7          	jalr	-1346(ra) # 80001c8e <myproc>
    800001d8:	591c                	lw	a5,48(a0)
    800001da:	eba5                	bnez	a5,8000024a <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001dc:	85ce                	mv	a1,s3
    800001de:	854a                	mv	a0,s2
    800001e0:	00002097          	auipc	ra,0x2
    800001e4:	2c8080e7          	jalr	712(ra) # 800024a8 <sleep>
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
    80000220:	4ee080e7          	jalr	1262(ra) # 8000270a <either_copyout>
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
    80000240:	bd6080e7          	jalr	-1066(ra) # 80000e12 <release>

  return target - n;
    80000244:	414b053b          	subw	a0,s6,s4
    80000248:	a811                	j	8000025c <consoleread+0xec>
        release(&cons.lock);
    8000024a:	00011517          	auipc	a0,0x11
    8000024e:	5e650513          	addi	a0,a0,1510 # 80011830 <cons>
    80000252:	00001097          	auipc	ra,0x1
    80000256:	bc0080e7          	jalr	-1088(ra) # 80000e12 <release>
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
    800002e8:	a7a080e7          	jalr	-1414(ra) # 80000d5e <acquire>

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
    8000041a:	3a0080e7          	jalr	928(ra) # 800027b6 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000041e:	00011517          	auipc	a0,0x11
    80000422:	41250513          	addi	a0,a0,1042 # 80011830 <cons>
    80000426:	00001097          	auipc	ra,0x1
    8000042a:	9ec080e7          	jalr	-1556(ra) # 80000e12 <release>
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
    8000047c:	1b6080e7          	jalr	438(ra) # 8000262e <wakeup>
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
    8000049a:	00001097          	auipc	ra,0x1
    8000049e:	834080e7          	jalr	-1996(ra) # 80000cce <initlock>

  uartinit();
    800004a2:	00000097          	auipc	ra,0x0
    800004a6:	334080e7          	jalr	820(ra) # 800007d6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004aa:	00241797          	auipc	a5,0x241
    800004ae:	50678793          	addi	a5,a5,1286 # 802419b0 <devsw>
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
    800005a6:	b5e50513          	addi	a0,a0,-1186 # 80008100 <digits+0xe8>
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
    80000638:	72a080e7          	jalr	1834(ra) # 80000d5e <acquire>
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
    8000079e:	678080e7          	jalr	1656(ra) # 80000e12 <release>
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
    800007c4:	50e080e7          	jalr	1294(ra) # 80000cce <initlock>
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
    8000081a:	4b8080e7          	jalr	1208(ra) # 80000cce <initlock>
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
    80000836:	4e0080e7          	jalr	1248(ra) # 80000d12 <push_off>

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
    8000086c:	54a080e7          	jalr	1354(ra) # 80000db2 <pop_off>
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
    800008f2:	d40080e7          	jalr	-704(ra) # 8000262e <wakeup>
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
    80000944:	41e080e7          	jalr	1054(ra) # 80000d5e <acquire>
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
    800009a2:	b0a080e7          	jalr	-1270(ra) # 800024a8 <sleep>
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
    800009e6:	430080e7          	jalr	1072(ra) # 80000e12 <release>
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
    80000a52:	310080e7          	jalr	784(ra) # 80000d5e <acquire>
  uartstart();
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	e24080e7          	jalr	-476(ra) # 8000087a <uartstart>
  release(&uart_tx_lock);
    80000a5e:	8526                	mv	a0,s1
    80000a60:	00000097          	auipc	ra,0x0
    80000a64:	3b2080e7          	jalr	946(ra) # 80000e12 <release>
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
    80000a72:	7179                	addi	sp,sp,-48
    80000a74:	f406                	sd	ra,40(sp)
    80000a76:	f022                	sd	s0,32(sp)
    80000a78:	ec26                	sd	s1,24(sp)
    80000a7a:	e84a                	sd	s2,16(sp)
    80000a7c:	e44e                	sd	s3,8(sp)
    80000a7e:	1800                	addi	s0,sp,48
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a80:	6785                	lui	a5,0x1
    80000a82:	17fd                	addi	a5,a5,-1
    80000a84:	8fe9                	and	a5,a5,a0
    80000a86:	e3ad                	bnez	a5,80000ae8 <kfree+0x76>
    80000a88:	84aa                	mv	s1,a0
    80000a8a:	00245797          	auipc	a5,0x245
    80000a8e:	57678793          	addi	a5,a5,1398 # 80246000 <end>
    80000a92:	04f56b63          	bltu	a0,a5,80000ae8 <kfree+0x76>
    80000a96:	47c5                	li	a5,17
    80000a98:	07ee                	slli	a5,a5,0x1b
    80000a9a:	04f57763          	bleu	a5,a0,80000ae8 <kfree+0x76>
    panic("kfree");

  acquire(&kmem.lock);
    80000a9e:	00011917          	auipc	s2,0x11
    80000aa2:	e9290913          	addi	s2,s2,-366 # 80011930 <kmem>
    80000aa6:	854a                	mv	a0,s2
    80000aa8:	00000097          	auipc	ra,0x0
    80000aac:	2b6080e7          	jalr	694(ra) # 80000d5e <acquire>
  int remain = --cowcount[PA2INDEX(pa)];
    80000ab0:	00c4d793          	srli	a5,s1,0xc
    80000ab4:	00279713          	slli	a4,a5,0x2
    80000ab8:	00011797          	auipc	a5,0x11
    80000abc:	e9878793          	addi	a5,a5,-360 # 80011950 <cowcount>
    80000ac0:	97ba                	add	a5,a5,a4
    80000ac2:	4398                	lw	a4,0(a5)
    80000ac4:	377d                	addiw	a4,a4,-1
    80000ac6:	0007099b          	sext.w	s3,a4
    80000aca:	c398                	sw	a4,0(a5)
  release(&kmem.lock);
    80000acc:	854a                	mv	a0,s2
    80000ace:	00000097          	auipc	ra,0x0
    80000ad2:	344080e7          	jalr	836(ra) # 80000e12 <release>

  if (remain > 0) {
    80000ad6:	03305163          	blez	s3,80000af8 <kfree+0x86>

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}
    80000ada:	70a2                	ld	ra,40(sp)
    80000adc:	7402                	ld	s0,32(sp)
    80000ade:	64e2                	ld	s1,24(sp)
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6145                	addi	sp,sp,48
    80000ae6:	8082                	ret
    panic("kfree");
    80000ae8:	00007517          	auipc	a0,0x7
    80000aec:	57850513          	addi	a0,a0,1400 # 80008060 <digits+0x48>
    80000af0:	00000097          	auipc	ra,0x0
    80000af4:	a84080e7          	jalr	-1404(ra) # 80000574 <panic>
  memset(pa, 1, PGSIZE);
    80000af8:	6605                	lui	a2,0x1
    80000afa:	4585                	li	a1,1
    80000afc:	8526                	mv	a0,s1
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	35c080e7          	jalr	860(ra) # 80000e5a <memset>
  acquire(&kmem.lock);
    80000b06:	854a                	mv	a0,s2
    80000b08:	00000097          	auipc	ra,0x0
    80000b0c:	256080e7          	jalr	598(ra) # 80000d5e <acquire>
  r->next = kmem.freelist;
    80000b10:	01893783          	ld	a5,24(s2)
    80000b14:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000b16:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000b1a:	854a                	mv	a0,s2
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	2f6080e7          	jalr	758(ra) # 80000e12 <release>
    80000b24:	bf5d                	j	80000ada <kfree+0x68>

0000000080000b26 <freerange>:
{
    80000b26:	7139                	addi	sp,sp,-64
    80000b28:	fc06                	sd	ra,56(sp)
    80000b2a:	f822                	sd	s0,48(sp)
    80000b2c:	f426                	sd	s1,40(sp)
    80000b2e:	f04a                	sd	s2,32(sp)
    80000b30:	ec4e                	sd	s3,24(sp)
    80000b32:	e852                	sd	s4,16(sp)
    80000b34:	e456                	sd	s5,8(sp)
    80000b36:	e05a                	sd	s6,0(sp)
    80000b38:	0080                	addi	s0,sp,64
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b3a:	6785                	lui	a5,0x1
    80000b3c:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000b40:	94aa                	add	s1,s1,a0
    80000b42:	757d                	lui	a0,0xfffff
    80000b44:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    80000b46:	97a6                	add	a5,a5,s1
    80000b48:	02f5ea63          	bltu	a1,a5,80000b7c <freerange+0x56>
    80000b4c:	892e                	mv	s2,a1
    cowcount[PA2INDEX(p)] = 1; // add into free list initially
    80000b4e:	00011b17          	auipc	s6,0x11
    80000b52:	e02b0b13          	addi	s6,s6,-510 # 80011950 <cowcount>
    80000b56:	4a85                	li	s5,1
    80000b58:	6a05                	lui	s4,0x1
    80000b5a:	6989                	lui	s3,0x2
    80000b5c:	00c4d793          	srli	a5,s1,0xc
    80000b60:	078a                	slli	a5,a5,0x2
    80000b62:	97da                	add	a5,a5,s6
    80000b64:	0157a023          	sw	s5,0(a5)
    kfree(p);
    80000b68:	8526                	mv	a0,s1
    80000b6a:	00000097          	auipc	ra,0x0
    80000b6e:	f08080e7          	jalr	-248(ra) # 80000a72 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    80000b72:	013487b3          	add	a5,s1,s3
    80000b76:	94d2                	add	s1,s1,s4
    80000b78:	fef972e3          	bleu	a5,s2,80000b5c <freerange+0x36>
}
    80000b7c:	70e2                	ld	ra,56(sp)
    80000b7e:	7442                	ld	s0,48(sp)
    80000b80:	74a2                	ld	s1,40(sp)
    80000b82:	7902                	ld	s2,32(sp)
    80000b84:	69e2                	ld	s3,24(sp)
    80000b86:	6a42                	ld	s4,16(sp)
    80000b88:	6aa2                	ld	s5,8(sp)
    80000b8a:	6b02                	ld	s6,0(sp)
    80000b8c:	6121                	addi	sp,sp,64
    80000b8e:	8082                	ret

0000000080000b90 <kinit>:
{
    80000b90:	1141                	addi	sp,sp,-16
    80000b92:	e406                	sd	ra,8(sp)
    80000b94:	e022                	sd	s0,0(sp)
    80000b96:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b98:	00007597          	auipc	a1,0x7
    80000b9c:	4d058593          	addi	a1,a1,1232 # 80008068 <digits+0x50>
    80000ba0:	00011517          	auipc	a0,0x11
    80000ba4:	d9050513          	addi	a0,a0,-624 # 80011930 <kmem>
    80000ba8:	00000097          	auipc	ra,0x0
    80000bac:	126080e7          	jalr	294(ra) # 80000cce <initlock>
  freerange(end, (void*)PHYSTOP);
    80000bb0:	45c5                	li	a1,17
    80000bb2:	05ee                	slli	a1,a1,0x1b
    80000bb4:	00245517          	auipc	a0,0x245
    80000bb8:	44c50513          	addi	a0,a0,1100 # 80246000 <end>
    80000bbc:	00000097          	auipc	ra,0x0
    80000bc0:	f6a080e7          	jalr	-150(ra) # 80000b26 <freerange>
}
    80000bc4:	60a2                	ld	ra,8(sp)
    80000bc6:	6402                	ld	s0,0(sp)
    80000bc8:	0141                	addi	sp,sp,16
    80000bca:	8082                	ret

0000000080000bcc <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000bcc:	1101                	addi	sp,sp,-32
    80000bce:	ec06                	sd	ra,24(sp)
    80000bd0:	e822                	sd	s0,16(sp)
    80000bd2:	e426                	sd	s1,8(sp)
    80000bd4:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000bd6:	00011497          	auipc	s1,0x11
    80000bda:	d5a48493          	addi	s1,s1,-678 # 80011930 <kmem>
    80000bde:	8526                	mv	a0,s1
    80000be0:	00000097          	auipc	ra,0x0
    80000be4:	17e080e7          	jalr	382(ra) # 80000d5e <acquire>
  r = kmem.freelist;
    80000be8:	6c84                	ld	s1,24(s1)
  if(r)
    80000bea:	c4a5                	beqz	s1,80000c52 <kalloc+0x86>
    kmem.freelist = r->next;
    80000bec:	609c                	ld	a5,0(s1)
    80000bee:	00011517          	auipc	a0,0x11
    80000bf2:	d4250513          	addi	a0,a0,-702 # 80011930 <kmem>
    80000bf6:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000bf8:	00000097          	auipc	ra,0x0
    80000bfc:	21a080e7          	jalr	538(ra) # 80000e12 <release>

  if(r) {
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000c00:	6605                	lui	a2,0x1
    80000c02:	4595                	li	a1,5
    80000c04:	8526                	mv	a0,s1
    80000c06:	00000097          	auipc	ra,0x0
    80000c0a:	254080e7          	jalr	596(ra) # 80000e5a <memset>
    int idx = PA2INDEX(r);
    80000c0e:	00c4d793          	srli	a5,s1,0xc
    80000c12:	2781                	sext.w	a5,a5
    if (cowcount[idx] != 0) {
    80000c14:	00279693          	slli	a3,a5,0x2
    80000c18:	00011717          	auipc	a4,0x11
    80000c1c:	d3870713          	addi	a4,a4,-712 # 80011950 <cowcount>
    80000c20:	9736                	add	a4,a4,a3
    80000c22:	4318                	lw	a4,0(a4)
    80000c24:	ef19                	bnez	a4,80000c42 <kalloc+0x76>
      panic("kalloc: cowcount[idx] != 0");
    }
    cowcount[idx] = 1;
    80000c26:	078a                	slli	a5,a5,0x2
    80000c28:	00011717          	auipc	a4,0x11
    80000c2c:	d2870713          	addi	a4,a4,-728 # 80011950 <cowcount>
    80000c30:	97ba                	add	a5,a5,a4
    80000c32:	4705                	li	a4,1
    80000c34:	c398                	sw	a4,0(a5)
  }
  return (void*)r;
}
    80000c36:	8526                	mv	a0,s1
    80000c38:	60e2                	ld	ra,24(sp)
    80000c3a:	6442                	ld	s0,16(sp)
    80000c3c:	64a2                	ld	s1,8(sp)
    80000c3e:	6105                	addi	sp,sp,32
    80000c40:	8082                	ret
      panic("kalloc: cowcount[idx] != 0");
    80000c42:	00007517          	auipc	a0,0x7
    80000c46:	42e50513          	addi	a0,a0,1070 # 80008070 <digits+0x58>
    80000c4a:	00000097          	auipc	ra,0x0
    80000c4e:	92a080e7          	jalr	-1750(ra) # 80000574 <panic>
  release(&kmem.lock);
    80000c52:	00011517          	auipc	a0,0x11
    80000c56:	cde50513          	addi	a0,a0,-802 # 80011930 <kmem>
    80000c5a:	00000097          	auipc	ra,0x0
    80000c5e:	1b8080e7          	jalr	440(ra) # 80000e12 <release>
  if(r) {
    80000c62:	bfd1                	j	80000c36 <kalloc+0x6a>

0000000080000c64 <adjustref>:

// increment the reference count for a physical address by 1
void adjustref(uint64 pa, int num) {
    80000c64:	7179                	addi	sp,sp,-48
    80000c66:	f406                	sd	ra,40(sp)
    80000c68:	f022                	sd	s0,32(sp)
    80000c6a:	ec26                	sd	s1,24(sp)
    80000c6c:	e84a                	sd	s2,16(sp)
    80000c6e:	e44e                	sd	s3,8(sp)
    80000c70:	1800                	addi	s0,sp,48
    if (pa >= PHYSTOP) {
    80000c72:	47c5                	li	a5,17
    80000c74:	07ee                	slli	a5,a5,0x1b
    80000c76:	04f57463          	bleu	a5,a0,80000cbe <adjustref+0x5a>
    80000c7a:	84aa                	mv	s1,a0
    80000c7c:	89ae                	mv	s3,a1
        panic("addref: pa too big");
    }
    acquire(&kmem.lock);
    80000c7e:	00011917          	auipc	s2,0x11
    80000c82:	cb290913          	addi	s2,s2,-846 # 80011930 <kmem>
    80000c86:	854a                	mv	a0,s2
    80000c88:	00000097          	auipc	ra,0x0
    80000c8c:	0d6080e7          	jalr	214(ra) # 80000d5e <acquire>
    cowcount[PA2INDEX(pa)] += num;
    80000c90:	80b1                	srli	s1,s1,0xc
    80000c92:	048a                	slli	s1,s1,0x2
    80000c94:	00011797          	auipc	a5,0x11
    80000c98:	cbc78793          	addi	a5,a5,-836 # 80011950 <cowcount>
    80000c9c:	94be                	add	s1,s1,a5
    80000c9e:	408c                	lw	a1,0(s1)
    80000ca0:	013585bb          	addw	a1,a1,s3
    80000ca4:	c08c                	sw	a1,0(s1)
    release(&kmem.lock);
    80000ca6:	854a                	mv	a0,s2
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	16a080e7          	jalr	362(ra) # 80000e12 <release>
}
    80000cb0:	70a2                	ld	ra,40(sp)
    80000cb2:	7402                	ld	s0,32(sp)
    80000cb4:	64e2                	ld	s1,24(sp)
    80000cb6:	6942                	ld	s2,16(sp)
    80000cb8:	69a2                	ld	s3,8(sp)
    80000cba:	6145                	addi	sp,sp,48
    80000cbc:	8082                	ret
        panic("addref: pa too big");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3d250513          	addi	a0,a0,978 # 80008090 <digits+0x78>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	8ae080e7          	jalr	-1874(ra) # 80000574 <panic>

0000000080000cce <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	addi	s0,sp,16
  lk->name = name;
    80000cd4:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000cd6:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000cda:	00053823          	sd	zero,16(a0)
}
    80000cde:	6422                	ld	s0,8(sp)
    80000ce0:	0141                	addi	sp,sp,16
    80000ce2:	8082                	ret

0000000080000ce4 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000ce4:	411c                	lw	a5,0(a0)
    80000ce6:	e399                	bnez	a5,80000cec <holding+0x8>
    80000ce8:	4501                	li	a0,0
  return r;
}
    80000cea:	8082                	ret
{
    80000cec:	1101                	addi	sp,sp,-32
    80000cee:	ec06                	sd	ra,24(sp)
    80000cf0:	e822                	sd	s0,16(sp)
    80000cf2:	e426                	sd	s1,8(sp)
    80000cf4:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000cf6:	6904                	ld	s1,16(a0)
    80000cf8:	00001097          	auipc	ra,0x1
    80000cfc:	f7a080e7          	jalr	-134(ra) # 80001c72 <mycpu>
    80000d00:	40a48533          	sub	a0,s1,a0
    80000d04:	00153513          	seqz	a0,a0
}
    80000d08:	60e2                	ld	ra,24(sp)
    80000d0a:	6442                	ld	s0,16(sp)
    80000d0c:	64a2                	ld	s1,8(sp)
    80000d0e:	6105                	addi	sp,sp,32
    80000d10:	8082                	ret

0000000080000d12 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000d12:	1101                	addi	sp,sp,-32
    80000d14:	ec06                	sd	ra,24(sp)
    80000d16:	e822                	sd	s0,16(sp)
    80000d18:	e426                	sd	s1,8(sp)
    80000d1a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d1c:	100024f3          	csrr	s1,sstatus
    80000d20:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000d24:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d26:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000d2a:	00001097          	auipc	ra,0x1
    80000d2e:	f48080e7          	jalr	-184(ra) # 80001c72 <mycpu>
    80000d32:	5d3c                	lw	a5,120(a0)
    80000d34:	cf89                	beqz	a5,80000d4e <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d36:	00001097          	auipc	ra,0x1
    80000d3a:	f3c080e7          	jalr	-196(ra) # 80001c72 <mycpu>
    80000d3e:	5d3c                	lw	a5,120(a0)
    80000d40:	2785                	addiw	a5,a5,1
    80000d42:	dd3c                	sw	a5,120(a0)
}
    80000d44:	60e2                	ld	ra,24(sp)
    80000d46:	6442                	ld	s0,16(sp)
    80000d48:	64a2                	ld	s1,8(sp)
    80000d4a:	6105                	addi	sp,sp,32
    80000d4c:	8082                	ret
    mycpu()->intena = old;
    80000d4e:	00001097          	auipc	ra,0x1
    80000d52:	f24080e7          	jalr	-220(ra) # 80001c72 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000d56:	8085                	srli	s1,s1,0x1
    80000d58:	8885                	andi	s1,s1,1
    80000d5a:	dd64                	sw	s1,124(a0)
    80000d5c:	bfe9                	j	80000d36 <push_off+0x24>

0000000080000d5e <acquire>:
{
    80000d5e:	1101                	addi	sp,sp,-32
    80000d60:	ec06                	sd	ra,24(sp)
    80000d62:	e822                	sd	s0,16(sp)
    80000d64:	e426                	sd	s1,8(sp)
    80000d66:	1000                	addi	s0,sp,32
    80000d68:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d6a:	00000097          	auipc	ra,0x0
    80000d6e:	fa8080e7          	jalr	-88(ra) # 80000d12 <push_off>
  if(holding(lk))
    80000d72:	8526                	mv	a0,s1
    80000d74:	00000097          	auipc	ra,0x0
    80000d78:	f70080e7          	jalr	-144(ra) # 80000ce4 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d7c:	4705                	li	a4,1
  if(holding(lk))
    80000d7e:	e115                	bnez	a0,80000da2 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d80:	87ba                	mv	a5,a4
    80000d82:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d86:	2781                	sext.w	a5,a5
    80000d88:	ffe5                	bnez	a5,80000d80 <acquire+0x22>
  __sync_synchronize();
    80000d8a:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d8e:	00001097          	auipc	ra,0x1
    80000d92:	ee4080e7          	jalr	-284(ra) # 80001c72 <mycpu>
    80000d96:	e888                	sd	a0,16(s1)
}
    80000d98:	60e2                	ld	ra,24(sp)
    80000d9a:	6442                	ld	s0,16(sp)
    80000d9c:	64a2                	ld	s1,8(sp)
    80000d9e:	6105                	addi	sp,sp,32
    80000da0:	8082                	ret
    panic("acquire");
    80000da2:	00007517          	auipc	a0,0x7
    80000da6:	30650513          	addi	a0,a0,774 # 800080a8 <digits+0x90>
    80000daa:	fffff097          	auipc	ra,0xfffff
    80000dae:	7ca080e7          	jalr	1994(ra) # 80000574 <panic>

0000000080000db2 <pop_off>:

void
pop_off(void)
{
    80000db2:	1141                	addi	sp,sp,-16
    80000db4:	e406                	sd	ra,8(sp)
    80000db6:	e022                	sd	s0,0(sp)
    80000db8:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000dba:	00001097          	auipc	ra,0x1
    80000dbe:	eb8080e7          	jalr	-328(ra) # 80001c72 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000dc2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000dc6:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000dc8:	e78d                	bnez	a5,80000df2 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000dca:	5d3c                	lw	a5,120(a0)
    80000dcc:	02f05b63          	blez	a5,80000e02 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000dd0:	37fd                	addiw	a5,a5,-1
    80000dd2:	0007871b          	sext.w	a4,a5
    80000dd6:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000dd8:	eb09                	bnez	a4,80000dea <pop_off+0x38>
    80000dda:	5d7c                	lw	a5,124(a0)
    80000ddc:	c799                	beqz	a5,80000dea <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000dde:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000de2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000de6:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000dea:	60a2                	ld	ra,8(sp)
    80000dec:	6402                	ld	s0,0(sp)
    80000dee:	0141                	addi	sp,sp,16
    80000df0:	8082                	ret
    panic("pop_off - interruptible");
    80000df2:	00007517          	auipc	a0,0x7
    80000df6:	2be50513          	addi	a0,a0,702 # 800080b0 <digits+0x98>
    80000dfa:	fffff097          	auipc	ra,0xfffff
    80000dfe:	77a080e7          	jalr	1914(ra) # 80000574 <panic>
    panic("pop_off");
    80000e02:	00007517          	auipc	a0,0x7
    80000e06:	2c650513          	addi	a0,a0,710 # 800080c8 <digits+0xb0>
    80000e0a:	fffff097          	auipc	ra,0xfffff
    80000e0e:	76a080e7          	jalr	1898(ra) # 80000574 <panic>

0000000080000e12 <release>:
{
    80000e12:	1101                	addi	sp,sp,-32
    80000e14:	ec06                	sd	ra,24(sp)
    80000e16:	e822                	sd	s0,16(sp)
    80000e18:	e426                	sd	s1,8(sp)
    80000e1a:	1000                	addi	s0,sp,32
    80000e1c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000e1e:	00000097          	auipc	ra,0x0
    80000e22:	ec6080e7          	jalr	-314(ra) # 80000ce4 <holding>
    80000e26:	c115                	beqz	a0,80000e4a <release+0x38>
  lk->cpu = 0;
    80000e28:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000e2c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000e30:	0f50000f          	fence	iorw,ow
    80000e34:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000e38:	00000097          	auipc	ra,0x0
    80000e3c:	f7a080e7          	jalr	-134(ra) # 80000db2 <pop_off>
}
    80000e40:	60e2                	ld	ra,24(sp)
    80000e42:	6442                	ld	s0,16(sp)
    80000e44:	64a2                	ld	s1,8(sp)
    80000e46:	6105                	addi	sp,sp,32
    80000e48:	8082                	ret
    panic("release");
    80000e4a:	00007517          	auipc	a0,0x7
    80000e4e:	28650513          	addi	a0,a0,646 # 800080d0 <digits+0xb8>
    80000e52:	fffff097          	auipc	ra,0xfffff
    80000e56:	722080e7          	jalr	1826(ra) # 80000574 <panic>

0000000080000e5a <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000e5a:	1141                	addi	sp,sp,-16
    80000e5c:	e422                	sd	s0,8(sp)
    80000e5e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000e60:	ce09                	beqz	a2,80000e7a <memset+0x20>
    80000e62:	87aa                	mv	a5,a0
    80000e64:	fff6071b          	addiw	a4,a2,-1
    80000e68:	1702                	slli	a4,a4,0x20
    80000e6a:	9301                	srli	a4,a4,0x20
    80000e6c:	0705                	addi	a4,a4,1
    80000e6e:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000e70:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000e74:	0785                	addi	a5,a5,1
    80000e76:	fee79de3          	bne	a5,a4,80000e70 <memset+0x16>
  }
  return dst;
}
    80000e7a:	6422                	ld	s0,8(sp)
    80000e7c:	0141                	addi	sp,sp,16
    80000e7e:	8082                	ret

0000000080000e80 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e80:	1141                	addi	sp,sp,-16
    80000e82:	e422                	sd	s0,8(sp)
    80000e84:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e86:	ce15                	beqz	a2,80000ec2 <memcmp+0x42>
    80000e88:	fff6069b          	addiw	a3,a2,-1
    if(*s1 != *s2)
    80000e8c:	00054783          	lbu	a5,0(a0)
    80000e90:	0005c703          	lbu	a4,0(a1)
    80000e94:	02e79063          	bne	a5,a4,80000eb4 <memcmp+0x34>
    80000e98:	1682                	slli	a3,a3,0x20
    80000e9a:	9281                	srli	a3,a3,0x20
    80000e9c:	0685                	addi	a3,a3,1
    80000e9e:	96aa                	add	a3,a3,a0
      return *s1 - *s2;
    s1++, s2++;
    80000ea0:	0505                	addi	a0,a0,1
    80000ea2:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ea4:	00d50d63          	beq	a0,a3,80000ebe <memcmp+0x3e>
    if(*s1 != *s2)
    80000ea8:	00054783          	lbu	a5,0(a0)
    80000eac:	0005c703          	lbu	a4,0(a1)
    80000eb0:	fee788e3          	beq	a5,a4,80000ea0 <memcmp+0x20>
      return *s1 - *s2;
    80000eb4:	40e7853b          	subw	a0,a5,a4
  }

  return 0;
}
    80000eb8:	6422                	ld	s0,8(sp)
    80000eba:	0141                	addi	sp,sp,16
    80000ebc:	8082                	ret
  return 0;
    80000ebe:	4501                	li	a0,0
    80000ec0:	bfe5                	j	80000eb8 <memcmp+0x38>
    80000ec2:	4501                	li	a0,0
    80000ec4:	bfd5                	j	80000eb8 <memcmp+0x38>

0000000080000ec6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000ec6:	1141                	addi	sp,sp,-16
    80000ec8:	e422                	sd	s0,8(sp)
    80000eca:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000ecc:	00a5f963          	bleu	a0,a1,80000ede <memmove+0x18>
    80000ed0:	02061713          	slli	a4,a2,0x20
    80000ed4:	9301                	srli	a4,a4,0x20
    80000ed6:	00e587b3          	add	a5,a1,a4
    80000eda:	02f56563          	bltu	a0,a5,80000f04 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000ede:	fff6069b          	addiw	a3,a2,-1
    80000ee2:	ce11                	beqz	a2,80000efe <memmove+0x38>
    80000ee4:	1682                	slli	a3,a3,0x20
    80000ee6:	9281                	srli	a3,a3,0x20
    80000ee8:	0685                	addi	a3,a3,1
    80000eea:	96ae                	add	a3,a3,a1
    80000eec:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000eee:	0585                	addi	a1,a1,1
    80000ef0:	0785                	addi	a5,a5,1
    80000ef2:	fff5c703          	lbu	a4,-1(a1)
    80000ef6:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000efa:	fed59ae3          	bne	a1,a3,80000eee <memmove+0x28>

  return dst;
}
    80000efe:	6422                	ld	s0,8(sp)
    80000f00:	0141                	addi	sp,sp,16
    80000f02:	8082                	ret
    d += n;
    80000f04:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000f06:	fff6069b          	addiw	a3,a2,-1
    80000f0a:	da75                	beqz	a2,80000efe <memmove+0x38>
    80000f0c:	02069613          	slli	a2,a3,0x20
    80000f10:	9201                	srli	a2,a2,0x20
    80000f12:	fff64613          	not	a2,a2
    80000f16:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000f18:	17fd                	addi	a5,a5,-1
    80000f1a:	177d                	addi	a4,a4,-1
    80000f1c:	0007c683          	lbu	a3,0(a5)
    80000f20:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000f24:	fef61ae3          	bne	a2,a5,80000f18 <memmove+0x52>
    80000f28:	bfd9                	j	80000efe <memmove+0x38>

0000000080000f2a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000f2a:	1141                	addi	sp,sp,-16
    80000f2c:	e406                	sd	ra,8(sp)
    80000f2e:	e022                	sd	s0,0(sp)
    80000f30:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	f94080e7          	jalr	-108(ra) # 80000ec6 <memmove>
}
    80000f3a:	60a2                	ld	ra,8(sp)
    80000f3c:	6402                	ld	s0,0(sp)
    80000f3e:	0141                	addi	sp,sp,16
    80000f40:	8082                	ret

0000000080000f42 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000f42:	1141                	addi	sp,sp,-16
    80000f44:	e422                	sd	s0,8(sp)
    80000f46:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000f48:	c229                	beqz	a2,80000f8a <strncmp+0x48>
    80000f4a:	00054783          	lbu	a5,0(a0)
    80000f4e:	c795                	beqz	a5,80000f7a <strncmp+0x38>
    80000f50:	0005c703          	lbu	a4,0(a1)
    80000f54:	02f71363          	bne	a4,a5,80000f7a <strncmp+0x38>
    80000f58:	fff6071b          	addiw	a4,a2,-1
    80000f5c:	1702                	slli	a4,a4,0x20
    80000f5e:	9301                	srli	a4,a4,0x20
    80000f60:	0705                	addi	a4,a4,1
    80000f62:	972a                	add	a4,a4,a0
    n--, p++, q++;
    80000f64:	0505                	addi	a0,a0,1
    80000f66:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000f68:	02e50363          	beq	a0,a4,80000f8e <strncmp+0x4c>
    80000f6c:	00054783          	lbu	a5,0(a0)
    80000f70:	c789                	beqz	a5,80000f7a <strncmp+0x38>
    80000f72:	0005c683          	lbu	a3,0(a1)
    80000f76:	fef687e3          	beq	a3,a5,80000f64 <strncmp+0x22>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
    80000f7a:	00054503          	lbu	a0,0(a0)
    80000f7e:	0005c783          	lbu	a5,0(a1)
    80000f82:	9d1d                	subw	a0,a0,a5
}
    80000f84:	6422                	ld	s0,8(sp)
    80000f86:	0141                	addi	sp,sp,16
    80000f88:	8082                	ret
    return 0;
    80000f8a:	4501                	li	a0,0
    80000f8c:	bfe5                	j	80000f84 <strncmp+0x42>
    80000f8e:	4501                	li	a0,0
    80000f90:	bfd5                	j	80000f84 <strncmp+0x42>

0000000080000f92 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000f92:	1141                	addi	sp,sp,-16
    80000f94:	e422                	sd	s0,8(sp)
    80000f96:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000f98:	872a                	mv	a4,a0
    80000f9a:	a011                	j	80000f9e <strncpy+0xc>
    80000f9c:	8636                	mv	a2,a3
    80000f9e:	fff6069b          	addiw	a3,a2,-1
    80000fa2:	00c05963          	blez	a2,80000fb4 <strncpy+0x22>
    80000fa6:	0705                	addi	a4,a4,1
    80000fa8:	0005c783          	lbu	a5,0(a1)
    80000fac:	fef70fa3          	sb	a5,-1(a4)
    80000fb0:	0585                	addi	a1,a1,1
    80000fb2:	f7ed                	bnez	a5,80000f9c <strncpy+0xa>
    ;
  while(n-- > 0)
    80000fb4:	00d05c63          	blez	a3,80000fcc <strncpy+0x3a>
    80000fb8:	86ba                	mv	a3,a4
    *s++ = 0;
    80000fba:	0685                	addi	a3,a3,1
    80000fbc:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000fc0:	fff6c793          	not	a5,a3
    80000fc4:	9fb9                	addw	a5,a5,a4
    80000fc6:	9fb1                	addw	a5,a5,a2
    80000fc8:	fef049e3          	bgtz	a5,80000fba <strncpy+0x28>
  return os;
}
    80000fcc:	6422                	ld	s0,8(sp)
    80000fce:	0141                	addi	sp,sp,16
    80000fd0:	8082                	ret

0000000080000fd2 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000fd2:	1141                	addi	sp,sp,-16
    80000fd4:	e422                	sd	s0,8(sp)
    80000fd6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000fd8:	02c05363          	blez	a2,80000ffe <safestrcpy+0x2c>
    80000fdc:	fff6069b          	addiw	a3,a2,-1
    80000fe0:	1682                	slli	a3,a3,0x20
    80000fe2:	9281                	srli	a3,a3,0x20
    80000fe4:	96ae                	add	a3,a3,a1
    80000fe6:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000fe8:	00d58963          	beq	a1,a3,80000ffa <safestrcpy+0x28>
    80000fec:	0585                	addi	a1,a1,1
    80000fee:	0785                	addi	a5,a5,1
    80000ff0:	fff5c703          	lbu	a4,-1(a1)
    80000ff4:	fee78fa3          	sb	a4,-1(a5)
    80000ff8:	fb65                	bnez	a4,80000fe8 <safestrcpy+0x16>
    ;
  *s = 0;
    80000ffa:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ffe:	6422                	ld	s0,8(sp)
    80001000:	0141                	addi	sp,sp,16
    80001002:	8082                	ret

0000000080001004 <strlen>:

int
strlen(const char *s)
{
    80001004:	1141                	addi	sp,sp,-16
    80001006:	e422                	sd	s0,8(sp)
    80001008:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    8000100a:	00054783          	lbu	a5,0(a0)
    8000100e:	cf91                	beqz	a5,8000102a <strlen+0x26>
    80001010:	0505                	addi	a0,a0,1
    80001012:	87aa                	mv	a5,a0
    80001014:	4685                	li	a3,1
    80001016:	9e89                	subw	a3,a3,a0
    80001018:	00f6853b          	addw	a0,a3,a5
    8000101c:	0785                	addi	a5,a5,1
    8000101e:	fff7c703          	lbu	a4,-1(a5)
    80001022:	fb7d                	bnez	a4,80001018 <strlen+0x14>
    ;
  return n;
}
    80001024:	6422                	ld	s0,8(sp)
    80001026:	0141                	addi	sp,sp,16
    80001028:	8082                	ret
  for(n = 0; s[n]; n++)
    8000102a:	4501                	li	a0,0
    8000102c:	bfe5                	j	80001024 <strlen+0x20>

000000008000102e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    8000102e:	1141                	addi	sp,sp,-16
    80001030:	e406                	sd	ra,8(sp)
    80001032:	e022                	sd	s0,0(sp)
    80001034:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001036:	00001097          	auipc	ra,0x1
    8000103a:	c2c080e7          	jalr	-980(ra) # 80001c62 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000103e:	00008717          	auipc	a4,0x8
    80001042:	fce70713          	addi	a4,a4,-50 # 8000900c <started>
  if(cpuid() == 0){
    80001046:	c139                	beqz	a0,8000108c <main+0x5e>
    while(started == 0)
    80001048:	431c                	lw	a5,0(a4)
    8000104a:	2781                	sext.w	a5,a5
    8000104c:	dff5                	beqz	a5,80001048 <main+0x1a>
      ;
    __sync_synchronize();
    8000104e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80001052:	00001097          	auipc	ra,0x1
    80001056:	c10080e7          	jalr	-1008(ra) # 80001c62 <cpuid>
    8000105a:	85aa                	mv	a1,a0
    8000105c:	00007517          	auipc	a0,0x7
    80001060:	09450513          	addi	a0,a0,148 # 800080f0 <digits+0xd8>
    80001064:	fffff097          	auipc	ra,0xfffff
    80001068:	55a080e7          	jalr	1370(ra) # 800005be <printf>
    kvminithart();    // turn on paging
    8000106c:	00000097          	auipc	ra,0x0
    80001070:	0d8080e7          	jalr	216(ra) # 80001144 <kvminithart>
    trapinithart();   // install kernel trap vector
    80001074:	00002097          	auipc	ra,0x2
    80001078:	884080e7          	jalr	-1916(ra) # 800028f8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000107c:	00005097          	auipc	ra,0x5
    80001080:	f24080e7          	jalr	-220(ra) # 80005fa0 <plicinithart>
  }

  scheduler();        
    80001084:	00001097          	auipc	ra,0x1
    80001088:	140080e7          	jalr	320(ra) # 800021c4 <scheduler>
    consoleinit();
    8000108c:	fffff097          	auipc	ra,0xfffff
    80001090:	3f6080e7          	jalr	1014(ra) # 80000482 <consoleinit>
    printfinit();
    80001094:	fffff097          	auipc	ra,0xfffff
    80001098:	710080e7          	jalr	1808(ra) # 800007a4 <printfinit>
    printf("\n");
    8000109c:	00007517          	auipc	a0,0x7
    800010a0:	06450513          	addi	a0,a0,100 # 80008100 <digits+0xe8>
    800010a4:	fffff097          	auipc	ra,0xfffff
    800010a8:	51a080e7          	jalr	1306(ra) # 800005be <printf>
    printf("xv6 kernel is booting\n");
    800010ac:	00007517          	auipc	a0,0x7
    800010b0:	02c50513          	addi	a0,a0,44 # 800080d8 <digits+0xc0>
    800010b4:	fffff097          	auipc	ra,0xfffff
    800010b8:	50a080e7          	jalr	1290(ra) # 800005be <printf>
    printf("\n");
    800010bc:	00007517          	auipc	a0,0x7
    800010c0:	04450513          	addi	a0,a0,68 # 80008100 <digits+0xe8>
    800010c4:	fffff097          	auipc	ra,0xfffff
    800010c8:	4fa080e7          	jalr	1274(ra) # 800005be <printf>
    kinit();         // physical page allocator
    800010cc:	00000097          	auipc	ra,0x0
    800010d0:	ac4080e7          	jalr	-1340(ra) # 80000b90 <kinit>
    kvminit();       // create kernel page table
    800010d4:	00000097          	auipc	ra,0x0
    800010d8:	2a6080e7          	jalr	678(ra) # 8000137a <kvminit>
    kvminithart();   // turn on paging
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	068080e7          	jalr	104(ra) # 80001144 <kvminithart>
    procinit();      // process table
    800010e4:	00001097          	auipc	ra,0x1
    800010e8:	aae080e7          	jalr	-1362(ra) # 80001b92 <procinit>
    trapinit();      // trap vectors
    800010ec:	00001097          	auipc	ra,0x1
    800010f0:	7e4080e7          	jalr	2020(ra) # 800028d0 <trapinit>
    trapinithart();  // install kernel trap vector
    800010f4:	00002097          	auipc	ra,0x2
    800010f8:	804080e7          	jalr	-2044(ra) # 800028f8 <trapinithart>
    plicinit();      // set up interrupt controller
    800010fc:	00005097          	auipc	ra,0x5
    80001100:	e8e080e7          	jalr	-370(ra) # 80005f8a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001104:	00005097          	auipc	ra,0x5
    80001108:	e9c080e7          	jalr	-356(ra) # 80005fa0 <plicinithart>
    binit();         // buffer cache
    8000110c:	00002097          	auipc	ra,0x2
    80001110:	f60080e7          	jalr	-160(ra) # 8000306c <binit>
    iinit();         // inode cache
    80001114:	00002097          	auipc	ra,0x2
    80001118:	632080e7          	jalr	1586(ra) # 80003746 <iinit>
    fileinit();      // file table
    8000111c:	00003097          	auipc	ra,0x3
    80001120:	5fc080e7          	jalr	1532(ra) # 80004718 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001124:	00005097          	auipc	ra,0x5
    80001128:	f86080e7          	jalr	-122(ra) # 800060aa <virtio_disk_init>
    userinit();      // first user process
    8000112c:	00001097          	auipc	ra,0x1
    80001130:	e2e080e7          	jalr	-466(ra) # 80001f5a <userinit>
    __sync_synchronize();
    80001134:	0ff0000f          	fence
    started = 1;
    80001138:	4785                	li	a5,1
    8000113a:	00008717          	auipc	a4,0x8
    8000113e:	ecf72923          	sw	a5,-302(a4) # 8000900c <started>
    80001142:	b789                	j	80001084 <main+0x56>

0000000080001144 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001144:	1141                	addi	sp,sp,-16
    80001146:	e422                	sd	s0,8(sp)
    80001148:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000114a:	00008797          	auipc	a5,0x8
    8000114e:	ec678793          	addi	a5,a5,-314 # 80009010 <kernel_pagetable>
    80001152:	639c                	ld	a5,0(a5)
    80001154:	83b1                	srli	a5,a5,0xc
    80001156:	577d                	li	a4,-1
    80001158:	177e                	slli	a4,a4,0x3f
    8000115a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000115c:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001160:	12000073          	sfence.vma
  sfence_vma();
}
    80001164:	6422                	ld	s0,8(sp)
    80001166:	0141                	addi	sp,sp,16
    80001168:	8082                	ret

000000008000116a <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000116a:	7139                	addi	sp,sp,-64
    8000116c:	fc06                	sd	ra,56(sp)
    8000116e:	f822                	sd	s0,48(sp)
    80001170:	f426                	sd	s1,40(sp)
    80001172:	f04a                	sd	s2,32(sp)
    80001174:	ec4e                	sd	s3,24(sp)
    80001176:	e852                	sd	s4,16(sp)
    80001178:	e456                	sd	s5,8(sp)
    8000117a:	e05a                	sd	s6,0(sp)
    8000117c:	0080                	addi	s0,sp,64
    8000117e:	84aa                	mv	s1,a0
    80001180:	89ae                	mv	s3,a1
    80001182:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80001184:	57fd                	li	a5,-1
    80001186:	83e9                	srli	a5,a5,0x1a
    80001188:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000118a:	4ab1                	li	s5,12
  if(va >= MAXVA)
    8000118c:	04b7f263          	bleu	a1,a5,800011d0 <walk+0x66>
    panic("walk");
    80001190:	00007517          	auipc	a0,0x7
    80001194:	f7850513          	addi	a0,a0,-136 # 80008108 <digits+0xf0>
    80001198:	fffff097          	auipc	ra,0xfffff
    8000119c:	3dc080e7          	jalr	988(ra) # 80000574 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800011a0:	060b0663          	beqz	s6,8000120c <walk+0xa2>
    800011a4:	00000097          	auipc	ra,0x0
    800011a8:	a28080e7          	jalr	-1496(ra) # 80000bcc <kalloc>
    800011ac:	84aa                	mv	s1,a0
    800011ae:	c529                	beqz	a0,800011f8 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800011b0:	6605                	lui	a2,0x1
    800011b2:	4581                	li	a1,0
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	ca6080e7          	jalr	-858(ra) # 80000e5a <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800011bc:	00c4d793          	srli	a5,s1,0xc
    800011c0:	07aa                	slli	a5,a5,0xa
    800011c2:	0017e793          	ori	a5,a5,1
    800011c6:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800011ca:	3a5d                	addiw	s4,s4,-9
    800011cc:	035a0063          	beq	s4,s5,800011ec <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800011d0:	0149d933          	srl	s2,s3,s4
    800011d4:	1ff97913          	andi	s2,s2,511
    800011d8:	090e                	slli	s2,s2,0x3
    800011da:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800011dc:	00093483          	ld	s1,0(s2)
    800011e0:	0014f793          	andi	a5,s1,1
    800011e4:	dfd5                	beqz	a5,800011a0 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800011e6:	80a9                	srli	s1,s1,0xa
    800011e8:	04b2                	slli	s1,s1,0xc
    800011ea:	b7c5                	j	800011ca <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800011ec:	00c9d513          	srli	a0,s3,0xc
    800011f0:	1ff57513          	andi	a0,a0,511
    800011f4:	050e                	slli	a0,a0,0x3
    800011f6:	9526                	add	a0,a0,s1
}
    800011f8:	70e2                	ld	ra,56(sp)
    800011fa:	7442                	ld	s0,48(sp)
    800011fc:	74a2                	ld	s1,40(sp)
    800011fe:	7902                	ld	s2,32(sp)
    80001200:	69e2                	ld	s3,24(sp)
    80001202:	6a42                	ld	s4,16(sp)
    80001204:	6aa2                	ld	s5,8(sp)
    80001206:	6b02                	ld	s6,0(sp)
    80001208:	6121                	addi	sp,sp,64
    8000120a:	8082                	ret
        return 0;
    8000120c:	4501                	li	a0,0
    8000120e:	b7ed                	j	800011f8 <walk+0x8e>

0000000080001210 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001210:	57fd                	li	a5,-1
    80001212:	83e9                	srli	a5,a5,0x1a
    80001214:	00b7f463          	bleu	a1,a5,8000121c <walkaddr+0xc>
    return 0;
    80001218:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000121a:	8082                	ret
{
    8000121c:	1141                	addi	sp,sp,-16
    8000121e:	e406                	sd	ra,8(sp)
    80001220:	e022                	sd	s0,0(sp)
    80001222:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001224:	4601                	li	a2,0
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	f44080e7          	jalr	-188(ra) # 8000116a <walk>
  if(pte == 0)
    8000122e:	c105                	beqz	a0,8000124e <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001230:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001232:	0117f693          	andi	a3,a5,17
    80001236:	4745                	li	a4,17
    return 0;
    80001238:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000123a:	00e68663          	beq	a3,a4,80001246 <walkaddr+0x36>
}
    8000123e:	60a2                	ld	ra,8(sp)
    80001240:	6402                	ld	s0,0(sp)
    80001242:	0141                	addi	sp,sp,16
    80001244:	8082                	ret
  pa = PTE2PA(*pte);
    80001246:	00a7d513          	srli	a0,a5,0xa
    8000124a:	0532                	slli	a0,a0,0xc
  return pa;
    8000124c:	bfcd                	j	8000123e <walkaddr+0x2e>
    return 0;
    8000124e:	4501                	li	a0,0
    80001250:	b7fd                	j	8000123e <walkaddr+0x2e>

0000000080001252 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    80001252:	1101                	addi	sp,sp,-32
    80001254:	ec06                	sd	ra,24(sp)
    80001256:	e822                	sd	s0,16(sp)
    80001258:	e426                	sd	s1,8(sp)
    8000125a:	1000                	addi	s0,sp,32
    8000125c:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    8000125e:	6785                	lui	a5,0x1
    80001260:	17fd                	addi	a5,a5,-1
    80001262:	00f574b3          	and	s1,a0,a5
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    80001266:	4601                	li	a2,0
    80001268:	00008797          	auipc	a5,0x8
    8000126c:	da878793          	addi	a5,a5,-600 # 80009010 <kernel_pagetable>
    80001270:	6388                	ld	a0,0(a5)
    80001272:	00000097          	auipc	ra,0x0
    80001276:	ef8080e7          	jalr	-264(ra) # 8000116a <walk>
  if(pte == 0)
    8000127a:	cd09                	beqz	a0,80001294 <kvmpa+0x42>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    8000127c:	6108                	ld	a0,0(a0)
    8000127e:	00157793          	andi	a5,a0,1
    80001282:	c38d                	beqz	a5,800012a4 <kvmpa+0x52>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001284:	8129                	srli	a0,a0,0xa
    80001286:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    80001288:	9526                	add	a0,a0,s1
    8000128a:	60e2                	ld	ra,24(sp)
    8000128c:	6442                	ld	s0,16(sp)
    8000128e:	64a2                	ld	s1,8(sp)
    80001290:	6105                	addi	sp,sp,32
    80001292:	8082                	ret
    panic("kvmpa");
    80001294:	00007517          	auipc	a0,0x7
    80001298:	e7c50513          	addi	a0,a0,-388 # 80008110 <digits+0xf8>
    8000129c:	fffff097          	auipc	ra,0xfffff
    800012a0:	2d8080e7          	jalr	728(ra) # 80000574 <panic>
    panic("kvmpa");
    800012a4:	00007517          	auipc	a0,0x7
    800012a8:	e6c50513          	addi	a0,a0,-404 # 80008110 <digits+0xf8>
    800012ac:	fffff097          	auipc	ra,0xfffff
    800012b0:	2c8080e7          	jalr	712(ra) # 80000574 <panic>

00000000800012b4 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800012b4:	715d                	addi	sp,sp,-80
    800012b6:	e486                	sd	ra,72(sp)
    800012b8:	e0a2                	sd	s0,64(sp)
    800012ba:	fc26                	sd	s1,56(sp)
    800012bc:	f84a                	sd	s2,48(sp)
    800012be:	f44e                	sd	s3,40(sp)
    800012c0:	f052                	sd	s4,32(sp)
    800012c2:	ec56                	sd	s5,24(sp)
    800012c4:	e85a                	sd	s6,16(sp)
    800012c6:	e45e                	sd	s7,8(sp)
    800012c8:	0880                	addi	s0,sp,80
    800012ca:	8aaa                	mv	s5,a0
    800012cc:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800012ce:	79fd                	lui	s3,0xfffff
    800012d0:	0135fa33          	and	s4,a1,s3
  last = PGROUNDDOWN(va + size - 1);
    800012d4:	167d                	addi	a2,a2,-1
    800012d6:	962e                	add	a2,a2,a1
    800012d8:	013679b3          	and	s3,a2,s3
  a = PGROUNDDOWN(va);
    800012dc:	8952                	mv	s2,s4
    800012de:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800012e2:	6b85                	lui	s7,0x1
    800012e4:	a811                	j	800012f8 <mappages+0x44>
      panic("remap");
    800012e6:	00007517          	auipc	a0,0x7
    800012ea:	e3250513          	addi	a0,a0,-462 # 80008118 <digits+0x100>
    800012ee:	fffff097          	auipc	ra,0xfffff
    800012f2:	286080e7          	jalr	646(ra) # 80000574 <panic>
    a += PGSIZE;
    800012f6:	995e                	add	s2,s2,s7
  for(;;){
    800012f8:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800012fc:	4605                	li	a2,1
    800012fe:	85ca                	mv	a1,s2
    80001300:	8556                	mv	a0,s5
    80001302:	00000097          	auipc	ra,0x0
    80001306:	e68080e7          	jalr	-408(ra) # 8000116a <walk>
    8000130a:	cd19                	beqz	a0,80001328 <mappages+0x74>
    if(*pte & PTE_V)
    8000130c:	611c                	ld	a5,0(a0)
    8000130e:	8b85                	andi	a5,a5,1
    80001310:	fbf9                	bnez	a5,800012e6 <mappages+0x32>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001312:	80b1                	srli	s1,s1,0xc
    80001314:	04aa                	slli	s1,s1,0xa
    80001316:	0164e4b3          	or	s1,s1,s6
    8000131a:	0014e493          	ori	s1,s1,1
    8000131e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001320:	fd391be3          	bne	s2,s3,800012f6 <mappages+0x42>
    pa += PGSIZE;
  }
  return 0;
    80001324:	4501                	li	a0,0
    80001326:	a011                	j	8000132a <mappages+0x76>
      return -1;
    80001328:	557d                	li	a0,-1
}
    8000132a:	60a6                	ld	ra,72(sp)
    8000132c:	6406                	ld	s0,64(sp)
    8000132e:	74e2                	ld	s1,56(sp)
    80001330:	7942                	ld	s2,48(sp)
    80001332:	79a2                	ld	s3,40(sp)
    80001334:	7a02                	ld	s4,32(sp)
    80001336:	6ae2                	ld	s5,24(sp)
    80001338:	6b42                	ld	s6,16(sp)
    8000133a:	6ba2                	ld	s7,8(sp)
    8000133c:	6161                	addi	sp,sp,80
    8000133e:	8082                	ret

0000000080001340 <kvmmap>:
{
    80001340:	1141                	addi	sp,sp,-16
    80001342:	e406                	sd	ra,8(sp)
    80001344:	e022                	sd	s0,0(sp)
    80001346:	0800                	addi	s0,sp,16
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001348:	8736                	mv	a4,a3
    8000134a:	86ae                	mv	a3,a1
    8000134c:	85aa                	mv	a1,a0
    8000134e:	00008797          	auipc	a5,0x8
    80001352:	cc278793          	addi	a5,a5,-830 # 80009010 <kernel_pagetable>
    80001356:	6388                	ld	a0,0(a5)
    80001358:	00000097          	auipc	ra,0x0
    8000135c:	f5c080e7          	jalr	-164(ra) # 800012b4 <mappages>
    80001360:	e509                	bnez	a0,8000136a <kvmmap+0x2a>
}
    80001362:	60a2                	ld	ra,8(sp)
    80001364:	6402                	ld	s0,0(sp)
    80001366:	0141                	addi	sp,sp,16
    80001368:	8082                	ret
    panic("kvmmap");
    8000136a:	00007517          	auipc	a0,0x7
    8000136e:	db650513          	addi	a0,a0,-586 # 80008120 <digits+0x108>
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	202080e7          	jalr	514(ra) # 80000574 <panic>

000000008000137a <kvminit>:
{
    8000137a:	1101                	addi	sp,sp,-32
    8000137c:	ec06                	sd	ra,24(sp)
    8000137e:	e822                	sd	s0,16(sp)
    80001380:	e426                	sd	s1,8(sp)
    80001382:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001384:	00000097          	auipc	ra,0x0
    80001388:	848080e7          	jalr	-1976(ra) # 80000bcc <kalloc>
    8000138c:	00008797          	auipc	a5,0x8
    80001390:	c8a7b223          	sd	a0,-892(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001394:	6605                	lui	a2,0x1
    80001396:	4581                	li	a1,0
    80001398:	00000097          	auipc	ra,0x0
    8000139c:	ac2080e7          	jalr	-1342(ra) # 80000e5a <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800013a0:	4699                	li	a3,6
    800013a2:	6605                	lui	a2,0x1
    800013a4:	100005b7          	lui	a1,0x10000
    800013a8:	10000537          	lui	a0,0x10000
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	f94080e7          	jalr	-108(ra) # 80001340 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800013b4:	4699                	li	a3,6
    800013b6:	6605                	lui	a2,0x1
    800013b8:	100015b7          	lui	a1,0x10001
    800013bc:	10001537          	lui	a0,0x10001
    800013c0:	00000097          	auipc	ra,0x0
    800013c4:	f80080e7          	jalr	-128(ra) # 80001340 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    800013c8:	4699                	li	a3,6
    800013ca:	6641                	lui	a2,0x10
    800013cc:	020005b7          	lui	a1,0x2000
    800013d0:	02000537          	lui	a0,0x2000
    800013d4:	00000097          	auipc	ra,0x0
    800013d8:	f6c080e7          	jalr	-148(ra) # 80001340 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800013dc:	4699                	li	a3,6
    800013de:	00400637          	lui	a2,0x400
    800013e2:	0c0005b7          	lui	a1,0xc000
    800013e6:	0c000537          	lui	a0,0xc000
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	f56080e7          	jalr	-170(ra) # 80001340 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800013f2:	00007497          	auipc	s1,0x7
    800013f6:	c0e48493          	addi	s1,s1,-1010 # 80008000 <etext>
    800013fa:	46a9                	li	a3,10
    800013fc:	80007617          	auipc	a2,0x80007
    80001400:	c0460613          	addi	a2,a2,-1020 # 8000 <_entry-0x7fff8000>
    80001404:	4585                	li	a1,1
    80001406:	05fe                	slli	a1,a1,0x1f
    80001408:	852e                	mv	a0,a1
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	f36080e7          	jalr	-202(ra) # 80001340 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001412:	4699                	li	a3,6
    80001414:	4645                	li	a2,17
    80001416:	066e                	slli	a2,a2,0x1b
    80001418:	8e05                	sub	a2,a2,s1
    8000141a:	85a6                	mv	a1,s1
    8000141c:	8526                	mv	a0,s1
    8000141e:	00000097          	auipc	ra,0x0
    80001422:	f22080e7          	jalr	-222(ra) # 80001340 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001426:	46a9                	li	a3,10
    80001428:	6605                	lui	a2,0x1
    8000142a:	00006597          	auipc	a1,0x6
    8000142e:	bd658593          	addi	a1,a1,-1066 # 80007000 <_trampoline>
    80001432:	04000537          	lui	a0,0x4000
    80001436:	157d                	addi	a0,a0,-1
    80001438:	0532                	slli	a0,a0,0xc
    8000143a:	00000097          	auipc	ra,0x0
    8000143e:	f06080e7          	jalr	-250(ra) # 80001340 <kvmmap>
}
    80001442:	60e2                	ld	ra,24(sp)
    80001444:	6442                	ld	s0,16(sp)
    80001446:	64a2                	ld	s1,8(sp)
    80001448:	6105                	addi	sp,sp,32
    8000144a:	8082                	ret

000000008000144c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000144c:	715d                	addi	sp,sp,-80
    8000144e:	e486                	sd	ra,72(sp)
    80001450:	e0a2                	sd	s0,64(sp)
    80001452:	fc26                	sd	s1,56(sp)
    80001454:	f84a                	sd	s2,48(sp)
    80001456:	f44e                	sd	s3,40(sp)
    80001458:	f052                	sd	s4,32(sp)
    8000145a:	ec56                	sd	s5,24(sp)
    8000145c:	e85a                	sd	s6,16(sp)
    8000145e:	e45e                	sd	s7,8(sp)
    80001460:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1
    80001466:	8fed                	and	a5,a5,a1
    80001468:	e795                	bnez	a5,80001494 <uvmunmap+0x48>
    8000146a:	8a2a                	mv	s4,a0
    8000146c:	84ae                	mv	s1,a1
    8000146e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001470:	0632                	slli	a2,a2,0xc
    80001472:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001476:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001478:	6b05                	lui	s6,0x1
    8000147a:	0735e863          	bltu	a1,s3,800014ea <uvmunmap+0x9e>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000147e:	60a6                	ld	ra,72(sp)
    80001480:	6406                	ld	s0,64(sp)
    80001482:	74e2                	ld	s1,56(sp)
    80001484:	7942                	ld	s2,48(sp)
    80001486:	79a2                	ld	s3,40(sp)
    80001488:	7a02                	ld	s4,32(sp)
    8000148a:	6ae2                	ld	s5,24(sp)
    8000148c:	6b42                	ld	s6,16(sp)
    8000148e:	6ba2                	ld	s7,8(sp)
    80001490:	6161                	addi	sp,sp,80
    80001492:	8082                	ret
    panic("uvmunmap: not aligned");
    80001494:	00007517          	auipc	a0,0x7
    80001498:	c9450513          	addi	a0,a0,-876 # 80008128 <digits+0x110>
    8000149c:	fffff097          	auipc	ra,0xfffff
    800014a0:	0d8080e7          	jalr	216(ra) # 80000574 <panic>
      panic("uvmunmap: walk");
    800014a4:	00007517          	auipc	a0,0x7
    800014a8:	c9c50513          	addi	a0,a0,-868 # 80008140 <digits+0x128>
    800014ac:	fffff097          	auipc	ra,0xfffff
    800014b0:	0c8080e7          	jalr	200(ra) # 80000574 <panic>
      panic("uvmunmap: not mapped");
    800014b4:	00007517          	auipc	a0,0x7
    800014b8:	c9c50513          	addi	a0,a0,-868 # 80008150 <digits+0x138>
    800014bc:	fffff097          	auipc	ra,0xfffff
    800014c0:	0b8080e7          	jalr	184(ra) # 80000574 <panic>
      panic("uvmunmap: not a leaf");
    800014c4:	00007517          	auipc	a0,0x7
    800014c8:	ca450513          	addi	a0,a0,-860 # 80008168 <digits+0x150>
    800014cc:	fffff097          	auipc	ra,0xfffff
    800014d0:	0a8080e7          	jalr	168(ra) # 80000574 <panic>
      uint64 pa = PTE2PA(*pte);
    800014d4:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800014d6:	0532                	slli	a0,a0,0xc
    800014d8:	fffff097          	auipc	ra,0xfffff
    800014dc:	59a080e7          	jalr	1434(ra) # 80000a72 <kfree>
    *pte = 0;
    800014e0:	00093023          	sd	zero,0(s2)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014e4:	94da                	add	s1,s1,s6
    800014e6:	f934fce3          	bleu	s3,s1,8000147e <uvmunmap+0x32>
    if((pte = walk(pagetable, a, 0)) == 0)
    800014ea:	4601                	li	a2,0
    800014ec:	85a6                	mv	a1,s1
    800014ee:	8552                	mv	a0,s4
    800014f0:	00000097          	auipc	ra,0x0
    800014f4:	c7a080e7          	jalr	-902(ra) # 8000116a <walk>
    800014f8:	892a                	mv	s2,a0
    800014fa:	d54d                	beqz	a0,800014a4 <uvmunmap+0x58>
    if((*pte & PTE_V) == 0)
    800014fc:	6108                	ld	a0,0(a0)
    800014fe:	00157793          	andi	a5,a0,1
    80001502:	dbcd                	beqz	a5,800014b4 <uvmunmap+0x68>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001504:	3ff57793          	andi	a5,a0,1023
    80001508:	fb778ee3          	beq	a5,s7,800014c4 <uvmunmap+0x78>
    if(do_free){
    8000150c:	fc0a8ae3          	beqz	s5,800014e0 <uvmunmap+0x94>
    80001510:	b7d1                	j	800014d4 <uvmunmap+0x88>

0000000080001512 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001512:	1101                	addi	sp,sp,-32
    80001514:	ec06                	sd	ra,24(sp)
    80001516:	e822                	sd	s0,16(sp)
    80001518:	e426                	sd	s1,8(sp)
    8000151a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000151c:	fffff097          	auipc	ra,0xfffff
    80001520:	6b0080e7          	jalr	1712(ra) # 80000bcc <kalloc>
    80001524:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001526:	c519                	beqz	a0,80001534 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001528:	6605                	lui	a2,0x1
    8000152a:	4581                	li	a1,0
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	92e080e7          	jalr	-1746(ra) # 80000e5a <memset>
  return pagetable;
}
    80001534:	8526                	mv	a0,s1
    80001536:	60e2                	ld	ra,24(sp)
    80001538:	6442                	ld	s0,16(sp)
    8000153a:	64a2                	ld	s1,8(sp)
    8000153c:	6105                	addi	sp,sp,32
    8000153e:	8082                	ret

0000000080001540 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001540:	7179                	addi	sp,sp,-48
    80001542:	f406                	sd	ra,40(sp)
    80001544:	f022                	sd	s0,32(sp)
    80001546:	ec26                	sd	s1,24(sp)
    80001548:	e84a                	sd	s2,16(sp)
    8000154a:	e44e                	sd	s3,8(sp)
    8000154c:	e052                	sd	s4,0(sp)
    8000154e:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001550:	6785                	lui	a5,0x1
    80001552:	04f67863          	bleu	a5,a2,800015a2 <uvminit+0x62>
    80001556:	8a2a                	mv	s4,a0
    80001558:	89ae                	mv	s3,a1
    8000155a:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000155c:	fffff097          	auipc	ra,0xfffff
    80001560:	670080e7          	jalr	1648(ra) # 80000bcc <kalloc>
    80001564:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001566:	6605                	lui	a2,0x1
    80001568:	4581                	li	a1,0
    8000156a:	00000097          	auipc	ra,0x0
    8000156e:	8f0080e7          	jalr	-1808(ra) # 80000e5a <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001572:	4779                	li	a4,30
    80001574:	86ca                	mv	a3,s2
    80001576:	6605                	lui	a2,0x1
    80001578:	4581                	li	a1,0
    8000157a:	8552                	mv	a0,s4
    8000157c:	00000097          	auipc	ra,0x0
    80001580:	d38080e7          	jalr	-712(ra) # 800012b4 <mappages>
  memmove(mem, src, sz);
    80001584:	8626                	mv	a2,s1
    80001586:	85ce                	mv	a1,s3
    80001588:	854a                	mv	a0,s2
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	93c080e7          	jalr	-1732(ra) # 80000ec6 <memmove>
}
    80001592:	70a2                	ld	ra,40(sp)
    80001594:	7402                	ld	s0,32(sp)
    80001596:	64e2                	ld	s1,24(sp)
    80001598:	6942                	ld	s2,16(sp)
    8000159a:	69a2                	ld	s3,8(sp)
    8000159c:	6a02                	ld	s4,0(sp)
    8000159e:	6145                	addi	sp,sp,48
    800015a0:	8082                	ret
    panic("inituvm: more than a page");
    800015a2:	00007517          	auipc	a0,0x7
    800015a6:	bde50513          	addi	a0,a0,-1058 # 80008180 <digits+0x168>
    800015aa:	fffff097          	auipc	ra,0xfffff
    800015ae:	fca080e7          	jalr	-54(ra) # 80000574 <panic>

00000000800015b2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800015b2:	1101                	addi	sp,sp,-32
    800015b4:	ec06                	sd	ra,24(sp)
    800015b6:	e822                	sd	s0,16(sp)
    800015b8:	e426                	sd	s1,8(sp)
    800015ba:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800015bc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800015be:	00b67d63          	bleu	a1,a2,800015d8 <uvmdealloc+0x26>
    800015c2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800015c4:	6605                	lui	a2,0x1
    800015c6:	167d                	addi	a2,a2,-1
    800015c8:	00c487b3          	add	a5,s1,a2
    800015cc:	777d                	lui	a4,0xfffff
    800015ce:	8ff9                	and	a5,a5,a4
    800015d0:	962e                	add	a2,a2,a1
    800015d2:	8e79                	and	a2,a2,a4
    800015d4:	00c7e863          	bltu	a5,a2,800015e4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800015d8:	8526                	mv	a0,s1
    800015da:	60e2                	ld	ra,24(sp)
    800015dc:	6442                	ld	s0,16(sp)
    800015de:	64a2                	ld	s1,8(sp)
    800015e0:	6105                	addi	sp,sp,32
    800015e2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800015e4:	8e1d                	sub	a2,a2,a5
    800015e6:	8231                	srli	a2,a2,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800015e8:	4685                	li	a3,1
    800015ea:	2601                	sext.w	a2,a2
    800015ec:	85be                	mv	a1,a5
    800015ee:	00000097          	auipc	ra,0x0
    800015f2:	e5e080e7          	jalr	-418(ra) # 8000144c <uvmunmap>
    800015f6:	b7cd                	j	800015d8 <uvmdealloc+0x26>

00000000800015f8 <uvmalloc>:
  if(newsz < oldsz)
    800015f8:	0ab66163          	bltu	a2,a1,8000169a <uvmalloc+0xa2>
{
    800015fc:	7139                	addi	sp,sp,-64
    800015fe:	fc06                	sd	ra,56(sp)
    80001600:	f822                	sd	s0,48(sp)
    80001602:	f426                	sd	s1,40(sp)
    80001604:	f04a                	sd	s2,32(sp)
    80001606:	ec4e                	sd	s3,24(sp)
    80001608:	e852                	sd	s4,16(sp)
    8000160a:	e456                	sd	s5,8(sp)
    8000160c:	0080                	addi	s0,sp,64
  oldsz = PGROUNDUP(oldsz);
    8000160e:	6a05                	lui	s4,0x1
    80001610:	1a7d                	addi	s4,s4,-1
    80001612:	95d2                	add	a1,a1,s4
    80001614:	7a7d                	lui	s4,0xfffff
    80001616:	0145fa33          	and	s4,a1,s4
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000161a:	08ca7263          	bleu	a2,s4,8000169e <uvmalloc+0xa6>
    8000161e:	89b2                	mv	s3,a2
    80001620:	8aaa                	mv	s5,a0
    80001622:	8952                	mv	s2,s4
    mem = kalloc();
    80001624:	fffff097          	auipc	ra,0xfffff
    80001628:	5a8080e7          	jalr	1448(ra) # 80000bcc <kalloc>
    8000162c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000162e:	c51d                	beqz	a0,8000165c <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001630:	6605                	lui	a2,0x1
    80001632:	4581                	li	a1,0
    80001634:	00000097          	auipc	ra,0x0
    80001638:	826080e7          	jalr	-2010(ra) # 80000e5a <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000163c:	4779                	li	a4,30
    8000163e:	86a6                	mv	a3,s1
    80001640:	6605                	lui	a2,0x1
    80001642:	85ca                	mv	a1,s2
    80001644:	8556                	mv	a0,s5
    80001646:	00000097          	auipc	ra,0x0
    8000164a:	c6e080e7          	jalr	-914(ra) # 800012b4 <mappages>
    8000164e:	e905                	bnez	a0,8000167e <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001650:	6785                	lui	a5,0x1
    80001652:	993e                	add	s2,s2,a5
    80001654:	fd3968e3          	bltu	s2,s3,80001624 <uvmalloc+0x2c>
  return newsz;
    80001658:	854e                	mv	a0,s3
    8000165a:	a809                	j	8000166c <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000165c:	8652                	mv	a2,s4
    8000165e:	85ca                	mv	a1,s2
    80001660:	8556                	mv	a0,s5
    80001662:	00000097          	auipc	ra,0x0
    80001666:	f50080e7          	jalr	-176(ra) # 800015b2 <uvmdealloc>
      return 0;
    8000166a:	4501                	li	a0,0
}
    8000166c:	70e2                	ld	ra,56(sp)
    8000166e:	7442                	ld	s0,48(sp)
    80001670:	74a2                	ld	s1,40(sp)
    80001672:	7902                	ld	s2,32(sp)
    80001674:	69e2                	ld	s3,24(sp)
    80001676:	6a42                	ld	s4,16(sp)
    80001678:	6aa2                	ld	s5,8(sp)
    8000167a:	6121                	addi	sp,sp,64
    8000167c:	8082                	ret
      kfree(mem);
    8000167e:	8526                	mv	a0,s1
    80001680:	fffff097          	auipc	ra,0xfffff
    80001684:	3f2080e7          	jalr	1010(ra) # 80000a72 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001688:	8652                	mv	a2,s4
    8000168a:	85ca                	mv	a1,s2
    8000168c:	8556                	mv	a0,s5
    8000168e:	00000097          	auipc	ra,0x0
    80001692:	f24080e7          	jalr	-220(ra) # 800015b2 <uvmdealloc>
      return 0;
    80001696:	4501                	li	a0,0
    80001698:	bfd1                	j	8000166c <uvmalloc+0x74>
    return oldsz;
    8000169a:	852e                	mv	a0,a1
}
    8000169c:	8082                	ret
  return newsz;
    8000169e:	8532                	mv	a0,a2
    800016a0:	b7f1                	j	8000166c <uvmalloc+0x74>

00000000800016a2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800016a2:	7179                	addi	sp,sp,-48
    800016a4:	f406                	sd	ra,40(sp)
    800016a6:	f022                	sd	s0,32(sp)
    800016a8:	ec26                	sd	s1,24(sp)
    800016aa:	e84a                	sd	s2,16(sp)
    800016ac:	e44e                	sd	s3,8(sp)
    800016ae:	e052                	sd	s4,0(sp)
    800016b0:	1800                	addi	s0,sp,48
    800016b2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800016b4:	84aa                	mv	s1,a0
    800016b6:	6905                	lui	s2,0x1
    800016b8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016ba:	4985                	li	s3,1
    800016bc:	a821                	j	800016d4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800016be:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800016c0:	0532                	slli	a0,a0,0xc
    800016c2:	00000097          	auipc	ra,0x0
    800016c6:	fe0080e7          	jalr	-32(ra) # 800016a2 <freewalk>
      pagetable[i] = 0;
    800016ca:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800016ce:	04a1                	addi	s1,s1,8
    800016d0:	03248163          	beq	s1,s2,800016f2 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800016d4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016d6:	00f57793          	andi	a5,a0,15
    800016da:	ff3782e3          	beq	a5,s3,800016be <freewalk+0x1c>
    } else if(pte & PTE_V){
    800016de:	8905                	andi	a0,a0,1
    800016e0:	d57d                	beqz	a0,800016ce <freewalk+0x2c>
      panic("freewalk: leaf");
    800016e2:	00007517          	auipc	a0,0x7
    800016e6:	abe50513          	addi	a0,a0,-1346 # 800081a0 <digits+0x188>
    800016ea:	fffff097          	auipc	ra,0xfffff
    800016ee:	e8a080e7          	jalr	-374(ra) # 80000574 <panic>
    }
  }
  kfree((void*)pagetable);
    800016f2:	8552                	mv	a0,s4
    800016f4:	fffff097          	auipc	ra,0xfffff
    800016f8:	37e080e7          	jalr	894(ra) # 80000a72 <kfree>
}
    800016fc:	70a2                	ld	ra,40(sp)
    800016fe:	7402                	ld	s0,32(sp)
    80001700:	64e2                	ld	s1,24(sp)
    80001702:	6942                	ld	s2,16(sp)
    80001704:	69a2                	ld	s3,8(sp)
    80001706:	6a02                	ld	s4,0(sp)
    80001708:	6145                	addi	sp,sp,48
    8000170a:	8082                	ret

000000008000170c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000170c:	1101                	addi	sp,sp,-32
    8000170e:	ec06                	sd	ra,24(sp)
    80001710:	e822                	sd	s0,16(sp)
    80001712:	e426                	sd	s1,8(sp)
    80001714:	1000                	addi	s0,sp,32
    80001716:	84aa                	mv	s1,a0
  if(sz > 0)
    80001718:	e999                	bnez	a1,8000172e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000171a:	8526                	mv	a0,s1
    8000171c:	00000097          	auipc	ra,0x0
    80001720:	f86080e7          	jalr	-122(ra) # 800016a2 <freewalk>
}
    80001724:	60e2                	ld	ra,24(sp)
    80001726:	6442                	ld	s0,16(sp)
    80001728:	64a2                	ld	s1,8(sp)
    8000172a:	6105                	addi	sp,sp,32
    8000172c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000172e:	6605                	lui	a2,0x1
    80001730:	167d                	addi	a2,a2,-1
    80001732:	962e                	add	a2,a2,a1
    80001734:	4685                	li	a3,1
    80001736:	8231                	srli	a2,a2,0xc
    80001738:	4581                	li	a1,0
    8000173a:	00000097          	auipc	ra,0x0
    8000173e:	d12080e7          	jalr	-750(ra) # 8000144c <uvmunmap>
    80001742:	bfe1                	j	8000171a <uvmfree+0xe>

0000000080001744 <uvmcopy>:
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    80001744:	7139                	addi	sp,sp,-64
    80001746:	fc06                	sd	ra,56(sp)
    80001748:	f822                	sd	s0,48(sp)
    8000174a:	f426                	sd	s1,40(sp)
    8000174c:	f04a                	sd	s2,32(sp)
    8000174e:	ec4e                	sd	s3,24(sp)
    80001750:	e852                	sd	s4,16(sp)
    80001752:	e456                	sd	s5,8(sp)
    80001754:	e05a                	sd	s6,0(sp)
    80001756:	0080                	addi	s0,sp,64
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    80001758:	c255                	beqz	a2,800017fc <uvmcopy+0xb8>
    8000175a:	8a32                	mv	s4,a2
    8000175c:	8aae                	mv	s5,a1
    8000175e:	8b2a                	mv	s6,a0
    80001760:	4481                	li	s1,0
    if((pte = walk(old, i, 0)) == 0)
    80001762:	4601                	li	a2,0
    80001764:	85a6                	mv	a1,s1
    80001766:	855a                	mv	a0,s6
    80001768:	00000097          	auipc	ra,0x0
    8000176c:	a02080e7          	jalr	-1534(ra) # 8000116a <walk>
    80001770:	c129                	beqz	a0,800017b2 <uvmcopy+0x6e>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001772:	6118                	ld	a4,0(a0)
    80001774:	00177793          	andi	a5,a4,1
    80001778:	c7a9                	beqz	a5,800017c2 <uvmcopy+0x7e>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000177a:	00a75913          	srli	s2,a4,0xa
    8000177e:	0932                	slli	s2,s2,0xc
    *pte &= ~PTE_W;  // mask off W bit
    80001780:	9b6d                	andi	a4,a4,-5
    80001782:	e118                	sd	a4,0(a0)
    flags = PTE_FLAGS(*pte);
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    80001784:	3fb77713          	andi	a4,a4,1019
    80001788:	86ca                	mv	a3,s2
    8000178a:	6605                	lui	a2,0x1
    8000178c:	85a6                	mv	a1,s1
    8000178e:	8556                	mv	a0,s5
    80001790:	00000097          	auipc	ra,0x0
    80001794:	b24080e7          	jalr	-1244(ra) # 800012b4 <mappages>
    80001798:	89aa                	mv	s3,a0
    8000179a:	ed05                	bnez	a0,800017d2 <uvmcopy+0x8e>
      goto err;
    }
    adjustref(pa, 1); // one more process refers to this page
    8000179c:	4585                	li	a1,1
    8000179e:	854a                	mv	a0,s2
    800017a0:	fffff097          	auipc	ra,0xfffff
    800017a4:	4c4080e7          	jalr	1220(ra) # 80000c64 <adjustref>
  for(i = 0; i < sz; i += PGSIZE){
    800017a8:	6785                	lui	a5,0x1
    800017aa:	94be                	add	s1,s1,a5
    800017ac:	fb44ebe3          	bltu	s1,s4,80001762 <uvmcopy+0x1e>
    800017b0:	a81d                	j	800017e6 <uvmcopy+0xa2>
      panic("uvmcopy: pte should exist");
    800017b2:	00007517          	auipc	a0,0x7
    800017b6:	9fe50513          	addi	a0,a0,-1538 # 800081b0 <digits+0x198>
    800017ba:	fffff097          	auipc	ra,0xfffff
    800017be:	dba080e7          	jalr	-582(ra) # 80000574 <panic>
      panic("uvmcopy: page not present");
    800017c2:	00007517          	auipc	a0,0x7
    800017c6:	a0e50513          	addi	a0,a0,-1522 # 800081d0 <digits+0x1b8>
    800017ca:	fffff097          	auipc	ra,0xfffff
    800017ce:	daa080e7          	jalr	-598(ra) # 80000574 <panic>
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800017d2:	4685                	li	a3,1
    800017d4:	00c4d613          	srli	a2,s1,0xc
    800017d8:	4581                	li	a1,0
    800017da:	8556                	mv	a0,s5
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	c70080e7          	jalr	-912(ra) # 8000144c <uvmunmap>
  return -1;
    800017e4:	59fd                	li	s3,-1
}
    800017e6:	854e                	mv	a0,s3
    800017e8:	70e2                	ld	ra,56(sp)
    800017ea:	7442                	ld	s0,48(sp)
    800017ec:	74a2                	ld	s1,40(sp)
    800017ee:	7902                	ld	s2,32(sp)
    800017f0:	69e2                	ld	s3,24(sp)
    800017f2:	6a42                	ld	s4,16(sp)
    800017f4:	6aa2                	ld	s5,8(sp)
    800017f6:	6b02                	ld	s6,0(sp)
    800017f8:	6121                	addi	sp,sp,64
    800017fa:	8082                	ret
  return 0;
    800017fc:	4981                	li	s3,0
    800017fe:	b7e5                	j	800017e6 <uvmcopy+0xa2>

0000000080001800 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001800:	1141                	addi	sp,sp,-16
    80001802:	e406                	sd	ra,8(sp)
    80001804:	e022                	sd	s0,0(sp)
    80001806:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001808:	4601                	li	a2,0
    8000180a:	00000097          	auipc	ra,0x0
    8000180e:	960080e7          	jalr	-1696(ra) # 8000116a <walk>
  if(pte == 0)
    80001812:	c901                	beqz	a0,80001822 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001814:	611c                	ld	a5,0(a0)
    80001816:	9bbd                	andi	a5,a5,-17
    80001818:	e11c                	sd	a5,0(a0)
}
    8000181a:	60a2                	ld	ra,8(sp)
    8000181c:	6402                	ld	s0,0(sp)
    8000181e:	0141                	addi	sp,sp,16
    80001820:	8082                	ret
    panic("uvmclear");
    80001822:	00007517          	auipc	a0,0x7
    80001826:	9ce50513          	addi	a0,a0,-1586 # 800081f0 <digits+0x1d8>
    8000182a:	fffff097          	auipc	ra,0xfffff
    8000182e:	d4a080e7          	jalr	-694(ra) # 80000574 <panic>

0000000080001832 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

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
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001856:	6b05                	lui	s6,0x1
    80001858:	a01d                	j	8000187e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000185a:	014505b3          	add	a1,a0,s4
    8000185e:	0004861b          	sext.w	a2,s1
    80001862:	412585b3          	sub	a1,a1,s2
    80001866:	8556                	mv	a0,s5
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	65e080e7          	jalr	1630(ra) # 80000ec6 <memmove>

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
    8000188a:	98a080e7          	jalr	-1654(ra) # 80001210 <walkaddr>
    if(pa0 == 0)
    8000188e:	cd01                	beqz	a0,800018a6 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001890:	414904b3          	sub	s1,s2,s4
    80001894:	94da                	add	s1,s1,s6
    if(n > len)
    80001896:	fc99f2e3          	bleu	s1,s3,8000185a <copyin+0x28>
    8000189a:	84ce                	mv	s1,s3
    8000189c:	bf7d                	j	8000185a <copyin+0x28>
  }
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
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

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
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018e4:	6985                	lui	s3,0x1
    800018e6:	4b05                	li	s6,1
    800018e8:	a801                	j	800018f8 <copyinstr+0x38>
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
    800018ea:	87a6                	mv	a5,s1
    800018ec:	a085                	j	8000194c <copyinstr+0x8c>
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    800018ee:	84b2                	mv	s1,a2
    }

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
    80001904:	910080e7          	jalr	-1776(ra) # 80001210 <walkaddr>
    if(pa0 == 0)
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
    80001934:	00e78023          	sb	a4,0(a5) # 1000 <_entry-0x7ffff000>
      --max;
    80001938:	40f68bb3          	sub	s7,a3,a5
      p++;
    8000193c:	00f48733          	add	a4,s1,a5
      dst++;
    80001940:	0785                	addi	a5,a5,1
    while(n > 0){
    80001942:	faf606e3          	beq	a2,a5,800018ee <copyinstr+0x2e>
      if(*p == '\0'){
    80001946:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7fdb9000>
    8000194a:	f76d                	bnez	a4,80001934 <copyinstr+0x74>
        *dst = '\0';
    8000194c:	00078023          	sb	zero,0(a5)
    80001950:	4785                	li	a5,1
  }
  if(got_null){
    80001952:	0017b513          	seqz	a0,a5
    80001956:	40a0053b          	negw	a0,a0
    8000195a:	2501                	sext.w	a0,a0
    return 0;
  } else {
    return -1;
  }
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

000000008000198a <cowalloc>:

// copy-on-write page fault handler
// allocate a new physical page
// for virtual address va in this process's pagetable
int
cowalloc(pagetable_t pagetable, uint64 va) {
    8000198a:	7179                	addi	sp,sp,-48
    8000198c:	f406                	sd	ra,40(sp)
    8000198e:	f022                	sd	s0,32(sp)
    80001990:	ec26                	sd	s1,24(sp)
    80001992:	e84a                	sd	s2,16(sp)
    80001994:	e44e                	sd	s3,8(sp)
    80001996:	1800                	addi	s0,sp,48
  if (va >= MAXVA) {
    80001998:	57fd                	li	a5,-1
    8000199a:	83e9                	srli	a5,a5,0x1a
    8000199c:	06b7e763          	bltu	a5,a1,80001a0a <cowalloc+0x80>
    printf("cowalloc: exceeds MAXVA\n");
    return -1;
  }

  pte_t* pte = walk(pagetable, va, 0); // should refer to a shared PA
    800019a0:	4601                	li	a2,0
    800019a2:	fffff097          	auipc	ra,0xfffff
    800019a6:	7c8080e7          	jalr	1992(ra) # 8000116a <walk>
    800019aa:	89aa                	mv	s3,a0
  if (pte == 0) {
    800019ac:	c92d                	beqz	a0,80001a1e <cowalloc+0x94>
    panic("cowalloc: pte not exists");
  }
  if ((*pte & PTE_V) == 0 || (*pte & PTE_U) == 0) {
    800019ae:	611c                	ld	a5,0(a0)
    800019b0:	8bc5                	andi	a5,a5,17
    800019b2:	4745                	li	a4,17
    800019b4:	06e79d63          	bne	a5,a4,80001a2e <cowalloc+0xa4>
    panic("cowalloc: pte permission err");
  }
  uint64 pa_new = (uint64)kalloc();
    800019b8:	fffff097          	auipc	ra,0xfffff
    800019bc:	214080e7          	jalr	532(ra) # 80000bcc <kalloc>
    800019c0:	84aa                	mv	s1,a0
  if (pa_new == 0) {
    800019c2:	cd35                	beqz	a0,80001a3e <cowalloc+0xb4>
    printf("cowalloc: kalloc fails\n");
    return -1;
  }
  uint64 pa_old = PTE2PA(*pte);
    800019c4:	0009b903          	ld	s2,0(s3) # 1000 <_entry-0x7ffff000>
    800019c8:	00a95913          	srli	s2,s2,0xa
    800019cc:	0932                	slli	s2,s2,0xc
  memmove((void *)pa_new, (const void *)pa_old, PGSIZE);
    800019ce:	6605                	lui	a2,0x1
    800019d0:	85ca                	mv	a1,s2
    800019d2:	fffff097          	auipc	ra,0xfffff
    800019d6:	4f4080e7          	jalr	1268(ra) # 80000ec6 <memmove>
  kfree((void *)pa_old); // decrement ref count by 1
    800019da:	854a                	mv	a0,s2
    800019dc:	fffff097          	auipc	ra,0xfffff
    800019e0:	096080e7          	jalr	150(ra) # 80000a72 <kfree>
  *pte = PA2PTE(pa_new) | PTE_FLAGS(*pte) | PTE_W;
    800019e4:	80b1                	srli	s1,s1,0xc
    800019e6:	04aa                	slli	s1,s1,0xa
    800019e8:	0009b783          	ld	a5,0(s3)
    800019ec:	3ff7f793          	andi	a5,a5,1023
    800019f0:	8cdd                	or	s1,s1,a5
    800019f2:	0044e493          	ori	s1,s1,4
    800019f6:	0099b023          	sd	s1,0(s3)
  return 0;
    800019fa:	4501                	li	a0,0
}
    800019fc:	70a2                	ld	ra,40(sp)
    800019fe:	7402                	ld	s0,32(sp)
    80001a00:	64e2                	ld	s1,24(sp)
    80001a02:	6942                	ld	s2,16(sp)
    80001a04:	69a2                	ld	s3,8(sp)
    80001a06:	6145                	addi	sp,sp,48
    80001a08:	8082                	ret
    printf("cowalloc: exceeds MAXVA\n");
    80001a0a:	00006517          	auipc	a0,0x6
    80001a0e:	7f650513          	addi	a0,a0,2038 # 80008200 <digits+0x1e8>
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	bac080e7          	jalr	-1108(ra) # 800005be <printf>
    return -1;
    80001a1a:	557d                	li	a0,-1
    80001a1c:	b7c5                	j	800019fc <cowalloc+0x72>
    panic("cowalloc: pte not exists");
    80001a1e:	00007517          	auipc	a0,0x7
    80001a22:	80250513          	addi	a0,a0,-2046 # 80008220 <digits+0x208>
    80001a26:	fffff097          	auipc	ra,0xfffff
    80001a2a:	b4e080e7          	jalr	-1202(ra) # 80000574 <panic>
    panic("cowalloc: pte permission err");
    80001a2e:	00007517          	auipc	a0,0x7
    80001a32:	81250513          	addi	a0,a0,-2030 # 80008240 <digits+0x228>
    80001a36:	fffff097          	auipc	ra,0xfffff
    80001a3a:	b3e080e7          	jalr	-1218(ra) # 80000574 <panic>
    printf("cowalloc: kalloc fails\n");
    80001a3e:	00007517          	auipc	a0,0x7
    80001a42:	82250513          	addi	a0,a0,-2014 # 80008260 <digits+0x248>
    80001a46:	fffff097          	auipc	ra,0xfffff
    80001a4a:	b78080e7          	jalr	-1160(ra) # 800005be <printf>
    return -1;
    80001a4e:	557d                	li	a0,-1
    80001a50:	b775                	j	800019fc <cowalloc+0x72>

0000000080001a52 <copyout>:
  while(len > 0){
    80001a52:	caf5                	beqz	a3,80001b46 <copyout+0xf4>
{
    80001a54:	711d                	addi	sp,sp,-96
    80001a56:	ec86                	sd	ra,88(sp)
    80001a58:	e8a2                	sd	s0,80(sp)
    80001a5a:	e4a6                	sd	s1,72(sp)
    80001a5c:	e0ca                	sd	s2,64(sp)
    80001a5e:	fc4e                	sd	s3,56(sp)
    80001a60:	f852                	sd	s4,48(sp)
    80001a62:	f456                	sd	s5,40(sp)
    80001a64:	f05a                	sd	s6,32(sp)
    80001a66:	ec5e                	sd	s7,24(sp)
    80001a68:	e862                	sd	s8,16(sp)
    80001a6a:	e466                	sd	s9,8(sp)
    80001a6c:	e06a                	sd	s10,0(sp)
    80001a6e:	1080                	addi	s0,sp,96
    80001a70:	8aaa                	mv	s5,a0
    80001a72:	89ae                	mv	s3,a1
    80001a74:	8a32                	mv	s4,a2
    80001a76:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(dstva);
    80001a78:	74fd                	lui	s1,0xfffff
    80001a7a:	8ced                	and	s1,s1,a1
    if (va0 >= MAXVA) {
    80001a7c:	57fd                	li	a5,-1
    80001a7e:	83e9                	srli	a5,a5,0x1a
    80001a80:	0097e663          	bltu	a5,s1,80001a8c <copyout+0x3a>
    if (pte == 0 || (*pte & PTE_U) == 0 || (*pte & PTE_V) == 0) {
    80001a84:	4bc5                	li	s7,17
    80001a86:	6c05                	lui	s8,0x1
    if (va0 >= MAXVA) {
    80001a88:	8b3e                	mv	s6,a5
    80001a8a:	a8bd                	j	80001b08 <copyout+0xb6>
      printf("copyout: va exceeds MAXVA\n");
    80001a8c:	00006517          	auipc	a0,0x6
    80001a90:	7ec50513          	addi	a0,a0,2028 # 80008278 <digits+0x260>
    80001a94:	fffff097          	auipc	ra,0xfffff
    80001a98:	b2a080e7          	jalr	-1238(ra) # 800005be <printf>
      return -1;
    80001a9c:	557d                	li	a0,-1
    80001a9e:	a811                	j	80001ab2 <copyout+0x60>
      printf("copyout: invalid pte\n");
    80001aa0:	00006517          	auipc	a0,0x6
    80001aa4:	7f850513          	addi	a0,a0,2040 # 80008298 <digits+0x280>
    80001aa8:	fffff097          	auipc	ra,0xfffff
    80001aac:	b16080e7          	jalr	-1258(ra) # 800005be <printf>
      return -1;
    80001ab0:	557d                	li	a0,-1
}
    80001ab2:	60e6                	ld	ra,88(sp)
    80001ab4:	6446                	ld	s0,80(sp)
    80001ab6:	64a6                	ld	s1,72(sp)
    80001ab8:	6906                	ld	s2,64(sp)
    80001aba:	79e2                	ld	s3,56(sp)
    80001abc:	7a42                	ld	s4,48(sp)
    80001abe:	7aa2                	ld	s5,40(sp)
    80001ac0:	7b02                	ld	s6,32(sp)
    80001ac2:	6be2                	ld	s7,24(sp)
    80001ac4:	6c42                	ld	s8,16(sp)
    80001ac6:	6ca2                	ld	s9,8(sp)
    80001ac8:	6d02                	ld	s10,0(sp)
    80001aca:	6125                	addi	sp,sp,96
    80001acc:	8082                	ret
      if (cowalloc(pagetable, va0) < 0) {
    80001ace:	85a6                	mv	a1,s1
    80001ad0:	8556                	mv	a0,s5
    80001ad2:	00000097          	auipc	ra,0x0
    80001ad6:	eb8080e7          	jalr	-328(ra) # 8000198a <cowalloc>
    80001ada:	04055763          	bgez	a0,80001b28 <copyout+0xd6>
        return -1;
    80001ade:	557d                	li	a0,-1
    80001ae0:	bfc9                	j	80001ab2 <copyout+0x60>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001ae2:	40998533          	sub	a0,s3,s1
    80001ae6:	000c861b          	sext.w	a2,s9
    80001aea:	85d2                	mv	a1,s4
    80001aec:	953e                	add	a0,a0,a5
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	3d8080e7          	jalr	984(ra) # 80000ec6 <memmove>
    len -= n;
    80001af6:	41990933          	sub	s2,s2,s9
    src += n;
    80001afa:	9a66                	add	s4,s4,s9
  while(len > 0){
    80001afc:	04090363          	beqz	s2,80001b42 <copyout+0xf0>
    dstva = va0 + PGSIZE;
    80001b00:	89ea                	mv	s3,s10
    va0 = PGROUNDDOWN(dstva);
    80001b02:	84ea                	mv	s1,s10
    if (va0 >= MAXVA) {
    80001b04:	f9ab64e3          	bltu	s6,s10,80001a8c <copyout+0x3a>
    pte_t *pte = walk(pagetable, va0, 0);
    80001b08:	4601                	li	a2,0
    80001b0a:	85a6                	mv	a1,s1
    80001b0c:	8556                	mv	a0,s5
    80001b0e:	fffff097          	auipc	ra,0xfffff
    80001b12:	65c080e7          	jalr	1628(ra) # 8000116a <walk>
    80001b16:	8caa                	mv	s9,a0
    if (pte == 0 || (*pte & PTE_U) == 0 || (*pte & PTE_V) == 0) {
    80001b18:	d541                	beqz	a0,80001aa0 <copyout+0x4e>
    80001b1a:	611c                	ld	a5,0(a0)
    80001b1c:	0117f713          	andi	a4,a5,17
    80001b20:	f97710e3          	bne	a4,s7,80001aa0 <copyout+0x4e>
    if ((*pte & PTE_W) == 0) {
    80001b24:	8b91                	andi	a5,a5,4
    80001b26:	d7c5                	beqz	a5,80001ace <copyout+0x7c>
    pa0 = PTE2PA(*pte);
    80001b28:	000cb783          	ld	a5,0(s9)
    80001b2c:	83a9                	srli	a5,a5,0xa
    80001b2e:	07b2                	slli	a5,a5,0xc
    if(pa0 == 0)
    80001b30:	cf89                	beqz	a5,80001b4a <copyout+0xf8>
    n = PGSIZE - (dstva - va0);
    80001b32:	01848d33          	add	s10,s1,s8
    80001b36:	413d0cb3          	sub	s9,s10,s3
    if(n > len)
    80001b3a:	fb9974e3          	bleu	s9,s2,80001ae2 <copyout+0x90>
    80001b3e:	8cca                	mv	s9,s2
    80001b40:	b74d                	j	80001ae2 <copyout+0x90>
  return 0;
    80001b42:	4501                	li	a0,0
    80001b44:	b7bd                	j	80001ab2 <copyout+0x60>
    80001b46:	4501                	li	a0,0
}
    80001b48:	8082                	ret
      return -1;
    80001b4a:	557d                	li	a0,-1
    80001b4c:	b79d                	j	80001ab2 <copyout+0x60>

0000000080001b4e <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001b4e:	1101                	addi	sp,sp,-32
    80001b50:	ec06                	sd	ra,24(sp)
    80001b52:	e822                	sd	s0,16(sp)
    80001b54:	e426                	sd	s1,8(sp)
    80001b56:	1000                	addi	s0,sp,32
    80001b58:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	18a080e7          	jalr	394(ra) # 80000ce4 <holding>
    80001b62:	c909                	beqz	a0,80001b74 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001b64:	749c                	ld	a5,40(s1)
    80001b66:	00978f63          	beq	a5,s1,80001b84 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001b6a:	60e2                	ld	ra,24(sp)
    80001b6c:	6442                	ld	s0,16(sp)
    80001b6e:	64a2                	ld	s1,8(sp)
    80001b70:	6105                	addi	sp,sp,32
    80001b72:	8082                	ret
    panic("wakeup1");
    80001b74:	00006517          	auipc	a0,0x6
    80001b78:	76450513          	addi	a0,a0,1892 # 800082d8 <states.1732+0x28>
    80001b7c:	fffff097          	auipc	ra,0xfffff
    80001b80:	9f8080e7          	jalr	-1544(ra) # 80000574 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001b84:	4c98                	lw	a4,24(s1)
    80001b86:	4785                	li	a5,1
    80001b88:	fef711e3          	bne	a4,a5,80001b6a <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001b8c:	4789                	li	a5,2
    80001b8e:	cc9c                	sw	a5,24(s1)
}
    80001b90:	bfe9                	j	80001b6a <wakeup1+0x1c>

0000000080001b92 <procinit>:
{
    80001b92:	715d                	addi	sp,sp,-80
    80001b94:	e486                	sd	ra,72(sp)
    80001b96:	e0a2                	sd	s0,64(sp)
    80001b98:	fc26                	sd	s1,56(sp)
    80001b9a:	f84a                	sd	s2,48(sp)
    80001b9c:	f44e                	sd	s3,40(sp)
    80001b9e:	f052                	sd	s4,32(sp)
    80001ba0:	ec56                	sd	s5,24(sp)
    80001ba2:	e85a                	sd	s6,16(sp)
    80001ba4:	e45e                	sd	s7,8(sp)
    80001ba6:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001ba8:	00006597          	auipc	a1,0x6
    80001bac:	73858593          	addi	a1,a1,1848 # 800082e0 <states.1732+0x30>
    80001bb0:	00230517          	auipc	a0,0x230
    80001bb4:	da050513          	addi	a0,a0,-608 # 80231950 <pid_lock>
    80001bb8:	fffff097          	auipc	ra,0xfffff
    80001bbc:	116080e7          	jalr	278(ra) # 80000cce <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bc0:	00230917          	auipc	s2,0x230
    80001bc4:	1a890913          	addi	s2,s2,424 # 80231d68 <proc>
      initlock(&p->lock, "proc");
    80001bc8:	00006b97          	auipc	s7,0x6
    80001bcc:	720b8b93          	addi	s7,s7,1824 # 800082e8 <states.1732+0x38>
      uint64 va = KSTACK((int) (p - proc));
    80001bd0:	8b4a                	mv	s6,s2
    80001bd2:	00006a97          	auipc	s5,0x6
    80001bd6:	42ea8a93          	addi	s5,s5,1070 # 80008000 <etext>
    80001bda:	040009b7          	lui	s3,0x4000
    80001bde:	19fd                	addi	s3,s3,-1
    80001be0:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be2:	00236a17          	auipc	s4,0x236
    80001be6:	b86a0a13          	addi	s4,s4,-1146 # 80237768 <tickslock>
      initlock(&p->lock, "proc");
    80001bea:	85de                	mv	a1,s7
    80001bec:	854a                	mv	a0,s2
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	0e0080e7          	jalr	224(ra) # 80000cce <initlock>
      char *pa = kalloc();
    80001bf6:	fffff097          	auipc	ra,0xfffff
    80001bfa:	fd6080e7          	jalr	-42(ra) # 80000bcc <kalloc>
    80001bfe:	85aa                	mv	a1,a0
      if(pa == 0)
    80001c00:	c929                	beqz	a0,80001c52 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001c02:	416904b3          	sub	s1,s2,s6
    80001c06:	848d                	srai	s1,s1,0x3
    80001c08:	000ab783          	ld	a5,0(s5)
    80001c0c:	02f484b3          	mul	s1,s1,a5
    80001c10:	2485                	addiw	s1,s1,1
    80001c12:	00d4949b          	slliw	s1,s1,0xd
    80001c16:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001c1a:	4699                	li	a3,6
    80001c1c:	6605                	lui	a2,0x1
    80001c1e:	8526                	mv	a0,s1
    80001c20:	fffff097          	auipc	ra,0xfffff
    80001c24:	720080e7          	jalr	1824(ra) # 80001340 <kvmmap>
      p->kstack = va;
    80001c28:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c2c:	16890913          	addi	s2,s2,360
    80001c30:	fb491de3          	bne	s2,s4,80001bea <procinit+0x58>
  kvminithart();
    80001c34:	fffff097          	auipc	ra,0xfffff
    80001c38:	510080e7          	jalr	1296(ra) # 80001144 <kvminithart>
}
    80001c3c:	60a6                	ld	ra,72(sp)
    80001c3e:	6406                	ld	s0,64(sp)
    80001c40:	74e2                	ld	s1,56(sp)
    80001c42:	7942                	ld	s2,48(sp)
    80001c44:	79a2                	ld	s3,40(sp)
    80001c46:	7a02                	ld	s4,32(sp)
    80001c48:	6ae2                	ld	s5,24(sp)
    80001c4a:	6b42                	ld	s6,16(sp)
    80001c4c:	6ba2                	ld	s7,8(sp)
    80001c4e:	6161                	addi	sp,sp,80
    80001c50:	8082                	ret
        panic("kalloc");
    80001c52:	00006517          	auipc	a0,0x6
    80001c56:	69e50513          	addi	a0,a0,1694 # 800082f0 <states.1732+0x40>
    80001c5a:	fffff097          	auipc	ra,0xfffff
    80001c5e:	91a080e7          	jalr	-1766(ra) # 80000574 <panic>

0000000080001c62 <cpuid>:
{
    80001c62:	1141                	addi	sp,sp,-16
    80001c64:	e422                	sd	s0,8(sp)
    80001c66:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c68:	8512                	mv	a0,tp
}
    80001c6a:	2501                	sext.w	a0,a0
    80001c6c:	6422                	ld	s0,8(sp)
    80001c6e:	0141                	addi	sp,sp,16
    80001c70:	8082                	ret

0000000080001c72 <mycpu>:
mycpu(void) {
    80001c72:	1141                	addi	sp,sp,-16
    80001c74:	e422                	sd	s0,8(sp)
    80001c76:	0800                	addi	s0,sp,16
    80001c78:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001c7a:	2781                	sext.w	a5,a5
    80001c7c:	079e                	slli	a5,a5,0x7
}
    80001c7e:	00230517          	auipc	a0,0x230
    80001c82:	cea50513          	addi	a0,a0,-790 # 80231968 <cpus>
    80001c86:	953e                	add	a0,a0,a5
    80001c88:	6422                	ld	s0,8(sp)
    80001c8a:	0141                	addi	sp,sp,16
    80001c8c:	8082                	ret

0000000080001c8e <myproc>:
myproc(void) {
    80001c8e:	1101                	addi	sp,sp,-32
    80001c90:	ec06                	sd	ra,24(sp)
    80001c92:	e822                	sd	s0,16(sp)
    80001c94:	e426                	sd	s1,8(sp)
    80001c96:	1000                	addi	s0,sp,32
  push_off();
    80001c98:	fffff097          	auipc	ra,0xfffff
    80001c9c:	07a080e7          	jalr	122(ra) # 80000d12 <push_off>
    80001ca0:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001ca2:	2781                	sext.w	a5,a5
    80001ca4:	079e                	slli	a5,a5,0x7
    80001ca6:	00230717          	auipc	a4,0x230
    80001caa:	caa70713          	addi	a4,a4,-854 # 80231950 <pid_lock>
    80001cae:	97ba                	add	a5,a5,a4
    80001cb0:	6f84                	ld	s1,24(a5)
  pop_off();
    80001cb2:	fffff097          	auipc	ra,0xfffff
    80001cb6:	100080e7          	jalr	256(ra) # 80000db2 <pop_off>
}
    80001cba:	8526                	mv	a0,s1
    80001cbc:	60e2                	ld	ra,24(sp)
    80001cbe:	6442                	ld	s0,16(sp)
    80001cc0:	64a2                	ld	s1,8(sp)
    80001cc2:	6105                	addi	sp,sp,32
    80001cc4:	8082                	ret

0000000080001cc6 <forkret>:
{
    80001cc6:	1141                	addi	sp,sp,-16
    80001cc8:	e406                	sd	ra,8(sp)
    80001cca:	e022                	sd	s0,0(sp)
    80001ccc:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001cce:	00000097          	auipc	ra,0x0
    80001cd2:	fc0080e7          	jalr	-64(ra) # 80001c8e <myproc>
    80001cd6:	fffff097          	auipc	ra,0xfffff
    80001cda:	13c080e7          	jalr	316(ra) # 80000e12 <release>
  if (first) {
    80001cde:	00007797          	auipc	a5,0x7
    80001ce2:	c2278793          	addi	a5,a5,-990 # 80008900 <first.1692>
    80001ce6:	439c                	lw	a5,0(a5)
    80001ce8:	eb89                	bnez	a5,80001cfa <forkret+0x34>
  usertrapret();
    80001cea:	00001097          	auipc	ra,0x1
    80001cee:	c26080e7          	jalr	-986(ra) # 80002910 <usertrapret>
}
    80001cf2:	60a2                	ld	ra,8(sp)
    80001cf4:	6402                	ld	s0,0(sp)
    80001cf6:	0141                	addi	sp,sp,16
    80001cf8:	8082                	ret
    first = 0;
    80001cfa:	00007797          	auipc	a5,0x7
    80001cfe:	c007a323          	sw	zero,-1018(a5) # 80008900 <first.1692>
    fsinit(ROOTDEV);
    80001d02:	4505                	li	a0,1
    80001d04:	00002097          	auipc	ra,0x2
    80001d08:	9c4080e7          	jalr	-1596(ra) # 800036c8 <fsinit>
    80001d0c:	bff9                	j	80001cea <forkret+0x24>

0000000080001d0e <allocpid>:
allocpid() {
    80001d0e:	1101                	addi	sp,sp,-32
    80001d10:	ec06                	sd	ra,24(sp)
    80001d12:	e822                	sd	s0,16(sp)
    80001d14:	e426                	sd	s1,8(sp)
    80001d16:	e04a                	sd	s2,0(sp)
    80001d18:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001d1a:	00230917          	auipc	s2,0x230
    80001d1e:	c3690913          	addi	s2,s2,-970 # 80231950 <pid_lock>
    80001d22:	854a                	mv	a0,s2
    80001d24:	fffff097          	auipc	ra,0xfffff
    80001d28:	03a080e7          	jalr	58(ra) # 80000d5e <acquire>
  pid = nextpid;
    80001d2c:	00007797          	auipc	a5,0x7
    80001d30:	bd878793          	addi	a5,a5,-1064 # 80008904 <nextpid>
    80001d34:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001d36:	0014871b          	addiw	a4,s1,1
    80001d3a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001d3c:	854a                	mv	a0,s2
    80001d3e:	fffff097          	auipc	ra,0xfffff
    80001d42:	0d4080e7          	jalr	212(ra) # 80000e12 <release>
}
    80001d46:	8526                	mv	a0,s1
    80001d48:	60e2                	ld	ra,24(sp)
    80001d4a:	6442                	ld	s0,16(sp)
    80001d4c:	64a2                	ld	s1,8(sp)
    80001d4e:	6902                	ld	s2,0(sp)
    80001d50:	6105                	addi	sp,sp,32
    80001d52:	8082                	ret

0000000080001d54 <proc_pagetable>:
{
    80001d54:	1101                	addi	sp,sp,-32
    80001d56:	ec06                	sd	ra,24(sp)
    80001d58:	e822                	sd	s0,16(sp)
    80001d5a:	e426                	sd	s1,8(sp)
    80001d5c:	e04a                	sd	s2,0(sp)
    80001d5e:	1000                	addi	s0,sp,32
    80001d60:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001d62:	fffff097          	auipc	ra,0xfffff
    80001d66:	7b0080e7          	jalr	1968(ra) # 80001512 <uvmcreate>
    80001d6a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001d6c:	c121                	beqz	a0,80001dac <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d6e:	4729                	li	a4,10
    80001d70:	00005697          	auipc	a3,0x5
    80001d74:	29068693          	addi	a3,a3,656 # 80007000 <_trampoline>
    80001d78:	6605                	lui	a2,0x1
    80001d7a:	040005b7          	lui	a1,0x4000
    80001d7e:	15fd                	addi	a1,a1,-1
    80001d80:	05b2                	slli	a1,a1,0xc
    80001d82:	fffff097          	auipc	ra,0xfffff
    80001d86:	532080e7          	jalr	1330(ra) # 800012b4 <mappages>
    80001d8a:	02054863          	bltz	a0,80001dba <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d8e:	4719                	li	a4,6
    80001d90:	05893683          	ld	a3,88(s2)
    80001d94:	6605                	lui	a2,0x1
    80001d96:	020005b7          	lui	a1,0x2000
    80001d9a:	15fd                	addi	a1,a1,-1
    80001d9c:	05b6                	slli	a1,a1,0xd
    80001d9e:	8526                	mv	a0,s1
    80001da0:	fffff097          	auipc	ra,0xfffff
    80001da4:	514080e7          	jalr	1300(ra) # 800012b4 <mappages>
    80001da8:	02054163          	bltz	a0,80001dca <proc_pagetable+0x76>
}
    80001dac:	8526                	mv	a0,s1
    80001dae:	60e2                	ld	ra,24(sp)
    80001db0:	6442                	ld	s0,16(sp)
    80001db2:	64a2                	ld	s1,8(sp)
    80001db4:	6902                	ld	s2,0(sp)
    80001db6:	6105                	addi	sp,sp,32
    80001db8:	8082                	ret
    uvmfree(pagetable, 0);
    80001dba:	4581                	li	a1,0
    80001dbc:	8526                	mv	a0,s1
    80001dbe:	00000097          	auipc	ra,0x0
    80001dc2:	94e080e7          	jalr	-1714(ra) # 8000170c <uvmfree>
    return 0;
    80001dc6:	4481                	li	s1,0
    80001dc8:	b7d5                	j	80001dac <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dca:	4681                	li	a3,0
    80001dcc:	4605                	li	a2,1
    80001dce:	040005b7          	lui	a1,0x4000
    80001dd2:	15fd                	addi	a1,a1,-1
    80001dd4:	05b2                	slli	a1,a1,0xc
    80001dd6:	8526                	mv	a0,s1
    80001dd8:	fffff097          	auipc	ra,0xfffff
    80001ddc:	674080e7          	jalr	1652(ra) # 8000144c <uvmunmap>
    uvmfree(pagetable, 0);
    80001de0:	4581                	li	a1,0
    80001de2:	8526                	mv	a0,s1
    80001de4:	00000097          	auipc	ra,0x0
    80001de8:	928080e7          	jalr	-1752(ra) # 8000170c <uvmfree>
    return 0;
    80001dec:	4481                	li	s1,0
    80001dee:	bf7d                	j	80001dac <proc_pagetable+0x58>

0000000080001df0 <proc_freepagetable>:
{
    80001df0:	1101                	addi	sp,sp,-32
    80001df2:	ec06                	sd	ra,24(sp)
    80001df4:	e822                	sd	s0,16(sp)
    80001df6:	e426                	sd	s1,8(sp)
    80001df8:	e04a                	sd	s2,0(sp)
    80001dfa:	1000                	addi	s0,sp,32
    80001dfc:	84aa                	mv	s1,a0
    80001dfe:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e00:	4681                	li	a3,0
    80001e02:	4605                	li	a2,1
    80001e04:	040005b7          	lui	a1,0x4000
    80001e08:	15fd                	addi	a1,a1,-1
    80001e0a:	05b2                	slli	a1,a1,0xc
    80001e0c:	fffff097          	auipc	ra,0xfffff
    80001e10:	640080e7          	jalr	1600(ra) # 8000144c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e14:	4681                	li	a3,0
    80001e16:	4605                	li	a2,1
    80001e18:	020005b7          	lui	a1,0x2000
    80001e1c:	15fd                	addi	a1,a1,-1
    80001e1e:	05b6                	slli	a1,a1,0xd
    80001e20:	8526                	mv	a0,s1
    80001e22:	fffff097          	auipc	ra,0xfffff
    80001e26:	62a080e7          	jalr	1578(ra) # 8000144c <uvmunmap>
  uvmfree(pagetable, sz);
    80001e2a:	85ca                	mv	a1,s2
    80001e2c:	8526                	mv	a0,s1
    80001e2e:	00000097          	auipc	ra,0x0
    80001e32:	8de080e7          	jalr	-1826(ra) # 8000170c <uvmfree>
}
    80001e36:	60e2                	ld	ra,24(sp)
    80001e38:	6442                	ld	s0,16(sp)
    80001e3a:	64a2                	ld	s1,8(sp)
    80001e3c:	6902                	ld	s2,0(sp)
    80001e3e:	6105                	addi	sp,sp,32
    80001e40:	8082                	ret

0000000080001e42 <freeproc>:
{
    80001e42:	1101                	addi	sp,sp,-32
    80001e44:	ec06                	sd	ra,24(sp)
    80001e46:	e822                	sd	s0,16(sp)
    80001e48:	e426                	sd	s1,8(sp)
    80001e4a:	1000                	addi	s0,sp,32
    80001e4c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001e4e:	6d28                	ld	a0,88(a0)
    80001e50:	c509                	beqz	a0,80001e5a <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001e52:	fffff097          	auipc	ra,0xfffff
    80001e56:	c20080e7          	jalr	-992(ra) # 80000a72 <kfree>
  p->trapframe = 0;
    80001e5a:	0404bc23          	sd	zero,88(s1) # fffffffffffff058 <end+0xffffffff7fdb9058>
  if(p->pagetable)
    80001e5e:	68a8                	ld	a0,80(s1)
    80001e60:	c511                	beqz	a0,80001e6c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001e62:	64ac                	ld	a1,72(s1)
    80001e64:	00000097          	auipc	ra,0x0
    80001e68:	f8c080e7          	jalr	-116(ra) # 80001df0 <proc_freepagetable>
  p->pagetable = 0;
    80001e6c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001e70:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001e74:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001e78:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001e7c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001e80:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001e84:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001e88:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001e8c:	0004ac23          	sw	zero,24(s1)
}
    80001e90:	60e2                	ld	ra,24(sp)
    80001e92:	6442                	ld	s0,16(sp)
    80001e94:	64a2                	ld	s1,8(sp)
    80001e96:	6105                	addi	sp,sp,32
    80001e98:	8082                	ret

0000000080001e9a <allocproc>:
{
    80001e9a:	1101                	addi	sp,sp,-32
    80001e9c:	ec06                	sd	ra,24(sp)
    80001e9e:	e822                	sd	s0,16(sp)
    80001ea0:	e426                	sd	s1,8(sp)
    80001ea2:	e04a                	sd	s2,0(sp)
    80001ea4:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ea6:	00230497          	auipc	s1,0x230
    80001eaa:	ec248493          	addi	s1,s1,-318 # 80231d68 <proc>
    80001eae:	00236917          	auipc	s2,0x236
    80001eb2:	8ba90913          	addi	s2,s2,-1862 # 80237768 <tickslock>
    acquire(&p->lock);
    80001eb6:	8526                	mv	a0,s1
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	ea6080e7          	jalr	-346(ra) # 80000d5e <acquire>
    if(p->state == UNUSED) {
    80001ec0:	4c9c                	lw	a5,24(s1)
    80001ec2:	cf81                	beqz	a5,80001eda <allocproc+0x40>
      release(&p->lock);
    80001ec4:	8526                	mv	a0,s1
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	f4c080e7          	jalr	-180(ra) # 80000e12 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ece:	16848493          	addi	s1,s1,360
    80001ed2:	ff2492e3          	bne	s1,s2,80001eb6 <allocproc+0x1c>
  return 0;
    80001ed6:	4481                	li	s1,0
    80001ed8:	a0b9                	j	80001f26 <allocproc+0x8c>
  p->pid = allocpid();
    80001eda:	00000097          	auipc	ra,0x0
    80001ede:	e34080e7          	jalr	-460(ra) # 80001d0e <allocpid>
    80001ee2:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ee4:	fffff097          	auipc	ra,0xfffff
    80001ee8:	ce8080e7          	jalr	-792(ra) # 80000bcc <kalloc>
    80001eec:	892a                	mv	s2,a0
    80001eee:	eca8                	sd	a0,88(s1)
    80001ef0:	c131                	beqz	a0,80001f34 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001ef2:	8526                	mv	a0,s1
    80001ef4:	00000097          	auipc	ra,0x0
    80001ef8:	e60080e7          	jalr	-416(ra) # 80001d54 <proc_pagetable>
    80001efc:	892a                	mv	s2,a0
    80001efe:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001f00:	c129                	beqz	a0,80001f42 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001f02:	07000613          	li	a2,112
    80001f06:	4581                	li	a1,0
    80001f08:	06048513          	addi	a0,s1,96
    80001f0c:	fffff097          	auipc	ra,0xfffff
    80001f10:	f4e080e7          	jalr	-178(ra) # 80000e5a <memset>
  p->context.ra = (uint64)forkret;
    80001f14:	00000797          	auipc	a5,0x0
    80001f18:	db278793          	addi	a5,a5,-590 # 80001cc6 <forkret>
    80001f1c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001f1e:	60bc                	ld	a5,64(s1)
    80001f20:	6705                	lui	a4,0x1
    80001f22:	97ba                	add	a5,a5,a4
    80001f24:	f4bc                	sd	a5,104(s1)
}
    80001f26:	8526                	mv	a0,s1
    80001f28:	60e2                	ld	ra,24(sp)
    80001f2a:	6442                	ld	s0,16(sp)
    80001f2c:	64a2                	ld	s1,8(sp)
    80001f2e:	6902                	ld	s2,0(sp)
    80001f30:	6105                	addi	sp,sp,32
    80001f32:	8082                	ret
    release(&p->lock);
    80001f34:	8526                	mv	a0,s1
    80001f36:	fffff097          	auipc	ra,0xfffff
    80001f3a:	edc080e7          	jalr	-292(ra) # 80000e12 <release>
    return 0;
    80001f3e:	84ca                	mv	s1,s2
    80001f40:	b7dd                	j	80001f26 <allocproc+0x8c>
    freeproc(p);
    80001f42:	8526                	mv	a0,s1
    80001f44:	00000097          	auipc	ra,0x0
    80001f48:	efe080e7          	jalr	-258(ra) # 80001e42 <freeproc>
    release(&p->lock);
    80001f4c:	8526                	mv	a0,s1
    80001f4e:	fffff097          	auipc	ra,0xfffff
    80001f52:	ec4080e7          	jalr	-316(ra) # 80000e12 <release>
    return 0;
    80001f56:	84ca                	mv	s1,s2
    80001f58:	b7f9                	j	80001f26 <allocproc+0x8c>

0000000080001f5a <userinit>:
{
    80001f5a:	1101                	addi	sp,sp,-32
    80001f5c:	ec06                	sd	ra,24(sp)
    80001f5e:	e822                	sd	s0,16(sp)
    80001f60:	e426                	sd	s1,8(sp)
    80001f62:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f64:	00000097          	auipc	ra,0x0
    80001f68:	f36080e7          	jalr	-202(ra) # 80001e9a <allocproc>
    80001f6c:	84aa                	mv	s1,a0
  initproc = p;
    80001f6e:	00007797          	auipc	a5,0x7
    80001f72:	0aa7b523          	sd	a0,170(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001f76:	03400613          	li	a2,52
    80001f7a:	00007597          	auipc	a1,0x7
    80001f7e:	99658593          	addi	a1,a1,-1642 # 80008910 <initcode>
    80001f82:	6928                	ld	a0,80(a0)
    80001f84:	fffff097          	auipc	ra,0xfffff
    80001f88:	5bc080e7          	jalr	1468(ra) # 80001540 <uvminit>
  p->sz = PGSIZE;
    80001f8c:	6785                	lui	a5,0x1
    80001f8e:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001f90:	6cb8                	ld	a4,88(s1)
    80001f92:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001f96:	6cb8                	ld	a4,88(s1)
    80001f98:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f9a:	4641                	li	a2,16
    80001f9c:	00006597          	auipc	a1,0x6
    80001fa0:	35c58593          	addi	a1,a1,860 # 800082f8 <states.1732+0x48>
    80001fa4:	15848513          	addi	a0,s1,344
    80001fa8:	fffff097          	auipc	ra,0xfffff
    80001fac:	02a080e7          	jalr	42(ra) # 80000fd2 <safestrcpy>
  p->cwd = namei("/");
    80001fb0:	00006517          	auipc	a0,0x6
    80001fb4:	35850513          	addi	a0,a0,856 # 80008308 <states.1732+0x58>
    80001fb8:	00002097          	auipc	ra,0x2
    80001fbc:	148080e7          	jalr	328(ra) # 80004100 <namei>
    80001fc0:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001fc4:	4789                	li	a5,2
    80001fc6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001fc8:	8526                	mv	a0,s1
    80001fca:	fffff097          	auipc	ra,0xfffff
    80001fce:	e48080e7          	jalr	-440(ra) # 80000e12 <release>
}
    80001fd2:	60e2                	ld	ra,24(sp)
    80001fd4:	6442                	ld	s0,16(sp)
    80001fd6:	64a2                	ld	s1,8(sp)
    80001fd8:	6105                	addi	sp,sp,32
    80001fda:	8082                	ret

0000000080001fdc <growproc>:
{
    80001fdc:	1101                	addi	sp,sp,-32
    80001fde:	ec06                	sd	ra,24(sp)
    80001fe0:	e822                	sd	s0,16(sp)
    80001fe2:	e426                	sd	s1,8(sp)
    80001fe4:	e04a                	sd	s2,0(sp)
    80001fe6:	1000                	addi	s0,sp,32
    80001fe8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fea:	00000097          	auipc	ra,0x0
    80001fee:	ca4080e7          	jalr	-860(ra) # 80001c8e <myproc>
    80001ff2:	892a                	mv	s2,a0
  sz = p->sz;
    80001ff4:	652c                	ld	a1,72(a0)
    80001ff6:	0005851b          	sext.w	a0,a1
  if(n > 0){
    80001ffa:	00904f63          	bgtz	s1,80002018 <growproc+0x3c>
  } else if(n < 0){
    80001ffe:	0204cd63          	bltz	s1,80002038 <growproc+0x5c>
  p->sz = sz;
    80002002:	1502                	slli	a0,a0,0x20
    80002004:	9101                	srli	a0,a0,0x20
    80002006:	04a93423          	sd	a0,72(s2)
  return 0;
    8000200a:	4501                	li	a0,0
}
    8000200c:	60e2                	ld	ra,24(sp)
    8000200e:	6442                	ld	s0,16(sp)
    80002010:	64a2                	ld	s1,8(sp)
    80002012:	6902                	ld	s2,0(sp)
    80002014:	6105                	addi	sp,sp,32
    80002016:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80002018:	00a4863b          	addw	a2,s1,a0
    8000201c:	1602                	slli	a2,a2,0x20
    8000201e:	9201                	srli	a2,a2,0x20
    80002020:	1582                	slli	a1,a1,0x20
    80002022:	9181                	srli	a1,a1,0x20
    80002024:	05093503          	ld	a0,80(s2)
    80002028:	fffff097          	auipc	ra,0xfffff
    8000202c:	5d0080e7          	jalr	1488(ra) # 800015f8 <uvmalloc>
    80002030:	2501                	sext.w	a0,a0
    80002032:	f961                	bnez	a0,80002002 <growproc+0x26>
      return -1;
    80002034:	557d                	li	a0,-1
    80002036:	bfd9                	j	8000200c <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002038:	00a4863b          	addw	a2,s1,a0
    8000203c:	1602                	slli	a2,a2,0x20
    8000203e:	9201                	srli	a2,a2,0x20
    80002040:	1582                	slli	a1,a1,0x20
    80002042:	9181                	srli	a1,a1,0x20
    80002044:	05093503          	ld	a0,80(s2)
    80002048:	fffff097          	auipc	ra,0xfffff
    8000204c:	56a080e7          	jalr	1386(ra) # 800015b2 <uvmdealloc>
    80002050:	2501                	sext.w	a0,a0
    80002052:	bf45                	j	80002002 <growproc+0x26>

0000000080002054 <fork>:
{
    80002054:	7179                	addi	sp,sp,-48
    80002056:	f406                	sd	ra,40(sp)
    80002058:	f022                	sd	s0,32(sp)
    8000205a:	ec26                	sd	s1,24(sp)
    8000205c:	e84a                	sd	s2,16(sp)
    8000205e:	e44e                	sd	s3,8(sp)
    80002060:	e052                	sd	s4,0(sp)
    80002062:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002064:	00000097          	auipc	ra,0x0
    80002068:	c2a080e7          	jalr	-982(ra) # 80001c8e <myproc>
    8000206c:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    8000206e:	00000097          	auipc	ra,0x0
    80002072:	e2c080e7          	jalr	-468(ra) # 80001e9a <allocproc>
    80002076:	c175                	beqz	a0,8000215a <fork+0x106>
    80002078:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000207a:	04893603          	ld	a2,72(s2)
    8000207e:	692c                	ld	a1,80(a0)
    80002080:	05093503          	ld	a0,80(s2)
    80002084:	fffff097          	auipc	ra,0xfffff
    80002088:	6c0080e7          	jalr	1728(ra) # 80001744 <uvmcopy>
    8000208c:	04054863          	bltz	a0,800020dc <fork+0x88>
  np->sz = p->sz;
    80002090:	04893783          	ld	a5,72(s2)
    80002094:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80002098:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    8000209c:	05893683          	ld	a3,88(s2)
    800020a0:	87b6                	mv	a5,a3
    800020a2:	0589b703          	ld	a4,88(s3)
    800020a6:	12068693          	addi	a3,a3,288
    800020aa:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800020ae:	6788                	ld	a0,8(a5)
    800020b0:	6b8c                	ld	a1,16(a5)
    800020b2:	6f90                	ld	a2,24(a5)
    800020b4:	01073023          	sd	a6,0(a4)
    800020b8:	e708                	sd	a0,8(a4)
    800020ba:	eb0c                	sd	a1,16(a4)
    800020bc:	ef10                	sd	a2,24(a4)
    800020be:	02078793          	addi	a5,a5,32
    800020c2:	02070713          	addi	a4,a4,32
    800020c6:	fed792e3          	bne	a5,a3,800020aa <fork+0x56>
  np->trapframe->a0 = 0;
    800020ca:	0589b783          	ld	a5,88(s3)
    800020ce:	0607b823          	sd	zero,112(a5)
    800020d2:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    800020d6:	15000a13          	li	s4,336
    800020da:	a03d                	j	80002108 <fork+0xb4>
    freeproc(np);
    800020dc:	854e                	mv	a0,s3
    800020de:	00000097          	auipc	ra,0x0
    800020e2:	d64080e7          	jalr	-668(ra) # 80001e42 <freeproc>
    release(&np->lock);
    800020e6:	854e                	mv	a0,s3
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	d2a080e7          	jalr	-726(ra) # 80000e12 <release>
    return -1;
    800020f0:	54fd                	li	s1,-1
    800020f2:	a899                	j	80002148 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    800020f4:	00002097          	auipc	ra,0x2
    800020f8:	6ca080e7          	jalr	1738(ra) # 800047be <filedup>
    800020fc:	009987b3          	add	a5,s3,s1
    80002100:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80002102:	04a1                	addi	s1,s1,8
    80002104:	01448763          	beq	s1,s4,80002112 <fork+0xbe>
    if(p->ofile[i])
    80002108:	009907b3          	add	a5,s2,s1
    8000210c:	6388                	ld	a0,0(a5)
    8000210e:	f17d                	bnez	a0,800020f4 <fork+0xa0>
    80002110:	bfcd                	j	80002102 <fork+0xae>
  np->cwd = idup(p->cwd);
    80002112:	15093503          	ld	a0,336(s2)
    80002116:	00001097          	auipc	ra,0x1
    8000211a:	7ee080e7          	jalr	2030(ra) # 80003904 <idup>
    8000211e:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002122:	4641                	li	a2,16
    80002124:	15890593          	addi	a1,s2,344
    80002128:	15898513          	addi	a0,s3,344
    8000212c:	fffff097          	auipc	ra,0xfffff
    80002130:	ea6080e7          	jalr	-346(ra) # 80000fd2 <safestrcpy>
  pid = np->pid;
    80002134:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80002138:	4789                	li	a5,2
    8000213a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000213e:	854e                	mv	a0,s3
    80002140:	fffff097          	auipc	ra,0xfffff
    80002144:	cd2080e7          	jalr	-814(ra) # 80000e12 <release>
}
    80002148:	8526                	mv	a0,s1
    8000214a:	70a2                	ld	ra,40(sp)
    8000214c:	7402                	ld	s0,32(sp)
    8000214e:	64e2                	ld	s1,24(sp)
    80002150:	6942                	ld	s2,16(sp)
    80002152:	69a2                	ld	s3,8(sp)
    80002154:	6a02                	ld	s4,0(sp)
    80002156:	6145                	addi	sp,sp,48
    80002158:	8082                	ret
    return -1;
    8000215a:	54fd                	li	s1,-1
    8000215c:	b7f5                	j	80002148 <fork+0xf4>

000000008000215e <reparent>:
{
    8000215e:	7179                	addi	sp,sp,-48
    80002160:	f406                	sd	ra,40(sp)
    80002162:	f022                	sd	s0,32(sp)
    80002164:	ec26                	sd	s1,24(sp)
    80002166:	e84a                	sd	s2,16(sp)
    80002168:	e44e                	sd	s3,8(sp)
    8000216a:	e052                	sd	s4,0(sp)
    8000216c:	1800                	addi	s0,sp,48
    8000216e:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002170:	00230497          	auipc	s1,0x230
    80002174:	bf848493          	addi	s1,s1,-1032 # 80231d68 <proc>
      pp->parent = initproc;
    80002178:	00007a17          	auipc	s4,0x7
    8000217c:	ea0a0a13          	addi	s4,s4,-352 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002180:	00235917          	auipc	s2,0x235
    80002184:	5e890913          	addi	s2,s2,1512 # 80237768 <tickslock>
    80002188:	a029                	j	80002192 <reparent+0x34>
    8000218a:	16848493          	addi	s1,s1,360
    8000218e:	03248363          	beq	s1,s2,800021b4 <reparent+0x56>
    if(pp->parent == p){
    80002192:	709c                	ld	a5,32(s1)
    80002194:	ff379be3          	bne	a5,s3,8000218a <reparent+0x2c>
      acquire(&pp->lock);
    80002198:	8526                	mv	a0,s1
    8000219a:	fffff097          	auipc	ra,0xfffff
    8000219e:	bc4080e7          	jalr	-1084(ra) # 80000d5e <acquire>
      pp->parent = initproc;
    800021a2:	000a3783          	ld	a5,0(s4)
    800021a6:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    800021a8:	8526                	mv	a0,s1
    800021aa:	fffff097          	auipc	ra,0xfffff
    800021ae:	c68080e7          	jalr	-920(ra) # 80000e12 <release>
    800021b2:	bfe1                	j	8000218a <reparent+0x2c>
}
    800021b4:	70a2                	ld	ra,40(sp)
    800021b6:	7402                	ld	s0,32(sp)
    800021b8:	64e2                	ld	s1,24(sp)
    800021ba:	6942                	ld	s2,16(sp)
    800021bc:	69a2                	ld	s3,8(sp)
    800021be:	6a02                	ld	s4,0(sp)
    800021c0:	6145                	addi	sp,sp,48
    800021c2:	8082                	ret

00000000800021c4 <scheduler>:
{
    800021c4:	711d                	addi	sp,sp,-96
    800021c6:	ec86                	sd	ra,88(sp)
    800021c8:	e8a2                	sd	s0,80(sp)
    800021ca:	e4a6                	sd	s1,72(sp)
    800021cc:	e0ca                	sd	s2,64(sp)
    800021ce:	fc4e                	sd	s3,56(sp)
    800021d0:	f852                	sd	s4,48(sp)
    800021d2:	f456                	sd	s5,40(sp)
    800021d4:	f05a                	sd	s6,32(sp)
    800021d6:	ec5e                	sd	s7,24(sp)
    800021d8:	e862                	sd	s8,16(sp)
    800021da:	e466                	sd	s9,8(sp)
    800021dc:	1080                	addi	s0,sp,96
    800021de:	8792                	mv	a5,tp
  int id = r_tp();
    800021e0:	2781                	sext.w	a5,a5
  c->proc = 0;
    800021e2:	00779c13          	slli	s8,a5,0x7
    800021e6:	0022f717          	auipc	a4,0x22f
    800021ea:	76a70713          	addi	a4,a4,1898 # 80231950 <pid_lock>
    800021ee:	9762                	add	a4,a4,s8
    800021f0:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    800021f4:	0022f717          	auipc	a4,0x22f
    800021f8:	77c70713          	addi	a4,a4,1916 # 80231970 <cpus+0x8>
    800021fc:	9c3a                	add	s8,s8,a4
      if(p->state == RUNNABLE) {
    800021fe:	4a89                	li	s5,2
        c->proc = p;
    80002200:	079e                	slli	a5,a5,0x7
    80002202:	0022fb17          	auipc	s6,0x22f
    80002206:	74eb0b13          	addi	s6,s6,1870 # 80231950 <pid_lock>
    8000220a:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000220c:	00235a17          	auipc	s4,0x235
    80002210:	55ca0a13          	addi	s4,s4,1372 # 80237768 <tickslock>
    int nproc = 0;
    80002214:	4c81                	li	s9,0
    80002216:	a8a1                	j	8000226e <scheduler+0xaa>
        p->state = RUNNING;
    80002218:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    8000221c:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    80002220:	06048593          	addi	a1,s1,96
    80002224:	8562                	mv	a0,s8
    80002226:	00000097          	auipc	ra,0x0
    8000222a:	640080e7          	jalr	1600(ra) # 80002866 <swtch>
        c->proc = 0;
    8000222e:	000b3c23          	sd	zero,24(s6)
      release(&p->lock);
    80002232:	8526                	mv	a0,s1
    80002234:	fffff097          	auipc	ra,0xfffff
    80002238:	bde080e7          	jalr	-1058(ra) # 80000e12 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000223c:	16848493          	addi	s1,s1,360
    80002240:	01448d63          	beq	s1,s4,8000225a <scheduler+0x96>
      acquire(&p->lock);
    80002244:	8526                	mv	a0,s1
    80002246:	fffff097          	auipc	ra,0xfffff
    8000224a:	b18080e7          	jalr	-1256(ra) # 80000d5e <acquire>
      if(p->state != UNUSED) {
    8000224e:	4c9c                	lw	a5,24(s1)
    80002250:	d3ed                	beqz	a5,80002232 <scheduler+0x6e>
        nproc++;
    80002252:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    80002254:	fd579fe3          	bne	a5,s5,80002232 <scheduler+0x6e>
    80002258:	b7c1                	j	80002218 <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    8000225a:	013aca63          	blt	s5,s3,8000226e <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000225e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002262:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002266:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000226a:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000226e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002272:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002276:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    8000227a:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    8000227c:	00230497          	auipc	s1,0x230
    80002280:	aec48493          	addi	s1,s1,-1300 # 80231d68 <proc>
        p->state = RUNNING;
    80002284:	4b8d                	li	s7,3
    80002286:	bf7d                	j	80002244 <scheduler+0x80>

0000000080002288 <sched>:
{
    80002288:	7179                	addi	sp,sp,-48
    8000228a:	f406                	sd	ra,40(sp)
    8000228c:	f022                	sd	s0,32(sp)
    8000228e:	ec26                	sd	s1,24(sp)
    80002290:	e84a                	sd	s2,16(sp)
    80002292:	e44e                	sd	s3,8(sp)
    80002294:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002296:	00000097          	auipc	ra,0x0
    8000229a:	9f8080e7          	jalr	-1544(ra) # 80001c8e <myproc>
    8000229e:	892a                	mv	s2,a0
  if(!holding(&p->lock))
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	a44080e7          	jalr	-1468(ra) # 80000ce4 <holding>
    800022a8:	cd25                	beqz	a0,80002320 <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022aa:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800022ac:	2781                	sext.w	a5,a5
    800022ae:	079e                	slli	a5,a5,0x7
    800022b0:	0022f717          	auipc	a4,0x22f
    800022b4:	6a070713          	addi	a4,a4,1696 # 80231950 <pid_lock>
    800022b8:	97ba                	add	a5,a5,a4
    800022ba:	0907a703          	lw	a4,144(a5)
    800022be:	4785                	li	a5,1
    800022c0:	06f71863          	bne	a4,a5,80002330 <sched+0xa8>
  if(p->state == RUNNING)
    800022c4:	01892703          	lw	a4,24(s2)
    800022c8:	478d                	li	a5,3
    800022ca:	06f70b63          	beq	a4,a5,80002340 <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022ce:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800022d2:	8b89                	andi	a5,a5,2
  if(intr_get())
    800022d4:	efb5                	bnez	a5,80002350 <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022d6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800022d8:	0022f497          	auipc	s1,0x22f
    800022dc:	67848493          	addi	s1,s1,1656 # 80231950 <pid_lock>
    800022e0:	2781                	sext.w	a5,a5
    800022e2:	079e                	slli	a5,a5,0x7
    800022e4:	97a6                	add	a5,a5,s1
    800022e6:	0947a983          	lw	s3,148(a5)
    800022ea:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800022ec:	2781                	sext.w	a5,a5
    800022ee:	079e                	slli	a5,a5,0x7
    800022f0:	0022f597          	auipc	a1,0x22f
    800022f4:	68058593          	addi	a1,a1,1664 # 80231970 <cpus+0x8>
    800022f8:	95be                	add	a1,a1,a5
    800022fa:	06090513          	addi	a0,s2,96
    800022fe:	00000097          	auipc	ra,0x0
    80002302:	568080e7          	jalr	1384(ra) # 80002866 <swtch>
    80002306:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002308:	2781                	sext.w	a5,a5
    8000230a:	079e                	slli	a5,a5,0x7
    8000230c:	97a6                	add	a5,a5,s1
    8000230e:	0937aa23          	sw	s3,148(a5)
}
    80002312:	70a2                	ld	ra,40(sp)
    80002314:	7402                	ld	s0,32(sp)
    80002316:	64e2                	ld	s1,24(sp)
    80002318:	6942                	ld	s2,16(sp)
    8000231a:	69a2                	ld	s3,8(sp)
    8000231c:	6145                	addi	sp,sp,48
    8000231e:	8082                	ret
    panic("sched p->lock");
    80002320:	00006517          	auipc	a0,0x6
    80002324:	ff050513          	addi	a0,a0,-16 # 80008310 <states.1732+0x60>
    80002328:	ffffe097          	auipc	ra,0xffffe
    8000232c:	24c080e7          	jalr	588(ra) # 80000574 <panic>
    panic("sched locks");
    80002330:	00006517          	auipc	a0,0x6
    80002334:	ff050513          	addi	a0,a0,-16 # 80008320 <states.1732+0x70>
    80002338:	ffffe097          	auipc	ra,0xffffe
    8000233c:	23c080e7          	jalr	572(ra) # 80000574 <panic>
    panic("sched running");
    80002340:	00006517          	auipc	a0,0x6
    80002344:	ff050513          	addi	a0,a0,-16 # 80008330 <states.1732+0x80>
    80002348:	ffffe097          	auipc	ra,0xffffe
    8000234c:	22c080e7          	jalr	556(ra) # 80000574 <panic>
    panic("sched interruptible");
    80002350:	00006517          	auipc	a0,0x6
    80002354:	ff050513          	addi	a0,a0,-16 # 80008340 <states.1732+0x90>
    80002358:	ffffe097          	auipc	ra,0xffffe
    8000235c:	21c080e7          	jalr	540(ra) # 80000574 <panic>

0000000080002360 <exit>:
{
    80002360:	7179                	addi	sp,sp,-48
    80002362:	f406                	sd	ra,40(sp)
    80002364:	f022                	sd	s0,32(sp)
    80002366:	ec26                	sd	s1,24(sp)
    80002368:	e84a                	sd	s2,16(sp)
    8000236a:	e44e                	sd	s3,8(sp)
    8000236c:	e052                	sd	s4,0(sp)
    8000236e:	1800                	addi	s0,sp,48
    80002370:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002372:	00000097          	auipc	ra,0x0
    80002376:	91c080e7          	jalr	-1764(ra) # 80001c8e <myproc>
    8000237a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000237c:	00007797          	auipc	a5,0x7
    80002380:	c9c78793          	addi	a5,a5,-868 # 80009018 <initproc>
    80002384:	639c                	ld	a5,0(a5)
    80002386:	0d050493          	addi	s1,a0,208
    8000238a:	15050913          	addi	s2,a0,336
    8000238e:	02a79363          	bne	a5,a0,800023b4 <exit+0x54>
    panic("init exiting");
    80002392:	00006517          	auipc	a0,0x6
    80002396:	fc650513          	addi	a0,a0,-58 # 80008358 <states.1732+0xa8>
    8000239a:	ffffe097          	auipc	ra,0xffffe
    8000239e:	1da080e7          	jalr	474(ra) # 80000574 <panic>
      fileclose(f);
    800023a2:	00002097          	auipc	ra,0x2
    800023a6:	46e080e7          	jalr	1134(ra) # 80004810 <fileclose>
      p->ofile[fd] = 0;
    800023aa:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800023ae:	04a1                	addi	s1,s1,8
    800023b0:	01248563          	beq	s1,s2,800023ba <exit+0x5a>
    if(p->ofile[fd]){
    800023b4:	6088                	ld	a0,0(s1)
    800023b6:	f575                	bnez	a0,800023a2 <exit+0x42>
    800023b8:	bfdd                	j	800023ae <exit+0x4e>
  begin_op();
    800023ba:	00002097          	auipc	ra,0x2
    800023be:	f54080e7          	jalr	-172(ra) # 8000430e <begin_op>
  iput(p->cwd);
    800023c2:	1509b503          	ld	a0,336(s3)
    800023c6:	00001097          	auipc	ra,0x1
    800023ca:	738080e7          	jalr	1848(ra) # 80003afe <iput>
  end_op();
    800023ce:	00002097          	auipc	ra,0x2
    800023d2:	fc0080e7          	jalr	-64(ra) # 8000438e <end_op>
  p->cwd = 0;
    800023d6:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    800023da:	00007497          	auipc	s1,0x7
    800023de:	c3e48493          	addi	s1,s1,-962 # 80009018 <initproc>
    800023e2:	6088                	ld	a0,0(s1)
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	97a080e7          	jalr	-1670(ra) # 80000d5e <acquire>
  wakeup1(initproc);
    800023ec:	6088                	ld	a0,0(s1)
    800023ee:	fffff097          	auipc	ra,0xfffff
    800023f2:	760080e7          	jalr	1888(ra) # 80001b4e <wakeup1>
  release(&initproc->lock);
    800023f6:	6088                	ld	a0,0(s1)
    800023f8:	fffff097          	auipc	ra,0xfffff
    800023fc:	a1a080e7          	jalr	-1510(ra) # 80000e12 <release>
  acquire(&p->lock);
    80002400:	854e                	mv	a0,s3
    80002402:	fffff097          	auipc	ra,0xfffff
    80002406:	95c080e7          	jalr	-1700(ra) # 80000d5e <acquire>
  struct proc *original_parent = p->parent;
    8000240a:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    8000240e:	854e                	mv	a0,s3
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	a02080e7          	jalr	-1534(ra) # 80000e12 <release>
  acquire(&original_parent->lock);
    80002418:	8526                	mv	a0,s1
    8000241a:	fffff097          	auipc	ra,0xfffff
    8000241e:	944080e7          	jalr	-1724(ra) # 80000d5e <acquire>
  acquire(&p->lock);
    80002422:	854e                	mv	a0,s3
    80002424:	fffff097          	auipc	ra,0xfffff
    80002428:	93a080e7          	jalr	-1734(ra) # 80000d5e <acquire>
  reparent(p);
    8000242c:	854e                	mv	a0,s3
    8000242e:	00000097          	auipc	ra,0x0
    80002432:	d30080e7          	jalr	-720(ra) # 8000215e <reparent>
  wakeup1(original_parent);
    80002436:	8526                	mv	a0,s1
    80002438:	fffff097          	auipc	ra,0xfffff
    8000243c:	716080e7          	jalr	1814(ra) # 80001b4e <wakeup1>
  p->xstate = status;
    80002440:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80002444:	4791                	li	a5,4
    80002446:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    8000244a:	8526                	mv	a0,s1
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	9c6080e7          	jalr	-1594(ra) # 80000e12 <release>
  sched();
    80002454:	00000097          	auipc	ra,0x0
    80002458:	e34080e7          	jalr	-460(ra) # 80002288 <sched>
  panic("zombie exit");
    8000245c:	00006517          	auipc	a0,0x6
    80002460:	f0c50513          	addi	a0,a0,-244 # 80008368 <states.1732+0xb8>
    80002464:	ffffe097          	auipc	ra,0xffffe
    80002468:	110080e7          	jalr	272(ra) # 80000574 <panic>

000000008000246c <yield>:
{
    8000246c:	1101                	addi	sp,sp,-32
    8000246e:	ec06                	sd	ra,24(sp)
    80002470:	e822                	sd	s0,16(sp)
    80002472:	e426                	sd	s1,8(sp)
    80002474:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002476:	00000097          	auipc	ra,0x0
    8000247a:	818080e7          	jalr	-2024(ra) # 80001c8e <myproc>
    8000247e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002480:	fffff097          	auipc	ra,0xfffff
    80002484:	8de080e7          	jalr	-1826(ra) # 80000d5e <acquire>
  p->state = RUNNABLE;
    80002488:	4789                	li	a5,2
    8000248a:	cc9c                	sw	a5,24(s1)
  sched();
    8000248c:	00000097          	auipc	ra,0x0
    80002490:	dfc080e7          	jalr	-516(ra) # 80002288 <sched>
  release(&p->lock);
    80002494:	8526                	mv	a0,s1
    80002496:	fffff097          	auipc	ra,0xfffff
    8000249a:	97c080e7          	jalr	-1668(ra) # 80000e12 <release>
}
    8000249e:	60e2                	ld	ra,24(sp)
    800024a0:	6442                	ld	s0,16(sp)
    800024a2:	64a2                	ld	s1,8(sp)
    800024a4:	6105                	addi	sp,sp,32
    800024a6:	8082                	ret

00000000800024a8 <sleep>:
{
    800024a8:	7179                	addi	sp,sp,-48
    800024aa:	f406                	sd	ra,40(sp)
    800024ac:	f022                	sd	s0,32(sp)
    800024ae:	ec26                	sd	s1,24(sp)
    800024b0:	e84a                	sd	s2,16(sp)
    800024b2:	e44e                	sd	s3,8(sp)
    800024b4:	1800                	addi	s0,sp,48
    800024b6:	89aa                	mv	s3,a0
    800024b8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800024ba:	fffff097          	auipc	ra,0xfffff
    800024be:	7d4080e7          	jalr	2004(ra) # 80001c8e <myproc>
    800024c2:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800024c4:	05250663          	beq	a0,s2,80002510 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800024c8:	fffff097          	auipc	ra,0xfffff
    800024cc:	896080e7          	jalr	-1898(ra) # 80000d5e <acquire>
    release(lk);
    800024d0:	854a                	mv	a0,s2
    800024d2:	fffff097          	auipc	ra,0xfffff
    800024d6:	940080e7          	jalr	-1728(ra) # 80000e12 <release>
  p->chan = chan;
    800024da:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    800024de:	4785                	li	a5,1
    800024e0:	cc9c                	sw	a5,24(s1)
  sched();
    800024e2:	00000097          	auipc	ra,0x0
    800024e6:	da6080e7          	jalr	-602(ra) # 80002288 <sched>
  p->chan = 0;
    800024ea:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800024ee:	8526                	mv	a0,s1
    800024f0:	fffff097          	auipc	ra,0xfffff
    800024f4:	922080e7          	jalr	-1758(ra) # 80000e12 <release>
    acquire(lk);
    800024f8:	854a                	mv	a0,s2
    800024fa:	fffff097          	auipc	ra,0xfffff
    800024fe:	864080e7          	jalr	-1948(ra) # 80000d5e <acquire>
}
    80002502:	70a2                	ld	ra,40(sp)
    80002504:	7402                	ld	s0,32(sp)
    80002506:	64e2                	ld	s1,24(sp)
    80002508:	6942                	ld	s2,16(sp)
    8000250a:	69a2                	ld	s3,8(sp)
    8000250c:	6145                	addi	sp,sp,48
    8000250e:	8082                	ret
  p->chan = chan;
    80002510:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002514:	4785                	li	a5,1
    80002516:	cd1c                	sw	a5,24(a0)
  sched();
    80002518:	00000097          	auipc	ra,0x0
    8000251c:	d70080e7          	jalr	-656(ra) # 80002288 <sched>
  p->chan = 0;
    80002520:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002524:	bff9                	j	80002502 <sleep+0x5a>

0000000080002526 <wait>:
{
    80002526:	715d                	addi	sp,sp,-80
    80002528:	e486                	sd	ra,72(sp)
    8000252a:	e0a2                	sd	s0,64(sp)
    8000252c:	fc26                	sd	s1,56(sp)
    8000252e:	f84a                	sd	s2,48(sp)
    80002530:	f44e                	sd	s3,40(sp)
    80002532:	f052                	sd	s4,32(sp)
    80002534:	ec56                	sd	s5,24(sp)
    80002536:	e85a                	sd	s6,16(sp)
    80002538:	e45e                	sd	s7,8(sp)
    8000253a:	e062                	sd	s8,0(sp)
    8000253c:	0880                	addi	s0,sp,80
    8000253e:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002540:	fffff097          	auipc	ra,0xfffff
    80002544:	74e080e7          	jalr	1870(ra) # 80001c8e <myproc>
    80002548:	892a                	mv	s2,a0
  acquire(&p->lock);
    8000254a:	8c2a                	mv	s8,a0
    8000254c:	fffff097          	auipc	ra,0xfffff
    80002550:	812080e7          	jalr	-2030(ra) # 80000d5e <acquire>
    havekids = 0;
    80002554:	4b01                	li	s6,0
        if(np->state == ZOMBIE){
    80002556:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    80002558:	00235997          	auipc	s3,0x235
    8000255c:	21098993          	addi	s3,s3,528 # 80237768 <tickslock>
        havekids = 1;
    80002560:	4a85                	li	s5,1
    havekids = 0;
    80002562:	875a                	mv	a4,s6
    for(np = proc; np < &proc[NPROC]; np++){
    80002564:	00230497          	auipc	s1,0x230
    80002568:	80448493          	addi	s1,s1,-2044 # 80231d68 <proc>
    8000256c:	a08d                	j	800025ce <wait+0xa8>
          pid = np->pid;
    8000256e:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002572:	000b8e63          	beqz	s7,8000258e <wait+0x68>
    80002576:	4691                	li	a3,4
    80002578:	03448613          	addi	a2,s1,52
    8000257c:	85de                	mv	a1,s7
    8000257e:	05093503          	ld	a0,80(s2)
    80002582:	fffff097          	auipc	ra,0xfffff
    80002586:	4d0080e7          	jalr	1232(ra) # 80001a52 <copyout>
    8000258a:	02054263          	bltz	a0,800025ae <wait+0x88>
          freeproc(np);
    8000258e:	8526                	mv	a0,s1
    80002590:	00000097          	auipc	ra,0x0
    80002594:	8b2080e7          	jalr	-1870(ra) # 80001e42 <freeproc>
          release(&np->lock);
    80002598:	8526                	mv	a0,s1
    8000259a:	fffff097          	auipc	ra,0xfffff
    8000259e:	878080e7          	jalr	-1928(ra) # 80000e12 <release>
          release(&p->lock);
    800025a2:	854a                	mv	a0,s2
    800025a4:	fffff097          	auipc	ra,0xfffff
    800025a8:	86e080e7          	jalr	-1938(ra) # 80000e12 <release>
          return pid;
    800025ac:	a8a9                	j	80002606 <wait+0xe0>
            release(&np->lock);
    800025ae:	8526                	mv	a0,s1
    800025b0:	fffff097          	auipc	ra,0xfffff
    800025b4:	862080e7          	jalr	-1950(ra) # 80000e12 <release>
            release(&p->lock);
    800025b8:	854a                	mv	a0,s2
    800025ba:	fffff097          	auipc	ra,0xfffff
    800025be:	858080e7          	jalr	-1960(ra) # 80000e12 <release>
            return -1;
    800025c2:	59fd                	li	s3,-1
    800025c4:	a089                	j	80002606 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    800025c6:	16848493          	addi	s1,s1,360
    800025ca:	03348463          	beq	s1,s3,800025f2 <wait+0xcc>
      if(np->parent == p){
    800025ce:	709c                	ld	a5,32(s1)
    800025d0:	ff279be3          	bne	a5,s2,800025c6 <wait+0xa0>
        acquire(&np->lock);
    800025d4:	8526                	mv	a0,s1
    800025d6:	ffffe097          	auipc	ra,0xffffe
    800025da:	788080e7          	jalr	1928(ra) # 80000d5e <acquire>
        if(np->state == ZOMBIE){
    800025de:	4c9c                	lw	a5,24(s1)
    800025e0:	f94787e3          	beq	a5,s4,8000256e <wait+0x48>
        release(&np->lock);
    800025e4:	8526                	mv	a0,s1
    800025e6:	fffff097          	auipc	ra,0xfffff
    800025ea:	82c080e7          	jalr	-2004(ra) # 80000e12 <release>
        havekids = 1;
    800025ee:	8756                	mv	a4,s5
    800025f0:	bfd9                	j	800025c6 <wait+0xa0>
    if(!havekids || p->killed){
    800025f2:	c701                	beqz	a4,800025fa <wait+0xd4>
    800025f4:	03092783          	lw	a5,48(s2)
    800025f8:	c785                	beqz	a5,80002620 <wait+0xfa>
      release(&p->lock);
    800025fa:	854a                	mv	a0,s2
    800025fc:	fffff097          	auipc	ra,0xfffff
    80002600:	816080e7          	jalr	-2026(ra) # 80000e12 <release>
      return -1;
    80002604:	59fd                	li	s3,-1
}
    80002606:	854e                	mv	a0,s3
    80002608:	60a6                	ld	ra,72(sp)
    8000260a:	6406                	ld	s0,64(sp)
    8000260c:	74e2                	ld	s1,56(sp)
    8000260e:	7942                	ld	s2,48(sp)
    80002610:	79a2                	ld	s3,40(sp)
    80002612:	7a02                	ld	s4,32(sp)
    80002614:	6ae2                	ld	s5,24(sp)
    80002616:	6b42                	ld	s6,16(sp)
    80002618:	6ba2                	ld	s7,8(sp)
    8000261a:	6c02                	ld	s8,0(sp)
    8000261c:	6161                	addi	sp,sp,80
    8000261e:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002620:	85e2                	mv	a1,s8
    80002622:	854a                	mv	a0,s2
    80002624:	00000097          	auipc	ra,0x0
    80002628:	e84080e7          	jalr	-380(ra) # 800024a8 <sleep>
    havekids = 0;
    8000262c:	bf1d                	j	80002562 <wait+0x3c>

000000008000262e <wakeup>:
{
    8000262e:	7139                	addi	sp,sp,-64
    80002630:	fc06                	sd	ra,56(sp)
    80002632:	f822                	sd	s0,48(sp)
    80002634:	f426                	sd	s1,40(sp)
    80002636:	f04a                	sd	s2,32(sp)
    80002638:	ec4e                	sd	s3,24(sp)
    8000263a:	e852                	sd	s4,16(sp)
    8000263c:	e456                	sd	s5,8(sp)
    8000263e:	0080                	addi	s0,sp,64
    80002640:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002642:	0022f497          	auipc	s1,0x22f
    80002646:	72648493          	addi	s1,s1,1830 # 80231d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    8000264a:	4985                	li	s3,1
      p->state = RUNNABLE;
    8000264c:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    8000264e:	00235917          	auipc	s2,0x235
    80002652:	11a90913          	addi	s2,s2,282 # 80237768 <tickslock>
    80002656:	a821                	j	8000266e <wakeup+0x40>
      p->state = RUNNABLE;
    80002658:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    8000265c:	8526                	mv	a0,s1
    8000265e:	ffffe097          	auipc	ra,0xffffe
    80002662:	7b4080e7          	jalr	1972(ra) # 80000e12 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002666:	16848493          	addi	s1,s1,360
    8000266a:	01248e63          	beq	s1,s2,80002686 <wakeup+0x58>
    acquire(&p->lock);
    8000266e:	8526                	mv	a0,s1
    80002670:	ffffe097          	auipc	ra,0xffffe
    80002674:	6ee080e7          	jalr	1774(ra) # 80000d5e <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002678:	4c9c                	lw	a5,24(s1)
    8000267a:	ff3791e3          	bne	a5,s3,8000265c <wakeup+0x2e>
    8000267e:	749c                	ld	a5,40(s1)
    80002680:	fd479ee3          	bne	a5,s4,8000265c <wakeup+0x2e>
    80002684:	bfd1                	j	80002658 <wakeup+0x2a>
}
    80002686:	70e2                	ld	ra,56(sp)
    80002688:	7442                	ld	s0,48(sp)
    8000268a:	74a2                	ld	s1,40(sp)
    8000268c:	7902                	ld	s2,32(sp)
    8000268e:	69e2                	ld	s3,24(sp)
    80002690:	6a42                	ld	s4,16(sp)
    80002692:	6aa2                	ld	s5,8(sp)
    80002694:	6121                	addi	sp,sp,64
    80002696:	8082                	ret

0000000080002698 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002698:	7179                	addi	sp,sp,-48
    8000269a:	f406                	sd	ra,40(sp)
    8000269c:	f022                	sd	s0,32(sp)
    8000269e:	ec26                	sd	s1,24(sp)
    800026a0:	e84a                	sd	s2,16(sp)
    800026a2:	e44e                	sd	s3,8(sp)
    800026a4:	1800                	addi	s0,sp,48
    800026a6:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800026a8:	0022f497          	auipc	s1,0x22f
    800026ac:	6c048493          	addi	s1,s1,1728 # 80231d68 <proc>
    800026b0:	00235997          	auipc	s3,0x235
    800026b4:	0b898993          	addi	s3,s3,184 # 80237768 <tickslock>
    acquire(&p->lock);
    800026b8:	8526                	mv	a0,s1
    800026ba:	ffffe097          	auipc	ra,0xffffe
    800026be:	6a4080e7          	jalr	1700(ra) # 80000d5e <acquire>
    if(p->pid == pid){
    800026c2:	5c9c                	lw	a5,56(s1)
    800026c4:	01278d63          	beq	a5,s2,800026de <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800026c8:	8526                	mv	a0,s1
    800026ca:	ffffe097          	auipc	ra,0xffffe
    800026ce:	748080e7          	jalr	1864(ra) # 80000e12 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800026d2:	16848493          	addi	s1,s1,360
    800026d6:	ff3491e3          	bne	s1,s3,800026b8 <kill+0x20>
  }
  return -1;
    800026da:	557d                	li	a0,-1
    800026dc:	a829                	j	800026f6 <kill+0x5e>
      p->killed = 1;
    800026de:	4785                	li	a5,1
    800026e0:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800026e2:	4c98                	lw	a4,24(s1)
    800026e4:	4785                	li	a5,1
    800026e6:	00f70f63          	beq	a4,a5,80002704 <kill+0x6c>
      release(&p->lock);
    800026ea:	8526                	mv	a0,s1
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	726080e7          	jalr	1830(ra) # 80000e12 <release>
      return 0;
    800026f4:	4501                	li	a0,0
}
    800026f6:	70a2                	ld	ra,40(sp)
    800026f8:	7402                	ld	s0,32(sp)
    800026fa:	64e2                	ld	s1,24(sp)
    800026fc:	6942                	ld	s2,16(sp)
    800026fe:	69a2                	ld	s3,8(sp)
    80002700:	6145                	addi	sp,sp,48
    80002702:	8082                	ret
        p->state = RUNNABLE;
    80002704:	4789                	li	a5,2
    80002706:	cc9c                	sw	a5,24(s1)
    80002708:	b7cd                	j	800026ea <kill+0x52>

000000008000270a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000270a:	7179                	addi	sp,sp,-48
    8000270c:	f406                	sd	ra,40(sp)
    8000270e:	f022                	sd	s0,32(sp)
    80002710:	ec26                	sd	s1,24(sp)
    80002712:	e84a                	sd	s2,16(sp)
    80002714:	e44e                	sd	s3,8(sp)
    80002716:	e052                	sd	s4,0(sp)
    80002718:	1800                	addi	s0,sp,48
    8000271a:	84aa                	mv	s1,a0
    8000271c:	892e                	mv	s2,a1
    8000271e:	89b2                	mv	s3,a2
    80002720:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002722:	fffff097          	auipc	ra,0xfffff
    80002726:	56c080e7          	jalr	1388(ra) # 80001c8e <myproc>
  if(user_dst){
    8000272a:	c08d                	beqz	s1,8000274c <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000272c:	86d2                	mv	a3,s4
    8000272e:	864e                	mv	a2,s3
    80002730:	85ca                	mv	a1,s2
    80002732:	6928                	ld	a0,80(a0)
    80002734:	fffff097          	auipc	ra,0xfffff
    80002738:	31e080e7          	jalr	798(ra) # 80001a52 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000273c:	70a2                	ld	ra,40(sp)
    8000273e:	7402                	ld	s0,32(sp)
    80002740:	64e2                	ld	s1,24(sp)
    80002742:	6942                	ld	s2,16(sp)
    80002744:	69a2                	ld	s3,8(sp)
    80002746:	6a02                	ld	s4,0(sp)
    80002748:	6145                	addi	sp,sp,48
    8000274a:	8082                	ret
    memmove((char *)dst, src, len);
    8000274c:	000a061b          	sext.w	a2,s4
    80002750:	85ce                	mv	a1,s3
    80002752:	854a                	mv	a0,s2
    80002754:	ffffe097          	auipc	ra,0xffffe
    80002758:	772080e7          	jalr	1906(ra) # 80000ec6 <memmove>
    return 0;
    8000275c:	8526                	mv	a0,s1
    8000275e:	bff9                	j	8000273c <either_copyout+0x32>

0000000080002760 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002760:	7179                	addi	sp,sp,-48
    80002762:	f406                	sd	ra,40(sp)
    80002764:	f022                	sd	s0,32(sp)
    80002766:	ec26                	sd	s1,24(sp)
    80002768:	e84a                	sd	s2,16(sp)
    8000276a:	e44e                	sd	s3,8(sp)
    8000276c:	e052                	sd	s4,0(sp)
    8000276e:	1800                	addi	s0,sp,48
    80002770:	892a                	mv	s2,a0
    80002772:	84ae                	mv	s1,a1
    80002774:	89b2                	mv	s3,a2
    80002776:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002778:	fffff097          	auipc	ra,0xfffff
    8000277c:	516080e7          	jalr	1302(ra) # 80001c8e <myproc>
  if(user_src){
    80002780:	c08d                	beqz	s1,800027a2 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002782:	86d2                	mv	a3,s4
    80002784:	864e                	mv	a2,s3
    80002786:	85ca                	mv	a1,s2
    80002788:	6928                	ld	a0,80(a0)
    8000278a:	fffff097          	auipc	ra,0xfffff
    8000278e:	0a8080e7          	jalr	168(ra) # 80001832 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002792:	70a2                	ld	ra,40(sp)
    80002794:	7402                	ld	s0,32(sp)
    80002796:	64e2                	ld	s1,24(sp)
    80002798:	6942                	ld	s2,16(sp)
    8000279a:	69a2                	ld	s3,8(sp)
    8000279c:	6a02                	ld	s4,0(sp)
    8000279e:	6145                	addi	sp,sp,48
    800027a0:	8082                	ret
    memmove(dst, (char*)src, len);
    800027a2:	000a061b          	sext.w	a2,s4
    800027a6:	85ce                	mv	a1,s3
    800027a8:	854a                	mv	a0,s2
    800027aa:	ffffe097          	auipc	ra,0xffffe
    800027ae:	71c080e7          	jalr	1820(ra) # 80000ec6 <memmove>
    return 0;
    800027b2:	8526                	mv	a0,s1
    800027b4:	bff9                	j	80002792 <either_copyin+0x32>

00000000800027b6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800027b6:	715d                	addi	sp,sp,-80
    800027b8:	e486                	sd	ra,72(sp)
    800027ba:	e0a2                	sd	s0,64(sp)
    800027bc:	fc26                	sd	s1,56(sp)
    800027be:	f84a                	sd	s2,48(sp)
    800027c0:	f44e                	sd	s3,40(sp)
    800027c2:	f052                	sd	s4,32(sp)
    800027c4:	ec56                	sd	s5,24(sp)
    800027c6:	e85a                	sd	s6,16(sp)
    800027c8:	e45e                	sd	s7,8(sp)
    800027ca:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800027cc:	00006517          	auipc	a0,0x6
    800027d0:	93450513          	addi	a0,a0,-1740 # 80008100 <digits+0xe8>
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	dea080e7          	jalr	-534(ra) # 800005be <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027dc:	0022f497          	auipc	s1,0x22f
    800027e0:	6e448493          	addi	s1,s1,1764 # 80231ec0 <proc+0x158>
    800027e4:	00235917          	auipc	s2,0x235
    800027e8:	0dc90913          	addi	s2,s2,220 # 802378c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027ec:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800027ee:	00006997          	auipc	s3,0x6
    800027f2:	b8a98993          	addi	s3,s3,-1142 # 80008378 <states.1732+0xc8>
    printf("%d %s %s", p->pid, state, p->name);
    800027f6:	00006a97          	auipc	s5,0x6
    800027fa:	b8aa8a93          	addi	s5,s5,-1142 # 80008380 <states.1732+0xd0>
    printf("\n");
    800027fe:	00006a17          	auipc	s4,0x6
    80002802:	902a0a13          	addi	s4,s4,-1790 # 80008100 <digits+0xe8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002806:	00006b97          	auipc	s7,0x6
    8000280a:	aaab8b93          	addi	s7,s7,-1366 # 800082b0 <states.1732>
    8000280e:	a015                	j	80002832 <procdump+0x7c>
    printf("%d %s %s", p->pid, state, p->name);
    80002810:	86ba                	mv	a3,a4
    80002812:	ee072583          	lw	a1,-288(a4)
    80002816:	8556                	mv	a0,s5
    80002818:	ffffe097          	auipc	ra,0xffffe
    8000281c:	da6080e7          	jalr	-602(ra) # 800005be <printf>
    printf("\n");
    80002820:	8552                	mv	a0,s4
    80002822:	ffffe097          	auipc	ra,0xffffe
    80002826:	d9c080e7          	jalr	-612(ra) # 800005be <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000282a:	16848493          	addi	s1,s1,360
    8000282e:	03248163          	beq	s1,s2,80002850 <procdump+0x9a>
    if(p->state == UNUSED)
    80002832:	8726                	mv	a4,s1
    80002834:	ec04a783          	lw	a5,-320(s1)
    80002838:	dbed                	beqz	a5,8000282a <procdump+0x74>
      state = "???";
    8000283a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000283c:	fcfb6ae3          	bltu	s6,a5,80002810 <procdump+0x5a>
    80002840:	1782                	slli	a5,a5,0x20
    80002842:	9381                	srli	a5,a5,0x20
    80002844:	078e                	slli	a5,a5,0x3
    80002846:	97de                	add	a5,a5,s7
    80002848:	6390                	ld	a2,0(a5)
    8000284a:	f279                	bnez	a2,80002810 <procdump+0x5a>
      state = "???";
    8000284c:	864e                	mv	a2,s3
    8000284e:	b7c9                	j	80002810 <procdump+0x5a>
  }
}
    80002850:	60a6                	ld	ra,72(sp)
    80002852:	6406                	ld	s0,64(sp)
    80002854:	74e2                	ld	s1,56(sp)
    80002856:	7942                	ld	s2,48(sp)
    80002858:	79a2                	ld	s3,40(sp)
    8000285a:	7a02                	ld	s4,32(sp)
    8000285c:	6ae2                	ld	s5,24(sp)
    8000285e:	6b42                	ld	s6,16(sp)
    80002860:	6ba2                	ld	s7,8(sp)
    80002862:	6161                	addi	sp,sp,80
    80002864:	8082                	ret

0000000080002866 <swtch>:
    80002866:	00153023          	sd	ra,0(a0)
    8000286a:	00253423          	sd	sp,8(a0)
    8000286e:	e900                	sd	s0,16(a0)
    80002870:	ed04                	sd	s1,24(a0)
    80002872:	03253023          	sd	s2,32(a0)
    80002876:	03353423          	sd	s3,40(a0)
    8000287a:	03453823          	sd	s4,48(a0)
    8000287e:	03553c23          	sd	s5,56(a0)
    80002882:	05653023          	sd	s6,64(a0)
    80002886:	05753423          	sd	s7,72(a0)
    8000288a:	05853823          	sd	s8,80(a0)
    8000288e:	05953c23          	sd	s9,88(a0)
    80002892:	07a53023          	sd	s10,96(a0)
    80002896:	07b53423          	sd	s11,104(a0)
    8000289a:	0005b083          	ld	ra,0(a1)
    8000289e:	0085b103          	ld	sp,8(a1)
    800028a2:	6980                	ld	s0,16(a1)
    800028a4:	6d84                	ld	s1,24(a1)
    800028a6:	0205b903          	ld	s2,32(a1)
    800028aa:	0285b983          	ld	s3,40(a1)
    800028ae:	0305ba03          	ld	s4,48(a1)
    800028b2:	0385ba83          	ld	s5,56(a1)
    800028b6:	0405bb03          	ld	s6,64(a1)
    800028ba:	0485bb83          	ld	s7,72(a1)
    800028be:	0505bc03          	ld	s8,80(a1)
    800028c2:	0585bc83          	ld	s9,88(a1)
    800028c6:	0605bd03          	ld	s10,96(a1)
    800028ca:	0685bd83          	ld	s11,104(a1)
    800028ce:	8082                	ret

00000000800028d0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028d0:	1141                	addi	sp,sp,-16
    800028d2:	e406                	sd	ra,8(sp)
    800028d4:	e022                	sd	s0,0(sp)
    800028d6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028d8:	00006597          	auipc	a1,0x6
    800028dc:	ae058593          	addi	a1,a1,-1312 # 800083b8 <states.1732+0x108>
    800028e0:	00235517          	auipc	a0,0x235
    800028e4:	e8850513          	addi	a0,a0,-376 # 80237768 <tickslock>
    800028e8:	ffffe097          	auipc	ra,0xffffe
    800028ec:	3e6080e7          	jalr	998(ra) # 80000cce <initlock>
}
    800028f0:	60a2                	ld	ra,8(sp)
    800028f2:	6402                	ld	s0,0(sp)
    800028f4:	0141                	addi	sp,sp,16
    800028f6:	8082                	ret

00000000800028f8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028f8:	1141                	addi	sp,sp,-16
    800028fa:	e422                	sd	s0,8(sp)
    800028fc:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028fe:	00003797          	auipc	a5,0x3
    80002902:	5d278793          	addi	a5,a5,1490 # 80005ed0 <kernelvec>
    80002906:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000290a:	6422                	ld	s0,8(sp)
    8000290c:	0141                	addi	sp,sp,16
    8000290e:	8082                	ret

0000000080002910 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002910:	1141                	addi	sp,sp,-16
    80002912:	e406                	sd	ra,8(sp)
    80002914:	e022                	sd	s0,0(sp)
    80002916:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002918:	fffff097          	auipc	ra,0xfffff
    8000291c:	376080e7          	jalr	886(ra) # 80001c8e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002920:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002924:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002926:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000292a:	00004617          	auipc	a2,0x4
    8000292e:	6d660613          	addi	a2,a2,1750 # 80007000 <_trampoline>
    80002932:	00004697          	auipc	a3,0x4
    80002936:	6ce68693          	addi	a3,a3,1742 # 80007000 <_trampoline>
    8000293a:	8e91                	sub	a3,a3,a2
    8000293c:	040007b7          	lui	a5,0x4000
    80002940:	17fd                	addi	a5,a5,-1
    80002942:	07b2                	slli	a5,a5,0xc
    80002944:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002946:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000294a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000294c:	180026f3          	csrr	a3,satp
    80002950:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002952:	6d38                	ld	a4,88(a0)
    80002954:	6134                	ld	a3,64(a0)
    80002956:	6585                	lui	a1,0x1
    80002958:	96ae                	add	a3,a3,a1
    8000295a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000295c:	6d38                	ld	a4,88(a0)
    8000295e:	00000697          	auipc	a3,0x0
    80002962:	13868693          	addi	a3,a3,312 # 80002a96 <usertrap>
    80002966:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002968:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000296a:	8692                	mv	a3,tp
    8000296c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000296e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002972:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002976:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000297a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000297e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002980:	6f18                	ld	a4,24(a4)
    80002982:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002986:	692c                	ld	a1,80(a0)
    80002988:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000298a:	00004717          	auipc	a4,0x4
    8000298e:	70670713          	addi	a4,a4,1798 # 80007090 <userret>
    80002992:	8f11                	sub	a4,a4,a2
    80002994:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002996:	577d                	li	a4,-1
    80002998:	177e                	slli	a4,a4,0x3f
    8000299a:	8dd9                	or	a1,a1,a4
    8000299c:	02000537          	lui	a0,0x2000
    800029a0:	157d                	addi	a0,a0,-1
    800029a2:	0536                	slli	a0,a0,0xd
    800029a4:	9782                	jalr	a5
}
    800029a6:	60a2                	ld	ra,8(sp)
    800029a8:	6402                	ld	s0,0(sp)
    800029aa:	0141                	addi	sp,sp,16
    800029ac:	8082                	ret

00000000800029ae <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029ae:	1101                	addi	sp,sp,-32
    800029b0:	ec06                	sd	ra,24(sp)
    800029b2:	e822                	sd	s0,16(sp)
    800029b4:	e426                	sd	s1,8(sp)
    800029b6:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800029b8:	00235497          	auipc	s1,0x235
    800029bc:	db048493          	addi	s1,s1,-592 # 80237768 <tickslock>
    800029c0:	8526                	mv	a0,s1
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	39c080e7          	jalr	924(ra) # 80000d5e <acquire>
  ticks++;
    800029ca:	00006517          	auipc	a0,0x6
    800029ce:	65650513          	addi	a0,a0,1622 # 80009020 <ticks>
    800029d2:	411c                	lw	a5,0(a0)
    800029d4:	2785                	addiw	a5,a5,1
    800029d6:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800029d8:	00000097          	auipc	ra,0x0
    800029dc:	c56080e7          	jalr	-938(ra) # 8000262e <wakeup>
  release(&tickslock);
    800029e0:	8526                	mv	a0,s1
    800029e2:	ffffe097          	auipc	ra,0xffffe
    800029e6:	430080e7          	jalr	1072(ra) # 80000e12 <release>
}
    800029ea:	60e2                	ld	ra,24(sp)
    800029ec:	6442                	ld	s0,16(sp)
    800029ee:	64a2                	ld	s1,8(sp)
    800029f0:	6105                	addi	sp,sp,32
    800029f2:	8082                	ret

00000000800029f4 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800029f4:	1101                	addi	sp,sp,-32
    800029f6:	ec06                	sd	ra,24(sp)
    800029f8:	e822                	sd	s0,16(sp)
    800029fa:	e426                	sd	s1,8(sp)
    800029fc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029fe:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002a02:	00074d63          	bltz	a4,80002a1c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002a06:	57fd                	li	a5,-1
    80002a08:	17fe                	slli	a5,a5,0x3f
    80002a0a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002a0c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a0e:	06f70363          	beq	a4,a5,80002a74 <devintr+0x80>
  }
}
    80002a12:	60e2                	ld	ra,24(sp)
    80002a14:	6442                	ld	s0,16(sp)
    80002a16:	64a2                	ld	s1,8(sp)
    80002a18:	6105                	addi	sp,sp,32
    80002a1a:	8082                	ret
     (scause & 0xff) == 9){
    80002a1c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a20:	46a5                	li	a3,9
    80002a22:	fed792e3          	bne	a5,a3,80002a06 <devintr+0x12>
    int irq = plic_claim();
    80002a26:	00003097          	auipc	ra,0x3
    80002a2a:	5b2080e7          	jalr	1458(ra) # 80005fd8 <plic_claim>
    80002a2e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a30:	47a9                	li	a5,10
    80002a32:	02f50763          	beq	a0,a5,80002a60 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002a36:	4785                	li	a5,1
    80002a38:	02f50963          	beq	a0,a5,80002a6a <devintr+0x76>
    return 1;
    80002a3c:	4505                	li	a0,1
    } else if(irq){
    80002a3e:	d8f1                	beqz	s1,80002a12 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a40:	85a6                	mv	a1,s1
    80002a42:	00006517          	auipc	a0,0x6
    80002a46:	97e50513          	addi	a0,a0,-1666 # 800083c0 <states.1732+0x110>
    80002a4a:	ffffe097          	auipc	ra,0xffffe
    80002a4e:	b74080e7          	jalr	-1164(ra) # 800005be <printf>
      plic_complete(irq);
    80002a52:	8526                	mv	a0,s1
    80002a54:	00003097          	auipc	ra,0x3
    80002a58:	5a8080e7          	jalr	1448(ra) # 80005ffc <plic_complete>
    return 1;
    80002a5c:	4505                	li	a0,1
    80002a5e:	bf55                	j	80002a12 <devintr+0x1e>
      uartintr();
    80002a60:	ffffe097          	auipc	ra,0xffffe
    80002a64:	fc2080e7          	jalr	-62(ra) # 80000a22 <uartintr>
    80002a68:	b7ed                	j	80002a52 <devintr+0x5e>
      virtio_disk_intr();
    80002a6a:	00004097          	auipc	ra,0x4
    80002a6e:	a3e080e7          	jalr	-1474(ra) # 800064a8 <virtio_disk_intr>
    80002a72:	b7c5                	j	80002a52 <devintr+0x5e>
    if(cpuid() == 0){
    80002a74:	fffff097          	auipc	ra,0xfffff
    80002a78:	1ee080e7          	jalr	494(ra) # 80001c62 <cpuid>
    80002a7c:	c901                	beqz	a0,80002a8c <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a7e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a82:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a84:	14479073          	csrw	sip,a5
    return 2;
    80002a88:	4509                	li	a0,2
    80002a8a:	b761                	j	80002a12 <devintr+0x1e>
      clockintr();
    80002a8c:	00000097          	auipc	ra,0x0
    80002a90:	f22080e7          	jalr	-222(ra) # 800029ae <clockintr>
    80002a94:	b7ed                	j	80002a7e <devintr+0x8a>

0000000080002a96 <usertrap>:
{
    80002a96:	1101                	addi	sp,sp,-32
    80002a98:	ec06                	sd	ra,24(sp)
    80002a9a:	e822                	sd	s0,16(sp)
    80002a9c:	e426                	sd	s1,8(sp)
    80002a9e:	e04a                	sd	s2,0(sp)
    80002aa0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aa2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002aa6:	1007f793          	andi	a5,a5,256
    80002aaa:	e3b9                	bnez	a5,80002af0 <usertrap+0x5a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002aac:	00003797          	auipc	a5,0x3
    80002ab0:	42478793          	addi	a5,a5,1060 # 80005ed0 <kernelvec>
    80002ab4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ab8:	fffff097          	auipc	ra,0xfffff
    80002abc:	1d6080e7          	jalr	470(ra) # 80001c8e <myproc>
    80002ac0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002ac2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ac4:	14102773          	csrr	a4,sepc
    80002ac8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aca:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002ace:	47a1                	li	a5,8
    80002ad0:	02f70863          	beq	a4,a5,80002b00 <usertrap+0x6a>
    80002ad4:	14202773          	csrr	a4,scause
  } else if (r_scause() == 15) {
    80002ad8:	47bd                	li	a5,15
    80002ada:	06f70563          	beq	a4,a5,80002b44 <usertrap+0xae>
  } else if((which_dev = devintr()) != 0){
    80002ade:	00000097          	auipc	ra,0x0
    80002ae2:	f16080e7          	jalr	-234(ra) # 800029f4 <devintr>
    80002ae6:	892a                	mv	s2,a0
    80002ae8:	c935                	beqz	a0,80002b5c <usertrap+0xc6>
  if(p->killed)
    80002aea:	589c                	lw	a5,48(s1)
    80002aec:	c7dd                	beqz	a5,80002b9a <usertrap+0x104>
    80002aee:	a04d                	j	80002b90 <usertrap+0xfa>
    panic("usertrap: not from user mode");
    80002af0:	00006517          	auipc	a0,0x6
    80002af4:	8f050513          	addi	a0,a0,-1808 # 800083e0 <states.1732+0x130>
    80002af8:	ffffe097          	auipc	ra,0xffffe
    80002afc:	a7c080e7          	jalr	-1412(ra) # 80000574 <panic>
    if(p->killed)
    80002b00:	591c                	lw	a5,48(a0)
    80002b02:	eb9d                	bnez	a5,80002b38 <usertrap+0xa2>
    p->trapframe->epc += 4;
    80002b04:	6cb8                	ld	a4,88(s1)
    80002b06:	6f1c                	ld	a5,24(a4)
    80002b08:	0791                	addi	a5,a5,4
    80002b0a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b0c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b10:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b14:	10079073          	csrw	sstatus,a5
    syscall();
    80002b18:	00000097          	auipc	ra,0x0
    80002b1c:	2de080e7          	jalr	734(ra) # 80002df6 <syscall>
  if(p->killed)
    80002b20:	589c                	lw	a5,48(s1)
    80002b22:	e7c1                	bnez	a5,80002baa <usertrap+0x114>
  usertrapret();
    80002b24:	00000097          	auipc	ra,0x0
    80002b28:	dec080e7          	jalr	-532(ra) # 80002910 <usertrapret>
}
    80002b2c:	60e2                	ld	ra,24(sp)
    80002b2e:	6442                	ld	s0,16(sp)
    80002b30:	64a2                	ld	s1,8(sp)
    80002b32:	6902                	ld	s2,0(sp)
    80002b34:	6105                	addi	sp,sp,32
    80002b36:	8082                	ret
      exit(-1);
    80002b38:	557d                	li	a0,-1
    80002b3a:	00000097          	auipc	ra,0x0
    80002b3e:	826080e7          	jalr	-2010(ra) # 80002360 <exit>
    80002b42:	b7c9                	j	80002b04 <usertrap+0x6e>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b44:	143025f3          	csrr	a1,stval
    if (cowalloc(p->pagetable, r_stval()) < 0) {
    80002b48:	6928                	ld	a0,80(a0)
    80002b4a:	fffff097          	auipc	ra,0xfffff
    80002b4e:	e40080e7          	jalr	-448(ra) # 8000198a <cowalloc>
    80002b52:	fc0557e3          	bgez	a0,80002b20 <usertrap+0x8a>
      p->killed = 1;
    80002b56:	4785                	li	a5,1
    80002b58:	d89c                	sw	a5,48(s1)
    80002b5a:	a815                	j	80002b8e <usertrap+0xf8>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b5c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b60:	5c90                	lw	a2,56(s1)
    80002b62:	00006517          	auipc	a0,0x6
    80002b66:	89e50513          	addi	a0,a0,-1890 # 80008400 <states.1732+0x150>
    80002b6a:	ffffe097          	auipc	ra,0xffffe
    80002b6e:	a54080e7          	jalr	-1452(ra) # 800005be <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b72:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b76:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b7a:	00006517          	auipc	a0,0x6
    80002b7e:	8b650513          	addi	a0,a0,-1866 # 80008430 <states.1732+0x180>
    80002b82:	ffffe097          	auipc	ra,0xffffe
    80002b86:	a3c080e7          	jalr	-1476(ra) # 800005be <printf>
    p->killed = 1;
    80002b8a:	4785                	li	a5,1
    80002b8c:	d89c                	sw	a5,48(s1)
{
    80002b8e:	4901                	li	s2,0
    exit(-1);
    80002b90:	557d                	li	a0,-1
    80002b92:	fffff097          	auipc	ra,0xfffff
    80002b96:	7ce080e7          	jalr	1998(ra) # 80002360 <exit>
  if(which_dev == 2)
    80002b9a:	4789                	li	a5,2
    80002b9c:	f8f914e3          	bne	s2,a5,80002b24 <usertrap+0x8e>
    yield();
    80002ba0:	00000097          	auipc	ra,0x0
    80002ba4:	8cc080e7          	jalr	-1844(ra) # 8000246c <yield>
    80002ba8:	bfb5                	j	80002b24 <usertrap+0x8e>
  if(p->killed)
    80002baa:	4901                	li	s2,0
    80002bac:	b7d5                	j	80002b90 <usertrap+0xfa>

0000000080002bae <kerneltrap>:
{
    80002bae:	7179                	addi	sp,sp,-48
    80002bb0:	f406                	sd	ra,40(sp)
    80002bb2:	f022                	sd	s0,32(sp)
    80002bb4:	ec26                	sd	s1,24(sp)
    80002bb6:	e84a                	sd	s2,16(sp)
    80002bb8:	e44e                	sd	s3,8(sp)
    80002bba:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bbc:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bc0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bc4:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002bc8:	1004f793          	andi	a5,s1,256
    80002bcc:	cb85                	beqz	a5,80002bfc <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bce:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bd2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002bd4:	ef85                	bnez	a5,80002c0c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002bd6:	00000097          	auipc	ra,0x0
    80002bda:	e1e080e7          	jalr	-482(ra) # 800029f4 <devintr>
    80002bde:	cd1d                	beqz	a0,80002c1c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002be0:	4789                	li	a5,2
    80002be2:	06f50a63          	beq	a0,a5,80002c56 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002be6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bea:	10049073          	csrw	sstatus,s1
}
    80002bee:	70a2                	ld	ra,40(sp)
    80002bf0:	7402                	ld	s0,32(sp)
    80002bf2:	64e2                	ld	s1,24(sp)
    80002bf4:	6942                	ld	s2,16(sp)
    80002bf6:	69a2                	ld	s3,8(sp)
    80002bf8:	6145                	addi	sp,sp,48
    80002bfa:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bfc:	00006517          	auipc	a0,0x6
    80002c00:	85450513          	addi	a0,a0,-1964 # 80008450 <states.1732+0x1a0>
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	970080e7          	jalr	-1680(ra) # 80000574 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c0c:	00006517          	auipc	a0,0x6
    80002c10:	86c50513          	addi	a0,a0,-1940 # 80008478 <states.1732+0x1c8>
    80002c14:	ffffe097          	auipc	ra,0xffffe
    80002c18:	960080e7          	jalr	-1696(ra) # 80000574 <panic>
    printf("scause %p\n", scause);
    80002c1c:	85ce                	mv	a1,s3
    80002c1e:	00006517          	auipc	a0,0x6
    80002c22:	87a50513          	addi	a0,a0,-1926 # 80008498 <states.1732+0x1e8>
    80002c26:	ffffe097          	auipc	ra,0xffffe
    80002c2a:	998080e7          	jalr	-1640(ra) # 800005be <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c2e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c32:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c36:	00006517          	auipc	a0,0x6
    80002c3a:	87250513          	addi	a0,a0,-1934 # 800084a8 <states.1732+0x1f8>
    80002c3e:	ffffe097          	auipc	ra,0xffffe
    80002c42:	980080e7          	jalr	-1664(ra) # 800005be <printf>
    panic("kerneltrap");
    80002c46:	00006517          	auipc	a0,0x6
    80002c4a:	87a50513          	addi	a0,a0,-1926 # 800084c0 <states.1732+0x210>
    80002c4e:	ffffe097          	auipc	ra,0xffffe
    80002c52:	926080e7          	jalr	-1754(ra) # 80000574 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c56:	fffff097          	auipc	ra,0xfffff
    80002c5a:	038080e7          	jalr	56(ra) # 80001c8e <myproc>
    80002c5e:	d541                	beqz	a0,80002be6 <kerneltrap+0x38>
    80002c60:	fffff097          	auipc	ra,0xfffff
    80002c64:	02e080e7          	jalr	46(ra) # 80001c8e <myproc>
    80002c68:	4d18                	lw	a4,24(a0)
    80002c6a:	478d                	li	a5,3
    80002c6c:	f6f71de3          	bne	a4,a5,80002be6 <kerneltrap+0x38>
    yield();
    80002c70:	fffff097          	auipc	ra,0xfffff
    80002c74:	7fc080e7          	jalr	2044(ra) # 8000246c <yield>
    80002c78:	b7bd                	j	80002be6 <kerneltrap+0x38>

0000000080002c7a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c7a:	1101                	addi	sp,sp,-32
    80002c7c:	ec06                	sd	ra,24(sp)
    80002c7e:	e822                	sd	s0,16(sp)
    80002c80:	e426                	sd	s1,8(sp)
    80002c82:	1000                	addi	s0,sp,32
    80002c84:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c86:	fffff097          	auipc	ra,0xfffff
    80002c8a:	008080e7          	jalr	8(ra) # 80001c8e <myproc>
  switch (n) {
    80002c8e:	4795                	li	a5,5
    80002c90:	0497e363          	bltu	a5,s1,80002cd6 <argraw+0x5c>
    80002c94:	1482                	slli	s1,s1,0x20
    80002c96:	9081                	srli	s1,s1,0x20
    80002c98:	048a                	slli	s1,s1,0x2
    80002c9a:	00006717          	auipc	a4,0x6
    80002c9e:	83670713          	addi	a4,a4,-1994 # 800084d0 <states.1732+0x220>
    80002ca2:	94ba                	add	s1,s1,a4
    80002ca4:	409c                	lw	a5,0(s1)
    80002ca6:	97ba                	add	a5,a5,a4
    80002ca8:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002caa:	6d3c                	ld	a5,88(a0)
    80002cac:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cae:	60e2                	ld	ra,24(sp)
    80002cb0:	6442                	ld	s0,16(sp)
    80002cb2:	64a2                	ld	s1,8(sp)
    80002cb4:	6105                	addi	sp,sp,32
    80002cb6:	8082                	ret
    return p->trapframe->a1;
    80002cb8:	6d3c                	ld	a5,88(a0)
    80002cba:	7fa8                	ld	a0,120(a5)
    80002cbc:	bfcd                	j	80002cae <argraw+0x34>
    return p->trapframe->a2;
    80002cbe:	6d3c                	ld	a5,88(a0)
    80002cc0:	63c8                	ld	a0,128(a5)
    80002cc2:	b7f5                	j	80002cae <argraw+0x34>
    return p->trapframe->a3;
    80002cc4:	6d3c                	ld	a5,88(a0)
    80002cc6:	67c8                	ld	a0,136(a5)
    80002cc8:	b7dd                	j	80002cae <argraw+0x34>
    return p->trapframe->a4;
    80002cca:	6d3c                	ld	a5,88(a0)
    80002ccc:	6bc8                	ld	a0,144(a5)
    80002cce:	b7c5                	j	80002cae <argraw+0x34>
    return p->trapframe->a5;
    80002cd0:	6d3c                	ld	a5,88(a0)
    80002cd2:	6fc8                	ld	a0,152(a5)
    80002cd4:	bfe9                	j	80002cae <argraw+0x34>
  panic("argraw");
    80002cd6:	00006517          	auipc	a0,0x6
    80002cda:	8c250513          	addi	a0,a0,-1854 # 80008598 <syscalls+0xb0>
    80002cde:	ffffe097          	auipc	ra,0xffffe
    80002ce2:	896080e7          	jalr	-1898(ra) # 80000574 <panic>

0000000080002ce6 <fetchaddr>:
{
    80002ce6:	1101                	addi	sp,sp,-32
    80002ce8:	ec06                	sd	ra,24(sp)
    80002cea:	e822                	sd	s0,16(sp)
    80002cec:	e426                	sd	s1,8(sp)
    80002cee:	e04a                	sd	s2,0(sp)
    80002cf0:	1000                	addi	s0,sp,32
    80002cf2:	84aa                	mv	s1,a0
    80002cf4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002cf6:	fffff097          	auipc	ra,0xfffff
    80002cfa:	f98080e7          	jalr	-104(ra) # 80001c8e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002cfe:	653c                	ld	a5,72(a0)
    80002d00:	02f4f963          	bleu	a5,s1,80002d32 <fetchaddr+0x4c>
    80002d04:	00848713          	addi	a4,s1,8
    80002d08:	02e7e763          	bltu	a5,a4,80002d36 <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d0c:	46a1                	li	a3,8
    80002d0e:	8626                	mv	a2,s1
    80002d10:	85ca                	mv	a1,s2
    80002d12:	6928                	ld	a0,80(a0)
    80002d14:	fffff097          	auipc	ra,0xfffff
    80002d18:	b1e080e7          	jalr	-1250(ra) # 80001832 <copyin>
    80002d1c:	00a03533          	snez	a0,a0
    80002d20:	40a0053b          	negw	a0,a0
    80002d24:	2501                	sext.w	a0,a0
}
    80002d26:	60e2                	ld	ra,24(sp)
    80002d28:	6442                	ld	s0,16(sp)
    80002d2a:	64a2                	ld	s1,8(sp)
    80002d2c:	6902                	ld	s2,0(sp)
    80002d2e:	6105                	addi	sp,sp,32
    80002d30:	8082                	ret
    return -1;
    80002d32:	557d                	li	a0,-1
    80002d34:	bfcd                	j	80002d26 <fetchaddr+0x40>
    80002d36:	557d                	li	a0,-1
    80002d38:	b7fd                	j	80002d26 <fetchaddr+0x40>

0000000080002d3a <fetchstr>:
{
    80002d3a:	7179                	addi	sp,sp,-48
    80002d3c:	f406                	sd	ra,40(sp)
    80002d3e:	f022                	sd	s0,32(sp)
    80002d40:	ec26                	sd	s1,24(sp)
    80002d42:	e84a                	sd	s2,16(sp)
    80002d44:	e44e                	sd	s3,8(sp)
    80002d46:	1800                	addi	s0,sp,48
    80002d48:	892a                	mv	s2,a0
    80002d4a:	84ae                	mv	s1,a1
    80002d4c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d4e:	fffff097          	auipc	ra,0xfffff
    80002d52:	f40080e7          	jalr	-192(ra) # 80001c8e <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002d56:	86ce                	mv	a3,s3
    80002d58:	864a                	mv	a2,s2
    80002d5a:	85a6                	mv	a1,s1
    80002d5c:	6928                	ld	a0,80(a0)
    80002d5e:	fffff097          	auipc	ra,0xfffff
    80002d62:	b62080e7          	jalr	-1182(ra) # 800018c0 <copyinstr>
  if(err < 0)
    80002d66:	00054763          	bltz	a0,80002d74 <fetchstr+0x3a>
  return strlen(buf);
    80002d6a:	8526                	mv	a0,s1
    80002d6c:	ffffe097          	auipc	ra,0xffffe
    80002d70:	298080e7          	jalr	664(ra) # 80001004 <strlen>
}
    80002d74:	70a2                	ld	ra,40(sp)
    80002d76:	7402                	ld	s0,32(sp)
    80002d78:	64e2                	ld	s1,24(sp)
    80002d7a:	6942                	ld	s2,16(sp)
    80002d7c:	69a2                	ld	s3,8(sp)
    80002d7e:	6145                	addi	sp,sp,48
    80002d80:	8082                	ret

0000000080002d82 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002d82:	1101                	addi	sp,sp,-32
    80002d84:	ec06                	sd	ra,24(sp)
    80002d86:	e822                	sd	s0,16(sp)
    80002d88:	e426                	sd	s1,8(sp)
    80002d8a:	1000                	addi	s0,sp,32
    80002d8c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d8e:	00000097          	auipc	ra,0x0
    80002d92:	eec080e7          	jalr	-276(ra) # 80002c7a <argraw>
    80002d96:	c088                	sw	a0,0(s1)
  return 0;
}
    80002d98:	4501                	li	a0,0
    80002d9a:	60e2                	ld	ra,24(sp)
    80002d9c:	6442                	ld	s0,16(sp)
    80002d9e:	64a2                	ld	s1,8(sp)
    80002da0:	6105                	addi	sp,sp,32
    80002da2:	8082                	ret

0000000080002da4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002da4:	1101                	addi	sp,sp,-32
    80002da6:	ec06                	sd	ra,24(sp)
    80002da8:	e822                	sd	s0,16(sp)
    80002daa:	e426                	sd	s1,8(sp)
    80002dac:	1000                	addi	s0,sp,32
    80002dae:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002db0:	00000097          	auipc	ra,0x0
    80002db4:	eca080e7          	jalr	-310(ra) # 80002c7a <argraw>
    80002db8:	e088                	sd	a0,0(s1)
  return 0;
}
    80002dba:	4501                	li	a0,0
    80002dbc:	60e2                	ld	ra,24(sp)
    80002dbe:	6442                	ld	s0,16(sp)
    80002dc0:	64a2                	ld	s1,8(sp)
    80002dc2:	6105                	addi	sp,sp,32
    80002dc4:	8082                	ret

0000000080002dc6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002dc6:	1101                	addi	sp,sp,-32
    80002dc8:	ec06                	sd	ra,24(sp)
    80002dca:	e822                	sd	s0,16(sp)
    80002dcc:	e426                	sd	s1,8(sp)
    80002dce:	e04a                	sd	s2,0(sp)
    80002dd0:	1000                	addi	s0,sp,32
    80002dd2:	84ae                	mv	s1,a1
    80002dd4:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002dd6:	00000097          	auipc	ra,0x0
    80002dda:	ea4080e7          	jalr	-348(ra) # 80002c7a <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002dde:	864a                	mv	a2,s2
    80002de0:	85a6                	mv	a1,s1
    80002de2:	00000097          	auipc	ra,0x0
    80002de6:	f58080e7          	jalr	-168(ra) # 80002d3a <fetchstr>
}
    80002dea:	60e2                	ld	ra,24(sp)
    80002dec:	6442                	ld	s0,16(sp)
    80002dee:	64a2                	ld	s1,8(sp)
    80002df0:	6902                	ld	s2,0(sp)
    80002df2:	6105                	addi	sp,sp,32
    80002df4:	8082                	ret

0000000080002df6 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002df6:	1101                	addi	sp,sp,-32
    80002df8:	ec06                	sd	ra,24(sp)
    80002dfa:	e822                	sd	s0,16(sp)
    80002dfc:	e426                	sd	s1,8(sp)
    80002dfe:	e04a                	sd	s2,0(sp)
    80002e00:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e02:	fffff097          	auipc	ra,0xfffff
    80002e06:	e8c080e7          	jalr	-372(ra) # 80001c8e <myproc>
    80002e0a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e0c:	05853903          	ld	s2,88(a0)
    80002e10:	0a893783          	ld	a5,168(s2)
    80002e14:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e18:	37fd                	addiw	a5,a5,-1
    80002e1a:	4751                	li	a4,20
    80002e1c:	00f76f63          	bltu	a4,a5,80002e3a <syscall+0x44>
    80002e20:	00369713          	slli	a4,a3,0x3
    80002e24:	00005797          	auipc	a5,0x5
    80002e28:	6c478793          	addi	a5,a5,1732 # 800084e8 <syscalls>
    80002e2c:	97ba                	add	a5,a5,a4
    80002e2e:	639c                	ld	a5,0(a5)
    80002e30:	c789                	beqz	a5,80002e3a <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002e32:	9782                	jalr	a5
    80002e34:	06a93823          	sd	a0,112(s2)
    80002e38:	a839                	j	80002e56 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e3a:	15848613          	addi	a2,s1,344
    80002e3e:	5c8c                	lw	a1,56(s1)
    80002e40:	00005517          	auipc	a0,0x5
    80002e44:	76050513          	addi	a0,a0,1888 # 800085a0 <syscalls+0xb8>
    80002e48:	ffffd097          	auipc	ra,0xffffd
    80002e4c:	776080e7          	jalr	1910(ra) # 800005be <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e50:	6cbc                	ld	a5,88(s1)
    80002e52:	577d                	li	a4,-1
    80002e54:	fbb8                	sd	a4,112(a5)
  }
}
    80002e56:	60e2                	ld	ra,24(sp)
    80002e58:	6442                	ld	s0,16(sp)
    80002e5a:	64a2                	ld	s1,8(sp)
    80002e5c:	6902                	ld	s2,0(sp)
    80002e5e:	6105                	addi	sp,sp,32
    80002e60:	8082                	ret

0000000080002e62 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e62:	1101                	addi	sp,sp,-32
    80002e64:	ec06                	sd	ra,24(sp)
    80002e66:	e822                	sd	s0,16(sp)
    80002e68:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002e6a:	fec40593          	addi	a1,s0,-20
    80002e6e:	4501                	li	a0,0
    80002e70:	00000097          	auipc	ra,0x0
    80002e74:	f12080e7          	jalr	-238(ra) # 80002d82 <argint>
    return -1;
    80002e78:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e7a:	00054963          	bltz	a0,80002e8c <sys_exit+0x2a>
  exit(n);
    80002e7e:	fec42503          	lw	a0,-20(s0)
    80002e82:	fffff097          	auipc	ra,0xfffff
    80002e86:	4de080e7          	jalr	1246(ra) # 80002360 <exit>
  return 0;  // not reached
    80002e8a:	4781                	li	a5,0
}
    80002e8c:	853e                	mv	a0,a5
    80002e8e:	60e2                	ld	ra,24(sp)
    80002e90:	6442                	ld	s0,16(sp)
    80002e92:	6105                	addi	sp,sp,32
    80002e94:	8082                	ret

0000000080002e96 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e96:	1141                	addi	sp,sp,-16
    80002e98:	e406                	sd	ra,8(sp)
    80002e9a:	e022                	sd	s0,0(sp)
    80002e9c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e9e:	fffff097          	auipc	ra,0xfffff
    80002ea2:	df0080e7          	jalr	-528(ra) # 80001c8e <myproc>
}
    80002ea6:	5d08                	lw	a0,56(a0)
    80002ea8:	60a2                	ld	ra,8(sp)
    80002eaa:	6402                	ld	s0,0(sp)
    80002eac:	0141                	addi	sp,sp,16
    80002eae:	8082                	ret

0000000080002eb0 <sys_fork>:

uint64
sys_fork(void)
{
    80002eb0:	1141                	addi	sp,sp,-16
    80002eb2:	e406                	sd	ra,8(sp)
    80002eb4:	e022                	sd	s0,0(sp)
    80002eb6:	0800                	addi	s0,sp,16
  return fork();
    80002eb8:	fffff097          	auipc	ra,0xfffff
    80002ebc:	19c080e7          	jalr	412(ra) # 80002054 <fork>
}
    80002ec0:	60a2                	ld	ra,8(sp)
    80002ec2:	6402                	ld	s0,0(sp)
    80002ec4:	0141                	addi	sp,sp,16
    80002ec6:	8082                	ret

0000000080002ec8 <sys_wait>:

uint64
sys_wait(void)
{
    80002ec8:	1101                	addi	sp,sp,-32
    80002eca:	ec06                	sd	ra,24(sp)
    80002ecc:	e822                	sd	s0,16(sp)
    80002ece:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002ed0:	fe840593          	addi	a1,s0,-24
    80002ed4:	4501                	li	a0,0
    80002ed6:	00000097          	auipc	ra,0x0
    80002eda:	ece080e7          	jalr	-306(ra) # 80002da4 <argaddr>
    return -1;
    80002ede:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    80002ee0:	00054963          	bltz	a0,80002ef2 <sys_wait+0x2a>
  return wait(p);
    80002ee4:	fe843503          	ld	a0,-24(s0)
    80002ee8:	fffff097          	auipc	ra,0xfffff
    80002eec:	63e080e7          	jalr	1598(ra) # 80002526 <wait>
    80002ef0:	87aa                	mv	a5,a0
}
    80002ef2:	853e                	mv	a0,a5
    80002ef4:	60e2                	ld	ra,24(sp)
    80002ef6:	6442                	ld	s0,16(sp)
    80002ef8:	6105                	addi	sp,sp,32
    80002efa:	8082                	ret

0000000080002efc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002efc:	7179                	addi	sp,sp,-48
    80002efe:	f406                	sd	ra,40(sp)
    80002f00:	f022                	sd	s0,32(sp)
    80002f02:	ec26                	sd	s1,24(sp)
    80002f04:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002f06:	fdc40593          	addi	a1,s0,-36
    80002f0a:	4501                	li	a0,0
    80002f0c:	00000097          	auipc	ra,0x0
    80002f10:	e76080e7          	jalr	-394(ra) # 80002d82 <argint>
    return -1;
    80002f14:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002f16:	00054f63          	bltz	a0,80002f34 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002f1a:	fffff097          	auipc	ra,0xfffff
    80002f1e:	d74080e7          	jalr	-652(ra) # 80001c8e <myproc>
    80002f22:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002f24:	fdc42503          	lw	a0,-36(s0)
    80002f28:	fffff097          	auipc	ra,0xfffff
    80002f2c:	0b4080e7          	jalr	180(ra) # 80001fdc <growproc>
    80002f30:	00054863          	bltz	a0,80002f40 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002f34:	8526                	mv	a0,s1
    80002f36:	70a2                	ld	ra,40(sp)
    80002f38:	7402                	ld	s0,32(sp)
    80002f3a:	64e2                	ld	s1,24(sp)
    80002f3c:	6145                	addi	sp,sp,48
    80002f3e:	8082                	ret
    return -1;
    80002f40:	54fd                	li	s1,-1
    80002f42:	bfcd                	j	80002f34 <sys_sbrk+0x38>

0000000080002f44 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f44:	7139                	addi	sp,sp,-64
    80002f46:	fc06                	sd	ra,56(sp)
    80002f48:	f822                	sd	s0,48(sp)
    80002f4a:	f426                	sd	s1,40(sp)
    80002f4c:	f04a                	sd	s2,32(sp)
    80002f4e:	ec4e                	sd	s3,24(sp)
    80002f50:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002f52:	fcc40593          	addi	a1,s0,-52
    80002f56:	4501                	li	a0,0
    80002f58:	00000097          	auipc	ra,0x0
    80002f5c:	e2a080e7          	jalr	-470(ra) # 80002d82 <argint>
    return -1;
    80002f60:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f62:	06054763          	bltz	a0,80002fd0 <sys_sleep+0x8c>
  acquire(&tickslock);
    80002f66:	00235517          	auipc	a0,0x235
    80002f6a:	80250513          	addi	a0,a0,-2046 # 80237768 <tickslock>
    80002f6e:	ffffe097          	auipc	ra,0xffffe
    80002f72:	df0080e7          	jalr	-528(ra) # 80000d5e <acquire>
  ticks0 = ticks;
    80002f76:	00006797          	auipc	a5,0x6
    80002f7a:	0aa78793          	addi	a5,a5,170 # 80009020 <ticks>
    80002f7e:	0007a903          	lw	s2,0(a5)
  while(ticks - ticks0 < n){
    80002f82:	fcc42783          	lw	a5,-52(s0)
    80002f86:	cf85                	beqz	a5,80002fbe <sys_sleep+0x7a>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f88:	00234997          	auipc	s3,0x234
    80002f8c:	7e098993          	addi	s3,s3,2016 # 80237768 <tickslock>
    80002f90:	00006497          	auipc	s1,0x6
    80002f94:	09048493          	addi	s1,s1,144 # 80009020 <ticks>
    if(myproc()->killed){
    80002f98:	fffff097          	auipc	ra,0xfffff
    80002f9c:	cf6080e7          	jalr	-778(ra) # 80001c8e <myproc>
    80002fa0:	591c                	lw	a5,48(a0)
    80002fa2:	ef9d                	bnez	a5,80002fe0 <sys_sleep+0x9c>
    sleep(&ticks, &tickslock);
    80002fa4:	85ce                	mv	a1,s3
    80002fa6:	8526                	mv	a0,s1
    80002fa8:	fffff097          	auipc	ra,0xfffff
    80002fac:	500080e7          	jalr	1280(ra) # 800024a8 <sleep>
  while(ticks - ticks0 < n){
    80002fb0:	409c                	lw	a5,0(s1)
    80002fb2:	412787bb          	subw	a5,a5,s2
    80002fb6:	fcc42703          	lw	a4,-52(s0)
    80002fba:	fce7efe3          	bltu	a5,a4,80002f98 <sys_sleep+0x54>
  }
  release(&tickslock);
    80002fbe:	00234517          	auipc	a0,0x234
    80002fc2:	7aa50513          	addi	a0,a0,1962 # 80237768 <tickslock>
    80002fc6:	ffffe097          	auipc	ra,0xffffe
    80002fca:	e4c080e7          	jalr	-436(ra) # 80000e12 <release>
  return 0;
    80002fce:	4781                	li	a5,0
}
    80002fd0:	853e                	mv	a0,a5
    80002fd2:	70e2                	ld	ra,56(sp)
    80002fd4:	7442                	ld	s0,48(sp)
    80002fd6:	74a2                	ld	s1,40(sp)
    80002fd8:	7902                	ld	s2,32(sp)
    80002fda:	69e2                	ld	s3,24(sp)
    80002fdc:	6121                	addi	sp,sp,64
    80002fde:	8082                	ret
      release(&tickslock);
    80002fe0:	00234517          	auipc	a0,0x234
    80002fe4:	78850513          	addi	a0,a0,1928 # 80237768 <tickslock>
    80002fe8:	ffffe097          	auipc	ra,0xffffe
    80002fec:	e2a080e7          	jalr	-470(ra) # 80000e12 <release>
      return -1;
    80002ff0:	57fd                	li	a5,-1
    80002ff2:	bff9                	j	80002fd0 <sys_sleep+0x8c>

0000000080002ff4 <sys_kill>:

uint64
sys_kill(void)
{
    80002ff4:	1101                	addi	sp,sp,-32
    80002ff6:	ec06                	sd	ra,24(sp)
    80002ff8:	e822                	sd	s0,16(sp)
    80002ffa:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002ffc:	fec40593          	addi	a1,s0,-20
    80003000:	4501                	li	a0,0
    80003002:	00000097          	auipc	ra,0x0
    80003006:	d80080e7          	jalr	-640(ra) # 80002d82 <argint>
    return -1;
    8000300a:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    8000300c:	00054963          	bltz	a0,8000301e <sys_kill+0x2a>
  return kill(pid);
    80003010:	fec42503          	lw	a0,-20(s0)
    80003014:	fffff097          	auipc	ra,0xfffff
    80003018:	684080e7          	jalr	1668(ra) # 80002698 <kill>
    8000301c:	87aa                	mv	a5,a0
}
    8000301e:	853e                	mv	a0,a5
    80003020:	60e2                	ld	ra,24(sp)
    80003022:	6442                	ld	s0,16(sp)
    80003024:	6105                	addi	sp,sp,32
    80003026:	8082                	ret

0000000080003028 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003028:	1101                	addi	sp,sp,-32
    8000302a:	ec06                	sd	ra,24(sp)
    8000302c:	e822                	sd	s0,16(sp)
    8000302e:	e426                	sd	s1,8(sp)
    80003030:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003032:	00234517          	auipc	a0,0x234
    80003036:	73650513          	addi	a0,a0,1846 # 80237768 <tickslock>
    8000303a:	ffffe097          	auipc	ra,0xffffe
    8000303e:	d24080e7          	jalr	-732(ra) # 80000d5e <acquire>
  xticks = ticks;
    80003042:	00006797          	auipc	a5,0x6
    80003046:	fde78793          	addi	a5,a5,-34 # 80009020 <ticks>
    8000304a:	4384                	lw	s1,0(a5)
  release(&tickslock);
    8000304c:	00234517          	auipc	a0,0x234
    80003050:	71c50513          	addi	a0,a0,1820 # 80237768 <tickslock>
    80003054:	ffffe097          	auipc	ra,0xffffe
    80003058:	dbe080e7          	jalr	-578(ra) # 80000e12 <release>
  return xticks;
}
    8000305c:	02049513          	slli	a0,s1,0x20
    80003060:	9101                	srli	a0,a0,0x20
    80003062:	60e2                	ld	ra,24(sp)
    80003064:	6442                	ld	s0,16(sp)
    80003066:	64a2                	ld	s1,8(sp)
    80003068:	6105                	addi	sp,sp,32
    8000306a:	8082                	ret

000000008000306c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000306c:	7179                	addi	sp,sp,-48
    8000306e:	f406                	sd	ra,40(sp)
    80003070:	f022                	sd	s0,32(sp)
    80003072:	ec26                	sd	s1,24(sp)
    80003074:	e84a                	sd	s2,16(sp)
    80003076:	e44e                	sd	s3,8(sp)
    80003078:	e052                	sd	s4,0(sp)
    8000307a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000307c:	00005597          	auipc	a1,0x5
    80003080:	54458593          	addi	a1,a1,1348 # 800085c0 <syscalls+0xd8>
    80003084:	00234517          	auipc	a0,0x234
    80003088:	6fc50513          	addi	a0,a0,1788 # 80237780 <bcache>
    8000308c:	ffffe097          	auipc	ra,0xffffe
    80003090:	c42080e7          	jalr	-958(ra) # 80000cce <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003094:	0023c797          	auipc	a5,0x23c
    80003098:	6ec78793          	addi	a5,a5,1772 # 8023f780 <bcache+0x8000>
    8000309c:	0023d717          	auipc	a4,0x23d
    800030a0:	94c70713          	addi	a4,a4,-1716 # 8023f9e8 <bcache+0x8268>
    800030a4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030a8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030ac:	00234497          	auipc	s1,0x234
    800030b0:	6ec48493          	addi	s1,s1,1772 # 80237798 <bcache+0x18>
    b->next = bcache.head.next;
    800030b4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030b6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030b8:	00005a17          	auipc	s4,0x5
    800030bc:	510a0a13          	addi	s4,s4,1296 # 800085c8 <syscalls+0xe0>
    b->next = bcache.head.next;
    800030c0:	2b893783          	ld	a5,696(s2)
    800030c4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030c6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030ca:	85d2                	mv	a1,s4
    800030cc:	01048513          	addi	a0,s1,16
    800030d0:	00001097          	auipc	ra,0x1
    800030d4:	51e080e7          	jalr	1310(ra) # 800045ee <initsleeplock>
    bcache.head.next->prev = b;
    800030d8:	2b893783          	ld	a5,696(s2)
    800030dc:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030de:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030e2:	45848493          	addi	s1,s1,1112
    800030e6:	fd349de3          	bne	s1,s3,800030c0 <binit+0x54>
  }
}
    800030ea:	70a2                	ld	ra,40(sp)
    800030ec:	7402                	ld	s0,32(sp)
    800030ee:	64e2                	ld	s1,24(sp)
    800030f0:	6942                	ld	s2,16(sp)
    800030f2:	69a2                	ld	s3,8(sp)
    800030f4:	6a02                	ld	s4,0(sp)
    800030f6:	6145                	addi	sp,sp,48
    800030f8:	8082                	ret

00000000800030fa <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030fa:	7179                	addi	sp,sp,-48
    800030fc:	f406                	sd	ra,40(sp)
    800030fe:	f022                	sd	s0,32(sp)
    80003100:	ec26                	sd	s1,24(sp)
    80003102:	e84a                	sd	s2,16(sp)
    80003104:	e44e                	sd	s3,8(sp)
    80003106:	1800                	addi	s0,sp,48
    80003108:	89aa                	mv	s3,a0
    8000310a:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000310c:	00234517          	auipc	a0,0x234
    80003110:	67450513          	addi	a0,a0,1652 # 80237780 <bcache>
    80003114:	ffffe097          	auipc	ra,0xffffe
    80003118:	c4a080e7          	jalr	-950(ra) # 80000d5e <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000311c:	0023c797          	auipc	a5,0x23c
    80003120:	66478793          	addi	a5,a5,1636 # 8023f780 <bcache+0x8000>
    80003124:	2b87b483          	ld	s1,696(a5)
    80003128:	0023d797          	auipc	a5,0x23d
    8000312c:	8c078793          	addi	a5,a5,-1856 # 8023f9e8 <bcache+0x8268>
    80003130:	02f48f63          	beq	s1,a5,8000316e <bread+0x74>
    80003134:	873e                	mv	a4,a5
    80003136:	a021                	j	8000313e <bread+0x44>
    80003138:	68a4                	ld	s1,80(s1)
    8000313a:	02e48a63          	beq	s1,a4,8000316e <bread+0x74>
    if(b->dev == dev && b->blockno == blockno){
    8000313e:	449c                	lw	a5,8(s1)
    80003140:	ff379ce3          	bne	a5,s3,80003138 <bread+0x3e>
    80003144:	44dc                	lw	a5,12(s1)
    80003146:	ff2799e3          	bne	a5,s2,80003138 <bread+0x3e>
      b->refcnt++;
    8000314a:	40bc                	lw	a5,64(s1)
    8000314c:	2785                	addiw	a5,a5,1
    8000314e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003150:	00234517          	auipc	a0,0x234
    80003154:	63050513          	addi	a0,a0,1584 # 80237780 <bcache>
    80003158:	ffffe097          	auipc	ra,0xffffe
    8000315c:	cba080e7          	jalr	-838(ra) # 80000e12 <release>
      acquiresleep(&b->lock);
    80003160:	01048513          	addi	a0,s1,16
    80003164:	00001097          	auipc	ra,0x1
    80003168:	4c4080e7          	jalr	1220(ra) # 80004628 <acquiresleep>
      return b;
    8000316c:	a8b1                	j	800031c8 <bread+0xce>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000316e:	0023c797          	auipc	a5,0x23c
    80003172:	61278793          	addi	a5,a5,1554 # 8023f780 <bcache+0x8000>
    80003176:	2b07b483          	ld	s1,688(a5)
    8000317a:	0023d797          	auipc	a5,0x23d
    8000317e:	86e78793          	addi	a5,a5,-1938 # 8023f9e8 <bcache+0x8268>
    80003182:	04f48d63          	beq	s1,a5,800031dc <bread+0xe2>
    if(b->refcnt == 0) {
    80003186:	40bc                	lw	a5,64(s1)
    80003188:	cb91                	beqz	a5,8000319c <bread+0xa2>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000318a:	0023d717          	auipc	a4,0x23d
    8000318e:	85e70713          	addi	a4,a4,-1954 # 8023f9e8 <bcache+0x8268>
    80003192:	64a4                	ld	s1,72(s1)
    80003194:	04e48463          	beq	s1,a4,800031dc <bread+0xe2>
    if(b->refcnt == 0) {
    80003198:	40bc                	lw	a5,64(s1)
    8000319a:	ffe5                	bnez	a5,80003192 <bread+0x98>
      b->dev = dev;
    8000319c:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800031a0:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800031a4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031a8:	4785                	li	a5,1
    800031aa:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031ac:	00234517          	auipc	a0,0x234
    800031b0:	5d450513          	addi	a0,a0,1492 # 80237780 <bcache>
    800031b4:	ffffe097          	auipc	ra,0xffffe
    800031b8:	c5e080e7          	jalr	-930(ra) # 80000e12 <release>
      acquiresleep(&b->lock);
    800031bc:	01048513          	addi	a0,s1,16
    800031c0:	00001097          	auipc	ra,0x1
    800031c4:	468080e7          	jalr	1128(ra) # 80004628 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031c8:	409c                	lw	a5,0(s1)
    800031ca:	c38d                	beqz	a5,800031ec <bread+0xf2>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031cc:	8526                	mv	a0,s1
    800031ce:	70a2                	ld	ra,40(sp)
    800031d0:	7402                	ld	s0,32(sp)
    800031d2:	64e2                	ld	s1,24(sp)
    800031d4:	6942                	ld	s2,16(sp)
    800031d6:	69a2                	ld	s3,8(sp)
    800031d8:	6145                	addi	sp,sp,48
    800031da:	8082                	ret
  panic("bget: no buffers");
    800031dc:	00005517          	auipc	a0,0x5
    800031e0:	3f450513          	addi	a0,a0,1012 # 800085d0 <syscalls+0xe8>
    800031e4:	ffffd097          	auipc	ra,0xffffd
    800031e8:	390080e7          	jalr	912(ra) # 80000574 <panic>
    virtio_disk_rw(b, 0);
    800031ec:	4581                	li	a1,0
    800031ee:	8526                	mv	a0,s1
    800031f0:	00003097          	auipc	ra,0x3
    800031f4:	ffe080e7          	jalr	-2(ra) # 800061ee <virtio_disk_rw>
    b->valid = 1;
    800031f8:	4785                	li	a5,1
    800031fa:	c09c                	sw	a5,0(s1)
  return b;
    800031fc:	bfc1                	j	800031cc <bread+0xd2>

00000000800031fe <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031fe:	1101                	addi	sp,sp,-32
    80003200:	ec06                	sd	ra,24(sp)
    80003202:	e822                	sd	s0,16(sp)
    80003204:	e426                	sd	s1,8(sp)
    80003206:	1000                	addi	s0,sp,32
    80003208:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000320a:	0541                	addi	a0,a0,16
    8000320c:	00001097          	auipc	ra,0x1
    80003210:	4b6080e7          	jalr	1206(ra) # 800046c2 <holdingsleep>
    80003214:	cd01                	beqz	a0,8000322c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003216:	4585                	li	a1,1
    80003218:	8526                	mv	a0,s1
    8000321a:	00003097          	auipc	ra,0x3
    8000321e:	fd4080e7          	jalr	-44(ra) # 800061ee <virtio_disk_rw>
}
    80003222:	60e2                	ld	ra,24(sp)
    80003224:	6442                	ld	s0,16(sp)
    80003226:	64a2                	ld	s1,8(sp)
    80003228:	6105                	addi	sp,sp,32
    8000322a:	8082                	ret
    panic("bwrite");
    8000322c:	00005517          	auipc	a0,0x5
    80003230:	3bc50513          	addi	a0,a0,956 # 800085e8 <syscalls+0x100>
    80003234:	ffffd097          	auipc	ra,0xffffd
    80003238:	340080e7          	jalr	832(ra) # 80000574 <panic>

000000008000323c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000323c:	1101                	addi	sp,sp,-32
    8000323e:	ec06                	sd	ra,24(sp)
    80003240:	e822                	sd	s0,16(sp)
    80003242:	e426                	sd	s1,8(sp)
    80003244:	e04a                	sd	s2,0(sp)
    80003246:	1000                	addi	s0,sp,32
    80003248:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000324a:	01050913          	addi	s2,a0,16
    8000324e:	854a                	mv	a0,s2
    80003250:	00001097          	auipc	ra,0x1
    80003254:	472080e7          	jalr	1138(ra) # 800046c2 <holdingsleep>
    80003258:	c92d                	beqz	a0,800032ca <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000325a:	854a                	mv	a0,s2
    8000325c:	00001097          	auipc	ra,0x1
    80003260:	422080e7          	jalr	1058(ra) # 8000467e <releasesleep>

  acquire(&bcache.lock);
    80003264:	00234517          	auipc	a0,0x234
    80003268:	51c50513          	addi	a0,a0,1308 # 80237780 <bcache>
    8000326c:	ffffe097          	auipc	ra,0xffffe
    80003270:	af2080e7          	jalr	-1294(ra) # 80000d5e <acquire>
  b->refcnt--;
    80003274:	40bc                	lw	a5,64(s1)
    80003276:	37fd                	addiw	a5,a5,-1
    80003278:	0007871b          	sext.w	a4,a5
    8000327c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000327e:	eb05                	bnez	a4,800032ae <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003280:	68bc                	ld	a5,80(s1)
    80003282:	64b8                	ld	a4,72(s1)
    80003284:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003286:	64bc                	ld	a5,72(s1)
    80003288:	68b8                	ld	a4,80(s1)
    8000328a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000328c:	0023c797          	auipc	a5,0x23c
    80003290:	4f478793          	addi	a5,a5,1268 # 8023f780 <bcache+0x8000>
    80003294:	2b87b703          	ld	a4,696(a5)
    80003298:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000329a:	0023c717          	auipc	a4,0x23c
    8000329e:	74e70713          	addi	a4,a4,1870 # 8023f9e8 <bcache+0x8268>
    800032a2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800032a4:	2b87b703          	ld	a4,696(a5)
    800032a8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800032aa:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800032ae:	00234517          	auipc	a0,0x234
    800032b2:	4d250513          	addi	a0,a0,1234 # 80237780 <bcache>
    800032b6:	ffffe097          	auipc	ra,0xffffe
    800032ba:	b5c080e7          	jalr	-1188(ra) # 80000e12 <release>
}
    800032be:	60e2                	ld	ra,24(sp)
    800032c0:	6442                	ld	s0,16(sp)
    800032c2:	64a2                	ld	s1,8(sp)
    800032c4:	6902                	ld	s2,0(sp)
    800032c6:	6105                	addi	sp,sp,32
    800032c8:	8082                	ret
    panic("brelse");
    800032ca:	00005517          	auipc	a0,0x5
    800032ce:	32650513          	addi	a0,a0,806 # 800085f0 <syscalls+0x108>
    800032d2:	ffffd097          	auipc	ra,0xffffd
    800032d6:	2a2080e7          	jalr	674(ra) # 80000574 <panic>

00000000800032da <bpin>:

void
bpin(struct buf *b) {
    800032da:	1101                	addi	sp,sp,-32
    800032dc:	ec06                	sd	ra,24(sp)
    800032de:	e822                	sd	s0,16(sp)
    800032e0:	e426                	sd	s1,8(sp)
    800032e2:	1000                	addi	s0,sp,32
    800032e4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032e6:	00234517          	auipc	a0,0x234
    800032ea:	49a50513          	addi	a0,a0,1178 # 80237780 <bcache>
    800032ee:	ffffe097          	auipc	ra,0xffffe
    800032f2:	a70080e7          	jalr	-1424(ra) # 80000d5e <acquire>
  b->refcnt++;
    800032f6:	40bc                	lw	a5,64(s1)
    800032f8:	2785                	addiw	a5,a5,1
    800032fa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032fc:	00234517          	auipc	a0,0x234
    80003300:	48450513          	addi	a0,a0,1156 # 80237780 <bcache>
    80003304:	ffffe097          	auipc	ra,0xffffe
    80003308:	b0e080e7          	jalr	-1266(ra) # 80000e12 <release>
}
    8000330c:	60e2                	ld	ra,24(sp)
    8000330e:	6442                	ld	s0,16(sp)
    80003310:	64a2                	ld	s1,8(sp)
    80003312:	6105                	addi	sp,sp,32
    80003314:	8082                	ret

0000000080003316 <bunpin>:

void
bunpin(struct buf *b) {
    80003316:	1101                	addi	sp,sp,-32
    80003318:	ec06                	sd	ra,24(sp)
    8000331a:	e822                	sd	s0,16(sp)
    8000331c:	e426                	sd	s1,8(sp)
    8000331e:	1000                	addi	s0,sp,32
    80003320:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003322:	00234517          	auipc	a0,0x234
    80003326:	45e50513          	addi	a0,a0,1118 # 80237780 <bcache>
    8000332a:	ffffe097          	auipc	ra,0xffffe
    8000332e:	a34080e7          	jalr	-1484(ra) # 80000d5e <acquire>
  b->refcnt--;
    80003332:	40bc                	lw	a5,64(s1)
    80003334:	37fd                	addiw	a5,a5,-1
    80003336:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003338:	00234517          	auipc	a0,0x234
    8000333c:	44850513          	addi	a0,a0,1096 # 80237780 <bcache>
    80003340:	ffffe097          	auipc	ra,0xffffe
    80003344:	ad2080e7          	jalr	-1326(ra) # 80000e12 <release>
}
    80003348:	60e2                	ld	ra,24(sp)
    8000334a:	6442                	ld	s0,16(sp)
    8000334c:	64a2                	ld	s1,8(sp)
    8000334e:	6105                	addi	sp,sp,32
    80003350:	8082                	ret

0000000080003352 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003352:	1101                	addi	sp,sp,-32
    80003354:	ec06                	sd	ra,24(sp)
    80003356:	e822                	sd	s0,16(sp)
    80003358:	e426                	sd	s1,8(sp)
    8000335a:	e04a                	sd	s2,0(sp)
    8000335c:	1000                	addi	s0,sp,32
    8000335e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003360:	00d5d59b          	srliw	a1,a1,0xd
    80003364:	0023d797          	auipc	a5,0x23d
    80003368:	adc78793          	addi	a5,a5,-1316 # 8023fe40 <sb>
    8000336c:	4fdc                	lw	a5,28(a5)
    8000336e:	9dbd                	addw	a1,a1,a5
    80003370:	00000097          	auipc	ra,0x0
    80003374:	d8a080e7          	jalr	-630(ra) # 800030fa <bread>
  bi = b % BPB;
    80003378:	2481                	sext.w	s1,s1
  m = 1 << (bi % 8);
    8000337a:	0074f793          	andi	a5,s1,7
    8000337e:	4705                	li	a4,1
    80003380:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    80003384:	6789                	lui	a5,0x2
    80003386:	17fd                	addi	a5,a5,-1
    80003388:	8cfd                	and	s1,s1,a5
  if((bp->data[bi/8] & m) == 0)
    8000338a:	41f4d79b          	sraiw	a5,s1,0x1f
    8000338e:	01d7d79b          	srliw	a5,a5,0x1d
    80003392:	9fa5                	addw	a5,a5,s1
    80003394:	4037d79b          	sraiw	a5,a5,0x3
    80003398:	00f506b3          	add	a3,a0,a5
    8000339c:	0586c683          	lbu	a3,88(a3)
    800033a0:	00d77633          	and	a2,a4,a3
    800033a4:	c61d                	beqz	a2,800033d2 <bfree+0x80>
    800033a6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033a8:	97aa                	add	a5,a5,a0
    800033aa:	fff74713          	not	a4,a4
    800033ae:	8f75                	and	a4,a4,a3
    800033b0:	04e78c23          	sb	a4,88(a5) # 2058 <_entry-0x7fffdfa8>
  log_write(bp);
    800033b4:	00001097          	auipc	ra,0x1
    800033b8:	136080e7          	jalr	310(ra) # 800044ea <log_write>
  brelse(bp);
    800033bc:	854a                	mv	a0,s2
    800033be:	00000097          	auipc	ra,0x0
    800033c2:	e7e080e7          	jalr	-386(ra) # 8000323c <brelse>
}
    800033c6:	60e2                	ld	ra,24(sp)
    800033c8:	6442                	ld	s0,16(sp)
    800033ca:	64a2                	ld	s1,8(sp)
    800033cc:	6902                	ld	s2,0(sp)
    800033ce:	6105                	addi	sp,sp,32
    800033d0:	8082                	ret
    panic("freeing free block");
    800033d2:	00005517          	auipc	a0,0x5
    800033d6:	22650513          	addi	a0,a0,550 # 800085f8 <syscalls+0x110>
    800033da:	ffffd097          	auipc	ra,0xffffd
    800033de:	19a080e7          	jalr	410(ra) # 80000574 <panic>

00000000800033e2 <balloc>:
{
    800033e2:	711d                	addi	sp,sp,-96
    800033e4:	ec86                	sd	ra,88(sp)
    800033e6:	e8a2                	sd	s0,80(sp)
    800033e8:	e4a6                	sd	s1,72(sp)
    800033ea:	e0ca                	sd	s2,64(sp)
    800033ec:	fc4e                	sd	s3,56(sp)
    800033ee:	f852                	sd	s4,48(sp)
    800033f0:	f456                	sd	s5,40(sp)
    800033f2:	f05a                	sd	s6,32(sp)
    800033f4:	ec5e                	sd	s7,24(sp)
    800033f6:	e862                	sd	s8,16(sp)
    800033f8:	e466                	sd	s9,8(sp)
    800033fa:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033fc:	0023d797          	auipc	a5,0x23d
    80003400:	a4478793          	addi	a5,a5,-1468 # 8023fe40 <sb>
    80003404:	43dc                	lw	a5,4(a5)
    80003406:	10078e63          	beqz	a5,80003522 <balloc+0x140>
    8000340a:	8baa                	mv	s7,a0
    8000340c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000340e:	0023db17          	auipc	s6,0x23d
    80003412:	a32b0b13          	addi	s6,s6,-1486 # 8023fe40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003416:	4c05                	li	s8,1
      m = 1 << (bi % 8);
    80003418:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000341a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000341c:	6c89                	lui	s9,0x2
    8000341e:	a079                	j	800034ac <balloc+0xca>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003420:	8942                	mv	s2,a6
      m = 1 << (bi % 8);
    80003422:	4705                	li	a4,1
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003424:	4681                	li	a3,0
        bp->data[bi/8] |= m;  // Mark block in use.
    80003426:	96a6                	add	a3,a3,s1
    80003428:	8f51                	or	a4,a4,a2
    8000342a:	04e68c23          	sb	a4,88(a3)
        log_write(bp);
    8000342e:	8526                	mv	a0,s1
    80003430:	00001097          	auipc	ra,0x1
    80003434:	0ba080e7          	jalr	186(ra) # 800044ea <log_write>
        brelse(bp);
    80003438:	8526                	mv	a0,s1
    8000343a:	00000097          	auipc	ra,0x0
    8000343e:	e02080e7          	jalr	-510(ra) # 8000323c <brelse>
  bp = bread(dev, bno);
    80003442:	85ca                	mv	a1,s2
    80003444:	855e                	mv	a0,s7
    80003446:	00000097          	auipc	ra,0x0
    8000344a:	cb4080e7          	jalr	-844(ra) # 800030fa <bread>
    8000344e:	84aa                	mv	s1,a0
  memset(bp->data, 0, BSIZE);
    80003450:	40000613          	li	a2,1024
    80003454:	4581                	li	a1,0
    80003456:	05850513          	addi	a0,a0,88
    8000345a:	ffffe097          	auipc	ra,0xffffe
    8000345e:	a00080e7          	jalr	-1536(ra) # 80000e5a <memset>
  log_write(bp);
    80003462:	8526                	mv	a0,s1
    80003464:	00001097          	auipc	ra,0x1
    80003468:	086080e7          	jalr	134(ra) # 800044ea <log_write>
  brelse(bp);
    8000346c:	8526                	mv	a0,s1
    8000346e:	00000097          	auipc	ra,0x0
    80003472:	dce080e7          	jalr	-562(ra) # 8000323c <brelse>
}
    80003476:	854a                	mv	a0,s2
    80003478:	60e6                	ld	ra,88(sp)
    8000347a:	6446                	ld	s0,80(sp)
    8000347c:	64a6                	ld	s1,72(sp)
    8000347e:	6906                	ld	s2,64(sp)
    80003480:	79e2                	ld	s3,56(sp)
    80003482:	7a42                	ld	s4,48(sp)
    80003484:	7aa2                	ld	s5,40(sp)
    80003486:	7b02                	ld	s6,32(sp)
    80003488:	6be2                	ld	s7,24(sp)
    8000348a:	6c42                	ld	s8,16(sp)
    8000348c:	6ca2                	ld	s9,8(sp)
    8000348e:	6125                	addi	sp,sp,96
    80003490:	8082                	ret
    brelse(bp);
    80003492:	8526                	mv	a0,s1
    80003494:	00000097          	auipc	ra,0x0
    80003498:	da8080e7          	jalr	-600(ra) # 8000323c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000349c:	015c87bb          	addw	a5,s9,s5
    800034a0:	00078a9b          	sext.w	s5,a5
    800034a4:	004b2703          	lw	a4,4(s6)
    800034a8:	06eafd63          	bleu	a4,s5,80003522 <balloc+0x140>
    bp = bread(dev, BBLOCK(b, sb));
    800034ac:	41fad79b          	sraiw	a5,s5,0x1f
    800034b0:	0137d79b          	srliw	a5,a5,0x13
    800034b4:	015787bb          	addw	a5,a5,s5
    800034b8:	40d7d79b          	sraiw	a5,a5,0xd
    800034bc:	01cb2583          	lw	a1,28(s6)
    800034c0:	9dbd                	addw	a1,a1,a5
    800034c2:	855e                	mv	a0,s7
    800034c4:	00000097          	auipc	ra,0x0
    800034c8:	c36080e7          	jalr	-970(ra) # 800030fa <bread>
    800034cc:	84aa                	mv	s1,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034ce:	000a881b          	sext.w	a6,s5
    800034d2:	004b2503          	lw	a0,4(s6)
    800034d6:	faa87ee3          	bleu	a0,a6,80003492 <balloc+0xb0>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034da:	0584c603          	lbu	a2,88(s1)
    800034de:	00167793          	andi	a5,a2,1
    800034e2:	df9d                	beqz	a5,80003420 <balloc+0x3e>
    800034e4:	4105053b          	subw	a0,a0,a6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034e8:	87e2                	mv	a5,s8
    800034ea:	0107893b          	addw	s2,a5,a6
    800034ee:	faa782e3          	beq	a5,a0,80003492 <balloc+0xb0>
      m = 1 << (bi % 8);
    800034f2:	41f7d71b          	sraiw	a4,a5,0x1f
    800034f6:	01d7561b          	srliw	a2,a4,0x1d
    800034fa:	00f606bb          	addw	a3,a2,a5
    800034fe:	0076f713          	andi	a4,a3,7
    80003502:	9f11                	subw	a4,a4,a2
    80003504:	00e9973b          	sllw	a4,s3,a4
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003508:	4036d69b          	sraiw	a3,a3,0x3
    8000350c:	00d48633          	add	a2,s1,a3
    80003510:	05864603          	lbu	a2,88(a2)
    80003514:	00c775b3          	and	a1,a4,a2
    80003518:	d599                	beqz	a1,80003426 <balloc+0x44>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000351a:	2785                	addiw	a5,a5,1
    8000351c:	fd4797e3          	bne	a5,s4,800034ea <balloc+0x108>
    80003520:	bf8d                	j	80003492 <balloc+0xb0>
  panic("balloc: out of blocks");
    80003522:	00005517          	auipc	a0,0x5
    80003526:	0ee50513          	addi	a0,a0,238 # 80008610 <syscalls+0x128>
    8000352a:	ffffd097          	auipc	ra,0xffffd
    8000352e:	04a080e7          	jalr	74(ra) # 80000574 <panic>

0000000080003532 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003532:	7179                	addi	sp,sp,-48
    80003534:	f406                	sd	ra,40(sp)
    80003536:	f022                	sd	s0,32(sp)
    80003538:	ec26                	sd	s1,24(sp)
    8000353a:	e84a                	sd	s2,16(sp)
    8000353c:	e44e                	sd	s3,8(sp)
    8000353e:	e052                	sd	s4,0(sp)
    80003540:	1800                	addi	s0,sp,48
    80003542:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003544:	47ad                	li	a5,11
    80003546:	04b7fe63          	bleu	a1,a5,800035a2 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000354a:	ff45849b          	addiw	s1,a1,-12
    8000354e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003552:	0ff00793          	li	a5,255
    80003556:	0ae7e363          	bltu	a5,a4,800035fc <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000355a:	08052583          	lw	a1,128(a0)
    8000355e:	c5ad                	beqz	a1,800035c8 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003560:	0009a503          	lw	a0,0(s3)
    80003564:	00000097          	auipc	ra,0x0
    80003568:	b96080e7          	jalr	-1130(ra) # 800030fa <bread>
    8000356c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000356e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003572:	02049593          	slli	a1,s1,0x20
    80003576:	9181                	srli	a1,a1,0x20
    80003578:	058a                	slli	a1,a1,0x2
    8000357a:	00b784b3          	add	s1,a5,a1
    8000357e:	0004a903          	lw	s2,0(s1)
    80003582:	04090d63          	beqz	s2,800035dc <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003586:	8552                	mv	a0,s4
    80003588:	00000097          	auipc	ra,0x0
    8000358c:	cb4080e7          	jalr	-844(ra) # 8000323c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003590:	854a                	mv	a0,s2
    80003592:	70a2                	ld	ra,40(sp)
    80003594:	7402                	ld	s0,32(sp)
    80003596:	64e2                	ld	s1,24(sp)
    80003598:	6942                	ld	s2,16(sp)
    8000359a:	69a2                	ld	s3,8(sp)
    8000359c:	6a02                	ld	s4,0(sp)
    8000359e:	6145                	addi	sp,sp,48
    800035a0:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800035a2:	02059493          	slli	s1,a1,0x20
    800035a6:	9081                	srli	s1,s1,0x20
    800035a8:	048a                	slli	s1,s1,0x2
    800035aa:	94aa                	add	s1,s1,a0
    800035ac:	0504a903          	lw	s2,80(s1)
    800035b0:	fe0910e3          	bnez	s2,80003590 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800035b4:	4108                	lw	a0,0(a0)
    800035b6:	00000097          	auipc	ra,0x0
    800035ba:	e2c080e7          	jalr	-468(ra) # 800033e2 <balloc>
    800035be:	0005091b          	sext.w	s2,a0
    800035c2:	0524a823          	sw	s2,80(s1)
    800035c6:	b7e9                	j	80003590 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800035c8:	4108                	lw	a0,0(a0)
    800035ca:	00000097          	auipc	ra,0x0
    800035ce:	e18080e7          	jalr	-488(ra) # 800033e2 <balloc>
    800035d2:	0005059b          	sext.w	a1,a0
    800035d6:	08b9a023          	sw	a1,128(s3)
    800035da:	b759                	j	80003560 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800035dc:	0009a503          	lw	a0,0(s3)
    800035e0:	00000097          	auipc	ra,0x0
    800035e4:	e02080e7          	jalr	-510(ra) # 800033e2 <balloc>
    800035e8:	0005091b          	sext.w	s2,a0
    800035ec:	0124a023          	sw	s2,0(s1)
      log_write(bp);
    800035f0:	8552                	mv	a0,s4
    800035f2:	00001097          	auipc	ra,0x1
    800035f6:	ef8080e7          	jalr	-264(ra) # 800044ea <log_write>
    800035fa:	b771                	j	80003586 <bmap+0x54>
  panic("bmap: out of range");
    800035fc:	00005517          	auipc	a0,0x5
    80003600:	02c50513          	addi	a0,a0,44 # 80008628 <syscalls+0x140>
    80003604:	ffffd097          	auipc	ra,0xffffd
    80003608:	f70080e7          	jalr	-144(ra) # 80000574 <panic>

000000008000360c <iget>:
{
    8000360c:	7179                	addi	sp,sp,-48
    8000360e:	f406                	sd	ra,40(sp)
    80003610:	f022                	sd	s0,32(sp)
    80003612:	ec26                	sd	s1,24(sp)
    80003614:	e84a                	sd	s2,16(sp)
    80003616:	e44e                	sd	s3,8(sp)
    80003618:	e052                	sd	s4,0(sp)
    8000361a:	1800                	addi	s0,sp,48
    8000361c:	89aa                	mv	s3,a0
    8000361e:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003620:	0023d517          	auipc	a0,0x23d
    80003624:	84050513          	addi	a0,a0,-1984 # 8023fe60 <icache>
    80003628:	ffffd097          	auipc	ra,0xffffd
    8000362c:	736080e7          	jalr	1846(ra) # 80000d5e <acquire>
  empty = 0;
    80003630:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003632:	0023d497          	auipc	s1,0x23d
    80003636:	84648493          	addi	s1,s1,-1978 # 8023fe78 <icache+0x18>
    8000363a:	0023e697          	auipc	a3,0x23e
    8000363e:	2ce68693          	addi	a3,a3,718 # 80241908 <log>
    80003642:	a039                	j	80003650 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003644:	02090b63          	beqz	s2,8000367a <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003648:	08848493          	addi	s1,s1,136
    8000364c:	02d48a63          	beq	s1,a3,80003680 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003650:	449c                	lw	a5,8(s1)
    80003652:	fef059e3          	blez	a5,80003644 <iget+0x38>
    80003656:	4098                	lw	a4,0(s1)
    80003658:	ff3716e3          	bne	a4,s3,80003644 <iget+0x38>
    8000365c:	40d8                	lw	a4,4(s1)
    8000365e:	ff4713e3          	bne	a4,s4,80003644 <iget+0x38>
      ip->ref++;
    80003662:	2785                	addiw	a5,a5,1
    80003664:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003666:	0023c517          	auipc	a0,0x23c
    8000366a:	7fa50513          	addi	a0,a0,2042 # 8023fe60 <icache>
    8000366e:	ffffd097          	auipc	ra,0xffffd
    80003672:	7a4080e7          	jalr	1956(ra) # 80000e12 <release>
      return ip;
    80003676:	8926                	mv	s2,s1
    80003678:	a03d                	j	800036a6 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000367a:	f7f9                	bnez	a5,80003648 <iget+0x3c>
    8000367c:	8926                	mv	s2,s1
    8000367e:	b7e9                	j	80003648 <iget+0x3c>
  if(empty == 0)
    80003680:	02090c63          	beqz	s2,800036b8 <iget+0xac>
  ip->dev = dev;
    80003684:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003688:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000368c:	4785                	li	a5,1
    8000368e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003692:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003696:	0023c517          	auipc	a0,0x23c
    8000369a:	7ca50513          	addi	a0,a0,1994 # 8023fe60 <icache>
    8000369e:	ffffd097          	auipc	ra,0xffffd
    800036a2:	774080e7          	jalr	1908(ra) # 80000e12 <release>
}
    800036a6:	854a                	mv	a0,s2
    800036a8:	70a2                	ld	ra,40(sp)
    800036aa:	7402                	ld	s0,32(sp)
    800036ac:	64e2                	ld	s1,24(sp)
    800036ae:	6942                	ld	s2,16(sp)
    800036b0:	69a2                	ld	s3,8(sp)
    800036b2:	6a02                	ld	s4,0(sp)
    800036b4:	6145                	addi	sp,sp,48
    800036b6:	8082                	ret
    panic("iget: no inodes");
    800036b8:	00005517          	auipc	a0,0x5
    800036bc:	f8850513          	addi	a0,a0,-120 # 80008640 <syscalls+0x158>
    800036c0:	ffffd097          	auipc	ra,0xffffd
    800036c4:	eb4080e7          	jalr	-332(ra) # 80000574 <panic>

00000000800036c8 <fsinit>:
fsinit(int dev) {
    800036c8:	7179                	addi	sp,sp,-48
    800036ca:	f406                	sd	ra,40(sp)
    800036cc:	f022                	sd	s0,32(sp)
    800036ce:	ec26                	sd	s1,24(sp)
    800036d0:	e84a                	sd	s2,16(sp)
    800036d2:	e44e                	sd	s3,8(sp)
    800036d4:	1800                	addi	s0,sp,48
    800036d6:	89aa                	mv	s3,a0
  bp = bread(dev, 1);
    800036d8:	4585                	li	a1,1
    800036da:	00000097          	auipc	ra,0x0
    800036de:	a20080e7          	jalr	-1504(ra) # 800030fa <bread>
    800036e2:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036e4:	0023c497          	auipc	s1,0x23c
    800036e8:	75c48493          	addi	s1,s1,1884 # 8023fe40 <sb>
    800036ec:	02000613          	li	a2,32
    800036f0:	05850593          	addi	a1,a0,88
    800036f4:	8526                	mv	a0,s1
    800036f6:	ffffd097          	auipc	ra,0xffffd
    800036fa:	7d0080e7          	jalr	2000(ra) # 80000ec6 <memmove>
  brelse(bp);
    800036fe:	854a                	mv	a0,s2
    80003700:	00000097          	auipc	ra,0x0
    80003704:	b3c080e7          	jalr	-1220(ra) # 8000323c <brelse>
  if(sb.magic != FSMAGIC)
    80003708:	4098                	lw	a4,0(s1)
    8000370a:	102037b7          	lui	a5,0x10203
    8000370e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003712:	02f71263          	bne	a4,a5,80003736 <fsinit+0x6e>
  initlog(dev, &sb);
    80003716:	0023c597          	auipc	a1,0x23c
    8000371a:	72a58593          	addi	a1,a1,1834 # 8023fe40 <sb>
    8000371e:	854e                	mv	a0,s3
    80003720:	00001097          	auipc	ra,0x1
    80003724:	b4c080e7          	jalr	-1204(ra) # 8000426c <initlog>
}
    80003728:	70a2                	ld	ra,40(sp)
    8000372a:	7402                	ld	s0,32(sp)
    8000372c:	64e2                	ld	s1,24(sp)
    8000372e:	6942                	ld	s2,16(sp)
    80003730:	69a2                	ld	s3,8(sp)
    80003732:	6145                	addi	sp,sp,48
    80003734:	8082                	ret
    panic("invalid file system");
    80003736:	00005517          	auipc	a0,0x5
    8000373a:	f1a50513          	addi	a0,a0,-230 # 80008650 <syscalls+0x168>
    8000373e:	ffffd097          	auipc	ra,0xffffd
    80003742:	e36080e7          	jalr	-458(ra) # 80000574 <panic>

0000000080003746 <iinit>:
{
    80003746:	7179                	addi	sp,sp,-48
    80003748:	f406                	sd	ra,40(sp)
    8000374a:	f022                	sd	s0,32(sp)
    8000374c:	ec26                	sd	s1,24(sp)
    8000374e:	e84a                	sd	s2,16(sp)
    80003750:	e44e                	sd	s3,8(sp)
    80003752:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003754:	00005597          	auipc	a1,0x5
    80003758:	f1458593          	addi	a1,a1,-236 # 80008668 <syscalls+0x180>
    8000375c:	0023c517          	auipc	a0,0x23c
    80003760:	70450513          	addi	a0,a0,1796 # 8023fe60 <icache>
    80003764:	ffffd097          	auipc	ra,0xffffd
    80003768:	56a080e7          	jalr	1386(ra) # 80000cce <initlock>
  for(i = 0; i < NINODE; i++) {
    8000376c:	0023c497          	auipc	s1,0x23c
    80003770:	71c48493          	addi	s1,s1,1820 # 8023fe88 <icache+0x28>
    80003774:	0023e997          	auipc	s3,0x23e
    80003778:	1a498993          	addi	s3,s3,420 # 80241918 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    8000377c:	00005917          	auipc	s2,0x5
    80003780:	ef490913          	addi	s2,s2,-268 # 80008670 <syscalls+0x188>
    80003784:	85ca                	mv	a1,s2
    80003786:	8526                	mv	a0,s1
    80003788:	00001097          	auipc	ra,0x1
    8000378c:	e66080e7          	jalr	-410(ra) # 800045ee <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003790:	08848493          	addi	s1,s1,136
    80003794:	ff3498e3          	bne	s1,s3,80003784 <iinit+0x3e>
}
    80003798:	70a2                	ld	ra,40(sp)
    8000379a:	7402                	ld	s0,32(sp)
    8000379c:	64e2                	ld	s1,24(sp)
    8000379e:	6942                	ld	s2,16(sp)
    800037a0:	69a2                	ld	s3,8(sp)
    800037a2:	6145                	addi	sp,sp,48
    800037a4:	8082                	ret

00000000800037a6 <ialloc>:
{
    800037a6:	715d                	addi	sp,sp,-80
    800037a8:	e486                	sd	ra,72(sp)
    800037aa:	e0a2                	sd	s0,64(sp)
    800037ac:	fc26                	sd	s1,56(sp)
    800037ae:	f84a                	sd	s2,48(sp)
    800037b0:	f44e                	sd	s3,40(sp)
    800037b2:	f052                	sd	s4,32(sp)
    800037b4:	ec56                	sd	s5,24(sp)
    800037b6:	e85a                	sd	s6,16(sp)
    800037b8:	e45e                	sd	s7,8(sp)
    800037ba:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800037bc:	0023c797          	auipc	a5,0x23c
    800037c0:	68478793          	addi	a5,a5,1668 # 8023fe40 <sb>
    800037c4:	47d8                	lw	a4,12(a5)
    800037c6:	4785                	li	a5,1
    800037c8:	04e7fa63          	bleu	a4,a5,8000381c <ialloc+0x76>
    800037cc:	8a2a                	mv	s4,a0
    800037ce:	8b2e                	mv	s6,a1
    800037d0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037d2:	0023c997          	auipc	s3,0x23c
    800037d6:	66e98993          	addi	s3,s3,1646 # 8023fe40 <sb>
    800037da:	00048a9b          	sext.w	s5,s1
    800037de:	0044d593          	srli	a1,s1,0x4
    800037e2:	0189a783          	lw	a5,24(s3)
    800037e6:	9dbd                	addw	a1,a1,a5
    800037e8:	8552                	mv	a0,s4
    800037ea:	00000097          	auipc	ra,0x0
    800037ee:	910080e7          	jalr	-1776(ra) # 800030fa <bread>
    800037f2:	8baa                	mv	s7,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037f4:	05850913          	addi	s2,a0,88
    800037f8:	00f4f793          	andi	a5,s1,15
    800037fc:	079a                	slli	a5,a5,0x6
    800037fe:	993e                	add	s2,s2,a5
    if(dip->type == 0){  // a free inode
    80003800:	00091783          	lh	a5,0(s2)
    80003804:	c785                	beqz	a5,8000382c <ialloc+0x86>
    brelse(bp);
    80003806:	00000097          	auipc	ra,0x0
    8000380a:	a36080e7          	jalr	-1482(ra) # 8000323c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000380e:	0485                	addi	s1,s1,1
    80003810:	00c9a703          	lw	a4,12(s3)
    80003814:	0004879b          	sext.w	a5,s1
    80003818:	fce7e1e3          	bltu	a5,a4,800037da <ialloc+0x34>
  panic("ialloc: no inodes");
    8000381c:	00005517          	auipc	a0,0x5
    80003820:	e5c50513          	addi	a0,a0,-420 # 80008678 <syscalls+0x190>
    80003824:	ffffd097          	auipc	ra,0xffffd
    80003828:	d50080e7          	jalr	-688(ra) # 80000574 <panic>
      memset(dip, 0, sizeof(*dip));
    8000382c:	04000613          	li	a2,64
    80003830:	4581                	li	a1,0
    80003832:	854a                	mv	a0,s2
    80003834:	ffffd097          	auipc	ra,0xffffd
    80003838:	626080e7          	jalr	1574(ra) # 80000e5a <memset>
      dip->type = type;
    8000383c:	01691023          	sh	s6,0(s2)
      log_write(bp);   // mark it allocated on the disk
    80003840:	855e                	mv	a0,s7
    80003842:	00001097          	auipc	ra,0x1
    80003846:	ca8080e7          	jalr	-856(ra) # 800044ea <log_write>
      brelse(bp);
    8000384a:	855e                	mv	a0,s7
    8000384c:	00000097          	auipc	ra,0x0
    80003850:	9f0080e7          	jalr	-1552(ra) # 8000323c <brelse>
      return iget(dev, inum);
    80003854:	85d6                	mv	a1,s5
    80003856:	8552                	mv	a0,s4
    80003858:	00000097          	auipc	ra,0x0
    8000385c:	db4080e7          	jalr	-588(ra) # 8000360c <iget>
}
    80003860:	60a6                	ld	ra,72(sp)
    80003862:	6406                	ld	s0,64(sp)
    80003864:	74e2                	ld	s1,56(sp)
    80003866:	7942                	ld	s2,48(sp)
    80003868:	79a2                	ld	s3,40(sp)
    8000386a:	7a02                	ld	s4,32(sp)
    8000386c:	6ae2                	ld	s5,24(sp)
    8000386e:	6b42                	ld	s6,16(sp)
    80003870:	6ba2                	ld	s7,8(sp)
    80003872:	6161                	addi	sp,sp,80
    80003874:	8082                	ret

0000000080003876 <iupdate>:
{
    80003876:	1101                	addi	sp,sp,-32
    80003878:	ec06                	sd	ra,24(sp)
    8000387a:	e822                	sd	s0,16(sp)
    8000387c:	e426                	sd	s1,8(sp)
    8000387e:	e04a                	sd	s2,0(sp)
    80003880:	1000                	addi	s0,sp,32
    80003882:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003884:	415c                	lw	a5,4(a0)
    80003886:	0047d79b          	srliw	a5,a5,0x4
    8000388a:	0023c717          	auipc	a4,0x23c
    8000388e:	5b670713          	addi	a4,a4,1462 # 8023fe40 <sb>
    80003892:	4f0c                	lw	a1,24(a4)
    80003894:	9dbd                	addw	a1,a1,a5
    80003896:	4108                	lw	a0,0(a0)
    80003898:	00000097          	auipc	ra,0x0
    8000389c:	862080e7          	jalr	-1950(ra) # 800030fa <bread>
    800038a0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038a2:	05850513          	addi	a0,a0,88
    800038a6:	40dc                	lw	a5,4(s1)
    800038a8:	8bbd                	andi	a5,a5,15
    800038aa:	079a                	slli	a5,a5,0x6
    800038ac:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800038ae:	04449783          	lh	a5,68(s1)
    800038b2:	00f51023          	sh	a5,0(a0)
  dip->major = ip->major;
    800038b6:	04649783          	lh	a5,70(s1)
    800038ba:	00f51123          	sh	a5,2(a0)
  dip->minor = ip->minor;
    800038be:	04849783          	lh	a5,72(s1)
    800038c2:	00f51223          	sh	a5,4(a0)
  dip->nlink = ip->nlink;
    800038c6:	04a49783          	lh	a5,74(s1)
    800038ca:	00f51323          	sh	a5,6(a0)
  dip->size = ip->size;
    800038ce:	44fc                	lw	a5,76(s1)
    800038d0:	c51c                	sw	a5,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038d2:	03400613          	li	a2,52
    800038d6:	05048593          	addi	a1,s1,80
    800038da:	0531                	addi	a0,a0,12
    800038dc:	ffffd097          	auipc	ra,0xffffd
    800038e0:	5ea080e7          	jalr	1514(ra) # 80000ec6 <memmove>
  log_write(bp);
    800038e4:	854a                	mv	a0,s2
    800038e6:	00001097          	auipc	ra,0x1
    800038ea:	c04080e7          	jalr	-1020(ra) # 800044ea <log_write>
  brelse(bp);
    800038ee:	854a                	mv	a0,s2
    800038f0:	00000097          	auipc	ra,0x0
    800038f4:	94c080e7          	jalr	-1716(ra) # 8000323c <brelse>
}
    800038f8:	60e2                	ld	ra,24(sp)
    800038fa:	6442                	ld	s0,16(sp)
    800038fc:	64a2                	ld	s1,8(sp)
    800038fe:	6902                	ld	s2,0(sp)
    80003900:	6105                	addi	sp,sp,32
    80003902:	8082                	ret

0000000080003904 <idup>:
{
    80003904:	1101                	addi	sp,sp,-32
    80003906:	ec06                	sd	ra,24(sp)
    80003908:	e822                	sd	s0,16(sp)
    8000390a:	e426                	sd	s1,8(sp)
    8000390c:	1000                	addi	s0,sp,32
    8000390e:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003910:	0023c517          	auipc	a0,0x23c
    80003914:	55050513          	addi	a0,a0,1360 # 8023fe60 <icache>
    80003918:	ffffd097          	auipc	ra,0xffffd
    8000391c:	446080e7          	jalr	1094(ra) # 80000d5e <acquire>
  ip->ref++;
    80003920:	449c                	lw	a5,8(s1)
    80003922:	2785                	addiw	a5,a5,1
    80003924:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003926:	0023c517          	auipc	a0,0x23c
    8000392a:	53a50513          	addi	a0,a0,1338 # 8023fe60 <icache>
    8000392e:	ffffd097          	auipc	ra,0xffffd
    80003932:	4e4080e7          	jalr	1252(ra) # 80000e12 <release>
}
    80003936:	8526                	mv	a0,s1
    80003938:	60e2                	ld	ra,24(sp)
    8000393a:	6442                	ld	s0,16(sp)
    8000393c:	64a2                	ld	s1,8(sp)
    8000393e:	6105                	addi	sp,sp,32
    80003940:	8082                	ret

0000000080003942 <ilock>:
{
    80003942:	1101                	addi	sp,sp,-32
    80003944:	ec06                	sd	ra,24(sp)
    80003946:	e822                	sd	s0,16(sp)
    80003948:	e426                	sd	s1,8(sp)
    8000394a:	e04a                	sd	s2,0(sp)
    8000394c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000394e:	c115                	beqz	a0,80003972 <ilock+0x30>
    80003950:	84aa                	mv	s1,a0
    80003952:	451c                	lw	a5,8(a0)
    80003954:	00f05f63          	blez	a5,80003972 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003958:	0541                	addi	a0,a0,16
    8000395a:	00001097          	auipc	ra,0x1
    8000395e:	cce080e7          	jalr	-818(ra) # 80004628 <acquiresleep>
  if(ip->valid == 0){
    80003962:	40bc                	lw	a5,64(s1)
    80003964:	cf99                	beqz	a5,80003982 <ilock+0x40>
}
    80003966:	60e2                	ld	ra,24(sp)
    80003968:	6442                	ld	s0,16(sp)
    8000396a:	64a2                	ld	s1,8(sp)
    8000396c:	6902                	ld	s2,0(sp)
    8000396e:	6105                	addi	sp,sp,32
    80003970:	8082                	ret
    panic("ilock");
    80003972:	00005517          	auipc	a0,0x5
    80003976:	d1e50513          	addi	a0,a0,-738 # 80008690 <syscalls+0x1a8>
    8000397a:	ffffd097          	auipc	ra,0xffffd
    8000397e:	bfa080e7          	jalr	-1030(ra) # 80000574 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003982:	40dc                	lw	a5,4(s1)
    80003984:	0047d79b          	srliw	a5,a5,0x4
    80003988:	0023c717          	auipc	a4,0x23c
    8000398c:	4b870713          	addi	a4,a4,1208 # 8023fe40 <sb>
    80003990:	4f0c                	lw	a1,24(a4)
    80003992:	9dbd                	addw	a1,a1,a5
    80003994:	4088                	lw	a0,0(s1)
    80003996:	fffff097          	auipc	ra,0xfffff
    8000399a:	764080e7          	jalr	1892(ra) # 800030fa <bread>
    8000399e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039a0:	05850593          	addi	a1,a0,88
    800039a4:	40dc                	lw	a5,4(s1)
    800039a6:	8bbd                	andi	a5,a5,15
    800039a8:	079a                	slli	a5,a5,0x6
    800039aa:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800039ac:	00059783          	lh	a5,0(a1)
    800039b0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800039b4:	00259783          	lh	a5,2(a1)
    800039b8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039bc:	00459783          	lh	a5,4(a1)
    800039c0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039c4:	00659783          	lh	a5,6(a1)
    800039c8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039cc:	459c                	lw	a5,8(a1)
    800039ce:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039d0:	03400613          	li	a2,52
    800039d4:	05b1                	addi	a1,a1,12
    800039d6:	05048513          	addi	a0,s1,80
    800039da:	ffffd097          	auipc	ra,0xffffd
    800039de:	4ec080e7          	jalr	1260(ra) # 80000ec6 <memmove>
    brelse(bp);
    800039e2:	854a                	mv	a0,s2
    800039e4:	00000097          	auipc	ra,0x0
    800039e8:	858080e7          	jalr	-1960(ra) # 8000323c <brelse>
    ip->valid = 1;
    800039ec:	4785                	li	a5,1
    800039ee:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039f0:	04449783          	lh	a5,68(s1)
    800039f4:	fbad                	bnez	a5,80003966 <ilock+0x24>
      panic("ilock: no type");
    800039f6:	00005517          	auipc	a0,0x5
    800039fa:	ca250513          	addi	a0,a0,-862 # 80008698 <syscalls+0x1b0>
    800039fe:	ffffd097          	auipc	ra,0xffffd
    80003a02:	b76080e7          	jalr	-1162(ra) # 80000574 <panic>

0000000080003a06 <iunlock>:
{
    80003a06:	1101                	addi	sp,sp,-32
    80003a08:	ec06                	sd	ra,24(sp)
    80003a0a:	e822                	sd	s0,16(sp)
    80003a0c:	e426                	sd	s1,8(sp)
    80003a0e:	e04a                	sd	s2,0(sp)
    80003a10:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a12:	c905                	beqz	a0,80003a42 <iunlock+0x3c>
    80003a14:	84aa                	mv	s1,a0
    80003a16:	01050913          	addi	s2,a0,16
    80003a1a:	854a                	mv	a0,s2
    80003a1c:	00001097          	auipc	ra,0x1
    80003a20:	ca6080e7          	jalr	-858(ra) # 800046c2 <holdingsleep>
    80003a24:	cd19                	beqz	a0,80003a42 <iunlock+0x3c>
    80003a26:	449c                	lw	a5,8(s1)
    80003a28:	00f05d63          	blez	a5,80003a42 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a2c:	854a                	mv	a0,s2
    80003a2e:	00001097          	auipc	ra,0x1
    80003a32:	c50080e7          	jalr	-944(ra) # 8000467e <releasesleep>
}
    80003a36:	60e2                	ld	ra,24(sp)
    80003a38:	6442                	ld	s0,16(sp)
    80003a3a:	64a2                	ld	s1,8(sp)
    80003a3c:	6902                	ld	s2,0(sp)
    80003a3e:	6105                	addi	sp,sp,32
    80003a40:	8082                	ret
    panic("iunlock");
    80003a42:	00005517          	auipc	a0,0x5
    80003a46:	c6650513          	addi	a0,a0,-922 # 800086a8 <syscalls+0x1c0>
    80003a4a:	ffffd097          	auipc	ra,0xffffd
    80003a4e:	b2a080e7          	jalr	-1238(ra) # 80000574 <panic>

0000000080003a52 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a52:	7179                	addi	sp,sp,-48
    80003a54:	f406                	sd	ra,40(sp)
    80003a56:	f022                	sd	s0,32(sp)
    80003a58:	ec26                	sd	s1,24(sp)
    80003a5a:	e84a                	sd	s2,16(sp)
    80003a5c:	e44e                	sd	s3,8(sp)
    80003a5e:	e052                	sd	s4,0(sp)
    80003a60:	1800                	addi	s0,sp,48
    80003a62:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a64:	05050493          	addi	s1,a0,80
    80003a68:	08050913          	addi	s2,a0,128
    80003a6c:	a821                	j	80003a84 <itrunc+0x32>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    80003a6e:	0009a503          	lw	a0,0(s3)
    80003a72:	00000097          	auipc	ra,0x0
    80003a76:	8e0080e7          	jalr	-1824(ra) # 80003352 <bfree>
      ip->addrs[i] = 0;
    80003a7a:	0004a023          	sw	zero,0(s1)
  for(i = 0; i < NDIRECT; i++){
    80003a7e:	0491                	addi	s1,s1,4
    80003a80:	01248563          	beq	s1,s2,80003a8a <itrunc+0x38>
    if(ip->addrs[i]){
    80003a84:	408c                	lw	a1,0(s1)
    80003a86:	dde5                	beqz	a1,80003a7e <itrunc+0x2c>
    80003a88:	b7dd                	j	80003a6e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a8a:	0809a583          	lw	a1,128(s3)
    80003a8e:	e185                	bnez	a1,80003aae <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a90:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a94:	854e                	mv	a0,s3
    80003a96:	00000097          	auipc	ra,0x0
    80003a9a:	de0080e7          	jalr	-544(ra) # 80003876 <iupdate>
}
    80003a9e:	70a2                	ld	ra,40(sp)
    80003aa0:	7402                	ld	s0,32(sp)
    80003aa2:	64e2                	ld	s1,24(sp)
    80003aa4:	6942                	ld	s2,16(sp)
    80003aa6:	69a2                	ld	s3,8(sp)
    80003aa8:	6a02                	ld	s4,0(sp)
    80003aaa:	6145                	addi	sp,sp,48
    80003aac:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003aae:	0009a503          	lw	a0,0(s3)
    80003ab2:	fffff097          	auipc	ra,0xfffff
    80003ab6:	648080e7          	jalr	1608(ra) # 800030fa <bread>
    80003aba:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003abc:	05850493          	addi	s1,a0,88
    80003ac0:	45850913          	addi	s2,a0,1112
    80003ac4:	a811                	j	80003ad8 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003ac6:	0009a503          	lw	a0,0(s3)
    80003aca:	00000097          	auipc	ra,0x0
    80003ace:	888080e7          	jalr	-1912(ra) # 80003352 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003ad2:	0491                	addi	s1,s1,4
    80003ad4:	01248563          	beq	s1,s2,80003ade <itrunc+0x8c>
      if(a[j])
    80003ad8:	408c                	lw	a1,0(s1)
    80003ada:	dde5                	beqz	a1,80003ad2 <itrunc+0x80>
    80003adc:	b7ed                	j	80003ac6 <itrunc+0x74>
    brelse(bp);
    80003ade:	8552                	mv	a0,s4
    80003ae0:	fffff097          	auipc	ra,0xfffff
    80003ae4:	75c080e7          	jalr	1884(ra) # 8000323c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ae8:	0809a583          	lw	a1,128(s3)
    80003aec:	0009a503          	lw	a0,0(s3)
    80003af0:	00000097          	auipc	ra,0x0
    80003af4:	862080e7          	jalr	-1950(ra) # 80003352 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003af8:	0809a023          	sw	zero,128(s3)
    80003afc:	bf51                	j	80003a90 <itrunc+0x3e>

0000000080003afe <iput>:
{
    80003afe:	1101                	addi	sp,sp,-32
    80003b00:	ec06                	sd	ra,24(sp)
    80003b02:	e822                	sd	s0,16(sp)
    80003b04:	e426                	sd	s1,8(sp)
    80003b06:	e04a                	sd	s2,0(sp)
    80003b08:	1000                	addi	s0,sp,32
    80003b0a:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003b0c:	0023c517          	auipc	a0,0x23c
    80003b10:	35450513          	addi	a0,a0,852 # 8023fe60 <icache>
    80003b14:	ffffd097          	auipc	ra,0xffffd
    80003b18:	24a080e7          	jalr	586(ra) # 80000d5e <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b1c:	4498                	lw	a4,8(s1)
    80003b1e:	4785                	li	a5,1
    80003b20:	02f70363          	beq	a4,a5,80003b46 <iput+0x48>
  ip->ref--;
    80003b24:	449c                	lw	a5,8(s1)
    80003b26:	37fd                	addiw	a5,a5,-1
    80003b28:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003b2a:	0023c517          	auipc	a0,0x23c
    80003b2e:	33650513          	addi	a0,a0,822 # 8023fe60 <icache>
    80003b32:	ffffd097          	auipc	ra,0xffffd
    80003b36:	2e0080e7          	jalr	736(ra) # 80000e12 <release>
}
    80003b3a:	60e2                	ld	ra,24(sp)
    80003b3c:	6442                	ld	s0,16(sp)
    80003b3e:	64a2                	ld	s1,8(sp)
    80003b40:	6902                	ld	s2,0(sp)
    80003b42:	6105                	addi	sp,sp,32
    80003b44:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b46:	40bc                	lw	a5,64(s1)
    80003b48:	dff1                	beqz	a5,80003b24 <iput+0x26>
    80003b4a:	04a49783          	lh	a5,74(s1)
    80003b4e:	fbf9                	bnez	a5,80003b24 <iput+0x26>
    acquiresleep(&ip->lock);
    80003b50:	01048913          	addi	s2,s1,16
    80003b54:	854a                	mv	a0,s2
    80003b56:	00001097          	auipc	ra,0x1
    80003b5a:	ad2080e7          	jalr	-1326(ra) # 80004628 <acquiresleep>
    release(&icache.lock);
    80003b5e:	0023c517          	auipc	a0,0x23c
    80003b62:	30250513          	addi	a0,a0,770 # 8023fe60 <icache>
    80003b66:	ffffd097          	auipc	ra,0xffffd
    80003b6a:	2ac080e7          	jalr	684(ra) # 80000e12 <release>
    itrunc(ip);
    80003b6e:	8526                	mv	a0,s1
    80003b70:	00000097          	auipc	ra,0x0
    80003b74:	ee2080e7          	jalr	-286(ra) # 80003a52 <itrunc>
    ip->type = 0;
    80003b78:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b7c:	8526                	mv	a0,s1
    80003b7e:	00000097          	auipc	ra,0x0
    80003b82:	cf8080e7          	jalr	-776(ra) # 80003876 <iupdate>
    ip->valid = 0;
    80003b86:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b8a:	854a                	mv	a0,s2
    80003b8c:	00001097          	auipc	ra,0x1
    80003b90:	af2080e7          	jalr	-1294(ra) # 8000467e <releasesleep>
    acquire(&icache.lock);
    80003b94:	0023c517          	auipc	a0,0x23c
    80003b98:	2cc50513          	addi	a0,a0,716 # 8023fe60 <icache>
    80003b9c:	ffffd097          	auipc	ra,0xffffd
    80003ba0:	1c2080e7          	jalr	450(ra) # 80000d5e <acquire>
    80003ba4:	b741                	j	80003b24 <iput+0x26>

0000000080003ba6 <iunlockput>:
{
    80003ba6:	1101                	addi	sp,sp,-32
    80003ba8:	ec06                	sd	ra,24(sp)
    80003baa:	e822                	sd	s0,16(sp)
    80003bac:	e426                	sd	s1,8(sp)
    80003bae:	1000                	addi	s0,sp,32
    80003bb0:	84aa                	mv	s1,a0
  iunlock(ip);
    80003bb2:	00000097          	auipc	ra,0x0
    80003bb6:	e54080e7          	jalr	-428(ra) # 80003a06 <iunlock>
  iput(ip);
    80003bba:	8526                	mv	a0,s1
    80003bbc:	00000097          	auipc	ra,0x0
    80003bc0:	f42080e7          	jalr	-190(ra) # 80003afe <iput>
}
    80003bc4:	60e2                	ld	ra,24(sp)
    80003bc6:	6442                	ld	s0,16(sp)
    80003bc8:	64a2                	ld	s1,8(sp)
    80003bca:	6105                	addi	sp,sp,32
    80003bcc:	8082                	ret

0000000080003bce <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003bce:	1141                	addi	sp,sp,-16
    80003bd0:	e422                	sd	s0,8(sp)
    80003bd2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003bd4:	411c                	lw	a5,0(a0)
    80003bd6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bd8:	415c                	lw	a5,4(a0)
    80003bda:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bdc:	04451783          	lh	a5,68(a0)
    80003be0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003be4:	04a51783          	lh	a5,74(a0)
    80003be8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bec:	04c56783          	lwu	a5,76(a0)
    80003bf0:	e99c                	sd	a5,16(a1)
}
    80003bf2:	6422                	ld	s0,8(sp)
    80003bf4:	0141                	addi	sp,sp,16
    80003bf6:	8082                	ret

0000000080003bf8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bf8:	457c                	lw	a5,76(a0)
    80003bfa:	0ed7e963          	bltu	a5,a3,80003cec <readi+0xf4>
{
    80003bfe:	7159                	addi	sp,sp,-112
    80003c00:	f486                	sd	ra,104(sp)
    80003c02:	f0a2                	sd	s0,96(sp)
    80003c04:	eca6                	sd	s1,88(sp)
    80003c06:	e8ca                	sd	s2,80(sp)
    80003c08:	e4ce                	sd	s3,72(sp)
    80003c0a:	e0d2                	sd	s4,64(sp)
    80003c0c:	fc56                	sd	s5,56(sp)
    80003c0e:	f85a                	sd	s6,48(sp)
    80003c10:	f45e                	sd	s7,40(sp)
    80003c12:	f062                	sd	s8,32(sp)
    80003c14:	ec66                	sd	s9,24(sp)
    80003c16:	e86a                	sd	s10,16(sp)
    80003c18:	e46e                	sd	s11,8(sp)
    80003c1a:	1880                	addi	s0,sp,112
    80003c1c:	8baa                	mv	s7,a0
    80003c1e:	8c2e                	mv	s8,a1
    80003c20:	8a32                	mv	s4,a2
    80003c22:	84b6                	mv	s1,a3
    80003c24:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c26:	9f35                	addw	a4,a4,a3
    return 0;
    80003c28:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c2a:	0ad76063          	bltu	a4,a3,80003cca <readi+0xd2>
  if(off + n > ip->size)
    80003c2e:	00e7f463          	bleu	a4,a5,80003c36 <readi+0x3e>
    n = ip->size - off;
    80003c32:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c36:	0a0b0963          	beqz	s6,80003ce8 <readi+0xf0>
    80003c3a:	4901                	li	s2,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c3c:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c40:	5cfd                	li	s9,-1
    80003c42:	a82d                	j	80003c7c <readi+0x84>
    80003c44:	02099d93          	slli	s11,s3,0x20
    80003c48:	020ddd93          	srli	s11,s11,0x20
    80003c4c:	058a8613          	addi	a2,s5,88
    80003c50:	86ee                	mv	a3,s11
    80003c52:	963a                	add	a2,a2,a4
    80003c54:	85d2                	mv	a1,s4
    80003c56:	8562                	mv	a0,s8
    80003c58:	fffff097          	auipc	ra,0xfffff
    80003c5c:	ab2080e7          	jalr	-1358(ra) # 8000270a <either_copyout>
    80003c60:	05950d63          	beq	a0,s9,80003cba <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c64:	8556                	mv	a0,s5
    80003c66:	fffff097          	auipc	ra,0xfffff
    80003c6a:	5d6080e7          	jalr	1494(ra) # 8000323c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c6e:	0129893b          	addw	s2,s3,s2
    80003c72:	009984bb          	addw	s1,s3,s1
    80003c76:	9a6e                	add	s4,s4,s11
    80003c78:	05697763          	bleu	s6,s2,80003cc6 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c7c:	000ba983          	lw	s3,0(s7)
    80003c80:	00a4d59b          	srliw	a1,s1,0xa
    80003c84:	855e                	mv	a0,s7
    80003c86:	00000097          	auipc	ra,0x0
    80003c8a:	8ac080e7          	jalr	-1876(ra) # 80003532 <bmap>
    80003c8e:	0005059b          	sext.w	a1,a0
    80003c92:	854e                	mv	a0,s3
    80003c94:	fffff097          	auipc	ra,0xfffff
    80003c98:	466080e7          	jalr	1126(ra) # 800030fa <bread>
    80003c9c:	8aaa                	mv	s5,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c9e:	3ff4f713          	andi	a4,s1,1023
    80003ca2:	40ed07bb          	subw	a5,s10,a4
    80003ca6:	412b06bb          	subw	a3,s6,s2
    80003caa:	89be                	mv	s3,a5
    80003cac:	2781                	sext.w	a5,a5
    80003cae:	0006861b          	sext.w	a2,a3
    80003cb2:	f8f679e3          	bleu	a5,a2,80003c44 <readi+0x4c>
    80003cb6:	89b6                	mv	s3,a3
    80003cb8:	b771                	j	80003c44 <readi+0x4c>
      brelse(bp);
    80003cba:	8556                	mv	a0,s5
    80003cbc:	fffff097          	auipc	ra,0xfffff
    80003cc0:	580080e7          	jalr	1408(ra) # 8000323c <brelse>
      tot = -1;
    80003cc4:	597d                	li	s2,-1
  }
  return tot;
    80003cc6:	0009051b          	sext.w	a0,s2
}
    80003cca:	70a6                	ld	ra,104(sp)
    80003ccc:	7406                	ld	s0,96(sp)
    80003cce:	64e6                	ld	s1,88(sp)
    80003cd0:	6946                	ld	s2,80(sp)
    80003cd2:	69a6                	ld	s3,72(sp)
    80003cd4:	6a06                	ld	s4,64(sp)
    80003cd6:	7ae2                	ld	s5,56(sp)
    80003cd8:	7b42                	ld	s6,48(sp)
    80003cda:	7ba2                	ld	s7,40(sp)
    80003cdc:	7c02                	ld	s8,32(sp)
    80003cde:	6ce2                	ld	s9,24(sp)
    80003ce0:	6d42                	ld	s10,16(sp)
    80003ce2:	6da2                	ld	s11,8(sp)
    80003ce4:	6165                	addi	sp,sp,112
    80003ce6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ce8:	895a                	mv	s2,s6
    80003cea:	bff1                	j	80003cc6 <readi+0xce>
    return 0;
    80003cec:	4501                	li	a0,0
}
    80003cee:	8082                	ret

0000000080003cf0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cf0:	457c                	lw	a5,76(a0)
    80003cf2:	10d7e763          	bltu	a5,a3,80003e00 <writei+0x110>
{
    80003cf6:	7159                	addi	sp,sp,-112
    80003cf8:	f486                	sd	ra,104(sp)
    80003cfa:	f0a2                	sd	s0,96(sp)
    80003cfc:	eca6                	sd	s1,88(sp)
    80003cfe:	e8ca                	sd	s2,80(sp)
    80003d00:	e4ce                	sd	s3,72(sp)
    80003d02:	e0d2                	sd	s4,64(sp)
    80003d04:	fc56                	sd	s5,56(sp)
    80003d06:	f85a                	sd	s6,48(sp)
    80003d08:	f45e                	sd	s7,40(sp)
    80003d0a:	f062                	sd	s8,32(sp)
    80003d0c:	ec66                	sd	s9,24(sp)
    80003d0e:	e86a                	sd	s10,16(sp)
    80003d10:	e46e                	sd	s11,8(sp)
    80003d12:	1880                	addi	s0,sp,112
    80003d14:	8baa                	mv	s7,a0
    80003d16:	8c2e                	mv	s8,a1
    80003d18:	8ab2                	mv	s5,a2
    80003d1a:	84b6                	mv	s1,a3
    80003d1c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d1e:	00e687bb          	addw	a5,a3,a4
    80003d22:	0ed7e163          	bltu	a5,a3,80003e04 <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d26:	00043737          	lui	a4,0x43
    80003d2a:	0cf76f63          	bltu	a4,a5,80003e08 <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d2e:	0a0b0863          	beqz	s6,80003dde <writei+0xee>
    80003d32:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d34:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d38:	5cfd                	li	s9,-1
    80003d3a:	a091                	j	80003d7e <writei+0x8e>
    80003d3c:	02091d93          	slli	s11,s2,0x20
    80003d40:	020ddd93          	srli	s11,s11,0x20
    80003d44:	05898513          	addi	a0,s3,88
    80003d48:	86ee                	mv	a3,s11
    80003d4a:	8656                	mv	a2,s5
    80003d4c:	85e2                	mv	a1,s8
    80003d4e:	953a                	add	a0,a0,a4
    80003d50:	fffff097          	auipc	ra,0xfffff
    80003d54:	a10080e7          	jalr	-1520(ra) # 80002760 <either_copyin>
    80003d58:	07950263          	beq	a0,s9,80003dbc <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80003d5c:	854e                	mv	a0,s3
    80003d5e:	00000097          	auipc	ra,0x0
    80003d62:	78c080e7          	jalr	1932(ra) # 800044ea <log_write>
    brelse(bp);
    80003d66:	854e                	mv	a0,s3
    80003d68:	fffff097          	auipc	ra,0xfffff
    80003d6c:	4d4080e7          	jalr	1236(ra) # 8000323c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d70:	01490a3b          	addw	s4,s2,s4
    80003d74:	009904bb          	addw	s1,s2,s1
    80003d78:	9aee                	add	s5,s5,s11
    80003d7a:	056a7763          	bleu	s6,s4,80003dc8 <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d7e:	000ba903          	lw	s2,0(s7)
    80003d82:	00a4d59b          	srliw	a1,s1,0xa
    80003d86:	855e                	mv	a0,s7
    80003d88:	fffff097          	auipc	ra,0xfffff
    80003d8c:	7aa080e7          	jalr	1962(ra) # 80003532 <bmap>
    80003d90:	0005059b          	sext.w	a1,a0
    80003d94:	854a                	mv	a0,s2
    80003d96:	fffff097          	auipc	ra,0xfffff
    80003d9a:	364080e7          	jalr	868(ra) # 800030fa <bread>
    80003d9e:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003da0:	3ff4f713          	andi	a4,s1,1023
    80003da4:	40ed07bb          	subw	a5,s10,a4
    80003da8:	414b06bb          	subw	a3,s6,s4
    80003dac:	893e                	mv	s2,a5
    80003dae:	2781                	sext.w	a5,a5
    80003db0:	0006861b          	sext.w	a2,a3
    80003db4:	f8f674e3          	bleu	a5,a2,80003d3c <writei+0x4c>
    80003db8:	8936                	mv	s2,a3
    80003dba:	b749                	j	80003d3c <writei+0x4c>
      brelse(bp);
    80003dbc:	854e                	mv	a0,s3
    80003dbe:	fffff097          	auipc	ra,0xfffff
    80003dc2:	47e080e7          	jalr	1150(ra) # 8000323c <brelse>
      n = -1;
    80003dc6:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003dc8:	04cba783          	lw	a5,76(s7)
    80003dcc:	0097f463          	bleu	s1,a5,80003dd4 <writei+0xe4>
      ip->size = off;
    80003dd0:	049ba623          	sw	s1,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003dd4:	855e                	mv	a0,s7
    80003dd6:	00000097          	auipc	ra,0x0
    80003dda:	aa0080e7          	jalr	-1376(ra) # 80003876 <iupdate>
  }

  return n;
    80003dde:	000b051b          	sext.w	a0,s6
}
    80003de2:	70a6                	ld	ra,104(sp)
    80003de4:	7406                	ld	s0,96(sp)
    80003de6:	64e6                	ld	s1,88(sp)
    80003de8:	6946                	ld	s2,80(sp)
    80003dea:	69a6                	ld	s3,72(sp)
    80003dec:	6a06                	ld	s4,64(sp)
    80003dee:	7ae2                	ld	s5,56(sp)
    80003df0:	7b42                	ld	s6,48(sp)
    80003df2:	7ba2                	ld	s7,40(sp)
    80003df4:	7c02                	ld	s8,32(sp)
    80003df6:	6ce2                	ld	s9,24(sp)
    80003df8:	6d42                	ld	s10,16(sp)
    80003dfa:	6da2                	ld	s11,8(sp)
    80003dfc:	6165                	addi	sp,sp,112
    80003dfe:	8082                	ret
    return -1;
    80003e00:	557d                	li	a0,-1
}
    80003e02:	8082                	ret
    return -1;
    80003e04:	557d                	li	a0,-1
    80003e06:	bff1                	j	80003de2 <writei+0xf2>
    return -1;
    80003e08:	557d                	li	a0,-1
    80003e0a:	bfe1                	j	80003de2 <writei+0xf2>

0000000080003e0c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e0c:	1141                	addi	sp,sp,-16
    80003e0e:	e406                	sd	ra,8(sp)
    80003e10:	e022                	sd	s0,0(sp)
    80003e12:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e14:	4639                	li	a2,14
    80003e16:	ffffd097          	auipc	ra,0xffffd
    80003e1a:	12c080e7          	jalr	300(ra) # 80000f42 <strncmp>
}
    80003e1e:	60a2                	ld	ra,8(sp)
    80003e20:	6402                	ld	s0,0(sp)
    80003e22:	0141                	addi	sp,sp,16
    80003e24:	8082                	ret

0000000080003e26 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e26:	7139                	addi	sp,sp,-64
    80003e28:	fc06                	sd	ra,56(sp)
    80003e2a:	f822                	sd	s0,48(sp)
    80003e2c:	f426                	sd	s1,40(sp)
    80003e2e:	f04a                	sd	s2,32(sp)
    80003e30:	ec4e                	sd	s3,24(sp)
    80003e32:	e852                	sd	s4,16(sp)
    80003e34:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e36:	04451703          	lh	a4,68(a0)
    80003e3a:	4785                	li	a5,1
    80003e3c:	00f71a63          	bne	a4,a5,80003e50 <dirlookup+0x2a>
    80003e40:	892a                	mv	s2,a0
    80003e42:	89ae                	mv	s3,a1
    80003e44:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e46:	457c                	lw	a5,76(a0)
    80003e48:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e4a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e4c:	e79d                	bnez	a5,80003e7a <dirlookup+0x54>
    80003e4e:	a8a5                	j	80003ec6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e50:	00005517          	auipc	a0,0x5
    80003e54:	86050513          	addi	a0,a0,-1952 # 800086b0 <syscalls+0x1c8>
    80003e58:	ffffc097          	auipc	ra,0xffffc
    80003e5c:	71c080e7          	jalr	1820(ra) # 80000574 <panic>
      panic("dirlookup read");
    80003e60:	00005517          	auipc	a0,0x5
    80003e64:	86850513          	addi	a0,a0,-1944 # 800086c8 <syscalls+0x1e0>
    80003e68:	ffffc097          	auipc	ra,0xffffc
    80003e6c:	70c080e7          	jalr	1804(ra) # 80000574 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e70:	24c1                	addiw	s1,s1,16
    80003e72:	04c92783          	lw	a5,76(s2)
    80003e76:	04f4f763          	bleu	a5,s1,80003ec4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e7a:	4741                	li	a4,16
    80003e7c:	86a6                	mv	a3,s1
    80003e7e:	fc040613          	addi	a2,s0,-64
    80003e82:	4581                	li	a1,0
    80003e84:	854a                	mv	a0,s2
    80003e86:	00000097          	auipc	ra,0x0
    80003e8a:	d72080e7          	jalr	-654(ra) # 80003bf8 <readi>
    80003e8e:	47c1                	li	a5,16
    80003e90:	fcf518e3          	bne	a0,a5,80003e60 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e94:	fc045783          	lhu	a5,-64(s0)
    80003e98:	dfe1                	beqz	a5,80003e70 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e9a:	fc240593          	addi	a1,s0,-62
    80003e9e:	854e                	mv	a0,s3
    80003ea0:	00000097          	auipc	ra,0x0
    80003ea4:	f6c080e7          	jalr	-148(ra) # 80003e0c <namecmp>
    80003ea8:	f561                	bnez	a0,80003e70 <dirlookup+0x4a>
      if(poff)
    80003eaa:	000a0463          	beqz	s4,80003eb2 <dirlookup+0x8c>
        *poff = off;
    80003eae:	009a2023          	sw	s1,0(s4) # 2000 <_entry-0x7fffe000>
      return iget(dp->dev, inum);
    80003eb2:	fc045583          	lhu	a1,-64(s0)
    80003eb6:	00092503          	lw	a0,0(s2)
    80003eba:	fffff097          	auipc	ra,0xfffff
    80003ebe:	752080e7          	jalr	1874(ra) # 8000360c <iget>
    80003ec2:	a011                	j	80003ec6 <dirlookup+0xa0>
  return 0;
    80003ec4:	4501                	li	a0,0
}
    80003ec6:	70e2                	ld	ra,56(sp)
    80003ec8:	7442                	ld	s0,48(sp)
    80003eca:	74a2                	ld	s1,40(sp)
    80003ecc:	7902                	ld	s2,32(sp)
    80003ece:	69e2                	ld	s3,24(sp)
    80003ed0:	6a42                	ld	s4,16(sp)
    80003ed2:	6121                	addi	sp,sp,64
    80003ed4:	8082                	ret

0000000080003ed6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ed6:	711d                	addi	sp,sp,-96
    80003ed8:	ec86                	sd	ra,88(sp)
    80003eda:	e8a2                	sd	s0,80(sp)
    80003edc:	e4a6                	sd	s1,72(sp)
    80003ede:	e0ca                	sd	s2,64(sp)
    80003ee0:	fc4e                	sd	s3,56(sp)
    80003ee2:	f852                	sd	s4,48(sp)
    80003ee4:	f456                	sd	s5,40(sp)
    80003ee6:	f05a                	sd	s6,32(sp)
    80003ee8:	ec5e                	sd	s7,24(sp)
    80003eea:	e862                	sd	s8,16(sp)
    80003eec:	e466                	sd	s9,8(sp)
    80003eee:	1080                	addi	s0,sp,96
    80003ef0:	84aa                	mv	s1,a0
    80003ef2:	8bae                	mv	s7,a1
    80003ef4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ef6:	00054703          	lbu	a4,0(a0)
    80003efa:	02f00793          	li	a5,47
    80003efe:	02f70363          	beq	a4,a5,80003f24 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f02:	ffffe097          	auipc	ra,0xffffe
    80003f06:	d8c080e7          	jalr	-628(ra) # 80001c8e <myproc>
    80003f0a:	15053503          	ld	a0,336(a0)
    80003f0e:	00000097          	auipc	ra,0x0
    80003f12:	9f6080e7          	jalr	-1546(ra) # 80003904 <idup>
    80003f16:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f18:	02f00913          	li	s2,47
  len = path - s;
    80003f1c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003f1e:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f20:	4c05                	li	s8,1
    80003f22:	a865                	j	80003fda <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f24:	4585                	li	a1,1
    80003f26:	4505                	li	a0,1
    80003f28:	fffff097          	auipc	ra,0xfffff
    80003f2c:	6e4080e7          	jalr	1764(ra) # 8000360c <iget>
    80003f30:	89aa                	mv	s3,a0
    80003f32:	b7dd                	j	80003f18 <namex+0x42>
      iunlockput(ip);
    80003f34:	854e                	mv	a0,s3
    80003f36:	00000097          	auipc	ra,0x0
    80003f3a:	c70080e7          	jalr	-912(ra) # 80003ba6 <iunlockput>
      return 0;
    80003f3e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f40:	854e                	mv	a0,s3
    80003f42:	60e6                	ld	ra,88(sp)
    80003f44:	6446                	ld	s0,80(sp)
    80003f46:	64a6                	ld	s1,72(sp)
    80003f48:	6906                	ld	s2,64(sp)
    80003f4a:	79e2                	ld	s3,56(sp)
    80003f4c:	7a42                	ld	s4,48(sp)
    80003f4e:	7aa2                	ld	s5,40(sp)
    80003f50:	7b02                	ld	s6,32(sp)
    80003f52:	6be2                	ld	s7,24(sp)
    80003f54:	6c42                	ld	s8,16(sp)
    80003f56:	6ca2                	ld	s9,8(sp)
    80003f58:	6125                	addi	sp,sp,96
    80003f5a:	8082                	ret
      iunlock(ip);
    80003f5c:	854e                	mv	a0,s3
    80003f5e:	00000097          	auipc	ra,0x0
    80003f62:	aa8080e7          	jalr	-1368(ra) # 80003a06 <iunlock>
      return ip;
    80003f66:	bfe9                	j	80003f40 <namex+0x6a>
      iunlockput(ip);
    80003f68:	854e                	mv	a0,s3
    80003f6a:	00000097          	auipc	ra,0x0
    80003f6e:	c3c080e7          	jalr	-964(ra) # 80003ba6 <iunlockput>
      return 0;
    80003f72:	89d2                	mv	s3,s4
    80003f74:	b7f1                	j	80003f40 <namex+0x6a>
  len = path - s;
    80003f76:	40b48633          	sub	a2,s1,a1
    80003f7a:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003f7e:	094cd663          	ble	s4,s9,8000400a <namex+0x134>
    memmove(name, s, DIRSIZ);
    80003f82:	4639                	li	a2,14
    80003f84:	8556                	mv	a0,s5
    80003f86:	ffffd097          	auipc	ra,0xffffd
    80003f8a:	f40080e7          	jalr	-192(ra) # 80000ec6 <memmove>
  while(*path == '/')
    80003f8e:	0004c783          	lbu	a5,0(s1)
    80003f92:	01279763          	bne	a5,s2,80003fa0 <namex+0xca>
    path++;
    80003f96:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f98:	0004c783          	lbu	a5,0(s1)
    80003f9c:	ff278de3          	beq	a5,s2,80003f96 <namex+0xc0>
    ilock(ip);
    80003fa0:	854e                	mv	a0,s3
    80003fa2:	00000097          	auipc	ra,0x0
    80003fa6:	9a0080e7          	jalr	-1632(ra) # 80003942 <ilock>
    if(ip->type != T_DIR){
    80003faa:	04499783          	lh	a5,68(s3)
    80003fae:	f98793e3          	bne	a5,s8,80003f34 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003fb2:	000b8563          	beqz	s7,80003fbc <namex+0xe6>
    80003fb6:	0004c783          	lbu	a5,0(s1)
    80003fba:	d3cd                	beqz	a5,80003f5c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003fbc:	865a                	mv	a2,s6
    80003fbe:	85d6                	mv	a1,s5
    80003fc0:	854e                	mv	a0,s3
    80003fc2:	00000097          	auipc	ra,0x0
    80003fc6:	e64080e7          	jalr	-412(ra) # 80003e26 <dirlookup>
    80003fca:	8a2a                	mv	s4,a0
    80003fcc:	dd51                	beqz	a0,80003f68 <namex+0x92>
    iunlockput(ip);
    80003fce:	854e                	mv	a0,s3
    80003fd0:	00000097          	auipc	ra,0x0
    80003fd4:	bd6080e7          	jalr	-1066(ra) # 80003ba6 <iunlockput>
    ip = next;
    80003fd8:	89d2                	mv	s3,s4
  while(*path == '/')
    80003fda:	0004c783          	lbu	a5,0(s1)
    80003fde:	05279d63          	bne	a5,s2,80004038 <namex+0x162>
    path++;
    80003fe2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fe4:	0004c783          	lbu	a5,0(s1)
    80003fe8:	ff278de3          	beq	a5,s2,80003fe2 <namex+0x10c>
  if(*path == 0)
    80003fec:	cf8d                	beqz	a5,80004026 <namex+0x150>
  while(*path != '/' && *path != 0)
    80003fee:	01278b63          	beq	a5,s2,80004004 <namex+0x12e>
    80003ff2:	c795                	beqz	a5,8000401e <namex+0x148>
    path++;
    80003ff4:	85a6                	mv	a1,s1
    path++;
    80003ff6:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003ff8:	0004c783          	lbu	a5,0(s1)
    80003ffc:	f7278de3          	beq	a5,s2,80003f76 <namex+0xa0>
    80004000:	fbfd                	bnez	a5,80003ff6 <namex+0x120>
    80004002:	bf95                	j	80003f76 <namex+0xa0>
    80004004:	85a6                	mv	a1,s1
  len = path - s;
    80004006:	8a5a                	mv	s4,s6
    80004008:	865a                	mv	a2,s6
    memmove(name, s, len);
    8000400a:	2601                	sext.w	a2,a2
    8000400c:	8556                	mv	a0,s5
    8000400e:	ffffd097          	auipc	ra,0xffffd
    80004012:	eb8080e7          	jalr	-328(ra) # 80000ec6 <memmove>
    name[len] = 0;
    80004016:	9a56                	add	s4,s4,s5
    80004018:	000a0023          	sb	zero,0(s4)
    8000401c:	bf8d                	j	80003f8e <namex+0xb8>
  while(*path != '/' && *path != 0)
    8000401e:	85a6                	mv	a1,s1
  len = path - s;
    80004020:	8a5a                	mv	s4,s6
    80004022:	865a                	mv	a2,s6
    80004024:	b7dd                	j	8000400a <namex+0x134>
  if(nameiparent){
    80004026:	f00b8de3          	beqz	s7,80003f40 <namex+0x6a>
    iput(ip);
    8000402a:	854e                	mv	a0,s3
    8000402c:	00000097          	auipc	ra,0x0
    80004030:	ad2080e7          	jalr	-1326(ra) # 80003afe <iput>
    return 0;
    80004034:	4981                	li	s3,0
    80004036:	b729                	j	80003f40 <namex+0x6a>
  if(*path == 0)
    80004038:	d7fd                	beqz	a5,80004026 <namex+0x150>
    8000403a:	85a6                	mv	a1,s1
    8000403c:	bf6d                	j	80003ff6 <namex+0x120>

000000008000403e <dirlink>:
{
    8000403e:	7139                	addi	sp,sp,-64
    80004040:	fc06                	sd	ra,56(sp)
    80004042:	f822                	sd	s0,48(sp)
    80004044:	f426                	sd	s1,40(sp)
    80004046:	f04a                	sd	s2,32(sp)
    80004048:	ec4e                	sd	s3,24(sp)
    8000404a:	e852                	sd	s4,16(sp)
    8000404c:	0080                	addi	s0,sp,64
    8000404e:	892a                	mv	s2,a0
    80004050:	8a2e                	mv	s4,a1
    80004052:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004054:	4601                	li	a2,0
    80004056:	00000097          	auipc	ra,0x0
    8000405a:	dd0080e7          	jalr	-560(ra) # 80003e26 <dirlookup>
    8000405e:	e93d                	bnez	a0,800040d4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004060:	04c92483          	lw	s1,76(s2)
    80004064:	c49d                	beqz	s1,80004092 <dirlink+0x54>
    80004066:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004068:	4741                	li	a4,16
    8000406a:	86a6                	mv	a3,s1
    8000406c:	fc040613          	addi	a2,s0,-64
    80004070:	4581                	li	a1,0
    80004072:	854a                	mv	a0,s2
    80004074:	00000097          	auipc	ra,0x0
    80004078:	b84080e7          	jalr	-1148(ra) # 80003bf8 <readi>
    8000407c:	47c1                	li	a5,16
    8000407e:	06f51163          	bne	a0,a5,800040e0 <dirlink+0xa2>
    if(de.inum == 0)
    80004082:	fc045783          	lhu	a5,-64(s0)
    80004086:	c791                	beqz	a5,80004092 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004088:	24c1                	addiw	s1,s1,16
    8000408a:	04c92783          	lw	a5,76(s2)
    8000408e:	fcf4ede3          	bltu	s1,a5,80004068 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004092:	4639                	li	a2,14
    80004094:	85d2                	mv	a1,s4
    80004096:	fc240513          	addi	a0,s0,-62
    8000409a:	ffffd097          	auipc	ra,0xffffd
    8000409e:	ef8080e7          	jalr	-264(ra) # 80000f92 <strncpy>
  de.inum = inum;
    800040a2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040a6:	4741                	li	a4,16
    800040a8:	86a6                	mv	a3,s1
    800040aa:	fc040613          	addi	a2,s0,-64
    800040ae:	4581                	li	a1,0
    800040b0:	854a                	mv	a0,s2
    800040b2:	00000097          	auipc	ra,0x0
    800040b6:	c3e080e7          	jalr	-962(ra) # 80003cf0 <writei>
    800040ba:	4741                	li	a4,16
  return 0;
    800040bc:	4781                	li	a5,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040be:	02e51963          	bne	a0,a4,800040f0 <dirlink+0xb2>
}
    800040c2:	853e                	mv	a0,a5
    800040c4:	70e2                	ld	ra,56(sp)
    800040c6:	7442                	ld	s0,48(sp)
    800040c8:	74a2                	ld	s1,40(sp)
    800040ca:	7902                	ld	s2,32(sp)
    800040cc:	69e2                	ld	s3,24(sp)
    800040ce:	6a42                	ld	s4,16(sp)
    800040d0:	6121                	addi	sp,sp,64
    800040d2:	8082                	ret
    iput(ip);
    800040d4:	00000097          	auipc	ra,0x0
    800040d8:	a2a080e7          	jalr	-1494(ra) # 80003afe <iput>
    return -1;
    800040dc:	57fd                	li	a5,-1
    800040de:	b7d5                	j	800040c2 <dirlink+0x84>
      panic("dirlink read");
    800040e0:	00004517          	auipc	a0,0x4
    800040e4:	5f850513          	addi	a0,a0,1528 # 800086d8 <syscalls+0x1f0>
    800040e8:	ffffc097          	auipc	ra,0xffffc
    800040ec:	48c080e7          	jalr	1164(ra) # 80000574 <panic>
    panic("dirlink");
    800040f0:	00004517          	auipc	a0,0x4
    800040f4:	70850513          	addi	a0,a0,1800 # 800087f8 <syscalls+0x310>
    800040f8:	ffffc097          	auipc	ra,0xffffc
    800040fc:	47c080e7          	jalr	1148(ra) # 80000574 <panic>

0000000080004100 <namei>:

struct inode*
namei(char *path)
{
    80004100:	1101                	addi	sp,sp,-32
    80004102:	ec06                	sd	ra,24(sp)
    80004104:	e822                	sd	s0,16(sp)
    80004106:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004108:	fe040613          	addi	a2,s0,-32
    8000410c:	4581                	li	a1,0
    8000410e:	00000097          	auipc	ra,0x0
    80004112:	dc8080e7          	jalr	-568(ra) # 80003ed6 <namex>
}
    80004116:	60e2                	ld	ra,24(sp)
    80004118:	6442                	ld	s0,16(sp)
    8000411a:	6105                	addi	sp,sp,32
    8000411c:	8082                	ret

000000008000411e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000411e:	1141                	addi	sp,sp,-16
    80004120:	e406                	sd	ra,8(sp)
    80004122:	e022                	sd	s0,0(sp)
    80004124:	0800                	addi	s0,sp,16
  return namex(path, 1, name);
    80004126:	862e                	mv	a2,a1
    80004128:	4585                	li	a1,1
    8000412a:	00000097          	auipc	ra,0x0
    8000412e:	dac080e7          	jalr	-596(ra) # 80003ed6 <namex>
}
    80004132:	60a2                	ld	ra,8(sp)
    80004134:	6402                	ld	s0,0(sp)
    80004136:	0141                	addi	sp,sp,16
    80004138:	8082                	ret

000000008000413a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000413a:	1101                	addi	sp,sp,-32
    8000413c:	ec06                	sd	ra,24(sp)
    8000413e:	e822                	sd	s0,16(sp)
    80004140:	e426                	sd	s1,8(sp)
    80004142:	e04a                	sd	s2,0(sp)
    80004144:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004146:	0023d917          	auipc	s2,0x23d
    8000414a:	7c290913          	addi	s2,s2,1986 # 80241908 <log>
    8000414e:	01892583          	lw	a1,24(s2)
    80004152:	02892503          	lw	a0,40(s2)
    80004156:	fffff097          	auipc	ra,0xfffff
    8000415a:	fa4080e7          	jalr	-92(ra) # 800030fa <bread>
    8000415e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004160:	02c92683          	lw	a3,44(s2)
    80004164:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004166:	02d05763          	blez	a3,80004194 <write_head+0x5a>
    8000416a:	0023d797          	auipc	a5,0x23d
    8000416e:	7ce78793          	addi	a5,a5,1998 # 80241938 <log+0x30>
    80004172:	05c50713          	addi	a4,a0,92
    80004176:	36fd                	addiw	a3,a3,-1
    80004178:	1682                	slli	a3,a3,0x20
    8000417a:	9281                	srli	a3,a3,0x20
    8000417c:	068a                	slli	a3,a3,0x2
    8000417e:	0023d617          	auipc	a2,0x23d
    80004182:	7be60613          	addi	a2,a2,1982 # 8024193c <log+0x34>
    80004186:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004188:	4390                	lw	a2,0(a5)
    8000418a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000418c:	0791                	addi	a5,a5,4
    8000418e:	0711                	addi	a4,a4,4
    80004190:	fed79ce3          	bne	a5,a3,80004188 <write_head+0x4e>
  }
  bwrite(buf);
    80004194:	8526                	mv	a0,s1
    80004196:	fffff097          	auipc	ra,0xfffff
    8000419a:	068080e7          	jalr	104(ra) # 800031fe <bwrite>
  brelse(buf);
    8000419e:	8526                	mv	a0,s1
    800041a0:	fffff097          	auipc	ra,0xfffff
    800041a4:	09c080e7          	jalr	156(ra) # 8000323c <brelse>
}
    800041a8:	60e2                	ld	ra,24(sp)
    800041aa:	6442                	ld	s0,16(sp)
    800041ac:	64a2                	ld	s1,8(sp)
    800041ae:	6902                	ld	s2,0(sp)
    800041b0:	6105                	addi	sp,sp,32
    800041b2:	8082                	ret

00000000800041b4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800041b4:	0023d797          	auipc	a5,0x23d
    800041b8:	75478793          	addi	a5,a5,1876 # 80241908 <log>
    800041bc:	57dc                	lw	a5,44(a5)
    800041be:	0af05663          	blez	a5,8000426a <install_trans+0xb6>
{
    800041c2:	7139                	addi	sp,sp,-64
    800041c4:	fc06                	sd	ra,56(sp)
    800041c6:	f822                	sd	s0,48(sp)
    800041c8:	f426                	sd	s1,40(sp)
    800041ca:	f04a                	sd	s2,32(sp)
    800041cc:	ec4e                	sd	s3,24(sp)
    800041ce:	e852                	sd	s4,16(sp)
    800041d0:	e456                	sd	s5,8(sp)
    800041d2:	0080                	addi	s0,sp,64
    800041d4:	0023da17          	auipc	s4,0x23d
    800041d8:	764a0a13          	addi	s4,s4,1892 # 80241938 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041dc:	4981                	li	s3,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041de:	0023d917          	auipc	s2,0x23d
    800041e2:	72a90913          	addi	s2,s2,1834 # 80241908 <log>
    800041e6:	01892583          	lw	a1,24(s2)
    800041ea:	013585bb          	addw	a1,a1,s3
    800041ee:	2585                	addiw	a1,a1,1
    800041f0:	02892503          	lw	a0,40(s2)
    800041f4:	fffff097          	auipc	ra,0xfffff
    800041f8:	f06080e7          	jalr	-250(ra) # 800030fa <bread>
    800041fc:	8aaa                	mv	s5,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041fe:	000a2583          	lw	a1,0(s4)
    80004202:	02892503          	lw	a0,40(s2)
    80004206:	fffff097          	auipc	ra,0xfffff
    8000420a:	ef4080e7          	jalr	-268(ra) # 800030fa <bread>
    8000420e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004210:	40000613          	li	a2,1024
    80004214:	058a8593          	addi	a1,s5,88
    80004218:	05850513          	addi	a0,a0,88
    8000421c:	ffffd097          	auipc	ra,0xffffd
    80004220:	caa080e7          	jalr	-854(ra) # 80000ec6 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004224:	8526                	mv	a0,s1
    80004226:	fffff097          	auipc	ra,0xfffff
    8000422a:	fd8080e7          	jalr	-40(ra) # 800031fe <bwrite>
    bunpin(dbuf);
    8000422e:	8526                	mv	a0,s1
    80004230:	fffff097          	auipc	ra,0xfffff
    80004234:	0e6080e7          	jalr	230(ra) # 80003316 <bunpin>
    brelse(lbuf);
    80004238:	8556                	mv	a0,s5
    8000423a:	fffff097          	auipc	ra,0xfffff
    8000423e:	002080e7          	jalr	2(ra) # 8000323c <brelse>
    brelse(dbuf);
    80004242:	8526                	mv	a0,s1
    80004244:	fffff097          	auipc	ra,0xfffff
    80004248:	ff8080e7          	jalr	-8(ra) # 8000323c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000424c:	2985                	addiw	s3,s3,1
    8000424e:	0a11                	addi	s4,s4,4
    80004250:	02c92783          	lw	a5,44(s2)
    80004254:	f8f9c9e3          	blt	s3,a5,800041e6 <install_trans+0x32>
}
    80004258:	70e2                	ld	ra,56(sp)
    8000425a:	7442                	ld	s0,48(sp)
    8000425c:	74a2                	ld	s1,40(sp)
    8000425e:	7902                	ld	s2,32(sp)
    80004260:	69e2                	ld	s3,24(sp)
    80004262:	6a42                	ld	s4,16(sp)
    80004264:	6aa2                	ld	s5,8(sp)
    80004266:	6121                	addi	sp,sp,64
    80004268:	8082                	ret
    8000426a:	8082                	ret

000000008000426c <initlog>:
{
    8000426c:	7179                	addi	sp,sp,-48
    8000426e:	f406                	sd	ra,40(sp)
    80004270:	f022                	sd	s0,32(sp)
    80004272:	ec26                	sd	s1,24(sp)
    80004274:	e84a                	sd	s2,16(sp)
    80004276:	e44e                	sd	s3,8(sp)
    80004278:	1800                	addi	s0,sp,48
    8000427a:	892a                	mv	s2,a0
    8000427c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000427e:	0023d497          	auipc	s1,0x23d
    80004282:	68a48493          	addi	s1,s1,1674 # 80241908 <log>
    80004286:	00004597          	auipc	a1,0x4
    8000428a:	46258593          	addi	a1,a1,1122 # 800086e8 <syscalls+0x200>
    8000428e:	8526                	mv	a0,s1
    80004290:	ffffd097          	auipc	ra,0xffffd
    80004294:	a3e080e7          	jalr	-1474(ra) # 80000cce <initlock>
  log.start = sb->logstart;
    80004298:	0149a583          	lw	a1,20(s3)
    8000429c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000429e:	0109a783          	lw	a5,16(s3)
    800042a2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800042a4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800042a8:	854a                	mv	a0,s2
    800042aa:	fffff097          	auipc	ra,0xfffff
    800042ae:	e50080e7          	jalr	-432(ra) # 800030fa <bread>
  log.lh.n = lh->n;
    800042b2:	4d3c                	lw	a5,88(a0)
    800042b4:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800042b6:	02f05563          	blez	a5,800042e0 <initlog+0x74>
    800042ba:	05c50713          	addi	a4,a0,92
    800042be:	0023d697          	auipc	a3,0x23d
    800042c2:	67a68693          	addi	a3,a3,1658 # 80241938 <log+0x30>
    800042c6:	37fd                	addiw	a5,a5,-1
    800042c8:	1782                	slli	a5,a5,0x20
    800042ca:	9381                	srli	a5,a5,0x20
    800042cc:	078a                	slli	a5,a5,0x2
    800042ce:	06050613          	addi	a2,a0,96
    800042d2:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800042d4:	4310                	lw	a2,0(a4)
    800042d6:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800042d8:	0711                	addi	a4,a4,4
    800042da:	0691                	addi	a3,a3,4
    800042dc:	fef71ce3          	bne	a4,a5,800042d4 <initlog+0x68>
  brelse(buf);
    800042e0:	fffff097          	auipc	ra,0xfffff
    800042e4:	f5c080e7          	jalr	-164(ra) # 8000323c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    800042e8:	00000097          	auipc	ra,0x0
    800042ec:	ecc080e7          	jalr	-308(ra) # 800041b4 <install_trans>
  log.lh.n = 0;
    800042f0:	0023d797          	auipc	a5,0x23d
    800042f4:	6407a223          	sw	zero,1604(a5) # 80241934 <log+0x2c>
  write_head(); // clear the log
    800042f8:	00000097          	auipc	ra,0x0
    800042fc:	e42080e7          	jalr	-446(ra) # 8000413a <write_head>
}
    80004300:	70a2                	ld	ra,40(sp)
    80004302:	7402                	ld	s0,32(sp)
    80004304:	64e2                	ld	s1,24(sp)
    80004306:	6942                	ld	s2,16(sp)
    80004308:	69a2                	ld	s3,8(sp)
    8000430a:	6145                	addi	sp,sp,48
    8000430c:	8082                	ret

000000008000430e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000430e:	1101                	addi	sp,sp,-32
    80004310:	ec06                	sd	ra,24(sp)
    80004312:	e822                	sd	s0,16(sp)
    80004314:	e426                	sd	s1,8(sp)
    80004316:	e04a                	sd	s2,0(sp)
    80004318:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000431a:	0023d517          	auipc	a0,0x23d
    8000431e:	5ee50513          	addi	a0,a0,1518 # 80241908 <log>
    80004322:	ffffd097          	auipc	ra,0xffffd
    80004326:	a3c080e7          	jalr	-1476(ra) # 80000d5e <acquire>
  while(1){
    if(log.committing){
    8000432a:	0023d497          	auipc	s1,0x23d
    8000432e:	5de48493          	addi	s1,s1,1502 # 80241908 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004332:	4979                	li	s2,30
    80004334:	a039                	j	80004342 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004336:	85a6                	mv	a1,s1
    80004338:	8526                	mv	a0,s1
    8000433a:	ffffe097          	auipc	ra,0xffffe
    8000433e:	16e080e7          	jalr	366(ra) # 800024a8 <sleep>
    if(log.committing){
    80004342:	50dc                	lw	a5,36(s1)
    80004344:	fbed                	bnez	a5,80004336 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004346:	509c                	lw	a5,32(s1)
    80004348:	0017871b          	addiw	a4,a5,1
    8000434c:	0007069b          	sext.w	a3,a4
    80004350:	0027179b          	slliw	a5,a4,0x2
    80004354:	9fb9                	addw	a5,a5,a4
    80004356:	0017979b          	slliw	a5,a5,0x1
    8000435a:	54d8                	lw	a4,44(s1)
    8000435c:	9fb9                	addw	a5,a5,a4
    8000435e:	00f95963          	ble	a5,s2,80004370 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004362:	85a6                	mv	a1,s1
    80004364:	8526                	mv	a0,s1
    80004366:	ffffe097          	auipc	ra,0xffffe
    8000436a:	142080e7          	jalr	322(ra) # 800024a8 <sleep>
    8000436e:	bfd1                	j	80004342 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004370:	0023d517          	auipc	a0,0x23d
    80004374:	59850513          	addi	a0,a0,1432 # 80241908 <log>
    80004378:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000437a:	ffffd097          	auipc	ra,0xffffd
    8000437e:	a98080e7          	jalr	-1384(ra) # 80000e12 <release>
      break;
    }
  }
}
    80004382:	60e2                	ld	ra,24(sp)
    80004384:	6442                	ld	s0,16(sp)
    80004386:	64a2                	ld	s1,8(sp)
    80004388:	6902                	ld	s2,0(sp)
    8000438a:	6105                	addi	sp,sp,32
    8000438c:	8082                	ret

000000008000438e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000438e:	7139                	addi	sp,sp,-64
    80004390:	fc06                	sd	ra,56(sp)
    80004392:	f822                	sd	s0,48(sp)
    80004394:	f426                	sd	s1,40(sp)
    80004396:	f04a                	sd	s2,32(sp)
    80004398:	ec4e                	sd	s3,24(sp)
    8000439a:	e852                	sd	s4,16(sp)
    8000439c:	e456                	sd	s5,8(sp)
    8000439e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800043a0:	0023d917          	auipc	s2,0x23d
    800043a4:	56890913          	addi	s2,s2,1384 # 80241908 <log>
    800043a8:	854a                	mv	a0,s2
    800043aa:	ffffd097          	auipc	ra,0xffffd
    800043ae:	9b4080e7          	jalr	-1612(ra) # 80000d5e <acquire>
  log.outstanding -= 1;
    800043b2:	02092783          	lw	a5,32(s2)
    800043b6:	37fd                	addiw	a5,a5,-1
    800043b8:	0007849b          	sext.w	s1,a5
    800043bc:	02f92023          	sw	a5,32(s2)
  if(log.committing)
    800043c0:	02492783          	lw	a5,36(s2)
    800043c4:	eba1                	bnez	a5,80004414 <end_op+0x86>
    panic("log.committing");
  if(log.outstanding == 0){
    800043c6:	ecb9                	bnez	s1,80004424 <end_op+0x96>
    do_commit = 1;
    log.committing = 1;
    800043c8:	0023d917          	auipc	s2,0x23d
    800043cc:	54090913          	addi	s2,s2,1344 # 80241908 <log>
    800043d0:	4785                	li	a5,1
    800043d2:	02f92223          	sw	a5,36(s2)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043d6:	854a                	mv	a0,s2
    800043d8:	ffffd097          	auipc	ra,0xffffd
    800043dc:	a3a080e7          	jalr	-1478(ra) # 80000e12 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043e0:	02c92783          	lw	a5,44(s2)
    800043e4:	06f04763          	bgtz	a5,80004452 <end_op+0xc4>
    acquire(&log.lock);
    800043e8:	0023d497          	auipc	s1,0x23d
    800043ec:	52048493          	addi	s1,s1,1312 # 80241908 <log>
    800043f0:	8526                	mv	a0,s1
    800043f2:	ffffd097          	auipc	ra,0xffffd
    800043f6:	96c080e7          	jalr	-1684(ra) # 80000d5e <acquire>
    log.committing = 0;
    800043fa:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043fe:	8526                	mv	a0,s1
    80004400:	ffffe097          	auipc	ra,0xffffe
    80004404:	22e080e7          	jalr	558(ra) # 8000262e <wakeup>
    release(&log.lock);
    80004408:	8526                	mv	a0,s1
    8000440a:	ffffd097          	auipc	ra,0xffffd
    8000440e:	a08080e7          	jalr	-1528(ra) # 80000e12 <release>
}
    80004412:	a03d                	j	80004440 <end_op+0xb2>
    panic("log.committing");
    80004414:	00004517          	auipc	a0,0x4
    80004418:	2dc50513          	addi	a0,a0,732 # 800086f0 <syscalls+0x208>
    8000441c:	ffffc097          	auipc	ra,0xffffc
    80004420:	158080e7          	jalr	344(ra) # 80000574 <panic>
    wakeup(&log);
    80004424:	0023d497          	auipc	s1,0x23d
    80004428:	4e448493          	addi	s1,s1,1252 # 80241908 <log>
    8000442c:	8526                	mv	a0,s1
    8000442e:	ffffe097          	auipc	ra,0xffffe
    80004432:	200080e7          	jalr	512(ra) # 8000262e <wakeup>
  release(&log.lock);
    80004436:	8526                	mv	a0,s1
    80004438:	ffffd097          	auipc	ra,0xffffd
    8000443c:	9da080e7          	jalr	-1574(ra) # 80000e12 <release>
}
    80004440:	70e2                	ld	ra,56(sp)
    80004442:	7442                	ld	s0,48(sp)
    80004444:	74a2                	ld	s1,40(sp)
    80004446:	7902                	ld	s2,32(sp)
    80004448:	69e2                	ld	s3,24(sp)
    8000444a:	6a42                	ld	s4,16(sp)
    8000444c:	6aa2                	ld	s5,8(sp)
    8000444e:	6121                	addi	sp,sp,64
    80004450:	8082                	ret
    80004452:	0023da17          	auipc	s4,0x23d
    80004456:	4e6a0a13          	addi	s4,s4,1254 # 80241938 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000445a:	0023d917          	auipc	s2,0x23d
    8000445e:	4ae90913          	addi	s2,s2,1198 # 80241908 <log>
    80004462:	01892583          	lw	a1,24(s2)
    80004466:	9da5                	addw	a1,a1,s1
    80004468:	2585                	addiw	a1,a1,1
    8000446a:	02892503          	lw	a0,40(s2)
    8000446e:	fffff097          	auipc	ra,0xfffff
    80004472:	c8c080e7          	jalr	-884(ra) # 800030fa <bread>
    80004476:	89aa                	mv	s3,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004478:	000a2583          	lw	a1,0(s4)
    8000447c:	02892503          	lw	a0,40(s2)
    80004480:	fffff097          	auipc	ra,0xfffff
    80004484:	c7a080e7          	jalr	-902(ra) # 800030fa <bread>
    80004488:	8aaa                	mv	s5,a0
    memmove(to->data, from->data, BSIZE);
    8000448a:	40000613          	li	a2,1024
    8000448e:	05850593          	addi	a1,a0,88
    80004492:	05898513          	addi	a0,s3,88
    80004496:	ffffd097          	auipc	ra,0xffffd
    8000449a:	a30080e7          	jalr	-1488(ra) # 80000ec6 <memmove>
    bwrite(to);  // write the log
    8000449e:	854e                	mv	a0,s3
    800044a0:	fffff097          	auipc	ra,0xfffff
    800044a4:	d5e080e7          	jalr	-674(ra) # 800031fe <bwrite>
    brelse(from);
    800044a8:	8556                	mv	a0,s5
    800044aa:	fffff097          	auipc	ra,0xfffff
    800044ae:	d92080e7          	jalr	-622(ra) # 8000323c <brelse>
    brelse(to);
    800044b2:	854e                	mv	a0,s3
    800044b4:	fffff097          	auipc	ra,0xfffff
    800044b8:	d88080e7          	jalr	-632(ra) # 8000323c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044bc:	2485                	addiw	s1,s1,1
    800044be:	0a11                	addi	s4,s4,4
    800044c0:	02c92783          	lw	a5,44(s2)
    800044c4:	f8f4cfe3          	blt	s1,a5,80004462 <end_op+0xd4>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800044c8:	00000097          	auipc	ra,0x0
    800044cc:	c72080e7          	jalr	-910(ra) # 8000413a <write_head>
    install_trans(); // Now install writes to home locations
    800044d0:	00000097          	auipc	ra,0x0
    800044d4:	ce4080e7          	jalr	-796(ra) # 800041b4 <install_trans>
    log.lh.n = 0;
    800044d8:	0023d797          	auipc	a5,0x23d
    800044dc:	4407ae23          	sw	zero,1116(a5) # 80241934 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800044e0:	00000097          	auipc	ra,0x0
    800044e4:	c5a080e7          	jalr	-934(ra) # 8000413a <write_head>
    800044e8:	b701                	j	800043e8 <end_op+0x5a>

00000000800044ea <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044ea:	1101                	addi	sp,sp,-32
    800044ec:	ec06                	sd	ra,24(sp)
    800044ee:	e822                	sd	s0,16(sp)
    800044f0:	e426                	sd	s1,8(sp)
    800044f2:	e04a                	sd	s2,0(sp)
    800044f4:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044f6:	0023d797          	auipc	a5,0x23d
    800044fa:	41278793          	addi	a5,a5,1042 # 80241908 <log>
    800044fe:	57d8                	lw	a4,44(a5)
    80004500:	47f5                	li	a5,29
    80004502:	08e7c563          	blt	a5,a4,8000458c <log_write+0xa2>
    80004506:	892a                	mv	s2,a0
    80004508:	0023d797          	auipc	a5,0x23d
    8000450c:	40078793          	addi	a5,a5,1024 # 80241908 <log>
    80004510:	4fdc                	lw	a5,28(a5)
    80004512:	37fd                	addiw	a5,a5,-1
    80004514:	06f75c63          	ble	a5,a4,8000458c <log_write+0xa2>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004518:	0023d797          	auipc	a5,0x23d
    8000451c:	3f078793          	addi	a5,a5,1008 # 80241908 <log>
    80004520:	539c                	lw	a5,32(a5)
    80004522:	06f05d63          	blez	a5,8000459c <log_write+0xb2>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004526:	0023d497          	auipc	s1,0x23d
    8000452a:	3e248493          	addi	s1,s1,994 # 80241908 <log>
    8000452e:	8526                	mv	a0,s1
    80004530:	ffffd097          	auipc	ra,0xffffd
    80004534:	82e080e7          	jalr	-2002(ra) # 80000d5e <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004538:	54d0                	lw	a2,44(s1)
    8000453a:	0ac05063          	blez	a2,800045da <log_write+0xf0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000453e:	00c92583          	lw	a1,12(s2)
    80004542:	589c                	lw	a5,48(s1)
    80004544:	0ab78363          	beq	a5,a1,800045ea <log_write+0x100>
    80004548:	0023d717          	auipc	a4,0x23d
    8000454c:	3f470713          	addi	a4,a4,1012 # 8024193c <log+0x34>
  for (i = 0; i < log.lh.n; i++) {
    80004550:	4781                	li	a5,0
    80004552:	2785                	addiw	a5,a5,1
    80004554:	04c78c63          	beq	a5,a2,800045ac <log_write+0xc2>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004558:	4314                	lw	a3,0(a4)
    8000455a:	0711                	addi	a4,a4,4
    8000455c:	feb69be3          	bne	a3,a1,80004552 <log_write+0x68>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004560:	07a1                	addi	a5,a5,8
    80004562:	078a                	slli	a5,a5,0x2
    80004564:	0023d717          	auipc	a4,0x23d
    80004568:	3a470713          	addi	a4,a4,932 # 80241908 <log>
    8000456c:	97ba                	add	a5,a5,a4
    8000456e:	cb8c                	sw	a1,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    log.lh.n++;
  }
  release(&log.lock);
    80004570:	0023d517          	auipc	a0,0x23d
    80004574:	39850513          	addi	a0,a0,920 # 80241908 <log>
    80004578:	ffffd097          	auipc	ra,0xffffd
    8000457c:	89a080e7          	jalr	-1894(ra) # 80000e12 <release>
}
    80004580:	60e2                	ld	ra,24(sp)
    80004582:	6442                	ld	s0,16(sp)
    80004584:	64a2                	ld	s1,8(sp)
    80004586:	6902                	ld	s2,0(sp)
    80004588:	6105                	addi	sp,sp,32
    8000458a:	8082                	ret
    panic("too big a transaction");
    8000458c:	00004517          	auipc	a0,0x4
    80004590:	17450513          	addi	a0,a0,372 # 80008700 <syscalls+0x218>
    80004594:	ffffc097          	auipc	ra,0xffffc
    80004598:	fe0080e7          	jalr	-32(ra) # 80000574 <panic>
    panic("log_write outside of trans");
    8000459c:	00004517          	auipc	a0,0x4
    800045a0:	17c50513          	addi	a0,a0,380 # 80008718 <syscalls+0x230>
    800045a4:	ffffc097          	auipc	ra,0xffffc
    800045a8:	fd0080e7          	jalr	-48(ra) # 80000574 <panic>
  log.lh.block[i] = b->blockno;
    800045ac:	0621                	addi	a2,a2,8
    800045ae:	060a                	slli	a2,a2,0x2
    800045b0:	0023d797          	auipc	a5,0x23d
    800045b4:	35878793          	addi	a5,a5,856 # 80241908 <log>
    800045b8:	963e                	add	a2,a2,a5
    800045ba:	00c92783          	lw	a5,12(s2)
    800045be:	ca1c                	sw	a5,16(a2)
    bpin(b);
    800045c0:	854a                	mv	a0,s2
    800045c2:	fffff097          	auipc	ra,0xfffff
    800045c6:	d18080e7          	jalr	-744(ra) # 800032da <bpin>
    log.lh.n++;
    800045ca:	0023d717          	auipc	a4,0x23d
    800045ce:	33e70713          	addi	a4,a4,830 # 80241908 <log>
    800045d2:	575c                	lw	a5,44(a4)
    800045d4:	2785                	addiw	a5,a5,1
    800045d6:	d75c                	sw	a5,44(a4)
    800045d8:	bf61                	j	80004570 <log_write+0x86>
  log.lh.block[i] = b->blockno;
    800045da:	00c92783          	lw	a5,12(s2)
    800045de:	0023d717          	auipc	a4,0x23d
    800045e2:	34f72d23          	sw	a5,858(a4) # 80241938 <log+0x30>
  if (i == log.lh.n) {  // Add new block to log?
    800045e6:	f649                	bnez	a2,80004570 <log_write+0x86>
    800045e8:	bfe1                	j	800045c0 <log_write+0xd6>
  for (i = 0; i < log.lh.n; i++) {
    800045ea:	4781                	li	a5,0
    800045ec:	bf95                	j	80004560 <log_write+0x76>

00000000800045ee <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045ee:	1101                	addi	sp,sp,-32
    800045f0:	ec06                	sd	ra,24(sp)
    800045f2:	e822                	sd	s0,16(sp)
    800045f4:	e426                	sd	s1,8(sp)
    800045f6:	e04a                	sd	s2,0(sp)
    800045f8:	1000                	addi	s0,sp,32
    800045fa:	84aa                	mv	s1,a0
    800045fc:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045fe:	00004597          	auipc	a1,0x4
    80004602:	13a58593          	addi	a1,a1,314 # 80008738 <syscalls+0x250>
    80004606:	0521                	addi	a0,a0,8
    80004608:	ffffc097          	auipc	ra,0xffffc
    8000460c:	6c6080e7          	jalr	1734(ra) # 80000cce <initlock>
  lk->name = name;
    80004610:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004614:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004618:	0204a423          	sw	zero,40(s1)
}
    8000461c:	60e2                	ld	ra,24(sp)
    8000461e:	6442                	ld	s0,16(sp)
    80004620:	64a2                	ld	s1,8(sp)
    80004622:	6902                	ld	s2,0(sp)
    80004624:	6105                	addi	sp,sp,32
    80004626:	8082                	ret

0000000080004628 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004628:	1101                	addi	sp,sp,-32
    8000462a:	ec06                	sd	ra,24(sp)
    8000462c:	e822                	sd	s0,16(sp)
    8000462e:	e426                	sd	s1,8(sp)
    80004630:	e04a                	sd	s2,0(sp)
    80004632:	1000                	addi	s0,sp,32
    80004634:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004636:	00850913          	addi	s2,a0,8
    8000463a:	854a                	mv	a0,s2
    8000463c:	ffffc097          	auipc	ra,0xffffc
    80004640:	722080e7          	jalr	1826(ra) # 80000d5e <acquire>
  while (lk->locked) {
    80004644:	409c                	lw	a5,0(s1)
    80004646:	cb89                	beqz	a5,80004658 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004648:	85ca                	mv	a1,s2
    8000464a:	8526                	mv	a0,s1
    8000464c:	ffffe097          	auipc	ra,0xffffe
    80004650:	e5c080e7          	jalr	-420(ra) # 800024a8 <sleep>
  while (lk->locked) {
    80004654:	409c                	lw	a5,0(s1)
    80004656:	fbed                	bnez	a5,80004648 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004658:	4785                	li	a5,1
    8000465a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000465c:	ffffd097          	auipc	ra,0xffffd
    80004660:	632080e7          	jalr	1586(ra) # 80001c8e <myproc>
    80004664:	5d1c                	lw	a5,56(a0)
    80004666:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004668:	854a                	mv	a0,s2
    8000466a:	ffffc097          	auipc	ra,0xffffc
    8000466e:	7a8080e7          	jalr	1960(ra) # 80000e12 <release>
}
    80004672:	60e2                	ld	ra,24(sp)
    80004674:	6442                	ld	s0,16(sp)
    80004676:	64a2                	ld	s1,8(sp)
    80004678:	6902                	ld	s2,0(sp)
    8000467a:	6105                	addi	sp,sp,32
    8000467c:	8082                	ret

000000008000467e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000467e:	1101                	addi	sp,sp,-32
    80004680:	ec06                	sd	ra,24(sp)
    80004682:	e822                	sd	s0,16(sp)
    80004684:	e426                	sd	s1,8(sp)
    80004686:	e04a                	sd	s2,0(sp)
    80004688:	1000                	addi	s0,sp,32
    8000468a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000468c:	00850913          	addi	s2,a0,8
    80004690:	854a                	mv	a0,s2
    80004692:	ffffc097          	auipc	ra,0xffffc
    80004696:	6cc080e7          	jalr	1740(ra) # 80000d5e <acquire>
  lk->locked = 0;
    8000469a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000469e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800046a2:	8526                	mv	a0,s1
    800046a4:	ffffe097          	auipc	ra,0xffffe
    800046a8:	f8a080e7          	jalr	-118(ra) # 8000262e <wakeup>
  release(&lk->lk);
    800046ac:	854a                	mv	a0,s2
    800046ae:	ffffc097          	auipc	ra,0xffffc
    800046b2:	764080e7          	jalr	1892(ra) # 80000e12 <release>
}
    800046b6:	60e2                	ld	ra,24(sp)
    800046b8:	6442                	ld	s0,16(sp)
    800046ba:	64a2                	ld	s1,8(sp)
    800046bc:	6902                	ld	s2,0(sp)
    800046be:	6105                	addi	sp,sp,32
    800046c0:	8082                	ret

00000000800046c2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800046c2:	7179                	addi	sp,sp,-48
    800046c4:	f406                	sd	ra,40(sp)
    800046c6:	f022                	sd	s0,32(sp)
    800046c8:	ec26                	sd	s1,24(sp)
    800046ca:	e84a                	sd	s2,16(sp)
    800046cc:	e44e                	sd	s3,8(sp)
    800046ce:	1800                	addi	s0,sp,48
    800046d0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046d2:	00850913          	addi	s2,a0,8
    800046d6:	854a                	mv	a0,s2
    800046d8:	ffffc097          	auipc	ra,0xffffc
    800046dc:	686080e7          	jalr	1670(ra) # 80000d5e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046e0:	409c                	lw	a5,0(s1)
    800046e2:	ef99                	bnez	a5,80004700 <holdingsleep+0x3e>
    800046e4:	4481                	li	s1,0
  release(&lk->lk);
    800046e6:	854a                	mv	a0,s2
    800046e8:	ffffc097          	auipc	ra,0xffffc
    800046ec:	72a080e7          	jalr	1834(ra) # 80000e12 <release>
  return r;
}
    800046f0:	8526                	mv	a0,s1
    800046f2:	70a2                	ld	ra,40(sp)
    800046f4:	7402                	ld	s0,32(sp)
    800046f6:	64e2                	ld	s1,24(sp)
    800046f8:	6942                	ld	s2,16(sp)
    800046fa:	69a2                	ld	s3,8(sp)
    800046fc:	6145                	addi	sp,sp,48
    800046fe:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004700:	0284a983          	lw	s3,40(s1)
    80004704:	ffffd097          	auipc	ra,0xffffd
    80004708:	58a080e7          	jalr	1418(ra) # 80001c8e <myproc>
    8000470c:	5d04                	lw	s1,56(a0)
    8000470e:	413484b3          	sub	s1,s1,s3
    80004712:	0014b493          	seqz	s1,s1
    80004716:	bfc1                	j	800046e6 <holdingsleep+0x24>

0000000080004718 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004718:	1141                	addi	sp,sp,-16
    8000471a:	e406                	sd	ra,8(sp)
    8000471c:	e022                	sd	s0,0(sp)
    8000471e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004720:	00004597          	auipc	a1,0x4
    80004724:	02858593          	addi	a1,a1,40 # 80008748 <syscalls+0x260>
    80004728:	0023d517          	auipc	a0,0x23d
    8000472c:	32850513          	addi	a0,a0,808 # 80241a50 <ftable>
    80004730:	ffffc097          	auipc	ra,0xffffc
    80004734:	59e080e7          	jalr	1438(ra) # 80000cce <initlock>
}
    80004738:	60a2                	ld	ra,8(sp)
    8000473a:	6402                	ld	s0,0(sp)
    8000473c:	0141                	addi	sp,sp,16
    8000473e:	8082                	ret

0000000080004740 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004740:	1101                	addi	sp,sp,-32
    80004742:	ec06                	sd	ra,24(sp)
    80004744:	e822                	sd	s0,16(sp)
    80004746:	e426                	sd	s1,8(sp)
    80004748:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000474a:	0023d517          	auipc	a0,0x23d
    8000474e:	30650513          	addi	a0,a0,774 # 80241a50 <ftable>
    80004752:	ffffc097          	auipc	ra,0xffffc
    80004756:	60c080e7          	jalr	1548(ra) # 80000d5e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
    8000475a:	0023d797          	auipc	a5,0x23d
    8000475e:	2f678793          	addi	a5,a5,758 # 80241a50 <ftable>
    80004762:	4fdc                	lw	a5,28(a5)
    80004764:	cb8d                	beqz	a5,80004796 <filealloc+0x56>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004766:	0023d497          	auipc	s1,0x23d
    8000476a:	32a48493          	addi	s1,s1,810 # 80241a90 <ftable+0x40>
    8000476e:	0023e717          	auipc	a4,0x23e
    80004772:	29a70713          	addi	a4,a4,666 # 80242a08 <ftable+0xfb8>
    if(f->ref == 0){
    80004776:	40dc                	lw	a5,4(s1)
    80004778:	c39d                	beqz	a5,8000479e <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000477a:	02848493          	addi	s1,s1,40
    8000477e:	fee49ce3          	bne	s1,a4,80004776 <filealloc+0x36>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004782:	0023d517          	auipc	a0,0x23d
    80004786:	2ce50513          	addi	a0,a0,718 # 80241a50 <ftable>
    8000478a:	ffffc097          	auipc	ra,0xffffc
    8000478e:	688080e7          	jalr	1672(ra) # 80000e12 <release>
  return 0;
    80004792:	4481                	li	s1,0
    80004794:	a839                	j	800047b2 <filealloc+0x72>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004796:	0023d497          	auipc	s1,0x23d
    8000479a:	2d248493          	addi	s1,s1,722 # 80241a68 <ftable+0x18>
      f->ref = 1;
    8000479e:	4785                	li	a5,1
    800047a0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047a2:	0023d517          	auipc	a0,0x23d
    800047a6:	2ae50513          	addi	a0,a0,686 # 80241a50 <ftable>
    800047aa:	ffffc097          	auipc	ra,0xffffc
    800047ae:	668080e7          	jalr	1640(ra) # 80000e12 <release>
}
    800047b2:	8526                	mv	a0,s1
    800047b4:	60e2                	ld	ra,24(sp)
    800047b6:	6442                	ld	s0,16(sp)
    800047b8:	64a2                	ld	s1,8(sp)
    800047ba:	6105                	addi	sp,sp,32
    800047bc:	8082                	ret

00000000800047be <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800047be:	1101                	addi	sp,sp,-32
    800047c0:	ec06                	sd	ra,24(sp)
    800047c2:	e822                	sd	s0,16(sp)
    800047c4:	e426                	sd	s1,8(sp)
    800047c6:	1000                	addi	s0,sp,32
    800047c8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800047ca:	0023d517          	auipc	a0,0x23d
    800047ce:	28650513          	addi	a0,a0,646 # 80241a50 <ftable>
    800047d2:	ffffc097          	auipc	ra,0xffffc
    800047d6:	58c080e7          	jalr	1420(ra) # 80000d5e <acquire>
  if(f->ref < 1)
    800047da:	40dc                	lw	a5,4(s1)
    800047dc:	02f05263          	blez	a5,80004800 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800047e0:	2785                	addiw	a5,a5,1
    800047e2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047e4:	0023d517          	auipc	a0,0x23d
    800047e8:	26c50513          	addi	a0,a0,620 # 80241a50 <ftable>
    800047ec:	ffffc097          	auipc	ra,0xffffc
    800047f0:	626080e7          	jalr	1574(ra) # 80000e12 <release>
  return f;
}
    800047f4:	8526                	mv	a0,s1
    800047f6:	60e2                	ld	ra,24(sp)
    800047f8:	6442                	ld	s0,16(sp)
    800047fa:	64a2                	ld	s1,8(sp)
    800047fc:	6105                	addi	sp,sp,32
    800047fe:	8082                	ret
    panic("filedup");
    80004800:	00004517          	auipc	a0,0x4
    80004804:	f5050513          	addi	a0,a0,-176 # 80008750 <syscalls+0x268>
    80004808:	ffffc097          	auipc	ra,0xffffc
    8000480c:	d6c080e7          	jalr	-660(ra) # 80000574 <panic>

0000000080004810 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004810:	7139                	addi	sp,sp,-64
    80004812:	fc06                	sd	ra,56(sp)
    80004814:	f822                	sd	s0,48(sp)
    80004816:	f426                	sd	s1,40(sp)
    80004818:	f04a                	sd	s2,32(sp)
    8000481a:	ec4e                	sd	s3,24(sp)
    8000481c:	e852                	sd	s4,16(sp)
    8000481e:	e456                	sd	s5,8(sp)
    80004820:	0080                	addi	s0,sp,64
    80004822:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004824:	0023d517          	auipc	a0,0x23d
    80004828:	22c50513          	addi	a0,a0,556 # 80241a50 <ftable>
    8000482c:	ffffc097          	auipc	ra,0xffffc
    80004830:	532080e7          	jalr	1330(ra) # 80000d5e <acquire>
  if(f->ref < 1)
    80004834:	40dc                	lw	a5,4(s1)
    80004836:	06f05163          	blez	a5,80004898 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000483a:	37fd                	addiw	a5,a5,-1
    8000483c:	0007871b          	sext.w	a4,a5
    80004840:	c0dc                	sw	a5,4(s1)
    80004842:	06e04363          	bgtz	a4,800048a8 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004846:	0004a903          	lw	s2,0(s1)
    8000484a:	0094ca83          	lbu	s5,9(s1)
    8000484e:	0104ba03          	ld	s4,16(s1)
    80004852:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004856:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000485a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000485e:	0023d517          	auipc	a0,0x23d
    80004862:	1f250513          	addi	a0,a0,498 # 80241a50 <ftable>
    80004866:	ffffc097          	auipc	ra,0xffffc
    8000486a:	5ac080e7          	jalr	1452(ra) # 80000e12 <release>

  if(ff.type == FD_PIPE){
    8000486e:	4785                	li	a5,1
    80004870:	04f90d63          	beq	s2,a5,800048ca <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004874:	3979                	addiw	s2,s2,-2
    80004876:	4785                	li	a5,1
    80004878:	0527e063          	bltu	a5,s2,800048b8 <fileclose+0xa8>
    begin_op();
    8000487c:	00000097          	auipc	ra,0x0
    80004880:	a92080e7          	jalr	-1390(ra) # 8000430e <begin_op>
    iput(ff.ip);
    80004884:	854e                	mv	a0,s3
    80004886:	fffff097          	auipc	ra,0xfffff
    8000488a:	278080e7          	jalr	632(ra) # 80003afe <iput>
    end_op();
    8000488e:	00000097          	auipc	ra,0x0
    80004892:	b00080e7          	jalr	-1280(ra) # 8000438e <end_op>
    80004896:	a00d                	j	800048b8 <fileclose+0xa8>
    panic("fileclose");
    80004898:	00004517          	auipc	a0,0x4
    8000489c:	ec050513          	addi	a0,a0,-320 # 80008758 <syscalls+0x270>
    800048a0:	ffffc097          	auipc	ra,0xffffc
    800048a4:	cd4080e7          	jalr	-812(ra) # 80000574 <panic>
    release(&ftable.lock);
    800048a8:	0023d517          	auipc	a0,0x23d
    800048ac:	1a850513          	addi	a0,a0,424 # 80241a50 <ftable>
    800048b0:	ffffc097          	auipc	ra,0xffffc
    800048b4:	562080e7          	jalr	1378(ra) # 80000e12 <release>
  }
}
    800048b8:	70e2                	ld	ra,56(sp)
    800048ba:	7442                	ld	s0,48(sp)
    800048bc:	74a2                	ld	s1,40(sp)
    800048be:	7902                	ld	s2,32(sp)
    800048c0:	69e2                	ld	s3,24(sp)
    800048c2:	6a42                	ld	s4,16(sp)
    800048c4:	6aa2                	ld	s5,8(sp)
    800048c6:	6121                	addi	sp,sp,64
    800048c8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048ca:	85d6                	mv	a1,s5
    800048cc:	8552                	mv	a0,s4
    800048ce:	00000097          	auipc	ra,0x0
    800048d2:	364080e7          	jalr	868(ra) # 80004c32 <pipeclose>
    800048d6:	b7cd                	j	800048b8 <fileclose+0xa8>

00000000800048d8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048d8:	715d                	addi	sp,sp,-80
    800048da:	e486                	sd	ra,72(sp)
    800048dc:	e0a2                	sd	s0,64(sp)
    800048de:	fc26                	sd	s1,56(sp)
    800048e0:	f84a                	sd	s2,48(sp)
    800048e2:	f44e                	sd	s3,40(sp)
    800048e4:	0880                	addi	s0,sp,80
    800048e6:	84aa                	mv	s1,a0
    800048e8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800048ea:	ffffd097          	auipc	ra,0xffffd
    800048ee:	3a4080e7          	jalr	932(ra) # 80001c8e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800048f2:	409c                	lw	a5,0(s1)
    800048f4:	37f9                	addiw	a5,a5,-2
    800048f6:	4705                	li	a4,1
    800048f8:	04f76763          	bltu	a4,a5,80004946 <filestat+0x6e>
    800048fc:	892a                	mv	s2,a0
    ilock(f->ip);
    800048fe:	6c88                	ld	a0,24(s1)
    80004900:	fffff097          	auipc	ra,0xfffff
    80004904:	042080e7          	jalr	66(ra) # 80003942 <ilock>
    stati(f->ip, &st);
    80004908:	fb840593          	addi	a1,s0,-72
    8000490c:	6c88                	ld	a0,24(s1)
    8000490e:	fffff097          	auipc	ra,0xfffff
    80004912:	2c0080e7          	jalr	704(ra) # 80003bce <stati>
    iunlock(f->ip);
    80004916:	6c88                	ld	a0,24(s1)
    80004918:	fffff097          	auipc	ra,0xfffff
    8000491c:	0ee080e7          	jalr	238(ra) # 80003a06 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004920:	46e1                	li	a3,24
    80004922:	fb840613          	addi	a2,s0,-72
    80004926:	85ce                	mv	a1,s3
    80004928:	05093503          	ld	a0,80(s2)
    8000492c:	ffffd097          	auipc	ra,0xffffd
    80004930:	126080e7          	jalr	294(ra) # 80001a52 <copyout>
    80004934:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004938:	60a6                	ld	ra,72(sp)
    8000493a:	6406                	ld	s0,64(sp)
    8000493c:	74e2                	ld	s1,56(sp)
    8000493e:	7942                	ld	s2,48(sp)
    80004940:	79a2                	ld	s3,40(sp)
    80004942:	6161                	addi	sp,sp,80
    80004944:	8082                	ret
  return -1;
    80004946:	557d                	li	a0,-1
    80004948:	bfc5                	j	80004938 <filestat+0x60>

000000008000494a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000494a:	7179                	addi	sp,sp,-48
    8000494c:	f406                	sd	ra,40(sp)
    8000494e:	f022                	sd	s0,32(sp)
    80004950:	ec26                	sd	s1,24(sp)
    80004952:	e84a                	sd	s2,16(sp)
    80004954:	e44e                	sd	s3,8(sp)
    80004956:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004958:	00854783          	lbu	a5,8(a0)
    8000495c:	c3d5                	beqz	a5,80004a00 <fileread+0xb6>
    8000495e:	89b2                	mv	s3,a2
    80004960:	892e                	mv	s2,a1
    80004962:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80004964:	411c                	lw	a5,0(a0)
    80004966:	4705                	li	a4,1
    80004968:	04e78963          	beq	a5,a4,800049ba <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000496c:	470d                	li	a4,3
    8000496e:	04e78d63          	beq	a5,a4,800049c8 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004972:	4709                	li	a4,2
    80004974:	06e79e63          	bne	a5,a4,800049f0 <fileread+0xa6>
    ilock(f->ip);
    80004978:	6d08                	ld	a0,24(a0)
    8000497a:	fffff097          	auipc	ra,0xfffff
    8000497e:	fc8080e7          	jalr	-56(ra) # 80003942 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004982:	874e                	mv	a4,s3
    80004984:	5094                	lw	a3,32(s1)
    80004986:	864a                	mv	a2,s2
    80004988:	4585                	li	a1,1
    8000498a:	6c88                	ld	a0,24(s1)
    8000498c:	fffff097          	auipc	ra,0xfffff
    80004990:	26c080e7          	jalr	620(ra) # 80003bf8 <readi>
    80004994:	892a                	mv	s2,a0
    80004996:	00a05563          	blez	a0,800049a0 <fileread+0x56>
      f->off += r;
    8000499a:	509c                	lw	a5,32(s1)
    8000499c:	9fa9                	addw	a5,a5,a0
    8000499e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049a0:	6c88                	ld	a0,24(s1)
    800049a2:	fffff097          	auipc	ra,0xfffff
    800049a6:	064080e7          	jalr	100(ra) # 80003a06 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800049aa:	854a                	mv	a0,s2
    800049ac:	70a2                	ld	ra,40(sp)
    800049ae:	7402                	ld	s0,32(sp)
    800049b0:	64e2                	ld	s1,24(sp)
    800049b2:	6942                	ld	s2,16(sp)
    800049b4:	69a2                	ld	s3,8(sp)
    800049b6:	6145                	addi	sp,sp,48
    800049b8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800049ba:	6908                	ld	a0,16(a0)
    800049bc:	00000097          	auipc	ra,0x0
    800049c0:	416080e7          	jalr	1046(ra) # 80004dd2 <piperead>
    800049c4:	892a                	mv	s2,a0
    800049c6:	b7d5                	j	800049aa <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049c8:	02451783          	lh	a5,36(a0)
    800049cc:	03079693          	slli	a3,a5,0x30
    800049d0:	92c1                	srli	a3,a3,0x30
    800049d2:	4725                	li	a4,9
    800049d4:	02d76863          	bltu	a4,a3,80004a04 <fileread+0xba>
    800049d8:	0792                	slli	a5,a5,0x4
    800049da:	0023d717          	auipc	a4,0x23d
    800049de:	fd670713          	addi	a4,a4,-42 # 802419b0 <devsw>
    800049e2:	97ba                	add	a5,a5,a4
    800049e4:	639c                	ld	a5,0(a5)
    800049e6:	c38d                	beqz	a5,80004a08 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800049e8:	4505                	li	a0,1
    800049ea:	9782                	jalr	a5
    800049ec:	892a                	mv	s2,a0
    800049ee:	bf75                	j	800049aa <fileread+0x60>
    panic("fileread");
    800049f0:	00004517          	auipc	a0,0x4
    800049f4:	d7850513          	addi	a0,a0,-648 # 80008768 <syscalls+0x280>
    800049f8:	ffffc097          	auipc	ra,0xffffc
    800049fc:	b7c080e7          	jalr	-1156(ra) # 80000574 <panic>
    return -1;
    80004a00:	597d                	li	s2,-1
    80004a02:	b765                	j	800049aa <fileread+0x60>
      return -1;
    80004a04:	597d                	li	s2,-1
    80004a06:	b755                	j	800049aa <fileread+0x60>
    80004a08:	597d                	li	s2,-1
    80004a0a:	b745                	j	800049aa <fileread+0x60>

0000000080004a0c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004a0c:	00954783          	lbu	a5,9(a0)
    80004a10:	12078e63          	beqz	a5,80004b4c <filewrite+0x140>
{
    80004a14:	715d                	addi	sp,sp,-80
    80004a16:	e486                	sd	ra,72(sp)
    80004a18:	e0a2                	sd	s0,64(sp)
    80004a1a:	fc26                	sd	s1,56(sp)
    80004a1c:	f84a                	sd	s2,48(sp)
    80004a1e:	f44e                	sd	s3,40(sp)
    80004a20:	f052                	sd	s4,32(sp)
    80004a22:	ec56                	sd	s5,24(sp)
    80004a24:	e85a                	sd	s6,16(sp)
    80004a26:	e45e                	sd	s7,8(sp)
    80004a28:	e062                	sd	s8,0(sp)
    80004a2a:	0880                	addi	s0,sp,80
    80004a2c:	8ab2                	mv	s5,a2
    80004a2e:	8b2e                	mv	s6,a1
    80004a30:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80004a32:	411c                	lw	a5,0(a0)
    80004a34:	4705                	li	a4,1
    80004a36:	02e78263          	beq	a5,a4,80004a5a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a3a:	470d                	li	a4,3
    80004a3c:	02e78563          	beq	a5,a4,80004a66 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a40:	4709                	li	a4,2
    80004a42:	0ee79d63          	bne	a5,a4,80004b3c <filewrite+0x130>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a46:	0ec05763          	blez	a2,80004b34 <filewrite+0x128>
    int i = 0;
    80004a4a:	4901                	li	s2,0
    80004a4c:	6b85                	lui	s7,0x1
    80004a4e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004a52:	6c05                	lui	s8,0x1
    80004a54:	c00c0c1b          	addiw	s8,s8,-1024
    80004a58:	a061                	j	80004ae0 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    80004a5a:	6908                	ld	a0,16(a0)
    80004a5c:	00000097          	auipc	ra,0x0
    80004a60:	246080e7          	jalr	582(ra) # 80004ca2 <pipewrite>
    80004a64:	a065                	j	80004b0c <filewrite+0x100>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a66:	02451783          	lh	a5,36(a0)
    80004a6a:	03079693          	slli	a3,a5,0x30
    80004a6e:	92c1                	srli	a3,a3,0x30
    80004a70:	4725                	li	a4,9
    80004a72:	0cd76f63          	bltu	a4,a3,80004b50 <filewrite+0x144>
    80004a76:	0792                	slli	a5,a5,0x4
    80004a78:	0023d717          	auipc	a4,0x23d
    80004a7c:	f3870713          	addi	a4,a4,-200 # 802419b0 <devsw>
    80004a80:	97ba                	add	a5,a5,a4
    80004a82:	679c                	ld	a5,8(a5)
    80004a84:	cbe1                	beqz	a5,80004b54 <filewrite+0x148>
    ret = devsw[f->major].write(1, addr, n);
    80004a86:	4505                	li	a0,1
    80004a88:	9782                	jalr	a5
    80004a8a:	a049                	j	80004b0c <filewrite+0x100>
    80004a8c:	00098a1b          	sext.w	s4,s3
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a90:	00000097          	auipc	ra,0x0
    80004a94:	87e080e7          	jalr	-1922(ra) # 8000430e <begin_op>
      ilock(f->ip);
    80004a98:	6c88                	ld	a0,24(s1)
    80004a9a:	fffff097          	auipc	ra,0xfffff
    80004a9e:	ea8080e7          	jalr	-344(ra) # 80003942 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004aa2:	8752                	mv	a4,s4
    80004aa4:	5094                	lw	a3,32(s1)
    80004aa6:	01690633          	add	a2,s2,s6
    80004aaa:	4585                	li	a1,1
    80004aac:	6c88                	ld	a0,24(s1)
    80004aae:	fffff097          	auipc	ra,0xfffff
    80004ab2:	242080e7          	jalr	578(ra) # 80003cf0 <writei>
    80004ab6:	89aa                	mv	s3,a0
    80004ab8:	02a05c63          	blez	a0,80004af0 <filewrite+0xe4>
        f->off += r;
    80004abc:	509c                	lw	a5,32(s1)
    80004abe:	9fa9                	addw	a5,a5,a0
    80004ac0:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004ac2:	6c88                	ld	a0,24(s1)
    80004ac4:	fffff097          	auipc	ra,0xfffff
    80004ac8:	f42080e7          	jalr	-190(ra) # 80003a06 <iunlock>
      end_op();
    80004acc:	00000097          	auipc	ra,0x0
    80004ad0:	8c2080e7          	jalr	-1854(ra) # 8000438e <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004ad4:	05499863          	bne	s3,s4,80004b24 <filewrite+0x118>
        panic("short filewrite");
      i += r;
    80004ad8:	012a093b          	addw	s2,s4,s2
    while(i < n){
    80004adc:	03595563          	ble	s5,s2,80004b06 <filewrite+0xfa>
      int n1 = n - i;
    80004ae0:	412a87bb          	subw	a5,s5,s2
      if(n1 > max)
    80004ae4:	89be                	mv	s3,a5
    80004ae6:	2781                	sext.w	a5,a5
    80004ae8:	fafbd2e3          	ble	a5,s7,80004a8c <filewrite+0x80>
    80004aec:	89e2                	mv	s3,s8
    80004aee:	bf79                	j	80004a8c <filewrite+0x80>
      iunlock(f->ip);
    80004af0:	6c88                	ld	a0,24(s1)
    80004af2:	fffff097          	auipc	ra,0xfffff
    80004af6:	f14080e7          	jalr	-236(ra) # 80003a06 <iunlock>
      end_op();
    80004afa:	00000097          	auipc	ra,0x0
    80004afe:	894080e7          	jalr	-1900(ra) # 8000438e <end_op>
      if(r < 0)
    80004b02:	fc09d9e3          	bgez	s3,80004ad4 <filewrite+0xc8>
    }
    ret = (i == n ? n : -1);
    80004b06:	8556                	mv	a0,s5
    80004b08:	032a9863          	bne	s5,s2,80004b38 <filewrite+0x12c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b0c:	60a6                	ld	ra,72(sp)
    80004b0e:	6406                	ld	s0,64(sp)
    80004b10:	74e2                	ld	s1,56(sp)
    80004b12:	7942                	ld	s2,48(sp)
    80004b14:	79a2                	ld	s3,40(sp)
    80004b16:	7a02                	ld	s4,32(sp)
    80004b18:	6ae2                	ld	s5,24(sp)
    80004b1a:	6b42                	ld	s6,16(sp)
    80004b1c:	6ba2                	ld	s7,8(sp)
    80004b1e:	6c02                	ld	s8,0(sp)
    80004b20:	6161                	addi	sp,sp,80
    80004b22:	8082                	ret
        panic("short filewrite");
    80004b24:	00004517          	auipc	a0,0x4
    80004b28:	c5450513          	addi	a0,a0,-940 # 80008778 <syscalls+0x290>
    80004b2c:	ffffc097          	auipc	ra,0xffffc
    80004b30:	a48080e7          	jalr	-1464(ra) # 80000574 <panic>
    int i = 0;
    80004b34:	4901                	li	s2,0
    80004b36:	bfc1                	j	80004b06 <filewrite+0xfa>
    ret = (i == n ? n : -1);
    80004b38:	557d                	li	a0,-1
    80004b3a:	bfc9                	j	80004b0c <filewrite+0x100>
    panic("filewrite");
    80004b3c:	00004517          	auipc	a0,0x4
    80004b40:	c4c50513          	addi	a0,a0,-948 # 80008788 <syscalls+0x2a0>
    80004b44:	ffffc097          	auipc	ra,0xffffc
    80004b48:	a30080e7          	jalr	-1488(ra) # 80000574 <panic>
    return -1;
    80004b4c:	557d                	li	a0,-1
}
    80004b4e:	8082                	ret
      return -1;
    80004b50:	557d                	li	a0,-1
    80004b52:	bf6d                	j	80004b0c <filewrite+0x100>
    80004b54:	557d                	li	a0,-1
    80004b56:	bf5d                	j	80004b0c <filewrite+0x100>

0000000080004b58 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b58:	7179                	addi	sp,sp,-48
    80004b5a:	f406                	sd	ra,40(sp)
    80004b5c:	f022                	sd	s0,32(sp)
    80004b5e:	ec26                	sd	s1,24(sp)
    80004b60:	e84a                	sd	s2,16(sp)
    80004b62:	e44e                	sd	s3,8(sp)
    80004b64:	e052                	sd	s4,0(sp)
    80004b66:	1800                	addi	s0,sp,48
    80004b68:	84aa                	mv	s1,a0
    80004b6a:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b6c:	0005b023          	sd	zero,0(a1)
    80004b70:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b74:	00000097          	auipc	ra,0x0
    80004b78:	bcc080e7          	jalr	-1076(ra) # 80004740 <filealloc>
    80004b7c:	e088                	sd	a0,0(s1)
    80004b7e:	c551                	beqz	a0,80004c0a <pipealloc+0xb2>
    80004b80:	00000097          	auipc	ra,0x0
    80004b84:	bc0080e7          	jalr	-1088(ra) # 80004740 <filealloc>
    80004b88:	00a93023          	sd	a0,0(s2)
    80004b8c:	c92d                	beqz	a0,80004bfe <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b8e:	ffffc097          	auipc	ra,0xffffc
    80004b92:	03e080e7          	jalr	62(ra) # 80000bcc <kalloc>
    80004b96:	89aa                	mv	s3,a0
    80004b98:	c125                	beqz	a0,80004bf8 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b9a:	4a05                	li	s4,1
    80004b9c:	23452023          	sw	s4,544(a0)
  pi->writeopen = 1;
    80004ba0:	23452223          	sw	s4,548(a0)
  pi->nwrite = 0;
    80004ba4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ba8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004bac:	00004597          	auipc	a1,0x4
    80004bb0:	bec58593          	addi	a1,a1,-1044 # 80008798 <syscalls+0x2b0>
    80004bb4:	ffffc097          	auipc	ra,0xffffc
    80004bb8:	11a080e7          	jalr	282(ra) # 80000cce <initlock>
  (*f0)->type = FD_PIPE;
    80004bbc:	609c                	ld	a5,0(s1)
    80004bbe:	0147a023          	sw	s4,0(a5)
  (*f0)->readable = 1;
    80004bc2:	609c                	ld	a5,0(s1)
    80004bc4:	01478423          	sb	s4,8(a5)
  (*f0)->writable = 0;
    80004bc8:	609c                	ld	a5,0(s1)
    80004bca:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004bce:	609c                	ld	a5,0(s1)
    80004bd0:	0137b823          	sd	s3,16(a5)
  (*f1)->type = FD_PIPE;
    80004bd4:	00093783          	ld	a5,0(s2)
    80004bd8:	0147a023          	sw	s4,0(a5)
  (*f1)->readable = 0;
    80004bdc:	00093783          	ld	a5,0(s2)
    80004be0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004be4:	00093783          	ld	a5,0(s2)
    80004be8:	014784a3          	sb	s4,9(a5)
  (*f1)->pipe = pi;
    80004bec:	00093783          	ld	a5,0(s2)
    80004bf0:	0137b823          	sd	s3,16(a5)
  return 0;
    80004bf4:	4501                	li	a0,0
    80004bf6:	a025                	j	80004c1e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004bf8:	6088                	ld	a0,0(s1)
    80004bfa:	e501                	bnez	a0,80004c02 <pipealloc+0xaa>
    80004bfc:	a039                	j	80004c0a <pipealloc+0xb2>
    80004bfe:	6088                	ld	a0,0(s1)
    80004c00:	c51d                	beqz	a0,80004c2e <pipealloc+0xd6>
    fileclose(*f0);
    80004c02:	00000097          	auipc	ra,0x0
    80004c06:	c0e080e7          	jalr	-1010(ra) # 80004810 <fileclose>
  if(*f1)
    80004c0a:	00093783          	ld	a5,0(s2)
    fileclose(*f1);
  return -1;
    80004c0e:	557d                	li	a0,-1
  if(*f1)
    80004c10:	c799                	beqz	a5,80004c1e <pipealloc+0xc6>
    fileclose(*f1);
    80004c12:	853e                	mv	a0,a5
    80004c14:	00000097          	auipc	ra,0x0
    80004c18:	bfc080e7          	jalr	-1028(ra) # 80004810 <fileclose>
  return -1;
    80004c1c:	557d                	li	a0,-1
}
    80004c1e:	70a2                	ld	ra,40(sp)
    80004c20:	7402                	ld	s0,32(sp)
    80004c22:	64e2                	ld	s1,24(sp)
    80004c24:	6942                	ld	s2,16(sp)
    80004c26:	69a2                	ld	s3,8(sp)
    80004c28:	6a02                	ld	s4,0(sp)
    80004c2a:	6145                	addi	sp,sp,48
    80004c2c:	8082                	ret
  return -1;
    80004c2e:	557d                	li	a0,-1
    80004c30:	b7fd                	j	80004c1e <pipealloc+0xc6>

0000000080004c32 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c32:	1101                	addi	sp,sp,-32
    80004c34:	ec06                	sd	ra,24(sp)
    80004c36:	e822                	sd	s0,16(sp)
    80004c38:	e426                	sd	s1,8(sp)
    80004c3a:	e04a                	sd	s2,0(sp)
    80004c3c:	1000                	addi	s0,sp,32
    80004c3e:	84aa                	mv	s1,a0
    80004c40:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c42:	ffffc097          	auipc	ra,0xffffc
    80004c46:	11c080e7          	jalr	284(ra) # 80000d5e <acquire>
  if(writable){
    80004c4a:	02090d63          	beqz	s2,80004c84 <pipeclose+0x52>
    pi->writeopen = 0;
    80004c4e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c52:	21848513          	addi	a0,s1,536
    80004c56:	ffffe097          	auipc	ra,0xffffe
    80004c5a:	9d8080e7          	jalr	-1576(ra) # 8000262e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c5e:	2204b783          	ld	a5,544(s1)
    80004c62:	eb95                	bnez	a5,80004c96 <pipeclose+0x64>
    release(&pi->lock);
    80004c64:	8526                	mv	a0,s1
    80004c66:	ffffc097          	auipc	ra,0xffffc
    80004c6a:	1ac080e7          	jalr	428(ra) # 80000e12 <release>
    kfree((char*)pi);
    80004c6e:	8526                	mv	a0,s1
    80004c70:	ffffc097          	auipc	ra,0xffffc
    80004c74:	e02080e7          	jalr	-510(ra) # 80000a72 <kfree>
  } else
    release(&pi->lock);
}
    80004c78:	60e2                	ld	ra,24(sp)
    80004c7a:	6442                	ld	s0,16(sp)
    80004c7c:	64a2                	ld	s1,8(sp)
    80004c7e:	6902                	ld	s2,0(sp)
    80004c80:	6105                	addi	sp,sp,32
    80004c82:	8082                	ret
    pi->readopen = 0;
    80004c84:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c88:	21c48513          	addi	a0,s1,540
    80004c8c:	ffffe097          	auipc	ra,0xffffe
    80004c90:	9a2080e7          	jalr	-1630(ra) # 8000262e <wakeup>
    80004c94:	b7e9                	j	80004c5e <pipeclose+0x2c>
    release(&pi->lock);
    80004c96:	8526                	mv	a0,s1
    80004c98:	ffffc097          	auipc	ra,0xffffc
    80004c9c:	17a080e7          	jalr	378(ra) # 80000e12 <release>
}
    80004ca0:	bfe1                	j	80004c78 <pipeclose+0x46>

0000000080004ca2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ca2:	7119                	addi	sp,sp,-128
    80004ca4:	fc86                	sd	ra,120(sp)
    80004ca6:	f8a2                	sd	s0,112(sp)
    80004ca8:	f4a6                	sd	s1,104(sp)
    80004caa:	f0ca                	sd	s2,96(sp)
    80004cac:	ecce                	sd	s3,88(sp)
    80004cae:	e8d2                	sd	s4,80(sp)
    80004cb0:	e4d6                	sd	s5,72(sp)
    80004cb2:	e0da                	sd	s6,64(sp)
    80004cb4:	fc5e                	sd	s7,56(sp)
    80004cb6:	f862                	sd	s8,48(sp)
    80004cb8:	f466                	sd	s9,40(sp)
    80004cba:	f06a                	sd	s10,32(sp)
    80004cbc:	ec6e                	sd	s11,24(sp)
    80004cbe:	0100                	addi	s0,sp,128
    80004cc0:	84aa                	mv	s1,a0
    80004cc2:	8d2e                	mv	s10,a1
    80004cc4:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004cc6:	ffffd097          	auipc	ra,0xffffd
    80004cca:	fc8080e7          	jalr	-56(ra) # 80001c8e <myproc>
    80004cce:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004cd0:	8526                	mv	a0,s1
    80004cd2:	ffffc097          	auipc	ra,0xffffc
    80004cd6:	08c080e7          	jalr	140(ra) # 80000d5e <acquire>
  for(i = 0; i < n; i++){
    80004cda:	0d605f63          	blez	s6,80004db8 <pipewrite+0x116>
    80004cde:	89a6                	mv	s3,s1
    80004ce0:	3b7d                	addiw	s6,s6,-1
    80004ce2:	1b02                	slli	s6,s6,0x20
    80004ce4:	020b5b13          	srli	s6,s6,0x20
    80004ce8:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004cea:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004cee:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cf2:	5dfd                	li	s11,-1
    80004cf4:	000b8c9b          	sext.w	s9,s7
    80004cf8:	8c66                	mv	s8,s9
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004cfa:	2184a783          	lw	a5,536(s1)
    80004cfe:	21c4a703          	lw	a4,540(s1)
    80004d02:	2007879b          	addiw	a5,a5,512
    80004d06:	06f71763          	bne	a4,a5,80004d74 <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004d0a:	2204a783          	lw	a5,544(s1)
    80004d0e:	cf8d                	beqz	a5,80004d48 <pipewrite+0xa6>
    80004d10:	03092783          	lw	a5,48(s2)
    80004d14:	eb95                	bnez	a5,80004d48 <pipewrite+0xa6>
      wakeup(&pi->nread);
    80004d16:	8556                	mv	a0,s5
    80004d18:	ffffe097          	auipc	ra,0xffffe
    80004d1c:	916080e7          	jalr	-1770(ra) # 8000262e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d20:	85ce                	mv	a1,s3
    80004d22:	8552                	mv	a0,s4
    80004d24:	ffffd097          	auipc	ra,0xffffd
    80004d28:	784080e7          	jalr	1924(ra) # 800024a8 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004d2c:	2184a783          	lw	a5,536(s1)
    80004d30:	21c4a703          	lw	a4,540(s1)
    80004d34:	2007879b          	addiw	a5,a5,512
    80004d38:	02f71e63          	bne	a4,a5,80004d74 <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004d3c:	2204a783          	lw	a5,544(s1)
    80004d40:	c781                	beqz	a5,80004d48 <pipewrite+0xa6>
    80004d42:	03092783          	lw	a5,48(s2)
    80004d46:	dbe1                	beqz	a5,80004d16 <pipewrite+0x74>
        release(&pi->lock);
    80004d48:	8526                	mv	a0,s1
    80004d4a:	ffffc097          	auipc	ra,0xffffc
    80004d4e:	0c8080e7          	jalr	200(ra) # 80000e12 <release>
        return -1;
    80004d52:	5c7d                	li	s8,-1
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004d54:	8562                	mv	a0,s8
    80004d56:	70e6                	ld	ra,120(sp)
    80004d58:	7446                	ld	s0,112(sp)
    80004d5a:	74a6                	ld	s1,104(sp)
    80004d5c:	7906                	ld	s2,96(sp)
    80004d5e:	69e6                	ld	s3,88(sp)
    80004d60:	6a46                	ld	s4,80(sp)
    80004d62:	6aa6                	ld	s5,72(sp)
    80004d64:	6b06                	ld	s6,64(sp)
    80004d66:	7be2                	ld	s7,56(sp)
    80004d68:	7c42                	ld	s8,48(sp)
    80004d6a:	7ca2                	ld	s9,40(sp)
    80004d6c:	7d02                	ld	s10,32(sp)
    80004d6e:	6de2                	ld	s11,24(sp)
    80004d70:	6109                	addi	sp,sp,128
    80004d72:	8082                	ret
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d74:	4685                	li	a3,1
    80004d76:	01ab8633          	add	a2,s7,s10
    80004d7a:	f8f40593          	addi	a1,s0,-113
    80004d7e:	05093503          	ld	a0,80(s2)
    80004d82:	ffffd097          	auipc	ra,0xffffd
    80004d86:	ab0080e7          	jalr	-1360(ra) # 80001832 <copyin>
    80004d8a:	03b50863          	beq	a0,s11,80004dba <pipewrite+0x118>
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d8e:	21c4a783          	lw	a5,540(s1)
    80004d92:	0017871b          	addiw	a4,a5,1
    80004d96:	20e4ae23          	sw	a4,540(s1)
    80004d9a:	1ff7f793          	andi	a5,a5,511
    80004d9e:	97a6                	add	a5,a5,s1
    80004da0:	f8f44703          	lbu	a4,-113(s0)
    80004da4:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004da8:	001c8c1b          	addiw	s8,s9,1
    80004dac:	001b8793          	addi	a5,s7,1
    80004db0:	016b8563          	beq	s7,s6,80004dba <pipewrite+0x118>
    80004db4:	8bbe                	mv	s7,a5
    80004db6:	bf3d                	j	80004cf4 <pipewrite+0x52>
    80004db8:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004dba:	21848513          	addi	a0,s1,536
    80004dbe:	ffffe097          	auipc	ra,0xffffe
    80004dc2:	870080e7          	jalr	-1936(ra) # 8000262e <wakeup>
  release(&pi->lock);
    80004dc6:	8526                	mv	a0,s1
    80004dc8:	ffffc097          	auipc	ra,0xffffc
    80004dcc:	04a080e7          	jalr	74(ra) # 80000e12 <release>
  return i;
    80004dd0:	b751                	j	80004d54 <pipewrite+0xb2>

0000000080004dd2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004dd2:	715d                	addi	sp,sp,-80
    80004dd4:	e486                	sd	ra,72(sp)
    80004dd6:	e0a2                	sd	s0,64(sp)
    80004dd8:	fc26                	sd	s1,56(sp)
    80004dda:	f84a                	sd	s2,48(sp)
    80004ddc:	f44e                	sd	s3,40(sp)
    80004dde:	f052                	sd	s4,32(sp)
    80004de0:	ec56                	sd	s5,24(sp)
    80004de2:	e85a                	sd	s6,16(sp)
    80004de4:	0880                	addi	s0,sp,80
    80004de6:	84aa                	mv	s1,a0
    80004de8:	89ae                	mv	s3,a1
    80004dea:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004dec:	ffffd097          	auipc	ra,0xffffd
    80004df0:	ea2080e7          	jalr	-350(ra) # 80001c8e <myproc>
    80004df4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004df6:	8526                	mv	a0,s1
    80004df8:	ffffc097          	auipc	ra,0xffffc
    80004dfc:	f66080e7          	jalr	-154(ra) # 80000d5e <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e00:	2184a703          	lw	a4,536(s1)
    80004e04:	21c4a783          	lw	a5,540(s1)
    80004e08:	06f71b63          	bne	a4,a5,80004e7e <piperead+0xac>
    80004e0c:	8926                	mv	s2,s1
    80004e0e:	2244a783          	lw	a5,548(s1)
    80004e12:	cf9d                	beqz	a5,80004e50 <piperead+0x7e>
    if(pr->killed){
    80004e14:	030a2783          	lw	a5,48(s4)
    80004e18:	e78d                	bnez	a5,80004e42 <piperead+0x70>
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e1a:	21848b13          	addi	s6,s1,536
    80004e1e:	85ca                	mv	a1,s2
    80004e20:	855a                	mv	a0,s6
    80004e22:	ffffd097          	auipc	ra,0xffffd
    80004e26:	686080e7          	jalr	1670(ra) # 800024a8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e2a:	2184a703          	lw	a4,536(s1)
    80004e2e:	21c4a783          	lw	a5,540(s1)
    80004e32:	04f71663          	bne	a4,a5,80004e7e <piperead+0xac>
    80004e36:	2244a783          	lw	a5,548(s1)
    80004e3a:	cb99                	beqz	a5,80004e50 <piperead+0x7e>
    if(pr->killed){
    80004e3c:	030a2783          	lw	a5,48(s4)
    80004e40:	dff9                	beqz	a5,80004e1e <piperead+0x4c>
      release(&pi->lock);
    80004e42:	8526                	mv	a0,s1
    80004e44:	ffffc097          	auipc	ra,0xffffc
    80004e48:	fce080e7          	jalr	-50(ra) # 80000e12 <release>
      return -1;
    80004e4c:	597d                	li	s2,-1
    80004e4e:	a829                	j	80004e68 <piperead+0x96>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(pi->nread == pi->nwrite)
    80004e50:	4901                	li	s2,0
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e52:	21c48513          	addi	a0,s1,540
    80004e56:	ffffd097          	auipc	ra,0xffffd
    80004e5a:	7d8080e7          	jalr	2008(ra) # 8000262e <wakeup>
  release(&pi->lock);
    80004e5e:	8526                	mv	a0,s1
    80004e60:	ffffc097          	auipc	ra,0xffffc
    80004e64:	fb2080e7          	jalr	-78(ra) # 80000e12 <release>
  return i;
}
    80004e68:	854a                	mv	a0,s2
    80004e6a:	60a6                	ld	ra,72(sp)
    80004e6c:	6406                	ld	s0,64(sp)
    80004e6e:	74e2                	ld	s1,56(sp)
    80004e70:	7942                	ld	s2,48(sp)
    80004e72:	79a2                	ld	s3,40(sp)
    80004e74:	7a02                	ld	s4,32(sp)
    80004e76:	6ae2                	ld	s5,24(sp)
    80004e78:	6b42                	ld	s6,16(sp)
    80004e7a:	6161                	addi	sp,sp,80
    80004e7c:	8082                	ret
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e7e:	4901                	li	s2,0
    80004e80:	fd5059e3          	blez	s5,80004e52 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004e84:	2184a783          	lw	a5,536(s1)
    80004e88:	4901                	li	s2,0
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e8a:	5b7d                	li	s6,-1
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e8c:	0017871b          	addiw	a4,a5,1
    80004e90:	20e4ac23          	sw	a4,536(s1)
    80004e94:	1ff7f793          	andi	a5,a5,511
    80004e98:	97a6                	add	a5,a5,s1
    80004e9a:	0187c783          	lbu	a5,24(a5)
    80004e9e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ea2:	4685                	li	a3,1
    80004ea4:	fbf40613          	addi	a2,s0,-65
    80004ea8:	85ce                	mv	a1,s3
    80004eaa:	050a3503          	ld	a0,80(s4)
    80004eae:	ffffd097          	auipc	ra,0xffffd
    80004eb2:	ba4080e7          	jalr	-1116(ra) # 80001a52 <copyout>
    80004eb6:	f9650ee3          	beq	a0,s6,80004e52 <piperead+0x80>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004eba:	2905                	addiw	s2,s2,1
    80004ebc:	f92a8be3          	beq	s5,s2,80004e52 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004ec0:	2184a783          	lw	a5,536(s1)
    80004ec4:	0985                	addi	s3,s3,1
    80004ec6:	21c4a703          	lw	a4,540(s1)
    80004eca:	fcf711e3          	bne	a4,a5,80004e8c <piperead+0xba>
    80004ece:	b751                	j	80004e52 <piperead+0x80>

0000000080004ed0 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004ed0:	de010113          	addi	sp,sp,-544
    80004ed4:	20113c23          	sd	ra,536(sp)
    80004ed8:	20813823          	sd	s0,528(sp)
    80004edc:	20913423          	sd	s1,520(sp)
    80004ee0:	21213023          	sd	s2,512(sp)
    80004ee4:	ffce                	sd	s3,504(sp)
    80004ee6:	fbd2                	sd	s4,496(sp)
    80004ee8:	f7d6                	sd	s5,488(sp)
    80004eea:	f3da                	sd	s6,480(sp)
    80004eec:	efde                	sd	s7,472(sp)
    80004eee:	ebe2                	sd	s8,464(sp)
    80004ef0:	e7e6                	sd	s9,456(sp)
    80004ef2:	e3ea                	sd	s10,448(sp)
    80004ef4:	ff6e                	sd	s11,440(sp)
    80004ef6:	1400                	addi	s0,sp,544
    80004ef8:	892a                	mv	s2,a0
    80004efa:	dea43823          	sd	a0,-528(s0)
    80004efe:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f02:	ffffd097          	auipc	ra,0xffffd
    80004f06:	d8c080e7          	jalr	-628(ra) # 80001c8e <myproc>
    80004f0a:	84aa                	mv	s1,a0

  begin_op();
    80004f0c:	fffff097          	auipc	ra,0xfffff
    80004f10:	402080e7          	jalr	1026(ra) # 8000430e <begin_op>

  if((ip = namei(path)) == 0){
    80004f14:	854a                	mv	a0,s2
    80004f16:	fffff097          	auipc	ra,0xfffff
    80004f1a:	1ea080e7          	jalr	490(ra) # 80004100 <namei>
    80004f1e:	c93d                	beqz	a0,80004f94 <exec+0xc4>
    80004f20:	892a                	mv	s2,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f22:	fffff097          	auipc	ra,0xfffff
    80004f26:	a20080e7          	jalr	-1504(ra) # 80003942 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f2a:	04000713          	li	a4,64
    80004f2e:	4681                	li	a3,0
    80004f30:	e4840613          	addi	a2,s0,-440
    80004f34:	4581                	li	a1,0
    80004f36:	854a                	mv	a0,s2
    80004f38:	fffff097          	auipc	ra,0xfffff
    80004f3c:	cc0080e7          	jalr	-832(ra) # 80003bf8 <readi>
    80004f40:	04000793          	li	a5,64
    80004f44:	00f51a63          	bne	a0,a5,80004f58 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004f48:	e4842703          	lw	a4,-440(s0)
    80004f4c:	464c47b7          	lui	a5,0x464c4
    80004f50:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f54:	04f70663          	beq	a4,a5,80004fa0 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f58:	854a                	mv	a0,s2
    80004f5a:	fffff097          	auipc	ra,0xfffff
    80004f5e:	c4c080e7          	jalr	-948(ra) # 80003ba6 <iunlockput>
    end_op();
    80004f62:	fffff097          	auipc	ra,0xfffff
    80004f66:	42c080e7          	jalr	1068(ra) # 8000438e <end_op>
  }
  return -1;
    80004f6a:	557d                	li	a0,-1
}
    80004f6c:	21813083          	ld	ra,536(sp)
    80004f70:	21013403          	ld	s0,528(sp)
    80004f74:	20813483          	ld	s1,520(sp)
    80004f78:	20013903          	ld	s2,512(sp)
    80004f7c:	79fe                	ld	s3,504(sp)
    80004f7e:	7a5e                	ld	s4,496(sp)
    80004f80:	7abe                	ld	s5,488(sp)
    80004f82:	7b1e                	ld	s6,480(sp)
    80004f84:	6bfe                	ld	s7,472(sp)
    80004f86:	6c5e                	ld	s8,464(sp)
    80004f88:	6cbe                	ld	s9,456(sp)
    80004f8a:	6d1e                	ld	s10,448(sp)
    80004f8c:	7dfa                	ld	s11,440(sp)
    80004f8e:	22010113          	addi	sp,sp,544
    80004f92:	8082                	ret
    end_op();
    80004f94:	fffff097          	auipc	ra,0xfffff
    80004f98:	3fa080e7          	jalr	1018(ra) # 8000438e <end_op>
    return -1;
    80004f9c:	557d                	li	a0,-1
    80004f9e:	b7f9                	j	80004f6c <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004fa0:	8526                	mv	a0,s1
    80004fa2:	ffffd097          	auipc	ra,0xffffd
    80004fa6:	db2080e7          	jalr	-590(ra) # 80001d54 <proc_pagetable>
    80004faa:	e0a43423          	sd	a0,-504(s0)
    80004fae:	d54d                	beqz	a0,80004f58 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fb0:	e6842983          	lw	s3,-408(s0)
    80004fb4:	e8045783          	lhu	a5,-384(s0)
    80004fb8:	c7ad                	beqz	a5,80005022 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004fba:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fbc:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004fbe:	6c05                	lui	s8,0x1
    80004fc0:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    80004fc4:	def43423          	sd	a5,-536(s0)
    80004fc8:	7cfd                	lui	s9,0xfffff
    80004fca:	ac1d                	j	80005200 <exec+0x330>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004fcc:	00003517          	auipc	a0,0x3
    80004fd0:	7d450513          	addi	a0,a0,2004 # 800087a0 <syscalls+0x2b8>
    80004fd4:	ffffb097          	auipc	ra,0xffffb
    80004fd8:	5a0080e7          	jalr	1440(ra) # 80000574 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004fdc:	8756                	mv	a4,s5
    80004fde:	009d86bb          	addw	a3,s11,s1
    80004fe2:	4581                	li	a1,0
    80004fe4:	854a                	mv	a0,s2
    80004fe6:	fffff097          	auipc	ra,0xfffff
    80004fea:	c12080e7          	jalr	-1006(ra) # 80003bf8 <readi>
    80004fee:	2501                	sext.w	a0,a0
    80004ff0:	1aaa9e63          	bne	s5,a0,800051ac <exec+0x2dc>
  for(i = 0; i < sz; i += PGSIZE){
    80004ff4:	6785                	lui	a5,0x1
    80004ff6:	9cbd                	addw	s1,s1,a5
    80004ff8:	014c8a3b          	addw	s4,s9,s4
    80004ffc:	1f74f963          	bleu	s7,s1,800051ee <exec+0x31e>
    pa = walkaddr(pagetable, va + i);
    80005000:	02049593          	slli	a1,s1,0x20
    80005004:	9181                	srli	a1,a1,0x20
    80005006:	95ea                	add	a1,a1,s10
    80005008:	e0843503          	ld	a0,-504(s0)
    8000500c:	ffffc097          	auipc	ra,0xffffc
    80005010:	204080e7          	jalr	516(ra) # 80001210 <walkaddr>
    80005014:	862a                	mv	a2,a0
    if(pa == 0)
    80005016:	d95d                	beqz	a0,80004fcc <exec+0xfc>
      n = PGSIZE;
    80005018:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    8000501a:	fd8a71e3          	bleu	s8,s4,80004fdc <exec+0x10c>
      n = sz - i;
    8000501e:	8ad2                	mv	s5,s4
    80005020:	bf75                	j	80004fdc <exec+0x10c>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005022:	4481                	li	s1,0
  iunlockput(ip);
    80005024:	854a                	mv	a0,s2
    80005026:	fffff097          	auipc	ra,0xfffff
    8000502a:	b80080e7          	jalr	-1152(ra) # 80003ba6 <iunlockput>
  end_op();
    8000502e:	fffff097          	auipc	ra,0xfffff
    80005032:	360080e7          	jalr	864(ra) # 8000438e <end_op>
  p = myproc();
    80005036:	ffffd097          	auipc	ra,0xffffd
    8000503a:	c58080e7          	jalr	-936(ra) # 80001c8e <myproc>
    8000503e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005040:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005044:	6785                	lui	a5,0x1
    80005046:	17fd                	addi	a5,a5,-1
    80005048:	94be                	add	s1,s1,a5
    8000504a:	77fd                	lui	a5,0xfffff
    8000504c:	8fe5                	and	a5,a5,s1
    8000504e:	e0f43023          	sd	a5,-512(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005052:	6609                	lui	a2,0x2
    80005054:	963e                	add	a2,a2,a5
    80005056:	85be                	mv	a1,a5
    80005058:	e0843483          	ld	s1,-504(s0)
    8000505c:	8526                	mv	a0,s1
    8000505e:	ffffc097          	auipc	ra,0xffffc
    80005062:	59a080e7          	jalr	1434(ra) # 800015f8 <uvmalloc>
    80005066:	8b2a                	mv	s6,a0
  ip = 0;
    80005068:	4901                	li	s2,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000506a:	14050163          	beqz	a0,800051ac <exec+0x2dc>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000506e:	75f9                	lui	a1,0xffffe
    80005070:	95aa                	add	a1,a1,a0
    80005072:	8526                	mv	a0,s1
    80005074:	ffffc097          	auipc	ra,0xffffc
    80005078:	78c080e7          	jalr	1932(ra) # 80001800 <uvmclear>
  stackbase = sp - PGSIZE;
    8000507c:	7bfd                	lui	s7,0xfffff
    8000507e:	9bda                	add	s7,s7,s6
  for(argc = 0; argv[argc]; argc++) {
    80005080:	df843783          	ld	a5,-520(s0)
    80005084:	6388                	ld	a0,0(a5)
    80005086:	c925                	beqz	a0,800050f6 <exec+0x226>
    80005088:	e8840993          	addi	s3,s0,-376
    8000508c:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80005090:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005092:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005094:	ffffc097          	auipc	ra,0xffffc
    80005098:	f70080e7          	jalr	-144(ra) # 80001004 <strlen>
    8000509c:	2505                	addiw	a0,a0,1
    8000509e:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050a2:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800050a6:	13796863          	bltu	s2,s7,800051d6 <exec+0x306>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800050aa:	df843c83          	ld	s9,-520(s0)
    800050ae:	000cba03          	ld	s4,0(s9) # fffffffffffff000 <end+0xffffffff7fdb9000>
    800050b2:	8552                	mv	a0,s4
    800050b4:	ffffc097          	auipc	ra,0xffffc
    800050b8:	f50080e7          	jalr	-176(ra) # 80001004 <strlen>
    800050bc:	0015069b          	addiw	a3,a0,1
    800050c0:	8652                	mv	a2,s4
    800050c2:	85ca                	mv	a1,s2
    800050c4:	e0843503          	ld	a0,-504(s0)
    800050c8:	ffffd097          	auipc	ra,0xffffd
    800050cc:	98a080e7          	jalr	-1654(ra) # 80001a52 <copyout>
    800050d0:	10054763          	bltz	a0,800051de <exec+0x30e>
    ustack[argc] = sp;
    800050d4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800050d8:	0485                	addi	s1,s1,1
    800050da:	008c8793          	addi	a5,s9,8
    800050de:	def43c23          	sd	a5,-520(s0)
    800050e2:	008cb503          	ld	a0,8(s9)
    800050e6:	c911                	beqz	a0,800050fa <exec+0x22a>
    if(argc >= MAXARG)
    800050e8:	09a1                	addi	s3,s3,8
    800050ea:	fb8995e3          	bne	s3,s8,80005094 <exec+0x1c4>
  sz = sz1;
    800050ee:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    800050f2:	4901                	li	s2,0
    800050f4:	a865                	j	800051ac <exec+0x2dc>
  sp = sz;
    800050f6:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800050f8:	4481                	li	s1,0
  ustack[argc] = 0;
    800050fa:	00349793          	slli	a5,s1,0x3
    800050fe:	f9040713          	addi	a4,s0,-112
    80005102:	97ba                	add	a5,a5,a4
    80005104:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7fdb8ef8>
  sp -= (argc+1) * sizeof(uint64);
    80005108:	00148693          	addi	a3,s1,1
    8000510c:	068e                	slli	a3,a3,0x3
    8000510e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005112:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005116:	01797663          	bleu	s7,s2,80005122 <exec+0x252>
  sz = sz1;
    8000511a:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    8000511e:	4901                	li	s2,0
    80005120:	a071                	j	800051ac <exec+0x2dc>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005122:	e8840613          	addi	a2,s0,-376
    80005126:	85ca                	mv	a1,s2
    80005128:	e0843503          	ld	a0,-504(s0)
    8000512c:	ffffd097          	auipc	ra,0xffffd
    80005130:	926080e7          	jalr	-1754(ra) # 80001a52 <copyout>
    80005134:	0a054963          	bltz	a0,800051e6 <exec+0x316>
  p->trapframe->a1 = sp;
    80005138:	058ab783          	ld	a5,88(s5)
    8000513c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005140:	df043783          	ld	a5,-528(s0)
    80005144:	0007c703          	lbu	a4,0(a5)
    80005148:	cf11                	beqz	a4,80005164 <exec+0x294>
    8000514a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000514c:	02f00693          	li	a3,47
    80005150:	a029                	j	8000515a <exec+0x28a>
  for(last=s=path; *s; s++)
    80005152:	0785                	addi	a5,a5,1
    80005154:	fff7c703          	lbu	a4,-1(a5)
    80005158:	c711                	beqz	a4,80005164 <exec+0x294>
    if(*s == '/')
    8000515a:	fed71ce3          	bne	a4,a3,80005152 <exec+0x282>
      last = s+1;
    8000515e:	def43823          	sd	a5,-528(s0)
    80005162:	bfc5                	j	80005152 <exec+0x282>
  safestrcpy(p->name, last, sizeof(p->name));
    80005164:	4641                	li	a2,16
    80005166:	df043583          	ld	a1,-528(s0)
    8000516a:	158a8513          	addi	a0,s5,344
    8000516e:	ffffc097          	auipc	ra,0xffffc
    80005172:	e64080e7          	jalr	-412(ra) # 80000fd2 <safestrcpy>
  oldpagetable = p->pagetable;
    80005176:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000517a:	e0843783          	ld	a5,-504(s0)
    8000517e:	04fab823          	sd	a5,80(s5)
  p->sz = sz;
    80005182:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005186:	058ab783          	ld	a5,88(s5)
    8000518a:	e6043703          	ld	a4,-416(s0)
    8000518e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005190:	058ab783          	ld	a5,88(s5)
    80005194:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005198:	85ea                	mv	a1,s10
    8000519a:	ffffd097          	auipc	ra,0xffffd
    8000519e:	c56080e7          	jalr	-938(ra) # 80001df0 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051a2:	0004851b          	sext.w	a0,s1
    800051a6:	b3d9                	j	80004f6c <exec+0x9c>
    800051a8:	e0943023          	sd	s1,-512(s0)
    proc_freepagetable(pagetable, sz);
    800051ac:	e0043583          	ld	a1,-512(s0)
    800051b0:	e0843503          	ld	a0,-504(s0)
    800051b4:	ffffd097          	auipc	ra,0xffffd
    800051b8:	c3c080e7          	jalr	-964(ra) # 80001df0 <proc_freepagetable>
  if(ip){
    800051bc:	d8091ee3          	bnez	s2,80004f58 <exec+0x88>
  return -1;
    800051c0:	557d                	li	a0,-1
    800051c2:	b36d                	j	80004f6c <exec+0x9c>
    800051c4:	e0943023          	sd	s1,-512(s0)
    800051c8:	b7d5                	j	800051ac <exec+0x2dc>
    800051ca:	e0943023          	sd	s1,-512(s0)
    800051ce:	bff9                	j	800051ac <exec+0x2dc>
    800051d0:	e0943023          	sd	s1,-512(s0)
    800051d4:	bfe1                	j	800051ac <exec+0x2dc>
  sz = sz1;
    800051d6:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    800051da:	4901                	li	s2,0
    800051dc:	bfc1                	j	800051ac <exec+0x2dc>
  sz = sz1;
    800051de:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    800051e2:	4901                	li	s2,0
    800051e4:	b7e1                	j	800051ac <exec+0x2dc>
  sz = sz1;
    800051e6:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    800051ea:	4901                	li	s2,0
    800051ec:	b7c1                	j	800051ac <exec+0x2dc>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800051ee:	e0043483          	ld	s1,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051f2:	2b05                	addiw	s6,s6,1
    800051f4:	0389899b          	addiw	s3,s3,56
    800051f8:	e8045783          	lhu	a5,-384(s0)
    800051fc:	e2fb54e3          	ble	a5,s6,80005024 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005200:	2981                	sext.w	s3,s3
    80005202:	03800713          	li	a4,56
    80005206:	86ce                	mv	a3,s3
    80005208:	e1040613          	addi	a2,s0,-496
    8000520c:	4581                	li	a1,0
    8000520e:	854a                	mv	a0,s2
    80005210:	fffff097          	auipc	ra,0xfffff
    80005214:	9e8080e7          	jalr	-1560(ra) # 80003bf8 <readi>
    80005218:	03800793          	li	a5,56
    8000521c:	f8f516e3          	bne	a0,a5,800051a8 <exec+0x2d8>
    if(ph.type != ELF_PROG_LOAD)
    80005220:	e1042783          	lw	a5,-496(s0)
    80005224:	4705                	li	a4,1
    80005226:	fce796e3          	bne	a5,a4,800051f2 <exec+0x322>
    if(ph.memsz < ph.filesz)
    8000522a:	e3843603          	ld	a2,-456(s0)
    8000522e:	e3043783          	ld	a5,-464(s0)
    80005232:	f8f669e3          	bltu	a2,a5,800051c4 <exec+0x2f4>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005236:	e2043783          	ld	a5,-480(s0)
    8000523a:	963e                	add	a2,a2,a5
    8000523c:	f8f667e3          	bltu	a2,a5,800051ca <exec+0x2fa>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005240:	85a6                	mv	a1,s1
    80005242:	e0843503          	ld	a0,-504(s0)
    80005246:	ffffc097          	auipc	ra,0xffffc
    8000524a:	3b2080e7          	jalr	946(ra) # 800015f8 <uvmalloc>
    8000524e:	e0a43023          	sd	a0,-512(s0)
    80005252:	dd3d                	beqz	a0,800051d0 <exec+0x300>
    if(ph.vaddr % PGSIZE != 0)
    80005254:	e2043d03          	ld	s10,-480(s0)
    80005258:	de843783          	ld	a5,-536(s0)
    8000525c:	00fd77b3          	and	a5,s10,a5
    80005260:	f7b1                	bnez	a5,800051ac <exec+0x2dc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005262:	e1842d83          	lw	s11,-488(s0)
    80005266:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000526a:	f80b82e3          	beqz	s7,800051ee <exec+0x31e>
    8000526e:	8a5e                	mv	s4,s7
    80005270:	4481                	li	s1,0
    80005272:	b379                	j	80005000 <exec+0x130>

0000000080005274 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005274:	7179                	addi	sp,sp,-48
    80005276:	f406                	sd	ra,40(sp)
    80005278:	f022                	sd	s0,32(sp)
    8000527a:	ec26                	sd	s1,24(sp)
    8000527c:	e84a                	sd	s2,16(sp)
    8000527e:	1800                	addi	s0,sp,48
    80005280:	892e                	mv	s2,a1
    80005282:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005284:	fdc40593          	addi	a1,s0,-36
    80005288:	ffffe097          	auipc	ra,0xffffe
    8000528c:	afa080e7          	jalr	-1286(ra) # 80002d82 <argint>
    80005290:	04054063          	bltz	a0,800052d0 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005294:	fdc42703          	lw	a4,-36(s0)
    80005298:	47bd                	li	a5,15
    8000529a:	02e7ed63          	bltu	a5,a4,800052d4 <argfd+0x60>
    8000529e:	ffffd097          	auipc	ra,0xffffd
    800052a2:	9f0080e7          	jalr	-1552(ra) # 80001c8e <myproc>
    800052a6:	fdc42703          	lw	a4,-36(s0)
    800052aa:	01a70793          	addi	a5,a4,26
    800052ae:	078e                	slli	a5,a5,0x3
    800052b0:	953e                	add	a0,a0,a5
    800052b2:	611c                	ld	a5,0(a0)
    800052b4:	c395                	beqz	a5,800052d8 <argfd+0x64>
    return -1;
  if(pfd)
    800052b6:	00090463          	beqz	s2,800052be <argfd+0x4a>
    *pfd = fd;
    800052ba:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800052be:	4501                	li	a0,0
  if(pf)
    800052c0:	c091                	beqz	s1,800052c4 <argfd+0x50>
    *pf = f;
    800052c2:	e09c                	sd	a5,0(s1)
}
    800052c4:	70a2                	ld	ra,40(sp)
    800052c6:	7402                	ld	s0,32(sp)
    800052c8:	64e2                	ld	s1,24(sp)
    800052ca:	6942                	ld	s2,16(sp)
    800052cc:	6145                	addi	sp,sp,48
    800052ce:	8082                	ret
    return -1;
    800052d0:	557d                	li	a0,-1
    800052d2:	bfcd                	j	800052c4 <argfd+0x50>
    return -1;
    800052d4:	557d                	li	a0,-1
    800052d6:	b7fd                	j	800052c4 <argfd+0x50>
    800052d8:	557d                	li	a0,-1
    800052da:	b7ed                	j	800052c4 <argfd+0x50>

00000000800052dc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052dc:	1101                	addi	sp,sp,-32
    800052de:	ec06                	sd	ra,24(sp)
    800052e0:	e822                	sd	s0,16(sp)
    800052e2:	e426                	sd	s1,8(sp)
    800052e4:	1000                	addi	s0,sp,32
    800052e6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052e8:	ffffd097          	auipc	ra,0xffffd
    800052ec:	9a6080e7          	jalr	-1626(ra) # 80001c8e <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
    800052f0:	697c                	ld	a5,208(a0)
    800052f2:	c395                	beqz	a5,80005316 <fdalloc+0x3a>
    800052f4:	0d850713          	addi	a4,a0,216
  for(fd = 0; fd < NOFILE; fd++){
    800052f8:	4785                	li	a5,1
    800052fa:	4641                	li	a2,16
    if(p->ofile[fd] == 0){
    800052fc:	6314                	ld	a3,0(a4)
    800052fe:	ce89                	beqz	a3,80005318 <fdalloc+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
    80005300:	2785                	addiw	a5,a5,1
    80005302:	0721                	addi	a4,a4,8
    80005304:	fec79ce3          	bne	a5,a2,800052fc <fdalloc+0x20>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005308:	57fd                	li	a5,-1
}
    8000530a:	853e                	mv	a0,a5
    8000530c:	60e2                	ld	ra,24(sp)
    8000530e:	6442                	ld	s0,16(sp)
    80005310:	64a2                	ld	s1,8(sp)
    80005312:	6105                	addi	sp,sp,32
    80005314:	8082                	ret
  for(fd = 0; fd < NOFILE; fd++){
    80005316:	4781                	li	a5,0
      p->ofile[fd] = f;
    80005318:	01a78713          	addi	a4,a5,26
    8000531c:	070e                	slli	a4,a4,0x3
    8000531e:	953a                	add	a0,a0,a4
    80005320:	e104                	sd	s1,0(a0)
      return fd;
    80005322:	b7e5                	j	8000530a <fdalloc+0x2e>

0000000080005324 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005324:	715d                	addi	sp,sp,-80
    80005326:	e486                	sd	ra,72(sp)
    80005328:	e0a2                	sd	s0,64(sp)
    8000532a:	fc26                	sd	s1,56(sp)
    8000532c:	f84a                	sd	s2,48(sp)
    8000532e:	f44e                	sd	s3,40(sp)
    80005330:	f052                	sd	s4,32(sp)
    80005332:	ec56                	sd	s5,24(sp)
    80005334:	0880                	addi	s0,sp,80
    80005336:	89ae                	mv	s3,a1
    80005338:	8ab2                	mv	s5,a2
    8000533a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000533c:	fb040593          	addi	a1,s0,-80
    80005340:	fffff097          	auipc	ra,0xfffff
    80005344:	dde080e7          	jalr	-546(ra) # 8000411e <nameiparent>
    80005348:	892a                	mv	s2,a0
    8000534a:	12050f63          	beqz	a0,80005488 <create+0x164>
    return 0;

  ilock(dp);
    8000534e:	ffffe097          	auipc	ra,0xffffe
    80005352:	5f4080e7          	jalr	1524(ra) # 80003942 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005356:	4601                	li	a2,0
    80005358:	fb040593          	addi	a1,s0,-80
    8000535c:	854a                	mv	a0,s2
    8000535e:	fffff097          	auipc	ra,0xfffff
    80005362:	ac8080e7          	jalr	-1336(ra) # 80003e26 <dirlookup>
    80005366:	84aa                	mv	s1,a0
    80005368:	c921                	beqz	a0,800053b8 <create+0x94>
    iunlockput(dp);
    8000536a:	854a                	mv	a0,s2
    8000536c:	fffff097          	auipc	ra,0xfffff
    80005370:	83a080e7          	jalr	-1990(ra) # 80003ba6 <iunlockput>
    ilock(ip);
    80005374:	8526                	mv	a0,s1
    80005376:	ffffe097          	auipc	ra,0xffffe
    8000537a:	5cc080e7          	jalr	1484(ra) # 80003942 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000537e:	2981                	sext.w	s3,s3
    80005380:	4789                	li	a5,2
    80005382:	02f99463          	bne	s3,a5,800053aa <create+0x86>
    80005386:	0444d783          	lhu	a5,68(s1)
    8000538a:	37f9                	addiw	a5,a5,-2
    8000538c:	17c2                	slli	a5,a5,0x30
    8000538e:	93c1                	srli	a5,a5,0x30
    80005390:	4705                	li	a4,1
    80005392:	00f76c63          	bltu	a4,a5,800053aa <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005396:	8526                	mv	a0,s1
    80005398:	60a6                	ld	ra,72(sp)
    8000539a:	6406                	ld	s0,64(sp)
    8000539c:	74e2                	ld	s1,56(sp)
    8000539e:	7942                	ld	s2,48(sp)
    800053a0:	79a2                	ld	s3,40(sp)
    800053a2:	7a02                	ld	s4,32(sp)
    800053a4:	6ae2                	ld	s5,24(sp)
    800053a6:	6161                	addi	sp,sp,80
    800053a8:	8082                	ret
    iunlockput(ip);
    800053aa:	8526                	mv	a0,s1
    800053ac:	ffffe097          	auipc	ra,0xffffe
    800053b0:	7fa080e7          	jalr	2042(ra) # 80003ba6 <iunlockput>
    return 0;
    800053b4:	4481                	li	s1,0
    800053b6:	b7c5                	j	80005396 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800053b8:	85ce                	mv	a1,s3
    800053ba:	00092503          	lw	a0,0(s2)
    800053be:	ffffe097          	auipc	ra,0xffffe
    800053c2:	3e8080e7          	jalr	1000(ra) # 800037a6 <ialloc>
    800053c6:	84aa                	mv	s1,a0
    800053c8:	c529                	beqz	a0,80005412 <create+0xee>
  ilock(ip);
    800053ca:	ffffe097          	auipc	ra,0xffffe
    800053ce:	578080e7          	jalr	1400(ra) # 80003942 <ilock>
  ip->major = major;
    800053d2:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800053d6:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800053da:	4785                	li	a5,1
    800053dc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053e0:	8526                	mv	a0,s1
    800053e2:	ffffe097          	auipc	ra,0xffffe
    800053e6:	494080e7          	jalr	1172(ra) # 80003876 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053ea:	2981                	sext.w	s3,s3
    800053ec:	4785                	li	a5,1
    800053ee:	02f98a63          	beq	s3,a5,80005422 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800053f2:	40d0                	lw	a2,4(s1)
    800053f4:	fb040593          	addi	a1,s0,-80
    800053f8:	854a                	mv	a0,s2
    800053fa:	fffff097          	auipc	ra,0xfffff
    800053fe:	c44080e7          	jalr	-956(ra) # 8000403e <dirlink>
    80005402:	06054b63          	bltz	a0,80005478 <create+0x154>
  iunlockput(dp);
    80005406:	854a                	mv	a0,s2
    80005408:	ffffe097          	auipc	ra,0xffffe
    8000540c:	79e080e7          	jalr	1950(ra) # 80003ba6 <iunlockput>
  return ip;
    80005410:	b759                	j	80005396 <create+0x72>
    panic("create: ialloc");
    80005412:	00003517          	auipc	a0,0x3
    80005416:	3ae50513          	addi	a0,a0,942 # 800087c0 <syscalls+0x2d8>
    8000541a:	ffffb097          	auipc	ra,0xffffb
    8000541e:	15a080e7          	jalr	346(ra) # 80000574 <panic>
    dp->nlink++;  // for ".."
    80005422:	04a95783          	lhu	a5,74(s2)
    80005426:	2785                	addiw	a5,a5,1
    80005428:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000542c:	854a                	mv	a0,s2
    8000542e:	ffffe097          	auipc	ra,0xffffe
    80005432:	448080e7          	jalr	1096(ra) # 80003876 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005436:	40d0                	lw	a2,4(s1)
    80005438:	00003597          	auipc	a1,0x3
    8000543c:	39858593          	addi	a1,a1,920 # 800087d0 <syscalls+0x2e8>
    80005440:	8526                	mv	a0,s1
    80005442:	fffff097          	auipc	ra,0xfffff
    80005446:	bfc080e7          	jalr	-1028(ra) # 8000403e <dirlink>
    8000544a:	00054f63          	bltz	a0,80005468 <create+0x144>
    8000544e:	00492603          	lw	a2,4(s2)
    80005452:	00003597          	auipc	a1,0x3
    80005456:	38658593          	addi	a1,a1,902 # 800087d8 <syscalls+0x2f0>
    8000545a:	8526                	mv	a0,s1
    8000545c:	fffff097          	auipc	ra,0xfffff
    80005460:	be2080e7          	jalr	-1054(ra) # 8000403e <dirlink>
    80005464:	f80557e3          	bgez	a0,800053f2 <create+0xce>
      panic("create dots");
    80005468:	00003517          	auipc	a0,0x3
    8000546c:	37850513          	addi	a0,a0,888 # 800087e0 <syscalls+0x2f8>
    80005470:	ffffb097          	auipc	ra,0xffffb
    80005474:	104080e7          	jalr	260(ra) # 80000574 <panic>
    panic("create: dirlink");
    80005478:	00003517          	auipc	a0,0x3
    8000547c:	37850513          	addi	a0,a0,888 # 800087f0 <syscalls+0x308>
    80005480:	ffffb097          	auipc	ra,0xffffb
    80005484:	0f4080e7          	jalr	244(ra) # 80000574 <panic>
    return 0;
    80005488:	84aa                	mv	s1,a0
    8000548a:	b731                	j	80005396 <create+0x72>

000000008000548c <sys_dup>:
{
    8000548c:	7179                	addi	sp,sp,-48
    8000548e:	f406                	sd	ra,40(sp)
    80005490:	f022                	sd	s0,32(sp)
    80005492:	ec26                	sd	s1,24(sp)
    80005494:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005496:	fd840613          	addi	a2,s0,-40
    8000549a:	4581                	li	a1,0
    8000549c:	4501                	li	a0,0
    8000549e:	00000097          	auipc	ra,0x0
    800054a2:	dd6080e7          	jalr	-554(ra) # 80005274 <argfd>
    return -1;
    800054a6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800054a8:	02054363          	bltz	a0,800054ce <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800054ac:	fd843503          	ld	a0,-40(s0)
    800054b0:	00000097          	auipc	ra,0x0
    800054b4:	e2c080e7          	jalr	-468(ra) # 800052dc <fdalloc>
    800054b8:	84aa                	mv	s1,a0
    return -1;
    800054ba:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800054bc:	00054963          	bltz	a0,800054ce <sys_dup+0x42>
  filedup(f);
    800054c0:	fd843503          	ld	a0,-40(s0)
    800054c4:	fffff097          	auipc	ra,0xfffff
    800054c8:	2fa080e7          	jalr	762(ra) # 800047be <filedup>
  return fd;
    800054cc:	87a6                	mv	a5,s1
}
    800054ce:	853e                	mv	a0,a5
    800054d0:	70a2                	ld	ra,40(sp)
    800054d2:	7402                	ld	s0,32(sp)
    800054d4:	64e2                	ld	s1,24(sp)
    800054d6:	6145                	addi	sp,sp,48
    800054d8:	8082                	ret

00000000800054da <sys_read>:
{
    800054da:	7179                	addi	sp,sp,-48
    800054dc:	f406                	sd	ra,40(sp)
    800054de:	f022                	sd	s0,32(sp)
    800054e0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054e2:	fe840613          	addi	a2,s0,-24
    800054e6:	4581                	li	a1,0
    800054e8:	4501                	li	a0,0
    800054ea:	00000097          	auipc	ra,0x0
    800054ee:	d8a080e7          	jalr	-630(ra) # 80005274 <argfd>
    return -1;
    800054f2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054f4:	04054163          	bltz	a0,80005536 <sys_read+0x5c>
    800054f8:	fe440593          	addi	a1,s0,-28
    800054fc:	4509                	li	a0,2
    800054fe:	ffffe097          	auipc	ra,0xffffe
    80005502:	884080e7          	jalr	-1916(ra) # 80002d82 <argint>
    return -1;
    80005506:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005508:	02054763          	bltz	a0,80005536 <sys_read+0x5c>
    8000550c:	fd840593          	addi	a1,s0,-40
    80005510:	4505                	li	a0,1
    80005512:	ffffe097          	auipc	ra,0xffffe
    80005516:	892080e7          	jalr	-1902(ra) # 80002da4 <argaddr>
    return -1;
    8000551a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000551c:	00054d63          	bltz	a0,80005536 <sys_read+0x5c>
  return fileread(f, p, n);
    80005520:	fe442603          	lw	a2,-28(s0)
    80005524:	fd843583          	ld	a1,-40(s0)
    80005528:	fe843503          	ld	a0,-24(s0)
    8000552c:	fffff097          	auipc	ra,0xfffff
    80005530:	41e080e7          	jalr	1054(ra) # 8000494a <fileread>
    80005534:	87aa                	mv	a5,a0
}
    80005536:	853e                	mv	a0,a5
    80005538:	70a2                	ld	ra,40(sp)
    8000553a:	7402                	ld	s0,32(sp)
    8000553c:	6145                	addi	sp,sp,48
    8000553e:	8082                	ret

0000000080005540 <sys_write>:
{
    80005540:	7179                	addi	sp,sp,-48
    80005542:	f406                	sd	ra,40(sp)
    80005544:	f022                	sd	s0,32(sp)
    80005546:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005548:	fe840613          	addi	a2,s0,-24
    8000554c:	4581                	li	a1,0
    8000554e:	4501                	li	a0,0
    80005550:	00000097          	auipc	ra,0x0
    80005554:	d24080e7          	jalr	-732(ra) # 80005274 <argfd>
    return -1;
    80005558:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000555a:	04054163          	bltz	a0,8000559c <sys_write+0x5c>
    8000555e:	fe440593          	addi	a1,s0,-28
    80005562:	4509                	li	a0,2
    80005564:	ffffe097          	auipc	ra,0xffffe
    80005568:	81e080e7          	jalr	-2018(ra) # 80002d82 <argint>
    return -1;
    8000556c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000556e:	02054763          	bltz	a0,8000559c <sys_write+0x5c>
    80005572:	fd840593          	addi	a1,s0,-40
    80005576:	4505                	li	a0,1
    80005578:	ffffe097          	auipc	ra,0xffffe
    8000557c:	82c080e7          	jalr	-2004(ra) # 80002da4 <argaddr>
    return -1;
    80005580:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005582:	00054d63          	bltz	a0,8000559c <sys_write+0x5c>
  return filewrite(f, p, n);
    80005586:	fe442603          	lw	a2,-28(s0)
    8000558a:	fd843583          	ld	a1,-40(s0)
    8000558e:	fe843503          	ld	a0,-24(s0)
    80005592:	fffff097          	auipc	ra,0xfffff
    80005596:	47a080e7          	jalr	1146(ra) # 80004a0c <filewrite>
    8000559a:	87aa                	mv	a5,a0
}
    8000559c:	853e                	mv	a0,a5
    8000559e:	70a2                	ld	ra,40(sp)
    800055a0:	7402                	ld	s0,32(sp)
    800055a2:	6145                	addi	sp,sp,48
    800055a4:	8082                	ret

00000000800055a6 <sys_close>:
{
    800055a6:	1101                	addi	sp,sp,-32
    800055a8:	ec06                	sd	ra,24(sp)
    800055aa:	e822                	sd	s0,16(sp)
    800055ac:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800055ae:	fe040613          	addi	a2,s0,-32
    800055b2:	fec40593          	addi	a1,s0,-20
    800055b6:	4501                	li	a0,0
    800055b8:	00000097          	auipc	ra,0x0
    800055bc:	cbc080e7          	jalr	-836(ra) # 80005274 <argfd>
    return -1;
    800055c0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800055c2:	02054463          	bltz	a0,800055ea <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800055c6:	ffffc097          	auipc	ra,0xffffc
    800055ca:	6c8080e7          	jalr	1736(ra) # 80001c8e <myproc>
    800055ce:	fec42783          	lw	a5,-20(s0)
    800055d2:	07e9                	addi	a5,a5,26
    800055d4:	078e                	slli	a5,a5,0x3
    800055d6:	953e                	add	a0,a0,a5
    800055d8:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800055dc:	fe043503          	ld	a0,-32(s0)
    800055e0:	fffff097          	auipc	ra,0xfffff
    800055e4:	230080e7          	jalr	560(ra) # 80004810 <fileclose>
  return 0;
    800055e8:	4781                	li	a5,0
}
    800055ea:	853e                	mv	a0,a5
    800055ec:	60e2                	ld	ra,24(sp)
    800055ee:	6442                	ld	s0,16(sp)
    800055f0:	6105                	addi	sp,sp,32
    800055f2:	8082                	ret

00000000800055f4 <sys_fstat>:
{
    800055f4:	1101                	addi	sp,sp,-32
    800055f6:	ec06                	sd	ra,24(sp)
    800055f8:	e822                	sd	s0,16(sp)
    800055fa:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055fc:	fe840613          	addi	a2,s0,-24
    80005600:	4581                	li	a1,0
    80005602:	4501                	li	a0,0
    80005604:	00000097          	auipc	ra,0x0
    80005608:	c70080e7          	jalr	-912(ra) # 80005274 <argfd>
    return -1;
    8000560c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000560e:	02054563          	bltz	a0,80005638 <sys_fstat+0x44>
    80005612:	fe040593          	addi	a1,s0,-32
    80005616:	4505                	li	a0,1
    80005618:	ffffd097          	auipc	ra,0xffffd
    8000561c:	78c080e7          	jalr	1932(ra) # 80002da4 <argaddr>
    return -1;
    80005620:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005622:	00054b63          	bltz	a0,80005638 <sys_fstat+0x44>
  return filestat(f, st);
    80005626:	fe043583          	ld	a1,-32(s0)
    8000562a:	fe843503          	ld	a0,-24(s0)
    8000562e:	fffff097          	auipc	ra,0xfffff
    80005632:	2aa080e7          	jalr	682(ra) # 800048d8 <filestat>
    80005636:	87aa                	mv	a5,a0
}
    80005638:	853e                	mv	a0,a5
    8000563a:	60e2                	ld	ra,24(sp)
    8000563c:	6442                	ld	s0,16(sp)
    8000563e:	6105                	addi	sp,sp,32
    80005640:	8082                	ret

0000000080005642 <sys_link>:
{
    80005642:	7169                	addi	sp,sp,-304
    80005644:	f606                	sd	ra,296(sp)
    80005646:	f222                	sd	s0,288(sp)
    80005648:	ee26                	sd	s1,280(sp)
    8000564a:	ea4a                	sd	s2,272(sp)
    8000564c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000564e:	08000613          	li	a2,128
    80005652:	ed040593          	addi	a1,s0,-304
    80005656:	4501                	li	a0,0
    80005658:	ffffd097          	auipc	ra,0xffffd
    8000565c:	76e080e7          	jalr	1902(ra) # 80002dc6 <argstr>
    return -1;
    80005660:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005662:	10054e63          	bltz	a0,8000577e <sys_link+0x13c>
    80005666:	08000613          	li	a2,128
    8000566a:	f5040593          	addi	a1,s0,-176
    8000566e:	4505                	li	a0,1
    80005670:	ffffd097          	auipc	ra,0xffffd
    80005674:	756080e7          	jalr	1878(ra) # 80002dc6 <argstr>
    return -1;
    80005678:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000567a:	10054263          	bltz	a0,8000577e <sys_link+0x13c>
  begin_op();
    8000567e:	fffff097          	auipc	ra,0xfffff
    80005682:	c90080e7          	jalr	-880(ra) # 8000430e <begin_op>
  if((ip = namei(old)) == 0){
    80005686:	ed040513          	addi	a0,s0,-304
    8000568a:	fffff097          	auipc	ra,0xfffff
    8000568e:	a76080e7          	jalr	-1418(ra) # 80004100 <namei>
    80005692:	84aa                	mv	s1,a0
    80005694:	c551                	beqz	a0,80005720 <sys_link+0xde>
  ilock(ip);
    80005696:	ffffe097          	auipc	ra,0xffffe
    8000569a:	2ac080e7          	jalr	684(ra) # 80003942 <ilock>
  if(ip->type == T_DIR){
    8000569e:	04449703          	lh	a4,68(s1)
    800056a2:	4785                	li	a5,1
    800056a4:	08f70463          	beq	a4,a5,8000572c <sys_link+0xea>
  ip->nlink++;
    800056a8:	04a4d783          	lhu	a5,74(s1)
    800056ac:	2785                	addiw	a5,a5,1
    800056ae:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056b2:	8526                	mv	a0,s1
    800056b4:	ffffe097          	auipc	ra,0xffffe
    800056b8:	1c2080e7          	jalr	450(ra) # 80003876 <iupdate>
  iunlock(ip);
    800056bc:	8526                	mv	a0,s1
    800056be:	ffffe097          	auipc	ra,0xffffe
    800056c2:	348080e7          	jalr	840(ra) # 80003a06 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800056c6:	fd040593          	addi	a1,s0,-48
    800056ca:	f5040513          	addi	a0,s0,-176
    800056ce:	fffff097          	auipc	ra,0xfffff
    800056d2:	a50080e7          	jalr	-1456(ra) # 8000411e <nameiparent>
    800056d6:	892a                	mv	s2,a0
    800056d8:	c935                	beqz	a0,8000574c <sys_link+0x10a>
  ilock(dp);
    800056da:	ffffe097          	auipc	ra,0xffffe
    800056de:	268080e7          	jalr	616(ra) # 80003942 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800056e2:	00092703          	lw	a4,0(s2)
    800056e6:	409c                	lw	a5,0(s1)
    800056e8:	04f71d63          	bne	a4,a5,80005742 <sys_link+0x100>
    800056ec:	40d0                	lw	a2,4(s1)
    800056ee:	fd040593          	addi	a1,s0,-48
    800056f2:	854a                	mv	a0,s2
    800056f4:	fffff097          	auipc	ra,0xfffff
    800056f8:	94a080e7          	jalr	-1718(ra) # 8000403e <dirlink>
    800056fc:	04054363          	bltz	a0,80005742 <sys_link+0x100>
  iunlockput(dp);
    80005700:	854a                	mv	a0,s2
    80005702:	ffffe097          	auipc	ra,0xffffe
    80005706:	4a4080e7          	jalr	1188(ra) # 80003ba6 <iunlockput>
  iput(ip);
    8000570a:	8526                	mv	a0,s1
    8000570c:	ffffe097          	auipc	ra,0xffffe
    80005710:	3f2080e7          	jalr	1010(ra) # 80003afe <iput>
  end_op();
    80005714:	fffff097          	auipc	ra,0xfffff
    80005718:	c7a080e7          	jalr	-902(ra) # 8000438e <end_op>
  return 0;
    8000571c:	4781                	li	a5,0
    8000571e:	a085                	j	8000577e <sys_link+0x13c>
    end_op();
    80005720:	fffff097          	auipc	ra,0xfffff
    80005724:	c6e080e7          	jalr	-914(ra) # 8000438e <end_op>
    return -1;
    80005728:	57fd                	li	a5,-1
    8000572a:	a891                	j	8000577e <sys_link+0x13c>
    iunlockput(ip);
    8000572c:	8526                	mv	a0,s1
    8000572e:	ffffe097          	auipc	ra,0xffffe
    80005732:	478080e7          	jalr	1144(ra) # 80003ba6 <iunlockput>
    end_op();
    80005736:	fffff097          	auipc	ra,0xfffff
    8000573a:	c58080e7          	jalr	-936(ra) # 8000438e <end_op>
    return -1;
    8000573e:	57fd                	li	a5,-1
    80005740:	a83d                	j	8000577e <sys_link+0x13c>
    iunlockput(dp);
    80005742:	854a                	mv	a0,s2
    80005744:	ffffe097          	auipc	ra,0xffffe
    80005748:	462080e7          	jalr	1122(ra) # 80003ba6 <iunlockput>
  ilock(ip);
    8000574c:	8526                	mv	a0,s1
    8000574e:	ffffe097          	auipc	ra,0xffffe
    80005752:	1f4080e7          	jalr	500(ra) # 80003942 <ilock>
  ip->nlink--;
    80005756:	04a4d783          	lhu	a5,74(s1)
    8000575a:	37fd                	addiw	a5,a5,-1
    8000575c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005760:	8526                	mv	a0,s1
    80005762:	ffffe097          	auipc	ra,0xffffe
    80005766:	114080e7          	jalr	276(ra) # 80003876 <iupdate>
  iunlockput(ip);
    8000576a:	8526                	mv	a0,s1
    8000576c:	ffffe097          	auipc	ra,0xffffe
    80005770:	43a080e7          	jalr	1082(ra) # 80003ba6 <iunlockput>
  end_op();
    80005774:	fffff097          	auipc	ra,0xfffff
    80005778:	c1a080e7          	jalr	-998(ra) # 8000438e <end_op>
  return -1;
    8000577c:	57fd                	li	a5,-1
}
    8000577e:	853e                	mv	a0,a5
    80005780:	70b2                	ld	ra,296(sp)
    80005782:	7412                	ld	s0,288(sp)
    80005784:	64f2                	ld	s1,280(sp)
    80005786:	6952                	ld	s2,272(sp)
    80005788:	6155                	addi	sp,sp,304
    8000578a:	8082                	ret

000000008000578c <sys_unlink>:
{
    8000578c:	7151                	addi	sp,sp,-240
    8000578e:	f586                	sd	ra,232(sp)
    80005790:	f1a2                	sd	s0,224(sp)
    80005792:	eda6                	sd	s1,216(sp)
    80005794:	e9ca                	sd	s2,208(sp)
    80005796:	e5ce                	sd	s3,200(sp)
    80005798:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000579a:	08000613          	li	a2,128
    8000579e:	f3040593          	addi	a1,s0,-208
    800057a2:	4501                	li	a0,0
    800057a4:	ffffd097          	auipc	ra,0xffffd
    800057a8:	622080e7          	jalr	1570(ra) # 80002dc6 <argstr>
    800057ac:	16054f63          	bltz	a0,8000592a <sys_unlink+0x19e>
  begin_op();
    800057b0:	fffff097          	auipc	ra,0xfffff
    800057b4:	b5e080e7          	jalr	-1186(ra) # 8000430e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800057b8:	fb040593          	addi	a1,s0,-80
    800057bc:	f3040513          	addi	a0,s0,-208
    800057c0:	fffff097          	auipc	ra,0xfffff
    800057c4:	95e080e7          	jalr	-1698(ra) # 8000411e <nameiparent>
    800057c8:	89aa                	mv	s3,a0
    800057ca:	c979                	beqz	a0,800058a0 <sys_unlink+0x114>
  ilock(dp);
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	176080e7          	jalr	374(ra) # 80003942 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057d4:	00003597          	auipc	a1,0x3
    800057d8:	ffc58593          	addi	a1,a1,-4 # 800087d0 <syscalls+0x2e8>
    800057dc:	fb040513          	addi	a0,s0,-80
    800057e0:	ffffe097          	auipc	ra,0xffffe
    800057e4:	62c080e7          	jalr	1580(ra) # 80003e0c <namecmp>
    800057e8:	14050863          	beqz	a0,80005938 <sys_unlink+0x1ac>
    800057ec:	00003597          	auipc	a1,0x3
    800057f0:	fec58593          	addi	a1,a1,-20 # 800087d8 <syscalls+0x2f0>
    800057f4:	fb040513          	addi	a0,s0,-80
    800057f8:	ffffe097          	auipc	ra,0xffffe
    800057fc:	614080e7          	jalr	1556(ra) # 80003e0c <namecmp>
    80005800:	12050c63          	beqz	a0,80005938 <sys_unlink+0x1ac>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005804:	f2c40613          	addi	a2,s0,-212
    80005808:	fb040593          	addi	a1,s0,-80
    8000580c:	854e                	mv	a0,s3
    8000580e:	ffffe097          	auipc	ra,0xffffe
    80005812:	618080e7          	jalr	1560(ra) # 80003e26 <dirlookup>
    80005816:	84aa                	mv	s1,a0
    80005818:	12050063          	beqz	a0,80005938 <sys_unlink+0x1ac>
  ilock(ip);
    8000581c:	ffffe097          	auipc	ra,0xffffe
    80005820:	126080e7          	jalr	294(ra) # 80003942 <ilock>
  if(ip->nlink < 1)
    80005824:	04a49783          	lh	a5,74(s1)
    80005828:	08f05263          	blez	a5,800058ac <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000582c:	04449703          	lh	a4,68(s1)
    80005830:	4785                	li	a5,1
    80005832:	08f70563          	beq	a4,a5,800058bc <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005836:	4641                	li	a2,16
    80005838:	4581                	li	a1,0
    8000583a:	fc040513          	addi	a0,s0,-64
    8000583e:	ffffb097          	auipc	ra,0xffffb
    80005842:	61c080e7          	jalr	1564(ra) # 80000e5a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005846:	4741                	li	a4,16
    80005848:	f2c42683          	lw	a3,-212(s0)
    8000584c:	fc040613          	addi	a2,s0,-64
    80005850:	4581                	li	a1,0
    80005852:	854e                	mv	a0,s3
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	49c080e7          	jalr	1180(ra) # 80003cf0 <writei>
    8000585c:	47c1                	li	a5,16
    8000585e:	0af51363          	bne	a0,a5,80005904 <sys_unlink+0x178>
  if(ip->type == T_DIR){
    80005862:	04449703          	lh	a4,68(s1)
    80005866:	4785                	li	a5,1
    80005868:	0af70663          	beq	a4,a5,80005914 <sys_unlink+0x188>
  iunlockput(dp);
    8000586c:	854e                	mv	a0,s3
    8000586e:	ffffe097          	auipc	ra,0xffffe
    80005872:	338080e7          	jalr	824(ra) # 80003ba6 <iunlockput>
  ip->nlink--;
    80005876:	04a4d783          	lhu	a5,74(s1)
    8000587a:	37fd                	addiw	a5,a5,-1
    8000587c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005880:	8526                	mv	a0,s1
    80005882:	ffffe097          	auipc	ra,0xffffe
    80005886:	ff4080e7          	jalr	-12(ra) # 80003876 <iupdate>
  iunlockput(ip);
    8000588a:	8526                	mv	a0,s1
    8000588c:	ffffe097          	auipc	ra,0xffffe
    80005890:	31a080e7          	jalr	794(ra) # 80003ba6 <iunlockput>
  end_op();
    80005894:	fffff097          	auipc	ra,0xfffff
    80005898:	afa080e7          	jalr	-1286(ra) # 8000438e <end_op>
  return 0;
    8000589c:	4501                	li	a0,0
    8000589e:	a07d                	j	8000594c <sys_unlink+0x1c0>
    end_op();
    800058a0:	fffff097          	auipc	ra,0xfffff
    800058a4:	aee080e7          	jalr	-1298(ra) # 8000438e <end_op>
    return -1;
    800058a8:	557d                	li	a0,-1
    800058aa:	a04d                	j	8000594c <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    800058ac:	00003517          	auipc	a0,0x3
    800058b0:	f5450513          	addi	a0,a0,-172 # 80008800 <syscalls+0x318>
    800058b4:	ffffb097          	auipc	ra,0xffffb
    800058b8:	cc0080e7          	jalr	-832(ra) # 80000574 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058bc:	44f8                	lw	a4,76(s1)
    800058be:	02000793          	li	a5,32
    800058c2:	f6e7fae3          	bleu	a4,a5,80005836 <sys_unlink+0xaa>
    800058c6:	02000913          	li	s2,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058ca:	4741                	li	a4,16
    800058cc:	86ca                	mv	a3,s2
    800058ce:	f1840613          	addi	a2,s0,-232
    800058d2:	4581                	li	a1,0
    800058d4:	8526                	mv	a0,s1
    800058d6:	ffffe097          	auipc	ra,0xffffe
    800058da:	322080e7          	jalr	802(ra) # 80003bf8 <readi>
    800058de:	47c1                	li	a5,16
    800058e0:	00f51a63          	bne	a0,a5,800058f4 <sys_unlink+0x168>
    if(de.inum != 0)
    800058e4:	f1845783          	lhu	a5,-232(s0)
    800058e8:	e3b9                	bnez	a5,8000592e <sys_unlink+0x1a2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058ea:	2941                	addiw	s2,s2,16
    800058ec:	44fc                	lw	a5,76(s1)
    800058ee:	fcf96ee3          	bltu	s2,a5,800058ca <sys_unlink+0x13e>
    800058f2:	b791                	j	80005836 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800058f4:	00003517          	auipc	a0,0x3
    800058f8:	f2450513          	addi	a0,a0,-220 # 80008818 <syscalls+0x330>
    800058fc:	ffffb097          	auipc	ra,0xffffb
    80005900:	c78080e7          	jalr	-904(ra) # 80000574 <panic>
    panic("unlink: writei");
    80005904:	00003517          	auipc	a0,0x3
    80005908:	f2c50513          	addi	a0,a0,-212 # 80008830 <syscalls+0x348>
    8000590c:	ffffb097          	auipc	ra,0xffffb
    80005910:	c68080e7          	jalr	-920(ra) # 80000574 <panic>
    dp->nlink--;
    80005914:	04a9d783          	lhu	a5,74(s3)
    80005918:	37fd                	addiw	a5,a5,-1
    8000591a:	04f99523          	sh	a5,74(s3)
    iupdate(dp);
    8000591e:	854e                	mv	a0,s3
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	f56080e7          	jalr	-170(ra) # 80003876 <iupdate>
    80005928:	b791                	j	8000586c <sys_unlink+0xe0>
    return -1;
    8000592a:	557d                	li	a0,-1
    8000592c:	a005                	j	8000594c <sys_unlink+0x1c0>
    iunlockput(ip);
    8000592e:	8526                	mv	a0,s1
    80005930:	ffffe097          	auipc	ra,0xffffe
    80005934:	276080e7          	jalr	630(ra) # 80003ba6 <iunlockput>
  iunlockput(dp);
    80005938:	854e                	mv	a0,s3
    8000593a:	ffffe097          	auipc	ra,0xffffe
    8000593e:	26c080e7          	jalr	620(ra) # 80003ba6 <iunlockput>
  end_op();
    80005942:	fffff097          	auipc	ra,0xfffff
    80005946:	a4c080e7          	jalr	-1460(ra) # 8000438e <end_op>
  return -1;
    8000594a:	557d                	li	a0,-1
}
    8000594c:	70ae                	ld	ra,232(sp)
    8000594e:	740e                	ld	s0,224(sp)
    80005950:	64ee                	ld	s1,216(sp)
    80005952:	694e                	ld	s2,208(sp)
    80005954:	69ae                	ld	s3,200(sp)
    80005956:	616d                	addi	sp,sp,240
    80005958:	8082                	ret

000000008000595a <sys_open>:

uint64
sys_open(void)
{
    8000595a:	7131                	addi	sp,sp,-192
    8000595c:	fd06                	sd	ra,184(sp)
    8000595e:	f922                	sd	s0,176(sp)
    80005960:	f526                	sd	s1,168(sp)
    80005962:	f14a                	sd	s2,160(sp)
    80005964:	ed4e                	sd	s3,152(sp)
    80005966:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005968:	08000613          	li	a2,128
    8000596c:	f5040593          	addi	a1,s0,-176
    80005970:	4501                	li	a0,0
    80005972:	ffffd097          	auipc	ra,0xffffd
    80005976:	454080e7          	jalr	1108(ra) # 80002dc6 <argstr>
    return -1;
    8000597a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000597c:	0c054163          	bltz	a0,80005a3e <sys_open+0xe4>
    80005980:	f4c40593          	addi	a1,s0,-180
    80005984:	4505                	li	a0,1
    80005986:	ffffd097          	auipc	ra,0xffffd
    8000598a:	3fc080e7          	jalr	1020(ra) # 80002d82 <argint>
    8000598e:	0a054863          	bltz	a0,80005a3e <sys_open+0xe4>

  begin_op();
    80005992:	fffff097          	auipc	ra,0xfffff
    80005996:	97c080e7          	jalr	-1668(ra) # 8000430e <begin_op>

  if(omode & O_CREATE){
    8000599a:	f4c42783          	lw	a5,-180(s0)
    8000599e:	2007f793          	andi	a5,a5,512
    800059a2:	cbdd                	beqz	a5,80005a58 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800059a4:	4681                	li	a3,0
    800059a6:	4601                	li	a2,0
    800059a8:	4589                	li	a1,2
    800059aa:	f5040513          	addi	a0,s0,-176
    800059ae:	00000097          	auipc	ra,0x0
    800059b2:	976080e7          	jalr	-1674(ra) # 80005324 <create>
    800059b6:	892a                	mv	s2,a0
    if(ip == 0){
    800059b8:	c959                	beqz	a0,80005a4e <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800059ba:	04491703          	lh	a4,68(s2)
    800059be:	478d                	li	a5,3
    800059c0:	00f71763          	bne	a4,a5,800059ce <sys_open+0x74>
    800059c4:	04695703          	lhu	a4,70(s2)
    800059c8:	47a5                	li	a5,9
    800059ca:	0ce7ec63          	bltu	a5,a4,80005aa2 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800059ce:	fffff097          	auipc	ra,0xfffff
    800059d2:	d72080e7          	jalr	-654(ra) # 80004740 <filealloc>
    800059d6:	89aa                	mv	s3,a0
    800059d8:	10050263          	beqz	a0,80005adc <sys_open+0x182>
    800059dc:	00000097          	auipc	ra,0x0
    800059e0:	900080e7          	jalr	-1792(ra) # 800052dc <fdalloc>
    800059e4:	84aa                	mv	s1,a0
    800059e6:	0e054663          	bltz	a0,80005ad2 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059ea:	04491703          	lh	a4,68(s2)
    800059ee:	478d                	li	a5,3
    800059f0:	0cf70463          	beq	a4,a5,80005ab8 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800059f4:	4789                	li	a5,2
    800059f6:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800059fa:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800059fe:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005a02:	f4c42783          	lw	a5,-180(s0)
    80005a06:	0017c713          	xori	a4,a5,1
    80005a0a:	8b05                	andi	a4,a4,1
    80005a0c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a10:	0037f713          	andi	a4,a5,3
    80005a14:	00e03733          	snez	a4,a4
    80005a18:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a1c:	4007f793          	andi	a5,a5,1024
    80005a20:	c791                	beqz	a5,80005a2c <sys_open+0xd2>
    80005a22:	04491703          	lh	a4,68(s2)
    80005a26:	4789                	li	a5,2
    80005a28:	08f70f63          	beq	a4,a5,80005ac6 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005a2c:	854a                	mv	a0,s2
    80005a2e:	ffffe097          	auipc	ra,0xffffe
    80005a32:	fd8080e7          	jalr	-40(ra) # 80003a06 <iunlock>
  end_op();
    80005a36:	fffff097          	auipc	ra,0xfffff
    80005a3a:	958080e7          	jalr	-1704(ra) # 8000438e <end_op>

  return fd;
}
    80005a3e:	8526                	mv	a0,s1
    80005a40:	70ea                	ld	ra,184(sp)
    80005a42:	744a                	ld	s0,176(sp)
    80005a44:	74aa                	ld	s1,168(sp)
    80005a46:	790a                	ld	s2,160(sp)
    80005a48:	69ea                	ld	s3,152(sp)
    80005a4a:	6129                	addi	sp,sp,192
    80005a4c:	8082                	ret
      end_op();
    80005a4e:	fffff097          	auipc	ra,0xfffff
    80005a52:	940080e7          	jalr	-1728(ra) # 8000438e <end_op>
      return -1;
    80005a56:	b7e5                	j	80005a3e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005a58:	f5040513          	addi	a0,s0,-176
    80005a5c:	ffffe097          	auipc	ra,0xffffe
    80005a60:	6a4080e7          	jalr	1700(ra) # 80004100 <namei>
    80005a64:	892a                	mv	s2,a0
    80005a66:	c905                	beqz	a0,80005a96 <sys_open+0x13c>
    ilock(ip);
    80005a68:	ffffe097          	auipc	ra,0xffffe
    80005a6c:	eda080e7          	jalr	-294(ra) # 80003942 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a70:	04491703          	lh	a4,68(s2)
    80005a74:	4785                	li	a5,1
    80005a76:	f4f712e3          	bne	a4,a5,800059ba <sys_open+0x60>
    80005a7a:	f4c42783          	lw	a5,-180(s0)
    80005a7e:	dba1                	beqz	a5,800059ce <sys_open+0x74>
      iunlockput(ip);
    80005a80:	854a                	mv	a0,s2
    80005a82:	ffffe097          	auipc	ra,0xffffe
    80005a86:	124080e7          	jalr	292(ra) # 80003ba6 <iunlockput>
      end_op();
    80005a8a:	fffff097          	auipc	ra,0xfffff
    80005a8e:	904080e7          	jalr	-1788(ra) # 8000438e <end_op>
      return -1;
    80005a92:	54fd                	li	s1,-1
    80005a94:	b76d                	j	80005a3e <sys_open+0xe4>
      end_op();
    80005a96:	fffff097          	auipc	ra,0xfffff
    80005a9a:	8f8080e7          	jalr	-1800(ra) # 8000438e <end_op>
      return -1;
    80005a9e:	54fd                	li	s1,-1
    80005aa0:	bf79                	j	80005a3e <sys_open+0xe4>
    iunlockput(ip);
    80005aa2:	854a                	mv	a0,s2
    80005aa4:	ffffe097          	auipc	ra,0xffffe
    80005aa8:	102080e7          	jalr	258(ra) # 80003ba6 <iunlockput>
    end_op();
    80005aac:	fffff097          	auipc	ra,0xfffff
    80005ab0:	8e2080e7          	jalr	-1822(ra) # 8000438e <end_op>
    return -1;
    80005ab4:	54fd                	li	s1,-1
    80005ab6:	b761                	j	80005a3e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005ab8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005abc:	04691783          	lh	a5,70(s2)
    80005ac0:	02f99223          	sh	a5,36(s3)
    80005ac4:	bf2d                	j	800059fe <sys_open+0xa4>
    itrunc(ip);
    80005ac6:	854a                	mv	a0,s2
    80005ac8:	ffffe097          	auipc	ra,0xffffe
    80005acc:	f8a080e7          	jalr	-118(ra) # 80003a52 <itrunc>
    80005ad0:	bfb1                	j	80005a2c <sys_open+0xd2>
      fileclose(f);
    80005ad2:	854e                	mv	a0,s3
    80005ad4:	fffff097          	auipc	ra,0xfffff
    80005ad8:	d3c080e7          	jalr	-708(ra) # 80004810 <fileclose>
    iunlockput(ip);
    80005adc:	854a                	mv	a0,s2
    80005ade:	ffffe097          	auipc	ra,0xffffe
    80005ae2:	0c8080e7          	jalr	200(ra) # 80003ba6 <iunlockput>
    end_op();
    80005ae6:	fffff097          	auipc	ra,0xfffff
    80005aea:	8a8080e7          	jalr	-1880(ra) # 8000438e <end_op>
    return -1;
    80005aee:	54fd                	li	s1,-1
    80005af0:	b7b9                	j	80005a3e <sys_open+0xe4>

0000000080005af2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005af2:	7175                	addi	sp,sp,-144
    80005af4:	e506                	sd	ra,136(sp)
    80005af6:	e122                	sd	s0,128(sp)
    80005af8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005afa:	fffff097          	auipc	ra,0xfffff
    80005afe:	814080e7          	jalr	-2028(ra) # 8000430e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b02:	08000613          	li	a2,128
    80005b06:	f7040593          	addi	a1,s0,-144
    80005b0a:	4501                	li	a0,0
    80005b0c:	ffffd097          	auipc	ra,0xffffd
    80005b10:	2ba080e7          	jalr	698(ra) # 80002dc6 <argstr>
    80005b14:	02054963          	bltz	a0,80005b46 <sys_mkdir+0x54>
    80005b18:	4681                	li	a3,0
    80005b1a:	4601                	li	a2,0
    80005b1c:	4585                	li	a1,1
    80005b1e:	f7040513          	addi	a0,s0,-144
    80005b22:	00000097          	auipc	ra,0x0
    80005b26:	802080e7          	jalr	-2046(ra) # 80005324 <create>
    80005b2a:	cd11                	beqz	a0,80005b46 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b2c:	ffffe097          	auipc	ra,0xffffe
    80005b30:	07a080e7          	jalr	122(ra) # 80003ba6 <iunlockput>
  end_op();
    80005b34:	fffff097          	auipc	ra,0xfffff
    80005b38:	85a080e7          	jalr	-1958(ra) # 8000438e <end_op>
  return 0;
    80005b3c:	4501                	li	a0,0
}
    80005b3e:	60aa                	ld	ra,136(sp)
    80005b40:	640a                	ld	s0,128(sp)
    80005b42:	6149                	addi	sp,sp,144
    80005b44:	8082                	ret
    end_op();
    80005b46:	fffff097          	auipc	ra,0xfffff
    80005b4a:	848080e7          	jalr	-1976(ra) # 8000438e <end_op>
    return -1;
    80005b4e:	557d                	li	a0,-1
    80005b50:	b7fd                	j	80005b3e <sys_mkdir+0x4c>

0000000080005b52 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b52:	7135                	addi	sp,sp,-160
    80005b54:	ed06                	sd	ra,152(sp)
    80005b56:	e922                	sd	s0,144(sp)
    80005b58:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b5a:	ffffe097          	auipc	ra,0xffffe
    80005b5e:	7b4080e7          	jalr	1972(ra) # 8000430e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b62:	08000613          	li	a2,128
    80005b66:	f7040593          	addi	a1,s0,-144
    80005b6a:	4501                	li	a0,0
    80005b6c:	ffffd097          	auipc	ra,0xffffd
    80005b70:	25a080e7          	jalr	602(ra) # 80002dc6 <argstr>
    80005b74:	04054a63          	bltz	a0,80005bc8 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005b78:	f6c40593          	addi	a1,s0,-148
    80005b7c:	4505                	li	a0,1
    80005b7e:	ffffd097          	auipc	ra,0xffffd
    80005b82:	204080e7          	jalr	516(ra) # 80002d82 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b86:	04054163          	bltz	a0,80005bc8 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005b8a:	f6840593          	addi	a1,s0,-152
    80005b8e:	4509                	li	a0,2
    80005b90:	ffffd097          	auipc	ra,0xffffd
    80005b94:	1f2080e7          	jalr	498(ra) # 80002d82 <argint>
     argint(1, &major) < 0 ||
    80005b98:	02054863          	bltz	a0,80005bc8 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b9c:	f6841683          	lh	a3,-152(s0)
    80005ba0:	f6c41603          	lh	a2,-148(s0)
    80005ba4:	458d                	li	a1,3
    80005ba6:	f7040513          	addi	a0,s0,-144
    80005baa:	fffff097          	auipc	ra,0xfffff
    80005bae:	77a080e7          	jalr	1914(ra) # 80005324 <create>
     argint(2, &minor) < 0 ||
    80005bb2:	c919                	beqz	a0,80005bc8 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bb4:	ffffe097          	auipc	ra,0xffffe
    80005bb8:	ff2080e7          	jalr	-14(ra) # 80003ba6 <iunlockput>
  end_op();
    80005bbc:	ffffe097          	auipc	ra,0xffffe
    80005bc0:	7d2080e7          	jalr	2002(ra) # 8000438e <end_op>
  return 0;
    80005bc4:	4501                	li	a0,0
    80005bc6:	a031                	j	80005bd2 <sys_mknod+0x80>
    end_op();
    80005bc8:	ffffe097          	auipc	ra,0xffffe
    80005bcc:	7c6080e7          	jalr	1990(ra) # 8000438e <end_op>
    return -1;
    80005bd0:	557d                	li	a0,-1
}
    80005bd2:	60ea                	ld	ra,152(sp)
    80005bd4:	644a                	ld	s0,144(sp)
    80005bd6:	610d                	addi	sp,sp,160
    80005bd8:	8082                	ret

0000000080005bda <sys_chdir>:

uint64
sys_chdir(void)
{
    80005bda:	7135                	addi	sp,sp,-160
    80005bdc:	ed06                	sd	ra,152(sp)
    80005bde:	e922                	sd	s0,144(sp)
    80005be0:	e526                	sd	s1,136(sp)
    80005be2:	e14a                	sd	s2,128(sp)
    80005be4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005be6:	ffffc097          	auipc	ra,0xffffc
    80005bea:	0a8080e7          	jalr	168(ra) # 80001c8e <myproc>
    80005bee:	892a                	mv	s2,a0
  
  begin_op();
    80005bf0:	ffffe097          	auipc	ra,0xffffe
    80005bf4:	71e080e7          	jalr	1822(ra) # 8000430e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005bf8:	08000613          	li	a2,128
    80005bfc:	f6040593          	addi	a1,s0,-160
    80005c00:	4501                	li	a0,0
    80005c02:	ffffd097          	auipc	ra,0xffffd
    80005c06:	1c4080e7          	jalr	452(ra) # 80002dc6 <argstr>
    80005c0a:	04054b63          	bltz	a0,80005c60 <sys_chdir+0x86>
    80005c0e:	f6040513          	addi	a0,s0,-160
    80005c12:	ffffe097          	auipc	ra,0xffffe
    80005c16:	4ee080e7          	jalr	1262(ra) # 80004100 <namei>
    80005c1a:	84aa                	mv	s1,a0
    80005c1c:	c131                	beqz	a0,80005c60 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c1e:	ffffe097          	auipc	ra,0xffffe
    80005c22:	d24080e7          	jalr	-732(ra) # 80003942 <ilock>
  if(ip->type != T_DIR){
    80005c26:	04449703          	lh	a4,68(s1)
    80005c2a:	4785                	li	a5,1
    80005c2c:	04f71063          	bne	a4,a5,80005c6c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c30:	8526                	mv	a0,s1
    80005c32:	ffffe097          	auipc	ra,0xffffe
    80005c36:	dd4080e7          	jalr	-556(ra) # 80003a06 <iunlock>
  iput(p->cwd);
    80005c3a:	15093503          	ld	a0,336(s2)
    80005c3e:	ffffe097          	auipc	ra,0xffffe
    80005c42:	ec0080e7          	jalr	-320(ra) # 80003afe <iput>
  end_op();
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	748080e7          	jalr	1864(ra) # 8000438e <end_op>
  p->cwd = ip;
    80005c4e:	14993823          	sd	s1,336(s2)
  return 0;
    80005c52:	4501                	li	a0,0
}
    80005c54:	60ea                	ld	ra,152(sp)
    80005c56:	644a                	ld	s0,144(sp)
    80005c58:	64aa                	ld	s1,136(sp)
    80005c5a:	690a                	ld	s2,128(sp)
    80005c5c:	610d                	addi	sp,sp,160
    80005c5e:	8082                	ret
    end_op();
    80005c60:	ffffe097          	auipc	ra,0xffffe
    80005c64:	72e080e7          	jalr	1838(ra) # 8000438e <end_op>
    return -1;
    80005c68:	557d                	li	a0,-1
    80005c6a:	b7ed                	j	80005c54 <sys_chdir+0x7a>
    iunlockput(ip);
    80005c6c:	8526                	mv	a0,s1
    80005c6e:	ffffe097          	auipc	ra,0xffffe
    80005c72:	f38080e7          	jalr	-200(ra) # 80003ba6 <iunlockput>
    end_op();
    80005c76:	ffffe097          	auipc	ra,0xffffe
    80005c7a:	718080e7          	jalr	1816(ra) # 8000438e <end_op>
    return -1;
    80005c7e:	557d                	li	a0,-1
    80005c80:	bfd1                	j	80005c54 <sys_chdir+0x7a>

0000000080005c82 <sys_exec>:

uint64
sys_exec(void)
{
    80005c82:	7145                	addi	sp,sp,-464
    80005c84:	e786                	sd	ra,456(sp)
    80005c86:	e3a2                	sd	s0,448(sp)
    80005c88:	ff26                	sd	s1,440(sp)
    80005c8a:	fb4a                	sd	s2,432(sp)
    80005c8c:	f74e                	sd	s3,424(sp)
    80005c8e:	f352                	sd	s4,416(sp)
    80005c90:	ef56                	sd	s5,408(sp)
    80005c92:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c94:	08000613          	li	a2,128
    80005c98:	f4040593          	addi	a1,s0,-192
    80005c9c:	4501                	li	a0,0
    80005c9e:	ffffd097          	auipc	ra,0xffffd
    80005ca2:	128080e7          	jalr	296(ra) # 80002dc6 <argstr>
    return -1;
    80005ca6:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005ca8:	0e054c63          	bltz	a0,80005da0 <sys_exec+0x11e>
    80005cac:	e3840593          	addi	a1,s0,-456
    80005cb0:	4505                	li	a0,1
    80005cb2:	ffffd097          	auipc	ra,0xffffd
    80005cb6:	0f2080e7          	jalr	242(ra) # 80002da4 <argaddr>
    80005cba:	0e054363          	bltz	a0,80005da0 <sys_exec+0x11e>
  }
  memset(argv, 0, sizeof(argv));
    80005cbe:	e4040913          	addi	s2,s0,-448
    80005cc2:	10000613          	li	a2,256
    80005cc6:	4581                	li	a1,0
    80005cc8:	854a                	mv	a0,s2
    80005cca:	ffffb097          	auipc	ra,0xffffb
    80005cce:	190080e7          	jalr	400(ra) # 80000e5a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005cd2:	89ca                	mv	s3,s2
  memset(argv, 0, sizeof(argv));
    80005cd4:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005cd6:	02000a93          	li	s5,32
    80005cda:	00048a1b          	sext.w	s4,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005cde:	00349513          	slli	a0,s1,0x3
    80005ce2:	e3040593          	addi	a1,s0,-464
    80005ce6:	e3843783          	ld	a5,-456(s0)
    80005cea:	953e                	add	a0,a0,a5
    80005cec:	ffffd097          	auipc	ra,0xffffd
    80005cf0:	ffa080e7          	jalr	-6(ra) # 80002ce6 <fetchaddr>
    80005cf4:	02054a63          	bltz	a0,80005d28 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005cf8:	e3043783          	ld	a5,-464(s0)
    80005cfc:	cfa9                	beqz	a5,80005d56 <sys_exec+0xd4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005cfe:	ffffb097          	auipc	ra,0xffffb
    80005d02:	ece080e7          	jalr	-306(ra) # 80000bcc <kalloc>
    80005d06:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80005d0a:	cd19                	beqz	a0,80005d28 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d0c:	6605                	lui	a2,0x1
    80005d0e:	85aa                	mv	a1,a0
    80005d10:	e3043503          	ld	a0,-464(s0)
    80005d14:	ffffd097          	auipc	ra,0xffffd
    80005d18:	026080e7          	jalr	38(ra) # 80002d3a <fetchstr>
    80005d1c:	00054663          	bltz	a0,80005d28 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005d20:	0485                	addi	s1,s1,1
    80005d22:	0921                	addi	s2,s2,8
    80005d24:	fb549be3          	bne	s1,s5,80005cda <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d28:	e4043503          	ld	a0,-448(s0)
    kfree(argv[i]);
  return -1;
    80005d2c:	597d                	li	s2,-1
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d2e:	c92d                	beqz	a0,80005da0 <sys_exec+0x11e>
    kfree(argv[i]);
    80005d30:	ffffb097          	auipc	ra,0xffffb
    80005d34:	d42080e7          	jalr	-702(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d38:	e4840493          	addi	s1,s0,-440
    80005d3c:	10098993          	addi	s3,s3,256
    80005d40:	6088                	ld	a0,0(s1)
    80005d42:	cd31                	beqz	a0,80005d9e <sys_exec+0x11c>
    kfree(argv[i]);
    80005d44:	ffffb097          	auipc	ra,0xffffb
    80005d48:	d2e080e7          	jalr	-722(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d4c:	04a1                	addi	s1,s1,8
    80005d4e:	ff3499e3          	bne	s1,s3,80005d40 <sys_exec+0xbe>
  return -1;
    80005d52:	597d                	li	s2,-1
    80005d54:	a0b1                	j	80005da0 <sys_exec+0x11e>
      argv[i] = 0;
    80005d56:	0a0e                	slli	s4,s4,0x3
    80005d58:	fc040793          	addi	a5,s0,-64
    80005d5c:	9a3e                	add	s4,s4,a5
    80005d5e:	e80a3023          	sd	zero,-384(s4)
  int ret = exec(path, argv);
    80005d62:	e4040593          	addi	a1,s0,-448
    80005d66:	f4040513          	addi	a0,s0,-192
    80005d6a:	fffff097          	auipc	ra,0xfffff
    80005d6e:	166080e7          	jalr	358(ra) # 80004ed0 <exec>
    80005d72:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d74:	e4043503          	ld	a0,-448(s0)
    80005d78:	c505                	beqz	a0,80005da0 <sys_exec+0x11e>
    kfree(argv[i]);
    80005d7a:	ffffb097          	auipc	ra,0xffffb
    80005d7e:	cf8080e7          	jalr	-776(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d82:	e4840493          	addi	s1,s0,-440
    80005d86:	10098993          	addi	s3,s3,256
    80005d8a:	6088                	ld	a0,0(s1)
    80005d8c:	c911                	beqz	a0,80005da0 <sys_exec+0x11e>
    kfree(argv[i]);
    80005d8e:	ffffb097          	auipc	ra,0xffffb
    80005d92:	ce4080e7          	jalr	-796(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d96:	04a1                	addi	s1,s1,8
    80005d98:	ff3499e3          	bne	s1,s3,80005d8a <sys_exec+0x108>
    80005d9c:	a011                	j	80005da0 <sys_exec+0x11e>
  return -1;
    80005d9e:	597d                	li	s2,-1
}
    80005da0:	854a                	mv	a0,s2
    80005da2:	60be                	ld	ra,456(sp)
    80005da4:	641e                	ld	s0,448(sp)
    80005da6:	74fa                	ld	s1,440(sp)
    80005da8:	795a                	ld	s2,432(sp)
    80005daa:	79ba                	ld	s3,424(sp)
    80005dac:	7a1a                	ld	s4,416(sp)
    80005dae:	6afa                	ld	s5,408(sp)
    80005db0:	6179                	addi	sp,sp,464
    80005db2:	8082                	ret

0000000080005db4 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005db4:	7139                	addi	sp,sp,-64
    80005db6:	fc06                	sd	ra,56(sp)
    80005db8:	f822                	sd	s0,48(sp)
    80005dba:	f426                	sd	s1,40(sp)
    80005dbc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005dbe:	ffffc097          	auipc	ra,0xffffc
    80005dc2:	ed0080e7          	jalr	-304(ra) # 80001c8e <myproc>
    80005dc6:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005dc8:	fd840593          	addi	a1,s0,-40
    80005dcc:	4501                	li	a0,0
    80005dce:	ffffd097          	auipc	ra,0xffffd
    80005dd2:	fd6080e7          	jalr	-42(ra) # 80002da4 <argaddr>
    return -1;
    80005dd6:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005dd8:	0c054f63          	bltz	a0,80005eb6 <sys_pipe+0x102>
  if(pipealloc(&rf, &wf) < 0)
    80005ddc:	fc840593          	addi	a1,s0,-56
    80005de0:	fd040513          	addi	a0,s0,-48
    80005de4:	fffff097          	auipc	ra,0xfffff
    80005de8:	d74080e7          	jalr	-652(ra) # 80004b58 <pipealloc>
    return -1;
    80005dec:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005dee:	0c054463          	bltz	a0,80005eb6 <sys_pipe+0x102>
  fd0 = -1;
    80005df2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005df6:	fd043503          	ld	a0,-48(s0)
    80005dfa:	fffff097          	auipc	ra,0xfffff
    80005dfe:	4e2080e7          	jalr	1250(ra) # 800052dc <fdalloc>
    80005e02:	fca42223          	sw	a0,-60(s0)
    80005e06:	08054b63          	bltz	a0,80005e9c <sys_pipe+0xe8>
    80005e0a:	fc843503          	ld	a0,-56(s0)
    80005e0e:	fffff097          	auipc	ra,0xfffff
    80005e12:	4ce080e7          	jalr	1230(ra) # 800052dc <fdalloc>
    80005e16:	fca42023          	sw	a0,-64(s0)
    80005e1a:	06054863          	bltz	a0,80005e8a <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e1e:	4691                	li	a3,4
    80005e20:	fc440613          	addi	a2,s0,-60
    80005e24:	fd843583          	ld	a1,-40(s0)
    80005e28:	68a8                	ld	a0,80(s1)
    80005e2a:	ffffc097          	auipc	ra,0xffffc
    80005e2e:	c28080e7          	jalr	-984(ra) # 80001a52 <copyout>
    80005e32:	02054063          	bltz	a0,80005e52 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e36:	4691                	li	a3,4
    80005e38:	fc040613          	addi	a2,s0,-64
    80005e3c:	fd843583          	ld	a1,-40(s0)
    80005e40:	0591                	addi	a1,a1,4
    80005e42:	68a8                	ld	a0,80(s1)
    80005e44:	ffffc097          	auipc	ra,0xffffc
    80005e48:	c0e080e7          	jalr	-1010(ra) # 80001a52 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e4c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e4e:	06055463          	bgez	a0,80005eb6 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80005e52:	fc442783          	lw	a5,-60(s0)
    80005e56:	07e9                	addi	a5,a5,26
    80005e58:	078e                	slli	a5,a5,0x3
    80005e5a:	97a6                	add	a5,a5,s1
    80005e5c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e60:	fc042783          	lw	a5,-64(s0)
    80005e64:	07e9                	addi	a5,a5,26
    80005e66:	078e                	slli	a5,a5,0x3
    80005e68:	94be                	add	s1,s1,a5
    80005e6a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e6e:	fd043503          	ld	a0,-48(s0)
    80005e72:	fffff097          	auipc	ra,0xfffff
    80005e76:	99e080e7          	jalr	-1634(ra) # 80004810 <fileclose>
    fileclose(wf);
    80005e7a:	fc843503          	ld	a0,-56(s0)
    80005e7e:	fffff097          	auipc	ra,0xfffff
    80005e82:	992080e7          	jalr	-1646(ra) # 80004810 <fileclose>
    return -1;
    80005e86:	57fd                	li	a5,-1
    80005e88:	a03d                	j	80005eb6 <sys_pipe+0x102>
    if(fd0 >= 0)
    80005e8a:	fc442783          	lw	a5,-60(s0)
    80005e8e:	0007c763          	bltz	a5,80005e9c <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005e92:	07e9                	addi	a5,a5,26
    80005e94:	078e                	slli	a5,a5,0x3
    80005e96:	94be                	add	s1,s1,a5
    80005e98:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e9c:	fd043503          	ld	a0,-48(s0)
    80005ea0:	fffff097          	auipc	ra,0xfffff
    80005ea4:	970080e7          	jalr	-1680(ra) # 80004810 <fileclose>
    fileclose(wf);
    80005ea8:	fc843503          	ld	a0,-56(s0)
    80005eac:	fffff097          	auipc	ra,0xfffff
    80005eb0:	964080e7          	jalr	-1692(ra) # 80004810 <fileclose>
    return -1;
    80005eb4:	57fd                	li	a5,-1
}
    80005eb6:	853e                	mv	a0,a5
    80005eb8:	70e2                	ld	ra,56(sp)
    80005eba:	7442                	ld	s0,48(sp)
    80005ebc:	74a2                	ld	s1,40(sp)
    80005ebe:	6121                	addi	sp,sp,64
    80005ec0:	8082                	ret
	...

0000000080005ed0 <kernelvec>:
    80005ed0:	7111                	addi	sp,sp,-256
    80005ed2:	e006                	sd	ra,0(sp)
    80005ed4:	e40a                	sd	sp,8(sp)
    80005ed6:	e80e                	sd	gp,16(sp)
    80005ed8:	ec12                	sd	tp,24(sp)
    80005eda:	f016                	sd	t0,32(sp)
    80005edc:	f41a                	sd	t1,40(sp)
    80005ede:	f81e                	sd	t2,48(sp)
    80005ee0:	fc22                	sd	s0,56(sp)
    80005ee2:	e0a6                	sd	s1,64(sp)
    80005ee4:	e4aa                	sd	a0,72(sp)
    80005ee6:	e8ae                	sd	a1,80(sp)
    80005ee8:	ecb2                	sd	a2,88(sp)
    80005eea:	f0b6                	sd	a3,96(sp)
    80005eec:	f4ba                	sd	a4,104(sp)
    80005eee:	f8be                	sd	a5,112(sp)
    80005ef0:	fcc2                	sd	a6,120(sp)
    80005ef2:	e146                	sd	a7,128(sp)
    80005ef4:	e54a                	sd	s2,136(sp)
    80005ef6:	e94e                	sd	s3,144(sp)
    80005ef8:	ed52                	sd	s4,152(sp)
    80005efa:	f156                	sd	s5,160(sp)
    80005efc:	f55a                	sd	s6,168(sp)
    80005efe:	f95e                	sd	s7,176(sp)
    80005f00:	fd62                	sd	s8,184(sp)
    80005f02:	e1e6                	sd	s9,192(sp)
    80005f04:	e5ea                	sd	s10,200(sp)
    80005f06:	e9ee                	sd	s11,208(sp)
    80005f08:	edf2                	sd	t3,216(sp)
    80005f0a:	f1f6                	sd	t4,224(sp)
    80005f0c:	f5fa                	sd	t5,232(sp)
    80005f0e:	f9fe                	sd	t6,240(sp)
    80005f10:	c9ffc0ef          	jal	ra,80002bae <kerneltrap>
    80005f14:	6082                	ld	ra,0(sp)
    80005f16:	6122                	ld	sp,8(sp)
    80005f18:	61c2                	ld	gp,16(sp)
    80005f1a:	7282                	ld	t0,32(sp)
    80005f1c:	7322                	ld	t1,40(sp)
    80005f1e:	73c2                	ld	t2,48(sp)
    80005f20:	7462                	ld	s0,56(sp)
    80005f22:	6486                	ld	s1,64(sp)
    80005f24:	6526                	ld	a0,72(sp)
    80005f26:	65c6                	ld	a1,80(sp)
    80005f28:	6666                	ld	a2,88(sp)
    80005f2a:	7686                	ld	a3,96(sp)
    80005f2c:	7726                	ld	a4,104(sp)
    80005f2e:	77c6                	ld	a5,112(sp)
    80005f30:	7866                	ld	a6,120(sp)
    80005f32:	688a                	ld	a7,128(sp)
    80005f34:	692a                	ld	s2,136(sp)
    80005f36:	69ca                	ld	s3,144(sp)
    80005f38:	6a6a                	ld	s4,152(sp)
    80005f3a:	7a8a                	ld	s5,160(sp)
    80005f3c:	7b2a                	ld	s6,168(sp)
    80005f3e:	7bca                	ld	s7,176(sp)
    80005f40:	7c6a                	ld	s8,184(sp)
    80005f42:	6c8e                	ld	s9,192(sp)
    80005f44:	6d2e                	ld	s10,200(sp)
    80005f46:	6dce                	ld	s11,208(sp)
    80005f48:	6e6e                	ld	t3,216(sp)
    80005f4a:	7e8e                	ld	t4,224(sp)
    80005f4c:	7f2e                	ld	t5,232(sp)
    80005f4e:	7fce                	ld	t6,240(sp)
    80005f50:	6111                	addi	sp,sp,256
    80005f52:	10200073          	sret
    80005f56:	00000013          	nop
    80005f5a:	00000013          	nop
    80005f5e:	0001                	nop

0000000080005f60 <timervec>:
    80005f60:	34051573          	csrrw	a0,mscratch,a0
    80005f64:	e10c                	sd	a1,0(a0)
    80005f66:	e510                	sd	a2,8(a0)
    80005f68:	e914                	sd	a3,16(a0)
    80005f6a:	710c                	ld	a1,32(a0)
    80005f6c:	7510                	ld	a2,40(a0)
    80005f6e:	6194                	ld	a3,0(a1)
    80005f70:	96b2                	add	a3,a3,a2
    80005f72:	e194                	sd	a3,0(a1)
    80005f74:	4589                	li	a1,2
    80005f76:	14459073          	csrw	sip,a1
    80005f7a:	6914                	ld	a3,16(a0)
    80005f7c:	6510                	ld	a2,8(a0)
    80005f7e:	610c                	ld	a1,0(a0)
    80005f80:	34051573          	csrrw	a0,mscratch,a0
    80005f84:	30200073          	mret
	...

0000000080005f8a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f8a:	1141                	addi	sp,sp,-16
    80005f8c:	e422                	sd	s0,8(sp)
    80005f8e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f90:	0c0007b7          	lui	a5,0xc000
    80005f94:	4705                	li	a4,1
    80005f96:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f98:	c3d8                	sw	a4,4(a5)
}
    80005f9a:	6422                	ld	s0,8(sp)
    80005f9c:	0141                	addi	sp,sp,16
    80005f9e:	8082                	ret

0000000080005fa0 <plicinithart>:

void
plicinithart(void)
{
    80005fa0:	1141                	addi	sp,sp,-16
    80005fa2:	e406                	sd	ra,8(sp)
    80005fa4:	e022                	sd	s0,0(sp)
    80005fa6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fa8:	ffffc097          	auipc	ra,0xffffc
    80005fac:	cba080e7          	jalr	-838(ra) # 80001c62 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005fb0:	0085171b          	slliw	a4,a0,0x8
    80005fb4:	0c0027b7          	lui	a5,0xc002
    80005fb8:	97ba                	add	a5,a5,a4
    80005fba:	40200713          	li	a4,1026
    80005fbe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005fc2:	00d5151b          	slliw	a0,a0,0xd
    80005fc6:	0c2017b7          	lui	a5,0xc201
    80005fca:	953e                	add	a0,a0,a5
    80005fcc:	00052023          	sw	zero,0(a0)
}
    80005fd0:	60a2                	ld	ra,8(sp)
    80005fd2:	6402                	ld	s0,0(sp)
    80005fd4:	0141                	addi	sp,sp,16
    80005fd6:	8082                	ret

0000000080005fd8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005fd8:	1141                	addi	sp,sp,-16
    80005fda:	e406                	sd	ra,8(sp)
    80005fdc:	e022                	sd	s0,0(sp)
    80005fde:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fe0:	ffffc097          	auipc	ra,0xffffc
    80005fe4:	c82080e7          	jalr	-894(ra) # 80001c62 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005fe8:	00d5151b          	slliw	a0,a0,0xd
    80005fec:	0c2017b7          	lui	a5,0xc201
    80005ff0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005ff2:	43c8                	lw	a0,4(a5)
    80005ff4:	60a2                	ld	ra,8(sp)
    80005ff6:	6402                	ld	s0,0(sp)
    80005ff8:	0141                	addi	sp,sp,16
    80005ffa:	8082                	ret

0000000080005ffc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005ffc:	1101                	addi	sp,sp,-32
    80005ffe:	ec06                	sd	ra,24(sp)
    80006000:	e822                	sd	s0,16(sp)
    80006002:	e426                	sd	s1,8(sp)
    80006004:	1000                	addi	s0,sp,32
    80006006:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006008:	ffffc097          	auipc	ra,0xffffc
    8000600c:	c5a080e7          	jalr	-934(ra) # 80001c62 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006010:	00d5151b          	slliw	a0,a0,0xd
    80006014:	0c2017b7          	lui	a5,0xc201
    80006018:	97aa                	add	a5,a5,a0
    8000601a:	c3c4                	sw	s1,4(a5)
}
    8000601c:	60e2                	ld	ra,24(sp)
    8000601e:	6442                	ld	s0,16(sp)
    80006020:	64a2                	ld	s1,8(sp)
    80006022:	6105                	addi	sp,sp,32
    80006024:	8082                	ret

0000000080006026 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006026:	1141                	addi	sp,sp,-16
    80006028:	e406                	sd	ra,8(sp)
    8000602a:	e022                	sd	s0,0(sp)
    8000602c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000602e:	479d                	li	a5,7
    80006030:	04a7cd63          	blt	a5,a0,8000608a <free_desc+0x64>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80006034:	0023d797          	auipc	a5,0x23d
    80006038:	fcc78793          	addi	a5,a5,-52 # 80243000 <disk>
    8000603c:	00a78733          	add	a4,a5,a0
    80006040:	6789                	lui	a5,0x2
    80006042:	97ba                	add	a5,a5,a4
    80006044:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006048:	eba9                	bnez	a5,8000609a <free_desc+0x74>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    8000604a:	0023f797          	auipc	a5,0x23f
    8000604e:	fb678793          	addi	a5,a5,-74 # 80245000 <disk+0x2000>
    80006052:	639c                	ld	a5,0(a5)
    80006054:	00451713          	slli	a4,a0,0x4
    80006058:	97ba                	add	a5,a5,a4
    8000605a:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    8000605e:	0023d797          	auipc	a5,0x23d
    80006062:	fa278793          	addi	a5,a5,-94 # 80243000 <disk>
    80006066:	97aa                	add	a5,a5,a0
    80006068:	6509                	lui	a0,0x2
    8000606a:	953e                	add	a0,a0,a5
    8000606c:	4785                	li	a5,1
    8000606e:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006072:	0023f517          	auipc	a0,0x23f
    80006076:	fa650513          	addi	a0,a0,-90 # 80245018 <disk+0x2018>
    8000607a:	ffffc097          	auipc	ra,0xffffc
    8000607e:	5b4080e7          	jalr	1460(ra) # 8000262e <wakeup>
}
    80006082:	60a2                	ld	ra,8(sp)
    80006084:	6402                	ld	s0,0(sp)
    80006086:	0141                	addi	sp,sp,16
    80006088:	8082                	ret
    panic("virtio_disk_intr 1");
    8000608a:	00002517          	auipc	a0,0x2
    8000608e:	7b650513          	addi	a0,a0,1974 # 80008840 <syscalls+0x358>
    80006092:	ffffa097          	auipc	ra,0xffffa
    80006096:	4e2080e7          	jalr	1250(ra) # 80000574 <panic>
    panic("virtio_disk_intr 2");
    8000609a:	00002517          	auipc	a0,0x2
    8000609e:	7be50513          	addi	a0,a0,1982 # 80008858 <syscalls+0x370>
    800060a2:	ffffa097          	auipc	ra,0xffffa
    800060a6:	4d2080e7          	jalr	1234(ra) # 80000574 <panic>

00000000800060aa <virtio_disk_init>:
{
    800060aa:	1101                	addi	sp,sp,-32
    800060ac:	ec06                	sd	ra,24(sp)
    800060ae:	e822                	sd	s0,16(sp)
    800060b0:	e426                	sd	s1,8(sp)
    800060b2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800060b4:	00002597          	auipc	a1,0x2
    800060b8:	7bc58593          	addi	a1,a1,1980 # 80008870 <syscalls+0x388>
    800060bc:	0023f517          	auipc	a0,0x23f
    800060c0:	fec50513          	addi	a0,a0,-20 # 802450a8 <disk+0x20a8>
    800060c4:	ffffb097          	auipc	ra,0xffffb
    800060c8:	c0a080e7          	jalr	-1014(ra) # 80000cce <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060cc:	100017b7          	lui	a5,0x10001
    800060d0:	4398                	lw	a4,0(a5)
    800060d2:	2701                	sext.w	a4,a4
    800060d4:	747277b7          	lui	a5,0x74727
    800060d8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800060dc:	0ef71163          	bne	a4,a5,800061be <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800060e0:	100017b7          	lui	a5,0x10001
    800060e4:	43dc                	lw	a5,4(a5)
    800060e6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060e8:	4705                	li	a4,1
    800060ea:	0ce79a63          	bne	a5,a4,800061be <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060ee:	100017b7          	lui	a5,0x10001
    800060f2:	479c                	lw	a5,8(a5)
    800060f4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800060f6:	4709                	li	a4,2
    800060f8:	0ce79363          	bne	a5,a4,800061be <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800060fc:	100017b7          	lui	a5,0x10001
    80006100:	47d8                	lw	a4,12(a5)
    80006102:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006104:	554d47b7          	lui	a5,0x554d4
    80006108:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000610c:	0af71963          	bne	a4,a5,800061be <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006110:	100017b7          	lui	a5,0x10001
    80006114:	4705                	li	a4,1
    80006116:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006118:	470d                	li	a4,3
    8000611a:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000611c:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000611e:	c7ffe737          	lui	a4,0xc7ffe
    80006122:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47db875f>
    80006126:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006128:	2701                	sext.w	a4,a4
    8000612a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000612c:	472d                	li	a4,11
    8000612e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006130:	473d                	li	a4,15
    80006132:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006134:	6705                	lui	a4,0x1
    80006136:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006138:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000613c:	5bdc                	lw	a5,52(a5)
    8000613e:	2781                	sext.w	a5,a5
  if(max == 0)
    80006140:	c7d9                	beqz	a5,800061ce <virtio_disk_init+0x124>
  if(max < NUM)
    80006142:	471d                	li	a4,7
    80006144:	08f77d63          	bleu	a5,a4,800061de <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006148:	100014b7          	lui	s1,0x10001
    8000614c:	47a1                	li	a5,8
    8000614e:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006150:	6609                	lui	a2,0x2
    80006152:	4581                	li	a1,0
    80006154:	0023d517          	auipc	a0,0x23d
    80006158:	eac50513          	addi	a0,a0,-340 # 80243000 <disk>
    8000615c:	ffffb097          	auipc	ra,0xffffb
    80006160:	cfe080e7          	jalr	-770(ra) # 80000e5a <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006164:	0023d717          	auipc	a4,0x23d
    80006168:	e9c70713          	addi	a4,a4,-356 # 80243000 <disk>
    8000616c:	00c75793          	srli	a5,a4,0xc
    80006170:	2781                	sext.w	a5,a5
    80006172:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80006174:	0023f797          	auipc	a5,0x23f
    80006178:	e8c78793          	addi	a5,a5,-372 # 80245000 <disk+0x2000>
    8000617c:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    8000617e:	0023d717          	auipc	a4,0x23d
    80006182:	f0270713          	addi	a4,a4,-254 # 80243080 <disk+0x80>
    80006186:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80006188:	0023e717          	auipc	a4,0x23e
    8000618c:	e7870713          	addi	a4,a4,-392 # 80244000 <disk+0x1000>
    80006190:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006192:	4705                	li	a4,1
    80006194:	00e78c23          	sb	a4,24(a5)
    80006198:	00e78ca3          	sb	a4,25(a5)
    8000619c:	00e78d23          	sb	a4,26(a5)
    800061a0:	00e78da3          	sb	a4,27(a5)
    800061a4:	00e78e23          	sb	a4,28(a5)
    800061a8:	00e78ea3          	sb	a4,29(a5)
    800061ac:	00e78f23          	sb	a4,30(a5)
    800061b0:	00e78fa3          	sb	a4,31(a5)
}
    800061b4:	60e2                	ld	ra,24(sp)
    800061b6:	6442                	ld	s0,16(sp)
    800061b8:	64a2                	ld	s1,8(sp)
    800061ba:	6105                	addi	sp,sp,32
    800061bc:	8082                	ret
    panic("could not find virtio disk");
    800061be:	00002517          	auipc	a0,0x2
    800061c2:	6c250513          	addi	a0,a0,1730 # 80008880 <syscalls+0x398>
    800061c6:	ffffa097          	auipc	ra,0xffffa
    800061ca:	3ae080e7          	jalr	942(ra) # 80000574 <panic>
    panic("virtio disk has no queue 0");
    800061ce:	00002517          	auipc	a0,0x2
    800061d2:	6d250513          	addi	a0,a0,1746 # 800088a0 <syscalls+0x3b8>
    800061d6:	ffffa097          	auipc	ra,0xffffa
    800061da:	39e080e7          	jalr	926(ra) # 80000574 <panic>
    panic("virtio disk max queue too short");
    800061de:	00002517          	auipc	a0,0x2
    800061e2:	6e250513          	addi	a0,a0,1762 # 800088c0 <syscalls+0x3d8>
    800061e6:	ffffa097          	auipc	ra,0xffffa
    800061ea:	38e080e7          	jalr	910(ra) # 80000574 <panic>

00000000800061ee <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800061ee:	7159                	addi	sp,sp,-112
    800061f0:	f486                	sd	ra,104(sp)
    800061f2:	f0a2                	sd	s0,96(sp)
    800061f4:	eca6                	sd	s1,88(sp)
    800061f6:	e8ca                	sd	s2,80(sp)
    800061f8:	e4ce                	sd	s3,72(sp)
    800061fa:	e0d2                	sd	s4,64(sp)
    800061fc:	fc56                	sd	s5,56(sp)
    800061fe:	f85a                	sd	s6,48(sp)
    80006200:	f45e                	sd	s7,40(sp)
    80006202:	f062                	sd	s8,32(sp)
    80006204:	1880                	addi	s0,sp,112
    80006206:	892a                	mv	s2,a0
    80006208:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000620a:	00c52b83          	lw	s7,12(a0)
    8000620e:	001b9b9b          	slliw	s7,s7,0x1
    80006212:	1b82                	slli	s7,s7,0x20
    80006214:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80006218:	0023f517          	auipc	a0,0x23f
    8000621c:	e9050513          	addi	a0,a0,-368 # 802450a8 <disk+0x20a8>
    80006220:	ffffb097          	auipc	ra,0xffffb
    80006224:	b3e080e7          	jalr	-1218(ra) # 80000d5e <acquire>
    if(disk.free[i]){
    80006228:	0023f997          	auipc	s3,0x23f
    8000622c:	dd898993          	addi	s3,s3,-552 # 80245000 <disk+0x2000>
  for(int i = 0; i < NUM; i++){
    80006230:	4b21                	li	s6,8
      disk.free[i] = 0;
    80006232:	0023da97          	auipc	s5,0x23d
    80006236:	dcea8a93          	addi	s5,s5,-562 # 80243000 <disk>
  for(int i = 0; i < 3; i++){
    8000623a:	4a0d                	li	s4,3
    8000623c:	a079                	j	800062ca <virtio_disk_rw+0xdc>
      disk.free[i] = 0;
    8000623e:	00fa86b3          	add	a3,s5,a5
    80006242:	96ae                	add	a3,a3,a1
    80006244:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006248:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000624a:	0207ca63          	bltz	a5,8000627e <virtio_disk_rw+0x90>
  for(int i = 0; i < 3; i++){
    8000624e:	2485                	addiw	s1,s1,1
    80006250:	0711                	addi	a4,a4,4
    80006252:	25448163          	beq	s1,s4,80006494 <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80006256:	863a                	mv	a2,a4
    if(disk.free[i]){
    80006258:	0189c783          	lbu	a5,24(s3)
    8000625c:	24079163          	bnez	a5,8000649e <virtio_disk_rw+0x2b0>
    80006260:	0023f697          	auipc	a3,0x23f
    80006264:	db968693          	addi	a3,a3,-583 # 80245019 <disk+0x2019>
  for(int i = 0; i < NUM; i++){
    80006268:	87aa                	mv	a5,a0
    if(disk.free[i]){
    8000626a:	0006c803          	lbu	a6,0(a3)
    8000626e:	fc0818e3          	bnez	a6,8000623e <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80006272:	2785                	addiw	a5,a5,1
    80006274:	0685                	addi	a3,a3,1
    80006276:	ff679ae3          	bne	a5,s6,8000626a <virtio_disk_rw+0x7c>
    idx[i] = alloc_desc();
    8000627a:	57fd                	li	a5,-1
    8000627c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000627e:	02905a63          	blez	s1,800062b2 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    80006282:	fa042503          	lw	a0,-96(s0)
    80006286:	00000097          	auipc	ra,0x0
    8000628a:	da0080e7          	jalr	-608(ra) # 80006026 <free_desc>
      for(int j = 0; j < i; j++)
    8000628e:	4785                	li	a5,1
    80006290:	0297d163          	ble	s1,a5,800062b2 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    80006294:	fa442503          	lw	a0,-92(s0)
    80006298:	00000097          	auipc	ra,0x0
    8000629c:	d8e080e7          	jalr	-626(ra) # 80006026 <free_desc>
      for(int j = 0; j < i; j++)
    800062a0:	4789                	li	a5,2
    800062a2:	0097d863          	ble	s1,a5,800062b2 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800062a6:	fa842503          	lw	a0,-88(s0)
    800062aa:	00000097          	auipc	ra,0x0
    800062ae:	d7c080e7          	jalr	-644(ra) # 80006026 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062b2:	0023f597          	auipc	a1,0x23f
    800062b6:	df658593          	addi	a1,a1,-522 # 802450a8 <disk+0x20a8>
    800062ba:	0023f517          	auipc	a0,0x23f
    800062be:	d5e50513          	addi	a0,a0,-674 # 80245018 <disk+0x2018>
    800062c2:	ffffc097          	auipc	ra,0xffffc
    800062c6:	1e6080e7          	jalr	486(ra) # 800024a8 <sleep>
  for(int i = 0; i < 3; i++){
    800062ca:	fa040713          	addi	a4,s0,-96
    800062ce:	4481                	li	s1,0
  for(int i = 0; i < NUM; i++){
    800062d0:	4505                	li	a0,1
      disk.free[i] = 0;
    800062d2:	6589                	lui	a1,0x2
    800062d4:	b749                	j	80006256 <virtio_disk_rw+0x68>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    800062d6:	4785                	li	a5,1
    800062d8:	f8f42823          	sw	a5,-112(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    800062dc:	f8042a23          	sw	zero,-108(s0)
  buf0.sector = sector;
    800062e0:	f9743c23          	sd	s7,-104(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    800062e4:	fa042983          	lw	s3,-96(s0)
    800062e8:	00499493          	slli	s1,s3,0x4
    800062ec:	0023fa17          	auipc	s4,0x23f
    800062f0:	d14a0a13          	addi	s4,s4,-748 # 80245000 <disk+0x2000>
    800062f4:	000a3a83          	ld	s5,0(s4)
    800062f8:	9aa6                	add	s5,s5,s1
    800062fa:	f9040513          	addi	a0,s0,-112
    800062fe:	ffffb097          	auipc	ra,0xffffb
    80006302:	f54080e7          	jalr	-172(ra) # 80001252 <kvmpa>
    80006306:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    8000630a:	000a3783          	ld	a5,0(s4)
    8000630e:	97a6                	add	a5,a5,s1
    80006310:	4741                	li	a4,16
    80006312:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006314:	000a3783          	ld	a5,0(s4)
    80006318:	97a6                	add	a5,a5,s1
    8000631a:	4705                	li	a4,1
    8000631c:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80006320:	fa442703          	lw	a4,-92(s0)
    80006324:	000a3783          	ld	a5,0(s4)
    80006328:	97a6                	add	a5,a5,s1
    8000632a:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000632e:	0712                	slli	a4,a4,0x4
    80006330:	000a3783          	ld	a5,0(s4)
    80006334:	97ba                	add	a5,a5,a4
    80006336:	05890693          	addi	a3,s2,88
    8000633a:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    8000633c:	000a3783          	ld	a5,0(s4)
    80006340:	97ba                	add	a5,a5,a4
    80006342:	40000693          	li	a3,1024
    80006346:	c794                	sw	a3,8(a5)
  if(write)
    80006348:	100c0863          	beqz	s8,80006458 <virtio_disk_rw+0x26a>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000634c:	000a3783          	ld	a5,0(s4)
    80006350:	97ba                	add	a5,a5,a4
    80006352:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006356:	0023d517          	auipc	a0,0x23d
    8000635a:	caa50513          	addi	a0,a0,-854 # 80243000 <disk>
    8000635e:	0023f797          	auipc	a5,0x23f
    80006362:	ca278793          	addi	a5,a5,-862 # 80245000 <disk+0x2000>
    80006366:	6394                	ld	a3,0(a5)
    80006368:	96ba                	add	a3,a3,a4
    8000636a:	00c6d603          	lhu	a2,12(a3)
    8000636e:	00166613          	ori	a2,a2,1
    80006372:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006376:	fa842683          	lw	a3,-88(s0)
    8000637a:	6390                	ld	a2,0(a5)
    8000637c:	9732                	add	a4,a4,a2
    8000637e:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    80006382:	20098613          	addi	a2,s3,512
    80006386:	0612                	slli	a2,a2,0x4
    80006388:	962a                	add	a2,a2,a0
    8000638a:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000638e:	00469713          	slli	a4,a3,0x4
    80006392:	6394                	ld	a3,0(a5)
    80006394:	96ba                	add	a3,a3,a4
    80006396:	6589                	lui	a1,0x2
    80006398:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    8000639c:	94ae                	add	s1,s1,a1
    8000639e:	94aa                	add	s1,s1,a0
    800063a0:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    800063a2:	6394                	ld	a3,0(a5)
    800063a4:	96ba                	add	a3,a3,a4
    800063a6:	4585                	li	a1,1
    800063a8:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800063aa:	6394                	ld	a3,0(a5)
    800063ac:	96ba                	add	a3,a3,a4
    800063ae:	4509                	li	a0,2
    800063b0:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    800063b4:	6394                	ld	a3,0(a5)
    800063b6:	9736                	add	a4,a4,a3
    800063b8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800063bc:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800063c0:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    800063c4:	6794                	ld	a3,8(a5)
    800063c6:	0026d703          	lhu	a4,2(a3)
    800063ca:	8b1d                	andi	a4,a4,7
    800063cc:	2709                	addiw	a4,a4,2
    800063ce:	0706                	slli	a4,a4,0x1
    800063d0:	9736                	add	a4,a4,a3
    800063d2:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    800063d6:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    800063da:	6798                	ld	a4,8(a5)
    800063dc:	00275783          	lhu	a5,2(a4)
    800063e0:	2785                	addiw	a5,a5,1
    800063e2:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800063e6:	100017b7          	lui	a5,0x10001
    800063ea:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800063ee:	00492703          	lw	a4,4(s2)
    800063f2:	4785                	li	a5,1
    800063f4:	02f71163          	bne	a4,a5,80006416 <virtio_disk_rw+0x228>
    sleep(b, &disk.vdisk_lock);
    800063f8:	0023f997          	auipc	s3,0x23f
    800063fc:	cb098993          	addi	s3,s3,-848 # 802450a8 <disk+0x20a8>
  while(b->disk == 1) {
    80006400:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006402:	85ce                	mv	a1,s3
    80006404:	854a                	mv	a0,s2
    80006406:	ffffc097          	auipc	ra,0xffffc
    8000640a:	0a2080e7          	jalr	162(ra) # 800024a8 <sleep>
  while(b->disk == 1) {
    8000640e:	00492783          	lw	a5,4(s2)
    80006412:	fe9788e3          	beq	a5,s1,80006402 <virtio_disk_rw+0x214>
  }

  disk.info[idx[0]].b = 0;
    80006416:	fa042483          	lw	s1,-96(s0)
    8000641a:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    8000641e:	00479713          	slli	a4,a5,0x4
    80006422:	0023d797          	auipc	a5,0x23d
    80006426:	bde78793          	addi	a5,a5,-1058 # 80243000 <disk>
    8000642a:	97ba                	add	a5,a5,a4
    8000642c:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006430:	0023f917          	auipc	s2,0x23f
    80006434:	bd090913          	addi	s2,s2,-1072 # 80245000 <disk+0x2000>
    free_desc(i);
    80006438:	8526                	mv	a0,s1
    8000643a:	00000097          	auipc	ra,0x0
    8000643e:	bec080e7          	jalr	-1044(ra) # 80006026 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006442:	0492                	slli	s1,s1,0x4
    80006444:	00093783          	ld	a5,0(s2)
    80006448:	94be                	add	s1,s1,a5
    8000644a:	00c4d783          	lhu	a5,12(s1)
    8000644e:	8b85                	andi	a5,a5,1
    80006450:	cf91                	beqz	a5,8000646c <virtio_disk_rw+0x27e>
      i = disk.desc[i].next;
    80006452:	00e4d483          	lhu	s1,14(s1)
  while(1){
    80006456:	b7cd                	j	80006438 <virtio_disk_rw+0x24a>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006458:	0023f797          	auipc	a5,0x23f
    8000645c:	ba878793          	addi	a5,a5,-1112 # 80245000 <disk+0x2000>
    80006460:	639c                	ld	a5,0(a5)
    80006462:	97ba                	add	a5,a5,a4
    80006464:	4689                	li	a3,2
    80006466:	00d79623          	sh	a3,12(a5)
    8000646a:	b5f5                	j	80006356 <virtio_disk_rw+0x168>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000646c:	0023f517          	auipc	a0,0x23f
    80006470:	c3c50513          	addi	a0,a0,-964 # 802450a8 <disk+0x20a8>
    80006474:	ffffb097          	auipc	ra,0xffffb
    80006478:	99e080e7          	jalr	-1634(ra) # 80000e12 <release>
}
    8000647c:	70a6                	ld	ra,104(sp)
    8000647e:	7406                	ld	s0,96(sp)
    80006480:	64e6                	ld	s1,88(sp)
    80006482:	6946                	ld	s2,80(sp)
    80006484:	69a6                	ld	s3,72(sp)
    80006486:	6a06                	ld	s4,64(sp)
    80006488:	7ae2                	ld	s5,56(sp)
    8000648a:	7b42                	ld	s6,48(sp)
    8000648c:	7ba2                	ld	s7,40(sp)
    8000648e:	7c02                	ld	s8,32(sp)
    80006490:	6165                	addi	sp,sp,112
    80006492:	8082                	ret
  if(write)
    80006494:	e40c11e3          	bnez	s8,800062d6 <virtio_disk_rw+0xe8>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006498:	f8042823          	sw	zero,-112(s0)
    8000649c:	b581                	j	800062dc <virtio_disk_rw+0xee>
      disk.free[i] = 0;
    8000649e:	00098c23          	sb	zero,24(s3)
    idx[i] = alloc_desc();
    800064a2:	00072023          	sw	zero,0(a4)
    if(idx[i] < 0){
    800064a6:	b365                	j	8000624e <virtio_disk_rw+0x60>

00000000800064a8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800064a8:	1101                	addi	sp,sp,-32
    800064aa:	ec06                	sd	ra,24(sp)
    800064ac:	e822                	sd	s0,16(sp)
    800064ae:	e426                	sd	s1,8(sp)
    800064b0:	e04a                	sd	s2,0(sp)
    800064b2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800064b4:	0023f517          	auipc	a0,0x23f
    800064b8:	bf450513          	addi	a0,a0,-1036 # 802450a8 <disk+0x20a8>
    800064bc:	ffffb097          	auipc	ra,0xffffb
    800064c0:	8a2080e7          	jalr	-1886(ra) # 80000d5e <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800064c4:	0023f797          	auipc	a5,0x23f
    800064c8:	b3c78793          	addi	a5,a5,-1220 # 80245000 <disk+0x2000>
    800064cc:	0207d683          	lhu	a3,32(a5)
    800064d0:	6b98                	ld	a4,16(a5)
    800064d2:	00275783          	lhu	a5,2(a4)
    800064d6:	8fb5                	xor	a5,a5,a3
    800064d8:	8b9d                	andi	a5,a5,7
    800064da:	c7c9                	beqz	a5,80006564 <virtio_disk_intr+0xbc>
    int id = disk.used->elems[disk.used_idx].id;
    800064dc:	068e                	slli	a3,a3,0x3
    800064de:	9736                	add	a4,a4,a3
    800064e0:	435c                	lw	a5,4(a4)

    if(disk.info[id].status != 0)
    800064e2:	20078713          	addi	a4,a5,512
    800064e6:	00471693          	slli	a3,a4,0x4
    800064ea:	0023d717          	auipc	a4,0x23d
    800064ee:	b1670713          	addi	a4,a4,-1258 # 80243000 <disk>
    800064f2:	9736                	add	a4,a4,a3
    800064f4:	03074703          	lbu	a4,48(a4)
    800064f8:	ef31                	bnez	a4,80006554 <virtio_disk_intr+0xac>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    800064fa:	0023d917          	auipc	s2,0x23d
    800064fe:	b0690913          	addi	s2,s2,-1274 # 80243000 <disk>
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006502:	0023f497          	auipc	s1,0x23f
    80006506:	afe48493          	addi	s1,s1,-1282 # 80245000 <disk+0x2000>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000650a:	20078793          	addi	a5,a5,512
    8000650e:	0792                	slli	a5,a5,0x4
    80006510:	97ca                	add	a5,a5,s2
    80006512:	7798                	ld	a4,40(a5)
    80006514:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    80006518:	7788                	ld	a0,40(a5)
    8000651a:	ffffc097          	auipc	ra,0xffffc
    8000651e:	114080e7          	jalr	276(ra) # 8000262e <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006522:	0204d783          	lhu	a5,32(s1)
    80006526:	2785                	addiw	a5,a5,1
    80006528:	8b9d                	andi	a5,a5,7
    8000652a:	03079613          	slli	a2,a5,0x30
    8000652e:	9241                	srli	a2,a2,0x30
    80006530:	02c49023          	sh	a2,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006534:	6898                	ld	a4,16(s1)
    80006536:	00275683          	lhu	a3,2(a4)
    8000653a:	8a9d                	andi	a3,a3,7
    8000653c:	02c68463          	beq	a3,a2,80006564 <virtio_disk_intr+0xbc>
    int id = disk.used->elems[disk.used_idx].id;
    80006540:	078e                	slli	a5,a5,0x3
    80006542:	97ba                	add	a5,a5,a4
    80006544:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006546:	20078713          	addi	a4,a5,512
    8000654a:	0712                	slli	a4,a4,0x4
    8000654c:	974a                	add	a4,a4,s2
    8000654e:	03074703          	lbu	a4,48(a4)
    80006552:	df45                	beqz	a4,8000650a <virtio_disk_intr+0x62>
      panic("virtio_disk_intr status");
    80006554:	00002517          	auipc	a0,0x2
    80006558:	38c50513          	addi	a0,a0,908 # 800088e0 <syscalls+0x3f8>
    8000655c:	ffffa097          	auipc	ra,0xffffa
    80006560:	018080e7          	jalr	24(ra) # 80000574 <panic>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006564:	10001737          	lui	a4,0x10001
    80006568:	533c                	lw	a5,96(a4)
    8000656a:	8b8d                	andi	a5,a5,3
    8000656c:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    8000656e:	0023f517          	auipc	a0,0x23f
    80006572:	b3a50513          	addi	a0,a0,-1222 # 802450a8 <disk+0x20a8>
    80006576:	ffffb097          	auipc	ra,0xffffb
    8000657a:	89c080e7          	jalr	-1892(ra) # 80000e12 <release>
}
    8000657e:	60e2                	ld	ra,24(sp)
    80006580:	6442                	ld	s0,16(sp)
    80006582:	64a2                	ld	s1,8(sp)
    80006584:	6902                	ld	s2,0(sp)
    80006586:	6105                	addi	sp,sp,32
    80006588:	8082                	ret
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
