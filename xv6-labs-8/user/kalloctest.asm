
user/_kalloctest：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <ntas>:
  test2();
  exit(0);
}

int ntas(int print)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
   c:	892a                	mv	s2,a0
  int n;
  char *c;

  if (statistics(buf, SZ) <= 0) {
   e:	6585                	lui	a1,0x1
  10:	00001517          	auipc	a0,0x1
  14:	cb850513          	addi	a0,a0,-840 # cc8 <buf>
  18:	00001097          	auipc	ra,0x1
  1c:	ab4080e7          	jalr	-1356(ra) # acc <statistics>
  20:	02a05b63          	blez	a0,56 <ntas+0x56>
    fprintf(2, "ntas: no stats\n");
  }
  c = strchr(buf, '=');
  24:	03d00593          	li	a1,61
  28:	00001517          	auipc	a0,0x1
  2c:	ca050513          	addi	a0,a0,-864 # cc8 <buf>
  30:	00000097          	auipc	ra,0x0
  34:	38e080e7          	jalr	910(ra) # 3be <strchr>
  n = atoi(c+2);
  38:	0509                	addi	a0,a0,2
  3a:	00000097          	auipc	ra,0x0
  3e:	468080e7          	jalr	1128(ra) # 4a2 <atoi>
  42:	84aa                	mv	s1,a0
  if(print)
  44:	02091363          	bnez	s2,6a <ntas+0x6a>
    printf("%s", buf);
  return n;
}
  48:	8526                	mv	a0,s1
  4a:	60e2                	ld	ra,24(sp)
  4c:	6442                	ld	s0,16(sp)
  4e:	64a2                	ld	s1,8(sp)
  50:	6902                	ld	s2,0(sp)
  52:	6105                	addi	sp,sp,32
  54:	8082                	ret
    fprintf(2, "ntas: no stats\n");
  56:	00001597          	auipc	a1,0x1
  5a:	b0258593          	addi	a1,a1,-1278 # b58 <statistics+0x8c>
  5e:	4509                	li	a0,2
  60:	00001097          	auipc	ra,0x1
  64:	898080e7          	jalr	-1896(ra) # 8f8 <fprintf>
  68:	bf75                	j	24 <ntas+0x24>
    printf("%s", buf);
  6a:	00001597          	auipc	a1,0x1
  6e:	c5e58593          	addi	a1,a1,-930 # cc8 <buf>
  72:	00001517          	auipc	a0,0x1
  76:	af650513          	addi	a0,a0,-1290 # b68 <statistics+0x9c>
  7a:	00001097          	auipc	ra,0x1
  7e:	8ac080e7          	jalr	-1876(ra) # 926 <printf>
  82:	b7d9                	j	48 <ntas+0x48>

0000000000000084 <test1>:

