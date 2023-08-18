
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	86013103          	ld	sp,-1952(sp) # 80008860 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	ff078793          	addi	a5,a5,-16 # 80009040 <timer_scratch>
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
    80000066:	18e78793          	addi	a5,a5,398 # 800061f0 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffcc7ff>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e4878793          	addi	a5,a5,-440 # 80000ef4 <main>
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
  int i;

  for(i = 0; i < n; i++){
    80000104:	04c05663          	blez	a2,80000150 <consolewrite+0x5e>
    80000108:	8a2a                	mv	s4,a0
    8000010a:	892e                	mv	s2,a1
    8000010c:	89b2                	mv	s3,a2
    8000010e:	4481                	li	s1,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000110:	5afd                	li	s5,-1
    80000112:	4685                	li	a3,1
    80000114:	864a                	mv	a2,s2
    80000116:	85d2                	mv	a1,s4
    80000118:	fbf40513          	addi	a0,s0,-65
    8000011c:	00002097          	auipc	ra,0x2
    80000120:	4be080e7          	jalr	1214(ra) # 800025da <either_copyin>
    80000124:	01550c63          	beq	a0,s5,8000013c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000128:	fbf44503          	lbu	a0,-65(s0)
    8000012c:	00000097          	auipc	ra,0x0
    80000130:	7d2080e7          	jalr	2002(ra) # 800008fe <uartputc>
  for(i = 0; i < n; i++){
    80000134:	2485                	addiw	s1,s1,1
    80000136:	0905                	addi	s2,s2,1
    80000138:	fc999de3          	bne	s3,s1,80000112 <consolewrite+0x20>
  }

  return i;
}
    8000013c:	8526                	mv	a0,s1
    8000013e:	60a6                	ld	ra,72(sp)
    80000140:	6406                	ld	s0,64(sp)
    80000142:	74e2                	ld	s1,56(sp)
    80000144:	7942                	ld	s2,48(sp)
    80000146:	79a2                	ld	s3,40(sp)
    80000148:	7a02                	ld	s4,32(sp)
    8000014a:	6ae2                	ld	s5,24(sp)
    8000014c:	6161                	addi	sp,sp,80
    8000014e:	8082                	ret
  for(i = 0; i < n; i++){
    80000150:	4481                	li	s1,0
    80000152:	b7ed                	j	8000013c <consolewrite+0x4a>

0000000080000154 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000154:	7119                	addi	sp,sp,-128
    80000156:	fc86                	sd	ra,120(sp)
    80000158:	f8a2                	sd	s0,112(sp)
    8000015a:	f4a6                	sd	s1,104(sp)
    8000015c:	f0ca                	sd	s2,96(sp)
    8000015e:	ecce                	sd	s3,88(sp)
    80000160:	e8d2                	sd	s4,80(sp)
    80000162:	e4d6                	sd	s5,72(sp)
    80000164:	e0da                	sd	s6,64(sp)
    80000166:	fc5e                	sd	s7,56(sp)
    80000168:	f862                	sd	s8,48(sp)
    8000016a:	f466                	sd	s9,40(sp)
    8000016c:	f06a                	sd	s10,32(sp)
    8000016e:	ec6e                	sd	s11,24(sp)
    80000170:	0100                	addi	s0,sp,128
    80000172:	8caa                	mv	s9,a0
    80000174:	8aae                	mv	s5,a1
    80000176:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000178:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000017c:	00011517          	auipc	a0,0x11
    80000180:	00450513          	addi	a0,a0,4 # 80011180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	aa0080e7          	jalr	-1376(ra) # 80000c24 <acquire>
  while(n > 0){
    8000018c:	09405663          	blez	s4,80000218 <consoleread+0xc4>
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000190:	00011497          	auipc	s1,0x11
    80000194:	ff048493          	addi	s1,s1,-16 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000198:	89a6                	mv	s3,s1
    8000019a:	00011917          	auipc	s2,0x11
    8000019e:	07e90913          	addi	s2,s2,126 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001a2:	4c11                	li	s8,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001a4:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001a6:	4da9                	li	s11,10
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71463          	bne	a4,a5,800001d8 <consoleread+0x84>
      if(myproc()->killed){
    800001b4:	00002097          	auipc	ra,0x2
    800001b8:	878080e7          	jalr	-1928(ra) # 80001a2c <myproc>
    800001bc:	591c                	lw	a5,48(a0)
    800001be:	eba5                	bnez	a5,8000022e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c0:	85ce                	mv	a1,s3
    800001c2:	854a                	mv	a0,s2
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	15e080e7          	jalr	350(ra) # 80002322 <sleep>
    while(cons.r == cons.w){
    800001cc:	0984a783          	lw	a5,152(s1)
    800001d0:	09c4a703          	lw	a4,156(s1)
    800001d4:	fef700e3          	beq	a4,a5,800001b4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001d8:	0017871b          	addiw	a4,a5,1
    800001dc:	08e4ac23          	sw	a4,152(s1)
    800001e0:	07f7f713          	andi	a4,a5,127
    800001e4:	9726                	add	a4,a4,s1
    800001e6:	01874703          	lbu	a4,24(a4)
    800001ea:	00070b9b          	sext.w	s7,a4
    if(c == C('D')){  // end-of-file
    800001ee:	078b8863          	beq	s7,s8,8000025e <consoleread+0x10a>
    cbuf = c;
    800001f2:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001f6:	4685                	li	a3,1
    800001f8:	f8f40613          	addi	a2,s0,-113
    800001fc:	85d6                	mv	a1,s5
    800001fe:	8566                	mv	a0,s9
    80000200:	00002097          	auipc	ra,0x2
    80000204:	384080e7          	jalr	900(ra) # 80002584 <either_copyout>
    80000208:	01a50863          	beq	a0,s10,80000218 <consoleread+0xc4>
    dst++;
    8000020c:	0a85                	addi	s5,s5,1
    --n;
    8000020e:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000210:	01bb8463          	beq	s7,s11,80000218 <consoleread+0xc4>
  while(n > 0){
    80000214:	f80a1ae3          	bnez	s4,800001a8 <consoleread+0x54>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000218:	00011517          	auipc	a0,0x11
    8000021c:	f6850513          	addi	a0,a0,-152 # 80011180 <cons>
    80000220:	00001097          	auipc	ra,0x1
    80000224:	ab8080e7          	jalr	-1352(ra) # 80000cd8 <release>

  return target - n;
    80000228:	414b053b          	subw	a0,s6,s4
    8000022c:	a811                	j	80000240 <consoleread+0xec>
        release(&cons.lock);
    8000022e:	00011517          	auipc	a0,0x11
    80000232:	f5250513          	addi	a0,a0,-174 # 80011180 <cons>
    80000236:	00001097          	auipc	ra,0x1
    8000023a:	aa2080e7          	jalr	-1374(ra) # 80000cd8 <release>
        return -1;
    8000023e:	557d                	li	a0,-1
}
    80000240:	70e6                	ld	ra,120(sp)
    80000242:	7446                	ld	s0,112(sp)
    80000244:	74a6                	ld	s1,104(sp)
    80000246:	7906                	ld	s2,96(sp)
    80000248:	69e6                	ld	s3,88(sp)
    8000024a:	6a46                	ld	s4,80(sp)
    8000024c:	6aa6                	ld	s5,72(sp)
    8000024e:	6b06                	ld	s6,64(sp)
    80000250:	7be2                	ld	s7,56(sp)
    80000252:	7c42                	ld	s8,48(sp)
    80000254:	7ca2                	ld	s9,40(sp)
    80000256:	7d02                	ld	s10,32(sp)
    80000258:	6de2                	ld	s11,24(sp)
    8000025a:	6109                	addi	sp,sp,128
    8000025c:	8082                	ret
      if(n < target){
    8000025e:	000a071b          	sext.w	a4,s4
    80000262:	fb677be3          	bleu	s6,a4,80000218 <consoleread+0xc4>
        cons.r--;
    80000266:	00011717          	auipc	a4,0x11
    8000026a:	faf72923          	sw	a5,-78(a4) # 80011218 <cons+0x98>
    8000026e:	b76d                	j	80000218 <consoleread+0xc4>

0000000080000270 <consputc>:
{
    80000270:	1141                	addi	sp,sp,-16
    80000272:	e406                	sd	ra,8(sp)
    80000274:	e022                	sd	s0,0(sp)
    80000276:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000278:	10000793          	li	a5,256
    8000027c:	00f50a63          	beq	a0,a5,80000290 <consputc+0x20>
    uartputc_sync(c);
    80000280:	00000097          	auipc	ra,0x0
    80000284:	58a080e7          	jalr	1418(ra) # 8000080a <uartputc_sync>
}
    80000288:	60a2                	ld	ra,8(sp)
    8000028a:	6402                	ld	s0,0(sp)
    8000028c:	0141                	addi	sp,sp,16
    8000028e:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000290:	4521                	li	a0,8
    80000292:	00000097          	auipc	ra,0x0
    80000296:	578080e7          	jalr	1400(ra) # 8000080a <uartputc_sync>
    8000029a:	02000513          	li	a0,32
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	56c080e7          	jalr	1388(ra) # 8000080a <uartputc_sync>
    800002a6:	4521                	li	a0,8
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	562080e7          	jalr	1378(ra) # 8000080a <uartputc_sync>
    800002b0:	bfe1                	j	80000288 <consputc+0x18>

00000000800002b2 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002b2:	1101                	addi	sp,sp,-32
    800002b4:	ec06                	sd	ra,24(sp)
    800002b6:	e822                	sd	s0,16(sp)
    800002b8:	e426                	sd	s1,8(sp)
    800002ba:	e04a                	sd	s2,0(sp)
    800002bc:	1000                	addi	s0,sp,32
    800002be:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c0:	00011517          	auipc	a0,0x11
    800002c4:	ec050513          	addi	a0,a0,-320 # 80011180 <cons>
    800002c8:	00001097          	auipc	ra,0x1
    800002cc:	95c080e7          	jalr	-1700(ra) # 80000c24 <acquire>

  switch(c){
    800002d0:	47c1                	li	a5,16
    800002d2:	12f48463          	beq	s1,a5,800003fa <consoleintr+0x148>
    800002d6:	0297df63          	ble	s1,a5,80000314 <consoleintr+0x62>
    800002da:	47d5                	li	a5,21
    800002dc:	0af48863          	beq	s1,a5,8000038c <consoleintr+0xda>
    800002e0:	07f00793          	li	a5,127
    800002e4:	02f49b63          	bne	s1,a5,8000031a <consoleintr+0x68>
      consputc(BACKSPACE);
    }
    break;
  case C('H'): // Backspace
  case '\x7f':
    if(cons.e != cons.w){
    800002e8:	00011717          	auipc	a4,0x11
    800002ec:	e9870713          	addi	a4,a4,-360 # 80011180 <cons>
    800002f0:	0a072783          	lw	a5,160(a4)
    800002f4:	09c72703          	lw	a4,156(a4)
    800002f8:	10f70563          	beq	a4,a5,80000402 <consoleintr+0x150>
      cons.e--;
    800002fc:	37fd                	addiw	a5,a5,-1
    800002fe:	00011717          	auipc	a4,0x11
    80000302:	f2f72123          	sw	a5,-222(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    80000306:	10000513          	li	a0,256
    8000030a:	00000097          	auipc	ra,0x0
    8000030e:	f66080e7          	jalr	-154(ra) # 80000270 <consputc>
    80000312:	a8c5                	j	80000402 <consoleintr+0x150>
  switch(c){
    80000314:	47a1                	li	a5,8
    80000316:	fcf489e3          	beq	s1,a5,800002e8 <consoleintr+0x36>
    }
    break;
  default:
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000031a:	c4e5                	beqz	s1,80000402 <consoleintr+0x150>
    8000031c:	00011717          	auipc	a4,0x11
    80000320:	e6470713          	addi	a4,a4,-412 # 80011180 <cons>
    80000324:	0a072783          	lw	a5,160(a4)
    80000328:	09872703          	lw	a4,152(a4)
    8000032c:	9f99                	subw	a5,a5,a4
    8000032e:	07f00713          	li	a4,127
    80000332:	0cf76863          	bltu	a4,a5,80000402 <consoleintr+0x150>
      c = (c == '\r') ? '\n' : c;
    80000336:	47b5                	li	a5,13
    80000338:	0ef48363          	beq	s1,a5,8000041e <consoleintr+0x16c>

      // echo back to the user.
      consputc(c);
    8000033c:	8526                	mv	a0,s1
    8000033e:	00000097          	auipc	ra,0x0
    80000342:	f32080e7          	jalr	-206(ra) # 80000270 <consputc>

      // store for consumption by consoleread().
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000346:	00011797          	auipc	a5,0x11
    8000034a:	e3a78793          	addi	a5,a5,-454 # 80011180 <cons>
    8000034e:	0a07a703          	lw	a4,160(a5)
    80000352:	0017069b          	addiw	a3,a4,1
    80000356:	0006861b          	sext.w	a2,a3
    8000035a:	0ad7a023          	sw	a3,160(a5)
    8000035e:	07f77713          	andi	a4,a4,127
    80000362:	97ba                	add	a5,a5,a4
    80000364:	00978c23          	sb	s1,24(a5)

      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000368:	47a9                	li	a5,10
    8000036a:	0ef48163          	beq	s1,a5,8000044c <consoleintr+0x19a>
    8000036e:	4791                	li	a5,4
    80000370:	0cf48e63          	beq	s1,a5,8000044c <consoleintr+0x19a>
    80000374:	00011797          	auipc	a5,0x11
    80000378:	e0c78793          	addi	a5,a5,-500 # 80011180 <cons>
    8000037c:	0987a783          	lw	a5,152(a5)
    80000380:	0807879b          	addiw	a5,a5,128
    80000384:	06f61f63          	bne	a2,a5,80000402 <consoleintr+0x150>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000388:	863e                	mv	a2,a5
    8000038a:	a0c9                	j	8000044c <consoleintr+0x19a>
    while(cons.e != cons.w &&
    8000038c:	00011717          	auipc	a4,0x11
    80000390:	df470713          	addi	a4,a4,-524 # 80011180 <cons>
    80000394:	0a072783          	lw	a5,160(a4)
    80000398:	09c72703          	lw	a4,156(a4)
    8000039c:	06f70363          	beq	a4,a5,80000402 <consoleintr+0x150>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a0:	37fd                	addiw	a5,a5,-1
    800003a2:	0007871b          	sext.w	a4,a5
    800003a6:	07f7f793          	andi	a5,a5,127
    800003aa:	00011697          	auipc	a3,0x11
    800003ae:	dd668693          	addi	a3,a3,-554 # 80011180 <cons>
    800003b2:	97b6                	add	a5,a5,a3
    while(cons.e != cons.w &&
    800003b4:	0187c683          	lbu	a3,24(a5)
    800003b8:	47a9                	li	a5,10
      cons.e--;
    800003ba:	00011497          	auipc	s1,0x11
    800003be:	dc648493          	addi	s1,s1,-570 # 80011180 <cons>
    while(cons.e != cons.w &&
    800003c2:	4929                	li	s2,10
    800003c4:	02f68f63          	beq	a3,a5,80000402 <consoleintr+0x150>
      cons.e--;
    800003c8:	0ae4a023          	sw	a4,160(s1)
      consputc(BACKSPACE);
    800003cc:	10000513          	li	a0,256
    800003d0:	00000097          	auipc	ra,0x0
    800003d4:	ea0080e7          	jalr	-352(ra) # 80000270 <consputc>
    while(cons.e != cons.w &&
    800003d8:	0a04a783          	lw	a5,160(s1)
    800003dc:	09c4a703          	lw	a4,156(s1)
    800003e0:	02f70163          	beq	a4,a5,80000402 <consoleintr+0x150>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003e4:	37fd                	addiw	a5,a5,-1
    800003e6:	0007871b          	sext.w	a4,a5
    800003ea:	07f7f793          	andi	a5,a5,127
    800003ee:	97a6                	add	a5,a5,s1
    while(cons.e != cons.w &&
    800003f0:	0187c783          	lbu	a5,24(a5)
    800003f4:	fd279ae3          	bne	a5,s2,800003c8 <consoleintr+0x116>
    800003f8:	a029                	j	80000402 <consoleintr+0x150>
    procdump();
    800003fa:	00002097          	auipc	ra,0x2
    800003fe:	236080e7          	jalr	566(ra) # 80002630 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000402:	00011517          	auipc	a0,0x11
    80000406:	d7e50513          	addi	a0,a0,-642 # 80011180 <cons>
    8000040a:	00001097          	auipc	ra,0x1
    8000040e:	8ce080e7          	jalr	-1842(ra) # 80000cd8 <release>
}
    80000412:	60e2                	ld	ra,24(sp)
    80000414:	6442                	ld	s0,16(sp)
    80000416:	64a2                	ld	s1,8(sp)
    80000418:	6902                	ld	s2,0(sp)
    8000041a:	6105                	addi	sp,sp,32
    8000041c:	8082                	ret
      consputc(c);
    8000041e:	4529                	li	a0,10
    80000420:	00000097          	auipc	ra,0x0
    80000424:	e50080e7          	jalr	-432(ra) # 80000270 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000428:	00011797          	auipc	a5,0x11
    8000042c:	d5878793          	addi	a5,a5,-680 # 80011180 <cons>
    80000430:	0a07a703          	lw	a4,160(a5)
    80000434:	0017069b          	addiw	a3,a4,1
    80000438:	0006861b          	sext.w	a2,a3
    8000043c:	0ad7a023          	sw	a3,160(a5)
    80000440:	07f77713          	andi	a4,a4,127
    80000444:	97ba                	add	a5,a5,a4
    80000446:	4729                	li	a4,10
    80000448:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000044c:	00011797          	auipc	a5,0x11
    80000450:	dcc7a823          	sw	a2,-560(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    80000454:	00011517          	auipc	a0,0x11
    80000458:	dc450513          	addi	a0,a0,-572 # 80011218 <cons+0x98>
    8000045c:	00002097          	auipc	ra,0x2
    80000460:	04c080e7          	jalr	76(ra) # 800024a8 <wakeup>
    80000464:	bf79                	j	80000402 <consoleintr+0x150>

0000000080000466 <consoleinit>:

void
consoleinit(void)
{
    80000466:	1141                	addi	sp,sp,-16
    80000468:	e406                	sd	ra,8(sp)
    8000046a:	e022                	sd	s0,0(sp)
    8000046c:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000046e:	00008597          	auipc	a1,0x8
    80000472:	ba258593          	addi	a1,a1,-1118 # 80008010 <etext+0x10>
    80000476:	00011517          	auipc	a0,0x11
    8000047a:	d0a50513          	addi	a0,a0,-758 # 80011180 <cons>
    8000047e:	00000097          	auipc	ra,0x0
    80000482:	716080e7          	jalr	1814(ra) # 80000b94 <initlock>

  uartinit();
    80000486:	00000097          	auipc	ra,0x0
    8000048a:	334080e7          	jalr	820(ra) # 800007ba <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000048e:	0002d797          	auipc	a5,0x2d
    80000492:	e7278793          	addi	a5,a5,-398 # 8002d300 <devsw>
    80000496:	00000717          	auipc	a4,0x0
    8000049a:	cbe70713          	addi	a4,a4,-834 # 80000154 <consoleread>
    8000049e:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004a0:	00000717          	auipc	a4,0x0
    800004a4:	c5270713          	addi	a4,a4,-942 # 800000f2 <consolewrite>
    800004a8:	ef98                	sd	a4,24(a5)
}
    800004aa:	60a2                	ld	ra,8(sp)
    800004ac:	6402                	ld	s0,0(sp)
    800004ae:	0141                	addi	sp,sp,16
    800004b0:	8082                	ret

00000000800004b2 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004b2:	7179                	addi	sp,sp,-48
    800004b4:	f406                	sd	ra,40(sp)
    800004b6:	f022                	sd	s0,32(sp)
    800004b8:	ec26                	sd	s1,24(sp)
    800004ba:	e84a                	sd	s2,16(sp)
    800004bc:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004be:	c219                	beqz	a2,800004c4 <printint+0x12>
    800004c0:	00054d63          	bltz	a0,800004da <printint+0x28>
    x = -xx;
  else
    x = xx;
    800004c4:	2501                	sext.w	a0,a0
    800004c6:	4881                	li	a7,0
    800004c8:	fd040713          	addi	a4,s0,-48

  i = 0;
    800004cc:	4601                	li	a2,0
  do {
    buf[i++] = digits[x % base];
    800004ce:	2581                	sext.w	a1,a1
    800004d0:	00008817          	auipc	a6,0x8
    800004d4:	b4880813          	addi	a6,a6,-1208 # 80008018 <digits>
    800004d8:	a801                	j	800004e8 <printint+0x36>
    x = -xx;
    800004da:	40a0053b          	negw	a0,a0
    800004de:	2501                	sext.w	a0,a0
  if(sign && (sign = xx < 0))
    800004e0:	4885                	li	a7,1
    x = -xx;
    800004e2:	b7dd                	j	800004c8 <printint+0x16>
  } while((x /= base) != 0);
    800004e4:	853e                	mv	a0,a5
    buf[i++] = digits[x % base];
    800004e6:	8636                	mv	a2,a3
    800004e8:	0016069b          	addiw	a3,a2,1
    800004ec:	02b577bb          	remuw	a5,a0,a1
    800004f0:	1782                	slli	a5,a5,0x20
    800004f2:	9381                	srli	a5,a5,0x20
    800004f4:	97c2                	add	a5,a5,a6
    800004f6:	0007c783          	lbu	a5,0(a5)
    800004fa:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    800004fe:	0705                	addi	a4,a4,1
    80000500:	02b557bb          	divuw	a5,a0,a1
    80000504:	feb570e3          	bleu	a1,a0,800004e4 <printint+0x32>

  if(sign)
    80000508:	00088b63          	beqz	a7,8000051e <printint+0x6c>
    buf[i++] = '-';
    8000050c:	fe040793          	addi	a5,s0,-32
    80000510:	96be                	add	a3,a3,a5
    80000512:	02d00793          	li	a5,45
    80000516:	fef68823          	sb	a5,-16(a3)
    8000051a:	0026069b          	addiw	a3,a2,2

  while(--i >= 0)
    8000051e:	02d05763          	blez	a3,8000054c <printint+0x9a>
    80000522:	fd040793          	addi	a5,s0,-48
    80000526:	00d784b3          	add	s1,a5,a3
    8000052a:	fff78913          	addi	s2,a5,-1
    8000052e:	9936                	add	s2,s2,a3
    80000530:	36fd                	addiw	a3,a3,-1
    80000532:	1682                	slli	a3,a3,0x20
    80000534:	9281                	srli	a3,a3,0x20
    80000536:	40d90933          	sub	s2,s2,a3
    consputc(buf[i]);
    8000053a:	fff4c503          	lbu	a0,-1(s1)
    8000053e:	00000097          	auipc	ra,0x0
    80000542:	d32080e7          	jalr	-718(ra) # 80000270 <consputc>
  while(--i >= 0)
    80000546:	14fd                	addi	s1,s1,-1
    80000548:	ff2499e3          	bne	s1,s2,8000053a <printint+0x88>
}
    8000054c:	70a2                	ld	ra,40(sp)
    8000054e:	7402                	ld	s0,32(sp)
    80000550:	64e2                	ld	s1,24(sp)
    80000552:	6942                	ld	s2,16(sp)
    80000554:	6145                	addi	sp,sp,48
    80000556:	8082                	ret

0000000080000558 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000558:	1101                	addi	sp,sp,-32
    8000055a:	ec06                	sd	ra,24(sp)
    8000055c:	e822                	sd	s0,16(sp)
    8000055e:	e426                	sd	s1,8(sp)
    80000560:	1000                	addi	s0,sp,32
    80000562:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000564:	00011797          	auipc	a5,0x11
    80000568:	cc07ae23          	sw	zero,-804(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	ac450513          	addi	a0,a0,-1340 # 80008030 <digits+0x18>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	02e080e7          	jalr	46(ra) # 800005a2 <printf>
  printf(s);
    8000057c:	8526                	mv	a0,s1
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	024080e7          	jalr	36(ra) # 800005a2 <printf>
  printf("\n");
    80000586:	00008517          	auipc	a0,0x8
    8000058a:	b4250513          	addi	a0,a0,-1214 # 800080c8 <digits+0xb0>
    8000058e:	00000097          	auipc	ra,0x0
    80000592:	014080e7          	jalr	20(ra) # 800005a2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000596:	4785                	li	a5,1
    80000598:	00009717          	auipc	a4,0x9
    8000059c:	a6f72423          	sw	a5,-1432(a4) # 80009000 <panicked>
  for(;;)
    800005a0:	a001                	j	800005a0 <panic+0x48>

00000000800005a2 <printf>:
{
    800005a2:	7131                	addi	sp,sp,-192
    800005a4:	fc86                	sd	ra,120(sp)
    800005a6:	f8a2                	sd	s0,112(sp)
    800005a8:	f4a6                	sd	s1,104(sp)
    800005aa:	f0ca                	sd	s2,96(sp)
    800005ac:	ecce                	sd	s3,88(sp)
    800005ae:	e8d2                	sd	s4,80(sp)
    800005b0:	e4d6                	sd	s5,72(sp)
    800005b2:	e0da                	sd	s6,64(sp)
    800005b4:	fc5e                	sd	s7,56(sp)
    800005b6:	f862                	sd	s8,48(sp)
    800005b8:	f466                	sd	s9,40(sp)
    800005ba:	f06a                	sd	s10,32(sp)
    800005bc:	ec6e                	sd	s11,24(sp)
    800005be:	0100                	addi	s0,sp,128
    800005c0:	8aaa                	mv	s5,a0
    800005c2:	e40c                	sd	a1,8(s0)
    800005c4:	e810                	sd	a2,16(s0)
    800005c6:	ec14                	sd	a3,24(s0)
    800005c8:	f018                	sd	a4,32(s0)
    800005ca:	f41c                	sd	a5,40(s0)
    800005cc:	03043823          	sd	a6,48(s0)
    800005d0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005d4:	00011797          	auipc	a5,0x11
    800005d8:	c5478793          	addi	a5,a5,-940 # 80011228 <pr>
    800005dc:	0187ad83          	lw	s11,24(a5)
  if(locking)
    800005e0:	020d9b63          	bnez	s11,80000616 <printf+0x74>
  if (fmt == 0)
    800005e4:	020a8f63          	beqz	s5,80000622 <printf+0x80>
  va_start(ap, fmt);
    800005e8:	00840793          	addi	a5,s0,8
    800005ec:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005f0:	000ac503          	lbu	a0,0(s5)
    800005f4:	16050063          	beqz	a0,80000754 <printf+0x1b2>
    800005f8:	4481                	li	s1,0
    if(c != '%'){
    800005fa:	02500a13          	li	s4,37
    switch(c){
    800005fe:	07000b13          	li	s6,112
  consputc('x');
    80000602:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000604:	00008b97          	auipc	s7,0x8
    80000608:	a14b8b93          	addi	s7,s7,-1516 # 80008018 <digits>
    switch(c){
    8000060c:	07300c93          	li	s9,115
    80000610:	06400c13          	li	s8,100
    80000614:	a815                	j	80000648 <printf+0xa6>
    acquire(&pr.lock);
    80000616:	853e                	mv	a0,a5
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	60c080e7          	jalr	1548(ra) # 80000c24 <acquire>
    80000620:	b7d1                	j	800005e4 <printf+0x42>
    panic("null fmt");
    80000622:	00008517          	auipc	a0,0x8
    80000626:	a1e50513          	addi	a0,a0,-1506 # 80008040 <digits+0x28>
    8000062a:	00000097          	auipc	ra,0x0
    8000062e:	f2e080e7          	jalr	-210(ra) # 80000558 <panic>
      consputc(c);
    80000632:	00000097          	auipc	ra,0x0
    80000636:	c3e080e7          	jalr	-962(ra) # 80000270 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000063a:	2485                	addiw	s1,s1,1
    8000063c:	009a87b3          	add	a5,s5,s1
    80000640:	0007c503          	lbu	a0,0(a5)
    80000644:	10050863          	beqz	a0,80000754 <printf+0x1b2>
    if(c != '%'){
    80000648:	ff4515e3          	bne	a0,s4,80000632 <printf+0x90>
    c = fmt[++i] & 0xff;
    8000064c:	2485                	addiw	s1,s1,1
    8000064e:	009a87b3          	add	a5,s5,s1
    80000652:	0007c783          	lbu	a5,0(a5)
    80000656:	0007891b          	sext.w	s2,a5
    if(c == 0)
    8000065a:	0e090d63          	beqz	s2,80000754 <printf+0x1b2>
    switch(c){
    8000065e:	05678a63          	beq	a5,s6,800006b2 <printf+0x110>
    80000662:	02fb7663          	bleu	a5,s6,8000068e <printf+0xec>
    80000666:	09978963          	beq	a5,s9,800006f8 <printf+0x156>
    8000066a:	07800713          	li	a4,120
    8000066e:	0ce79863          	bne	a5,a4,8000073e <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000672:	f8843783          	ld	a5,-120(s0)
    80000676:	00878713          	addi	a4,a5,8
    8000067a:	f8e43423          	sd	a4,-120(s0)
    8000067e:	4605                	li	a2,1
    80000680:	85ea                	mv	a1,s10
    80000682:	4388                	lw	a0,0(a5)
    80000684:	00000097          	auipc	ra,0x0
    80000688:	e2e080e7          	jalr	-466(ra) # 800004b2 <printint>
      break;
    8000068c:	b77d                	j	8000063a <printf+0x98>
    switch(c){
    8000068e:	0b478263          	beq	a5,s4,80000732 <printf+0x190>
    80000692:	0b879663          	bne	a5,s8,8000073e <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4605                	li	a2,1
    800006a4:	45a9                	li	a1,10
    800006a6:	4388                	lw	a0,0(a5)
    800006a8:	00000097          	auipc	ra,0x0
    800006ac:	e0a080e7          	jalr	-502(ra) # 800004b2 <printint>
      break;
    800006b0:	b769                	j	8000063a <printf+0x98>
      printptr(va_arg(ap, uint64));
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006c2:	03000513          	li	a0,48
    800006c6:	00000097          	auipc	ra,0x0
    800006ca:	baa080e7          	jalr	-1110(ra) # 80000270 <consputc>
  consputc('x');
    800006ce:	07800513          	li	a0,120
    800006d2:	00000097          	auipc	ra,0x0
    800006d6:	b9e080e7          	jalr	-1122(ra) # 80000270 <consputc>
    800006da:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006dc:	03c9d793          	srli	a5,s3,0x3c
    800006e0:	97de                	add	a5,a5,s7
    800006e2:	0007c503          	lbu	a0,0(a5)
    800006e6:	00000097          	auipc	ra,0x0
    800006ea:	b8a080e7          	jalr	-1142(ra) # 80000270 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006ee:	0992                	slli	s3,s3,0x4
    800006f0:	397d                	addiw	s2,s2,-1
    800006f2:	fe0915e3          	bnez	s2,800006dc <printf+0x13a>
    800006f6:	b791                	j	8000063a <printf+0x98>
      if((s = va_arg(ap, char*)) == 0)
    800006f8:	f8843783          	ld	a5,-120(s0)
    800006fc:	00878713          	addi	a4,a5,8
    80000700:	f8e43423          	sd	a4,-120(s0)
    80000704:	0007b903          	ld	s2,0(a5)
    80000708:	00090e63          	beqz	s2,80000724 <printf+0x182>
      for(; *s; s++)
    8000070c:	00094503          	lbu	a0,0(s2)
    80000710:	d50d                	beqz	a0,8000063a <printf+0x98>
        consputc(*s);
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b5e080e7          	jalr	-1186(ra) # 80000270 <consputc>
      for(; *s; s++)
    8000071a:	0905                	addi	s2,s2,1
    8000071c:	00094503          	lbu	a0,0(s2)
    80000720:	f96d                	bnez	a0,80000712 <printf+0x170>
    80000722:	bf21                	j	8000063a <printf+0x98>
        s = "(null)";
    80000724:	00008917          	auipc	s2,0x8
    80000728:	91490913          	addi	s2,s2,-1772 # 80008038 <digits+0x20>
      for(; *s; s++)
    8000072c:	02800513          	li	a0,40
    80000730:	b7cd                	j	80000712 <printf+0x170>
      consputc('%');
    80000732:	8552                	mv	a0,s4
    80000734:	00000097          	auipc	ra,0x0
    80000738:	b3c080e7          	jalr	-1220(ra) # 80000270 <consputc>
      break;
    8000073c:	bdfd                	j	8000063a <printf+0x98>
      consputc('%');
    8000073e:	8552                	mv	a0,s4
    80000740:	00000097          	auipc	ra,0x0
    80000744:	b30080e7          	jalr	-1232(ra) # 80000270 <consputc>
      consputc(c);
    80000748:	854a                	mv	a0,s2
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	b26080e7          	jalr	-1242(ra) # 80000270 <consputc>
      break;
    80000752:	b5e5                	j	8000063a <printf+0x98>
  if(locking)
    80000754:	020d9163          	bnez	s11,80000776 <printf+0x1d4>
}
    80000758:	70e6                	ld	ra,120(sp)
    8000075a:	7446                	ld	s0,112(sp)
    8000075c:	74a6                	ld	s1,104(sp)
    8000075e:	7906                	ld	s2,96(sp)
    80000760:	69e6                	ld	s3,88(sp)
    80000762:	6a46                	ld	s4,80(sp)
    80000764:	6aa6                	ld	s5,72(sp)
    80000766:	6b06                	ld	s6,64(sp)
    80000768:	7be2                	ld	s7,56(sp)
    8000076a:	7c42                	ld	s8,48(sp)
    8000076c:	7ca2                	ld	s9,40(sp)
    8000076e:	7d02                	ld	s10,32(sp)
    80000770:	6de2                	ld	s11,24(sp)
    80000772:	6129                	addi	sp,sp,192
    80000774:	8082                	ret
    release(&pr.lock);
    80000776:	00011517          	auipc	a0,0x11
    8000077a:	ab250513          	addi	a0,a0,-1358 # 80011228 <pr>
    8000077e:	00000097          	auipc	ra,0x0
    80000782:	55a080e7          	jalr	1370(ra) # 80000cd8 <release>
}
    80000786:	bfc9                	j	80000758 <printf+0x1b6>

0000000080000788 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000788:	1101                	addi	sp,sp,-32
    8000078a:	ec06                	sd	ra,24(sp)
    8000078c:	e822                	sd	s0,16(sp)
    8000078e:	e426                	sd	s1,8(sp)
    80000790:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000792:	00011497          	auipc	s1,0x11
    80000796:	a9648493          	addi	s1,s1,-1386 # 80011228 <pr>
    8000079a:	00008597          	auipc	a1,0x8
    8000079e:	8b658593          	addi	a1,a1,-1866 # 80008050 <digits+0x38>
    800007a2:	8526                	mv	a0,s1
    800007a4:	00000097          	auipc	ra,0x0
    800007a8:	3f0080e7          	jalr	1008(ra) # 80000b94 <initlock>
  pr.locking = 1;
    800007ac:	4785                	li	a5,1
    800007ae:	cc9c                	sw	a5,24(s1)
}
    800007b0:	60e2                	ld	ra,24(sp)
    800007b2:	6442                	ld	s0,16(sp)
    800007b4:	64a2                	ld	s1,8(sp)
    800007b6:	6105                	addi	sp,sp,32
    800007b8:	8082                	ret

00000000800007ba <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007ba:	1141                	addi	sp,sp,-16
    800007bc:	e406                	sd	ra,8(sp)
    800007be:	e022                	sd	s0,0(sp)
    800007c0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007c2:	100007b7          	lui	a5,0x10000
    800007c6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ca:	f8000713          	li	a4,-128
    800007ce:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007d2:	470d                	li	a4,3
    800007d4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007d8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007dc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007e0:	469d                	li	a3,7
    800007e2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007e6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ea:	00008597          	auipc	a1,0x8
    800007ee:	86e58593          	addi	a1,a1,-1938 # 80008058 <digits+0x40>
    800007f2:	00011517          	auipc	a0,0x11
    800007f6:	a5650513          	addi	a0,a0,-1450 # 80011248 <uart_tx_lock>
    800007fa:	00000097          	auipc	ra,0x0
    800007fe:	39a080e7          	jalr	922(ra) # 80000b94 <initlock>
}
    80000802:	60a2                	ld	ra,8(sp)
    80000804:	6402                	ld	s0,0(sp)
    80000806:	0141                	addi	sp,sp,16
    80000808:	8082                	ret

000000008000080a <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000080a:	1101                	addi	sp,sp,-32
    8000080c:	ec06                	sd	ra,24(sp)
    8000080e:	e822                	sd	s0,16(sp)
    80000810:	e426                	sd	s1,8(sp)
    80000812:	1000                	addi	s0,sp,32
    80000814:	84aa                	mv	s1,a0
  push_off();
    80000816:	00000097          	auipc	ra,0x0
    8000081a:	3c2080e7          	jalr	962(ra) # 80000bd8 <push_off>

  if(panicked){
    8000081e:	00008797          	auipc	a5,0x8
    80000822:	7e278793          	addi	a5,a5,2018 # 80009000 <panicked>
    80000826:	439c                	lw	a5,0(a5)
    80000828:	2781                	sext.w	a5,a5
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000082a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000082e:	c391                	beqz	a5,80000832 <uartputc_sync+0x28>
    for(;;)
    80000830:	a001                	j	80000830 <uartputc_sync+0x26>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000832:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000836:	0ff7f793          	andi	a5,a5,255
    8000083a:	0207f793          	andi	a5,a5,32
    8000083e:	dbf5                	beqz	a5,80000832 <uartputc_sync+0x28>
    ;
  WriteReg(THR, c);
    80000840:	0ff4f793          	andi	a5,s1,255
    80000844:	10000737          	lui	a4,0x10000
    80000848:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000084c:	00000097          	auipc	ra,0x0
    80000850:	42c080e7          	jalr	1068(ra) # 80000c78 <pop_off>
}
    80000854:	60e2                	ld	ra,24(sp)
    80000856:	6442                	ld	s0,16(sp)
    80000858:	64a2                	ld	s1,8(sp)
    8000085a:	6105                	addi	sp,sp,32
    8000085c:	8082                	ret

000000008000085e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000085e:	00008797          	auipc	a5,0x8
    80000862:	7aa78793          	addi	a5,a5,1962 # 80009008 <uart_tx_r>
    80000866:	639c                	ld	a5,0(a5)
    80000868:	00008717          	auipc	a4,0x8
    8000086c:	7a870713          	addi	a4,a4,1960 # 80009010 <uart_tx_w>
    80000870:	6318                	ld	a4,0(a4)
    80000872:	08f70563          	beq	a4,a5,800008fc <uartstart+0x9e>
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	10000737          	lui	a4,0x10000
    8000087a:	00574703          	lbu	a4,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000087e:	0ff77713          	andi	a4,a4,255
    80000882:	02077713          	andi	a4,a4,32
    80000886:	cb3d                	beqz	a4,800008fc <uartstart+0x9e>
{
    80000888:	7139                	addi	sp,sp,-64
    8000088a:	fc06                	sd	ra,56(sp)
    8000088c:	f822                	sd	s0,48(sp)
    8000088e:	f426                	sd	s1,40(sp)
    80000890:	f04a                	sd	s2,32(sp)
    80000892:	ec4e                	sd	s3,24(sp)
    80000894:	e852                	sd	s4,16(sp)
    80000896:	e456                	sd	s5,8(sp)
    80000898:	0080                	addi	s0,sp,64
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000089a:	00011a17          	auipc	s4,0x11
    8000089e:	9aea0a13          	addi	s4,s4,-1618 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    800008a2:	00008497          	auipc	s1,0x8
    800008a6:	76648493          	addi	s1,s1,1894 # 80009008 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008aa:	10000937          	lui	s2,0x10000
    if(uart_tx_w == uart_tx_r){
    800008ae:	00008997          	auipc	s3,0x8
    800008b2:	76298993          	addi	s3,s3,1890 # 80009010 <uart_tx_w>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008b6:	01f7f713          	andi	a4,a5,31
    800008ba:	9752                	add	a4,a4,s4
    800008bc:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    800008c0:	0785                	addi	a5,a5,1
    800008c2:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008c4:	8526                	mv	a0,s1
    800008c6:	00002097          	auipc	ra,0x2
    800008ca:	be2080e7          	jalr	-1054(ra) # 800024a8 <wakeup>
    WriteReg(THR, c);
    800008ce:	01590023          	sb	s5,0(s2) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008d2:	609c                	ld	a5,0(s1)
    800008d4:	0009b703          	ld	a4,0(s3)
    800008d8:	00f70963          	beq	a4,a5,800008ea <uartstart+0x8c>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008dc:	00594703          	lbu	a4,5(s2)
    800008e0:	0ff77713          	andi	a4,a4,255
    800008e4:	02077713          	andi	a4,a4,32
    800008e8:	f779                	bnez	a4,800008b6 <uartstart+0x58>
  }
}
    800008ea:	70e2                	ld	ra,56(sp)
    800008ec:	7442                	ld	s0,48(sp)
    800008ee:	74a2                	ld	s1,40(sp)
    800008f0:	7902                	ld	s2,32(sp)
    800008f2:	69e2                	ld	s3,24(sp)
    800008f4:	6a42                	ld	s4,16(sp)
    800008f6:	6aa2                	ld	s5,8(sp)
    800008f8:	6121                	addi	sp,sp,64
    800008fa:	8082                	ret
    800008fc:	8082                	ret

00000000800008fe <uartputc>:
{
    800008fe:	7179                	addi	sp,sp,-48
    80000900:	f406                	sd	ra,40(sp)
    80000902:	f022                	sd	s0,32(sp)
    80000904:	ec26                	sd	s1,24(sp)
    80000906:	e84a                	sd	s2,16(sp)
    80000908:	e44e                	sd	s3,8(sp)
    8000090a:	e052                	sd	s4,0(sp)
    8000090c:	1800                	addi	s0,sp,48
    8000090e:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    80000910:	00011517          	auipc	a0,0x11
    80000914:	93850513          	addi	a0,a0,-1736 # 80011248 <uart_tx_lock>
    80000918:	00000097          	auipc	ra,0x0
    8000091c:	30c080e7          	jalr	780(ra) # 80000c24 <acquire>
  if(panicked){
    80000920:	00008797          	auipc	a5,0x8
    80000924:	6e078793          	addi	a5,a5,1760 # 80009000 <panicked>
    80000928:	439c                	lw	a5,0(a5)
    8000092a:	2781                	sext.w	a5,a5
    8000092c:	c391                	beqz	a5,80000930 <uartputc+0x32>
    for(;;)
    8000092e:	a001                	j	8000092e <uartputc+0x30>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000930:	00008797          	auipc	a5,0x8
    80000934:	6e078793          	addi	a5,a5,1760 # 80009010 <uart_tx_w>
    80000938:	639c                	ld	a5,0(a5)
    8000093a:	00008717          	auipc	a4,0x8
    8000093e:	6ce70713          	addi	a4,a4,1742 # 80009008 <uart_tx_r>
    80000942:	6318                	ld	a4,0(a4)
    80000944:	02070713          	addi	a4,a4,32
    80000948:	02f71b63          	bne	a4,a5,8000097e <uartputc+0x80>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000094c:	00011a17          	auipc	s4,0x11
    80000950:	8fca0a13          	addi	s4,s4,-1796 # 80011248 <uart_tx_lock>
    80000954:	00008497          	auipc	s1,0x8
    80000958:	6b448493          	addi	s1,s1,1716 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000095c:	00008917          	auipc	s2,0x8
    80000960:	6b490913          	addi	s2,s2,1716 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000964:	85d2                	mv	a1,s4
    80000966:	8526                	mv	a0,s1
    80000968:	00002097          	auipc	ra,0x2
    8000096c:	9ba080e7          	jalr	-1606(ra) # 80002322 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000970:	00093783          	ld	a5,0(s2)
    80000974:	6098                	ld	a4,0(s1)
    80000976:	02070713          	addi	a4,a4,32
    8000097a:	fef705e3          	beq	a4,a5,80000964 <uartputc+0x66>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000097e:	00011497          	auipc	s1,0x11
    80000982:	8ca48493          	addi	s1,s1,-1846 # 80011248 <uart_tx_lock>
    80000986:	01f7f713          	andi	a4,a5,31
    8000098a:	9726                	add	a4,a4,s1
    8000098c:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    80000990:	0785                	addi	a5,a5,1
    80000992:	00008717          	auipc	a4,0x8
    80000996:	66f73f23          	sd	a5,1662(a4) # 80009010 <uart_tx_w>
      uartstart();
    8000099a:	00000097          	auipc	ra,0x0
    8000099e:	ec4080e7          	jalr	-316(ra) # 8000085e <uartstart>
      release(&uart_tx_lock);
    800009a2:	8526                	mv	a0,s1
    800009a4:	00000097          	auipc	ra,0x0
    800009a8:	334080e7          	jalr	820(ra) # 80000cd8 <release>
}
    800009ac:	70a2                	ld	ra,40(sp)
    800009ae:	7402                	ld	s0,32(sp)
    800009b0:	64e2                	ld	s1,24(sp)
    800009b2:	6942                	ld	s2,16(sp)
    800009b4:	69a2                	ld	s3,8(sp)
    800009b6:	6a02                	ld	s4,0(sp)
    800009b8:	6145                	addi	sp,sp,48
    800009ba:	8082                	ret

00000000800009bc <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009bc:	1141                	addi	sp,sp,-16
    800009be:	e422                	sd	s0,8(sp)
    800009c0:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009c2:	100007b7          	lui	a5,0x10000
    800009c6:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009ca:	8b85                	andi	a5,a5,1
    800009cc:	cb91                	beqz	a5,800009e0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009ce:	100007b7          	lui	a5,0x10000
    800009d2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009d6:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009da:	6422                	ld	s0,8(sp)
    800009dc:	0141                	addi	sp,sp,16
    800009de:	8082                	ret
    return -1;
    800009e0:	557d                	li	a0,-1
    800009e2:	bfe5                	j	800009da <uartgetc+0x1e>

00000000800009e4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009e4:	1101                	addi	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ee:	54fd                	li	s1,-1
    int c = uartgetc();
    800009f0:	00000097          	auipc	ra,0x0
    800009f4:	fcc080e7          	jalr	-52(ra) # 800009bc <uartgetc>
    if(c == -1)
    800009f8:	00950763          	beq	a0,s1,80000a06 <uartintr+0x22>
      break;
    consoleintr(c);
    800009fc:	00000097          	auipc	ra,0x0
    80000a00:	8b6080e7          	jalr	-1866(ra) # 800002b2 <consoleintr>
  while(1){
    80000a04:	b7f5                	j	800009f0 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a06:	00011497          	auipc	s1,0x11
    80000a0a:	84248493          	addi	s1,s1,-1982 # 80011248 <uart_tx_lock>
    80000a0e:	8526                	mv	a0,s1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	214080e7          	jalr	532(ra) # 80000c24 <acquire>
  uartstart();
    80000a18:	00000097          	auipc	ra,0x0
    80000a1c:	e46080e7          	jalr	-442(ra) # 8000085e <uartstart>
  release(&uart_tx_lock);
    80000a20:	8526                	mv	a0,s1
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	2b6080e7          	jalr	694(ra) # 80000cd8 <release>
}
    80000a2a:	60e2                	ld	ra,24(sp)
    80000a2c:	6442                	ld	s0,16(sp)
    80000a2e:	64a2                	ld	s1,8(sp)
    80000a30:	6105                	addi	sp,sp,32
    80000a32:	8082                	ret

0000000080000a34 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a34:	1101                	addi	sp,sp,-32
    80000a36:	ec06                	sd	ra,24(sp)
    80000a38:	e822                	sd	s0,16(sp)
    80000a3a:	e426                	sd	s1,8(sp)
    80000a3c:	e04a                	sd	s2,0(sp)
    80000a3e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a40:	6785                	lui	a5,0x1
    80000a42:	17fd                	addi	a5,a5,-1
    80000a44:	8fe9                	and	a5,a5,a0
    80000a46:	ebb9                	bnez	a5,80000a9c <kfree+0x68>
    80000a48:	84aa                	mv	s1,a0
    80000a4a:	00031797          	auipc	a5,0x31
    80000a4e:	5b678793          	addi	a5,a5,1462 # 80032000 <end>
    80000a52:	04f56563          	bltu	a0,a5,80000a9c <kfree+0x68>
    80000a56:	47c5                	li	a5,17
    80000a58:	07ee                	slli	a5,a5,0x1b
    80000a5a:	04f57163          	bleu	a5,a0,80000a9c <kfree+0x68>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a5e:	6605                	lui	a2,0x1
    80000a60:	4585                	li	a1,1
    80000a62:	00000097          	auipc	ra,0x0
    80000a66:	2be080e7          	jalr	702(ra) # 80000d20 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a6a:	00011917          	auipc	s2,0x11
    80000a6e:	81690913          	addi	s2,s2,-2026 # 80011280 <kmem>
    80000a72:	854a                	mv	a0,s2
    80000a74:	00000097          	auipc	ra,0x0
    80000a78:	1b0080e7          	jalr	432(ra) # 80000c24 <acquire>
  r->next = kmem.freelist;
    80000a7c:	01893783          	ld	a5,24(s2)
    80000a80:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a82:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a86:	854a                	mv	a0,s2
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	250080e7          	jalr	592(ra) # 80000cd8 <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00007517          	auipc	a0,0x7
    80000aa0:	5c450513          	addi	a0,a0,1476 # 80008060 <digits+0x48>
    80000aa4:	00000097          	auipc	ra,0x0
    80000aa8:	ab4080e7          	jalr	-1356(ra) # 80000558 <panic>

0000000080000aac <freerange>:
{
    80000aac:	7179                	addi	sp,sp,-48
    80000aae:	f406                	sd	ra,40(sp)
    80000ab0:	f022                	sd	s0,32(sp)
    80000ab2:	ec26                	sd	s1,24(sp)
    80000ab4:	e84a                	sd	s2,16(sp)
    80000ab6:	e44e                	sd	s3,8(sp)
    80000ab8:	e052                	sd	s4,0(sp)
    80000aba:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000abc:	6705                	lui	a4,0x1
    80000abe:	fff70793          	addi	a5,a4,-1 # fff <_entry-0x7ffff001>
    80000ac2:	00f504b3          	add	s1,a0,a5
    80000ac6:	77fd                	lui	a5,0xfffff
    80000ac8:	8cfd                	and	s1,s1,a5
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aca:	94ba                	add	s1,s1,a4
    80000acc:	0095ee63          	bltu	a1,s1,80000ae8 <freerange+0x3c>
    80000ad0:	892e                	mv	s2,a1
    kfree(p);
    80000ad2:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad4:	6985                	lui	s3,0x1
    kfree(p);
    80000ad6:	01448533          	add	a0,s1,s4
    80000ada:	00000097          	auipc	ra,0x0
    80000ade:	f5a080e7          	jalr	-166(ra) # 80000a34 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae2:	94ce                	add	s1,s1,s3
    80000ae4:	fe9979e3          	bleu	s1,s2,80000ad6 <freerange+0x2a>
}
    80000ae8:	70a2                	ld	ra,40(sp)
    80000aea:	7402                	ld	s0,32(sp)
    80000aec:	64e2                	ld	s1,24(sp)
    80000aee:	6942                	ld	s2,16(sp)
    80000af0:	69a2                	ld	s3,8(sp)
    80000af2:	6a02                	ld	s4,0(sp)
    80000af4:	6145                	addi	sp,sp,48
    80000af6:	8082                	ret

0000000080000af8 <kinit>:
{
    80000af8:	1141                	addi	sp,sp,-16
    80000afa:	e406                	sd	ra,8(sp)
    80000afc:	e022                	sd	s0,0(sp)
    80000afe:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b00:	00007597          	auipc	a1,0x7
    80000b04:	56858593          	addi	a1,a1,1384 # 80008068 <digits+0x50>
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	77850513          	addi	a0,a0,1912 # 80011280 <kmem>
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	084080e7          	jalr	132(ra) # 80000b94 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b18:	45c5                	li	a1,17
    80000b1a:	05ee                	slli	a1,a1,0x1b
    80000b1c:	00031517          	auipc	a0,0x31
    80000b20:	4e450513          	addi	a0,a0,1252 # 80032000 <end>
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	f88080e7          	jalr	-120(ra) # 80000aac <freerange>
}
    80000b2c:	60a2                	ld	ra,8(sp)
    80000b2e:	6402                	ld	s0,0(sp)
    80000b30:	0141                	addi	sp,sp,16
    80000b32:	8082                	ret

0000000080000b34 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b34:	1101                	addi	sp,sp,-32
    80000b36:	ec06                	sd	ra,24(sp)
    80000b38:	e822                	sd	s0,16(sp)
    80000b3a:	e426                	sd	s1,8(sp)
    80000b3c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b3e:	00010497          	auipc	s1,0x10
    80000b42:	74248493          	addi	s1,s1,1858 # 80011280 <kmem>
    80000b46:	8526                	mv	a0,s1
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	0dc080e7          	jalr	220(ra) # 80000c24 <acquire>
  r = kmem.freelist;
    80000b50:	6c84                	ld	s1,24(s1)
  if(r)
    80000b52:	c885                	beqz	s1,80000b82 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b54:	609c                	ld	a5,0(s1)
    80000b56:	00010517          	auipc	a0,0x10
    80000b5a:	72a50513          	addi	a0,a0,1834 # 80011280 <kmem>
    80000b5e:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b60:	00000097          	auipc	ra,0x0
    80000b64:	178080e7          	jalr	376(ra) # 80000cd8 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b68:	6605                	lui	a2,0x1
    80000b6a:	4595                	li	a1,5
    80000b6c:	8526                	mv	a0,s1
    80000b6e:	00000097          	auipc	ra,0x0
    80000b72:	1b2080e7          	jalr	434(ra) # 80000d20 <memset>
  return (void*)r;
}
    80000b76:	8526                	mv	a0,s1
    80000b78:	60e2                	ld	ra,24(sp)
    80000b7a:	6442                	ld	s0,16(sp)
    80000b7c:	64a2                	ld	s1,8(sp)
    80000b7e:	6105                	addi	sp,sp,32
    80000b80:	8082                	ret
  release(&kmem.lock);
    80000b82:	00010517          	auipc	a0,0x10
    80000b86:	6fe50513          	addi	a0,a0,1790 # 80011280 <kmem>
    80000b8a:	00000097          	auipc	ra,0x0
    80000b8e:	14e080e7          	jalr	334(ra) # 80000cd8 <release>
  if(r)
    80000b92:	b7d5                	j	80000b76 <kalloc+0x42>

0000000080000b94 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b94:	1141                	addi	sp,sp,-16
    80000b96:	e422                	sd	s0,8(sp)
    80000b98:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b9a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b9c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000ba0:	00053823          	sd	zero,16(a0)
}
    80000ba4:	6422                	ld	s0,8(sp)
    80000ba6:	0141                	addi	sp,sp,16
    80000ba8:	8082                	ret

0000000080000baa <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000baa:	411c                	lw	a5,0(a0)
    80000bac:	e399                	bnez	a5,80000bb2 <holding+0x8>
    80000bae:	4501                	li	a0,0
  return r;
}
    80000bb0:	8082                	ret
{
    80000bb2:	1101                	addi	sp,sp,-32
    80000bb4:	ec06                	sd	ra,24(sp)
    80000bb6:	e822                	sd	s0,16(sp)
    80000bb8:	e426                	sd	s1,8(sp)
    80000bba:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bbc:	6904                	ld	s1,16(a0)
    80000bbe:	00001097          	auipc	ra,0x1
    80000bc2:	e52080e7          	jalr	-430(ra) # 80001a10 <mycpu>
    80000bc6:	40a48533          	sub	a0,s1,a0
    80000bca:	00153513          	seqz	a0,a0
}
    80000bce:	60e2                	ld	ra,24(sp)
    80000bd0:	6442                	ld	s0,16(sp)
    80000bd2:	64a2                	ld	s1,8(sp)
    80000bd4:	6105                	addi	sp,sp,32
    80000bd6:	8082                	ret

0000000080000bd8 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bd8:	1101                	addi	sp,sp,-32
    80000bda:	ec06                	sd	ra,24(sp)
    80000bdc:	e822                	sd	s0,16(sp)
    80000bde:	e426                	sd	s1,8(sp)
    80000be0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000be2:	100024f3          	csrr	s1,sstatus
    80000be6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bea:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bec:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bf0:	00001097          	auipc	ra,0x1
    80000bf4:	e20080e7          	jalr	-480(ra) # 80001a10 <mycpu>
    80000bf8:	5d3c                	lw	a5,120(a0)
    80000bfa:	cf89                	beqz	a5,80000c14 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bfc:	00001097          	auipc	ra,0x1
    80000c00:	e14080e7          	jalr	-492(ra) # 80001a10 <mycpu>
    80000c04:	5d3c                	lw	a5,120(a0)
    80000c06:	2785                	addiw	a5,a5,1
    80000c08:	dd3c                	sw	a5,120(a0)
}
    80000c0a:	60e2                	ld	ra,24(sp)
    80000c0c:	6442                	ld	s0,16(sp)
    80000c0e:	64a2                	ld	s1,8(sp)
    80000c10:	6105                	addi	sp,sp,32
    80000c12:	8082                	ret
    mycpu()->intena = old;
    80000c14:	00001097          	auipc	ra,0x1
    80000c18:	dfc080e7          	jalr	-516(ra) # 80001a10 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c1c:	8085                	srli	s1,s1,0x1
    80000c1e:	8885                	andi	s1,s1,1
    80000c20:	dd64                	sw	s1,124(a0)
    80000c22:	bfe9                	j	80000bfc <push_off+0x24>

0000000080000c24 <acquire>:
{
    80000c24:	1101                	addi	sp,sp,-32
    80000c26:	ec06                	sd	ra,24(sp)
    80000c28:	e822                	sd	s0,16(sp)
    80000c2a:	e426                	sd	s1,8(sp)
    80000c2c:	1000                	addi	s0,sp,32
    80000c2e:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c30:	00000097          	auipc	ra,0x0
    80000c34:	fa8080e7          	jalr	-88(ra) # 80000bd8 <push_off>
  if(holding(lk))
    80000c38:	8526                	mv	a0,s1
    80000c3a:	00000097          	auipc	ra,0x0
    80000c3e:	f70080e7          	jalr	-144(ra) # 80000baa <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c42:	4705                	li	a4,1
  if(holding(lk))
    80000c44:	e115                	bnez	a0,80000c68 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c46:	87ba                	mv	a5,a4
    80000c48:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c4c:	2781                	sext.w	a5,a5
    80000c4e:	ffe5                	bnez	a5,80000c46 <acquire+0x22>
  __sync_synchronize();
    80000c50:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c54:	00001097          	auipc	ra,0x1
    80000c58:	dbc080e7          	jalr	-580(ra) # 80001a10 <mycpu>
    80000c5c:	e888                	sd	a0,16(s1)
}
    80000c5e:	60e2                	ld	ra,24(sp)
    80000c60:	6442                	ld	s0,16(sp)
    80000c62:	64a2                	ld	s1,8(sp)
    80000c64:	6105                	addi	sp,sp,32
    80000c66:	8082                	ret
    panic("acquire");
    80000c68:	00007517          	auipc	a0,0x7
    80000c6c:	40850513          	addi	a0,a0,1032 # 80008070 <digits+0x58>
    80000c70:	00000097          	auipc	ra,0x0
    80000c74:	8e8080e7          	jalr	-1816(ra) # 80000558 <panic>

0000000080000c78 <pop_off>:

void
pop_off(void)
{
    80000c78:	1141                	addi	sp,sp,-16
    80000c7a:	e406                	sd	ra,8(sp)
    80000c7c:	e022                	sd	s0,0(sp)
    80000c7e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c80:	00001097          	auipc	ra,0x1
    80000c84:	d90080e7          	jalr	-624(ra) # 80001a10 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c88:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c8c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c8e:	e78d                	bnez	a5,80000cb8 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c90:	5d3c                	lw	a5,120(a0)
    80000c92:	02f05b63          	blez	a5,80000cc8 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c96:	37fd                	addiw	a5,a5,-1
    80000c98:	0007871b          	sext.w	a4,a5
    80000c9c:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c9e:	eb09                	bnez	a4,80000cb0 <pop_off+0x38>
    80000ca0:	5d7c                	lw	a5,124(a0)
    80000ca2:	c799                	beqz	a5,80000cb0 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ca4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000ca8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cac:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cb0:	60a2                	ld	ra,8(sp)
    80000cb2:	6402                	ld	s0,0(sp)
    80000cb4:	0141                	addi	sp,sp,16
    80000cb6:	8082                	ret
    panic("pop_off - interruptible");
    80000cb8:	00007517          	auipc	a0,0x7
    80000cbc:	3c050513          	addi	a0,a0,960 # 80008078 <digits+0x60>
    80000cc0:	00000097          	auipc	ra,0x0
    80000cc4:	898080e7          	jalr	-1896(ra) # 80000558 <panic>
    panic("pop_off");
    80000cc8:	00007517          	auipc	a0,0x7
    80000ccc:	3c850513          	addi	a0,a0,968 # 80008090 <digits+0x78>
    80000cd0:	00000097          	auipc	ra,0x0
    80000cd4:	888080e7          	jalr	-1912(ra) # 80000558 <panic>

0000000080000cd8 <release>:
{
    80000cd8:	1101                	addi	sp,sp,-32
    80000cda:	ec06                	sd	ra,24(sp)
    80000cdc:	e822                	sd	s0,16(sp)
    80000cde:	e426                	sd	s1,8(sp)
    80000ce0:	1000                	addi	s0,sp,32
    80000ce2:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ce4:	00000097          	auipc	ra,0x0
    80000ce8:	ec6080e7          	jalr	-314(ra) # 80000baa <holding>
    80000cec:	c115                	beqz	a0,80000d10 <release+0x38>
  lk->cpu = 0;
    80000cee:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cf2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cf6:	0f50000f          	fence	iorw,ow
    80000cfa:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cfe:	00000097          	auipc	ra,0x0
    80000d02:	f7a080e7          	jalr	-134(ra) # 80000c78 <pop_off>
}
    80000d06:	60e2                	ld	ra,24(sp)
    80000d08:	6442                	ld	s0,16(sp)
    80000d0a:	64a2                	ld	s1,8(sp)
    80000d0c:	6105                	addi	sp,sp,32
    80000d0e:	8082                	ret
    panic("release");
    80000d10:	00007517          	auipc	a0,0x7
    80000d14:	38850513          	addi	a0,a0,904 # 80008098 <digits+0x80>
    80000d18:	00000097          	auipc	ra,0x0
    80000d1c:	840080e7          	jalr	-1984(ra) # 80000558 <panic>

0000000080000d20 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d20:	1141                	addi	sp,sp,-16
    80000d22:	e422                	sd	s0,8(sp)
    80000d24:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d26:	ce09                	beqz	a2,80000d40 <memset+0x20>
    80000d28:	87aa                	mv	a5,a0
    80000d2a:	fff6071b          	addiw	a4,a2,-1
    80000d2e:	1702                	slli	a4,a4,0x20
    80000d30:	9301                	srli	a4,a4,0x20
    80000d32:	0705                	addi	a4,a4,1
    80000d34:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000d36:	00b78023          	sb	a1,0(a5) # fffffffffffff000 <end+0xffffffff7ffcd000>
  for(i = 0; i < n; i++){
    80000d3a:	0785                	addi	a5,a5,1
    80000d3c:	fee79de3          	bne	a5,a4,80000d36 <memset+0x16>
  }
  return dst;
}
    80000d40:	6422                	ld	s0,8(sp)
    80000d42:	0141                	addi	sp,sp,16
    80000d44:	8082                	ret

0000000080000d46 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d46:	1141                	addi	sp,sp,-16
    80000d48:	e422                	sd	s0,8(sp)
    80000d4a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d4c:	ce15                	beqz	a2,80000d88 <memcmp+0x42>
    80000d4e:	fff6069b          	addiw	a3,a2,-1
    if(*s1 != *s2)
    80000d52:	00054783          	lbu	a5,0(a0)
    80000d56:	0005c703          	lbu	a4,0(a1)
    80000d5a:	02e79063          	bne	a5,a4,80000d7a <memcmp+0x34>
    80000d5e:	1682                	slli	a3,a3,0x20
    80000d60:	9281                	srli	a3,a3,0x20
    80000d62:	0685                	addi	a3,a3,1
    80000d64:	96aa                	add	a3,a3,a0
      return *s1 - *s2;
    s1++, s2++;
    80000d66:	0505                	addi	a0,a0,1
    80000d68:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d6a:	00d50d63          	beq	a0,a3,80000d84 <memcmp+0x3e>
    if(*s1 != *s2)
    80000d6e:	00054783          	lbu	a5,0(a0)
    80000d72:	0005c703          	lbu	a4,0(a1)
    80000d76:	fee788e3          	beq	a5,a4,80000d66 <memcmp+0x20>
      return *s1 - *s2;
    80000d7a:	40e7853b          	subw	a0,a5,a4
  }

  return 0;
}
    80000d7e:	6422                	ld	s0,8(sp)
    80000d80:	0141                	addi	sp,sp,16
    80000d82:	8082                	ret
  return 0;
    80000d84:	4501                	li	a0,0
    80000d86:	bfe5                	j	80000d7e <memcmp+0x38>
    80000d88:	4501                	li	a0,0
    80000d8a:	bfd5                	j	80000d7e <memcmp+0x38>

0000000080000d8c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d8c:	1141                	addi	sp,sp,-16
    80000d8e:	e422                	sd	s0,8(sp)
    80000d90:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d92:	00a5f963          	bleu	a0,a1,80000da4 <memmove+0x18>
    80000d96:	02061713          	slli	a4,a2,0x20
    80000d9a:	9301                	srli	a4,a4,0x20
    80000d9c:	00e587b3          	add	a5,a1,a4
    80000da0:	02f56563          	bltu	a0,a5,80000dca <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000da4:	fff6069b          	addiw	a3,a2,-1
    80000da8:	ce11                	beqz	a2,80000dc4 <memmove+0x38>
    80000daa:	1682                	slli	a3,a3,0x20
    80000dac:	9281                	srli	a3,a3,0x20
    80000dae:	0685                	addi	a3,a3,1
    80000db0:	96ae                	add	a3,a3,a1
    80000db2:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000db4:	0585                	addi	a1,a1,1
    80000db6:	0785                	addi	a5,a5,1
    80000db8:	fff5c703          	lbu	a4,-1(a1)
    80000dbc:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000dc0:	fed59ae3          	bne	a1,a3,80000db4 <memmove+0x28>

  return dst;
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret
    d += n;
    80000dca:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000dcc:	fff6069b          	addiw	a3,a2,-1
    80000dd0:	da75                	beqz	a2,80000dc4 <memmove+0x38>
    80000dd2:	02069613          	slli	a2,a3,0x20
    80000dd6:	9201                	srli	a2,a2,0x20
    80000dd8:	fff64613          	not	a2,a2
    80000ddc:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000dde:	17fd                	addi	a5,a5,-1
    80000de0:	177d                	addi	a4,a4,-1
    80000de2:	0007c683          	lbu	a3,0(a5)
    80000de6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000dea:	fef61ae3          	bne	a2,a5,80000dde <memmove+0x52>
    80000dee:	bfd9                	j	80000dc4 <memmove+0x38>

0000000080000df0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000df0:	1141                	addi	sp,sp,-16
    80000df2:	e406                	sd	ra,8(sp)
    80000df4:	e022                	sd	s0,0(sp)
    80000df6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000df8:	00000097          	auipc	ra,0x0
    80000dfc:	f94080e7          	jalr	-108(ra) # 80000d8c <memmove>
}
    80000e00:	60a2                	ld	ra,8(sp)
    80000e02:	6402                	ld	s0,0(sp)
    80000e04:	0141                	addi	sp,sp,16
    80000e06:	8082                	ret

0000000080000e08 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e08:	1141                	addi	sp,sp,-16
    80000e0a:	e422                	sd	s0,8(sp)
    80000e0c:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e0e:	c229                	beqz	a2,80000e50 <strncmp+0x48>
    80000e10:	00054783          	lbu	a5,0(a0)
    80000e14:	c795                	beqz	a5,80000e40 <strncmp+0x38>
    80000e16:	0005c703          	lbu	a4,0(a1)
    80000e1a:	02f71363          	bne	a4,a5,80000e40 <strncmp+0x38>
    80000e1e:	fff6071b          	addiw	a4,a2,-1
    80000e22:	1702                	slli	a4,a4,0x20
    80000e24:	9301                	srli	a4,a4,0x20
    80000e26:	0705                	addi	a4,a4,1
    80000e28:	972a                	add	a4,a4,a0
    n--, p++, q++;
    80000e2a:	0505                	addi	a0,a0,1
    80000e2c:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e2e:	02e50363          	beq	a0,a4,80000e54 <strncmp+0x4c>
    80000e32:	00054783          	lbu	a5,0(a0)
    80000e36:	c789                	beqz	a5,80000e40 <strncmp+0x38>
    80000e38:	0005c683          	lbu	a3,0(a1)
    80000e3c:	fef687e3          	beq	a3,a5,80000e2a <strncmp+0x22>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
    80000e40:	00054503          	lbu	a0,0(a0)
    80000e44:	0005c783          	lbu	a5,0(a1)
    80000e48:	9d1d                	subw	a0,a0,a5
}
    80000e4a:	6422                	ld	s0,8(sp)
    80000e4c:	0141                	addi	sp,sp,16
    80000e4e:	8082                	ret
    return 0;
    80000e50:	4501                	li	a0,0
    80000e52:	bfe5                	j	80000e4a <strncmp+0x42>
    80000e54:	4501                	li	a0,0
    80000e56:	bfd5                	j	80000e4a <strncmp+0x42>

0000000080000e58 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e58:	1141                	addi	sp,sp,-16
    80000e5a:	e422                	sd	s0,8(sp)
    80000e5c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e5e:	872a                	mv	a4,a0
    80000e60:	a011                	j	80000e64 <strncpy+0xc>
    80000e62:	8636                	mv	a2,a3
    80000e64:	fff6069b          	addiw	a3,a2,-1
    80000e68:	00c05963          	blez	a2,80000e7a <strncpy+0x22>
    80000e6c:	0705                	addi	a4,a4,1
    80000e6e:	0005c783          	lbu	a5,0(a1)
    80000e72:	fef70fa3          	sb	a5,-1(a4)
    80000e76:	0585                	addi	a1,a1,1
    80000e78:	f7ed                	bnez	a5,80000e62 <strncpy+0xa>
    ;
  while(n-- > 0)
    80000e7a:	00d05c63          	blez	a3,80000e92 <strncpy+0x3a>
    80000e7e:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e80:	0685                	addi	a3,a3,1
    80000e82:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e86:	fff6c793          	not	a5,a3
    80000e8a:	9fb9                	addw	a5,a5,a4
    80000e8c:	9fb1                	addw	a5,a5,a2
    80000e8e:	fef049e3          	bgtz	a5,80000e80 <strncpy+0x28>
  return os;
}
    80000e92:	6422                	ld	s0,8(sp)
    80000e94:	0141                	addi	sp,sp,16
    80000e96:	8082                	ret

0000000080000e98 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e98:	1141                	addi	sp,sp,-16
    80000e9a:	e422                	sd	s0,8(sp)
    80000e9c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e9e:	02c05363          	blez	a2,80000ec4 <safestrcpy+0x2c>
    80000ea2:	fff6069b          	addiw	a3,a2,-1
    80000ea6:	1682                	slli	a3,a3,0x20
    80000ea8:	9281                	srli	a3,a3,0x20
    80000eaa:	96ae                	add	a3,a3,a1
    80000eac:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000eae:	00d58963          	beq	a1,a3,80000ec0 <safestrcpy+0x28>
    80000eb2:	0585                	addi	a1,a1,1
    80000eb4:	0785                	addi	a5,a5,1
    80000eb6:	fff5c703          	lbu	a4,-1(a1)
    80000eba:	fee78fa3          	sb	a4,-1(a5)
    80000ebe:	fb65                	bnez	a4,80000eae <safestrcpy+0x16>
    ;
  *s = 0;
    80000ec0:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ec4:	6422                	ld	s0,8(sp)
    80000ec6:	0141                	addi	sp,sp,16
    80000ec8:	8082                	ret

0000000080000eca <strlen>:

int
strlen(const char *s)
{
    80000eca:	1141                	addi	sp,sp,-16
    80000ecc:	e422                	sd	s0,8(sp)
    80000ece:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ed0:	00054783          	lbu	a5,0(a0)
    80000ed4:	cf91                	beqz	a5,80000ef0 <strlen+0x26>
    80000ed6:	0505                	addi	a0,a0,1
    80000ed8:	87aa                	mv	a5,a0
    80000eda:	4685                	li	a3,1
    80000edc:	9e89                	subw	a3,a3,a0
    80000ede:	00f6853b          	addw	a0,a3,a5
    80000ee2:	0785                	addi	a5,a5,1
    80000ee4:	fff7c703          	lbu	a4,-1(a5)
    80000ee8:	fb7d                	bnez	a4,80000ede <strlen+0x14>
    ;
  return n;
}
    80000eea:	6422                	ld	s0,8(sp)
    80000eec:	0141                	addi	sp,sp,16
    80000eee:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ef0:	4501                	li	a0,0
    80000ef2:	bfe5                	j	80000eea <strlen+0x20>

0000000080000ef4 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ef4:	1141                	addi	sp,sp,-16
    80000ef6:	e406                	sd	ra,8(sp)
    80000ef8:	e022                	sd	s0,0(sp)
    80000efa:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000efc:	00001097          	auipc	ra,0x1
    80000f00:	b04080e7          	jalr	-1276(ra) # 80001a00 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f04:	00008717          	auipc	a4,0x8
    80000f08:	11470713          	addi	a4,a4,276 # 80009018 <started>
  if(cpuid() == 0){
    80000f0c:	c139                	beqz	a0,80000f52 <main+0x5e>
    while(started == 0)
    80000f0e:	431c                	lw	a5,0(a4)
    80000f10:	2781                	sext.w	a5,a5
    80000f12:	dff5                	beqz	a5,80000f0e <main+0x1a>
      ;
    __sync_synchronize();
    80000f14:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f18:	00001097          	auipc	ra,0x1
    80000f1c:	ae8080e7          	jalr	-1304(ra) # 80001a00 <cpuid>
    80000f20:	85aa                	mv	a1,a0
    80000f22:	00007517          	auipc	a0,0x7
    80000f26:	19650513          	addi	a0,a0,406 # 800080b8 <digits+0xa0>
    80000f2a:	fffff097          	auipc	ra,0xfffff
    80000f2e:	678080e7          	jalr	1656(ra) # 800005a2 <printf>
    kvminithart();    // turn on paging
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	0d8080e7          	jalr	216(ra) # 8000100a <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f3a:	00002097          	auipc	ra,0x2
    80000f3e:	838080e7          	jalr	-1992(ra) # 80002772 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	2ee080e7          	jalr	750(ra) # 80006230 <plicinithart>
  }

  scheduler();        
    80000f4a:	00001097          	auipc	ra,0x1
    80000f4e:	090080e7          	jalr	144(ra) # 80001fda <scheduler>
    consoleinit();
    80000f52:	fffff097          	auipc	ra,0xfffff
    80000f56:	514080e7          	jalr	1300(ra) # 80000466 <consoleinit>
    printfinit();
    80000f5a:	00000097          	auipc	ra,0x0
    80000f5e:	82e080e7          	jalr	-2002(ra) # 80000788 <printfinit>
    printf("\n");
    80000f62:	00007517          	auipc	a0,0x7
    80000f66:	16650513          	addi	a0,a0,358 # 800080c8 <digits+0xb0>
    80000f6a:	fffff097          	auipc	ra,0xfffff
    80000f6e:	638080e7          	jalr	1592(ra) # 800005a2 <printf>
    printf("xv6 kernel is booting\n");
    80000f72:	00007517          	auipc	a0,0x7
    80000f76:	12e50513          	addi	a0,a0,302 # 800080a0 <digits+0x88>
    80000f7a:	fffff097          	auipc	ra,0xfffff
    80000f7e:	628080e7          	jalr	1576(ra) # 800005a2 <printf>
    printf("\n");
    80000f82:	00007517          	auipc	a0,0x7
    80000f86:	14650513          	addi	a0,a0,326 # 800080c8 <digits+0xb0>
    80000f8a:	fffff097          	auipc	ra,0xfffff
    80000f8e:	618080e7          	jalr	1560(ra) # 800005a2 <printf>
    kinit();         // physical page allocator
    80000f92:	00000097          	auipc	ra,0x0
    80000f96:	b66080e7          	jalr	-1178(ra) # 80000af8 <kinit>
    kvminit();       // create kernel page table
    80000f9a:	00000097          	auipc	ra,0x0
    80000f9e:	310080e7          	jalr	784(ra) # 800012aa <kvminit>
    kvminithart();   // turn on paging
    80000fa2:	00000097          	auipc	ra,0x0
    80000fa6:	068080e7          	jalr	104(ra) # 8000100a <kvminithart>
    procinit();      // process table
    80000faa:	00001097          	auipc	ra,0x1
    80000fae:	9be080e7          	jalr	-1602(ra) # 80001968 <procinit>
    trapinit();      // trap vectors
    80000fb2:	00001097          	auipc	ra,0x1
    80000fb6:	798080e7          	jalr	1944(ra) # 8000274a <trapinit>
    trapinithart();  // install kernel trap vector
    80000fba:	00001097          	auipc	ra,0x1
    80000fbe:	7b8080e7          	jalr	1976(ra) # 80002772 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fc2:	00005097          	auipc	ra,0x5
    80000fc6:	258080e7          	jalr	600(ra) # 8000621a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fca:	00005097          	auipc	ra,0x5
    80000fce:	266080e7          	jalr	614(ra) # 80006230 <plicinithart>
    binit();         // buffer cache
    80000fd2:	00002097          	auipc	ra,0x2
    80000fd6:	042080e7          	jalr	66(ra) # 80003014 <binit>
    iinit();         // inode cache
    80000fda:	00002097          	auipc	ra,0x2
    80000fde:	714080e7          	jalr	1812(ra) # 800036ee <iinit>
    fileinit();      // file table
    80000fe2:	00003097          	auipc	ra,0x3
    80000fe6:	6f2080e7          	jalr	1778(ra) # 800046d4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fea:	00005097          	auipc	ra,0x5
    80000fee:	368080e7          	jalr	872(ra) # 80006352 <virtio_disk_init>
    userinit();      // first user process
    80000ff2:	00001097          	auipc	ra,0x1
    80000ff6:	d3a080e7          	jalr	-710(ra) # 80001d2c <userinit>
    __sync_synchronize();
    80000ffa:	0ff0000f          	fence
    started = 1;
    80000ffe:	4785                	li	a5,1
    80001000:	00008717          	auipc	a4,0x8
    80001004:	00f72c23          	sw	a5,24(a4) # 80009018 <started>
    80001008:	b789                	j	80000f4a <main+0x56>

000000008000100a <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000100a:	1141                	addi	sp,sp,-16
    8000100c:	e422                	sd	s0,8(sp)
    8000100e:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001010:	00008797          	auipc	a5,0x8
    80001014:	01078793          	addi	a5,a5,16 # 80009020 <kernel_pagetable>
    80001018:	639c                	ld	a5,0(a5)
    8000101a:	83b1                	srli	a5,a5,0xc
    8000101c:	577d                	li	a4,-1
    8000101e:	177e                	slli	a4,a4,0x3f
    80001020:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001022:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001026:	12000073          	sfence.vma
  sfence_vma();
}
    8000102a:	6422                	ld	s0,8(sp)
    8000102c:	0141                	addi	sp,sp,16
    8000102e:	8082                	ret

0000000080001030 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001030:	7139                	addi	sp,sp,-64
    80001032:	fc06                	sd	ra,56(sp)
    80001034:	f822                	sd	s0,48(sp)
    80001036:	f426                	sd	s1,40(sp)
    80001038:	f04a                	sd	s2,32(sp)
    8000103a:	ec4e                	sd	s3,24(sp)
    8000103c:	e852                	sd	s4,16(sp)
    8000103e:	e456                	sd	s5,8(sp)
    80001040:	e05a                	sd	s6,0(sp)
    80001042:	0080                	addi	s0,sp,64
    80001044:	84aa                	mv	s1,a0
    80001046:	89ae                	mv	s3,a1
    80001048:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    8000104a:	57fd                	li	a5,-1
    8000104c:	83e9                	srli	a5,a5,0x1a
    8000104e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001050:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80001052:	04b7f263          	bleu	a1,a5,80001096 <walk+0x66>
    panic("walk");
    80001056:	00007517          	auipc	a0,0x7
    8000105a:	07a50513          	addi	a0,a0,122 # 800080d0 <digits+0xb8>
    8000105e:	fffff097          	auipc	ra,0xfffff
    80001062:	4fa080e7          	jalr	1274(ra) # 80000558 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001066:	060b0663          	beqz	s6,800010d2 <walk+0xa2>
    8000106a:	00000097          	auipc	ra,0x0
    8000106e:	aca080e7          	jalr	-1334(ra) # 80000b34 <kalloc>
    80001072:	84aa                	mv	s1,a0
    80001074:	c529                	beqz	a0,800010be <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001076:	6605                	lui	a2,0x1
    80001078:	4581                	li	a1,0
    8000107a:	00000097          	auipc	ra,0x0
    8000107e:	ca6080e7          	jalr	-858(ra) # 80000d20 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001082:	00c4d793          	srli	a5,s1,0xc
    80001086:	07aa                	slli	a5,a5,0xa
    80001088:	0017e793          	ori	a5,a5,1
    8000108c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001090:	3a5d                	addiw	s4,s4,-9
    80001092:	035a0063          	beq	s4,s5,800010b2 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001096:	0149d933          	srl	s2,s3,s4
    8000109a:	1ff97913          	andi	s2,s2,511
    8000109e:	090e                	slli	s2,s2,0x3
    800010a0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010a2:	00093483          	ld	s1,0(s2)
    800010a6:	0014f793          	andi	a5,s1,1
    800010aa:	dfd5                	beqz	a5,80001066 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010ac:	80a9                	srli	s1,s1,0xa
    800010ae:	04b2                	slli	s1,s1,0xc
    800010b0:	b7c5                	j	80001090 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010b2:	00c9d513          	srli	a0,s3,0xc
    800010b6:	1ff57513          	andi	a0,a0,511
    800010ba:	050e                	slli	a0,a0,0x3
    800010bc:	9526                	add	a0,a0,s1
}
    800010be:	70e2                	ld	ra,56(sp)
    800010c0:	7442                	ld	s0,48(sp)
    800010c2:	74a2                	ld	s1,40(sp)
    800010c4:	7902                	ld	s2,32(sp)
    800010c6:	69e2                	ld	s3,24(sp)
    800010c8:	6a42                	ld	s4,16(sp)
    800010ca:	6aa2                	ld	s5,8(sp)
    800010cc:	6b02                	ld	s6,0(sp)
    800010ce:	6121                	addi	sp,sp,64
    800010d0:	8082                	ret
        return 0;
    800010d2:	4501                	li	a0,0
    800010d4:	b7ed                	j	800010be <walk+0x8e>

00000000800010d6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010d6:	57fd                	li	a5,-1
    800010d8:	83e9                	srli	a5,a5,0x1a
    800010da:	00b7f463          	bleu	a1,a5,800010e2 <walkaddr+0xc>
    return 0;
    800010de:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010e0:	8082                	ret
{
    800010e2:	1141                	addi	sp,sp,-16
    800010e4:	e406                	sd	ra,8(sp)
    800010e6:	e022                	sd	s0,0(sp)
    800010e8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010ea:	4601                	li	a2,0
    800010ec:	00000097          	auipc	ra,0x0
    800010f0:	f44080e7          	jalr	-188(ra) # 80001030 <walk>
  if(pte == 0)
    800010f4:	c105                	beqz	a0,80001114 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010f6:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010f8:	0117f693          	andi	a3,a5,17
    800010fc:	4745                	li	a4,17
    return 0;
    800010fe:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001100:	00e68663          	beq	a3,a4,8000110c <walkaddr+0x36>
}
    80001104:	60a2                	ld	ra,8(sp)
    80001106:	6402                	ld	s0,0(sp)
    80001108:	0141                	addi	sp,sp,16
    8000110a:	8082                	ret
  pa = PTE2PA(*pte);
    8000110c:	00a7d513          	srli	a0,a5,0xa
    80001110:	0532                	slli	a0,a0,0xc
  return pa;
    80001112:	bfcd                	j	80001104 <walkaddr+0x2e>
    return 0;
    80001114:	4501                	li	a0,0
    80001116:	b7fd                	j	80001104 <walkaddr+0x2e>

0000000080001118 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001118:	715d                	addi	sp,sp,-80
    8000111a:	e486                	sd	ra,72(sp)
    8000111c:	e0a2                	sd	s0,64(sp)
    8000111e:	fc26                	sd	s1,56(sp)
    80001120:	f84a                	sd	s2,48(sp)
    80001122:	f44e                	sd	s3,40(sp)
    80001124:	f052                	sd	s4,32(sp)
    80001126:	ec56                	sd	s5,24(sp)
    80001128:	e85a                	sd	s6,16(sp)
    8000112a:	e45e                	sd	s7,8(sp)
    8000112c:	0880                	addi	s0,sp,80
    8000112e:	8aaa                	mv	s5,a0
    80001130:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001132:	79fd                	lui	s3,0xfffff
    80001134:	0135fa33          	and	s4,a1,s3
  last = PGROUNDDOWN(va + size - 1);
    80001138:	167d                	addi	a2,a2,-1
    8000113a:	962e                	add	a2,a2,a1
    8000113c:	013679b3          	and	s3,a2,s3
  a = PGROUNDDOWN(va);
    80001140:	8952                	mv	s2,s4
    80001142:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001146:	6b85                	lui	s7,0x1
    80001148:	a811                	j	8000115c <mappages+0x44>
      panic("remap");
    8000114a:	00007517          	auipc	a0,0x7
    8000114e:	f8e50513          	addi	a0,a0,-114 # 800080d8 <digits+0xc0>
    80001152:	fffff097          	auipc	ra,0xfffff
    80001156:	406080e7          	jalr	1030(ra) # 80000558 <panic>
    a += PGSIZE;
    8000115a:	995e                	add	s2,s2,s7
  for(;;){
    8000115c:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001160:	4605                	li	a2,1
    80001162:	85ca                	mv	a1,s2
    80001164:	8556                	mv	a0,s5
    80001166:	00000097          	auipc	ra,0x0
    8000116a:	eca080e7          	jalr	-310(ra) # 80001030 <walk>
    8000116e:	cd19                	beqz	a0,8000118c <mappages+0x74>
    if(*pte & PTE_V)
    80001170:	611c                	ld	a5,0(a0)
    80001172:	8b85                	andi	a5,a5,1
    80001174:	fbf9                	bnez	a5,8000114a <mappages+0x32>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001176:	80b1                	srli	s1,s1,0xc
    80001178:	04aa                	slli	s1,s1,0xa
    8000117a:	0164e4b3          	or	s1,s1,s6
    8000117e:	0014e493          	ori	s1,s1,1
    80001182:	e104                	sd	s1,0(a0)
    if(a == last)
    80001184:	fd391be3          	bne	s2,s3,8000115a <mappages+0x42>
    pa += PGSIZE;
  }
  return 0;
    80001188:	4501                	li	a0,0
    8000118a:	a011                	j	8000118e <mappages+0x76>
      return -1;
    8000118c:	557d                	li	a0,-1
}
    8000118e:	60a6                	ld	ra,72(sp)
    80001190:	6406                	ld	s0,64(sp)
    80001192:	74e2                	ld	s1,56(sp)
    80001194:	7942                	ld	s2,48(sp)
    80001196:	79a2                	ld	s3,40(sp)
    80001198:	7a02                	ld	s4,32(sp)
    8000119a:	6ae2                	ld	s5,24(sp)
    8000119c:	6b42                	ld	s6,16(sp)
    8000119e:	6ba2                	ld	s7,8(sp)
    800011a0:	6161                	addi	sp,sp,80
    800011a2:	8082                	ret

00000000800011a4 <kvmmap>:
{
    800011a4:	1141                	addi	sp,sp,-16
    800011a6:	e406                	sd	ra,8(sp)
    800011a8:	e022                	sd	s0,0(sp)
    800011aa:	0800                	addi	s0,sp,16
    800011ac:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011ae:	86b2                	mv	a3,a2
    800011b0:	863e                	mv	a2,a5
    800011b2:	00000097          	auipc	ra,0x0
    800011b6:	f66080e7          	jalr	-154(ra) # 80001118 <mappages>
    800011ba:	e509                	bnez	a0,800011c4 <kvmmap+0x20>
}
    800011bc:	60a2                	ld	ra,8(sp)
    800011be:	6402                	ld	s0,0(sp)
    800011c0:	0141                	addi	sp,sp,16
    800011c2:	8082                	ret
    panic("kvmmap");
    800011c4:	00007517          	auipc	a0,0x7
    800011c8:	f1c50513          	addi	a0,a0,-228 # 800080e0 <digits+0xc8>
    800011cc:	fffff097          	auipc	ra,0xfffff
    800011d0:	38c080e7          	jalr	908(ra) # 80000558 <panic>

00000000800011d4 <kvmmake>:
{
    800011d4:	1101                	addi	sp,sp,-32
    800011d6:	ec06                	sd	ra,24(sp)
    800011d8:	e822                	sd	s0,16(sp)
    800011da:	e426                	sd	s1,8(sp)
    800011dc:	e04a                	sd	s2,0(sp)
    800011de:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011e0:	00000097          	auipc	ra,0x0
    800011e4:	954080e7          	jalr	-1708(ra) # 80000b34 <kalloc>
    800011e8:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011ea:	6605                	lui	a2,0x1
    800011ec:	4581                	li	a1,0
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	b32080e7          	jalr	-1230(ra) # 80000d20 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	6685                	lui	a3,0x1
    800011fa:	10000637          	lui	a2,0x10000
    800011fe:	100005b7          	lui	a1,0x10000
    80001202:	8526                	mv	a0,s1
    80001204:	00000097          	auipc	ra,0x0
    80001208:	fa0080e7          	jalr	-96(ra) # 800011a4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000120c:	4719                	li	a4,6
    8000120e:	6685                	lui	a3,0x1
    80001210:	10001637          	lui	a2,0x10001
    80001214:	100015b7          	lui	a1,0x10001
    80001218:	8526                	mv	a0,s1
    8000121a:	00000097          	auipc	ra,0x0
    8000121e:	f8a080e7          	jalr	-118(ra) # 800011a4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001222:	4719                	li	a4,6
    80001224:	004006b7          	lui	a3,0x400
    80001228:	0c000637          	lui	a2,0xc000
    8000122c:	0c0005b7          	lui	a1,0xc000
    80001230:	8526                	mv	a0,s1
    80001232:	00000097          	auipc	ra,0x0
    80001236:	f72080e7          	jalr	-142(ra) # 800011a4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000123a:	00007917          	auipc	s2,0x7
    8000123e:	dc690913          	addi	s2,s2,-570 # 80008000 <etext>
    80001242:	4729                	li	a4,10
    80001244:	80007697          	auipc	a3,0x80007
    80001248:	dbc68693          	addi	a3,a3,-580 # 8000 <_entry-0x7fff8000>
    8000124c:	4605                	li	a2,1
    8000124e:	067e                	slli	a2,a2,0x1f
    80001250:	85b2                	mv	a1,a2
    80001252:	8526                	mv	a0,s1
    80001254:	00000097          	auipc	ra,0x0
    80001258:	f50080e7          	jalr	-176(ra) # 800011a4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000125c:	4719                	li	a4,6
    8000125e:	46c5                	li	a3,17
    80001260:	06ee                	slli	a3,a3,0x1b
    80001262:	412686b3          	sub	a3,a3,s2
    80001266:	864a                	mv	a2,s2
    80001268:	85ca                	mv	a1,s2
    8000126a:	8526                	mv	a0,s1
    8000126c:	00000097          	auipc	ra,0x0
    80001270:	f38080e7          	jalr	-200(ra) # 800011a4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001274:	4729                	li	a4,10
    80001276:	6685                	lui	a3,0x1
    80001278:	00006617          	auipc	a2,0x6
    8000127c:	d8860613          	addi	a2,a2,-632 # 80007000 <_trampoline>
    80001280:	040005b7          	lui	a1,0x4000
    80001284:	15fd                	addi	a1,a1,-1
    80001286:	05b2                	slli	a1,a1,0xc
    80001288:	8526                	mv	a0,s1
    8000128a:	00000097          	auipc	ra,0x0
    8000128e:	f1a080e7          	jalr	-230(ra) # 800011a4 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001292:	8526                	mv	a0,s1
    80001294:	00000097          	auipc	ra,0x0
    80001298:	63e080e7          	jalr	1598(ra) # 800018d2 <proc_mapstacks>
}
    8000129c:	8526                	mv	a0,s1
    8000129e:	60e2                	ld	ra,24(sp)
    800012a0:	6442                	ld	s0,16(sp)
    800012a2:	64a2                	ld	s1,8(sp)
    800012a4:	6902                	ld	s2,0(sp)
    800012a6:	6105                	addi	sp,sp,32
    800012a8:	8082                	ret

00000000800012aa <kvminit>:
{
    800012aa:	1141                	addi	sp,sp,-16
    800012ac:	e406                	sd	ra,8(sp)
    800012ae:	e022                	sd	s0,0(sp)
    800012b0:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012b2:	00000097          	auipc	ra,0x0
    800012b6:	f22080e7          	jalr	-222(ra) # 800011d4 <kvmmake>
    800012ba:	00008797          	auipc	a5,0x8
    800012be:	d6a7b323          	sd	a0,-666(a5) # 80009020 <kernel_pagetable>
}
    800012c2:	60a2                	ld	ra,8(sp)
    800012c4:	6402                	ld	s0,0(sp)
    800012c6:	0141                	addi	sp,sp,16
    800012c8:	8082                	ret

00000000800012ca <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012ca:	715d                	addi	sp,sp,-80
    800012cc:	e486                	sd	ra,72(sp)
    800012ce:	e0a2                	sd	s0,64(sp)
    800012d0:	fc26                	sd	s1,56(sp)
    800012d2:	f84a                	sd	s2,48(sp)
    800012d4:	f44e                	sd	s3,40(sp)
    800012d6:	f052                	sd	s4,32(sp)
    800012d8:	ec56                	sd	s5,24(sp)
    800012da:	e85a                	sd	s6,16(sp)
    800012dc:	e45e                	sd	s7,8(sp)
    800012de:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012e0:	6785                	lui	a5,0x1
    800012e2:	17fd                	addi	a5,a5,-1
    800012e4:	8fed                	and	a5,a5,a1
    800012e6:	e795                	bnez	a5,80001312 <uvmunmap+0x48>
    800012e8:	8a2a                	mv	s4,a0
    800012ea:	84ae                	mv	s1,a1
    800012ec:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	0632                	slli	a2,a2,0xc
    800012f0:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      continue;
//      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012f4:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f6:	6b05                	lui	s6,0x1
    800012f8:	0735e063          	bltu	a1,s3,80001358 <uvmunmap+0x8e>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012fc:	60a6                	ld	ra,72(sp)
    800012fe:	6406                	ld	s0,64(sp)
    80001300:	74e2                	ld	s1,56(sp)
    80001302:	7942                	ld	s2,48(sp)
    80001304:	79a2                	ld	s3,40(sp)
    80001306:	7a02                	ld	s4,32(sp)
    80001308:	6ae2                	ld	s5,24(sp)
    8000130a:	6b42                	ld	s6,16(sp)
    8000130c:	6ba2                	ld	s7,8(sp)
    8000130e:	6161                	addi	sp,sp,80
    80001310:	8082                	ret
    panic("uvmunmap: not aligned");
    80001312:	00007517          	auipc	a0,0x7
    80001316:	dd650513          	addi	a0,a0,-554 # 800080e8 <digits+0xd0>
    8000131a:	fffff097          	auipc	ra,0xfffff
    8000131e:	23e080e7          	jalr	574(ra) # 80000558 <panic>
      panic("uvmunmap: walk");
    80001322:	00007517          	auipc	a0,0x7
    80001326:	dde50513          	addi	a0,a0,-546 # 80008100 <digits+0xe8>
    8000132a:	fffff097          	auipc	ra,0xfffff
    8000132e:	22e080e7          	jalr	558(ra) # 80000558 <panic>
      panic("uvmunmap: not a leaf");
    80001332:	00007517          	auipc	a0,0x7
    80001336:	dde50513          	addi	a0,a0,-546 # 80008110 <digits+0xf8>
    8000133a:	fffff097          	auipc	ra,0xfffff
    8000133e:	21e080e7          	jalr	542(ra) # 80000558 <panic>
      uint64 pa = PTE2PA(*pte);
    80001342:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001344:	0532                	slli	a0,a0,0xc
    80001346:	fffff097          	auipc	ra,0xfffff
    8000134a:	6ee080e7          	jalr	1774(ra) # 80000a34 <kfree>
    *pte = 0;
    8000134e:	00093023          	sd	zero,0(s2)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001352:	94da                	add	s1,s1,s6
    80001354:	fb34f4e3          	bleu	s3,s1,800012fc <uvmunmap+0x32>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001358:	4601                	li	a2,0
    8000135a:	85a6                	mv	a1,s1
    8000135c:	8552                	mv	a0,s4
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	cd2080e7          	jalr	-814(ra) # 80001030 <walk>
    80001366:	892a                	mv	s2,a0
    80001368:	dd4d                	beqz	a0,80001322 <uvmunmap+0x58>
    if((*pte & PTE_V) == 0)
    8000136a:	6108                	ld	a0,0(a0)
    8000136c:	00157793          	andi	a5,a0,1
    80001370:	d3ed                	beqz	a5,80001352 <uvmunmap+0x88>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001372:	3ff57793          	andi	a5,a0,1023
    80001376:	fb778ee3          	beq	a5,s7,80001332 <uvmunmap+0x68>
    if(do_free){
    8000137a:	fc0a8ae3          	beqz	s5,8000134e <uvmunmap+0x84>
    8000137e:	b7d1                	j	80001342 <uvmunmap+0x78>

0000000080001380 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001380:	1101                	addi	sp,sp,-32
    80001382:	ec06                	sd	ra,24(sp)
    80001384:	e822                	sd	s0,16(sp)
    80001386:	e426                	sd	s1,8(sp)
    80001388:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000138a:	fffff097          	auipc	ra,0xfffff
    8000138e:	7aa080e7          	jalr	1962(ra) # 80000b34 <kalloc>
    80001392:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001394:	c519                	beqz	a0,800013a2 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001396:	6605                	lui	a2,0x1
    80001398:	4581                	li	a1,0
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	986080e7          	jalr	-1658(ra) # 80000d20 <memset>
  return pagetable;
}
    800013a2:	8526                	mv	a0,s1
    800013a4:	60e2                	ld	ra,24(sp)
    800013a6:	6442                	ld	s0,16(sp)
    800013a8:	64a2                	ld	s1,8(sp)
    800013aa:	6105                	addi	sp,sp,32
    800013ac:	8082                	ret

00000000800013ae <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800013ae:	7179                	addi	sp,sp,-48
    800013b0:	f406                	sd	ra,40(sp)
    800013b2:	f022                	sd	s0,32(sp)
    800013b4:	ec26                	sd	s1,24(sp)
    800013b6:	e84a                	sd	s2,16(sp)
    800013b8:	e44e                	sd	s3,8(sp)
    800013ba:	e052                	sd	s4,0(sp)
    800013bc:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013be:	6785                	lui	a5,0x1
    800013c0:	04f67863          	bleu	a5,a2,80001410 <uvminit+0x62>
    800013c4:	8a2a                	mv	s4,a0
    800013c6:	89ae                	mv	s3,a1
    800013c8:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013ca:	fffff097          	auipc	ra,0xfffff
    800013ce:	76a080e7          	jalr	1898(ra) # 80000b34 <kalloc>
    800013d2:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013d4:	6605                	lui	a2,0x1
    800013d6:	4581                	li	a1,0
    800013d8:	00000097          	auipc	ra,0x0
    800013dc:	948080e7          	jalr	-1720(ra) # 80000d20 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013e0:	4779                	li	a4,30
    800013e2:	86ca                	mv	a3,s2
    800013e4:	6605                	lui	a2,0x1
    800013e6:	4581                	li	a1,0
    800013e8:	8552                	mv	a0,s4
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	d2e080e7          	jalr	-722(ra) # 80001118 <mappages>
  memmove(mem, src, sz);
    800013f2:	8626                	mv	a2,s1
    800013f4:	85ce                	mv	a1,s3
    800013f6:	854a                	mv	a0,s2
    800013f8:	00000097          	auipc	ra,0x0
    800013fc:	994080e7          	jalr	-1644(ra) # 80000d8c <memmove>
}
    80001400:	70a2                	ld	ra,40(sp)
    80001402:	7402                	ld	s0,32(sp)
    80001404:	64e2                	ld	s1,24(sp)
    80001406:	6942                	ld	s2,16(sp)
    80001408:	69a2                	ld	s3,8(sp)
    8000140a:	6a02                	ld	s4,0(sp)
    8000140c:	6145                	addi	sp,sp,48
    8000140e:	8082                	ret
    panic("inituvm: more than a page");
    80001410:	00007517          	auipc	a0,0x7
    80001414:	d1850513          	addi	a0,a0,-744 # 80008128 <digits+0x110>
    80001418:	fffff097          	auipc	ra,0xfffff
    8000141c:	140080e7          	jalr	320(ra) # 80000558 <panic>

0000000080001420 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001420:	1101                	addi	sp,sp,-32
    80001422:	ec06                	sd	ra,24(sp)
    80001424:	e822                	sd	s0,16(sp)
    80001426:	e426                	sd	s1,8(sp)
    80001428:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000142a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000142c:	00b67d63          	bleu	a1,a2,80001446 <uvmdealloc+0x26>
    80001430:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001432:	6605                	lui	a2,0x1
    80001434:	167d                	addi	a2,a2,-1
    80001436:	00c487b3          	add	a5,s1,a2
    8000143a:	777d                	lui	a4,0xfffff
    8000143c:	8ff9                	and	a5,a5,a4
    8000143e:	962e                	add	a2,a2,a1
    80001440:	8e79                	and	a2,a2,a4
    80001442:	00c7e863          	bltu	a5,a2,80001452 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001446:	8526                	mv	a0,s1
    80001448:	60e2                	ld	ra,24(sp)
    8000144a:	6442                	ld	s0,16(sp)
    8000144c:	64a2                	ld	s1,8(sp)
    8000144e:	6105                	addi	sp,sp,32
    80001450:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001452:	8e1d                	sub	a2,a2,a5
    80001454:	8231                	srli	a2,a2,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001456:	4685                	li	a3,1
    80001458:	2601                	sext.w	a2,a2
    8000145a:	85be                	mv	a1,a5
    8000145c:	00000097          	auipc	ra,0x0
    80001460:	e6e080e7          	jalr	-402(ra) # 800012ca <uvmunmap>
    80001464:	b7cd                	j	80001446 <uvmdealloc+0x26>

0000000080001466 <uvmalloc>:
  if(newsz < oldsz)
    80001466:	0ab66163          	bltu	a2,a1,80001508 <uvmalloc+0xa2>
{
    8000146a:	7139                	addi	sp,sp,-64
    8000146c:	fc06                	sd	ra,56(sp)
    8000146e:	f822                	sd	s0,48(sp)
    80001470:	f426                	sd	s1,40(sp)
    80001472:	f04a                	sd	s2,32(sp)
    80001474:	ec4e                	sd	s3,24(sp)
    80001476:	e852                	sd	s4,16(sp)
    80001478:	e456                	sd	s5,8(sp)
    8000147a:	0080                	addi	s0,sp,64
  oldsz = PGROUNDUP(oldsz);
    8000147c:	6a05                	lui	s4,0x1
    8000147e:	1a7d                	addi	s4,s4,-1
    80001480:	95d2                	add	a1,a1,s4
    80001482:	7a7d                	lui	s4,0xfffff
    80001484:	0145fa33          	and	s4,a1,s4
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001488:	08ca7263          	bleu	a2,s4,8000150c <uvmalloc+0xa6>
    8000148c:	89b2                	mv	s3,a2
    8000148e:	8aaa                	mv	s5,a0
    80001490:	8952                	mv	s2,s4
    mem = kalloc();
    80001492:	fffff097          	auipc	ra,0xfffff
    80001496:	6a2080e7          	jalr	1698(ra) # 80000b34 <kalloc>
    8000149a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000149c:	c51d                	beqz	a0,800014ca <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000149e:	6605                	lui	a2,0x1
    800014a0:	4581                	li	a1,0
    800014a2:	00000097          	auipc	ra,0x0
    800014a6:	87e080e7          	jalr	-1922(ra) # 80000d20 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014aa:	4779                	li	a4,30
    800014ac:	86a6                	mv	a3,s1
    800014ae:	6605                	lui	a2,0x1
    800014b0:	85ca                	mv	a1,s2
    800014b2:	8556                	mv	a0,s5
    800014b4:	00000097          	auipc	ra,0x0
    800014b8:	c64080e7          	jalr	-924(ra) # 80001118 <mappages>
    800014bc:	e905                	bnez	a0,800014ec <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014be:	6785                	lui	a5,0x1
    800014c0:	993e                	add	s2,s2,a5
    800014c2:	fd3968e3          	bltu	s2,s3,80001492 <uvmalloc+0x2c>
  return newsz;
    800014c6:	854e                	mv	a0,s3
    800014c8:	a809                	j	800014da <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800014ca:	8652                	mv	a2,s4
    800014cc:	85ca                	mv	a1,s2
    800014ce:	8556                	mv	a0,s5
    800014d0:	00000097          	auipc	ra,0x0
    800014d4:	f50080e7          	jalr	-176(ra) # 80001420 <uvmdealloc>
      return 0;
    800014d8:	4501                	li	a0,0
}
    800014da:	70e2                	ld	ra,56(sp)
    800014dc:	7442                	ld	s0,48(sp)
    800014de:	74a2                	ld	s1,40(sp)
    800014e0:	7902                	ld	s2,32(sp)
    800014e2:	69e2                	ld	s3,24(sp)
    800014e4:	6a42                	ld	s4,16(sp)
    800014e6:	6aa2                	ld	s5,8(sp)
    800014e8:	6121                	addi	sp,sp,64
    800014ea:	8082                	ret
      kfree(mem);
    800014ec:	8526                	mv	a0,s1
    800014ee:	fffff097          	auipc	ra,0xfffff
    800014f2:	546080e7          	jalr	1350(ra) # 80000a34 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014f6:	8652                	mv	a2,s4
    800014f8:	85ca                	mv	a1,s2
    800014fa:	8556                	mv	a0,s5
    800014fc:	00000097          	auipc	ra,0x0
    80001500:	f24080e7          	jalr	-220(ra) # 80001420 <uvmdealloc>
      return 0;
    80001504:	4501                	li	a0,0
    80001506:	bfd1                	j	800014da <uvmalloc+0x74>
    return oldsz;
    80001508:	852e                	mv	a0,a1
}
    8000150a:	8082                	ret
  return newsz;
    8000150c:	8532                	mv	a0,a2
    8000150e:	b7f1                	j	800014da <uvmalloc+0x74>

0000000080001510 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001510:	7179                	addi	sp,sp,-48
    80001512:	f406                	sd	ra,40(sp)
    80001514:	f022                	sd	s0,32(sp)
    80001516:	ec26                	sd	s1,24(sp)
    80001518:	e84a                	sd	s2,16(sp)
    8000151a:	e44e                	sd	s3,8(sp)
    8000151c:	e052                	sd	s4,0(sp)
    8000151e:	1800                	addi	s0,sp,48
    80001520:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001522:	84aa                	mv	s1,a0
    80001524:	6905                	lui	s2,0x1
    80001526:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001528:	4985                	li	s3,1
    8000152a:	a821                	j	80001542 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000152c:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000152e:	0532                	slli	a0,a0,0xc
    80001530:	00000097          	auipc	ra,0x0
    80001534:	fe0080e7          	jalr	-32(ra) # 80001510 <freewalk>
      pagetable[i] = 0;
    80001538:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000153c:	04a1                	addi	s1,s1,8
    8000153e:	03248163          	beq	s1,s2,80001560 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001542:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001544:	00f57793          	andi	a5,a0,15
    80001548:	ff3782e3          	beq	a5,s3,8000152c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000154c:	8905                	andi	a0,a0,1
    8000154e:	d57d                	beqz	a0,8000153c <freewalk+0x2c>
      panic("freewalk: leaf");
    80001550:	00007517          	auipc	a0,0x7
    80001554:	bf850513          	addi	a0,a0,-1032 # 80008148 <digits+0x130>
    80001558:	fffff097          	auipc	ra,0xfffff
    8000155c:	000080e7          	jalr	ra # 80000558 <panic>
    }
  }
  kfree((void*)pagetable);
    80001560:	8552                	mv	a0,s4
    80001562:	fffff097          	auipc	ra,0xfffff
    80001566:	4d2080e7          	jalr	1234(ra) # 80000a34 <kfree>
}
    8000156a:	70a2                	ld	ra,40(sp)
    8000156c:	7402                	ld	s0,32(sp)
    8000156e:	64e2                	ld	s1,24(sp)
    80001570:	6942                	ld	s2,16(sp)
    80001572:	69a2                	ld	s3,8(sp)
    80001574:	6a02                	ld	s4,0(sp)
    80001576:	6145                	addi	sp,sp,48
    80001578:	8082                	ret

000000008000157a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000157a:	1101                	addi	sp,sp,-32
    8000157c:	ec06                	sd	ra,24(sp)
    8000157e:	e822                	sd	s0,16(sp)
    80001580:	e426                	sd	s1,8(sp)
    80001582:	1000                	addi	s0,sp,32
    80001584:	84aa                	mv	s1,a0
  if(sz > 0)
    80001586:	e999                	bnez	a1,8000159c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001588:	8526                	mv	a0,s1
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	f86080e7          	jalr	-122(ra) # 80001510 <freewalk>
}
    80001592:	60e2                	ld	ra,24(sp)
    80001594:	6442                	ld	s0,16(sp)
    80001596:	64a2                	ld	s1,8(sp)
    80001598:	6105                	addi	sp,sp,32
    8000159a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000159c:	6605                	lui	a2,0x1
    8000159e:	167d                	addi	a2,a2,-1
    800015a0:	962e                	add	a2,a2,a1
    800015a2:	4685                	li	a3,1
    800015a4:	8231                	srli	a2,a2,0xc
    800015a6:	4581                	li	a1,0
    800015a8:	00000097          	auipc	ra,0x0
    800015ac:	d22080e7          	jalr	-734(ra) # 800012ca <uvmunmap>
    800015b0:	bfe1                	j	80001588 <uvmfree+0xe>

00000000800015b2 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015b2:	c269                	beqz	a2,80001674 <uvmcopy+0xc2>
{
    800015b4:	715d                	addi	sp,sp,-80
    800015b6:	e486                	sd	ra,72(sp)
    800015b8:	e0a2                	sd	s0,64(sp)
    800015ba:	fc26                	sd	s1,56(sp)
    800015bc:	f84a                	sd	s2,48(sp)
    800015be:	f44e                	sd	s3,40(sp)
    800015c0:	f052                	sd	s4,32(sp)
    800015c2:	ec56                	sd	s5,24(sp)
    800015c4:	e85a                	sd	s6,16(sp)
    800015c6:	e45e                	sd	s7,8(sp)
    800015c8:	0880                	addi	s0,sp,80
    800015ca:	8ab2                	mv	s5,a2
    800015cc:	8bae                	mv	s7,a1
    800015ce:	8b2a                	mv	s6,a0
  for(i = 0; i < sz; i += PGSIZE){
    800015d0:	4481                	li	s1,0
    800015d2:	a829                	j	800015ec <uvmcopy+0x3a>
    if((pte = walk(old, i, 0)) == 0)
      panic("uvmcopy: pte should exist");
    800015d4:	00007517          	auipc	a0,0x7
    800015d8:	b8450513          	addi	a0,a0,-1148 # 80008158 <digits+0x140>
    800015dc:	fffff097          	auipc	ra,0xfffff
    800015e0:	f7c080e7          	jalr	-132(ra) # 80000558 <panic>
  for(i = 0; i < sz; i += PGSIZE){
    800015e4:	6785                	lui	a5,0x1
    800015e6:	94be                	add	s1,s1,a5
    800015e8:	0954f463          	bleu	s5,s1,80001670 <uvmcopy+0xbe>
    if((pte = walk(old, i, 0)) == 0)
    800015ec:	4601                	li	a2,0
    800015ee:	85a6                	mv	a1,s1
    800015f0:	855a                	mv	a0,s6
    800015f2:	00000097          	auipc	ra,0x0
    800015f6:	a3e080e7          	jalr	-1474(ra) # 80001030 <walk>
    800015fa:	dd69                	beqz	a0,800015d4 <uvmcopy+0x22>
    if((*pte & PTE_V) == 0)
    800015fc:	6118                	ld	a4,0(a0)
    800015fe:	00177793          	andi	a5,a4,1
    80001602:	d3ed                	beqz	a5,800015e4 <uvmcopy+0x32>
      continue;
//      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001604:	00a75593          	srli	a1,a4,0xa
    80001608:	00c59993          	slli	s3,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000160c:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001610:	fffff097          	auipc	ra,0xfffff
    80001614:	524080e7          	jalr	1316(ra) # 80000b34 <kalloc>
    80001618:	8a2a                	mv	s4,a0
    8000161a:	c515                	beqz	a0,80001646 <uvmcopy+0x94>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000161c:	6605                	lui	a2,0x1
    8000161e:	85ce                	mv	a1,s3
    80001620:	fffff097          	auipc	ra,0xfffff
    80001624:	76c080e7          	jalr	1900(ra) # 80000d8c <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001628:	874a                	mv	a4,s2
    8000162a:	86d2                	mv	a3,s4
    8000162c:	6605                	lui	a2,0x1
    8000162e:	85a6                	mv	a1,s1
    80001630:	855e                	mv	a0,s7
    80001632:	00000097          	auipc	ra,0x0
    80001636:	ae6080e7          	jalr	-1306(ra) # 80001118 <mappages>
    8000163a:	d54d                	beqz	a0,800015e4 <uvmcopy+0x32>
      kfree(mem);
    8000163c:	8552                	mv	a0,s4
    8000163e:	fffff097          	auipc	ra,0xfffff
    80001642:	3f6080e7          	jalr	1014(ra) # 80000a34 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001646:	4685                	li	a3,1
    80001648:	00c4d613          	srli	a2,s1,0xc
    8000164c:	4581                	li	a1,0
    8000164e:	855e                	mv	a0,s7
    80001650:	00000097          	auipc	ra,0x0
    80001654:	c7a080e7          	jalr	-902(ra) # 800012ca <uvmunmap>
  return -1;
    80001658:	557d                	li	a0,-1
}
    8000165a:	60a6                	ld	ra,72(sp)
    8000165c:	6406                	ld	s0,64(sp)
    8000165e:	74e2                	ld	s1,56(sp)
    80001660:	7942                	ld	s2,48(sp)
    80001662:	79a2                	ld	s3,40(sp)
    80001664:	7a02                	ld	s4,32(sp)
    80001666:	6ae2                	ld	s5,24(sp)
    80001668:	6b42                	ld	s6,16(sp)
    8000166a:	6ba2                	ld	s7,8(sp)
    8000166c:	6161                	addi	sp,sp,80
    8000166e:	8082                	ret
  return 0;
    80001670:	4501                	li	a0,0
    80001672:	b7e5                	j	8000165a <uvmcopy+0xa8>
    80001674:	4501                	li	a0,0
}
    80001676:	8082                	ret

0000000080001678 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001678:	1141                	addi	sp,sp,-16
    8000167a:	e406                	sd	ra,8(sp)
    8000167c:	e022                	sd	s0,0(sp)
    8000167e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001680:	4601                	li	a2,0
    80001682:	00000097          	auipc	ra,0x0
    80001686:	9ae080e7          	jalr	-1618(ra) # 80001030 <walk>
  if(pte == 0)
    8000168a:	c901                	beqz	a0,8000169a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000168c:	611c                	ld	a5,0(a0)
    8000168e:	9bbd                	andi	a5,a5,-17
    80001690:	e11c                	sd	a5,0(a0)
}
    80001692:	60a2                	ld	ra,8(sp)
    80001694:	6402                	ld	s0,0(sp)
    80001696:	0141                	addi	sp,sp,16
    80001698:	8082                	ret
    panic("uvmclear");
    8000169a:	00007517          	auipc	a0,0x7
    8000169e:	ade50513          	addi	a0,a0,-1314 # 80008178 <digits+0x160>
    800016a2:	fffff097          	auipc	ra,0xfffff
    800016a6:	eb6080e7          	jalr	-330(ra) # 80000558 <panic>

00000000800016aa <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016aa:	c6bd                	beqz	a3,80001718 <copyout+0x6e>
{
    800016ac:	715d                	addi	sp,sp,-80
    800016ae:	e486                	sd	ra,72(sp)
    800016b0:	e0a2                	sd	s0,64(sp)
    800016b2:	fc26                	sd	s1,56(sp)
    800016b4:	f84a                	sd	s2,48(sp)
    800016b6:	f44e                	sd	s3,40(sp)
    800016b8:	f052                	sd	s4,32(sp)
    800016ba:	ec56                	sd	s5,24(sp)
    800016bc:	e85a                	sd	s6,16(sp)
    800016be:	e45e                	sd	s7,8(sp)
    800016c0:	e062                	sd	s8,0(sp)
    800016c2:	0880                	addi	s0,sp,80
    800016c4:	8baa                	mv	s7,a0
    800016c6:	8a2e                	mv	s4,a1
    800016c8:	8ab2                	mv	s5,a2
    800016ca:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016cc:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016ce:	6b05                	lui	s6,0x1
    800016d0:	a015                	j	800016f4 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016d2:	9552                	add	a0,a0,s4
    800016d4:	0004861b          	sext.w	a2,s1
    800016d8:	85d6                	mv	a1,s5
    800016da:	41250533          	sub	a0,a0,s2
    800016de:	fffff097          	auipc	ra,0xfffff
    800016e2:	6ae080e7          	jalr	1710(ra) # 80000d8c <memmove>

    len -= n;
    800016e6:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ea:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    800016ec:	01690a33          	add	s4,s2,s6
  while(len > 0){
    800016f0:	02098263          	beqz	s3,80001714 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016f4:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    800016f8:	85ca                	mv	a1,s2
    800016fa:	855e                	mv	a0,s7
    800016fc:	00000097          	auipc	ra,0x0
    80001700:	9da080e7          	jalr	-1574(ra) # 800010d6 <walkaddr>
    if(pa0 == 0)
    80001704:	cd01                	beqz	a0,8000171c <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001706:	414904b3          	sub	s1,s2,s4
    8000170a:	94da                	add	s1,s1,s6
    if(n > len)
    8000170c:	fc99f3e3          	bleu	s1,s3,800016d2 <copyout+0x28>
    80001710:	84ce                	mv	s1,s3
    80001712:	b7c1                	j	800016d2 <copyout+0x28>
  }
  return 0;
    80001714:	4501                	li	a0,0
    80001716:	a021                	j	8000171e <copyout+0x74>
    80001718:	4501                	li	a0,0
}
    8000171a:	8082                	ret
      return -1;
    8000171c:	557d                	li	a0,-1
}
    8000171e:	60a6                	ld	ra,72(sp)
    80001720:	6406                	ld	s0,64(sp)
    80001722:	74e2                	ld	s1,56(sp)
    80001724:	7942                	ld	s2,48(sp)
    80001726:	79a2                	ld	s3,40(sp)
    80001728:	7a02                	ld	s4,32(sp)
    8000172a:	6ae2                	ld	s5,24(sp)
    8000172c:	6b42                	ld	s6,16(sp)
    8000172e:	6ba2                	ld	s7,8(sp)
    80001730:	6c02                	ld	s8,0(sp)
    80001732:	6161                	addi	sp,sp,80
    80001734:	8082                	ret

0000000080001736 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001736:	caa5                	beqz	a3,800017a6 <copyin+0x70>
{
    80001738:	715d                	addi	sp,sp,-80
    8000173a:	e486                	sd	ra,72(sp)
    8000173c:	e0a2                	sd	s0,64(sp)
    8000173e:	fc26                	sd	s1,56(sp)
    80001740:	f84a                	sd	s2,48(sp)
    80001742:	f44e                	sd	s3,40(sp)
    80001744:	f052                	sd	s4,32(sp)
    80001746:	ec56                	sd	s5,24(sp)
    80001748:	e85a                	sd	s6,16(sp)
    8000174a:	e45e                	sd	s7,8(sp)
    8000174c:	e062                	sd	s8,0(sp)
    8000174e:	0880                	addi	s0,sp,80
    80001750:	8baa                	mv	s7,a0
    80001752:	8aae                	mv	s5,a1
    80001754:	8a32                	mv	s4,a2
    80001756:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001758:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000175a:	6b05                	lui	s6,0x1
    8000175c:	a01d                	j	80001782 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000175e:	014505b3          	add	a1,a0,s4
    80001762:	0004861b          	sext.w	a2,s1
    80001766:	412585b3          	sub	a1,a1,s2
    8000176a:	8556                	mv	a0,s5
    8000176c:	fffff097          	auipc	ra,0xfffff
    80001770:	620080e7          	jalr	1568(ra) # 80000d8c <memmove>

    len -= n;
    80001774:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001778:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000177a:	01690a33          	add	s4,s2,s6
  while(len > 0){
    8000177e:	02098263          	beqz	s3,800017a2 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001782:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    80001786:	85ca                	mv	a1,s2
    80001788:	855e                	mv	a0,s7
    8000178a:	00000097          	auipc	ra,0x0
    8000178e:	94c080e7          	jalr	-1716(ra) # 800010d6 <walkaddr>
    if(pa0 == 0)
    80001792:	cd01                	beqz	a0,800017aa <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001794:	414904b3          	sub	s1,s2,s4
    80001798:	94da                	add	s1,s1,s6
    if(n > len)
    8000179a:	fc99f2e3          	bleu	s1,s3,8000175e <copyin+0x28>
    8000179e:	84ce                	mv	s1,s3
    800017a0:	bf7d                	j	8000175e <copyin+0x28>
  }
  return 0;
    800017a2:	4501                	li	a0,0
    800017a4:	a021                	j	800017ac <copyin+0x76>
    800017a6:	4501                	li	a0,0
}
    800017a8:	8082                	ret
      return -1;
    800017aa:	557d                	li	a0,-1
}
    800017ac:	60a6                	ld	ra,72(sp)
    800017ae:	6406                	ld	s0,64(sp)
    800017b0:	74e2                	ld	s1,56(sp)
    800017b2:	7942                	ld	s2,48(sp)
    800017b4:	79a2                	ld	s3,40(sp)
    800017b6:	7a02                	ld	s4,32(sp)
    800017b8:	6ae2                	ld	s5,24(sp)
    800017ba:	6b42                	ld	s6,16(sp)
    800017bc:	6ba2                	ld	s7,8(sp)
    800017be:	6c02                	ld	s8,0(sp)
    800017c0:	6161                	addi	sp,sp,80
    800017c2:	8082                	ret

00000000800017c4 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017c4:	ced5                	beqz	a3,80001880 <copyinstr+0xbc>
{
    800017c6:	715d                	addi	sp,sp,-80
    800017c8:	e486                	sd	ra,72(sp)
    800017ca:	e0a2                	sd	s0,64(sp)
    800017cc:	fc26                	sd	s1,56(sp)
    800017ce:	f84a                	sd	s2,48(sp)
    800017d0:	f44e                	sd	s3,40(sp)
    800017d2:	f052                	sd	s4,32(sp)
    800017d4:	ec56                	sd	s5,24(sp)
    800017d6:	e85a                	sd	s6,16(sp)
    800017d8:	e45e                	sd	s7,8(sp)
    800017da:	e062                	sd	s8,0(sp)
    800017dc:	0880                	addi	s0,sp,80
    800017de:	8aaa                	mv	s5,a0
    800017e0:	84ae                	mv	s1,a1
    800017e2:	8c32                	mv	s8,a2
    800017e4:	8bb6                	mv	s7,a3
    va0 = PGROUNDDOWN(srcva);
    800017e6:	7a7d                	lui	s4,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017e8:	6985                	lui	s3,0x1
    800017ea:	4b05                	li	s6,1
    800017ec:	a801                	j	800017fc <copyinstr+0x38>
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
    800017ee:	87a6                	mv	a5,s1
    800017f0:	a085                	j	80001850 <copyinstr+0x8c>
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    800017f2:	84b2                	mv	s1,a2
    }

    srcva = va0 + PGSIZE;
    800017f4:	01390c33          	add	s8,s2,s3
  while(got_null == 0 && max > 0){
    800017f8:	080b8063          	beqz	s7,80001878 <copyinstr+0xb4>
    va0 = PGROUNDDOWN(srcva);
    800017fc:	014c7933          	and	s2,s8,s4
    pa0 = walkaddr(pagetable, va0);
    80001800:	85ca                	mv	a1,s2
    80001802:	8556                	mv	a0,s5
    80001804:	00000097          	auipc	ra,0x0
    80001808:	8d2080e7          	jalr	-1838(ra) # 800010d6 <walkaddr>
    if(pa0 == 0)
    8000180c:	c925                	beqz	a0,8000187c <copyinstr+0xb8>
    n = PGSIZE - (srcva - va0);
    8000180e:	41890633          	sub	a2,s2,s8
    80001812:	964e                	add	a2,a2,s3
    if(n > max)
    80001814:	00cbf363          	bleu	a2,s7,8000181a <copyinstr+0x56>
    80001818:	865e                	mv	a2,s7
    char *p = (char *) (pa0 + (srcva - va0));
    8000181a:	9562                	add	a0,a0,s8
    8000181c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001820:	da71                	beqz	a2,800017f4 <copyinstr+0x30>
      if(*p == '\0'){
    80001822:	00054703          	lbu	a4,0(a0)
    80001826:	d761                	beqz	a4,800017ee <copyinstr+0x2a>
    80001828:	9626                	add	a2,a2,s1
    8000182a:	87a6                	mv	a5,s1
    8000182c:	1bfd                	addi	s7,s7,-1
    8000182e:	009b86b3          	add	a3,s7,s1
    80001832:	409b04b3          	sub	s1,s6,s1
    80001836:	94aa                	add	s1,s1,a0
        *dst = *p;
    80001838:	00e78023          	sb	a4,0(a5) # 1000 <_entry-0x7ffff000>
      --max;
    8000183c:	40f68bb3          	sub	s7,a3,a5
      p++;
    80001840:	00f48733          	add	a4,s1,a5
      dst++;
    80001844:	0785                	addi	a5,a5,1
    while(n > 0){
    80001846:	faf606e3          	beq	a2,a5,800017f2 <copyinstr+0x2e>
      if(*p == '\0'){
    8000184a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffcd000>
    8000184e:	f76d                	bnez	a4,80001838 <copyinstr+0x74>
        *dst = '\0';
    80001850:	00078023          	sb	zero,0(a5)
    80001854:	4785                	li	a5,1
  }
  if(got_null){
    80001856:	0017b513          	seqz	a0,a5
    8000185a:	40a0053b          	negw	a0,a0
    8000185e:	2501                	sext.w	a0,a0
    return 0;
  } else {
    return -1;
  }
}
    80001860:	60a6                	ld	ra,72(sp)
    80001862:	6406                	ld	s0,64(sp)
    80001864:	74e2                	ld	s1,56(sp)
    80001866:	7942                	ld	s2,48(sp)
    80001868:	79a2                	ld	s3,40(sp)
    8000186a:	7a02                	ld	s4,32(sp)
    8000186c:	6ae2                	ld	s5,24(sp)
    8000186e:	6b42                	ld	s6,16(sp)
    80001870:	6ba2                	ld	s7,8(sp)
    80001872:	6c02                	ld	s8,0(sp)
    80001874:	6161                	addi	sp,sp,80
    80001876:	8082                	ret
    80001878:	4781                	li	a5,0
    8000187a:	bff1                	j	80001856 <copyinstr+0x92>
      return -1;
    8000187c:	557d                	li	a0,-1
    8000187e:	b7cd                	j	80001860 <copyinstr+0x9c>
  int got_null = 0;
    80001880:	4781                	li	a5,0
  if(got_null){
    80001882:	0017b513          	seqz	a0,a5
    80001886:	40a0053b          	negw	a0,a0
    8000188a:	2501                	sext.w	a0,a0
}
    8000188c:	8082                	ret

000000008000188e <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    8000188e:	1101                	addi	sp,sp,-32
    80001890:	ec06                	sd	ra,24(sp)
    80001892:	e822                	sd	s0,16(sp)
    80001894:	e426                	sd	s1,8(sp)
    80001896:	1000                	addi	s0,sp,32
    80001898:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000189a:	fffff097          	auipc	ra,0xfffff
    8000189e:	310080e7          	jalr	784(ra) # 80000baa <holding>
    800018a2:	c909                	beqz	a0,800018b4 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800018a4:	749c                	ld	a5,40(s1)
    800018a6:	00978f63          	beq	a5,s1,800018c4 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    800018aa:	60e2                	ld	ra,24(sp)
    800018ac:	6442                	ld	s0,16(sp)
    800018ae:	64a2                	ld	s1,8(sp)
    800018b0:	6105                	addi	sp,sp,32
    800018b2:	8082                	ret
    panic("wakeup1");
    800018b4:	00007517          	auipc	a0,0x7
    800018b8:	8fc50513          	addi	a0,a0,-1796 # 800081b0 <states.1759+0x28>
    800018bc:	fffff097          	auipc	ra,0xfffff
    800018c0:	c9c080e7          	jalr	-868(ra) # 80000558 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    800018c4:	4c98                	lw	a4,24(s1)
    800018c6:	4785                	li	a5,1
    800018c8:	fef711e3          	bne	a4,a5,800018aa <wakeup1+0x1c>
    p->state = RUNNABLE;
    800018cc:	4789                	li	a5,2
    800018ce:	cc9c                	sw	a5,24(s1)
}
    800018d0:	bfe9                	j	800018aa <wakeup1+0x1c>

00000000800018d2 <proc_mapstacks>:
proc_mapstacks(pagetable_t kpgtbl) {
    800018d2:	7139                	addi	sp,sp,-64
    800018d4:	fc06                	sd	ra,56(sp)
    800018d6:	f822                	sd	s0,48(sp)
    800018d8:	f426                	sd	s1,40(sp)
    800018da:	f04a                	sd	s2,32(sp)
    800018dc:	ec4e                	sd	s3,24(sp)
    800018de:	e852                	sd	s4,16(sp)
    800018e0:	e456                	sd	s5,8(sp)
    800018e2:	e05a                	sd	s6,0(sp)
    800018e4:	0080                	addi	s0,sp,64
    800018e6:	8b2a                	mv	s6,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e8:	00010497          	auipc	s1,0x10
    800018ec:	dd048493          	addi	s1,s1,-560 # 800116b8 <proc>
    uint64 va = KSTACK((int) (p - proc));
    800018f0:	8aa6                	mv	s5,s1
    800018f2:	00006a17          	auipc	s4,0x6
    800018f6:	70ea0a13          	addi	s4,s4,1806 # 80008000 <etext>
    800018fa:	04000937          	lui	s2,0x4000
    800018fe:	197d                	addi	s2,s2,-1
    80001900:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001902:	00021997          	auipc	s3,0x21
    80001906:	7b698993          	addi	s3,s3,1974 # 800230b8 <tickslock>
    char *pa = kalloc();
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	22a080e7          	jalr	554(ra) # 80000b34 <kalloc>
    80001912:	862a                	mv	a2,a0
    if(pa == 0)
    80001914:	c131                	beqz	a0,80001958 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001916:	415485b3          	sub	a1,s1,s5
    8000191a:	858d                	srai	a1,a1,0x3
    8000191c:	000a3783          	ld	a5,0(s4)
    80001920:	02f585b3          	mul	a1,a1,a5
    80001924:	2585                	addiw	a1,a1,1
    80001926:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000192a:	4719                	li	a4,6
    8000192c:	6685                	lui	a3,0x1
    8000192e:	40b905b3          	sub	a1,s2,a1
    80001932:	855a                	mv	a0,s6
    80001934:	00000097          	auipc	ra,0x0
    80001938:	870080e7          	jalr	-1936(ra) # 800011a4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000193c:	46848493          	addi	s1,s1,1128
    80001940:	fd3495e3          	bne	s1,s3,8000190a <proc_mapstacks+0x38>
}
    80001944:	70e2                	ld	ra,56(sp)
    80001946:	7442                	ld	s0,48(sp)
    80001948:	74a2                	ld	s1,40(sp)
    8000194a:	7902                	ld	s2,32(sp)
    8000194c:	69e2                	ld	s3,24(sp)
    8000194e:	6a42                	ld	s4,16(sp)
    80001950:	6aa2                	ld	s5,8(sp)
    80001952:	6b02                	ld	s6,0(sp)
    80001954:	6121                	addi	sp,sp,64
    80001956:	8082                	ret
      panic("kalloc");
    80001958:	00007517          	auipc	a0,0x7
    8000195c:	86050513          	addi	a0,a0,-1952 # 800081b8 <states.1759+0x30>
    80001960:	fffff097          	auipc	ra,0xfffff
    80001964:	bf8080e7          	jalr	-1032(ra) # 80000558 <panic>

0000000080001968 <procinit>:
{
    80001968:	7139                	addi	sp,sp,-64
    8000196a:	fc06                	sd	ra,56(sp)
    8000196c:	f822                	sd	s0,48(sp)
    8000196e:	f426                	sd	s1,40(sp)
    80001970:	f04a                	sd	s2,32(sp)
    80001972:	ec4e                	sd	s3,24(sp)
    80001974:	e852                	sd	s4,16(sp)
    80001976:	e456                	sd	s5,8(sp)
    80001978:	e05a                	sd	s6,0(sp)
    8000197a:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    8000197c:	00007597          	auipc	a1,0x7
    80001980:	84458593          	addi	a1,a1,-1980 # 800081c0 <states.1759+0x38>
    80001984:	00010517          	auipc	a0,0x10
    80001988:	91c50513          	addi	a0,a0,-1764 # 800112a0 <pid_lock>
    8000198c:	fffff097          	auipc	ra,0xfffff
    80001990:	208080e7          	jalr	520(ra) # 80000b94 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001994:	00010497          	auipc	s1,0x10
    80001998:	d2448493          	addi	s1,s1,-732 # 800116b8 <proc>
      initlock(&p->lock, "proc");
    8000199c:	00007b17          	auipc	s6,0x7
    800019a0:	82cb0b13          	addi	s6,s6,-2004 # 800081c8 <states.1759+0x40>
      p->kstack = KSTACK((int) (p - proc));
    800019a4:	8aa6                	mv	s5,s1
    800019a6:	00006a17          	auipc	s4,0x6
    800019aa:	65aa0a13          	addi	s4,s4,1626 # 80008000 <etext>
    800019ae:	04000937          	lui	s2,0x4000
    800019b2:	197d                	addi	s2,s2,-1
    800019b4:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b6:	00021997          	auipc	s3,0x21
    800019ba:	70298993          	addi	s3,s3,1794 # 800230b8 <tickslock>
      initlock(&p->lock, "proc");
    800019be:	85da                	mv	a1,s6
    800019c0:	8526                	mv	a0,s1
    800019c2:	fffff097          	auipc	ra,0xfffff
    800019c6:	1d2080e7          	jalr	466(ra) # 80000b94 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    800019ca:	415487b3          	sub	a5,s1,s5
    800019ce:	878d                	srai	a5,a5,0x3
    800019d0:	000a3703          	ld	a4,0(s4)
    800019d4:	02e787b3          	mul	a5,a5,a4
    800019d8:	2785                	addiw	a5,a5,1
    800019da:	00d7979b          	slliw	a5,a5,0xd
    800019de:	40f907b3          	sub	a5,s2,a5
    800019e2:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019e4:	46848493          	addi	s1,s1,1128
    800019e8:	fd349be3          	bne	s1,s3,800019be <procinit+0x56>
}
    800019ec:	70e2                	ld	ra,56(sp)
    800019ee:	7442                	ld	s0,48(sp)
    800019f0:	74a2                	ld	s1,40(sp)
    800019f2:	7902                	ld	s2,32(sp)
    800019f4:	69e2                	ld	s3,24(sp)
    800019f6:	6a42                	ld	s4,16(sp)
    800019f8:	6aa2                	ld	s5,8(sp)
    800019fa:	6b02                	ld	s6,0(sp)
    800019fc:	6121                	addi	sp,sp,64
    800019fe:	8082                	ret

0000000080001a00 <cpuid>:
{
    80001a00:	1141                	addi	sp,sp,-16
    80001a02:	e422                	sd	s0,8(sp)
    80001a04:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a06:	8512                	mv	a0,tp
}
    80001a08:	2501                	sext.w	a0,a0
    80001a0a:	6422                	ld	s0,8(sp)
    80001a0c:	0141                	addi	sp,sp,16
    80001a0e:	8082                	ret

0000000080001a10 <mycpu>:
mycpu(void) {
    80001a10:	1141                	addi	sp,sp,-16
    80001a12:	e422                	sd	s0,8(sp)
    80001a14:	0800                	addi	s0,sp,16
    80001a16:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a18:	2781                	sext.w	a5,a5
    80001a1a:	079e                	slli	a5,a5,0x7
}
    80001a1c:	00010517          	auipc	a0,0x10
    80001a20:	89c50513          	addi	a0,a0,-1892 # 800112b8 <cpus>
    80001a24:	953e                	add	a0,a0,a5
    80001a26:	6422                	ld	s0,8(sp)
    80001a28:	0141                	addi	sp,sp,16
    80001a2a:	8082                	ret

0000000080001a2c <myproc>:
myproc(void) {
    80001a2c:	1101                	addi	sp,sp,-32
    80001a2e:	ec06                	sd	ra,24(sp)
    80001a30:	e822                	sd	s0,16(sp)
    80001a32:	e426                	sd	s1,8(sp)
    80001a34:	1000                	addi	s0,sp,32
  push_off();
    80001a36:	fffff097          	auipc	ra,0xfffff
    80001a3a:	1a2080e7          	jalr	418(ra) # 80000bd8 <push_off>
    80001a3e:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a40:	2781                	sext.w	a5,a5
    80001a42:	079e                	slli	a5,a5,0x7
    80001a44:	00010717          	auipc	a4,0x10
    80001a48:	85c70713          	addi	a4,a4,-1956 # 800112a0 <pid_lock>
    80001a4c:	97ba                	add	a5,a5,a4
    80001a4e:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a50:	fffff097          	auipc	ra,0xfffff
    80001a54:	228080e7          	jalr	552(ra) # 80000c78 <pop_off>
}
    80001a58:	8526                	mv	a0,s1
    80001a5a:	60e2                	ld	ra,24(sp)
    80001a5c:	6442                	ld	s0,16(sp)
    80001a5e:	64a2                	ld	s1,8(sp)
    80001a60:	6105                	addi	sp,sp,32
    80001a62:	8082                	ret

0000000080001a64 <forkret>:
{
    80001a64:	1141                	addi	sp,sp,-16
    80001a66:	e406                	sd	ra,8(sp)
    80001a68:	e022                	sd	s0,0(sp)
    80001a6a:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a6c:	00000097          	auipc	ra,0x0
    80001a70:	fc0080e7          	jalr	-64(ra) # 80001a2c <myproc>
    80001a74:	fffff097          	auipc	ra,0xfffff
    80001a78:	264080e7          	jalr	612(ra) # 80000cd8 <release>
  if (first) {
    80001a7c:	00007797          	auipc	a5,0x7
    80001a80:	d9478793          	addi	a5,a5,-620 # 80008810 <first.1719>
    80001a84:	439c                	lw	a5,0(a5)
    80001a86:	eb89                	bnez	a5,80001a98 <forkret+0x34>
  usertrapret();
    80001a88:	00001097          	auipc	ra,0x1
    80001a8c:	d02080e7          	jalr	-766(ra) # 8000278a <usertrapret>
}
    80001a90:	60a2                	ld	ra,8(sp)
    80001a92:	6402                	ld	s0,0(sp)
    80001a94:	0141                	addi	sp,sp,16
    80001a96:	8082                	ret
    first = 0;
    80001a98:	00007797          	auipc	a5,0x7
    80001a9c:	d607ac23          	sw	zero,-648(a5) # 80008810 <first.1719>
    fsinit(ROOTDEV);
    80001aa0:	4505                	li	a0,1
    80001aa2:	00002097          	auipc	ra,0x2
    80001aa6:	bce080e7          	jalr	-1074(ra) # 80003670 <fsinit>
    80001aaa:	bff9                	j	80001a88 <forkret+0x24>

0000000080001aac <allocpid>:
allocpid() {
    80001aac:	1101                	addi	sp,sp,-32
    80001aae:	ec06                	sd	ra,24(sp)
    80001ab0:	e822                	sd	s0,16(sp)
    80001ab2:	e426                	sd	s1,8(sp)
    80001ab4:	e04a                	sd	s2,0(sp)
    80001ab6:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ab8:	0000f917          	auipc	s2,0xf
    80001abc:	7e890913          	addi	s2,s2,2024 # 800112a0 <pid_lock>
    80001ac0:	854a                	mv	a0,s2
    80001ac2:	fffff097          	auipc	ra,0xfffff
    80001ac6:	162080e7          	jalr	354(ra) # 80000c24 <acquire>
  pid = nextpid;
    80001aca:	00007797          	auipc	a5,0x7
    80001ace:	d4a78793          	addi	a5,a5,-694 # 80008814 <nextpid>
    80001ad2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ad4:	0014871b          	addiw	a4,s1,1
    80001ad8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ada:	854a                	mv	a0,s2
    80001adc:	fffff097          	auipc	ra,0xfffff
    80001ae0:	1fc080e7          	jalr	508(ra) # 80000cd8 <release>
}
    80001ae4:	8526                	mv	a0,s1
    80001ae6:	60e2                	ld	ra,24(sp)
    80001ae8:	6442                	ld	s0,16(sp)
    80001aea:	64a2                	ld	s1,8(sp)
    80001aec:	6902                	ld	s2,0(sp)
    80001aee:	6105                	addi	sp,sp,32
    80001af0:	8082                	ret

0000000080001af2 <proc_pagetable>:
{
    80001af2:	1101                	addi	sp,sp,-32
    80001af4:	ec06                	sd	ra,24(sp)
    80001af6:	e822                	sd	s0,16(sp)
    80001af8:	e426                	sd	s1,8(sp)
    80001afa:	e04a                	sd	s2,0(sp)
    80001afc:	1000                	addi	s0,sp,32
    80001afe:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b00:	00000097          	auipc	ra,0x0
    80001b04:	880080e7          	jalr	-1920(ra) # 80001380 <uvmcreate>
    80001b08:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b0a:	c121                	beqz	a0,80001b4a <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b0c:	4729                	li	a4,10
    80001b0e:	00005697          	auipc	a3,0x5
    80001b12:	4f268693          	addi	a3,a3,1266 # 80007000 <_trampoline>
    80001b16:	6605                	lui	a2,0x1
    80001b18:	040005b7          	lui	a1,0x4000
    80001b1c:	15fd                	addi	a1,a1,-1
    80001b1e:	05b2                	slli	a1,a1,0xc
    80001b20:	fffff097          	auipc	ra,0xfffff
    80001b24:	5f8080e7          	jalr	1528(ra) # 80001118 <mappages>
    80001b28:	02054863          	bltz	a0,80001b58 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b2c:	4719                	li	a4,6
    80001b2e:	05893683          	ld	a3,88(s2)
    80001b32:	6605                	lui	a2,0x1
    80001b34:	020005b7          	lui	a1,0x2000
    80001b38:	15fd                	addi	a1,a1,-1
    80001b3a:	05b6                	slli	a1,a1,0xd
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	fffff097          	auipc	ra,0xfffff
    80001b42:	5da080e7          	jalr	1498(ra) # 80001118 <mappages>
    80001b46:	02054163          	bltz	a0,80001b68 <proc_pagetable+0x76>
}
    80001b4a:	8526                	mv	a0,s1
    80001b4c:	60e2                	ld	ra,24(sp)
    80001b4e:	6442                	ld	s0,16(sp)
    80001b50:	64a2                	ld	s1,8(sp)
    80001b52:	6902                	ld	s2,0(sp)
    80001b54:	6105                	addi	sp,sp,32
    80001b56:	8082                	ret
    uvmfree(pagetable, 0);
    80001b58:	4581                	li	a1,0
    80001b5a:	8526                	mv	a0,s1
    80001b5c:	00000097          	auipc	ra,0x0
    80001b60:	a1e080e7          	jalr	-1506(ra) # 8000157a <uvmfree>
    return 0;
    80001b64:	4481                	li	s1,0
    80001b66:	b7d5                	j	80001b4a <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b68:	4681                	li	a3,0
    80001b6a:	4605                	li	a2,1
    80001b6c:	040005b7          	lui	a1,0x4000
    80001b70:	15fd                	addi	a1,a1,-1
    80001b72:	05b2                	slli	a1,a1,0xc
    80001b74:	8526                	mv	a0,s1
    80001b76:	fffff097          	auipc	ra,0xfffff
    80001b7a:	754080e7          	jalr	1876(ra) # 800012ca <uvmunmap>
    uvmfree(pagetable, 0);
    80001b7e:	4581                	li	a1,0
    80001b80:	8526                	mv	a0,s1
    80001b82:	00000097          	auipc	ra,0x0
    80001b86:	9f8080e7          	jalr	-1544(ra) # 8000157a <uvmfree>
    return 0;
    80001b8a:	4481                	li	s1,0
    80001b8c:	bf7d                	j	80001b4a <proc_pagetable+0x58>

0000000080001b8e <proc_freepagetable>:
{
    80001b8e:	1101                	addi	sp,sp,-32
    80001b90:	ec06                	sd	ra,24(sp)
    80001b92:	e822                	sd	s0,16(sp)
    80001b94:	e426                	sd	s1,8(sp)
    80001b96:	e04a                	sd	s2,0(sp)
    80001b98:	1000                	addi	s0,sp,32
    80001b9a:	84aa                	mv	s1,a0
    80001b9c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b9e:	4681                	li	a3,0
    80001ba0:	4605                	li	a2,1
    80001ba2:	040005b7          	lui	a1,0x4000
    80001ba6:	15fd                	addi	a1,a1,-1
    80001ba8:	05b2                	slli	a1,a1,0xc
    80001baa:	fffff097          	auipc	ra,0xfffff
    80001bae:	720080e7          	jalr	1824(ra) # 800012ca <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bb2:	4681                	li	a3,0
    80001bb4:	4605                	li	a2,1
    80001bb6:	020005b7          	lui	a1,0x2000
    80001bba:	15fd                	addi	a1,a1,-1
    80001bbc:	05b6                	slli	a1,a1,0xd
    80001bbe:	8526                	mv	a0,s1
    80001bc0:	fffff097          	auipc	ra,0xfffff
    80001bc4:	70a080e7          	jalr	1802(ra) # 800012ca <uvmunmap>
  uvmfree(pagetable, sz);
    80001bc8:	85ca                	mv	a1,s2
    80001bca:	8526                	mv	a0,s1
    80001bcc:	00000097          	auipc	ra,0x0
    80001bd0:	9ae080e7          	jalr	-1618(ra) # 8000157a <uvmfree>
}
    80001bd4:	60e2                	ld	ra,24(sp)
    80001bd6:	6442                	ld	s0,16(sp)
    80001bd8:	64a2                	ld	s1,8(sp)
    80001bda:	6902                	ld	s2,0(sp)
    80001bdc:	6105                	addi	sp,sp,32
    80001bde:	8082                	ret

0000000080001be0 <freeproc>:
{
    80001be0:	1101                	addi	sp,sp,-32
    80001be2:	ec06                	sd	ra,24(sp)
    80001be4:	e822                	sd	s0,16(sp)
    80001be6:	e426                	sd	s1,8(sp)
    80001be8:	1000                	addi	s0,sp,32
    80001bea:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bec:	6d28                	ld	a0,88(a0)
    80001bee:	c509                	beqz	a0,80001bf8 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bf0:	fffff097          	auipc	ra,0xfffff
    80001bf4:	e44080e7          	jalr	-444(ra) # 80000a34 <kfree>
  p->trapframe = 0;
    80001bf8:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bfc:	68a8                	ld	a0,80(s1)
    80001bfe:	c511                	beqz	a0,80001c0a <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c00:	64ac                	ld	a1,72(s1)
    80001c02:	00000097          	auipc	ra,0x0
    80001c06:	f8c080e7          	jalr	-116(ra) # 80001b8e <proc_freepagetable>
  p->pagetable = 0;
    80001c0a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c0e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c12:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001c16:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c1a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c1e:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c22:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c26:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c2a:	0004ac23          	sw	zero,24(s1)
}
    80001c2e:	60e2                	ld	ra,24(sp)
    80001c30:	6442                	ld	s0,16(sp)
    80001c32:	64a2                	ld	s1,8(sp)
    80001c34:	6105                	addi	sp,sp,32
    80001c36:	8082                	ret

0000000080001c38 <allocproc>:
{
    80001c38:	7179                	addi	sp,sp,-48
    80001c3a:	f406                	sd	ra,40(sp)
    80001c3c:	f022                	sd	s0,32(sp)
    80001c3e:	ec26                	sd	s1,24(sp)
    80001c40:	e84a                	sd	s2,16(sp)
    80001c42:	e44e                	sd	s3,8(sp)
    80001c44:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c46:	00010497          	auipc	s1,0x10
    80001c4a:	a7248493          	addi	s1,s1,-1422 # 800116b8 <proc>
    80001c4e:	00021997          	auipc	s3,0x21
    80001c52:	46a98993          	addi	s3,s3,1130 # 800230b8 <tickslock>
    acquire(&p->lock);
    80001c56:	8526                	mv	a0,s1
    80001c58:	fffff097          	auipc	ra,0xfffff
    80001c5c:	fcc080e7          	jalr	-52(ra) # 80000c24 <acquire>
    if(p->state == UNUSED) {
    80001c60:	4c9c                	lw	a5,24(s1)
    80001c62:	cf81                	beqz	a5,80001c7a <allocproc+0x42>
      release(&p->lock);
    80001c64:	8526                	mv	a0,s1
    80001c66:	fffff097          	auipc	ra,0xfffff
    80001c6a:	072080e7          	jalr	114(ra) # 80000cd8 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c6e:	46848493          	addi	s1,s1,1128
    80001c72:	ff3492e3          	bne	s1,s3,80001c56 <allocproc+0x1e>
  return 0;
    80001c76:	4481                	li	s1,0
    80001c78:	a8bd                	j	80001cf6 <allocproc+0xbe>
  p->pid = allocpid();
    80001c7a:	00000097          	auipc	ra,0x0
    80001c7e:	e32080e7          	jalr	-462(ra) # 80001aac <allocpid>
    80001c82:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c84:	fffff097          	auipc	ra,0xfffff
    80001c88:	eb0080e7          	jalr	-336(ra) # 80000b34 <kalloc>
    80001c8c:	89aa                	mv	s3,a0
    80001c8e:	eca8                	sd	a0,88(s1)
    80001c90:	c93d                	beqz	a0,80001d06 <allocproc+0xce>
  p->pagetable = proc_pagetable(p);
    80001c92:	8526                	mv	a0,s1
    80001c94:	00000097          	auipc	ra,0x0
    80001c98:	e5e080e7          	jalr	-418(ra) # 80001af2 <proc_pagetable>
    80001c9c:	89aa                	mv	s3,a0
    80001c9e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001ca0:	c935                	beqz	a0,80001d14 <allocproc+0xdc>
  memset(&p->context, 0, sizeof(p->context));
    80001ca2:	07000613          	li	a2,112
    80001ca6:	4581                	li	a1,0
    80001ca8:	06048513          	addi	a0,s1,96
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	074080e7          	jalr	116(ra) # 80000d20 <memset>
  p->context.ra = (uint64)forkret;
    80001cb4:	00000797          	auipc	a5,0x0
    80001cb8:	db078793          	addi	a5,a5,-592 # 80001a64 <forkret>
    80001cbc:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cbe:	60bc                	ld	a5,64(s1)
    80001cc0:	6705                	lui	a4,0x1
    80001cc2:	97ba                	add	a5,a5,a4
    80001cc4:	f4bc                	sd	a5,104(s1)
  for (int i = 0; i < NVMA; i++) {
    80001cc6:	16848793          	addi	a5,s1,360
    80001cca:	46848913          	addi	s2,s1,1128
    p->vmas[i].valid  = 0;
    80001cce:	0007a023          	sw	zero,0(a5)
    p->vmas[i].addr   = 0;
    80001cd2:	0007b423          	sd	zero,8(a5)
    p->vmas[i].length = 0;
    80001cd6:	0007a823          	sw	zero,16(a5)
    p->vmas[i].prot   = 0;
    80001cda:	0007aa23          	sw	zero,20(a5)
    p->vmas[i].flags  = 0;
    80001cde:	0007ac23          	sw	zero,24(a5)
    p->vmas[i].fd     = 0;
    80001ce2:	0007ae23          	sw	zero,28(a5)
    p->vmas[i].offset = 0;
    80001ce6:	0207a023          	sw	zero,32(a5)
    p->vmas[i].f      = 0;
    80001cea:	0207b423          	sd	zero,40(a5)
  for (int i = 0; i < NVMA; i++) {
    80001cee:	03078793          	addi	a5,a5,48
    80001cf2:	fd279ee3          	bne	a5,s2,80001cce <allocproc+0x96>
}
    80001cf6:	8526                	mv	a0,s1
    80001cf8:	70a2                	ld	ra,40(sp)
    80001cfa:	7402                	ld	s0,32(sp)
    80001cfc:	64e2                	ld	s1,24(sp)
    80001cfe:	6942                	ld	s2,16(sp)
    80001d00:	69a2                	ld	s3,8(sp)
    80001d02:	6145                	addi	sp,sp,48
    80001d04:	8082                	ret
    release(&p->lock);
    80001d06:	8526                	mv	a0,s1
    80001d08:	fffff097          	auipc	ra,0xfffff
    80001d0c:	fd0080e7          	jalr	-48(ra) # 80000cd8 <release>
    return 0;
    80001d10:	84ce                	mv	s1,s3
    80001d12:	b7d5                	j	80001cf6 <allocproc+0xbe>
    freeproc(p);
    80001d14:	8526                	mv	a0,s1
    80001d16:	00000097          	auipc	ra,0x0
    80001d1a:	eca080e7          	jalr	-310(ra) # 80001be0 <freeproc>
    release(&p->lock);
    80001d1e:	8526                	mv	a0,s1
    80001d20:	fffff097          	auipc	ra,0xfffff
    80001d24:	fb8080e7          	jalr	-72(ra) # 80000cd8 <release>
    return 0;
    80001d28:	84ce                	mv	s1,s3
    80001d2a:	b7f1                	j	80001cf6 <allocproc+0xbe>

0000000080001d2c <userinit>:
{
    80001d2c:	1101                	addi	sp,sp,-32
    80001d2e:	ec06                	sd	ra,24(sp)
    80001d30:	e822                	sd	s0,16(sp)
    80001d32:	e426                	sd	s1,8(sp)
    80001d34:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d36:	00000097          	auipc	ra,0x0
    80001d3a:	f02080e7          	jalr	-254(ra) # 80001c38 <allocproc>
    80001d3e:	84aa                	mv	s1,a0
  initproc = p;
    80001d40:	00007797          	auipc	a5,0x7
    80001d44:	2ea7b423          	sd	a0,744(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d48:	03400613          	li	a2,52
    80001d4c:	00007597          	auipc	a1,0x7
    80001d50:	ad458593          	addi	a1,a1,-1324 # 80008820 <initcode>
    80001d54:	6928                	ld	a0,80(a0)
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	658080e7          	jalr	1624(ra) # 800013ae <uvminit>
  p->sz = PGSIZE;
    80001d5e:	6785                	lui	a5,0x1
    80001d60:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d62:	6cb8                	ld	a4,88(s1)
    80001d64:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d68:	6cb8                	ld	a4,88(s1)
    80001d6a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d6c:	4641                	li	a2,16
    80001d6e:	00006597          	auipc	a1,0x6
    80001d72:	46258593          	addi	a1,a1,1122 # 800081d0 <states.1759+0x48>
    80001d76:	15848513          	addi	a0,s1,344
    80001d7a:	fffff097          	auipc	ra,0xfffff
    80001d7e:	11e080e7          	jalr	286(ra) # 80000e98 <safestrcpy>
  p->cwd = namei("/");
    80001d82:	00006517          	auipc	a0,0x6
    80001d86:	45e50513          	addi	a0,a0,1118 # 800081e0 <states.1759+0x58>
    80001d8a:	00002097          	auipc	ra,0x2
    80001d8e:	320080e7          	jalr	800(ra) # 800040aa <namei>
    80001d92:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d96:	4789                	li	a5,2
    80001d98:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d9a:	8526                	mv	a0,s1
    80001d9c:	fffff097          	auipc	ra,0xfffff
    80001da0:	f3c080e7          	jalr	-196(ra) # 80000cd8 <release>
}
    80001da4:	60e2                	ld	ra,24(sp)
    80001da6:	6442                	ld	s0,16(sp)
    80001da8:	64a2                	ld	s1,8(sp)
    80001daa:	6105                	addi	sp,sp,32
    80001dac:	8082                	ret

0000000080001dae <growproc>:
{
    80001dae:	1101                	addi	sp,sp,-32
    80001db0:	ec06                	sd	ra,24(sp)
    80001db2:	e822                	sd	s0,16(sp)
    80001db4:	e426                	sd	s1,8(sp)
    80001db6:	e04a                	sd	s2,0(sp)
    80001db8:	1000                	addi	s0,sp,32
    80001dba:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dbc:	00000097          	auipc	ra,0x0
    80001dc0:	c70080e7          	jalr	-912(ra) # 80001a2c <myproc>
    80001dc4:	892a                	mv	s2,a0
  sz = p->sz;
    80001dc6:	652c                	ld	a1,72(a0)
    80001dc8:	0005851b          	sext.w	a0,a1
  if(n > 0){
    80001dcc:	00904f63          	bgtz	s1,80001dea <growproc+0x3c>
  } else if(n < 0){
    80001dd0:	0204cd63          	bltz	s1,80001e0a <growproc+0x5c>
  p->sz = sz;
    80001dd4:	1502                	slli	a0,a0,0x20
    80001dd6:	9101                	srli	a0,a0,0x20
    80001dd8:	04a93423          	sd	a0,72(s2)
  return 0;
    80001ddc:	4501                	li	a0,0
}
    80001dde:	60e2                	ld	ra,24(sp)
    80001de0:	6442                	ld	s0,16(sp)
    80001de2:	64a2                	ld	s1,8(sp)
    80001de4:	6902                	ld	s2,0(sp)
    80001de6:	6105                	addi	sp,sp,32
    80001de8:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dea:	00a4863b          	addw	a2,s1,a0
    80001dee:	1602                	slli	a2,a2,0x20
    80001df0:	9201                	srli	a2,a2,0x20
    80001df2:	1582                	slli	a1,a1,0x20
    80001df4:	9181                	srli	a1,a1,0x20
    80001df6:	05093503          	ld	a0,80(s2)
    80001dfa:	fffff097          	auipc	ra,0xfffff
    80001dfe:	66c080e7          	jalr	1644(ra) # 80001466 <uvmalloc>
    80001e02:	2501                	sext.w	a0,a0
    80001e04:	f961                	bnez	a0,80001dd4 <growproc+0x26>
      return -1;
    80001e06:	557d                	li	a0,-1
    80001e08:	bfd9                	j	80001dde <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e0a:	00a4863b          	addw	a2,s1,a0
    80001e0e:	1602                	slli	a2,a2,0x20
    80001e10:	9201                	srli	a2,a2,0x20
    80001e12:	1582                	slli	a1,a1,0x20
    80001e14:	9181                	srli	a1,a1,0x20
    80001e16:	05093503          	ld	a0,80(s2)
    80001e1a:	fffff097          	auipc	ra,0xfffff
    80001e1e:	606080e7          	jalr	1542(ra) # 80001420 <uvmdealloc>
    80001e22:	2501                	sext.w	a0,a0
    80001e24:	bf45                	j	80001dd4 <growproc+0x26>

0000000080001e26 <fork>:
{
    80001e26:	7139                	addi	sp,sp,-64
    80001e28:	fc06                	sd	ra,56(sp)
    80001e2a:	f822                	sd	s0,48(sp)
    80001e2c:	f426                	sd	s1,40(sp)
    80001e2e:	f04a                	sd	s2,32(sp)
    80001e30:	ec4e                	sd	s3,24(sp)
    80001e32:	e852                	sd	s4,16(sp)
    80001e34:	e456                	sd	s5,8(sp)
    80001e36:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e38:	00000097          	auipc	ra,0x0
    80001e3c:	bf4080e7          	jalr	-1036(ra) # 80001a2c <myproc>
    80001e40:	89aa                	mv	s3,a0
  if((np = allocproc()) == 0){
    80001e42:	00000097          	auipc	ra,0x0
    80001e46:	df6080e7          	jalr	-522(ra) # 80001c38 <allocproc>
    80001e4a:	12050363          	beqz	a0,80001f70 <fork+0x14a>
    80001e4e:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e50:	0489b603          	ld	a2,72(s3)
    80001e54:	692c                	ld	a1,80(a0)
    80001e56:	0509b503          	ld	a0,80(s3)
    80001e5a:	fffff097          	auipc	ra,0xfffff
    80001e5e:	758080e7          	jalr	1880(ra) # 800015b2 <uvmcopy>
    80001e62:	04054863          	bltz	a0,80001eb2 <fork+0x8c>
  np->sz = p->sz;
    80001e66:	0489b783          	ld	a5,72(s3)
    80001e6a:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    80001e6e:	033a3023          	sd	s3,32(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e72:	0589b683          	ld	a3,88(s3)
    80001e76:	87b6                	mv	a5,a3
    80001e78:	058a3703          	ld	a4,88(s4)
    80001e7c:	12068693          	addi	a3,a3,288
    80001e80:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e84:	6788                	ld	a0,8(a5)
    80001e86:	6b8c                	ld	a1,16(a5)
    80001e88:	6f90                	ld	a2,24(a5)
    80001e8a:	01073023          	sd	a6,0(a4)
    80001e8e:	e708                	sd	a0,8(a4)
    80001e90:	eb0c                	sd	a1,16(a4)
    80001e92:	ef10                	sd	a2,24(a4)
    80001e94:	02078793          	addi	a5,a5,32
    80001e98:	02070713          	addi	a4,a4,32
    80001e9c:	fed792e3          	bne	a5,a3,80001e80 <fork+0x5a>
  np->trapframe->a0 = 0;
    80001ea0:	058a3783          	ld	a5,88(s4)
    80001ea4:	0607b823          	sd	zero,112(a5)
    80001ea8:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001eac:	15000913          	li	s2,336
    80001eb0:	a03d                	j	80001ede <fork+0xb8>
    freeproc(np);
    80001eb2:	8552                	mv	a0,s4
    80001eb4:	00000097          	auipc	ra,0x0
    80001eb8:	d2c080e7          	jalr	-724(ra) # 80001be0 <freeproc>
    release(&np->lock);
    80001ebc:	8552                	mv	a0,s4
    80001ebe:	fffff097          	auipc	ra,0xfffff
    80001ec2:	e1a080e7          	jalr	-486(ra) # 80000cd8 <release>
    return -1;
    80001ec6:	5afd                	li	s5,-1
    80001ec8:	a851                	j	80001f5c <fork+0x136>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eca:	00003097          	auipc	ra,0x3
    80001ece:	8b0080e7          	jalr	-1872(ra) # 8000477a <filedup>
    80001ed2:	009a07b3          	add	a5,s4,s1
    80001ed6:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001ed8:	04a1                	addi	s1,s1,8
    80001eda:	01248763          	beq	s1,s2,80001ee8 <fork+0xc2>
    if(p->ofile[i])
    80001ede:	009987b3          	add	a5,s3,s1
    80001ee2:	6388                	ld	a0,0(a5)
    80001ee4:	f17d                	bnez	a0,80001eca <fork+0xa4>
    80001ee6:	bfcd                	j	80001ed8 <fork+0xb2>
  np->cwd = idup(p->cwd);
    80001ee8:	1509b503          	ld	a0,336(s3)
    80001eec:	00002097          	auipc	ra,0x2
    80001ef0:	9c0080e7          	jalr	-1600(ra) # 800038ac <idup>
    80001ef4:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ef8:	4641                	li	a2,16
    80001efa:	15898593          	addi	a1,s3,344
    80001efe:	158a0513          	addi	a0,s4,344
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	f96080e7          	jalr	-106(ra) # 80000e98 <safestrcpy>
  pid = np->pid;
    80001f0a:	038a2a83          	lw	s5,56(s4)
  for (int i = 0; i < NVMA; i++) {
    80001f0e:	168a0913          	addi	s2,s4,360
    80001f12:	16898493          	addi	s1,s3,360
    80001f16:	46898993          	addi	s3,s3,1128
    80001f1a:	a025                	j	80001f42 <fork+0x11c>
      memmove(&np->vmas[i], &p->vmas[i], sizeof(struct vma));
    80001f1c:	03000613          	li	a2,48
    80001f20:	85a6                	mv	a1,s1
    80001f22:	854a                	mv	a0,s2
    80001f24:	fffff097          	auipc	ra,0xfffff
    80001f28:	e68080e7          	jalr	-408(ra) # 80000d8c <memmove>
      filedup(p->vmas[i].f);
    80001f2c:	7488                	ld	a0,40(s1)
    80001f2e:	00003097          	auipc	ra,0x3
    80001f32:	84c080e7          	jalr	-1972(ra) # 8000477a <filedup>
  for (int i = 0; i < NVMA; i++) {
    80001f36:	03090913          	addi	s2,s2,48
    80001f3a:	03048493          	addi	s1,s1,48
    80001f3e:	01348763          	beq	s1,s3,80001f4c <fork+0x126>
    np->vmas[i].valid = 0;
    80001f42:	00092023          	sw	zero,0(s2)
    if (p->vmas[i].valid) {
    80001f46:	409c                	lw	a5,0(s1)
    80001f48:	d7fd                	beqz	a5,80001f36 <fork+0x110>
    80001f4a:	bfc9                	j	80001f1c <fork+0xf6>
  np->state = RUNNABLE;
    80001f4c:	4789                	li	a5,2
    80001f4e:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f52:	8552                	mv	a0,s4
    80001f54:	fffff097          	auipc	ra,0xfffff
    80001f58:	d84080e7          	jalr	-636(ra) # 80000cd8 <release>
}
    80001f5c:	8556                	mv	a0,s5
    80001f5e:	70e2                	ld	ra,56(sp)
    80001f60:	7442                	ld	s0,48(sp)
    80001f62:	74a2                	ld	s1,40(sp)
    80001f64:	7902                	ld	s2,32(sp)
    80001f66:	69e2                	ld	s3,24(sp)
    80001f68:	6a42                	ld	s4,16(sp)
    80001f6a:	6aa2                	ld	s5,8(sp)
    80001f6c:	6121                	addi	sp,sp,64
    80001f6e:	8082                	ret
    return -1;
    80001f70:	5afd                	li	s5,-1
    80001f72:	b7ed                	j	80001f5c <fork+0x136>

0000000080001f74 <reparent>:
{
    80001f74:	7179                	addi	sp,sp,-48
    80001f76:	f406                	sd	ra,40(sp)
    80001f78:	f022                	sd	s0,32(sp)
    80001f7a:	ec26                	sd	s1,24(sp)
    80001f7c:	e84a                	sd	s2,16(sp)
    80001f7e:	e44e                	sd	s3,8(sp)
    80001f80:	e052                	sd	s4,0(sp)
    80001f82:	1800                	addi	s0,sp,48
    80001f84:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f86:	0000f497          	auipc	s1,0xf
    80001f8a:	73248493          	addi	s1,s1,1842 # 800116b8 <proc>
      pp->parent = initproc;
    80001f8e:	00007a17          	auipc	s4,0x7
    80001f92:	09aa0a13          	addi	s4,s4,154 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f96:	00021917          	auipc	s2,0x21
    80001f9a:	12290913          	addi	s2,s2,290 # 800230b8 <tickslock>
    80001f9e:	a029                	j	80001fa8 <reparent+0x34>
    80001fa0:	46848493          	addi	s1,s1,1128
    80001fa4:	03248363          	beq	s1,s2,80001fca <reparent+0x56>
    if(pp->parent == p){
    80001fa8:	709c                	ld	a5,32(s1)
    80001faa:	ff379be3          	bne	a5,s3,80001fa0 <reparent+0x2c>
      acquire(&pp->lock);
    80001fae:	8526                	mv	a0,s1
    80001fb0:	fffff097          	auipc	ra,0xfffff
    80001fb4:	c74080e7          	jalr	-908(ra) # 80000c24 <acquire>
      pp->parent = initproc;
    80001fb8:	000a3783          	ld	a5,0(s4)
    80001fbc:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001fbe:	8526                	mv	a0,s1
    80001fc0:	fffff097          	auipc	ra,0xfffff
    80001fc4:	d18080e7          	jalr	-744(ra) # 80000cd8 <release>
    80001fc8:	bfe1                	j	80001fa0 <reparent+0x2c>
}
    80001fca:	70a2                	ld	ra,40(sp)
    80001fcc:	7402                	ld	s0,32(sp)
    80001fce:	64e2                	ld	s1,24(sp)
    80001fd0:	6942                	ld	s2,16(sp)
    80001fd2:	69a2                	ld	s3,8(sp)
    80001fd4:	6a02                	ld	s4,0(sp)
    80001fd6:	6145                	addi	sp,sp,48
    80001fd8:	8082                	ret

0000000080001fda <scheduler>:
{
    80001fda:	711d                	addi	sp,sp,-96
    80001fdc:	ec86                	sd	ra,88(sp)
    80001fde:	e8a2                	sd	s0,80(sp)
    80001fe0:	e4a6                	sd	s1,72(sp)
    80001fe2:	e0ca                	sd	s2,64(sp)
    80001fe4:	fc4e                	sd	s3,56(sp)
    80001fe6:	f852                	sd	s4,48(sp)
    80001fe8:	f456                	sd	s5,40(sp)
    80001fea:	f05a                	sd	s6,32(sp)
    80001fec:	ec5e                	sd	s7,24(sp)
    80001fee:	e862                	sd	s8,16(sp)
    80001ff0:	e466                	sd	s9,8(sp)
    80001ff2:	1080                	addi	s0,sp,96
    80001ff4:	8792                	mv	a5,tp
  int id = r_tp();
    80001ff6:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ff8:	00779c13          	slli	s8,a5,0x7
    80001ffc:	0000f717          	auipc	a4,0xf
    80002000:	2a470713          	addi	a4,a4,676 # 800112a0 <pid_lock>
    80002004:	9762                	add	a4,a4,s8
    80002006:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    8000200a:	0000f717          	auipc	a4,0xf
    8000200e:	2b670713          	addi	a4,a4,694 # 800112c0 <cpus+0x8>
    80002012:	9c3a                	add	s8,s8,a4
      if(p->state == RUNNABLE) {
    80002014:	4a89                	li	s5,2
        c->proc = p;
    80002016:	079e                	slli	a5,a5,0x7
    80002018:	0000fb17          	auipc	s6,0xf
    8000201c:	288b0b13          	addi	s6,s6,648 # 800112a0 <pid_lock>
    80002020:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002022:	00021a17          	auipc	s4,0x21
    80002026:	096a0a13          	addi	s4,s4,150 # 800230b8 <tickslock>
    int nproc = 0;
    8000202a:	4c81                	li	s9,0
    8000202c:	a8a1                	j	80002084 <scheduler+0xaa>
        p->state = RUNNING;
    8000202e:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80002032:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    80002036:	06048593          	addi	a1,s1,96
    8000203a:	8562                	mv	a0,s8
    8000203c:	00000097          	auipc	ra,0x0
    80002040:	6a4080e7          	jalr	1700(ra) # 800026e0 <swtch>
        c->proc = 0;
    80002044:	000b3c23          	sd	zero,24(s6)
      release(&p->lock);
    80002048:	8526                	mv	a0,s1
    8000204a:	fffff097          	auipc	ra,0xfffff
    8000204e:	c8e080e7          	jalr	-882(ra) # 80000cd8 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002052:	46848493          	addi	s1,s1,1128
    80002056:	01448d63          	beq	s1,s4,80002070 <scheduler+0x96>
      acquire(&p->lock);
    8000205a:	8526                	mv	a0,s1
    8000205c:	fffff097          	auipc	ra,0xfffff
    80002060:	bc8080e7          	jalr	-1080(ra) # 80000c24 <acquire>
      if(p->state != UNUSED) {
    80002064:	4c9c                	lw	a5,24(s1)
    80002066:	d3ed                	beqz	a5,80002048 <scheduler+0x6e>
        nproc++;
    80002068:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    8000206a:	fd579fe3          	bne	a5,s5,80002048 <scheduler+0x6e>
    8000206e:	b7c1                	j	8000202e <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    80002070:	013aca63          	blt	s5,s3,80002084 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002074:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002078:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000207c:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80002080:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002084:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002088:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000208c:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    80002090:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    80002092:	0000f497          	auipc	s1,0xf
    80002096:	62648493          	addi	s1,s1,1574 # 800116b8 <proc>
        p->state = RUNNING;
    8000209a:	4b8d                	li	s7,3
    8000209c:	bf7d                	j	8000205a <scheduler+0x80>

000000008000209e <sched>:
{
    8000209e:	7179                	addi	sp,sp,-48
    800020a0:	f406                	sd	ra,40(sp)
    800020a2:	f022                	sd	s0,32(sp)
    800020a4:	ec26                	sd	s1,24(sp)
    800020a6:	e84a                	sd	s2,16(sp)
    800020a8:	e44e                	sd	s3,8(sp)
    800020aa:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020ac:	00000097          	auipc	ra,0x0
    800020b0:	980080e7          	jalr	-1664(ra) # 80001a2c <myproc>
    800020b4:	892a                	mv	s2,a0
  if(!holding(&p->lock))
    800020b6:	fffff097          	auipc	ra,0xfffff
    800020ba:	af4080e7          	jalr	-1292(ra) # 80000baa <holding>
    800020be:	cd25                	beqz	a0,80002136 <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020c0:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020c2:	2781                	sext.w	a5,a5
    800020c4:	079e                	slli	a5,a5,0x7
    800020c6:	0000f717          	auipc	a4,0xf
    800020ca:	1da70713          	addi	a4,a4,474 # 800112a0 <pid_lock>
    800020ce:	97ba                	add	a5,a5,a4
    800020d0:	0907a703          	lw	a4,144(a5)
    800020d4:	4785                	li	a5,1
    800020d6:	06f71863          	bne	a4,a5,80002146 <sched+0xa8>
  if(p->state == RUNNING)
    800020da:	01892703          	lw	a4,24(s2)
    800020de:	478d                	li	a5,3
    800020e0:	06f70b63          	beq	a4,a5,80002156 <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020e4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020e8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020ea:	efb5                	bnez	a5,80002166 <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020ec:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020ee:	0000f497          	auipc	s1,0xf
    800020f2:	1b248493          	addi	s1,s1,434 # 800112a0 <pid_lock>
    800020f6:	2781                	sext.w	a5,a5
    800020f8:	079e                	slli	a5,a5,0x7
    800020fa:	97a6                	add	a5,a5,s1
    800020fc:	0947a983          	lw	s3,148(a5)
    80002100:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002102:	2781                	sext.w	a5,a5
    80002104:	079e                	slli	a5,a5,0x7
    80002106:	0000f597          	auipc	a1,0xf
    8000210a:	1ba58593          	addi	a1,a1,442 # 800112c0 <cpus+0x8>
    8000210e:	95be                	add	a1,a1,a5
    80002110:	06090513          	addi	a0,s2,96
    80002114:	00000097          	auipc	ra,0x0
    80002118:	5cc080e7          	jalr	1484(ra) # 800026e0 <swtch>
    8000211c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000211e:	2781                	sext.w	a5,a5
    80002120:	079e                	slli	a5,a5,0x7
    80002122:	97a6                	add	a5,a5,s1
    80002124:	0937aa23          	sw	s3,148(a5)
}
    80002128:	70a2                	ld	ra,40(sp)
    8000212a:	7402                	ld	s0,32(sp)
    8000212c:	64e2                	ld	s1,24(sp)
    8000212e:	6942                	ld	s2,16(sp)
    80002130:	69a2                	ld	s3,8(sp)
    80002132:	6145                	addi	sp,sp,48
    80002134:	8082                	ret
    panic("sched p->lock");
    80002136:	00006517          	auipc	a0,0x6
    8000213a:	0b250513          	addi	a0,a0,178 # 800081e8 <states.1759+0x60>
    8000213e:	ffffe097          	auipc	ra,0xffffe
    80002142:	41a080e7          	jalr	1050(ra) # 80000558 <panic>
    panic("sched locks");
    80002146:	00006517          	auipc	a0,0x6
    8000214a:	0b250513          	addi	a0,a0,178 # 800081f8 <states.1759+0x70>
    8000214e:	ffffe097          	auipc	ra,0xffffe
    80002152:	40a080e7          	jalr	1034(ra) # 80000558 <panic>
    panic("sched running");
    80002156:	00006517          	auipc	a0,0x6
    8000215a:	0b250513          	addi	a0,a0,178 # 80008208 <states.1759+0x80>
    8000215e:	ffffe097          	auipc	ra,0xffffe
    80002162:	3fa080e7          	jalr	1018(ra) # 80000558 <panic>
    panic("sched interruptible");
    80002166:	00006517          	auipc	a0,0x6
    8000216a:	0b250513          	addi	a0,a0,178 # 80008218 <states.1759+0x90>
    8000216e:	ffffe097          	auipc	ra,0xffffe
    80002172:	3ea080e7          	jalr	1002(ra) # 80000558 <panic>

0000000080002176 <exit>:
{
    80002176:	7139                	addi	sp,sp,-64
    80002178:	fc06                	sd	ra,56(sp)
    8000217a:	f822                	sd	s0,48(sp)
    8000217c:	f426                	sd	s1,40(sp)
    8000217e:	f04a                	sd	s2,32(sp)
    80002180:	ec4e                	sd	s3,24(sp)
    80002182:	e852                	sd	s4,16(sp)
    80002184:	e456                	sd	s5,8(sp)
    80002186:	0080                	addi	s0,sp,64
    80002188:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000218a:	00000097          	auipc	ra,0x0
    8000218e:	8a2080e7          	jalr	-1886(ra) # 80001a2c <myproc>
    80002192:	89aa                	mv	s3,a0
  if(p == initproc)
    80002194:	00007797          	auipc	a5,0x7
    80002198:	e9478793          	addi	a5,a5,-364 # 80009028 <initproc>
    8000219c:	639c                	ld	a5,0(a5)
    8000219e:	0d050493          	addi	s1,a0,208
    800021a2:	15050913          	addi	s2,a0,336
    800021a6:	02a79363          	bne	a5,a0,800021cc <exit+0x56>
    panic("init exiting");
    800021aa:	00006517          	auipc	a0,0x6
    800021ae:	08650513          	addi	a0,a0,134 # 80008230 <states.1759+0xa8>
    800021b2:	ffffe097          	auipc	ra,0xffffe
    800021b6:	3a6080e7          	jalr	934(ra) # 80000558 <panic>
      fileclose(f);
    800021ba:	00002097          	auipc	ra,0x2
    800021be:	612080e7          	jalr	1554(ra) # 800047cc <fileclose>
      p->ofile[fd] = 0;
    800021c2:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021c6:	04a1                	addi	s1,s1,8
    800021c8:	01248563          	beq	s1,s2,800021d2 <exit+0x5c>
    if(p->ofile[fd]){
    800021cc:	6088                	ld	a0,0(s1)
    800021ce:	f575                	bnez	a0,800021ba <exit+0x44>
    800021d0:	bfdd                	j	800021c6 <exit+0x50>
    800021d2:	16898493          	addi	s1,s3,360
    800021d6:	46898a93          	addi	s5,s3,1128
    800021da:	a0b1                	j	80002226 <exit+0xb0>
        filewrite(p->vmas[i].f, p->vmas[i].addr, p->vmas[i].length);
    800021dc:	4890                	lw	a2,16(s1)
    800021de:	648c                	ld	a1,8(s1)
    800021e0:	7488                	ld	a0,40(s1)
    800021e2:	00002097          	auipc	ra,0x2
    800021e6:	7e6080e7          	jalr	2022(ra) # 800049c8 <filewrite>
      fileclose(p->vmas[i].f);
    800021ea:	02893503          	ld	a0,40(s2)
    800021ee:	00002097          	auipc	ra,0x2
    800021f2:	5de080e7          	jalr	1502(ra) # 800047cc <fileclose>
      uvmunmap(p->pagetable, p->vmas[i].addr, p->vmas[i].length / PGSIZE, 1);
    800021f6:	01092783          	lw	a5,16(s2)
    800021fa:	41f7d61b          	sraiw	a2,a5,0x1f
    800021fe:	0146561b          	srliw	a2,a2,0x14
    80002202:	9e3d                	addw	a2,a2,a5
    80002204:	4685                	li	a3,1
    80002206:	40c6561b          	sraiw	a2,a2,0xc
    8000220a:	00893583          	ld	a1,8(s2)
    8000220e:	0509b503          	ld	a0,80(s3)
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	0b8080e7          	jalr	184(ra) # 800012ca <uvmunmap>
      p->vmas[i].valid = 0;
    8000221a:	00092023          	sw	zero,0(s2)
  for (int i = 0; i < NVMA; i++) {
    8000221e:	03048493          	addi	s1,s1,48
    80002222:	01548963          	beq	s1,s5,80002234 <exit+0xbe>
    if (p->vmas[i].valid) {
    80002226:	8926                	mv	s2,s1
    80002228:	409c                	lw	a5,0(s1)
    8000222a:	dbf5                	beqz	a5,8000221e <exit+0xa8>
      if (p->vmas[i].flags & MAP_SHARED) {
    8000222c:	4c9c                	lw	a5,24(s1)
    8000222e:	8b85                	andi	a5,a5,1
    80002230:	dfcd                	beqz	a5,800021ea <exit+0x74>
    80002232:	b76d                	j	800021dc <exit+0x66>
  begin_op();
    80002234:	00002097          	auipc	ra,0x2
    80002238:	094080e7          	jalr	148(ra) # 800042c8 <begin_op>
  iput(p->cwd);
    8000223c:	1509b503          	ld	a0,336(s3)
    80002240:	00002097          	auipc	ra,0x2
    80002244:	866080e7          	jalr	-1946(ra) # 80003aa6 <iput>
  end_op();
    80002248:	00002097          	auipc	ra,0x2
    8000224c:	100080e7          	jalr	256(ra) # 80004348 <end_op>
  p->cwd = 0;
    80002250:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    80002254:	00007497          	auipc	s1,0x7
    80002258:	dd448493          	addi	s1,s1,-556 # 80009028 <initproc>
    8000225c:	6088                	ld	a0,0(s1)
    8000225e:	fffff097          	auipc	ra,0xfffff
    80002262:	9c6080e7          	jalr	-1594(ra) # 80000c24 <acquire>
  wakeup1(initproc);
    80002266:	6088                	ld	a0,0(s1)
    80002268:	fffff097          	auipc	ra,0xfffff
    8000226c:	626080e7          	jalr	1574(ra) # 8000188e <wakeup1>
  release(&initproc->lock);
    80002270:	6088                	ld	a0,0(s1)
    80002272:	fffff097          	auipc	ra,0xfffff
    80002276:	a66080e7          	jalr	-1434(ra) # 80000cd8 <release>
  acquire(&p->lock);
    8000227a:	854e                	mv	a0,s3
    8000227c:	fffff097          	auipc	ra,0xfffff
    80002280:	9a8080e7          	jalr	-1624(ra) # 80000c24 <acquire>
  struct proc *original_parent = p->parent;
    80002284:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002288:	854e                	mv	a0,s3
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	a4e080e7          	jalr	-1458(ra) # 80000cd8 <release>
  acquire(&original_parent->lock);
    80002292:	8526                	mv	a0,s1
    80002294:	fffff097          	auipc	ra,0xfffff
    80002298:	990080e7          	jalr	-1648(ra) # 80000c24 <acquire>
  acquire(&p->lock);
    8000229c:	854e                	mv	a0,s3
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	986080e7          	jalr	-1658(ra) # 80000c24 <acquire>
  reparent(p);
    800022a6:	854e                	mv	a0,s3
    800022a8:	00000097          	auipc	ra,0x0
    800022ac:	ccc080e7          	jalr	-820(ra) # 80001f74 <reparent>
  wakeup1(original_parent);
    800022b0:	8526                	mv	a0,s1
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	5dc080e7          	jalr	1500(ra) # 8000188e <wakeup1>
  p->xstate = status;
    800022ba:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800022be:	4791                	li	a5,4
    800022c0:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800022c4:	8526                	mv	a0,s1
    800022c6:	fffff097          	auipc	ra,0xfffff
    800022ca:	a12080e7          	jalr	-1518(ra) # 80000cd8 <release>
  sched();
    800022ce:	00000097          	auipc	ra,0x0
    800022d2:	dd0080e7          	jalr	-560(ra) # 8000209e <sched>
  panic("zombie exit");
    800022d6:	00006517          	auipc	a0,0x6
    800022da:	f6a50513          	addi	a0,a0,-150 # 80008240 <states.1759+0xb8>
    800022de:	ffffe097          	auipc	ra,0xffffe
    800022e2:	27a080e7          	jalr	634(ra) # 80000558 <panic>

00000000800022e6 <yield>:
{
    800022e6:	1101                	addi	sp,sp,-32
    800022e8:	ec06                	sd	ra,24(sp)
    800022ea:	e822                	sd	s0,16(sp)
    800022ec:	e426                	sd	s1,8(sp)
    800022ee:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800022f0:	fffff097          	auipc	ra,0xfffff
    800022f4:	73c080e7          	jalr	1852(ra) # 80001a2c <myproc>
    800022f8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	92a080e7          	jalr	-1750(ra) # 80000c24 <acquire>
  p->state = RUNNABLE;
    80002302:	4789                	li	a5,2
    80002304:	cc9c                	sw	a5,24(s1)
  sched();
    80002306:	00000097          	auipc	ra,0x0
    8000230a:	d98080e7          	jalr	-616(ra) # 8000209e <sched>
  release(&p->lock);
    8000230e:	8526                	mv	a0,s1
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	9c8080e7          	jalr	-1592(ra) # 80000cd8 <release>
}
    80002318:	60e2                	ld	ra,24(sp)
    8000231a:	6442                	ld	s0,16(sp)
    8000231c:	64a2                	ld	s1,8(sp)
    8000231e:	6105                	addi	sp,sp,32
    80002320:	8082                	ret

0000000080002322 <sleep>:
{
    80002322:	7179                	addi	sp,sp,-48
    80002324:	f406                	sd	ra,40(sp)
    80002326:	f022                	sd	s0,32(sp)
    80002328:	ec26                	sd	s1,24(sp)
    8000232a:	e84a                	sd	s2,16(sp)
    8000232c:	e44e                	sd	s3,8(sp)
    8000232e:	1800                	addi	s0,sp,48
    80002330:	89aa                	mv	s3,a0
    80002332:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002334:	fffff097          	auipc	ra,0xfffff
    80002338:	6f8080e7          	jalr	1784(ra) # 80001a2c <myproc>
    8000233c:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8000233e:	05250663          	beq	a0,s2,8000238a <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	8e2080e7          	jalr	-1822(ra) # 80000c24 <acquire>
    release(lk);
    8000234a:	854a                	mv	a0,s2
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	98c080e7          	jalr	-1652(ra) # 80000cd8 <release>
  p->chan = chan;
    80002354:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002358:	4785                	li	a5,1
    8000235a:	cc9c                	sw	a5,24(s1)
  sched();
    8000235c:	00000097          	auipc	ra,0x0
    80002360:	d42080e7          	jalr	-702(ra) # 8000209e <sched>
  p->chan = 0;
    80002364:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	96e080e7          	jalr	-1682(ra) # 80000cd8 <release>
    acquire(lk);
    80002372:	854a                	mv	a0,s2
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	8b0080e7          	jalr	-1872(ra) # 80000c24 <acquire>
}
    8000237c:	70a2                	ld	ra,40(sp)
    8000237e:	7402                	ld	s0,32(sp)
    80002380:	64e2                	ld	s1,24(sp)
    80002382:	6942                	ld	s2,16(sp)
    80002384:	69a2                	ld	s3,8(sp)
    80002386:	6145                	addi	sp,sp,48
    80002388:	8082                	ret
  p->chan = chan;
    8000238a:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    8000238e:	4785                	li	a5,1
    80002390:	cd1c                	sw	a5,24(a0)
  sched();
    80002392:	00000097          	auipc	ra,0x0
    80002396:	d0c080e7          	jalr	-756(ra) # 8000209e <sched>
  p->chan = 0;
    8000239a:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    8000239e:	bff9                	j	8000237c <sleep+0x5a>

00000000800023a0 <wait>:
{
    800023a0:	715d                	addi	sp,sp,-80
    800023a2:	e486                	sd	ra,72(sp)
    800023a4:	e0a2                	sd	s0,64(sp)
    800023a6:	fc26                	sd	s1,56(sp)
    800023a8:	f84a                	sd	s2,48(sp)
    800023aa:	f44e                	sd	s3,40(sp)
    800023ac:	f052                	sd	s4,32(sp)
    800023ae:	ec56                	sd	s5,24(sp)
    800023b0:	e85a                	sd	s6,16(sp)
    800023b2:	e45e                	sd	s7,8(sp)
    800023b4:	e062                	sd	s8,0(sp)
    800023b6:	0880                	addi	s0,sp,80
    800023b8:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	672080e7          	jalr	1650(ra) # 80001a2c <myproc>
    800023c2:	892a                	mv	s2,a0
  acquire(&p->lock);
    800023c4:	8c2a                	mv	s8,a0
    800023c6:	fffff097          	auipc	ra,0xfffff
    800023ca:	85e080e7          	jalr	-1954(ra) # 80000c24 <acquire>
    havekids = 0;
    800023ce:	4b01                	li	s6,0
        if(np->state == ZOMBIE){
    800023d0:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800023d2:	00021997          	auipc	s3,0x21
    800023d6:	ce698993          	addi	s3,s3,-794 # 800230b8 <tickslock>
        havekids = 1;
    800023da:	4a85                	li	s5,1
    havekids = 0;
    800023dc:	875a                	mv	a4,s6
    for(np = proc; np < &proc[NPROC]; np++){
    800023de:	0000f497          	auipc	s1,0xf
    800023e2:	2da48493          	addi	s1,s1,730 # 800116b8 <proc>
    800023e6:	a08d                	j	80002448 <wait+0xa8>
          pid = np->pid;
    800023e8:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800023ec:	000b8e63          	beqz	s7,80002408 <wait+0x68>
    800023f0:	4691                	li	a3,4
    800023f2:	03448613          	addi	a2,s1,52
    800023f6:	85de                	mv	a1,s7
    800023f8:	05093503          	ld	a0,80(s2)
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	2ae080e7          	jalr	686(ra) # 800016aa <copyout>
    80002404:	02054263          	bltz	a0,80002428 <wait+0x88>
          freeproc(np);
    80002408:	8526                	mv	a0,s1
    8000240a:	fffff097          	auipc	ra,0xfffff
    8000240e:	7d6080e7          	jalr	2006(ra) # 80001be0 <freeproc>
          release(&np->lock);
    80002412:	8526                	mv	a0,s1
    80002414:	fffff097          	auipc	ra,0xfffff
    80002418:	8c4080e7          	jalr	-1852(ra) # 80000cd8 <release>
          release(&p->lock);
    8000241c:	854a                	mv	a0,s2
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	8ba080e7          	jalr	-1862(ra) # 80000cd8 <release>
          return pid;
    80002426:	a8a9                	j	80002480 <wait+0xe0>
            release(&np->lock);
    80002428:	8526                	mv	a0,s1
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	8ae080e7          	jalr	-1874(ra) # 80000cd8 <release>
            release(&p->lock);
    80002432:	854a                	mv	a0,s2
    80002434:	fffff097          	auipc	ra,0xfffff
    80002438:	8a4080e7          	jalr	-1884(ra) # 80000cd8 <release>
            return -1;
    8000243c:	59fd                	li	s3,-1
    8000243e:	a089                	j	80002480 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002440:	46848493          	addi	s1,s1,1128
    80002444:	03348463          	beq	s1,s3,8000246c <wait+0xcc>
      if(np->parent == p){
    80002448:	709c                	ld	a5,32(s1)
    8000244a:	ff279be3          	bne	a5,s2,80002440 <wait+0xa0>
        acquire(&np->lock);
    8000244e:	8526                	mv	a0,s1
    80002450:	ffffe097          	auipc	ra,0xffffe
    80002454:	7d4080e7          	jalr	2004(ra) # 80000c24 <acquire>
        if(np->state == ZOMBIE){
    80002458:	4c9c                	lw	a5,24(s1)
    8000245a:	f94787e3          	beq	a5,s4,800023e8 <wait+0x48>
        release(&np->lock);
    8000245e:	8526                	mv	a0,s1
    80002460:	fffff097          	auipc	ra,0xfffff
    80002464:	878080e7          	jalr	-1928(ra) # 80000cd8 <release>
        havekids = 1;
    80002468:	8756                	mv	a4,s5
    8000246a:	bfd9                	j	80002440 <wait+0xa0>
    if(!havekids || p->killed){
    8000246c:	c701                	beqz	a4,80002474 <wait+0xd4>
    8000246e:	03092783          	lw	a5,48(s2)
    80002472:	c785                	beqz	a5,8000249a <wait+0xfa>
      release(&p->lock);
    80002474:	854a                	mv	a0,s2
    80002476:	fffff097          	auipc	ra,0xfffff
    8000247a:	862080e7          	jalr	-1950(ra) # 80000cd8 <release>
      return -1;
    8000247e:	59fd                	li	s3,-1
}
    80002480:	854e                	mv	a0,s3
    80002482:	60a6                	ld	ra,72(sp)
    80002484:	6406                	ld	s0,64(sp)
    80002486:	74e2                	ld	s1,56(sp)
    80002488:	7942                	ld	s2,48(sp)
    8000248a:	79a2                	ld	s3,40(sp)
    8000248c:	7a02                	ld	s4,32(sp)
    8000248e:	6ae2                	ld	s5,24(sp)
    80002490:	6b42                	ld	s6,16(sp)
    80002492:	6ba2                	ld	s7,8(sp)
    80002494:	6c02                	ld	s8,0(sp)
    80002496:	6161                	addi	sp,sp,80
    80002498:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000249a:	85e2                	mv	a1,s8
    8000249c:	854a                	mv	a0,s2
    8000249e:	00000097          	auipc	ra,0x0
    800024a2:	e84080e7          	jalr	-380(ra) # 80002322 <sleep>
    havekids = 0;
    800024a6:	bf1d                	j	800023dc <wait+0x3c>

00000000800024a8 <wakeup>:
{
    800024a8:	7139                	addi	sp,sp,-64
    800024aa:	fc06                	sd	ra,56(sp)
    800024ac:	f822                	sd	s0,48(sp)
    800024ae:	f426                	sd	s1,40(sp)
    800024b0:	f04a                	sd	s2,32(sp)
    800024b2:	ec4e                	sd	s3,24(sp)
    800024b4:	e852                	sd	s4,16(sp)
    800024b6:	e456                	sd	s5,8(sp)
    800024b8:	0080                	addi	s0,sp,64
    800024ba:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800024bc:	0000f497          	auipc	s1,0xf
    800024c0:	1fc48493          	addi	s1,s1,508 # 800116b8 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800024c4:	4985                	li	s3,1
      p->state = RUNNABLE;
    800024c6:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800024c8:	00021917          	auipc	s2,0x21
    800024cc:	bf090913          	addi	s2,s2,-1040 # 800230b8 <tickslock>
    800024d0:	a821                	j	800024e8 <wakeup+0x40>
      p->state = RUNNABLE;
    800024d2:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    800024d6:	8526                	mv	a0,s1
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	800080e7          	jalr	-2048(ra) # 80000cd8 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800024e0:	46848493          	addi	s1,s1,1128
    800024e4:	01248e63          	beq	s1,s2,80002500 <wakeup+0x58>
    acquire(&p->lock);
    800024e8:	8526                	mv	a0,s1
    800024ea:	ffffe097          	auipc	ra,0xffffe
    800024ee:	73a080e7          	jalr	1850(ra) # 80000c24 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800024f2:	4c9c                	lw	a5,24(s1)
    800024f4:	ff3791e3          	bne	a5,s3,800024d6 <wakeup+0x2e>
    800024f8:	749c                	ld	a5,40(s1)
    800024fa:	fd479ee3          	bne	a5,s4,800024d6 <wakeup+0x2e>
    800024fe:	bfd1                	j	800024d2 <wakeup+0x2a>
}
    80002500:	70e2                	ld	ra,56(sp)
    80002502:	7442                	ld	s0,48(sp)
    80002504:	74a2                	ld	s1,40(sp)
    80002506:	7902                	ld	s2,32(sp)
    80002508:	69e2                	ld	s3,24(sp)
    8000250a:	6a42                	ld	s4,16(sp)
    8000250c:	6aa2                	ld	s5,8(sp)
    8000250e:	6121                	addi	sp,sp,64
    80002510:	8082                	ret

0000000080002512 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002512:	7179                	addi	sp,sp,-48
    80002514:	f406                	sd	ra,40(sp)
    80002516:	f022                	sd	s0,32(sp)
    80002518:	ec26                	sd	s1,24(sp)
    8000251a:	e84a                	sd	s2,16(sp)
    8000251c:	e44e                	sd	s3,8(sp)
    8000251e:	1800                	addi	s0,sp,48
    80002520:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002522:	0000f497          	auipc	s1,0xf
    80002526:	19648493          	addi	s1,s1,406 # 800116b8 <proc>
    8000252a:	00021997          	auipc	s3,0x21
    8000252e:	b8e98993          	addi	s3,s3,-1138 # 800230b8 <tickslock>
    acquire(&p->lock);
    80002532:	8526                	mv	a0,s1
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	6f0080e7          	jalr	1776(ra) # 80000c24 <acquire>
    if(p->pid == pid){
    8000253c:	5c9c                	lw	a5,56(s1)
    8000253e:	01278d63          	beq	a5,s2,80002558 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002542:	8526                	mv	a0,s1
    80002544:	ffffe097          	auipc	ra,0xffffe
    80002548:	794080e7          	jalr	1940(ra) # 80000cd8 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000254c:	46848493          	addi	s1,s1,1128
    80002550:	ff3491e3          	bne	s1,s3,80002532 <kill+0x20>
  }
  return -1;
    80002554:	557d                	li	a0,-1
    80002556:	a829                	j	80002570 <kill+0x5e>
      p->killed = 1;
    80002558:	4785                	li	a5,1
    8000255a:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    8000255c:	4c98                	lw	a4,24(s1)
    8000255e:	4785                	li	a5,1
    80002560:	00f70f63          	beq	a4,a5,8000257e <kill+0x6c>
      release(&p->lock);
    80002564:	8526                	mv	a0,s1
    80002566:	ffffe097          	auipc	ra,0xffffe
    8000256a:	772080e7          	jalr	1906(ra) # 80000cd8 <release>
      return 0;
    8000256e:	4501                	li	a0,0
}
    80002570:	70a2                	ld	ra,40(sp)
    80002572:	7402                	ld	s0,32(sp)
    80002574:	64e2                	ld	s1,24(sp)
    80002576:	6942                	ld	s2,16(sp)
    80002578:	69a2                	ld	s3,8(sp)
    8000257a:	6145                	addi	sp,sp,48
    8000257c:	8082                	ret
        p->state = RUNNABLE;
    8000257e:	4789                	li	a5,2
    80002580:	cc9c                	sw	a5,24(s1)
    80002582:	b7cd                	j	80002564 <kill+0x52>

0000000080002584 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002584:	7179                	addi	sp,sp,-48
    80002586:	f406                	sd	ra,40(sp)
    80002588:	f022                	sd	s0,32(sp)
    8000258a:	ec26                	sd	s1,24(sp)
    8000258c:	e84a                	sd	s2,16(sp)
    8000258e:	e44e                	sd	s3,8(sp)
    80002590:	e052                	sd	s4,0(sp)
    80002592:	1800                	addi	s0,sp,48
    80002594:	84aa                	mv	s1,a0
    80002596:	892e                	mv	s2,a1
    80002598:	89b2                	mv	s3,a2
    8000259a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000259c:	fffff097          	auipc	ra,0xfffff
    800025a0:	490080e7          	jalr	1168(ra) # 80001a2c <myproc>
  if(user_dst){
    800025a4:	c08d                	beqz	s1,800025c6 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800025a6:	86d2                	mv	a3,s4
    800025a8:	864e                	mv	a2,s3
    800025aa:	85ca                	mv	a1,s2
    800025ac:	6928                	ld	a0,80(a0)
    800025ae:	fffff097          	auipc	ra,0xfffff
    800025b2:	0fc080e7          	jalr	252(ra) # 800016aa <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025b6:	70a2                	ld	ra,40(sp)
    800025b8:	7402                	ld	s0,32(sp)
    800025ba:	64e2                	ld	s1,24(sp)
    800025bc:	6942                	ld	s2,16(sp)
    800025be:	69a2                	ld	s3,8(sp)
    800025c0:	6a02                	ld	s4,0(sp)
    800025c2:	6145                	addi	sp,sp,48
    800025c4:	8082                	ret
    memmove((char *)dst, src, len);
    800025c6:	000a061b          	sext.w	a2,s4
    800025ca:	85ce                	mv	a1,s3
    800025cc:	854a                	mv	a0,s2
    800025ce:	ffffe097          	auipc	ra,0xffffe
    800025d2:	7be080e7          	jalr	1982(ra) # 80000d8c <memmove>
    return 0;
    800025d6:	8526                	mv	a0,s1
    800025d8:	bff9                	j	800025b6 <either_copyout+0x32>

00000000800025da <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025da:	7179                	addi	sp,sp,-48
    800025dc:	f406                	sd	ra,40(sp)
    800025de:	f022                	sd	s0,32(sp)
    800025e0:	ec26                	sd	s1,24(sp)
    800025e2:	e84a                	sd	s2,16(sp)
    800025e4:	e44e                	sd	s3,8(sp)
    800025e6:	e052                	sd	s4,0(sp)
    800025e8:	1800                	addi	s0,sp,48
    800025ea:	892a                	mv	s2,a0
    800025ec:	84ae                	mv	s1,a1
    800025ee:	89b2                	mv	s3,a2
    800025f0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025f2:	fffff097          	auipc	ra,0xfffff
    800025f6:	43a080e7          	jalr	1082(ra) # 80001a2c <myproc>
  if(user_src){
    800025fa:	c08d                	beqz	s1,8000261c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800025fc:	86d2                	mv	a3,s4
    800025fe:	864e                	mv	a2,s3
    80002600:	85ca                	mv	a1,s2
    80002602:	6928                	ld	a0,80(a0)
    80002604:	fffff097          	auipc	ra,0xfffff
    80002608:	132080e7          	jalr	306(ra) # 80001736 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000260c:	70a2                	ld	ra,40(sp)
    8000260e:	7402                	ld	s0,32(sp)
    80002610:	64e2                	ld	s1,24(sp)
    80002612:	6942                	ld	s2,16(sp)
    80002614:	69a2                	ld	s3,8(sp)
    80002616:	6a02                	ld	s4,0(sp)
    80002618:	6145                	addi	sp,sp,48
    8000261a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000261c:	000a061b          	sext.w	a2,s4
    80002620:	85ce                	mv	a1,s3
    80002622:	854a                	mv	a0,s2
    80002624:	ffffe097          	auipc	ra,0xffffe
    80002628:	768080e7          	jalr	1896(ra) # 80000d8c <memmove>
    return 0;
    8000262c:	8526                	mv	a0,s1
    8000262e:	bff9                	j	8000260c <either_copyin+0x32>

0000000080002630 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002630:	715d                	addi	sp,sp,-80
    80002632:	e486                	sd	ra,72(sp)
    80002634:	e0a2                	sd	s0,64(sp)
    80002636:	fc26                	sd	s1,56(sp)
    80002638:	f84a                	sd	s2,48(sp)
    8000263a:	f44e                	sd	s3,40(sp)
    8000263c:	f052                	sd	s4,32(sp)
    8000263e:	ec56                	sd	s5,24(sp)
    80002640:	e85a                	sd	s6,16(sp)
    80002642:	e45e                	sd	s7,8(sp)
    80002644:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002646:	00006517          	auipc	a0,0x6
    8000264a:	a8250513          	addi	a0,a0,-1406 # 800080c8 <digits+0xb0>
    8000264e:	ffffe097          	auipc	ra,0xffffe
    80002652:	f54080e7          	jalr	-172(ra) # 800005a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002656:	0000f497          	auipc	s1,0xf
    8000265a:	1ba48493          	addi	s1,s1,442 # 80011810 <proc+0x158>
    8000265e:	00021917          	auipc	s2,0x21
    80002662:	bb290913          	addi	s2,s2,-1102 # 80023210 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002666:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002668:	00006997          	auipc	s3,0x6
    8000266c:	be898993          	addi	s3,s3,-1048 # 80008250 <states.1759+0xc8>
    printf("%d %s %s", p->pid, state, p->name);
    80002670:	00006a97          	auipc	s5,0x6
    80002674:	be8a8a93          	addi	s5,s5,-1048 # 80008258 <states.1759+0xd0>
    printf("\n");
    80002678:	00006a17          	auipc	s4,0x6
    8000267c:	a50a0a13          	addi	s4,s4,-1456 # 800080c8 <digits+0xb0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002680:	00006b97          	auipc	s7,0x6
    80002684:	b08b8b93          	addi	s7,s7,-1272 # 80008188 <states.1759>
    80002688:	a015                	j	800026ac <procdump+0x7c>
    printf("%d %s %s", p->pid, state, p->name);
    8000268a:	86ba                	mv	a3,a4
    8000268c:	ee072583          	lw	a1,-288(a4)
    80002690:	8556                	mv	a0,s5
    80002692:	ffffe097          	auipc	ra,0xffffe
    80002696:	f10080e7          	jalr	-240(ra) # 800005a2 <printf>
    printf("\n");
    8000269a:	8552                	mv	a0,s4
    8000269c:	ffffe097          	auipc	ra,0xffffe
    800026a0:	f06080e7          	jalr	-250(ra) # 800005a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026a4:	46848493          	addi	s1,s1,1128
    800026a8:	03248163          	beq	s1,s2,800026ca <procdump+0x9a>
    if(p->state == UNUSED)
    800026ac:	8726                	mv	a4,s1
    800026ae:	ec04a783          	lw	a5,-320(s1)
    800026b2:	dbed                	beqz	a5,800026a4 <procdump+0x74>
      state = "???";
    800026b4:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026b6:	fcfb6ae3          	bltu	s6,a5,8000268a <procdump+0x5a>
    800026ba:	1782                	slli	a5,a5,0x20
    800026bc:	9381                	srli	a5,a5,0x20
    800026be:	078e                	slli	a5,a5,0x3
    800026c0:	97de                	add	a5,a5,s7
    800026c2:	6390                	ld	a2,0(a5)
    800026c4:	f279                	bnez	a2,8000268a <procdump+0x5a>
      state = "???";
    800026c6:	864e                	mv	a2,s3
    800026c8:	b7c9                	j	8000268a <procdump+0x5a>
  }
}
    800026ca:	60a6                	ld	ra,72(sp)
    800026cc:	6406                	ld	s0,64(sp)
    800026ce:	74e2                	ld	s1,56(sp)
    800026d0:	7942                	ld	s2,48(sp)
    800026d2:	79a2                	ld	s3,40(sp)
    800026d4:	7a02                	ld	s4,32(sp)
    800026d6:	6ae2                	ld	s5,24(sp)
    800026d8:	6b42                	ld	s6,16(sp)
    800026da:	6ba2                	ld	s7,8(sp)
    800026dc:	6161                	addi	sp,sp,80
    800026de:	8082                	ret

00000000800026e0 <swtch>:
    800026e0:	00153023          	sd	ra,0(a0)
    800026e4:	00253423          	sd	sp,8(a0)
    800026e8:	e900                	sd	s0,16(a0)
    800026ea:	ed04                	sd	s1,24(a0)
    800026ec:	03253023          	sd	s2,32(a0)
    800026f0:	03353423          	sd	s3,40(a0)
    800026f4:	03453823          	sd	s4,48(a0)
    800026f8:	03553c23          	sd	s5,56(a0)
    800026fc:	05653023          	sd	s6,64(a0)
    80002700:	05753423          	sd	s7,72(a0)
    80002704:	05853823          	sd	s8,80(a0)
    80002708:	05953c23          	sd	s9,88(a0)
    8000270c:	07a53023          	sd	s10,96(a0)
    80002710:	07b53423          	sd	s11,104(a0)
    80002714:	0005b083          	ld	ra,0(a1)
    80002718:	0085b103          	ld	sp,8(a1)
    8000271c:	6980                	ld	s0,16(a1)
    8000271e:	6d84                	ld	s1,24(a1)
    80002720:	0205b903          	ld	s2,32(a1)
    80002724:	0285b983          	ld	s3,40(a1)
    80002728:	0305ba03          	ld	s4,48(a1)
    8000272c:	0385ba83          	ld	s5,56(a1)
    80002730:	0405bb03          	ld	s6,64(a1)
    80002734:	0485bb83          	ld	s7,72(a1)
    80002738:	0505bc03          	ld	s8,80(a1)
    8000273c:	0585bc83          	ld	s9,88(a1)
    80002740:	0605bd03          	ld	s10,96(a1)
    80002744:	0685bd83          	ld	s11,104(a1)
    80002748:	8082                	ret

000000008000274a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000274a:	1141                	addi	sp,sp,-16
    8000274c:	e406                	sd	ra,8(sp)
    8000274e:	e022                	sd	s0,0(sp)
    80002750:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002752:	00006597          	auipc	a1,0x6
    80002756:	b3e58593          	addi	a1,a1,-1218 # 80008290 <states.1759+0x108>
    8000275a:	00021517          	auipc	a0,0x21
    8000275e:	95e50513          	addi	a0,a0,-1698 # 800230b8 <tickslock>
    80002762:	ffffe097          	auipc	ra,0xffffe
    80002766:	432080e7          	jalr	1074(ra) # 80000b94 <initlock>
}
    8000276a:	60a2                	ld	ra,8(sp)
    8000276c:	6402                	ld	s0,0(sp)
    8000276e:	0141                	addi	sp,sp,16
    80002770:	8082                	ret

0000000080002772 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002772:	1141                	addi	sp,sp,-16
    80002774:	e422                	sd	s0,8(sp)
    80002776:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002778:	00004797          	auipc	a5,0x4
    8000277c:	9e878793          	addi	a5,a5,-1560 # 80006160 <kernelvec>
    80002780:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002784:	6422                	ld	s0,8(sp)
    80002786:	0141                	addi	sp,sp,16
    80002788:	8082                	ret

000000008000278a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000278a:	1141                	addi	sp,sp,-16
    8000278c:	e406                	sd	ra,8(sp)
    8000278e:	e022                	sd	s0,0(sp)
    80002790:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002792:	fffff097          	auipc	ra,0xfffff
    80002796:	29a080e7          	jalr	666(ra) # 80001a2c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000279a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000279e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027a0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800027a4:	00005617          	auipc	a2,0x5
    800027a8:	85c60613          	addi	a2,a2,-1956 # 80007000 <_trampoline>
    800027ac:	00005697          	auipc	a3,0x5
    800027b0:	85468693          	addi	a3,a3,-1964 # 80007000 <_trampoline>
    800027b4:	8e91                	sub	a3,a3,a2
    800027b6:	040007b7          	lui	a5,0x4000
    800027ba:	17fd                	addi	a5,a5,-1
    800027bc:	07b2                	slli	a5,a5,0xc
    800027be:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027c0:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027c4:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027c6:	180026f3          	csrr	a3,satp
    800027ca:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027cc:	6d38                	ld	a4,88(a0)
    800027ce:	6134                	ld	a3,64(a0)
    800027d0:	6585                	lui	a1,0x1
    800027d2:	96ae                	add	a3,a3,a1
    800027d4:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027d6:	6d38                	ld	a4,88(a0)
    800027d8:	00000697          	auipc	a3,0x0
    800027dc:	13868693          	addi	a3,a3,312 # 80002910 <usertrap>
    800027e0:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027e2:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027e4:	8692                	mv	a3,tp
    800027e6:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027e8:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027ec:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027f0:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027f4:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027f8:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027fa:	6f18                	ld	a4,24(a4)
    800027fc:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002800:	692c                	ld	a1,80(a0)
    80002802:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002804:	00005717          	auipc	a4,0x5
    80002808:	88c70713          	addi	a4,a4,-1908 # 80007090 <userret>
    8000280c:	8f11                	sub	a4,a4,a2
    8000280e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002810:	577d                	li	a4,-1
    80002812:	177e                	slli	a4,a4,0x3f
    80002814:	8dd9                	or	a1,a1,a4
    80002816:	02000537          	lui	a0,0x2000
    8000281a:	157d                	addi	a0,a0,-1
    8000281c:	0536                	slli	a0,a0,0xd
    8000281e:	9782                	jalr	a5
}
    80002820:	60a2                	ld	ra,8(sp)
    80002822:	6402                	ld	s0,0(sp)
    80002824:	0141                	addi	sp,sp,16
    80002826:	8082                	ret

0000000080002828 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002828:	1101                	addi	sp,sp,-32
    8000282a:	ec06                	sd	ra,24(sp)
    8000282c:	e822                	sd	s0,16(sp)
    8000282e:	e426                	sd	s1,8(sp)
    80002830:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002832:	00021497          	auipc	s1,0x21
    80002836:	88648493          	addi	s1,s1,-1914 # 800230b8 <tickslock>
    8000283a:	8526                	mv	a0,s1
    8000283c:	ffffe097          	auipc	ra,0xffffe
    80002840:	3e8080e7          	jalr	1000(ra) # 80000c24 <acquire>
  ticks++;
    80002844:	00006517          	auipc	a0,0x6
    80002848:	7ec50513          	addi	a0,a0,2028 # 80009030 <ticks>
    8000284c:	411c                	lw	a5,0(a0)
    8000284e:	2785                	addiw	a5,a5,1
    80002850:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002852:	00000097          	auipc	ra,0x0
    80002856:	c56080e7          	jalr	-938(ra) # 800024a8 <wakeup>
  release(&tickslock);
    8000285a:	8526                	mv	a0,s1
    8000285c:	ffffe097          	auipc	ra,0xffffe
    80002860:	47c080e7          	jalr	1148(ra) # 80000cd8 <release>
}
    80002864:	60e2                	ld	ra,24(sp)
    80002866:	6442                	ld	s0,16(sp)
    80002868:	64a2                	ld	s1,8(sp)
    8000286a:	6105                	addi	sp,sp,32
    8000286c:	8082                	ret

000000008000286e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000286e:	1101                	addi	sp,sp,-32
    80002870:	ec06                	sd	ra,24(sp)
    80002872:	e822                	sd	s0,16(sp)
    80002874:	e426                	sd	s1,8(sp)
    80002876:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002878:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000287c:	00074d63          	bltz	a4,80002896 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002880:	57fd                	li	a5,-1
    80002882:	17fe                	slli	a5,a5,0x3f
    80002884:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002886:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002888:	06f70363          	beq	a4,a5,800028ee <devintr+0x80>
  }
}
    8000288c:	60e2                	ld	ra,24(sp)
    8000288e:	6442                	ld	s0,16(sp)
    80002890:	64a2                	ld	s1,8(sp)
    80002892:	6105                	addi	sp,sp,32
    80002894:	8082                	ret
     (scause & 0xff) == 9){
    80002896:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000289a:	46a5                	li	a3,9
    8000289c:	fed792e3          	bne	a5,a3,80002880 <devintr+0x12>
    int irq = plic_claim();
    800028a0:	00004097          	auipc	ra,0x4
    800028a4:	9c8080e7          	jalr	-1592(ra) # 80006268 <plic_claim>
    800028a8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028aa:	47a9                	li	a5,10
    800028ac:	02f50763          	beq	a0,a5,800028da <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800028b0:	4785                	li	a5,1
    800028b2:	02f50963          	beq	a0,a5,800028e4 <devintr+0x76>
    return 1;
    800028b6:	4505                	li	a0,1
    } else if(irq){
    800028b8:	d8f1                	beqz	s1,8000288c <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800028ba:	85a6                	mv	a1,s1
    800028bc:	00006517          	auipc	a0,0x6
    800028c0:	9dc50513          	addi	a0,a0,-1572 # 80008298 <states.1759+0x110>
    800028c4:	ffffe097          	auipc	ra,0xffffe
    800028c8:	cde080e7          	jalr	-802(ra) # 800005a2 <printf>
      plic_complete(irq);
    800028cc:	8526                	mv	a0,s1
    800028ce:	00004097          	auipc	ra,0x4
    800028d2:	9be080e7          	jalr	-1602(ra) # 8000628c <plic_complete>
    return 1;
    800028d6:	4505                	li	a0,1
    800028d8:	bf55                	j	8000288c <devintr+0x1e>
      uartintr();
    800028da:	ffffe097          	auipc	ra,0xffffe
    800028de:	10a080e7          	jalr	266(ra) # 800009e4 <uartintr>
    800028e2:	b7ed                	j	800028cc <devintr+0x5e>
      virtio_disk_intr();
    800028e4:	00004097          	auipc	ra,0x4
    800028e8:	ea6080e7          	jalr	-346(ra) # 8000678a <virtio_disk_intr>
    800028ec:	b7c5                	j	800028cc <devintr+0x5e>
    if(cpuid() == 0){
    800028ee:	fffff097          	auipc	ra,0xfffff
    800028f2:	112080e7          	jalr	274(ra) # 80001a00 <cpuid>
    800028f6:	c901                	beqz	a0,80002906 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800028f8:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800028fc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800028fe:	14479073          	csrw	sip,a5
    return 2;
    80002902:	4509                	li	a0,2
    80002904:	b761                	j	8000288c <devintr+0x1e>
      clockintr();
    80002906:	00000097          	auipc	ra,0x0
    8000290a:	f22080e7          	jalr	-222(ra) # 80002828 <clockintr>
    8000290e:	b7ed                	j	800028f8 <devintr+0x8a>

0000000080002910 <usertrap>:
{
    80002910:	7139                	addi	sp,sp,-64
    80002912:	fc06                	sd	ra,56(sp)
    80002914:	f822                	sd	s0,48(sp)
    80002916:	f426                	sd	s1,40(sp)
    80002918:	f04a                	sd	s2,32(sp)
    8000291a:	ec4e                	sd	s3,24(sp)
    8000291c:	e852                	sd	s4,16(sp)
    8000291e:	e456                	sd	s5,8(sp)
    80002920:	e05a                	sd	s6,0(sp)
    80002922:	0080                	addi	s0,sp,64
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002924:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002928:	1007f793          	andi	a5,a5,256
    8000292c:	e3ad                	bnez	a5,8000298e <usertrap+0x7e>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000292e:	00004797          	auipc	a5,0x4
    80002932:	83278793          	addi	a5,a5,-1998 # 80006160 <kernelvec>
    80002936:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000293a:	fffff097          	auipc	ra,0xfffff
    8000293e:	0f2080e7          	jalr	242(ra) # 80001a2c <myproc>
    80002942:	892a                	mv	s2,a0
  p->trapframe->epc = r_sepc();
    80002944:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002946:	14102773          	csrr	a4,sepc
    8000294a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000294c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002950:	47a1                	li	a5,8
    80002952:	04f70663          	beq	a4,a5,8000299e <usertrap+0x8e>
    80002956:	14202773          	csrr	a4,scause
  } else if(r_scause() == 13 || r_scause() == 15) {
    8000295a:	47b5                	li	a5,13
    8000295c:	00f70763          	beq	a4,a5,8000296a <usertrap+0x5a>
    80002960:	14202773          	csrr	a4,scause
    80002964:	47bd                	li	a5,15
    80002966:	18f71463          	bne	a4,a5,80002aee <usertrap+0x1de>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000296a:	143029f3          	csrr	s3,stval
    struct proc* p = myproc();
    8000296e:	fffff097          	auipc	ra,0xfffff
    80002972:	0be080e7          	jalr	190(ra) # 80001a2c <myproc>
    80002976:	8a2a                	mv	s4,a0
    if (va > MAXVA || va > p->sz) {
    80002978:	4785                	li	a5,1
    8000297a:	179a                	slli	a5,a5,0x26
    8000297c:	0137e563          	bltu	a5,s3,80002986 <usertrap+0x76>
    80002980:	653c                	ld	a5,72(a0)
    80002982:	0737f763          	bleu	s3,a5,800029f0 <usertrap+0xe0>
      p->killed = 1;
    80002986:	4785                	li	a5,1
    80002988:	02fa2823          	sw	a5,48(s4)
    8000298c:	a815                	j	800029c0 <usertrap+0xb0>
    panic("usertrap: not from user mode");
    8000298e:	00006517          	auipc	a0,0x6
    80002992:	92a50513          	addi	a0,a0,-1750 # 800082b8 <states.1759+0x130>
    80002996:	ffffe097          	auipc	ra,0xffffe
    8000299a:	bc2080e7          	jalr	-1086(ra) # 80000558 <panic>
    if(p->killed)
    8000299e:	591c                	lw	a5,48(a0)
    800029a0:	e3b1                	bnez	a5,800029e4 <usertrap+0xd4>
    p->trapframe->epc += 4;
    800029a2:	05893703          	ld	a4,88(s2)
    800029a6:	6f1c                	ld	a5,24(a4)
    800029a8:	0791                	addi	a5,a5,4
    800029aa:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ac:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800029b0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029b4:	10079073          	csrw	sstatus,a5
    syscall();
    800029b8:	00000097          	auipc	ra,0x0
    800029bc:	3e6080e7          	jalr	998(ra) # 80002d9e <syscall>
  if(p->killed)
    800029c0:	03092783          	lw	a5,48(s2)
    800029c4:	16079b63          	bnez	a5,80002b3a <usertrap+0x22a>
  usertrapret();
    800029c8:	00000097          	auipc	ra,0x0
    800029cc:	dc2080e7          	jalr	-574(ra) # 8000278a <usertrapret>
}
    800029d0:	70e2                	ld	ra,56(sp)
    800029d2:	7442                	ld	s0,48(sp)
    800029d4:	74a2                	ld	s1,40(sp)
    800029d6:	7902                	ld	s2,32(sp)
    800029d8:	69e2                	ld	s3,24(sp)
    800029da:	6a42                	ld	s4,16(sp)
    800029dc:	6aa2                	ld	s5,8(sp)
    800029de:	6b02                	ld	s6,0(sp)
    800029e0:	6121                	addi	sp,sp,64
    800029e2:	8082                	ret
      exit(-1);
    800029e4:	557d                	li	a0,-1
    800029e6:	fffff097          	auipc	ra,0xfffff
    800029ea:	790080e7          	jalr	1936(ra) # 80002176 <exit>
    800029ee:	bf55                	j	800029a2 <usertrap+0x92>
    800029f0:	16850793          	addi	a5,a0,360
      for (int i = 0; i < NVMA; i++) {
    800029f4:	4481                	li	s1,0
    800029f6:	4641                	li	a2,16
    800029f8:	a00d                	j	80002a1a <usertrap+0x10a>
            iunlock(vma->f->ip);
    800029fa:	1909b783          	ld	a5,400(s3)
    800029fe:	6f88                	ld	a0,24(a5)
    80002a00:	00001097          	auipc	ra,0x1
    80002a04:	fae080e7          	jalr	-82(ra) # 800039ae <iunlock>
        p->killed = 1;
    80002a08:	4785                	li	a5,1
    80002a0a:	02fa2823          	sw	a5,48(s4)
    80002a0e:	bf4d                	j	800029c0 <usertrap+0xb0>
      for (int i = 0; i < NVMA; i++) {
    80002a10:	2485                	addiw	s1,s1,1
    80002a12:	03078793          	addi	a5,a5,48
    80002a16:	fec489e3          	beq	s1,a2,80002a08 <usertrap+0xf8>
        if (vma->valid && va >= vma->addr && va < vma->addr+vma->length) {
    80002a1a:	4398                	lw	a4,0(a5)
    80002a1c:	db75                	beqz	a4,80002a10 <usertrap+0x100>
    80002a1e:	6798                	ld	a4,8(a5)
    80002a20:	fee9e8e3          	bltu	s3,a4,80002a10 <usertrap+0x100>
    80002a24:	4b94                	lw	a3,16(a5)
    80002a26:	9736                	add	a4,a4,a3
    80002a28:	fee9f4e3          	bleu	a4,s3,80002a10 <usertrap+0x100>
          uint64 pa = (uint64)kalloc();
    80002a2c:	ffffe097          	auipc	ra,0xffffe
    80002a30:	108080e7          	jalr	264(ra) # 80000b34 <kalloc>
    80002a34:	8aaa                	mv	s5,a0
          if (pa == 0) {
    80002a36:	d969                	beqz	a0,80002a08 <usertrap+0xf8>
          va = PGROUNDDOWN(va);
    80002a38:	7b7d                	lui	s6,0xfffff
    80002a3a:	0169fb33          	and	s6,s3,s6
          memset((void *)pa, 0, PGSIZE);
    80002a3e:	6605                	lui	a2,0x1
    80002a40:	4581                	li	a1,0
    80002a42:	ffffe097          	auipc	ra,0xffffe
    80002a46:	2de080e7          	jalr	734(ra) # 80000d20 <memset>
          ilock(vma->f->ip);
    80002a4a:	00149993          	slli	s3,s1,0x1
    80002a4e:	99a6                	add	s3,s3,s1
    80002a50:	0992                	slli	s3,s3,0x4
    80002a52:	99d2                	add	s3,s3,s4
    80002a54:	1909b783          	ld	a5,400(s3)
    80002a58:	6f88                	ld	a0,24(a5)
    80002a5a:	00001097          	auipc	ra,0x1
    80002a5e:	e90080e7          	jalr	-368(ra) # 800038ea <ilock>
          if(readi(vma->f->ip, 0, pa, vma->offset + va - vma->addr, PGSIZE) < 0) {
    80002a62:	1889a783          	lw	a5,392(s3)
    80002a66:	016787bb          	addw	a5,a5,s6
    80002a6a:	1709b683          	ld	a3,368(s3)
    80002a6e:	1909b503          	ld	a0,400(s3)
    80002a72:	6705                	lui	a4,0x1
    80002a74:	40d786bb          	subw	a3,a5,a3
    80002a78:	8656                	mv	a2,s5
    80002a7a:	4581                	li	a1,0
    80002a7c:	6d08                	ld	a0,24(a0)
    80002a7e:	00001097          	auipc	ra,0x1
    80002a82:	122080e7          	jalr	290(ra) # 80003ba0 <readi>
    80002a86:	f6054ae3          	bltz	a0,800029fa <usertrap+0xea>
          iunlock(vma->f->ip);
    80002a8a:	00149993          	slli	s3,s1,0x1
    80002a8e:	009987b3          	add	a5,s3,s1
    80002a92:	0792                	slli	a5,a5,0x4
    80002a94:	97d2                	add	a5,a5,s4
    80002a96:	1907b783          	ld	a5,400(a5)
    80002a9a:	6f88                	ld	a0,24(a5)
    80002a9c:	00001097          	auipc	ra,0x1
    80002aa0:	f12080e7          	jalr	-238(ra) # 800039ae <iunlock>
          if (vma->prot & PROT_READ)
    80002aa4:	009987b3          	add	a5,s3,s1
    80002aa8:	0792                	slli	a5,a5,0x4
    80002aaa:	97d2                	add	a5,a5,s4
    80002aac:	17c7a783          	lw	a5,380(a5)
    80002ab0:	0017f693          	andi	a3,a5,1
          int perm = PTE_U;
    80002ab4:	4741                	li	a4,16
          if (vma->prot & PROT_READ)
    80002ab6:	c291                	beqz	a3,80002aba <usertrap+0x1aa>
            perm |= PTE_R;
    80002ab8:	4749                	li	a4,18
          if (vma->prot & PROT_WRITE)
    80002aba:	0027f693          	andi	a3,a5,2
    80002abe:	c299                	beqz	a3,80002ac4 <usertrap+0x1b4>
            perm |= PTE_W;
    80002ac0:	00476713          	ori	a4,a4,4
          if (vma->prot & PROT_EXEC)
    80002ac4:	8b91                	andi	a5,a5,4
    80002ac6:	c399                	beqz	a5,80002acc <usertrap+0x1bc>
            perm |= PTE_X;
    80002ac8:	00876713          	ori	a4,a4,8
          if (mappages(p->pagetable, va, PGSIZE, pa, perm) < 0) {
    80002acc:	86d6                	mv	a3,s5
    80002ace:	6605                	lui	a2,0x1
    80002ad0:	85da                	mv	a1,s6
    80002ad2:	050a3503          	ld	a0,80(s4)
    80002ad6:	ffffe097          	auipc	ra,0xffffe
    80002ada:	642080e7          	jalr	1602(ra) # 80001118 <mappages>
    80002ade:	ee0551e3          	bgez	a0,800029c0 <usertrap+0xb0>
            kfree((void*)pa);
    80002ae2:	8556                	mv	a0,s5
    80002ae4:	ffffe097          	auipc	ra,0xffffe
    80002ae8:	f50080e7          	jalr	-176(ra) # 80000a34 <kfree>
      if (!found)
    80002aec:	bf31                	j	80002a08 <usertrap+0xf8>
  } else if((which_dev = devintr()) != 0){
    80002aee:	00000097          	auipc	ra,0x0
    80002af2:	d80080e7          	jalr	-640(ra) # 8000286e <devintr>
    80002af6:	84aa                	mv	s1,a0
    80002af8:	c509                	beqz	a0,80002b02 <usertrap+0x1f2>
  if(p->killed)
    80002afa:	03092783          	lw	a5,48(s2)
    80002afe:	c7a1                	beqz	a5,80002b46 <usertrap+0x236>
    80002b00:	a835                	j	80002b3c <usertrap+0x22c>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b02:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b06:	03892603          	lw	a2,56(s2)
    80002b0a:	00005517          	auipc	a0,0x5
    80002b0e:	7ce50513          	addi	a0,a0,1998 # 800082d8 <states.1759+0x150>
    80002b12:	ffffe097          	auipc	ra,0xffffe
    80002b16:	a90080e7          	jalr	-1392(ra) # 800005a2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b1a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b1e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b22:	00005517          	auipc	a0,0x5
    80002b26:	7e650513          	addi	a0,a0,2022 # 80008308 <states.1759+0x180>
    80002b2a:	ffffe097          	auipc	ra,0xffffe
    80002b2e:	a78080e7          	jalr	-1416(ra) # 800005a2 <printf>
    p->killed = 1;
    80002b32:	4785                	li	a5,1
    80002b34:	02f92823          	sw	a5,48(s2)
  if(p->killed)
    80002b38:	a011                	j	80002b3c <usertrap+0x22c>
    80002b3a:	4481                	li	s1,0
    exit(-1);
    80002b3c:	557d                	li	a0,-1
    80002b3e:	fffff097          	auipc	ra,0xfffff
    80002b42:	638080e7          	jalr	1592(ra) # 80002176 <exit>
  if(which_dev == 2)
    80002b46:	4789                	li	a5,2
    80002b48:	e8f490e3          	bne	s1,a5,800029c8 <usertrap+0xb8>
    yield();
    80002b4c:	fffff097          	auipc	ra,0xfffff
    80002b50:	79a080e7          	jalr	1946(ra) # 800022e6 <yield>
    80002b54:	bd95                	j	800029c8 <usertrap+0xb8>

0000000080002b56 <kerneltrap>:
{
    80002b56:	7179                	addi	sp,sp,-48
    80002b58:	f406                	sd	ra,40(sp)
    80002b5a:	f022                	sd	s0,32(sp)
    80002b5c:	ec26                	sd	s1,24(sp)
    80002b5e:	e84a                	sd	s2,16(sp)
    80002b60:	e44e                	sd	s3,8(sp)
    80002b62:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b64:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b68:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b6c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b70:	1004f793          	andi	a5,s1,256
    80002b74:	cb85                	beqz	a5,80002ba4 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b76:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b7a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b7c:	ef85                	bnez	a5,80002bb4 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002b7e:	00000097          	auipc	ra,0x0
    80002b82:	cf0080e7          	jalr	-784(ra) # 8000286e <devintr>
    80002b86:	cd1d                	beqz	a0,80002bc4 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b88:	4789                	li	a5,2
    80002b8a:	06f50a63          	beq	a0,a5,80002bfe <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b8e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b92:	10049073          	csrw	sstatus,s1
}
    80002b96:	70a2                	ld	ra,40(sp)
    80002b98:	7402                	ld	s0,32(sp)
    80002b9a:	64e2                	ld	s1,24(sp)
    80002b9c:	6942                	ld	s2,16(sp)
    80002b9e:	69a2                	ld	s3,8(sp)
    80002ba0:	6145                	addi	sp,sp,48
    80002ba2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ba4:	00005517          	auipc	a0,0x5
    80002ba8:	78450513          	addi	a0,a0,1924 # 80008328 <states.1759+0x1a0>
    80002bac:	ffffe097          	auipc	ra,0xffffe
    80002bb0:	9ac080e7          	jalr	-1620(ra) # 80000558 <panic>
    panic("kerneltrap: interrupts enabled");
    80002bb4:	00005517          	auipc	a0,0x5
    80002bb8:	79c50513          	addi	a0,a0,1948 # 80008350 <states.1759+0x1c8>
    80002bbc:	ffffe097          	auipc	ra,0xffffe
    80002bc0:	99c080e7          	jalr	-1636(ra) # 80000558 <panic>
    printf("scause %p\n", scause);
    80002bc4:	85ce                	mv	a1,s3
    80002bc6:	00005517          	auipc	a0,0x5
    80002bca:	7aa50513          	addi	a0,a0,1962 # 80008370 <states.1759+0x1e8>
    80002bce:	ffffe097          	auipc	ra,0xffffe
    80002bd2:	9d4080e7          	jalr	-1580(ra) # 800005a2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bd6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bda:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bde:	00005517          	auipc	a0,0x5
    80002be2:	7a250513          	addi	a0,a0,1954 # 80008380 <states.1759+0x1f8>
    80002be6:	ffffe097          	auipc	ra,0xffffe
    80002bea:	9bc080e7          	jalr	-1604(ra) # 800005a2 <printf>
    panic("kerneltrap");
    80002bee:	00005517          	auipc	a0,0x5
    80002bf2:	7aa50513          	addi	a0,a0,1962 # 80008398 <states.1759+0x210>
    80002bf6:	ffffe097          	auipc	ra,0xffffe
    80002bfa:	962080e7          	jalr	-1694(ra) # 80000558 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bfe:	fffff097          	auipc	ra,0xfffff
    80002c02:	e2e080e7          	jalr	-466(ra) # 80001a2c <myproc>
    80002c06:	d541                	beqz	a0,80002b8e <kerneltrap+0x38>
    80002c08:	fffff097          	auipc	ra,0xfffff
    80002c0c:	e24080e7          	jalr	-476(ra) # 80001a2c <myproc>
    80002c10:	4d18                	lw	a4,24(a0)
    80002c12:	478d                	li	a5,3
    80002c14:	f6f71de3          	bne	a4,a5,80002b8e <kerneltrap+0x38>
    yield();
    80002c18:	fffff097          	auipc	ra,0xfffff
    80002c1c:	6ce080e7          	jalr	1742(ra) # 800022e6 <yield>
    80002c20:	b7bd                	j	80002b8e <kerneltrap+0x38>

0000000080002c22 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c22:	1101                	addi	sp,sp,-32
    80002c24:	ec06                	sd	ra,24(sp)
    80002c26:	e822                	sd	s0,16(sp)
    80002c28:	e426                	sd	s1,8(sp)
    80002c2a:	1000                	addi	s0,sp,32
    80002c2c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c2e:	fffff097          	auipc	ra,0xfffff
    80002c32:	dfe080e7          	jalr	-514(ra) # 80001a2c <myproc>
  switch (n) {
    80002c36:	4795                	li	a5,5
    80002c38:	0497e363          	bltu	a5,s1,80002c7e <argraw+0x5c>
    80002c3c:	1482                	slli	s1,s1,0x20
    80002c3e:	9081                	srli	s1,s1,0x20
    80002c40:	048a                	slli	s1,s1,0x2
    80002c42:	00005717          	auipc	a4,0x5
    80002c46:	76670713          	addi	a4,a4,1894 # 800083a8 <states.1759+0x220>
    80002c4a:	94ba                	add	s1,s1,a4
    80002c4c:	409c                	lw	a5,0(s1)
    80002c4e:	97ba                	add	a5,a5,a4
    80002c50:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c52:	6d3c                	ld	a5,88(a0)
    80002c54:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c56:	60e2                	ld	ra,24(sp)
    80002c58:	6442                	ld	s0,16(sp)
    80002c5a:	64a2                	ld	s1,8(sp)
    80002c5c:	6105                	addi	sp,sp,32
    80002c5e:	8082                	ret
    return p->trapframe->a1;
    80002c60:	6d3c                	ld	a5,88(a0)
    80002c62:	7fa8                	ld	a0,120(a5)
    80002c64:	bfcd                	j	80002c56 <argraw+0x34>
    return p->trapframe->a2;
    80002c66:	6d3c                	ld	a5,88(a0)
    80002c68:	63c8                	ld	a0,128(a5)
    80002c6a:	b7f5                	j	80002c56 <argraw+0x34>
    return p->trapframe->a3;
    80002c6c:	6d3c                	ld	a5,88(a0)
    80002c6e:	67c8                	ld	a0,136(a5)
    80002c70:	b7dd                	j	80002c56 <argraw+0x34>
    return p->trapframe->a4;
    80002c72:	6d3c                	ld	a5,88(a0)
    80002c74:	6bc8                	ld	a0,144(a5)
    80002c76:	b7c5                	j	80002c56 <argraw+0x34>
    return p->trapframe->a5;
    80002c78:	6d3c                	ld	a5,88(a0)
    80002c7a:	6fc8                	ld	a0,152(a5)
    80002c7c:	bfe9                	j	80002c56 <argraw+0x34>
  panic("argraw");
    80002c7e:	00006517          	auipc	a0,0x6
    80002c82:	80250513          	addi	a0,a0,-2046 # 80008480 <syscalls+0xc0>
    80002c86:	ffffe097          	auipc	ra,0xffffe
    80002c8a:	8d2080e7          	jalr	-1838(ra) # 80000558 <panic>

0000000080002c8e <fetchaddr>:
{
    80002c8e:	1101                	addi	sp,sp,-32
    80002c90:	ec06                	sd	ra,24(sp)
    80002c92:	e822                	sd	s0,16(sp)
    80002c94:	e426                	sd	s1,8(sp)
    80002c96:	e04a                	sd	s2,0(sp)
    80002c98:	1000                	addi	s0,sp,32
    80002c9a:	84aa                	mv	s1,a0
    80002c9c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c9e:	fffff097          	auipc	ra,0xfffff
    80002ca2:	d8e080e7          	jalr	-626(ra) # 80001a2c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002ca6:	653c                	ld	a5,72(a0)
    80002ca8:	02f4f963          	bleu	a5,s1,80002cda <fetchaddr+0x4c>
    80002cac:	00848713          	addi	a4,s1,8
    80002cb0:	02e7e763          	bltu	a5,a4,80002cde <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cb4:	46a1                	li	a3,8
    80002cb6:	8626                	mv	a2,s1
    80002cb8:	85ca                	mv	a1,s2
    80002cba:	6928                	ld	a0,80(a0)
    80002cbc:	fffff097          	auipc	ra,0xfffff
    80002cc0:	a7a080e7          	jalr	-1414(ra) # 80001736 <copyin>
    80002cc4:	00a03533          	snez	a0,a0
    80002cc8:	40a0053b          	negw	a0,a0
    80002ccc:	2501                	sext.w	a0,a0
}
    80002cce:	60e2                	ld	ra,24(sp)
    80002cd0:	6442                	ld	s0,16(sp)
    80002cd2:	64a2                	ld	s1,8(sp)
    80002cd4:	6902                	ld	s2,0(sp)
    80002cd6:	6105                	addi	sp,sp,32
    80002cd8:	8082                	ret
    return -1;
    80002cda:	557d                	li	a0,-1
    80002cdc:	bfcd                	j	80002cce <fetchaddr+0x40>
    80002cde:	557d                	li	a0,-1
    80002ce0:	b7fd                	j	80002cce <fetchaddr+0x40>

0000000080002ce2 <fetchstr>:
{
    80002ce2:	7179                	addi	sp,sp,-48
    80002ce4:	f406                	sd	ra,40(sp)
    80002ce6:	f022                	sd	s0,32(sp)
    80002ce8:	ec26                	sd	s1,24(sp)
    80002cea:	e84a                	sd	s2,16(sp)
    80002cec:	e44e                	sd	s3,8(sp)
    80002cee:	1800                	addi	s0,sp,48
    80002cf0:	892a                	mv	s2,a0
    80002cf2:	84ae                	mv	s1,a1
    80002cf4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002cf6:	fffff097          	auipc	ra,0xfffff
    80002cfa:	d36080e7          	jalr	-714(ra) # 80001a2c <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002cfe:	86ce                	mv	a3,s3
    80002d00:	864a                	mv	a2,s2
    80002d02:	85a6                	mv	a1,s1
    80002d04:	6928                	ld	a0,80(a0)
    80002d06:	fffff097          	auipc	ra,0xfffff
    80002d0a:	abe080e7          	jalr	-1346(ra) # 800017c4 <copyinstr>
  if(err < 0)
    80002d0e:	00054763          	bltz	a0,80002d1c <fetchstr+0x3a>
  return strlen(buf);
    80002d12:	8526                	mv	a0,s1
    80002d14:	ffffe097          	auipc	ra,0xffffe
    80002d18:	1b6080e7          	jalr	438(ra) # 80000eca <strlen>
}
    80002d1c:	70a2                	ld	ra,40(sp)
    80002d1e:	7402                	ld	s0,32(sp)
    80002d20:	64e2                	ld	s1,24(sp)
    80002d22:	6942                	ld	s2,16(sp)
    80002d24:	69a2                	ld	s3,8(sp)
    80002d26:	6145                	addi	sp,sp,48
    80002d28:	8082                	ret

0000000080002d2a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002d2a:	1101                	addi	sp,sp,-32
    80002d2c:	ec06                	sd	ra,24(sp)
    80002d2e:	e822                	sd	s0,16(sp)
    80002d30:	e426                	sd	s1,8(sp)
    80002d32:	1000                	addi	s0,sp,32
    80002d34:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d36:	00000097          	auipc	ra,0x0
    80002d3a:	eec080e7          	jalr	-276(ra) # 80002c22 <argraw>
    80002d3e:	c088                	sw	a0,0(s1)
  return 0;
}
    80002d40:	4501                	li	a0,0
    80002d42:	60e2                	ld	ra,24(sp)
    80002d44:	6442                	ld	s0,16(sp)
    80002d46:	64a2                	ld	s1,8(sp)
    80002d48:	6105                	addi	sp,sp,32
    80002d4a:	8082                	ret

0000000080002d4c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002d4c:	1101                	addi	sp,sp,-32
    80002d4e:	ec06                	sd	ra,24(sp)
    80002d50:	e822                	sd	s0,16(sp)
    80002d52:	e426                	sd	s1,8(sp)
    80002d54:	1000                	addi	s0,sp,32
    80002d56:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d58:	00000097          	auipc	ra,0x0
    80002d5c:	eca080e7          	jalr	-310(ra) # 80002c22 <argraw>
    80002d60:	e088                	sd	a0,0(s1)
  return 0;
}
    80002d62:	4501                	li	a0,0
    80002d64:	60e2                	ld	ra,24(sp)
    80002d66:	6442                	ld	s0,16(sp)
    80002d68:	64a2                	ld	s1,8(sp)
    80002d6a:	6105                	addi	sp,sp,32
    80002d6c:	8082                	ret

0000000080002d6e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d6e:	1101                	addi	sp,sp,-32
    80002d70:	ec06                	sd	ra,24(sp)
    80002d72:	e822                	sd	s0,16(sp)
    80002d74:	e426                	sd	s1,8(sp)
    80002d76:	e04a                	sd	s2,0(sp)
    80002d78:	1000                	addi	s0,sp,32
    80002d7a:	84ae                	mv	s1,a1
    80002d7c:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002d7e:	00000097          	auipc	ra,0x0
    80002d82:	ea4080e7          	jalr	-348(ra) # 80002c22 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002d86:	864a                	mv	a2,s2
    80002d88:	85a6                	mv	a1,s1
    80002d8a:	00000097          	auipc	ra,0x0
    80002d8e:	f58080e7          	jalr	-168(ra) # 80002ce2 <fetchstr>
}
    80002d92:	60e2                	ld	ra,24(sp)
    80002d94:	6442                	ld	s0,16(sp)
    80002d96:	64a2                	ld	s1,8(sp)
    80002d98:	6902                	ld	s2,0(sp)
    80002d9a:	6105                	addi	sp,sp,32
    80002d9c:	8082                	ret

0000000080002d9e <syscall>:
[SYS_munmap]  sys_munmap,
};

void
syscall(void)
{
    80002d9e:	1101                	addi	sp,sp,-32
    80002da0:	ec06                	sd	ra,24(sp)
    80002da2:	e822                	sd	s0,16(sp)
    80002da4:	e426                	sd	s1,8(sp)
    80002da6:	e04a                	sd	s2,0(sp)
    80002da8:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002daa:	fffff097          	auipc	ra,0xfffff
    80002dae:	c82080e7          	jalr	-894(ra) # 80001a2c <myproc>
    80002db2:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002db4:	05853903          	ld	s2,88(a0)
    80002db8:	0a893783          	ld	a5,168(s2)
    80002dbc:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002dc0:	37fd                	addiw	a5,a5,-1
    80002dc2:	4759                	li	a4,22
    80002dc4:	00f76f63          	bltu	a4,a5,80002de2 <syscall+0x44>
    80002dc8:	00369713          	slli	a4,a3,0x3
    80002dcc:	00005797          	auipc	a5,0x5
    80002dd0:	5f478793          	addi	a5,a5,1524 # 800083c0 <syscalls>
    80002dd4:	97ba                	add	a5,a5,a4
    80002dd6:	639c                	ld	a5,0(a5)
    80002dd8:	c789                	beqz	a5,80002de2 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002dda:	9782                	jalr	a5
    80002ddc:	06a93823          	sd	a0,112(s2)
    80002de0:	a839                	j	80002dfe <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002de2:	15848613          	addi	a2,s1,344
    80002de6:	5c8c                	lw	a1,56(s1)
    80002de8:	00005517          	auipc	a0,0x5
    80002dec:	6a050513          	addi	a0,a0,1696 # 80008488 <syscalls+0xc8>
    80002df0:	ffffd097          	auipc	ra,0xffffd
    80002df4:	7b2080e7          	jalr	1970(ra) # 800005a2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002df8:	6cbc                	ld	a5,88(s1)
    80002dfa:	577d                	li	a4,-1
    80002dfc:	fbb8                	sd	a4,112(a5)
  }
}
    80002dfe:	60e2                	ld	ra,24(sp)
    80002e00:	6442                	ld	s0,16(sp)
    80002e02:	64a2                	ld	s1,8(sp)
    80002e04:	6902                	ld	s2,0(sp)
    80002e06:	6105                	addi	sp,sp,32
    80002e08:	8082                	ret

0000000080002e0a <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e0a:	1101                	addi	sp,sp,-32
    80002e0c:	ec06                	sd	ra,24(sp)
    80002e0e:	e822                	sd	s0,16(sp)
    80002e10:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002e12:	fec40593          	addi	a1,s0,-20
    80002e16:	4501                	li	a0,0
    80002e18:	00000097          	auipc	ra,0x0
    80002e1c:	f12080e7          	jalr	-238(ra) # 80002d2a <argint>
    return -1;
    80002e20:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e22:	00054963          	bltz	a0,80002e34 <sys_exit+0x2a>
  exit(n);
    80002e26:	fec42503          	lw	a0,-20(s0)
    80002e2a:	fffff097          	auipc	ra,0xfffff
    80002e2e:	34c080e7          	jalr	844(ra) # 80002176 <exit>
  return 0;  // not reached
    80002e32:	4781                	li	a5,0
}
    80002e34:	853e                	mv	a0,a5
    80002e36:	60e2                	ld	ra,24(sp)
    80002e38:	6442                	ld	s0,16(sp)
    80002e3a:	6105                	addi	sp,sp,32
    80002e3c:	8082                	ret

0000000080002e3e <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e3e:	1141                	addi	sp,sp,-16
    80002e40:	e406                	sd	ra,8(sp)
    80002e42:	e022                	sd	s0,0(sp)
    80002e44:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e46:	fffff097          	auipc	ra,0xfffff
    80002e4a:	be6080e7          	jalr	-1050(ra) # 80001a2c <myproc>
}
    80002e4e:	5d08                	lw	a0,56(a0)
    80002e50:	60a2                	ld	ra,8(sp)
    80002e52:	6402                	ld	s0,0(sp)
    80002e54:	0141                	addi	sp,sp,16
    80002e56:	8082                	ret

0000000080002e58 <sys_fork>:

uint64
sys_fork(void)
{
    80002e58:	1141                	addi	sp,sp,-16
    80002e5a:	e406                	sd	ra,8(sp)
    80002e5c:	e022                	sd	s0,0(sp)
    80002e5e:	0800                	addi	s0,sp,16
  return fork();
    80002e60:	fffff097          	auipc	ra,0xfffff
    80002e64:	fc6080e7          	jalr	-58(ra) # 80001e26 <fork>
}
    80002e68:	60a2                	ld	ra,8(sp)
    80002e6a:	6402                	ld	s0,0(sp)
    80002e6c:	0141                	addi	sp,sp,16
    80002e6e:	8082                	ret

0000000080002e70 <sys_wait>:

uint64
sys_wait(void)
{
    80002e70:	1101                	addi	sp,sp,-32
    80002e72:	ec06                	sd	ra,24(sp)
    80002e74:	e822                	sd	s0,16(sp)
    80002e76:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002e78:	fe840593          	addi	a1,s0,-24
    80002e7c:	4501                	li	a0,0
    80002e7e:	00000097          	auipc	ra,0x0
    80002e82:	ece080e7          	jalr	-306(ra) # 80002d4c <argaddr>
    return -1;
    80002e86:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    80002e88:	00054963          	bltz	a0,80002e9a <sys_wait+0x2a>
  return wait(p);
    80002e8c:	fe843503          	ld	a0,-24(s0)
    80002e90:	fffff097          	auipc	ra,0xfffff
    80002e94:	510080e7          	jalr	1296(ra) # 800023a0 <wait>
    80002e98:	87aa                	mv	a5,a0
}
    80002e9a:	853e                	mv	a0,a5
    80002e9c:	60e2                	ld	ra,24(sp)
    80002e9e:	6442                	ld	s0,16(sp)
    80002ea0:	6105                	addi	sp,sp,32
    80002ea2:	8082                	ret

0000000080002ea4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ea4:	7179                	addi	sp,sp,-48
    80002ea6:	f406                	sd	ra,40(sp)
    80002ea8:	f022                	sd	s0,32(sp)
    80002eaa:	ec26                	sd	s1,24(sp)
    80002eac:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002eae:	fdc40593          	addi	a1,s0,-36
    80002eb2:	4501                	li	a0,0
    80002eb4:	00000097          	auipc	ra,0x0
    80002eb8:	e76080e7          	jalr	-394(ra) # 80002d2a <argint>
    return -1;
    80002ebc:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002ebe:	00054f63          	bltz	a0,80002edc <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002ec2:	fffff097          	auipc	ra,0xfffff
    80002ec6:	b6a080e7          	jalr	-1174(ra) # 80001a2c <myproc>
    80002eca:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002ecc:	fdc42503          	lw	a0,-36(s0)
    80002ed0:	fffff097          	auipc	ra,0xfffff
    80002ed4:	ede080e7          	jalr	-290(ra) # 80001dae <growproc>
    80002ed8:	00054863          	bltz	a0,80002ee8 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002edc:	8526                	mv	a0,s1
    80002ede:	70a2                	ld	ra,40(sp)
    80002ee0:	7402                	ld	s0,32(sp)
    80002ee2:	64e2                	ld	s1,24(sp)
    80002ee4:	6145                	addi	sp,sp,48
    80002ee6:	8082                	ret
    return -1;
    80002ee8:	54fd                	li	s1,-1
    80002eea:	bfcd                	j	80002edc <sys_sbrk+0x38>

0000000080002eec <sys_sleep>:

uint64
sys_sleep(void)
{
    80002eec:	7139                	addi	sp,sp,-64
    80002eee:	fc06                	sd	ra,56(sp)
    80002ef0:	f822                	sd	s0,48(sp)
    80002ef2:	f426                	sd	s1,40(sp)
    80002ef4:	f04a                	sd	s2,32(sp)
    80002ef6:	ec4e                	sd	s3,24(sp)
    80002ef8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002efa:	fcc40593          	addi	a1,s0,-52
    80002efe:	4501                	li	a0,0
    80002f00:	00000097          	auipc	ra,0x0
    80002f04:	e2a080e7          	jalr	-470(ra) # 80002d2a <argint>
    return -1;
    80002f08:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f0a:	06054763          	bltz	a0,80002f78 <sys_sleep+0x8c>
  acquire(&tickslock);
    80002f0e:	00020517          	auipc	a0,0x20
    80002f12:	1aa50513          	addi	a0,a0,426 # 800230b8 <tickslock>
    80002f16:	ffffe097          	auipc	ra,0xffffe
    80002f1a:	d0e080e7          	jalr	-754(ra) # 80000c24 <acquire>
  ticks0 = ticks;
    80002f1e:	00006797          	auipc	a5,0x6
    80002f22:	11278793          	addi	a5,a5,274 # 80009030 <ticks>
    80002f26:	0007a903          	lw	s2,0(a5)
  while(ticks - ticks0 < n){
    80002f2a:	fcc42783          	lw	a5,-52(s0)
    80002f2e:	cf85                	beqz	a5,80002f66 <sys_sleep+0x7a>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f30:	00020997          	auipc	s3,0x20
    80002f34:	18898993          	addi	s3,s3,392 # 800230b8 <tickslock>
    80002f38:	00006497          	auipc	s1,0x6
    80002f3c:	0f848493          	addi	s1,s1,248 # 80009030 <ticks>
    if(myproc()->killed){
    80002f40:	fffff097          	auipc	ra,0xfffff
    80002f44:	aec080e7          	jalr	-1300(ra) # 80001a2c <myproc>
    80002f48:	591c                	lw	a5,48(a0)
    80002f4a:	ef9d                	bnez	a5,80002f88 <sys_sleep+0x9c>
    sleep(&ticks, &tickslock);
    80002f4c:	85ce                	mv	a1,s3
    80002f4e:	8526                	mv	a0,s1
    80002f50:	fffff097          	auipc	ra,0xfffff
    80002f54:	3d2080e7          	jalr	978(ra) # 80002322 <sleep>
  while(ticks - ticks0 < n){
    80002f58:	409c                	lw	a5,0(s1)
    80002f5a:	412787bb          	subw	a5,a5,s2
    80002f5e:	fcc42703          	lw	a4,-52(s0)
    80002f62:	fce7efe3          	bltu	a5,a4,80002f40 <sys_sleep+0x54>
  }
  release(&tickslock);
    80002f66:	00020517          	auipc	a0,0x20
    80002f6a:	15250513          	addi	a0,a0,338 # 800230b8 <tickslock>
    80002f6e:	ffffe097          	auipc	ra,0xffffe
    80002f72:	d6a080e7          	jalr	-662(ra) # 80000cd8 <release>
  return 0;
    80002f76:	4781                	li	a5,0
}
    80002f78:	853e                	mv	a0,a5
    80002f7a:	70e2                	ld	ra,56(sp)
    80002f7c:	7442                	ld	s0,48(sp)
    80002f7e:	74a2                	ld	s1,40(sp)
    80002f80:	7902                	ld	s2,32(sp)
    80002f82:	69e2                	ld	s3,24(sp)
    80002f84:	6121                	addi	sp,sp,64
    80002f86:	8082                	ret
      release(&tickslock);
    80002f88:	00020517          	auipc	a0,0x20
    80002f8c:	13050513          	addi	a0,a0,304 # 800230b8 <tickslock>
    80002f90:	ffffe097          	auipc	ra,0xffffe
    80002f94:	d48080e7          	jalr	-696(ra) # 80000cd8 <release>
      return -1;
    80002f98:	57fd                	li	a5,-1
    80002f9a:	bff9                	j	80002f78 <sys_sleep+0x8c>

0000000080002f9c <sys_kill>:

uint64
sys_kill(void)
{
    80002f9c:	1101                	addi	sp,sp,-32
    80002f9e:	ec06                	sd	ra,24(sp)
    80002fa0:	e822                	sd	s0,16(sp)
    80002fa2:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002fa4:	fec40593          	addi	a1,s0,-20
    80002fa8:	4501                	li	a0,0
    80002faa:	00000097          	auipc	ra,0x0
    80002fae:	d80080e7          	jalr	-640(ra) # 80002d2a <argint>
    return -1;
    80002fb2:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    80002fb4:	00054963          	bltz	a0,80002fc6 <sys_kill+0x2a>
  return kill(pid);
    80002fb8:	fec42503          	lw	a0,-20(s0)
    80002fbc:	fffff097          	auipc	ra,0xfffff
    80002fc0:	556080e7          	jalr	1366(ra) # 80002512 <kill>
    80002fc4:	87aa                	mv	a5,a0
}
    80002fc6:	853e                	mv	a0,a5
    80002fc8:	60e2                	ld	ra,24(sp)
    80002fca:	6442                	ld	s0,16(sp)
    80002fcc:	6105                	addi	sp,sp,32
    80002fce:	8082                	ret

0000000080002fd0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002fd0:	1101                	addi	sp,sp,-32
    80002fd2:	ec06                	sd	ra,24(sp)
    80002fd4:	e822                	sd	s0,16(sp)
    80002fd6:	e426                	sd	s1,8(sp)
    80002fd8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002fda:	00020517          	auipc	a0,0x20
    80002fde:	0de50513          	addi	a0,a0,222 # 800230b8 <tickslock>
    80002fe2:	ffffe097          	auipc	ra,0xffffe
    80002fe6:	c42080e7          	jalr	-958(ra) # 80000c24 <acquire>
  xticks = ticks;
    80002fea:	00006797          	auipc	a5,0x6
    80002fee:	04678793          	addi	a5,a5,70 # 80009030 <ticks>
    80002ff2:	4384                	lw	s1,0(a5)
  release(&tickslock);
    80002ff4:	00020517          	auipc	a0,0x20
    80002ff8:	0c450513          	addi	a0,a0,196 # 800230b8 <tickslock>
    80002ffc:	ffffe097          	auipc	ra,0xffffe
    80003000:	cdc080e7          	jalr	-804(ra) # 80000cd8 <release>
  return xticks;
}
    80003004:	02049513          	slli	a0,s1,0x20
    80003008:	9101                	srli	a0,a0,0x20
    8000300a:	60e2                	ld	ra,24(sp)
    8000300c:	6442                	ld	s0,16(sp)
    8000300e:	64a2                	ld	s1,8(sp)
    80003010:	6105                	addi	sp,sp,32
    80003012:	8082                	ret

0000000080003014 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003014:	7179                	addi	sp,sp,-48
    80003016:	f406                	sd	ra,40(sp)
    80003018:	f022                	sd	s0,32(sp)
    8000301a:	ec26                	sd	s1,24(sp)
    8000301c:	e84a                	sd	s2,16(sp)
    8000301e:	e44e                	sd	s3,8(sp)
    80003020:	e052                	sd	s4,0(sp)
    80003022:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003024:	00005597          	auipc	a1,0x5
    80003028:	48458593          	addi	a1,a1,1156 # 800084a8 <syscalls+0xe8>
    8000302c:	00020517          	auipc	a0,0x20
    80003030:	0a450513          	addi	a0,a0,164 # 800230d0 <bcache>
    80003034:	ffffe097          	auipc	ra,0xffffe
    80003038:	b60080e7          	jalr	-1184(ra) # 80000b94 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000303c:	00028797          	auipc	a5,0x28
    80003040:	09478793          	addi	a5,a5,148 # 8002b0d0 <bcache+0x8000>
    80003044:	00028717          	auipc	a4,0x28
    80003048:	2f470713          	addi	a4,a4,756 # 8002b338 <bcache+0x8268>
    8000304c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003050:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003054:	00020497          	auipc	s1,0x20
    80003058:	09448493          	addi	s1,s1,148 # 800230e8 <bcache+0x18>
    b->next = bcache.head.next;
    8000305c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000305e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003060:	00005a17          	auipc	s4,0x5
    80003064:	450a0a13          	addi	s4,s4,1104 # 800084b0 <syscalls+0xf0>
    b->next = bcache.head.next;
    80003068:	2b893783          	ld	a5,696(s2)
    8000306c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000306e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003072:	85d2                	mv	a1,s4
    80003074:	01048513          	addi	a0,s1,16
    80003078:	00001097          	auipc	ra,0x1
    8000307c:	532080e7          	jalr	1330(ra) # 800045aa <initsleeplock>
    bcache.head.next->prev = b;
    80003080:	2b893783          	ld	a5,696(s2)
    80003084:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003086:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000308a:	45848493          	addi	s1,s1,1112
    8000308e:	fd349de3          	bne	s1,s3,80003068 <binit+0x54>
  }
}
    80003092:	70a2                	ld	ra,40(sp)
    80003094:	7402                	ld	s0,32(sp)
    80003096:	64e2                	ld	s1,24(sp)
    80003098:	6942                	ld	s2,16(sp)
    8000309a:	69a2                	ld	s3,8(sp)
    8000309c:	6a02                	ld	s4,0(sp)
    8000309e:	6145                	addi	sp,sp,48
    800030a0:	8082                	ret

00000000800030a2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030a2:	7179                	addi	sp,sp,-48
    800030a4:	f406                	sd	ra,40(sp)
    800030a6:	f022                	sd	s0,32(sp)
    800030a8:	ec26                	sd	s1,24(sp)
    800030aa:	e84a                	sd	s2,16(sp)
    800030ac:	e44e                	sd	s3,8(sp)
    800030ae:	1800                	addi	s0,sp,48
    800030b0:	89aa                	mv	s3,a0
    800030b2:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800030b4:	00020517          	auipc	a0,0x20
    800030b8:	01c50513          	addi	a0,a0,28 # 800230d0 <bcache>
    800030bc:	ffffe097          	auipc	ra,0xffffe
    800030c0:	b68080e7          	jalr	-1176(ra) # 80000c24 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800030c4:	00028797          	auipc	a5,0x28
    800030c8:	00c78793          	addi	a5,a5,12 # 8002b0d0 <bcache+0x8000>
    800030cc:	2b87b483          	ld	s1,696(a5)
    800030d0:	00028797          	auipc	a5,0x28
    800030d4:	26878793          	addi	a5,a5,616 # 8002b338 <bcache+0x8268>
    800030d8:	02f48f63          	beq	s1,a5,80003116 <bread+0x74>
    800030dc:	873e                	mv	a4,a5
    800030de:	a021                	j	800030e6 <bread+0x44>
    800030e0:	68a4                	ld	s1,80(s1)
    800030e2:	02e48a63          	beq	s1,a4,80003116 <bread+0x74>
    if(b->dev == dev && b->blockno == blockno){
    800030e6:	449c                	lw	a5,8(s1)
    800030e8:	ff379ce3          	bne	a5,s3,800030e0 <bread+0x3e>
    800030ec:	44dc                	lw	a5,12(s1)
    800030ee:	ff2799e3          	bne	a5,s2,800030e0 <bread+0x3e>
      b->refcnt++;
    800030f2:	40bc                	lw	a5,64(s1)
    800030f4:	2785                	addiw	a5,a5,1
    800030f6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030f8:	00020517          	auipc	a0,0x20
    800030fc:	fd850513          	addi	a0,a0,-40 # 800230d0 <bcache>
    80003100:	ffffe097          	auipc	ra,0xffffe
    80003104:	bd8080e7          	jalr	-1064(ra) # 80000cd8 <release>
      acquiresleep(&b->lock);
    80003108:	01048513          	addi	a0,s1,16
    8000310c:	00001097          	auipc	ra,0x1
    80003110:	4d8080e7          	jalr	1240(ra) # 800045e4 <acquiresleep>
      return b;
    80003114:	a8b1                	j	80003170 <bread+0xce>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003116:	00028797          	auipc	a5,0x28
    8000311a:	fba78793          	addi	a5,a5,-70 # 8002b0d0 <bcache+0x8000>
    8000311e:	2b07b483          	ld	s1,688(a5)
    80003122:	00028797          	auipc	a5,0x28
    80003126:	21678793          	addi	a5,a5,534 # 8002b338 <bcache+0x8268>
    8000312a:	04f48d63          	beq	s1,a5,80003184 <bread+0xe2>
    if(b->refcnt == 0) {
    8000312e:	40bc                	lw	a5,64(s1)
    80003130:	cb91                	beqz	a5,80003144 <bread+0xa2>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003132:	00028717          	auipc	a4,0x28
    80003136:	20670713          	addi	a4,a4,518 # 8002b338 <bcache+0x8268>
    8000313a:	64a4                	ld	s1,72(s1)
    8000313c:	04e48463          	beq	s1,a4,80003184 <bread+0xe2>
    if(b->refcnt == 0) {
    80003140:	40bc                	lw	a5,64(s1)
    80003142:	ffe5                	bnez	a5,8000313a <bread+0x98>
      b->dev = dev;
    80003144:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003148:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    8000314c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003150:	4785                	li	a5,1
    80003152:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003154:	00020517          	auipc	a0,0x20
    80003158:	f7c50513          	addi	a0,a0,-132 # 800230d0 <bcache>
    8000315c:	ffffe097          	auipc	ra,0xffffe
    80003160:	b7c080e7          	jalr	-1156(ra) # 80000cd8 <release>
      acquiresleep(&b->lock);
    80003164:	01048513          	addi	a0,s1,16
    80003168:	00001097          	auipc	ra,0x1
    8000316c:	47c080e7          	jalr	1148(ra) # 800045e4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003170:	409c                	lw	a5,0(s1)
    80003172:	c38d                	beqz	a5,80003194 <bread+0xf2>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003174:	8526                	mv	a0,s1
    80003176:	70a2                	ld	ra,40(sp)
    80003178:	7402                	ld	s0,32(sp)
    8000317a:	64e2                	ld	s1,24(sp)
    8000317c:	6942                	ld	s2,16(sp)
    8000317e:	69a2                	ld	s3,8(sp)
    80003180:	6145                	addi	sp,sp,48
    80003182:	8082                	ret
  panic("bget: no buffers");
    80003184:	00005517          	auipc	a0,0x5
    80003188:	33450513          	addi	a0,a0,820 # 800084b8 <syscalls+0xf8>
    8000318c:	ffffd097          	auipc	ra,0xffffd
    80003190:	3cc080e7          	jalr	972(ra) # 80000558 <panic>
    virtio_disk_rw(b, 0);
    80003194:	4581                	li	a1,0
    80003196:	8526                	mv	a0,s1
    80003198:	00003097          	auipc	ra,0x3
    8000319c:	2fe080e7          	jalr	766(ra) # 80006496 <virtio_disk_rw>
    b->valid = 1;
    800031a0:	4785                	li	a5,1
    800031a2:	c09c                	sw	a5,0(s1)
  return b;
    800031a4:	bfc1                	j	80003174 <bread+0xd2>

00000000800031a6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031a6:	1101                	addi	sp,sp,-32
    800031a8:	ec06                	sd	ra,24(sp)
    800031aa:	e822                	sd	s0,16(sp)
    800031ac:	e426                	sd	s1,8(sp)
    800031ae:	1000                	addi	s0,sp,32
    800031b0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031b2:	0541                	addi	a0,a0,16
    800031b4:	00001097          	auipc	ra,0x1
    800031b8:	4ca080e7          	jalr	1226(ra) # 8000467e <holdingsleep>
    800031bc:	cd01                	beqz	a0,800031d4 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800031be:	4585                	li	a1,1
    800031c0:	8526                	mv	a0,s1
    800031c2:	00003097          	auipc	ra,0x3
    800031c6:	2d4080e7          	jalr	724(ra) # 80006496 <virtio_disk_rw>
}
    800031ca:	60e2                	ld	ra,24(sp)
    800031cc:	6442                	ld	s0,16(sp)
    800031ce:	64a2                	ld	s1,8(sp)
    800031d0:	6105                	addi	sp,sp,32
    800031d2:	8082                	ret
    panic("bwrite");
    800031d4:	00005517          	auipc	a0,0x5
    800031d8:	2fc50513          	addi	a0,a0,764 # 800084d0 <syscalls+0x110>
    800031dc:	ffffd097          	auipc	ra,0xffffd
    800031e0:	37c080e7          	jalr	892(ra) # 80000558 <panic>

00000000800031e4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031e4:	1101                	addi	sp,sp,-32
    800031e6:	ec06                	sd	ra,24(sp)
    800031e8:	e822                	sd	s0,16(sp)
    800031ea:	e426                	sd	s1,8(sp)
    800031ec:	e04a                	sd	s2,0(sp)
    800031ee:	1000                	addi	s0,sp,32
    800031f0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031f2:	01050913          	addi	s2,a0,16
    800031f6:	854a                	mv	a0,s2
    800031f8:	00001097          	auipc	ra,0x1
    800031fc:	486080e7          	jalr	1158(ra) # 8000467e <holdingsleep>
    80003200:	c92d                	beqz	a0,80003272 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003202:	854a                	mv	a0,s2
    80003204:	00001097          	auipc	ra,0x1
    80003208:	436080e7          	jalr	1078(ra) # 8000463a <releasesleep>

  acquire(&bcache.lock);
    8000320c:	00020517          	auipc	a0,0x20
    80003210:	ec450513          	addi	a0,a0,-316 # 800230d0 <bcache>
    80003214:	ffffe097          	auipc	ra,0xffffe
    80003218:	a10080e7          	jalr	-1520(ra) # 80000c24 <acquire>
  b->refcnt--;
    8000321c:	40bc                	lw	a5,64(s1)
    8000321e:	37fd                	addiw	a5,a5,-1
    80003220:	0007871b          	sext.w	a4,a5
    80003224:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003226:	eb05                	bnez	a4,80003256 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003228:	68bc                	ld	a5,80(s1)
    8000322a:	64b8                	ld	a4,72(s1)
    8000322c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000322e:	64bc                	ld	a5,72(s1)
    80003230:	68b8                	ld	a4,80(s1)
    80003232:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003234:	00028797          	auipc	a5,0x28
    80003238:	e9c78793          	addi	a5,a5,-356 # 8002b0d0 <bcache+0x8000>
    8000323c:	2b87b703          	ld	a4,696(a5)
    80003240:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003242:	00028717          	auipc	a4,0x28
    80003246:	0f670713          	addi	a4,a4,246 # 8002b338 <bcache+0x8268>
    8000324a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000324c:	2b87b703          	ld	a4,696(a5)
    80003250:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003252:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003256:	00020517          	auipc	a0,0x20
    8000325a:	e7a50513          	addi	a0,a0,-390 # 800230d0 <bcache>
    8000325e:	ffffe097          	auipc	ra,0xffffe
    80003262:	a7a080e7          	jalr	-1414(ra) # 80000cd8 <release>
}
    80003266:	60e2                	ld	ra,24(sp)
    80003268:	6442                	ld	s0,16(sp)
    8000326a:	64a2                	ld	s1,8(sp)
    8000326c:	6902                	ld	s2,0(sp)
    8000326e:	6105                	addi	sp,sp,32
    80003270:	8082                	ret
    panic("brelse");
    80003272:	00005517          	auipc	a0,0x5
    80003276:	26650513          	addi	a0,a0,614 # 800084d8 <syscalls+0x118>
    8000327a:	ffffd097          	auipc	ra,0xffffd
    8000327e:	2de080e7          	jalr	734(ra) # 80000558 <panic>

0000000080003282 <bpin>:

void
bpin(struct buf *b) {
    80003282:	1101                	addi	sp,sp,-32
    80003284:	ec06                	sd	ra,24(sp)
    80003286:	e822                	sd	s0,16(sp)
    80003288:	e426                	sd	s1,8(sp)
    8000328a:	1000                	addi	s0,sp,32
    8000328c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000328e:	00020517          	auipc	a0,0x20
    80003292:	e4250513          	addi	a0,a0,-446 # 800230d0 <bcache>
    80003296:	ffffe097          	auipc	ra,0xffffe
    8000329a:	98e080e7          	jalr	-1650(ra) # 80000c24 <acquire>
  b->refcnt++;
    8000329e:	40bc                	lw	a5,64(s1)
    800032a0:	2785                	addiw	a5,a5,1
    800032a2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032a4:	00020517          	auipc	a0,0x20
    800032a8:	e2c50513          	addi	a0,a0,-468 # 800230d0 <bcache>
    800032ac:	ffffe097          	auipc	ra,0xffffe
    800032b0:	a2c080e7          	jalr	-1492(ra) # 80000cd8 <release>
}
    800032b4:	60e2                	ld	ra,24(sp)
    800032b6:	6442                	ld	s0,16(sp)
    800032b8:	64a2                	ld	s1,8(sp)
    800032ba:	6105                	addi	sp,sp,32
    800032bc:	8082                	ret

00000000800032be <bunpin>:

void
bunpin(struct buf *b) {
    800032be:	1101                	addi	sp,sp,-32
    800032c0:	ec06                	sd	ra,24(sp)
    800032c2:	e822                	sd	s0,16(sp)
    800032c4:	e426                	sd	s1,8(sp)
    800032c6:	1000                	addi	s0,sp,32
    800032c8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032ca:	00020517          	auipc	a0,0x20
    800032ce:	e0650513          	addi	a0,a0,-506 # 800230d0 <bcache>
    800032d2:	ffffe097          	auipc	ra,0xffffe
    800032d6:	952080e7          	jalr	-1710(ra) # 80000c24 <acquire>
  b->refcnt--;
    800032da:	40bc                	lw	a5,64(s1)
    800032dc:	37fd                	addiw	a5,a5,-1
    800032de:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032e0:	00020517          	auipc	a0,0x20
    800032e4:	df050513          	addi	a0,a0,-528 # 800230d0 <bcache>
    800032e8:	ffffe097          	auipc	ra,0xffffe
    800032ec:	9f0080e7          	jalr	-1552(ra) # 80000cd8 <release>
}
    800032f0:	60e2                	ld	ra,24(sp)
    800032f2:	6442                	ld	s0,16(sp)
    800032f4:	64a2                	ld	s1,8(sp)
    800032f6:	6105                	addi	sp,sp,32
    800032f8:	8082                	ret

00000000800032fa <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032fa:	1101                	addi	sp,sp,-32
    800032fc:	ec06                	sd	ra,24(sp)
    800032fe:	e822                	sd	s0,16(sp)
    80003300:	e426                	sd	s1,8(sp)
    80003302:	e04a                	sd	s2,0(sp)
    80003304:	1000                	addi	s0,sp,32
    80003306:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003308:	00d5d59b          	srliw	a1,a1,0xd
    8000330c:	00028797          	auipc	a5,0x28
    80003310:	48478793          	addi	a5,a5,1156 # 8002b790 <sb>
    80003314:	4fdc                	lw	a5,28(a5)
    80003316:	9dbd                	addw	a1,a1,a5
    80003318:	00000097          	auipc	ra,0x0
    8000331c:	d8a080e7          	jalr	-630(ra) # 800030a2 <bread>
  bi = b % BPB;
    80003320:	2481                	sext.w	s1,s1
  m = 1 << (bi % 8);
    80003322:	0074f793          	andi	a5,s1,7
    80003326:	4705                	li	a4,1
    80003328:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    8000332c:	6789                	lui	a5,0x2
    8000332e:	17fd                	addi	a5,a5,-1
    80003330:	8cfd                	and	s1,s1,a5
  if((bp->data[bi/8] & m) == 0)
    80003332:	41f4d79b          	sraiw	a5,s1,0x1f
    80003336:	01d7d79b          	srliw	a5,a5,0x1d
    8000333a:	9fa5                	addw	a5,a5,s1
    8000333c:	4037d79b          	sraiw	a5,a5,0x3
    80003340:	00f506b3          	add	a3,a0,a5
    80003344:	0586c683          	lbu	a3,88(a3)
    80003348:	00d77633          	and	a2,a4,a3
    8000334c:	c61d                	beqz	a2,8000337a <bfree+0x80>
    8000334e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003350:	97aa                	add	a5,a5,a0
    80003352:	fff74713          	not	a4,a4
    80003356:	8f75                	and	a4,a4,a3
    80003358:	04e78c23          	sb	a4,88(a5) # 2058 <_entry-0x7fffdfa8>
  log_write(bp);
    8000335c:	00001097          	auipc	ra,0x1
    80003360:	14a080e7          	jalr	330(ra) # 800044a6 <log_write>
  brelse(bp);
    80003364:	854a                	mv	a0,s2
    80003366:	00000097          	auipc	ra,0x0
    8000336a:	e7e080e7          	jalr	-386(ra) # 800031e4 <brelse>
}
    8000336e:	60e2                	ld	ra,24(sp)
    80003370:	6442                	ld	s0,16(sp)
    80003372:	64a2                	ld	s1,8(sp)
    80003374:	6902                	ld	s2,0(sp)
    80003376:	6105                	addi	sp,sp,32
    80003378:	8082                	ret
    panic("freeing free block");
    8000337a:	00005517          	auipc	a0,0x5
    8000337e:	16650513          	addi	a0,a0,358 # 800084e0 <syscalls+0x120>
    80003382:	ffffd097          	auipc	ra,0xffffd
    80003386:	1d6080e7          	jalr	470(ra) # 80000558 <panic>

000000008000338a <balloc>:
{
    8000338a:	711d                	addi	sp,sp,-96
    8000338c:	ec86                	sd	ra,88(sp)
    8000338e:	e8a2                	sd	s0,80(sp)
    80003390:	e4a6                	sd	s1,72(sp)
    80003392:	e0ca                	sd	s2,64(sp)
    80003394:	fc4e                	sd	s3,56(sp)
    80003396:	f852                	sd	s4,48(sp)
    80003398:	f456                	sd	s5,40(sp)
    8000339a:	f05a                	sd	s6,32(sp)
    8000339c:	ec5e                	sd	s7,24(sp)
    8000339e:	e862                	sd	s8,16(sp)
    800033a0:	e466                	sd	s9,8(sp)
    800033a2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033a4:	00028797          	auipc	a5,0x28
    800033a8:	3ec78793          	addi	a5,a5,1004 # 8002b790 <sb>
    800033ac:	43dc                	lw	a5,4(a5)
    800033ae:	10078e63          	beqz	a5,800034ca <balloc+0x140>
    800033b2:	8baa                	mv	s7,a0
    800033b4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033b6:	00028b17          	auipc	s6,0x28
    800033ba:	3dab0b13          	addi	s6,s6,986 # 8002b790 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033be:	4c05                	li	s8,1
      m = 1 << (bi % 8);
    800033c0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033c2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033c4:	6c89                	lui	s9,0x2
    800033c6:	a079                	j	80003454 <balloc+0xca>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033c8:	8942                	mv	s2,a6
      m = 1 << (bi % 8);
    800033ca:	4705                	li	a4,1
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800033cc:	4681                	li	a3,0
        bp->data[bi/8] |= m;  // Mark block in use.
    800033ce:	96a6                	add	a3,a3,s1
    800033d0:	8f51                	or	a4,a4,a2
    800033d2:	04e68c23          	sb	a4,88(a3)
        log_write(bp);
    800033d6:	8526                	mv	a0,s1
    800033d8:	00001097          	auipc	ra,0x1
    800033dc:	0ce080e7          	jalr	206(ra) # 800044a6 <log_write>
        brelse(bp);
    800033e0:	8526                	mv	a0,s1
    800033e2:	00000097          	auipc	ra,0x0
    800033e6:	e02080e7          	jalr	-510(ra) # 800031e4 <brelse>
  bp = bread(dev, bno);
    800033ea:	85ca                	mv	a1,s2
    800033ec:	855e                	mv	a0,s7
    800033ee:	00000097          	auipc	ra,0x0
    800033f2:	cb4080e7          	jalr	-844(ra) # 800030a2 <bread>
    800033f6:	84aa                	mv	s1,a0
  memset(bp->data, 0, BSIZE);
    800033f8:	40000613          	li	a2,1024
    800033fc:	4581                	li	a1,0
    800033fe:	05850513          	addi	a0,a0,88
    80003402:	ffffe097          	auipc	ra,0xffffe
    80003406:	91e080e7          	jalr	-1762(ra) # 80000d20 <memset>
  log_write(bp);
    8000340a:	8526                	mv	a0,s1
    8000340c:	00001097          	auipc	ra,0x1
    80003410:	09a080e7          	jalr	154(ra) # 800044a6 <log_write>
  brelse(bp);
    80003414:	8526                	mv	a0,s1
    80003416:	00000097          	auipc	ra,0x0
    8000341a:	dce080e7          	jalr	-562(ra) # 800031e4 <brelse>
}
    8000341e:	854a                	mv	a0,s2
    80003420:	60e6                	ld	ra,88(sp)
    80003422:	6446                	ld	s0,80(sp)
    80003424:	64a6                	ld	s1,72(sp)
    80003426:	6906                	ld	s2,64(sp)
    80003428:	79e2                	ld	s3,56(sp)
    8000342a:	7a42                	ld	s4,48(sp)
    8000342c:	7aa2                	ld	s5,40(sp)
    8000342e:	7b02                	ld	s6,32(sp)
    80003430:	6be2                	ld	s7,24(sp)
    80003432:	6c42                	ld	s8,16(sp)
    80003434:	6ca2                	ld	s9,8(sp)
    80003436:	6125                	addi	sp,sp,96
    80003438:	8082                	ret
    brelse(bp);
    8000343a:	8526                	mv	a0,s1
    8000343c:	00000097          	auipc	ra,0x0
    80003440:	da8080e7          	jalr	-600(ra) # 800031e4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003444:	015c87bb          	addw	a5,s9,s5
    80003448:	00078a9b          	sext.w	s5,a5
    8000344c:	004b2703          	lw	a4,4(s6)
    80003450:	06eafd63          	bleu	a4,s5,800034ca <balloc+0x140>
    bp = bread(dev, BBLOCK(b, sb));
    80003454:	41fad79b          	sraiw	a5,s5,0x1f
    80003458:	0137d79b          	srliw	a5,a5,0x13
    8000345c:	015787bb          	addw	a5,a5,s5
    80003460:	40d7d79b          	sraiw	a5,a5,0xd
    80003464:	01cb2583          	lw	a1,28(s6)
    80003468:	9dbd                	addw	a1,a1,a5
    8000346a:	855e                	mv	a0,s7
    8000346c:	00000097          	auipc	ra,0x0
    80003470:	c36080e7          	jalr	-970(ra) # 800030a2 <bread>
    80003474:	84aa                	mv	s1,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003476:	000a881b          	sext.w	a6,s5
    8000347a:	004b2503          	lw	a0,4(s6)
    8000347e:	faa87ee3          	bleu	a0,a6,8000343a <balloc+0xb0>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003482:	0584c603          	lbu	a2,88(s1)
    80003486:	00167793          	andi	a5,a2,1
    8000348a:	df9d                	beqz	a5,800033c8 <balloc+0x3e>
    8000348c:	4105053b          	subw	a0,a0,a6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003490:	87e2                	mv	a5,s8
    80003492:	0107893b          	addw	s2,a5,a6
    80003496:	faa782e3          	beq	a5,a0,8000343a <balloc+0xb0>
      m = 1 << (bi % 8);
    8000349a:	41f7d71b          	sraiw	a4,a5,0x1f
    8000349e:	01d7561b          	srliw	a2,a4,0x1d
    800034a2:	00f606bb          	addw	a3,a2,a5
    800034a6:	0076f713          	andi	a4,a3,7
    800034aa:	9f11                	subw	a4,a4,a2
    800034ac:	00e9973b          	sllw	a4,s3,a4
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034b0:	4036d69b          	sraiw	a3,a3,0x3
    800034b4:	00d48633          	add	a2,s1,a3
    800034b8:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    800034bc:	00c775b3          	and	a1,a4,a2
    800034c0:	d599                	beqz	a1,800033ce <balloc+0x44>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034c2:	2785                	addiw	a5,a5,1
    800034c4:	fd4797e3          	bne	a5,s4,80003492 <balloc+0x108>
    800034c8:	bf8d                	j	8000343a <balloc+0xb0>
  panic("balloc: out of blocks");
    800034ca:	00005517          	auipc	a0,0x5
    800034ce:	02e50513          	addi	a0,a0,46 # 800084f8 <syscalls+0x138>
    800034d2:	ffffd097          	auipc	ra,0xffffd
    800034d6:	086080e7          	jalr	134(ra) # 80000558 <panic>

00000000800034da <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800034da:	7179                	addi	sp,sp,-48
    800034dc:	f406                	sd	ra,40(sp)
    800034de:	f022                	sd	s0,32(sp)
    800034e0:	ec26                	sd	s1,24(sp)
    800034e2:	e84a                	sd	s2,16(sp)
    800034e4:	e44e                	sd	s3,8(sp)
    800034e6:	e052                	sd	s4,0(sp)
    800034e8:	1800                	addi	s0,sp,48
    800034ea:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034ec:	47ad                	li	a5,11
    800034ee:	04b7fe63          	bleu	a1,a5,8000354a <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800034f2:	ff45849b          	addiw	s1,a1,-12
    800034f6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800034fa:	0ff00793          	li	a5,255
    800034fe:	0ae7e363          	bltu	a5,a4,800035a4 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003502:	08052583          	lw	a1,128(a0)
    80003506:	c5ad                	beqz	a1,80003570 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003508:	0009a503          	lw	a0,0(s3)
    8000350c:	00000097          	auipc	ra,0x0
    80003510:	b96080e7          	jalr	-1130(ra) # 800030a2 <bread>
    80003514:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003516:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000351a:	02049593          	slli	a1,s1,0x20
    8000351e:	9181                	srli	a1,a1,0x20
    80003520:	058a                	slli	a1,a1,0x2
    80003522:	00b784b3          	add	s1,a5,a1
    80003526:	0004a903          	lw	s2,0(s1)
    8000352a:	04090d63          	beqz	s2,80003584 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000352e:	8552                	mv	a0,s4
    80003530:	00000097          	auipc	ra,0x0
    80003534:	cb4080e7          	jalr	-844(ra) # 800031e4 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003538:	854a                	mv	a0,s2
    8000353a:	70a2                	ld	ra,40(sp)
    8000353c:	7402                	ld	s0,32(sp)
    8000353e:	64e2                	ld	s1,24(sp)
    80003540:	6942                	ld	s2,16(sp)
    80003542:	69a2                	ld	s3,8(sp)
    80003544:	6a02                	ld	s4,0(sp)
    80003546:	6145                	addi	sp,sp,48
    80003548:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000354a:	02059493          	slli	s1,a1,0x20
    8000354e:	9081                	srli	s1,s1,0x20
    80003550:	048a                	slli	s1,s1,0x2
    80003552:	94aa                	add	s1,s1,a0
    80003554:	0504a903          	lw	s2,80(s1)
    80003558:	fe0910e3          	bnez	s2,80003538 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000355c:	4108                	lw	a0,0(a0)
    8000355e:	00000097          	auipc	ra,0x0
    80003562:	e2c080e7          	jalr	-468(ra) # 8000338a <balloc>
    80003566:	0005091b          	sext.w	s2,a0
    8000356a:	0524a823          	sw	s2,80(s1)
    8000356e:	b7e9                	j	80003538 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003570:	4108                	lw	a0,0(a0)
    80003572:	00000097          	auipc	ra,0x0
    80003576:	e18080e7          	jalr	-488(ra) # 8000338a <balloc>
    8000357a:	0005059b          	sext.w	a1,a0
    8000357e:	08b9a023          	sw	a1,128(s3)
    80003582:	b759                	j	80003508 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003584:	0009a503          	lw	a0,0(s3)
    80003588:	00000097          	auipc	ra,0x0
    8000358c:	e02080e7          	jalr	-510(ra) # 8000338a <balloc>
    80003590:	0005091b          	sext.w	s2,a0
    80003594:	0124a023          	sw	s2,0(s1)
      log_write(bp);
    80003598:	8552                	mv	a0,s4
    8000359a:	00001097          	auipc	ra,0x1
    8000359e:	f0c080e7          	jalr	-244(ra) # 800044a6 <log_write>
    800035a2:	b771                	j	8000352e <bmap+0x54>
  panic("bmap: out of range");
    800035a4:	00005517          	auipc	a0,0x5
    800035a8:	f6c50513          	addi	a0,a0,-148 # 80008510 <syscalls+0x150>
    800035ac:	ffffd097          	auipc	ra,0xffffd
    800035b0:	fac080e7          	jalr	-84(ra) # 80000558 <panic>

00000000800035b4 <iget>:
{
    800035b4:	7179                	addi	sp,sp,-48
    800035b6:	f406                	sd	ra,40(sp)
    800035b8:	f022                	sd	s0,32(sp)
    800035ba:	ec26                	sd	s1,24(sp)
    800035bc:	e84a                	sd	s2,16(sp)
    800035be:	e44e                	sd	s3,8(sp)
    800035c0:	e052                	sd	s4,0(sp)
    800035c2:	1800                	addi	s0,sp,48
    800035c4:	89aa                	mv	s3,a0
    800035c6:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800035c8:	00028517          	auipc	a0,0x28
    800035cc:	1e850513          	addi	a0,a0,488 # 8002b7b0 <icache>
    800035d0:	ffffd097          	auipc	ra,0xffffd
    800035d4:	654080e7          	jalr	1620(ra) # 80000c24 <acquire>
  empty = 0;
    800035d8:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800035da:	00028497          	auipc	s1,0x28
    800035de:	1ee48493          	addi	s1,s1,494 # 8002b7c8 <icache+0x18>
    800035e2:	0002a697          	auipc	a3,0x2a
    800035e6:	c7668693          	addi	a3,a3,-906 # 8002d258 <log>
    800035ea:	a039                	j	800035f8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035ec:	02090b63          	beqz	s2,80003622 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800035f0:	08848493          	addi	s1,s1,136
    800035f4:	02d48a63          	beq	s1,a3,80003628 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035f8:	449c                	lw	a5,8(s1)
    800035fa:	fef059e3          	blez	a5,800035ec <iget+0x38>
    800035fe:	4098                	lw	a4,0(s1)
    80003600:	ff3716e3          	bne	a4,s3,800035ec <iget+0x38>
    80003604:	40d8                	lw	a4,4(s1)
    80003606:	ff4713e3          	bne	a4,s4,800035ec <iget+0x38>
      ip->ref++;
    8000360a:	2785                	addiw	a5,a5,1
    8000360c:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000360e:	00028517          	auipc	a0,0x28
    80003612:	1a250513          	addi	a0,a0,418 # 8002b7b0 <icache>
    80003616:	ffffd097          	auipc	ra,0xffffd
    8000361a:	6c2080e7          	jalr	1730(ra) # 80000cd8 <release>
      return ip;
    8000361e:	8926                	mv	s2,s1
    80003620:	a03d                	j	8000364e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003622:	f7f9                	bnez	a5,800035f0 <iget+0x3c>
    80003624:	8926                	mv	s2,s1
    80003626:	b7e9                	j	800035f0 <iget+0x3c>
  if(empty == 0)
    80003628:	02090c63          	beqz	s2,80003660 <iget+0xac>
  ip->dev = dev;
    8000362c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003630:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003634:	4785                	li	a5,1
    80003636:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000363a:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    8000363e:	00028517          	auipc	a0,0x28
    80003642:	17250513          	addi	a0,a0,370 # 8002b7b0 <icache>
    80003646:	ffffd097          	auipc	ra,0xffffd
    8000364a:	692080e7          	jalr	1682(ra) # 80000cd8 <release>
}
    8000364e:	854a                	mv	a0,s2
    80003650:	70a2                	ld	ra,40(sp)
    80003652:	7402                	ld	s0,32(sp)
    80003654:	64e2                	ld	s1,24(sp)
    80003656:	6942                	ld	s2,16(sp)
    80003658:	69a2                	ld	s3,8(sp)
    8000365a:	6a02                	ld	s4,0(sp)
    8000365c:	6145                	addi	sp,sp,48
    8000365e:	8082                	ret
    panic("iget: no inodes");
    80003660:	00005517          	auipc	a0,0x5
    80003664:	ec850513          	addi	a0,a0,-312 # 80008528 <syscalls+0x168>
    80003668:	ffffd097          	auipc	ra,0xffffd
    8000366c:	ef0080e7          	jalr	-272(ra) # 80000558 <panic>

0000000080003670 <fsinit>:
fsinit(int dev) {
    80003670:	7179                	addi	sp,sp,-48
    80003672:	f406                	sd	ra,40(sp)
    80003674:	f022                	sd	s0,32(sp)
    80003676:	ec26                	sd	s1,24(sp)
    80003678:	e84a                	sd	s2,16(sp)
    8000367a:	e44e                	sd	s3,8(sp)
    8000367c:	1800                	addi	s0,sp,48
    8000367e:	89aa                	mv	s3,a0
  bp = bread(dev, 1);
    80003680:	4585                	li	a1,1
    80003682:	00000097          	auipc	ra,0x0
    80003686:	a20080e7          	jalr	-1504(ra) # 800030a2 <bread>
    8000368a:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000368c:	00028497          	auipc	s1,0x28
    80003690:	10448493          	addi	s1,s1,260 # 8002b790 <sb>
    80003694:	02000613          	li	a2,32
    80003698:	05850593          	addi	a1,a0,88
    8000369c:	8526                	mv	a0,s1
    8000369e:	ffffd097          	auipc	ra,0xffffd
    800036a2:	6ee080e7          	jalr	1774(ra) # 80000d8c <memmove>
  brelse(bp);
    800036a6:	854a                	mv	a0,s2
    800036a8:	00000097          	auipc	ra,0x0
    800036ac:	b3c080e7          	jalr	-1220(ra) # 800031e4 <brelse>
  if(sb.magic != FSMAGIC)
    800036b0:	4098                	lw	a4,0(s1)
    800036b2:	102037b7          	lui	a5,0x10203
    800036b6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036ba:	02f71263          	bne	a4,a5,800036de <fsinit+0x6e>
  initlog(dev, &sb);
    800036be:	00028597          	auipc	a1,0x28
    800036c2:	0d258593          	addi	a1,a1,210 # 8002b790 <sb>
    800036c6:	854e                	mv	a0,s3
    800036c8:	00001097          	auipc	ra,0x1
    800036cc:	b5c080e7          	jalr	-1188(ra) # 80004224 <initlog>
}
    800036d0:	70a2                	ld	ra,40(sp)
    800036d2:	7402                	ld	s0,32(sp)
    800036d4:	64e2                	ld	s1,24(sp)
    800036d6:	6942                	ld	s2,16(sp)
    800036d8:	69a2                	ld	s3,8(sp)
    800036da:	6145                	addi	sp,sp,48
    800036dc:	8082                	ret
    panic("invalid file system");
    800036de:	00005517          	auipc	a0,0x5
    800036e2:	e5a50513          	addi	a0,a0,-422 # 80008538 <syscalls+0x178>
    800036e6:	ffffd097          	auipc	ra,0xffffd
    800036ea:	e72080e7          	jalr	-398(ra) # 80000558 <panic>

00000000800036ee <iinit>:
{
    800036ee:	7179                	addi	sp,sp,-48
    800036f0:	f406                	sd	ra,40(sp)
    800036f2:	f022                	sd	s0,32(sp)
    800036f4:	ec26                	sd	s1,24(sp)
    800036f6:	e84a                	sd	s2,16(sp)
    800036f8:	e44e                	sd	s3,8(sp)
    800036fa:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800036fc:	00005597          	auipc	a1,0x5
    80003700:	e5458593          	addi	a1,a1,-428 # 80008550 <syscalls+0x190>
    80003704:	00028517          	auipc	a0,0x28
    80003708:	0ac50513          	addi	a0,a0,172 # 8002b7b0 <icache>
    8000370c:	ffffd097          	auipc	ra,0xffffd
    80003710:	488080e7          	jalr	1160(ra) # 80000b94 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003714:	00028497          	auipc	s1,0x28
    80003718:	0c448493          	addi	s1,s1,196 # 8002b7d8 <icache+0x28>
    8000371c:	0002a997          	auipc	s3,0x2a
    80003720:	b4c98993          	addi	s3,s3,-1204 # 8002d268 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003724:	00005917          	auipc	s2,0x5
    80003728:	e3490913          	addi	s2,s2,-460 # 80008558 <syscalls+0x198>
    8000372c:	85ca                	mv	a1,s2
    8000372e:	8526                	mv	a0,s1
    80003730:	00001097          	auipc	ra,0x1
    80003734:	e7a080e7          	jalr	-390(ra) # 800045aa <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003738:	08848493          	addi	s1,s1,136
    8000373c:	ff3498e3          	bne	s1,s3,8000372c <iinit+0x3e>
}
    80003740:	70a2                	ld	ra,40(sp)
    80003742:	7402                	ld	s0,32(sp)
    80003744:	64e2                	ld	s1,24(sp)
    80003746:	6942                	ld	s2,16(sp)
    80003748:	69a2                	ld	s3,8(sp)
    8000374a:	6145                	addi	sp,sp,48
    8000374c:	8082                	ret

000000008000374e <ialloc>:
{
    8000374e:	715d                	addi	sp,sp,-80
    80003750:	e486                	sd	ra,72(sp)
    80003752:	e0a2                	sd	s0,64(sp)
    80003754:	fc26                	sd	s1,56(sp)
    80003756:	f84a                	sd	s2,48(sp)
    80003758:	f44e                	sd	s3,40(sp)
    8000375a:	f052                	sd	s4,32(sp)
    8000375c:	ec56                	sd	s5,24(sp)
    8000375e:	e85a                	sd	s6,16(sp)
    80003760:	e45e                	sd	s7,8(sp)
    80003762:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003764:	00028797          	auipc	a5,0x28
    80003768:	02c78793          	addi	a5,a5,44 # 8002b790 <sb>
    8000376c:	47d8                	lw	a4,12(a5)
    8000376e:	4785                	li	a5,1
    80003770:	04e7fa63          	bleu	a4,a5,800037c4 <ialloc+0x76>
    80003774:	8a2a                	mv	s4,a0
    80003776:	8b2e                	mv	s6,a1
    80003778:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000377a:	00028997          	auipc	s3,0x28
    8000377e:	01698993          	addi	s3,s3,22 # 8002b790 <sb>
    80003782:	00048a9b          	sext.w	s5,s1
    80003786:	0044d593          	srli	a1,s1,0x4
    8000378a:	0189a783          	lw	a5,24(s3)
    8000378e:	9dbd                	addw	a1,a1,a5
    80003790:	8552                	mv	a0,s4
    80003792:	00000097          	auipc	ra,0x0
    80003796:	910080e7          	jalr	-1776(ra) # 800030a2 <bread>
    8000379a:	8baa                	mv	s7,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000379c:	05850913          	addi	s2,a0,88
    800037a0:	00f4f793          	andi	a5,s1,15
    800037a4:	079a                	slli	a5,a5,0x6
    800037a6:	993e                	add	s2,s2,a5
    if(dip->type == 0){  // a free inode
    800037a8:	00091783          	lh	a5,0(s2)
    800037ac:	c785                	beqz	a5,800037d4 <ialloc+0x86>
    brelse(bp);
    800037ae:	00000097          	auipc	ra,0x0
    800037b2:	a36080e7          	jalr	-1482(ra) # 800031e4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037b6:	0485                	addi	s1,s1,1
    800037b8:	00c9a703          	lw	a4,12(s3)
    800037bc:	0004879b          	sext.w	a5,s1
    800037c0:	fce7e1e3          	bltu	a5,a4,80003782 <ialloc+0x34>
  panic("ialloc: no inodes");
    800037c4:	00005517          	auipc	a0,0x5
    800037c8:	d9c50513          	addi	a0,a0,-612 # 80008560 <syscalls+0x1a0>
    800037cc:	ffffd097          	auipc	ra,0xffffd
    800037d0:	d8c080e7          	jalr	-628(ra) # 80000558 <panic>
      memset(dip, 0, sizeof(*dip));
    800037d4:	04000613          	li	a2,64
    800037d8:	4581                	li	a1,0
    800037da:	854a                	mv	a0,s2
    800037dc:	ffffd097          	auipc	ra,0xffffd
    800037e0:	544080e7          	jalr	1348(ra) # 80000d20 <memset>
      dip->type = type;
    800037e4:	01691023          	sh	s6,0(s2)
      log_write(bp);   // mark it allocated on the disk
    800037e8:	855e                	mv	a0,s7
    800037ea:	00001097          	auipc	ra,0x1
    800037ee:	cbc080e7          	jalr	-836(ra) # 800044a6 <log_write>
      brelse(bp);
    800037f2:	855e                	mv	a0,s7
    800037f4:	00000097          	auipc	ra,0x0
    800037f8:	9f0080e7          	jalr	-1552(ra) # 800031e4 <brelse>
      return iget(dev, inum);
    800037fc:	85d6                	mv	a1,s5
    800037fe:	8552                	mv	a0,s4
    80003800:	00000097          	auipc	ra,0x0
    80003804:	db4080e7          	jalr	-588(ra) # 800035b4 <iget>
}
    80003808:	60a6                	ld	ra,72(sp)
    8000380a:	6406                	ld	s0,64(sp)
    8000380c:	74e2                	ld	s1,56(sp)
    8000380e:	7942                	ld	s2,48(sp)
    80003810:	79a2                	ld	s3,40(sp)
    80003812:	7a02                	ld	s4,32(sp)
    80003814:	6ae2                	ld	s5,24(sp)
    80003816:	6b42                	ld	s6,16(sp)
    80003818:	6ba2                	ld	s7,8(sp)
    8000381a:	6161                	addi	sp,sp,80
    8000381c:	8082                	ret

000000008000381e <iupdate>:
{
    8000381e:	1101                	addi	sp,sp,-32
    80003820:	ec06                	sd	ra,24(sp)
    80003822:	e822                	sd	s0,16(sp)
    80003824:	e426                	sd	s1,8(sp)
    80003826:	e04a                	sd	s2,0(sp)
    80003828:	1000                	addi	s0,sp,32
    8000382a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000382c:	415c                	lw	a5,4(a0)
    8000382e:	0047d79b          	srliw	a5,a5,0x4
    80003832:	00028717          	auipc	a4,0x28
    80003836:	f5e70713          	addi	a4,a4,-162 # 8002b790 <sb>
    8000383a:	4f0c                	lw	a1,24(a4)
    8000383c:	9dbd                	addw	a1,a1,a5
    8000383e:	4108                	lw	a0,0(a0)
    80003840:	00000097          	auipc	ra,0x0
    80003844:	862080e7          	jalr	-1950(ra) # 800030a2 <bread>
    80003848:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000384a:	05850513          	addi	a0,a0,88
    8000384e:	40dc                	lw	a5,4(s1)
    80003850:	8bbd                	andi	a5,a5,15
    80003852:	079a                	slli	a5,a5,0x6
    80003854:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003856:	04449783          	lh	a5,68(s1)
    8000385a:	00f51023          	sh	a5,0(a0)
  dip->major = ip->major;
    8000385e:	04649783          	lh	a5,70(s1)
    80003862:	00f51123          	sh	a5,2(a0)
  dip->minor = ip->minor;
    80003866:	04849783          	lh	a5,72(s1)
    8000386a:	00f51223          	sh	a5,4(a0)
  dip->nlink = ip->nlink;
    8000386e:	04a49783          	lh	a5,74(s1)
    80003872:	00f51323          	sh	a5,6(a0)
  dip->size = ip->size;
    80003876:	44fc                	lw	a5,76(s1)
    80003878:	c51c                	sw	a5,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000387a:	03400613          	li	a2,52
    8000387e:	05048593          	addi	a1,s1,80
    80003882:	0531                	addi	a0,a0,12
    80003884:	ffffd097          	auipc	ra,0xffffd
    80003888:	508080e7          	jalr	1288(ra) # 80000d8c <memmove>
  log_write(bp);
    8000388c:	854a                	mv	a0,s2
    8000388e:	00001097          	auipc	ra,0x1
    80003892:	c18080e7          	jalr	-1000(ra) # 800044a6 <log_write>
  brelse(bp);
    80003896:	854a                	mv	a0,s2
    80003898:	00000097          	auipc	ra,0x0
    8000389c:	94c080e7          	jalr	-1716(ra) # 800031e4 <brelse>
}
    800038a0:	60e2                	ld	ra,24(sp)
    800038a2:	6442                	ld	s0,16(sp)
    800038a4:	64a2                	ld	s1,8(sp)
    800038a6:	6902                	ld	s2,0(sp)
    800038a8:	6105                	addi	sp,sp,32
    800038aa:	8082                	ret

00000000800038ac <idup>:
{
    800038ac:	1101                	addi	sp,sp,-32
    800038ae:	ec06                	sd	ra,24(sp)
    800038b0:	e822                	sd	s0,16(sp)
    800038b2:	e426                	sd	s1,8(sp)
    800038b4:	1000                	addi	s0,sp,32
    800038b6:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800038b8:	00028517          	auipc	a0,0x28
    800038bc:	ef850513          	addi	a0,a0,-264 # 8002b7b0 <icache>
    800038c0:	ffffd097          	auipc	ra,0xffffd
    800038c4:	364080e7          	jalr	868(ra) # 80000c24 <acquire>
  ip->ref++;
    800038c8:	449c                	lw	a5,8(s1)
    800038ca:	2785                	addiw	a5,a5,1
    800038cc:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800038ce:	00028517          	auipc	a0,0x28
    800038d2:	ee250513          	addi	a0,a0,-286 # 8002b7b0 <icache>
    800038d6:	ffffd097          	auipc	ra,0xffffd
    800038da:	402080e7          	jalr	1026(ra) # 80000cd8 <release>
}
    800038de:	8526                	mv	a0,s1
    800038e0:	60e2                	ld	ra,24(sp)
    800038e2:	6442                	ld	s0,16(sp)
    800038e4:	64a2                	ld	s1,8(sp)
    800038e6:	6105                	addi	sp,sp,32
    800038e8:	8082                	ret

00000000800038ea <ilock>:
{
    800038ea:	1101                	addi	sp,sp,-32
    800038ec:	ec06                	sd	ra,24(sp)
    800038ee:	e822                	sd	s0,16(sp)
    800038f0:	e426                	sd	s1,8(sp)
    800038f2:	e04a                	sd	s2,0(sp)
    800038f4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800038f6:	c115                	beqz	a0,8000391a <ilock+0x30>
    800038f8:	84aa                	mv	s1,a0
    800038fa:	451c                	lw	a5,8(a0)
    800038fc:	00f05f63          	blez	a5,8000391a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003900:	0541                	addi	a0,a0,16
    80003902:	00001097          	auipc	ra,0x1
    80003906:	ce2080e7          	jalr	-798(ra) # 800045e4 <acquiresleep>
  if(ip->valid == 0){
    8000390a:	40bc                	lw	a5,64(s1)
    8000390c:	cf99                	beqz	a5,8000392a <ilock+0x40>
}
    8000390e:	60e2                	ld	ra,24(sp)
    80003910:	6442                	ld	s0,16(sp)
    80003912:	64a2                	ld	s1,8(sp)
    80003914:	6902                	ld	s2,0(sp)
    80003916:	6105                	addi	sp,sp,32
    80003918:	8082                	ret
    panic("ilock");
    8000391a:	00005517          	auipc	a0,0x5
    8000391e:	c5e50513          	addi	a0,a0,-930 # 80008578 <syscalls+0x1b8>
    80003922:	ffffd097          	auipc	ra,0xffffd
    80003926:	c36080e7          	jalr	-970(ra) # 80000558 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000392a:	40dc                	lw	a5,4(s1)
    8000392c:	0047d79b          	srliw	a5,a5,0x4
    80003930:	00028717          	auipc	a4,0x28
    80003934:	e6070713          	addi	a4,a4,-416 # 8002b790 <sb>
    80003938:	4f0c                	lw	a1,24(a4)
    8000393a:	9dbd                	addw	a1,a1,a5
    8000393c:	4088                	lw	a0,0(s1)
    8000393e:	fffff097          	auipc	ra,0xfffff
    80003942:	764080e7          	jalr	1892(ra) # 800030a2 <bread>
    80003946:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003948:	05850593          	addi	a1,a0,88
    8000394c:	40dc                	lw	a5,4(s1)
    8000394e:	8bbd                	andi	a5,a5,15
    80003950:	079a                	slli	a5,a5,0x6
    80003952:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003954:	00059783          	lh	a5,0(a1)
    80003958:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000395c:	00259783          	lh	a5,2(a1)
    80003960:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003964:	00459783          	lh	a5,4(a1)
    80003968:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000396c:	00659783          	lh	a5,6(a1)
    80003970:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003974:	459c                	lw	a5,8(a1)
    80003976:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003978:	03400613          	li	a2,52
    8000397c:	05b1                	addi	a1,a1,12
    8000397e:	05048513          	addi	a0,s1,80
    80003982:	ffffd097          	auipc	ra,0xffffd
    80003986:	40a080e7          	jalr	1034(ra) # 80000d8c <memmove>
    brelse(bp);
    8000398a:	854a                	mv	a0,s2
    8000398c:	00000097          	auipc	ra,0x0
    80003990:	858080e7          	jalr	-1960(ra) # 800031e4 <brelse>
    ip->valid = 1;
    80003994:	4785                	li	a5,1
    80003996:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003998:	04449783          	lh	a5,68(s1)
    8000399c:	fbad                	bnez	a5,8000390e <ilock+0x24>
      panic("ilock: no type");
    8000399e:	00005517          	auipc	a0,0x5
    800039a2:	be250513          	addi	a0,a0,-1054 # 80008580 <syscalls+0x1c0>
    800039a6:	ffffd097          	auipc	ra,0xffffd
    800039aa:	bb2080e7          	jalr	-1102(ra) # 80000558 <panic>

00000000800039ae <iunlock>:
{
    800039ae:	1101                	addi	sp,sp,-32
    800039b0:	ec06                	sd	ra,24(sp)
    800039b2:	e822                	sd	s0,16(sp)
    800039b4:	e426                	sd	s1,8(sp)
    800039b6:	e04a                	sd	s2,0(sp)
    800039b8:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039ba:	c905                	beqz	a0,800039ea <iunlock+0x3c>
    800039bc:	84aa                	mv	s1,a0
    800039be:	01050913          	addi	s2,a0,16
    800039c2:	854a                	mv	a0,s2
    800039c4:	00001097          	auipc	ra,0x1
    800039c8:	cba080e7          	jalr	-838(ra) # 8000467e <holdingsleep>
    800039cc:	cd19                	beqz	a0,800039ea <iunlock+0x3c>
    800039ce:	449c                	lw	a5,8(s1)
    800039d0:	00f05d63          	blez	a5,800039ea <iunlock+0x3c>
  releasesleep(&ip->lock);
    800039d4:	854a                	mv	a0,s2
    800039d6:	00001097          	auipc	ra,0x1
    800039da:	c64080e7          	jalr	-924(ra) # 8000463a <releasesleep>
}
    800039de:	60e2                	ld	ra,24(sp)
    800039e0:	6442                	ld	s0,16(sp)
    800039e2:	64a2                	ld	s1,8(sp)
    800039e4:	6902                	ld	s2,0(sp)
    800039e6:	6105                	addi	sp,sp,32
    800039e8:	8082                	ret
    panic("iunlock");
    800039ea:	00005517          	auipc	a0,0x5
    800039ee:	ba650513          	addi	a0,a0,-1114 # 80008590 <syscalls+0x1d0>
    800039f2:	ffffd097          	auipc	ra,0xffffd
    800039f6:	b66080e7          	jalr	-1178(ra) # 80000558 <panic>

00000000800039fa <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800039fa:	7179                	addi	sp,sp,-48
    800039fc:	f406                	sd	ra,40(sp)
    800039fe:	f022                	sd	s0,32(sp)
    80003a00:	ec26                	sd	s1,24(sp)
    80003a02:	e84a                	sd	s2,16(sp)
    80003a04:	e44e                	sd	s3,8(sp)
    80003a06:	e052                	sd	s4,0(sp)
    80003a08:	1800                	addi	s0,sp,48
    80003a0a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a0c:	05050493          	addi	s1,a0,80
    80003a10:	08050913          	addi	s2,a0,128
    80003a14:	a821                	j	80003a2c <itrunc+0x32>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    80003a16:	0009a503          	lw	a0,0(s3)
    80003a1a:	00000097          	auipc	ra,0x0
    80003a1e:	8e0080e7          	jalr	-1824(ra) # 800032fa <bfree>
      ip->addrs[i] = 0;
    80003a22:	0004a023          	sw	zero,0(s1)
  for(i = 0; i < NDIRECT; i++){
    80003a26:	0491                	addi	s1,s1,4
    80003a28:	01248563          	beq	s1,s2,80003a32 <itrunc+0x38>
    if(ip->addrs[i]){
    80003a2c:	408c                	lw	a1,0(s1)
    80003a2e:	dde5                	beqz	a1,80003a26 <itrunc+0x2c>
    80003a30:	b7dd                	j	80003a16 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a32:	0809a583          	lw	a1,128(s3)
    80003a36:	e185                	bnez	a1,80003a56 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a38:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a3c:	854e                	mv	a0,s3
    80003a3e:	00000097          	auipc	ra,0x0
    80003a42:	de0080e7          	jalr	-544(ra) # 8000381e <iupdate>
}
    80003a46:	70a2                	ld	ra,40(sp)
    80003a48:	7402                	ld	s0,32(sp)
    80003a4a:	64e2                	ld	s1,24(sp)
    80003a4c:	6942                	ld	s2,16(sp)
    80003a4e:	69a2                	ld	s3,8(sp)
    80003a50:	6a02                	ld	s4,0(sp)
    80003a52:	6145                	addi	sp,sp,48
    80003a54:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a56:	0009a503          	lw	a0,0(s3)
    80003a5a:	fffff097          	auipc	ra,0xfffff
    80003a5e:	648080e7          	jalr	1608(ra) # 800030a2 <bread>
    80003a62:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a64:	05850493          	addi	s1,a0,88
    80003a68:	45850913          	addi	s2,a0,1112
    80003a6c:	a811                	j	80003a80 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003a6e:	0009a503          	lw	a0,0(s3)
    80003a72:	00000097          	auipc	ra,0x0
    80003a76:	888080e7          	jalr	-1912(ra) # 800032fa <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003a7a:	0491                	addi	s1,s1,4
    80003a7c:	01248563          	beq	s1,s2,80003a86 <itrunc+0x8c>
      if(a[j])
    80003a80:	408c                	lw	a1,0(s1)
    80003a82:	dde5                	beqz	a1,80003a7a <itrunc+0x80>
    80003a84:	b7ed                	j	80003a6e <itrunc+0x74>
    brelse(bp);
    80003a86:	8552                	mv	a0,s4
    80003a88:	fffff097          	auipc	ra,0xfffff
    80003a8c:	75c080e7          	jalr	1884(ra) # 800031e4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a90:	0809a583          	lw	a1,128(s3)
    80003a94:	0009a503          	lw	a0,0(s3)
    80003a98:	00000097          	auipc	ra,0x0
    80003a9c:	862080e7          	jalr	-1950(ra) # 800032fa <bfree>
    ip->addrs[NDIRECT] = 0;
    80003aa0:	0809a023          	sw	zero,128(s3)
    80003aa4:	bf51                	j	80003a38 <itrunc+0x3e>

0000000080003aa6 <iput>:
{
    80003aa6:	1101                	addi	sp,sp,-32
    80003aa8:	ec06                	sd	ra,24(sp)
    80003aaa:	e822                	sd	s0,16(sp)
    80003aac:	e426                	sd	s1,8(sp)
    80003aae:	e04a                	sd	s2,0(sp)
    80003ab0:	1000                	addi	s0,sp,32
    80003ab2:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003ab4:	00028517          	auipc	a0,0x28
    80003ab8:	cfc50513          	addi	a0,a0,-772 # 8002b7b0 <icache>
    80003abc:	ffffd097          	auipc	ra,0xffffd
    80003ac0:	168080e7          	jalr	360(ra) # 80000c24 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ac4:	4498                	lw	a4,8(s1)
    80003ac6:	4785                	li	a5,1
    80003ac8:	02f70363          	beq	a4,a5,80003aee <iput+0x48>
  ip->ref--;
    80003acc:	449c                	lw	a5,8(s1)
    80003ace:	37fd                	addiw	a5,a5,-1
    80003ad0:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003ad2:	00028517          	auipc	a0,0x28
    80003ad6:	cde50513          	addi	a0,a0,-802 # 8002b7b0 <icache>
    80003ada:	ffffd097          	auipc	ra,0xffffd
    80003ade:	1fe080e7          	jalr	510(ra) # 80000cd8 <release>
}
    80003ae2:	60e2                	ld	ra,24(sp)
    80003ae4:	6442                	ld	s0,16(sp)
    80003ae6:	64a2                	ld	s1,8(sp)
    80003ae8:	6902                	ld	s2,0(sp)
    80003aea:	6105                	addi	sp,sp,32
    80003aec:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003aee:	40bc                	lw	a5,64(s1)
    80003af0:	dff1                	beqz	a5,80003acc <iput+0x26>
    80003af2:	04a49783          	lh	a5,74(s1)
    80003af6:	fbf9                	bnez	a5,80003acc <iput+0x26>
    acquiresleep(&ip->lock);
    80003af8:	01048913          	addi	s2,s1,16
    80003afc:	854a                	mv	a0,s2
    80003afe:	00001097          	auipc	ra,0x1
    80003b02:	ae6080e7          	jalr	-1306(ra) # 800045e4 <acquiresleep>
    release(&icache.lock);
    80003b06:	00028517          	auipc	a0,0x28
    80003b0a:	caa50513          	addi	a0,a0,-854 # 8002b7b0 <icache>
    80003b0e:	ffffd097          	auipc	ra,0xffffd
    80003b12:	1ca080e7          	jalr	458(ra) # 80000cd8 <release>
    itrunc(ip);
    80003b16:	8526                	mv	a0,s1
    80003b18:	00000097          	auipc	ra,0x0
    80003b1c:	ee2080e7          	jalr	-286(ra) # 800039fa <itrunc>
    ip->type = 0;
    80003b20:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b24:	8526                	mv	a0,s1
    80003b26:	00000097          	auipc	ra,0x0
    80003b2a:	cf8080e7          	jalr	-776(ra) # 8000381e <iupdate>
    ip->valid = 0;
    80003b2e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b32:	854a                	mv	a0,s2
    80003b34:	00001097          	auipc	ra,0x1
    80003b38:	b06080e7          	jalr	-1274(ra) # 8000463a <releasesleep>
    acquire(&icache.lock);
    80003b3c:	00028517          	auipc	a0,0x28
    80003b40:	c7450513          	addi	a0,a0,-908 # 8002b7b0 <icache>
    80003b44:	ffffd097          	auipc	ra,0xffffd
    80003b48:	0e0080e7          	jalr	224(ra) # 80000c24 <acquire>
    80003b4c:	b741                	j	80003acc <iput+0x26>

0000000080003b4e <iunlockput>:
{
    80003b4e:	1101                	addi	sp,sp,-32
    80003b50:	ec06                	sd	ra,24(sp)
    80003b52:	e822                	sd	s0,16(sp)
    80003b54:	e426                	sd	s1,8(sp)
    80003b56:	1000                	addi	s0,sp,32
    80003b58:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b5a:	00000097          	auipc	ra,0x0
    80003b5e:	e54080e7          	jalr	-428(ra) # 800039ae <iunlock>
  iput(ip);
    80003b62:	8526                	mv	a0,s1
    80003b64:	00000097          	auipc	ra,0x0
    80003b68:	f42080e7          	jalr	-190(ra) # 80003aa6 <iput>
}
    80003b6c:	60e2                	ld	ra,24(sp)
    80003b6e:	6442                	ld	s0,16(sp)
    80003b70:	64a2                	ld	s1,8(sp)
    80003b72:	6105                	addi	sp,sp,32
    80003b74:	8082                	ret

0000000080003b76 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b76:	1141                	addi	sp,sp,-16
    80003b78:	e422                	sd	s0,8(sp)
    80003b7a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b7c:	411c                	lw	a5,0(a0)
    80003b7e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b80:	415c                	lw	a5,4(a0)
    80003b82:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b84:	04451783          	lh	a5,68(a0)
    80003b88:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b8c:	04a51783          	lh	a5,74(a0)
    80003b90:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b94:	04c56783          	lwu	a5,76(a0)
    80003b98:	e99c                	sd	a5,16(a1)
}
    80003b9a:	6422                	ld	s0,8(sp)
    80003b9c:	0141                	addi	sp,sp,16
    80003b9e:	8082                	ret

0000000080003ba0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ba0:	457c                	lw	a5,76(a0)
    80003ba2:	0ed7e963          	bltu	a5,a3,80003c94 <readi+0xf4>
{
    80003ba6:	7159                	addi	sp,sp,-112
    80003ba8:	f486                	sd	ra,104(sp)
    80003baa:	f0a2                	sd	s0,96(sp)
    80003bac:	eca6                	sd	s1,88(sp)
    80003bae:	e8ca                	sd	s2,80(sp)
    80003bb0:	e4ce                	sd	s3,72(sp)
    80003bb2:	e0d2                	sd	s4,64(sp)
    80003bb4:	fc56                	sd	s5,56(sp)
    80003bb6:	f85a                	sd	s6,48(sp)
    80003bb8:	f45e                	sd	s7,40(sp)
    80003bba:	f062                	sd	s8,32(sp)
    80003bbc:	ec66                	sd	s9,24(sp)
    80003bbe:	e86a                	sd	s10,16(sp)
    80003bc0:	e46e                	sd	s11,8(sp)
    80003bc2:	1880                	addi	s0,sp,112
    80003bc4:	8baa                	mv	s7,a0
    80003bc6:	8c2e                	mv	s8,a1
    80003bc8:	8a32                	mv	s4,a2
    80003bca:	84b6                	mv	s1,a3
    80003bcc:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003bce:	9f35                	addw	a4,a4,a3
    return 0;
    80003bd0:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003bd2:	0ad76063          	bltu	a4,a3,80003c72 <readi+0xd2>
  if(off + n > ip->size)
    80003bd6:	00e7f463          	bleu	a4,a5,80003bde <readi+0x3e>
    n = ip->size - off;
    80003bda:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bde:	0a0b0963          	beqz	s6,80003c90 <readi+0xf0>
    80003be2:	4901                	li	s2,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003be4:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003be8:	5cfd                	li	s9,-1
    80003bea:	a82d                	j	80003c24 <readi+0x84>
    80003bec:	02099d93          	slli	s11,s3,0x20
    80003bf0:	020ddd93          	srli	s11,s11,0x20
    80003bf4:	058a8613          	addi	a2,s5,88
    80003bf8:	86ee                	mv	a3,s11
    80003bfa:	963a                	add	a2,a2,a4
    80003bfc:	85d2                	mv	a1,s4
    80003bfe:	8562                	mv	a0,s8
    80003c00:	fffff097          	auipc	ra,0xfffff
    80003c04:	984080e7          	jalr	-1660(ra) # 80002584 <either_copyout>
    80003c08:	05950d63          	beq	a0,s9,80003c62 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c0c:	8556                	mv	a0,s5
    80003c0e:	fffff097          	auipc	ra,0xfffff
    80003c12:	5d6080e7          	jalr	1494(ra) # 800031e4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c16:	0129893b          	addw	s2,s3,s2
    80003c1a:	009984bb          	addw	s1,s3,s1
    80003c1e:	9a6e                	add	s4,s4,s11
    80003c20:	05697763          	bleu	s6,s2,80003c6e <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c24:	000ba983          	lw	s3,0(s7)
    80003c28:	00a4d59b          	srliw	a1,s1,0xa
    80003c2c:	855e                	mv	a0,s7
    80003c2e:	00000097          	auipc	ra,0x0
    80003c32:	8ac080e7          	jalr	-1876(ra) # 800034da <bmap>
    80003c36:	0005059b          	sext.w	a1,a0
    80003c3a:	854e                	mv	a0,s3
    80003c3c:	fffff097          	auipc	ra,0xfffff
    80003c40:	466080e7          	jalr	1126(ra) # 800030a2 <bread>
    80003c44:	8aaa                	mv	s5,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c46:	3ff4f713          	andi	a4,s1,1023
    80003c4a:	40ed07bb          	subw	a5,s10,a4
    80003c4e:	412b06bb          	subw	a3,s6,s2
    80003c52:	89be                	mv	s3,a5
    80003c54:	2781                	sext.w	a5,a5
    80003c56:	0006861b          	sext.w	a2,a3
    80003c5a:	f8f679e3          	bleu	a5,a2,80003bec <readi+0x4c>
    80003c5e:	89b6                	mv	s3,a3
    80003c60:	b771                	j	80003bec <readi+0x4c>
      brelse(bp);
    80003c62:	8556                	mv	a0,s5
    80003c64:	fffff097          	auipc	ra,0xfffff
    80003c68:	580080e7          	jalr	1408(ra) # 800031e4 <brelse>
      tot = -1;
    80003c6c:	597d                	li	s2,-1
  }
  return tot;
    80003c6e:	0009051b          	sext.w	a0,s2
}
    80003c72:	70a6                	ld	ra,104(sp)
    80003c74:	7406                	ld	s0,96(sp)
    80003c76:	64e6                	ld	s1,88(sp)
    80003c78:	6946                	ld	s2,80(sp)
    80003c7a:	69a6                	ld	s3,72(sp)
    80003c7c:	6a06                	ld	s4,64(sp)
    80003c7e:	7ae2                	ld	s5,56(sp)
    80003c80:	7b42                	ld	s6,48(sp)
    80003c82:	7ba2                	ld	s7,40(sp)
    80003c84:	7c02                	ld	s8,32(sp)
    80003c86:	6ce2                	ld	s9,24(sp)
    80003c88:	6d42                	ld	s10,16(sp)
    80003c8a:	6da2                	ld	s11,8(sp)
    80003c8c:	6165                	addi	sp,sp,112
    80003c8e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c90:	895a                	mv	s2,s6
    80003c92:	bff1                	j	80003c6e <readi+0xce>
    return 0;
    80003c94:	4501                	li	a0,0
}
    80003c96:	8082                	ret

0000000080003c98 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c98:	457c                	lw	a5,76(a0)
    80003c9a:	10d7e863          	bltu	a5,a3,80003daa <writei+0x112>
{
    80003c9e:	7159                	addi	sp,sp,-112
    80003ca0:	f486                	sd	ra,104(sp)
    80003ca2:	f0a2                	sd	s0,96(sp)
    80003ca4:	eca6                	sd	s1,88(sp)
    80003ca6:	e8ca                	sd	s2,80(sp)
    80003ca8:	e4ce                	sd	s3,72(sp)
    80003caa:	e0d2                	sd	s4,64(sp)
    80003cac:	fc56                	sd	s5,56(sp)
    80003cae:	f85a                	sd	s6,48(sp)
    80003cb0:	f45e                	sd	s7,40(sp)
    80003cb2:	f062                	sd	s8,32(sp)
    80003cb4:	ec66                	sd	s9,24(sp)
    80003cb6:	e86a                	sd	s10,16(sp)
    80003cb8:	e46e                	sd	s11,8(sp)
    80003cba:	1880                	addi	s0,sp,112
    80003cbc:	8b2a                	mv	s6,a0
    80003cbe:	8c2e                	mv	s8,a1
    80003cc0:	8ab2                	mv	s5,a2
    80003cc2:	84b6                	mv	s1,a3
    80003cc4:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003cc6:	00e687bb          	addw	a5,a3,a4
    80003cca:	0ed7e263          	bltu	a5,a3,80003dae <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003cce:	00043737          	lui	a4,0x43
    80003cd2:	0ef76063          	bltu	a4,a5,80003db2 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cd6:	0c0b8863          	beqz	s7,80003da6 <writei+0x10e>
    80003cda:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cdc:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ce0:	5cfd                	li	s9,-1
    80003ce2:	a091                	j	80003d26 <writei+0x8e>
    80003ce4:	02091d93          	slli	s11,s2,0x20
    80003ce8:	020ddd93          	srli	s11,s11,0x20
    80003cec:	058a0513          	addi	a0,s4,88 # 2058 <_entry-0x7fffdfa8>
    80003cf0:	86ee                	mv	a3,s11
    80003cf2:	8656                	mv	a2,s5
    80003cf4:	85e2                	mv	a1,s8
    80003cf6:	953a                	add	a0,a0,a4
    80003cf8:	fffff097          	auipc	ra,0xfffff
    80003cfc:	8e2080e7          	jalr	-1822(ra) # 800025da <either_copyin>
    80003d00:	07950263          	beq	a0,s9,80003d64 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d04:	8552                	mv	a0,s4
    80003d06:	00000097          	auipc	ra,0x0
    80003d0a:	7a0080e7          	jalr	1952(ra) # 800044a6 <log_write>
    brelse(bp);
    80003d0e:	8552                	mv	a0,s4
    80003d10:	fffff097          	auipc	ra,0xfffff
    80003d14:	4d4080e7          	jalr	1236(ra) # 800031e4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d18:	013909bb          	addw	s3,s2,s3
    80003d1c:	009904bb          	addw	s1,s2,s1
    80003d20:	9aee                	add	s5,s5,s11
    80003d22:	0579f663          	bleu	s7,s3,80003d6e <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d26:	000b2903          	lw	s2,0(s6)
    80003d2a:	00a4d59b          	srliw	a1,s1,0xa
    80003d2e:	855a                	mv	a0,s6
    80003d30:	fffff097          	auipc	ra,0xfffff
    80003d34:	7aa080e7          	jalr	1962(ra) # 800034da <bmap>
    80003d38:	0005059b          	sext.w	a1,a0
    80003d3c:	854a                	mv	a0,s2
    80003d3e:	fffff097          	auipc	ra,0xfffff
    80003d42:	364080e7          	jalr	868(ra) # 800030a2 <bread>
    80003d46:	8a2a                	mv	s4,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d48:	3ff4f713          	andi	a4,s1,1023
    80003d4c:	40ed07bb          	subw	a5,s10,a4
    80003d50:	413b86bb          	subw	a3,s7,s3
    80003d54:	893e                	mv	s2,a5
    80003d56:	2781                	sext.w	a5,a5
    80003d58:	0006861b          	sext.w	a2,a3
    80003d5c:	f8f674e3          	bleu	a5,a2,80003ce4 <writei+0x4c>
    80003d60:	8936                	mv	s2,a3
    80003d62:	b749                	j	80003ce4 <writei+0x4c>
      brelse(bp);
    80003d64:	8552                	mv	a0,s4
    80003d66:	fffff097          	auipc	ra,0xfffff
    80003d6a:	47e080e7          	jalr	1150(ra) # 800031e4 <brelse>
  }

  if(off > ip->size)
    80003d6e:	04cb2783          	lw	a5,76(s6)
    80003d72:	0097f463          	bleu	s1,a5,80003d7a <writei+0xe2>
    ip->size = off;
    80003d76:	049b2623          	sw	s1,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d7a:	855a                	mv	a0,s6
    80003d7c:	00000097          	auipc	ra,0x0
    80003d80:	aa2080e7          	jalr	-1374(ra) # 8000381e <iupdate>

  return tot;
    80003d84:	0009851b          	sext.w	a0,s3
}
    80003d88:	70a6                	ld	ra,104(sp)
    80003d8a:	7406                	ld	s0,96(sp)
    80003d8c:	64e6                	ld	s1,88(sp)
    80003d8e:	6946                	ld	s2,80(sp)
    80003d90:	69a6                	ld	s3,72(sp)
    80003d92:	6a06                	ld	s4,64(sp)
    80003d94:	7ae2                	ld	s5,56(sp)
    80003d96:	7b42                	ld	s6,48(sp)
    80003d98:	7ba2                	ld	s7,40(sp)
    80003d9a:	7c02                	ld	s8,32(sp)
    80003d9c:	6ce2                	ld	s9,24(sp)
    80003d9e:	6d42                	ld	s10,16(sp)
    80003da0:	6da2                	ld	s11,8(sp)
    80003da2:	6165                	addi	sp,sp,112
    80003da4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003da6:	89de                	mv	s3,s7
    80003da8:	bfc9                	j	80003d7a <writei+0xe2>
    return -1;
    80003daa:	557d                	li	a0,-1
}
    80003dac:	8082                	ret
    return -1;
    80003dae:	557d                	li	a0,-1
    80003db0:	bfe1                	j	80003d88 <writei+0xf0>
    return -1;
    80003db2:	557d                	li	a0,-1
    80003db4:	bfd1                	j	80003d88 <writei+0xf0>

0000000080003db6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003db6:	1141                	addi	sp,sp,-16
    80003db8:	e406                	sd	ra,8(sp)
    80003dba:	e022                	sd	s0,0(sp)
    80003dbc:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003dbe:	4639                	li	a2,14
    80003dc0:	ffffd097          	auipc	ra,0xffffd
    80003dc4:	048080e7          	jalr	72(ra) # 80000e08 <strncmp>
}
    80003dc8:	60a2                	ld	ra,8(sp)
    80003dca:	6402                	ld	s0,0(sp)
    80003dcc:	0141                	addi	sp,sp,16
    80003dce:	8082                	ret

0000000080003dd0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003dd0:	7139                	addi	sp,sp,-64
    80003dd2:	fc06                	sd	ra,56(sp)
    80003dd4:	f822                	sd	s0,48(sp)
    80003dd6:	f426                	sd	s1,40(sp)
    80003dd8:	f04a                	sd	s2,32(sp)
    80003dda:	ec4e                	sd	s3,24(sp)
    80003ddc:	e852                	sd	s4,16(sp)
    80003dde:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003de0:	04451703          	lh	a4,68(a0)
    80003de4:	4785                	li	a5,1
    80003de6:	00f71a63          	bne	a4,a5,80003dfa <dirlookup+0x2a>
    80003dea:	892a                	mv	s2,a0
    80003dec:	89ae                	mv	s3,a1
    80003dee:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003df0:	457c                	lw	a5,76(a0)
    80003df2:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003df4:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003df6:	e79d                	bnez	a5,80003e24 <dirlookup+0x54>
    80003df8:	a8a5                	j	80003e70 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003dfa:	00004517          	auipc	a0,0x4
    80003dfe:	79e50513          	addi	a0,a0,1950 # 80008598 <syscalls+0x1d8>
    80003e02:	ffffc097          	auipc	ra,0xffffc
    80003e06:	756080e7          	jalr	1878(ra) # 80000558 <panic>
      panic("dirlookup read");
    80003e0a:	00004517          	auipc	a0,0x4
    80003e0e:	7a650513          	addi	a0,a0,1958 # 800085b0 <syscalls+0x1f0>
    80003e12:	ffffc097          	auipc	ra,0xffffc
    80003e16:	746080e7          	jalr	1862(ra) # 80000558 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e1a:	24c1                	addiw	s1,s1,16
    80003e1c:	04c92783          	lw	a5,76(s2)
    80003e20:	04f4f763          	bleu	a5,s1,80003e6e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e24:	4741                	li	a4,16
    80003e26:	86a6                	mv	a3,s1
    80003e28:	fc040613          	addi	a2,s0,-64
    80003e2c:	4581                	li	a1,0
    80003e2e:	854a                	mv	a0,s2
    80003e30:	00000097          	auipc	ra,0x0
    80003e34:	d70080e7          	jalr	-656(ra) # 80003ba0 <readi>
    80003e38:	47c1                	li	a5,16
    80003e3a:	fcf518e3          	bne	a0,a5,80003e0a <dirlookup+0x3a>
    if(de.inum == 0)
    80003e3e:	fc045783          	lhu	a5,-64(s0)
    80003e42:	dfe1                	beqz	a5,80003e1a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e44:	fc240593          	addi	a1,s0,-62
    80003e48:	854e                	mv	a0,s3
    80003e4a:	00000097          	auipc	ra,0x0
    80003e4e:	f6c080e7          	jalr	-148(ra) # 80003db6 <namecmp>
    80003e52:	f561                	bnez	a0,80003e1a <dirlookup+0x4a>
      if(poff)
    80003e54:	000a0463          	beqz	s4,80003e5c <dirlookup+0x8c>
        *poff = off;
    80003e58:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e5c:	fc045583          	lhu	a1,-64(s0)
    80003e60:	00092503          	lw	a0,0(s2)
    80003e64:	fffff097          	auipc	ra,0xfffff
    80003e68:	750080e7          	jalr	1872(ra) # 800035b4 <iget>
    80003e6c:	a011                	j	80003e70 <dirlookup+0xa0>
  return 0;
    80003e6e:	4501                	li	a0,0
}
    80003e70:	70e2                	ld	ra,56(sp)
    80003e72:	7442                	ld	s0,48(sp)
    80003e74:	74a2                	ld	s1,40(sp)
    80003e76:	7902                	ld	s2,32(sp)
    80003e78:	69e2                	ld	s3,24(sp)
    80003e7a:	6a42                	ld	s4,16(sp)
    80003e7c:	6121                	addi	sp,sp,64
    80003e7e:	8082                	ret

0000000080003e80 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e80:	711d                	addi	sp,sp,-96
    80003e82:	ec86                	sd	ra,88(sp)
    80003e84:	e8a2                	sd	s0,80(sp)
    80003e86:	e4a6                	sd	s1,72(sp)
    80003e88:	e0ca                	sd	s2,64(sp)
    80003e8a:	fc4e                	sd	s3,56(sp)
    80003e8c:	f852                	sd	s4,48(sp)
    80003e8e:	f456                	sd	s5,40(sp)
    80003e90:	f05a                	sd	s6,32(sp)
    80003e92:	ec5e                	sd	s7,24(sp)
    80003e94:	e862                	sd	s8,16(sp)
    80003e96:	e466                	sd	s9,8(sp)
    80003e98:	1080                	addi	s0,sp,96
    80003e9a:	84aa                	mv	s1,a0
    80003e9c:	8bae                	mv	s7,a1
    80003e9e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ea0:	00054703          	lbu	a4,0(a0)
    80003ea4:	02f00793          	li	a5,47
    80003ea8:	02f70363          	beq	a4,a5,80003ece <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003eac:	ffffe097          	auipc	ra,0xffffe
    80003eb0:	b80080e7          	jalr	-1152(ra) # 80001a2c <myproc>
    80003eb4:	15053503          	ld	a0,336(a0)
    80003eb8:	00000097          	auipc	ra,0x0
    80003ebc:	9f4080e7          	jalr	-1548(ra) # 800038ac <idup>
    80003ec0:	89aa                	mv	s3,a0
  while(*path == '/')
    80003ec2:	02f00913          	li	s2,47
  len = path - s;
    80003ec6:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003ec8:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003eca:	4c05                	li	s8,1
    80003ecc:	a865                	j	80003f84 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003ece:	4585                	li	a1,1
    80003ed0:	4505                	li	a0,1
    80003ed2:	fffff097          	auipc	ra,0xfffff
    80003ed6:	6e2080e7          	jalr	1762(ra) # 800035b4 <iget>
    80003eda:	89aa                	mv	s3,a0
    80003edc:	b7dd                	j	80003ec2 <namex+0x42>
      iunlockput(ip);
    80003ede:	854e                	mv	a0,s3
    80003ee0:	00000097          	auipc	ra,0x0
    80003ee4:	c6e080e7          	jalr	-914(ra) # 80003b4e <iunlockput>
      return 0;
    80003ee8:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003eea:	854e                	mv	a0,s3
    80003eec:	60e6                	ld	ra,88(sp)
    80003eee:	6446                	ld	s0,80(sp)
    80003ef0:	64a6                	ld	s1,72(sp)
    80003ef2:	6906                	ld	s2,64(sp)
    80003ef4:	79e2                	ld	s3,56(sp)
    80003ef6:	7a42                	ld	s4,48(sp)
    80003ef8:	7aa2                	ld	s5,40(sp)
    80003efa:	7b02                	ld	s6,32(sp)
    80003efc:	6be2                	ld	s7,24(sp)
    80003efe:	6c42                	ld	s8,16(sp)
    80003f00:	6ca2                	ld	s9,8(sp)
    80003f02:	6125                	addi	sp,sp,96
    80003f04:	8082                	ret
      iunlock(ip);
    80003f06:	854e                	mv	a0,s3
    80003f08:	00000097          	auipc	ra,0x0
    80003f0c:	aa6080e7          	jalr	-1370(ra) # 800039ae <iunlock>
      return ip;
    80003f10:	bfe9                	j	80003eea <namex+0x6a>
      iunlockput(ip);
    80003f12:	854e                	mv	a0,s3
    80003f14:	00000097          	auipc	ra,0x0
    80003f18:	c3a080e7          	jalr	-966(ra) # 80003b4e <iunlockput>
      return 0;
    80003f1c:	89d2                	mv	s3,s4
    80003f1e:	b7f1                	j	80003eea <namex+0x6a>
  len = path - s;
    80003f20:	40b48633          	sub	a2,s1,a1
    80003f24:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003f28:	094cd663          	ble	s4,s9,80003fb4 <namex+0x134>
    memmove(name, s, DIRSIZ);
    80003f2c:	4639                	li	a2,14
    80003f2e:	8556                	mv	a0,s5
    80003f30:	ffffd097          	auipc	ra,0xffffd
    80003f34:	e5c080e7          	jalr	-420(ra) # 80000d8c <memmove>
  while(*path == '/')
    80003f38:	0004c783          	lbu	a5,0(s1)
    80003f3c:	01279763          	bne	a5,s2,80003f4a <namex+0xca>
    path++;
    80003f40:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f42:	0004c783          	lbu	a5,0(s1)
    80003f46:	ff278de3          	beq	a5,s2,80003f40 <namex+0xc0>
    ilock(ip);
    80003f4a:	854e                	mv	a0,s3
    80003f4c:	00000097          	auipc	ra,0x0
    80003f50:	99e080e7          	jalr	-1634(ra) # 800038ea <ilock>
    if(ip->type != T_DIR){
    80003f54:	04499783          	lh	a5,68(s3)
    80003f58:	f98793e3          	bne	a5,s8,80003ede <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003f5c:	000b8563          	beqz	s7,80003f66 <namex+0xe6>
    80003f60:	0004c783          	lbu	a5,0(s1)
    80003f64:	d3cd                	beqz	a5,80003f06 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f66:	865a                	mv	a2,s6
    80003f68:	85d6                	mv	a1,s5
    80003f6a:	854e                	mv	a0,s3
    80003f6c:	00000097          	auipc	ra,0x0
    80003f70:	e64080e7          	jalr	-412(ra) # 80003dd0 <dirlookup>
    80003f74:	8a2a                	mv	s4,a0
    80003f76:	dd51                	beqz	a0,80003f12 <namex+0x92>
    iunlockput(ip);
    80003f78:	854e                	mv	a0,s3
    80003f7a:	00000097          	auipc	ra,0x0
    80003f7e:	bd4080e7          	jalr	-1068(ra) # 80003b4e <iunlockput>
    ip = next;
    80003f82:	89d2                	mv	s3,s4
  while(*path == '/')
    80003f84:	0004c783          	lbu	a5,0(s1)
    80003f88:	05279d63          	bne	a5,s2,80003fe2 <namex+0x162>
    path++;
    80003f8c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f8e:	0004c783          	lbu	a5,0(s1)
    80003f92:	ff278de3          	beq	a5,s2,80003f8c <namex+0x10c>
  if(*path == 0)
    80003f96:	cf8d                	beqz	a5,80003fd0 <namex+0x150>
  while(*path != '/' && *path != 0)
    80003f98:	01278b63          	beq	a5,s2,80003fae <namex+0x12e>
    80003f9c:	c795                	beqz	a5,80003fc8 <namex+0x148>
    path++;
    80003f9e:	85a6                	mv	a1,s1
    path++;
    80003fa0:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003fa2:	0004c783          	lbu	a5,0(s1)
    80003fa6:	f7278de3          	beq	a5,s2,80003f20 <namex+0xa0>
    80003faa:	fbfd                	bnez	a5,80003fa0 <namex+0x120>
    80003fac:	bf95                	j	80003f20 <namex+0xa0>
    80003fae:	85a6                	mv	a1,s1
  len = path - s;
    80003fb0:	8a5a                	mv	s4,s6
    80003fb2:	865a                	mv	a2,s6
    memmove(name, s, len);
    80003fb4:	2601                	sext.w	a2,a2
    80003fb6:	8556                	mv	a0,s5
    80003fb8:	ffffd097          	auipc	ra,0xffffd
    80003fbc:	dd4080e7          	jalr	-556(ra) # 80000d8c <memmove>
    name[len] = 0;
    80003fc0:	9a56                	add	s4,s4,s5
    80003fc2:	000a0023          	sb	zero,0(s4)
    80003fc6:	bf8d                	j	80003f38 <namex+0xb8>
  while(*path != '/' && *path != 0)
    80003fc8:	85a6                	mv	a1,s1
  len = path - s;
    80003fca:	8a5a                	mv	s4,s6
    80003fcc:	865a                	mv	a2,s6
    80003fce:	b7dd                	j	80003fb4 <namex+0x134>
  if(nameiparent){
    80003fd0:	f00b8de3          	beqz	s7,80003eea <namex+0x6a>
    iput(ip);
    80003fd4:	854e                	mv	a0,s3
    80003fd6:	00000097          	auipc	ra,0x0
    80003fda:	ad0080e7          	jalr	-1328(ra) # 80003aa6 <iput>
    return 0;
    80003fde:	4981                	li	s3,0
    80003fe0:	b729                	j	80003eea <namex+0x6a>
  if(*path == 0)
    80003fe2:	d7fd                	beqz	a5,80003fd0 <namex+0x150>
    80003fe4:	85a6                	mv	a1,s1
    80003fe6:	bf6d                	j	80003fa0 <namex+0x120>

0000000080003fe8 <dirlink>:
{
    80003fe8:	7139                	addi	sp,sp,-64
    80003fea:	fc06                	sd	ra,56(sp)
    80003fec:	f822                	sd	s0,48(sp)
    80003fee:	f426                	sd	s1,40(sp)
    80003ff0:	f04a                	sd	s2,32(sp)
    80003ff2:	ec4e                	sd	s3,24(sp)
    80003ff4:	e852                	sd	s4,16(sp)
    80003ff6:	0080                	addi	s0,sp,64
    80003ff8:	892a                	mv	s2,a0
    80003ffa:	8a2e                	mv	s4,a1
    80003ffc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ffe:	4601                	li	a2,0
    80004000:	00000097          	auipc	ra,0x0
    80004004:	dd0080e7          	jalr	-560(ra) # 80003dd0 <dirlookup>
    80004008:	e93d                	bnez	a0,8000407e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000400a:	04c92483          	lw	s1,76(s2)
    8000400e:	c49d                	beqz	s1,8000403c <dirlink+0x54>
    80004010:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004012:	4741                	li	a4,16
    80004014:	86a6                	mv	a3,s1
    80004016:	fc040613          	addi	a2,s0,-64
    8000401a:	4581                	li	a1,0
    8000401c:	854a                	mv	a0,s2
    8000401e:	00000097          	auipc	ra,0x0
    80004022:	b82080e7          	jalr	-1150(ra) # 80003ba0 <readi>
    80004026:	47c1                	li	a5,16
    80004028:	06f51163          	bne	a0,a5,8000408a <dirlink+0xa2>
    if(de.inum == 0)
    8000402c:	fc045783          	lhu	a5,-64(s0)
    80004030:	c791                	beqz	a5,8000403c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004032:	24c1                	addiw	s1,s1,16
    80004034:	04c92783          	lw	a5,76(s2)
    80004038:	fcf4ede3          	bltu	s1,a5,80004012 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000403c:	4639                	li	a2,14
    8000403e:	85d2                	mv	a1,s4
    80004040:	fc240513          	addi	a0,s0,-62
    80004044:	ffffd097          	auipc	ra,0xffffd
    80004048:	e14080e7          	jalr	-492(ra) # 80000e58 <strncpy>
  de.inum = inum;
    8000404c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004050:	4741                	li	a4,16
    80004052:	86a6                	mv	a3,s1
    80004054:	fc040613          	addi	a2,s0,-64
    80004058:	4581                	li	a1,0
    8000405a:	854a                	mv	a0,s2
    8000405c:	00000097          	auipc	ra,0x0
    80004060:	c3c080e7          	jalr	-964(ra) # 80003c98 <writei>
    80004064:	4741                	li	a4,16
  return 0;
    80004066:	4781                	li	a5,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004068:	02e51963          	bne	a0,a4,8000409a <dirlink+0xb2>
}
    8000406c:	853e                	mv	a0,a5
    8000406e:	70e2                	ld	ra,56(sp)
    80004070:	7442                	ld	s0,48(sp)
    80004072:	74a2                	ld	s1,40(sp)
    80004074:	7902                	ld	s2,32(sp)
    80004076:	69e2                	ld	s3,24(sp)
    80004078:	6a42                	ld	s4,16(sp)
    8000407a:	6121                	addi	sp,sp,64
    8000407c:	8082                	ret
    iput(ip);
    8000407e:	00000097          	auipc	ra,0x0
    80004082:	a28080e7          	jalr	-1496(ra) # 80003aa6 <iput>
    return -1;
    80004086:	57fd                	li	a5,-1
    80004088:	b7d5                	j	8000406c <dirlink+0x84>
      panic("dirlink read");
    8000408a:	00004517          	auipc	a0,0x4
    8000408e:	53650513          	addi	a0,a0,1334 # 800085c0 <syscalls+0x200>
    80004092:	ffffc097          	auipc	ra,0xffffc
    80004096:	4c6080e7          	jalr	1222(ra) # 80000558 <panic>
    panic("dirlink");
    8000409a:	00004517          	auipc	a0,0x4
    8000409e:	63650513          	addi	a0,a0,1590 # 800086d0 <syscalls+0x310>
    800040a2:	ffffc097          	auipc	ra,0xffffc
    800040a6:	4b6080e7          	jalr	1206(ra) # 80000558 <panic>

00000000800040aa <namei>:

struct inode*
namei(char *path)
{
    800040aa:	1101                	addi	sp,sp,-32
    800040ac:	ec06                	sd	ra,24(sp)
    800040ae:	e822                	sd	s0,16(sp)
    800040b0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040b2:	fe040613          	addi	a2,s0,-32
    800040b6:	4581                	li	a1,0
    800040b8:	00000097          	auipc	ra,0x0
    800040bc:	dc8080e7          	jalr	-568(ra) # 80003e80 <namex>
}
    800040c0:	60e2                	ld	ra,24(sp)
    800040c2:	6442                	ld	s0,16(sp)
    800040c4:	6105                	addi	sp,sp,32
    800040c6:	8082                	ret

00000000800040c8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040c8:	1141                	addi	sp,sp,-16
    800040ca:	e406                	sd	ra,8(sp)
    800040cc:	e022                	sd	s0,0(sp)
    800040ce:	0800                	addi	s0,sp,16
  return namex(path, 1, name);
    800040d0:	862e                	mv	a2,a1
    800040d2:	4585                	li	a1,1
    800040d4:	00000097          	auipc	ra,0x0
    800040d8:	dac080e7          	jalr	-596(ra) # 80003e80 <namex>
}
    800040dc:	60a2                	ld	ra,8(sp)
    800040de:	6402                	ld	s0,0(sp)
    800040e0:	0141                	addi	sp,sp,16
    800040e2:	8082                	ret

00000000800040e4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040e4:	1101                	addi	sp,sp,-32
    800040e6:	ec06                	sd	ra,24(sp)
    800040e8:	e822                	sd	s0,16(sp)
    800040ea:	e426                	sd	s1,8(sp)
    800040ec:	e04a                	sd	s2,0(sp)
    800040ee:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800040f0:	00029917          	auipc	s2,0x29
    800040f4:	16890913          	addi	s2,s2,360 # 8002d258 <log>
    800040f8:	01892583          	lw	a1,24(s2)
    800040fc:	02892503          	lw	a0,40(s2)
    80004100:	fffff097          	auipc	ra,0xfffff
    80004104:	fa2080e7          	jalr	-94(ra) # 800030a2 <bread>
    80004108:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000410a:	02c92683          	lw	a3,44(s2)
    8000410e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004110:	02d05763          	blez	a3,8000413e <write_head+0x5a>
    80004114:	00029797          	auipc	a5,0x29
    80004118:	17478793          	addi	a5,a5,372 # 8002d288 <log+0x30>
    8000411c:	05c50713          	addi	a4,a0,92
    80004120:	36fd                	addiw	a3,a3,-1
    80004122:	1682                	slli	a3,a3,0x20
    80004124:	9281                	srli	a3,a3,0x20
    80004126:	068a                	slli	a3,a3,0x2
    80004128:	00029617          	auipc	a2,0x29
    8000412c:	16460613          	addi	a2,a2,356 # 8002d28c <log+0x34>
    80004130:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004132:	4390                	lw	a2,0(a5)
    80004134:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004136:	0791                	addi	a5,a5,4
    80004138:	0711                	addi	a4,a4,4
    8000413a:	fed79ce3          	bne	a5,a3,80004132 <write_head+0x4e>
  }
  bwrite(buf);
    8000413e:	8526                	mv	a0,s1
    80004140:	fffff097          	auipc	ra,0xfffff
    80004144:	066080e7          	jalr	102(ra) # 800031a6 <bwrite>
  brelse(buf);
    80004148:	8526                	mv	a0,s1
    8000414a:	fffff097          	auipc	ra,0xfffff
    8000414e:	09a080e7          	jalr	154(ra) # 800031e4 <brelse>
}
    80004152:	60e2                	ld	ra,24(sp)
    80004154:	6442                	ld	s0,16(sp)
    80004156:	64a2                	ld	s1,8(sp)
    80004158:	6902                	ld	s2,0(sp)
    8000415a:	6105                	addi	sp,sp,32
    8000415c:	8082                	ret

000000008000415e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000415e:	00029797          	auipc	a5,0x29
    80004162:	0fa78793          	addi	a5,a5,250 # 8002d258 <log>
    80004166:	57dc                	lw	a5,44(a5)
    80004168:	0af05d63          	blez	a5,80004222 <install_trans+0xc4>
{
    8000416c:	7139                	addi	sp,sp,-64
    8000416e:	fc06                	sd	ra,56(sp)
    80004170:	f822                	sd	s0,48(sp)
    80004172:	f426                	sd	s1,40(sp)
    80004174:	f04a                	sd	s2,32(sp)
    80004176:	ec4e                	sd	s3,24(sp)
    80004178:	e852                	sd	s4,16(sp)
    8000417a:	e456                	sd	s5,8(sp)
    8000417c:	e05a                	sd	s6,0(sp)
    8000417e:	0080                	addi	s0,sp,64
    80004180:	8b2a                	mv	s6,a0
    80004182:	00029a17          	auipc	s4,0x29
    80004186:	106a0a13          	addi	s4,s4,262 # 8002d288 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000418a:	4981                	li	s3,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000418c:	00029917          	auipc	s2,0x29
    80004190:	0cc90913          	addi	s2,s2,204 # 8002d258 <log>
    80004194:	a035                	j	800041c0 <install_trans+0x62>
      bunpin(dbuf);
    80004196:	8526                	mv	a0,s1
    80004198:	fffff097          	auipc	ra,0xfffff
    8000419c:	126080e7          	jalr	294(ra) # 800032be <bunpin>
    brelse(lbuf);
    800041a0:	8556                	mv	a0,s5
    800041a2:	fffff097          	auipc	ra,0xfffff
    800041a6:	042080e7          	jalr	66(ra) # 800031e4 <brelse>
    brelse(dbuf);
    800041aa:	8526                	mv	a0,s1
    800041ac:	fffff097          	auipc	ra,0xfffff
    800041b0:	038080e7          	jalr	56(ra) # 800031e4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041b4:	2985                	addiw	s3,s3,1
    800041b6:	0a11                	addi	s4,s4,4
    800041b8:	02c92783          	lw	a5,44(s2)
    800041bc:	04f9d963          	ble	a5,s3,8000420e <install_trans+0xb0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041c0:	01892583          	lw	a1,24(s2)
    800041c4:	013585bb          	addw	a1,a1,s3
    800041c8:	2585                	addiw	a1,a1,1
    800041ca:	02892503          	lw	a0,40(s2)
    800041ce:	fffff097          	auipc	ra,0xfffff
    800041d2:	ed4080e7          	jalr	-300(ra) # 800030a2 <bread>
    800041d6:	8aaa                	mv	s5,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041d8:	000a2583          	lw	a1,0(s4)
    800041dc:	02892503          	lw	a0,40(s2)
    800041e0:	fffff097          	auipc	ra,0xfffff
    800041e4:	ec2080e7          	jalr	-318(ra) # 800030a2 <bread>
    800041e8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041ea:	40000613          	li	a2,1024
    800041ee:	058a8593          	addi	a1,s5,88
    800041f2:	05850513          	addi	a0,a0,88
    800041f6:	ffffd097          	auipc	ra,0xffffd
    800041fa:	b96080e7          	jalr	-1130(ra) # 80000d8c <memmove>
    bwrite(dbuf);  // write dst to disk
    800041fe:	8526                	mv	a0,s1
    80004200:	fffff097          	auipc	ra,0xfffff
    80004204:	fa6080e7          	jalr	-90(ra) # 800031a6 <bwrite>
    if(recovering == 0)
    80004208:	f80b1ce3          	bnez	s6,800041a0 <install_trans+0x42>
    8000420c:	b769                	j	80004196 <install_trans+0x38>
}
    8000420e:	70e2                	ld	ra,56(sp)
    80004210:	7442                	ld	s0,48(sp)
    80004212:	74a2                	ld	s1,40(sp)
    80004214:	7902                	ld	s2,32(sp)
    80004216:	69e2                	ld	s3,24(sp)
    80004218:	6a42                	ld	s4,16(sp)
    8000421a:	6aa2                	ld	s5,8(sp)
    8000421c:	6b02                	ld	s6,0(sp)
    8000421e:	6121                	addi	sp,sp,64
    80004220:	8082                	ret
    80004222:	8082                	ret

0000000080004224 <initlog>:
{
    80004224:	7179                	addi	sp,sp,-48
    80004226:	f406                	sd	ra,40(sp)
    80004228:	f022                	sd	s0,32(sp)
    8000422a:	ec26                	sd	s1,24(sp)
    8000422c:	e84a                	sd	s2,16(sp)
    8000422e:	e44e                	sd	s3,8(sp)
    80004230:	1800                	addi	s0,sp,48
    80004232:	892a                	mv	s2,a0
    80004234:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004236:	00029497          	auipc	s1,0x29
    8000423a:	02248493          	addi	s1,s1,34 # 8002d258 <log>
    8000423e:	00004597          	auipc	a1,0x4
    80004242:	39258593          	addi	a1,a1,914 # 800085d0 <syscalls+0x210>
    80004246:	8526                	mv	a0,s1
    80004248:	ffffd097          	auipc	ra,0xffffd
    8000424c:	94c080e7          	jalr	-1716(ra) # 80000b94 <initlock>
  log.start = sb->logstart;
    80004250:	0149a583          	lw	a1,20(s3)
    80004254:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004256:	0109a783          	lw	a5,16(s3)
    8000425a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000425c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004260:	854a                	mv	a0,s2
    80004262:	fffff097          	auipc	ra,0xfffff
    80004266:	e40080e7          	jalr	-448(ra) # 800030a2 <bread>
  log.lh.n = lh->n;
    8000426a:	4d3c                	lw	a5,88(a0)
    8000426c:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000426e:	02f05563          	blez	a5,80004298 <initlog+0x74>
    80004272:	05c50713          	addi	a4,a0,92
    80004276:	00029697          	auipc	a3,0x29
    8000427a:	01268693          	addi	a3,a3,18 # 8002d288 <log+0x30>
    8000427e:	37fd                	addiw	a5,a5,-1
    80004280:	1782                	slli	a5,a5,0x20
    80004282:	9381                	srli	a5,a5,0x20
    80004284:	078a                	slli	a5,a5,0x2
    80004286:	06050613          	addi	a2,a0,96
    8000428a:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    8000428c:	4310                	lw	a2,0(a4)
    8000428e:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004290:	0711                	addi	a4,a4,4
    80004292:	0691                	addi	a3,a3,4
    80004294:	fef71ce3          	bne	a4,a5,8000428c <initlog+0x68>
  brelse(buf);
    80004298:	fffff097          	auipc	ra,0xfffff
    8000429c:	f4c080e7          	jalr	-180(ra) # 800031e4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800042a0:	4505                	li	a0,1
    800042a2:	00000097          	auipc	ra,0x0
    800042a6:	ebc080e7          	jalr	-324(ra) # 8000415e <install_trans>
  log.lh.n = 0;
    800042aa:	00029797          	auipc	a5,0x29
    800042ae:	fc07ad23          	sw	zero,-38(a5) # 8002d284 <log+0x2c>
  write_head(); // clear the log
    800042b2:	00000097          	auipc	ra,0x0
    800042b6:	e32080e7          	jalr	-462(ra) # 800040e4 <write_head>
}
    800042ba:	70a2                	ld	ra,40(sp)
    800042bc:	7402                	ld	s0,32(sp)
    800042be:	64e2                	ld	s1,24(sp)
    800042c0:	6942                	ld	s2,16(sp)
    800042c2:	69a2                	ld	s3,8(sp)
    800042c4:	6145                	addi	sp,sp,48
    800042c6:	8082                	ret

00000000800042c8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042c8:	1101                	addi	sp,sp,-32
    800042ca:	ec06                	sd	ra,24(sp)
    800042cc:	e822                	sd	s0,16(sp)
    800042ce:	e426                	sd	s1,8(sp)
    800042d0:	e04a                	sd	s2,0(sp)
    800042d2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042d4:	00029517          	auipc	a0,0x29
    800042d8:	f8450513          	addi	a0,a0,-124 # 8002d258 <log>
    800042dc:	ffffd097          	auipc	ra,0xffffd
    800042e0:	948080e7          	jalr	-1720(ra) # 80000c24 <acquire>
  while(1){
    if(log.committing){
    800042e4:	00029497          	auipc	s1,0x29
    800042e8:	f7448493          	addi	s1,s1,-140 # 8002d258 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042ec:	4979                	li	s2,30
    800042ee:	a039                	j	800042fc <begin_op+0x34>
      sleep(&log, &log.lock);
    800042f0:	85a6                	mv	a1,s1
    800042f2:	8526                	mv	a0,s1
    800042f4:	ffffe097          	auipc	ra,0xffffe
    800042f8:	02e080e7          	jalr	46(ra) # 80002322 <sleep>
    if(log.committing){
    800042fc:	50dc                	lw	a5,36(s1)
    800042fe:	fbed                	bnez	a5,800042f0 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004300:	509c                	lw	a5,32(s1)
    80004302:	0017871b          	addiw	a4,a5,1
    80004306:	0007069b          	sext.w	a3,a4
    8000430a:	0027179b          	slliw	a5,a4,0x2
    8000430e:	9fb9                	addw	a5,a5,a4
    80004310:	0017979b          	slliw	a5,a5,0x1
    80004314:	54d8                	lw	a4,44(s1)
    80004316:	9fb9                	addw	a5,a5,a4
    80004318:	00f95963          	ble	a5,s2,8000432a <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000431c:	85a6                	mv	a1,s1
    8000431e:	8526                	mv	a0,s1
    80004320:	ffffe097          	auipc	ra,0xffffe
    80004324:	002080e7          	jalr	2(ra) # 80002322 <sleep>
    80004328:	bfd1                	j	800042fc <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000432a:	00029517          	auipc	a0,0x29
    8000432e:	f2e50513          	addi	a0,a0,-210 # 8002d258 <log>
    80004332:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004334:	ffffd097          	auipc	ra,0xffffd
    80004338:	9a4080e7          	jalr	-1628(ra) # 80000cd8 <release>
      break;
    }
  }
}
    8000433c:	60e2                	ld	ra,24(sp)
    8000433e:	6442                	ld	s0,16(sp)
    80004340:	64a2                	ld	s1,8(sp)
    80004342:	6902                	ld	s2,0(sp)
    80004344:	6105                	addi	sp,sp,32
    80004346:	8082                	ret

0000000080004348 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004348:	7139                	addi	sp,sp,-64
    8000434a:	fc06                	sd	ra,56(sp)
    8000434c:	f822                	sd	s0,48(sp)
    8000434e:	f426                	sd	s1,40(sp)
    80004350:	f04a                	sd	s2,32(sp)
    80004352:	ec4e                	sd	s3,24(sp)
    80004354:	e852                	sd	s4,16(sp)
    80004356:	e456                	sd	s5,8(sp)
    80004358:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000435a:	00029917          	auipc	s2,0x29
    8000435e:	efe90913          	addi	s2,s2,-258 # 8002d258 <log>
    80004362:	854a                	mv	a0,s2
    80004364:	ffffd097          	auipc	ra,0xffffd
    80004368:	8c0080e7          	jalr	-1856(ra) # 80000c24 <acquire>
  log.outstanding -= 1;
    8000436c:	02092783          	lw	a5,32(s2)
    80004370:	37fd                	addiw	a5,a5,-1
    80004372:	0007849b          	sext.w	s1,a5
    80004376:	02f92023          	sw	a5,32(s2)
  if(log.committing)
    8000437a:	02492783          	lw	a5,36(s2)
    8000437e:	eba1                	bnez	a5,800043ce <end_op+0x86>
    panic("log.committing");
  if(log.outstanding == 0){
    80004380:	ecb9                	bnez	s1,800043de <end_op+0x96>
    do_commit = 1;
    log.committing = 1;
    80004382:	00029917          	auipc	s2,0x29
    80004386:	ed690913          	addi	s2,s2,-298 # 8002d258 <log>
    8000438a:	4785                	li	a5,1
    8000438c:	02f92223          	sw	a5,36(s2)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004390:	854a                	mv	a0,s2
    80004392:	ffffd097          	auipc	ra,0xffffd
    80004396:	946080e7          	jalr	-1722(ra) # 80000cd8 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000439a:	02c92783          	lw	a5,44(s2)
    8000439e:	06f04763          	bgtz	a5,8000440c <end_op+0xc4>
    acquire(&log.lock);
    800043a2:	00029497          	auipc	s1,0x29
    800043a6:	eb648493          	addi	s1,s1,-330 # 8002d258 <log>
    800043aa:	8526                	mv	a0,s1
    800043ac:	ffffd097          	auipc	ra,0xffffd
    800043b0:	878080e7          	jalr	-1928(ra) # 80000c24 <acquire>
    log.committing = 0;
    800043b4:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043b8:	8526                	mv	a0,s1
    800043ba:	ffffe097          	auipc	ra,0xffffe
    800043be:	0ee080e7          	jalr	238(ra) # 800024a8 <wakeup>
    release(&log.lock);
    800043c2:	8526                	mv	a0,s1
    800043c4:	ffffd097          	auipc	ra,0xffffd
    800043c8:	914080e7          	jalr	-1772(ra) # 80000cd8 <release>
}
    800043cc:	a03d                	j	800043fa <end_op+0xb2>
    panic("log.committing");
    800043ce:	00004517          	auipc	a0,0x4
    800043d2:	20a50513          	addi	a0,a0,522 # 800085d8 <syscalls+0x218>
    800043d6:	ffffc097          	auipc	ra,0xffffc
    800043da:	182080e7          	jalr	386(ra) # 80000558 <panic>
    wakeup(&log);
    800043de:	00029497          	auipc	s1,0x29
    800043e2:	e7a48493          	addi	s1,s1,-390 # 8002d258 <log>
    800043e6:	8526                	mv	a0,s1
    800043e8:	ffffe097          	auipc	ra,0xffffe
    800043ec:	0c0080e7          	jalr	192(ra) # 800024a8 <wakeup>
  release(&log.lock);
    800043f0:	8526                	mv	a0,s1
    800043f2:	ffffd097          	auipc	ra,0xffffd
    800043f6:	8e6080e7          	jalr	-1818(ra) # 80000cd8 <release>
}
    800043fa:	70e2                	ld	ra,56(sp)
    800043fc:	7442                	ld	s0,48(sp)
    800043fe:	74a2                	ld	s1,40(sp)
    80004400:	7902                	ld	s2,32(sp)
    80004402:	69e2                	ld	s3,24(sp)
    80004404:	6a42                	ld	s4,16(sp)
    80004406:	6aa2                	ld	s5,8(sp)
    80004408:	6121                	addi	sp,sp,64
    8000440a:	8082                	ret
    8000440c:	00029a17          	auipc	s4,0x29
    80004410:	e7ca0a13          	addi	s4,s4,-388 # 8002d288 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004414:	00029917          	auipc	s2,0x29
    80004418:	e4490913          	addi	s2,s2,-444 # 8002d258 <log>
    8000441c:	01892583          	lw	a1,24(s2)
    80004420:	9da5                	addw	a1,a1,s1
    80004422:	2585                	addiw	a1,a1,1
    80004424:	02892503          	lw	a0,40(s2)
    80004428:	fffff097          	auipc	ra,0xfffff
    8000442c:	c7a080e7          	jalr	-902(ra) # 800030a2 <bread>
    80004430:	89aa                	mv	s3,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004432:	000a2583          	lw	a1,0(s4)
    80004436:	02892503          	lw	a0,40(s2)
    8000443a:	fffff097          	auipc	ra,0xfffff
    8000443e:	c68080e7          	jalr	-920(ra) # 800030a2 <bread>
    80004442:	8aaa                	mv	s5,a0
    memmove(to->data, from->data, BSIZE);
    80004444:	40000613          	li	a2,1024
    80004448:	05850593          	addi	a1,a0,88
    8000444c:	05898513          	addi	a0,s3,88
    80004450:	ffffd097          	auipc	ra,0xffffd
    80004454:	93c080e7          	jalr	-1732(ra) # 80000d8c <memmove>
    bwrite(to);  // write the log
    80004458:	854e                	mv	a0,s3
    8000445a:	fffff097          	auipc	ra,0xfffff
    8000445e:	d4c080e7          	jalr	-692(ra) # 800031a6 <bwrite>
    brelse(from);
    80004462:	8556                	mv	a0,s5
    80004464:	fffff097          	auipc	ra,0xfffff
    80004468:	d80080e7          	jalr	-640(ra) # 800031e4 <brelse>
    brelse(to);
    8000446c:	854e                	mv	a0,s3
    8000446e:	fffff097          	auipc	ra,0xfffff
    80004472:	d76080e7          	jalr	-650(ra) # 800031e4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004476:	2485                	addiw	s1,s1,1
    80004478:	0a11                	addi	s4,s4,4
    8000447a:	02c92783          	lw	a5,44(s2)
    8000447e:	f8f4cfe3          	blt	s1,a5,8000441c <end_op+0xd4>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004482:	00000097          	auipc	ra,0x0
    80004486:	c62080e7          	jalr	-926(ra) # 800040e4 <write_head>
    install_trans(0); // Now install writes to home locations
    8000448a:	4501                	li	a0,0
    8000448c:	00000097          	auipc	ra,0x0
    80004490:	cd2080e7          	jalr	-814(ra) # 8000415e <install_trans>
    log.lh.n = 0;
    80004494:	00029797          	auipc	a5,0x29
    80004498:	de07a823          	sw	zero,-528(a5) # 8002d284 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000449c:	00000097          	auipc	ra,0x0
    800044a0:	c48080e7          	jalr	-952(ra) # 800040e4 <write_head>
    800044a4:	bdfd                	j	800043a2 <end_op+0x5a>

00000000800044a6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044a6:	1101                	addi	sp,sp,-32
    800044a8:	ec06                	sd	ra,24(sp)
    800044aa:	e822                	sd	s0,16(sp)
    800044ac:	e426                	sd	s1,8(sp)
    800044ae:	e04a                	sd	s2,0(sp)
    800044b0:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044b2:	00029797          	auipc	a5,0x29
    800044b6:	da678793          	addi	a5,a5,-602 # 8002d258 <log>
    800044ba:	57d8                	lw	a4,44(a5)
    800044bc:	47f5                	li	a5,29
    800044be:	08e7c563          	blt	a5,a4,80004548 <log_write+0xa2>
    800044c2:	892a                	mv	s2,a0
    800044c4:	00029797          	auipc	a5,0x29
    800044c8:	d9478793          	addi	a5,a5,-620 # 8002d258 <log>
    800044cc:	4fdc                	lw	a5,28(a5)
    800044ce:	37fd                	addiw	a5,a5,-1
    800044d0:	06f75c63          	ble	a5,a4,80004548 <log_write+0xa2>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044d4:	00029797          	auipc	a5,0x29
    800044d8:	d8478793          	addi	a5,a5,-636 # 8002d258 <log>
    800044dc:	539c                	lw	a5,32(a5)
    800044de:	06f05d63          	blez	a5,80004558 <log_write+0xb2>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800044e2:	00029497          	auipc	s1,0x29
    800044e6:	d7648493          	addi	s1,s1,-650 # 8002d258 <log>
    800044ea:	8526                	mv	a0,s1
    800044ec:	ffffc097          	auipc	ra,0xffffc
    800044f0:	738080e7          	jalr	1848(ra) # 80000c24 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800044f4:	54d0                	lw	a2,44(s1)
    800044f6:	0ac05063          	blez	a2,80004596 <log_write+0xf0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800044fa:	00c92583          	lw	a1,12(s2)
    800044fe:	589c                	lw	a5,48(s1)
    80004500:	0ab78363          	beq	a5,a1,800045a6 <log_write+0x100>
    80004504:	00029717          	auipc	a4,0x29
    80004508:	d8870713          	addi	a4,a4,-632 # 8002d28c <log+0x34>
  for (i = 0; i < log.lh.n; i++) {
    8000450c:	4781                	li	a5,0
    8000450e:	2785                	addiw	a5,a5,1
    80004510:	04c78c63          	beq	a5,a2,80004568 <log_write+0xc2>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004514:	4314                	lw	a3,0(a4)
    80004516:	0711                	addi	a4,a4,4
    80004518:	feb69be3          	bne	a3,a1,8000450e <log_write+0x68>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000451c:	07a1                	addi	a5,a5,8
    8000451e:	078a                	slli	a5,a5,0x2
    80004520:	00029717          	auipc	a4,0x29
    80004524:	d3870713          	addi	a4,a4,-712 # 8002d258 <log>
    80004528:	97ba                	add	a5,a5,a4
    8000452a:	cb8c                	sw	a1,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    log.lh.n++;
  }
  release(&log.lock);
    8000452c:	00029517          	auipc	a0,0x29
    80004530:	d2c50513          	addi	a0,a0,-724 # 8002d258 <log>
    80004534:	ffffc097          	auipc	ra,0xffffc
    80004538:	7a4080e7          	jalr	1956(ra) # 80000cd8 <release>
}
    8000453c:	60e2                	ld	ra,24(sp)
    8000453e:	6442                	ld	s0,16(sp)
    80004540:	64a2                	ld	s1,8(sp)
    80004542:	6902                	ld	s2,0(sp)
    80004544:	6105                	addi	sp,sp,32
    80004546:	8082                	ret
    panic("too big a transaction");
    80004548:	00004517          	auipc	a0,0x4
    8000454c:	0a050513          	addi	a0,a0,160 # 800085e8 <syscalls+0x228>
    80004550:	ffffc097          	auipc	ra,0xffffc
    80004554:	008080e7          	jalr	8(ra) # 80000558 <panic>
    panic("log_write outside of trans");
    80004558:	00004517          	auipc	a0,0x4
    8000455c:	0a850513          	addi	a0,a0,168 # 80008600 <syscalls+0x240>
    80004560:	ffffc097          	auipc	ra,0xffffc
    80004564:	ff8080e7          	jalr	-8(ra) # 80000558 <panic>
  log.lh.block[i] = b->blockno;
    80004568:	0621                	addi	a2,a2,8
    8000456a:	060a                	slli	a2,a2,0x2
    8000456c:	00029797          	auipc	a5,0x29
    80004570:	cec78793          	addi	a5,a5,-788 # 8002d258 <log>
    80004574:	963e                	add	a2,a2,a5
    80004576:	00c92783          	lw	a5,12(s2)
    8000457a:	ca1c                	sw	a5,16(a2)
    bpin(b);
    8000457c:	854a                	mv	a0,s2
    8000457e:	fffff097          	auipc	ra,0xfffff
    80004582:	d04080e7          	jalr	-764(ra) # 80003282 <bpin>
    log.lh.n++;
    80004586:	00029717          	auipc	a4,0x29
    8000458a:	cd270713          	addi	a4,a4,-814 # 8002d258 <log>
    8000458e:	575c                	lw	a5,44(a4)
    80004590:	2785                	addiw	a5,a5,1
    80004592:	d75c                	sw	a5,44(a4)
    80004594:	bf61                	j	8000452c <log_write+0x86>
  log.lh.block[i] = b->blockno;
    80004596:	00c92783          	lw	a5,12(s2)
    8000459a:	00029717          	auipc	a4,0x29
    8000459e:	cef72723          	sw	a5,-786(a4) # 8002d288 <log+0x30>
  if (i == log.lh.n) {  // Add new block to log?
    800045a2:	f649                	bnez	a2,8000452c <log_write+0x86>
    800045a4:	bfe1                	j	8000457c <log_write+0xd6>
  for (i = 0; i < log.lh.n; i++) {
    800045a6:	4781                	li	a5,0
    800045a8:	bf95                	j	8000451c <log_write+0x76>

00000000800045aa <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045aa:	1101                	addi	sp,sp,-32
    800045ac:	ec06                	sd	ra,24(sp)
    800045ae:	e822                	sd	s0,16(sp)
    800045b0:	e426                	sd	s1,8(sp)
    800045b2:	e04a                	sd	s2,0(sp)
    800045b4:	1000                	addi	s0,sp,32
    800045b6:	84aa                	mv	s1,a0
    800045b8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045ba:	00004597          	auipc	a1,0x4
    800045be:	06658593          	addi	a1,a1,102 # 80008620 <syscalls+0x260>
    800045c2:	0521                	addi	a0,a0,8
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	5d0080e7          	jalr	1488(ra) # 80000b94 <initlock>
  lk->name = name;
    800045cc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045d0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045d4:	0204a423          	sw	zero,40(s1)
}
    800045d8:	60e2                	ld	ra,24(sp)
    800045da:	6442                	ld	s0,16(sp)
    800045dc:	64a2                	ld	s1,8(sp)
    800045de:	6902                	ld	s2,0(sp)
    800045e0:	6105                	addi	sp,sp,32
    800045e2:	8082                	ret

00000000800045e4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045e4:	1101                	addi	sp,sp,-32
    800045e6:	ec06                	sd	ra,24(sp)
    800045e8:	e822                	sd	s0,16(sp)
    800045ea:	e426                	sd	s1,8(sp)
    800045ec:	e04a                	sd	s2,0(sp)
    800045ee:	1000                	addi	s0,sp,32
    800045f0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045f2:	00850913          	addi	s2,a0,8
    800045f6:	854a                	mv	a0,s2
    800045f8:	ffffc097          	auipc	ra,0xffffc
    800045fc:	62c080e7          	jalr	1580(ra) # 80000c24 <acquire>
  while (lk->locked) {
    80004600:	409c                	lw	a5,0(s1)
    80004602:	cb89                	beqz	a5,80004614 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004604:	85ca                	mv	a1,s2
    80004606:	8526                	mv	a0,s1
    80004608:	ffffe097          	auipc	ra,0xffffe
    8000460c:	d1a080e7          	jalr	-742(ra) # 80002322 <sleep>
  while (lk->locked) {
    80004610:	409c                	lw	a5,0(s1)
    80004612:	fbed                	bnez	a5,80004604 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004614:	4785                	li	a5,1
    80004616:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004618:	ffffd097          	auipc	ra,0xffffd
    8000461c:	414080e7          	jalr	1044(ra) # 80001a2c <myproc>
    80004620:	5d1c                	lw	a5,56(a0)
    80004622:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004624:	854a                	mv	a0,s2
    80004626:	ffffc097          	auipc	ra,0xffffc
    8000462a:	6b2080e7          	jalr	1714(ra) # 80000cd8 <release>
}
    8000462e:	60e2                	ld	ra,24(sp)
    80004630:	6442                	ld	s0,16(sp)
    80004632:	64a2                	ld	s1,8(sp)
    80004634:	6902                	ld	s2,0(sp)
    80004636:	6105                	addi	sp,sp,32
    80004638:	8082                	ret

000000008000463a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000463a:	1101                	addi	sp,sp,-32
    8000463c:	ec06                	sd	ra,24(sp)
    8000463e:	e822                	sd	s0,16(sp)
    80004640:	e426                	sd	s1,8(sp)
    80004642:	e04a                	sd	s2,0(sp)
    80004644:	1000                	addi	s0,sp,32
    80004646:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004648:	00850913          	addi	s2,a0,8
    8000464c:	854a                	mv	a0,s2
    8000464e:	ffffc097          	auipc	ra,0xffffc
    80004652:	5d6080e7          	jalr	1494(ra) # 80000c24 <acquire>
  lk->locked = 0;
    80004656:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000465a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000465e:	8526                	mv	a0,s1
    80004660:	ffffe097          	auipc	ra,0xffffe
    80004664:	e48080e7          	jalr	-440(ra) # 800024a8 <wakeup>
  release(&lk->lk);
    80004668:	854a                	mv	a0,s2
    8000466a:	ffffc097          	auipc	ra,0xffffc
    8000466e:	66e080e7          	jalr	1646(ra) # 80000cd8 <release>
}
    80004672:	60e2                	ld	ra,24(sp)
    80004674:	6442                	ld	s0,16(sp)
    80004676:	64a2                	ld	s1,8(sp)
    80004678:	6902                	ld	s2,0(sp)
    8000467a:	6105                	addi	sp,sp,32
    8000467c:	8082                	ret

000000008000467e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000467e:	7179                	addi	sp,sp,-48
    80004680:	f406                	sd	ra,40(sp)
    80004682:	f022                	sd	s0,32(sp)
    80004684:	ec26                	sd	s1,24(sp)
    80004686:	e84a                	sd	s2,16(sp)
    80004688:	e44e                	sd	s3,8(sp)
    8000468a:	1800                	addi	s0,sp,48
    8000468c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000468e:	00850913          	addi	s2,a0,8
    80004692:	854a                	mv	a0,s2
    80004694:	ffffc097          	auipc	ra,0xffffc
    80004698:	590080e7          	jalr	1424(ra) # 80000c24 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000469c:	409c                	lw	a5,0(s1)
    8000469e:	ef99                	bnez	a5,800046bc <holdingsleep+0x3e>
    800046a0:	4481                	li	s1,0
  release(&lk->lk);
    800046a2:	854a                	mv	a0,s2
    800046a4:	ffffc097          	auipc	ra,0xffffc
    800046a8:	634080e7          	jalr	1588(ra) # 80000cd8 <release>
  return r;
}
    800046ac:	8526                	mv	a0,s1
    800046ae:	70a2                	ld	ra,40(sp)
    800046b0:	7402                	ld	s0,32(sp)
    800046b2:	64e2                	ld	s1,24(sp)
    800046b4:	6942                	ld	s2,16(sp)
    800046b6:	69a2                	ld	s3,8(sp)
    800046b8:	6145                	addi	sp,sp,48
    800046ba:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046bc:	0284a983          	lw	s3,40(s1)
    800046c0:	ffffd097          	auipc	ra,0xffffd
    800046c4:	36c080e7          	jalr	876(ra) # 80001a2c <myproc>
    800046c8:	5d04                	lw	s1,56(a0)
    800046ca:	413484b3          	sub	s1,s1,s3
    800046ce:	0014b493          	seqz	s1,s1
    800046d2:	bfc1                	j	800046a2 <holdingsleep+0x24>

00000000800046d4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046d4:	1141                	addi	sp,sp,-16
    800046d6:	e406                	sd	ra,8(sp)
    800046d8:	e022                	sd	s0,0(sp)
    800046da:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046dc:	00004597          	auipc	a1,0x4
    800046e0:	f5458593          	addi	a1,a1,-172 # 80008630 <syscalls+0x270>
    800046e4:	00029517          	auipc	a0,0x29
    800046e8:	cbc50513          	addi	a0,a0,-836 # 8002d3a0 <ftable>
    800046ec:	ffffc097          	auipc	ra,0xffffc
    800046f0:	4a8080e7          	jalr	1192(ra) # 80000b94 <initlock>
}
    800046f4:	60a2                	ld	ra,8(sp)
    800046f6:	6402                	ld	s0,0(sp)
    800046f8:	0141                	addi	sp,sp,16
    800046fa:	8082                	ret

00000000800046fc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046fc:	1101                	addi	sp,sp,-32
    800046fe:	ec06                	sd	ra,24(sp)
    80004700:	e822                	sd	s0,16(sp)
    80004702:	e426                	sd	s1,8(sp)
    80004704:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004706:	00029517          	auipc	a0,0x29
    8000470a:	c9a50513          	addi	a0,a0,-870 # 8002d3a0 <ftable>
    8000470e:	ffffc097          	auipc	ra,0xffffc
    80004712:	516080e7          	jalr	1302(ra) # 80000c24 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
    80004716:	00029797          	auipc	a5,0x29
    8000471a:	c8a78793          	addi	a5,a5,-886 # 8002d3a0 <ftable>
    8000471e:	4fdc                	lw	a5,28(a5)
    80004720:	cb8d                	beqz	a5,80004752 <filealloc+0x56>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004722:	00029497          	auipc	s1,0x29
    80004726:	cbe48493          	addi	s1,s1,-834 # 8002d3e0 <ftable+0x40>
    8000472a:	0002a717          	auipc	a4,0x2a
    8000472e:	c2e70713          	addi	a4,a4,-978 # 8002e358 <ftable+0xfb8>
    if(f->ref == 0){
    80004732:	40dc                	lw	a5,4(s1)
    80004734:	c39d                	beqz	a5,8000475a <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004736:	02848493          	addi	s1,s1,40
    8000473a:	fee49ce3          	bne	s1,a4,80004732 <filealloc+0x36>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000473e:	00029517          	auipc	a0,0x29
    80004742:	c6250513          	addi	a0,a0,-926 # 8002d3a0 <ftable>
    80004746:	ffffc097          	auipc	ra,0xffffc
    8000474a:	592080e7          	jalr	1426(ra) # 80000cd8 <release>
  return 0;
    8000474e:	4481                	li	s1,0
    80004750:	a839                	j	8000476e <filealloc+0x72>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004752:	00029497          	auipc	s1,0x29
    80004756:	c6648493          	addi	s1,s1,-922 # 8002d3b8 <ftable+0x18>
      f->ref = 1;
    8000475a:	4785                	li	a5,1
    8000475c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000475e:	00029517          	auipc	a0,0x29
    80004762:	c4250513          	addi	a0,a0,-958 # 8002d3a0 <ftable>
    80004766:	ffffc097          	auipc	ra,0xffffc
    8000476a:	572080e7          	jalr	1394(ra) # 80000cd8 <release>
}
    8000476e:	8526                	mv	a0,s1
    80004770:	60e2                	ld	ra,24(sp)
    80004772:	6442                	ld	s0,16(sp)
    80004774:	64a2                	ld	s1,8(sp)
    80004776:	6105                	addi	sp,sp,32
    80004778:	8082                	ret

000000008000477a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000477a:	1101                	addi	sp,sp,-32
    8000477c:	ec06                	sd	ra,24(sp)
    8000477e:	e822                	sd	s0,16(sp)
    80004780:	e426                	sd	s1,8(sp)
    80004782:	1000                	addi	s0,sp,32
    80004784:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004786:	00029517          	auipc	a0,0x29
    8000478a:	c1a50513          	addi	a0,a0,-998 # 8002d3a0 <ftable>
    8000478e:	ffffc097          	auipc	ra,0xffffc
    80004792:	496080e7          	jalr	1174(ra) # 80000c24 <acquire>
  if(f->ref < 1)
    80004796:	40dc                	lw	a5,4(s1)
    80004798:	02f05263          	blez	a5,800047bc <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000479c:	2785                	addiw	a5,a5,1
    8000479e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047a0:	00029517          	auipc	a0,0x29
    800047a4:	c0050513          	addi	a0,a0,-1024 # 8002d3a0 <ftable>
    800047a8:	ffffc097          	auipc	ra,0xffffc
    800047ac:	530080e7          	jalr	1328(ra) # 80000cd8 <release>
  return f;
}
    800047b0:	8526                	mv	a0,s1
    800047b2:	60e2                	ld	ra,24(sp)
    800047b4:	6442                	ld	s0,16(sp)
    800047b6:	64a2                	ld	s1,8(sp)
    800047b8:	6105                	addi	sp,sp,32
    800047ba:	8082                	ret
    panic("filedup");
    800047bc:	00004517          	auipc	a0,0x4
    800047c0:	e7c50513          	addi	a0,a0,-388 # 80008638 <syscalls+0x278>
    800047c4:	ffffc097          	auipc	ra,0xffffc
    800047c8:	d94080e7          	jalr	-620(ra) # 80000558 <panic>

00000000800047cc <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047cc:	7139                	addi	sp,sp,-64
    800047ce:	fc06                	sd	ra,56(sp)
    800047d0:	f822                	sd	s0,48(sp)
    800047d2:	f426                	sd	s1,40(sp)
    800047d4:	f04a                	sd	s2,32(sp)
    800047d6:	ec4e                	sd	s3,24(sp)
    800047d8:	e852                	sd	s4,16(sp)
    800047da:	e456                	sd	s5,8(sp)
    800047dc:	0080                	addi	s0,sp,64
    800047de:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047e0:	00029517          	auipc	a0,0x29
    800047e4:	bc050513          	addi	a0,a0,-1088 # 8002d3a0 <ftable>
    800047e8:	ffffc097          	auipc	ra,0xffffc
    800047ec:	43c080e7          	jalr	1084(ra) # 80000c24 <acquire>
  if(f->ref < 1)
    800047f0:	40dc                	lw	a5,4(s1)
    800047f2:	06f05163          	blez	a5,80004854 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047f6:	37fd                	addiw	a5,a5,-1
    800047f8:	0007871b          	sext.w	a4,a5
    800047fc:	c0dc                	sw	a5,4(s1)
    800047fe:	06e04363          	bgtz	a4,80004864 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004802:	0004a903          	lw	s2,0(s1)
    80004806:	0094ca83          	lbu	s5,9(s1)
    8000480a:	0104ba03          	ld	s4,16(s1)
    8000480e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004812:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004816:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000481a:	00029517          	auipc	a0,0x29
    8000481e:	b8650513          	addi	a0,a0,-1146 # 8002d3a0 <ftable>
    80004822:	ffffc097          	auipc	ra,0xffffc
    80004826:	4b6080e7          	jalr	1206(ra) # 80000cd8 <release>

  if(ff.type == FD_PIPE){
    8000482a:	4785                	li	a5,1
    8000482c:	04f90d63          	beq	s2,a5,80004886 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004830:	3979                	addiw	s2,s2,-2
    80004832:	4785                	li	a5,1
    80004834:	0527e063          	bltu	a5,s2,80004874 <fileclose+0xa8>
    begin_op();
    80004838:	00000097          	auipc	ra,0x0
    8000483c:	a90080e7          	jalr	-1392(ra) # 800042c8 <begin_op>
    iput(ff.ip);
    80004840:	854e                	mv	a0,s3
    80004842:	fffff097          	auipc	ra,0xfffff
    80004846:	264080e7          	jalr	612(ra) # 80003aa6 <iput>
    end_op();
    8000484a:	00000097          	auipc	ra,0x0
    8000484e:	afe080e7          	jalr	-1282(ra) # 80004348 <end_op>
    80004852:	a00d                	j	80004874 <fileclose+0xa8>
    panic("fileclose");
    80004854:	00004517          	auipc	a0,0x4
    80004858:	dec50513          	addi	a0,a0,-532 # 80008640 <syscalls+0x280>
    8000485c:	ffffc097          	auipc	ra,0xffffc
    80004860:	cfc080e7          	jalr	-772(ra) # 80000558 <panic>
    release(&ftable.lock);
    80004864:	00029517          	auipc	a0,0x29
    80004868:	b3c50513          	addi	a0,a0,-1220 # 8002d3a0 <ftable>
    8000486c:	ffffc097          	auipc	ra,0xffffc
    80004870:	46c080e7          	jalr	1132(ra) # 80000cd8 <release>
  }
}
    80004874:	70e2                	ld	ra,56(sp)
    80004876:	7442                	ld	s0,48(sp)
    80004878:	74a2                	ld	s1,40(sp)
    8000487a:	7902                	ld	s2,32(sp)
    8000487c:	69e2                	ld	s3,24(sp)
    8000487e:	6a42                	ld	s4,16(sp)
    80004880:	6aa2                	ld	s5,8(sp)
    80004882:	6121                	addi	sp,sp,64
    80004884:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004886:	85d6                	mv	a1,s5
    80004888:	8552                	mv	a0,s4
    8000488a:	00000097          	auipc	ra,0x0
    8000488e:	340080e7          	jalr	832(ra) # 80004bca <pipeclose>
    80004892:	b7cd                	j	80004874 <fileclose+0xa8>

0000000080004894 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004894:	715d                	addi	sp,sp,-80
    80004896:	e486                	sd	ra,72(sp)
    80004898:	e0a2                	sd	s0,64(sp)
    8000489a:	fc26                	sd	s1,56(sp)
    8000489c:	f84a                	sd	s2,48(sp)
    8000489e:	f44e                	sd	s3,40(sp)
    800048a0:	0880                	addi	s0,sp,80
    800048a2:	84aa                	mv	s1,a0
    800048a4:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800048a6:	ffffd097          	auipc	ra,0xffffd
    800048aa:	186080e7          	jalr	390(ra) # 80001a2c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800048ae:	409c                	lw	a5,0(s1)
    800048b0:	37f9                	addiw	a5,a5,-2
    800048b2:	4705                	li	a4,1
    800048b4:	04f76763          	bltu	a4,a5,80004902 <filestat+0x6e>
    800048b8:	892a                	mv	s2,a0
    ilock(f->ip);
    800048ba:	6c88                	ld	a0,24(s1)
    800048bc:	fffff097          	auipc	ra,0xfffff
    800048c0:	02e080e7          	jalr	46(ra) # 800038ea <ilock>
    stati(f->ip, &st);
    800048c4:	fb840593          	addi	a1,s0,-72
    800048c8:	6c88                	ld	a0,24(s1)
    800048ca:	fffff097          	auipc	ra,0xfffff
    800048ce:	2ac080e7          	jalr	684(ra) # 80003b76 <stati>
    iunlock(f->ip);
    800048d2:	6c88                	ld	a0,24(s1)
    800048d4:	fffff097          	auipc	ra,0xfffff
    800048d8:	0da080e7          	jalr	218(ra) # 800039ae <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048dc:	46e1                	li	a3,24
    800048de:	fb840613          	addi	a2,s0,-72
    800048e2:	85ce                	mv	a1,s3
    800048e4:	05093503          	ld	a0,80(s2)
    800048e8:	ffffd097          	auipc	ra,0xffffd
    800048ec:	dc2080e7          	jalr	-574(ra) # 800016aa <copyout>
    800048f0:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048f4:	60a6                	ld	ra,72(sp)
    800048f6:	6406                	ld	s0,64(sp)
    800048f8:	74e2                	ld	s1,56(sp)
    800048fa:	7942                	ld	s2,48(sp)
    800048fc:	79a2                	ld	s3,40(sp)
    800048fe:	6161                	addi	sp,sp,80
    80004900:	8082                	ret
  return -1;
    80004902:	557d                	li	a0,-1
    80004904:	bfc5                	j	800048f4 <filestat+0x60>

0000000080004906 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004906:	7179                	addi	sp,sp,-48
    80004908:	f406                	sd	ra,40(sp)
    8000490a:	f022                	sd	s0,32(sp)
    8000490c:	ec26                	sd	s1,24(sp)
    8000490e:	e84a                	sd	s2,16(sp)
    80004910:	e44e                	sd	s3,8(sp)
    80004912:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004914:	00854783          	lbu	a5,8(a0)
    80004918:	c3d5                	beqz	a5,800049bc <fileread+0xb6>
    8000491a:	89b2                	mv	s3,a2
    8000491c:	892e                	mv	s2,a1
    8000491e:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80004920:	411c                	lw	a5,0(a0)
    80004922:	4705                	li	a4,1
    80004924:	04e78963          	beq	a5,a4,80004976 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004928:	470d                	li	a4,3
    8000492a:	04e78d63          	beq	a5,a4,80004984 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000492e:	4709                	li	a4,2
    80004930:	06e79e63          	bne	a5,a4,800049ac <fileread+0xa6>
    ilock(f->ip);
    80004934:	6d08                	ld	a0,24(a0)
    80004936:	fffff097          	auipc	ra,0xfffff
    8000493a:	fb4080e7          	jalr	-76(ra) # 800038ea <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000493e:	874e                	mv	a4,s3
    80004940:	5094                	lw	a3,32(s1)
    80004942:	864a                	mv	a2,s2
    80004944:	4585                	li	a1,1
    80004946:	6c88                	ld	a0,24(s1)
    80004948:	fffff097          	auipc	ra,0xfffff
    8000494c:	258080e7          	jalr	600(ra) # 80003ba0 <readi>
    80004950:	892a                	mv	s2,a0
    80004952:	00a05563          	blez	a0,8000495c <fileread+0x56>
      f->off += r;
    80004956:	509c                	lw	a5,32(s1)
    80004958:	9fa9                	addw	a5,a5,a0
    8000495a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000495c:	6c88                	ld	a0,24(s1)
    8000495e:	fffff097          	auipc	ra,0xfffff
    80004962:	050080e7          	jalr	80(ra) # 800039ae <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004966:	854a                	mv	a0,s2
    80004968:	70a2                	ld	ra,40(sp)
    8000496a:	7402                	ld	s0,32(sp)
    8000496c:	64e2                	ld	s1,24(sp)
    8000496e:	6942                	ld	s2,16(sp)
    80004970:	69a2                	ld	s3,8(sp)
    80004972:	6145                	addi	sp,sp,48
    80004974:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004976:	6908                	ld	a0,16(a0)
    80004978:	00000097          	auipc	ra,0x0
    8000497c:	3c8080e7          	jalr	968(ra) # 80004d40 <piperead>
    80004980:	892a                	mv	s2,a0
    80004982:	b7d5                	j	80004966 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004984:	02451783          	lh	a5,36(a0)
    80004988:	03079693          	slli	a3,a5,0x30
    8000498c:	92c1                	srli	a3,a3,0x30
    8000498e:	4725                	li	a4,9
    80004990:	02d76863          	bltu	a4,a3,800049c0 <fileread+0xba>
    80004994:	0792                	slli	a5,a5,0x4
    80004996:	00029717          	auipc	a4,0x29
    8000499a:	96a70713          	addi	a4,a4,-1686 # 8002d300 <devsw>
    8000499e:	97ba                	add	a5,a5,a4
    800049a0:	639c                	ld	a5,0(a5)
    800049a2:	c38d                	beqz	a5,800049c4 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800049a4:	4505                	li	a0,1
    800049a6:	9782                	jalr	a5
    800049a8:	892a                	mv	s2,a0
    800049aa:	bf75                	j	80004966 <fileread+0x60>
    panic("fileread");
    800049ac:	00004517          	auipc	a0,0x4
    800049b0:	ca450513          	addi	a0,a0,-860 # 80008650 <syscalls+0x290>
    800049b4:	ffffc097          	auipc	ra,0xffffc
    800049b8:	ba4080e7          	jalr	-1116(ra) # 80000558 <panic>
    return -1;
    800049bc:	597d                	li	s2,-1
    800049be:	b765                	j	80004966 <fileread+0x60>
      return -1;
    800049c0:	597d                	li	s2,-1
    800049c2:	b755                	j	80004966 <fileread+0x60>
    800049c4:	597d                	li	s2,-1
    800049c6:	b745                	j	80004966 <fileread+0x60>

00000000800049c8 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800049c8:	715d                	addi	sp,sp,-80
    800049ca:	e486                	sd	ra,72(sp)
    800049cc:	e0a2                	sd	s0,64(sp)
    800049ce:	fc26                	sd	s1,56(sp)
    800049d0:	f84a                	sd	s2,48(sp)
    800049d2:	f44e                	sd	s3,40(sp)
    800049d4:	f052                	sd	s4,32(sp)
    800049d6:	ec56                	sd	s5,24(sp)
    800049d8:	e85a                	sd	s6,16(sp)
    800049da:	e45e                	sd	s7,8(sp)
    800049dc:	e062                	sd	s8,0(sp)
    800049de:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800049e0:	00954783          	lbu	a5,9(a0)
    800049e4:	10078063          	beqz	a5,80004ae4 <filewrite+0x11c>
    800049e8:	84aa                	mv	s1,a0
    800049ea:	8bae                	mv	s7,a1
    800049ec:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800049ee:	411c                	lw	a5,0(a0)
    800049f0:	4705                	li	a4,1
    800049f2:	02e78263          	beq	a5,a4,80004a16 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049f6:	470d                	li	a4,3
    800049f8:	02e78663          	beq	a5,a4,80004a24 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049fc:	4709                	li	a4,2
    800049fe:	0ce79b63          	bne	a5,a4,80004ad4 <filewrite+0x10c>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a02:	0ac05763          	blez	a2,80004ab0 <filewrite+0xe8>
    int i = 0;
    80004a06:	4901                	li	s2,0
    80004a08:	6b05                	lui	s6,0x1
    80004a0a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004a0e:	6c05                	lui	s8,0x1
    80004a10:	c00c0c1b          	addiw	s8,s8,-1024
    80004a14:	a071                	j	80004aa0 <filewrite+0xd8>
    ret = pipewrite(f->pipe, addr, n);
    80004a16:	6908                	ld	a0,16(a0)
    80004a18:	00000097          	auipc	ra,0x0
    80004a1c:	222080e7          	jalr	546(ra) # 80004c3a <pipewrite>
    80004a20:	8aaa                	mv	s5,a0
    80004a22:	a851                	j	80004ab6 <filewrite+0xee>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a24:	02451783          	lh	a5,36(a0)
    80004a28:	03079693          	slli	a3,a5,0x30
    80004a2c:	92c1                	srli	a3,a3,0x30
    80004a2e:	4725                	li	a4,9
    80004a30:	0ad76c63          	bltu	a4,a3,80004ae8 <filewrite+0x120>
    80004a34:	0792                	slli	a5,a5,0x4
    80004a36:	00029717          	auipc	a4,0x29
    80004a3a:	8ca70713          	addi	a4,a4,-1846 # 8002d300 <devsw>
    80004a3e:	97ba                	add	a5,a5,a4
    80004a40:	679c                	ld	a5,8(a5)
    80004a42:	c7cd                	beqz	a5,80004aec <filewrite+0x124>
    ret = devsw[f->major].write(1, addr, n);
    80004a44:	4505                	li	a0,1
    80004a46:	9782                	jalr	a5
    80004a48:	8aaa                	mv	s5,a0
    80004a4a:	a0b5                	j	80004ab6 <filewrite+0xee>
    80004a4c:	00098a1b          	sext.w	s4,s3
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a50:	00000097          	auipc	ra,0x0
    80004a54:	878080e7          	jalr	-1928(ra) # 800042c8 <begin_op>
      ilock(f->ip);
    80004a58:	6c88                	ld	a0,24(s1)
    80004a5a:	fffff097          	auipc	ra,0xfffff
    80004a5e:	e90080e7          	jalr	-368(ra) # 800038ea <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a62:	8752                	mv	a4,s4
    80004a64:	5094                	lw	a3,32(s1)
    80004a66:	01790633          	add	a2,s2,s7
    80004a6a:	4585                	li	a1,1
    80004a6c:	6c88                	ld	a0,24(s1)
    80004a6e:	fffff097          	auipc	ra,0xfffff
    80004a72:	22a080e7          	jalr	554(ra) # 80003c98 <writei>
    80004a76:	89aa                	mv	s3,a0
    80004a78:	00a05563          	blez	a0,80004a82 <filewrite+0xba>
        f->off += r;
    80004a7c:	509c                	lw	a5,32(s1)
    80004a7e:	9fa9                	addw	a5,a5,a0
    80004a80:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004a82:	6c88                	ld	a0,24(s1)
    80004a84:	fffff097          	auipc	ra,0xfffff
    80004a88:	f2a080e7          	jalr	-214(ra) # 800039ae <iunlock>
      end_op();
    80004a8c:	00000097          	auipc	ra,0x0
    80004a90:	8bc080e7          	jalr	-1860(ra) # 80004348 <end_op>

      if(r != n1){
    80004a94:	01499f63          	bne	s3,s4,80004ab2 <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    80004a98:	012a093b          	addw	s2,s4,s2
    while(i < n){
    80004a9c:	01595b63          	ble	s5,s2,80004ab2 <filewrite+0xea>
      int n1 = n - i;
    80004aa0:	412a87bb          	subw	a5,s5,s2
      if(n1 > max)
    80004aa4:	89be                	mv	s3,a5
    80004aa6:	2781                	sext.w	a5,a5
    80004aa8:	fafb52e3          	ble	a5,s6,80004a4c <filewrite+0x84>
    80004aac:	89e2                	mv	s3,s8
    80004aae:	bf79                	j	80004a4c <filewrite+0x84>
    int i = 0;
    80004ab0:	4901                	li	s2,0
    }
    ret = (i == n ? n : -1);
    80004ab2:	012a9f63          	bne	s5,s2,80004ad0 <filewrite+0x108>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ab6:	8556                	mv	a0,s5
    80004ab8:	60a6                	ld	ra,72(sp)
    80004aba:	6406                	ld	s0,64(sp)
    80004abc:	74e2                	ld	s1,56(sp)
    80004abe:	7942                	ld	s2,48(sp)
    80004ac0:	79a2                	ld	s3,40(sp)
    80004ac2:	7a02                	ld	s4,32(sp)
    80004ac4:	6ae2                	ld	s5,24(sp)
    80004ac6:	6b42                	ld	s6,16(sp)
    80004ac8:	6ba2                	ld	s7,8(sp)
    80004aca:	6c02                	ld	s8,0(sp)
    80004acc:	6161                	addi	sp,sp,80
    80004ace:	8082                	ret
    ret = (i == n ? n : -1);
    80004ad0:	5afd                	li	s5,-1
    80004ad2:	b7d5                	j	80004ab6 <filewrite+0xee>
    panic("filewrite");
    80004ad4:	00004517          	auipc	a0,0x4
    80004ad8:	b8c50513          	addi	a0,a0,-1140 # 80008660 <syscalls+0x2a0>
    80004adc:	ffffc097          	auipc	ra,0xffffc
    80004ae0:	a7c080e7          	jalr	-1412(ra) # 80000558 <panic>
    return -1;
    80004ae4:	5afd                	li	s5,-1
    80004ae6:	bfc1                	j	80004ab6 <filewrite+0xee>
      return -1;
    80004ae8:	5afd                	li	s5,-1
    80004aea:	b7f1                	j	80004ab6 <filewrite+0xee>
    80004aec:	5afd                	li	s5,-1
    80004aee:	b7e1                	j	80004ab6 <filewrite+0xee>

0000000080004af0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004af0:	7179                	addi	sp,sp,-48
    80004af2:	f406                	sd	ra,40(sp)
    80004af4:	f022                	sd	s0,32(sp)
    80004af6:	ec26                	sd	s1,24(sp)
    80004af8:	e84a                	sd	s2,16(sp)
    80004afa:	e44e                	sd	s3,8(sp)
    80004afc:	e052                	sd	s4,0(sp)
    80004afe:	1800                	addi	s0,sp,48
    80004b00:	84aa                	mv	s1,a0
    80004b02:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b04:	0005b023          	sd	zero,0(a1)
    80004b08:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b0c:	00000097          	auipc	ra,0x0
    80004b10:	bf0080e7          	jalr	-1040(ra) # 800046fc <filealloc>
    80004b14:	e088                	sd	a0,0(s1)
    80004b16:	c551                	beqz	a0,80004ba2 <pipealloc+0xb2>
    80004b18:	00000097          	auipc	ra,0x0
    80004b1c:	be4080e7          	jalr	-1052(ra) # 800046fc <filealloc>
    80004b20:	00a93023          	sd	a0,0(s2)
    80004b24:	c92d                	beqz	a0,80004b96 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b26:	ffffc097          	auipc	ra,0xffffc
    80004b2a:	00e080e7          	jalr	14(ra) # 80000b34 <kalloc>
    80004b2e:	89aa                	mv	s3,a0
    80004b30:	c125                	beqz	a0,80004b90 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b32:	4a05                	li	s4,1
    80004b34:	23452023          	sw	s4,544(a0)
  pi->writeopen = 1;
    80004b38:	23452223          	sw	s4,548(a0)
  pi->nwrite = 0;
    80004b3c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b40:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b44:	00004597          	auipc	a1,0x4
    80004b48:	b2c58593          	addi	a1,a1,-1236 # 80008670 <syscalls+0x2b0>
    80004b4c:	ffffc097          	auipc	ra,0xffffc
    80004b50:	048080e7          	jalr	72(ra) # 80000b94 <initlock>
  (*f0)->type = FD_PIPE;
    80004b54:	609c                	ld	a5,0(s1)
    80004b56:	0147a023          	sw	s4,0(a5)
  (*f0)->readable = 1;
    80004b5a:	609c                	ld	a5,0(s1)
    80004b5c:	01478423          	sb	s4,8(a5)
  (*f0)->writable = 0;
    80004b60:	609c                	ld	a5,0(s1)
    80004b62:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b66:	609c                	ld	a5,0(s1)
    80004b68:	0137b823          	sd	s3,16(a5)
  (*f1)->type = FD_PIPE;
    80004b6c:	00093783          	ld	a5,0(s2)
    80004b70:	0147a023          	sw	s4,0(a5)
  (*f1)->readable = 0;
    80004b74:	00093783          	ld	a5,0(s2)
    80004b78:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b7c:	00093783          	ld	a5,0(s2)
    80004b80:	014784a3          	sb	s4,9(a5)
  (*f1)->pipe = pi;
    80004b84:	00093783          	ld	a5,0(s2)
    80004b88:	0137b823          	sd	s3,16(a5)
  return 0;
    80004b8c:	4501                	li	a0,0
    80004b8e:	a025                	j	80004bb6 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b90:	6088                	ld	a0,0(s1)
    80004b92:	e501                	bnez	a0,80004b9a <pipealloc+0xaa>
    80004b94:	a039                	j	80004ba2 <pipealloc+0xb2>
    80004b96:	6088                	ld	a0,0(s1)
    80004b98:	c51d                	beqz	a0,80004bc6 <pipealloc+0xd6>
    fileclose(*f0);
    80004b9a:	00000097          	auipc	ra,0x0
    80004b9e:	c32080e7          	jalr	-974(ra) # 800047cc <fileclose>
  if(*f1)
    80004ba2:	00093783          	ld	a5,0(s2)
    fileclose(*f1);
  return -1;
    80004ba6:	557d                	li	a0,-1
  if(*f1)
    80004ba8:	c799                	beqz	a5,80004bb6 <pipealloc+0xc6>
    fileclose(*f1);
    80004baa:	853e                	mv	a0,a5
    80004bac:	00000097          	auipc	ra,0x0
    80004bb0:	c20080e7          	jalr	-992(ra) # 800047cc <fileclose>
  return -1;
    80004bb4:	557d                	li	a0,-1
}
    80004bb6:	70a2                	ld	ra,40(sp)
    80004bb8:	7402                	ld	s0,32(sp)
    80004bba:	64e2                	ld	s1,24(sp)
    80004bbc:	6942                	ld	s2,16(sp)
    80004bbe:	69a2                	ld	s3,8(sp)
    80004bc0:	6a02                	ld	s4,0(sp)
    80004bc2:	6145                	addi	sp,sp,48
    80004bc4:	8082                	ret
  return -1;
    80004bc6:	557d                	li	a0,-1
    80004bc8:	b7fd                	j	80004bb6 <pipealloc+0xc6>

0000000080004bca <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bca:	1101                	addi	sp,sp,-32
    80004bcc:	ec06                	sd	ra,24(sp)
    80004bce:	e822                	sd	s0,16(sp)
    80004bd0:	e426                	sd	s1,8(sp)
    80004bd2:	e04a                	sd	s2,0(sp)
    80004bd4:	1000                	addi	s0,sp,32
    80004bd6:	84aa                	mv	s1,a0
    80004bd8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bda:	ffffc097          	auipc	ra,0xffffc
    80004bde:	04a080e7          	jalr	74(ra) # 80000c24 <acquire>
  if(writable){
    80004be2:	02090d63          	beqz	s2,80004c1c <pipeclose+0x52>
    pi->writeopen = 0;
    80004be6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bea:	21848513          	addi	a0,s1,536
    80004bee:	ffffe097          	auipc	ra,0xffffe
    80004bf2:	8ba080e7          	jalr	-1862(ra) # 800024a8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bf6:	2204b783          	ld	a5,544(s1)
    80004bfa:	eb95                	bnez	a5,80004c2e <pipeclose+0x64>
    release(&pi->lock);
    80004bfc:	8526                	mv	a0,s1
    80004bfe:	ffffc097          	auipc	ra,0xffffc
    80004c02:	0da080e7          	jalr	218(ra) # 80000cd8 <release>
    kfree((char*)pi);
    80004c06:	8526                	mv	a0,s1
    80004c08:	ffffc097          	auipc	ra,0xffffc
    80004c0c:	e2c080e7          	jalr	-468(ra) # 80000a34 <kfree>
  } else
    release(&pi->lock);
}
    80004c10:	60e2                	ld	ra,24(sp)
    80004c12:	6442                	ld	s0,16(sp)
    80004c14:	64a2                	ld	s1,8(sp)
    80004c16:	6902                	ld	s2,0(sp)
    80004c18:	6105                	addi	sp,sp,32
    80004c1a:	8082                	ret
    pi->readopen = 0;
    80004c1c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c20:	21c48513          	addi	a0,s1,540
    80004c24:	ffffe097          	auipc	ra,0xffffe
    80004c28:	884080e7          	jalr	-1916(ra) # 800024a8 <wakeup>
    80004c2c:	b7e9                	j	80004bf6 <pipeclose+0x2c>
    release(&pi->lock);
    80004c2e:	8526                	mv	a0,s1
    80004c30:	ffffc097          	auipc	ra,0xffffc
    80004c34:	0a8080e7          	jalr	168(ra) # 80000cd8 <release>
}
    80004c38:	bfe1                	j	80004c10 <pipeclose+0x46>

0000000080004c3a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c3a:	7159                	addi	sp,sp,-112
    80004c3c:	f486                	sd	ra,104(sp)
    80004c3e:	f0a2                	sd	s0,96(sp)
    80004c40:	eca6                	sd	s1,88(sp)
    80004c42:	e8ca                	sd	s2,80(sp)
    80004c44:	e4ce                	sd	s3,72(sp)
    80004c46:	e0d2                	sd	s4,64(sp)
    80004c48:	fc56                	sd	s5,56(sp)
    80004c4a:	f85a                	sd	s6,48(sp)
    80004c4c:	f45e                	sd	s7,40(sp)
    80004c4e:	f062                	sd	s8,32(sp)
    80004c50:	ec66                	sd	s9,24(sp)
    80004c52:	1880                	addi	s0,sp,112
    80004c54:	84aa                	mv	s1,a0
    80004c56:	8aae                	mv	s5,a1
    80004c58:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c5a:	ffffd097          	auipc	ra,0xffffd
    80004c5e:	dd2080e7          	jalr	-558(ra) # 80001a2c <myproc>
    80004c62:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c64:	8526                	mv	a0,s1
    80004c66:	ffffc097          	auipc	ra,0xffffc
    80004c6a:	fbe080e7          	jalr	-66(ra) # 80000c24 <acquire>
  while(i < n){
    80004c6e:	0d405763          	blez	s4,80004d3c <pipewrite+0x102>
    80004c72:	8ba6                	mv	s7,s1
    if(pi->readopen == 0 || pr->killed){
    80004c74:	2204a783          	lw	a5,544(s1)
    80004c78:	cb99                	beqz	a5,80004c8e <pipewrite+0x54>
    80004c7a:	0309a903          	lw	s2,48(s3)
    80004c7e:	00091863          	bnez	s2,80004c8e <pipewrite+0x54>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c82:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c84:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c88:	21c48c13          	addi	s8,s1,540
    80004c8c:	a0bd                	j	80004cfa <pipewrite+0xc0>
      release(&pi->lock);
    80004c8e:	8526                	mv	a0,s1
    80004c90:	ffffc097          	auipc	ra,0xffffc
    80004c94:	048080e7          	jalr	72(ra) # 80000cd8 <release>
      return -1;
    80004c98:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c9a:	854a                	mv	a0,s2
    80004c9c:	70a6                	ld	ra,104(sp)
    80004c9e:	7406                	ld	s0,96(sp)
    80004ca0:	64e6                	ld	s1,88(sp)
    80004ca2:	6946                	ld	s2,80(sp)
    80004ca4:	69a6                	ld	s3,72(sp)
    80004ca6:	6a06                	ld	s4,64(sp)
    80004ca8:	7ae2                	ld	s5,56(sp)
    80004caa:	7b42                	ld	s6,48(sp)
    80004cac:	7ba2                	ld	s7,40(sp)
    80004cae:	7c02                	ld	s8,32(sp)
    80004cb0:	6ce2                	ld	s9,24(sp)
    80004cb2:	6165                	addi	sp,sp,112
    80004cb4:	8082                	ret
      wakeup(&pi->nread);
    80004cb6:	8566                	mv	a0,s9
    80004cb8:	ffffd097          	auipc	ra,0xffffd
    80004cbc:	7f0080e7          	jalr	2032(ra) # 800024a8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cc0:	85de                	mv	a1,s7
    80004cc2:	8562                	mv	a0,s8
    80004cc4:	ffffd097          	auipc	ra,0xffffd
    80004cc8:	65e080e7          	jalr	1630(ra) # 80002322 <sleep>
    80004ccc:	a839                	j	80004cea <pipewrite+0xb0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cce:	21c4a783          	lw	a5,540(s1)
    80004cd2:	0017871b          	addiw	a4,a5,1
    80004cd6:	20e4ae23          	sw	a4,540(s1)
    80004cda:	1ff7f793          	andi	a5,a5,511
    80004cde:	97a6                	add	a5,a5,s1
    80004ce0:	f9f44703          	lbu	a4,-97(s0)
    80004ce4:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ce8:	2905                	addiw	s2,s2,1
  while(i < n){
    80004cea:	03495d63          	ble	s4,s2,80004d24 <pipewrite+0xea>
    if(pi->readopen == 0 || pr->killed){
    80004cee:	2204a783          	lw	a5,544(s1)
    80004cf2:	dfd1                	beqz	a5,80004c8e <pipewrite+0x54>
    80004cf4:	0309a783          	lw	a5,48(s3)
    80004cf8:	fbd9                	bnez	a5,80004c8e <pipewrite+0x54>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004cfa:	2184a783          	lw	a5,536(s1)
    80004cfe:	21c4a703          	lw	a4,540(s1)
    80004d02:	2007879b          	addiw	a5,a5,512
    80004d06:	faf708e3          	beq	a4,a5,80004cb6 <pipewrite+0x7c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d0a:	4685                	li	a3,1
    80004d0c:	01590633          	add	a2,s2,s5
    80004d10:	f9f40593          	addi	a1,s0,-97
    80004d14:	0509b503          	ld	a0,80(s3)
    80004d18:	ffffd097          	auipc	ra,0xffffd
    80004d1c:	a1e080e7          	jalr	-1506(ra) # 80001736 <copyin>
    80004d20:	fb6517e3          	bne	a0,s6,80004cce <pipewrite+0x94>
  wakeup(&pi->nread);
    80004d24:	21848513          	addi	a0,s1,536
    80004d28:	ffffd097          	auipc	ra,0xffffd
    80004d2c:	780080e7          	jalr	1920(ra) # 800024a8 <wakeup>
  release(&pi->lock);
    80004d30:	8526                	mv	a0,s1
    80004d32:	ffffc097          	auipc	ra,0xffffc
    80004d36:	fa6080e7          	jalr	-90(ra) # 80000cd8 <release>
  return i;
    80004d3a:	b785                	j	80004c9a <pipewrite+0x60>
  int i = 0;
    80004d3c:	4901                	li	s2,0
    80004d3e:	b7dd                	j	80004d24 <pipewrite+0xea>

0000000080004d40 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d40:	715d                	addi	sp,sp,-80
    80004d42:	e486                	sd	ra,72(sp)
    80004d44:	e0a2                	sd	s0,64(sp)
    80004d46:	fc26                	sd	s1,56(sp)
    80004d48:	f84a                	sd	s2,48(sp)
    80004d4a:	f44e                	sd	s3,40(sp)
    80004d4c:	f052                	sd	s4,32(sp)
    80004d4e:	ec56                	sd	s5,24(sp)
    80004d50:	e85a                	sd	s6,16(sp)
    80004d52:	0880                	addi	s0,sp,80
    80004d54:	84aa                	mv	s1,a0
    80004d56:	89ae                	mv	s3,a1
    80004d58:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d5a:	ffffd097          	auipc	ra,0xffffd
    80004d5e:	cd2080e7          	jalr	-814(ra) # 80001a2c <myproc>
    80004d62:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d64:	8526                	mv	a0,s1
    80004d66:	ffffc097          	auipc	ra,0xffffc
    80004d6a:	ebe080e7          	jalr	-322(ra) # 80000c24 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d6e:	2184a703          	lw	a4,536(s1)
    80004d72:	21c4a783          	lw	a5,540(s1)
    80004d76:	06f71b63          	bne	a4,a5,80004dec <piperead+0xac>
    80004d7a:	8926                	mv	s2,s1
    80004d7c:	2244a783          	lw	a5,548(s1)
    80004d80:	cf9d                	beqz	a5,80004dbe <piperead+0x7e>
    if(pr->killed){
    80004d82:	030a2783          	lw	a5,48(s4)
    80004d86:	e78d                	bnez	a5,80004db0 <piperead+0x70>
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d88:	21848b13          	addi	s6,s1,536
    80004d8c:	85ca                	mv	a1,s2
    80004d8e:	855a                	mv	a0,s6
    80004d90:	ffffd097          	auipc	ra,0xffffd
    80004d94:	592080e7          	jalr	1426(ra) # 80002322 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d98:	2184a703          	lw	a4,536(s1)
    80004d9c:	21c4a783          	lw	a5,540(s1)
    80004da0:	04f71663          	bne	a4,a5,80004dec <piperead+0xac>
    80004da4:	2244a783          	lw	a5,548(s1)
    80004da8:	cb99                	beqz	a5,80004dbe <piperead+0x7e>
    if(pr->killed){
    80004daa:	030a2783          	lw	a5,48(s4)
    80004dae:	dff9                	beqz	a5,80004d8c <piperead+0x4c>
      release(&pi->lock);
    80004db0:	8526                	mv	a0,s1
    80004db2:	ffffc097          	auipc	ra,0xffffc
    80004db6:	f26080e7          	jalr	-218(ra) # 80000cd8 <release>
      return -1;
    80004dba:	597d                	li	s2,-1
    80004dbc:	a829                	j	80004dd6 <piperead+0x96>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(pi->nread == pi->nwrite)
    80004dbe:	4901                	li	s2,0
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004dc0:	21c48513          	addi	a0,s1,540
    80004dc4:	ffffd097          	auipc	ra,0xffffd
    80004dc8:	6e4080e7          	jalr	1764(ra) # 800024a8 <wakeup>
  release(&pi->lock);
    80004dcc:	8526                	mv	a0,s1
    80004dce:	ffffc097          	auipc	ra,0xffffc
    80004dd2:	f0a080e7          	jalr	-246(ra) # 80000cd8 <release>
  return i;
}
    80004dd6:	854a                	mv	a0,s2
    80004dd8:	60a6                	ld	ra,72(sp)
    80004dda:	6406                	ld	s0,64(sp)
    80004ddc:	74e2                	ld	s1,56(sp)
    80004dde:	7942                	ld	s2,48(sp)
    80004de0:	79a2                	ld	s3,40(sp)
    80004de2:	7a02                	ld	s4,32(sp)
    80004de4:	6ae2                	ld	s5,24(sp)
    80004de6:	6b42                	ld	s6,16(sp)
    80004de8:	6161                	addi	sp,sp,80
    80004dea:	8082                	ret
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dec:	4901                	li	s2,0
    80004dee:	fd5059e3          	blez	s5,80004dc0 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004df2:	2184a783          	lw	a5,536(s1)
    80004df6:	4901                	li	s2,0
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004df8:	5b7d                	li	s6,-1
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004dfa:	0017871b          	addiw	a4,a5,1
    80004dfe:	20e4ac23          	sw	a4,536(s1)
    80004e02:	1ff7f793          	andi	a5,a5,511
    80004e06:	97a6                	add	a5,a5,s1
    80004e08:	0187c783          	lbu	a5,24(a5)
    80004e0c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e10:	4685                	li	a3,1
    80004e12:	fbf40613          	addi	a2,s0,-65
    80004e16:	85ce                	mv	a1,s3
    80004e18:	050a3503          	ld	a0,80(s4)
    80004e1c:	ffffd097          	auipc	ra,0xffffd
    80004e20:	88e080e7          	jalr	-1906(ra) # 800016aa <copyout>
    80004e24:	f9650ee3          	beq	a0,s6,80004dc0 <piperead+0x80>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e28:	2905                	addiw	s2,s2,1
    80004e2a:	f92a8be3          	beq	s5,s2,80004dc0 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004e2e:	2184a783          	lw	a5,536(s1)
    80004e32:	0985                	addi	s3,s3,1
    80004e34:	21c4a703          	lw	a4,540(s1)
    80004e38:	fcf711e3          	bne	a4,a5,80004dfa <piperead+0xba>
    80004e3c:	b751                	j	80004dc0 <piperead+0x80>

0000000080004e3e <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e3e:	de010113          	addi	sp,sp,-544
    80004e42:	20113c23          	sd	ra,536(sp)
    80004e46:	20813823          	sd	s0,528(sp)
    80004e4a:	20913423          	sd	s1,520(sp)
    80004e4e:	21213023          	sd	s2,512(sp)
    80004e52:	ffce                	sd	s3,504(sp)
    80004e54:	fbd2                	sd	s4,496(sp)
    80004e56:	f7d6                	sd	s5,488(sp)
    80004e58:	f3da                	sd	s6,480(sp)
    80004e5a:	efde                	sd	s7,472(sp)
    80004e5c:	ebe2                	sd	s8,464(sp)
    80004e5e:	e7e6                	sd	s9,456(sp)
    80004e60:	e3ea                	sd	s10,448(sp)
    80004e62:	ff6e                	sd	s11,440(sp)
    80004e64:	1400                	addi	s0,sp,544
    80004e66:	892a                	mv	s2,a0
    80004e68:	dea43823          	sd	a0,-528(s0)
    80004e6c:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e70:	ffffd097          	auipc	ra,0xffffd
    80004e74:	bbc080e7          	jalr	-1092(ra) # 80001a2c <myproc>
    80004e78:	84aa                	mv	s1,a0

  begin_op();
    80004e7a:	fffff097          	auipc	ra,0xfffff
    80004e7e:	44e080e7          	jalr	1102(ra) # 800042c8 <begin_op>

  if((ip = namei(path)) == 0){
    80004e82:	854a                	mv	a0,s2
    80004e84:	fffff097          	auipc	ra,0xfffff
    80004e88:	226080e7          	jalr	550(ra) # 800040aa <namei>
    80004e8c:	c93d                	beqz	a0,80004f02 <exec+0xc4>
    80004e8e:	892a                	mv	s2,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e90:	fffff097          	auipc	ra,0xfffff
    80004e94:	a5a080e7          	jalr	-1446(ra) # 800038ea <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e98:	04000713          	li	a4,64
    80004e9c:	4681                	li	a3,0
    80004e9e:	e4840613          	addi	a2,s0,-440
    80004ea2:	4581                	li	a1,0
    80004ea4:	854a                	mv	a0,s2
    80004ea6:	fffff097          	auipc	ra,0xfffff
    80004eaa:	cfa080e7          	jalr	-774(ra) # 80003ba0 <readi>
    80004eae:	04000793          	li	a5,64
    80004eb2:	00f51a63          	bne	a0,a5,80004ec6 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004eb6:	e4842703          	lw	a4,-440(s0)
    80004eba:	464c47b7          	lui	a5,0x464c4
    80004ebe:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ec2:	04f70663          	beq	a4,a5,80004f0e <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ec6:	854a                	mv	a0,s2
    80004ec8:	fffff097          	auipc	ra,0xfffff
    80004ecc:	c86080e7          	jalr	-890(ra) # 80003b4e <iunlockput>
    end_op();
    80004ed0:	fffff097          	auipc	ra,0xfffff
    80004ed4:	478080e7          	jalr	1144(ra) # 80004348 <end_op>
  }
  return -1;
    80004ed8:	557d                	li	a0,-1
}
    80004eda:	21813083          	ld	ra,536(sp)
    80004ede:	21013403          	ld	s0,528(sp)
    80004ee2:	20813483          	ld	s1,520(sp)
    80004ee6:	20013903          	ld	s2,512(sp)
    80004eea:	79fe                	ld	s3,504(sp)
    80004eec:	7a5e                	ld	s4,496(sp)
    80004eee:	7abe                	ld	s5,488(sp)
    80004ef0:	7b1e                	ld	s6,480(sp)
    80004ef2:	6bfe                	ld	s7,472(sp)
    80004ef4:	6c5e                	ld	s8,464(sp)
    80004ef6:	6cbe                	ld	s9,456(sp)
    80004ef8:	6d1e                	ld	s10,448(sp)
    80004efa:	7dfa                	ld	s11,440(sp)
    80004efc:	22010113          	addi	sp,sp,544
    80004f00:	8082                	ret
    end_op();
    80004f02:	fffff097          	auipc	ra,0xfffff
    80004f06:	446080e7          	jalr	1094(ra) # 80004348 <end_op>
    return -1;
    80004f0a:	557d                	li	a0,-1
    80004f0c:	b7f9                	j	80004eda <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f0e:	8526                	mv	a0,s1
    80004f10:	ffffd097          	auipc	ra,0xffffd
    80004f14:	be2080e7          	jalr	-1054(ra) # 80001af2 <proc_pagetable>
    80004f18:	e0a43423          	sd	a0,-504(s0)
    80004f1c:	d54d                	beqz	a0,80004ec6 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f1e:	e6842983          	lw	s3,-408(s0)
    80004f22:	e8045783          	lhu	a5,-384(s0)
    80004f26:	c7ad                	beqz	a5,80004f90 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004f28:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f2a:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004f2c:	6c05                	lui	s8,0x1
    80004f2e:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    80004f32:	def43423          	sd	a5,-536(s0)
    80004f36:	7cfd                	lui	s9,0xfffff
    80004f38:	ac1d                	j	8000516e <exec+0x330>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f3a:	00003517          	auipc	a0,0x3
    80004f3e:	73e50513          	addi	a0,a0,1854 # 80008678 <syscalls+0x2b8>
    80004f42:	ffffb097          	auipc	ra,0xffffb
    80004f46:	616080e7          	jalr	1558(ra) # 80000558 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f4a:	8756                	mv	a4,s5
    80004f4c:	009d86bb          	addw	a3,s11,s1
    80004f50:	4581                	li	a1,0
    80004f52:	854a                	mv	a0,s2
    80004f54:	fffff097          	auipc	ra,0xfffff
    80004f58:	c4c080e7          	jalr	-948(ra) # 80003ba0 <readi>
    80004f5c:	2501                	sext.w	a0,a0
    80004f5e:	1aaa9e63          	bne	s5,a0,8000511a <exec+0x2dc>
  for(i = 0; i < sz; i += PGSIZE){
    80004f62:	6785                	lui	a5,0x1
    80004f64:	9cbd                	addw	s1,s1,a5
    80004f66:	014c8a3b          	addw	s4,s9,s4
    80004f6a:	1f74f963          	bleu	s7,s1,8000515c <exec+0x31e>
    pa = walkaddr(pagetable, va + i);
    80004f6e:	02049593          	slli	a1,s1,0x20
    80004f72:	9181                	srli	a1,a1,0x20
    80004f74:	95ea                	add	a1,a1,s10
    80004f76:	e0843503          	ld	a0,-504(s0)
    80004f7a:	ffffc097          	auipc	ra,0xffffc
    80004f7e:	15c080e7          	jalr	348(ra) # 800010d6 <walkaddr>
    80004f82:	862a                	mv	a2,a0
    if(pa == 0)
    80004f84:	d95d                	beqz	a0,80004f3a <exec+0xfc>
      n = PGSIZE;
    80004f86:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    80004f88:	fd8a71e3          	bleu	s8,s4,80004f4a <exec+0x10c>
      n = sz - i;
    80004f8c:	8ad2                	mv	s5,s4
    80004f8e:	bf75                	j	80004f4a <exec+0x10c>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004f90:	4481                	li	s1,0
  iunlockput(ip);
    80004f92:	854a                	mv	a0,s2
    80004f94:	fffff097          	auipc	ra,0xfffff
    80004f98:	bba080e7          	jalr	-1094(ra) # 80003b4e <iunlockput>
  end_op();
    80004f9c:	fffff097          	auipc	ra,0xfffff
    80004fa0:	3ac080e7          	jalr	940(ra) # 80004348 <end_op>
  p = myproc();
    80004fa4:	ffffd097          	auipc	ra,0xffffd
    80004fa8:	a88080e7          	jalr	-1400(ra) # 80001a2c <myproc>
    80004fac:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004fae:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004fb2:	6785                	lui	a5,0x1
    80004fb4:	17fd                	addi	a5,a5,-1
    80004fb6:	94be                	add	s1,s1,a5
    80004fb8:	77fd                	lui	a5,0xfffff
    80004fba:	8fe5                	and	a5,a5,s1
    80004fbc:	e0f43023          	sd	a5,-512(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fc0:	6609                	lui	a2,0x2
    80004fc2:	963e                	add	a2,a2,a5
    80004fc4:	85be                	mv	a1,a5
    80004fc6:	e0843483          	ld	s1,-504(s0)
    80004fca:	8526                	mv	a0,s1
    80004fcc:	ffffc097          	auipc	ra,0xffffc
    80004fd0:	49a080e7          	jalr	1178(ra) # 80001466 <uvmalloc>
    80004fd4:	8b2a                	mv	s6,a0
  ip = 0;
    80004fd6:	4901                	li	s2,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fd8:	14050163          	beqz	a0,8000511a <exec+0x2dc>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fdc:	75f9                	lui	a1,0xffffe
    80004fde:	95aa                	add	a1,a1,a0
    80004fe0:	8526                	mv	a0,s1
    80004fe2:	ffffc097          	auipc	ra,0xffffc
    80004fe6:	696080e7          	jalr	1686(ra) # 80001678 <uvmclear>
  stackbase = sp - PGSIZE;
    80004fea:	7bfd                	lui	s7,0xfffff
    80004fec:	9bda                	add	s7,s7,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fee:	df843783          	ld	a5,-520(s0)
    80004ff2:	6388                	ld	a0,0(a5)
    80004ff4:	c925                	beqz	a0,80005064 <exec+0x226>
    80004ff6:	e8840993          	addi	s3,s0,-376
    80004ffa:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80004ffe:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005000:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005002:	ffffc097          	auipc	ra,0xffffc
    80005006:	ec8080e7          	jalr	-312(ra) # 80000eca <strlen>
    8000500a:	2505                	addiw	a0,a0,1
    8000500c:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005010:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005014:	13796863          	bltu	s2,s7,80005144 <exec+0x306>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005018:	df843c83          	ld	s9,-520(s0)
    8000501c:	000cba03          	ld	s4,0(s9) # fffffffffffff000 <end+0xffffffff7ffcd000>
    80005020:	8552                	mv	a0,s4
    80005022:	ffffc097          	auipc	ra,0xffffc
    80005026:	ea8080e7          	jalr	-344(ra) # 80000eca <strlen>
    8000502a:	0015069b          	addiw	a3,a0,1
    8000502e:	8652                	mv	a2,s4
    80005030:	85ca                	mv	a1,s2
    80005032:	e0843503          	ld	a0,-504(s0)
    80005036:	ffffc097          	auipc	ra,0xffffc
    8000503a:	674080e7          	jalr	1652(ra) # 800016aa <copyout>
    8000503e:	10054763          	bltz	a0,8000514c <exec+0x30e>
    ustack[argc] = sp;
    80005042:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005046:	0485                	addi	s1,s1,1
    80005048:	008c8793          	addi	a5,s9,8
    8000504c:	def43c23          	sd	a5,-520(s0)
    80005050:	008cb503          	ld	a0,8(s9)
    80005054:	c911                	beqz	a0,80005068 <exec+0x22a>
    if(argc >= MAXARG)
    80005056:	09a1                	addi	s3,s3,8
    80005058:	fb8995e3          	bne	s3,s8,80005002 <exec+0x1c4>
  sz = sz1;
    8000505c:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005060:	4901                	li	s2,0
    80005062:	a865                	j	8000511a <exec+0x2dc>
  sp = sz;
    80005064:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005066:	4481                	li	s1,0
  ustack[argc] = 0;
    80005068:	00349793          	slli	a5,s1,0x3
    8000506c:	f9040713          	addi	a4,s0,-112
    80005070:	97ba                	add	a5,a5,a4
    80005072:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffccef8>
  sp -= (argc+1) * sizeof(uint64);
    80005076:	00148693          	addi	a3,s1,1
    8000507a:	068e                	slli	a3,a3,0x3
    8000507c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005080:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005084:	01797663          	bleu	s7,s2,80005090 <exec+0x252>
  sz = sz1;
    80005088:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    8000508c:	4901                	li	s2,0
    8000508e:	a071                	j	8000511a <exec+0x2dc>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005090:	e8840613          	addi	a2,s0,-376
    80005094:	85ca                	mv	a1,s2
    80005096:	e0843503          	ld	a0,-504(s0)
    8000509a:	ffffc097          	auipc	ra,0xffffc
    8000509e:	610080e7          	jalr	1552(ra) # 800016aa <copyout>
    800050a2:	0a054963          	bltz	a0,80005154 <exec+0x316>
  p->trapframe->a1 = sp;
    800050a6:	058ab783          	ld	a5,88(s5)
    800050aa:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050ae:	df043783          	ld	a5,-528(s0)
    800050b2:	0007c703          	lbu	a4,0(a5)
    800050b6:	cf11                	beqz	a4,800050d2 <exec+0x294>
    800050b8:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050ba:	02f00693          	li	a3,47
    800050be:	a029                	j	800050c8 <exec+0x28a>
  for(last=s=path; *s; s++)
    800050c0:	0785                	addi	a5,a5,1
    800050c2:	fff7c703          	lbu	a4,-1(a5)
    800050c6:	c711                	beqz	a4,800050d2 <exec+0x294>
    if(*s == '/')
    800050c8:	fed71ce3          	bne	a4,a3,800050c0 <exec+0x282>
      last = s+1;
    800050cc:	def43823          	sd	a5,-528(s0)
    800050d0:	bfc5                	j	800050c0 <exec+0x282>
  safestrcpy(p->name, last, sizeof(p->name));
    800050d2:	4641                	li	a2,16
    800050d4:	df043583          	ld	a1,-528(s0)
    800050d8:	158a8513          	addi	a0,s5,344
    800050dc:	ffffc097          	auipc	ra,0xffffc
    800050e0:	dbc080e7          	jalr	-580(ra) # 80000e98 <safestrcpy>
  oldpagetable = p->pagetable;
    800050e4:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800050e8:	e0843783          	ld	a5,-504(s0)
    800050ec:	04fab823          	sd	a5,80(s5)
  p->sz = sz;
    800050f0:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050f4:	058ab783          	ld	a5,88(s5)
    800050f8:	e6043703          	ld	a4,-416(s0)
    800050fc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050fe:	058ab783          	ld	a5,88(s5)
    80005102:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005106:	85ea                	mv	a1,s10
    80005108:	ffffd097          	auipc	ra,0xffffd
    8000510c:	a86080e7          	jalr	-1402(ra) # 80001b8e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005110:	0004851b          	sext.w	a0,s1
    80005114:	b3d9                	j	80004eda <exec+0x9c>
    80005116:	e0943023          	sd	s1,-512(s0)
    proc_freepagetable(pagetable, sz);
    8000511a:	e0043583          	ld	a1,-512(s0)
    8000511e:	e0843503          	ld	a0,-504(s0)
    80005122:	ffffd097          	auipc	ra,0xffffd
    80005126:	a6c080e7          	jalr	-1428(ra) # 80001b8e <proc_freepagetable>
  if(ip){
    8000512a:	d8091ee3          	bnez	s2,80004ec6 <exec+0x88>
  return -1;
    8000512e:	557d                	li	a0,-1
    80005130:	b36d                	j	80004eda <exec+0x9c>
    80005132:	e0943023          	sd	s1,-512(s0)
    80005136:	b7d5                	j	8000511a <exec+0x2dc>
    80005138:	e0943023          	sd	s1,-512(s0)
    8000513c:	bff9                	j	8000511a <exec+0x2dc>
    8000513e:	e0943023          	sd	s1,-512(s0)
    80005142:	bfe1                	j	8000511a <exec+0x2dc>
  sz = sz1;
    80005144:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005148:	4901                	li	s2,0
    8000514a:	bfc1                	j	8000511a <exec+0x2dc>
  sz = sz1;
    8000514c:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005150:	4901                	li	s2,0
    80005152:	b7e1                	j	8000511a <exec+0x2dc>
  sz = sz1;
    80005154:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005158:	4901                	li	s2,0
    8000515a:	b7c1                	j	8000511a <exec+0x2dc>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000515c:	e0043483          	ld	s1,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005160:	2b05                	addiw	s6,s6,1
    80005162:	0389899b          	addiw	s3,s3,56
    80005166:	e8045783          	lhu	a5,-384(s0)
    8000516a:	e2fb54e3          	ble	a5,s6,80004f92 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000516e:	2981                	sext.w	s3,s3
    80005170:	03800713          	li	a4,56
    80005174:	86ce                	mv	a3,s3
    80005176:	e1040613          	addi	a2,s0,-496
    8000517a:	4581                	li	a1,0
    8000517c:	854a                	mv	a0,s2
    8000517e:	fffff097          	auipc	ra,0xfffff
    80005182:	a22080e7          	jalr	-1502(ra) # 80003ba0 <readi>
    80005186:	03800793          	li	a5,56
    8000518a:	f8f516e3          	bne	a0,a5,80005116 <exec+0x2d8>
    if(ph.type != ELF_PROG_LOAD)
    8000518e:	e1042783          	lw	a5,-496(s0)
    80005192:	4705                	li	a4,1
    80005194:	fce796e3          	bne	a5,a4,80005160 <exec+0x322>
    if(ph.memsz < ph.filesz)
    80005198:	e3843603          	ld	a2,-456(s0)
    8000519c:	e3043783          	ld	a5,-464(s0)
    800051a0:	f8f669e3          	bltu	a2,a5,80005132 <exec+0x2f4>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800051a4:	e2043783          	ld	a5,-480(s0)
    800051a8:	963e                	add	a2,a2,a5
    800051aa:	f8f667e3          	bltu	a2,a5,80005138 <exec+0x2fa>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800051ae:	85a6                	mv	a1,s1
    800051b0:	e0843503          	ld	a0,-504(s0)
    800051b4:	ffffc097          	auipc	ra,0xffffc
    800051b8:	2b2080e7          	jalr	690(ra) # 80001466 <uvmalloc>
    800051bc:	e0a43023          	sd	a0,-512(s0)
    800051c0:	dd3d                	beqz	a0,8000513e <exec+0x300>
    if(ph.vaddr % PGSIZE != 0)
    800051c2:	e2043d03          	ld	s10,-480(s0)
    800051c6:	de843783          	ld	a5,-536(s0)
    800051ca:	00fd77b3          	and	a5,s10,a5
    800051ce:	f7b1                	bnez	a5,8000511a <exec+0x2dc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800051d0:	e1842d83          	lw	s11,-488(s0)
    800051d4:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800051d8:	f80b82e3          	beqz	s7,8000515c <exec+0x31e>
    800051dc:	8a5e                	mv	s4,s7
    800051de:	4481                	li	s1,0
    800051e0:	b379                	j	80004f6e <exec+0x130>

00000000800051e2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051e2:	7179                	addi	sp,sp,-48
    800051e4:	f406                	sd	ra,40(sp)
    800051e6:	f022                	sd	s0,32(sp)
    800051e8:	ec26                	sd	s1,24(sp)
    800051ea:	e84a                	sd	s2,16(sp)
    800051ec:	1800                	addi	s0,sp,48
    800051ee:	892e                	mv	s2,a1
    800051f0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800051f2:	fdc40593          	addi	a1,s0,-36
    800051f6:	ffffe097          	auipc	ra,0xffffe
    800051fa:	b34080e7          	jalr	-1228(ra) # 80002d2a <argint>
    800051fe:	04054063          	bltz	a0,8000523e <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005202:	fdc42703          	lw	a4,-36(s0)
    80005206:	47bd                	li	a5,15
    80005208:	02e7ed63          	bltu	a5,a4,80005242 <argfd+0x60>
    8000520c:	ffffd097          	auipc	ra,0xffffd
    80005210:	820080e7          	jalr	-2016(ra) # 80001a2c <myproc>
    80005214:	fdc42703          	lw	a4,-36(s0)
    80005218:	01a70793          	addi	a5,a4,26
    8000521c:	078e                	slli	a5,a5,0x3
    8000521e:	953e                	add	a0,a0,a5
    80005220:	611c                	ld	a5,0(a0)
    80005222:	c395                	beqz	a5,80005246 <argfd+0x64>
    return -1;
  if(pfd)
    80005224:	00090463          	beqz	s2,8000522c <argfd+0x4a>
    *pfd = fd;
    80005228:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000522c:	4501                	li	a0,0
  if(pf)
    8000522e:	c091                	beqz	s1,80005232 <argfd+0x50>
    *pf = f;
    80005230:	e09c                	sd	a5,0(s1)
}
    80005232:	70a2                	ld	ra,40(sp)
    80005234:	7402                	ld	s0,32(sp)
    80005236:	64e2                	ld	s1,24(sp)
    80005238:	6942                	ld	s2,16(sp)
    8000523a:	6145                	addi	sp,sp,48
    8000523c:	8082                	ret
    return -1;
    8000523e:	557d                	li	a0,-1
    80005240:	bfcd                	j	80005232 <argfd+0x50>
    return -1;
    80005242:	557d                	li	a0,-1
    80005244:	b7fd                	j	80005232 <argfd+0x50>
    80005246:	557d                	li	a0,-1
    80005248:	b7ed                	j	80005232 <argfd+0x50>

000000008000524a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000524a:	1101                	addi	sp,sp,-32
    8000524c:	ec06                	sd	ra,24(sp)
    8000524e:	e822                	sd	s0,16(sp)
    80005250:	e426                	sd	s1,8(sp)
    80005252:	1000                	addi	s0,sp,32
    80005254:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005256:	ffffc097          	auipc	ra,0xffffc
    8000525a:	7d6080e7          	jalr	2006(ra) # 80001a2c <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
    8000525e:	697c                	ld	a5,208(a0)
    80005260:	c395                	beqz	a5,80005284 <fdalloc+0x3a>
    80005262:	0d850713          	addi	a4,a0,216
  for(fd = 0; fd < NOFILE; fd++){
    80005266:	4785                	li	a5,1
    80005268:	4641                	li	a2,16
    if(p->ofile[fd] == 0){
    8000526a:	6314                	ld	a3,0(a4)
    8000526c:	ce89                	beqz	a3,80005286 <fdalloc+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
    8000526e:	2785                	addiw	a5,a5,1
    80005270:	0721                	addi	a4,a4,8
    80005272:	fec79ce3          	bne	a5,a2,8000526a <fdalloc+0x20>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005276:	57fd                	li	a5,-1
}
    80005278:	853e                	mv	a0,a5
    8000527a:	60e2                	ld	ra,24(sp)
    8000527c:	6442                	ld	s0,16(sp)
    8000527e:	64a2                	ld	s1,8(sp)
    80005280:	6105                	addi	sp,sp,32
    80005282:	8082                	ret
  for(fd = 0; fd < NOFILE; fd++){
    80005284:	4781                	li	a5,0
      p->ofile[fd] = f;
    80005286:	01a78713          	addi	a4,a5,26
    8000528a:	070e                	slli	a4,a4,0x3
    8000528c:	953a                	add	a0,a0,a4
    8000528e:	e104                	sd	s1,0(a0)
      return fd;
    80005290:	b7e5                	j	80005278 <fdalloc+0x2e>

0000000080005292 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005292:	715d                	addi	sp,sp,-80
    80005294:	e486                	sd	ra,72(sp)
    80005296:	e0a2                	sd	s0,64(sp)
    80005298:	fc26                	sd	s1,56(sp)
    8000529a:	f84a                	sd	s2,48(sp)
    8000529c:	f44e                	sd	s3,40(sp)
    8000529e:	f052                	sd	s4,32(sp)
    800052a0:	ec56                	sd	s5,24(sp)
    800052a2:	0880                	addi	s0,sp,80
    800052a4:	89ae                	mv	s3,a1
    800052a6:	8ab2                	mv	s5,a2
    800052a8:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052aa:	fb040593          	addi	a1,s0,-80
    800052ae:	fffff097          	auipc	ra,0xfffff
    800052b2:	e1a080e7          	jalr	-486(ra) # 800040c8 <nameiparent>
    800052b6:	892a                	mv	s2,a0
    800052b8:	12050f63          	beqz	a0,800053f6 <create+0x164>
    return 0;

  ilock(dp);
    800052bc:	ffffe097          	auipc	ra,0xffffe
    800052c0:	62e080e7          	jalr	1582(ra) # 800038ea <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052c4:	4601                	li	a2,0
    800052c6:	fb040593          	addi	a1,s0,-80
    800052ca:	854a                	mv	a0,s2
    800052cc:	fffff097          	auipc	ra,0xfffff
    800052d0:	b04080e7          	jalr	-1276(ra) # 80003dd0 <dirlookup>
    800052d4:	84aa                	mv	s1,a0
    800052d6:	c921                	beqz	a0,80005326 <create+0x94>
    iunlockput(dp);
    800052d8:	854a                	mv	a0,s2
    800052da:	fffff097          	auipc	ra,0xfffff
    800052de:	874080e7          	jalr	-1932(ra) # 80003b4e <iunlockput>
    ilock(ip);
    800052e2:	8526                	mv	a0,s1
    800052e4:	ffffe097          	auipc	ra,0xffffe
    800052e8:	606080e7          	jalr	1542(ra) # 800038ea <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052ec:	2981                	sext.w	s3,s3
    800052ee:	4789                	li	a5,2
    800052f0:	02f99463          	bne	s3,a5,80005318 <create+0x86>
    800052f4:	0444d783          	lhu	a5,68(s1)
    800052f8:	37f9                	addiw	a5,a5,-2
    800052fa:	17c2                	slli	a5,a5,0x30
    800052fc:	93c1                	srli	a5,a5,0x30
    800052fe:	4705                	li	a4,1
    80005300:	00f76c63          	bltu	a4,a5,80005318 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005304:	8526                	mv	a0,s1
    80005306:	60a6                	ld	ra,72(sp)
    80005308:	6406                	ld	s0,64(sp)
    8000530a:	74e2                	ld	s1,56(sp)
    8000530c:	7942                	ld	s2,48(sp)
    8000530e:	79a2                	ld	s3,40(sp)
    80005310:	7a02                	ld	s4,32(sp)
    80005312:	6ae2                	ld	s5,24(sp)
    80005314:	6161                	addi	sp,sp,80
    80005316:	8082                	ret
    iunlockput(ip);
    80005318:	8526                	mv	a0,s1
    8000531a:	fffff097          	auipc	ra,0xfffff
    8000531e:	834080e7          	jalr	-1996(ra) # 80003b4e <iunlockput>
    return 0;
    80005322:	4481                	li	s1,0
    80005324:	b7c5                	j	80005304 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005326:	85ce                	mv	a1,s3
    80005328:	00092503          	lw	a0,0(s2)
    8000532c:	ffffe097          	auipc	ra,0xffffe
    80005330:	422080e7          	jalr	1058(ra) # 8000374e <ialloc>
    80005334:	84aa                	mv	s1,a0
    80005336:	c529                	beqz	a0,80005380 <create+0xee>
  ilock(ip);
    80005338:	ffffe097          	auipc	ra,0xffffe
    8000533c:	5b2080e7          	jalr	1458(ra) # 800038ea <ilock>
  ip->major = major;
    80005340:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005344:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005348:	4785                	li	a5,1
    8000534a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000534e:	8526                	mv	a0,s1
    80005350:	ffffe097          	auipc	ra,0xffffe
    80005354:	4ce080e7          	jalr	1230(ra) # 8000381e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005358:	2981                	sext.w	s3,s3
    8000535a:	4785                	li	a5,1
    8000535c:	02f98a63          	beq	s3,a5,80005390 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005360:	40d0                	lw	a2,4(s1)
    80005362:	fb040593          	addi	a1,s0,-80
    80005366:	854a                	mv	a0,s2
    80005368:	fffff097          	auipc	ra,0xfffff
    8000536c:	c80080e7          	jalr	-896(ra) # 80003fe8 <dirlink>
    80005370:	06054b63          	bltz	a0,800053e6 <create+0x154>
  iunlockput(dp);
    80005374:	854a                	mv	a0,s2
    80005376:	ffffe097          	auipc	ra,0xffffe
    8000537a:	7d8080e7          	jalr	2008(ra) # 80003b4e <iunlockput>
  return ip;
    8000537e:	b759                	j	80005304 <create+0x72>
    panic("create: ialloc");
    80005380:	00003517          	auipc	a0,0x3
    80005384:	31850513          	addi	a0,a0,792 # 80008698 <syscalls+0x2d8>
    80005388:	ffffb097          	auipc	ra,0xffffb
    8000538c:	1d0080e7          	jalr	464(ra) # 80000558 <panic>
    dp->nlink++;  // for ".."
    80005390:	04a95783          	lhu	a5,74(s2)
    80005394:	2785                	addiw	a5,a5,1
    80005396:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000539a:	854a                	mv	a0,s2
    8000539c:	ffffe097          	auipc	ra,0xffffe
    800053a0:	482080e7          	jalr	1154(ra) # 8000381e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053a4:	40d0                	lw	a2,4(s1)
    800053a6:	00003597          	auipc	a1,0x3
    800053aa:	30258593          	addi	a1,a1,770 # 800086a8 <syscalls+0x2e8>
    800053ae:	8526                	mv	a0,s1
    800053b0:	fffff097          	auipc	ra,0xfffff
    800053b4:	c38080e7          	jalr	-968(ra) # 80003fe8 <dirlink>
    800053b8:	00054f63          	bltz	a0,800053d6 <create+0x144>
    800053bc:	00492603          	lw	a2,4(s2)
    800053c0:	00003597          	auipc	a1,0x3
    800053c4:	2f058593          	addi	a1,a1,752 # 800086b0 <syscalls+0x2f0>
    800053c8:	8526                	mv	a0,s1
    800053ca:	fffff097          	auipc	ra,0xfffff
    800053ce:	c1e080e7          	jalr	-994(ra) # 80003fe8 <dirlink>
    800053d2:	f80557e3          	bgez	a0,80005360 <create+0xce>
      panic("create dots");
    800053d6:	00003517          	auipc	a0,0x3
    800053da:	2e250513          	addi	a0,a0,738 # 800086b8 <syscalls+0x2f8>
    800053de:	ffffb097          	auipc	ra,0xffffb
    800053e2:	17a080e7          	jalr	378(ra) # 80000558 <panic>
    panic("create: dirlink");
    800053e6:	00003517          	auipc	a0,0x3
    800053ea:	2e250513          	addi	a0,a0,738 # 800086c8 <syscalls+0x308>
    800053ee:	ffffb097          	auipc	ra,0xffffb
    800053f2:	16a080e7          	jalr	362(ra) # 80000558 <panic>
    return 0;
    800053f6:	84aa                	mv	s1,a0
    800053f8:	b731                	j	80005304 <create+0x72>

00000000800053fa <sys_dup>:
{
    800053fa:	7179                	addi	sp,sp,-48
    800053fc:	f406                	sd	ra,40(sp)
    800053fe:	f022                	sd	s0,32(sp)
    80005400:	ec26                	sd	s1,24(sp)
    80005402:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005404:	fd840613          	addi	a2,s0,-40
    80005408:	4581                	li	a1,0
    8000540a:	4501                	li	a0,0
    8000540c:	00000097          	auipc	ra,0x0
    80005410:	dd6080e7          	jalr	-554(ra) # 800051e2 <argfd>
    return -1;
    80005414:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005416:	02054363          	bltz	a0,8000543c <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000541a:	fd843503          	ld	a0,-40(s0)
    8000541e:	00000097          	auipc	ra,0x0
    80005422:	e2c080e7          	jalr	-468(ra) # 8000524a <fdalloc>
    80005426:	84aa                	mv	s1,a0
    return -1;
    80005428:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000542a:	00054963          	bltz	a0,8000543c <sys_dup+0x42>
  filedup(f);
    8000542e:	fd843503          	ld	a0,-40(s0)
    80005432:	fffff097          	auipc	ra,0xfffff
    80005436:	348080e7          	jalr	840(ra) # 8000477a <filedup>
  return fd;
    8000543a:	87a6                	mv	a5,s1
}
    8000543c:	853e                	mv	a0,a5
    8000543e:	70a2                	ld	ra,40(sp)
    80005440:	7402                	ld	s0,32(sp)
    80005442:	64e2                	ld	s1,24(sp)
    80005444:	6145                	addi	sp,sp,48
    80005446:	8082                	ret

0000000080005448 <sys_read>:
{
    80005448:	7179                	addi	sp,sp,-48
    8000544a:	f406                	sd	ra,40(sp)
    8000544c:	f022                	sd	s0,32(sp)
    8000544e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005450:	fe840613          	addi	a2,s0,-24
    80005454:	4581                	li	a1,0
    80005456:	4501                	li	a0,0
    80005458:	00000097          	auipc	ra,0x0
    8000545c:	d8a080e7          	jalr	-630(ra) # 800051e2 <argfd>
    return -1;
    80005460:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005462:	04054163          	bltz	a0,800054a4 <sys_read+0x5c>
    80005466:	fe440593          	addi	a1,s0,-28
    8000546a:	4509                	li	a0,2
    8000546c:	ffffe097          	auipc	ra,0xffffe
    80005470:	8be080e7          	jalr	-1858(ra) # 80002d2a <argint>
    return -1;
    80005474:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005476:	02054763          	bltz	a0,800054a4 <sys_read+0x5c>
    8000547a:	fd840593          	addi	a1,s0,-40
    8000547e:	4505                	li	a0,1
    80005480:	ffffe097          	auipc	ra,0xffffe
    80005484:	8cc080e7          	jalr	-1844(ra) # 80002d4c <argaddr>
    return -1;
    80005488:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000548a:	00054d63          	bltz	a0,800054a4 <sys_read+0x5c>
  return fileread(f, p, n);
    8000548e:	fe442603          	lw	a2,-28(s0)
    80005492:	fd843583          	ld	a1,-40(s0)
    80005496:	fe843503          	ld	a0,-24(s0)
    8000549a:	fffff097          	auipc	ra,0xfffff
    8000549e:	46c080e7          	jalr	1132(ra) # 80004906 <fileread>
    800054a2:	87aa                	mv	a5,a0
}
    800054a4:	853e                	mv	a0,a5
    800054a6:	70a2                	ld	ra,40(sp)
    800054a8:	7402                	ld	s0,32(sp)
    800054aa:	6145                	addi	sp,sp,48
    800054ac:	8082                	ret

00000000800054ae <sys_write>:
{
    800054ae:	7179                	addi	sp,sp,-48
    800054b0:	f406                	sd	ra,40(sp)
    800054b2:	f022                	sd	s0,32(sp)
    800054b4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054b6:	fe840613          	addi	a2,s0,-24
    800054ba:	4581                	li	a1,0
    800054bc:	4501                	li	a0,0
    800054be:	00000097          	auipc	ra,0x0
    800054c2:	d24080e7          	jalr	-732(ra) # 800051e2 <argfd>
    return -1;
    800054c6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054c8:	04054163          	bltz	a0,8000550a <sys_write+0x5c>
    800054cc:	fe440593          	addi	a1,s0,-28
    800054d0:	4509                	li	a0,2
    800054d2:	ffffe097          	auipc	ra,0xffffe
    800054d6:	858080e7          	jalr	-1960(ra) # 80002d2a <argint>
    return -1;
    800054da:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054dc:	02054763          	bltz	a0,8000550a <sys_write+0x5c>
    800054e0:	fd840593          	addi	a1,s0,-40
    800054e4:	4505                	li	a0,1
    800054e6:	ffffe097          	auipc	ra,0xffffe
    800054ea:	866080e7          	jalr	-1946(ra) # 80002d4c <argaddr>
    return -1;
    800054ee:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054f0:	00054d63          	bltz	a0,8000550a <sys_write+0x5c>
  return filewrite(f, p, n);
    800054f4:	fe442603          	lw	a2,-28(s0)
    800054f8:	fd843583          	ld	a1,-40(s0)
    800054fc:	fe843503          	ld	a0,-24(s0)
    80005500:	fffff097          	auipc	ra,0xfffff
    80005504:	4c8080e7          	jalr	1224(ra) # 800049c8 <filewrite>
    80005508:	87aa                	mv	a5,a0
}
    8000550a:	853e                	mv	a0,a5
    8000550c:	70a2                	ld	ra,40(sp)
    8000550e:	7402                	ld	s0,32(sp)
    80005510:	6145                	addi	sp,sp,48
    80005512:	8082                	ret

0000000080005514 <sys_close>:
{
    80005514:	1101                	addi	sp,sp,-32
    80005516:	ec06                	sd	ra,24(sp)
    80005518:	e822                	sd	s0,16(sp)
    8000551a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000551c:	fe040613          	addi	a2,s0,-32
    80005520:	fec40593          	addi	a1,s0,-20
    80005524:	4501                	li	a0,0
    80005526:	00000097          	auipc	ra,0x0
    8000552a:	cbc080e7          	jalr	-836(ra) # 800051e2 <argfd>
    return -1;
    8000552e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005530:	02054463          	bltz	a0,80005558 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005534:	ffffc097          	auipc	ra,0xffffc
    80005538:	4f8080e7          	jalr	1272(ra) # 80001a2c <myproc>
    8000553c:	fec42783          	lw	a5,-20(s0)
    80005540:	07e9                	addi	a5,a5,26
    80005542:	078e                	slli	a5,a5,0x3
    80005544:	953e                	add	a0,a0,a5
    80005546:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000554a:	fe043503          	ld	a0,-32(s0)
    8000554e:	fffff097          	auipc	ra,0xfffff
    80005552:	27e080e7          	jalr	638(ra) # 800047cc <fileclose>
  return 0;
    80005556:	4781                	li	a5,0
}
    80005558:	853e                	mv	a0,a5
    8000555a:	60e2                	ld	ra,24(sp)
    8000555c:	6442                	ld	s0,16(sp)
    8000555e:	6105                	addi	sp,sp,32
    80005560:	8082                	ret

0000000080005562 <sys_fstat>:
{
    80005562:	1101                	addi	sp,sp,-32
    80005564:	ec06                	sd	ra,24(sp)
    80005566:	e822                	sd	s0,16(sp)
    80005568:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000556a:	fe840613          	addi	a2,s0,-24
    8000556e:	4581                	li	a1,0
    80005570:	4501                	li	a0,0
    80005572:	00000097          	auipc	ra,0x0
    80005576:	c70080e7          	jalr	-912(ra) # 800051e2 <argfd>
    return -1;
    8000557a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000557c:	02054563          	bltz	a0,800055a6 <sys_fstat+0x44>
    80005580:	fe040593          	addi	a1,s0,-32
    80005584:	4505                	li	a0,1
    80005586:	ffffd097          	auipc	ra,0xffffd
    8000558a:	7c6080e7          	jalr	1990(ra) # 80002d4c <argaddr>
    return -1;
    8000558e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005590:	00054b63          	bltz	a0,800055a6 <sys_fstat+0x44>
  return filestat(f, st);
    80005594:	fe043583          	ld	a1,-32(s0)
    80005598:	fe843503          	ld	a0,-24(s0)
    8000559c:	fffff097          	auipc	ra,0xfffff
    800055a0:	2f8080e7          	jalr	760(ra) # 80004894 <filestat>
    800055a4:	87aa                	mv	a5,a0
}
    800055a6:	853e                	mv	a0,a5
    800055a8:	60e2                	ld	ra,24(sp)
    800055aa:	6442                	ld	s0,16(sp)
    800055ac:	6105                	addi	sp,sp,32
    800055ae:	8082                	ret

00000000800055b0 <sys_link>:
{
    800055b0:	7169                	addi	sp,sp,-304
    800055b2:	f606                	sd	ra,296(sp)
    800055b4:	f222                	sd	s0,288(sp)
    800055b6:	ee26                	sd	s1,280(sp)
    800055b8:	ea4a                	sd	s2,272(sp)
    800055ba:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055bc:	08000613          	li	a2,128
    800055c0:	ed040593          	addi	a1,s0,-304
    800055c4:	4501                	li	a0,0
    800055c6:	ffffd097          	auipc	ra,0xffffd
    800055ca:	7a8080e7          	jalr	1960(ra) # 80002d6e <argstr>
    return -1;
    800055ce:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055d0:	10054e63          	bltz	a0,800056ec <sys_link+0x13c>
    800055d4:	08000613          	li	a2,128
    800055d8:	f5040593          	addi	a1,s0,-176
    800055dc:	4505                	li	a0,1
    800055de:	ffffd097          	auipc	ra,0xffffd
    800055e2:	790080e7          	jalr	1936(ra) # 80002d6e <argstr>
    return -1;
    800055e6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055e8:	10054263          	bltz	a0,800056ec <sys_link+0x13c>
  begin_op();
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	cdc080e7          	jalr	-804(ra) # 800042c8 <begin_op>
  if((ip = namei(old)) == 0){
    800055f4:	ed040513          	addi	a0,s0,-304
    800055f8:	fffff097          	auipc	ra,0xfffff
    800055fc:	ab2080e7          	jalr	-1358(ra) # 800040aa <namei>
    80005600:	84aa                	mv	s1,a0
    80005602:	c551                	beqz	a0,8000568e <sys_link+0xde>
  ilock(ip);
    80005604:	ffffe097          	auipc	ra,0xffffe
    80005608:	2e6080e7          	jalr	742(ra) # 800038ea <ilock>
  if(ip->type == T_DIR){
    8000560c:	04449703          	lh	a4,68(s1)
    80005610:	4785                	li	a5,1
    80005612:	08f70463          	beq	a4,a5,8000569a <sys_link+0xea>
  ip->nlink++;
    80005616:	04a4d783          	lhu	a5,74(s1)
    8000561a:	2785                	addiw	a5,a5,1
    8000561c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005620:	8526                	mv	a0,s1
    80005622:	ffffe097          	auipc	ra,0xffffe
    80005626:	1fc080e7          	jalr	508(ra) # 8000381e <iupdate>
  iunlock(ip);
    8000562a:	8526                	mv	a0,s1
    8000562c:	ffffe097          	auipc	ra,0xffffe
    80005630:	382080e7          	jalr	898(ra) # 800039ae <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005634:	fd040593          	addi	a1,s0,-48
    80005638:	f5040513          	addi	a0,s0,-176
    8000563c:	fffff097          	auipc	ra,0xfffff
    80005640:	a8c080e7          	jalr	-1396(ra) # 800040c8 <nameiparent>
    80005644:	892a                	mv	s2,a0
    80005646:	c935                	beqz	a0,800056ba <sys_link+0x10a>
  ilock(dp);
    80005648:	ffffe097          	auipc	ra,0xffffe
    8000564c:	2a2080e7          	jalr	674(ra) # 800038ea <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005650:	00092703          	lw	a4,0(s2)
    80005654:	409c                	lw	a5,0(s1)
    80005656:	04f71d63          	bne	a4,a5,800056b0 <sys_link+0x100>
    8000565a:	40d0                	lw	a2,4(s1)
    8000565c:	fd040593          	addi	a1,s0,-48
    80005660:	854a                	mv	a0,s2
    80005662:	fffff097          	auipc	ra,0xfffff
    80005666:	986080e7          	jalr	-1658(ra) # 80003fe8 <dirlink>
    8000566a:	04054363          	bltz	a0,800056b0 <sys_link+0x100>
  iunlockput(dp);
    8000566e:	854a                	mv	a0,s2
    80005670:	ffffe097          	auipc	ra,0xffffe
    80005674:	4de080e7          	jalr	1246(ra) # 80003b4e <iunlockput>
  iput(ip);
    80005678:	8526                	mv	a0,s1
    8000567a:	ffffe097          	auipc	ra,0xffffe
    8000567e:	42c080e7          	jalr	1068(ra) # 80003aa6 <iput>
  end_op();
    80005682:	fffff097          	auipc	ra,0xfffff
    80005686:	cc6080e7          	jalr	-826(ra) # 80004348 <end_op>
  return 0;
    8000568a:	4781                	li	a5,0
    8000568c:	a085                	j	800056ec <sys_link+0x13c>
    end_op();
    8000568e:	fffff097          	auipc	ra,0xfffff
    80005692:	cba080e7          	jalr	-838(ra) # 80004348 <end_op>
    return -1;
    80005696:	57fd                	li	a5,-1
    80005698:	a891                	j	800056ec <sys_link+0x13c>
    iunlockput(ip);
    8000569a:	8526                	mv	a0,s1
    8000569c:	ffffe097          	auipc	ra,0xffffe
    800056a0:	4b2080e7          	jalr	1202(ra) # 80003b4e <iunlockput>
    end_op();
    800056a4:	fffff097          	auipc	ra,0xfffff
    800056a8:	ca4080e7          	jalr	-860(ra) # 80004348 <end_op>
    return -1;
    800056ac:	57fd                	li	a5,-1
    800056ae:	a83d                	j	800056ec <sys_link+0x13c>
    iunlockput(dp);
    800056b0:	854a                	mv	a0,s2
    800056b2:	ffffe097          	auipc	ra,0xffffe
    800056b6:	49c080e7          	jalr	1180(ra) # 80003b4e <iunlockput>
  ilock(ip);
    800056ba:	8526                	mv	a0,s1
    800056bc:	ffffe097          	auipc	ra,0xffffe
    800056c0:	22e080e7          	jalr	558(ra) # 800038ea <ilock>
  ip->nlink--;
    800056c4:	04a4d783          	lhu	a5,74(s1)
    800056c8:	37fd                	addiw	a5,a5,-1
    800056ca:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056ce:	8526                	mv	a0,s1
    800056d0:	ffffe097          	auipc	ra,0xffffe
    800056d4:	14e080e7          	jalr	334(ra) # 8000381e <iupdate>
  iunlockput(ip);
    800056d8:	8526                	mv	a0,s1
    800056da:	ffffe097          	auipc	ra,0xffffe
    800056de:	474080e7          	jalr	1140(ra) # 80003b4e <iunlockput>
  end_op();
    800056e2:	fffff097          	auipc	ra,0xfffff
    800056e6:	c66080e7          	jalr	-922(ra) # 80004348 <end_op>
  return -1;
    800056ea:	57fd                	li	a5,-1
}
    800056ec:	853e                	mv	a0,a5
    800056ee:	70b2                	ld	ra,296(sp)
    800056f0:	7412                	ld	s0,288(sp)
    800056f2:	64f2                	ld	s1,280(sp)
    800056f4:	6952                	ld	s2,272(sp)
    800056f6:	6155                	addi	sp,sp,304
    800056f8:	8082                	ret

00000000800056fa <sys_unlink>:
{
    800056fa:	7151                	addi	sp,sp,-240
    800056fc:	f586                	sd	ra,232(sp)
    800056fe:	f1a2                	sd	s0,224(sp)
    80005700:	eda6                	sd	s1,216(sp)
    80005702:	e9ca                	sd	s2,208(sp)
    80005704:	e5ce                	sd	s3,200(sp)
    80005706:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005708:	08000613          	li	a2,128
    8000570c:	f3040593          	addi	a1,s0,-208
    80005710:	4501                	li	a0,0
    80005712:	ffffd097          	auipc	ra,0xffffd
    80005716:	65c080e7          	jalr	1628(ra) # 80002d6e <argstr>
    8000571a:	16054f63          	bltz	a0,80005898 <sys_unlink+0x19e>
  begin_op();
    8000571e:	fffff097          	auipc	ra,0xfffff
    80005722:	baa080e7          	jalr	-1110(ra) # 800042c8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005726:	fb040593          	addi	a1,s0,-80
    8000572a:	f3040513          	addi	a0,s0,-208
    8000572e:	fffff097          	auipc	ra,0xfffff
    80005732:	99a080e7          	jalr	-1638(ra) # 800040c8 <nameiparent>
    80005736:	89aa                	mv	s3,a0
    80005738:	c979                	beqz	a0,8000580e <sys_unlink+0x114>
  ilock(dp);
    8000573a:	ffffe097          	auipc	ra,0xffffe
    8000573e:	1b0080e7          	jalr	432(ra) # 800038ea <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005742:	00003597          	auipc	a1,0x3
    80005746:	f6658593          	addi	a1,a1,-154 # 800086a8 <syscalls+0x2e8>
    8000574a:	fb040513          	addi	a0,s0,-80
    8000574e:	ffffe097          	auipc	ra,0xffffe
    80005752:	668080e7          	jalr	1640(ra) # 80003db6 <namecmp>
    80005756:	14050863          	beqz	a0,800058a6 <sys_unlink+0x1ac>
    8000575a:	00003597          	auipc	a1,0x3
    8000575e:	f5658593          	addi	a1,a1,-170 # 800086b0 <syscalls+0x2f0>
    80005762:	fb040513          	addi	a0,s0,-80
    80005766:	ffffe097          	auipc	ra,0xffffe
    8000576a:	650080e7          	jalr	1616(ra) # 80003db6 <namecmp>
    8000576e:	12050c63          	beqz	a0,800058a6 <sys_unlink+0x1ac>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005772:	f2c40613          	addi	a2,s0,-212
    80005776:	fb040593          	addi	a1,s0,-80
    8000577a:	854e                	mv	a0,s3
    8000577c:	ffffe097          	auipc	ra,0xffffe
    80005780:	654080e7          	jalr	1620(ra) # 80003dd0 <dirlookup>
    80005784:	84aa                	mv	s1,a0
    80005786:	12050063          	beqz	a0,800058a6 <sys_unlink+0x1ac>
  ilock(ip);
    8000578a:	ffffe097          	auipc	ra,0xffffe
    8000578e:	160080e7          	jalr	352(ra) # 800038ea <ilock>
  if(ip->nlink < 1)
    80005792:	04a49783          	lh	a5,74(s1)
    80005796:	08f05263          	blez	a5,8000581a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000579a:	04449703          	lh	a4,68(s1)
    8000579e:	4785                	li	a5,1
    800057a0:	08f70563          	beq	a4,a5,8000582a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800057a4:	4641                	li	a2,16
    800057a6:	4581                	li	a1,0
    800057a8:	fc040513          	addi	a0,s0,-64
    800057ac:	ffffb097          	auipc	ra,0xffffb
    800057b0:	574080e7          	jalr	1396(ra) # 80000d20 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057b4:	4741                	li	a4,16
    800057b6:	f2c42683          	lw	a3,-212(s0)
    800057ba:	fc040613          	addi	a2,s0,-64
    800057be:	4581                	li	a1,0
    800057c0:	854e                	mv	a0,s3
    800057c2:	ffffe097          	auipc	ra,0xffffe
    800057c6:	4d6080e7          	jalr	1238(ra) # 80003c98 <writei>
    800057ca:	47c1                	li	a5,16
    800057cc:	0af51363          	bne	a0,a5,80005872 <sys_unlink+0x178>
  if(ip->type == T_DIR){
    800057d0:	04449703          	lh	a4,68(s1)
    800057d4:	4785                	li	a5,1
    800057d6:	0af70663          	beq	a4,a5,80005882 <sys_unlink+0x188>
  iunlockput(dp);
    800057da:	854e                	mv	a0,s3
    800057dc:	ffffe097          	auipc	ra,0xffffe
    800057e0:	372080e7          	jalr	882(ra) # 80003b4e <iunlockput>
  ip->nlink--;
    800057e4:	04a4d783          	lhu	a5,74(s1)
    800057e8:	37fd                	addiw	a5,a5,-1
    800057ea:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057ee:	8526                	mv	a0,s1
    800057f0:	ffffe097          	auipc	ra,0xffffe
    800057f4:	02e080e7          	jalr	46(ra) # 8000381e <iupdate>
  iunlockput(ip);
    800057f8:	8526                	mv	a0,s1
    800057fa:	ffffe097          	auipc	ra,0xffffe
    800057fe:	354080e7          	jalr	852(ra) # 80003b4e <iunlockput>
  end_op();
    80005802:	fffff097          	auipc	ra,0xfffff
    80005806:	b46080e7          	jalr	-1210(ra) # 80004348 <end_op>
  return 0;
    8000580a:	4501                	li	a0,0
    8000580c:	a07d                	j	800058ba <sys_unlink+0x1c0>
    end_op();
    8000580e:	fffff097          	auipc	ra,0xfffff
    80005812:	b3a080e7          	jalr	-1222(ra) # 80004348 <end_op>
    return -1;
    80005816:	557d                	li	a0,-1
    80005818:	a04d                	j	800058ba <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    8000581a:	00003517          	auipc	a0,0x3
    8000581e:	ebe50513          	addi	a0,a0,-322 # 800086d8 <syscalls+0x318>
    80005822:	ffffb097          	auipc	ra,0xffffb
    80005826:	d36080e7          	jalr	-714(ra) # 80000558 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000582a:	44f8                	lw	a4,76(s1)
    8000582c:	02000793          	li	a5,32
    80005830:	f6e7fae3          	bleu	a4,a5,800057a4 <sys_unlink+0xaa>
    80005834:	02000913          	li	s2,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005838:	4741                	li	a4,16
    8000583a:	86ca                	mv	a3,s2
    8000583c:	f1840613          	addi	a2,s0,-232
    80005840:	4581                	li	a1,0
    80005842:	8526                	mv	a0,s1
    80005844:	ffffe097          	auipc	ra,0xffffe
    80005848:	35c080e7          	jalr	860(ra) # 80003ba0 <readi>
    8000584c:	47c1                	li	a5,16
    8000584e:	00f51a63          	bne	a0,a5,80005862 <sys_unlink+0x168>
    if(de.inum != 0)
    80005852:	f1845783          	lhu	a5,-232(s0)
    80005856:	e3b9                	bnez	a5,8000589c <sys_unlink+0x1a2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005858:	2941                	addiw	s2,s2,16
    8000585a:	44fc                	lw	a5,76(s1)
    8000585c:	fcf96ee3          	bltu	s2,a5,80005838 <sys_unlink+0x13e>
    80005860:	b791                	j	800057a4 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005862:	00003517          	auipc	a0,0x3
    80005866:	e8e50513          	addi	a0,a0,-370 # 800086f0 <syscalls+0x330>
    8000586a:	ffffb097          	auipc	ra,0xffffb
    8000586e:	cee080e7          	jalr	-786(ra) # 80000558 <panic>
    panic("unlink: writei");
    80005872:	00003517          	auipc	a0,0x3
    80005876:	e9650513          	addi	a0,a0,-362 # 80008708 <syscalls+0x348>
    8000587a:	ffffb097          	auipc	ra,0xffffb
    8000587e:	cde080e7          	jalr	-802(ra) # 80000558 <panic>
    dp->nlink--;
    80005882:	04a9d783          	lhu	a5,74(s3)
    80005886:	37fd                	addiw	a5,a5,-1
    80005888:	04f99523          	sh	a5,74(s3)
    iupdate(dp);
    8000588c:	854e                	mv	a0,s3
    8000588e:	ffffe097          	auipc	ra,0xffffe
    80005892:	f90080e7          	jalr	-112(ra) # 8000381e <iupdate>
    80005896:	b791                	j	800057da <sys_unlink+0xe0>
    return -1;
    80005898:	557d                	li	a0,-1
    8000589a:	a005                	j	800058ba <sys_unlink+0x1c0>
    iunlockput(ip);
    8000589c:	8526                	mv	a0,s1
    8000589e:	ffffe097          	auipc	ra,0xffffe
    800058a2:	2b0080e7          	jalr	688(ra) # 80003b4e <iunlockput>
  iunlockput(dp);
    800058a6:	854e                	mv	a0,s3
    800058a8:	ffffe097          	auipc	ra,0xffffe
    800058ac:	2a6080e7          	jalr	678(ra) # 80003b4e <iunlockput>
  end_op();
    800058b0:	fffff097          	auipc	ra,0xfffff
    800058b4:	a98080e7          	jalr	-1384(ra) # 80004348 <end_op>
  return -1;
    800058b8:	557d                	li	a0,-1
}
    800058ba:	70ae                	ld	ra,232(sp)
    800058bc:	740e                	ld	s0,224(sp)
    800058be:	64ee                	ld	s1,216(sp)
    800058c0:	694e                	ld	s2,208(sp)
    800058c2:	69ae                	ld	s3,200(sp)
    800058c4:	616d                	addi	sp,sp,240
    800058c6:	8082                	ret

00000000800058c8 <sys_open>:

uint64
sys_open(void)
{
    800058c8:	7131                	addi	sp,sp,-192
    800058ca:	fd06                	sd	ra,184(sp)
    800058cc:	f922                	sd	s0,176(sp)
    800058ce:	f526                	sd	s1,168(sp)
    800058d0:	f14a                	sd	s2,160(sp)
    800058d2:	ed4e                	sd	s3,152(sp)
    800058d4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058d6:	08000613          	li	a2,128
    800058da:	f5040593          	addi	a1,s0,-176
    800058de:	4501                	li	a0,0
    800058e0:	ffffd097          	auipc	ra,0xffffd
    800058e4:	48e080e7          	jalr	1166(ra) # 80002d6e <argstr>
    return -1;
    800058e8:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058ea:	0c054163          	bltz	a0,800059ac <sys_open+0xe4>
    800058ee:	f4c40593          	addi	a1,s0,-180
    800058f2:	4505                	li	a0,1
    800058f4:	ffffd097          	auipc	ra,0xffffd
    800058f8:	436080e7          	jalr	1078(ra) # 80002d2a <argint>
    800058fc:	0a054863          	bltz	a0,800059ac <sys_open+0xe4>

  begin_op();
    80005900:	fffff097          	auipc	ra,0xfffff
    80005904:	9c8080e7          	jalr	-1592(ra) # 800042c8 <begin_op>

  if(omode & O_CREATE){
    80005908:	f4c42783          	lw	a5,-180(s0)
    8000590c:	2007f793          	andi	a5,a5,512
    80005910:	cbdd                	beqz	a5,800059c6 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005912:	4681                	li	a3,0
    80005914:	4601                	li	a2,0
    80005916:	4589                	li	a1,2
    80005918:	f5040513          	addi	a0,s0,-176
    8000591c:	00000097          	auipc	ra,0x0
    80005920:	976080e7          	jalr	-1674(ra) # 80005292 <create>
    80005924:	892a                	mv	s2,a0
    if(ip == 0){
    80005926:	c959                	beqz	a0,800059bc <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005928:	04491703          	lh	a4,68(s2)
    8000592c:	478d                	li	a5,3
    8000592e:	00f71763          	bne	a4,a5,8000593c <sys_open+0x74>
    80005932:	04695703          	lhu	a4,70(s2)
    80005936:	47a5                	li	a5,9
    80005938:	0ce7ec63          	bltu	a5,a4,80005a10 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000593c:	fffff097          	auipc	ra,0xfffff
    80005940:	dc0080e7          	jalr	-576(ra) # 800046fc <filealloc>
    80005944:	89aa                	mv	s3,a0
    80005946:	10050263          	beqz	a0,80005a4a <sys_open+0x182>
    8000594a:	00000097          	auipc	ra,0x0
    8000594e:	900080e7          	jalr	-1792(ra) # 8000524a <fdalloc>
    80005952:	84aa                	mv	s1,a0
    80005954:	0e054663          	bltz	a0,80005a40 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005958:	04491703          	lh	a4,68(s2)
    8000595c:	478d                	li	a5,3
    8000595e:	0cf70463          	beq	a4,a5,80005a26 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005962:	4789                	li	a5,2
    80005964:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005968:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000596c:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005970:	f4c42783          	lw	a5,-180(s0)
    80005974:	0017c713          	xori	a4,a5,1
    80005978:	8b05                	andi	a4,a4,1
    8000597a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000597e:	0037f713          	andi	a4,a5,3
    80005982:	00e03733          	snez	a4,a4
    80005986:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000598a:	4007f793          	andi	a5,a5,1024
    8000598e:	c791                	beqz	a5,8000599a <sys_open+0xd2>
    80005990:	04491703          	lh	a4,68(s2)
    80005994:	4789                	li	a5,2
    80005996:	08f70f63          	beq	a4,a5,80005a34 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000599a:	854a                	mv	a0,s2
    8000599c:	ffffe097          	auipc	ra,0xffffe
    800059a0:	012080e7          	jalr	18(ra) # 800039ae <iunlock>
  end_op();
    800059a4:	fffff097          	auipc	ra,0xfffff
    800059a8:	9a4080e7          	jalr	-1628(ra) # 80004348 <end_op>

  return fd;
}
    800059ac:	8526                	mv	a0,s1
    800059ae:	70ea                	ld	ra,184(sp)
    800059b0:	744a                	ld	s0,176(sp)
    800059b2:	74aa                	ld	s1,168(sp)
    800059b4:	790a                	ld	s2,160(sp)
    800059b6:	69ea                	ld	s3,152(sp)
    800059b8:	6129                	addi	sp,sp,192
    800059ba:	8082                	ret
      end_op();
    800059bc:	fffff097          	auipc	ra,0xfffff
    800059c0:	98c080e7          	jalr	-1652(ra) # 80004348 <end_op>
      return -1;
    800059c4:	b7e5                	j	800059ac <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800059c6:	f5040513          	addi	a0,s0,-176
    800059ca:	ffffe097          	auipc	ra,0xffffe
    800059ce:	6e0080e7          	jalr	1760(ra) # 800040aa <namei>
    800059d2:	892a                	mv	s2,a0
    800059d4:	c905                	beqz	a0,80005a04 <sys_open+0x13c>
    ilock(ip);
    800059d6:	ffffe097          	auipc	ra,0xffffe
    800059da:	f14080e7          	jalr	-236(ra) # 800038ea <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059de:	04491703          	lh	a4,68(s2)
    800059e2:	4785                	li	a5,1
    800059e4:	f4f712e3          	bne	a4,a5,80005928 <sys_open+0x60>
    800059e8:	f4c42783          	lw	a5,-180(s0)
    800059ec:	dba1                	beqz	a5,8000593c <sys_open+0x74>
      iunlockput(ip);
    800059ee:	854a                	mv	a0,s2
    800059f0:	ffffe097          	auipc	ra,0xffffe
    800059f4:	15e080e7          	jalr	350(ra) # 80003b4e <iunlockput>
      end_op();
    800059f8:	fffff097          	auipc	ra,0xfffff
    800059fc:	950080e7          	jalr	-1712(ra) # 80004348 <end_op>
      return -1;
    80005a00:	54fd                	li	s1,-1
    80005a02:	b76d                	j	800059ac <sys_open+0xe4>
      end_op();
    80005a04:	fffff097          	auipc	ra,0xfffff
    80005a08:	944080e7          	jalr	-1724(ra) # 80004348 <end_op>
      return -1;
    80005a0c:	54fd                	li	s1,-1
    80005a0e:	bf79                	j	800059ac <sys_open+0xe4>
    iunlockput(ip);
    80005a10:	854a                	mv	a0,s2
    80005a12:	ffffe097          	auipc	ra,0xffffe
    80005a16:	13c080e7          	jalr	316(ra) # 80003b4e <iunlockput>
    end_op();
    80005a1a:	fffff097          	auipc	ra,0xfffff
    80005a1e:	92e080e7          	jalr	-1746(ra) # 80004348 <end_op>
    return -1;
    80005a22:	54fd                	li	s1,-1
    80005a24:	b761                	j	800059ac <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a26:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a2a:	04691783          	lh	a5,70(s2)
    80005a2e:	02f99223          	sh	a5,36(s3)
    80005a32:	bf2d                	j	8000596c <sys_open+0xa4>
    itrunc(ip);
    80005a34:	854a                	mv	a0,s2
    80005a36:	ffffe097          	auipc	ra,0xffffe
    80005a3a:	fc4080e7          	jalr	-60(ra) # 800039fa <itrunc>
    80005a3e:	bfb1                	j	8000599a <sys_open+0xd2>
      fileclose(f);
    80005a40:	854e                	mv	a0,s3
    80005a42:	fffff097          	auipc	ra,0xfffff
    80005a46:	d8a080e7          	jalr	-630(ra) # 800047cc <fileclose>
    iunlockput(ip);
    80005a4a:	854a                	mv	a0,s2
    80005a4c:	ffffe097          	auipc	ra,0xffffe
    80005a50:	102080e7          	jalr	258(ra) # 80003b4e <iunlockput>
    end_op();
    80005a54:	fffff097          	auipc	ra,0xfffff
    80005a58:	8f4080e7          	jalr	-1804(ra) # 80004348 <end_op>
    return -1;
    80005a5c:	54fd                	li	s1,-1
    80005a5e:	b7b9                	j	800059ac <sys_open+0xe4>

0000000080005a60 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a60:	7175                	addi	sp,sp,-144
    80005a62:	e506                	sd	ra,136(sp)
    80005a64:	e122                	sd	s0,128(sp)
    80005a66:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a68:	fffff097          	auipc	ra,0xfffff
    80005a6c:	860080e7          	jalr	-1952(ra) # 800042c8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a70:	08000613          	li	a2,128
    80005a74:	f7040593          	addi	a1,s0,-144
    80005a78:	4501                	li	a0,0
    80005a7a:	ffffd097          	auipc	ra,0xffffd
    80005a7e:	2f4080e7          	jalr	756(ra) # 80002d6e <argstr>
    80005a82:	02054963          	bltz	a0,80005ab4 <sys_mkdir+0x54>
    80005a86:	4681                	li	a3,0
    80005a88:	4601                	li	a2,0
    80005a8a:	4585                	li	a1,1
    80005a8c:	f7040513          	addi	a0,s0,-144
    80005a90:	00000097          	auipc	ra,0x0
    80005a94:	802080e7          	jalr	-2046(ra) # 80005292 <create>
    80005a98:	cd11                	beqz	a0,80005ab4 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	0b4080e7          	jalr	180(ra) # 80003b4e <iunlockput>
  end_op();
    80005aa2:	fffff097          	auipc	ra,0xfffff
    80005aa6:	8a6080e7          	jalr	-1882(ra) # 80004348 <end_op>
  return 0;
    80005aaa:	4501                	li	a0,0
}
    80005aac:	60aa                	ld	ra,136(sp)
    80005aae:	640a                	ld	s0,128(sp)
    80005ab0:	6149                	addi	sp,sp,144
    80005ab2:	8082                	ret
    end_op();
    80005ab4:	fffff097          	auipc	ra,0xfffff
    80005ab8:	894080e7          	jalr	-1900(ra) # 80004348 <end_op>
    return -1;
    80005abc:	557d                	li	a0,-1
    80005abe:	b7fd                	j	80005aac <sys_mkdir+0x4c>

0000000080005ac0 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ac0:	7135                	addi	sp,sp,-160
    80005ac2:	ed06                	sd	ra,152(sp)
    80005ac4:	e922                	sd	s0,144(sp)
    80005ac6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ac8:	fffff097          	auipc	ra,0xfffff
    80005acc:	800080e7          	jalr	-2048(ra) # 800042c8 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ad0:	08000613          	li	a2,128
    80005ad4:	f7040593          	addi	a1,s0,-144
    80005ad8:	4501                	li	a0,0
    80005ada:	ffffd097          	auipc	ra,0xffffd
    80005ade:	294080e7          	jalr	660(ra) # 80002d6e <argstr>
    80005ae2:	04054a63          	bltz	a0,80005b36 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005ae6:	f6c40593          	addi	a1,s0,-148
    80005aea:	4505                	li	a0,1
    80005aec:	ffffd097          	auipc	ra,0xffffd
    80005af0:	23e080e7          	jalr	574(ra) # 80002d2a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005af4:	04054163          	bltz	a0,80005b36 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005af8:	f6840593          	addi	a1,s0,-152
    80005afc:	4509                	li	a0,2
    80005afe:	ffffd097          	auipc	ra,0xffffd
    80005b02:	22c080e7          	jalr	556(ra) # 80002d2a <argint>
     argint(1, &major) < 0 ||
    80005b06:	02054863          	bltz	a0,80005b36 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b0a:	f6841683          	lh	a3,-152(s0)
    80005b0e:	f6c41603          	lh	a2,-148(s0)
    80005b12:	458d                	li	a1,3
    80005b14:	f7040513          	addi	a0,s0,-144
    80005b18:	fffff097          	auipc	ra,0xfffff
    80005b1c:	77a080e7          	jalr	1914(ra) # 80005292 <create>
     argint(2, &minor) < 0 ||
    80005b20:	c919                	beqz	a0,80005b36 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b22:	ffffe097          	auipc	ra,0xffffe
    80005b26:	02c080e7          	jalr	44(ra) # 80003b4e <iunlockput>
  end_op();
    80005b2a:	fffff097          	auipc	ra,0xfffff
    80005b2e:	81e080e7          	jalr	-2018(ra) # 80004348 <end_op>
  return 0;
    80005b32:	4501                	li	a0,0
    80005b34:	a031                	j	80005b40 <sys_mknod+0x80>
    end_op();
    80005b36:	fffff097          	auipc	ra,0xfffff
    80005b3a:	812080e7          	jalr	-2030(ra) # 80004348 <end_op>
    return -1;
    80005b3e:	557d                	li	a0,-1
}
    80005b40:	60ea                	ld	ra,152(sp)
    80005b42:	644a                	ld	s0,144(sp)
    80005b44:	610d                	addi	sp,sp,160
    80005b46:	8082                	ret

0000000080005b48 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b48:	7135                	addi	sp,sp,-160
    80005b4a:	ed06                	sd	ra,152(sp)
    80005b4c:	e922                	sd	s0,144(sp)
    80005b4e:	e526                	sd	s1,136(sp)
    80005b50:	e14a                	sd	s2,128(sp)
    80005b52:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b54:	ffffc097          	auipc	ra,0xffffc
    80005b58:	ed8080e7          	jalr	-296(ra) # 80001a2c <myproc>
    80005b5c:	892a                	mv	s2,a0
  
  begin_op();
    80005b5e:	ffffe097          	auipc	ra,0xffffe
    80005b62:	76a080e7          	jalr	1898(ra) # 800042c8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b66:	08000613          	li	a2,128
    80005b6a:	f6040593          	addi	a1,s0,-160
    80005b6e:	4501                	li	a0,0
    80005b70:	ffffd097          	auipc	ra,0xffffd
    80005b74:	1fe080e7          	jalr	510(ra) # 80002d6e <argstr>
    80005b78:	04054b63          	bltz	a0,80005bce <sys_chdir+0x86>
    80005b7c:	f6040513          	addi	a0,s0,-160
    80005b80:	ffffe097          	auipc	ra,0xffffe
    80005b84:	52a080e7          	jalr	1322(ra) # 800040aa <namei>
    80005b88:	84aa                	mv	s1,a0
    80005b8a:	c131                	beqz	a0,80005bce <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b8c:	ffffe097          	auipc	ra,0xffffe
    80005b90:	d5e080e7          	jalr	-674(ra) # 800038ea <ilock>
  if(ip->type != T_DIR){
    80005b94:	04449703          	lh	a4,68(s1)
    80005b98:	4785                	li	a5,1
    80005b9a:	04f71063          	bne	a4,a5,80005bda <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b9e:	8526                	mv	a0,s1
    80005ba0:	ffffe097          	auipc	ra,0xffffe
    80005ba4:	e0e080e7          	jalr	-498(ra) # 800039ae <iunlock>
  iput(p->cwd);
    80005ba8:	15093503          	ld	a0,336(s2)
    80005bac:	ffffe097          	auipc	ra,0xffffe
    80005bb0:	efa080e7          	jalr	-262(ra) # 80003aa6 <iput>
  end_op();
    80005bb4:	ffffe097          	auipc	ra,0xffffe
    80005bb8:	794080e7          	jalr	1940(ra) # 80004348 <end_op>
  p->cwd = ip;
    80005bbc:	14993823          	sd	s1,336(s2)
  return 0;
    80005bc0:	4501                	li	a0,0
}
    80005bc2:	60ea                	ld	ra,152(sp)
    80005bc4:	644a                	ld	s0,144(sp)
    80005bc6:	64aa                	ld	s1,136(sp)
    80005bc8:	690a                	ld	s2,128(sp)
    80005bca:	610d                	addi	sp,sp,160
    80005bcc:	8082                	ret
    end_op();
    80005bce:	ffffe097          	auipc	ra,0xffffe
    80005bd2:	77a080e7          	jalr	1914(ra) # 80004348 <end_op>
    return -1;
    80005bd6:	557d                	li	a0,-1
    80005bd8:	b7ed                	j	80005bc2 <sys_chdir+0x7a>
    iunlockput(ip);
    80005bda:	8526                	mv	a0,s1
    80005bdc:	ffffe097          	auipc	ra,0xffffe
    80005be0:	f72080e7          	jalr	-142(ra) # 80003b4e <iunlockput>
    end_op();
    80005be4:	ffffe097          	auipc	ra,0xffffe
    80005be8:	764080e7          	jalr	1892(ra) # 80004348 <end_op>
    return -1;
    80005bec:	557d                	li	a0,-1
    80005bee:	bfd1                	j	80005bc2 <sys_chdir+0x7a>

0000000080005bf0 <sys_exec>:

uint64
sys_exec(void)
{
    80005bf0:	7145                	addi	sp,sp,-464
    80005bf2:	e786                	sd	ra,456(sp)
    80005bf4:	e3a2                	sd	s0,448(sp)
    80005bf6:	ff26                	sd	s1,440(sp)
    80005bf8:	fb4a                	sd	s2,432(sp)
    80005bfa:	f74e                	sd	s3,424(sp)
    80005bfc:	f352                	sd	s4,416(sp)
    80005bfe:	ef56                	sd	s5,408(sp)
    80005c00:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c02:	08000613          	li	a2,128
    80005c06:	f4040593          	addi	a1,s0,-192
    80005c0a:	4501                	li	a0,0
    80005c0c:	ffffd097          	auipc	ra,0xffffd
    80005c10:	162080e7          	jalr	354(ra) # 80002d6e <argstr>
    return -1;
    80005c14:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c16:	0e054c63          	bltz	a0,80005d0e <sys_exec+0x11e>
    80005c1a:	e3840593          	addi	a1,s0,-456
    80005c1e:	4505                	li	a0,1
    80005c20:	ffffd097          	auipc	ra,0xffffd
    80005c24:	12c080e7          	jalr	300(ra) # 80002d4c <argaddr>
    80005c28:	0e054363          	bltz	a0,80005d0e <sys_exec+0x11e>
  }
  memset(argv, 0, sizeof(argv));
    80005c2c:	e4040913          	addi	s2,s0,-448
    80005c30:	10000613          	li	a2,256
    80005c34:	4581                	li	a1,0
    80005c36:	854a                	mv	a0,s2
    80005c38:	ffffb097          	auipc	ra,0xffffb
    80005c3c:	0e8080e7          	jalr	232(ra) # 80000d20 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c40:	89ca                	mv	s3,s2
  memset(argv, 0, sizeof(argv));
    80005c42:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005c44:	02000a93          	li	s5,32
    80005c48:	00048a1b          	sext.w	s4,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c4c:	00349513          	slli	a0,s1,0x3
    80005c50:	e3040593          	addi	a1,s0,-464
    80005c54:	e3843783          	ld	a5,-456(s0)
    80005c58:	953e                	add	a0,a0,a5
    80005c5a:	ffffd097          	auipc	ra,0xffffd
    80005c5e:	034080e7          	jalr	52(ra) # 80002c8e <fetchaddr>
    80005c62:	02054a63          	bltz	a0,80005c96 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c66:	e3043783          	ld	a5,-464(s0)
    80005c6a:	cfa9                	beqz	a5,80005cc4 <sys_exec+0xd4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c6c:	ffffb097          	auipc	ra,0xffffb
    80005c70:	ec8080e7          	jalr	-312(ra) # 80000b34 <kalloc>
    80005c74:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80005c78:	cd19                	beqz	a0,80005c96 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c7a:	6605                	lui	a2,0x1
    80005c7c:	85aa                	mv	a1,a0
    80005c7e:	e3043503          	ld	a0,-464(s0)
    80005c82:	ffffd097          	auipc	ra,0xffffd
    80005c86:	060080e7          	jalr	96(ra) # 80002ce2 <fetchstr>
    80005c8a:	00054663          	bltz	a0,80005c96 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c8e:	0485                	addi	s1,s1,1
    80005c90:	0921                	addi	s2,s2,8
    80005c92:	fb549be3          	bne	s1,s5,80005c48 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c96:	e4043503          	ld	a0,-448(s0)
    kfree(argv[i]);
  return -1;
    80005c9a:	597d                	li	s2,-1
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c9c:	c92d                	beqz	a0,80005d0e <sys_exec+0x11e>
    kfree(argv[i]);
    80005c9e:	ffffb097          	auipc	ra,0xffffb
    80005ca2:	d96080e7          	jalr	-618(ra) # 80000a34 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ca6:	e4840493          	addi	s1,s0,-440
    80005caa:	10098993          	addi	s3,s3,256
    80005cae:	6088                	ld	a0,0(s1)
    80005cb0:	cd31                	beqz	a0,80005d0c <sys_exec+0x11c>
    kfree(argv[i]);
    80005cb2:	ffffb097          	auipc	ra,0xffffb
    80005cb6:	d82080e7          	jalr	-638(ra) # 80000a34 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cba:	04a1                	addi	s1,s1,8
    80005cbc:	ff3499e3          	bne	s1,s3,80005cae <sys_exec+0xbe>
  return -1;
    80005cc0:	597d                	li	s2,-1
    80005cc2:	a0b1                	j	80005d0e <sys_exec+0x11e>
      argv[i] = 0;
    80005cc4:	0a0e                	slli	s4,s4,0x3
    80005cc6:	fc040793          	addi	a5,s0,-64
    80005cca:	9a3e                	add	s4,s4,a5
    80005ccc:	e80a3023          	sd	zero,-384(s4)
  int ret = exec(path, argv);
    80005cd0:	e4040593          	addi	a1,s0,-448
    80005cd4:	f4040513          	addi	a0,s0,-192
    80005cd8:	fffff097          	auipc	ra,0xfffff
    80005cdc:	166080e7          	jalr	358(ra) # 80004e3e <exec>
    80005ce0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ce2:	e4043503          	ld	a0,-448(s0)
    80005ce6:	c505                	beqz	a0,80005d0e <sys_exec+0x11e>
    kfree(argv[i]);
    80005ce8:	ffffb097          	auipc	ra,0xffffb
    80005cec:	d4c080e7          	jalr	-692(ra) # 80000a34 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cf0:	e4840493          	addi	s1,s0,-440
    80005cf4:	10098993          	addi	s3,s3,256
    80005cf8:	6088                	ld	a0,0(s1)
    80005cfa:	c911                	beqz	a0,80005d0e <sys_exec+0x11e>
    kfree(argv[i]);
    80005cfc:	ffffb097          	auipc	ra,0xffffb
    80005d00:	d38080e7          	jalr	-712(ra) # 80000a34 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d04:	04a1                	addi	s1,s1,8
    80005d06:	ff3499e3          	bne	s1,s3,80005cf8 <sys_exec+0x108>
    80005d0a:	a011                	j	80005d0e <sys_exec+0x11e>
  return -1;
    80005d0c:	597d                	li	s2,-1
}
    80005d0e:	854a                	mv	a0,s2
    80005d10:	60be                	ld	ra,456(sp)
    80005d12:	641e                	ld	s0,448(sp)
    80005d14:	74fa                	ld	s1,440(sp)
    80005d16:	795a                	ld	s2,432(sp)
    80005d18:	79ba                	ld	s3,424(sp)
    80005d1a:	7a1a                	ld	s4,416(sp)
    80005d1c:	6afa                	ld	s5,408(sp)
    80005d1e:	6179                	addi	sp,sp,464
    80005d20:	8082                	ret

0000000080005d22 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d22:	7139                	addi	sp,sp,-64
    80005d24:	fc06                	sd	ra,56(sp)
    80005d26:	f822                	sd	s0,48(sp)
    80005d28:	f426                	sd	s1,40(sp)
    80005d2a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d2c:	ffffc097          	auipc	ra,0xffffc
    80005d30:	d00080e7          	jalr	-768(ra) # 80001a2c <myproc>
    80005d34:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d36:	fd840593          	addi	a1,s0,-40
    80005d3a:	4501                	li	a0,0
    80005d3c:	ffffd097          	auipc	ra,0xffffd
    80005d40:	010080e7          	jalr	16(ra) # 80002d4c <argaddr>
    return -1;
    80005d44:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d46:	0c054f63          	bltz	a0,80005e24 <sys_pipe+0x102>
  if(pipealloc(&rf, &wf) < 0)
    80005d4a:	fc840593          	addi	a1,s0,-56
    80005d4e:	fd040513          	addi	a0,s0,-48
    80005d52:	fffff097          	auipc	ra,0xfffff
    80005d56:	d9e080e7          	jalr	-610(ra) # 80004af0 <pipealloc>
    return -1;
    80005d5a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d5c:	0c054463          	bltz	a0,80005e24 <sys_pipe+0x102>
  fd0 = -1;
    80005d60:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d64:	fd043503          	ld	a0,-48(s0)
    80005d68:	fffff097          	auipc	ra,0xfffff
    80005d6c:	4e2080e7          	jalr	1250(ra) # 8000524a <fdalloc>
    80005d70:	fca42223          	sw	a0,-60(s0)
    80005d74:	08054b63          	bltz	a0,80005e0a <sys_pipe+0xe8>
    80005d78:	fc843503          	ld	a0,-56(s0)
    80005d7c:	fffff097          	auipc	ra,0xfffff
    80005d80:	4ce080e7          	jalr	1230(ra) # 8000524a <fdalloc>
    80005d84:	fca42023          	sw	a0,-64(s0)
    80005d88:	06054863          	bltz	a0,80005df8 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d8c:	4691                	li	a3,4
    80005d8e:	fc440613          	addi	a2,s0,-60
    80005d92:	fd843583          	ld	a1,-40(s0)
    80005d96:	68a8                	ld	a0,80(s1)
    80005d98:	ffffc097          	auipc	ra,0xffffc
    80005d9c:	912080e7          	jalr	-1774(ra) # 800016aa <copyout>
    80005da0:	02054063          	bltz	a0,80005dc0 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005da4:	4691                	li	a3,4
    80005da6:	fc040613          	addi	a2,s0,-64
    80005daa:	fd843583          	ld	a1,-40(s0)
    80005dae:	0591                	addi	a1,a1,4
    80005db0:	68a8                	ld	a0,80(s1)
    80005db2:	ffffc097          	auipc	ra,0xffffc
    80005db6:	8f8080e7          	jalr	-1800(ra) # 800016aa <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005dba:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dbc:	06055463          	bgez	a0,80005e24 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80005dc0:	fc442783          	lw	a5,-60(s0)
    80005dc4:	07e9                	addi	a5,a5,26
    80005dc6:	078e                	slli	a5,a5,0x3
    80005dc8:	97a6                	add	a5,a5,s1
    80005dca:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005dce:	fc042783          	lw	a5,-64(s0)
    80005dd2:	07e9                	addi	a5,a5,26
    80005dd4:	078e                	slli	a5,a5,0x3
    80005dd6:	94be                	add	s1,s1,a5
    80005dd8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005ddc:	fd043503          	ld	a0,-48(s0)
    80005de0:	fffff097          	auipc	ra,0xfffff
    80005de4:	9ec080e7          	jalr	-1556(ra) # 800047cc <fileclose>
    fileclose(wf);
    80005de8:	fc843503          	ld	a0,-56(s0)
    80005dec:	fffff097          	auipc	ra,0xfffff
    80005df0:	9e0080e7          	jalr	-1568(ra) # 800047cc <fileclose>
    return -1;
    80005df4:	57fd                	li	a5,-1
    80005df6:	a03d                	j	80005e24 <sys_pipe+0x102>
    if(fd0 >= 0)
    80005df8:	fc442783          	lw	a5,-60(s0)
    80005dfc:	0007c763          	bltz	a5,80005e0a <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005e00:	07e9                	addi	a5,a5,26
    80005e02:	078e                	slli	a5,a5,0x3
    80005e04:	94be                	add	s1,s1,a5
    80005e06:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e0a:	fd043503          	ld	a0,-48(s0)
    80005e0e:	fffff097          	auipc	ra,0xfffff
    80005e12:	9be080e7          	jalr	-1602(ra) # 800047cc <fileclose>
    fileclose(wf);
    80005e16:	fc843503          	ld	a0,-56(s0)
    80005e1a:	fffff097          	auipc	ra,0xfffff
    80005e1e:	9b2080e7          	jalr	-1614(ra) # 800047cc <fileclose>
    return -1;
    80005e22:	57fd                	li	a5,-1
}
    80005e24:	853e                	mv	a0,a5
    80005e26:	70e2                	ld	ra,56(sp)
    80005e28:	7442                	ld	s0,48(sp)
    80005e2a:	74a2                	ld	s1,40(sp)
    80005e2c:	6121                	addi	sp,sp,64
    80005e2e:	8082                	ret

0000000080005e30 <sys_mmap>:

uint64
sys_mmap(void) {
    80005e30:	711d                	addi	sp,sp,-96
    80005e32:	ec86                	sd	ra,88(sp)
    80005e34:	e8a2                	sd	s0,80(sp)
    80005e36:	e4a6                	sd	s1,72(sp)
    80005e38:	e0ca                	sd	s2,64(sp)
    80005e3a:	fc4e                	sd	s3,56(sp)
    80005e3c:	f852                	sd	s4,48(sp)
    80005e3e:	1080                	addi	s0,sp,96
  uint64 failure = (uint64)((char *) -1);
  struct proc* p = myproc();
    80005e40:	ffffc097          	auipc	ra,0xffffc
    80005e44:	bec080e7          	jalr	-1044(ra) # 80001a2c <myproc>
    80005e48:	892a                	mv	s2,a0
  uint64 addr;
  int length, prot, flags, fd, offset;
  struct file* f;

  // parse argument
  if (argaddr(0, &addr) < 0 || argint(1, &length) < 0 || argint(2, &prot) < 0
    80005e4a:	fc840593          	addi	a1,s0,-56
    80005e4e:	4501                	li	a0,0
    80005e50:	ffffd097          	auipc	ra,0xffffd
    80005e54:	efc080e7          	jalr	-260(ra) # 80002d4c <argaddr>
      || argint(3, &flags) < 0 || argfd(4, &fd, &f) < 0 || argint(5, &offset) < 0)
    return failure;
    80005e58:	57fd                	li	a5,-1
  if (argaddr(0, &addr) < 0 || argint(1, &length) < 0 || argint(2, &prot) < 0
    80005e5a:	0c054363          	bltz	a0,80005f20 <sys_mmap+0xf0>
    80005e5e:	fc440593          	addi	a1,s0,-60
    80005e62:	4505                	li	a0,1
    80005e64:	ffffd097          	auipc	ra,0xffffd
    80005e68:	ec6080e7          	jalr	-314(ra) # 80002d2a <argint>
    return failure;
    80005e6c:	57fd                	li	a5,-1
  if (argaddr(0, &addr) < 0 || argint(1, &length) < 0 || argint(2, &prot) < 0
    80005e6e:	0a054963          	bltz	a0,80005f20 <sys_mmap+0xf0>
    80005e72:	fc040593          	addi	a1,s0,-64
    80005e76:	4509                	li	a0,2
    80005e78:	ffffd097          	auipc	ra,0xffffd
    80005e7c:	eb2080e7          	jalr	-334(ra) # 80002d2a <argint>
    return failure;
    80005e80:	57fd                	li	a5,-1
  if (argaddr(0, &addr) < 0 || argint(1, &length) < 0 || argint(2, &prot) < 0
    80005e82:	08054f63          	bltz	a0,80005f20 <sys_mmap+0xf0>
      || argint(3, &flags) < 0 || argfd(4, &fd, &f) < 0 || argint(5, &offset) < 0)
    80005e86:	fbc40593          	addi	a1,s0,-68
    80005e8a:	450d                	li	a0,3
    80005e8c:	ffffd097          	auipc	ra,0xffffd
    80005e90:	e9e080e7          	jalr	-354(ra) # 80002d2a <argint>
    return failure;
    80005e94:	57fd                	li	a5,-1
      || argint(3, &flags) < 0 || argfd(4, &fd, &f) < 0 || argint(5, &offset) < 0)
    80005e96:	08054563          	bltz	a0,80005f20 <sys_mmap+0xf0>
    80005e9a:	fa840613          	addi	a2,s0,-88
    80005e9e:	fb840593          	addi	a1,s0,-72
    80005ea2:	4511                	li	a0,4
    80005ea4:	fffff097          	auipc	ra,0xfffff
    80005ea8:	33e080e7          	jalr	830(ra) # 800051e2 <argfd>
    return failure;
    80005eac:	57fd                	li	a5,-1
      || argint(3, &flags) < 0 || argfd(4, &fd, &f) < 0 || argint(5, &offset) < 0)
    80005eae:	06054963          	bltz	a0,80005f20 <sys_mmap+0xf0>
    80005eb2:	fb440593          	addi	a1,s0,-76
    80005eb6:	4515                	li	a0,5
    80005eb8:	ffffd097          	auipc	ra,0xffffd
    80005ebc:	e72080e7          	jalr	-398(ra) # 80002d2a <argint>
    80005ec0:	0c054d63          	bltz	a0,80005f9a <sys_mmap+0x16a>

  // sanity check
  length = PGROUNDUP(length);
    80005ec4:	fc442683          	lw	a3,-60(s0)
    80005ec8:	6785                	lui	a5,0x1
    80005eca:	37fd                	addiw	a5,a5,-1
    80005ecc:	9ebd                	addw	a3,a3,a5
    80005ece:	77fd                	lui	a5,0xfffff
    80005ed0:	8efd                	and	a3,a3,a5
    80005ed2:	2681                	sext.w	a3,a3
    80005ed4:	fcd42223          	sw	a3,-60(s0)
  if (MAXVA - length < p->sz)
    80005ed8:	04893583          	ld	a1,72(s2)
    80005edc:	4705                	li	a4,1
    80005ede:	171a                	slli	a4,a4,0x26
    80005ee0:	8f15                	sub	a4,a4,a3
    return failure;
    80005ee2:	57fd                	li	a5,-1
  if (MAXVA - length < p->sz)
    80005ee4:	02b76e63          	bltu	a4,a1,80005f20 <sys_mmap+0xf0>
  if (!f->readable && (prot & PROT_READ))
    80005ee8:	fa843503          	ld	a0,-88(s0)
    80005eec:	00854783          	lbu	a5,8(a0)
    80005ef0:	e791                	bnez	a5,80005efc <sys_mmap+0xcc>
    80005ef2:	fc042703          	lw	a4,-64(s0)
    80005ef6:	8b05                	andi	a4,a4,1
    return failure;
    80005ef8:	57fd                	li	a5,-1
  if (!f->readable && (prot & PROT_READ))
    80005efa:	e31d                	bnez	a4,80005f20 <sys_mmap+0xf0>
  if (!f->writable && (prot & PROT_WRITE) && (flags == MAP_SHARED))
    80005efc:	00954783          	lbu	a5,9(a0)
    80005f00:	cb8d                	beqz	a5,80005f32 <sys_mmap+0x102>
    return failure;

  // find an empty vma slot and fill in
  for (int i = 0; i < NVMA; i++) {
    struct vma* vma = &p->vmas[i];
    if (vma->valid == 0) {
    80005f02:	16892483          	lw	s1,360(s2)
    80005f06:	c0a9                	beqz	s1,80005f48 <sys_mmap+0x118>
    80005f08:	19890793          	addi	a5,s2,408
  for (int i = 0; i < NVMA; i++) {
    80005f0c:	4485                	li	s1,1
    80005f0e:	4641                	li	a2,16
    if (vma->valid == 0) {
    80005f10:	4398                	lw	a4,0(a5)
    80005f12:	cb1d                	beqz	a4,80005f48 <sys_mmap+0x118>
  for (int i = 0; i < NVMA; i++) {
    80005f14:	2485                	addiw	s1,s1,1
    80005f16:	03078793          	addi	a5,a5,48 # fffffffffffff030 <end+0xffffffff7ffcd030>
    80005f1a:	fec49be3          	bne	s1,a2,80005f10 <sys_mmap+0xe0>
      return vma->addr;
    }
  }

  // all vma are in use
  return failure;
    80005f1e:	57fd                	li	a5,-1
}
    80005f20:	853e                	mv	a0,a5
    80005f22:	60e6                	ld	ra,88(sp)
    80005f24:	6446                	ld	s0,80(sp)
    80005f26:	64a6                	ld	s1,72(sp)
    80005f28:	6906                	ld	s2,64(sp)
    80005f2a:	79e2                	ld	s3,56(sp)
    80005f2c:	7a42                	ld	s4,48(sp)
    80005f2e:	6125                	addi	sp,sp,96
    80005f30:	8082                	ret
  if (!f->writable && (prot & PROT_WRITE) && (flags == MAP_SHARED))
    80005f32:	fc042783          	lw	a5,-64(s0)
    80005f36:	8b89                	andi	a5,a5,2
    80005f38:	d7e9                	beqz	a5,80005f02 <sys_mmap+0xd2>
    80005f3a:	fbc42703          	lw	a4,-68(s0)
    80005f3e:	4785                	li	a5,1
    80005f40:	fcf711e3          	bne	a4,a5,80005f02 <sys_mmap+0xd2>
    return failure;
    80005f44:	57fd                	li	a5,-1
    80005f46:	bfe9                	j	80005f20 <sys_mmap+0xf0>
      vma->valid = 1;
    80005f48:	00149a13          	slli	s4,s1,0x1
    80005f4c:	009a09b3          	add	s3,s4,s1
    80005f50:	0992                	slli	s3,s3,0x4
    80005f52:	99ca                	add	s3,s3,s2
    80005f54:	4785                	li	a5,1
    80005f56:	16f9a423          	sw	a5,360(s3)
      vma->addr = p->sz;
    80005f5a:	16b9b823          	sd	a1,368(s3)
      p->sz += length;
    80005f5e:	95b6                	add	a1,a1,a3
    80005f60:	04b93423          	sd	a1,72(s2)
      vma->length = length;
    80005f64:	16d9ac23          	sw	a3,376(s3)
      vma->prot = prot;
    80005f68:	fc042783          	lw	a5,-64(s0)
    80005f6c:	16f9ae23          	sw	a5,380(s3)
      vma->flags = flags;
    80005f70:	fbc42783          	lw	a5,-68(s0)
    80005f74:	18f9a023          	sw	a5,384(s3)
      vma->fd = fd;
    80005f78:	fb842783          	lw	a5,-72(s0)
    80005f7c:	18f9a223          	sw	a5,388(s3)
      vma->f = f;
    80005f80:	18a9b823          	sd	a0,400(s3)
      filedup(f);
    80005f84:	ffffe097          	auipc	ra,0xffffe
    80005f88:	7f6080e7          	jalr	2038(ra) # 8000477a <filedup>
      vma->offset = offset;
    80005f8c:	fb442783          	lw	a5,-76(s0)
    80005f90:	18f9a423          	sw	a5,392(s3)
      return vma->addr;
    80005f94:	1709b783          	ld	a5,368(s3)
    80005f98:	b761                	j	80005f20 <sys_mmap+0xf0>
    return failure;
    80005f9a:	57fd                	li	a5,-1
    80005f9c:	b751                	j	80005f20 <sys_mmap+0xf0>

0000000080005f9e <sys_munmap>:

uint64
sys_munmap(void) {
    80005f9e:	7139                	addi	sp,sp,-64
    80005fa0:	fc06                	sd	ra,56(sp)
    80005fa2:	f822                	sd	s0,48(sp)
    80005fa4:	f426                	sd	s1,40(sp)
    80005fa6:	f04a                	sd	s2,32(sp)
    80005fa8:	ec4e                	sd	s3,24(sp)
    80005faa:	0080                	addi	s0,sp,64
  uint64 addr;
  int length;
  if (argaddr(0, &addr) < 0 || argint(1, &length) < 0)
    80005fac:	fc840593          	addi	a1,s0,-56
    80005fb0:	4501                	li	a0,0
    80005fb2:	ffffd097          	auipc	ra,0xffffd
    80005fb6:	d9a080e7          	jalr	-614(ra) # 80002d4c <argaddr>
    80005fba:	18054d63          	bltz	a0,80006154 <sys_munmap+0x1b6>
    80005fbe:	fc440593          	addi	a1,s0,-60
    80005fc2:	4505                	li	a0,1
    80005fc4:	ffffd097          	auipc	ra,0xffffd
    80005fc8:	d66080e7          	jalr	-666(ra) # 80002d2a <argint>
    80005fcc:	18054663          	bltz	a0,80006158 <sys_munmap+0x1ba>
    return -1;
  struct proc *p = myproc();
    80005fd0:	ffffc097          	auipc	ra,0xffffc
    80005fd4:	a5c080e7          	jalr	-1444(ra) # 80001a2c <myproc>
    80005fd8:	892a                	mv	s2,a0
  struct vma* vma = 0;
  int idx = -1;
  // find the corresponding vma
  for (int i = 0; i < NVMA; i++) {
    if (p->vmas[i].valid && addr >= p->vmas[i].addr && addr <= p->vmas[i].addr + p->vmas[i].length) {
    80005fda:	fc843583          	ld	a1,-56(s0)
    80005fde:	16850793          	addi	a5,a0,360
  for (int i = 0; i < NVMA; i++) {
    80005fe2:	4481                	li	s1,0
    80005fe4:	4641                	li	a2,16
    80005fe6:	a031                	j	80005ff2 <sys_munmap+0x54>
    80005fe8:	2485                	addiw	s1,s1,1
    80005fea:	03078793          	addi	a5,a5,48
    80005fee:	0ac48963          	beq	s1,a2,800060a0 <sys_munmap+0x102>
    if (p->vmas[i].valid && addr >= p->vmas[i].addr && addr <= p->vmas[i].addr + p->vmas[i].length) {
    80005ff2:	4398                	lw	a4,0(a5)
    80005ff4:	db75                	beqz	a4,80005fe8 <sys_munmap+0x4a>
    80005ff6:	6798                	ld	a4,8(a5)
    80005ff8:	fee5e8e3          	bltu	a1,a4,80005fe8 <sys_munmap+0x4a>
    80005ffc:	4b94                	lw	a3,16(a5)
    80005ffe:	9736                	add	a4,a4,a3
    80006000:	feb764e3          	bltu	a4,a1,80005fe8 <sys_munmap+0x4a>
      idx = i;
      vma = &p->vmas[i];
      break;
    }
  }
  if (idx == -1)
    80006004:	57fd                	li	a5,-1
    80006006:	14f48b63          	beq	s1,a5,8000615c <sys_munmap+0x1be>
    // not in a valid VMA
    return -1;

  addr = PGROUNDDOWN(addr);
    8000600a:	77fd                	lui	a5,0xfffff
    8000600c:	8dfd                	and	a1,a1,a5
    8000600e:	fcb43423          	sd	a1,-56(s0)
  length = PGROUNDUP(length);
    80006012:	fc442603          	lw	a2,-60(s0)
    80006016:	6785                	lui	a5,0x1
    80006018:	37fd                	addiw	a5,a5,-1
    8000601a:	9e3d                	addw	a2,a2,a5
    8000601c:	77fd                	lui	a5,0xfffff
    8000601e:	8e7d                	and	a2,a2,a5
    80006020:	2601                	sext.w	a2,a2
    80006022:	fcc42223          	sw	a2,-60(s0)
  if (vma->flags & MAP_SHARED) {
    80006026:	00149793          	slli	a5,s1,0x1
    8000602a:	97a6                	add	a5,a5,s1
    8000602c:	0792                	slli	a5,a5,0x4
    8000602e:	97ca                	add	a5,a5,s2
    80006030:	1807a783          	lw	a5,384(a5) # fffffffffffff180 <end+0xffffffff7ffcd180>
    80006034:	8b85                	andi	a5,a5,1
    80006036:	efad                	bnez	a5,800060b0 <sys_munmap+0x112>
    // write back
    if (filewrite(vma->f, addr, length) < 0) {
      printf("munmap: filewrite < 0\n");
    }
  }
  uvmunmap(p->pagetable, addr, length/PGSIZE, 1);
    80006038:	fc442783          	lw	a5,-60(s0)
    8000603c:	41f7d61b          	sraiw	a2,a5,0x1f
    80006040:	0146561b          	srliw	a2,a2,0x14
    80006044:	9e3d                	addw	a2,a2,a5
    80006046:	4685                	li	a3,1
    80006048:	40c6561b          	sraiw	a2,a2,0xc
    8000604c:	fc843583          	ld	a1,-56(s0)
    80006050:	05093503          	ld	a0,80(s2)
    80006054:	ffffb097          	auipc	ra,0xffffb
    80006058:	276080e7          	jalr	630(ra) # 800012ca <uvmunmap>

  // change the mmap parameter
  if (addr == vma->addr && length == vma->length) {
    8000605c:	00149793          	slli	a5,s1,0x1
    80006060:	97a6                	add	a5,a5,s1
    80006062:	0792                	slli	a5,a5,0x4
    80006064:	97ca                	add	a5,a5,s2
    80006066:	1707b703          	ld	a4,368(a5)
    8000606a:	fc843683          	ld	a3,-56(s0)
    8000606e:	06d70763          	beq	a4,a3,800060dc <sys_munmap+0x13e>
  } else if (addr == vma->addr) {
    // cover the beginning
    vma->addr += length;
    vma->length -= length;
    vma->offset += length;
  } else if ((addr + length) == (vma->addr + vma->length)) {
    80006072:	fc442583          	lw	a1,-60(s0)
    80006076:	00149793          	slli	a5,s1,0x1
    8000607a:	97a6                	add	a5,a5,s1
    8000607c:	0792                	slli	a5,a5,0x4
    8000607e:	97ca                	add	a5,a5,s2
    80006080:	1787a603          	lw	a2,376(a5)
    80006084:	96ae                	add	a3,a3,a1
    80006086:	9732                	add	a4,a4,a2
    80006088:	0ae69e63          	bne	a3,a4,80006144 <sys_munmap+0x1a6>
    // cover the end
    vma->length -= length;
    8000608c:	00149793          	slli	a5,s1,0x1
    80006090:	94be                	add	s1,s1,a5
    80006092:	0492                	slli	s1,s1,0x4
    80006094:	9926                	add	s2,s2,s1
    80006096:	9e0d                	subw	a2,a2,a1
    80006098:	16c92c23          	sw	a2,376(s2)
  } else {
    panic("munmap neither cover beginning or end of mapped region");
  }

  return 0;
    8000609c:	4501                	li	a0,0
    8000609e:	a011                	j	800060a2 <sys_munmap+0x104>
    return -1;
    800060a0:	557d                	li	a0,-1
}
    800060a2:	70e2                	ld	ra,56(sp)
    800060a4:	7442                	ld	s0,48(sp)
    800060a6:	74a2                	ld	s1,40(sp)
    800060a8:	7902                	ld	s2,32(sp)
    800060aa:	69e2                	ld	s3,24(sp)
    800060ac:	6121                	addi	sp,sp,64
    800060ae:	8082                	ret
    if (filewrite(vma->f, addr, length) < 0) {
    800060b0:	00149793          	slli	a5,s1,0x1
    800060b4:	97a6                	add	a5,a5,s1
    800060b6:	0792                	slli	a5,a5,0x4
    800060b8:	97ca                	add	a5,a5,s2
    800060ba:	1907b503          	ld	a0,400(a5)
    800060be:	fffff097          	auipc	ra,0xfffff
    800060c2:	90a080e7          	jalr	-1782(ra) # 800049c8 <filewrite>
    800060c6:	f60559e3          	bgez	a0,80006038 <sys_munmap+0x9a>
      printf("munmap: filewrite < 0\n");
    800060ca:	00002517          	auipc	a0,0x2
    800060ce:	64e50513          	addi	a0,a0,1614 # 80008718 <syscalls+0x358>
    800060d2:	ffffa097          	auipc	ra,0xffffa
    800060d6:	4d0080e7          	jalr	1232(ra) # 800005a2 <printf>
    800060da:	bfb9                	j	80006038 <sys_munmap+0x9a>
  if (addr == vma->addr && length == vma->length) {
    800060dc:	fc442603          	lw	a2,-60(s0)
    800060e0:	00149793          	slli	a5,s1,0x1
    800060e4:	97a6                	add	a5,a5,s1
    800060e6:	0792                	slli	a5,a5,0x4
    800060e8:	97ca                	add	a5,a5,s2
    800060ea:	1787a783          	lw	a5,376(a5)
    800060ee:	02c78763          	beq	a5,a2,8000611c <sys_munmap+0x17e>
    vma->addr += length;
    800060f2:	00149693          	slli	a3,s1,0x1
    800060f6:	009687b3          	add	a5,a3,s1
    800060fa:	0792                	slli	a5,a5,0x4
    800060fc:	97ca                	add	a5,a5,s2
    800060fe:	9732                	add	a4,a4,a2
    80006100:	16e7b823          	sd	a4,368(a5)
    vma->length -= length;
    80006104:	1787a703          	lw	a4,376(a5)
    80006108:	9f11                	subw	a4,a4,a2
    8000610a:	16e7ac23          	sw	a4,376(a5)
    vma->offset += length;
    8000610e:	1887a703          	lw	a4,392(a5)
    80006112:	9e39                	addw	a2,a2,a4
    80006114:	18c7a423          	sw	a2,392(a5)
  return 0;
    80006118:	4501                	li	a0,0
    8000611a:	b761                	j	800060a2 <sys_munmap+0x104>
    fileclose(vma->f);
    8000611c:	00149993          	slli	s3,s1,0x1
    80006120:	009987b3          	add	a5,s3,s1
    80006124:	0792                	slli	a5,a5,0x4
    80006126:	97ca                	add	a5,a5,s2
    80006128:	1907b503          	ld	a0,400(a5)
    8000612c:	ffffe097          	auipc	ra,0xffffe
    80006130:	6a0080e7          	jalr	1696(ra) # 800047cc <fileclose>
    vma->valid = 0;
    80006134:	009987b3          	add	a5,s3,s1
    80006138:	0792                	slli	a5,a5,0x4
    8000613a:	993e                	add	s2,s2,a5
    8000613c:	16092423          	sw	zero,360(s2)
  return 0;
    80006140:	4501                	li	a0,0
    vma->valid = 0;
    80006142:	b785                	j	800060a2 <sys_munmap+0x104>
    panic("munmap neither cover beginning or end of mapped region");
    80006144:	00002517          	auipc	a0,0x2
    80006148:	5ec50513          	addi	a0,a0,1516 # 80008730 <syscalls+0x370>
    8000614c:	ffffa097          	auipc	ra,0xffffa
    80006150:	40c080e7          	jalr	1036(ra) # 80000558 <panic>
    return -1;
    80006154:	557d                	li	a0,-1
    80006156:	b7b1                	j	800060a2 <sys_munmap+0x104>
    80006158:	557d                	li	a0,-1
    8000615a:	b7a1                	j	800060a2 <sys_munmap+0x104>
    return -1;
    8000615c:	557d                	li	a0,-1
    8000615e:	b791                	j	800060a2 <sys_munmap+0x104>

0000000080006160 <kernelvec>:
    80006160:	7111                	addi	sp,sp,-256
    80006162:	e006                	sd	ra,0(sp)
    80006164:	e40a                	sd	sp,8(sp)
    80006166:	e80e                	sd	gp,16(sp)
    80006168:	ec12                	sd	tp,24(sp)
    8000616a:	f016                	sd	t0,32(sp)
    8000616c:	f41a                	sd	t1,40(sp)
    8000616e:	f81e                	sd	t2,48(sp)
    80006170:	fc22                	sd	s0,56(sp)
    80006172:	e0a6                	sd	s1,64(sp)
    80006174:	e4aa                	sd	a0,72(sp)
    80006176:	e8ae                	sd	a1,80(sp)
    80006178:	ecb2                	sd	a2,88(sp)
    8000617a:	f0b6                	sd	a3,96(sp)
    8000617c:	f4ba                	sd	a4,104(sp)
    8000617e:	f8be                	sd	a5,112(sp)
    80006180:	fcc2                	sd	a6,120(sp)
    80006182:	e146                	sd	a7,128(sp)
    80006184:	e54a                	sd	s2,136(sp)
    80006186:	e94e                	sd	s3,144(sp)
    80006188:	ed52                	sd	s4,152(sp)
    8000618a:	f156                	sd	s5,160(sp)
    8000618c:	f55a                	sd	s6,168(sp)
    8000618e:	f95e                	sd	s7,176(sp)
    80006190:	fd62                	sd	s8,184(sp)
    80006192:	e1e6                	sd	s9,192(sp)
    80006194:	e5ea                	sd	s10,200(sp)
    80006196:	e9ee                	sd	s11,208(sp)
    80006198:	edf2                	sd	t3,216(sp)
    8000619a:	f1f6                	sd	t4,224(sp)
    8000619c:	f5fa                	sd	t5,232(sp)
    8000619e:	f9fe                	sd	t6,240(sp)
    800061a0:	9b7fc0ef          	jal	ra,80002b56 <kerneltrap>
    800061a4:	6082                	ld	ra,0(sp)
    800061a6:	6122                	ld	sp,8(sp)
    800061a8:	61c2                	ld	gp,16(sp)
    800061aa:	7282                	ld	t0,32(sp)
    800061ac:	7322                	ld	t1,40(sp)
    800061ae:	73c2                	ld	t2,48(sp)
    800061b0:	7462                	ld	s0,56(sp)
    800061b2:	6486                	ld	s1,64(sp)
    800061b4:	6526                	ld	a0,72(sp)
    800061b6:	65c6                	ld	a1,80(sp)
    800061b8:	6666                	ld	a2,88(sp)
    800061ba:	7686                	ld	a3,96(sp)
    800061bc:	7726                	ld	a4,104(sp)
    800061be:	77c6                	ld	a5,112(sp)
    800061c0:	7866                	ld	a6,120(sp)
    800061c2:	688a                	ld	a7,128(sp)
    800061c4:	692a                	ld	s2,136(sp)
    800061c6:	69ca                	ld	s3,144(sp)
    800061c8:	6a6a                	ld	s4,152(sp)
    800061ca:	7a8a                	ld	s5,160(sp)
    800061cc:	7b2a                	ld	s6,168(sp)
    800061ce:	7bca                	ld	s7,176(sp)
    800061d0:	7c6a                	ld	s8,184(sp)
    800061d2:	6c8e                	ld	s9,192(sp)
    800061d4:	6d2e                	ld	s10,200(sp)
    800061d6:	6dce                	ld	s11,208(sp)
    800061d8:	6e6e                	ld	t3,216(sp)
    800061da:	7e8e                	ld	t4,224(sp)
    800061dc:	7f2e                	ld	t5,232(sp)
    800061de:	7fce                	ld	t6,240(sp)
    800061e0:	6111                	addi	sp,sp,256
    800061e2:	10200073          	sret
    800061e6:	00000013          	nop
    800061ea:	00000013          	nop
    800061ee:	0001                	nop

00000000800061f0 <timervec>:
    800061f0:	34051573          	csrrw	a0,mscratch,a0
    800061f4:	e10c                	sd	a1,0(a0)
    800061f6:	e510                	sd	a2,8(a0)
    800061f8:	e914                	sd	a3,16(a0)
    800061fa:	6d0c                	ld	a1,24(a0)
    800061fc:	7110                	ld	a2,32(a0)
    800061fe:	6194                	ld	a3,0(a1)
    80006200:	96b2                	add	a3,a3,a2
    80006202:	e194                	sd	a3,0(a1)
    80006204:	4589                	li	a1,2
    80006206:	14459073          	csrw	sip,a1
    8000620a:	6914                	ld	a3,16(a0)
    8000620c:	6510                	ld	a2,8(a0)
    8000620e:	610c                	ld	a1,0(a0)
    80006210:	34051573          	csrrw	a0,mscratch,a0
    80006214:	30200073          	mret
	...

000000008000621a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000621a:	1141                	addi	sp,sp,-16
    8000621c:	e422                	sd	s0,8(sp)
    8000621e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006220:	0c0007b7          	lui	a5,0xc000
    80006224:	4705                	li	a4,1
    80006226:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006228:	c3d8                	sw	a4,4(a5)
}
    8000622a:	6422                	ld	s0,8(sp)
    8000622c:	0141                	addi	sp,sp,16
    8000622e:	8082                	ret

0000000080006230 <plicinithart>:

void
plicinithart(void)
{
    80006230:	1141                	addi	sp,sp,-16
    80006232:	e406                	sd	ra,8(sp)
    80006234:	e022                	sd	s0,0(sp)
    80006236:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006238:	ffffb097          	auipc	ra,0xffffb
    8000623c:	7c8080e7          	jalr	1992(ra) # 80001a00 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006240:	0085171b          	slliw	a4,a0,0x8
    80006244:	0c0027b7          	lui	a5,0xc002
    80006248:	97ba                	add	a5,a5,a4
    8000624a:	40200713          	li	a4,1026
    8000624e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006252:	00d5151b          	slliw	a0,a0,0xd
    80006256:	0c2017b7          	lui	a5,0xc201
    8000625a:	953e                	add	a0,a0,a5
    8000625c:	00052023          	sw	zero,0(a0)
}
    80006260:	60a2                	ld	ra,8(sp)
    80006262:	6402                	ld	s0,0(sp)
    80006264:	0141                	addi	sp,sp,16
    80006266:	8082                	ret

0000000080006268 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006268:	1141                	addi	sp,sp,-16
    8000626a:	e406                	sd	ra,8(sp)
    8000626c:	e022                	sd	s0,0(sp)
    8000626e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006270:	ffffb097          	auipc	ra,0xffffb
    80006274:	790080e7          	jalr	1936(ra) # 80001a00 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006278:	00d5151b          	slliw	a0,a0,0xd
    8000627c:	0c2017b7          	lui	a5,0xc201
    80006280:	97aa                	add	a5,a5,a0
  return irq;
}
    80006282:	43c8                	lw	a0,4(a5)
    80006284:	60a2                	ld	ra,8(sp)
    80006286:	6402                	ld	s0,0(sp)
    80006288:	0141                	addi	sp,sp,16
    8000628a:	8082                	ret

000000008000628c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000628c:	1101                	addi	sp,sp,-32
    8000628e:	ec06                	sd	ra,24(sp)
    80006290:	e822                	sd	s0,16(sp)
    80006292:	e426                	sd	s1,8(sp)
    80006294:	1000                	addi	s0,sp,32
    80006296:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006298:	ffffb097          	auipc	ra,0xffffb
    8000629c:	768080e7          	jalr	1896(ra) # 80001a00 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800062a0:	00d5151b          	slliw	a0,a0,0xd
    800062a4:	0c2017b7          	lui	a5,0xc201
    800062a8:	97aa                	add	a5,a5,a0
    800062aa:	c3c4                	sw	s1,4(a5)
}
    800062ac:	60e2                	ld	ra,24(sp)
    800062ae:	6442                	ld	s0,16(sp)
    800062b0:	64a2                	ld	s1,8(sp)
    800062b2:	6105                	addi	sp,sp,32
    800062b4:	8082                	ret

00000000800062b6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800062b6:	1141                	addi	sp,sp,-16
    800062b8:	e406                	sd	ra,8(sp)
    800062ba:	e022                	sd	s0,0(sp)
    800062bc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800062be:	479d                	li	a5,7
    800062c0:	06a7c963          	blt	a5,a0,80006332 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800062c4:	00029797          	auipc	a5,0x29
    800062c8:	d3c78793          	addi	a5,a5,-708 # 8002f000 <disk>
    800062cc:	00a78733          	add	a4,a5,a0
    800062d0:	6789                	lui	a5,0x2
    800062d2:	97ba                	add	a5,a5,a4
    800062d4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800062d8:	e7ad                	bnez	a5,80006342 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800062da:	00451793          	slli	a5,a0,0x4
    800062de:	0002b717          	auipc	a4,0x2b
    800062e2:	d2270713          	addi	a4,a4,-734 # 80031000 <disk+0x2000>
    800062e6:	6314                	ld	a3,0(a4)
    800062e8:	96be                	add	a3,a3,a5
    800062ea:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800062ee:	6314                	ld	a3,0(a4)
    800062f0:	96be                	add	a3,a3,a5
    800062f2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800062f6:	6314                	ld	a3,0(a4)
    800062f8:	96be                	add	a3,a3,a5
    800062fa:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800062fe:	6318                	ld	a4,0(a4)
    80006300:	97ba                	add	a5,a5,a4
    80006302:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006306:	00029797          	auipc	a5,0x29
    8000630a:	cfa78793          	addi	a5,a5,-774 # 8002f000 <disk>
    8000630e:	97aa                	add	a5,a5,a0
    80006310:	6509                	lui	a0,0x2
    80006312:	953e                	add	a0,a0,a5
    80006314:	4785                	li	a5,1
    80006316:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000631a:	0002b517          	auipc	a0,0x2b
    8000631e:	cfe50513          	addi	a0,a0,-770 # 80031018 <disk+0x2018>
    80006322:	ffffc097          	auipc	ra,0xffffc
    80006326:	186080e7          	jalr	390(ra) # 800024a8 <wakeup>
}
    8000632a:	60a2                	ld	ra,8(sp)
    8000632c:	6402                	ld	s0,0(sp)
    8000632e:	0141                	addi	sp,sp,16
    80006330:	8082                	ret
    panic("free_desc 1");
    80006332:	00002517          	auipc	a0,0x2
    80006336:	43650513          	addi	a0,a0,1078 # 80008768 <syscalls+0x3a8>
    8000633a:	ffffa097          	auipc	ra,0xffffa
    8000633e:	21e080e7          	jalr	542(ra) # 80000558 <panic>
    panic("free_desc 2");
    80006342:	00002517          	auipc	a0,0x2
    80006346:	43650513          	addi	a0,a0,1078 # 80008778 <syscalls+0x3b8>
    8000634a:	ffffa097          	auipc	ra,0xffffa
    8000634e:	20e080e7          	jalr	526(ra) # 80000558 <panic>

0000000080006352 <virtio_disk_init>:
{
    80006352:	1101                	addi	sp,sp,-32
    80006354:	ec06                	sd	ra,24(sp)
    80006356:	e822                	sd	s0,16(sp)
    80006358:	e426                	sd	s1,8(sp)
    8000635a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000635c:	00002597          	auipc	a1,0x2
    80006360:	42c58593          	addi	a1,a1,1068 # 80008788 <syscalls+0x3c8>
    80006364:	0002b517          	auipc	a0,0x2b
    80006368:	dc450513          	addi	a0,a0,-572 # 80031128 <disk+0x2128>
    8000636c:	ffffb097          	auipc	ra,0xffffb
    80006370:	828080e7          	jalr	-2008(ra) # 80000b94 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006374:	100017b7          	lui	a5,0x10001
    80006378:	4398                	lw	a4,0(a5)
    8000637a:	2701                	sext.w	a4,a4
    8000637c:	747277b7          	lui	a5,0x74727
    80006380:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006384:	0ef71163          	bne	a4,a5,80006466 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006388:	100017b7          	lui	a5,0x10001
    8000638c:	43dc                	lw	a5,4(a5)
    8000638e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006390:	4705                	li	a4,1
    80006392:	0ce79a63          	bne	a5,a4,80006466 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006396:	100017b7          	lui	a5,0x10001
    8000639a:	479c                	lw	a5,8(a5)
    8000639c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000639e:	4709                	li	a4,2
    800063a0:	0ce79363          	bne	a5,a4,80006466 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800063a4:	100017b7          	lui	a5,0x10001
    800063a8:	47d8                	lw	a4,12(a5)
    800063aa:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063ac:	554d47b7          	lui	a5,0x554d4
    800063b0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800063b4:	0af71963          	bne	a4,a5,80006466 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063b8:	100017b7          	lui	a5,0x10001
    800063bc:	4705                	li	a4,1
    800063be:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063c0:	470d                	li	a4,3
    800063c2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800063c4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800063c6:	c7ffe737          	lui	a4,0xc7ffe
    800063ca:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fcc75f>
    800063ce:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800063d0:	2701                	sext.w	a4,a4
    800063d2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063d4:	472d                	li	a4,11
    800063d6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063d8:	473d                	li	a4,15
    800063da:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800063dc:	6705                	lui	a4,0x1
    800063de:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800063e0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800063e4:	5bdc                	lw	a5,52(a5)
    800063e6:	2781                	sext.w	a5,a5
  if(max == 0)
    800063e8:	c7d9                	beqz	a5,80006476 <virtio_disk_init+0x124>
  if(max < NUM)
    800063ea:	471d                	li	a4,7
    800063ec:	08f77d63          	bleu	a5,a4,80006486 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800063f0:	100014b7          	lui	s1,0x10001
    800063f4:	47a1                	li	a5,8
    800063f6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800063f8:	6609                	lui	a2,0x2
    800063fa:	4581                	li	a1,0
    800063fc:	00029517          	auipc	a0,0x29
    80006400:	c0450513          	addi	a0,a0,-1020 # 8002f000 <disk>
    80006404:	ffffb097          	auipc	ra,0xffffb
    80006408:	91c080e7          	jalr	-1764(ra) # 80000d20 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000640c:	00029717          	auipc	a4,0x29
    80006410:	bf470713          	addi	a4,a4,-1036 # 8002f000 <disk>
    80006414:	00c75793          	srli	a5,a4,0xc
    80006418:	2781                	sext.w	a5,a5
    8000641a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000641c:	0002b797          	auipc	a5,0x2b
    80006420:	be478793          	addi	a5,a5,-1052 # 80031000 <disk+0x2000>
    80006424:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006426:	00029717          	auipc	a4,0x29
    8000642a:	c5a70713          	addi	a4,a4,-934 # 8002f080 <disk+0x80>
    8000642e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006430:	0002a717          	auipc	a4,0x2a
    80006434:	bd070713          	addi	a4,a4,-1072 # 80030000 <disk+0x1000>
    80006438:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000643a:	4705                	li	a4,1
    8000643c:	00e78c23          	sb	a4,24(a5)
    80006440:	00e78ca3          	sb	a4,25(a5)
    80006444:	00e78d23          	sb	a4,26(a5)
    80006448:	00e78da3          	sb	a4,27(a5)
    8000644c:	00e78e23          	sb	a4,28(a5)
    80006450:	00e78ea3          	sb	a4,29(a5)
    80006454:	00e78f23          	sb	a4,30(a5)
    80006458:	00e78fa3          	sb	a4,31(a5)
}
    8000645c:	60e2                	ld	ra,24(sp)
    8000645e:	6442                	ld	s0,16(sp)
    80006460:	64a2                	ld	s1,8(sp)
    80006462:	6105                	addi	sp,sp,32
    80006464:	8082                	ret
    panic("could not find virtio disk");
    80006466:	00002517          	auipc	a0,0x2
    8000646a:	33250513          	addi	a0,a0,818 # 80008798 <syscalls+0x3d8>
    8000646e:	ffffa097          	auipc	ra,0xffffa
    80006472:	0ea080e7          	jalr	234(ra) # 80000558 <panic>
    panic("virtio disk has no queue 0");
    80006476:	00002517          	auipc	a0,0x2
    8000647a:	34250513          	addi	a0,a0,834 # 800087b8 <syscalls+0x3f8>
    8000647e:	ffffa097          	auipc	ra,0xffffa
    80006482:	0da080e7          	jalr	218(ra) # 80000558 <panic>
    panic("virtio disk max queue too short");
    80006486:	00002517          	auipc	a0,0x2
    8000648a:	35250513          	addi	a0,a0,850 # 800087d8 <syscalls+0x418>
    8000648e:	ffffa097          	auipc	ra,0xffffa
    80006492:	0ca080e7          	jalr	202(ra) # 80000558 <panic>

0000000080006496 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006496:	711d                	addi	sp,sp,-96
    80006498:	ec86                	sd	ra,88(sp)
    8000649a:	e8a2                	sd	s0,80(sp)
    8000649c:	e4a6                	sd	s1,72(sp)
    8000649e:	e0ca                	sd	s2,64(sp)
    800064a0:	fc4e                	sd	s3,56(sp)
    800064a2:	f852                	sd	s4,48(sp)
    800064a4:	f456                	sd	s5,40(sp)
    800064a6:	f05a                	sd	s6,32(sp)
    800064a8:	ec5e                	sd	s7,24(sp)
    800064aa:	e862                	sd	s8,16(sp)
    800064ac:	1080                	addi	s0,sp,96
    800064ae:	892a                	mv	s2,a0
    800064b0:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800064b2:	00c52b83          	lw	s7,12(a0)
    800064b6:	001b9b9b          	slliw	s7,s7,0x1
    800064ba:	1b82                	slli	s7,s7,0x20
    800064bc:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800064c0:	0002b517          	auipc	a0,0x2b
    800064c4:	c6850513          	addi	a0,a0,-920 # 80031128 <disk+0x2128>
    800064c8:	ffffa097          	auipc	ra,0xffffa
    800064cc:	75c080e7          	jalr	1884(ra) # 80000c24 <acquire>
    if(disk.free[i]){
    800064d0:	0002b997          	auipc	s3,0x2b
    800064d4:	b3098993          	addi	s3,s3,-1232 # 80031000 <disk+0x2000>
  for(int i = 0; i < NUM; i++){
    800064d8:	4b21                	li	s6,8
      disk.free[i] = 0;
    800064da:	00029a97          	auipc	s5,0x29
    800064de:	b26a8a93          	addi	s5,s5,-1242 # 8002f000 <disk>
  for(int i = 0; i < 3; i++){
    800064e2:	4a0d                	li	s4,3
    800064e4:	a079                	j	80006572 <virtio_disk_rw+0xdc>
      disk.free[i] = 0;
    800064e6:	00fa86b3          	add	a3,s5,a5
    800064ea:	96ae                	add	a3,a3,a1
    800064ec:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800064f0:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800064f2:	0207ca63          	bltz	a5,80006526 <virtio_disk_rw+0x90>
  for(int i = 0; i < 3; i++){
    800064f6:	2485                	addiw	s1,s1,1
    800064f8:	0711                	addi	a4,a4,4
    800064fa:	25448b63          	beq	s1,s4,80006750 <virtio_disk_rw+0x2ba>
    idx[i] = alloc_desc();
    800064fe:	863a                	mv	a2,a4
    if(disk.free[i]){
    80006500:	0189c783          	lbu	a5,24(s3)
    80006504:	26079e63          	bnez	a5,80006780 <virtio_disk_rw+0x2ea>
    80006508:	0002b697          	auipc	a3,0x2b
    8000650c:	b1168693          	addi	a3,a3,-1263 # 80031019 <disk+0x2019>
  for(int i = 0; i < NUM; i++){
    80006510:	87aa                	mv	a5,a0
    if(disk.free[i]){
    80006512:	0006c803          	lbu	a6,0(a3)
    80006516:	fc0818e3          	bnez	a6,800064e6 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    8000651a:	2785                	addiw	a5,a5,1
    8000651c:	0685                	addi	a3,a3,1
    8000651e:	ff679ae3          	bne	a5,s6,80006512 <virtio_disk_rw+0x7c>
    idx[i] = alloc_desc();
    80006522:	57fd                	li	a5,-1
    80006524:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006526:	02905a63          	blez	s1,8000655a <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    8000652a:	fa042503          	lw	a0,-96(s0)
    8000652e:	00000097          	auipc	ra,0x0
    80006532:	d88080e7          	jalr	-632(ra) # 800062b6 <free_desc>
      for(int j = 0; j < i; j++)
    80006536:	4785                	li	a5,1
    80006538:	0297d163          	ble	s1,a5,8000655a <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    8000653c:	fa442503          	lw	a0,-92(s0)
    80006540:	00000097          	auipc	ra,0x0
    80006544:	d76080e7          	jalr	-650(ra) # 800062b6 <free_desc>
      for(int j = 0; j < i; j++)
    80006548:	4789                	li	a5,2
    8000654a:	0097d863          	ble	s1,a5,8000655a <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    8000654e:	fa842503          	lw	a0,-88(s0)
    80006552:	00000097          	auipc	ra,0x0
    80006556:	d64080e7          	jalr	-668(ra) # 800062b6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000655a:	0002b597          	auipc	a1,0x2b
    8000655e:	bce58593          	addi	a1,a1,-1074 # 80031128 <disk+0x2128>
    80006562:	0002b517          	auipc	a0,0x2b
    80006566:	ab650513          	addi	a0,a0,-1354 # 80031018 <disk+0x2018>
    8000656a:	ffffc097          	auipc	ra,0xffffc
    8000656e:	db8080e7          	jalr	-584(ra) # 80002322 <sleep>
  for(int i = 0; i < 3; i++){
    80006572:	fa040713          	addi	a4,s0,-96
    80006576:	4481                	li	s1,0
  for(int i = 0; i < NUM; i++){
    80006578:	4505                	li	a0,1
      disk.free[i] = 0;
    8000657a:	6589                	lui	a1,0x2
    8000657c:	b749                	j	800064fe <virtio_disk_rw+0x68>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    8000657e:	20058793          	addi	a5,a1,512 # 2200 <_entry-0x7fffde00>
    80006582:	00479613          	slli	a2,a5,0x4
    80006586:	00029797          	auipc	a5,0x29
    8000658a:	a7a78793          	addi	a5,a5,-1414 # 8002f000 <disk>
    8000658e:	97b2                	add	a5,a5,a2
    80006590:	4605                	li	a2,1
    80006592:	0ac7a423          	sw	a2,168(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006596:	20058793          	addi	a5,a1,512
    8000659a:	00479613          	slli	a2,a5,0x4
    8000659e:	00029797          	auipc	a5,0x29
    800065a2:	a6278793          	addi	a5,a5,-1438 # 8002f000 <disk>
    800065a6:	97b2                	add	a5,a5,a2
    800065a8:	0a07a623          	sw	zero,172(a5)
  buf0->sector = sector;
    800065ac:	0b77b823          	sd	s7,176(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800065b0:	0002b797          	auipc	a5,0x2b
    800065b4:	a5078793          	addi	a5,a5,-1456 # 80031000 <disk+0x2000>
    800065b8:	6390                	ld	a2,0(a5)
    800065ba:	963a                	add	a2,a2,a4
    800065bc:	7779                	lui	a4,0xffffe
    800065be:	9732                	add	a4,a4,a2
    800065c0:	e314                	sd	a3,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800065c2:	00459713          	slli	a4,a1,0x4
    800065c6:	6394                	ld	a3,0(a5)
    800065c8:	96ba                	add	a3,a3,a4
    800065ca:	4641                	li	a2,16
    800065cc:	c690                	sw	a2,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800065ce:	6394                	ld	a3,0(a5)
    800065d0:	96ba                	add	a3,a3,a4
    800065d2:	4605                	li	a2,1
    800065d4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800065d8:	fa442683          	lw	a3,-92(s0)
    800065dc:	6390                	ld	a2,0(a5)
    800065de:	963a                	add	a2,a2,a4
    800065e0:	00d61723          	sh	a3,14(a2) # 200e <_entry-0x7fffdff2>

  disk.desc[idx[1]].addr = (uint64) b->data;
    800065e4:	0692                	slli	a3,a3,0x4
    800065e6:	6390                	ld	a2,0(a5)
    800065e8:	9636                	add	a2,a2,a3
    800065ea:	05890513          	addi	a0,s2,88
    800065ee:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800065f0:	639c                	ld	a5,0(a5)
    800065f2:	97b6                	add	a5,a5,a3
    800065f4:	40000613          	li	a2,1024
    800065f8:	c790                	sw	a2,8(a5)
  if(write)
    800065fa:	140c0163          	beqz	s8,8000673c <virtio_disk_rw+0x2a6>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800065fe:	0002b797          	auipc	a5,0x2b
    80006602:	a0278793          	addi	a5,a5,-1534 # 80031000 <disk+0x2000>
    80006606:	639c                	ld	a5,0(a5)
    80006608:	97b6                	add	a5,a5,a3
    8000660a:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000660e:	00029897          	auipc	a7,0x29
    80006612:	9f288893          	addi	a7,a7,-1550 # 8002f000 <disk>
    80006616:	0002b797          	auipc	a5,0x2b
    8000661a:	9ea78793          	addi	a5,a5,-1558 # 80031000 <disk+0x2000>
    8000661e:	6390                	ld	a2,0(a5)
    80006620:	9636                	add	a2,a2,a3
    80006622:	00c65503          	lhu	a0,12(a2)
    80006626:	00156513          	ori	a0,a0,1
    8000662a:	00a61623          	sh	a0,12(a2)
  disk.desc[idx[1]].next = idx[2];
    8000662e:	fa842603          	lw	a2,-88(s0)
    80006632:	6388                	ld	a0,0(a5)
    80006634:	96aa                	add	a3,a3,a0
    80006636:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000663a:	20058513          	addi	a0,a1,512
    8000663e:	0512                	slli	a0,a0,0x4
    80006640:	9546                	add	a0,a0,a7
    80006642:	56fd                	li	a3,-1
    80006644:	02d50823          	sb	a3,48(a0)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006648:	00461693          	slli	a3,a2,0x4
    8000664c:	6390                	ld	a2,0(a5)
    8000664e:	9636                	add	a2,a2,a3
    80006650:	6809                	lui	a6,0x2
    80006652:	03080813          	addi	a6,a6,48 # 2030 <_entry-0x7fffdfd0>
    80006656:	9742                	add	a4,a4,a6
    80006658:	9746                	add	a4,a4,a7
    8000665a:	e218                	sd	a4,0(a2)
  disk.desc[idx[2]].len = 1;
    8000665c:	6398                	ld	a4,0(a5)
    8000665e:	9736                	add	a4,a4,a3
    80006660:	4605                	li	a2,1
    80006662:	c710                	sw	a2,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006664:	6398                	ld	a4,0(a5)
    80006666:	9736                	add	a4,a4,a3
    80006668:	4809                	li	a6,2
    8000666a:	01071623          	sh	a6,12(a4) # ffffffffffffe00c <end+0xffffffff7ffcc00c>
  disk.desc[idx[2]].next = 0;
    8000666e:	6398                	ld	a4,0(a5)
    80006670:	96ba                	add	a3,a3,a4
    80006672:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006676:	00c92223          	sw	a2,4(s2)
  disk.info[idx[0]].b = b;
    8000667a:	03253423          	sd	s2,40(a0)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000667e:	6794                	ld	a3,8(a5)
    80006680:	0026d703          	lhu	a4,2(a3)
    80006684:	8b1d                	andi	a4,a4,7
    80006686:	0706                	slli	a4,a4,0x1
    80006688:	9736                	add	a4,a4,a3
    8000668a:	00b71223          	sh	a1,4(a4)

  __sync_synchronize();
    8000668e:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006692:	6798                	ld	a4,8(a5)
    80006694:	00275783          	lhu	a5,2(a4)
    80006698:	2785                	addiw	a5,a5,1
    8000669a:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000669e:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800066a2:	100017b7          	lui	a5,0x10001
    800066a6:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800066aa:	00492703          	lw	a4,4(s2)
    800066ae:	4785                	li	a5,1
    800066b0:	02f71163          	bne	a4,a5,800066d2 <virtio_disk_rw+0x23c>
    sleep(b, &disk.vdisk_lock);
    800066b4:	0002b997          	auipc	s3,0x2b
    800066b8:	a7498993          	addi	s3,s3,-1420 # 80031128 <disk+0x2128>
  while(b->disk == 1) {
    800066bc:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800066be:	85ce                	mv	a1,s3
    800066c0:	854a                	mv	a0,s2
    800066c2:	ffffc097          	auipc	ra,0xffffc
    800066c6:	c60080e7          	jalr	-928(ra) # 80002322 <sleep>
  while(b->disk == 1) {
    800066ca:	00492783          	lw	a5,4(s2)
    800066ce:	fe9788e3          	beq	a5,s1,800066be <virtio_disk_rw+0x228>
  }

  disk.info[idx[0]].b = 0;
    800066d2:	fa042503          	lw	a0,-96(s0)
    800066d6:	20050793          	addi	a5,a0,512
    800066da:	00479713          	slli	a4,a5,0x4
    800066de:	00029797          	auipc	a5,0x29
    800066e2:	92278793          	addi	a5,a5,-1758 # 8002f000 <disk>
    800066e6:	97ba                	add	a5,a5,a4
    800066e8:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800066ec:	0002b997          	auipc	s3,0x2b
    800066f0:	91498993          	addi	s3,s3,-1772 # 80031000 <disk+0x2000>
    800066f4:	00451713          	slli	a4,a0,0x4
    800066f8:	0009b783          	ld	a5,0(s3)
    800066fc:	97ba                	add	a5,a5,a4
    800066fe:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006702:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006706:	00000097          	auipc	ra,0x0
    8000670a:	bb0080e7          	jalr	-1104(ra) # 800062b6 <free_desc>
      i = nxt;
    8000670e:	854a                	mv	a0,s2
    if(flag & VRING_DESC_F_NEXT)
    80006710:	8885                	andi	s1,s1,1
    80006712:	f0ed                	bnez	s1,800066f4 <virtio_disk_rw+0x25e>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006714:	0002b517          	auipc	a0,0x2b
    80006718:	a1450513          	addi	a0,a0,-1516 # 80031128 <disk+0x2128>
    8000671c:	ffffa097          	auipc	ra,0xffffa
    80006720:	5bc080e7          	jalr	1468(ra) # 80000cd8 <release>
}
    80006724:	60e6                	ld	ra,88(sp)
    80006726:	6446                	ld	s0,80(sp)
    80006728:	64a6                	ld	s1,72(sp)
    8000672a:	6906                	ld	s2,64(sp)
    8000672c:	79e2                	ld	s3,56(sp)
    8000672e:	7a42                	ld	s4,48(sp)
    80006730:	7aa2                	ld	s5,40(sp)
    80006732:	7b02                	ld	s6,32(sp)
    80006734:	6be2                	ld	s7,24(sp)
    80006736:	6c42                	ld	s8,16(sp)
    80006738:	6125                	addi	sp,sp,96
    8000673a:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000673c:	0002b797          	auipc	a5,0x2b
    80006740:	8c478793          	addi	a5,a5,-1852 # 80031000 <disk+0x2000>
    80006744:	639c                	ld	a5,0(a5)
    80006746:	97b6                	add	a5,a5,a3
    80006748:	4609                	li	a2,2
    8000674a:	00c79623          	sh	a2,12(a5)
    8000674e:	b5c1                	j	8000660e <virtio_disk_rw+0x178>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006750:	fa042583          	lw	a1,-96(s0)
    80006754:	20058713          	addi	a4,a1,512
    80006758:	0712                	slli	a4,a4,0x4
    8000675a:	00029697          	auipc	a3,0x29
    8000675e:	94e68693          	addi	a3,a3,-1714 # 8002f0a8 <disk+0xa8>
    80006762:	96ba                	add	a3,a3,a4
  if(write)
    80006764:	e00c1de3          	bnez	s8,8000657e <virtio_disk_rw+0xe8>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006768:	20058793          	addi	a5,a1,512
    8000676c:	00479613          	slli	a2,a5,0x4
    80006770:	00029797          	auipc	a5,0x29
    80006774:	89078793          	addi	a5,a5,-1904 # 8002f000 <disk>
    80006778:	97b2                	add	a5,a5,a2
    8000677a:	0a07a423          	sw	zero,168(a5)
    8000677e:	bd21                	j	80006596 <virtio_disk_rw+0x100>
      disk.free[i] = 0;
    80006780:	00098c23          	sb	zero,24(s3)
    idx[i] = alloc_desc();
    80006784:	00072023          	sw	zero,0(a4)
    if(idx[i] < 0){
    80006788:	b3bd                	j	800064f6 <virtio_disk_rw+0x60>

000000008000678a <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000678a:	1101                	addi	sp,sp,-32
    8000678c:	ec06                	sd	ra,24(sp)
    8000678e:	e822                	sd	s0,16(sp)
    80006790:	e426                	sd	s1,8(sp)
    80006792:	e04a                	sd	s2,0(sp)
    80006794:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006796:	0002b517          	auipc	a0,0x2b
    8000679a:	99250513          	addi	a0,a0,-1646 # 80031128 <disk+0x2128>
    8000679e:	ffffa097          	auipc	ra,0xffffa
    800067a2:	486080e7          	jalr	1158(ra) # 80000c24 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800067a6:	10001737          	lui	a4,0x10001
    800067aa:	533c                	lw	a5,96(a4)
    800067ac:	8b8d                	andi	a5,a5,3
    800067ae:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800067b0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800067b4:	0002b797          	auipc	a5,0x2b
    800067b8:	84c78793          	addi	a5,a5,-1972 # 80031000 <disk+0x2000>
    800067bc:	6b94                	ld	a3,16(a5)
    800067be:	0207d703          	lhu	a4,32(a5)
    800067c2:	0026d783          	lhu	a5,2(a3)
    800067c6:	06f70163          	beq	a4,a5,80006828 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800067ca:	00029917          	auipc	s2,0x29
    800067ce:	83690913          	addi	s2,s2,-1994 # 8002f000 <disk>
    800067d2:	0002b497          	auipc	s1,0x2b
    800067d6:	82e48493          	addi	s1,s1,-2002 # 80031000 <disk+0x2000>
    __sync_synchronize();
    800067da:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800067de:	6898                	ld	a4,16(s1)
    800067e0:	0204d783          	lhu	a5,32(s1)
    800067e4:	8b9d                	andi	a5,a5,7
    800067e6:	078e                	slli	a5,a5,0x3
    800067e8:	97ba                	add	a5,a5,a4
    800067ea:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800067ec:	20078713          	addi	a4,a5,512
    800067f0:	0712                	slli	a4,a4,0x4
    800067f2:	974a                	add	a4,a4,s2
    800067f4:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800067f8:	e731                	bnez	a4,80006844 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800067fa:	20078793          	addi	a5,a5,512
    800067fe:	0792                	slli	a5,a5,0x4
    80006800:	97ca                	add	a5,a5,s2
    80006802:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006804:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006808:	ffffc097          	auipc	ra,0xffffc
    8000680c:	ca0080e7          	jalr	-864(ra) # 800024a8 <wakeup>

    disk.used_idx += 1;
    80006810:	0204d783          	lhu	a5,32(s1)
    80006814:	2785                	addiw	a5,a5,1
    80006816:	17c2                	slli	a5,a5,0x30
    80006818:	93c1                	srli	a5,a5,0x30
    8000681a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000681e:	6898                	ld	a4,16(s1)
    80006820:	00275703          	lhu	a4,2(a4)
    80006824:	faf71be3          	bne	a4,a5,800067da <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80006828:	0002b517          	auipc	a0,0x2b
    8000682c:	90050513          	addi	a0,a0,-1792 # 80031128 <disk+0x2128>
    80006830:	ffffa097          	auipc	ra,0xffffa
    80006834:	4a8080e7          	jalr	1192(ra) # 80000cd8 <release>
}
    80006838:	60e2                	ld	ra,24(sp)
    8000683a:	6442                	ld	s0,16(sp)
    8000683c:	64a2                	ld	s1,8(sp)
    8000683e:	6902                	ld	s2,0(sp)
    80006840:	6105                	addi	sp,sp,32
    80006842:	8082                	ret
      panic("virtio_disk_intr status");
    80006844:	00002517          	auipc	a0,0x2
    80006848:	fb450513          	addi	a0,a0,-76 # 800087f8 <syscalls+0x438>
    8000684c:	ffffa097          	auipc	ra,0xffffa
    80006850:	d0c080e7          	jalr	-756(ra) # 80000558 <panic>
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
