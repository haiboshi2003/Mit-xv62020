
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	85013103          	ld	sp,-1968(sp) # 80008850 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

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
    80000022:	f1402773          	csrr	a4,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	2701                	sext.w	a4,a4

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000028:	0037161b          	slliw	a2,a4,0x3
    8000002c:	020047b7          	lui	a5,0x2004
    80000030:	963e                	add	a2,a2,a5
    80000032:	0200c7b7          	lui	a5,0x200c
    80000036:	ff87b783          	ld	a5,-8(a5) # 200bff8 <_entry-0x7dff4008>
    8000003a:	000f46b7          	lui	a3,0xf4
    8000003e:	24068693          	addi	a3,a3,576 # f4240 <_entry-0x7ff0bdc0>
    80000042:	97b6                	add	a5,a5,a3
    80000044:	e21c                	sd	a5,0(a2)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000046:	00271793          	slli	a5,a4,0x2
    8000004a:	97ba                	add	a5,a5,a4
    8000004c:	00379713          	slli	a4,a5,0x3
    80000050:	00009797          	auipc	a5,0x9
    80000054:	fe078793          	addi	a5,a5,-32 # 80009030 <timer_scratch>
    80000058:	97ba                	add	a5,a5,a4
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef90                	sd	a2,24(a5)
  scratch[4] = interval;
    8000005c:	f394                	sd	a3,32(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	c4e78793          	addi	a5,a5,-946 # 80005cb0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e8a78793          	addi	a5,a5,-374 # 80000f36 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  timerinit();
    800000d6:	00000097          	auipc	ra,0x0
    800000da:	f46080e7          	jalr	-186(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000de:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e6:	30200073          	mret
}
    800000ea:	60a2                	ld	ra,8(sp)
    800000ec:	6402                	ld	s0,0(sp)
    800000ee:	0141                	addi	sp,sp,16
    800000f0:	8082                	ret

00000000800000f2 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f2:	715d                	addi	sp,sp,-80
    800000f4:	e486                	sd	ra,72(sp)
    800000f6:	e0a2                	sd	s0,64(sp)
    800000f8:	fc26                	sd	s1,56(sp)
    800000fa:	f84a                	sd	s2,48(sp)
    800000fc:	f44e                	sd	s3,40(sp)
    800000fe:	f052                	sd	s4,32(sp)
    80000100:	ec56                	sd	s5,24(sp)
    80000102:	0880                	addi	s0,sp,80
    80000104:	8a2a                	mv	s4,a0
    80000106:	892e                	mv	s2,a1
    80000108:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    8000010a:	00011517          	auipc	a0,0x11
    8000010e:	06650513          	addi	a0,a0,102 # 80011170 <cons>
    80000112:	00001097          	auipc	ra,0x1
    80000116:	b54080e7          	jalr	-1196(ra) # 80000c66 <acquire>
  for(i = 0; i < n; i++){
    8000011a:	05305b63          	blez	s3,80000170 <consolewrite+0x7e>
    8000011e:	4481                	li	s1,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	864a                	mv	a2,s2
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	3a4080e7          	jalr	932(ra) # 800024d0 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x5a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	7ee080e7          	jalr	2030(ra) # 8000092a <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2485                	addiw	s1,s1,1
    80000146:	0905                	addi	s2,s2,1
    80000148:	fc999de3          	bne	s3,s1,80000122 <consolewrite+0x30>
  }
  release(&cons.lock);
    8000014c:	00011517          	auipc	a0,0x11
    80000150:	02450513          	addi	a0,a0,36 # 80011170 <cons>
    80000154:	00001097          	auipc	ra,0x1
    80000158:	bc6080e7          	jalr	-1082(ra) # 80000d1a <release>

  return i;
}
    8000015c:	8526                	mv	a0,s1
    8000015e:	60a6                	ld	ra,72(sp)
    80000160:	6406                	ld	s0,64(sp)
    80000162:	74e2                	ld	s1,56(sp)
    80000164:	7942                	ld	s2,48(sp)
    80000166:	79a2                	ld	s3,40(sp)
    80000168:	7a02                	ld	s4,32(sp)
    8000016a:	6ae2                	ld	s5,24(sp)
    8000016c:	6161                	addi	sp,sp,80
    8000016e:	8082                	ret
  for(i = 0; i < n; i++){
    80000170:	4481                	li	s1,0
    80000172:	bfe9                	j	8000014c <consolewrite+0x5a>

0000000080000174 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000174:	7119                	addi	sp,sp,-128
    80000176:	fc86                	sd	ra,120(sp)
    80000178:	f8a2                	sd	s0,112(sp)
    8000017a:	f4a6                	sd	s1,104(sp)
    8000017c:	f0ca                	sd	s2,96(sp)
    8000017e:	ecce                	sd	s3,88(sp)
    80000180:	e8d2                	sd	s4,80(sp)
    80000182:	e4d6                	sd	s5,72(sp)
    80000184:	e0da                	sd	s6,64(sp)
    80000186:	fc5e                	sd	s7,56(sp)
    80000188:	f862                	sd	s8,48(sp)
    8000018a:	f466                	sd	s9,40(sp)
    8000018c:	f06a                	sd	s10,32(sp)
    8000018e:	ec6e                	sd	s11,24(sp)
    80000190:	0100                	addi	s0,sp,128
    80000192:	8caa                	mv	s9,a0
    80000194:	8aae                	mv	s5,a1
    80000196:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000198:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000019c:	00011517          	auipc	a0,0x11
    800001a0:	fd450513          	addi	a0,a0,-44 # 80011170 <cons>
    800001a4:	00001097          	auipc	ra,0x1
    800001a8:	ac2080e7          	jalr	-1342(ra) # 80000c66 <acquire>
  while(n > 0){
    800001ac:	09405663          	blez	s4,80000238 <consoleread+0xc4>
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001b0:	00011497          	auipc	s1,0x11
    800001b4:	fc048493          	addi	s1,s1,-64 # 80011170 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b8:	89a6                	mv	s3,s1
    800001ba:	00011917          	auipc	s2,0x11
    800001be:	04e90913          	addi	s2,s2,78 # 80011208 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001c2:	4c11                	li	s8,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c4:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001c6:	4da9                	li	s11,10
    while(cons.r == cons.w){
    800001c8:	0984a783          	lw	a5,152(s1)
    800001cc:	09c4a703          	lw	a4,156(s1)
    800001d0:	02f71463          	bne	a4,a5,800001f8 <consoleread+0x84>
      if(myproc()->killed){
    800001d4:	00002097          	auipc	ra,0x2
    800001d8:	82a080e7          	jalr	-2006(ra) # 800019fe <myproc>
    800001dc:	591c                	lw	a5,48(a0)
    800001de:	eba5                	bnez	a5,8000024e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001e0:	85ce                	mv	a1,s3
    800001e2:	854a                	mv	a0,s2
    800001e4:	00002097          	auipc	ra,0x2
    800001e8:	034080e7          	jalr	52(ra) # 80002218 <sleep>
    while(cons.r == cons.w){
    800001ec:	0984a783          	lw	a5,152(s1)
    800001f0:	09c4a703          	lw	a4,156(s1)
    800001f4:	fef700e3          	beq	a4,a5,800001d4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f8:	0017871b          	addiw	a4,a5,1
    800001fc:	08e4ac23          	sw	a4,152(s1)
    80000200:	07f7f713          	andi	a4,a5,127
    80000204:	9726                	add	a4,a4,s1
    80000206:	01874703          	lbu	a4,24(a4)
    8000020a:	00070b9b          	sext.w	s7,a4
    if(c == C('D')){  // end-of-file
    8000020e:	078b8863          	beq	s7,s8,8000027e <consoleread+0x10a>
    cbuf = c;
    80000212:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000216:	4685                	li	a3,1
    80000218:	f8f40613          	addi	a2,s0,-113
    8000021c:	85d6                	mv	a1,s5
    8000021e:	8566                	mv	a0,s9
    80000220:	00002097          	auipc	ra,0x2
    80000224:	25a080e7          	jalr	602(ra) # 8000247a <either_copyout>
    80000228:	01a50863          	beq	a0,s10,80000238 <consoleread+0xc4>
    dst++;
    8000022c:	0a85                	addi	s5,s5,1
    --n;
    8000022e:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000230:	01bb8463          	beq	s7,s11,80000238 <consoleread+0xc4>
  while(n > 0){
    80000234:	f80a1ae3          	bnez	s4,800001c8 <consoleread+0x54>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000238:	00011517          	auipc	a0,0x11
    8000023c:	f3850513          	addi	a0,a0,-200 # 80011170 <cons>
    80000240:	00001097          	auipc	ra,0x1
    80000244:	ada080e7          	jalr	-1318(ra) # 80000d1a <release>

  return target - n;
    80000248:	414b053b          	subw	a0,s6,s4
    8000024c:	a811                	j	80000260 <consoleread+0xec>
        release(&cons.lock);
    8000024e:	00011517          	auipc	a0,0x11
    80000252:	f2250513          	addi	a0,a0,-222 # 80011170 <cons>
    80000256:	00001097          	auipc	ra,0x1
    8000025a:	ac4080e7          	jalr	-1340(ra) # 80000d1a <release>
        return -1;
    8000025e:	557d                	li	a0,-1
}
    80000260:	70e6                	ld	ra,120(sp)
    80000262:	7446                	ld	s0,112(sp)
    80000264:	74a6                	ld	s1,104(sp)
    80000266:	7906                	ld	s2,96(sp)
    80000268:	69e6                	ld	s3,88(sp)
    8000026a:	6a46                	ld	s4,80(sp)
    8000026c:	6aa6                	ld	s5,72(sp)
    8000026e:	6b06                	ld	s6,64(sp)
    80000270:	7be2                	ld	s7,56(sp)
    80000272:	7c42                	ld	s8,48(sp)
    80000274:	7ca2                	ld	s9,40(sp)
    80000276:	7d02                	ld	s10,32(sp)
    80000278:	6de2                	ld	s11,24(sp)
    8000027a:	6109                	addi	sp,sp,128
    8000027c:	8082                	ret
      if(n < target){
    8000027e:	000a071b          	sext.w	a4,s4
    80000282:	fb677be3          	bleu	s6,a4,80000238 <consoleread+0xc4>
        cons.r--;
    80000286:	00011717          	auipc	a4,0x11
    8000028a:	f8f72123          	sw	a5,-126(a4) # 80011208 <cons+0x98>
    8000028e:	b76d                	j	80000238 <consoleread+0xc4>

0000000080000290 <consputc>:
{
    80000290:	1141                	addi	sp,sp,-16
    80000292:	e406                	sd	ra,8(sp)
    80000294:	e022                	sd	s0,0(sp)
    80000296:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000298:	10000793          	li	a5,256
    8000029c:	00f50a63          	beq	a0,a5,800002b0 <consputc+0x20>
    uartputc_sync(c);
    800002a0:	00000097          	auipc	ra,0x0
    800002a4:	58a080e7          	jalr	1418(ra) # 8000082a <uartputc_sync>
}
    800002a8:	60a2                	ld	ra,8(sp)
    800002aa:	6402                	ld	s0,0(sp)
    800002ac:	0141                	addi	sp,sp,16
    800002ae:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002b0:	4521                	li	a0,8
    800002b2:	00000097          	auipc	ra,0x0
    800002b6:	578080e7          	jalr	1400(ra) # 8000082a <uartputc_sync>
    800002ba:	02000513          	li	a0,32
    800002be:	00000097          	auipc	ra,0x0
    800002c2:	56c080e7          	jalr	1388(ra) # 8000082a <uartputc_sync>
    800002c6:	4521                	li	a0,8
    800002c8:	00000097          	auipc	ra,0x0
    800002cc:	562080e7          	jalr	1378(ra) # 8000082a <uartputc_sync>
    800002d0:	bfe1                	j	800002a8 <consputc+0x18>

00000000800002d2 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d2:	1101                	addi	sp,sp,-32
    800002d4:	ec06                	sd	ra,24(sp)
    800002d6:	e822                	sd	s0,16(sp)
    800002d8:	e426                	sd	s1,8(sp)
    800002da:	e04a                	sd	s2,0(sp)
    800002dc:	1000                	addi	s0,sp,32
    800002de:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002e0:	00011517          	auipc	a0,0x11
    800002e4:	e9050513          	addi	a0,a0,-368 # 80011170 <cons>
    800002e8:	00001097          	auipc	ra,0x1
    800002ec:	97e080e7          	jalr	-1666(ra) # 80000c66 <acquire>

  switch(c){
    800002f0:	47c1                	li	a5,16
    800002f2:	12f48463          	beq	s1,a5,8000041a <consoleintr+0x148>
    800002f6:	0297df63          	ble	s1,a5,80000334 <consoleintr+0x62>
    800002fa:	47d5                	li	a5,21
    800002fc:	0af48863          	beq	s1,a5,800003ac <consoleintr+0xda>
    80000300:	07f00793          	li	a5,127
    80000304:	02f49b63          	bne	s1,a5,8000033a <consoleintr+0x68>
      consputc(BACKSPACE);
    }
    break;
  case C('H'): // Backspace
  case '\x7f':
    if(cons.e != cons.w){
    80000308:	00011717          	auipc	a4,0x11
    8000030c:	e6870713          	addi	a4,a4,-408 # 80011170 <cons>
    80000310:	0a072783          	lw	a5,160(a4)
    80000314:	09c72703          	lw	a4,156(a4)
    80000318:	10f70563          	beq	a4,a5,80000422 <consoleintr+0x150>
      cons.e--;
    8000031c:	37fd                	addiw	a5,a5,-1
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	eef72923          	sw	a5,-270(a4) # 80011210 <cons+0xa0>
      consputc(BACKSPACE);
    80000326:	10000513          	li	a0,256
    8000032a:	00000097          	auipc	ra,0x0
    8000032e:	f66080e7          	jalr	-154(ra) # 80000290 <consputc>
    80000332:	a8c5                	j	80000422 <consoleintr+0x150>
  switch(c){
    80000334:	47a1                	li	a5,8
    80000336:	fcf489e3          	beq	s1,a5,80000308 <consoleintr+0x36>
    }
    break;
  default:
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000033a:	c4e5                	beqz	s1,80000422 <consoleintr+0x150>
    8000033c:	00011717          	auipc	a4,0x11
    80000340:	e3470713          	addi	a4,a4,-460 # 80011170 <cons>
    80000344:	0a072783          	lw	a5,160(a4)
    80000348:	09872703          	lw	a4,152(a4)
    8000034c:	9f99                	subw	a5,a5,a4
    8000034e:	07f00713          	li	a4,127
    80000352:	0cf76863          	bltu	a4,a5,80000422 <consoleintr+0x150>
      c = (c == '\r') ? '\n' : c;
    80000356:	47b5                	li	a5,13
    80000358:	0ef48363          	beq	s1,a5,8000043e <consoleintr+0x16c>

      // echo back to the user.
      consputc(c);
    8000035c:	8526                	mv	a0,s1
    8000035e:	00000097          	auipc	ra,0x0
    80000362:	f32080e7          	jalr	-206(ra) # 80000290 <consputc>

      // store for consumption by consoleread().
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000366:	00011797          	auipc	a5,0x11
    8000036a:	e0a78793          	addi	a5,a5,-502 # 80011170 <cons>
    8000036e:	0a07a703          	lw	a4,160(a5)
    80000372:	0017069b          	addiw	a3,a4,1
    80000376:	0006861b          	sext.w	a2,a3
    8000037a:	0ad7a023          	sw	a3,160(a5)
    8000037e:	07f77713          	andi	a4,a4,127
    80000382:	97ba                	add	a5,a5,a4
    80000384:	00978c23          	sb	s1,24(a5)

      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000388:	47a9                	li	a5,10
    8000038a:	0ef48163          	beq	s1,a5,8000046c <consoleintr+0x19a>
    8000038e:	4791                	li	a5,4
    80000390:	0cf48e63          	beq	s1,a5,8000046c <consoleintr+0x19a>
    80000394:	00011797          	auipc	a5,0x11
    80000398:	ddc78793          	addi	a5,a5,-548 # 80011170 <cons>
    8000039c:	0987a783          	lw	a5,152(a5)
    800003a0:	0807879b          	addiw	a5,a5,128
    800003a4:	06f61f63          	bne	a2,a5,80000422 <consoleintr+0x150>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003a8:	863e                	mv	a2,a5
    800003aa:	a0c9                	j	8000046c <consoleintr+0x19a>
    while(cons.e != cons.w &&
    800003ac:	00011717          	auipc	a4,0x11
    800003b0:	dc470713          	addi	a4,a4,-572 # 80011170 <cons>
    800003b4:	0a072783          	lw	a5,160(a4)
    800003b8:	09c72703          	lw	a4,156(a4)
    800003bc:	06f70363          	beq	a4,a5,80000422 <consoleintr+0x150>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003c0:	37fd                	addiw	a5,a5,-1
    800003c2:	0007871b          	sext.w	a4,a5
    800003c6:	07f7f793          	andi	a5,a5,127
    800003ca:	00011697          	auipc	a3,0x11
    800003ce:	da668693          	addi	a3,a3,-602 # 80011170 <cons>
    800003d2:	97b6                	add	a5,a5,a3
    while(cons.e != cons.w &&
    800003d4:	0187c683          	lbu	a3,24(a5)
    800003d8:	47a9                	li	a5,10
      cons.e--;
    800003da:	00011497          	auipc	s1,0x11
    800003de:	d9648493          	addi	s1,s1,-618 # 80011170 <cons>
    while(cons.e != cons.w &&
    800003e2:	4929                	li	s2,10
    800003e4:	02f68f63          	beq	a3,a5,80000422 <consoleintr+0x150>
      cons.e--;
    800003e8:	0ae4a023          	sw	a4,160(s1)
      consputc(BACKSPACE);
    800003ec:	10000513          	li	a0,256
    800003f0:	00000097          	auipc	ra,0x0
    800003f4:	ea0080e7          	jalr	-352(ra) # 80000290 <consputc>
    while(cons.e != cons.w &&
    800003f8:	0a04a783          	lw	a5,160(s1)
    800003fc:	09c4a703          	lw	a4,156(s1)
    80000400:	02f70163          	beq	a4,a5,80000422 <consoleintr+0x150>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000404:	37fd                	addiw	a5,a5,-1
    80000406:	0007871b          	sext.w	a4,a5
    8000040a:	07f7f793          	andi	a5,a5,127
    8000040e:	97a6                	add	a5,a5,s1
    while(cons.e != cons.w &&
    80000410:	0187c783          	lbu	a5,24(a5)
    80000414:	fd279ae3          	bne	a5,s2,800003e8 <consoleintr+0x116>
    80000418:	a029                	j	80000422 <consoleintr+0x150>
    procdump();
    8000041a:	00002097          	auipc	ra,0x2
    8000041e:	10c080e7          	jalr	268(ra) # 80002526 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000422:	00011517          	auipc	a0,0x11
    80000426:	d4e50513          	addi	a0,a0,-690 # 80011170 <cons>
    8000042a:	00001097          	auipc	ra,0x1
    8000042e:	8f0080e7          	jalr	-1808(ra) # 80000d1a <release>
}
    80000432:	60e2                	ld	ra,24(sp)
    80000434:	6442                	ld	s0,16(sp)
    80000436:	64a2                	ld	s1,8(sp)
    80000438:	6902                	ld	s2,0(sp)
    8000043a:	6105                	addi	sp,sp,32
    8000043c:	8082                	ret
      consputc(c);
    8000043e:	4529                	li	a0,10
    80000440:	00000097          	auipc	ra,0x0
    80000444:	e50080e7          	jalr	-432(ra) # 80000290 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000448:	00011797          	auipc	a5,0x11
    8000044c:	d2878793          	addi	a5,a5,-728 # 80011170 <cons>
    80000450:	0a07a703          	lw	a4,160(a5)
    80000454:	0017069b          	addiw	a3,a4,1
    80000458:	0006861b          	sext.w	a2,a3
    8000045c:	0ad7a023          	sw	a3,160(a5)
    80000460:	07f77713          	andi	a4,a4,127
    80000464:	97ba                	add	a5,a5,a4
    80000466:	4729                	li	a4,10
    80000468:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000046c:	00011797          	auipc	a5,0x11
    80000470:	dac7a023          	sw	a2,-608(a5) # 8001120c <cons+0x9c>
        wakeup(&cons.r);
    80000474:	00011517          	auipc	a0,0x11
    80000478:	d9450513          	addi	a0,a0,-620 # 80011208 <cons+0x98>
    8000047c:	00002097          	auipc	ra,0x2
    80000480:	f22080e7          	jalr	-222(ra) # 8000239e <wakeup>
    80000484:	bf79                	j	80000422 <consoleintr+0x150>

0000000080000486 <consoleinit>:

void
consoleinit(void)
{
    80000486:	1141                	addi	sp,sp,-16
    80000488:	e406                	sd	ra,8(sp)
    8000048a:	e022                	sd	s0,0(sp)
    8000048c:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000048e:	00008597          	auipc	a1,0x8
    80000492:	b8258593          	addi	a1,a1,-1150 # 80008010 <etext+0x10>
    80000496:	00011517          	auipc	a0,0x11
    8000049a:	cda50513          	addi	a0,a0,-806 # 80011170 <cons>
    8000049e:	00000097          	auipc	ra,0x0
    800004a2:	738080e7          	jalr	1848(ra) # 80000bd6 <initlock>

  uartinit();
    800004a6:	00000097          	auipc	ra,0x0
    800004aa:	334080e7          	jalr	820(ra) # 800007da <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004ae:	00021797          	auipc	a5,0x21
    800004b2:	e4278793          	addi	a5,a5,-446 # 800212f0 <devsw>
    800004b6:	00000717          	auipc	a4,0x0
    800004ba:	cbe70713          	addi	a4,a4,-834 # 80000174 <consoleread>
    800004be:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004c0:	00000717          	auipc	a4,0x0
    800004c4:	c3270713          	addi	a4,a4,-974 # 800000f2 <consolewrite>
    800004c8:	ef98                	sd	a4,24(a5)
}
    800004ca:	60a2                	ld	ra,8(sp)
    800004cc:	6402                	ld	s0,0(sp)
    800004ce:	0141                	addi	sp,sp,16
    800004d0:	8082                	ret

00000000800004d2 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004d2:	7179                	addi	sp,sp,-48
    800004d4:	f406                	sd	ra,40(sp)
    800004d6:	f022                	sd	s0,32(sp)
    800004d8:	ec26                	sd	s1,24(sp)
    800004da:	e84a                	sd	s2,16(sp)
    800004dc:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004de:	c219                	beqz	a2,800004e4 <printint+0x12>
    800004e0:	00054d63          	bltz	a0,800004fa <printint+0x28>
    x = -xx;
  else
    x = xx;
    800004e4:	2501                	sext.w	a0,a0
    800004e6:	4881                	li	a7,0
    800004e8:	fd040713          	addi	a4,s0,-48

  i = 0;
    800004ec:	4601                	li	a2,0
  do {
    buf[i++] = digits[x % base];
    800004ee:	2581                	sext.w	a1,a1
    800004f0:	00008817          	auipc	a6,0x8
    800004f4:	b2880813          	addi	a6,a6,-1240 # 80008018 <digits>
    800004f8:	a801                	j	80000508 <printint+0x36>
    x = -xx;
    800004fa:	40a0053b          	negw	a0,a0
    800004fe:	2501                	sext.w	a0,a0
  if(sign && (sign = xx < 0))
    80000500:	4885                	li	a7,1
    x = -xx;
    80000502:	b7dd                	j	800004e8 <printint+0x16>
  } while((x /= base) != 0);
    80000504:	853e                	mv	a0,a5
    buf[i++] = digits[x % base];
    80000506:	8636                	mv	a2,a3
    80000508:	0016069b          	addiw	a3,a2,1
    8000050c:	02b577bb          	remuw	a5,a0,a1
    80000510:	1782                	slli	a5,a5,0x20
    80000512:	9381                	srli	a5,a5,0x20
    80000514:	97c2                	add	a5,a5,a6
    80000516:	0007c783          	lbu	a5,0(a5)
    8000051a:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    8000051e:	0705                	addi	a4,a4,1
    80000520:	02b557bb          	divuw	a5,a0,a1
    80000524:	feb570e3          	bleu	a1,a0,80000504 <printint+0x32>

  if(sign)
    80000528:	00088b63          	beqz	a7,8000053e <printint+0x6c>
    buf[i++] = '-';
    8000052c:	fe040793          	addi	a5,s0,-32
    80000530:	96be                	add	a3,a3,a5
    80000532:	02d00793          	li	a5,45
    80000536:	fef68823          	sb	a5,-16(a3)
    8000053a:	0026069b          	addiw	a3,a2,2

  while(--i >= 0)
    8000053e:	02d05763          	blez	a3,8000056c <printint+0x9a>
    80000542:	fd040793          	addi	a5,s0,-48
    80000546:	00d784b3          	add	s1,a5,a3
    8000054a:	fff78913          	addi	s2,a5,-1
    8000054e:	9936                	add	s2,s2,a3
    80000550:	36fd                	addiw	a3,a3,-1
    80000552:	1682                	slli	a3,a3,0x20
    80000554:	9281                	srli	a3,a3,0x20
    80000556:	40d90933          	sub	s2,s2,a3
    consputc(buf[i]);
    8000055a:	fff4c503          	lbu	a0,-1(s1)
    8000055e:	00000097          	auipc	ra,0x0
    80000562:	d32080e7          	jalr	-718(ra) # 80000290 <consputc>
  while(--i >= 0)
    80000566:	14fd                	addi	s1,s1,-1
    80000568:	ff2499e3          	bne	s1,s2,8000055a <printint+0x88>
}
    8000056c:	70a2                	ld	ra,40(sp)
    8000056e:	7402                	ld	s0,32(sp)
    80000570:	64e2                	ld	s1,24(sp)
    80000572:	6942                	ld	s2,16(sp)
    80000574:	6145                	addi	sp,sp,48
    80000576:	8082                	ret

0000000080000578 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000578:	1101                	addi	sp,sp,-32
    8000057a:	ec06                	sd	ra,24(sp)
    8000057c:	e822                	sd	s0,16(sp)
    8000057e:	e426                	sd	s1,8(sp)
    80000580:	1000                	addi	s0,sp,32
    80000582:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000584:	00011797          	auipc	a5,0x11
    80000588:	ca07a623          	sw	zero,-852(a5) # 80011230 <pr+0x18>
  printf("panic: ");
    8000058c:	00008517          	auipc	a0,0x8
    80000590:	aa450513          	addi	a0,a0,-1372 # 80008030 <digits+0x18>
    80000594:	00000097          	auipc	ra,0x0
    80000598:	02e080e7          	jalr	46(ra) # 800005c2 <printf>
  printf(s);
    8000059c:	8526                	mv	a0,s1
    8000059e:	00000097          	auipc	ra,0x0
    800005a2:	024080e7          	jalr	36(ra) # 800005c2 <printf>
  printf("\n");
    800005a6:	00008517          	auipc	a0,0x8
    800005aa:	b2250513          	addi	a0,a0,-1246 # 800080c8 <digits+0xb0>
    800005ae:	00000097          	auipc	ra,0x0
    800005b2:	014080e7          	jalr	20(ra) # 800005c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800005b6:	4785                	li	a5,1
    800005b8:	00009717          	auipc	a4,0x9
    800005bc:	a4f72423          	sw	a5,-1464(a4) # 80009000 <panicked>
  for(;;)
    800005c0:	a001                	j	800005c0 <panic+0x48>

00000000800005c2 <printf>:
{
    800005c2:	7131                	addi	sp,sp,-192
    800005c4:	fc86                	sd	ra,120(sp)
    800005c6:	f8a2                	sd	s0,112(sp)
    800005c8:	f4a6                	sd	s1,104(sp)
    800005ca:	f0ca                	sd	s2,96(sp)
    800005cc:	ecce                	sd	s3,88(sp)
    800005ce:	e8d2                	sd	s4,80(sp)
    800005d0:	e4d6                	sd	s5,72(sp)
    800005d2:	e0da                	sd	s6,64(sp)
    800005d4:	fc5e                	sd	s7,56(sp)
    800005d6:	f862                	sd	s8,48(sp)
    800005d8:	f466                	sd	s9,40(sp)
    800005da:	f06a                	sd	s10,32(sp)
    800005dc:	ec6e                	sd	s11,24(sp)
    800005de:	0100                	addi	s0,sp,128
    800005e0:	8aaa                	mv	s5,a0
    800005e2:	e40c                	sd	a1,8(s0)
    800005e4:	e810                	sd	a2,16(s0)
    800005e6:	ec14                	sd	a3,24(s0)
    800005e8:	f018                	sd	a4,32(s0)
    800005ea:	f41c                	sd	a5,40(s0)
    800005ec:	03043823          	sd	a6,48(s0)
    800005f0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005f4:	00011797          	auipc	a5,0x11
    800005f8:	c2478793          	addi	a5,a5,-988 # 80011218 <pr>
    800005fc:	0187ad83          	lw	s11,24(a5)
  if(locking)
    80000600:	020d9b63          	bnez	s11,80000636 <printf+0x74>
  if (fmt == 0)
    80000604:	020a8f63          	beqz	s5,80000642 <printf+0x80>
  va_start(ap, fmt);
    80000608:	00840793          	addi	a5,s0,8
    8000060c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000610:	000ac503          	lbu	a0,0(s5)
    80000614:	16050063          	beqz	a0,80000774 <printf+0x1b2>
    80000618:	4481                	li	s1,0
    if(c != '%'){
    8000061a:	02500a13          	li	s4,37
    switch(c){
    8000061e:	07000b13          	li	s6,112
  consputc('x');
    80000622:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000624:	00008b97          	auipc	s7,0x8
    80000628:	9f4b8b93          	addi	s7,s7,-1548 # 80008018 <digits>
    switch(c){
    8000062c:	07300c93          	li	s9,115
    80000630:	06400c13          	li	s8,100
    80000634:	a815                	j	80000668 <printf+0xa6>
    acquire(&pr.lock);
    80000636:	853e                	mv	a0,a5
    80000638:	00000097          	auipc	ra,0x0
    8000063c:	62e080e7          	jalr	1582(ra) # 80000c66 <acquire>
    80000640:	b7d1                	j	80000604 <printf+0x42>
    panic("null fmt");
    80000642:	00008517          	auipc	a0,0x8
    80000646:	9fe50513          	addi	a0,a0,-1538 # 80008040 <digits+0x28>
    8000064a:	00000097          	auipc	ra,0x0
    8000064e:	f2e080e7          	jalr	-210(ra) # 80000578 <panic>
      consputc(c);
    80000652:	00000097          	auipc	ra,0x0
    80000656:	c3e080e7          	jalr	-962(ra) # 80000290 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000065a:	2485                	addiw	s1,s1,1
    8000065c:	009a87b3          	add	a5,s5,s1
    80000660:	0007c503          	lbu	a0,0(a5)
    80000664:	10050863          	beqz	a0,80000774 <printf+0x1b2>
    if(c != '%'){
    80000668:	ff4515e3          	bne	a0,s4,80000652 <printf+0x90>
    c = fmt[++i] & 0xff;
    8000066c:	2485                	addiw	s1,s1,1
    8000066e:	009a87b3          	add	a5,s5,s1
    80000672:	0007c783          	lbu	a5,0(a5)
    80000676:	0007891b          	sext.w	s2,a5
    if(c == 0)
    8000067a:	0e090d63          	beqz	s2,80000774 <printf+0x1b2>
    switch(c){
    8000067e:	05678a63          	beq	a5,s6,800006d2 <printf+0x110>
    80000682:	02fb7663          	bleu	a5,s6,800006ae <printf+0xec>
    80000686:	09978963          	beq	a5,s9,80000718 <printf+0x156>
    8000068a:	07800713          	li	a4,120
    8000068e:	0ce79863          	bne	a5,a4,8000075e <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	4605                	li	a2,1
    800006a0:	85ea                	mv	a1,s10
    800006a2:	4388                	lw	a0,0(a5)
    800006a4:	00000097          	auipc	ra,0x0
    800006a8:	e2e080e7          	jalr	-466(ra) # 800004d2 <printint>
      break;
    800006ac:	b77d                	j	8000065a <printf+0x98>
    switch(c){
    800006ae:	0b478263          	beq	a5,s4,80000752 <printf+0x190>
    800006b2:	0b879663          	bne	a5,s8,8000075e <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    800006b6:	f8843783          	ld	a5,-120(s0)
    800006ba:	00878713          	addi	a4,a5,8
    800006be:	f8e43423          	sd	a4,-120(s0)
    800006c2:	4605                	li	a2,1
    800006c4:	45a9                	li	a1,10
    800006c6:	4388                	lw	a0,0(a5)
    800006c8:	00000097          	auipc	ra,0x0
    800006cc:	e0a080e7          	jalr	-502(ra) # 800004d2 <printint>
      break;
    800006d0:	b769                	j	8000065a <printf+0x98>
      printptr(va_arg(ap, uint64));
    800006d2:	f8843783          	ld	a5,-120(s0)
    800006d6:	00878713          	addi	a4,a5,8
    800006da:	f8e43423          	sd	a4,-120(s0)
    800006de:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006e2:	03000513          	li	a0,48
    800006e6:	00000097          	auipc	ra,0x0
    800006ea:	baa080e7          	jalr	-1110(ra) # 80000290 <consputc>
  consputc('x');
    800006ee:	07800513          	li	a0,120
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b9e080e7          	jalr	-1122(ra) # 80000290 <consputc>
    800006fa:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006fc:	03c9d793          	srli	a5,s3,0x3c
    80000700:	97de                	add	a5,a5,s7
    80000702:	0007c503          	lbu	a0,0(a5)
    80000706:	00000097          	auipc	ra,0x0
    8000070a:	b8a080e7          	jalr	-1142(ra) # 80000290 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070e:	0992                	slli	s3,s3,0x4
    80000710:	397d                	addiw	s2,s2,-1
    80000712:	fe0915e3          	bnez	s2,800006fc <printf+0x13a>
    80000716:	b791                	j	8000065a <printf+0x98>
      if((s = va_arg(ap, char*)) == 0)
    80000718:	f8843783          	ld	a5,-120(s0)
    8000071c:	00878713          	addi	a4,a5,8
    80000720:	f8e43423          	sd	a4,-120(s0)
    80000724:	0007b903          	ld	s2,0(a5)
    80000728:	00090e63          	beqz	s2,80000744 <printf+0x182>
      for(; *s; s++)
    8000072c:	00094503          	lbu	a0,0(s2)
    80000730:	d50d                	beqz	a0,8000065a <printf+0x98>
        consputc(*s);
    80000732:	00000097          	auipc	ra,0x0
    80000736:	b5e080e7          	jalr	-1186(ra) # 80000290 <consputc>
      for(; *s; s++)
    8000073a:	0905                	addi	s2,s2,1
    8000073c:	00094503          	lbu	a0,0(s2)
    80000740:	f96d                	bnez	a0,80000732 <printf+0x170>
    80000742:	bf21                	j	8000065a <printf+0x98>
        s = "(null)";
    80000744:	00008917          	auipc	s2,0x8
    80000748:	8f490913          	addi	s2,s2,-1804 # 80008038 <digits+0x20>
      for(; *s; s++)
    8000074c:	02800513          	li	a0,40
    80000750:	b7cd                	j	80000732 <printf+0x170>
      consputc('%');
    80000752:	8552                	mv	a0,s4
    80000754:	00000097          	auipc	ra,0x0
    80000758:	b3c080e7          	jalr	-1220(ra) # 80000290 <consputc>
      break;
    8000075c:	bdfd                	j	8000065a <printf+0x98>
      consputc('%');
    8000075e:	8552                	mv	a0,s4
    80000760:	00000097          	auipc	ra,0x0
    80000764:	b30080e7          	jalr	-1232(ra) # 80000290 <consputc>
      consputc(c);
    80000768:	854a                	mv	a0,s2
    8000076a:	00000097          	auipc	ra,0x0
    8000076e:	b26080e7          	jalr	-1242(ra) # 80000290 <consputc>
      break;
    80000772:	b5e5                	j	8000065a <printf+0x98>
  if(locking)
    80000774:	020d9163          	bnez	s11,80000796 <printf+0x1d4>
}
    80000778:	70e6                	ld	ra,120(sp)
    8000077a:	7446                	ld	s0,112(sp)
    8000077c:	74a6                	ld	s1,104(sp)
    8000077e:	7906                	ld	s2,96(sp)
    80000780:	69e6                	ld	s3,88(sp)
    80000782:	6a46                	ld	s4,80(sp)
    80000784:	6aa6                	ld	s5,72(sp)
    80000786:	6b06                	ld	s6,64(sp)
    80000788:	7be2                	ld	s7,56(sp)
    8000078a:	7c42                	ld	s8,48(sp)
    8000078c:	7ca2                	ld	s9,40(sp)
    8000078e:	7d02                	ld	s10,32(sp)
    80000790:	6de2                	ld	s11,24(sp)
    80000792:	6129                	addi	sp,sp,192
    80000794:	8082                	ret
    release(&pr.lock);
    80000796:	00011517          	auipc	a0,0x11
    8000079a:	a8250513          	addi	a0,a0,-1406 # 80011218 <pr>
    8000079e:	00000097          	auipc	ra,0x0
    800007a2:	57c080e7          	jalr	1404(ra) # 80000d1a <release>
}
    800007a6:	bfc9                	j	80000778 <printf+0x1b6>

00000000800007a8 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007a8:	1101                	addi	sp,sp,-32
    800007aa:	ec06                	sd	ra,24(sp)
    800007ac:	e822                	sd	s0,16(sp)
    800007ae:	e426                	sd	s1,8(sp)
    800007b0:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007b2:	00011497          	auipc	s1,0x11
    800007b6:	a6648493          	addi	s1,s1,-1434 # 80011218 <pr>
    800007ba:	00008597          	auipc	a1,0x8
    800007be:	89658593          	addi	a1,a1,-1898 # 80008050 <digits+0x38>
    800007c2:	8526                	mv	a0,s1
    800007c4:	00000097          	auipc	ra,0x0
    800007c8:	412080e7          	jalr	1042(ra) # 80000bd6 <initlock>
  pr.locking = 1;
    800007cc:	4785                	li	a5,1
    800007ce:	cc9c                	sw	a5,24(s1)
}
    800007d0:	60e2                	ld	ra,24(sp)
    800007d2:	6442                	ld	s0,16(sp)
    800007d4:	64a2                	ld	s1,8(sp)
    800007d6:	6105                	addi	sp,sp,32
    800007d8:	8082                	ret

00000000800007da <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007da:	1141                	addi	sp,sp,-16
    800007dc:	e406                	sd	ra,8(sp)
    800007de:	e022                	sd	s0,0(sp)
    800007e0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007e2:	100007b7          	lui	a5,0x10000
    800007e6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ea:	f8000713          	li	a4,-128
    800007ee:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007f2:	470d                	li	a4,3
    800007f4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007f8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007fc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000800:	469d                	li	a3,7
    80000802:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000806:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000080a:	00008597          	auipc	a1,0x8
    8000080e:	84e58593          	addi	a1,a1,-1970 # 80008058 <digits+0x40>
    80000812:	00011517          	auipc	a0,0x11
    80000816:	a2650513          	addi	a0,a0,-1498 # 80011238 <uart_tx_lock>
    8000081a:	00000097          	auipc	ra,0x0
    8000081e:	3bc080e7          	jalr	956(ra) # 80000bd6 <initlock>
}
    80000822:	60a2                	ld	ra,8(sp)
    80000824:	6402                	ld	s0,0(sp)
    80000826:	0141                	addi	sp,sp,16
    80000828:	8082                	ret

000000008000082a <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000082a:	1101                	addi	sp,sp,-32
    8000082c:	ec06                	sd	ra,24(sp)
    8000082e:	e822                	sd	s0,16(sp)
    80000830:	e426                	sd	s1,8(sp)
    80000832:	1000                	addi	s0,sp,32
    80000834:	84aa                	mv	s1,a0
  push_off();
    80000836:	00000097          	auipc	ra,0x0
    8000083a:	3e4080e7          	jalr	996(ra) # 80000c1a <push_off>

  if(panicked){
    8000083e:	00008797          	auipc	a5,0x8
    80000842:	7c278793          	addi	a5,a5,1986 # 80009000 <panicked>
    80000846:	439c                	lw	a5,0(a5)
    80000848:	2781                	sext.w	a5,a5
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000084a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000084e:	c391                	beqz	a5,80000852 <uartputc_sync+0x28>
    for(;;)
    80000850:	a001                	j	80000850 <uartputc_sync+0x26>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000852:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000856:	0ff7f793          	andi	a5,a5,255
    8000085a:	0207f793          	andi	a5,a5,32
    8000085e:	dbf5                	beqz	a5,80000852 <uartputc_sync+0x28>
    ;
  WriteReg(THR, c);
    80000860:	0ff4f793          	andi	a5,s1,255
    80000864:	10000737          	lui	a4,0x10000
    80000868:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000086c:	00000097          	auipc	ra,0x0
    80000870:	44e080e7          	jalr	1102(ra) # 80000cba <pop_off>
}
    80000874:	60e2                	ld	ra,24(sp)
    80000876:	6442                	ld	s0,16(sp)
    80000878:	64a2                	ld	s1,8(sp)
    8000087a:	6105                	addi	sp,sp,32
    8000087c:	8082                	ret

000000008000087e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000087e:	00008797          	auipc	a5,0x8
    80000882:	78678793          	addi	a5,a5,1926 # 80009004 <uart_tx_r>
    80000886:	439c                	lw	a5,0(a5)
    80000888:	00008717          	auipc	a4,0x8
    8000088c:	78070713          	addi	a4,a4,1920 # 80009008 <uart_tx_w>
    80000890:	4318                	lw	a4,0(a4)
    80000892:	08f70b63          	beq	a4,a5,80000928 <uartstart+0xaa>
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000896:	10000737          	lui	a4,0x10000
    8000089a:	00574703          	lbu	a4,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000089e:	0ff77713          	andi	a4,a4,255
    800008a2:	02077713          	andi	a4,a4,32
    800008a6:	c349                	beqz	a4,80000928 <uartstart+0xaa>
{
    800008a8:	7139                	addi	sp,sp,-64
    800008aa:	fc06                	sd	ra,56(sp)
    800008ac:	f822                	sd	s0,48(sp)
    800008ae:	f426                	sd	s1,40(sp)
    800008b0:	f04a                	sd	s2,32(sp)
    800008b2:	ec4e                	sd	s3,24(sp)
    800008b4:	e852                	sd	s4,16(sp)
    800008b6:	e456                	sd	s5,8(sp)
    800008b8:	0080                	addi	s0,sp,64
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    800008ba:	00011a17          	auipc	s4,0x11
    800008be:	97ea0a13          	addi	s4,s4,-1666 # 80011238 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008c2:	00008497          	auipc	s1,0x8
    800008c6:	74248493          	addi	s1,s1,1858 # 80009004 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008ca:	10000937          	lui	s2,0x10000
    if(uart_tx_w == uart_tx_r){
    800008ce:	00008997          	auipc	s3,0x8
    800008d2:	73a98993          	addi	s3,s3,1850 # 80009008 <uart_tx_w>
    int c = uart_tx_buf[uart_tx_r];
    800008d6:	00fa0733          	add	a4,s4,a5
    800008da:	01874a83          	lbu	s5,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008de:	2785                	addiw	a5,a5,1
    800008e0:	41f7d71b          	sraiw	a4,a5,0x1f
    800008e4:	01b7571b          	srliw	a4,a4,0x1b
    800008e8:	9fb9                	addw	a5,a5,a4
    800008ea:	8bfd                	andi	a5,a5,31
    800008ec:	9f99                	subw	a5,a5,a4
    800008ee:	c09c                	sw	a5,0(s1)
    wakeup(&uart_tx_r);
    800008f0:	8526                	mv	a0,s1
    800008f2:	00002097          	auipc	ra,0x2
    800008f6:	aac080e7          	jalr	-1364(ra) # 8000239e <wakeup>
    WriteReg(THR, c);
    800008fa:	01590023          	sb	s5,0(s2) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fe:	409c                	lw	a5,0(s1)
    80000900:	0009a703          	lw	a4,0(s3)
    80000904:	00f70963          	beq	a4,a5,80000916 <uartstart+0x98>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000908:	00594703          	lbu	a4,5(s2)
    8000090c:	0ff77713          	andi	a4,a4,255
    80000910:	02077713          	andi	a4,a4,32
    80000914:	f369                	bnez	a4,800008d6 <uartstart+0x58>
  }
}
    80000916:	70e2                	ld	ra,56(sp)
    80000918:	7442                	ld	s0,48(sp)
    8000091a:	74a2                	ld	s1,40(sp)
    8000091c:	7902                	ld	s2,32(sp)
    8000091e:	69e2                	ld	s3,24(sp)
    80000920:	6a42                	ld	s4,16(sp)
    80000922:	6aa2                	ld	s5,8(sp)
    80000924:	6121                	addi	sp,sp,64
    80000926:	8082                	ret
    80000928:	8082                	ret

000000008000092a <uartputc>:
{
    8000092a:	7179                	addi	sp,sp,-48
    8000092c:	f406                	sd	ra,40(sp)
    8000092e:	f022                	sd	s0,32(sp)
    80000930:	ec26                	sd	s1,24(sp)
    80000932:	e84a                	sd	s2,16(sp)
    80000934:	e44e                	sd	s3,8(sp)
    80000936:	e052                	sd	s4,0(sp)
    80000938:	1800                	addi	s0,sp,48
    8000093a:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    8000093c:	00011517          	auipc	a0,0x11
    80000940:	8fc50513          	addi	a0,a0,-1796 # 80011238 <uart_tx_lock>
    80000944:	00000097          	auipc	ra,0x0
    80000948:	322080e7          	jalr	802(ra) # 80000c66 <acquire>
  if(panicked){
    8000094c:	00008797          	auipc	a5,0x8
    80000950:	6b478793          	addi	a5,a5,1716 # 80009000 <panicked>
    80000954:	439c                	lw	a5,0(a5)
    80000956:	2781                	sext.w	a5,a5
    80000958:	c391                	beqz	a5,8000095c <uartputc+0x32>
    for(;;)
    8000095a:	a001                	j	8000095a <uartputc+0x30>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000095c:	00008797          	auipc	a5,0x8
    80000960:	6ac78793          	addi	a5,a5,1708 # 80009008 <uart_tx_w>
    80000964:	4398                	lw	a4,0(a5)
    80000966:	0017079b          	addiw	a5,a4,1
    8000096a:	41f7d69b          	sraiw	a3,a5,0x1f
    8000096e:	01b6d69b          	srliw	a3,a3,0x1b
    80000972:	9fb5                	addw	a5,a5,a3
    80000974:	8bfd                	andi	a5,a5,31
    80000976:	9f95                	subw	a5,a5,a3
    80000978:	00008697          	auipc	a3,0x8
    8000097c:	68c68693          	addi	a3,a3,1676 # 80009004 <uart_tx_r>
    80000980:	4294                	lw	a3,0(a3)
    80000982:	04f69263          	bne	a3,a5,800009c6 <uartputc+0x9c>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000986:	00011a17          	auipc	s4,0x11
    8000098a:	8b2a0a13          	addi	s4,s4,-1870 # 80011238 <uart_tx_lock>
    8000098e:	00008497          	auipc	s1,0x8
    80000992:	67648493          	addi	s1,s1,1654 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000996:	00008917          	auipc	s2,0x8
    8000099a:	67290913          	addi	s2,s2,1650 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000099e:	85d2                	mv	a1,s4
    800009a0:	8526                	mv	a0,s1
    800009a2:	00002097          	auipc	ra,0x2
    800009a6:	876080e7          	jalr	-1930(ra) # 80002218 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800009aa:	00092703          	lw	a4,0(s2)
    800009ae:	0017079b          	addiw	a5,a4,1
    800009b2:	41f7d69b          	sraiw	a3,a5,0x1f
    800009b6:	01b6d69b          	srliw	a3,a3,0x1b
    800009ba:	9fb5                	addw	a5,a5,a3
    800009bc:	8bfd                	andi	a5,a5,31
    800009be:	9f95                	subw	a5,a5,a3
    800009c0:	4094                	lw	a3,0(s1)
    800009c2:	fcf68ee3          	beq	a3,a5,8000099e <uartputc+0x74>
      uart_tx_buf[uart_tx_w] = c;
    800009c6:	00011497          	auipc	s1,0x11
    800009ca:	87248493          	addi	s1,s1,-1934 # 80011238 <uart_tx_lock>
    800009ce:	9726                	add	a4,a4,s1
    800009d0:	01370c23          	sb	s3,24(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    800009d4:	00008717          	auipc	a4,0x8
    800009d8:	62f72a23          	sw	a5,1588(a4) # 80009008 <uart_tx_w>
      uartstart();
    800009dc:	00000097          	auipc	ra,0x0
    800009e0:	ea2080e7          	jalr	-350(ra) # 8000087e <uartstart>
      release(&uart_tx_lock);
    800009e4:	8526                	mv	a0,s1
    800009e6:	00000097          	auipc	ra,0x0
    800009ea:	334080e7          	jalr	820(ra) # 80000d1a <release>
}
    800009ee:	70a2                	ld	ra,40(sp)
    800009f0:	7402                	ld	s0,32(sp)
    800009f2:	64e2                	ld	s1,24(sp)
    800009f4:	6942                	ld	s2,16(sp)
    800009f6:	69a2                	ld	s3,8(sp)
    800009f8:	6a02                	ld	s4,0(sp)
    800009fa:	6145                	addi	sp,sp,48
    800009fc:	8082                	ret

00000000800009fe <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009fe:	1141                	addi	sp,sp,-16
    80000a00:	e422                	sd	s0,8(sp)
    80000a02:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000a04:	100007b7          	lui	a5,0x10000
    80000a08:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a0c:	8b85                	andi	a5,a5,1
    80000a0e:	cb91                	beqz	a5,80000a22 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000a10:	100007b7          	lui	a5,0x10000
    80000a14:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000a18:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000a1c:	6422                	ld	s0,8(sp)
    80000a1e:	0141                	addi	sp,sp,16
    80000a20:	8082                	ret
    return -1;
    80000a22:	557d                	li	a0,-1
    80000a24:	bfe5                	j	80000a1c <uartgetc+0x1e>

0000000080000a26 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000a26:	1101                	addi	sp,sp,-32
    80000a28:	ec06                	sd	ra,24(sp)
    80000a2a:	e822                	sd	s0,16(sp)
    80000a2c:	e426                	sd	s1,8(sp)
    80000a2e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a30:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a32:	00000097          	auipc	ra,0x0
    80000a36:	fcc080e7          	jalr	-52(ra) # 800009fe <uartgetc>
    if(c == -1)
    80000a3a:	00950763          	beq	a0,s1,80000a48 <uartintr+0x22>
      break;
    consoleintr(c);
    80000a3e:	00000097          	auipc	ra,0x0
    80000a42:	894080e7          	jalr	-1900(ra) # 800002d2 <consoleintr>
  while(1){
    80000a46:	b7f5                	j	80000a32 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a48:	00010497          	auipc	s1,0x10
    80000a4c:	7f048493          	addi	s1,s1,2032 # 80011238 <uart_tx_lock>
    80000a50:	8526                	mv	a0,s1
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	214080e7          	jalr	532(ra) # 80000c66 <acquire>
  uartstart();
    80000a5a:	00000097          	auipc	ra,0x0
    80000a5e:	e24080e7          	jalr	-476(ra) # 8000087e <uartstart>
  release(&uart_tx_lock);
    80000a62:	8526                	mv	a0,s1
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	2b6080e7          	jalr	694(ra) # 80000d1a <release>
}
    80000a6c:	60e2                	ld	ra,24(sp)
    80000a6e:	6442                	ld	s0,16(sp)
    80000a70:	64a2                	ld	s1,8(sp)
    80000a72:	6105                	addi	sp,sp,32
    80000a74:	8082                	ret

0000000080000a76 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a76:	1101                	addi	sp,sp,-32
    80000a78:	ec06                	sd	ra,24(sp)
    80000a7a:	e822                	sd	s0,16(sp)
    80000a7c:	e426                	sd	s1,8(sp)
    80000a7e:	e04a                	sd	s2,0(sp)
    80000a80:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a82:	6785                	lui	a5,0x1
    80000a84:	17fd                	addi	a5,a5,-1
    80000a86:	8fe9                	and	a5,a5,a0
    80000a88:	ebb9                	bnez	a5,80000ade <kfree+0x68>
    80000a8a:	84aa                	mv	s1,a0
    80000a8c:	00025797          	auipc	a5,0x25
    80000a90:	57478793          	addi	a5,a5,1396 # 80026000 <end>
    80000a94:	04f56563          	bltu	a0,a5,80000ade <kfree+0x68>
    80000a98:	47c5                	li	a5,17
    80000a9a:	07ee                	slli	a5,a5,0x1b
    80000a9c:	04f57163          	bleu	a5,a0,80000ade <kfree+0x68>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000aa0:	6605                	lui	a2,0x1
    80000aa2:	4585                	li	a1,1
    80000aa4:	00000097          	auipc	ra,0x0
    80000aa8:	2be080e7          	jalr	702(ra) # 80000d62 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000aac:	00010917          	auipc	s2,0x10
    80000ab0:	7c490913          	addi	s2,s2,1988 # 80011270 <kmem>
    80000ab4:	854a                	mv	a0,s2
    80000ab6:	00000097          	auipc	ra,0x0
    80000aba:	1b0080e7          	jalr	432(ra) # 80000c66 <acquire>
  r->next = kmem.freelist;
    80000abe:	01893783          	ld	a5,24(s2)
    80000ac2:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ac4:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000ac8:	854a                	mv	a0,s2
    80000aca:	00000097          	auipc	ra,0x0
    80000ace:	250080e7          	jalr	592(ra) # 80000d1a <release>
}
    80000ad2:	60e2                	ld	ra,24(sp)
    80000ad4:	6442                	ld	s0,16(sp)
    80000ad6:	64a2                	ld	s1,8(sp)
    80000ad8:	6902                	ld	s2,0(sp)
    80000ada:	6105                	addi	sp,sp,32
    80000adc:	8082                	ret
    panic("kfree");
    80000ade:	00007517          	auipc	a0,0x7
    80000ae2:	58250513          	addi	a0,a0,1410 # 80008060 <digits+0x48>
    80000ae6:	00000097          	auipc	ra,0x0
    80000aea:	a92080e7          	jalr	-1390(ra) # 80000578 <panic>

0000000080000aee <freerange>:
{
    80000aee:	7179                	addi	sp,sp,-48
    80000af0:	f406                	sd	ra,40(sp)
    80000af2:	f022                	sd	s0,32(sp)
    80000af4:	ec26                	sd	s1,24(sp)
    80000af6:	e84a                	sd	s2,16(sp)
    80000af8:	e44e                	sd	s3,8(sp)
    80000afa:	e052                	sd	s4,0(sp)
    80000afc:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000afe:	6705                	lui	a4,0x1
    80000b00:	fff70793          	addi	a5,a4,-1 # fff <_entry-0x7ffff001>
    80000b04:	00f504b3          	add	s1,a0,a5
    80000b08:	77fd                	lui	a5,0xfffff
    80000b0a:	8cfd                	and	s1,s1,a5
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b0c:	94ba                	add	s1,s1,a4
    80000b0e:	0095ee63          	bltu	a1,s1,80000b2a <freerange+0x3c>
    80000b12:	892e                	mv	s2,a1
    kfree(p);
    80000b14:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b16:	6985                	lui	s3,0x1
    kfree(p);
    80000b18:	01448533          	add	a0,s1,s4
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	f5a080e7          	jalr	-166(ra) # 80000a76 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b24:	94ce                	add	s1,s1,s3
    80000b26:	fe9979e3          	bleu	s1,s2,80000b18 <freerange+0x2a>
}
    80000b2a:	70a2                	ld	ra,40(sp)
    80000b2c:	7402                	ld	s0,32(sp)
    80000b2e:	64e2                	ld	s1,24(sp)
    80000b30:	6942                	ld	s2,16(sp)
    80000b32:	69a2                	ld	s3,8(sp)
    80000b34:	6a02                	ld	s4,0(sp)
    80000b36:	6145                	addi	sp,sp,48
    80000b38:	8082                	ret

0000000080000b3a <kinit>:
{
    80000b3a:	1141                	addi	sp,sp,-16
    80000b3c:	e406                	sd	ra,8(sp)
    80000b3e:	e022                	sd	s0,0(sp)
    80000b40:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b42:	00007597          	auipc	a1,0x7
    80000b46:	52658593          	addi	a1,a1,1318 # 80008068 <digits+0x50>
    80000b4a:	00010517          	auipc	a0,0x10
    80000b4e:	72650513          	addi	a0,a0,1830 # 80011270 <kmem>
    80000b52:	00000097          	auipc	ra,0x0
    80000b56:	084080e7          	jalr	132(ra) # 80000bd6 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b5a:	45c5                	li	a1,17
    80000b5c:	05ee                	slli	a1,a1,0x1b
    80000b5e:	00025517          	auipc	a0,0x25
    80000b62:	4a250513          	addi	a0,a0,1186 # 80026000 <end>
    80000b66:	00000097          	auipc	ra,0x0
    80000b6a:	f88080e7          	jalr	-120(ra) # 80000aee <freerange>
}
    80000b6e:	60a2                	ld	ra,8(sp)
    80000b70:	6402                	ld	s0,0(sp)
    80000b72:	0141                	addi	sp,sp,16
    80000b74:	8082                	ret

0000000080000b76 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b76:	1101                	addi	sp,sp,-32
    80000b78:	ec06                	sd	ra,24(sp)
    80000b7a:	e822                	sd	s0,16(sp)
    80000b7c:	e426                	sd	s1,8(sp)
    80000b7e:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b80:	00010497          	auipc	s1,0x10
    80000b84:	6f048493          	addi	s1,s1,1776 # 80011270 <kmem>
    80000b88:	8526                	mv	a0,s1
    80000b8a:	00000097          	auipc	ra,0x0
    80000b8e:	0dc080e7          	jalr	220(ra) # 80000c66 <acquire>
  r = kmem.freelist;
    80000b92:	6c84                	ld	s1,24(s1)
  if(r)
    80000b94:	c885                	beqz	s1,80000bc4 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b96:	609c                	ld	a5,0(s1)
    80000b98:	00010517          	auipc	a0,0x10
    80000b9c:	6d850513          	addi	a0,a0,1752 # 80011270 <kmem>
    80000ba0:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000ba2:	00000097          	auipc	ra,0x0
    80000ba6:	178080e7          	jalr	376(ra) # 80000d1a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000baa:	6605                	lui	a2,0x1
    80000bac:	4595                	li	a1,5
    80000bae:	8526                	mv	a0,s1
    80000bb0:	00000097          	auipc	ra,0x0
    80000bb4:	1b2080e7          	jalr	434(ra) # 80000d62 <memset>
  return (void*)r;
}
    80000bb8:	8526                	mv	a0,s1
    80000bba:	60e2                	ld	ra,24(sp)
    80000bbc:	6442                	ld	s0,16(sp)
    80000bbe:	64a2                	ld	s1,8(sp)
    80000bc0:	6105                	addi	sp,sp,32
    80000bc2:	8082                	ret
  release(&kmem.lock);
    80000bc4:	00010517          	auipc	a0,0x10
    80000bc8:	6ac50513          	addi	a0,a0,1708 # 80011270 <kmem>
    80000bcc:	00000097          	auipc	ra,0x0
    80000bd0:	14e080e7          	jalr	334(ra) # 80000d1a <release>
  if(r)
    80000bd4:	b7d5                	j	80000bb8 <kalloc+0x42>

0000000080000bd6 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bd6:	1141                	addi	sp,sp,-16
    80000bd8:	e422                	sd	s0,8(sp)
    80000bda:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bdc:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bde:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000be2:	00053823          	sd	zero,16(a0)
}
    80000be6:	6422                	ld	s0,8(sp)
    80000be8:	0141                	addi	sp,sp,16
    80000bea:	8082                	ret

0000000080000bec <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bec:	411c                	lw	a5,0(a0)
    80000bee:	e399                	bnez	a5,80000bf4 <holding+0x8>
    80000bf0:	4501                	li	a0,0
  return r;
}
    80000bf2:	8082                	ret
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bfe:	6904                	ld	s1,16(a0)
    80000c00:	00001097          	auipc	ra,0x1
    80000c04:	de2080e7          	jalr	-542(ra) # 800019e2 <mycpu>
    80000c08:	40a48533          	sub	a0,s1,a0
    80000c0c:	00153513          	seqz	a0,a0
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret

0000000080000c1a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c1a:	1101                	addi	sp,sp,-32
    80000c1c:	ec06                	sd	ra,24(sp)
    80000c1e:	e822                	sd	s0,16(sp)
    80000c20:	e426                	sd	s1,8(sp)
    80000c22:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c24:	100024f3          	csrr	s1,sstatus
    80000c28:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c2c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c2e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	db0080e7          	jalr	-592(ra) # 800019e2 <mycpu>
    80000c3a:	5d3c                	lw	a5,120(a0)
    80000c3c:	cf89                	beqz	a5,80000c56 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c3e:	00001097          	auipc	ra,0x1
    80000c42:	da4080e7          	jalr	-604(ra) # 800019e2 <mycpu>
    80000c46:	5d3c                	lw	a5,120(a0)
    80000c48:	2785                	addiw	a5,a5,1
    80000c4a:	dd3c                	sw	a5,120(a0)
}
    80000c4c:	60e2                	ld	ra,24(sp)
    80000c4e:	6442                	ld	s0,16(sp)
    80000c50:	64a2                	ld	s1,8(sp)
    80000c52:	6105                	addi	sp,sp,32
    80000c54:	8082                	ret
    mycpu()->intena = old;
    80000c56:	00001097          	auipc	ra,0x1
    80000c5a:	d8c080e7          	jalr	-628(ra) # 800019e2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c5e:	8085                	srli	s1,s1,0x1
    80000c60:	8885                	andi	s1,s1,1
    80000c62:	dd64                	sw	s1,124(a0)
    80000c64:	bfe9                	j	80000c3e <push_off+0x24>

0000000080000c66 <acquire>:
{
    80000c66:	1101                	addi	sp,sp,-32
    80000c68:	ec06                	sd	ra,24(sp)
    80000c6a:	e822                	sd	s0,16(sp)
    80000c6c:	e426                	sd	s1,8(sp)
    80000c6e:	1000                	addi	s0,sp,32
    80000c70:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	fa8080e7          	jalr	-88(ra) # 80000c1a <push_off>
  if(holding(lk))
    80000c7a:	8526                	mv	a0,s1
    80000c7c:	00000097          	auipc	ra,0x0
    80000c80:	f70080e7          	jalr	-144(ra) # 80000bec <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c84:	4705                	li	a4,1
  if(holding(lk))
    80000c86:	e115                	bnez	a0,80000caa <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c88:	87ba                	mv	a5,a4
    80000c8a:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c8e:	2781                	sext.w	a5,a5
    80000c90:	ffe5                	bnez	a5,80000c88 <acquire+0x22>
  __sync_synchronize();
    80000c92:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c96:	00001097          	auipc	ra,0x1
    80000c9a:	d4c080e7          	jalr	-692(ra) # 800019e2 <mycpu>
    80000c9e:	e888                	sd	a0,16(s1)
}
    80000ca0:	60e2                	ld	ra,24(sp)
    80000ca2:	6442                	ld	s0,16(sp)
    80000ca4:	64a2                	ld	s1,8(sp)
    80000ca6:	6105                	addi	sp,sp,32
    80000ca8:	8082                	ret
    panic("acquire");
    80000caa:	00007517          	auipc	a0,0x7
    80000cae:	3c650513          	addi	a0,a0,966 # 80008070 <digits+0x58>
    80000cb2:	00000097          	auipc	ra,0x0
    80000cb6:	8c6080e7          	jalr	-1850(ra) # 80000578 <panic>

0000000080000cba <pop_off>:

void
pop_off(void)
{
    80000cba:	1141                	addi	sp,sp,-16
    80000cbc:	e406                	sd	ra,8(sp)
    80000cbe:	e022                	sd	s0,0(sp)
    80000cc0:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cc2:	00001097          	auipc	ra,0x1
    80000cc6:	d20080e7          	jalr	-736(ra) # 800019e2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cca:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cce:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cd0:	e78d                	bnez	a5,80000cfa <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cd2:	5d3c                	lw	a5,120(a0)
    80000cd4:	02f05b63          	blez	a5,80000d0a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000cd8:	37fd                	addiw	a5,a5,-1
    80000cda:	0007871b          	sext.w	a4,a5
    80000cde:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000ce0:	eb09                	bnez	a4,80000cf2 <pop_off+0x38>
    80000ce2:	5d7c                	lw	a5,124(a0)
    80000ce4:	c799                	beqz	a5,80000cf2 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ce6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cea:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cee:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cf2:	60a2                	ld	ra,8(sp)
    80000cf4:	6402                	ld	s0,0(sp)
    80000cf6:	0141                	addi	sp,sp,16
    80000cf8:	8082                	ret
    panic("pop_off - interruptible");
    80000cfa:	00007517          	auipc	a0,0x7
    80000cfe:	37e50513          	addi	a0,a0,894 # 80008078 <digits+0x60>
    80000d02:	00000097          	auipc	ra,0x0
    80000d06:	876080e7          	jalr	-1930(ra) # 80000578 <panic>
    panic("pop_off");
    80000d0a:	00007517          	auipc	a0,0x7
    80000d0e:	38650513          	addi	a0,a0,902 # 80008090 <digits+0x78>
    80000d12:	00000097          	auipc	ra,0x0
    80000d16:	866080e7          	jalr	-1946(ra) # 80000578 <panic>

0000000080000d1a <release>:
{
    80000d1a:	1101                	addi	sp,sp,-32
    80000d1c:	ec06                	sd	ra,24(sp)
    80000d1e:	e822                	sd	s0,16(sp)
    80000d20:	e426                	sd	s1,8(sp)
    80000d22:	1000                	addi	s0,sp,32
    80000d24:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d26:	00000097          	auipc	ra,0x0
    80000d2a:	ec6080e7          	jalr	-314(ra) # 80000bec <holding>
    80000d2e:	c115                	beqz	a0,80000d52 <release+0x38>
  lk->cpu = 0;
    80000d30:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d34:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d38:	0f50000f          	fence	iorw,ow
    80000d3c:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d40:	00000097          	auipc	ra,0x0
    80000d44:	f7a080e7          	jalr	-134(ra) # 80000cba <pop_off>
}
    80000d48:	60e2                	ld	ra,24(sp)
    80000d4a:	6442                	ld	s0,16(sp)
    80000d4c:	64a2                	ld	s1,8(sp)
    80000d4e:	6105                	addi	sp,sp,32
    80000d50:	8082                	ret
    panic("release");
    80000d52:	00007517          	auipc	a0,0x7
    80000d56:	34650513          	addi	a0,a0,838 # 80008098 <digits+0x80>
    80000d5a:	00000097          	auipc	ra,0x0
    80000d5e:	81e080e7          	jalr	-2018(ra) # 80000578 <panic>

0000000080000d62 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d62:	1141                	addi	sp,sp,-16
    80000d64:	e422                	sd	s0,8(sp)
    80000d66:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d68:	ce09                	beqz	a2,80000d82 <memset+0x20>
    80000d6a:	87aa                	mv	a5,a0
    80000d6c:	fff6071b          	addiw	a4,a2,-1
    80000d70:	1702                	slli	a4,a4,0x20
    80000d72:	9301                	srli	a4,a4,0x20
    80000d74:	0705                	addi	a4,a4,1
    80000d76:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000d78:	00b78023          	sb	a1,0(a5) # fffffffffffff000 <end+0xffffffff7ffd9000>
  for(i = 0; i < n; i++){
    80000d7c:	0785                	addi	a5,a5,1
    80000d7e:	fee79de3          	bne	a5,a4,80000d78 <memset+0x16>
  }
  return dst;
}
    80000d82:	6422                	ld	s0,8(sp)
    80000d84:	0141                	addi	sp,sp,16
    80000d86:	8082                	ret

0000000080000d88 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d88:	1141                	addi	sp,sp,-16
    80000d8a:	e422                	sd	s0,8(sp)
    80000d8c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d8e:	ce15                	beqz	a2,80000dca <memcmp+0x42>
    80000d90:	fff6069b          	addiw	a3,a2,-1
    if(*s1 != *s2)
    80000d94:	00054783          	lbu	a5,0(a0)
    80000d98:	0005c703          	lbu	a4,0(a1)
    80000d9c:	02e79063          	bne	a5,a4,80000dbc <memcmp+0x34>
    80000da0:	1682                	slli	a3,a3,0x20
    80000da2:	9281                	srli	a3,a3,0x20
    80000da4:	0685                	addi	a3,a3,1
    80000da6:	96aa                	add	a3,a3,a0
      return *s1 - *s2;
    s1++, s2++;
    80000da8:	0505                	addi	a0,a0,1
    80000daa:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000dac:	00d50d63          	beq	a0,a3,80000dc6 <memcmp+0x3e>
    if(*s1 != *s2)
    80000db0:	00054783          	lbu	a5,0(a0)
    80000db4:	0005c703          	lbu	a4,0(a1)
    80000db8:	fee788e3          	beq	a5,a4,80000da8 <memcmp+0x20>
      return *s1 - *s2;
    80000dbc:	40e7853b          	subw	a0,a5,a4
  }

  return 0;
}
    80000dc0:	6422                	ld	s0,8(sp)
    80000dc2:	0141                	addi	sp,sp,16
    80000dc4:	8082                	ret
  return 0;
    80000dc6:	4501                	li	a0,0
    80000dc8:	bfe5                	j	80000dc0 <memcmp+0x38>
    80000dca:	4501                	li	a0,0
    80000dcc:	bfd5                	j	80000dc0 <memcmp+0x38>

0000000080000dce <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dce:	1141                	addi	sp,sp,-16
    80000dd0:	e422                	sd	s0,8(sp)
    80000dd2:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dd4:	00a5f963          	bleu	a0,a1,80000de6 <memmove+0x18>
    80000dd8:	02061713          	slli	a4,a2,0x20
    80000ddc:	9301                	srli	a4,a4,0x20
    80000dde:	00e587b3          	add	a5,a1,a4
    80000de2:	02f56563          	bltu	a0,a5,80000e0c <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000de6:	fff6069b          	addiw	a3,a2,-1
    80000dea:	ce11                	beqz	a2,80000e06 <memmove+0x38>
    80000dec:	1682                	slli	a3,a3,0x20
    80000dee:	9281                	srli	a3,a3,0x20
    80000df0:	0685                	addi	a3,a3,1
    80000df2:	96ae                	add	a3,a3,a1
    80000df4:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000df6:	0585                	addi	a1,a1,1
    80000df8:	0785                	addi	a5,a5,1
    80000dfa:	fff5c703          	lbu	a4,-1(a1)
    80000dfe:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000e02:	fed59ae3          	bne	a1,a3,80000df6 <memmove+0x28>

  return dst;
}
    80000e06:	6422                	ld	s0,8(sp)
    80000e08:	0141                	addi	sp,sp,16
    80000e0a:	8082                	ret
    d += n;
    80000e0c:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000e0e:	fff6069b          	addiw	a3,a2,-1
    80000e12:	da75                	beqz	a2,80000e06 <memmove+0x38>
    80000e14:	02069613          	slli	a2,a3,0x20
    80000e18:	9201                	srli	a2,a2,0x20
    80000e1a:	fff64613          	not	a2,a2
    80000e1e:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e20:	17fd                	addi	a5,a5,-1
    80000e22:	177d                	addi	a4,a4,-1
    80000e24:	0007c683          	lbu	a3,0(a5)
    80000e28:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e2c:	fef61ae3          	bne	a2,a5,80000e20 <memmove+0x52>
    80000e30:	bfd9                	j	80000e06 <memmove+0x38>

0000000080000e32 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e32:	1141                	addi	sp,sp,-16
    80000e34:	e406                	sd	ra,8(sp)
    80000e36:	e022                	sd	s0,0(sp)
    80000e38:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e3a:	00000097          	auipc	ra,0x0
    80000e3e:	f94080e7          	jalr	-108(ra) # 80000dce <memmove>
}
    80000e42:	60a2                	ld	ra,8(sp)
    80000e44:	6402                	ld	s0,0(sp)
    80000e46:	0141                	addi	sp,sp,16
    80000e48:	8082                	ret

0000000080000e4a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e4a:	1141                	addi	sp,sp,-16
    80000e4c:	e422                	sd	s0,8(sp)
    80000e4e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e50:	c229                	beqz	a2,80000e92 <strncmp+0x48>
    80000e52:	00054783          	lbu	a5,0(a0)
    80000e56:	c795                	beqz	a5,80000e82 <strncmp+0x38>
    80000e58:	0005c703          	lbu	a4,0(a1)
    80000e5c:	02f71363          	bne	a4,a5,80000e82 <strncmp+0x38>
    80000e60:	fff6071b          	addiw	a4,a2,-1
    80000e64:	1702                	slli	a4,a4,0x20
    80000e66:	9301                	srli	a4,a4,0x20
    80000e68:	0705                	addi	a4,a4,1
    80000e6a:	972a                	add	a4,a4,a0
    n--, p++, q++;
    80000e6c:	0505                	addi	a0,a0,1
    80000e6e:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e70:	02e50363          	beq	a0,a4,80000e96 <strncmp+0x4c>
    80000e74:	00054783          	lbu	a5,0(a0)
    80000e78:	c789                	beqz	a5,80000e82 <strncmp+0x38>
    80000e7a:	0005c683          	lbu	a3,0(a1)
    80000e7e:	fef687e3          	beq	a3,a5,80000e6c <strncmp+0x22>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
    80000e82:	00054503          	lbu	a0,0(a0)
    80000e86:	0005c783          	lbu	a5,0(a1)
    80000e8a:	9d1d                	subw	a0,a0,a5
}
    80000e8c:	6422                	ld	s0,8(sp)
    80000e8e:	0141                	addi	sp,sp,16
    80000e90:	8082                	ret
    return 0;
    80000e92:	4501                	li	a0,0
    80000e94:	bfe5                	j	80000e8c <strncmp+0x42>
    80000e96:	4501                	li	a0,0
    80000e98:	bfd5                	j	80000e8c <strncmp+0x42>

0000000080000e9a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e9a:	1141                	addi	sp,sp,-16
    80000e9c:	e422                	sd	s0,8(sp)
    80000e9e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000ea0:	872a                	mv	a4,a0
    80000ea2:	a011                	j	80000ea6 <strncpy+0xc>
    80000ea4:	8636                	mv	a2,a3
    80000ea6:	fff6069b          	addiw	a3,a2,-1
    80000eaa:	00c05963          	blez	a2,80000ebc <strncpy+0x22>
    80000eae:	0705                	addi	a4,a4,1
    80000eb0:	0005c783          	lbu	a5,0(a1)
    80000eb4:	fef70fa3          	sb	a5,-1(a4)
    80000eb8:	0585                	addi	a1,a1,1
    80000eba:	f7ed                	bnez	a5,80000ea4 <strncpy+0xa>
    ;
  while(n-- > 0)
    80000ebc:	00d05c63          	blez	a3,80000ed4 <strncpy+0x3a>
    80000ec0:	86ba                	mv	a3,a4
    *s++ = 0;
    80000ec2:	0685                	addi	a3,a3,1
    80000ec4:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000ec8:	fff6c793          	not	a5,a3
    80000ecc:	9fb9                	addw	a5,a5,a4
    80000ece:	9fb1                	addw	a5,a5,a2
    80000ed0:	fef049e3          	bgtz	a5,80000ec2 <strncpy+0x28>
  return os;
}
    80000ed4:	6422                	ld	s0,8(sp)
    80000ed6:	0141                	addi	sp,sp,16
    80000ed8:	8082                	ret

0000000080000eda <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000eda:	1141                	addi	sp,sp,-16
    80000edc:	e422                	sd	s0,8(sp)
    80000ede:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ee0:	02c05363          	blez	a2,80000f06 <safestrcpy+0x2c>
    80000ee4:	fff6069b          	addiw	a3,a2,-1
    80000ee8:	1682                	slli	a3,a3,0x20
    80000eea:	9281                	srli	a3,a3,0x20
    80000eec:	96ae                	add	a3,a3,a1
    80000eee:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ef0:	00d58963          	beq	a1,a3,80000f02 <safestrcpy+0x28>
    80000ef4:	0585                	addi	a1,a1,1
    80000ef6:	0785                	addi	a5,a5,1
    80000ef8:	fff5c703          	lbu	a4,-1(a1)
    80000efc:	fee78fa3          	sb	a4,-1(a5)
    80000f00:	fb65                	bnez	a4,80000ef0 <safestrcpy+0x16>
    ;
  *s = 0;
    80000f02:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f06:	6422                	ld	s0,8(sp)
    80000f08:	0141                	addi	sp,sp,16
    80000f0a:	8082                	ret

0000000080000f0c <strlen>:

int
strlen(const char *s)
{
    80000f0c:	1141                	addi	sp,sp,-16
    80000f0e:	e422                	sd	s0,8(sp)
    80000f10:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f12:	00054783          	lbu	a5,0(a0)
    80000f16:	cf91                	beqz	a5,80000f32 <strlen+0x26>
    80000f18:	0505                	addi	a0,a0,1
    80000f1a:	87aa                	mv	a5,a0
    80000f1c:	4685                	li	a3,1
    80000f1e:	9e89                	subw	a3,a3,a0
    80000f20:	00f6853b          	addw	a0,a3,a5
    80000f24:	0785                	addi	a5,a5,1
    80000f26:	fff7c703          	lbu	a4,-1(a5)
    80000f2a:	fb7d                	bnez	a4,80000f20 <strlen+0x14>
    ;
  return n;
}
    80000f2c:	6422                	ld	s0,8(sp)
    80000f2e:	0141                	addi	sp,sp,16
    80000f30:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f32:	4501                	li	a0,0
    80000f34:	bfe5                	j	80000f2c <strlen+0x20>

0000000080000f36 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f36:	1141                	addi	sp,sp,-16
    80000f38:	e406                	sd	ra,8(sp)
    80000f3a:	e022                	sd	s0,0(sp)
    80000f3c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f3e:	00001097          	auipc	ra,0x1
    80000f42:	a94080e7          	jalr	-1388(ra) # 800019d2 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f46:	00008717          	auipc	a4,0x8
    80000f4a:	0c670713          	addi	a4,a4,198 # 8000900c <started>
  if(cpuid() == 0){
    80000f4e:	c139                	beqz	a0,80000f94 <main+0x5e>
    while(started == 0)
    80000f50:	431c                	lw	a5,0(a4)
    80000f52:	2781                	sext.w	a5,a5
    80000f54:	dff5                	beqz	a5,80000f50 <main+0x1a>
      ;
    __sync_synchronize();
    80000f56:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f5a:	00001097          	auipc	ra,0x1
    80000f5e:	a78080e7          	jalr	-1416(ra) # 800019d2 <cpuid>
    80000f62:	85aa                	mv	a1,a0
    80000f64:	00007517          	auipc	a0,0x7
    80000f68:	15450513          	addi	a0,a0,340 # 800080b8 <digits+0xa0>
    80000f6c:	fffff097          	auipc	ra,0xfffff
    80000f70:	656080e7          	jalr	1622(ra) # 800005c2 <printf>
    kvminithart();    // turn on paging
    80000f74:	00000097          	auipc	ra,0x0
    80000f78:	17e080e7          	jalr	382(ra) # 800010f2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f7c:	00001097          	auipc	ra,0x1
    80000f80:	6ec080e7          	jalr	1772(ra) # 80002668 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f84:	00005097          	auipc	ra,0x5
    80000f88:	d6c080e7          	jalr	-660(ra) # 80005cf0 <plicinithart>
  }

  scheduler();        
    80000f8c:	00001097          	auipc	ra,0x1
    80000f90:	fa8080e7          	jalr	-88(ra) # 80001f34 <scheduler>
    consoleinit();
    80000f94:	fffff097          	auipc	ra,0xfffff
    80000f98:	4f2080e7          	jalr	1266(ra) # 80000486 <consoleinit>
    printfinit();
    80000f9c:	00000097          	auipc	ra,0x0
    80000fa0:	80c080e7          	jalr	-2036(ra) # 800007a8 <printfinit>
    printf("\n");
    80000fa4:	00007517          	auipc	a0,0x7
    80000fa8:	12450513          	addi	a0,a0,292 # 800080c8 <digits+0xb0>
    80000fac:	fffff097          	auipc	ra,0xfffff
    80000fb0:	616080e7          	jalr	1558(ra) # 800005c2 <printf>
    printf("xv6 kernel is booting\n");
    80000fb4:	00007517          	auipc	a0,0x7
    80000fb8:	0ec50513          	addi	a0,a0,236 # 800080a0 <digits+0x88>
    80000fbc:	fffff097          	auipc	ra,0xfffff
    80000fc0:	606080e7          	jalr	1542(ra) # 800005c2 <printf>
    printf("\n");
    80000fc4:	00007517          	auipc	a0,0x7
    80000fc8:	10450513          	addi	a0,a0,260 # 800080c8 <digits+0xb0>
    80000fcc:	fffff097          	auipc	ra,0xfffff
    80000fd0:	5f6080e7          	jalr	1526(ra) # 800005c2 <printf>
    kinit();         // physical page allocator
    80000fd4:	00000097          	auipc	ra,0x0
    80000fd8:	b66080e7          	jalr	-1178(ra) # 80000b3a <kinit>
    kvminit();       // create kernel page table
    80000fdc:	00000097          	auipc	ra,0x0
    80000fe0:	244080e7          	jalr	580(ra) # 80001220 <kvminit>
    kvminithart();   // turn on paging
    80000fe4:	00000097          	auipc	ra,0x0
    80000fe8:	10e080e7          	jalr	270(ra) # 800010f2 <kvminithart>
    procinit();      // process table
    80000fec:	00001097          	auipc	ra,0x1
    80000ff0:	916080e7          	jalr	-1770(ra) # 80001902 <procinit>
    trapinit();      // trap vectors
    80000ff4:	00001097          	auipc	ra,0x1
    80000ff8:	64c080e7          	jalr	1612(ra) # 80002640 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ffc:	00001097          	auipc	ra,0x1
    80001000:	66c080e7          	jalr	1644(ra) # 80002668 <trapinithart>
    plicinit();      // set up interrupt controller
    80001004:	00005097          	auipc	ra,0x5
    80001008:	cd6080e7          	jalr	-810(ra) # 80005cda <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000100c:	00005097          	auipc	ra,0x5
    80001010:	ce4080e7          	jalr	-796(ra) # 80005cf0 <plicinithart>
    binit();         // buffer cache
    80001014:	00002097          	auipc	ra,0x2
    80001018:	da4080e7          	jalr	-604(ra) # 80002db8 <binit>
    iinit();         // inode cache
    8000101c:	00002097          	auipc	ra,0x2
    80001020:	476080e7          	jalr	1142(ra) # 80003492 <iinit>
    fileinit();      // file table
    80001024:	00003097          	auipc	ra,0x3
    80001028:	452080e7          	jalr	1106(ra) # 80004476 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000102c:	00005097          	auipc	ra,0x5
    80001030:	de6080e7          	jalr	-538(ra) # 80005e12 <virtio_disk_init>
    userinit();      // first user process
    80001034:	00001097          	auipc	ra,0x1
    80001038:	c96080e7          	jalr	-874(ra) # 80001cca <userinit>
    __sync_synchronize();
    8000103c:	0ff0000f          	fence
    started = 1;
    80001040:	4785                	li	a5,1
    80001042:	00008717          	auipc	a4,0x8
    80001046:	fcf72523          	sw	a5,-54(a4) # 8000900c <started>
    8000104a:	b789                	j	80000f8c <main+0x56>

000000008000104c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000104c:	7139                	addi	sp,sp,-64
    8000104e:	fc06                	sd	ra,56(sp)
    80001050:	f822                	sd	s0,48(sp)
    80001052:	f426                	sd	s1,40(sp)
    80001054:	f04a                	sd	s2,32(sp)
    80001056:	ec4e                	sd	s3,24(sp)
    80001058:	e852                	sd	s4,16(sp)
    8000105a:	e456                	sd	s5,8(sp)
    8000105c:	e05a                	sd	s6,0(sp)
    8000105e:	0080                	addi	s0,sp,64
    80001060:	84aa                	mv	s1,a0
    80001062:	89ae                	mv	s3,a1
    80001064:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80001066:	57fd                	li	a5,-1
    80001068:	83e9                	srli	a5,a5,0x1a
    8000106a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000106c:	4ab1                	li	s5,12
  if(va >= MAXVA)
    8000106e:	04b7f263          	bleu	a1,a5,800010b2 <walk+0x66>
    panic("walk");
    80001072:	00007517          	auipc	a0,0x7
    80001076:	05e50513          	addi	a0,a0,94 # 800080d0 <digits+0xb8>
    8000107a:	fffff097          	auipc	ra,0xfffff
    8000107e:	4fe080e7          	jalr	1278(ra) # 80000578 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001082:	060b0663          	beqz	s6,800010ee <walk+0xa2>
    80001086:	00000097          	auipc	ra,0x0
    8000108a:	af0080e7          	jalr	-1296(ra) # 80000b76 <kalloc>
    8000108e:	84aa                	mv	s1,a0
    80001090:	c529                	beqz	a0,800010da <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001092:	6605                	lui	a2,0x1
    80001094:	4581                	li	a1,0
    80001096:	00000097          	auipc	ra,0x0
    8000109a:	ccc080e7          	jalr	-820(ra) # 80000d62 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000109e:	00c4d793          	srli	a5,s1,0xc
    800010a2:	07aa                	slli	a5,a5,0xa
    800010a4:	0017e793          	ori	a5,a5,1
    800010a8:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010ac:	3a5d                	addiw	s4,s4,-9
    800010ae:	035a0063          	beq	s4,s5,800010ce <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010b2:	0149d933          	srl	s2,s3,s4
    800010b6:	1ff97913          	andi	s2,s2,511
    800010ba:	090e                	slli	s2,s2,0x3
    800010bc:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010be:	00093483          	ld	s1,0(s2)
    800010c2:	0014f793          	andi	a5,s1,1
    800010c6:	dfd5                	beqz	a5,80001082 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010c8:	80a9                	srli	s1,s1,0xa
    800010ca:	04b2                	slli	s1,s1,0xc
    800010cc:	b7c5                	j	800010ac <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010ce:	00c9d513          	srli	a0,s3,0xc
    800010d2:	1ff57513          	andi	a0,a0,511
    800010d6:	050e                	slli	a0,a0,0x3
    800010d8:	9526                	add	a0,a0,s1
}
    800010da:	70e2                	ld	ra,56(sp)
    800010dc:	7442                	ld	s0,48(sp)
    800010de:	74a2                	ld	s1,40(sp)
    800010e0:	7902                	ld	s2,32(sp)
    800010e2:	69e2                	ld	s3,24(sp)
    800010e4:	6a42                	ld	s4,16(sp)
    800010e6:	6aa2                	ld	s5,8(sp)
    800010e8:	6b02                	ld	s6,0(sp)
    800010ea:	6121                	addi	sp,sp,64
    800010ec:	8082                	ret
        return 0;
    800010ee:	4501                	li	a0,0
    800010f0:	b7ed                	j	800010da <walk+0x8e>

00000000800010f2 <kvminithart>:
{
    800010f2:	1141                	addi	sp,sp,-16
    800010f4:	e422                	sd	s0,8(sp)
    800010f6:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    800010f8:	00008797          	auipc	a5,0x8
    800010fc:	f1878793          	addi	a5,a5,-232 # 80009010 <kernel_pagetable>
    80001100:	639c                	ld	a5,0(a5)
    80001102:	83b1                	srli	a5,a5,0xc
    80001104:	577d                	li	a4,-1
    80001106:	177e                	slli	a4,a4,0x3f
    80001108:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000110a:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000110e:	12000073          	sfence.vma
}
    80001112:	6422                	ld	s0,8(sp)
    80001114:	0141                	addi	sp,sp,16
    80001116:	8082                	ret

0000000080001118 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001118:	57fd                	li	a5,-1
    8000111a:	83e9                	srli	a5,a5,0x1a
    8000111c:	00b7f463          	bleu	a1,a5,80001124 <walkaddr+0xc>
    return 0;
    80001120:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001122:	8082                	ret
{
    80001124:	1141                	addi	sp,sp,-16
    80001126:	e406                	sd	ra,8(sp)
    80001128:	e022                	sd	s0,0(sp)
    8000112a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000112c:	4601                	li	a2,0
    8000112e:	00000097          	auipc	ra,0x0
    80001132:	f1e080e7          	jalr	-226(ra) # 8000104c <walk>
  if(pte == 0)
    80001136:	c105                	beqz	a0,80001156 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001138:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000113a:	0117f693          	andi	a3,a5,17
    8000113e:	4745                	li	a4,17
    return 0;
    80001140:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001142:	00e68663          	beq	a3,a4,8000114e <walkaddr+0x36>
}
    80001146:	60a2                	ld	ra,8(sp)
    80001148:	6402                	ld	s0,0(sp)
    8000114a:	0141                	addi	sp,sp,16
    8000114c:	8082                	ret
  pa = PTE2PA(*pte);
    8000114e:	00a7d513          	srli	a0,a5,0xa
    80001152:	0532                	slli	a0,a0,0xc
  return pa;
    80001154:	bfcd                	j	80001146 <walkaddr+0x2e>
    return 0;
    80001156:	4501                	li	a0,0
    80001158:	b7fd                	j	80001146 <walkaddr+0x2e>

000000008000115a <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000115a:	715d                	addi	sp,sp,-80
    8000115c:	e486                	sd	ra,72(sp)
    8000115e:	e0a2                	sd	s0,64(sp)
    80001160:	fc26                	sd	s1,56(sp)
    80001162:	f84a                	sd	s2,48(sp)
    80001164:	f44e                	sd	s3,40(sp)
    80001166:	f052                	sd	s4,32(sp)
    80001168:	ec56                	sd	s5,24(sp)
    8000116a:	e85a                	sd	s6,16(sp)
    8000116c:	e45e                	sd	s7,8(sp)
    8000116e:	0880                	addi	s0,sp,80
    80001170:	8aaa                	mv	s5,a0
    80001172:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001174:	79fd                	lui	s3,0xfffff
    80001176:	0135fa33          	and	s4,a1,s3
  last = PGROUNDDOWN(va + size - 1);
    8000117a:	167d                	addi	a2,a2,-1
    8000117c:	962e                	add	a2,a2,a1
    8000117e:	013679b3          	and	s3,a2,s3
  a = PGROUNDDOWN(va);
    80001182:	8952                	mv	s2,s4
    80001184:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001188:	6b85                	lui	s7,0x1
    8000118a:	a811                	j	8000119e <mappages+0x44>
      panic("remap");
    8000118c:	00007517          	auipc	a0,0x7
    80001190:	f4c50513          	addi	a0,a0,-180 # 800080d8 <digits+0xc0>
    80001194:	fffff097          	auipc	ra,0xfffff
    80001198:	3e4080e7          	jalr	996(ra) # 80000578 <panic>
    a += PGSIZE;
    8000119c:	995e                	add	s2,s2,s7
  for(;;){
    8000119e:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011a2:	4605                	li	a2,1
    800011a4:	85ca                	mv	a1,s2
    800011a6:	8556                	mv	a0,s5
    800011a8:	00000097          	auipc	ra,0x0
    800011ac:	ea4080e7          	jalr	-348(ra) # 8000104c <walk>
    800011b0:	cd19                	beqz	a0,800011ce <mappages+0x74>
    if(*pte & PTE_V)
    800011b2:	611c                	ld	a5,0(a0)
    800011b4:	8b85                	andi	a5,a5,1
    800011b6:	fbf9                	bnez	a5,8000118c <mappages+0x32>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011b8:	80b1                	srli	s1,s1,0xc
    800011ba:	04aa                	slli	s1,s1,0xa
    800011bc:	0164e4b3          	or	s1,s1,s6
    800011c0:	0014e493          	ori	s1,s1,1
    800011c4:	e104                	sd	s1,0(a0)
    if(a == last)
    800011c6:	fd391be3          	bne	s2,s3,8000119c <mappages+0x42>
    pa += PGSIZE;
  }
  return 0;
    800011ca:	4501                	li	a0,0
    800011cc:	a011                	j	800011d0 <mappages+0x76>
      return -1;
    800011ce:	557d                	li	a0,-1
}
    800011d0:	60a6                	ld	ra,72(sp)
    800011d2:	6406                	ld	s0,64(sp)
    800011d4:	74e2                	ld	s1,56(sp)
    800011d6:	7942                	ld	s2,48(sp)
    800011d8:	79a2                	ld	s3,40(sp)
    800011da:	7a02                	ld	s4,32(sp)
    800011dc:	6ae2                	ld	s5,24(sp)
    800011de:	6b42                	ld	s6,16(sp)
    800011e0:	6ba2                	ld	s7,8(sp)
    800011e2:	6161                	addi	sp,sp,80
    800011e4:	8082                	ret

00000000800011e6 <kvmmap>:
{
    800011e6:	1141                	addi	sp,sp,-16
    800011e8:	e406                	sd	ra,8(sp)
    800011ea:	e022                	sd	s0,0(sp)
    800011ec:	0800                	addi	s0,sp,16
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800011ee:	8736                	mv	a4,a3
    800011f0:	86ae                	mv	a3,a1
    800011f2:	85aa                	mv	a1,a0
    800011f4:	00008797          	auipc	a5,0x8
    800011f8:	e1c78793          	addi	a5,a5,-484 # 80009010 <kernel_pagetable>
    800011fc:	6388                	ld	a0,0(a5)
    800011fe:	00000097          	auipc	ra,0x0
    80001202:	f5c080e7          	jalr	-164(ra) # 8000115a <mappages>
    80001206:	e509                	bnez	a0,80001210 <kvmmap+0x2a>
}
    80001208:	60a2                	ld	ra,8(sp)
    8000120a:	6402                	ld	s0,0(sp)
    8000120c:	0141                	addi	sp,sp,16
    8000120e:	8082                	ret
    panic("kvmmap");
    80001210:	00007517          	auipc	a0,0x7
    80001214:	ed050513          	addi	a0,a0,-304 # 800080e0 <digits+0xc8>
    80001218:	fffff097          	auipc	ra,0xfffff
    8000121c:	360080e7          	jalr	864(ra) # 80000578 <panic>

0000000080001220 <kvminit>:
{
    80001220:	1101                	addi	sp,sp,-32
    80001222:	ec06                	sd	ra,24(sp)
    80001224:	e822                	sd	s0,16(sp)
    80001226:	e426                	sd	s1,8(sp)
    80001228:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    8000122a:	00000097          	auipc	ra,0x0
    8000122e:	94c080e7          	jalr	-1716(ra) # 80000b76 <kalloc>
    80001232:	00008797          	auipc	a5,0x8
    80001236:	dca7bf23          	sd	a0,-546(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    8000123a:	6605                	lui	a2,0x1
    8000123c:	4581                	li	a1,0
    8000123e:	00000097          	auipc	ra,0x0
    80001242:	b24080e7          	jalr	-1244(ra) # 80000d62 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001246:	4699                	li	a3,6
    80001248:	6605                	lui	a2,0x1
    8000124a:	100005b7          	lui	a1,0x10000
    8000124e:	10000537          	lui	a0,0x10000
    80001252:	00000097          	auipc	ra,0x0
    80001256:	f94080e7          	jalr	-108(ra) # 800011e6 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000125a:	4699                	li	a3,6
    8000125c:	6605                	lui	a2,0x1
    8000125e:	100015b7          	lui	a1,0x10001
    80001262:	10001537          	lui	a0,0x10001
    80001266:	00000097          	auipc	ra,0x0
    8000126a:	f80080e7          	jalr	-128(ra) # 800011e6 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000126e:	4699                	li	a3,6
    80001270:	00400637          	lui	a2,0x400
    80001274:	0c0005b7          	lui	a1,0xc000
    80001278:	0c000537          	lui	a0,0xc000
    8000127c:	00000097          	auipc	ra,0x0
    80001280:	f6a080e7          	jalr	-150(ra) # 800011e6 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001284:	00007497          	auipc	s1,0x7
    80001288:	d7c48493          	addi	s1,s1,-644 # 80008000 <etext>
    8000128c:	46a9                	li	a3,10
    8000128e:	80007617          	auipc	a2,0x80007
    80001292:	d7260613          	addi	a2,a2,-654 # 8000 <_entry-0x7fff8000>
    80001296:	4585                	li	a1,1
    80001298:	05fe                	slli	a1,a1,0x1f
    8000129a:	852e                	mv	a0,a1
    8000129c:	00000097          	auipc	ra,0x0
    800012a0:	f4a080e7          	jalr	-182(ra) # 800011e6 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012a4:	4699                	li	a3,6
    800012a6:	4645                	li	a2,17
    800012a8:	066e                	slli	a2,a2,0x1b
    800012aa:	8e05                	sub	a2,a2,s1
    800012ac:	85a6                	mv	a1,s1
    800012ae:	8526                	mv	a0,s1
    800012b0:	00000097          	auipc	ra,0x0
    800012b4:	f36080e7          	jalr	-202(ra) # 800011e6 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012b8:	46a9                	li	a3,10
    800012ba:	6605                	lui	a2,0x1
    800012bc:	00006597          	auipc	a1,0x6
    800012c0:	d4458593          	addi	a1,a1,-700 # 80007000 <_trampoline>
    800012c4:	04000537          	lui	a0,0x4000
    800012c8:	157d                	addi	a0,a0,-1
    800012ca:	0532                	slli	a0,a0,0xc
    800012cc:	00000097          	auipc	ra,0x0
    800012d0:	f1a080e7          	jalr	-230(ra) # 800011e6 <kvmmap>
}
    800012d4:	60e2                	ld	ra,24(sp)
    800012d6:	6442                	ld	s0,16(sp)
    800012d8:	64a2                	ld	s1,8(sp)
    800012da:	6105                	addi	sp,sp,32
    800012dc:	8082                	ret

00000000800012de <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012de:	715d                	addi	sp,sp,-80
    800012e0:	e486                	sd	ra,72(sp)
    800012e2:	e0a2                	sd	s0,64(sp)
    800012e4:	fc26                	sd	s1,56(sp)
    800012e6:	f84a                	sd	s2,48(sp)
    800012e8:	f44e                	sd	s3,40(sp)
    800012ea:	f052                	sd	s4,32(sp)
    800012ec:	ec56                	sd	s5,24(sp)
    800012ee:	e85a                	sd	s6,16(sp)
    800012f0:	e45e                	sd	s7,8(sp)
    800012f2:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012f4:	6785                	lui	a5,0x1
    800012f6:	17fd                	addi	a5,a5,-1
    800012f8:	8fed                	and	a5,a5,a1
    800012fa:	e795                	bnez	a5,80001326 <uvmunmap+0x48>
    800012fc:	8a2a                	mv	s4,a0
    800012fe:	84ae                	mv	s1,a1
    80001300:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001302:	0632                	slli	a2,a2,0xc
    80001304:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001308:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130a:	6b05                	lui	s6,0x1
    8000130c:	0735e863          	bltu	a1,s3,8000137c <uvmunmap+0x9e>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001310:	60a6                	ld	ra,72(sp)
    80001312:	6406                	ld	s0,64(sp)
    80001314:	74e2                	ld	s1,56(sp)
    80001316:	7942                	ld	s2,48(sp)
    80001318:	79a2                	ld	s3,40(sp)
    8000131a:	7a02                	ld	s4,32(sp)
    8000131c:	6ae2                	ld	s5,24(sp)
    8000131e:	6b42                	ld	s6,16(sp)
    80001320:	6ba2                	ld	s7,8(sp)
    80001322:	6161                	addi	sp,sp,80
    80001324:	8082                	ret
    panic("uvmunmap: not aligned");
    80001326:	00007517          	auipc	a0,0x7
    8000132a:	dc250513          	addi	a0,a0,-574 # 800080e8 <digits+0xd0>
    8000132e:	fffff097          	auipc	ra,0xfffff
    80001332:	24a080e7          	jalr	586(ra) # 80000578 <panic>
      panic("uvmunmap: walk");
    80001336:	00007517          	auipc	a0,0x7
    8000133a:	dca50513          	addi	a0,a0,-566 # 80008100 <digits+0xe8>
    8000133e:	fffff097          	auipc	ra,0xfffff
    80001342:	23a080e7          	jalr	570(ra) # 80000578 <panic>
      panic("uvmunmap: not mapped");
    80001346:	00007517          	auipc	a0,0x7
    8000134a:	dca50513          	addi	a0,a0,-566 # 80008110 <digits+0xf8>
    8000134e:	fffff097          	auipc	ra,0xfffff
    80001352:	22a080e7          	jalr	554(ra) # 80000578 <panic>
      panic("uvmunmap: not a leaf");
    80001356:	00007517          	auipc	a0,0x7
    8000135a:	dd250513          	addi	a0,a0,-558 # 80008128 <digits+0x110>
    8000135e:	fffff097          	auipc	ra,0xfffff
    80001362:	21a080e7          	jalr	538(ra) # 80000578 <panic>
      uint64 pa = PTE2PA(*pte);
    80001366:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001368:	0532                	slli	a0,a0,0xc
    8000136a:	fffff097          	auipc	ra,0xfffff
    8000136e:	70c080e7          	jalr	1804(ra) # 80000a76 <kfree>
    *pte = 0;
    80001372:	00093023          	sd	zero,0(s2)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001376:	94da                	add	s1,s1,s6
    80001378:	f934fce3          	bleu	s3,s1,80001310 <uvmunmap+0x32>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000137c:	4601                	li	a2,0
    8000137e:	85a6                	mv	a1,s1
    80001380:	8552                	mv	a0,s4
    80001382:	00000097          	auipc	ra,0x0
    80001386:	cca080e7          	jalr	-822(ra) # 8000104c <walk>
    8000138a:	892a                	mv	s2,a0
    8000138c:	d54d                	beqz	a0,80001336 <uvmunmap+0x58>
    if((*pte & PTE_V) == 0)
    8000138e:	6108                	ld	a0,0(a0)
    80001390:	00157793          	andi	a5,a0,1
    80001394:	dbcd                	beqz	a5,80001346 <uvmunmap+0x68>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001396:	3ff57793          	andi	a5,a0,1023
    8000139a:	fb778ee3          	beq	a5,s7,80001356 <uvmunmap+0x78>
    if(do_free){
    8000139e:	fc0a8ae3          	beqz	s5,80001372 <uvmunmap+0x94>
    800013a2:	b7d1                	j	80001366 <uvmunmap+0x88>

00000000800013a4 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013a4:	1101                	addi	sp,sp,-32
    800013a6:	ec06                	sd	ra,24(sp)
    800013a8:	e822                	sd	s0,16(sp)
    800013aa:	e426                	sd	s1,8(sp)
    800013ac:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013ae:	fffff097          	auipc	ra,0xfffff
    800013b2:	7c8080e7          	jalr	1992(ra) # 80000b76 <kalloc>
    800013b6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013b8:	c519                	beqz	a0,800013c6 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013ba:	6605                	lui	a2,0x1
    800013bc:	4581                	li	a1,0
    800013be:	00000097          	auipc	ra,0x0
    800013c2:	9a4080e7          	jalr	-1628(ra) # 80000d62 <memset>
  return pagetable;
}
    800013c6:	8526                	mv	a0,s1
    800013c8:	60e2                	ld	ra,24(sp)
    800013ca:	6442                	ld	s0,16(sp)
    800013cc:	64a2                	ld	s1,8(sp)
    800013ce:	6105                	addi	sp,sp,32
    800013d0:	8082                	ret

00000000800013d2 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800013d2:	7179                	addi	sp,sp,-48
    800013d4:	f406                	sd	ra,40(sp)
    800013d6:	f022                	sd	s0,32(sp)
    800013d8:	ec26                	sd	s1,24(sp)
    800013da:	e84a                	sd	s2,16(sp)
    800013dc:	e44e                	sd	s3,8(sp)
    800013de:	e052                	sd	s4,0(sp)
    800013e0:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013e2:	6785                	lui	a5,0x1
    800013e4:	04f67863          	bleu	a5,a2,80001434 <uvminit+0x62>
    800013e8:	8a2a                	mv	s4,a0
    800013ea:	89ae                	mv	s3,a1
    800013ec:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013ee:	fffff097          	auipc	ra,0xfffff
    800013f2:	788080e7          	jalr	1928(ra) # 80000b76 <kalloc>
    800013f6:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013f8:	6605                	lui	a2,0x1
    800013fa:	4581                	li	a1,0
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	966080e7          	jalr	-1690(ra) # 80000d62 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001404:	4779                	li	a4,30
    80001406:	86ca                	mv	a3,s2
    80001408:	6605                	lui	a2,0x1
    8000140a:	4581                	li	a1,0
    8000140c:	8552                	mv	a0,s4
    8000140e:	00000097          	auipc	ra,0x0
    80001412:	d4c080e7          	jalr	-692(ra) # 8000115a <mappages>
  memmove(mem, src, sz);
    80001416:	8626                	mv	a2,s1
    80001418:	85ce                	mv	a1,s3
    8000141a:	854a                	mv	a0,s2
    8000141c:	00000097          	auipc	ra,0x0
    80001420:	9b2080e7          	jalr	-1614(ra) # 80000dce <memmove>
}
    80001424:	70a2                	ld	ra,40(sp)
    80001426:	7402                	ld	s0,32(sp)
    80001428:	64e2                	ld	s1,24(sp)
    8000142a:	6942                	ld	s2,16(sp)
    8000142c:	69a2                	ld	s3,8(sp)
    8000142e:	6a02                	ld	s4,0(sp)
    80001430:	6145                	addi	sp,sp,48
    80001432:	8082                	ret
    panic("inituvm: more than a page");
    80001434:	00007517          	auipc	a0,0x7
    80001438:	d0c50513          	addi	a0,a0,-756 # 80008140 <digits+0x128>
    8000143c:	fffff097          	auipc	ra,0xfffff
    80001440:	13c080e7          	jalr	316(ra) # 80000578 <panic>

0000000080001444 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000144e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001450:	00b67d63          	bleu	a1,a2,8000146a <uvmdealloc+0x26>
    80001454:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001456:	6605                	lui	a2,0x1
    80001458:	167d                	addi	a2,a2,-1
    8000145a:	00c487b3          	add	a5,s1,a2
    8000145e:	777d                	lui	a4,0xfffff
    80001460:	8ff9                	and	a5,a5,a4
    80001462:	962e                	add	a2,a2,a1
    80001464:	8e79                	and	a2,a2,a4
    80001466:	00c7e863          	bltu	a5,a2,80001476 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000146a:	8526                	mv	a0,s1
    8000146c:	60e2                	ld	ra,24(sp)
    8000146e:	6442                	ld	s0,16(sp)
    80001470:	64a2                	ld	s1,8(sp)
    80001472:	6105                	addi	sp,sp,32
    80001474:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001476:	8e1d                	sub	a2,a2,a5
    80001478:	8231                	srli	a2,a2,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000147a:	4685                	li	a3,1
    8000147c:	2601                	sext.w	a2,a2
    8000147e:	85be                	mv	a1,a5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	e5e080e7          	jalr	-418(ra) # 800012de <uvmunmap>
    80001488:	b7cd                	j	8000146a <uvmdealloc+0x26>

000000008000148a <uvmalloc>:
  if(newsz < oldsz)
    8000148a:	0ab66163          	bltu	a2,a1,8000152c <uvmalloc+0xa2>
{
    8000148e:	7139                	addi	sp,sp,-64
    80001490:	fc06                	sd	ra,56(sp)
    80001492:	f822                	sd	s0,48(sp)
    80001494:	f426                	sd	s1,40(sp)
    80001496:	f04a                	sd	s2,32(sp)
    80001498:	ec4e                	sd	s3,24(sp)
    8000149a:	e852                	sd	s4,16(sp)
    8000149c:	e456                	sd	s5,8(sp)
    8000149e:	0080                	addi	s0,sp,64
  oldsz = PGROUNDUP(oldsz);
    800014a0:	6a05                	lui	s4,0x1
    800014a2:	1a7d                	addi	s4,s4,-1
    800014a4:	95d2                	add	a1,a1,s4
    800014a6:	7a7d                	lui	s4,0xfffff
    800014a8:	0145fa33          	and	s4,a1,s4
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014ac:	08ca7263          	bleu	a2,s4,80001530 <uvmalloc+0xa6>
    800014b0:	89b2                	mv	s3,a2
    800014b2:	8aaa                	mv	s5,a0
    800014b4:	8952                	mv	s2,s4
    mem = kalloc();
    800014b6:	fffff097          	auipc	ra,0xfffff
    800014ba:	6c0080e7          	jalr	1728(ra) # 80000b76 <kalloc>
    800014be:	84aa                	mv	s1,a0
    if(mem == 0){
    800014c0:	c51d                	beqz	a0,800014ee <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800014c2:	6605                	lui	a2,0x1
    800014c4:	4581                	li	a1,0
    800014c6:	00000097          	auipc	ra,0x0
    800014ca:	89c080e7          	jalr	-1892(ra) # 80000d62 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014ce:	4779                	li	a4,30
    800014d0:	86a6                	mv	a3,s1
    800014d2:	6605                	lui	a2,0x1
    800014d4:	85ca                	mv	a1,s2
    800014d6:	8556                	mv	a0,s5
    800014d8:	00000097          	auipc	ra,0x0
    800014dc:	c82080e7          	jalr	-894(ra) # 8000115a <mappages>
    800014e0:	e905                	bnez	a0,80001510 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014e2:	6785                	lui	a5,0x1
    800014e4:	993e                	add	s2,s2,a5
    800014e6:	fd3968e3          	bltu	s2,s3,800014b6 <uvmalloc+0x2c>
  return newsz;
    800014ea:	854e                	mv	a0,s3
    800014ec:	a809                	j	800014fe <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800014ee:	8652                	mv	a2,s4
    800014f0:	85ca                	mv	a1,s2
    800014f2:	8556                	mv	a0,s5
    800014f4:	00000097          	auipc	ra,0x0
    800014f8:	f50080e7          	jalr	-176(ra) # 80001444 <uvmdealloc>
      return 0;
    800014fc:	4501                	li	a0,0
}
    800014fe:	70e2                	ld	ra,56(sp)
    80001500:	7442                	ld	s0,48(sp)
    80001502:	74a2                	ld	s1,40(sp)
    80001504:	7902                	ld	s2,32(sp)
    80001506:	69e2                	ld	s3,24(sp)
    80001508:	6a42                	ld	s4,16(sp)
    8000150a:	6aa2                	ld	s5,8(sp)
    8000150c:	6121                	addi	sp,sp,64
    8000150e:	8082                	ret
      kfree(mem);
    80001510:	8526                	mv	a0,s1
    80001512:	fffff097          	auipc	ra,0xfffff
    80001516:	564080e7          	jalr	1380(ra) # 80000a76 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000151a:	8652                	mv	a2,s4
    8000151c:	85ca                	mv	a1,s2
    8000151e:	8556                	mv	a0,s5
    80001520:	00000097          	auipc	ra,0x0
    80001524:	f24080e7          	jalr	-220(ra) # 80001444 <uvmdealloc>
      return 0;
    80001528:	4501                	li	a0,0
    8000152a:	bfd1                	j	800014fe <uvmalloc+0x74>
    return oldsz;
    8000152c:	852e                	mv	a0,a1
}
    8000152e:	8082                	ret
  return newsz;
    80001530:	8532                	mv	a0,a2
    80001532:	b7f1                	j	800014fe <uvmalloc+0x74>

0000000080001534 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001534:	7179                	addi	sp,sp,-48
    80001536:	f406                	sd	ra,40(sp)
    80001538:	f022                	sd	s0,32(sp)
    8000153a:	ec26                	sd	s1,24(sp)
    8000153c:	e84a                	sd	s2,16(sp)
    8000153e:	e44e                	sd	s3,8(sp)
    80001540:	e052                	sd	s4,0(sp)
    80001542:	1800                	addi	s0,sp,48
    80001544:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001546:	84aa                	mv	s1,a0
    80001548:	6905                	lui	s2,0x1
    8000154a:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000154c:	4985                	li	s3,1
    8000154e:	a821                	j	80001566 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001550:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001552:	0532                	slli	a0,a0,0xc
    80001554:	00000097          	auipc	ra,0x0
    80001558:	fe0080e7          	jalr	-32(ra) # 80001534 <freewalk>
      pagetable[i] = 0;
    8000155c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001560:	04a1                	addi	s1,s1,8
    80001562:	03248163          	beq	s1,s2,80001584 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001566:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001568:	00f57793          	andi	a5,a0,15
    8000156c:	ff3782e3          	beq	a5,s3,80001550 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001570:	8905                	andi	a0,a0,1
    80001572:	d57d                	beqz	a0,80001560 <freewalk+0x2c>
      panic("freewalk: leaf");
    80001574:	00007517          	auipc	a0,0x7
    80001578:	bec50513          	addi	a0,a0,-1044 # 80008160 <digits+0x148>
    8000157c:	fffff097          	auipc	ra,0xfffff
    80001580:	ffc080e7          	jalr	-4(ra) # 80000578 <panic>
    }
  }
  kfree((void*)pagetable);
    80001584:	8552                	mv	a0,s4
    80001586:	fffff097          	auipc	ra,0xfffff
    8000158a:	4f0080e7          	jalr	1264(ra) # 80000a76 <kfree>
}
    8000158e:	70a2                	ld	ra,40(sp)
    80001590:	7402                	ld	s0,32(sp)
    80001592:	64e2                	ld	s1,24(sp)
    80001594:	6942                	ld	s2,16(sp)
    80001596:	69a2                	ld	s3,8(sp)
    80001598:	6a02                	ld	s4,0(sp)
    8000159a:	6145                	addi	sp,sp,48
    8000159c:	8082                	ret

000000008000159e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000159e:	1101                	addi	sp,sp,-32
    800015a0:	ec06                	sd	ra,24(sp)
    800015a2:	e822                	sd	s0,16(sp)
    800015a4:	e426                	sd	s1,8(sp)
    800015a6:	1000                	addi	s0,sp,32
    800015a8:	84aa                	mv	s1,a0
  if(sz > 0)
    800015aa:	e999                	bnez	a1,800015c0 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015ac:	8526                	mv	a0,s1
    800015ae:	00000097          	auipc	ra,0x0
    800015b2:	f86080e7          	jalr	-122(ra) # 80001534 <freewalk>
}
    800015b6:	60e2                	ld	ra,24(sp)
    800015b8:	6442                	ld	s0,16(sp)
    800015ba:	64a2                	ld	s1,8(sp)
    800015bc:	6105                	addi	sp,sp,32
    800015be:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015c0:	6605                	lui	a2,0x1
    800015c2:	167d                	addi	a2,a2,-1
    800015c4:	962e                	add	a2,a2,a1
    800015c6:	4685                	li	a3,1
    800015c8:	8231                	srli	a2,a2,0xc
    800015ca:	4581                	li	a1,0
    800015cc:	00000097          	auipc	ra,0x0
    800015d0:	d12080e7          	jalr	-750(ra) # 800012de <uvmunmap>
    800015d4:	bfe1                	j	800015ac <uvmfree+0xe>

00000000800015d6 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015d6:	c679                	beqz	a2,800016a4 <uvmcopy+0xce>
{
    800015d8:	715d                	addi	sp,sp,-80
    800015da:	e486                	sd	ra,72(sp)
    800015dc:	e0a2                	sd	s0,64(sp)
    800015de:	fc26                	sd	s1,56(sp)
    800015e0:	f84a                	sd	s2,48(sp)
    800015e2:	f44e                	sd	s3,40(sp)
    800015e4:	f052                	sd	s4,32(sp)
    800015e6:	ec56                	sd	s5,24(sp)
    800015e8:	e85a                	sd	s6,16(sp)
    800015ea:	e45e                	sd	s7,8(sp)
    800015ec:	0880                	addi	s0,sp,80
    800015ee:	8ab2                	mv	s5,a2
    800015f0:	8b2e                	mv	s6,a1
    800015f2:	8baa                	mv	s7,a0
  for(i = 0; i < sz; i += PGSIZE){
    800015f4:	4901                	li	s2,0
    if((pte = walk(old, i, 0)) == 0)
    800015f6:	4601                	li	a2,0
    800015f8:	85ca                	mv	a1,s2
    800015fa:	855e                	mv	a0,s7
    800015fc:	00000097          	auipc	ra,0x0
    80001600:	a50080e7          	jalr	-1456(ra) # 8000104c <walk>
    80001604:	c531                	beqz	a0,80001650 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001606:	6118                	ld	a4,0(a0)
    80001608:	00177793          	andi	a5,a4,1
    8000160c:	cbb1                	beqz	a5,80001660 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000160e:	00a75593          	srli	a1,a4,0xa
    80001612:	00c59993          	slli	s3,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001616:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000161a:	fffff097          	auipc	ra,0xfffff
    8000161e:	55c080e7          	jalr	1372(ra) # 80000b76 <kalloc>
    80001622:	8a2a                	mv	s4,a0
    80001624:	c939                	beqz	a0,8000167a <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001626:	6605                	lui	a2,0x1
    80001628:	85ce                	mv	a1,s3
    8000162a:	fffff097          	auipc	ra,0xfffff
    8000162e:	7a4080e7          	jalr	1956(ra) # 80000dce <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001632:	8726                	mv	a4,s1
    80001634:	86d2                	mv	a3,s4
    80001636:	6605                	lui	a2,0x1
    80001638:	85ca                	mv	a1,s2
    8000163a:	855a                	mv	a0,s6
    8000163c:	00000097          	auipc	ra,0x0
    80001640:	b1e080e7          	jalr	-1250(ra) # 8000115a <mappages>
    80001644:	e515                	bnez	a0,80001670 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001646:	6785                	lui	a5,0x1
    80001648:	993e                	add	s2,s2,a5
    8000164a:	fb5966e3          	bltu	s2,s5,800015f6 <uvmcopy+0x20>
    8000164e:	a081                	j	8000168e <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001650:	00007517          	auipc	a0,0x7
    80001654:	b2050513          	addi	a0,a0,-1248 # 80008170 <digits+0x158>
    80001658:	fffff097          	auipc	ra,0xfffff
    8000165c:	f20080e7          	jalr	-224(ra) # 80000578 <panic>
      panic("uvmcopy: page not present");
    80001660:	00007517          	auipc	a0,0x7
    80001664:	b3050513          	addi	a0,a0,-1232 # 80008190 <digits+0x178>
    80001668:	fffff097          	auipc	ra,0xfffff
    8000166c:	f10080e7          	jalr	-240(ra) # 80000578 <panic>
      kfree(mem);
    80001670:	8552                	mv	a0,s4
    80001672:	fffff097          	auipc	ra,0xfffff
    80001676:	404080e7          	jalr	1028(ra) # 80000a76 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000167a:	4685                	li	a3,1
    8000167c:	00c95613          	srli	a2,s2,0xc
    80001680:	4581                	li	a1,0
    80001682:	855a                	mv	a0,s6
    80001684:	00000097          	auipc	ra,0x0
    80001688:	c5a080e7          	jalr	-934(ra) # 800012de <uvmunmap>
  return -1;
    8000168c:	557d                	li	a0,-1
}
    8000168e:	60a6                	ld	ra,72(sp)
    80001690:	6406                	ld	s0,64(sp)
    80001692:	74e2                	ld	s1,56(sp)
    80001694:	7942                	ld	s2,48(sp)
    80001696:	79a2                	ld	s3,40(sp)
    80001698:	7a02                	ld	s4,32(sp)
    8000169a:	6ae2                	ld	s5,24(sp)
    8000169c:	6b42                	ld	s6,16(sp)
    8000169e:	6ba2                	ld	s7,8(sp)
    800016a0:	6161                	addi	sp,sp,80
    800016a2:	8082                	ret
  return 0;
    800016a4:	4501                	li	a0,0
}
    800016a6:	8082                	ret

00000000800016a8 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016a8:	1141                	addi	sp,sp,-16
    800016aa:	e406                	sd	ra,8(sp)
    800016ac:	e022                	sd	s0,0(sp)
    800016ae:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016b0:	4601                	li	a2,0
    800016b2:	00000097          	auipc	ra,0x0
    800016b6:	99a080e7          	jalr	-1638(ra) # 8000104c <walk>
  if(pte == 0)
    800016ba:	c901                	beqz	a0,800016ca <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016bc:	611c                	ld	a5,0(a0)
    800016be:	9bbd                	andi	a5,a5,-17
    800016c0:	e11c                	sd	a5,0(a0)
}
    800016c2:	60a2                	ld	ra,8(sp)
    800016c4:	6402                	ld	s0,0(sp)
    800016c6:	0141                	addi	sp,sp,16
    800016c8:	8082                	ret
    panic("uvmclear");
    800016ca:	00007517          	auipc	a0,0x7
    800016ce:	ae650513          	addi	a0,a0,-1306 # 800081b0 <digits+0x198>
    800016d2:	fffff097          	auipc	ra,0xfffff
    800016d6:	ea6080e7          	jalr	-346(ra) # 80000578 <panic>

00000000800016da <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016da:	c6bd                	beqz	a3,80001748 <copyout+0x6e>
{
    800016dc:	715d                	addi	sp,sp,-80
    800016de:	e486                	sd	ra,72(sp)
    800016e0:	e0a2                	sd	s0,64(sp)
    800016e2:	fc26                	sd	s1,56(sp)
    800016e4:	f84a                	sd	s2,48(sp)
    800016e6:	f44e                	sd	s3,40(sp)
    800016e8:	f052                	sd	s4,32(sp)
    800016ea:	ec56                	sd	s5,24(sp)
    800016ec:	e85a                	sd	s6,16(sp)
    800016ee:	e45e                	sd	s7,8(sp)
    800016f0:	e062                	sd	s8,0(sp)
    800016f2:	0880                	addi	s0,sp,80
    800016f4:	8baa                	mv	s7,a0
    800016f6:	8a2e                	mv	s4,a1
    800016f8:	8ab2                	mv	s5,a2
    800016fa:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016fc:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016fe:	6b05                	lui	s6,0x1
    80001700:	a015                	j	80001724 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001702:	9552                	add	a0,a0,s4
    80001704:	0004861b          	sext.w	a2,s1
    80001708:	85d6                	mv	a1,s5
    8000170a:	41250533          	sub	a0,a0,s2
    8000170e:	fffff097          	auipc	ra,0xfffff
    80001712:	6c0080e7          	jalr	1728(ra) # 80000dce <memmove>

    len -= n;
    80001716:	409989b3          	sub	s3,s3,s1
    src += n;
    8000171a:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    8000171c:	01690a33          	add	s4,s2,s6
  while(len > 0){
    80001720:	02098263          	beqz	s3,80001744 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001724:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    80001728:	85ca                	mv	a1,s2
    8000172a:	855e                	mv	a0,s7
    8000172c:	00000097          	auipc	ra,0x0
    80001730:	9ec080e7          	jalr	-1556(ra) # 80001118 <walkaddr>
    if(pa0 == 0)
    80001734:	cd01                	beqz	a0,8000174c <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001736:	414904b3          	sub	s1,s2,s4
    8000173a:	94da                	add	s1,s1,s6
    if(n > len)
    8000173c:	fc99f3e3          	bleu	s1,s3,80001702 <copyout+0x28>
    80001740:	84ce                	mv	s1,s3
    80001742:	b7c1                	j	80001702 <copyout+0x28>
  }
  return 0;
    80001744:	4501                	li	a0,0
    80001746:	a021                	j	8000174e <copyout+0x74>
    80001748:	4501                	li	a0,0
}
    8000174a:	8082                	ret
      return -1;
    8000174c:	557d                	li	a0,-1
}
    8000174e:	60a6                	ld	ra,72(sp)
    80001750:	6406                	ld	s0,64(sp)
    80001752:	74e2                	ld	s1,56(sp)
    80001754:	7942                	ld	s2,48(sp)
    80001756:	79a2                	ld	s3,40(sp)
    80001758:	7a02                	ld	s4,32(sp)
    8000175a:	6ae2                	ld	s5,24(sp)
    8000175c:	6b42                	ld	s6,16(sp)
    8000175e:	6ba2                	ld	s7,8(sp)
    80001760:	6c02                	ld	s8,0(sp)
    80001762:	6161                	addi	sp,sp,80
    80001764:	8082                	ret

0000000080001766 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001766:	caa5                	beqz	a3,800017d6 <copyin+0x70>
{
    80001768:	715d                	addi	sp,sp,-80
    8000176a:	e486                	sd	ra,72(sp)
    8000176c:	e0a2                	sd	s0,64(sp)
    8000176e:	fc26                	sd	s1,56(sp)
    80001770:	f84a                	sd	s2,48(sp)
    80001772:	f44e                	sd	s3,40(sp)
    80001774:	f052                	sd	s4,32(sp)
    80001776:	ec56                	sd	s5,24(sp)
    80001778:	e85a                	sd	s6,16(sp)
    8000177a:	e45e                	sd	s7,8(sp)
    8000177c:	e062                	sd	s8,0(sp)
    8000177e:	0880                	addi	s0,sp,80
    80001780:	8baa                	mv	s7,a0
    80001782:	8aae                	mv	s5,a1
    80001784:	8a32                	mv	s4,a2
    80001786:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001788:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000178a:	6b05                	lui	s6,0x1
    8000178c:	a01d                	j	800017b2 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000178e:	014505b3          	add	a1,a0,s4
    80001792:	0004861b          	sext.w	a2,s1
    80001796:	412585b3          	sub	a1,a1,s2
    8000179a:	8556                	mv	a0,s5
    8000179c:	fffff097          	auipc	ra,0xfffff
    800017a0:	632080e7          	jalr	1586(ra) # 80000dce <memmove>

    len -= n;
    800017a4:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017a8:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    800017aa:	01690a33          	add	s4,s2,s6
  while(len > 0){
    800017ae:	02098263          	beqz	s3,800017d2 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017b2:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    800017b6:	85ca                	mv	a1,s2
    800017b8:	855e                	mv	a0,s7
    800017ba:	00000097          	auipc	ra,0x0
    800017be:	95e080e7          	jalr	-1698(ra) # 80001118 <walkaddr>
    if(pa0 == 0)
    800017c2:	cd01                	beqz	a0,800017da <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017c4:	414904b3          	sub	s1,s2,s4
    800017c8:	94da                	add	s1,s1,s6
    if(n > len)
    800017ca:	fc99f2e3          	bleu	s1,s3,8000178e <copyin+0x28>
    800017ce:	84ce                	mv	s1,s3
    800017d0:	bf7d                	j	8000178e <copyin+0x28>
  }
  return 0;
    800017d2:	4501                	li	a0,0
    800017d4:	a021                	j	800017dc <copyin+0x76>
    800017d6:	4501                	li	a0,0
}
    800017d8:	8082                	ret
      return -1;
    800017da:	557d                	li	a0,-1
}
    800017dc:	60a6                	ld	ra,72(sp)
    800017de:	6406                	ld	s0,64(sp)
    800017e0:	74e2                	ld	s1,56(sp)
    800017e2:	7942                	ld	s2,48(sp)
    800017e4:	79a2                	ld	s3,40(sp)
    800017e6:	7a02                	ld	s4,32(sp)
    800017e8:	6ae2                	ld	s5,24(sp)
    800017ea:	6b42                	ld	s6,16(sp)
    800017ec:	6ba2                	ld	s7,8(sp)
    800017ee:	6c02                	ld	s8,0(sp)
    800017f0:	6161                	addi	sp,sp,80
    800017f2:	8082                	ret

00000000800017f4 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017f4:	ced5                	beqz	a3,800018b0 <copyinstr+0xbc>
{
    800017f6:	715d                	addi	sp,sp,-80
    800017f8:	e486                	sd	ra,72(sp)
    800017fa:	e0a2                	sd	s0,64(sp)
    800017fc:	fc26                	sd	s1,56(sp)
    800017fe:	f84a                	sd	s2,48(sp)
    80001800:	f44e                	sd	s3,40(sp)
    80001802:	f052                	sd	s4,32(sp)
    80001804:	ec56                	sd	s5,24(sp)
    80001806:	e85a                	sd	s6,16(sp)
    80001808:	e45e                	sd	s7,8(sp)
    8000180a:	e062                	sd	s8,0(sp)
    8000180c:	0880                	addi	s0,sp,80
    8000180e:	8aaa                	mv	s5,a0
    80001810:	84ae                	mv	s1,a1
    80001812:	8c32                	mv	s8,a2
    80001814:	8bb6                	mv	s7,a3
    va0 = PGROUNDDOWN(srcva);
    80001816:	7a7d                	lui	s4,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001818:	6985                	lui	s3,0x1
    8000181a:	4b05                	li	s6,1
    8000181c:	a801                	j	8000182c <copyinstr+0x38>
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
    8000181e:	87a6                	mv	a5,s1
    80001820:	a085                	j	80001880 <copyinstr+0x8c>
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    80001822:	84b2                	mv	s1,a2
    }

    srcva = va0 + PGSIZE;
    80001824:	01390c33          	add	s8,s2,s3
  while(got_null == 0 && max > 0){
    80001828:	080b8063          	beqz	s7,800018a8 <copyinstr+0xb4>
    va0 = PGROUNDDOWN(srcva);
    8000182c:	014c7933          	and	s2,s8,s4
    pa0 = walkaddr(pagetable, va0);
    80001830:	85ca                	mv	a1,s2
    80001832:	8556                	mv	a0,s5
    80001834:	00000097          	auipc	ra,0x0
    80001838:	8e4080e7          	jalr	-1820(ra) # 80001118 <walkaddr>
    if(pa0 == 0)
    8000183c:	c925                	beqz	a0,800018ac <copyinstr+0xb8>
    n = PGSIZE - (srcva - va0);
    8000183e:	41890633          	sub	a2,s2,s8
    80001842:	964e                	add	a2,a2,s3
    if(n > max)
    80001844:	00cbf363          	bleu	a2,s7,8000184a <copyinstr+0x56>
    80001848:	865e                	mv	a2,s7
    char *p = (char *) (pa0 + (srcva - va0));
    8000184a:	9562                	add	a0,a0,s8
    8000184c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001850:	da71                	beqz	a2,80001824 <copyinstr+0x30>
      if(*p == '\0'){
    80001852:	00054703          	lbu	a4,0(a0)
    80001856:	d761                	beqz	a4,8000181e <copyinstr+0x2a>
    80001858:	9626                	add	a2,a2,s1
    8000185a:	87a6                	mv	a5,s1
    8000185c:	1bfd                	addi	s7,s7,-1
    8000185e:	009b86b3          	add	a3,s7,s1
    80001862:	409b04b3          	sub	s1,s6,s1
    80001866:	94aa                	add	s1,s1,a0
        *dst = *p;
    80001868:	00e78023          	sb	a4,0(a5) # 1000 <_entry-0x7ffff000>
      --max;
    8000186c:	40f68bb3          	sub	s7,a3,a5
      p++;
    80001870:	00f48733          	add	a4,s1,a5
      dst++;
    80001874:	0785                	addi	a5,a5,1
    while(n > 0){
    80001876:	faf606e3          	beq	a2,a5,80001822 <copyinstr+0x2e>
      if(*p == '\0'){
    8000187a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    8000187e:	f76d                	bnez	a4,80001868 <copyinstr+0x74>
        *dst = '\0';
    80001880:	00078023          	sb	zero,0(a5)
    80001884:	4785                	li	a5,1
  }
  if(got_null){
    80001886:	0017b513          	seqz	a0,a5
    8000188a:	40a0053b          	negw	a0,a0
    8000188e:	2501                	sext.w	a0,a0
    return 0;
  } else {
    return -1;
  }
}
    80001890:	60a6                	ld	ra,72(sp)
    80001892:	6406                	ld	s0,64(sp)
    80001894:	74e2                	ld	s1,56(sp)
    80001896:	7942                	ld	s2,48(sp)
    80001898:	79a2                	ld	s3,40(sp)
    8000189a:	7a02                	ld	s4,32(sp)
    8000189c:	6ae2                	ld	s5,24(sp)
    8000189e:	6b42                	ld	s6,16(sp)
    800018a0:	6ba2                	ld	s7,8(sp)
    800018a2:	6c02                	ld	s8,0(sp)
    800018a4:	6161                	addi	sp,sp,80
    800018a6:	8082                	ret
    800018a8:	4781                	li	a5,0
    800018aa:	bff1                	j	80001886 <copyinstr+0x92>
      return -1;
    800018ac:	557d                	li	a0,-1
    800018ae:	b7cd                	j	80001890 <copyinstr+0x9c>
  int got_null = 0;
    800018b0:	4781                	li	a5,0
  if(got_null){
    800018b2:	0017b513          	seqz	a0,a5
    800018b6:	40a0053b          	negw	a0,a0
    800018ba:	2501                	sext.w	a0,a0
}
    800018bc:	8082                	ret

00000000800018be <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800018be:	1101                	addi	sp,sp,-32
    800018c0:	ec06                	sd	ra,24(sp)
    800018c2:	e822                	sd	s0,16(sp)
    800018c4:	e426                	sd	s1,8(sp)
    800018c6:	1000                	addi	s0,sp,32
    800018c8:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800018ca:	fffff097          	auipc	ra,0xfffff
    800018ce:	322080e7          	jalr	802(ra) # 80000bec <holding>
    800018d2:	c909                	beqz	a0,800018e4 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800018d4:	749c                	ld	a5,40(s1)
    800018d6:	00978f63          	beq	a5,s1,800018f4 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    800018da:	60e2                	ld	ra,24(sp)
    800018dc:	6442                	ld	s0,16(sp)
    800018de:	64a2                	ld	s1,8(sp)
    800018e0:	6105                	addi	sp,sp,32
    800018e2:	8082                	ret
    panic("wakeup1");
    800018e4:	00007517          	auipc	a0,0x7
    800018e8:	90450513          	addi	a0,a0,-1788 # 800081e8 <states.1720+0x28>
    800018ec:	fffff097          	auipc	ra,0xfffff
    800018f0:	c8c080e7          	jalr	-884(ra) # 80000578 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    800018f4:	4c98                	lw	a4,24(s1)
    800018f6:	4785                	li	a5,1
    800018f8:	fef711e3          	bne	a4,a5,800018da <wakeup1+0x1c>
    p->state = RUNNABLE;
    800018fc:	4789                	li	a5,2
    800018fe:	cc9c                	sw	a5,24(s1)
}
    80001900:	bfe9                	j	800018da <wakeup1+0x1c>

0000000080001902 <procinit>:
{
    80001902:	715d                	addi	sp,sp,-80
    80001904:	e486                	sd	ra,72(sp)
    80001906:	e0a2                	sd	s0,64(sp)
    80001908:	fc26                	sd	s1,56(sp)
    8000190a:	f84a                	sd	s2,48(sp)
    8000190c:	f44e                	sd	s3,40(sp)
    8000190e:	f052                	sd	s4,32(sp)
    80001910:	ec56                	sd	s5,24(sp)
    80001912:	e85a                	sd	s6,16(sp)
    80001914:	e45e                	sd	s7,8(sp)
    80001916:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001918:	00007597          	auipc	a1,0x7
    8000191c:	8d858593          	addi	a1,a1,-1832 # 800081f0 <states.1720+0x30>
    80001920:	00010517          	auipc	a0,0x10
    80001924:	97050513          	addi	a0,a0,-1680 # 80011290 <pid_lock>
    80001928:	fffff097          	auipc	ra,0xfffff
    8000192c:	2ae080e7          	jalr	686(ra) # 80000bd6 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001930:	00010917          	auipc	s2,0x10
    80001934:	d7890913          	addi	s2,s2,-648 # 800116a8 <proc>
      initlock(&p->lock, "proc");
    80001938:	00007b97          	auipc	s7,0x7
    8000193c:	8c0b8b93          	addi	s7,s7,-1856 # 800081f8 <states.1720+0x38>
      uint64 va = KSTACK((int) (p - proc));
    80001940:	8b4a                	mv	s6,s2
    80001942:	00006a97          	auipc	s5,0x6
    80001946:	6bea8a93          	addi	s5,s5,1726 # 80008000 <etext>
    8000194a:	040009b7          	lui	s3,0x4000
    8000194e:	19fd                	addi	s3,s3,-1
    80001950:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001952:	00015a17          	auipc	s4,0x15
    80001956:	756a0a13          	addi	s4,s4,1878 # 800170a8 <tickslock>
      initlock(&p->lock, "proc");
    8000195a:	85de                	mv	a1,s7
    8000195c:	854a                	mv	a0,s2
    8000195e:	fffff097          	auipc	ra,0xfffff
    80001962:	278080e7          	jalr	632(ra) # 80000bd6 <initlock>
      char *pa = kalloc();
    80001966:	fffff097          	auipc	ra,0xfffff
    8000196a:	210080e7          	jalr	528(ra) # 80000b76 <kalloc>
    8000196e:	85aa                	mv	a1,a0
      if(pa == 0)
    80001970:	c929                	beqz	a0,800019c2 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001972:	416904b3          	sub	s1,s2,s6
    80001976:	848d                	srai	s1,s1,0x3
    80001978:	000ab783          	ld	a5,0(s5)
    8000197c:	02f484b3          	mul	s1,s1,a5
    80001980:	2485                	addiw	s1,s1,1
    80001982:	00d4949b          	slliw	s1,s1,0xd
    80001986:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000198a:	4699                	li	a3,6
    8000198c:	6605                	lui	a2,0x1
    8000198e:	8526                	mv	a0,s1
    80001990:	00000097          	auipc	ra,0x0
    80001994:	856080e7          	jalr	-1962(ra) # 800011e6 <kvmmap>
      p->kstack = va;
    80001998:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000199c:	16890913          	addi	s2,s2,360
    800019a0:	fb491de3          	bne	s2,s4,8000195a <procinit+0x58>
  kvminithart();
    800019a4:	fffff097          	auipc	ra,0xfffff
    800019a8:	74e080e7          	jalr	1870(ra) # 800010f2 <kvminithart>
}
    800019ac:	60a6                	ld	ra,72(sp)
    800019ae:	6406                	ld	s0,64(sp)
    800019b0:	74e2                	ld	s1,56(sp)
    800019b2:	7942                	ld	s2,48(sp)
    800019b4:	79a2                	ld	s3,40(sp)
    800019b6:	7a02                	ld	s4,32(sp)
    800019b8:	6ae2                	ld	s5,24(sp)
    800019ba:	6b42                	ld	s6,16(sp)
    800019bc:	6ba2                	ld	s7,8(sp)
    800019be:	6161                	addi	sp,sp,80
    800019c0:	8082                	ret
        panic("kalloc");
    800019c2:	00007517          	auipc	a0,0x7
    800019c6:	83e50513          	addi	a0,a0,-1986 # 80008200 <states.1720+0x40>
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	bae080e7          	jalr	-1106(ra) # 80000578 <panic>

00000000800019d2 <cpuid>:
{
    800019d2:	1141                	addi	sp,sp,-16
    800019d4:	e422                	sd	s0,8(sp)
    800019d6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019d8:	8512                	mv	a0,tp
}
    800019da:	2501                	sext.w	a0,a0
    800019dc:	6422                	ld	s0,8(sp)
    800019de:	0141                	addi	sp,sp,16
    800019e0:	8082                	ret

00000000800019e2 <mycpu>:
mycpu(void) {
    800019e2:	1141                	addi	sp,sp,-16
    800019e4:	e422                	sd	s0,8(sp)
    800019e6:	0800                	addi	s0,sp,16
    800019e8:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    800019ea:	2781                	sext.w	a5,a5
    800019ec:	079e                	slli	a5,a5,0x7
}
    800019ee:	00010517          	auipc	a0,0x10
    800019f2:	8ba50513          	addi	a0,a0,-1862 # 800112a8 <cpus>
    800019f6:	953e                	add	a0,a0,a5
    800019f8:	6422                	ld	s0,8(sp)
    800019fa:	0141                	addi	sp,sp,16
    800019fc:	8082                	ret

00000000800019fe <myproc>:
myproc(void) {
    800019fe:	1101                	addi	sp,sp,-32
    80001a00:	ec06                	sd	ra,24(sp)
    80001a02:	e822                	sd	s0,16(sp)
    80001a04:	e426                	sd	s1,8(sp)
    80001a06:	1000                	addi	s0,sp,32
  push_off();
    80001a08:	fffff097          	auipc	ra,0xfffff
    80001a0c:	212080e7          	jalr	530(ra) # 80000c1a <push_off>
    80001a10:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a12:	2781                	sext.w	a5,a5
    80001a14:	079e                	slli	a5,a5,0x7
    80001a16:	00010717          	auipc	a4,0x10
    80001a1a:	87a70713          	addi	a4,a4,-1926 # 80011290 <pid_lock>
    80001a1e:	97ba                	add	a5,a5,a4
    80001a20:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a22:	fffff097          	auipc	ra,0xfffff
    80001a26:	298080e7          	jalr	664(ra) # 80000cba <pop_off>
}
    80001a2a:	8526                	mv	a0,s1
    80001a2c:	60e2                	ld	ra,24(sp)
    80001a2e:	6442                	ld	s0,16(sp)
    80001a30:	64a2                	ld	s1,8(sp)
    80001a32:	6105                	addi	sp,sp,32
    80001a34:	8082                	ret

0000000080001a36 <forkret>:
{
    80001a36:	1141                	addi	sp,sp,-16
    80001a38:	e406                	sd	ra,8(sp)
    80001a3a:	e022                	sd	s0,0(sp)
    80001a3c:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a3e:	00000097          	auipc	ra,0x0
    80001a42:	fc0080e7          	jalr	-64(ra) # 800019fe <myproc>
    80001a46:	fffff097          	auipc	ra,0xfffff
    80001a4a:	2d4080e7          	jalr	724(ra) # 80000d1a <release>
  if (first) {
    80001a4e:	00007797          	auipc	a5,0x7
    80001a52:	db278793          	addi	a5,a5,-590 # 80008800 <first.1680>
    80001a56:	439c                	lw	a5,0(a5)
    80001a58:	eb89                	bnez	a5,80001a6a <forkret+0x34>
  usertrapret();
    80001a5a:	00001097          	auipc	ra,0x1
    80001a5e:	c26080e7          	jalr	-986(ra) # 80002680 <usertrapret>
}
    80001a62:	60a2                	ld	ra,8(sp)
    80001a64:	6402                	ld	s0,0(sp)
    80001a66:	0141                	addi	sp,sp,16
    80001a68:	8082                	ret
    first = 0;
    80001a6a:	00007797          	auipc	a5,0x7
    80001a6e:	d807ab23          	sw	zero,-618(a5) # 80008800 <first.1680>
    fsinit(ROOTDEV);
    80001a72:	4505                	li	a0,1
    80001a74:	00002097          	auipc	ra,0x2
    80001a78:	9a0080e7          	jalr	-1632(ra) # 80003414 <fsinit>
    80001a7c:	bff9                	j	80001a5a <forkret+0x24>

0000000080001a7e <allocpid>:
allocpid() {
    80001a7e:	1101                	addi	sp,sp,-32
    80001a80:	ec06                	sd	ra,24(sp)
    80001a82:	e822                	sd	s0,16(sp)
    80001a84:	e426                	sd	s1,8(sp)
    80001a86:	e04a                	sd	s2,0(sp)
    80001a88:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a8a:	00010917          	auipc	s2,0x10
    80001a8e:	80690913          	addi	s2,s2,-2042 # 80011290 <pid_lock>
    80001a92:	854a                	mv	a0,s2
    80001a94:	fffff097          	auipc	ra,0xfffff
    80001a98:	1d2080e7          	jalr	466(ra) # 80000c66 <acquire>
  pid = nextpid;
    80001a9c:	00007797          	auipc	a5,0x7
    80001aa0:	d6878793          	addi	a5,a5,-664 # 80008804 <nextpid>
    80001aa4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001aa6:	0014871b          	addiw	a4,s1,1
    80001aaa:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001aac:	854a                	mv	a0,s2
    80001aae:	fffff097          	auipc	ra,0xfffff
    80001ab2:	26c080e7          	jalr	620(ra) # 80000d1a <release>
}
    80001ab6:	8526                	mv	a0,s1
    80001ab8:	60e2                	ld	ra,24(sp)
    80001aba:	6442                	ld	s0,16(sp)
    80001abc:	64a2                	ld	s1,8(sp)
    80001abe:	6902                	ld	s2,0(sp)
    80001ac0:	6105                	addi	sp,sp,32
    80001ac2:	8082                	ret

0000000080001ac4 <proc_pagetable>:
{
    80001ac4:	1101                	addi	sp,sp,-32
    80001ac6:	ec06                	sd	ra,24(sp)
    80001ac8:	e822                	sd	s0,16(sp)
    80001aca:	e426                	sd	s1,8(sp)
    80001acc:	e04a                	sd	s2,0(sp)
    80001ace:	1000                	addi	s0,sp,32
    80001ad0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ad2:	00000097          	auipc	ra,0x0
    80001ad6:	8d2080e7          	jalr	-1838(ra) # 800013a4 <uvmcreate>
    80001ada:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001adc:	c121                	beqz	a0,80001b1c <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ade:	4729                	li	a4,10
    80001ae0:	00005697          	auipc	a3,0x5
    80001ae4:	52068693          	addi	a3,a3,1312 # 80007000 <_trampoline>
    80001ae8:	6605                	lui	a2,0x1
    80001aea:	040005b7          	lui	a1,0x4000
    80001aee:	15fd                	addi	a1,a1,-1
    80001af0:	05b2                	slli	a1,a1,0xc
    80001af2:	fffff097          	auipc	ra,0xfffff
    80001af6:	668080e7          	jalr	1640(ra) # 8000115a <mappages>
    80001afa:	02054863          	bltz	a0,80001b2a <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001afe:	4719                	li	a4,6
    80001b00:	05893683          	ld	a3,88(s2)
    80001b04:	6605                	lui	a2,0x1
    80001b06:	020005b7          	lui	a1,0x2000
    80001b0a:	15fd                	addi	a1,a1,-1
    80001b0c:	05b6                	slli	a1,a1,0xd
    80001b0e:	8526                	mv	a0,s1
    80001b10:	fffff097          	auipc	ra,0xfffff
    80001b14:	64a080e7          	jalr	1610(ra) # 8000115a <mappages>
    80001b18:	02054163          	bltz	a0,80001b3a <proc_pagetable+0x76>
}
    80001b1c:	8526                	mv	a0,s1
    80001b1e:	60e2                	ld	ra,24(sp)
    80001b20:	6442                	ld	s0,16(sp)
    80001b22:	64a2                	ld	s1,8(sp)
    80001b24:	6902                	ld	s2,0(sp)
    80001b26:	6105                	addi	sp,sp,32
    80001b28:	8082                	ret
    uvmfree(pagetable, 0);
    80001b2a:	4581                	li	a1,0
    80001b2c:	8526                	mv	a0,s1
    80001b2e:	00000097          	auipc	ra,0x0
    80001b32:	a70080e7          	jalr	-1424(ra) # 8000159e <uvmfree>
    return 0;
    80001b36:	4481                	li	s1,0
    80001b38:	b7d5                	j	80001b1c <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b3a:	4681                	li	a3,0
    80001b3c:	4605                	li	a2,1
    80001b3e:	040005b7          	lui	a1,0x4000
    80001b42:	15fd                	addi	a1,a1,-1
    80001b44:	05b2                	slli	a1,a1,0xc
    80001b46:	8526                	mv	a0,s1
    80001b48:	fffff097          	auipc	ra,0xfffff
    80001b4c:	796080e7          	jalr	1942(ra) # 800012de <uvmunmap>
    uvmfree(pagetable, 0);
    80001b50:	4581                	li	a1,0
    80001b52:	8526                	mv	a0,s1
    80001b54:	00000097          	auipc	ra,0x0
    80001b58:	a4a080e7          	jalr	-1462(ra) # 8000159e <uvmfree>
    return 0;
    80001b5c:	4481                	li	s1,0
    80001b5e:	bf7d                	j	80001b1c <proc_pagetable+0x58>

0000000080001b60 <proc_freepagetable>:
{
    80001b60:	1101                	addi	sp,sp,-32
    80001b62:	ec06                	sd	ra,24(sp)
    80001b64:	e822                	sd	s0,16(sp)
    80001b66:	e426                	sd	s1,8(sp)
    80001b68:	e04a                	sd	s2,0(sp)
    80001b6a:	1000                	addi	s0,sp,32
    80001b6c:	84aa                	mv	s1,a0
    80001b6e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b70:	4681                	li	a3,0
    80001b72:	4605                	li	a2,1
    80001b74:	040005b7          	lui	a1,0x4000
    80001b78:	15fd                	addi	a1,a1,-1
    80001b7a:	05b2                	slli	a1,a1,0xc
    80001b7c:	fffff097          	auipc	ra,0xfffff
    80001b80:	762080e7          	jalr	1890(ra) # 800012de <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b84:	4681                	li	a3,0
    80001b86:	4605                	li	a2,1
    80001b88:	020005b7          	lui	a1,0x2000
    80001b8c:	15fd                	addi	a1,a1,-1
    80001b8e:	05b6                	slli	a1,a1,0xd
    80001b90:	8526                	mv	a0,s1
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	74c080e7          	jalr	1868(ra) # 800012de <uvmunmap>
  uvmfree(pagetable, sz);
    80001b9a:	85ca                	mv	a1,s2
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	00000097          	auipc	ra,0x0
    80001ba2:	a00080e7          	jalr	-1536(ra) # 8000159e <uvmfree>
}
    80001ba6:	60e2                	ld	ra,24(sp)
    80001ba8:	6442                	ld	s0,16(sp)
    80001baa:	64a2                	ld	s1,8(sp)
    80001bac:	6902                	ld	s2,0(sp)
    80001bae:	6105                	addi	sp,sp,32
    80001bb0:	8082                	ret

0000000080001bb2 <freeproc>:
{
    80001bb2:	1101                	addi	sp,sp,-32
    80001bb4:	ec06                	sd	ra,24(sp)
    80001bb6:	e822                	sd	s0,16(sp)
    80001bb8:	e426                	sd	s1,8(sp)
    80001bba:	1000                	addi	s0,sp,32
    80001bbc:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bbe:	6d28                	ld	a0,88(a0)
    80001bc0:	c509                	beqz	a0,80001bca <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bc2:	fffff097          	auipc	ra,0xfffff
    80001bc6:	eb4080e7          	jalr	-332(ra) # 80000a76 <kfree>
  p->trapframe = 0;
    80001bca:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bce:	68a8                	ld	a0,80(s1)
    80001bd0:	c511                	beqz	a0,80001bdc <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bd2:	64ac                	ld	a1,72(s1)
    80001bd4:	00000097          	auipc	ra,0x0
    80001bd8:	f8c080e7          	jalr	-116(ra) # 80001b60 <proc_freepagetable>
  p->pagetable = 0;
    80001bdc:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001be0:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001be4:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001be8:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001bec:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bf0:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001bf4:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001bf8:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001bfc:	0004ac23          	sw	zero,24(s1)
}
    80001c00:	60e2                	ld	ra,24(sp)
    80001c02:	6442                	ld	s0,16(sp)
    80001c04:	64a2                	ld	s1,8(sp)
    80001c06:	6105                	addi	sp,sp,32
    80001c08:	8082                	ret

0000000080001c0a <allocproc>:
{
    80001c0a:	1101                	addi	sp,sp,-32
    80001c0c:	ec06                	sd	ra,24(sp)
    80001c0e:	e822                	sd	s0,16(sp)
    80001c10:	e426                	sd	s1,8(sp)
    80001c12:	e04a                	sd	s2,0(sp)
    80001c14:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c16:	00010497          	auipc	s1,0x10
    80001c1a:	a9248493          	addi	s1,s1,-1390 # 800116a8 <proc>
    80001c1e:	00015917          	auipc	s2,0x15
    80001c22:	48a90913          	addi	s2,s2,1162 # 800170a8 <tickslock>
    acquire(&p->lock);
    80001c26:	8526                	mv	a0,s1
    80001c28:	fffff097          	auipc	ra,0xfffff
    80001c2c:	03e080e7          	jalr	62(ra) # 80000c66 <acquire>
    if(p->state == UNUSED) {
    80001c30:	4c9c                	lw	a5,24(s1)
    80001c32:	cf81                	beqz	a5,80001c4a <allocproc+0x40>
      release(&p->lock);
    80001c34:	8526                	mv	a0,s1
    80001c36:	fffff097          	auipc	ra,0xfffff
    80001c3a:	0e4080e7          	jalr	228(ra) # 80000d1a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c3e:	16848493          	addi	s1,s1,360
    80001c42:	ff2492e3          	bne	s1,s2,80001c26 <allocproc+0x1c>
  return 0;
    80001c46:	4481                	li	s1,0
    80001c48:	a0b9                	j	80001c96 <allocproc+0x8c>
  p->pid = allocpid();
    80001c4a:	00000097          	auipc	ra,0x0
    80001c4e:	e34080e7          	jalr	-460(ra) # 80001a7e <allocpid>
    80001c52:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c54:	fffff097          	auipc	ra,0xfffff
    80001c58:	f22080e7          	jalr	-222(ra) # 80000b76 <kalloc>
    80001c5c:	892a                	mv	s2,a0
    80001c5e:	eca8                	sd	a0,88(s1)
    80001c60:	c131                	beqz	a0,80001ca4 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001c62:	8526                	mv	a0,s1
    80001c64:	00000097          	auipc	ra,0x0
    80001c68:	e60080e7          	jalr	-416(ra) # 80001ac4 <proc_pagetable>
    80001c6c:	892a                	mv	s2,a0
    80001c6e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c70:	c129                	beqz	a0,80001cb2 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001c72:	07000613          	li	a2,112
    80001c76:	4581                	li	a1,0
    80001c78:	06048513          	addi	a0,s1,96
    80001c7c:	fffff097          	auipc	ra,0xfffff
    80001c80:	0e6080e7          	jalr	230(ra) # 80000d62 <memset>
  p->context.ra = (uint64)forkret;
    80001c84:	00000797          	auipc	a5,0x0
    80001c88:	db278793          	addi	a5,a5,-590 # 80001a36 <forkret>
    80001c8c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c8e:	60bc                	ld	a5,64(s1)
    80001c90:	6705                	lui	a4,0x1
    80001c92:	97ba                	add	a5,a5,a4
    80001c94:	f4bc                	sd	a5,104(s1)
}
    80001c96:	8526                	mv	a0,s1
    80001c98:	60e2                	ld	ra,24(sp)
    80001c9a:	6442                	ld	s0,16(sp)
    80001c9c:	64a2                	ld	s1,8(sp)
    80001c9e:	6902                	ld	s2,0(sp)
    80001ca0:	6105                	addi	sp,sp,32
    80001ca2:	8082                	ret
    release(&p->lock);
    80001ca4:	8526                	mv	a0,s1
    80001ca6:	fffff097          	auipc	ra,0xfffff
    80001caa:	074080e7          	jalr	116(ra) # 80000d1a <release>
    return 0;
    80001cae:	84ca                	mv	s1,s2
    80001cb0:	b7dd                	j	80001c96 <allocproc+0x8c>
    freeproc(p);
    80001cb2:	8526                	mv	a0,s1
    80001cb4:	00000097          	auipc	ra,0x0
    80001cb8:	efe080e7          	jalr	-258(ra) # 80001bb2 <freeproc>
    release(&p->lock);
    80001cbc:	8526                	mv	a0,s1
    80001cbe:	fffff097          	auipc	ra,0xfffff
    80001cc2:	05c080e7          	jalr	92(ra) # 80000d1a <release>
    return 0;
    80001cc6:	84ca                	mv	s1,s2
    80001cc8:	b7f9                	j	80001c96 <allocproc+0x8c>

0000000080001cca <userinit>:
{
    80001cca:	1101                	addi	sp,sp,-32
    80001ccc:	ec06                	sd	ra,24(sp)
    80001cce:	e822                	sd	s0,16(sp)
    80001cd0:	e426                	sd	s1,8(sp)
    80001cd2:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cd4:	00000097          	auipc	ra,0x0
    80001cd8:	f36080e7          	jalr	-202(ra) # 80001c0a <allocproc>
    80001cdc:	84aa                	mv	s1,a0
  initproc = p;
    80001cde:	00007797          	auipc	a5,0x7
    80001ce2:	32a7bd23          	sd	a0,826(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001ce6:	03400613          	li	a2,52
    80001cea:	00007597          	auipc	a1,0x7
    80001cee:	b2658593          	addi	a1,a1,-1242 # 80008810 <initcode>
    80001cf2:	6928                	ld	a0,80(a0)
    80001cf4:	fffff097          	auipc	ra,0xfffff
    80001cf8:	6de080e7          	jalr	1758(ra) # 800013d2 <uvminit>
  p->sz = PGSIZE;
    80001cfc:	6785                	lui	a5,0x1
    80001cfe:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d00:	6cb8                	ld	a4,88(s1)
    80001d02:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d06:	6cb8                	ld	a4,88(s1)
    80001d08:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d0a:	4641                	li	a2,16
    80001d0c:	00006597          	auipc	a1,0x6
    80001d10:	4fc58593          	addi	a1,a1,1276 # 80008208 <states.1720+0x48>
    80001d14:	15848513          	addi	a0,s1,344
    80001d18:	fffff097          	auipc	ra,0xfffff
    80001d1c:	1c2080e7          	jalr	450(ra) # 80000eda <safestrcpy>
  p->cwd = namei("/");
    80001d20:	00006517          	auipc	a0,0x6
    80001d24:	4f850513          	addi	a0,a0,1272 # 80008218 <states.1720+0x58>
    80001d28:	00002097          	auipc	ra,0x2
    80001d2c:	124080e7          	jalr	292(ra) # 80003e4c <namei>
    80001d30:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d34:	4789                	li	a5,2
    80001d36:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d38:	8526                	mv	a0,s1
    80001d3a:	fffff097          	auipc	ra,0xfffff
    80001d3e:	fe0080e7          	jalr	-32(ra) # 80000d1a <release>
}
    80001d42:	60e2                	ld	ra,24(sp)
    80001d44:	6442                	ld	s0,16(sp)
    80001d46:	64a2                	ld	s1,8(sp)
    80001d48:	6105                	addi	sp,sp,32
    80001d4a:	8082                	ret

0000000080001d4c <growproc>:
{
    80001d4c:	1101                	addi	sp,sp,-32
    80001d4e:	ec06                	sd	ra,24(sp)
    80001d50:	e822                	sd	s0,16(sp)
    80001d52:	e426                	sd	s1,8(sp)
    80001d54:	e04a                	sd	s2,0(sp)
    80001d56:	1000                	addi	s0,sp,32
    80001d58:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d5a:	00000097          	auipc	ra,0x0
    80001d5e:	ca4080e7          	jalr	-860(ra) # 800019fe <myproc>
    80001d62:	892a                	mv	s2,a0
  sz = p->sz;
    80001d64:	652c                	ld	a1,72(a0)
    80001d66:	0005851b          	sext.w	a0,a1
  if(n > 0){
    80001d6a:	00904f63          	bgtz	s1,80001d88 <growproc+0x3c>
  } else if(n < 0){
    80001d6e:	0204cd63          	bltz	s1,80001da8 <growproc+0x5c>
  p->sz = sz;
    80001d72:	1502                	slli	a0,a0,0x20
    80001d74:	9101                	srli	a0,a0,0x20
    80001d76:	04a93423          	sd	a0,72(s2)
  return 0;
    80001d7a:	4501                	li	a0,0
}
    80001d7c:	60e2                	ld	ra,24(sp)
    80001d7e:	6442                	ld	s0,16(sp)
    80001d80:	64a2                	ld	s1,8(sp)
    80001d82:	6902                	ld	s2,0(sp)
    80001d84:	6105                	addi	sp,sp,32
    80001d86:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d88:	00a4863b          	addw	a2,s1,a0
    80001d8c:	1602                	slli	a2,a2,0x20
    80001d8e:	9201                	srli	a2,a2,0x20
    80001d90:	1582                	slli	a1,a1,0x20
    80001d92:	9181                	srli	a1,a1,0x20
    80001d94:	05093503          	ld	a0,80(s2)
    80001d98:	fffff097          	auipc	ra,0xfffff
    80001d9c:	6f2080e7          	jalr	1778(ra) # 8000148a <uvmalloc>
    80001da0:	2501                	sext.w	a0,a0
    80001da2:	f961                	bnez	a0,80001d72 <growproc+0x26>
      return -1;
    80001da4:	557d                	li	a0,-1
    80001da6:	bfd9                	j	80001d7c <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001da8:	00a4863b          	addw	a2,s1,a0
    80001dac:	1602                	slli	a2,a2,0x20
    80001dae:	9201                	srli	a2,a2,0x20
    80001db0:	1582                	slli	a1,a1,0x20
    80001db2:	9181                	srli	a1,a1,0x20
    80001db4:	05093503          	ld	a0,80(s2)
    80001db8:	fffff097          	auipc	ra,0xfffff
    80001dbc:	68c080e7          	jalr	1676(ra) # 80001444 <uvmdealloc>
    80001dc0:	2501                	sext.w	a0,a0
    80001dc2:	bf45                	j	80001d72 <growproc+0x26>

0000000080001dc4 <fork>:
{
    80001dc4:	7179                	addi	sp,sp,-48
    80001dc6:	f406                	sd	ra,40(sp)
    80001dc8:	f022                	sd	s0,32(sp)
    80001dca:	ec26                	sd	s1,24(sp)
    80001dcc:	e84a                	sd	s2,16(sp)
    80001dce:	e44e                	sd	s3,8(sp)
    80001dd0:	e052                	sd	s4,0(sp)
    80001dd2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dd4:	00000097          	auipc	ra,0x0
    80001dd8:	c2a080e7          	jalr	-982(ra) # 800019fe <myproc>
    80001ddc:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001dde:	00000097          	auipc	ra,0x0
    80001de2:	e2c080e7          	jalr	-468(ra) # 80001c0a <allocproc>
    80001de6:	c175                	beqz	a0,80001eca <fork+0x106>
    80001de8:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dea:	04893603          	ld	a2,72(s2)
    80001dee:	692c                	ld	a1,80(a0)
    80001df0:	05093503          	ld	a0,80(s2)
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	7e2080e7          	jalr	2018(ra) # 800015d6 <uvmcopy>
    80001dfc:	04054863          	bltz	a0,80001e4c <fork+0x88>
  np->sz = p->sz;
    80001e00:	04893783          	ld	a5,72(s2)
    80001e04:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80001e08:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e0c:	05893683          	ld	a3,88(s2)
    80001e10:	87b6                	mv	a5,a3
    80001e12:	0589b703          	ld	a4,88(s3)
    80001e16:	12068693          	addi	a3,a3,288
    80001e1a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e1e:	6788                	ld	a0,8(a5)
    80001e20:	6b8c                	ld	a1,16(a5)
    80001e22:	6f90                	ld	a2,24(a5)
    80001e24:	01073023          	sd	a6,0(a4)
    80001e28:	e708                	sd	a0,8(a4)
    80001e2a:	eb0c                	sd	a1,16(a4)
    80001e2c:	ef10                	sd	a2,24(a4)
    80001e2e:	02078793          	addi	a5,a5,32
    80001e32:	02070713          	addi	a4,a4,32
    80001e36:	fed792e3          	bne	a5,a3,80001e1a <fork+0x56>
  np->trapframe->a0 = 0;
    80001e3a:	0589b783          	ld	a5,88(s3)
    80001e3e:	0607b823          	sd	zero,112(a5)
    80001e42:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001e46:	15000a13          	li	s4,336
    80001e4a:	a03d                	j	80001e78 <fork+0xb4>
    freeproc(np);
    80001e4c:	854e                	mv	a0,s3
    80001e4e:	00000097          	auipc	ra,0x0
    80001e52:	d64080e7          	jalr	-668(ra) # 80001bb2 <freeproc>
    release(&np->lock);
    80001e56:	854e                	mv	a0,s3
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	ec2080e7          	jalr	-318(ra) # 80000d1a <release>
    return -1;
    80001e60:	54fd                	li	s1,-1
    80001e62:	a899                	j	80001eb8 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e64:	00002097          	auipc	ra,0x2
    80001e68:	6b8080e7          	jalr	1720(ra) # 8000451c <filedup>
    80001e6c:	009987b3          	add	a5,s3,s1
    80001e70:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001e72:	04a1                	addi	s1,s1,8
    80001e74:	01448763          	beq	s1,s4,80001e82 <fork+0xbe>
    if(p->ofile[i])
    80001e78:	009907b3          	add	a5,s2,s1
    80001e7c:	6388                	ld	a0,0(a5)
    80001e7e:	f17d                	bnez	a0,80001e64 <fork+0xa0>
    80001e80:	bfcd                	j	80001e72 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001e82:	15093503          	ld	a0,336(s2)
    80001e86:	00001097          	auipc	ra,0x1
    80001e8a:	7ca080e7          	jalr	1994(ra) # 80003650 <idup>
    80001e8e:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e92:	4641                	li	a2,16
    80001e94:	15890593          	addi	a1,s2,344
    80001e98:	15898513          	addi	a0,s3,344
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	03e080e7          	jalr	62(ra) # 80000eda <safestrcpy>
  pid = np->pid;
    80001ea4:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001ea8:	4789                	li	a5,2
    80001eaa:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001eae:	854e                	mv	a0,s3
    80001eb0:	fffff097          	auipc	ra,0xfffff
    80001eb4:	e6a080e7          	jalr	-406(ra) # 80000d1a <release>
}
    80001eb8:	8526                	mv	a0,s1
    80001eba:	70a2                	ld	ra,40(sp)
    80001ebc:	7402                	ld	s0,32(sp)
    80001ebe:	64e2                	ld	s1,24(sp)
    80001ec0:	6942                	ld	s2,16(sp)
    80001ec2:	69a2                	ld	s3,8(sp)
    80001ec4:	6a02                	ld	s4,0(sp)
    80001ec6:	6145                	addi	sp,sp,48
    80001ec8:	8082                	ret
    return -1;
    80001eca:	54fd                	li	s1,-1
    80001ecc:	b7f5                	j	80001eb8 <fork+0xf4>

0000000080001ece <reparent>:
{
    80001ece:	7179                	addi	sp,sp,-48
    80001ed0:	f406                	sd	ra,40(sp)
    80001ed2:	f022                	sd	s0,32(sp)
    80001ed4:	ec26                	sd	s1,24(sp)
    80001ed6:	e84a                	sd	s2,16(sp)
    80001ed8:	e44e                	sd	s3,8(sp)
    80001eda:	e052                	sd	s4,0(sp)
    80001edc:	1800                	addi	s0,sp,48
    80001ede:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ee0:	0000f497          	auipc	s1,0xf
    80001ee4:	7c848493          	addi	s1,s1,1992 # 800116a8 <proc>
      pp->parent = initproc;
    80001ee8:	00007a17          	auipc	s4,0x7
    80001eec:	130a0a13          	addi	s4,s4,304 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ef0:	00015917          	auipc	s2,0x15
    80001ef4:	1b890913          	addi	s2,s2,440 # 800170a8 <tickslock>
    80001ef8:	a029                	j	80001f02 <reparent+0x34>
    80001efa:	16848493          	addi	s1,s1,360
    80001efe:	03248363          	beq	s1,s2,80001f24 <reparent+0x56>
    if(pp->parent == p){
    80001f02:	709c                	ld	a5,32(s1)
    80001f04:	ff379be3          	bne	a5,s3,80001efa <reparent+0x2c>
      acquire(&pp->lock);
    80001f08:	8526                	mv	a0,s1
    80001f0a:	fffff097          	auipc	ra,0xfffff
    80001f0e:	d5c080e7          	jalr	-676(ra) # 80000c66 <acquire>
      pp->parent = initproc;
    80001f12:	000a3783          	ld	a5,0(s4)
    80001f16:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001f18:	8526                	mv	a0,s1
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	e00080e7          	jalr	-512(ra) # 80000d1a <release>
    80001f22:	bfe1                	j	80001efa <reparent+0x2c>
}
    80001f24:	70a2                	ld	ra,40(sp)
    80001f26:	7402                	ld	s0,32(sp)
    80001f28:	64e2                	ld	s1,24(sp)
    80001f2a:	6942                	ld	s2,16(sp)
    80001f2c:	69a2                	ld	s3,8(sp)
    80001f2e:	6a02                	ld	s4,0(sp)
    80001f30:	6145                	addi	sp,sp,48
    80001f32:	8082                	ret

0000000080001f34 <scheduler>:
{
    80001f34:	711d                	addi	sp,sp,-96
    80001f36:	ec86                	sd	ra,88(sp)
    80001f38:	e8a2                	sd	s0,80(sp)
    80001f3a:	e4a6                	sd	s1,72(sp)
    80001f3c:	e0ca                	sd	s2,64(sp)
    80001f3e:	fc4e                	sd	s3,56(sp)
    80001f40:	f852                	sd	s4,48(sp)
    80001f42:	f456                	sd	s5,40(sp)
    80001f44:	f05a                	sd	s6,32(sp)
    80001f46:	ec5e                	sd	s7,24(sp)
    80001f48:	e862                	sd	s8,16(sp)
    80001f4a:	e466                	sd	s9,8(sp)
    80001f4c:	1080                	addi	s0,sp,96
    80001f4e:	8792                	mv	a5,tp
  int id = r_tp();
    80001f50:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f52:	00779c13          	slli	s8,a5,0x7
    80001f56:	0000f717          	auipc	a4,0xf
    80001f5a:	33a70713          	addi	a4,a4,826 # 80011290 <pid_lock>
    80001f5e:	9762                	add	a4,a4,s8
    80001f60:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001f64:	0000f717          	auipc	a4,0xf
    80001f68:	34c70713          	addi	a4,a4,844 # 800112b0 <cpus+0x8>
    80001f6c:	9c3a                	add	s8,s8,a4
      if(p->state == RUNNABLE) {
    80001f6e:	4a89                	li	s5,2
        c->proc = p;
    80001f70:	079e                	slli	a5,a5,0x7
    80001f72:	0000fb17          	auipc	s6,0xf
    80001f76:	31eb0b13          	addi	s6,s6,798 # 80011290 <pid_lock>
    80001f7a:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f7c:	00015a17          	auipc	s4,0x15
    80001f80:	12ca0a13          	addi	s4,s4,300 # 800170a8 <tickslock>
    int nproc = 0;
    80001f84:	4c81                	li	s9,0
    80001f86:	a8a1                	j	80001fde <scheduler+0xaa>
        p->state = RUNNING;
    80001f88:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80001f8c:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    80001f90:	06048593          	addi	a1,s1,96
    80001f94:	8562                	mv	a0,s8
    80001f96:	00000097          	auipc	ra,0x0
    80001f9a:	640080e7          	jalr	1600(ra) # 800025d6 <swtch>
        c->proc = 0;
    80001f9e:	000b3c23          	sd	zero,24(s6)
      release(&p->lock);
    80001fa2:	8526                	mv	a0,s1
    80001fa4:	fffff097          	auipc	ra,0xfffff
    80001fa8:	d76080e7          	jalr	-650(ra) # 80000d1a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fac:	16848493          	addi	s1,s1,360
    80001fb0:	01448d63          	beq	s1,s4,80001fca <scheduler+0x96>
      acquire(&p->lock);
    80001fb4:	8526                	mv	a0,s1
    80001fb6:	fffff097          	auipc	ra,0xfffff
    80001fba:	cb0080e7          	jalr	-848(ra) # 80000c66 <acquire>
      if(p->state != UNUSED) {
    80001fbe:	4c9c                	lw	a5,24(s1)
    80001fc0:	d3ed                	beqz	a5,80001fa2 <scheduler+0x6e>
        nproc++;
    80001fc2:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    80001fc4:	fd579fe3          	bne	a5,s5,80001fa2 <scheduler+0x6e>
    80001fc8:	b7c1                	j	80001f88 <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    80001fca:	013aca63          	blt	s5,s3,80001fde <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fce:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fd2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fd6:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001fda:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fde:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fe2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fe6:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    80001fea:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fec:	0000f497          	auipc	s1,0xf
    80001ff0:	6bc48493          	addi	s1,s1,1724 # 800116a8 <proc>
        p->state = RUNNING;
    80001ff4:	4b8d                	li	s7,3
    80001ff6:	bf7d                	j	80001fb4 <scheduler+0x80>

0000000080001ff8 <sched>:
{
    80001ff8:	7179                	addi	sp,sp,-48
    80001ffa:	f406                	sd	ra,40(sp)
    80001ffc:	f022                	sd	s0,32(sp)
    80001ffe:	ec26                	sd	s1,24(sp)
    80002000:	e84a                	sd	s2,16(sp)
    80002002:	e44e                	sd	s3,8(sp)
    80002004:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002006:	00000097          	auipc	ra,0x0
    8000200a:	9f8080e7          	jalr	-1544(ra) # 800019fe <myproc>
    8000200e:	892a                	mv	s2,a0
  if(!holding(&p->lock))
    80002010:	fffff097          	auipc	ra,0xfffff
    80002014:	bdc080e7          	jalr	-1060(ra) # 80000bec <holding>
    80002018:	cd25                	beqz	a0,80002090 <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000201a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000201c:	2781                	sext.w	a5,a5
    8000201e:	079e                	slli	a5,a5,0x7
    80002020:	0000f717          	auipc	a4,0xf
    80002024:	27070713          	addi	a4,a4,624 # 80011290 <pid_lock>
    80002028:	97ba                	add	a5,a5,a4
    8000202a:	0907a703          	lw	a4,144(a5)
    8000202e:	4785                	li	a5,1
    80002030:	06f71863          	bne	a4,a5,800020a0 <sched+0xa8>
  if(p->state == RUNNING)
    80002034:	01892703          	lw	a4,24(s2)
    80002038:	478d                	li	a5,3
    8000203a:	06f70b63          	beq	a4,a5,800020b0 <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000203e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002042:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002044:	efb5                	bnez	a5,800020c0 <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002046:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002048:	0000f497          	auipc	s1,0xf
    8000204c:	24848493          	addi	s1,s1,584 # 80011290 <pid_lock>
    80002050:	2781                	sext.w	a5,a5
    80002052:	079e                	slli	a5,a5,0x7
    80002054:	97a6                	add	a5,a5,s1
    80002056:	0947a983          	lw	s3,148(a5)
    8000205a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000205c:	2781                	sext.w	a5,a5
    8000205e:	079e                	slli	a5,a5,0x7
    80002060:	0000f597          	auipc	a1,0xf
    80002064:	25058593          	addi	a1,a1,592 # 800112b0 <cpus+0x8>
    80002068:	95be                	add	a1,a1,a5
    8000206a:	06090513          	addi	a0,s2,96
    8000206e:	00000097          	auipc	ra,0x0
    80002072:	568080e7          	jalr	1384(ra) # 800025d6 <swtch>
    80002076:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002078:	2781                	sext.w	a5,a5
    8000207a:	079e                	slli	a5,a5,0x7
    8000207c:	97a6                	add	a5,a5,s1
    8000207e:	0937aa23          	sw	s3,148(a5)
}
    80002082:	70a2                	ld	ra,40(sp)
    80002084:	7402                	ld	s0,32(sp)
    80002086:	64e2                	ld	s1,24(sp)
    80002088:	6942                	ld	s2,16(sp)
    8000208a:	69a2                	ld	s3,8(sp)
    8000208c:	6145                	addi	sp,sp,48
    8000208e:	8082                	ret
    panic("sched p->lock");
    80002090:	00006517          	auipc	a0,0x6
    80002094:	19050513          	addi	a0,a0,400 # 80008220 <states.1720+0x60>
    80002098:	ffffe097          	auipc	ra,0xffffe
    8000209c:	4e0080e7          	jalr	1248(ra) # 80000578 <panic>
    panic("sched locks");
    800020a0:	00006517          	auipc	a0,0x6
    800020a4:	19050513          	addi	a0,a0,400 # 80008230 <states.1720+0x70>
    800020a8:	ffffe097          	auipc	ra,0xffffe
    800020ac:	4d0080e7          	jalr	1232(ra) # 80000578 <panic>
    panic("sched running");
    800020b0:	00006517          	auipc	a0,0x6
    800020b4:	19050513          	addi	a0,a0,400 # 80008240 <states.1720+0x80>
    800020b8:	ffffe097          	auipc	ra,0xffffe
    800020bc:	4c0080e7          	jalr	1216(ra) # 80000578 <panic>
    panic("sched interruptible");
    800020c0:	00006517          	auipc	a0,0x6
    800020c4:	19050513          	addi	a0,a0,400 # 80008250 <states.1720+0x90>
    800020c8:	ffffe097          	auipc	ra,0xffffe
    800020cc:	4b0080e7          	jalr	1200(ra) # 80000578 <panic>

00000000800020d0 <exit>:
{
    800020d0:	7179                	addi	sp,sp,-48
    800020d2:	f406                	sd	ra,40(sp)
    800020d4:	f022                	sd	s0,32(sp)
    800020d6:	ec26                	sd	s1,24(sp)
    800020d8:	e84a                	sd	s2,16(sp)
    800020da:	e44e                	sd	s3,8(sp)
    800020dc:	e052                	sd	s4,0(sp)
    800020de:	1800                	addi	s0,sp,48
    800020e0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020e2:	00000097          	auipc	ra,0x0
    800020e6:	91c080e7          	jalr	-1764(ra) # 800019fe <myproc>
    800020ea:	89aa                	mv	s3,a0
  if(p == initproc)
    800020ec:	00007797          	auipc	a5,0x7
    800020f0:	f2c78793          	addi	a5,a5,-212 # 80009018 <initproc>
    800020f4:	639c                	ld	a5,0(a5)
    800020f6:	0d050493          	addi	s1,a0,208
    800020fa:	15050913          	addi	s2,a0,336
    800020fe:	02a79363          	bne	a5,a0,80002124 <exit+0x54>
    panic("init exiting");
    80002102:	00006517          	auipc	a0,0x6
    80002106:	16650513          	addi	a0,a0,358 # 80008268 <states.1720+0xa8>
    8000210a:	ffffe097          	auipc	ra,0xffffe
    8000210e:	46e080e7          	jalr	1134(ra) # 80000578 <panic>
      fileclose(f);
    80002112:	00002097          	auipc	ra,0x2
    80002116:	45c080e7          	jalr	1116(ra) # 8000456e <fileclose>
      p->ofile[fd] = 0;
    8000211a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000211e:	04a1                	addi	s1,s1,8
    80002120:	01248563          	beq	s1,s2,8000212a <exit+0x5a>
    if(p->ofile[fd]){
    80002124:	6088                	ld	a0,0(s1)
    80002126:	f575                	bnez	a0,80002112 <exit+0x42>
    80002128:	bfdd                	j	8000211e <exit+0x4e>
  begin_op();
    8000212a:	00002097          	auipc	ra,0x2
    8000212e:	f40080e7          	jalr	-192(ra) # 8000406a <begin_op>
  iput(p->cwd);
    80002132:	1509b503          	ld	a0,336(s3)
    80002136:	00001097          	auipc	ra,0x1
    8000213a:	714080e7          	jalr	1812(ra) # 8000384a <iput>
  end_op();
    8000213e:	00002097          	auipc	ra,0x2
    80002142:	fac080e7          	jalr	-84(ra) # 800040ea <end_op>
  p->cwd = 0;
    80002146:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    8000214a:	00007497          	auipc	s1,0x7
    8000214e:	ece48493          	addi	s1,s1,-306 # 80009018 <initproc>
    80002152:	6088                	ld	a0,0(s1)
    80002154:	fffff097          	auipc	ra,0xfffff
    80002158:	b12080e7          	jalr	-1262(ra) # 80000c66 <acquire>
  wakeup1(initproc);
    8000215c:	6088                	ld	a0,0(s1)
    8000215e:	fffff097          	auipc	ra,0xfffff
    80002162:	760080e7          	jalr	1888(ra) # 800018be <wakeup1>
  release(&initproc->lock);
    80002166:	6088                	ld	a0,0(s1)
    80002168:	fffff097          	auipc	ra,0xfffff
    8000216c:	bb2080e7          	jalr	-1102(ra) # 80000d1a <release>
  acquire(&p->lock);
    80002170:	854e                	mv	a0,s3
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	af4080e7          	jalr	-1292(ra) # 80000c66 <acquire>
  struct proc *original_parent = p->parent;
    8000217a:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    8000217e:	854e                	mv	a0,s3
    80002180:	fffff097          	auipc	ra,0xfffff
    80002184:	b9a080e7          	jalr	-1126(ra) # 80000d1a <release>
  acquire(&original_parent->lock);
    80002188:	8526                	mv	a0,s1
    8000218a:	fffff097          	auipc	ra,0xfffff
    8000218e:	adc080e7          	jalr	-1316(ra) # 80000c66 <acquire>
  acquire(&p->lock);
    80002192:	854e                	mv	a0,s3
    80002194:	fffff097          	auipc	ra,0xfffff
    80002198:	ad2080e7          	jalr	-1326(ra) # 80000c66 <acquire>
  reparent(p);
    8000219c:	854e                	mv	a0,s3
    8000219e:	00000097          	auipc	ra,0x0
    800021a2:	d30080e7          	jalr	-720(ra) # 80001ece <reparent>
  wakeup1(original_parent);
    800021a6:	8526                	mv	a0,s1
    800021a8:	fffff097          	auipc	ra,0xfffff
    800021ac:	716080e7          	jalr	1814(ra) # 800018be <wakeup1>
  p->xstate = status;
    800021b0:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800021b4:	4791                	li	a5,4
    800021b6:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800021ba:	8526                	mv	a0,s1
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	b5e080e7          	jalr	-1186(ra) # 80000d1a <release>
  sched();
    800021c4:	00000097          	auipc	ra,0x0
    800021c8:	e34080e7          	jalr	-460(ra) # 80001ff8 <sched>
  panic("zombie exit");
    800021cc:	00006517          	auipc	a0,0x6
    800021d0:	0ac50513          	addi	a0,a0,172 # 80008278 <states.1720+0xb8>
    800021d4:	ffffe097          	auipc	ra,0xffffe
    800021d8:	3a4080e7          	jalr	932(ra) # 80000578 <panic>

00000000800021dc <yield>:
{
    800021dc:	1101                	addi	sp,sp,-32
    800021de:	ec06                	sd	ra,24(sp)
    800021e0:	e822                	sd	s0,16(sp)
    800021e2:	e426                	sd	s1,8(sp)
    800021e4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021e6:	00000097          	auipc	ra,0x0
    800021ea:	818080e7          	jalr	-2024(ra) # 800019fe <myproc>
    800021ee:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021f0:	fffff097          	auipc	ra,0xfffff
    800021f4:	a76080e7          	jalr	-1418(ra) # 80000c66 <acquire>
  p->state = RUNNABLE;
    800021f8:	4789                	li	a5,2
    800021fa:	cc9c                	sw	a5,24(s1)
  sched();
    800021fc:	00000097          	auipc	ra,0x0
    80002200:	dfc080e7          	jalr	-516(ra) # 80001ff8 <sched>
  release(&p->lock);
    80002204:	8526                	mv	a0,s1
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	b14080e7          	jalr	-1260(ra) # 80000d1a <release>
}
    8000220e:	60e2                	ld	ra,24(sp)
    80002210:	6442                	ld	s0,16(sp)
    80002212:	64a2                	ld	s1,8(sp)
    80002214:	6105                	addi	sp,sp,32
    80002216:	8082                	ret

0000000080002218 <sleep>:
{
    80002218:	7179                	addi	sp,sp,-48
    8000221a:	f406                	sd	ra,40(sp)
    8000221c:	f022                	sd	s0,32(sp)
    8000221e:	ec26                	sd	s1,24(sp)
    80002220:	e84a                	sd	s2,16(sp)
    80002222:	e44e                	sd	s3,8(sp)
    80002224:	1800                	addi	s0,sp,48
    80002226:	89aa                	mv	s3,a0
    80002228:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000222a:	fffff097          	auipc	ra,0xfffff
    8000222e:	7d4080e7          	jalr	2004(ra) # 800019fe <myproc>
    80002232:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002234:	05250663          	beq	a0,s2,80002280 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	a2e080e7          	jalr	-1490(ra) # 80000c66 <acquire>
    release(lk);
    80002240:	854a                	mv	a0,s2
    80002242:	fffff097          	auipc	ra,0xfffff
    80002246:	ad8080e7          	jalr	-1320(ra) # 80000d1a <release>
  p->chan = chan;
    8000224a:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    8000224e:	4785                	li	a5,1
    80002250:	cc9c                	sw	a5,24(s1)
  sched();
    80002252:	00000097          	auipc	ra,0x0
    80002256:	da6080e7          	jalr	-602(ra) # 80001ff8 <sched>
  p->chan = 0;
    8000225a:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    8000225e:	8526                	mv	a0,s1
    80002260:	fffff097          	auipc	ra,0xfffff
    80002264:	aba080e7          	jalr	-1350(ra) # 80000d1a <release>
    acquire(lk);
    80002268:	854a                	mv	a0,s2
    8000226a:	fffff097          	auipc	ra,0xfffff
    8000226e:	9fc080e7          	jalr	-1540(ra) # 80000c66 <acquire>
}
    80002272:	70a2                	ld	ra,40(sp)
    80002274:	7402                	ld	s0,32(sp)
    80002276:	64e2                	ld	s1,24(sp)
    80002278:	6942                	ld	s2,16(sp)
    8000227a:	69a2                	ld	s3,8(sp)
    8000227c:	6145                	addi	sp,sp,48
    8000227e:	8082                	ret
  p->chan = chan;
    80002280:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002284:	4785                	li	a5,1
    80002286:	cd1c                	sw	a5,24(a0)
  sched();
    80002288:	00000097          	auipc	ra,0x0
    8000228c:	d70080e7          	jalr	-656(ra) # 80001ff8 <sched>
  p->chan = 0;
    80002290:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002294:	bff9                	j	80002272 <sleep+0x5a>

0000000080002296 <wait>:
{
    80002296:	715d                	addi	sp,sp,-80
    80002298:	e486                	sd	ra,72(sp)
    8000229a:	e0a2                	sd	s0,64(sp)
    8000229c:	fc26                	sd	s1,56(sp)
    8000229e:	f84a                	sd	s2,48(sp)
    800022a0:	f44e                	sd	s3,40(sp)
    800022a2:	f052                	sd	s4,32(sp)
    800022a4:	ec56                	sd	s5,24(sp)
    800022a6:	e85a                	sd	s6,16(sp)
    800022a8:	e45e                	sd	s7,8(sp)
    800022aa:	e062                	sd	s8,0(sp)
    800022ac:	0880                	addi	s0,sp,80
    800022ae:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	74e080e7          	jalr	1870(ra) # 800019fe <myproc>
    800022b8:	892a                	mv	s2,a0
  acquire(&p->lock);
    800022ba:	8c2a                	mv	s8,a0
    800022bc:	fffff097          	auipc	ra,0xfffff
    800022c0:	9aa080e7          	jalr	-1622(ra) # 80000c66 <acquire>
    havekids = 0;
    800022c4:	4b01                	li	s6,0
        if(np->state == ZOMBIE){
    800022c6:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800022c8:	00015997          	auipc	s3,0x15
    800022cc:	de098993          	addi	s3,s3,-544 # 800170a8 <tickslock>
        havekids = 1;
    800022d0:	4a85                	li	s5,1
    havekids = 0;
    800022d2:	875a                	mv	a4,s6
    for(np = proc; np < &proc[NPROC]; np++){
    800022d4:	0000f497          	auipc	s1,0xf
    800022d8:	3d448493          	addi	s1,s1,980 # 800116a8 <proc>
    800022dc:	a08d                	j	8000233e <wait+0xa8>
          pid = np->pid;
    800022de:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022e2:	000b8e63          	beqz	s7,800022fe <wait+0x68>
    800022e6:	4691                	li	a3,4
    800022e8:	03448613          	addi	a2,s1,52
    800022ec:	85de                	mv	a1,s7
    800022ee:	05093503          	ld	a0,80(s2)
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	3e8080e7          	jalr	1000(ra) # 800016da <copyout>
    800022fa:	02054263          	bltz	a0,8000231e <wait+0x88>
          freeproc(np);
    800022fe:	8526                	mv	a0,s1
    80002300:	00000097          	auipc	ra,0x0
    80002304:	8b2080e7          	jalr	-1870(ra) # 80001bb2 <freeproc>
          release(&np->lock);
    80002308:	8526                	mv	a0,s1
    8000230a:	fffff097          	auipc	ra,0xfffff
    8000230e:	a10080e7          	jalr	-1520(ra) # 80000d1a <release>
          release(&p->lock);
    80002312:	854a                	mv	a0,s2
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	a06080e7          	jalr	-1530(ra) # 80000d1a <release>
          return pid;
    8000231c:	a8a9                	j	80002376 <wait+0xe0>
            release(&np->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	9fa080e7          	jalr	-1542(ra) # 80000d1a <release>
            release(&p->lock);
    80002328:	854a                	mv	a0,s2
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	9f0080e7          	jalr	-1552(ra) # 80000d1a <release>
            return -1;
    80002332:	59fd                	li	s3,-1
    80002334:	a089                	j	80002376 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002336:	16848493          	addi	s1,s1,360
    8000233a:	03348463          	beq	s1,s3,80002362 <wait+0xcc>
      if(np->parent == p){
    8000233e:	709c                	ld	a5,32(s1)
    80002340:	ff279be3          	bne	a5,s2,80002336 <wait+0xa0>
        acquire(&np->lock);
    80002344:	8526                	mv	a0,s1
    80002346:	fffff097          	auipc	ra,0xfffff
    8000234a:	920080e7          	jalr	-1760(ra) # 80000c66 <acquire>
        if(np->state == ZOMBIE){
    8000234e:	4c9c                	lw	a5,24(s1)
    80002350:	f94787e3          	beq	a5,s4,800022de <wait+0x48>
        release(&np->lock);
    80002354:	8526                	mv	a0,s1
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	9c4080e7          	jalr	-1596(ra) # 80000d1a <release>
        havekids = 1;
    8000235e:	8756                	mv	a4,s5
    80002360:	bfd9                	j	80002336 <wait+0xa0>
    if(!havekids || p->killed){
    80002362:	c701                	beqz	a4,8000236a <wait+0xd4>
    80002364:	03092783          	lw	a5,48(s2)
    80002368:	c785                	beqz	a5,80002390 <wait+0xfa>
      release(&p->lock);
    8000236a:	854a                	mv	a0,s2
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	9ae080e7          	jalr	-1618(ra) # 80000d1a <release>
      return -1;
    80002374:	59fd                	li	s3,-1
}
    80002376:	854e                	mv	a0,s3
    80002378:	60a6                	ld	ra,72(sp)
    8000237a:	6406                	ld	s0,64(sp)
    8000237c:	74e2                	ld	s1,56(sp)
    8000237e:	7942                	ld	s2,48(sp)
    80002380:	79a2                	ld	s3,40(sp)
    80002382:	7a02                	ld	s4,32(sp)
    80002384:	6ae2                	ld	s5,24(sp)
    80002386:	6b42                	ld	s6,16(sp)
    80002388:	6ba2                	ld	s7,8(sp)
    8000238a:	6c02                	ld	s8,0(sp)
    8000238c:	6161                	addi	sp,sp,80
    8000238e:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002390:	85e2                	mv	a1,s8
    80002392:	854a                	mv	a0,s2
    80002394:	00000097          	auipc	ra,0x0
    80002398:	e84080e7          	jalr	-380(ra) # 80002218 <sleep>
    havekids = 0;
    8000239c:	bf1d                	j	800022d2 <wait+0x3c>

000000008000239e <wakeup>:
{
    8000239e:	7139                	addi	sp,sp,-64
    800023a0:	fc06                	sd	ra,56(sp)
    800023a2:	f822                	sd	s0,48(sp)
    800023a4:	f426                	sd	s1,40(sp)
    800023a6:	f04a                	sd	s2,32(sp)
    800023a8:	ec4e                	sd	s3,24(sp)
    800023aa:	e852                	sd	s4,16(sp)
    800023ac:	e456                	sd	s5,8(sp)
    800023ae:	0080                	addi	s0,sp,64
    800023b0:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800023b2:	0000f497          	auipc	s1,0xf
    800023b6:	2f648493          	addi	s1,s1,758 # 800116a8 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800023ba:	4985                	li	s3,1
      p->state = RUNNABLE;
    800023bc:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800023be:	00015917          	auipc	s2,0x15
    800023c2:	cea90913          	addi	s2,s2,-790 # 800170a8 <tickslock>
    800023c6:	a821                	j	800023de <wakeup+0x40>
      p->state = RUNNABLE;
    800023c8:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    800023cc:	8526                	mv	a0,s1
    800023ce:	fffff097          	auipc	ra,0xfffff
    800023d2:	94c080e7          	jalr	-1716(ra) # 80000d1a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800023d6:	16848493          	addi	s1,s1,360
    800023da:	01248e63          	beq	s1,s2,800023f6 <wakeup+0x58>
    acquire(&p->lock);
    800023de:	8526                	mv	a0,s1
    800023e0:	fffff097          	auipc	ra,0xfffff
    800023e4:	886080e7          	jalr	-1914(ra) # 80000c66 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800023e8:	4c9c                	lw	a5,24(s1)
    800023ea:	ff3791e3          	bne	a5,s3,800023cc <wakeup+0x2e>
    800023ee:	749c                	ld	a5,40(s1)
    800023f0:	fd479ee3          	bne	a5,s4,800023cc <wakeup+0x2e>
    800023f4:	bfd1                	j	800023c8 <wakeup+0x2a>
}
    800023f6:	70e2                	ld	ra,56(sp)
    800023f8:	7442                	ld	s0,48(sp)
    800023fa:	74a2                	ld	s1,40(sp)
    800023fc:	7902                	ld	s2,32(sp)
    800023fe:	69e2                	ld	s3,24(sp)
    80002400:	6a42                	ld	s4,16(sp)
    80002402:	6aa2                	ld	s5,8(sp)
    80002404:	6121                	addi	sp,sp,64
    80002406:	8082                	ret

0000000080002408 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002408:	7179                	addi	sp,sp,-48
    8000240a:	f406                	sd	ra,40(sp)
    8000240c:	f022                	sd	s0,32(sp)
    8000240e:	ec26                	sd	s1,24(sp)
    80002410:	e84a                	sd	s2,16(sp)
    80002412:	e44e                	sd	s3,8(sp)
    80002414:	1800                	addi	s0,sp,48
    80002416:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002418:	0000f497          	auipc	s1,0xf
    8000241c:	29048493          	addi	s1,s1,656 # 800116a8 <proc>
    80002420:	00015997          	auipc	s3,0x15
    80002424:	c8898993          	addi	s3,s3,-888 # 800170a8 <tickslock>
    acquire(&p->lock);
    80002428:	8526                	mv	a0,s1
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	83c080e7          	jalr	-1988(ra) # 80000c66 <acquire>
    if(p->pid == pid){
    80002432:	5c9c                	lw	a5,56(s1)
    80002434:	01278d63          	beq	a5,s2,8000244e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002438:	8526                	mv	a0,s1
    8000243a:	fffff097          	auipc	ra,0xfffff
    8000243e:	8e0080e7          	jalr	-1824(ra) # 80000d1a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002442:	16848493          	addi	s1,s1,360
    80002446:	ff3491e3          	bne	s1,s3,80002428 <kill+0x20>
  }
  return -1;
    8000244a:	557d                	li	a0,-1
    8000244c:	a829                	j	80002466 <kill+0x5e>
      p->killed = 1;
    8000244e:	4785                	li	a5,1
    80002450:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002452:	4c98                	lw	a4,24(s1)
    80002454:	4785                	li	a5,1
    80002456:	00f70f63          	beq	a4,a5,80002474 <kill+0x6c>
      release(&p->lock);
    8000245a:	8526                	mv	a0,s1
    8000245c:	fffff097          	auipc	ra,0xfffff
    80002460:	8be080e7          	jalr	-1858(ra) # 80000d1a <release>
      return 0;
    80002464:	4501                	li	a0,0
}
    80002466:	70a2                	ld	ra,40(sp)
    80002468:	7402                	ld	s0,32(sp)
    8000246a:	64e2                	ld	s1,24(sp)
    8000246c:	6942                	ld	s2,16(sp)
    8000246e:	69a2                	ld	s3,8(sp)
    80002470:	6145                	addi	sp,sp,48
    80002472:	8082                	ret
        p->state = RUNNABLE;
    80002474:	4789                	li	a5,2
    80002476:	cc9c                	sw	a5,24(s1)
    80002478:	b7cd                	j	8000245a <kill+0x52>

000000008000247a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000247a:	7179                	addi	sp,sp,-48
    8000247c:	f406                	sd	ra,40(sp)
    8000247e:	f022                	sd	s0,32(sp)
    80002480:	ec26                	sd	s1,24(sp)
    80002482:	e84a                	sd	s2,16(sp)
    80002484:	e44e                	sd	s3,8(sp)
    80002486:	e052                	sd	s4,0(sp)
    80002488:	1800                	addi	s0,sp,48
    8000248a:	84aa                	mv	s1,a0
    8000248c:	892e                	mv	s2,a1
    8000248e:	89b2                	mv	s3,a2
    80002490:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002492:	fffff097          	auipc	ra,0xfffff
    80002496:	56c080e7          	jalr	1388(ra) # 800019fe <myproc>
  if(user_dst){
    8000249a:	c08d                	beqz	s1,800024bc <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000249c:	86d2                	mv	a3,s4
    8000249e:	864e                	mv	a2,s3
    800024a0:	85ca                	mv	a1,s2
    800024a2:	6928                	ld	a0,80(a0)
    800024a4:	fffff097          	auipc	ra,0xfffff
    800024a8:	236080e7          	jalr	566(ra) # 800016da <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024ac:	70a2                	ld	ra,40(sp)
    800024ae:	7402                	ld	s0,32(sp)
    800024b0:	64e2                	ld	s1,24(sp)
    800024b2:	6942                	ld	s2,16(sp)
    800024b4:	69a2                	ld	s3,8(sp)
    800024b6:	6a02                	ld	s4,0(sp)
    800024b8:	6145                	addi	sp,sp,48
    800024ba:	8082                	ret
    memmove((char *)dst, src, len);
    800024bc:	000a061b          	sext.w	a2,s4
    800024c0:	85ce                	mv	a1,s3
    800024c2:	854a                	mv	a0,s2
    800024c4:	fffff097          	auipc	ra,0xfffff
    800024c8:	90a080e7          	jalr	-1782(ra) # 80000dce <memmove>
    return 0;
    800024cc:	8526                	mv	a0,s1
    800024ce:	bff9                	j	800024ac <either_copyout+0x32>

00000000800024d0 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024d0:	7179                	addi	sp,sp,-48
    800024d2:	f406                	sd	ra,40(sp)
    800024d4:	f022                	sd	s0,32(sp)
    800024d6:	ec26                	sd	s1,24(sp)
    800024d8:	e84a                	sd	s2,16(sp)
    800024da:	e44e                	sd	s3,8(sp)
    800024dc:	e052                	sd	s4,0(sp)
    800024de:	1800                	addi	s0,sp,48
    800024e0:	892a                	mv	s2,a0
    800024e2:	84ae                	mv	s1,a1
    800024e4:	89b2                	mv	s3,a2
    800024e6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024e8:	fffff097          	auipc	ra,0xfffff
    800024ec:	516080e7          	jalr	1302(ra) # 800019fe <myproc>
  if(user_src){
    800024f0:	c08d                	beqz	s1,80002512 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024f2:	86d2                	mv	a3,s4
    800024f4:	864e                	mv	a2,s3
    800024f6:	85ca                	mv	a1,s2
    800024f8:	6928                	ld	a0,80(a0)
    800024fa:	fffff097          	auipc	ra,0xfffff
    800024fe:	26c080e7          	jalr	620(ra) # 80001766 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002502:	70a2                	ld	ra,40(sp)
    80002504:	7402                	ld	s0,32(sp)
    80002506:	64e2                	ld	s1,24(sp)
    80002508:	6942                	ld	s2,16(sp)
    8000250a:	69a2                	ld	s3,8(sp)
    8000250c:	6a02                	ld	s4,0(sp)
    8000250e:	6145                	addi	sp,sp,48
    80002510:	8082                	ret
    memmove(dst, (char*)src, len);
    80002512:	000a061b          	sext.w	a2,s4
    80002516:	85ce                	mv	a1,s3
    80002518:	854a                	mv	a0,s2
    8000251a:	fffff097          	auipc	ra,0xfffff
    8000251e:	8b4080e7          	jalr	-1868(ra) # 80000dce <memmove>
    return 0;
    80002522:	8526                	mv	a0,s1
    80002524:	bff9                	j	80002502 <either_copyin+0x32>

0000000080002526 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
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
    8000253a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000253c:	00006517          	auipc	a0,0x6
    80002540:	b8c50513          	addi	a0,a0,-1140 # 800080c8 <digits+0xb0>
    80002544:	ffffe097          	auipc	ra,0xffffe
    80002548:	07e080e7          	jalr	126(ra) # 800005c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000254c:	0000f497          	auipc	s1,0xf
    80002550:	2b448493          	addi	s1,s1,692 # 80011800 <proc+0x158>
    80002554:	00015917          	auipc	s2,0x15
    80002558:	cac90913          	addi	s2,s2,-852 # 80017200 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000255c:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    8000255e:	00006997          	auipc	s3,0x6
    80002562:	d2a98993          	addi	s3,s3,-726 # 80008288 <states.1720+0xc8>
    printf("%d %s %s", p->pid, state, p->name);
    80002566:	00006a97          	auipc	s5,0x6
    8000256a:	d2aa8a93          	addi	s5,s5,-726 # 80008290 <states.1720+0xd0>
    printf("\n");
    8000256e:	00006a17          	auipc	s4,0x6
    80002572:	b5aa0a13          	addi	s4,s4,-1190 # 800080c8 <digits+0xb0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002576:	00006b97          	auipc	s7,0x6
    8000257a:	c4ab8b93          	addi	s7,s7,-950 # 800081c0 <states.1720>
    8000257e:	a015                	j	800025a2 <procdump+0x7c>
    printf("%d %s %s", p->pid, state, p->name);
    80002580:	86ba                	mv	a3,a4
    80002582:	ee072583          	lw	a1,-288(a4)
    80002586:	8556                	mv	a0,s5
    80002588:	ffffe097          	auipc	ra,0xffffe
    8000258c:	03a080e7          	jalr	58(ra) # 800005c2 <printf>
    printf("\n");
    80002590:	8552                	mv	a0,s4
    80002592:	ffffe097          	auipc	ra,0xffffe
    80002596:	030080e7          	jalr	48(ra) # 800005c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000259a:	16848493          	addi	s1,s1,360
    8000259e:	03248163          	beq	s1,s2,800025c0 <procdump+0x9a>
    if(p->state == UNUSED)
    800025a2:	8726                	mv	a4,s1
    800025a4:	ec04a783          	lw	a5,-320(s1)
    800025a8:	dbed                	beqz	a5,8000259a <procdump+0x74>
      state = "???";
    800025aa:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ac:	fcfb6ae3          	bltu	s6,a5,80002580 <procdump+0x5a>
    800025b0:	1782                	slli	a5,a5,0x20
    800025b2:	9381                	srli	a5,a5,0x20
    800025b4:	078e                	slli	a5,a5,0x3
    800025b6:	97de                	add	a5,a5,s7
    800025b8:	6390                	ld	a2,0(a5)
    800025ba:	f279                	bnez	a2,80002580 <procdump+0x5a>
      state = "???";
    800025bc:	864e                	mv	a2,s3
    800025be:	b7c9                	j	80002580 <procdump+0x5a>
  }
}
    800025c0:	60a6                	ld	ra,72(sp)
    800025c2:	6406                	ld	s0,64(sp)
    800025c4:	74e2                	ld	s1,56(sp)
    800025c6:	7942                	ld	s2,48(sp)
    800025c8:	79a2                	ld	s3,40(sp)
    800025ca:	7a02                	ld	s4,32(sp)
    800025cc:	6ae2                	ld	s5,24(sp)
    800025ce:	6b42                	ld	s6,16(sp)
    800025d0:	6ba2                	ld	s7,8(sp)
    800025d2:	6161                	addi	sp,sp,80
    800025d4:	8082                	ret

00000000800025d6 <swtch>:
    800025d6:	00153023          	sd	ra,0(a0)
    800025da:	00253423          	sd	sp,8(a0)
    800025de:	e900                	sd	s0,16(a0)
    800025e0:	ed04                	sd	s1,24(a0)
    800025e2:	03253023          	sd	s2,32(a0)
    800025e6:	03353423          	sd	s3,40(a0)
    800025ea:	03453823          	sd	s4,48(a0)
    800025ee:	03553c23          	sd	s5,56(a0)
    800025f2:	05653023          	sd	s6,64(a0)
    800025f6:	05753423          	sd	s7,72(a0)
    800025fa:	05853823          	sd	s8,80(a0)
    800025fe:	05953c23          	sd	s9,88(a0)
    80002602:	07a53023          	sd	s10,96(a0)
    80002606:	07b53423          	sd	s11,104(a0)
    8000260a:	0005b083          	ld	ra,0(a1)
    8000260e:	0085b103          	ld	sp,8(a1)
    80002612:	6980                	ld	s0,16(a1)
    80002614:	6d84                	ld	s1,24(a1)
    80002616:	0205b903          	ld	s2,32(a1)
    8000261a:	0285b983          	ld	s3,40(a1)
    8000261e:	0305ba03          	ld	s4,48(a1)
    80002622:	0385ba83          	ld	s5,56(a1)
    80002626:	0405bb03          	ld	s6,64(a1)
    8000262a:	0485bb83          	ld	s7,72(a1)
    8000262e:	0505bc03          	ld	s8,80(a1)
    80002632:	0585bc83          	ld	s9,88(a1)
    80002636:	0605bd03          	ld	s10,96(a1)
    8000263a:	0685bd83          	ld	s11,104(a1)
    8000263e:	8082                	ret

0000000080002640 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002640:	1141                	addi	sp,sp,-16
    80002642:	e406                	sd	ra,8(sp)
    80002644:	e022                	sd	s0,0(sp)
    80002646:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002648:	00006597          	auipc	a1,0x6
    8000264c:	c8058593          	addi	a1,a1,-896 # 800082c8 <states.1720+0x108>
    80002650:	00015517          	auipc	a0,0x15
    80002654:	a5850513          	addi	a0,a0,-1448 # 800170a8 <tickslock>
    80002658:	ffffe097          	auipc	ra,0xffffe
    8000265c:	57e080e7          	jalr	1406(ra) # 80000bd6 <initlock>
}
    80002660:	60a2                	ld	ra,8(sp)
    80002662:	6402                	ld	s0,0(sp)
    80002664:	0141                	addi	sp,sp,16
    80002666:	8082                	ret

0000000080002668 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002668:	1141                	addi	sp,sp,-16
    8000266a:	e422                	sd	s0,8(sp)
    8000266c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000266e:	00003797          	auipc	a5,0x3
    80002672:	5b278793          	addi	a5,a5,1458 # 80005c20 <kernelvec>
    80002676:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000267a:	6422                	ld	s0,8(sp)
    8000267c:	0141                	addi	sp,sp,16
    8000267e:	8082                	ret

0000000080002680 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002680:	1141                	addi	sp,sp,-16
    80002682:	e406                	sd	ra,8(sp)
    80002684:	e022                	sd	s0,0(sp)
    80002686:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002688:	fffff097          	auipc	ra,0xfffff
    8000268c:	376080e7          	jalr	886(ra) # 800019fe <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002690:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002694:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002696:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000269a:	00005617          	auipc	a2,0x5
    8000269e:	96660613          	addi	a2,a2,-1690 # 80007000 <_trampoline>
    800026a2:	00005697          	auipc	a3,0x5
    800026a6:	95e68693          	addi	a3,a3,-1698 # 80007000 <_trampoline>
    800026aa:	8e91                	sub	a3,a3,a2
    800026ac:	040007b7          	lui	a5,0x4000
    800026b0:	17fd                	addi	a5,a5,-1
    800026b2:	07b2                	slli	a5,a5,0xc
    800026b4:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026b6:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026ba:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026bc:	180026f3          	csrr	a3,satp
    800026c0:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026c2:	6d38                	ld	a4,88(a0)
    800026c4:	6134                	ld	a3,64(a0)
    800026c6:	6585                	lui	a1,0x1
    800026c8:	96ae                	add	a3,a3,a1
    800026ca:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026cc:	6d38                	ld	a4,88(a0)
    800026ce:	00000697          	auipc	a3,0x0
    800026d2:	13868693          	addi	a3,a3,312 # 80002806 <usertrap>
    800026d6:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026d8:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026da:	8692                	mv	a3,tp
    800026dc:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026de:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026e2:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026e6:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026ea:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026ee:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026f0:	6f18                	ld	a4,24(a4)
    800026f2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026f6:	692c                	ld	a1,80(a0)
    800026f8:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800026fa:	00005717          	auipc	a4,0x5
    800026fe:	99670713          	addi	a4,a4,-1642 # 80007090 <userret>
    80002702:	8f11                	sub	a4,a4,a2
    80002704:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002706:	577d                	li	a4,-1
    80002708:	177e                	slli	a4,a4,0x3f
    8000270a:	8dd9                	or	a1,a1,a4
    8000270c:	02000537          	lui	a0,0x2000
    80002710:	157d                	addi	a0,a0,-1
    80002712:	0536                	slli	a0,a0,0xd
    80002714:	9782                	jalr	a5
}
    80002716:	60a2                	ld	ra,8(sp)
    80002718:	6402                	ld	s0,0(sp)
    8000271a:	0141                	addi	sp,sp,16
    8000271c:	8082                	ret

000000008000271e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000271e:	1101                	addi	sp,sp,-32
    80002720:	ec06                	sd	ra,24(sp)
    80002722:	e822                	sd	s0,16(sp)
    80002724:	e426                	sd	s1,8(sp)
    80002726:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002728:	00015497          	auipc	s1,0x15
    8000272c:	98048493          	addi	s1,s1,-1664 # 800170a8 <tickslock>
    80002730:	8526                	mv	a0,s1
    80002732:	ffffe097          	auipc	ra,0xffffe
    80002736:	534080e7          	jalr	1332(ra) # 80000c66 <acquire>
  ticks++;
    8000273a:	00007517          	auipc	a0,0x7
    8000273e:	8e650513          	addi	a0,a0,-1818 # 80009020 <ticks>
    80002742:	411c                	lw	a5,0(a0)
    80002744:	2785                	addiw	a5,a5,1
    80002746:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002748:	00000097          	auipc	ra,0x0
    8000274c:	c56080e7          	jalr	-938(ra) # 8000239e <wakeup>
  release(&tickslock);
    80002750:	8526                	mv	a0,s1
    80002752:	ffffe097          	auipc	ra,0xffffe
    80002756:	5c8080e7          	jalr	1480(ra) # 80000d1a <release>
}
    8000275a:	60e2                	ld	ra,24(sp)
    8000275c:	6442                	ld	s0,16(sp)
    8000275e:	64a2                	ld	s1,8(sp)
    80002760:	6105                	addi	sp,sp,32
    80002762:	8082                	ret

0000000080002764 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002764:	1101                	addi	sp,sp,-32
    80002766:	ec06                	sd	ra,24(sp)
    80002768:	e822                	sd	s0,16(sp)
    8000276a:	e426                	sd	s1,8(sp)
    8000276c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000276e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002772:	00074d63          	bltz	a4,8000278c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002776:	57fd                	li	a5,-1
    80002778:	17fe                	slli	a5,a5,0x3f
    8000277a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000277c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000277e:	06f70363          	beq	a4,a5,800027e4 <devintr+0x80>
  }
}
    80002782:	60e2                	ld	ra,24(sp)
    80002784:	6442                	ld	s0,16(sp)
    80002786:	64a2                	ld	s1,8(sp)
    80002788:	6105                	addi	sp,sp,32
    8000278a:	8082                	ret
     (scause & 0xff) == 9){
    8000278c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002790:	46a5                	li	a3,9
    80002792:	fed792e3          	bne	a5,a3,80002776 <devintr+0x12>
    int irq = plic_claim();
    80002796:	00003097          	auipc	ra,0x3
    8000279a:	592080e7          	jalr	1426(ra) # 80005d28 <plic_claim>
    8000279e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027a0:	47a9                	li	a5,10
    800027a2:	02f50763          	beq	a0,a5,800027d0 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800027a6:	4785                	li	a5,1
    800027a8:	02f50963          	beq	a0,a5,800027da <devintr+0x76>
    return 1;
    800027ac:	4505                	li	a0,1
    } else if(irq){
    800027ae:	d8f1                	beqz	s1,80002782 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800027b0:	85a6                	mv	a1,s1
    800027b2:	00006517          	auipc	a0,0x6
    800027b6:	b1e50513          	addi	a0,a0,-1250 # 800082d0 <states.1720+0x110>
    800027ba:	ffffe097          	auipc	ra,0xffffe
    800027be:	e08080e7          	jalr	-504(ra) # 800005c2 <printf>
      plic_complete(irq);
    800027c2:	8526                	mv	a0,s1
    800027c4:	00003097          	auipc	ra,0x3
    800027c8:	588080e7          	jalr	1416(ra) # 80005d4c <plic_complete>
    return 1;
    800027cc:	4505                	li	a0,1
    800027ce:	bf55                	j	80002782 <devintr+0x1e>
      uartintr();
    800027d0:	ffffe097          	auipc	ra,0xffffe
    800027d4:	256080e7          	jalr	598(ra) # 80000a26 <uartintr>
    800027d8:	b7ed                	j	800027c2 <devintr+0x5e>
      virtio_disk_intr();
    800027da:	00004097          	auipc	ra,0x4
    800027de:	a70080e7          	jalr	-1424(ra) # 8000624a <virtio_disk_intr>
    800027e2:	b7c5                	j	800027c2 <devintr+0x5e>
    if(cpuid() == 0){
    800027e4:	fffff097          	auipc	ra,0xfffff
    800027e8:	1ee080e7          	jalr	494(ra) # 800019d2 <cpuid>
    800027ec:	c901                	beqz	a0,800027fc <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027ee:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027f2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027f4:	14479073          	csrw	sip,a5
    return 2;
    800027f8:	4509                	li	a0,2
    800027fa:	b761                	j	80002782 <devintr+0x1e>
      clockintr();
    800027fc:	00000097          	auipc	ra,0x0
    80002800:	f22080e7          	jalr	-222(ra) # 8000271e <clockintr>
    80002804:	b7ed                	j	800027ee <devintr+0x8a>

0000000080002806 <usertrap>:
{
    80002806:	1101                	addi	sp,sp,-32
    80002808:	ec06                	sd	ra,24(sp)
    8000280a:	e822                	sd	s0,16(sp)
    8000280c:	e426                	sd	s1,8(sp)
    8000280e:	e04a                	sd	s2,0(sp)
    80002810:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002812:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002816:	1007f793          	andi	a5,a5,256
    8000281a:	e3ad                	bnez	a5,8000287c <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000281c:	00003797          	auipc	a5,0x3
    80002820:	40478793          	addi	a5,a5,1028 # 80005c20 <kernelvec>
    80002824:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002828:	fffff097          	auipc	ra,0xfffff
    8000282c:	1d6080e7          	jalr	470(ra) # 800019fe <myproc>
    80002830:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002832:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002834:	14102773          	csrr	a4,sepc
    80002838:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000283a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000283e:	47a1                	li	a5,8
    80002840:	04f71c63          	bne	a4,a5,80002898 <usertrap+0x92>
    if(p->killed)
    80002844:	591c                	lw	a5,48(a0)
    80002846:	e3b9                	bnez	a5,8000288c <usertrap+0x86>
    p->trapframe->epc += 4;
    80002848:	6cb8                	ld	a4,88(s1)
    8000284a:	6f1c                	ld	a5,24(a4)
    8000284c:	0791                	addi	a5,a5,4
    8000284e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002850:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002854:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002858:	10079073          	csrw	sstatus,a5
    syscall();
    8000285c:	00000097          	auipc	ra,0x0
    80002860:	2e6080e7          	jalr	742(ra) # 80002b42 <syscall>
  if(p->killed)
    80002864:	589c                	lw	a5,48(s1)
    80002866:	ebc1                	bnez	a5,800028f6 <usertrap+0xf0>
  usertrapret();
    80002868:	00000097          	auipc	ra,0x0
    8000286c:	e18080e7          	jalr	-488(ra) # 80002680 <usertrapret>
}
    80002870:	60e2                	ld	ra,24(sp)
    80002872:	6442                	ld	s0,16(sp)
    80002874:	64a2                	ld	s1,8(sp)
    80002876:	6902                	ld	s2,0(sp)
    80002878:	6105                	addi	sp,sp,32
    8000287a:	8082                	ret
    panic("usertrap: not from user mode");
    8000287c:	00006517          	auipc	a0,0x6
    80002880:	a7450513          	addi	a0,a0,-1420 # 800082f0 <states.1720+0x130>
    80002884:	ffffe097          	auipc	ra,0xffffe
    80002888:	cf4080e7          	jalr	-780(ra) # 80000578 <panic>
      exit(-1);
    8000288c:	557d                	li	a0,-1
    8000288e:	00000097          	auipc	ra,0x0
    80002892:	842080e7          	jalr	-1982(ra) # 800020d0 <exit>
    80002896:	bf4d                	j	80002848 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002898:	00000097          	auipc	ra,0x0
    8000289c:	ecc080e7          	jalr	-308(ra) # 80002764 <devintr>
    800028a0:	892a                	mv	s2,a0
    800028a2:	c501                	beqz	a0,800028aa <usertrap+0xa4>
  if(p->killed)
    800028a4:	589c                	lw	a5,48(s1)
    800028a6:	c3a1                	beqz	a5,800028e6 <usertrap+0xe0>
    800028a8:	a815                	j	800028dc <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028aa:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028ae:	5c90                	lw	a2,56(s1)
    800028b0:	00006517          	auipc	a0,0x6
    800028b4:	a6050513          	addi	a0,a0,-1440 # 80008310 <states.1720+0x150>
    800028b8:	ffffe097          	auipc	ra,0xffffe
    800028bc:	d0a080e7          	jalr	-758(ra) # 800005c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028c0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028c4:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028c8:	00006517          	auipc	a0,0x6
    800028cc:	a7850513          	addi	a0,a0,-1416 # 80008340 <states.1720+0x180>
    800028d0:	ffffe097          	auipc	ra,0xffffe
    800028d4:	cf2080e7          	jalr	-782(ra) # 800005c2 <printf>
    p->killed = 1;
    800028d8:	4785                	li	a5,1
    800028da:	d89c                	sw	a5,48(s1)
    exit(-1);
    800028dc:	557d                	li	a0,-1
    800028de:	fffff097          	auipc	ra,0xfffff
    800028e2:	7f2080e7          	jalr	2034(ra) # 800020d0 <exit>
  if(which_dev == 2)
    800028e6:	4789                	li	a5,2
    800028e8:	f8f910e3          	bne	s2,a5,80002868 <usertrap+0x62>
    yield();
    800028ec:	00000097          	auipc	ra,0x0
    800028f0:	8f0080e7          	jalr	-1808(ra) # 800021dc <yield>
    800028f4:	bf95                	j	80002868 <usertrap+0x62>
  int which_dev = 0;
    800028f6:	4901                	li	s2,0
    800028f8:	b7d5                	j	800028dc <usertrap+0xd6>

00000000800028fa <kerneltrap>:
{
    800028fa:	7179                	addi	sp,sp,-48
    800028fc:	f406                	sd	ra,40(sp)
    800028fe:	f022                	sd	s0,32(sp)
    80002900:	ec26                	sd	s1,24(sp)
    80002902:	e84a                	sd	s2,16(sp)
    80002904:	e44e                	sd	s3,8(sp)
    80002906:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002908:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000290c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002910:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002914:	1004f793          	andi	a5,s1,256
    80002918:	cb85                	beqz	a5,80002948 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000291a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000291e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002920:	ef85                	bnez	a5,80002958 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002922:	00000097          	auipc	ra,0x0
    80002926:	e42080e7          	jalr	-446(ra) # 80002764 <devintr>
    8000292a:	cd1d                	beqz	a0,80002968 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000292c:	4789                	li	a5,2
    8000292e:	06f50a63          	beq	a0,a5,800029a2 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002932:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002936:	10049073          	csrw	sstatus,s1
}
    8000293a:	70a2                	ld	ra,40(sp)
    8000293c:	7402                	ld	s0,32(sp)
    8000293e:	64e2                	ld	s1,24(sp)
    80002940:	6942                	ld	s2,16(sp)
    80002942:	69a2                	ld	s3,8(sp)
    80002944:	6145                	addi	sp,sp,48
    80002946:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002948:	00006517          	auipc	a0,0x6
    8000294c:	a1850513          	addi	a0,a0,-1512 # 80008360 <states.1720+0x1a0>
    80002950:	ffffe097          	auipc	ra,0xffffe
    80002954:	c28080e7          	jalr	-984(ra) # 80000578 <panic>
    panic("kerneltrap: interrupts enabled");
    80002958:	00006517          	auipc	a0,0x6
    8000295c:	a3050513          	addi	a0,a0,-1488 # 80008388 <states.1720+0x1c8>
    80002960:	ffffe097          	auipc	ra,0xffffe
    80002964:	c18080e7          	jalr	-1000(ra) # 80000578 <panic>
    printf("scause %p\n", scause);
    80002968:	85ce                	mv	a1,s3
    8000296a:	00006517          	auipc	a0,0x6
    8000296e:	a3e50513          	addi	a0,a0,-1474 # 800083a8 <states.1720+0x1e8>
    80002972:	ffffe097          	auipc	ra,0xffffe
    80002976:	c50080e7          	jalr	-944(ra) # 800005c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000297a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000297e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002982:	00006517          	auipc	a0,0x6
    80002986:	a3650513          	addi	a0,a0,-1482 # 800083b8 <states.1720+0x1f8>
    8000298a:	ffffe097          	auipc	ra,0xffffe
    8000298e:	c38080e7          	jalr	-968(ra) # 800005c2 <printf>
    panic("kerneltrap");
    80002992:	00006517          	auipc	a0,0x6
    80002996:	a3e50513          	addi	a0,a0,-1474 # 800083d0 <states.1720+0x210>
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	bde080e7          	jalr	-1058(ra) # 80000578 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029a2:	fffff097          	auipc	ra,0xfffff
    800029a6:	05c080e7          	jalr	92(ra) # 800019fe <myproc>
    800029aa:	d541                	beqz	a0,80002932 <kerneltrap+0x38>
    800029ac:	fffff097          	auipc	ra,0xfffff
    800029b0:	052080e7          	jalr	82(ra) # 800019fe <myproc>
    800029b4:	4d18                	lw	a4,24(a0)
    800029b6:	478d                	li	a5,3
    800029b8:	f6f71de3          	bne	a4,a5,80002932 <kerneltrap+0x38>
    yield();
    800029bc:	00000097          	auipc	ra,0x0
    800029c0:	820080e7          	jalr	-2016(ra) # 800021dc <yield>
    800029c4:	b7bd                	j	80002932 <kerneltrap+0x38>

00000000800029c6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029c6:	1101                	addi	sp,sp,-32
    800029c8:	ec06                	sd	ra,24(sp)
    800029ca:	e822                	sd	s0,16(sp)
    800029cc:	e426                	sd	s1,8(sp)
    800029ce:	1000                	addi	s0,sp,32
    800029d0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029d2:	fffff097          	auipc	ra,0xfffff
    800029d6:	02c080e7          	jalr	44(ra) # 800019fe <myproc>
  switch (n) {
    800029da:	4795                	li	a5,5
    800029dc:	0497e363          	bltu	a5,s1,80002a22 <argraw+0x5c>
    800029e0:	1482                	slli	s1,s1,0x20
    800029e2:	9081                	srli	s1,s1,0x20
    800029e4:	048a                	slli	s1,s1,0x2
    800029e6:	00006717          	auipc	a4,0x6
    800029ea:	9fa70713          	addi	a4,a4,-1542 # 800083e0 <states.1720+0x220>
    800029ee:	94ba                	add	s1,s1,a4
    800029f0:	409c                	lw	a5,0(s1)
    800029f2:	97ba                	add	a5,a5,a4
    800029f4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029f6:	6d3c                	ld	a5,88(a0)
    800029f8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029fa:	60e2                	ld	ra,24(sp)
    800029fc:	6442                	ld	s0,16(sp)
    800029fe:	64a2                	ld	s1,8(sp)
    80002a00:	6105                	addi	sp,sp,32
    80002a02:	8082                	ret
    return p->trapframe->a1;
    80002a04:	6d3c                	ld	a5,88(a0)
    80002a06:	7fa8                	ld	a0,120(a5)
    80002a08:	bfcd                	j	800029fa <argraw+0x34>
    return p->trapframe->a2;
    80002a0a:	6d3c                	ld	a5,88(a0)
    80002a0c:	63c8                	ld	a0,128(a5)
    80002a0e:	b7f5                	j	800029fa <argraw+0x34>
    return p->trapframe->a3;
    80002a10:	6d3c                	ld	a5,88(a0)
    80002a12:	67c8                	ld	a0,136(a5)
    80002a14:	b7dd                	j	800029fa <argraw+0x34>
    return p->trapframe->a4;
    80002a16:	6d3c                	ld	a5,88(a0)
    80002a18:	6bc8                	ld	a0,144(a5)
    80002a1a:	b7c5                	j	800029fa <argraw+0x34>
    return p->trapframe->a5;
    80002a1c:	6d3c                	ld	a5,88(a0)
    80002a1e:	6fc8                	ld	a0,152(a5)
    80002a20:	bfe9                	j	800029fa <argraw+0x34>
  panic("argraw");
    80002a22:	00006517          	auipc	a0,0x6
    80002a26:	a8650513          	addi	a0,a0,-1402 # 800084a8 <syscalls+0xb0>
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	b4e080e7          	jalr	-1202(ra) # 80000578 <panic>

0000000080002a32 <fetchaddr>:
{
    80002a32:	1101                	addi	sp,sp,-32
    80002a34:	ec06                	sd	ra,24(sp)
    80002a36:	e822                	sd	s0,16(sp)
    80002a38:	e426                	sd	s1,8(sp)
    80002a3a:	e04a                	sd	s2,0(sp)
    80002a3c:	1000                	addi	s0,sp,32
    80002a3e:	84aa                	mv	s1,a0
    80002a40:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a42:	fffff097          	auipc	ra,0xfffff
    80002a46:	fbc080e7          	jalr	-68(ra) # 800019fe <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a4a:	653c                	ld	a5,72(a0)
    80002a4c:	02f4f963          	bleu	a5,s1,80002a7e <fetchaddr+0x4c>
    80002a50:	00848713          	addi	a4,s1,8
    80002a54:	02e7e763          	bltu	a5,a4,80002a82 <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a58:	46a1                	li	a3,8
    80002a5a:	8626                	mv	a2,s1
    80002a5c:	85ca                	mv	a1,s2
    80002a5e:	6928                	ld	a0,80(a0)
    80002a60:	fffff097          	auipc	ra,0xfffff
    80002a64:	d06080e7          	jalr	-762(ra) # 80001766 <copyin>
    80002a68:	00a03533          	snez	a0,a0
    80002a6c:	40a0053b          	negw	a0,a0
    80002a70:	2501                	sext.w	a0,a0
}
    80002a72:	60e2                	ld	ra,24(sp)
    80002a74:	6442                	ld	s0,16(sp)
    80002a76:	64a2                	ld	s1,8(sp)
    80002a78:	6902                	ld	s2,0(sp)
    80002a7a:	6105                	addi	sp,sp,32
    80002a7c:	8082                	ret
    return -1;
    80002a7e:	557d                	li	a0,-1
    80002a80:	bfcd                	j	80002a72 <fetchaddr+0x40>
    80002a82:	557d                	li	a0,-1
    80002a84:	b7fd                	j	80002a72 <fetchaddr+0x40>

0000000080002a86 <fetchstr>:
{
    80002a86:	7179                	addi	sp,sp,-48
    80002a88:	f406                	sd	ra,40(sp)
    80002a8a:	f022                	sd	s0,32(sp)
    80002a8c:	ec26                	sd	s1,24(sp)
    80002a8e:	e84a                	sd	s2,16(sp)
    80002a90:	e44e                	sd	s3,8(sp)
    80002a92:	1800                	addi	s0,sp,48
    80002a94:	892a                	mv	s2,a0
    80002a96:	84ae                	mv	s1,a1
    80002a98:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a9a:	fffff097          	auipc	ra,0xfffff
    80002a9e:	f64080e7          	jalr	-156(ra) # 800019fe <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002aa2:	86ce                	mv	a3,s3
    80002aa4:	864a                	mv	a2,s2
    80002aa6:	85a6                	mv	a1,s1
    80002aa8:	6928                	ld	a0,80(a0)
    80002aaa:	fffff097          	auipc	ra,0xfffff
    80002aae:	d4a080e7          	jalr	-694(ra) # 800017f4 <copyinstr>
  if(err < 0)
    80002ab2:	00054763          	bltz	a0,80002ac0 <fetchstr+0x3a>
  return strlen(buf);
    80002ab6:	8526                	mv	a0,s1
    80002ab8:	ffffe097          	auipc	ra,0xffffe
    80002abc:	454080e7          	jalr	1108(ra) # 80000f0c <strlen>
}
    80002ac0:	70a2                	ld	ra,40(sp)
    80002ac2:	7402                	ld	s0,32(sp)
    80002ac4:	64e2                	ld	s1,24(sp)
    80002ac6:	6942                	ld	s2,16(sp)
    80002ac8:	69a2                	ld	s3,8(sp)
    80002aca:	6145                	addi	sp,sp,48
    80002acc:	8082                	ret

0000000080002ace <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002ace:	1101                	addi	sp,sp,-32
    80002ad0:	ec06                	sd	ra,24(sp)
    80002ad2:	e822                	sd	s0,16(sp)
    80002ad4:	e426                	sd	s1,8(sp)
    80002ad6:	1000                	addi	s0,sp,32
    80002ad8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ada:	00000097          	auipc	ra,0x0
    80002ade:	eec080e7          	jalr	-276(ra) # 800029c6 <argraw>
    80002ae2:	c088                	sw	a0,0(s1)
  return 0;
}
    80002ae4:	4501                	li	a0,0
    80002ae6:	60e2                	ld	ra,24(sp)
    80002ae8:	6442                	ld	s0,16(sp)
    80002aea:	64a2                	ld	s1,8(sp)
    80002aec:	6105                	addi	sp,sp,32
    80002aee:	8082                	ret

0000000080002af0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002af0:	1101                	addi	sp,sp,-32
    80002af2:	ec06                	sd	ra,24(sp)
    80002af4:	e822                	sd	s0,16(sp)
    80002af6:	e426                	sd	s1,8(sp)
    80002af8:	1000                	addi	s0,sp,32
    80002afa:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002afc:	00000097          	auipc	ra,0x0
    80002b00:	eca080e7          	jalr	-310(ra) # 800029c6 <argraw>
    80002b04:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b06:	4501                	li	a0,0
    80002b08:	60e2                	ld	ra,24(sp)
    80002b0a:	6442                	ld	s0,16(sp)
    80002b0c:	64a2                	ld	s1,8(sp)
    80002b0e:	6105                	addi	sp,sp,32
    80002b10:	8082                	ret

0000000080002b12 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b12:	1101                	addi	sp,sp,-32
    80002b14:	ec06                	sd	ra,24(sp)
    80002b16:	e822                	sd	s0,16(sp)
    80002b18:	e426                	sd	s1,8(sp)
    80002b1a:	e04a                	sd	s2,0(sp)
    80002b1c:	1000                	addi	s0,sp,32
    80002b1e:	84ae                	mv	s1,a1
    80002b20:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b22:	00000097          	auipc	ra,0x0
    80002b26:	ea4080e7          	jalr	-348(ra) # 800029c6 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b2a:	864a                	mv	a2,s2
    80002b2c:	85a6                	mv	a1,s1
    80002b2e:	00000097          	auipc	ra,0x0
    80002b32:	f58080e7          	jalr	-168(ra) # 80002a86 <fetchstr>
}
    80002b36:	60e2                	ld	ra,24(sp)
    80002b38:	6442                	ld	s0,16(sp)
    80002b3a:	64a2                	ld	s1,8(sp)
    80002b3c:	6902                	ld	s2,0(sp)
    80002b3e:	6105                	addi	sp,sp,32
    80002b40:	8082                	ret

0000000080002b42 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002b42:	1101                	addi	sp,sp,-32
    80002b44:	ec06                	sd	ra,24(sp)
    80002b46:	e822                	sd	s0,16(sp)
    80002b48:	e426                	sd	s1,8(sp)
    80002b4a:	e04a                	sd	s2,0(sp)
    80002b4c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b4e:	fffff097          	auipc	ra,0xfffff
    80002b52:	eb0080e7          	jalr	-336(ra) # 800019fe <myproc>
    80002b56:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b58:	05853903          	ld	s2,88(a0)
    80002b5c:	0a893783          	ld	a5,168(s2)
    80002b60:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b64:	37fd                	addiw	a5,a5,-1
    80002b66:	4751                	li	a4,20
    80002b68:	00f76f63          	bltu	a4,a5,80002b86 <syscall+0x44>
    80002b6c:	00369713          	slli	a4,a3,0x3
    80002b70:	00006797          	auipc	a5,0x6
    80002b74:	88878793          	addi	a5,a5,-1912 # 800083f8 <syscalls>
    80002b78:	97ba                	add	a5,a5,a4
    80002b7a:	639c                	ld	a5,0(a5)
    80002b7c:	c789                	beqz	a5,80002b86 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002b7e:	9782                	jalr	a5
    80002b80:	06a93823          	sd	a0,112(s2)
    80002b84:	a839                	j	80002ba2 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b86:	15848613          	addi	a2,s1,344
    80002b8a:	5c8c                	lw	a1,56(s1)
    80002b8c:	00006517          	auipc	a0,0x6
    80002b90:	92450513          	addi	a0,a0,-1756 # 800084b0 <syscalls+0xb8>
    80002b94:	ffffe097          	auipc	ra,0xffffe
    80002b98:	a2e080e7          	jalr	-1490(ra) # 800005c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b9c:	6cbc                	ld	a5,88(s1)
    80002b9e:	577d                	li	a4,-1
    80002ba0:	fbb8                	sd	a4,112(a5)
  }
}
    80002ba2:	60e2                	ld	ra,24(sp)
    80002ba4:	6442                	ld	s0,16(sp)
    80002ba6:	64a2                	ld	s1,8(sp)
    80002ba8:	6902                	ld	s2,0(sp)
    80002baa:	6105                	addi	sp,sp,32
    80002bac:	8082                	ret

0000000080002bae <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002bae:	1101                	addi	sp,sp,-32
    80002bb0:	ec06                	sd	ra,24(sp)
    80002bb2:	e822                	sd	s0,16(sp)
    80002bb4:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002bb6:	fec40593          	addi	a1,s0,-20
    80002bba:	4501                	li	a0,0
    80002bbc:	00000097          	auipc	ra,0x0
    80002bc0:	f12080e7          	jalr	-238(ra) # 80002ace <argint>
    return -1;
    80002bc4:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002bc6:	00054963          	bltz	a0,80002bd8 <sys_exit+0x2a>
  exit(n);
    80002bca:	fec42503          	lw	a0,-20(s0)
    80002bce:	fffff097          	auipc	ra,0xfffff
    80002bd2:	502080e7          	jalr	1282(ra) # 800020d0 <exit>
  return 0;  // not reached
    80002bd6:	4781                	li	a5,0
}
    80002bd8:	853e                	mv	a0,a5
    80002bda:	60e2                	ld	ra,24(sp)
    80002bdc:	6442                	ld	s0,16(sp)
    80002bde:	6105                	addi	sp,sp,32
    80002be0:	8082                	ret

0000000080002be2 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002be2:	1141                	addi	sp,sp,-16
    80002be4:	e406                	sd	ra,8(sp)
    80002be6:	e022                	sd	s0,0(sp)
    80002be8:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002bea:	fffff097          	auipc	ra,0xfffff
    80002bee:	e14080e7          	jalr	-492(ra) # 800019fe <myproc>
}
    80002bf2:	5d08                	lw	a0,56(a0)
    80002bf4:	60a2                	ld	ra,8(sp)
    80002bf6:	6402                	ld	s0,0(sp)
    80002bf8:	0141                	addi	sp,sp,16
    80002bfa:	8082                	ret

0000000080002bfc <sys_fork>:

uint64
sys_fork(void)
{
    80002bfc:	1141                	addi	sp,sp,-16
    80002bfe:	e406                	sd	ra,8(sp)
    80002c00:	e022                	sd	s0,0(sp)
    80002c02:	0800                	addi	s0,sp,16
  return fork();
    80002c04:	fffff097          	auipc	ra,0xfffff
    80002c08:	1c0080e7          	jalr	448(ra) # 80001dc4 <fork>
}
    80002c0c:	60a2                	ld	ra,8(sp)
    80002c0e:	6402                	ld	s0,0(sp)
    80002c10:	0141                	addi	sp,sp,16
    80002c12:	8082                	ret

0000000080002c14 <sys_wait>:

uint64
sys_wait(void)
{
    80002c14:	1101                	addi	sp,sp,-32
    80002c16:	ec06                	sd	ra,24(sp)
    80002c18:	e822                	sd	s0,16(sp)
    80002c1a:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c1c:	fe840593          	addi	a1,s0,-24
    80002c20:	4501                	li	a0,0
    80002c22:	00000097          	auipc	ra,0x0
    80002c26:	ece080e7          	jalr	-306(ra) # 80002af0 <argaddr>
    return -1;
    80002c2a:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    80002c2c:	00054963          	bltz	a0,80002c3e <sys_wait+0x2a>
  return wait(p);
    80002c30:	fe843503          	ld	a0,-24(s0)
    80002c34:	fffff097          	auipc	ra,0xfffff
    80002c38:	662080e7          	jalr	1634(ra) # 80002296 <wait>
    80002c3c:	87aa                	mv	a5,a0
}
    80002c3e:	853e                	mv	a0,a5
    80002c40:	60e2                	ld	ra,24(sp)
    80002c42:	6442                	ld	s0,16(sp)
    80002c44:	6105                	addi	sp,sp,32
    80002c46:	8082                	ret

0000000080002c48 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c48:	7179                	addi	sp,sp,-48
    80002c4a:	f406                	sd	ra,40(sp)
    80002c4c:	f022                	sd	s0,32(sp)
    80002c4e:	ec26                	sd	s1,24(sp)
    80002c50:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002c52:	fdc40593          	addi	a1,s0,-36
    80002c56:	4501                	li	a0,0
    80002c58:	00000097          	auipc	ra,0x0
    80002c5c:	e76080e7          	jalr	-394(ra) # 80002ace <argint>
    return -1;
    80002c60:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002c62:	00054f63          	bltz	a0,80002c80 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002c66:	fffff097          	auipc	ra,0xfffff
    80002c6a:	d98080e7          	jalr	-616(ra) # 800019fe <myproc>
    80002c6e:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002c70:	fdc42503          	lw	a0,-36(s0)
    80002c74:	fffff097          	auipc	ra,0xfffff
    80002c78:	0d8080e7          	jalr	216(ra) # 80001d4c <growproc>
    80002c7c:	00054863          	bltz	a0,80002c8c <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002c80:	8526                	mv	a0,s1
    80002c82:	70a2                	ld	ra,40(sp)
    80002c84:	7402                	ld	s0,32(sp)
    80002c86:	64e2                	ld	s1,24(sp)
    80002c88:	6145                	addi	sp,sp,48
    80002c8a:	8082                	ret
    return -1;
    80002c8c:	54fd                	li	s1,-1
    80002c8e:	bfcd                	j	80002c80 <sys_sbrk+0x38>

0000000080002c90 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c90:	7139                	addi	sp,sp,-64
    80002c92:	fc06                	sd	ra,56(sp)
    80002c94:	f822                	sd	s0,48(sp)
    80002c96:	f426                	sd	s1,40(sp)
    80002c98:	f04a                	sd	s2,32(sp)
    80002c9a:	ec4e                	sd	s3,24(sp)
    80002c9c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002c9e:	fcc40593          	addi	a1,s0,-52
    80002ca2:	4501                	li	a0,0
    80002ca4:	00000097          	auipc	ra,0x0
    80002ca8:	e2a080e7          	jalr	-470(ra) # 80002ace <argint>
    return -1;
    80002cac:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002cae:	06054763          	bltz	a0,80002d1c <sys_sleep+0x8c>
  acquire(&tickslock);
    80002cb2:	00014517          	auipc	a0,0x14
    80002cb6:	3f650513          	addi	a0,a0,1014 # 800170a8 <tickslock>
    80002cba:	ffffe097          	auipc	ra,0xffffe
    80002cbe:	fac080e7          	jalr	-84(ra) # 80000c66 <acquire>
  ticks0 = ticks;
    80002cc2:	00006797          	auipc	a5,0x6
    80002cc6:	35e78793          	addi	a5,a5,862 # 80009020 <ticks>
    80002cca:	0007a903          	lw	s2,0(a5)
  while(ticks - ticks0 < n){
    80002cce:	fcc42783          	lw	a5,-52(s0)
    80002cd2:	cf85                	beqz	a5,80002d0a <sys_sleep+0x7a>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cd4:	00014997          	auipc	s3,0x14
    80002cd8:	3d498993          	addi	s3,s3,980 # 800170a8 <tickslock>
    80002cdc:	00006497          	auipc	s1,0x6
    80002ce0:	34448493          	addi	s1,s1,836 # 80009020 <ticks>
    if(myproc()->killed){
    80002ce4:	fffff097          	auipc	ra,0xfffff
    80002ce8:	d1a080e7          	jalr	-742(ra) # 800019fe <myproc>
    80002cec:	591c                	lw	a5,48(a0)
    80002cee:	ef9d                	bnez	a5,80002d2c <sys_sleep+0x9c>
    sleep(&ticks, &tickslock);
    80002cf0:	85ce                	mv	a1,s3
    80002cf2:	8526                	mv	a0,s1
    80002cf4:	fffff097          	auipc	ra,0xfffff
    80002cf8:	524080e7          	jalr	1316(ra) # 80002218 <sleep>
  while(ticks - ticks0 < n){
    80002cfc:	409c                	lw	a5,0(s1)
    80002cfe:	412787bb          	subw	a5,a5,s2
    80002d02:	fcc42703          	lw	a4,-52(s0)
    80002d06:	fce7efe3          	bltu	a5,a4,80002ce4 <sys_sleep+0x54>
  }
  release(&tickslock);
    80002d0a:	00014517          	auipc	a0,0x14
    80002d0e:	39e50513          	addi	a0,a0,926 # 800170a8 <tickslock>
    80002d12:	ffffe097          	auipc	ra,0xffffe
    80002d16:	008080e7          	jalr	8(ra) # 80000d1a <release>
  return 0;
    80002d1a:	4781                	li	a5,0
}
    80002d1c:	853e                	mv	a0,a5
    80002d1e:	70e2                	ld	ra,56(sp)
    80002d20:	7442                	ld	s0,48(sp)
    80002d22:	74a2                	ld	s1,40(sp)
    80002d24:	7902                	ld	s2,32(sp)
    80002d26:	69e2                	ld	s3,24(sp)
    80002d28:	6121                	addi	sp,sp,64
    80002d2a:	8082                	ret
      release(&tickslock);
    80002d2c:	00014517          	auipc	a0,0x14
    80002d30:	37c50513          	addi	a0,a0,892 # 800170a8 <tickslock>
    80002d34:	ffffe097          	auipc	ra,0xffffe
    80002d38:	fe6080e7          	jalr	-26(ra) # 80000d1a <release>
      return -1;
    80002d3c:	57fd                	li	a5,-1
    80002d3e:	bff9                	j	80002d1c <sys_sleep+0x8c>

0000000080002d40 <sys_kill>:

uint64
sys_kill(void)
{
    80002d40:	1101                	addi	sp,sp,-32
    80002d42:	ec06                	sd	ra,24(sp)
    80002d44:	e822                	sd	s0,16(sp)
    80002d46:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002d48:	fec40593          	addi	a1,s0,-20
    80002d4c:	4501                	li	a0,0
    80002d4e:	00000097          	auipc	ra,0x0
    80002d52:	d80080e7          	jalr	-640(ra) # 80002ace <argint>
    return -1;
    80002d56:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    80002d58:	00054963          	bltz	a0,80002d6a <sys_kill+0x2a>
  return kill(pid);
    80002d5c:	fec42503          	lw	a0,-20(s0)
    80002d60:	fffff097          	auipc	ra,0xfffff
    80002d64:	6a8080e7          	jalr	1704(ra) # 80002408 <kill>
    80002d68:	87aa                	mv	a5,a0
}
    80002d6a:	853e                	mv	a0,a5
    80002d6c:	60e2                	ld	ra,24(sp)
    80002d6e:	6442                	ld	s0,16(sp)
    80002d70:	6105                	addi	sp,sp,32
    80002d72:	8082                	ret

0000000080002d74 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d74:	1101                	addi	sp,sp,-32
    80002d76:	ec06                	sd	ra,24(sp)
    80002d78:	e822                	sd	s0,16(sp)
    80002d7a:	e426                	sd	s1,8(sp)
    80002d7c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d7e:	00014517          	auipc	a0,0x14
    80002d82:	32a50513          	addi	a0,a0,810 # 800170a8 <tickslock>
    80002d86:	ffffe097          	auipc	ra,0xffffe
    80002d8a:	ee0080e7          	jalr	-288(ra) # 80000c66 <acquire>
  xticks = ticks;
    80002d8e:	00006797          	auipc	a5,0x6
    80002d92:	29278793          	addi	a5,a5,658 # 80009020 <ticks>
    80002d96:	4384                	lw	s1,0(a5)
  release(&tickslock);
    80002d98:	00014517          	auipc	a0,0x14
    80002d9c:	31050513          	addi	a0,a0,784 # 800170a8 <tickslock>
    80002da0:	ffffe097          	auipc	ra,0xffffe
    80002da4:	f7a080e7          	jalr	-134(ra) # 80000d1a <release>
  return xticks;
}
    80002da8:	02049513          	slli	a0,s1,0x20
    80002dac:	9101                	srli	a0,a0,0x20
    80002dae:	60e2                	ld	ra,24(sp)
    80002db0:	6442                	ld	s0,16(sp)
    80002db2:	64a2                	ld	s1,8(sp)
    80002db4:	6105                	addi	sp,sp,32
    80002db6:	8082                	ret

0000000080002db8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002db8:	7179                	addi	sp,sp,-48
    80002dba:	f406                	sd	ra,40(sp)
    80002dbc:	f022                	sd	s0,32(sp)
    80002dbe:	ec26                	sd	s1,24(sp)
    80002dc0:	e84a                	sd	s2,16(sp)
    80002dc2:	e44e                	sd	s3,8(sp)
    80002dc4:	e052                	sd	s4,0(sp)
    80002dc6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002dc8:	00005597          	auipc	a1,0x5
    80002dcc:	70858593          	addi	a1,a1,1800 # 800084d0 <syscalls+0xd8>
    80002dd0:	00014517          	auipc	a0,0x14
    80002dd4:	2f050513          	addi	a0,a0,752 # 800170c0 <bcache>
    80002dd8:	ffffe097          	auipc	ra,0xffffe
    80002ddc:	dfe080e7          	jalr	-514(ra) # 80000bd6 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002de0:	0001c797          	auipc	a5,0x1c
    80002de4:	2e078793          	addi	a5,a5,736 # 8001f0c0 <bcache+0x8000>
    80002de8:	0001c717          	auipc	a4,0x1c
    80002dec:	54070713          	addi	a4,a4,1344 # 8001f328 <bcache+0x8268>
    80002df0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002df4:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002df8:	00014497          	auipc	s1,0x14
    80002dfc:	2e048493          	addi	s1,s1,736 # 800170d8 <bcache+0x18>
    b->next = bcache.head.next;
    80002e00:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e02:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e04:	00005a17          	auipc	s4,0x5
    80002e08:	6d4a0a13          	addi	s4,s4,1748 # 800084d8 <syscalls+0xe0>
    b->next = bcache.head.next;
    80002e0c:	2b893783          	ld	a5,696(s2)
    80002e10:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e12:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e16:	85d2                	mv	a1,s4
    80002e18:	01048513          	addi	a0,s1,16
    80002e1c:	00001097          	auipc	ra,0x1
    80002e20:	530080e7          	jalr	1328(ra) # 8000434c <initsleeplock>
    bcache.head.next->prev = b;
    80002e24:	2b893783          	ld	a5,696(s2)
    80002e28:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e2a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e2e:	45848493          	addi	s1,s1,1112
    80002e32:	fd349de3          	bne	s1,s3,80002e0c <binit+0x54>
  }
}
    80002e36:	70a2                	ld	ra,40(sp)
    80002e38:	7402                	ld	s0,32(sp)
    80002e3a:	64e2                	ld	s1,24(sp)
    80002e3c:	6942                	ld	s2,16(sp)
    80002e3e:	69a2                	ld	s3,8(sp)
    80002e40:	6a02                	ld	s4,0(sp)
    80002e42:	6145                	addi	sp,sp,48
    80002e44:	8082                	ret

0000000080002e46 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e46:	7179                	addi	sp,sp,-48
    80002e48:	f406                	sd	ra,40(sp)
    80002e4a:	f022                	sd	s0,32(sp)
    80002e4c:	ec26                	sd	s1,24(sp)
    80002e4e:	e84a                	sd	s2,16(sp)
    80002e50:	e44e                	sd	s3,8(sp)
    80002e52:	1800                	addi	s0,sp,48
    80002e54:	89aa                	mv	s3,a0
    80002e56:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002e58:	00014517          	auipc	a0,0x14
    80002e5c:	26850513          	addi	a0,a0,616 # 800170c0 <bcache>
    80002e60:	ffffe097          	auipc	ra,0xffffe
    80002e64:	e06080e7          	jalr	-506(ra) # 80000c66 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e68:	0001c797          	auipc	a5,0x1c
    80002e6c:	25878793          	addi	a5,a5,600 # 8001f0c0 <bcache+0x8000>
    80002e70:	2b87b483          	ld	s1,696(a5)
    80002e74:	0001c797          	auipc	a5,0x1c
    80002e78:	4b478793          	addi	a5,a5,1204 # 8001f328 <bcache+0x8268>
    80002e7c:	02f48f63          	beq	s1,a5,80002eba <bread+0x74>
    80002e80:	873e                	mv	a4,a5
    80002e82:	a021                	j	80002e8a <bread+0x44>
    80002e84:	68a4                	ld	s1,80(s1)
    80002e86:	02e48a63          	beq	s1,a4,80002eba <bread+0x74>
    if(b->dev == dev && b->blockno == blockno){
    80002e8a:	449c                	lw	a5,8(s1)
    80002e8c:	ff379ce3          	bne	a5,s3,80002e84 <bread+0x3e>
    80002e90:	44dc                	lw	a5,12(s1)
    80002e92:	ff2799e3          	bne	a5,s2,80002e84 <bread+0x3e>
      b->refcnt++;
    80002e96:	40bc                	lw	a5,64(s1)
    80002e98:	2785                	addiw	a5,a5,1
    80002e9a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e9c:	00014517          	auipc	a0,0x14
    80002ea0:	22450513          	addi	a0,a0,548 # 800170c0 <bcache>
    80002ea4:	ffffe097          	auipc	ra,0xffffe
    80002ea8:	e76080e7          	jalr	-394(ra) # 80000d1a <release>
      acquiresleep(&b->lock);
    80002eac:	01048513          	addi	a0,s1,16
    80002eb0:	00001097          	auipc	ra,0x1
    80002eb4:	4d6080e7          	jalr	1238(ra) # 80004386 <acquiresleep>
      return b;
    80002eb8:	a8b1                	j	80002f14 <bread+0xce>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002eba:	0001c797          	auipc	a5,0x1c
    80002ebe:	20678793          	addi	a5,a5,518 # 8001f0c0 <bcache+0x8000>
    80002ec2:	2b07b483          	ld	s1,688(a5)
    80002ec6:	0001c797          	auipc	a5,0x1c
    80002eca:	46278793          	addi	a5,a5,1122 # 8001f328 <bcache+0x8268>
    80002ece:	04f48d63          	beq	s1,a5,80002f28 <bread+0xe2>
    if(b->refcnt == 0) {
    80002ed2:	40bc                	lw	a5,64(s1)
    80002ed4:	cb91                	beqz	a5,80002ee8 <bread+0xa2>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ed6:	0001c717          	auipc	a4,0x1c
    80002eda:	45270713          	addi	a4,a4,1106 # 8001f328 <bcache+0x8268>
    80002ede:	64a4                	ld	s1,72(s1)
    80002ee0:	04e48463          	beq	s1,a4,80002f28 <bread+0xe2>
    if(b->refcnt == 0) {
    80002ee4:	40bc                	lw	a5,64(s1)
    80002ee6:	ffe5                	bnez	a5,80002ede <bread+0x98>
      b->dev = dev;
    80002ee8:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002eec:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002ef0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002ef4:	4785                	li	a5,1
    80002ef6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ef8:	00014517          	auipc	a0,0x14
    80002efc:	1c850513          	addi	a0,a0,456 # 800170c0 <bcache>
    80002f00:	ffffe097          	auipc	ra,0xffffe
    80002f04:	e1a080e7          	jalr	-486(ra) # 80000d1a <release>
      acquiresleep(&b->lock);
    80002f08:	01048513          	addi	a0,s1,16
    80002f0c:	00001097          	auipc	ra,0x1
    80002f10:	47a080e7          	jalr	1146(ra) # 80004386 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f14:	409c                	lw	a5,0(s1)
    80002f16:	c38d                	beqz	a5,80002f38 <bread+0xf2>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f18:	8526                	mv	a0,s1
    80002f1a:	70a2                	ld	ra,40(sp)
    80002f1c:	7402                	ld	s0,32(sp)
    80002f1e:	64e2                	ld	s1,24(sp)
    80002f20:	6942                	ld	s2,16(sp)
    80002f22:	69a2                	ld	s3,8(sp)
    80002f24:	6145                	addi	sp,sp,48
    80002f26:	8082                	ret
  panic("bget: no buffers");
    80002f28:	00005517          	auipc	a0,0x5
    80002f2c:	5b850513          	addi	a0,a0,1464 # 800084e0 <syscalls+0xe8>
    80002f30:	ffffd097          	auipc	ra,0xffffd
    80002f34:	648080e7          	jalr	1608(ra) # 80000578 <panic>
    virtio_disk_rw(b, 0);
    80002f38:	4581                	li	a1,0
    80002f3a:	8526                	mv	a0,s1
    80002f3c:	00003097          	auipc	ra,0x3
    80002f40:	01a080e7          	jalr	26(ra) # 80005f56 <virtio_disk_rw>
    b->valid = 1;
    80002f44:	4785                	li	a5,1
    80002f46:	c09c                	sw	a5,0(s1)
  return b;
    80002f48:	bfc1                	j	80002f18 <bread+0xd2>

0000000080002f4a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f4a:	1101                	addi	sp,sp,-32
    80002f4c:	ec06                	sd	ra,24(sp)
    80002f4e:	e822                	sd	s0,16(sp)
    80002f50:	e426                	sd	s1,8(sp)
    80002f52:	1000                	addi	s0,sp,32
    80002f54:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f56:	0541                	addi	a0,a0,16
    80002f58:	00001097          	auipc	ra,0x1
    80002f5c:	4c8080e7          	jalr	1224(ra) # 80004420 <holdingsleep>
    80002f60:	cd01                	beqz	a0,80002f78 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f62:	4585                	li	a1,1
    80002f64:	8526                	mv	a0,s1
    80002f66:	00003097          	auipc	ra,0x3
    80002f6a:	ff0080e7          	jalr	-16(ra) # 80005f56 <virtio_disk_rw>
}
    80002f6e:	60e2                	ld	ra,24(sp)
    80002f70:	6442                	ld	s0,16(sp)
    80002f72:	64a2                	ld	s1,8(sp)
    80002f74:	6105                	addi	sp,sp,32
    80002f76:	8082                	ret
    panic("bwrite");
    80002f78:	00005517          	auipc	a0,0x5
    80002f7c:	58050513          	addi	a0,a0,1408 # 800084f8 <syscalls+0x100>
    80002f80:	ffffd097          	auipc	ra,0xffffd
    80002f84:	5f8080e7          	jalr	1528(ra) # 80000578 <panic>

0000000080002f88 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f88:	1101                	addi	sp,sp,-32
    80002f8a:	ec06                	sd	ra,24(sp)
    80002f8c:	e822                	sd	s0,16(sp)
    80002f8e:	e426                	sd	s1,8(sp)
    80002f90:	e04a                	sd	s2,0(sp)
    80002f92:	1000                	addi	s0,sp,32
    80002f94:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f96:	01050913          	addi	s2,a0,16
    80002f9a:	854a                	mv	a0,s2
    80002f9c:	00001097          	auipc	ra,0x1
    80002fa0:	484080e7          	jalr	1156(ra) # 80004420 <holdingsleep>
    80002fa4:	c92d                	beqz	a0,80003016 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002fa6:	854a                	mv	a0,s2
    80002fa8:	00001097          	auipc	ra,0x1
    80002fac:	434080e7          	jalr	1076(ra) # 800043dc <releasesleep>

  acquire(&bcache.lock);
    80002fb0:	00014517          	auipc	a0,0x14
    80002fb4:	11050513          	addi	a0,a0,272 # 800170c0 <bcache>
    80002fb8:	ffffe097          	auipc	ra,0xffffe
    80002fbc:	cae080e7          	jalr	-850(ra) # 80000c66 <acquire>
  b->refcnt--;
    80002fc0:	40bc                	lw	a5,64(s1)
    80002fc2:	37fd                	addiw	a5,a5,-1
    80002fc4:	0007871b          	sext.w	a4,a5
    80002fc8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002fca:	eb05                	bnez	a4,80002ffa <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002fcc:	68bc                	ld	a5,80(s1)
    80002fce:	64b8                	ld	a4,72(s1)
    80002fd0:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002fd2:	64bc                	ld	a5,72(s1)
    80002fd4:	68b8                	ld	a4,80(s1)
    80002fd6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002fd8:	0001c797          	auipc	a5,0x1c
    80002fdc:	0e878793          	addi	a5,a5,232 # 8001f0c0 <bcache+0x8000>
    80002fe0:	2b87b703          	ld	a4,696(a5)
    80002fe4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002fe6:	0001c717          	auipc	a4,0x1c
    80002fea:	34270713          	addi	a4,a4,834 # 8001f328 <bcache+0x8268>
    80002fee:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002ff0:	2b87b703          	ld	a4,696(a5)
    80002ff4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002ff6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002ffa:	00014517          	auipc	a0,0x14
    80002ffe:	0c650513          	addi	a0,a0,198 # 800170c0 <bcache>
    80003002:	ffffe097          	auipc	ra,0xffffe
    80003006:	d18080e7          	jalr	-744(ra) # 80000d1a <release>
}
    8000300a:	60e2                	ld	ra,24(sp)
    8000300c:	6442                	ld	s0,16(sp)
    8000300e:	64a2                	ld	s1,8(sp)
    80003010:	6902                	ld	s2,0(sp)
    80003012:	6105                	addi	sp,sp,32
    80003014:	8082                	ret
    panic("brelse");
    80003016:	00005517          	auipc	a0,0x5
    8000301a:	4ea50513          	addi	a0,a0,1258 # 80008500 <syscalls+0x108>
    8000301e:	ffffd097          	auipc	ra,0xffffd
    80003022:	55a080e7          	jalr	1370(ra) # 80000578 <panic>

0000000080003026 <bpin>:

void
bpin(struct buf *b) {
    80003026:	1101                	addi	sp,sp,-32
    80003028:	ec06                	sd	ra,24(sp)
    8000302a:	e822                	sd	s0,16(sp)
    8000302c:	e426                	sd	s1,8(sp)
    8000302e:	1000                	addi	s0,sp,32
    80003030:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003032:	00014517          	auipc	a0,0x14
    80003036:	08e50513          	addi	a0,a0,142 # 800170c0 <bcache>
    8000303a:	ffffe097          	auipc	ra,0xffffe
    8000303e:	c2c080e7          	jalr	-980(ra) # 80000c66 <acquire>
  b->refcnt++;
    80003042:	40bc                	lw	a5,64(s1)
    80003044:	2785                	addiw	a5,a5,1
    80003046:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003048:	00014517          	auipc	a0,0x14
    8000304c:	07850513          	addi	a0,a0,120 # 800170c0 <bcache>
    80003050:	ffffe097          	auipc	ra,0xffffe
    80003054:	cca080e7          	jalr	-822(ra) # 80000d1a <release>
}
    80003058:	60e2                	ld	ra,24(sp)
    8000305a:	6442                	ld	s0,16(sp)
    8000305c:	64a2                	ld	s1,8(sp)
    8000305e:	6105                	addi	sp,sp,32
    80003060:	8082                	ret

0000000080003062 <bunpin>:

void
bunpin(struct buf *b) {
    80003062:	1101                	addi	sp,sp,-32
    80003064:	ec06                	sd	ra,24(sp)
    80003066:	e822                	sd	s0,16(sp)
    80003068:	e426                	sd	s1,8(sp)
    8000306a:	1000                	addi	s0,sp,32
    8000306c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000306e:	00014517          	auipc	a0,0x14
    80003072:	05250513          	addi	a0,a0,82 # 800170c0 <bcache>
    80003076:	ffffe097          	auipc	ra,0xffffe
    8000307a:	bf0080e7          	jalr	-1040(ra) # 80000c66 <acquire>
  b->refcnt--;
    8000307e:	40bc                	lw	a5,64(s1)
    80003080:	37fd                	addiw	a5,a5,-1
    80003082:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003084:	00014517          	auipc	a0,0x14
    80003088:	03c50513          	addi	a0,a0,60 # 800170c0 <bcache>
    8000308c:	ffffe097          	auipc	ra,0xffffe
    80003090:	c8e080e7          	jalr	-882(ra) # 80000d1a <release>
}
    80003094:	60e2                	ld	ra,24(sp)
    80003096:	6442                	ld	s0,16(sp)
    80003098:	64a2                	ld	s1,8(sp)
    8000309a:	6105                	addi	sp,sp,32
    8000309c:	8082                	ret

000000008000309e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000309e:	1101                	addi	sp,sp,-32
    800030a0:	ec06                	sd	ra,24(sp)
    800030a2:	e822                	sd	s0,16(sp)
    800030a4:	e426                	sd	s1,8(sp)
    800030a6:	e04a                	sd	s2,0(sp)
    800030a8:	1000                	addi	s0,sp,32
    800030aa:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030ac:	00d5d59b          	srliw	a1,a1,0xd
    800030b0:	0001c797          	auipc	a5,0x1c
    800030b4:	6d078793          	addi	a5,a5,1744 # 8001f780 <sb>
    800030b8:	4fdc                	lw	a5,28(a5)
    800030ba:	9dbd                	addw	a1,a1,a5
    800030bc:	00000097          	auipc	ra,0x0
    800030c0:	d8a080e7          	jalr	-630(ra) # 80002e46 <bread>
  bi = b % BPB;
    800030c4:	2481                	sext.w	s1,s1
  m = 1 << (bi % 8);
    800030c6:	0074f793          	andi	a5,s1,7
    800030ca:	4705                	li	a4,1
    800030cc:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    800030d0:	6789                	lui	a5,0x2
    800030d2:	17fd                	addi	a5,a5,-1
    800030d4:	8cfd                	and	s1,s1,a5
  if((bp->data[bi/8] & m) == 0)
    800030d6:	41f4d79b          	sraiw	a5,s1,0x1f
    800030da:	01d7d79b          	srliw	a5,a5,0x1d
    800030de:	9fa5                	addw	a5,a5,s1
    800030e0:	4037d79b          	sraiw	a5,a5,0x3
    800030e4:	00f506b3          	add	a3,a0,a5
    800030e8:	0586c683          	lbu	a3,88(a3)
    800030ec:	00d77633          	and	a2,a4,a3
    800030f0:	c61d                	beqz	a2,8000311e <bfree+0x80>
    800030f2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800030f4:	97aa                	add	a5,a5,a0
    800030f6:	fff74713          	not	a4,a4
    800030fa:	8f75                	and	a4,a4,a3
    800030fc:	04e78c23          	sb	a4,88(a5) # 2058 <_entry-0x7fffdfa8>
  log_write(bp);
    80003100:	00001097          	auipc	ra,0x1
    80003104:	148080e7          	jalr	328(ra) # 80004248 <log_write>
  brelse(bp);
    80003108:	854a                	mv	a0,s2
    8000310a:	00000097          	auipc	ra,0x0
    8000310e:	e7e080e7          	jalr	-386(ra) # 80002f88 <brelse>
}
    80003112:	60e2                	ld	ra,24(sp)
    80003114:	6442                	ld	s0,16(sp)
    80003116:	64a2                	ld	s1,8(sp)
    80003118:	6902                	ld	s2,0(sp)
    8000311a:	6105                	addi	sp,sp,32
    8000311c:	8082                	ret
    panic("freeing free block");
    8000311e:	00005517          	auipc	a0,0x5
    80003122:	3ea50513          	addi	a0,a0,1002 # 80008508 <syscalls+0x110>
    80003126:	ffffd097          	auipc	ra,0xffffd
    8000312a:	452080e7          	jalr	1106(ra) # 80000578 <panic>

000000008000312e <balloc>:
{
    8000312e:	711d                	addi	sp,sp,-96
    80003130:	ec86                	sd	ra,88(sp)
    80003132:	e8a2                	sd	s0,80(sp)
    80003134:	e4a6                	sd	s1,72(sp)
    80003136:	e0ca                	sd	s2,64(sp)
    80003138:	fc4e                	sd	s3,56(sp)
    8000313a:	f852                	sd	s4,48(sp)
    8000313c:	f456                	sd	s5,40(sp)
    8000313e:	f05a                	sd	s6,32(sp)
    80003140:	ec5e                	sd	s7,24(sp)
    80003142:	e862                	sd	s8,16(sp)
    80003144:	e466                	sd	s9,8(sp)
    80003146:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003148:	0001c797          	auipc	a5,0x1c
    8000314c:	63878793          	addi	a5,a5,1592 # 8001f780 <sb>
    80003150:	43dc                	lw	a5,4(a5)
    80003152:	10078e63          	beqz	a5,8000326e <balloc+0x140>
    80003156:	8baa                	mv	s7,a0
    80003158:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000315a:	0001cb17          	auipc	s6,0x1c
    8000315e:	626b0b13          	addi	s6,s6,1574 # 8001f780 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003162:	4c05                	li	s8,1
      m = 1 << (bi % 8);
    80003164:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003166:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003168:	6c89                	lui	s9,0x2
    8000316a:	a079                	j	800031f8 <balloc+0xca>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000316c:	8942                	mv	s2,a6
      m = 1 << (bi % 8);
    8000316e:	4705                	li	a4,1
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003170:	4681                	li	a3,0
        bp->data[bi/8] |= m;  // Mark block in use.
    80003172:	96a6                	add	a3,a3,s1
    80003174:	8f51                	or	a4,a4,a2
    80003176:	04e68c23          	sb	a4,88(a3)
        log_write(bp);
    8000317a:	8526                	mv	a0,s1
    8000317c:	00001097          	auipc	ra,0x1
    80003180:	0cc080e7          	jalr	204(ra) # 80004248 <log_write>
        brelse(bp);
    80003184:	8526                	mv	a0,s1
    80003186:	00000097          	auipc	ra,0x0
    8000318a:	e02080e7          	jalr	-510(ra) # 80002f88 <brelse>
  bp = bread(dev, bno);
    8000318e:	85ca                	mv	a1,s2
    80003190:	855e                	mv	a0,s7
    80003192:	00000097          	auipc	ra,0x0
    80003196:	cb4080e7          	jalr	-844(ra) # 80002e46 <bread>
    8000319a:	84aa                	mv	s1,a0
  memset(bp->data, 0, BSIZE);
    8000319c:	40000613          	li	a2,1024
    800031a0:	4581                	li	a1,0
    800031a2:	05850513          	addi	a0,a0,88
    800031a6:	ffffe097          	auipc	ra,0xffffe
    800031aa:	bbc080e7          	jalr	-1092(ra) # 80000d62 <memset>
  log_write(bp);
    800031ae:	8526                	mv	a0,s1
    800031b0:	00001097          	auipc	ra,0x1
    800031b4:	098080e7          	jalr	152(ra) # 80004248 <log_write>
  brelse(bp);
    800031b8:	8526                	mv	a0,s1
    800031ba:	00000097          	auipc	ra,0x0
    800031be:	dce080e7          	jalr	-562(ra) # 80002f88 <brelse>
}
    800031c2:	854a                	mv	a0,s2
    800031c4:	60e6                	ld	ra,88(sp)
    800031c6:	6446                	ld	s0,80(sp)
    800031c8:	64a6                	ld	s1,72(sp)
    800031ca:	6906                	ld	s2,64(sp)
    800031cc:	79e2                	ld	s3,56(sp)
    800031ce:	7a42                	ld	s4,48(sp)
    800031d0:	7aa2                	ld	s5,40(sp)
    800031d2:	7b02                	ld	s6,32(sp)
    800031d4:	6be2                	ld	s7,24(sp)
    800031d6:	6c42                	ld	s8,16(sp)
    800031d8:	6ca2                	ld	s9,8(sp)
    800031da:	6125                	addi	sp,sp,96
    800031dc:	8082                	ret
    brelse(bp);
    800031de:	8526                	mv	a0,s1
    800031e0:	00000097          	auipc	ra,0x0
    800031e4:	da8080e7          	jalr	-600(ra) # 80002f88 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031e8:	015c87bb          	addw	a5,s9,s5
    800031ec:	00078a9b          	sext.w	s5,a5
    800031f0:	004b2703          	lw	a4,4(s6)
    800031f4:	06eafd63          	bleu	a4,s5,8000326e <balloc+0x140>
    bp = bread(dev, BBLOCK(b, sb));
    800031f8:	41fad79b          	sraiw	a5,s5,0x1f
    800031fc:	0137d79b          	srliw	a5,a5,0x13
    80003200:	015787bb          	addw	a5,a5,s5
    80003204:	40d7d79b          	sraiw	a5,a5,0xd
    80003208:	01cb2583          	lw	a1,28(s6)
    8000320c:	9dbd                	addw	a1,a1,a5
    8000320e:	855e                	mv	a0,s7
    80003210:	00000097          	auipc	ra,0x0
    80003214:	c36080e7          	jalr	-970(ra) # 80002e46 <bread>
    80003218:	84aa                	mv	s1,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000321a:	000a881b          	sext.w	a6,s5
    8000321e:	004b2503          	lw	a0,4(s6)
    80003222:	faa87ee3          	bleu	a0,a6,800031de <balloc+0xb0>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003226:	0584c603          	lbu	a2,88(s1)
    8000322a:	00167793          	andi	a5,a2,1
    8000322e:	df9d                	beqz	a5,8000316c <balloc+0x3e>
    80003230:	4105053b          	subw	a0,a0,a6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003234:	87e2                	mv	a5,s8
    80003236:	0107893b          	addw	s2,a5,a6
    8000323a:	faa782e3          	beq	a5,a0,800031de <balloc+0xb0>
      m = 1 << (bi % 8);
    8000323e:	41f7d71b          	sraiw	a4,a5,0x1f
    80003242:	01d7561b          	srliw	a2,a4,0x1d
    80003246:	00f606bb          	addw	a3,a2,a5
    8000324a:	0076f713          	andi	a4,a3,7
    8000324e:	9f11                	subw	a4,a4,a2
    80003250:	00e9973b          	sllw	a4,s3,a4
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003254:	4036d69b          	sraiw	a3,a3,0x3
    80003258:	00d48633          	add	a2,s1,a3
    8000325c:	05864603          	lbu	a2,88(a2)
    80003260:	00c775b3          	and	a1,a4,a2
    80003264:	d599                	beqz	a1,80003172 <balloc+0x44>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003266:	2785                	addiw	a5,a5,1
    80003268:	fd4797e3          	bne	a5,s4,80003236 <balloc+0x108>
    8000326c:	bf8d                	j	800031de <balloc+0xb0>
  panic("balloc: out of blocks");
    8000326e:	00005517          	auipc	a0,0x5
    80003272:	2b250513          	addi	a0,a0,690 # 80008520 <syscalls+0x128>
    80003276:	ffffd097          	auipc	ra,0xffffd
    8000327a:	302080e7          	jalr	770(ra) # 80000578 <panic>

000000008000327e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000327e:	7179                	addi	sp,sp,-48
    80003280:	f406                	sd	ra,40(sp)
    80003282:	f022                	sd	s0,32(sp)
    80003284:	ec26                	sd	s1,24(sp)
    80003286:	e84a                	sd	s2,16(sp)
    80003288:	e44e                	sd	s3,8(sp)
    8000328a:	e052                	sd	s4,0(sp)
    8000328c:	1800                	addi	s0,sp,48
    8000328e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003290:	47ad                	li	a5,11
    80003292:	04b7fe63          	bleu	a1,a5,800032ee <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003296:	ff45849b          	addiw	s1,a1,-12
    8000329a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000329e:	0ff00793          	li	a5,255
    800032a2:	0ae7e363          	bltu	a5,a4,80003348 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800032a6:	08052583          	lw	a1,128(a0)
    800032aa:	c5ad                	beqz	a1,80003314 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800032ac:	0009a503          	lw	a0,0(s3)
    800032b0:	00000097          	auipc	ra,0x0
    800032b4:	b96080e7          	jalr	-1130(ra) # 80002e46 <bread>
    800032b8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800032ba:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800032be:	02049593          	slli	a1,s1,0x20
    800032c2:	9181                	srli	a1,a1,0x20
    800032c4:	058a                	slli	a1,a1,0x2
    800032c6:	00b784b3          	add	s1,a5,a1
    800032ca:	0004a903          	lw	s2,0(s1)
    800032ce:	04090d63          	beqz	s2,80003328 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800032d2:	8552                	mv	a0,s4
    800032d4:	00000097          	auipc	ra,0x0
    800032d8:	cb4080e7          	jalr	-844(ra) # 80002f88 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800032dc:	854a                	mv	a0,s2
    800032de:	70a2                	ld	ra,40(sp)
    800032e0:	7402                	ld	s0,32(sp)
    800032e2:	64e2                	ld	s1,24(sp)
    800032e4:	6942                	ld	s2,16(sp)
    800032e6:	69a2                	ld	s3,8(sp)
    800032e8:	6a02                	ld	s4,0(sp)
    800032ea:	6145                	addi	sp,sp,48
    800032ec:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800032ee:	02059493          	slli	s1,a1,0x20
    800032f2:	9081                	srli	s1,s1,0x20
    800032f4:	048a                	slli	s1,s1,0x2
    800032f6:	94aa                	add	s1,s1,a0
    800032f8:	0504a903          	lw	s2,80(s1)
    800032fc:	fe0910e3          	bnez	s2,800032dc <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003300:	4108                	lw	a0,0(a0)
    80003302:	00000097          	auipc	ra,0x0
    80003306:	e2c080e7          	jalr	-468(ra) # 8000312e <balloc>
    8000330a:	0005091b          	sext.w	s2,a0
    8000330e:	0524a823          	sw	s2,80(s1)
    80003312:	b7e9                	j	800032dc <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003314:	4108                	lw	a0,0(a0)
    80003316:	00000097          	auipc	ra,0x0
    8000331a:	e18080e7          	jalr	-488(ra) # 8000312e <balloc>
    8000331e:	0005059b          	sext.w	a1,a0
    80003322:	08b9a023          	sw	a1,128(s3)
    80003326:	b759                	j	800032ac <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003328:	0009a503          	lw	a0,0(s3)
    8000332c:	00000097          	auipc	ra,0x0
    80003330:	e02080e7          	jalr	-510(ra) # 8000312e <balloc>
    80003334:	0005091b          	sext.w	s2,a0
    80003338:	0124a023          	sw	s2,0(s1)
      log_write(bp);
    8000333c:	8552                	mv	a0,s4
    8000333e:	00001097          	auipc	ra,0x1
    80003342:	f0a080e7          	jalr	-246(ra) # 80004248 <log_write>
    80003346:	b771                	j	800032d2 <bmap+0x54>
  panic("bmap: out of range");
    80003348:	00005517          	auipc	a0,0x5
    8000334c:	1f050513          	addi	a0,a0,496 # 80008538 <syscalls+0x140>
    80003350:	ffffd097          	auipc	ra,0xffffd
    80003354:	228080e7          	jalr	552(ra) # 80000578 <panic>

0000000080003358 <iget>:
{
    80003358:	7179                	addi	sp,sp,-48
    8000335a:	f406                	sd	ra,40(sp)
    8000335c:	f022                	sd	s0,32(sp)
    8000335e:	ec26                	sd	s1,24(sp)
    80003360:	e84a                	sd	s2,16(sp)
    80003362:	e44e                	sd	s3,8(sp)
    80003364:	e052                	sd	s4,0(sp)
    80003366:	1800                	addi	s0,sp,48
    80003368:	89aa                	mv	s3,a0
    8000336a:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    8000336c:	0001c517          	auipc	a0,0x1c
    80003370:	43450513          	addi	a0,a0,1076 # 8001f7a0 <icache>
    80003374:	ffffe097          	auipc	ra,0xffffe
    80003378:	8f2080e7          	jalr	-1806(ra) # 80000c66 <acquire>
  empty = 0;
    8000337c:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000337e:	0001c497          	auipc	s1,0x1c
    80003382:	43a48493          	addi	s1,s1,1082 # 8001f7b8 <icache+0x18>
    80003386:	0001e697          	auipc	a3,0x1e
    8000338a:	ec268693          	addi	a3,a3,-318 # 80021248 <log>
    8000338e:	a039                	j	8000339c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003390:	02090b63          	beqz	s2,800033c6 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003394:	08848493          	addi	s1,s1,136
    80003398:	02d48a63          	beq	s1,a3,800033cc <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000339c:	449c                	lw	a5,8(s1)
    8000339e:	fef059e3          	blez	a5,80003390 <iget+0x38>
    800033a2:	4098                	lw	a4,0(s1)
    800033a4:	ff3716e3          	bne	a4,s3,80003390 <iget+0x38>
    800033a8:	40d8                	lw	a4,4(s1)
    800033aa:	ff4713e3          	bne	a4,s4,80003390 <iget+0x38>
      ip->ref++;
    800033ae:	2785                	addiw	a5,a5,1
    800033b0:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800033b2:	0001c517          	auipc	a0,0x1c
    800033b6:	3ee50513          	addi	a0,a0,1006 # 8001f7a0 <icache>
    800033ba:	ffffe097          	auipc	ra,0xffffe
    800033be:	960080e7          	jalr	-1696(ra) # 80000d1a <release>
      return ip;
    800033c2:	8926                	mv	s2,s1
    800033c4:	a03d                	j	800033f2 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033c6:	f7f9                	bnez	a5,80003394 <iget+0x3c>
    800033c8:	8926                	mv	s2,s1
    800033ca:	b7e9                	j	80003394 <iget+0x3c>
  if(empty == 0)
    800033cc:	02090c63          	beqz	s2,80003404 <iget+0xac>
  ip->dev = dev;
    800033d0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800033d4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800033d8:	4785                	li	a5,1
    800033da:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800033de:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800033e2:	0001c517          	auipc	a0,0x1c
    800033e6:	3be50513          	addi	a0,a0,958 # 8001f7a0 <icache>
    800033ea:	ffffe097          	auipc	ra,0xffffe
    800033ee:	930080e7          	jalr	-1744(ra) # 80000d1a <release>
}
    800033f2:	854a                	mv	a0,s2
    800033f4:	70a2                	ld	ra,40(sp)
    800033f6:	7402                	ld	s0,32(sp)
    800033f8:	64e2                	ld	s1,24(sp)
    800033fa:	6942                	ld	s2,16(sp)
    800033fc:	69a2                	ld	s3,8(sp)
    800033fe:	6a02                	ld	s4,0(sp)
    80003400:	6145                	addi	sp,sp,48
    80003402:	8082                	ret
    panic("iget: no inodes");
    80003404:	00005517          	auipc	a0,0x5
    80003408:	14c50513          	addi	a0,a0,332 # 80008550 <syscalls+0x158>
    8000340c:	ffffd097          	auipc	ra,0xffffd
    80003410:	16c080e7          	jalr	364(ra) # 80000578 <panic>

0000000080003414 <fsinit>:
fsinit(int dev) {
    80003414:	7179                	addi	sp,sp,-48
    80003416:	f406                	sd	ra,40(sp)
    80003418:	f022                	sd	s0,32(sp)
    8000341a:	ec26                	sd	s1,24(sp)
    8000341c:	e84a                	sd	s2,16(sp)
    8000341e:	e44e                	sd	s3,8(sp)
    80003420:	1800                	addi	s0,sp,48
    80003422:	89aa                	mv	s3,a0
  bp = bread(dev, 1);
    80003424:	4585                	li	a1,1
    80003426:	00000097          	auipc	ra,0x0
    8000342a:	a20080e7          	jalr	-1504(ra) # 80002e46 <bread>
    8000342e:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003430:	0001c497          	auipc	s1,0x1c
    80003434:	35048493          	addi	s1,s1,848 # 8001f780 <sb>
    80003438:	02000613          	li	a2,32
    8000343c:	05850593          	addi	a1,a0,88
    80003440:	8526                	mv	a0,s1
    80003442:	ffffe097          	auipc	ra,0xffffe
    80003446:	98c080e7          	jalr	-1652(ra) # 80000dce <memmove>
  brelse(bp);
    8000344a:	854a                	mv	a0,s2
    8000344c:	00000097          	auipc	ra,0x0
    80003450:	b3c080e7          	jalr	-1220(ra) # 80002f88 <brelse>
  if(sb.magic != FSMAGIC)
    80003454:	4098                	lw	a4,0(s1)
    80003456:	102037b7          	lui	a5,0x10203
    8000345a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000345e:	02f71263          	bne	a4,a5,80003482 <fsinit+0x6e>
  initlog(dev, &sb);
    80003462:	0001c597          	auipc	a1,0x1c
    80003466:	31e58593          	addi	a1,a1,798 # 8001f780 <sb>
    8000346a:	854e                	mv	a0,s3
    8000346c:	00001097          	auipc	ra,0x1
    80003470:	b5a080e7          	jalr	-1190(ra) # 80003fc6 <initlog>
}
    80003474:	70a2                	ld	ra,40(sp)
    80003476:	7402                	ld	s0,32(sp)
    80003478:	64e2                	ld	s1,24(sp)
    8000347a:	6942                	ld	s2,16(sp)
    8000347c:	69a2                	ld	s3,8(sp)
    8000347e:	6145                	addi	sp,sp,48
    80003480:	8082                	ret
    panic("invalid file system");
    80003482:	00005517          	auipc	a0,0x5
    80003486:	0de50513          	addi	a0,a0,222 # 80008560 <syscalls+0x168>
    8000348a:	ffffd097          	auipc	ra,0xffffd
    8000348e:	0ee080e7          	jalr	238(ra) # 80000578 <panic>

0000000080003492 <iinit>:
{
    80003492:	7179                	addi	sp,sp,-48
    80003494:	f406                	sd	ra,40(sp)
    80003496:	f022                	sd	s0,32(sp)
    80003498:	ec26                	sd	s1,24(sp)
    8000349a:	e84a                	sd	s2,16(sp)
    8000349c:	e44e                	sd	s3,8(sp)
    8000349e:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800034a0:	00005597          	auipc	a1,0x5
    800034a4:	0d858593          	addi	a1,a1,216 # 80008578 <syscalls+0x180>
    800034a8:	0001c517          	auipc	a0,0x1c
    800034ac:	2f850513          	addi	a0,a0,760 # 8001f7a0 <icache>
    800034b0:	ffffd097          	auipc	ra,0xffffd
    800034b4:	726080e7          	jalr	1830(ra) # 80000bd6 <initlock>
  for(i = 0; i < NINODE; i++) {
    800034b8:	0001c497          	auipc	s1,0x1c
    800034bc:	31048493          	addi	s1,s1,784 # 8001f7c8 <icache+0x28>
    800034c0:	0001e997          	auipc	s3,0x1e
    800034c4:	d9898993          	addi	s3,s3,-616 # 80021258 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800034c8:	00005917          	auipc	s2,0x5
    800034cc:	0b890913          	addi	s2,s2,184 # 80008580 <syscalls+0x188>
    800034d0:	85ca                	mv	a1,s2
    800034d2:	8526                	mv	a0,s1
    800034d4:	00001097          	auipc	ra,0x1
    800034d8:	e78080e7          	jalr	-392(ra) # 8000434c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034dc:	08848493          	addi	s1,s1,136
    800034e0:	ff3498e3          	bne	s1,s3,800034d0 <iinit+0x3e>
}
    800034e4:	70a2                	ld	ra,40(sp)
    800034e6:	7402                	ld	s0,32(sp)
    800034e8:	64e2                	ld	s1,24(sp)
    800034ea:	6942                	ld	s2,16(sp)
    800034ec:	69a2                	ld	s3,8(sp)
    800034ee:	6145                	addi	sp,sp,48
    800034f0:	8082                	ret

00000000800034f2 <ialloc>:
{
    800034f2:	715d                	addi	sp,sp,-80
    800034f4:	e486                	sd	ra,72(sp)
    800034f6:	e0a2                	sd	s0,64(sp)
    800034f8:	fc26                	sd	s1,56(sp)
    800034fa:	f84a                	sd	s2,48(sp)
    800034fc:	f44e                	sd	s3,40(sp)
    800034fe:	f052                	sd	s4,32(sp)
    80003500:	ec56                	sd	s5,24(sp)
    80003502:	e85a                	sd	s6,16(sp)
    80003504:	e45e                	sd	s7,8(sp)
    80003506:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003508:	0001c797          	auipc	a5,0x1c
    8000350c:	27878793          	addi	a5,a5,632 # 8001f780 <sb>
    80003510:	47d8                	lw	a4,12(a5)
    80003512:	4785                	li	a5,1
    80003514:	04e7fa63          	bleu	a4,a5,80003568 <ialloc+0x76>
    80003518:	8a2a                	mv	s4,a0
    8000351a:	8b2e                	mv	s6,a1
    8000351c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000351e:	0001c997          	auipc	s3,0x1c
    80003522:	26298993          	addi	s3,s3,610 # 8001f780 <sb>
    80003526:	00048a9b          	sext.w	s5,s1
    8000352a:	0044d593          	srli	a1,s1,0x4
    8000352e:	0189a783          	lw	a5,24(s3)
    80003532:	9dbd                	addw	a1,a1,a5
    80003534:	8552                	mv	a0,s4
    80003536:	00000097          	auipc	ra,0x0
    8000353a:	910080e7          	jalr	-1776(ra) # 80002e46 <bread>
    8000353e:	8baa                	mv	s7,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003540:	05850913          	addi	s2,a0,88
    80003544:	00f4f793          	andi	a5,s1,15
    80003548:	079a                	slli	a5,a5,0x6
    8000354a:	993e                	add	s2,s2,a5
    if(dip->type == 0){  // a free inode
    8000354c:	00091783          	lh	a5,0(s2)
    80003550:	c785                	beqz	a5,80003578 <ialloc+0x86>
    brelse(bp);
    80003552:	00000097          	auipc	ra,0x0
    80003556:	a36080e7          	jalr	-1482(ra) # 80002f88 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000355a:	0485                	addi	s1,s1,1
    8000355c:	00c9a703          	lw	a4,12(s3)
    80003560:	0004879b          	sext.w	a5,s1
    80003564:	fce7e1e3          	bltu	a5,a4,80003526 <ialloc+0x34>
  panic("ialloc: no inodes");
    80003568:	00005517          	auipc	a0,0x5
    8000356c:	02050513          	addi	a0,a0,32 # 80008588 <syscalls+0x190>
    80003570:	ffffd097          	auipc	ra,0xffffd
    80003574:	008080e7          	jalr	8(ra) # 80000578 <panic>
      memset(dip, 0, sizeof(*dip));
    80003578:	04000613          	li	a2,64
    8000357c:	4581                	li	a1,0
    8000357e:	854a                	mv	a0,s2
    80003580:	ffffd097          	auipc	ra,0xffffd
    80003584:	7e2080e7          	jalr	2018(ra) # 80000d62 <memset>
      dip->type = type;
    80003588:	01691023          	sh	s6,0(s2)
      log_write(bp);   // mark it allocated on the disk
    8000358c:	855e                	mv	a0,s7
    8000358e:	00001097          	auipc	ra,0x1
    80003592:	cba080e7          	jalr	-838(ra) # 80004248 <log_write>
      brelse(bp);
    80003596:	855e                	mv	a0,s7
    80003598:	00000097          	auipc	ra,0x0
    8000359c:	9f0080e7          	jalr	-1552(ra) # 80002f88 <brelse>
      return iget(dev, inum);
    800035a0:	85d6                	mv	a1,s5
    800035a2:	8552                	mv	a0,s4
    800035a4:	00000097          	auipc	ra,0x0
    800035a8:	db4080e7          	jalr	-588(ra) # 80003358 <iget>
}
    800035ac:	60a6                	ld	ra,72(sp)
    800035ae:	6406                	ld	s0,64(sp)
    800035b0:	74e2                	ld	s1,56(sp)
    800035b2:	7942                	ld	s2,48(sp)
    800035b4:	79a2                	ld	s3,40(sp)
    800035b6:	7a02                	ld	s4,32(sp)
    800035b8:	6ae2                	ld	s5,24(sp)
    800035ba:	6b42                	ld	s6,16(sp)
    800035bc:	6ba2                	ld	s7,8(sp)
    800035be:	6161                	addi	sp,sp,80
    800035c0:	8082                	ret

00000000800035c2 <iupdate>:
{
    800035c2:	1101                	addi	sp,sp,-32
    800035c4:	ec06                	sd	ra,24(sp)
    800035c6:	e822                	sd	s0,16(sp)
    800035c8:	e426                	sd	s1,8(sp)
    800035ca:	e04a                	sd	s2,0(sp)
    800035cc:	1000                	addi	s0,sp,32
    800035ce:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035d0:	415c                	lw	a5,4(a0)
    800035d2:	0047d79b          	srliw	a5,a5,0x4
    800035d6:	0001c717          	auipc	a4,0x1c
    800035da:	1aa70713          	addi	a4,a4,426 # 8001f780 <sb>
    800035de:	4f0c                	lw	a1,24(a4)
    800035e0:	9dbd                	addw	a1,a1,a5
    800035e2:	4108                	lw	a0,0(a0)
    800035e4:	00000097          	auipc	ra,0x0
    800035e8:	862080e7          	jalr	-1950(ra) # 80002e46 <bread>
    800035ec:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035ee:	05850513          	addi	a0,a0,88
    800035f2:	40dc                	lw	a5,4(s1)
    800035f4:	8bbd                	andi	a5,a5,15
    800035f6:	079a                	slli	a5,a5,0x6
    800035f8:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800035fa:	04449783          	lh	a5,68(s1)
    800035fe:	00f51023          	sh	a5,0(a0)
  dip->major = ip->major;
    80003602:	04649783          	lh	a5,70(s1)
    80003606:	00f51123          	sh	a5,2(a0)
  dip->minor = ip->minor;
    8000360a:	04849783          	lh	a5,72(s1)
    8000360e:	00f51223          	sh	a5,4(a0)
  dip->nlink = ip->nlink;
    80003612:	04a49783          	lh	a5,74(s1)
    80003616:	00f51323          	sh	a5,6(a0)
  dip->size = ip->size;
    8000361a:	44fc                	lw	a5,76(s1)
    8000361c:	c51c                	sw	a5,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000361e:	03400613          	li	a2,52
    80003622:	05048593          	addi	a1,s1,80
    80003626:	0531                	addi	a0,a0,12
    80003628:	ffffd097          	auipc	ra,0xffffd
    8000362c:	7a6080e7          	jalr	1958(ra) # 80000dce <memmove>
  log_write(bp);
    80003630:	854a                	mv	a0,s2
    80003632:	00001097          	auipc	ra,0x1
    80003636:	c16080e7          	jalr	-1002(ra) # 80004248 <log_write>
  brelse(bp);
    8000363a:	854a                	mv	a0,s2
    8000363c:	00000097          	auipc	ra,0x0
    80003640:	94c080e7          	jalr	-1716(ra) # 80002f88 <brelse>
}
    80003644:	60e2                	ld	ra,24(sp)
    80003646:	6442                	ld	s0,16(sp)
    80003648:	64a2                	ld	s1,8(sp)
    8000364a:	6902                	ld	s2,0(sp)
    8000364c:	6105                	addi	sp,sp,32
    8000364e:	8082                	ret

0000000080003650 <idup>:
{
    80003650:	1101                	addi	sp,sp,-32
    80003652:	ec06                	sd	ra,24(sp)
    80003654:	e822                	sd	s0,16(sp)
    80003656:	e426                	sd	s1,8(sp)
    80003658:	1000                	addi	s0,sp,32
    8000365a:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000365c:	0001c517          	auipc	a0,0x1c
    80003660:	14450513          	addi	a0,a0,324 # 8001f7a0 <icache>
    80003664:	ffffd097          	auipc	ra,0xffffd
    80003668:	602080e7          	jalr	1538(ra) # 80000c66 <acquire>
  ip->ref++;
    8000366c:	449c                	lw	a5,8(s1)
    8000366e:	2785                	addiw	a5,a5,1
    80003670:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003672:	0001c517          	auipc	a0,0x1c
    80003676:	12e50513          	addi	a0,a0,302 # 8001f7a0 <icache>
    8000367a:	ffffd097          	auipc	ra,0xffffd
    8000367e:	6a0080e7          	jalr	1696(ra) # 80000d1a <release>
}
    80003682:	8526                	mv	a0,s1
    80003684:	60e2                	ld	ra,24(sp)
    80003686:	6442                	ld	s0,16(sp)
    80003688:	64a2                	ld	s1,8(sp)
    8000368a:	6105                	addi	sp,sp,32
    8000368c:	8082                	ret

000000008000368e <ilock>:
{
    8000368e:	1101                	addi	sp,sp,-32
    80003690:	ec06                	sd	ra,24(sp)
    80003692:	e822                	sd	s0,16(sp)
    80003694:	e426                	sd	s1,8(sp)
    80003696:	e04a                	sd	s2,0(sp)
    80003698:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000369a:	c115                	beqz	a0,800036be <ilock+0x30>
    8000369c:	84aa                	mv	s1,a0
    8000369e:	451c                	lw	a5,8(a0)
    800036a0:	00f05f63          	blez	a5,800036be <ilock+0x30>
  acquiresleep(&ip->lock);
    800036a4:	0541                	addi	a0,a0,16
    800036a6:	00001097          	auipc	ra,0x1
    800036aa:	ce0080e7          	jalr	-800(ra) # 80004386 <acquiresleep>
  if(ip->valid == 0){
    800036ae:	40bc                	lw	a5,64(s1)
    800036b0:	cf99                	beqz	a5,800036ce <ilock+0x40>
}
    800036b2:	60e2                	ld	ra,24(sp)
    800036b4:	6442                	ld	s0,16(sp)
    800036b6:	64a2                	ld	s1,8(sp)
    800036b8:	6902                	ld	s2,0(sp)
    800036ba:	6105                	addi	sp,sp,32
    800036bc:	8082                	ret
    panic("ilock");
    800036be:	00005517          	auipc	a0,0x5
    800036c2:	ee250513          	addi	a0,a0,-286 # 800085a0 <syscalls+0x1a8>
    800036c6:	ffffd097          	auipc	ra,0xffffd
    800036ca:	eb2080e7          	jalr	-334(ra) # 80000578 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036ce:	40dc                	lw	a5,4(s1)
    800036d0:	0047d79b          	srliw	a5,a5,0x4
    800036d4:	0001c717          	auipc	a4,0x1c
    800036d8:	0ac70713          	addi	a4,a4,172 # 8001f780 <sb>
    800036dc:	4f0c                	lw	a1,24(a4)
    800036de:	9dbd                	addw	a1,a1,a5
    800036e0:	4088                	lw	a0,0(s1)
    800036e2:	fffff097          	auipc	ra,0xfffff
    800036e6:	764080e7          	jalr	1892(ra) # 80002e46 <bread>
    800036ea:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036ec:	05850593          	addi	a1,a0,88
    800036f0:	40dc                	lw	a5,4(s1)
    800036f2:	8bbd                	andi	a5,a5,15
    800036f4:	079a                	slli	a5,a5,0x6
    800036f6:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036f8:	00059783          	lh	a5,0(a1)
    800036fc:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003700:	00259783          	lh	a5,2(a1)
    80003704:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003708:	00459783          	lh	a5,4(a1)
    8000370c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003710:	00659783          	lh	a5,6(a1)
    80003714:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003718:	459c                	lw	a5,8(a1)
    8000371a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000371c:	03400613          	li	a2,52
    80003720:	05b1                	addi	a1,a1,12
    80003722:	05048513          	addi	a0,s1,80
    80003726:	ffffd097          	auipc	ra,0xffffd
    8000372a:	6a8080e7          	jalr	1704(ra) # 80000dce <memmove>
    brelse(bp);
    8000372e:	854a                	mv	a0,s2
    80003730:	00000097          	auipc	ra,0x0
    80003734:	858080e7          	jalr	-1960(ra) # 80002f88 <brelse>
    ip->valid = 1;
    80003738:	4785                	li	a5,1
    8000373a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000373c:	04449783          	lh	a5,68(s1)
    80003740:	fbad                	bnez	a5,800036b2 <ilock+0x24>
      panic("ilock: no type");
    80003742:	00005517          	auipc	a0,0x5
    80003746:	e6650513          	addi	a0,a0,-410 # 800085a8 <syscalls+0x1b0>
    8000374a:	ffffd097          	auipc	ra,0xffffd
    8000374e:	e2e080e7          	jalr	-466(ra) # 80000578 <panic>

0000000080003752 <iunlock>:
{
    80003752:	1101                	addi	sp,sp,-32
    80003754:	ec06                	sd	ra,24(sp)
    80003756:	e822                	sd	s0,16(sp)
    80003758:	e426                	sd	s1,8(sp)
    8000375a:	e04a                	sd	s2,0(sp)
    8000375c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000375e:	c905                	beqz	a0,8000378e <iunlock+0x3c>
    80003760:	84aa                	mv	s1,a0
    80003762:	01050913          	addi	s2,a0,16
    80003766:	854a                	mv	a0,s2
    80003768:	00001097          	auipc	ra,0x1
    8000376c:	cb8080e7          	jalr	-840(ra) # 80004420 <holdingsleep>
    80003770:	cd19                	beqz	a0,8000378e <iunlock+0x3c>
    80003772:	449c                	lw	a5,8(s1)
    80003774:	00f05d63          	blez	a5,8000378e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003778:	854a                	mv	a0,s2
    8000377a:	00001097          	auipc	ra,0x1
    8000377e:	c62080e7          	jalr	-926(ra) # 800043dc <releasesleep>
}
    80003782:	60e2                	ld	ra,24(sp)
    80003784:	6442                	ld	s0,16(sp)
    80003786:	64a2                	ld	s1,8(sp)
    80003788:	6902                	ld	s2,0(sp)
    8000378a:	6105                	addi	sp,sp,32
    8000378c:	8082                	ret
    panic("iunlock");
    8000378e:	00005517          	auipc	a0,0x5
    80003792:	e2a50513          	addi	a0,a0,-470 # 800085b8 <syscalls+0x1c0>
    80003796:	ffffd097          	auipc	ra,0xffffd
    8000379a:	de2080e7          	jalr	-542(ra) # 80000578 <panic>

000000008000379e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000379e:	7179                	addi	sp,sp,-48
    800037a0:	f406                	sd	ra,40(sp)
    800037a2:	f022                	sd	s0,32(sp)
    800037a4:	ec26                	sd	s1,24(sp)
    800037a6:	e84a                	sd	s2,16(sp)
    800037a8:	e44e                	sd	s3,8(sp)
    800037aa:	e052                	sd	s4,0(sp)
    800037ac:	1800                	addi	s0,sp,48
    800037ae:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800037b0:	05050493          	addi	s1,a0,80
    800037b4:	08050913          	addi	s2,a0,128
    800037b8:	a821                	j	800037d0 <itrunc+0x32>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    800037ba:	0009a503          	lw	a0,0(s3)
    800037be:	00000097          	auipc	ra,0x0
    800037c2:	8e0080e7          	jalr	-1824(ra) # 8000309e <bfree>
      ip->addrs[i] = 0;
    800037c6:	0004a023          	sw	zero,0(s1)
  for(i = 0; i < NDIRECT; i++){
    800037ca:	0491                	addi	s1,s1,4
    800037cc:	01248563          	beq	s1,s2,800037d6 <itrunc+0x38>
    if(ip->addrs[i]){
    800037d0:	408c                	lw	a1,0(s1)
    800037d2:	dde5                	beqz	a1,800037ca <itrunc+0x2c>
    800037d4:	b7dd                	j	800037ba <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037d6:	0809a583          	lw	a1,128(s3)
    800037da:	e185                	bnez	a1,800037fa <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037dc:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800037e0:	854e                	mv	a0,s3
    800037e2:	00000097          	auipc	ra,0x0
    800037e6:	de0080e7          	jalr	-544(ra) # 800035c2 <iupdate>
}
    800037ea:	70a2                	ld	ra,40(sp)
    800037ec:	7402                	ld	s0,32(sp)
    800037ee:	64e2                	ld	s1,24(sp)
    800037f0:	6942                	ld	s2,16(sp)
    800037f2:	69a2                	ld	s3,8(sp)
    800037f4:	6a02                	ld	s4,0(sp)
    800037f6:	6145                	addi	sp,sp,48
    800037f8:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800037fa:	0009a503          	lw	a0,0(s3)
    800037fe:	fffff097          	auipc	ra,0xfffff
    80003802:	648080e7          	jalr	1608(ra) # 80002e46 <bread>
    80003806:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003808:	05850493          	addi	s1,a0,88
    8000380c:	45850913          	addi	s2,a0,1112
    80003810:	a811                	j	80003824 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003812:	0009a503          	lw	a0,0(s3)
    80003816:	00000097          	auipc	ra,0x0
    8000381a:	888080e7          	jalr	-1912(ra) # 8000309e <bfree>
    for(j = 0; j < NINDIRECT; j++){
    8000381e:	0491                	addi	s1,s1,4
    80003820:	01248563          	beq	s1,s2,8000382a <itrunc+0x8c>
      if(a[j])
    80003824:	408c                	lw	a1,0(s1)
    80003826:	dde5                	beqz	a1,8000381e <itrunc+0x80>
    80003828:	b7ed                	j	80003812 <itrunc+0x74>
    brelse(bp);
    8000382a:	8552                	mv	a0,s4
    8000382c:	fffff097          	auipc	ra,0xfffff
    80003830:	75c080e7          	jalr	1884(ra) # 80002f88 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003834:	0809a583          	lw	a1,128(s3)
    80003838:	0009a503          	lw	a0,0(s3)
    8000383c:	00000097          	auipc	ra,0x0
    80003840:	862080e7          	jalr	-1950(ra) # 8000309e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003844:	0809a023          	sw	zero,128(s3)
    80003848:	bf51                	j	800037dc <itrunc+0x3e>

000000008000384a <iput>:
{
    8000384a:	1101                	addi	sp,sp,-32
    8000384c:	ec06                	sd	ra,24(sp)
    8000384e:	e822                	sd	s0,16(sp)
    80003850:	e426                	sd	s1,8(sp)
    80003852:	e04a                	sd	s2,0(sp)
    80003854:	1000                	addi	s0,sp,32
    80003856:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003858:	0001c517          	auipc	a0,0x1c
    8000385c:	f4850513          	addi	a0,a0,-184 # 8001f7a0 <icache>
    80003860:	ffffd097          	auipc	ra,0xffffd
    80003864:	406080e7          	jalr	1030(ra) # 80000c66 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003868:	4498                	lw	a4,8(s1)
    8000386a:	4785                	li	a5,1
    8000386c:	02f70363          	beq	a4,a5,80003892 <iput+0x48>
  ip->ref--;
    80003870:	449c                	lw	a5,8(s1)
    80003872:	37fd                	addiw	a5,a5,-1
    80003874:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003876:	0001c517          	auipc	a0,0x1c
    8000387a:	f2a50513          	addi	a0,a0,-214 # 8001f7a0 <icache>
    8000387e:	ffffd097          	auipc	ra,0xffffd
    80003882:	49c080e7          	jalr	1180(ra) # 80000d1a <release>
}
    80003886:	60e2                	ld	ra,24(sp)
    80003888:	6442                	ld	s0,16(sp)
    8000388a:	64a2                	ld	s1,8(sp)
    8000388c:	6902                	ld	s2,0(sp)
    8000388e:	6105                	addi	sp,sp,32
    80003890:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003892:	40bc                	lw	a5,64(s1)
    80003894:	dff1                	beqz	a5,80003870 <iput+0x26>
    80003896:	04a49783          	lh	a5,74(s1)
    8000389a:	fbf9                	bnez	a5,80003870 <iput+0x26>
    acquiresleep(&ip->lock);
    8000389c:	01048913          	addi	s2,s1,16
    800038a0:	854a                	mv	a0,s2
    800038a2:	00001097          	auipc	ra,0x1
    800038a6:	ae4080e7          	jalr	-1308(ra) # 80004386 <acquiresleep>
    release(&icache.lock);
    800038aa:	0001c517          	auipc	a0,0x1c
    800038ae:	ef650513          	addi	a0,a0,-266 # 8001f7a0 <icache>
    800038b2:	ffffd097          	auipc	ra,0xffffd
    800038b6:	468080e7          	jalr	1128(ra) # 80000d1a <release>
    itrunc(ip);
    800038ba:	8526                	mv	a0,s1
    800038bc:	00000097          	auipc	ra,0x0
    800038c0:	ee2080e7          	jalr	-286(ra) # 8000379e <itrunc>
    ip->type = 0;
    800038c4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800038c8:	8526                	mv	a0,s1
    800038ca:	00000097          	auipc	ra,0x0
    800038ce:	cf8080e7          	jalr	-776(ra) # 800035c2 <iupdate>
    ip->valid = 0;
    800038d2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038d6:	854a                	mv	a0,s2
    800038d8:	00001097          	auipc	ra,0x1
    800038dc:	b04080e7          	jalr	-1276(ra) # 800043dc <releasesleep>
    acquire(&icache.lock);
    800038e0:	0001c517          	auipc	a0,0x1c
    800038e4:	ec050513          	addi	a0,a0,-320 # 8001f7a0 <icache>
    800038e8:	ffffd097          	auipc	ra,0xffffd
    800038ec:	37e080e7          	jalr	894(ra) # 80000c66 <acquire>
    800038f0:	b741                	j	80003870 <iput+0x26>

00000000800038f2 <iunlockput>:
{
    800038f2:	1101                	addi	sp,sp,-32
    800038f4:	ec06                	sd	ra,24(sp)
    800038f6:	e822                	sd	s0,16(sp)
    800038f8:	e426                	sd	s1,8(sp)
    800038fa:	1000                	addi	s0,sp,32
    800038fc:	84aa                	mv	s1,a0
  iunlock(ip);
    800038fe:	00000097          	auipc	ra,0x0
    80003902:	e54080e7          	jalr	-428(ra) # 80003752 <iunlock>
  iput(ip);
    80003906:	8526                	mv	a0,s1
    80003908:	00000097          	auipc	ra,0x0
    8000390c:	f42080e7          	jalr	-190(ra) # 8000384a <iput>
}
    80003910:	60e2                	ld	ra,24(sp)
    80003912:	6442                	ld	s0,16(sp)
    80003914:	64a2                	ld	s1,8(sp)
    80003916:	6105                	addi	sp,sp,32
    80003918:	8082                	ret

000000008000391a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000391a:	1141                	addi	sp,sp,-16
    8000391c:	e422                	sd	s0,8(sp)
    8000391e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003920:	411c                	lw	a5,0(a0)
    80003922:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003924:	415c                	lw	a5,4(a0)
    80003926:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003928:	04451783          	lh	a5,68(a0)
    8000392c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003930:	04a51783          	lh	a5,74(a0)
    80003934:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003938:	04c56783          	lwu	a5,76(a0)
    8000393c:	e99c                	sd	a5,16(a1)
}
    8000393e:	6422                	ld	s0,8(sp)
    80003940:	0141                	addi	sp,sp,16
    80003942:	8082                	ret

0000000080003944 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003944:	457c                	lw	a5,76(a0)
    80003946:	0ed7e963          	bltu	a5,a3,80003a38 <readi+0xf4>
{
    8000394a:	7159                	addi	sp,sp,-112
    8000394c:	f486                	sd	ra,104(sp)
    8000394e:	f0a2                	sd	s0,96(sp)
    80003950:	eca6                	sd	s1,88(sp)
    80003952:	e8ca                	sd	s2,80(sp)
    80003954:	e4ce                	sd	s3,72(sp)
    80003956:	e0d2                	sd	s4,64(sp)
    80003958:	fc56                	sd	s5,56(sp)
    8000395a:	f85a                	sd	s6,48(sp)
    8000395c:	f45e                	sd	s7,40(sp)
    8000395e:	f062                	sd	s8,32(sp)
    80003960:	ec66                	sd	s9,24(sp)
    80003962:	e86a                	sd	s10,16(sp)
    80003964:	e46e                	sd	s11,8(sp)
    80003966:	1880                	addi	s0,sp,112
    80003968:	8baa                	mv	s7,a0
    8000396a:	8c2e                	mv	s8,a1
    8000396c:	8a32                	mv	s4,a2
    8000396e:	84b6                	mv	s1,a3
    80003970:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003972:	9f35                	addw	a4,a4,a3
    return 0;
    80003974:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003976:	0ad76063          	bltu	a4,a3,80003a16 <readi+0xd2>
  if(off + n > ip->size)
    8000397a:	00e7f463          	bleu	a4,a5,80003982 <readi+0x3e>
    n = ip->size - off;
    8000397e:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003982:	0a0b0963          	beqz	s6,80003a34 <readi+0xf0>
    80003986:	4901                	li	s2,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003988:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000398c:	5cfd                	li	s9,-1
    8000398e:	a82d                	j	800039c8 <readi+0x84>
    80003990:	02099d93          	slli	s11,s3,0x20
    80003994:	020ddd93          	srli	s11,s11,0x20
    80003998:	058a8613          	addi	a2,s5,88
    8000399c:	86ee                	mv	a3,s11
    8000399e:	963a                	add	a2,a2,a4
    800039a0:	85d2                	mv	a1,s4
    800039a2:	8562                	mv	a0,s8
    800039a4:	fffff097          	auipc	ra,0xfffff
    800039a8:	ad6080e7          	jalr	-1322(ra) # 8000247a <either_copyout>
    800039ac:	05950d63          	beq	a0,s9,80003a06 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800039b0:	8556                	mv	a0,s5
    800039b2:	fffff097          	auipc	ra,0xfffff
    800039b6:	5d6080e7          	jalr	1494(ra) # 80002f88 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039ba:	0129893b          	addw	s2,s3,s2
    800039be:	009984bb          	addw	s1,s3,s1
    800039c2:	9a6e                	add	s4,s4,s11
    800039c4:	05697763          	bleu	s6,s2,80003a12 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800039c8:	000ba983          	lw	s3,0(s7)
    800039cc:	00a4d59b          	srliw	a1,s1,0xa
    800039d0:	855e                	mv	a0,s7
    800039d2:	00000097          	auipc	ra,0x0
    800039d6:	8ac080e7          	jalr	-1876(ra) # 8000327e <bmap>
    800039da:	0005059b          	sext.w	a1,a0
    800039de:	854e                	mv	a0,s3
    800039e0:	fffff097          	auipc	ra,0xfffff
    800039e4:	466080e7          	jalr	1126(ra) # 80002e46 <bread>
    800039e8:	8aaa                	mv	s5,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039ea:	3ff4f713          	andi	a4,s1,1023
    800039ee:	40ed07bb          	subw	a5,s10,a4
    800039f2:	412b06bb          	subw	a3,s6,s2
    800039f6:	89be                	mv	s3,a5
    800039f8:	2781                	sext.w	a5,a5
    800039fa:	0006861b          	sext.w	a2,a3
    800039fe:	f8f679e3          	bleu	a5,a2,80003990 <readi+0x4c>
    80003a02:	89b6                	mv	s3,a3
    80003a04:	b771                	j	80003990 <readi+0x4c>
      brelse(bp);
    80003a06:	8556                	mv	a0,s5
    80003a08:	fffff097          	auipc	ra,0xfffff
    80003a0c:	580080e7          	jalr	1408(ra) # 80002f88 <brelse>
      tot = -1;
    80003a10:	597d                	li	s2,-1
  }
  return tot;
    80003a12:	0009051b          	sext.w	a0,s2
}
    80003a16:	70a6                	ld	ra,104(sp)
    80003a18:	7406                	ld	s0,96(sp)
    80003a1a:	64e6                	ld	s1,88(sp)
    80003a1c:	6946                	ld	s2,80(sp)
    80003a1e:	69a6                	ld	s3,72(sp)
    80003a20:	6a06                	ld	s4,64(sp)
    80003a22:	7ae2                	ld	s5,56(sp)
    80003a24:	7b42                	ld	s6,48(sp)
    80003a26:	7ba2                	ld	s7,40(sp)
    80003a28:	7c02                	ld	s8,32(sp)
    80003a2a:	6ce2                	ld	s9,24(sp)
    80003a2c:	6d42                	ld	s10,16(sp)
    80003a2e:	6da2                	ld	s11,8(sp)
    80003a30:	6165                	addi	sp,sp,112
    80003a32:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a34:	895a                	mv	s2,s6
    80003a36:	bff1                	j	80003a12 <readi+0xce>
    return 0;
    80003a38:	4501                	li	a0,0
}
    80003a3a:	8082                	ret

0000000080003a3c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a3c:	457c                	lw	a5,76(a0)
    80003a3e:	10d7e763          	bltu	a5,a3,80003b4c <writei+0x110>
{
    80003a42:	7159                	addi	sp,sp,-112
    80003a44:	f486                	sd	ra,104(sp)
    80003a46:	f0a2                	sd	s0,96(sp)
    80003a48:	eca6                	sd	s1,88(sp)
    80003a4a:	e8ca                	sd	s2,80(sp)
    80003a4c:	e4ce                	sd	s3,72(sp)
    80003a4e:	e0d2                	sd	s4,64(sp)
    80003a50:	fc56                	sd	s5,56(sp)
    80003a52:	f85a                	sd	s6,48(sp)
    80003a54:	f45e                	sd	s7,40(sp)
    80003a56:	f062                	sd	s8,32(sp)
    80003a58:	ec66                	sd	s9,24(sp)
    80003a5a:	e86a                	sd	s10,16(sp)
    80003a5c:	e46e                	sd	s11,8(sp)
    80003a5e:	1880                	addi	s0,sp,112
    80003a60:	8baa                	mv	s7,a0
    80003a62:	8c2e                	mv	s8,a1
    80003a64:	8ab2                	mv	s5,a2
    80003a66:	84b6                	mv	s1,a3
    80003a68:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a6a:	00e687bb          	addw	a5,a3,a4
    80003a6e:	0ed7e163          	bltu	a5,a3,80003b50 <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a72:	00043737          	lui	a4,0x43
    80003a76:	0cf76f63          	bltu	a4,a5,80003b54 <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a7a:	0a0b0863          	beqz	s6,80003b2a <writei+0xee>
    80003a7e:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a80:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a84:	5cfd                	li	s9,-1
    80003a86:	a091                	j	80003aca <writei+0x8e>
    80003a88:	02091d93          	slli	s11,s2,0x20
    80003a8c:	020ddd93          	srli	s11,s11,0x20
    80003a90:	05898513          	addi	a0,s3,88
    80003a94:	86ee                	mv	a3,s11
    80003a96:	8656                	mv	a2,s5
    80003a98:	85e2                	mv	a1,s8
    80003a9a:	953a                	add	a0,a0,a4
    80003a9c:	fffff097          	auipc	ra,0xfffff
    80003aa0:	a34080e7          	jalr	-1484(ra) # 800024d0 <either_copyin>
    80003aa4:	07950263          	beq	a0,s9,80003b08 <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80003aa8:	854e                	mv	a0,s3
    80003aaa:	00000097          	auipc	ra,0x0
    80003aae:	79e080e7          	jalr	1950(ra) # 80004248 <log_write>
    brelse(bp);
    80003ab2:	854e                	mv	a0,s3
    80003ab4:	fffff097          	auipc	ra,0xfffff
    80003ab8:	4d4080e7          	jalr	1236(ra) # 80002f88 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003abc:	01490a3b          	addw	s4,s2,s4
    80003ac0:	009904bb          	addw	s1,s2,s1
    80003ac4:	9aee                	add	s5,s5,s11
    80003ac6:	056a7763          	bleu	s6,s4,80003b14 <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003aca:	000ba903          	lw	s2,0(s7)
    80003ace:	00a4d59b          	srliw	a1,s1,0xa
    80003ad2:	855e                	mv	a0,s7
    80003ad4:	fffff097          	auipc	ra,0xfffff
    80003ad8:	7aa080e7          	jalr	1962(ra) # 8000327e <bmap>
    80003adc:	0005059b          	sext.w	a1,a0
    80003ae0:	854a                	mv	a0,s2
    80003ae2:	fffff097          	auipc	ra,0xfffff
    80003ae6:	364080e7          	jalr	868(ra) # 80002e46 <bread>
    80003aea:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aec:	3ff4f713          	andi	a4,s1,1023
    80003af0:	40ed07bb          	subw	a5,s10,a4
    80003af4:	414b06bb          	subw	a3,s6,s4
    80003af8:	893e                	mv	s2,a5
    80003afa:	2781                	sext.w	a5,a5
    80003afc:	0006861b          	sext.w	a2,a3
    80003b00:	f8f674e3          	bleu	a5,a2,80003a88 <writei+0x4c>
    80003b04:	8936                	mv	s2,a3
    80003b06:	b749                	j	80003a88 <writei+0x4c>
      brelse(bp);
    80003b08:	854e                	mv	a0,s3
    80003b0a:	fffff097          	auipc	ra,0xfffff
    80003b0e:	47e080e7          	jalr	1150(ra) # 80002f88 <brelse>
      n = -1;
    80003b12:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003b14:	04cba783          	lw	a5,76(s7)
    80003b18:	0097f463          	bleu	s1,a5,80003b20 <writei+0xe4>
      ip->size = off;
    80003b1c:	049ba623          	sw	s1,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003b20:	855e                	mv	a0,s7
    80003b22:	00000097          	auipc	ra,0x0
    80003b26:	aa0080e7          	jalr	-1376(ra) # 800035c2 <iupdate>
  }

  return n;
    80003b2a:	000b051b          	sext.w	a0,s6
}
    80003b2e:	70a6                	ld	ra,104(sp)
    80003b30:	7406                	ld	s0,96(sp)
    80003b32:	64e6                	ld	s1,88(sp)
    80003b34:	6946                	ld	s2,80(sp)
    80003b36:	69a6                	ld	s3,72(sp)
    80003b38:	6a06                	ld	s4,64(sp)
    80003b3a:	7ae2                	ld	s5,56(sp)
    80003b3c:	7b42                	ld	s6,48(sp)
    80003b3e:	7ba2                	ld	s7,40(sp)
    80003b40:	7c02                	ld	s8,32(sp)
    80003b42:	6ce2                	ld	s9,24(sp)
    80003b44:	6d42                	ld	s10,16(sp)
    80003b46:	6da2                	ld	s11,8(sp)
    80003b48:	6165                	addi	sp,sp,112
    80003b4a:	8082                	ret
    return -1;
    80003b4c:	557d                	li	a0,-1
}
    80003b4e:	8082                	ret
    return -1;
    80003b50:	557d                	li	a0,-1
    80003b52:	bff1                	j	80003b2e <writei+0xf2>
    return -1;
    80003b54:	557d                	li	a0,-1
    80003b56:	bfe1                	j	80003b2e <writei+0xf2>

0000000080003b58 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b58:	1141                	addi	sp,sp,-16
    80003b5a:	e406                	sd	ra,8(sp)
    80003b5c:	e022                	sd	s0,0(sp)
    80003b5e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b60:	4639                	li	a2,14
    80003b62:	ffffd097          	auipc	ra,0xffffd
    80003b66:	2e8080e7          	jalr	744(ra) # 80000e4a <strncmp>
}
    80003b6a:	60a2                	ld	ra,8(sp)
    80003b6c:	6402                	ld	s0,0(sp)
    80003b6e:	0141                	addi	sp,sp,16
    80003b70:	8082                	ret

0000000080003b72 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b72:	7139                	addi	sp,sp,-64
    80003b74:	fc06                	sd	ra,56(sp)
    80003b76:	f822                	sd	s0,48(sp)
    80003b78:	f426                	sd	s1,40(sp)
    80003b7a:	f04a                	sd	s2,32(sp)
    80003b7c:	ec4e                	sd	s3,24(sp)
    80003b7e:	e852                	sd	s4,16(sp)
    80003b80:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b82:	04451703          	lh	a4,68(a0)
    80003b86:	4785                	li	a5,1
    80003b88:	00f71a63          	bne	a4,a5,80003b9c <dirlookup+0x2a>
    80003b8c:	892a                	mv	s2,a0
    80003b8e:	89ae                	mv	s3,a1
    80003b90:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b92:	457c                	lw	a5,76(a0)
    80003b94:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b96:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b98:	e79d                	bnez	a5,80003bc6 <dirlookup+0x54>
    80003b9a:	a8a5                	j	80003c12 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b9c:	00005517          	auipc	a0,0x5
    80003ba0:	a2450513          	addi	a0,a0,-1500 # 800085c0 <syscalls+0x1c8>
    80003ba4:	ffffd097          	auipc	ra,0xffffd
    80003ba8:	9d4080e7          	jalr	-1580(ra) # 80000578 <panic>
      panic("dirlookup read");
    80003bac:	00005517          	auipc	a0,0x5
    80003bb0:	a2c50513          	addi	a0,a0,-1492 # 800085d8 <syscalls+0x1e0>
    80003bb4:	ffffd097          	auipc	ra,0xffffd
    80003bb8:	9c4080e7          	jalr	-1596(ra) # 80000578 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bbc:	24c1                	addiw	s1,s1,16
    80003bbe:	04c92783          	lw	a5,76(s2)
    80003bc2:	04f4f763          	bleu	a5,s1,80003c10 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bc6:	4741                	li	a4,16
    80003bc8:	86a6                	mv	a3,s1
    80003bca:	fc040613          	addi	a2,s0,-64
    80003bce:	4581                	li	a1,0
    80003bd0:	854a                	mv	a0,s2
    80003bd2:	00000097          	auipc	ra,0x0
    80003bd6:	d72080e7          	jalr	-654(ra) # 80003944 <readi>
    80003bda:	47c1                	li	a5,16
    80003bdc:	fcf518e3          	bne	a0,a5,80003bac <dirlookup+0x3a>
    if(de.inum == 0)
    80003be0:	fc045783          	lhu	a5,-64(s0)
    80003be4:	dfe1                	beqz	a5,80003bbc <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003be6:	fc240593          	addi	a1,s0,-62
    80003bea:	854e                	mv	a0,s3
    80003bec:	00000097          	auipc	ra,0x0
    80003bf0:	f6c080e7          	jalr	-148(ra) # 80003b58 <namecmp>
    80003bf4:	f561                	bnez	a0,80003bbc <dirlookup+0x4a>
      if(poff)
    80003bf6:	000a0463          	beqz	s4,80003bfe <dirlookup+0x8c>
        *poff = off;
    80003bfa:	009a2023          	sw	s1,0(s4) # 2000 <_entry-0x7fffe000>
      return iget(dp->dev, inum);
    80003bfe:	fc045583          	lhu	a1,-64(s0)
    80003c02:	00092503          	lw	a0,0(s2)
    80003c06:	fffff097          	auipc	ra,0xfffff
    80003c0a:	752080e7          	jalr	1874(ra) # 80003358 <iget>
    80003c0e:	a011                	j	80003c12 <dirlookup+0xa0>
  return 0;
    80003c10:	4501                	li	a0,0
}
    80003c12:	70e2                	ld	ra,56(sp)
    80003c14:	7442                	ld	s0,48(sp)
    80003c16:	74a2                	ld	s1,40(sp)
    80003c18:	7902                	ld	s2,32(sp)
    80003c1a:	69e2                	ld	s3,24(sp)
    80003c1c:	6a42                	ld	s4,16(sp)
    80003c1e:	6121                	addi	sp,sp,64
    80003c20:	8082                	ret

0000000080003c22 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c22:	711d                	addi	sp,sp,-96
    80003c24:	ec86                	sd	ra,88(sp)
    80003c26:	e8a2                	sd	s0,80(sp)
    80003c28:	e4a6                	sd	s1,72(sp)
    80003c2a:	e0ca                	sd	s2,64(sp)
    80003c2c:	fc4e                	sd	s3,56(sp)
    80003c2e:	f852                	sd	s4,48(sp)
    80003c30:	f456                	sd	s5,40(sp)
    80003c32:	f05a                	sd	s6,32(sp)
    80003c34:	ec5e                	sd	s7,24(sp)
    80003c36:	e862                	sd	s8,16(sp)
    80003c38:	e466                	sd	s9,8(sp)
    80003c3a:	1080                	addi	s0,sp,96
    80003c3c:	84aa                	mv	s1,a0
    80003c3e:	8bae                	mv	s7,a1
    80003c40:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c42:	00054703          	lbu	a4,0(a0)
    80003c46:	02f00793          	li	a5,47
    80003c4a:	02f70363          	beq	a4,a5,80003c70 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c4e:	ffffe097          	auipc	ra,0xffffe
    80003c52:	db0080e7          	jalr	-592(ra) # 800019fe <myproc>
    80003c56:	15053503          	ld	a0,336(a0)
    80003c5a:	00000097          	auipc	ra,0x0
    80003c5e:	9f6080e7          	jalr	-1546(ra) # 80003650 <idup>
    80003c62:	89aa                	mv	s3,a0
  while(*path == '/')
    80003c64:	02f00913          	li	s2,47
  len = path - s;
    80003c68:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003c6a:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c6c:	4c05                	li	s8,1
    80003c6e:	a865                	j	80003d26 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003c70:	4585                	li	a1,1
    80003c72:	4505                	li	a0,1
    80003c74:	fffff097          	auipc	ra,0xfffff
    80003c78:	6e4080e7          	jalr	1764(ra) # 80003358 <iget>
    80003c7c:	89aa                	mv	s3,a0
    80003c7e:	b7dd                	j	80003c64 <namex+0x42>
      iunlockput(ip);
    80003c80:	854e                	mv	a0,s3
    80003c82:	00000097          	auipc	ra,0x0
    80003c86:	c70080e7          	jalr	-912(ra) # 800038f2 <iunlockput>
      return 0;
    80003c8a:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c8c:	854e                	mv	a0,s3
    80003c8e:	60e6                	ld	ra,88(sp)
    80003c90:	6446                	ld	s0,80(sp)
    80003c92:	64a6                	ld	s1,72(sp)
    80003c94:	6906                	ld	s2,64(sp)
    80003c96:	79e2                	ld	s3,56(sp)
    80003c98:	7a42                	ld	s4,48(sp)
    80003c9a:	7aa2                	ld	s5,40(sp)
    80003c9c:	7b02                	ld	s6,32(sp)
    80003c9e:	6be2                	ld	s7,24(sp)
    80003ca0:	6c42                	ld	s8,16(sp)
    80003ca2:	6ca2                	ld	s9,8(sp)
    80003ca4:	6125                	addi	sp,sp,96
    80003ca6:	8082                	ret
      iunlock(ip);
    80003ca8:	854e                	mv	a0,s3
    80003caa:	00000097          	auipc	ra,0x0
    80003cae:	aa8080e7          	jalr	-1368(ra) # 80003752 <iunlock>
      return ip;
    80003cb2:	bfe9                	j	80003c8c <namex+0x6a>
      iunlockput(ip);
    80003cb4:	854e                	mv	a0,s3
    80003cb6:	00000097          	auipc	ra,0x0
    80003cba:	c3c080e7          	jalr	-964(ra) # 800038f2 <iunlockput>
      return 0;
    80003cbe:	89d2                	mv	s3,s4
    80003cc0:	b7f1                	j	80003c8c <namex+0x6a>
  len = path - s;
    80003cc2:	40b48633          	sub	a2,s1,a1
    80003cc6:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003cca:	094cd663          	ble	s4,s9,80003d56 <namex+0x134>
    memmove(name, s, DIRSIZ);
    80003cce:	4639                	li	a2,14
    80003cd0:	8556                	mv	a0,s5
    80003cd2:	ffffd097          	auipc	ra,0xffffd
    80003cd6:	0fc080e7          	jalr	252(ra) # 80000dce <memmove>
  while(*path == '/')
    80003cda:	0004c783          	lbu	a5,0(s1)
    80003cde:	01279763          	bne	a5,s2,80003cec <namex+0xca>
    path++;
    80003ce2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ce4:	0004c783          	lbu	a5,0(s1)
    80003ce8:	ff278de3          	beq	a5,s2,80003ce2 <namex+0xc0>
    ilock(ip);
    80003cec:	854e                	mv	a0,s3
    80003cee:	00000097          	auipc	ra,0x0
    80003cf2:	9a0080e7          	jalr	-1632(ra) # 8000368e <ilock>
    if(ip->type != T_DIR){
    80003cf6:	04499783          	lh	a5,68(s3)
    80003cfa:	f98793e3          	bne	a5,s8,80003c80 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003cfe:	000b8563          	beqz	s7,80003d08 <namex+0xe6>
    80003d02:	0004c783          	lbu	a5,0(s1)
    80003d06:	d3cd                	beqz	a5,80003ca8 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d08:	865a                	mv	a2,s6
    80003d0a:	85d6                	mv	a1,s5
    80003d0c:	854e                	mv	a0,s3
    80003d0e:	00000097          	auipc	ra,0x0
    80003d12:	e64080e7          	jalr	-412(ra) # 80003b72 <dirlookup>
    80003d16:	8a2a                	mv	s4,a0
    80003d18:	dd51                	beqz	a0,80003cb4 <namex+0x92>
    iunlockput(ip);
    80003d1a:	854e                	mv	a0,s3
    80003d1c:	00000097          	auipc	ra,0x0
    80003d20:	bd6080e7          	jalr	-1066(ra) # 800038f2 <iunlockput>
    ip = next;
    80003d24:	89d2                	mv	s3,s4
  while(*path == '/')
    80003d26:	0004c783          	lbu	a5,0(s1)
    80003d2a:	05279d63          	bne	a5,s2,80003d84 <namex+0x162>
    path++;
    80003d2e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d30:	0004c783          	lbu	a5,0(s1)
    80003d34:	ff278de3          	beq	a5,s2,80003d2e <namex+0x10c>
  if(*path == 0)
    80003d38:	cf8d                	beqz	a5,80003d72 <namex+0x150>
  while(*path != '/' && *path != 0)
    80003d3a:	01278b63          	beq	a5,s2,80003d50 <namex+0x12e>
    80003d3e:	c795                	beqz	a5,80003d6a <namex+0x148>
    path++;
    80003d40:	85a6                	mv	a1,s1
    path++;
    80003d42:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003d44:	0004c783          	lbu	a5,0(s1)
    80003d48:	f7278de3          	beq	a5,s2,80003cc2 <namex+0xa0>
    80003d4c:	fbfd                	bnez	a5,80003d42 <namex+0x120>
    80003d4e:	bf95                	j	80003cc2 <namex+0xa0>
    80003d50:	85a6                	mv	a1,s1
  len = path - s;
    80003d52:	8a5a                	mv	s4,s6
    80003d54:	865a                	mv	a2,s6
    memmove(name, s, len);
    80003d56:	2601                	sext.w	a2,a2
    80003d58:	8556                	mv	a0,s5
    80003d5a:	ffffd097          	auipc	ra,0xffffd
    80003d5e:	074080e7          	jalr	116(ra) # 80000dce <memmove>
    name[len] = 0;
    80003d62:	9a56                	add	s4,s4,s5
    80003d64:	000a0023          	sb	zero,0(s4)
    80003d68:	bf8d                	j	80003cda <namex+0xb8>
  while(*path != '/' && *path != 0)
    80003d6a:	85a6                	mv	a1,s1
  len = path - s;
    80003d6c:	8a5a                	mv	s4,s6
    80003d6e:	865a                	mv	a2,s6
    80003d70:	b7dd                	j	80003d56 <namex+0x134>
  if(nameiparent){
    80003d72:	f00b8de3          	beqz	s7,80003c8c <namex+0x6a>
    iput(ip);
    80003d76:	854e                	mv	a0,s3
    80003d78:	00000097          	auipc	ra,0x0
    80003d7c:	ad2080e7          	jalr	-1326(ra) # 8000384a <iput>
    return 0;
    80003d80:	4981                	li	s3,0
    80003d82:	b729                	j	80003c8c <namex+0x6a>
  if(*path == 0)
    80003d84:	d7fd                	beqz	a5,80003d72 <namex+0x150>
    80003d86:	85a6                	mv	a1,s1
    80003d88:	bf6d                	j	80003d42 <namex+0x120>

0000000080003d8a <dirlink>:
{
    80003d8a:	7139                	addi	sp,sp,-64
    80003d8c:	fc06                	sd	ra,56(sp)
    80003d8e:	f822                	sd	s0,48(sp)
    80003d90:	f426                	sd	s1,40(sp)
    80003d92:	f04a                	sd	s2,32(sp)
    80003d94:	ec4e                	sd	s3,24(sp)
    80003d96:	e852                	sd	s4,16(sp)
    80003d98:	0080                	addi	s0,sp,64
    80003d9a:	892a                	mv	s2,a0
    80003d9c:	8a2e                	mv	s4,a1
    80003d9e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003da0:	4601                	li	a2,0
    80003da2:	00000097          	auipc	ra,0x0
    80003da6:	dd0080e7          	jalr	-560(ra) # 80003b72 <dirlookup>
    80003daa:	e93d                	bnez	a0,80003e20 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dac:	04c92483          	lw	s1,76(s2)
    80003db0:	c49d                	beqz	s1,80003dde <dirlink+0x54>
    80003db2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003db4:	4741                	li	a4,16
    80003db6:	86a6                	mv	a3,s1
    80003db8:	fc040613          	addi	a2,s0,-64
    80003dbc:	4581                	li	a1,0
    80003dbe:	854a                	mv	a0,s2
    80003dc0:	00000097          	auipc	ra,0x0
    80003dc4:	b84080e7          	jalr	-1148(ra) # 80003944 <readi>
    80003dc8:	47c1                	li	a5,16
    80003dca:	06f51163          	bne	a0,a5,80003e2c <dirlink+0xa2>
    if(de.inum == 0)
    80003dce:	fc045783          	lhu	a5,-64(s0)
    80003dd2:	c791                	beqz	a5,80003dde <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dd4:	24c1                	addiw	s1,s1,16
    80003dd6:	04c92783          	lw	a5,76(s2)
    80003dda:	fcf4ede3          	bltu	s1,a5,80003db4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003dde:	4639                	li	a2,14
    80003de0:	85d2                	mv	a1,s4
    80003de2:	fc240513          	addi	a0,s0,-62
    80003de6:	ffffd097          	auipc	ra,0xffffd
    80003dea:	0b4080e7          	jalr	180(ra) # 80000e9a <strncpy>
  de.inum = inum;
    80003dee:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003df2:	4741                	li	a4,16
    80003df4:	86a6                	mv	a3,s1
    80003df6:	fc040613          	addi	a2,s0,-64
    80003dfa:	4581                	li	a1,0
    80003dfc:	854a                	mv	a0,s2
    80003dfe:	00000097          	auipc	ra,0x0
    80003e02:	c3e080e7          	jalr	-962(ra) # 80003a3c <writei>
    80003e06:	4741                	li	a4,16
  return 0;
    80003e08:	4781                	li	a5,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e0a:	02e51963          	bne	a0,a4,80003e3c <dirlink+0xb2>
}
    80003e0e:	853e                	mv	a0,a5
    80003e10:	70e2                	ld	ra,56(sp)
    80003e12:	7442                	ld	s0,48(sp)
    80003e14:	74a2                	ld	s1,40(sp)
    80003e16:	7902                	ld	s2,32(sp)
    80003e18:	69e2                	ld	s3,24(sp)
    80003e1a:	6a42                	ld	s4,16(sp)
    80003e1c:	6121                	addi	sp,sp,64
    80003e1e:	8082                	ret
    iput(ip);
    80003e20:	00000097          	auipc	ra,0x0
    80003e24:	a2a080e7          	jalr	-1494(ra) # 8000384a <iput>
    return -1;
    80003e28:	57fd                	li	a5,-1
    80003e2a:	b7d5                	j	80003e0e <dirlink+0x84>
      panic("dirlink read");
    80003e2c:	00004517          	auipc	a0,0x4
    80003e30:	7bc50513          	addi	a0,a0,1980 # 800085e8 <syscalls+0x1f0>
    80003e34:	ffffc097          	auipc	ra,0xffffc
    80003e38:	744080e7          	jalr	1860(ra) # 80000578 <panic>
    panic("dirlink");
    80003e3c:	00005517          	auipc	a0,0x5
    80003e40:	8cc50513          	addi	a0,a0,-1844 # 80008708 <syscalls+0x310>
    80003e44:	ffffc097          	auipc	ra,0xffffc
    80003e48:	734080e7          	jalr	1844(ra) # 80000578 <panic>

0000000080003e4c <namei>:

struct inode*
namei(char *path)
{
    80003e4c:	1101                	addi	sp,sp,-32
    80003e4e:	ec06                	sd	ra,24(sp)
    80003e50:	e822                	sd	s0,16(sp)
    80003e52:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e54:	fe040613          	addi	a2,s0,-32
    80003e58:	4581                	li	a1,0
    80003e5a:	00000097          	auipc	ra,0x0
    80003e5e:	dc8080e7          	jalr	-568(ra) # 80003c22 <namex>
}
    80003e62:	60e2                	ld	ra,24(sp)
    80003e64:	6442                	ld	s0,16(sp)
    80003e66:	6105                	addi	sp,sp,32
    80003e68:	8082                	ret

0000000080003e6a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e6a:	1141                	addi	sp,sp,-16
    80003e6c:	e406                	sd	ra,8(sp)
    80003e6e:	e022                	sd	s0,0(sp)
    80003e70:	0800                	addi	s0,sp,16
  return namex(path, 1, name);
    80003e72:	862e                	mv	a2,a1
    80003e74:	4585                	li	a1,1
    80003e76:	00000097          	auipc	ra,0x0
    80003e7a:	dac080e7          	jalr	-596(ra) # 80003c22 <namex>
}
    80003e7e:	60a2                	ld	ra,8(sp)
    80003e80:	6402                	ld	s0,0(sp)
    80003e82:	0141                	addi	sp,sp,16
    80003e84:	8082                	ret

0000000080003e86 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e86:	1101                	addi	sp,sp,-32
    80003e88:	ec06                	sd	ra,24(sp)
    80003e8a:	e822                	sd	s0,16(sp)
    80003e8c:	e426                	sd	s1,8(sp)
    80003e8e:	e04a                	sd	s2,0(sp)
    80003e90:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e92:	0001d917          	auipc	s2,0x1d
    80003e96:	3b690913          	addi	s2,s2,950 # 80021248 <log>
    80003e9a:	01892583          	lw	a1,24(s2)
    80003e9e:	02892503          	lw	a0,40(s2)
    80003ea2:	fffff097          	auipc	ra,0xfffff
    80003ea6:	fa4080e7          	jalr	-92(ra) # 80002e46 <bread>
    80003eaa:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003eac:	02c92683          	lw	a3,44(s2)
    80003eb0:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003eb2:	02d05763          	blez	a3,80003ee0 <write_head+0x5a>
    80003eb6:	0001d797          	auipc	a5,0x1d
    80003eba:	3c278793          	addi	a5,a5,962 # 80021278 <log+0x30>
    80003ebe:	05c50713          	addi	a4,a0,92
    80003ec2:	36fd                	addiw	a3,a3,-1
    80003ec4:	1682                	slli	a3,a3,0x20
    80003ec6:	9281                	srli	a3,a3,0x20
    80003ec8:	068a                	slli	a3,a3,0x2
    80003eca:	0001d617          	auipc	a2,0x1d
    80003ece:	3b260613          	addi	a2,a2,946 # 8002127c <log+0x34>
    80003ed2:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003ed4:	4390                	lw	a2,0(a5)
    80003ed6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ed8:	0791                	addi	a5,a5,4
    80003eda:	0711                	addi	a4,a4,4
    80003edc:	fed79ce3          	bne	a5,a3,80003ed4 <write_head+0x4e>
  }
  bwrite(buf);
    80003ee0:	8526                	mv	a0,s1
    80003ee2:	fffff097          	auipc	ra,0xfffff
    80003ee6:	068080e7          	jalr	104(ra) # 80002f4a <bwrite>
  brelse(buf);
    80003eea:	8526                	mv	a0,s1
    80003eec:	fffff097          	auipc	ra,0xfffff
    80003ef0:	09c080e7          	jalr	156(ra) # 80002f88 <brelse>
}
    80003ef4:	60e2                	ld	ra,24(sp)
    80003ef6:	6442                	ld	s0,16(sp)
    80003ef8:	64a2                	ld	s1,8(sp)
    80003efa:	6902                	ld	s2,0(sp)
    80003efc:	6105                	addi	sp,sp,32
    80003efe:	8082                	ret

0000000080003f00 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f00:	0001d797          	auipc	a5,0x1d
    80003f04:	34878793          	addi	a5,a5,840 # 80021248 <log>
    80003f08:	57dc                	lw	a5,44(a5)
    80003f0a:	0af05d63          	blez	a5,80003fc4 <install_trans+0xc4>
{
    80003f0e:	7139                	addi	sp,sp,-64
    80003f10:	fc06                	sd	ra,56(sp)
    80003f12:	f822                	sd	s0,48(sp)
    80003f14:	f426                	sd	s1,40(sp)
    80003f16:	f04a                	sd	s2,32(sp)
    80003f18:	ec4e                	sd	s3,24(sp)
    80003f1a:	e852                	sd	s4,16(sp)
    80003f1c:	e456                	sd	s5,8(sp)
    80003f1e:	e05a                	sd	s6,0(sp)
    80003f20:	0080                	addi	s0,sp,64
    80003f22:	8b2a                	mv	s6,a0
    80003f24:	0001da17          	auipc	s4,0x1d
    80003f28:	354a0a13          	addi	s4,s4,852 # 80021278 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f2c:	4981                	li	s3,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f2e:	0001d917          	auipc	s2,0x1d
    80003f32:	31a90913          	addi	s2,s2,794 # 80021248 <log>
    80003f36:	a035                	j	80003f62 <install_trans+0x62>
      bunpin(dbuf);
    80003f38:	8526                	mv	a0,s1
    80003f3a:	fffff097          	auipc	ra,0xfffff
    80003f3e:	128080e7          	jalr	296(ra) # 80003062 <bunpin>
    brelse(lbuf);
    80003f42:	8556                	mv	a0,s5
    80003f44:	fffff097          	auipc	ra,0xfffff
    80003f48:	044080e7          	jalr	68(ra) # 80002f88 <brelse>
    brelse(dbuf);
    80003f4c:	8526                	mv	a0,s1
    80003f4e:	fffff097          	auipc	ra,0xfffff
    80003f52:	03a080e7          	jalr	58(ra) # 80002f88 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f56:	2985                	addiw	s3,s3,1
    80003f58:	0a11                	addi	s4,s4,4
    80003f5a:	02c92783          	lw	a5,44(s2)
    80003f5e:	04f9d963          	ble	a5,s3,80003fb0 <install_trans+0xb0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f62:	01892583          	lw	a1,24(s2)
    80003f66:	013585bb          	addw	a1,a1,s3
    80003f6a:	2585                	addiw	a1,a1,1
    80003f6c:	02892503          	lw	a0,40(s2)
    80003f70:	fffff097          	auipc	ra,0xfffff
    80003f74:	ed6080e7          	jalr	-298(ra) # 80002e46 <bread>
    80003f78:	8aaa                	mv	s5,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f7a:	000a2583          	lw	a1,0(s4)
    80003f7e:	02892503          	lw	a0,40(s2)
    80003f82:	fffff097          	auipc	ra,0xfffff
    80003f86:	ec4080e7          	jalr	-316(ra) # 80002e46 <bread>
    80003f8a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f8c:	40000613          	li	a2,1024
    80003f90:	058a8593          	addi	a1,s5,88
    80003f94:	05850513          	addi	a0,a0,88
    80003f98:	ffffd097          	auipc	ra,0xffffd
    80003f9c:	e36080e7          	jalr	-458(ra) # 80000dce <memmove>
    bwrite(dbuf);  // write dst to disk
    80003fa0:	8526                	mv	a0,s1
    80003fa2:	fffff097          	auipc	ra,0xfffff
    80003fa6:	fa8080e7          	jalr	-88(ra) # 80002f4a <bwrite>
    if(recovering == 0)
    80003faa:	f80b1ce3          	bnez	s6,80003f42 <install_trans+0x42>
    80003fae:	b769                	j	80003f38 <install_trans+0x38>
}
    80003fb0:	70e2                	ld	ra,56(sp)
    80003fb2:	7442                	ld	s0,48(sp)
    80003fb4:	74a2                	ld	s1,40(sp)
    80003fb6:	7902                	ld	s2,32(sp)
    80003fb8:	69e2                	ld	s3,24(sp)
    80003fba:	6a42                	ld	s4,16(sp)
    80003fbc:	6aa2                	ld	s5,8(sp)
    80003fbe:	6b02                	ld	s6,0(sp)
    80003fc0:	6121                	addi	sp,sp,64
    80003fc2:	8082                	ret
    80003fc4:	8082                	ret

0000000080003fc6 <initlog>:
{
    80003fc6:	7179                	addi	sp,sp,-48
    80003fc8:	f406                	sd	ra,40(sp)
    80003fca:	f022                	sd	s0,32(sp)
    80003fcc:	ec26                	sd	s1,24(sp)
    80003fce:	e84a                	sd	s2,16(sp)
    80003fd0:	e44e                	sd	s3,8(sp)
    80003fd2:	1800                	addi	s0,sp,48
    80003fd4:	892a                	mv	s2,a0
    80003fd6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003fd8:	0001d497          	auipc	s1,0x1d
    80003fdc:	27048493          	addi	s1,s1,624 # 80021248 <log>
    80003fe0:	00004597          	auipc	a1,0x4
    80003fe4:	61858593          	addi	a1,a1,1560 # 800085f8 <syscalls+0x200>
    80003fe8:	8526                	mv	a0,s1
    80003fea:	ffffd097          	auipc	ra,0xffffd
    80003fee:	bec080e7          	jalr	-1044(ra) # 80000bd6 <initlock>
  log.start = sb->logstart;
    80003ff2:	0149a583          	lw	a1,20(s3)
    80003ff6:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003ff8:	0109a783          	lw	a5,16(s3)
    80003ffc:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003ffe:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004002:	854a                	mv	a0,s2
    80004004:	fffff097          	auipc	ra,0xfffff
    80004008:	e42080e7          	jalr	-446(ra) # 80002e46 <bread>
  log.lh.n = lh->n;
    8000400c:	4d3c                	lw	a5,88(a0)
    8000400e:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004010:	02f05563          	blez	a5,8000403a <initlog+0x74>
    80004014:	05c50713          	addi	a4,a0,92
    80004018:	0001d697          	auipc	a3,0x1d
    8000401c:	26068693          	addi	a3,a3,608 # 80021278 <log+0x30>
    80004020:	37fd                	addiw	a5,a5,-1
    80004022:	1782                	slli	a5,a5,0x20
    80004024:	9381                	srli	a5,a5,0x20
    80004026:	078a                	slli	a5,a5,0x2
    80004028:	06050613          	addi	a2,a0,96
    8000402c:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    8000402e:	4310                	lw	a2,0(a4)
    80004030:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004032:	0711                	addi	a4,a4,4
    80004034:	0691                	addi	a3,a3,4
    80004036:	fef71ce3          	bne	a4,a5,8000402e <initlog+0x68>
  brelse(buf);
    8000403a:	fffff097          	auipc	ra,0xfffff
    8000403e:	f4e080e7          	jalr	-178(ra) # 80002f88 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004042:	4505                	li	a0,1
    80004044:	00000097          	auipc	ra,0x0
    80004048:	ebc080e7          	jalr	-324(ra) # 80003f00 <install_trans>
  log.lh.n = 0;
    8000404c:	0001d797          	auipc	a5,0x1d
    80004050:	2207a423          	sw	zero,552(a5) # 80021274 <log+0x2c>
  write_head(); // clear the log
    80004054:	00000097          	auipc	ra,0x0
    80004058:	e32080e7          	jalr	-462(ra) # 80003e86 <write_head>
}
    8000405c:	70a2                	ld	ra,40(sp)
    8000405e:	7402                	ld	s0,32(sp)
    80004060:	64e2                	ld	s1,24(sp)
    80004062:	6942                	ld	s2,16(sp)
    80004064:	69a2                	ld	s3,8(sp)
    80004066:	6145                	addi	sp,sp,48
    80004068:	8082                	ret

000000008000406a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000406a:	1101                	addi	sp,sp,-32
    8000406c:	ec06                	sd	ra,24(sp)
    8000406e:	e822                	sd	s0,16(sp)
    80004070:	e426                	sd	s1,8(sp)
    80004072:	e04a                	sd	s2,0(sp)
    80004074:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004076:	0001d517          	auipc	a0,0x1d
    8000407a:	1d250513          	addi	a0,a0,466 # 80021248 <log>
    8000407e:	ffffd097          	auipc	ra,0xffffd
    80004082:	be8080e7          	jalr	-1048(ra) # 80000c66 <acquire>
  while(1){
    if(log.committing){
    80004086:	0001d497          	auipc	s1,0x1d
    8000408a:	1c248493          	addi	s1,s1,450 # 80021248 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000408e:	4979                	li	s2,30
    80004090:	a039                	j	8000409e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004092:	85a6                	mv	a1,s1
    80004094:	8526                	mv	a0,s1
    80004096:	ffffe097          	auipc	ra,0xffffe
    8000409a:	182080e7          	jalr	386(ra) # 80002218 <sleep>
    if(log.committing){
    8000409e:	50dc                	lw	a5,36(s1)
    800040a0:	fbed                	bnez	a5,80004092 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040a2:	509c                	lw	a5,32(s1)
    800040a4:	0017871b          	addiw	a4,a5,1
    800040a8:	0007069b          	sext.w	a3,a4
    800040ac:	0027179b          	slliw	a5,a4,0x2
    800040b0:	9fb9                	addw	a5,a5,a4
    800040b2:	0017979b          	slliw	a5,a5,0x1
    800040b6:	54d8                	lw	a4,44(s1)
    800040b8:	9fb9                	addw	a5,a5,a4
    800040ba:	00f95963          	ble	a5,s2,800040cc <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800040be:	85a6                	mv	a1,s1
    800040c0:	8526                	mv	a0,s1
    800040c2:	ffffe097          	auipc	ra,0xffffe
    800040c6:	156080e7          	jalr	342(ra) # 80002218 <sleep>
    800040ca:	bfd1                	j	8000409e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800040cc:	0001d517          	auipc	a0,0x1d
    800040d0:	17c50513          	addi	a0,a0,380 # 80021248 <log>
    800040d4:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800040d6:	ffffd097          	auipc	ra,0xffffd
    800040da:	c44080e7          	jalr	-956(ra) # 80000d1a <release>
      break;
    }
  }
}
    800040de:	60e2                	ld	ra,24(sp)
    800040e0:	6442                	ld	s0,16(sp)
    800040e2:	64a2                	ld	s1,8(sp)
    800040e4:	6902                	ld	s2,0(sp)
    800040e6:	6105                	addi	sp,sp,32
    800040e8:	8082                	ret

00000000800040ea <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800040ea:	7139                	addi	sp,sp,-64
    800040ec:	fc06                	sd	ra,56(sp)
    800040ee:	f822                	sd	s0,48(sp)
    800040f0:	f426                	sd	s1,40(sp)
    800040f2:	f04a                	sd	s2,32(sp)
    800040f4:	ec4e                	sd	s3,24(sp)
    800040f6:	e852                	sd	s4,16(sp)
    800040f8:	e456                	sd	s5,8(sp)
    800040fa:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040fc:	0001d917          	auipc	s2,0x1d
    80004100:	14c90913          	addi	s2,s2,332 # 80021248 <log>
    80004104:	854a                	mv	a0,s2
    80004106:	ffffd097          	auipc	ra,0xffffd
    8000410a:	b60080e7          	jalr	-1184(ra) # 80000c66 <acquire>
  log.outstanding -= 1;
    8000410e:	02092783          	lw	a5,32(s2)
    80004112:	37fd                	addiw	a5,a5,-1
    80004114:	0007849b          	sext.w	s1,a5
    80004118:	02f92023          	sw	a5,32(s2)
  if(log.committing)
    8000411c:	02492783          	lw	a5,36(s2)
    80004120:	eba1                	bnez	a5,80004170 <end_op+0x86>
    panic("log.committing");
  if(log.outstanding == 0){
    80004122:	ecb9                	bnez	s1,80004180 <end_op+0x96>
    do_commit = 1;
    log.committing = 1;
    80004124:	0001d917          	auipc	s2,0x1d
    80004128:	12490913          	addi	s2,s2,292 # 80021248 <log>
    8000412c:	4785                	li	a5,1
    8000412e:	02f92223          	sw	a5,36(s2)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004132:	854a                	mv	a0,s2
    80004134:	ffffd097          	auipc	ra,0xffffd
    80004138:	be6080e7          	jalr	-1050(ra) # 80000d1a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000413c:	02c92783          	lw	a5,44(s2)
    80004140:	06f04763          	bgtz	a5,800041ae <end_op+0xc4>
    acquire(&log.lock);
    80004144:	0001d497          	auipc	s1,0x1d
    80004148:	10448493          	addi	s1,s1,260 # 80021248 <log>
    8000414c:	8526                	mv	a0,s1
    8000414e:	ffffd097          	auipc	ra,0xffffd
    80004152:	b18080e7          	jalr	-1256(ra) # 80000c66 <acquire>
    log.committing = 0;
    80004156:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000415a:	8526                	mv	a0,s1
    8000415c:	ffffe097          	auipc	ra,0xffffe
    80004160:	242080e7          	jalr	578(ra) # 8000239e <wakeup>
    release(&log.lock);
    80004164:	8526                	mv	a0,s1
    80004166:	ffffd097          	auipc	ra,0xffffd
    8000416a:	bb4080e7          	jalr	-1100(ra) # 80000d1a <release>
}
    8000416e:	a03d                	j	8000419c <end_op+0xb2>
    panic("log.committing");
    80004170:	00004517          	auipc	a0,0x4
    80004174:	49050513          	addi	a0,a0,1168 # 80008600 <syscalls+0x208>
    80004178:	ffffc097          	auipc	ra,0xffffc
    8000417c:	400080e7          	jalr	1024(ra) # 80000578 <panic>
    wakeup(&log);
    80004180:	0001d497          	auipc	s1,0x1d
    80004184:	0c848493          	addi	s1,s1,200 # 80021248 <log>
    80004188:	8526                	mv	a0,s1
    8000418a:	ffffe097          	auipc	ra,0xffffe
    8000418e:	214080e7          	jalr	532(ra) # 8000239e <wakeup>
  release(&log.lock);
    80004192:	8526                	mv	a0,s1
    80004194:	ffffd097          	auipc	ra,0xffffd
    80004198:	b86080e7          	jalr	-1146(ra) # 80000d1a <release>
}
    8000419c:	70e2                	ld	ra,56(sp)
    8000419e:	7442                	ld	s0,48(sp)
    800041a0:	74a2                	ld	s1,40(sp)
    800041a2:	7902                	ld	s2,32(sp)
    800041a4:	69e2                	ld	s3,24(sp)
    800041a6:	6a42                	ld	s4,16(sp)
    800041a8:	6aa2                	ld	s5,8(sp)
    800041aa:	6121                	addi	sp,sp,64
    800041ac:	8082                	ret
    800041ae:	0001da17          	auipc	s4,0x1d
    800041b2:	0caa0a13          	addi	s4,s4,202 # 80021278 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041b6:	0001d917          	auipc	s2,0x1d
    800041ba:	09290913          	addi	s2,s2,146 # 80021248 <log>
    800041be:	01892583          	lw	a1,24(s2)
    800041c2:	9da5                	addw	a1,a1,s1
    800041c4:	2585                	addiw	a1,a1,1
    800041c6:	02892503          	lw	a0,40(s2)
    800041ca:	fffff097          	auipc	ra,0xfffff
    800041ce:	c7c080e7          	jalr	-900(ra) # 80002e46 <bread>
    800041d2:	89aa                	mv	s3,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800041d4:	000a2583          	lw	a1,0(s4)
    800041d8:	02892503          	lw	a0,40(s2)
    800041dc:	fffff097          	auipc	ra,0xfffff
    800041e0:	c6a080e7          	jalr	-918(ra) # 80002e46 <bread>
    800041e4:	8aaa                	mv	s5,a0
    memmove(to->data, from->data, BSIZE);
    800041e6:	40000613          	li	a2,1024
    800041ea:	05850593          	addi	a1,a0,88
    800041ee:	05898513          	addi	a0,s3,88
    800041f2:	ffffd097          	auipc	ra,0xffffd
    800041f6:	bdc080e7          	jalr	-1060(ra) # 80000dce <memmove>
    bwrite(to);  // write the log
    800041fa:	854e                	mv	a0,s3
    800041fc:	fffff097          	auipc	ra,0xfffff
    80004200:	d4e080e7          	jalr	-690(ra) # 80002f4a <bwrite>
    brelse(from);
    80004204:	8556                	mv	a0,s5
    80004206:	fffff097          	auipc	ra,0xfffff
    8000420a:	d82080e7          	jalr	-638(ra) # 80002f88 <brelse>
    brelse(to);
    8000420e:	854e                	mv	a0,s3
    80004210:	fffff097          	auipc	ra,0xfffff
    80004214:	d78080e7          	jalr	-648(ra) # 80002f88 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004218:	2485                	addiw	s1,s1,1
    8000421a:	0a11                	addi	s4,s4,4
    8000421c:	02c92783          	lw	a5,44(s2)
    80004220:	f8f4cfe3          	blt	s1,a5,800041be <end_op+0xd4>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004224:	00000097          	auipc	ra,0x0
    80004228:	c62080e7          	jalr	-926(ra) # 80003e86 <write_head>
    install_trans(0); // Now install writes to home locations
    8000422c:	4501                	li	a0,0
    8000422e:	00000097          	auipc	ra,0x0
    80004232:	cd2080e7          	jalr	-814(ra) # 80003f00 <install_trans>
    log.lh.n = 0;
    80004236:	0001d797          	auipc	a5,0x1d
    8000423a:	0207af23          	sw	zero,62(a5) # 80021274 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000423e:	00000097          	auipc	ra,0x0
    80004242:	c48080e7          	jalr	-952(ra) # 80003e86 <write_head>
    80004246:	bdfd                	j	80004144 <end_op+0x5a>

0000000080004248 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004248:	1101                	addi	sp,sp,-32
    8000424a:	ec06                	sd	ra,24(sp)
    8000424c:	e822                	sd	s0,16(sp)
    8000424e:	e426                	sd	s1,8(sp)
    80004250:	e04a                	sd	s2,0(sp)
    80004252:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004254:	0001d797          	auipc	a5,0x1d
    80004258:	ff478793          	addi	a5,a5,-12 # 80021248 <log>
    8000425c:	57d8                	lw	a4,44(a5)
    8000425e:	47f5                	li	a5,29
    80004260:	08e7c563          	blt	a5,a4,800042ea <log_write+0xa2>
    80004264:	892a                	mv	s2,a0
    80004266:	0001d797          	auipc	a5,0x1d
    8000426a:	fe278793          	addi	a5,a5,-30 # 80021248 <log>
    8000426e:	4fdc                	lw	a5,28(a5)
    80004270:	37fd                	addiw	a5,a5,-1
    80004272:	06f75c63          	ble	a5,a4,800042ea <log_write+0xa2>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004276:	0001d797          	auipc	a5,0x1d
    8000427a:	fd278793          	addi	a5,a5,-46 # 80021248 <log>
    8000427e:	539c                	lw	a5,32(a5)
    80004280:	06f05d63          	blez	a5,800042fa <log_write+0xb2>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004284:	0001d497          	auipc	s1,0x1d
    80004288:	fc448493          	addi	s1,s1,-60 # 80021248 <log>
    8000428c:	8526                	mv	a0,s1
    8000428e:	ffffd097          	auipc	ra,0xffffd
    80004292:	9d8080e7          	jalr	-1576(ra) # 80000c66 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004296:	54d0                	lw	a2,44(s1)
    80004298:	0ac05063          	blez	a2,80004338 <log_write+0xf0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000429c:	00c92583          	lw	a1,12(s2)
    800042a0:	589c                	lw	a5,48(s1)
    800042a2:	0ab78363          	beq	a5,a1,80004348 <log_write+0x100>
    800042a6:	0001d717          	auipc	a4,0x1d
    800042aa:	fd670713          	addi	a4,a4,-42 # 8002127c <log+0x34>
  for (i = 0; i < log.lh.n; i++) {
    800042ae:	4781                	li	a5,0
    800042b0:	2785                	addiw	a5,a5,1
    800042b2:	04c78c63          	beq	a5,a2,8000430a <log_write+0xc2>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800042b6:	4314                	lw	a3,0(a4)
    800042b8:	0711                	addi	a4,a4,4
    800042ba:	feb69be3          	bne	a3,a1,800042b0 <log_write+0x68>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042be:	07a1                	addi	a5,a5,8
    800042c0:	078a                	slli	a5,a5,0x2
    800042c2:	0001d717          	auipc	a4,0x1d
    800042c6:	f8670713          	addi	a4,a4,-122 # 80021248 <log>
    800042ca:	97ba                	add	a5,a5,a4
    800042cc:	cb8c                	sw	a1,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    log.lh.n++;
  }
  release(&log.lock);
    800042ce:	0001d517          	auipc	a0,0x1d
    800042d2:	f7a50513          	addi	a0,a0,-134 # 80021248 <log>
    800042d6:	ffffd097          	auipc	ra,0xffffd
    800042da:	a44080e7          	jalr	-1468(ra) # 80000d1a <release>
}
    800042de:	60e2                	ld	ra,24(sp)
    800042e0:	6442                	ld	s0,16(sp)
    800042e2:	64a2                	ld	s1,8(sp)
    800042e4:	6902                	ld	s2,0(sp)
    800042e6:	6105                	addi	sp,sp,32
    800042e8:	8082                	ret
    panic("too big a transaction");
    800042ea:	00004517          	auipc	a0,0x4
    800042ee:	32650513          	addi	a0,a0,806 # 80008610 <syscalls+0x218>
    800042f2:	ffffc097          	auipc	ra,0xffffc
    800042f6:	286080e7          	jalr	646(ra) # 80000578 <panic>
    panic("log_write outside of trans");
    800042fa:	00004517          	auipc	a0,0x4
    800042fe:	32e50513          	addi	a0,a0,814 # 80008628 <syscalls+0x230>
    80004302:	ffffc097          	auipc	ra,0xffffc
    80004306:	276080e7          	jalr	630(ra) # 80000578 <panic>
  log.lh.block[i] = b->blockno;
    8000430a:	0621                	addi	a2,a2,8
    8000430c:	060a                	slli	a2,a2,0x2
    8000430e:	0001d797          	auipc	a5,0x1d
    80004312:	f3a78793          	addi	a5,a5,-198 # 80021248 <log>
    80004316:	963e                	add	a2,a2,a5
    80004318:	00c92783          	lw	a5,12(s2)
    8000431c:	ca1c                	sw	a5,16(a2)
    bpin(b);
    8000431e:	854a                	mv	a0,s2
    80004320:	fffff097          	auipc	ra,0xfffff
    80004324:	d06080e7          	jalr	-762(ra) # 80003026 <bpin>
    log.lh.n++;
    80004328:	0001d717          	auipc	a4,0x1d
    8000432c:	f2070713          	addi	a4,a4,-224 # 80021248 <log>
    80004330:	575c                	lw	a5,44(a4)
    80004332:	2785                	addiw	a5,a5,1
    80004334:	d75c                	sw	a5,44(a4)
    80004336:	bf61                	j	800042ce <log_write+0x86>
  log.lh.block[i] = b->blockno;
    80004338:	00c92783          	lw	a5,12(s2)
    8000433c:	0001d717          	auipc	a4,0x1d
    80004340:	f2f72e23          	sw	a5,-196(a4) # 80021278 <log+0x30>
  if (i == log.lh.n) {  // Add new block to log?
    80004344:	f649                	bnez	a2,800042ce <log_write+0x86>
    80004346:	bfe1                	j	8000431e <log_write+0xd6>
  for (i = 0; i < log.lh.n; i++) {
    80004348:	4781                	li	a5,0
    8000434a:	bf95                	j	800042be <log_write+0x76>

000000008000434c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000434c:	1101                	addi	sp,sp,-32
    8000434e:	ec06                	sd	ra,24(sp)
    80004350:	e822                	sd	s0,16(sp)
    80004352:	e426                	sd	s1,8(sp)
    80004354:	e04a                	sd	s2,0(sp)
    80004356:	1000                	addi	s0,sp,32
    80004358:	84aa                	mv	s1,a0
    8000435a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000435c:	00004597          	auipc	a1,0x4
    80004360:	2ec58593          	addi	a1,a1,748 # 80008648 <syscalls+0x250>
    80004364:	0521                	addi	a0,a0,8
    80004366:	ffffd097          	auipc	ra,0xffffd
    8000436a:	870080e7          	jalr	-1936(ra) # 80000bd6 <initlock>
  lk->name = name;
    8000436e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004372:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004376:	0204a423          	sw	zero,40(s1)
}
    8000437a:	60e2                	ld	ra,24(sp)
    8000437c:	6442                	ld	s0,16(sp)
    8000437e:	64a2                	ld	s1,8(sp)
    80004380:	6902                	ld	s2,0(sp)
    80004382:	6105                	addi	sp,sp,32
    80004384:	8082                	ret

0000000080004386 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004386:	1101                	addi	sp,sp,-32
    80004388:	ec06                	sd	ra,24(sp)
    8000438a:	e822                	sd	s0,16(sp)
    8000438c:	e426                	sd	s1,8(sp)
    8000438e:	e04a                	sd	s2,0(sp)
    80004390:	1000                	addi	s0,sp,32
    80004392:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004394:	00850913          	addi	s2,a0,8
    80004398:	854a                	mv	a0,s2
    8000439a:	ffffd097          	auipc	ra,0xffffd
    8000439e:	8cc080e7          	jalr	-1844(ra) # 80000c66 <acquire>
  while (lk->locked) {
    800043a2:	409c                	lw	a5,0(s1)
    800043a4:	cb89                	beqz	a5,800043b6 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800043a6:	85ca                	mv	a1,s2
    800043a8:	8526                	mv	a0,s1
    800043aa:	ffffe097          	auipc	ra,0xffffe
    800043ae:	e6e080e7          	jalr	-402(ra) # 80002218 <sleep>
  while (lk->locked) {
    800043b2:	409c                	lw	a5,0(s1)
    800043b4:	fbed                	bnez	a5,800043a6 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043b6:	4785                	li	a5,1
    800043b8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043ba:	ffffd097          	auipc	ra,0xffffd
    800043be:	644080e7          	jalr	1604(ra) # 800019fe <myproc>
    800043c2:	5d1c                	lw	a5,56(a0)
    800043c4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043c6:	854a                	mv	a0,s2
    800043c8:	ffffd097          	auipc	ra,0xffffd
    800043cc:	952080e7          	jalr	-1710(ra) # 80000d1a <release>
}
    800043d0:	60e2                	ld	ra,24(sp)
    800043d2:	6442                	ld	s0,16(sp)
    800043d4:	64a2                	ld	s1,8(sp)
    800043d6:	6902                	ld	s2,0(sp)
    800043d8:	6105                	addi	sp,sp,32
    800043da:	8082                	ret

00000000800043dc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800043dc:	1101                	addi	sp,sp,-32
    800043de:	ec06                	sd	ra,24(sp)
    800043e0:	e822                	sd	s0,16(sp)
    800043e2:	e426                	sd	s1,8(sp)
    800043e4:	e04a                	sd	s2,0(sp)
    800043e6:	1000                	addi	s0,sp,32
    800043e8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043ea:	00850913          	addi	s2,a0,8
    800043ee:	854a                	mv	a0,s2
    800043f0:	ffffd097          	auipc	ra,0xffffd
    800043f4:	876080e7          	jalr	-1930(ra) # 80000c66 <acquire>
  lk->locked = 0;
    800043f8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043fc:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004400:	8526                	mv	a0,s1
    80004402:	ffffe097          	auipc	ra,0xffffe
    80004406:	f9c080e7          	jalr	-100(ra) # 8000239e <wakeup>
  release(&lk->lk);
    8000440a:	854a                	mv	a0,s2
    8000440c:	ffffd097          	auipc	ra,0xffffd
    80004410:	90e080e7          	jalr	-1778(ra) # 80000d1a <release>
}
    80004414:	60e2                	ld	ra,24(sp)
    80004416:	6442                	ld	s0,16(sp)
    80004418:	64a2                	ld	s1,8(sp)
    8000441a:	6902                	ld	s2,0(sp)
    8000441c:	6105                	addi	sp,sp,32
    8000441e:	8082                	ret

0000000080004420 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004420:	7179                	addi	sp,sp,-48
    80004422:	f406                	sd	ra,40(sp)
    80004424:	f022                	sd	s0,32(sp)
    80004426:	ec26                	sd	s1,24(sp)
    80004428:	e84a                	sd	s2,16(sp)
    8000442a:	e44e                	sd	s3,8(sp)
    8000442c:	1800                	addi	s0,sp,48
    8000442e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004430:	00850913          	addi	s2,a0,8
    80004434:	854a                	mv	a0,s2
    80004436:	ffffd097          	auipc	ra,0xffffd
    8000443a:	830080e7          	jalr	-2000(ra) # 80000c66 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000443e:	409c                	lw	a5,0(s1)
    80004440:	ef99                	bnez	a5,8000445e <holdingsleep+0x3e>
    80004442:	4481                	li	s1,0
  release(&lk->lk);
    80004444:	854a                	mv	a0,s2
    80004446:	ffffd097          	auipc	ra,0xffffd
    8000444a:	8d4080e7          	jalr	-1836(ra) # 80000d1a <release>
  return r;
}
    8000444e:	8526                	mv	a0,s1
    80004450:	70a2                	ld	ra,40(sp)
    80004452:	7402                	ld	s0,32(sp)
    80004454:	64e2                	ld	s1,24(sp)
    80004456:	6942                	ld	s2,16(sp)
    80004458:	69a2                	ld	s3,8(sp)
    8000445a:	6145                	addi	sp,sp,48
    8000445c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000445e:	0284a983          	lw	s3,40(s1)
    80004462:	ffffd097          	auipc	ra,0xffffd
    80004466:	59c080e7          	jalr	1436(ra) # 800019fe <myproc>
    8000446a:	5d04                	lw	s1,56(a0)
    8000446c:	413484b3          	sub	s1,s1,s3
    80004470:	0014b493          	seqz	s1,s1
    80004474:	bfc1                	j	80004444 <holdingsleep+0x24>

0000000080004476 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004476:	1141                	addi	sp,sp,-16
    80004478:	e406                	sd	ra,8(sp)
    8000447a:	e022                	sd	s0,0(sp)
    8000447c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000447e:	00004597          	auipc	a1,0x4
    80004482:	1da58593          	addi	a1,a1,474 # 80008658 <syscalls+0x260>
    80004486:	0001d517          	auipc	a0,0x1d
    8000448a:	f0a50513          	addi	a0,a0,-246 # 80021390 <ftable>
    8000448e:	ffffc097          	auipc	ra,0xffffc
    80004492:	748080e7          	jalr	1864(ra) # 80000bd6 <initlock>
}
    80004496:	60a2                	ld	ra,8(sp)
    80004498:	6402                	ld	s0,0(sp)
    8000449a:	0141                	addi	sp,sp,16
    8000449c:	8082                	ret

000000008000449e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000449e:	1101                	addi	sp,sp,-32
    800044a0:	ec06                	sd	ra,24(sp)
    800044a2:	e822                	sd	s0,16(sp)
    800044a4:	e426                	sd	s1,8(sp)
    800044a6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044a8:	0001d517          	auipc	a0,0x1d
    800044ac:	ee850513          	addi	a0,a0,-280 # 80021390 <ftable>
    800044b0:	ffffc097          	auipc	ra,0xffffc
    800044b4:	7b6080e7          	jalr	1974(ra) # 80000c66 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
    800044b8:	0001d797          	auipc	a5,0x1d
    800044bc:	ed878793          	addi	a5,a5,-296 # 80021390 <ftable>
    800044c0:	4fdc                	lw	a5,28(a5)
    800044c2:	cb8d                	beqz	a5,800044f4 <filealloc+0x56>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044c4:	0001d497          	auipc	s1,0x1d
    800044c8:	f0c48493          	addi	s1,s1,-244 # 800213d0 <ftable+0x40>
    800044cc:	0001e717          	auipc	a4,0x1e
    800044d0:	e7c70713          	addi	a4,a4,-388 # 80022348 <ftable+0xfb8>
    if(f->ref == 0){
    800044d4:	40dc                	lw	a5,4(s1)
    800044d6:	c39d                	beqz	a5,800044fc <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044d8:	02848493          	addi	s1,s1,40
    800044dc:	fee49ce3          	bne	s1,a4,800044d4 <filealloc+0x36>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800044e0:	0001d517          	auipc	a0,0x1d
    800044e4:	eb050513          	addi	a0,a0,-336 # 80021390 <ftable>
    800044e8:	ffffd097          	auipc	ra,0xffffd
    800044ec:	832080e7          	jalr	-1998(ra) # 80000d1a <release>
  return 0;
    800044f0:	4481                	li	s1,0
    800044f2:	a839                	j	80004510 <filealloc+0x72>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044f4:	0001d497          	auipc	s1,0x1d
    800044f8:	eb448493          	addi	s1,s1,-332 # 800213a8 <ftable+0x18>
      f->ref = 1;
    800044fc:	4785                	li	a5,1
    800044fe:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004500:	0001d517          	auipc	a0,0x1d
    80004504:	e9050513          	addi	a0,a0,-368 # 80021390 <ftable>
    80004508:	ffffd097          	auipc	ra,0xffffd
    8000450c:	812080e7          	jalr	-2030(ra) # 80000d1a <release>
}
    80004510:	8526                	mv	a0,s1
    80004512:	60e2                	ld	ra,24(sp)
    80004514:	6442                	ld	s0,16(sp)
    80004516:	64a2                	ld	s1,8(sp)
    80004518:	6105                	addi	sp,sp,32
    8000451a:	8082                	ret

000000008000451c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000451c:	1101                	addi	sp,sp,-32
    8000451e:	ec06                	sd	ra,24(sp)
    80004520:	e822                	sd	s0,16(sp)
    80004522:	e426                	sd	s1,8(sp)
    80004524:	1000                	addi	s0,sp,32
    80004526:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004528:	0001d517          	auipc	a0,0x1d
    8000452c:	e6850513          	addi	a0,a0,-408 # 80021390 <ftable>
    80004530:	ffffc097          	auipc	ra,0xffffc
    80004534:	736080e7          	jalr	1846(ra) # 80000c66 <acquire>
  if(f->ref < 1)
    80004538:	40dc                	lw	a5,4(s1)
    8000453a:	02f05263          	blez	a5,8000455e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000453e:	2785                	addiw	a5,a5,1
    80004540:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004542:	0001d517          	auipc	a0,0x1d
    80004546:	e4e50513          	addi	a0,a0,-434 # 80021390 <ftable>
    8000454a:	ffffc097          	auipc	ra,0xffffc
    8000454e:	7d0080e7          	jalr	2000(ra) # 80000d1a <release>
  return f;
}
    80004552:	8526                	mv	a0,s1
    80004554:	60e2                	ld	ra,24(sp)
    80004556:	6442                	ld	s0,16(sp)
    80004558:	64a2                	ld	s1,8(sp)
    8000455a:	6105                	addi	sp,sp,32
    8000455c:	8082                	ret
    panic("filedup");
    8000455e:	00004517          	auipc	a0,0x4
    80004562:	10250513          	addi	a0,a0,258 # 80008660 <syscalls+0x268>
    80004566:	ffffc097          	auipc	ra,0xffffc
    8000456a:	012080e7          	jalr	18(ra) # 80000578 <panic>

000000008000456e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000456e:	7139                	addi	sp,sp,-64
    80004570:	fc06                	sd	ra,56(sp)
    80004572:	f822                	sd	s0,48(sp)
    80004574:	f426                	sd	s1,40(sp)
    80004576:	f04a                	sd	s2,32(sp)
    80004578:	ec4e                	sd	s3,24(sp)
    8000457a:	e852                	sd	s4,16(sp)
    8000457c:	e456                	sd	s5,8(sp)
    8000457e:	0080                	addi	s0,sp,64
    80004580:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004582:	0001d517          	auipc	a0,0x1d
    80004586:	e0e50513          	addi	a0,a0,-498 # 80021390 <ftable>
    8000458a:	ffffc097          	auipc	ra,0xffffc
    8000458e:	6dc080e7          	jalr	1756(ra) # 80000c66 <acquire>
  if(f->ref < 1)
    80004592:	40dc                	lw	a5,4(s1)
    80004594:	06f05163          	blez	a5,800045f6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004598:	37fd                	addiw	a5,a5,-1
    8000459a:	0007871b          	sext.w	a4,a5
    8000459e:	c0dc                	sw	a5,4(s1)
    800045a0:	06e04363          	bgtz	a4,80004606 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045a4:	0004a903          	lw	s2,0(s1)
    800045a8:	0094ca83          	lbu	s5,9(s1)
    800045ac:	0104ba03          	ld	s4,16(s1)
    800045b0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800045b4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800045b8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800045bc:	0001d517          	auipc	a0,0x1d
    800045c0:	dd450513          	addi	a0,a0,-556 # 80021390 <ftable>
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	756080e7          	jalr	1878(ra) # 80000d1a <release>

  if(ff.type == FD_PIPE){
    800045cc:	4785                	li	a5,1
    800045ce:	04f90d63          	beq	s2,a5,80004628 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045d2:	3979                	addiw	s2,s2,-2
    800045d4:	4785                	li	a5,1
    800045d6:	0527e063          	bltu	a5,s2,80004616 <fileclose+0xa8>
    begin_op();
    800045da:	00000097          	auipc	ra,0x0
    800045de:	a90080e7          	jalr	-1392(ra) # 8000406a <begin_op>
    iput(ff.ip);
    800045e2:	854e                	mv	a0,s3
    800045e4:	fffff097          	auipc	ra,0xfffff
    800045e8:	266080e7          	jalr	614(ra) # 8000384a <iput>
    end_op();
    800045ec:	00000097          	auipc	ra,0x0
    800045f0:	afe080e7          	jalr	-1282(ra) # 800040ea <end_op>
    800045f4:	a00d                	j	80004616 <fileclose+0xa8>
    panic("fileclose");
    800045f6:	00004517          	auipc	a0,0x4
    800045fa:	07250513          	addi	a0,a0,114 # 80008668 <syscalls+0x270>
    800045fe:	ffffc097          	auipc	ra,0xffffc
    80004602:	f7a080e7          	jalr	-134(ra) # 80000578 <panic>
    release(&ftable.lock);
    80004606:	0001d517          	auipc	a0,0x1d
    8000460a:	d8a50513          	addi	a0,a0,-630 # 80021390 <ftable>
    8000460e:	ffffc097          	auipc	ra,0xffffc
    80004612:	70c080e7          	jalr	1804(ra) # 80000d1a <release>
  }
}
    80004616:	70e2                	ld	ra,56(sp)
    80004618:	7442                	ld	s0,48(sp)
    8000461a:	74a2                	ld	s1,40(sp)
    8000461c:	7902                	ld	s2,32(sp)
    8000461e:	69e2                	ld	s3,24(sp)
    80004620:	6a42                	ld	s4,16(sp)
    80004622:	6aa2                	ld	s5,8(sp)
    80004624:	6121                	addi	sp,sp,64
    80004626:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004628:	85d6                	mv	a1,s5
    8000462a:	8552                	mv	a0,s4
    8000462c:	00000097          	auipc	ra,0x0
    80004630:	364080e7          	jalr	868(ra) # 80004990 <pipeclose>
    80004634:	b7cd                	j	80004616 <fileclose+0xa8>

0000000080004636 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004636:	715d                	addi	sp,sp,-80
    80004638:	e486                	sd	ra,72(sp)
    8000463a:	e0a2                	sd	s0,64(sp)
    8000463c:	fc26                	sd	s1,56(sp)
    8000463e:	f84a                	sd	s2,48(sp)
    80004640:	f44e                	sd	s3,40(sp)
    80004642:	0880                	addi	s0,sp,80
    80004644:	84aa                	mv	s1,a0
    80004646:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004648:	ffffd097          	auipc	ra,0xffffd
    8000464c:	3b6080e7          	jalr	950(ra) # 800019fe <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004650:	409c                	lw	a5,0(s1)
    80004652:	37f9                	addiw	a5,a5,-2
    80004654:	4705                	li	a4,1
    80004656:	04f76763          	bltu	a4,a5,800046a4 <filestat+0x6e>
    8000465a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000465c:	6c88                	ld	a0,24(s1)
    8000465e:	fffff097          	auipc	ra,0xfffff
    80004662:	030080e7          	jalr	48(ra) # 8000368e <ilock>
    stati(f->ip, &st);
    80004666:	fb840593          	addi	a1,s0,-72
    8000466a:	6c88                	ld	a0,24(s1)
    8000466c:	fffff097          	auipc	ra,0xfffff
    80004670:	2ae080e7          	jalr	686(ra) # 8000391a <stati>
    iunlock(f->ip);
    80004674:	6c88                	ld	a0,24(s1)
    80004676:	fffff097          	auipc	ra,0xfffff
    8000467a:	0dc080e7          	jalr	220(ra) # 80003752 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000467e:	46e1                	li	a3,24
    80004680:	fb840613          	addi	a2,s0,-72
    80004684:	85ce                	mv	a1,s3
    80004686:	05093503          	ld	a0,80(s2)
    8000468a:	ffffd097          	auipc	ra,0xffffd
    8000468e:	050080e7          	jalr	80(ra) # 800016da <copyout>
    80004692:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004696:	60a6                	ld	ra,72(sp)
    80004698:	6406                	ld	s0,64(sp)
    8000469a:	74e2                	ld	s1,56(sp)
    8000469c:	7942                	ld	s2,48(sp)
    8000469e:	79a2                	ld	s3,40(sp)
    800046a0:	6161                	addi	sp,sp,80
    800046a2:	8082                	ret
  return -1;
    800046a4:	557d                	li	a0,-1
    800046a6:	bfc5                	j	80004696 <filestat+0x60>

00000000800046a8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046a8:	7179                	addi	sp,sp,-48
    800046aa:	f406                	sd	ra,40(sp)
    800046ac:	f022                	sd	s0,32(sp)
    800046ae:	ec26                	sd	s1,24(sp)
    800046b0:	e84a                	sd	s2,16(sp)
    800046b2:	e44e                	sd	s3,8(sp)
    800046b4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046b6:	00854783          	lbu	a5,8(a0)
    800046ba:	c3d5                	beqz	a5,8000475e <fileread+0xb6>
    800046bc:	89b2                	mv	s3,a2
    800046be:	892e                	mv	s2,a1
    800046c0:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    800046c2:	411c                	lw	a5,0(a0)
    800046c4:	4705                	li	a4,1
    800046c6:	04e78963          	beq	a5,a4,80004718 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046ca:	470d                	li	a4,3
    800046cc:	04e78d63          	beq	a5,a4,80004726 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800046d0:	4709                	li	a4,2
    800046d2:	06e79e63          	bne	a5,a4,8000474e <fileread+0xa6>
    ilock(f->ip);
    800046d6:	6d08                	ld	a0,24(a0)
    800046d8:	fffff097          	auipc	ra,0xfffff
    800046dc:	fb6080e7          	jalr	-74(ra) # 8000368e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046e0:	874e                	mv	a4,s3
    800046e2:	5094                	lw	a3,32(s1)
    800046e4:	864a                	mv	a2,s2
    800046e6:	4585                	li	a1,1
    800046e8:	6c88                	ld	a0,24(s1)
    800046ea:	fffff097          	auipc	ra,0xfffff
    800046ee:	25a080e7          	jalr	602(ra) # 80003944 <readi>
    800046f2:	892a                	mv	s2,a0
    800046f4:	00a05563          	blez	a0,800046fe <fileread+0x56>
      f->off += r;
    800046f8:	509c                	lw	a5,32(s1)
    800046fa:	9fa9                	addw	a5,a5,a0
    800046fc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800046fe:	6c88                	ld	a0,24(s1)
    80004700:	fffff097          	auipc	ra,0xfffff
    80004704:	052080e7          	jalr	82(ra) # 80003752 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004708:	854a                	mv	a0,s2
    8000470a:	70a2                	ld	ra,40(sp)
    8000470c:	7402                	ld	s0,32(sp)
    8000470e:	64e2                	ld	s1,24(sp)
    80004710:	6942                	ld	s2,16(sp)
    80004712:	69a2                	ld	s3,8(sp)
    80004714:	6145                	addi	sp,sp,48
    80004716:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004718:	6908                	ld	a0,16(a0)
    8000471a:	00000097          	auipc	ra,0x0
    8000471e:	416080e7          	jalr	1046(ra) # 80004b30 <piperead>
    80004722:	892a                	mv	s2,a0
    80004724:	b7d5                	j	80004708 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004726:	02451783          	lh	a5,36(a0)
    8000472a:	03079693          	slli	a3,a5,0x30
    8000472e:	92c1                	srli	a3,a3,0x30
    80004730:	4725                	li	a4,9
    80004732:	02d76863          	bltu	a4,a3,80004762 <fileread+0xba>
    80004736:	0792                	slli	a5,a5,0x4
    80004738:	0001d717          	auipc	a4,0x1d
    8000473c:	bb870713          	addi	a4,a4,-1096 # 800212f0 <devsw>
    80004740:	97ba                	add	a5,a5,a4
    80004742:	639c                	ld	a5,0(a5)
    80004744:	c38d                	beqz	a5,80004766 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004746:	4505                	li	a0,1
    80004748:	9782                	jalr	a5
    8000474a:	892a                	mv	s2,a0
    8000474c:	bf75                	j	80004708 <fileread+0x60>
    panic("fileread");
    8000474e:	00004517          	auipc	a0,0x4
    80004752:	f2a50513          	addi	a0,a0,-214 # 80008678 <syscalls+0x280>
    80004756:	ffffc097          	auipc	ra,0xffffc
    8000475a:	e22080e7          	jalr	-478(ra) # 80000578 <panic>
    return -1;
    8000475e:	597d                	li	s2,-1
    80004760:	b765                	j	80004708 <fileread+0x60>
      return -1;
    80004762:	597d                	li	s2,-1
    80004764:	b755                	j	80004708 <fileread+0x60>
    80004766:	597d                	li	s2,-1
    80004768:	b745                	j	80004708 <fileread+0x60>

000000008000476a <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000476a:	00954783          	lbu	a5,9(a0)
    8000476e:	12078e63          	beqz	a5,800048aa <filewrite+0x140>
{
    80004772:	715d                	addi	sp,sp,-80
    80004774:	e486                	sd	ra,72(sp)
    80004776:	e0a2                	sd	s0,64(sp)
    80004778:	fc26                	sd	s1,56(sp)
    8000477a:	f84a                	sd	s2,48(sp)
    8000477c:	f44e                	sd	s3,40(sp)
    8000477e:	f052                	sd	s4,32(sp)
    80004780:	ec56                	sd	s5,24(sp)
    80004782:	e85a                	sd	s6,16(sp)
    80004784:	e45e                	sd	s7,8(sp)
    80004786:	e062                	sd	s8,0(sp)
    80004788:	0880                	addi	s0,sp,80
    8000478a:	8ab2                	mv	s5,a2
    8000478c:	8b2e                	mv	s6,a1
    8000478e:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80004790:	411c                	lw	a5,0(a0)
    80004792:	4705                	li	a4,1
    80004794:	02e78263          	beq	a5,a4,800047b8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004798:	470d                	li	a4,3
    8000479a:	02e78563          	beq	a5,a4,800047c4 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000479e:	4709                	li	a4,2
    800047a0:	0ee79d63          	bne	a5,a4,8000489a <filewrite+0x130>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047a4:	0ec05763          	blez	a2,80004892 <filewrite+0x128>
    int i = 0;
    800047a8:	4901                	li	s2,0
    800047aa:	6b85                	lui	s7,0x1
    800047ac:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800047b0:	6c05                	lui	s8,0x1
    800047b2:	c00c0c1b          	addiw	s8,s8,-1024
    800047b6:	a061                	j	8000483e <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    800047b8:	6908                	ld	a0,16(a0)
    800047ba:	00000097          	auipc	ra,0x0
    800047be:	246080e7          	jalr	582(ra) # 80004a00 <pipewrite>
    800047c2:	a065                	j	8000486a <filewrite+0x100>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047c4:	02451783          	lh	a5,36(a0)
    800047c8:	03079693          	slli	a3,a5,0x30
    800047cc:	92c1                	srli	a3,a3,0x30
    800047ce:	4725                	li	a4,9
    800047d0:	0cd76f63          	bltu	a4,a3,800048ae <filewrite+0x144>
    800047d4:	0792                	slli	a5,a5,0x4
    800047d6:	0001d717          	auipc	a4,0x1d
    800047da:	b1a70713          	addi	a4,a4,-1254 # 800212f0 <devsw>
    800047de:	97ba                	add	a5,a5,a4
    800047e0:	679c                	ld	a5,8(a5)
    800047e2:	cbe1                	beqz	a5,800048b2 <filewrite+0x148>
    ret = devsw[f->major].write(1, addr, n);
    800047e4:	4505                	li	a0,1
    800047e6:	9782                	jalr	a5
    800047e8:	a049                	j	8000486a <filewrite+0x100>
    800047ea:	00098a1b          	sext.w	s4,s3
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800047ee:	00000097          	auipc	ra,0x0
    800047f2:	87c080e7          	jalr	-1924(ra) # 8000406a <begin_op>
      ilock(f->ip);
    800047f6:	6c88                	ld	a0,24(s1)
    800047f8:	fffff097          	auipc	ra,0xfffff
    800047fc:	e96080e7          	jalr	-362(ra) # 8000368e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004800:	8752                	mv	a4,s4
    80004802:	5094                	lw	a3,32(s1)
    80004804:	01690633          	add	a2,s2,s6
    80004808:	4585                	li	a1,1
    8000480a:	6c88                	ld	a0,24(s1)
    8000480c:	fffff097          	auipc	ra,0xfffff
    80004810:	230080e7          	jalr	560(ra) # 80003a3c <writei>
    80004814:	89aa                	mv	s3,a0
    80004816:	02a05c63          	blez	a0,8000484e <filewrite+0xe4>
        f->off += r;
    8000481a:	509c                	lw	a5,32(s1)
    8000481c:	9fa9                	addw	a5,a5,a0
    8000481e:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004820:	6c88                	ld	a0,24(s1)
    80004822:	fffff097          	auipc	ra,0xfffff
    80004826:	f30080e7          	jalr	-208(ra) # 80003752 <iunlock>
      end_op();
    8000482a:	00000097          	auipc	ra,0x0
    8000482e:	8c0080e7          	jalr	-1856(ra) # 800040ea <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004832:	05499863          	bne	s3,s4,80004882 <filewrite+0x118>
        panic("short filewrite");
      i += r;
    80004836:	012a093b          	addw	s2,s4,s2
    while(i < n){
    8000483a:	03595563          	ble	s5,s2,80004864 <filewrite+0xfa>
      int n1 = n - i;
    8000483e:	412a87bb          	subw	a5,s5,s2
      if(n1 > max)
    80004842:	89be                	mv	s3,a5
    80004844:	2781                	sext.w	a5,a5
    80004846:	fafbd2e3          	ble	a5,s7,800047ea <filewrite+0x80>
    8000484a:	89e2                	mv	s3,s8
    8000484c:	bf79                	j	800047ea <filewrite+0x80>
      iunlock(f->ip);
    8000484e:	6c88                	ld	a0,24(s1)
    80004850:	fffff097          	auipc	ra,0xfffff
    80004854:	f02080e7          	jalr	-254(ra) # 80003752 <iunlock>
      end_op();
    80004858:	00000097          	auipc	ra,0x0
    8000485c:	892080e7          	jalr	-1902(ra) # 800040ea <end_op>
      if(r < 0)
    80004860:	fc09d9e3          	bgez	s3,80004832 <filewrite+0xc8>
    }
    ret = (i == n ? n : -1);
    80004864:	8556                	mv	a0,s5
    80004866:	032a9863          	bne	s5,s2,80004896 <filewrite+0x12c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000486a:	60a6                	ld	ra,72(sp)
    8000486c:	6406                	ld	s0,64(sp)
    8000486e:	74e2                	ld	s1,56(sp)
    80004870:	7942                	ld	s2,48(sp)
    80004872:	79a2                	ld	s3,40(sp)
    80004874:	7a02                	ld	s4,32(sp)
    80004876:	6ae2                	ld	s5,24(sp)
    80004878:	6b42                	ld	s6,16(sp)
    8000487a:	6ba2                	ld	s7,8(sp)
    8000487c:	6c02                	ld	s8,0(sp)
    8000487e:	6161                	addi	sp,sp,80
    80004880:	8082                	ret
        panic("short filewrite");
    80004882:	00004517          	auipc	a0,0x4
    80004886:	e0650513          	addi	a0,a0,-506 # 80008688 <syscalls+0x290>
    8000488a:	ffffc097          	auipc	ra,0xffffc
    8000488e:	cee080e7          	jalr	-786(ra) # 80000578 <panic>
    int i = 0;
    80004892:	4901                	li	s2,0
    80004894:	bfc1                	j	80004864 <filewrite+0xfa>
    ret = (i == n ? n : -1);
    80004896:	557d                	li	a0,-1
    80004898:	bfc9                	j	8000486a <filewrite+0x100>
    panic("filewrite");
    8000489a:	00004517          	auipc	a0,0x4
    8000489e:	dfe50513          	addi	a0,a0,-514 # 80008698 <syscalls+0x2a0>
    800048a2:	ffffc097          	auipc	ra,0xffffc
    800048a6:	cd6080e7          	jalr	-810(ra) # 80000578 <panic>
    return -1;
    800048aa:	557d                	li	a0,-1
}
    800048ac:	8082                	ret
      return -1;
    800048ae:	557d                	li	a0,-1
    800048b0:	bf6d                	j	8000486a <filewrite+0x100>
    800048b2:	557d                	li	a0,-1
    800048b4:	bf5d                	j	8000486a <filewrite+0x100>

00000000800048b6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048b6:	7179                	addi	sp,sp,-48
    800048b8:	f406                	sd	ra,40(sp)
    800048ba:	f022                	sd	s0,32(sp)
    800048bc:	ec26                	sd	s1,24(sp)
    800048be:	e84a                	sd	s2,16(sp)
    800048c0:	e44e                	sd	s3,8(sp)
    800048c2:	e052                	sd	s4,0(sp)
    800048c4:	1800                	addi	s0,sp,48
    800048c6:	84aa                	mv	s1,a0
    800048c8:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800048ca:	0005b023          	sd	zero,0(a1)
    800048ce:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048d2:	00000097          	auipc	ra,0x0
    800048d6:	bcc080e7          	jalr	-1076(ra) # 8000449e <filealloc>
    800048da:	e088                	sd	a0,0(s1)
    800048dc:	c551                	beqz	a0,80004968 <pipealloc+0xb2>
    800048de:	00000097          	auipc	ra,0x0
    800048e2:	bc0080e7          	jalr	-1088(ra) # 8000449e <filealloc>
    800048e6:	00a93023          	sd	a0,0(s2)
    800048ea:	c92d                	beqz	a0,8000495c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048ec:	ffffc097          	auipc	ra,0xffffc
    800048f0:	28a080e7          	jalr	650(ra) # 80000b76 <kalloc>
    800048f4:	89aa                	mv	s3,a0
    800048f6:	c125                	beqz	a0,80004956 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800048f8:	4a05                	li	s4,1
    800048fa:	23452023          	sw	s4,544(a0)
  pi->writeopen = 1;
    800048fe:	23452223          	sw	s4,548(a0)
  pi->nwrite = 0;
    80004902:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004906:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000490a:	00004597          	auipc	a1,0x4
    8000490e:	d9e58593          	addi	a1,a1,-610 # 800086a8 <syscalls+0x2b0>
    80004912:	ffffc097          	auipc	ra,0xffffc
    80004916:	2c4080e7          	jalr	708(ra) # 80000bd6 <initlock>
  (*f0)->type = FD_PIPE;
    8000491a:	609c                	ld	a5,0(s1)
    8000491c:	0147a023          	sw	s4,0(a5)
  (*f0)->readable = 1;
    80004920:	609c                	ld	a5,0(s1)
    80004922:	01478423          	sb	s4,8(a5)
  (*f0)->writable = 0;
    80004926:	609c                	ld	a5,0(s1)
    80004928:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000492c:	609c                	ld	a5,0(s1)
    8000492e:	0137b823          	sd	s3,16(a5)
  (*f1)->type = FD_PIPE;
    80004932:	00093783          	ld	a5,0(s2)
    80004936:	0147a023          	sw	s4,0(a5)
  (*f1)->readable = 0;
    8000493a:	00093783          	ld	a5,0(s2)
    8000493e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004942:	00093783          	ld	a5,0(s2)
    80004946:	014784a3          	sb	s4,9(a5)
  (*f1)->pipe = pi;
    8000494a:	00093783          	ld	a5,0(s2)
    8000494e:	0137b823          	sd	s3,16(a5)
  return 0;
    80004952:	4501                	li	a0,0
    80004954:	a025                	j	8000497c <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004956:	6088                	ld	a0,0(s1)
    80004958:	e501                	bnez	a0,80004960 <pipealloc+0xaa>
    8000495a:	a039                	j	80004968 <pipealloc+0xb2>
    8000495c:	6088                	ld	a0,0(s1)
    8000495e:	c51d                	beqz	a0,8000498c <pipealloc+0xd6>
    fileclose(*f0);
    80004960:	00000097          	auipc	ra,0x0
    80004964:	c0e080e7          	jalr	-1010(ra) # 8000456e <fileclose>
  if(*f1)
    80004968:	00093783          	ld	a5,0(s2)
    fileclose(*f1);
  return -1;
    8000496c:	557d                	li	a0,-1
  if(*f1)
    8000496e:	c799                	beqz	a5,8000497c <pipealloc+0xc6>
    fileclose(*f1);
    80004970:	853e                	mv	a0,a5
    80004972:	00000097          	auipc	ra,0x0
    80004976:	bfc080e7          	jalr	-1028(ra) # 8000456e <fileclose>
  return -1;
    8000497a:	557d                	li	a0,-1
}
    8000497c:	70a2                	ld	ra,40(sp)
    8000497e:	7402                	ld	s0,32(sp)
    80004980:	64e2                	ld	s1,24(sp)
    80004982:	6942                	ld	s2,16(sp)
    80004984:	69a2                	ld	s3,8(sp)
    80004986:	6a02                	ld	s4,0(sp)
    80004988:	6145                	addi	sp,sp,48
    8000498a:	8082                	ret
  return -1;
    8000498c:	557d                	li	a0,-1
    8000498e:	b7fd                	j	8000497c <pipealloc+0xc6>

0000000080004990 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004990:	1101                	addi	sp,sp,-32
    80004992:	ec06                	sd	ra,24(sp)
    80004994:	e822                	sd	s0,16(sp)
    80004996:	e426                	sd	s1,8(sp)
    80004998:	e04a                	sd	s2,0(sp)
    8000499a:	1000                	addi	s0,sp,32
    8000499c:	84aa                	mv	s1,a0
    8000499e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049a0:	ffffc097          	auipc	ra,0xffffc
    800049a4:	2c6080e7          	jalr	710(ra) # 80000c66 <acquire>
  if(writable){
    800049a8:	02090d63          	beqz	s2,800049e2 <pipeclose+0x52>
    pi->writeopen = 0;
    800049ac:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049b0:	21848513          	addi	a0,s1,536
    800049b4:	ffffe097          	auipc	ra,0xffffe
    800049b8:	9ea080e7          	jalr	-1558(ra) # 8000239e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049bc:	2204b783          	ld	a5,544(s1)
    800049c0:	eb95                	bnez	a5,800049f4 <pipeclose+0x64>
    release(&pi->lock);
    800049c2:	8526                	mv	a0,s1
    800049c4:	ffffc097          	auipc	ra,0xffffc
    800049c8:	356080e7          	jalr	854(ra) # 80000d1a <release>
    kfree((char*)pi);
    800049cc:	8526                	mv	a0,s1
    800049ce:	ffffc097          	auipc	ra,0xffffc
    800049d2:	0a8080e7          	jalr	168(ra) # 80000a76 <kfree>
  } else
    release(&pi->lock);
}
    800049d6:	60e2                	ld	ra,24(sp)
    800049d8:	6442                	ld	s0,16(sp)
    800049da:	64a2                	ld	s1,8(sp)
    800049dc:	6902                	ld	s2,0(sp)
    800049de:	6105                	addi	sp,sp,32
    800049e0:	8082                	ret
    pi->readopen = 0;
    800049e2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049e6:	21c48513          	addi	a0,s1,540
    800049ea:	ffffe097          	auipc	ra,0xffffe
    800049ee:	9b4080e7          	jalr	-1612(ra) # 8000239e <wakeup>
    800049f2:	b7e9                	j	800049bc <pipeclose+0x2c>
    release(&pi->lock);
    800049f4:	8526                	mv	a0,s1
    800049f6:	ffffc097          	auipc	ra,0xffffc
    800049fa:	324080e7          	jalr	804(ra) # 80000d1a <release>
}
    800049fe:	bfe1                	j	800049d6 <pipeclose+0x46>

0000000080004a00 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a00:	7119                	addi	sp,sp,-128
    80004a02:	fc86                	sd	ra,120(sp)
    80004a04:	f8a2                	sd	s0,112(sp)
    80004a06:	f4a6                	sd	s1,104(sp)
    80004a08:	f0ca                	sd	s2,96(sp)
    80004a0a:	ecce                	sd	s3,88(sp)
    80004a0c:	e8d2                	sd	s4,80(sp)
    80004a0e:	e4d6                	sd	s5,72(sp)
    80004a10:	e0da                	sd	s6,64(sp)
    80004a12:	fc5e                	sd	s7,56(sp)
    80004a14:	f862                	sd	s8,48(sp)
    80004a16:	f466                	sd	s9,40(sp)
    80004a18:	f06a                	sd	s10,32(sp)
    80004a1a:	ec6e                	sd	s11,24(sp)
    80004a1c:	0100                	addi	s0,sp,128
    80004a1e:	84aa                	mv	s1,a0
    80004a20:	8d2e                	mv	s10,a1
    80004a22:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004a24:	ffffd097          	auipc	ra,0xffffd
    80004a28:	fda080e7          	jalr	-38(ra) # 800019fe <myproc>
    80004a2c:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004a2e:	8526                	mv	a0,s1
    80004a30:	ffffc097          	auipc	ra,0xffffc
    80004a34:	236080e7          	jalr	566(ra) # 80000c66 <acquire>
  for(i = 0; i < n; i++){
    80004a38:	0d605f63          	blez	s6,80004b16 <pipewrite+0x116>
    80004a3c:	89a6                	mv	s3,s1
    80004a3e:	3b7d                	addiw	s6,s6,-1
    80004a40:	1b02                	slli	s6,s6,0x20
    80004a42:	020b5b13          	srli	s6,s6,0x20
    80004a46:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004a48:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a4c:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a50:	5dfd                	li	s11,-1
    80004a52:	000b8c9b          	sext.w	s9,s7
    80004a56:	8c66                	mv	s8,s9
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004a58:	2184a783          	lw	a5,536(s1)
    80004a5c:	21c4a703          	lw	a4,540(s1)
    80004a60:	2007879b          	addiw	a5,a5,512
    80004a64:	06f71763          	bne	a4,a5,80004ad2 <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004a68:	2204a783          	lw	a5,544(s1)
    80004a6c:	cf8d                	beqz	a5,80004aa6 <pipewrite+0xa6>
    80004a6e:	03092783          	lw	a5,48(s2)
    80004a72:	eb95                	bnez	a5,80004aa6 <pipewrite+0xa6>
      wakeup(&pi->nread);
    80004a74:	8556                	mv	a0,s5
    80004a76:	ffffe097          	auipc	ra,0xffffe
    80004a7a:	928080e7          	jalr	-1752(ra) # 8000239e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a7e:	85ce                	mv	a1,s3
    80004a80:	8552                	mv	a0,s4
    80004a82:	ffffd097          	auipc	ra,0xffffd
    80004a86:	796080e7          	jalr	1942(ra) # 80002218 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004a8a:	2184a783          	lw	a5,536(s1)
    80004a8e:	21c4a703          	lw	a4,540(s1)
    80004a92:	2007879b          	addiw	a5,a5,512
    80004a96:	02f71e63          	bne	a4,a5,80004ad2 <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004a9a:	2204a783          	lw	a5,544(s1)
    80004a9e:	c781                	beqz	a5,80004aa6 <pipewrite+0xa6>
    80004aa0:	03092783          	lw	a5,48(s2)
    80004aa4:	dbe1                	beqz	a5,80004a74 <pipewrite+0x74>
        release(&pi->lock);
    80004aa6:	8526                	mv	a0,s1
    80004aa8:	ffffc097          	auipc	ra,0xffffc
    80004aac:	272080e7          	jalr	626(ra) # 80000d1a <release>
        return -1;
    80004ab0:	5c7d                	li	s8,-1
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004ab2:	8562                	mv	a0,s8
    80004ab4:	70e6                	ld	ra,120(sp)
    80004ab6:	7446                	ld	s0,112(sp)
    80004ab8:	74a6                	ld	s1,104(sp)
    80004aba:	7906                	ld	s2,96(sp)
    80004abc:	69e6                	ld	s3,88(sp)
    80004abe:	6a46                	ld	s4,80(sp)
    80004ac0:	6aa6                	ld	s5,72(sp)
    80004ac2:	6b06                	ld	s6,64(sp)
    80004ac4:	7be2                	ld	s7,56(sp)
    80004ac6:	7c42                	ld	s8,48(sp)
    80004ac8:	7ca2                	ld	s9,40(sp)
    80004aca:	7d02                	ld	s10,32(sp)
    80004acc:	6de2                	ld	s11,24(sp)
    80004ace:	6109                	addi	sp,sp,128
    80004ad0:	8082                	ret
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ad2:	4685                	li	a3,1
    80004ad4:	01ab8633          	add	a2,s7,s10
    80004ad8:	f8f40593          	addi	a1,s0,-113
    80004adc:	05093503          	ld	a0,80(s2)
    80004ae0:	ffffd097          	auipc	ra,0xffffd
    80004ae4:	c86080e7          	jalr	-890(ra) # 80001766 <copyin>
    80004ae8:	03b50863          	beq	a0,s11,80004b18 <pipewrite+0x118>
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004aec:	21c4a783          	lw	a5,540(s1)
    80004af0:	0017871b          	addiw	a4,a5,1
    80004af4:	20e4ae23          	sw	a4,540(s1)
    80004af8:	1ff7f793          	andi	a5,a5,511
    80004afc:	97a6                	add	a5,a5,s1
    80004afe:	f8f44703          	lbu	a4,-113(s0)
    80004b02:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004b06:	001c8c1b          	addiw	s8,s9,1
    80004b0a:	001b8793          	addi	a5,s7,1
    80004b0e:	016b8563          	beq	s7,s6,80004b18 <pipewrite+0x118>
    80004b12:	8bbe                	mv	s7,a5
    80004b14:	bf3d                	j	80004a52 <pipewrite+0x52>
    80004b16:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004b18:	21848513          	addi	a0,s1,536
    80004b1c:	ffffe097          	auipc	ra,0xffffe
    80004b20:	882080e7          	jalr	-1918(ra) # 8000239e <wakeup>
  release(&pi->lock);
    80004b24:	8526                	mv	a0,s1
    80004b26:	ffffc097          	auipc	ra,0xffffc
    80004b2a:	1f4080e7          	jalr	500(ra) # 80000d1a <release>
  return i;
    80004b2e:	b751                	j	80004ab2 <pipewrite+0xb2>

0000000080004b30 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b30:	715d                	addi	sp,sp,-80
    80004b32:	e486                	sd	ra,72(sp)
    80004b34:	e0a2                	sd	s0,64(sp)
    80004b36:	fc26                	sd	s1,56(sp)
    80004b38:	f84a                	sd	s2,48(sp)
    80004b3a:	f44e                	sd	s3,40(sp)
    80004b3c:	f052                	sd	s4,32(sp)
    80004b3e:	ec56                	sd	s5,24(sp)
    80004b40:	e85a                	sd	s6,16(sp)
    80004b42:	0880                	addi	s0,sp,80
    80004b44:	84aa                	mv	s1,a0
    80004b46:	89ae                	mv	s3,a1
    80004b48:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b4a:	ffffd097          	auipc	ra,0xffffd
    80004b4e:	eb4080e7          	jalr	-332(ra) # 800019fe <myproc>
    80004b52:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b54:	8526                	mv	a0,s1
    80004b56:	ffffc097          	auipc	ra,0xffffc
    80004b5a:	110080e7          	jalr	272(ra) # 80000c66 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b5e:	2184a703          	lw	a4,536(s1)
    80004b62:	21c4a783          	lw	a5,540(s1)
    80004b66:	06f71b63          	bne	a4,a5,80004bdc <piperead+0xac>
    80004b6a:	8926                	mv	s2,s1
    80004b6c:	2244a783          	lw	a5,548(s1)
    80004b70:	cf9d                	beqz	a5,80004bae <piperead+0x7e>
    if(pr->killed){
    80004b72:	030a2783          	lw	a5,48(s4)
    80004b76:	e78d                	bnez	a5,80004ba0 <piperead+0x70>
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b78:	21848b13          	addi	s6,s1,536
    80004b7c:	85ca                	mv	a1,s2
    80004b7e:	855a                	mv	a0,s6
    80004b80:	ffffd097          	auipc	ra,0xffffd
    80004b84:	698080e7          	jalr	1688(ra) # 80002218 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b88:	2184a703          	lw	a4,536(s1)
    80004b8c:	21c4a783          	lw	a5,540(s1)
    80004b90:	04f71663          	bne	a4,a5,80004bdc <piperead+0xac>
    80004b94:	2244a783          	lw	a5,548(s1)
    80004b98:	cb99                	beqz	a5,80004bae <piperead+0x7e>
    if(pr->killed){
    80004b9a:	030a2783          	lw	a5,48(s4)
    80004b9e:	dff9                	beqz	a5,80004b7c <piperead+0x4c>
      release(&pi->lock);
    80004ba0:	8526                	mv	a0,s1
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	178080e7          	jalr	376(ra) # 80000d1a <release>
      return -1;
    80004baa:	597d                	li	s2,-1
    80004bac:	a829                	j	80004bc6 <piperead+0x96>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(pi->nread == pi->nwrite)
    80004bae:	4901                	li	s2,0
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004bb0:	21c48513          	addi	a0,s1,540
    80004bb4:	ffffd097          	auipc	ra,0xffffd
    80004bb8:	7ea080e7          	jalr	2026(ra) # 8000239e <wakeup>
  release(&pi->lock);
    80004bbc:	8526                	mv	a0,s1
    80004bbe:	ffffc097          	auipc	ra,0xffffc
    80004bc2:	15c080e7          	jalr	348(ra) # 80000d1a <release>
  return i;
}
    80004bc6:	854a                	mv	a0,s2
    80004bc8:	60a6                	ld	ra,72(sp)
    80004bca:	6406                	ld	s0,64(sp)
    80004bcc:	74e2                	ld	s1,56(sp)
    80004bce:	7942                	ld	s2,48(sp)
    80004bd0:	79a2                	ld	s3,40(sp)
    80004bd2:	7a02                	ld	s4,32(sp)
    80004bd4:	6ae2                	ld	s5,24(sp)
    80004bd6:	6b42                	ld	s6,16(sp)
    80004bd8:	6161                	addi	sp,sp,80
    80004bda:	8082                	ret
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bdc:	4901                	li	s2,0
    80004bde:	fd5059e3          	blez	s5,80004bb0 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004be2:	2184a783          	lw	a5,536(s1)
    80004be6:	4901                	li	s2,0
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004be8:	5b7d                	li	s6,-1
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004bea:	0017871b          	addiw	a4,a5,1
    80004bee:	20e4ac23          	sw	a4,536(s1)
    80004bf2:	1ff7f793          	andi	a5,a5,511
    80004bf6:	97a6                	add	a5,a5,s1
    80004bf8:	0187c783          	lbu	a5,24(a5)
    80004bfc:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c00:	4685                	li	a3,1
    80004c02:	fbf40613          	addi	a2,s0,-65
    80004c06:	85ce                	mv	a1,s3
    80004c08:	050a3503          	ld	a0,80(s4)
    80004c0c:	ffffd097          	auipc	ra,0xffffd
    80004c10:	ace080e7          	jalr	-1330(ra) # 800016da <copyout>
    80004c14:	f9650ee3          	beq	a0,s6,80004bb0 <piperead+0x80>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c18:	2905                	addiw	s2,s2,1
    80004c1a:	f92a8be3          	beq	s5,s2,80004bb0 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004c1e:	2184a783          	lw	a5,536(s1)
    80004c22:	0985                	addi	s3,s3,1
    80004c24:	21c4a703          	lw	a4,540(s1)
    80004c28:	fcf711e3          	bne	a4,a5,80004bea <piperead+0xba>
    80004c2c:	b751                	j	80004bb0 <piperead+0x80>

0000000080004c2e <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004c2e:	de010113          	addi	sp,sp,-544
    80004c32:	20113c23          	sd	ra,536(sp)
    80004c36:	20813823          	sd	s0,528(sp)
    80004c3a:	20913423          	sd	s1,520(sp)
    80004c3e:	21213023          	sd	s2,512(sp)
    80004c42:	ffce                	sd	s3,504(sp)
    80004c44:	fbd2                	sd	s4,496(sp)
    80004c46:	f7d6                	sd	s5,488(sp)
    80004c48:	f3da                	sd	s6,480(sp)
    80004c4a:	efde                	sd	s7,472(sp)
    80004c4c:	ebe2                	sd	s8,464(sp)
    80004c4e:	e7e6                	sd	s9,456(sp)
    80004c50:	e3ea                	sd	s10,448(sp)
    80004c52:	ff6e                	sd	s11,440(sp)
    80004c54:	1400                	addi	s0,sp,544
    80004c56:	892a                	mv	s2,a0
    80004c58:	dea43823          	sd	a0,-528(s0)
    80004c5c:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c60:	ffffd097          	auipc	ra,0xffffd
    80004c64:	d9e080e7          	jalr	-610(ra) # 800019fe <myproc>
    80004c68:	84aa                	mv	s1,a0

  begin_op();
    80004c6a:	fffff097          	auipc	ra,0xfffff
    80004c6e:	400080e7          	jalr	1024(ra) # 8000406a <begin_op>

  if((ip = namei(path)) == 0){
    80004c72:	854a                	mv	a0,s2
    80004c74:	fffff097          	auipc	ra,0xfffff
    80004c78:	1d8080e7          	jalr	472(ra) # 80003e4c <namei>
    80004c7c:	c93d                	beqz	a0,80004cf2 <exec+0xc4>
    80004c7e:	892a                	mv	s2,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c80:	fffff097          	auipc	ra,0xfffff
    80004c84:	a0e080e7          	jalr	-1522(ra) # 8000368e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c88:	04000713          	li	a4,64
    80004c8c:	4681                	li	a3,0
    80004c8e:	e4840613          	addi	a2,s0,-440
    80004c92:	4581                	li	a1,0
    80004c94:	854a                	mv	a0,s2
    80004c96:	fffff097          	auipc	ra,0xfffff
    80004c9a:	cae080e7          	jalr	-850(ra) # 80003944 <readi>
    80004c9e:	04000793          	li	a5,64
    80004ca2:	00f51a63          	bne	a0,a5,80004cb6 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004ca6:	e4842703          	lw	a4,-440(s0)
    80004caa:	464c47b7          	lui	a5,0x464c4
    80004cae:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004cb2:	04f70663          	beq	a4,a5,80004cfe <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004cb6:	854a                	mv	a0,s2
    80004cb8:	fffff097          	auipc	ra,0xfffff
    80004cbc:	c3a080e7          	jalr	-966(ra) # 800038f2 <iunlockput>
    end_op();
    80004cc0:	fffff097          	auipc	ra,0xfffff
    80004cc4:	42a080e7          	jalr	1066(ra) # 800040ea <end_op>
  }
  return -1;
    80004cc8:	557d                	li	a0,-1
}
    80004cca:	21813083          	ld	ra,536(sp)
    80004cce:	21013403          	ld	s0,528(sp)
    80004cd2:	20813483          	ld	s1,520(sp)
    80004cd6:	20013903          	ld	s2,512(sp)
    80004cda:	79fe                	ld	s3,504(sp)
    80004cdc:	7a5e                	ld	s4,496(sp)
    80004cde:	7abe                	ld	s5,488(sp)
    80004ce0:	7b1e                	ld	s6,480(sp)
    80004ce2:	6bfe                	ld	s7,472(sp)
    80004ce4:	6c5e                	ld	s8,464(sp)
    80004ce6:	6cbe                	ld	s9,456(sp)
    80004ce8:	6d1e                	ld	s10,448(sp)
    80004cea:	7dfa                	ld	s11,440(sp)
    80004cec:	22010113          	addi	sp,sp,544
    80004cf0:	8082                	ret
    end_op();
    80004cf2:	fffff097          	auipc	ra,0xfffff
    80004cf6:	3f8080e7          	jalr	1016(ra) # 800040ea <end_op>
    return -1;
    80004cfa:	557d                	li	a0,-1
    80004cfc:	b7f9                	j	80004cca <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004cfe:	8526                	mv	a0,s1
    80004d00:	ffffd097          	auipc	ra,0xffffd
    80004d04:	dc4080e7          	jalr	-572(ra) # 80001ac4 <proc_pagetable>
    80004d08:	e0a43423          	sd	a0,-504(s0)
    80004d0c:	d54d                	beqz	a0,80004cb6 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d0e:	e6842983          	lw	s3,-408(s0)
    80004d12:	e8045783          	lhu	a5,-384(s0)
    80004d16:	c7ad                	beqz	a5,80004d80 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004d18:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d1a:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004d1c:	6c05                	lui	s8,0x1
    80004d1e:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    80004d22:	def43423          	sd	a5,-536(s0)
    80004d26:	7cfd                	lui	s9,0xfffff
    80004d28:	ac1d                	j	80004f5e <exec+0x330>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004d2a:	00004517          	auipc	a0,0x4
    80004d2e:	98650513          	addi	a0,a0,-1658 # 800086b0 <syscalls+0x2b8>
    80004d32:	ffffc097          	auipc	ra,0xffffc
    80004d36:	846080e7          	jalr	-1978(ra) # 80000578 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d3a:	8756                	mv	a4,s5
    80004d3c:	009d86bb          	addw	a3,s11,s1
    80004d40:	4581                	li	a1,0
    80004d42:	854a                	mv	a0,s2
    80004d44:	fffff097          	auipc	ra,0xfffff
    80004d48:	c00080e7          	jalr	-1024(ra) # 80003944 <readi>
    80004d4c:	2501                	sext.w	a0,a0
    80004d4e:	1aaa9e63          	bne	s5,a0,80004f0a <exec+0x2dc>
  for(i = 0; i < sz; i += PGSIZE){
    80004d52:	6785                	lui	a5,0x1
    80004d54:	9cbd                	addw	s1,s1,a5
    80004d56:	014c8a3b          	addw	s4,s9,s4
    80004d5a:	1f74f963          	bleu	s7,s1,80004f4c <exec+0x31e>
    pa = walkaddr(pagetable, va + i);
    80004d5e:	02049593          	slli	a1,s1,0x20
    80004d62:	9181                	srli	a1,a1,0x20
    80004d64:	95ea                	add	a1,a1,s10
    80004d66:	e0843503          	ld	a0,-504(s0)
    80004d6a:	ffffc097          	auipc	ra,0xffffc
    80004d6e:	3ae080e7          	jalr	942(ra) # 80001118 <walkaddr>
    80004d72:	862a                	mv	a2,a0
    if(pa == 0)
    80004d74:	d95d                	beqz	a0,80004d2a <exec+0xfc>
      n = PGSIZE;
    80004d76:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    80004d78:	fd8a71e3          	bleu	s8,s4,80004d3a <exec+0x10c>
      n = sz - i;
    80004d7c:	8ad2                	mv	s5,s4
    80004d7e:	bf75                	j	80004d3a <exec+0x10c>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004d80:	4481                	li	s1,0
  iunlockput(ip);
    80004d82:	854a                	mv	a0,s2
    80004d84:	fffff097          	auipc	ra,0xfffff
    80004d88:	b6e080e7          	jalr	-1170(ra) # 800038f2 <iunlockput>
  end_op();
    80004d8c:	fffff097          	auipc	ra,0xfffff
    80004d90:	35e080e7          	jalr	862(ra) # 800040ea <end_op>
  p = myproc();
    80004d94:	ffffd097          	auipc	ra,0xffffd
    80004d98:	c6a080e7          	jalr	-918(ra) # 800019fe <myproc>
    80004d9c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004d9e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004da2:	6785                	lui	a5,0x1
    80004da4:	17fd                	addi	a5,a5,-1
    80004da6:	94be                	add	s1,s1,a5
    80004da8:	77fd                	lui	a5,0xfffff
    80004daa:	8fe5                	and	a5,a5,s1
    80004dac:	e0f43023          	sd	a5,-512(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004db0:	6609                	lui	a2,0x2
    80004db2:	963e                	add	a2,a2,a5
    80004db4:	85be                	mv	a1,a5
    80004db6:	e0843483          	ld	s1,-504(s0)
    80004dba:	8526                	mv	a0,s1
    80004dbc:	ffffc097          	auipc	ra,0xffffc
    80004dc0:	6ce080e7          	jalr	1742(ra) # 8000148a <uvmalloc>
    80004dc4:	8b2a                	mv	s6,a0
  ip = 0;
    80004dc6:	4901                	li	s2,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004dc8:	14050163          	beqz	a0,80004f0a <exec+0x2dc>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004dcc:	75f9                	lui	a1,0xffffe
    80004dce:	95aa                	add	a1,a1,a0
    80004dd0:	8526                	mv	a0,s1
    80004dd2:	ffffd097          	auipc	ra,0xffffd
    80004dd6:	8d6080e7          	jalr	-1834(ra) # 800016a8 <uvmclear>
  stackbase = sp - PGSIZE;
    80004dda:	7bfd                	lui	s7,0xfffff
    80004ddc:	9bda                	add	s7,s7,s6
  for(argc = 0; argv[argc]; argc++) {
    80004dde:	df843783          	ld	a5,-520(s0)
    80004de2:	6388                	ld	a0,0(a5)
    80004de4:	c925                	beqz	a0,80004e54 <exec+0x226>
    80004de6:	e8840993          	addi	s3,s0,-376
    80004dea:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80004dee:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004df0:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004df2:	ffffc097          	auipc	ra,0xffffc
    80004df6:	11a080e7          	jalr	282(ra) # 80000f0c <strlen>
    80004dfa:	2505                	addiw	a0,a0,1
    80004dfc:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e00:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004e04:	13796863          	bltu	s2,s7,80004f34 <exec+0x306>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e08:	df843c83          	ld	s9,-520(s0)
    80004e0c:	000cba03          	ld	s4,0(s9) # fffffffffffff000 <end+0xffffffff7ffd9000>
    80004e10:	8552                	mv	a0,s4
    80004e12:	ffffc097          	auipc	ra,0xffffc
    80004e16:	0fa080e7          	jalr	250(ra) # 80000f0c <strlen>
    80004e1a:	0015069b          	addiw	a3,a0,1
    80004e1e:	8652                	mv	a2,s4
    80004e20:	85ca                	mv	a1,s2
    80004e22:	e0843503          	ld	a0,-504(s0)
    80004e26:	ffffd097          	auipc	ra,0xffffd
    80004e2a:	8b4080e7          	jalr	-1868(ra) # 800016da <copyout>
    80004e2e:	10054763          	bltz	a0,80004f3c <exec+0x30e>
    ustack[argc] = sp;
    80004e32:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e36:	0485                	addi	s1,s1,1
    80004e38:	008c8793          	addi	a5,s9,8
    80004e3c:	def43c23          	sd	a5,-520(s0)
    80004e40:	008cb503          	ld	a0,8(s9)
    80004e44:	c911                	beqz	a0,80004e58 <exec+0x22a>
    if(argc >= MAXARG)
    80004e46:	09a1                	addi	s3,s3,8
    80004e48:	fb8995e3          	bne	s3,s8,80004df2 <exec+0x1c4>
  sz = sz1;
    80004e4c:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80004e50:	4901                	li	s2,0
    80004e52:	a865                	j	80004f0a <exec+0x2dc>
  sp = sz;
    80004e54:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004e56:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e58:	00349793          	slli	a5,s1,0x3
    80004e5c:	f9040713          	addi	a4,s0,-112
    80004e60:	97ba                	add	a5,a5,a4
    80004e62:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    80004e66:	00148693          	addi	a3,s1,1
    80004e6a:	068e                	slli	a3,a3,0x3
    80004e6c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e70:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004e74:	01797663          	bleu	s7,s2,80004e80 <exec+0x252>
  sz = sz1;
    80004e78:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80004e7c:	4901                	li	s2,0
    80004e7e:	a071                	j	80004f0a <exec+0x2dc>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e80:	e8840613          	addi	a2,s0,-376
    80004e84:	85ca                	mv	a1,s2
    80004e86:	e0843503          	ld	a0,-504(s0)
    80004e8a:	ffffd097          	auipc	ra,0xffffd
    80004e8e:	850080e7          	jalr	-1968(ra) # 800016da <copyout>
    80004e92:	0a054963          	bltz	a0,80004f44 <exec+0x316>
  p->trapframe->a1 = sp;
    80004e96:	058ab783          	ld	a5,88(s5)
    80004e9a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e9e:	df043783          	ld	a5,-528(s0)
    80004ea2:	0007c703          	lbu	a4,0(a5)
    80004ea6:	cf11                	beqz	a4,80004ec2 <exec+0x294>
    80004ea8:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004eaa:	02f00693          	li	a3,47
    80004eae:	a029                	j	80004eb8 <exec+0x28a>
  for(last=s=path; *s; s++)
    80004eb0:	0785                	addi	a5,a5,1
    80004eb2:	fff7c703          	lbu	a4,-1(a5)
    80004eb6:	c711                	beqz	a4,80004ec2 <exec+0x294>
    if(*s == '/')
    80004eb8:	fed71ce3          	bne	a4,a3,80004eb0 <exec+0x282>
      last = s+1;
    80004ebc:	def43823          	sd	a5,-528(s0)
    80004ec0:	bfc5                	j	80004eb0 <exec+0x282>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ec2:	4641                	li	a2,16
    80004ec4:	df043583          	ld	a1,-528(s0)
    80004ec8:	158a8513          	addi	a0,s5,344
    80004ecc:	ffffc097          	auipc	ra,0xffffc
    80004ed0:	00e080e7          	jalr	14(ra) # 80000eda <safestrcpy>
  oldpagetable = p->pagetable;
    80004ed4:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004ed8:	e0843783          	ld	a5,-504(s0)
    80004edc:	04fab823          	sd	a5,80(s5)
  p->sz = sz;
    80004ee0:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004ee4:	058ab783          	ld	a5,88(s5)
    80004ee8:	e6043703          	ld	a4,-416(s0)
    80004eec:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004eee:	058ab783          	ld	a5,88(s5)
    80004ef2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004ef6:	85ea                	mv	a1,s10
    80004ef8:	ffffd097          	auipc	ra,0xffffd
    80004efc:	c68080e7          	jalr	-920(ra) # 80001b60 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f00:	0004851b          	sext.w	a0,s1
    80004f04:	b3d9                	j	80004cca <exec+0x9c>
    80004f06:	e0943023          	sd	s1,-512(s0)
    proc_freepagetable(pagetable, sz);
    80004f0a:	e0043583          	ld	a1,-512(s0)
    80004f0e:	e0843503          	ld	a0,-504(s0)
    80004f12:	ffffd097          	auipc	ra,0xffffd
    80004f16:	c4e080e7          	jalr	-946(ra) # 80001b60 <proc_freepagetable>
  if(ip){
    80004f1a:	d8091ee3          	bnez	s2,80004cb6 <exec+0x88>
  return -1;
    80004f1e:	557d                	li	a0,-1
    80004f20:	b36d                	j	80004cca <exec+0x9c>
    80004f22:	e0943023          	sd	s1,-512(s0)
    80004f26:	b7d5                	j	80004f0a <exec+0x2dc>
    80004f28:	e0943023          	sd	s1,-512(s0)
    80004f2c:	bff9                	j	80004f0a <exec+0x2dc>
    80004f2e:	e0943023          	sd	s1,-512(s0)
    80004f32:	bfe1                	j	80004f0a <exec+0x2dc>
  sz = sz1;
    80004f34:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80004f38:	4901                	li	s2,0
    80004f3a:	bfc1                	j	80004f0a <exec+0x2dc>
  sz = sz1;
    80004f3c:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80004f40:	4901                	li	s2,0
    80004f42:	b7e1                	j	80004f0a <exec+0x2dc>
  sz = sz1;
    80004f44:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80004f48:	4901                	li	s2,0
    80004f4a:	b7c1                	j	80004f0a <exec+0x2dc>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f4c:	e0043483          	ld	s1,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f50:	2b05                	addiw	s6,s6,1
    80004f52:	0389899b          	addiw	s3,s3,56
    80004f56:	e8045783          	lhu	a5,-384(s0)
    80004f5a:	e2fb54e3          	ble	a5,s6,80004d82 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f5e:	2981                	sext.w	s3,s3
    80004f60:	03800713          	li	a4,56
    80004f64:	86ce                	mv	a3,s3
    80004f66:	e1040613          	addi	a2,s0,-496
    80004f6a:	4581                	li	a1,0
    80004f6c:	854a                	mv	a0,s2
    80004f6e:	fffff097          	auipc	ra,0xfffff
    80004f72:	9d6080e7          	jalr	-1578(ra) # 80003944 <readi>
    80004f76:	03800793          	li	a5,56
    80004f7a:	f8f516e3          	bne	a0,a5,80004f06 <exec+0x2d8>
    if(ph.type != ELF_PROG_LOAD)
    80004f7e:	e1042783          	lw	a5,-496(s0)
    80004f82:	4705                	li	a4,1
    80004f84:	fce796e3          	bne	a5,a4,80004f50 <exec+0x322>
    if(ph.memsz < ph.filesz)
    80004f88:	e3843603          	ld	a2,-456(s0)
    80004f8c:	e3043783          	ld	a5,-464(s0)
    80004f90:	f8f669e3          	bltu	a2,a5,80004f22 <exec+0x2f4>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f94:	e2043783          	ld	a5,-480(s0)
    80004f98:	963e                	add	a2,a2,a5
    80004f9a:	f8f667e3          	bltu	a2,a5,80004f28 <exec+0x2fa>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f9e:	85a6                	mv	a1,s1
    80004fa0:	e0843503          	ld	a0,-504(s0)
    80004fa4:	ffffc097          	auipc	ra,0xffffc
    80004fa8:	4e6080e7          	jalr	1254(ra) # 8000148a <uvmalloc>
    80004fac:	e0a43023          	sd	a0,-512(s0)
    80004fb0:	dd3d                	beqz	a0,80004f2e <exec+0x300>
    if(ph.vaddr % PGSIZE != 0)
    80004fb2:	e2043d03          	ld	s10,-480(s0)
    80004fb6:	de843783          	ld	a5,-536(s0)
    80004fba:	00fd77b3          	and	a5,s10,a5
    80004fbe:	f7b1                	bnez	a5,80004f0a <exec+0x2dc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fc0:	e1842d83          	lw	s11,-488(s0)
    80004fc4:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004fc8:	f80b82e3          	beqz	s7,80004f4c <exec+0x31e>
    80004fcc:	8a5e                	mv	s4,s7
    80004fce:	4481                	li	s1,0
    80004fd0:	b379                	j	80004d5e <exec+0x130>

0000000080004fd2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004fd2:	7179                	addi	sp,sp,-48
    80004fd4:	f406                	sd	ra,40(sp)
    80004fd6:	f022                	sd	s0,32(sp)
    80004fd8:	ec26                	sd	s1,24(sp)
    80004fda:	e84a                	sd	s2,16(sp)
    80004fdc:	1800                	addi	s0,sp,48
    80004fde:	892e                	mv	s2,a1
    80004fe0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004fe2:	fdc40593          	addi	a1,s0,-36
    80004fe6:	ffffe097          	auipc	ra,0xffffe
    80004fea:	ae8080e7          	jalr	-1304(ra) # 80002ace <argint>
    80004fee:	04054063          	bltz	a0,8000502e <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ff2:	fdc42703          	lw	a4,-36(s0)
    80004ff6:	47bd                	li	a5,15
    80004ff8:	02e7ed63          	bltu	a5,a4,80005032 <argfd+0x60>
    80004ffc:	ffffd097          	auipc	ra,0xffffd
    80005000:	a02080e7          	jalr	-1534(ra) # 800019fe <myproc>
    80005004:	fdc42703          	lw	a4,-36(s0)
    80005008:	01a70793          	addi	a5,a4,26
    8000500c:	078e                	slli	a5,a5,0x3
    8000500e:	953e                	add	a0,a0,a5
    80005010:	611c                	ld	a5,0(a0)
    80005012:	c395                	beqz	a5,80005036 <argfd+0x64>
    return -1;
  if(pfd)
    80005014:	00090463          	beqz	s2,8000501c <argfd+0x4a>
    *pfd = fd;
    80005018:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000501c:	4501                	li	a0,0
  if(pf)
    8000501e:	c091                	beqz	s1,80005022 <argfd+0x50>
    *pf = f;
    80005020:	e09c                	sd	a5,0(s1)
}
    80005022:	70a2                	ld	ra,40(sp)
    80005024:	7402                	ld	s0,32(sp)
    80005026:	64e2                	ld	s1,24(sp)
    80005028:	6942                	ld	s2,16(sp)
    8000502a:	6145                	addi	sp,sp,48
    8000502c:	8082                	ret
    return -1;
    8000502e:	557d                	li	a0,-1
    80005030:	bfcd                	j	80005022 <argfd+0x50>
    return -1;
    80005032:	557d                	li	a0,-1
    80005034:	b7fd                	j	80005022 <argfd+0x50>
    80005036:	557d                	li	a0,-1
    80005038:	b7ed                	j	80005022 <argfd+0x50>

000000008000503a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000503a:	1101                	addi	sp,sp,-32
    8000503c:	ec06                	sd	ra,24(sp)
    8000503e:	e822                	sd	s0,16(sp)
    80005040:	e426                	sd	s1,8(sp)
    80005042:	1000                	addi	s0,sp,32
    80005044:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005046:	ffffd097          	auipc	ra,0xffffd
    8000504a:	9b8080e7          	jalr	-1608(ra) # 800019fe <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
    8000504e:	697c                	ld	a5,208(a0)
    80005050:	c395                	beqz	a5,80005074 <fdalloc+0x3a>
    80005052:	0d850713          	addi	a4,a0,216
  for(fd = 0; fd < NOFILE; fd++){
    80005056:	4785                	li	a5,1
    80005058:	4641                	li	a2,16
    if(p->ofile[fd] == 0){
    8000505a:	6314                	ld	a3,0(a4)
    8000505c:	ce89                	beqz	a3,80005076 <fdalloc+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
    8000505e:	2785                	addiw	a5,a5,1
    80005060:	0721                	addi	a4,a4,8
    80005062:	fec79ce3          	bne	a5,a2,8000505a <fdalloc+0x20>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005066:	57fd                	li	a5,-1
}
    80005068:	853e                	mv	a0,a5
    8000506a:	60e2                	ld	ra,24(sp)
    8000506c:	6442                	ld	s0,16(sp)
    8000506e:	64a2                	ld	s1,8(sp)
    80005070:	6105                	addi	sp,sp,32
    80005072:	8082                	ret
  for(fd = 0; fd < NOFILE; fd++){
    80005074:	4781                	li	a5,0
      p->ofile[fd] = f;
    80005076:	01a78713          	addi	a4,a5,26
    8000507a:	070e                	slli	a4,a4,0x3
    8000507c:	953a                	add	a0,a0,a4
    8000507e:	e104                	sd	s1,0(a0)
      return fd;
    80005080:	b7e5                	j	80005068 <fdalloc+0x2e>

0000000080005082 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005082:	715d                	addi	sp,sp,-80
    80005084:	e486                	sd	ra,72(sp)
    80005086:	e0a2                	sd	s0,64(sp)
    80005088:	fc26                	sd	s1,56(sp)
    8000508a:	f84a                	sd	s2,48(sp)
    8000508c:	f44e                	sd	s3,40(sp)
    8000508e:	f052                	sd	s4,32(sp)
    80005090:	ec56                	sd	s5,24(sp)
    80005092:	0880                	addi	s0,sp,80
    80005094:	89ae                	mv	s3,a1
    80005096:	8ab2                	mv	s5,a2
    80005098:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000509a:	fb040593          	addi	a1,s0,-80
    8000509e:	fffff097          	auipc	ra,0xfffff
    800050a2:	dcc080e7          	jalr	-564(ra) # 80003e6a <nameiparent>
    800050a6:	892a                	mv	s2,a0
    800050a8:	12050f63          	beqz	a0,800051e6 <create+0x164>
    return 0;

  ilock(dp);
    800050ac:	ffffe097          	auipc	ra,0xffffe
    800050b0:	5e2080e7          	jalr	1506(ra) # 8000368e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800050b4:	4601                	li	a2,0
    800050b6:	fb040593          	addi	a1,s0,-80
    800050ba:	854a                	mv	a0,s2
    800050bc:	fffff097          	auipc	ra,0xfffff
    800050c0:	ab6080e7          	jalr	-1354(ra) # 80003b72 <dirlookup>
    800050c4:	84aa                	mv	s1,a0
    800050c6:	c921                	beqz	a0,80005116 <create+0x94>
    iunlockput(dp);
    800050c8:	854a                	mv	a0,s2
    800050ca:	fffff097          	auipc	ra,0xfffff
    800050ce:	828080e7          	jalr	-2008(ra) # 800038f2 <iunlockput>
    ilock(ip);
    800050d2:	8526                	mv	a0,s1
    800050d4:	ffffe097          	auipc	ra,0xffffe
    800050d8:	5ba080e7          	jalr	1466(ra) # 8000368e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800050dc:	2981                	sext.w	s3,s3
    800050de:	4789                	li	a5,2
    800050e0:	02f99463          	bne	s3,a5,80005108 <create+0x86>
    800050e4:	0444d783          	lhu	a5,68(s1)
    800050e8:	37f9                	addiw	a5,a5,-2
    800050ea:	17c2                	slli	a5,a5,0x30
    800050ec:	93c1                	srli	a5,a5,0x30
    800050ee:	4705                	li	a4,1
    800050f0:	00f76c63          	bltu	a4,a5,80005108 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800050f4:	8526                	mv	a0,s1
    800050f6:	60a6                	ld	ra,72(sp)
    800050f8:	6406                	ld	s0,64(sp)
    800050fa:	74e2                	ld	s1,56(sp)
    800050fc:	7942                	ld	s2,48(sp)
    800050fe:	79a2                	ld	s3,40(sp)
    80005100:	7a02                	ld	s4,32(sp)
    80005102:	6ae2                	ld	s5,24(sp)
    80005104:	6161                	addi	sp,sp,80
    80005106:	8082                	ret
    iunlockput(ip);
    80005108:	8526                	mv	a0,s1
    8000510a:	ffffe097          	auipc	ra,0xffffe
    8000510e:	7e8080e7          	jalr	2024(ra) # 800038f2 <iunlockput>
    return 0;
    80005112:	4481                	li	s1,0
    80005114:	b7c5                	j	800050f4 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005116:	85ce                	mv	a1,s3
    80005118:	00092503          	lw	a0,0(s2)
    8000511c:	ffffe097          	auipc	ra,0xffffe
    80005120:	3d6080e7          	jalr	982(ra) # 800034f2 <ialloc>
    80005124:	84aa                	mv	s1,a0
    80005126:	c529                	beqz	a0,80005170 <create+0xee>
  ilock(ip);
    80005128:	ffffe097          	auipc	ra,0xffffe
    8000512c:	566080e7          	jalr	1382(ra) # 8000368e <ilock>
  ip->major = major;
    80005130:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005134:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005138:	4785                	li	a5,1
    8000513a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000513e:	8526                	mv	a0,s1
    80005140:	ffffe097          	auipc	ra,0xffffe
    80005144:	482080e7          	jalr	1154(ra) # 800035c2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005148:	2981                	sext.w	s3,s3
    8000514a:	4785                	li	a5,1
    8000514c:	02f98a63          	beq	s3,a5,80005180 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005150:	40d0                	lw	a2,4(s1)
    80005152:	fb040593          	addi	a1,s0,-80
    80005156:	854a                	mv	a0,s2
    80005158:	fffff097          	auipc	ra,0xfffff
    8000515c:	c32080e7          	jalr	-974(ra) # 80003d8a <dirlink>
    80005160:	06054b63          	bltz	a0,800051d6 <create+0x154>
  iunlockput(dp);
    80005164:	854a                	mv	a0,s2
    80005166:	ffffe097          	auipc	ra,0xffffe
    8000516a:	78c080e7          	jalr	1932(ra) # 800038f2 <iunlockput>
  return ip;
    8000516e:	b759                	j	800050f4 <create+0x72>
    panic("create: ialloc");
    80005170:	00003517          	auipc	a0,0x3
    80005174:	56050513          	addi	a0,a0,1376 # 800086d0 <syscalls+0x2d8>
    80005178:	ffffb097          	auipc	ra,0xffffb
    8000517c:	400080e7          	jalr	1024(ra) # 80000578 <panic>
    dp->nlink++;  // for ".."
    80005180:	04a95783          	lhu	a5,74(s2)
    80005184:	2785                	addiw	a5,a5,1
    80005186:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000518a:	854a                	mv	a0,s2
    8000518c:	ffffe097          	auipc	ra,0xffffe
    80005190:	436080e7          	jalr	1078(ra) # 800035c2 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005194:	40d0                	lw	a2,4(s1)
    80005196:	00003597          	auipc	a1,0x3
    8000519a:	54a58593          	addi	a1,a1,1354 # 800086e0 <syscalls+0x2e8>
    8000519e:	8526                	mv	a0,s1
    800051a0:	fffff097          	auipc	ra,0xfffff
    800051a4:	bea080e7          	jalr	-1046(ra) # 80003d8a <dirlink>
    800051a8:	00054f63          	bltz	a0,800051c6 <create+0x144>
    800051ac:	00492603          	lw	a2,4(s2)
    800051b0:	00003597          	auipc	a1,0x3
    800051b4:	53858593          	addi	a1,a1,1336 # 800086e8 <syscalls+0x2f0>
    800051b8:	8526                	mv	a0,s1
    800051ba:	fffff097          	auipc	ra,0xfffff
    800051be:	bd0080e7          	jalr	-1072(ra) # 80003d8a <dirlink>
    800051c2:	f80557e3          	bgez	a0,80005150 <create+0xce>
      panic("create dots");
    800051c6:	00003517          	auipc	a0,0x3
    800051ca:	52a50513          	addi	a0,a0,1322 # 800086f0 <syscalls+0x2f8>
    800051ce:	ffffb097          	auipc	ra,0xffffb
    800051d2:	3aa080e7          	jalr	938(ra) # 80000578 <panic>
    panic("create: dirlink");
    800051d6:	00003517          	auipc	a0,0x3
    800051da:	52a50513          	addi	a0,a0,1322 # 80008700 <syscalls+0x308>
    800051de:	ffffb097          	auipc	ra,0xffffb
    800051e2:	39a080e7          	jalr	922(ra) # 80000578 <panic>
    return 0;
    800051e6:	84aa                	mv	s1,a0
    800051e8:	b731                	j	800050f4 <create+0x72>

00000000800051ea <sys_dup>:
{
    800051ea:	7179                	addi	sp,sp,-48
    800051ec:	f406                	sd	ra,40(sp)
    800051ee:	f022                	sd	s0,32(sp)
    800051f0:	ec26                	sd	s1,24(sp)
    800051f2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800051f4:	fd840613          	addi	a2,s0,-40
    800051f8:	4581                	li	a1,0
    800051fa:	4501                	li	a0,0
    800051fc:	00000097          	auipc	ra,0x0
    80005200:	dd6080e7          	jalr	-554(ra) # 80004fd2 <argfd>
    return -1;
    80005204:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005206:	02054363          	bltz	a0,8000522c <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000520a:	fd843503          	ld	a0,-40(s0)
    8000520e:	00000097          	auipc	ra,0x0
    80005212:	e2c080e7          	jalr	-468(ra) # 8000503a <fdalloc>
    80005216:	84aa                	mv	s1,a0
    return -1;
    80005218:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000521a:	00054963          	bltz	a0,8000522c <sys_dup+0x42>
  filedup(f);
    8000521e:	fd843503          	ld	a0,-40(s0)
    80005222:	fffff097          	auipc	ra,0xfffff
    80005226:	2fa080e7          	jalr	762(ra) # 8000451c <filedup>
  return fd;
    8000522a:	87a6                	mv	a5,s1
}
    8000522c:	853e                	mv	a0,a5
    8000522e:	70a2                	ld	ra,40(sp)
    80005230:	7402                	ld	s0,32(sp)
    80005232:	64e2                	ld	s1,24(sp)
    80005234:	6145                	addi	sp,sp,48
    80005236:	8082                	ret

0000000080005238 <sys_read>:
{
    80005238:	7179                	addi	sp,sp,-48
    8000523a:	f406                	sd	ra,40(sp)
    8000523c:	f022                	sd	s0,32(sp)
    8000523e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005240:	fe840613          	addi	a2,s0,-24
    80005244:	4581                	li	a1,0
    80005246:	4501                	li	a0,0
    80005248:	00000097          	auipc	ra,0x0
    8000524c:	d8a080e7          	jalr	-630(ra) # 80004fd2 <argfd>
    return -1;
    80005250:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005252:	04054163          	bltz	a0,80005294 <sys_read+0x5c>
    80005256:	fe440593          	addi	a1,s0,-28
    8000525a:	4509                	li	a0,2
    8000525c:	ffffe097          	auipc	ra,0xffffe
    80005260:	872080e7          	jalr	-1934(ra) # 80002ace <argint>
    return -1;
    80005264:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005266:	02054763          	bltz	a0,80005294 <sys_read+0x5c>
    8000526a:	fd840593          	addi	a1,s0,-40
    8000526e:	4505                	li	a0,1
    80005270:	ffffe097          	auipc	ra,0xffffe
    80005274:	880080e7          	jalr	-1920(ra) # 80002af0 <argaddr>
    return -1;
    80005278:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000527a:	00054d63          	bltz	a0,80005294 <sys_read+0x5c>
  return fileread(f, p, n);
    8000527e:	fe442603          	lw	a2,-28(s0)
    80005282:	fd843583          	ld	a1,-40(s0)
    80005286:	fe843503          	ld	a0,-24(s0)
    8000528a:	fffff097          	auipc	ra,0xfffff
    8000528e:	41e080e7          	jalr	1054(ra) # 800046a8 <fileread>
    80005292:	87aa                	mv	a5,a0
}
    80005294:	853e                	mv	a0,a5
    80005296:	70a2                	ld	ra,40(sp)
    80005298:	7402                	ld	s0,32(sp)
    8000529a:	6145                	addi	sp,sp,48
    8000529c:	8082                	ret

000000008000529e <sys_write>:
{
    8000529e:	7179                	addi	sp,sp,-48
    800052a0:	f406                	sd	ra,40(sp)
    800052a2:	f022                	sd	s0,32(sp)
    800052a4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052a6:	fe840613          	addi	a2,s0,-24
    800052aa:	4581                	li	a1,0
    800052ac:	4501                	li	a0,0
    800052ae:	00000097          	auipc	ra,0x0
    800052b2:	d24080e7          	jalr	-732(ra) # 80004fd2 <argfd>
    return -1;
    800052b6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052b8:	04054163          	bltz	a0,800052fa <sys_write+0x5c>
    800052bc:	fe440593          	addi	a1,s0,-28
    800052c0:	4509                	li	a0,2
    800052c2:	ffffe097          	auipc	ra,0xffffe
    800052c6:	80c080e7          	jalr	-2036(ra) # 80002ace <argint>
    return -1;
    800052ca:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052cc:	02054763          	bltz	a0,800052fa <sys_write+0x5c>
    800052d0:	fd840593          	addi	a1,s0,-40
    800052d4:	4505                	li	a0,1
    800052d6:	ffffe097          	auipc	ra,0xffffe
    800052da:	81a080e7          	jalr	-2022(ra) # 80002af0 <argaddr>
    return -1;
    800052de:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052e0:	00054d63          	bltz	a0,800052fa <sys_write+0x5c>
  return filewrite(f, p, n);
    800052e4:	fe442603          	lw	a2,-28(s0)
    800052e8:	fd843583          	ld	a1,-40(s0)
    800052ec:	fe843503          	ld	a0,-24(s0)
    800052f0:	fffff097          	auipc	ra,0xfffff
    800052f4:	47a080e7          	jalr	1146(ra) # 8000476a <filewrite>
    800052f8:	87aa                	mv	a5,a0
}
    800052fa:	853e                	mv	a0,a5
    800052fc:	70a2                	ld	ra,40(sp)
    800052fe:	7402                	ld	s0,32(sp)
    80005300:	6145                	addi	sp,sp,48
    80005302:	8082                	ret

0000000080005304 <sys_close>:
{
    80005304:	1101                	addi	sp,sp,-32
    80005306:	ec06                	sd	ra,24(sp)
    80005308:	e822                	sd	s0,16(sp)
    8000530a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000530c:	fe040613          	addi	a2,s0,-32
    80005310:	fec40593          	addi	a1,s0,-20
    80005314:	4501                	li	a0,0
    80005316:	00000097          	auipc	ra,0x0
    8000531a:	cbc080e7          	jalr	-836(ra) # 80004fd2 <argfd>
    return -1;
    8000531e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005320:	02054463          	bltz	a0,80005348 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005324:	ffffc097          	auipc	ra,0xffffc
    80005328:	6da080e7          	jalr	1754(ra) # 800019fe <myproc>
    8000532c:	fec42783          	lw	a5,-20(s0)
    80005330:	07e9                	addi	a5,a5,26
    80005332:	078e                	slli	a5,a5,0x3
    80005334:	953e                	add	a0,a0,a5
    80005336:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000533a:	fe043503          	ld	a0,-32(s0)
    8000533e:	fffff097          	auipc	ra,0xfffff
    80005342:	230080e7          	jalr	560(ra) # 8000456e <fileclose>
  return 0;
    80005346:	4781                	li	a5,0
}
    80005348:	853e                	mv	a0,a5
    8000534a:	60e2                	ld	ra,24(sp)
    8000534c:	6442                	ld	s0,16(sp)
    8000534e:	6105                	addi	sp,sp,32
    80005350:	8082                	ret

0000000080005352 <sys_fstat>:
{
    80005352:	1101                	addi	sp,sp,-32
    80005354:	ec06                	sd	ra,24(sp)
    80005356:	e822                	sd	s0,16(sp)
    80005358:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000535a:	fe840613          	addi	a2,s0,-24
    8000535e:	4581                	li	a1,0
    80005360:	4501                	li	a0,0
    80005362:	00000097          	auipc	ra,0x0
    80005366:	c70080e7          	jalr	-912(ra) # 80004fd2 <argfd>
    return -1;
    8000536a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000536c:	02054563          	bltz	a0,80005396 <sys_fstat+0x44>
    80005370:	fe040593          	addi	a1,s0,-32
    80005374:	4505                	li	a0,1
    80005376:	ffffd097          	auipc	ra,0xffffd
    8000537a:	77a080e7          	jalr	1914(ra) # 80002af0 <argaddr>
    return -1;
    8000537e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005380:	00054b63          	bltz	a0,80005396 <sys_fstat+0x44>
  return filestat(f, st);
    80005384:	fe043583          	ld	a1,-32(s0)
    80005388:	fe843503          	ld	a0,-24(s0)
    8000538c:	fffff097          	auipc	ra,0xfffff
    80005390:	2aa080e7          	jalr	682(ra) # 80004636 <filestat>
    80005394:	87aa                	mv	a5,a0
}
    80005396:	853e                	mv	a0,a5
    80005398:	60e2                	ld	ra,24(sp)
    8000539a:	6442                	ld	s0,16(sp)
    8000539c:	6105                	addi	sp,sp,32
    8000539e:	8082                	ret

00000000800053a0 <sys_link>:
{
    800053a0:	7169                	addi	sp,sp,-304
    800053a2:	f606                	sd	ra,296(sp)
    800053a4:	f222                	sd	s0,288(sp)
    800053a6:	ee26                	sd	s1,280(sp)
    800053a8:	ea4a                	sd	s2,272(sp)
    800053aa:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053ac:	08000613          	li	a2,128
    800053b0:	ed040593          	addi	a1,s0,-304
    800053b4:	4501                	li	a0,0
    800053b6:	ffffd097          	auipc	ra,0xffffd
    800053ba:	75c080e7          	jalr	1884(ra) # 80002b12 <argstr>
    return -1;
    800053be:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053c0:	10054e63          	bltz	a0,800054dc <sys_link+0x13c>
    800053c4:	08000613          	li	a2,128
    800053c8:	f5040593          	addi	a1,s0,-176
    800053cc:	4505                	li	a0,1
    800053ce:	ffffd097          	auipc	ra,0xffffd
    800053d2:	744080e7          	jalr	1860(ra) # 80002b12 <argstr>
    return -1;
    800053d6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053d8:	10054263          	bltz	a0,800054dc <sys_link+0x13c>
  begin_op();
    800053dc:	fffff097          	auipc	ra,0xfffff
    800053e0:	c8e080e7          	jalr	-882(ra) # 8000406a <begin_op>
  if((ip = namei(old)) == 0){
    800053e4:	ed040513          	addi	a0,s0,-304
    800053e8:	fffff097          	auipc	ra,0xfffff
    800053ec:	a64080e7          	jalr	-1436(ra) # 80003e4c <namei>
    800053f0:	84aa                	mv	s1,a0
    800053f2:	c551                	beqz	a0,8000547e <sys_link+0xde>
  ilock(ip);
    800053f4:	ffffe097          	auipc	ra,0xffffe
    800053f8:	29a080e7          	jalr	666(ra) # 8000368e <ilock>
  if(ip->type == T_DIR){
    800053fc:	04449703          	lh	a4,68(s1)
    80005400:	4785                	li	a5,1
    80005402:	08f70463          	beq	a4,a5,8000548a <sys_link+0xea>
  ip->nlink++;
    80005406:	04a4d783          	lhu	a5,74(s1)
    8000540a:	2785                	addiw	a5,a5,1
    8000540c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005410:	8526                	mv	a0,s1
    80005412:	ffffe097          	auipc	ra,0xffffe
    80005416:	1b0080e7          	jalr	432(ra) # 800035c2 <iupdate>
  iunlock(ip);
    8000541a:	8526                	mv	a0,s1
    8000541c:	ffffe097          	auipc	ra,0xffffe
    80005420:	336080e7          	jalr	822(ra) # 80003752 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005424:	fd040593          	addi	a1,s0,-48
    80005428:	f5040513          	addi	a0,s0,-176
    8000542c:	fffff097          	auipc	ra,0xfffff
    80005430:	a3e080e7          	jalr	-1474(ra) # 80003e6a <nameiparent>
    80005434:	892a                	mv	s2,a0
    80005436:	c935                	beqz	a0,800054aa <sys_link+0x10a>
  ilock(dp);
    80005438:	ffffe097          	auipc	ra,0xffffe
    8000543c:	256080e7          	jalr	598(ra) # 8000368e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005440:	00092703          	lw	a4,0(s2)
    80005444:	409c                	lw	a5,0(s1)
    80005446:	04f71d63          	bne	a4,a5,800054a0 <sys_link+0x100>
    8000544a:	40d0                	lw	a2,4(s1)
    8000544c:	fd040593          	addi	a1,s0,-48
    80005450:	854a                	mv	a0,s2
    80005452:	fffff097          	auipc	ra,0xfffff
    80005456:	938080e7          	jalr	-1736(ra) # 80003d8a <dirlink>
    8000545a:	04054363          	bltz	a0,800054a0 <sys_link+0x100>
  iunlockput(dp);
    8000545e:	854a                	mv	a0,s2
    80005460:	ffffe097          	auipc	ra,0xffffe
    80005464:	492080e7          	jalr	1170(ra) # 800038f2 <iunlockput>
  iput(ip);
    80005468:	8526                	mv	a0,s1
    8000546a:	ffffe097          	auipc	ra,0xffffe
    8000546e:	3e0080e7          	jalr	992(ra) # 8000384a <iput>
  end_op();
    80005472:	fffff097          	auipc	ra,0xfffff
    80005476:	c78080e7          	jalr	-904(ra) # 800040ea <end_op>
  return 0;
    8000547a:	4781                	li	a5,0
    8000547c:	a085                	j	800054dc <sys_link+0x13c>
    end_op();
    8000547e:	fffff097          	auipc	ra,0xfffff
    80005482:	c6c080e7          	jalr	-916(ra) # 800040ea <end_op>
    return -1;
    80005486:	57fd                	li	a5,-1
    80005488:	a891                	j	800054dc <sys_link+0x13c>
    iunlockput(ip);
    8000548a:	8526                	mv	a0,s1
    8000548c:	ffffe097          	auipc	ra,0xffffe
    80005490:	466080e7          	jalr	1126(ra) # 800038f2 <iunlockput>
    end_op();
    80005494:	fffff097          	auipc	ra,0xfffff
    80005498:	c56080e7          	jalr	-938(ra) # 800040ea <end_op>
    return -1;
    8000549c:	57fd                	li	a5,-1
    8000549e:	a83d                	j	800054dc <sys_link+0x13c>
    iunlockput(dp);
    800054a0:	854a                	mv	a0,s2
    800054a2:	ffffe097          	auipc	ra,0xffffe
    800054a6:	450080e7          	jalr	1104(ra) # 800038f2 <iunlockput>
  ilock(ip);
    800054aa:	8526                	mv	a0,s1
    800054ac:	ffffe097          	auipc	ra,0xffffe
    800054b0:	1e2080e7          	jalr	482(ra) # 8000368e <ilock>
  ip->nlink--;
    800054b4:	04a4d783          	lhu	a5,74(s1)
    800054b8:	37fd                	addiw	a5,a5,-1
    800054ba:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054be:	8526                	mv	a0,s1
    800054c0:	ffffe097          	auipc	ra,0xffffe
    800054c4:	102080e7          	jalr	258(ra) # 800035c2 <iupdate>
  iunlockput(ip);
    800054c8:	8526                	mv	a0,s1
    800054ca:	ffffe097          	auipc	ra,0xffffe
    800054ce:	428080e7          	jalr	1064(ra) # 800038f2 <iunlockput>
  end_op();
    800054d2:	fffff097          	auipc	ra,0xfffff
    800054d6:	c18080e7          	jalr	-1000(ra) # 800040ea <end_op>
  return -1;
    800054da:	57fd                	li	a5,-1
}
    800054dc:	853e                	mv	a0,a5
    800054de:	70b2                	ld	ra,296(sp)
    800054e0:	7412                	ld	s0,288(sp)
    800054e2:	64f2                	ld	s1,280(sp)
    800054e4:	6952                	ld	s2,272(sp)
    800054e6:	6155                	addi	sp,sp,304
    800054e8:	8082                	ret

00000000800054ea <sys_unlink>:
{
    800054ea:	7151                	addi	sp,sp,-240
    800054ec:	f586                	sd	ra,232(sp)
    800054ee:	f1a2                	sd	s0,224(sp)
    800054f0:	eda6                	sd	s1,216(sp)
    800054f2:	e9ca                	sd	s2,208(sp)
    800054f4:	e5ce                	sd	s3,200(sp)
    800054f6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800054f8:	08000613          	li	a2,128
    800054fc:	f3040593          	addi	a1,s0,-208
    80005500:	4501                	li	a0,0
    80005502:	ffffd097          	auipc	ra,0xffffd
    80005506:	610080e7          	jalr	1552(ra) # 80002b12 <argstr>
    8000550a:	16054f63          	bltz	a0,80005688 <sys_unlink+0x19e>
  begin_op();
    8000550e:	fffff097          	auipc	ra,0xfffff
    80005512:	b5c080e7          	jalr	-1188(ra) # 8000406a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005516:	fb040593          	addi	a1,s0,-80
    8000551a:	f3040513          	addi	a0,s0,-208
    8000551e:	fffff097          	auipc	ra,0xfffff
    80005522:	94c080e7          	jalr	-1716(ra) # 80003e6a <nameiparent>
    80005526:	89aa                	mv	s3,a0
    80005528:	c979                	beqz	a0,800055fe <sys_unlink+0x114>
  ilock(dp);
    8000552a:	ffffe097          	auipc	ra,0xffffe
    8000552e:	164080e7          	jalr	356(ra) # 8000368e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005532:	00003597          	auipc	a1,0x3
    80005536:	1ae58593          	addi	a1,a1,430 # 800086e0 <syscalls+0x2e8>
    8000553a:	fb040513          	addi	a0,s0,-80
    8000553e:	ffffe097          	auipc	ra,0xffffe
    80005542:	61a080e7          	jalr	1562(ra) # 80003b58 <namecmp>
    80005546:	14050863          	beqz	a0,80005696 <sys_unlink+0x1ac>
    8000554a:	00003597          	auipc	a1,0x3
    8000554e:	19e58593          	addi	a1,a1,414 # 800086e8 <syscalls+0x2f0>
    80005552:	fb040513          	addi	a0,s0,-80
    80005556:	ffffe097          	auipc	ra,0xffffe
    8000555a:	602080e7          	jalr	1538(ra) # 80003b58 <namecmp>
    8000555e:	12050c63          	beqz	a0,80005696 <sys_unlink+0x1ac>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005562:	f2c40613          	addi	a2,s0,-212
    80005566:	fb040593          	addi	a1,s0,-80
    8000556a:	854e                	mv	a0,s3
    8000556c:	ffffe097          	auipc	ra,0xffffe
    80005570:	606080e7          	jalr	1542(ra) # 80003b72 <dirlookup>
    80005574:	84aa                	mv	s1,a0
    80005576:	12050063          	beqz	a0,80005696 <sys_unlink+0x1ac>
  ilock(ip);
    8000557a:	ffffe097          	auipc	ra,0xffffe
    8000557e:	114080e7          	jalr	276(ra) # 8000368e <ilock>
  if(ip->nlink < 1)
    80005582:	04a49783          	lh	a5,74(s1)
    80005586:	08f05263          	blez	a5,8000560a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000558a:	04449703          	lh	a4,68(s1)
    8000558e:	4785                	li	a5,1
    80005590:	08f70563          	beq	a4,a5,8000561a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005594:	4641                	li	a2,16
    80005596:	4581                	li	a1,0
    80005598:	fc040513          	addi	a0,s0,-64
    8000559c:	ffffb097          	auipc	ra,0xffffb
    800055a0:	7c6080e7          	jalr	1990(ra) # 80000d62 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055a4:	4741                	li	a4,16
    800055a6:	f2c42683          	lw	a3,-212(s0)
    800055aa:	fc040613          	addi	a2,s0,-64
    800055ae:	4581                	li	a1,0
    800055b0:	854e                	mv	a0,s3
    800055b2:	ffffe097          	auipc	ra,0xffffe
    800055b6:	48a080e7          	jalr	1162(ra) # 80003a3c <writei>
    800055ba:	47c1                	li	a5,16
    800055bc:	0af51363          	bne	a0,a5,80005662 <sys_unlink+0x178>
  if(ip->type == T_DIR){
    800055c0:	04449703          	lh	a4,68(s1)
    800055c4:	4785                	li	a5,1
    800055c6:	0af70663          	beq	a4,a5,80005672 <sys_unlink+0x188>
  iunlockput(dp);
    800055ca:	854e                	mv	a0,s3
    800055cc:	ffffe097          	auipc	ra,0xffffe
    800055d0:	326080e7          	jalr	806(ra) # 800038f2 <iunlockput>
  ip->nlink--;
    800055d4:	04a4d783          	lhu	a5,74(s1)
    800055d8:	37fd                	addiw	a5,a5,-1
    800055da:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055de:	8526                	mv	a0,s1
    800055e0:	ffffe097          	auipc	ra,0xffffe
    800055e4:	fe2080e7          	jalr	-30(ra) # 800035c2 <iupdate>
  iunlockput(ip);
    800055e8:	8526                	mv	a0,s1
    800055ea:	ffffe097          	auipc	ra,0xffffe
    800055ee:	308080e7          	jalr	776(ra) # 800038f2 <iunlockput>
  end_op();
    800055f2:	fffff097          	auipc	ra,0xfffff
    800055f6:	af8080e7          	jalr	-1288(ra) # 800040ea <end_op>
  return 0;
    800055fa:	4501                	li	a0,0
    800055fc:	a07d                	j	800056aa <sys_unlink+0x1c0>
    end_op();
    800055fe:	fffff097          	auipc	ra,0xfffff
    80005602:	aec080e7          	jalr	-1300(ra) # 800040ea <end_op>
    return -1;
    80005606:	557d                	li	a0,-1
    80005608:	a04d                	j	800056aa <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    8000560a:	00003517          	auipc	a0,0x3
    8000560e:	10650513          	addi	a0,a0,262 # 80008710 <syscalls+0x318>
    80005612:	ffffb097          	auipc	ra,0xffffb
    80005616:	f66080e7          	jalr	-154(ra) # 80000578 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000561a:	44f8                	lw	a4,76(s1)
    8000561c:	02000793          	li	a5,32
    80005620:	f6e7fae3          	bleu	a4,a5,80005594 <sys_unlink+0xaa>
    80005624:	02000913          	li	s2,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005628:	4741                	li	a4,16
    8000562a:	86ca                	mv	a3,s2
    8000562c:	f1840613          	addi	a2,s0,-232
    80005630:	4581                	li	a1,0
    80005632:	8526                	mv	a0,s1
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	310080e7          	jalr	784(ra) # 80003944 <readi>
    8000563c:	47c1                	li	a5,16
    8000563e:	00f51a63          	bne	a0,a5,80005652 <sys_unlink+0x168>
    if(de.inum != 0)
    80005642:	f1845783          	lhu	a5,-232(s0)
    80005646:	e3b9                	bnez	a5,8000568c <sys_unlink+0x1a2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005648:	2941                	addiw	s2,s2,16
    8000564a:	44fc                	lw	a5,76(s1)
    8000564c:	fcf96ee3          	bltu	s2,a5,80005628 <sys_unlink+0x13e>
    80005650:	b791                	j	80005594 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005652:	00003517          	auipc	a0,0x3
    80005656:	0d650513          	addi	a0,a0,214 # 80008728 <syscalls+0x330>
    8000565a:	ffffb097          	auipc	ra,0xffffb
    8000565e:	f1e080e7          	jalr	-226(ra) # 80000578 <panic>
    panic("unlink: writei");
    80005662:	00003517          	auipc	a0,0x3
    80005666:	0de50513          	addi	a0,a0,222 # 80008740 <syscalls+0x348>
    8000566a:	ffffb097          	auipc	ra,0xffffb
    8000566e:	f0e080e7          	jalr	-242(ra) # 80000578 <panic>
    dp->nlink--;
    80005672:	04a9d783          	lhu	a5,74(s3)
    80005676:	37fd                	addiw	a5,a5,-1
    80005678:	04f99523          	sh	a5,74(s3)
    iupdate(dp);
    8000567c:	854e                	mv	a0,s3
    8000567e:	ffffe097          	auipc	ra,0xffffe
    80005682:	f44080e7          	jalr	-188(ra) # 800035c2 <iupdate>
    80005686:	b791                	j	800055ca <sys_unlink+0xe0>
    return -1;
    80005688:	557d                	li	a0,-1
    8000568a:	a005                	j	800056aa <sys_unlink+0x1c0>
    iunlockput(ip);
    8000568c:	8526                	mv	a0,s1
    8000568e:	ffffe097          	auipc	ra,0xffffe
    80005692:	264080e7          	jalr	612(ra) # 800038f2 <iunlockput>
  iunlockput(dp);
    80005696:	854e                	mv	a0,s3
    80005698:	ffffe097          	auipc	ra,0xffffe
    8000569c:	25a080e7          	jalr	602(ra) # 800038f2 <iunlockput>
  end_op();
    800056a0:	fffff097          	auipc	ra,0xfffff
    800056a4:	a4a080e7          	jalr	-1462(ra) # 800040ea <end_op>
  return -1;
    800056a8:	557d                	li	a0,-1
}
    800056aa:	70ae                	ld	ra,232(sp)
    800056ac:	740e                	ld	s0,224(sp)
    800056ae:	64ee                	ld	s1,216(sp)
    800056b0:	694e                	ld	s2,208(sp)
    800056b2:	69ae                	ld	s3,200(sp)
    800056b4:	616d                	addi	sp,sp,240
    800056b6:	8082                	ret

00000000800056b8 <sys_open>:

uint64
sys_open(void)
{
    800056b8:	7131                	addi	sp,sp,-192
    800056ba:	fd06                	sd	ra,184(sp)
    800056bc:	f922                	sd	s0,176(sp)
    800056be:	f526                	sd	s1,168(sp)
    800056c0:	f14a                	sd	s2,160(sp)
    800056c2:	ed4e                	sd	s3,152(sp)
    800056c4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800056c6:	08000613          	li	a2,128
    800056ca:	f5040593          	addi	a1,s0,-176
    800056ce:	4501                	li	a0,0
    800056d0:	ffffd097          	auipc	ra,0xffffd
    800056d4:	442080e7          	jalr	1090(ra) # 80002b12 <argstr>
    return -1;
    800056d8:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800056da:	0c054163          	bltz	a0,8000579c <sys_open+0xe4>
    800056de:	f4c40593          	addi	a1,s0,-180
    800056e2:	4505                	li	a0,1
    800056e4:	ffffd097          	auipc	ra,0xffffd
    800056e8:	3ea080e7          	jalr	1002(ra) # 80002ace <argint>
    800056ec:	0a054863          	bltz	a0,8000579c <sys_open+0xe4>

  begin_op();
    800056f0:	fffff097          	auipc	ra,0xfffff
    800056f4:	97a080e7          	jalr	-1670(ra) # 8000406a <begin_op>

  if(omode & O_CREATE){
    800056f8:	f4c42783          	lw	a5,-180(s0)
    800056fc:	2007f793          	andi	a5,a5,512
    80005700:	cbdd                	beqz	a5,800057b6 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005702:	4681                	li	a3,0
    80005704:	4601                	li	a2,0
    80005706:	4589                	li	a1,2
    80005708:	f5040513          	addi	a0,s0,-176
    8000570c:	00000097          	auipc	ra,0x0
    80005710:	976080e7          	jalr	-1674(ra) # 80005082 <create>
    80005714:	892a                	mv	s2,a0
    if(ip == 0){
    80005716:	c959                	beqz	a0,800057ac <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005718:	04491703          	lh	a4,68(s2)
    8000571c:	478d                	li	a5,3
    8000571e:	00f71763          	bne	a4,a5,8000572c <sys_open+0x74>
    80005722:	04695703          	lhu	a4,70(s2)
    80005726:	47a5                	li	a5,9
    80005728:	0ce7ec63          	bltu	a5,a4,80005800 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000572c:	fffff097          	auipc	ra,0xfffff
    80005730:	d72080e7          	jalr	-654(ra) # 8000449e <filealloc>
    80005734:	89aa                	mv	s3,a0
    80005736:	10050263          	beqz	a0,8000583a <sys_open+0x182>
    8000573a:	00000097          	auipc	ra,0x0
    8000573e:	900080e7          	jalr	-1792(ra) # 8000503a <fdalloc>
    80005742:	84aa                	mv	s1,a0
    80005744:	0e054663          	bltz	a0,80005830 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005748:	04491703          	lh	a4,68(s2)
    8000574c:	478d                	li	a5,3
    8000574e:	0cf70463          	beq	a4,a5,80005816 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005752:	4789                	li	a5,2
    80005754:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005758:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000575c:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005760:	f4c42783          	lw	a5,-180(s0)
    80005764:	0017c713          	xori	a4,a5,1
    80005768:	8b05                	andi	a4,a4,1
    8000576a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000576e:	0037f713          	andi	a4,a5,3
    80005772:	00e03733          	snez	a4,a4
    80005776:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000577a:	4007f793          	andi	a5,a5,1024
    8000577e:	c791                	beqz	a5,8000578a <sys_open+0xd2>
    80005780:	04491703          	lh	a4,68(s2)
    80005784:	4789                	li	a5,2
    80005786:	08f70f63          	beq	a4,a5,80005824 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000578a:	854a                	mv	a0,s2
    8000578c:	ffffe097          	auipc	ra,0xffffe
    80005790:	fc6080e7          	jalr	-58(ra) # 80003752 <iunlock>
  end_op();
    80005794:	fffff097          	auipc	ra,0xfffff
    80005798:	956080e7          	jalr	-1706(ra) # 800040ea <end_op>

  return fd;
}
    8000579c:	8526                	mv	a0,s1
    8000579e:	70ea                	ld	ra,184(sp)
    800057a0:	744a                	ld	s0,176(sp)
    800057a2:	74aa                	ld	s1,168(sp)
    800057a4:	790a                	ld	s2,160(sp)
    800057a6:	69ea                	ld	s3,152(sp)
    800057a8:	6129                	addi	sp,sp,192
    800057aa:	8082                	ret
      end_op();
    800057ac:	fffff097          	auipc	ra,0xfffff
    800057b0:	93e080e7          	jalr	-1730(ra) # 800040ea <end_op>
      return -1;
    800057b4:	b7e5                	j	8000579c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800057b6:	f5040513          	addi	a0,s0,-176
    800057ba:	ffffe097          	auipc	ra,0xffffe
    800057be:	692080e7          	jalr	1682(ra) # 80003e4c <namei>
    800057c2:	892a                	mv	s2,a0
    800057c4:	c905                	beqz	a0,800057f4 <sys_open+0x13c>
    ilock(ip);
    800057c6:	ffffe097          	auipc	ra,0xffffe
    800057ca:	ec8080e7          	jalr	-312(ra) # 8000368e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800057ce:	04491703          	lh	a4,68(s2)
    800057d2:	4785                	li	a5,1
    800057d4:	f4f712e3          	bne	a4,a5,80005718 <sys_open+0x60>
    800057d8:	f4c42783          	lw	a5,-180(s0)
    800057dc:	dba1                	beqz	a5,8000572c <sys_open+0x74>
      iunlockput(ip);
    800057de:	854a                	mv	a0,s2
    800057e0:	ffffe097          	auipc	ra,0xffffe
    800057e4:	112080e7          	jalr	274(ra) # 800038f2 <iunlockput>
      end_op();
    800057e8:	fffff097          	auipc	ra,0xfffff
    800057ec:	902080e7          	jalr	-1790(ra) # 800040ea <end_op>
      return -1;
    800057f0:	54fd                	li	s1,-1
    800057f2:	b76d                	j	8000579c <sys_open+0xe4>
      end_op();
    800057f4:	fffff097          	auipc	ra,0xfffff
    800057f8:	8f6080e7          	jalr	-1802(ra) # 800040ea <end_op>
      return -1;
    800057fc:	54fd                	li	s1,-1
    800057fe:	bf79                	j	8000579c <sys_open+0xe4>
    iunlockput(ip);
    80005800:	854a                	mv	a0,s2
    80005802:	ffffe097          	auipc	ra,0xffffe
    80005806:	0f0080e7          	jalr	240(ra) # 800038f2 <iunlockput>
    end_op();
    8000580a:	fffff097          	auipc	ra,0xfffff
    8000580e:	8e0080e7          	jalr	-1824(ra) # 800040ea <end_op>
    return -1;
    80005812:	54fd                	li	s1,-1
    80005814:	b761                	j	8000579c <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005816:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000581a:	04691783          	lh	a5,70(s2)
    8000581e:	02f99223          	sh	a5,36(s3)
    80005822:	bf2d                	j	8000575c <sys_open+0xa4>
    itrunc(ip);
    80005824:	854a                	mv	a0,s2
    80005826:	ffffe097          	auipc	ra,0xffffe
    8000582a:	f78080e7          	jalr	-136(ra) # 8000379e <itrunc>
    8000582e:	bfb1                	j	8000578a <sys_open+0xd2>
      fileclose(f);
    80005830:	854e                	mv	a0,s3
    80005832:	fffff097          	auipc	ra,0xfffff
    80005836:	d3c080e7          	jalr	-708(ra) # 8000456e <fileclose>
    iunlockput(ip);
    8000583a:	854a                	mv	a0,s2
    8000583c:	ffffe097          	auipc	ra,0xffffe
    80005840:	0b6080e7          	jalr	182(ra) # 800038f2 <iunlockput>
    end_op();
    80005844:	fffff097          	auipc	ra,0xfffff
    80005848:	8a6080e7          	jalr	-1882(ra) # 800040ea <end_op>
    return -1;
    8000584c:	54fd                	li	s1,-1
    8000584e:	b7b9                	j	8000579c <sys_open+0xe4>

0000000080005850 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005850:	7175                	addi	sp,sp,-144
    80005852:	e506                	sd	ra,136(sp)
    80005854:	e122                	sd	s0,128(sp)
    80005856:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005858:	fffff097          	auipc	ra,0xfffff
    8000585c:	812080e7          	jalr	-2030(ra) # 8000406a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005860:	08000613          	li	a2,128
    80005864:	f7040593          	addi	a1,s0,-144
    80005868:	4501                	li	a0,0
    8000586a:	ffffd097          	auipc	ra,0xffffd
    8000586e:	2a8080e7          	jalr	680(ra) # 80002b12 <argstr>
    80005872:	02054963          	bltz	a0,800058a4 <sys_mkdir+0x54>
    80005876:	4681                	li	a3,0
    80005878:	4601                	li	a2,0
    8000587a:	4585                	li	a1,1
    8000587c:	f7040513          	addi	a0,s0,-144
    80005880:	00000097          	auipc	ra,0x0
    80005884:	802080e7          	jalr	-2046(ra) # 80005082 <create>
    80005888:	cd11                	beqz	a0,800058a4 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000588a:	ffffe097          	auipc	ra,0xffffe
    8000588e:	068080e7          	jalr	104(ra) # 800038f2 <iunlockput>
  end_op();
    80005892:	fffff097          	auipc	ra,0xfffff
    80005896:	858080e7          	jalr	-1960(ra) # 800040ea <end_op>
  return 0;
    8000589a:	4501                	li	a0,0
}
    8000589c:	60aa                	ld	ra,136(sp)
    8000589e:	640a                	ld	s0,128(sp)
    800058a0:	6149                	addi	sp,sp,144
    800058a2:	8082                	ret
    end_op();
    800058a4:	fffff097          	auipc	ra,0xfffff
    800058a8:	846080e7          	jalr	-1978(ra) # 800040ea <end_op>
    return -1;
    800058ac:	557d                	li	a0,-1
    800058ae:	b7fd                	j	8000589c <sys_mkdir+0x4c>

00000000800058b0 <sys_mknod>:

uint64
sys_mknod(void)
{
    800058b0:	7135                	addi	sp,sp,-160
    800058b2:	ed06                	sd	ra,152(sp)
    800058b4:	e922                	sd	s0,144(sp)
    800058b6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	7b2080e7          	jalr	1970(ra) # 8000406a <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058c0:	08000613          	li	a2,128
    800058c4:	f7040593          	addi	a1,s0,-144
    800058c8:	4501                	li	a0,0
    800058ca:	ffffd097          	auipc	ra,0xffffd
    800058ce:	248080e7          	jalr	584(ra) # 80002b12 <argstr>
    800058d2:	04054a63          	bltz	a0,80005926 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800058d6:	f6c40593          	addi	a1,s0,-148
    800058da:	4505                	li	a0,1
    800058dc:	ffffd097          	auipc	ra,0xffffd
    800058e0:	1f2080e7          	jalr	498(ra) # 80002ace <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058e4:	04054163          	bltz	a0,80005926 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800058e8:	f6840593          	addi	a1,s0,-152
    800058ec:	4509                	li	a0,2
    800058ee:	ffffd097          	auipc	ra,0xffffd
    800058f2:	1e0080e7          	jalr	480(ra) # 80002ace <argint>
     argint(1, &major) < 0 ||
    800058f6:	02054863          	bltz	a0,80005926 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800058fa:	f6841683          	lh	a3,-152(s0)
    800058fe:	f6c41603          	lh	a2,-148(s0)
    80005902:	458d                	li	a1,3
    80005904:	f7040513          	addi	a0,s0,-144
    80005908:	fffff097          	auipc	ra,0xfffff
    8000590c:	77a080e7          	jalr	1914(ra) # 80005082 <create>
     argint(2, &minor) < 0 ||
    80005910:	c919                	beqz	a0,80005926 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005912:	ffffe097          	auipc	ra,0xffffe
    80005916:	fe0080e7          	jalr	-32(ra) # 800038f2 <iunlockput>
  end_op();
    8000591a:	ffffe097          	auipc	ra,0xffffe
    8000591e:	7d0080e7          	jalr	2000(ra) # 800040ea <end_op>
  return 0;
    80005922:	4501                	li	a0,0
    80005924:	a031                	j	80005930 <sys_mknod+0x80>
    end_op();
    80005926:	ffffe097          	auipc	ra,0xffffe
    8000592a:	7c4080e7          	jalr	1988(ra) # 800040ea <end_op>
    return -1;
    8000592e:	557d                	li	a0,-1
}
    80005930:	60ea                	ld	ra,152(sp)
    80005932:	644a                	ld	s0,144(sp)
    80005934:	610d                	addi	sp,sp,160
    80005936:	8082                	ret

0000000080005938 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005938:	7135                	addi	sp,sp,-160
    8000593a:	ed06                	sd	ra,152(sp)
    8000593c:	e922                	sd	s0,144(sp)
    8000593e:	e526                	sd	s1,136(sp)
    80005940:	e14a                	sd	s2,128(sp)
    80005942:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005944:	ffffc097          	auipc	ra,0xffffc
    80005948:	0ba080e7          	jalr	186(ra) # 800019fe <myproc>
    8000594c:	892a                	mv	s2,a0
  
  begin_op();
    8000594e:	ffffe097          	auipc	ra,0xffffe
    80005952:	71c080e7          	jalr	1820(ra) # 8000406a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005956:	08000613          	li	a2,128
    8000595a:	f6040593          	addi	a1,s0,-160
    8000595e:	4501                	li	a0,0
    80005960:	ffffd097          	auipc	ra,0xffffd
    80005964:	1b2080e7          	jalr	434(ra) # 80002b12 <argstr>
    80005968:	04054b63          	bltz	a0,800059be <sys_chdir+0x86>
    8000596c:	f6040513          	addi	a0,s0,-160
    80005970:	ffffe097          	auipc	ra,0xffffe
    80005974:	4dc080e7          	jalr	1244(ra) # 80003e4c <namei>
    80005978:	84aa                	mv	s1,a0
    8000597a:	c131                	beqz	a0,800059be <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000597c:	ffffe097          	auipc	ra,0xffffe
    80005980:	d12080e7          	jalr	-750(ra) # 8000368e <ilock>
  if(ip->type != T_DIR){
    80005984:	04449703          	lh	a4,68(s1)
    80005988:	4785                	li	a5,1
    8000598a:	04f71063          	bne	a4,a5,800059ca <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000598e:	8526                	mv	a0,s1
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	dc2080e7          	jalr	-574(ra) # 80003752 <iunlock>
  iput(p->cwd);
    80005998:	15093503          	ld	a0,336(s2)
    8000599c:	ffffe097          	auipc	ra,0xffffe
    800059a0:	eae080e7          	jalr	-338(ra) # 8000384a <iput>
  end_op();
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	746080e7          	jalr	1862(ra) # 800040ea <end_op>
  p->cwd = ip;
    800059ac:	14993823          	sd	s1,336(s2)
  return 0;
    800059b0:	4501                	li	a0,0
}
    800059b2:	60ea                	ld	ra,152(sp)
    800059b4:	644a                	ld	s0,144(sp)
    800059b6:	64aa                	ld	s1,136(sp)
    800059b8:	690a                	ld	s2,128(sp)
    800059ba:	610d                	addi	sp,sp,160
    800059bc:	8082                	ret
    end_op();
    800059be:	ffffe097          	auipc	ra,0xffffe
    800059c2:	72c080e7          	jalr	1836(ra) # 800040ea <end_op>
    return -1;
    800059c6:	557d                	li	a0,-1
    800059c8:	b7ed                	j	800059b2 <sys_chdir+0x7a>
    iunlockput(ip);
    800059ca:	8526                	mv	a0,s1
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	f26080e7          	jalr	-218(ra) # 800038f2 <iunlockput>
    end_op();
    800059d4:	ffffe097          	auipc	ra,0xffffe
    800059d8:	716080e7          	jalr	1814(ra) # 800040ea <end_op>
    return -1;
    800059dc:	557d                	li	a0,-1
    800059de:	bfd1                	j	800059b2 <sys_chdir+0x7a>

00000000800059e0 <sys_exec>:

uint64
sys_exec(void)
{
    800059e0:	7145                	addi	sp,sp,-464
    800059e2:	e786                	sd	ra,456(sp)
    800059e4:	e3a2                	sd	s0,448(sp)
    800059e6:	ff26                	sd	s1,440(sp)
    800059e8:	fb4a                	sd	s2,432(sp)
    800059ea:	f74e                	sd	s3,424(sp)
    800059ec:	f352                	sd	s4,416(sp)
    800059ee:	ef56                	sd	s5,408(sp)
    800059f0:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800059f2:	08000613          	li	a2,128
    800059f6:	f4040593          	addi	a1,s0,-192
    800059fa:	4501                	li	a0,0
    800059fc:	ffffd097          	auipc	ra,0xffffd
    80005a00:	116080e7          	jalr	278(ra) # 80002b12 <argstr>
    return -1;
    80005a04:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a06:	0e054c63          	bltz	a0,80005afe <sys_exec+0x11e>
    80005a0a:	e3840593          	addi	a1,s0,-456
    80005a0e:	4505                	li	a0,1
    80005a10:	ffffd097          	auipc	ra,0xffffd
    80005a14:	0e0080e7          	jalr	224(ra) # 80002af0 <argaddr>
    80005a18:	0e054363          	bltz	a0,80005afe <sys_exec+0x11e>
  }
  memset(argv, 0, sizeof(argv));
    80005a1c:	e4040913          	addi	s2,s0,-448
    80005a20:	10000613          	li	a2,256
    80005a24:	4581                	li	a1,0
    80005a26:	854a                	mv	a0,s2
    80005a28:	ffffb097          	auipc	ra,0xffffb
    80005a2c:	33a080e7          	jalr	826(ra) # 80000d62 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a30:	89ca                	mv	s3,s2
  memset(argv, 0, sizeof(argv));
    80005a32:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005a34:	02000a93          	li	s5,32
    80005a38:	00048a1b          	sext.w	s4,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a3c:	00349513          	slli	a0,s1,0x3
    80005a40:	e3040593          	addi	a1,s0,-464
    80005a44:	e3843783          	ld	a5,-456(s0)
    80005a48:	953e                	add	a0,a0,a5
    80005a4a:	ffffd097          	auipc	ra,0xffffd
    80005a4e:	fe8080e7          	jalr	-24(ra) # 80002a32 <fetchaddr>
    80005a52:	02054a63          	bltz	a0,80005a86 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005a56:	e3043783          	ld	a5,-464(s0)
    80005a5a:	cfa9                	beqz	a5,80005ab4 <sys_exec+0xd4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a5c:	ffffb097          	auipc	ra,0xffffb
    80005a60:	11a080e7          	jalr	282(ra) # 80000b76 <kalloc>
    80005a64:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80005a68:	cd19                	beqz	a0,80005a86 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a6a:	6605                	lui	a2,0x1
    80005a6c:	85aa                	mv	a1,a0
    80005a6e:	e3043503          	ld	a0,-464(s0)
    80005a72:	ffffd097          	auipc	ra,0xffffd
    80005a76:	014080e7          	jalr	20(ra) # 80002a86 <fetchstr>
    80005a7a:	00054663          	bltz	a0,80005a86 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005a7e:	0485                	addi	s1,s1,1
    80005a80:	0921                	addi	s2,s2,8
    80005a82:	fb549be3          	bne	s1,s5,80005a38 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a86:	e4043503          	ld	a0,-448(s0)
    kfree(argv[i]);
  return -1;
    80005a8a:	597d                	li	s2,-1
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a8c:	c92d                	beqz	a0,80005afe <sys_exec+0x11e>
    kfree(argv[i]);
    80005a8e:	ffffb097          	auipc	ra,0xffffb
    80005a92:	fe8080e7          	jalr	-24(ra) # 80000a76 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a96:	e4840493          	addi	s1,s0,-440
    80005a9a:	10098993          	addi	s3,s3,256
    80005a9e:	6088                	ld	a0,0(s1)
    80005aa0:	cd31                	beqz	a0,80005afc <sys_exec+0x11c>
    kfree(argv[i]);
    80005aa2:	ffffb097          	auipc	ra,0xffffb
    80005aa6:	fd4080e7          	jalr	-44(ra) # 80000a76 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005aaa:	04a1                	addi	s1,s1,8
    80005aac:	ff3499e3          	bne	s1,s3,80005a9e <sys_exec+0xbe>
  return -1;
    80005ab0:	597d                	li	s2,-1
    80005ab2:	a0b1                	j	80005afe <sys_exec+0x11e>
      argv[i] = 0;
    80005ab4:	0a0e                	slli	s4,s4,0x3
    80005ab6:	fc040793          	addi	a5,s0,-64
    80005aba:	9a3e                	add	s4,s4,a5
    80005abc:	e80a3023          	sd	zero,-384(s4)
  int ret = exec(path, argv);
    80005ac0:	e4040593          	addi	a1,s0,-448
    80005ac4:	f4040513          	addi	a0,s0,-192
    80005ac8:	fffff097          	auipc	ra,0xfffff
    80005acc:	166080e7          	jalr	358(ra) # 80004c2e <exec>
    80005ad0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ad2:	e4043503          	ld	a0,-448(s0)
    80005ad6:	c505                	beqz	a0,80005afe <sys_exec+0x11e>
    kfree(argv[i]);
    80005ad8:	ffffb097          	auipc	ra,0xffffb
    80005adc:	f9e080e7          	jalr	-98(ra) # 80000a76 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ae0:	e4840493          	addi	s1,s0,-440
    80005ae4:	10098993          	addi	s3,s3,256
    80005ae8:	6088                	ld	a0,0(s1)
    80005aea:	c911                	beqz	a0,80005afe <sys_exec+0x11e>
    kfree(argv[i]);
    80005aec:	ffffb097          	auipc	ra,0xffffb
    80005af0:	f8a080e7          	jalr	-118(ra) # 80000a76 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005af4:	04a1                	addi	s1,s1,8
    80005af6:	ff3499e3          	bne	s1,s3,80005ae8 <sys_exec+0x108>
    80005afa:	a011                	j	80005afe <sys_exec+0x11e>
  return -1;
    80005afc:	597d                	li	s2,-1
}
    80005afe:	854a                	mv	a0,s2
    80005b00:	60be                	ld	ra,456(sp)
    80005b02:	641e                	ld	s0,448(sp)
    80005b04:	74fa                	ld	s1,440(sp)
    80005b06:	795a                	ld	s2,432(sp)
    80005b08:	79ba                	ld	s3,424(sp)
    80005b0a:	7a1a                	ld	s4,416(sp)
    80005b0c:	6afa                	ld	s5,408(sp)
    80005b0e:	6179                	addi	sp,sp,464
    80005b10:	8082                	ret

0000000080005b12 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b12:	7139                	addi	sp,sp,-64
    80005b14:	fc06                	sd	ra,56(sp)
    80005b16:	f822                	sd	s0,48(sp)
    80005b18:	f426                	sd	s1,40(sp)
    80005b1a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b1c:	ffffc097          	auipc	ra,0xffffc
    80005b20:	ee2080e7          	jalr	-286(ra) # 800019fe <myproc>
    80005b24:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005b26:	fd840593          	addi	a1,s0,-40
    80005b2a:	4501                	li	a0,0
    80005b2c:	ffffd097          	auipc	ra,0xffffd
    80005b30:	fc4080e7          	jalr	-60(ra) # 80002af0 <argaddr>
    return -1;
    80005b34:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005b36:	0c054f63          	bltz	a0,80005c14 <sys_pipe+0x102>
  if(pipealloc(&rf, &wf) < 0)
    80005b3a:	fc840593          	addi	a1,s0,-56
    80005b3e:	fd040513          	addi	a0,s0,-48
    80005b42:	fffff097          	auipc	ra,0xfffff
    80005b46:	d74080e7          	jalr	-652(ra) # 800048b6 <pipealloc>
    return -1;
    80005b4a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b4c:	0c054463          	bltz	a0,80005c14 <sys_pipe+0x102>
  fd0 = -1;
    80005b50:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b54:	fd043503          	ld	a0,-48(s0)
    80005b58:	fffff097          	auipc	ra,0xfffff
    80005b5c:	4e2080e7          	jalr	1250(ra) # 8000503a <fdalloc>
    80005b60:	fca42223          	sw	a0,-60(s0)
    80005b64:	08054b63          	bltz	a0,80005bfa <sys_pipe+0xe8>
    80005b68:	fc843503          	ld	a0,-56(s0)
    80005b6c:	fffff097          	auipc	ra,0xfffff
    80005b70:	4ce080e7          	jalr	1230(ra) # 8000503a <fdalloc>
    80005b74:	fca42023          	sw	a0,-64(s0)
    80005b78:	06054863          	bltz	a0,80005be8 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b7c:	4691                	li	a3,4
    80005b7e:	fc440613          	addi	a2,s0,-60
    80005b82:	fd843583          	ld	a1,-40(s0)
    80005b86:	68a8                	ld	a0,80(s1)
    80005b88:	ffffc097          	auipc	ra,0xffffc
    80005b8c:	b52080e7          	jalr	-1198(ra) # 800016da <copyout>
    80005b90:	02054063          	bltz	a0,80005bb0 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b94:	4691                	li	a3,4
    80005b96:	fc040613          	addi	a2,s0,-64
    80005b9a:	fd843583          	ld	a1,-40(s0)
    80005b9e:	0591                	addi	a1,a1,4
    80005ba0:	68a8                	ld	a0,80(s1)
    80005ba2:	ffffc097          	auipc	ra,0xffffc
    80005ba6:	b38080e7          	jalr	-1224(ra) # 800016da <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005baa:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bac:	06055463          	bgez	a0,80005c14 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80005bb0:	fc442783          	lw	a5,-60(s0)
    80005bb4:	07e9                	addi	a5,a5,26
    80005bb6:	078e                	slli	a5,a5,0x3
    80005bb8:	97a6                	add	a5,a5,s1
    80005bba:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005bbe:	fc042783          	lw	a5,-64(s0)
    80005bc2:	07e9                	addi	a5,a5,26
    80005bc4:	078e                	slli	a5,a5,0x3
    80005bc6:	94be                	add	s1,s1,a5
    80005bc8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005bcc:	fd043503          	ld	a0,-48(s0)
    80005bd0:	fffff097          	auipc	ra,0xfffff
    80005bd4:	99e080e7          	jalr	-1634(ra) # 8000456e <fileclose>
    fileclose(wf);
    80005bd8:	fc843503          	ld	a0,-56(s0)
    80005bdc:	fffff097          	auipc	ra,0xfffff
    80005be0:	992080e7          	jalr	-1646(ra) # 8000456e <fileclose>
    return -1;
    80005be4:	57fd                	li	a5,-1
    80005be6:	a03d                	j	80005c14 <sys_pipe+0x102>
    if(fd0 >= 0)
    80005be8:	fc442783          	lw	a5,-60(s0)
    80005bec:	0007c763          	bltz	a5,80005bfa <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005bf0:	07e9                	addi	a5,a5,26
    80005bf2:	078e                	slli	a5,a5,0x3
    80005bf4:	94be                	add	s1,s1,a5
    80005bf6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005bfa:	fd043503          	ld	a0,-48(s0)
    80005bfe:	fffff097          	auipc	ra,0xfffff
    80005c02:	970080e7          	jalr	-1680(ra) # 8000456e <fileclose>
    fileclose(wf);
    80005c06:	fc843503          	ld	a0,-56(s0)
    80005c0a:	fffff097          	auipc	ra,0xfffff
    80005c0e:	964080e7          	jalr	-1692(ra) # 8000456e <fileclose>
    return -1;
    80005c12:	57fd                	li	a5,-1
}
    80005c14:	853e                	mv	a0,a5
    80005c16:	70e2                	ld	ra,56(sp)
    80005c18:	7442                	ld	s0,48(sp)
    80005c1a:	74a2                	ld	s1,40(sp)
    80005c1c:	6121                	addi	sp,sp,64
    80005c1e:	8082                	ret

0000000080005c20 <kernelvec>:
    80005c20:	7111                	addi	sp,sp,-256
    80005c22:	e006                	sd	ra,0(sp)
    80005c24:	e40a                	sd	sp,8(sp)
    80005c26:	e80e                	sd	gp,16(sp)
    80005c28:	ec12                	sd	tp,24(sp)
    80005c2a:	f016                	sd	t0,32(sp)
    80005c2c:	f41a                	sd	t1,40(sp)
    80005c2e:	f81e                	sd	t2,48(sp)
    80005c30:	fc22                	sd	s0,56(sp)
    80005c32:	e0a6                	sd	s1,64(sp)
    80005c34:	e4aa                	sd	a0,72(sp)
    80005c36:	e8ae                	sd	a1,80(sp)
    80005c38:	ecb2                	sd	a2,88(sp)
    80005c3a:	f0b6                	sd	a3,96(sp)
    80005c3c:	f4ba                	sd	a4,104(sp)
    80005c3e:	f8be                	sd	a5,112(sp)
    80005c40:	fcc2                	sd	a6,120(sp)
    80005c42:	e146                	sd	a7,128(sp)
    80005c44:	e54a                	sd	s2,136(sp)
    80005c46:	e94e                	sd	s3,144(sp)
    80005c48:	ed52                	sd	s4,152(sp)
    80005c4a:	f156                	sd	s5,160(sp)
    80005c4c:	f55a                	sd	s6,168(sp)
    80005c4e:	f95e                	sd	s7,176(sp)
    80005c50:	fd62                	sd	s8,184(sp)
    80005c52:	e1e6                	sd	s9,192(sp)
    80005c54:	e5ea                	sd	s10,200(sp)
    80005c56:	e9ee                	sd	s11,208(sp)
    80005c58:	edf2                	sd	t3,216(sp)
    80005c5a:	f1f6                	sd	t4,224(sp)
    80005c5c:	f5fa                	sd	t5,232(sp)
    80005c5e:	f9fe                	sd	t6,240(sp)
    80005c60:	c9bfc0ef          	jal	ra,800028fa <kerneltrap>
    80005c64:	6082                	ld	ra,0(sp)
    80005c66:	6122                	ld	sp,8(sp)
    80005c68:	61c2                	ld	gp,16(sp)
    80005c6a:	7282                	ld	t0,32(sp)
    80005c6c:	7322                	ld	t1,40(sp)
    80005c6e:	73c2                	ld	t2,48(sp)
    80005c70:	7462                	ld	s0,56(sp)
    80005c72:	6486                	ld	s1,64(sp)
    80005c74:	6526                	ld	a0,72(sp)
    80005c76:	65c6                	ld	a1,80(sp)
    80005c78:	6666                	ld	a2,88(sp)
    80005c7a:	7686                	ld	a3,96(sp)
    80005c7c:	7726                	ld	a4,104(sp)
    80005c7e:	77c6                	ld	a5,112(sp)
    80005c80:	7866                	ld	a6,120(sp)
    80005c82:	688a                	ld	a7,128(sp)
    80005c84:	692a                	ld	s2,136(sp)
    80005c86:	69ca                	ld	s3,144(sp)
    80005c88:	6a6a                	ld	s4,152(sp)
    80005c8a:	7a8a                	ld	s5,160(sp)
    80005c8c:	7b2a                	ld	s6,168(sp)
    80005c8e:	7bca                	ld	s7,176(sp)
    80005c90:	7c6a                	ld	s8,184(sp)
    80005c92:	6c8e                	ld	s9,192(sp)
    80005c94:	6d2e                	ld	s10,200(sp)
    80005c96:	6dce                	ld	s11,208(sp)
    80005c98:	6e6e                	ld	t3,216(sp)
    80005c9a:	7e8e                	ld	t4,224(sp)
    80005c9c:	7f2e                	ld	t5,232(sp)
    80005c9e:	7fce                	ld	t6,240(sp)
    80005ca0:	6111                	addi	sp,sp,256
    80005ca2:	10200073          	sret
    80005ca6:	00000013          	nop
    80005caa:	00000013          	nop
    80005cae:	0001                	nop

0000000080005cb0 <timervec>:
    80005cb0:	34051573          	csrrw	a0,mscratch,a0
    80005cb4:	e10c                	sd	a1,0(a0)
    80005cb6:	e510                	sd	a2,8(a0)
    80005cb8:	e914                	sd	a3,16(a0)
    80005cba:	6d0c                	ld	a1,24(a0)
    80005cbc:	7110                	ld	a2,32(a0)
    80005cbe:	6194                	ld	a3,0(a1)
    80005cc0:	96b2                	add	a3,a3,a2
    80005cc2:	e194                	sd	a3,0(a1)
    80005cc4:	4589                	li	a1,2
    80005cc6:	14459073          	csrw	sip,a1
    80005cca:	6914                	ld	a3,16(a0)
    80005ccc:	6510                	ld	a2,8(a0)
    80005cce:	610c                	ld	a1,0(a0)
    80005cd0:	34051573          	csrrw	a0,mscratch,a0
    80005cd4:	30200073          	mret
	...

0000000080005cda <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005cda:	1141                	addi	sp,sp,-16
    80005cdc:	e422                	sd	s0,8(sp)
    80005cde:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ce0:	0c0007b7          	lui	a5,0xc000
    80005ce4:	4705                	li	a4,1
    80005ce6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ce8:	c3d8                	sw	a4,4(a5)
}
    80005cea:	6422                	ld	s0,8(sp)
    80005cec:	0141                	addi	sp,sp,16
    80005cee:	8082                	ret

0000000080005cf0 <plicinithart>:

void
plicinithart(void)
{
    80005cf0:	1141                	addi	sp,sp,-16
    80005cf2:	e406                	sd	ra,8(sp)
    80005cf4:	e022                	sd	s0,0(sp)
    80005cf6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005cf8:	ffffc097          	auipc	ra,0xffffc
    80005cfc:	cda080e7          	jalr	-806(ra) # 800019d2 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d00:	0085171b          	slliw	a4,a0,0x8
    80005d04:	0c0027b7          	lui	a5,0xc002
    80005d08:	97ba                	add	a5,a5,a4
    80005d0a:	40200713          	li	a4,1026
    80005d0e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d12:	00d5151b          	slliw	a0,a0,0xd
    80005d16:	0c2017b7          	lui	a5,0xc201
    80005d1a:	953e                	add	a0,a0,a5
    80005d1c:	00052023          	sw	zero,0(a0)
}
    80005d20:	60a2                	ld	ra,8(sp)
    80005d22:	6402                	ld	s0,0(sp)
    80005d24:	0141                	addi	sp,sp,16
    80005d26:	8082                	ret

0000000080005d28 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d28:	1141                	addi	sp,sp,-16
    80005d2a:	e406                	sd	ra,8(sp)
    80005d2c:	e022                	sd	s0,0(sp)
    80005d2e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d30:	ffffc097          	auipc	ra,0xffffc
    80005d34:	ca2080e7          	jalr	-862(ra) # 800019d2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d38:	00d5151b          	slliw	a0,a0,0xd
    80005d3c:	0c2017b7          	lui	a5,0xc201
    80005d40:	97aa                	add	a5,a5,a0
  return irq;
}
    80005d42:	43c8                	lw	a0,4(a5)
    80005d44:	60a2                	ld	ra,8(sp)
    80005d46:	6402                	ld	s0,0(sp)
    80005d48:	0141                	addi	sp,sp,16
    80005d4a:	8082                	ret

0000000080005d4c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d4c:	1101                	addi	sp,sp,-32
    80005d4e:	ec06                	sd	ra,24(sp)
    80005d50:	e822                	sd	s0,16(sp)
    80005d52:	e426                	sd	s1,8(sp)
    80005d54:	1000                	addi	s0,sp,32
    80005d56:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d58:	ffffc097          	auipc	ra,0xffffc
    80005d5c:	c7a080e7          	jalr	-902(ra) # 800019d2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d60:	00d5151b          	slliw	a0,a0,0xd
    80005d64:	0c2017b7          	lui	a5,0xc201
    80005d68:	97aa                	add	a5,a5,a0
    80005d6a:	c3c4                	sw	s1,4(a5)
}
    80005d6c:	60e2                	ld	ra,24(sp)
    80005d6e:	6442                	ld	s0,16(sp)
    80005d70:	64a2                	ld	s1,8(sp)
    80005d72:	6105                	addi	sp,sp,32
    80005d74:	8082                	ret

0000000080005d76 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d76:	1141                	addi	sp,sp,-16
    80005d78:	e406                	sd	ra,8(sp)
    80005d7a:	e022                	sd	s0,0(sp)
    80005d7c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d7e:	479d                	li	a5,7
    80005d80:	06a7c963          	blt	a5,a0,80005df2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80005d84:	0001d797          	auipc	a5,0x1d
    80005d88:	27c78793          	addi	a5,a5,636 # 80023000 <disk>
    80005d8c:	00a78733          	add	a4,a5,a0
    80005d90:	6789                	lui	a5,0x2
    80005d92:	97ba                	add	a5,a5,a4
    80005d94:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005d98:	e7ad                	bnez	a5,80005e02 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d9a:	00451793          	slli	a5,a0,0x4
    80005d9e:	0001f717          	auipc	a4,0x1f
    80005da2:	26270713          	addi	a4,a4,610 # 80025000 <disk+0x2000>
    80005da6:	6314                	ld	a3,0(a4)
    80005da8:	96be                	add	a3,a3,a5
    80005daa:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005dae:	6314                	ld	a3,0(a4)
    80005db0:	96be                	add	a3,a3,a5
    80005db2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005db6:	6314                	ld	a3,0(a4)
    80005db8:	96be                	add	a3,a3,a5
    80005dba:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005dbe:	6318                	ld	a4,0(a4)
    80005dc0:	97ba                	add	a5,a5,a4
    80005dc2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005dc6:	0001d797          	auipc	a5,0x1d
    80005dca:	23a78793          	addi	a5,a5,570 # 80023000 <disk>
    80005dce:	97aa                	add	a5,a5,a0
    80005dd0:	6509                	lui	a0,0x2
    80005dd2:	953e                	add	a0,a0,a5
    80005dd4:	4785                	li	a5,1
    80005dd6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005dda:	0001f517          	auipc	a0,0x1f
    80005dde:	23e50513          	addi	a0,a0,574 # 80025018 <disk+0x2018>
    80005de2:	ffffc097          	auipc	ra,0xffffc
    80005de6:	5bc080e7          	jalr	1468(ra) # 8000239e <wakeup>
}
    80005dea:	60a2                	ld	ra,8(sp)
    80005dec:	6402                	ld	s0,0(sp)
    80005dee:	0141                	addi	sp,sp,16
    80005df0:	8082                	ret
    panic("free_desc 1");
    80005df2:	00003517          	auipc	a0,0x3
    80005df6:	95e50513          	addi	a0,a0,-1698 # 80008750 <syscalls+0x358>
    80005dfa:	ffffa097          	auipc	ra,0xffffa
    80005dfe:	77e080e7          	jalr	1918(ra) # 80000578 <panic>
    panic("free_desc 2");
    80005e02:	00003517          	auipc	a0,0x3
    80005e06:	95e50513          	addi	a0,a0,-1698 # 80008760 <syscalls+0x368>
    80005e0a:	ffffa097          	auipc	ra,0xffffa
    80005e0e:	76e080e7          	jalr	1902(ra) # 80000578 <panic>

0000000080005e12 <virtio_disk_init>:
{
    80005e12:	1101                	addi	sp,sp,-32
    80005e14:	ec06                	sd	ra,24(sp)
    80005e16:	e822                	sd	s0,16(sp)
    80005e18:	e426                	sd	s1,8(sp)
    80005e1a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e1c:	00003597          	auipc	a1,0x3
    80005e20:	95458593          	addi	a1,a1,-1708 # 80008770 <syscalls+0x378>
    80005e24:	0001f517          	auipc	a0,0x1f
    80005e28:	30450513          	addi	a0,a0,772 # 80025128 <disk+0x2128>
    80005e2c:	ffffb097          	auipc	ra,0xffffb
    80005e30:	daa080e7          	jalr	-598(ra) # 80000bd6 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e34:	100017b7          	lui	a5,0x10001
    80005e38:	4398                	lw	a4,0(a5)
    80005e3a:	2701                	sext.w	a4,a4
    80005e3c:	747277b7          	lui	a5,0x74727
    80005e40:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e44:	0ef71163          	bne	a4,a5,80005f26 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e48:	100017b7          	lui	a5,0x10001
    80005e4c:	43dc                	lw	a5,4(a5)
    80005e4e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e50:	4705                	li	a4,1
    80005e52:	0ce79a63          	bne	a5,a4,80005f26 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e56:	100017b7          	lui	a5,0x10001
    80005e5a:	479c                	lw	a5,8(a5)
    80005e5c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e5e:	4709                	li	a4,2
    80005e60:	0ce79363          	bne	a5,a4,80005f26 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e64:	100017b7          	lui	a5,0x10001
    80005e68:	47d8                	lw	a4,12(a5)
    80005e6a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e6c:	554d47b7          	lui	a5,0x554d4
    80005e70:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e74:	0af71963          	bne	a4,a5,80005f26 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e78:	100017b7          	lui	a5,0x10001
    80005e7c:	4705                	li	a4,1
    80005e7e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e80:	470d                	li	a4,3
    80005e82:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e84:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005e86:	c7ffe737          	lui	a4,0xc7ffe
    80005e8a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005e8e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e90:	2701                	sext.w	a4,a4
    80005e92:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e94:	472d                	li	a4,11
    80005e96:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e98:	473d                	li	a4,15
    80005e9a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005e9c:	6705                	lui	a4,0x1
    80005e9e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ea0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005ea4:	5bdc                	lw	a5,52(a5)
    80005ea6:	2781                	sext.w	a5,a5
  if(max == 0)
    80005ea8:	c7d9                	beqz	a5,80005f36 <virtio_disk_init+0x124>
  if(max < NUM)
    80005eaa:	471d                	li	a4,7
    80005eac:	08f77d63          	bleu	a5,a4,80005f46 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005eb0:	100014b7          	lui	s1,0x10001
    80005eb4:	47a1                	li	a5,8
    80005eb6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005eb8:	6609                	lui	a2,0x2
    80005eba:	4581                	li	a1,0
    80005ebc:	0001d517          	auipc	a0,0x1d
    80005ec0:	14450513          	addi	a0,a0,324 # 80023000 <disk>
    80005ec4:	ffffb097          	auipc	ra,0xffffb
    80005ec8:	e9e080e7          	jalr	-354(ra) # 80000d62 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005ecc:	0001d717          	auipc	a4,0x1d
    80005ed0:	13470713          	addi	a4,a4,308 # 80023000 <disk>
    80005ed4:	00c75793          	srli	a5,a4,0xc
    80005ed8:	2781                	sext.w	a5,a5
    80005eda:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005edc:	0001f797          	auipc	a5,0x1f
    80005ee0:	12478793          	addi	a5,a5,292 # 80025000 <disk+0x2000>
    80005ee4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005ee6:	0001d717          	auipc	a4,0x1d
    80005eea:	19a70713          	addi	a4,a4,410 # 80023080 <disk+0x80>
    80005eee:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005ef0:	0001e717          	auipc	a4,0x1e
    80005ef4:	11070713          	addi	a4,a4,272 # 80024000 <disk+0x1000>
    80005ef8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005efa:	4705                	li	a4,1
    80005efc:	00e78c23          	sb	a4,24(a5)
    80005f00:	00e78ca3          	sb	a4,25(a5)
    80005f04:	00e78d23          	sb	a4,26(a5)
    80005f08:	00e78da3          	sb	a4,27(a5)
    80005f0c:	00e78e23          	sb	a4,28(a5)
    80005f10:	00e78ea3          	sb	a4,29(a5)
    80005f14:	00e78f23          	sb	a4,30(a5)
    80005f18:	00e78fa3          	sb	a4,31(a5)
}
    80005f1c:	60e2                	ld	ra,24(sp)
    80005f1e:	6442                	ld	s0,16(sp)
    80005f20:	64a2                	ld	s1,8(sp)
    80005f22:	6105                	addi	sp,sp,32
    80005f24:	8082                	ret
    panic("could not find virtio disk");
    80005f26:	00003517          	auipc	a0,0x3
    80005f2a:	85a50513          	addi	a0,a0,-1958 # 80008780 <syscalls+0x388>
    80005f2e:	ffffa097          	auipc	ra,0xffffa
    80005f32:	64a080e7          	jalr	1610(ra) # 80000578 <panic>
    panic("virtio disk has no queue 0");
    80005f36:	00003517          	auipc	a0,0x3
    80005f3a:	86a50513          	addi	a0,a0,-1942 # 800087a0 <syscalls+0x3a8>
    80005f3e:	ffffa097          	auipc	ra,0xffffa
    80005f42:	63a080e7          	jalr	1594(ra) # 80000578 <panic>
    panic("virtio disk max queue too short");
    80005f46:	00003517          	auipc	a0,0x3
    80005f4a:	87a50513          	addi	a0,a0,-1926 # 800087c0 <syscalls+0x3c8>
    80005f4e:	ffffa097          	auipc	ra,0xffffa
    80005f52:	62a080e7          	jalr	1578(ra) # 80000578 <panic>

0000000080005f56 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f56:	711d                	addi	sp,sp,-96
    80005f58:	ec86                	sd	ra,88(sp)
    80005f5a:	e8a2                	sd	s0,80(sp)
    80005f5c:	e4a6                	sd	s1,72(sp)
    80005f5e:	e0ca                	sd	s2,64(sp)
    80005f60:	fc4e                	sd	s3,56(sp)
    80005f62:	f852                	sd	s4,48(sp)
    80005f64:	f456                	sd	s5,40(sp)
    80005f66:	f05a                	sd	s6,32(sp)
    80005f68:	ec5e                	sd	s7,24(sp)
    80005f6a:	e862                	sd	s8,16(sp)
    80005f6c:	1080                	addi	s0,sp,96
    80005f6e:	892a                	mv	s2,a0
    80005f70:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f72:	00c52b83          	lw	s7,12(a0)
    80005f76:	001b9b9b          	slliw	s7,s7,0x1
    80005f7a:	1b82                	slli	s7,s7,0x20
    80005f7c:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005f80:	0001f517          	auipc	a0,0x1f
    80005f84:	1a850513          	addi	a0,a0,424 # 80025128 <disk+0x2128>
    80005f88:	ffffb097          	auipc	ra,0xffffb
    80005f8c:	cde080e7          	jalr	-802(ra) # 80000c66 <acquire>
    if(disk.free[i]){
    80005f90:	0001f997          	auipc	s3,0x1f
    80005f94:	07098993          	addi	s3,s3,112 # 80025000 <disk+0x2000>
  for(int i = 0; i < NUM; i++){
    80005f98:	4b21                	li	s6,8
      disk.free[i] = 0;
    80005f9a:	0001da97          	auipc	s5,0x1d
    80005f9e:	066a8a93          	addi	s5,s5,102 # 80023000 <disk>
  for(int i = 0; i < 3; i++){
    80005fa2:	4a0d                	li	s4,3
    80005fa4:	a079                	j	80006032 <virtio_disk_rw+0xdc>
      disk.free[i] = 0;
    80005fa6:	00fa86b3          	add	a3,s5,a5
    80005faa:	96ae                	add	a3,a3,a1
    80005fac:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80005fb0:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80005fb2:	0207ca63          	bltz	a5,80005fe6 <virtio_disk_rw+0x90>
  for(int i = 0; i < 3; i++){
    80005fb6:	2485                	addiw	s1,s1,1
    80005fb8:	0711                	addi	a4,a4,4
    80005fba:	25448b63          	beq	s1,s4,80006210 <virtio_disk_rw+0x2ba>
    idx[i] = alloc_desc();
    80005fbe:	863a                	mv	a2,a4
    if(disk.free[i]){
    80005fc0:	0189c783          	lbu	a5,24(s3)
    80005fc4:	26079e63          	bnez	a5,80006240 <virtio_disk_rw+0x2ea>
    80005fc8:	0001f697          	auipc	a3,0x1f
    80005fcc:	05168693          	addi	a3,a3,81 # 80025019 <disk+0x2019>
  for(int i = 0; i < NUM; i++){
    80005fd0:	87aa                	mv	a5,a0
    if(disk.free[i]){
    80005fd2:	0006c803          	lbu	a6,0(a3)
    80005fd6:	fc0818e3          	bnez	a6,80005fa6 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005fda:	2785                	addiw	a5,a5,1
    80005fdc:	0685                	addi	a3,a3,1
    80005fde:	ff679ae3          	bne	a5,s6,80005fd2 <virtio_disk_rw+0x7c>
    idx[i] = alloc_desc();
    80005fe2:	57fd                	li	a5,-1
    80005fe4:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80005fe6:	02905a63          	blez	s1,8000601a <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    80005fea:	fa042503          	lw	a0,-96(s0)
    80005fee:	00000097          	auipc	ra,0x0
    80005ff2:	d88080e7          	jalr	-632(ra) # 80005d76 <free_desc>
      for(int j = 0; j < i; j++)
    80005ff6:	4785                	li	a5,1
    80005ff8:	0297d163          	ble	s1,a5,8000601a <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    80005ffc:	fa442503          	lw	a0,-92(s0)
    80006000:	00000097          	auipc	ra,0x0
    80006004:	d76080e7          	jalr	-650(ra) # 80005d76 <free_desc>
      for(int j = 0; j < i; j++)
    80006008:	4789                	li	a5,2
    8000600a:	0097d863          	ble	s1,a5,8000601a <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    8000600e:	fa842503          	lw	a0,-88(s0)
    80006012:	00000097          	auipc	ra,0x0
    80006016:	d64080e7          	jalr	-668(ra) # 80005d76 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000601a:	0001f597          	auipc	a1,0x1f
    8000601e:	10e58593          	addi	a1,a1,270 # 80025128 <disk+0x2128>
    80006022:	0001f517          	auipc	a0,0x1f
    80006026:	ff650513          	addi	a0,a0,-10 # 80025018 <disk+0x2018>
    8000602a:	ffffc097          	auipc	ra,0xffffc
    8000602e:	1ee080e7          	jalr	494(ra) # 80002218 <sleep>
  for(int i = 0; i < 3; i++){
    80006032:	fa040713          	addi	a4,s0,-96
    80006036:	4481                	li	s1,0
  for(int i = 0; i < NUM; i++){
    80006038:	4505                	li	a0,1
      disk.free[i] = 0;
    8000603a:	6589                	lui	a1,0x2
    8000603c:	b749                	j	80005fbe <virtio_disk_rw+0x68>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    8000603e:	20058793          	addi	a5,a1,512 # 2200 <_entry-0x7fffde00>
    80006042:	00479613          	slli	a2,a5,0x4
    80006046:	0001d797          	auipc	a5,0x1d
    8000604a:	fba78793          	addi	a5,a5,-70 # 80023000 <disk>
    8000604e:	97b2                	add	a5,a5,a2
    80006050:	4605                	li	a2,1
    80006052:	0ac7a423          	sw	a2,168(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006056:	20058793          	addi	a5,a1,512
    8000605a:	00479613          	slli	a2,a5,0x4
    8000605e:	0001d797          	auipc	a5,0x1d
    80006062:	fa278793          	addi	a5,a5,-94 # 80023000 <disk>
    80006066:	97b2                	add	a5,a5,a2
    80006068:	0a07a623          	sw	zero,172(a5)
  buf0->sector = sector;
    8000606c:	0b77b823          	sd	s7,176(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006070:	0001f797          	auipc	a5,0x1f
    80006074:	f9078793          	addi	a5,a5,-112 # 80025000 <disk+0x2000>
    80006078:	6390                	ld	a2,0(a5)
    8000607a:	963a                	add	a2,a2,a4
    8000607c:	7779                	lui	a4,0xffffe
    8000607e:	9732                	add	a4,a4,a2
    80006080:	e314                	sd	a3,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006082:	00459713          	slli	a4,a1,0x4
    80006086:	6394                	ld	a3,0(a5)
    80006088:	96ba                	add	a3,a3,a4
    8000608a:	4641                	li	a2,16
    8000608c:	c690                	sw	a2,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000608e:	6394                	ld	a3,0(a5)
    80006090:	96ba                	add	a3,a3,a4
    80006092:	4605                	li	a2,1
    80006094:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006098:	fa442683          	lw	a3,-92(s0)
    8000609c:	6390                	ld	a2,0(a5)
    8000609e:	963a                	add	a2,a2,a4
    800060a0:	00d61723          	sh	a3,14(a2) # 200e <_entry-0x7fffdff2>

  disk.desc[idx[1]].addr = (uint64) b->data;
    800060a4:	0692                	slli	a3,a3,0x4
    800060a6:	6390                	ld	a2,0(a5)
    800060a8:	9636                	add	a2,a2,a3
    800060aa:	05890513          	addi	a0,s2,88
    800060ae:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800060b0:	639c                	ld	a5,0(a5)
    800060b2:	97b6                	add	a5,a5,a3
    800060b4:	40000613          	li	a2,1024
    800060b8:	c790                	sw	a2,8(a5)
  if(write)
    800060ba:	140c0163          	beqz	s8,800061fc <virtio_disk_rw+0x2a6>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800060be:	0001f797          	auipc	a5,0x1f
    800060c2:	f4278793          	addi	a5,a5,-190 # 80025000 <disk+0x2000>
    800060c6:	639c                	ld	a5,0(a5)
    800060c8:	97b6                	add	a5,a5,a3
    800060ca:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800060ce:	0001d897          	auipc	a7,0x1d
    800060d2:	f3288893          	addi	a7,a7,-206 # 80023000 <disk>
    800060d6:	0001f797          	auipc	a5,0x1f
    800060da:	f2a78793          	addi	a5,a5,-214 # 80025000 <disk+0x2000>
    800060de:	6390                	ld	a2,0(a5)
    800060e0:	9636                	add	a2,a2,a3
    800060e2:	00c65503          	lhu	a0,12(a2)
    800060e6:	00156513          	ori	a0,a0,1
    800060ea:	00a61623          	sh	a0,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800060ee:	fa842603          	lw	a2,-88(s0)
    800060f2:	6388                	ld	a0,0(a5)
    800060f4:	96aa                	add	a3,a3,a0
    800060f6:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800060fa:	20058513          	addi	a0,a1,512
    800060fe:	0512                	slli	a0,a0,0x4
    80006100:	9546                	add	a0,a0,a7
    80006102:	56fd                	li	a3,-1
    80006104:	02d50823          	sb	a3,48(a0)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006108:	00461693          	slli	a3,a2,0x4
    8000610c:	6390                	ld	a2,0(a5)
    8000610e:	9636                	add	a2,a2,a3
    80006110:	6809                	lui	a6,0x2
    80006112:	03080813          	addi	a6,a6,48 # 2030 <_entry-0x7fffdfd0>
    80006116:	9742                	add	a4,a4,a6
    80006118:	9746                	add	a4,a4,a7
    8000611a:	e218                	sd	a4,0(a2)
  disk.desc[idx[2]].len = 1;
    8000611c:	6398                	ld	a4,0(a5)
    8000611e:	9736                	add	a4,a4,a3
    80006120:	4605                	li	a2,1
    80006122:	c710                	sw	a2,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006124:	6398                	ld	a4,0(a5)
    80006126:	9736                	add	a4,a4,a3
    80006128:	4809                	li	a6,2
    8000612a:	01071623          	sh	a6,12(a4) # ffffffffffffe00c <end+0xffffffff7ffd800c>
  disk.desc[idx[2]].next = 0;
    8000612e:	6398                	ld	a4,0(a5)
    80006130:	96ba                	add	a3,a3,a4
    80006132:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006136:	00c92223          	sw	a2,4(s2)
  disk.info[idx[0]].b = b;
    8000613a:	03253423          	sd	s2,40(a0)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000613e:	6794                	ld	a3,8(a5)
    80006140:	0026d703          	lhu	a4,2(a3)
    80006144:	8b1d                	andi	a4,a4,7
    80006146:	0706                	slli	a4,a4,0x1
    80006148:	9736                	add	a4,a4,a3
    8000614a:	00b71223          	sh	a1,4(a4)

  __sync_synchronize();
    8000614e:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006152:	6798                	ld	a4,8(a5)
    80006154:	00275783          	lhu	a5,2(a4)
    80006158:	2785                	addiw	a5,a5,1
    8000615a:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000615e:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006162:	100017b7          	lui	a5,0x10001
    80006166:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000616a:	00492703          	lw	a4,4(s2)
    8000616e:	4785                	li	a5,1
    80006170:	02f71163          	bne	a4,a5,80006192 <virtio_disk_rw+0x23c>
    sleep(b, &disk.vdisk_lock);
    80006174:	0001f997          	auipc	s3,0x1f
    80006178:	fb498993          	addi	s3,s3,-76 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    8000617c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000617e:	85ce                	mv	a1,s3
    80006180:	854a                	mv	a0,s2
    80006182:	ffffc097          	auipc	ra,0xffffc
    80006186:	096080e7          	jalr	150(ra) # 80002218 <sleep>
  while(b->disk == 1) {
    8000618a:	00492783          	lw	a5,4(s2)
    8000618e:	fe9788e3          	beq	a5,s1,8000617e <virtio_disk_rw+0x228>
  }

  disk.info[idx[0]].b = 0;
    80006192:	fa042503          	lw	a0,-96(s0)
    80006196:	20050793          	addi	a5,a0,512
    8000619a:	00479713          	slli	a4,a5,0x4
    8000619e:	0001d797          	auipc	a5,0x1d
    800061a2:	e6278793          	addi	a5,a5,-414 # 80023000 <disk>
    800061a6:	97ba                	add	a5,a5,a4
    800061a8:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800061ac:	0001f997          	auipc	s3,0x1f
    800061b0:	e5498993          	addi	s3,s3,-428 # 80025000 <disk+0x2000>
    800061b4:	00451713          	slli	a4,a0,0x4
    800061b8:	0009b783          	ld	a5,0(s3)
    800061bc:	97ba                	add	a5,a5,a4
    800061be:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800061c2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800061c6:	00000097          	auipc	ra,0x0
    800061ca:	bb0080e7          	jalr	-1104(ra) # 80005d76 <free_desc>
      i = nxt;
    800061ce:	854a                	mv	a0,s2
    if(flag & VRING_DESC_F_NEXT)
    800061d0:	8885                	andi	s1,s1,1
    800061d2:	f0ed                	bnez	s1,800061b4 <virtio_disk_rw+0x25e>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800061d4:	0001f517          	auipc	a0,0x1f
    800061d8:	f5450513          	addi	a0,a0,-172 # 80025128 <disk+0x2128>
    800061dc:	ffffb097          	auipc	ra,0xffffb
    800061e0:	b3e080e7          	jalr	-1218(ra) # 80000d1a <release>
}
    800061e4:	60e6                	ld	ra,88(sp)
    800061e6:	6446                	ld	s0,80(sp)
    800061e8:	64a6                	ld	s1,72(sp)
    800061ea:	6906                	ld	s2,64(sp)
    800061ec:	79e2                	ld	s3,56(sp)
    800061ee:	7a42                	ld	s4,48(sp)
    800061f0:	7aa2                	ld	s5,40(sp)
    800061f2:	7b02                	ld	s6,32(sp)
    800061f4:	6be2                	ld	s7,24(sp)
    800061f6:	6c42                	ld	s8,16(sp)
    800061f8:	6125                	addi	sp,sp,96
    800061fa:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800061fc:	0001f797          	auipc	a5,0x1f
    80006200:	e0478793          	addi	a5,a5,-508 # 80025000 <disk+0x2000>
    80006204:	639c                	ld	a5,0(a5)
    80006206:	97b6                	add	a5,a5,a3
    80006208:	4609                	li	a2,2
    8000620a:	00c79623          	sh	a2,12(a5)
    8000620e:	b5c1                	j	800060ce <virtio_disk_rw+0x178>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006210:	fa042583          	lw	a1,-96(s0)
    80006214:	20058713          	addi	a4,a1,512
    80006218:	0712                	slli	a4,a4,0x4
    8000621a:	0001d697          	auipc	a3,0x1d
    8000621e:	e8e68693          	addi	a3,a3,-370 # 800230a8 <disk+0xa8>
    80006222:	96ba                	add	a3,a3,a4
  if(write)
    80006224:	e00c1de3          	bnez	s8,8000603e <virtio_disk_rw+0xe8>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006228:	20058793          	addi	a5,a1,512
    8000622c:	00479613          	slli	a2,a5,0x4
    80006230:	0001d797          	auipc	a5,0x1d
    80006234:	dd078793          	addi	a5,a5,-560 # 80023000 <disk>
    80006238:	97b2                	add	a5,a5,a2
    8000623a:	0a07a423          	sw	zero,168(a5)
    8000623e:	bd21                	j	80006056 <virtio_disk_rw+0x100>
      disk.free[i] = 0;
    80006240:	00098c23          	sb	zero,24(s3)
    idx[i] = alloc_desc();
    80006244:	00072023          	sw	zero,0(a4)
    if(idx[i] < 0){
    80006248:	b3bd                	j	80005fb6 <virtio_disk_rw+0x60>

000000008000624a <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000624a:	1101                	addi	sp,sp,-32
    8000624c:	ec06                	sd	ra,24(sp)
    8000624e:	e822                	sd	s0,16(sp)
    80006250:	e426                	sd	s1,8(sp)
    80006252:	e04a                	sd	s2,0(sp)
    80006254:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006256:	0001f517          	auipc	a0,0x1f
    8000625a:	ed250513          	addi	a0,a0,-302 # 80025128 <disk+0x2128>
    8000625e:	ffffb097          	auipc	ra,0xffffb
    80006262:	a08080e7          	jalr	-1528(ra) # 80000c66 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006266:	10001737          	lui	a4,0x10001
    8000626a:	533c                	lw	a5,96(a4)
    8000626c:	8b8d                	andi	a5,a5,3
    8000626e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006270:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006274:	0001f797          	auipc	a5,0x1f
    80006278:	d8c78793          	addi	a5,a5,-628 # 80025000 <disk+0x2000>
    8000627c:	6b94                	ld	a3,16(a5)
    8000627e:	0207d703          	lhu	a4,32(a5)
    80006282:	0026d783          	lhu	a5,2(a3)
    80006286:	06f70163          	beq	a4,a5,800062e8 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000628a:	0001d917          	auipc	s2,0x1d
    8000628e:	d7690913          	addi	s2,s2,-650 # 80023000 <disk>
    80006292:	0001f497          	auipc	s1,0x1f
    80006296:	d6e48493          	addi	s1,s1,-658 # 80025000 <disk+0x2000>
    __sync_synchronize();
    8000629a:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000629e:	6898                	ld	a4,16(s1)
    800062a0:	0204d783          	lhu	a5,32(s1)
    800062a4:	8b9d                	andi	a5,a5,7
    800062a6:	078e                	slli	a5,a5,0x3
    800062a8:	97ba                	add	a5,a5,a4
    800062aa:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800062ac:	20078713          	addi	a4,a5,512
    800062b0:	0712                	slli	a4,a4,0x4
    800062b2:	974a                	add	a4,a4,s2
    800062b4:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800062b8:	e731                	bnez	a4,80006304 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800062ba:	20078793          	addi	a5,a5,512
    800062be:	0792                	slli	a5,a5,0x4
    800062c0:	97ca                	add	a5,a5,s2
    800062c2:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800062c4:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800062c8:	ffffc097          	auipc	ra,0xffffc
    800062cc:	0d6080e7          	jalr	214(ra) # 8000239e <wakeup>

    disk.used_idx += 1;
    800062d0:	0204d783          	lhu	a5,32(s1)
    800062d4:	2785                	addiw	a5,a5,1
    800062d6:	17c2                	slli	a5,a5,0x30
    800062d8:	93c1                	srli	a5,a5,0x30
    800062da:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800062de:	6898                	ld	a4,16(s1)
    800062e0:	00275703          	lhu	a4,2(a4)
    800062e4:	faf71be3          	bne	a4,a5,8000629a <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800062e8:	0001f517          	auipc	a0,0x1f
    800062ec:	e4050513          	addi	a0,a0,-448 # 80025128 <disk+0x2128>
    800062f0:	ffffb097          	auipc	ra,0xffffb
    800062f4:	a2a080e7          	jalr	-1494(ra) # 80000d1a <release>
}
    800062f8:	60e2                	ld	ra,24(sp)
    800062fa:	6442                	ld	s0,16(sp)
    800062fc:	64a2                	ld	s1,8(sp)
    800062fe:	6902                	ld	s2,0(sp)
    80006300:	6105                	addi	sp,sp,32
    80006302:	8082                	ret
      panic("virtio_disk_intr status");
    80006304:	00002517          	auipc	a0,0x2
    80006308:	4dc50513          	addi	a0,a0,1244 # 800087e0 <syscalls+0x3e8>
    8000630c:	ffffa097          	auipc	ra,0xffffa
    80006310:	26c080e7          	jalr	620(ra) # 80000578 <panic>
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
