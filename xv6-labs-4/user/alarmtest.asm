
user/_alarmtest：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <periodic>:

volatile static int count;

void
periodic()
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  count = count + 1;
   8:	00001717          	auipc	a4,0x1
   c:	d5870713          	addi	a4,a4,-680 # d60 <__bss_start>
  10:	431c                	lw	a5,0(a4)
  12:	2785                	addiw	a5,a5,1
  14:	c31c                	sw	a5,0(a4)
  printf("alarm!\n");
  16:	00001517          	auipc	a0,0x1
  1a:	b9250513          	addi	a0,a0,-1134 # ba8 <malloc+0xe8>
  1e:	00001097          	auipc	ra,0x1
  22:	9e2080e7          	jalr	-1566(ra) # a00 <printf>
  sigreturn();
  26:	00000097          	auipc	ra,0x0
  2a:	6fa080e7          	jalr	1786(ra) # 720 <sigreturn>
}
  2e:	60a2                	ld	ra,8(sp)
  30:	6402                	ld	s0,0(sp)
  32:	0141                	addi	sp,sp,16
  34:	8082                	ret

0000000000000036 <slow_handler>:
  }
}

void
slow_handler()
{
  36:	1101                	addi	sp,sp,-32
  38:	ec06                	sd	ra,24(sp)
  3a:	e822                	sd	s0,16(sp)
  3c:	e426                	sd	s1,8(sp)
  3e:	1000                	addi	s0,sp,32
  count++;
  40:	00001497          	auipc	s1,0x1
  44:	d2048493          	addi	s1,s1,-736 # d60 <__bss_start>
  48:	409c                	lw	a5,0(s1)
  4a:	2785                	addiw	a5,a5,1
  4c:	c09c                	sw	a5,0(s1)
  printf("alarm!\n");
  4e:	00001517          	auipc	a0,0x1
  52:	b5a50513          	addi	a0,a0,-1190 # ba8 <malloc+0xe8>
  56:	00001097          	auipc	ra,0x1
  5a:	9aa080e7          	jalr	-1622(ra) # a00 <printf>
  if (count > 1) {
  5e:	4098                	lw	a4,0(s1)
  60:	2701                	sext.w	a4,a4
  62:	4685                	li	a3,1
  64:	1dcd67b7          	lui	a5,0x1dcd6
  68:	50078793          	addi	a5,a5,1280 # 1dcd6500 <__global_pointer$+0x1dcd4fa0>
  6c:	02e6c463          	blt	a3,a4,94 <slow_handler+0x5e>
    printf("test2 failed: alarm handler called more than once\n");
    exit(1);
  }
  for (int i = 0; i < 1000*500000; i++) {
    asm volatile("nop"); // avoid compiler optimizing away loop
  70:	0001                	nop
  for (int i = 0; i < 1000*500000; i++) {
  72:	37fd                	addiw	a5,a5,-1
  74:	fff5                	bnez	a5,70 <slow_handler+0x3a>
  }
  sigalarm(0, 0);
  76:	4581                	li	a1,0
  78:	4501                	li	a0,0
  7a:	00000097          	auipc	ra,0x0
  7e:	69e080e7          	jalr	1694(ra) # 718 <sigalarm>
  sigreturn();
  82:	00000097          	auipc	ra,0x0
  86:	69e080e7          	jalr	1694(ra) # 720 <sigreturn>
}
  8a:	60e2                	ld	ra,24(sp)
  8c:	6442                	ld	s0,16(sp)
  8e:	64a2                	ld	s1,8(sp)
  90:	6105                	addi	sp,sp,32
  92:	8082                	ret
    printf("test2 failed: alarm handler called more than once\n");
  94:	00001517          	auipc	a0,0x1
  98:	b1c50513          	addi	a0,a0,-1252 # bb0 <malloc+0xf0>
  9c:	00001097          	auipc	ra,0x1
  a0:	964080e7          	jalr	-1692(ra) # a00 <printf>
    exit(1);
  a4:	4505                	li	a0,1
  a6:	00000097          	auipc	ra,0x0
  aa:	5d2080e7          	jalr	1490(ra) # 678 <exit>

00000000000000ae <test0>:
{
  ae:	7139                	addi	sp,sp,-64
  b0:	fc06                	sd	ra,56(sp)
  b2:	f822                	sd	s0,48(sp)
  b4:	f426                	sd	s1,40(sp)
  b6:	f04a                	sd	s2,32(sp)
  b8:	ec4e                	sd	s3,24(sp)
  ba:	e852                	sd	s4,16(sp)
  bc:	e456                	sd	s5,8(sp)
  be:	0080                	addi	s0,sp,64
  printf("test0 start\n");
  c0:	00001517          	auipc	a0,0x1
  c4:	b2850513          	addi	a0,a0,-1240 # be8 <malloc+0x128>
  c8:	00001097          	auipc	ra,0x1
  cc:	938080e7          	jalr	-1736(ra) # a00 <printf>
  count = 0;
  d0:	00001797          	auipc	a5,0x1
  d4:	c807a823          	sw	zero,-880(a5) # d60 <__bss_start>
  sigalarm(2, periodic);
  d8:	00000597          	auipc	a1,0x0
  dc:	f2858593          	addi	a1,a1,-216 # 0 <periodic>
  e0:	4509                	li	a0,2
  e2:	00000097          	auipc	ra,0x0
  e6:	636080e7          	jalr	1590(ra) # 718 <sigalarm>
  for(i = 0; i < 1000*500000; i++){
  ea:	4481                	li	s1,0
    if((i % 1000000) == 0)
  ec:	000f4937          	lui	s2,0xf4
  f0:	2409091b          	addiw	s2,s2,576
      write(2, ".", 1);
  f4:	00001a97          	auipc	s5,0x1
  f8:	b04a8a93          	addi	s5,s5,-1276 # bf8 <malloc+0x138>
    if(count > 0)
  fc:	00001a17          	auipc	s4,0x1
 100:	c64a0a13          	addi	s4,s4,-924 # d60 <__bss_start>
  for(i = 0; i < 1000*500000; i++){
 104:	1dcd69b7          	lui	s3,0x1dcd6
 108:	50098993          	addi	s3,s3,1280 # 1dcd6500 <__global_pointer$+0x1dcd4fa0>
 10c:	a005                	j	12c <test0+0x7e>
      write(2, ".", 1);
 10e:	4605                	li	a2,1
 110:	85d6                	mv	a1,s5
 112:	4509                	li	a0,2
 114:	00000097          	auipc	ra,0x0
 118:	584080e7          	jalr	1412(ra) # 698 <write>
    if(count > 0)
 11c:	000a2783          	lw	a5,0(s4)
 120:	2781                	sext.w	a5,a5
 122:	00f04963          	bgtz	a5,134 <test0+0x86>
  for(i = 0; i < 1000*500000; i++){
 126:	2485                	addiw	s1,s1,1
 128:	01348663          	beq	s1,s3,134 <test0+0x86>
    if((i % 1000000) == 0)
 12c:	0324e7bb          	remw	a5,s1,s2
 130:	f7f5                	bnez	a5,11c <test0+0x6e>
 132:	bff1                	j	10e <test0+0x60>
  sigalarm(0, 0);
 134:	4581                	li	a1,0
 136:	4501                	li	a0,0
 138:	00000097          	auipc	ra,0x0
 13c:	5e0080e7          	jalr	1504(ra) # 718 <sigalarm>
  if(count > 0){
 140:	00001797          	auipc	a5,0x1
 144:	c2078793          	addi	a5,a5,-992 # d60 <__bss_start>
 148:	439c                	lw	a5,0(a5)
 14a:	2781                	sext.w	a5,a5
 14c:	02f05363          	blez	a5,172 <test0+0xc4>
    printf("test0 passed\n");
 150:	00001517          	auipc	a0,0x1
 154:	ab050513          	addi	a0,a0,-1360 # c00 <malloc+0x140>
 158:	00001097          	auipc	ra,0x1
 15c:	8a8080e7          	jalr	-1880(ra) # a00 <printf>
}
 160:	70e2                	ld	ra,56(sp)
 162:	7442                	ld	s0,48(sp)
 164:	74a2                	ld	s1,40(sp)
 166:	7902                	ld	s2,32(sp)
 168:	69e2                	ld	s3,24(sp)
 16a:	6a42                	ld	s4,16(sp)
 16c:	6aa2                	ld	s5,8(sp)
 16e:	6121                	addi	sp,sp,64
 170:	8082                	ret
    printf("\ntest0 failed: the kernel never called the alarm handler\n");
 172:	00001517          	auipc	a0,0x1
 176:	a9e50513          	addi	a0,a0,-1378 # c10 <malloc+0x150>
 17a:	00001097          	auipc	ra,0x1
 17e:	886080e7          	jalr	-1914(ra) # a00 <printf>
}
 182:	bff9                	j	160 <test0+0xb2>

0000000000000184 <foo>:
void __attribute__ ((noinline)) foo(int i, int *j) {
 184:	1101                	addi	sp,sp,-32
 186:	ec06                	sd	ra,24(sp)
 188:	e822                	sd	s0,16(sp)
 18a:	e426                	sd	s1,8(sp)
 18c:	1000                	addi	s0,sp,32
 18e:	84ae                	mv	s1,a1
  if((i % 2500000) == 0) {
 190:	002627b7          	lui	a5,0x262
 194:	5a07879b          	addiw	a5,a5,1440
 198:	02f5653b          	remw	a0,a0,a5
 19c:	c909                	beqz	a0,1ae <foo+0x2a>
  *j += 1;
 19e:	409c                	lw	a5,0(s1)
 1a0:	2785                	addiw	a5,a5,1
 1a2:	c09c                	sw	a5,0(s1)
}
 1a4:	60e2                	ld	ra,24(sp)
 1a6:	6442                	ld	s0,16(sp)
 1a8:	64a2                	ld	s1,8(sp)
 1aa:	6105                	addi	sp,sp,32
 1ac:	8082                	ret
    write(2, ".", 1);
 1ae:	4605                	li	a2,1
 1b0:	00001597          	auipc	a1,0x1
 1b4:	a4858593          	addi	a1,a1,-1464 # bf8 <malloc+0x138>
 1b8:	4509                	li	a0,2
 1ba:	00000097          	auipc	ra,0x0
 1be:	4de080e7          	jalr	1246(ra) # 698 <write>
 1c2:	bff1                	j	19e <foo+0x1a>

00000000000001c4 <test1>:
{
 1c4:	7139                	addi	sp,sp,-64
 1c6:	fc06                	sd	ra,56(sp)
 1c8:	f822                	sd	s0,48(sp)
 1ca:	f426                	sd	s1,40(sp)
 1cc:	f04a                	sd	s2,32(sp)
 1ce:	ec4e                	sd	s3,24(sp)
 1d0:	e852                	sd	s4,16(sp)
 1d2:	0080                	addi	s0,sp,64
  printf("test1 start\n");
 1d4:	00001517          	auipc	a0,0x1
 1d8:	a7c50513          	addi	a0,a0,-1412 # c50 <malloc+0x190>
 1dc:	00001097          	auipc	ra,0x1
 1e0:	824080e7          	jalr	-2012(ra) # a00 <printf>
  count = 0;
 1e4:	00001497          	auipc	s1,0x1
 1e8:	b7c48493          	addi	s1,s1,-1156 # d60 <__bss_start>
 1ec:	0004a023          	sw	zero,0(s1)
  j = 0;
 1f0:	fc042623          	sw	zero,-52(s0)
  sigalarm(2, periodic);
 1f4:	00000597          	auipc	a1,0x0
 1f8:	e0c58593          	addi	a1,a1,-500 # 0 <periodic>
 1fc:	4509                	li	a0,2
 1fe:	00000097          	auipc	ra,0x0
 202:	51a080e7          	jalr	1306(ra) # 718 <sigalarm>
    if(count >= 10)
 206:	409c                	lw	a5,0(s1)
 208:	2781                	sext.w	a5,a5
 20a:	4725                	li	a4,9
 20c:	06f74f63          	blt	a4,a5,28a <test1+0xc6>
    foo(i, &j);
 210:	fcc40593          	addi	a1,s0,-52
 214:	4501                	li	a0,0
 216:	00000097          	auipc	ra,0x0
 21a:	f6e080e7          	jalr	-146(ra) # 184 <foo>
  for(i = 0; i < 500000000; i++){
 21e:	4485                	li	s1,1
    if(count >= 10)
 220:	00001a17          	auipc	s4,0x1
 224:	b40a0a13          	addi	s4,s4,-1216 # d60 <__bss_start>
 228:	49a5                	li	s3,9
  for(i = 0; i < 500000000; i++){
 22a:	1dcd6937          	lui	s2,0x1dcd6
 22e:	50090913          	addi	s2,s2,1280 # 1dcd6500 <__global_pointer$+0x1dcd4fa0>
    if(count >= 10)
 232:	000a2783          	lw	a5,0(s4)
 236:	2781                	sext.w	a5,a5
 238:	00f9cc63          	blt	s3,a5,250 <test1+0x8c>
    foo(i, &j);
 23c:	fcc40593          	addi	a1,s0,-52
 240:	8526                	mv	a0,s1
 242:	00000097          	auipc	ra,0x0
 246:	f42080e7          	jalr	-190(ra) # 184 <foo>
  for(i = 0; i < 500000000; i++){
 24a:	2485                	addiw	s1,s1,1
 24c:	ff2493e3          	bne	s1,s2,232 <test1+0x6e>
  if(count < 10){
 250:	00001797          	auipc	a5,0x1
 254:	b1078793          	addi	a5,a5,-1264 # d60 <__bss_start>
 258:	439c                	lw	a5,0(a5)
 25a:	2781                	sext.w	a5,a5
 25c:	4725                	li	a4,9
 25e:	02f75863          	ble	a5,a4,28e <test1+0xca>
  } else if(i != j){
 262:	fcc42783          	lw	a5,-52(s0)
 266:	02978d63          	beq	a5,s1,2a0 <test1+0xdc>
    printf("\ntest1 failed: foo() executed fewer times than it was called\n");
 26a:	00001517          	auipc	a0,0x1
 26e:	a2650513          	addi	a0,a0,-1498 # c90 <malloc+0x1d0>
 272:	00000097          	auipc	ra,0x0
 276:	78e080e7          	jalr	1934(ra) # a00 <printf>
}
 27a:	70e2                	ld	ra,56(sp)
 27c:	7442                	ld	s0,48(sp)
 27e:	74a2                	ld	s1,40(sp)
 280:	7902                	ld	s2,32(sp)
 282:	69e2                	ld	s3,24(sp)
 284:	6a42                	ld	s4,16(sp)
 286:	6121                	addi	sp,sp,64
 288:	8082                	ret
  for(i = 0; i < 500000000; i++){
 28a:	4481                	li	s1,0
 28c:	b7d1                	j	250 <test1+0x8c>
    printf("\ntest1 failed: too few calls to the handler\n");
 28e:	00001517          	auipc	a0,0x1
 292:	9d250513          	addi	a0,a0,-1582 # c60 <malloc+0x1a0>
 296:	00000097          	auipc	ra,0x0
 29a:	76a080e7          	jalr	1898(ra) # a00 <printf>
 29e:	bff1                	j	27a <test1+0xb6>
    printf("test1 passed\n");
 2a0:	00001517          	auipc	a0,0x1
 2a4:	a3050513          	addi	a0,a0,-1488 # cd0 <malloc+0x210>
 2a8:	00000097          	auipc	ra,0x0
 2ac:	758080e7          	jalr	1880(ra) # a00 <printf>
}
 2b0:	b7e9                	j	27a <test1+0xb6>

00000000000002b2 <test2>:
{
 2b2:	715d                	addi	sp,sp,-80
 2b4:	e486                	sd	ra,72(sp)
 2b6:	e0a2                	sd	s0,64(sp)
 2b8:	fc26                	sd	s1,56(sp)
 2ba:	f84a                	sd	s2,48(sp)
 2bc:	f44e                	sd	s3,40(sp)
 2be:	f052                	sd	s4,32(sp)
 2c0:	ec56                	sd	s5,24(sp)
 2c2:	0880                	addi	s0,sp,80
  printf("test2 start\n");
 2c4:	00001517          	auipc	a0,0x1
 2c8:	a1c50513          	addi	a0,a0,-1508 # ce0 <malloc+0x220>
 2cc:	00000097          	auipc	ra,0x0
 2d0:	734080e7          	jalr	1844(ra) # a00 <printf>
  if ((pid = fork()) < 0) {
 2d4:	00000097          	auipc	ra,0x0
 2d8:	39c080e7          	jalr	924(ra) # 670 <fork>
 2dc:	04054263          	bltz	a0,320 <test2+0x6e>
 2e0:	84aa                	mv	s1,a0
  if (pid == 0) {
 2e2:	e539                	bnez	a0,330 <test2+0x7e>
    count = 0;
 2e4:	00001797          	auipc	a5,0x1
 2e8:	a607ae23          	sw	zero,-1412(a5) # d60 <__bss_start>
    sigalarm(2, slow_handler);
 2ec:	00000597          	auipc	a1,0x0
 2f0:	d4a58593          	addi	a1,a1,-694 # 36 <slow_handler>
 2f4:	4509                	li	a0,2
 2f6:	00000097          	auipc	ra,0x0
 2fa:	422080e7          	jalr	1058(ra) # 718 <sigalarm>
      if((i % 1000000) == 0)
 2fe:	000f4937          	lui	s2,0xf4
 302:	2409091b          	addiw	s2,s2,576
        write(2, ".", 1);
 306:	00001a97          	auipc	s5,0x1
 30a:	8f2a8a93          	addi	s5,s5,-1806 # bf8 <malloc+0x138>
      if(count > 0)
 30e:	00001a17          	auipc	s4,0x1
 312:	a52a0a13          	addi	s4,s4,-1454 # d60 <__bss_start>
    for(i = 0; i < 1000*500000; i++){
 316:	1dcd69b7          	lui	s3,0x1dcd6
 31a:	50098993          	addi	s3,s3,1280 # 1dcd6500 <__global_pointer$+0x1dcd4fa0>
 31e:	a891                	j	372 <test2+0xc0>
    printf("test2: fork failed\n");
 320:	00001517          	auipc	a0,0x1
 324:	9d050513          	addi	a0,a0,-1584 # cf0 <malloc+0x230>
 328:	00000097          	auipc	ra,0x0
 32c:	6d8080e7          	jalr	1752(ra) # a00 <printf>
  wait(&status);
 330:	fbc40513          	addi	a0,s0,-68
 334:	00000097          	auipc	ra,0x0
 338:	34c080e7          	jalr	844(ra) # 680 <wait>
  if (status == 0) {
 33c:	fbc42783          	lw	a5,-68(s0)
 340:	c7b5                	beqz	a5,3ac <test2+0xfa>
}
 342:	60a6                	ld	ra,72(sp)
 344:	6406                	ld	s0,64(sp)
 346:	74e2                	ld	s1,56(sp)
 348:	7942                	ld	s2,48(sp)
 34a:	79a2                	ld	s3,40(sp)
 34c:	7a02                	ld	s4,32(sp)
 34e:	6ae2                	ld	s5,24(sp)
 350:	6161                	addi	sp,sp,80
 352:	8082                	ret
        write(2, ".", 1);
 354:	4605                	li	a2,1
 356:	85d6                	mv	a1,s5
 358:	4509                	li	a0,2
 35a:	00000097          	auipc	ra,0x0
 35e:	33e080e7          	jalr	830(ra) # 698 <write>
      if(count > 0)
 362:	000a2783          	lw	a5,0(s4)
 366:	2781                	sext.w	a5,a5
 368:	00f04963          	bgtz	a5,37a <test2+0xc8>
    for(i = 0; i < 1000*500000; i++){
 36c:	2485                	addiw	s1,s1,1
 36e:	01348663          	beq	s1,s3,37a <test2+0xc8>
      if((i % 1000000) == 0)
 372:	0324e7bb          	remw	a5,s1,s2
 376:	f7f5                	bnez	a5,362 <test2+0xb0>
 378:	bff1                	j	354 <test2+0xa2>
    if (count == 0) {
 37a:	00001797          	auipc	a5,0x1
 37e:	9e678793          	addi	a5,a5,-1562 # d60 <__bss_start>
 382:	439c                	lw	a5,0(a5)
 384:	2781                	sext.w	a5,a5
 386:	ef91                	bnez	a5,3a2 <test2+0xf0>
      printf("\ntest2 failed: alarm not called\n");
 388:	00001517          	auipc	a0,0x1
 38c:	98050513          	addi	a0,a0,-1664 # d08 <malloc+0x248>
 390:	00000097          	auipc	ra,0x0
 394:	670080e7          	jalr	1648(ra) # a00 <printf>
      exit(1);
 398:	4505                	li	a0,1
 39a:	00000097          	auipc	ra,0x0
 39e:	2de080e7          	jalr	734(ra) # 678 <exit>
    exit(0);
 3a2:	4501                	li	a0,0
 3a4:	00000097          	auipc	ra,0x0
 3a8:	2d4080e7          	jalr	724(ra) # 678 <exit>
    printf("test2 passed\n");
 3ac:	00001517          	auipc	a0,0x1
 3b0:	98450513          	addi	a0,a0,-1660 # d30 <malloc+0x270>
 3b4:	00000097          	auipc	ra,0x0
 3b8:	64c080e7          	jalr	1612(ra) # a00 <printf>
}
 3bc:	b759                	j	342 <test2+0x90>

00000000000003be <main>:
{
 3be:	1141                	addi	sp,sp,-16
 3c0:	e406                	sd	ra,8(sp)
 3c2:	e022                	sd	s0,0(sp)
 3c4:	0800                	addi	s0,sp,16
  test0();
 3c6:	00000097          	auipc	ra,0x0
 3ca:	ce8080e7          	jalr	-792(ra) # ae <test0>
  test1();
 3ce:	00000097          	auipc	ra,0x0
 3d2:	df6080e7          	jalr	-522(ra) # 1c4 <test1>
  test2();
 3d6:	00000097          	auipc	ra,0x0
 3da:	edc080e7          	jalr	-292(ra) # 2b2 <test2>
  exit(0);
 3de:	4501                	li	a0,0
 3e0:	00000097          	auipc	ra,0x0
 3e4:	298080e7          	jalr	664(ra) # 678 <exit>

00000000000003e8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 3e8:	1141                	addi	sp,sp,-16
 3ea:	e422                	sd	s0,8(sp)
 3ec:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 3ee:	87aa                	mv	a5,a0
 3f0:	0585                	addi	a1,a1,1
 3f2:	0785                	addi	a5,a5,1
 3f4:	fff5c703          	lbu	a4,-1(a1)
 3f8:	fee78fa3          	sb	a4,-1(a5)
 3fc:	fb75                	bnez	a4,3f0 <strcpy+0x8>
    ;
  return os;
}
 3fe:	6422                	ld	s0,8(sp)
 400:	0141                	addi	sp,sp,16
 402:	8082                	ret

0000000000000404 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 404:	1141                	addi	sp,sp,-16
 406:	e422                	sd	s0,8(sp)
 408:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 40a:	00054783          	lbu	a5,0(a0)
 40e:	cf91                	beqz	a5,42a <strcmp+0x26>
 410:	0005c703          	lbu	a4,0(a1)
 414:	00f71b63          	bne	a4,a5,42a <strcmp+0x26>
    p++, q++;
 418:	0505                	addi	a0,a0,1
 41a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 41c:	00054783          	lbu	a5,0(a0)
 420:	c789                	beqz	a5,42a <strcmp+0x26>
 422:	0005c703          	lbu	a4,0(a1)
 426:	fef709e3          	beq	a4,a5,418 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 42a:	0005c503          	lbu	a0,0(a1)
}
 42e:	40a7853b          	subw	a0,a5,a0
 432:	6422                	ld	s0,8(sp)
 434:	0141                	addi	sp,sp,16
 436:	8082                	ret

0000000000000438 <strlen>:

uint
strlen(const char *s)
{
 438:	1141                	addi	sp,sp,-16
 43a:	e422                	sd	s0,8(sp)
 43c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 43e:	00054783          	lbu	a5,0(a0)
 442:	cf91                	beqz	a5,45e <strlen+0x26>
 444:	0505                	addi	a0,a0,1
 446:	87aa                	mv	a5,a0
 448:	4685                	li	a3,1
 44a:	9e89                	subw	a3,a3,a0
 44c:	00f6853b          	addw	a0,a3,a5
 450:	0785                	addi	a5,a5,1
 452:	fff7c703          	lbu	a4,-1(a5)
 456:	fb7d                	bnez	a4,44c <strlen+0x14>
    ;
  return n;
}
 458:	6422                	ld	s0,8(sp)
 45a:	0141                	addi	sp,sp,16
 45c:	8082                	ret
  for(n = 0; s[n]; n++)
 45e:	4501                	li	a0,0
 460:	bfe5                	j	458 <strlen+0x20>

0000000000000462 <memset>:

void*
memset(void *dst, int c, uint n)
{
 462:	1141                	addi	sp,sp,-16
 464:	e422                	sd	s0,8(sp)
 466:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 468:	ce09                	beqz	a2,482 <memset+0x20>
 46a:	87aa                	mv	a5,a0
 46c:	fff6071b          	addiw	a4,a2,-1
 470:	1702                	slli	a4,a4,0x20
 472:	9301                	srli	a4,a4,0x20
 474:	0705                	addi	a4,a4,1
 476:	972a                	add	a4,a4,a0
    cdst[i] = c;
 478:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 47c:	0785                	addi	a5,a5,1
 47e:	fee79de3          	bne	a5,a4,478 <memset+0x16>
  }
  return dst;
}
 482:	6422                	ld	s0,8(sp)
 484:	0141                	addi	sp,sp,16
 486:	8082                	ret

0000000000000488 <strchr>:

char*
strchr(const char *s, char c)
{
 488:	1141                	addi	sp,sp,-16
 48a:	e422                	sd	s0,8(sp)
 48c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 48e:	00054783          	lbu	a5,0(a0)
 492:	cf91                	beqz	a5,4ae <strchr+0x26>
    if(*s == c)
 494:	00f58a63          	beq	a1,a5,4a8 <strchr+0x20>
  for(; *s; s++)
 498:	0505                	addi	a0,a0,1
 49a:	00054783          	lbu	a5,0(a0)
 49e:	c781                	beqz	a5,4a6 <strchr+0x1e>
    if(*s == c)
 4a0:	feb79ce3          	bne	a5,a1,498 <strchr+0x10>
 4a4:	a011                	j	4a8 <strchr+0x20>
      return (char*)s;
  return 0;
 4a6:	4501                	li	a0,0
}
 4a8:	6422                	ld	s0,8(sp)
 4aa:	0141                	addi	sp,sp,16
 4ac:	8082                	ret
  return 0;
 4ae:	4501                	li	a0,0
 4b0:	bfe5                	j	4a8 <strchr+0x20>

00000000000004b2 <gets>:

char*
gets(char *buf, int max)
{
 4b2:	711d                	addi	sp,sp,-96
 4b4:	ec86                	sd	ra,88(sp)
 4b6:	e8a2                	sd	s0,80(sp)
 4b8:	e4a6                	sd	s1,72(sp)
 4ba:	e0ca                	sd	s2,64(sp)
 4bc:	fc4e                	sd	s3,56(sp)
 4be:	f852                	sd	s4,48(sp)
 4c0:	f456                	sd	s5,40(sp)
 4c2:	f05a                	sd	s6,32(sp)
 4c4:	ec5e                	sd	s7,24(sp)
 4c6:	1080                	addi	s0,sp,96
 4c8:	8baa                	mv	s7,a0
 4ca:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4cc:	892a                	mv	s2,a0
 4ce:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 4d0:	4aa9                	li	s5,10
 4d2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 4d4:	0019849b          	addiw	s1,s3,1
 4d8:	0344d863          	ble	s4,s1,508 <gets+0x56>
    cc = read(0, &c, 1);
 4dc:	4605                	li	a2,1
 4de:	faf40593          	addi	a1,s0,-81
 4e2:	4501                	li	a0,0
 4e4:	00000097          	auipc	ra,0x0
 4e8:	1ac080e7          	jalr	428(ra) # 690 <read>
    if(cc < 1)
 4ec:	00a05e63          	blez	a0,508 <gets+0x56>
    buf[i++] = c;
 4f0:	faf44783          	lbu	a5,-81(s0)
 4f4:	00f90023          	sb	a5,0(s2) # f4000 <__global_pointer$+0xf2aa0>
    if(c == '\n' || c == '\r')
 4f8:	01578763          	beq	a5,s5,506 <gets+0x54>
 4fc:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 4fe:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 500:	fd679ae3          	bne	a5,s6,4d4 <gets+0x22>
 504:	a011                	j	508 <gets+0x56>
  for(i=0; i+1 < max; ){
 506:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 508:	99de                	add	s3,s3,s7
 50a:	00098023          	sb	zero,0(s3)
  return buf;
}
 50e:	855e                	mv	a0,s7
 510:	60e6                	ld	ra,88(sp)
 512:	6446                	ld	s0,80(sp)
 514:	64a6                	ld	s1,72(sp)
 516:	6906                	ld	s2,64(sp)
 518:	79e2                	ld	s3,56(sp)
 51a:	7a42                	ld	s4,48(sp)
 51c:	7aa2                	ld	s5,40(sp)
 51e:	7b02                	ld	s6,32(sp)
 520:	6be2                	ld	s7,24(sp)
 522:	6125                	addi	sp,sp,96
 524:	8082                	ret

0000000000000526 <stat>:

int
stat(const char *n, struct stat *st)
{
 526:	1101                	addi	sp,sp,-32
 528:	ec06                	sd	ra,24(sp)
 52a:	e822                	sd	s0,16(sp)
 52c:	e426                	sd	s1,8(sp)
 52e:	e04a                	sd	s2,0(sp)
 530:	1000                	addi	s0,sp,32
 532:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 534:	4581                	li	a1,0
 536:	00000097          	auipc	ra,0x0
 53a:	182080e7          	jalr	386(ra) # 6b8 <open>
  if(fd < 0)
 53e:	02054563          	bltz	a0,568 <stat+0x42>
 542:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 544:	85ca                	mv	a1,s2
 546:	00000097          	auipc	ra,0x0
 54a:	18a080e7          	jalr	394(ra) # 6d0 <fstat>
 54e:	892a                	mv	s2,a0
  close(fd);
 550:	8526                	mv	a0,s1
 552:	00000097          	auipc	ra,0x0
 556:	14e080e7          	jalr	334(ra) # 6a0 <close>
  return r;
}
 55a:	854a                	mv	a0,s2
 55c:	60e2                	ld	ra,24(sp)
 55e:	6442                	ld	s0,16(sp)
 560:	64a2                	ld	s1,8(sp)
 562:	6902                	ld	s2,0(sp)
 564:	6105                	addi	sp,sp,32
 566:	8082                	ret
    return -1;
 568:	597d                	li	s2,-1
 56a:	bfc5                	j	55a <stat+0x34>

000000000000056c <atoi>:

int
atoi(const char *s)
{
 56c:	1141                	addi	sp,sp,-16
 56e:	e422                	sd	s0,8(sp)
 570:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 572:	00054683          	lbu	a3,0(a0)
 576:	fd06879b          	addiw	a5,a3,-48
 57a:	0ff7f793          	andi	a5,a5,255
 57e:	4725                	li	a4,9
 580:	02f76963          	bltu	a4,a5,5b2 <atoi+0x46>
 584:	862a                	mv	a2,a0
  n = 0;
 586:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 588:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 58a:	0605                	addi	a2,a2,1
 58c:	0025179b          	slliw	a5,a0,0x2
 590:	9fa9                	addw	a5,a5,a0
 592:	0017979b          	slliw	a5,a5,0x1
 596:	9fb5                	addw	a5,a5,a3
 598:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 59c:	00064683          	lbu	a3,0(a2)
 5a0:	fd06871b          	addiw	a4,a3,-48
 5a4:	0ff77713          	andi	a4,a4,255
 5a8:	fee5f1e3          	bleu	a4,a1,58a <atoi+0x1e>
  return n;
}
 5ac:	6422                	ld	s0,8(sp)
 5ae:	0141                	addi	sp,sp,16
 5b0:	8082                	ret
  n = 0;
 5b2:	4501                	li	a0,0
 5b4:	bfe5                	j	5ac <atoi+0x40>

00000000000005b6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 5b6:	1141                	addi	sp,sp,-16
 5b8:	e422                	sd	s0,8(sp)
 5ba:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 5bc:	02b57663          	bleu	a1,a0,5e8 <memmove+0x32>
    while(n-- > 0)
 5c0:	02c05163          	blez	a2,5e2 <memmove+0x2c>
 5c4:	fff6079b          	addiw	a5,a2,-1
 5c8:	1782                	slli	a5,a5,0x20
 5ca:	9381                	srli	a5,a5,0x20
 5cc:	0785                	addi	a5,a5,1
 5ce:	97aa                	add	a5,a5,a0
  dst = vdst;
 5d0:	872a                	mv	a4,a0
      *dst++ = *src++;
 5d2:	0585                	addi	a1,a1,1
 5d4:	0705                	addi	a4,a4,1
 5d6:	fff5c683          	lbu	a3,-1(a1)
 5da:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 5de:	fee79ae3          	bne	a5,a4,5d2 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 5e2:	6422                	ld	s0,8(sp)
 5e4:	0141                	addi	sp,sp,16
 5e6:	8082                	ret
    dst += n;
 5e8:	00c50733          	add	a4,a0,a2
    src += n;
 5ec:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 5ee:	fec05ae3          	blez	a2,5e2 <memmove+0x2c>
 5f2:	fff6079b          	addiw	a5,a2,-1
 5f6:	1782                	slli	a5,a5,0x20
 5f8:	9381                	srli	a5,a5,0x20
 5fa:	fff7c793          	not	a5,a5
 5fe:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 600:	15fd                	addi	a1,a1,-1
 602:	177d                	addi	a4,a4,-1
 604:	0005c683          	lbu	a3,0(a1)
 608:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 60c:	fef71ae3          	bne	a4,a5,600 <memmove+0x4a>
 610:	bfc9                	j	5e2 <memmove+0x2c>

0000000000000612 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 612:	1141                	addi	sp,sp,-16
 614:	e422                	sd	s0,8(sp)
 616:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 618:	ce15                	beqz	a2,654 <memcmp+0x42>
 61a:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 61e:	00054783          	lbu	a5,0(a0)
 622:	0005c703          	lbu	a4,0(a1)
 626:	02e79063          	bne	a5,a4,646 <memcmp+0x34>
 62a:	1682                	slli	a3,a3,0x20
 62c:	9281                	srli	a3,a3,0x20
 62e:	0685                	addi	a3,a3,1
 630:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 632:	0505                	addi	a0,a0,1
    p2++;
 634:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 636:	00d50d63          	beq	a0,a3,650 <memcmp+0x3e>
    if (*p1 != *p2) {
 63a:	00054783          	lbu	a5,0(a0)
 63e:	0005c703          	lbu	a4,0(a1)
 642:	fee788e3          	beq	a5,a4,632 <memcmp+0x20>
      return *p1 - *p2;
 646:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 64a:	6422                	ld	s0,8(sp)
 64c:	0141                	addi	sp,sp,16
 64e:	8082                	ret
  return 0;
 650:	4501                	li	a0,0
 652:	bfe5                	j	64a <memcmp+0x38>
 654:	4501                	li	a0,0
 656:	bfd5                	j	64a <memcmp+0x38>

0000000000000658 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 658:	1141                	addi	sp,sp,-16
 65a:	e406                	sd	ra,8(sp)
 65c:	e022                	sd	s0,0(sp)
 65e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 660:	00000097          	auipc	ra,0x0
 664:	f56080e7          	jalr	-170(ra) # 5b6 <memmove>
}
 668:	60a2                	ld	ra,8(sp)
 66a:	6402                	ld	s0,0(sp)
 66c:	0141                	addi	sp,sp,16
 66e:	8082                	ret

0000000000000670 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 670:	4885                	li	a7,1
 ecall
 672:	00000073          	ecall
 ret
 676:	8082                	ret

0000000000000678 <exit>:
.global exit
exit:
 li a7, SYS_exit
 678:	4889                	li	a7,2
 ecall
 67a:	00000073          	ecall
 ret
 67e:	8082                	ret

0000000000000680 <wait>:
.global wait
wait:
 li a7, SYS_wait
 680:	488d                	li	a7,3
 ecall
 682:	00000073          	ecall
 ret
 686:	8082                	ret

0000000000000688 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 688:	4891                	li	a7,4
 ecall
 68a:	00000073          	ecall
 ret
 68e:	8082                	ret

0000000000000690 <read>:
.global read
read:
 li a7, SYS_read
 690:	4895                	li	a7,5
 ecall
 692:	00000073          	ecall
 ret
 696:	8082                	ret

0000000000000698 <write>:
.global write
write:
 li a7, SYS_write
 698:	48c1                	li	a7,16
 ecall
 69a:	00000073          	ecall
 ret
 69e:	8082                	ret

00000000000006a0 <close>:
.global close
close:
 li a7, SYS_close
 6a0:	48d5                	li	a7,21
 ecall
 6a2:	00000073          	ecall
 ret
 6a6:	8082                	ret

00000000000006a8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 6a8:	4899                	li	a7,6
 ecall
 6aa:	00000073          	ecall
 ret
 6ae:	8082                	ret

00000000000006b0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 6b0:	489d                	li	a7,7
 ecall
 6b2:	00000073          	ecall
 ret
 6b6:	8082                	ret

00000000000006b8 <open>:
.global open
open:
 li a7, SYS_open
 6b8:	48bd                	li	a7,15
 ecall
 6ba:	00000073          	ecall
 ret
 6be:	8082                	ret

00000000000006c0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 6c0:	48c5                	li	a7,17
 ecall
 6c2:	00000073          	ecall
 ret
 6c6:	8082                	ret

00000000000006c8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 6c8:	48c9                	li	a7,18
 ecall
 6ca:	00000073          	ecall
 ret
 6ce:	8082                	ret

00000000000006d0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 6d0:	48a1                	li	a7,8
 ecall
 6d2:	00000073          	ecall
 ret
 6d6:	8082                	ret

00000000000006d8 <link>:
.global link
link:
 li a7, SYS_link
 6d8:	48cd                	li	a7,19
 ecall
 6da:	00000073          	ecall
 ret
 6de:	8082                	ret

00000000000006e0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 6e0:	48d1                	li	a7,20
 ecall
 6e2:	00000073          	ecall
 ret
 6e6:	8082                	ret

00000000000006e8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 6e8:	48a5                	li	a7,9
 ecall
 6ea:	00000073          	ecall
 ret
 6ee:	8082                	ret

00000000000006f0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 6f0:	48a9                	li	a7,10
 ecall
 6f2:	00000073          	ecall
 ret
 6f6:	8082                	ret

00000000000006f8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 6f8:	48ad                	li	a7,11
 ecall
 6fa:	00000073          	ecall
 ret
 6fe:	8082                	ret

0000000000000700 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 700:	48b1                	li	a7,12
 ecall
 702:	00000073          	ecall
 ret
 706:	8082                	ret

0000000000000708 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 708:	48b5                	li	a7,13
 ecall
 70a:	00000073          	ecall
 ret
 70e:	8082                	ret

0000000000000710 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 710:	48b9                	li	a7,14
 ecall
 712:	00000073          	ecall
 ret
 716:	8082                	ret

0000000000000718 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 718:	48d9                	li	a7,22
 ecall
 71a:	00000073          	ecall
 ret
 71e:	8082                	ret

0000000000000720 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 720:	48dd                	li	a7,23
 ecall
 722:	00000073          	ecall
 ret
 726:	8082                	ret

0000000000000728 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 728:	1101                	addi	sp,sp,-32
 72a:	ec06                	sd	ra,24(sp)
 72c:	e822                	sd	s0,16(sp)
 72e:	1000                	addi	s0,sp,32
 730:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 734:	4605                	li	a2,1
 736:	fef40593          	addi	a1,s0,-17
 73a:	00000097          	auipc	ra,0x0
 73e:	f5e080e7          	jalr	-162(ra) # 698 <write>
}
 742:	60e2                	ld	ra,24(sp)
 744:	6442                	ld	s0,16(sp)
 746:	6105                	addi	sp,sp,32
 748:	8082                	ret

000000000000074a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 74a:	7139                	addi	sp,sp,-64
 74c:	fc06                	sd	ra,56(sp)
 74e:	f822                	sd	s0,48(sp)
 750:	f426                	sd	s1,40(sp)
 752:	f04a                	sd	s2,32(sp)
 754:	ec4e                	sd	s3,24(sp)
 756:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 758:	c299                	beqz	a3,75e <printint+0x14>
 75a:	0005cd63          	bltz	a1,774 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 75e:	2581                	sext.w	a1,a1
  neg = 0;
 760:	4301                	li	t1,0
 762:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 766:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 768:	2601                	sext.w	a2,a2
 76a:	00000897          	auipc	a7,0x0
 76e:	5d688893          	addi	a7,a7,1494 # d40 <digits>
 772:	a801                	j	782 <printint+0x38>
    x = -xx;
 774:	40b005bb          	negw	a1,a1
 778:	2581                	sext.w	a1,a1
    neg = 1;
 77a:	4305                	li	t1,1
    x = -xx;
 77c:	b7dd                	j	762 <printint+0x18>
  }while((x /= base) != 0);
 77e:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 780:	8836                	mv	a6,a3
 782:	0018069b          	addiw	a3,a6,1
 786:	02c5f7bb          	remuw	a5,a1,a2
 78a:	1782                	slli	a5,a5,0x20
 78c:	9381                	srli	a5,a5,0x20
 78e:	97c6                	add	a5,a5,a7
 790:	0007c783          	lbu	a5,0(a5)
 794:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 798:	0705                	addi	a4,a4,1
 79a:	02c5d7bb          	divuw	a5,a1,a2
 79e:	fec5f0e3          	bleu	a2,a1,77e <printint+0x34>
  if(neg)
 7a2:	00030b63          	beqz	t1,7b8 <printint+0x6e>
    buf[i++] = '-';
 7a6:	fd040793          	addi	a5,s0,-48
 7aa:	96be                	add	a3,a3,a5
 7ac:	02d00793          	li	a5,45
 7b0:	fef68823          	sb	a5,-16(a3)
 7b4:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 7b8:	02d05963          	blez	a3,7ea <printint+0xa0>
 7bc:	89aa                	mv	s3,a0
 7be:	fc040793          	addi	a5,s0,-64
 7c2:	00d784b3          	add	s1,a5,a3
 7c6:	fff78913          	addi	s2,a5,-1
 7ca:	9936                	add	s2,s2,a3
 7cc:	36fd                	addiw	a3,a3,-1
 7ce:	1682                	slli	a3,a3,0x20
 7d0:	9281                	srli	a3,a3,0x20
 7d2:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 7d6:	fff4c583          	lbu	a1,-1(s1)
 7da:	854e                	mv	a0,s3
 7dc:	00000097          	auipc	ra,0x0
 7e0:	f4c080e7          	jalr	-180(ra) # 728 <putc>
  while(--i >= 0)
 7e4:	14fd                	addi	s1,s1,-1
 7e6:	ff2498e3          	bne	s1,s2,7d6 <printint+0x8c>
}
 7ea:	70e2                	ld	ra,56(sp)
 7ec:	7442                	ld	s0,48(sp)
 7ee:	74a2                	ld	s1,40(sp)
 7f0:	7902                	ld	s2,32(sp)
 7f2:	69e2                	ld	s3,24(sp)
 7f4:	6121                	addi	sp,sp,64
 7f6:	8082                	ret

00000000000007f8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 7f8:	7119                	addi	sp,sp,-128
 7fa:	fc86                	sd	ra,120(sp)
 7fc:	f8a2                	sd	s0,112(sp)
 7fe:	f4a6                	sd	s1,104(sp)
 800:	f0ca                	sd	s2,96(sp)
 802:	ecce                	sd	s3,88(sp)
 804:	e8d2                	sd	s4,80(sp)
 806:	e4d6                	sd	s5,72(sp)
 808:	e0da                	sd	s6,64(sp)
 80a:	fc5e                	sd	s7,56(sp)
 80c:	f862                	sd	s8,48(sp)
 80e:	f466                	sd	s9,40(sp)
 810:	f06a                	sd	s10,32(sp)
 812:	ec6e                	sd	s11,24(sp)
 814:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 816:	0005c483          	lbu	s1,0(a1)
 81a:	18048d63          	beqz	s1,9b4 <vprintf+0x1bc>
 81e:	8aaa                	mv	s5,a0
 820:	8b32                	mv	s6,a2
 822:	00158913          	addi	s2,a1,1
  state = 0;
 826:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 828:	02500a13          	li	s4,37
      if(c == 'd'){
 82c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 830:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 834:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 838:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 83c:	00000b97          	auipc	s7,0x0
 840:	504b8b93          	addi	s7,s7,1284 # d40 <digits>
 844:	a839                	j	862 <vprintf+0x6a>
        putc(fd, c);
 846:	85a6                	mv	a1,s1
 848:	8556                	mv	a0,s5
 84a:	00000097          	auipc	ra,0x0
 84e:	ede080e7          	jalr	-290(ra) # 728 <putc>
 852:	a019                	j	858 <vprintf+0x60>
    } else if(state == '%'){
 854:	01498f63          	beq	s3,s4,872 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 858:	0905                	addi	s2,s2,1
 85a:	fff94483          	lbu	s1,-1(s2)
 85e:	14048b63          	beqz	s1,9b4 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 862:	0004879b          	sext.w	a5,s1
    if(state == 0){
 866:	fe0997e3          	bnez	s3,854 <vprintf+0x5c>
      if(c == '%'){
 86a:	fd479ee3          	bne	a5,s4,846 <vprintf+0x4e>
        state = '%';
 86e:	89be                	mv	s3,a5
 870:	b7e5                	j	858 <vprintf+0x60>
      if(c == 'd'){
 872:	05878063          	beq	a5,s8,8b2 <vprintf+0xba>
      } else if(c == 'l') {
 876:	05978c63          	beq	a5,s9,8ce <vprintf+0xd6>
      } else if(c == 'x') {
 87a:	07a78863          	beq	a5,s10,8ea <vprintf+0xf2>
      } else if(c == 'p') {
 87e:	09b78463          	beq	a5,s11,906 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 882:	07300713          	li	a4,115
 886:	0ce78563          	beq	a5,a4,950 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 88a:	06300713          	li	a4,99
 88e:	0ee78c63          	beq	a5,a4,986 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 892:	11478663          	beq	a5,s4,99e <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 896:	85d2                	mv	a1,s4
 898:	8556                	mv	a0,s5
 89a:	00000097          	auipc	ra,0x0
 89e:	e8e080e7          	jalr	-370(ra) # 728 <putc>
        putc(fd, c);
 8a2:	85a6                	mv	a1,s1
 8a4:	8556                	mv	a0,s5
 8a6:	00000097          	auipc	ra,0x0
 8aa:	e82080e7          	jalr	-382(ra) # 728 <putc>
      }
      state = 0;
 8ae:	4981                	li	s3,0
 8b0:	b765                	j	858 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 8b2:	008b0493          	addi	s1,s6,8
 8b6:	4685                	li	a3,1
 8b8:	4629                	li	a2,10
 8ba:	000b2583          	lw	a1,0(s6)
 8be:	8556                	mv	a0,s5
 8c0:	00000097          	auipc	ra,0x0
 8c4:	e8a080e7          	jalr	-374(ra) # 74a <printint>
 8c8:	8b26                	mv	s6,s1
      state = 0;
 8ca:	4981                	li	s3,0
 8cc:	b771                	j	858 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8ce:	008b0493          	addi	s1,s6,8
 8d2:	4681                	li	a3,0
 8d4:	4629                	li	a2,10
 8d6:	000b2583          	lw	a1,0(s6)
 8da:	8556                	mv	a0,s5
 8dc:	00000097          	auipc	ra,0x0
 8e0:	e6e080e7          	jalr	-402(ra) # 74a <printint>
 8e4:	8b26                	mv	s6,s1
      state = 0;
 8e6:	4981                	li	s3,0
 8e8:	bf85                	j	858 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 8ea:	008b0493          	addi	s1,s6,8
 8ee:	4681                	li	a3,0
 8f0:	4641                	li	a2,16
 8f2:	000b2583          	lw	a1,0(s6)
 8f6:	8556                	mv	a0,s5
 8f8:	00000097          	auipc	ra,0x0
 8fc:	e52080e7          	jalr	-430(ra) # 74a <printint>
 900:	8b26                	mv	s6,s1
      state = 0;
 902:	4981                	li	s3,0
 904:	bf91                	j	858 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 906:	008b0793          	addi	a5,s6,8
 90a:	f8f43423          	sd	a5,-120(s0)
 90e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 912:	03000593          	li	a1,48
 916:	8556                	mv	a0,s5
 918:	00000097          	auipc	ra,0x0
 91c:	e10080e7          	jalr	-496(ra) # 728 <putc>
  putc(fd, 'x');
 920:	85ea                	mv	a1,s10
 922:	8556                	mv	a0,s5
 924:	00000097          	auipc	ra,0x0
 928:	e04080e7          	jalr	-508(ra) # 728 <putc>
 92c:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 92e:	03c9d793          	srli	a5,s3,0x3c
 932:	97de                	add	a5,a5,s7
 934:	0007c583          	lbu	a1,0(a5)
 938:	8556                	mv	a0,s5
 93a:	00000097          	auipc	ra,0x0
 93e:	dee080e7          	jalr	-530(ra) # 728 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 942:	0992                	slli	s3,s3,0x4
 944:	34fd                	addiw	s1,s1,-1
 946:	f4e5                	bnez	s1,92e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 948:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 94c:	4981                	li	s3,0
 94e:	b729                	j	858 <vprintf+0x60>
        s = va_arg(ap, char*);
 950:	008b0993          	addi	s3,s6,8
 954:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 958:	c085                	beqz	s1,978 <vprintf+0x180>
        while(*s != 0){
 95a:	0004c583          	lbu	a1,0(s1)
 95e:	c9a1                	beqz	a1,9ae <vprintf+0x1b6>
          putc(fd, *s);
 960:	8556                	mv	a0,s5
 962:	00000097          	auipc	ra,0x0
 966:	dc6080e7          	jalr	-570(ra) # 728 <putc>
          s++;
 96a:	0485                	addi	s1,s1,1
        while(*s != 0){
 96c:	0004c583          	lbu	a1,0(s1)
 970:	f9e5                	bnez	a1,960 <vprintf+0x168>
        s = va_arg(ap, char*);
 972:	8b4e                	mv	s6,s3
      state = 0;
 974:	4981                	li	s3,0
 976:	b5cd                	j	858 <vprintf+0x60>
          s = "(null)";
 978:	00000497          	auipc	s1,0x0
 97c:	3e048493          	addi	s1,s1,992 # d58 <digits+0x18>
        while(*s != 0){
 980:	02800593          	li	a1,40
 984:	bff1                	j	960 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 986:	008b0493          	addi	s1,s6,8
 98a:	000b4583          	lbu	a1,0(s6)
 98e:	8556                	mv	a0,s5
 990:	00000097          	auipc	ra,0x0
 994:	d98080e7          	jalr	-616(ra) # 728 <putc>
 998:	8b26                	mv	s6,s1
      state = 0;
 99a:	4981                	li	s3,0
 99c:	bd75                	j	858 <vprintf+0x60>
        putc(fd, c);
 99e:	85d2                	mv	a1,s4
 9a0:	8556                	mv	a0,s5
 9a2:	00000097          	auipc	ra,0x0
 9a6:	d86080e7          	jalr	-634(ra) # 728 <putc>
      state = 0;
 9aa:	4981                	li	s3,0
 9ac:	b575                	j	858 <vprintf+0x60>
        s = va_arg(ap, char*);
 9ae:	8b4e                	mv	s6,s3
      state = 0;
 9b0:	4981                	li	s3,0
 9b2:	b55d                	j	858 <vprintf+0x60>
    }
  }
}
 9b4:	70e6                	ld	ra,120(sp)
 9b6:	7446                	ld	s0,112(sp)
 9b8:	74a6                	ld	s1,104(sp)
 9ba:	7906                	ld	s2,96(sp)
 9bc:	69e6                	ld	s3,88(sp)
 9be:	6a46                	ld	s4,80(sp)
 9c0:	6aa6                	ld	s5,72(sp)
 9c2:	6b06                	ld	s6,64(sp)
 9c4:	7be2                	ld	s7,56(sp)
 9c6:	7c42                	ld	s8,48(sp)
 9c8:	7ca2                	ld	s9,40(sp)
 9ca:	7d02                	ld	s10,32(sp)
 9cc:	6de2                	ld	s11,24(sp)
 9ce:	6109                	addi	sp,sp,128
 9d0:	8082                	ret

00000000000009d2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9d2:	715d                	addi	sp,sp,-80
 9d4:	ec06                	sd	ra,24(sp)
 9d6:	e822                	sd	s0,16(sp)
 9d8:	1000                	addi	s0,sp,32
 9da:	e010                	sd	a2,0(s0)
 9dc:	e414                	sd	a3,8(s0)
 9de:	e818                	sd	a4,16(s0)
 9e0:	ec1c                	sd	a5,24(s0)
 9e2:	03043023          	sd	a6,32(s0)
 9e6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9ea:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9ee:	8622                	mv	a2,s0
 9f0:	00000097          	auipc	ra,0x0
 9f4:	e08080e7          	jalr	-504(ra) # 7f8 <vprintf>
}
 9f8:	60e2                	ld	ra,24(sp)
 9fa:	6442                	ld	s0,16(sp)
 9fc:	6161                	addi	sp,sp,80
 9fe:	8082                	ret

0000000000000a00 <printf>:

void
printf(const char *fmt, ...)
{
 a00:	711d                	addi	sp,sp,-96
 a02:	ec06                	sd	ra,24(sp)
 a04:	e822                	sd	s0,16(sp)
 a06:	1000                	addi	s0,sp,32
 a08:	e40c                	sd	a1,8(s0)
 a0a:	e810                	sd	a2,16(s0)
 a0c:	ec14                	sd	a3,24(s0)
 a0e:	f018                	sd	a4,32(s0)
 a10:	f41c                	sd	a5,40(s0)
 a12:	03043823          	sd	a6,48(s0)
 a16:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a1a:	00840613          	addi	a2,s0,8
 a1e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a22:	85aa                	mv	a1,a0
 a24:	4505                	li	a0,1
 a26:	00000097          	auipc	ra,0x0
 a2a:	dd2080e7          	jalr	-558(ra) # 7f8 <vprintf>
}
 a2e:	60e2                	ld	ra,24(sp)
 a30:	6442                	ld	s0,16(sp)
 a32:	6125                	addi	sp,sp,96
 a34:	8082                	ret

0000000000000a36 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a36:	1141                	addi	sp,sp,-16
 a38:	e422                	sd	s0,8(sp)
 a3a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a3c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a40:	00000797          	auipc	a5,0x0
 a44:	32878793          	addi	a5,a5,808 # d68 <freep>
 a48:	639c                	ld	a5,0(a5)
 a4a:	a805                	j	a7a <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a4c:	4618                	lw	a4,8(a2)
 a4e:	9db9                	addw	a1,a1,a4
 a50:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a54:	6398                	ld	a4,0(a5)
 a56:	6318                	ld	a4,0(a4)
 a58:	fee53823          	sd	a4,-16(a0)
 a5c:	a091                	j	aa0 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a5e:	ff852703          	lw	a4,-8(a0)
 a62:	9e39                	addw	a2,a2,a4
 a64:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 a66:	ff053703          	ld	a4,-16(a0)
 a6a:	e398                	sd	a4,0(a5)
 a6c:	a099                	j	ab2 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a6e:	6398                	ld	a4,0(a5)
 a70:	00e7e463          	bltu	a5,a4,a78 <free+0x42>
 a74:	00e6ea63          	bltu	a3,a4,a88 <free+0x52>
{
 a78:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a7a:	fed7fae3          	bleu	a3,a5,a6e <free+0x38>
 a7e:	6398                	ld	a4,0(a5)
 a80:	00e6e463          	bltu	a3,a4,a88 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a84:	fee7eae3          	bltu	a5,a4,a78 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 a88:	ff852583          	lw	a1,-8(a0)
 a8c:	6390                	ld	a2,0(a5)
 a8e:	02059713          	slli	a4,a1,0x20
 a92:	9301                	srli	a4,a4,0x20
 a94:	0712                	slli	a4,a4,0x4
 a96:	9736                	add	a4,a4,a3
 a98:	fae60ae3          	beq	a2,a4,a4c <free+0x16>
    bp->s.ptr = p->s.ptr;
 a9c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 aa0:	4790                	lw	a2,8(a5)
 aa2:	02061713          	slli	a4,a2,0x20
 aa6:	9301                	srli	a4,a4,0x20
 aa8:	0712                	slli	a4,a4,0x4
 aaa:	973e                	add	a4,a4,a5
 aac:	fae689e3          	beq	a3,a4,a5e <free+0x28>
  } else
    p->s.ptr = bp;
 ab0:	e394                	sd	a3,0(a5)
  freep = p;
 ab2:	00000717          	auipc	a4,0x0
 ab6:	2af73b23          	sd	a5,694(a4) # d68 <freep>
}
 aba:	6422                	ld	s0,8(sp)
 abc:	0141                	addi	sp,sp,16
 abe:	8082                	ret

0000000000000ac0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ac0:	7139                	addi	sp,sp,-64
 ac2:	fc06                	sd	ra,56(sp)
 ac4:	f822                	sd	s0,48(sp)
 ac6:	f426                	sd	s1,40(sp)
 ac8:	f04a                	sd	s2,32(sp)
 aca:	ec4e                	sd	s3,24(sp)
 acc:	e852                	sd	s4,16(sp)
 ace:	e456                	sd	s5,8(sp)
 ad0:	e05a                	sd	s6,0(sp)
 ad2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ad4:	02051993          	slli	s3,a0,0x20
 ad8:	0209d993          	srli	s3,s3,0x20
 adc:	09bd                	addi	s3,s3,15
 ade:	0049d993          	srli	s3,s3,0x4
 ae2:	2985                	addiw	s3,s3,1
 ae4:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 ae8:	00000797          	auipc	a5,0x0
 aec:	28078793          	addi	a5,a5,640 # d68 <freep>
 af0:	6388                	ld	a0,0(a5)
 af2:	c515                	beqz	a0,b1e <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 af4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 af6:	4798                	lw	a4,8(a5)
 af8:	03277f63          	bleu	s2,a4,b36 <malloc+0x76>
 afc:	8a4e                	mv	s4,s3
 afe:	0009871b          	sext.w	a4,s3
 b02:	6685                	lui	a3,0x1
 b04:	00d77363          	bleu	a3,a4,b0a <malloc+0x4a>
 b08:	6a05                	lui	s4,0x1
 b0a:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 b0e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b12:	00000497          	auipc	s1,0x0
 b16:	25648493          	addi	s1,s1,598 # d68 <freep>
  if(p == (char*)-1)
 b1a:	5b7d                	li	s6,-1
 b1c:	a885                	j	b8c <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 b1e:	00000797          	auipc	a5,0x0
 b22:	25278793          	addi	a5,a5,594 # d70 <base>
 b26:	00000717          	auipc	a4,0x0
 b2a:	24f73123          	sd	a5,578(a4) # d68 <freep>
 b2e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b30:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b34:	b7e1                	j	afc <malloc+0x3c>
      if(p->s.size == nunits)
 b36:	02e90b63          	beq	s2,a4,b6c <malloc+0xac>
        p->s.size -= nunits;
 b3a:	4137073b          	subw	a4,a4,s3
 b3e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b40:	1702                	slli	a4,a4,0x20
 b42:	9301                	srli	a4,a4,0x20
 b44:	0712                	slli	a4,a4,0x4
 b46:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b48:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b4c:	00000717          	auipc	a4,0x0
 b50:	20a73e23          	sd	a0,540(a4) # d68 <freep>
      return (void*)(p + 1);
 b54:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 b58:	70e2                	ld	ra,56(sp)
 b5a:	7442                	ld	s0,48(sp)
 b5c:	74a2                	ld	s1,40(sp)
 b5e:	7902                	ld	s2,32(sp)
 b60:	69e2                	ld	s3,24(sp)
 b62:	6a42                	ld	s4,16(sp)
 b64:	6aa2                	ld	s5,8(sp)
 b66:	6b02                	ld	s6,0(sp)
 b68:	6121                	addi	sp,sp,64
 b6a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b6c:	6398                	ld	a4,0(a5)
 b6e:	e118                	sd	a4,0(a0)
 b70:	bff1                	j	b4c <malloc+0x8c>
  hp->s.size = nu;
 b72:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 b76:	0541                	addi	a0,a0,16
 b78:	00000097          	auipc	ra,0x0
 b7c:	ebe080e7          	jalr	-322(ra) # a36 <free>
  return freep;
 b80:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 b82:	d979                	beqz	a0,b58 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b84:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b86:	4798                	lw	a4,8(a5)
 b88:	fb2777e3          	bleu	s2,a4,b36 <malloc+0x76>
    if(p == freep)
 b8c:	6098                	ld	a4,0(s1)
 b8e:	853e                	mv	a0,a5
 b90:	fef71ae3          	bne	a4,a5,b84 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 b94:	8552                	mv	a0,s4
 b96:	00000097          	auipc	ra,0x0
 b9a:	b6a080e7          	jalr	-1174(ra) # 700 <sbrk>
  if(p == (char*)-1)
 b9e:	fd651ae3          	bne	a0,s6,b72 <malloc+0xb2>
        return 0;
 ba2:	4501                	li	a0,0
 ba4:	bf55                	j	b58 <malloc+0x98>
