
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	92013103          	ld	sp,-1760(sp) # 80008920 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	12e78793          	addi	a5,a5,302 # 80006190 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffcc7d7>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	2ae78793          	addi	a5,a5,686 # 8000135a <main>
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
    80000116:	c68080e7          	jalr	-920(ra) # 80000d7a <acquire>
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
    80000130:	7d0080e7          	jalr	2000(ra) # 800028fc <either_copyin>
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
    80000158:	cf6080e7          	jalr	-778(ra) # 80000e4a <release>

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
    800001a8:	bd6080e7          	jalr	-1066(ra) # 80000d7a <acquire>
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
    800001be:	05690913          	addi	s2,s2,86 # 80011210 <cons+0xa0>
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
    800001c8:	0a04a783          	lw	a5,160(s1)
    800001cc:	0a44a703          	lw	a4,164(s1)
    800001d0:	02f71463          	bne	a4,a5,800001f8 <consoleread+0x84>
      if(myproc()->killed){
    800001d4:	00002097          	auipc	ra,0x2
    800001d8:	c56080e7          	jalr	-938(ra) # 80001e2a <myproc>
    800001dc:	5d1c                	lw	a5,56(a0)
    800001de:	eba5                	bnez	a5,8000024e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001e0:	85ce                	mv	a1,s3
    800001e2:	854a                	mv	a0,s2
    800001e4:	00002097          	auipc	ra,0x2
    800001e8:	460080e7          	jalr	1120(ra) # 80002644 <sleep>
    while(cons.r == cons.w){
    800001ec:	0a04a783          	lw	a5,160(s1)
    800001f0:	0a44a703          	lw	a4,164(s1)
    800001f4:	fef700e3          	beq	a4,a5,800001d4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f8:	0017871b          	addiw	a4,a5,1
    800001fc:	0ae4a023          	sw	a4,160(s1)
    80000200:	07f7f713          	andi	a4,a5,127
    80000204:	9726                	add	a4,a4,s1
    80000206:	02074703          	lbu	a4,32(a4)
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
    80000224:	686080e7          	jalr	1670(ra) # 800028a6 <either_copyout>
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
    80000244:	c0a080e7          	jalr	-1014(ra) # 80000e4a <release>

  return target - n;
    80000248:	414b053b          	subw	a0,s6,s4
    8000024c:	a811                	j	80000260 <consoleread+0xec>
        release(&cons.lock);
    8000024e:	00011517          	auipc	a0,0x11
    80000252:	f2250513          	addi	a0,a0,-222 # 80011170 <cons>
    80000256:	00001097          	auipc	ra,0x1
    8000025a:	bf4080e7          	jalr	-1036(ra) # 80000e4a <release>
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
    8000028a:	f8f72523          	sw	a5,-118(a4) # 80011210 <cons+0xa0>
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
    800002ec:	a92080e7          	jalr	-1390(ra) # 80000d7a <acquire>

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
    80000310:	0a872783          	lw	a5,168(a4)
    80000314:	0a472703          	lw	a4,164(a4)
    80000318:	10f70563          	beq	a4,a5,80000422 <consoleintr+0x150>
      cons.e--;
    8000031c:	37fd                	addiw	a5,a5,-1
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	eef72d23          	sw	a5,-262(a4) # 80011218 <cons+0xa8>
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
    80000344:	0a872783          	lw	a5,168(a4)
    80000348:	0a072703          	lw	a4,160(a4)
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
    8000036e:	0a87a703          	lw	a4,168(a5)
    80000372:	0017069b          	addiw	a3,a4,1
    80000376:	0006861b          	sext.w	a2,a3
    8000037a:	0ad7a423          	sw	a3,168(a5)
    8000037e:	07f77713          	andi	a4,a4,127
    80000382:	97ba                	add	a5,a5,a4
    80000384:	02978023          	sb	s1,32(a5)

      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000388:	47a9                	li	a5,10
    8000038a:	0ef48163          	beq	s1,a5,8000046c <consoleintr+0x19a>
    8000038e:	4791                	li	a5,4
    80000390:	0cf48e63          	beq	s1,a5,8000046c <consoleintr+0x19a>
    80000394:	00011797          	auipc	a5,0x11
    80000398:	ddc78793          	addi	a5,a5,-548 # 80011170 <cons>
    8000039c:	0a07a783          	lw	a5,160(a5)
    800003a0:	0807879b          	addiw	a5,a5,128
    800003a4:	06f61f63          	bne	a2,a5,80000422 <consoleintr+0x150>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003a8:	863e                	mv	a2,a5
    800003aa:	a0c9                	j	8000046c <consoleintr+0x19a>
    while(cons.e != cons.w &&
    800003ac:	00011717          	auipc	a4,0x11
    800003b0:	dc470713          	addi	a4,a4,-572 # 80011170 <cons>
    800003b4:	0a872783          	lw	a5,168(a4)
    800003b8:	0a472703          	lw	a4,164(a4)
    800003bc:	06f70363          	beq	a4,a5,80000422 <consoleintr+0x150>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003c0:	37fd                	addiw	a5,a5,-1
    800003c2:	0007871b          	sext.w	a4,a5
    800003c6:	07f7f793          	andi	a5,a5,127
    800003ca:	00011697          	auipc	a3,0x11
    800003ce:	da668693          	addi	a3,a3,-602 # 80011170 <cons>
    800003d2:	97b6                	add	a5,a5,a3
    while(cons.e != cons.w &&
    800003d4:	0207c683          	lbu	a3,32(a5)
    800003d8:	47a9                	li	a5,10
      cons.e--;
    800003da:	00011497          	auipc	s1,0x11
    800003de:	d9648493          	addi	s1,s1,-618 # 80011170 <cons>
    while(cons.e != cons.w &&
    800003e2:	4929                	li	s2,10
    800003e4:	02f68f63          	beq	a3,a5,80000422 <consoleintr+0x150>
      cons.e--;
    800003e8:	0ae4a423          	sw	a4,168(s1)
      consputc(BACKSPACE);
    800003ec:	10000513          	li	a0,256
    800003f0:	00000097          	auipc	ra,0x0
    800003f4:	ea0080e7          	jalr	-352(ra) # 80000290 <consputc>
    while(cons.e != cons.w &&
    800003f8:	0a84a783          	lw	a5,168(s1)
    800003fc:	0a44a703          	lw	a4,164(s1)
    80000400:	02f70163          	beq	a4,a5,80000422 <consoleintr+0x150>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000404:	37fd                	addiw	a5,a5,-1
    80000406:	0007871b          	sext.w	a4,a5
    8000040a:	07f7f793          	andi	a5,a5,127
    8000040e:	97a6                	add	a5,a5,s1
    while(cons.e != cons.w &&
    80000410:	0207c783          	lbu	a5,32(a5)
    80000414:	fd279ae3          	bne	a5,s2,800003e8 <consoleintr+0x116>
    80000418:	a029                	j	80000422 <consoleintr+0x150>
    procdump();
    8000041a:	00002097          	auipc	ra,0x2
    8000041e:	538080e7          	jalr	1336(ra) # 80002952 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000422:	00011517          	auipc	a0,0x11
    80000426:	d4e50513          	addi	a0,a0,-690 # 80011170 <cons>
    8000042a:	00001097          	auipc	ra,0x1
    8000042e:	a20080e7          	jalr	-1504(ra) # 80000e4a <release>
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
    80000450:	0a87a703          	lw	a4,168(a5)
    80000454:	0017069b          	addiw	a3,a4,1
    80000458:	0006861b          	sext.w	a2,a3
    8000045c:	0ad7a423          	sw	a3,168(a5)
    80000460:	07f77713          	andi	a4,a4,127
    80000464:	97ba                	add	a5,a5,a4
    80000466:	4729                	li	a4,10
    80000468:	02e78023          	sb	a4,32(a5)
        cons.w = cons.e;
    8000046c:	00011797          	auipc	a5,0x11
    80000470:	dac7a423          	sw	a2,-600(a5) # 80011214 <cons+0xa4>
        wakeup(&cons.r);
    80000474:	00011517          	auipc	a0,0x11
    80000478:	d9c50513          	addi	a0,a0,-612 # 80011210 <cons+0xa0>
    8000047c:	00002097          	auipc	ra,0x2
    80000480:	34e080e7          	jalr	846(ra) # 800027ca <wakeup>
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
    8000049e:	00001097          	auipc	ra,0x1
    800004a2:	a68080e7          	jalr	-1432(ra) # 80000f06 <initlock>

  uartinit();
    800004a6:	00000097          	auipc	ra,0x0
    800004aa:	334080e7          	jalr	820(ra) # 800007da <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004ae:	0002c797          	auipc	a5,0x2c
    800004b2:	c3278793          	addi	a5,a5,-974 # 8002c0e0 <devsw>
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
    80000588:	ca07ae23          	sw	zero,-836(a5) # 80011240 <pr+0x20>
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
    800005aa:	bba50513          	addi	a0,a0,-1094 # 80008160 <digits+0x148>
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
    800005f8:	c2c78793          	addi	a5,a5,-980 # 80011220 <pr>
    800005fc:	0207ad83          	lw	s11,32(a5)
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
    8000063c:	742080e7          	jalr	1858(ra) # 80000d7a <acquire>
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
    8000079a:	a8a50513          	addi	a0,a0,-1398 # 80011220 <pr>
    8000079e:	00000097          	auipc	ra,0x0
    800007a2:	6ac080e7          	jalr	1708(ra) # 80000e4a <release>
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
    800007b6:	a6e48493          	addi	s1,s1,-1426 # 80011220 <pr>
    800007ba:	00008597          	auipc	a1,0x8
    800007be:	89658593          	addi	a1,a1,-1898 # 80008050 <digits+0x38>
    800007c2:	8526                	mv	a0,s1
    800007c4:	00000097          	auipc	ra,0x0
    800007c8:	742080e7          	jalr	1858(ra) # 80000f06 <initlock>
  pr.locking = 1;
    800007cc:	4785                	li	a5,1
    800007ce:	d09c                	sw	a5,32(s1)
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
    80000816:	a3650513          	addi	a0,a0,-1482 # 80011248 <uart_tx_lock>
    8000081a:	00000097          	auipc	ra,0x0
    8000081e:	6ec080e7          	jalr	1772(ra) # 80000f06 <initlock>
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
    8000083a:	4f8080e7          	jalr	1272(ra) # 80000d2e <push_off>

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
    80000870:	57e080e7          	jalr	1406(ra) # 80000dea <pop_off>
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
    800008be:	98ea0a13          	addi	s4,s4,-1650 # 80011248 <uart_tx_lock>
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
    800008da:	02074a83          	lbu	s5,32(a4)
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
    800008f6:	ed8080e7          	jalr	-296(ra) # 800027ca <wakeup>
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
    80000940:	90c50513          	addi	a0,a0,-1780 # 80011248 <uart_tx_lock>
    80000944:	00000097          	auipc	ra,0x0
    80000948:	436080e7          	jalr	1078(ra) # 80000d7a <acquire>
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
    8000098a:	8c2a0a13          	addi	s4,s4,-1854 # 80011248 <uart_tx_lock>
    8000098e:	00008497          	auipc	s1,0x8
    80000992:	67648493          	addi	s1,s1,1654 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000996:	00008917          	auipc	s2,0x8
    8000099a:	67290913          	addi	s2,s2,1650 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000099e:	85d2                	mv	a1,s4
    800009a0:	8526                	mv	a0,s1
    800009a2:	00002097          	auipc	ra,0x2
    800009a6:	ca2080e7          	jalr	-862(ra) # 80002644 <sleep>
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
    800009ca:	88248493          	addi	s1,s1,-1918 # 80011248 <uart_tx_lock>
    800009ce:	9726                	add	a4,a4,s1
    800009d0:	03370023          	sb	s3,32(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    800009d4:	00008717          	auipc	a4,0x8
    800009d8:	62f72a23          	sw	a5,1588(a4) # 80009008 <uart_tx_w>
      uartstart();
    800009dc:	00000097          	auipc	ra,0x0
    800009e0:	ea2080e7          	jalr	-350(ra) # 8000087e <uartstart>
      release(&uart_tx_lock);
    800009e4:	8526                	mv	a0,s1
    800009e6:	00000097          	auipc	ra,0x0
    800009ea:	464080e7          	jalr	1124(ra) # 80000e4a <release>
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
    80000a48:	00011497          	auipc	s1,0x11
    80000a4c:	80048493          	addi	s1,s1,-2048 # 80011248 <uart_tx_lock>
    80000a50:	8526                	mv	a0,s1
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	328080e7          	jalr	808(ra) # 80000d7a <acquire>
  uartstart();
    80000a5a:	00000097          	auipc	ra,0x0
    80000a5e:	e24080e7          	jalr	-476(ra) # 8000087e <uartstart>
  release(&uart_tx_lock);
    80000a62:	8526                	mv	a0,s1
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	3e6080e7          	jalr	998(ra) # 80000e4a <release>
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
    80000a76:	7139                	addi	sp,sp,-64
    80000a78:	fc06                	sd	ra,56(sp)
    80000a7a:	f822                	sd	s0,48(sp)
    80000a7c:	f426                	sd	s1,40(sp)
    80000a7e:	f04a                	sd	s2,32(sp)
    80000a80:	ec4e                	sd	s3,24(sp)
    80000a82:	e852                	sd	s4,16(sp)
    80000a84:	e456                	sd	s5,8(sp)
    80000a86:	0080                	addi	s0,sp,64
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a88:	6785                	lui	a5,0x1
    80000a8a:	17fd                	addi	a5,a5,-1
    80000a8c:	8fe9                	and	a5,a5,a0
    80000a8e:	e3d1                	bnez	a5,80000b12 <kfree+0x9c>
    80000a90:	892a                	mv	s2,a0
    80000a92:	00031797          	auipc	a5,0x31
    80000a96:	59678793          	addi	a5,a5,1430 # 80032028 <end>
    80000a9a:	06f56c63          	bltu	a0,a5,80000b12 <kfree+0x9c>
    80000a9e:	47c5                	li	a5,17
    80000aa0:	07ee                	slli	a5,a5,0x1b
    80000aa2:	06f57863          	bleu	a5,a0,80000b12 <kfree+0x9c>
    panic("kfree");

  push_off();
    80000aa6:	00000097          	auipc	ra,0x0
    80000aaa:	288080e7          	jalr	648(ra) # 80000d2e <push_off>
  int cpu = cpuid();
    80000aae:	00001097          	auipc	ra,0x1
    80000ab2:	350080e7          	jalr	848(ra) # 80001dfe <cpuid>
    80000ab6:	8aaa                	mv	s5,a0
  memset(pa, 1, PGSIZE);
    80000ab8:	6605                	lui	a2,0x1
    80000aba:	4585                	li	a1,1
    80000abc:	854a                	mv	a0,s2
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	6c8080e7          	jalr	1736(ra) # 80001186 <memset>
  r = (struct run*)pa;
  // --- critical session ---
  acquire(&kmem[cpu].lock);
    80000ac6:	00010a17          	auipc	s4,0x10
    80000aca:	7c2a0a13          	addi	s4,s4,1986 # 80011288 <kmem>
    80000ace:	002a9993          	slli	s3,s5,0x2
    80000ad2:	015984b3          	add	s1,s3,s5
    80000ad6:	048e                	slli	s1,s1,0x3
    80000ad8:	94d2                	add	s1,s1,s4
    80000ada:	8526                	mv	a0,s1
    80000adc:	00000097          	auipc	ra,0x0
    80000ae0:	29e080e7          	jalr	670(ra) # 80000d7a <acquire>
  r->next = kmem[cpu].freelist;
    80000ae4:	709c                	ld	a5,32(s1)
    80000ae6:	00f93023          	sd	a5,0(s2)
  kmem[cpu].freelist = r;
    80000aea:	0324b023          	sd	s2,32(s1)
  release(&kmem[cpu].lock);
    80000aee:	8526                	mv	a0,s1
    80000af0:	00000097          	auipc	ra,0x0
    80000af4:	35a080e7          	jalr	858(ra) # 80000e4a <release>
  // --- end of critical session ---
  pop_off();
    80000af8:	00000097          	auipc	ra,0x0
    80000afc:	2f2080e7          	jalr	754(ra) # 80000dea <pop_off>
}
    80000b00:	70e2                	ld	ra,56(sp)
    80000b02:	7442                	ld	s0,48(sp)
    80000b04:	74a2                	ld	s1,40(sp)
    80000b06:	7902                	ld	s2,32(sp)
    80000b08:	69e2                	ld	s3,24(sp)
    80000b0a:	6a42                	ld	s4,16(sp)
    80000b0c:	6aa2                	ld	s5,8(sp)
    80000b0e:	6121                	addi	sp,sp,64
    80000b10:	8082                	ret
    panic("kfree");
    80000b12:	00007517          	auipc	a0,0x7
    80000b16:	54e50513          	addi	a0,a0,1358 # 80008060 <digits+0x48>
    80000b1a:	00000097          	auipc	ra,0x0
    80000b1e:	a5e080e7          	jalr	-1442(ra) # 80000578 <panic>

0000000080000b22 <freerange>:
{
    80000b22:	7179                	addi	sp,sp,-48
    80000b24:	f406                	sd	ra,40(sp)
    80000b26:	f022                	sd	s0,32(sp)
    80000b28:	ec26                	sd	s1,24(sp)
    80000b2a:	e84a                	sd	s2,16(sp)
    80000b2c:	e44e                	sd	s3,8(sp)
    80000b2e:	e052                	sd	s4,0(sp)
    80000b30:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b32:	6705                	lui	a4,0x1
    80000b34:	fff70793          	addi	a5,a4,-1 # fff <_entry-0x7ffff001>
    80000b38:	00f504b3          	add	s1,a0,a5
    80000b3c:	77fd                	lui	a5,0xfffff
    80000b3e:	8cfd                	and	s1,s1,a5
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b40:	94ba                	add	s1,s1,a4
    80000b42:	0095ee63          	bltu	a1,s1,80000b5e <freerange+0x3c>
    80000b46:	892e                	mv	s2,a1
    kfree(p);
    80000b48:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b4a:	6985                	lui	s3,0x1
    kfree(p);
    80000b4c:	01448533          	add	a0,s1,s4
    80000b50:	00000097          	auipc	ra,0x0
    80000b54:	f26080e7          	jalr	-218(ra) # 80000a76 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b58:	94ce                	add	s1,s1,s3
    80000b5a:	fe9979e3          	bleu	s1,s2,80000b4c <freerange+0x2a>
}
    80000b5e:	70a2                	ld	ra,40(sp)
    80000b60:	7402                	ld	s0,32(sp)
    80000b62:	64e2                	ld	s1,24(sp)
    80000b64:	6942                	ld	s2,16(sp)
    80000b66:	69a2                	ld	s3,8(sp)
    80000b68:	6a02                	ld	s4,0(sp)
    80000b6a:	6145                	addi	sp,sp,48
    80000b6c:	8082                	ret

0000000080000b6e <kinit>:
{
    80000b6e:	7179                	addi	sp,sp,-48
    80000b70:	f406                	sd	ra,40(sp)
    80000b72:	f022                	sd	s0,32(sp)
    80000b74:	ec26                	sd	s1,24(sp)
    80000b76:	e84a                	sd	s2,16(sp)
    80000b78:	e44e                	sd	s3,8(sp)
    80000b7a:	1800                	addi	s0,sp,48
  for (int i = 0; i < NCPU; i++) {
    80000b7c:	00010497          	auipc	s1,0x10
    80000b80:	70c48493          	addi	s1,s1,1804 # 80011288 <kmem>
    80000b84:	00011997          	auipc	s3,0x11
    80000b88:	84498993          	addi	s3,s3,-1980 # 800113c8 <lock_locks>
    initlock(&kmem[i].lock, "kmem");
    80000b8c:	00007917          	auipc	s2,0x7
    80000b90:	4dc90913          	addi	s2,s2,1244 # 80008068 <digits+0x50>
    80000b94:	85ca                	mv	a1,s2
    80000b96:	8526                	mv	a0,s1
    80000b98:	00000097          	auipc	ra,0x0
    80000b9c:	36e080e7          	jalr	878(ra) # 80000f06 <initlock>
  for (int i = 0; i < NCPU; i++) {
    80000ba0:	02848493          	addi	s1,s1,40
    80000ba4:	ff3498e3          	bne	s1,s3,80000b94 <kinit+0x26>
  freerange(end, (void*)PHYSTOP);
    80000ba8:	45c5                	li	a1,17
    80000baa:	05ee                	slli	a1,a1,0x1b
    80000bac:	00031517          	auipc	a0,0x31
    80000bb0:	47c50513          	addi	a0,a0,1148 # 80032028 <end>
    80000bb4:	00000097          	auipc	ra,0x0
    80000bb8:	f6e080e7          	jalr	-146(ra) # 80000b22 <freerange>
}
    80000bbc:	70a2                	ld	ra,40(sp)
    80000bbe:	7402                	ld	s0,32(sp)
    80000bc0:	64e2                	ld	s1,24(sp)
    80000bc2:	6942                	ld	s2,16(sp)
    80000bc4:	69a2                	ld	s3,8(sp)
    80000bc6:	6145                	addi	sp,sp,48
    80000bc8:	8082                	ret

0000000080000bca <ksteal>:

// Try steal a free physical memory page from another core
// interrupt should already be turned off
// return NULL if not found free page
void *
ksteal(int cpu) {
    80000bca:	7139                	addi	sp,sp,-64
    80000bcc:	fc06                	sd	ra,56(sp)
    80000bce:	f822                	sd	s0,48(sp)
    80000bd0:	f426                	sd	s1,40(sp)
    80000bd2:	f04a                	sd	s2,32(sp)
    80000bd4:	ec4e                	sd	s3,24(sp)
    80000bd6:	e852                	sd	s4,16(sp)
    80000bd8:	e456                	sd	s5,8(sp)
    80000bda:	e05a                	sd	s6,0(sp)
    80000bdc:	0080                	addi	s0,sp,64
  struct run *r;
  for (int i = 1; i < NCPU; i++) {
    80000bde:	0015099b          	addiw	s3,a0,1
    80000be2:	00850a1b          	addiw	s4,a0,8
    int next_cpu = (cpu + i) % NCPU;
    // --- critical session ---
    acquire(&kmem[next_cpu].lock);
    80000be6:	00010a97          	auipc	s5,0x10
    80000bea:	6a2a8a93          	addi	s5,s5,1698 # 80011288 <kmem>
    80000bee:	a809                	j	80000c00 <ksteal+0x36>
    r = kmem[next_cpu].freelist;
    if (r) {
      // steal one page
      kmem[next_cpu].freelist = r->next;
    }
    release(&kmem[next_cpu].lock);
    80000bf0:	8526                	mv	a0,s1
    80000bf2:	00000097          	auipc	ra,0x0
    80000bf6:	258080e7          	jalr	600(ra) # 80000e4a <release>
  for (int i = 1; i < NCPU; i++) {
    80000bfa:	2985                	addiw	s3,s3,1
    80000bfc:	05498c63          	beq	s3,s4,80000c54 <ksteal+0x8a>
    int next_cpu = (cpu + i) % NCPU;
    80000c00:	41f9d91b          	sraiw	s2,s3,0x1f
    80000c04:	01d9579b          	srliw	a5,s2,0x1d
    80000c08:	0137893b          	addw	s2,a5,s3
    80000c0c:	00797913          	andi	s2,s2,7
    80000c10:	40f9093b          	subw	s2,s2,a5
    acquire(&kmem[next_cpu].lock);
    80000c14:	00291493          	slli	s1,s2,0x2
    80000c18:	94ca                	add	s1,s1,s2
    80000c1a:	048e                	slli	s1,s1,0x3
    80000c1c:	94d6                	add	s1,s1,s5
    80000c1e:	8526                	mv	a0,s1
    80000c20:	00000097          	auipc	ra,0x0
    80000c24:	15a080e7          	jalr	346(ra) # 80000d7a <acquire>
    r = kmem[next_cpu].freelist;
    80000c28:	0204bb03          	ld	s6,32(s1)
    if (r) {
    80000c2c:	fc0b02e3          	beqz	s6,80000bf0 <ksteal+0x26>
      kmem[next_cpu].freelist = r->next;
    80000c30:	000b3703          	ld	a4,0(s6)
    80000c34:	00291793          	slli	a5,s2,0x2
    80000c38:	993e                	add	s2,s2,a5
    80000c3a:	090e                	slli	s2,s2,0x3
    80000c3c:	00010797          	auipc	a5,0x10
    80000c40:	64c78793          	addi	a5,a5,1612 # 80011288 <kmem>
    80000c44:	993e                	add	s2,s2,a5
    80000c46:	02e93023          	sd	a4,32(s2)
    release(&kmem[next_cpu].lock);
    80000c4a:	8526                	mv	a0,s1
    80000c4c:	00000097          	auipc	ra,0x0
    80000c50:	1fe080e7          	jalr	510(ra) # 80000e4a <release>
    if (r) {
      break;
    }
  }
  return r;
}
    80000c54:	855a                	mv	a0,s6
    80000c56:	70e2                	ld	ra,56(sp)
    80000c58:	7442                	ld	s0,48(sp)
    80000c5a:	74a2                	ld	s1,40(sp)
    80000c5c:	7902                	ld	s2,32(sp)
    80000c5e:	69e2                	ld	s3,24(sp)
    80000c60:	6a42                	ld	s4,16(sp)
    80000c62:	6aa2                	ld	s5,8(sp)
    80000c64:	6b02                	ld	s6,0(sp)
    80000c66:	6121                	addi	sp,sp,64
    80000c68:	8082                	ret

0000000080000c6a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000c6a:	7179                	addi	sp,sp,-48
    80000c6c:	f406                	sd	ra,40(sp)
    80000c6e:	f022                	sd	s0,32(sp)
    80000c70:	ec26                	sd	s1,24(sp)
    80000c72:	e84a                	sd	s2,16(sp)
    80000c74:	e44e                	sd	s3,8(sp)
    80000c76:	1800                	addi	s0,sp,48
  struct run *r;

  push_off();
    80000c78:	00000097          	auipc	ra,0x0
    80000c7c:	0b6080e7          	jalr	182(ra) # 80000d2e <push_off>

  int cpu = cpuid();
    80000c80:	00001097          	auipc	ra,0x1
    80000c84:	17e080e7          	jalr	382(ra) # 80001dfe <cpuid>
    80000c88:	89aa                	mv	s3,a0
  // --- critical session ---
  acquire(&kmem[cpu].lock);
    80000c8a:	00251493          	slli	s1,a0,0x2
    80000c8e:	94aa                	add	s1,s1,a0
    80000c90:	00349793          	slli	a5,s1,0x3
    80000c94:	00010497          	auipc	s1,0x10
    80000c98:	5f448493          	addi	s1,s1,1524 # 80011288 <kmem>
    80000c9c:	94be                	add	s1,s1,a5
    80000c9e:	8526                	mv	a0,s1
    80000ca0:	00000097          	auipc	ra,0x0
    80000ca4:	0da080e7          	jalr	218(ra) # 80000d7a <acquire>
  r = kmem[cpu].freelist;
    80000ca8:	0204b903          	ld	s2,32(s1)
  if (r) {
    80000cac:	02090d63          	beqz	s2,80000ce6 <kalloc+0x7c>
    kmem[cpu].freelist = r->next;
    80000cb0:	00093703          	ld	a4,0(s2)
    80000cb4:	f098                	sd	a4,32(s1)
  }
  release(&kmem[cpu].lock);
    80000cb6:	8526                	mv	a0,s1
    80000cb8:	00000097          	auipc	ra,0x0
    80000cbc:	192080e7          	jalr	402(ra) # 80000e4a <release>
  if (r == 0) {
    r = ksteal(cpu);
  }

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000cc0:	6605                	lui	a2,0x1
    80000cc2:	4595                	li	a1,5
    80000cc4:	854a                	mv	a0,s2
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	4c0080e7          	jalr	1216(ra) # 80001186 <memset>

  pop_off();
    80000cce:	00000097          	auipc	ra,0x0
    80000cd2:	11c080e7          	jalr	284(ra) # 80000dea <pop_off>
  return (void*)r;
}
    80000cd6:	854a                	mv	a0,s2
    80000cd8:	70a2                	ld	ra,40(sp)
    80000cda:	7402                	ld	s0,32(sp)
    80000cdc:	64e2                	ld	s1,24(sp)
    80000cde:	6942                	ld	s2,16(sp)
    80000ce0:	69a2                	ld	s3,8(sp)
    80000ce2:	6145                	addi	sp,sp,48
    80000ce4:	8082                	ret
  release(&kmem[cpu].lock);
    80000ce6:	8526                	mv	a0,s1
    80000ce8:	00000097          	auipc	ra,0x0
    80000cec:	162080e7          	jalr	354(ra) # 80000e4a <release>
    r = ksteal(cpu);
    80000cf0:	854e                	mv	a0,s3
    80000cf2:	00000097          	auipc	ra,0x0
    80000cf6:	ed8080e7          	jalr	-296(ra) # 80000bca <ksteal>
    80000cfa:	892a                	mv	s2,a0
  if(r)
    80000cfc:	d969                	beqz	a0,80000cce <kalloc+0x64>
    80000cfe:	b7c9                	j	80000cc0 <kalloc+0x56>

0000000080000d00 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000d00:	411c                	lw	a5,0(a0)
    80000d02:	e399                	bnez	a5,80000d08 <holding+0x8>
    80000d04:	4501                	li	a0,0
  return r;
}
    80000d06:	8082                	ret
{
    80000d08:	1101                	addi	sp,sp,-32
    80000d0a:	ec06                	sd	ra,24(sp)
    80000d0c:	e822                	sd	s0,16(sp)
    80000d0e:	e426                	sd	s1,8(sp)
    80000d10:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000d12:	6904                	ld	s1,16(a0)
    80000d14:	00001097          	auipc	ra,0x1
    80000d18:	0fa080e7          	jalr	250(ra) # 80001e0e <mycpu>
    80000d1c:	40a48533          	sub	a0,s1,a0
    80000d20:	00153513          	seqz	a0,a0
}
    80000d24:	60e2                	ld	ra,24(sp)
    80000d26:	6442                	ld	s0,16(sp)
    80000d28:	64a2                	ld	s1,8(sp)
    80000d2a:	6105                	addi	sp,sp,32
    80000d2c:	8082                	ret

0000000080000d2e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000d2e:	1101                	addi	sp,sp,-32
    80000d30:	ec06                	sd	ra,24(sp)
    80000d32:	e822                	sd	s0,16(sp)
    80000d34:	e426                	sd	s1,8(sp)
    80000d36:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d38:	100024f3          	csrr	s1,sstatus
    80000d3c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000d40:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d42:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000d46:	00001097          	auipc	ra,0x1
    80000d4a:	0c8080e7          	jalr	200(ra) # 80001e0e <mycpu>
    80000d4e:	5d3c                	lw	a5,120(a0)
    80000d50:	cf89                	beqz	a5,80000d6a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d52:	00001097          	auipc	ra,0x1
    80000d56:	0bc080e7          	jalr	188(ra) # 80001e0e <mycpu>
    80000d5a:	5d3c                	lw	a5,120(a0)
    80000d5c:	2785                	addiw	a5,a5,1
    80000d5e:	dd3c                	sw	a5,120(a0)
}
    80000d60:	60e2                	ld	ra,24(sp)
    80000d62:	6442                	ld	s0,16(sp)
    80000d64:	64a2                	ld	s1,8(sp)
    80000d66:	6105                	addi	sp,sp,32
    80000d68:	8082                	ret
    mycpu()->intena = old;
    80000d6a:	00001097          	auipc	ra,0x1
    80000d6e:	0a4080e7          	jalr	164(ra) # 80001e0e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000d72:	8085                	srli	s1,s1,0x1
    80000d74:	8885                	andi	s1,s1,1
    80000d76:	dd64                	sw	s1,124(a0)
    80000d78:	bfe9                	j	80000d52 <push_off+0x24>

0000000080000d7a <acquire>:
{
    80000d7a:	1101                	addi	sp,sp,-32
    80000d7c:	ec06                	sd	ra,24(sp)
    80000d7e:	e822                	sd	s0,16(sp)
    80000d80:	e426                	sd	s1,8(sp)
    80000d82:	1000                	addi	s0,sp,32
    80000d84:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	fa8080e7          	jalr	-88(ra) # 80000d2e <push_off>
  if(holding(lk))
    80000d8e:	8526                	mv	a0,s1
    80000d90:	00000097          	auipc	ra,0x0
    80000d94:	f70080e7          	jalr	-144(ra) # 80000d00 <holding>
    80000d98:	e50d                	bnez	a0,80000dc2 <acquire+0x48>
    __sync_fetch_and_add(&(lk->n), 1);
    80000d9a:	4785                	li	a5,1
    80000d9c:	01c48713          	addi	a4,s1,28
    80000da0:	0f50000f          	fence	iorw,ow
    80000da4:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000da8:	4705                	li	a4,1
    80000daa:	87ba                	mv	a5,a4
    80000dac:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000db0:	2781                	sext.w	a5,a5
    80000db2:	c385                	beqz	a5,80000dd2 <acquire+0x58>
    __sync_fetch_and_add(&(lk->nts), 1);
    80000db4:	01848793          	addi	a5,s1,24
    80000db8:	0f50000f          	fence	iorw,ow
    80000dbc:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
    80000dc0:	b7ed                	j	80000daa <acquire+0x30>
    panic("acquire");
    80000dc2:	00007517          	auipc	a0,0x7
    80000dc6:	2ae50513          	addi	a0,a0,686 # 80008070 <digits+0x58>
    80000dca:	fffff097          	auipc	ra,0xfffff
    80000dce:	7ae080e7          	jalr	1966(ra) # 80000578 <panic>
  __sync_synchronize();
    80000dd2:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000dd6:	00001097          	auipc	ra,0x1
    80000dda:	038080e7          	jalr	56(ra) # 80001e0e <mycpu>
    80000dde:	e888                	sd	a0,16(s1)
}
    80000de0:	60e2                	ld	ra,24(sp)
    80000de2:	6442                	ld	s0,16(sp)
    80000de4:	64a2                	ld	s1,8(sp)
    80000de6:	6105                	addi	sp,sp,32
    80000de8:	8082                	ret

0000000080000dea <pop_off>:

void
pop_off(void)
{
    80000dea:	1141                	addi	sp,sp,-16
    80000dec:	e406                	sd	ra,8(sp)
    80000dee:	e022                	sd	s0,0(sp)
    80000df0:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000df2:	00001097          	auipc	ra,0x1
    80000df6:	01c080e7          	jalr	28(ra) # 80001e0e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000dfa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000dfe:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e00:	e78d                	bnez	a5,80000e2a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000e02:	5d3c                	lw	a5,120(a0)
    80000e04:	02f05b63          	blez	a5,80000e3a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000e08:	37fd                	addiw	a5,a5,-1
    80000e0a:	0007871b          	sext.w	a4,a5
    80000e0e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000e10:	eb09                	bnez	a4,80000e22 <pop_off+0x38>
    80000e12:	5d7c                	lw	a5,124(a0)
    80000e14:	c799                	beqz	a5,80000e22 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e16:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e1a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000e1e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000e22:	60a2                	ld	ra,8(sp)
    80000e24:	6402                	ld	s0,0(sp)
    80000e26:	0141                	addi	sp,sp,16
    80000e28:	8082                	ret
    panic("pop_off - interruptible");
    80000e2a:	00007517          	auipc	a0,0x7
    80000e2e:	24e50513          	addi	a0,a0,590 # 80008078 <digits+0x60>
    80000e32:	fffff097          	auipc	ra,0xfffff
    80000e36:	746080e7          	jalr	1862(ra) # 80000578 <panic>
    panic("pop_off");
    80000e3a:	00007517          	auipc	a0,0x7
    80000e3e:	25650513          	addi	a0,a0,598 # 80008090 <digits+0x78>
    80000e42:	fffff097          	auipc	ra,0xfffff
    80000e46:	736080e7          	jalr	1846(ra) # 80000578 <panic>

0000000080000e4a <release>:
{
    80000e4a:	1101                	addi	sp,sp,-32
    80000e4c:	ec06                	sd	ra,24(sp)
    80000e4e:	e822                	sd	s0,16(sp)
    80000e50:	e426                	sd	s1,8(sp)
    80000e52:	1000                	addi	s0,sp,32
    80000e54:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000e56:	00000097          	auipc	ra,0x0
    80000e5a:	eaa080e7          	jalr	-342(ra) # 80000d00 <holding>
    80000e5e:	c115                	beqz	a0,80000e82 <release+0x38>
  lk->cpu = 0;
    80000e60:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000e64:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000e68:	0f50000f          	fence	iorw,ow
    80000e6c:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000e70:	00000097          	auipc	ra,0x0
    80000e74:	f7a080e7          	jalr	-134(ra) # 80000dea <pop_off>
}
    80000e78:	60e2                	ld	ra,24(sp)
    80000e7a:	6442                	ld	s0,16(sp)
    80000e7c:	64a2                	ld	s1,8(sp)
    80000e7e:	6105                	addi	sp,sp,32
    80000e80:	8082                	ret
    panic("release");
    80000e82:	00007517          	auipc	a0,0x7
    80000e86:	21650513          	addi	a0,a0,534 # 80008098 <digits+0x80>
    80000e8a:	fffff097          	auipc	ra,0xfffff
    80000e8e:	6ee080e7          	jalr	1774(ra) # 80000578 <panic>

0000000080000e92 <freelock>:
{
    80000e92:	1101                	addi	sp,sp,-32
    80000e94:	ec06                	sd	ra,24(sp)
    80000e96:	e822                	sd	s0,16(sp)
    80000e98:	e426                	sd	s1,8(sp)
    80000e9a:	1000                	addi	s0,sp,32
    80000e9c:	84aa                	mv	s1,a0
  acquire(&lock_locks);
    80000e9e:	00010517          	auipc	a0,0x10
    80000ea2:	52a50513          	addi	a0,a0,1322 # 800113c8 <lock_locks>
    80000ea6:	00000097          	auipc	ra,0x0
    80000eaa:	ed4080e7          	jalr	-300(ra) # 80000d7a <acquire>
    if(locks[i] == lk) {
    80000eae:	00010797          	auipc	a5,0x10
    80000eb2:	53a78793          	addi	a5,a5,1338 # 800113e8 <locks>
    80000eb6:	639c                	ld	a5,0(a5)
    80000eb8:	02f48163          	beq	s1,a5,80000eda <freelock+0x48>
    80000ebc:	00010717          	auipc	a4,0x10
    80000ec0:	53470713          	addi	a4,a4,1332 # 800113f0 <locks+0x8>
  for (i = 0; i < NLOCK; i++) {
    80000ec4:	4785                	li	a5,1
    80000ec6:	1f400613          	li	a2,500
    if(locks[i] == lk) {
    80000eca:	6314                	ld	a3,0(a4)
    80000ecc:	00968863          	beq	a3,s1,80000edc <freelock+0x4a>
  for (i = 0; i < NLOCK; i++) {
    80000ed0:	2785                	addiw	a5,a5,1
    80000ed2:	0721                	addi	a4,a4,8
    80000ed4:	fec79be3          	bne	a5,a2,80000eca <freelock+0x38>
    80000ed8:	a811                	j	80000eec <freelock+0x5a>
    80000eda:	4781                	li	a5,0
      locks[i] = 0;
    80000edc:	078e                	slli	a5,a5,0x3
    80000ede:	00010717          	auipc	a4,0x10
    80000ee2:	50a70713          	addi	a4,a4,1290 # 800113e8 <locks>
    80000ee6:	97ba                	add	a5,a5,a4
    80000ee8:	0007b023          	sd	zero,0(a5)
  release(&lock_locks);
    80000eec:	00010517          	auipc	a0,0x10
    80000ef0:	4dc50513          	addi	a0,a0,1244 # 800113c8 <lock_locks>
    80000ef4:	00000097          	auipc	ra,0x0
    80000ef8:	f56080e7          	jalr	-170(ra) # 80000e4a <release>
}
    80000efc:	60e2                	ld	ra,24(sp)
    80000efe:	6442                	ld	s0,16(sp)
    80000f00:	64a2                	ld	s1,8(sp)
    80000f02:	6105                	addi	sp,sp,32
    80000f04:	8082                	ret

0000000080000f06 <initlock>:
{
    80000f06:	1101                	addi	sp,sp,-32
    80000f08:	ec06                	sd	ra,24(sp)
    80000f0a:	e822                	sd	s0,16(sp)
    80000f0c:	e426                	sd	s1,8(sp)
    80000f0e:	1000                	addi	s0,sp,32
    80000f10:	84aa                	mv	s1,a0
  lk->name = name;
    80000f12:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000f14:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000f18:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    80000f1c:	00052c23          	sw	zero,24(a0)
  lk->n = 0;
    80000f20:	00052e23          	sw	zero,28(a0)
  acquire(&lock_locks);
    80000f24:	00010517          	auipc	a0,0x10
    80000f28:	4a450513          	addi	a0,a0,1188 # 800113c8 <lock_locks>
    80000f2c:	00000097          	auipc	ra,0x0
    80000f30:	e4e080e7          	jalr	-434(ra) # 80000d7a <acquire>
    if(locks[i] == 0) {
    80000f34:	00010797          	auipc	a5,0x10
    80000f38:	4b478793          	addi	a5,a5,1204 # 800113e8 <locks>
    80000f3c:	639c                	ld	a5,0(a5)
    80000f3e:	c795                	beqz	a5,80000f6a <initlock+0x64>
    80000f40:	00010717          	auipc	a4,0x10
    80000f44:	4b070713          	addi	a4,a4,1200 # 800113f0 <locks+0x8>
  for (i = 0; i < NLOCK; i++) {
    80000f48:	4785                	li	a5,1
    80000f4a:	1f400613          	li	a2,500
    if(locks[i] == 0) {
    80000f4e:	6314                	ld	a3,0(a4)
    80000f50:	ce91                	beqz	a3,80000f6c <initlock+0x66>
  for (i = 0; i < NLOCK; i++) {
    80000f52:	2785                	addiw	a5,a5,1
    80000f54:	0721                	addi	a4,a4,8
    80000f56:	fec79ce3          	bne	a5,a2,80000f4e <initlock+0x48>
  panic("findslot");
    80000f5a:	00007517          	auipc	a0,0x7
    80000f5e:	14650513          	addi	a0,a0,326 # 800080a0 <digits+0x88>
    80000f62:	fffff097          	auipc	ra,0xfffff
    80000f66:	616080e7          	jalr	1558(ra) # 80000578 <panic>
  for (i = 0; i < NLOCK; i++) {
    80000f6a:	4781                	li	a5,0
      locks[i] = lk;
    80000f6c:	078e                	slli	a5,a5,0x3
    80000f6e:	00010717          	auipc	a4,0x10
    80000f72:	47a70713          	addi	a4,a4,1146 # 800113e8 <locks>
    80000f76:	97ba                	add	a5,a5,a4
    80000f78:	e384                	sd	s1,0(a5)
      release(&lock_locks);
    80000f7a:	00010517          	auipc	a0,0x10
    80000f7e:	44e50513          	addi	a0,a0,1102 # 800113c8 <lock_locks>
    80000f82:	00000097          	auipc	ra,0x0
    80000f86:	ec8080e7          	jalr	-312(ra) # 80000e4a <release>
}
    80000f8a:	60e2                	ld	ra,24(sp)
    80000f8c:	6442                	ld	s0,16(sp)
    80000f8e:	64a2                	ld	s1,8(sp)
    80000f90:	6105                	addi	sp,sp,32
    80000f92:	8082                	ret

0000000080000f94 <snprint_lock>:
#ifdef LAB_LOCK
int
snprint_lock(char *buf, int sz, struct spinlock *lk)
{
  int n = 0;
  if(lk->n > 0) {
    80000f94:	4e5c                	lw	a5,28(a2)
    80000f96:	00f04463          	bgtz	a5,80000f9e <snprint_lock+0xa>
  int n = 0;
    80000f9a:	4501                	li	a0,0
    n = snprintf(buf, sz, "lock: %s: #fetch-and-add %d #acquire() %d\n",
                 lk->name, lk->nts, lk->n);
  }
  return n;
}
    80000f9c:	8082                	ret
{
    80000f9e:	1141                	addi	sp,sp,-16
    80000fa0:	e406                	sd	ra,8(sp)
    80000fa2:	e022                	sd	s0,0(sp)
    80000fa4:	0800                	addi	s0,sp,16
    n = snprintf(buf, sz, "lock: %s: #fetch-and-add %d #acquire() %d\n",
    80000fa6:	4e18                	lw	a4,24(a2)
    80000fa8:	6614                	ld	a3,8(a2)
    80000faa:	00007617          	auipc	a2,0x7
    80000fae:	10660613          	addi	a2,a2,262 # 800080b0 <digits+0x98>
    80000fb2:	00006097          	auipc	ra,0x6
    80000fb6:	a02080e7          	jalr	-1534(ra) # 800069b4 <snprintf>
}
    80000fba:	60a2                	ld	ra,8(sp)
    80000fbc:	6402                	ld	s0,0(sp)
    80000fbe:	0141                	addi	sp,sp,16
    80000fc0:	8082                	ret

0000000080000fc2 <statslock>:

int
statslock(char *buf, int sz) {
    80000fc2:	711d                	addi	sp,sp,-96
    80000fc4:	ec86                	sd	ra,88(sp)
    80000fc6:	e8a2                	sd	s0,80(sp)
    80000fc8:	e4a6                	sd	s1,72(sp)
    80000fca:	e0ca                	sd	s2,64(sp)
    80000fcc:	fc4e                	sd	s3,56(sp)
    80000fce:	f852                	sd	s4,48(sp)
    80000fd0:	f456                	sd	s5,40(sp)
    80000fd2:	f05a                	sd	s6,32(sp)
    80000fd4:	ec5e                	sd	s7,24(sp)
    80000fd6:	e862                	sd	s8,16(sp)
    80000fd8:	e466                	sd	s9,8(sp)
    80000fda:	1080                	addi	s0,sp,96
    80000fdc:	8aaa                	mv	s5,a0
    80000fde:	8b2e                	mv	s6,a1
  int n;
  int tot = 0;

  acquire(&lock_locks);
    80000fe0:	00010517          	auipc	a0,0x10
    80000fe4:	3e850513          	addi	a0,a0,1000 # 800113c8 <lock_locks>
    80000fe8:	00000097          	auipc	ra,0x0
    80000fec:	d92080e7          	jalr	-622(ra) # 80000d7a <acquire>
  n = snprintf(buf, sz, "--- lock kmem/bcache stats\n");
    80000ff0:	00007617          	auipc	a2,0x7
    80000ff4:	0f060613          	addi	a2,a2,240 # 800080e0 <digits+0xc8>
    80000ff8:	85da                	mv	a1,s6
    80000ffa:	8556                	mv	a0,s5
    80000ffc:	00006097          	auipc	ra,0x6
    80001000:	9b8080e7          	jalr	-1608(ra) # 800069b4 <snprintf>
    80001004:	89aa                	mv	s3,a0
  for(int i = 0; i < NLOCK; i++) {
    if(locks[i] == 0)
    80001006:	00010797          	auipc	a5,0x10
    8000100a:	3e278793          	addi	a5,a5,994 # 800113e8 <locks>
    8000100e:	639c                	ld	a5,0(a5)
    80001010:	cbc1                	beqz	a5,800010a0 <statslock+0xde>
    80001012:	00010497          	auipc	s1,0x10
    80001016:	3d648493          	addi	s1,s1,982 # 800113e8 <locks>
    8000101a:	00011c17          	auipc	s8,0x11
    8000101e:	366c0c13          	addi	s8,s8,870 # 80012380 <locks+0xf98>
  int tot = 0;
    80001022:	4a01                	li	s4,0
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80001024:	00007917          	auipc	s2,0x7
    80001028:	0dc90913          	addi	s2,s2,220 # 80008100 <digits+0xe8>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    8000102c:	00007c97          	auipc	s9,0x7
    80001030:	03cc8c93          	addi	s9,s9,60 # 80008068 <digits+0x50>
    80001034:	a025                	j	8000105c <statslock+0x9a>
      tot += locks[i]->nts;
    80001036:	6090                	ld	a2,0(s1)
    80001038:	4e1c                	lw	a5,24(a2)
    8000103a:	01478a3b          	addw	s4,a5,s4
      n += snprint_lock(buf +n, sz-n, locks[i]);
    8000103e:	413b05bb          	subw	a1,s6,s3
    80001042:	013a8533          	add	a0,s5,s3
    80001046:	00000097          	auipc	ra,0x0
    8000104a:	f4e080e7          	jalr	-178(ra) # 80000f94 <snprint_lock>
    8000104e:	013509bb          	addw	s3,a0,s3
  for(int i = 0; i < NLOCK; i++) {
    80001052:	05848863          	beq	s1,s8,800010a2 <statslock+0xe0>
    if(locks[i] == 0)
    80001056:	04a1                	addi	s1,s1,8
    80001058:	609c                	ld	a5,0(s1)
    8000105a:	c7a1                	beqz	a5,800010a2 <statslock+0xe0>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    8000105c:	0087bb83          	ld	s7,8(a5)
    80001060:	854a                	mv	a0,s2
    80001062:	00000097          	auipc	ra,0x0
    80001066:	2ce080e7          	jalr	718(ra) # 80001330 <strlen>
    8000106a:	0005061b          	sext.w	a2,a0
    8000106e:	85ca                	mv	a1,s2
    80001070:	855e                	mv	a0,s7
    80001072:	00000097          	auipc	ra,0x0
    80001076:	1fc080e7          	jalr	508(ra) # 8000126e <strncmp>
    8000107a:	dd55                	beqz	a0,80001036 <statslock+0x74>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    8000107c:	609c                	ld	a5,0(s1)
    8000107e:	0087bb83          	ld	s7,8(a5)
    80001082:	8566                	mv	a0,s9
    80001084:	00000097          	auipc	ra,0x0
    80001088:	2ac080e7          	jalr	684(ra) # 80001330 <strlen>
    8000108c:	0005061b          	sext.w	a2,a0
    80001090:	85e6                	mv	a1,s9
    80001092:	855e                	mv	a0,s7
    80001094:	00000097          	auipc	ra,0x0
    80001098:	1da080e7          	jalr	474(ra) # 8000126e <strncmp>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    8000109c:	f95d                	bnez	a0,80001052 <statslock+0x90>
    8000109e:	bf61                	j	80001036 <statslock+0x74>
  int tot = 0;
    800010a0:	4a01                	li	s4,0
    }
  }
  
  n += snprintf(buf+n, sz-n, "--- top 5 contended locks:\n");
    800010a2:	00007617          	auipc	a2,0x7
    800010a6:	06660613          	addi	a2,a2,102 # 80008108 <digits+0xf0>
    800010aa:	413b05bb          	subw	a1,s6,s3
    800010ae:	013a8533          	add	a0,s5,s3
    800010b2:	00006097          	auipc	ra,0x6
    800010b6:	902080e7          	jalr	-1790(ra) # 800069b4 <snprintf>
    800010ba:	013509bb          	addw	s3,a0,s3
    800010be:	4b95                	li	s7,5
  int last = 100000000;
    800010c0:	05f5e537          	lui	a0,0x5f5e
    800010c4:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t = 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
      if(locks[i] == 0)
    800010c8:	00010497          	auipc	s1,0x10
    800010cc:	32048493          	addi	s1,s1,800 # 800113e8 <locks>
    for(int i = 0; i < NLOCK; i++) {
    800010d0:	4c01                	li	s8,0
    800010d2:	1f400913          	li	s2,500
    800010d6:	a891                	j	8000112a <statslock+0x168>
    800010d8:	2705                	addiw	a4,a4,1
    800010da:	03270363          	beq	a4,s2,80001100 <statslock+0x13e>
      if(locks[i] == 0)
    800010de:	06a1                	addi	a3,a3,8
    800010e0:	ff86b783          	ld	a5,-8(a3)
    800010e4:	cf91                	beqz	a5,80001100 <statslock+0x13e>
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    800010e6:	4f90                	lw	a2,24(a5)
    800010e8:	00359793          	slli	a5,a1,0x3
    800010ec:	97a6                	add	a5,a5,s1
    800010ee:	639c                	ld	a5,0(a5)
    800010f0:	4f9c                	lw	a5,24(a5)
    800010f2:	fec7d3e3          	ble	a2,a5,800010d8 <statslock+0x116>
    800010f6:	fea651e3          	ble	a0,a2,800010d8 <statslock+0x116>
    800010fa:	85ba                	mv	a1,a4
    800010fc:	bff1                	j	800010d8 <statslock+0x116>
    int top = 0;
    800010fe:	85e2                	mv	a1,s8
        top = i;
      }
    }
    n += snprint_lock(buf+n, sz-n, locks[top]);
    80001100:	058e                	slli	a1,a1,0x3
    80001102:	00b48cb3          	add	s9,s1,a1
    80001106:	000cb603          	ld	a2,0(s9)
    8000110a:	413b05bb          	subw	a1,s6,s3
    8000110e:	013a8533          	add	a0,s5,s3
    80001112:	00000097          	auipc	ra,0x0
    80001116:	e82080e7          	jalr	-382(ra) # 80000f94 <snprint_lock>
    8000111a:	013509bb          	addw	s3,a0,s3
    last = locks[top]->nts;
    8000111e:	000cb783          	ld	a5,0(s9)
    80001122:	4f88                	lw	a0,24(a5)
  for(int t = 0; t < 5; t++) {
    80001124:	3bfd                	addiw	s7,s7,-1
    80001126:	000b8b63          	beqz	s7,8000113c <statslock+0x17a>
      if(locks[i] == 0)
    8000112a:	609c                	ld	a5,0(s1)
    8000112c:	dbe9                	beqz	a5,800010fe <statslock+0x13c>
    8000112e:	00010697          	auipc	a3,0x10
    80001132:	2c268693          	addi	a3,a3,706 # 800113f0 <locks+0x8>
    for(int i = 0; i < NLOCK; i++) {
    80001136:	8762                	mv	a4,s8
    int top = 0;
    80001138:	85e2                	mv	a1,s8
    8000113a:	b775                	j	800010e6 <statslock+0x124>
  }
  n += snprintf(buf+n, sz-n, "tot= %d\n", tot);
    8000113c:	86d2                	mv	a3,s4
    8000113e:	00007617          	auipc	a2,0x7
    80001142:	fea60613          	addi	a2,a2,-22 # 80008128 <digits+0x110>
    80001146:	413b05bb          	subw	a1,s6,s3
    8000114a:	013a8533          	add	a0,s5,s3
    8000114e:	00006097          	auipc	ra,0x6
    80001152:	866080e7          	jalr	-1946(ra) # 800069b4 <snprintf>
    80001156:	013509bb          	addw	s3,a0,s3
  release(&lock_locks);  
    8000115a:	00010517          	auipc	a0,0x10
    8000115e:	26e50513          	addi	a0,a0,622 # 800113c8 <lock_locks>
    80001162:	00000097          	auipc	ra,0x0
    80001166:	ce8080e7          	jalr	-792(ra) # 80000e4a <release>
  return n;
}
    8000116a:	854e                	mv	a0,s3
    8000116c:	60e6                	ld	ra,88(sp)
    8000116e:	6446                	ld	s0,80(sp)
    80001170:	64a6                	ld	s1,72(sp)
    80001172:	6906                	ld	s2,64(sp)
    80001174:	79e2                	ld	s3,56(sp)
    80001176:	7a42                	ld	s4,48(sp)
    80001178:	7aa2                	ld	s5,40(sp)
    8000117a:	7b02                	ld	s6,32(sp)
    8000117c:	6be2                	ld	s7,24(sp)
    8000117e:	6c42                	ld	s8,16(sp)
    80001180:	6ca2                	ld	s9,8(sp)
    80001182:	6125                	addi	sp,sp,96
    80001184:	8082                	ret

0000000080001186 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80001186:	1141                	addi	sp,sp,-16
    80001188:	e422                	sd	s0,8(sp)
    8000118a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    8000118c:	ce09                	beqz	a2,800011a6 <memset+0x20>
    8000118e:	87aa                	mv	a5,a0
    80001190:	fff6071b          	addiw	a4,a2,-1
    80001194:	1702                	slli	a4,a4,0x20
    80001196:	9301                	srli	a4,a4,0x20
    80001198:	0705                	addi	a4,a4,1
    8000119a:	972a                	add	a4,a4,a0
    cdst[i] = c;
    8000119c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800011a0:	0785                	addi	a5,a5,1
    800011a2:	fee79de3          	bne	a5,a4,8000119c <memset+0x16>
  }
  return dst;
}
    800011a6:	6422                	ld	s0,8(sp)
    800011a8:	0141                	addi	sp,sp,16
    800011aa:	8082                	ret

00000000800011ac <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800011ac:	1141                	addi	sp,sp,-16
    800011ae:	e422                	sd	s0,8(sp)
    800011b0:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800011b2:	ce15                	beqz	a2,800011ee <memcmp+0x42>
    800011b4:	fff6069b          	addiw	a3,a2,-1
    if(*s1 != *s2)
    800011b8:	00054783          	lbu	a5,0(a0)
    800011bc:	0005c703          	lbu	a4,0(a1)
    800011c0:	02e79063          	bne	a5,a4,800011e0 <memcmp+0x34>
    800011c4:	1682                	slli	a3,a3,0x20
    800011c6:	9281                	srli	a3,a3,0x20
    800011c8:	0685                	addi	a3,a3,1
    800011ca:	96aa                	add	a3,a3,a0
      return *s1 - *s2;
    s1++, s2++;
    800011cc:	0505                	addi	a0,a0,1
    800011ce:	0585                	addi	a1,a1,1
  while(n-- > 0){
    800011d0:	00d50d63          	beq	a0,a3,800011ea <memcmp+0x3e>
    if(*s1 != *s2)
    800011d4:	00054783          	lbu	a5,0(a0)
    800011d8:	0005c703          	lbu	a4,0(a1)
    800011dc:	fee788e3          	beq	a5,a4,800011cc <memcmp+0x20>
      return *s1 - *s2;
    800011e0:	40e7853b          	subw	a0,a5,a4
  }

  return 0;
}
    800011e4:	6422                	ld	s0,8(sp)
    800011e6:	0141                	addi	sp,sp,16
    800011e8:	8082                	ret
  return 0;
    800011ea:	4501                	li	a0,0
    800011ec:	bfe5                	j	800011e4 <memcmp+0x38>
    800011ee:	4501                	li	a0,0
    800011f0:	bfd5                	j	800011e4 <memcmp+0x38>

00000000800011f2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800011f2:	1141                	addi	sp,sp,-16
    800011f4:	e422                	sd	s0,8(sp)
    800011f6:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    800011f8:	00a5f963          	bleu	a0,a1,8000120a <memmove+0x18>
    800011fc:	02061713          	slli	a4,a2,0x20
    80001200:	9301                	srli	a4,a4,0x20
    80001202:	00e587b3          	add	a5,a1,a4
    80001206:	02f56563          	bltu	a0,a5,80001230 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    8000120a:	fff6069b          	addiw	a3,a2,-1
    8000120e:	ce11                	beqz	a2,8000122a <memmove+0x38>
    80001210:	1682                	slli	a3,a3,0x20
    80001212:	9281                	srli	a3,a3,0x20
    80001214:	0685                	addi	a3,a3,1
    80001216:	96ae                	add	a3,a3,a1
    80001218:	87aa                	mv	a5,a0
      *d++ = *s++;
    8000121a:	0585                	addi	a1,a1,1
    8000121c:	0785                	addi	a5,a5,1
    8000121e:	fff5c703          	lbu	a4,-1(a1)
    80001222:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80001226:	fed59ae3          	bne	a1,a3,8000121a <memmove+0x28>

  return dst;
}
    8000122a:	6422                	ld	s0,8(sp)
    8000122c:	0141                	addi	sp,sp,16
    8000122e:	8082                	ret
    d += n;
    80001230:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80001232:	fff6069b          	addiw	a3,a2,-1
    80001236:	da75                	beqz	a2,8000122a <memmove+0x38>
    80001238:	02069613          	slli	a2,a3,0x20
    8000123c:	9201                	srli	a2,a2,0x20
    8000123e:	fff64613          	not	a2,a2
    80001242:	963e                	add	a2,a2,a5
      *--d = *--s;
    80001244:	17fd                	addi	a5,a5,-1
    80001246:	177d                	addi	a4,a4,-1
    80001248:	0007c683          	lbu	a3,0(a5)
    8000124c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80001250:	fef61ae3          	bne	a2,a5,80001244 <memmove+0x52>
    80001254:	bfd9                	j	8000122a <memmove+0x38>

0000000080001256 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80001256:	1141                	addi	sp,sp,-16
    80001258:	e406                	sd	ra,8(sp)
    8000125a:	e022                	sd	s0,0(sp)
    8000125c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	f94080e7          	jalr	-108(ra) # 800011f2 <memmove>
}
    80001266:	60a2                	ld	ra,8(sp)
    80001268:	6402                	ld	s0,0(sp)
    8000126a:	0141                	addi	sp,sp,16
    8000126c:	8082                	ret

000000008000126e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000126e:	1141                	addi	sp,sp,-16
    80001270:	e422                	sd	s0,8(sp)
    80001272:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80001274:	c229                	beqz	a2,800012b6 <strncmp+0x48>
    80001276:	00054783          	lbu	a5,0(a0)
    8000127a:	c795                	beqz	a5,800012a6 <strncmp+0x38>
    8000127c:	0005c703          	lbu	a4,0(a1)
    80001280:	02f71363          	bne	a4,a5,800012a6 <strncmp+0x38>
    80001284:	fff6071b          	addiw	a4,a2,-1
    80001288:	1702                	slli	a4,a4,0x20
    8000128a:	9301                	srli	a4,a4,0x20
    8000128c:	0705                	addi	a4,a4,1
    8000128e:	972a                	add	a4,a4,a0
    n--, p++, q++;
    80001290:	0505                	addi	a0,a0,1
    80001292:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80001294:	02e50363          	beq	a0,a4,800012ba <strncmp+0x4c>
    80001298:	00054783          	lbu	a5,0(a0)
    8000129c:	c789                	beqz	a5,800012a6 <strncmp+0x38>
    8000129e:	0005c683          	lbu	a3,0(a1)
    800012a2:	fef687e3          	beq	a3,a5,80001290 <strncmp+0x22>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
    800012a6:	00054503          	lbu	a0,0(a0)
    800012aa:	0005c783          	lbu	a5,0(a1)
    800012ae:	9d1d                	subw	a0,a0,a5
}
    800012b0:	6422                	ld	s0,8(sp)
    800012b2:	0141                	addi	sp,sp,16
    800012b4:	8082                	ret
    return 0;
    800012b6:	4501                	li	a0,0
    800012b8:	bfe5                	j	800012b0 <strncmp+0x42>
    800012ba:	4501                	li	a0,0
    800012bc:	bfd5                	j	800012b0 <strncmp+0x42>

00000000800012be <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800012be:	1141                	addi	sp,sp,-16
    800012c0:	e422                	sd	s0,8(sp)
    800012c2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800012c4:	872a                	mv	a4,a0
    800012c6:	a011                	j	800012ca <strncpy+0xc>
    800012c8:	8636                	mv	a2,a3
    800012ca:	fff6069b          	addiw	a3,a2,-1
    800012ce:	00c05963          	blez	a2,800012e0 <strncpy+0x22>
    800012d2:	0705                	addi	a4,a4,1
    800012d4:	0005c783          	lbu	a5,0(a1)
    800012d8:	fef70fa3          	sb	a5,-1(a4)
    800012dc:	0585                	addi	a1,a1,1
    800012de:	f7ed                	bnez	a5,800012c8 <strncpy+0xa>
    ;
  while(n-- > 0)
    800012e0:	00d05c63          	blez	a3,800012f8 <strncpy+0x3a>
    800012e4:	86ba                	mv	a3,a4
    *s++ = 0;
    800012e6:	0685                	addi	a3,a3,1
    800012e8:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800012ec:	fff6c793          	not	a5,a3
    800012f0:	9fb9                	addw	a5,a5,a4
    800012f2:	9fb1                	addw	a5,a5,a2
    800012f4:	fef049e3          	bgtz	a5,800012e6 <strncpy+0x28>
  return os;
}
    800012f8:	6422                	ld	s0,8(sp)
    800012fa:	0141                	addi	sp,sp,16
    800012fc:	8082                	ret

00000000800012fe <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800012fe:	1141                	addi	sp,sp,-16
    80001300:	e422                	sd	s0,8(sp)
    80001302:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80001304:	02c05363          	blez	a2,8000132a <safestrcpy+0x2c>
    80001308:	fff6069b          	addiw	a3,a2,-1
    8000130c:	1682                	slli	a3,a3,0x20
    8000130e:	9281                	srli	a3,a3,0x20
    80001310:	96ae                	add	a3,a3,a1
    80001312:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001314:	00d58963          	beq	a1,a3,80001326 <safestrcpy+0x28>
    80001318:	0585                	addi	a1,a1,1
    8000131a:	0785                	addi	a5,a5,1
    8000131c:	fff5c703          	lbu	a4,-1(a1)
    80001320:	fee78fa3          	sb	a4,-1(a5)
    80001324:	fb65                	bnez	a4,80001314 <safestrcpy+0x16>
    ;
  *s = 0;
    80001326:	00078023          	sb	zero,0(a5)
  return os;
}
    8000132a:	6422                	ld	s0,8(sp)
    8000132c:	0141                	addi	sp,sp,16
    8000132e:	8082                	ret

0000000080001330 <strlen>:

int
strlen(const char *s)
{
    80001330:	1141                	addi	sp,sp,-16
    80001332:	e422                	sd	s0,8(sp)
    80001334:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001336:	00054783          	lbu	a5,0(a0)
    8000133a:	cf91                	beqz	a5,80001356 <strlen+0x26>
    8000133c:	0505                	addi	a0,a0,1
    8000133e:	87aa                	mv	a5,a0
    80001340:	4685                	li	a3,1
    80001342:	9e89                	subw	a3,a3,a0
    80001344:	00f6853b          	addw	a0,a3,a5
    80001348:	0785                	addi	a5,a5,1
    8000134a:	fff7c703          	lbu	a4,-1(a5)
    8000134e:	fb7d                	bnez	a4,80001344 <strlen+0x14>
    ;
  return n;
}
    80001350:	6422                	ld	s0,8(sp)
    80001352:	0141                	addi	sp,sp,16
    80001354:	8082                	ret
  for(n = 0; s[n]; n++)
    80001356:	4501                	li	a0,0
    80001358:	bfe5                	j	80001350 <strlen+0x20>

000000008000135a <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    8000135a:	1141                	addi	sp,sp,-16
    8000135c:	e406                	sd	ra,8(sp)
    8000135e:	e022                	sd	s0,0(sp)
    80001360:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001362:	00001097          	auipc	ra,0x1
    80001366:	a9c080e7          	jalr	-1380(ra) # 80001dfe <cpuid>
#endif    
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000136a:	00008717          	auipc	a4,0x8
    8000136e:	ca270713          	addi	a4,a4,-862 # 8000900c <started>
  if(cpuid() == 0){
    80001372:	c139                	beqz	a0,800013b8 <main+0x5e>
    while(started == 0)
    80001374:	431c                	lw	a5,0(a4)
    80001376:	2781                	sext.w	a5,a5
    80001378:	dff5                	beqz	a5,80001374 <main+0x1a>
      ;
    __sync_synchronize();
    8000137a:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000137e:	00001097          	auipc	ra,0x1
    80001382:	a80080e7          	jalr	-1408(ra) # 80001dfe <cpuid>
    80001386:	85aa                	mv	a1,a0
    80001388:	00007517          	auipc	a0,0x7
    8000138c:	dc850513          	addi	a0,a0,-568 # 80008150 <digits+0x138>
    80001390:	fffff097          	auipc	ra,0xfffff
    80001394:	232080e7          	jalr	562(ra) # 800005c2 <printf>
    kvminithart();    // turn on paging
    80001398:	00000097          	auipc	ra,0x0
    8000139c:	186080e7          	jalr	390(ra) # 8000151e <kvminithart>
    trapinithart();   // install kernel trap vector
    800013a0:	00001097          	auipc	ra,0x1
    800013a4:	6f4080e7          	jalr	1780(ra) # 80002a94 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800013a8:	00005097          	auipc	ra,0x5
    800013ac:	e28080e7          	jalr	-472(ra) # 800061d0 <plicinithart>
  }

  scheduler();        
    800013b0:	00001097          	auipc	ra,0x1
    800013b4:	fb0080e7          	jalr	-80(ra) # 80002360 <scheduler>
    consoleinit();
    800013b8:	fffff097          	auipc	ra,0xfffff
    800013bc:	0ce080e7          	jalr	206(ra) # 80000486 <consoleinit>
    statsinit();
    800013c0:	00005097          	auipc	ra,0x5
    800013c4:	514080e7          	jalr	1300(ra) # 800068d4 <statsinit>
    printfinit();
    800013c8:	fffff097          	auipc	ra,0xfffff
    800013cc:	3e0080e7          	jalr	992(ra) # 800007a8 <printfinit>
    printf("\n");
    800013d0:	00007517          	auipc	a0,0x7
    800013d4:	d9050513          	addi	a0,a0,-624 # 80008160 <digits+0x148>
    800013d8:	fffff097          	auipc	ra,0xfffff
    800013dc:	1ea080e7          	jalr	490(ra) # 800005c2 <printf>
    printf("xv6 kernel is booting\n");
    800013e0:	00007517          	auipc	a0,0x7
    800013e4:	d5850513          	addi	a0,a0,-680 # 80008138 <digits+0x120>
    800013e8:	fffff097          	auipc	ra,0xfffff
    800013ec:	1da080e7          	jalr	474(ra) # 800005c2 <printf>
    printf("\n");
    800013f0:	00007517          	auipc	a0,0x7
    800013f4:	d7050513          	addi	a0,a0,-656 # 80008160 <digits+0x148>
    800013f8:	fffff097          	auipc	ra,0xfffff
    800013fc:	1ca080e7          	jalr	458(ra) # 800005c2 <printf>
    kinit();         // physical page allocator
    80001400:	fffff097          	auipc	ra,0xfffff
    80001404:	76e080e7          	jalr	1902(ra) # 80000b6e <kinit>
    kvminit();       // create kernel page table
    80001408:	00000097          	auipc	ra,0x0
    8000140c:	244080e7          	jalr	580(ra) # 8000164c <kvminit>
    kvminithart();   // turn on paging
    80001410:	00000097          	auipc	ra,0x0
    80001414:	10e080e7          	jalr	270(ra) # 8000151e <kvminithart>
    procinit();      // process table
    80001418:	00001097          	auipc	ra,0x1
    8000141c:	916080e7          	jalr	-1770(ra) # 80001d2e <procinit>
    trapinit();      // trap vectors
    80001420:	00001097          	auipc	ra,0x1
    80001424:	64c080e7          	jalr	1612(ra) # 80002a6c <trapinit>
    trapinithart();  // install kernel trap vector
    80001428:	00001097          	auipc	ra,0x1
    8000142c:	66c080e7          	jalr	1644(ra) # 80002a94 <trapinithart>
    plicinit();      // set up interrupt controller
    80001430:	00005097          	auipc	ra,0x5
    80001434:	d8a080e7          	jalr	-630(ra) # 800061ba <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001438:	00005097          	auipc	ra,0x5
    8000143c:	d98080e7          	jalr	-616(ra) # 800061d0 <plicinithart>
    binit();         // buffer cache
    80001440:	00002097          	auipc	ra,0x2
    80001444:	db6080e7          	jalr	-586(ra) # 800031f6 <binit>
    iinit();         // inode cache
    80001448:	00002097          	auipc	ra,0x2
    8000144c:	520080e7          	jalr	1312(ra) # 80003968 <iinit>
    fileinit();      // file table
    80001450:	00003097          	auipc	ra,0x3
    80001454:	4fc080e7          	jalr	1276(ra) # 8000494c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001458:	00005097          	auipc	ra,0x5
    8000145c:	e9a080e7          	jalr	-358(ra) # 800062f2 <virtio_disk_init>
    userinit();      // first user process
    80001460:	00001097          	auipc	ra,0x1
    80001464:	c96080e7          	jalr	-874(ra) # 800020f6 <userinit>
    __sync_synchronize();
    80001468:	0ff0000f          	fence
    started = 1;
    8000146c:	4785                	li	a5,1
    8000146e:	00008717          	auipc	a4,0x8
    80001472:	b8f72f23          	sw	a5,-1122(a4) # 8000900c <started>
    80001476:	bf2d                	j	800013b0 <main+0x56>

0000000080001478 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001478:	7139                	addi	sp,sp,-64
    8000147a:	fc06                	sd	ra,56(sp)
    8000147c:	f822                	sd	s0,48(sp)
    8000147e:	f426                	sd	s1,40(sp)
    80001480:	f04a                	sd	s2,32(sp)
    80001482:	ec4e                	sd	s3,24(sp)
    80001484:	e852                	sd	s4,16(sp)
    80001486:	e456                	sd	s5,8(sp)
    80001488:	e05a                	sd	s6,0(sp)
    8000148a:	0080                	addi	s0,sp,64
    8000148c:	84aa                	mv	s1,a0
    8000148e:	89ae                	mv	s3,a1
    80001490:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80001492:	57fd                	li	a5,-1
    80001494:	83e9                	srli	a5,a5,0x1a
    80001496:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001498:	4ab1                	li	s5,12
  if(va >= MAXVA)
    8000149a:	04b7f263          	bleu	a1,a5,800014de <walk+0x66>
    panic("walk");
    8000149e:	00007517          	auipc	a0,0x7
    800014a2:	cca50513          	addi	a0,a0,-822 # 80008168 <digits+0x150>
    800014a6:	fffff097          	auipc	ra,0xfffff
    800014aa:	0d2080e7          	jalr	210(ra) # 80000578 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800014ae:	060b0663          	beqz	s6,8000151a <walk+0xa2>
    800014b2:	fffff097          	auipc	ra,0xfffff
    800014b6:	7b8080e7          	jalr	1976(ra) # 80000c6a <kalloc>
    800014ba:	84aa                	mv	s1,a0
    800014bc:	c529                	beqz	a0,80001506 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800014be:	6605                	lui	a2,0x1
    800014c0:	4581                	li	a1,0
    800014c2:	00000097          	auipc	ra,0x0
    800014c6:	cc4080e7          	jalr	-828(ra) # 80001186 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800014ca:	00c4d793          	srli	a5,s1,0xc
    800014ce:	07aa                	slli	a5,a5,0xa
    800014d0:	0017e793          	ori	a5,a5,1
    800014d4:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800014d8:	3a5d                	addiw	s4,s4,-9
    800014da:	035a0063          	beq	s4,s5,800014fa <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800014de:	0149d933          	srl	s2,s3,s4
    800014e2:	1ff97913          	andi	s2,s2,511
    800014e6:	090e                	slli	s2,s2,0x3
    800014e8:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800014ea:	00093483          	ld	s1,0(s2)
    800014ee:	0014f793          	andi	a5,s1,1
    800014f2:	dfd5                	beqz	a5,800014ae <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800014f4:	80a9                	srli	s1,s1,0xa
    800014f6:	04b2                	slli	s1,s1,0xc
    800014f8:	b7c5                	j	800014d8 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800014fa:	00c9d513          	srli	a0,s3,0xc
    800014fe:	1ff57513          	andi	a0,a0,511
    80001502:	050e                	slli	a0,a0,0x3
    80001504:	9526                	add	a0,a0,s1
}
    80001506:	70e2                	ld	ra,56(sp)
    80001508:	7442                	ld	s0,48(sp)
    8000150a:	74a2                	ld	s1,40(sp)
    8000150c:	7902                	ld	s2,32(sp)
    8000150e:	69e2                	ld	s3,24(sp)
    80001510:	6a42                	ld	s4,16(sp)
    80001512:	6aa2                	ld	s5,8(sp)
    80001514:	6b02                	ld	s6,0(sp)
    80001516:	6121                	addi	sp,sp,64
    80001518:	8082                	ret
        return 0;
    8000151a:	4501                	li	a0,0
    8000151c:	b7ed                	j	80001506 <walk+0x8e>

000000008000151e <kvminithart>:
{
    8000151e:	1141                	addi	sp,sp,-16
    80001520:	e422                	sd	s0,8(sp)
    80001522:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001524:	00008797          	auipc	a5,0x8
    80001528:	aec78793          	addi	a5,a5,-1300 # 80009010 <kernel_pagetable>
    8000152c:	639c                	ld	a5,0(a5)
    8000152e:	83b1                	srli	a5,a5,0xc
    80001530:	577d                	li	a4,-1
    80001532:	177e                	slli	a4,a4,0x3f
    80001534:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001536:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000153a:	12000073          	sfence.vma
}
    8000153e:	6422                	ld	s0,8(sp)
    80001540:	0141                	addi	sp,sp,16
    80001542:	8082                	ret

0000000080001544 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001544:	57fd                	li	a5,-1
    80001546:	83e9                	srli	a5,a5,0x1a
    80001548:	00b7f463          	bleu	a1,a5,80001550 <walkaddr+0xc>
    return 0;
    8000154c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000154e:	8082                	ret
{
    80001550:	1141                	addi	sp,sp,-16
    80001552:	e406                	sd	ra,8(sp)
    80001554:	e022                	sd	s0,0(sp)
    80001556:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001558:	4601                	li	a2,0
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	f1e080e7          	jalr	-226(ra) # 80001478 <walk>
  if(pte == 0)
    80001562:	c105                	beqz	a0,80001582 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001564:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001566:	0117f693          	andi	a3,a5,17
    8000156a:	4745                	li	a4,17
    return 0;
    8000156c:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000156e:	00e68663          	beq	a3,a4,8000157a <walkaddr+0x36>
}
    80001572:	60a2                	ld	ra,8(sp)
    80001574:	6402                	ld	s0,0(sp)
    80001576:	0141                	addi	sp,sp,16
    80001578:	8082                	ret
  pa = PTE2PA(*pte);
    8000157a:	00a7d513          	srli	a0,a5,0xa
    8000157e:	0532                	slli	a0,a0,0xc
  return pa;
    80001580:	bfcd                	j	80001572 <walkaddr+0x2e>
    return 0;
    80001582:	4501                	li	a0,0
    80001584:	b7fd                	j	80001572 <walkaddr+0x2e>

0000000080001586 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001586:	715d                	addi	sp,sp,-80
    80001588:	e486                	sd	ra,72(sp)
    8000158a:	e0a2                	sd	s0,64(sp)
    8000158c:	fc26                	sd	s1,56(sp)
    8000158e:	f84a                	sd	s2,48(sp)
    80001590:	f44e                	sd	s3,40(sp)
    80001592:	f052                	sd	s4,32(sp)
    80001594:	ec56                	sd	s5,24(sp)
    80001596:	e85a                	sd	s6,16(sp)
    80001598:	e45e                	sd	s7,8(sp)
    8000159a:	0880                	addi	s0,sp,80
    8000159c:	8aaa                	mv	s5,a0
    8000159e:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800015a0:	79fd                	lui	s3,0xfffff
    800015a2:	0135fa33          	and	s4,a1,s3
  last = PGROUNDDOWN(va + size - 1);
    800015a6:	167d                	addi	a2,a2,-1
    800015a8:	962e                	add	a2,a2,a1
    800015aa:	013679b3          	and	s3,a2,s3
  a = PGROUNDDOWN(va);
    800015ae:	8952                	mv	s2,s4
    800015b0:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800015b4:	6b85                	lui	s7,0x1
    800015b6:	a811                	j	800015ca <mappages+0x44>
      panic("remap");
    800015b8:	00007517          	auipc	a0,0x7
    800015bc:	bb850513          	addi	a0,a0,-1096 # 80008170 <digits+0x158>
    800015c0:	fffff097          	auipc	ra,0xfffff
    800015c4:	fb8080e7          	jalr	-72(ra) # 80000578 <panic>
    a += PGSIZE;
    800015c8:	995e                	add	s2,s2,s7
  for(;;){
    800015ca:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800015ce:	4605                	li	a2,1
    800015d0:	85ca                	mv	a1,s2
    800015d2:	8556                	mv	a0,s5
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	ea4080e7          	jalr	-348(ra) # 80001478 <walk>
    800015dc:	cd19                	beqz	a0,800015fa <mappages+0x74>
    if(*pte & PTE_V)
    800015de:	611c                	ld	a5,0(a0)
    800015e0:	8b85                	andi	a5,a5,1
    800015e2:	fbf9                	bnez	a5,800015b8 <mappages+0x32>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800015e4:	80b1                	srli	s1,s1,0xc
    800015e6:	04aa                	slli	s1,s1,0xa
    800015e8:	0164e4b3          	or	s1,s1,s6
    800015ec:	0014e493          	ori	s1,s1,1
    800015f0:	e104                	sd	s1,0(a0)
    if(a == last)
    800015f2:	fd391be3          	bne	s2,s3,800015c8 <mappages+0x42>
    pa += PGSIZE;
  }
  return 0;
    800015f6:	4501                	li	a0,0
    800015f8:	a011                	j	800015fc <mappages+0x76>
      return -1;
    800015fa:	557d                	li	a0,-1
}
    800015fc:	60a6                	ld	ra,72(sp)
    800015fe:	6406                	ld	s0,64(sp)
    80001600:	74e2                	ld	s1,56(sp)
    80001602:	7942                	ld	s2,48(sp)
    80001604:	79a2                	ld	s3,40(sp)
    80001606:	7a02                	ld	s4,32(sp)
    80001608:	6ae2                	ld	s5,24(sp)
    8000160a:	6b42                	ld	s6,16(sp)
    8000160c:	6ba2                	ld	s7,8(sp)
    8000160e:	6161                	addi	sp,sp,80
    80001610:	8082                	ret

0000000080001612 <kvmmap>:
{
    80001612:	1141                	addi	sp,sp,-16
    80001614:	e406                	sd	ra,8(sp)
    80001616:	e022                	sd	s0,0(sp)
    80001618:	0800                	addi	s0,sp,16
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    8000161a:	8736                	mv	a4,a3
    8000161c:	86ae                	mv	a3,a1
    8000161e:	85aa                	mv	a1,a0
    80001620:	00008797          	auipc	a5,0x8
    80001624:	9f078793          	addi	a5,a5,-1552 # 80009010 <kernel_pagetable>
    80001628:	6388                	ld	a0,0(a5)
    8000162a:	00000097          	auipc	ra,0x0
    8000162e:	f5c080e7          	jalr	-164(ra) # 80001586 <mappages>
    80001632:	e509                	bnez	a0,8000163c <kvmmap+0x2a>
}
    80001634:	60a2                	ld	ra,8(sp)
    80001636:	6402                	ld	s0,0(sp)
    80001638:	0141                	addi	sp,sp,16
    8000163a:	8082                	ret
    panic("kvmmap");
    8000163c:	00007517          	auipc	a0,0x7
    80001640:	b3c50513          	addi	a0,a0,-1220 # 80008178 <digits+0x160>
    80001644:	fffff097          	auipc	ra,0xfffff
    80001648:	f34080e7          	jalr	-204(ra) # 80000578 <panic>

000000008000164c <kvminit>:
{
    8000164c:	1101                	addi	sp,sp,-32
    8000164e:	ec06                	sd	ra,24(sp)
    80001650:	e822                	sd	s0,16(sp)
    80001652:	e426                	sd	s1,8(sp)
    80001654:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001656:	fffff097          	auipc	ra,0xfffff
    8000165a:	614080e7          	jalr	1556(ra) # 80000c6a <kalloc>
    8000165e:	00008797          	auipc	a5,0x8
    80001662:	9aa7b923          	sd	a0,-1614(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001666:	6605                	lui	a2,0x1
    80001668:	4581                	li	a1,0
    8000166a:	00000097          	auipc	ra,0x0
    8000166e:	b1c080e7          	jalr	-1252(ra) # 80001186 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001672:	4699                	li	a3,6
    80001674:	6605                	lui	a2,0x1
    80001676:	100005b7          	lui	a1,0x10000
    8000167a:	10000537          	lui	a0,0x10000
    8000167e:	00000097          	auipc	ra,0x0
    80001682:	f94080e7          	jalr	-108(ra) # 80001612 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001686:	4699                	li	a3,6
    80001688:	6605                	lui	a2,0x1
    8000168a:	100015b7          	lui	a1,0x10001
    8000168e:	10001537          	lui	a0,0x10001
    80001692:	00000097          	auipc	ra,0x0
    80001696:	f80080e7          	jalr	-128(ra) # 80001612 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000169a:	4699                	li	a3,6
    8000169c:	00400637          	lui	a2,0x400
    800016a0:	0c0005b7          	lui	a1,0xc000
    800016a4:	0c000537          	lui	a0,0xc000
    800016a8:	00000097          	auipc	ra,0x0
    800016ac:	f6a080e7          	jalr	-150(ra) # 80001612 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800016b0:	00007497          	auipc	s1,0x7
    800016b4:	95048493          	addi	s1,s1,-1712 # 80008000 <etext>
    800016b8:	46a9                	li	a3,10
    800016ba:	80007617          	auipc	a2,0x80007
    800016be:	94660613          	addi	a2,a2,-1722 # 8000 <_entry-0x7fff8000>
    800016c2:	4585                	li	a1,1
    800016c4:	05fe                	slli	a1,a1,0x1f
    800016c6:	852e                	mv	a0,a1
    800016c8:	00000097          	auipc	ra,0x0
    800016cc:	f4a080e7          	jalr	-182(ra) # 80001612 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800016d0:	4699                	li	a3,6
    800016d2:	4645                	li	a2,17
    800016d4:	066e                	slli	a2,a2,0x1b
    800016d6:	8e05                	sub	a2,a2,s1
    800016d8:	85a6                	mv	a1,s1
    800016da:	8526                	mv	a0,s1
    800016dc:	00000097          	auipc	ra,0x0
    800016e0:	f36080e7          	jalr	-202(ra) # 80001612 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800016e4:	46a9                	li	a3,10
    800016e6:	6605                	lui	a2,0x1
    800016e8:	00006597          	auipc	a1,0x6
    800016ec:	91858593          	addi	a1,a1,-1768 # 80007000 <_trampoline>
    800016f0:	04000537          	lui	a0,0x4000
    800016f4:	157d                	addi	a0,a0,-1
    800016f6:	0532                	slli	a0,a0,0xc
    800016f8:	00000097          	auipc	ra,0x0
    800016fc:	f1a080e7          	jalr	-230(ra) # 80001612 <kvmmap>
}
    80001700:	60e2                	ld	ra,24(sp)
    80001702:	6442                	ld	s0,16(sp)
    80001704:	64a2                	ld	s1,8(sp)
    80001706:	6105                	addi	sp,sp,32
    80001708:	8082                	ret

000000008000170a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000170a:	715d                	addi	sp,sp,-80
    8000170c:	e486                	sd	ra,72(sp)
    8000170e:	e0a2                	sd	s0,64(sp)
    80001710:	fc26                	sd	s1,56(sp)
    80001712:	f84a                	sd	s2,48(sp)
    80001714:	f44e                	sd	s3,40(sp)
    80001716:	f052                	sd	s4,32(sp)
    80001718:	ec56                	sd	s5,24(sp)
    8000171a:	e85a                	sd	s6,16(sp)
    8000171c:	e45e                	sd	s7,8(sp)
    8000171e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001720:	6785                	lui	a5,0x1
    80001722:	17fd                	addi	a5,a5,-1
    80001724:	8fed                	and	a5,a5,a1
    80001726:	e795                	bnez	a5,80001752 <uvmunmap+0x48>
    80001728:	8a2a                	mv	s4,a0
    8000172a:	84ae                	mv	s1,a1
    8000172c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000172e:	0632                	slli	a2,a2,0xc
    80001730:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001734:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001736:	6b05                	lui	s6,0x1
    80001738:	0735e863          	bltu	a1,s3,800017a8 <uvmunmap+0x9e>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000173c:	60a6                	ld	ra,72(sp)
    8000173e:	6406                	ld	s0,64(sp)
    80001740:	74e2                	ld	s1,56(sp)
    80001742:	7942                	ld	s2,48(sp)
    80001744:	79a2                	ld	s3,40(sp)
    80001746:	7a02                	ld	s4,32(sp)
    80001748:	6ae2                	ld	s5,24(sp)
    8000174a:	6b42                	ld	s6,16(sp)
    8000174c:	6ba2                	ld	s7,8(sp)
    8000174e:	6161                	addi	sp,sp,80
    80001750:	8082                	ret
    panic("uvmunmap: not aligned");
    80001752:	00007517          	auipc	a0,0x7
    80001756:	a2e50513          	addi	a0,a0,-1490 # 80008180 <digits+0x168>
    8000175a:	fffff097          	auipc	ra,0xfffff
    8000175e:	e1e080e7          	jalr	-482(ra) # 80000578 <panic>
      panic("uvmunmap: walk");
    80001762:	00007517          	auipc	a0,0x7
    80001766:	a3650513          	addi	a0,a0,-1482 # 80008198 <digits+0x180>
    8000176a:	fffff097          	auipc	ra,0xfffff
    8000176e:	e0e080e7          	jalr	-498(ra) # 80000578 <panic>
      panic("uvmunmap: not mapped");
    80001772:	00007517          	auipc	a0,0x7
    80001776:	a3650513          	addi	a0,a0,-1482 # 800081a8 <digits+0x190>
    8000177a:	fffff097          	auipc	ra,0xfffff
    8000177e:	dfe080e7          	jalr	-514(ra) # 80000578 <panic>
      panic("uvmunmap: not a leaf");
    80001782:	00007517          	auipc	a0,0x7
    80001786:	a3e50513          	addi	a0,a0,-1474 # 800081c0 <digits+0x1a8>
    8000178a:	fffff097          	auipc	ra,0xfffff
    8000178e:	dee080e7          	jalr	-530(ra) # 80000578 <panic>
      uint64 pa = PTE2PA(*pte);
    80001792:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001794:	0532                	slli	a0,a0,0xc
    80001796:	fffff097          	auipc	ra,0xfffff
    8000179a:	2e0080e7          	jalr	736(ra) # 80000a76 <kfree>
    *pte = 0;
    8000179e:	00093023          	sd	zero,0(s2)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800017a2:	94da                	add	s1,s1,s6
    800017a4:	f934fce3          	bleu	s3,s1,8000173c <uvmunmap+0x32>
    if((pte = walk(pagetable, a, 0)) == 0)
    800017a8:	4601                	li	a2,0
    800017aa:	85a6                	mv	a1,s1
    800017ac:	8552                	mv	a0,s4
    800017ae:	00000097          	auipc	ra,0x0
    800017b2:	cca080e7          	jalr	-822(ra) # 80001478 <walk>
    800017b6:	892a                	mv	s2,a0
    800017b8:	d54d                	beqz	a0,80001762 <uvmunmap+0x58>
    if((*pte & PTE_V) == 0)
    800017ba:	6108                	ld	a0,0(a0)
    800017bc:	00157793          	andi	a5,a0,1
    800017c0:	dbcd                	beqz	a5,80001772 <uvmunmap+0x68>
    if(PTE_FLAGS(*pte) == PTE_V)
    800017c2:	3ff57793          	andi	a5,a0,1023
    800017c6:	fb778ee3          	beq	a5,s7,80001782 <uvmunmap+0x78>
    if(do_free){
    800017ca:	fc0a8ae3          	beqz	s5,8000179e <uvmunmap+0x94>
    800017ce:	b7d1                	j	80001792 <uvmunmap+0x88>

00000000800017d0 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800017d0:	1101                	addi	sp,sp,-32
    800017d2:	ec06                	sd	ra,24(sp)
    800017d4:	e822                	sd	s0,16(sp)
    800017d6:	e426                	sd	s1,8(sp)
    800017d8:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800017da:	fffff097          	auipc	ra,0xfffff
    800017de:	490080e7          	jalr	1168(ra) # 80000c6a <kalloc>
    800017e2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800017e4:	c519                	beqz	a0,800017f2 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800017e6:	6605                	lui	a2,0x1
    800017e8:	4581                	li	a1,0
    800017ea:	00000097          	auipc	ra,0x0
    800017ee:	99c080e7          	jalr	-1636(ra) # 80001186 <memset>
  return pagetable;
}
    800017f2:	8526                	mv	a0,s1
    800017f4:	60e2                	ld	ra,24(sp)
    800017f6:	6442                	ld	s0,16(sp)
    800017f8:	64a2                	ld	s1,8(sp)
    800017fa:	6105                	addi	sp,sp,32
    800017fc:	8082                	ret

00000000800017fe <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800017fe:	7179                	addi	sp,sp,-48
    80001800:	f406                	sd	ra,40(sp)
    80001802:	f022                	sd	s0,32(sp)
    80001804:	ec26                	sd	s1,24(sp)
    80001806:	e84a                	sd	s2,16(sp)
    80001808:	e44e                	sd	s3,8(sp)
    8000180a:	e052                	sd	s4,0(sp)
    8000180c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000180e:	6785                	lui	a5,0x1
    80001810:	04f67863          	bleu	a5,a2,80001860 <uvminit+0x62>
    80001814:	8a2a                	mv	s4,a0
    80001816:	89ae                	mv	s3,a1
    80001818:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000181a:	fffff097          	auipc	ra,0xfffff
    8000181e:	450080e7          	jalr	1104(ra) # 80000c6a <kalloc>
    80001822:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001824:	6605                	lui	a2,0x1
    80001826:	4581                	li	a1,0
    80001828:	00000097          	auipc	ra,0x0
    8000182c:	95e080e7          	jalr	-1698(ra) # 80001186 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001830:	4779                	li	a4,30
    80001832:	86ca                	mv	a3,s2
    80001834:	6605                	lui	a2,0x1
    80001836:	4581                	li	a1,0
    80001838:	8552                	mv	a0,s4
    8000183a:	00000097          	auipc	ra,0x0
    8000183e:	d4c080e7          	jalr	-692(ra) # 80001586 <mappages>
  memmove(mem, src, sz);
    80001842:	8626                	mv	a2,s1
    80001844:	85ce                	mv	a1,s3
    80001846:	854a                	mv	a0,s2
    80001848:	00000097          	auipc	ra,0x0
    8000184c:	9aa080e7          	jalr	-1622(ra) # 800011f2 <memmove>
}
    80001850:	70a2                	ld	ra,40(sp)
    80001852:	7402                	ld	s0,32(sp)
    80001854:	64e2                	ld	s1,24(sp)
    80001856:	6942                	ld	s2,16(sp)
    80001858:	69a2                	ld	s3,8(sp)
    8000185a:	6a02                	ld	s4,0(sp)
    8000185c:	6145                	addi	sp,sp,48
    8000185e:	8082                	ret
    panic("inituvm: more than a page");
    80001860:	00007517          	auipc	a0,0x7
    80001864:	97850513          	addi	a0,a0,-1672 # 800081d8 <digits+0x1c0>
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	d10080e7          	jalr	-752(ra) # 80000578 <panic>

0000000080001870 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001870:	1101                	addi	sp,sp,-32
    80001872:	ec06                	sd	ra,24(sp)
    80001874:	e822                	sd	s0,16(sp)
    80001876:	e426                	sd	s1,8(sp)
    80001878:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000187a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000187c:	00b67d63          	bleu	a1,a2,80001896 <uvmdealloc+0x26>
    80001880:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001882:	6605                	lui	a2,0x1
    80001884:	167d                	addi	a2,a2,-1
    80001886:	00c487b3          	add	a5,s1,a2
    8000188a:	777d                	lui	a4,0xfffff
    8000188c:	8ff9                	and	a5,a5,a4
    8000188e:	962e                	add	a2,a2,a1
    80001890:	8e79                	and	a2,a2,a4
    80001892:	00c7e863          	bltu	a5,a2,800018a2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001896:	8526                	mv	a0,s1
    80001898:	60e2                	ld	ra,24(sp)
    8000189a:	6442                	ld	s0,16(sp)
    8000189c:	64a2                	ld	s1,8(sp)
    8000189e:	6105                	addi	sp,sp,32
    800018a0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800018a2:	8e1d                	sub	a2,a2,a5
    800018a4:	8231                	srli	a2,a2,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800018a6:	4685                	li	a3,1
    800018a8:	2601                	sext.w	a2,a2
    800018aa:	85be                	mv	a1,a5
    800018ac:	00000097          	auipc	ra,0x0
    800018b0:	e5e080e7          	jalr	-418(ra) # 8000170a <uvmunmap>
    800018b4:	b7cd                	j	80001896 <uvmdealloc+0x26>

00000000800018b6 <uvmalloc>:
  if(newsz < oldsz)
    800018b6:	0ab66163          	bltu	a2,a1,80001958 <uvmalloc+0xa2>
{
    800018ba:	7139                	addi	sp,sp,-64
    800018bc:	fc06                	sd	ra,56(sp)
    800018be:	f822                	sd	s0,48(sp)
    800018c0:	f426                	sd	s1,40(sp)
    800018c2:	f04a                	sd	s2,32(sp)
    800018c4:	ec4e                	sd	s3,24(sp)
    800018c6:	e852                	sd	s4,16(sp)
    800018c8:	e456                	sd	s5,8(sp)
    800018ca:	0080                	addi	s0,sp,64
  oldsz = PGROUNDUP(oldsz);
    800018cc:	6a05                	lui	s4,0x1
    800018ce:	1a7d                	addi	s4,s4,-1
    800018d0:	95d2                	add	a1,a1,s4
    800018d2:	7a7d                	lui	s4,0xfffff
    800018d4:	0145fa33          	and	s4,a1,s4
  for(a = oldsz; a < newsz; a += PGSIZE){
    800018d8:	08ca7263          	bleu	a2,s4,8000195c <uvmalloc+0xa6>
    800018dc:	89b2                	mv	s3,a2
    800018de:	8aaa                	mv	s5,a0
    800018e0:	8952                	mv	s2,s4
    mem = kalloc();
    800018e2:	fffff097          	auipc	ra,0xfffff
    800018e6:	388080e7          	jalr	904(ra) # 80000c6a <kalloc>
    800018ea:	84aa                	mv	s1,a0
    if(mem == 0){
    800018ec:	c51d                	beqz	a0,8000191a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800018ee:	6605                	lui	a2,0x1
    800018f0:	4581                	li	a1,0
    800018f2:	00000097          	auipc	ra,0x0
    800018f6:	894080e7          	jalr	-1900(ra) # 80001186 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800018fa:	4779                	li	a4,30
    800018fc:	86a6                	mv	a3,s1
    800018fe:	6605                	lui	a2,0x1
    80001900:	85ca                	mv	a1,s2
    80001902:	8556                	mv	a0,s5
    80001904:	00000097          	auipc	ra,0x0
    80001908:	c82080e7          	jalr	-894(ra) # 80001586 <mappages>
    8000190c:	e905                	bnez	a0,8000193c <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000190e:	6785                	lui	a5,0x1
    80001910:	993e                	add	s2,s2,a5
    80001912:	fd3968e3          	bltu	s2,s3,800018e2 <uvmalloc+0x2c>
  return newsz;
    80001916:	854e                	mv	a0,s3
    80001918:	a809                	j	8000192a <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000191a:	8652                	mv	a2,s4
    8000191c:	85ca                	mv	a1,s2
    8000191e:	8556                	mv	a0,s5
    80001920:	00000097          	auipc	ra,0x0
    80001924:	f50080e7          	jalr	-176(ra) # 80001870 <uvmdealloc>
      return 0;
    80001928:	4501                	li	a0,0
}
    8000192a:	70e2                	ld	ra,56(sp)
    8000192c:	7442                	ld	s0,48(sp)
    8000192e:	74a2                	ld	s1,40(sp)
    80001930:	7902                	ld	s2,32(sp)
    80001932:	69e2                	ld	s3,24(sp)
    80001934:	6a42                	ld	s4,16(sp)
    80001936:	6aa2                	ld	s5,8(sp)
    80001938:	6121                	addi	sp,sp,64
    8000193a:	8082                	ret
      kfree(mem);
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	138080e7          	jalr	312(ra) # 80000a76 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001946:	8652                	mv	a2,s4
    80001948:	85ca                	mv	a1,s2
    8000194a:	8556                	mv	a0,s5
    8000194c:	00000097          	auipc	ra,0x0
    80001950:	f24080e7          	jalr	-220(ra) # 80001870 <uvmdealloc>
      return 0;
    80001954:	4501                	li	a0,0
    80001956:	bfd1                	j	8000192a <uvmalloc+0x74>
    return oldsz;
    80001958:	852e                	mv	a0,a1
}
    8000195a:	8082                	ret
  return newsz;
    8000195c:	8532                	mv	a0,a2
    8000195e:	b7f1                	j	8000192a <uvmalloc+0x74>

0000000080001960 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001960:	7179                	addi	sp,sp,-48
    80001962:	f406                	sd	ra,40(sp)
    80001964:	f022                	sd	s0,32(sp)
    80001966:	ec26                	sd	s1,24(sp)
    80001968:	e84a                	sd	s2,16(sp)
    8000196a:	e44e                	sd	s3,8(sp)
    8000196c:	e052                	sd	s4,0(sp)
    8000196e:	1800                	addi	s0,sp,48
    80001970:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001972:	84aa                	mv	s1,a0
    80001974:	6905                	lui	s2,0x1
    80001976:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001978:	4985                	li	s3,1
    8000197a:	a821                	j	80001992 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000197c:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000197e:	0532                	slli	a0,a0,0xc
    80001980:	00000097          	auipc	ra,0x0
    80001984:	fe0080e7          	jalr	-32(ra) # 80001960 <freewalk>
      pagetable[i] = 0;
    80001988:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000198c:	04a1                	addi	s1,s1,8
    8000198e:	03248163          	beq	s1,s2,800019b0 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001992:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001994:	00f57793          	andi	a5,a0,15
    80001998:	ff3782e3          	beq	a5,s3,8000197c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000199c:	8905                	andi	a0,a0,1
    8000199e:	d57d                	beqz	a0,8000198c <freewalk+0x2c>
      panic("freewalk: leaf");
    800019a0:	00007517          	auipc	a0,0x7
    800019a4:	85850513          	addi	a0,a0,-1960 # 800081f8 <digits+0x1e0>
    800019a8:	fffff097          	auipc	ra,0xfffff
    800019ac:	bd0080e7          	jalr	-1072(ra) # 80000578 <panic>
    }
  }
  kfree((void*)pagetable);
    800019b0:	8552                	mv	a0,s4
    800019b2:	fffff097          	auipc	ra,0xfffff
    800019b6:	0c4080e7          	jalr	196(ra) # 80000a76 <kfree>
}
    800019ba:	70a2                	ld	ra,40(sp)
    800019bc:	7402                	ld	s0,32(sp)
    800019be:	64e2                	ld	s1,24(sp)
    800019c0:	6942                	ld	s2,16(sp)
    800019c2:	69a2                	ld	s3,8(sp)
    800019c4:	6a02                	ld	s4,0(sp)
    800019c6:	6145                	addi	sp,sp,48
    800019c8:	8082                	ret

00000000800019ca <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800019ca:	1101                	addi	sp,sp,-32
    800019cc:	ec06                	sd	ra,24(sp)
    800019ce:	e822                	sd	s0,16(sp)
    800019d0:	e426                	sd	s1,8(sp)
    800019d2:	1000                	addi	s0,sp,32
    800019d4:	84aa                	mv	s1,a0
  if(sz > 0)
    800019d6:	e999                	bnez	a1,800019ec <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800019d8:	8526                	mv	a0,s1
    800019da:	00000097          	auipc	ra,0x0
    800019de:	f86080e7          	jalr	-122(ra) # 80001960 <freewalk>
}
    800019e2:	60e2                	ld	ra,24(sp)
    800019e4:	6442                	ld	s0,16(sp)
    800019e6:	64a2                	ld	s1,8(sp)
    800019e8:	6105                	addi	sp,sp,32
    800019ea:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800019ec:	6605                	lui	a2,0x1
    800019ee:	167d                	addi	a2,a2,-1
    800019f0:	962e                	add	a2,a2,a1
    800019f2:	4685                	li	a3,1
    800019f4:	8231                	srli	a2,a2,0xc
    800019f6:	4581                	li	a1,0
    800019f8:	00000097          	auipc	ra,0x0
    800019fc:	d12080e7          	jalr	-750(ra) # 8000170a <uvmunmap>
    80001a00:	bfe1                	j	800019d8 <uvmfree+0xe>

0000000080001a02 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001a02:	c679                	beqz	a2,80001ad0 <uvmcopy+0xce>
{
    80001a04:	715d                	addi	sp,sp,-80
    80001a06:	e486                	sd	ra,72(sp)
    80001a08:	e0a2                	sd	s0,64(sp)
    80001a0a:	fc26                	sd	s1,56(sp)
    80001a0c:	f84a                	sd	s2,48(sp)
    80001a0e:	f44e                	sd	s3,40(sp)
    80001a10:	f052                	sd	s4,32(sp)
    80001a12:	ec56                	sd	s5,24(sp)
    80001a14:	e85a                	sd	s6,16(sp)
    80001a16:	e45e                	sd	s7,8(sp)
    80001a18:	0880                	addi	s0,sp,80
    80001a1a:	8ab2                	mv	s5,a2
    80001a1c:	8b2e                	mv	s6,a1
    80001a1e:	8baa                	mv	s7,a0
  for(i = 0; i < sz; i += PGSIZE){
    80001a20:	4901                	li	s2,0
    if((pte = walk(old, i, 0)) == 0)
    80001a22:	4601                	li	a2,0
    80001a24:	85ca                	mv	a1,s2
    80001a26:	855e                	mv	a0,s7
    80001a28:	00000097          	auipc	ra,0x0
    80001a2c:	a50080e7          	jalr	-1456(ra) # 80001478 <walk>
    80001a30:	c531                	beqz	a0,80001a7c <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001a32:	6118                	ld	a4,0(a0)
    80001a34:	00177793          	andi	a5,a4,1
    80001a38:	cbb1                	beqz	a5,80001a8c <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001a3a:	00a75593          	srli	a1,a4,0xa
    80001a3e:	00c59993          	slli	s3,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001a42:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001a46:	fffff097          	auipc	ra,0xfffff
    80001a4a:	224080e7          	jalr	548(ra) # 80000c6a <kalloc>
    80001a4e:	8a2a                	mv	s4,a0
    80001a50:	c939                	beqz	a0,80001aa6 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001a52:	6605                	lui	a2,0x1
    80001a54:	85ce                	mv	a1,s3
    80001a56:	fffff097          	auipc	ra,0xfffff
    80001a5a:	79c080e7          	jalr	1948(ra) # 800011f2 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001a5e:	8726                	mv	a4,s1
    80001a60:	86d2                	mv	a3,s4
    80001a62:	6605                	lui	a2,0x1
    80001a64:	85ca                	mv	a1,s2
    80001a66:	855a                	mv	a0,s6
    80001a68:	00000097          	auipc	ra,0x0
    80001a6c:	b1e080e7          	jalr	-1250(ra) # 80001586 <mappages>
    80001a70:	e515                	bnez	a0,80001a9c <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001a72:	6785                	lui	a5,0x1
    80001a74:	993e                	add	s2,s2,a5
    80001a76:	fb5966e3          	bltu	s2,s5,80001a22 <uvmcopy+0x20>
    80001a7a:	a081                	j	80001aba <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001a7c:	00006517          	auipc	a0,0x6
    80001a80:	78c50513          	addi	a0,a0,1932 # 80008208 <digits+0x1f0>
    80001a84:	fffff097          	auipc	ra,0xfffff
    80001a88:	af4080e7          	jalr	-1292(ra) # 80000578 <panic>
      panic("uvmcopy: page not present");
    80001a8c:	00006517          	auipc	a0,0x6
    80001a90:	79c50513          	addi	a0,a0,1948 # 80008228 <digits+0x210>
    80001a94:	fffff097          	auipc	ra,0xfffff
    80001a98:	ae4080e7          	jalr	-1308(ra) # 80000578 <panic>
      kfree(mem);
    80001a9c:	8552                	mv	a0,s4
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	fd8080e7          	jalr	-40(ra) # 80000a76 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001aa6:	4685                	li	a3,1
    80001aa8:	00c95613          	srli	a2,s2,0xc
    80001aac:	4581                	li	a1,0
    80001aae:	855a                	mv	a0,s6
    80001ab0:	00000097          	auipc	ra,0x0
    80001ab4:	c5a080e7          	jalr	-934(ra) # 8000170a <uvmunmap>
  return -1;
    80001ab8:	557d                	li	a0,-1
}
    80001aba:	60a6                	ld	ra,72(sp)
    80001abc:	6406                	ld	s0,64(sp)
    80001abe:	74e2                	ld	s1,56(sp)
    80001ac0:	7942                	ld	s2,48(sp)
    80001ac2:	79a2                	ld	s3,40(sp)
    80001ac4:	7a02                	ld	s4,32(sp)
    80001ac6:	6ae2                	ld	s5,24(sp)
    80001ac8:	6b42                	ld	s6,16(sp)
    80001aca:	6ba2                	ld	s7,8(sp)
    80001acc:	6161                	addi	sp,sp,80
    80001ace:	8082                	ret
  return 0;
    80001ad0:	4501                	li	a0,0
}
    80001ad2:	8082                	ret

0000000080001ad4 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001ad4:	1141                	addi	sp,sp,-16
    80001ad6:	e406                	sd	ra,8(sp)
    80001ad8:	e022                	sd	s0,0(sp)
    80001ada:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001adc:	4601                	li	a2,0
    80001ade:	00000097          	auipc	ra,0x0
    80001ae2:	99a080e7          	jalr	-1638(ra) # 80001478 <walk>
  if(pte == 0)
    80001ae6:	c901                	beqz	a0,80001af6 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001ae8:	611c                	ld	a5,0(a0)
    80001aea:	9bbd                	andi	a5,a5,-17
    80001aec:	e11c                	sd	a5,0(a0)
}
    80001aee:	60a2                	ld	ra,8(sp)
    80001af0:	6402                	ld	s0,0(sp)
    80001af2:	0141                	addi	sp,sp,16
    80001af4:	8082                	ret
    panic("uvmclear");
    80001af6:	00006517          	auipc	a0,0x6
    80001afa:	75250513          	addi	a0,a0,1874 # 80008248 <digits+0x230>
    80001afe:	fffff097          	auipc	ra,0xfffff
    80001b02:	a7a080e7          	jalr	-1414(ra) # 80000578 <panic>

0000000080001b06 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001b06:	c6bd                	beqz	a3,80001b74 <copyout+0x6e>
{
    80001b08:	715d                	addi	sp,sp,-80
    80001b0a:	e486                	sd	ra,72(sp)
    80001b0c:	e0a2                	sd	s0,64(sp)
    80001b0e:	fc26                	sd	s1,56(sp)
    80001b10:	f84a                	sd	s2,48(sp)
    80001b12:	f44e                	sd	s3,40(sp)
    80001b14:	f052                	sd	s4,32(sp)
    80001b16:	ec56                	sd	s5,24(sp)
    80001b18:	e85a                	sd	s6,16(sp)
    80001b1a:	e45e                	sd	s7,8(sp)
    80001b1c:	e062                	sd	s8,0(sp)
    80001b1e:	0880                	addi	s0,sp,80
    80001b20:	8baa                	mv	s7,a0
    80001b22:	8a2e                	mv	s4,a1
    80001b24:	8ab2                	mv	s5,a2
    80001b26:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001b28:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001b2a:	6b05                	lui	s6,0x1
    80001b2c:	a015                	j	80001b50 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001b2e:	9552                	add	a0,a0,s4
    80001b30:	0004861b          	sext.w	a2,s1
    80001b34:	85d6                	mv	a1,s5
    80001b36:	41250533          	sub	a0,a0,s2
    80001b3a:	fffff097          	auipc	ra,0xfffff
    80001b3e:	6b8080e7          	jalr	1720(ra) # 800011f2 <memmove>

    len -= n;
    80001b42:	409989b3          	sub	s3,s3,s1
    src += n;
    80001b46:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    80001b48:	01690a33          	add	s4,s2,s6
  while(len > 0){
    80001b4c:	02098263          	beqz	s3,80001b70 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001b50:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    80001b54:	85ca                	mv	a1,s2
    80001b56:	855e                	mv	a0,s7
    80001b58:	00000097          	auipc	ra,0x0
    80001b5c:	9ec080e7          	jalr	-1556(ra) # 80001544 <walkaddr>
    if(pa0 == 0)
    80001b60:	cd01                	beqz	a0,80001b78 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001b62:	414904b3          	sub	s1,s2,s4
    80001b66:	94da                	add	s1,s1,s6
    if(n > len)
    80001b68:	fc99f3e3          	bleu	s1,s3,80001b2e <copyout+0x28>
    80001b6c:	84ce                	mv	s1,s3
    80001b6e:	b7c1                	j	80001b2e <copyout+0x28>
  }
  return 0;
    80001b70:	4501                	li	a0,0
    80001b72:	a021                	j	80001b7a <copyout+0x74>
    80001b74:	4501                	li	a0,0
}
    80001b76:	8082                	ret
      return -1;
    80001b78:	557d                	li	a0,-1
}
    80001b7a:	60a6                	ld	ra,72(sp)
    80001b7c:	6406                	ld	s0,64(sp)
    80001b7e:	74e2                	ld	s1,56(sp)
    80001b80:	7942                	ld	s2,48(sp)
    80001b82:	79a2                	ld	s3,40(sp)
    80001b84:	7a02                	ld	s4,32(sp)
    80001b86:	6ae2                	ld	s5,24(sp)
    80001b88:	6b42                	ld	s6,16(sp)
    80001b8a:	6ba2                	ld	s7,8(sp)
    80001b8c:	6c02                	ld	s8,0(sp)
    80001b8e:	6161                	addi	sp,sp,80
    80001b90:	8082                	ret

0000000080001b92 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001b92:	caa5                	beqz	a3,80001c02 <copyin+0x70>
{
    80001b94:	715d                	addi	sp,sp,-80
    80001b96:	e486                	sd	ra,72(sp)
    80001b98:	e0a2                	sd	s0,64(sp)
    80001b9a:	fc26                	sd	s1,56(sp)
    80001b9c:	f84a                	sd	s2,48(sp)
    80001b9e:	f44e                	sd	s3,40(sp)
    80001ba0:	f052                	sd	s4,32(sp)
    80001ba2:	ec56                	sd	s5,24(sp)
    80001ba4:	e85a                	sd	s6,16(sp)
    80001ba6:	e45e                	sd	s7,8(sp)
    80001ba8:	e062                	sd	s8,0(sp)
    80001baa:	0880                	addi	s0,sp,80
    80001bac:	8baa                	mv	s7,a0
    80001bae:	8aae                	mv	s5,a1
    80001bb0:	8a32                	mv	s4,a2
    80001bb2:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001bb4:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001bb6:	6b05                	lui	s6,0x1
    80001bb8:	a01d                	j	80001bde <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001bba:	014505b3          	add	a1,a0,s4
    80001bbe:	0004861b          	sext.w	a2,s1
    80001bc2:	412585b3          	sub	a1,a1,s2
    80001bc6:	8556                	mv	a0,s5
    80001bc8:	fffff097          	auipc	ra,0xfffff
    80001bcc:	62a080e7          	jalr	1578(ra) # 800011f2 <memmove>

    len -= n;
    80001bd0:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001bd4:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001bd6:	01690a33          	add	s4,s2,s6
  while(len > 0){
    80001bda:	02098263          	beqz	s3,80001bfe <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001bde:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    80001be2:	85ca                	mv	a1,s2
    80001be4:	855e                	mv	a0,s7
    80001be6:	00000097          	auipc	ra,0x0
    80001bea:	95e080e7          	jalr	-1698(ra) # 80001544 <walkaddr>
    if(pa0 == 0)
    80001bee:	cd01                	beqz	a0,80001c06 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001bf0:	414904b3          	sub	s1,s2,s4
    80001bf4:	94da                	add	s1,s1,s6
    if(n > len)
    80001bf6:	fc99f2e3          	bleu	s1,s3,80001bba <copyin+0x28>
    80001bfa:	84ce                	mv	s1,s3
    80001bfc:	bf7d                	j	80001bba <copyin+0x28>
  }
  return 0;
    80001bfe:	4501                	li	a0,0
    80001c00:	a021                	j	80001c08 <copyin+0x76>
    80001c02:	4501                	li	a0,0
}
    80001c04:	8082                	ret
      return -1;
    80001c06:	557d                	li	a0,-1
}
    80001c08:	60a6                	ld	ra,72(sp)
    80001c0a:	6406                	ld	s0,64(sp)
    80001c0c:	74e2                	ld	s1,56(sp)
    80001c0e:	7942                	ld	s2,48(sp)
    80001c10:	79a2                	ld	s3,40(sp)
    80001c12:	7a02                	ld	s4,32(sp)
    80001c14:	6ae2                	ld	s5,24(sp)
    80001c16:	6b42                	ld	s6,16(sp)
    80001c18:	6ba2                	ld	s7,8(sp)
    80001c1a:	6c02                	ld	s8,0(sp)
    80001c1c:	6161                	addi	sp,sp,80
    80001c1e:	8082                	ret

0000000080001c20 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001c20:	ced5                	beqz	a3,80001cdc <copyinstr+0xbc>
{
    80001c22:	715d                	addi	sp,sp,-80
    80001c24:	e486                	sd	ra,72(sp)
    80001c26:	e0a2                	sd	s0,64(sp)
    80001c28:	fc26                	sd	s1,56(sp)
    80001c2a:	f84a                	sd	s2,48(sp)
    80001c2c:	f44e                	sd	s3,40(sp)
    80001c2e:	f052                	sd	s4,32(sp)
    80001c30:	ec56                	sd	s5,24(sp)
    80001c32:	e85a                	sd	s6,16(sp)
    80001c34:	e45e                	sd	s7,8(sp)
    80001c36:	e062                	sd	s8,0(sp)
    80001c38:	0880                	addi	s0,sp,80
    80001c3a:	8aaa                	mv	s5,a0
    80001c3c:	84ae                	mv	s1,a1
    80001c3e:	8c32                	mv	s8,a2
    80001c40:	8bb6                	mv	s7,a3
    va0 = PGROUNDDOWN(srcva);
    80001c42:	7a7d                	lui	s4,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001c44:	6985                	lui	s3,0x1
    80001c46:	4b05                	li	s6,1
    80001c48:	a801                	j	80001c58 <copyinstr+0x38>
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
    80001c4a:	87a6                	mv	a5,s1
    80001c4c:	a085                	j	80001cac <copyinstr+0x8c>
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    80001c4e:	84b2                	mv	s1,a2
    }

    srcva = va0 + PGSIZE;
    80001c50:	01390c33          	add	s8,s2,s3
  while(got_null == 0 && max > 0){
    80001c54:	080b8063          	beqz	s7,80001cd4 <copyinstr+0xb4>
    va0 = PGROUNDDOWN(srcva);
    80001c58:	014c7933          	and	s2,s8,s4
    pa0 = walkaddr(pagetable, va0);
    80001c5c:	85ca                	mv	a1,s2
    80001c5e:	8556                	mv	a0,s5
    80001c60:	00000097          	auipc	ra,0x0
    80001c64:	8e4080e7          	jalr	-1820(ra) # 80001544 <walkaddr>
    if(pa0 == 0)
    80001c68:	c925                	beqz	a0,80001cd8 <copyinstr+0xb8>
    n = PGSIZE - (srcva - va0);
    80001c6a:	41890633          	sub	a2,s2,s8
    80001c6e:	964e                	add	a2,a2,s3
    if(n > max)
    80001c70:	00cbf363          	bleu	a2,s7,80001c76 <copyinstr+0x56>
    80001c74:	865e                	mv	a2,s7
    char *p = (char *) (pa0 + (srcva - va0));
    80001c76:	9562                	add	a0,a0,s8
    80001c78:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001c7c:	da71                	beqz	a2,80001c50 <copyinstr+0x30>
      if(*p == '\0'){
    80001c7e:	00054703          	lbu	a4,0(a0)
    80001c82:	d761                	beqz	a4,80001c4a <copyinstr+0x2a>
    80001c84:	9626                	add	a2,a2,s1
    80001c86:	87a6                	mv	a5,s1
    80001c88:	1bfd                	addi	s7,s7,-1
    80001c8a:	009b86b3          	add	a3,s7,s1
    80001c8e:	409b04b3          	sub	s1,s6,s1
    80001c92:	94aa                	add	s1,s1,a0
        *dst = *p;
    80001c94:	00e78023          	sb	a4,0(a5) # 1000 <_entry-0x7ffff000>
      --max;
    80001c98:	40f68bb3          	sub	s7,a3,a5
      p++;
    80001c9c:	00f48733          	add	a4,s1,a5
      dst++;
    80001ca0:	0785                	addi	a5,a5,1
    while(n > 0){
    80001ca2:	faf606e3          	beq	a2,a5,80001c4e <copyinstr+0x2e>
      if(*p == '\0'){
    80001ca6:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffccfd8>
    80001caa:	f76d                	bnez	a4,80001c94 <copyinstr+0x74>
        *dst = '\0';
    80001cac:	00078023          	sb	zero,0(a5)
    80001cb0:	4785                	li	a5,1
  }
  if(got_null){
    80001cb2:	0017b513          	seqz	a0,a5
    80001cb6:	40a0053b          	negw	a0,a0
    80001cba:	2501                	sext.w	a0,a0
    return 0;
  } else {
    return -1;
  }
}
    80001cbc:	60a6                	ld	ra,72(sp)
    80001cbe:	6406                	ld	s0,64(sp)
    80001cc0:	74e2                	ld	s1,56(sp)
    80001cc2:	7942                	ld	s2,48(sp)
    80001cc4:	79a2                	ld	s3,40(sp)
    80001cc6:	7a02                	ld	s4,32(sp)
    80001cc8:	6ae2                	ld	s5,24(sp)
    80001cca:	6b42                	ld	s6,16(sp)
    80001ccc:	6ba2                	ld	s7,8(sp)
    80001cce:	6c02                	ld	s8,0(sp)
    80001cd0:	6161                	addi	sp,sp,80
    80001cd2:	8082                	ret
    80001cd4:	4781                	li	a5,0
    80001cd6:	bff1                	j	80001cb2 <copyinstr+0x92>
      return -1;
    80001cd8:	557d                	li	a0,-1
    80001cda:	b7cd                	j	80001cbc <copyinstr+0x9c>
  int got_null = 0;
    80001cdc:	4781                	li	a5,0
  if(got_null){
    80001cde:	0017b513          	seqz	a0,a5
    80001ce2:	40a0053b          	negw	a0,a0
    80001ce6:	2501                	sext.w	a0,a0
}
    80001ce8:	8082                	ret

0000000080001cea <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001cea:	1101                	addi	sp,sp,-32
    80001cec:	ec06                	sd	ra,24(sp)
    80001cee:	e822                	sd	s0,16(sp)
    80001cf0:	e426                	sd	s1,8(sp)
    80001cf2:	1000                	addi	s0,sp,32
    80001cf4:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	00a080e7          	jalr	10(ra) # 80000d00 <holding>
    80001cfe:	c909                	beqz	a0,80001d10 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001d00:	789c                	ld	a5,48(s1)
    80001d02:	00978f63          	beq	a5,s1,80001d20 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001d06:	60e2                	ld	ra,24(sp)
    80001d08:	6442                	ld	s0,16(sp)
    80001d0a:	64a2                	ld	s1,8(sp)
    80001d0c:	6105                	addi	sp,sp,32
    80001d0e:	8082                	ret
    panic("wakeup1");
    80001d10:	00006517          	auipc	a0,0x6
    80001d14:	57050513          	addi	a0,a0,1392 # 80008280 <states.1732+0x28>
    80001d18:	fffff097          	auipc	ra,0xfffff
    80001d1c:	860080e7          	jalr	-1952(ra) # 80000578 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001d20:	5098                	lw	a4,32(s1)
    80001d22:	4785                	li	a5,1
    80001d24:	fef711e3          	bne	a4,a5,80001d06 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001d28:	4789                	li	a5,2
    80001d2a:	d09c                	sw	a5,32(s1)
}
    80001d2c:	bfe9                	j	80001d06 <wakeup1+0x1c>

0000000080001d2e <procinit>:
{
    80001d2e:	715d                	addi	sp,sp,-80
    80001d30:	e486                	sd	ra,72(sp)
    80001d32:	e0a2                	sd	s0,64(sp)
    80001d34:	fc26                	sd	s1,56(sp)
    80001d36:	f84a                	sd	s2,48(sp)
    80001d38:	f44e                	sd	s3,40(sp)
    80001d3a:	f052                	sd	s4,32(sp)
    80001d3c:	ec56                	sd	s5,24(sp)
    80001d3e:	e85a                	sd	s6,16(sp)
    80001d40:	e45e                	sd	s7,8(sp)
    80001d42:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001d44:	00006597          	auipc	a1,0x6
    80001d48:	54458593          	addi	a1,a1,1348 # 80008288 <states.1732+0x30>
    80001d4c:	00010517          	auipc	a0,0x10
    80001d50:	63c50513          	addi	a0,a0,1596 # 80012388 <pid_lock>
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	1b2080e7          	jalr	434(ra) # 80000f06 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d5c:	00011917          	auipc	s2,0x11
    80001d60:	a4c90913          	addi	s2,s2,-1460 # 800127a8 <proc>
      initlock(&p->lock, "proc");
    80001d64:	00006b97          	auipc	s7,0x6
    80001d68:	52cb8b93          	addi	s7,s7,1324 # 80008290 <states.1732+0x38>
      uint64 va = KSTACK((int) (p - proc));
    80001d6c:	8b4a                	mv	s6,s2
    80001d6e:	00006a97          	auipc	s5,0x6
    80001d72:	292a8a93          	addi	s5,s5,658 # 80008000 <etext>
    80001d76:	040009b7          	lui	s3,0x4000
    80001d7a:	19fd                	addi	s3,s3,-1
    80001d7c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d7e:	00016a17          	auipc	s4,0x16
    80001d82:	62aa0a13          	addi	s4,s4,1578 # 800183a8 <tickslock>
      initlock(&p->lock, "proc");
    80001d86:	85de                	mv	a1,s7
    80001d88:	854a                	mv	a0,s2
    80001d8a:	fffff097          	auipc	ra,0xfffff
    80001d8e:	17c080e7          	jalr	380(ra) # 80000f06 <initlock>
      char *pa = kalloc();
    80001d92:	fffff097          	auipc	ra,0xfffff
    80001d96:	ed8080e7          	jalr	-296(ra) # 80000c6a <kalloc>
    80001d9a:	85aa                	mv	a1,a0
      if(pa == 0)
    80001d9c:	c929                	beqz	a0,80001dee <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001d9e:	416904b3          	sub	s1,s2,s6
    80001da2:	8491                	srai	s1,s1,0x4
    80001da4:	000ab783          	ld	a5,0(s5)
    80001da8:	02f484b3          	mul	s1,s1,a5
    80001dac:	2485                	addiw	s1,s1,1
    80001dae:	00d4949b          	slliw	s1,s1,0xd
    80001db2:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001db6:	4699                	li	a3,6
    80001db8:	6605                	lui	a2,0x1
    80001dba:	8526                	mv	a0,s1
    80001dbc:	00000097          	auipc	ra,0x0
    80001dc0:	856080e7          	jalr	-1962(ra) # 80001612 <kvmmap>
      p->kstack = va;
    80001dc4:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dc8:	17090913          	addi	s2,s2,368
    80001dcc:	fb491de3          	bne	s2,s4,80001d86 <procinit+0x58>
  kvminithart();
    80001dd0:	fffff097          	auipc	ra,0xfffff
    80001dd4:	74e080e7          	jalr	1870(ra) # 8000151e <kvminithart>
}
    80001dd8:	60a6                	ld	ra,72(sp)
    80001dda:	6406                	ld	s0,64(sp)
    80001ddc:	74e2                	ld	s1,56(sp)
    80001dde:	7942                	ld	s2,48(sp)
    80001de0:	79a2                	ld	s3,40(sp)
    80001de2:	7a02                	ld	s4,32(sp)
    80001de4:	6ae2                	ld	s5,24(sp)
    80001de6:	6b42                	ld	s6,16(sp)
    80001de8:	6ba2                	ld	s7,8(sp)
    80001dea:	6161                	addi	sp,sp,80
    80001dec:	8082                	ret
        panic("kalloc");
    80001dee:	00006517          	auipc	a0,0x6
    80001df2:	4aa50513          	addi	a0,a0,1194 # 80008298 <states.1732+0x40>
    80001df6:	ffffe097          	auipc	ra,0xffffe
    80001dfa:	782080e7          	jalr	1922(ra) # 80000578 <panic>

0000000080001dfe <cpuid>:
{
    80001dfe:	1141                	addi	sp,sp,-16
    80001e00:	e422                	sd	s0,8(sp)
    80001e02:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e04:	8512                	mv	a0,tp
}
    80001e06:	2501                	sext.w	a0,a0
    80001e08:	6422                	ld	s0,8(sp)
    80001e0a:	0141                	addi	sp,sp,16
    80001e0c:	8082                	ret

0000000080001e0e <mycpu>:
mycpu(void) {
    80001e0e:	1141                	addi	sp,sp,-16
    80001e10:	e422                	sd	s0,8(sp)
    80001e12:	0800                	addi	s0,sp,16
    80001e14:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001e16:	2781                	sext.w	a5,a5
    80001e18:	079e                	slli	a5,a5,0x7
}
    80001e1a:	00010517          	auipc	a0,0x10
    80001e1e:	58e50513          	addi	a0,a0,1422 # 800123a8 <cpus>
    80001e22:	953e                	add	a0,a0,a5
    80001e24:	6422                	ld	s0,8(sp)
    80001e26:	0141                	addi	sp,sp,16
    80001e28:	8082                	ret

0000000080001e2a <myproc>:
myproc(void) {
    80001e2a:	1101                	addi	sp,sp,-32
    80001e2c:	ec06                	sd	ra,24(sp)
    80001e2e:	e822                	sd	s0,16(sp)
    80001e30:	e426                	sd	s1,8(sp)
    80001e32:	1000                	addi	s0,sp,32
  push_off();
    80001e34:	fffff097          	auipc	ra,0xfffff
    80001e38:	efa080e7          	jalr	-262(ra) # 80000d2e <push_off>
    80001e3c:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001e3e:	2781                	sext.w	a5,a5
    80001e40:	079e                	slli	a5,a5,0x7
    80001e42:	00010717          	auipc	a4,0x10
    80001e46:	54670713          	addi	a4,a4,1350 # 80012388 <pid_lock>
    80001e4a:	97ba                	add	a5,a5,a4
    80001e4c:	7384                	ld	s1,32(a5)
  pop_off();
    80001e4e:	fffff097          	auipc	ra,0xfffff
    80001e52:	f9c080e7          	jalr	-100(ra) # 80000dea <pop_off>
}
    80001e56:	8526                	mv	a0,s1
    80001e58:	60e2                	ld	ra,24(sp)
    80001e5a:	6442                	ld	s0,16(sp)
    80001e5c:	64a2                	ld	s1,8(sp)
    80001e5e:	6105                	addi	sp,sp,32
    80001e60:	8082                	ret

0000000080001e62 <forkret>:
{
    80001e62:	1141                	addi	sp,sp,-16
    80001e64:	e406                	sd	ra,8(sp)
    80001e66:	e022                	sd	s0,0(sp)
    80001e68:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001e6a:	00000097          	auipc	ra,0x0
    80001e6e:	fc0080e7          	jalr	-64(ra) # 80001e2a <myproc>
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	fd8080e7          	jalr	-40(ra) # 80000e4a <release>
  if (first) {
    80001e7a:	00007797          	auipc	a5,0x7
    80001e7e:	a5678793          	addi	a5,a5,-1450 # 800088d0 <first.1692>
    80001e82:	439c                	lw	a5,0(a5)
    80001e84:	eb89                	bnez	a5,80001e96 <forkret+0x34>
  usertrapret();
    80001e86:	00001097          	auipc	ra,0x1
    80001e8a:	c26080e7          	jalr	-986(ra) # 80002aac <usertrapret>
}
    80001e8e:	60a2                	ld	ra,8(sp)
    80001e90:	6402                	ld	s0,0(sp)
    80001e92:	0141                	addi	sp,sp,16
    80001e94:	8082                	ret
    first = 0;
    80001e96:	00007797          	auipc	a5,0x7
    80001e9a:	a207ad23          	sw	zero,-1478(a5) # 800088d0 <first.1692>
    fsinit(ROOTDEV);
    80001e9e:	4505                	li	a0,1
    80001ea0:	00002097          	auipc	ra,0x2
    80001ea4:	a4a080e7          	jalr	-1462(ra) # 800038ea <fsinit>
    80001ea8:	bff9                	j	80001e86 <forkret+0x24>

0000000080001eaa <allocpid>:
allocpid() {
    80001eaa:	1101                	addi	sp,sp,-32
    80001eac:	ec06                	sd	ra,24(sp)
    80001eae:	e822                	sd	s0,16(sp)
    80001eb0:	e426                	sd	s1,8(sp)
    80001eb2:	e04a                	sd	s2,0(sp)
    80001eb4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001eb6:	00010917          	auipc	s2,0x10
    80001eba:	4d290913          	addi	s2,s2,1234 # 80012388 <pid_lock>
    80001ebe:	854a                	mv	a0,s2
    80001ec0:	fffff097          	auipc	ra,0xfffff
    80001ec4:	eba080e7          	jalr	-326(ra) # 80000d7a <acquire>
  pid = nextpid;
    80001ec8:	00007797          	auipc	a5,0x7
    80001ecc:	a0c78793          	addi	a5,a5,-1524 # 800088d4 <nextpid>
    80001ed0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ed2:	0014871b          	addiw	a4,s1,1
    80001ed6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ed8:	854a                	mv	a0,s2
    80001eda:	fffff097          	auipc	ra,0xfffff
    80001ede:	f70080e7          	jalr	-144(ra) # 80000e4a <release>
}
    80001ee2:	8526                	mv	a0,s1
    80001ee4:	60e2                	ld	ra,24(sp)
    80001ee6:	6442                	ld	s0,16(sp)
    80001ee8:	64a2                	ld	s1,8(sp)
    80001eea:	6902                	ld	s2,0(sp)
    80001eec:	6105                	addi	sp,sp,32
    80001eee:	8082                	ret

0000000080001ef0 <proc_pagetable>:
{
    80001ef0:	1101                	addi	sp,sp,-32
    80001ef2:	ec06                	sd	ra,24(sp)
    80001ef4:	e822                	sd	s0,16(sp)
    80001ef6:	e426                	sd	s1,8(sp)
    80001ef8:	e04a                	sd	s2,0(sp)
    80001efa:	1000                	addi	s0,sp,32
    80001efc:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001efe:	00000097          	auipc	ra,0x0
    80001f02:	8d2080e7          	jalr	-1838(ra) # 800017d0 <uvmcreate>
    80001f06:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001f08:	c121                	beqz	a0,80001f48 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001f0a:	4729                	li	a4,10
    80001f0c:	00005697          	auipc	a3,0x5
    80001f10:	0f468693          	addi	a3,a3,244 # 80007000 <_trampoline>
    80001f14:	6605                	lui	a2,0x1
    80001f16:	040005b7          	lui	a1,0x4000
    80001f1a:	15fd                	addi	a1,a1,-1
    80001f1c:	05b2                	slli	a1,a1,0xc
    80001f1e:	fffff097          	auipc	ra,0xfffff
    80001f22:	668080e7          	jalr	1640(ra) # 80001586 <mappages>
    80001f26:	02054863          	bltz	a0,80001f56 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001f2a:	4719                	li	a4,6
    80001f2c:	06093683          	ld	a3,96(s2)
    80001f30:	6605                	lui	a2,0x1
    80001f32:	020005b7          	lui	a1,0x2000
    80001f36:	15fd                	addi	a1,a1,-1
    80001f38:	05b6                	slli	a1,a1,0xd
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	fffff097          	auipc	ra,0xfffff
    80001f40:	64a080e7          	jalr	1610(ra) # 80001586 <mappages>
    80001f44:	02054163          	bltz	a0,80001f66 <proc_pagetable+0x76>
}
    80001f48:	8526                	mv	a0,s1
    80001f4a:	60e2                	ld	ra,24(sp)
    80001f4c:	6442                	ld	s0,16(sp)
    80001f4e:	64a2                	ld	s1,8(sp)
    80001f50:	6902                	ld	s2,0(sp)
    80001f52:	6105                	addi	sp,sp,32
    80001f54:	8082                	ret
    uvmfree(pagetable, 0);
    80001f56:	4581                	li	a1,0
    80001f58:	8526                	mv	a0,s1
    80001f5a:	00000097          	auipc	ra,0x0
    80001f5e:	a70080e7          	jalr	-1424(ra) # 800019ca <uvmfree>
    return 0;
    80001f62:	4481                	li	s1,0
    80001f64:	b7d5                	j	80001f48 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f66:	4681                	li	a3,0
    80001f68:	4605                	li	a2,1
    80001f6a:	040005b7          	lui	a1,0x4000
    80001f6e:	15fd                	addi	a1,a1,-1
    80001f70:	05b2                	slli	a1,a1,0xc
    80001f72:	8526                	mv	a0,s1
    80001f74:	fffff097          	auipc	ra,0xfffff
    80001f78:	796080e7          	jalr	1942(ra) # 8000170a <uvmunmap>
    uvmfree(pagetable, 0);
    80001f7c:	4581                	li	a1,0
    80001f7e:	8526                	mv	a0,s1
    80001f80:	00000097          	auipc	ra,0x0
    80001f84:	a4a080e7          	jalr	-1462(ra) # 800019ca <uvmfree>
    return 0;
    80001f88:	4481                	li	s1,0
    80001f8a:	bf7d                	j	80001f48 <proc_pagetable+0x58>

0000000080001f8c <proc_freepagetable>:
{
    80001f8c:	1101                	addi	sp,sp,-32
    80001f8e:	ec06                	sd	ra,24(sp)
    80001f90:	e822                	sd	s0,16(sp)
    80001f92:	e426                	sd	s1,8(sp)
    80001f94:	e04a                	sd	s2,0(sp)
    80001f96:	1000                	addi	s0,sp,32
    80001f98:	84aa                	mv	s1,a0
    80001f9a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f9c:	4681                	li	a3,0
    80001f9e:	4605                	li	a2,1
    80001fa0:	040005b7          	lui	a1,0x4000
    80001fa4:	15fd                	addi	a1,a1,-1
    80001fa6:	05b2                	slli	a1,a1,0xc
    80001fa8:	fffff097          	auipc	ra,0xfffff
    80001fac:	762080e7          	jalr	1890(ra) # 8000170a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001fb0:	4681                	li	a3,0
    80001fb2:	4605                	li	a2,1
    80001fb4:	020005b7          	lui	a1,0x2000
    80001fb8:	15fd                	addi	a1,a1,-1
    80001fba:	05b6                	slli	a1,a1,0xd
    80001fbc:	8526                	mv	a0,s1
    80001fbe:	fffff097          	auipc	ra,0xfffff
    80001fc2:	74c080e7          	jalr	1868(ra) # 8000170a <uvmunmap>
  uvmfree(pagetable, sz);
    80001fc6:	85ca                	mv	a1,s2
    80001fc8:	8526                	mv	a0,s1
    80001fca:	00000097          	auipc	ra,0x0
    80001fce:	a00080e7          	jalr	-1536(ra) # 800019ca <uvmfree>
}
    80001fd2:	60e2                	ld	ra,24(sp)
    80001fd4:	6442                	ld	s0,16(sp)
    80001fd6:	64a2                	ld	s1,8(sp)
    80001fd8:	6902                	ld	s2,0(sp)
    80001fda:	6105                	addi	sp,sp,32
    80001fdc:	8082                	ret

0000000080001fde <freeproc>:
{
    80001fde:	1101                	addi	sp,sp,-32
    80001fe0:	ec06                	sd	ra,24(sp)
    80001fe2:	e822                	sd	s0,16(sp)
    80001fe4:	e426                	sd	s1,8(sp)
    80001fe6:	1000                	addi	s0,sp,32
    80001fe8:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001fea:	7128                	ld	a0,96(a0)
    80001fec:	c509                	beqz	a0,80001ff6 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001fee:	fffff097          	auipc	ra,0xfffff
    80001ff2:	a88080e7          	jalr	-1400(ra) # 80000a76 <kfree>
  p->trapframe = 0;
    80001ff6:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001ffa:	6ca8                	ld	a0,88(s1)
    80001ffc:	c511                	beqz	a0,80002008 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001ffe:	68ac                	ld	a1,80(s1)
    80002000:	00000097          	auipc	ra,0x0
    80002004:	f8c080e7          	jalr	-116(ra) # 80001f8c <proc_freepagetable>
  p->pagetable = 0;
    80002008:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    8000200c:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80002010:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80002014:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80002018:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    8000201c:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80002020:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80002024:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80002028:	0204a023          	sw	zero,32(s1)
}
    8000202c:	60e2                	ld	ra,24(sp)
    8000202e:	6442                	ld	s0,16(sp)
    80002030:	64a2                	ld	s1,8(sp)
    80002032:	6105                	addi	sp,sp,32
    80002034:	8082                	ret

0000000080002036 <allocproc>:
{
    80002036:	1101                	addi	sp,sp,-32
    80002038:	ec06                	sd	ra,24(sp)
    8000203a:	e822                	sd	s0,16(sp)
    8000203c:	e426                	sd	s1,8(sp)
    8000203e:	e04a                	sd	s2,0(sp)
    80002040:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80002042:	00010497          	auipc	s1,0x10
    80002046:	76648493          	addi	s1,s1,1894 # 800127a8 <proc>
    8000204a:	00016917          	auipc	s2,0x16
    8000204e:	35e90913          	addi	s2,s2,862 # 800183a8 <tickslock>
    acquire(&p->lock);
    80002052:	8526                	mv	a0,s1
    80002054:	fffff097          	auipc	ra,0xfffff
    80002058:	d26080e7          	jalr	-730(ra) # 80000d7a <acquire>
    if(p->state == UNUSED) {
    8000205c:	509c                	lw	a5,32(s1)
    8000205e:	cf81                	beqz	a5,80002076 <allocproc+0x40>
      release(&p->lock);
    80002060:	8526                	mv	a0,s1
    80002062:	fffff097          	auipc	ra,0xfffff
    80002066:	de8080e7          	jalr	-536(ra) # 80000e4a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000206a:	17048493          	addi	s1,s1,368
    8000206e:	ff2492e3          	bne	s1,s2,80002052 <allocproc+0x1c>
  return 0;
    80002072:	4481                	li	s1,0
    80002074:	a0b9                	j	800020c2 <allocproc+0x8c>
  p->pid = allocpid();
    80002076:	00000097          	auipc	ra,0x0
    8000207a:	e34080e7          	jalr	-460(ra) # 80001eaa <allocpid>
    8000207e:	c0a8                	sw	a0,64(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	bea080e7          	jalr	-1046(ra) # 80000c6a <kalloc>
    80002088:	892a                	mv	s2,a0
    8000208a:	f0a8                	sd	a0,96(s1)
    8000208c:	c131                	beqz	a0,800020d0 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    8000208e:	8526                	mv	a0,s1
    80002090:	00000097          	auipc	ra,0x0
    80002094:	e60080e7          	jalr	-416(ra) # 80001ef0 <proc_pagetable>
    80002098:	892a                	mv	s2,a0
    8000209a:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    8000209c:	c129                	beqz	a0,800020de <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    8000209e:	07000613          	li	a2,112
    800020a2:	4581                	li	a1,0
    800020a4:	06848513          	addi	a0,s1,104
    800020a8:	fffff097          	auipc	ra,0xfffff
    800020ac:	0de080e7          	jalr	222(ra) # 80001186 <memset>
  p->context.ra = (uint64)forkret;
    800020b0:	00000797          	auipc	a5,0x0
    800020b4:	db278793          	addi	a5,a5,-590 # 80001e62 <forkret>
    800020b8:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    800020ba:	64bc                	ld	a5,72(s1)
    800020bc:	6705                	lui	a4,0x1
    800020be:	97ba                	add	a5,a5,a4
    800020c0:	f8bc                	sd	a5,112(s1)
}
    800020c2:	8526                	mv	a0,s1
    800020c4:	60e2                	ld	ra,24(sp)
    800020c6:	6442                	ld	s0,16(sp)
    800020c8:	64a2                	ld	s1,8(sp)
    800020ca:	6902                	ld	s2,0(sp)
    800020cc:	6105                	addi	sp,sp,32
    800020ce:	8082                	ret
    release(&p->lock);
    800020d0:	8526                	mv	a0,s1
    800020d2:	fffff097          	auipc	ra,0xfffff
    800020d6:	d78080e7          	jalr	-648(ra) # 80000e4a <release>
    return 0;
    800020da:	84ca                	mv	s1,s2
    800020dc:	b7dd                	j	800020c2 <allocproc+0x8c>
    freeproc(p);
    800020de:	8526                	mv	a0,s1
    800020e0:	00000097          	auipc	ra,0x0
    800020e4:	efe080e7          	jalr	-258(ra) # 80001fde <freeproc>
    release(&p->lock);
    800020e8:	8526                	mv	a0,s1
    800020ea:	fffff097          	auipc	ra,0xfffff
    800020ee:	d60080e7          	jalr	-672(ra) # 80000e4a <release>
    return 0;
    800020f2:	84ca                	mv	s1,s2
    800020f4:	b7f9                	j	800020c2 <allocproc+0x8c>

00000000800020f6 <userinit>:
{
    800020f6:	1101                	addi	sp,sp,-32
    800020f8:	ec06                	sd	ra,24(sp)
    800020fa:	e822                	sd	s0,16(sp)
    800020fc:	e426                	sd	s1,8(sp)
    800020fe:	1000                	addi	s0,sp,32
  p = allocproc();
    80002100:	00000097          	auipc	ra,0x0
    80002104:	f36080e7          	jalr	-202(ra) # 80002036 <allocproc>
    80002108:	84aa                	mv	s1,a0
  initproc = p;
    8000210a:	00007797          	auipc	a5,0x7
    8000210e:	f0a7b723          	sd	a0,-242(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80002112:	03400613          	li	a2,52
    80002116:	00006597          	auipc	a1,0x6
    8000211a:	7ca58593          	addi	a1,a1,1994 # 800088e0 <initcode>
    8000211e:	6d28                	ld	a0,88(a0)
    80002120:	fffff097          	auipc	ra,0xfffff
    80002124:	6de080e7          	jalr	1758(ra) # 800017fe <uvminit>
  p->sz = PGSIZE;
    80002128:	6785                	lui	a5,0x1
    8000212a:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    8000212c:	70b8                	ld	a4,96(s1)
    8000212e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80002132:	70b8                	ld	a4,96(s1)
    80002134:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002136:	4641                	li	a2,16
    80002138:	00006597          	auipc	a1,0x6
    8000213c:	16858593          	addi	a1,a1,360 # 800082a0 <states.1732+0x48>
    80002140:	16048513          	addi	a0,s1,352
    80002144:	fffff097          	auipc	ra,0xfffff
    80002148:	1ba080e7          	jalr	442(ra) # 800012fe <safestrcpy>
  p->cwd = namei("/");
    8000214c:	00006517          	auipc	a0,0x6
    80002150:	16450513          	addi	a0,a0,356 # 800082b0 <states.1732+0x58>
    80002154:	00002097          	auipc	ra,0x2
    80002158:	1ce080e7          	jalr	462(ra) # 80004322 <namei>
    8000215c:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80002160:	4789                	li	a5,2
    80002162:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80002164:	8526                	mv	a0,s1
    80002166:	fffff097          	auipc	ra,0xfffff
    8000216a:	ce4080e7          	jalr	-796(ra) # 80000e4a <release>
}
    8000216e:	60e2                	ld	ra,24(sp)
    80002170:	6442                	ld	s0,16(sp)
    80002172:	64a2                	ld	s1,8(sp)
    80002174:	6105                	addi	sp,sp,32
    80002176:	8082                	ret

0000000080002178 <growproc>:
{
    80002178:	1101                	addi	sp,sp,-32
    8000217a:	ec06                	sd	ra,24(sp)
    8000217c:	e822                	sd	s0,16(sp)
    8000217e:	e426                	sd	s1,8(sp)
    80002180:	e04a                	sd	s2,0(sp)
    80002182:	1000                	addi	s0,sp,32
    80002184:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002186:	00000097          	auipc	ra,0x0
    8000218a:	ca4080e7          	jalr	-860(ra) # 80001e2a <myproc>
    8000218e:	892a                	mv	s2,a0
  sz = p->sz;
    80002190:	692c                	ld	a1,80(a0)
    80002192:	0005851b          	sext.w	a0,a1
  if(n > 0){
    80002196:	00904f63          	bgtz	s1,800021b4 <growproc+0x3c>
  } else if(n < 0){
    8000219a:	0204cd63          	bltz	s1,800021d4 <growproc+0x5c>
  p->sz = sz;
    8000219e:	1502                	slli	a0,a0,0x20
    800021a0:	9101                	srli	a0,a0,0x20
    800021a2:	04a93823          	sd	a0,80(s2)
  return 0;
    800021a6:	4501                	li	a0,0
}
    800021a8:	60e2                	ld	ra,24(sp)
    800021aa:	6442                	ld	s0,16(sp)
    800021ac:	64a2                	ld	s1,8(sp)
    800021ae:	6902                	ld	s2,0(sp)
    800021b0:	6105                	addi	sp,sp,32
    800021b2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    800021b4:	00a4863b          	addw	a2,s1,a0
    800021b8:	1602                	slli	a2,a2,0x20
    800021ba:	9201                	srli	a2,a2,0x20
    800021bc:	1582                	slli	a1,a1,0x20
    800021be:	9181                	srli	a1,a1,0x20
    800021c0:	05893503          	ld	a0,88(s2)
    800021c4:	fffff097          	auipc	ra,0xfffff
    800021c8:	6f2080e7          	jalr	1778(ra) # 800018b6 <uvmalloc>
    800021cc:	2501                	sext.w	a0,a0
    800021ce:	f961                	bnez	a0,8000219e <growproc+0x26>
      return -1;
    800021d0:	557d                	li	a0,-1
    800021d2:	bfd9                	j	800021a8 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800021d4:	00a4863b          	addw	a2,s1,a0
    800021d8:	1602                	slli	a2,a2,0x20
    800021da:	9201                	srli	a2,a2,0x20
    800021dc:	1582                	slli	a1,a1,0x20
    800021de:	9181                	srli	a1,a1,0x20
    800021e0:	05893503          	ld	a0,88(s2)
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	68c080e7          	jalr	1676(ra) # 80001870 <uvmdealloc>
    800021ec:	2501                	sext.w	a0,a0
    800021ee:	bf45                	j	8000219e <growproc+0x26>

00000000800021f0 <fork>:
{
    800021f0:	7179                	addi	sp,sp,-48
    800021f2:	f406                	sd	ra,40(sp)
    800021f4:	f022                	sd	s0,32(sp)
    800021f6:	ec26                	sd	s1,24(sp)
    800021f8:	e84a                	sd	s2,16(sp)
    800021fa:	e44e                	sd	s3,8(sp)
    800021fc:	e052                	sd	s4,0(sp)
    800021fe:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002200:	00000097          	auipc	ra,0x0
    80002204:	c2a080e7          	jalr	-982(ra) # 80001e2a <myproc>
    80002208:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    8000220a:	00000097          	auipc	ra,0x0
    8000220e:	e2c080e7          	jalr	-468(ra) # 80002036 <allocproc>
    80002212:	c175                	beqz	a0,800022f6 <fork+0x106>
    80002214:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002216:	05093603          	ld	a2,80(s2)
    8000221a:	6d2c                	ld	a1,88(a0)
    8000221c:	05893503          	ld	a0,88(s2)
    80002220:	fffff097          	auipc	ra,0xfffff
    80002224:	7e2080e7          	jalr	2018(ra) # 80001a02 <uvmcopy>
    80002228:	04054863          	bltz	a0,80002278 <fork+0x88>
  np->sz = p->sz;
    8000222c:	05093783          	ld	a5,80(s2)
    80002230:	04f9b823          	sd	a5,80(s3) # 4000050 <_entry-0x7bffffb0>
  np->parent = p;
    80002234:	0329b423          	sd	s2,40(s3)
  *(np->trapframe) = *(p->trapframe);
    80002238:	06093683          	ld	a3,96(s2)
    8000223c:	87b6                	mv	a5,a3
    8000223e:	0609b703          	ld	a4,96(s3)
    80002242:	12068693          	addi	a3,a3,288
    80002246:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000224a:	6788                	ld	a0,8(a5)
    8000224c:	6b8c                	ld	a1,16(a5)
    8000224e:	6f90                	ld	a2,24(a5)
    80002250:	01073023          	sd	a6,0(a4)
    80002254:	e708                	sd	a0,8(a4)
    80002256:	eb0c                	sd	a1,16(a4)
    80002258:	ef10                	sd	a2,24(a4)
    8000225a:	02078793          	addi	a5,a5,32
    8000225e:	02070713          	addi	a4,a4,32
    80002262:	fed792e3          	bne	a5,a3,80002246 <fork+0x56>
  np->trapframe->a0 = 0;
    80002266:	0609b783          	ld	a5,96(s3)
    8000226a:	0607b823          	sd	zero,112(a5)
    8000226e:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    80002272:	15800a13          	li	s4,344
    80002276:	a03d                	j	800022a4 <fork+0xb4>
    freeproc(np);
    80002278:	854e                	mv	a0,s3
    8000227a:	00000097          	auipc	ra,0x0
    8000227e:	d64080e7          	jalr	-668(ra) # 80001fde <freeproc>
    release(&np->lock);
    80002282:	854e                	mv	a0,s3
    80002284:	fffff097          	auipc	ra,0xfffff
    80002288:	bc6080e7          	jalr	-1082(ra) # 80000e4a <release>
    return -1;
    8000228c:	54fd                	li	s1,-1
    8000228e:	a899                	j	800022e4 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80002290:	00002097          	auipc	ra,0x2
    80002294:	762080e7          	jalr	1890(ra) # 800049f2 <filedup>
    80002298:	009987b3          	add	a5,s3,s1
    8000229c:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    8000229e:	04a1                	addi	s1,s1,8
    800022a0:	01448763          	beq	s1,s4,800022ae <fork+0xbe>
    if(p->ofile[i])
    800022a4:	009907b3          	add	a5,s2,s1
    800022a8:	6388                	ld	a0,0(a5)
    800022aa:	f17d                	bnez	a0,80002290 <fork+0xa0>
    800022ac:	bfcd                	j	8000229e <fork+0xae>
  np->cwd = idup(p->cwd);
    800022ae:	15893503          	ld	a0,344(s2)
    800022b2:	00002097          	auipc	ra,0x2
    800022b6:	874080e7          	jalr	-1932(ra) # 80003b26 <idup>
    800022ba:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800022be:	4641                	li	a2,16
    800022c0:	16090593          	addi	a1,s2,352
    800022c4:	16098513          	addi	a0,s3,352
    800022c8:	fffff097          	auipc	ra,0xfffff
    800022cc:	036080e7          	jalr	54(ra) # 800012fe <safestrcpy>
  pid = np->pid;
    800022d0:	0409a483          	lw	s1,64(s3)
  np->state = RUNNABLE;
    800022d4:	4789                	li	a5,2
    800022d6:	02f9a023          	sw	a5,32(s3)
  release(&np->lock);
    800022da:	854e                	mv	a0,s3
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	b6e080e7          	jalr	-1170(ra) # 80000e4a <release>
}
    800022e4:	8526                	mv	a0,s1
    800022e6:	70a2                	ld	ra,40(sp)
    800022e8:	7402                	ld	s0,32(sp)
    800022ea:	64e2                	ld	s1,24(sp)
    800022ec:	6942                	ld	s2,16(sp)
    800022ee:	69a2                	ld	s3,8(sp)
    800022f0:	6a02                	ld	s4,0(sp)
    800022f2:	6145                	addi	sp,sp,48
    800022f4:	8082                	ret
    return -1;
    800022f6:	54fd                	li	s1,-1
    800022f8:	b7f5                	j	800022e4 <fork+0xf4>

00000000800022fa <reparent>:
{
    800022fa:	7179                	addi	sp,sp,-48
    800022fc:	f406                	sd	ra,40(sp)
    800022fe:	f022                	sd	s0,32(sp)
    80002300:	ec26                	sd	s1,24(sp)
    80002302:	e84a                	sd	s2,16(sp)
    80002304:	e44e                	sd	s3,8(sp)
    80002306:	e052                	sd	s4,0(sp)
    80002308:	1800                	addi	s0,sp,48
    8000230a:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000230c:	00010497          	auipc	s1,0x10
    80002310:	49c48493          	addi	s1,s1,1180 # 800127a8 <proc>
      pp->parent = initproc;
    80002314:	00007a17          	auipc	s4,0x7
    80002318:	d04a0a13          	addi	s4,s4,-764 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000231c:	00016917          	auipc	s2,0x16
    80002320:	08c90913          	addi	s2,s2,140 # 800183a8 <tickslock>
    80002324:	a029                	j	8000232e <reparent+0x34>
    80002326:	17048493          	addi	s1,s1,368
    8000232a:	03248363          	beq	s1,s2,80002350 <reparent+0x56>
    if(pp->parent == p){
    8000232e:	749c                	ld	a5,40(s1)
    80002330:	ff379be3          	bne	a5,s3,80002326 <reparent+0x2c>
      acquire(&pp->lock);
    80002334:	8526                	mv	a0,s1
    80002336:	fffff097          	auipc	ra,0xfffff
    8000233a:	a44080e7          	jalr	-1468(ra) # 80000d7a <acquire>
      pp->parent = initproc;
    8000233e:	000a3783          	ld	a5,0(s4)
    80002342:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    80002344:	8526                	mv	a0,s1
    80002346:	fffff097          	auipc	ra,0xfffff
    8000234a:	b04080e7          	jalr	-1276(ra) # 80000e4a <release>
    8000234e:	bfe1                	j	80002326 <reparent+0x2c>
}
    80002350:	70a2                	ld	ra,40(sp)
    80002352:	7402                	ld	s0,32(sp)
    80002354:	64e2                	ld	s1,24(sp)
    80002356:	6942                	ld	s2,16(sp)
    80002358:	69a2                	ld	s3,8(sp)
    8000235a:	6a02                	ld	s4,0(sp)
    8000235c:	6145                	addi	sp,sp,48
    8000235e:	8082                	ret

0000000080002360 <scheduler>:
{
    80002360:	711d                	addi	sp,sp,-96
    80002362:	ec86                	sd	ra,88(sp)
    80002364:	e8a2                	sd	s0,80(sp)
    80002366:	e4a6                	sd	s1,72(sp)
    80002368:	e0ca                	sd	s2,64(sp)
    8000236a:	fc4e                	sd	s3,56(sp)
    8000236c:	f852                	sd	s4,48(sp)
    8000236e:	f456                	sd	s5,40(sp)
    80002370:	f05a                	sd	s6,32(sp)
    80002372:	ec5e                	sd	s7,24(sp)
    80002374:	e862                	sd	s8,16(sp)
    80002376:	e466                	sd	s9,8(sp)
    80002378:	1080                	addi	s0,sp,96
    8000237a:	8792                	mv	a5,tp
  int id = r_tp();
    8000237c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000237e:	00779c13          	slli	s8,a5,0x7
    80002382:	00010717          	auipc	a4,0x10
    80002386:	00670713          	addi	a4,a4,6 # 80012388 <pid_lock>
    8000238a:	9762                	add	a4,a4,s8
    8000238c:	02073023          	sd	zero,32(a4)
        swtch(&c->context, &p->context);
    80002390:	00010717          	auipc	a4,0x10
    80002394:	02070713          	addi	a4,a4,32 # 800123b0 <cpus+0x8>
    80002398:	9c3a                	add	s8,s8,a4
      if(p->state == RUNNABLE) {
    8000239a:	4a89                	li	s5,2
        c->proc = p;
    8000239c:	079e                	slli	a5,a5,0x7
    8000239e:	00010b17          	auipc	s6,0x10
    800023a2:	feab0b13          	addi	s6,s6,-22 # 80012388 <pid_lock>
    800023a6:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800023a8:	00016a17          	auipc	s4,0x16
    800023ac:	000a0a13          	mv	s4,s4
    int nproc = 0;
    800023b0:	4c81                	li	s9,0
    800023b2:	a8a1                	j	8000240a <scheduler+0xaa>
        p->state = RUNNING;
    800023b4:	0374a023          	sw	s7,32(s1)
        c->proc = p;
    800023b8:	029b3023          	sd	s1,32(s6)
        swtch(&c->context, &p->context);
    800023bc:	06848593          	addi	a1,s1,104
    800023c0:	8562                	mv	a0,s8
    800023c2:	00000097          	auipc	ra,0x0
    800023c6:	640080e7          	jalr	1600(ra) # 80002a02 <swtch>
        c->proc = 0;
    800023ca:	020b3023          	sd	zero,32(s6)
      release(&p->lock);
    800023ce:	8526                	mv	a0,s1
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	a7a080e7          	jalr	-1414(ra) # 80000e4a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800023d8:	17048493          	addi	s1,s1,368
    800023dc:	01448d63          	beq	s1,s4,800023f6 <scheduler+0x96>
      acquire(&p->lock);
    800023e0:	8526                	mv	a0,s1
    800023e2:	fffff097          	auipc	ra,0xfffff
    800023e6:	998080e7          	jalr	-1640(ra) # 80000d7a <acquire>
      if(p->state != UNUSED) {
    800023ea:	509c                	lw	a5,32(s1)
    800023ec:	d3ed                	beqz	a5,800023ce <scheduler+0x6e>
        nproc++;
    800023ee:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    800023f0:	fd579fe3          	bne	a5,s5,800023ce <scheduler+0x6e>
    800023f4:	b7c1                	j	800023b4 <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    800023f6:	013aca63          	blt	s5,s3,8000240a <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023fa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800023fe:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002402:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80002406:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000240a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000240e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002412:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    80002416:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    80002418:	00010497          	auipc	s1,0x10
    8000241c:	39048493          	addi	s1,s1,912 # 800127a8 <proc>
        p->state = RUNNING;
    80002420:	4b8d                	li	s7,3
    80002422:	bf7d                	j	800023e0 <scheduler+0x80>

0000000080002424 <sched>:
{
    80002424:	7179                	addi	sp,sp,-48
    80002426:	f406                	sd	ra,40(sp)
    80002428:	f022                	sd	s0,32(sp)
    8000242a:	ec26                	sd	s1,24(sp)
    8000242c:	e84a                	sd	s2,16(sp)
    8000242e:	e44e                	sd	s3,8(sp)
    80002430:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002432:	00000097          	auipc	ra,0x0
    80002436:	9f8080e7          	jalr	-1544(ra) # 80001e2a <myproc>
    8000243a:	892a                	mv	s2,a0
  if(!holding(&p->lock))
    8000243c:	fffff097          	auipc	ra,0xfffff
    80002440:	8c4080e7          	jalr	-1852(ra) # 80000d00 <holding>
    80002444:	cd25                	beqz	a0,800024bc <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002446:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002448:	2781                	sext.w	a5,a5
    8000244a:	079e                	slli	a5,a5,0x7
    8000244c:	00010717          	auipc	a4,0x10
    80002450:	f3c70713          	addi	a4,a4,-196 # 80012388 <pid_lock>
    80002454:	97ba                	add	a5,a5,a4
    80002456:	0987a703          	lw	a4,152(a5)
    8000245a:	4785                	li	a5,1
    8000245c:	06f71863          	bne	a4,a5,800024cc <sched+0xa8>
  if(p->state == RUNNING)
    80002460:	02092703          	lw	a4,32(s2)
    80002464:	478d                	li	a5,3
    80002466:	06f70b63          	beq	a4,a5,800024dc <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000246a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000246e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002470:	efb5                	bnez	a5,800024ec <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002472:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002474:	00010497          	auipc	s1,0x10
    80002478:	f1448493          	addi	s1,s1,-236 # 80012388 <pid_lock>
    8000247c:	2781                	sext.w	a5,a5
    8000247e:	079e                	slli	a5,a5,0x7
    80002480:	97a6                	add	a5,a5,s1
    80002482:	09c7a983          	lw	s3,156(a5)
    80002486:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002488:	2781                	sext.w	a5,a5
    8000248a:	079e                	slli	a5,a5,0x7
    8000248c:	00010597          	auipc	a1,0x10
    80002490:	f2458593          	addi	a1,a1,-220 # 800123b0 <cpus+0x8>
    80002494:	95be                	add	a1,a1,a5
    80002496:	06890513          	addi	a0,s2,104
    8000249a:	00000097          	auipc	ra,0x0
    8000249e:	568080e7          	jalr	1384(ra) # 80002a02 <swtch>
    800024a2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800024a4:	2781                	sext.w	a5,a5
    800024a6:	079e                	slli	a5,a5,0x7
    800024a8:	97a6                	add	a5,a5,s1
    800024aa:	0937ae23          	sw	s3,156(a5)
}
    800024ae:	70a2                	ld	ra,40(sp)
    800024b0:	7402                	ld	s0,32(sp)
    800024b2:	64e2                	ld	s1,24(sp)
    800024b4:	6942                	ld	s2,16(sp)
    800024b6:	69a2                	ld	s3,8(sp)
    800024b8:	6145                	addi	sp,sp,48
    800024ba:	8082                	ret
    panic("sched p->lock");
    800024bc:	00006517          	auipc	a0,0x6
    800024c0:	dfc50513          	addi	a0,a0,-516 # 800082b8 <states.1732+0x60>
    800024c4:	ffffe097          	auipc	ra,0xffffe
    800024c8:	0b4080e7          	jalr	180(ra) # 80000578 <panic>
    panic("sched locks");
    800024cc:	00006517          	auipc	a0,0x6
    800024d0:	dfc50513          	addi	a0,a0,-516 # 800082c8 <states.1732+0x70>
    800024d4:	ffffe097          	auipc	ra,0xffffe
    800024d8:	0a4080e7          	jalr	164(ra) # 80000578 <panic>
    panic("sched running");
    800024dc:	00006517          	auipc	a0,0x6
    800024e0:	dfc50513          	addi	a0,a0,-516 # 800082d8 <states.1732+0x80>
    800024e4:	ffffe097          	auipc	ra,0xffffe
    800024e8:	094080e7          	jalr	148(ra) # 80000578 <panic>
    panic("sched interruptible");
    800024ec:	00006517          	auipc	a0,0x6
    800024f0:	dfc50513          	addi	a0,a0,-516 # 800082e8 <states.1732+0x90>
    800024f4:	ffffe097          	auipc	ra,0xffffe
    800024f8:	084080e7          	jalr	132(ra) # 80000578 <panic>

00000000800024fc <exit>:
{
    800024fc:	7179                	addi	sp,sp,-48
    800024fe:	f406                	sd	ra,40(sp)
    80002500:	f022                	sd	s0,32(sp)
    80002502:	ec26                	sd	s1,24(sp)
    80002504:	e84a                	sd	s2,16(sp)
    80002506:	e44e                	sd	s3,8(sp)
    80002508:	e052                	sd	s4,0(sp)
    8000250a:	1800                	addi	s0,sp,48
    8000250c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000250e:	00000097          	auipc	ra,0x0
    80002512:	91c080e7          	jalr	-1764(ra) # 80001e2a <myproc>
    80002516:	89aa                	mv	s3,a0
  if(p == initproc)
    80002518:	00007797          	auipc	a5,0x7
    8000251c:	b0078793          	addi	a5,a5,-1280 # 80009018 <initproc>
    80002520:	639c                	ld	a5,0(a5)
    80002522:	0d850493          	addi	s1,a0,216
    80002526:	15850913          	addi	s2,a0,344
    8000252a:	02a79363          	bne	a5,a0,80002550 <exit+0x54>
    panic("init exiting");
    8000252e:	00006517          	auipc	a0,0x6
    80002532:	dd250513          	addi	a0,a0,-558 # 80008300 <states.1732+0xa8>
    80002536:	ffffe097          	auipc	ra,0xffffe
    8000253a:	042080e7          	jalr	66(ra) # 80000578 <panic>
      fileclose(f);
    8000253e:	00002097          	auipc	ra,0x2
    80002542:	506080e7          	jalr	1286(ra) # 80004a44 <fileclose>
      p->ofile[fd] = 0;
    80002546:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000254a:	04a1                	addi	s1,s1,8
    8000254c:	01248563          	beq	s1,s2,80002556 <exit+0x5a>
    if(p->ofile[fd]){
    80002550:	6088                	ld	a0,0(s1)
    80002552:	f575                	bnez	a0,8000253e <exit+0x42>
    80002554:	bfdd                	j	8000254a <exit+0x4e>
  begin_op();
    80002556:	00002097          	auipc	ra,0x2
    8000255a:	fea080e7          	jalr	-22(ra) # 80004540 <begin_op>
  iput(p->cwd);
    8000255e:	1589b503          	ld	a0,344(s3)
    80002562:	00001097          	auipc	ra,0x1
    80002566:	7be080e7          	jalr	1982(ra) # 80003d20 <iput>
  end_op();
    8000256a:	00002097          	auipc	ra,0x2
    8000256e:	056080e7          	jalr	86(ra) # 800045c0 <end_op>
  p->cwd = 0;
    80002572:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    80002576:	00007497          	auipc	s1,0x7
    8000257a:	aa248493          	addi	s1,s1,-1374 # 80009018 <initproc>
    8000257e:	6088                	ld	a0,0(s1)
    80002580:	ffffe097          	auipc	ra,0xffffe
    80002584:	7fa080e7          	jalr	2042(ra) # 80000d7a <acquire>
  wakeup1(initproc);
    80002588:	6088                	ld	a0,0(s1)
    8000258a:	fffff097          	auipc	ra,0xfffff
    8000258e:	760080e7          	jalr	1888(ra) # 80001cea <wakeup1>
  release(&initproc->lock);
    80002592:	6088                	ld	a0,0(s1)
    80002594:	fffff097          	auipc	ra,0xfffff
    80002598:	8b6080e7          	jalr	-1866(ra) # 80000e4a <release>
  acquire(&p->lock);
    8000259c:	854e                	mv	a0,s3
    8000259e:	ffffe097          	auipc	ra,0xffffe
    800025a2:	7dc080e7          	jalr	2012(ra) # 80000d7a <acquire>
  struct proc *original_parent = p->parent;
    800025a6:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    800025aa:	854e                	mv	a0,s3
    800025ac:	fffff097          	auipc	ra,0xfffff
    800025b0:	89e080e7          	jalr	-1890(ra) # 80000e4a <release>
  acquire(&original_parent->lock);
    800025b4:	8526                	mv	a0,s1
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	7c4080e7          	jalr	1988(ra) # 80000d7a <acquire>
  acquire(&p->lock);
    800025be:	854e                	mv	a0,s3
    800025c0:	ffffe097          	auipc	ra,0xffffe
    800025c4:	7ba080e7          	jalr	1978(ra) # 80000d7a <acquire>
  reparent(p);
    800025c8:	854e                	mv	a0,s3
    800025ca:	00000097          	auipc	ra,0x0
    800025ce:	d30080e7          	jalr	-720(ra) # 800022fa <reparent>
  wakeup1(original_parent);
    800025d2:	8526                	mv	a0,s1
    800025d4:	fffff097          	auipc	ra,0xfffff
    800025d8:	716080e7          	jalr	1814(ra) # 80001cea <wakeup1>
  p->xstate = status;
    800025dc:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    800025e0:	4791                	li	a5,4
    800025e2:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    800025e6:	8526                	mv	a0,s1
    800025e8:	fffff097          	auipc	ra,0xfffff
    800025ec:	862080e7          	jalr	-1950(ra) # 80000e4a <release>
  sched();
    800025f0:	00000097          	auipc	ra,0x0
    800025f4:	e34080e7          	jalr	-460(ra) # 80002424 <sched>
  panic("zombie exit");
    800025f8:	00006517          	auipc	a0,0x6
    800025fc:	d1850513          	addi	a0,a0,-744 # 80008310 <states.1732+0xb8>
    80002600:	ffffe097          	auipc	ra,0xffffe
    80002604:	f78080e7          	jalr	-136(ra) # 80000578 <panic>

0000000080002608 <yield>:
{
    80002608:	1101                	addi	sp,sp,-32
    8000260a:	ec06                	sd	ra,24(sp)
    8000260c:	e822                	sd	s0,16(sp)
    8000260e:	e426                	sd	s1,8(sp)
    80002610:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002612:	00000097          	auipc	ra,0x0
    80002616:	818080e7          	jalr	-2024(ra) # 80001e2a <myproc>
    8000261a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000261c:	ffffe097          	auipc	ra,0xffffe
    80002620:	75e080e7          	jalr	1886(ra) # 80000d7a <acquire>
  p->state = RUNNABLE;
    80002624:	4789                	li	a5,2
    80002626:	d09c                	sw	a5,32(s1)
  sched();
    80002628:	00000097          	auipc	ra,0x0
    8000262c:	dfc080e7          	jalr	-516(ra) # 80002424 <sched>
  release(&p->lock);
    80002630:	8526                	mv	a0,s1
    80002632:	fffff097          	auipc	ra,0xfffff
    80002636:	818080e7          	jalr	-2024(ra) # 80000e4a <release>
}
    8000263a:	60e2                	ld	ra,24(sp)
    8000263c:	6442                	ld	s0,16(sp)
    8000263e:	64a2                	ld	s1,8(sp)
    80002640:	6105                	addi	sp,sp,32
    80002642:	8082                	ret

0000000080002644 <sleep>:
{
    80002644:	7179                	addi	sp,sp,-48
    80002646:	f406                	sd	ra,40(sp)
    80002648:	f022                	sd	s0,32(sp)
    8000264a:	ec26                	sd	s1,24(sp)
    8000264c:	e84a                	sd	s2,16(sp)
    8000264e:	e44e                	sd	s3,8(sp)
    80002650:	1800                	addi	s0,sp,48
    80002652:	89aa                	mv	s3,a0
    80002654:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002656:	fffff097          	auipc	ra,0xfffff
    8000265a:	7d4080e7          	jalr	2004(ra) # 80001e2a <myproc>
    8000265e:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002660:	05250663          	beq	a0,s2,800026ac <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002664:	ffffe097          	auipc	ra,0xffffe
    80002668:	716080e7          	jalr	1814(ra) # 80000d7a <acquire>
    release(lk);
    8000266c:	854a                	mv	a0,s2
    8000266e:	ffffe097          	auipc	ra,0xffffe
    80002672:	7dc080e7          	jalr	2012(ra) # 80000e4a <release>
  p->chan = chan;
    80002676:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    8000267a:	4785                	li	a5,1
    8000267c:	d09c                	sw	a5,32(s1)
  sched();
    8000267e:	00000097          	auipc	ra,0x0
    80002682:	da6080e7          	jalr	-602(ra) # 80002424 <sched>
  p->chan = 0;
    80002686:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    8000268a:	8526                	mv	a0,s1
    8000268c:	ffffe097          	auipc	ra,0xffffe
    80002690:	7be080e7          	jalr	1982(ra) # 80000e4a <release>
    acquire(lk);
    80002694:	854a                	mv	a0,s2
    80002696:	ffffe097          	auipc	ra,0xffffe
    8000269a:	6e4080e7          	jalr	1764(ra) # 80000d7a <acquire>
}
    8000269e:	70a2                	ld	ra,40(sp)
    800026a0:	7402                	ld	s0,32(sp)
    800026a2:	64e2                	ld	s1,24(sp)
    800026a4:	6942                	ld	s2,16(sp)
    800026a6:	69a2                	ld	s3,8(sp)
    800026a8:	6145                	addi	sp,sp,48
    800026aa:	8082                	ret
  p->chan = chan;
    800026ac:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    800026b0:	4785                	li	a5,1
    800026b2:	d11c                	sw	a5,32(a0)
  sched();
    800026b4:	00000097          	auipc	ra,0x0
    800026b8:	d70080e7          	jalr	-656(ra) # 80002424 <sched>
  p->chan = 0;
    800026bc:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    800026c0:	bff9                	j	8000269e <sleep+0x5a>

00000000800026c2 <wait>:
{
    800026c2:	715d                	addi	sp,sp,-80
    800026c4:	e486                	sd	ra,72(sp)
    800026c6:	e0a2                	sd	s0,64(sp)
    800026c8:	fc26                	sd	s1,56(sp)
    800026ca:	f84a                	sd	s2,48(sp)
    800026cc:	f44e                	sd	s3,40(sp)
    800026ce:	f052                	sd	s4,32(sp)
    800026d0:	ec56                	sd	s5,24(sp)
    800026d2:	e85a                	sd	s6,16(sp)
    800026d4:	e45e                	sd	s7,8(sp)
    800026d6:	e062                	sd	s8,0(sp)
    800026d8:	0880                	addi	s0,sp,80
    800026da:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800026dc:	fffff097          	auipc	ra,0xfffff
    800026e0:	74e080e7          	jalr	1870(ra) # 80001e2a <myproc>
    800026e4:	892a                	mv	s2,a0
  acquire(&p->lock);
    800026e6:	8c2a                	mv	s8,a0
    800026e8:	ffffe097          	auipc	ra,0xffffe
    800026ec:	692080e7          	jalr	1682(ra) # 80000d7a <acquire>
    havekids = 0;
    800026f0:	4b01                	li	s6,0
        if(np->state == ZOMBIE){
    800026f2:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800026f4:	00016997          	auipc	s3,0x16
    800026f8:	cb498993          	addi	s3,s3,-844 # 800183a8 <tickslock>
        havekids = 1;
    800026fc:	4a85                	li	s5,1
    havekids = 0;
    800026fe:	875a                	mv	a4,s6
    for(np = proc; np < &proc[NPROC]; np++){
    80002700:	00010497          	auipc	s1,0x10
    80002704:	0a848493          	addi	s1,s1,168 # 800127a8 <proc>
    80002708:	a08d                	j	8000276a <wait+0xa8>
          pid = np->pid;
    8000270a:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000270e:	000b8e63          	beqz	s7,8000272a <wait+0x68>
    80002712:	4691                	li	a3,4
    80002714:	03c48613          	addi	a2,s1,60
    80002718:	85de                	mv	a1,s7
    8000271a:	05893503          	ld	a0,88(s2)
    8000271e:	fffff097          	auipc	ra,0xfffff
    80002722:	3e8080e7          	jalr	1000(ra) # 80001b06 <copyout>
    80002726:	02054263          	bltz	a0,8000274a <wait+0x88>
          freeproc(np);
    8000272a:	8526                	mv	a0,s1
    8000272c:	00000097          	auipc	ra,0x0
    80002730:	8b2080e7          	jalr	-1870(ra) # 80001fde <freeproc>
          release(&np->lock);
    80002734:	8526                	mv	a0,s1
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	714080e7          	jalr	1812(ra) # 80000e4a <release>
          release(&p->lock);
    8000273e:	854a                	mv	a0,s2
    80002740:	ffffe097          	auipc	ra,0xffffe
    80002744:	70a080e7          	jalr	1802(ra) # 80000e4a <release>
          return pid;
    80002748:	a8a9                	j	800027a2 <wait+0xe0>
            release(&np->lock);
    8000274a:	8526                	mv	a0,s1
    8000274c:	ffffe097          	auipc	ra,0xffffe
    80002750:	6fe080e7          	jalr	1790(ra) # 80000e4a <release>
            release(&p->lock);
    80002754:	854a                	mv	a0,s2
    80002756:	ffffe097          	auipc	ra,0xffffe
    8000275a:	6f4080e7          	jalr	1780(ra) # 80000e4a <release>
            return -1;
    8000275e:	59fd                	li	s3,-1
    80002760:	a089                	j	800027a2 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002762:	17048493          	addi	s1,s1,368
    80002766:	03348463          	beq	s1,s3,8000278e <wait+0xcc>
      if(np->parent == p){
    8000276a:	749c                	ld	a5,40(s1)
    8000276c:	ff279be3          	bne	a5,s2,80002762 <wait+0xa0>
        acquire(&np->lock);
    80002770:	8526                	mv	a0,s1
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	608080e7          	jalr	1544(ra) # 80000d7a <acquire>
        if(np->state == ZOMBIE){
    8000277a:	509c                	lw	a5,32(s1)
    8000277c:	f94787e3          	beq	a5,s4,8000270a <wait+0x48>
        release(&np->lock);
    80002780:	8526                	mv	a0,s1
    80002782:	ffffe097          	auipc	ra,0xffffe
    80002786:	6c8080e7          	jalr	1736(ra) # 80000e4a <release>
        havekids = 1;
    8000278a:	8756                	mv	a4,s5
    8000278c:	bfd9                	j	80002762 <wait+0xa0>
    if(!havekids || p->killed){
    8000278e:	c701                	beqz	a4,80002796 <wait+0xd4>
    80002790:	03892783          	lw	a5,56(s2)
    80002794:	c785                	beqz	a5,800027bc <wait+0xfa>
      release(&p->lock);
    80002796:	854a                	mv	a0,s2
    80002798:	ffffe097          	auipc	ra,0xffffe
    8000279c:	6b2080e7          	jalr	1714(ra) # 80000e4a <release>
      return -1;
    800027a0:	59fd                	li	s3,-1
}
    800027a2:	854e                	mv	a0,s3
    800027a4:	60a6                	ld	ra,72(sp)
    800027a6:	6406                	ld	s0,64(sp)
    800027a8:	74e2                	ld	s1,56(sp)
    800027aa:	7942                	ld	s2,48(sp)
    800027ac:	79a2                	ld	s3,40(sp)
    800027ae:	7a02                	ld	s4,32(sp)
    800027b0:	6ae2                	ld	s5,24(sp)
    800027b2:	6b42                	ld	s6,16(sp)
    800027b4:	6ba2                	ld	s7,8(sp)
    800027b6:	6c02                	ld	s8,0(sp)
    800027b8:	6161                	addi	sp,sp,80
    800027ba:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800027bc:	85e2                	mv	a1,s8
    800027be:	854a                	mv	a0,s2
    800027c0:	00000097          	auipc	ra,0x0
    800027c4:	e84080e7          	jalr	-380(ra) # 80002644 <sleep>
    havekids = 0;
    800027c8:	bf1d                	j	800026fe <wait+0x3c>

00000000800027ca <wakeup>:
{
    800027ca:	7139                	addi	sp,sp,-64
    800027cc:	fc06                	sd	ra,56(sp)
    800027ce:	f822                	sd	s0,48(sp)
    800027d0:	f426                	sd	s1,40(sp)
    800027d2:	f04a                	sd	s2,32(sp)
    800027d4:	ec4e                	sd	s3,24(sp)
    800027d6:	e852                	sd	s4,16(sp)
    800027d8:	e456                	sd	s5,8(sp)
    800027da:	0080                	addi	s0,sp,64
    800027dc:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800027de:	00010497          	auipc	s1,0x10
    800027e2:	fca48493          	addi	s1,s1,-54 # 800127a8 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800027e6:	4985                	li	s3,1
      p->state = RUNNABLE;
    800027e8:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800027ea:	00016917          	auipc	s2,0x16
    800027ee:	bbe90913          	addi	s2,s2,-1090 # 800183a8 <tickslock>
    800027f2:	a821                	j	8000280a <wakeup+0x40>
      p->state = RUNNABLE;
    800027f4:	0354a023          	sw	s5,32(s1)
    release(&p->lock);
    800027f8:	8526                	mv	a0,s1
    800027fa:	ffffe097          	auipc	ra,0xffffe
    800027fe:	650080e7          	jalr	1616(ra) # 80000e4a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002802:	17048493          	addi	s1,s1,368
    80002806:	01248e63          	beq	s1,s2,80002822 <wakeup+0x58>
    acquire(&p->lock);
    8000280a:	8526                	mv	a0,s1
    8000280c:	ffffe097          	auipc	ra,0xffffe
    80002810:	56e080e7          	jalr	1390(ra) # 80000d7a <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002814:	509c                	lw	a5,32(s1)
    80002816:	ff3791e3          	bne	a5,s3,800027f8 <wakeup+0x2e>
    8000281a:	789c                	ld	a5,48(s1)
    8000281c:	fd479ee3          	bne	a5,s4,800027f8 <wakeup+0x2e>
    80002820:	bfd1                	j	800027f4 <wakeup+0x2a>
}
    80002822:	70e2                	ld	ra,56(sp)
    80002824:	7442                	ld	s0,48(sp)
    80002826:	74a2                	ld	s1,40(sp)
    80002828:	7902                	ld	s2,32(sp)
    8000282a:	69e2                	ld	s3,24(sp)
    8000282c:	6a42                	ld	s4,16(sp)
    8000282e:	6aa2                	ld	s5,8(sp)
    80002830:	6121                	addi	sp,sp,64
    80002832:	8082                	ret

0000000080002834 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002834:	7179                	addi	sp,sp,-48
    80002836:	f406                	sd	ra,40(sp)
    80002838:	f022                	sd	s0,32(sp)
    8000283a:	ec26                	sd	s1,24(sp)
    8000283c:	e84a                	sd	s2,16(sp)
    8000283e:	e44e                	sd	s3,8(sp)
    80002840:	1800                	addi	s0,sp,48
    80002842:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002844:	00010497          	auipc	s1,0x10
    80002848:	f6448493          	addi	s1,s1,-156 # 800127a8 <proc>
    8000284c:	00016997          	auipc	s3,0x16
    80002850:	b5c98993          	addi	s3,s3,-1188 # 800183a8 <tickslock>
    acquire(&p->lock);
    80002854:	8526                	mv	a0,s1
    80002856:	ffffe097          	auipc	ra,0xffffe
    8000285a:	524080e7          	jalr	1316(ra) # 80000d7a <acquire>
    if(p->pid == pid){
    8000285e:	40bc                	lw	a5,64(s1)
    80002860:	01278d63          	beq	a5,s2,8000287a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002864:	8526                	mv	a0,s1
    80002866:	ffffe097          	auipc	ra,0xffffe
    8000286a:	5e4080e7          	jalr	1508(ra) # 80000e4a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000286e:	17048493          	addi	s1,s1,368
    80002872:	ff3491e3          	bne	s1,s3,80002854 <kill+0x20>
  }
  return -1;
    80002876:	557d                	li	a0,-1
    80002878:	a829                	j	80002892 <kill+0x5e>
      p->killed = 1;
    8000287a:	4785                	li	a5,1
    8000287c:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    8000287e:	5098                	lw	a4,32(s1)
    80002880:	4785                	li	a5,1
    80002882:	00f70f63          	beq	a4,a5,800028a0 <kill+0x6c>
      release(&p->lock);
    80002886:	8526                	mv	a0,s1
    80002888:	ffffe097          	auipc	ra,0xffffe
    8000288c:	5c2080e7          	jalr	1474(ra) # 80000e4a <release>
      return 0;
    80002890:	4501                	li	a0,0
}
    80002892:	70a2                	ld	ra,40(sp)
    80002894:	7402                	ld	s0,32(sp)
    80002896:	64e2                	ld	s1,24(sp)
    80002898:	6942                	ld	s2,16(sp)
    8000289a:	69a2                	ld	s3,8(sp)
    8000289c:	6145                	addi	sp,sp,48
    8000289e:	8082                	ret
        p->state = RUNNABLE;
    800028a0:	4789                	li	a5,2
    800028a2:	d09c                	sw	a5,32(s1)
    800028a4:	b7cd                	j	80002886 <kill+0x52>

00000000800028a6 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800028a6:	7179                	addi	sp,sp,-48
    800028a8:	f406                	sd	ra,40(sp)
    800028aa:	f022                	sd	s0,32(sp)
    800028ac:	ec26                	sd	s1,24(sp)
    800028ae:	e84a                	sd	s2,16(sp)
    800028b0:	e44e                	sd	s3,8(sp)
    800028b2:	e052                	sd	s4,0(sp)
    800028b4:	1800                	addi	s0,sp,48
    800028b6:	84aa                	mv	s1,a0
    800028b8:	892e                	mv	s2,a1
    800028ba:	89b2                	mv	s3,a2
    800028bc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028be:	fffff097          	auipc	ra,0xfffff
    800028c2:	56c080e7          	jalr	1388(ra) # 80001e2a <myproc>
  if(user_dst){
    800028c6:	c08d                	beqz	s1,800028e8 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800028c8:	86d2                	mv	a3,s4
    800028ca:	864e                	mv	a2,s3
    800028cc:	85ca                	mv	a1,s2
    800028ce:	6d28                	ld	a0,88(a0)
    800028d0:	fffff097          	auipc	ra,0xfffff
    800028d4:	236080e7          	jalr	566(ra) # 80001b06 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800028d8:	70a2                	ld	ra,40(sp)
    800028da:	7402                	ld	s0,32(sp)
    800028dc:	64e2                	ld	s1,24(sp)
    800028de:	6942                	ld	s2,16(sp)
    800028e0:	69a2                	ld	s3,8(sp)
    800028e2:	6a02                	ld	s4,0(sp)
    800028e4:	6145                	addi	sp,sp,48
    800028e6:	8082                	ret
    memmove((char *)dst, src, len);
    800028e8:	000a061b          	sext.w	a2,s4
    800028ec:	85ce                	mv	a1,s3
    800028ee:	854a                	mv	a0,s2
    800028f0:	fffff097          	auipc	ra,0xfffff
    800028f4:	902080e7          	jalr	-1790(ra) # 800011f2 <memmove>
    return 0;
    800028f8:	8526                	mv	a0,s1
    800028fa:	bff9                	j	800028d8 <either_copyout+0x32>

00000000800028fc <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800028fc:	7179                	addi	sp,sp,-48
    800028fe:	f406                	sd	ra,40(sp)
    80002900:	f022                	sd	s0,32(sp)
    80002902:	ec26                	sd	s1,24(sp)
    80002904:	e84a                	sd	s2,16(sp)
    80002906:	e44e                	sd	s3,8(sp)
    80002908:	e052                	sd	s4,0(sp)
    8000290a:	1800                	addi	s0,sp,48
    8000290c:	892a                	mv	s2,a0
    8000290e:	84ae                	mv	s1,a1
    80002910:	89b2                	mv	s3,a2
    80002912:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002914:	fffff097          	auipc	ra,0xfffff
    80002918:	516080e7          	jalr	1302(ra) # 80001e2a <myproc>
  if(user_src){
    8000291c:	c08d                	beqz	s1,8000293e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000291e:	86d2                	mv	a3,s4
    80002920:	864e                	mv	a2,s3
    80002922:	85ca                	mv	a1,s2
    80002924:	6d28                	ld	a0,88(a0)
    80002926:	fffff097          	auipc	ra,0xfffff
    8000292a:	26c080e7          	jalr	620(ra) # 80001b92 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000292e:	70a2                	ld	ra,40(sp)
    80002930:	7402                	ld	s0,32(sp)
    80002932:	64e2                	ld	s1,24(sp)
    80002934:	6942                	ld	s2,16(sp)
    80002936:	69a2                	ld	s3,8(sp)
    80002938:	6a02                	ld	s4,0(sp)
    8000293a:	6145                	addi	sp,sp,48
    8000293c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000293e:	000a061b          	sext.w	a2,s4
    80002942:	85ce                	mv	a1,s3
    80002944:	854a                	mv	a0,s2
    80002946:	fffff097          	auipc	ra,0xfffff
    8000294a:	8ac080e7          	jalr	-1876(ra) # 800011f2 <memmove>
    return 0;
    8000294e:	8526                	mv	a0,s1
    80002950:	bff9                	j	8000292e <either_copyin+0x32>

0000000080002952 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002952:	715d                	addi	sp,sp,-80
    80002954:	e486                	sd	ra,72(sp)
    80002956:	e0a2                	sd	s0,64(sp)
    80002958:	fc26                	sd	s1,56(sp)
    8000295a:	f84a                	sd	s2,48(sp)
    8000295c:	f44e                	sd	s3,40(sp)
    8000295e:	f052                	sd	s4,32(sp)
    80002960:	ec56                	sd	s5,24(sp)
    80002962:	e85a                	sd	s6,16(sp)
    80002964:	e45e                	sd	s7,8(sp)
    80002966:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002968:	00005517          	auipc	a0,0x5
    8000296c:	7f850513          	addi	a0,a0,2040 # 80008160 <digits+0x148>
    80002970:	ffffe097          	auipc	ra,0xffffe
    80002974:	c52080e7          	jalr	-942(ra) # 800005c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002978:	00010497          	auipc	s1,0x10
    8000297c:	f9048493          	addi	s1,s1,-112 # 80012908 <proc+0x160>
    80002980:	00016917          	auipc	s2,0x16
    80002984:	b8890913          	addi	s2,s2,-1144 # 80018508 <bcachebucket+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002988:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    8000298a:	00006997          	auipc	s3,0x6
    8000298e:	99698993          	addi	s3,s3,-1642 # 80008320 <states.1732+0xc8>
    printf("%d %s %s", p->pid, state, p->name);
    80002992:	00006a97          	auipc	s5,0x6
    80002996:	996a8a93          	addi	s5,s5,-1642 # 80008328 <states.1732+0xd0>
    printf("\n");
    8000299a:	00005a17          	auipc	s4,0x5
    8000299e:	7c6a0a13          	addi	s4,s4,1990 # 80008160 <digits+0x148>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029a2:	00006b97          	auipc	s7,0x6
    800029a6:	8b6b8b93          	addi	s7,s7,-1866 # 80008258 <states.1732>
    800029aa:	a015                	j	800029ce <procdump+0x7c>
    printf("%d %s %s", p->pid, state, p->name);
    800029ac:	86ba                	mv	a3,a4
    800029ae:	ee072583          	lw	a1,-288(a4)
    800029b2:	8556                	mv	a0,s5
    800029b4:	ffffe097          	auipc	ra,0xffffe
    800029b8:	c0e080e7          	jalr	-1010(ra) # 800005c2 <printf>
    printf("\n");
    800029bc:	8552                	mv	a0,s4
    800029be:	ffffe097          	auipc	ra,0xffffe
    800029c2:	c04080e7          	jalr	-1020(ra) # 800005c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800029c6:	17048493          	addi	s1,s1,368
    800029ca:	03248163          	beq	s1,s2,800029ec <procdump+0x9a>
    if(p->state == UNUSED)
    800029ce:	8726                	mv	a4,s1
    800029d0:	ec04a783          	lw	a5,-320(s1)
    800029d4:	dbed                	beqz	a5,800029c6 <procdump+0x74>
      state = "???";
    800029d6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029d8:	fcfb6ae3          	bltu	s6,a5,800029ac <procdump+0x5a>
    800029dc:	1782                	slli	a5,a5,0x20
    800029de:	9381                	srli	a5,a5,0x20
    800029e0:	078e                	slli	a5,a5,0x3
    800029e2:	97de                	add	a5,a5,s7
    800029e4:	6390                	ld	a2,0(a5)
    800029e6:	f279                	bnez	a2,800029ac <procdump+0x5a>
      state = "???";
    800029e8:	864e                	mv	a2,s3
    800029ea:	b7c9                	j	800029ac <procdump+0x5a>
  }
}
    800029ec:	60a6                	ld	ra,72(sp)
    800029ee:	6406                	ld	s0,64(sp)
    800029f0:	74e2                	ld	s1,56(sp)
    800029f2:	7942                	ld	s2,48(sp)
    800029f4:	79a2                	ld	s3,40(sp)
    800029f6:	7a02                	ld	s4,32(sp)
    800029f8:	6ae2                	ld	s5,24(sp)
    800029fa:	6b42                	ld	s6,16(sp)
    800029fc:	6ba2                	ld	s7,8(sp)
    800029fe:	6161                	addi	sp,sp,80
    80002a00:	8082                	ret

0000000080002a02 <swtch>:
    80002a02:	00153023          	sd	ra,0(a0)
    80002a06:	00253423          	sd	sp,8(a0)
    80002a0a:	e900                	sd	s0,16(a0)
    80002a0c:	ed04                	sd	s1,24(a0)
    80002a0e:	03253023          	sd	s2,32(a0)
    80002a12:	03353423          	sd	s3,40(a0)
    80002a16:	03453823          	sd	s4,48(a0)
    80002a1a:	03553c23          	sd	s5,56(a0)
    80002a1e:	05653023          	sd	s6,64(a0)
    80002a22:	05753423          	sd	s7,72(a0)
    80002a26:	05853823          	sd	s8,80(a0)
    80002a2a:	05953c23          	sd	s9,88(a0)
    80002a2e:	07a53023          	sd	s10,96(a0)
    80002a32:	07b53423          	sd	s11,104(a0)
    80002a36:	0005b083          	ld	ra,0(a1)
    80002a3a:	0085b103          	ld	sp,8(a1)
    80002a3e:	6980                	ld	s0,16(a1)
    80002a40:	6d84                	ld	s1,24(a1)
    80002a42:	0205b903          	ld	s2,32(a1)
    80002a46:	0285b983          	ld	s3,40(a1)
    80002a4a:	0305ba03          	ld	s4,48(a1)
    80002a4e:	0385ba83          	ld	s5,56(a1)
    80002a52:	0405bb03          	ld	s6,64(a1)
    80002a56:	0485bb83          	ld	s7,72(a1)
    80002a5a:	0505bc03          	ld	s8,80(a1)
    80002a5e:	0585bc83          	ld	s9,88(a1)
    80002a62:	0605bd03          	ld	s10,96(a1)
    80002a66:	0685bd83          	ld	s11,104(a1)
    80002a6a:	8082                	ret

0000000080002a6c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a6c:	1141                	addi	sp,sp,-16
    80002a6e:	e406                	sd	ra,8(sp)
    80002a70:	e022                	sd	s0,0(sp)
    80002a72:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a74:	00006597          	auipc	a1,0x6
    80002a78:	8ec58593          	addi	a1,a1,-1812 # 80008360 <states.1732+0x108>
    80002a7c:	00016517          	auipc	a0,0x16
    80002a80:	92c50513          	addi	a0,a0,-1748 # 800183a8 <tickslock>
    80002a84:	ffffe097          	auipc	ra,0xffffe
    80002a88:	482080e7          	jalr	1154(ra) # 80000f06 <initlock>
}
    80002a8c:	60a2                	ld	ra,8(sp)
    80002a8e:	6402                	ld	s0,0(sp)
    80002a90:	0141                	addi	sp,sp,16
    80002a92:	8082                	ret

0000000080002a94 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a94:	1141                	addi	sp,sp,-16
    80002a96:	e422                	sd	s0,8(sp)
    80002a98:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a9a:	00003797          	auipc	a5,0x3
    80002a9e:	66678793          	addi	a5,a5,1638 # 80006100 <kernelvec>
    80002aa2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002aa6:	6422                	ld	s0,8(sp)
    80002aa8:	0141                	addi	sp,sp,16
    80002aaa:	8082                	ret

0000000080002aac <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002aac:	1141                	addi	sp,sp,-16
    80002aae:	e406                	sd	ra,8(sp)
    80002ab0:	e022                	sd	s0,0(sp)
    80002ab2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002ab4:	fffff097          	auipc	ra,0xfffff
    80002ab8:	376080e7          	jalr	886(ra) # 80001e2a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002abc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002ac0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ac2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002ac6:	00004617          	auipc	a2,0x4
    80002aca:	53a60613          	addi	a2,a2,1338 # 80007000 <_trampoline>
    80002ace:	00004697          	auipc	a3,0x4
    80002ad2:	53268693          	addi	a3,a3,1330 # 80007000 <_trampoline>
    80002ad6:	8e91                	sub	a3,a3,a2
    80002ad8:	040007b7          	lui	a5,0x4000
    80002adc:	17fd                	addi	a5,a5,-1
    80002ade:	07b2                	slli	a5,a5,0xc
    80002ae0:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ae2:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002ae6:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002ae8:	180026f3          	csrr	a3,satp
    80002aec:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002aee:	7138                	ld	a4,96(a0)
    80002af0:	6534                	ld	a3,72(a0)
    80002af2:	6585                	lui	a1,0x1
    80002af4:	96ae                	add	a3,a3,a1
    80002af6:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002af8:	7138                	ld	a4,96(a0)
    80002afa:	00000697          	auipc	a3,0x0
    80002afe:	13868693          	addi	a3,a3,312 # 80002c32 <usertrap>
    80002b02:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b04:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b06:	8692                	mv	a3,tp
    80002b08:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b0a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b0e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b12:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b16:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b1a:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b1c:	6f18                	ld	a4,24(a4)
    80002b1e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b22:	6d2c                	ld	a1,88(a0)
    80002b24:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002b26:	00004717          	auipc	a4,0x4
    80002b2a:	56a70713          	addi	a4,a4,1386 # 80007090 <userret>
    80002b2e:	8f11                	sub	a4,a4,a2
    80002b30:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002b32:	577d                	li	a4,-1
    80002b34:	177e                	slli	a4,a4,0x3f
    80002b36:	8dd9                	or	a1,a1,a4
    80002b38:	02000537          	lui	a0,0x2000
    80002b3c:	157d                	addi	a0,a0,-1
    80002b3e:	0536                	slli	a0,a0,0xd
    80002b40:	9782                	jalr	a5
}
    80002b42:	60a2                	ld	ra,8(sp)
    80002b44:	6402                	ld	s0,0(sp)
    80002b46:	0141                	addi	sp,sp,16
    80002b48:	8082                	ret

0000000080002b4a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b4a:	1101                	addi	sp,sp,-32
    80002b4c:	ec06                	sd	ra,24(sp)
    80002b4e:	e822                	sd	s0,16(sp)
    80002b50:	e426                	sd	s1,8(sp)
    80002b52:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002b54:	00016497          	auipc	s1,0x16
    80002b58:	85448493          	addi	s1,s1,-1964 # 800183a8 <tickslock>
    80002b5c:	8526                	mv	a0,s1
    80002b5e:	ffffe097          	auipc	ra,0xffffe
    80002b62:	21c080e7          	jalr	540(ra) # 80000d7a <acquire>
  ticks++;
    80002b66:	00006517          	auipc	a0,0x6
    80002b6a:	4ba50513          	addi	a0,a0,1210 # 80009020 <ticks>
    80002b6e:	411c                	lw	a5,0(a0)
    80002b70:	2785                	addiw	a5,a5,1
    80002b72:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002b74:	00000097          	auipc	ra,0x0
    80002b78:	c56080e7          	jalr	-938(ra) # 800027ca <wakeup>
  release(&tickslock);
    80002b7c:	8526                	mv	a0,s1
    80002b7e:	ffffe097          	auipc	ra,0xffffe
    80002b82:	2cc080e7          	jalr	716(ra) # 80000e4a <release>
}
    80002b86:	60e2                	ld	ra,24(sp)
    80002b88:	6442                	ld	s0,16(sp)
    80002b8a:	64a2                	ld	s1,8(sp)
    80002b8c:	6105                	addi	sp,sp,32
    80002b8e:	8082                	ret

0000000080002b90 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002b90:	1101                	addi	sp,sp,-32
    80002b92:	ec06                	sd	ra,24(sp)
    80002b94:	e822                	sd	s0,16(sp)
    80002b96:	e426                	sd	s1,8(sp)
    80002b98:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b9a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002b9e:	00074d63          	bltz	a4,80002bb8 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002ba2:	57fd                	li	a5,-1
    80002ba4:	17fe                	slli	a5,a5,0x3f
    80002ba6:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002ba8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002baa:	06f70363          	beq	a4,a5,80002c10 <devintr+0x80>
  }
}
    80002bae:	60e2                	ld	ra,24(sp)
    80002bb0:	6442                	ld	s0,16(sp)
    80002bb2:	64a2                	ld	s1,8(sp)
    80002bb4:	6105                	addi	sp,sp,32
    80002bb6:	8082                	ret
     (scause & 0xff) == 9){
    80002bb8:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002bbc:	46a5                	li	a3,9
    80002bbe:	fed792e3          	bne	a5,a3,80002ba2 <devintr+0x12>
    int irq = plic_claim();
    80002bc2:	00003097          	auipc	ra,0x3
    80002bc6:	646080e7          	jalr	1606(ra) # 80006208 <plic_claim>
    80002bca:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002bcc:	47a9                	li	a5,10
    80002bce:	02f50763          	beq	a0,a5,80002bfc <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002bd2:	4785                	li	a5,1
    80002bd4:	02f50963          	beq	a0,a5,80002c06 <devintr+0x76>
    return 1;
    80002bd8:	4505                	li	a0,1
    } else if(irq){
    80002bda:	d8f1                	beqz	s1,80002bae <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002bdc:	85a6                	mv	a1,s1
    80002bde:	00005517          	auipc	a0,0x5
    80002be2:	78a50513          	addi	a0,a0,1930 # 80008368 <states.1732+0x110>
    80002be6:	ffffe097          	auipc	ra,0xffffe
    80002bea:	9dc080e7          	jalr	-1572(ra) # 800005c2 <printf>
      plic_complete(irq);
    80002bee:	8526                	mv	a0,s1
    80002bf0:	00003097          	auipc	ra,0x3
    80002bf4:	63c080e7          	jalr	1596(ra) # 8000622c <plic_complete>
    return 1;
    80002bf8:	4505                	li	a0,1
    80002bfa:	bf55                	j	80002bae <devintr+0x1e>
      uartintr();
    80002bfc:	ffffe097          	auipc	ra,0xffffe
    80002c00:	e2a080e7          	jalr	-470(ra) # 80000a26 <uartintr>
    80002c04:	b7ed                	j	80002bee <devintr+0x5e>
      virtio_disk_intr();
    80002c06:	00004097          	auipc	ra,0x4
    80002c0a:	b24080e7          	jalr	-1244(ra) # 8000672a <virtio_disk_intr>
    80002c0e:	b7c5                	j	80002bee <devintr+0x5e>
    if(cpuid() == 0){
    80002c10:	fffff097          	auipc	ra,0xfffff
    80002c14:	1ee080e7          	jalr	494(ra) # 80001dfe <cpuid>
    80002c18:	c901                	beqz	a0,80002c28 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c1a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c1e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c20:	14479073          	csrw	sip,a5
    return 2;
    80002c24:	4509                	li	a0,2
    80002c26:	b761                	j	80002bae <devintr+0x1e>
      clockintr();
    80002c28:	00000097          	auipc	ra,0x0
    80002c2c:	f22080e7          	jalr	-222(ra) # 80002b4a <clockintr>
    80002c30:	b7ed                	j	80002c1a <devintr+0x8a>

0000000080002c32 <usertrap>:
{
    80002c32:	1101                	addi	sp,sp,-32
    80002c34:	ec06                	sd	ra,24(sp)
    80002c36:	e822                	sd	s0,16(sp)
    80002c38:	e426                	sd	s1,8(sp)
    80002c3a:	e04a                	sd	s2,0(sp)
    80002c3c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c3e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c42:	1007f793          	andi	a5,a5,256
    80002c46:	e3ad                	bnez	a5,80002ca8 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c48:	00003797          	auipc	a5,0x3
    80002c4c:	4b878793          	addi	a5,a5,1208 # 80006100 <kernelvec>
    80002c50:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c54:	fffff097          	auipc	ra,0xfffff
    80002c58:	1d6080e7          	jalr	470(ra) # 80001e2a <myproc>
    80002c5c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c5e:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c60:	14102773          	csrr	a4,sepc
    80002c64:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c66:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c6a:	47a1                	li	a5,8
    80002c6c:	04f71c63          	bne	a4,a5,80002cc4 <usertrap+0x92>
    if(p->killed)
    80002c70:	5d1c                	lw	a5,56(a0)
    80002c72:	e3b9                	bnez	a5,80002cb8 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002c74:	70b8                	ld	a4,96(s1)
    80002c76:	6f1c                	ld	a5,24(a4)
    80002c78:	0791                	addi	a5,a5,4
    80002c7a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c7c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c80:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c84:	10079073          	csrw	sstatus,a5
    syscall();
    80002c88:	00000097          	auipc	ra,0x0
    80002c8c:	2e6080e7          	jalr	742(ra) # 80002f6e <syscall>
  if(p->killed)
    80002c90:	5c9c                	lw	a5,56(s1)
    80002c92:	ebc1                	bnez	a5,80002d22 <usertrap+0xf0>
  usertrapret();
    80002c94:	00000097          	auipc	ra,0x0
    80002c98:	e18080e7          	jalr	-488(ra) # 80002aac <usertrapret>
}
    80002c9c:	60e2                	ld	ra,24(sp)
    80002c9e:	6442                	ld	s0,16(sp)
    80002ca0:	64a2                	ld	s1,8(sp)
    80002ca2:	6902                	ld	s2,0(sp)
    80002ca4:	6105                	addi	sp,sp,32
    80002ca6:	8082                	ret
    panic("usertrap: not from user mode");
    80002ca8:	00005517          	auipc	a0,0x5
    80002cac:	6e050513          	addi	a0,a0,1760 # 80008388 <states.1732+0x130>
    80002cb0:	ffffe097          	auipc	ra,0xffffe
    80002cb4:	8c8080e7          	jalr	-1848(ra) # 80000578 <panic>
      exit(-1);
    80002cb8:	557d                	li	a0,-1
    80002cba:	00000097          	auipc	ra,0x0
    80002cbe:	842080e7          	jalr	-1982(ra) # 800024fc <exit>
    80002cc2:	bf4d                	j	80002c74 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002cc4:	00000097          	auipc	ra,0x0
    80002cc8:	ecc080e7          	jalr	-308(ra) # 80002b90 <devintr>
    80002ccc:	892a                	mv	s2,a0
    80002cce:	c501                	beqz	a0,80002cd6 <usertrap+0xa4>
  if(p->killed)
    80002cd0:	5c9c                	lw	a5,56(s1)
    80002cd2:	c3a1                	beqz	a5,80002d12 <usertrap+0xe0>
    80002cd4:	a815                	j	80002d08 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cd6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002cda:	40b0                	lw	a2,64(s1)
    80002cdc:	00005517          	auipc	a0,0x5
    80002ce0:	6cc50513          	addi	a0,a0,1740 # 800083a8 <states.1732+0x150>
    80002ce4:	ffffe097          	auipc	ra,0xffffe
    80002ce8:	8de080e7          	jalr	-1826(ra) # 800005c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cec:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cf0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cf4:	00005517          	auipc	a0,0x5
    80002cf8:	6e450513          	addi	a0,a0,1764 # 800083d8 <states.1732+0x180>
    80002cfc:	ffffe097          	auipc	ra,0xffffe
    80002d00:	8c6080e7          	jalr	-1850(ra) # 800005c2 <printf>
    p->killed = 1;
    80002d04:	4785                	li	a5,1
    80002d06:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002d08:	557d                	li	a0,-1
    80002d0a:	fffff097          	auipc	ra,0xfffff
    80002d0e:	7f2080e7          	jalr	2034(ra) # 800024fc <exit>
  if(which_dev == 2)
    80002d12:	4789                	li	a5,2
    80002d14:	f8f910e3          	bne	s2,a5,80002c94 <usertrap+0x62>
    yield();
    80002d18:	00000097          	auipc	ra,0x0
    80002d1c:	8f0080e7          	jalr	-1808(ra) # 80002608 <yield>
    80002d20:	bf95                	j	80002c94 <usertrap+0x62>
  int which_dev = 0;
    80002d22:	4901                	li	s2,0
    80002d24:	b7d5                	j	80002d08 <usertrap+0xd6>

0000000080002d26 <kerneltrap>:
{
    80002d26:	7179                	addi	sp,sp,-48
    80002d28:	f406                	sd	ra,40(sp)
    80002d2a:	f022                	sd	s0,32(sp)
    80002d2c:	ec26                	sd	s1,24(sp)
    80002d2e:	e84a                	sd	s2,16(sp)
    80002d30:	e44e                	sd	s3,8(sp)
    80002d32:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d34:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d38:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d3c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002d40:	1004f793          	andi	a5,s1,256
    80002d44:	cb85                	beqz	a5,80002d74 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d46:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d4a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d4c:	ef85                	bnez	a5,80002d84 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002d4e:	00000097          	auipc	ra,0x0
    80002d52:	e42080e7          	jalr	-446(ra) # 80002b90 <devintr>
    80002d56:	cd1d                	beqz	a0,80002d94 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d58:	4789                	li	a5,2
    80002d5a:	06f50a63          	beq	a0,a5,80002dce <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d5e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d62:	10049073          	csrw	sstatus,s1
}
    80002d66:	70a2                	ld	ra,40(sp)
    80002d68:	7402                	ld	s0,32(sp)
    80002d6a:	64e2                	ld	s1,24(sp)
    80002d6c:	6942                	ld	s2,16(sp)
    80002d6e:	69a2                	ld	s3,8(sp)
    80002d70:	6145                	addi	sp,sp,48
    80002d72:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d74:	00005517          	auipc	a0,0x5
    80002d78:	68450513          	addi	a0,a0,1668 # 800083f8 <states.1732+0x1a0>
    80002d7c:	ffffd097          	auipc	ra,0xffffd
    80002d80:	7fc080e7          	jalr	2044(ra) # 80000578 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d84:	00005517          	auipc	a0,0x5
    80002d88:	69c50513          	addi	a0,a0,1692 # 80008420 <states.1732+0x1c8>
    80002d8c:	ffffd097          	auipc	ra,0xffffd
    80002d90:	7ec080e7          	jalr	2028(ra) # 80000578 <panic>
    printf("scause %p\n", scause);
    80002d94:	85ce                	mv	a1,s3
    80002d96:	00005517          	auipc	a0,0x5
    80002d9a:	6aa50513          	addi	a0,a0,1706 # 80008440 <states.1732+0x1e8>
    80002d9e:	ffffe097          	auipc	ra,0xffffe
    80002da2:	824080e7          	jalr	-2012(ra) # 800005c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002da6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002daa:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002dae:	00005517          	auipc	a0,0x5
    80002db2:	6a250513          	addi	a0,a0,1698 # 80008450 <states.1732+0x1f8>
    80002db6:	ffffe097          	auipc	ra,0xffffe
    80002dba:	80c080e7          	jalr	-2036(ra) # 800005c2 <printf>
    panic("kerneltrap");
    80002dbe:	00005517          	auipc	a0,0x5
    80002dc2:	6aa50513          	addi	a0,a0,1706 # 80008468 <states.1732+0x210>
    80002dc6:	ffffd097          	auipc	ra,0xffffd
    80002dca:	7b2080e7          	jalr	1970(ra) # 80000578 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002dce:	fffff097          	auipc	ra,0xfffff
    80002dd2:	05c080e7          	jalr	92(ra) # 80001e2a <myproc>
    80002dd6:	d541                	beqz	a0,80002d5e <kerneltrap+0x38>
    80002dd8:	fffff097          	auipc	ra,0xfffff
    80002ddc:	052080e7          	jalr	82(ra) # 80001e2a <myproc>
    80002de0:	5118                	lw	a4,32(a0)
    80002de2:	478d                	li	a5,3
    80002de4:	f6f71de3          	bne	a4,a5,80002d5e <kerneltrap+0x38>
    yield();
    80002de8:	00000097          	auipc	ra,0x0
    80002dec:	820080e7          	jalr	-2016(ra) # 80002608 <yield>
    80002df0:	b7bd                	j	80002d5e <kerneltrap+0x38>

0000000080002df2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002df2:	1101                	addi	sp,sp,-32
    80002df4:	ec06                	sd	ra,24(sp)
    80002df6:	e822                	sd	s0,16(sp)
    80002df8:	e426                	sd	s1,8(sp)
    80002dfa:	1000                	addi	s0,sp,32
    80002dfc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002dfe:	fffff097          	auipc	ra,0xfffff
    80002e02:	02c080e7          	jalr	44(ra) # 80001e2a <myproc>
  switch (n) {
    80002e06:	4795                	li	a5,5
    80002e08:	0497e363          	bltu	a5,s1,80002e4e <argraw+0x5c>
    80002e0c:	1482                	slli	s1,s1,0x20
    80002e0e:	9081                	srli	s1,s1,0x20
    80002e10:	048a                	slli	s1,s1,0x2
    80002e12:	00005717          	auipc	a4,0x5
    80002e16:	66670713          	addi	a4,a4,1638 # 80008478 <states.1732+0x220>
    80002e1a:	94ba                	add	s1,s1,a4
    80002e1c:	409c                	lw	a5,0(s1)
    80002e1e:	97ba                	add	a5,a5,a4
    80002e20:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002e22:	713c                	ld	a5,96(a0)
    80002e24:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e26:	60e2                	ld	ra,24(sp)
    80002e28:	6442                	ld	s0,16(sp)
    80002e2a:	64a2                	ld	s1,8(sp)
    80002e2c:	6105                	addi	sp,sp,32
    80002e2e:	8082                	ret
    return p->trapframe->a1;
    80002e30:	713c                	ld	a5,96(a0)
    80002e32:	7fa8                	ld	a0,120(a5)
    80002e34:	bfcd                	j	80002e26 <argraw+0x34>
    return p->trapframe->a2;
    80002e36:	713c                	ld	a5,96(a0)
    80002e38:	63c8                	ld	a0,128(a5)
    80002e3a:	b7f5                	j	80002e26 <argraw+0x34>
    return p->trapframe->a3;
    80002e3c:	713c                	ld	a5,96(a0)
    80002e3e:	67c8                	ld	a0,136(a5)
    80002e40:	b7dd                	j	80002e26 <argraw+0x34>
    return p->trapframe->a4;
    80002e42:	713c                	ld	a5,96(a0)
    80002e44:	6bc8                	ld	a0,144(a5)
    80002e46:	b7c5                	j	80002e26 <argraw+0x34>
    return p->trapframe->a5;
    80002e48:	713c                	ld	a5,96(a0)
    80002e4a:	6fc8                	ld	a0,152(a5)
    80002e4c:	bfe9                	j	80002e26 <argraw+0x34>
  panic("argraw");
    80002e4e:	00005517          	auipc	a0,0x5
    80002e52:	6f250513          	addi	a0,a0,1778 # 80008540 <syscalls+0xb0>
    80002e56:	ffffd097          	auipc	ra,0xffffd
    80002e5a:	722080e7          	jalr	1826(ra) # 80000578 <panic>

0000000080002e5e <fetchaddr>:
{
    80002e5e:	1101                	addi	sp,sp,-32
    80002e60:	ec06                	sd	ra,24(sp)
    80002e62:	e822                	sd	s0,16(sp)
    80002e64:	e426                	sd	s1,8(sp)
    80002e66:	e04a                	sd	s2,0(sp)
    80002e68:	1000                	addi	s0,sp,32
    80002e6a:	84aa                	mv	s1,a0
    80002e6c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e6e:	fffff097          	auipc	ra,0xfffff
    80002e72:	fbc080e7          	jalr	-68(ra) # 80001e2a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002e76:	693c                	ld	a5,80(a0)
    80002e78:	02f4f963          	bleu	a5,s1,80002eaa <fetchaddr+0x4c>
    80002e7c:	00848713          	addi	a4,s1,8
    80002e80:	02e7e763          	bltu	a5,a4,80002eae <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e84:	46a1                	li	a3,8
    80002e86:	8626                	mv	a2,s1
    80002e88:	85ca                	mv	a1,s2
    80002e8a:	6d28                	ld	a0,88(a0)
    80002e8c:	fffff097          	auipc	ra,0xfffff
    80002e90:	d06080e7          	jalr	-762(ra) # 80001b92 <copyin>
    80002e94:	00a03533          	snez	a0,a0
    80002e98:	40a0053b          	negw	a0,a0
    80002e9c:	2501                	sext.w	a0,a0
}
    80002e9e:	60e2                	ld	ra,24(sp)
    80002ea0:	6442                	ld	s0,16(sp)
    80002ea2:	64a2                	ld	s1,8(sp)
    80002ea4:	6902                	ld	s2,0(sp)
    80002ea6:	6105                	addi	sp,sp,32
    80002ea8:	8082                	ret
    return -1;
    80002eaa:	557d                	li	a0,-1
    80002eac:	bfcd                	j	80002e9e <fetchaddr+0x40>
    80002eae:	557d                	li	a0,-1
    80002eb0:	b7fd                	j	80002e9e <fetchaddr+0x40>

0000000080002eb2 <fetchstr>:
{
    80002eb2:	7179                	addi	sp,sp,-48
    80002eb4:	f406                	sd	ra,40(sp)
    80002eb6:	f022                	sd	s0,32(sp)
    80002eb8:	ec26                	sd	s1,24(sp)
    80002eba:	e84a                	sd	s2,16(sp)
    80002ebc:	e44e                	sd	s3,8(sp)
    80002ebe:	1800                	addi	s0,sp,48
    80002ec0:	892a                	mv	s2,a0
    80002ec2:	84ae                	mv	s1,a1
    80002ec4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ec6:	fffff097          	auipc	ra,0xfffff
    80002eca:	f64080e7          	jalr	-156(ra) # 80001e2a <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002ece:	86ce                	mv	a3,s3
    80002ed0:	864a                	mv	a2,s2
    80002ed2:	85a6                	mv	a1,s1
    80002ed4:	6d28                	ld	a0,88(a0)
    80002ed6:	fffff097          	auipc	ra,0xfffff
    80002eda:	d4a080e7          	jalr	-694(ra) # 80001c20 <copyinstr>
  if(err < 0)
    80002ede:	00054763          	bltz	a0,80002eec <fetchstr+0x3a>
  return strlen(buf);
    80002ee2:	8526                	mv	a0,s1
    80002ee4:	ffffe097          	auipc	ra,0xffffe
    80002ee8:	44c080e7          	jalr	1100(ra) # 80001330 <strlen>
}
    80002eec:	70a2                	ld	ra,40(sp)
    80002eee:	7402                	ld	s0,32(sp)
    80002ef0:	64e2                	ld	s1,24(sp)
    80002ef2:	6942                	ld	s2,16(sp)
    80002ef4:	69a2                	ld	s3,8(sp)
    80002ef6:	6145                	addi	sp,sp,48
    80002ef8:	8082                	ret

0000000080002efa <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002efa:	1101                	addi	sp,sp,-32
    80002efc:	ec06                	sd	ra,24(sp)
    80002efe:	e822                	sd	s0,16(sp)
    80002f00:	e426                	sd	s1,8(sp)
    80002f02:	1000                	addi	s0,sp,32
    80002f04:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f06:	00000097          	auipc	ra,0x0
    80002f0a:	eec080e7          	jalr	-276(ra) # 80002df2 <argraw>
    80002f0e:	c088                	sw	a0,0(s1)
  return 0;
}
    80002f10:	4501                	li	a0,0
    80002f12:	60e2                	ld	ra,24(sp)
    80002f14:	6442                	ld	s0,16(sp)
    80002f16:	64a2                	ld	s1,8(sp)
    80002f18:	6105                	addi	sp,sp,32
    80002f1a:	8082                	ret

0000000080002f1c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002f1c:	1101                	addi	sp,sp,-32
    80002f1e:	ec06                	sd	ra,24(sp)
    80002f20:	e822                	sd	s0,16(sp)
    80002f22:	e426                	sd	s1,8(sp)
    80002f24:	1000                	addi	s0,sp,32
    80002f26:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f28:	00000097          	auipc	ra,0x0
    80002f2c:	eca080e7          	jalr	-310(ra) # 80002df2 <argraw>
    80002f30:	e088                	sd	a0,0(s1)
  return 0;
}
    80002f32:	4501                	li	a0,0
    80002f34:	60e2                	ld	ra,24(sp)
    80002f36:	6442                	ld	s0,16(sp)
    80002f38:	64a2                	ld	s1,8(sp)
    80002f3a:	6105                	addi	sp,sp,32
    80002f3c:	8082                	ret

0000000080002f3e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002f3e:	1101                	addi	sp,sp,-32
    80002f40:	ec06                	sd	ra,24(sp)
    80002f42:	e822                	sd	s0,16(sp)
    80002f44:	e426                	sd	s1,8(sp)
    80002f46:	e04a                	sd	s2,0(sp)
    80002f48:	1000                	addi	s0,sp,32
    80002f4a:	84ae                	mv	s1,a1
    80002f4c:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002f4e:	00000097          	auipc	ra,0x0
    80002f52:	ea4080e7          	jalr	-348(ra) # 80002df2 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002f56:	864a                	mv	a2,s2
    80002f58:	85a6                	mv	a1,s1
    80002f5a:	00000097          	auipc	ra,0x0
    80002f5e:	f58080e7          	jalr	-168(ra) # 80002eb2 <fetchstr>
}
    80002f62:	60e2                	ld	ra,24(sp)
    80002f64:	6442                	ld	s0,16(sp)
    80002f66:	64a2                	ld	s1,8(sp)
    80002f68:	6902                	ld	s2,0(sp)
    80002f6a:	6105                	addi	sp,sp,32
    80002f6c:	8082                	ret

0000000080002f6e <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002f6e:	1101                	addi	sp,sp,-32
    80002f70:	ec06                	sd	ra,24(sp)
    80002f72:	e822                	sd	s0,16(sp)
    80002f74:	e426                	sd	s1,8(sp)
    80002f76:	e04a                	sd	s2,0(sp)
    80002f78:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002f7a:	fffff097          	auipc	ra,0xfffff
    80002f7e:	eb0080e7          	jalr	-336(ra) # 80001e2a <myproc>
    80002f82:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002f84:	06053903          	ld	s2,96(a0)
    80002f88:	0a893783          	ld	a5,168(s2)
    80002f8c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f90:	37fd                	addiw	a5,a5,-1
    80002f92:	4751                	li	a4,20
    80002f94:	00f76f63          	bltu	a4,a5,80002fb2 <syscall+0x44>
    80002f98:	00369713          	slli	a4,a3,0x3
    80002f9c:	00005797          	auipc	a5,0x5
    80002fa0:	4f478793          	addi	a5,a5,1268 # 80008490 <syscalls>
    80002fa4:	97ba                	add	a5,a5,a4
    80002fa6:	639c                	ld	a5,0(a5)
    80002fa8:	c789                	beqz	a5,80002fb2 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002faa:	9782                	jalr	a5
    80002fac:	06a93823          	sd	a0,112(s2)
    80002fb0:	a839                	j	80002fce <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002fb2:	16048613          	addi	a2,s1,352
    80002fb6:	40ac                	lw	a1,64(s1)
    80002fb8:	00005517          	auipc	a0,0x5
    80002fbc:	59050513          	addi	a0,a0,1424 # 80008548 <syscalls+0xb8>
    80002fc0:	ffffd097          	auipc	ra,0xffffd
    80002fc4:	602080e7          	jalr	1538(ra) # 800005c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002fc8:	70bc                	ld	a5,96(s1)
    80002fca:	577d                	li	a4,-1
    80002fcc:	fbb8                	sd	a4,112(a5)
  }
}
    80002fce:	60e2                	ld	ra,24(sp)
    80002fd0:	6442                	ld	s0,16(sp)
    80002fd2:	64a2                	ld	s1,8(sp)
    80002fd4:	6902                	ld	s2,0(sp)
    80002fd6:	6105                	addi	sp,sp,32
    80002fd8:	8082                	ret

0000000080002fda <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002fda:	1101                	addi	sp,sp,-32
    80002fdc:	ec06                	sd	ra,24(sp)
    80002fde:	e822                	sd	s0,16(sp)
    80002fe0:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002fe2:	fec40593          	addi	a1,s0,-20
    80002fe6:	4501                	li	a0,0
    80002fe8:	00000097          	auipc	ra,0x0
    80002fec:	f12080e7          	jalr	-238(ra) # 80002efa <argint>
    return -1;
    80002ff0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ff2:	00054963          	bltz	a0,80003004 <sys_exit+0x2a>
  exit(n);
    80002ff6:	fec42503          	lw	a0,-20(s0)
    80002ffa:	fffff097          	auipc	ra,0xfffff
    80002ffe:	502080e7          	jalr	1282(ra) # 800024fc <exit>
  return 0;  // not reached
    80003002:	4781                	li	a5,0
}
    80003004:	853e                	mv	a0,a5
    80003006:	60e2                	ld	ra,24(sp)
    80003008:	6442                	ld	s0,16(sp)
    8000300a:	6105                	addi	sp,sp,32
    8000300c:	8082                	ret

000000008000300e <sys_getpid>:

uint64
sys_getpid(void)
{
    8000300e:	1141                	addi	sp,sp,-16
    80003010:	e406                	sd	ra,8(sp)
    80003012:	e022                	sd	s0,0(sp)
    80003014:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003016:	fffff097          	auipc	ra,0xfffff
    8000301a:	e14080e7          	jalr	-492(ra) # 80001e2a <myproc>
}
    8000301e:	4128                	lw	a0,64(a0)
    80003020:	60a2                	ld	ra,8(sp)
    80003022:	6402                	ld	s0,0(sp)
    80003024:	0141                	addi	sp,sp,16
    80003026:	8082                	ret

0000000080003028 <sys_fork>:

uint64
sys_fork(void)
{
    80003028:	1141                	addi	sp,sp,-16
    8000302a:	e406                	sd	ra,8(sp)
    8000302c:	e022                	sd	s0,0(sp)
    8000302e:	0800                	addi	s0,sp,16
  return fork();
    80003030:	fffff097          	auipc	ra,0xfffff
    80003034:	1c0080e7          	jalr	448(ra) # 800021f0 <fork>
}
    80003038:	60a2                	ld	ra,8(sp)
    8000303a:	6402                	ld	s0,0(sp)
    8000303c:	0141                	addi	sp,sp,16
    8000303e:	8082                	ret

0000000080003040 <sys_wait>:

uint64
sys_wait(void)
{
    80003040:	1101                	addi	sp,sp,-32
    80003042:	ec06                	sd	ra,24(sp)
    80003044:	e822                	sd	s0,16(sp)
    80003046:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003048:	fe840593          	addi	a1,s0,-24
    8000304c:	4501                	li	a0,0
    8000304e:	00000097          	auipc	ra,0x0
    80003052:	ece080e7          	jalr	-306(ra) # 80002f1c <argaddr>
    return -1;
    80003056:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    80003058:	00054963          	bltz	a0,8000306a <sys_wait+0x2a>
  return wait(p);
    8000305c:	fe843503          	ld	a0,-24(s0)
    80003060:	fffff097          	auipc	ra,0xfffff
    80003064:	662080e7          	jalr	1634(ra) # 800026c2 <wait>
    80003068:	87aa                	mv	a5,a0
}
    8000306a:	853e                	mv	a0,a5
    8000306c:	60e2                	ld	ra,24(sp)
    8000306e:	6442                	ld	s0,16(sp)
    80003070:	6105                	addi	sp,sp,32
    80003072:	8082                	ret

0000000080003074 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003074:	7179                	addi	sp,sp,-48
    80003076:	f406                	sd	ra,40(sp)
    80003078:	f022                	sd	s0,32(sp)
    8000307a:	ec26                	sd	s1,24(sp)
    8000307c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000307e:	fdc40593          	addi	a1,s0,-36
    80003082:	4501                	li	a0,0
    80003084:	00000097          	auipc	ra,0x0
    80003088:	e76080e7          	jalr	-394(ra) # 80002efa <argint>
    return -1;
    8000308c:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    8000308e:	00054f63          	bltz	a0,800030ac <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003092:	fffff097          	auipc	ra,0xfffff
    80003096:	d98080e7          	jalr	-616(ra) # 80001e2a <myproc>
    8000309a:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    8000309c:	fdc42503          	lw	a0,-36(s0)
    800030a0:	fffff097          	auipc	ra,0xfffff
    800030a4:	0d8080e7          	jalr	216(ra) # 80002178 <growproc>
    800030a8:	00054863          	bltz	a0,800030b8 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800030ac:	8526                	mv	a0,s1
    800030ae:	70a2                	ld	ra,40(sp)
    800030b0:	7402                	ld	s0,32(sp)
    800030b2:	64e2                	ld	s1,24(sp)
    800030b4:	6145                	addi	sp,sp,48
    800030b6:	8082                	ret
    return -1;
    800030b8:	54fd                	li	s1,-1
    800030ba:	bfcd                	j	800030ac <sys_sbrk+0x38>

00000000800030bc <sys_sleep>:

uint64
sys_sleep(void)
{
    800030bc:	7139                	addi	sp,sp,-64
    800030be:	fc06                	sd	ra,56(sp)
    800030c0:	f822                	sd	s0,48(sp)
    800030c2:	f426                	sd	s1,40(sp)
    800030c4:	f04a                	sd	s2,32(sp)
    800030c6:	ec4e                	sd	s3,24(sp)
    800030c8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800030ca:	fcc40593          	addi	a1,s0,-52
    800030ce:	4501                	li	a0,0
    800030d0:	00000097          	auipc	ra,0x0
    800030d4:	e2a080e7          	jalr	-470(ra) # 80002efa <argint>
    return -1;
    800030d8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800030da:	06054763          	bltz	a0,80003148 <sys_sleep+0x8c>
  acquire(&tickslock);
    800030de:	00015517          	auipc	a0,0x15
    800030e2:	2ca50513          	addi	a0,a0,714 # 800183a8 <tickslock>
    800030e6:	ffffe097          	auipc	ra,0xffffe
    800030ea:	c94080e7          	jalr	-876(ra) # 80000d7a <acquire>
  ticks0 = ticks;
    800030ee:	00006797          	auipc	a5,0x6
    800030f2:	f3278793          	addi	a5,a5,-206 # 80009020 <ticks>
    800030f6:	0007a903          	lw	s2,0(a5)
  while(ticks - ticks0 < n){
    800030fa:	fcc42783          	lw	a5,-52(s0)
    800030fe:	cf85                	beqz	a5,80003136 <sys_sleep+0x7a>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003100:	00015997          	auipc	s3,0x15
    80003104:	2a898993          	addi	s3,s3,680 # 800183a8 <tickslock>
    80003108:	00006497          	auipc	s1,0x6
    8000310c:	f1848493          	addi	s1,s1,-232 # 80009020 <ticks>
    if(myproc()->killed){
    80003110:	fffff097          	auipc	ra,0xfffff
    80003114:	d1a080e7          	jalr	-742(ra) # 80001e2a <myproc>
    80003118:	5d1c                	lw	a5,56(a0)
    8000311a:	ef9d                	bnez	a5,80003158 <sys_sleep+0x9c>
    sleep(&ticks, &tickslock);
    8000311c:	85ce                	mv	a1,s3
    8000311e:	8526                	mv	a0,s1
    80003120:	fffff097          	auipc	ra,0xfffff
    80003124:	524080e7          	jalr	1316(ra) # 80002644 <sleep>
  while(ticks - ticks0 < n){
    80003128:	409c                	lw	a5,0(s1)
    8000312a:	412787bb          	subw	a5,a5,s2
    8000312e:	fcc42703          	lw	a4,-52(s0)
    80003132:	fce7efe3          	bltu	a5,a4,80003110 <sys_sleep+0x54>
  }
  release(&tickslock);
    80003136:	00015517          	auipc	a0,0x15
    8000313a:	27250513          	addi	a0,a0,626 # 800183a8 <tickslock>
    8000313e:	ffffe097          	auipc	ra,0xffffe
    80003142:	d0c080e7          	jalr	-756(ra) # 80000e4a <release>
  return 0;
    80003146:	4781                	li	a5,0
}
    80003148:	853e                	mv	a0,a5
    8000314a:	70e2                	ld	ra,56(sp)
    8000314c:	7442                	ld	s0,48(sp)
    8000314e:	74a2                	ld	s1,40(sp)
    80003150:	7902                	ld	s2,32(sp)
    80003152:	69e2                	ld	s3,24(sp)
    80003154:	6121                	addi	sp,sp,64
    80003156:	8082                	ret
      release(&tickslock);
    80003158:	00015517          	auipc	a0,0x15
    8000315c:	25050513          	addi	a0,a0,592 # 800183a8 <tickslock>
    80003160:	ffffe097          	auipc	ra,0xffffe
    80003164:	cea080e7          	jalr	-790(ra) # 80000e4a <release>
      return -1;
    80003168:	57fd                	li	a5,-1
    8000316a:	bff9                	j	80003148 <sys_sleep+0x8c>

000000008000316c <sys_kill>:

uint64
sys_kill(void)
{
    8000316c:	1101                	addi	sp,sp,-32
    8000316e:	ec06                	sd	ra,24(sp)
    80003170:	e822                	sd	s0,16(sp)
    80003172:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003174:	fec40593          	addi	a1,s0,-20
    80003178:	4501                	li	a0,0
    8000317a:	00000097          	auipc	ra,0x0
    8000317e:	d80080e7          	jalr	-640(ra) # 80002efa <argint>
    return -1;
    80003182:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    80003184:	00054963          	bltz	a0,80003196 <sys_kill+0x2a>
  return kill(pid);
    80003188:	fec42503          	lw	a0,-20(s0)
    8000318c:	fffff097          	auipc	ra,0xfffff
    80003190:	6a8080e7          	jalr	1704(ra) # 80002834 <kill>
    80003194:	87aa                	mv	a5,a0
}
    80003196:	853e                	mv	a0,a5
    80003198:	60e2                	ld	ra,24(sp)
    8000319a:	6442                	ld	s0,16(sp)
    8000319c:	6105                	addi	sp,sp,32
    8000319e:	8082                	ret

00000000800031a0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800031a0:	1101                	addi	sp,sp,-32
    800031a2:	ec06                	sd	ra,24(sp)
    800031a4:	e822                	sd	s0,16(sp)
    800031a6:	e426                	sd	s1,8(sp)
    800031a8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800031aa:	00015517          	auipc	a0,0x15
    800031ae:	1fe50513          	addi	a0,a0,510 # 800183a8 <tickslock>
    800031b2:	ffffe097          	auipc	ra,0xffffe
    800031b6:	bc8080e7          	jalr	-1080(ra) # 80000d7a <acquire>
  xticks = ticks;
    800031ba:	00006797          	auipc	a5,0x6
    800031be:	e6678793          	addi	a5,a5,-410 # 80009020 <ticks>
    800031c2:	4384                	lw	s1,0(a5)
  release(&tickslock);
    800031c4:	00015517          	auipc	a0,0x15
    800031c8:	1e450513          	addi	a0,a0,484 # 800183a8 <tickslock>
    800031cc:	ffffe097          	auipc	ra,0xffffe
    800031d0:	c7e080e7          	jalr	-898(ra) # 80000e4a <release>
  return xticks;
}
    800031d4:	02049513          	slli	a0,s1,0x20
    800031d8:	9101                	srli	a0,a0,0x20
    800031da:	60e2                	ld	ra,24(sp)
    800031dc:	6442                	ld	s0,16(sp)
    800031de:	64a2                	ld	s1,8(sp)
    800031e0:	6105                	addi	sp,sp,32
    800031e2:	8082                	ret

00000000800031e4 <hash>:
  struct buf buf[BUFFERSIZE];
} bcachebucket[BUCKETSIZE];

int
hash(uint blockno)
{
    800031e4:	1141                	addi	sp,sp,-16
    800031e6:	e422                	sd	s0,8(sp)
    800031e8:	0800                	addi	s0,sp,16
  return blockno % BUCKETSIZE;
}
    800031ea:	47b5                	li	a5,13
    800031ec:	02f5753b          	remuw	a0,a0,a5
    800031f0:	6422                	ld	s0,8(sp)
    800031f2:	0141                	addi	sp,sp,16
    800031f4:	8082                	ret

00000000800031f6 <binit>:

void
binit(void)
{
    800031f6:	715d                	addi	sp,sp,-80
    800031f8:	e486                	sd	ra,72(sp)
    800031fa:	e0a2                	sd	s0,64(sp)
    800031fc:	fc26                	sd	s1,56(sp)
    800031fe:	f84a                	sd	s2,48(sp)
    80003200:	f44e                	sd	s3,40(sp)
    80003202:	f052                	sd	s4,32(sp)
    80003204:	ec56                	sd	s5,24(sp)
    80003206:	e85a                	sd	s6,16(sp)
    80003208:	e45e                	sd	s7,8(sp)
    8000320a:	e062                	sd	s8,0(sp)
    8000320c:	0880                	addi	s0,sp,80
  for (int i = 0; i < BUCKETSIZE; i++) {
    8000320e:	00016917          	auipc	s2,0x16
    80003212:	7f290913          	addi	s2,s2,2034 # 80019a00 <bcachebucket+0x1638>
    80003216:	00028c17          	auipc	s8,0x28
    8000321a:	7f2c0c13          	addi	s8,s8,2034 # 8002ba08 <icache+0x1618>
    initlock(&bcachebucket[i].lock, "bcachebucket");
    8000321e:	7a7d                	lui	s4,0xfffff
    80003220:	9c8a0b93          	addi	s7,s4,-1592 # ffffffffffffe9c8 <end+0xffffffff7ffcc9a0>
    80003224:	00005b17          	auipc	s6,0x5
    80003228:	344b0b13          	addi	s6,s6,836 # 80008568 <syscalls+0xd8>
    8000322c:	9f8a0a13          	addi	s4,s4,-1544
    for (int j = 0; j < BUFFERSIZE; j++) {
      initsleeplock(&bcachebucket[i].buf[j].lock, "buffer");
    80003230:	00005997          	auipc	s3,0x5
    80003234:	34898993          	addi	s3,s3,840 # 80008578 <syscalls+0xe8>
    80003238:	6a85                	lui	s5,0x1
    8000323a:	628a8a93          	addi	s5,s5,1576 # 1628 <_entry-0x7fffe9d8>
    8000323e:	a021                	j	80003246 <binit+0x50>
  for (int i = 0; i < BUCKETSIZE; i++) {
    80003240:	9956                	add	s2,s2,s5
    80003242:	03890663          	beq	s2,s8,8000326e <binit+0x78>
    initlock(&bcachebucket[i].lock, "bcachebucket");
    80003246:	85da                	mv	a1,s6
    80003248:	01790533          	add	a0,s2,s7
    8000324c:	ffffe097          	auipc	ra,0xffffe
    80003250:	cba080e7          	jalr	-838(ra) # 80000f06 <initlock>
    for (int j = 0; j < BUFFERSIZE; j++) {
    80003254:	014904b3          	add	s1,s2,s4
      initsleeplock(&bcachebucket[i].buf[j].lock, "buffer");
    80003258:	85ce                	mv	a1,s3
    8000325a:	8526                	mv	a0,s1
    8000325c:	00001097          	auipc	ra,0x1
    80003260:	5c6080e7          	jalr	1478(ra) # 80004822 <initsleeplock>
    for (int j = 0; j < BUFFERSIZE; j++) {
    80003264:	46848493          	addi	s1,s1,1128
    80003268:	ff2498e3          	bne	s1,s2,80003258 <binit+0x62>
    8000326c:	bfd1                	j	80003240 <binit+0x4a>
    }
  }
}
    8000326e:	60a6                	ld	ra,72(sp)
    80003270:	6406                	ld	s0,64(sp)
    80003272:	74e2                	ld	s1,56(sp)
    80003274:	7942                	ld	s2,48(sp)
    80003276:	79a2                	ld	s3,40(sp)
    80003278:	7a02                	ld	s4,32(sp)
    8000327a:	6ae2                	ld	s5,24(sp)
    8000327c:	6b42                	ld	s6,16(sp)
    8000327e:	6ba2                	ld	s7,8(sp)
    80003280:	6c02                	ld	s8,0(sp)
    80003282:	6161                	addi	sp,sp,80
    80003284:	8082                	ret

0000000080003286 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003286:	715d                	addi	sp,sp,-80
    80003288:	e486                	sd	ra,72(sp)
    8000328a:	e0a2                	sd	s0,64(sp)
    8000328c:	fc26                	sd	s1,56(sp)
    8000328e:	f84a                	sd	s2,48(sp)
    80003290:	f44e                	sd	s3,40(sp)
    80003292:	f052                	sd	s4,32(sp)
    80003294:	ec56                	sd	s5,24(sp)
    80003296:	e85a                	sd	s6,16(sp)
    80003298:	e45e                	sd	s7,8(sp)
    8000329a:	e062                	sd	s8,0(sp)
    8000329c:	0880                	addi	s0,sp,80
    8000329e:	8c2a                	mv	s8,a0
    800032a0:	8bae                	mv	s7,a1
  return blockno % BUCKETSIZE;
    800032a2:	44b5                	li	s1,13
    800032a4:	0295f4bb          	remuw	s1,a1,s1
  acquire(&bcachebucket[bucket].lock);
    800032a8:	6905                	lui	s2,0x1
    800032aa:	62890913          	addi	s2,s2,1576 # 1628 <_entry-0x7fffe9d8>
    800032ae:	03248933          	mul	s2,s1,s2
    800032b2:	00015a97          	auipc	s5,0x15
    800032b6:	116a8a93          	addi	s5,s5,278 # 800183c8 <bcachebucket>
    800032ba:	9aca                	add	s5,s5,s2
    800032bc:	8556                	mv	a0,s5
    800032be:	ffffe097          	auipc	ra,0xffffe
    800032c2:	abc080e7          	jalr	-1348(ra) # 80000d7a <acquire>
  for (int i = 0; i < BUFFERSIZE; i++) {
    800032c6:	87d6                	mv	a5,s5
  acquire(&bcachebucket[bucket].lock);
    800032c8:	8756                	mv	a4,s5
  for (int i = 0; i < BUFFERSIZE; i++) {
    800032ca:	4501                	li	a0,0
    800032cc:	4695                	li	a3,5
    800032ce:	a031                	j	800032da <bread+0x54>
    800032d0:	2505                	addiw	a0,a0,1
    800032d2:	46870713          	addi	a4,a4,1128
    800032d6:	06d50363          	beq	a0,a3,8000333c <bread+0xb6>
    if (b->dev == dev && b->blockno == blockno) {
    800032da:	5710                	lw	a2,40(a4)
    800032dc:	ff861ae3          	bne	a2,s8,800032d0 <bread+0x4a>
    800032e0:	5750                	lw	a2,44(a4)
    800032e2:	ff7617e3          	bne	a2,s7,800032d0 <bread+0x4a>
    800032e6:	46800a13          	li	s4,1128
    800032ea:	03450a33          	mul	s4,a0,s4
    b = &bcachebucket[bucket].buf[i];
    800032ee:	02090993          	addi	s3,s2,32
    800032f2:	99d2                	add	s3,s3,s4
    800032f4:	00015b17          	auipc	s6,0x15
    800032f8:	0d4b0b13          	addi	s6,s6,212 # 800183c8 <bcachebucket>
    800032fc:	99da                	add	s3,s3,s6
      b->refcnt++;
    800032fe:	6785                	lui	a5,0x1
    80003300:	62878793          	addi	a5,a5,1576 # 1628 <_entry-0x7fffe9d8>
    80003304:	02f484b3          	mul	s1,s1,a5
    80003308:	94d2                	add	s1,s1,s4
    8000330a:	94da                	add	s1,s1,s6
    8000330c:	54bc                	lw	a5,104(s1)
    8000330e:	2785                	addiw	a5,a5,1
    80003310:	d4bc                	sw	a5,104(s1)
      b->lastuse = ticks;
    80003312:	00006797          	auipc	a5,0x6
    80003316:	d0e78793          	addi	a5,a5,-754 # 80009020 <ticks>
    8000331a:	439c                	lw	a5,0(a5)
    8000331c:	48f4a023          	sw	a5,1152(s1)
      release(&bcachebucket[bucket].lock);
    80003320:	8556                	mv	a0,s5
    80003322:	ffffe097          	auipc	ra,0xffffe
    80003326:	b28080e7          	jalr	-1240(ra) # 80000e4a <release>
      acquiresleep(&b->lock);
    8000332a:	03090513          	addi	a0,s2,48
    8000332e:	9552                	add	a0,a0,s4
    80003330:	955a                	add	a0,a0,s6
    80003332:	00001097          	auipc	ra,0x1
    80003336:	52a080e7          	jalr	1322(ra) # 8000485c <acquiresleep>
      return b;
    8000333a:	a071                	j	800033c6 <bread+0x140>
  int least_idx = -1;
    8000333c:	557d                	li	a0,-1
  uint least = 0xffffffff;
    8000333e:	567d                	li	a2,-1
  for (int i = 0; i < BUFFERSIZE; i++) {
    80003340:	4701                	li	a4,0
    80003342:	4595                	li	a1,5
    80003344:	a031                	j	80003350 <bread+0xca>
    80003346:	2705                	addiw	a4,a4,1
    80003348:	46878793          	addi	a5,a5,1128
    8000334c:	00b70b63          	beq	a4,a1,80003362 <bread+0xdc>
    if(b->refcnt == 0 && b->lastuse < least) {
    80003350:	57b4                	lw	a3,104(a5)
    80003352:	faf5                	bnez	a3,80003346 <bread+0xc0>
    80003354:	4807a683          	lw	a3,1152(a5)
    80003358:	fec6f7e3          	bleu	a2,a3,80003346 <bread+0xc0>
    8000335c:	853a                	mv	a0,a4
      least = b->lastuse;
    8000335e:	8636                	mv	a2,a3
    80003360:	b7dd                	j	80003346 <bread+0xc0>
  if (least_idx == -1) {
    80003362:	57fd                	li	a5,-1
    80003364:	08f50163          	beq	a0,a5,800033e6 <bread+0x160>
  b = &bcachebucket[bucket].buf[least_idx];
    80003368:	46800a13          	li	s4,1128
    8000336c:	03450a33          	mul	s4,a0,s4
    80003370:	02090993          	addi	s3,s2,32
    80003374:	99d2                	add	s3,s3,s4
    80003376:	00015b17          	auipc	s6,0x15
    8000337a:	052b0b13          	addi	s6,s6,82 # 800183c8 <bcachebucket>
    8000337e:	99da                	add	s3,s3,s6
  b->dev = dev;
    80003380:	6785                	lui	a5,0x1
    80003382:	62878793          	addi	a5,a5,1576 # 1628 <_entry-0x7fffe9d8>
    80003386:	02f487b3          	mul	a5,s1,a5
    8000338a:	97d2                	add	a5,a5,s4
    8000338c:	97da                	add	a5,a5,s6
    8000338e:	0387a423          	sw	s8,40(a5)
  b->blockno = blockno;
    80003392:	0377a623          	sw	s7,44(a5)
  b->lastuse = ticks;
    80003396:	00006717          	auipc	a4,0x6
    8000339a:	c8a70713          	addi	a4,a4,-886 # 80009020 <ticks>
    8000339e:	4318                	lw	a4,0(a4)
    800033a0:	48e7a023          	sw	a4,1152(a5)
  b->valid = 0;
    800033a4:	0207a023          	sw	zero,32(a5)
  b->refcnt = 1;
    800033a8:	4705                	li	a4,1
    800033aa:	d7b8                	sw	a4,104(a5)
  release(&bcachebucket[bucket].lock);
    800033ac:	8556                	mv	a0,s5
    800033ae:	ffffe097          	auipc	ra,0xffffe
    800033b2:	a9c080e7          	jalr	-1380(ra) # 80000e4a <release>
  acquiresleep(&b->lock);
    800033b6:	03090513          	addi	a0,s2,48
    800033ba:	9552                	add	a0,a0,s4
    800033bc:	955a                	add	a0,a0,s6
    800033be:	00001097          	auipc	ra,0x1
    800033c2:	49e080e7          	jalr	1182(ra) # 8000485c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800033c6:	0009a783          	lw	a5,0(s3)
    800033ca:	c795                	beqz	a5,800033f6 <bread+0x170>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800033cc:	854e                	mv	a0,s3
    800033ce:	60a6                	ld	ra,72(sp)
    800033d0:	6406                	ld	s0,64(sp)
    800033d2:	74e2                	ld	s1,56(sp)
    800033d4:	7942                	ld	s2,48(sp)
    800033d6:	79a2                	ld	s3,40(sp)
    800033d8:	7a02                	ld	s4,32(sp)
    800033da:	6ae2                	ld	s5,24(sp)
    800033dc:	6b42                	ld	s6,16(sp)
    800033de:	6ba2                	ld	s7,8(sp)
    800033e0:	6c02                	ld	s8,0(sp)
    800033e2:	6161                	addi	sp,sp,80
    800033e4:	8082                	ret
    panic("bget: no unused buffer for recycle");
    800033e6:	00005517          	auipc	a0,0x5
    800033ea:	19a50513          	addi	a0,a0,410 # 80008580 <syscalls+0xf0>
    800033ee:	ffffd097          	auipc	ra,0xffffd
    800033f2:	18a080e7          	jalr	394(ra) # 80000578 <panic>
    virtio_disk_rw(b, 0);
    800033f6:	4581                	li	a1,0
    800033f8:	854e                	mv	a0,s3
    800033fa:	00003097          	auipc	ra,0x3
    800033fe:	03c080e7          	jalr	60(ra) # 80006436 <virtio_disk_rw>
    b->valid = 1;
    80003402:	4785                	li	a5,1
    80003404:	00f9a023          	sw	a5,0(s3)
  return b;
    80003408:	b7d1                	j	800033cc <bread+0x146>

000000008000340a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000340a:	1101                	addi	sp,sp,-32
    8000340c:	ec06                	sd	ra,24(sp)
    8000340e:	e822                	sd	s0,16(sp)
    80003410:	e426                	sd	s1,8(sp)
    80003412:	1000                	addi	s0,sp,32
    80003414:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003416:	0541                	addi	a0,a0,16
    80003418:	00001097          	auipc	ra,0x1
    8000341c:	4de080e7          	jalr	1246(ra) # 800048f6 <holdingsleep>
    80003420:	cd01                	beqz	a0,80003438 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003422:	4585                	li	a1,1
    80003424:	8526                	mv	a0,s1
    80003426:	00003097          	auipc	ra,0x3
    8000342a:	010080e7          	jalr	16(ra) # 80006436 <virtio_disk_rw>
}
    8000342e:	60e2                	ld	ra,24(sp)
    80003430:	6442                	ld	s0,16(sp)
    80003432:	64a2                	ld	s1,8(sp)
    80003434:	6105                	addi	sp,sp,32
    80003436:	8082                	ret
    panic("bwrite");
    80003438:	00005517          	auipc	a0,0x5
    8000343c:	17050513          	addi	a0,a0,368 # 800085a8 <syscalls+0x118>
    80003440:	ffffd097          	auipc	ra,0xffffd
    80003444:	138080e7          	jalr	312(ra) # 80000578 <panic>

0000000080003448 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003448:	7179                	addi	sp,sp,-48
    8000344a:	f406                	sd	ra,40(sp)
    8000344c:	f022                	sd	s0,32(sp)
    8000344e:	ec26                	sd	s1,24(sp)
    80003450:	e84a                	sd	s2,16(sp)
    80003452:	e44e                	sd	s3,8(sp)
    80003454:	1800                	addi	s0,sp,48
    80003456:	892a                	mv	s2,a0
  if(!holdingsleep(&b->lock))
    80003458:	01050993          	addi	s3,a0,16
    8000345c:	854e                	mv	a0,s3
    8000345e:	00001097          	auipc	ra,0x1
    80003462:	498080e7          	jalr	1176(ra) # 800048f6 <holdingsleep>
    80003466:	c939                	beqz	a0,800034bc <brelse+0x74>
  return blockno % BUCKETSIZE;
    80003468:	00c92483          	lw	s1,12(s2)
    panic("brelse");


  int bucket = hash(b->blockno);
  acquire(&bcachebucket[bucket].lock);
    8000346c:	47b5                	li	a5,13
    8000346e:	02f4f4bb          	remuw	s1,s1,a5
    80003472:	6785                	lui	a5,0x1
    80003474:	62878793          	addi	a5,a5,1576 # 1628 <_entry-0x7fffe9d8>
    80003478:	02f484b3          	mul	s1,s1,a5
    8000347c:	00015797          	auipc	a5,0x15
    80003480:	f4c78793          	addi	a5,a5,-180 # 800183c8 <bcachebucket>
    80003484:	94be                	add	s1,s1,a5
    80003486:	8526                	mv	a0,s1
    80003488:	ffffe097          	auipc	ra,0xffffe
    8000348c:	8f2080e7          	jalr	-1806(ra) # 80000d7a <acquire>
  b->refcnt--;
    80003490:	04892783          	lw	a5,72(s2)
    80003494:	37fd                	addiw	a5,a5,-1
    80003496:	04f92423          	sw	a5,72(s2)
  release(&bcachebucket[bucket].lock);
    8000349a:	8526                	mv	a0,s1
    8000349c:	ffffe097          	auipc	ra,0xffffe
    800034a0:	9ae080e7          	jalr	-1618(ra) # 80000e4a <release>
  releasesleep(&b->lock);
    800034a4:	854e                	mv	a0,s3
    800034a6:	00001097          	auipc	ra,0x1
    800034aa:	40c080e7          	jalr	1036(ra) # 800048b2 <releasesleep>
}
    800034ae:	70a2                	ld	ra,40(sp)
    800034b0:	7402                	ld	s0,32(sp)
    800034b2:	64e2                	ld	s1,24(sp)
    800034b4:	6942                	ld	s2,16(sp)
    800034b6:	69a2                	ld	s3,8(sp)
    800034b8:	6145                	addi	sp,sp,48
    800034ba:	8082                	ret
    panic("brelse");
    800034bc:	00005517          	auipc	a0,0x5
    800034c0:	0f450513          	addi	a0,a0,244 # 800085b0 <syscalls+0x120>
    800034c4:	ffffd097          	auipc	ra,0xffffd
    800034c8:	0b4080e7          	jalr	180(ra) # 80000578 <panic>

00000000800034cc <bpin>:

void
bpin(struct buf *b) {
    800034cc:	1101                	addi	sp,sp,-32
    800034ce:	ec06                	sd	ra,24(sp)
    800034d0:	e822                	sd	s0,16(sp)
    800034d2:	e426                	sd	s1,8(sp)
    800034d4:	e04a                	sd	s2,0(sp)
    800034d6:	1000                	addi	s0,sp,32
    800034d8:	892a                	mv	s2,a0
  return blockno % BUCKETSIZE;
    800034da:	4544                	lw	s1,12(a0)
  int bucket = hash(b->blockno);
  acquire(&bcachebucket[bucket].lock);
    800034dc:	47b5                	li	a5,13
    800034de:	02f4f4bb          	remuw	s1,s1,a5
    800034e2:	6785                	lui	a5,0x1
    800034e4:	62878793          	addi	a5,a5,1576 # 1628 <_entry-0x7fffe9d8>
    800034e8:	02f484b3          	mul	s1,s1,a5
    800034ec:	00015797          	auipc	a5,0x15
    800034f0:	edc78793          	addi	a5,a5,-292 # 800183c8 <bcachebucket>
    800034f4:	94be                	add	s1,s1,a5
    800034f6:	8526                	mv	a0,s1
    800034f8:	ffffe097          	auipc	ra,0xffffe
    800034fc:	882080e7          	jalr	-1918(ra) # 80000d7a <acquire>
  b->refcnt++;
    80003500:	04892783          	lw	a5,72(s2)
    80003504:	2785                	addiw	a5,a5,1
    80003506:	04f92423          	sw	a5,72(s2)
  release(&bcachebucket[bucket].lock);
    8000350a:	8526                	mv	a0,s1
    8000350c:	ffffe097          	auipc	ra,0xffffe
    80003510:	93e080e7          	jalr	-1730(ra) # 80000e4a <release>
}
    80003514:	60e2                	ld	ra,24(sp)
    80003516:	6442                	ld	s0,16(sp)
    80003518:	64a2                	ld	s1,8(sp)
    8000351a:	6902                	ld	s2,0(sp)
    8000351c:	6105                	addi	sp,sp,32
    8000351e:	8082                	ret

0000000080003520 <bunpin>:

void
bunpin(struct buf *b) {
    80003520:	1101                	addi	sp,sp,-32
    80003522:	ec06                	sd	ra,24(sp)
    80003524:	e822                	sd	s0,16(sp)
    80003526:	e426                	sd	s1,8(sp)
    80003528:	e04a                	sd	s2,0(sp)
    8000352a:	1000                	addi	s0,sp,32
    8000352c:	892a                	mv	s2,a0
  return blockno % BUCKETSIZE;
    8000352e:	4544                	lw	s1,12(a0)
  int bucket = hash(b->blockno);
  acquire(&bcachebucket[bucket].lock);
    80003530:	47b5                	li	a5,13
    80003532:	02f4f4bb          	remuw	s1,s1,a5
    80003536:	6785                	lui	a5,0x1
    80003538:	62878793          	addi	a5,a5,1576 # 1628 <_entry-0x7fffe9d8>
    8000353c:	02f484b3          	mul	s1,s1,a5
    80003540:	00015797          	auipc	a5,0x15
    80003544:	e8878793          	addi	a5,a5,-376 # 800183c8 <bcachebucket>
    80003548:	94be                	add	s1,s1,a5
    8000354a:	8526                	mv	a0,s1
    8000354c:	ffffe097          	auipc	ra,0xffffe
    80003550:	82e080e7          	jalr	-2002(ra) # 80000d7a <acquire>
  b->refcnt--;
    80003554:	04892783          	lw	a5,72(s2)
    80003558:	37fd                	addiw	a5,a5,-1
    8000355a:	04f92423          	sw	a5,72(s2)
  release(&bcachebucket[bucket].lock);
    8000355e:	8526                	mv	a0,s1
    80003560:	ffffe097          	auipc	ra,0xffffe
    80003564:	8ea080e7          	jalr	-1814(ra) # 80000e4a <release>
}
    80003568:	60e2                	ld	ra,24(sp)
    8000356a:	6442                	ld	s0,16(sp)
    8000356c:	64a2                	ld	s1,8(sp)
    8000356e:	6902                	ld	s2,0(sp)
    80003570:	6105                	addi	sp,sp,32
    80003572:	8082                	ret

0000000080003574 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003574:	1101                	addi	sp,sp,-32
    80003576:	ec06                	sd	ra,24(sp)
    80003578:	e822                	sd	s0,16(sp)
    8000357a:	e426                	sd	s1,8(sp)
    8000357c:	e04a                	sd	s2,0(sp)
    8000357e:	1000                	addi	s0,sp,32
    80003580:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003582:	00d5d59b          	srliw	a1,a1,0xd
    80003586:	00027797          	auipc	a5,0x27
    8000358a:	e4a78793          	addi	a5,a5,-438 # 8002a3d0 <sb>
    8000358e:	4fdc                	lw	a5,28(a5)
    80003590:	9dbd                	addw	a1,a1,a5
    80003592:	00000097          	auipc	ra,0x0
    80003596:	cf4080e7          	jalr	-780(ra) # 80003286 <bread>
  bi = b % BPB;
    8000359a:	2481                	sext.w	s1,s1
  m = 1 << (bi % 8);
    8000359c:	0074f793          	andi	a5,s1,7
    800035a0:	4705                	li	a4,1
    800035a2:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    800035a6:	6789                	lui	a5,0x2
    800035a8:	17fd                	addi	a5,a5,-1
    800035aa:	8cfd                	and	s1,s1,a5
  if((bp->data[bi/8] & m) == 0)
    800035ac:	41f4d79b          	sraiw	a5,s1,0x1f
    800035b0:	01d7d79b          	srliw	a5,a5,0x1d
    800035b4:	9fa5                	addw	a5,a5,s1
    800035b6:	4037d79b          	sraiw	a5,a5,0x3
    800035ba:	00f506b3          	add	a3,a0,a5
    800035be:	0606c683          	lbu	a3,96(a3)
    800035c2:	00d77633          	and	a2,a4,a3
    800035c6:	c61d                	beqz	a2,800035f4 <bfree+0x80>
    800035c8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800035ca:	97aa                	add	a5,a5,a0
    800035cc:	fff74713          	not	a4,a4
    800035d0:	8f75                	and	a4,a4,a3
    800035d2:	06e78023          	sb	a4,96(a5) # 2060 <_entry-0x7fffdfa0>
  log_write(bp);
    800035d6:	00001097          	auipc	ra,0x1
    800035da:	148080e7          	jalr	328(ra) # 8000471e <log_write>
  brelse(bp);
    800035de:	854a                	mv	a0,s2
    800035e0:	00000097          	auipc	ra,0x0
    800035e4:	e68080e7          	jalr	-408(ra) # 80003448 <brelse>
}
    800035e8:	60e2                	ld	ra,24(sp)
    800035ea:	6442                	ld	s0,16(sp)
    800035ec:	64a2                	ld	s1,8(sp)
    800035ee:	6902                	ld	s2,0(sp)
    800035f0:	6105                	addi	sp,sp,32
    800035f2:	8082                	ret
    panic("freeing free block");
    800035f4:	00005517          	auipc	a0,0x5
    800035f8:	fc450513          	addi	a0,a0,-60 # 800085b8 <syscalls+0x128>
    800035fc:	ffffd097          	auipc	ra,0xffffd
    80003600:	f7c080e7          	jalr	-132(ra) # 80000578 <panic>

0000000080003604 <balloc>:
{
    80003604:	711d                	addi	sp,sp,-96
    80003606:	ec86                	sd	ra,88(sp)
    80003608:	e8a2                	sd	s0,80(sp)
    8000360a:	e4a6                	sd	s1,72(sp)
    8000360c:	e0ca                	sd	s2,64(sp)
    8000360e:	fc4e                	sd	s3,56(sp)
    80003610:	f852                	sd	s4,48(sp)
    80003612:	f456                	sd	s5,40(sp)
    80003614:	f05a                	sd	s6,32(sp)
    80003616:	ec5e                	sd	s7,24(sp)
    80003618:	e862                	sd	s8,16(sp)
    8000361a:	e466                	sd	s9,8(sp)
    8000361c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000361e:	00027797          	auipc	a5,0x27
    80003622:	db278793          	addi	a5,a5,-590 # 8002a3d0 <sb>
    80003626:	43dc                	lw	a5,4(a5)
    80003628:	10078e63          	beqz	a5,80003744 <balloc+0x140>
    8000362c:	8baa                	mv	s7,a0
    8000362e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003630:	00027b17          	auipc	s6,0x27
    80003634:	da0b0b13          	addi	s6,s6,-608 # 8002a3d0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003638:	4c05                	li	s8,1
      m = 1 << (bi % 8);
    8000363a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000363c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000363e:	6c89                	lui	s9,0x2
    80003640:	a079                	j	800036ce <balloc+0xca>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003642:	8942                	mv	s2,a6
      m = 1 << (bi % 8);
    80003644:	4705                	li	a4,1
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003646:	4681                	li	a3,0
        bp->data[bi/8] |= m;  // Mark block in use.
    80003648:	96a6                	add	a3,a3,s1
    8000364a:	8f51                	or	a4,a4,a2
    8000364c:	06e68023          	sb	a4,96(a3)
        log_write(bp);
    80003650:	8526                	mv	a0,s1
    80003652:	00001097          	auipc	ra,0x1
    80003656:	0cc080e7          	jalr	204(ra) # 8000471e <log_write>
        brelse(bp);
    8000365a:	8526                	mv	a0,s1
    8000365c:	00000097          	auipc	ra,0x0
    80003660:	dec080e7          	jalr	-532(ra) # 80003448 <brelse>
  bp = bread(dev, bno);
    80003664:	85ca                	mv	a1,s2
    80003666:	855e                	mv	a0,s7
    80003668:	00000097          	auipc	ra,0x0
    8000366c:	c1e080e7          	jalr	-994(ra) # 80003286 <bread>
    80003670:	84aa                	mv	s1,a0
  memset(bp->data, 0, BSIZE);
    80003672:	40000613          	li	a2,1024
    80003676:	4581                	li	a1,0
    80003678:	06050513          	addi	a0,a0,96
    8000367c:	ffffe097          	auipc	ra,0xffffe
    80003680:	b0a080e7          	jalr	-1270(ra) # 80001186 <memset>
  log_write(bp);
    80003684:	8526                	mv	a0,s1
    80003686:	00001097          	auipc	ra,0x1
    8000368a:	098080e7          	jalr	152(ra) # 8000471e <log_write>
  brelse(bp);
    8000368e:	8526                	mv	a0,s1
    80003690:	00000097          	auipc	ra,0x0
    80003694:	db8080e7          	jalr	-584(ra) # 80003448 <brelse>
}
    80003698:	854a                	mv	a0,s2
    8000369a:	60e6                	ld	ra,88(sp)
    8000369c:	6446                	ld	s0,80(sp)
    8000369e:	64a6                	ld	s1,72(sp)
    800036a0:	6906                	ld	s2,64(sp)
    800036a2:	79e2                	ld	s3,56(sp)
    800036a4:	7a42                	ld	s4,48(sp)
    800036a6:	7aa2                	ld	s5,40(sp)
    800036a8:	7b02                	ld	s6,32(sp)
    800036aa:	6be2                	ld	s7,24(sp)
    800036ac:	6c42                	ld	s8,16(sp)
    800036ae:	6ca2                	ld	s9,8(sp)
    800036b0:	6125                	addi	sp,sp,96
    800036b2:	8082                	ret
    brelse(bp);
    800036b4:	8526                	mv	a0,s1
    800036b6:	00000097          	auipc	ra,0x0
    800036ba:	d92080e7          	jalr	-622(ra) # 80003448 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800036be:	015c87bb          	addw	a5,s9,s5
    800036c2:	00078a9b          	sext.w	s5,a5
    800036c6:	004b2703          	lw	a4,4(s6)
    800036ca:	06eafd63          	bleu	a4,s5,80003744 <balloc+0x140>
    bp = bread(dev, BBLOCK(b, sb));
    800036ce:	41fad79b          	sraiw	a5,s5,0x1f
    800036d2:	0137d79b          	srliw	a5,a5,0x13
    800036d6:	015787bb          	addw	a5,a5,s5
    800036da:	40d7d79b          	sraiw	a5,a5,0xd
    800036de:	01cb2583          	lw	a1,28(s6)
    800036e2:	9dbd                	addw	a1,a1,a5
    800036e4:	855e                	mv	a0,s7
    800036e6:	00000097          	auipc	ra,0x0
    800036ea:	ba0080e7          	jalr	-1120(ra) # 80003286 <bread>
    800036ee:	84aa                	mv	s1,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036f0:	000a881b          	sext.w	a6,s5
    800036f4:	004b2503          	lw	a0,4(s6)
    800036f8:	faa87ee3          	bleu	a0,a6,800036b4 <balloc+0xb0>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800036fc:	0604c603          	lbu	a2,96(s1)
    80003700:	00167793          	andi	a5,a2,1
    80003704:	df9d                	beqz	a5,80003642 <balloc+0x3e>
    80003706:	4105053b          	subw	a0,a0,a6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000370a:	87e2                	mv	a5,s8
    8000370c:	0107893b          	addw	s2,a5,a6
    80003710:	faa782e3          	beq	a5,a0,800036b4 <balloc+0xb0>
      m = 1 << (bi % 8);
    80003714:	41f7d71b          	sraiw	a4,a5,0x1f
    80003718:	01d7561b          	srliw	a2,a4,0x1d
    8000371c:	00f606bb          	addw	a3,a2,a5
    80003720:	0076f713          	andi	a4,a3,7
    80003724:	9f11                	subw	a4,a4,a2
    80003726:	00e9973b          	sllw	a4,s3,a4
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000372a:	4036d69b          	sraiw	a3,a3,0x3
    8000372e:	00d48633          	add	a2,s1,a3
    80003732:	06064603          	lbu	a2,96(a2)
    80003736:	00c775b3          	and	a1,a4,a2
    8000373a:	d599                	beqz	a1,80003648 <balloc+0x44>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000373c:	2785                	addiw	a5,a5,1
    8000373e:	fd4797e3          	bne	a5,s4,8000370c <balloc+0x108>
    80003742:	bf8d                	j	800036b4 <balloc+0xb0>
  panic("balloc: out of blocks");
    80003744:	00005517          	auipc	a0,0x5
    80003748:	e8c50513          	addi	a0,a0,-372 # 800085d0 <syscalls+0x140>
    8000374c:	ffffd097          	auipc	ra,0xffffd
    80003750:	e2c080e7          	jalr	-468(ra) # 80000578 <panic>

0000000080003754 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003754:	7179                	addi	sp,sp,-48
    80003756:	f406                	sd	ra,40(sp)
    80003758:	f022                	sd	s0,32(sp)
    8000375a:	ec26                	sd	s1,24(sp)
    8000375c:	e84a                	sd	s2,16(sp)
    8000375e:	e44e                	sd	s3,8(sp)
    80003760:	e052                	sd	s4,0(sp)
    80003762:	1800                	addi	s0,sp,48
    80003764:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003766:	47ad                	li	a5,11
    80003768:	04b7fe63          	bleu	a1,a5,800037c4 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000376c:	ff45849b          	addiw	s1,a1,-12
    80003770:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003774:	0ff00793          	li	a5,255
    80003778:	0ae7e363          	bltu	a5,a4,8000381e <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000377c:	08852583          	lw	a1,136(a0)
    80003780:	c5ad                	beqz	a1,800037ea <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003782:	0009a503          	lw	a0,0(s3)
    80003786:	00000097          	auipc	ra,0x0
    8000378a:	b00080e7          	jalr	-1280(ra) # 80003286 <bread>
    8000378e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003790:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    80003794:	02049593          	slli	a1,s1,0x20
    80003798:	9181                	srli	a1,a1,0x20
    8000379a:	058a                	slli	a1,a1,0x2
    8000379c:	00b784b3          	add	s1,a5,a1
    800037a0:	0004a903          	lw	s2,0(s1)
    800037a4:	04090d63          	beqz	s2,800037fe <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800037a8:	8552                	mv	a0,s4
    800037aa:	00000097          	auipc	ra,0x0
    800037ae:	c9e080e7          	jalr	-866(ra) # 80003448 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800037b2:	854a                	mv	a0,s2
    800037b4:	70a2                	ld	ra,40(sp)
    800037b6:	7402                	ld	s0,32(sp)
    800037b8:	64e2                	ld	s1,24(sp)
    800037ba:	6942                	ld	s2,16(sp)
    800037bc:	69a2                	ld	s3,8(sp)
    800037be:	6a02                	ld	s4,0(sp)
    800037c0:	6145                	addi	sp,sp,48
    800037c2:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800037c4:	02059493          	slli	s1,a1,0x20
    800037c8:	9081                	srli	s1,s1,0x20
    800037ca:	048a                	slli	s1,s1,0x2
    800037cc:	94aa                	add	s1,s1,a0
    800037ce:	0584a903          	lw	s2,88(s1)
    800037d2:	fe0910e3          	bnez	s2,800037b2 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800037d6:	4108                	lw	a0,0(a0)
    800037d8:	00000097          	auipc	ra,0x0
    800037dc:	e2c080e7          	jalr	-468(ra) # 80003604 <balloc>
    800037e0:	0005091b          	sext.w	s2,a0
    800037e4:	0524ac23          	sw	s2,88(s1)
    800037e8:	b7e9                	j	800037b2 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800037ea:	4108                	lw	a0,0(a0)
    800037ec:	00000097          	auipc	ra,0x0
    800037f0:	e18080e7          	jalr	-488(ra) # 80003604 <balloc>
    800037f4:	0005059b          	sext.w	a1,a0
    800037f8:	08b9a423          	sw	a1,136(s3)
    800037fc:	b759                	j	80003782 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800037fe:	0009a503          	lw	a0,0(s3)
    80003802:	00000097          	auipc	ra,0x0
    80003806:	e02080e7          	jalr	-510(ra) # 80003604 <balloc>
    8000380a:	0005091b          	sext.w	s2,a0
    8000380e:	0124a023          	sw	s2,0(s1)
      log_write(bp);
    80003812:	8552                	mv	a0,s4
    80003814:	00001097          	auipc	ra,0x1
    80003818:	f0a080e7          	jalr	-246(ra) # 8000471e <log_write>
    8000381c:	b771                	j	800037a8 <bmap+0x54>
  panic("bmap: out of range");
    8000381e:	00005517          	auipc	a0,0x5
    80003822:	dca50513          	addi	a0,a0,-566 # 800085e8 <syscalls+0x158>
    80003826:	ffffd097          	auipc	ra,0xffffd
    8000382a:	d52080e7          	jalr	-686(ra) # 80000578 <panic>

000000008000382e <iget>:
{
    8000382e:	7179                	addi	sp,sp,-48
    80003830:	f406                	sd	ra,40(sp)
    80003832:	f022                	sd	s0,32(sp)
    80003834:	ec26                	sd	s1,24(sp)
    80003836:	e84a                	sd	s2,16(sp)
    80003838:	e44e                	sd	s3,8(sp)
    8000383a:	e052                	sd	s4,0(sp)
    8000383c:	1800                	addi	s0,sp,48
    8000383e:	89aa                	mv	s3,a0
    80003840:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003842:	00027517          	auipc	a0,0x27
    80003846:	bae50513          	addi	a0,a0,-1106 # 8002a3f0 <icache>
    8000384a:	ffffd097          	auipc	ra,0xffffd
    8000384e:	530080e7          	jalr	1328(ra) # 80000d7a <acquire>
  empty = 0;
    80003852:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003854:	00027497          	auipc	s1,0x27
    80003858:	bbc48493          	addi	s1,s1,-1092 # 8002a410 <icache+0x20>
    8000385c:	00028697          	auipc	a3,0x28
    80003860:	7d468693          	addi	a3,a3,2004 # 8002c030 <log>
    80003864:	a039                	j	80003872 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003866:	02090b63          	beqz	s2,8000389c <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000386a:	09048493          	addi	s1,s1,144
    8000386e:	02d48a63          	beq	s1,a3,800038a2 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003872:	449c                	lw	a5,8(s1)
    80003874:	fef059e3          	blez	a5,80003866 <iget+0x38>
    80003878:	4098                	lw	a4,0(s1)
    8000387a:	ff3716e3          	bne	a4,s3,80003866 <iget+0x38>
    8000387e:	40d8                	lw	a4,4(s1)
    80003880:	ff4713e3          	bne	a4,s4,80003866 <iget+0x38>
      ip->ref++;
    80003884:	2785                	addiw	a5,a5,1
    80003886:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003888:	00027517          	auipc	a0,0x27
    8000388c:	b6850513          	addi	a0,a0,-1176 # 8002a3f0 <icache>
    80003890:	ffffd097          	auipc	ra,0xffffd
    80003894:	5ba080e7          	jalr	1466(ra) # 80000e4a <release>
      return ip;
    80003898:	8926                	mv	s2,s1
    8000389a:	a03d                	j	800038c8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000389c:	f7f9                	bnez	a5,8000386a <iget+0x3c>
    8000389e:	8926                	mv	s2,s1
    800038a0:	b7e9                	j	8000386a <iget+0x3c>
  if(empty == 0)
    800038a2:	02090c63          	beqz	s2,800038da <iget+0xac>
  ip->dev = dev;
    800038a6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800038aa:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800038ae:	4785                	li	a5,1
    800038b0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800038b4:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    800038b8:	00027517          	auipc	a0,0x27
    800038bc:	b3850513          	addi	a0,a0,-1224 # 8002a3f0 <icache>
    800038c0:	ffffd097          	auipc	ra,0xffffd
    800038c4:	58a080e7          	jalr	1418(ra) # 80000e4a <release>
}
    800038c8:	854a                	mv	a0,s2
    800038ca:	70a2                	ld	ra,40(sp)
    800038cc:	7402                	ld	s0,32(sp)
    800038ce:	64e2                	ld	s1,24(sp)
    800038d0:	6942                	ld	s2,16(sp)
    800038d2:	69a2                	ld	s3,8(sp)
    800038d4:	6a02                	ld	s4,0(sp)
    800038d6:	6145                	addi	sp,sp,48
    800038d8:	8082                	ret
    panic("iget: no inodes");
    800038da:	00005517          	auipc	a0,0x5
    800038de:	d2650513          	addi	a0,a0,-730 # 80008600 <syscalls+0x170>
    800038e2:	ffffd097          	auipc	ra,0xffffd
    800038e6:	c96080e7          	jalr	-874(ra) # 80000578 <panic>

00000000800038ea <fsinit>:
fsinit(int dev) {
    800038ea:	7179                	addi	sp,sp,-48
    800038ec:	f406                	sd	ra,40(sp)
    800038ee:	f022                	sd	s0,32(sp)
    800038f0:	ec26                	sd	s1,24(sp)
    800038f2:	e84a                	sd	s2,16(sp)
    800038f4:	e44e                	sd	s3,8(sp)
    800038f6:	1800                	addi	s0,sp,48
    800038f8:	89aa                	mv	s3,a0
  bp = bread(dev, 1);
    800038fa:	4585                	li	a1,1
    800038fc:	00000097          	auipc	ra,0x0
    80003900:	98a080e7          	jalr	-1654(ra) # 80003286 <bread>
    80003904:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003906:	00027497          	auipc	s1,0x27
    8000390a:	aca48493          	addi	s1,s1,-1334 # 8002a3d0 <sb>
    8000390e:	02000613          	li	a2,32
    80003912:	06050593          	addi	a1,a0,96
    80003916:	8526                	mv	a0,s1
    80003918:	ffffe097          	auipc	ra,0xffffe
    8000391c:	8da080e7          	jalr	-1830(ra) # 800011f2 <memmove>
  brelse(bp);
    80003920:	854a                	mv	a0,s2
    80003922:	00000097          	auipc	ra,0x0
    80003926:	b26080e7          	jalr	-1242(ra) # 80003448 <brelse>
  if(sb.magic != FSMAGIC)
    8000392a:	4098                	lw	a4,0(s1)
    8000392c:	102037b7          	lui	a5,0x10203
    80003930:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003934:	02f71263          	bne	a4,a5,80003958 <fsinit+0x6e>
  initlog(dev, &sb);
    80003938:	00027597          	auipc	a1,0x27
    8000393c:	a9858593          	addi	a1,a1,-1384 # 8002a3d0 <sb>
    80003940:	854e                	mv	a0,s3
    80003942:	00001097          	auipc	ra,0x1
    80003946:	b5a080e7          	jalr	-1190(ra) # 8000449c <initlog>
}
    8000394a:	70a2                	ld	ra,40(sp)
    8000394c:	7402                	ld	s0,32(sp)
    8000394e:	64e2                	ld	s1,24(sp)
    80003950:	6942                	ld	s2,16(sp)
    80003952:	69a2                	ld	s3,8(sp)
    80003954:	6145                	addi	sp,sp,48
    80003956:	8082                	ret
    panic("invalid file system");
    80003958:	00005517          	auipc	a0,0x5
    8000395c:	cb850513          	addi	a0,a0,-840 # 80008610 <syscalls+0x180>
    80003960:	ffffd097          	auipc	ra,0xffffd
    80003964:	c18080e7          	jalr	-1000(ra) # 80000578 <panic>

0000000080003968 <iinit>:
{
    80003968:	7179                	addi	sp,sp,-48
    8000396a:	f406                	sd	ra,40(sp)
    8000396c:	f022                	sd	s0,32(sp)
    8000396e:	ec26                	sd	s1,24(sp)
    80003970:	e84a                	sd	s2,16(sp)
    80003972:	e44e                	sd	s3,8(sp)
    80003974:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003976:	00005597          	auipc	a1,0x5
    8000397a:	cb258593          	addi	a1,a1,-846 # 80008628 <syscalls+0x198>
    8000397e:	00027517          	auipc	a0,0x27
    80003982:	a7250513          	addi	a0,a0,-1422 # 8002a3f0 <icache>
    80003986:	ffffd097          	auipc	ra,0xffffd
    8000398a:	580080e7          	jalr	1408(ra) # 80000f06 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000398e:	00027497          	auipc	s1,0x27
    80003992:	a9248493          	addi	s1,s1,-1390 # 8002a420 <icache+0x30>
    80003996:	00028997          	auipc	s3,0x28
    8000399a:	6aa98993          	addi	s3,s3,1706 # 8002c040 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    8000399e:	00005917          	auipc	s2,0x5
    800039a2:	c9290913          	addi	s2,s2,-878 # 80008630 <syscalls+0x1a0>
    800039a6:	85ca                	mv	a1,s2
    800039a8:	8526                	mv	a0,s1
    800039aa:	00001097          	auipc	ra,0x1
    800039ae:	e78080e7          	jalr	-392(ra) # 80004822 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800039b2:	09048493          	addi	s1,s1,144
    800039b6:	ff3498e3          	bne	s1,s3,800039a6 <iinit+0x3e>
}
    800039ba:	70a2                	ld	ra,40(sp)
    800039bc:	7402                	ld	s0,32(sp)
    800039be:	64e2                	ld	s1,24(sp)
    800039c0:	6942                	ld	s2,16(sp)
    800039c2:	69a2                	ld	s3,8(sp)
    800039c4:	6145                	addi	sp,sp,48
    800039c6:	8082                	ret

00000000800039c8 <ialloc>:
{
    800039c8:	715d                	addi	sp,sp,-80
    800039ca:	e486                	sd	ra,72(sp)
    800039cc:	e0a2                	sd	s0,64(sp)
    800039ce:	fc26                	sd	s1,56(sp)
    800039d0:	f84a                	sd	s2,48(sp)
    800039d2:	f44e                	sd	s3,40(sp)
    800039d4:	f052                	sd	s4,32(sp)
    800039d6:	ec56                	sd	s5,24(sp)
    800039d8:	e85a                	sd	s6,16(sp)
    800039da:	e45e                	sd	s7,8(sp)
    800039dc:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800039de:	00027797          	auipc	a5,0x27
    800039e2:	9f278793          	addi	a5,a5,-1550 # 8002a3d0 <sb>
    800039e6:	47d8                	lw	a4,12(a5)
    800039e8:	4785                	li	a5,1
    800039ea:	04e7fa63          	bleu	a4,a5,80003a3e <ialloc+0x76>
    800039ee:	8a2a                	mv	s4,a0
    800039f0:	8b2e                	mv	s6,a1
    800039f2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800039f4:	00027997          	auipc	s3,0x27
    800039f8:	9dc98993          	addi	s3,s3,-1572 # 8002a3d0 <sb>
    800039fc:	00048a9b          	sext.w	s5,s1
    80003a00:	0044d593          	srli	a1,s1,0x4
    80003a04:	0189a783          	lw	a5,24(s3)
    80003a08:	9dbd                	addw	a1,a1,a5
    80003a0a:	8552                	mv	a0,s4
    80003a0c:	00000097          	auipc	ra,0x0
    80003a10:	87a080e7          	jalr	-1926(ra) # 80003286 <bread>
    80003a14:	8baa                	mv	s7,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a16:	06050913          	addi	s2,a0,96
    80003a1a:	00f4f793          	andi	a5,s1,15
    80003a1e:	079a                	slli	a5,a5,0x6
    80003a20:	993e                	add	s2,s2,a5
    if(dip->type == 0){  // a free inode
    80003a22:	00091783          	lh	a5,0(s2)
    80003a26:	c785                	beqz	a5,80003a4e <ialloc+0x86>
    brelse(bp);
    80003a28:	00000097          	auipc	ra,0x0
    80003a2c:	a20080e7          	jalr	-1504(ra) # 80003448 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a30:	0485                	addi	s1,s1,1
    80003a32:	00c9a703          	lw	a4,12(s3)
    80003a36:	0004879b          	sext.w	a5,s1
    80003a3a:	fce7e1e3          	bltu	a5,a4,800039fc <ialloc+0x34>
  panic("ialloc: no inodes");
    80003a3e:	00005517          	auipc	a0,0x5
    80003a42:	bfa50513          	addi	a0,a0,-1030 # 80008638 <syscalls+0x1a8>
    80003a46:	ffffd097          	auipc	ra,0xffffd
    80003a4a:	b32080e7          	jalr	-1230(ra) # 80000578 <panic>
      memset(dip, 0, sizeof(*dip));
    80003a4e:	04000613          	li	a2,64
    80003a52:	4581                	li	a1,0
    80003a54:	854a                	mv	a0,s2
    80003a56:	ffffd097          	auipc	ra,0xffffd
    80003a5a:	730080e7          	jalr	1840(ra) # 80001186 <memset>
      dip->type = type;
    80003a5e:	01691023          	sh	s6,0(s2)
      log_write(bp);   // mark it allocated on the disk
    80003a62:	855e                	mv	a0,s7
    80003a64:	00001097          	auipc	ra,0x1
    80003a68:	cba080e7          	jalr	-838(ra) # 8000471e <log_write>
      brelse(bp);
    80003a6c:	855e                	mv	a0,s7
    80003a6e:	00000097          	auipc	ra,0x0
    80003a72:	9da080e7          	jalr	-1574(ra) # 80003448 <brelse>
      return iget(dev, inum);
    80003a76:	85d6                	mv	a1,s5
    80003a78:	8552                	mv	a0,s4
    80003a7a:	00000097          	auipc	ra,0x0
    80003a7e:	db4080e7          	jalr	-588(ra) # 8000382e <iget>
}
    80003a82:	60a6                	ld	ra,72(sp)
    80003a84:	6406                	ld	s0,64(sp)
    80003a86:	74e2                	ld	s1,56(sp)
    80003a88:	7942                	ld	s2,48(sp)
    80003a8a:	79a2                	ld	s3,40(sp)
    80003a8c:	7a02                	ld	s4,32(sp)
    80003a8e:	6ae2                	ld	s5,24(sp)
    80003a90:	6b42                	ld	s6,16(sp)
    80003a92:	6ba2                	ld	s7,8(sp)
    80003a94:	6161                	addi	sp,sp,80
    80003a96:	8082                	ret

0000000080003a98 <iupdate>:
{
    80003a98:	1101                	addi	sp,sp,-32
    80003a9a:	ec06                	sd	ra,24(sp)
    80003a9c:	e822                	sd	s0,16(sp)
    80003a9e:	e426                	sd	s1,8(sp)
    80003aa0:	e04a                	sd	s2,0(sp)
    80003aa2:	1000                	addi	s0,sp,32
    80003aa4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003aa6:	415c                	lw	a5,4(a0)
    80003aa8:	0047d79b          	srliw	a5,a5,0x4
    80003aac:	00027717          	auipc	a4,0x27
    80003ab0:	92470713          	addi	a4,a4,-1756 # 8002a3d0 <sb>
    80003ab4:	4f0c                	lw	a1,24(a4)
    80003ab6:	9dbd                	addw	a1,a1,a5
    80003ab8:	4108                	lw	a0,0(a0)
    80003aba:	fffff097          	auipc	ra,0xfffff
    80003abe:	7cc080e7          	jalr	1996(ra) # 80003286 <bread>
    80003ac2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ac4:	06050513          	addi	a0,a0,96
    80003ac8:	40dc                	lw	a5,4(s1)
    80003aca:	8bbd                	andi	a5,a5,15
    80003acc:	079a                	slli	a5,a5,0x6
    80003ace:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003ad0:	04c49783          	lh	a5,76(s1)
    80003ad4:	00f51023          	sh	a5,0(a0)
  dip->major = ip->major;
    80003ad8:	04e49783          	lh	a5,78(s1)
    80003adc:	00f51123          	sh	a5,2(a0)
  dip->minor = ip->minor;
    80003ae0:	05049783          	lh	a5,80(s1)
    80003ae4:	00f51223          	sh	a5,4(a0)
  dip->nlink = ip->nlink;
    80003ae8:	05249783          	lh	a5,82(s1)
    80003aec:	00f51323          	sh	a5,6(a0)
  dip->size = ip->size;
    80003af0:	48fc                	lw	a5,84(s1)
    80003af2:	c51c                	sw	a5,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003af4:	03400613          	li	a2,52
    80003af8:	05848593          	addi	a1,s1,88
    80003afc:	0531                	addi	a0,a0,12
    80003afe:	ffffd097          	auipc	ra,0xffffd
    80003b02:	6f4080e7          	jalr	1780(ra) # 800011f2 <memmove>
  log_write(bp);
    80003b06:	854a                	mv	a0,s2
    80003b08:	00001097          	auipc	ra,0x1
    80003b0c:	c16080e7          	jalr	-1002(ra) # 8000471e <log_write>
  brelse(bp);
    80003b10:	854a                	mv	a0,s2
    80003b12:	00000097          	auipc	ra,0x0
    80003b16:	936080e7          	jalr	-1738(ra) # 80003448 <brelse>
}
    80003b1a:	60e2                	ld	ra,24(sp)
    80003b1c:	6442                	ld	s0,16(sp)
    80003b1e:	64a2                	ld	s1,8(sp)
    80003b20:	6902                	ld	s2,0(sp)
    80003b22:	6105                	addi	sp,sp,32
    80003b24:	8082                	ret

0000000080003b26 <idup>:
{
    80003b26:	1101                	addi	sp,sp,-32
    80003b28:	ec06                	sd	ra,24(sp)
    80003b2a:	e822                	sd	s0,16(sp)
    80003b2c:	e426                	sd	s1,8(sp)
    80003b2e:	1000                	addi	s0,sp,32
    80003b30:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003b32:	00027517          	auipc	a0,0x27
    80003b36:	8be50513          	addi	a0,a0,-1858 # 8002a3f0 <icache>
    80003b3a:	ffffd097          	auipc	ra,0xffffd
    80003b3e:	240080e7          	jalr	576(ra) # 80000d7a <acquire>
  ip->ref++;
    80003b42:	449c                	lw	a5,8(s1)
    80003b44:	2785                	addiw	a5,a5,1
    80003b46:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003b48:	00027517          	auipc	a0,0x27
    80003b4c:	8a850513          	addi	a0,a0,-1880 # 8002a3f0 <icache>
    80003b50:	ffffd097          	auipc	ra,0xffffd
    80003b54:	2fa080e7          	jalr	762(ra) # 80000e4a <release>
}
    80003b58:	8526                	mv	a0,s1
    80003b5a:	60e2                	ld	ra,24(sp)
    80003b5c:	6442                	ld	s0,16(sp)
    80003b5e:	64a2                	ld	s1,8(sp)
    80003b60:	6105                	addi	sp,sp,32
    80003b62:	8082                	ret

0000000080003b64 <ilock>:
{
    80003b64:	1101                	addi	sp,sp,-32
    80003b66:	ec06                	sd	ra,24(sp)
    80003b68:	e822                	sd	s0,16(sp)
    80003b6a:	e426                	sd	s1,8(sp)
    80003b6c:	e04a                	sd	s2,0(sp)
    80003b6e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003b70:	c115                	beqz	a0,80003b94 <ilock+0x30>
    80003b72:	84aa                	mv	s1,a0
    80003b74:	451c                	lw	a5,8(a0)
    80003b76:	00f05f63          	blez	a5,80003b94 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003b7a:	0541                	addi	a0,a0,16
    80003b7c:	00001097          	auipc	ra,0x1
    80003b80:	ce0080e7          	jalr	-800(ra) # 8000485c <acquiresleep>
  if(ip->valid == 0){
    80003b84:	44bc                	lw	a5,72(s1)
    80003b86:	cf99                	beqz	a5,80003ba4 <ilock+0x40>
}
    80003b88:	60e2                	ld	ra,24(sp)
    80003b8a:	6442                	ld	s0,16(sp)
    80003b8c:	64a2                	ld	s1,8(sp)
    80003b8e:	6902                	ld	s2,0(sp)
    80003b90:	6105                	addi	sp,sp,32
    80003b92:	8082                	ret
    panic("ilock");
    80003b94:	00005517          	auipc	a0,0x5
    80003b98:	abc50513          	addi	a0,a0,-1348 # 80008650 <syscalls+0x1c0>
    80003b9c:	ffffd097          	auipc	ra,0xffffd
    80003ba0:	9dc080e7          	jalr	-1572(ra) # 80000578 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ba4:	40dc                	lw	a5,4(s1)
    80003ba6:	0047d79b          	srliw	a5,a5,0x4
    80003baa:	00027717          	auipc	a4,0x27
    80003bae:	82670713          	addi	a4,a4,-2010 # 8002a3d0 <sb>
    80003bb2:	4f0c                	lw	a1,24(a4)
    80003bb4:	9dbd                	addw	a1,a1,a5
    80003bb6:	4088                	lw	a0,0(s1)
    80003bb8:	fffff097          	auipc	ra,0xfffff
    80003bbc:	6ce080e7          	jalr	1742(ra) # 80003286 <bread>
    80003bc0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bc2:	06050593          	addi	a1,a0,96
    80003bc6:	40dc                	lw	a5,4(s1)
    80003bc8:	8bbd                	andi	a5,a5,15
    80003bca:	079a                	slli	a5,a5,0x6
    80003bcc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003bce:	00059783          	lh	a5,0(a1)
    80003bd2:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    80003bd6:	00259783          	lh	a5,2(a1)
    80003bda:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80003bde:	00459783          	lh	a5,4(a1)
    80003be2:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    80003be6:	00659783          	lh	a5,6(a1)
    80003bea:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003bee:	459c                	lw	a5,8(a1)
    80003bf0:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003bf2:	03400613          	li	a2,52
    80003bf6:	05b1                	addi	a1,a1,12
    80003bf8:	05848513          	addi	a0,s1,88
    80003bfc:	ffffd097          	auipc	ra,0xffffd
    80003c00:	5f6080e7          	jalr	1526(ra) # 800011f2 <memmove>
    brelse(bp);
    80003c04:	854a                	mv	a0,s2
    80003c06:	00000097          	auipc	ra,0x0
    80003c0a:	842080e7          	jalr	-1982(ra) # 80003448 <brelse>
    ip->valid = 1;
    80003c0e:	4785                	li	a5,1
    80003c10:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    80003c12:	04c49783          	lh	a5,76(s1)
    80003c16:	fbad                	bnez	a5,80003b88 <ilock+0x24>
      panic("ilock: no type");
    80003c18:	00005517          	auipc	a0,0x5
    80003c1c:	a4050513          	addi	a0,a0,-1472 # 80008658 <syscalls+0x1c8>
    80003c20:	ffffd097          	auipc	ra,0xffffd
    80003c24:	958080e7          	jalr	-1704(ra) # 80000578 <panic>

0000000080003c28 <iunlock>:
{
    80003c28:	1101                	addi	sp,sp,-32
    80003c2a:	ec06                	sd	ra,24(sp)
    80003c2c:	e822                	sd	s0,16(sp)
    80003c2e:	e426                	sd	s1,8(sp)
    80003c30:	e04a                	sd	s2,0(sp)
    80003c32:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c34:	c905                	beqz	a0,80003c64 <iunlock+0x3c>
    80003c36:	84aa                	mv	s1,a0
    80003c38:	01050913          	addi	s2,a0,16
    80003c3c:	854a                	mv	a0,s2
    80003c3e:	00001097          	auipc	ra,0x1
    80003c42:	cb8080e7          	jalr	-840(ra) # 800048f6 <holdingsleep>
    80003c46:	cd19                	beqz	a0,80003c64 <iunlock+0x3c>
    80003c48:	449c                	lw	a5,8(s1)
    80003c4a:	00f05d63          	blez	a5,80003c64 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003c4e:	854a                	mv	a0,s2
    80003c50:	00001097          	auipc	ra,0x1
    80003c54:	c62080e7          	jalr	-926(ra) # 800048b2 <releasesleep>
}
    80003c58:	60e2                	ld	ra,24(sp)
    80003c5a:	6442                	ld	s0,16(sp)
    80003c5c:	64a2                	ld	s1,8(sp)
    80003c5e:	6902                	ld	s2,0(sp)
    80003c60:	6105                	addi	sp,sp,32
    80003c62:	8082                	ret
    panic("iunlock");
    80003c64:	00005517          	auipc	a0,0x5
    80003c68:	a0450513          	addi	a0,a0,-1532 # 80008668 <syscalls+0x1d8>
    80003c6c:	ffffd097          	auipc	ra,0xffffd
    80003c70:	90c080e7          	jalr	-1780(ra) # 80000578 <panic>

0000000080003c74 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c74:	7179                	addi	sp,sp,-48
    80003c76:	f406                	sd	ra,40(sp)
    80003c78:	f022                	sd	s0,32(sp)
    80003c7a:	ec26                	sd	s1,24(sp)
    80003c7c:	e84a                	sd	s2,16(sp)
    80003c7e:	e44e                	sd	s3,8(sp)
    80003c80:	e052                	sd	s4,0(sp)
    80003c82:	1800                	addi	s0,sp,48
    80003c84:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003c86:	05850493          	addi	s1,a0,88
    80003c8a:	08850913          	addi	s2,a0,136
    80003c8e:	a821                	j	80003ca6 <itrunc+0x32>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    80003c90:	0009a503          	lw	a0,0(s3)
    80003c94:	00000097          	auipc	ra,0x0
    80003c98:	8e0080e7          	jalr	-1824(ra) # 80003574 <bfree>
      ip->addrs[i] = 0;
    80003c9c:	0004a023          	sw	zero,0(s1)
  for(i = 0; i < NDIRECT; i++){
    80003ca0:	0491                	addi	s1,s1,4
    80003ca2:	01248563          	beq	s1,s2,80003cac <itrunc+0x38>
    if(ip->addrs[i]){
    80003ca6:	408c                	lw	a1,0(s1)
    80003ca8:	dde5                	beqz	a1,80003ca0 <itrunc+0x2c>
    80003caa:	b7dd                	j	80003c90 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003cac:	0889a583          	lw	a1,136(s3)
    80003cb0:	e185                	bnez	a1,80003cd0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003cb2:	0409aa23          	sw	zero,84(s3)
  iupdate(ip);
    80003cb6:	854e                	mv	a0,s3
    80003cb8:	00000097          	auipc	ra,0x0
    80003cbc:	de0080e7          	jalr	-544(ra) # 80003a98 <iupdate>
}
    80003cc0:	70a2                	ld	ra,40(sp)
    80003cc2:	7402                	ld	s0,32(sp)
    80003cc4:	64e2                	ld	s1,24(sp)
    80003cc6:	6942                	ld	s2,16(sp)
    80003cc8:	69a2                	ld	s3,8(sp)
    80003cca:	6a02                	ld	s4,0(sp)
    80003ccc:	6145                	addi	sp,sp,48
    80003cce:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003cd0:	0009a503          	lw	a0,0(s3)
    80003cd4:	fffff097          	auipc	ra,0xfffff
    80003cd8:	5b2080e7          	jalr	1458(ra) # 80003286 <bread>
    80003cdc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003cde:	06050493          	addi	s1,a0,96
    80003ce2:	46050913          	addi	s2,a0,1120
    80003ce6:	a811                	j	80003cfa <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003ce8:	0009a503          	lw	a0,0(s3)
    80003cec:	00000097          	auipc	ra,0x0
    80003cf0:	888080e7          	jalr	-1912(ra) # 80003574 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003cf4:	0491                	addi	s1,s1,4
    80003cf6:	01248563          	beq	s1,s2,80003d00 <itrunc+0x8c>
      if(a[j])
    80003cfa:	408c                	lw	a1,0(s1)
    80003cfc:	dde5                	beqz	a1,80003cf4 <itrunc+0x80>
    80003cfe:	b7ed                	j	80003ce8 <itrunc+0x74>
    brelse(bp);
    80003d00:	8552                	mv	a0,s4
    80003d02:	fffff097          	auipc	ra,0xfffff
    80003d06:	746080e7          	jalr	1862(ra) # 80003448 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d0a:	0889a583          	lw	a1,136(s3)
    80003d0e:	0009a503          	lw	a0,0(s3)
    80003d12:	00000097          	auipc	ra,0x0
    80003d16:	862080e7          	jalr	-1950(ra) # 80003574 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d1a:	0809a423          	sw	zero,136(s3)
    80003d1e:	bf51                	j	80003cb2 <itrunc+0x3e>

0000000080003d20 <iput>:
{
    80003d20:	1101                	addi	sp,sp,-32
    80003d22:	ec06                	sd	ra,24(sp)
    80003d24:	e822                	sd	s0,16(sp)
    80003d26:	e426                	sd	s1,8(sp)
    80003d28:	e04a                	sd	s2,0(sp)
    80003d2a:	1000                	addi	s0,sp,32
    80003d2c:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003d2e:	00026517          	auipc	a0,0x26
    80003d32:	6c250513          	addi	a0,a0,1730 # 8002a3f0 <icache>
    80003d36:	ffffd097          	auipc	ra,0xffffd
    80003d3a:	044080e7          	jalr	68(ra) # 80000d7a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d3e:	4498                	lw	a4,8(s1)
    80003d40:	4785                	li	a5,1
    80003d42:	02f70363          	beq	a4,a5,80003d68 <iput+0x48>
  ip->ref--;
    80003d46:	449c                	lw	a5,8(s1)
    80003d48:	37fd                	addiw	a5,a5,-1
    80003d4a:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003d4c:	00026517          	auipc	a0,0x26
    80003d50:	6a450513          	addi	a0,a0,1700 # 8002a3f0 <icache>
    80003d54:	ffffd097          	auipc	ra,0xffffd
    80003d58:	0f6080e7          	jalr	246(ra) # 80000e4a <release>
}
    80003d5c:	60e2                	ld	ra,24(sp)
    80003d5e:	6442                	ld	s0,16(sp)
    80003d60:	64a2                	ld	s1,8(sp)
    80003d62:	6902                	ld	s2,0(sp)
    80003d64:	6105                	addi	sp,sp,32
    80003d66:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d68:	44bc                	lw	a5,72(s1)
    80003d6a:	dff1                	beqz	a5,80003d46 <iput+0x26>
    80003d6c:	05249783          	lh	a5,82(s1)
    80003d70:	fbf9                	bnez	a5,80003d46 <iput+0x26>
    acquiresleep(&ip->lock);
    80003d72:	01048913          	addi	s2,s1,16
    80003d76:	854a                	mv	a0,s2
    80003d78:	00001097          	auipc	ra,0x1
    80003d7c:	ae4080e7          	jalr	-1308(ra) # 8000485c <acquiresleep>
    release(&icache.lock);
    80003d80:	00026517          	auipc	a0,0x26
    80003d84:	67050513          	addi	a0,a0,1648 # 8002a3f0 <icache>
    80003d88:	ffffd097          	auipc	ra,0xffffd
    80003d8c:	0c2080e7          	jalr	194(ra) # 80000e4a <release>
    itrunc(ip);
    80003d90:	8526                	mv	a0,s1
    80003d92:	00000097          	auipc	ra,0x0
    80003d96:	ee2080e7          	jalr	-286(ra) # 80003c74 <itrunc>
    ip->type = 0;
    80003d9a:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003d9e:	8526                	mv	a0,s1
    80003da0:	00000097          	auipc	ra,0x0
    80003da4:	cf8080e7          	jalr	-776(ra) # 80003a98 <iupdate>
    ip->valid = 0;
    80003da8:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003dac:	854a                	mv	a0,s2
    80003dae:	00001097          	auipc	ra,0x1
    80003db2:	b04080e7          	jalr	-1276(ra) # 800048b2 <releasesleep>
    acquire(&icache.lock);
    80003db6:	00026517          	auipc	a0,0x26
    80003dba:	63a50513          	addi	a0,a0,1594 # 8002a3f0 <icache>
    80003dbe:	ffffd097          	auipc	ra,0xffffd
    80003dc2:	fbc080e7          	jalr	-68(ra) # 80000d7a <acquire>
    80003dc6:	b741                	j	80003d46 <iput+0x26>

0000000080003dc8 <iunlockput>:
{
    80003dc8:	1101                	addi	sp,sp,-32
    80003dca:	ec06                	sd	ra,24(sp)
    80003dcc:	e822                	sd	s0,16(sp)
    80003dce:	e426                	sd	s1,8(sp)
    80003dd0:	1000                	addi	s0,sp,32
    80003dd2:	84aa                	mv	s1,a0
  iunlock(ip);
    80003dd4:	00000097          	auipc	ra,0x0
    80003dd8:	e54080e7          	jalr	-428(ra) # 80003c28 <iunlock>
  iput(ip);
    80003ddc:	8526                	mv	a0,s1
    80003dde:	00000097          	auipc	ra,0x0
    80003de2:	f42080e7          	jalr	-190(ra) # 80003d20 <iput>
}
    80003de6:	60e2                	ld	ra,24(sp)
    80003de8:	6442                	ld	s0,16(sp)
    80003dea:	64a2                	ld	s1,8(sp)
    80003dec:	6105                	addi	sp,sp,32
    80003dee:	8082                	ret

0000000080003df0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003df0:	1141                	addi	sp,sp,-16
    80003df2:	e422                	sd	s0,8(sp)
    80003df4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003df6:	411c                	lw	a5,0(a0)
    80003df8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003dfa:	415c                	lw	a5,4(a0)
    80003dfc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003dfe:	04c51783          	lh	a5,76(a0)
    80003e02:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e06:	05251783          	lh	a5,82(a0)
    80003e0a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e0e:	05456783          	lwu	a5,84(a0)
    80003e12:	e99c                	sd	a5,16(a1)
}
    80003e14:	6422                	ld	s0,8(sp)
    80003e16:	0141                	addi	sp,sp,16
    80003e18:	8082                	ret

0000000080003e1a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e1a:	497c                	lw	a5,84(a0)
    80003e1c:	0ed7e963          	bltu	a5,a3,80003f0e <readi+0xf4>
{
    80003e20:	7159                	addi	sp,sp,-112
    80003e22:	f486                	sd	ra,104(sp)
    80003e24:	f0a2                	sd	s0,96(sp)
    80003e26:	eca6                	sd	s1,88(sp)
    80003e28:	e8ca                	sd	s2,80(sp)
    80003e2a:	e4ce                	sd	s3,72(sp)
    80003e2c:	e0d2                	sd	s4,64(sp)
    80003e2e:	fc56                	sd	s5,56(sp)
    80003e30:	f85a                	sd	s6,48(sp)
    80003e32:	f45e                	sd	s7,40(sp)
    80003e34:	f062                	sd	s8,32(sp)
    80003e36:	ec66                	sd	s9,24(sp)
    80003e38:	e86a                	sd	s10,16(sp)
    80003e3a:	e46e                	sd	s11,8(sp)
    80003e3c:	1880                	addi	s0,sp,112
    80003e3e:	8baa                	mv	s7,a0
    80003e40:	8c2e                	mv	s8,a1
    80003e42:	8a32                	mv	s4,a2
    80003e44:	84b6                	mv	s1,a3
    80003e46:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003e48:	9f35                	addw	a4,a4,a3
    return 0;
    80003e4a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003e4c:	0ad76063          	bltu	a4,a3,80003eec <readi+0xd2>
  if(off + n > ip->size)
    80003e50:	00e7f463          	bleu	a4,a5,80003e58 <readi+0x3e>
    n = ip->size - off;
    80003e54:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e58:	0a0b0963          	beqz	s6,80003f0a <readi+0xf0>
    80003e5c:	4901                	li	s2,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e5e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e62:	5cfd                	li	s9,-1
    80003e64:	a82d                	j	80003e9e <readi+0x84>
    80003e66:	02099d93          	slli	s11,s3,0x20
    80003e6a:	020ddd93          	srli	s11,s11,0x20
    80003e6e:	060a8613          	addi	a2,s5,96
    80003e72:	86ee                	mv	a3,s11
    80003e74:	963a                	add	a2,a2,a4
    80003e76:	85d2                	mv	a1,s4
    80003e78:	8562                	mv	a0,s8
    80003e7a:	fffff097          	auipc	ra,0xfffff
    80003e7e:	a2c080e7          	jalr	-1492(ra) # 800028a6 <either_copyout>
    80003e82:	05950d63          	beq	a0,s9,80003edc <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e86:	8556                	mv	a0,s5
    80003e88:	fffff097          	auipc	ra,0xfffff
    80003e8c:	5c0080e7          	jalr	1472(ra) # 80003448 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e90:	0129893b          	addw	s2,s3,s2
    80003e94:	009984bb          	addw	s1,s3,s1
    80003e98:	9a6e                	add	s4,s4,s11
    80003e9a:	05697763          	bleu	s6,s2,80003ee8 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003e9e:	000ba983          	lw	s3,0(s7)
    80003ea2:	00a4d59b          	srliw	a1,s1,0xa
    80003ea6:	855e                	mv	a0,s7
    80003ea8:	00000097          	auipc	ra,0x0
    80003eac:	8ac080e7          	jalr	-1876(ra) # 80003754 <bmap>
    80003eb0:	0005059b          	sext.w	a1,a0
    80003eb4:	854e                	mv	a0,s3
    80003eb6:	fffff097          	auipc	ra,0xfffff
    80003eba:	3d0080e7          	jalr	976(ra) # 80003286 <bread>
    80003ebe:	8aaa                	mv	s5,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ec0:	3ff4f713          	andi	a4,s1,1023
    80003ec4:	40ed07bb          	subw	a5,s10,a4
    80003ec8:	412b06bb          	subw	a3,s6,s2
    80003ecc:	89be                	mv	s3,a5
    80003ece:	2781                	sext.w	a5,a5
    80003ed0:	0006861b          	sext.w	a2,a3
    80003ed4:	f8f679e3          	bleu	a5,a2,80003e66 <readi+0x4c>
    80003ed8:	89b6                	mv	s3,a3
    80003eda:	b771                	j	80003e66 <readi+0x4c>
      brelse(bp);
    80003edc:	8556                	mv	a0,s5
    80003ede:	fffff097          	auipc	ra,0xfffff
    80003ee2:	56a080e7          	jalr	1386(ra) # 80003448 <brelse>
      tot = -1;
    80003ee6:	597d                	li	s2,-1
  }
  return tot;
    80003ee8:	0009051b          	sext.w	a0,s2
}
    80003eec:	70a6                	ld	ra,104(sp)
    80003eee:	7406                	ld	s0,96(sp)
    80003ef0:	64e6                	ld	s1,88(sp)
    80003ef2:	6946                	ld	s2,80(sp)
    80003ef4:	69a6                	ld	s3,72(sp)
    80003ef6:	6a06                	ld	s4,64(sp)
    80003ef8:	7ae2                	ld	s5,56(sp)
    80003efa:	7b42                	ld	s6,48(sp)
    80003efc:	7ba2                	ld	s7,40(sp)
    80003efe:	7c02                	ld	s8,32(sp)
    80003f00:	6ce2                	ld	s9,24(sp)
    80003f02:	6d42                	ld	s10,16(sp)
    80003f04:	6da2                	ld	s11,8(sp)
    80003f06:	6165                	addi	sp,sp,112
    80003f08:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f0a:	895a                	mv	s2,s6
    80003f0c:	bff1                	j	80003ee8 <readi+0xce>
    return 0;
    80003f0e:	4501                	li	a0,0
}
    80003f10:	8082                	ret

0000000080003f12 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f12:	497c                	lw	a5,84(a0)
    80003f14:	10d7e763          	bltu	a5,a3,80004022 <writei+0x110>
{
    80003f18:	7159                	addi	sp,sp,-112
    80003f1a:	f486                	sd	ra,104(sp)
    80003f1c:	f0a2                	sd	s0,96(sp)
    80003f1e:	eca6                	sd	s1,88(sp)
    80003f20:	e8ca                	sd	s2,80(sp)
    80003f22:	e4ce                	sd	s3,72(sp)
    80003f24:	e0d2                	sd	s4,64(sp)
    80003f26:	fc56                	sd	s5,56(sp)
    80003f28:	f85a                	sd	s6,48(sp)
    80003f2a:	f45e                	sd	s7,40(sp)
    80003f2c:	f062                	sd	s8,32(sp)
    80003f2e:	ec66                	sd	s9,24(sp)
    80003f30:	e86a                	sd	s10,16(sp)
    80003f32:	e46e                	sd	s11,8(sp)
    80003f34:	1880                	addi	s0,sp,112
    80003f36:	8baa                	mv	s7,a0
    80003f38:	8c2e                	mv	s8,a1
    80003f3a:	8ab2                	mv	s5,a2
    80003f3c:	84b6                	mv	s1,a3
    80003f3e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f40:	00e687bb          	addw	a5,a3,a4
    80003f44:	0ed7e163          	bltu	a5,a3,80004026 <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f48:	00043737          	lui	a4,0x43
    80003f4c:	0cf76f63          	bltu	a4,a5,8000402a <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f50:	0a0b0863          	beqz	s6,80004000 <writei+0xee>
    80003f54:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f56:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f5a:	5cfd                	li	s9,-1
    80003f5c:	a091                	j	80003fa0 <writei+0x8e>
    80003f5e:	02091d93          	slli	s11,s2,0x20
    80003f62:	020ddd93          	srli	s11,s11,0x20
    80003f66:	06098513          	addi	a0,s3,96
    80003f6a:	86ee                	mv	a3,s11
    80003f6c:	8656                	mv	a2,s5
    80003f6e:	85e2                	mv	a1,s8
    80003f70:	953a                	add	a0,a0,a4
    80003f72:	fffff097          	auipc	ra,0xfffff
    80003f76:	98a080e7          	jalr	-1654(ra) # 800028fc <either_copyin>
    80003f7a:	07950263          	beq	a0,s9,80003fde <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80003f7e:	854e                	mv	a0,s3
    80003f80:	00000097          	auipc	ra,0x0
    80003f84:	79e080e7          	jalr	1950(ra) # 8000471e <log_write>
    brelse(bp);
    80003f88:	854e                	mv	a0,s3
    80003f8a:	fffff097          	auipc	ra,0xfffff
    80003f8e:	4be080e7          	jalr	1214(ra) # 80003448 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f92:	01490a3b          	addw	s4,s2,s4
    80003f96:	009904bb          	addw	s1,s2,s1
    80003f9a:	9aee                	add	s5,s5,s11
    80003f9c:	056a7763          	bleu	s6,s4,80003fea <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003fa0:	000ba903          	lw	s2,0(s7)
    80003fa4:	00a4d59b          	srliw	a1,s1,0xa
    80003fa8:	855e                	mv	a0,s7
    80003faa:	fffff097          	auipc	ra,0xfffff
    80003fae:	7aa080e7          	jalr	1962(ra) # 80003754 <bmap>
    80003fb2:	0005059b          	sext.w	a1,a0
    80003fb6:	854a                	mv	a0,s2
    80003fb8:	fffff097          	auipc	ra,0xfffff
    80003fbc:	2ce080e7          	jalr	718(ra) # 80003286 <bread>
    80003fc0:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fc2:	3ff4f713          	andi	a4,s1,1023
    80003fc6:	40ed07bb          	subw	a5,s10,a4
    80003fca:	414b06bb          	subw	a3,s6,s4
    80003fce:	893e                	mv	s2,a5
    80003fd0:	2781                	sext.w	a5,a5
    80003fd2:	0006861b          	sext.w	a2,a3
    80003fd6:	f8f674e3          	bleu	a5,a2,80003f5e <writei+0x4c>
    80003fda:	8936                	mv	s2,a3
    80003fdc:	b749                	j	80003f5e <writei+0x4c>
      brelse(bp);
    80003fde:	854e                	mv	a0,s3
    80003fe0:	fffff097          	auipc	ra,0xfffff
    80003fe4:	468080e7          	jalr	1128(ra) # 80003448 <brelse>
      n = -1;
    80003fe8:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003fea:	054ba783          	lw	a5,84(s7)
    80003fee:	0097f463          	bleu	s1,a5,80003ff6 <writei+0xe4>
      ip->size = off;
    80003ff2:	049baa23          	sw	s1,84(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003ff6:	855e                	mv	a0,s7
    80003ff8:	00000097          	auipc	ra,0x0
    80003ffc:	aa0080e7          	jalr	-1376(ra) # 80003a98 <iupdate>
  }

  return n;
    80004000:	000b051b          	sext.w	a0,s6
}
    80004004:	70a6                	ld	ra,104(sp)
    80004006:	7406                	ld	s0,96(sp)
    80004008:	64e6                	ld	s1,88(sp)
    8000400a:	6946                	ld	s2,80(sp)
    8000400c:	69a6                	ld	s3,72(sp)
    8000400e:	6a06                	ld	s4,64(sp)
    80004010:	7ae2                	ld	s5,56(sp)
    80004012:	7b42                	ld	s6,48(sp)
    80004014:	7ba2                	ld	s7,40(sp)
    80004016:	7c02                	ld	s8,32(sp)
    80004018:	6ce2                	ld	s9,24(sp)
    8000401a:	6d42                	ld	s10,16(sp)
    8000401c:	6da2                	ld	s11,8(sp)
    8000401e:	6165                	addi	sp,sp,112
    80004020:	8082                	ret
    return -1;
    80004022:	557d                	li	a0,-1
}
    80004024:	8082                	ret
    return -1;
    80004026:	557d                	li	a0,-1
    80004028:	bff1                	j	80004004 <writei+0xf2>
    return -1;
    8000402a:	557d                	li	a0,-1
    8000402c:	bfe1                	j	80004004 <writei+0xf2>

000000008000402e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000402e:	1141                	addi	sp,sp,-16
    80004030:	e406                	sd	ra,8(sp)
    80004032:	e022                	sd	s0,0(sp)
    80004034:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004036:	4639                	li	a2,14
    80004038:	ffffd097          	auipc	ra,0xffffd
    8000403c:	236080e7          	jalr	566(ra) # 8000126e <strncmp>
}
    80004040:	60a2                	ld	ra,8(sp)
    80004042:	6402                	ld	s0,0(sp)
    80004044:	0141                	addi	sp,sp,16
    80004046:	8082                	ret

0000000080004048 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004048:	7139                	addi	sp,sp,-64
    8000404a:	fc06                	sd	ra,56(sp)
    8000404c:	f822                	sd	s0,48(sp)
    8000404e:	f426                	sd	s1,40(sp)
    80004050:	f04a                	sd	s2,32(sp)
    80004052:	ec4e                	sd	s3,24(sp)
    80004054:	e852                	sd	s4,16(sp)
    80004056:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004058:	04c51703          	lh	a4,76(a0)
    8000405c:	4785                	li	a5,1
    8000405e:	00f71a63          	bne	a4,a5,80004072 <dirlookup+0x2a>
    80004062:	892a                	mv	s2,a0
    80004064:	89ae                	mv	s3,a1
    80004066:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004068:	497c                	lw	a5,84(a0)
    8000406a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000406c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000406e:	e79d                	bnez	a5,8000409c <dirlookup+0x54>
    80004070:	a8a5                	j	800040e8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004072:	00004517          	auipc	a0,0x4
    80004076:	5fe50513          	addi	a0,a0,1534 # 80008670 <syscalls+0x1e0>
    8000407a:	ffffc097          	auipc	ra,0xffffc
    8000407e:	4fe080e7          	jalr	1278(ra) # 80000578 <panic>
      panic("dirlookup read");
    80004082:	00004517          	auipc	a0,0x4
    80004086:	60650513          	addi	a0,a0,1542 # 80008688 <syscalls+0x1f8>
    8000408a:	ffffc097          	auipc	ra,0xffffc
    8000408e:	4ee080e7          	jalr	1262(ra) # 80000578 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004092:	24c1                	addiw	s1,s1,16
    80004094:	05492783          	lw	a5,84(s2)
    80004098:	04f4f763          	bleu	a5,s1,800040e6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000409c:	4741                	li	a4,16
    8000409e:	86a6                	mv	a3,s1
    800040a0:	fc040613          	addi	a2,s0,-64
    800040a4:	4581                	li	a1,0
    800040a6:	854a                	mv	a0,s2
    800040a8:	00000097          	auipc	ra,0x0
    800040ac:	d72080e7          	jalr	-654(ra) # 80003e1a <readi>
    800040b0:	47c1                	li	a5,16
    800040b2:	fcf518e3          	bne	a0,a5,80004082 <dirlookup+0x3a>
    if(de.inum == 0)
    800040b6:	fc045783          	lhu	a5,-64(s0)
    800040ba:	dfe1                	beqz	a5,80004092 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800040bc:	fc240593          	addi	a1,s0,-62
    800040c0:	854e                	mv	a0,s3
    800040c2:	00000097          	auipc	ra,0x0
    800040c6:	f6c080e7          	jalr	-148(ra) # 8000402e <namecmp>
    800040ca:	f561                	bnez	a0,80004092 <dirlookup+0x4a>
      if(poff)
    800040cc:	000a0463          	beqz	s4,800040d4 <dirlookup+0x8c>
        *poff = off;
    800040d0:	009a2023          	sw	s1,0(s4) # 2000 <_entry-0x7fffe000>
      return iget(dp->dev, inum);
    800040d4:	fc045583          	lhu	a1,-64(s0)
    800040d8:	00092503          	lw	a0,0(s2)
    800040dc:	fffff097          	auipc	ra,0xfffff
    800040e0:	752080e7          	jalr	1874(ra) # 8000382e <iget>
    800040e4:	a011                	j	800040e8 <dirlookup+0xa0>
  return 0;
    800040e6:	4501                	li	a0,0
}
    800040e8:	70e2                	ld	ra,56(sp)
    800040ea:	7442                	ld	s0,48(sp)
    800040ec:	74a2                	ld	s1,40(sp)
    800040ee:	7902                	ld	s2,32(sp)
    800040f0:	69e2                	ld	s3,24(sp)
    800040f2:	6a42                	ld	s4,16(sp)
    800040f4:	6121                	addi	sp,sp,64
    800040f6:	8082                	ret

00000000800040f8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800040f8:	711d                	addi	sp,sp,-96
    800040fa:	ec86                	sd	ra,88(sp)
    800040fc:	e8a2                	sd	s0,80(sp)
    800040fe:	e4a6                	sd	s1,72(sp)
    80004100:	e0ca                	sd	s2,64(sp)
    80004102:	fc4e                	sd	s3,56(sp)
    80004104:	f852                	sd	s4,48(sp)
    80004106:	f456                	sd	s5,40(sp)
    80004108:	f05a                	sd	s6,32(sp)
    8000410a:	ec5e                	sd	s7,24(sp)
    8000410c:	e862                	sd	s8,16(sp)
    8000410e:	e466                	sd	s9,8(sp)
    80004110:	1080                	addi	s0,sp,96
    80004112:	84aa                	mv	s1,a0
    80004114:	8bae                	mv	s7,a1
    80004116:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004118:	00054703          	lbu	a4,0(a0)
    8000411c:	02f00793          	li	a5,47
    80004120:	02f70363          	beq	a4,a5,80004146 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004124:	ffffe097          	auipc	ra,0xffffe
    80004128:	d06080e7          	jalr	-762(ra) # 80001e2a <myproc>
    8000412c:	15853503          	ld	a0,344(a0)
    80004130:	00000097          	auipc	ra,0x0
    80004134:	9f6080e7          	jalr	-1546(ra) # 80003b26 <idup>
    80004138:	89aa                	mv	s3,a0
  while(*path == '/')
    8000413a:	02f00913          	li	s2,47
  len = path - s;
    8000413e:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004140:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004142:	4c05                	li	s8,1
    80004144:	a865                	j	800041fc <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004146:	4585                	li	a1,1
    80004148:	4505                	li	a0,1
    8000414a:	fffff097          	auipc	ra,0xfffff
    8000414e:	6e4080e7          	jalr	1764(ra) # 8000382e <iget>
    80004152:	89aa                	mv	s3,a0
    80004154:	b7dd                	j	8000413a <namex+0x42>
      iunlockput(ip);
    80004156:	854e                	mv	a0,s3
    80004158:	00000097          	auipc	ra,0x0
    8000415c:	c70080e7          	jalr	-912(ra) # 80003dc8 <iunlockput>
      return 0;
    80004160:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004162:	854e                	mv	a0,s3
    80004164:	60e6                	ld	ra,88(sp)
    80004166:	6446                	ld	s0,80(sp)
    80004168:	64a6                	ld	s1,72(sp)
    8000416a:	6906                	ld	s2,64(sp)
    8000416c:	79e2                	ld	s3,56(sp)
    8000416e:	7a42                	ld	s4,48(sp)
    80004170:	7aa2                	ld	s5,40(sp)
    80004172:	7b02                	ld	s6,32(sp)
    80004174:	6be2                	ld	s7,24(sp)
    80004176:	6c42                	ld	s8,16(sp)
    80004178:	6ca2                	ld	s9,8(sp)
    8000417a:	6125                	addi	sp,sp,96
    8000417c:	8082                	ret
      iunlock(ip);
    8000417e:	854e                	mv	a0,s3
    80004180:	00000097          	auipc	ra,0x0
    80004184:	aa8080e7          	jalr	-1368(ra) # 80003c28 <iunlock>
      return ip;
    80004188:	bfe9                	j	80004162 <namex+0x6a>
      iunlockput(ip);
    8000418a:	854e                	mv	a0,s3
    8000418c:	00000097          	auipc	ra,0x0
    80004190:	c3c080e7          	jalr	-964(ra) # 80003dc8 <iunlockput>
      return 0;
    80004194:	89d2                	mv	s3,s4
    80004196:	b7f1                	j	80004162 <namex+0x6a>
  len = path - s;
    80004198:	40b48633          	sub	a2,s1,a1
    8000419c:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800041a0:	094cd663          	ble	s4,s9,8000422c <namex+0x134>
    memmove(name, s, DIRSIZ);
    800041a4:	4639                	li	a2,14
    800041a6:	8556                	mv	a0,s5
    800041a8:	ffffd097          	auipc	ra,0xffffd
    800041ac:	04a080e7          	jalr	74(ra) # 800011f2 <memmove>
  while(*path == '/')
    800041b0:	0004c783          	lbu	a5,0(s1)
    800041b4:	01279763          	bne	a5,s2,800041c2 <namex+0xca>
    path++;
    800041b8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041ba:	0004c783          	lbu	a5,0(s1)
    800041be:	ff278de3          	beq	a5,s2,800041b8 <namex+0xc0>
    ilock(ip);
    800041c2:	854e                	mv	a0,s3
    800041c4:	00000097          	auipc	ra,0x0
    800041c8:	9a0080e7          	jalr	-1632(ra) # 80003b64 <ilock>
    if(ip->type != T_DIR){
    800041cc:	04c99783          	lh	a5,76(s3)
    800041d0:	f98793e3          	bne	a5,s8,80004156 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800041d4:	000b8563          	beqz	s7,800041de <namex+0xe6>
    800041d8:	0004c783          	lbu	a5,0(s1)
    800041dc:	d3cd                	beqz	a5,8000417e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800041de:	865a                	mv	a2,s6
    800041e0:	85d6                	mv	a1,s5
    800041e2:	854e                	mv	a0,s3
    800041e4:	00000097          	auipc	ra,0x0
    800041e8:	e64080e7          	jalr	-412(ra) # 80004048 <dirlookup>
    800041ec:	8a2a                	mv	s4,a0
    800041ee:	dd51                	beqz	a0,8000418a <namex+0x92>
    iunlockput(ip);
    800041f0:	854e                	mv	a0,s3
    800041f2:	00000097          	auipc	ra,0x0
    800041f6:	bd6080e7          	jalr	-1066(ra) # 80003dc8 <iunlockput>
    ip = next;
    800041fa:	89d2                	mv	s3,s4
  while(*path == '/')
    800041fc:	0004c783          	lbu	a5,0(s1)
    80004200:	05279d63          	bne	a5,s2,8000425a <namex+0x162>
    path++;
    80004204:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004206:	0004c783          	lbu	a5,0(s1)
    8000420a:	ff278de3          	beq	a5,s2,80004204 <namex+0x10c>
  if(*path == 0)
    8000420e:	cf8d                	beqz	a5,80004248 <namex+0x150>
  while(*path != '/' && *path != 0)
    80004210:	01278b63          	beq	a5,s2,80004226 <namex+0x12e>
    80004214:	c795                	beqz	a5,80004240 <namex+0x148>
    path++;
    80004216:	85a6                	mv	a1,s1
    path++;
    80004218:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000421a:	0004c783          	lbu	a5,0(s1)
    8000421e:	f7278de3          	beq	a5,s2,80004198 <namex+0xa0>
    80004222:	fbfd                	bnez	a5,80004218 <namex+0x120>
    80004224:	bf95                	j	80004198 <namex+0xa0>
    80004226:	85a6                	mv	a1,s1
  len = path - s;
    80004228:	8a5a                	mv	s4,s6
    8000422a:	865a                	mv	a2,s6
    memmove(name, s, len);
    8000422c:	2601                	sext.w	a2,a2
    8000422e:	8556                	mv	a0,s5
    80004230:	ffffd097          	auipc	ra,0xffffd
    80004234:	fc2080e7          	jalr	-62(ra) # 800011f2 <memmove>
    name[len] = 0;
    80004238:	9a56                	add	s4,s4,s5
    8000423a:	000a0023          	sb	zero,0(s4)
    8000423e:	bf8d                	j	800041b0 <namex+0xb8>
  while(*path != '/' && *path != 0)
    80004240:	85a6                	mv	a1,s1
  len = path - s;
    80004242:	8a5a                	mv	s4,s6
    80004244:	865a                	mv	a2,s6
    80004246:	b7dd                	j	8000422c <namex+0x134>
  if(nameiparent){
    80004248:	f00b8de3          	beqz	s7,80004162 <namex+0x6a>
    iput(ip);
    8000424c:	854e                	mv	a0,s3
    8000424e:	00000097          	auipc	ra,0x0
    80004252:	ad2080e7          	jalr	-1326(ra) # 80003d20 <iput>
    return 0;
    80004256:	4981                	li	s3,0
    80004258:	b729                	j	80004162 <namex+0x6a>
  if(*path == 0)
    8000425a:	d7fd                	beqz	a5,80004248 <namex+0x150>
    8000425c:	85a6                	mv	a1,s1
    8000425e:	bf6d                	j	80004218 <namex+0x120>

0000000080004260 <dirlink>:
{
    80004260:	7139                	addi	sp,sp,-64
    80004262:	fc06                	sd	ra,56(sp)
    80004264:	f822                	sd	s0,48(sp)
    80004266:	f426                	sd	s1,40(sp)
    80004268:	f04a                	sd	s2,32(sp)
    8000426a:	ec4e                	sd	s3,24(sp)
    8000426c:	e852                	sd	s4,16(sp)
    8000426e:	0080                	addi	s0,sp,64
    80004270:	892a                	mv	s2,a0
    80004272:	8a2e                	mv	s4,a1
    80004274:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004276:	4601                	li	a2,0
    80004278:	00000097          	auipc	ra,0x0
    8000427c:	dd0080e7          	jalr	-560(ra) # 80004048 <dirlookup>
    80004280:	e93d                	bnez	a0,800042f6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004282:	05492483          	lw	s1,84(s2)
    80004286:	c49d                	beqz	s1,800042b4 <dirlink+0x54>
    80004288:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000428a:	4741                	li	a4,16
    8000428c:	86a6                	mv	a3,s1
    8000428e:	fc040613          	addi	a2,s0,-64
    80004292:	4581                	li	a1,0
    80004294:	854a                	mv	a0,s2
    80004296:	00000097          	auipc	ra,0x0
    8000429a:	b84080e7          	jalr	-1148(ra) # 80003e1a <readi>
    8000429e:	47c1                	li	a5,16
    800042a0:	06f51163          	bne	a0,a5,80004302 <dirlink+0xa2>
    if(de.inum == 0)
    800042a4:	fc045783          	lhu	a5,-64(s0)
    800042a8:	c791                	beqz	a5,800042b4 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042aa:	24c1                	addiw	s1,s1,16
    800042ac:	05492783          	lw	a5,84(s2)
    800042b0:	fcf4ede3          	bltu	s1,a5,8000428a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800042b4:	4639                	li	a2,14
    800042b6:	85d2                	mv	a1,s4
    800042b8:	fc240513          	addi	a0,s0,-62
    800042bc:	ffffd097          	auipc	ra,0xffffd
    800042c0:	002080e7          	jalr	2(ra) # 800012be <strncpy>
  de.inum = inum;
    800042c4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042c8:	4741                	li	a4,16
    800042ca:	86a6                	mv	a3,s1
    800042cc:	fc040613          	addi	a2,s0,-64
    800042d0:	4581                	li	a1,0
    800042d2:	854a                	mv	a0,s2
    800042d4:	00000097          	auipc	ra,0x0
    800042d8:	c3e080e7          	jalr	-962(ra) # 80003f12 <writei>
    800042dc:	4741                	li	a4,16
  return 0;
    800042de:	4781                	li	a5,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042e0:	02e51963          	bne	a0,a4,80004312 <dirlink+0xb2>
}
    800042e4:	853e                	mv	a0,a5
    800042e6:	70e2                	ld	ra,56(sp)
    800042e8:	7442                	ld	s0,48(sp)
    800042ea:	74a2                	ld	s1,40(sp)
    800042ec:	7902                	ld	s2,32(sp)
    800042ee:	69e2                	ld	s3,24(sp)
    800042f0:	6a42                	ld	s4,16(sp)
    800042f2:	6121                	addi	sp,sp,64
    800042f4:	8082                	ret
    iput(ip);
    800042f6:	00000097          	auipc	ra,0x0
    800042fa:	a2a080e7          	jalr	-1494(ra) # 80003d20 <iput>
    return -1;
    800042fe:	57fd                	li	a5,-1
    80004300:	b7d5                	j	800042e4 <dirlink+0x84>
      panic("dirlink read");
    80004302:	00004517          	auipc	a0,0x4
    80004306:	39650513          	addi	a0,a0,918 # 80008698 <syscalls+0x208>
    8000430a:	ffffc097          	auipc	ra,0xffffc
    8000430e:	26e080e7          	jalr	622(ra) # 80000578 <panic>
    panic("dirlink");
    80004312:	00004517          	auipc	a0,0x4
    80004316:	4a650513          	addi	a0,a0,1190 # 800087b8 <syscalls+0x328>
    8000431a:	ffffc097          	auipc	ra,0xffffc
    8000431e:	25e080e7          	jalr	606(ra) # 80000578 <panic>

0000000080004322 <namei>:

struct inode*
namei(char *path)
{
    80004322:	1101                	addi	sp,sp,-32
    80004324:	ec06                	sd	ra,24(sp)
    80004326:	e822                	sd	s0,16(sp)
    80004328:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000432a:	fe040613          	addi	a2,s0,-32
    8000432e:	4581                	li	a1,0
    80004330:	00000097          	auipc	ra,0x0
    80004334:	dc8080e7          	jalr	-568(ra) # 800040f8 <namex>
}
    80004338:	60e2                	ld	ra,24(sp)
    8000433a:	6442                	ld	s0,16(sp)
    8000433c:	6105                	addi	sp,sp,32
    8000433e:	8082                	ret

0000000080004340 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004340:	1141                	addi	sp,sp,-16
    80004342:	e406                	sd	ra,8(sp)
    80004344:	e022                	sd	s0,0(sp)
    80004346:	0800                	addi	s0,sp,16
  return namex(path, 1, name);
    80004348:	862e                	mv	a2,a1
    8000434a:	4585                	li	a1,1
    8000434c:	00000097          	auipc	ra,0x0
    80004350:	dac080e7          	jalr	-596(ra) # 800040f8 <namex>
}
    80004354:	60a2                	ld	ra,8(sp)
    80004356:	6402                	ld	s0,0(sp)
    80004358:	0141                	addi	sp,sp,16
    8000435a:	8082                	ret

000000008000435c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000435c:	1101                	addi	sp,sp,-32
    8000435e:	ec06                	sd	ra,24(sp)
    80004360:	e822                	sd	s0,16(sp)
    80004362:	e426                	sd	s1,8(sp)
    80004364:	e04a                	sd	s2,0(sp)
    80004366:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004368:	00028917          	auipc	s2,0x28
    8000436c:	cc890913          	addi	s2,s2,-824 # 8002c030 <log>
    80004370:	02092583          	lw	a1,32(s2)
    80004374:	03092503          	lw	a0,48(s2)
    80004378:	fffff097          	auipc	ra,0xfffff
    8000437c:	f0e080e7          	jalr	-242(ra) # 80003286 <bread>
    80004380:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004382:	03492683          	lw	a3,52(s2)
    80004386:	d134                	sw	a3,96(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004388:	02d05763          	blez	a3,800043b6 <write_head+0x5a>
    8000438c:	00028797          	auipc	a5,0x28
    80004390:	cdc78793          	addi	a5,a5,-804 # 8002c068 <log+0x38>
    80004394:	06450713          	addi	a4,a0,100
    80004398:	36fd                	addiw	a3,a3,-1
    8000439a:	1682                	slli	a3,a3,0x20
    8000439c:	9281                	srli	a3,a3,0x20
    8000439e:	068a                	slli	a3,a3,0x2
    800043a0:	00028617          	auipc	a2,0x28
    800043a4:	ccc60613          	addi	a2,a2,-820 # 8002c06c <log+0x3c>
    800043a8:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800043aa:	4390                	lw	a2,0(a5)
    800043ac:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800043ae:	0791                	addi	a5,a5,4
    800043b0:	0711                	addi	a4,a4,4
    800043b2:	fed79ce3          	bne	a5,a3,800043aa <write_head+0x4e>
  }
  bwrite(buf);
    800043b6:	8526                	mv	a0,s1
    800043b8:	fffff097          	auipc	ra,0xfffff
    800043bc:	052080e7          	jalr	82(ra) # 8000340a <bwrite>
  brelse(buf);
    800043c0:	8526                	mv	a0,s1
    800043c2:	fffff097          	auipc	ra,0xfffff
    800043c6:	086080e7          	jalr	134(ra) # 80003448 <brelse>
}
    800043ca:	60e2                	ld	ra,24(sp)
    800043cc:	6442                	ld	s0,16(sp)
    800043ce:	64a2                	ld	s1,8(sp)
    800043d0:	6902                	ld	s2,0(sp)
    800043d2:	6105                	addi	sp,sp,32
    800043d4:	8082                	ret

00000000800043d6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800043d6:	00028797          	auipc	a5,0x28
    800043da:	c5a78793          	addi	a5,a5,-934 # 8002c030 <log>
    800043de:	5bdc                	lw	a5,52(a5)
    800043e0:	0af05d63          	blez	a5,8000449a <install_trans+0xc4>
{
    800043e4:	7139                	addi	sp,sp,-64
    800043e6:	fc06                	sd	ra,56(sp)
    800043e8:	f822                	sd	s0,48(sp)
    800043ea:	f426                	sd	s1,40(sp)
    800043ec:	f04a                	sd	s2,32(sp)
    800043ee:	ec4e                	sd	s3,24(sp)
    800043f0:	e852                	sd	s4,16(sp)
    800043f2:	e456                	sd	s5,8(sp)
    800043f4:	e05a                	sd	s6,0(sp)
    800043f6:	0080                	addi	s0,sp,64
    800043f8:	8b2a                	mv	s6,a0
    800043fa:	00028a17          	auipc	s4,0x28
    800043fe:	c6ea0a13          	addi	s4,s4,-914 # 8002c068 <log+0x38>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004402:	4981                	li	s3,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004404:	00028917          	auipc	s2,0x28
    80004408:	c2c90913          	addi	s2,s2,-980 # 8002c030 <log>
    8000440c:	a035                	j	80004438 <install_trans+0x62>
      bunpin(dbuf);
    8000440e:	8526                	mv	a0,s1
    80004410:	fffff097          	auipc	ra,0xfffff
    80004414:	110080e7          	jalr	272(ra) # 80003520 <bunpin>
    brelse(lbuf);
    80004418:	8556                	mv	a0,s5
    8000441a:	fffff097          	auipc	ra,0xfffff
    8000441e:	02e080e7          	jalr	46(ra) # 80003448 <brelse>
    brelse(dbuf);
    80004422:	8526                	mv	a0,s1
    80004424:	fffff097          	auipc	ra,0xfffff
    80004428:	024080e7          	jalr	36(ra) # 80003448 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000442c:	2985                	addiw	s3,s3,1
    8000442e:	0a11                	addi	s4,s4,4
    80004430:	03492783          	lw	a5,52(s2)
    80004434:	04f9d963          	ble	a5,s3,80004486 <install_trans+0xb0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004438:	02092583          	lw	a1,32(s2)
    8000443c:	013585bb          	addw	a1,a1,s3
    80004440:	2585                	addiw	a1,a1,1
    80004442:	03092503          	lw	a0,48(s2)
    80004446:	fffff097          	auipc	ra,0xfffff
    8000444a:	e40080e7          	jalr	-448(ra) # 80003286 <bread>
    8000444e:	8aaa                	mv	s5,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004450:	000a2583          	lw	a1,0(s4)
    80004454:	03092503          	lw	a0,48(s2)
    80004458:	fffff097          	auipc	ra,0xfffff
    8000445c:	e2e080e7          	jalr	-466(ra) # 80003286 <bread>
    80004460:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004462:	40000613          	li	a2,1024
    80004466:	060a8593          	addi	a1,s5,96
    8000446a:	06050513          	addi	a0,a0,96
    8000446e:	ffffd097          	auipc	ra,0xffffd
    80004472:	d84080e7          	jalr	-636(ra) # 800011f2 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004476:	8526                	mv	a0,s1
    80004478:	fffff097          	auipc	ra,0xfffff
    8000447c:	f92080e7          	jalr	-110(ra) # 8000340a <bwrite>
    if(recovering == 0)
    80004480:	f80b1ce3          	bnez	s6,80004418 <install_trans+0x42>
    80004484:	b769                	j	8000440e <install_trans+0x38>
}
    80004486:	70e2                	ld	ra,56(sp)
    80004488:	7442                	ld	s0,48(sp)
    8000448a:	74a2                	ld	s1,40(sp)
    8000448c:	7902                	ld	s2,32(sp)
    8000448e:	69e2                	ld	s3,24(sp)
    80004490:	6a42                	ld	s4,16(sp)
    80004492:	6aa2                	ld	s5,8(sp)
    80004494:	6b02                	ld	s6,0(sp)
    80004496:	6121                	addi	sp,sp,64
    80004498:	8082                	ret
    8000449a:	8082                	ret

000000008000449c <initlog>:
{
    8000449c:	7179                	addi	sp,sp,-48
    8000449e:	f406                	sd	ra,40(sp)
    800044a0:	f022                	sd	s0,32(sp)
    800044a2:	ec26                	sd	s1,24(sp)
    800044a4:	e84a                	sd	s2,16(sp)
    800044a6:	e44e                	sd	s3,8(sp)
    800044a8:	1800                	addi	s0,sp,48
    800044aa:	892a                	mv	s2,a0
    800044ac:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800044ae:	00028497          	auipc	s1,0x28
    800044b2:	b8248493          	addi	s1,s1,-1150 # 8002c030 <log>
    800044b6:	00004597          	auipc	a1,0x4
    800044ba:	1f258593          	addi	a1,a1,498 # 800086a8 <syscalls+0x218>
    800044be:	8526                	mv	a0,s1
    800044c0:	ffffd097          	auipc	ra,0xffffd
    800044c4:	a46080e7          	jalr	-1466(ra) # 80000f06 <initlock>
  log.start = sb->logstart;
    800044c8:	0149a583          	lw	a1,20(s3)
    800044cc:	d08c                	sw	a1,32(s1)
  log.size = sb->nlog;
    800044ce:	0109a783          	lw	a5,16(s3)
    800044d2:	d0dc                	sw	a5,36(s1)
  log.dev = dev;
    800044d4:	0324a823          	sw	s2,48(s1)
  struct buf *buf = bread(log.dev, log.start);
    800044d8:	854a                	mv	a0,s2
    800044da:	fffff097          	auipc	ra,0xfffff
    800044de:	dac080e7          	jalr	-596(ra) # 80003286 <bread>
  log.lh.n = lh->n;
    800044e2:	513c                	lw	a5,96(a0)
    800044e4:	d8dc                	sw	a5,52(s1)
  for (i = 0; i < log.lh.n; i++) {
    800044e6:	02f05563          	blez	a5,80004510 <initlog+0x74>
    800044ea:	06450713          	addi	a4,a0,100
    800044ee:	00028697          	auipc	a3,0x28
    800044f2:	b7a68693          	addi	a3,a3,-1158 # 8002c068 <log+0x38>
    800044f6:	37fd                	addiw	a5,a5,-1
    800044f8:	1782                	slli	a5,a5,0x20
    800044fa:	9381                	srli	a5,a5,0x20
    800044fc:	078a                	slli	a5,a5,0x2
    800044fe:	06850613          	addi	a2,a0,104
    80004502:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004504:	4310                	lw	a2,0(a4)
    80004506:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004508:	0711                	addi	a4,a4,4
    8000450a:	0691                	addi	a3,a3,4
    8000450c:	fef71ce3          	bne	a4,a5,80004504 <initlog+0x68>
  brelse(buf);
    80004510:	fffff097          	auipc	ra,0xfffff
    80004514:	f38080e7          	jalr	-200(ra) # 80003448 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004518:	4505                	li	a0,1
    8000451a:	00000097          	auipc	ra,0x0
    8000451e:	ebc080e7          	jalr	-324(ra) # 800043d6 <install_trans>
  log.lh.n = 0;
    80004522:	00028797          	auipc	a5,0x28
    80004526:	b407a123          	sw	zero,-1214(a5) # 8002c064 <log+0x34>
  write_head(); // clear the log
    8000452a:	00000097          	auipc	ra,0x0
    8000452e:	e32080e7          	jalr	-462(ra) # 8000435c <write_head>
}
    80004532:	70a2                	ld	ra,40(sp)
    80004534:	7402                	ld	s0,32(sp)
    80004536:	64e2                	ld	s1,24(sp)
    80004538:	6942                	ld	s2,16(sp)
    8000453a:	69a2                	ld	s3,8(sp)
    8000453c:	6145                	addi	sp,sp,48
    8000453e:	8082                	ret

0000000080004540 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004540:	1101                	addi	sp,sp,-32
    80004542:	ec06                	sd	ra,24(sp)
    80004544:	e822                	sd	s0,16(sp)
    80004546:	e426                	sd	s1,8(sp)
    80004548:	e04a                	sd	s2,0(sp)
    8000454a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000454c:	00028517          	auipc	a0,0x28
    80004550:	ae450513          	addi	a0,a0,-1308 # 8002c030 <log>
    80004554:	ffffd097          	auipc	ra,0xffffd
    80004558:	826080e7          	jalr	-2010(ra) # 80000d7a <acquire>
  while(1){
    if(log.committing){
    8000455c:	00028497          	auipc	s1,0x28
    80004560:	ad448493          	addi	s1,s1,-1324 # 8002c030 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004564:	4979                	li	s2,30
    80004566:	a039                	j	80004574 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004568:	85a6                	mv	a1,s1
    8000456a:	8526                	mv	a0,s1
    8000456c:	ffffe097          	auipc	ra,0xffffe
    80004570:	0d8080e7          	jalr	216(ra) # 80002644 <sleep>
    if(log.committing){
    80004574:	54dc                	lw	a5,44(s1)
    80004576:	fbed                	bnez	a5,80004568 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004578:	549c                	lw	a5,40(s1)
    8000457a:	0017871b          	addiw	a4,a5,1
    8000457e:	0007069b          	sext.w	a3,a4
    80004582:	0027179b          	slliw	a5,a4,0x2
    80004586:	9fb9                	addw	a5,a5,a4
    80004588:	0017979b          	slliw	a5,a5,0x1
    8000458c:	58d8                	lw	a4,52(s1)
    8000458e:	9fb9                	addw	a5,a5,a4
    80004590:	00f95963          	ble	a5,s2,800045a2 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004594:	85a6                	mv	a1,s1
    80004596:	8526                	mv	a0,s1
    80004598:	ffffe097          	auipc	ra,0xffffe
    8000459c:	0ac080e7          	jalr	172(ra) # 80002644 <sleep>
    800045a0:	bfd1                	j	80004574 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800045a2:	00028517          	auipc	a0,0x28
    800045a6:	a8e50513          	addi	a0,a0,-1394 # 8002c030 <log>
    800045aa:	d514                	sw	a3,40(a0)
      release(&log.lock);
    800045ac:	ffffd097          	auipc	ra,0xffffd
    800045b0:	89e080e7          	jalr	-1890(ra) # 80000e4a <release>
      break;
    }
  }
}
    800045b4:	60e2                	ld	ra,24(sp)
    800045b6:	6442                	ld	s0,16(sp)
    800045b8:	64a2                	ld	s1,8(sp)
    800045ba:	6902                	ld	s2,0(sp)
    800045bc:	6105                	addi	sp,sp,32
    800045be:	8082                	ret

00000000800045c0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800045c0:	7139                	addi	sp,sp,-64
    800045c2:	fc06                	sd	ra,56(sp)
    800045c4:	f822                	sd	s0,48(sp)
    800045c6:	f426                	sd	s1,40(sp)
    800045c8:	f04a                	sd	s2,32(sp)
    800045ca:	ec4e                	sd	s3,24(sp)
    800045cc:	e852                	sd	s4,16(sp)
    800045ce:	e456                	sd	s5,8(sp)
    800045d0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800045d2:	00028917          	auipc	s2,0x28
    800045d6:	a5e90913          	addi	s2,s2,-1442 # 8002c030 <log>
    800045da:	854a                	mv	a0,s2
    800045dc:	ffffc097          	auipc	ra,0xffffc
    800045e0:	79e080e7          	jalr	1950(ra) # 80000d7a <acquire>
  log.outstanding -= 1;
    800045e4:	02892783          	lw	a5,40(s2)
    800045e8:	37fd                	addiw	a5,a5,-1
    800045ea:	0007849b          	sext.w	s1,a5
    800045ee:	02f92423          	sw	a5,40(s2)
  if(log.committing)
    800045f2:	02c92783          	lw	a5,44(s2)
    800045f6:	eba1                	bnez	a5,80004646 <end_op+0x86>
    panic("log.committing");
  if(log.outstanding == 0){
    800045f8:	ecb9                	bnez	s1,80004656 <end_op+0x96>
    do_commit = 1;
    log.committing = 1;
    800045fa:	00028917          	auipc	s2,0x28
    800045fe:	a3690913          	addi	s2,s2,-1482 # 8002c030 <log>
    80004602:	4785                	li	a5,1
    80004604:	02f92623          	sw	a5,44(s2)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004608:	854a                	mv	a0,s2
    8000460a:	ffffd097          	auipc	ra,0xffffd
    8000460e:	840080e7          	jalr	-1984(ra) # 80000e4a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004612:	03492783          	lw	a5,52(s2)
    80004616:	06f04763          	bgtz	a5,80004684 <end_op+0xc4>
    acquire(&log.lock);
    8000461a:	00028497          	auipc	s1,0x28
    8000461e:	a1648493          	addi	s1,s1,-1514 # 8002c030 <log>
    80004622:	8526                	mv	a0,s1
    80004624:	ffffc097          	auipc	ra,0xffffc
    80004628:	756080e7          	jalr	1878(ra) # 80000d7a <acquire>
    log.committing = 0;
    8000462c:	0204a623          	sw	zero,44(s1)
    wakeup(&log);
    80004630:	8526                	mv	a0,s1
    80004632:	ffffe097          	auipc	ra,0xffffe
    80004636:	198080e7          	jalr	408(ra) # 800027ca <wakeup>
    release(&log.lock);
    8000463a:	8526                	mv	a0,s1
    8000463c:	ffffd097          	auipc	ra,0xffffd
    80004640:	80e080e7          	jalr	-2034(ra) # 80000e4a <release>
}
    80004644:	a03d                	j	80004672 <end_op+0xb2>
    panic("log.committing");
    80004646:	00004517          	auipc	a0,0x4
    8000464a:	06a50513          	addi	a0,a0,106 # 800086b0 <syscalls+0x220>
    8000464e:	ffffc097          	auipc	ra,0xffffc
    80004652:	f2a080e7          	jalr	-214(ra) # 80000578 <panic>
    wakeup(&log);
    80004656:	00028497          	auipc	s1,0x28
    8000465a:	9da48493          	addi	s1,s1,-1574 # 8002c030 <log>
    8000465e:	8526                	mv	a0,s1
    80004660:	ffffe097          	auipc	ra,0xffffe
    80004664:	16a080e7          	jalr	362(ra) # 800027ca <wakeup>
  release(&log.lock);
    80004668:	8526                	mv	a0,s1
    8000466a:	ffffc097          	auipc	ra,0xffffc
    8000466e:	7e0080e7          	jalr	2016(ra) # 80000e4a <release>
}
    80004672:	70e2                	ld	ra,56(sp)
    80004674:	7442                	ld	s0,48(sp)
    80004676:	74a2                	ld	s1,40(sp)
    80004678:	7902                	ld	s2,32(sp)
    8000467a:	69e2                	ld	s3,24(sp)
    8000467c:	6a42                	ld	s4,16(sp)
    8000467e:	6aa2                	ld	s5,8(sp)
    80004680:	6121                	addi	sp,sp,64
    80004682:	8082                	ret
    80004684:	00028a17          	auipc	s4,0x28
    80004688:	9e4a0a13          	addi	s4,s4,-1564 # 8002c068 <log+0x38>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000468c:	00028917          	auipc	s2,0x28
    80004690:	9a490913          	addi	s2,s2,-1628 # 8002c030 <log>
    80004694:	02092583          	lw	a1,32(s2)
    80004698:	9da5                	addw	a1,a1,s1
    8000469a:	2585                	addiw	a1,a1,1
    8000469c:	03092503          	lw	a0,48(s2)
    800046a0:	fffff097          	auipc	ra,0xfffff
    800046a4:	be6080e7          	jalr	-1050(ra) # 80003286 <bread>
    800046a8:	89aa                	mv	s3,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800046aa:	000a2583          	lw	a1,0(s4)
    800046ae:	03092503          	lw	a0,48(s2)
    800046b2:	fffff097          	auipc	ra,0xfffff
    800046b6:	bd4080e7          	jalr	-1068(ra) # 80003286 <bread>
    800046ba:	8aaa                	mv	s5,a0
    memmove(to->data, from->data, BSIZE);
    800046bc:	40000613          	li	a2,1024
    800046c0:	06050593          	addi	a1,a0,96
    800046c4:	06098513          	addi	a0,s3,96
    800046c8:	ffffd097          	auipc	ra,0xffffd
    800046cc:	b2a080e7          	jalr	-1238(ra) # 800011f2 <memmove>
    bwrite(to);  // write the log
    800046d0:	854e                	mv	a0,s3
    800046d2:	fffff097          	auipc	ra,0xfffff
    800046d6:	d38080e7          	jalr	-712(ra) # 8000340a <bwrite>
    brelse(from);
    800046da:	8556                	mv	a0,s5
    800046dc:	fffff097          	auipc	ra,0xfffff
    800046e0:	d6c080e7          	jalr	-660(ra) # 80003448 <brelse>
    brelse(to);
    800046e4:	854e                	mv	a0,s3
    800046e6:	fffff097          	auipc	ra,0xfffff
    800046ea:	d62080e7          	jalr	-670(ra) # 80003448 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046ee:	2485                	addiw	s1,s1,1
    800046f0:	0a11                	addi	s4,s4,4
    800046f2:	03492783          	lw	a5,52(s2)
    800046f6:	f8f4cfe3          	blt	s1,a5,80004694 <end_op+0xd4>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800046fa:	00000097          	auipc	ra,0x0
    800046fe:	c62080e7          	jalr	-926(ra) # 8000435c <write_head>
    install_trans(0); // Now install writes to home locations
    80004702:	4501                	li	a0,0
    80004704:	00000097          	auipc	ra,0x0
    80004708:	cd2080e7          	jalr	-814(ra) # 800043d6 <install_trans>
    log.lh.n = 0;
    8000470c:	00028797          	auipc	a5,0x28
    80004710:	9407ac23          	sw	zero,-1704(a5) # 8002c064 <log+0x34>
    write_head();    // Erase the transaction from the log
    80004714:	00000097          	auipc	ra,0x0
    80004718:	c48080e7          	jalr	-952(ra) # 8000435c <write_head>
    8000471c:	bdfd                	j	8000461a <end_op+0x5a>

000000008000471e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000471e:	1101                	addi	sp,sp,-32
    80004720:	ec06                	sd	ra,24(sp)
    80004722:	e822                	sd	s0,16(sp)
    80004724:	e426                	sd	s1,8(sp)
    80004726:	e04a                	sd	s2,0(sp)
    80004728:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000472a:	00028797          	auipc	a5,0x28
    8000472e:	90678793          	addi	a5,a5,-1786 # 8002c030 <log>
    80004732:	5bd8                	lw	a4,52(a5)
    80004734:	47f5                	li	a5,29
    80004736:	08e7c563          	blt	a5,a4,800047c0 <log_write+0xa2>
    8000473a:	892a                	mv	s2,a0
    8000473c:	00028797          	auipc	a5,0x28
    80004740:	8f478793          	addi	a5,a5,-1804 # 8002c030 <log>
    80004744:	53dc                	lw	a5,36(a5)
    80004746:	37fd                	addiw	a5,a5,-1
    80004748:	06f75c63          	ble	a5,a4,800047c0 <log_write+0xa2>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000474c:	00028797          	auipc	a5,0x28
    80004750:	8e478793          	addi	a5,a5,-1820 # 8002c030 <log>
    80004754:	579c                	lw	a5,40(a5)
    80004756:	06f05d63          	blez	a5,800047d0 <log_write+0xb2>
    panic("log_write outside of trans");

  acquire(&log.lock);
    8000475a:	00028497          	auipc	s1,0x28
    8000475e:	8d648493          	addi	s1,s1,-1834 # 8002c030 <log>
    80004762:	8526                	mv	a0,s1
    80004764:	ffffc097          	auipc	ra,0xffffc
    80004768:	616080e7          	jalr	1558(ra) # 80000d7a <acquire>
  for (i = 0; i < log.lh.n; i++) {
    8000476c:	58d0                	lw	a2,52(s1)
    8000476e:	0ac05063          	blez	a2,8000480e <log_write+0xf0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004772:	00c92583          	lw	a1,12(s2)
    80004776:	5c9c                	lw	a5,56(s1)
    80004778:	0ab78363          	beq	a5,a1,8000481e <log_write+0x100>
    8000477c:	00028717          	auipc	a4,0x28
    80004780:	8f070713          	addi	a4,a4,-1808 # 8002c06c <log+0x3c>
  for (i = 0; i < log.lh.n; i++) {
    80004784:	4781                	li	a5,0
    80004786:	2785                	addiw	a5,a5,1
    80004788:	04c78c63          	beq	a5,a2,800047e0 <log_write+0xc2>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000478c:	4314                	lw	a3,0(a4)
    8000478e:	0711                	addi	a4,a4,4
    80004790:	feb69be3          	bne	a3,a1,80004786 <log_write+0x68>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004794:	07b1                	addi	a5,a5,12
    80004796:	078a                	slli	a5,a5,0x2
    80004798:	00028717          	auipc	a4,0x28
    8000479c:	89870713          	addi	a4,a4,-1896 # 8002c030 <log>
    800047a0:	97ba                	add	a5,a5,a4
    800047a2:	c78c                	sw	a1,8(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    log.lh.n++;
  }
  release(&log.lock);
    800047a4:	00028517          	auipc	a0,0x28
    800047a8:	88c50513          	addi	a0,a0,-1908 # 8002c030 <log>
    800047ac:	ffffc097          	auipc	ra,0xffffc
    800047b0:	69e080e7          	jalr	1694(ra) # 80000e4a <release>
}
    800047b4:	60e2                	ld	ra,24(sp)
    800047b6:	6442                	ld	s0,16(sp)
    800047b8:	64a2                	ld	s1,8(sp)
    800047ba:	6902                	ld	s2,0(sp)
    800047bc:	6105                	addi	sp,sp,32
    800047be:	8082                	ret
    panic("too big a transaction");
    800047c0:	00004517          	auipc	a0,0x4
    800047c4:	f0050513          	addi	a0,a0,-256 # 800086c0 <syscalls+0x230>
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	db0080e7          	jalr	-592(ra) # 80000578 <panic>
    panic("log_write outside of trans");
    800047d0:	00004517          	auipc	a0,0x4
    800047d4:	f0850513          	addi	a0,a0,-248 # 800086d8 <syscalls+0x248>
    800047d8:	ffffc097          	auipc	ra,0xffffc
    800047dc:	da0080e7          	jalr	-608(ra) # 80000578 <panic>
  log.lh.block[i] = b->blockno;
    800047e0:	0631                	addi	a2,a2,12
    800047e2:	060a                	slli	a2,a2,0x2
    800047e4:	00028797          	auipc	a5,0x28
    800047e8:	84c78793          	addi	a5,a5,-1972 # 8002c030 <log>
    800047ec:	963e                	add	a2,a2,a5
    800047ee:	00c92783          	lw	a5,12(s2)
    800047f2:	c61c                	sw	a5,8(a2)
    bpin(b);
    800047f4:	854a                	mv	a0,s2
    800047f6:	fffff097          	auipc	ra,0xfffff
    800047fa:	cd6080e7          	jalr	-810(ra) # 800034cc <bpin>
    log.lh.n++;
    800047fe:	00028717          	auipc	a4,0x28
    80004802:	83270713          	addi	a4,a4,-1998 # 8002c030 <log>
    80004806:	5b5c                	lw	a5,52(a4)
    80004808:	2785                	addiw	a5,a5,1
    8000480a:	db5c                	sw	a5,52(a4)
    8000480c:	bf61                	j	800047a4 <log_write+0x86>
  log.lh.block[i] = b->blockno;
    8000480e:	00c92783          	lw	a5,12(s2)
    80004812:	00028717          	auipc	a4,0x28
    80004816:	84f72b23          	sw	a5,-1962(a4) # 8002c068 <log+0x38>
  if (i == log.lh.n) {  // Add new block to log?
    8000481a:	f649                	bnez	a2,800047a4 <log_write+0x86>
    8000481c:	bfe1                	j	800047f4 <log_write+0xd6>
  for (i = 0; i < log.lh.n; i++) {
    8000481e:	4781                	li	a5,0
    80004820:	bf95                	j	80004794 <log_write+0x76>

0000000080004822 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004822:	1101                	addi	sp,sp,-32
    80004824:	ec06                	sd	ra,24(sp)
    80004826:	e822                	sd	s0,16(sp)
    80004828:	e426                	sd	s1,8(sp)
    8000482a:	e04a                	sd	s2,0(sp)
    8000482c:	1000                	addi	s0,sp,32
    8000482e:	84aa                	mv	s1,a0
    80004830:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004832:	00004597          	auipc	a1,0x4
    80004836:	ec658593          	addi	a1,a1,-314 # 800086f8 <syscalls+0x268>
    8000483a:	0521                	addi	a0,a0,8
    8000483c:	ffffc097          	auipc	ra,0xffffc
    80004840:	6ca080e7          	jalr	1738(ra) # 80000f06 <initlock>
  lk->name = name;
    80004844:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    80004848:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000484c:	0204a823          	sw	zero,48(s1)
}
    80004850:	60e2                	ld	ra,24(sp)
    80004852:	6442                	ld	s0,16(sp)
    80004854:	64a2                	ld	s1,8(sp)
    80004856:	6902                	ld	s2,0(sp)
    80004858:	6105                	addi	sp,sp,32
    8000485a:	8082                	ret

000000008000485c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000485c:	1101                	addi	sp,sp,-32
    8000485e:	ec06                	sd	ra,24(sp)
    80004860:	e822                	sd	s0,16(sp)
    80004862:	e426                	sd	s1,8(sp)
    80004864:	e04a                	sd	s2,0(sp)
    80004866:	1000                	addi	s0,sp,32
    80004868:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000486a:	00850913          	addi	s2,a0,8
    8000486e:	854a                	mv	a0,s2
    80004870:	ffffc097          	auipc	ra,0xffffc
    80004874:	50a080e7          	jalr	1290(ra) # 80000d7a <acquire>
  while (lk->locked) {
    80004878:	409c                	lw	a5,0(s1)
    8000487a:	cb89                	beqz	a5,8000488c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000487c:	85ca                	mv	a1,s2
    8000487e:	8526                	mv	a0,s1
    80004880:	ffffe097          	auipc	ra,0xffffe
    80004884:	dc4080e7          	jalr	-572(ra) # 80002644 <sleep>
  while (lk->locked) {
    80004888:	409c                	lw	a5,0(s1)
    8000488a:	fbed                	bnez	a5,8000487c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000488c:	4785                	li	a5,1
    8000488e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004890:	ffffd097          	auipc	ra,0xffffd
    80004894:	59a080e7          	jalr	1434(ra) # 80001e2a <myproc>
    80004898:	413c                	lw	a5,64(a0)
    8000489a:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    8000489c:	854a                	mv	a0,s2
    8000489e:	ffffc097          	auipc	ra,0xffffc
    800048a2:	5ac080e7          	jalr	1452(ra) # 80000e4a <release>
}
    800048a6:	60e2                	ld	ra,24(sp)
    800048a8:	6442                	ld	s0,16(sp)
    800048aa:	64a2                	ld	s1,8(sp)
    800048ac:	6902                	ld	s2,0(sp)
    800048ae:	6105                	addi	sp,sp,32
    800048b0:	8082                	ret

00000000800048b2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800048b2:	1101                	addi	sp,sp,-32
    800048b4:	ec06                	sd	ra,24(sp)
    800048b6:	e822                	sd	s0,16(sp)
    800048b8:	e426                	sd	s1,8(sp)
    800048ba:	e04a                	sd	s2,0(sp)
    800048bc:	1000                	addi	s0,sp,32
    800048be:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048c0:	00850913          	addi	s2,a0,8
    800048c4:	854a                	mv	a0,s2
    800048c6:	ffffc097          	auipc	ra,0xffffc
    800048ca:	4b4080e7          	jalr	1204(ra) # 80000d7a <acquire>
  lk->locked = 0;
    800048ce:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048d2:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    800048d6:	8526                	mv	a0,s1
    800048d8:	ffffe097          	auipc	ra,0xffffe
    800048dc:	ef2080e7          	jalr	-270(ra) # 800027ca <wakeup>
  release(&lk->lk);
    800048e0:	854a                	mv	a0,s2
    800048e2:	ffffc097          	auipc	ra,0xffffc
    800048e6:	568080e7          	jalr	1384(ra) # 80000e4a <release>
}
    800048ea:	60e2                	ld	ra,24(sp)
    800048ec:	6442                	ld	s0,16(sp)
    800048ee:	64a2                	ld	s1,8(sp)
    800048f0:	6902                	ld	s2,0(sp)
    800048f2:	6105                	addi	sp,sp,32
    800048f4:	8082                	ret

00000000800048f6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800048f6:	7179                	addi	sp,sp,-48
    800048f8:	f406                	sd	ra,40(sp)
    800048fa:	f022                	sd	s0,32(sp)
    800048fc:	ec26                	sd	s1,24(sp)
    800048fe:	e84a                	sd	s2,16(sp)
    80004900:	e44e                	sd	s3,8(sp)
    80004902:	1800                	addi	s0,sp,48
    80004904:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004906:	00850913          	addi	s2,a0,8
    8000490a:	854a                	mv	a0,s2
    8000490c:	ffffc097          	auipc	ra,0xffffc
    80004910:	46e080e7          	jalr	1134(ra) # 80000d7a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004914:	409c                	lw	a5,0(s1)
    80004916:	ef99                	bnez	a5,80004934 <holdingsleep+0x3e>
    80004918:	4481                	li	s1,0
  release(&lk->lk);
    8000491a:	854a                	mv	a0,s2
    8000491c:	ffffc097          	auipc	ra,0xffffc
    80004920:	52e080e7          	jalr	1326(ra) # 80000e4a <release>
  return r;
}
    80004924:	8526                	mv	a0,s1
    80004926:	70a2                	ld	ra,40(sp)
    80004928:	7402                	ld	s0,32(sp)
    8000492a:	64e2                	ld	s1,24(sp)
    8000492c:	6942                	ld	s2,16(sp)
    8000492e:	69a2                	ld	s3,8(sp)
    80004930:	6145                	addi	sp,sp,48
    80004932:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004934:	0304a983          	lw	s3,48(s1)
    80004938:	ffffd097          	auipc	ra,0xffffd
    8000493c:	4f2080e7          	jalr	1266(ra) # 80001e2a <myproc>
    80004940:	4124                	lw	s1,64(a0)
    80004942:	413484b3          	sub	s1,s1,s3
    80004946:	0014b493          	seqz	s1,s1
    8000494a:	bfc1                	j	8000491a <holdingsleep+0x24>

000000008000494c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000494c:	1141                	addi	sp,sp,-16
    8000494e:	e406                	sd	ra,8(sp)
    80004950:	e022                	sd	s0,0(sp)
    80004952:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004954:	00004597          	auipc	a1,0x4
    80004958:	db458593          	addi	a1,a1,-588 # 80008708 <syscalls+0x278>
    8000495c:	00028517          	auipc	a0,0x28
    80004960:	82450513          	addi	a0,a0,-2012 # 8002c180 <ftable>
    80004964:	ffffc097          	auipc	ra,0xffffc
    80004968:	5a2080e7          	jalr	1442(ra) # 80000f06 <initlock>
}
    8000496c:	60a2                	ld	ra,8(sp)
    8000496e:	6402                	ld	s0,0(sp)
    80004970:	0141                	addi	sp,sp,16
    80004972:	8082                	ret

0000000080004974 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004974:	1101                	addi	sp,sp,-32
    80004976:	ec06                	sd	ra,24(sp)
    80004978:	e822                	sd	s0,16(sp)
    8000497a:	e426                	sd	s1,8(sp)
    8000497c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000497e:	00028517          	auipc	a0,0x28
    80004982:	80250513          	addi	a0,a0,-2046 # 8002c180 <ftable>
    80004986:	ffffc097          	auipc	ra,0xffffc
    8000498a:	3f4080e7          	jalr	1012(ra) # 80000d7a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
    8000498e:	00027797          	auipc	a5,0x27
    80004992:	7f278793          	addi	a5,a5,2034 # 8002c180 <ftable>
    80004996:	53dc                	lw	a5,36(a5)
    80004998:	cb8d                	beqz	a5,800049ca <filealloc+0x56>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000499a:	00028497          	auipc	s1,0x28
    8000499e:	82e48493          	addi	s1,s1,-2002 # 8002c1c8 <ftable+0x48>
    800049a2:	00028717          	auipc	a4,0x28
    800049a6:	79e70713          	addi	a4,a4,1950 # 8002d140 <ftable+0xfc0>
    if(f->ref == 0){
    800049aa:	40dc                	lw	a5,4(s1)
    800049ac:	c39d                	beqz	a5,800049d2 <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049ae:	02848493          	addi	s1,s1,40
    800049b2:	fee49ce3          	bne	s1,a4,800049aa <filealloc+0x36>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800049b6:	00027517          	auipc	a0,0x27
    800049ba:	7ca50513          	addi	a0,a0,1994 # 8002c180 <ftable>
    800049be:	ffffc097          	auipc	ra,0xffffc
    800049c2:	48c080e7          	jalr	1164(ra) # 80000e4a <release>
  return 0;
    800049c6:	4481                	li	s1,0
    800049c8:	a839                	j	800049e6 <filealloc+0x72>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049ca:	00027497          	auipc	s1,0x27
    800049ce:	7d648493          	addi	s1,s1,2006 # 8002c1a0 <ftable+0x20>
      f->ref = 1;
    800049d2:	4785                	li	a5,1
    800049d4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800049d6:	00027517          	auipc	a0,0x27
    800049da:	7aa50513          	addi	a0,a0,1962 # 8002c180 <ftable>
    800049de:	ffffc097          	auipc	ra,0xffffc
    800049e2:	46c080e7          	jalr	1132(ra) # 80000e4a <release>
}
    800049e6:	8526                	mv	a0,s1
    800049e8:	60e2                	ld	ra,24(sp)
    800049ea:	6442                	ld	s0,16(sp)
    800049ec:	64a2                	ld	s1,8(sp)
    800049ee:	6105                	addi	sp,sp,32
    800049f0:	8082                	ret

00000000800049f2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800049f2:	1101                	addi	sp,sp,-32
    800049f4:	ec06                	sd	ra,24(sp)
    800049f6:	e822                	sd	s0,16(sp)
    800049f8:	e426                	sd	s1,8(sp)
    800049fa:	1000                	addi	s0,sp,32
    800049fc:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800049fe:	00027517          	auipc	a0,0x27
    80004a02:	78250513          	addi	a0,a0,1922 # 8002c180 <ftable>
    80004a06:	ffffc097          	auipc	ra,0xffffc
    80004a0a:	374080e7          	jalr	884(ra) # 80000d7a <acquire>
  if(f->ref < 1)
    80004a0e:	40dc                	lw	a5,4(s1)
    80004a10:	02f05263          	blez	a5,80004a34 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a14:	2785                	addiw	a5,a5,1
    80004a16:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a18:	00027517          	auipc	a0,0x27
    80004a1c:	76850513          	addi	a0,a0,1896 # 8002c180 <ftable>
    80004a20:	ffffc097          	auipc	ra,0xffffc
    80004a24:	42a080e7          	jalr	1066(ra) # 80000e4a <release>
  return f;
}
    80004a28:	8526                	mv	a0,s1
    80004a2a:	60e2                	ld	ra,24(sp)
    80004a2c:	6442                	ld	s0,16(sp)
    80004a2e:	64a2                	ld	s1,8(sp)
    80004a30:	6105                	addi	sp,sp,32
    80004a32:	8082                	ret
    panic("filedup");
    80004a34:	00004517          	auipc	a0,0x4
    80004a38:	cdc50513          	addi	a0,a0,-804 # 80008710 <syscalls+0x280>
    80004a3c:	ffffc097          	auipc	ra,0xffffc
    80004a40:	b3c080e7          	jalr	-1220(ra) # 80000578 <panic>

0000000080004a44 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a44:	7139                	addi	sp,sp,-64
    80004a46:	fc06                	sd	ra,56(sp)
    80004a48:	f822                	sd	s0,48(sp)
    80004a4a:	f426                	sd	s1,40(sp)
    80004a4c:	f04a                	sd	s2,32(sp)
    80004a4e:	ec4e                	sd	s3,24(sp)
    80004a50:	e852                	sd	s4,16(sp)
    80004a52:	e456                	sd	s5,8(sp)
    80004a54:	0080                	addi	s0,sp,64
    80004a56:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a58:	00027517          	auipc	a0,0x27
    80004a5c:	72850513          	addi	a0,a0,1832 # 8002c180 <ftable>
    80004a60:	ffffc097          	auipc	ra,0xffffc
    80004a64:	31a080e7          	jalr	794(ra) # 80000d7a <acquire>
  if(f->ref < 1)
    80004a68:	40dc                	lw	a5,4(s1)
    80004a6a:	06f05163          	blez	a5,80004acc <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004a6e:	37fd                	addiw	a5,a5,-1
    80004a70:	0007871b          	sext.w	a4,a5
    80004a74:	c0dc                	sw	a5,4(s1)
    80004a76:	06e04363          	bgtz	a4,80004adc <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a7a:	0004a903          	lw	s2,0(s1)
    80004a7e:	0094ca83          	lbu	s5,9(s1)
    80004a82:	0104ba03          	ld	s4,16(s1)
    80004a86:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a8a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a8e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a92:	00027517          	auipc	a0,0x27
    80004a96:	6ee50513          	addi	a0,a0,1774 # 8002c180 <ftable>
    80004a9a:	ffffc097          	auipc	ra,0xffffc
    80004a9e:	3b0080e7          	jalr	944(ra) # 80000e4a <release>

  if(ff.type == FD_PIPE){
    80004aa2:	4785                	li	a5,1
    80004aa4:	04f90d63          	beq	s2,a5,80004afe <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004aa8:	3979                	addiw	s2,s2,-2
    80004aaa:	4785                	li	a5,1
    80004aac:	0527e063          	bltu	a5,s2,80004aec <fileclose+0xa8>
    begin_op();
    80004ab0:	00000097          	auipc	ra,0x0
    80004ab4:	a90080e7          	jalr	-1392(ra) # 80004540 <begin_op>
    iput(ff.ip);
    80004ab8:	854e                	mv	a0,s3
    80004aba:	fffff097          	auipc	ra,0xfffff
    80004abe:	266080e7          	jalr	614(ra) # 80003d20 <iput>
    end_op();
    80004ac2:	00000097          	auipc	ra,0x0
    80004ac6:	afe080e7          	jalr	-1282(ra) # 800045c0 <end_op>
    80004aca:	a00d                	j	80004aec <fileclose+0xa8>
    panic("fileclose");
    80004acc:	00004517          	auipc	a0,0x4
    80004ad0:	c4c50513          	addi	a0,a0,-948 # 80008718 <syscalls+0x288>
    80004ad4:	ffffc097          	auipc	ra,0xffffc
    80004ad8:	aa4080e7          	jalr	-1372(ra) # 80000578 <panic>
    release(&ftable.lock);
    80004adc:	00027517          	auipc	a0,0x27
    80004ae0:	6a450513          	addi	a0,a0,1700 # 8002c180 <ftable>
    80004ae4:	ffffc097          	auipc	ra,0xffffc
    80004ae8:	366080e7          	jalr	870(ra) # 80000e4a <release>
  }
}
    80004aec:	70e2                	ld	ra,56(sp)
    80004aee:	7442                	ld	s0,48(sp)
    80004af0:	74a2                	ld	s1,40(sp)
    80004af2:	7902                	ld	s2,32(sp)
    80004af4:	69e2                	ld	s3,24(sp)
    80004af6:	6a42                	ld	s4,16(sp)
    80004af8:	6aa2                	ld	s5,8(sp)
    80004afa:	6121                	addi	sp,sp,64
    80004afc:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004afe:	85d6                	mv	a1,s5
    80004b00:	8552                	mv	a0,s4
    80004b02:	00000097          	auipc	ra,0x0
    80004b06:	364080e7          	jalr	868(ra) # 80004e66 <pipeclose>
    80004b0a:	b7cd                	j	80004aec <fileclose+0xa8>

0000000080004b0c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b0c:	715d                	addi	sp,sp,-80
    80004b0e:	e486                	sd	ra,72(sp)
    80004b10:	e0a2                	sd	s0,64(sp)
    80004b12:	fc26                	sd	s1,56(sp)
    80004b14:	f84a                	sd	s2,48(sp)
    80004b16:	f44e                	sd	s3,40(sp)
    80004b18:	0880                	addi	s0,sp,80
    80004b1a:	84aa                	mv	s1,a0
    80004b1c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b1e:	ffffd097          	auipc	ra,0xffffd
    80004b22:	30c080e7          	jalr	780(ra) # 80001e2a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b26:	409c                	lw	a5,0(s1)
    80004b28:	37f9                	addiw	a5,a5,-2
    80004b2a:	4705                	li	a4,1
    80004b2c:	04f76763          	bltu	a4,a5,80004b7a <filestat+0x6e>
    80004b30:	892a                	mv	s2,a0
    ilock(f->ip);
    80004b32:	6c88                	ld	a0,24(s1)
    80004b34:	fffff097          	auipc	ra,0xfffff
    80004b38:	030080e7          	jalr	48(ra) # 80003b64 <ilock>
    stati(f->ip, &st);
    80004b3c:	fb840593          	addi	a1,s0,-72
    80004b40:	6c88                	ld	a0,24(s1)
    80004b42:	fffff097          	auipc	ra,0xfffff
    80004b46:	2ae080e7          	jalr	686(ra) # 80003df0 <stati>
    iunlock(f->ip);
    80004b4a:	6c88                	ld	a0,24(s1)
    80004b4c:	fffff097          	auipc	ra,0xfffff
    80004b50:	0dc080e7          	jalr	220(ra) # 80003c28 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b54:	46e1                	li	a3,24
    80004b56:	fb840613          	addi	a2,s0,-72
    80004b5a:	85ce                	mv	a1,s3
    80004b5c:	05893503          	ld	a0,88(s2)
    80004b60:	ffffd097          	auipc	ra,0xffffd
    80004b64:	fa6080e7          	jalr	-90(ra) # 80001b06 <copyout>
    80004b68:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004b6c:	60a6                	ld	ra,72(sp)
    80004b6e:	6406                	ld	s0,64(sp)
    80004b70:	74e2                	ld	s1,56(sp)
    80004b72:	7942                	ld	s2,48(sp)
    80004b74:	79a2                	ld	s3,40(sp)
    80004b76:	6161                	addi	sp,sp,80
    80004b78:	8082                	ret
  return -1;
    80004b7a:	557d                	li	a0,-1
    80004b7c:	bfc5                	j	80004b6c <filestat+0x60>

0000000080004b7e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b7e:	7179                	addi	sp,sp,-48
    80004b80:	f406                	sd	ra,40(sp)
    80004b82:	f022                	sd	s0,32(sp)
    80004b84:	ec26                	sd	s1,24(sp)
    80004b86:	e84a                	sd	s2,16(sp)
    80004b88:	e44e                	sd	s3,8(sp)
    80004b8a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b8c:	00854783          	lbu	a5,8(a0)
    80004b90:	c3d5                	beqz	a5,80004c34 <fileread+0xb6>
    80004b92:	89b2                	mv	s3,a2
    80004b94:	892e                	mv	s2,a1
    80004b96:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80004b98:	411c                	lw	a5,0(a0)
    80004b9a:	4705                	li	a4,1
    80004b9c:	04e78963          	beq	a5,a4,80004bee <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ba0:	470d                	li	a4,3
    80004ba2:	04e78d63          	beq	a5,a4,80004bfc <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ba6:	4709                	li	a4,2
    80004ba8:	06e79e63          	bne	a5,a4,80004c24 <fileread+0xa6>
    ilock(f->ip);
    80004bac:	6d08                	ld	a0,24(a0)
    80004bae:	fffff097          	auipc	ra,0xfffff
    80004bb2:	fb6080e7          	jalr	-74(ra) # 80003b64 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004bb6:	874e                	mv	a4,s3
    80004bb8:	5094                	lw	a3,32(s1)
    80004bba:	864a                	mv	a2,s2
    80004bbc:	4585                	li	a1,1
    80004bbe:	6c88                	ld	a0,24(s1)
    80004bc0:	fffff097          	auipc	ra,0xfffff
    80004bc4:	25a080e7          	jalr	602(ra) # 80003e1a <readi>
    80004bc8:	892a                	mv	s2,a0
    80004bca:	00a05563          	blez	a0,80004bd4 <fileread+0x56>
      f->off += r;
    80004bce:	509c                	lw	a5,32(s1)
    80004bd0:	9fa9                	addw	a5,a5,a0
    80004bd2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004bd4:	6c88                	ld	a0,24(s1)
    80004bd6:	fffff097          	auipc	ra,0xfffff
    80004bda:	052080e7          	jalr	82(ra) # 80003c28 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004bde:	854a                	mv	a0,s2
    80004be0:	70a2                	ld	ra,40(sp)
    80004be2:	7402                	ld	s0,32(sp)
    80004be4:	64e2                	ld	s1,24(sp)
    80004be6:	6942                	ld	s2,16(sp)
    80004be8:	69a2                	ld	s3,8(sp)
    80004bea:	6145                	addi	sp,sp,48
    80004bec:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004bee:	6908                	ld	a0,16(a0)
    80004bf0:	00000097          	auipc	ra,0x0
    80004bf4:	420080e7          	jalr	1056(ra) # 80005010 <piperead>
    80004bf8:	892a                	mv	s2,a0
    80004bfa:	b7d5                	j	80004bde <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004bfc:	02451783          	lh	a5,36(a0)
    80004c00:	03079693          	slli	a3,a5,0x30
    80004c04:	92c1                	srli	a3,a3,0x30
    80004c06:	4725                	li	a4,9
    80004c08:	02d76863          	bltu	a4,a3,80004c38 <fileread+0xba>
    80004c0c:	0792                	slli	a5,a5,0x4
    80004c0e:	00027717          	auipc	a4,0x27
    80004c12:	4d270713          	addi	a4,a4,1234 # 8002c0e0 <devsw>
    80004c16:	97ba                	add	a5,a5,a4
    80004c18:	639c                	ld	a5,0(a5)
    80004c1a:	c38d                	beqz	a5,80004c3c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004c1c:	4505                	li	a0,1
    80004c1e:	9782                	jalr	a5
    80004c20:	892a                	mv	s2,a0
    80004c22:	bf75                	j	80004bde <fileread+0x60>
    panic("fileread");
    80004c24:	00004517          	auipc	a0,0x4
    80004c28:	b0450513          	addi	a0,a0,-1276 # 80008728 <syscalls+0x298>
    80004c2c:	ffffc097          	auipc	ra,0xffffc
    80004c30:	94c080e7          	jalr	-1716(ra) # 80000578 <panic>
    return -1;
    80004c34:	597d                	li	s2,-1
    80004c36:	b765                	j	80004bde <fileread+0x60>
      return -1;
    80004c38:	597d                	li	s2,-1
    80004c3a:	b755                	j	80004bde <fileread+0x60>
    80004c3c:	597d                	li	s2,-1
    80004c3e:	b745                	j	80004bde <fileread+0x60>

0000000080004c40 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004c40:	00954783          	lbu	a5,9(a0)
    80004c44:	12078e63          	beqz	a5,80004d80 <filewrite+0x140>
{
    80004c48:	715d                	addi	sp,sp,-80
    80004c4a:	e486                	sd	ra,72(sp)
    80004c4c:	e0a2                	sd	s0,64(sp)
    80004c4e:	fc26                	sd	s1,56(sp)
    80004c50:	f84a                	sd	s2,48(sp)
    80004c52:	f44e                	sd	s3,40(sp)
    80004c54:	f052                	sd	s4,32(sp)
    80004c56:	ec56                	sd	s5,24(sp)
    80004c58:	e85a                	sd	s6,16(sp)
    80004c5a:	e45e                	sd	s7,8(sp)
    80004c5c:	e062                	sd	s8,0(sp)
    80004c5e:	0880                	addi	s0,sp,80
    80004c60:	8ab2                	mv	s5,a2
    80004c62:	8b2e                	mv	s6,a1
    80004c64:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80004c66:	411c                	lw	a5,0(a0)
    80004c68:	4705                	li	a4,1
    80004c6a:	02e78263          	beq	a5,a4,80004c8e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c6e:	470d                	li	a4,3
    80004c70:	02e78563          	beq	a5,a4,80004c9a <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c74:	4709                	li	a4,2
    80004c76:	0ee79d63          	bne	a5,a4,80004d70 <filewrite+0x130>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c7a:	0ec05763          	blez	a2,80004d68 <filewrite+0x128>
    int i = 0;
    80004c7e:	4901                	li	s2,0
    80004c80:	6b85                	lui	s7,0x1
    80004c82:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004c86:	6c05                	lui	s8,0x1
    80004c88:	c00c0c1b          	addiw	s8,s8,-1024
    80004c8c:	a061                	j	80004d14 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    80004c8e:	6908                	ld	a0,16(a0)
    80004c90:	00000097          	auipc	ra,0x0
    80004c94:	250080e7          	jalr	592(ra) # 80004ee0 <pipewrite>
    80004c98:	a065                	j	80004d40 <filewrite+0x100>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c9a:	02451783          	lh	a5,36(a0)
    80004c9e:	03079693          	slli	a3,a5,0x30
    80004ca2:	92c1                	srli	a3,a3,0x30
    80004ca4:	4725                	li	a4,9
    80004ca6:	0cd76f63          	bltu	a4,a3,80004d84 <filewrite+0x144>
    80004caa:	0792                	slli	a5,a5,0x4
    80004cac:	00027717          	auipc	a4,0x27
    80004cb0:	43470713          	addi	a4,a4,1076 # 8002c0e0 <devsw>
    80004cb4:	97ba                	add	a5,a5,a4
    80004cb6:	679c                	ld	a5,8(a5)
    80004cb8:	cbe1                	beqz	a5,80004d88 <filewrite+0x148>
    ret = devsw[f->major].write(1, addr, n);
    80004cba:	4505                	li	a0,1
    80004cbc:	9782                	jalr	a5
    80004cbe:	a049                	j	80004d40 <filewrite+0x100>
    80004cc0:	00098a1b          	sext.w	s4,s3
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004cc4:	00000097          	auipc	ra,0x0
    80004cc8:	87c080e7          	jalr	-1924(ra) # 80004540 <begin_op>
      ilock(f->ip);
    80004ccc:	6c88                	ld	a0,24(s1)
    80004cce:	fffff097          	auipc	ra,0xfffff
    80004cd2:	e96080e7          	jalr	-362(ra) # 80003b64 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004cd6:	8752                	mv	a4,s4
    80004cd8:	5094                	lw	a3,32(s1)
    80004cda:	01690633          	add	a2,s2,s6
    80004cde:	4585                	li	a1,1
    80004ce0:	6c88                	ld	a0,24(s1)
    80004ce2:	fffff097          	auipc	ra,0xfffff
    80004ce6:	230080e7          	jalr	560(ra) # 80003f12 <writei>
    80004cea:	89aa                	mv	s3,a0
    80004cec:	02a05c63          	blez	a0,80004d24 <filewrite+0xe4>
        f->off += r;
    80004cf0:	509c                	lw	a5,32(s1)
    80004cf2:	9fa9                	addw	a5,a5,a0
    80004cf4:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004cf6:	6c88                	ld	a0,24(s1)
    80004cf8:	fffff097          	auipc	ra,0xfffff
    80004cfc:	f30080e7          	jalr	-208(ra) # 80003c28 <iunlock>
      end_op();
    80004d00:	00000097          	auipc	ra,0x0
    80004d04:	8c0080e7          	jalr	-1856(ra) # 800045c0 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004d08:	05499863          	bne	s3,s4,80004d58 <filewrite+0x118>
        panic("short filewrite");
      i += r;
    80004d0c:	012a093b          	addw	s2,s4,s2
    while(i < n){
    80004d10:	03595563          	ble	s5,s2,80004d3a <filewrite+0xfa>
      int n1 = n - i;
    80004d14:	412a87bb          	subw	a5,s5,s2
      if(n1 > max)
    80004d18:	89be                	mv	s3,a5
    80004d1a:	2781                	sext.w	a5,a5
    80004d1c:	fafbd2e3          	ble	a5,s7,80004cc0 <filewrite+0x80>
    80004d20:	89e2                	mv	s3,s8
    80004d22:	bf79                	j	80004cc0 <filewrite+0x80>
      iunlock(f->ip);
    80004d24:	6c88                	ld	a0,24(s1)
    80004d26:	fffff097          	auipc	ra,0xfffff
    80004d2a:	f02080e7          	jalr	-254(ra) # 80003c28 <iunlock>
      end_op();
    80004d2e:	00000097          	auipc	ra,0x0
    80004d32:	892080e7          	jalr	-1902(ra) # 800045c0 <end_op>
      if(r < 0)
    80004d36:	fc09d9e3          	bgez	s3,80004d08 <filewrite+0xc8>
    }
    ret = (i == n ? n : -1);
    80004d3a:	8556                	mv	a0,s5
    80004d3c:	032a9863          	bne	s5,s2,80004d6c <filewrite+0x12c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d40:	60a6                	ld	ra,72(sp)
    80004d42:	6406                	ld	s0,64(sp)
    80004d44:	74e2                	ld	s1,56(sp)
    80004d46:	7942                	ld	s2,48(sp)
    80004d48:	79a2                	ld	s3,40(sp)
    80004d4a:	7a02                	ld	s4,32(sp)
    80004d4c:	6ae2                	ld	s5,24(sp)
    80004d4e:	6b42                	ld	s6,16(sp)
    80004d50:	6ba2                	ld	s7,8(sp)
    80004d52:	6c02                	ld	s8,0(sp)
    80004d54:	6161                	addi	sp,sp,80
    80004d56:	8082                	ret
        panic("short filewrite");
    80004d58:	00004517          	auipc	a0,0x4
    80004d5c:	9e050513          	addi	a0,a0,-1568 # 80008738 <syscalls+0x2a8>
    80004d60:	ffffc097          	auipc	ra,0xffffc
    80004d64:	818080e7          	jalr	-2024(ra) # 80000578 <panic>
    int i = 0;
    80004d68:	4901                	li	s2,0
    80004d6a:	bfc1                	j	80004d3a <filewrite+0xfa>
    ret = (i == n ? n : -1);
    80004d6c:	557d                	li	a0,-1
    80004d6e:	bfc9                	j	80004d40 <filewrite+0x100>
    panic("filewrite");
    80004d70:	00004517          	auipc	a0,0x4
    80004d74:	9d850513          	addi	a0,a0,-1576 # 80008748 <syscalls+0x2b8>
    80004d78:	ffffc097          	auipc	ra,0xffffc
    80004d7c:	800080e7          	jalr	-2048(ra) # 80000578 <panic>
    return -1;
    80004d80:	557d                	li	a0,-1
}
    80004d82:	8082                	ret
      return -1;
    80004d84:	557d                	li	a0,-1
    80004d86:	bf6d                	j	80004d40 <filewrite+0x100>
    80004d88:	557d                	li	a0,-1
    80004d8a:	bf5d                	j	80004d40 <filewrite+0x100>

0000000080004d8c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d8c:	7179                	addi	sp,sp,-48
    80004d8e:	f406                	sd	ra,40(sp)
    80004d90:	f022                	sd	s0,32(sp)
    80004d92:	ec26                	sd	s1,24(sp)
    80004d94:	e84a                	sd	s2,16(sp)
    80004d96:	e44e                	sd	s3,8(sp)
    80004d98:	e052                	sd	s4,0(sp)
    80004d9a:	1800                	addi	s0,sp,48
    80004d9c:	84aa                	mv	s1,a0
    80004d9e:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004da0:	0005b023          	sd	zero,0(a1)
    80004da4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004da8:	00000097          	auipc	ra,0x0
    80004dac:	bcc080e7          	jalr	-1076(ra) # 80004974 <filealloc>
    80004db0:	e088                	sd	a0,0(s1)
    80004db2:	c551                	beqz	a0,80004e3e <pipealloc+0xb2>
    80004db4:	00000097          	auipc	ra,0x0
    80004db8:	bc0080e7          	jalr	-1088(ra) # 80004974 <filealloc>
    80004dbc:	00a93023          	sd	a0,0(s2)
    80004dc0:	c92d                	beqz	a0,80004e32 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004dc2:	ffffc097          	auipc	ra,0xffffc
    80004dc6:	ea8080e7          	jalr	-344(ra) # 80000c6a <kalloc>
    80004dca:	89aa                	mv	s3,a0
    80004dcc:	c125                	beqz	a0,80004e2c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004dce:	4a05                	li	s4,1
    80004dd0:	23452423          	sw	s4,552(a0)
  pi->writeopen = 1;
    80004dd4:	23452623          	sw	s4,556(a0)
  pi->nwrite = 0;
    80004dd8:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004ddc:	22052023          	sw	zero,544(a0)
  initlock(&pi->lock, "pipe");
    80004de0:	00004597          	auipc	a1,0x4
    80004de4:	97858593          	addi	a1,a1,-1672 # 80008758 <syscalls+0x2c8>
    80004de8:	ffffc097          	auipc	ra,0xffffc
    80004dec:	11e080e7          	jalr	286(ra) # 80000f06 <initlock>
  (*f0)->type = FD_PIPE;
    80004df0:	609c                	ld	a5,0(s1)
    80004df2:	0147a023          	sw	s4,0(a5)
  (*f0)->readable = 1;
    80004df6:	609c                	ld	a5,0(s1)
    80004df8:	01478423          	sb	s4,8(a5)
  (*f0)->writable = 0;
    80004dfc:	609c                	ld	a5,0(s1)
    80004dfe:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e02:	609c                	ld	a5,0(s1)
    80004e04:	0137b823          	sd	s3,16(a5)
  (*f1)->type = FD_PIPE;
    80004e08:	00093783          	ld	a5,0(s2)
    80004e0c:	0147a023          	sw	s4,0(a5)
  (*f1)->readable = 0;
    80004e10:	00093783          	ld	a5,0(s2)
    80004e14:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e18:	00093783          	ld	a5,0(s2)
    80004e1c:	014784a3          	sb	s4,9(a5)
  (*f1)->pipe = pi;
    80004e20:	00093783          	ld	a5,0(s2)
    80004e24:	0137b823          	sd	s3,16(a5)
  return 0;
    80004e28:	4501                	li	a0,0
    80004e2a:	a025                	j	80004e52 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e2c:	6088                	ld	a0,0(s1)
    80004e2e:	e501                	bnez	a0,80004e36 <pipealloc+0xaa>
    80004e30:	a039                	j	80004e3e <pipealloc+0xb2>
    80004e32:	6088                	ld	a0,0(s1)
    80004e34:	c51d                	beqz	a0,80004e62 <pipealloc+0xd6>
    fileclose(*f0);
    80004e36:	00000097          	auipc	ra,0x0
    80004e3a:	c0e080e7          	jalr	-1010(ra) # 80004a44 <fileclose>
  if(*f1)
    80004e3e:	00093783          	ld	a5,0(s2)
    fileclose(*f1);
  return -1;
    80004e42:	557d                	li	a0,-1
  if(*f1)
    80004e44:	c799                	beqz	a5,80004e52 <pipealloc+0xc6>
    fileclose(*f1);
    80004e46:	853e                	mv	a0,a5
    80004e48:	00000097          	auipc	ra,0x0
    80004e4c:	bfc080e7          	jalr	-1028(ra) # 80004a44 <fileclose>
  return -1;
    80004e50:	557d                	li	a0,-1
}
    80004e52:	70a2                	ld	ra,40(sp)
    80004e54:	7402                	ld	s0,32(sp)
    80004e56:	64e2                	ld	s1,24(sp)
    80004e58:	6942                	ld	s2,16(sp)
    80004e5a:	69a2                	ld	s3,8(sp)
    80004e5c:	6a02                	ld	s4,0(sp)
    80004e5e:	6145                	addi	sp,sp,48
    80004e60:	8082                	ret
  return -1;
    80004e62:	557d                	li	a0,-1
    80004e64:	b7fd                	j	80004e52 <pipealloc+0xc6>

0000000080004e66 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e66:	1101                	addi	sp,sp,-32
    80004e68:	ec06                	sd	ra,24(sp)
    80004e6a:	e822                	sd	s0,16(sp)
    80004e6c:	e426                	sd	s1,8(sp)
    80004e6e:	e04a                	sd	s2,0(sp)
    80004e70:	1000                	addi	s0,sp,32
    80004e72:	84aa                	mv	s1,a0
    80004e74:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e76:	ffffc097          	auipc	ra,0xffffc
    80004e7a:	f04080e7          	jalr	-252(ra) # 80000d7a <acquire>
  if(writable){
    80004e7e:	04090263          	beqz	s2,80004ec2 <pipeclose+0x5c>
    pi->writeopen = 0;
    80004e82:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004e86:	22048513          	addi	a0,s1,544
    80004e8a:	ffffe097          	auipc	ra,0xffffe
    80004e8e:	940080e7          	jalr	-1728(ra) # 800027ca <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004e92:	2284b783          	ld	a5,552(s1)
    80004e96:	ef9d                	bnez	a5,80004ed4 <pipeclose+0x6e>
    release(&pi->lock);
    80004e98:	8526                	mv	a0,s1
    80004e9a:	ffffc097          	auipc	ra,0xffffc
    80004e9e:	fb0080e7          	jalr	-80(ra) # 80000e4a <release>
#ifdef LAB_LOCK
    freelock(&pi->lock);
    80004ea2:	8526                	mv	a0,s1
    80004ea4:	ffffc097          	auipc	ra,0xffffc
    80004ea8:	fee080e7          	jalr	-18(ra) # 80000e92 <freelock>
#endif    
    kfree((char*)pi);
    80004eac:	8526                	mv	a0,s1
    80004eae:	ffffc097          	auipc	ra,0xffffc
    80004eb2:	bc8080e7          	jalr	-1080(ra) # 80000a76 <kfree>
  } else
    release(&pi->lock);
}
    80004eb6:	60e2                	ld	ra,24(sp)
    80004eb8:	6442                	ld	s0,16(sp)
    80004eba:	64a2                	ld	s1,8(sp)
    80004ebc:	6902                	ld	s2,0(sp)
    80004ebe:	6105                	addi	sp,sp,32
    80004ec0:	8082                	ret
    pi->readopen = 0;
    80004ec2:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004ec6:	22448513          	addi	a0,s1,548
    80004eca:	ffffe097          	auipc	ra,0xffffe
    80004ece:	900080e7          	jalr	-1792(ra) # 800027ca <wakeup>
    80004ed2:	b7c1                	j	80004e92 <pipeclose+0x2c>
    release(&pi->lock);
    80004ed4:	8526                	mv	a0,s1
    80004ed6:	ffffc097          	auipc	ra,0xffffc
    80004eda:	f74080e7          	jalr	-140(ra) # 80000e4a <release>
}
    80004ede:	bfe1                	j	80004eb6 <pipeclose+0x50>

0000000080004ee0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ee0:	7119                	addi	sp,sp,-128
    80004ee2:	fc86                	sd	ra,120(sp)
    80004ee4:	f8a2                	sd	s0,112(sp)
    80004ee6:	f4a6                	sd	s1,104(sp)
    80004ee8:	f0ca                	sd	s2,96(sp)
    80004eea:	ecce                	sd	s3,88(sp)
    80004eec:	e8d2                	sd	s4,80(sp)
    80004eee:	e4d6                	sd	s5,72(sp)
    80004ef0:	e0da                	sd	s6,64(sp)
    80004ef2:	fc5e                	sd	s7,56(sp)
    80004ef4:	f862                	sd	s8,48(sp)
    80004ef6:	f466                	sd	s9,40(sp)
    80004ef8:	f06a                	sd	s10,32(sp)
    80004efa:	ec6e                	sd	s11,24(sp)
    80004efc:	0100                	addi	s0,sp,128
    80004efe:	84aa                	mv	s1,a0
    80004f00:	8d2e                	mv	s10,a1
    80004f02:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004f04:	ffffd097          	auipc	ra,0xffffd
    80004f08:	f26080e7          	jalr	-218(ra) # 80001e2a <myproc>
    80004f0c:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004f0e:	8526                	mv	a0,s1
    80004f10:	ffffc097          	auipc	ra,0xffffc
    80004f14:	e6a080e7          	jalr	-406(ra) # 80000d7a <acquire>
  for(i = 0; i < n; i++){
    80004f18:	0d605f63          	blez	s6,80004ff6 <pipewrite+0x116>
    80004f1c:	89a6                	mv	s3,s1
    80004f1e:	3b7d                	addiw	s6,s6,-1
    80004f20:	1b02                	slli	s6,s6,0x20
    80004f22:	020b5b13          	srli	s6,s6,0x20
    80004f26:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004f28:	22048a93          	addi	s5,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004f2c:	22448a13          	addi	s4,s1,548
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f30:	5dfd                	li	s11,-1
    80004f32:	000b8c9b          	sext.w	s9,s7
    80004f36:	8c66                	mv	s8,s9
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004f38:	2204a783          	lw	a5,544(s1)
    80004f3c:	2244a703          	lw	a4,548(s1)
    80004f40:	2007879b          	addiw	a5,a5,512
    80004f44:	06f71763          	bne	a4,a5,80004fb2 <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004f48:	2284a783          	lw	a5,552(s1)
    80004f4c:	cf8d                	beqz	a5,80004f86 <pipewrite+0xa6>
    80004f4e:	03892783          	lw	a5,56(s2)
    80004f52:	eb95                	bnez	a5,80004f86 <pipewrite+0xa6>
      wakeup(&pi->nread);
    80004f54:	8556                	mv	a0,s5
    80004f56:	ffffe097          	auipc	ra,0xffffe
    80004f5a:	874080e7          	jalr	-1932(ra) # 800027ca <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004f5e:	85ce                	mv	a1,s3
    80004f60:	8552                	mv	a0,s4
    80004f62:	ffffd097          	auipc	ra,0xffffd
    80004f66:	6e2080e7          	jalr	1762(ra) # 80002644 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004f6a:	2204a783          	lw	a5,544(s1)
    80004f6e:	2244a703          	lw	a4,548(s1)
    80004f72:	2007879b          	addiw	a5,a5,512
    80004f76:	02f71e63          	bne	a4,a5,80004fb2 <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004f7a:	2284a783          	lw	a5,552(s1)
    80004f7e:	c781                	beqz	a5,80004f86 <pipewrite+0xa6>
    80004f80:	03892783          	lw	a5,56(s2)
    80004f84:	dbe1                	beqz	a5,80004f54 <pipewrite+0x74>
        release(&pi->lock);
    80004f86:	8526                	mv	a0,s1
    80004f88:	ffffc097          	auipc	ra,0xffffc
    80004f8c:	ec2080e7          	jalr	-318(ra) # 80000e4a <release>
        return -1;
    80004f90:	5c7d                	li	s8,-1
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004f92:	8562                	mv	a0,s8
    80004f94:	70e6                	ld	ra,120(sp)
    80004f96:	7446                	ld	s0,112(sp)
    80004f98:	74a6                	ld	s1,104(sp)
    80004f9a:	7906                	ld	s2,96(sp)
    80004f9c:	69e6                	ld	s3,88(sp)
    80004f9e:	6a46                	ld	s4,80(sp)
    80004fa0:	6aa6                	ld	s5,72(sp)
    80004fa2:	6b06                	ld	s6,64(sp)
    80004fa4:	7be2                	ld	s7,56(sp)
    80004fa6:	7c42                	ld	s8,48(sp)
    80004fa8:	7ca2                	ld	s9,40(sp)
    80004faa:	7d02                	ld	s10,32(sp)
    80004fac:	6de2                	ld	s11,24(sp)
    80004fae:	6109                	addi	sp,sp,128
    80004fb0:	8082                	ret
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fb2:	4685                	li	a3,1
    80004fb4:	01ab8633          	add	a2,s7,s10
    80004fb8:	f8f40593          	addi	a1,s0,-113
    80004fbc:	05893503          	ld	a0,88(s2)
    80004fc0:	ffffd097          	auipc	ra,0xffffd
    80004fc4:	bd2080e7          	jalr	-1070(ra) # 80001b92 <copyin>
    80004fc8:	03b50863          	beq	a0,s11,80004ff8 <pipewrite+0x118>
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004fcc:	2244a783          	lw	a5,548(s1)
    80004fd0:	0017871b          	addiw	a4,a5,1
    80004fd4:	22e4a223          	sw	a4,548(s1)
    80004fd8:	1ff7f793          	andi	a5,a5,511
    80004fdc:	97a6                	add	a5,a5,s1
    80004fde:	f8f44703          	lbu	a4,-113(s0)
    80004fe2:	02e78023          	sb	a4,32(a5)
  for(i = 0; i < n; i++){
    80004fe6:	001c8c1b          	addiw	s8,s9,1
    80004fea:	001b8793          	addi	a5,s7,1
    80004fee:	016b8563          	beq	s7,s6,80004ff8 <pipewrite+0x118>
    80004ff2:	8bbe                	mv	s7,a5
    80004ff4:	bf3d                	j	80004f32 <pipewrite+0x52>
    80004ff6:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004ff8:	22048513          	addi	a0,s1,544
    80004ffc:	ffffd097          	auipc	ra,0xffffd
    80005000:	7ce080e7          	jalr	1998(ra) # 800027ca <wakeup>
  release(&pi->lock);
    80005004:	8526                	mv	a0,s1
    80005006:	ffffc097          	auipc	ra,0xffffc
    8000500a:	e44080e7          	jalr	-444(ra) # 80000e4a <release>
  return i;
    8000500e:	b751                	j	80004f92 <pipewrite+0xb2>

0000000080005010 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005010:	715d                	addi	sp,sp,-80
    80005012:	e486                	sd	ra,72(sp)
    80005014:	e0a2                	sd	s0,64(sp)
    80005016:	fc26                	sd	s1,56(sp)
    80005018:	f84a                	sd	s2,48(sp)
    8000501a:	f44e                	sd	s3,40(sp)
    8000501c:	f052                	sd	s4,32(sp)
    8000501e:	ec56                	sd	s5,24(sp)
    80005020:	e85a                	sd	s6,16(sp)
    80005022:	0880                	addi	s0,sp,80
    80005024:	84aa                	mv	s1,a0
    80005026:	89ae                	mv	s3,a1
    80005028:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000502a:	ffffd097          	auipc	ra,0xffffd
    8000502e:	e00080e7          	jalr	-512(ra) # 80001e2a <myproc>
    80005032:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005034:	8526                	mv	a0,s1
    80005036:	ffffc097          	auipc	ra,0xffffc
    8000503a:	d44080e7          	jalr	-700(ra) # 80000d7a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000503e:	2204a703          	lw	a4,544(s1)
    80005042:	2244a783          	lw	a5,548(s1)
    80005046:	06f71b63          	bne	a4,a5,800050bc <piperead+0xac>
    8000504a:	8926                	mv	s2,s1
    8000504c:	22c4a783          	lw	a5,556(s1)
    80005050:	cf9d                	beqz	a5,8000508e <piperead+0x7e>
    if(pr->killed){
    80005052:	038a2783          	lw	a5,56(s4)
    80005056:	e78d                	bnez	a5,80005080 <piperead+0x70>
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005058:	22048b13          	addi	s6,s1,544
    8000505c:	85ca                	mv	a1,s2
    8000505e:	855a                	mv	a0,s6
    80005060:	ffffd097          	auipc	ra,0xffffd
    80005064:	5e4080e7          	jalr	1508(ra) # 80002644 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005068:	2204a703          	lw	a4,544(s1)
    8000506c:	2244a783          	lw	a5,548(s1)
    80005070:	04f71663          	bne	a4,a5,800050bc <piperead+0xac>
    80005074:	22c4a783          	lw	a5,556(s1)
    80005078:	cb99                	beqz	a5,8000508e <piperead+0x7e>
    if(pr->killed){
    8000507a:	038a2783          	lw	a5,56(s4)
    8000507e:	dff9                	beqz	a5,8000505c <piperead+0x4c>
      release(&pi->lock);
    80005080:	8526                	mv	a0,s1
    80005082:	ffffc097          	auipc	ra,0xffffc
    80005086:	dc8080e7          	jalr	-568(ra) # 80000e4a <release>
      return -1;
    8000508a:	597d                	li	s2,-1
    8000508c:	a829                	j	800050a6 <piperead+0x96>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(pi->nread == pi->nwrite)
    8000508e:	4901                	li	s2,0
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005090:	22448513          	addi	a0,s1,548
    80005094:	ffffd097          	auipc	ra,0xffffd
    80005098:	736080e7          	jalr	1846(ra) # 800027ca <wakeup>
  release(&pi->lock);
    8000509c:	8526                	mv	a0,s1
    8000509e:	ffffc097          	auipc	ra,0xffffc
    800050a2:	dac080e7          	jalr	-596(ra) # 80000e4a <release>
  return i;
}
    800050a6:	854a                	mv	a0,s2
    800050a8:	60a6                	ld	ra,72(sp)
    800050aa:	6406                	ld	s0,64(sp)
    800050ac:	74e2                	ld	s1,56(sp)
    800050ae:	7942                	ld	s2,48(sp)
    800050b0:	79a2                	ld	s3,40(sp)
    800050b2:	7a02                	ld	s4,32(sp)
    800050b4:	6ae2                	ld	s5,24(sp)
    800050b6:	6b42                	ld	s6,16(sp)
    800050b8:	6161                	addi	sp,sp,80
    800050ba:	8082                	ret
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050bc:	4901                	li	s2,0
    800050be:	fd5059e3          	blez	s5,80005090 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    800050c2:	2204a783          	lw	a5,544(s1)
    800050c6:	4901                	li	s2,0
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050c8:	5b7d                	li	s6,-1
    ch = pi->data[pi->nread++ % PIPESIZE];
    800050ca:	0017871b          	addiw	a4,a5,1
    800050ce:	22e4a023          	sw	a4,544(s1)
    800050d2:	1ff7f793          	andi	a5,a5,511
    800050d6:	97a6                	add	a5,a5,s1
    800050d8:	0207c783          	lbu	a5,32(a5)
    800050dc:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050e0:	4685                	li	a3,1
    800050e2:	fbf40613          	addi	a2,s0,-65
    800050e6:	85ce                	mv	a1,s3
    800050e8:	058a3503          	ld	a0,88(s4)
    800050ec:	ffffd097          	auipc	ra,0xffffd
    800050f0:	a1a080e7          	jalr	-1510(ra) # 80001b06 <copyout>
    800050f4:	f9650ee3          	beq	a0,s6,80005090 <piperead+0x80>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050f8:	2905                	addiw	s2,s2,1
    800050fa:	f92a8be3          	beq	s5,s2,80005090 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    800050fe:	2204a783          	lw	a5,544(s1)
    80005102:	0985                	addi	s3,s3,1
    80005104:	2244a703          	lw	a4,548(s1)
    80005108:	fcf711e3          	bne	a4,a5,800050ca <piperead+0xba>
    8000510c:	b751                	j	80005090 <piperead+0x80>

000000008000510e <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    8000510e:	de010113          	addi	sp,sp,-544
    80005112:	20113c23          	sd	ra,536(sp)
    80005116:	20813823          	sd	s0,528(sp)
    8000511a:	20913423          	sd	s1,520(sp)
    8000511e:	21213023          	sd	s2,512(sp)
    80005122:	ffce                	sd	s3,504(sp)
    80005124:	fbd2                	sd	s4,496(sp)
    80005126:	f7d6                	sd	s5,488(sp)
    80005128:	f3da                	sd	s6,480(sp)
    8000512a:	efde                	sd	s7,472(sp)
    8000512c:	ebe2                	sd	s8,464(sp)
    8000512e:	e7e6                	sd	s9,456(sp)
    80005130:	e3ea                	sd	s10,448(sp)
    80005132:	ff6e                	sd	s11,440(sp)
    80005134:	1400                	addi	s0,sp,544
    80005136:	892a                	mv	s2,a0
    80005138:	dea43823          	sd	a0,-528(s0)
    8000513c:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005140:	ffffd097          	auipc	ra,0xffffd
    80005144:	cea080e7          	jalr	-790(ra) # 80001e2a <myproc>
    80005148:	84aa                	mv	s1,a0

  begin_op();
    8000514a:	fffff097          	auipc	ra,0xfffff
    8000514e:	3f6080e7          	jalr	1014(ra) # 80004540 <begin_op>

  if((ip = namei(path)) == 0){
    80005152:	854a                	mv	a0,s2
    80005154:	fffff097          	auipc	ra,0xfffff
    80005158:	1ce080e7          	jalr	462(ra) # 80004322 <namei>
    8000515c:	c93d                	beqz	a0,800051d2 <exec+0xc4>
    8000515e:	892a                	mv	s2,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005160:	fffff097          	auipc	ra,0xfffff
    80005164:	a04080e7          	jalr	-1532(ra) # 80003b64 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005168:	04000713          	li	a4,64
    8000516c:	4681                	li	a3,0
    8000516e:	e4840613          	addi	a2,s0,-440
    80005172:	4581                	li	a1,0
    80005174:	854a                	mv	a0,s2
    80005176:	fffff097          	auipc	ra,0xfffff
    8000517a:	ca4080e7          	jalr	-860(ra) # 80003e1a <readi>
    8000517e:	04000793          	li	a5,64
    80005182:	00f51a63          	bne	a0,a5,80005196 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005186:	e4842703          	lw	a4,-440(s0)
    8000518a:	464c47b7          	lui	a5,0x464c4
    8000518e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005192:	04f70663          	beq	a4,a5,800051de <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005196:	854a                	mv	a0,s2
    80005198:	fffff097          	auipc	ra,0xfffff
    8000519c:	c30080e7          	jalr	-976(ra) # 80003dc8 <iunlockput>
    end_op();
    800051a0:	fffff097          	auipc	ra,0xfffff
    800051a4:	420080e7          	jalr	1056(ra) # 800045c0 <end_op>
  }
  return -1;
    800051a8:	557d                	li	a0,-1
}
    800051aa:	21813083          	ld	ra,536(sp)
    800051ae:	21013403          	ld	s0,528(sp)
    800051b2:	20813483          	ld	s1,520(sp)
    800051b6:	20013903          	ld	s2,512(sp)
    800051ba:	79fe                	ld	s3,504(sp)
    800051bc:	7a5e                	ld	s4,496(sp)
    800051be:	7abe                	ld	s5,488(sp)
    800051c0:	7b1e                	ld	s6,480(sp)
    800051c2:	6bfe                	ld	s7,472(sp)
    800051c4:	6c5e                	ld	s8,464(sp)
    800051c6:	6cbe                	ld	s9,456(sp)
    800051c8:	6d1e                	ld	s10,448(sp)
    800051ca:	7dfa                	ld	s11,440(sp)
    800051cc:	22010113          	addi	sp,sp,544
    800051d0:	8082                	ret
    end_op();
    800051d2:	fffff097          	auipc	ra,0xfffff
    800051d6:	3ee080e7          	jalr	1006(ra) # 800045c0 <end_op>
    return -1;
    800051da:	557d                	li	a0,-1
    800051dc:	b7f9                	j	800051aa <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800051de:	8526                	mv	a0,s1
    800051e0:	ffffd097          	auipc	ra,0xffffd
    800051e4:	d10080e7          	jalr	-752(ra) # 80001ef0 <proc_pagetable>
    800051e8:	e0a43423          	sd	a0,-504(s0)
    800051ec:	d54d                	beqz	a0,80005196 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051ee:	e6842983          	lw	s3,-408(s0)
    800051f2:	e8045783          	lhu	a5,-384(s0)
    800051f6:	c7ad                	beqz	a5,80005260 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800051f8:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051fa:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    800051fc:	6c05                	lui	s8,0x1
    800051fe:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    80005202:	def43423          	sd	a5,-536(s0)
    80005206:	7cfd                	lui	s9,0xfffff
    80005208:	ac1d                	j	8000543e <exec+0x330>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000520a:	00003517          	auipc	a0,0x3
    8000520e:	55650513          	addi	a0,a0,1366 # 80008760 <syscalls+0x2d0>
    80005212:	ffffb097          	auipc	ra,0xffffb
    80005216:	366080e7          	jalr	870(ra) # 80000578 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000521a:	8756                	mv	a4,s5
    8000521c:	009d86bb          	addw	a3,s11,s1
    80005220:	4581                	li	a1,0
    80005222:	854a                	mv	a0,s2
    80005224:	fffff097          	auipc	ra,0xfffff
    80005228:	bf6080e7          	jalr	-1034(ra) # 80003e1a <readi>
    8000522c:	2501                	sext.w	a0,a0
    8000522e:	1aaa9e63          	bne	s5,a0,800053ea <exec+0x2dc>
  for(i = 0; i < sz; i += PGSIZE){
    80005232:	6785                	lui	a5,0x1
    80005234:	9cbd                	addw	s1,s1,a5
    80005236:	014c8a3b          	addw	s4,s9,s4
    8000523a:	1f74f963          	bleu	s7,s1,8000542c <exec+0x31e>
    pa = walkaddr(pagetable, va + i);
    8000523e:	02049593          	slli	a1,s1,0x20
    80005242:	9181                	srli	a1,a1,0x20
    80005244:	95ea                	add	a1,a1,s10
    80005246:	e0843503          	ld	a0,-504(s0)
    8000524a:	ffffc097          	auipc	ra,0xffffc
    8000524e:	2fa080e7          	jalr	762(ra) # 80001544 <walkaddr>
    80005252:	862a                	mv	a2,a0
    if(pa == 0)
    80005254:	d95d                	beqz	a0,8000520a <exec+0xfc>
      n = PGSIZE;
    80005256:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    80005258:	fd8a71e3          	bleu	s8,s4,8000521a <exec+0x10c>
      n = sz - i;
    8000525c:	8ad2                	mv	s5,s4
    8000525e:	bf75                	j	8000521a <exec+0x10c>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005260:	4481                	li	s1,0
  iunlockput(ip);
    80005262:	854a                	mv	a0,s2
    80005264:	fffff097          	auipc	ra,0xfffff
    80005268:	b64080e7          	jalr	-1180(ra) # 80003dc8 <iunlockput>
  end_op();
    8000526c:	fffff097          	auipc	ra,0xfffff
    80005270:	354080e7          	jalr	852(ra) # 800045c0 <end_op>
  p = myproc();
    80005274:	ffffd097          	auipc	ra,0xffffd
    80005278:	bb6080e7          	jalr	-1098(ra) # 80001e2a <myproc>
    8000527c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000527e:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80005282:	6785                	lui	a5,0x1
    80005284:	17fd                	addi	a5,a5,-1
    80005286:	94be                	add	s1,s1,a5
    80005288:	77fd                	lui	a5,0xfffff
    8000528a:	8fe5                	and	a5,a5,s1
    8000528c:	e0f43023          	sd	a5,-512(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005290:	6609                	lui	a2,0x2
    80005292:	963e                	add	a2,a2,a5
    80005294:	85be                	mv	a1,a5
    80005296:	e0843483          	ld	s1,-504(s0)
    8000529a:	8526                	mv	a0,s1
    8000529c:	ffffc097          	auipc	ra,0xffffc
    800052a0:	61a080e7          	jalr	1562(ra) # 800018b6 <uvmalloc>
    800052a4:	8b2a                	mv	s6,a0
  ip = 0;
    800052a6:	4901                	li	s2,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800052a8:	14050163          	beqz	a0,800053ea <exec+0x2dc>
  uvmclear(pagetable, sz-2*PGSIZE);
    800052ac:	75f9                	lui	a1,0xffffe
    800052ae:	95aa                	add	a1,a1,a0
    800052b0:	8526                	mv	a0,s1
    800052b2:	ffffd097          	auipc	ra,0xffffd
    800052b6:	822080e7          	jalr	-2014(ra) # 80001ad4 <uvmclear>
  stackbase = sp - PGSIZE;
    800052ba:	7bfd                	lui	s7,0xfffff
    800052bc:	9bda                	add	s7,s7,s6
  for(argc = 0; argv[argc]; argc++) {
    800052be:	df843783          	ld	a5,-520(s0)
    800052c2:	6388                	ld	a0,0(a5)
    800052c4:	c925                	beqz	a0,80005334 <exec+0x226>
    800052c6:	e8840993          	addi	s3,s0,-376
    800052ca:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    800052ce:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800052d0:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800052d2:	ffffc097          	auipc	ra,0xffffc
    800052d6:	05e080e7          	jalr	94(ra) # 80001330 <strlen>
    800052da:	2505                	addiw	a0,a0,1
    800052dc:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800052e0:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800052e4:	13796863          	bltu	s2,s7,80005414 <exec+0x306>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800052e8:	df843c83          	ld	s9,-520(s0)
    800052ec:	000cba03          	ld	s4,0(s9) # fffffffffffff000 <end+0xffffffff7ffccfd8>
    800052f0:	8552                	mv	a0,s4
    800052f2:	ffffc097          	auipc	ra,0xffffc
    800052f6:	03e080e7          	jalr	62(ra) # 80001330 <strlen>
    800052fa:	0015069b          	addiw	a3,a0,1
    800052fe:	8652                	mv	a2,s4
    80005300:	85ca                	mv	a1,s2
    80005302:	e0843503          	ld	a0,-504(s0)
    80005306:	ffffd097          	auipc	ra,0xffffd
    8000530a:	800080e7          	jalr	-2048(ra) # 80001b06 <copyout>
    8000530e:	10054763          	bltz	a0,8000541c <exec+0x30e>
    ustack[argc] = sp;
    80005312:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005316:	0485                	addi	s1,s1,1
    80005318:	008c8793          	addi	a5,s9,8
    8000531c:	def43c23          	sd	a5,-520(s0)
    80005320:	008cb503          	ld	a0,8(s9)
    80005324:	c911                	beqz	a0,80005338 <exec+0x22a>
    if(argc >= MAXARG)
    80005326:	09a1                	addi	s3,s3,8
    80005328:	fb8995e3          	bne	s3,s8,800052d2 <exec+0x1c4>
  sz = sz1;
    8000532c:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005330:	4901                	li	s2,0
    80005332:	a865                	j	800053ea <exec+0x2dc>
  sp = sz;
    80005334:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005336:	4481                	li	s1,0
  ustack[argc] = 0;
    80005338:	00349793          	slli	a5,s1,0x3
    8000533c:	f9040713          	addi	a4,s0,-112
    80005340:	97ba                	add	a5,a5,a4
    80005342:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffcced0>
  sp -= (argc+1) * sizeof(uint64);
    80005346:	00148693          	addi	a3,s1,1
    8000534a:	068e                	slli	a3,a3,0x3
    8000534c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005350:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005354:	01797663          	bleu	s7,s2,80005360 <exec+0x252>
  sz = sz1;
    80005358:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    8000535c:	4901                	li	s2,0
    8000535e:	a071                	j	800053ea <exec+0x2dc>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005360:	e8840613          	addi	a2,s0,-376
    80005364:	85ca                	mv	a1,s2
    80005366:	e0843503          	ld	a0,-504(s0)
    8000536a:	ffffc097          	auipc	ra,0xffffc
    8000536e:	79c080e7          	jalr	1948(ra) # 80001b06 <copyout>
    80005372:	0a054963          	bltz	a0,80005424 <exec+0x316>
  p->trapframe->a1 = sp;
    80005376:	060ab783          	ld	a5,96(s5)
    8000537a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000537e:	df043783          	ld	a5,-528(s0)
    80005382:	0007c703          	lbu	a4,0(a5)
    80005386:	cf11                	beqz	a4,800053a2 <exec+0x294>
    80005388:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000538a:	02f00693          	li	a3,47
    8000538e:	a029                	j	80005398 <exec+0x28a>
  for(last=s=path; *s; s++)
    80005390:	0785                	addi	a5,a5,1
    80005392:	fff7c703          	lbu	a4,-1(a5)
    80005396:	c711                	beqz	a4,800053a2 <exec+0x294>
    if(*s == '/')
    80005398:	fed71ce3          	bne	a4,a3,80005390 <exec+0x282>
      last = s+1;
    8000539c:	def43823          	sd	a5,-528(s0)
    800053a0:	bfc5                	j	80005390 <exec+0x282>
  safestrcpy(p->name, last, sizeof(p->name));
    800053a2:	4641                	li	a2,16
    800053a4:	df043583          	ld	a1,-528(s0)
    800053a8:	160a8513          	addi	a0,s5,352
    800053ac:	ffffc097          	auipc	ra,0xffffc
    800053b0:	f52080e7          	jalr	-174(ra) # 800012fe <safestrcpy>
  oldpagetable = p->pagetable;
    800053b4:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    800053b8:	e0843783          	ld	a5,-504(s0)
    800053bc:	04fabc23          	sd	a5,88(s5)
  p->sz = sz;
    800053c0:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800053c4:	060ab783          	ld	a5,96(s5)
    800053c8:	e6043703          	ld	a4,-416(s0)
    800053cc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800053ce:	060ab783          	ld	a5,96(s5)
    800053d2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800053d6:	85ea                	mv	a1,s10
    800053d8:	ffffd097          	auipc	ra,0xffffd
    800053dc:	bb4080e7          	jalr	-1100(ra) # 80001f8c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800053e0:	0004851b          	sext.w	a0,s1
    800053e4:	b3d9                	j	800051aa <exec+0x9c>
    800053e6:	e0943023          	sd	s1,-512(s0)
    proc_freepagetable(pagetable, sz);
    800053ea:	e0043583          	ld	a1,-512(s0)
    800053ee:	e0843503          	ld	a0,-504(s0)
    800053f2:	ffffd097          	auipc	ra,0xffffd
    800053f6:	b9a080e7          	jalr	-1126(ra) # 80001f8c <proc_freepagetable>
  if(ip){
    800053fa:	d8091ee3          	bnez	s2,80005196 <exec+0x88>
  return -1;
    800053fe:	557d                	li	a0,-1
    80005400:	b36d                	j	800051aa <exec+0x9c>
    80005402:	e0943023          	sd	s1,-512(s0)
    80005406:	b7d5                	j	800053ea <exec+0x2dc>
    80005408:	e0943023          	sd	s1,-512(s0)
    8000540c:	bff9                	j	800053ea <exec+0x2dc>
    8000540e:	e0943023          	sd	s1,-512(s0)
    80005412:	bfe1                	j	800053ea <exec+0x2dc>
  sz = sz1;
    80005414:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005418:	4901                	li	s2,0
    8000541a:	bfc1                	j	800053ea <exec+0x2dc>
  sz = sz1;
    8000541c:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005420:	4901                	li	s2,0
    80005422:	b7e1                	j	800053ea <exec+0x2dc>
  sz = sz1;
    80005424:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005428:	4901                	li	s2,0
    8000542a:	b7c1                	j	800053ea <exec+0x2dc>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000542c:	e0043483          	ld	s1,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005430:	2b05                	addiw	s6,s6,1
    80005432:	0389899b          	addiw	s3,s3,56
    80005436:	e8045783          	lhu	a5,-384(s0)
    8000543a:	e2fb54e3          	ble	a5,s6,80005262 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000543e:	2981                	sext.w	s3,s3
    80005440:	03800713          	li	a4,56
    80005444:	86ce                	mv	a3,s3
    80005446:	e1040613          	addi	a2,s0,-496
    8000544a:	4581                	li	a1,0
    8000544c:	854a                	mv	a0,s2
    8000544e:	fffff097          	auipc	ra,0xfffff
    80005452:	9cc080e7          	jalr	-1588(ra) # 80003e1a <readi>
    80005456:	03800793          	li	a5,56
    8000545a:	f8f516e3          	bne	a0,a5,800053e6 <exec+0x2d8>
    if(ph.type != ELF_PROG_LOAD)
    8000545e:	e1042783          	lw	a5,-496(s0)
    80005462:	4705                	li	a4,1
    80005464:	fce796e3          	bne	a5,a4,80005430 <exec+0x322>
    if(ph.memsz < ph.filesz)
    80005468:	e3843603          	ld	a2,-456(s0)
    8000546c:	e3043783          	ld	a5,-464(s0)
    80005470:	f8f669e3          	bltu	a2,a5,80005402 <exec+0x2f4>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005474:	e2043783          	ld	a5,-480(s0)
    80005478:	963e                	add	a2,a2,a5
    8000547a:	f8f667e3          	bltu	a2,a5,80005408 <exec+0x2fa>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000547e:	85a6                	mv	a1,s1
    80005480:	e0843503          	ld	a0,-504(s0)
    80005484:	ffffc097          	auipc	ra,0xffffc
    80005488:	432080e7          	jalr	1074(ra) # 800018b6 <uvmalloc>
    8000548c:	e0a43023          	sd	a0,-512(s0)
    80005490:	dd3d                	beqz	a0,8000540e <exec+0x300>
    if(ph.vaddr % PGSIZE != 0)
    80005492:	e2043d03          	ld	s10,-480(s0)
    80005496:	de843783          	ld	a5,-536(s0)
    8000549a:	00fd77b3          	and	a5,s10,a5
    8000549e:	f7b1                	bnez	a5,800053ea <exec+0x2dc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800054a0:	e1842d83          	lw	s11,-488(s0)
    800054a4:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800054a8:	f80b82e3          	beqz	s7,8000542c <exec+0x31e>
    800054ac:	8a5e                	mv	s4,s7
    800054ae:	4481                	li	s1,0
    800054b0:	b379                	j	8000523e <exec+0x130>

00000000800054b2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800054b2:	7179                	addi	sp,sp,-48
    800054b4:	f406                	sd	ra,40(sp)
    800054b6:	f022                	sd	s0,32(sp)
    800054b8:	ec26                	sd	s1,24(sp)
    800054ba:	e84a                	sd	s2,16(sp)
    800054bc:	1800                	addi	s0,sp,48
    800054be:	892e                	mv	s2,a1
    800054c0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800054c2:	fdc40593          	addi	a1,s0,-36
    800054c6:	ffffe097          	auipc	ra,0xffffe
    800054ca:	a34080e7          	jalr	-1484(ra) # 80002efa <argint>
    800054ce:	04054063          	bltz	a0,8000550e <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800054d2:	fdc42703          	lw	a4,-36(s0)
    800054d6:	47bd                	li	a5,15
    800054d8:	02e7ed63          	bltu	a5,a4,80005512 <argfd+0x60>
    800054dc:	ffffd097          	auipc	ra,0xffffd
    800054e0:	94e080e7          	jalr	-1714(ra) # 80001e2a <myproc>
    800054e4:	fdc42703          	lw	a4,-36(s0)
    800054e8:	01a70793          	addi	a5,a4,26
    800054ec:	078e                	slli	a5,a5,0x3
    800054ee:	953e                	add	a0,a0,a5
    800054f0:	651c                	ld	a5,8(a0)
    800054f2:	c395                	beqz	a5,80005516 <argfd+0x64>
    return -1;
  if(pfd)
    800054f4:	00090463          	beqz	s2,800054fc <argfd+0x4a>
    *pfd = fd;
    800054f8:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800054fc:	4501                	li	a0,0
  if(pf)
    800054fe:	c091                	beqz	s1,80005502 <argfd+0x50>
    *pf = f;
    80005500:	e09c                	sd	a5,0(s1)
}
    80005502:	70a2                	ld	ra,40(sp)
    80005504:	7402                	ld	s0,32(sp)
    80005506:	64e2                	ld	s1,24(sp)
    80005508:	6942                	ld	s2,16(sp)
    8000550a:	6145                	addi	sp,sp,48
    8000550c:	8082                	ret
    return -1;
    8000550e:	557d                	li	a0,-1
    80005510:	bfcd                	j	80005502 <argfd+0x50>
    return -1;
    80005512:	557d                	li	a0,-1
    80005514:	b7fd                	j	80005502 <argfd+0x50>
    80005516:	557d                	li	a0,-1
    80005518:	b7ed                	j	80005502 <argfd+0x50>

000000008000551a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000551a:	1101                	addi	sp,sp,-32
    8000551c:	ec06                	sd	ra,24(sp)
    8000551e:	e822                	sd	s0,16(sp)
    80005520:	e426                	sd	s1,8(sp)
    80005522:	1000                	addi	s0,sp,32
    80005524:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005526:	ffffd097          	auipc	ra,0xffffd
    8000552a:	904080e7          	jalr	-1788(ra) # 80001e2a <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
    8000552e:	6d7c                	ld	a5,216(a0)
    80005530:	c395                	beqz	a5,80005554 <fdalloc+0x3a>
    80005532:	0e050713          	addi	a4,a0,224
  for(fd = 0; fd < NOFILE; fd++){
    80005536:	4785                	li	a5,1
    80005538:	4641                	li	a2,16
    if(p->ofile[fd] == 0){
    8000553a:	6314                	ld	a3,0(a4)
    8000553c:	ce89                	beqz	a3,80005556 <fdalloc+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
    8000553e:	2785                	addiw	a5,a5,1
    80005540:	0721                	addi	a4,a4,8
    80005542:	fec79ce3          	bne	a5,a2,8000553a <fdalloc+0x20>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005546:	57fd                	li	a5,-1
}
    80005548:	853e                	mv	a0,a5
    8000554a:	60e2                	ld	ra,24(sp)
    8000554c:	6442                	ld	s0,16(sp)
    8000554e:	64a2                	ld	s1,8(sp)
    80005550:	6105                	addi	sp,sp,32
    80005552:	8082                	ret
  for(fd = 0; fd < NOFILE; fd++){
    80005554:	4781                	li	a5,0
      p->ofile[fd] = f;
    80005556:	01a78713          	addi	a4,a5,26
    8000555a:	070e                	slli	a4,a4,0x3
    8000555c:	953a                	add	a0,a0,a4
    8000555e:	e504                	sd	s1,8(a0)
      return fd;
    80005560:	b7e5                	j	80005548 <fdalloc+0x2e>

0000000080005562 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005562:	715d                	addi	sp,sp,-80
    80005564:	e486                	sd	ra,72(sp)
    80005566:	e0a2                	sd	s0,64(sp)
    80005568:	fc26                	sd	s1,56(sp)
    8000556a:	f84a                	sd	s2,48(sp)
    8000556c:	f44e                	sd	s3,40(sp)
    8000556e:	f052                	sd	s4,32(sp)
    80005570:	ec56                	sd	s5,24(sp)
    80005572:	0880                	addi	s0,sp,80
    80005574:	89ae                	mv	s3,a1
    80005576:	8ab2                	mv	s5,a2
    80005578:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000557a:	fb040593          	addi	a1,s0,-80
    8000557e:	fffff097          	auipc	ra,0xfffff
    80005582:	dc2080e7          	jalr	-574(ra) # 80004340 <nameiparent>
    80005586:	892a                	mv	s2,a0
    80005588:	12050f63          	beqz	a0,800056c6 <create+0x164>
    return 0;

  ilock(dp);
    8000558c:	ffffe097          	auipc	ra,0xffffe
    80005590:	5d8080e7          	jalr	1496(ra) # 80003b64 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005594:	4601                	li	a2,0
    80005596:	fb040593          	addi	a1,s0,-80
    8000559a:	854a                	mv	a0,s2
    8000559c:	fffff097          	auipc	ra,0xfffff
    800055a0:	aac080e7          	jalr	-1364(ra) # 80004048 <dirlookup>
    800055a4:	84aa                	mv	s1,a0
    800055a6:	c921                	beqz	a0,800055f6 <create+0x94>
    iunlockput(dp);
    800055a8:	854a                	mv	a0,s2
    800055aa:	fffff097          	auipc	ra,0xfffff
    800055ae:	81e080e7          	jalr	-2018(ra) # 80003dc8 <iunlockput>
    ilock(ip);
    800055b2:	8526                	mv	a0,s1
    800055b4:	ffffe097          	auipc	ra,0xffffe
    800055b8:	5b0080e7          	jalr	1456(ra) # 80003b64 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800055bc:	2981                	sext.w	s3,s3
    800055be:	4789                	li	a5,2
    800055c0:	02f99463          	bne	s3,a5,800055e8 <create+0x86>
    800055c4:	04c4d783          	lhu	a5,76(s1)
    800055c8:	37f9                	addiw	a5,a5,-2
    800055ca:	17c2                	slli	a5,a5,0x30
    800055cc:	93c1                	srli	a5,a5,0x30
    800055ce:	4705                	li	a4,1
    800055d0:	00f76c63          	bltu	a4,a5,800055e8 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800055d4:	8526                	mv	a0,s1
    800055d6:	60a6                	ld	ra,72(sp)
    800055d8:	6406                	ld	s0,64(sp)
    800055da:	74e2                	ld	s1,56(sp)
    800055dc:	7942                	ld	s2,48(sp)
    800055de:	79a2                	ld	s3,40(sp)
    800055e0:	7a02                	ld	s4,32(sp)
    800055e2:	6ae2                	ld	s5,24(sp)
    800055e4:	6161                	addi	sp,sp,80
    800055e6:	8082                	ret
    iunlockput(ip);
    800055e8:	8526                	mv	a0,s1
    800055ea:	ffffe097          	auipc	ra,0xffffe
    800055ee:	7de080e7          	jalr	2014(ra) # 80003dc8 <iunlockput>
    return 0;
    800055f2:	4481                	li	s1,0
    800055f4:	b7c5                	j	800055d4 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800055f6:	85ce                	mv	a1,s3
    800055f8:	00092503          	lw	a0,0(s2)
    800055fc:	ffffe097          	auipc	ra,0xffffe
    80005600:	3cc080e7          	jalr	972(ra) # 800039c8 <ialloc>
    80005604:	84aa                	mv	s1,a0
    80005606:	c529                	beqz	a0,80005650 <create+0xee>
  ilock(ip);
    80005608:	ffffe097          	auipc	ra,0xffffe
    8000560c:	55c080e7          	jalr	1372(ra) # 80003b64 <ilock>
  ip->major = major;
    80005610:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    80005614:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    80005618:	4785                	li	a5,1
    8000561a:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    8000561e:	8526                	mv	a0,s1
    80005620:	ffffe097          	auipc	ra,0xffffe
    80005624:	478080e7          	jalr	1144(ra) # 80003a98 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005628:	2981                	sext.w	s3,s3
    8000562a:	4785                	li	a5,1
    8000562c:	02f98a63          	beq	s3,a5,80005660 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005630:	40d0                	lw	a2,4(s1)
    80005632:	fb040593          	addi	a1,s0,-80
    80005636:	854a                	mv	a0,s2
    80005638:	fffff097          	auipc	ra,0xfffff
    8000563c:	c28080e7          	jalr	-984(ra) # 80004260 <dirlink>
    80005640:	06054b63          	bltz	a0,800056b6 <create+0x154>
  iunlockput(dp);
    80005644:	854a                	mv	a0,s2
    80005646:	ffffe097          	auipc	ra,0xffffe
    8000564a:	782080e7          	jalr	1922(ra) # 80003dc8 <iunlockput>
  return ip;
    8000564e:	b759                	j	800055d4 <create+0x72>
    panic("create: ialloc");
    80005650:	00003517          	auipc	a0,0x3
    80005654:	13050513          	addi	a0,a0,304 # 80008780 <syscalls+0x2f0>
    80005658:	ffffb097          	auipc	ra,0xffffb
    8000565c:	f20080e7          	jalr	-224(ra) # 80000578 <panic>
    dp->nlink++;  // for ".."
    80005660:	05295783          	lhu	a5,82(s2)
    80005664:	2785                	addiw	a5,a5,1
    80005666:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    8000566a:	854a                	mv	a0,s2
    8000566c:	ffffe097          	auipc	ra,0xffffe
    80005670:	42c080e7          	jalr	1068(ra) # 80003a98 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005674:	40d0                	lw	a2,4(s1)
    80005676:	00003597          	auipc	a1,0x3
    8000567a:	11a58593          	addi	a1,a1,282 # 80008790 <syscalls+0x300>
    8000567e:	8526                	mv	a0,s1
    80005680:	fffff097          	auipc	ra,0xfffff
    80005684:	be0080e7          	jalr	-1056(ra) # 80004260 <dirlink>
    80005688:	00054f63          	bltz	a0,800056a6 <create+0x144>
    8000568c:	00492603          	lw	a2,4(s2)
    80005690:	00003597          	auipc	a1,0x3
    80005694:	10858593          	addi	a1,a1,264 # 80008798 <syscalls+0x308>
    80005698:	8526                	mv	a0,s1
    8000569a:	fffff097          	auipc	ra,0xfffff
    8000569e:	bc6080e7          	jalr	-1082(ra) # 80004260 <dirlink>
    800056a2:	f80557e3          	bgez	a0,80005630 <create+0xce>
      panic("create dots");
    800056a6:	00003517          	auipc	a0,0x3
    800056aa:	0fa50513          	addi	a0,a0,250 # 800087a0 <syscalls+0x310>
    800056ae:	ffffb097          	auipc	ra,0xffffb
    800056b2:	eca080e7          	jalr	-310(ra) # 80000578 <panic>
    panic("create: dirlink");
    800056b6:	00003517          	auipc	a0,0x3
    800056ba:	0fa50513          	addi	a0,a0,250 # 800087b0 <syscalls+0x320>
    800056be:	ffffb097          	auipc	ra,0xffffb
    800056c2:	eba080e7          	jalr	-326(ra) # 80000578 <panic>
    return 0;
    800056c6:	84aa                	mv	s1,a0
    800056c8:	b731                	j	800055d4 <create+0x72>

00000000800056ca <sys_dup>:
{
    800056ca:	7179                	addi	sp,sp,-48
    800056cc:	f406                	sd	ra,40(sp)
    800056ce:	f022                	sd	s0,32(sp)
    800056d0:	ec26                	sd	s1,24(sp)
    800056d2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800056d4:	fd840613          	addi	a2,s0,-40
    800056d8:	4581                	li	a1,0
    800056da:	4501                	li	a0,0
    800056dc:	00000097          	auipc	ra,0x0
    800056e0:	dd6080e7          	jalr	-554(ra) # 800054b2 <argfd>
    return -1;
    800056e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800056e6:	02054363          	bltz	a0,8000570c <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800056ea:	fd843503          	ld	a0,-40(s0)
    800056ee:	00000097          	auipc	ra,0x0
    800056f2:	e2c080e7          	jalr	-468(ra) # 8000551a <fdalloc>
    800056f6:	84aa                	mv	s1,a0
    return -1;
    800056f8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800056fa:	00054963          	bltz	a0,8000570c <sys_dup+0x42>
  filedup(f);
    800056fe:	fd843503          	ld	a0,-40(s0)
    80005702:	fffff097          	auipc	ra,0xfffff
    80005706:	2f0080e7          	jalr	752(ra) # 800049f2 <filedup>
  return fd;
    8000570a:	87a6                	mv	a5,s1
}
    8000570c:	853e                	mv	a0,a5
    8000570e:	70a2                	ld	ra,40(sp)
    80005710:	7402                	ld	s0,32(sp)
    80005712:	64e2                	ld	s1,24(sp)
    80005714:	6145                	addi	sp,sp,48
    80005716:	8082                	ret

0000000080005718 <sys_read>:
{
    80005718:	7179                	addi	sp,sp,-48
    8000571a:	f406                	sd	ra,40(sp)
    8000571c:	f022                	sd	s0,32(sp)
    8000571e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005720:	fe840613          	addi	a2,s0,-24
    80005724:	4581                	li	a1,0
    80005726:	4501                	li	a0,0
    80005728:	00000097          	auipc	ra,0x0
    8000572c:	d8a080e7          	jalr	-630(ra) # 800054b2 <argfd>
    return -1;
    80005730:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005732:	04054163          	bltz	a0,80005774 <sys_read+0x5c>
    80005736:	fe440593          	addi	a1,s0,-28
    8000573a:	4509                	li	a0,2
    8000573c:	ffffd097          	auipc	ra,0xffffd
    80005740:	7be080e7          	jalr	1982(ra) # 80002efa <argint>
    return -1;
    80005744:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005746:	02054763          	bltz	a0,80005774 <sys_read+0x5c>
    8000574a:	fd840593          	addi	a1,s0,-40
    8000574e:	4505                	li	a0,1
    80005750:	ffffd097          	auipc	ra,0xffffd
    80005754:	7cc080e7          	jalr	1996(ra) # 80002f1c <argaddr>
    return -1;
    80005758:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000575a:	00054d63          	bltz	a0,80005774 <sys_read+0x5c>
  return fileread(f, p, n);
    8000575e:	fe442603          	lw	a2,-28(s0)
    80005762:	fd843583          	ld	a1,-40(s0)
    80005766:	fe843503          	ld	a0,-24(s0)
    8000576a:	fffff097          	auipc	ra,0xfffff
    8000576e:	414080e7          	jalr	1044(ra) # 80004b7e <fileread>
    80005772:	87aa                	mv	a5,a0
}
    80005774:	853e                	mv	a0,a5
    80005776:	70a2                	ld	ra,40(sp)
    80005778:	7402                	ld	s0,32(sp)
    8000577a:	6145                	addi	sp,sp,48
    8000577c:	8082                	ret

000000008000577e <sys_write>:
{
    8000577e:	7179                	addi	sp,sp,-48
    80005780:	f406                	sd	ra,40(sp)
    80005782:	f022                	sd	s0,32(sp)
    80005784:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005786:	fe840613          	addi	a2,s0,-24
    8000578a:	4581                	li	a1,0
    8000578c:	4501                	li	a0,0
    8000578e:	00000097          	auipc	ra,0x0
    80005792:	d24080e7          	jalr	-732(ra) # 800054b2 <argfd>
    return -1;
    80005796:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005798:	04054163          	bltz	a0,800057da <sys_write+0x5c>
    8000579c:	fe440593          	addi	a1,s0,-28
    800057a0:	4509                	li	a0,2
    800057a2:	ffffd097          	auipc	ra,0xffffd
    800057a6:	758080e7          	jalr	1880(ra) # 80002efa <argint>
    return -1;
    800057aa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057ac:	02054763          	bltz	a0,800057da <sys_write+0x5c>
    800057b0:	fd840593          	addi	a1,s0,-40
    800057b4:	4505                	li	a0,1
    800057b6:	ffffd097          	auipc	ra,0xffffd
    800057ba:	766080e7          	jalr	1894(ra) # 80002f1c <argaddr>
    return -1;
    800057be:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057c0:	00054d63          	bltz	a0,800057da <sys_write+0x5c>
  return filewrite(f, p, n);
    800057c4:	fe442603          	lw	a2,-28(s0)
    800057c8:	fd843583          	ld	a1,-40(s0)
    800057cc:	fe843503          	ld	a0,-24(s0)
    800057d0:	fffff097          	auipc	ra,0xfffff
    800057d4:	470080e7          	jalr	1136(ra) # 80004c40 <filewrite>
    800057d8:	87aa                	mv	a5,a0
}
    800057da:	853e                	mv	a0,a5
    800057dc:	70a2                	ld	ra,40(sp)
    800057de:	7402                	ld	s0,32(sp)
    800057e0:	6145                	addi	sp,sp,48
    800057e2:	8082                	ret

00000000800057e4 <sys_close>:
{
    800057e4:	1101                	addi	sp,sp,-32
    800057e6:	ec06                	sd	ra,24(sp)
    800057e8:	e822                	sd	s0,16(sp)
    800057ea:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800057ec:	fe040613          	addi	a2,s0,-32
    800057f0:	fec40593          	addi	a1,s0,-20
    800057f4:	4501                	li	a0,0
    800057f6:	00000097          	auipc	ra,0x0
    800057fa:	cbc080e7          	jalr	-836(ra) # 800054b2 <argfd>
    return -1;
    800057fe:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005800:	02054463          	bltz	a0,80005828 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005804:	ffffc097          	auipc	ra,0xffffc
    80005808:	626080e7          	jalr	1574(ra) # 80001e2a <myproc>
    8000580c:	fec42783          	lw	a5,-20(s0)
    80005810:	07e9                	addi	a5,a5,26
    80005812:	078e                	slli	a5,a5,0x3
    80005814:	953e                	add	a0,a0,a5
    80005816:	00053423          	sd	zero,8(a0)
  fileclose(f);
    8000581a:	fe043503          	ld	a0,-32(s0)
    8000581e:	fffff097          	auipc	ra,0xfffff
    80005822:	226080e7          	jalr	550(ra) # 80004a44 <fileclose>
  return 0;
    80005826:	4781                	li	a5,0
}
    80005828:	853e                	mv	a0,a5
    8000582a:	60e2                	ld	ra,24(sp)
    8000582c:	6442                	ld	s0,16(sp)
    8000582e:	6105                	addi	sp,sp,32
    80005830:	8082                	ret

0000000080005832 <sys_fstat>:
{
    80005832:	1101                	addi	sp,sp,-32
    80005834:	ec06                	sd	ra,24(sp)
    80005836:	e822                	sd	s0,16(sp)
    80005838:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000583a:	fe840613          	addi	a2,s0,-24
    8000583e:	4581                	li	a1,0
    80005840:	4501                	li	a0,0
    80005842:	00000097          	auipc	ra,0x0
    80005846:	c70080e7          	jalr	-912(ra) # 800054b2 <argfd>
    return -1;
    8000584a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000584c:	02054563          	bltz	a0,80005876 <sys_fstat+0x44>
    80005850:	fe040593          	addi	a1,s0,-32
    80005854:	4505                	li	a0,1
    80005856:	ffffd097          	auipc	ra,0xffffd
    8000585a:	6c6080e7          	jalr	1734(ra) # 80002f1c <argaddr>
    return -1;
    8000585e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005860:	00054b63          	bltz	a0,80005876 <sys_fstat+0x44>
  return filestat(f, st);
    80005864:	fe043583          	ld	a1,-32(s0)
    80005868:	fe843503          	ld	a0,-24(s0)
    8000586c:	fffff097          	auipc	ra,0xfffff
    80005870:	2a0080e7          	jalr	672(ra) # 80004b0c <filestat>
    80005874:	87aa                	mv	a5,a0
}
    80005876:	853e                	mv	a0,a5
    80005878:	60e2                	ld	ra,24(sp)
    8000587a:	6442                	ld	s0,16(sp)
    8000587c:	6105                	addi	sp,sp,32
    8000587e:	8082                	ret

0000000080005880 <sys_link>:
{
    80005880:	7169                	addi	sp,sp,-304
    80005882:	f606                	sd	ra,296(sp)
    80005884:	f222                	sd	s0,288(sp)
    80005886:	ee26                	sd	s1,280(sp)
    80005888:	ea4a                	sd	s2,272(sp)
    8000588a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000588c:	08000613          	li	a2,128
    80005890:	ed040593          	addi	a1,s0,-304
    80005894:	4501                	li	a0,0
    80005896:	ffffd097          	auipc	ra,0xffffd
    8000589a:	6a8080e7          	jalr	1704(ra) # 80002f3e <argstr>
    return -1;
    8000589e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058a0:	10054e63          	bltz	a0,800059bc <sys_link+0x13c>
    800058a4:	08000613          	li	a2,128
    800058a8:	f5040593          	addi	a1,s0,-176
    800058ac:	4505                	li	a0,1
    800058ae:	ffffd097          	auipc	ra,0xffffd
    800058b2:	690080e7          	jalr	1680(ra) # 80002f3e <argstr>
    return -1;
    800058b6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058b8:	10054263          	bltz	a0,800059bc <sys_link+0x13c>
  begin_op();
    800058bc:	fffff097          	auipc	ra,0xfffff
    800058c0:	c84080e7          	jalr	-892(ra) # 80004540 <begin_op>
  if((ip = namei(old)) == 0){
    800058c4:	ed040513          	addi	a0,s0,-304
    800058c8:	fffff097          	auipc	ra,0xfffff
    800058cc:	a5a080e7          	jalr	-1446(ra) # 80004322 <namei>
    800058d0:	84aa                	mv	s1,a0
    800058d2:	c551                	beqz	a0,8000595e <sys_link+0xde>
  ilock(ip);
    800058d4:	ffffe097          	auipc	ra,0xffffe
    800058d8:	290080e7          	jalr	656(ra) # 80003b64 <ilock>
  if(ip->type == T_DIR){
    800058dc:	04c49703          	lh	a4,76(s1)
    800058e0:	4785                	li	a5,1
    800058e2:	08f70463          	beq	a4,a5,8000596a <sys_link+0xea>
  ip->nlink++;
    800058e6:	0524d783          	lhu	a5,82(s1)
    800058ea:	2785                	addiw	a5,a5,1
    800058ec:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800058f0:	8526                	mv	a0,s1
    800058f2:	ffffe097          	auipc	ra,0xffffe
    800058f6:	1a6080e7          	jalr	422(ra) # 80003a98 <iupdate>
  iunlock(ip);
    800058fa:	8526                	mv	a0,s1
    800058fc:	ffffe097          	auipc	ra,0xffffe
    80005900:	32c080e7          	jalr	812(ra) # 80003c28 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005904:	fd040593          	addi	a1,s0,-48
    80005908:	f5040513          	addi	a0,s0,-176
    8000590c:	fffff097          	auipc	ra,0xfffff
    80005910:	a34080e7          	jalr	-1484(ra) # 80004340 <nameiparent>
    80005914:	892a                	mv	s2,a0
    80005916:	c935                	beqz	a0,8000598a <sys_link+0x10a>
  ilock(dp);
    80005918:	ffffe097          	auipc	ra,0xffffe
    8000591c:	24c080e7          	jalr	588(ra) # 80003b64 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005920:	00092703          	lw	a4,0(s2)
    80005924:	409c                	lw	a5,0(s1)
    80005926:	04f71d63          	bne	a4,a5,80005980 <sys_link+0x100>
    8000592a:	40d0                	lw	a2,4(s1)
    8000592c:	fd040593          	addi	a1,s0,-48
    80005930:	854a                	mv	a0,s2
    80005932:	fffff097          	auipc	ra,0xfffff
    80005936:	92e080e7          	jalr	-1746(ra) # 80004260 <dirlink>
    8000593a:	04054363          	bltz	a0,80005980 <sys_link+0x100>
  iunlockput(dp);
    8000593e:	854a                	mv	a0,s2
    80005940:	ffffe097          	auipc	ra,0xffffe
    80005944:	488080e7          	jalr	1160(ra) # 80003dc8 <iunlockput>
  iput(ip);
    80005948:	8526                	mv	a0,s1
    8000594a:	ffffe097          	auipc	ra,0xffffe
    8000594e:	3d6080e7          	jalr	982(ra) # 80003d20 <iput>
  end_op();
    80005952:	fffff097          	auipc	ra,0xfffff
    80005956:	c6e080e7          	jalr	-914(ra) # 800045c0 <end_op>
  return 0;
    8000595a:	4781                	li	a5,0
    8000595c:	a085                	j	800059bc <sys_link+0x13c>
    end_op();
    8000595e:	fffff097          	auipc	ra,0xfffff
    80005962:	c62080e7          	jalr	-926(ra) # 800045c0 <end_op>
    return -1;
    80005966:	57fd                	li	a5,-1
    80005968:	a891                	j	800059bc <sys_link+0x13c>
    iunlockput(ip);
    8000596a:	8526                	mv	a0,s1
    8000596c:	ffffe097          	auipc	ra,0xffffe
    80005970:	45c080e7          	jalr	1116(ra) # 80003dc8 <iunlockput>
    end_op();
    80005974:	fffff097          	auipc	ra,0xfffff
    80005978:	c4c080e7          	jalr	-948(ra) # 800045c0 <end_op>
    return -1;
    8000597c:	57fd                	li	a5,-1
    8000597e:	a83d                	j	800059bc <sys_link+0x13c>
    iunlockput(dp);
    80005980:	854a                	mv	a0,s2
    80005982:	ffffe097          	auipc	ra,0xffffe
    80005986:	446080e7          	jalr	1094(ra) # 80003dc8 <iunlockput>
  ilock(ip);
    8000598a:	8526                	mv	a0,s1
    8000598c:	ffffe097          	auipc	ra,0xffffe
    80005990:	1d8080e7          	jalr	472(ra) # 80003b64 <ilock>
  ip->nlink--;
    80005994:	0524d783          	lhu	a5,82(s1)
    80005998:	37fd                	addiw	a5,a5,-1
    8000599a:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    8000599e:	8526                	mv	a0,s1
    800059a0:	ffffe097          	auipc	ra,0xffffe
    800059a4:	0f8080e7          	jalr	248(ra) # 80003a98 <iupdate>
  iunlockput(ip);
    800059a8:	8526                	mv	a0,s1
    800059aa:	ffffe097          	auipc	ra,0xffffe
    800059ae:	41e080e7          	jalr	1054(ra) # 80003dc8 <iunlockput>
  end_op();
    800059b2:	fffff097          	auipc	ra,0xfffff
    800059b6:	c0e080e7          	jalr	-1010(ra) # 800045c0 <end_op>
  return -1;
    800059ba:	57fd                	li	a5,-1
}
    800059bc:	853e                	mv	a0,a5
    800059be:	70b2                	ld	ra,296(sp)
    800059c0:	7412                	ld	s0,288(sp)
    800059c2:	64f2                	ld	s1,280(sp)
    800059c4:	6952                	ld	s2,272(sp)
    800059c6:	6155                	addi	sp,sp,304
    800059c8:	8082                	ret

00000000800059ca <sys_unlink>:
{
    800059ca:	7151                	addi	sp,sp,-240
    800059cc:	f586                	sd	ra,232(sp)
    800059ce:	f1a2                	sd	s0,224(sp)
    800059d0:	eda6                	sd	s1,216(sp)
    800059d2:	e9ca                	sd	s2,208(sp)
    800059d4:	e5ce                	sd	s3,200(sp)
    800059d6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800059d8:	08000613          	li	a2,128
    800059dc:	f3040593          	addi	a1,s0,-208
    800059e0:	4501                	li	a0,0
    800059e2:	ffffd097          	auipc	ra,0xffffd
    800059e6:	55c080e7          	jalr	1372(ra) # 80002f3e <argstr>
    800059ea:	16054f63          	bltz	a0,80005b68 <sys_unlink+0x19e>
  begin_op();
    800059ee:	fffff097          	auipc	ra,0xfffff
    800059f2:	b52080e7          	jalr	-1198(ra) # 80004540 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800059f6:	fb040593          	addi	a1,s0,-80
    800059fa:	f3040513          	addi	a0,s0,-208
    800059fe:	fffff097          	auipc	ra,0xfffff
    80005a02:	942080e7          	jalr	-1726(ra) # 80004340 <nameiparent>
    80005a06:	89aa                	mv	s3,a0
    80005a08:	c979                	beqz	a0,80005ade <sys_unlink+0x114>
  ilock(dp);
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	15a080e7          	jalr	346(ra) # 80003b64 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a12:	00003597          	auipc	a1,0x3
    80005a16:	d7e58593          	addi	a1,a1,-642 # 80008790 <syscalls+0x300>
    80005a1a:	fb040513          	addi	a0,s0,-80
    80005a1e:	ffffe097          	auipc	ra,0xffffe
    80005a22:	610080e7          	jalr	1552(ra) # 8000402e <namecmp>
    80005a26:	14050863          	beqz	a0,80005b76 <sys_unlink+0x1ac>
    80005a2a:	00003597          	auipc	a1,0x3
    80005a2e:	d6e58593          	addi	a1,a1,-658 # 80008798 <syscalls+0x308>
    80005a32:	fb040513          	addi	a0,s0,-80
    80005a36:	ffffe097          	auipc	ra,0xffffe
    80005a3a:	5f8080e7          	jalr	1528(ra) # 8000402e <namecmp>
    80005a3e:	12050c63          	beqz	a0,80005b76 <sys_unlink+0x1ac>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a42:	f2c40613          	addi	a2,s0,-212
    80005a46:	fb040593          	addi	a1,s0,-80
    80005a4a:	854e                	mv	a0,s3
    80005a4c:	ffffe097          	auipc	ra,0xffffe
    80005a50:	5fc080e7          	jalr	1532(ra) # 80004048 <dirlookup>
    80005a54:	84aa                	mv	s1,a0
    80005a56:	12050063          	beqz	a0,80005b76 <sys_unlink+0x1ac>
  ilock(ip);
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	10a080e7          	jalr	266(ra) # 80003b64 <ilock>
  if(ip->nlink < 1)
    80005a62:	05249783          	lh	a5,82(s1)
    80005a66:	08f05263          	blez	a5,80005aea <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a6a:	04c49703          	lh	a4,76(s1)
    80005a6e:	4785                	li	a5,1
    80005a70:	08f70563          	beq	a4,a5,80005afa <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005a74:	4641                	li	a2,16
    80005a76:	4581                	li	a1,0
    80005a78:	fc040513          	addi	a0,s0,-64
    80005a7c:	ffffb097          	auipc	ra,0xffffb
    80005a80:	70a080e7          	jalr	1802(ra) # 80001186 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a84:	4741                	li	a4,16
    80005a86:	f2c42683          	lw	a3,-212(s0)
    80005a8a:	fc040613          	addi	a2,s0,-64
    80005a8e:	4581                	li	a1,0
    80005a90:	854e                	mv	a0,s3
    80005a92:	ffffe097          	auipc	ra,0xffffe
    80005a96:	480080e7          	jalr	1152(ra) # 80003f12 <writei>
    80005a9a:	47c1                	li	a5,16
    80005a9c:	0af51363          	bne	a0,a5,80005b42 <sys_unlink+0x178>
  if(ip->type == T_DIR){
    80005aa0:	04c49703          	lh	a4,76(s1)
    80005aa4:	4785                	li	a5,1
    80005aa6:	0af70663          	beq	a4,a5,80005b52 <sys_unlink+0x188>
  iunlockput(dp);
    80005aaa:	854e                	mv	a0,s3
    80005aac:	ffffe097          	auipc	ra,0xffffe
    80005ab0:	31c080e7          	jalr	796(ra) # 80003dc8 <iunlockput>
  ip->nlink--;
    80005ab4:	0524d783          	lhu	a5,82(s1)
    80005ab8:	37fd                	addiw	a5,a5,-1
    80005aba:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005abe:	8526                	mv	a0,s1
    80005ac0:	ffffe097          	auipc	ra,0xffffe
    80005ac4:	fd8080e7          	jalr	-40(ra) # 80003a98 <iupdate>
  iunlockput(ip);
    80005ac8:	8526                	mv	a0,s1
    80005aca:	ffffe097          	auipc	ra,0xffffe
    80005ace:	2fe080e7          	jalr	766(ra) # 80003dc8 <iunlockput>
  end_op();
    80005ad2:	fffff097          	auipc	ra,0xfffff
    80005ad6:	aee080e7          	jalr	-1298(ra) # 800045c0 <end_op>
  return 0;
    80005ada:	4501                	li	a0,0
    80005adc:	a07d                	j	80005b8a <sys_unlink+0x1c0>
    end_op();
    80005ade:	fffff097          	auipc	ra,0xfffff
    80005ae2:	ae2080e7          	jalr	-1310(ra) # 800045c0 <end_op>
    return -1;
    80005ae6:	557d                	li	a0,-1
    80005ae8:	a04d                	j	80005b8a <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    80005aea:	00003517          	auipc	a0,0x3
    80005aee:	cd650513          	addi	a0,a0,-810 # 800087c0 <syscalls+0x330>
    80005af2:	ffffb097          	auipc	ra,0xffffb
    80005af6:	a86080e7          	jalr	-1402(ra) # 80000578 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005afa:	48f8                	lw	a4,84(s1)
    80005afc:	02000793          	li	a5,32
    80005b00:	f6e7fae3          	bleu	a4,a5,80005a74 <sys_unlink+0xaa>
    80005b04:	02000913          	li	s2,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b08:	4741                	li	a4,16
    80005b0a:	86ca                	mv	a3,s2
    80005b0c:	f1840613          	addi	a2,s0,-232
    80005b10:	4581                	li	a1,0
    80005b12:	8526                	mv	a0,s1
    80005b14:	ffffe097          	auipc	ra,0xffffe
    80005b18:	306080e7          	jalr	774(ra) # 80003e1a <readi>
    80005b1c:	47c1                	li	a5,16
    80005b1e:	00f51a63          	bne	a0,a5,80005b32 <sys_unlink+0x168>
    if(de.inum != 0)
    80005b22:	f1845783          	lhu	a5,-232(s0)
    80005b26:	e3b9                	bnez	a5,80005b6c <sys_unlink+0x1a2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b28:	2941                	addiw	s2,s2,16
    80005b2a:	48fc                	lw	a5,84(s1)
    80005b2c:	fcf96ee3          	bltu	s2,a5,80005b08 <sys_unlink+0x13e>
    80005b30:	b791                	j	80005a74 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b32:	00003517          	auipc	a0,0x3
    80005b36:	ca650513          	addi	a0,a0,-858 # 800087d8 <syscalls+0x348>
    80005b3a:	ffffb097          	auipc	ra,0xffffb
    80005b3e:	a3e080e7          	jalr	-1474(ra) # 80000578 <panic>
    panic("unlink: writei");
    80005b42:	00003517          	auipc	a0,0x3
    80005b46:	cae50513          	addi	a0,a0,-850 # 800087f0 <syscalls+0x360>
    80005b4a:	ffffb097          	auipc	ra,0xffffb
    80005b4e:	a2e080e7          	jalr	-1490(ra) # 80000578 <panic>
    dp->nlink--;
    80005b52:	0529d783          	lhu	a5,82(s3)
    80005b56:	37fd                	addiw	a5,a5,-1
    80005b58:	04f99923          	sh	a5,82(s3)
    iupdate(dp);
    80005b5c:	854e                	mv	a0,s3
    80005b5e:	ffffe097          	auipc	ra,0xffffe
    80005b62:	f3a080e7          	jalr	-198(ra) # 80003a98 <iupdate>
    80005b66:	b791                	j	80005aaa <sys_unlink+0xe0>
    return -1;
    80005b68:	557d                	li	a0,-1
    80005b6a:	a005                	j	80005b8a <sys_unlink+0x1c0>
    iunlockput(ip);
    80005b6c:	8526                	mv	a0,s1
    80005b6e:	ffffe097          	auipc	ra,0xffffe
    80005b72:	25a080e7          	jalr	602(ra) # 80003dc8 <iunlockput>
  iunlockput(dp);
    80005b76:	854e                	mv	a0,s3
    80005b78:	ffffe097          	auipc	ra,0xffffe
    80005b7c:	250080e7          	jalr	592(ra) # 80003dc8 <iunlockput>
  end_op();
    80005b80:	fffff097          	auipc	ra,0xfffff
    80005b84:	a40080e7          	jalr	-1472(ra) # 800045c0 <end_op>
  return -1;
    80005b88:	557d                	li	a0,-1
}
    80005b8a:	70ae                	ld	ra,232(sp)
    80005b8c:	740e                	ld	s0,224(sp)
    80005b8e:	64ee                	ld	s1,216(sp)
    80005b90:	694e                	ld	s2,208(sp)
    80005b92:	69ae                	ld	s3,200(sp)
    80005b94:	616d                	addi	sp,sp,240
    80005b96:	8082                	ret

0000000080005b98 <sys_open>:

uint64
sys_open(void)
{
    80005b98:	7131                	addi	sp,sp,-192
    80005b9a:	fd06                	sd	ra,184(sp)
    80005b9c:	f922                	sd	s0,176(sp)
    80005b9e:	f526                	sd	s1,168(sp)
    80005ba0:	f14a                	sd	s2,160(sp)
    80005ba2:	ed4e                	sd	s3,152(sp)
    80005ba4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005ba6:	08000613          	li	a2,128
    80005baa:	f5040593          	addi	a1,s0,-176
    80005bae:	4501                	li	a0,0
    80005bb0:	ffffd097          	auipc	ra,0xffffd
    80005bb4:	38e080e7          	jalr	910(ra) # 80002f3e <argstr>
    return -1;
    80005bb8:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005bba:	0c054163          	bltz	a0,80005c7c <sys_open+0xe4>
    80005bbe:	f4c40593          	addi	a1,s0,-180
    80005bc2:	4505                	li	a0,1
    80005bc4:	ffffd097          	auipc	ra,0xffffd
    80005bc8:	336080e7          	jalr	822(ra) # 80002efa <argint>
    80005bcc:	0a054863          	bltz	a0,80005c7c <sys_open+0xe4>

  begin_op();
    80005bd0:	fffff097          	auipc	ra,0xfffff
    80005bd4:	970080e7          	jalr	-1680(ra) # 80004540 <begin_op>

  if(omode & O_CREATE){
    80005bd8:	f4c42783          	lw	a5,-180(s0)
    80005bdc:	2007f793          	andi	a5,a5,512
    80005be0:	cbdd                	beqz	a5,80005c96 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005be2:	4681                	li	a3,0
    80005be4:	4601                	li	a2,0
    80005be6:	4589                	li	a1,2
    80005be8:	f5040513          	addi	a0,s0,-176
    80005bec:	00000097          	auipc	ra,0x0
    80005bf0:	976080e7          	jalr	-1674(ra) # 80005562 <create>
    80005bf4:	892a                	mv	s2,a0
    if(ip == 0){
    80005bf6:	c959                	beqz	a0,80005c8c <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005bf8:	04c91703          	lh	a4,76(s2)
    80005bfc:	478d                	li	a5,3
    80005bfe:	00f71763          	bne	a4,a5,80005c0c <sys_open+0x74>
    80005c02:	04e95703          	lhu	a4,78(s2)
    80005c06:	47a5                	li	a5,9
    80005c08:	0ce7ec63          	bltu	a5,a4,80005ce0 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c0c:	fffff097          	auipc	ra,0xfffff
    80005c10:	d68080e7          	jalr	-664(ra) # 80004974 <filealloc>
    80005c14:	89aa                	mv	s3,a0
    80005c16:	10050263          	beqz	a0,80005d1a <sys_open+0x182>
    80005c1a:	00000097          	auipc	ra,0x0
    80005c1e:	900080e7          	jalr	-1792(ra) # 8000551a <fdalloc>
    80005c22:	84aa                	mv	s1,a0
    80005c24:	0e054663          	bltz	a0,80005d10 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c28:	04c91703          	lh	a4,76(s2)
    80005c2c:	478d                	li	a5,3
    80005c2e:	0cf70463          	beq	a4,a5,80005cf6 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c32:	4789                	li	a5,2
    80005c34:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c38:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c3c:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c40:	f4c42783          	lw	a5,-180(s0)
    80005c44:	0017c713          	xori	a4,a5,1
    80005c48:	8b05                	andi	a4,a4,1
    80005c4a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c4e:	0037f713          	andi	a4,a5,3
    80005c52:	00e03733          	snez	a4,a4
    80005c56:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c5a:	4007f793          	andi	a5,a5,1024
    80005c5e:	c791                	beqz	a5,80005c6a <sys_open+0xd2>
    80005c60:	04c91703          	lh	a4,76(s2)
    80005c64:	4789                	li	a5,2
    80005c66:	08f70f63          	beq	a4,a5,80005d04 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c6a:	854a                	mv	a0,s2
    80005c6c:	ffffe097          	auipc	ra,0xffffe
    80005c70:	fbc080e7          	jalr	-68(ra) # 80003c28 <iunlock>
  end_op();
    80005c74:	fffff097          	auipc	ra,0xfffff
    80005c78:	94c080e7          	jalr	-1716(ra) # 800045c0 <end_op>

  return fd;
}
    80005c7c:	8526                	mv	a0,s1
    80005c7e:	70ea                	ld	ra,184(sp)
    80005c80:	744a                	ld	s0,176(sp)
    80005c82:	74aa                	ld	s1,168(sp)
    80005c84:	790a                	ld	s2,160(sp)
    80005c86:	69ea                	ld	s3,152(sp)
    80005c88:	6129                	addi	sp,sp,192
    80005c8a:	8082                	ret
      end_op();
    80005c8c:	fffff097          	auipc	ra,0xfffff
    80005c90:	934080e7          	jalr	-1740(ra) # 800045c0 <end_op>
      return -1;
    80005c94:	b7e5                	j	80005c7c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005c96:	f5040513          	addi	a0,s0,-176
    80005c9a:	ffffe097          	auipc	ra,0xffffe
    80005c9e:	688080e7          	jalr	1672(ra) # 80004322 <namei>
    80005ca2:	892a                	mv	s2,a0
    80005ca4:	c905                	beqz	a0,80005cd4 <sys_open+0x13c>
    ilock(ip);
    80005ca6:	ffffe097          	auipc	ra,0xffffe
    80005caa:	ebe080e7          	jalr	-322(ra) # 80003b64 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005cae:	04c91703          	lh	a4,76(s2)
    80005cb2:	4785                	li	a5,1
    80005cb4:	f4f712e3          	bne	a4,a5,80005bf8 <sys_open+0x60>
    80005cb8:	f4c42783          	lw	a5,-180(s0)
    80005cbc:	dba1                	beqz	a5,80005c0c <sys_open+0x74>
      iunlockput(ip);
    80005cbe:	854a                	mv	a0,s2
    80005cc0:	ffffe097          	auipc	ra,0xffffe
    80005cc4:	108080e7          	jalr	264(ra) # 80003dc8 <iunlockput>
      end_op();
    80005cc8:	fffff097          	auipc	ra,0xfffff
    80005ccc:	8f8080e7          	jalr	-1800(ra) # 800045c0 <end_op>
      return -1;
    80005cd0:	54fd                	li	s1,-1
    80005cd2:	b76d                	j	80005c7c <sys_open+0xe4>
      end_op();
    80005cd4:	fffff097          	auipc	ra,0xfffff
    80005cd8:	8ec080e7          	jalr	-1812(ra) # 800045c0 <end_op>
      return -1;
    80005cdc:	54fd                	li	s1,-1
    80005cde:	bf79                	j	80005c7c <sys_open+0xe4>
    iunlockput(ip);
    80005ce0:	854a                	mv	a0,s2
    80005ce2:	ffffe097          	auipc	ra,0xffffe
    80005ce6:	0e6080e7          	jalr	230(ra) # 80003dc8 <iunlockput>
    end_op();
    80005cea:	fffff097          	auipc	ra,0xfffff
    80005cee:	8d6080e7          	jalr	-1834(ra) # 800045c0 <end_op>
    return -1;
    80005cf2:	54fd                	li	s1,-1
    80005cf4:	b761                	j	80005c7c <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005cf6:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005cfa:	04e91783          	lh	a5,78(s2)
    80005cfe:	02f99223          	sh	a5,36(s3)
    80005d02:	bf2d                	j	80005c3c <sys_open+0xa4>
    itrunc(ip);
    80005d04:	854a                	mv	a0,s2
    80005d06:	ffffe097          	auipc	ra,0xffffe
    80005d0a:	f6e080e7          	jalr	-146(ra) # 80003c74 <itrunc>
    80005d0e:	bfb1                	j	80005c6a <sys_open+0xd2>
      fileclose(f);
    80005d10:	854e                	mv	a0,s3
    80005d12:	fffff097          	auipc	ra,0xfffff
    80005d16:	d32080e7          	jalr	-718(ra) # 80004a44 <fileclose>
    iunlockput(ip);
    80005d1a:	854a                	mv	a0,s2
    80005d1c:	ffffe097          	auipc	ra,0xffffe
    80005d20:	0ac080e7          	jalr	172(ra) # 80003dc8 <iunlockput>
    end_op();
    80005d24:	fffff097          	auipc	ra,0xfffff
    80005d28:	89c080e7          	jalr	-1892(ra) # 800045c0 <end_op>
    return -1;
    80005d2c:	54fd                	li	s1,-1
    80005d2e:	b7b9                	j	80005c7c <sys_open+0xe4>

0000000080005d30 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d30:	7175                	addi	sp,sp,-144
    80005d32:	e506                	sd	ra,136(sp)
    80005d34:	e122                	sd	s0,128(sp)
    80005d36:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d38:	fffff097          	auipc	ra,0xfffff
    80005d3c:	808080e7          	jalr	-2040(ra) # 80004540 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d40:	08000613          	li	a2,128
    80005d44:	f7040593          	addi	a1,s0,-144
    80005d48:	4501                	li	a0,0
    80005d4a:	ffffd097          	auipc	ra,0xffffd
    80005d4e:	1f4080e7          	jalr	500(ra) # 80002f3e <argstr>
    80005d52:	02054963          	bltz	a0,80005d84 <sys_mkdir+0x54>
    80005d56:	4681                	li	a3,0
    80005d58:	4601                	li	a2,0
    80005d5a:	4585                	li	a1,1
    80005d5c:	f7040513          	addi	a0,s0,-144
    80005d60:	00000097          	auipc	ra,0x0
    80005d64:	802080e7          	jalr	-2046(ra) # 80005562 <create>
    80005d68:	cd11                	beqz	a0,80005d84 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d6a:	ffffe097          	auipc	ra,0xffffe
    80005d6e:	05e080e7          	jalr	94(ra) # 80003dc8 <iunlockput>
  end_op();
    80005d72:	fffff097          	auipc	ra,0xfffff
    80005d76:	84e080e7          	jalr	-1970(ra) # 800045c0 <end_op>
  return 0;
    80005d7a:	4501                	li	a0,0
}
    80005d7c:	60aa                	ld	ra,136(sp)
    80005d7e:	640a                	ld	s0,128(sp)
    80005d80:	6149                	addi	sp,sp,144
    80005d82:	8082                	ret
    end_op();
    80005d84:	fffff097          	auipc	ra,0xfffff
    80005d88:	83c080e7          	jalr	-1988(ra) # 800045c0 <end_op>
    return -1;
    80005d8c:	557d                	li	a0,-1
    80005d8e:	b7fd                	j	80005d7c <sys_mkdir+0x4c>

0000000080005d90 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d90:	7135                	addi	sp,sp,-160
    80005d92:	ed06                	sd	ra,152(sp)
    80005d94:	e922                	sd	s0,144(sp)
    80005d96:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d98:	ffffe097          	auipc	ra,0xffffe
    80005d9c:	7a8080e7          	jalr	1960(ra) # 80004540 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005da0:	08000613          	li	a2,128
    80005da4:	f7040593          	addi	a1,s0,-144
    80005da8:	4501                	li	a0,0
    80005daa:	ffffd097          	auipc	ra,0xffffd
    80005dae:	194080e7          	jalr	404(ra) # 80002f3e <argstr>
    80005db2:	04054a63          	bltz	a0,80005e06 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005db6:	f6c40593          	addi	a1,s0,-148
    80005dba:	4505                	li	a0,1
    80005dbc:	ffffd097          	auipc	ra,0xffffd
    80005dc0:	13e080e7          	jalr	318(ra) # 80002efa <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005dc4:	04054163          	bltz	a0,80005e06 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005dc8:	f6840593          	addi	a1,s0,-152
    80005dcc:	4509                	li	a0,2
    80005dce:	ffffd097          	auipc	ra,0xffffd
    80005dd2:	12c080e7          	jalr	300(ra) # 80002efa <argint>
     argint(1, &major) < 0 ||
    80005dd6:	02054863          	bltz	a0,80005e06 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005dda:	f6841683          	lh	a3,-152(s0)
    80005dde:	f6c41603          	lh	a2,-148(s0)
    80005de2:	458d                	li	a1,3
    80005de4:	f7040513          	addi	a0,s0,-144
    80005de8:	fffff097          	auipc	ra,0xfffff
    80005dec:	77a080e7          	jalr	1914(ra) # 80005562 <create>
     argint(2, &minor) < 0 ||
    80005df0:	c919                	beqz	a0,80005e06 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005df2:	ffffe097          	auipc	ra,0xffffe
    80005df6:	fd6080e7          	jalr	-42(ra) # 80003dc8 <iunlockput>
  end_op();
    80005dfa:	ffffe097          	auipc	ra,0xffffe
    80005dfe:	7c6080e7          	jalr	1990(ra) # 800045c0 <end_op>
  return 0;
    80005e02:	4501                	li	a0,0
    80005e04:	a031                	j	80005e10 <sys_mknod+0x80>
    end_op();
    80005e06:	ffffe097          	auipc	ra,0xffffe
    80005e0a:	7ba080e7          	jalr	1978(ra) # 800045c0 <end_op>
    return -1;
    80005e0e:	557d                	li	a0,-1
}
    80005e10:	60ea                	ld	ra,152(sp)
    80005e12:	644a                	ld	s0,144(sp)
    80005e14:	610d                	addi	sp,sp,160
    80005e16:	8082                	ret

0000000080005e18 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e18:	7135                	addi	sp,sp,-160
    80005e1a:	ed06                	sd	ra,152(sp)
    80005e1c:	e922                	sd	s0,144(sp)
    80005e1e:	e526                	sd	s1,136(sp)
    80005e20:	e14a                	sd	s2,128(sp)
    80005e22:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e24:	ffffc097          	auipc	ra,0xffffc
    80005e28:	006080e7          	jalr	6(ra) # 80001e2a <myproc>
    80005e2c:	892a                	mv	s2,a0
  
  begin_op();
    80005e2e:	ffffe097          	auipc	ra,0xffffe
    80005e32:	712080e7          	jalr	1810(ra) # 80004540 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e36:	08000613          	li	a2,128
    80005e3a:	f6040593          	addi	a1,s0,-160
    80005e3e:	4501                	li	a0,0
    80005e40:	ffffd097          	auipc	ra,0xffffd
    80005e44:	0fe080e7          	jalr	254(ra) # 80002f3e <argstr>
    80005e48:	04054b63          	bltz	a0,80005e9e <sys_chdir+0x86>
    80005e4c:	f6040513          	addi	a0,s0,-160
    80005e50:	ffffe097          	auipc	ra,0xffffe
    80005e54:	4d2080e7          	jalr	1234(ra) # 80004322 <namei>
    80005e58:	84aa                	mv	s1,a0
    80005e5a:	c131                	beqz	a0,80005e9e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e5c:	ffffe097          	auipc	ra,0xffffe
    80005e60:	d08080e7          	jalr	-760(ra) # 80003b64 <ilock>
  if(ip->type != T_DIR){
    80005e64:	04c49703          	lh	a4,76(s1)
    80005e68:	4785                	li	a5,1
    80005e6a:	04f71063          	bne	a4,a5,80005eaa <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e6e:	8526                	mv	a0,s1
    80005e70:	ffffe097          	auipc	ra,0xffffe
    80005e74:	db8080e7          	jalr	-584(ra) # 80003c28 <iunlock>
  iput(p->cwd);
    80005e78:	15893503          	ld	a0,344(s2)
    80005e7c:	ffffe097          	auipc	ra,0xffffe
    80005e80:	ea4080e7          	jalr	-348(ra) # 80003d20 <iput>
  end_op();
    80005e84:	ffffe097          	auipc	ra,0xffffe
    80005e88:	73c080e7          	jalr	1852(ra) # 800045c0 <end_op>
  p->cwd = ip;
    80005e8c:	14993c23          	sd	s1,344(s2)
  return 0;
    80005e90:	4501                	li	a0,0
}
    80005e92:	60ea                	ld	ra,152(sp)
    80005e94:	644a                	ld	s0,144(sp)
    80005e96:	64aa                	ld	s1,136(sp)
    80005e98:	690a                	ld	s2,128(sp)
    80005e9a:	610d                	addi	sp,sp,160
    80005e9c:	8082                	ret
    end_op();
    80005e9e:	ffffe097          	auipc	ra,0xffffe
    80005ea2:	722080e7          	jalr	1826(ra) # 800045c0 <end_op>
    return -1;
    80005ea6:	557d                	li	a0,-1
    80005ea8:	b7ed                	j	80005e92 <sys_chdir+0x7a>
    iunlockput(ip);
    80005eaa:	8526                	mv	a0,s1
    80005eac:	ffffe097          	auipc	ra,0xffffe
    80005eb0:	f1c080e7          	jalr	-228(ra) # 80003dc8 <iunlockput>
    end_op();
    80005eb4:	ffffe097          	auipc	ra,0xffffe
    80005eb8:	70c080e7          	jalr	1804(ra) # 800045c0 <end_op>
    return -1;
    80005ebc:	557d                	li	a0,-1
    80005ebe:	bfd1                	j	80005e92 <sys_chdir+0x7a>

0000000080005ec0 <sys_exec>:

uint64
sys_exec(void)
{
    80005ec0:	7145                	addi	sp,sp,-464
    80005ec2:	e786                	sd	ra,456(sp)
    80005ec4:	e3a2                	sd	s0,448(sp)
    80005ec6:	ff26                	sd	s1,440(sp)
    80005ec8:	fb4a                	sd	s2,432(sp)
    80005eca:	f74e                	sd	s3,424(sp)
    80005ecc:	f352                	sd	s4,416(sp)
    80005ece:	ef56                	sd	s5,408(sp)
    80005ed0:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005ed2:	08000613          	li	a2,128
    80005ed6:	f4040593          	addi	a1,s0,-192
    80005eda:	4501                	li	a0,0
    80005edc:	ffffd097          	auipc	ra,0xffffd
    80005ee0:	062080e7          	jalr	98(ra) # 80002f3e <argstr>
    return -1;
    80005ee4:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005ee6:	0e054c63          	bltz	a0,80005fde <sys_exec+0x11e>
    80005eea:	e3840593          	addi	a1,s0,-456
    80005eee:	4505                	li	a0,1
    80005ef0:	ffffd097          	auipc	ra,0xffffd
    80005ef4:	02c080e7          	jalr	44(ra) # 80002f1c <argaddr>
    80005ef8:	0e054363          	bltz	a0,80005fde <sys_exec+0x11e>
  }
  memset(argv, 0, sizeof(argv));
    80005efc:	e4040913          	addi	s2,s0,-448
    80005f00:	10000613          	li	a2,256
    80005f04:	4581                	li	a1,0
    80005f06:	854a                	mv	a0,s2
    80005f08:	ffffb097          	auipc	ra,0xffffb
    80005f0c:	27e080e7          	jalr	638(ra) # 80001186 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f10:	89ca                	mv	s3,s2
  memset(argv, 0, sizeof(argv));
    80005f12:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005f14:	02000a93          	li	s5,32
    80005f18:	00048a1b          	sext.w	s4,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f1c:	00349513          	slli	a0,s1,0x3
    80005f20:	e3040593          	addi	a1,s0,-464
    80005f24:	e3843783          	ld	a5,-456(s0)
    80005f28:	953e                	add	a0,a0,a5
    80005f2a:	ffffd097          	auipc	ra,0xffffd
    80005f2e:	f34080e7          	jalr	-204(ra) # 80002e5e <fetchaddr>
    80005f32:	02054a63          	bltz	a0,80005f66 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005f36:	e3043783          	ld	a5,-464(s0)
    80005f3a:	cfa9                	beqz	a5,80005f94 <sys_exec+0xd4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f3c:	ffffb097          	auipc	ra,0xffffb
    80005f40:	d2e080e7          	jalr	-722(ra) # 80000c6a <kalloc>
    80005f44:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80005f48:	cd19                	beqz	a0,80005f66 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f4a:	6605                	lui	a2,0x1
    80005f4c:	85aa                	mv	a1,a0
    80005f4e:	e3043503          	ld	a0,-464(s0)
    80005f52:	ffffd097          	auipc	ra,0xffffd
    80005f56:	f60080e7          	jalr	-160(ra) # 80002eb2 <fetchstr>
    80005f5a:	00054663          	bltz	a0,80005f66 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005f5e:	0485                	addi	s1,s1,1
    80005f60:	0921                	addi	s2,s2,8
    80005f62:	fb549be3          	bne	s1,s5,80005f18 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f66:	e4043503          	ld	a0,-448(s0)
    kfree(argv[i]);
  return -1;
    80005f6a:	597d                	li	s2,-1
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f6c:	c92d                	beqz	a0,80005fde <sys_exec+0x11e>
    kfree(argv[i]);
    80005f6e:	ffffb097          	auipc	ra,0xffffb
    80005f72:	b08080e7          	jalr	-1272(ra) # 80000a76 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f76:	e4840493          	addi	s1,s0,-440
    80005f7a:	10098993          	addi	s3,s3,256
    80005f7e:	6088                	ld	a0,0(s1)
    80005f80:	cd31                	beqz	a0,80005fdc <sys_exec+0x11c>
    kfree(argv[i]);
    80005f82:	ffffb097          	auipc	ra,0xffffb
    80005f86:	af4080e7          	jalr	-1292(ra) # 80000a76 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f8a:	04a1                	addi	s1,s1,8
    80005f8c:	ff3499e3          	bne	s1,s3,80005f7e <sys_exec+0xbe>
  return -1;
    80005f90:	597d                	li	s2,-1
    80005f92:	a0b1                	j	80005fde <sys_exec+0x11e>
      argv[i] = 0;
    80005f94:	0a0e                	slli	s4,s4,0x3
    80005f96:	fc040793          	addi	a5,s0,-64
    80005f9a:	9a3e                	add	s4,s4,a5
    80005f9c:	e80a3023          	sd	zero,-384(s4)
  int ret = exec(path, argv);
    80005fa0:	e4040593          	addi	a1,s0,-448
    80005fa4:	f4040513          	addi	a0,s0,-192
    80005fa8:	fffff097          	auipc	ra,0xfffff
    80005fac:	166080e7          	jalr	358(ra) # 8000510e <exec>
    80005fb0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fb2:	e4043503          	ld	a0,-448(s0)
    80005fb6:	c505                	beqz	a0,80005fde <sys_exec+0x11e>
    kfree(argv[i]);
    80005fb8:	ffffb097          	auipc	ra,0xffffb
    80005fbc:	abe080e7          	jalr	-1346(ra) # 80000a76 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fc0:	e4840493          	addi	s1,s0,-440
    80005fc4:	10098993          	addi	s3,s3,256
    80005fc8:	6088                	ld	a0,0(s1)
    80005fca:	c911                	beqz	a0,80005fde <sys_exec+0x11e>
    kfree(argv[i]);
    80005fcc:	ffffb097          	auipc	ra,0xffffb
    80005fd0:	aaa080e7          	jalr	-1366(ra) # 80000a76 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fd4:	04a1                	addi	s1,s1,8
    80005fd6:	ff3499e3          	bne	s1,s3,80005fc8 <sys_exec+0x108>
    80005fda:	a011                	j	80005fde <sys_exec+0x11e>
  return -1;
    80005fdc:	597d                	li	s2,-1
}
    80005fde:	854a                	mv	a0,s2
    80005fe0:	60be                	ld	ra,456(sp)
    80005fe2:	641e                	ld	s0,448(sp)
    80005fe4:	74fa                	ld	s1,440(sp)
    80005fe6:	795a                	ld	s2,432(sp)
    80005fe8:	79ba                	ld	s3,424(sp)
    80005fea:	7a1a                	ld	s4,416(sp)
    80005fec:	6afa                	ld	s5,408(sp)
    80005fee:	6179                	addi	sp,sp,464
    80005ff0:	8082                	ret

0000000080005ff2 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ff2:	7139                	addi	sp,sp,-64
    80005ff4:	fc06                	sd	ra,56(sp)
    80005ff6:	f822                	sd	s0,48(sp)
    80005ff8:	f426                	sd	s1,40(sp)
    80005ffa:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ffc:	ffffc097          	auipc	ra,0xffffc
    80006000:	e2e080e7          	jalr	-466(ra) # 80001e2a <myproc>
    80006004:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006006:	fd840593          	addi	a1,s0,-40
    8000600a:	4501                	li	a0,0
    8000600c:	ffffd097          	auipc	ra,0xffffd
    80006010:	f10080e7          	jalr	-240(ra) # 80002f1c <argaddr>
    return -1;
    80006014:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006016:	0c054f63          	bltz	a0,800060f4 <sys_pipe+0x102>
  if(pipealloc(&rf, &wf) < 0)
    8000601a:	fc840593          	addi	a1,s0,-56
    8000601e:	fd040513          	addi	a0,s0,-48
    80006022:	fffff097          	auipc	ra,0xfffff
    80006026:	d6a080e7          	jalr	-662(ra) # 80004d8c <pipealloc>
    return -1;
    8000602a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000602c:	0c054463          	bltz	a0,800060f4 <sys_pipe+0x102>
  fd0 = -1;
    80006030:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006034:	fd043503          	ld	a0,-48(s0)
    80006038:	fffff097          	auipc	ra,0xfffff
    8000603c:	4e2080e7          	jalr	1250(ra) # 8000551a <fdalloc>
    80006040:	fca42223          	sw	a0,-60(s0)
    80006044:	08054b63          	bltz	a0,800060da <sys_pipe+0xe8>
    80006048:	fc843503          	ld	a0,-56(s0)
    8000604c:	fffff097          	auipc	ra,0xfffff
    80006050:	4ce080e7          	jalr	1230(ra) # 8000551a <fdalloc>
    80006054:	fca42023          	sw	a0,-64(s0)
    80006058:	06054863          	bltz	a0,800060c8 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000605c:	4691                	li	a3,4
    8000605e:	fc440613          	addi	a2,s0,-60
    80006062:	fd843583          	ld	a1,-40(s0)
    80006066:	6ca8                	ld	a0,88(s1)
    80006068:	ffffc097          	auipc	ra,0xffffc
    8000606c:	a9e080e7          	jalr	-1378(ra) # 80001b06 <copyout>
    80006070:	02054063          	bltz	a0,80006090 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006074:	4691                	li	a3,4
    80006076:	fc040613          	addi	a2,s0,-64
    8000607a:	fd843583          	ld	a1,-40(s0)
    8000607e:	0591                	addi	a1,a1,4
    80006080:	6ca8                	ld	a0,88(s1)
    80006082:	ffffc097          	auipc	ra,0xffffc
    80006086:	a84080e7          	jalr	-1404(ra) # 80001b06 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000608a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000608c:	06055463          	bgez	a0,800060f4 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80006090:	fc442783          	lw	a5,-60(s0)
    80006094:	07e9                	addi	a5,a5,26
    80006096:	078e                	slli	a5,a5,0x3
    80006098:	97a6                	add	a5,a5,s1
    8000609a:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    8000609e:	fc042783          	lw	a5,-64(s0)
    800060a2:	07e9                	addi	a5,a5,26
    800060a4:	078e                	slli	a5,a5,0x3
    800060a6:	94be                	add	s1,s1,a5
    800060a8:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800060ac:	fd043503          	ld	a0,-48(s0)
    800060b0:	fffff097          	auipc	ra,0xfffff
    800060b4:	994080e7          	jalr	-1644(ra) # 80004a44 <fileclose>
    fileclose(wf);
    800060b8:	fc843503          	ld	a0,-56(s0)
    800060bc:	fffff097          	auipc	ra,0xfffff
    800060c0:	988080e7          	jalr	-1656(ra) # 80004a44 <fileclose>
    return -1;
    800060c4:	57fd                	li	a5,-1
    800060c6:	a03d                	j	800060f4 <sys_pipe+0x102>
    if(fd0 >= 0)
    800060c8:	fc442783          	lw	a5,-60(s0)
    800060cc:	0007c763          	bltz	a5,800060da <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    800060d0:	07e9                	addi	a5,a5,26
    800060d2:	078e                	slli	a5,a5,0x3
    800060d4:	94be                	add	s1,s1,a5
    800060d6:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800060da:	fd043503          	ld	a0,-48(s0)
    800060de:	fffff097          	auipc	ra,0xfffff
    800060e2:	966080e7          	jalr	-1690(ra) # 80004a44 <fileclose>
    fileclose(wf);
    800060e6:	fc843503          	ld	a0,-56(s0)
    800060ea:	fffff097          	auipc	ra,0xfffff
    800060ee:	95a080e7          	jalr	-1702(ra) # 80004a44 <fileclose>
    return -1;
    800060f2:	57fd                	li	a5,-1
}
    800060f4:	853e                	mv	a0,a5
    800060f6:	70e2                	ld	ra,56(sp)
    800060f8:	7442                	ld	s0,48(sp)
    800060fa:	74a2                	ld	s1,40(sp)
    800060fc:	6121                	addi	sp,sp,64
    800060fe:	8082                	ret

0000000080006100 <kernelvec>:
    80006100:	7111                	addi	sp,sp,-256
    80006102:	e006                	sd	ra,0(sp)
    80006104:	e40a                	sd	sp,8(sp)
    80006106:	e80e                	sd	gp,16(sp)
    80006108:	ec12                	sd	tp,24(sp)
    8000610a:	f016                	sd	t0,32(sp)
    8000610c:	f41a                	sd	t1,40(sp)
    8000610e:	f81e                	sd	t2,48(sp)
    80006110:	fc22                	sd	s0,56(sp)
    80006112:	e0a6                	sd	s1,64(sp)
    80006114:	e4aa                	sd	a0,72(sp)
    80006116:	e8ae                	sd	a1,80(sp)
    80006118:	ecb2                	sd	a2,88(sp)
    8000611a:	f0b6                	sd	a3,96(sp)
    8000611c:	f4ba                	sd	a4,104(sp)
    8000611e:	f8be                	sd	a5,112(sp)
    80006120:	fcc2                	sd	a6,120(sp)
    80006122:	e146                	sd	a7,128(sp)
    80006124:	e54a                	sd	s2,136(sp)
    80006126:	e94e                	sd	s3,144(sp)
    80006128:	ed52                	sd	s4,152(sp)
    8000612a:	f156                	sd	s5,160(sp)
    8000612c:	f55a                	sd	s6,168(sp)
    8000612e:	f95e                	sd	s7,176(sp)
    80006130:	fd62                	sd	s8,184(sp)
    80006132:	e1e6                	sd	s9,192(sp)
    80006134:	e5ea                	sd	s10,200(sp)
    80006136:	e9ee                	sd	s11,208(sp)
    80006138:	edf2                	sd	t3,216(sp)
    8000613a:	f1f6                	sd	t4,224(sp)
    8000613c:	f5fa                	sd	t5,232(sp)
    8000613e:	f9fe                	sd	t6,240(sp)
    80006140:	be7fc0ef          	jal	ra,80002d26 <kerneltrap>
    80006144:	6082                	ld	ra,0(sp)
    80006146:	6122                	ld	sp,8(sp)
    80006148:	61c2                	ld	gp,16(sp)
    8000614a:	7282                	ld	t0,32(sp)
    8000614c:	7322                	ld	t1,40(sp)
    8000614e:	73c2                	ld	t2,48(sp)
    80006150:	7462                	ld	s0,56(sp)
    80006152:	6486                	ld	s1,64(sp)
    80006154:	6526                	ld	a0,72(sp)
    80006156:	65c6                	ld	a1,80(sp)
    80006158:	6666                	ld	a2,88(sp)
    8000615a:	7686                	ld	a3,96(sp)
    8000615c:	7726                	ld	a4,104(sp)
    8000615e:	77c6                	ld	a5,112(sp)
    80006160:	7866                	ld	a6,120(sp)
    80006162:	688a                	ld	a7,128(sp)
    80006164:	692a                	ld	s2,136(sp)
    80006166:	69ca                	ld	s3,144(sp)
    80006168:	6a6a                	ld	s4,152(sp)
    8000616a:	7a8a                	ld	s5,160(sp)
    8000616c:	7b2a                	ld	s6,168(sp)
    8000616e:	7bca                	ld	s7,176(sp)
    80006170:	7c6a                	ld	s8,184(sp)
    80006172:	6c8e                	ld	s9,192(sp)
    80006174:	6d2e                	ld	s10,200(sp)
    80006176:	6dce                	ld	s11,208(sp)
    80006178:	6e6e                	ld	t3,216(sp)
    8000617a:	7e8e                	ld	t4,224(sp)
    8000617c:	7f2e                	ld	t5,232(sp)
    8000617e:	7fce                	ld	t6,240(sp)
    80006180:	6111                	addi	sp,sp,256
    80006182:	10200073          	sret
    80006186:	00000013          	nop
    8000618a:	00000013          	nop
    8000618e:	0001                	nop

0000000080006190 <timervec>:
    80006190:	34051573          	csrrw	a0,mscratch,a0
    80006194:	e10c                	sd	a1,0(a0)
    80006196:	e510                	sd	a2,8(a0)
    80006198:	e914                	sd	a3,16(a0)
    8000619a:	6d0c                	ld	a1,24(a0)
    8000619c:	7110                	ld	a2,32(a0)
    8000619e:	6194                	ld	a3,0(a1)
    800061a0:	96b2                	add	a3,a3,a2
    800061a2:	e194                	sd	a3,0(a1)
    800061a4:	4589                	li	a1,2
    800061a6:	14459073          	csrw	sip,a1
    800061aa:	6914                	ld	a3,16(a0)
    800061ac:	6510                	ld	a2,8(a0)
    800061ae:	610c                	ld	a1,0(a0)
    800061b0:	34051573          	csrrw	a0,mscratch,a0
    800061b4:	30200073          	mret
	...

00000000800061ba <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800061ba:	1141                	addi	sp,sp,-16
    800061bc:	e422                	sd	s0,8(sp)
    800061be:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800061c0:	0c0007b7          	lui	a5,0xc000
    800061c4:	4705                	li	a4,1
    800061c6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800061c8:	c3d8                	sw	a4,4(a5)
}
    800061ca:	6422                	ld	s0,8(sp)
    800061cc:	0141                	addi	sp,sp,16
    800061ce:	8082                	ret

00000000800061d0 <plicinithart>:

void
plicinithart(void)
{
    800061d0:	1141                	addi	sp,sp,-16
    800061d2:	e406                	sd	ra,8(sp)
    800061d4:	e022                	sd	s0,0(sp)
    800061d6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061d8:	ffffc097          	auipc	ra,0xffffc
    800061dc:	c26080e7          	jalr	-986(ra) # 80001dfe <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800061e0:	0085171b          	slliw	a4,a0,0x8
    800061e4:	0c0027b7          	lui	a5,0xc002
    800061e8:	97ba                	add	a5,a5,a4
    800061ea:	40200713          	li	a4,1026
    800061ee:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800061f2:	00d5151b          	slliw	a0,a0,0xd
    800061f6:	0c2017b7          	lui	a5,0xc201
    800061fa:	953e                	add	a0,a0,a5
    800061fc:	00052023          	sw	zero,0(a0)
}
    80006200:	60a2                	ld	ra,8(sp)
    80006202:	6402                	ld	s0,0(sp)
    80006204:	0141                	addi	sp,sp,16
    80006206:	8082                	ret

0000000080006208 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006208:	1141                	addi	sp,sp,-16
    8000620a:	e406                	sd	ra,8(sp)
    8000620c:	e022                	sd	s0,0(sp)
    8000620e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006210:	ffffc097          	auipc	ra,0xffffc
    80006214:	bee080e7          	jalr	-1042(ra) # 80001dfe <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006218:	00d5151b          	slliw	a0,a0,0xd
    8000621c:	0c2017b7          	lui	a5,0xc201
    80006220:	97aa                	add	a5,a5,a0
  return irq;
}
    80006222:	43c8                	lw	a0,4(a5)
    80006224:	60a2                	ld	ra,8(sp)
    80006226:	6402                	ld	s0,0(sp)
    80006228:	0141                	addi	sp,sp,16
    8000622a:	8082                	ret

000000008000622c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000622c:	1101                	addi	sp,sp,-32
    8000622e:	ec06                	sd	ra,24(sp)
    80006230:	e822                	sd	s0,16(sp)
    80006232:	e426                	sd	s1,8(sp)
    80006234:	1000                	addi	s0,sp,32
    80006236:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006238:	ffffc097          	auipc	ra,0xffffc
    8000623c:	bc6080e7          	jalr	-1082(ra) # 80001dfe <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006240:	00d5151b          	slliw	a0,a0,0xd
    80006244:	0c2017b7          	lui	a5,0xc201
    80006248:	97aa                	add	a5,a5,a0
    8000624a:	c3c4                	sw	s1,4(a5)
}
    8000624c:	60e2                	ld	ra,24(sp)
    8000624e:	6442                	ld	s0,16(sp)
    80006250:	64a2                	ld	s1,8(sp)
    80006252:	6105                	addi	sp,sp,32
    80006254:	8082                	ret

0000000080006256 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006256:	1141                	addi	sp,sp,-16
    80006258:	e406                	sd	ra,8(sp)
    8000625a:	e022                	sd	s0,0(sp)
    8000625c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000625e:	479d                	li	a5,7
    80006260:	06a7c963          	blt	a5,a0,800062d2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006264:	00028797          	auipc	a5,0x28
    80006268:	d9c78793          	addi	a5,a5,-612 # 8002e000 <disk>
    8000626c:	00a78733          	add	a4,a5,a0
    80006270:	6789                	lui	a5,0x2
    80006272:	97ba                	add	a5,a5,a4
    80006274:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006278:	e7ad                	bnez	a5,800062e2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000627a:	00451793          	slli	a5,a0,0x4
    8000627e:	0002a717          	auipc	a4,0x2a
    80006282:	d8270713          	addi	a4,a4,-638 # 80030000 <disk+0x2000>
    80006286:	6314                	ld	a3,0(a4)
    80006288:	96be                	add	a3,a3,a5
    8000628a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000628e:	6314                	ld	a3,0(a4)
    80006290:	96be                	add	a3,a3,a5
    80006292:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006296:	6314                	ld	a3,0(a4)
    80006298:	96be                	add	a3,a3,a5
    8000629a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000629e:	6318                	ld	a4,0(a4)
    800062a0:	97ba                	add	a5,a5,a4
    800062a2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800062a6:	00028797          	auipc	a5,0x28
    800062aa:	d5a78793          	addi	a5,a5,-678 # 8002e000 <disk>
    800062ae:	97aa                	add	a5,a5,a0
    800062b0:	6509                	lui	a0,0x2
    800062b2:	953e                	add	a0,a0,a5
    800062b4:	4785                	li	a5,1
    800062b6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800062ba:	0002a517          	auipc	a0,0x2a
    800062be:	d5e50513          	addi	a0,a0,-674 # 80030018 <disk+0x2018>
    800062c2:	ffffc097          	auipc	ra,0xffffc
    800062c6:	508080e7          	jalr	1288(ra) # 800027ca <wakeup>
}
    800062ca:	60a2                	ld	ra,8(sp)
    800062cc:	6402                	ld	s0,0(sp)
    800062ce:	0141                	addi	sp,sp,16
    800062d0:	8082                	ret
    panic("free_desc 1");
    800062d2:	00002517          	auipc	a0,0x2
    800062d6:	52e50513          	addi	a0,a0,1326 # 80008800 <syscalls+0x370>
    800062da:	ffffa097          	auipc	ra,0xffffa
    800062de:	29e080e7          	jalr	670(ra) # 80000578 <panic>
    panic("free_desc 2");
    800062e2:	00002517          	auipc	a0,0x2
    800062e6:	52e50513          	addi	a0,a0,1326 # 80008810 <syscalls+0x380>
    800062ea:	ffffa097          	auipc	ra,0xffffa
    800062ee:	28e080e7          	jalr	654(ra) # 80000578 <panic>

00000000800062f2 <virtio_disk_init>:
{
    800062f2:	1101                	addi	sp,sp,-32
    800062f4:	ec06                	sd	ra,24(sp)
    800062f6:	e822                	sd	s0,16(sp)
    800062f8:	e426                	sd	s1,8(sp)
    800062fa:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800062fc:	00002597          	auipc	a1,0x2
    80006300:	52458593          	addi	a1,a1,1316 # 80008820 <syscalls+0x390>
    80006304:	0002a517          	auipc	a0,0x2a
    80006308:	e2450513          	addi	a0,a0,-476 # 80030128 <disk+0x2128>
    8000630c:	ffffb097          	auipc	ra,0xffffb
    80006310:	bfa080e7          	jalr	-1030(ra) # 80000f06 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006314:	100017b7          	lui	a5,0x10001
    80006318:	4398                	lw	a4,0(a5)
    8000631a:	2701                	sext.w	a4,a4
    8000631c:	747277b7          	lui	a5,0x74727
    80006320:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006324:	0ef71163          	bne	a4,a5,80006406 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006328:	100017b7          	lui	a5,0x10001
    8000632c:	43dc                	lw	a5,4(a5)
    8000632e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006330:	4705                	li	a4,1
    80006332:	0ce79a63          	bne	a5,a4,80006406 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006336:	100017b7          	lui	a5,0x10001
    8000633a:	479c                	lw	a5,8(a5)
    8000633c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000633e:	4709                	li	a4,2
    80006340:	0ce79363          	bne	a5,a4,80006406 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006344:	100017b7          	lui	a5,0x10001
    80006348:	47d8                	lw	a4,12(a5)
    8000634a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000634c:	554d47b7          	lui	a5,0x554d4
    80006350:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006354:	0af71963          	bne	a4,a5,80006406 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006358:	100017b7          	lui	a5,0x10001
    8000635c:	4705                	li	a4,1
    8000635e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006360:	470d                	li	a4,3
    80006362:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006364:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006366:	c7ffe737          	lui	a4,0xc7ffe
    8000636a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fcc737>
    8000636e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006370:	2701                	sext.w	a4,a4
    80006372:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006374:	472d                	li	a4,11
    80006376:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006378:	473d                	li	a4,15
    8000637a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000637c:	6705                	lui	a4,0x1
    8000637e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006380:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006384:	5bdc                	lw	a5,52(a5)
    80006386:	2781                	sext.w	a5,a5
  if(max == 0)
    80006388:	c7d9                	beqz	a5,80006416 <virtio_disk_init+0x124>
  if(max < NUM)
    8000638a:	471d                	li	a4,7
    8000638c:	08f77d63          	bleu	a5,a4,80006426 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006390:	100014b7          	lui	s1,0x10001
    80006394:	47a1                	li	a5,8
    80006396:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006398:	6609                	lui	a2,0x2
    8000639a:	4581                	li	a1,0
    8000639c:	00028517          	auipc	a0,0x28
    800063a0:	c6450513          	addi	a0,a0,-924 # 8002e000 <disk>
    800063a4:	ffffb097          	auipc	ra,0xffffb
    800063a8:	de2080e7          	jalr	-542(ra) # 80001186 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800063ac:	00028717          	auipc	a4,0x28
    800063b0:	c5470713          	addi	a4,a4,-940 # 8002e000 <disk>
    800063b4:	00c75793          	srli	a5,a4,0xc
    800063b8:	2781                	sext.w	a5,a5
    800063ba:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    800063bc:	0002a797          	auipc	a5,0x2a
    800063c0:	c4478793          	addi	a5,a5,-956 # 80030000 <disk+0x2000>
    800063c4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800063c6:	00028717          	auipc	a4,0x28
    800063ca:	cba70713          	addi	a4,a4,-838 # 8002e080 <disk+0x80>
    800063ce:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    800063d0:	00029717          	auipc	a4,0x29
    800063d4:	c3070713          	addi	a4,a4,-976 # 8002f000 <disk+0x1000>
    800063d8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800063da:	4705                	li	a4,1
    800063dc:	00e78c23          	sb	a4,24(a5)
    800063e0:	00e78ca3          	sb	a4,25(a5)
    800063e4:	00e78d23          	sb	a4,26(a5)
    800063e8:	00e78da3          	sb	a4,27(a5)
    800063ec:	00e78e23          	sb	a4,28(a5)
    800063f0:	00e78ea3          	sb	a4,29(a5)
    800063f4:	00e78f23          	sb	a4,30(a5)
    800063f8:	00e78fa3          	sb	a4,31(a5)
}
    800063fc:	60e2                	ld	ra,24(sp)
    800063fe:	6442                	ld	s0,16(sp)
    80006400:	64a2                	ld	s1,8(sp)
    80006402:	6105                	addi	sp,sp,32
    80006404:	8082                	ret
    panic("could not find virtio disk");
    80006406:	00002517          	auipc	a0,0x2
    8000640a:	42a50513          	addi	a0,a0,1066 # 80008830 <syscalls+0x3a0>
    8000640e:	ffffa097          	auipc	ra,0xffffa
    80006412:	16a080e7          	jalr	362(ra) # 80000578 <panic>
    panic("virtio disk has no queue 0");
    80006416:	00002517          	auipc	a0,0x2
    8000641a:	43a50513          	addi	a0,a0,1082 # 80008850 <syscalls+0x3c0>
    8000641e:	ffffa097          	auipc	ra,0xffffa
    80006422:	15a080e7          	jalr	346(ra) # 80000578 <panic>
    panic("virtio disk max queue too short");
    80006426:	00002517          	auipc	a0,0x2
    8000642a:	44a50513          	addi	a0,a0,1098 # 80008870 <syscalls+0x3e0>
    8000642e:	ffffa097          	auipc	ra,0xffffa
    80006432:	14a080e7          	jalr	330(ra) # 80000578 <panic>

0000000080006436 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006436:	711d                	addi	sp,sp,-96
    80006438:	ec86                	sd	ra,88(sp)
    8000643a:	e8a2                	sd	s0,80(sp)
    8000643c:	e4a6                	sd	s1,72(sp)
    8000643e:	e0ca                	sd	s2,64(sp)
    80006440:	fc4e                	sd	s3,56(sp)
    80006442:	f852                	sd	s4,48(sp)
    80006444:	f456                	sd	s5,40(sp)
    80006446:	f05a                	sd	s6,32(sp)
    80006448:	ec5e                	sd	s7,24(sp)
    8000644a:	e862                	sd	s8,16(sp)
    8000644c:	1080                	addi	s0,sp,96
    8000644e:	892a                	mv	s2,a0
    80006450:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006452:	00c52b83          	lw	s7,12(a0)
    80006456:	001b9b9b          	slliw	s7,s7,0x1
    8000645a:	1b82                	slli	s7,s7,0x20
    8000645c:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80006460:	0002a517          	auipc	a0,0x2a
    80006464:	cc850513          	addi	a0,a0,-824 # 80030128 <disk+0x2128>
    80006468:	ffffb097          	auipc	ra,0xffffb
    8000646c:	912080e7          	jalr	-1774(ra) # 80000d7a <acquire>
    if(disk.free[i]){
    80006470:	0002a997          	auipc	s3,0x2a
    80006474:	b9098993          	addi	s3,s3,-1136 # 80030000 <disk+0x2000>
  for(int i = 0; i < NUM; i++){
    80006478:	4b21                	li	s6,8
      disk.free[i] = 0;
    8000647a:	00028a97          	auipc	s5,0x28
    8000647e:	b86a8a93          	addi	s5,s5,-1146 # 8002e000 <disk>
  for(int i = 0; i < 3; i++){
    80006482:	4a0d                	li	s4,3
    80006484:	a079                	j	80006512 <virtio_disk_rw+0xdc>
      disk.free[i] = 0;
    80006486:	00fa86b3          	add	a3,s5,a5
    8000648a:	96ae                	add	a3,a3,a1
    8000648c:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006490:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006492:	0207ca63          	bltz	a5,800064c6 <virtio_disk_rw+0x90>
  for(int i = 0; i < 3; i++){
    80006496:	2485                	addiw	s1,s1,1
    80006498:	0711                	addi	a4,a4,4
    8000649a:	25448b63          	beq	s1,s4,800066f0 <virtio_disk_rw+0x2ba>
    idx[i] = alloc_desc();
    8000649e:	863a                	mv	a2,a4
    if(disk.free[i]){
    800064a0:	0189c783          	lbu	a5,24(s3)
    800064a4:	26079e63          	bnez	a5,80006720 <virtio_disk_rw+0x2ea>
    800064a8:	0002a697          	auipc	a3,0x2a
    800064ac:	b7168693          	addi	a3,a3,-1167 # 80030019 <disk+0x2019>
  for(int i = 0; i < NUM; i++){
    800064b0:	87aa                	mv	a5,a0
    if(disk.free[i]){
    800064b2:	0006c803          	lbu	a6,0(a3)
    800064b6:	fc0818e3          	bnez	a6,80006486 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800064ba:	2785                	addiw	a5,a5,1
    800064bc:	0685                	addi	a3,a3,1
    800064be:	ff679ae3          	bne	a5,s6,800064b2 <virtio_disk_rw+0x7c>
    idx[i] = alloc_desc();
    800064c2:	57fd                	li	a5,-1
    800064c4:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800064c6:	02905a63          	blez	s1,800064fa <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800064ca:	fa042503          	lw	a0,-96(s0)
    800064ce:	00000097          	auipc	ra,0x0
    800064d2:	d88080e7          	jalr	-632(ra) # 80006256 <free_desc>
      for(int j = 0; j < i; j++)
    800064d6:	4785                	li	a5,1
    800064d8:	0297d163          	ble	s1,a5,800064fa <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800064dc:	fa442503          	lw	a0,-92(s0)
    800064e0:	00000097          	auipc	ra,0x0
    800064e4:	d76080e7          	jalr	-650(ra) # 80006256 <free_desc>
      for(int j = 0; j < i; j++)
    800064e8:	4789                	li	a5,2
    800064ea:	0097d863          	ble	s1,a5,800064fa <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800064ee:	fa842503          	lw	a0,-88(s0)
    800064f2:	00000097          	auipc	ra,0x0
    800064f6:	d64080e7          	jalr	-668(ra) # 80006256 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064fa:	0002a597          	auipc	a1,0x2a
    800064fe:	c2e58593          	addi	a1,a1,-978 # 80030128 <disk+0x2128>
    80006502:	0002a517          	auipc	a0,0x2a
    80006506:	b1650513          	addi	a0,a0,-1258 # 80030018 <disk+0x2018>
    8000650a:	ffffc097          	auipc	ra,0xffffc
    8000650e:	13a080e7          	jalr	314(ra) # 80002644 <sleep>
  for(int i = 0; i < 3; i++){
    80006512:	fa040713          	addi	a4,s0,-96
    80006516:	4481                	li	s1,0
  for(int i = 0; i < NUM; i++){
    80006518:	4505                	li	a0,1
      disk.free[i] = 0;
    8000651a:	6589                	lui	a1,0x2
    8000651c:	b749                	j	8000649e <virtio_disk_rw+0x68>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    8000651e:	20058793          	addi	a5,a1,512 # 2200 <_entry-0x7fffde00>
    80006522:	00479613          	slli	a2,a5,0x4
    80006526:	00028797          	auipc	a5,0x28
    8000652a:	ada78793          	addi	a5,a5,-1318 # 8002e000 <disk>
    8000652e:	97b2                	add	a5,a5,a2
    80006530:	4605                	li	a2,1
    80006532:	0ac7a423          	sw	a2,168(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006536:	20058793          	addi	a5,a1,512
    8000653a:	00479613          	slli	a2,a5,0x4
    8000653e:	00028797          	auipc	a5,0x28
    80006542:	ac278793          	addi	a5,a5,-1342 # 8002e000 <disk>
    80006546:	97b2                	add	a5,a5,a2
    80006548:	0a07a623          	sw	zero,172(a5)
  buf0->sector = sector;
    8000654c:	0b77b823          	sd	s7,176(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006550:	0002a797          	auipc	a5,0x2a
    80006554:	ab078793          	addi	a5,a5,-1360 # 80030000 <disk+0x2000>
    80006558:	6390                	ld	a2,0(a5)
    8000655a:	963a                	add	a2,a2,a4
    8000655c:	7779                	lui	a4,0xffffe
    8000655e:	9732                	add	a4,a4,a2
    80006560:	e314                	sd	a3,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006562:	00459713          	slli	a4,a1,0x4
    80006566:	6394                	ld	a3,0(a5)
    80006568:	96ba                	add	a3,a3,a4
    8000656a:	4641                	li	a2,16
    8000656c:	c690                	sw	a2,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000656e:	6394                	ld	a3,0(a5)
    80006570:	96ba                	add	a3,a3,a4
    80006572:	4605                	li	a2,1
    80006574:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006578:	fa442683          	lw	a3,-92(s0)
    8000657c:	6390                	ld	a2,0(a5)
    8000657e:	963a                	add	a2,a2,a4
    80006580:	00d61723          	sh	a3,14(a2) # 200e <_entry-0x7fffdff2>

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006584:	0692                	slli	a3,a3,0x4
    80006586:	6390                	ld	a2,0(a5)
    80006588:	9636                	add	a2,a2,a3
    8000658a:	06090513          	addi	a0,s2,96
    8000658e:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006590:	639c                	ld	a5,0(a5)
    80006592:	97b6                	add	a5,a5,a3
    80006594:	40000613          	li	a2,1024
    80006598:	c790                	sw	a2,8(a5)
  if(write)
    8000659a:	140c0163          	beqz	s8,800066dc <virtio_disk_rw+0x2a6>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000659e:	0002a797          	auipc	a5,0x2a
    800065a2:	a6278793          	addi	a5,a5,-1438 # 80030000 <disk+0x2000>
    800065a6:	639c                	ld	a5,0(a5)
    800065a8:	97b6                	add	a5,a5,a3
    800065aa:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800065ae:	00028897          	auipc	a7,0x28
    800065b2:	a5288893          	addi	a7,a7,-1454 # 8002e000 <disk>
    800065b6:	0002a797          	auipc	a5,0x2a
    800065ba:	a4a78793          	addi	a5,a5,-1462 # 80030000 <disk+0x2000>
    800065be:	6390                	ld	a2,0(a5)
    800065c0:	9636                	add	a2,a2,a3
    800065c2:	00c65503          	lhu	a0,12(a2)
    800065c6:	00156513          	ori	a0,a0,1
    800065ca:	00a61623          	sh	a0,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800065ce:	fa842603          	lw	a2,-88(s0)
    800065d2:	6388                	ld	a0,0(a5)
    800065d4:	96aa                	add	a3,a3,a0
    800065d6:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800065da:	20058513          	addi	a0,a1,512
    800065de:	0512                	slli	a0,a0,0x4
    800065e0:	9546                	add	a0,a0,a7
    800065e2:	56fd                	li	a3,-1
    800065e4:	02d50823          	sb	a3,48(a0)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800065e8:	00461693          	slli	a3,a2,0x4
    800065ec:	6390                	ld	a2,0(a5)
    800065ee:	9636                	add	a2,a2,a3
    800065f0:	6809                	lui	a6,0x2
    800065f2:	03080813          	addi	a6,a6,48 # 2030 <_entry-0x7fffdfd0>
    800065f6:	9742                	add	a4,a4,a6
    800065f8:	9746                	add	a4,a4,a7
    800065fa:	e218                	sd	a4,0(a2)
  disk.desc[idx[2]].len = 1;
    800065fc:	6398                	ld	a4,0(a5)
    800065fe:	9736                	add	a4,a4,a3
    80006600:	4605                	li	a2,1
    80006602:	c710                	sw	a2,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006604:	6398                	ld	a4,0(a5)
    80006606:	9736                	add	a4,a4,a3
    80006608:	4809                	li	a6,2
    8000660a:	01071623          	sh	a6,12(a4) # ffffffffffffe00c <end+0xffffffff7ffcbfe4>
  disk.desc[idx[2]].next = 0;
    8000660e:	6398                	ld	a4,0(a5)
    80006610:	96ba                	add	a3,a3,a4
    80006612:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006616:	00c92223          	sw	a2,4(s2)
  disk.info[idx[0]].b = b;
    8000661a:	03253423          	sd	s2,40(a0)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000661e:	6794                	ld	a3,8(a5)
    80006620:	0026d703          	lhu	a4,2(a3)
    80006624:	8b1d                	andi	a4,a4,7
    80006626:	0706                	slli	a4,a4,0x1
    80006628:	9736                	add	a4,a4,a3
    8000662a:	00b71223          	sh	a1,4(a4)

  __sync_synchronize();
    8000662e:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006632:	6798                	ld	a4,8(a5)
    80006634:	00275783          	lhu	a5,2(a4)
    80006638:	2785                	addiw	a5,a5,1
    8000663a:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000663e:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006642:	100017b7          	lui	a5,0x10001
    80006646:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000664a:	00492703          	lw	a4,4(s2)
    8000664e:	4785                	li	a5,1
    80006650:	02f71163          	bne	a4,a5,80006672 <virtio_disk_rw+0x23c>
    sleep(b, &disk.vdisk_lock);
    80006654:	0002a997          	auipc	s3,0x2a
    80006658:	ad498993          	addi	s3,s3,-1324 # 80030128 <disk+0x2128>
  while(b->disk == 1) {
    8000665c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000665e:	85ce                	mv	a1,s3
    80006660:	854a                	mv	a0,s2
    80006662:	ffffc097          	auipc	ra,0xffffc
    80006666:	fe2080e7          	jalr	-30(ra) # 80002644 <sleep>
  while(b->disk == 1) {
    8000666a:	00492783          	lw	a5,4(s2)
    8000666e:	fe9788e3          	beq	a5,s1,8000665e <virtio_disk_rw+0x228>
  }

  disk.info[idx[0]].b = 0;
    80006672:	fa042503          	lw	a0,-96(s0)
    80006676:	20050793          	addi	a5,a0,512
    8000667a:	00479713          	slli	a4,a5,0x4
    8000667e:	00028797          	auipc	a5,0x28
    80006682:	98278793          	addi	a5,a5,-1662 # 8002e000 <disk>
    80006686:	97ba                	add	a5,a5,a4
    80006688:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    8000668c:	0002a997          	auipc	s3,0x2a
    80006690:	97498993          	addi	s3,s3,-1676 # 80030000 <disk+0x2000>
    80006694:	00451713          	slli	a4,a0,0x4
    80006698:	0009b783          	ld	a5,0(s3)
    8000669c:	97ba                	add	a5,a5,a4
    8000669e:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800066a2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800066a6:	00000097          	auipc	ra,0x0
    800066aa:	bb0080e7          	jalr	-1104(ra) # 80006256 <free_desc>
      i = nxt;
    800066ae:	854a                	mv	a0,s2
    if(flag & VRING_DESC_F_NEXT)
    800066b0:	8885                	andi	s1,s1,1
    800066b2:	f0ed                	bnez	s1,80006694 <virtio_disk_rw+0x25e>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800066b4:	0002a517          	auipc	a0,0x2a
    800066b8:	a7450513          	addi	a0,a0,-1420 # 80030128 <disk+0x2128>
    800066bc:	ffffa097          	auipc	ra,0xffffa
    800066c0:	78e080e7          	jalr	1934(ra) # 80000e4a <release>
}
    800066c4:	60e6                	ld	ra,88(sp)
    800066c6:	6446                	ld	s0,80(sp)
    800066c8:	64a6                	ld	s1,72(sp)
    800066ca:	6906                	ld	s2,64(sp)
    800066cc:	79e2                	ld	s3,56(sp)
    800066ce:	7a42                	ld	s4,48(sp)
    800066d0:	7aa2                	ld	s5,40(sp)
    800066d2:	7b02                	ld	s6,32(sp)
    800066d4:	6be2                	ld	s7,24(sp)
    800066d6:	6c42                	ld	s8,16(sp)
    800066d8:	6125                	addi	sp,sp,96
    800066da:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800066dc:	0002a797          	auipc	a5,0x2a
    800066e0:	92478793          	addi	a5,a5,-1756 # 80030000 <disk+0x2000>
    800066e4:	639c                	ld	a5,0(a5)
    800066e6:	97b6                	add	a5,a5,a3
    800066e8:	4609                	li	a2,2
    800066ea:	00c79623          	sh	a2,12(a5)
    800066ee:	b5c1                	j	800065ae <virtio_disk_rw+0x178>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066f0:	fa042583          	lw	a1,-96(s0)
    800066f4:	20058713          	addi	a4,a1,512
    800066f8:	0712                	slli	a4,a4,0x4
    800066fa:	00028697          	auipc	a3,0x28
    800066fe:	9ae68693          	addi	a3,a3,-1618 # 8002e0a8 <disk+0xa8>
    80006702:	96ba                	add	a3,a3,a4
  if(write)
    80006704:	e00c1de3          	bnez	s8,8000651e <virtio_disk_rw+0xe8>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006708:	20058793          	addi	a5,a1,512
    8000670c:	00479613          	slli	a2,a5,0x4
    80006710:	00028797          	auipc	a5,0x28
    80006714:	8f078793          	addi	a5,a5,-1808 # 8002e000 <disk>
    80006718:	97b2                	add	a5,a5,a2
    8000671a:	0a07a423          	sw	zero,168(a5)
    8000671e:	bd21                	j	80006536 <virtio_disk_rw+0x100>
      disk.free[i] = 0;
    80006720:	00098c23          	sb	zero,24(s3)
    idx[i] = alloc_desc();
    80006724:	00072023          	sw	zero,0(a4)
    if(idx[i] < 0){
    80006728:	b3bd                	j	80006496 <virtio_disk_rw+0x60>

000000008000672a <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000672a:	1101                	addi	sp,sp,-32
    8000672c:	ec06                	sd	ra,24(sp)
    8000672e:	e822                	sd	s0,16(sp)
    80006730:	e426                	sd	s1,8(sp)
    80006732:	e04a                	sd	s2,0(sp)
    80006734:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006736:	0002a517          	auipc	a0,0x2a
    8000673a:	9f250513          	addi	a0,a0,-1550 # 80030128 <disk+0x2128>
    8000673e:	ffffa097          	auipc	ra,0xffffa
    80006742:	63c080e7          	jalr	1596(ra) # 80000d7a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006746:	10001737          	lui	a4,0x10001
    8000674a:	533c                	lw	a5,96(a4)
    8000674c:	8b8d                	andi	a5,a5,3
    8000674e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006750:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006754:	0002a797          	auipc	a5,0x2a
    80006758:	8ac78793          	addi	a5,a5,-1876 # 80030000 <disk+0x2000>
    8000675c:	6b94                	ld	a3,16(a5)
    8000675e:	0207d703          	lhu	a4,32(a5)
    80006762:	0026d783          	lhu	a5,2(a3)
    80006766:	06f70163          	beq	a4,a5,800067c8 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000676a:	00028917          	auipc	s2,0x28
    8000676e:	89690913          	addi	s2,s2,-1898 # 8002e000 <disk>
    80006772:	0002a497          	auipc	s1,0x2a
    80006776:	88e48493          	addi	s1,s1,-1906 # 80030000 <disk+0x2000>
    __sync_synchronize();
    8000677a:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000677e:	6898                	ld	a4,16(s1)
    80006780:	0204d783          	lhu	a5,32(s1)
    80006784:	8b9d                	andi	a5,a5,7
    80006786:	078e                	slli	a5,a5,0x3
    80006788:	97ba                	add	a5,a5,a4
    8000678a:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000678c:	20078713          	addi	a4,a5,512
    80006790:	0712                	slli	a4,a4,0x4
    80006792:	974a                	add	a4,a4,s2
    80006794:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80006798:	e731                	bnez	a4,800067e4 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000679a:	20078793          	addi	a5,a5,512
    8000679e:	0792                	slli	a5,a5,0x4
    800067a0:	97ca                	add	a5,a5,s2
    800067a2:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800067a4:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800067a8:	ffffc097          	auipc	ra,0xffffc
    800067ac:	022080e7          	jalr	34(ra) # 800027ca <wakeup>

    disk.used_idx += 1;
    800067b0:	0204d783          	lhu	a5,32(s1)
    800067b4:	2785                	addiw	a5,a5,1
    800067b6:	17c2                	slli	a5,a5,0x30
    800067b8:	93c1                	srli	a5,a5,0x30
    800067ba:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800067be:	6898                	ld	a4,16(s1)
    800067c0:	00275703          	lhu	a4,2(a4)
    800067c4:	faf71be3          	bne	a4,a5,8000677a <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800067c8:	0002a517          	auipc	a0,0x2a
    800067cc:	96050513          	addi	a0,a0,-1696 # 80030128 <disk+0x2128>
    800067d0:	ffffa097          	auipc	ra,0xffffa
    800067d4:	67a080e7          	jalr	1658(ra) # 80000e4a <release>
}
    800067d8:	60e2                	ld	ra,24(sp)
    800067da:	6442                	ld	s0,16(sp)
    800067dc:	64a2                	ld	s1,8(sp)
    800067de:	6902                	ld	s2,0(sp)
    800067e0:	6105                	addi	sp,sp,32
    800067e2:	8082                	ret
      panic("virtio_disk_intr status");
    800067e4:	00002517          	auipc	a0,0x2
    800067e8:	0ac50513          	addi	a0,a0,172 # 80008890 <syscalls+0x400>
    800067ec:	ffffa097          	auipc	ra,0xffffa
    800067f0:	d8c080e7          	jalr	-628(ra) # 80000578 <panic>

00000000800067f4 <statswrite>:
int statscopyin(char*, int);
int statslock(char*, int);
  
int
statswrite(int user_src, uint64 src, int n)
{
    800067f4:	1141                	addi	sp,sp,-16
    800067f6:	e422                	sd	s0,8(sp)
    800067f8:	0800                	addi	s0,sp,16
  return -1;
}
    800067fa:	557d                	li	a0,-1
    800067fc:	6422                	ld	s0,8(sp)
    800067fe:	0141                	addi	sp,sp,16
    80006800:	8082                	ret

0000000080006802 <statsread>:

int
statsread(int user_dst, uint64 dst, int n)
{
    80006802:	7179                	addi	sp,sp,-48
    80006804:	f406                	sd	ra,40(sp)
    80006806:	f022                	sd	s0,32(sp)
    80006808:	ec26                	sd	s1,24(sp)
    8000680a:	e84a                	sd	s2,16(sp)
    8000680c:	e44e                	sd	s3,8(sp)
    8000680e:	e052                	sd	s4,0(sp)
    80006810:	1800                	addi	s0,sp,48
    80006812:	89aa                	mv	s3,a0
    80006814:	8a2e                	mv	s4,a1
    80006816:	8932                	mv	s2,a2
  int m;

  acquire(&stats.lock);
    80006818:	0002a517          	auipc	a0,0x2a
    8000681c:	7e850513          	addi	a0,a0,2024 # 80031000 <stats>
    80006820:	ffffa097          	auipc	ra,0xffffa
    80006824:	55a080e7          	jalr	1370(ra) # 80000d7a <acquire>

  if(stats.sz == 0) {
    80006828:	0002b797          	auipc	a5,0x2b
    8000682c:	7d878793          	addi	a5,a5,2008 # 80032000 <stats+0x1000>
    80006830:	539c                	lw	a5,32(a5)
    80006832:	cbad                	beqz	a5,800068a4 <statsread+0xa2>
#endif
#ifdef LAB_LOCK
    stats.sz = statslock(stats.buf, BUFSZ);
#endif
  }
  m = stats.sz - stats.off;
    80006834:	0002b797          	auipc	a5,0x2b
    80006838:	7cc78793          	addi	a5,a5,1996 # 80032000 <stats+0x1000>
    8000683c:	53d8                	lw	a4,36(a5)
    8000683e:	539c                	lw	a5,32(a5)
    80006840:	9f99                	subw	a5,a5,a4
    80006842:	0007869b          	sext.w	a3,a5

  if (m > 0) {
    80006846:	06d05d63          	blez	a3,800068c0 <statsread+0xbe>
    if(m > n)
    8000684a:	84be                	mv	s1,a5
    8000684c:	00d95363          	ble	a3,s2,80006852 <statsread+0x50>
    80006850:	84ca                	mv	s1,s2
    80006852:	0004891b          	sext.w	s2,s1
      m  = n;
    if(either_copyout(user_dst, dst, stats.buf+stats.off, m) != -1) {
    80006856:	86ca                	mv	a3,s2
    80006858:	0002a617          	auipc	a2,0x2a
    8000685c:	7c860613          	addi	a2,a2,1992 # 80031020 <stats+0x20>
    80006860:	963a                	add	a2,a2,a4
    80006862:	85d2                	mv	a1,s4
    80006864:	854e                	mv	a0,s3
    80006866:	ffffc097          	auipc	ra,0xffffc
    8000686a:	040080e7          	jalr	64(ra) # 800028a6 <either_copyout>
    8000686e:	57fd                	li	a5,-1
    80006870:	00f50963          	beq	a0,a5,80006882 <statsread+0x80>
      stats.off += m;
    80006874:	0002b717          	auipc	a4,0x2b
    80006878:	78c70713          	addi	a4,a4,1932 # 80032000 <stats+0x1000>
    8000687c:	535c                	lw	a5,36(a4)
    8000687e:	9cbd                	addw	s1,s1,a5
    80006880:	d344                	sw	s1,36(a4)
  } else {
    m = -1;
    stats.sz = 0;
    stats.off = 0;
  }
  release(&stats.lock);
    80006882:	0002a517          	auipc	a0,0x2a
    80006886:	77e50513          	addi	a0,a0,1918 # 80031000 <stats>
    8000688a:	ffffa097          	auipc	ra,0xffffa
    8000688e:	5c0080e7          	jalr	1472(ra) # 80000e4a <release>
  return m;
}
    80006892:	854a                	mv	a0,s2
    80006894:	70a2                	ld	ra,40(sp)
    80006896:	7402                	ld	s0,32(sp)
    80006898:	64e2                	ld	s1,24(sp)
    8000689a:	6942                	ld	s2,16(sp)
    8000689c:	69a2                	ld	s3,8(sp)
    8000689e:	6a02                	ld	s4,0(sp)
    800068a0:	6145                	addi	sp,sp,48
    800068a2:	8082                	ret
    stats.sz = statslock(stats.buf, BUFSZ);
    800068a4:	6585                	lui	a1,0x1
    800068a6:	0002a517          	auipc	a0,0x2a
    800068aa:	77a50513          	addi	a0,a0,1914 # 80031020 <stats+0x20>
    800068ae:	ffffa097          	auipc	ra,0xffffa
    800068b2:	714080e7          	jalr	1812(ra) # 80000fc2 <statslock>
    800068b6:	0002b797          	auipc	a5,0x2b
    800068ba:	76a7a523          	sw	a0,1898(a5) # 80032020 <stats+0x1020>
    800068be:	bf9d                	j	80006834 <statsread+0x32>
    stats.sz = 0;
    800068c0:	0002b797          	auipc	a5,0x2b
    800068c4:	74078793          	addi	a5,a5,1856 # 80032000 <stats+0x1000>
    800068c8:	0207a023          	sw	zero,32(a5)
    stats.off = 0;
    800068cc:	0207a223          	sw	zero,36(a5)
    m = -1;
    800068d0:	597d                	li	s2,-1
    800068d2:	bf45                	j	80006882 <statsread+0x80>

00000000800068d4 <statsinit>:

void
statsinit(void)
{
    800068d4:	1141                	addi	sp,sp,-16
    800068d6:	e406                	sd	ra,8(sp)
    800068d8:	e022                	sd	s0,0(sp)
    800068da:	0800                	addi	s0,sp,16
  initlock(&stats.lock, "stats");
    800068dc:	00002597          	auipc	a1,0x2
    800068e0:	fcc58593          	addi	a1,a1,-52 # 800088a8 <syscalls+0x418>
    800068e4:	0002a517          	auipc	a0,0x2a
    800068e8:	71c50513          	addi	a0,a0,1820 # 80031000 <stats>
    800068ec:	ffffa097          	auipc	ra,0xffffa
    800068f0:	61a080e7          	jalr	1562(ra) # 80000f06 <initlock>

  devsw[STATS].read = statsread;
    800068f4:	00025797          	auipc	a5,0x25
    800068f8:	7ec78793          	addi	a5,a5,2028 # 8002c0e0 <devsw>
    800068fc:	00000717          	auipc	a4,0x0
    80006900:	f0670713          	addi	a4,a4,-250 # 80006802 <statsread>
    80006904:	f398                	sd	a4,32(a5)
  devsw[STATS].write = statswrite;
    80006906:	00000717          	auipc	a4,0x0
    8000690a:	eee70713          	addi	a4,a4,-274 # 800067f4 <statswrite>
    8000690e:	f798                	sd	a4,40(a5)
}
    80006910:	60a2                	ld	ra,8(sp)
    80006912:	6402                	ld	s0,0(sp)
    80006914:	0141                	addi	sp,sp,16
    80006916:	8082                	ret

0000000080006918 <sprintint>:
  return 1;
}

static int
sprintint(char *s, int xx, int base, int sign)
{
    80006918:	1101                	addi	sp,sp,-32
    8000691a:	ec22                	sd	s0,24(sp)
    8000691c:	1000                	addi	s0,sp,32
  char buf[16];
  int i, n;
  uint x;

  if(sign && (sign = xx < 0))
    8000691e:	c299                	beqz	a3,80006924 <sprintint+0xc>
    80006920:	0005cd63          	bltz	a1,8000693a <sprintint+0x22>
    x = -xx;
  else
    x = xx;
    80006924:	2581                	sext.w	a1,a1
    80006926:	4301                	li	t1,0

  i = 0;
    80006928:	fe040713          	addi	a4,s0,-32
    8000692c:	4801                	li	a6,0
  do {
    buf[i++] = digits[x % base];
    8000692e:	2601                	sext.w	a2,a2
    80006930:	00002897          	auipc	a7,0x2
    80006934:	f8088893          	addi	a7,a7,-128 # 800088b0 <digits>
    80006938:	a801                	j	80006948 <sprintint+0x30>
    x = -xx;
    8000693a:	40b005bb          	negw	a1,a1
    8000693e:	2581                	sext.w	a1,a1
  if(sign && (sign = xx < 0))
    80006940:	4305                	li	t1,1
    x = -xx;
    80006942:	b7dd                	j	80006928 <sprintint+0x10>
  } while((x /= base) != 0);
    80006944:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
    80006946:	8836                	mv	a6,a3
    80006948:	0018069b          	addiw	a3,a6,1
    8000694c:	02c5f7bb          	remuw	a5,a1,a2
    80006950:	1782                	slli	a5,a5,0x20
    80006952:	9381                	srli	a5,a5,0x20
    80006954:	97c6                	add	a5,a5,a7
    80006956:	0007c783          	lbu	a5,0(a5)
    8000695a:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    8000695e:	0705                	addi	a4,a4,1
    80006960:	02c5d7bb          	divuw	a5,a1,a2
    80006964:	fec5f0e3          	bleu	a2,a1,80006944 <sprintint+0x2c>

  if(sign)
    80006968:	00030b63          	beqz	t1,8000697e <sprintint+0x66>
    buf[i++] = '-';
    8000696c:	ff040793          	addi	a5,s0,-16
    80006970:	96be                	add	a3,a3,a5
    80006972:	02d00793          	li	a5,45
    80006976:	fef68823          	sb	a5,-16(a3)
    8000697a:	0028069b          	addiw	a3,a6,2

  n = 0;
  while(--i >= 0)
    8000697e:	02d05963          	blez	a3,800069b0 <sprintint+0x98>
    80006982:	fe040793          	addi	a5,s0,-32
    80006986:	00d78733          	add	a4,a5,a3
    8000698a:	87aa                	mv	a5,a0
    8000698c:	0505                	addi	a0,a0,1
    8000698e:	fff6861b          	addiw	a2,a3,-1
    80006992:	1602                	slli	a2,a2,0x20
    80006994:	9201                	srli	a2,a2,0x20
    80006996:	9532                	add	a0,a0,a2
  *s = c;
    80006998:	fff74603          	lbu	a2,-1(a4)
    8000699c:	00c78023          	sb	a2,0(a5)
  while(--i >= 0)
    800069a0:	177d                	addi	a4,a4,-1
    800069a2:	0785                	addi	a5,a5,1
    800069a4:	fea79ae3          	bne	a5,a0,80006998 <sprintint+0x80>
    n += sputc(s+n, buf[i]);
  return n;
}
    800069a8:	8536                	mv	a0,a3
    800069aa:	6462                	ld	s0,24(sp)
    800069ac:	6105                	addi	sp,sp,32
    800069ae:	8082                	ret
  while(--i >= 0)
    800069b0:	4681                	li	a3,0
    800069b2:	bfdd                	j	800069a8 <sprintint+0x90>

00000000800069b4 <snprintf>:

int
snprintf(char *buf, int sz, char *fmt, ...)
{
    800069b4:	7171                	addi	sp,sp,-176
    800069b6:	fc86                	sd	ra,120(sp)
    800069b8:	f8a2                	sd	s0,112(sp)
    800069ba:	f4a6                	sd	s1,104(sp)
    800069bc:	f0ca                	sd	s2,96(sp)
    800069be:	ecce                	sd	s3,88(sp)
    800069c0:	e8d2                	sd	s4,80(sp)
    800069c2:	e4d6                	sd	s5,72(sp)
    800069c4:	e0da                	sd	s6,64(sp)
    800069c6:	fc5e                	sd	s7,56(sp)
    800069c8:	f862                	sd	s8,48(sp)
    800069ca:	f466                	sd	s9,40(sp)
    800069cc:	f06a                	sd	s10,32(sp)
    800069ce:	ec6e                	sd	s11,24(sp)
    800069d0:	0100                	addi	s0,sp,128
    800069d2:	e414                	sd	a3,8(s0)
    800069d4:	e818                	sd	a4,16(s0)
    800069d6:	ec1c                	sd	a5,24(s0)
    800069d8:	03043023          	sd	a6,32(s0)
    800069dc:	03143423          	sd	a7,40(s0)
  va_list ap;
  int i, c;
  int off = 0;
  char *s;

  if (fmt == 0)
    800069e0:	ce1d                	beqz	a2,80006a1e <snprintf+0x6a>
    800069e2:	8baa                	mv	s7,a0
    800069e4:	89ae                	mv	s3,a1
    800069e6:	8a32                	mv	s4,a2
    panic("null fmt");

  va_start(ap, fmt);
    800069e8:	00840793          	addi	a5,s0,8
    800069ec:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    800069f0:	14b05263          	blez	a1,80006b34 <snprintf+0x180>
    800069f4:	00064703          	lbu	a4,0(a2)
    800069f8:	0007079b          	sext.w	a5,a4
    800069fc:	12078e63          	beqz	a5,80006b38 <snprintf+0x184>
  int off = 0;
    80006a00:	4481                	li	s1,0
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    80006a02:	4901                	li	s2,0
    if(c != '%'){
    80006a04:	02500a93          	li	s5,37
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    80006a08:	06400b13          	li	s6,100
  *s = c;
    80006a0c:	02500d13          	li	s10,37
    switch(c){
    80006a10:	07300c93          	li	s9,115
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
      break;
    case 's':
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s && off < sz; s++)
    80006a14:	02800d93          	li	s11,40
    switch(c){
    80006a18:	07800c13          	li	s8,120
    80006a1c:	a805                	j	80006a4c <snprintf+0x98>
    panic("null fmt");
    80006a1e:	00001517          	auipc	a0,0x1
    80006a22:	62250513          	addi	a0,a0,1570 # 80008040 <digits+0x28>
    80006a26:	ffffa097          	auipc	ra,0xffffa
    80006a2a:	b52080e7          	jalr	-1198(ra) # 80000578 <panic>
  *s = c;
    80006a2e:	009b87b3          	add	a5,s7,s1
    80006a32:	00e78023          	sb	a4,0(a5)
      off += sputc(buf+off, c);
    80006a36:	2485                	addiw	s1,s1,1
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    80006a38:	2905                	addiw	s2,s2,1
    80006a3a:	0b34dc63          	ble	s3,s1,80006af2 <snprintf+0x13e>
    80006a3e:	012a07b3          	add	a5,s4,s2
    80006a42:	0007c703          	lbu	a4,0(a5)
    80006a46:	0007079b          	sext.w	a5,a4
    80006a4a:	c7c5                	beqz	a5,80006af2 <snprintf+0x13e>
    if(c != '%'){
    80006a4c:	ff5791e3          	bne	a5,s5,80006a2e <snprintf+0x7a>
    c = fmt[++i] & 0xff;
    80006a50:	2905                	addiw	s2,s2,1
    80006a52:	012a07b3          	add	a5,s4,s2
    80006a56:	0007c783          	lbu	a5,0(a5)
    if(c == 0)
    80006a5a:	cfc1                	beqz	a5,80006af2 <snprintf+0x13e>
    switch(c){
    80006a5c:	05678163          	beq	a5,s6,80006a9e <snprintf+0xea>
    80006a60:	02fb7763          	bleu	a5,s6,80006a8e <snprintf+0xda>
    80006a64:	05978e63          	beq	a5,s9,80006ac0 <snprintf+0x10c>
    80006a68:	0b879b63          	bne	a5,s8,80006b1e <snprintf+0x16a>
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
    80006a6c:	f8843783          	ld	a5,-120(s0)
    80006a70:	00878713          	addi	a4,a5,8
    80006a74:	f8e43423          	sd	a4,-120(s0)
    80006a78:	4685                	li	a3,1
    80006a7a:	4641                	li	a2,16
    80006a7c:	438c                	lw	a1,0(a5)
    80006a7e:	009b8533          	add	a0,s7,s1
    80006a82:	00000097          	auipc	ra,0x0
    80006a86:	e96080e7          	jalr	-362(ra) # 80006918 <sprintint>
    80006a8a:	9ca9                	addw	s1,s1,a0
      break;
    80006a8c:	b775                	j	80006a38 <snprintf+0x84>
    switch(c){
    80006a8e:	09579863          	bne	a5,s5,80006b1e <snprintf+0x16a>
  *s = c;
    80006a92:	009b87b3          	add	a5,s7,s1
    80006a96:	01a78023          	sb	s10,0(a5)
        off += sputc(buf+off, *s);
      break;
    case '%':
      off += sputc(buf+off, '%');
    80006a9a:	2485                	addiw	s1,s1,1
      break;
    80006a9c:	bf71                	j	80006a38 <snprintf+0x84>
      off += sprintint(buf+off, va_arg(ap, int), 10, 1);
    80006a9e:	f8843783          	ld	a5,-120(s0)
    80006aa2:	00878713          	addi	a4,a5,8
    80006aa6:	f8e43423          	sd	a4,-120(s0)
    80006aaa:	4685                	li	a3,1
    80006aac:	4629                	li	a2,10
    80006aae:	438c                	lw	a1,0(a5)
    80006ab0:	009b8533          	add	a0,s7,s1
    80006ab4:	00000097          	auipc	ra,0x0
    80006ab8:	e64080e7          	jalr	-412(ra) # 80006918 <sprintint>
    80006abc:	9ca9                	addw	s1,s1,a0
      break;
    80006abe:	bfad                	j	80006a38 <snprintf+0x84>
      if((s = va_arg(ap, char*)) == 0)
    80006ac0:	f8843783          	ld	a5,-120(s0)
    80006ac4:	00878713          	addi	a4,a5,8
    80006ac8:	f8e43423          	sd	a4,-120(s0)
    80006acc:	639c                	ld	a5,0(a5)
    80006ace:	c3b1                	beqz	a5,80006b12 <snprintf+0x15e>
      for(; *s && off < sz; s++)
    80006ad0:	0007c703          	lbu	a4,0(a5)
    80006ad4:	d335                	beqz	a4,80006a38 <snprintf+0x84>
    80006ad6:	0134de63          	ble	s3,s1,80006af2 <snprintf+0x13e>
    80006ada:	009b86b3          	add	a3,s7,s1
  *s = c;
    80006ade:	00e68023          	sb	a4,0(a3)
        off += sputc(buf+off, *s);
    80006ae2:	2485                	addiw	s1,s1,1
      for(; *s && off < sz; s++)
    80006ae4:	0785                	addi	a5,a5,1
    80006ae6:	0007c703          	lbu	a4,0(a5)
    80006aea:	d739                	beqz	a4,80006a38 <snprintf+0x84>
    80006aec:	0685                	addi	a3,a3,1
    80006aee:	fe9998e3          	bne	s3,s1,80006ade <snprintf+0x12a>
      off += sputc(buf+off, c);
      break;
    }
  }
  return off;
}
    80006af2:	8526                	mv	a0,s1
    80006af4:	70e6                	ld	ra,120(sp)
    80006af6:	7446                	ld	s0,112(sp)
    80006af8:	74a6                	ld	s1,104(sp)
    80006afa:	7906                	ld	s2,96(sp)
    80006afc:	69e6                	ld	s3,88(sp)
    80006afe:	6a46                	ld	s4,80(sp)
    80006b00:	6aa6                	ld	s5,72(sp)
    80006b02:	6b06                	ld	s6,64(sp)
    80006b04:	7be2                	ld	s7,56(sp)
    80006b06:	7c42                	ld	s8,48(sp)
    80006b08:	7ca2                	ld	s9,40(sp)
    80006b0a:	7d02                	ld	s10,32(sp)
    80006b0c:	6de2                	ld	s11,24(sp)
    80006b0e:	614d                	addi	sp,sp,176
    80006b10:	8082                	ret
      for(; *s && off < sz; s++)
    80006b12:	876e                	mv	a4,s11
        s = "(null)";
    80006b14:	00001797          	auipc	a5,0x1
    80006b18:	52478793          	addi	a5,a5,1316 # 80008038 <digits+0x20>
    80006b1c:	bf6d                	j	80006ad6 <snprintf+0x122>
  *s = c;
    80006b1e:	009b8733          	add	a4,s7,s1
    80006b22:	01a70023          	sb	s10,0(a4)
      off += sputc(buf+off, c);
    80006b26:	0014871b          	addiw	a4,s1,1
  *s = c;
    80006b2a:	975e                	add	a4,a4,s7
    80006b2c:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    80006b30:	2489                	addiw	s1,s1,2
      break;
    80006b32:	b719                	j	80006a38 <snprintf+0x84>
  int off = 0;
    80006b34:	4481                	li	s1,0
    80006b36:	bf75                	j	80006af2 <snprintf+0x13e>
    80006b38:	84be                	mv	s1,a5
    80006b3a:	bf65                	j	80006af2 <snprintf+0x13e>
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
