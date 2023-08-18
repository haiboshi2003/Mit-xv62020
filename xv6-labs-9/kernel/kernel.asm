
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
    80000066:	f5e78793          	addi	a5,a5,-162 # 80005fc0 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd7ff>
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
    80000120:	3fe080e7          	jalr	1022(ra) # 8000251a <either_copyin>
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
    800001b8:	894080e7          	jalr	-1900(ra) # 80001a48 <myproc>
    800001bc:	591c                	lw	a5,48(a0)
    800001be:	eba5                	bnez	a5,8000022e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c0:	85ce                	mv	a1,s3
    800001c2:	854a                	mv	a0,s2
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	09e080e7          	jalr	158(ra) # 80002262 <sleep>
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
    80000204:	2c4080e7          	jalr	708(ra) # 800024c4 <either_copyout>
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
    800003fe:	176080e7          	jalr	374(ra) # 80002570 <procdump>
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
    80000460:	f8c080e7          	jalr	-116(ra) # 800023e8 <wakeup>
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
    8000048e:	0001c797          	auipc	a5,0x1c
    80000492:	28278793          	addi	a5,a5,642 # 8001c710 <devsw>
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
    800008ca:	b22080e7          	jalr	-1246(ra) # 800023e8 <wakeup>
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
    8000096c:	8fa080e7          	jalr	-1798(ra) # 80002262 <sleep>
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
    80000a4a:	00020797          	auipc	a5,0x20
    80000a4e:	5b678793          	addi	a5,a5,1462 # 80021000 <end>
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
    80000b1c:	00020517          	auipc	a0,0x20
    80000b20:	4e450513          	addi	a0,a0,1252 # 80021000 <end>
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
    80000bc2:	e6e080e7          	jalr	-402(ra) # 80001a2c <mycpu>
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
    80000bf4:	e3c080e7          	jalr	-452(ra) # 80001a2c <mycpu>
    80000bf8:	5d3c                	lw	a5,120(a0)
    80000bfa:	cf89                	beqz	a5,80000c14 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bfc:	00001097          	auipc	ra,0x1
    80000c00:	e30080e7          	jalr	-464(ra) # 80001a2c <mycpu>
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
    80000c18:	e18080e7          	jalr	-488(ra) # 80001a2c <mycpu>
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
    80000c58:	dd8080e7          	jalr	-552(ra) # 80001a2c <mycpu>
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
    80000c84:	dac080e7          	jalr	-596(ra) # 80001a2c <mycpu>
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
    80000d36:	00b78023          	sb	a1,0(a5) # fffffffffffff000 <end+0xffffffff7ffde000>
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
    80000f00:	b20080e7          	jalr	-1248(ra) # 80001a1c <cpuid>
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
    80000f1c:	b04080e7          	jalr	-1276(ra) # 80001a1c <cpuid>
    80000f20:	85aa                	mv	a1,a0
    80000f22:	00007517          	auipc	a0,0x7
    80000f26:	19650513          	addi	a0,a0,406 # 800080b8 <digits+0xa0>
    80000f2a:	fffff097          	auipc	ra,0xfffff
    80000f2e:	678080e7          	jalr	1656(ra) # 800005a2 <printf>
    kvminithart();    // turn on paging
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	0d8080e7          	jalr	216(ra) # 8000100a <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f3a:	00001097          	auipc	ra,0x1
    80000f3e:	778080e7          	jalr	1912(ra) # 800026b2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	0be080e7          	jalr	190(ra) # 80006000 <plicinithart>
  }

  scheduler();        
    80000f4a:	00001097          	auipc	ra,0x1
    80000f4e:	034080e7          	jalr	52(ra) # 80001f7e <scheduler>
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
    80000fae:	9da080e7          	jalr	-1574(ra) # 80001984 <procinit>
    trapinit();      // trap vectors
    80000fb2:	00001097          	auipc	ra,0x1
    80000fb6:	6d8080e7          	jalr	1752(ra) # 8000268a <trapinit>
    trapinithart();  // install kernel trap vector
    80000fba:	00001097          	auipc	ra,0x1
    80000fbe:	6f8080e7          	jalr	1784(ra) # 800026b2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fc2:	00005097          	auipc	ra,0x5
    80000fc6:	028080e7          	jalr	40(ra) # 80005fea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fca:	00005097          	auipc	ra,0x5
    80000fce:	036080e7          	jalr	54(ra) # 80006000 <plicinithart>
    binit();         // buffer cache
    80000fd2:	00002097          	auipc	ra,0x2
    80000fd6:	e30080e7          	jalr	-464(ra) # 80002e02 <binit>
    iinit();         // inode cache
    80000fda:	00002097          	auipc	ra,0x2
    80000fde:	5c8080e7          	jalr	1480(ra) # 800035a2 <iinit>
    fileinit();      // file table
    80000fe2:	00003097          	auipc	ra,0x3
    80000fe6:	64e080e7          	jalr	1614(ra) # 80004630 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fea:	00005097          	auipc	ra,0x5
    80000fee:	138080e7          	jalr	312(ra) # 80006122 <virtio_disk_init>
    userinit();      // first user process
    80000ff2:	00001097          	auipc	ra,0x1
    80000ff6:	d22080e7          	jalr	-734(ra) # 80001d14 <userinit>
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
    80001298:	65a080e7          	jalr	1626(ra) # 800018ee <proc_mapstacks>
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
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012f4:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f6:	6b05                	lui	s6,0x1
    800012f8:	0735e863          	bltu	a1,s3,80001368 <uvmunmap+0x9e>
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
      panic("uvmunmap: not mapped");
    80001332:	00007517          	auipc	a0,0x7
    80001336:	dde50513          	addi	a0,a0,-546 # 80008110 <digits+0xf8>
    8000133a:	fffff097          	auipc	ra,0xfffff
    8000133e:	21e080e7          	jalr	542(ra) # 80000558 <panic>
      panic("uvmunmap: not a leaf");
    80001342:	00007517          	auipc	a0,0x7
    80001346:	de650513          	addi	a0,a0,-538 # 80008128 <digits+0x110>
    8000134a:	fffff097          	auipc	ra,0xfffff
    8000134e:	20e080e7          	jalr	526(ra) # 80000558 <panic>
      uint64 pa = PTE2PA(*pte);
    80001352:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001354:	0532                	slli	a0,a0,0xc
    80001356:	fffff097          	auipc	ra,0xfffff
    8000135a:	6de080e7          	jalr	1758(ra) # 80000a34 <kfree>
    *pte = 0;
    8000135e:	00093023          	sd	zero,0(s2)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001362:	94da                	add	s1,s1,s6
    80001364:	f934fce3          	bleu	s3,s1,800012fc <uvmunmap+0x32>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001368:	4601                	li	a2,0
    8000136a:	85a6                	mv	a1,s1
    8000136c:	8552                	mv	a0,s4
    8000136e:	00000097          	auipc	ra,0x0
    80001372:	cc2080e7          	jalr	-830(ra) # 80001030 <walk>
    80001376:	892a                	mv	s2,a0
    80001378:	d54d                	beqz	a0,80001322 <uvmunmap+0x58>
    if((*pte & PTE_V) == 0)
    8000137a:	6108                	ld	a0,0(a0)
    8000137c:	00157793          	andi	a5,a0,1
    80001380:	dbcd                	beqz	a5,80001332 <uvmunmap+0x68>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001382:	3ff57793          	andi	a5,a0,1023
    80001386:	fb778ee3          	beq	a5,s7,80001342 <uvmunmap+0x78>
    if(do_free){
    8000138a:	fc0a8ae3          	beqz	s5,8000135e <uvmunmap+0x94>
    8000138e:	b7d1                	j	80001352 <uvmunmap+0x88>

0000000080001390 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001390:	1101                	addi	sp,sp,-32
    80001392:	ec06                	sd	ra,24(sp)
    80001394:	e822                	sd	s0,16(sp)
    80001396:	e426                	sd	s1,8(sp)
    80001398:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000139a:	fffff097          	auipc	ra,0xfffff
    8000139e:	79a080e7          	jalr	1946(ra) # 80000b34 <kalloc>
    800013a2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013a4:	c519                	beqz	a0,800013b2 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013a6:	6605                	lui	a2,0x1
    800013a8:	4581                	li	a1,0
    800013aa:	00000097          	auipc	ra,0x0
    800013ae:	976080e7          	jalr	-1674(ra) # 80000d20 <memset>
  return pagetable;
}
    800013b2:	8526                	mv	a0,s1
    800013b4:	60e2                	ld	ra,24(sp)
    800013b6:	6442                	ld	s0,16(sp)
    800013b8:	64a2                	ld	s1,8(sp)
    800013ba:	6105                	addi	sp,sp,32
    800013bc:	8082                	ret

00000000800013be <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800013be:	7179                	addi	sp,sp,-48
    800013c0:	f406                	sd	ra,40(sp)
    800013c2:	f022                	sd	s0,32(sp)
    800013c4:	ec26                	sd	s1,24(sp)
    800013c6:	e84a                	sd	s2,16(sp)
    800013c8:	e44e                	sd	s3,8(sp)
    800013ca:	e052                	sd	s4,0(sp)
    800013cc:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013ce:	6785                	lui	a5,0x1
    800013d0:	04f67863          	bleu	a5,a2,80001420 <uvminit+0x62>
    800013d4:	8a2a                	mv	s4,a0
    800013d6:	89ae                	mv	s3,a1
    800013d8:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013da:	fffff097          	auipc	ra,0xfffff
    800013de:	75a080e7          	jalr	1882(ra) # 80000b34 <kalloc>
    800013e2:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013e4:	6605                	lui	a2,0x1
    800013e6:	4581                	li	a1,0
    800013e8:	00000097          	auipc	ra,0x0
    800013ec:	938080e7          	jalr	-1736(ra) # 80000d20 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013f0:	4779                	li	a4,30
    800013f2:	86ca                	mv	a3,s2
    800013f4:	6605                	lui	a2,0x1
    800013f6:	4581                	li	a1,0
    800013f8:	8552                	mv	a0,s4
    800013fa:	00000097          	auipc	ra,0x0
    800013fe:	d1e080e7          	jalr	-738(ra) # 80001118 <mappages>
  memmove(mem, src, sz);
    80001402:	8626                	mv	a2,s1
    80001404:	85ce                	mv	a1,s3
    80001406:	854a                	mv	a0,s2
    80001408:	00000097          	auipc	ra,0x0
    8000140c:	984080e7          	jalr	-1660(ra) # 80000d8c <memmove>
}
    80001410:	70a2                	ld	ra,40(sp)
    80001412:	7402                	ld	s0,32(sp)
    80001414:	64e2                	ld	s1,24(sp)
    80001416:	6942                	ld	s2,16(sp)
    80001418:	69a2                	ld	s3,8(sp)
    8000141a:	6a02                	ld	s4,0(sp)
    8000141c:	6145                	addi	sp,sp,48
    8000141e:	8082                	ret
    panic("inituvm: more than a page");
    80001420:	00007517          	auipc	a0,0x7
    80001424:	d2050513          	addi	a0,a0,-736 # 80008140 <digits+0x128>
    80001428:	fffff097          	auipc	ra,0xfffff
    8000142c:	130080e7          	jalr	304(ra) # 80000558 <panic>

0000000080001430 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001430:	1101                	addi	sp,sp,-32
    80001432:	ec06                	sd	ra,24(sp)
    80001434:	e822                	sd	s0,16(sp)
    80001436:	e426                	sd	s1,8(sp)
    80001438:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000143a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000143c:	00b67d63          	bleu	a1,a2,80001456 <uvmdealloc+0x26>
    80001440:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001442:	6605                	lui	a2,0x1
    80001444:	167d                	addi	a2,a2,-1
    80001446:	00c487b3          	add	a5,s1,a2
    8000144a:	777d                	lui	a4,0xfffff
    8000144c:	8ff9                	and	a5,a5,a4
    8000144e:	962e                	add	a2,a2,a1
    80001450:	8e79                	and	a2,a2,a4
    80001452:	00c7e863          	bltu	a5,a2,80001462 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001456:	8526                	mv	a0,s1
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001462:	8e1d                	sub	a2,a2,a5
    80001464:	8231                	srli	a2,a2,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001466:	4685                	li	a3,1
    80001468:	2601                	sext.w	a2,a2
    8000146a:	85be                	mv	a1,a5
    8000146c:	00000097          	auipc	ra,0x0
    80001470:	e5e080e7          	jalr	-418(ra) # 800012ca <uvmunmap>
    80001474:	b7cd                	j	80001456 <uvmdealloc+0x26>

0000000080001476 <uvmalloc>:
  if(newsz < oldsz)
    80001476:	0ab66163          	bltu	a2,a1,80001518 <uvmalloc+0xa2>
{
    8000147a:	7139                	addi	sp,sp,-64
    8000147c:	fc06                	sd	ra,56(sp)
    8000147e:	f822                	sd	s0,48(sp)
    80001480:	f426                	sd	s1,40(sp)
    80001482:	f04a                	sd	s2,32(sp)
    80001484:	ec4e                	sd	s3,24(sp)
    80001486:	e852                	sd	s4,16(sp)
    80001488:	e456                	sd	s5,8(sp)
    8000148a:	0080                	addi	s0,sp,64
  oldsz = PGROUNDUP(oldsz);
    8000148c:	6a05                	lui	s4,0x1
    8000148e:	1a7d                	addi	s4,s4,-1
    80001490:	95d2                	add	a1,a1,s4
    80001492:	7a7d                	lui	s4,0xfffff
    80001494:	0145fa33          	and	s4,a1,s4
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001498:	08ca7263          	bleu	a2,s4,8000151c <uvmalloc+0xa6>
    8000149c:	89b2                	mv	s3,a2
    8000149e:	8aaa                	mv	s5,a0
    800014a0:	8952                	mv	s2,s4
    mem = kalloc();
    800014a2:	fffff097          	auipc	ra,0xfffff
    800014a6:	692080e7          	jalr	1682(ra) # 80000b34 <kalloc>
    800014aa:	84aa                	mv	s1,a0
    if(mem == 0){
    800014ac:	c51d                	beqz	a0,800014da <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800014ae:	6605                	lui	a2,0x1
    800014b0:	4581                	li	a1,0
    800014b2:	00000097          	auipc	ra,0x0
    800014b6:	86e080e7          	jalr	-1938(ra) # 80000d20 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014ba:	4779                	li	a4,30
    800014bc:	86a6                	mv	a3,s1
    800014be:	6605                	lui	a2,0x1
    800014c0:	85ca                	mv	a1,s2
    800014c2:	8556                	mv	a0,s5
    800014c4:	00000097          	auipc	ra,0x0
    800014c8:	c54080e7          	jalr	-940(ra) # 80001118 <mappages>
    800014cc:	e905                	bnez	a0,800014fc <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014ce:	6785                	lui	a5,0x1
    800014d0:	993e                	add	s2,s2,a5
    800014d2:	fd3968e3          	bltu	s2,s3,800014a2 <uvmalloc+0x2c>
  return newsz;
    800014d6:	854e                	mv	a0,s3
    800014d8:	a809                	j	800014ea <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800014da:	8652                	mv	a2,s4
    800014dc:	85ca                	mv	a1,s2
    800014de:	8556                	mv	a0,s5
    800014e0:	00000097          	auipc	ra,0x0
    800014e4:	f50080e7          	jalr	-176(ra) # 80001430 <uvmdealloc>
      return 0;
    800014e8:	4501                	li	a0,0
}
    800014ea:	70e2                	ld	ra,56(sp)
    800014ec:	7442                	ld	s0,48(sp)
    800014ee:	74a2                	ld	s1,40(sp)
    800014f0:	7902                	ld	s2,32(sp)
    800014f2:	69e2                	ld	s3,24(sp)
    800014f4:	6a42                	ld	s4,16(sp)
    800014f6:	6aa2                	ld	s5,8(sp)
    800014f8:	6121                	addi	sp,sp,64
    800014fa:	8082                	ret
      kfree(mem);
    800014fc:	8526                	mv	a0,s1
    800014fe:	fffff097          	auipc	ra,0xfffff
    80001502:	536080e7          	jalr	1334(ra) # 80000a34 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001506:	8652                	mv	a2,s4
    80001508:	85ca                	mv	a1,s2
    8000150a:	8556                	mv	a0,s5
    8000150c:	00000097          	auipc	ra,0x0
    80001510:	f24080e7          	jalr	-220(ra) # 80001430 <uvmdealloc>
      return 0;
    80001514:	4501                	li	a0,0
    80001516:	bfd1                	j	800014ea <uvmalloc+0x74>
    return oldsz;
    80001518:	852e                	mv	a0,a1
}
    8000151a:	8082                	ret
  return newsz;
    8000151c:	8532                	mv	a0,a2
    8000151e:	b7f1                	j	800014ea <uvmalloc+0x74>

0000000080001520 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001520:	7179                	addi	sp,sp,-48
    80001522:	f406                	sd	ra,40(sp)
    80001524:	f022                	sd	s0,32(sp)
    80001526:	ec26                	sd	s1,24(sp)
    80001528:	e84a                	sd	s2,16(sp)
    8000152a:	e44e                	sd	s3,8(sp)
    8000152c:	e052                	sd	s4,0(sp)
    8000152e:	1800                	addi	s0,sp,48
    80001530:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001532:	84aa                	mv	s1,a0
    80001534:	6905                	lui	s2,0x1
    80001536:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001538:	4985                	li	s3,1
    8000153a:	a821                	j	80001552 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000153c:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000153e:	0532                	slli	a0,a0,0xc
    80001540:	00000097          	auipc	ra,0x0
    80001544:	fe0080e7          	jalr	-32(ra) # 80001520 <freewalk>
      pagetable[i] = 0;
    80001548:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000154c:	04a1                	addi	s1,s1,8
    8000154e:	03248163          	beq	s1,s2,80001570 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001552:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001554:	00f57793          	andi	a5,a0,15
    80001558:	ff3782e3          	beq	a5,s3,8000153c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000155c:	8905                	andi	a0,a0,1
    8000155e:	d57d                	beqz	a0,8000154c <freewalk+0x2c>
      panic("freewalk: leaf");
    80001560:	00007517          	auipc	a0,0x7
    80001564:	c0050513          	addi	a0,a0,-1024 # 80008160 <digits+0x148>
    80001568:	fffff097          	auipc	ra,0xfffff
    8000156c:	ff0080e7          	jalr	-16(ra) # 80000558 <panic>
    }
  }
  kfree((void*)pagetable);
    80001570:	8552                	mv	a0,s4
    80001572:	fffff097          	auipc	ra,0xfffff
    80001576:	4c2080e7          	jalr	1218(ra) # 80000a34 <kfree>
}
    8000157a:	70a2                	ld	ra,40(sp)
    8000157c:	7402                	ld	s0,32(sp)
    8000157e:	64e2                	ld	s1,24(sp)
    80001580:	6942                	ld	s2,16(sp)
    80001582:	69a2                	ld	s3,8(sp)
    80001584:	6a02                	ld	s4,0(sp)
    80001586:	6145                	addi	sp,sp,48
    80001588:	8082                	ret

000000008000158a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000158a:	1101                	addi	sp,sp,-32
    8000158c:	ec06                	sd	ra,24(sp)
    8000158e:	e822                	sd	s0,16(sp)
    80001590:	e426                	sd	s1,8(sp)
    80001592:	1000                	addi	s0,sp,32
    80001594:	84aa                	mv	s1,a0
  if(sz > 0)
    80001596:	e999                	bnez	a1,800015ac <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001598:	8526                	mv	a0,s1
    8000159a:	00000097          	auipc	ra,0x0
    8000159e:	f86080e7          	jalr	-122(ra) # 80001520 <freewalk>
}
    800015a2:	60e2                	ld	ra,24(sp)
    800015a4:	6442                	ld	s0,16(sp)
    800015a6:	64a2                	ld	s1,8(sp)
    800015a8:	6105                	addi	sp,sp,32
    800015aa:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015ac:	6605                	lui	a2,0x1
    800015ae:	167d                	addi	a2,a2,-1
    800015b0:	962e                	add	a2,a2,a1
    800015b2:	4685                	li	a3,1
    800015b4:	8231                	srli	a2,a2,0xc
    800015b6:	4581                	li	a1,0
    800015b8:	00000097          	auipc	ra,0x0
    800015bc:	d12080e7          	jalr	-750(ra) # 800012ca <uvmunmap>
    800015c0:	bfe1                	j	80001598 <uvmfree+0xe>

00000000800015c2 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015c2:	c679                	beqz	a2,80001690 <uvmcopy+0xce>
{
    800015c4:	715d                	addi	sp,sp,-80
    800015c6:	e486                	sd	ra,72(sp)
    800015c8:	e0a2                	sd	s0,64(sp)
    800015ca:	fc26                	sd	s1,56(sp)
    800015cc:	f84a                	sd	s2,48(sp)
    800015ce:	f44e                	sd	s3,40(sp)
    800015d0:	f052                	sd	s4,32(sp)
    800015d2:	ec56                	sd	s5,24(sp)
    800015d4:	e85a                	sd	s6,16(sp)
    800015d6:	e45e                	sd	s7,8(sp)
    800015d8:	0880                	addi	s0,sp,80
    800015da:	8ab2                	mv	s5,a2
    800015dc:	8b2e                	mv	s6,a1
    800015de:	8baa                	mv	s7,a0
  for(i = 0; i < sz; i += PGSIZE){
    800015e0:	4901                	li	s2,0
    if((pte = walk(old, i, 0)) == 0)
    800015e2:	4601                	li	a2,0
    800015e4:	85ca                	mv	a1,s2
    800015e6:	855e                	mv	a0,s7
    800015e8:	00000097          	auipc	ra,0x0
    800015ec:	a48080e7          	jalr	-1464(ra) # 80001030 <walk>
    800015f0:	c531                	beqz	a0,8000163c <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015f2:	6118                	ld	a4,0(a0)
    800015f4:	00177793          	andi	a5,a4,1
    800015f8:	cbb1                	beqz	a5,8000164c <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015fa:	00a75593          	srli	a1,a4,0xa
    800015fe:	00c59993          	slli	s3,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001602:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001606:	fffff097          	auipc	ra,0xfffff
    8000160a:	52e080e7          	jalr	1326(ra) # 80000b34 <kalloc>
    8000160e:	8a2a                	mv	s4,a0
    80001610:	c939                	beqz	a0,80001666 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001612:	6605                	lui	a2,0x1
    80001614:	85ce                	mv	a1,s3
    80001616:	fffff097          	auipc	ra,0xfffff
    8000161a:	776080e7          	jalr	1910(ra) # 80000d8c <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000161e:	8726                	mv	a4,s1
    80001620:	86d2                	mv	a3,s4
    80001622:	6605                	lui	a2,0x1
    80001624:	85ca                	mv	a1,s2
    80001626:	855a                	mv	a0,s6
    80001628:	00000097          	auipc	ra,0x0
    8000162c:	af0080e7          	jalr	-1296(ra) # 80001118 <mappages>
    80001630:	e515                	bnez	a0,8000165c <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001632:	6785                	lui	a5,0x1
    80001634:	993e                	add	s2,s2,a5
    80001636:	fb5966e3          	bltu	s2,s5,800015e2 <uvmcopy+0x20>
    8000163a:	a081                	j	8000167a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    8000163c:	00007517          	auipc	a0,0x7
    80001640:	b3450513          	addi	a0,a0,-1228 # 80008170 <digits+0x158>
    80001644:	fffff097          	auipc	ra,0xfffff
    80001648:	f14080e7          	jalr	-236(ra) # 80000558 <panic>
      panic("uvmcopy: page not present");
    8000164c:	00007517          	auipc	a0,0x7
    80001650:	b4450513          	addi	a0,a0,-1212 # 80008190 <digits+0x178>
    80001654:	fffff097          	auipc	ra,0xfffff
    80001658:	f04080e7          	jalr	-252(ra) # 80000558 <panic>
      kfree(mem);
    8000165c:	8552                	mv	a0,s4
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	3d6080e7          	jalr	982(ra) # 80000a34 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001666:	4685                	li	a3,1
    80001668:	00c95613          	srli	a2,s2,0xc
    8000166c:	4581                	li	a1,0
    8000166e:	855a                	mv	a0,s6
    80001670:	00000097          	auipc	ra,0x0
    80001674:	c5a080e7          	jalr	-934(ra) # 800012ca <uvmunmap>
  return -1;
    80001678:	557d                	li	a0,-1
}
    8000167a:	60a6                	ld	ra,72(sp)
    8000167c:	6406                	ld	s0,64(sp)
    8000167e:	74e2                	ld	s1,56(sp)
    80001680:	7942                	ld	s2,48(sp)
    80001682:	79a2                	ld	s3,40(sp)
    80001684:	7a02                	ld	s4,32(sp)
    80001686:	6ae2                	ld	s5,24(sp)
    80001688:	6b42                	ld	s6,16(sp)
    8000168a:	6ba2                	ld	s7,8(sp)
    8000168c:	6161                	addi	sp,sp,80
    8000168e:	8082                	ret
  return 0;
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret

0000000080001694 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001694:	1141                	addi	sp,sp,-16
    80001696:	e406                	sd	ra,8(sp)
    80001698:	e022                	sd	s0,0(sp)
    8000169a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000169c:	4601                	li	a2,0
    8000169e:	00000097          	auipc	ra,0x0
    800016a2:	992080e7          	jalr	-1646(ra) # 80001030 <walk>
  if(pte == 0)
    800016a6:	c901                	beqz	a0,800016b6 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016a8:	611c                	ld	a5,0(a0)
    800016aa:	9bbd                	andi	a5,a5,-17
    800016ac:	e11c                	sd	a5,0(a0)
}
    800016ae:	60a2                	ld	ra,8(sp)
    800016b0:	6402                	ld	s0,0(sp)
    800016b2:	0141                	addi	sp,sp,16
    800016b4:	8082                	ret
    panic("uvmclear");
    800016b6:	00007517          	auipc	a0,0x7
    800016ba:	afa50513          	addi	a0,a0,-1286 # 800081b0 <digits+0x198>
    800016be:	fffff097          	auipc	ra,0xfffff
    800016c2:	e9a080e7          	jalr	-358(ra) # 80000558 <panic>

00000000800016c6 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016c6:	c6bd                	beqz	a3,80001734 <copyout+0x6e>
{
    800016c8:	715d                	addi	sp,sp,-80
    800016ca:	e486                	sd	ra,72(sp)
    800016cc:	e0a2                	sd	s0,64(sp)
    800016ce:	fc26                	sd	s1,56(sp)
    800016d0:	f84a                	sd	s2,48(sp)
    800016d2:	f44e                	sd	s3,40(sp)
    800016d4:	f052                	sd	s4,32(sp)
    800016d6:	ec56                	sd	s5,24(sp)
    800016d8:	e85a                	sd	s6,16(sp)
    800016da:	e45e                	sd	s7,8(sp)
    800016dc:	e062                	sd	s8,0(sp)
    800016de:	0880                	addi	s0,sp,80
    800016e0:	8baa                	mv	s7,a0
    800016e2:	8a2e                	mv	s4,a1
    800016e4:	8ab2                	mv	s5,a2
    800016e6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016e8:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016ea:	6b05                	lui	s6,0x1
    800016ec:	a015                	j	80001710 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016ee:	9552                	add	a0,a0,s4
    800016f0:	0004861b          	sext.w	a2,s1
    800016f4:	85d6                	mv	a1,s5
    800016f6:	41250533          	sub	a0,a0,s2
    800016fa:	fffff097          	auipc	ra,0xfffff
    800016fe:	692080e7          	jalr	1682(ra) # 80000d8c <memmove>

    len -= n;
    80001702:	409989b3          	sub	s3,s3,s1
    src += n;
    80001706:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    80001708:	01690a33          	add	s4,s2,s6
  while(len > 0){
    8000170c:	02098263          	beqz	s3,80001730 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001710:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    80001714:	85ca                	mv	a1,s2
    80001716:	855e                	mv	a0,s7
    80001718:	00000097          	auipc	ra,0x0
    8000171c:	9be080e7          	jalr	-1602(ra) # 800010d6 <walkaddr>
    if(pa0 == 0)
    80001720:	cd01                	beqz	a0,80001738 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001722:	414904b3          	sub	s1,s2,s4
    80001726:	94da                	add	s1,s1,s6
    if(n > len)
    80001728:	fc99f3e3          	bleu	s1,s3,800016ee <copyout+0x28>
    8000172c:	84ce                	mv	s1,s3
    8000172e:	b7c1                	j	800016ee <copyout+0x28>
  }
  return 0;
    80001730:	4501                	li	a0,0
    80001732:	a021                	j	8000173a <copyout+0x74>
    80001734:	4501                	li	a0,0
}
    80001736:	8082                	ret
      return -1;
    80001738:	557d                	li	a0,-1
}
    8000173a:	60a6                	ld	ra,72(sp)
    8000173c:	6406                	ld	s0,64(sp)
    8000173e:	74e2                	ld	s1,56(sp)
    80001740:	7942                	ld	s2,48(sp)
    80001742:	79a2                	ld	s3,40(sp)
    80001744:	7a02                	ld	s4,32(sp)
    80001746:	6ae2                	ld	s5,24(sp)
    80001748:	6b42                	ld	s6,16(sp)
    8000174a:	6ba2                	ld	s7,8(sp)
    8000174c:	6c02                	ld	s8,0(sp)
    8000174e:	6161                	addi	sp,sp,80
    80001750:	8082                	ret

0000000080001752 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001752:	caa5                	beqz	a3,800017c2 <copyin+0x70>
{
    80001754:	715d                	addi	sp,sp,-80
    80001756:	e486                	sd	ra,72(sp)
    80001758:	e0a2                	sd	s0,64(sp)
    8000175a:	fc26                	sd	s1,56(sp)
    8000175c:	f84a                	sd	s2,48(sp)
    8000175e:	f44e                	sd	s3,40(sp)
    80001760:	f052                	sd	s4,32(sp)
    80001762:	ec56                	sd	s5,24(sp)
    80001764:	e85a                	sd	s6,16(sp)
    80001766:	e45e                	sd	s7,8(sp)
    80001768:	e062                	sd	s8,0(sp)
    8000176a:	0880                	addi	s0,sp,80
    8000176c:	8baa                	mv	s7,a0
    8000176e:	8aae                	mv	s5,a1
    80001770:	8a32                	mv	s4,a2
    80001772:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001774:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001776:	6b05                	lui	s6,0x1
    80001778:	a01d                	j	8000179e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000177a:	014505b3          	add	a1,a0,s4
    8000177e:	0004861b          	sext.w	a2,s1
    80001782:	412585b3          	sub	a1,a1,s2
    80001786:	8556                	mv	a0,s5
    80001788:	fffff097          	auipc	ra,0xfffff
    8000178c:	604080e7          	jalr	1540(ra) # 80000d8c <memmove>

    len -= n;
    80001790:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001794:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001796:	01690a33          	add	s4,s2,s6
  while(len > 0){
    8000179a:	02098263          	beqz	s3,800017be <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000179e:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    800017a2:	85ca                	mv	a1,s2
    800017a4:	855e                	mv	a0,s7
    800017a6:	00000097          	auipc	ra,0x0
    800017aa:	930080e7          	jalr	-1744(ra) # 800010d6 <walkaddr>
    if(pa0 == 0)
    800017ae:	cd01                	beqz	a0,800017c6 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017b0:	414904b3          	sub	s1,s2,s4
    800017b4:	94da                	add	s1,s1,s6
    if(n > len)
    800017b6:	fc99f2e3          	bleu	s1,s3,8000177a <copyin+0x28>
    800017ba:	84ce                	mv	s1,s3
    800017bc:	bf7d                	j	8000177a <copyin+0x28>
  }
  return 0;
    800017be:	4501                	li	a0,0
    800017c0:	a021                	j	800017c8 <copyin+0x76>
    800017c2:	4501                	li	a0,0
}
    800017c4:	8082                	ret
      return -1;
    800017c6:	557d                	li	a0,-1
}
    800017c8:	60a6                	ld	ra,72(sp)
    800017ca:	6406                	ld	s0,64(sp)
    800017cc:	74e2                	ld	s1,56(sp)
    800017ce:	7942                	ld	s2,48(sp)
    800017d0:	79a2                	ld	s3,40(sp)
    800017d2:	7a02                	ld	s4,32(sp)
    800017d4:	6ae2                	ld	s5,24(sp)
    800017d6:	6b42                	ld	s6,16(sp)
    800017d8:	6ba2                	ld	s7,8(sp)
    800017da:	6c02                	ld	s8,0(sp)
    800017dc:	6161                	addi	sp,sp,80
    800017de:	8082                	ret

00000000800017e0 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017e0:	ced5                	beqz	a3,8000189c <copyinstr+0xbc>
{
    800017e2:	715d                	addi	sp,sp,-80
    800017e4:	e486                	sd	ra,72(sp)
    800017e6:	e0a2                	sd	s0,64(sp)
    800017e8:	fc26                	sd	s1,56(sp)
    800017ea:	f84a                	sd	s2,48(sp)
    800017ec:	f44e                	sd	s3,40(sp)
    800017ee:	f052                	sd	s4,32(sp)
    800017f0:	ec56                	sd	s5,24(sp)
    800017f2:	e85a                	sd	s6,16(sp)
    800017f4:	e45e                	sd	s7,8(sp)
    800017f6:	e062                	sd	s8,0(sp)
    800017f8:	0880                	addi	s0,sp,80
    800017fa:	8aaa                	mv	s5,a0
    800017fc:	84ae                	mv	s1,a1
    800017fe:	8c32                	mv	s8,a2
    80001800:	8bb6                	mv	s7,a3
    va0 = PGROUNDDOWN(srcva);
    80001802:	7a7d                	lui	s4,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001804:	6985                	lui	s3,0x1
    80001806:	4b05                	li	s6,1
    80001808:	a801                	j	80001818 <copyinstr+0x38>
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
    8000180a:	87a6                	mv	a5,s1
    8000180c:	a085                	j	8000186c <copyinstr+0x8c>
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    8000180e:	84b2                	mv	s1,a2
    }

    srcva = va0 + PGSIZE;
    80001810:	01390c33          	add	s8,s2,s3
  while(got_null == 0 && max > 0){
    80001814:	080b8063          	beqz	s7,80001894 <copyinstr+0xb4>
    va0 = PGROUNDDOWN(srcva);
    80001818:	014c7933          	and	s2,s8,s4
    pa0 = walkaddr(pagetable, va0);
    8000181c:	85ca                	mv	a1,s2
    8000181e:	8556                	mv	a0,s5
    80001820:	00000097          	auipc	ra,0x0
    80001824:	8b6080e7          	jalr	-1866(ra) # 800010d6 <walkaddr>
    if(pa0 == 0)
    80001828:	c925                	beqz	a0,80001898 <copyinstr+0xb8>
    n = PGSIZE - (srcva - va0);
    8000182a:	41890633          	sub	a2,s2,s8
    8000182e:	964e                	add	a2,a2,s3
    if(n > max)
    80001830:	00cbf363          	bleu	a2,s7,80001836 <copyinstr+0x56>
    80001834:	865e                	mv	a2,s7
    char *p = (char *) (pa0 + (srcva - va0));
    80001836:	9562                	add	a0,a0,s8
    80001838:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000183c:	da71                	beqz	a2,80001810 <copyinstr+0x30>
      if(*p == '\0'){
    8000183e:	00054703          	lbu	a4,0(a0)
    80001842:	d761                	beqz	a4,8000180a <copyinstr+0x2a>
    80001844:	9626                	add	a2,a2,s1
    80001846:	87a6                	mv	a5,s1
    80001848:	1bfd                	addi	s7,s7,-1
    8000184a:	009b86b3          	add	a3,s7,s1
    8000184e:	409b04b3          	sub	s1,s6,s1
    80001852:	94aa                	add	s1,s1,a0
        *dst = *p;
    80001854:	00e78023          	sb	a4,0(a5) # 1000 <_entry-0x7ffff000>
      --max;
    80001858:	40f68bb3          	sub	s7,a3,a5
      p++;
    8000185c:	00f48733          	add	a4,s1,a5
      dst++;
    80001860:	0785                	addi	a5,a5,1
    while(n > 0){
    80001862:	faf606e3          	beq	a2,a5,8000180e <copyinstr+0x2e>
      if(*p == '\0'){
    80001866:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffde000>
    8000186a:	f76d                	bnez	a4,80001854 <copyinstr+0x74>
        *dst = '\0';
    8000186c:	00078023          	sb	zero,0(a5)
    80001870:	4785                	li	a5,1
  }
  if(got_null){
    80001872:	0017b513          	seqz	a0,a5
    80001876:	40a0053b          	negw	a0,a0
    8000187a:	2501                	sext.w	a0,a0
    return 0;
  } else {
    return -1;
  }
}
    8000187c:	60a6                	ld	ra,72(sp)
    8000187e:	6406                	ld	s0,64(sp)
    80001880:	74e2                	ld	s1,56(sp)
    80001882:	7942                	ld	s2,48(sp)
    80001884:	79a2                	ld	s3,40(sp)
    80001886:	7a02                	ld	s4,32(sp)
    80001888:	6ae2                	ld	s5,24(sp)
    8000188a:	6b42                	ld	s6,16(sp)
    8000188c:	6ba2                	ld	s7,8(sp)
    8000188e:	6c02                	ld	s8,0(sp)
    80001890:	6161                	addi	sp,sp,80
    80001892:	8082                	ret
    80001894:	4781                	li	a5,0
    80001896:	bff1                	j	80001872 <copyinstr+0x92>
      return -1;
    80001898:	557d                	li	a0,-1
    8000189a:	b7cd                	j	8000187c <copyinstr+0x9c>
  int got_null = 0;
    8000189c:	4781                	li	a5,0
  if(got_null){
    8000189e:	0017b513          	seqz	a0,a5
    800018a2:	40a0053b          	negw	a0,a0
    800018a6:	2501                	sext.w	a0,a0
}
    800018a8:	8082                	ret

00000000800018aa <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800018aa:	1101                	addi	sp,sp,-32
    800018ac:	ec06                	sd	ra,24(sp)
    800018ae:	e822                	sd	s0,16(sp)
    800018b0:	e426                	sd	s1,8(sp)
    800018b2:	1000                	addi	s0,sp,32
    800018b4:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800018b6:	fffff097          	auipc	ra,0xfffff
    800018ba:	2f4080e7          	jalr	756(ra) # 80000baa <holding>
    800018be:	c909                	beqz	a0,800018d0 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800018c0:	749c                	ld	a5,40(s1)
    800018c2:	00978f63          	beq	a5,s1,800018e0 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    800018c6:	60e2                	ld	ra,24(sp)
    800018c8:	6442                	ld	s0,16(sp)
    800018ca:	64a2                	ld	s1,8(sp)
    800018cc:	6105                	addi	sp,sp,32
    800018ce:	8082                	ret
    panic("wakeup1");
    800018d0:	00007517          	auipc	a0,0x7
    800018d4:	91850513          	addi	a0,a0,-1768 # 800081e8 <states.1730+0x28>
    800018d8:	fffff097          	auipc	ra,0xfffff
    800018dc:	c80080e7          	jalr	-896(ra) # 80000558 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    800018e0:	4c98                	lw	a4,24(s1)
    800018e2:	4785                	li	a5,1
    800018e4:	fef711e3          	bne	a4,a5,800018c6 <wakeup1+0x1c>
    p->state = RUNNABLE;
    800018e8:	4789                	li	a5,2
    800018ea:	cc9c                	sw	a5,24(s1)
}
    800018ec:	bfe9                	j	800018c6 <wakeup1+0x1c>

00000000800018ee <proc_mapstacks>:
proc_mapstacks(pagetable_t kpgtbl) {
    800018ee:	7139                	addi	sp,sp,-64
    800018f0:	fc06                	sd	ra,56(sp)
    800018f2:	f822                	sd	s0,48(sp)
    800018f4:	f426                	sd	s1,40(sp)
    800018f6:	f04a                	sd	s2,32(sp)
    800018f8:	ec4e                	sd	s3,24(sp)
    800018fa:	e852                	sd	s4,16(sp)
    800018fc:	e456                	sd	s5,8(sp)
    800018fe:	e05a                	sd	s6,0(sp)
    80001900:	0080                	addi	s0,sp,64
    80001902:	8b2a                	mv	s6,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001904:	00010497          	auipc	s1,0x10
    80001908:	db448493          	addi	s1,s1,-588 # 800116b8 <proc>
    uint64 va = KSTACK((int) (p - proc));
    8000190c:	8aa6                	mv	s5,s1
    8000190e:	00006a17          	auipc	s4,0x6
    80001912:	6f2a0a13          	addi	s4,s4,1778 # 80008000 <etext>
    80001916:	04000937          	lui	s2,0x4000
    8000191a:	197d                	addi	s2,s2,-1
    8000191c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000191e:	00011997          	auipc	s3,0x11
    80001922:	baa98993          	addi	s3,s3,-1110 # 800124c8 <tickslock>
    char *pa = kalloc();
    80001926:	fffff097          	auipc	ra,0xfffff
    8000192a:	20e080e7          	jalr	526(ra) # 80000b34 <kalloc>
    if(pa == 0)
    8000192e:	c139                	beqz	a0,80001974 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001930:	415485b3          	sub	a1,s1,s5
    80001934:	858d                	srai	a1,a1,0x3
    80001936:	000a3783          	ld	a5,0(s4)
    8000193a:	02f585b3          	mul	a1,a1,a5
    8000193e:	2585                	addiw	a1,a1,1
    80001940:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001944:	4719                	li	a4,6
    80001946:	6685                	lui	a3,0x1
    80001948:	862a                	mv	a2,a0
    8000194a:	40b905b3          	sub	a1,s2,a1
    8000194e:	855a                	mv	a0,s6
    80001950:	00000097          	auipc	ra,0x0
    80001954:	854080e7          	jalr	-1964(ra) # 800011a4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001958:	16848493          	addi	s1,s1,360
    8000195c:	fd3495e3          	bne	s1,s3,80001926 <proc_mapstacks+0x38>
}
    80001960:	70e2                	ld	ra,56(sp)
    80001962:	7442                	ld	s0,48(sp)
    80001964:	74a2                	ld	s1,40(sp)
    80001966:	7902                	ld	s2,32(sp)
    80001968:	69e2                	ld	s3,24(sp)
    8000196a:	6a42                	ld	s4,16(sp)
    8000196c:	6aa2                	ld	s5,8(sp)
    8000196e:	6b02                	ld	s6,0(sp)
    80001970:	6121                	addi	sp,sp,64
    80001972:	8082                	ret
      panic("kalloc");
    80001974:	00007517          	auipc	a0,0x7
    80001978:	87c50513          	addi	a0,a0,-1924 # 800081f0 <states.1730+0x30>
    8000197c:	fffff097          	auipc	ra,0xfffff
    80001980:	bdc080e7          	jalr	-1060(ra) # 80000558 <panic>

0000000080001984 <procinit>:
{
    80001984:	7139                	addi	sp,sp,-64
    80001986:	fc06                	sd	ra,56(sp)
    80001988:	f822                	sd	s0,48(sp)
    8000198a:	f426                	sd	s1,40(sp)
    8000198c:	f04a                	sd	s2,32(sp)
    8000198e:	ec4e                	sd	s3,24(sp)
    80001990:	e852                	sd	s4,16(sp)
    80001992:	e456                	sd	s5,8(sp)
    80001994:	e05a                	sd	s6,0(sp)
    80001996:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    80001998:	00007597          	auipc	a1,0x7
    8000199c:	86058593          	addi	a1,a1,-1952 # 800081f8 <states.1730+0x38>
    800019a0:	00010517          	auipc	a0,0x10
    800019a4:	90050513          	addi	a0,a0,-1792 # 800112a0 <pid_lock>
    800019a8:	fffff097          	auipc	ra,0xfffff
    800019ac:	1ec080e7          	jalr	492(ra) # 80000b94 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b0:	00010497          	auipc	s1,0x10
    800019b4:	d0848493          	addi	s1,s1,-760 # 800116b8 <proc>
      initlock(&p->lock, "proc");
    800019b8:	00007b17          	auipc	s6,0x7
    800019bc:	848b0b13          	addi	s6,s6,-1976 # 80008200 <states.1730+0x40>
      p->kstack = KSTACK((int) (p - proc));
    800019c0:	8aa6                	mv	s5,s1
    800019c2:	00006a17          	auipc	s4,0x6
    800019c6:	63ea0a13          	addi	s4,s4,1598 # 80008000 <etext>
    800019ca:	04000937          	lui	s2,0x4000
    800019ce:	197d                	addi	s2,s2,-1
    800019d0:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d2:	00011997          	auipc	s3,0x11
    800019d6:	af698993          	addi	s3,s3,-1290 # 800124c8 <tickslock>
      initlock(&p->lock, "proc");
    800019da:	85da                	mv	a1,s6
    800019dc:	8526                	mv	a0,s1
    800019de:	fffff097          	auipc	ra,0xfffff
    800019e2:	1b6080e7          	jalr	438(ra) # 80000b94 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    800019e6:	415487b3          	sub	a5,s1,s5
    800019ea:	878d                	srai	a5,a5,0x3
    800019ec:	000a3703          	ld	a4,0(s4)
    800019f0:	02e787b3          	mul	a5,a5,a4
    800019f4:	2785                	addiw	a5,a5,1
    800019f6:	00d7979b          	slliw	a5,a5,0xd
    800019fa:	40f907b3          	sub	a5,s2,a5
    800019fe:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a00:	16848493          	addi	s1,s1,360
    80001a04:	fd349be3          	bne	s1,s3,800019da <procinit+0x56>
}
    80001a08:	70e2                	ld	ra,56(sp)
    80001a0a:	7442                	ld	s0,48(sp)
    80001a0c:	74a2                	ld	s1,40(sp)
    80001a0e:	7902                	ld	s2,32(sp)
    80001a10:	69e2                	ld	s3,24(sp)
    80001a12:	6a42                	ld	s4,16(sp)
    80001a14:	6aa2                	ld	s5,8(sp)
    80001a16:	6b02                	ld	s6,0(sp)
    80001a18:	6121                	addi	sp,sp,64
    80001a1a:	8082                	ret

0000000080001a1c <cpuid>:
{
    80001a1c:	1141                	addi	sp,sp,-16
    80001a1e:	e422                	sd	s0,8(sp)
    80001a20:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a22:	8512                	mv	a0,tp
}
    80001a24:	2501                	sext.w	a0,a0
    80001a26:	6422                	ld	s0,8(sp)
    80001a28:	0141                	addi	sp,sp,16
    80001a2a:	8082                	ret

0000000080001a2c <mycpu>:
mycpu(void) {
    80001a2c:	1141                	addi	sp,sp,-16
    80001a2e:	e422                	sd	s0,8(sp)
    80001a30:	0800                	addi	s0,sp,16
    80001a32:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a34:	2781                	sext.w	a5,a5
    80001a36:	079e                	slli	a5,a5,0x7
}
    80001a38:	00010517          	auipc	a0,0x10
    80001a3c:	88050513          	addi	a0,a0,-1920 # 800112b8 <cpus>
    80001a40:	953e                	add	a0,a0,a5
    80001a42:	6422                	ld	s0,8(sp)
    80001a44:	0141                	addi	sp,sp,16
    80001a46:	8082                	ret

0000000080001a48 <myproc>:
myproc(void) {
    80001a48:	1101                	addi	sp,sp,-32
    80001a4a:	ec06                	sd	ra,24(sp)
    80001a4c:	e822                	sd	s0,16(sp)
    80001a4e:	e426                	sd	s1,8(sp)
    80001a50:	1000                	addi	s0,sp,32
  push_off();
    80001a52:	fffff097          	auipc	ra,0xfffff
    80001a56:	186080e7          	jalr	390(ra) # 80000bd8 <push_off>
    80001a5a:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a5c:	2781                	sext.w	a5,a5
    80001a5e:	079e                	slli	a5,a5,0x7
    80001a60:	00010717          	auipc	a4,0x10
    80001a64:	84070713          	addi	a4,a4,-1984 # 800112a0 <pid_lock>
    80001a68:	97ba                	add	a5,a5,a4
    80001a6a:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a6c:	fffff097          	auipc	ra,0xfffff
    80001a70:	20c080e7          	jalr	524(ra) # 80000c78 <pop_off>
}
    80001a74:	8526                	mv	a0,s1
    80001a76:	60e2                	ld	ra,24(sp)
    80001a78:	6442                	ld	s0,16(sp)
    80001a7a:	64a2                	ld	s1,8(sp)
    80001a7c:	6105                	addi	sp,sp,32
    80001a7e:	8082                	ret

0000000080001a80 <forkret>:
{
    80001a80:	1141                	addi	sp,sp,-16
    80001a82:	e406                	sd	ra,8(sp)
    80001a84:	e022                	sd	s0,0(sp)
    80001a86:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a88:	00000097          	auipc	ra,0x0
    80001a8c:	fc0080e7          	jalr	-64(ra) # 80001a48 <myproc>
    80001a90:	fffff097          	auipc	ra,0xfffff
    80001a94:	248080e7          	jalr	584(ra) # 80000cd8 <release>
  if (first) {
    80001a98:	00007797          	auipc	a5,0x7
    80001a9c:	d5878793          	addi	a5,a5,-680 # 800087f0 <first.1690>
    80001aa0:	439c                	lw	a5,0(a5)
    80001aa2:	eb89                	bnez	a5,80001ab4 <forkret+0x34>
  usertrapret();
    80001aa4:	00001097          	auipc	ra,0x1
    80001aa8:	c26080e7          	jalr	-986(ra) # 800026ca <usertrapret>
}
    80001aac:	60a2                	ld	ra,8(sp)
    80001aae:	6402                	ld	s0,0(sp)
    80001ab0:	0141                	addi	sp,sp,16
    80001ab2:	8082                	ret
    first = 0;
    80001ab4:	00007797          	auipc	a5,0x7
    80001ab8:	d207ae23          	sw	zero,-708(a5) # 800087f0 <first.1690>
    fsinit(ROOTDEV);
    80001abc:	4505                	li	a0,1
    80001abe:	00002097          	auipc	ra,0x2
    80001ac2:	a66080e7          	jalr	-1434(ra) # 80003524 <fsinit>
    80001ac6:	bff9                	j	80001aa4 <forkret+0x24>

0000000080001ac8 <allocpid>:
allocpid() {
    80001ac8:	1101                	addi	sp,sp,-32
    80001aca:	ec06                	sd	ra,24(sp)
    80001acc:	e822                	sd	s0,16(sp)
    80001ace:	e426                	sd	s1,8(sp)
    80001ad0:	e04a                	sd	s2,0(sp)
    80001ad2:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ad4:	0000f917          	auipc	s2,0xf
    80001ad8:	7cc90913          	addi	s2,s2,1996 # 800112a0 <pid_lock>
    80001adc:	854a                	mv	a0,s2
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	146080e7          	jalr	326(ra) # 80000c24 <acquire>
  pid = nextpid;
    80001ae6:	00007797          	auipc	a5,0x7
    80001aea:	d0e78793          	addi	a5,a5,-754 # 800087f4 <nextpid>
    80001aee:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001af0:	0014871b          	addiw	a4,s1,1
    80001af4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001af6:	854a                	mv	a0,s2
    80001af8:	fffff097          	auipc	ra,0xfffff
    80001afc:	1e0080e7          	jalr	480(ra) # 80000cd8 <release>
}
    80001b00:	8526                	mv	a0,s1
    80001b02:	60e2                	ld	ra,24(sp)
    80001b04:	6442                	ld	s0,16(sp)
    80001b06:	64a2                	ld	s1,8(sp)
    80001b08:	6902                	ld	s2,0(sp)
    80001b0a:	6105                	addi	sp,sp,32
    80001b0c:	8082                	ret

0000000080001b0e <proc_pagetable>:
{
    80001b0e:	1101                	addi	sp,sp,-32
    80001b10:	ec06                	sd	ra,24(sp)
    80001b12:	e822                	sd	s0,16(sp)
    80001b14:	e426                	sd	s1,8(sp)
    80001b16:	e04a                	sd	s2,0(sp)
    80001b18:	1000                	addi	s0,sp,32
    80001b1a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b1c:	00000097          	auipc	ra,0x0
    80001b20:	874080e7          	jalr	-1932(ra) # 80001390 <uvmcreate>
    80001b24:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b26:	c121                	beqz	a0,80001b66 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b28:	4729                	li	a4,10
    80001b2a:	00005697          	auipc	a3,0x5
    80001b2e:	4d668693          	addi	a3,a3,1238 # 80007000 <_trampoline>
    80001b32:	6605                	lui	a2,0x1
    80001b34:	040005b7          	lui	a1,0x4000
    80001b38:	15fd                	addi	a1,a1,-1
    80001b3a:	05b2                	slli	a1,a1,0xc
    80001b3c:	fffff097          	auipc	ra,0xfffff
    80001b40:	5dc080e7          	jalr	1500(ra) # 80001118 <mappages>
    80001b44:	02054863          	bltz	a0,80001b74 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b48:	4719                	li	a4,6
    80001b4a:	05893683          	ld	a3,88(s2)
    80001b4e:	6605                	lui	a2,0x1
    80001b50:	020005b7          	lui	a1,0x2000
    80001b54:	15fd                	addi	a1,a1,-1
    80001b56:	05b6                	slli	a1,a1,0xd
    80001b58:	8526                	mv	a0,s1
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	5be080e7          	jalr	1470(ra) # 80001118 <mappages>
    80001b62:	02054163          	bltz	a0,80001b84 <proc_pagetable+0x76>
}
    80001b66:	8526                	mv	a0,s1
    80001b68:	60e2                	ld	ra,24(sp)
    80001b6a:	6442                	ld	s0,16(sp)
    80001b6c:	64a2                	ld	s1,8(sp)
    80001b6e:	6902                	ld	s2,0(sp)
    80001b70:	6105                	addi	sp,sp,32
    80001b72:	8082                	ret
    uvmfree(pagetable, 0);
    80001b74:	4581                	li	a1,0
    80001b76:	8526                	mv	a0,s1
    80001b78:	00000097          	auipc	ra,0x0
    80001b7c:	a12080e7          	jalr	-1518(ra) # 8000158a <uvmfree>
    return 0;
    80001b80:	4481                	li	s1,0
    80001b82:	b7d5                	j	80001b66 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b84:	4681                	li	a3,0
    80001b86:	4605                	li	a2,1
    80001b88:	040005b7          	lui	a1,0x4000
    80001b8c:	15fd                	addi	a1,a1,-1
    80001b8e:	05b2                	slli	a1,a1,0xc
    80001b90:	8526                	mv	a0,s1
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	738080e7          	jalr	1848(ra) # 800012ca <uvmunmap>
    uvmfree(pagetable, 0);
    80001b9a:	4581                	li	a1,0
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	00000097          	auipc	ra,0x0
    80001ba2:	9ec080e7          	jalr	-1556(ra) # 8000158a <uvmfree>
    return 0;
    80001ba6:	4481                	li	s1,0
    80001ba8:	bf7d                	j	80001b66 <proc_pagetable+0x58>

0000000080001baa <proc_freepagetable>:
{
    80001baa:	1101                	addi	sp,sp,-32
    80001bac:	ec06                	sd	ra,24(sp)
    80001bae:	e822                	sd	s0,16(sp)
    80001bb0:	e426                	sd	s1,8(sp)
    80001bb2:	e04a                	sd	s2,0(sp)
    80001bb4:	1000                	addi	s0,sp,32
    80001bb6:	84aa                	mv	s1,a0
    80001bb8:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bba:	4681                	li	a3,0
    80001bbc:	4605                	li	a2,1
    80001bbe:	040005b7          	lui	a1,0x4000
    80001bc2:	15fd                	addi	a1,a1,-1
    80001bc4:	05b2                	slli	a1,a1,0xc
    80001bc6:	fffff097          	auipc	ra,0xfffff
    80001bca:	704080e7          	jalr	1796(ra) # 800012ca <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bce:	4681                	li	a3,0
    80001bd0:	4605                	li	a2,1
    80001bd2:	020005b7          	lui	a1,0x2000
    80001bd6:	15fd                	addi	a1,a1,-1
    80001bd8:	05b6                	slli	a1,a1,0xd
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	6ee080e7          	jalr	1774(ra) # 800012ca <uvmunmap>
  uvmfree(pagetable, sz);
    80001be4:	85ca                	mv	a1,s2
    80001be6:	8526                	mv	a0,s1
    80001be8:	00000097          	auipc	ra,0x0
    80001bec:	9a2080e7          	jalr	-1630(ra) # 8000158a <uvmfree>
}
    80001bf0:	60e2                	ld	ra,24(sp)
    80001bf2:	6442                	ld	s0,16(sp)
    80001bf4:	64a2                	ld	s1,8(sp)
    80001bf6:	6902                	ld	s2,0(sp)
    80001bf8:	6105                	addi	sp,sp,32
    80001bfa:	8082                	ret

0000000080001bfc <freeproc>:
{
    80001bfc:	1101                	addi	sp,sp,-32
    80001bfe:	ec06                	sd	ra,24(sp)
    80001c00:	e822                	sd	s0,16(sp)
    80001c02:	e426                	sd	s1,8(sp)
    80001c04:	1000                	addi	s0,sp,32
    80001c06:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c08:	6d28                	ld	a0,88(a0)
    80001c0a:	c509                	beqz	a0,80001c14 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	e28080e7          	jalr	-472(ra) # 80000a34 <kfree>
  p->trapframe = 0;
    80001c14:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c18:	68a8                	ld	a0,80(s1)
    80001c1a:	c511                	beqz	a0,80001c26 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c1c:	64ac                	ld	a1,72(s1)
    80001c1e:	00000097          	auipc	ra,0x0
    80001c22:	f8c080e7          	jalr	-116(ra) # 80001baa <proc_freepagetable>
  p->pagetable = 0;
    80001c26:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c2a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c2e:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001c32:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c36:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c3a:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c3e:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c42:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c46:	0004ac23          	sw	zero,24(s1)
}
    80001c4a:	60e2                	ld	ra,24(sp)
    80001c4c:	6442                	ld	s0,16(sp)
    80001c4e:	64a2                	ld	s1,8(sp)
    80001c50:	6105                	addi	sp,sp,32
    80001c52:	8082                	ret

0000000080001c54 <allocproc>:
{
    80001c54:	1101                	addi	sp,sp,-32
    80001c56:	ec06                	sd	ra,24(sp)
    80001c58:	e822                	sd	s0,16(sp)
    80001c5a:	e426                	sd	s1,8(sp)
    80001c5c:	e04a                	sd	s2,0(sp)
    80001c5e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c60:	00010497          	auipc	s1,0x10
    80001c64:	a5848493          	addi	s1,s1,-1448 # 800116b8 <proc>
    80001c68:	00011917          	auipc	s2,0x11
    80001c6c:	86090913          	addi	s2,s2,-1952 # 800124c8 <tickslock>
    acquire(&p->lock);
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	fb2080e7          	jalr	-78(ra) # 80000c24 <acquire>
    if(p->state == UNUSED) {
    80001c7a:	4c9c                	lw	a5,24(s1)
    80001c7c:	c395                	beqz	a5,80001ca0 <allocproc+0x4c>
      release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	058080e7          	jalr	88(ra) # 80000cd8 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c88:	16848493          	addi	s1,s1,360
    80001c8c:	ff2492e3          	bne	s1,s2,80001c70 <allocproc+0x1c>
  return 0;
    80001c90:	4481                	li	s1,0
}
    80001c92:	8526                	mv	a0,s1
    80001c94:	60e2                	ld	ra,24(sp)
    80001c96:	6442                	ld	s0,16(sp)
    80001c98:	64a2                	ld	s1,8(sp)
    80001c9a:	6902                	ld	s2,0(sp)
    80001c9c:	6105                	addi	sp,sp,32
    80001c9e:	8082                	ret
  p->pid = allocpid();
    80001ca0:	00000097          	auipc	ra,0x0
    80001ca4:	e28080e7          	jalr	-472(ra) # 80001ac8 <allocpid>
    80001ca8:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001caa:	fffff097          	auipc	ra,0xfffff
    80001cae:	e8a080e7          	jalr	-374(ra) # 80000b34 <kalloc>
    80001cb2:	892a                	mv	s2,a0
    80001cb4:	eca8                	sd	a0,88(s1)
    80001cb6:	cd05                	beqz	a0,80001cee <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001cb8:	8526                	mv	a0,s1
    80001cba:	00000097          	auipc	ra,0x0
    80001cbe:	e54080e7          	jalr	-428(ra) # 80001b0e <proc_pagetable>
    80001cc2:	892a                	mv	s2,a0
    80001cc4:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cc6:	c91d                	beqz	a0,80001cfc <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001cc8:	07000613          	li	a2,112
    80001ccc:	4581                	li	a1,0
    80001cce:	06048513          	addi	a0,s1,96
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	04e080e7          	jalr	78(ra) # 80000d20 <memset>
  p->context.ra = (uint64)forkret;
    80001cda:	00000797          	auipc	a5,0x0
    80001cde:	da678793          	addi	a5,a5,-602 # 80001a80 <forkret>
    80001ce2:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ce4:	60bc                	ld	a5,64(s1)
    80001ce6:	6705                	lui	a4,0x1
    80001ce8:	97ba                	add	a5,a5,a4
    80001cea:	f4bc                	sd	a5,104(s1)
  return p;
    80001cec:	b75d                	j	80001c92 <allocproc+0x3e>
    release(&p->lock);
    80001cee:	8526                	mv	a0,s1
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	fe8080e7          	jalr	-24(ra) # 80000cd8 <release>
    return 0;
    80001cf8:	84ca                	mv	s1,s2
    80001cfa:	bf61                	j	80001c92 <allocproc+0x3e>
    freeproc(p);
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	00000097          	auipc	ra,0x0
    80001d02:	efe080e7          	jalr	-258(ra) # 80001bfc <freeproc>
    release(&p->lock);
    80001d06:	8526                	mv	a0,s1
    80001d08:	fffff097          	auipc	ra,0xfffff
    80001d0c:	fd0080e7          	jalr	-48(ra) # 80000cd8 <release>
    return 0;
    80001d10:	84ca                	mv	s1,s2
    80001d12:	b741                	j	80001c92 <allocproc+0x3e>

0000000080001d14 <userinit>:
{
    80001d14:	1101                	addi	sp,sp,-32
    80001d16:	ec06                	sd	ra,24(sp)
    80001d18:	e822                	sd	s0,16(sp)
    80001d1a:	e426                	sd	s1,8(sp)
    80001d1c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d1e:	00000097          	auipc	ra,0x0
    80001d22:	f36080e7          	jalr	-202(ra) # 80001c54 <allocproc>
    80001d26:	84aa                	mv	s1,a0
  initproc = p;
    80001d28:	00007797          	auipc	a5,0x7
    80001d2c:	30a7b023          	sd	a0,768(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d30:	03400613          	li	a2,52
    80001d34:	00007597          	auipc	a1,0x7
    80001d38:	acc58593          	addi	a1,a1,-1332 # 80008800 <initcode>
    80001d3c:	6928                	ld	a0,80(a0)
    80001d3e:	fffff097          	auipc	ra,0xfffff
    80001d42:	680080e7          	jalr	1664(ra) # 800013be <uvminit>
  p->sz = PGSIZE;
    80001d46:	6785                	lui	a5,0x1
    80001d48:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d4a:	6cb8                	ld	a4,88(s1)
    80001d4c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d50:	6cb8                	ld	a4,88(s1)
    80001d52:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d54:	4641                	li	a2,16
    80001d56:	00006597          	auipc	a1,0x6
    80001d5a:	4b258593          	addi	a1,a1,1202 # 80008208 <states.1730+0x48>
    80001d5e:	15848513          	addi	a0,s1,344
    80001d62:	fffff097          	auipc	ra,0xfffff
    80001d66:	136080e7          	jalr	310(ra) # 80000e98 <safestrcpy>
  p->cwd = namei("/");
    80001d6a:	00006517          	auipc	a0,0x6
    80001d6e:	4ae50513          	addi	a0,a0,1198 # 80008218 <states.1730+0x58>
    80001d72:	00002097          	auipc	ra,0x2
    80001d76:	294080e7          	jalr	660(ra) # 80004006 <namei>
    80001d7a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d7e:	4789                	li	a5,2
    80001d80:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d82:	8526                	mv	a0,s1
    80001d84:	fffff097          	auipc	ra,0xfffff
    80001d88:	f54080e7          	jalr	-172(ra) # 80000cd8 <release>
}
    80001d8c:	60e2                	ld	ra,24(sp)
    80001d8e:	6442                	ld	s0,16(sp)
    80001d90:	64a2                	ld	s1,8(sp)
    80001d92:	6105                	addi	sp,sp,32
    80001d94:	8082                	ret

0000000080001d96 <growproc>:
{
    80001d96:	1101                	addi	sp,sp,-32
    80001d98:	ec06                	sd	ra,24(sp)
    80001d9a:	e822                	sd	s0,16(sp)
    80001d9c:	e426                	sd	s1,8(sp)
    80001d9e:	e04a                	sd	s2,0(sp)
    80001da0:	1000                	addi	s0,sp,32
    80001da2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001da4:	00000097          	auipc	ra,0x0
    80001da8:	ca4080e7          	jalr	-860(ra) # 80001a48 <myproc>
    80001dac:	892a                	mv	s2,a0
  sz = p->sz;
    80001dae:	652c                	ld	a1,72(a0)
    80001db0:	0005851b          	sext.w	a0,a1
  if(n > 0){
    80001db4:	00904f63          	bgtz	s1,80001dd2 <growproc+0x3c>
  } else if(n < 0){
    80001db8:	0204cd63          	bltz	s1,80001df2 <growproc+0x5c>
  p->sz = sz;
    80001dbc:	1502                	slli	a0,a0,0x20
    80001dbe:	9101                	srli	a0,a0,0x20
    80001dc0:	04a93423          	sd	a0,72(s2)
  return 0;
    80001dc4:	4501                	li	a0,0
}
    80001dc6:	60e2                	ld	ra,24(sp)
    80001dc8:	6442                	ld	s0,16(sp)
    80001dca:	64a2                	ld	s1,8(sp)
    80001dcc:	6902                	ld	s2,0(sp)
    80001dce:	6105                	addi	sp,sp,32
    80001dd0:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dd2:	00a4863b          	addw	a2,s1,a0
    80001dd6:	1602                	slli	a2,a2,0x20
    80001dd8:	9201                	srli	a2,a2,0x20
    80001dda:	1582                	slli	a1,a1,0x20
    80001ddc:	9181                	srli	a1,a1,0x20
    80001dde:	05093503          	ld	a0,80(s2)
    80001de2:	fffff097          	auipc	ra,0xfffff
    80001de6:	694080e7          	jalr	1684(ra) # 80001476 <uvmalloc>
    80001dea:	2501                	sext.w	a0,a0
    80001dec:	f961                	bnez	a0,80001dbc <growproc+0x26>
      return -1;
    80001dee:	557d                	li	a0,-1
    80001df0:	bfd9                	j	80001dc6 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001df2:	00a4863b          	addw	a2,s1,a0
    80001df6:	1602                	slli	a2,a2,0x20
    80001df8:	9201                	srli	a2,a2,0x20
    80001dfa:	1582                	slli	a1,a1,0x20
    80001dfc:	9181                	srli	a1,a1,0x20
    80001dfe:	05093503          	ld	a0,80(s2)
    80001e02:	fffff097          	auipc	ra,0xfffff
    80001e06:	62e080e7          	jalr	1582(ra) # 80001430 <uvmdealloc>
    80001e0a:	2501                	sext.w	a0,a0
    80001e0c:	bf45                	j	80001dbc <growproc+0x26>

0000000080001e0e <fork>:
{
    80001e0e:	7179                	addi	sp,sp,-48
    80001e10:	f406                	sd	ra,40(sp)
    80001e12:	f022                	sd	s0,32(sp)
    80001e14:	ec26                	sd	s1,24(sp)
    80001e16:	e84a                	sd	s2,16(sp)
    80001e18:	e44e                	sd	s3,8(sp)
    80001e1a:	e052                	sd	s4,0(sp)
    80001e1c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e1e:	00000097          	auipc	ra,0x0
    80001e22:	c2a080e7          	jalr	-982(ra) # 80001a48 <myproc>
    80001e26:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001e28:	00000097          	auipc	ra,0x0
    80001e2c:	e2c080e7          	jalr	-468(ra) # 80001c54 <allocproc>
    80001e30:	c175                	beqz	a0,80001f14 <fork+0x106>
    80001e32:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e34:	04893603          	ld	a2,72(s2)
    80001e38:	692c                	ld	a1,80(a0)
    80001e3a:	05093503          	ld	a0,80(s2)
    80001e3e:	fffff097          	auipc	ra,0xfffff
    80001e42:	784080e7          	jalr	1924(ra) # 800015c2 <uvmcopy>
    80001e46:	04054863          	bltz	a0,80001e96 <fork+0x88>
  np->sz = p->sz;
    80001e4a:	04893783          	ld	a5,72(s2)
    80001e4e:	04f9b423          	sd	a5,72(s3)
  np->parent = p;
    80001e52:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e56:	05893683          	ld	a3,88(s2)
    80001e5a:	87b6                	mv	a5,a3
    80001e5c:	0589b703          	ld	a4,88(s3)
    80001e60:	12068693          	addi	a3,a3,288
    80001e64:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e68:	6788                	ld	a0,8(a5)
    80001e6a:	6b8c                	ld	a1,16(a5)
    80001e6c:	6f90                	ld	a2,24(a5)
    80001e6e:	01073023          	sd	a6,0(a4)
    80001e72:	e708                	sd	a0,8(a4)
    80001e74:	eb0c                	sd	a1,16(a4)
    80001e76:	ef10                	sd	a2,24(a4)
    80001e78:	02078793          	addi	a5,a5,32
    80001e7c:	02070713          	addi	a4,a4,32
    80001e80:	fed792e3          	bne	a5,a3,80001e64 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e84:	0589b783          	ld	a5,88(s3)
    80001e88:	0607b823          	sd	zero,112(a5)
    80001e8c:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001e90:	15000a13          	li	s4,336
    80001e94:	a03d                	j	80001ec2 <fork+0xb4>
    freeproc(np);
    80001e96:	854e                	mv	a0,s3
    80001e98:	00000097          	auipc	ra,0x0
    80001e9c:	d64080e7          	jalr	-668(ra) # 80001bfc <freeproc>
    release(&np->lock);
    80001ea0:	854e                	mv	a0,s3
    80001ea2:	fffff097          	auipc	ra,0xfffff
    80001ea6:	e36080e7          	jalr	-458(ra) # 80000cd8 <release>
    return -1;
    80001eaa:	54fd                	li	s1,-1
    80001eac:	a899                	j	80001f02 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eae:	00003097          	auipc	ra,0x3
    80001eb2:	828080e7          	jalr	-2008(ra) # 800046d6 <filedup>
    80001eb6:	009987b3          	add	a5,s3,s1
    80001eba:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001ebc:	04a1                	addi	s1,s1,8
    80001ebe:	01448763          	beq	s1,s4,80001ecc <fork+0xbe>
    if(p->ofile[i])
    80001ec2:	009907b3          	add	a5,s2,s1
    80001ec6:	6388                	ld	a0,0(a5)
    80001ec8:	f17d                	bnez	a0,80001eae <fork+0xa0>
    80001eca:	bfcd                	j	80001ebc <fork+0xae>
  np->cwd = idup(p->cwd);
    80001ecc:	15093503          	ld	a0,336(s2)
    80001ed0:	00002097          	auipc	ra,0x2
    80001ed4:	890080e7          	jalr	-1904(ra) # 80003760 <idup>
    80001ed8:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001edc:	4641                	li	a2,16
    80001ede:	15890593          	addi	a1,s2,344
    80001ee2:	15898513          	addi	a0,s3,344
    80001ee6:	fffff097          	auipc	ra,0xfffff
    80001eea:	fb2080e7          	jalr	-78(ra) # 80000e98 <safestrcpy>
  pid = np->pid;
    80001eee:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001ef2:	4789                	li	a5,2
    80001ef4:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001ef8:	854e                	mv	a0,s3
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	dde080e7          	jalr	-546(ra) # 80000cd8 <release>
}
    80001f02:	8526                	mv	a0,s1
    80001f04:	70a2                	ld	ra,40(sp)
    80001f06:	7402                	ld	s0,32(sp)
    80001f08:	64e2                	ld	s1,24(sp)
    80001f0a:	6942                	ld	s2,16(sp)
    80001f0c:	69a2                	ld	s3,8(sp)
    80001f0e:	6a02                	ld	s4,0(sp)
    80001f10:	6145                	addi	sp,sp,48
    80001f12:	8082                	ret
    return -1;
    80001f14:	54fd                	li	s1,-1
    80001f16:	b7f5                	j	80001f02 <fork+0xf4>

0000000080001f18 <reparent>:
{
    80001f18:	7179                	addi	sp,sp,-48
    80001f1a:	f406                	sd	ra,40(sp)
    80001f1c:	f022                	sd	s0,32(sp)
    80001f1e:	ec26                	sd	s1,24(sp)
    80001f20:	e84a                	sd	s2,16(sp)
    80001f22:	e44e                	sd	s3,8(sp)
    80001f24:	e052                	sd	s4,0(sp)
    80001f26:	1800                	addi	s0,sp,48
    80001f28:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f2a:	0000f497          	auipc	s1,0xf
    80001f2e:	78e48493          	addi	s1,s1,1934 # 800116b8 <proc>
      pp->parent = initproc;
    80001f32:	00007a17          	auipc	s4,0x7
    80001f36:	0f6a0a13          	addi	s4,s4,246 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f3a:	00010917          	auipc	s2,0x10
    80001f3e:	58e90913          	addi	s2,s2,1422 # 800124c8 <tickslock>
    80001f42:	a029                	j	80001f4c <reparent+0x34>
    80001f44:	16848493          	addi	s1,s1,360
    80001f48:	03248363          	beq	s1,s2,80001f6e <reparent+0x56>
    if(pp->parent == p){
    80001f4c:	709c                	ld	a5,32(s1)
    80001f4e:	ff379be3          	bne	a5,s3,80001f44 <reparent+0x2c>
      acquire(&pp->lock);
    80001f52:	8526                	mv	a0,s1
    80001f54:	fffff097          	auipc	ra,0xfffff
    80001f58:	cd0080e7          	jalr	-816(ra) # 80000c24 <acquire>
      pp->parent = initproc;
    80001f5c:	000a3783          	ld	a5,0(s4)
    80001f60:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001f62:	8526                	mv	a0,s1
    80001f64:	fffff097          	auipc	ra,0xfffff
    80001f68:	d74080e7          	jalr	-652(ra) # 80000cd8 <release>
    80001f6c:	bfe1                	j	80001f44 <reparent+0x2c>
}
    80001f6e:	70a2                	ld	ra,40(sp)
    80001f70:	7402                	ld	s0,32(sp)
    80001f72:	64e2                	ld	s1,24(sp)
    80001f74:	6942                	ld	s2,16(sp)
    80001f76:	69a2                	ld	s3,8(sp)
    80001f78:	6a02                	ld	s4,0(sp)
    80001f7a:	6145                	addi	sp,sp,48
    80001f7c:	8082                	ret

0000000080001f7e <scheduler>:
{
    80001f7e:	711d                	addi	sp,sp,-96
    80001f80:	ec86                	sd	ra,88(sp)
    80001f82:	e8a2                	sd	s0,80(sp)
    80001f84:	e4a6                	sd	s1,72(sp)
    80001f86:	e0ca                	sd	s2,64(sp)
    80001f88:	fc4e                	sd	s3,56(sp)
    80001f8a:	f852                	sd	s4,48(sp)
    80001f8c:	f456                	sd	s5,40(sp)
    80001f8e:	f05a                	sd	s6,32(sp)
    80001f90:	ec5e                	sd	s7,24(sp)
    80001f92:	e862                	sd	s8,16(sp)
    80001f94:	e466                	sd	s9,8(sp)
    80001f96:	1080                	addi	s0,sp,96
    80001f98:	8792                	mv	a5,tp
  int id = r_tp();
    80001f9a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f9c:	00779b93          	slli	s7,a5,0x7
    80001fa0:	0000f717          	auipc	a4,0xf
    80001fa4:	30070713          	addi	a4,a4,768 # 800112a0 <pid_lock>
    80001fa8:	975e                	add	a4,a4,s7
    80001faa:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001fae:	0000f717          	auipc	a4,0xf
    80001fb2:	31270713          	addi	a4,a4,786 # 800112c0 <cpus+0x8>
    80001fb6:	9bba                	add	s7,s7,a4
      if(p->state == RUNNABLE) {
    80001fb8:	4a89                	li	s5,2
        c->proc = p;
    80001fba:	079e                	slli	a5,a5,0x7
    80001fbc:	0000fb17          	auipc	s6,0xf
    80001fc0:	2e4b0b13          	addi	s6,s6,740 # 800112a0 <pid_lock>
    80001fc4:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fc6:	00010a17          	auipc	s4,0x10
    80001fca:	502a0a13          	addi	s4,s4,1282 # 800124c8 <tickslock>
    int nproc = 0;
    80001fce:	4c01                	li	s8,0
    80001fd0:	a8a1                	j	80002028 <scheduler+0xaa>
        p->state = RUNNING;
    80001fd2:	0194ac23          	sw	s9,24(s1)
        c->proc = p;
    80001fd6:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    80001fda:	06048593          	addi	a1,s1,96
    80001fde:	855e                	mv	a0,s7
    80001fe0:	00000097          	auipc	ra,0x0
    80001fe4:	640080e7          	jalr	1600(ra) # 80002620 <swtch>
        c->proc = 0;
    80001fe8:	000b3c23          	sd	zero,24(s6)
      release(&p->lock);
    80001fec:	8526                	mv	a0,s1
    80001fee:	fffff097          	auipc	ra,0xfffff
    80001ff2:	cea080e7          	jalr	-790(ra) # 80000cd8 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ff6:	16848493          	addi	s1,s1,360
    80001ffa:	01448d63          	beq	s1,s4,80002014 <scheduler+0x96>
      acquire(&p->lock);
    80001ffe:	8526                	mv	a0,s1
    80002000:	fffff097          	auipc	ra,0xfffff
    80002004:	c24080e7          	jalr	-988(ra) # 80000c24 <acquire>
      if(p->state != UNUSED) {
    80002008:	4c9c                	lw	a5,24(s1)
    8000200a:	d3ed                	beqz	a5,80001fec <scheduler+0x6e>
        nproc++;
    8000200c:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    8000200e:	fd579fe3          	bne	a5,s5,80001fec <scheduler+0x6e>
    80002012:	b7c1                	j	80001fd2 <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    80002014:	013aca63          	blt	s5,s3,80002028 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002018:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000201c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002020:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80002024:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002028:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000202c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002030:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    80002034:	89e2                	mv	s3,s8
    for(p = proc; p < &proc[NPROC]; p++) {
    80002036:	0000f497          	auipc	s1,0xf
    8000203a:	68248493          	addi	s1,s1,1666 # 800116b8 <proc>
        p->state = RUNNING;
    8000203e:	4c8d                	li	s9,3
    80002040:	bf7d                	j	80001ffe <scheduler+0x80>

0000000080002042 <sched>:
{
    80002042:	7179                	addi	sp,sp,-48
    80002044:	f406                	sd	ra,40(sp)
    80002046:	f022                	sd	s0,32(sp)
    80002048:	ec26                	sd	s1,24(sp)
    8000204a:	e84a                	sd	s2,16(sp)
    8000204c:	e44e                	sd	s3,8(sp)
    8000204e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002050:	00000097          	auipc	ra,0x0
    80002054:	9f8080e7          	jalr	-1544(ra) # 80001a48 <myproc>
    80002058:	892a                	mv	s2,a0
  if(!holding(&p->lock))
    8000205a:	fffff097          	auipc	ra,0xfffff
    8000205e:	b50080e7          	jalr	-1200(ra) # 80000baa <holding>
    80002062:	cd25                	beqz	a0,800020da <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002064:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002066:	2781                	sext.w	a5,a5
    80002068:	079e                	slli	a5,a5,0x7
    8000206a:	0000f717          	auipc	a4,0xf
    8000206e:	23670713          	addi	a4,a4,566 # 800112a0 <pid_lock>
    80002072:	97ba                	add	a5,a5,a4
    80002074:	0907a703          	lw	a4,144(a5)
    80002078:	4785                	li	a5,1
    8000207a:	06f71863          	bne	a4,a5,800020ea <sched+0xa8>
  if(p->state == RUNNING)
    8000207e:	01892703          	lw	a4,24(s2)
    80002082:	478d                	li	a5,3
    80002084:	06f70b63          	beq	a4,a5,800020fa <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002088:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000208c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000208e:	efb5                	bnez	a5,8000210a <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002090:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002092:	0000f497          	auipc	s1,0xf
    80002096:	20e48493          	addi	s1,s1,526 # 800112a0 <pid_lock>
    8000209a:	2781                	sext.w	a5,a5
    8000209c:	079e                	slli	a5,a5,0x7
    8000209e:	97a6                	add	a5,a5,s1
    800020a0:	0947a983          	lw	s3,148(a5)
    800020a4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020a6:	2781                	sext.w	a5,a5
    800020a8:	079e                	slli	a5,a5,0x7
    800020aa:	0000f597          	auipc	a1,0xf
    800020ae:	21658593          	addi	a1,a1,534 # 800112c0 <cpus+0x8>
    800020b2:	95be                	add	a1,a1,a5
    800020b4:	06090513          	addi	a0,s2,96
    800020b8:	00000097          	auipc	ra,0x0
    800020bc:	568080e7          	jalr	1384(ra) # 80002620 <swtch>
    800020c0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020c2:	2781                	sext.w	a5,a5
    800020c4:	079e                	slli	a5,a5,0x7
    800020c6:	97a6                	add	a5,a5,s1
    800020c8:	0937aa23          	sw	s3,148(a5)
}
    800020cc:	70a2                	ld	ra,40(sp)
    800020ce:	7402                	ld	s0,32(sp)
    800020d0:	64e2                	ld	s1,24(sp)
    800020d2:	6942                	ld	s2,16(sp)
    800020d4:	69a2                	ld	s3,8(sp)
    800020d6:	6145                	addi	sp,sp,48
    800020d8:	8082                	ret
    panic("sched p->lock");
    800020da:	00006517          	auipc	a0,0x6
    800020de:	14650513          	addi	a0,a0,326 # 80008220 <states.1730+0x60>
    800020e2:	ffffe097          	auipc	ra,0xffffe
    800020e6:	476080e7          	jalr	1142(ra) # 80000558 <panic>
    panic("sched locks");
    800020ea:	00006517          	auipc	a0,0x6
    800020ee:	14650513          	addi	a0,a0,326 # 80008230 <states.1730+0x70>
    800020f2:	ffffe097          	auipc	ra,0xffffe
    800020f6:	466080e7          	jalr	1126(ra) # 80000558 <panic>
    panic("sched running");
    800020fa:	00006517          	auipc	a0,0x6
    800020fe:	14650513          	addi	a0,a0,326 # 80008240 <states.1730+0x80>
    80002102:	ffffe097          	auipc	ra,0xffffe
    80002106:	456080e7          	jalr	1110(ra) # 80000558 <panic>
    panic("sched interruptible");
    8000210a:	00006517          	auipc	a0,0x6
    8000210e:	14650513          	addi	a0,a0,326 # 80008250 <states.1730+0x90>
    80002112:	ffffe097          	auipc	ra,0xffffe
    80002116:	446080e7          	jalr	1094(ra) # 80000558 <panic>

000000008000211a <exit>:
{
    8000211a:	7179                	addi	sp,sp,-48
    8000211c:	f406                	sd	ra,40(sp)
    8000211e:	f022                	sd	s0,32(sp)
    80002120:	ec26                	sd	s1,24(sp)
    80002122:	e84a                	sd	s2,16(sp)
    80002124:	e44e                	sd	s3,8(sp)
    80002126:	e052                	sd	s4,0(sp)
    80002128:	1800                	addi	s0,sp,48
    8000212a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000212c:	00000097          	auipc	ra,0x0
    80002130:	91c080e7          	jalr	-1764(ra) # 80001a48 <myproc>
    80002134:	89aa                	mv	s3,a0
  if(p == initproc)
    80002136:	00007797          	auipc	a5,0x7
    8000213a:	ef278793          	addi	a5,a5,-270 # 80009028 <initproc>
    8000213e:	639c                	ld	a5,0(a5)
    80002140:	0d050493          	addi	s1,a0,208
    80002144:	15050913          	addi	s2,a0,336
    80002148:	02a79363          	bne	a5,a0,8000216e <exit+0x54>
    panic("init exiting");
    8000214c:	00006517          	auipc	a0,0x6
    80002150:	11c50513          	addi	a0,a0,284 # 80008268 <states.1730+0xa8>
    80002154:	ffffe097          	auipc	ra,0xffffe
    80002158:	404080e7          	jalr	1028(ra) # 80000558 <panic>
      fileclose(f);
    8000215c:	00002097          	auipc	ra,0x2
    80002160:	5cc080e7          	jalr	1484(ra) # 80004728 <fileclose>
      p->ofile[fd] = 0;
    80002164:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002168:	04a1                	addi	s1,s1,8
    8000216a:	01248563          	beq	s1,s2,80002174 <exit+0x5a>
    if(p->ofile[fd]){
    8000216e:	6088                	ld	a0,0(s1)
    80002170:	f575                	bnez	a0,8000215c <exit+0x42>
    80002172:	bfdd                	j	80002168 <exit+0x4e>
  begin_op();
    80002174:	00002097          	auipc	ra,0x2
    80002178:	0b0080e7          	jalr	176(ra) # 80004224 <begin_op>
  iput(p->cwd);
    8000217c:	1509b503          	ld	a0,336(s3)
    80002180:	00002097          	auipc	ra,0x2
    80002184:	880080e7          	jalr	-1920(ra) # 80003a00 <iput>
  end_op();
    80002188:	00002097          	auipc	ra,0x2
    8000218c:	11c080e7          	jalr	284(ra) # 800042a4 <end_op>
  p->cwd = 0;
    80002190:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    80002194:	00007497          	auipc	s1,0x7
    80002198:	e9448493          	addi	s1,s1,-364 # 80009028 <initproc>
    8000219c:	6088                	ld	a0,0(s1)
    8000219e:	fffff097          	auipc	ra,0xfffff
    800021a2:	a86080e7          	jalr	-1402(ra) # 80000c24 <acquire>
  wakeup1(initproc);
    800021a6:	6088                	ld	a0,0(s1)
    800021a8:	fffff097          	auipc	ra,0xfffff
    800021ac:	702080e7          	jalr	1794(ra) # 800018aa <wakeup1>
  release(&initproc->lock);
    800021b0:	6088                	ld	a0,0(s1)
    800021b2:	fffff097          	auipc	ra,0xfffff
    800021b6:	b26080e7          	jalr	-1242(ra) # 80000cd8 <release>
  acquire(&p->lock);
    800021ba:	854e                	mv	a0,s3
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	a68080e7          	jalr	-1432(ra) # 80000c24 <acquire>
  struct proc *original_parent = p->parent;
    800021c4:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    800021c8:	854e                	mv	a0,s3
    800021ca:	fffff097          	auipc	ra,0xfffff
    800021ce:	b0e080e7          	jalr	-1266(ra) # 80000cd8 <release>
  acquire(&original_parent->lock);
    800021d2:	8526                	mv	a0,s1
    800021d4:	fffff097          	auipc	ra,0xfffff
    800021d8:	a50080e7          	jalr	-1456(ra) # 80000c24 <acquire>
  acquire(&p->lock);
    800021dc:	854e                	mv	a0,s3
    800021de:	fffff097          	auipc	ra,0xfffff
    800021e2:	a46080e7          	jalr	-1466(ra) # 80000c24 <acquire>
  reparent(p);
    800021e6:	854e                	mv	a0,s3
    800021e8:	00000097          	auipc	ra,0x0
    800021ec:	d30080e7          	jalr	-720(ra) # 80001f18 <reparent>
  wakeup1(original_parent);
    800021f0:	8526                	mv	a0,s1
    800021f2:	fffff097          	auipc	ra,0xfffff
    800021f6:	6b8080e7          	jalr	1720(ra) # 800018aa <wakeup1>
  p->xstate = status;
    800021fa:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800021fe:	4791                	li	a5,4
    80002200:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    80002204:	8526                	mv	a0,s1
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	ad2080e7          	jalr	-1326(ra) # 80000cd8 <release>
  sched();
    8000220e:	00000097          	auipc	ra,0x0
    80002212:	e34080e7          	jalr	-460(ra) # 80002042 <sched>
  panic("zombie exit");
    80002216:	00006517          	auipc	a0,0x6
    8000221a:	06250513          	addi	a0,a0,98 # 80008278 <states.1730+0xb8>
    8000221e:	ffffe097          	auipc	ra,0xffffe
    80002222:	33a080e7          	jalr	826(ra) # 80000558 <panic>

0000000080002226 <yield>:
{
    80002226:	1101                	addi	sp,sp,-32
    80002228:	ec06                	sd	ra,24(sp)
    8000222a:	e822                	sd	s0,16(sp)
    8000222c:	e426                	sd	s1,8(sp)
    8000222e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002230:	00000097          	auipc	ra,0x0
    80002234:	818080e7          	jalr	-2024(ra) # 80001a48 <myproc>
    80002238:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000223a:	fffff097          	auipc	ra,0xfffff
    8000223e:	9ea080e7          	jalr	-1558(ra) # 80000c24 <acquire>
  p->state = RUNNABLE;
    80002242:	4789                	li	a5,2
    80002244:	cc9c                	sw	a5,24(s1)
  sched();
    80002246:	00000097          	auipc	ra,0x0
    8000224a:	dfc080e7          	jalr	-516(ra) # 80002042 <sched>
  release(&p->lock);
    8000224e:	8526                	mv	a0,s1
    80002250:	fffff097          	auipc	ra,0xfffff
    80002254:	a88080e7          	jalr	-1400(ra) # 80000cd8 <release>
}
    80002258:	60e2                	ld	ra,24(sp)
    8000225a:	6442                	ld	s0,16(sp)
    8000225c:	64a2                	ld	s1,8(sp)
    8000225e:	6105                	addi	sp,sp,32
    80002260:	8082                	ret

0000000080002262 <sleep>:
{
    80002262:	7179                	addi	sp,sp,-48
    80002264:	f406                	sd	ra,40(sp)
    80002266:	f022                	sd	s0,32(sp)
    80002268:	ec26                	sd	s1,24(sp)
    8000226a:	e84a                	sd	s2,16(sp)
    8000226c:	e44e                	sd	s3,8(sp)
    8000226e:	1800                	addi	s0,sp,48
    80002270:	89aa                	mv	s3,a0
    80002272:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	7d4080e7          	jalr	2004(ra) # 80001a48 <myproc>
    8000227c:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8000227e:	05250663          	beq	a0,s2,800022ca <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	9a2080e7          	jalr	-1630(ra) # 80000c24 <acquire>
    release(lk);
    8000228a:	854a                	mv	a0,s2
    8000228c:	fffff097          	auipc	ra,0xfffff
    80002290:	a4c080e7          	jalr	-1460(ra) # 80000cd8 <release>
  p->chan = chan;
    80002294:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002298:	4785                	li	a5,1
    8000229a:	cc9c                	sw	a5,24(s1)
  sched();
    8000229c:	00000097          	auipc	ra,0x0
    800022a0:	da6080e7          	jalr	-602(ra) # 80002042 <sched>
  p->chan = 0;
    800022a4:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800022a8:	8526                	mv	a0,s1
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	a2e080e7          	jalr	-1490(ra) # 80000cd8 <release>
    acquire(lk);
    800022b2:	854a                	mv	a0,s2
    800022b4:	fffff097          	auipc	ra,0xfffff
    800022b8:	970080e7          	jalr	-1680(ra) # 80000c24 <acquire>
}
    800022bc:	70a2                	ld	ra,40(sp)
    800022be:	7402                	ld	s0,32(sp)
    800022c0:	64e2                	ld	s1,24(sp)
    800022c2:	6942                	ld	s2,16(sp)
    800022c4:	69a2                	ld	s3,8(sp)
    800022c6:	6145                	addi	sp,sp,48
    800022c8:	8082                	ret
  p->chan = chan;
    800022ca:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800022ce:	4785                	li	a5,1
    800022d0:	cd1c                	sw	a5,24(a0)
  sched();
    800022d2:	00000097          	auipc	ra,0x0
    800022d6:	d70080e7          	jalr	-656(ra) # 80002042 <sched>
  p->chan = 0;
    800022da:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800022de:	bff9                	j	800022bc <sleep+0x5a>

00000000800022e0 <wait>:
{
    800022e0:	715d                	addi	sp,sp,-80
    800022e2:	e486                	sd	ra,72(sp)
    800022e4:	e0a2                	sd	s0,64(sp)
    800022e6:	fc26                	sd	s1,56(sp)
    800022e8:	f84a                	sd	s2,48(sp)
    800022ea:	f44e                	sd	s3,40(sp)
    800022ec:	f052                	sd	s4,32(sp)
    800022ee:	ec56                	sd	s5,24(sp)
    800022f0:	e85a                	sd	s6,16(sp)
    800022f2:	e45e                	sd	s7,8(sp)
    800022f4:	e062                	sd	s8,0(sp)
    800022f6:	0880                	addi	s0,sp,80
    800022f8:	8c2a                	mv	s8,a0
  struct proc *p = myproc();
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	74e080e7          	jalr	1870(ra) # 80001a48 <myproc>
    80002302:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002304:	8baa                	mv	s7,a0
    80002306:	fffff097          	auipc	ra,0xfffff
    8000230a:	91e080e7          	jalr	-1762(ra) # 80000c24 <acquire>
    havekids = 0;
    8000230e:	4b01                	li	s6,0
        if(np->state == ZOMBIE){
    80002310:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    80002312:	00010997          	auipc	s3,0x10
    80002316:	1b698993          	addi	s3,s3,438 # 800124c8 <tickslock>
        havekids = 1;
    8000231a:	4a85                	li	s5,1
    havekids = 0;
    8000231c:	875a                	mv	a4,s6
    for(np = proc; np < &proc[NPROC]; np++){
    8000231e:	0000f497          	auipc	s1,0xf
    80002322:	39a48493          	addi	s1,s1,922 # 800116b8 <proc>
    80002326:	a08d                	j	80002388 <wait+0xa8>
          pid = np->pid;
    80002328:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000232c:	000c0e63          	beqz	s8,80002348 <wait+0x68>
    80002330:	4691                	li	a3,4
    80002332:	03448613          	addi	a2,s1,52
    80002336:	85e2                	mv	a1,s8
    80002338:	05093503          	ld	a0,80(s2)
    8000233c:	fffff097          	auipc	ra,0xfffff
    80002340:	38a080e7          	jalr	906(ra) # 800016c6 <copyout>
    80002344:	02054263          	bltz	a0,80002368 <wait+0x88>
          freeproc(np);
    80002348:	8526                	mv	a0,s1
    8000234a:	00000097          	auipc	ra,0x0
    8000234e:	8b2080e7          	jalr	-1870(ra) # 80001bfc <freeproc>
          release(&np->lock);
    80002352:	8526                	mv	a0,s1
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	984080e7          	jalr	-1660(ra) # 80000cd8 <release>
          release(&p->lock);
    8000235c:	854a                	mv	a0,s2
    8000235e:	fffff097          	auipc	ra,0xfffff
    80002362:	97a080e7          	jalr	-1670(ra) # 80000cd8 <release>
          return pid;
    80002366:	a8a9                	j	800023c0 <wait+0xe0>
            release(&np->lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	96e080e7          	jalr	-1682(ra) # 80000cd8 <release>
            release(&p->lock);
    80002372:	854a                	mv	a0,s2
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	964080e7          	jalr	-1692(ra) # 80000cd8 <release>
            return -1;
    8000237c:	59fd                	li	s3,-1
    8000237e:	a089                	j	800023c0 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002380:	16848493          	addi	s1,s1,360
    80002384:	03348463          	beq	s1,s3,800023ac <wait+0xcc>
      if(np->parent == p){
    80002388:	709c                	ld	a5,32(s1)
    8000238a:	ff279be3          	bne	a5,s2,80002380 <wait+0xa0>
        acquire(&np->lock);
    8000238e:	8526                	mv	a0,s1
    80002390:	fffff097          	auipc	ra,0xfffff
    80002394:	894080e7          	jalr	-1900(ra) # 80000c24 <acquire>
        if(np->state == ZOMBIE){
    80002398:	4c9c                	lw	a5,24(s1)
    8000239a:	f94787e3          	beq	a5,s4,80002328 <wait+0x48>
        release(&np->lock);
    8000239e:	8526                	mv	a0,s1
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	938080e7          	jalr	-1736(ra) # 80000cd8 <release>
        havekids = 1;
    800023a8:	8756                	mv	a4,s5
    800023aa:	bfd9                	j	80002380 <wait+0xa0>
    if(!havekids || p->killed){
    800023ac:	c701                	beqz	a4,800023b4 <wait+0xd4>
    800023ae:	03092783          	lw	a5,48(s2)
    800023b2:	c785                	beqz	a5,800023da <wait+0xfa>
      release(&p->lock);
    800023b4:	854a                	mv	a0,s2
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	922080e7          	jalr	-1758(ra) # 80000cd8 <release>
      return -1;
    800023be:	59fd                	li	s3,-1
}
    800023c0:	854e                	mv	a0,s3
    800023c2:	60a6                	ld	ra,72(sp)
    800023c4:	6406                	ld	s0,64(sp)
    800023c6:	74e2                	ld	s1,56(sp)
    800023c8:	7942                	ld	s2,48(sp)
    800023ca:	79a2                	ld	s3,40(sp)
    800023cc:	7a02                	ld	s4,32(sp)
    800023ce:	6ae2                	ld	s5,24(sp)
    800023d0:	6b42                	ld	s6,16(sp)
    800023d2:	6ba2                	ld	s7,8(sp)
    800023d4:	6c02                	ld	s8,0(sp)
    800023d6:	6161                	addi	sp,sp,80
    800023d8:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800023da:	85de                	mv	a1,s7
    800023dc:	854a                	mv	a0,s2
    800023de:	00000097          	auipc	ra,0x0
    800023e2:	e84080e7          	jalr	-380(ra) # 80002262 <sleep>
    havekids = 0;
    800023e6:	bf1d                	j	8000231c <wait+0x3c>

00000000800023e8 <wakeup>:
{
    800023e8:	7139                	addi	sp,sp,-64
    800023ea:	fc06                	sd	ra,56(sp)
    800023ec:	f822                	sd	s0,48(sp)
    800023ee:	f426                	sd	s1,40(sp)
    800023f0:	f04a                	sd	s2,32(sp)
    800023f2:	ec4e                	sd	s3,24(sp)
    800023f4:	e852                	sd	s4,16(sp)
    800023f6:	e456                	sd	s5,8(sp)
    800023f8:	0080                	addi	s0,sp,64
    800023fa:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800023fc:	0000f497          	auipc	s1,0xf
    80002400:	2bc48493          	addi	s1,s1,700 # 800116b8 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002404:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002406:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002408:	00010917          	auipc	s2,0x10
    8000240c:	0c090913          	addi	s2,s2,192 # 800124c8 <tickslock>
    80002410:	a821                	j	80002428 <wakeup+0x40>
      p->state = RUNNABLE;
    80002412:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    80002416:	8526                	mv	a0,s1
    80002418:	fffff097          	auipc	ra,0xfffff
    8000241c:	8c0080e7          	jalr	-1856(ra) # 80000cd8 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002420:	16848493          	addi	s1,s1,360
    80002424:	01248e63          	beq	s1,s2,80002440 <wakeup+0x58>
    acquire(&p->lock);
    80002428:	8526                	mv	a0,s1
    8000242a:	ffffe097          	auipc	ra,0xffffe
    8000242e:	7fa080e7          	jalr	2042(ra) # 80000c24 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002432:	4c9c                	lw	a5,24(s1)
    80002434:	ff3791e3          	bne	a5,s3,80002416 <wakeup+0x2e>
    80002438:	749c                	ld	a5,40(s1)
    8000243a:	fd479ee3          	bne	a5,s4,80002416 <wakeup+0x2e>
    8000243e:	bfd1                	j	80002412 <wakeup+0x2a>
}
    80002440:	70e2                	ld	ra,56(sp)
    80002442:	7442                	ld	s0,48(sp)
    80002444:	74a2                	ld	s1,40(sp)
    80002446:	7902                	ld	s2,32(sp)
    80002448:	69e2                	ld	s3,24(sp)
    8000244a:	6a42                	ld	s4,16(sp)
    8000244c:	6aa2                	ld	s5,8(sp)
    8000244e:	6121                	addi	sp,sp,64
    80002450:	8082                	ret

0000000080002452 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002452:	7179                	addi	sp,sp,-48
    80002454:	f406                	sd	ra,40(sp)
    80002456:	f022                	sd	s0,32(sp)
    80002458:	ec26                	sd	s1,24(sp)
    8000245a:	e84a                	sd	s2,16(sp)
    8000245c:	e44e                	sd	s3,8(sp)
    8000245e:	1800                	addi	s0,sp,48
    80002460:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002462:	0000f497          	auipc	s1,0xf
    80002466:	25648493          	addi	s1,s1,598 # 800116b8 <proc>
    8000246a:	00010997          	auipc	s3,0x10
    8000246e:	05e98993          	addi	s3,s3,94 # 800124c8 <tickslock>
    acquire(&p->lock);
    80002472:	8526                	mv	a0,s1
    80002474:	ffffe097          	auipc	ra,0xffffe
    80002478:	7b0080e7          	jalr	1968(ra) # 80000c24 <acquire>
    if(p->pid == pid){
    8000247c:	5c9c                	lw	a5,56(s1)
    8000247e:	03278363          	beq	a5,s2,800024a4 <kill+0x52>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002482:	8526                	mv	a0,s1
    80002484:	fffff097          	auipc	ra,0xfffff
    80002488:	854080e7          	jalr	-1964(ra) # 80000cd8 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000248c:	16848493          	addi	s1,s1,360
    80002490:	ff3491e3          	bne	s1,s3,80002472 <kill+0x20>
  }
  return -1;
    80002494:	557d                	li	a0,-1
}
    80002496:	70a2                	ld	ra,40(sp)
    80002498:	7402                	ld	s0,32(sp)
    8000249a:	64e2                	ld	s1,24(sp)
    8000249c:	6942                	ld	s2,16(sp)
    8000249e:	69a2                	ld	s3,8(sp)
    800024a0:	6145                	addi	sp,sp,48
    800024a2:	8082                	ret
      p->killed = 1;
    800024a4:	4785                	li	a5,1
    800024a6:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800024a8:	4c98                	lw	a4,24(s1)
    800024aa:	4785                	li	a5,1
    800024ac:	00f70963          	beq	a4,a5,800024be <kill+0x6c>
      release(&p->lock);
    800024b0:	8526                	mv	a0,s1
    800024b2:	fffff097          	auipc	ra,0xfffff
    800024b6:	826080e7          	jalr	-2010(ra) # 80000cd8 <release>
      return 0;
    800024ba:	4501                	li	a0,0
    800024bc:	bfe9                	j	80002496 <kill+0x44>
        p->state = RUNNABLE;
    800024be:	4789                	li	a5,2
    800024c0:	cc9c                	sw	a5,24(s1)
    800024c2:	b7fd                	j	800024b0 <kill+0x5e>

00000000800024c4 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024c4:	7179                	addi	sp,sp,-48
    800024c6:	f406                	sd	ra,40(sp)
    800024c8:	f022                	sd	s0,32(sp)
    800024ca:	ec26                	sd	s1,24(sp)
    800024cc:	e84a                	sd	s2,16(sp)
    800024ce:	e44e                	sd	s3,8(sp)
    800024d0:	e052                	sd	s4,0(sp)
    800024d2:	1800                	addi	s0,sp,48
    800024d4:	84aa                	mv	s1,a0
    800024d6:	892e                	mv	s2,a1
    800024d8:	89b2                	mv	s3,a2
    800024da:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024dc:	fffff097          	auipc	ra,0xfffff
    800024e0:	56c080e7          	jalr	1388(ra) # 80001a48 <myproc>
  if(user_dst){
    800024e4:	c08d                	beqz	s1,80002506 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024e6:	86d2                	mv	a3,s4
    800024e8:	864e                	mv	a2,s3
    800024ea:	85ca                	mv	a1,s2
    800024ec:	6928                	ld	a0,80(a0)
    800024ee:	fffff097          	auipc	ra,0xfffff
    800024f2:	1d8080e7          	jalr	472(ra) # 800016c6 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024f6:	70a2                	ld	ra,40(sp)
    800024f8:	7402                	ld	s0,32(sp)
    800024fa:	64e2                	ld	s1,24(sp)
    800024fc:	6942                	ld	s2,16(sp)
    800024fe:	69a2                	ld	s3,8(sp)
    80002500:	6a02                	ld	s4,0(sp)
    80002502:	6145                	addi	sp,sp,48
    80002504:	8082                	ret
    memmove((char *)dst, src, len);
    80002506:	000a061b          	sext.w	a2,s4
    8000250a:	85ce                	mv	a1,s3
    8000250c:	854a                	mv	a0,s2
    8000250e:	fffff097          	auipc	ra,0xfffff
    80002512:	87e080e7          	jalr	-1922(ra) # 80000d8c <memmove>
    return 0;
    80002516:	8526                	mv	a0,s1
    80002518:	bff9                	j	800024f6 <either_copyout+0x32>

000000008000251a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000251a:	7179                	addi	sp,sp,-48
    8000251c:	f406                	sd	ra,40(sp)
    8000251e:	f022                	sd	s0,32(sp)
    80002520:	ec26                	sd	s1,24(sp)
    80002522:	e84a                	sd	s2,16(sp)
    80002524:	e44e                	sd	s3,8(sp)
    80002526:	e052                	sd	s4,0(sp)
    80002528:	1800                	addi	s0,sp,48
    8000252a:	892a                	mv	s2,a0
    8000252c:	84ae                	mv	s1,a1
    8000252e:	89b2                	mv	s3,a2
    80002530:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002532:	fffff097          	auipc	ra,0xfffff
    80002536:	516080e7          	jalr	1302(ra) # 80001a48 <myproc>
  if(user_src){
    8000253a:	c08d                	beqz	s1,8000255c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000253c:	86d2                	mv	a3,s4
    8000253e:	864e                	mv	a2,s3
    80002540:	85ca                	mv	a1,s2
    80002542:	6928                	ld	a0,80(a0)
    80002544:	fffff097          	auipc	ra,0xfffff
    80002548:	20e080e7          	jalr	526(ra) # 80001752 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000254c:	70a2                	ld	ra,40(sp)
    8000254e:	7402                	ld	s0,32(sp)
    80002550:	64e2                	ld	s1,24(sp)
    80002552:	6942                	ld	s2,16(sp)
    80002554:	69a2                	ld	s3,8(sp)
    80002556:	6a02                	ld	s4,0(sp)
    80002558:	6145                	addi	sp,sp,48
    8000255a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000255c:	000a061b          	sext.w	a2,s4
    80002560:	85ce                	mv	a1,s3
    80002562:	854a                	mv	a0,s2
    80002564:	fffff097          	auipc	ra,0xfffff
    80002568:	828080e7          	jalr	-2008(ra) # 80000d8c <memmove>
    return 0;
    8000256c:	8526                	mv	a0,s1
    8000256e:	bff9                	j	8000254c <either_copyin+0x32>

0000000080002570 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002570:	715d                	addi	sp,sp,-80
    80002572:	e486                	sd	ra,72(sp)
    80002574:	e0a2                	sd	s0,64(sp)
    80002576:	fc26                	sd	s1,56(sp)
    80002578:	f84a                	sd	s2,48(sp)
    8000257a:	f44e                	sd	s3,40(sp)
    8000257c:	f052                	sd	s4,32(sp)
    8000257e:	ec56                	sd	s5,24(sp)
    80002580:	e85a                	sd	s6,16(sp)
    80002582:	e45e                	sd	s7,8(sp)
    80002584:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002586:	00006517          	auipc	a0,0x6
    8000258a:	b4250513          	addi	a0,a0,-1214 # 800080c8 <digits+0xb0>
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	014080e7          	jalr	20(ra) # 800005a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002596:	0000f497          	auipc	s1,0xf
    8000259a:	27a48493          	addi	s1,s1,634 # 80011810 <proc+0x158>
    8000259e:	00010917          	auipc	s2,0x10
    800025a2:	08290913          	addi	s2,s2,130 # 80012620 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a6:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800025a8:	00006997          	auipc	s3,0x6
    800025ac:	ce098993          	addi	s3,s3,-800 # 80008288 <states.1730+0xc8>
    printf("%d %s %s", p->pid, state, p->name);
    800025b0:	00006a97          	auipc	s5,0x6
    800025b4:	ce0a8a93          	addi	s5,s5,-800 # 80008290 <states.1730+0xd0>
    printf("\n");
    800025b8:	00006a17          	auipc	s4,0x6
    800025bc:	b10a0a13          	addi	s4,s4,-1264 # 800080c8 <digits+0xb0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025c0:	00006b97          	auipc	s7,0x6
    800025c4:	c00b8b93          	addi	s7,s7,-1024 # 800081c0 <states.1730>
    800025c8:	a015                	j	800025ec <procdump+0x7c>
    printf("%d %s %s", p->pid, state, p->name);
    800025ca:	86ba                	mv	a3,a4
    800025cc:	ee072583          	lw	a1,-288(a4)
    800025d0:	8556                	mv	a0,s5
    800025d2:	ffffe097          	auipc	ra,0xffffe
    800025d6:	fd0080e7          	jalr	-48(ra) # 800005a2 <printf>
    printf("\n");
    800025da:	8552                	mv	a0,s4
    800025dc:	ffffe097          	auipc	ra,0xffffe
    800025e0:	fc6080e7          	jalr	-58(ra) # 800005a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025e4:	16848493          	addi	s1,s1,360
    800025e8:	03248163          	beq	s1,s2,8000260a <procdump+0x9a>
    if(p->state == UNUSED)
    800025ec:	8726                	mv	a4,s1
    800025ee:	ec04a783          	lw	a5,-320(s1)
    800025f2:	dbed                	beqz	a5,800025e4 <procdump+0x74>
      state = "???";
    800025f4:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025f6:	fcfb6ae3          	bltu	s6,a5,800025ca <procdump+0x5a>
    800025fa:	1782                	slli	a5,a5,0x20
    800025fc:	9381                	srli	a5,a5,0x20
    800025fe:	078e                	slli	a5,a5,0x3
    80002600:	97de                	add	a5,a5,s7
    80002602:	6390                	ld	a2,0(a5)
    80002604:	f279                	bnez	a2,800025ca <procdump+0x5a>
      state = "???";
    80002606:	864e                	mv	a2,s3
    80002608:	b7c9                	j	800025ca <procdump+0x5a>
  }
}
    8000260a:	60a6                	ld	ra,72(sp)
    8000260c:	6406                	ld	s0,64(sp)
    8000260e:	74e2                	ld	s1,56(sp)
    80002610:	7942                	ld	s2,48(sp)
    80002612:	79a2                	ld	s3,40(sp)
    80002614:	7a02                	ld	s4,32(sp)
    80002616:	6ae2                	ld	s5,24(sp)
    80002618:	6b42                	ld	s6,16(sp)
    8000261a:	6ba2                	ld	s7,8(sp)
    8000261c:	6161                	addi	sp,sp,80
    8000261e:	8082                	ret

0000000080002620 <swtch>:
    80002620:	00153023          	sd	ra,0(a0)
    80002624:	00253423          	sd	sp,8(a0)
    80002628:	e900                	sd	s0,16(a0)
    8000262a:	ed04                	sd	s1,24(a0)
    8000262c:	03253023          	sd	s2,32(a0)
    80002630:	03353423          	sd	s3,40(a0)
    80002634:	03453823          	sd	s4,48(a0)
    80002638:	03553c23          	sd	s5,56(a0)
    8000263c:	05653023          	sd	s6,64(a0)
    80002640:	05753423          	sd	s7,72(a0)
    80002644:	05853823          	sd	s8,80(a0)
    80002648:	05953c23          	sd	s9,88(a0)
    8000264c:	07a53023          	sd	s10,96(a0)
    80002650:	07b53423          	sd	s11,104(a0)
    80002654:	0005b083          	ld	ra,0(a1)
    80002658:	0085b103          	ld	sp,8(a1)
    8000265c:	6980                	ld	s0,16(a1)
    8000265e:	6d84                	ld	s1,24(a1)
    80002660:	0205b903          	ld	s2,32(a1)
    80002664:	0285b983          	ld	s3,40(a1)
    80002668:	0305ba03          	ld	s4,48(a1)
    8000266c:	0385ba83          	ld	s5,56(a1)
    80002670:	0405bb03          	ld	s6,64(a1)
    80002674:	0485bb83          	ld	s7,72(a1)
    80002678:	0505bc03          	ld	s8,80(a1)
    8000267c:	0585bc83          	ld	s9,88(a1)
    80002680:	0605bd03          	ld	s10,96(a1)
    80002684:	0685bd83          	ld	s11,104(a1)
    80002688:	8082                	ret

000000008000268a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000268a:	1141                	addi	sp,sp,-16
    8000268c:	e406                	sd	ra,8(sp)
    8000268e:	e022                	sd	s0,0(sp)
    80002690:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002692:	00006597          	auipc	a1,0x6
    80002696:	c3658593          	addi	a1,a1,-970 # 800082c8 <states.1730+0x108>
    8000269a:	00010517          	auipc	a0,0x10
    8000269e:	e2e50513          	addi	a0,a0,-466 # 800124c8 <tickslock>
    800026a2:	ffffe097          	auipc	ra,0xffffe
    800026a6:	4f2080e7          	jalr	1266(ra) # 80000b94 <initlock>
}
    800026aa:	60a2                	ld	ra,8(sp)
    800026ac:	6402                	ld	s0,0(sp)
    800026ae:	0141                	addi	sp,sp,16
    800026b0:	8082                	ret

00000000800026b2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026b2:	1141                	addi	sp,sp,-16
    800026b4:	e422                	sd	s0,8(sp)
    800026b6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026b8:	00004797          	auipc	a5,0x4
    800026bc:	87878793          	addi	a5,a5,-1928 # 80005f30 <kernelvec>
    800026c0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026c4:	6422                	ld	s0,8(sp)
    800026c6:	0141                	addi	sp,sp,16
    800026c8:	8082                	ret

00000000800026ca <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026ca:	1141                	addi	sp,sp,-16
    800026cc:	e406                	sd	ra,8(sp)
    800026ce:	e022                	sd	s0,0(sp)
    800026d0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026d2:	fffff097          	auipc	ra,0xfffff
    800026d6:	376080e7          	jalr	886(ra) # 80001a48 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026da:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026de:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026e0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800026e4:	00005617          	auipc	a2,0x5
    800026e8:	91c60613          	addi	a2,a2,-1764 # 80007000 <_trampoline>
    800026ec:	00005697          	auipc	a3,0x5
    800026f0:	91468693          	addi	a3,a3,-1772 # 80007000 <_trampoline>
    800026f4:	8e91                	sub	a3,a3,a2
    800026f6:	040007b7          	lui	a5,0x4000
    800026fa:	17fd                	addi	a5,a5,-1
    800026fc:	07b2                	slli	a5,a5,0xc
    800026fe:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002700:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002704:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002706:	180026f3          	csrr	a3,satp
    8000270a:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000270c:	6d38                	ld	a4,88(a0)
    8000270e:	6134                	ld	a3,64(a0)
    80002710:	6585                	lui	a1,0x1
    80002712:	96ae                	add	a3,a3,a1
    80002714:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002716:	6d38                	ld	a4,88(a0)
    80002718:	00000697          	auipc	a3,0x0
    8000271c:	13868693          	addi	a3,a3,312 # 80002850 <usertrap>
    80002720:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002722:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002724:	8692                	mv	a3,tp
    80002726:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002728:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000272c:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002730:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002734:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002738:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000273a:	6f18                	ld	a4,24(a4)
    8000273c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002740:	692c                	ld	a1,80(a0)
    80002742:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002744:	00005717          	auipc	a4,0x5
    80002748:	94c70713          	addi	a4,a4,-1716 # 80007090 <userret>
    8000274c:	8f11                	sub	a4,a4,a2
    8000274e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002750:	577d                	li	a4,-1
    80002752:	177e                	slli	a4,a4,0x3f
    80002754:	8dd9                	or	a1,a1,a4
    80002756:	02000537          	lui	a0,0x2000
    8000275a:	157d                	addi	a0,a0,-1
    8000275c:	0536                	slli	a0,a0,0xd
    8000275e:	9782                	jalr	a5
}
    80002760:	60a2                	ld	ra,8(sp)
    80002762:	6402                	ld	s0,0(sp)
    80002764:	0141                	addi	sp,sp,16
    80002766:	8082                	ret

0000000080002768 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002768:	1101                	addi	sp,sp,-32
    8000276a:	ec06                	sd	ra,24(sp)
    8000276c:	e822                	sd	s0,16(sp)
    8000276e:	e426                	sd	s1,8(sp)
    80002770:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002772:	00010497          	auipc	s1,0x10
    80002776:	d5648493          	addi	s1,s1,-682 # 800124c8 <tickslock>
    8000277a:	8526                	mv	a0,s1
    8000277c:	ffffe097          	auipc	ra,0xffffe
    80002780:	4a8080e7          	jalr	1192(ra) # 80000c24 <acquire>
  ticks++;
    80002784:	00007517          	auipc	a0,0x7
    80002788:	8ac50513          	addi	a0,a0,-1876 # 80009030 <ticks>
    8000278c:	411c                	lw	a5,0(a0)
    8000278e:	2785                	addiw	a5,a5,1
    80002790:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002792:	00000097          	auipc	ra,0x0
    80002796:	c56080e7          	jalr	-938(ra) # 800023e8 <wakeup>
  release(&tickslock);
    8000279a:	8526                	mv	a0,s1
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	53c080e7          	jalr	1340(ra) # 80000cd8 <release>
}
    800027a4:	60e2                	ld	ra,24(sp)
    800027a6:	6442                	ld	s0,16(sp)
    800027a8:	64a2                	ld	s1,8(sp)
    800027aa:	6105                	addi	sp,sp,32
    800027ac:	8082                	ret

00000000800027ae <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027ae:	1101                	addi	sp,sp,-32
    800027b0:	ec06                	sd	ra,24(sp)
    800027b2:	e822                	sd	s0,16(sp)
    800027b4:	e426                	sd	s1,8(sp)
    800027b6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027b8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027bc:	00074d63          	bltz	a4,800027d6 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027c0:	57fd                	li	a5,-1
    800027c2:	17fe                	slli	a5,a5,0x3f
    800027c4:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027c6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027c8:	06f70363          	beq	a4,a5,8000282e <devintr+0x80>
  }
}
    800027cc:	60e2                	ld	ra,24(sp)
    800027ce:	6442                	ld	s0,16(sp)
    800027d0:	64a2                	ld	s1,8(sp)
    800027d2:	6105                	addi	sp,sp,32
    800027d4:	8082                	ret
     (scause & 0xff) == 9){
    800027d6:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800027da:	46a5                	li	a3,9
    800027dc:	fed792e3          	bne	a5,a3,800027c0 <devintr+0x12>
    int irq = plic_claim();
    800027e0:	00004097          	auipc	ra,0x4
    800027e4:	858080e7          	jalr	-1960(ra) # 80006038 <plic_claim>
    800027e8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027ea:	47a9                	li	a5,10
    800027ec:	02f50763          	beq	a0,a5,8000281a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800027f0:	4785                	li	a5,1
    800027f2:	02f50963          	beq	a0,a5,80002824 <devintr+0x76>
    return 1;
    800027f6:	4505                	li	a0,1
    } else if(irq){
    800027f8:	d8f1                	beqz	s1,800027cc <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800027fa:	85a6                	mv	a1,s1
    800027fc:	00006517          	auipc	a0,0x6
    80002800:	ad450513          	addi	a0,a0,-1324 # 800082d0 <states.1730+0x110>
    80002804:	ffffe097          	auipc	ra,0xffffe
    80002808:	d9e080e7          	jalr	-610(ra) # 800005a2 <printf>
      plic_complete(irq);
    8000280c:	8526                	mv	a0,s1
    8000280e:	00004097          	auipc	ra,0x4
    80002812:	84e080e7          	jalr	-1970(ra) # 8000605c <plic_complete>
    return 1;
    80002816:	4505                	li	a0,1
    80002818:	bf55                	j	800027cc <devintr+0x1e>
      uartintr();
    8000281a:	ffffe097          	auipc	ra,0xffffe
    8000281e:	1ca080e7          	jalr	458(ra) # 800009e4 <uartintr>
    80002822:	b7ed                	j	8000280c <devintr+0x5e>
      virtio_disk_intr();
    80002824:	00004097          	auipc	ra,0x4
    80002828:	d36080e7          	jalr	-714(ra) # 8000655a <virtio_disk_intr>
    8000282c:	b7c5                	j	8000280c <devintr+0x5e>
    if(cpuid() == 0){
    8000282e:	fffff097          	auipc	ra,0xfffff
    80002832:	1ee080e7          	jalr	494(ra) # 80001a1c <cpuid>
    80002836:	c901                	beqz	a0,80002846 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002838:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000283c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000283e:	14479073          	csrw	sip,a5
    return 2;
    80002842:	4509                	li	a0,2
    80002844:	b761                	j	800027cc <devintr+0x1e>
      clockintr();
    80002846:	00000097          	auipc	ra,0x0
    8000284a:	f22080e7          	jalr	-222(ra) # 80002768 <clockintr>
    8000284e:	b7ed                	j	80002838 <devintr+0x8a>

0000000080002850 <usertrap>:
{
    80002850:	1101                	addi	sp,sp,-32
    80002852:	ec06                	sd	ra,24(sp)
    80002854:	e822                	sd	s0,16(sp)
    80002856:	e426                	sd	s1,8(sp)
    80002858:	e04a                	sd	s2,0(sp)
    8000285a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000285c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002860:	1007f793          	andi	a5,a5,256
    80002864:	e3ad                	bnez	a5,800028c6 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002866:	00003797          	auipc	a5,0x3
    8000286a:	6ca78793          	addi	a5,a5,1738 # 80005f30 <kernelvec>
    8000286e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002872:	fffff097          	auipc	ra,0xfffff
    80002876:	1d6080e7          	jalr	470(ra) # 80001a48 <myproc>
    8000287a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000287c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000287e:	14102773          	csrr	a4,sepc
    80002882:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002884:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002888:	47a1                	li	a5,8
    8000288a:	04f71c63          	bne	a4,a5,800028e2 <usertrap+0x92>
    if(p->killed)
    8000288e:	591c                	lw	a5,48(a0)
    80002890:	e3b9                	bnez	a5,800028d6 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002892:	6cb8                	ld	a4,88(s1)
    80002894:	6f1c                	ld	a5,24(a4)
    80002896:	0791                	addi	a5,a5,4
    80002898:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000289a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000289e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028a2:	10079073          	csrw	sstatus,a5
    syscall();
    800028a6:	00000097          	auipc	ra,0x0
    800028aa:	2e6080e7          	jalr	742(ra) # 80002b8c <syscall>
  if(p->killed)
    800028ae:	589c                	lw	a5,48(s1)
    800028b0:	ebc1                	bnez	a5,80002940 <usertrap+0xf0>
  usertrapret();
    800028b2:	00000097          	auipc	ra,0x0
    800028b6:	e18080e7          	jalr	-488(ra) # 800026ca <usertrapret>
}
    800028ba:	60e2                	ld	ra,24(sp)
    800028bc:	6442                	ld	s0,16(sp)
    800028be:	64a2                	ld	s1,8(sp)
    800028c0:	6902                	ld	s2,0(sp)
    800028c2:	6105                	addi	sp,sp,32
    800028c4:	8082                	ret
    panic("usertrap: not from user mode");
    800028c6:	00006517          	auipc	a0,0x6
    800028ca:	a2a50513          	addi	a0,a0,-1494 # 800082f0 <states.1730+0x130>
    800028ce:	ffffe097          	auipc	ra,0xffffe
    800028d2:	c8a080e7          	jalr	-886(ra) # 80000558 <panic>
      exit(-1);
    800028d6:	557d                	li	a0,-1
    800028d8:	00000097          	auipc	ra,0x0
    800028dc:	842080e7          	jalr	-1982(ra) # 8000211a <exit>
    800028e0:	bf4d                	j	80002892 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800028e2:	00000097          	auipc	ra,0x0
    800028e6:	ecc080e7          	jalr	-308(ra) # 800027ae <devintr>
    800028ea:	892a                	mv	s2,a0
    800028ec:	c501                	beqz	a0,800028f4 <usertrap+0xa4>
  if(p->killed)
    800028ee:	589c                	lw	a5,48(s1)
    800028f0:	c3a1                	beqz	a5,80002930 <usertrap+0xe0>
    800028f2:	a815                	j	80002926 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028f4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028f8:	5c90                	lw	a2,56(s1)
    800028fa:	00006517          	auipc	a0,0x6
    800028fe:	a1650513          	addi	a0,a0,-1514 # 80008310 <states.1730+0x150>
    80002902:	ffffe097          	auipc	ra,0xffffe
    80002906:	ca0080e7          	jalr	-864(ra) # 800005a2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000290a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000290e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002912:	00006517          	auipc	a0,0x6
    80002916:	a2e50513          	addi	a0,a0,-1490 # 80008340 <states.1730+0x180>
    8000291a:	ffffe097          	auipc	ra,0xffffe
    8000291e:	c88080e7          	jalr	-888(ra) # 800005a2 <printf>
    p->killed = 1;
    80002922:	4785                	li	a5,1
    80002924:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002926:	557d                	li	a0,-1
    80002928:	fffff097          	auipc	ra,0xfffff
    8000292c:	7f2080e7          	jalr	2034(ra) # 8000211a <exit>
  if(which_dev == 2)
    80002930:	4789                	li	a5,2
    80002932:	f8f910e3          	bne	s2,a5,800028b2 <usertrap+0x62>
    yield();
    80002936:	00000097          	auipc	ra,0x0
    8000293a:	8f0080e7          	jalr	-1808(ra) # 80002226 <yield>
    8000293e:	bf95                	j	800028b2 <usertrap+0x62>
  int which_dev = 0;
    80002940:	4901                	li	s2,0
    80002942:	b7d5                	j	80002926 <usertrap+0xd6>

0000000080002944 <kerneltrap>:
{
    80002944:	7179                	addi	sp,sp,-48
    80002946:	f406                	sd	ra,40(sp)
    80002948:	f022                	sd	s0,32(sp)
    8000294a:	ec26                	sd	s1,24(sp)
    8000294c:	e84a                	sd	s2,16(sp)
    8000294e:	e44e                	sd	s3,8(sp)
    80002950:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002952:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002956:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000295a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000295e:	1004f793          	andi	a5,s1,256
    80002962:	cb85                	beqz	a5,80002992 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002964:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002968:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000296a:	ef85                	bnez	a5,800029a2 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000296c:	00000097          	auipc	ra,0x0
    80002970:	e42080e7          	jalr	-446(ra) # 800027ae <devintr>
    80002974:	cd1d                	beqz	a0,800029b2 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002976:	4789                	li	a5,2
    80002978:	06f50a63          	beq	a0,a5,800029ec <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000297c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002980:	10049073          	csrw	sstatus,s1
}
    80002984:	70a2                	ld	ra,40(sp)
    80002986:	7402                	ld	s0,32(sp)
    80002988:	64e2                	ld	s1,24(sp)
    8000298a:	6942                	ld	s2,16(sp)
    8000298c:	69a2                	ld	s3,8(sp)
    8000298e:	6145                	addi	sp,sp,48
    80002990:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002992:	00006517          	auipc	a0,0x6
    80002996:	9ce50513          	addi	a0,a0,-1586 # 80008360 <states.1730+0x1a0>
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	bbe080e7          	jalr	-1090(ra) # 80000558 <panic>
    panic("kerneltrap: interrupts enabled");
    800029a2:	00006517          	auipc	a0,0x6
    800029a6:	9e650513          	addi	a0,a0,-1562 # 80008388 <states.1730+0x1c8>
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	bae080e7          	jalr	-1106(ra) # 80000558 <panic>
    printf("scause %p\n", scause);
    800029b2:	85ce                	mv	a1,s3
    800029b4:	00006517          	auipc	a0,0x6
    800029b8:	9f450513          	addi	a0,a0,-1548 # 800083a8 <states.1730+0x1e8>
    800029bc:	ffffe097          	auipc	ra,0xffffe
    800029c0:	be6080e7          	jalr	-1050(ra) # 800005a2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029c4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029c8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029cc:	00006517          	auipc	a0,0x6
    800029d0:	9ec50513          	addi	a0,a0,-1556 # 800083b8 <states.1730+0x1f8>
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	bce080e7          	jalr	-1074(ra) # 800005a2 <printf>
    panic("kerneltrap");
    800029dc:	00006517          	auipc	a0,0x6
    800029e0:	9f450513          	addi	a0,a0,-1548 # 800083d0 <states.1730+0x210>
    800029e4:	ffffe097          	auipc	ra,0xffffe
    800029e8:	b74080e7          	jalr	-1164(ra) # 80000558 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029ec:	fffff097          	auipc	ra,0xfffff
    800029f0:	05c080e7          	jalr	92(ra) # 80001a48 <myproc>
    800029f4:	d541                	beqz	a0,8000297c <kerneltrap+0x38>
    800029f6:	fffff097          	auipc	ra,0xfffff
    800029fa:	052080e7          	jalr	82(ra) # 80001a48 <myproc>
    800029fe:	4d18                	lw	a4,24(a0)
    80002a00:	478d                	li	a5,3
    80002a02:	f6f71de3          	bne	a4,a5,8000297c <kerneltrap+0x38>
    yield();
    80002a06:	00000097          	auipc	ra,0x0
    80002a0a:	820080e7          	jalr	-2016(ra) # 80002226 <yield>
    80002a0e:	b7bd                	j	8000297c <kerneltrap+0x38>

0000000080002a10 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a10:	1101                	addi	sp,sp,-32
    80002a12:	ec06                	sd	ra,24(sp)
    80002a14:	e822                	sd	s0,16(sp)
    80002a16:	e426                	sd	s1,8(sp)
    80002a18:	1000                	addi	s0,sp,32
    80002a1a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a1c:	fffff097          	auipc	ra,0xfffff
    80002a20:	02c080e7          	jalr	44(ra) # 80001a48 <myproc>
  switch (n) {
    80002a24:	4795                	li	a5,5
    80002a26:	0497e363          	bltu	a5,s1,80002a6c <argraw+0x5c>
    80002a2a:	1482                	slli	s1,s1,0x20
    80002a2c:	9081                	srli	s1,s1,0x20
    80002a2e:	048a                	slli	s1,s1,0x2
    80002a30:	00006717          	auipc	a4,0x6
    80002a34:	9b070713          	addi	a4,a4,-1616 # 800083e0 <states.1730+0x220>
    80002a38:	94ba                	add	s1,s1,a4
    80002a3a:	409c                	lw	a5,0(s1)
    80002a3c:	97ba                	add	a5,a5,a4
    80002a3e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a40:	6d3c                	ld	a5,88(a0)
    80002a42:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a44:	60e2                	ld	ra,24(sp)
    80002a46:	6442                	ld	s0,16(sp)
    80002a48:	64a2                	ld	s1,8(sp)
    80002a4a:	6105                	addi	sp,sp,32
    80002a4c:	8082                	ret
    return p->trapframe->a1;
    80002a4e:	6d3c                	ld	a5,88(a0)
    80002a50:	7fa8                	ld	a0,120(a5)
    80002a52:	bfcd                	j	80002a44 <argraw+0x34>
    return p->trapframe->a2;
    80002a54:	6d3c                	ld	a5,88(a0)
    80002a56:	63c8                	ld	a0,128(a5)
    80002a58:	b7f5                	j	80002a44 <argraw+0x34>
    return p->trapframe->a3;
    80002a5a:	6d3c                	ld	a5,88(a0)
    80002a5c:	67c8                	ld	a0,136(a5)
    80002a5e:	b7dd                	j	80002a44 <argraw+0x34>
    return p->trapframe->a4;
    80002a60:	6d3c                	ld	a5,88(a0)
    80002a62:	6bc8                	ld	a0,144(a5)
    80002a64:	b7c5                	j	80002a44 <argraw+0x34>
    return p->trapframe->a5;
    80002a66:	6d3c                	ld	a5,88(a0)
    80002a68:	6fc8                	ld	a0,152(a5)
    80002a6a:	bfe9                	j	80002a44 <argraw+0x34>
  panic("argraw");
    80002a6c:	00006517          	auipc	a0,0x6
    80002a70:	a4450513          	addi	a0,a0,-1468 # 800084b0 <syscalls+0xb8>
    80002a74:	ffffe097          	auipc	ra,0xffffe
    80002a78:	ae4080e7          	jalr	-1308(ra) # 80000558 <panic>

0000000080002a7c <fetchaddr>:
{
    80002a7c:	1101                	addi	sp,sp,-32
    80002a7e:	ec06                	sd	ra,24(sp)
    80002a80:	e822                	sd	s0,16(sp)
    80002a82:	e426                	sd	s1,8(sp)
    80002a84:	e04a                	sd	s2,0(sp)
    80002a86:	1000                	addi	s0,sp,32
    80002a88:	84aa                	mv	s1,a0
    80002a8a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a8c:	fffff097          	auipc	ra,0xfffff
    80002a90:	fbc080e7          	jalr	-68(ra) # 80001a48 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a94:	653c                	ld	a5,72(a0)
    80002a96:	02f4f963          	bleu	a5,s1,80002ac8 <fetchaddr+0x4c>
    80002a9a:	00848713          	addi	a4,s1,8
    80002a9e:	02e7e763          	bltu	a5,a4,80002acc <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002aa2:	46a1                	li	a3,8
    80002aa4:	8626                	mv	a2,s1
    80002aa6:	85ca                	mv	a1,s2
    80002aa8:	6928                	ld	a0,80(a0)
    80002aaa:	fffff097          	auipc	ra,0xfffff
    80002aae:	ca8080e7          	jalr	-856(ra) # 80001752 <copyin>
    80002ab2:	00a03533          	snez	a0,a0
    80002ab6:	40a0053b          	negw	a0,a0
    80002aba:	2501                	sext.w	a0,a0
}
    80002abc:	60e2                	ld	ra,24(sp)
    80002abe:	6442                	ld	s0,16(sp)
    80002ac0:	64a2                	ld	s1,8(sp)
    80002ac2:	6902                	ld	s2,0(sp)
    80002ac4:	6105                	addi	sp,sp,32
    80002ac6:	8082                	ret
    return -1;
    80002ac8:	557d                	li	a0,-1
    80002aca:	bfcd                	j	80002abc <fetchaddr+0x40>
    80002acc:	557d                	li	a0,-1
    80002ace:	b7fd                	j	80002abc <fetchaddr+0x40>

0000000080002ad0 <fetchstr>:
{
    80002ad0:	7179                	addi	sp,sp,-48
    80002ad2:	f406                	sd	ra,40(sp)
    80002ad4:	f022                	sd	s0,32(sp)
    80002ad6:	ec26                	sd	s1,24(sp)
    80002ad8:	e84a                	sd	s2,16(sp)
    80002ada:	e44e                	sd	s3,8(sp)
    80002adc:	1800                	addi	s0,sp,48
    80002ade:	892a                	mv	s2,a0
    80002ae0:	84ae                	mv	s1,a1
    80002ae2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ae4:	fffff097          	auipc	ra,0xfffff
    80002ae8:	f64080e7          	jalr	-156(ra) # 80001a48 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002aec:	86ce                	mv	a3,s3
    80002aee:	864a                	mv	a2,s2
    80002af0:	85a6                	mv	a1,s1
    80002af2:	6928                	ld	a0,80(a0)
    80002af4:	fffff097          	auipc	ra,0xfffff
    80002af8:	cec080e7          	jalr	-788(ra) # 800017e0 <copyinstr>
  if(err < 0)
    80002afc:	00054763          	bltz	a0,80002b0a <fetchstr+0x3a>
  return strlen(buf);
    80002b00:	8526                	mv	a0,s1
    80002b02:	ffffe097          	auipc	ra,0xffffe
    80002b06:	3c8080e7          	jalr	968(ra) # 80000eca <strlen>
}
    80002b0a:	70a2                	ld	ra,40(sp)
    80002b0c:	7402                	ld	s0,32(sp)
    80002b0e:	64e2                	ld	s1,24(sp)
    80002b10:	6942                	ld	s2,16(sp)
    80002b12:	69a2                	ld	s3,8(sp)
    80002b14:	6145                	addi	sp,sp,48
    80002b16:	8082                	ret

0000000080002b18 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b18:	1101                	addi	sp,sp,-32
    80002b1a:	ec06                	sd	ra,24(sp)
    80002b1c:	e822                	sd	s0,16(sp)
    80002b1e:	e426                	sd	s1,8(sp)
    80002b20:	1000                	addi	s0,sp,32
    80002b22:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b24:	00000097          	auipc	ra,0x0
    80002b28:	eec080e7          	jalr	-276(ra) # 80002a10 <argraw>
    80002b2c:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b2e:	4501                	li	a0,0
    80002b30:	60e2                	ld	ra,24(sp)
    80002b32:	6442                	ld	s0,16(sp)
    80002b34:	64a2                	ld	s1,8(sp)
    80002b36:	6105                	addi	sp,sp,32
    80002b38:	8082                	ret

0000000080002b3a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b3a:	1101                	addi	sp,sp,-32
    80002b3c:	ec06                	sd	ra,24(sp)
    80002b3e:	e822                	sd	s0,16(sp)
    80002b40:	e426                	sd	s1,8(sp)
    80002b42:	1000                	addi	s0,sp,32
    80002b44:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b46:	00000097          	auipc	ra,0x0
    80002b4a:	eca080e7          	jalr	-310(ra) # 80002a10 <argraw>
    80002b4e:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b50:	4501                	li	a0,0
    80002b52:	60e2                	ld	ra,24(sp)
    80002b54:	6442                	ld	s0,16(sp)
    80002b56:	64a2                	ld	s1,8(sp)
    80002b58:	6105                	addi	sp,sp,32
    80002b5a:	8082                	ret

0000000080002b5c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b5c:	1101                	addi	sp,sp,-32
    80002b5e:	ec06                	sd	ra,24(sp)
    80002b60:	e822                	sd	s0,16(sp)
    80002b62:	e426                	sd	s1,8(sp)
    80002b64:	e04a                	sd	s2,0(sp)
    80002b66:	1000                	addi	s0,sp,32
    80002b68:	84ae                	mv	s1,a1
    80002b6a:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b6c:	00000097          	auipc	ra,0x0
    80002b70:	ea4080e7          	jalr	-348(ra) # 80002a10 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b74:	864a                	mv	a2,s2
    80002b76:	85a6                	mv	a1,s1
    80002b78:	00000097          	auipc	ra,0x0
    80002b7c:	f58080e7          	jalr	-168(ra) # 80002ad0 <fetchstr>
}
    80002b80:	60e2                	ld	ra,24(sp)
    80002b82:	6442                	ld	s0,16(sp)
    80002b84:	64a2                	ld	s1,8(sp)
    80002b86:	6902                	ld	s2,0(sp)
    80002b88:	6105                	addi	sp,sp,32
    80002b8a:	8082                	ret

0000000080002b8c <syscall>:
[SYS_symlink] sys_symlink,
};

void
syscall(void)
{
    80002b8c:	1101                	addi	sp,sp,-32
    80002b8e:	ec06                	sd	ra,24(sp)
    80002b90:	e822                	sd	s0,16(sp)
    80002b92:	e426                	sd	s1,8(sp)
    80002b94:	e04a                	sd	s2,0(sp)
    80002b96:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b98:	fffff097          	auipc	ra,0xfffff
    80002b9c:	eb0080e7          	jalr	-336(ra) # 80001a48 <myproc>
    80002ba0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ba2:	05853903          	ld	s2,88(a0)
    80002ba6:	0a893783          	ld	a5,168(s2)
    80002baa:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002bae:	37fd                	addiw	a5,a5,-1
    80002bb0:	4755                	li	a4,21
    80002bb2:	00f76f63          	bltu	a4,a5,80002bd0 <syscall+0x44>
    80002bb6:	00369713          	slli	a4,a3,0x3
    80002bba:	00006797          	auipc	a5,0x6
    80002bbe:	83e78793          	addi	a5,a5,-1986 # 800083f8 <syscalls>
    80002bc2:	97ba                	add	a5,a5,a4
    80002bc4:	639c                	ld	a5,0(a5)
    80002bc6:	c789                	beqz	a5,80002bd0 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002bc8:	9782                	jalr	a5
    80002bca:	06a93823          	sd	a0,112(s2)
    80002bce:	a839                	j	80002bec <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bd0:	15848613          	addi	a2,s1,344
    80002bd4:	5c8c                	lw	a1,56(s1)
    80002bd6:	00006517          	auipc	a0,0x6
    80002bda:	8e250513          	addi	a0,a0,-1822 # 800084b8 <syscalls+0xc0>
    80002bde:	ffffe097          	auipc	ra,0xffffe
    80002be2:	9c4080e7          	jalr	-1596(ra) # 800005a2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002be6:	6cbc                	ld	a5,88(s1)
    80002be8:	577d                	li	a4,-1
    80002bea:	fbb8                	sd	a4,112(a5)
  }
}
    80002bec:	60e2                	ld	ra,24(sp)
    80002bee:	6442                	ld	s0,16(sp)
    80002bf0:	64a2                	ld	s1,8(sp)
    80002bf2:	6902                	ld	s2,0(sp)
    80002bf4:	6105                	addi	sp,sp,32
    80002bf6:	8082                	ret

0000000080002bf8 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002bf8:	1101                	addi	sp,sp,-32
    80002bfa:	ec06                	sd	ra,24(sp)
    80002bfc:	e822                	sd	s0,16(sp)
    80002bfe:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002c00:	fec40593          	addi	a1,s0,-20
    80002c04:	4501                	li	a0,0
    80002c06:	00000097          	auipc	ra,0x0
    80002c0a:	f12080e7          	jalr	-238(ra) # 80002b18 <argint>
    return -1;
    80002c0e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c10:	00054963          	bltz	a0,80002c22 <sys_exit+0x2a>
  exit(n);
    80002c14:	fec42503          	lw	a0,-20(s0)
    80002c18:	fffff097          	auipc	ra,0xfffff
    80002c1c:	502080e7          	jalr	1282(ra) # 8000211a <exit>
  return 0;  // not reached
    80002c20:	4781                	li	a5,0
}
    80002c22:	853e                	mv	a0,a5
    80002c24:	60e2                	ld	ra,24(sp)
    80002c26:	6442                	ld	s0,16(sp)
    80002c28:	6105                	addi	sp,sp,32
    80002c2a:	8082                	ret

0000000080002c2c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c2c:	1141                	addi	sp,sp,-16
    80002c2e:	e406                	sd	ra,8(sp)
    80002c30:	e022                	sd	s0,0(sp)
    80002c32:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c34:	fffff097          	auipc	ra,0xfffff
    80002c38:	e14080e7          	jalr	-492(ra) # 80001a48 <myproc>
}
    80002c3c:	5d08                	lw	a0,56(a0)
    80002c3e:	60a2                	ld	ra,8(sp)
    80002c40:	6402                	ld	s0,0(sp)
    80002c42:	0141                	addi	sp,sp,16
    80002c44:	8082                	ret

0000000080002c46 <sys_fork>:

uint64
sys_fork(void)
{
    80002c46:	1141                	addi	sp,sp,-16
    80002c48:	e406                	sd	ra,8(sp)
    80002c4a:	e022                	sd	s0,0(sp)
    80002c4c:	0800                	addi	s0,sp,16
  return fork();
    80002c4e:	fffff097          	auipc	ra,0xfffff
    80002c52:	1c0080e7          	jalr	448(ra) # 80001e0e <fork>
}
    80002c56:	60a2                	ld	ra,8(sp)
    80002c58:	6402                	ld	s0,0(sp)
    80002c5a:	0141                	addi	sp,sp,16
    80002c5c:	8082                	ret

0000000080002c5e <sys_wait>:

uint64
sys_wait(void)
{
    80002c5e:	1101                	addi	sp,sp,-32
    80002c60:	ec06                	sd	ra,24(sp)
    80002c62:	e822                	sd	s0,16(sp)
    80002c64:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c66:	fe840593          	addi	a1,s0,-24
    80002c6a:	4501                	li	a0,0
    80002c6c:	00000097          	auipc	ra,0x0
    80002c70:	ece080e7          	jalr	-306(ra) # 80002b3a <argaddr>
    return -1;
    80002c74:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    80002c76:	00054963          	bltz	a0,80002c88 <sys_wait+0x2a>
  return wait(p);
    80002c7a:	fe843503          	ld	a0,-24(s0)
    80002c7e:	fffff097          	auipc	ra,0xfffff
    80002c82:	662080e7          	jalr	1634(ra) # 800022e0 <wait>
    80002c86:	87aa                	mv	a5,a0
}
    80002c88:	853e                	mv	a0,a5
    80002c8a:	60e2                	ld	ra,24(sp)
    80002c8c:	6442                	ld	s0,16(sp)
    80002c8e:	6105                	addi	sp,sp,32
    80002c90:	8082                	ret

0000000080002c92 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c92:	7179                	addi	sp,sp,-48
    80002c94:	f406                	sd	ra,40(sp)
    80002c96:	f022                	sd	s0,32(sp)
    80002c98:	ec26                	sd	s1,24(sp)
    80002c9a:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002c9c:	fdc40593          	addi	a1,s0,-36
    80002ca0:	4501                	li	a0,0
    80002ca2:	00000097          	auipc	ra,0x0
    80002ca6:	e76080e7          	jalr	-394(ra) # 80002b18 <argint>
    return -1;
    80002caa:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002cac:	00054f63          	bltz	a0,80002cca <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002cb0:	fffff097          	auipc	ra,0xfffff
    80002cb4:	d98080e7          	jalr	-616(ra) # 80001a48 <myproc>
    80002cb8:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002cba:	fdc42503          	lw	a0,-36(s0)
    80002cbe:	fffff097          	auipc	ra,0xfffff
    80002cc2:	0d8080e7          	jalr	216(ra) # 80001d96 <growproc>
    80002cc6:	00054863          	bltz	a0,80002cd6 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002cca:	8526                	mv	a0,s1
    80002ccc:	70a2                	ld	ra,40(sp)
    80002cce:	7402                	ld	s0,32(sp)
    80002cd0:	64e2                	ld	s1,24(sp)
    80002cd2:	6145                	addi	sp,sp,48
    80002cd4:	8082                	ret
    return -1;
    80002cd6:	54fd                	li	s1,-1
    80002cd8:	bfcd                	j	80002cca <sys_sbrk+0x38>

0000000080002cda <sys_sleep>:

uint64
sys_sleep(void)
{
    80002cda:	7139                	addi	sp,sp,-64
    80002cdc:	fc06                	sd	ra,56(sp)
    80002cde:	f822                	sd	s0,48(sp)
    80002ce0:	f426                	sd	s1,40(sp)
    80002ce2:	f04a                	sd	s2,32(sp)
    80002ce4:	ec4e                	sd	s3,24(sp)
    80002ce6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002ce8:	fcc40593          	addi	a1,s0,-52
    80002cec:	4501                	li	a0,0
    80002cee:	00000097          	auipc	ra,0x0
    80002cf2:	e2a080e7          	jalr	-470(ra) # 80002b18 <argint>
    return -1;
    80002cf6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002cf8:	06054763          	bltz	a0,80002d66 <sys_sleep+0x8c>
  acquire(&tickslock);
    80002cfc:	0000f517          	auipc	a0,0xf
    80002d00:	7cc50513          	addi	a0,a0,1996 # 800124c8 <tickslock>
    80002d04:	ffffe097          	auipc	ra,0xffffe
    80002d08:	f20080e7          	jalr	-224(ra) # 80000c24 <acquire>
  ticks0 = ticks;
    80002d0c:	00006797          	auipc	a5,0x6
    80002d10:	32478793          	addi	a5,a5,804 # 80009030 <ticks>
    80002d14:	0007a903          	lw	s2,0(a5)
  while(ticks - ticks0 < n){
    80002d18:	fcc42783          	lw	a5,-52(s0)
    80002d1c:	cf85                	beqz	a5,80002d54 <sys_sleep+0x7a>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d1e:	0000f997          	auipc	s3,0xf
    80002d22:	7aa98993          	addi	s3,s3,1962 # 800124c8 <tickslock>
    80002d26:	00006497          	auipc	s1,0x6
    80002d2a:	30a48493          	addi	s1,s1,778 # 80009030 <ticks>
    if(myproc()->killed){
    80002d2e:	fffff097          	auipc	ra,0xfffff
    80002d32:	d1a080e7          	jalr	-742(ra) # 80001a48 <myproc>
    80002d36:	591c                	lw	a5,48(a0)
    80002d38:	ef9d                	bnez	a5,80002d76 <sys_sleep+0x9c>
    sleep(&ticks, &tickslock);
    80002d3a:	85ce                	mv	a1,s3
    80002d3c:	8526                	mv	a0,s1
    80002d3e:	fffff097          	auipc	ra,0xfffff
    80002d42:	524080e7          	jalr	1316(ra) # 80002262 <sleep>
  while(ticks - ticks0 < n){
    80002d46:	409c                	lw	a5,0(s1)
    80002d48:	412787bb          	subw	a5,a5,s2
    80002d4c:	fcc42703          	lw	a4,-52(s0)
    80002d50:	fce7efe3          	bltu	a5,a4,80002d2e <sys_sleep+0x54>
  }
  release(&tickslock);
    80002d54:	0000f517          	auipc	a0,0xf
    80002d58:	77450513          	addi	a0,a0,1908 # 800124c8 <tickslock>
    80002d5c:	ffffe097          	auipc	ra,0xffffe
    80002d60:	f7c080e7          	jalr	-132(ra) # 80000cd8 <release>
  return 0;
    80002d64:	4781                	li	a5,0
}
    80002d66:	853e                	mv	a0,a5
    80002d68:	70e2                	ld	ra,56(sp)
    80002d6a:	7442                	ld	s0,48(sp)
    80002d6c:	74a2                	ld	s1,40(sp)
    80002d6e:	7902                	ld	s2,32(sp)
    80002d70:	69e2                	ld	s3,24(sp)
    80002d72:	6121                	addi	sp,sp,64
    80002d74:	8082                	ret
      release(&tickslock);
    80002d76:	0000f517          	auipc	a0,0xf
    80002d7a:	75250513          	addi	a0,a0,1874 # 800124c8 <tickslock>
    80002d7e:	ffffe097          	auipc	ra,0xffffe
    80002d82:	f5a080e7          	jalr	-166(ra) # 80000cd8 <release>
      return -1;
    80002d86:	57fd                	li	a5,-1
    80002d88:	bff9                	j	80002d66 <sys_sleep+0x8c>

0000000080002d8a <sys_kill>:

uint64
sys_kill(void)
{
    80002d8a:	1101                	addi	sp,sp,-32
    80002d8c:	ec06                	sd	ra,24(sp)
    80002d8e:	e822                	sd	s0,16(sp)
    80002d90:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002d92:	fec40593          	addi	a1,s0,-20
    80002d96:	4501                	li	a0,0
    80002d98:	00000097          	auipc	ra,0x0
    80002d9c:	d80080e7          	jalr	-640(ra) # 80002b18 <argint>
    return -1;
    80002da0:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    80002da2:	00054963          	bltz	a0,80002db4 <sys_kill+0x2a>
  return kill(pid);
    80002da6:	fec42503          	lw	a0,-20(s0)
    80002daa:	fffff097          	auipc	ra,0xfffff
    80002dae:	6a8080e7          	jalr	1704(ra) # 80002452 <kill>
    80002db2:	87aa                	mv	a5,a0
}
    80002db4:	853e                	mv	a0,a5
    80002db6:	60e2                	ld	ra,24(sp)
    80002db8:	6442                	ld	s0,16(sp)
    80002dba:	6105                	addi	sp,sp,32
    80002dbc:	8082                	ret

0000000080002dbe <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002dbe:	1101                	addi	sp,sp,-32
    80002dc0:	ec06                	sd	ra,24(sp)
    80002dc2:	e822                	sd	s0,16(sp)
    80002dc4:	e426                	sd	s1,8(sp)
    80002dc6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002dc8:	0000f517          	auipc	a0,0xf
    80002dcc:	70050513          	addi	a0,a0,1792 # 800124c8 <tickslock>
    80002dd0:	ffffe097          	auipc	ra,0xffffe
    80002dd4:	e54080e7          	jalr	-428(ra) # 80000c24 <acquire>
  xticks = ticks;
    80002dd8:	00006797          	auipc	a5,0x6
    80002ddc:	25878793          	addi	a5,a5,600 # 80009030 <ticks>
    80002de0:	4384                	lw	s1,0(a5)
  release(&tickslock);
    80002de2:	0000f517          	auipc	a0,0xf
    80002de6:	6e650513          	addi	a0,a0,1766 # 800124c8 <tickslock>
    80002dea:	ffffe097          	auipc	ra,0xffffe
    80002dee:	eee080e7          	jalr	-274(ra) # 80000cd8 <release>
  return xticks;
}
    80002df2:	02049513          	slli	a0,s1,0x20
    80002df6:	9101                	srli	a0,a0,0x20
    80002df8:	60e2                	ld	ra,24(sp)
    80002dfa:	6442                	ld	s0,16(sp)
    80002dfc:	64a2                	ld	s1,8(sp)
    80002dfe:	6105                	addi	sp,sp,32
    80002e00:	8082                	ret

0000000080002e02 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e02:	7179                	addi	sp,sp,-48
    80002e04:	f406                	sd	ra,40(sp)
    80002e06:	f022                	sd	s0,32(sp)
    80002e08:	ec26                	sd	s1,24(sp)
    80002e0a:	e84a                	sd	s2,16(sp)
    80002e0c:	e44e                	sd	s3,8(sp)
    80002e0e:	e052                	sd	s4,0(sp)
    80002e10:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e12:	00005597          	auipc	a1,0x5
    80002e16:	6c658593          	addi	a1,a1,1734 # 800084d8 <syscalls+0xe0>
    80002e1a:	0000f517          	auipc	a0,0xf
    80002e1e:	6c650513          	addi	a0,a0,1734 # 800124e0 <bcache>
    80002e22:	ffffe097          	auipc	ra,0xffffe
    80002e26:	d72080e7          	jalr	-654(ra) # 80000b94 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e2a:	00017797          	auipc	a5,0x17
    80002e2e:	6b678793          	addi	a5,a5,1718 # 8001a4e0 <bcache+0x8000>
    80002e32:	00018717          	auipc	a4,0x18
    80002e36:	91670713          	addi	a4,a4,-1770 # 8001a748 <bcache+0x8268>
    80002e3a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e3e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e42:	0000f497          	auipc	s1,0xf
    80002e46:	6b648493          	addi	s1,s1,1718 # 800124f8 <bcache+0x18>
    b->next = bcache.head.next;
    80002e4a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e4c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e4e:	00005a17          	auipc	s4,0x5
    80002e52:	692a0a13          	addi	s4,s4,1682 # 800084e0 <syscalls+0xe8>
    b->next = bcache.head.next;
    80002e56:	2b893783          	ld	a5,696(s2)
    80002e5a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e5c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e60:	85d2                	mv	a1,s4
    80002e62:	01048513          	addi	a0,s1,16
    80002e66:	00001097          	auipc	ra,0x1
    80002e6a:	6a0080e7          	jalr	1696(ra) # 80004506 <initsleeplock>
    bcache.head.next->prev = b;
    80002e6e:	2b893783          	ld	a5,696(s2)
    80002e72:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e74:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e78:	45848493          	addi	s1,s1,1112
    80002e7c:	fd349de3          	bne	s1,s3,80002e56 <binit+0x54>
  }
}
    80002e80:	70a2                	ld	ra,40(sp)
    80002e82:	7402                	ld	s0,32(sp)
    80002e84:	64e2                	ld	s1,24(sp)
    80002e86:	6942                	ld	s2,16(sp)
    80002e88:	69a2                	ld	s3,8(sp)
    80002e8a:	6a02                	ld	s4,0(sp)
    80002e8c:	6145                	addi	sp,sp,48
    80002e8e:	8082                	ret

0000000080002e90 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e90:	7179                	addi	sp,sp,-48
    80002e92:	f406                	sd	ra,40(sp)
    80002e94:	f022                	sd	s0,32(sp)
    80002e96:	ec26                	sd	s1,24(sp)
    80002e98:	e84a                	sd	s2,16(sp)
    80002e9a:	e44e                	sd	s3,8(sp)
    80002e9c:	1800                	addi	s0,sp,48
    80002e9e:	89aa                	mv	s3,a0
    80002ea0:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002ea2:	0000f517          	auipc	a0,0xf
    80002ea6:	63e50513          	addi	a0,a0,1598 # 800124e0 <bcache>
    80002eaa:	ffffe097          	auipc	ra,0xffffe
    80002eae:	d7a080e7          	jalr	-646(ra) # 80000c24 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002eb2:	00017797          	auipc	a5,0x17
    80002eb6:	62e78793          	addi	a5,a5,1582 # 8001a4e0 <bcache+0x8000>
    80002eba:	2b87b483          	ld	s1,696(a5)
    80002ebe:	00018797          	auipc	a5,0x18
    80002ec2:	88a78793          	addi	a5,a5,-1910 # 8001a748 <bcache+0x8268>
    80002ec6:	02f48f63          	beq	s1,a5,80002f04 <bread+0x74>
    80002eca:	873e                	mv	a4,a5
    80002ecc:	a021                	j	80002ed4 <bread+0x44>
    80002ece:	68a4                	ld	s1,80(s1)
    80002ed0:	02e48a63          	beq	s1,a4,80002f04 <bread+0x74>
    if(b->dev == dev && b->blockno == blockno){
    80002ed4:	449c                	lw	a5,8(s1)
    80002ed6:	ff379ce3          	bne	a5,s3,80002ece <bread+0x3e>
    80002eda:	44dc                	lw	a5,12(s1)
    80002edc:	ff2799e3          	bne	a5,s2,80002ece <bread+0x3e>
      b->refcnt++;
    80002ee0:	40bc                	lw	a5,64(s1)
    80002ee2:	2785                	addiw	a5,a5,1
    80002ee4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ee6:	0000f517          	auipc	a0,0xf
    80002eea:	5fa50513          	addi	a0,a0,1530 # 800124e0 <bcache>
    80002eee:	ffffe097          	auipc	ra,0xffffe
    80002ef2:	dea080e7          	jalr	-534(ra) # 80000cd8 <release>
      acquiresleep(&b->lock);
    80002ef6:	01048513          	addi	a0,s1,16
    80002efa:	00001097          	auipc	ra,0x1
    80002efe:	646080e7          	jalr	1606(ra) # 80004540 <acquiresleep>
      return b;
    80002f02:	a8b1                	j	80002f5e <bread+0xce>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f04:	00017797          	auipc	a5,0x17
    80002f08:	5dc78793          	addi	a5,a5,1500 # 8001a4e0 <bcache+0x8000>
    80002f0c:	2b07b483          	ld	s1,688(a5)
    80002f10:	00018797          	auipc	a5,0x18
    80002f14:	83878793          	addi	a5,a5,-1992 # 8001a748 <bcache+0x8268>
    80002f18:	04f48d63          	beq	s1,a5,80002f72 <bread+0xe2>
    if(b->refcnt == 0) {
    80002f1c:	40bc                	lw	a5,64(s1)
    80002f1e:	cb91                	beqz	a5,80002f32 <bread+0xa2>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f20:	00018717          	auipc	a4,0x18
    80002f24:	82870713          	addi	a4,a4,-2008 # 8001a748 <bcache+0x8268>
    80002f28:	64a4                	ld	s1,72(s1)
    80002f2a:	04e48463          	beq	s1,a4,80002f72 <bread+0xe2>
    if(b->refcnt == 0) {
    80002f2e:	40bc                	lw	a5,64(s1)
    80002f30:	ffe5                	bnez	a5,80002f28 <bread+0x98>
      b->dev = dev;
    80002f32:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002f36:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002f3a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f3e:	4785                	li	a5,1
    80002f40:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f42:	0000f517          	auipc	a0,0xf
    80002f46:	59e50513          	addi	a0,a0,1438 # 800124e0 <bcache>
    80002f4a:	ffffe097          	auipc	ra,0xffffe
    80002f4e:	d8e080e7          	jalr	-626(ra) # 80000cd8 <release>
      acquiresleep(&b->lock);
    80002f52:	01048513          	addi	a0,s1,16
    80002f56:	00001097          	auipc	ra,0x1
    80002f5a:	5ea080e7          	jalr	1514(ra) # 80004540 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f5e:	409c                	lw	a5,0(s1)
    80002f60:	c38d                	beqz	a5,80002f82 <bread+0xf2>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f62:	8526                	mv	a0,s1
    80002f64:	70a2                	ld	ra,40(sp)
    80002f66:	7402                	ld	s0,32(sp)
    80002f68:	64e2                	ld	s1,24(sp)
    80002f6a:	6942                	ld	s2,16(sp)
    80002f6c:	69a2                	ld	s3,8(sp)
    80002f6e:	6145                	addi	sp,sp,48
    80002f70:	8082                	ret
  panic("bget: no buffers");
    80002f72:	00005517          	auipc	a0,0x5
    80002f76:	57650513          	addi	a0,a0,1398 # 800084e8 <syscalls+0xf0>
    80002f7a:	ffffd097          	auipc	ra,0xffffd
    80002f7e:	5de080e7          	jalr	1502(ra) # 80000558 <panic>
    virtio_disk_rw(b, 0);
    80002f82:	4581                	li	a1,0
    80002f84:	8526                	mv	a0,s1
    80002f86:	00003097          	auipc	ra,0x3
    80002f8a:	2e0080e7          	jalr	736(ra) # 80006266 <virtio_disk_rw>
    b->valid = 1;
    80002f8e:	4785                	li	a5,1
    80002f90:	c09c                	sw	a5,0(s1)
  return b;
    80002f92:	bfc1                	j	80002f62 <bread+0xd2>

0000000080002f94 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f94:	1101                	addi	sp,sp,-32
    80002f96:	ec06                	sd	ra,24(sp)
    80002f98:	e822                	sd	s0,16(sp)
    80002f9a:	e426                	sd	s1,8(sp)
    80002f9c:	1000                	addi	s0,sp,32
    80002f9e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fa0:	0541                	addi	a0,a0,16
    80002fa2:	00001097          	auipc	ra,0x1
    80002fa6:	638080e7          	jalr	1592(ra) # 800045da <holdingsleep>
    80002faa:	cd01                	beqz	a0,80002fc2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002fac:	4585                	li	a1,1
    80002fae:	8526                	mv	a0,s1
    80002fb0:	00003097          	auipc	ra,0x3
    80002fb4:	2b6080e7          	jalr	694(ra) # 80006266 <virtio_disk_rw>
}
    80002fb8:	60e2                	ld	ra,24(sp)
    80002fba:	6442                	ld	s0,16(sp)
    80002fbc:	64a2                	ld	s1,8(sp)
    80002fbe:	6105                	addi	sp,sp,32
    80002fc0:	8082                	ret
    panic("bwrite");
    80002fc2:	00005517          	auipc	a0,0x5
    80002fc6:	53e50513          	addi	a0,a0,1342 # 80008500 <syscalls+0x108>
    80002fca:	ffffd097          	auipc	ra,0xffffd
    80002fce:	58e080e7          	jalr	1422(ra) # 80000558 <panic>

0000000080002fd2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002fd2:	1101                	addi	sp,sp,-32
    80002fd4:	ec06                	sd	ra,24(sp)
    80002fd6:	e822                	sd	s0,16(sp)
    80002fd8:	e426                	sd	s1,8(sp)
    80002fda:	e04a                	sd	s2,0(sp)
    80002fdc:	1000                	addi	s0,sp,32
    80002fde:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fe0:	01050913          	addi	s2,a0,16
    80002fe4:	854a                	mv	a0,s2
    80002fe6:	00001097          	auipc	ra,0x1
    80002fea:	5f4080e7          	jalr	1524(ra) # 800045da <holdingsleep>
    80002fee:	c92d                	beqz	a0,80003060 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002ff0:	854a                	mv	a0,s2
    80002ff2:	00001097          	auipc	ra,0x1
    80002ff6:	5a4080e7          	jalr	1444(ra) # 80004596 <releasesleep>

  acquire(&bcache.lock);
    80002ffa:	0000f517          	auipc	a0,0xf
    80002ffe:	4e650513          	addi	a0,a0,1254 # 800124e0 <bcache>
    80003002:	ffffe097          	auipc	ra,0xffffe
    80003006:	c22080e7          	jalr	-990(ra) # 80000c24 <acquire>
  b->refcnt--;
    8000300a:	40bc                	lw	a5,64(s1)
    8000300c:	37fd                	addiw	a5,a5,-1
    8000300e:	0007871b          	sext.w	a4,a5
    80003012:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003014:	eb05                	bnez	a4,80003044 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003016:	68bc                	ld	a5,80(s1)
    80003018:	64b8                	ld	a4,72(s1)
    8000301a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000301c:	64bc                	ld	a5,72(s1)
    8000301e:	68b8                	ld	a4,80(s1)
    80003020:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003022:	00017797          	auipc	a5,0x17
    80003026:	4be78793          	addi	a5,a5,1214 # 8001a4e0 <bcache+0x8000>
    8000302a:	2b87b703          	ld	a4,696(a5)
    8000302e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003030:	00017717          	auipc	a4,0x17
    80003034:	71870713          	addi	a4,a4,1816 # 8001a748 <bcache+0x8268>
    80003038:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000303a:	2b87b703          	ld	a4,696(a5)
    8000303e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003040:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003044:	0000f517          	auipc	a0,0xf
    80003048:	49c50513          	addi	a0,a0,1180 # 800124e0 <bcache>
    8000304c:	ffffe097          	auipc	ra,0xffffe
    80003050:	c8c080e7          	jalr	-884(ra) # 80000cd8 <release>
}
    80003054:	60e2                	ld	ra,24(sp)
    80003056:	6442                	ld	s0,16(sp)
    80003058:	64a2                	ld	s1,8(sp)
    8000305a:	6902                	ld	s2,0(sp)
    8000305c:	6105                	addi	sp,sp,32
    8000305e:	8082                	ret
    panic("brelse");
    80003060:	00005517          	auipc	a0,0x5
    80003064:	4a850513          	addi	a0,a0,1192 # 80008508 <syscalls+0x110>
    80003068:	ffffd097          	auipc	ra,0xffffd
    8000306c:	4f0080e7          	jalr	1264(ra) # 80000558 <panic>

0000000080003070 <bpin>:

void
bpin(struct buf *b) {
    80003070:	1101                	addi	sp,sp,-32
    80003072:	ec06                	sd	ra,24(sp)
    80003074:	e822                	sd	s0,16(sp)
    80003076:	e426                	sd	s1,8(sp)
    80003078:	1000                	addi	s0,sp,32
    8000307a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000307c:	0000f517          	auipc	a0,0xf
    80003080:	46450513          	addi	a0,a0,1124 # 800124e0 <bcache>
    80003084:	ffffe097          	auipc	ra,0xffffe
    80003088:	ba0080e7          	jalr	-1120(ra) # 80000c24 <acquire>
  b->refcnt++;
    8000308c:	40bc                	lw	a5,64(s1)
    8000308e:	2785                	addiw	a5,a5,1
    80003090:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003092:	0000f517          	auipc	a0,0xf
    80003096:	44e50513          	addi	a0,a0,1102 # 800124e0 <bcache>
    8000309a:	ffffe097          	auipc	ra,0xffffe
    8000309e:	c3e080e7          	jalr	-962(ra) # 80000cd8 <release>
}
    800030a2:	60e2                	ld	ra,24(sp)
    800030a4:	6442                	ld	s0,16(sp)
    800030a6:	64a2                	ld	s1,8(sp)
    800030a8:	6105                	addi	sp,sp,32
    800030aa:	8082                	ret

00000000800030ac <bunpin>:

void
bunpin(struct buf *b) {
    800030ac:	1101                	addi	sp,sp,-32
    800030ae:	ec06                	sd	ra,24(sp)
    800030b0:	e822                	sd	s0,16(sp)
    800030b2:	e426                	sd	s1,8(sp)
    800030b4:	1000                	addi	s0,sp,32
    800030b6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030b8:	0000f517          	auipc	a0,0xf
    800030bc:	42850513          	addi	a0,a0,1064 # 800124e0 <bcache>
    800030c0:	ffffe097          	auipc	ra,0xffffe
    800030c4:	b64080e7          	jalr	-1180(ra) # 80000c24 <acquire>
  b->refcnt--;
    800030c8:	40bc                	lw	a5,64(s1)
    800030ca:	37fd                	addiw	a5,a5,-1
    800030cc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030ce:	0000f517          	auipc	a0,0xf
    800030d2:	41250513          	addi	a0,a0,1042 # 800124e0 <bcache>
    800030d6:	ffffe097          	auipc	ra,0xffffe
    800030da:	c02080e7          	jalr	-1022(ra) # 80000cd8 <release>
}
    800030de:	60e2                	ld	ra,24(sp)
    800030e0:	6442                	ld	s0,16(sp)
    800030e2:	64a2                	ld	s1,8(sp)
    800030e4:	6105                	addi	sp,sp,32
    800030e6:	8082                	ret

00000000800030e8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030e8:	1101                	addi	sp,sp,-32
    800030ea:	ec06                	sd	ra,24(sp)
    800030ec:	e822                	sd	s0,16(sp)
    800030ee:	e426                	sd	s1,8(sp)
    800030f0:	e04a                	sd	s2,0(sp)
    800030f2:	1000                	addi	s0,sp,32
    800030f4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030f6:	00d5d59b          	srliw	a1,a1,0xd
    800030fa:	00018797          	auipc	a5,0x18
    800030fe:	aa678793          	addi	a5,a5,-1370 # 8001aba0 <sb>
    80003102:	4fdc                	lw	a5,28(a5)
    80003104:	9dbd                	addw	a1,a1,a5
    80003106:	00000097          	auipc	ra,0x0
    8000310a:	d8a080e7          	jalr	-630(ra) # 80002e90 <bread>
  bi = b % BPB;
    8000310e:	2481                	sext.w	s1,s1
  m = 1 << (bi % 8);
    80003110:	0074f793          	andi	a5,s1,7
    80003114:	4705                	li	a4,1
    80003116:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    8000311a:	6789                	lui	a5,0x2
    8000311c:	17fd                	addi	a5,a5,-1
    8000311e:	8cfd                	and	s1,s1,a5
  if((bp->data[bi/8] & m) == 0)
    80003120:	41f4d79b          	sraiw	a5,s1,0x1f
    80003124:	01d7d79b          	srliw	a5,a5,0x1d
    80003128:	9fa5                	addw	a5,a5,s1
    8000312a:	4037d79b          	sraiw	a5,a5,0x3
    8000312e:	00f506b3          	add	a3,a0,a5
    80003132:	0586c683          	lbu	a3,88(a3)
    80003136:	00d77633          	and	a2,a4,a3
    8000313a:	c61d                	beqz	a2,80003168 <bfree+0x80>
    8000313c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000313e:	97aa                	add	a5,a5,a0
    80003140:	fff74713          	not	a4,a4
    80003144:	8f75                	and	a4,a4,a3
    80003146:	04e78c23          	sb	a4,88(a5) # 2058 <_entry-0x7fffdfa8>
  log_write(bp);
    8000314a:	00001097          	auipc	ra,0x1
    8000314e:	2b8080e7          	jalr	696(ra) # 80004402 <log_write>
  brelse(bp);
    80003152:	854a                	mv	a0,s2
    80003154:	00000097          	auipc	ra,0x0
    80003158:	e7e080e7          	jalr	-386(ra) # 80002fd2 <brelse>
}
    8000315c:	60e2                	ld	ra,24(sp)
    8000315e:	6442                	ld	s0,16(sp)
    80003160:	64a2                	ld	s1,8(sp)
    80003162:	6902                	ld	s2,0(sp)
    80003164:	6105                	addi	sp,sp,32
    80003166:	8082                	ret
    panic("freeing free block");
    80003168:	00005517          	auipc	a0,0x5
    8000316c:	3a850513          	addi	a0,a0,936 # 80008510 <syscalls+0x118>
    80003170:	ffffd097          	auipc	ra,0xffffd
    80003174:	3e8080e7          	jalr	1000(ra) # 80000558 <panic>

0000000080003178 <balloc>:
{
    80003178:	711d                	addi	sp,sp,-96
    8000317a:	ec86                	sd	ra,88(sp)
    8000317c:	e8a2                	sd	s0,80(sp)
    8000317e:	e4a6                	sd	s1,72(sp)
    80003180:	e0ca                	sd	s2,64(sp)
    80003182:	fc4e                	sd	s3,56(sp)
    80003184:	f852                	sd	s4,48(sp)
    80003186:	f456                	sd	s5,40(sp)
    80003188:	f05a                	sd	s6,32(sp)
    8000318a:	ec5e                	sd	s7,24(sp)
    8000318c:	e862                	sd	s8,16(sp)
    8000318e:	e466                	sd	s9,8(sp)
    80003190:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003192:	00018797          	auipc	a5,0x18
    80003196:	a0e78793          	addi	a5,a5,-1522 # 8001aba0 <sb>
    8000319a:	43dc                	lw	a5,4(a5)
    8000319c:	10078e63          	beqz	a5,800032b8 <balloc+0x140>
    800031a0:	8baa                	mv	s7,a0
    800031a2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031a4:	00018b17          	auipc	s6,0x18
    800031a8:	9fcb0b13          	addi	s6,s6,-1540 # 8001aba0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031ac:	4c05                	li	s8,1
      m = 1 << (bi % 8);
    800031ae:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031b0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031b2:	6c89                	lui	s9,0x2
    800031b4:	a079                	j	80003242 <balloc+0xca>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031b6:	8942                	mv	s2,a6
      m = 1 << (bi % 8);
    800031b8:	4705                	li	a4,1
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031ba:	4681                	li	a3,0
        bp->data[bi/8] |= m;  // Mark block in use.
    800031bc:	96a6                	add	a3,a3,s1
    800031be:	8f51                	or	a4,a4,a2
    800031c0:	04e68c23          	sb	a4,88(a3)
        log_write(bp);
    800031c4:	8526                	mv	a0,s1
    800031c6:	00001097          	auipc	ra,0x1
    800031ca:	23c080e7          	jalr	572(ra) # 80004402 <log_write>
        brelse(bp);
    800031ce:	8526                	mv	a0,s1
    800031d0:	00000097          	auipc	ra,0x0
    800031d4:	e02080e7          	jalr	-510(ra) # 80002fd2 <brelse>
  bp = bread(dev, bno);
    800031d8:	85ca                	mv	a1,s2
    800031da:	855e                	mv	a0,s7
    800031dc:	00000097          	auipc	ra,0x0
    800031e0:	cb4080e7          	jalr	-844(ra) # 80002e90 <bread>
    800031e4:	84aa                	mv	s1,a0
  memset(bp->data, 0, BSIZE);
    800031e6:	40000613          	li	a2,1024
    800031ea:	4581                	li	a1,0
    800031ec:	05850513          	addi	a0,a0,88
    800031f0:	ffffe097          	auipc	ra,0xffffe
    800031f4:	b30080e7          	jalr	-1232(ra) # 80000d20 <memset>
  log_write(bp);
    800031f8:	8526                	mv	a0,s1
    800031fa:	00001097          	auipc	ra,0x1
    800031fe:	208080e7          	jalr	520(ra) # 80004402 <log_write>
  brelse(bp);
    80003202:	8526                	mv	a0,s1
    80003204:	00000097          	auipc	ra,0x0
    80003208:	dce080e7          	jalr	-562(ra) # 80002fd2 <brelse>
}
    8000320c:	854a                	mv	a0,s2
    8000320e:	60e6                	ld	ra,88(sp)
    80003210:	6446                	ld	s0,80(sp)
    80003212:	64a6                	ld	s1,72(sp)
    80003214:	6906                	ld	s2,64(sp)
    80003216:	79e2                	ld	s3,56(sp)
    80003218:	7a42                	ld	s4,48(sp)
    8000321a:	7aa2                	ld	s5,40(sp)
    8000321c:	7b02                	ld	s6,32(sp)
    8000321e:	6be2                	ld	s7,24(sp)
    80003220:	6c42                	ld	s8,16(sp)
    80003222:	6ca2                	ld	s9,8(sp)
    80003224:	6125                	addi	sp,sp,96
    80003226:	8082                	ret
    brelse(bp);
    80003228:	8526                	mv	a0,s1
    8000322a:	00000097          	auipc	ra,0x0
    8000322e:	da8080e7          	jalr	-600(ra) # 80002fd2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003232:	015c87bb          	addw	a5,s9,s5
    80003236:	00078a9b          	sext.w	s5,a5
    8000323a:	004b2703          	lw	a4,4(s6)
    8000323e:	06eafd63          	bleu	a4,s5,800032b8 <balloc+0x140>
    bp = bread(dev, BBLOCK(b, sb));
    80003242:	41fad79b          	sraiw	a5,s5,0x1f
    80003246:	0137d79b          	srliw	a5,a5,0x13
    8000324a:	015787bb          	addw	a5,a5,s5
    8000324e:	40d7d79b          	sraiw	a5,a5,0xd
    80003252:	01cb2583          	lw	a1,28(s6)
    80003256:	9dbd                	addw	a1,a1,a5
    80003258:	855e                	mv	a0,s7
    8000325a:	00000097          	auipc	ra,0x0
    8000325e:	c36080e7          	jalr	-970(ra) # 80002e90 <bread>
    80003262:	84aa                	mv	s1,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003264:	000a881b          	sext.w	a6,s5
    80003268:	004b2503          	lw	a0,4(s6)
    8000326c:	faa87ee3          	bleu	a0,a6,80003228 <balloc+0xb0>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003270:	0584c603          	lbu	a2,88(s1)
    80003274:	00167793          	andi	a5,a2,1
    80003278:	df9d                	beqz	a5,800031b6 <balloc+0x3e>
    8000327a:	4105053b          	subw	a0,a0,a6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000327e:	87e2                	mv	a5,s8
    80003280:	0107893b          	addw	s2,a5,a6
    80003284:	faa782e3          	beq	a5,a0,80003228 <balloc+0xb0>
      m = 1 << (bi % 8);
    80003288:	41f7d71b          	sraiw	a4,a5,0x1f
    8000328c:	01d7561b          	srliw	a2,a4,0x1d
    80003290:	00f606bb          	addw	a3,a2,a5
    80003294:	0076f713          	andi	a4,a3,7
    80003298:	9f11                	subw	a4,a4,a2
    8000329a:	00e9973b          	sllw	a4,s3,a4
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000329e:	4036d69b          	sraiw	a3,a3,0x3
    800032a2:	00d48633          	add	a2,s1,a3
    800032a6:	05864603          	lbu	a2,88(a2)
    800032aa:	00c775b3          	and	a1,a4,a2
    800032ae:	d599                	beqz	a1,800031bc <balloc+0x44>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032b0:	2785                	addiw	a5,a5,1
    800032b2:	fd4797e3          	bne	a5,s4,80003280 <balloc+0x108>
    800032b6:	bf8d                	j	80003228 <balloc+0xb0>
  panic("balloc: out of blocks");
    800032b8:	00005517          	auipc	a0,0x5
    800032bc:	27050513          	addi	a0,a0,624 # 80008528 <syscalls+0x130>
    800032c0:	ffffd097          	auipc	ra,0xffffd
    800032c4:	298080e7          	jalr	664(ra) # 80000558 <panic>

00000000800032c8 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800032c8:	7139                	addi	sp,sp,-64
    800032ca:	fc06                	sd	ra,56(sp)
    800032cc:	f822                	sd	s0,48(sp)
    800032ce:	f426                	sd	s1,40(sp)
    800032d0:	f04a                	sd	s2,32(sp)
    800032d2:	ec4e                	sd	s3,24(sp)
    800032d4:	e852                	sd	s4,16(sp)
    800032d6:	e456                	sd	s5,8(sp)
    800032d8:	0080                	addi	s0,sp,64
    800032da:	89aa                	mv	s3,a0
  uint addr, *a, *b;
  struct buf *inbp, *ininbp;
  // index [0, 10] is direct block
  if(bn < NDIRECT){
    800032dc:	47a9                	li	a5,10
    800032de:	08b7fd63          	bleu	a1,a5,80003378 <bmap+0xb0>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800032e2:	ff55849b          	addiw	s1,a1,-11
    800032e6:	0004871b          	sext.w	a4,s1

  // after subtraction, [0, 255] is 1st indirect block
  if (bn < NINDIRECT) {
    800032ea:	0ff00793          	li	a5,255
    800032ee:	0ae7f863          	bleu	a4,a5,8000339e <bmap+0xd6>
      log_write(inbp);
    }
    brelse(inbp);
    return addr;
  }
  bn -= NINDIRECT;
    800032f2:	ef55849b          	addiw	s1,a1,-267
    800032f6:	0004871b          	sext.w	a4,s1

  // after subtraction, [0, 65535] is doubly-indirect block
  if (bn < NININDIRECT) {
    800032fa:	67c1                	lui	a5,0x10
    800032fc:	14f77e63          	bleu	a5,a4,80003458 <bmap+0x190>

    // Load 1st indirect block, allocating if necessary
    if ((addr = ip->addrs[NDIRECT+1]) == 0)
    80003300:	08052583          	lw	a1,128(a0)
    80003304:	10058063          	beqz	a1,80003404 <bmap+0x13c>
      ip->addrs[NDIRECT+1] = addr = balloc(ip->dev);
    inbp = bread(ip->dev, addr);
    80003308:	0009a503          	lw	a0,0(s3)
    8000330c:	00000097          	auipc	ra,0x0
    80003310:	b84080e7          	jalr	-1148(ra) # 80002e90 <bread>
    80003314:	8aaa                	mv	s5,a0
    a = (uint*)inbp->data;
    80003316:	05850913          	addi	s2,a0,88
    if ((addr = a[bn/NINDIRECT]) == 0) {
    8000331a:	0084d79b          	srliw	a5,s1,0x8
    8000331e:	078a                	slli	a5,a5,0x2
    80003320:	993e                	add	s2,s2,a5
    80003322:	00092a03          	lw	s4,0(s2)
    80003326:	0e0a0963          	beqz	s4,80003418 <bmap+0x150>
      a[bn/NINDIRECT] = addr = balloc(ip->dev);
      log_write(inbp);
    }
    brelse(inbp);
    8000332a:	8556                	mv	a0,s5
    8000332c:	00000097          	auipc	ra,0x0
    80003330:	ca6080e7          	jalr	-858(ra) # 80002fd2 <brelse>

    // Load the 2nd indirect block, allocating if necessary
    ininbp = bread(ip->dev, addr);
    80003334:	85d2                	mv	a1,s4
    80003336:	0009a503          	lw	a0,0(s3)
    8000333a:	00000097          	auipc	ra,0x0
    8000333e:	b56080e7          	jalr	-1194(ra) # 80002e90 <bread>
    80003342:	8a2a                	mv	s4,a0
    b = (uint*)ininbp->data;
    80003344:	05850793          	addi	a5,a0,88
    if ((addr = b[bn % NINDIRECT]) == 0) {
    80003348:	0ff4f593          	andi	a1,s1,255
    8000334c:	058a                	slli	a1,a1,0x2
    8000334e:	00b784b3          	add	s1,a5,a1
    80003352:	0004a903          	lw	s2,0(s1)
    80003356:	0e090163          	beqz	s2,80003438 <bmap+0x170>
      b[bn % NINDIRECT] = addr = balloc(ip->dev);
      log_write(ininbp);
    }
    brelse(ininbp);
    8000335a:	8552                	mv	a0,s4
    8000335c:	00000097          	auipc	ra,0x0
    80003360:	c76080e7          	jalr	-906(ra) # 80002fd2 <brelse>
    return addr;
  }
  panic("bmap: out of range");
}
    80003364:	854a                	mv	a0,s2
    80003366:	70e2                	ld	ra,56(sp)
    80003368:	7442                	ld	s0,48(sp)
    8000336a:	74a2                	ld	s1,40(sp)
    8000336c:	7902                	ld	s2,32(sp)
    8000336e:	69e2                	ld	s3,24(sp)
    80003370:	6a42                	ld	s4,16(sp)
    80003372:	6aa2                	ld	s5,8(sp)
    80003374:	6121                	addi	sp,sp,64
    80003376:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003378:	02059493          	slli	s1,a1,0x20
    8000337c:	9081                	srli	s1,s1,0x20
    8000337e:	048a                	slli	s1,s1,0x2
    80003380:	94aa                	add	s1,s1,a0
    80003382:	0504a903          	lw	s2,80(s1)
    80003386:	fc091fe3          	bnez	s2,80003364 <bmap+0x9c>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000338a:	4108                	lw	a0,0(a0)
    8000338c:	00000097          	auipc	ra,0x0
    80003390:	dec080e7          	jalr	-532(ra) # 80003178 <balloc>
    80003394:	0005091b          	sext.w	s2,a0
    80003398:	0524a823          	sw	s2,80(s1)
    8000339c:	b7e1                	j	80003364 <bmap+0x9c>
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000339e:	5d6c                	lw	a1,124(a0)
    800033a0:	c985                	beqz	a1,800033d0 <bmap+0x108>
    inbp = bread(ip->dev, addr);
    800033a2:	0009a503          	lw	a0,0(s3)
    800033a6:	00000097          	auipc	ra,0x0
    800033aa:	aea080e7          	jalr	-1302(ra) # 80002e90 <bread>
    800033ae:	8a2a                	mv	s4,a0
    a = (uint*)inbp->data;
    800033b0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033b4:	1482                	slli	s1,s1,0x20
    800033b6:	9081                	srli	s1,s1,0x20
    800033b8:	048a                	slli	s1,s1,0x2
    800033ba:	94be                	add	s1,s1,a5
    800033bc:	0004a903          	lw	s2,0(s1)
    800033c0:	02090263          	beqz	s2,800033e4 <bmap+0x11c>
    brelse(inbp);
    800033c4:	8552                	mv	a0,s4
    800033c6:	00000097          	auipc	ra,0x0
    800033ca:	c0c080e7          	jalr	-1012(ra) # 80002fd2 <brelse>
    return addr;
    800033ce:	bf59                	j	80003364 <bmap+0x9c>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800033d0:	4108                	lw	a0,0(a0)
    800033d2:	00000097          	auipc	ra,0x0
    800033d6:	da6080e7          	jalr	-602(ra) # 80003178 <balloc>
    800033da:	0005059b          	sext.w	a1,a0
    800033de:	06b9ae23          	sw	a1,124(s3)
    800033e2:	b7c1                	j	800033a2 <bmap+0xda>
      a[bn] = addr = balloc(ip->dev);
    800033e4:	0009a503          	lw	a0,0(s3)
    800033e8:	00000097          	auipc	ra,0x0
    800033ec:	d90080e7          	jalr	-624(ra) # 80003178 <balloc>
    800033f0:	0005091b          	sext.w	s2,a0
    800033f4:	0124a023          	sw	s2,0(s1)
      log_write(inbp);
    800033f8:	8552                	mv	a0,s4
    800033fa:	00001097          	auipc	ra,0x1
    800033fe:	008080e7          	jalr	8(ra) # 80004402 <log_write>
    80003402:	b7c9                	j	800033c4 <bmap+0xfc>
      ip->addrs[NDIRECT+1] = addr = balloc(ip->dev);
    80003404:	4108                	lw	a0,0(a0)
    80003406:	00000097          	auipc	ra,0x0
    8000340a:	d72080e7          	jalr	-654(ra) # 80003178 <balloc>
    8000340e:	0005059b          	sext.w	a1,a0
    80003412:	08b9a023          	sw	a1,128(s3)
    80003416:	bdcd                	j	80003308 <bmap+0x40>
      a[bn/NINDIRECT] = addr = balloc(ip->dev);
    80003418:	0009a503          	lw	a0,0(s3)
    8000341c:	00000097          	auipc	ra,0x0
    80003420:	d5c080e7          	jalr	-676(ra) # 80003178 <balloc>
    80003424:	00050a1b          	sext.w	s4,a0
    80003428:	01492023          	sw	s4,0(s2)
      log_write(inbp);
    8000342c:	8556                	mv	a0,s5
    8000342e:	00001097          	auipc	ra,0x1
    80003432:	fd4080e7          	jalr	-44(ra) # 80004402 <log_write>
    80003436:	bdd5                	j	8000332a <bmap+0x62>
      b[bn % NINDIRECT] = addr = balloc(ip->dev);
    80003438:	0009a503          	lw	a0,0(s3)
    8000343c:	00000097          	auipc	ra,0x0
    80003440:	d3c080e7          	jalr	-708(ra) # 80003178 <balloc>
    80003444:	0005091b          	sext.w	s2,a0
    80003448:	0124a023          	sw	s2,0(s1)
      log_write(ininbp);
    8000344c:	8552                	mv	a0,s4
    8000344e:	00001097          	auipc	ra,0x1
    80003452:	fb4080e7          	jalr	-76(ra) # 80004402 <log_write>
    80003456:	b711                	j	8000335a <bmap+0x92>
  panic("bmap: out of range");
    80003458:	00005517          	auipc	a0,0x5
    8000345c:	0e850513          	addi	a0,a0,232 # 80008540 <syscalls+0x148>
    80003460:	ffffd097          	auipc	ra,0xffffd
    80003464:	0f8080e7          	jalr	248(ra) # 80000558 <panic>

0000000080003468 <iget>:
{
    80003468:	7179                	addi	sp,sp,-48
    8000346a:	f406                	sd	ra,40(sp)
    8000346c:	f022                	sd	s0,32(sp)
    8000346e:	ec26                	sd	s1,24(sp)
    80003470:	e84a                	sd	s2,16(sp)
    80003472:	e44e                	sd	s3,8(sp)
    80003474:	e052                	sd	s4,0(sp)
    80003476:	1800                	addi	s0,sp,48
    80003478:	89aa                	mv	s3,a0
    8000347a:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    8000347c:	00017517          	auipc	a0,0x17
    80003480:	74450513          	addi	a0,a0,1860 # 8001abc0 <icache>
    80003484:	ffffd097          	auipc	ra,0xffffd
    80003488:	7a0080e7          	jalr	1952(ra) # 80000c24 <acquire>
  empty = 0;
    8000348c:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000348e:	00017497          	auipc	s1,0x17
    80003492:	74a48493          	addi	s1,s1,1866 # 8001abd8 <icache+0x18>
    80003496:	00019697          	auipc	a3,0x19
    8000349a:	1d268693          	addi	a3,a3,466 # 8001c668 <log>
    8000349e:	a039                	j	800034ac <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034a0:	02090b63          	beqz	s2,800034d6 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800034a4:	08848493          	addi	s1,s1,136
    800034a8:	02d48a63          	beq	s1,a3,800034dc <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034ac:	449c                	lw	a5,8(s1)
    800034ae:	fef059e3          	blez	a5,800034a0 <iget+0x38>
    800034b2:	4098                	lw	a4,0(s1)
    800034b4:	ff3716e3          	bne	a4,s3,800034a0 <iget+0x38>
    800034b8:	40d8                	lw	a4,4(s1)
    800034ba:	ff4713e3          	bne	a4,s4,800034a0 <iget+0x38>
      ip->ref++;
    800034be:	2785                	addiw	a5,a5,1
    800034c0:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800034c2:	00017517          	auipc	a0,0x17
    800034c6:	6fe50513          	addi	a0,a0,1790 # 8001abc0 <icache>
    800034ca:	ffffe097          	auipc	ra,0xffffe
    800034ce:	80e080e7          	jalr	-2034(ra) # 80000cd8 <release>
      return ip;
    800034d2:	8926                	mv	s2,s1
    800034d4:	a03d                	j	80003502 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034d6:	f7f9                	bnez	a5,800034a4 <iget+0x3c>
    800034d8:	8926                	mv	s2,s1
    800034da:	b7e9                	j	800034a4 <iget+0x3c>
  if(empty == 0)
    800034dc:	02090c63          	beqz	s2,80003514 <iget+0xac>
  ip->dev = dev;
    800034e0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034e4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034e8:	4785                	li	a5,1
    800034ea:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034ee:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800034f2:	00017517          	auipc	a0,0x17
    800034f6:	6ce50513          	addi	a0,a0,1742 # 8001abc0 <icache>
    800034fa:	ffffd097          	auipc	ra,0xffffd
    800034fe:	7de080e7          	jalr	2014(ra) # 80000cd8 <release>
}
    80003502:	854a                	mv	a0,s2
    80003504:	70a2                	ld	ra,40(sp)
    80003506:	7402                	ld	s0,32(sp)
    80003508:	64e2                	ld	s1,24(sp)
    8000350a:	6942                	ld	s2,16(sp)
    8000350c:	69a2                	ld	s3,8(sp)
    8000350e:	6a02                	ld	s4,0(sp)
    80003510:	6145                	addi	sp,sp,48
    80003512:	8082                	ret
    panic("iget: no inodes");
    80003514:	00005517          	auipc	a0,0x5
    80003518:	04450513          	addi	a0,a0,68 # 80008558 <syscalls+0x160>
    8000351c:	ffffd097          	auipc	ra,0xffffd
    80003520:	03c080e7          	jalr	60(ra) # 80000558 <panic>

0000000080003524 <fsinit>:
fsinit(int dev) {
    80003524:	7179                	addi	sp,sp,-48
    80003526:	f406                	sd	ra,40(sp)
    80003528:	f022                	sd	s0,32(sp)
    8000352a:	ec26                	sd	s1,24(sp)
    8000352c:	e84a                	sd	s2,16(sp)
    8000352e:	e44e                	sd	s3,8(sp)
    80003530:	1800                	addi	s0,sp,48
    80003532:	89aa                	mv	s3,a0
  bp = bread(dev, 1);
    80003534:	4585                	li	a1,1
    80003536:	00000097          	auipc	ra,0x0
    8000353a:	95a080e7          	jalr	-1702(ra) # 80002e90 <bread>
    8000353e:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003540:	00017497          	auipc	s1,0x17
    80003544:	66048493          	addi	s1,s1,1632 # 8001aba0 <sb>
    80003548:	02000613          	li	a2,32
    8000354c:	05850593          	addi	a1,a0,88
    80003550:	8526                	mv	a0,s1
    80003552:	ffffe097          	auipc	ra,0xffffe
    80003556:	83a080e7          	jalr	-1990(ra) # 80000d8c <memmove>
  brelse(bp);
    8000355a:	854a                	mv	a0,s2
    8000355c:	00000097          	auipc	ra,0x0
    80003560:	a76080e7          	jalr	-1418(ra) # 80002fd2 <brelse>
  if(sb.magic != FSMAGIC)
    80003564:	4098                	lw	a4,0(s1)
    80003566:	102037b7          	lui	a5,0x10203
    8000356a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000356e:	02f71263          	bne	a4,a5,80003592 <fsinit+0x6e>
  initlog(dev, &sb);
    80003572:	00017597          	auipc	a1,0x17
    80003576:	62e58593          	addi	a1,a1,1582 # 8001aba0 <sb>
    8000357a:	854e                	mv	a0,s3
    8000357c:	00001097          	auipc	ra,0x1
    80003580:	c04080e7          	jalr	-1020(ra) # 80004180 <initlog>
}
    80003584:	70a2                	ld	ra,40(sp)
    80003586:	7402                	ld	s0,32(sp)
    80003588:	64e2                	ld	s1,24(sp)
    8000358a:	6942                	ld	s2,16(sp)
    8000358c:	69a2                	ld	s3,8(sp)
    8000358e:	6145                	addi	sp,sp,48
    80003590:	8082                	ret
    panic("invalid file system");
    80003592:	00005517          	auipc	a0,0x5
    80003596:	fd650513          	addi	a0,a0,-42 # 80008568 <syscalls+0x170>
    8000359a:	ffffd097          	auipc	ra,0xffffd
    8000359e:	fbe080e7          	jalr	-66(ra) # 80000558 <panic>

00000000800035a2 <iinit>:
{
    800035a2:	7179                	addi	sp,sp,-48
    800035a4:	f406                	sd	ra,40(sp)
    800035a6:	f022                	sd	s0,32(sp)
    800035a8:	ec26                	sd	s1,24(sp)
    800035aa:	e84a                	sd	s2,16(sp)
    800035ac:	e44e                	sd	s3,8(sp)
    800035ae:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800035b0:	00005597          	auipc	a1,0x5
    800035b4:	fd058593          	addi	a1,a1,-48 # 80008580 <syscalls+0x188>
    800035b8:	00017517          	auipc	a0,0x17
    800035bc:	60850513          	addi	a0,a0,1544 # 8001abc0 <icache>
    800035c0:	ffffd097          	auipc	ra,0xffffd
    800035c4:	5d4080e7          	jalr	1492(ra) # 80000b94 <initlock>
  for(i = 0; i < NINODE; i++) {
    800035c8:	00017497          	auipc	s1,0x17
    800035cc:	62048493          	addi	s1,s1,1568 # 8001abe8 <icache+0x28>
    800035d0:	00019997          	auipc	s3,0x19
    800035d4:	0a898993          	addi	s3,s3,168 # 8001c678 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800035d8:	00005917          	auipc	s2,0x5
    800035dc:	fb090913          	addi	s2,s2,-80 # 80008588 <syscalls+0x190>
    800035e0:	85ca                	mv	a1,s2
    800035e2:	8526                	mv	a0,s1
    800035e4:	00001097          	auipc	ra,0x1
    800035e8:	f22080e7          	jalr	-222(ra) # 80004506 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035ec:	08848493          	addi	s1,s1,136
    800035f0:	ff3498e3          	bne	s1,s3,800035e0 <iinit+0x3e>
}
    800035f4:	70a2                	ld	ra,40(sp)
    800035f6:	7402                	ld	s0,32(sp)
    800035f8:	64e2                	ld	s1,24(sp)
    800035fa:	6942                	ld	s2,16(sp)
    800035fc:	69a2                	ld	s3,8(sp)
    800035fe:	6145                	addi	sp,sp,48
    80003600:	8082                	ret

0000000080003602 <ialloc>:
{
    80003602:	715d                	addi	sp,sp,-80
    80003604:	e486                	sd	ra,72(sp)
    80003606:	e0a2                	sd	s0,64(sp)
    80003608:	fc26                	sd	s1,56(sp)
    8000360a:	f84a                	sd	s2,48(sp)
    8000360c:	f44e                	sd	s3,40(sp)
    8000360e:	f052                	sd	s4,32(sp)
    80003610:	ec56                	sd	s5,24(sp)
    80003612:	e85a                	sd	s6,16(sp)
    80003614:	e45e                	sd	s7,8(sp)
    80003616:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003618:	00017797          	auipc	a5,0x17
    8000361c:	58878793          	addi	a5,a5,1416 # 8001aba0 <sb>
    80003620:	47d8                	lw	a4,12(a5)
    80003622:	4785                	li	a5,1
    80003624:	04e7fa63          	bleu	a4,a5,80003678 <ialloc+0x76>
    80003628:	8a2a                	mv	s4,a0
    8000362a:	8b2e                	mv	s6,a1
    8000362c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000362e:	00017997          	auipc	s3,0x17
    80003632:	57298993          	addi	s3,s3,1394 # 8001aba0 <sb>
    80003636:	00048a9b          	sext.w	s5,s1
    8000363a:	0044d593          	srli	a1,s1,0x4
    8000363e:	0189a783          	lw	a5,24(s3)
    80003642:	9dbd                	addw	a1,a1,a5
    80003644:	8552                	mv	a0,s4
    80003646:	00000097          	auipc	ra,0x0
    8000364a:	84a080e7          	jalr	-1974(ra) # 80002e90 <bread>
    8000364e:	8baa                	mv	s7,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003650:	05850913          	addi	s2,a0,88
    80003654:	00f4f793          	andi	a5,s1,15
    80003658:	079a                	slli	a5,a5,0x6
    8000365a:	993e                	add	s2,s2,a5
    if(dip->type == 0){  // a free inode
    8000365c:	00091783          	lh	a5,0(s2)
    80003660:	c785                	beqz	a5,80003688 <ialloc+0x86>
    brelse(bp);
    80003662:	00000097          	auipc	ra,0x0
    80003666:	970080e7          	jalr	-1680(ra) # 80002fd2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000366a:	0485                	addi	s1,s1,1
    8000366c:	00c9a703          	lw	a4,12(s3)
    80003670:	0004879b          	sext.w	a5,s1
    80003674:	fce7e1e3          	bltu	a5,a4,80003636 <ialloc+0x34>
  panic("ialloc: no inodes");
    80003678:	00005517          	auipc	a0,0x5
    8000367c:	f1850513          	addi	a0,a0,-232 # 80008590 <syscalls+0x198>
    80003680:	ffffd097          	auipc	ra,0xffffd
    80003684:	ed8080e7          	jalr	-296(ra) # 80000558 <panic>
      memset(dip, 0, sizeof(*dip));
    80003688:	04000613          	li	a2,64
    8000368c:	4581                	li	a1,0
    8000368e:	854a                	mv	a0,s2
    80003690:	ffffd097          	auipc	ra,0xffffd
    80003694:	690080e7          	jalr	1680(ra) # 80000d20 <memset>
      dip->type = type;
    80003698:	01691023          	sh	s6,0(s2)
      log_write(bp);   // mark it allocated on the disk
    8000369c:	855e                	mv	a0,s7
    8000369e:	00001097          	auipc	ra,0x1
    800036a2:	d64080e7          	jalr	-668(ra) # 80004402 <log_write>
      brelse(bp);
    800036a6:	855e                	mv	a0,s7
    800036a8:	00000097          	auipc	ra,0x0
    800036ac:	92a080e7          	jalr	-1750(ra) # 80002fd2 <brelse>
      return iget(dev, inum);
    800036b0:	85d6                	mv	a1,s5
    800036b2:	8552                	mv	a0,s4
    800036b4:	00000097          	auipc	ra,0x0
    800036b8:	db4080e7          	jalr	-588(ra) # 80003468 <iget>
}
    800036bc:	60a6                	ld	ra,72(sp)
    800036be:	6406                	ld	s0,64(sp)
    800036c0:	74e2                	ld	s1,56(sp)
    800036c2:	7942                	ld	s2,48(sp)
    800036c4:	79a2                	ld	s3,40(sp)
    800036c6:	7a02                	ld	s4,32(sp)
    800036c8:	6ae2                	ld	s5,24(sp)
    800036ca:	6b42                	ld	s6,16(sp)
    800036cc:	6ba2                	ld	s7,8(sp)
    800036ce:	6161                	addi	sp,sp,80
    800036d0:	8082                	ret

00000000800036d2 <iupdate>:
{
    800036d2:	1101                	addi	sp,sp,-32
    800036d4:	ec06                	sd	ra,24(sp)
    800036d6:	e822                	sd	s0,16(sp)
    800036d8:	e426                	sd	s1,8(sp)
    800036da:	e04a                	sd	s2,0(sp)
    800036dc:	1000                	addi	s0,sp,32
    800036de:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036e0:	415c                	lw	a5,4(a0)
    800036e2:	0047d79b          	srliw	a5,a5,0x4
    800036e6:	00017717          	auipc	a4,0x17
    800036ea:	4ba70713          	addi	a4,a4,1210 # 8001aba0 <sb>
    800036ee:	4f0c                	lw	a1,24(a4)
    800036f0:	9dbd                	addw	a1,a1,a5
    800036f2:	4108                	lw	a0,0(a0)
    800036f4:	fffff097          	auipc	ra,0xfffff
    800036f8:	79c080e7          	jalr	1948(ra) # 80002e90 <bread>
    800036fc:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036fe:	05850513          	addi	a0,a0,88
    80003702:	40dc                	lw	a5,4(s1)
    80003704:	8bbd                	andi	a5,a5,15
    80003706:	079a                	slli	a5,a5,0x6
    80003708:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000370a:	04449783          	lh	a5,68(s1)
    8000370e:	00f51023          	sh	a5,0(a0)
  dip->major = ip->major;
    80003712:	04649783          	lh	a5,70(s1)
    80003716:	00f51123          	sh	a5,2(a0)
  dip->minor = ip->minor;
    8000371a:	04849783          	lh	a5,72(s1)
    8000371e:	00f51223          	sh	a5,4(a0)
  dip->nlink = ip->nlink;
    80003722:	04a49783          	lh	a5,74(s1)
    80003726:	00f51323          	sh	a5,6(a0)
  dip->size = ip->size;
    8000372a:	44fc                	lw	a5,76(s1)
    8000372c:	c51c                	sw	a5,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000372e:	03400613          	li	a2,52
    80003732:	05048593          	addi	a1,s1,80
    80003736:	0531                	addi	a0,a0,12
    80003738:	ffffd097          	auipc	ra,0xffffd
    8000373c:	654080e7          	jalr	1620(ra) # 80000d8c <memmove>
  log_write(bp);
    80003740:	854a                	mv	a0,s2
    80003742:	00001097          	auipc	ra,0x1
    80003746:	cc0080e7          	jalr	-832(ra) # 80004402 <log_write>
  brelse(bp);
    8000374a:	854a                	mv	a0,s2
    8000374c:	00000097          	auipc	ra,0x0
    80003750:	886080e7          	jalr	-1914(ra) # 80002fd2 <brelse>
}
    80003754:	60e2                	ld	ra,24(sp)
    80003756:	6442                	ld	s0,16(sp)
    80003758:	64a2                	ld	s1,8(sp)
    8000375a:	6902                	ld	s2,0(sp)
    8000375c:	6105                	addi	sp,sp,32
    8000375e:	8082                	ret

0000000080003760 <idup>:
{
    80003760:	1101                	addi	sp,sp,-32
    80003762:	ec06                	sd	ra,24(sp)
    80003764:	e822                	sd	s0,16(sp)
    80003766:	e426                	sd	s1,8(sp)
    80003768:	1000                	addi	s0,sp,32
    8000376a:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000376c:	00017517          	auipc	a0,0x17
    80003770:	45450513          	addi	a0,a0,1108 # 8001abc0 <icache>
    80003774:	ffffd097          	auipc	ra,0xffffd
    80003778:	4b0080e7          	jalr	1200(ra) # 80000c24 <acquire>
  ip->ref++;
    8000377c:	449c                	lw	a5,8(s1)
    8000377e:	2785                	addiw	a5,a5,1
    80003780:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003782:	00017517          	auipc	a0,0x17
    80003786:	43e50513          	addi	a0,a0,1086 # 8001abc0 <icache>
    8000378a:	ffffd097          	auipc	ra,0xffffd
    8000378e:	54e080e7          	jalr	1358(ra) # 80000cd8 <release>
}
    80003792:	8526                	mv	a0,s1
    80003794:	60e2                	ld	ra,24(sp)
    80003796:	6442                	ld	s0,16(sp)
    80003798:	64a2                	ld	s1,8(sp)
    8000379a:	6105                	addi	sp,sp,32
    8000379c:	8082                	ret

000000008000379e <ilock>:
{
    8000379e:	1101                	addi	sp,sp,-32
    800037a0:	ec06                	sd	ra,24(sp)
    800037a2:	e822                	sd	s0,16(sp)
    800037a4:	e426                	sd	s1,8(sp)
    800037a6:	e04a                	sd	s2,0(sp)
    800037a8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800037aa:	c115                	beqz	a0,800037ce <ilock+0x30>
    800037ac:	84aa                	mv	s1,a0
    800037ae:	451c                	lw	a5,8(a0)
    800037b0:	00f05f63          	blez	a5,800037ce <ilock+0x30>
  acquiresleep(&ip->lock);
    800037b4:	0541                	addi	a0,a0,16
    800037b6:	00001097          	auipc	ra,0x1
    800037ba:	d8a080e7          	jalr	-630(ra) # 80004540 <acquiresleep>
  if(ip->valid == 0){
    800037be:	40bc                	lw	a5,64(s1)
    800037c0:	cf99                	beqz	a5,800037de <ilock+0x40>
}
    800037c2:	60e2                	ld	ra,24(sp)
    800037c4:	6442                	ld	s0,16(sp)
    800037c6:	64a2                	ld	s1,8(sp)
    800037c8:	6902                	ld	s2,0(sp)
    800037ca:	6105                	addi	sp,sp,32
    800037cc:	8082                	ret
    panic("ilock");
    800037ce:	00005517          	auipc	a0,0x5
    800037d2:	dda50513          	addi	a0,a0,-550 # 800085a8 <syscalls+0x1b0>
    800037d6:	ffffd097          	auipc	ra,0xffffd
    800037da:	d82080e7          	jalr	-638(ra) # 80000558 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037de:	40dc                	lw	a5,4(s1)
    800037e0:	0047d79b          	srliw	a5,a5,0x4
    800037e4:	00017717          	auipc	a4,0x17
    800037e8:	3bc70713          	addi	a4,a4,956 # 8001aba0 <sb>
    800037ec:	4f0c                	lw	a1,24(a4)
    800037ee:	9dbd                	addw	a1,a1,a5
    800037f0:	4088                	lw	a0,0(s1)
    800037f2:	fffff097          	auipc	ra,0xfffff
    800037f6:	69e080e7          	jalr	1694(ra) # 80002e90 <bread>
    800037fa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037fc:	05850593          	addi	a1,a0,88
    80003800:	40dc                	lw	a5,4(s1)
    80003802:	8bbd                	andi	a5,a5,15
    80003804:	079a                	slli	a5,a5,0x6
    80003806:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003808:	00059783          	lh	a5,0(a1)
    8000380c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003810:	00259783          	lh	a5,2(a1)
    80003814:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003818:	00459783          	lh	a5,4(a1)
    8000381c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003820:	00659783          	lh	a5,6(a1)
    80003824:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003828:	459c                	lw	a5,8(a1)
    8000382a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000382c:	03400613          	li	a2,52
    80003830:	05b1                	addi	a1,a1,12
    80003832:	05048513          	addi	a0,s1,80
    80003836:	ffffd097          	auipc	ra,0xffffd
    8000383a:	556080e7          	jalr	1366(ra) # 80000d8c <memmove>
    brelse(bp);
    8000383e:	854a                	mv	a0,s2
    80003840:	fffff097          	auipc	ra,0xfffff
    80003844:	792080e7          	jalr	1938(ra) # 80002fd2 <brelse>
    ip->valid = 1;
    80003848:	4785                	li	a5,1
    8000384a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000384c:	04449783          	lh	a5,68(s1)
    80003850:	fbad                	bnez	a5,800037c2 <ilock+0x24>
      panic("ilock: no type");
    80003852:	00005517          	auipc	a0,0x5
    80003856:	d5e50513          	addi	a0,a0,-674 # 800085b0 <syscalls+0x1b8>
    8000385a:	ffffd097          	auipc	ra,0xffffd
    8000385e:	cfe080e7          	jalr	-770(ra) # 80000558 <panic>

0000000080003862 <iunlock>:
{
    80003862:	1101                	addi	sp,sp,-32
    80003864:	ec06                	sd	ra,24(sp)
    80003866:	e822                	sd	s0,16(sp)
    80003868:	e426                	sd	s1,8(sp)
    8000386a:	e04a                	sd	s2,0(sp)
    8000386c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000386e:	c905                	beqz	a0,8000389e <iunlock+0x3c>
    80003870:	84aa                	mv	s1,a0
    80003872:	01050913          	addi	s2,a0,16
    80003876:	854a                	mv	a0,s2
    80003878:	00001097          	auipc	ra,0x1
    8000387c:	d62080e7          	jalr	-670(ra) # 800045da <holdingsleep>
    80003880:	cd19                	beqz	a0,8000389e <iunlock+0x3c>
    80003882:	449c                	lw	a5,8(s1)
    80003884:	00f05d63          	blez	a5,8000389e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003888:	854a                	mv	a0,s2
    8000388a:	00001097          	auipc	ra,0x1
    8000388e:	d0c080e7          	jalr	-756(ra) # 80004596 <releasesleep>
}
    80003892:	60e2                	ld	ra,24(sp)
    80003894:	6442                	ld	s0,16(sp)
    80003896:	64a2                	ld	s1,8(sp)
    80003898:	6902                	ld	s2,0(sp)
    8000389a:	6105                	addi	sp,sp,32
    8000389c:	8082                	ret
    panic("iunlock");
    8000389e:	00005517          	auipc	a0,0x5
    800038a2:	d2250513          	addi	a0,a0,-734 # 800085c0 <syscalls+0x1c8>
    800038a6:	ffffd097          	auipc	ra,0xffffd
    800038aa:	cb2080e7          	jalr	-846(ra) # 80000558 <panic>

00000000800038ae <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038ae:	715d                	addi	sp,sp,-80
    800038b0:	e486                	sd	ra,72(sp)
    800038b2:	e0a2                	sd	s0,64(sp)
    800038b4:	fc26                	sd	s1,56(sp)
    800038b6:	f84a                	sd	s2,48(sp)
    800038b8:	f44e                	sd	s3,40(sp)
    800038ba:	f052                	sd	s4,32(sp)
    800038bc:	ec56                	sd	s5,24(sp)
    800038be:	e85a                	sd	s6,16(sp)
    800038c0:	e45e                	sd	s7,8(sp)
    800038c2:	e062                	sd	s8,0(sp)
    800038c4:	0880                	addi	s0,sp,80
    800038c6:	89aa                	mv	s3,a0
  int i, j, k;
  struct buf *bp, *inbp;
  uint *a, *b;

  for(i = 0; i < NDIRECT; i++){
    800038c8:	05050493          	addi	s1,a0,80
    800038cc:	07c50913          	addi	s2,a0,124
    800038d0:	a021                	j	800038d8 <itrunc+0x2a>
    800038d2:	0491                	addi	s1,s1,4
    800038d4:	01248d63          	beq	s1,s2,800038ee <itrunc+0x40>
    if(ip->addrs[i]){
    800038d8:	408c                	lw	a1,0(s1)
    800038da:	dde5                	beqz	a1,800038d2 <itrunc+0x24>
      bfree(ip->dev, ip->addrs[i]);
    800038dc:	0009a503          	lw	a0,0(s3)
    800038e0:	00000097          	auipc	ra,0x0
    800038e4:	808080e7          	jalr	-2040(ra) # 800030e8 <bfree>
      ip->addrs[i] = 0;
    800038e8:	0004a023          	sw	zero,0(s1)
    800038ec:	b7dd                	j	800038d2 <itrunc+0x24>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038ee:	07c9a583          	lw	a1,124(s3)
    800038f2:	e59d                	bnez	a1,80003920 <itrunc+0x72>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  if(ip->addrs[NDIRECT+1]) {
    800038f4:	0809a583          	lw	a1,128(s3)
    800038f8:	eda5                	bnez	a1,80003970 <itrunc+0xc2>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT+1]);
    ip->addrs[NDIRECT+1] = 0;
  }

  ip->size = 0;
    800038fa:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038fe:	854e                	mv	a0,s3
    80003900:	00000097          	auipc	ra,0x0
    80003904:	dd2080e7          	jalr	-558(ra) # 800036d2 <iupdate>
}
    80003908:	60a6                	ld	ra,72(sp)
    8000390a:	6406                	ld	s0,64(sp)
    8000390c:	74e2                	ld	s1,56(sp)
    8000390e:	7942                	ld	s2,48(sp)
    80003910:	79a2                	ld	s3,40(sp)
    80003912:	7a02                	ld	s4,32(sp)
    80003914:	6ae2                	ld	s5,24(sp)
    80003916:	6b42                	ld	s6,16(sp)
    80003918:	6ba2                	ld	s7,8(sp)
    8000391a:	6c02                	ld	s8,0(sp)
    8000391c:	6161                	addi	sp,sp,80
    8000391e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003920:	0009a503          	lw	a0,0(s3)
    80003924:	fffff097          	auipc	ra,0xfffff
    80003928:	56c080e7          	jalr	1388(ra) # 80002e90 <bread>
    8000392c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000392e:	05850493          	addi	s1,a0,88
    80003932:	45850913          	addi	s2,a0,1112
    80003936:	a021                	j	8000393e <itrunc+0x90>
    80003938:	0491                	addi	s1,s1,4
    8000393a:	01248b63          	beq	s1,s2,80003950 <itrunc+0xa2>
      if(a[j])
    8000393e:	408c                	lw	a1,0(s1)
    80003940:	dde5                	beqz	a1,80003938 <itrunc+0x8a>
        bfree(ip->dev, a[j]);
    80003942:	0009a503          	lw	a0,0(s3)
    80003946:	fffff097          	auipc	ra,0xfffff
    8000394a:	7a2080e7          	jalr	1954(ra) # 800030e8 <bfree>
    8000394e:	b7ed                	j	80003938 <itrunc+0x8a>
    brelse(bp);
    80003950:	8552                	mv	a0,s4
    80003952:	fffff097          	auipc	ra,0xfffff
    80003956:	680080e7          	jalr	1664(ra) # 80002fd2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000395a:	07c9a583          	lw	a1,124(s3)
    8000395e:	0009a503          	lw	a0,0(s3)
    80003962:	fffff097          	auipc	ra,0xfffff
    80003966:	786080e7          	jalr	1926(ra) # 800030e8 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000396a:	0609ae23          	sw	zero,124(s3)
    8000396e:	b759                	j	800038f4 <itrunc+0x46>
    bp = bread(ip->dev, ip->addrs[NDIRECT+1]);
    80003970:	0009a503          	lw	a0,0(s3)
    80003974:	fffff097          	auipc	ra,0xfffff
    80003978:	51c080e7          	jalr	1308(ra) # 80002e90 <bread>
    8000397c:	8c2a                	mv	s8,a0
    for (j = 0; j < NINDIRECT; j++) {
    8000397e:	05850a13          	addi	s4,a0,88
    80003982:	45850b13          	addi	s6,a0,1112
    80003986:	a82d                	j	800039c0 <itrunc+0x112>
            bfree(ip->dev, b[k]);
    80003988:	0009a503          	lw	a0,0(s3)
    8000398c:	fffff097          	auipc	ra,0xfffff
    80003990:	75c080e7          	jalr	1884(ra) # 800030e8 <bfree>
        for (k = 0; k < NINDIRECT; k++) {
    80003994:	0491                	addi	s1,s1,4
    80003996:	01248563          	beq	s1,s2,800039a0 <itrunc+0xf2>
          if (b[k])
    8000399a:	408c                	lw	a1,0(s1)
    8000399c:	dde5                	beqz	a1,80003994 <itrunc+0xe6>
    8000399e:	b7ed                	j	80003988 <itrunc+0xda>
        brelse(inbp);
    800039a0:	855e                	mv	a0,s7
    800039a2:	fffff097          	auipc	ra,0xfffff
    800039a6:	630080e7          	jalr	1584(ra) # 80002fd2 <brelse>
        bfree(ip->dev, a[j]);
    800039aa:	000aa583          	lw	a1,0(s5)
    800039ae:	0009a503          	lw	a0,0(s3)
    800039b2:	fffff097          	auipc	ra,0xfffff
    800039b6:	736080e7          	jalr	1846(ra) # 800030e8 <bfree>
    for (j = 0; j < NINDIRECT; j++) {
    800039ba:	0a11                	addi	s4,s4,4
    800039bc:	036a0263          	beq	s4,s6,800039e0 <itrunc+0x132>
      if (a[j]) {
    800039c0:	8ad2                	mv	s5,s4
    800039c2:	000a2583          	lw	a1,0(s4) # 2000 <_entry-0x7fffe000>
    800039c6:	d9f5                	beqz	a1,800039ba <itrunc+0x10c>
        inbp = bread(ip->dev, a[j]);
    800039c8:	0009a503          	lw	a0,0(s3)
    800039cc:	fffff097          	auipc	ra,0xfffff
    800039d0:	4c4080e7          	jalr	1220(ra) # 80002e90 <bread>
    800039d4:	8baa                	mv	s7,a0
        for (k = 0; k < NINDIRECT; k++) {
    800039d6:	05850493          	addi	s1,a0,88
    800039da:	45850913          	addi	s2,a0,1112
    800039de:	bf75                	j	8000399a <itrunc+0xec>
    brelse(bp);
    800039e0:	8562                	mv	a0,s8
    800039e2:	fffff097          	auipc	ra,0xfffff
    800039e6:	5f0080e7          	jalr	1520(ra) # 80002fd2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT+1]);
    800039ea:	0809a583          	lw	a1,128(s3)
    800039ee:	0009a503          	lw	a0,0(s3)
    800039f2:	fffff097          	auipc	ra,0xfffff
    800039f6:	6f6080e7          	jalr	1782(ra) # 800030e8 <bfree>
    ip->addrs[NDIRECT+1] = 0;
    800039fa:	0809a023          	sw	zero,128(s3)
    800039fe:	bdf5                	j	800038fa <itrunc+0x4c>

0000000080003a00 <iput>:
{
    80003a00:	1101                	addi	sp,sp,-32
    80003a02:	ec06                	sd	ra,24(sp)
    80003a04:	e822                	sd	s0,16(sp)
    80003a06:	e426                	sd	s1,8(sp)
    80003a08:	e04a                	sd	s2,0(sp)
    80003a0a:	1000                	addi	s0,sp,32
    80003a0c:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003a0e:	00017517          	auipc	a0,0x17
    80003a12:	1b250513          	addi	a0,a0,434 # 8001abc0 <icache>
    80003a16:	ffffd097          	auipc	ra,0xffffd
    80003a1a:	20e080e7          	jalr	526(ra) # 80000c24 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a1e:	4498                	lw	a4,8(s1)
    80003a20:	4785                	li	a5,1
    80003a22:	02f70363          	beq	a4,a5,80003a48 <iput+0x48>
  ip->ref--;
    80003a26:	449c                	lw	a5,8(s1)
    80003a28:	37fd                	addiw	a5,a5,-1
    80003a2a:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003a2c:	00017517          	auipc	a0,0x17
    80003a30:	19450513          	addi	a0,a0,404 # 8001abc0 <icache>
    80003a34:	ffffd097          	auipc	ra,0xffffd
    80003a38:	2a4080e7          	jalr	676(ra) # 80000cd8 <release>
}
    80003a3c:	60e2                	ld	ra,24(sp)
    80003a3e:	6442                	ld	s0,16(sp)
    80003a40:	64a2                	ld	s1,8(sp)
    80003a42:	6902                	ld	s2,0(sp)
    80003a44:	6105                	addi	sp,sp,32
    80003a46:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a48:	40bc                	lw	a5,64(s1)
    80003a4a:	dff1                	beqz	a5,80003a26 <iput+0x26>
    80003a4c:	04a49783          	lh	a5,74(s1)
    80003a50:	fbf9                	bnez	a5,80003a26 <iput+0x26>
    acquiresleep(&ip->lock);
    80003a52:	01048913          	addi	s2,s1,16
    80003a56:	854a                	mv	a0,s2
    80003a58:	00001097          	auipc	ra,0x1
    80003a5c:	ae8080e7          	jalr	-1304(ra) # 80004540 <acquiresleep>
    release(&icache.lock);
    80003a60:	00017517          	auipc	a0,0x17
    80003a64:	16050513          	addi	a0,a0,352 # 8001abc0 <icache>
    80003a68:	ffffd097          	auipc	ra,0xffffd
    80003a6c:	270080e7          	jalr	624(ra) # 80000cd8 <release>
    itrunc(ip);
    80003a70:	8526                	mv	a0,s1
    80003a72:	00000097          	auipc	ra,0x0
    80003a76:	e3c080e7          	jalr	-452(ra) # 800038ae <itrunc>
    ip->type = 0;
    80003a7a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a7e:	8526                	mv	a0,s1
    80003a80:	00000097          	auipc	ra,0x0
    80003a84:	c52080e7          	jalr	-942(ra) # 800036d2 <iupdate>
    ip->valid = 0;
    80003a88:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003a8c:	854a                	mv	a0,s2
    80003a8e:	00001097          	auipc	ra,0x1
    80003a92:	b08080e7          	jalr	-1272(ra) # 80004596 <releasesleep>
    acquire(&icache.lock);
    80003a96:	00017517          	auipc	a0,0x17
    80003a9a:	12a50513          	addi	a0,a0,298 # 8001abc0 <icache>
    80003a9e:	ffffd097          	auipc	ra,0xffffd
    80003aa2:	186080e7          	jalr	390(ra) # 80000c24 <acquire>
    80003aa6:	b741                	j	80003a26 <iput+0x26>

0000000080003aa8 <iunlockput>:
{
    80003aa8:	1101                	addi	sp,sp,-32
    80003aaa:	ec06                	sd	ra,24(sp)
    80003aac:	e822                	sd	s0,16(sp)
    80003aae:	e426                	sd	s1,8(sp)
    80003ab0:	1000                	addi	s0,sp,32
    80003ab2:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ab4:	00000097          	auipc	ra,0x0
    80003ab8:	dae080e7          	jalr	-594(ra) # 80003862 <iunlock>
  iput(ip);
    80003abc:	8526                	mv	a0,s1
    80003abe:	00000097          	auipc	ra,0x0
    80003ac2:	f42080e7          	jalr	-190(ra) # 80003a00 <iput>
}
    80003ac6:	60e2                	ld	ra,24(sp)
    80003ac8:	6442                	ld	s0,16(sp)
    80003aca:	64a2                	ld	s1,8(sp)
    80003acc:	6105                	addi	sp,sp,32
    80003ace:	8082                	ret

0000000080003ad0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ad0:	1141                	addi	sp,sp,-16
    80003ad2:	e422                	sd	s0,8(sp)
    80003ad4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ad6:	411c                	lw	a5,0(a0)
    80003ad8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ada:	415c                	lw	a5,4(a0)
    80003adc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003ade:	04451783          	lh	a5,68(a0)
    80003ae2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003ae6:	04a51783          	lh	a5,74(a0)
    80003aea:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003aee:	04c56783          	lwu	a5,76(a0)
    80003af2:	e99c                	sd	a5,16(a1)
}
    80003af4:	6422                	ld	s0,8(sp)
    80003af6:	0141                	addi	sp,sp,16
    80003af8:	8082                	ret

0000000080003afa <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003afa:	457c                	lw	a5,76(a0)
    80003afc:	0ed7e963          	bltu	a5,a3,80003bee <readi+0xf4>
{
    80003b00:	7159                	addi	sp,sp,-112
    80003b02:	f486                	sd	ra,104(sp)
    80003b04:	f0a2                	sd	s0,96(sp)
    80003b06:	eca6                	sd	s1,88(sp)
    80003b08:	e8ca                	sd	s2,80(sp)
    80003b0a:	e4ce                	sd	s3,72(sp)
    80003b0c:	e0d2                	sd	s4,64(sp)
    80003b0e:	fc56                	sd	s5,56(sp)
    80003b10:	f85a                	sd	s6,48(sp)
    80003b12:	f45e                	sd	s7,40(sp)
    80003b14:	f062                	sd	s8,32(sp)
    80003b16:	ec66                	sd	s9,24(sp)
    80003b18:	e86a                	sd	s10,16(sp)
    80003b1a:	e46e                	sd	s11,8(sp)
    80003b1c:	1880                	addi	s0,sp,112
    80003b1e:	8baa                	mv	s7,a0
    80003b20:	8c2e                	mv	s8,a1
    80003b22:	8a32                	mv	s4,a2
    80003b24:	84b6                	mv	s1,a3
    80003b26:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b28:	9f35                	addw	a4,a4,a3
    return 0;
    80003b2a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b2c:	0ad76063          	bltu	a4,a3,80003bcc <readi+0xd2>
  if(off + n > ip->size)
    80003b30:	00e7f463          	bleu	a4,a5,80003b38 <readi+0x3e>
    n = ip->size - off;
    80003b34:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b38:	0a0b0963          	beqz	s6,80003bea <readi+0xf0>
    80003b3c:	4901                	li	s2,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b3e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b42:	5cfd                	li	s9,-1
    80003b44:	a82d                	j	80003b7e <readi+0x84>
    80003b46:	02099d93          	slli	s11,s3,0x20
    80003b4a:	020ddd93          	srli	s11,s11,0x20
    80003b4e:	058a8613          	addi	a2,s5,88
    80003b52:	86ee                	mv	a3,s11
    80003b54:	963a                	add	a2,a2,a4
    80003b56:	85d2                	mv	a1,s4
    80003b58:	8562                	mv	a0,s8
    80003b5a:	fffff097          	auipc	ra,0xfffff
    80003b5e:	96a080e7          	jalr	-1686(ra) # 800024c4 <either_copyout>
    80003b62:	05950d63          	beq	a0,s9,80003bbc <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b66:	8556                	mv	a0,s5
    80003b68:	fffff097          	auipc	ra,0xfffff
    80003b6c:	46a080e7          	jalr	1130(ra) # 80002fd2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b70:	0129893b          	addw	s2,s3,s2
    80003b74:	009984bb          	addw	s1,s3,s1
    80003b78:	9a6e                	add	s4,s4,s11
    80003b7a:	05697763          	bleu	s6,s2,80003bc8 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b7e:	000ba983          	lw	s3,0(s7)
    80003b82:	00a4d59b          	srliw	a1,s1,0xa
    80003b86:	855e                	mv	a0,s7
    80003b88:	fffff097          	auipc	ra,0xfffff
    80003b8c:	740080e7          	jalr	1856(ra) # 800032c8 <bmap>
    80003b90:	0005059b          	sext.w	a1,a0
    80003b94:	854e                	mv	a0,s3
    80003b96:	fffff097          	auipc	ra,0xfffff
    80003b9a:	2fa080e7          	jalr	762(ra) # 80002e90 <bread>
    80003b9e:	8aaa                	mv	s5,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ba0:	3ff4f713          	andi	a4,s1,1023
    80003ba4:	40ed07bb          	subw	a5,s10,a4
    80003ba8:	412b06bb          	subw	a3,s6,s2
    80003bac:	89be                	mv	s3,a5
    80003bae:	2781                	sext.w	a5,a5
    80003bb0:	0006861b          	sext.w	a2,a3
    80003bb4:	f8f679e3          	bleu	a5,a2,80003b46 <readi+0x4c>
    80003bb8:	89b6                	mv	s3,a3
    80003bba:	b771                	j	80003b46 <readi+0x4c>
      brelse(bp);
    80003bbc:	8556                	mv	a0,s5
    80003bbe:	fffff097          	auipc	ra,0xfffff
    80003bc2:	414080e7          	jalr	1044(ra) # 80002fd2 <brelse>
      tot = -1;
    80003bc6:	597d                	li	s2,-1
  }
  return tot;
    80003bc8:	0009051b          	sext.w	a0,s2
}
    80003bcc:	70a6                	ld	ra,104(sp)
    80003bce:	7406                	ld	s0,96(sp)
    80003bd0:	64e6                	ld	s1,88(sp)
    80003bd2:	6946                	ld	s2,80(sp)
    80003bd4:	69a6                	ld	s3,72(sp)
    80003bd6:	6a06                	ld	s4,64(sp)
    80003bd8:	7ae2                	ld	s5,56(sp)
    80003bda:	7b42                	ld	s6,48(sp)
    80003bdc:	7ba2                	ld	s7,40(sp)
    80003bde:	7c02                	ld	s8,32(sp)
    80003be0:	6ce2                	ld	s9,24(sp)
    80003be2:	6d42                	ld	s10,16(sp)
    80003be4:	6da2                	ld	s11,8(sp)
    80003be6:	6165                	addi	sp,sp,112
    80003be8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bea:	895a                	mv	s2,s6
    80003bec:	bff1                	j	80003bc8 <readi+0xce>
    return 0;
    80003bee:	4501                	li	a0,0
}
    80003bf0:	8082                	ret

0000000080003bf2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bf2:	457c                	lw	a5,76(a0)
    80003bf4:	10d7e963          	bltu	a5,a3,80003d06 <writei+0x114>
{
    80003bf8:	7159                	addi	sp,sp,-112
    80003bfa:	f486                	sd	ra,104(sp)
    80003bfc:	f0a2                	sd	s0,96(sp)
    80003bfe:	eca6                	sd	s1,88(sp)
    80003c00:	e8ca                	sd	s2,80(sp)
    80003c02:	e4ce                	sd	s3,72(sp)
    80003c04:	e0d2                	sd	s4,64(sp)
    80003c06:	fc56                	sd	s5,56(sp)
    80003c08:	f85a                	sd	s6,48(sp)
    80003c0a:	f45e                	sd	s7,40(sp)
    80003c0c:	f062                	sd	s8,32(sp)
    80003c0e:	ec66                	sd	s9,24(sp)
    80003c10:	e86a                	sd	s10,16(sp)
    80003c12:	e46e                	sd	s11,8(sp)
    80003c14:	1880                	addi	s0,sp,112
    80003c16:	8b2a                	mv	s6,a0
    80003c18:	8c2e                	mv	s8,a1
    80003c1a:	8ab2                	mv	s5,a2
    80003c1c:	84b6                	mv	s1,a3
    80003c1e:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003c20:	9f35                	addw	a4,a4,a3
    80003c22:	0ed76463          	bltu	a4,a3,80003d0a <writei+0x118>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c26:	040437b7          	lui	a5,0x4043
    80003c2a:	c0078793          	addi	a5,a5,-1024 # 4042c00 <_entry-0x7bfbd400>
    80003c2e:	0ee7e063          	bltu	a5,a4,80003d0e <writei+0x11c>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c32:	0c0b8863          	beqz	s7,80003d02 <writei+0x110>
    80003c36:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c38:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c3c:	5cfd                	li	s9,-1
    80003c3e:	a091                	j	80003c82 <writei+0x90>
    80003c40:	02091d93          	slli	s11,s2,0x20
    80003c44:	020ddd93          	srli	s11,s11,0x20
    80003c48:	058a0513          	addi	a0,s4,88
    80003c4c:	86ee                	mv	a3,s11
    80003c4e:	8656                	mv	a2,s5
    80003c50:	85e2                	mv	a1,s8
    80003c52:	953a                	add	a0,a0,a4
    80003c54:	fffff097          	auipc	ra,0xfffff
    80003c58:	8c6080e7          	jalr	-1850(ra) # 8000251a <either_copyin>
    80003c5c:	07950263          	beq	a0,s9,80003cc0 <writei+0xce>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c60:	8552                	mv	a0,s4
    80003c62:	00000097          	auipc	ra,0x0
    80003c66:	7a0080e7          	jalr	1952(ra) # 80004402 <log_write>
    brelse(bp);
    80003c6a:	8552                	mv	a0,s4
    80003c6c:	fffff097          	auipc	ra,0xfffff
    80003c70:	366080e7          	jalr	870(ra) # 80002fd2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c74:	013909bb          	addw	s3,s2,s3
    80003c78:	009904bb          	addw	s1,s2,s1
    80003c7c:	9aee                	add	s5,s5,s11
    80003c7e:	0579f663          	bleu	s7,s3,80003cca <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c82:	000b2903          	lw	s2,0(s6)
    80003c86:	00a4d59b          	srliw	a1,s1,0xa
    80003c8a:	855a                	mv	a0,s6
    80003c8c:	fffff097          	auipc	ra,0xfffff
    80003c90:	63c080e7          	jalr	1596(ra) # 800032c8 <bmap>
    80003c94:	0005059b          	sext.w	a1,a0
    80003c98:	854a                	mv	a0,s2
    80003c9a:	fffff097          	auipc	ra,0xfffff
    80003c9e:	1f6080e7          	jalr	502(ra) # 80002e90 <bread>
    80003ca2:	8a2a                	mv	s4,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ca4:	3ff4f713          	andi	a4,s1,1023
    80003ca8:	40ed07bb          	subw	a5,s10,a4
    80003cac:	413b86bb          	subw	a3,s7,s3
    80003cb0:	893e                	mv	s2,a5
    80003cb2:	2781                	sext.w	a5,a5
    80003cb4:	0006861b          	sext.w	a2,a3
    80003cb8:	f8f674e3          	bleu	a5,a2,80003c40 <writei+0x4e>
    80003cbc:	8936                	mv	s2,a3
    80003cbe:	b749                	j	80003c40 <writei+0x4e>
      brelse(bp);
    80003cc0:	8552                	mv	a0,s4
    80003cc2:	fffff097          	auipc	ra,0xfffff
    80003cc6:	310080e7          	jalr	784(ra) # 80002fd2 <brelse>
  }

  if(off > ip->size)
    80003cca:	04cb2783          	lw	a5,76(s6)
    80003cce:	0097f463          	bleu	s1,a5,80003cd6 <writei+0xe4>
    ip->size = off;
    80003cd2:	049b2623          	sw	s1,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003cd6:	855a                	mv	a0,s6
    80003cd8:	00000097          	auipc	ra,0x0
    80003cdc:	9fa080e7          	jalr	-1542(ra) # 800036d2 <iupdate>

  return tot;
    80003ce0:	0009851b          	sext.w	a0,s3
}
    80003ce4:	70a6                	ld	ra,104(sp)
    80003ce6:	7406                	ld	s0,96(sp)
    80003ce8:	64e6                	ld	s1,88(sp)
    80003cea:	6946                	ld	s2,80(sp)
    80003cec:	69a6                	ld	s3,72(sp)
    80003cee:	6a06                	ld	s4,64(sp)
    80003cf0:	7ae2                	ld	s5,56(sp)
    80003cf2:	7b42                	ld	s6,48(sp)
    80003cf4:	7ba2                	ld	s7,40(sp)
    80003cf6:	7c02                	ld	s8,32(sp)
    80003cf8:	6ce2                	ld	s9,24(sp)
    80003cfa:	6d42                	ld	s10,16(sp)
    80003cfc:	6da2                	ld	s11,8(sp)
    80003cfe:	6165                	addi	sp,sp,112
    80003d00:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d02:	89de                	mv	s3,s7
    80003d04:	bfc9                	j	80003cd6 <writei+0xe4>
    return -1;
    80003d06:	557d                	li	a0,-1
}
    80003d08:	8082                	ret
    return -1;
    80003d0a:	557d                	li	a0,-1
    80003d0c:	bfe1                	j	80003ce4 <writei+0xf2>
    return -1;
    80003d0e:	557d                	li	a0,-1
    80003d10:	bfd1                	j	80003ce4 <writei+0xf2>

0000000080003d12 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d12:	1141                	addi	sp,sp,-16
    80003d14:	e406                	sd	ra,8(sp)
    80003d16:	e022                	sd	s0,0(sp)
    80003d18:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d1a:	4639                	li	a2,14
    80003d1c:	ffffd097          	auipc	ra,0xffffd
    80003d20:	0ec080e7          	jalr	236(ra) # 80000e08 <strncmp>
}
    80003d24:	60a2                	ld	ra,8(sp)
    80003d26:	6402                	ld	s0,0(sp)
    80003d28:	0141                	addi	sp,sp,16
    80003d2a:	8082                	ret

0000000080003d2c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d2c:	7139                	addi	sp,sp,-64
    80003d2e:	fc06                	sd	ra,56(sp)
    80003d30:	f822                	sd	s0,48(sp)
    80003d32:	f426                	sd	s1,40(sp)
    80003d34:	f04a                	sd	s2,32(sp)
    80003d36:	ec4e                	sd	s3,24(sp)
    80003d38:	e852                	sd	s4,16(sp)
    80003d3a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d3c:	04451703          	lh	a4,68(a0)
    80003d40:	4785                	li	a5,1
    80003d42:	00f71a63          	bne	a4,a5,80003d56 <dirlookup+0x2a>
    80003d46:	892a                	mv	s2,a0
    80003d48:	89ae                	mv	s3,a1
    80003d4a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d4c:	457c                	lw	a5,76(a0)
    80003d4e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d50:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d52:	e79d                	bnez	a5,80003d80 <dirlookup+0x54>
    80003d54:	a8a5                	j	80003dcc <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d56:	00005517          	auipc	a0,0x5
    80003d5a:	87250513          	addi	a0,a0,-1934 # 800085c8 <syscalls+0x1d0>
    80003d5e:	ffffc097          	auipc	ra,0xffffc
    80003d62:	7fa080e7          	jalr	2042(ra) # 80000558 <panic>
      panic("dirlookup read");
    80003d66:	00005517          	auipc	a0,0x5
    80003d6a:	87a50513          	addi	a0,a0,-1926 # 800085e0 <syscalls+0x1e8>
    80003d6e:	ffffc097          	auipc	ra,0xffffc
    80003d72:	7ea080e7          	jalr	2026(ra) # 80000558 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d76:	24c1                	addiw	s1,s1,16
    80003d78:	04c92783          	lw	a5,76(s2)
    80003d7c:	04f4f763          	bleu	a5,s1,80003dca <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d80:	4741                	li	a4,16
    80003d82:	86a6                	mv	a3,s1
    80003d84:	fc040613          	addi	a2,s0,-64
    80003d88:	4581                	li	a1,0
    80003d8a:	854a                	mv	a0,s2
    80003d8c:	00000097          	auipc	ra,0x0
    80003d90:	d6e080e7          	jalr	-658(ra) # 80003afa <readi>
    80003d94:	47c1                	li	a5,16
    80003d96:	fcf518e3          	bne	a0,a5,80003d66 <dirlookup+0x3a>
    if(de.inum == 0)
    80003d9a:	fc045783          	lhu	a5,-64(s0)
    80003d9e:	dfe1                	beqz	a5,80003d76 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003da0:	fc240593          	addi	a1,s0,-62
    80003da4:	854e                	mv	a0,s3
    80003da6:	00000097          	auipc	ra,0x0
    80003daa:	f6c080e7          	jalr	-148(ra) # 80003d12 <namecmp>
    80003dae:	f561                	bnez	a0,80003d76 <dirlookup+0x4a>
      if(poff)
    80003db0:	000a0463          	beqz	s4,80003db8 <dirlookup+0x8c>
        *poff = off;
    80003db4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003db8:	fc045583          	lhu	a1,-64(s0)
    80003dbc:	00092503          	lw	a0,0(s2)
    80003dc0:	fffff097          	auipc	ra,0xfffff
    80003dc4:	6a8080e7          	jalr	1704(ra) # 80003468 <iget>
    80003dc8:	a011                	j	80003dcc <dirlookup+0xa0>
  return 0;
    80003dca:	4501                	li	a0,0
}
    80003dcc:	70e2                	ld	ra,56(sp)
    80003dce:	7442                	ld	s0,48(sp)
    80003dd0:	74a2                	ld	s1,40(sp)
    80003dd2:	7902                	ld	s2,32(sp)
    80003dd4:	69e2                	ld	s3,24(sp)
    80003dd6:	6a42                	ld	s4,16(sp)
    80003dd8:	6121                	addi	sp,sp,64
    80003dda:	8082                	ret

0000000080003ddc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ddc:	711d                	addi	sp,sp,-96
    80003dde:	ec86                	sd	ra,88(sp)
    80003de0:	e8a2                	sd	s0,80(sp)
    80003de2:	e4a6                	sd	s1,72(sp)
    80003de4:	e0ca                	sd	s2,64(sp)
    80003de6:	fc4e                	sd	s3,56(sp)
    80003de8:	f852                	sd	s4,48(sp)
    80003dea:	f456                	sd	s5,40(sp)
    80003dec:	f05a                	sd	s6,32(sp)
    80003dee:	ec5e                	sd	s7,24(sp)
    80003df0:	e862                	sd	s8,16(sp)
    80003df2:	e466                	sd	s9,8(sp)
    80003df4:	1080                	addi	s0,sp,96
    80003df6:	84aa                	mv	s1,a0
    80003df8:	8bae                	mv	s7,a1
    80003dfa:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003dfc:	00054703          	lbu	a4,0(a0)
    80003e00:	02f00793          	li	a5,47
    80003e04:	02f70363          	beq	a4,a5,80003e2a <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e08:	ffffe097          	auipc	ra,0xffffe
    80003e0c:	c40080e7          	jalr	-960(ra) # 80001a48 <myproc>
    80003e10:	15053503          	ld	a0,336(a0)
    80003e14:	00000097          	auipc	ra,0x0
    80003e18:	94c080e7          	jalr	-1716(ra) # 80003760 <idup>
    80003e1c:	89aa                	mv	s3,a0
  while(*path == '/')
    80003e1e:	02f00913          	li	s2,47
  len = path - s;
    80003e22:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003e24:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e26:	4c05                	li	s8,1
    80003e28:	a865                	j	80003ee0 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003e2a:	4585                	li	a1,1
    80003e2c:	4505                	li	a0,1
    80003e2e:	fffff097          	auipc	ra,0xfffff
    80003e32:	63a080e7          	jalr	1594(ra) # 80003468 <iget>
    80003e36:	89aa                	mv	s3,a0
    80003e38:	b7dd                	j	80003e1e <namex+0x42>
      iunlockput(ip);
    80003e3a:	854e                	mv	a0,s3
    80003e3c:	00000097          	auipc	ra,0x0
    80003e40:	c6c080e7          	jalr	-916(ra) # 80003aa8 <iunlockput>
      return 0;
    80003e44:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e46:	854e                	mv	a0,s3
    80003e48:	60e6                	ld	ra,88(sp)
    80003e4a:	6446                	ld	s0,80(sp)
    80003e4c:	64a6                	ld	s1,72(sp)
    80003e4e:	6906                	ld	s2,64(sp)
    80003e50:	79e2                	ld	s3,56(sp)
    80003e52:	7a42                	ld	s4,48(sp)
    80003e54:	7aa2                	ld	s5,40(sp)
    80003e56:	7b02                	ld	s6,32(sp)
    80003e58:	6be2                	ld	s7,24(sp)
    80003e5a:	6c42                	ld	s8,16(sp)
    80003e5c:	6ca2                	ld	s9,8(sp)
    80003e5e:	6125                	addi	sp,sp,96
    80003e60:	8082                	ret
      iunlock(ip);
    80003e62:	854e                	mv	a0,s3
    80003e64:	00000097          	auipc	ra,0x0
    80003e68:	9fe080e7          	jalr	-1538(ra) # 80003862 <iunlock>
      return ip;
    80003e6c:	bfe9                	j	80003e46 <namex+0x6a>
      iunlockput(ip);
    80003e6e:	854e                	mv	a0,s3
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	c38080e7          	jalr	-968(ra) # 80003aa8 <iunlockput>
      return 0;
    80003e78:	89d2                	mv	s3,s4
    80003e7a:	b7f1                	j	80003e46 <namex+0x6a>
  len = path - s;
    80003e7c:	40b48633          	sub	a2,s1,a1
    80003e80:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003e84:	094cd663          	ble	s4,s9,80003f10 <namex+0x134>
    memmove(name, s, DIRSIZ);
    80003e88:	4639                	li	a2,14
    80003e8a:	8556                	mv	a0,s5
    80003e8c:	ffffd097          	auipc	ra,0xffffd
    80003e90:	f00080e7          	jalr	-256(ra) # 80000d8c <memmove>
  while(*path == '/')
    80003e94:	0004c783          	lbu	a5,0(s1)
    80003e98:	01279763          	bne	a5,s2,80003ea6 <namex+0xca>
    path++;
    80003e9c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e9e:	0004c783          	lbu	a5,0(s1)
    80003ea2:	ff278de3          	beq	a5,s2,80003e9c <namex+0xc0>
    ilock(ip);
    80003ea6:	854e                	mv	a0,s3
    80003ea8:	00000097          	auipc	ra,0x0
    80003eac:	8f6080e7          	jalr	-1802(ra) # 8000379e <ilock>
    if(ip->type != T_DIR){
    80003eb0:	04499783          	lh	a5,68(s3)
    80003eb4:	f98793e3          	bne	a5,s8,80003e3a <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003eb8:	000b8563          	beqz	s7,80003ec2 <namex+0xe6>
    80003ebc:	0004c783          	lbu	a5,0(s1)
    80003ec0:	d3cd                	beqz	a5,80003e62 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ec2:	865a                	mv	a2,s6
    80003ec4:	85d6                	mv	a1,s5
    80003ec6:	854e                	mv	a0,s3
    80003ec8:	00000097          	auipc	ra,0x0
    80003ecc:	e64080e7          	jalr	-412(ra) # 80003d2c <dirlookup>
    80003ed0:	8a2a                	mv	s4,a0
    80003ed2:	dd51                	beqz	a0,80003e6e <namex+0x92>
    iunlockput(ip);
    80003ed4:	854e                	mv	a0,s3
    80003ed6:	00000097          	auipc	ra,0x0
    80003eda:	bd2080e7          	jalr	-1070(ra) # 80003aa8 <iunlockput>
    ip = next;
    80003ede:	89d2                	mv	s3,s4
  while(*path == '/')
    80003ee0:	0004c783          	lbu	a5,0(s1)
    80003ee4:	05279d63          	bne	a5,s2,80003f3e <namex+0x162>
    path++;
    80003ee8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003eea:	0004c783          	lbu	a5,0(s1)
    80003eee:	ff278de3          	beq	a5,s2,80003ee8 <namex+0x10c>
  if(*path == 0)
    80003ef2:	cf8d                	beqz	a5,80003f2c <namex+0x150>
  while(*path != '/' && *path != 0)
    80003ef4:	01278b63          	beq	a5,s2,80003f0a <namex+0x12e>
    80003ef8:	c795                	beqz	a5,80003f24 <namex+0x148>
    path++;
    80003efa:	85a6                	mv	a1,s1
    path++;
    80003efc:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003efe:	0004c783          	lbu	a5,0(s1)
    80003f02:	f7278de3          	beq	a5,s2,80003e7c <namex+0xa0>
    80003f06:	fbfd                	bnez	a5,80003efc <namex+0x120>
    80003f08:	bf95                	j	80003e7c <namex+0xa0>
    80003f0a:	85a6                	mv	a1,s1
  len = path - s;
    80003f0c:	8a5a                	mv	s4,s6
    80003f0e:	865a                	mv	a2,s6
    memmove(name, s, len);
    80003f10:	2601                	sext.w	a2,a2
    80003f12:	8556                	mv	a0,s5
    80003f14:	ffffd097          	auipc	ra,0xffffd
    80003f18:	e78080e7          	jalr	-392(ra) # 80000d8c <memmove>
    name[len] = 0;
    80003f1c:	9a56                	add	s4,s4,s5
    80003f1e:	000a0023          	sb	zero,0(s4)
    80003f22:	bf8d                	j	80003e94 <namex+0xb8>
  while(*path != '/' && *path != 0)
    80003f24:	85a6                	mv	a1,s1
  len = path - s;
    80003f26:	8a5a                	mv	s4,s6
    80003f28:	865a                	mv	a2,s6
    80003f2a:	b7dd                	j	80003f10 <namex+0x134>
  if(nameiparent){
    80003f2c:	f00b8de3          	beqz	s7,80003e46 <namex+0x6a>
    iput(ip);
    80003f30:	854e                	mv	a0,s3
    80003f32:	00000097          	auipc	ra,0x0
    80003f36:	ace080e7          	jalr	-1330(ra) # 80003a00 <iput>
    return 0;
    80003f3a:	4981                	li	s3,0
    80003f3c:	b729                	j	80003e46 <namex+0x6a>
  if(*path == 0)
    80003f3e:	d7fd                	beqz	a5,80003f2c <namex+0x150>
    80003f40:	85a6                	mv	a1,s1
    80003f42:	bf6d                	j	80003efc <namex+0x120>

0000000080003f44 <dirlink>:
{
    80003f44:	7139                	addi	sp,sp,-64
    80003f46:	fc06                	sd	ra,56(sp)
    80003f48:	f822                	sd	s0,48(sp)
    80003f4a:	f426                	sd	s1,40(sp)
    80003f4c:	f04a                	sd	s2,32(sp)
    80003f4e:	ec4e                	sd	s3,24(sp)
    80003f50:	e852                	sd	s4,16(sp)
    80003f52:	0080                	addi	s0,sp,64
    80003f54:	892a                	mv	s2,a0
    80003f56:	8a2e                	mv	s4,a1
    80003f58:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f5a:	4601                	li	a2,0
    80003f5c:	00000097          	auipc	ra,0x0
    80003f60:	dd0080e7          	jalr	-560(ra) # 80003d2c <dirlookup>
    80003f64:	e93d                	bnez	a0,80003fda <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f66:	04c92483          	lw	s1,76(s2)
    80003f6a:	c49d                	beqz	s1,80003f98 <dirlink+0x54>
    80003f6c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f6e:	4741                	li	a4,16
    80003f70:	86a6                	mv	a3,s1
    80003f72:	fc040613          	addi	a2,s0,-64
    80003f76:	4581                	li	a1,0
    80003f78:	854a                	mv	a0,s2
    80003f7a:	00000097          	auipc	ra,0x0
    80003f7e:	b80080e7          	jalr	-1152(ra) # 80003afa <readi>
    80003f82:	47c1                	li	a5,16
    80003f84:	06f51163          	bne	a0,a5,80003fe6 <dirlink+0xa2>
    if(de.inum == 0)
    80003f88:	fc045783          	lhu	a5,-64(s0)
    80003f8c:	c791                	beqz	a5,80003f98 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f8e:	24c1                	addiw	s1,s1,16
    80003f90:	04c92783          	lw	a5,76(s2)
    80003f94:	fcf4ede3          	bltu	s1,a5,80003f6e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003f98:	4639                	li	a2,14
    80003f9a:	85d2                	mv	a1,s4
    80003f9c:	fc240513          	addi	a0,s0,-62
    80003fa0:	ffffd097          	auipc	ra,0xffffd
    80003fa4:	eb8080e7          	jalr	-328(ra) # 80000e58 <strncpy>
  de.inum = inum;
    80003fa8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fac:	4741                	li	a4,16
    80003fae:	86a6                	mv	a3,s1
    80003fb0:	fc040613          	addi	a2,s0,-64
    80003fb4:	4581                	li	a1,0
    80003fb6:	854a                	mv	a0,s2
    80003fb8:	00000097          	auipc	ra,0x0
    80003fbc:	c3a080e7          	jalr	-966(ra) # 80003bf2 <writei>
    80003fc0:	4741                	li	a4,16
  return 0;
    80003fc2:	4781                	li	a5,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fc4:	02e51963          	bne	a0,a4,80003ff6 <dirlink+0xb2>
}
    80003fc8:	853e                	mv	a0,a5
    80003fca:	70e2                	ld	ra,56(sp)
    80003fcc:	7442                	ld	s0,48(sp)
    80003fce:	74a2                	ld	s1,40(sp)
    80003fd0:	7902                	ld	s2,32(sp)
    80003fd2:	69e2                	ld	s3,24(sp)
    80003fd4:	6a42                	ld	s4,16(sp)
    80003fd6:	6121                	addi	sp,sp,64
    80003fd8:	8082                	ret
    iput(ip);
    80003fda:	00000097          	auipc	ra,0x0
    80003fde:	a26080e7          	jalr	-1498(ra) # 80003a00 <iput>
    return -1;
    80003fe2:	57fd                	li	a5,-1
    80003fe4:	b7d5                	j	80003fc8 <dirlink+0x84>
      panic("dirlink read");
    80003fe6:	00004517          	auipc	a0,0x4
    80003fea:	60a50513          	addi	a0,a0,1546 # 800085f0 <syscalls+0x1f8>
    80003fee:	ffffc097          	auipc	ra,0xffffc
    80003ff2:	56a080e7          	jalr	1386(ra) # 80000558 <panic>
    panic("dirlink");
    80003ff6:	00004517          	auipc	a0,0x4
    80003ffa:	70a50513          	addi	a0,a0,1802 # 80008700 <syscalls+0x308>
    80003ffe:	ffffc097          	auipc	ra,0xffffc
    80004002:	55a080e7          	jalr	1370(ra) # 80000558 <panic>

0000000080004006 <namei>:

struct inode*
namei(char *path)
{
    80004006:	1101                	addi	sp,sp,-32
    80004008:	ec06                	sd	ra,24(sp)
    8000400a:	e822                	sd	s0,16(sp)
    8000400c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000400e:	fe040613          	addi	a2,s0,-32
    80004012:	4581                	li	a1,0
    80004014:	00000097          	auipc	ra,0x0
    80004018:	dc8080e7          	jalr	-568(ra) # 80003ddc <namex>
}
    8000401c:	60e2                	ld	ra,24(sp)
    8000401e:	6442                	ld	s0,16(sp)
    80004020:	6105                	addi	sp,sp,32
    80004022:	8082                	ret

0000000080004024 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004024:	1141                	addi	sp,sp,-16
    80004026:	e406                	sd	ra,8(sp)
    80004028:	e022                	sd	s0,0(sp)
    8000402a:	0800                	addi	s0,sp,16
  return namex(path, 1, name);
    8000402c:	862e                	mv	a2,a1
    8000402e:	4585                	li	a1,1
    80004030:	00000097          	auipc	ra,0x0
    80004034:	dac080e7          	jalr	-596(ra) # 80003ddc <namex>
}
    80004038:	60a2                	ld	ra,8(sp)
    8000403a:	6402                	ld	s0,0(sp)
    8000403c:	0141                	addi	sp,sp,16
    8000403e:	8082                	ret

0000000080004040 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004040:	1101                	addi	sp,sp,-32
    80004042:	ec06                	sd	ra,24(sp)
    80004044:	e822                	sd	s0,16(sp)
    80004046:	e426                	sd	s1,8(sp)
    80004048:	e04a                	sd	s2,0(sp)
    8000404a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000404c:	00018917          	auipc	s2,0x18
    80004050:	61c90913          	addi	s2,s2,1564 # 8001c668 <log>
    80004054:	01892583          	lw	a1,24(s2)
    80004058:	02892503          	lw	a0,40(s2)
    8000405c:	fffff097          	auipc	ra,0xfffff
    80004060:	e34080e7          	jalr	-460(ra) # 80002e90 <bread>
    80004064:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004066:	02c92683          	lw	a3,44(s2)
    8000406a:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000406c:	02d05763          	blez	a3,8000409a <write_head+0x5a>
    80004070:	00018797          	auipc	a5,0x18
    80004074:	62878793          	addi	a5,a5,1576 # 8001c698 <log+0x30>
    80004078:	05c50713          	addi	a4,a0,92
    8000407c:	36fd                	addiw	a3,a3,-1
    8000407e:	1682                	slli	a3,a3,0x20
    80004080:	9281                	srli	a3,a3,0x20
    80004082:	068a                	slli	a3,a3,0x2
    80004084:	00018617          	auipc	a2,0x18
    80004088:	61860613          	addi	a2,a2,1560 # 8001c69c <log+0x34>
    8000408c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000408e:	4390                	lw	a2,0(a5)
    80004090:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004092:	0791                	addi	a5,a5,4
    80004094:	0711                	addi	a4,a4,4
    80004096:	fed79ce3          	bne	a5,a3,8000408e <write_head+0x4e>
  }
  bwrite(buf);
    8000409a:	8526                	mv	a0,s1
    8000409c:	fffff097          	auipc	ra,0xfffff
    800040a0:	ef8080e7          	jalr	-264(ra) # 80002f94 <bwrite>
  brelse(buf);
    800040a4:	8526                	mv	a0,s1
    800040a6:	fffff097          	auipc	ra,0xfffff
    800040aa:	f2c080e7          	jalr	-212(ra) # 80002fd2 <brelse>
}
    800040ae:	60e2                	ld	ra,24(sp)
    800040b0:	6442                	ld	s0,16(sp)
    800040b2:	64a2                	ld	s1,8(sp)
    800040b4:	6902                	ld	s2,0(sp)
    800040b6:	6105                	addi	sp,sp,32
    800040b8:	8082                	ret

00000000800040ba <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040ba:	00018797          	auipc	a5,0x18
    800040be:	5ae78793          	addi	a5,a5,1454 # 8001c668 <log>
    800040c2:	57dc                	lw	a5,44(a5)
    800040c4:	0af05d63          	blez	a5,8000417e <install_trans+0xc4>
{
    800040c8:	7139                	addi	sp,sp,-64
    800040ca:	fc06                	sd	ra,56(sp)
    800040cc:	f822                	sd	s0,48(sp)
    800040ce:	f426                	sd	s1,40(sp)
    800040d0:	f04a                	sd	s2,32(sp)
    800040d2:	ec4e                	sd	s3,24(sp)
    800040d4:	e852                	sd	s4,16(sp)
    800040d6:	e456                	sd	s5,8(sp)
    800040d8:	e05a                	sd	s6,0(sp)
    800040da:	0080                	addi	s0,sp,64
    800040dc:	8b2a                	mv	s6,a0
    800040de:	00018a17          	auipc	s4,0x18
    800040e2:	5baa0a13          	addi	s4,s4,1466 # 8001c698 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040e6:	4981                	li	s3,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040e8:	00018917          	auipc	s2,0x18
    800040ec:	58090913          	addi	s2,s2,1408 # 8001c668 <log>
    800040f0:	a035                	j	8000411c <install_trans+0x62>
      bunpin(dbuf);
    800040f2:	8526                	mv	a0,s1
    800040f4:	fffff097          	auipc	ra,0xfffff
    800040f8:	fb8080e7          	jalr	-72(ra) # 800030ac <bunpin>
    brelse(lbuf);
    800040fc:	8556                	mv	a0,s5
    800040fe:	fffff097          	auipc	ra,0xfffff
    80004102:	ed4080e7          	jalr	-300(ra) # 80002fd2 <brelse>
    brelse(dbuf);
    80004106:	8526                	mv	a0,s1
    80004108:	fffff097          	auipc	ra,0xfffff
    8000410c:	eca080e7          	jalr	-310(ra) # 80002fd2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004110:	2985                	addiw	s3,s3,1
    80004112:	0a11                	addi	s4,s4,4
    80004114:	02c92783          	lw	a5,44(s2)
    80004118:	04f9d963          	ble	a5,s3,8000416a <install_trans+0xb0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000411c:	01892583          	lw	a1,24(s2)
    80004120:	013585bb          	addw	a1,a1,s3
    80004124:	2585                	addiw	a1,a1,1
    80004126:	02892503          	lw	a0,40(s2)
    8000412a:	fffff097          	auipc	ra,0xfffff
    8000412e:	d66080e7          	jalr	-666(ra) # 80002e90 <bread>
    80004132:	8aaa                	mv	s5,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004134:	000a2583          	lw	a1,0(s4)
    80004138:	02892503          	lw	a0,40(s2)
    8000413c:	fffff097          	auipc	ra,0xfffff
    80004140:	d54080e7          	jalr	-684(ra) # 80002e90 <bread>
    80004144:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004146:	40000613          	li	a2,1024
    8000414a:	058a8593          	addi	a1,s5,88
    8000414e:	05850513          	addi	a0,a0,88
    80004152:	ffffd097          	auipc	ra,0xffffd
    80004156:	c3a080e7          	jalr	-966(ra) # 80000d8c <memmove>
    bwrite(dbuf);  // write dst to disk
    8000415a:	8526                	mv	a0,s1
    8000415c:	fffff097          	auipc	ra,0xfffff
    80004160:	e38080e7          	jalr	-456(ra) # 80002f94 <bwrite>
    if(recovering == 0)
    80004164:	f80b1ce3          	bnez	s6,800040fc <install_trans+0x42>
    80004168:	b769                	j	800040f2 <install_trans+0x38>
}
    8000416a:	70e2                	ld	ra,56(sp)
    8000416c:	7442                	ld	s0,48(sp)
    8000416e:	74a2                	ld	s1,40(sp)
    80004170:	7902                	ld	s2,32(sp)
    80004172:	69e2                	ld	s3,24(sp)
    80004174:	6a42                	ld	s4,16(sp)
    80004176:	6aa2                	ld	s5,8(sp)
    80004178:	6b02                	ld	s6,0(sp)
    8000417a:	6121                	addi	sp,sp,64
    8000417c:	8082                	ret
    8000417e:	8082                	ret

0000000080004180 <initlog>:
{
    80004180:	7179                	addi	sp,sp,-48
    80004182:	f406                	sd	ra,40(sp)
    80004184:	f022                	sd	s0,32(sp)
    80004186:	ec26                	sd	s1,24(sp)
    80004188:	e84a                	sd	s2,16(sp)
    8000418a:	e44e                	sd	s3,8(sp)
    8000418c:	1800                	addi	s0,sp,48
    8000418e:	892a                	mv	s2,a0
    80004190:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004192:	00018497          	auipc	s1,0x18
    80004196:	4d648493          	addi	s1,s1,1238 # 8001c668 <log>
    8000419a:	00004597          	auipc	a1,0x4
    8000419e:	46658593          	addi	a1,a1,1126 # 80008600 <syscalls+0x208>
    800041a2:	8526                	mv	a0,s1
    800041a4:	ffffd097          	auipc	ra,0xffffd
    800041a8:	9f0080e7          	jalr	-1552(ra) # 80000b94 <initlock>
  log.start = sb->logstart;
    800041ac:	0149a583          	lw	a1,20(s3)
    800041b0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041b2:	0109a783          	lw	a5,16(s3)
    800041b6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041b8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041bc:	854a                	mv	a0,s2
    800041be:	fffff097          	auipc	ra,0xfffff
    800041c2:	cd2080e7          	jalr	-814(ra) # 80002e90 <bread>
  log.lh.n = lh->n;
    800041c6:	4d3c                	lw	a5,88(a0)
    800041c8:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041ca:	02f05563          	blez	a5,800041f4 <initlog+0x74>
    800041ce:	05c50713          	addi	a4,a0,92
    800041d2:	00018697          	auipc	a3,0x18
    800041d6:	4c668693          	addi	a3,a3,1222 # 8001c698 <log+0x30>
    800041da:	37fd                	addiw	a5,a5,-1
    800041dc:	1782                	slli	a5,a5,0x20
    800041de:	9381                	srli	a5,a5,0x20
    800041e0:	078a                	slli	a5,a5,0x2
    800041e2:	06050613          	addi	a2,a0,96
    800041e6:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800041e8:	4310                	lw	a2,0(a4)
    800041ea:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800041ec:	0711                	addi	a4,a4,4
    800041ee:	0691                	addi	a3,a3,4
    800041f0:	fef71ce3          	bne	a4,a5,800041e8 <initlog+0x68>
  brelse(buf);
    800041f4:	fffff097          	auipc	ra,0xfffff
    800041f8:	dde080e7          	jalr	-546(ra) # 80002fd2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800041fc:	4505                	li	a0,1
    800041fe:	00000097          	auipc	ra,0x0
    80004202:	ebc080e7          	jalr	-324(ra) # 800040ba <install_trans>
  log.lh.n = 0;
    80004206:	00018797          	auipc	a5,0x18
    8000420a:	4807a723          	sw	zero,1166(a5) # 8001c694 <log+0x2c>
  write_head(); // clear the log
    8000420e:	00000097          	auipc	ra,0x0
    80004212:	e32080e7          	jalr	-462(ra) # 80004040 <write_head>
}
    80004216:	70a2                	ld	ra,40(sp)
    80004218:	7402                	ld	s0,32(sp)
    8000421a:	64e2                	ld	s1,24(sp)
    8000421c:	6942                	ld	s2,16(sp)
    8000421e:	69a2                	ld	s3,8(sp)
    80004220:	6145                	addi	sp,sp,48
    80004222:	8082                	ret

0000000080004224 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004224:	1101                	addi	sp,sp,-32
    80004226:	ec06                	sd	ra,24(sp)
    80004228:	e822                	sd	s0,16(sp)
    8000422a:	e426                	sd	s1,8(sp)
    8000422c:	e04a                	sd	s2,0(sp)
    8000422e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004230:	00018517          	auipc	a0,0x18
    80004234:	43850513          	addi	a0,a0,1080 # 8001c668 <log>
    80004238:	ffffd097          	auipc	ra,0xffffd
    8000423c:	9ec080e7          	jalr	-1556(ra) # 80000c24 <acquire>
  while(1){
    if(log.committing){
    80004240:	00018497          	auipc	s1,0x18
    80004244:	42848493          	addi	s1,s1,1064 # 8001c668 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004248:	4979                	li	s2,30
    8000424a:	a039                	j	80004258 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000424c:	85a6                	mv	a1,s1
    8000424e:	8526                	mv	a0,s1
    80004250:	ffffe097          	auipc	ra,0xffffe
    80004254:	012080e7          	jalr	18(ra) # 80002262 <sleep>
    if(log.committing){
    80004258:	50dc                	lw	a5,36(s1)
    8000425a:	fbed                	bnez	a5,8000424c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000425c:	509c                	lw	a5,32(s1)
    8000425e:	0017871b          	addiw	a4,a5,1
    80004262:	0007069b          	sext.w	a3,a4
    80004266:	0027179b          	slliw	a5,a4,0x2
    8000426a:	9fb9                	addw	a5,a5,a4
    8000426c:	0017979b          	slliw	a5,a5,0x1
    80004270:	54d8                	lw	a4,44(s1)
    80004272:	9fb9                	addw	a5,a5,a4
    80004274:	00f95963          	ble	a5,s2,80004286 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004278:	85a6                	mv	a1,s1
    8000427a:	8526                	mv	a0,s1
    8000427c:	ffffe097          	auipc	ra,0xffffe
    80004280:	fe6080e7          	jalr	-26(ra) # 80002262 <sleep>
    80004284:	bfd1                	j	80004258 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004286:	00018517          	auipc	a0,0x18
    8000428a:	3e250513          	addi	a0,a0,994 # 8001c668 <log>
    8000428e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004290:	ffffd097          	auipc	ra,0xffffd
    80004294:	a48080e7          	jalr	-1464(ra) # 80000cd8 <release>
      break;
    }
  }
}
    80004298:	60e2                	ld	ra,24(sp)
    8000429a:	6442                	ld	s0,16(sp)
    8000429c:	64a2                	ld	s1,8(sp)
    8000429e:	6902                	ld	s2,0(sp)
    800042a0:	6105                	addi	sp,sp,32
    800042a2:	8082                	ret

00000000800042a4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042a4:	7139                	addi	sp,sp,-64
    800042a6:	fc06                	sd	ra,56(sp)
    800042a8:	f822                	sd	s0,48(sp)
    800042aa:	f426                	sd	s1,40(sp)
    800042ac:	f04a                	sd	s2,32(sp)
    800042ae:	ec4e                	sd	s3,24(sp)
    800042b0:	e852                	sd	s4,16(sp)
    800042b2:	e456                	sd	s5,8(sp)
    800042b4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042b6:	00018917          	auipc	s2,0x18
    800042ba:	3b290913          	addi	s2,s2,946 # 8001c668 <log>
    800042be:	854a                	mv	a0,s2
    800042c0:	ffffd097          	auipc	ra,0xffffd
    800042c4:	964080e7          	jalr	-1692(ra) # 80000c24 <acquire>
  log.outstanding -= 1;
    800042c8:	02092783          	lw	a5,32(s2)
    800042cc:	37fd                	addiw	a5,a5,-1
    800042ce:	0007849b          	sext.w	s1,a5
    800042d2:	02f92023          	sw	a5,32(s2)
  if(log.committing)
    800042d6:	02492783          	lw	a5,36(s2)
    800042da:	eba1                	bnez	a5,8000432a <end_op+0x86>
    panic("log.committing");
  if(log.outstanding == 0){
    800042dc:	ecb9                	bnez	s1,8000433a <end_op+0x96>
    do_commit = 1;
    log.committing = 1;
    800042de:	00018917          	auipc	s2,0x18
    800042e2:	38a90913          	addi	s2,s2,906 # 8001c668 <log>
    800042e6:	4785                	li	a5,1
    800042e8:	02f92223          	sw	a5,36(s2)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042ec:	854a                	mv	a0,s2
    800042ee:	ffffd097          	auipc	ra,0xffffd
    800042f2:	9ea080e7          	jalr	-1558(ra) # 80000cd8 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800042f6:	02c92783          	lw	a5,44(s2)
    800042fa:	06f04763          	bgtz	a5,80004368 <end_op+0xc4>
    acquire(&log.lock);
    800042fe:	00018497          	auipc	s1,0x18
    80004302:	36a48493          	addi	s1,s1,874 # 8001c668 <log>
    80004306:	8526                	mv	a0,s1
    80004308:	ffffd097          	auipc	ra,0xffffd
    8000430c:	91c080e7          	jalr	-1764(ra) # 80000c24 <acquire>
    log.committing = 0;
    80004310:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004314:	8526                	mv	a0,s1
    80004316:	ffffe097          	auipc	ra,0xffffe
    8000431a:	0d2080e7          	jalr	210(ra) # 800023e8 <wakeup>
    release(&log.lock);
    8000431e:	8526                	mv	a0,s1
    80004320:	ffffd097          	auipc	ra,0xffffd
    80004324:	9b8080e7          	jalr	-1608(ra) # 80000cd8 <release>
}
    80004328:	a03d                	j	80004356 <end_op+0xb2>
    panic("log.committing");
    8000432a:	00004517          	auipc	a0,0x4
    8000432e:	2de50513          	addi	a0,a0,734 # 80008608 <syscalls+0x210>
    80004332:	ffffc097          	auipc	ra,0xffffc
    80004336:	226080e7          	jalr	550(ra) # 80000558 <panic>
    wakeup(&log);
    8000433a:	00018497          	auipc	s1,0x18
    8000433e:	32e48493          	addi	s1,s1,814 # 8001c668 <log>
    80004342:	8526                	mv	a0,s1
    80004344:	ffffe097          	auipc	ra,0xffffe
    80004348:	0a4080e7          	jalr	164(ra) # 800023e8 <wakeup>
  release(&log.lock);
    8000434c:	8526                	mv	a0,s1
    8000434e:	ffffd097          	auipc	ra,0xffffd
    80004352:	98a080e7          	jalr	-1654(ra) # 80000cd8 <release>
}
    80004356:	70e2                	ld	ra,56(sp)
    80004358:	7442                	ld	s0,48(sp)
    8000435a:	74a2                	ld	s1,40(sp)
    8000435c:	7902                	ld	s2,32(sp)
    8000435e:	69e2                	ld	s3,24(sp)
    80004360:	6a42                	ld	s4,16(sp)
    80004362:	6aa2                	ld	s5,8(sp)
    80004364:	6121                	addi	sp,sp,64
    80004366:	8082                	ret
    80004368:	00018a17          	auipc	s4,0x18
    8000436c:	330a0a13          	addi	s4,s4,816 # 8001c698 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004370:	00018917          	auipc	s2,0x18
    80004374:	2f890913          	addi	s2,s2,760 # 8001c668 <log>
    80004378:	01892583          	lw	a1,24(s2)
    8000437c:	9da5                	addw	a1,a1,s1
    8000437e:	2585                	addiw	a1,a1,1
    80004380:	02892503          	lw	a0,40(s2)
    80004384:	fffff097          	auipc	ra,0xfffff
    80004388:	b0c080e7          	jalr	-1268(ra) # 80002e90 <bread>
    8000438c:	89aa                	mv	s3,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000438e:	000a2583          	lw	a1,0(s4)
    80004392:	02892503          	lw	a0,40(s2)
    80004396:	fffff097          	auipc	ra,0xfffff
    8000439a:	afa080e7          	jalr	-1286(ra) # 80002e90 <bread>
    8000439e:	8aaa                	mv	s5,a0
    memmove(to->data, from->data, BSIZE);
    800043a0:	40000613          	li	a2,1024
    800043a4:	05850593          	addi	a1,a0,88
    800043a8:	05898513          	addi	a0,s3,88
    800043ac:	ffffd097          	auipc	ra,0xffffd
    800043b0:	9e0080e7          	jalr	-1568(ra) # 80000d8c <memmove>
    bwrite(to);  // write the log
    800043b4:	854e                	mv	a0,s3
    800043b6:	fffff097          	auipc	ra,0xfffff
    800043ba:	bde080e7          	jalr	-1058(ra) # 80002f94 <bwrite>
    brelse(from);
    800043be:	8556                	mv	a0,s5
    800043c0:	fffff097          	auipc	ra,0xfffff
    800043c4:	c12080e7          	jalr	-1006(ra) # 80002fd2 <brelse>
    brelse(to);
    800043c8:	854e                	mv	a0,s3
    800043ca:	fffff097          	auipc	ra,0xfffff
    800043ce:	c08080e7          	jalr	-1016(ra) # 80002fd2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043d2:	2485                	addiw	s1,s1,1
    800043d4:	0a11                	addi	s4,s4,4
    800043d6:	02c92783          	lw	a5,44(s2)
    800043da:	f8f4cfe3          	blt	s1,a5,80004378 <end_op+0xd4>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043de:	00000097          	auipc	ra,0x0
    800043e2:	c62080e7          	jalr	-926(ra) # 80004040 <write_head>
    install_trans(0); // Now install writes to home locations
    800043e6:	4501                	li	a0,0
    800043e8:	00000097          	auipc	ra,0x0
    800043ec:	cd2080e7          	jalr	-814(ra) # 800040ba <install_trans>
    log.lh.n = 0;
    800043f0:	00018797          	auipc	a5,0x18
    800043f4:	2a07a223          	sw	zero,676(a5) # 8001c694 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800043f8:	00000097          	auipc	ra,0x0
    800043fc:	c48080e7          	jalr	-952(ra) # 80004040 <write_head>
    80004400:	bdfd                	j	800042fe <end_op+0x5a>

0000000080004402 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004402:	1101                	addi	sp,sp,-32
    80004404:	ec06                	sd	ra,24(sp)
    80004406:	e822                	sd	s0,16(sp)
    80004408:	e426                	sd	s1,8(sp)
    8000440a:	e04a                	sd	s2,0(sp)
    8000440c:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000440e:	00018797          	auipc	a5,0x18
    80004412:	25a78793          	addi	a5,a5,602 # 8001c668 <log>
    80004416:	57d8                	lw	a4,44(a5)
    80004418:	47f5                	li	a5,29
    8000441a:	08e7c563          	blt	a5,a4,800044a4 <log_write+0xa2>
    8000441e:	892a                	mv	s2,a0
    80004420:	00018797          	auipc	a5,0x18
    80004424:	24878793          	addi	a5,a5,584 # 8001c668 <log>
    80004428:	4fdc                	lw	a5,28(a5)
    8000442a:	37fd                	addiw	a5,a5,-1
    8000442c:	06f75c63          	ble	a5,a4,800044a4 <log_write+0xa2>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004430:	00018797          	auipc	a5,0x18
    80004434:	23878793          	addi	a5,a5,568 # 8001c668 <log>
    80004438:	539c                	lw	a5,32(a5)
    8000443a:	06f05d63          	blez	a5,800044b4 <log_write+0xb2>
    panic("log_write outside of trans");

  acquire(&log.lock);
    8000443e:	00018497          	auipc	s1,0x18
    80004442:	22a48493          	addi	s1,s1,554 # 8001c668 <log>
    80004446:	8526                	mv	a0,s1
    80004448:	ffffc097          	auipc	ra,0xffffc
    8000444c:	7dc080e7          	jalr	2012(ra) # 80000c24 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004450:	54d0                	lw	a2,44(s1)
    80004452:	0ac05063          	blez	a2,800044f2 <log_write+0xf0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004456:	00c92583          	lw	a1,12(s2)
    8000445a:	589c                	lw	a5,48(s1)
    8000445c:	0ab78363          	beq	a5,a1,80004502 <log_write+0x100>
    80004460:	00018717          	auipc	a4,0x18
    80004464:	23c70713          	addi	a4,a4,572 # 8001c69c <log+0x34>
  for (i = 0; i < log.lh.n; i++) {
    80004468:	4781                	li	a5,0
    8000446a:	2785                	addiw	a5,a5,1
    8000446c:	04c78c63          	beq	a5,a2,800044c4 <log_write+0xc2>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004470:	4314                	lw	a3,0(a4)
    80004472:	0711                	addi	a4,a4,4
    80004474:	feb69be3          	bne	a3,a1,8000446a <log_write+0x68>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004478:	07a1                	addi	a5,a5,8
    8000447a:	078a                	slli	a5,a5,0x2
    8000447c:	00018717          	auipc	a4,0x18
    80004480:	1ec70713          	addi	a4,a4,492 # 8001c668 <log>
    80004484:	97ba                	add	a5,a5,a4
    80004486:	cb8c                	sw	a1,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    log.lh.n++;
  }
  release(&log.lock);
    80004488:	00018517          	auipc	a0,0x18
    8000448c:	1e050513          	addi	a0,a0,480 # 8001c668 <log>
    80004490:	ffffd097          	auipc	ra,0xffffd
    80004494:	848080e7          	jalr	-1976(ra) # 80000cd8 <release>
}
    80004498:	60e2                	ld	ra,24(sp)
    8000449a:	6442                	ld	s0,16(sp)
    8000449c:	64a2                	ld	s1,8(sp)
    8000449e:	6902                	ld	s2,0(sp)
    800044a0:	6105                	addi	sp,sp,32
    800044a2:	8082                	ret
    panic("too big a transaction");
    800044a4:	00004517          	auipc	a0,0x4
    800044a8:	17450513          	addi	a0,a0,372 # 80008618 <syscalls+0x220>
    800044ac:	ffffc097          	auipc	ra,0xffffc
    800044b0:	0ac080e7          	jalr	172(ra) # 80000558 <panic>
    panic("log_write outside of trans");
    800044b4:	00004517          	auipc	a0,0x4
    800044b8:	17c50513          	addi	a0,a0,380 # 80008630 <syscalls+0x238>
    800044bc:	ffffc097          	auipc	ra,0xffffc
    800044c0:	09c080e7          	jalr	156(ra) # 80000558 <panic>
  log.lh.block[i] = b->blockno;
    800044c4:	0621                	addi	a2,a2,8
    800044c6:	060a                	slli	a2,a2,0x2
    800044c8:	00018797          	auipc	a5,0x18
    800044cc:	1a078793          	addi	a5,a5,416 # 8001c668 <log>
    800044d0:	963e                	add	a2,a2,a5
    800044d2:	00c92783          	lw	a5,12(s2)
    800044d6:	ca1c                	sw	a5,16(a2)
    bpin(b);
    800044d8:	854a                	mv	a0,s2
    800044da:	fffff097          	auipc	ra,0xfffff
    800044de:	b96080e7          	jalr	-1130(ra) # 80003070 <bpin>
    log.lh.n++;
    800044e2:	00018717          	auipc	a4,0x18
    800044e6:	18670713          	addi	a4,a4,390 # 8001c668 <log>
    800044ea:	575c                	lw	a5,44(a4)
    800044ec:	2785                	addiw	a5,a5,1
    800044ee:	d75c                	sw	a5,44(a4)
    800044f0:	bf61                	j	80004488 <log_write+0x86>
  log.lh.block[i] = b->blockno;
    800044f2:	00c92783          	lw	a5,12(s2)
    800044f6:	00018717          	auipc	a4,0x18
    800044fa:	1af72123          	sw	a5,418(a4) # 8001c698 <log+0x30>
  if (i == log.lh.n) {  // Add new block to log?
    800044fe:	f649                	bnez	a2,80004488 <log_write+0x86>
    80004500:	bfe1                	j	800044d8 <log_write+0xd6>
  for (i = 0; i < log.lh.n; i++) {
    80004502:	4781                	li	a5,0
    80004504:	bf95                	j	80004478 <log_write+0x76>

0000000080004506 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004506:	1101                	addi	sp,sp,-32
    80004508:	ec06                	sd	ra,24(sp)
    8000450a:	e822                	sd	s0,16(sp)
    8000450c:	e426                	sd	s1,8(sp)
    8000450e:	e04a                	sd	s2,0(sp)
    80004510:	1000                	addi	s0,sp,32
    80004512:	84aa                	mv	s1,a0
    80004514:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004516:	00004597          	auipc	a1,0x4
    8000451a:	13a58593          	addi	a1,a1,314 # 80008650 <syscalls+0x258>
    8000451e:	0521                	addi	a0,a0,8
    80004520:	ffffc097          	auipc	ra,0xffffc
    80004524:	674080e7          	jalr	1652(ra) # 80000b94 <initlock>
  lk->name = name;
    80004528:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000452c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004530:	0204a423          	sw	zero,40(s1)
}
    80004534:	60e2                	ld	ra,24(sp)
    80004536:	6442                	ld	s0,16(sp)
    80004538:	64a2                	ld	s1,8(sp)
    8000453a:	6902                	ld	s2,0(sp)
    8000453c:	6105                	addi	sp,sp,32
    8000453e:	8082                	ret

0000000080004540 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004540:	1101                	addi	sp,sp,-32
    80004542:	ec06                	sd	ra,24(sp)
    80004544:	e822                	sd	s0,16(sp)
    80004546:	e426                	sd	s1,8(sp)
    80004548:	e04a                	sd	s2,0(sp)
    8000454a:	1000                	addi	s0,sp,32
    8000454c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000454e:	00850913          	addi	s2,a0,8
    80004552:	854a                	mv	a0,s2
    80004554:	ffffc097          	auipc	ra,0xffffc
    80004558:	6d0080e7          	jalr	1744(ra) # 80000c24 <acquire>
  while (lk->locked) {
    8000455c:	409c                	lw	a5,0(s1)
    8000455e:	cb89                	beqz	a5,80004570 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004560:	85ca                	mv	a1,s2
    80004562:	8526                	mv	a0,s1
    80004564:	ffffe097          	auipc	ra,0xffffe
    80004568:	cfe080e7          	jalr	-770(ra) # 80002262 <sleep>
  while (lk->locked) {
    8000456c:	409c                	lw	a5,0(s1)
    8000456e:	fbed                	bnez	a5,80004560 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004570:	4785                	li	a5,1
    80004572:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004574:	ffffd097          	auipc	ra,0xffffd
    80004578:	4d4080e7          	jalr	1236(ra) # 80001a48 <myproc>
    8000457c:	5d1c                	lw	a5,56(a0)
    8000457e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004580:	854a                	mv	a0,s2
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	756080e7          	jalr	1878(ra) # 80000cd8 <release>
}
    8000458a:	60e2                	ld	ra,24(sp)
    8000458c:	6442                	ld	s0,16(sp)
    8000458e:	64a2                	ld	s1,8(sp)
    80004590:	6902                	ld	s2,0(sp)
    80004592:	6105                	addi	sp,sp,32
    80004594:	8082                	ret

0000000080004596 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004596:	1101                	addi	sp,sp,-32
    80004598:	ec06                	sd	ra,24(sp)
    8000459a:	e822                	sd	s0,16(sp)
    8000459c:	e426                	sd	s1,8(sp)
    8000459e:	e04a                	sd	s2,0(sp)
    800045a0:	1000                	addi	s0,sp,32
    800045a2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045a4:	00850913          	addi	s2,a0,8
    800045a8:	854a                	mv	a0,s2
    800045aa:	ffffc097          	auipc	ra,0xffffc
    800045ae:	67a080e7          	jalr	1658(ra) # 80000c24 <acquire>
  lk->locked = 0;
    800045b2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045b6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800045ba:	8526                	mv	a0,s1
    800045bc:	ffffe097          	auipc	ra,0xffffe
    800045c0:	e2c080e7          	jalr	-468(ra) # 800023e8 <wakeup>
  release(&lk->lk);
    800045c4:	854a                	mv	a0,s2
    800045c6:	ffffc097          	auipc	ra,0xffffc
    800045ca:	712080e7          	jalr	1810(ra) # 80000cd8 <release>
}
    800045ce:	60e2                	ld	ra,24(sp)
    800045d0:	6442                	ld	s0,16(sp)
    800045d2:	64a2                	ld	s1,8(sp)
    800045d4:	6902                	ld	s2,0(sp)
    800045d6:	6105                	addi	sp,sp,32
    800045d8:	8082                	ret

00000000800045da <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045da:	7179                	addi	sp,sp,-48
    800045dc:	f406                	sd	ra,40(sp)
    800045de:	f022                	sd	s0,32(sp)
    800045e0:	ec26                	sd	s1,24(sp)
    800045e2:	e84a                	sd	s2,16(sp)
    800045e4:	e44e                	sd	s3,8(sp)
    800045e6:	1800                	addi	s0,sp,48
    800045e8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800045ea:	00850913          	addi	s2,a0,8
    800045ee:	854a                	mv	a0,s2
    800045f0:	ffffc097          	auipc	ra,0xffffc
    800045f4:	634080e7          	jalr	1588(ra) # 80000c24 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800045f8:	409c                	lw	a5,0(s1)
    800045fa:	ef99                	bnez	a5,80004618 <holdingsleep+0x3e>
    800045fc:	4481                	li	s1,0
  release(&lk->lk);
    800045fe:	854a                	mv	a0,s2
    80004600:	ffffc097          	auipc	ra,0xffffc
    80004604:	6d8080e7          	jalr	1752(ra) # 80000cd8 <release>
  return r;
}
    80004608:	8526                	mv	a0,s1
    8000460a:	70a2                	ld	ra,40(sp)
    8000460c:	7402                	ld	s0,32(sp)
    8000460e:	64e2                	ld	s1,24(sp)
    80004610:	6942                	ld	s2,16(sp)
    80004612:	69a2                	ld	s3,8(sp)
    80004614:	6145                	addi	sp,sp,48
    80004616:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004618:	0284a983          	lw	s3,40(s1)
    8000461c:	ffffd097          	auipc	ra,0xffffd
    80004620:	42c080e7          	jalr	1068(ra) # 80001a48 <myproc>
    80004624:	5d04                	lw	s1,56(a0)
    80004626:	413484b3          	sub	s1,s1,s3
    8000462a:	0014b493          	seqz	s1,s1
    8000462e:	bfc1                	j	800045fe <holdingsleep+0x24>

0000000080004630 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004630:	1141                	addi	sp,sp,-16
    80004632:	e406                	sd	ra,8(sp)
    80004634:	e022                	sd	s0,0(sp)
    80004636:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004638:	00004597          	auipc	a1,0x4
    8000463c:	02858593          	addi	a1,a1,40 # 80008660 <syscalls+0x268>
    80004640:	00018517          	auipc	a0,0x18
    80004644:	17050513          	addi	a0,a0,368 # 8001c7b0 <ftable>
    80004648:	ffffc097          	auipc	ra,0xffffc
    8000464c:	54c080e7          	jalr	1356(ra) # 80000b94 <initlock>
}
    80004650:	60a2                	ld	ra,8(sp)
    80004652:	6402                	ld	s0,0(sp)
    80004654:	0141                	addi	sp,sp,16
    80004656:	8082                	ret

0000000080004658 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004658:	1101                	addi	sp,sp,-32
    8000465a:	ec06                	sd	ra,24(sp)
    8000465c:	e822                	sd	s0,16(sp)
    8000465e:	e426                	sd	s1,8(sp)
    80004660:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004662:	00018517          	auipc	a0,0x18
    80004666:	14e50513          	addi	a0,a0,334 # 8001c7b0 <ftable>
    8000466a:	ffffc097          	auipc	ra,0xffffc
    8000466e:	5ba080e7          	jalr	1466(ra) # 80000c24 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
    80004672:	00018797          	auipc	a5,0x18
    80004676:	13e78793          	addi	a5,a5,318 # 8001c7b0 <ftable>
    8000467a:	4fdc                	lw	a5,28(a5)
    8000467c:	cb8d                	beqz	a5,800046ae <filealloc+0x56>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000467e:	00018497          	auipc	s1,0x18
    80004682:	17248493          	addi	s1,s1,370 # 8001c7f0 <ftable+0x40>
    80004686:	00019717          	auipc	a4,0x19
    8000468a:	0e270713          	addi	a4,a4,226 # 8001d768 <ftable+0xfb8>
    if(f->ref == 0){
    8000468e:	40dc                	lw	a5,4(s1)
    80004690:	c39d                	beqz	a5,800046b6 <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004692:	02848493          	addi	s1,s1,40
    80004696:	fee49ce3          	bne	s1,a4,8000468e <filealloc+0x36>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000469a:	00018517          	auipc	a0,0x18
    8000469e:	11650513          	addi	a0,a0,278 # 8001c7b0 <ftable>
    800046a2:	ffffc097          	auipc	ra,0xffffc
    800046a6:	636080e7          	jalr	1590(ra) # 80000cd8 <release>
  return 0;
    800046aa:	4481                	li	s1,0
    800046ac:	a839                	j	800046ca <filealloc+0x72>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046ae:	00018497          	auipc	s1,0x18
    800046b2:	11a48493          	addi	s1,s1,282 # 8001c7c8 <ftable+0x18>
      f->ref = 1;
    800046b6:	4785                	li	a5,1
    800046b8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046ba:	00018517          	auipc	a0,0x18
    800046be:	0f650513          	addi	a0,a0,246 # 8001c7b0 <ftable>
    800046c2:	ffffc097          	auipc	ra,0xffffc
    800046c6:	616080e7          	jalr	1558(ra) # 80000cd8 <release>
}
    800046ca:	8526                	mv	a0,s1
    800046cc:	60e2                	ld	ra,24(sp)
    800046ce:	6442                	ld	s0,16(sp)
    800046d0:	64a2                	ld	s1,8(sp)
    800046d2:	6105                	addi	sp,sp,32
    800046d4:	8082                	ret

00000000800046d6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046d6:	1101                	addi	sp,sp,-32
    800046d8:	ec06                	sd	ra,24(sp)
    800046da:	e822                	sd	s0,16(sp)
    800046dc:	e426                	sd	s1,8(sp)
    800046de:	1000                	addi	s0,sp,32
    800046e0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046e2:	00018517          	auipc	a0,0x18
    800046e6:	0ce50513          	addi	a0,a0,206 # 8001c7b0 <ftable>
    800046ea:	ffffc097          	auipc	ra,0xffffc
    800046ee:	53a080e7          	jalr	1338(ra) # 80000c24 <acquire>
  if(f->ref < 1)
    800046f2:	40dc                	lw	a5,4(s1)
    800046f4:	02f05263          	blez	a5,80004718 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800046f8:	2785                	addiw	a5,a5,1
    800046fa:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800046fc:	00018517          	auipc	a0,0x18
    80004700:	0b450513          	addi	a0,a0,180 # 8001c7b0 <ftable>
    80004704:	ffffc097          	auipc	ra,0xffffc
    80004708:	5d4080e7          	jalr	1492(ra) # 80000cd8 <release>
  return f;
}
    8000470c:	8526                	mv	a0,s1
    8000470e:	60e2                	ld	ra,24(sp)
    80004710:	6442                	ld	s0,16(sp)
    80004712:	64a2                	ld	s1,8(sp)
    80004714:	6105                	addi	sp,sp,32
    80004716:	8082                	ret
    panic("filedup");
    80004718:	00004517          	auipc	a0,0x4
    8000471c:	f5050513          	addi	a0,a0,-176 # 80008668 <syscalls+0x270>
    80004720:	ffffc097          	auipc	ra,0xffffc
    80004724:	e38080e7          	jalr	-456(ra) # 80000558 <panic>

0000000080004728 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004728:	7139                	addi	sp,sp,-64
    8000472a:	fc06                	sd	ra,56(sp)
    8000472c:	f822                	sd	s0,48(sp)
    8000472e:	f426                	sd	s1,40(sp)
    80004730:	f04a                	sd	s2,32(sp)
    80004732:	ec4e                	sd	s3,24(sp)
    80004734:	e852                	sd	s4,16(sp)
    80004736:	e456                	sd	s5,8(sp)
    80004738:	0080                	addi	s0,sp,64
    8000473a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000473c:	00018517          	auipc	a0,0x18
    80004740:	07450513          	addi	a0,a0,116 # 8001c7b0 <ftable>
    80004744:	ffffc097          	auipc	ra,0xffffc
    80004748:	4e0080e7          	jalr	1248(ra) # 80000c24 <acquire>
  if(f->ref < 1)
    8000474c:	40dc                	lw	a5,4(s1)
    8000474e:	06f05163          	blez	a5,800047b0 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004752:	37fd                	addiw	a5,a5,-1
    80004754:	0007871b          	sext.w	a4,a5
    80004758:	c0dc                	sw	a5,4(s1)
    8000475a:	06e04363          	bgtz	a4,800047c0 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000475e:	0004a903          	lw	s2,0(s1)
    80004762:	0094ca83          	lbu	s5,9(s1)
    80004766:	0104ba03          	ld	s4,16(s1)
    8000476a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000476e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004772:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004776:	00018517          	auipc	a0,0x18
    8000477a:	03a50513          	addi	a0,a0,58 # 8001c7b0 <ftable>
    8000477e:	ffffc097          	auipc	ra,0xffffc
    80004782:	55a080e7          	jalr	1370(ra) # 80000cd8 <release>

  if(ff.type == FD_PIPE){
    80004786:	4785                	li	a5,1
    80004788:	04f90d63          	beq	s2,a5,800047e2 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000478c:	3979                	addiw	s2,s2,-2
    8000478e:	4785                	li	a5,1
    80004790:	0527e063          	bltu	a5,s2,800047d0 <fileclose+0xa8>
    begin_op();
    80004794:	00000097          	auipc	ra,0x0
    80004798:	a90080e7          	jalr	-1392(ra) # 80004224 <begin_op>
    iput(ff.ip);
    8000479c:	854e                	mv	a0,s3
    8000479e:	fffff097          	auipc	ra,0xfffff
    800047a2:	262080e7          	jalr	610(ra) # 80003a00 <iput>
    end_op();
    800047a6:	00000097          	auipc	ra,0x0
    800047aa:	afe080e7          	jalr	-1282(ra) # 800042a4 <end_op>
    800047ae:	a00d                	j	800047d0 <fileclose+0xa8>
    panic("fileclose");
    800047b0:	00004517          	auipc	a0,0x4
    800047b4:	ec050513          	addi	a0,a0,-320 # 80008670 <syscalls+0x278>
    800047b8:	ffffc097          	auipc	ra,0xffffc
    800047bc:	da0080e7          	jalr	-608(ra) # 80000558 <panic>
    release(&ftable.lock);
    800047c0:	00018517          	auipc	a0,0x18
    800047c4:	ff050513          	addi	a0,a0,-16 # 8001c7b0 <ftable>
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	510080e7          	jalr	1296(ra) # 80000cd8 <release>
  }
}
    800047d0:	70e2                	ld	ra,56(sp)
    800047d2:	7442                	ld	s0,48(sp)
    800047d4:	74a2                	ld	s1,40(sp)
    800047d6:	7902                	ld	s2,32(sp)
    800047d8:	69e2                	ld	s3,24(sp)
    800047da:	6a42                	ld	s4,16(sp)
    800047dc:	6aa2                	ld	s5,8(sp)
    800047de:	6121                	addi	sp,sp,64
    800047e0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047e2:	85d6                	mv	a1,s5
    800047e4:	8552                	mv	a0,s4
    800047e6:	00000097          	auipc	ra,0x0
    800047ea:	340080e7          	jalr	832(ra) # 80004b26 <pipeclose>
    800047ee:	b7cd                	j	800047d0 <fileclose+0xa8>

00000000800047f0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800047f0:	715d                	addi	sp,sp,-80
    800047f2:	e486                	sd	ra,72(sp)
    800047f4:	e0a2                	sd	s0,64(sp)
    800047f6:	fc26                	sd	s1,56(sp)
    800047f8:	f84a                	sd	s2,48(sp)
    800047fa:	f44e                	sd	s3,40(sp)
    800047fc:	0880                	addi	s0,sp,80
    800047fe:	84aa                	mv	s1,a0
    80004800:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004802:	ffffd097          	auipc	ra,0xffffd
    80004806:	246080e7          	jalr	582(ra) # 80001a48 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000480a:	409c                	lw	a5,0(s1)
    8000480c:	37f9                	addiw	a5,a5,-2
    8000480e:	4705                	li	a4,1
    80004810:	04f76763          	bltu	a4,a5,8000485e <filestat+0x6e>
    80004814:	892a                	mv	s2,a0
    ilock(f->ip);
    80004816:	6c88                	ld	a0,24(s1)
    80004818:	fffff097          	auipc	ra,0xfffff
    8000481c:	f86080e7          	jalr	-122(ra) # 8000379e <ilock>
    stati(f->ip, &st);
    80004820:	fb840593          	addi	a1,s0,-72
    80004824:	6c88                	ld	a0,24(s1)
    80004826:	fffff097          	auipc	ra,0xfffff
    8000482a:	2aa080e7          	jalr	682(ra) # 80003ad0 <stati>
    iunlock(f->ip);
    8000482e:	6c88                	ld	a0,24(s1)
    80004830:	fffff097          	auipc	ra,0xfffff
    80004834:	032080e7          	jalr	50(ra) # 80003862 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004838:	46e1                	li	a3,24
    8000483a:	fb840613          	addi	a2,s0,-72
    8000483e:	85ce                	mv	a1,s3
    80004840:	05093503          	ld	a0,80(s2)
    80004844:	ffffd097          	auipc	ra,0xffffd
    80004848:	e82080e7          	jalr	-382(ra) # 800016c6 <copyout>
    8000484c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004850:	60a6                	ld	ra,72(sp)
    80004852:	6406                	ld	s0,64(sp)
    80004854:	74e2                	ld	s1,56(sp)
    80004856:	7942                	ld	s2,48(sp)
    80004858:	79a2                	ld	s3,40(sp)
    8000485a:	6161                	addi	sp,sp,80
    8000485c:	8082                	ret
  return -1;
    8000485e:	557d                	li	a0,-1
    80004860:	bfc5                	j	80004850 <filestat+0x60>

0000000080004862 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004862:	7179                	addi	sp,sp,-48
    80004864:	f406                	sd	ra,40(sp)
    80004866:	f022                	sd	s0,32(sp)
    80004868:	ec26                	sd	s1,24(sp)
    8000486a:	e84a                	sd	s2,16(sp)
    8000486c:	e44e                	sd	s3,8(sp)
    8000486e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004870:	00854783          	lbu	a5,8(a0)
    80004874:	c3d5                	beqz	a5,80004918 <fileread+0xb6>
    80004876:	89b2                	mv	s3,a2
    80004878:	892e                	mv	s2,a1
    8000487a:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    8000487c:	411c                	lw	a5,0(a0)
    8000487e:	4705                	li	a4,1
    80004880:	04e78963          	beq	a5,a4,800048d2 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004884:	470d                	li	a4,3
    80004886:	04e78d63          	beq	a5,a4,800048e0 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000488a:	4709                	li	a4,2
    8000488c:	06e79e63          	bne	a5,a4,80004908 <fileread+0xa6>
    ilock(f->ip);
    80004890:	6d08                	ld	a0,24(a0)
    80004892:	fffff097          	auipc	ra,0xfffff
    80004896:	f0c080e7          	jalr	-244(ra) # 8000379e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000489a:	874e                	mv	a4,s3
    8000489c:	5094                	lw	a3,32(s1)
    8000489e:	864a                	mv	a2,s2
    800048a0:	4585                	li	a1,1
    800048a2:	6c88                	ld	a0,24(s1)
    800048a4:	fffff097          	auipc	ra,0xfffff
    800048a8:	256080e7          	jalr	598(ra) # 80003afa <readi>
    800048ac:	892a                	mv	s2,a0
    800048ae:	00a05563          	blez	a0,800048b8 <fileread+0x56>
      f->off += r;
    800048b2:	509c                	lw	a5,32(s1)
    800048b4:	9fa9                	addw	a5,a5,a0
    800048b6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048b8:	6c88                	ld	a0,24(s1)
    800048ba:	fffff097          	auipc	ra,0xfffff
    800048be:	fa8080e7          	jalr	-88(ra) # 80003862 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800048c2:	854a                	mv	a0,s2
    800048c4:	70a2                	ld	ra,40(sp)
    800048c6:	7402                	ld	s0,32(sp)
    800048c8:	64e2                	ld	s1,24(sp)
    800048ca:	6942                	ld	s2,16(sp)
    800048cc:	69a2                	ld	s3,8(sp)
    800048ce:	6145                	addi	sp,sp,48
    800048d0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800048d2:	6908                	ld	a0,16(a0)
    800048d4:	00000097          	auipc	ra,0x0
    800048d8:	3c8080e7          	jalr	968(ra) # 80004c9c <piperead>
    800048dc:	892a                	mv	s2,a0
    800048de:	b7d5                	j	800048c2 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048e0:	02451783          	lh	a5,36(a0)
    800048e4:	03079693          	slli	a3,a5,0x30
    800048e8:	92c1                	srli	a3,a3,0x30
    800048ea:	4725                	li	a4,9
    800048ec:	02d76863          	bltu	a4,a3,8000491c <fileread+0xba>
    800048f0:	0792                	slli	a5,a5,0x4
    800048f2:	00018717          	auipc	a4,0x18
    800048f6:	e1e70713          	addi	a4,a4,-482 # 8001c710 <devsw>
    800048fa:	97ba                	add	a5,a5,a4
    800048fc:	639c                	ld	a5,0(a5)
    800048fe:	c38d                	beqz	a5,80004920 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004900:	4505                	li	a0,1
    80004902:	9782                	jalr	a5
    80004904:	892a                	mv	s2,a0
    80004906:	bf75                	j	800048c2 <fileread+0x60>
    panic("fileread");
    80004908:	00004517          	auipc	a0,0x4
    8000490c:	d7850513          	addi	a0,a0,-648 # 80008680 <syscalls+0x288>
    80004910:	ffffc097          	auipc	ra,0xffffc
    80004914:	c48080e7          	jalr	-952(ra) # 80000558 <panic>
    return -1;
    80004918:	597d                	li	s2,-1
    8000491a:	b765                	j	800048c2 <fileread+0x60>
      return -1;
    8000491c:	597d                	li	s2,-1
    8000491e:	b755                	j	800048c2 <fileread+0x60>
    80004920:	597d                	li	s2,-1
    80004922:	b745                	j	800048c2 <fileread+0x60>

0000000080004924 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004924:	715d                	addi	sp,sp,-80
    80004926:	e486                	sd	ra,72(sp)
    80004928:	e0a2                	sd	s0,64(sp)
    8000492a:	fc26                	sd	s1,56(sp)
    8000492c:	f84a                	sd	s2,48(sp)
    8000492e:	f44e                	sd	s3,40(sp)
    80004930:	f052                	sd	s4,32(sp)
    80004932:	ec56                	sd	s5,24(sp)
    80004934:	e85a                	sd	s6,16(sp)
    80004936:	e45e                	sd	s7,8(sp)
    80004938:	e062                	sd	s8,0(sp)
    8000493a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000493c:	00954783          	lbu	a5,9(a0)
    80004940:	10078063          	beqz	a5,80004a40 <filewrite+0x11c>
    80004944:	84aa                	mv	s1,a0
    80004946:	8bae                	mv	s7,a1
    80004948:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    8000494a:	411c                	lw	a5,0(a0)
    8000494c:	4705                	li	a4,1
    8000494e:	02e78263          	beq	a5,a4,80004972 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004952:	470d                	li	a4,3
    80004954:	02e78663          	beq	a5,a4,80004980 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004958:	4709                	li	a4,2
    8000495a:	0ce79b63          	bne	a5,a4,80004a30 <filewrite+0x10c>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000495e:	0ac05763          	blez	a2,80004a0c <filewrite+0xe8>
    int i = 0;
    80004962:	4901                	li	s2,0
    80004964:	6b05                	lui	s6,0x1
    80004966:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000496a:	6c05                	lui	s8,0x1
    8000496c:	c00c0c1b          	addiw	s8,s8,-1024
    80004970:	a071                	j	800049fc <filewrite+0xd8>
    ret = pipewrite(f->pipe, addr, n);
    80004972:	6908                	ld	a0,16(a0)
    80004974:	00000097          	auipc	ra,0x0
    80004978:	222080e7          	jalr	546(ra) # 80004b96 <pipewrite>
    8000497c:	8aaa                	mv	s5,a0
    8000497e:	a851                	j	80004a12 <filewrite+0xee>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004980:	02451783          	lh	a5,36(a0)
    80004984:	03079693          	slli	a3,a5,0x30
    80004988:	92c1                	srli	a3,a3,0x30
    8000498a:	4725                	li	a4,9
    8000498c:	0ad76c63          	bltu	a4,a3,80004a44 <filewrite+0x120>
    80004990:	0792                	slli	a5,a5,0x4
    80004992:	00018717          	auipc	a4,0x18
    80004996:	d7e70713          	addi	a4,a4,-642 # 8001c710 <devsw>
    8000499a:	97ba                	add	a5,a5,a4
    8000499c:	679c                	ld	a5,8(a5)
    8000499e:	c7cd                	beqz	a5,80004a48 <filewrite+0x124>
    ret = devsw[f->major].write(1, addr, n);
    800049a0:	4505                	li	a0,1
    800049a2:	9782                	jalr	a5
    800049a4:	8aaa                	mv	s5,a0
    800049a6:	a0b5                	j	80004a12 <filewrite+0xee>
    800049a8:	00098a1b          	sext.w	s4,s3
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800049ac:	00000097          	auipc	ra,0x0
    800049b0:	878080e7          	jalr	-1928(ra) # 80004224 <begin_op>
      ilock(f->ip);
    800049b4:	6c88                	ld	a0,24(s1)
    800049b6:	fffff097          	auipc	ra,0xfffff
    800049ba:	de8080e7          	jalr	-536(ra) # 8000379e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049be:	8752                	mv	a4,s4
    800049c0:	5094                	lw	a3,32(s1)
    800049c2:	01790633          	add	a2,s2,s7
    800049c6:	4585                	li	a1,1
    800049c8:	6c88                	ld	a0,24(s1)
    800049ca:	fffff097          	auipc	ra,0xfffff
    800049ce:	228080e7          	jalr	552(ra) # 80003bf2 <writei>
    800049d2:	89aa                	mv	s3,a0
    800049d4:	00a05563          	blez	a0,800049de <filewrite+0xba>
        f->off += r;
    800049d8:	509c                	lw	a5,32(s1)
    800049da:	9fa9                	addw	a5,a5,a0
    800049dc:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    800049de:	6c88                	ld	a0,24(s1)
    800049e0:	fffff097          	auipc	ra,0xfffff
    800049e4:	e82080e7          	jalr	-382(ra) # 80003862 <iunlock>
      end_op();
    800049e8:	00000097          	auipc	ra,0x0
    800049ec:	8bc080e7          	jalr	-1860(ra) # 800042a4 <end_op>

      if(r != n1){
    800049f0:	01499f63          	bne	s3,s4,80004a0e <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    800049f4:	012a093b          	addw	s2,s4,s2
    while(i < n){
    800049f8:	01595b63          	ble	s5,s2,80004a0e <filewrite+0xea>
      int n1 = n - i;
    800049fc:	412a87bb          	subw	a5,s5,s2
      if(n1 > max)
    80004a00:	89be                	mv	s3,a5
    80004a02:	2781                	sext.w	a5,a5
    80004a04:	fafb52e3          	ble	a5,s6,800049a8 <filewrite+0x84>
    80004a08:	89e2                	mv	s3,s8
    80004a0a:	bf79                	j	800049a8 <filewrite+0x84>
    int i = 0;
    80004a0c:	4901                	li	s2,0
    }
    ret = (i == n ? n : -1);
    80004a0e:	012a9f63          	bne	s5,s2,80004a2c <filewrite+0x108>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a12:	8556                	mv	a0,s5
    80004a14:	60a6                	ld	ra,72(sp)
    80004a16:	6406                	ld	s0,64(sp)
    80004a18:	74e2                	ld	s1,56(sp)
    80004a1a:	7942                	ld	s2,48(sp)
    80004a1c:	79a2                	ld	s3,40(sp)
    80004a1e:	7a02                	ld	s4,32(sp)
    80004a20:	6ae2                	ld	s5,24(sp)
    80004a22:	6b42                	ld	s6,16(sp)
    80004a24:	6ba2                	ld	s7,8(sp)
    80004a26:	6c02                	ld	s8,0(sp)
    80004a28:	6161                	addi	sp,sp,80
    80004a2a:	8082                	ret
    ret = (i == n ? n : -1);
    80004a2c:	5afd                	li	s5,-1
    80004a2e:	b7d5                	j	80004a12 <filewrite+0xee>
    panic("filewrite");
    80004a30:	00004517          	auipc	a0,0x4
    80004a34:	c6050513          	addi	a0,a0,-928 # 80008690 <syscalls+0x298>
    80004a38:	ffffc097          	auipc	ra,0xffffc
    80004a3c:	b20080e7          	jalr	-1248(ra) # 80000558 <panic>
    return -1;
    80004a40:	5afd                	li	s5,-1
    80004a42:	bfc1                	j	80004a12 <filewrite+0xee>
      return -1;
    80004a44:	5afd                	li	s5,-1
    80004a46:	b7f1                	j	80004a12 <filewrite+0xee>
    80004a48:	5afd                	li	s5,-1
    80004a4a:	b7e1                	j	80004a12 <filewrite+0xee>

0000000080004a4c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a4c:	7179                	addi	sp,sp,-48
    80004a4e:	f406                	sd	ra,40(sp)
    80004a50:	f022                	sd	s0,32(sp)
    80004a52:	ec26                	sd	s1,24(sp)
    80004a54:	e84a                	sd	s2,16(sp)
    80004a56:	e44e                	sd	s3,8(sp)
    80004a58:	e052                	sd	s4,0(sp)
    80004a5a:	1800                	addi	s0,sp,48
    80004a5c:	84aa                	mv	s1,a0
    80004a5e:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a60:	0005b023          	sd	zero,0(a1)
    80004a64:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a68:	00000097          	auipc	ra,0x0
    80004a6c:	bf0080e7          	jalr	-1040(ra) # 80004658 <filealloc>
    80004a70:	e088                	sd	a0,0(s1)
    80004a72:	c551                	beqz	a0,80004afe <pipealloc+0xb2>
    80004a74:	00000097          	auipc	ra,0x0
    80004a78:	be4080e7          	jalr	-1052(ra) # 80004658 <filealloc>
    80004a7c:	00a93023          	sd	a0,0(s2)
    80004a80:	c92d                	beqz	a0,80004af2 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a82:	ffffc097          	auipc	ra,0xffffc
    80004a86:	0b2080e7          	jalr	178(ra) # 80000b34 <kalloc>
    80004a8a:	89aa                	mv	s3,a0
    80004a8c:	c125                	beqz	a0,80004aec <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004a8e:	4a05                	li	s4,1
    80004a90:	23452023          	sw	s4,544(a0)
  pi->writeopen = 1;
    80004a94:	23452223          	sw	s4,548(a0)
  pi->nwrite = 0;
    80004a98:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004a9c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004aa0:	00004597          	auipc	a1,0x4
    80004aa4:	c0058593          	addi	a1,a1,-1024 # 800086a0 <syscalls+0x2a8>
    80004aa8:	ffffc097          	auipc	ra,0xffffc
    80004aac:	0ec080e7          	jalr	236(ra) # 80000b94 <initlock>
  (*f0)->type = FD_PIPE;
    80004ab0:	609c                	ld	a5,0(s1)
    80004ab2:	0147a023          	sw	s4,0(a5)
  (*f0)->readable = 1;
    80004ab6:	609c                	ld	a5,0(s1)
    80004ab8:	01478423          	sb	s4,8(a5)
  (*f0)->writable = 0;
    80004abc:	609c                	ld	a5,0(s1)
    80004abe:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ac2:	609c                	ld	a5,0(s1)
    80004ac4:	0137b823          	sd	s3,16(a5)
  (*f1)->type = FD_PIPE;
    80004ac8:	00093783          	ld	a5,0(s2)
    80004acc:	0147a023          	sw	s4,0(a5)
  (*f1)->readable = 0;
    80004ad0:	00093783          	ld	a5,0(s2)
    80004ad4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004ad8:	00093783          	ld	a5,0(s2)
    80004adc:	014784a3          	sb	s4,9(a5)
  (*f1)->pipe = pi;
    80004ae0:	00093783          	ld	a5,0(s2)
    80004ae4:	0137b823          	sd	s3,16(a5)
  return 0;
    80004ae8:	4501                	li	a0,0
    80004aea:	a025                	j	80004b12 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004aec:	6088                	ld	a0,0(s1)
    80004aee:	e501                	bnez	a0,80004af6 <pipealloc+0xaa>
    80004af0:	a039                	j	80004afe <pipealloc+0xb2>
    80004af2:	6088                	ld	a0,0(s1)
    80004af4:	c51d                	beqz	a0,80004b22 <pipealloc+0xd6>
    fileclose(*f0);
    80004af6:	00000097          	auipc	ra,0x0
    80004afa:	c32080e7          	jalr	-974(ra) # 80004728 <fileclose>
  if(*f1)
    80004afe:	00093783          	ld	a5,0(s2)
    fileclose(*f1);
  return -1;
    80004b02:	557d                	li	a0,-1
  if(*f1)
    80004b04:	c799                	beqz	a5,80004b12 <pipealloc+0xc6>
    fileclose(*f1);
    80004b06:	853e                	mv	a0,a5
    80004b08:	00000097          	auipc	ra,0x0
    80004b0c:	c20080e7          	jalr	-992(ra) # 80004728 <fileclose>
  return -1;
    80004b10:	557d                	li	a0,-1
}
    80004b12:	70a2                	ld	ra,40(sp)
    80004b14:	7402                	ld	s0,32(sp)
    80004b16:	64e2                	ld	s1,24(sp)
    80004b18:	6942                	ld	s2,16(sp)
    80004b1a:	69a2                	ld	s3,8(sp)
    80004b1c:	6a02                	ld	s4,0(sp)
    80004b1e:	6145                	addi	sp,sp,48
    80004b20:	8082                	ret
  return -1;
    80004b22:	557d                	li	a0,-1
    80004b24:	b7fd                	j	80004b12 <pipealloc+0xc6>

0000000080004b26 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b26:	1101                	addi	sp,sp,-32
    80004b28:	ec06                	sd	ra,24(sp)
    80004b2a:	e822                	sd	s0,16(sp)
    80004b2c:	e426                	sd	s1,8(sp)
    80004b2e:	e04a                	sd	s2,0(sp)
    80004b30:	1000                	addi	s0,sp,32
    80004b32:	84aa                	mv	s1,a0
    80004b34:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b36:	ffffc097          	auipc	ra,0xffffc
    80004b3a:	0ee080e7          	jalr	238(ra) # 80000c24 <acquire>
  if(writable){
    80004b3e:	02090d63          	beqz	s2,80004b78 <pipeclose+0x52>
    pi->writeopen = 0;
    80004b42:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b46:	21848513          	addi	a0,s1,536
    80004b4a:	ffffe097          	auipc	ra,0xffffe
    80004b4e:	89e080e7          	jalr	-1890(ra) # 800023e8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b52:	2204b783          	ld	a5,544(s1)
    80004b56:	eb95                	bnez	a5,80004b8a <pipeclose+0x64>
    release(&pi->lock);
    80004b58:	8526                	mv	a0,s1
    80004b5a:	ffffc097          	auipc	ra,0xffffc
    80004b5e:	17e080e7          	jalr	382(ra) # 80000cd8 <release>
    kfree((char*)pi);
    80004b62:	8526                	mv	a0,s1
    80004b64:	ffffc097          	auipc	ra,0xffffc
    80004b68:	ed0080e7          	jalr	-304(ra) # 80000a34 <kfree>
  } else
    release(&pi->lock);
}
    80004b6c:	60e2                	ld	ra,24(sp)
    80004b6e:	6442                	ld	s0,16(sp)
    80004b70:	64a2                	ld	s1,8(sp)
    80004b72:	6902                	ld	s2,0(sp)
    80004b74:	6105                	addi	sp,sp,32
    80004b76:	8082                	ret
    pi->readopen = 0;
    80004b78:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b7c:	21c48513          	addi	a0,s1,540
    80004b80:	ffffe097          	auipc	ra,0xffffe
    80004b84:	868080e7          	jalr	-1944(ra) # 800023e8 <wakeup>
    80004b88:	b7e9                	j	80004b52 <pipeclose+0x2c>
    release(&pi->lock);
    80004b8a:	8526                	mv	a0,s1
    80004b8c:	ffffc097          	auipc	ra,0xffffc
    80004b90:	14c080e7          	jalr	332(ra) # 80000cd8 <release>
}
    80004b94:	bfe1                	j	80004b6c <pipeclose+0x46>

0000000080004b96 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b96:	7159                	addi	sp,sp,-112
    80004b98:	f486                	sd	ra,104(sp)
    80004b9a:	f0a2                	sd	s0,96(sp)
    80004b9c:	eca6                	sd	s1,88(sp)
    80004b9e:	e8ca                	sd	s2,80(sp)
    80004ba0:	e4ce                	sd	s3,72(sp)
    80004ba2:	e0d2                	sd	s4,64(sp)
    80004ba4:	fc56                	sd	s5,56(sp)
    80004ba6:	f85a                	sd	s6,48(sp)
    80004ba8:	f45e                	sd	s7,40(sp)
    80004baa:	f062                	sd	s8,32(sp)
    80004bac:	ec66                	sd	s9,24(sp)
    80004bae:	1880                	addi	s0,sp,112
    80004bb0:	84aa                	mv	s1,a0
    80004bb2:	8aae                	mv	s5,a1
    80004bb4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004bb6:	ffffd097          	auipc	ra,0xffffd
    80004bba:	e92080e7          	jalr	-366(ra) # 80001a48 <myproc>
    80004bbe:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004bc0:	8526                	mv	a0,s1
    80004bc2:	ffffc097          	auipc	ra,0xffffc
    80004bc6:	062080e7          	jalr	98(ra) # 80000c24 <acquire>
  while(i < n){
    80004bca:	0d405763          	blez	s4,80004c98 <pipewrite+0x102>
    80004bce:	8ba6                	mv	s7,s1
    if(pi->readopen == 0 || pr->killed){
    80004bd0:	2204a783          	lw	a5,544(s1)
    80004bd4:	cb99                	beqz	a5,80004bea <pipewrite+0x54>
    80004bd6:	0309a903          	lw	s2,48(s3)
    80004bda:	00091863          	bnez	s2,80004bea <pipewrite+0x54>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004bde:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004be0:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004be4:	21c48c13          	addi	s8,s1,540
    80004be8:	a0bd                	j	80004c56 <pipewrite+0xc0>
      release(&pi->lock);
    80004bea:	8526                	mv	a0,s1
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	0ec080e7          	jalr	236(ra) # 80000cd8 <release>
      return -1;
    80004bf4:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004bf6:	854a                	mv	a0,s2
    80004bf8:	70a6                	ld	ra,104(sp)
    80004bfa:	7406                	ld	s0,96(sp)
    80004bfc:	64e6                	ld	s1,88(sp)
    80004bfe:	6946                	ld	s2,80(sp)
    80004c00:	69a6                	ld	s3,72(sp)
    80004c02:	6a06                	ld	s4,64(sp)
    80004c04:	7ae2                	ld	s5,56(sp)
    80004c06:	7b42                	ld	s6,48(sp)
    80004c08:	7ba2                	ld	s7,40(sp)
    80004c0a:	7c02                	ld	s8,32(sp)
    80004c0c:	6ce2                	ld	s9,24(sp)
    80004c0e:	6165                	addi	sp,sp,112
    80004c10:	8082                	ret
      wakeup(&pi->nread);
    80004c12:	8566                	mv	a0,s9
    80004c14:	ffffd097          	auipc	ra,0xffffd
    80004c18:	7d4080e7          	jalr	2004(ra) # 800023e8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c1c:	85de                	mv	a1,s7
    80004c1e:	8562                	mv	a0,s8
    80004c20:	ffffd097          	auipc	ra,0xffffd
    80004c24:	642080e7          	jalr	1602(ra) # 80002262 <sleep>
    80004c28:	a839                	j	80004c46 <pipewrite+0xb0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c2a:	21c4a783          	lw	a5,540(s1)
    80004c2e:	0017871b          	addiw	a4,a5,1
    80004c32:	20e4ae23          	sw	a4,540(s1)
    80004c36:	1ff7f793          	andi	a5,a5,511
    80004c3a:	97a6                	add	a5,a5,s1
    80004c3c:	f9f44703          	lbu	a4,-97(s0)
    80004c40:	00e78c23          	sb	a4,24(a5)
      i++;
    80004c44:	2905                	addiw	s2,s2,1
  while(i < n){
    80004c46:	03495d63          	ble	s4,s2,80004c80 <pipewrite+0xea>
    if(pi->readopen == 0 || pr->killed){
    80004c4a:	2204a783          	lw	a5,544(s1)
    80004c4e:	dfd1                	beqz	a5,80004bea <pipewrite+0x54>
    80004c50:	0309a783          	lw	a5,48(s3)
    80004c54:	fbd9                	bnez	a5,80004bea <pipewrite+0x54>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004c56:	2184a783          	lw	a5,536(s1)
    80004c5a:	21c4a703          	lw	a4,540(s1)
    80004c5e:	2007879b          	addiw	a5,a5,512
    80004c62:	faf708e3          	beq	a4,a5,80004c12 <pipewrite+0x7c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c66:	4685                	li	a3,1
    80004c68:	01590633          	add	a2,s2,s5
    80004c6c:	f9f40593          	addi	a1,s0,-97
    80004c70:	0509b503          	ld	a0,80(s3)
    80004c74:	ffffd097          	auipc	ra,0xffffd
    80004c78:	ade080e7          	jalr	-1314(ra) # 80001752 <copyin>
    80004c7c:	fb6517e3          	bne	a0,s6,80004c2a <pipewrite+0x94>
  wakeup(&pi->nread);
    80004c80:	21848513          	addi	a0,s1,536
    80004c84:	ffffd097          	auipc	ra,0xffffd
    80004c88:	764080e7          	jalr	1892(ra) # 800023e8 <wakeup>
  release(&pi->lock);
    80004c8c:	8526                	mv	a0,s1
    80004c8e:	ffffc097          	auipc	ra,0xffffc
    80004c92:	04a080e7          	jalr	74(ra) # 80000cd8 <release>
  return i;
    80004c96:	b785                	j	80004bf6 <pipewrite+0x60>
  int i = 0;
    80004c98:	4901                	li	s2,0
    80004c9a:	b7dd                	j	80004c80 <pipewrite+0xea>

0000000080004c9c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c9c:	715d                	addi	sp,sp,-80
    80004c9e:	e486                	sd	ra,72(sp)
    80004ca0:	e0a2                	sd	s0,64(sp)
    80004ca2:	fc26                	sd	s1,56(sp)
    80004ca4:	f84a                	sd	s2,48(sp)
    80004ca6:	f44e                	sd	s3,40(sp)
    80004ca8:	f052                	sd	s4,32(sp)
    80004caa:	ec56                	sd	s5,24(sp)
    80004cac:	e85a                	sd	s6,16(sp)
    80004cae:	0880                	addi	s0,sp,80
    80004cb0:	84aa                	mv	s1,a0
    80004cb2:	89ae                	mv	s3,a1
    80004cb4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004cb6:	ffffd097          	auipc	ra,0xffffd
    80004cba:	d92080e7          	jalr	-622(ra) # 80001a48 <myproc>
    80004cbe:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004cc0:	8526                	mv	a0,s1
    80004cc2:	ffffc097          	auipc	ra,0xffffc
    80004cc6:	f62080e7          	jalr	-158(ra) # 80000c24 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cca:	2184a703          	lw	a4,536(s1)
    80004cce:	21c4a783          	lw	a5,540(s1)
    80004cd2:	06f71b63          	bne	a4,a5,80004d48 <piperead+0xac>
    80004cd6:	8926                	mv	s2,s1
    80004cd8:	2244a783          	lw	a5,548(s1)
    80004cdc:	cf9d                	beqz	a5,80004d1a <piperead+0x7e>
    if(pr->killed){
    80004cde:	030a2783          	lw	a5,48(s4)
    80004ce2:	e78d                	bnez	a5,80004d0c <piperead+0x70>
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ce4:	21848b13          	addi	s6,s1,536
    80004ce8:	85ca                	mv	a1,s2
    80004cea:	855a                	mv	a0,s6
    80004cec:	ffffd097          	auipc	ra,0xffffd
    80004cf0:	576080e7          	jalr	1398(ra) # 80002262 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cf4:	2184a703          	lw	a4,536(s1)
    80004cf8:	21c4a783          	lw	a5,540(s1)
    80004cfc:	04f71663          	bne	a4,a5,80004d48 <piperead+0xac>
    80004d00:	2244a783          	lw	a5,548(s1)
    80004d04:	cb99                	beqz	a5,80004d1a <piperead+0x7e>
    if(pr->killed){
    80004d06:	030a2783          	lw	a5,48(s4)
    80004d0a:	dff9                	beqz	a5,80004ce8 <piperead+0x4c>
      release(&pi->lock);
    80004d0c:	8526                	mv	a0,s1
    80004d0e:	ffffc097          	auipc	ra,0xffffc
    80004d12:	fca080e7          	jalr	-54(ra) # 80000cd8 <release>
      return -1;
    80004d16:	597d                	li	s2,-1
    80004d18:	a829                	j	80004d32 <piperead+0x96>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(pi->nread == pi->nwrite)
    80004d1a:	4901                	li	s2,0
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d1c:	21c48513          	addi	a0,s1,540
    80004d20:	ffffd097          	auipc	ra,0xffffd
    80004d24:	6c8080e7          	jalr	1736(ra) # 800023e8 <wakeup>
  release(&pi->lock);
    80004d28:	8526                	mv	a0,s1
    80004d2a:	ffffc097          	auipc	ra,0xffffc
    80004d2e:	fae080e7          	jalr	-82(ra) # 80000cd8 <release>
  return i;
}
    80004d32:	854a                	mv	a0,s2
    80004d34:	60a6                	ld	ra,72(sp)
    80004d36:	6406                	ld	s0,64(sp)
    80004d38:	74e2                	ld	s1,56(sp)
    80004d3a:	7942                	ld	s2,48(sp)
    80004d3c:	79a2                	ld	s3,40(sp)
    80004d3e:	7a02                	ld	s4,32(sp)
    80004d40:	6ae2                	ld	s5,24(sp)
    80004d42:	6b42                	ld	s6,16(sp)
    80004d44:	6161                	addi	sp,sp,80
    80004d46:	8082                	ret
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d48:	4901                	li	s2,0
    80004d4a:	fd5059e3          	blez	s5,80004d1c <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004d4e:	2184a783          	lw	a5,536(s1)
    80004d52:	4901                	li	s2,0
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d54:	5b7d                	li	s6,-1
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d56:	0017871b          	addiw	a4,a5,1
    80004d5a:	20e4ac23          	sw	a4,536(s1)
    80004d5e:	1ff7f793          	andi	a5,a5,511
    80004d62:	97a6                	add	a5,a5,s1
    80004d64:	0187c783          	lbu	a5,24(a5)
    80004d68:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d6c:	4685                	li	a3,1
    80004d6e:	fbf40613          	addi	a2,s0,-65
    80004d72:	85ce                	mv	a1,s3
    80004d74:	050a3503          	ld	a0,80(s4)
    80004d78:	ffffd097          	auipc	ra,0xffffd
    80004d7c:	94e080e7          	jalr	-1714(ra) # 800016c6 <copyout>
    80004d80:	f9650ee3          	beq	a0,s6,80004d1c <piperead+0x80>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d84:	2905                	addiw	s2,s2,1
    80004d86:	f92a8be3          	beq	s5,s2,80004d1c <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004d8a:	2184a783          	lw	a5,536(s1)
    80004d8e:	0985                	addi	s3,s3,1
    80004d90:	21c4a703          	lw	a4,540(s1)
    80004d94:	fcf711e3          	bne	a4,a5,80004d56 <piperead+0xba>
    80004d98:	b751                	j	80004d1c <piperead+0x80>

0000000080004d9a <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004d9a:	de010113          	addi	sp,sp,-544
    80004d9e:	20113c23          	sd	ra,536(sp)
    80004da2:	20813823          	sd	s0,528(sp)
    80004da6:	20913423          	sd	s1,520(sp)
    80004daa:	21213023          	sd	s2,512(sp)
    80004dae:	ffce                	sd	s3,504(sp)
    80004db0:	fbd2                	sd	s4,496(sp)
    80004db2:	f7d6                	sd	s5,488(sp)
    80004db4:	f3da                	sd	s6,480(sp)
    80004db6:	efde                	sd	s7,472(sp)
    80004db8:	ebe2                	sd	s8,464(sp)
    80004dba:	e7e6                	sd	s9,456(sp)
    80004dbc:	e3ea                	sd	s10,448(sp)
    80004dbe:	ff6e                	sd	s11,440(sp)
    80004dc0:	1400                	addi	s0,sp,544
    80004dc2:	892a                	mv	s2,a0
    80004dc4:	dea43823          	sd	a0,-528(s0)
    80004dc8:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004dcc:	ffffd097          	auipc	ra,0xffffd
    80004dd0:	c7c080e7          	jalr	-900(ra) # 80001a48 <myproc>
    80004dd4:	84aa                	mv	s1,a0

  begin_op();
    80004dd6:	fffff097          	auipc	ra,0xfffff
    80004dda:	44e080e7          	jalr	1102(ra) # 80004224 <begin_op>

  if((ip = namei(path)) == 0){
    80004dde:	854a                	mv	a0,s2
    80004de0:	fffff097          	auipc	ra,0xfffff
    80004de4:	226080e7          	jalr	550(ra) # 80004006 <namei>
    80004de8:	c93d                	beqz	a0,80004e5e <exec+0xc4>
    80004dea:	892a                	mv	s2,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004dec:	fffff097          	auipc	ra,0xfffff
    80004df0:	9b2080e7          	jalr	-1614(ra) # 8000379e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004df4:	04000713          	li	a4,64
    80004df8:	4681                	li	a3,0
    80004dfa:	e4840613          	addi	a2,s0,-440
    80004dfe:	4581                	li	a1,0
    80004e00:	854a                	mv	a0,s2
    80004e02:	fffff097          	auipc	ra,0xfffff
    80004e06:	cf8080e7          	jalr	-776(ra) # 80003afa <readi>
    80004e0a:	04000793          	li	a5,64
    80004e0e:	00f51a63          	bne	a0,a5,80004e22 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e12:	e4842703          	lw	a4,-440(s0)
    80004e16:	464c47b7          	lui	a5,0x464c4
    80004e1a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e1e:	04f70663          	beq	a4,a5,80004e6a <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e22:	854a                	mv	a0,s2
    80004e24:	fffff097          	auipc	ra,0xfffff
    80004e28:	c84080e7          	jalr	-892(ra) # 80003aa8 <iunlockput>
    end_op();
    80004e2c:	fffff097          	auipc	ra,0xfffff
    80004e30:	478080e7          	jalr	1144(ra) # 800042a4 <end_op>
  }
  return -1;
    80004e34:	557d                	li	a0,-1
}
    80004e36:	21813083          	ld	ra,536(sp)
    80004e3a:	21013403          	ld	s0,528(sp)
    80004e3e:	20813483          	ld	s1,520(sp)
    80004e42:	20013903          	ld	s2,512(sp)
    80004e46:	79fe                	ld	s3,504(sp)
    80004e48:	7a5e                	ld	s4,496(sp)
    80004e4a:	7abe                	ld	s5,488(sp)
    80004e4c:	7b1e                	ld	s6,480(sp)
    80004e4e:	6bfe                	ld	s7,472(sp)
    80004e50:	6c5e                	ld	s8,464(sp)
    80004e52:	6cbe                	ld	s9,456(sp)
    80004e54:	6d1e                	ld	s10,448(sp)
    80004e56:	7dfa                	ld	s11,440(sp)
    80004e58:	22010113          	addi	sp,sp,544
    80004e5c:	8082                	ret
    end_op();
    80004e5e:	fffff097          	auipc	ra,0xfffff
    80004e62:	446080e7          	jalr	1094(ra) # 800042a4 <end_op>
    return -1;
    80004e66:	557d                	li	a0,-1
    80004e68:	b7f9                	j	80004e36 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e6a:	8526                	mv	a0,s1
    80004e6c:	ffffd097          	auipc	ra,0xffffd
    80004e70:	ca2080e7          	jalr	-862(ra) # 80001b0e <proc_pagetable>
    80004e74:	e0a43423          	sd	a0,-504(s0)
    80004e78:	d54d                	beqz	a0,80004e22 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e7a:	e6842983          	lw	s3,-408(s0)
    80004e7e:	e8045783          	lhu	a5,-384(s0)
    80004e82:	c7ad                	beqz	a5,80004eec <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004e84:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e86:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004e88:	6c05                	lui	s8,0x1
    80004e8a:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    80004e8e:	def43423          	sd	a5,-536(s0)
    80004e92:	7cfd                	lui	s9,0xfffff
    80004e94:	ac1d                	j	800050ca <exec+0x330>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004e96:	00004517          	auipc	a0,0x4
    80004e9a:	81250513          	addi	a0,a0,-2030 # 800086a8 <syscalls+0x2b0>
    80004e9e:	ffffb097          	auipc	ra,0xffffb
    80004ea2:	6ba080e7          	jalr	1722(ra) # 80000558 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004ea6:	8756                	mv	a4,s5
    80004ea8:	009d86bb          	addw	a3,s11,s1
    80004eac:	4581                	li	a1,0
    80004eae:	854a                	mv	a0,s2
    80004eb0:	fffff097          	auipc	ra,0xfffff
    80004eb4:	c4a080e7          	jalr	-950(ra) # 80003afa <readi>
    80004eb8:	2501                	sext.w	a0,a0
    80004eba:	1aaa9e63          	bne	s5,a0,80005076 <exec+0x2dc>
  for(i = 0; i < sz; i += PGSIZE){
    80004ebe:	6785                	lui	a5,0x1
    80004ec0:	9cbd                	addw	s1,s1,a5
    80004ec2:	014c8a3b          	addw	s4,s9,s4
    80004ec6:	1f74f963          	bleu	s7,s1,800050b8 <exec+0x31e>
    pa = walkaddr(pagetable, va + i);
    80004eca:	02049593          	slli	a1,s1,0x20
    80004ece:	9181                	srli	a1,a1,0x20
    80004ed0:	95ea                	add	a1,a1,s10
    80004ed2:	e0843503          	ld	a0,-504(s0)
    80004ed6:	ffffc097          	auipc	ra,0xffffc
    80004eda:	200080e7          	jalr	512(ra) # 800010d6 <walkaddr>
    80004ede:	862a                	mv	a2,a0
    if(pa == 0)
    80004ee0:	d95d                	beqz	a0,80004e96 <exec+0xfc>
      n = PGSIZE;
    80004ee2:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    80004ee4:	fd8a71e3          	bleu	s8,s4,80004ea6 <exec+0x10c>
      n = sz - i;
    80004ee8:	8ad2                	mv	s5,s4
    80004eea:	bf75                	j	80004ea6 <exec+0x10c>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004eec:	4481                	li	s1,0
  iunlockput(ip);
    80004eee:	854a                	mv	a0,s2
    80004ef0:	fffff097          	auipc	ra,0xfffff
    80004ef4:	bb8080e7          	jalr	-1096(ra) # 80003aa8 <iunlockput>
  end_op();
    80004ef8:	fffff097          	auipc	ra,0xfffff
    80004efc:	3ac080e7          	jalr	940(ra) # 800042a4 <end_op>
  p = myproc();
    80004f00:	ffffd097          	auipc	ra,0xffffd
    80004f04:	b48080e7          	jalr	-1208(ra) # 80001a48 <myproc>
    80004f08:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f0a:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004f0e:	6785                	lui	a5,0x1
    80004f10:	17fd                	addi	a5,a5,-1
    80004f12:	94be                	add	s1,s1,a5
    80004f14:	77fd                	lui	a5,0xfffff
    80004f16:	8fe5                	and	a5,a5,s1
    80004f18:	e0f43023          	sd	a5,-512(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f1c:	6609                	lui	a2,0x2
    80004f1e:	963e                	add	a2,a2,a5
    80004f20:	85be                	mv	a1,a5
    80004f22:	e0843483          	ld	s1,-504(s0)
    80004f26:	8526                	mv	a0,s1
    80004f28:	ffffc097          	auipc	ra,0xffffc
    80004f2c:	54e080e7          	jalr	1358(ra) # 80001476 <uvmalloc>
    80004f30:	8b2a                	mv	s6,a0
  ip = 0;
    80004f32:	4901                	li	s2,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f34:	14050163          	beqz	a0,80005076 <exec+0x2dc>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f38:	75f9                	lui	a1,0xffffe
    80004f3a:	95aa                	add	a1,a1,a0
    80004f3c:	8526                	mv	a0,s1
    80004f3e:	ffffc097          	auipc	ra,0xffffc
    80004f42:	756080e7          	jalr	1878(ra) # 80001694 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f46:	7bfd                	lui	s7,0xfffff
    80004f48:	9bda                	add	s7,s7,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f4a:	df843783          	ld	a5,-520(s0)
    80004f4e:	6388                	ld	a0,0(a5)
    80004f50:	c925                	beqz	a0,80004fc0 <exec+0x226>
    80004f52:	e8840993          	addi	s3,s0,-376
    80004f56:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80004f5a:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f5c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004f5e:	ffffc097          	auipc	ra,0xffffc
    80004f62:	f6c080e7          	jalr	-148(ra) # 80000eca <strlen>
    80004f66:	2505                	addiw	a0,a0,1
    80004f68:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f6c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004f70:	13796863          	bltu	s2,s7,800050a0 <exec+0x306>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f74:	df843c83          	ld	s9,-520(s0)
    80004f78:	000cba03          	ld	s4,0(s9) # fffffffffffff000 <end+0xffffffff7ffde000>
    80004f7c:	8552                	mv	a0,s4
    80004f7e:	ffffc097          	auipc	ra,0xffffc
    80004f82:	f4c080e7          	jalr	-180(ra) # 80000eca <strlen>
    80004f86:	0015069b          	addiw	a3,a0,1
    80004f8a:	8652                	mv	a2,s4
    80004f8c:	85ca                	mv	a1,s2
    80004f8e:	e0843503          	ld	a0,-504(s0)
    80004f92:	ffffc097          	auipc	ra,0xffffc
    80004f96:	734080e7          	jalr	1844(ra) # 800016c6 <copyout>
    80004f9a:	10054763          	bltz	a0,800050a8 <exec+0x30e>
    ustack[argc] = sp;
    80004f9e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004fa2:	0485                	addi	s1,s1,1
    80004fa4:	008c8793          	addi	a5,s9,8
    80004fa8:	def43c23          	sd	a5,-520(s0)
    80004fac:	008cb503          	ld	a0,8(s9)
    80004fb0:	c911                	beqz	a0,80004fc4 <exec+0x22a>
    if(argc >= MAXARG)
    80004fb2:	09a1                	addi	s3,s3,8
    80004fb4:	fb8995e3          	bne	s3,s8,80004f5e <exec+0x1c4>
  sz = sz1;
    80004fb8:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80004fbc:	4901                	li	s2,0
    80004fbe:	a865                	j	80005076 <exec+0x2dc>
  sp = sz;
    80004fc0:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fc2:	4481                	li	s1,0
  ustack[argc] = 0;
    80004fc4:	00349793          	slli	a5,s1,0x3
    80004fc8:	f9040713          	addi	a4,s0,-112
    80004fcc:	97ba                	add	a5,a5,a4
    80004fce:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffddef8>
  sp -= (argc+1) * sizeof(uint64);
    80004fd2:	00148693          	addi	a3,s1,1
    80004fd6:	068e                	slli	a3,a3,0x3
    80004fd8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004fdc:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004fe0:	01797663          	bleu	s7,s2,80004fec <exec+0x252>
  sz = sz1;
    80004fe4:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80004fe8:	4901                	li	s2,0
    80004fea:	a071                	j	80005076 <exec+0x2dc>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004fec:	e8840613          	addi	a2,s0,-376
    80004ff0:	85ca                	mv	a1,s2
    80004ff2:	e0843503          	ld	a0,-504(s0)
    80004ff6:	ffffc097          	auipc	ra,0xffffc
    80004ffa:	6d0080e7          	jalr	1744(ra) # 800016c6 <copyout>
    80004ffe:	0a054963          	bltz	a0,800050b0 <exec+0x316>
  p->trapframe->a1 = sp;
    80005002:	058ab783          	ld	a5,88(s5)
    80005006:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000500a:	df043783          	ld	a5,-528(s0)
    8000500e:	0007c703          	lbu	a4,0(a5)
    80005012:	cf11                	beqz	a4,8000502e <exec+0x294>
    80005014:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005016:	02f00693          	li	a3,47
    8000501a:	a029                	j	80005024 <exec+0x28a>
  for(last=s=path; *s; s++)
    8000501c:	0785                	addi	a5,a5,1
    8000501e:	fff7c703          	lbu	a4,-1(a5)
    80005022:	c711                	beqz	a4,8000502e <exec+0x294>
    if(*s == '/')
    80005024:	fed71ce3          	bne	a4,a3,8000501c <exec+0x282>
      last = s+1;
    80005028:	def43823          	sd	a5,-528(s0)
    8000502c:	bfc5                	j	8000501c <exec+0x282>
  safestrcpy(p->name, last, sizeof(p->name));
    8000502e:	4641                	li	a2,16
    80005030:	df043583          	ld	a1,-528(s0)
    80005034:	158a8513          	addi	a0,s5,344
    80005038:	ffffc097          	auipc	ra,0xffffc
    8000503c:	e60080e7          	jalr	-416(ra) # 80000e98 <safestrcpy>
  oldpagetable = p->pagetable;
    80005040:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005044:	e0843783          	ld	a5,-504(s0)
    80005048:	04fab823          	sd	a5,80(s5)
  p->sz = sz;
    8000504c:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005050:	058ab783          	ld	a5,88(s5)
    80005054:	e6043703          	ld	a4,-416(s0)
    80005058:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000505a:	058ab783          	ld	a5,88(s5)
    8000505e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005062:	85ea                	mv	a1,s10
    80005064:	ffffd097          	auipc	ra,0xffffd
    80005068:	b46080e7          	jalr	-1210(ra) # 80001baa <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000506c:	0004851b          	sext.w	a0,s1
    80005070:	b3d9                	j	80004e36 <exec+0x9c>
    80005072:	e0943023          	sd	s1,-512(s0)
    proc_freepagetable(pagetable, sz);
    80005076:	e0043583          	ld	a1,-512(s0)
    8000507a:	e0843503          	ld	a0,-504(s0)
    8000507e:	ffffd097          	auipc	ra,0xffffd
    80005082:	b2c080e7          	jalr	-1236(ra) # 80001baa <proc_freepagetable>
  if(ip){
    80005086:	d8091ee3          	bnez	s2,80004e22 <exec+0x88>
  return -1;
    8000508a:	557d                	li	a0,-1
    8000508c:	b36d                	j	80004e36 <exec+0x9c>
    8000508e:	e0943023          	sd	s1,-512(s0)
    80005092:	b7d5                	j	80005076 <exec+0x2dc>
    80005094:	e0943023          	sd	s1,-512(s0)
    80005098:	bff9                	j	80005076 <exec+0x2dc>
    8000509a:	e0943023          	sd	s1,-512(s0)
    8000509e:	bfe1                	j	80005076 <exec+0x2dc>
  sz = sz1;
    800050a0:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    800050a4:	4901                	li	s2,0
    800050a6:	bfc1                	j	80005076 <exec+0x2dc>
  sz = sz1;
    800050a8:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    800050ac:	4901                	li	s2,0
    800050ae:	b7e1                	j	80005076 <exec+0x2dc>
  sz = sz1;
    800050b0:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    800050b4:	4901                	li	s2,0
    800050b6:	b7c1                	j	80005076 <exec+0x2dc>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800050b8:	e0043483          	ld	s1,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050bc:	2b05                	addiw	s6,s6,1
    800050be:	0389899b          	addiw	s3,s3,56
    800050c2:	e8045783          	lhu	a5,-384(s0)
    800050c6:	e2fb54e3          	ble	a5,s6,80004eee <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800050ca:	2981                	sext.w	s3,s3
    800050cc:	03800713          	li	a4,56
    800050d0:	86ce                	mv	a3,s3
    800050d2:	e1040613          	addi	a2,s0,-496
    800050d6:	4581                	li	a1,0
    800050d8:	854a                	mv	a0,s2
    800050da:	fffff097          	auipc	ra,0xfffff
    800050de:	a20080e7          	jalr	-1504(ra) # 80003afa <readi>
    800050e2:	03800793          	li	a5,56
    800050e6:	f8f516e3          	bne	a0,a5,80005072 <exec+0x2d8>
    if(ph.type != ELF_PROG_LOAD)
    800050ea:	e1042783          	lw	a5,-496(s0)
    800050ee:	4705                	li	a4,1
    800050f0:	fce796e3          	bne	a5,a4,800050bc <exec+0x322>
    if(ph.memsz < ph.filesz)
    800050f4:	e3843603          	ld	a2,-456(s0)
    800050f8:	e3043783          	ld	a5,-464(s0)
    800050fc:	f8f669e3          	bltu	a2,a5,8000508e <exec+0x2f4>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005100:	e2043783          	ld	a5,-480(s0)
    80005104:	963e                	add	a2,a2,a5
    80005106:	f8f667e3          	bltu	a2,a5,80005094 <exec+0x2fa>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000510a:	85a6                	mv	a1,s1
    8000510c:	e0843503          	ld	a0,-504(s0)
    80005110:	ffffc097          	auipc	ra,0xffffc
    80005114:	366080e7          	jalr	870(ra) # 80001476 <uvmalloc>
    80005118:	e0a43023          	sd	a0,-512(s0)
    8000511c:	dd3d                	beqz	a0,8000509a <exec+0x300>
    if(ph.vaddr % PGSIZE != 0)
    8000511e:	e2043d03          	ld	s10,-480(s0)
    80005122:	de843783          	ld	a5,-536(s0)
    80005126:	00fd77b3          	and	a5,s10,a5
    8000512a:	f7b1                	bnez	a5,80005076 <exec+0x2dc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000512c:	e1842d83          	lw	s11,-488(s0)
    80005130:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005134:	f80b82e3          	beqz	s7,800050b8 <exec+0x31e>
    80005138:	8a5e                	mv	s4,s7
    8000513a:	4481                	li	s1,0
    8000513c:	b379                	j	80004eca <exec+0x130>

000000008000513e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000513e:	7179                	addi	sp,sp,-48
    80005140:	f406                	sd	ra,40(sp)
    80005142:	f022                	sd	s0,32(sp)
    80005144:	ec26                	sd	s1,24(sp)
    80005146:	e84a                	sd	s2,16(sp)
    80005148:	1800                	addi	s0,sp,48
    8000514a:	892e                	mv	s2,a1
    8000514c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000514e:	fdc40593          	addi	a1,s0,-36
    80005152:	ffffe097          	auipc	ra,0xffffe
    80005156:	9c6080e7          	jalr	-1594(ra) # 80002b18 <argint>
    8000515a:	04054063          	bltz	a0,8000519a <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000515e:	fdc42703          	lw	a4,-36(s0)
    80005162:	47bd                	li	a5,15
    80005164:	02e7ed63          	bltu	a5,a4,8000519e <argfd+0x60>
    80005168:	ffffd097          	auipc	ra,0xffffd
    8000516c:	8e0080e7          	jalr	-1824(ra) # 80001a48 <myproc>
    80005170:	fdc42703          	lw	a4,-36(s0)
    80005174:	01a70793          	addi	a5,a4,26
    80005178:	078e                	slli	a5,a5,0x3
    8000517a:	953e                	add	a0,a0,a5
    8000517c:	611c                	ld	a5,0(a0)
    8000517e:	c395                	beqz	a5,800051a2 <argfd+0x64>
    return -1;
  if(pfd)
    80005180:	00090463          	beqz	s2,80005188 <argfd+0x4a>
    *pfd = fd;
    80005184:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005188:	4501                	li	a0,0
  if(pf)
    8000518a:	c091                	beqz	s1,8000518e <argfd+0x50>
    *pf = f;
    8000518c:	e09c                	sd	a5,0(s1)
}
    8000518e:	70a2                	ld	ra,40(sp)
    80005190:	7402                	ld	s0,32(sp)
    80005192:	64e2                	ld	s1,24(sp)
    80005194:	6942                	ld	s2,16(sp)
    80005196:	6145                	addi	sp,sp,48
    80005198:	8082                	ret
    return -1;
    8000519a:	557d                	li	a0,-1
    8000519c:	bfcd                	j	8000518e <argfd+0x50>
    return -1;
    8000519e:	557d                	li	a0,-1
    800051a0:	b7fd                	j	8000518e <argfd+0x50>
    800051a2:	557d                	li	a0,-1
    800051a4:	b7ed                	j	8000518e <argfd+0x50>

00000000800051a6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051a6:	1101                	addi	sp,sp,-32
    800051a8:	ec06                	sd	ra,24(sp)
    800051aa:	e822                	sd	s0,16(sp)
    800051ac:	e426                	sd	s1,8(sp)
    800051ae:	1000                	addi	s0,sp,32
    800051b0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800051b2:	ffffd097          	auipc	ra,0xffffd
    800051b6:	896080e7          	jalr	-1898(ra) # 80001a48 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
    800051ba:	697c                	ld	a5,208(a0)
    800051bc:	c395                	beqz	a5,800051e0 <fdalloc+0x3a>
    800051be:	0d850713          	addi	a4,a0,216
  for(fd = 0; fd < NOFILE; fd++){
    800051c2:	4785                	li	a5,1
    800051c4:	4641                	li	a2,16
    if(p->ofile[fd] == 0){
    800051c6:	6314                	ld	a3,0(a4)
    800051c8:	ce89                	beqz	a3,800051e2 <fdalloc+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
    800051ca:	2785                	addiw	a5,a5,1
    800051cc:	0721                	addi	a4,a4,8
    800051ce:	fec79ce3          	bne	a5,a2,800051c6 <fdalloc+0x20>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800051d2:	57fd                	li	a5,-1
}
    800051d4:	853e                	mv	a0,a5
    800051d6:	60e2                	ld	ra,24(sp)
    800051d8:	6442                	ld	s0,16(sp)
    800051da:	64a2                	ld	s1,8(sp)
    800051dc:	6105                	addi	sp,sp,32
    800051de:	8082                	ret
  for(fd = 0; fd < NOFILE; fd++){
    800051e0:	4781                	li	a5,0
      p->ofile[fd] = f;
    800051e2:	01a78713          	addi	a4,a5,26
    800051e6:	070e                	slli	a4,a4,0x3
    800051e8:	953a                	add	a0,a0,a4
    800051ea:	e104                	sd	s1,0(a0)
      return fd;
    800051ec:	b7e5                	j	800051d4 <fdalloc+0x2e>

00000000800051ee <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800051ee:	715d                	addi	sp,sp,-80
    800051f0:	e486                	sd	ra,72(sp)
    800051f2:	e0a2                	sd	s0,64(sp)
    800051f4:	fc26                	sd	s1,56(sp)
    800051f6:	f84a                	sd	s2,48(sp)
    800051f8:	f44e                	sd	s3,40(sp)
    800051fa:	f052                	sd	s4,32(sp)
    800051fc:	ec56                	sd	s5,24(sp)
    800051fe:	0880                	addi	s0,sp,80
    80005200:	89ae                	mv	s3,a1
    80005202:	8ab2                	mv	s5,a2
    80005204:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005206:	fb040593          	addi	a1,s0,-80
    8000520a:	fffff097          	auipc	ra,0xfffff
    8000520e:	e1a080e7          	jalr	-486(ra) # 80004024 <nameiparent>
    80005212:	892a                	mv	s2,a0
    80005214:	12050f63          	beqz	a0,80005352 <create+0x164>
    return 0;

  ilock(dp);
    80005218:	ffffe097          	auipc	ra,0xffffe
    8000521c:	586080e7          	jalr	1414(ra) # 8000379e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005220:	4601                	li	a2,0
    80005222:	fb040593          	addi	a1,s0,-80
    80005226:	854a                	mv	a0,s2
    80005228:	fffff097          	auipc	ra,0xfffff
    8000522c:	b04080e7          	jalr	-1276(ra) # 80003d2c <dirlookup>
    80005230:	84aa                	mv	s1,a0
    80005232:	c921                	beqz	a0,80005282 <create+0x94>
    iunlockput(dp);
    80005234:	854a                	mv	a0,s2
    80005236:	fffff097          	auipc	ra,0xfffff
    8000523a:	872080e7          	jalr	-1934(ra) # 80003aa8 <iunlockput>
    ilock(ip);
    8000523e:	8526                	mv	a0,s1
    80005240:	ffffe097          	auipc	ra,0xffffe
    80005244:	55e080e7          	jalr	1374(ra) # 8000379e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005248:	2981                	sext.w	s3,s3
    8000524a:	4789                	li	a5,2
    8000524c:	02f99463          	bne	s3,a5,80005274 <create+0x86>
    80005250:	0444d783          	lhu	a5,68(s1)
    80005254:	37f9                	addiw	a5,a5,-2
    80005256:	17c2                	slli	a5,a5,0x30
    80005258:	93c1                	srli	a5,a5,0x30
    8000525a:	4705                	li	a4,1
    8000525c:	00f76c63          	bltu	a4,a5,80005274 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005260:	8526                	mv	a0,s1
    80005262:	60a6                	ld	ra,72(sp)
    80005264:	6406                	ld	s0,64(sp)
    80005266:	74e2                	ld	s1,56(sp)
    80005268:	7942                	ld	s2,48(sp)
    8000526a:	79a2                	ld	s3,40(sp)
    8000526c:	7a02                	ld	s4,32(sp)
    8000526e:	6ae2                	ld	s5,24(sp)
    80005270:	6161                	addi	sp,sp,80
    80005272:	8082                	ret
    iunlockput(ip);
    80005274:	8526                	mv	a0,s1
    80005276:	fffff097          	auipc	ra,0xfffff
    8000527a:	832080e7          	jalr	-1998(ra) # 80003aa8 <iunlockput>
    return 0;
    8000527e:	4481                	li	s1,0
    80005280:	b7c5                	j	80005260 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005282:	85ce                	mv	a1,s3
    80005284:	00092503          	lw	a0,0(s2)
    80005288:	ffffe097          	auipc	ra,0xffffe
    8000528c:	37a080e7          	jalr	890(ra) # 80003602 <ialloc>
    80005290:	84aa                	mv	s1,a0
    80005292:	c529                	beqz	a0,800052dc <create+0xee>
  ilock(ip);
    80005294:	ffffe097          	auipc	ra,0xffffe
    80005298:	50a080e7          	jalr	1290(ra) # 8000379e <ilock>
  ip->major = major;
    8000529c:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800052a0:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800052a4:	4785                	li	a5,1
    800052a6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052aa:	8526                	mv	a0,s1
    800052ac:	ffffe097          	auipc	ra,0xffffe
    800052b0:	426080e7          	jalr	1062(ra) # 800036d2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800052b4:	2981                	sext.w	s3,s3
    800052b6:	4785                	li	a5,1
    800052b8:	02f98a63          	beq	s3,a5,800052ec <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800052bc:	40d0                	lw	a2,4(s1)
    800052be:	fb040593          	addi	a1,s0,-80
    800052c2:	854a                	mv	a0,s2
    800052c4:	fffff097          	auipc	ra,0xfffff
    800052c8:	c80080e7          	jalr	-896(ra) # 80003f44 <dirlink>
    800052cc:	06054b63          	bltz	a0,80005342 <create+0x154>
  iunlockput(dp);
    800052d0:	854a                	mv	a0,s2
    800052d2:	ffffe097          	auipc	ra,0xffffe
    800052d6:	7d6080e7          	jalr	2006(ra) # 80003aa8 <iunlockput>
  return ip;
    800052da:	b759                	j	80005260 <create+0x72>
    panic("create: ialloc");
    800052dc:	00003517          	auipc	a0,0x3
    800052e0:	3ec50513          	addi	a0,a0,1004 # 800086c8 <syscalls+0x2d0>
    800052e4:	ffffb097          	auipc	ra,0xffffb
    800052e8:	274080e7          	jalr	628(ra) # 80000558 <panic>
    dp->nlink++;  // for ".."
    800052ec:	04a95783          	lhu	a5,74(s2)
    800052f0:	2785                	addiw	a5,a5,1
    800052f2:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800052f6:	854a                	mv	a0,s2
    800052f8:	ffffe097          	auipc	ra,0xffffe
    800052fc:	3da080e7          	jalr	986(ra) # 800036d2 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005300:	40d0                	lw	a2,4(s1)
    80005302:	00003597          	auipc	a1,0x3
    80005306:	3d658593          	addi	a1,a1,982 # 800086d8 <syscalls+0x2e0>
    8000530a:	8526                	mv	a0,s1
    8000530c:	fffff097          	auipc	ra,0xfffff
    80005310:	c38080e7          	jalr	-968(ra) # 80003f44 <dirlink>
    80005314:	00054f63          	bltz	a0,80005332 <create+0x144>
    80005318:	00492603          	lw	a2,4(s2)
    8000531c:	00003597          	auipc	a1,0x3
    80005320:	3c458593          	addi	a1,a1,964 # 800086e0 <syscalls+0x2e8>
    80005324:	8526                	mv	a0,s1
    80005326:	fffff097          	auipc	ra,0xfffff
    8000532a:	c1e080e7          	jalr	-994(ra) # 80003f44 <dirlink>
    8000532e:	f80557e3          	bgez	a0,800052bc <create+0xce>
      panic("create dots");
    80005332:	00003517          	auipc	a0,0x3
    80005336:	3b650513          	addi	a0,a0,950 # 800086e8 <syscalls+0x2f0>
    8000533a:	ffffb097          	auipc	ra,0xffffb
    8000533e:	21e080e7          	jalr	542(ra) # 80000558 <panic>
    panic("create: dirlink");
    80005342:	00003517          	auipc	a0,0x3
    80005346:	3b650513          	addi	a0,a0,950 # 800086f8 <syscalls+0x300>
    8000534a:	ffffb097          	auipc	ra,0xffffb
    8000534e:	20e080e7          	jalr	526(ra) # 80000558 <panic>
    return 0;
    80005352:	84aa                	mv	s1,a0
    80005354:	b731                	j	80005260 <create+0x72>

0000000080005356 <sys_dup>:
{
    80005356:	7179                	addi	sp,sp,-48
    80005358:	f406                	sd	ra,40(sp)
    8000535a:	f022                	sd	s0,32(sp)
    8000535c:	ec26                	sd	s1,24(sp)
    8000535e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005360:	fd840613          	addi	a2,s0,-40
    80005364:	4581                	li	a1,0
    80005366:	4501                	li	a0,0
    80005368:	00000097          	auipc	ra,0x0
    8000536c:	dd6080e7          	jalr	-554(ra) # 8000513e <argfd>
    return -1;
    80005370:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005372:	02054363          	bltz	a0,80005398 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005376:	fd843503          	ld	a0,-40(s0)
    8000537a:	00000097          	auipc	ra,0x0
    8000537e:	e2c080e7          	jalr	-468(ra) # 800051a6 <fdalloc>
    80005382:	84aa                	mv	s1,a0
    return -1;
    80005384:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005386:	00054963          	bltz	a0,80005398 <sys_dup+0x42>
  filedup(f);
    8000538a:	fd843503          	ld	a0,-40(s0)
    8000538e:	fffff097          	auipc	ra,0xfffff
    80005392:	348080e7          	jalr	840(ra) # 800046d6 <filedup>
  return fd;
    80005396:	87a6                	mv	a5,s1
}
    80005398:	853e                	mv	a0,a5
    8000539a:	70a2                	ld	ra,40(sp)
    8000539c:	7402                	ld	s0,32(sp)
    8000539e:	64e2                	ld	s1,24(sp)
    800053a0:	6145                	addi	sp,sp,48
    800053a2:	8082                	ret

00000000800053a4 <sys_read>:
{
    800053a4:	7179                	addi	sp,sp,-48
    800053a6:	f406                	sd	ra,40(sp)
    800053a8:	f022                	sd	s0,32(sp)
    800053aa:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053ac:	fe840613          	addi	a2,s0,-24
    800053b0:	4581                	li	a1,0
    800053b2:	4501                	li	a0,0
    800053b4:	00000097          	auipc	ra,0x0
    800053b8:	d8a080e7          	jalr	-630(ra) # 8000513e <argfd>
    return -1;
    800053bc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053be:	04054163          	bltz	a0,80005400 <sys_read+0x5c>
    800053c2:	fe440593          	addi	a1,s0,-28
    800053c6:	4509                	li	a0,2
    800053c8:	ffffd097          	auipc	ra,0xffffd
    800053cc:	750080e7          	jalr	1872(ra) # 80002b18 <argint>
    return -1;
    800053d0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053d2:	02054763          	bltz	a0,80005400 <sys_read+0x5c>
    800053d6:	fd840593          	addi	a1,s0,-40
    800053da:	4505                	li	a0,1
    800053dc:	ffffd097          	auipc	ra,0xffffd
    800053e0:	75e080e7          	jalr	1886(ra) # 80002b3a <argaddr>
    return -1;
    800053e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053e6:	00054d63          	bltz	a0,80005400 <sys_read+0x5c>
  return fileread(f, p, n);
    800053ea:	fe442603          	lw	a2,-28(s0)
    800053ee:	fd843583          	ld	a1,-40(s0)
    800053f2:	fe843503          	ld	a0,-24(s0)
    800053f6:	fffff097          	auipc	ra,0xfffff
    800053fa:	46c080e7          	jalr	1132(ra) # 80004862 <fileread>
    800053fe:	87aa                	mv	a5,a0
}
    80005400:	853e                	mv	a0,a5
    80005402:	70a2                	ld	ra,40(sp)
    80005404:	7402                	ld	s0,32(sp)
    80005406:	6145                	addi	sp,sp,48
    80005408:	8082                	ret

000000008000540a <sys_write>:
{
    8000540a:	7179                	addi	sp,sp,-48
    8000540c:	f406                	sd	ra,40(sp)
    8000540e:	f022                	sd	s0,32(sp)
    80005410:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005412:	fe840613          	addi	a2,s0,-24
    80005416:	4581                	li	a1,0
    80005418:	4501                	li	a0,0
    8000541a:	00000097          	auipc	ra,0x0
    8000541e:	d24080e7          	jalr	-732(ra) # 8000513e <argfd>
    return -1;
    80005422:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005424:	04054163          	bltz	a0,80005466 <sys_write+0x5c>
    80005428:	fe440593          	addi	a1,s0,-28
    8000542c:	4509                	li	a0,2
    8000542e:	ffffd097          	auipc	ra,0xffffd
    80005432:	6ea080e7          	jalr	1770(ra) # 80002b18 <argint>
    return -1;
    80005436:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005438:	02054763          	bltz	a0,80005466 <sys_write+0x5c>
    8000543c:	fd840593          	addi	a1,s0,-40
    80005440:	4505                	li	a0,1
    80005442:	ffffd097          	auipc	ra,0xffffd
    80005446:	6f8080e7          	jalr	1784(ra) # 80002b3a <argaddr>
    return -1;
    8000544a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000544c:	00054d63          	bltz	a0,80005466 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005450:	fe442603          	lw	a2,-28(s0)
    80005454:	fd843583          	ld	a1,-40(s0)
    80005458:	fe843503          	ld	a0,-24(s0)
    8000545c:	fffff097          	auipc	ra,0xfffff
    80005460:	4c8080e7          	jalr	1224(ra) # 80004924 <filewrite>
    80005464:	87aa                	mv	a5,a0
}
    80005466:	853e                	mv	a0,a5
    80005468:	70a2                	ld	ra,40(sp)
    8000546a:	7402                	ld	s0,32(sp)
    8000546c:	6145                	addi	sp,sp,48
    8000546e:	8082                	ret

0000000080005470 <sys_close>:
{
    80005470:	1101                	addi	sp,sp,-32
    80005472:	ec06                	sd	ra,24(sp)
    80005474:	e822                	sd	s0,16(sp)
    80005476:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005478:	fe040613          	addi	a2,s0,-32
    8000547c:	fec40593          	addi	a1,s0,-20
    80005480:	4501                	li	a0,0
    80005482:	00000097          	auipc	ra,0x0
    80005486:	cbc080e7          	jalr	-836(ra) # 8000513e <argfd>
    return -1;
    8000548a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000548c:	02054463          	bltz	a0,800054b4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005490:	ffffc097          	auipc	ra,0xffffc
    80005494:	5b8080e7          	jalr	1464(ra) # 80001a48 <myproc>
    80005498:	fec42783          	lw	a5,-20(s0)
    8000549c:	07e9                	addi	a5,a5,26
    8000549e:	078e                	slli	a5,a5,0x3
    800054a0:	953e                	add	a0,a0,a5
    800054a2:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800054a6:	fe043503          	ld	a0,-32(s0)
    800054aa:	fffff097          	auipc	ra,0xfffff
    800054ae:	27e080e7          	jalr	638(ra) # 80004728 <fileclose>
  return 0;
    800054b2:	4781                	li	a5,0
}
    800054b4:	853e                	mv	a0,a5
    800054b6:	60e2                	ld	ra,24(sp)
    800054b8:	6442                	ld	s0,16(sp)
    800054ba:	6105                	addi	sp,sp,32
    800054bc:	8082                	ret

00000000800054be <sys_fstat>:
{
    800054be:	1101                	addi	sp,sp,-32
    800054c0:	ec06                	sd	ra,24(sp)
    800054c2:	e822                	sd	s0,16(sp)
    800054c4:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800054c6:	fe840613          	addi	a2,s0,-24
    800054ca:	4581                	li	a1,0
    800054cc:	4501                	li	a0,0
    800054ce:	00000097          	auipc	ra,0x0
    800054d2:	c70080e7          	jalr	-912(ra) # 8000513e <argfd>
    return -1;
    800054d6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800054d8:	02054563          	bltz	a0,80005502 <sys_fstat+0x44>
    800054dc:	fe040593          	addi	a1,s0,-32
    800054e0:	4505                	li	a0,1
    800054e2:	ffffd097          	auipc	ra,0xffffd
    800054e6:	658080e7          	jalr	1624(ra) # 80002b3a <argaddr>
    return -1;
    800054ea:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800054ec:	00054b63          	bltz	a0,80005502 <sys_fstat+0x44>
  return filestat(f, st);
    800054f0:	fe043583          	ld	a1,-32(s0)
    800054f4:	fe843503          	ld	a0,-24(s0)
    800054f8:	fffff097          	auipc	ra,0xfffff
    800054fc:	2f8080e7          	jalr	760(ra) # 800047f0 <filestat>
    80005500:	87aa                	mv	a5,a0
}
    80005502:	853e                	mv	a0,a5
    80005504:	60e2                	ld	ra,24(sp)
    80005506:	6442                	ld	s0,16(sp)
    80005508:	6105                	addi	sp,sp,32
    8000550a:	8082                	ret

000000008000550c <sys_link>:
{
    8000550c:	7169                	addi	sp,sp,-304
    8000550e:	f606                	sd	ra,296(sp)
    80005510:	f222                	sd	s0,288(sp)
    80005512:	ee26                	sd	s1,280(sp)
    80005514:	ea4a                	sd	s2,272(sp)
    80005516:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005518:	08000613          	li	a2,128
    8000551c:	ed040593          	addi	a1,s0,-304
    80005520:	4501                	li	a0,0
    80005522:	ffffd097          	auipc	ra,0xffffd
    80005526:	63a080e7          	jalr	1594(ra) # 80002b5c <argstr>
    return -1;
    8000552a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000552c:	10054e63          	bltz	a0,80005648 <sys_link+0x13c>
    80005530:	08000613          	li	a2,128
    80005534:	f5040593          	addi	a1,s0,-176
    80005538:	4505                	li	a0,1
    8000553a:	ffffd097          	auipc	ra,0xffffd
    8000553e:	622080e7          	jalr	1570(ra) # 80002b5c <argstr>
    return -1;
    80005542:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005544:	10054263          	bltz	a0,80005648 <sys_link+0x13c>
  begin_op();
    80005548:	fffff097          	auipc	ra,0xfffff
    8000554c:	cdc080e7          	jalr	-804(ra) # 80004224 <begin_op>
  if((ip = namei(old)) == 0){
    80005550:	ed040513          	addi	a0,s0,-304
    80005554:	fffff097          	auipc	ra,0xfffff
    80005558:	ab2080e7          	jalr	-1358(ra) # 80004006 <namei>
    8000555c:	84aa                	mv	s1,a0
    8000555e:	c551                	beqz	a0,800055ea <sys_link+0xde>
  ilock(ip);
    80005560:	ffffe097          	auipc	ra,0xffffe
    80005564:	23e080e7          	jalr	574(ra) # 8000379e <ilock>
  if(ip->type == T_DIR){
    80005568:	04449703          	lh	a4,68(s1)
    8000556c:	4785                	li	a5,1
    8000556e:	08f70463          	beq	a4,a5,800055f6 <sys_link+0xea>
  ip->nlink++;
    80005572:	04a4d783          	lhu	a5,74(s1)
    80005576:	2785                	addiw	a5,a5,1
    80005578:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000557c:	8526                	mv	a0,s1
    8000557e:	ffffe097          	auipc	ra,0xffffe
    80005582:	154080e7          	jalr	340(ra) # 800036d2 <iupdate>
  iunlock(ip);
    80005586:	8526                	mv	a0,s1
    80005588:	ffffe097          	auipc	ra,0xffffe
    8000558c:	2da080e7          	jalr	730(ra) # 80003862 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005590:	fd040593          	addi	a1,s0,-48
    80005594:	f5040513          	addi	a0,s0,-176
    80005598:	fffff097          	auipc	ra,0xfffff
    8000559c:	a8c080e7          	jalr	-1396(ra) # 80004024 <nameiparent>
    800055a0:	892a                	mv	s2,a0
    800055a2:	c935                	beqz	a0,80005616 <sys_link+0x10a>
  ilock(dp);
    800055a4:	ffffe097          	auipc	ra,0xffffe
    800055a8:	1fa080e7          	jalr	506(ra) # 8000379e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800055ac:	00092703          	lw	a4,0(s2)
    800055b0:	409c                	lw	a5,0(s1)
    800055b2:	04f71d63          	bne	a4,a5,8000560c <sys_link+0x100>
    800055b6:	40d0                	lw	a2,4(s1)
    800055b8:	fd040593          	addi	a1,s0,-48
    800055bc:	854a                	mv	a0,s2
    800055be:	fffff097          	auipc	ra,0xfffff
    800055c2:	986080e7          	jalr	-1658(ra) # 80003f44 <dirlink>
    800055c6:	04054363          	bltz	a0,8000560c <sys_link+0x100>
  iunlockput(dp);
    800055ca:	854a                	mv	a0,s2
    800055cc:	ffffe097          	auipc	ra,0xffffe
    800055d0:	4dc080e7          	jalr	1244(ra) # 80003aa8 <iunlockput>
  iput(ip);
    800055d4:	8526                	mv	a0,s1
    800055d6:	ffffe097          	auipc	ra,0xffffe
    800055da:	42a080e7          	jalr	1066(ra) # 80003a00 <iput>
  end_op();
    800055de:	fffff097          	auipc	ra,0xfffff
    800055e2:	cc6080e7          	jalr	-826(ra) # 800042a4 <end_op>
  return 0;
    800055e6:	4781                	li	a5,0
    800055e8:	a085                	j	80005648 <sys_link+0x13c>
    end_op();
    800055ea:	fffff097          	auipc	ra,0xfffff
    800055ee:	cba080e7          	jalr	-838(ra) # 800042a4 <end_op>
    return -1;
    800055f2:	57fd                	li	a5,-1
    800055f4:	a891                	j	80005648 <sys_link+0x13c>
    iunlockput(ip);
    800055f6:	8526                	mv	a0,s1
    800055f8:	ffffe097          	auipc	ra,0xffffe
    800055fc:	4b0080e7          	jalr	1200(ra) # 80003aa8 <iunlockput>
    end_op();
    80005600:	fffff097          	auipc	ra,0xfffff
    80005604:	ca4080e7          	jalr	-860(ra) # 800042a4 <end_op>
    return -1;
    80005608:	57fd                	li	a5,-1
    8000560a:	a83d                	j	80005648 <sys_link+0x13c>
    iunlockput(dp);
    8000560c:	854a                	mv	a0,s2
    8000560e:	ffffe097          	auipc	ra,0xffffe
    80005612:	49a080e7          	jalr	1178(ra) # 80003aa8 <iunlockput>
  ilock(ip);
    80005616:	8526                	mv	a0,s1
    80005618:	ffffe097          	auipc	ra,0xffffe
    8000561c:	186080e7          	jalr	390(ra) # 8000379e <ilock>
  ip->nlink--;
    80005620:	04a4d783          	lhu	a5,74(s1)
    80005624:	37fd                	addiw	a5,a5,-1
    80005626:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000562a:	8526                	mv	a0,s1
    8000562c:	ffffe097          	auipc	ra,0xffffe
    80005630:	0a6080e7          	jalr	166(ra) # 800036d2 <iupdate>
  iunlockput(ip);
    80005634:	8526                	mv	a0,s1
    80005636:	ffffe097          	auipc	ra,0xffffe
    8000563a:	472080e7          	jalr	1138(ra) # 80003aa8 <iunlockput>
  end_op();
    8000563e:	fffff097          	auipc	ra,0xfffff
    80005642:	c66080e7          	jalr	-922(ra) # 800042a4 <end_op>
  return -1;
    80005646:	57fd                	li	a5,-1
}
    80005648:	853e                	mv	a0,a5
    8000564a:	70b2                	ld	ra,296(sp)
    8000564c:	7412                	ld	s0,288(sp)
    8000564e:	64f2                	ld	s1,280(sp)
    80005650:	6952                	ld	s2,272(sp)
    80005652:	6155                	addi	sp,sp,304
    80005654:	8082                	ret

0000000080005656 <sys_unlink>:
{
    80005656:	7151                	addi	sp,sp,-240
    80005658:	f586                	sd	ra,232(sp)
    8000565a:	f1a2                	sd	s0,224(sp)
    8000565c:	eda6                	sd	s1,216(sp)
    8000565e:	e9ca                	sd	s2,208(sp)
    80005660:	e5ce                	sd	s3,200(sp)
    80005662:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005664:	08000613          	li	a2,128
    80005668:	f3040593          	addi	a1,s0,-208
    8000566c:	4501                	li	a0,0
    8000566e:	ffffd097          	auipc	ra,0xffffd
    80005672:	4ee080e7          	jalr	1262(ra) # 80002b5c <argstr>
    80005676:	16054f63          	bltz	a0,800057f4 <sys_unlink+0x19e>
  begin_op();
    8000567a:	fffff097          	auipc	ra,0xfffff
    8000567e:	baa080e7          	jalr	-1110(ra) # 80004224 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005682:	fb040593          	addi	a1,s0,-80
    80005686:	f3040513          	addi	a0,s0,-208
    8000568a:	fffff097          	auipc	ra,0xfffff
    8000568e:	99a080e7          	jalr	-1638(ra) # 80004024 <nameiparent>
    80005692:	89aa                	mv	s3,a0
    80005694:	c979                	beqz	a0,8000576a <sys_unlink+0x114>
  ilock(dp);
    80005696:	ffffe097          	auipc	ra,0xffffe
    8000569a:	108080e7          	jalr	264(ra) # 8000379e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000569e:	00003597          	auipc	a1,0x3
    800056a2:	03a58593          	addi	a1,a1,58 # 800086d8 <syscalls+0x2e0>
    800056a6:	fb040513          	addi	a0,s0,-80
    800056aa:	ffffe097          	auipc	ra,0xffffe
    800056ae:	668080e7          	jalr	1640(ra) # 80003d12 <namecmp>
    800056b2:	14050863          	beqz	a0,80005802 <sys_unlink+0x1ac>
    800056b6:	00003597          	auipc	a1,0x3
    800056ba:	02a58593          	addi	a1,a1,42 # 800086e0 <syscalls+0x2e8>
    800056be:	fb040513          	addi	a0,s0,-80
    800056c2:	ffffe097          	auipc	ra,0xffffe
    800056c6:	650080e7          	jalr	1616(ra) # 80003d12 <namecmp>
    800056ca:	12050c63          	beqz	a0,80005802 <sys_unlink+0x1ac>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800056ce:	f2c40613          	addi	a2,s0,-212
    800056d2:	fb040593          	addi	a1,s0,-80
    800056d6:	854e                	mv	a0,s3
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	654080e7          	jalr	1620(ra) # 80003d2c <dirlookup>
    800056e0:	84aa                	mv	s1,a0
    800056e2:	12050063          	beqz	a0,80005802 <sys_unlink+0x1ac>
  ilock(ip);
    800056e6:	ffffe097          	auipc	ra,0xffffe
    800056ea:	0b8080e7          	jalr	184(ra) # 8000379e <ilock>
  if(ip->nlink < 1)
    800056ee:	04a49783          	lh	a5,74(s1)
    800056f2:	08f05263          	blez	a5,80005776 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800056f6:	04449703          	lh	a4,68(s1)
    800056fa:	4785                	li	a5,1
    800056fc:	08f70563          	beq	a4,a5,80005786 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005700:	4641                	li	a2,16
    80005702:	4581                	li	a1,0
    80005704:	fc040513          	addi	a0,s0,-64
    80005708:	ffffb097          	auipc	ra,0xffffb
    8000570c:	618080e7          	jalr	1560(ra) # 80000d20 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005710:	4741                	li	a4,16
    80005712:	f2c42683          	lw	a3,-212(s0)
    80005716:	fc040613          	addi	a2,s0,-64
    8000571a:	4581                	li	a1,0
    8000571c:	854e                	mv	a0,s3
    8000571e:	ffffe097          	auipc	ra,0xffffe
    80005722:	4d4080e7          	jalr	1236(ra) # 80003bf2 <writei>
    80005726:	47c1                	li	a5,16
    80005728:	0af51363          	bne	a0,a5,800057ce <sys_unlink+0x178>
  if(ip->type == T_DIR){
    8000572c:	04449703          	lh	a4,68(s1)
    80005730:	4785                	li	a5,1
    80005732:	0af70663          	beq	a4,a5,800057de <sys_unlink+0x188>
  iunlockput(dp);
    80005736:	854e                	mv	a0,s3
    80005738:	ffffe097          	auipc	ra,0xffffe
    8000573c:	370080e7          	jalr	880(ra) # 80003aa8 <iunlockput>
  ip->nlink--;
    80005740:	04a4d783          	lhu	a5,74(s1)
    80005744:	37fd                	addiw	a5,a5,-1
    80005746:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000574a:	8526                	mv	a0,s1
    8000574c:	ffffe097          	auipc	ra,0xffffe
    80005750:	f86080e7          	jalr	-122(ra) # 800036d2 <iupdate>
  iunlockput(ip);
    80005754:	8526                	mv	a0,s1
    80005756:	ffffe097          	auipc	ra,0xffffe
    8000575a:	352080e7          	jalr	850(ra) # 80003aa8 <iunlockput>
  end_op();
    8000575e:	fffff097          	auipc	ra,0xfffff
    80005762:	b46080e7          	jalr	-1210(ra) # 800042a4 <end_op>
  return 0;
    80005766:	4501                	li	a0,0
    80005768:	a07d                	j	80005816 <sys_unlink+0x1c0>
    end_op();
    8000576a:	fffff097          	auipc	ra,0xfffff
    8000576e:	b3a080e7          	jalr	-1222(ra) # 800042a4 <end_op>
    return -1;
    80005772:	557d                	li	a0,-1
    80005774:	a04d                	j	80005816 <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    80005776:	00003517          	auipc	a0,0x3
    8000577a:	f9250513          	addi	a0,a0,-110 # 80008708 <syscalls+0x310>
    8000577e:	ffffb097          	auipc	ra,0xffffb
    80005782:	dda080e7          	jalr	-550(ra) # 80000558 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005786:	44f8                	lw	a4,76(s1)
    80005788:	02000793          	li	a5,32
    8000578c:	f6e7fae3          	bleu	a4,a5,80005700 <sys_unlink+0xaa>
    80005790:	02000913          	li	s2,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005794:	4741                	li	a4,16
    80005796:	86ca                	mv	a3,s2
    80005798:	f1840613          	addi	a2,s0,-232
    8000579c:	4581                	li	a1,0
    8000579e:	8526                	mv	a0,s1
    800057a0:	ffffe097          	auipc	ra,0xffffe
    800057a4:	35a080e7          	jalr	858(ra) # 80003afa <readi>
    800057a8:	47c1                	li	a5,16
    800057aa:	00f51a63          	bne	a0,a5,800057be <sys_unlink+0x168>
    if(de.inum != 0)
    800057ae:	f1845783          	lhu	a5,-232(s0)
    800057b2:	e3b9                	bnez	a5,800057f8 <sys_unlink+0x1a2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057b4:	2941                	addiw	s2,s2,16
    800057b6:	44fc                	lw	a5,76(s1)
    800057b8:	fcf96ee3          	bltu	s2,a5,80005794 <sys_unlink+0x13e>
    800057bc:	b791                	j	80005700 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800057be:	00003517          	auipc	a0,0x3
    800057c2:	f6250513          	addi	a0,a0,-158 # 80008720 <syscalls+0x328>
    800057c6:	ffffb097          	auipc	ra,0xffffb
    800057ca:	d92080e7          	jalr	-622(ra) # 80000558 <panic>
    panic("unlink: writei");
    800057ce:	00003517          	auipc	a0,0x3
    800057d2:	f6a50513          	addi	a0,a0,-150 # 80008738 <syscalls+0x340>
    800057d6:	ffffb097          	auipc	ra,0xffffb
    800057da:	d82080e7          	jalr	-638(ra) # 80000558 <panic>
    dp->nlink--;
    800057de:	04a9d783          	lhu	a5,74(s3)
    800057e2:	37fd                	addiw	a5,a5,-1
    800057e4:	04f99523          	sh	a5,74(s3)
    iupdate(dp);
    800057e8:	854e                	mv	a0,s3
    800057ea:	ffffe097          	auipc	ra,0xffffe
    800057ee:	ee8080e7          	jalr	-280(ra) # 800036d2 <iupdate>
    800057f2:	b791                	j	80005736 <sys_unlink+0xe0>
    return -1;
    800057f4:	557d                	li	a0,-1
    800057f6:	a005                	j	80005816 <sys_unlink+0x1c0>
    iunlockput(ip);
    800057f8:	8526                	mv	a0,s1
    800057fa:	ffffe097          	auipc	ra,0xffffe
    800057fe:	2ae080e7          	jalr	686(ra) # 80003aa8 <iunlockput>
  iunlockput(dp);
    80005802:	854e                	mv	a0,s3
    80005804:	ffffe097          	auipc	ra,0xffffe
    80005808:	2a4080e7          	jalr	676(ra) # 80003aa8 <iunlockput>
  end_op();
    8000580c:	fffff097          	auipc	ra,0xfffff
    80005810:	a98080e7          	jalr	-1384(ra) # 800042a4 <end_op>
  return -1;
    80005814:	557d                	li	a0,-1
}
    80005816:	70ae                	ld	ra,232(sp)
    80005818:	740e                	ld	s0,224(sp)
    8000581a:	64ee                	ld	s1,216(sp)
    8000581c:	694e                	ld	s2,208(sp)
    8000581e:	69ae                	ld	s3,200(sp)
    80005820:	616d                	addi	sp,sp,240
    80005822:	8082                	ret

0000000080005824 <sys_open>:

uint64
sys_open(void)
{
    80005824:	7129                	addi	sp,sp,-320
    80005826:	fe06                	sd	ra,312(sp)
    80005828:	fa22                	sd	s0,304(sp)
    8000582a:	f626                	sd	s1,296(sp)
    8000582c:	f24a                	sd	s2,288(sp)
    8000582e:	ee4e                	sd	s3,280(sp)
    80005830:	ea52                	sd	s4,272(sp)
    80005832:	0280                	addi	s0,sp,320
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n, r;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005834:	08000613          	li	a2,128
    80005838:	f5040593          	addi	a1,s0,-176
    8000583c:	4501                	li	a0,0
    8000583e:	ffffd097          	auipc	ra,0xffffd
    80005842:	31e080e7          	jalr	798(ra) # 80002b5c <argstr>
    return -1;
    80005846:	597d                	li	s2,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005848:	1c054563          	bltz	a0,80005a12 <sys_open+0x1ee>
    8000584c:	f4c40593          	addi	a1,s0,-180
    80005850:	4505                	li	a0,1
    80005852:	ffffd097          	auipc	ra,0xffffd
    80005856:	2c6080e7          	jalr	710(ra) # 80002b18 <argint>
    8000585a:	1a054c63          	bltz	a0,80005a12 <sys_open+0x1ee>
  begin_op();
    8000585e:	fffff097          	auipc	ra,0xfffff
    80005862:	9c6080e7          	jalr	-1594(ra) # 80004224 <begin_op>

  if(omode & O_CREATE){
    80005866:	f4c42783          	lw	a5,-180(s0)
    8000586a:	2007f793          	andi	a5,a5,512
    8000586e:	cbdd                	beqz	a5,80005924 <sys_open+0x100>
    ip = create(path, T_FILE, 0, 0);
    80005870:	4681                	li	a3,0
    80005872:	4601                	li	a2,0
    80005874:	4589                	li	a1,2
    80005876:	f5040513          	addi	a0,s0,-176
    8000587a:	00000097          	auipc	ra,0x0
    8000587e:	974080e7          	jalr	-1676(ra) # 800051ee <create>
    80005882:	84aa                	mv	s1,a0
    if(ip == 0){
    80005884:	c959                	beqz	a0,8000591a <sys_open+0xf6>
    }
  }

  // deal with a symbolic link if it is and no_follow flag is not set
  int depth = 0;
  while (ip->type == T_SYMLINK && !(omode & O_NOFOLLOW)) {
    80005886:	04449783          	lh	a5,68(s1)
    8000588a:	0007869b          	sext.w	a3,a5
    8000588e:	4711                	li	a4,4
    80005890:	18e69a63          	bne	a3,a4,80005a24 <sys_open+0x200>
    80005894:	f4c42703          	lw	a4,-180(s0)
    80005898:	6785                	lui	a5,0x1
    8000589a:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    8000589e:	8ff9                	and	a5,a5,a4
    800058a0:	492d                	li	s2,11
    800058a2:	e7cd                	bnez	a5,8000594c <sys_open+0x128>
    800058a4:	4a11                	li	s4,4
    800058a6:	6985                	lui	s3,0x1
    800058a8:	80098993          	addi	s3,s3,-2048 # 800 <_entry-0x7ffff800>
    char ktarget[MAXPATH];
    memset(ktarget, 0, MAXPATH);
    800058ac:	08000613          	li	a2,128
    800058b0:	4581                	li	a1,0
    800058b2:	ec840513          	addi	a0,s0,-312
    800058b6:	ffffb097          	auipc	ra,0xffffb
    800058ba:	46a080e7          	jalr	1130(ra) # 80000d20 <memset>
    if ((r = readi(ip, 0, (uint64)ktarget, 0, MAXPATH)) < 0) {
    800058be:	08000713          	li	a4,128
    800058c2:	4681                	li	a3,0
    800058c4:	ec840613          	addi	a2,s0,-312
    800058c8:	4581                	li	a1,0
    800058ca:	8526                	mv	a0,s1
    800058cc:	ffffe097          	auipc	ra,0xffffe
    800058d0:	22e080e7          	jalr	558(ra) # 80003afa <readi>
    800058d4:	10054663          	bltz	a0,800059e0 <sys_open+0x1bc>
      iunlockput(ip);
      end_op();
      return -1;
    }
    iunlockput(ip);
    800058d8:	8526                	mv	a0,s1
    800058da:	ffffe097          	auipc	ra,0xffffe
    800058de:	1ce080e7          	jalr	462(ra) # 80003aa8 <iunlockput>
    if((ip = namei(ktarget)) == 0){
    800058e2:	ec840513          	addi	a0,s0,-312
    800058e6:	ffffe097          	auipc	ra,0xffffe
    800058ea:	720080e7          	jalr	1824(ra) # 80004006 <namei>
    800058ee:	84aa                	mv	s1,a0
    800058f0:	10050263          	beqz	a0,800059f4 <sys_open+0x1d0>
      end_op();
      return -1;
    }

    ilock(ip);
    800058f4:	ffffe097          	auipc	ra,0xffffe
    800058f8:	eaa080e7          	jalr	-342(ra) # 8000379e <ilock>
    depth++;
    if (depth > 10) {
    800058fc:	397d                	addiw	s2,s2,-1
    800058fe:	10090063          	beqz	s2,800059fe <sys_open+0x1da>
  while (ip->type == T_SYMLINK && !(omode & O_NOFOLLOW)) {
    80005902:	04449783          	lh	a5,68(s1)
    80005906:	0007871b          	sext.w	a4,a5
    8000590a:	11471d63          	bne	a4,s4,80005a24 <sys_open+0x200>
    8000590e:	f4c42783          	lw	a5,-180(s0)
    80005912:	00f9f7b3          	and	a5,s3,a5
    80005916:	dbd9                	beqz	a5,800058ac <sys_open+0x88>
    80005918:	a815                	j	8000594c <sys_open+0x128>
      end_op();
    8000591a:	fffff097          	auipc	ra,0xfffff
    8000591e:	98a080e7          	jalr	-1654(ra) # 800042a4 <end_op>
      return -1;
    80005922:	a8c5                	j	80005a12 <sys_open+0x1ee>
    if((ip = namei(path)) == 0){
    80005924:	f5040513          	addi	a0,s0,-176
    80005928:	ffffe097          	auipc	ra,0xffffe
    8000592c:	6de080e7          	jalr	1758(ra) # 80004006 <namei>
    80005930:	84aa                	mv	s1,a0
    80005932:	c551                	beqz	a0,800059be <sys_open+0x19a>
    ilock(ip);
    80005934:	ffffe097          	auipc	ra,0xffffe
    80005938:	e6a080e7          	jalr	-406(ra) # 8000379e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000593c:	04449703          	lh	a4,68(s1)
    80005940:	4785                	li	a5,1
    80005942:	f4f712e3          	bne	a4,a5,80005886 <sys_open+0x62>
    80005946:	f4c42783          	lw	a5,-180(s0)
    8000594a:	e3c1                	bnez	a5,800059ca <sys_open+0x1a6>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000594c:	fffff097          	auipc	ra,0xfffff
    80005950:	d0c080e7          	jalr	-756(ra) # 80004658 <filealloc>
    80005954:	89aa                	mv	s3,a0
    80005956:	10050d63          	beqz	a0,80005a70 <sys_open+0x24c>
    8000595a:	00000097          	auipc	ra,0x0
    8000595e:	84c080e7          	jalr	-1972(ra) # 800051a6 <fdalloc>
    80005962:	892a                	mv	s2,a0
    80005964:	10054163          	bltz	a0,80005a66 <sys_open+0x242>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005968:	04449703          	lh	a4,68(s1)
    8000596c:	478d                	li	a5,3
    8000596e:	0cf70f63          	beq	a4,a5,80005a4c <sys_open+0x228>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005972:	4789                	li	a5,2
    80005974:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005978:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000597c:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005980:	f4c42783          	lw	a5,-180(s0)
    80005984:	0017c713          	xori	a4,a5,1
    80005988:	8b05                	andi	a4,a4,1
    8000598a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000598e:	0037f713          	andi	a4,a5,3
    80005992:	00e03733          	snez	a4,a4
    80005996:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000599a:	4007f793          	andi	a5,a5,1024
    8000599e:	c791                	beqz	a5,800059aa <sys_open+0x186>
    800059a0:	04449703          	lh	a4,68(s1)
    800059a4:	4789                	li	a5,2
    800059a6:	0af70a63          	beq	a4,a5,80005a5a <sys_open+0x236>
    itrunc(ip);
  }

  iunlock(ip);
    800059aa:	8526                	mv	a0,s1
    800059ac:	ffffe097          	auipc	ra,0xffffe
    800059b0:	eb6080e7          	jalr	-330(ra) # 80003862 <iunlock>
  end_op();
    800059b4:	fffff097          	auipc	ra,0xfffff
    800059b8:	8f0080e7          	jalr	-1808(ra) # 800042a4 <end_op>

  return fd;
    800059bc:	a899                	j	80005a12 <sys_open+0x1ee>
      end_op();
    800059be:	fffff097          	auipc	ra,0xfffff
    800059c2:	8e6080e7          	jalr	-1818(ra) # 800042a4 <end_op>
      return -1;
    800059c6:	597d                	li	s2,-1
    800059c8:	a0a9                	j	80005a12 <sys_open+0x1ee>
      iunlockput(ip);
    800059ca:	8526                	mv	a0,s1
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	0dc080e7          	jalr	220(ra) # 80003aa8 <iunlockput>
      end_op();
    800059d4:	fffff097          	auipc	ra,0xfffff
    800059d8:	8d0080e7          	jalr	-1840(ra) # 800042a4 <end_op>
      return -1;
    800059dc:	597d                	li	s2,-1
    800059de:	a815                	j	80005a12 <sys_open+0x1ee>
      iunlockput(ip);
    800059e0:	8526                	mv	a0,s1
    800059e2:	ffffe097          	auipc	ra,0xffffe
    800059e6:	0c6080e7          	jalr	198(ra) # 80003aa8 <iunlockput>
      end_op();
    800059ea:	fffff097          	auipc	ra,0xfffff
    800059ee:	8ba080e7          	jalr	-1862(ra) # 800042a4 <end_op>
      return -1;
    800059f2:	a839                	j	80005a10 <sys_open+0x1ec>
      end_op();
    800059f4:	fffff097          	auipc	ra,0xfffff
    800059f8:	8b0080e7          	jalr	-1872(ra) # 800042a4 <end_op>
      return -1;
    800059fc:	a811                	j	80005a10 <sys_open+0x1ec>
      iunlockput(ip);
    800059fe:	8526                	mv	a0,s1
    80005a00:	ffffe097          	auipc	ra,0xffffe
    80005a04:	0a8080e7          	jalr	168(ra) # 80003aa8 <iunlockput>
      end_op();
    80005a08:	fffff097          	auipc	ra,0xfffff
    80005a0c:	89c080e7          	jalr	-1892(ra) # 800042a4 <end_op>
      return -1;
    80005a10:	597d                	li	s2,-1
}
    80005a12:	854a                	mv	a0,s2
    80005a14:	70f2                	ld	ra,312(sp)
    80005a16:	7452                	ld	s0,304(sp)
    80005a18:	74b2                	ld	s1,296(sp)
    80005a1a:	7912                	ld	s2,288(sp)
    80005a1c:	69f2                	ld	s3,280(sp)
    80005a1e:	6a52                	ld	s4,272(sp)
    80005a20:	6131                	addi	sp,sp,320
    80005a22:	8082                	ret
  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a24:	2781                	sext.w	a5,a5
    80005a26:	470d                	li	a4,3
    80005a28:	f2e792e3          	bne	a5,a4,8000594c <sys_open+0x128>
    80005a2c:	0464d703          	lhu	a4,70(s1)
    80005a30:	47a5                	li	a5,9
    80005a32:	f0e7fde3          	bleu	a4,a5,8000594c <sys_open+0x128>
    iunlockput(ip);
    80005a36:	8526                	mv	a0,s1
    80005a38:	ffffe097          	auipc	ra,0xffffe
    80005a3c:	070080e7          	jalr	112(ra) # 80003aa8 <iunlockput>
    end_op();
    80005a40:	fffff097          	auipc	ra,0xfffff
    80005a44:	864080e7          	jalr	-1948(ra) # 800042a4 <end_op>
    return -1;
    80005a48:	597d                	li	s2,-1
    80005a4a:	b7e1                	j	80005a12 <sys_open+0x1ee>
    f->type = FD_DEVICE;
    80005a4c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a50:	04649783          	lh	a5,70(s1)
    80005a54:	02f99223          	sh	a5,36(s3)
    80005a58:	b715                	j	8000597c <sys_open+0x158>
    itrunc(ip);
    80005a5a:	8526                	mv	a0,s1
    80005a5c:	ffffe097          	auipc	ra,0xffffe
    80005a60:	e52080e7          	jalr	-430(ra) # 800038ae <itrunc>
    80005a64:	b799                	j	800059aa <sys_open+0x186>
      fileclose(f);
    80005a66:	854e                	mv	a0,s3
    80005a68:	fffff097          	auipc	ra,0xfffff
    80005a6c:	cc0080e7          	jalr	-832(ra) # 80004728 <fileclose>
    iunlockput(ip);
    80005a70:	8526                	mv	a0,s1
    80005a72:	ffffe097          	auipc	ra,0xffffe
    80005a76:	036080e7          	jalr	54(ra) # 80003aa8 <iunlockput>
    end_op();
    80005a7a:	fffff097          	auipc	ra,0xfffff
    80005a7e:	82a080e7          	jalr	-2006(ra) # 800042a4 <end_op>
    return -1;
    80005a82:	597d                	li	s2,-1
    80005a84:	b779                	j	80005a12 <sys_open+0x1ee>

0000000080005a86 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a86:	7175                	addi	sp,sp,-144
    80005a88:	e506                	sd	ra,136(sp)
    80005a8a:	e122                	sd	s0,128(sp)
    80005a8c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a8e:	ffffe097          	auipc	ra,0xffffe
    80005a92:	796080e7          	jalr	1942(ra) # 80004224 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a96:	08000613          	li	a2,128
    80005a9a:	f7040593          	addi	a1,s0,-144
    80005a9e:	4501                	li	a0,0
    80005aa0:	ffffd097          	auipc	ra,0xffffd
    80005aa4:	0bc080e7          	jalr	188(ra) # 80002b5c <argstr>
    80005aa8:	02054963          	bltz	a0,80005ada <sys_mkdir+0x54>
    80005aac:	4681                	li	a3,0
    80005aae:	4601                	li	a2,0
    80005ab0:	4585                	li	a1,1
    80005ab2:	f7040513          	addi	a0,s0,-144
    80005ab6:	fffff097          	auipc	ra,0xfffff
    80005aba:	738080e7          	jalr	1848(ra) # 800051ee <create>
    80005abe:	cd11                	beqz	a0,80005ada <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ac0:	ffffe097          	auipc	ra,0xffffe
    80005ac4:	fe8080e7          	jalr	-24(ra) # 80003aa8 <iunlockput>
  end_op();
    80005ac8:	ffffe097          	auipc	ra,0xffffe
    80005acc:	7dc080e7          	jalr	2012(ra) # 800042a4 <end_op>
  return 0;
    80005ad0:	4501                	li	a0,0
}
    80005ad2:	60aa                	ld	ra,136(sp)
    80005ad4:	640a                	ld	s0,128(sp)
    80005ad6:	6149                	addi	sp,sp,144
    80005ad8:	8082                	ret
    end_op();
    80005ada:	ffffe097          	auipc	ra,0xffffe
    80005ade:	7ca080e7          	jalr	1994(ra) # 800042a4 <end_op>
    return -1;
    80005ae2:	557d                	li	a0,-1
    80005ae4:	b7fd                	j	80005ad2 <sys_mkdir+0x4c>

0000000080005ae6 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ae6:	7135                	addi	sp,sp,-160
    80005ae8:	ed06                	sd	ra,152(sp)
    80005aea:	e922                	sd	s0,144(sp)
    80005aec:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005aee:	ffffe097          	auipc	ra,0xffffe
    80005af2:	736080e7          	jalr	1846(ra) # 80004224 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005af6:	08000613          	li	a2,128
    80005afa:	f7040593          	addi	a1,s0,-144
    80005afe:	4501                	li	a0,0
    80005b00:	ffffd097          	auipc	ra,0xffffd
    80005b04:	05c080e7          	jalr	92(ra) # 80002b5c <argstr>
    80005b08:	04054a63          	bltz	a0,80005b5c <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005b0c:	f6c40593          	addi	a1,s0,-148
    80005b10:	4505                	li	a0,1
    80005b12:	ffffd097          	auipc	ra,0xffffd
    80005b16:	006080e7          	jalr	6(ra) # 80002b18 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b1a:	04054163          	bltz	a0,80005b5c <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005b1e:	f6840593          	addi	a1,s0,-152
    80005b22:	4509                	li	a0,2
    80005b24:	ffffd097          	auipc	ra,0xffffd
    80005b28:	ff4080e7          	jalr	-12(ra) # 80002b18 <argint>
     argint(1, &major) < 0 ||
    80005b2c:	02054863          	bltz	a0,80005b5c <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b30:	f6841683          	lh	a3,-152(s0)
    80005b34:	f6c41603          	lh	a2,-148(s0)
    80005b38:	458d                	li	a1,3
    80005b3a:	f7040513          	addi	a0,s0,-144
    80005b3e:	fffff097          	auipc	ra,0xfffff
    80005b42:	6b0080e7          	jalr	1712(ra) # 800051ee <create>
     argint(2, &minor) < 0 ||
    80005b46:	c919                	beqz	a0,80005b5c <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b48:	ffffe097          	auipc	ra,0xffffe
    80005b4c:	f60080e7          	jalr	-160(ra) # 80003aa8 <iunlockput>
  end_op();
    80005b50:	ffffe097          	auipc	ra,0xffffe
    80005b54:	754080e7          	jalr	1876(ra) # 800042a4 <end_op>
  return 0;
    80005b58:	4501                	li	a0,0
    80005b5a:	a031                	j	80005b66 <sys_mknod+0x80>
    end_op();
    80005b5c:	ffffe097          	auipc	ra,0xffffe
    80005b60:	748080e7          	jalr	1864(ra) # 800042a4 <end_op>
    return -1;
    80005b64:	557d                	li	a0,-1
}
    80005b66:	60ea                	ld	ra,152(sp)
    80005b68:	644a                	ld	s0,144(sp)
    80005b6a:	610d                	addi	sp,sp,160
    80005b6c:	8082                	ret

0000000080005b6e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b6e:	7135                	addi	sp,sp,-160
    80005b70:	ed06                	sd	ra,152(sp)
    80005b72:	e922                	sd	s0,144(sp)
    80005b74:	e526                	sd	s1,136(sp)
    80005b76:	e14a                	sd	s2,128(sp)
    80005b78:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b7a:	ffffc097          	auipc	ra,0xffffc
    80005b7e:	ece080e7          	jalr	-306(ra) # 80001a48 <myproc>
    80005b82:	892a                	mv	s2,a0
  
  begin_op();
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	6a0080e7          	jalr	1696(ra) # 80004224 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b8c:	08000613          	li	a2,128
    80005b90:	f6040593          	addi	a1,s0,-160
    80005b94:	4501                	li	a0,0
    80005b96:	ffffd097          	auipc	ra,0xffffd
    80005b9a:	fc6080e7          	jalr	-58(ra) # 80002b5c <argstr>
    80005b9e:	04054b63          	bltz	a0,80005bf4 <sys_chdir+0x86>
    80005ba2:	f6040513          	addi	a0,s0,-160
    80005ba6:	ffffe097          	auipc	ra,0xffffe
    80005baa:	460080e7          	jalr	1120(ra) # 80004006 <namei>
    80005bae:	84aa                	mv	s1,a0
    80005bb0:	c131                	beqz	a0,80005bf4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005bb2:	ffffe097          	auipc	ra,0xffffe
    80005bb6:	bec080e7          	jalr	-1044(ra) # 8000379e <ilock>
  if(ip->type != T_DIR){
    80005bba:	04449703          	lh	a4,68(s1)
    80005bbe:	4785                	li	a5,1
    80005bc0:	04f71063          	bne	a4,a5,80005c00 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005bc4:	8526                	mv	a0,s1
    80005bc6:	ffffe097          	auipc	ra,0xffffe
    80005bca:	c9c080e7          	jalr	-868(ra) # 80003862 <iunlock>
  iput(p->cwd);
    80005bce:	15093503          	ld	a0,336(s2)
    80005bd2:	ffffe097          	auipc	ra,0xffffe
    80005bd6:	e2e080e7          	jalr	-466(ra) # 80003a00 <iput>
  end_op();
    80005bda:	ffffe097          	auipc	ra,0xffffe
    80005bde:	6ca080e7          	jalr	1738(ra) # 800042a4 <end_op>
  p->cwd = ip;
    80005be2:	14993823          	sd	s1,336(s2)
  return 0;
    80005be6:	4501                	li	a0,0
}
    80005be8:	60ea                	ld	ra,152(sp)
    80005bea:	644a                	ld	s0,144(sp)
    80005bec:	64aa                	ld	s1,136(sp)
    80005bee:	690a                	ld	s2,128(sp)
    80005bf0:	610d                	addi	sp,sp,160
    80005bf2:	8082                	ret
    end_op();
    80005bf4:	ffffe097          	auipc	ra,0xffffe
    80005bf8:	6b0080e7          	jalr	1712(ra) # 800042a4 <end_op>
    return -1;
    80005bfc:	557d                	li	a0,-1
    80005bfe:	b7ed                	j	80005be8 <sys_chdir+0x7a>
    iunlockput(ip);
    80005c00:	8526                	mv	a0,s1
    80005c02:	ffffe097          	auipc	ra,0xffffe
    80005c06:	ea6080e7          	jalr	-346(ra) # 80003aa8 <iunlockput>
    end_op();
    80005c0a:	ffffe097          	auipc	ra,0xffffe
    80005c0e:	69a080e7          	jalr	1690(ra) # 800042a4 <end_op>
    return -1;
    80005c12:	557d                	li	a0,-1
    80005c14:	bfd1                	j	80005be8 <sys_chdir+0x7a>

0000000080005c16 <sys_exec>:

uint64
sys_exec(void)
{
    80005c16:	7145                	addi	sp,sp,-464
    80005c18:	e786                	sd	ra,456(sp)
    80005c1a:	e3a2                	sd	s0,448(sp)
    80005c1c:	ff26                	sd	s1,440(sp)
    80005c1e:	fb4a                	sd	s2,432(sp)
    80005c20:	f74e                	sd	s3,424(sp)
    80005c22:	f352                	sd	s4,416(sp)
    80005c24:	ef56                	sd	s5,408(sp)
    80005c26:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c28:	08000613          	li	a2,128
    80005c2c:	f4040593          	addi	a1,s0,-192
    80005c30:	4501                	li	a0,0
    80005c32:	ffffd097          	auipc	ra,0xffffd
    80005c36:	f2a080e7          	jalr	-214(ra) # 80002b5c <argstr>
    return -1;
    80005c3a:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c3c:	0e054c63          	bltz	a0,80005d34 <sys_exec+0x11e>
    80005c40:	e3840593          	addi	a1,s0,-456
    80005c44:	4505                	li	a0,1
    80005c46:	ffffd097          	auipc	ra,0xffffd
    80005c4a:	ef4080e7          	jalr	-268(ra) # 80002b3a <argaddr>
    80005c4e:	0e054363          	bltz	a0,80005d34 <sys_exec+0x11e>
  }
  memset(argv, 0, sizeof(argv));
    80005c52:	e4040913          	addi	s2,s0,-448
    80005c56:	10000613          	li	a2,256
    80005c5a:	4581                	li	a1,0
    80005c5c:	854a                	mv	a0,s2
    80005c5e:	ffffb097          	auipc	ra,0xffffb
    80005c62:	0c2080e7          	jalr	194(ra) # 80000d20 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c66:	89ca                	mv	s3,s2
  memset(argv, 0, sizeof(argv));
    80005c68:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005c6a:	02000a93          	li	s5,32
    80005c6e:	00048a1b          	sext.w	s4,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c72:	00349513          	slli	a0,s1,0x3
    80005c76:	e3040593          	addi	a1,s0,-464
    80005c7a:	e3843783          	ld	a5,-456(s0)
    80005c7e:	953e                	add	a0,a0,a5
    80005c80:	ffffd097          	auipc	ra,0xffffd
    80005c84:	dfc080e7          	jalr	-516(ra) # 80002a7c <fetchaddr>
    80005c88:	02054a63          	bltz	a0,80005cbc <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c8c:	e3043783          	ld	a5,-464(s0)
    80005c90:	cfa9                	beqz	a5,80005cea <sys_exec+0xd4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c92:	ffffb097          	auipc	ra,0xffffb
    80005c96:	ea2080e7          	jalr	-350(ra) # 80000b34 <kalloc>
    80005c9a:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80005c9e:	cd19                	beqz	a0,80005cbc <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ca0:	6605                	lui	a2,0x1
    80005ca2:	85aa                	mv	a1,a0
    80005ca4:	e3043503          	ld	a0,-464(s0)
    80005ca8:	ffffd097          	auipc	ra,0xffffd
    80005cac:	e28080e7          	jalr	-472(ra) # 80002ad0 <fetchstr>
    80005cb0:	00054663          	bltz	a0,80005cbc <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005cb4:	0485                	addi	s1,s1,1
    80005cb6:	0921                	addi	s2,s2,8
    80005cb8:	fb549be3          	bne	s1,s5,80005c6e <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cbc:	e4043503          	ld	a0,-448(s0)
    kfree(argv[i]);
  return -1;
    80005cc0:	597d                	li	s2,-1
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cc2:	c92d                	beqz	a0,80005d34 <sys_exec+0x11e>
    kfree(argv[i]);
    80005cc4:	ffffb097          	auipc	ra,0xffffb
    80005cc8:	d70080e7          	jalr	-656(ra) # 80000a34 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ccc:	e4840493          	addi	s1,s0,-440
    80005cd0:	10098993          	addi	s3,s3,256
    80005cd4:	6088                	ld	a0,0(s1)
    80005cd6:	cd31                	beqz	a0,80005d32 <sys_exec+0x11c>
    kfree(argv[i]);
    80005cd8:	ffffb097          	auipc	ra,0xffffb
    80005cdc:	d5c080e7          	jalr	-676(ra) # 80000a34 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ce0:	04a1                	addi	s1,s1,8
    80005ce2:	ff3499e3          	bne	s1,s3,80005cd4 <sys_exec+0xbe>
  return -1;
    80005ce6:	597d                	li	s2,-1
    80005ce8:	a0b1                	j	80005d34 <sys_exec+0x11e>
      argv[i] = 0;
    80005cea:	0a0e                	slli	s4,s4,0x3
    80005cec:	fc040793          	addi	a5,s0,-64
    80005cf0:	9a3e                	add	s4,s4,a5
    80005cf2:	e80a3023          	sd	zero,-384(s4)
  int ret = exec(path, argv);
    80005cf6:	e4040593          	addi	a1,s0,-448
    80005cfa:	f4040513          	addi	a0,s0,-192
    80005cfe:	fffff097          	auipc	ra,0xfffff
    80005d02:	09c080e7          	jalr	156(ra) # 80004d9a <exec>
    80005d06:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d08:	e4043503          	ld	a0,-448(s0)
    80005d0c:	c505                	beqz	a0,80005d34 <sys_exec+0x11e>
    kfree(argv[i]);
    80005d0e:	ffffb097          	auipc	ra,0xffffb
    80005d12:	d26080e7          	jalr	-730(ra) # 80000a34 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d16:	e4840493          	addi	s1,s0,-440
    80005d1a:	10098993          	addi	s3,s3,256
    80005d1e:	6088                	ld	a0,0(s1)
    80005d20:	c911                	beqz	a0,80005d34 <sys_exec+0x11e>
    kfree(argv[i]);
    80005d22:	ffffb097          	auipc	ra,0xffffb
    80005d26:	d12080e7          	jalr	-750(ra) # 80000a34 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d2a:	04a1                	addi	s1,s1,8
    80005d2c:	ff3499e3          	bne	s1,s3,80005d1e <sys_exec+0x108>
    80005d30:	a011                	j	80005d34 <sys_exec+0x11e>
  return -1;
    80005d32:	597d                	li	s2,-1
}
    80005d34:	854a                	mv	a0,s2
    80005d36:	60be                	ld	ra,456(sp)
    80005d38:	641e                	ld	s0,448(sp)
    80005d3a:	74fa                	ld	s1,440(sp)
    80005d3c:	795a                	ld	s2,432(sp)
    80005d3e:	79ba                	ld	s3,424(sp)
    80005d40:	7a1a                	ld	s4,416(sp)
    80005d42:	6afa                	ld	s5,408(sp)
    80005d44:	6179                	addi	sp,sp,464
    80005d46:	8082                	ret

0000000080005d48 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d48:	7139                	addi	sp,sp,-64
    80005d4a:	fc06                	sd	ra,56(sp)
    80005d4c:	f822                	sd	s0,48(sp)
    80005d4e:	f426                	sd	s1,40(sp)
    80005d50:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d52:	ffffc097          	auipc	ra,0xffffc
    80005d56:	cf6080e7          	jalr	-778(ra) # 80001a48 <myproc>
    80005d5a:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d5c:	fd840593          	addi	a1,s0,-40
    80005d60:	4501                	li	a0,0
    80005d62:	ffffd097          	auipc	ra,0xffffd
    80005d66:	dd8080e7          	jalr	-552(ra) # 80002b3a <argaddr>
    return -1;
    80005d6a:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d6c:	0c054f63          	bltz	a0,80005e4a <sys_pipe+0x102>
  if(pipealloc(&rf, &wf) < 0)
    80005d70:	fc840593          	addi	a1,s0,-56
    80005d74:	fd040513          	addi	a0,s0,-48
    80005d78:	fffff097          	auipc	ra,0xfffff
    80005d7c:	cd4080e7          	jalr	-812(ra) # 80004a4c <pipealloc>
    return -1;
    80005d80:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d82:	0c054463          	bltz	a0,80005e4a <sys_pipe+0x102>
  fd0 = -1;
    80005d86:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d8a:	fd043503          	ld	a0,-48(s0)
    80005d8e:	fffff097          	auipc	ra,0xfffff
    80005d92:	418080e7          	jalr	1048(ra) # 800051a6 <fdalloc>
    80005d96:	fca42223          	sw	a0,-60(s0)
    80005d9a:	08054b63          	bltz	a0,80005e30 <sys_pipe+0xe8>
    80005d9e:	fc843503          	ld	a0,-56(s0)
    80005da2:	fffff097          	auipc	ra,0xfffff
    80005da6:	404080e7          	jalr	1028(ra) # 800051a6 <fdalloc>
    80005daa:	fca42023          	sw	a0,-64(s0)
    80005dae:	06054863          	bltz	a0,80005e1e <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005db2:	4691                	li	a3,4
    80005db4:	fc440613          	addi	a2,s0,-60
    80005db8:	fd843583          	ld	a1,-40(s0)
    80005dbc:	68a8                	ld	a0,80(s1)
    80005dbe:	ffffc097          	auipc	ra,0xffffc
    80005dc2:	908080e7          	jalr	-1784(ra) # 800016c6 <copyout>
    80005dc6:	02054063          	bltz	a0,80005de6 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005dca:	4691                	li	a3,4
    80005dcc:	fc040613          	addi	a2,s0,-64
    80005dd0:	fd843583          	ld	a1,-40(s0)
    80005dd4:	0591                	addi	a1,a1,4
    80005dd6:	68a8                	ld	a0,80(s1)
    80005dd8:	ffffc097          	auipc	ra,0xffffc
    80005ddc:	8ee080e7          	jalr	-1810(ra) # 800016c6 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005de0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005de2:	06055463          	bgez	a0,80005e4a <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80005de6:	fc442783          	lw	a5,-60(s0)
    80005dea:	07e9                	addi	a5,a5,26
    80005dec:	078e                	slli	a5,a5,0x3
    80005dee:	97a6                	add	a5,a5,s1
    80005df0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005df4:	fc042783          	lw	a5,-64(s0)
    80005df8:	07e9                	addi	a5,a5,26
    80005dfa:	078e                	slli	a5,a5,0x3
    80005dfc:	94be                	add	s1,s1,a5
    80005dfe:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e02:	fd043503          	ld	a0,-48(s0)
    80005e06:	fffff097          	auipc	ra,0xfffff
    80005e0a:	922080e7          	jalr	-1758(ra) # 80004728 <fileclose>
    fileclose(wf);
    80005e0e:	fc843503          	ld	a0,-56(s0)
    80005e12:	fffff097          	auipc	ra,0xfffff
    80005e16:	916080e7          	jalr	-1770(ra) # 80004728 <fileclose>
    return -1;
    80005e1a:	57fd                	li	a5,-1
    80005e1c:	a03d                	j	80005e4a <sys_pipe+0x102>
    if(fd0 >= 0)
    80005e1e:	fc442783          	lw	a5,-60(s0)
    80005e22:	0007c763          	bltz	a5,80005e30 <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005e26:	07e9                	addi	a5,a5,26
    80005e28:	078e                	slli	a5,a5,0x3
    80005e2a:	94be                	add	s1,s1,a5
    80005e2c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e30:	fd043503          	ld	a0,-48(s0)
    80005e34:	fffff097          	auipc	ra,0xfffff
    80005e38:	8f4080e7          	jalr	-1804(ra) # 80004728 <fileclose>
    fileclose(wf);
    80005e3c:	fc843503          	ld	a0,-56(s0)
    80005e40:	fffff097          	auipc	ra,0xfffff
    80005e44:	8e8080e7          	jalr	-1816(ra) # 80004728 <fileclose>
    return -1;
    80005e48:	57fd                	li	a5,-1
}
    80005e4a:	853e                	mv	a0,a5
    80005e4c:	70e2                	ld	ra,56(sp)
    80005e4e:	7442                	ld	s0,48(sp)
    80005e50:	74a2                	ld	s1,40(sp)
    80005e52:	6121                	addi	sp,sp,64
    80005e54:	8082                	ret

0000000080005e56 <sys_symlink>:

int sys_symlink(char *target, char *path) {
    80005e56:	712d                	addi	sp,sp,-288
    80005e58:	ee06                	sd	ra,280(sp)
    80005e5a:	ea22                	sd	s0,272(sp)
    80005e5c:	e626                	sd	s1,264(sp)
    80005e5e:	e24a                	sd	s2,256(sp)
    80005e60:	1200                	addi	s0,sp,288
  char kpath[MAXPATH], ktarget[MAXPATH];
  memset(kpath, 0, MAXPATH);
    80005e62:	08000613          	li	a2,128
    80005e66:	4581                	li	a1,0
    80005e68:	f6040513          	addi	a0,s0,-160
    80005e6c:	ffffb097          	auipc	ra,0xffffb
    80005e70:	eb4080e7          	jalr	-332(ra) # 80000d20 <memset>
  memset(ktarget, 0, MAXPATH);
    80005e74:	08000613          	li	a2,128
    80005e78:	4581                	li	a1,0
    80005e7a:	ee040513          	addi	a0,s0,-288
    80005e7e:	ffffb097          	auipc	ra,0xffffb
    80005e82:	ea2080e7          	jalr	-350(ra) # 80000d20 <memset>
  struct inode *ip;
  int n, r;

  if((n = argstr(0, ktarget, MAXPATH)) < 0)
    80005e86:	08000613          	li	a2,128
    80005e8a:	ee040593          	addi	a1,s0,-288
    80005e8e:	4501                	li	a0,0
    80005e90:	ffffd097          	auipc	ra,0xffffd
    80005e94:	ccc080e7          	jalr	-820(ra) # 80002b5c <argstr>
    80005e98:	08054163          	bltz	a0,80005f1a <sys_symlink+0xc4>
    return -1;

  if ((n = argstr(1, kpath, MAXPATH)) < 0)
    80005e9c:	08000613          	li	a2,128
    80005ea0:	f6040593          	addi	a1,s0,-160
    80005ea4:	4505                	li	a0,1
    80005ea6:	ffffd097          	auipc	ra,0xffffd
    80005eaa:	cb6080e7          	jalr	-842(ra) # 80002b5c <argstr>
    80005eae:	06054863          	bltz	a0,80005f1e <sys_symlink+0xc8>
    return -1;

  int ret = 0;
  begin_op();
    80005eb2:	ffffe097          	auipc	ra,0xffffe
    80005eb6:	372080e7          	jalr	882(ra) # 80004224 <begin_op>

  if((ip = namei(kpath)) != 0){
    80005eba:	f6040513          	addi	a0,s0,-160
    80005ebe:	ffffe097          	auipc	ra,0xffffe
    80005ec2:	148080e7          	jalr	328(ra) # 80004006 <namei>
    // symlink already exists
    ret = -1;
    80005ec6:	54fd                	li	s1,-1
  if((ip = namei(kpath)) != 0){
    80005ec8:	cd01                	beqz	a0,80005ee0 <sys_symlink+0x8a>
  if ((r = writei(ip, 0, (uint64)ktarget, 0, MAXPATH)) < 0)
    ret = -1;
  iunlockput(ip);

final:
  end_op();
    80005eca:	ffffe097          	auipc	ra,0xffffe
    80005ece:	3da080e7          	jalr	986(ra) # 800042a4 <end_op>
  return ret;
}
    80005ed2:	8526                	mv	a0,s1
    80005ed4:	60f2                	ld	ra,280(sp)
    80005ed6:	6452                	ld	s0,272(sp)
    80005ed8:	64b2                	ld	s1,264(sp)
    80005eda:	6912                	ld	s2,256(sp)
    80005edc:	6115                	addi	sp,sp,288
    80005ede:	8082                	ret
  ip = create(kpath, T_SYMLINK, 0, 0);
    80005ee0:	4681                	li	a3,0
    80005ee2:	4601                	li	a2,0
    80005ee4:	4591                	li	a1,4
    80005ee6:	f6040513          	addi	a0,s0,-160
    80005eea:	fffff097          	auipc	ra,0xfffff
    80005eee:	304080e7          	jalr	772(ra) # 800051ee <create>
    80005ef2:	892a                	mv	s2,a0
  if(ip == 0){
    80005ef4:	d979                	beqz	a0,80005eca <sys_symlink+0x74>
  if ((r = writei(ip, 0, (uint64)ktarget, 0, MAXPATH)) < 0)
    80005ef6:	08000713          	li	a4,128
    80005efa:	4681                	li	a3,0
    80005efc:	ee040613          	addi	a2,s0,-288
    80005f00:	4581                	li	a1,0
    80005f02:	ffffe097          	auipc	ra,0xffffe
    80005f06:	cf0080e7          	jalr	-784(ra) # 80003bf2 <writei>
    80005f0a:	41f5549b          	sraiw	s1,a0,0x1f
  iunlockput(ip);
    80005f0e:	854a                	mv	a0,s2
    80005f10:	ffffe097          	auipc	ra,0xffffe
    80005f14:	b98080e7          	jalr	-1128(ra) # 80003aa8 <iunlockput>
    80005f18:	bf4d                	j	80005eca <sys_symlink+0x74>
    return -1;
    80005f1a:	54fd                	li	s1,-1
    80005f1c:	bf5d                	j	80005ed2 <sys_symlink+0x7c>
    return -1;
    80005f1e:	54fd                	li	s1,-1
    80005f20:	bf4d                	j	80005ed2 <sys_symlink+0x7c>
	...

0000000080005f30 <kernelvec>:
    80005f30:	7111                	addi	sp,sp,-256
    80005f32:	e006                	sd	ra,0(sp)
    80005f34:	e40a                	sd	sp,8(sp)
    80005f36:	e80e                	sd	gp,16(sp)
    80005f38:	ec12                	sd	tp,24(sp)
    80005f3a:	f016                	sd	t0,32(sp)
    80005f3c:	f41a                	sd	t1,40(sp)
    80005f3e:	f81e                	sd	t2,48(sp)
    80005f40:	fc22                	sd	s0,56(sp)
    80005f42:	e0a6                	sd	s1,64(sp)
    80005f44:	e4aa                	sd	a0,72(sp)
    80005f46:	e8ae                	sd	a1,80(sp)
    80005f48:	ecb2                	sd	a2,88(sp)
    80005f4a:	f0b6                	sd	a3,96(sp)
    80005f4c:	f4ba                	sd	a4,104(sp)
    80005f4e:	f8be                	sd	a5,112(sp)
    80005f50:	fcc2                	sd	a6,120(sp)
    80005f52:	e146                	sd	a7,128(sp)
    80005f54:	e54a                	sd	s2,136(sp)
    80005f56:	e94e                	sd	s3,144(sp)
    80005f58:	ed52                	sd	s4,152(sp)
    80005f5a:	f156                	sd	s5,160(sp)
    80005f5c:	f55a                	sd	s6,168(sp)
    80005f5e:	f95e                	sd	s7,176(sp)
    80005f60:	fd62                	sd	s8,184(sp)
    80005f62:	e1e6                	sd	s9,192(sp)
    80005f64:	e5ea                	sd	s10,200(sp)
    80005f66:	e9ee                	sd	s11,208(sp)
    80005f68:	edf2                	sd	t3,216(sp)
    80005f6a:	f1f6                	sd	t4,224(sp)
    80005f6c:	f5fa                	sd	t5,232(sp)
    80005f6e:	f9fe                	sd	t6,240(sp)
    80005f70:	9d5fc0ef          	jal	ra,80002944 <kerneltrap>
    80005f74:	6082                	ld	ra,0(sp)
    80005f76:	6122                	ld	sp,8(sp)
    80005f78:	61c2                	ld	gp,16(sp)
    80005f7a:	7282                	ld	t0,32(sp)
    80005f7c:	7322                	ld	t1,40(sp)
    80005f7e:	73c2                	ld	t2,48(sp)
    80005f80:	7462                	ld	s0,56(sp)
    80005f82:	6486                	ld	s1,64(sp)
    80005f84:	6526                	ld	a0,72(sp)
    80005f86:	65c6                	ld	a1,80(sp)
    80005f88:	6666                	ld	a2,88(sp)
    80005f8a:	7686                	ld	a3,96(sp)
    80005f8c:	7726                	ld	a4,104(sp)
    80005f8e:	77c6                	ld	a5,112(sp)
    80005f90:	7866                	ld	a6,120(sp)
    80005f92:	688a                	ld	a7,128(sp)
    80005f94:	692a                	ld	s2,136(sp)
    80005f96:	69ca                	ld	s3,144(sp)
    80005f98:	6a6a                	ld	s4,152(sp)
    80005f9a:	7a8a                	ld	s5,160(sp)
    80005f9c:	7b2a                	ld	s6,168(sp)
    80005f9e:	7bca                	ld	s7,176(sp)
    80005fa0:	7c6a                	ld	s8,184(sp)
    80005fa2:	6c8e                	ld	s9,192(sp)
    80005fa4:	6d2e                	ld	s10,200(sp)
    80005fa6:	6dce                	ld	s11,208(sp)
    80005fa8:	6e6e                	ld	t3,216(sp)
    80005faa:	7e8e                	ld	t4,224(sp)
    80005fac:	7f2e                	ld	t5,232(sp)
    80005fae:	7fce                	ld	t6,240(sp)
    80005fb0:	6111                	addi	sp,sp,256
    80005fb2:	10200073          	sret
    80005fb6:	00000013          	nop
    80005fba:	00000013          	nop
    80005fbe:	0001                	nop

0000000080005fc0 <timervec>:
    80005fc0:	34051573          	csrrw	a0,mscratch,a0
    80005fc4:	e10c                	sd	a1,0(a0)
    80005fc6:	e510                	sd	a2,8(a0)
    80005fc8:	e914                	sd	a3,16(a0)
    80005fca:	6d0c                	ld	a1,24(a0)
    80005fcc:	7110                	ld	a2,32(a0)
    80005fce:	6194                	ld	a3,0(a1)
    80005fd0:	96b2                	add	a3,a3,a2
    80005fd2:	e194                	sd	a3,0(a1)
    80005fd4:	4589                	li	a1,2
    80005fd6:	14459073          	csrw	sip,a1
    80005fda:	6914                	ld	a3,16(a0)
    80005fdc:	6510                	ld	a2,8(a0)
    80005fde:	610c                	ld	a1,0(a0)
    80005fe0:	34051573          	csrrw	a0,mscratch,a0
    80005fe4:	30200073          	mret
	...

0000000080005fea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005fea:	1141                	addi	sp,sp,-16
    80005fec:	e422                	sd	s0,8(sp)
    80005fee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ff0:	0c0007b7          	lui	a5,0xc000
    80005ff4:	4705                	li	a4,1
    80005ff6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ff8:	c3d8                	sw	a4,4(a5)
}
    80005ffa:	6422                	ld	s0,8(sp)
    80005ffc:	0141                	addi	sp,sp,16
    80005ffe:	8082                	ret

0000000080006000 <plicinithart>:

void
plicinithart(void)
{
    80006000:	1141                	addi	sp,sp,-16
    80006002:	e406                	sd	ra,8(sp)
    80006004:	e022                	sd	s0,0(sp)
    80006006:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006008:	ffffc097          	auipc	ra,0xffffc
    8000600c:	a14080e7          	jalr	-1516(ra) # 80001a1c <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006010:	0085171b          	slliw	a4,a0,0x8
    80006014:	0c0027b7          	lui	a5,0xc002
    80006018:	97ba                	add	a5,a5,a4
    8000601a:	40200713          	li	a4,1026
    8000601e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006022:	00d5151b          	slliw	a0,a0,0xd
    80006026:	0c2017b7          	lui	a5,0xc201
    8000602a:	953e                	add	a0,a0,a5
    8000602c:	00052023          	sw	zero,0(a0)
}
    80006030:	60a2                	ld	ra,8(sp)
    80006032:	6402                	ld	s0,0(sp)
    80006034:	0141                	addi	sp,sp,16
    80006036:	8082                	ret

0000000080006038 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006038:	1141                	addi	sp,sp,-16
    8000603a:	e406                	sd	ra,8(sp)
    8000603c:	e022                	sd	s0,0(sp)
    8000603e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006040:	ffffc097          	auipc	ra,0xffffc
    80006044:	9dc080e7          	jalr	-1572(ra) # 80001a1c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006048:	00d5151b          	slliw	a0,a0,0xd
    8000604c:	0c2017b7          	lui	a5,0xc201
    80006050:	97aa                	add	a5,a5,a0
  return irq;
}
    80006052:	43c8                	lw	a0,4(a5)
    80006054:	60a2                	ld	ra,8(sp)
    80006056:	6402                	ld	s0,0(sp)
    80006058:	0141                	addi	sp,sp,16
    8000605a:	8082                	ret

000000008000605c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000605c:	1101                	addi	sp,sp,-32
    8000605e:	ec06                	sd	ra,24(sp)
    80006060:	e822                	sd	s0,16(sp)
    80006062:	e426                	sd	s1,8(sp)
    80006064:	1000                	addi	s0,sp,32
    80006066:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006068:	ffffc097          	auipc	ra,0xffffc
    8000606c:	9b4080e7          	jalr	-1612(ra) # 80001a1c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006070:	00d5151b          	slliw	a0,a0,0xd
    80006074:	0c2017b7          	lui	a5,0xc201
    80006078:	97aa                	add	a5,a5,a0
    8000607a:	c3c4                	sw	s1,4(a5)
}
    8000607c:	60e2                	ld	ra,24(sp)
    8000607e:	6442                	ld	s0,16(sp)
    80006080:	64a2                	ld	s1,8(sp)
    80006082:	6105                	addi	sp,sp,32
    80006084:	8082                	ret

0000000080006086 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006086:	1141                	addi	sp,sp,-16
    80006088:	e406                	sd	ra,8(sp)
    8000608a:	e022                	sd	s0,0(sp)
    8000608c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000608e:	479d                	li	a5,7
    80006090:	06a7c963          	blt	a5,a0,80006102 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006094:	00018797          	auipc	a5,0x18
    80006098:	f6c78793          	addi	a5,a5,-148 # 8001e000 <disk>
    8000609c:	00a78733          	add	a4,a5,a0
    800060a0:	6789                	lui	a5,0x2
    800060a2:	97ba                	add	a5,a5,a4
    800060a4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800060a8:	e7ad                	bnez	a5,80006112 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800060aa:	00451793          	slli	a5,a0,0x4
    800060ae:	0001a717          	auipc	a4,0x1a
    800060b2:	f5270713          	addi	a4,a4,-174 # 80020000 <disk+0x2000>
    800060b6:	6314                	ld	a3,0(a4)
    800060b8:	96be                	add	a3,a3,a5
    800060ba:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800060be:	6314                	ld	a3,0(a4)
    800060c0:	96be                	add	a3,a3,a5
    800060c2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800060c6:	6314                	ld	a3,0(a4)
    800060c8:	96be                	add	a3,a3,a5
    800060ca:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800060ce:	6318                	ld	a4,0(a4)
    800060d0:	97ba                	add	a5,a5,a4
    800060d2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800060d6:	00018797          	auipc	a5,0x18
    800060da:	f2a78793          	addi	a5,a5,-214 # 8001e000 <disk>
    800060de:	97aa                	add	a5,a5,a0
    800060e0:	6509                	lui	a0,0x2
    800060e2:	953e                	add	a0,a0,a5
    800060e4:	4785                	li	a5,1
    800060e6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800060ea:	0001a517          	auipc	a0,0x1a
    800060ee:	f2e50513          	addi	a0,a0,-210 # 80020018 <disk+0x2018>
    800060f2:	ffffc097          	auipc	ra,0xffffc
    800060f6:	2f6080e7          	jalr	758(ra) # 800023e8 <wakeup>
}
    800060fa:	60a2                	ld	ra,8(sp)
    800060fc:	6402                	ld	s0,0(sp)
    800060fe:	0141                	addi	sp,sp,16
    80006100:	8082                	ret
    panic("free_desc 1");
    80006102:	00002517          	auipc	a0,0x2
    80006106:	64650513          	addi	a0,a0,1606 # 80008748 <syscalls+0x350>
    8000610a:	ffffa097          	auipc	ra,0xffffa
    8000610e:	44e080e7          	jalr	1102(ra) # 80000558 <panic>
    panic("free_desc 2");
    80006112:	00002517          	auipc	a0,0x2
    80006116:	64650513          	addi	a0,a0,1606 # 80008758 <syscalls+0x360>
    8000611a:	ffffa097          	auipc	ra,0xffffa
    8000611e:	43e080e7          	jalr	1086(ra) # 80000558 <panic>

0000000080006122 <virtio_disk_init>:
{
    80006122:	1101                	addi	sp,sp,-32
    80006124:	ec06                	sd	ra,24(sp)
    80006126:	e822                	sd	s0,16(sp)
    80006128:	e426                	sd	s1,8(sp)
    8000612a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000612c:	00002597          	auipc	a1,0x2
    80006130:	63c58593          	addi	a1,a1,1596 # 80008768 <syscalls+0x370>
    80006134:	0001a517          	auipc	a0,0x1a
    80006138:	ff450513          	addi	a0,a0,-12 # 80020128 <disk+0x2128>
    8000613c:	ffffb097          	auipc	ra,0xffffb
    80006140:	a58080e7          	jalr	-1448(ra) # 80000b94 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006144:	100017b7          	lui	a5,0x10001
    80006148:	4398                	lw	a4,0(a5)
    8000614a:	2701                	sext.w	a4,a4
    8000614c:	747277b7          	lui	a5,0x74727
    80006150:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006154:	0ef71163          	bne	a4,a5,80006236 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006158:	100017b7          	lui	a5,0x10001
    8000615c:	43dc                	lw	a5,4(a5)
    8000615e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006160:	4705                	li	a4,1
    80006162:	0ce79a63          	bne	a5,a4,80006236 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006166:	100017b7          	lui	a5,0x10001
    8000616a:	479c                	lw	a5,8(a5)
    8000616c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000616e:	4709                	li	a4,2
    80006170:	0ce79363          	bne	a5,a4,80006236 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006174:	100017b7          	lui	a5,0x10001
    80006178:	47d8                	lw	a4,12(a5)
    8000617a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000617c:	554d47b7          	lui	a5,0x554d4
    80006180:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006184:	0af71963          	bne	a4,a5,80006236 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006188:	100017b7          	lui	a5,0x10001
    8000618c:	4705                	li	a4,1
    8000618e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006190:	470d                	li	a4,3
    80006192:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006194:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006196:	c7ffe737          	lui	a4,0xc7ffe
    8000619a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd75f>
    8000619e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061a0:	2701                	sext.w	a4,a4
    800061a2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061a4:	472d                	li	a4,11
    800061a6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061a8:	473d                	li	a4,15
    800061aa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800061ac:	6705                	lui	a4,0x1
    800061ae:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800061b0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800061b4:	5bdc                	lw	a5,52(a5)
    800061b6:	2781                	sext.w	a5,a5
  if(max == 0)
    800061b8:	c7d9                	beqz	a5,80006246 <virtio_disk_init+0x124>
  if(max < NUM)
    800061ba:	471d                	li	a4,7
    800061bc:	08f77d63          	bleu	a5,a4,80006256 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061c0:	100014b7          	lui	s1,0x10001
    800061c4:	47a1                	li	a5,8
    800061c6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800061c8:	6609                	lui	a2,0x2
    800061ca:	4581                	li	a1,0
    800061cc:	00018517          	auipc	a0,0x18
    800061d0:	e3450513          	addi	a0,a0,-460 # 8001e000 <disk>
    800061d4:	ffffb097          	auipc	ra,0xffffb
    800061d8:	b4c080e7          	jalr	-1204(ra) # 80000d20 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800061dc:	00018717          	auipc	a4,0x18
    800061e0:	e2470713          	addi	a4,a4,-476 # 8001e000 <disk>
    800061e4:	00c75793          	srli	a5,a4,0xc
    800061e8:	2781                	sext.w	a5,a5
    800061ea:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    800061ec:	0001a797          	auipc	a5,0x1a
    800061f0:	e1478793          	addi	a5,a5,-492 # 80020000 <disk+0x2000>
    800061f4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800061f6:	00018717          	auipc	a4,0x18
    800061fa:	e8a70713          	addi	a4,a4,-374 # 8001e080 <disk+0x80>
    800061fe:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006200:	00019717          	auipc	a4,0x19
    80006204:	e0070713          	addi	a4,a4,-512 # 8001f000 <disk+0x1000>
    80006208:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000620a:	4705                	li	a4,1
    8000620c:	00e78c23          	sb	a4,24(a5)
    80006210:	00e78ca3          	sb	a4,25(a5)
    80006214:	00e78d23          	sb	a4,26(a5)
    80006218:	00e78da3          	sb	a4,27(a5)
    8000621c:	00e78e23          	sb	a4,28(a5)
    80006220:	00e78ea3          	sb	a4,29(a5)
    80006224:	00e78f23          	sb	a4,30(a5)
    80006228:	00e78fa3          	sb	a4,31(a5)
}
    8000622c:	60e2                	ld	ra,24(sp)
    8000622e:	6442                	ld	s0,16(sp)
    80006230:	64a2                	ld	s1,8(sp)
    80006232:	6105                	addi	sp,sp,32
    80006234:	8082                	ret
    panic("could not find virtio disk");
    80006236:	00002517          	auipc	a0,0x2
    8000623a:	54250513          	addi	a0,a0,1346 # 80008778 <syscalls+0x380>
    8000623e:	ffffa097          	auipc	ra,0xffffa
    80006242:	31a080e7          	jalr	794(ra) # 80000558 <panic>
    panic("virtio disk has no queue 0");
    80006246:	00002517          	auipc	a0,0x2
    8000624a:	55250513          	addi	a0,a0,1362 # 80008798 <syscalls+0x3a0>
    8000624e:	ffffa097          	auipc	ra,0xffffa
    80006252:	30a080e7          	jalr	778(ra) # 80000558 <panic>
    panic("virtio disk max queue too short");
    80006256:	00002517          	auipc	a0,0x2
    8000625a:	56250513          	addi	a0,a0,1378 # 800087b8 <syscalls+0x3c0>
    8000625e:	ffffa097          	auipc	ra,0xffffa
    80006262:	2fa080e7          	jalr	762(ra) # 80000558 <panic>

0000000080006266 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006266:	711d                	addi	sp,sp,-96
    80006268:	ec86                	sd	ra,88(sp)
    8000626a:	e8a2                	sd	s0,80(sp)
    8000626c:	e4a6                	sd	s1,72(sp)
    8000626e:	e0ca                	sd	s2,64(sp)
    80006270:	fc4e                	sd	s3,56(sp)
    80006272:	f852                	sd	s4,48(sp)
    80006274:	f456                	sd	s5,40(sp)
    80006276:	f05a                	sd	s6,32(sp)
    80006278:	ec5e                	sd	s7,24(sp)
    8000627a:	e862                	sd	s8,16(sp)
    8000627c:	1080                	addi	s0,sp,96
    8000627e:	892a                	mv	s2,a0
    80006280:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006282:	00c52b83          	lw	s7,12(a0)
    80006286:	001b9b9b          	slliw	s7,s7,0x1
    8000628a:	1b82                	slli	s7,s7,0x20
    8000628c:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80006290:	0001a517          	auipc	a0,0x1a
    80006294:	e9850513          	addi	a0,a0,-360 # 80020128 <disk+0x2128>
    80006298:	ffffb097          	auipc	ra,0xffffb
    8000629c:	98c080e7          	jalr	-1652(ra) # 80000c24 <acquire>
    if(disk.free[i]){
    800062a0:	0001a997          	auipc	s3,0x1a
    800062a4:	d6098993          	addi	s3,s3,-672 # 80020000 <disk+0x2000>
  for(int i = 0; i < NUM; i++){
    800062a8:	4b21                	li	s6,8
      disk.free[i] = 0;
    800062aa:	00018a97          	auipc	s5,0x18
    800062ae:	d56a8a93          	addi	s5,s5,-682 # 8001e000 <disk>
  for(int i = 0; i < 3; i++){
    800062b2:	4a0d                	li	s4,3
    800062b4:	a079                	j	80006342 <virtio_disk_rw+0xdc>
      disk.free[i] = 0;
    800062b6:	00fa86b3          	add	a3,s5,a5
    800062ba:	96ae                	add	a3,a3,a1
    800062bc:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800062c0:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800062c2:	0207ca63          	bltz	a5,800062f6 <virtio_disk_rw+0x90>
  for(int i = 0; i < 3; i++){
    800062c6:	2485                	addiw	s1,s1,1
    800062c8:	0711                	addi	a4,a4,4
    800062ca:	25448b63          	beq	s1,s4,80006520 <virtio_disk_rw+0x2ba>
    idx[i] = alloc_desc();
    800062ce:	863a                	mv	a2,a4
    if(disk.free[i]){
    800062d0:	0189c783          	lbu	a5,24(s3)
    800062d4:	26079e63          	bnez	a5,80006550 <virtio_disk_rw+0x2ea>
    800062d8:	0001a697          	auipc	a3,0x1a
    800062dc:	d4168693          	addi	a3,a3,-703 # 80020019 <disk+0x2019>
  for(int i = 0; i < NUM; i++){
    800062e0:	87aa                	mv	a5,a0
    if(disk.free[i]){
    800062e2:	0006c803          	lbu	a6,0(a3)
    800062e6:	fc0818e3          	bnez	a6,800062b6 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800062ea:	2785                	addiw	a5,a5,1
    800062ec:	0685                	addi	a3,a3,1
    800062ee:	ff679ae3          	bne	a5,s6,800062e2 <virtio_disk_rw+0x7c>
    idx[i] = alloc_desc();
    800062f2:	57fd                	li	a5,-1
    800062f4:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800062f6:	02905a63          	blez	s1,8000632a <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800062fa:	fa042503          	lw	a0,-96(s0)
    800062fe:	00000097          	auipc	ra,0x0
    80006302:	d88080e7          	jalr	-632(ra) # 80006086 <free_desc>
      for(int j = 0; j < i; j++)
    80006306:	4785                	li	a5,1
    80006308:	0297d163          	ble	s1,a5,8000632a <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    8000630c:	fa442503          	lw	a0,-92(s0)
    80006310:	00000097          	auipc	ra,0x0
    80006314:	d76080e7          	jalr	-650(ra) # 80006086 <free_desc>
      for(int j = 0; j < i; j++)
    80006318:	4789                	li	a5,2
    8000631a:	0097d863          	ble	s1,a5,8000632a <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    8000631e:	fa842503          	lw	a0,-88(s0)
    80006322:	00000097          	auipc	ra,0x0
    80006326:	d64080e7          	jalr	-668(ra) # 80006086 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000632a:	0001a597          	auipc	a1,0x1a
    8000632e:	dfe58593          	addi	a1,a1,-514 # 80020128 <disk+0x2128>
    80006332:	0001a517          	auipc	a0,0x1a
    80006336:	ce650513          	addi	a0,a0,-794 # 80020018 <disk+0x2018>
    8000633a:	ffffc097          	auipc	ra,0xffffc
    8000633e:	f28080e7          	jalr	-216(ra) # 80002262 <sleep>
  for(int i = 0; i < 3; i++){
    80006342:	fa040713          	addi	a4,s0,-96
    80006346:	4481                	li	s1,0
  for(int i = 0; i < NUM; i++){
    80006348:	4505                	li	a0,1
      disk.free[i] = 0;
    8000634a:	6589                	lui	a1,0x2
    8000634c:	b749                	j	800062ce <virtio_disk_rw+0x68>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    8000634e:	20058793          	addi	a5,a1,512 # 2200 <_entry-0x7fffde00>
    80006352:	00479613          	slli	a2,a5,0x4
    80006356:	00018797          	auipc	a5,0x18
    8000635a:	caa78793          	addi	a5,a5,-854 # 8001e000 <disk>
    8000635e:	97b2                	add	a5,a5,a2
    80006360:	4605                	li	a2,1
    80006362:	0ac7a423          	sw	a2,168(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006366:	20058793          	addi	a5,a1,512
    8000636a:	00479613          	slli	a2,a5,0x4
    8000636e:	00018797          	auipc	a5,0x18
    80006372:	c9278793          	addi	a5,a5,-878 # 8001e000 <disk>
    80006376:	97b2                	add	a5,a5,a2
    80006378:	0a07a623          	sw	zero,172(a5)
  buf0->sector = sector;
    8000637c:	0b77b823          	sd	s7,176(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006380:	0001a797          	auipc	a5,0x1a
    80006384:	c8078793          	addi	a5,a5,-896 # 80020000 <disk+0x2000>
    80006388:	6390                	ld	a2,0(a5)
    8000638a:	963a                	add	a2,a2,a4
    8000638c:	7779                	lui	a4,0xffffe
    8000638e:	9732                	add	a4,a4,a2
    80006390:	e314                	sd	a3,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006392:	00459713          	slli	a4,a1,0x4
    80006396:	6394                	ld	a3,0(a5)
    80006398:	96ba                	add	a3,a3,a4
    8000639a:	4641                	li	a2,16
    8000639c:	c690                	sw	a2,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000639e:	6394                	ld	a3,0(a5)
    800063a0:	96ba                	add	a3,a3,a4
    800063a2:	4605                	li	a2,1
    800063a4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800063a8:	fa442683          	lw	a3,-92(s0)
    800063ac:	6390                	ld	a2,0(a5)
    800063ae:	963a                	add	a2,a2,a4
    800063b0:	00d61723          	sh	a3,14(a2) # 200e <_entry-0x7fffdff2>

  disk.desc[idx[1]].addr = (uint64) b->data;
    800063b4:	0692                	slli	a3,a3,0x4
    800063b6:	6390                	ld	a2,0(a5)
    800063b8:	9636                	add	a2,a2,a3
    800063ba:	05890513          	addi	a0,s2,88
    800063be:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800063c0:	639c                	ld	a5,0(a5)
    800063c2:	97b6                	add	a5,a5,a3
    800063c4:	40000613          	li	a2,1024
    800063c8:	c790                	sw	a2,8(a5)
  if(write)
    800063ca:	140c0163          	beqz	s8,8000650c <virtio_disk_rw+0x2a6>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800063ce:	0001a797          	auipc	a5,0x1a
    800063d2:	c3278793          	addi	a5,a5,-974 # 80020000 <disk+0x2000>
    800063d6:	639c                	ld	a5,0(a5)
    800063d8:	97b6                	add	a5,a5,a3
    800063da:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800063de:	00018897          	auipc	a7,0x18
    800063e2:	c2288893          	addi	a7,a7,-990 # 8001e000 <disk>
    800063e6:	0001a797          	auipc	a5,0x1a
    800063ea:	c1a78793          	addi	a5,a5,-998 # 80020000 <disk+0x2000>
    800063ee:	6390                	ld	a2,0(a5)
    800063f0:	9636                	add	a2,a2,a3
    800063f2:	00c65503          	lhu	a0,12(a2)
    800063f6:	00156513          	ori	a0,a0,1
    800063fa:	00a61623          	sh	a0,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800063fe:	fa842603          	lw	a2,-88(s0)
    80006402:	6388                	ld	a0,0(a5)
    80006404:	96aa                	add	a3,a3,a0
    80006406:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000640a:	20058513          	addi	a0,a1,512
    8000640e:	0512                	slli	a0,a0,0x4
    80006410:	9546                	add	a0,a0,a7
    80006412:	56fd                	li	a3,-1
    80006414:	02d50823          	sb	a3,48(a0)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006418:	00461693          	slli	a3,a2,0x4
    8000641c:	6390                	ld	a2,0(a5)
    8000641e:	9636                	add	a2,a2,a3
    80006420:	6809                	lui	a6,0x2
    80006422:	03080813          	addi	a6,a6,48 # 2030 <_entry-0x7fffdfd0>
    80006426:	9742                	add	a4,a4,a6
    80006428:	9746                	add	a4,a4,a7
    8000642a:	e218                	sd	a4,0(a2)
  disk.desc[idx[2]].len = 1;
    8000642c:	6398                	ld	a4,0(a5)
    8000642e:	9736                	add	a4,a4,a3
    80006430:	4605                	li	a2,1
    80006432:	c710                	sw	a2,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006434:	6398                	ld	a4,0(a5)
    80006436:	9736                	add	a4,a4,a3
    80006438:	4809                	li	a6,2
    8000643a:	01071623          	sh	a6,12(a4) # ffffffffffffe00c <end+0xffffffff7ffdd00c>
  disk.desc[idx[2]].next = 0;
    8000643e:	6398                	ld	a4,0(a5)
    80006440:	96ba                	add	a3,a3,a4
    80006442:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006446:	00c92223          	sw	a2,4(s2)
  disk.info[idx[0]].b = b;
    8000644a:	03253423          	sd	s2,40(a0)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000644e:	6794                	ld	a3,8(a5)
    80006450:	0026d703          	lhu	a4,2(a3)
    80006454:	8b1d                	andi	a4,a4,7
    80006456:	0706                	slli	a4,a4,0x1
    80006458:	9736                	add	a4,a4,a3
    8000645a:	00b71223          	sh	a1,4(a4)

  __sync_synchronize();
    8000645e:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006462:	6798                	ld	a4,8(a5)
    80006464:	00275783          	lhu	a5,2(a4)
    80006468:	2785                	addiw	a5,a5,1
    8000646a:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000646e:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006472:	100017b7          	lui	a5,0x10001
    80006476:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000647a:	00492703          	lw	a4,4(s2)
    8000647e:	4785                	li	a5,1
    80006480:	02f71163          	bne	a4,a5,800064a2 <virtio_disk_rw+0x23c>
    sleep(b, &disk.vdisk_lock);
    80006484:	0001a997          	auipc	s3,0x1a
    80006488:	ca498993          	addi	s3,s3,-860 # 80020128 <disk+0x2128>
  while(b->disk == 1) {
    8000648c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000648e:	85ce                	mv	a1,s3
    80006490:	854a                	mv	a0,s2
    80006492:	ffffc097          	auipc	ra,0xffffc
    80006496:	dd0080e7          	jalr	-560(ra) # 80002262 <sleep>
  while(b->disk == 1) {
    8000649a:	00492783          	lw	a5,4(s2)
    8000649e:	fe9788e3          	beq	a5,s1,8000648e <virtio_disk_rw+0x228>
  }

  disk.info[idx[0]].b = 0;
    800064a2:	fa042503          	lw	a0,-96(s0)
    800064a6:	20050793          	addi	a5,a0,512
    800064aa:	00479713          	slli	a4,a5,0x4
    800064ae:	00018797          	auipc	a5,0x18
    800064b2:	b5278793          	addi	a5,a5,-1198 # 8001e000 <disk>
    800064b6:	97ba                	add	a5,a5,a4
    800064b8:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800064bc:	0001a997          	auipc	s3,0x1a
    800064c0:	b4498993          	addi	s3,s3,-1212 # 80020000 <disk+0x2000>
    800064c4:	00451713          	slli	a4,a0,0x4
    800064c8:	0009b783          	ld	a5,0(s3)
    800064cc:	97ba                	add	a5,a5,a4
    800064ce:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800064d2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800064d6:	00000097          	auipc	ra,0x0
    800064da:	bb0080e7          	jalr	-1104(ra) # 80006086 <free_desc>
      i = nxt;
    800064de:	854a                	mv	a0,s2
    if(flag & VRING_DESC_F_NEXT)
    800064e0:	8885                	andi	s1,s1,1
    800064e2:	f0ed                	bnez	s1,800064c4 <virtio_disk_rw+0x25e>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064e4:	0001a517          	auipc	a0,0x1a
    800064e8:	c4450513          	addi	a0,a0,-956 # 80020128 <disk+0x2128>
    800064ec:	ffffa097          	auipc	ra,0xffffa
    800064f0:	7ec080e7          	jalr	2028(ra) # 80000cd8 <release>
}
    800064f4:	60e6                	ld	ra,88(sp)
    800064f6:	6446                	ld	s0,80(sp)
    800064f8:	64a6                	ld	s1,72(sp)
    800064fa:	6906                	ld	s2,64(sp)
    800064fc:	79e2                	ld	s3,56(sp)
    800064fe:	7a42                	ld	s4,48(sp)
    80006500:	7aa2                	ld	s5,40(sp)
    80006502:	7b02                	ld	s6,32(sp)
    80006504:	6be2                	ld	s7,24(sp)
    80006506:	6c42                	ld	s8,16(sp)
    80006508:	6125                	addi	sp,sp,96
    8000650a:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000650c:	0001a797          	auipc	a5,0x1a
    80006510:	af478793          	addi	a5,a5,-1292 # 80020000 <disk+0x2000>
    80006514:	639c                	ld	a5,0(a5)
    80006516:	97b6                	add	a5,a5,a3
    80006518:	4609                	li	a2,2
    8000651a:	00c79623          	sh	a2,12(a5)
    8000651e:	b5c1                	j	800063de <virtio_disk_rw+0x178>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006520:	fa042583          	lw	a1,-96(s0)
    80006524:	20058713          	addi	a4,a1,512
    80006528:	0712                	slli	a4,a4,0x4
    8000652a:	00018697          	auipc	a3,0x18
    8000652e:	b7e68693          	addi	a3,a3,-1154 # 8001e0a8 <disk+0xa8>
    80006532:	96ba                	add	a3,a3,a4
  if(write)
    80006534:	e00c1de3          	bnez	s8,8000634e <virtio_disk_rw+0xe8>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006538:	20058793          	addi	a5,a1,512
    8000653c:	00479613          	slli	a2,a5,0x4
    80006540:	00018797          	auipc	a5,0x18
    80006544:	ac078793          	addi	a5,a5,-1344 # 8001e000 <disk>
    80006548:	97b2                	add	a5,a5,a2
    8000654a:	0a07a423          	sw	zero,168(a5)
    8000654e:	bd21                	j	80006366 <virtio_disk_rw+0x100>
      disk.free[i] = 0;
    80006550:	00098c23          	sb	zero,24(s3)
    idx[i] = alloc_desc();
    80006554:	00072023          	sw	zero,0(a4)
    if(idx[i] < 0){
    80006558:	b3bd                	j	800062c6 <virtio_disk_rw+0x60>

000000008000655a <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000655a:	1101                	addi	sp,sp,-32
    8000655c:	ec06                	sd	ra,24(sp)
    8000655e:	e822                	sd	s0,16(sp)
    80006560:	e426                	sd	s1,8(sp)
    80006562:	e04a                	sd	s2,0(sp)
    80006564:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006566:	0001a517          	auipc	a0,0x1a
    8000656a:	bc250513          	addi	a0,a0,-1086 # 80020128 <disk+0x2128>
    8000656e:	ffffa097          	auipc	ra,0xffffa
    80006572:	6b6080e7          	jalr	1718(ra) # 80000c24 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006576:	10001737          	lui	a4,0x10001
    8000657a:	533c                	lw	a5,96(a4)
    8000657c:	8b8d                	andi	a5,a5,3
    8000657e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006580:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006584:	0001a797          	auipc	a5,0x1a
    80006588:	a7c78793          	addi	a5,a5,-1412 # 80020000 <disk+0x2000>
    8000658c:	6b94                	ld	a3,16(a5)
    8000658e:	0207d703          	lhu	a4,32(a5)
    80006592:	0026d783          	lhu	a5,2(a3)
    80006596:	06f70163          	beq	a4,a5,800065f8 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000659a:	00018917          	auipc	s2,0x18
    8000659e:	a6690913          	addi	s2,s2,-1434 # 8001e000 <disk>
    800065a2:	0001a497          	auipc	s1,0x1a
    800065a6:	a5e48493          	addi	s1,s1,-1442 # 80020000 <disk+0x2000>
    __sync_synchronize();
    800065aa:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800065ae:	6898                	ld	a4,16(s1)
    800065b0:	0204d783          	lhu	a5,32(s1)
    800065b4:	8b9d                	andi	a5,a5,7
    800065b6:	078e                	slli	a5,a5,0x3
    800065b8:	97ba                	add	a5,a5,a4
    800065ba:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800065bc:	20078713          	addi	a4,a5,512
    800065c0:	0712                	slli	a4,a4,0x4
    800065c2:	974a                	add	a4,a4,s2
    800065c4:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800065c8:	e731                	bnez	a4,80006614 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800065ca:	20078793          	addi	a5,a5,512
    800065ce:	0792                	slli	a5,a5,0x4
    800065d0:	97ca                	add	a5,a5,s2
    800065d2:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800065d4:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800065d8:	ffffc097          	auipc	ra,0xffffc
    800065dc:	e10080e7          	jalr	-496(ra) # 800023e8 <wakeup>

    disk.used_idx += 1;
    800065e0:	0204d783          	lhu	a5,32(s1)
    800065e4:	2785                	addiw	a5,a5,1
    800065e6:	17c2                	slli	a5,a5,0x30
    800065e8:	93c1                	srli	a5,a5,0x30
    800065ea:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800065ee:	6898                	ld	a4,16(s1)
    800065f0:	00275703          	lhu	a4,2(a4)
    800065f4:	faf71be3          	bne	a4,a5,800065aa <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800065f8:	0001a517          	auipc	a0,0x1a
    800065fc:	b3050513          	addi	a0,a0,-1232 # 80020128 <disk+0x2128>
    80006600:	ffffa097          	auipc	ra,0xffffa
    80006604:	6d8080e7          	jalr	1752(ra) # 80000cd8 <release>
}
    80006608:	60e2                	ld	ra,24(sp)
    8000660a:	6442                	ld	s0,16(sp)
    8000660c:	64a2                	ld	s1,8(sp)
    8000660e:	6902                	ld	s2,0(sp)
    80006610:	6105                	addi	sp,sp,32
    80006612:	8082                	ret
      panic("virtio_disk_intr status");
    80006614:	00002517          	auipc	a0,0x2
    80006618:	1c450513          	addi	a0,a0,452 # 800087d8 <syscalls+0x3e0>
    8000661c:	ffffa097          	auipc	ra,0xffffa
    80006620:	f3c080e7          	jalr	-196(ra) # 80000558 <panic>
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