void test1(void)
{
  84:	7179                	addi	sp,sp,-48
  86:	f406                	sd	ra,40(sp)
  88:	f022                	sd	s0,32(sp)
  8a:	ec26                	sd	s1,24(sp)
  8c:	e84a                	sd	s2,16(sp)
  8e:	e44e                	sd	s3,8(sp)
  90:	1800                	addi	s0,sp,48
  void *a, *a1;
  int n, m;
  printf("start test1\n");  
  92:	00001517          	auipc	a0,0x1
  96:	ade50513          	addi	a0,a0,-1314 # b70 <statistics+0xa4>
  9a:	00001097          	auipc	ra,0x1
  9e:	88c080e7          	jalr	-1908(ra) # 926 <printf>
  m = ntas(0);
  a2:	4501                	li	a0,0
  a4:	00000097          	auipc	ra,0x0
  a8:	f5c080e7          	jalr	-164(ra) # 0 <ntas>
  ac:	84aa                	mv	s1,a0
  for(int i = 0; i < NCHILD; i++){
    int pid = fork();
  ae:	00000097          	auipc	ra,0x0
  b2:	4f8080e7          	jalr	1272(ra) # 5a6 <fork>
    if(pid < 0){
  b6:	06054463          	bltz	a0,11e <test1+0x9a>
      printf("fork failed");
      exit(-1);
    }
    if(pid == 0){
  ba:	cd3d                	beqz	a0,138 <test1+0xb4>
    int pid = fork();
  bc:	00000097          	auipc	ra,0x0
  c0:	4ea080e7          	jalr	1258(ra) # 5a6 <fork>
    if(pid < 0){
  c4:	04054d63          	bltz	a0,11e <test1+0x9a>
    if(pid == 0){
  c8:	c925                	beqz	a0,138 <test1+0xb4>
      exit(-1);
    }
  }

  for(int i = 0; i < NCHILD; i++){
    wait(0);
  ca:	4501                	li	a0,0
  cc:	00000097          	auipc	ra,0x0
  d0:	4ea080e7          	jalr	1258(ra) # 5b6 <wait>
  d4:	4501                	li	a0,0
  d6:	00000097          	auipc	ra,0x0
  da:	4e0080e7          	jalr	1248(ra) # 5b6 <wait>
  }
  printf("test1 results:\n");
  de:	00001517          	auipc	a0,0x1
  e2:	ac250513          	addi	a0,a0,-1342 # ba0 <statistics+0xd4>
  e6:	00001097          	auipc	ra,0x1
  ea:	840080e7          	jalr	-1984(ra) # 926 <printf>
  n = ntas(1);
  ee:	4505                	li	a0,1
  f0:	00000097          	auipc	ra,0x0
  f4:	f10080e7          	jalr	-240(ra) # 0 <ntas>
  if(n-m < 10) 
  f8:	9d05                	subw	a0,a0,s1
  fa:	47a5                	li	a5,9
  fc:	08a7c863          	blt	a5,a0,18c <test1+0x108>
    printf("test1 OK\n");
 100:	00001517          	auipc	a0,0x1
 104:	ab050513          	addi	a0,a0,-1360 # bb0 <statistics+0xe4>
 108:	00001097          	auipc	ra,0x1
 10c:	81e080e7          	jalr	-2018(ra) # 926 <printf>
  else
    printf("test1 FAIL\n");
}
 110:	70a2                	ld	ra,40(sp)
 112:	7402                	ld	s0,32(sp)
 114:	64e2                	ld	s1,24(sp)
 116:	6942                	ld	s2,16(sp)
 118:	69a2                	ld	s3,8(sp)
 11a:	6145                	addi	sp,sp,48
 11c:	8082                	ret
      printf("fork failed");
 11e:	00001517          	auipc	a0,0x1
 122:	a6250513          	addi	a0,a0,-1438 # b80 <statistics+0xb4>
 126:	00001097          	auipc	ra,0x1
 12a:	800080e7          	jalr	-2048(ra) # 926 <printf>
      exit(-1);
 12e:	557d                	li	a0,-1
 130:	00000097          	auipc	ra,0x0
 134:	47e080e7          	jalr	1150(ra) # 5ae <exit>
{
 138:	6961                	lui	s2,0x18
 13a:	6a090913          	addi	s2,s2,1696 # 186a0 <_end+0x169c8>
        *(int *)(a+4) = 1;
 13e:	4985                	li	s3,1
        a = sbrk(4096);
 140:	6505                	lui	a0,0x1
 142:	00000097          	auipc	ra,0x0
 146:	4f4080e7          	jalr	1268(ra) # 636 <sbrk>
 14a:	84aa                	mv	s1,a0
        *(int *)(a+4) = 1;
 14c:	01352223          	sw	s3,4(a0) # 1004 <buf+0x33c>
        a1 = sbrk(-4096);
 150:	757d                	lui	a0,0xfffff
 152:	00000097          	auipc	ra,0x0
 156:	4e4080e7          	jalr	1252(ra) # 636 <sbrk>
        if (a1 != a + 4096) {
 15a:	6785                	lui	a5,0x1
 15c:	94be                	add	s1,s1,a5
 15e:	00951a63          	bne	a0,s1,172 <test1+0xee>
      for(i = 0; i < N; i++) {
 162:	397d                	addiw	s2,s2,-1
 164:	fc091ee3          	bnez	s2,140 <test1+0xbc>
      exit(-1);
 168:	557d                	li	a0,-1
 16a:	00000097          	auipc	ra,0x0
 16e:	444080e7          	jalr	1092(ra) # 5ae <exit>
          printf("wrong sbrk\n");
 172:	00001517          	auipc	a0,0x1
 176:	a1e50513          	addi	a0,a0,-1506 # b90 <statistics+0xc4>
 17a:	00000097          	auipc	ra,0x0
 17e:	7ac080e7          	jalr	1964(ra) # 926 <printf>
          exit(-1);
 182:	557d                	li	a0,-1
 184:	00000097          	auipc	ra,0x0
 188:	42a080e7          	jalr	1066(ra) # 5ae <exit>
    printf("test1 FAIL\n");
 18c:	00001517          	auipc	a0,0x1
 190:	a3450513          	addi	a0,a0,-1484 # bc0 <statistics+0xf4>
 194:	00000097          	auipc	ra,0x0
 198:	792080e7          	jalr	1938(ra) # 926 <printf>
}
 19c:	bf95                	j	110 <test1+0x8c>

000000000000019e <countfree>:
//
// countfree() from usertests.c
//
int
countfree()
{
 19e:	7179                	addi	sp,sp,-48
 1a0:	f406                	sd	ra,40(sp)
 1a2:	f022                	sd	s0,32(sp)
 1a4:	ec26                	sd	s1,24(sp)
 1a6:	e84a                	sd	s2,16(sp)
 1a8:	e44e                	sd	s3,8(sp)
 1aa:	e052                	sd	s4,0(sp)
 1ac:	1800                	addi	s0,sp,48
  uint64 sz0 = (uint64)sbrk(0);
 1ae:	4501                	li	a0,0
 1b0:	00000097          	auipc	ra,0x0
 1b4:	486080e7          	jalr	1158(ra) # 636 <sbrk>
 1b8:	8a2a                	mv	s4,a0
  int n = 0;
 1ba:	4481                	li	s1,0

  while(1){
    uint64 a = (uint64) sbrk(4096);
    if(a == 0xffffffffffffffff){
 1bc:	597d                	li	s2,-1
      break;
    }
    // modify the memory to make sure it's really allocated.
    *(char *)(a + 4096 - 1) = 1;
 1be:	4985                	li	s3,1
    uint64 a = (uint64) sbrk(4096);
 1c0:	6505                	lui	a0,0x1
 1c2:	00000097          	auipc	ra,0x0
 1c6:	474080e7          	jalr	1140(ra) # 636 <sbrk>
    if(a == 0xffffffffffffffff){
 1ca:	01250863          	beq	a0,s2,1da <countfree+0x3c>
    *(char *)(a + 4096 - 1) = 1;
 1ce:	6785                	lui	a5,0x1
 1d0:	97aa                	add	a5,a5,a0
 1d2:	ff378fa3          	sb	s3,-1(a5) # fff <buf+0x337>
    n += 1;
 1d6:	2485                	addiw	s1,s1,1
  while(1){
 1d8:	b7e5                	j	1c0 <countfree+0x22>
  }
  sbrk(-((uint64)sbrk(0) - sz0));
 1da:	4501                	li	a0,0
 1dc:	00000097          	auipc	ra,0x0
 1e0:	45a080e7          	jalr	1114(ra) # 636 <sbrk>
 1e4:	40aa053b          	subw	a0,s4,a0
 1e8:	00000097          	auipc	ra,0x0
 1ec:	44e080e7          	jalr	1102(ra) # 636 <sbrk>
  return n;
}
 1f0:	8526                	mv	a0,s1
 1f2:	70a2                	ld	ra,40(sp)
 1f4:	7402                	ld	s0,32(sp)
 1f6:	64e2                	ld	s1,24(sp)
 1f8:	6942                	ld	s2,16(sp)
 1fa:	69a2                	ld	s3,8(sp)
 1fc:	6a02                	ld	s4,0(sp)
 1fe:	6145                	addi	sp,sp,48
 200:	8082                	ret

0000000000000202 <test2>:

void test2() {
 202:	715d                	addi	sp,sp,-80
 204:	e486                	sd	ra,72(sp)
 206:	e0a2                	sd	s0,64(sp)
 208:	fc26                	sd	s1,56(sp)
 20a:	f84a                	sd	s2,48(sp)
 20c:	f44e                	sd	s3,40(sp)
 20e:	f052                	sd	s4,32(sp)
 210:	ec56                	sd	s5,24(sp)
 212:	e85a                	sd	s6,16(sp)
 214:	e45e                	sd	s7,8(sp)
 216:	e062                	sd	s8,0(sp)
 218:	0880                	addi	s0,sp,80
  int free0 = countfree();
 21a:	00000097          	auipc	ra,0x0
 21e:	f84080e7          	jalr	-124(ra) # 19e <countfree>
 222:	8a2a                	mv	s4,a0
  int free1;
  int n = (PHYSTOP-KERNBASE)/PGSIZE;
  printf("start test2\n");  
 224:	00001517          	auipc	a0,0x1
 228:	9ac50513          	addi	a0,a0,-1620 # bd0 <statistics+0x104>
 22c:	00000097          	auipc	ra,0x0
 230:	6fa080e7          	jalr	1786(ra) # 926 <printf>
  printf("total free number of pages: %d (out of %d)\n", free0, n);
 234:	6621                	lui	a2,0x8
 236:	85d2                	mv	a1,s4
 238:	00001517          	auipc	a0,0x1
 23c:	9a850513          	addi	a0,a0,-1624 # be0 <statistics+0x114>
 240:	00000097          	auipc	ra,0x0
 244:	6e6080e7          	jalr	1766(ra) # 926 <printf>
  if(n - free0 > 1000) {
 248:	67a1                	lui	a5,0x8
 24a:	414787bb          	subw	a5,a5,s4
 24e:	3e800713          	li	a4,1000
 252:	04f74763          	blt	a4,a5,2a0 <test2+0x9e>
    printf("test2 FAILED: cannot allocate enough memory");
    exit(-1);
  }
  for (int i = 0; i < 50; i++) {
    free1 = countfree();
 256:	00000097          	auipc	ra,0x0
 25a:	f48080e7          	jalr	-184(ra) # 19e <countfree>
 25e:	89aa                	mv	s3,a0
  for (int i = 0; i < 50; i++) {
 260:	4901                	li	s2,0
 262:	03200a93          	li	s5,50
    if(i % 10 == 9)
 266:	4ba9                	li	s7,10
 268:	4b25                	li	s6,9
      printf(".");
 26a:	00001c17          	auipc	s8,0x1
 26e:	9d6c0c13          	addi	s8,s8,-1578 # c40 <statistics+0x174>
    if(free1 != free0) {
 272:	053a1463          	bne	s4,s3,2ba <test2+0xb8>
  for (int i = 0; i < 50; i++) {
 276:	0019049b          	addiw	s1,s2,1
 27a:	0004891b          	sext.w	s2,s1
 27e:	05590b63          	beq	s2,s5,2d4 <test2+0xd2>
    free1 = countfree();
 282:	00000097          	auipc	ra,0x0
 286:	f1c080e7          	jalr	-228(ra) # 19e <countfree>
 28a:	89aa                	mv	s3,a0
    if(i % 10 == 9)
 28c:	0374e4bb          	remw	s1,s1,s7
 290:	ff6491e3          	bne	s1,s6,272 <test2+0x70>
      printf(".");
 294:	8562                	mv	a0,s8
 296:	00000097          	auipc	ra,0x0
 29a:	690080e7          	jalr	1680(ra) # 926 <printf>
 29e:	bfd1                	j	272 <test2+0x70>
    printf("test2 FAILED: cannot allocate enough memory");
 2a0:	00001517          	auipc	a0,0x1
 2a4:	97050513          	addi	a0,a0,-1680 # c10 <statistics+0x144>
 2a8:	00000097          	auipc	ra,0x0
 2ac:	67e080e7          	jalr	1662(ra) # 926 <printf>
    exit(-1);
 2b0:	557d                	li	a0,-1
 2b2:	00000097          	auipc	ra,0x0
 2b6:	2fc080e7          	jalr	764(ra) # 5ae <exit>
      printf("test2 FAIL: losing pages\n");
 2ba:	00001517          	auipc	a0,0x1
 2be:	98e50513          	addi	a0,a0,-1650 # c48 <statistics+0x17c>
 2c2:	00000097          	auipc	ra,0x0
 2c6:	664080e7          	jalr	1636(ra) # 926 <printf>
      exit(-1);
 2ca:	557d                	li	a0,-1
 2cc:	00000097          	auipc	ra,0x0
 2d0:	2e2080e7          	jalr	738(ra) # 5ae <exit>
    }
  }
  printf("\ntest2 OK\n");  
 2d4:	00001517          	auipc	a0,0x1
 2d8:	99450513          	addi	a0,a0,-1644 # c68 <statistics+0x19c>
 2dc:	00000097          	auipc	ra,0x0
 2e0:	64a080e7          	jalr	1610(ra) # 926 <printf>
}
 2e4:	60a6                	ld	ra,72(sp)
 2e6:	6406                	ld	s0,64(sp)
 2e8:	74e2                	ld	s1,56(sp)
 2ea:	7942                	ld	s2,48(sp)
 2ec:	79a2                	ld	s3,40(sp)
 2ee:	7a02                	ld	s4,32(sp)
 2f0:	6ae2                	ld	s5,24(sp)
 2f2:	6b42                	ld	s6,16(sp)
 2f4:	6ba2                	ld	s7,8(sp)
 2f6:	6c02                	ld	s8,0(sp)
 2f8:	6161                	addi	sp,sp,80
 2fa:	8082                	ret

00000000000002fc <main>:
{
 2fc:	1141                	addi	sp,sp,-16
 2fe:	e406                	sd	ra,8(sp)
 300:	e022                	sd	s0,0(sp)
 302:	0800                	addi	s0,sp,16
  test1();
 304:	00000097          	auipc	ra,0x0
 308:	d80080e7          	jalr	-640(ra) # 84 <test1>
  test2();
 30c:	00000097          	auipc	ra,0x0
 310:	ef6080e7          	jalr	-266(ra) # 202 <test2>
  exit(0);
 314:	4501                	li	a0,0
 316:	00000097          	auipc	ra,0x0
 31a:	298080e7          	jalr	664(ra) # 5ae <exit>

000000000000031e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 31e:	1141                	addi	sp,sp,-16
 320:	e422                	sd	s0,8(sp)
 322:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 324:	87aa                	mv	a5,a0
 326:	0585                	addi	a1,a1,1
 328:	0785                	addi	a5,a5,1
 32a:	fff5c703          	lbu	a4,-1(a1)
 32e:	fee78fa3          	sb	a4,-1(a5) # 7fff <_end+0x6327>
 332:	fb75                	bnez	a4,326 <strcpy+0x8>
    ;
  return os;
}
 334:	6422                	ld	s0,8(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret

000000000000033a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 33a:	1141                	addi	sp,sp,-16
 33c:	e422                	sd	s0,8(sp)
 33e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 340:	00054783          	lbu	a5,0(a0)
 344:	cf91                	beqz	a5,360 <strcmp+0x26>
 346:	0005c703          	lbu	a4,0(a1)
 34a:	00f71b63          	bne	a4,a5,360 <strcmp+0x26>
    p++, q++;
 34e:	0505                	addi	a0,a0,1
 350:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 352:	00054783          	lbu	a5,0(a0)
 356:	c789                	beqz	a5,360 <strcmp+0x26>
 358:	0005c703          	lbu	a4,0(a1)
 35c:	fef709e3          	beq	a4,a5,34e <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 360:	0005c503          	lbu	a0,0(a1)
}
 364:	40a7853b          	subw	a0,a5,a0
 368:	6422                	ld	s0,8(sp)
 36a:	0141                	addi	sp,sp,16
 36c:	8082                	ret

000000000000036e <strlen>:

uint
strlen(const char *s)
{
 36e:	1141                	addi	sp,sp,-16
 370:	e422                	sd	s0,8(sp)
 372:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 374:	00054783          	lbu	a5,0(a0)
 378:	cf91                	beqz	a5,394 <strlen+0x26>
 37a:	0505                	addi	a0,a0,1
 37c:	87aa                	mv	a5,a0
 37e:	4685                	li	a3,1
 380:	9e89                	subw	a3,a3,a0
 382:	00f6853b          	addw	a0,a3,a5
 386:	0785                	addi	a5,a5,1
 388:	fff7c703          	lbu	a4,-1(a5)
 38c:	fb7d                	bnez	a4,382 <strlen+0x14>
    ;
  return n;
}
 38e:	6422                	ld	s0,8(sp)
 390:	0141                	addi	sp,sp,16
 392:	8082                	ret
  for(n = 0; s[n]; n++)
 394:	4501                	li	a0,0
 396:	bfe5                	j	38e <strlen+0x20>

0000000000000398 <memset>:

void*
memset(void *dst, int c, uint n)
{
 398:	1141                	addi	sp,sp,-16
 39a:	e422                	sd	s0,8(sp)
 39c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 39e:	ce09                	beqz	a2,3b8 <memset+0x20>
 3a0:	87aa                	mv	a5,a0
 3a2:	fff6071b          	addiw	a4,a2,-1
 3a6:	1702                	slli	a4,a4,0x20
 3a8:	9301                	srli	a4,a4,0x20
 3aa:	0705                	addi	a4,a4,1
 3ac:	972a                	add	a4,a4,a0
    cdst[i] = c;
 3ae:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3b2:	0785                	addi	a5,a5,1
 3b4:	fee79de3          	bne	a5,a4,3ae <memset+0x16>
  }
  return dst;
}
 3b8:	6422                	ld	s0,8(sp)
 3ba:	0141                	addi	sp,sp,16
 3bc:	8082                	ret

00000000000003be <strchr>:

char*
strchr(const char *s, char c)
{
 3be:	1141                	addi	sp,sp,-16
 3c0:	e422                	sd	s0,8(sp)
 3c2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3c4:	00054783          	lbu	a5,0(a0)
 3c8:	cf91                	beqz	a5,3e4 <strchr+0x26>
    if(*s == c)
 3ca:	00f58a63          	beq	a1,a5,3de <strchr+0x20>
  for(; *s; s++)
 3ce:	0505                	addi	a0,a0,1
 3d0:	00054783          	lbu	a5,0(a0)
 3d4:	c781                	beqz	a5,3dc <strchr+0x1e>
    if(*s == c)
 3d6:	feb79ce3          	bne	a5,a1,3ce <strchr+0x10>
 3da:	a011                	j	3de <strchr+0x20>
      return (char*)s;
  return 0;
 3dc:	4501                	li	a0,0
}
 3de:	6422                	ld	s0,8(sp)
 3e0:	0141                	addi	sp,sp,16
 3e2:	8082                	ret
  return 0;
 3e4:	4501                	li	a0,0
 3e6:	bfe5                	j	3de <strchr+0x20>

00000000000003e8 <gets>:

char*
gets(char *buf, int max)
{
 3e8:	711d                	addi	sp,sp,-96
 3ea:	ec86                	sd	ra,88(sp)
 3ec:	e8a2                	sd	s0,80(sp)
 3ee:	e4a6                	sd	s1,72(sp)
 3f0:	e0ca                	sd	s2,64(sp)
 3f2:	fc4e                	sd	s3,56(sp)
 3f4:	f852                	sd	s4,48(sp)
 3f6:	f456                	sd	s5,40(sp)
 3f8:	f05a                	sd	s6,32(sp)
 3fa:	ec5e                	sd	s7,24(sp)
 3fc:	1080                	addi	s0,sp,96
 3fe:	8baa                	mv	s7,a0
 400:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 402:	892a                	mv	s2,a0
 404:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 406:	4aa9                	li	s5,10
 408:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 40a:	0019849b          	addiw	s1,s3,1
 40e:	0344d863          	ble	s4,s1,43e <gets+0x56>
    cc = read(0, &c, 1);
 412:	4605                	li	a2,1
 414:	faf40593          	addi	a1,s0,-81
 418:	4501                	li	a0,0
 41a:	00000097          	auipc	ra,0x0
 41e:	1ac080e7          	jalr	428(ra) # 5c6 <read>
    if(cc < 1)
 422:	00a05e63          	blez	a0,43e <gets+0x56>
    buf[i++] = c;
 426:	faf44783          	lbu	a5,-81(s0)
 42a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 42e:	01578763          	beq	a5,s5,43c <gets+0x54>
 432:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 434:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 436:	fd679ae3          	bne	a5,s6,40a <gets+0x22>
 43a:	a011                	j	43e <gets+0x56>
  for(i=0; i+1 < max; ){
 43c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 43e:	99de                	add	s3,s3,s7
 440:	00098023          	sb	zero,0(s3)
  return buf;
}
 444:	855e                	mv	a0,s7
 446:	60e6                	ld	ra,88(sp)
 448:	6446                	ld	s0,80(sp)
 44a:	64a6                	ld	s1,72(sp)
 44c:	6906                	ld	s2,64(sp)
 44e:	79e2                	ld	s3,56(sp)
 450:	7a42                	ld	s4,48(sp)
 452:	7aa2                	ld	s5,40(sp)
 454:	7b02                	ld	s6,32(sp)
 456:	6be2                	ld	s7,24(sp)
 458:	6125                	addi	sp,sp,96
 45a:	8082                	ret

000000000000045c <stat>:

int
stat(const char *n, struct stat *st)
{
 45c:	1101                	addi	sp,sp,-32
 45e:	ec06                	sd	ra,24(sp)
 460:	e822                	sd	s0,16(sp)
 462:	e426                	sd	s1,8(sp)
 464:	e04a                	sd	s2,0(sp)
 466:	1000                	addi	s0,sp,32
 468:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 46a:	4581                	li	a1,0
 46c:	00000097          	auipc	ra,0x0
 470:	182080e7          	jalr	386(ra) # 5ee <open>
  if(fd < 0)
 474:	02054563          	bltz	a0,49e <stat+0x42>
 478:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 47a:	85ca                	mv	a1,s2
 47c:	00000097          	auipc	ra,0x0
 480:	18a080e7          	jalr	394(ra) # 606 <fstat>
 484:	892a                	mv	s2,a0
  close(fd);
 486:	8526                	mv	a0,s1
 488:	00000097          	auipc	ra,0x0
 48c:	14e080e7          	jalr	334(ra) # 5d6 <close>
  return r;
}
 490:	854a                	mv	a0,s2
 492:	60e2                	ld	ra,24(sp)
 494:	6442                	ld	s0,16(sp)
 496:	64a2                	ld	s1,8(sp)
 498:	6902                	ld	s2,0(sp)
 49a:	6105                	addi	sp,sp,32
 49c:	8082                	ret
    return -1;
 49e:	597d                	li	s2,-1
 4a0:	bfc5                	j	490 <stat+0x34>

00000000000004a2 <atoi>:

int
atoi(const char *s)
{
 4a2:	1141                	addi	sp,sp,-16
 4a4:	e422                	sd	s0,8(sp)
 4a6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4a8:	00054683          	lbu	a3,0(a0)
 4ac:	fd06879b          	addiw	a5,a3,-48
 4b0:	0ff7f793          	andi	a5,a5,255
 4b4:	4725                	li	a4,9
 4b6:	02f76963          	bltu	a4,a5,4e8 <atoi+0x46>
 4ba:	862a                	mv	a2,a0
  n = 0;
 4bc:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4be:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4c0:	0605                	addi	a2,a2,1
 4c2:	0025179b          	slliw	a5,a0,0x2
 4c6:	9fa9                	addw	a5,a5,a0
 4c8:	0017979b          	slliw	a5,a5,0x1
 4cc:	9fb5                	addw	a5,a5,a3
 4ce:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4d2:	00064683          	lbu	a3,0(a2) # 8000 <_end+0x6328>
 4d6:	fd06871b          	addiw	a4,a3,-48
 4da:	0ff77713          	andi	a4,a4,255
 4de:	fee5f1e3          	bleu	a4,a1,4c0 <atoi+0x1e>
  return n;
}
 4e2:	6422                	ld	s0,8(sp)
 4e4:	0141                	addi	sp,sp,16
 4e6:	8082                	ret
  n = 0;
 4e8:	4501                	li	a0,0
 4ea:	bfe5                	j	4e2 <atoi+0x40>

00000000000004ec <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4ec:	1141                	addi	sp,sp,-16
 4ee:	e422                	sd	s0,8(sp)
 4f0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4f2:	02b57663          	bleu	a1,a0,51e <memmove+0x32>
    while(n-- > 0)
 4f6:	02c05163          	blez	a2,518 <memmove+0x2c>
 4fa:	fff6079b          	addiw	a5,a2,-1
 4fe:	1782                	slli	a5,a5,0x20
 500:	9381                	srli	a5,a5,0x20
 502:	0785                	addi	a5,a5,1
 504:	97aa                	add	a5,a5,a0
  dst = vdst;
 506:	872a                	mv	a4,a0
      *dst++ = *src++;
 508:	0585                	addi	a1,a1,1
 50a:	0705                	addi	a4,a4,1
 50c:	fff5c683          	lbu	a3,-1(a1)
 510:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 514:	fee79ae3          	bne	a5,a4,508 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 518:	6422                	ld	s0,8(sp)
 51a:	0141                	addi	sp,sp,16
 51c:	8082                	ret
    dst += n;
 51e:	00c50733          	add	a4,a0,a2
    src += n;
 522:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 524:	fec05ae3          	blez	a2,518 <memmove+0x2c>
 528:	fff6079b          	addiw	a5,a2,-1
 52c:	1782                	slli	a5,a5,0x20
 52e:	9381                	srli	a5,a5,0x20
 530:	fff7c793          	not	a5,a5
 534:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 536:	15fd                	addi	a1,a1,-1
 538:	177d                	addi	a4,a4,-1
 53a:	0005c683          	lbu	a3,0(a1)
 53e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 542:	fef71ae3          	bne	a4,a5,536 <memmove+0x4a>
 546:	bfc9                	j	518 <memmove+0x2c>

0000000000000548 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 548:	1141                	addi	sp,sp,-16
 54a:	e422                	sd	s0,8(sp)
 54c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 54e:	ce15                	beqz	a2,58a <memcmp+0x42>
 550:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 554:	00054783          	lbu	a5,0(a0)
 558:	0005c703          	lbu	a4,0(a1)
 55c:	02e79063          	bne	a5,a4,57c <memcmp+0x34>
 560:	1682                	slli	a3,a3,0x20
 562:	9281                	srli	a3,a3,0x20
 564:	0685                	addi	a3,a3,1
 566:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 568:	0505                	addi	a0,a0,1
    p2++;
 56a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 56c:	00d50d63          	beq	a0,a3,586 <memcmp+0x3e>
    if (*p1 != *p2) {
 570:	00054783          	lbu	a5,0(a0)
 574:	0005c703          	lbu	a4,0(a1)
 578:	fee788e3          	beq	a5,a4,568 <memcmp+0x20>
      return *p1 - *p2;
 57c:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 580:	6422                	ld	s0,8(sp)
 582:	0141                	addi	sp,sp,16
 584:	8082                	ret
  return 0;
 586:	4501                	li	a0,0
 588:	bfe5                	j	580 <memcmp+0x38>
 58a:	4501                	li	a0,0
 58c:	bfd5                	j	580 <memcmp+0x38>

000000000000058e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 58e:	1141                	addi	sp,sp,-16
 590:	e406                	sd	ra,8(sp)
 592:	e022                	sd	s0,0(sp)
 594:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 596:	00000097          	auipc	ra,0x0
 59a:	f56080e7          	jalr	-170(ra) # 4ec <memmove>
}
 59e:	60a2                	ld	ra,8(sp)
 5a0:	6402                	ld	s0,0(sp)
 5a2:	0141                	addi	sp,sp,16
 5a4:	8082                	ret

00000000000005a6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5a6:	4885                	li	a7,1
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <exit>:
.global exit
exit:
 li a7, SYS_exit
 5ae:	4889                	li	a7,2
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5b6:	488d                	li	a7,3
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5be:	4891                	li	a7,4
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <read>:
.global read
read:
 li a7, SYS_read
 5c6:	4895                	li	a7,5
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <write>:
.global write
write:
 li a7, SYS_write
 5ce:	48c1                	li	a7,16
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <close>:
.global close
close:
 li a7, SYS_close
 5d6:	48d5                	li	a7,21
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <kill>:
.global kill
kill:
 li a7, SYS_kill
 5de:	4899                	li	a7,6
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5e6:	489d                	li	a7,7
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <open>:
.global open
open:
 li a7, SYS_open
 5ee:	48bd                	li	a7,15
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5f6:	48c5                	li	a7,17
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5fe:	48c9                	li	a7,18
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 606:	48a1                	li	a7,8
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <link>:
.global link
link:
 li a7, SYS_link
 60e:	48cd                	li	a7,19
 ecall
 610:	00000073          	ecall
 ret
 614:	8082                	ret

0000000000000616 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 616:	48d1                	li	a7,20
 ecall
 618:	00000073          	ecall
 ret
 61c:	8082                	ret

000000000000061e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 61e:	48a5                	li	a7,9
 ecall
 620:	00000073          	ecall
 ret
 624:	8082                	ret

0000000000000626 <dup>:
.global dup
dup:
 li a7, SYS_dup
 626:	48a9                	li	a7,10
 ecall
 628:	00000073          	ecall
 ret
 62c:	8082                	ret

000000000000062e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 62e:	48ad                	li	a7,11
 ecall
 630:	00000073          	ecall
 ret
 634:	8082                	ret

0000000000000636 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 636:	48b1                	li	a7,12
 ecall
 638:	00000073          	ecall
 ret
 63c:	8082                	ret

000000000000063e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 63e:	48b5                	li	a7,13
 ecall
 640:	00000073          	ecall
 ret
 644:	8082                	ret

0000000000000646 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 646:	48b9                	li	a7,14
 ecall
 648:	00000073          	ecall
 ret
 64c:	8082                	ret

000000000000064e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 64e:	1101                	addi	sp,sp,-32
 650:	ec06                	sd	ra,24(sp)
 652:	e822                	sd	s0,16(sp)
 654:	1000                	addi	s0,sp,32
 656:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 65a:	4605                	li	a2,1
 65c:	fef40593          	addi	a1,s0,-17
 660:	00000097          	auipc	ra,0x0
 664:	f6e080e7          	jalr	-146(ra) # 5ce <write>
}
 668:	60e2                	ld	ra,24(sp)
 66a:	6442                	ld	s0,16(sp)
 66c:	6105                	addi	sp,sp,32
 66e:	8082                	ret

0000000000000670 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 670:	7139                	addi	sp,sp,-64
 672:	fc06                	sd	ra,56(sp)
 674:	f822                	sd	s0,48(sp)
 676:	f426                	sd	s1,40(sp)
 678:	f04a                	sd	s2,32(sp)
 67a:	ec4e                	sd	s3,24(sp)
 67c:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 67e:	c299                	beqz	a3,684 <printint+0x14>
 680:	0005cd63          	bltz	a1,69a <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 684:	2581                	sext.w	a1,a1
  neg = 0;
 686:	4301                	li	t1,0
 688:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 68c:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 68e:	2601                	sext.w	a2,a2
 690:	00000897          	auipc	a7,0x0
 694:	5e888893          	addi	a7,a7,1512 # c78 <digits>
 698:	a801                	j	6a8 <printint+0x38>
    x = -xx;
 69a:	40b005bb          	negw	a1,a1
 69e:	2581                	sext.w	a1,a1
    neg = 1;
 6a0:	4305                	li	t1,1
    x = -xx;
 6a2:	b7dd                	j	688 <printint+0x18>
  }while((x /= base) != 0);
 6a4:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 6a6:	8836                	mv	a6,a3
 6a8:	0018069b          	addiw	a3,a6,1
 6ac:	02c5f7bb          	remuw	a5,a1,a2
 6b0:	1782                	slli	a5,a5,0x20
 6b2:	9381                	srli	a5,a5,0x20
 6b4:	97c6                	add	a5,a5,a7
 6b6:	0007c783          	lbu	a5,0(a5)
 6ba:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 6be:	0705                	addi	a4,a4,1
 6c0:	02c5d7bb          	divuw	a5,a1,a2
 6c4:	fec5f0e3          	bleu	a2,a1,6a4 <printint+0x34>
  if(neg)
 6c8:	00030b63          	beqz	t1,6de <printint+0x6e>
    buf[i++] = '-';
 6cc:	fd040793          	addi	a5,s0,-48
 6d0:	96be                	add	a3,a3,a5
 6d2:	02d00793          	li	a5,45
 6d6:	fef68823          	sb	a5,-16(a3)
 6da:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 6de:	02d05963          	blez	a3,710 <printint+0xa0>
 6e2:	89aa                	mv	s3,a0
 6e4:	fc040793          	addi	a5,s0,-64
 6e8:	00d784b3          	add	s1,a5,a3
 6ec:	fff78913          	addi	s2,a5,-1
 6f0:	9936                	add	s2,s2,a3
 6f2:	36fd                	addiw	a3,a3,-1
 6f4:	1682                	slli	a3,a3,0x20
 6f6:	9281                	srli	a3,a3,0x20
 6f8:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 6fc:	fff4c583          	lbu	a1,-1(s1)
 700:	854e                	mv	a0,s3
 702:	00000097          	auipc	ra,0x0
 706:	f4c080e7          	jalr	-180(ra) # 64e <putc>
  while(--i >= 0)
 70a:	14fd                	addi	s1,s1,-1
 70c:	ff2498e3          	bne	s1,s2,6fc <printint+0x8c>
}
 710:	70e2                	ld	ra,56(sp)
 712:	7442                	ld	s0,48(sp)
 714:	74a2                	ld	s1,40(sp)
 716:	7902                	ld	s2,32(sp)
 718:	69e2                	ld	s3,24(sp)
 71a:	6121                	addi	sp,sp,64
 71c:	8082                	ret

000000000000071e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 71e:	7119                	addi	sp,sp,-128
 720:	fc86                	sd	ra,120(sp)
 722:	f8a2                	sd	s0,112(sp)
 724:	f4a6                	sd	s1,104(sp)
 726:	f0ca                	sd	s2,96(sp)
 728:	ecce                	sd	s3,88(sp)
 72a:	e8d2                	sd	s4,80(sp)
 72c:	e4d6                	sd	s5,72(sp)
 72e:	e0da                	sd	s6,64(sp)
 730:	fc5e                	sd	s7,56(sp)
 732:	f862                	sd	s8,48(sp)
 734:	f466                	sd	s9,40(sp)
 736:	f06a                	sd	s10,32(sp)
 738:	ec6e                	sd	s11,24(sp)
 73a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 73c:	0005c483          	lbu	s1,0(a1)
 740:	18048d63          	beqz	s1,8da <vprintf+0x1bc>
 744:	8aaa                	mv	s5,a0
 746:	8b32                	mv	s6,a2
 748:	00158913          	addi	s2,a1,1
  state = 0;
 74c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 74e:	02500a13          	li	s4,37
      if(c == 'd'){
 752:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 756:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 75a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 75e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 762:	00000b97          	auipc	s7,0x0
 766:	516b8b93          	addi	s7,s7,1302 # c78 <digits>
 76a:	a839                	j	788 <vprintf+0x6a>
        putc(fd, c);
 76c:	85a6                	mv	a1,s1
 76e:	8556                	mv	a0,s5
 770:	00000097          	auipc	ra,0x0
 774:	ede080e7          	jalr	-290(ra) # 64e <putc>
 778:	a019                	j	77e <vprintf+0x60>
    } else if(state == '%'){
 77a:	01498f63          	beq	s3,s4,798 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 77e:	0905                	addi	s2,s2,1
 780:	fff94483          	lbu	s1,-1(s2)
 784:	14048b63          	beqz	s1,8da <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 788:	0004879b          	sext.w	a5,s1
    if(state == 0){
 78c:	fe0997e3          	bnez	s3,77a <vprintf+0x5c>
      if(c == '%'){
 790:	fd479ee3          	bne	a5,s4,76c <vprintf+0x4e>
        state = '%';
 794:	89be                	mv	s3,a5
 796:	b7e5                	j	77e <vprintf+0x60>
      if(c == 'd'){
 798:	05878063          	beq	a5,s8,7d8 <vprintf+0xba>
      } else if(c == 'l') {
 79c:	05978c63          	beq	a5,s9,7f4 <vprintf+0xd6>
      } else if(c == 'x') {
 7a0:	07a78863          	beq	a5,s10,810 <vprintf+0xf2>
      } else if(c == 'p') {
 7a4:	09b78463          	beq	a5,s11,82c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 7a8:	07300713          	li	a4,115
 7ac:	0ce78563          	beq	a5,a4,876 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7b0:	06300713          	li	a4,99
 7b4:	0ee78c63          	beq	a5,a4,8ac <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7b8:	11478663          	beq	a5,s4,8c4 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7bc:	85d2                	mv	a1,s4
 7be:	8556                	mv	a0,s5
 7c0:	00000097          	auipc	ra,0x0
 7c4:	e8e080e7          	jalr	-370(ra) # 64e <putc>
        putc(fd, c);
 7c8:	85a6                	mv	a1,s1
 7ca:	8556                	mv	a0,s5
 7cc:	00000097          	auipc	ra,0x0
 7d0:	e82080e7          	jalr	-382(ra) # 64e <putc>
      }
      state = 0;
 7d4:	4981                	li	s3,0
 7d6:	b765                	j	77e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7d8:	008b0493          	addi	s1,s6,8
 7dc:	4685                	li	a3,1
 7de:	4629                	li	a2,10
 7e0:	000b2583          	lw	a1,0(s6)
 7e4:	8556                	mv	a0,s5
 7e6:	00000097          	auipc	ra,0x0
 7ea:	e8a080e7          	jalr	-374(ra) # 670 <printint>
 7ee:	8b26                	mv	s6,s1
      state = 0;
 7f0:	4981                	li	s3,0
 7f2:	b771                	j	77e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7f4:	008b0493          	addi	s1,s6,8
 7f8:	4681                	li	a3,0
 7fa:	4629                	li	a2,10
 7fc:	000b2583          	lw	a1,0(s6)
 800:	8556                	mv	a0,s5
 802:	00000097          	auipc	ra,0x0
 806:	e6e080e7          	jalr	-402(ra) # 670 <printint>
 80a:	8b26                	mv	s6,s1
      state = 0;
 80c:	4981                	li	s3,0
 80e:	bf85                	j	77e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 810:	008b0493          	addi	s1,s6,8
 814:	4681                	li	a3,0
 816:	4641                	li	a2,16
 818:	000b2583          	lw	a1,0(s6)
 81c:	8556                	mv	a0,s5
 81e:	00000097          	auipc	ra,0x0
 822:	e52080e7          	jalr	-430(ra) # 670 <printint>
 826:	8b26                	mv	s6,s1
      state = 0;
 828:	4981                	li	s3,0
 82a:	bf91                	j	77e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 82c:	008b0793          	addi	a5,s6,8
 830:	f8f43423          	sd	a5,-120(s0)
 834:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 838:	03000593          	li	a1,48
 83c:	8556                	mv	a0,s5
 83e:	00000097          	auipc	ra,0x0
 842:	e10080e7          	jalr	-496(ra) # 64e <putc>
  putc(fd, 'x');
 846:	85ea                	mv	a1,s10
 848:	8556                	mv	a0,s5
 84a:	00000097          	auipc	ra,0x0
 84e:	e04080e7          	jalr	-508(ra) # 64e <putc>
 852:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 854:	03c9d793          	srli	a5,s3,0x3c
 858:	97de                	add	a5,a5,s7
 85a:	0007c583          	lbu	a1,0(a5)
 85e:	8556                	mv	a0,s5
 860:	00000097          	auipc	ra,0x0
 864:	dee080e7          	jalr	-530(ra) # 64e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 868:	0992                	slli	s3,s3,0x4
 86a:	34fd                	addiw	s1,s1,-1
 86c:	f4e5                	bnez	s1,854 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 86e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 872:	4981                	li	s3,0
 874:	b729                	j	77e <vprintf+0x60>
        s = va_arg(ap, char*);
 876:	008b0993          	addi	s3,s6,8
 87a:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 87e:	c085                	beqz	s1,89e <vprintf+0x180>
        while(*s != 0){
 880:	0004c583          	lbu	a1,0(s1)
 884:	c9a1                	beqz	a1,8d4 <vprintf+0x1b6>
          putc(fd, *s);
 886:	8556                	mv	a0,s5
 888:	00000097          	auipc	ra,0x0
 88c:	dc6080e7          	jalr	-570(ra) # 64e <putc>
          s++;
 890:	0485                	addi	s1,s1,1
        while(*s != 0){
 892:	0004c583          	lbu	a1,0(s1)
 896:	f9e5                	bnez	a1,886 <vprintf+0x168>
        s = va_arg(ap, char*);
 898:	8b4e                	mv	s6,s3
      state = 0;
 89a:	4981                	li	s3,0
 89c:	b5cd                	j	77e <vprintf+0x60>
          s = "(null)";
 89e:	00000497          	auipc	s1,0x0
 8a2:	3f248493          	addi	s1,s1,1010 # c90 <digits+0x18>
        while(*s != 0){
 8a6:	02800593          	li	a1,40
 8aa:	bff1                	j	886 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 8ac:	008b0493          	addi	s1,s6,8
 8b0:	000b4583          	lbu	a1,0(s6)
 8b4:	8556                	mv	a0,s5
 8b6:	00000097          	auipc	ra,0x0
 8ba:	d98080e7          	jalr	-616(ra) # 64e <putc>
 8be:	8b26                	mv	s6,s1
      state = 0;
 8c0:	4981                	li	s3,0
 8c2:	bd75                	j	77e <vprintf+0x60>
        putc(fd, c);
 8c4:	85d2                	mv	a1,s4
 8c6:	8556                	mv	a0,s5
 8c8:	00000097          	auipc	ra,0x0
 8cc:	d86080e7          	jalr	-634(ra) # 64e <putc>
      state = 0;
 8d0:	4981                	li	s3,0
 8d2:	b575                	j	77e <vprintf+0x60>
        s = va_arg(ap, char*);
 8d4:	8b4e                	mv	s6,s3
      state = 0;
 8d6:	4981                	li	s3,0
 8d8:	b55d                	j	77e <vprintf+0x60>
    }
  }
}
 8da:	70e6                	ld	ra,120(sp)
 8dc:	7446                	ld	s0,112(sp)
 8de:	74a6                	ld	s1,104(sp)
 8e0:	7906                	ld	s2,96(sp)
 8e2:	69e6                	ld	s3,88(sp)
 8e4:	6a46                	ld	s4,80(sp)
 8e6:	6aa6                	ld	s5,72(sp)
 8e8:	6b06                	ld	s6,64(sp)
 8ea:	7be2                	ld	s7,56(sp)
 8ec:	7c42                	ld	s8,48(sp)
 8ee:	7ca2                	ld	s9,40(sp)
 8f0:	7d02                	ld	s10,32(sp)
 8f2:	6de2                	ld	s11,24(sp)
 8f4:	6109                	addi	sp,sp,128
 8f6:	8082                	ret

00000000000008f8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8f8:	715d                	addi	sp,sp,-80
 8fa:	ec06                	sd	ra,24(sp)
 8fc:	e822                	sd	s0,16(sp)
 8fe:	1000                	addi	s0,sp,32
 900:	e010                	sd	a2,0(s0)
 902:	e414                	sd	a3,8(s0)
 904:	e818                	sd	a4,16(s0)
 906:	ec1c                	sd	a5,24(s0)
 908:	03043023          	sd	a6,32(s0)
 90c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 910:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 914:	8622                	mv	a2,s0
 916:	00000097          	auipc	ra,0x0
 91a:	e08080e7          	jalr	-504(ra) # 71e <vprintf>
}
 91e:	60e2                	ld	ra,24(sp)
 920:	6442                	ld	s0,16(sp)
 922:	6161                	addi	sp,sp,80
 924:	8082                	ret

0000000000000926 <printf>:

void
printf(const char *fmt, ...)
{
 926:	711d                	addi	sp,sp,-96
 928:	ec06                	sd	ra,24(sp)
 92a:	e822                	sd	s0,16(sp)
 92c:	1000                	addi	s0,sp,32
 92e:	e40c                	sd	a1,8(s0)
 930:	e810                	sd	a2,16(s0)
 932:	ec14                	sd	a3,24(s0)
 934:	f018                	sd	a4,32(s0)
 936:	f41c                	sd	a5,40(s0)
 938:	03043823          	sd	a6,48(s0)
 93c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 940:	00840613          	addi	a2,s0,8
 944:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 948:	85aa                	mv	a1,a0
 94a:	4505                	li	a0,1
 94c:	00000097          	auipc	ra,0x0
 950:	dd2080e7          	jalr	-558(ra) # 71e <vprintf>
}
 954:	60e2                	ld	ra,24(sp)
 956:	6442                	ld	s0,16(sp)
 958:	6125                	addi	sp,sp,96
 95a:	8082                	ret

000000000000095c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 95c:	1141                	addi	sp,sp,-16
 95e:	e422                	sd	s0,8(sp)
 960:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 962:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 966:	00000797          	auipc	a5,0x0
 96a:	35a78793          	addi	a5,a5,858 # cc0 <__bss_start>
 96e:	639c                	ld	a5,0(a5)
 970:	a805                	j	9a0 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 972:	4618                	lw	a4,8(a2)
 974:	9db9                	addw	a1,a1,a4
 976:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 97a:	6398                	ld	a4,0(a5)
 97c:	6318                	ld	a4,0(a4)
 97e:	fee53823          	sd	a4,-16(a0)
 982:	a091                	j	9c6 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 984:	ff852703          	lw	a4,-8(a0)
 988:	9e39                	addw	a2,a2,a4
 98a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 98c:	ff053703          	ld	a4,-16(a0)
 990:	e398                	sd	a4,0(a5)
 992:	a099                	j	9d8 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 994:	6398                	ld	a4,0(a5)
 996:	00e7e463          	bltu	a5,a4,99e <free+0x42>
 99a:	00e6ea63          	bltu	a3,a4,9ae <free+0x52>
{
 99e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9a0:	fed7fae3          	bleu	a3,a5,994 <free+0x38>
 9a4:	6398                	ld	a4,0(a5)
 9a6:	00e6e463          	bltu	a3,a4,9ae <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9aa:	fee7eae3          	bltu	a5,a4,99e <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 9ae:	ff852583          	lw	a1,-8(a0)
 9b2:	6390                	ld	a2,0(a5)
 9b4:	02059713          	slli	a4,a1,0x20
 9b8:	9301                	srli	a4,a4,0x20
 9ba:	0712                	slli	a4,a4,0x4
 9bc:	9736                	add	a4,a4,a3
 9be:	fae60ae3          	beq	a2,a4,972 <free+0x16>
    bp->s.ptr = p->s.ptr;
 9c2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9c6:	4790                	lw	a2,8(a5)
 9c8:	02061713          	slli	a4,a2,0x20
 9cc:	9301                	srli	a4,a4,0x20
 9ce:	0712                	slli	a4,a4,0x4
 9d0:	973e                	add	a4,a4,a5
 9d2:	fae689e3          	beq	a3,a4,984 <free+0x28>
  } else
    p->s.ptr = bp;
 9d6:	e394                	sd	a3,0(a5)
  freep = p;
 9d8:	00000717          	auipc	a4,0x0
 9dc:	2ef73423          	sd	a5,744(a4) # cc0 <__bss_start>
}
 9e0:	6422                	ld	s0,8(sp)
 9e2:	0141                	addi	sp,sp,16
 9e4:	8082                	ret

00000000000009e6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9e6:	7139                	addi	sp,sp,-64
 9e8:	fc06                	sd	ra,56(sp)
 9ea:	f822                	sd	s0,48(sp)
 9ec:	f426                	sd	s1,40(sp)
 9ee:	f04a                	sd	s2,32(sp)
 9f0:	ec4e                	sd	s3,24(sp)
 9f2:	e852                	sd	s4,16(sp)
 9f4:	e456                	sd	s5,8(sp)
 9f6:	e05a                	sd	s6,0(sp)
 9f8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9fa:	02051993          	slli	s3,a0,0x20
 9fe:	0209d993          	srli	s3,s3,0x20
 a02:	09bd                	addi	s3,s3,15
 a04:	0049d993          	srli	s3,s3,0x4
 a08:	2985                	addiw	s3,s3,1
 a0a:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 a0e:	00000797          	auipc	a5,0x0
 a12:	2b278793          	addi	a5,a5,690 # cc0 <__bss_start>
 a16:	6388                	ld	a0,0(a5)
 a18:	c515                	beqz	a0,a44 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a1a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a1c:	4798                	lw	a4,8(a5)
 a1e:	03277f63          	bleu	s2,a4,a5c <malloc+0x76>
 a22:	8a4e                	mv	s4,s3
 a24:	0009871b          	sext.w	a4,s3
 a28:	6685                	lui	a3,0x1
 a2a:	00d77363          	bleu	a3,a4,a30 <malloc+0x4a>
 a2e:	6a05                	lui	s4,0x1
 a30:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 a34:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a38:	00000497          	auipc	s1,0x0
 a3c:	28848493          	addi	s1,s1,648 # cc0 <__bss_start>
  if(p == (char*)-1)
 a40:	5b7d                	li	s6,-1
 a42:	a885                	j	ab2 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 a44:	00001797          	auipc	a5,0x1
 a48:	28478793          	addi	a5,a5,644 # 1cc8 <base>
 a4c:	00000717          	auipc	a4,0x0
 a50:	26f73a23          	sd	a5,628(a4) # cc0 <__bss_start>
 a54:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a56:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a5a:	b7e1                	j	a22 <malloc+0x3c>
      if(p->s.size == nunits)
 a5c:	02e90b63          	beq	s2,a4,a92 <malloc+0xac>
        p->s.size -= nunits;
 a60:	4137073b          	subw	a4,a4,s3
 a64:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a66:	1702                	slli	a4,a4,0x20
 a68:	9301                	srli	a4,a4,0x20
 a6a:	0712                	slli	a4,a4,0x4
 a6c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a6e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a72:	00000717          	auipc	a4,0x0
 a76:	24a73723          	sd	a0,590(a4) # cc0 <__bss_start>
      return (void*)(p + 1);
 a7a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a7e:	70e2                	ld	ra,56(sp)
 a80:	7442                	ld	s0,48(sp)
 a82:	74a2                	ld	s1,40(sp)
 a84:	7902                	ld	s2,32(sp)
 a86:	69e2                	ld	s3,24(sp)
 a88:	6a42                	ld	s4,16(sp)
 a8a:	6aa2                	ld	s5,8(sp)
 a8c:	6b02                	ld	s6,0(sp)
 a8e:	6121                	addi	sp,sp,64
 a90:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a92:	6398                	ld	a4,0(a5)
 a94:	e118                	sd	a4,0(a0)
 a96:	bff1                	j	a72 <malloc+0x8c>
  hp->s.size = nu;
 a98:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 a9c:	0541                	addi	a0,a0,16
 a9e:	00000097          	auipc	ra,0x0
 aa2:	ebe080e7          	jalr	-322(ra) # 95c <free>
  return freep;
 aa6:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 aa8:	d979                	beqz	a0,a7e <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aaa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aac:	4798                	lw	a4,8(a5)
 aae:	fb2777e3          	bleu	s2,a4,a5c <malloc+0x76>
    if(p == freep)
 ab2:	6098                	ld	a4,0(s1)
 ab4:	853e                	mv	a0,a5
 ab6:	fef71ae3          	bne	a4,a5,aaa <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 aba:	8552                	mv	a0,s4
 abc:	00000097          	auipc	ra,0x0
 ac0:	b7a080e7          	jalr	-1158(ra) # 636 <sbrk>
  if(p == (char*)-1)
 ac4:	fd651ae3          	bne	a0,s6,a98 <malloc+0xb2>
        return 0;
 ac8:	4501                	li	a0,0
 aca:	bf55                	j	a7e <malloc+0x98>

0000000000000acc <statistics>:
#include "kernel/fcntl.h"
#include "user/user.h"

int
statistics(void *buf, int sz)
{
 acc:	7179                	addi	sp,sp,-48
 ace:	f406                	sd	ra,40(sp)
 ad0:	f022                	sd	s0,32(sp)
 ad2:	ec26                	sd	s1,24(sp)
 ad4:	e84a                	sd	s2,16(sp)
 ad6:	e44e                	sd	s3,8(sp)
 ad8:	e052                	sd	s4,0(sp)
 ada:	1800                	addi	s0,sp,48
 adc:	8a2a                	mv	s4,a0
 ade:	892e                	mv	s2,a1
  int fd, i, n;
  
  fd = open("statistics", O_RDONLY);
 ae0:	4581                	li	a1,0
 ae2:	00000517          	auipc	a0,0x0
 ae6:	1b650513          	addi	a0,a0,438 # c98 <digits+0x20>
 aea:	00000097          	auipc	ra,0x0
 aee:	b04080e7          	jalr	-1276(ra) # 5ee <open>
  if(fd < 0) {
 af2:	04054263          	bltz	a0,b36 <statistics+0x6a>
 af6:	89aa                	mv	s3,a0
      fprintf(2, "stats: open failed\n");
      exit(1);
  }
  for (i = 0; i < sz; ) {
 af8:	4481                	li	s1,0
 afa:	03205063          	blez	s2,b1a <statistics+0x4e>
    if ((n = read(fd, buf+i, sz-i)) < 0) {
 afe:	4099063b          	subw	a2,s2,s1
 b02:	009a05b3          	add	a1,s4,s1
 b06:	854e                	mv	a0,s3
 b08:	00000097          	auipc	ra,0x0
 b0c:	abe080e7          	jalr	-1346(ra) # 5c6 <read>
 b10:	00054563          	bltz	a0,b1a <statistics+0x4e>
      break;
    }
    i += n;
 b14:	9ca9                	addw	s1,s1,a0
  for (i = 0; i < sz; ) {
 b16:	ff24c4e3          	blt	s1,s2,afe <statistics+0x32>
  }
  close(fd);
 b1a:	854e                	mv	a0,s3
 b1c:	00000097          	auipc	ra,0x0
 b20:	aba080e7          	jalr	-1350(ra) # 5d6 <close>
  return i;
}
 b24:	8526                	mv	a0,s1
 b26:	70a2                	ld	ra,40(sp)
 b28:	7402                	ld	s0,32(sp)
 b2a:	64e2                	ld	s1,24(sp)
 b2c:	6942                	ld	s2,16(sp)
 b2e:	69a2                	ld	s3,8(sp)
 b30:	6a02                	ld	s4,0(sp)
 b32:	6145                	addi	sp,sp,48
 b34:	8082                	ret
      fprintf(2, "stats: open failed\n");
 b36:	00000597          	auipc	a1,0x0
 b3a:	17258593          	addi	a1,a1,370 # ca8 <digits+0x30>
 b3e:	4509                	li	a0,2
 b40:	00000097          	auipc	ra,0x0
 b44:	db8080e7          	jalr	-584(ra) # 8f8 <fprintf>
      exit(1);
 b48:	4505                	li	a0,1
 b4a:	00000097          	auipc	ra,0x0
 b4e:	a64080e7          	jalr	-1436(ra) # 5ae <exit>
