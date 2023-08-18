
user/_lazytests：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <sparse_memory>:

#define REGION_SZ (1024 * 1024 * 1024)

void
sparse_memory(char *s)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  char *i, *prev_end, *new_end;
  
  prev_end = sbrk(REGION_SZ);
   8:	40000537          	lui	a0,0x40000
   c:	00000097          	auipc	ra,0x0
  10:	634080e7          	jalr	1588(ra) # 640 <sbrk>
  if (prev_end == (char*)0xffffffffffffffffL) {
  14:	57fd                	li	a5,-1
  16:	04f50863          	beq	a0,a5,66 <sparse_memory+0x66>
    printf("sbrk() failed\n");
    exit(1);
  }
  new_end = prev_end + REGION_SZ;

  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
  1a:	6605                	lui	a2,0x1
  1c:	962a                	add	a2,a2,a0
  1e:	40001737          	lui	a4,0x40001
  22:	972a                	add	a4,a4,a0
  24:	87b2                	mv	a5,a2
  26:	000406b7          	lui	a3,0x40
    *(char **)i = i;
  2a:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
  2c:	97b6                	add	a5,a5,a3
  2e:	fee79ee3          	bne	a5,a4,2a <sparse_memory+0x2a>

  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
    if (*(char **)i != i) {
  32:	6785                	lui	a5,0x1
  34:	953e                	add	a0,a0,a5
  36:	611c                	ld	a5,0(a0)
  38:	00f61a63          	bne	a2,a5,4c <sparse_memory+0x4c>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
  3c:	000406b7          	lui	a3,0x40
  40:	9636                	add	a2,a2,a3
  42:	02e60f63          	beq	a2,a4,80 <sparse_memory+0x80>
    if (*(char **)i != i) {
  46:	621c                	ld	a5,0(a2)
  48:	fec78ce3          	beq	a5,a2,40 <sparse_memory+0x40>
      printf("failed to read value from memory\n");
  4c:	00001517          	auipc	a0,0x1
  50:	adc50513          	addi	a0,a0,-1316 # b28 <malloc+0x138>
  54:	00001097          	auipc	ra,0x1
  58:	8dc080e7          	jalr	-1828(ra) # 930 <printf>
      exit(1);
  5c:	4505                	li	a0,1
  5e:	00000097          	auipc	ra,0x0
  62:	55a080e7          	jalr	1370(ra) # 5b8 <exit>
    printf("sbrk() failed\n");
  66:	00001517          	auipc	a0,0x1
  6a:	ab250513          	addi	a0,a0,-1358 # b18 <malloc+0x128>
  6e:	00001097          	auipc	ra,0x1
  72:	8c2080e7          	jalr	-1854(ra) # 930 <printf>
    exit(1);
  76:	4505                	li	a0,1
  78:	00000097          	auipc	ra,0x0
  7c:	540080e7          	jalr	1344(ra) # 5b8 <exit>
    }
  }

  exit(0);
  80:	4501                	li	a0,0
  82:	00000097          	auipc	ra,0x0
  86:	536080e7          	jalr	1334(ra) # 5b8 <exit>

000000000000008a <sparse_memory_unmap>:
}

void
sparse_memory_unmap(char *s)
{
  8a:	7139                	addi	sp,sp,-64
  8c:	fc06                	sd	ra,56(sp)
  8e:	f822                	sd	s0,48(sp)
  90:	f426                	sd	s1,40(sp)
  92:	f04a                	sd	s2,32(sp)
  94:	ec4e                	sd	s3,24(sp)
  96:	0080                	addi	s0,sp,64
  int pid;
  char *i, *prev_end, *new_end;

  prev_end = sbrk(REGION_SZ);
  98:	40000537          	lui	a0,0x40000
  9c:	00000097          	auipc	ra,0x0
  a0:	5a4080e7          	jalr	1444(ra) # 640 <sbrk>
  if (prev_end == (char*)0xffffffffffffffffL) {
  a4:	57fd                	li	a5,-1
  a6:	04f50863          	beq	a0,a5,f6 <sparse_memory_unmap+0x6c>
    printf("sbrk() failed\n");
    exit(1);
  }
  new_end = prev_end + REGION_SZ;

  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
  aa:	6905                	lui	s2,0x1
  ac:	992a                	add	s2,s2,a0
  ae:	400014b7          	lui	s1,0x40001
  b2:	94aa                	add	s1,s1,a0
  b4:	87ca                	mv	a5,s2
  b6:	01000737          	lui	a4,0x1000
    *(char **)i = i;
  ba:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
  bc:	97ba                	add	a5,a5,a4
  be:	fef49ee3          	bne	s1,a5,ba <sparse_memory_unmap+0x30>

  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
  c2:	010009b7          	lui	s3,0x1000
    pid = fork();
  c6:	00000097          	auipc	ra,0x0
  ca:	4ea080e7          	jalr	1258(ra) # 5b0 <fork>
    if (pid < 0) {
  ce:	04054163          	bltz	a0,110 <sparse_memory_unmap+0x86>
      printf("error forking\n");
      exit(1);
    } else if (pid == 0) {
  d2:	cd21                	beqz	a0,12a <sparse_memory_unmap+0xa0>
      sbrk(-1L * REGION_SZ);
      *(char **)i = i;
      exit(0);
    } else {
      int status;
      wait(&status);
  d4:	fcc40513          	addi	a0,s0,-52
  d8:	00000097          	auipc	ra,0x0
  dc:	4e8080e7          	jalr	1256(ra) # 5c0 <wait>
      if (status == 0) {
  e0:	fcc42783          	lw	a5,-52(s0)
  e4:	c3a5                	beqz	a5,144 <sparse_memory_unmap+0xba>
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
  e6:	994e                	add	s2,s2,s3
  e8:	fd249fe3          	bne	s1,s2,c6 <sparse_memory_unmap+0x3c>
        exit(1);
      }
    }
  }

  exit(0);
  ec:	4501                	li	a0,0
  ee:	00000097          	auipc	ra,0x0
  f2:	4ca080e7          	jalr	1226(ra) # 5b8 <exit>
    printf("sbrk() failed\n");
  f6:	00001517          	auipc	a0,0x1
  fa:	a2250513          	addi	a0,a0,-1502 # b18 <malloc+0x128>
  fe:	00001097          	auipc	ra,0x1
 102:	832080e7          	jalr	-1998(ra) # 930 <printf>
    exit(1);
 106:	4505                	li	a0,1
 108:	00000097          	auipc	ra,0x0
 10c:	4b0080e7          	jalr	1200(ra) # 5b8 <exit>
      printf("error forking\n");
 110:	00001517          	auipc	a0,0x1
 114:	a4050513          	addi	a0,a0,-1472 # b50 <malloc+0x160>
 118:	00001097          	auipc	ra,0x1
 11c:	818080e7          	jalr	-2024(ra) # 930 <printf>
      exit(1);
 120:	4505                	li	a0,1
 122:	00000097          	auipc	ra,0x0
 126:	496080e7          	jalr	1174(ra) # 5b8 <exit>
      sbrk(-1L * REGION_SZ);
 12a:	c0000537          	lui	a0,0xc0000
 12e:	00000097          	auipc	ra,0x0
 132:	512080e7          	jalr	1298(ra) # 640 <sbrk>
      *(char **)i = i;
 136:	01293023          	sd	s2,0(s2) # 1000 <_end+0x380>
      exit(0);
 13a:	4501                	li	a0,0
 13c:	00000097          	auipc	ra,0x0
 140:	47c080e7          	jalr	1148(ra) # 5b8 <exit>
        printf("memory not unmapped\n");
 144:	00001517          	auipc	a0,0x1
 148:	a1c50513          	addi	a0,a0,-1508 # b60 <malloc+0x170>
 14c:	00000097          	auipc	ra,0x0
 150:	7e4080e7          	jalr	2020(ra) # 930 <printf>
        exit(1);
 154:	4505                	li	a0,1
 156:	00000097          	auipc	ra,0x0
 15a:	462080e7          	jalr	1122(ra) # 5b8 <exit>

000000000000015e <oom>:
}

void
oom(char *s)
{
 15e:	7179                	addi	sp,sp,-48
 160:	f406                	sd	ra,40(sp)
 162:	f022                	sd	s0,32(sp)
 164:	ec26                	sd	s1,24(sp)
 166:	1800                	addi	s0,sp,48
  void *m1, *m2;
  int pid;

  if((pid = fork()) == 0){
 168:	00000097          	auipc	ra,0x0
 16c:	448080e7          	jalr	1096(ra) # 5b0 <fork>
    m1 = 0;
 170:	4481                	li	s1,0
  if((pid = fork()) == 0){
 172:	ed19                	bnez	a0,190 <oom+0x32>
    while((m2 = malloc(4096*4096)) != 0){
 174:	01000537          	lui	a0,0x1000
 178:	00001097          	auipc	ra,0x1
 17c:	878080e7          	jalr	-1928(ra) # 9f0 <malloc>
 180:	c501                	beqz	a0,188 <oom+0x2a>
      *(char**)m2 = m1;
 182:	e104                	sd	s1,0(a0)
      m1 = m2;
 184:	84aa                	mv	s1,a0
 186:	b7fd                	j	174 <oom+0x16>
    }
    exit(0);
 188:	00000097          	auipc	ra,0x0
 18c:	430080e7          	jalr	1072(ra) # 5b8 <exit>
  } else {
    int xstatus;
    wait(&xstatus);
 190:	fdc40513          	addi	a0,s0,-36
 194:	00000097          	auipc	ra,0x0
 198:	42c080e7          	jalr	1068(ra) # 5c0 <wait>
    exit(xstatus == 0);
 19c:	fdc42503          	lw	a0,-36(s0)
 1a0:	00153513          	seqz	a0,a0
 1a4:	00000097          	auipc	ra,0x0
 1a8:	414080e7          	jalr	1044(ra) # 5b8 <exit>

00000000000001ac <run>:
}

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
 1ac:	7179                	addi	sp,sp,-48
 1ae:	f406                	sd	ra,40(sp)
 1b0:	f022                	sd	s0,32(sp)
 1b2:	ec26                	sd	s1,24(sp)
 1b4:	e84a                	sd	s2,16(sp)
 1b6:	1800                	addi	s0,sp,48
 1b8:	892a                	mv	s2,a0
 1ba:	84ae                	mv	s1,a1
  int pid;
  int xstatus;
  
  printf("running test %s\n", s);
 1bc:	00001517          	auipc	a0,0x1
 1c0:	9bc50513          	addi	a0,a0,-1604 # b78 <malloc+0x188>
 1c4:	00000097          	auipc	ra,0x0
 1c8:	76c080e7          	jalr	1900(ra) # 930 <printf>
  if((pid = fork()) < 0) {
 1cc:	00000097          	auipc	ra,0x0
 1d0:	3e4080e7          	jalr	996(ra) # 5b0 <fork>
 1d4:	02054f63          	bltz	a0,212 <run+0x66>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
 1d8:	c931                	beqz	a0,22c <run+0x80>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
 1da:	fdc40513          	addi	a0,s0,-36
 1de:	00000097          	auipc	ra,0x0
 1e2:	3e2080e7          	jalr	994(ra) # 5c0 <wait>
    if(xstatus != 0) 
 1e6:	fdc42783          	lw	a5,-36(s0)
 1ea:	cba1                	beqz	a5,23a <run+0x8e>
      printf("test %s: FAILED\n", s);
 1ec:	85a6                	mv	a1,s1
 1ee:	00001517          	auipc	a0,0x1
 1f2:	9ba50513          	addi	a0,a0,-1606 # ba8 <malloc+0x1b8>
 1f6:	00000097          	auipc	ra,0x0
 1fa:	73a080e7          	jalr	1850(ra) # 930 <printf>
    else
      printf("test %s: OK\n", s);
    return xstatus == 0;
 1fe:	fdc42503          	lw	a0,-36(s0)
  }
}
 202:	00153513          	seqz	a0,a0
 206:	70a2                	ld	ra,40(sp)
 208:	7402                	ld	s0,32(sp)
 20a:	64e2                	ld	s1,24(sp)
 20c:	6942                	ld	s2,16(sp)
 20e:	6145                	addi	sp,sp,48
 210:	8082                	ret
    printf("runtest: fork error\n");
 212:	00001517          	auipc	a0,0x1
 216:	97e50513          	addi	a0,a0,-1666 # b90 <malloc+0x1a0>
 21a:	00000097          	auipc	ra,0x0
 21e:	716080e7          	jalr	1814(ra) # 930 <printf>
    exit(1);
 222:	4505                	li	a0,1
 224:	00000097          	auipc	ra,0x0
 228:	394080e7          	jalr	916(ra) # 5b8 <exit>
    f(s);
 22c:	8526                	mv	a0,s1
 22e:	9902                	jalr	s2
    exit(0);
 230:	4501                	li	a0,0
 232:	00000097          	auipc	ra,0x0
 236:	386080e7          	jalr	902(ra) # 5b8 <exit>
      printf("test %s: OK\n", s);
 23a:	85a6                	mv	a1,s1
 23c:	00001517          	auipc	a0,0x1
 240:	98450513          	addi	a0,a0,-1660 # bc0 <malloc+0x1d0>
 244:	00000097          	auipc	ra,0x0
 248:	6ec080e7          	jalr	1772(ra) # 930 <printf>
 24c:	bf4d                	j	1fe <run+0x52>

000000000000024e <main>:

int
main(int argc, char *argv[])
{
 24e:	7119                	addi	sp,sp,-128
 250:	fc86                	sd	ra,120(sp)
 252:	f8a2                	sd	s0,112(sp)
 254:	f4a6                	sd	s1,104(sp)
 256:	f0ca                	sd	s2,96(sp)
 258:	ecce                	sd	s3,88(sp)
 25a:	e8d2                	sd	s4,80(sp)
 25c:	e4d6                	sd	s5,72(sp)
 25e:	0100                	addi	s0,sp,128
  char *n = 0;
  if(argc > 1) {
 260:	4785                	li	a5,1
  char *n = 0;
 262:	4981                	li	s3,0
  if(argc > 1) {
 264:	00a7d463          	ble	a0,a5,26c <main+0x1e>
    n = argv[1];
 268:	0085b983          	ld	s3,8(a1)
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
 26c:	00001797          	auipc	a5,0x1
 270:	86c78793          	addi	a5,a5,-1940 # ad8 <malloc+0xe8>
 274:	0007b883          	ld	a7,0(a5)
 278:	0087b803          	ld	a6,8(a5)
 27c:	6b88                	ld	a0,16(a5)
 27e:	6f8c                	ld	a1,24(a5)
 280:	7390                	ld	a2,32(a5)
 282:	7794                	ld	a3,40(a5)
 284:	7b98                	ld	a4,48(a5)
 286:	7f9c                	ld	a5,56(a5)
 288:	f9143023          	sd	a7,-128(s0)
 28c:	f9043423          	sd	a6,-120(s0)
 290:	f8a43823          	sd	a0,-112(s0)
 294:	f8b43c23          	sd	a1,-104(s0)
 298:	fac43023          	sd	a2,-96(s0)
 29c:	fad43423          	sd	a3,-88(s0)
 2a0:	fae43823          	sd	a4,-80(s0)
 2a4:	faf43c23          	sd	a5,-72(s0)
    { sparse_memory_unmap, "lazy unmap"},
    { oom, "out of memory"},
    { 0, 0},
  };
    
  printf("lazytests starting\n");
 2a8:	00001517          	auipc	a0,0x1
 2ac:	92850513          	addi	a0,a0,-1752 # bd0 <malloc+0x1e0>
 2b0:	00000097          	auipc	ra,0x0
 2b4:	680080e7          	jalr	1664(ra) # 930 <printf>

  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
 2b8:	f8843903          	ld	s2,-120(s0)
 2bc:	04090963          	beqz	s2,30e <main+0xc0>
 2c0:	f8040493          	addi	s1,s0,-128
  int fail = 0;
 2c4:	4a01                	li	s4,0
    if((n == 0) || strcmp(t->s, n) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
 2c6:	4a85                	li	s5,1
 2c8:	a031                	j	2d4 <main+0x86>
  for (struct test *t = tests; t->s != 0; t++) {
 2ca:	04c1                	addi	s1,s1,16
 2cc:	0084b903          	ld	s2,8(s1) # 40001008 <__global_pointer$+0x3ffffba0>
 2d0:	02090463          	beqz	s2,2f8 <main+0xaa>
    if((n == 0) || strcmp(t->s, n) == 0) {
 2d4:	00098963          	beqz	s3,2e6 <main+0x98>
 2d8:	85ce                	mv	a1,s3
 2da:	854a                	mv	a0,s2
 2dc:	00000097          	auipc	ra,0x0
 2e0:	068080e7          	jalr	104(ra) # 344 <strcmp>
 2e4:	f17d                	bnez	a0,2ca <main+0x7c>
      if(!run(t->f, t->s))
 2e6:	85ca                	mv	a1,s2
 2e8:	6088                	ld	a0,0(s1)
 2ea:	00000097          	auipc	ra,0x0
 2ee:	ec2080e7          	jalr	-318(ra) # 1ac <run>
 2f2:	fd61                	bnez	a0,2ca <main+0x7c>
        fail = 1;
 2f4:	8a56                	mv	s4,s5
 2f6:	bfd1                	j	2ca <main+0x7c>
    }
  }
  if(!fail)
 2f8:	000a0b63          	beqz	s4,30e <main+0xc0>
    printf("ALL TESTS PASSED\n");
  else
    printf("SOME TESTS FAILED\n");
 2fc:	00001517          	auipc	a0,0x1
 300:	90450513          	addi	a0,a0,-1788 # c00 <malloc+0x210>
 304:	00000097          	auipc	ra,0x0
 308:	62c080e7          	jalr	1580(ra) # 930 <printf>
 30c:	a809                	j	31e <main+0xd0>
    printf("ALL TESTS PASSED\n");
 30e:	00001517          	auipc	a0,0x1
 312:	8da50513          	addi	a0,a0,-1830 # be8 <malloc+0x1f8>
 316:	00000097          	auipc	ra,0x0
 31a:	61a080e7          	jalr	1562(ra) # 930 <printf>
  exit(1);   // not reached.
 31e:	4505                	li	a0,1
 320:	00000097          	auipc	ra,0x0
 324:	298080e7          	jalr	664(ra) # 5b8 <exit>

0000000000000328 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 328:	1141                	addi	sp,sp,-16
 32a:	e422                	sd	s0,8(sp)
 32c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 32e:	87aa                	mv	a5,a0
 330:	0585                	addi	a1,a1,1
 332:	0785                	addi	a5,a5,1
 334:	fff5c703          	lbu	a4,-1(a1)
 338:	fee78fa3          	sb	a4,-1(a5)
 33c:	fb75                	bnez	a4,330 <strcpy+0x8>
    ;
  return os;
}
 33e:	6422                	ld	s0,8(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret

0000000000000344 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 344:	1141                	addi	sp,sp,-16
 346:	e422                	sd	s0,8(sp)
 348:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 34a:	00054783          	lbu	a5,0(a0)
 34e:	cf91                	beqz	a5,36a <strcmp+0x26>
 350:	0005c703          	lbu	a4,0(a1)
 354:	00f71b63          	bne	a4,a5,36a <strcmp+0x26>
    p++, q++;
 358:	0505                	addi	a0,a0,1
 35a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 35c:	00054783          	lbu	a5,0(a0)
 360:	c789                	beqz	a5,36a <strcmp+0x26>
 362:	0005c703          	lbu	a4,0(a1)
 366:	fef709e3          	beq	a4,a5,358 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 36a:	0005c503          	lbu	a0,0(a1)
}
 36e:	40a7853b          	subw	a0,a5,a0
 372:	6422                	ld	s0,8(sp)
 374:	0141                	addi	sp,sp,16
 376:	8082                	ret

0000000000000378 <strlen>:

uint
strlen(const char *s)
{
 378:	1141                	addi	sp,sp,-16
 37a:	e422                	sd	s0,8(sp)
 37c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 37e:	00054783          	lbu	a5,0(a0)
 382:	cf91                	beqz	a5,39e <strlen+0x26>
 384:	0505                	addi	a0,a0,1
 386:	87aa                	mv	a5,a0
 388:	4685                	li	a3,1
 38a:	9e89                	subw	a3,a3,a0
 38c:	00f6853b          	addw	a0,a3,a5
 390:	0785                	addi	a5,a5,1
 392:	fff7c703          	lbu	a4,-1(a5)
 396:	fb7d                	bnez	a4,38c <strlen+0x14>
    ;
  return n;
}
 398:	6422                	ld	s0,8(sp)
 39a:	0141                	addi	sp,sp,16
 39c:	8082                	ret
  for(n = 0; s[n]; n++)
 39e:	4501                	li	a0,0
 3a0:	bfe5                	j	398 <strlen+0x20>

00000000000003a2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3a2:	1141                	addi	sp,sp,-16
 3a4:	e422                	sd	s0,8(sp)
 3a6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3a8:	ce09                	beqz	a2,3c2 <memset+0x20>
 3aa:	87aa                	mv	a5,a0
 3ac:	fff6071b          	addiw	a4,a2,-1
 3b0:	1702                	slli	a4,a4,0x20
 3b2:	9301                	srli	a4,a4,0x20
 3b4:	0705                	addi	a4,a4,1
 3b6:	972a                	add	a4,a4,a0
    cdst[i] = c;
 3b8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3bc:	0785                	addi	a5,a5,1
 3be:	fee79de3          	bne	a5,a4,3b8 <memset+0x16>
  }
  return dst;
}
 3c2:	6422                	ld	s0,8(sp)
 3c4:	0141                	addi	sp,sp,16
 3c6:	8082                	ret

00000000000003c8 <strchr>:

char*
strchr(const char *s, char c)
{
 3c8:	1141                	addi	sp,sp,-16
 3ca:	e422                	sd	s0,8(sp)
 3cc:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3ce:	00054783          	lbu	a5,0(a0)
 3d2:	cf91                	beqz	a5,3ee <strchr+0x26>
    if(*s == c)
 3d4:	00f58a63          	beq	a1,a5,3e8 <strchr+0x20>
  for(; *s; s++)
 3d8:	0505                	addi	a0,a0,1
 3da:	00054783          	lbu	a5,0(a0)
 3de:	c781                	beqz	a5,3e6 <strchr+0x1e>
    if(*s == c)
 3e0:	feb79ce3          	bne	a5,a1,3d8 <strchr+0x10>
 3e4:	a011                	j	3e8 <strchr+0x20>
      return (char*)s;
  return 0;
 3e6:	4501                	li	a0,0
}
 3e8:	6422                	ld	s0,8(sp)
 3ea:	0141                	addi	sp,sp,16
 3ec:	8082                	ret
  return 0;
 3ee:	4501                	li	a0,0
 3f0:	bfe5                	j	3e8 <strchr+0x20>

00000000000003f2 <gets>:

char*
gets(char *buf, int max)
{
 3f2:	711d                	addi	sp,sp,-96
 3f4:	ec86                	sd	ra,88(sp)
 3f6:	e8a2                	sd	s0,80(sp)
 3f8:	e4a6                	sd	s1,72(sp)
 3fa:	e0ca                	sd	s2,64(sp)
 3fc:	fc4e                	sd	s3,56(sp)
 3fe:	f852                	sd	s4,48(sp)
 400:	f456                	sd	s5,40(sp)
 402:	f05a                	sd	s6,32(sp)
 404:	ec5e                	sd	s7,24(sp)
 406:	1080                	addi	s0,sp,96
 408:	8baa                	mv	s7,a0
 40a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 40c:	892a                	mv	s2,a0
 40e:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 410:	4aa9                	li	s5,10
 412:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 414:	0019849b          	addiw	s1,s3,1
 418:	0344d863          	ble	s4,s1,448 <gets+0x56>
    cc = read(0, &c, 1);
 41c:	4605                	li	a2,1
 41e:	faf40593          	addi	a1,s0,-81
 422:	4501                	li	a0,0
 424:	00000097          	auipc	ra,0x0
 428:	1ac080e7          	jalr	428(ra) # 5d0 <read>
    if(cc < 1)
 42c:	00a05e63          	blez	a0,448 <gets+0x56>
    buf[i++] = c;
 430:	faf44783          	lbu	a5,-81(s0)
 434:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 438:	01578763          	beq	a5,s5,446 <gets+0x54>
 43c:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 43e:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 440:	fd679ae3          	bne	a5,s6,414 <gets+0x22>
 444:	a011                	j	448 <gets+0x56>
  for(i=0; i+1 < max; ){
 446:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 448:	99de                	add	s3,s3,s7
 44a:	00098023          	sb	zero,0(s3) # 1000000 <__global_pointer$+0xffeb98>
  return buf;
}
 44e:	855e                	mv	a0,s7
 450:	60e6                	ld	ra,88(sp)
 452:	6446                	ld	s0,80(sp)
 454:	64a6                	ld	s1,72(sp)
 456:	6906                	ld	s2,64(sp)
 458:	79e2                	ld	s3,56(sp)
 45a:	7a42                	ld	s4,48(sp)
 45c:	7aa2                	ld	s5,40(sp)
 45e:	7b02                	ld	s6,32(sp)
 460:	6be2                	ld	s7,24(sp)
 462:	6125                	addi	sp,sp,96
 464:	8082                	ret

0000000000000466 <stat>:

int
stat(const char *n, struct stat *st)
{
 466:	1101                	addi	sp,sp,-32
 468:	ec06                	sd	ra,24(sp)
 46a:	e822                	sd	s0,16(sp)
 46c:	e426                	sd	s1,8(sp)
 46e:	e04a                	sd	s2,0(sp)
 470:	1000                	addi	s0,sp,32
 472:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 474:	4581                	li	a1,0
 476:	00000097          	auipc	ra,0x0
 47a:	182080e7          	jalr	386(ra) # 5f8 <open>
  if(fd < 0)
 47e:	02054563          	bltz	a0,4a8 <stat+0x42>
 482:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 484:	85ca                	mv	a1,s2
 486:	00000097          	auipc	ra,0x0
 48a:	18a080e7          	jalr	394(ra) # 610 <fstat>
 48e:	892a                	mv	s2,a0
  close(fd);
 490:	8526                	mv	a0,s1
 492:	00000097          	auipc	ra,0x0
 496:	14e080e7          	jalr	334(ra) # 5e0 <close>
  return r;
}
 49a:	854a                	mv	a0,s2
 49c:	60e2                	ld	ra,24(sp)
 49e:	6442                	ld	s0,16(sp)
 4a0:	64a2                	ld	s1,8(sp)
 4a2:	6902                	ld	s2,0(sp)
 4a4:	6105                	addi	sp,sp,32
 4a6:	8082                	ret
    return -1;
 4a8:	597d                	li	s2,-1
 4aa:	bfc5                	j	49a <stat+0x34>

00000000000004ac <atoi>:

int
atoi(const char *s)
{
 4ac:	1141                	addi	sp,sp,-16
 4ae:	e422                	sd	s0,8(sp)
 4b0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4b2:	00054683          	lbu	a3,0(a0)
 4b6:	fd06879b          	addiw	a5,a3,-48
 4ba:	0ff7f793          	andi	a5,a5,255
 4be:	4725                	li	a4,9
 4c0:	02f76963          	bltu	a4,a5,4f2 <atoi+0x46>
 4c4:	862a                	mv	a2,a0
  n = 0;
 4c6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4c8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4ca:	0605                	addi	a2,a2,1
 4cc:	0025179b          	slliw	a5,a0,0x2
 4d0:	9fa9                	addw	a5,a5,a0
 4d2:	0017979b          	slliw	a5,a5,0x1
 4d6:	9fb5                	addw	a5,a5,a3
 4d8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4dc:	00064683          	lbu	a3,0(a2) # 1000 <_end+0x380>
 4e0:	fd06871b          	addiw	a4,a3,-48
 4e4:	0ff77713          	andi	a4,a4,255
 4e8:	fee5f1e3          	bleu	a4,a1,4ca <atoi+0x1e>
  return n;
}
 4ec:	6422                	ld	s0,8(sp)
 4ee:	0141                	addi	sp,sp,16
 4f0:	8082                	ret
  n = 0;
 4f2:	4501                	li	a0,0
 4f4:	bfe5                	j	4ec <atoi+0x40>

00000000000004f6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4f6:	1141                	addi	sp,sp,-16
 4f8:	e422                	sd	s0,8(sp)
 4fa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4fc:	02b57663          	bleu	a1,a0,528 <memmove+0x32>
    while(n-- > 0)
 500:	02c05163          	blez	a2,522 <memmove+0x2c>
 504:	fff6079b          	addiw	a5,a2,-1
 508:	1782                	slli	a5,a5,0x20
 50a:	9381                	srli	a5,a5,0x20
 50c:	0785                	addi	a5,a5,1
 50e:	97aa                	add	a5,a5,a0
  dst = vdst;
 510:	872a                	mv	a4,a0
      *dst++ = *src++;
 512:	0585                	addi	a1,a1,1
 514:	0705                	addi	a4,a4,1
 516:	fff5c683          	lbu	a3,-1(a1)
 51a:	fed70fa3          	sb	a3,-1(a4) # ffffff <__global_pointer$+0xffeb97>
    while(n-- > 0)
 51e:	fee79ae3          	bne	a5,a4,512 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 522:	6422                	ld	s0,8(sp)
 524:	0141                	addi	sp,sp,16
 526:	8082                	ret
    dst += n;
 528:	00c50733          	add	a4,a0,a2
    src += n;
 52c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 52e:	fec05ae3          	blez	a2,522 <memmove+0x2c>
 532:	fff6079b          	addiw	a5,a2,-1
 536:	1782                	slli	a5,a5,0x20
 538:	9381                	srli	a5,a5,0x20
 53a:	fff7c793          	not	a5,a5
 53e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 540:	15fd                	addi	a1,a1,-1
 542:	177d                	addi	a4,a4,-1
 544:	0005c683          	lbu	a3,0(a1)
 548:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 54c:	fef71ae3          	bne	a4,a5,540 <memmove+0x4a>
 550:	bfc9                	j	522 <memmove+0x2c>

0000000000000552 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 552:	1141                	addi	sp,sp,-16
 554:	e422                	sd	s0,8(sp)
 556:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 558:	ce15                	beqz	a2,594 <memcmp+0x42>
 55a:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 55e:	00054783          	lbu	a5,0(a0)
 562:	0005c703          	lbu	a4,0(a1)
 566:	02e79063          	bne	a5,a4,586 <memcmp+0x34>
 56a:	1682                	slli	a3,a3,0x20
 56c:	9281                	srli	a3,a3,0x20
 56e:	0685                	addi	a3,a3,1
 570:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 572:	0505                	addi	a0,a0,1
    p2++;
 574:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 576:	00d50d63          	beq	a0,a3,590 <memcmp+0x3e>
    if (*p1 != *p2) {
 57a:	00054783          	lbu	a5,0(a0)
 57e:	0005c703          	lbu	a4,0(a1)
 582:	fee788e3          	beq	a5,a4,572 <memcmp+0x20>
      return *p1 - *p2;
 586:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 58a:	6422                	ld	s0,8(sp)
 58c:	0141                	addi	sp,sp,16
 58e:	8082                	ret
  return 0;
 590:	4501                	li	a0,0
 592:	bfe5                	j	58a <memcmp+0x38>
 594:	4501                	li	a0,0
 596:	bfd5                	j	58a <memcmp+0x38>

0000000000000598 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 598:	1141                	addi	sp,sp,-16
 59a:	e406                	sd	ra,8(sp)
 59c:	e022                	sd	s0,0(sp)
 59e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 5a0:	00000097          	auipc	ra,0x0
 5a4:	f56080e7          	jalr	-170(ra) # 4f6 <memmove>
}
 5a8:	60a2                	ld	ra,8(sp)
 5aa:	6402                	ld	s0,0(sp)
 5ac:	0141                	addi	sp,sp,16
 5ae:	8082                	ret

00000000000005b0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5b0:	4885                	li	a7,1
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 5b8:	4889                	li	a7,2
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5c0:	488d                	li	a7,3
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5c8:	4891                	li	a7,4
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <read>:
.global read
read:
 li a7, SYS_read
 5d0:	4895                	li	a7,5
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <write>:
.global write
write:
 li a7, SYS_write
 5d8:	48c1                	li	a7,16
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <close>:
.global close
close:
 li a7, SYS_close
 5e0:	48d5                	li	a7,21
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5e8:	4899                	li	a7,6
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5f0:	489d                	li	a7,7
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <open>:
.global open
open:
 li a7, SYS_open
 5f8:	48bd                	li	a7,15
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 600:	48c5                	li	a7,17
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 608:	48c9                	li	a7,18
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 610:	48a1                	li	a7,8
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <link>:
.global link
link:
 li a7, SYS_link
 618:	48cd                	li	a7,19
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 620:	48d1                	li	a7,20
 ecall
 622:	00000073          	ecall
 ret
 626:	8082                	ret

0000000000000628 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 628:	48a5                	li	a7,9
 ecall
 62a:	00000073          	ecall
 ret
 62e:	8082                	ret

0000000000000630 <dup>:
.global dup
dup:
 li a7, SYS_dup
 630:	48a9                	li	a7,10
 ecall
 632:	00000073          	ecall
 ret
 636:	8082                	ret

0000000000000638 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 638:	48ad                	li	a7,11
 ecall
 63a:	00000073          	ecall
 ret
 63e:	8082                	ret

0000000000000640 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 640:	48b1                	li	a7,12
 ecall
 642:	00000073          	ecall
 ret
 646:	8082                	ret

0000000000000648 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 648:	48b5                	li	a7,13
 ecall
 64a:	00000073          	ecall
 ret
 64e:	8082                	ret

0000000000000650 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 650:	48b9                	li	a7,14
 ecall
 652:	00000073          	ecall
 ret
 656:	8082                	ret

0000000000000658 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 658:	1101                	addi	sp,sp,-32
 65a:	ec06                	sd	ra,24(sp)
 65c:	e822                	sd	s0,16(sp)
 65e:	1000                	addi	s0,sp,32
 660:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 664:	4605                	li	a2,1
 666:	fef40593          	addi	a1,s0,-17
 66a:	00000097          	auipc	ra,0x0
 66e:	f6e080e7          	jalr	-146(ra) # 5d8 <write>
}
 672:	60e2                	ld	ra,24(sp)
 674:	6442                	ld	s0,16(sp)
 676:	6105                	addi	sp,sp,32
 678:	8082                	ret

000000000000067a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 67a:	7139                	addi	sp,sp,-64
 67c:	fc06                	sd	ra,56(sp)
 67e:	f822                	sd	s0,48(sp)
 680:	f426                	sd	s1,40(sp)
 682:	f04a                	sd	s2,32(sp)
 684:	ec4e                	sd	s3,24(sp)
 686:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 688:	c299                	beqz	a3,68e <printint+0x14>
 68a:	0005cd63          	bltz	a1,6a4 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 68e:	2581                	sext.w	a1,a1
  neg = 0;
 690:	4301                	li	t1,0
 692:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 696:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 698:	2601                	sext.w	a2,a2
 69a:	00000897          	auipc	a7,0x0
 69e:	5ae88893          	addi	a7,a7,1454 # c48 <digits>
 6a2:	a801                	j	6b2 <printint+0x38>
    x = -xx;
 6a4:	40b005bb          	negw	a1,a1
 6a8:	2581                	sext.w	a1,a1
    neg = 1;
 6aa:	4305                	li	t1,1
    x = -xx;
 6ac:	b7dd                	j	692 <printint+0x18>
  }while((x /= base) != 0);
 6ae:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 6b0:	8836                	mv	a6,a3
 6b2:	0018069b          	addiw	a3,a6,1
 6b6:	02c5f7bb          	remuw	a5,a1,a2
 6ba:	1782                	slli	a5,a5,0x20
 6bc:	9381                	srli	a5,a5,0x20
 6be:	97c6                	add	a5,a5,a7
 6c0:	0007c783          	lbu	a5,0(a5)
 6c4:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 6c8:	0705                	addi	a4,a4,1
 6ca:	02c5d7bb          	divuw	a5,a1,a2
 6ce:	fec5f0e3          	bleu	a2,a1,6ae <printint+0x34>
  if(neg)
 6d2:	00030b63          	beqz	t1,6e8 <printint+0x6e>
    buf[i++] = '-';
 6d6:	fd040793          	addi	a5,s0,-48
 6da:	96be                	add	a3,a3,a5
 6dc:	02d00793          	li	a5,45
 6e0:	fef68823          	sb	a5,-16(a3) # 3fff0 <__global_pointer$+0x3eb88>
 6e4:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 6e8:	02d05963          	blez	a3,71a <printint+0xa0>
 6ec:	89aa                	mv	s3,a0
 6ee:	fc040793          	addi	a5,s0,-64
 6f2:	00d784b3          	add	s1,a5,a3
 6f6:	fff78913          	addi	s2,a5,-1
 6fa:	9936                	add	s2,s2,a3
 6fc:	36fd                	addiw	a3,a3,-1
 6fe:	1682                	slli	a3,a3,0x20
 700:	9281                	srli	a3,a3,0x20
 702:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 706:	fff4c583          	lbu	a1,-1(s1)
 70a:	854e                	mv	a0,s3
 70c:	00000097          	auipc	ra,0x0
 710:	f4c080e7          	jalr	-180(ra) # 658 <putc>
  while(--i >= 0)
 714:	14fd                	addi	s1,s1,-1
 716:	ff2498e3          	bne	s1,s2,706 <printint+0x8c>
}
 71a:	70e2                	ld	ra,56(sp)
 71c:	7442                	ld	s0,48(sp)
 71e:	74a2                	ld	s1,40(sp)
 720:	7902                	ld	s2,32(sp)
 722:	69e2                	ld	s3,24(sp)
 724:	6121                	addi	sp,sp,64
 726:	8082                	ret

0000000000000728 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 728:	7119                	addi	sp,sp,-128
 72a:	fc86                	sd	ra,120(sp)
 72c:	f8a2                	sd	s0,112(sp)
 72e:	f4a6                	sd	s1,104(sp)
 730:	f0ca                	sd	s2,96(sp)
 732:	ecce                	sd	s3,88(sp)
 734:	e8d2                	sd	s4,80(sp)
 736:	e4d6                	sd	s5,72(sp)
 738:	e0da                	sd	s6,64(sp)
 73a:	fc5e                	sd	s7,56(sp)
 73c:	f862                	sd	s8,48(sp)
 73e:	f466                	sd	s9,40(sp)
 740:	f06a                	sd	s10,32(sp)
 742:	ec6e                	sd	s11,24(sp)
 744:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 746:	0005c483          	lbu	s1,0(a1)
 74a:	18048d63          	beqz	s1,8e4 <vprintf+0x1bc>
 74e:	8aaa                	mv	s5,a0
 750:	8b32                	mv	s6,a2
 752:	00158913          	addi	s2,a1,1
  state = 0;
 756:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 758:	02500a13          	li	s4,37
      if(c == 'd'){
 75c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 760:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 764:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 768:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 76c:	00000b97          	auipc	s7,0x0
 770:	4dcb8b93          	addi	s7,s7,1244 # c48 <digits>
 774:	a839                	j	792 <vprintf+0x6a>
        putc(fd, c);
 776:	85a6                	mv	a1,s1
 778:	8556                	mv	a0,s5
 77a:	00000097          	auipc	ra,0x0
 77e:	ede080e7          	jalr	-290(ra) # 658 <putc>
 782:	a019                	j	788 <vprintf+0x60>
    } else if(state == '%'){
 784:	01498f63          	beq	s3,s4,7a2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 788:	0905                	addi	s2,s2,1
 78a:	fff94483          	lbu	s1,-1(s2)
 78e:	14048b63          	beqz	s1,8e4 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 792:	0004879b          	sext.w	a5,s1
    if(state == 0){
 796:	fe0997e3          	bnez	s3,784 <vprintf+0x5c>
      if(c == '%'){
 79a:	fd479ee3          	bne	a5,s4,776 <vprintf+0x4e>
        state = '%';
 79e:	89be                	mv	s3,a5
 7a0:	b7e5                	j	788 <vprintf+0x60>
      if(c == 'd'){
 7a2:	05878063          	beq	a5,s8,7e2 <vprintf+0xba>
      } else if(c == 'l') {
 7a6:	05978c63          	beq	a5,s9,7fe <vprintf+0xd6>
      } else if(c == 'x') {
 7aa:	07a78863          	beq	a5,s10,81a <vprintf+0xf2>
      } else if(c == 'p') {
 7ae:	09b78463          	beq	a5,s11,836 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 7b2:	07300713          	li	a4,115
 7b6:	0ce78563          	beq	a5,a4,880 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7ba:	06300713          	li	a4,99
 7be:	0ee78c63          	beq	a5,a4,8b6 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7c2:	11478663          	beq	a5,s4,8ce <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7c6:	85d2                	mv	a1,s4
 7c8:	8556                	mv	a0,s5
 7ca:	00000097          	auipc	ra,0x0
 7ce:	e8e080e7          	jalr	-370(ra) # 658 <putc>
        putc(fd, c);
 7d2:	85a6                	mv	a1,s1
 7d4:	8556                	mv	a0,s5
 7d6:	00000097          	auipc	ra,0x0
 7da:	e82080e7          	jalr	-382(ra) # 658 <putc>
      }
      state = 0;
 7de:	4981                	li	s3,0
 7e0:	b765                	j	788 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7e2:	008b0493          	addi	s1,s6,8
 7e6:	4685                	li	a3,1
 7e8:	4629                	li	a2,10
 7ea:	000b2583          	lw	a1,0(s6)
 7ee:	8556                	mv	a0,s5
 7f0:	00000097          	auipc	ra,0x0
 7f4:	e8a080e7          	jalr	-374(ra) # 67a <printint>
 7f8:	8b26                	mv	s6,s1
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	b771                	j	788 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7fe:	008b0493          	addi	s1,s6,8
 802:	4681                	li	a3,0
 804:	4629                	li	a2,10
 806:	000b2583          	lw	a1,0(s6)
 80a:	8556                	mv	a0,s5
 80c:	00000097          	auipc	ra,0x0
 810:	e6e080e7          	jalr	-402(ra) # 67a <printint>
 814:	8b26                	mv	s6,s1
      state = 0;
 816:	4981                	li	s3,0
 818:	bf85                	j	788 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 81a:	008b0493          	addi	s1,s6,8
 81e:	4681                	li	a3,0
 820:	4641                	li	a2,16
 822:	000b2583          	lw	a1,0(s6)
 826:	8556                	mv	a0,s5
 828:	00000097          	auipc	ra,0x0
 82c:	e52080e7          	jalr	-430(ra) # 67a <printint>
 830:	8b26                	mv	s6,s1
      state = 0;
 832:	4981                	li	s3,0
 834:	bf91                	j	788 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 836:	008b0793          	addi	a5,s6,8
 83a:	f8f43423          	sd	a5,-120(s0)
 83e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 842:	03000593          	li	a1,48
 846:	8556                	mv	a0,s5
 848:	00000097          	auipc	ra,0x0
 84c:	e10080e7          	jalr	-496(ra) # 658 <putc>
  putc(fd, 'x');
 850:	85ea                	mv	a1,s10
 852:	8556                	mv	a0,s5
 854:	00000097          	auipc	ra,0x0
 858:	e04080e7          	jalr	-508(ra) # 658 <putc>
 85c:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 85e:	03c9d793          	srli	a5,s3,0x3c
 862:	97de                	add	a5,a5,s7
 864:	0007c583          	lbu	a1,0(a5)
 868:	8556                	mv	a0,s5
 86a:	00000097          	auipc	ra,0x0
 86e:	dee080e7          	jalr	-530(ra) # 658 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 872:	0992                	slli	s3,s3,0x4
 874:	34fd                	addiw	s1,s1,-1
 876:	f4e5                	bnez	s1,85e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 878:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 87c:	4981                	li	s3,0
 87e:	b729                	j	788 <vprintf+0x60>
        s = va_arg(ap, char*);
 880:	008b0993          	addi	s3,s6,8
 884:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 888:	c085                	beqz	s1,8a8 <vprintf+0x180>
        while(*s != 0){
 88a:	0004c583          	lbu	a1,0(s1)
 88e:	c9a1                	beqz	a1,8de <vprintf+0x1b6>
          putc(fd, *s);
 890:	8556                	mv	a0,s5
 892:	00000097          	auipc	ra,0x0
 896:	dc6080e7          	jalr	-570(ra) # 658 <putc>
          s++;
 89a:	0485                	addi	s1,s1,1
        while(*s != 0){
 89c:	0004c583          	lbu	a1,0(s1)
 8a0:	f9e5                	bnez	a1,890 <vprintf+0x168>
        s = va_arg(ap, char*);
 8a2:	8b4e                	mv	s6,s3
      state = 0;
 8a4:	4981                	li	s3,0
 8a6:	b5cd                	j	788 <vprintf+0x60>
          s = "(null)";
 8a8:	00000497          	auipc	s1,0x0
 8ac:	3b848493          	addi	s1,s1,952 # c60 <digits+0x18>
        while(*s != 0){
 8b0:	02800593          	li	a1,40
 8b4:	bff1                	j	890 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 8b6:	008b0493          	addi	s1,s6,8
 8ba:	000b4583          	lbu	a1,0(s6)
 8be:	8556                	mv	a0,s5
 8c0:	00000097          	auipc	ra,0x0
 8c4:	d98080e7          	jalr	-616(ra) # 658 <putc>
 8c8:	8b26                	mv	s6,s1
      state = 0;
 8ca:	4981                	li	s3,0
 8cc:	bd75                	j	788 <vprintf+0x60>
        putc(fd, c);
 8ce:	85d2                	mv	a1,s4
 8d0:	8556                	mv	a0,s5
 8d2:	00000097          	auipc	ra,0x0
 8d6:	d86080e7          	jalr	-634(ra) # 658 <putc>
      state = 0;
 8da:	4981                	li	s3,0
 8dc:	b575                	j	788 <vprintf+0x60>
        s = va_arg(ap, char*);
 8de:	8b4e                	mv	s6,s3
      state = 0;
 8e0:	4981                	li	s3,0
 8e2:	b55d                	j	788 <vprintf+0x60>
    }
  }
}
 8e4:	70e6                	ld	ra,120(sp)
 8e6:	7446                	ld	s0,112(sp)
 8e8:	74a6                	ld	s1,104(sp)
 8ea:	7906                	ld	s2,96(sp)
 8ec:	69e6                	ld	s3,88(sp)
 8ee:	6a46                	ld	s4,80(sp)
 8f0:	6aa6                	ld	s5,72(sp)
 8f2:	6b06                	ld	s6,64(sp)
 8f4:	7be2                	ld	s7,56(sp)
 8f6:	7c42                	ld	s8,48(sp)
 8f8:	7ca2                	ld	s9,40(sp)
 8fa:	7d02                	ld	s10,32(sp)
 8fc:	6de2                	ld	s11,24(sp)
 8fe:	6109                	addi	sp,sp,128
 900:	8082                	ret

0000000000000902 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 902:	715d                	addi	sp,sp,-80
 904:	ec06                	sd	ra,24(sp)
 906:	e822                	sd	s0,16(sp)
 908:	1000                	addi	s0,sp,32
 90a:	e010                	sd	a2,0(s0)
 90c:	e414                	sd	a3,8(s0)
 90e:	e818                	sd	a4,16(s0)
 910:	ec1c                	sd	a5,24(s0)
 912:	03043023          	sd	a6,32(s0)
 916:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 91a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 91e:	8622                	mv	a2,s0
 920:	00000097          	auipc	ra,0x0
 924:	e08080e7          	jalr	-504(ra) # 728 <vprintf>
}
 928:	60e2                	ld	ra,24(sp)
 92a:	6442                	ld	s0,16(sp)
 92c:	6161                	addi	sp,sp,80
 92e:	8082                	ret

0000000000000930 <printf>:

void
printf(const char *fmt, ...)
{
 930:	711d                	addi	sp,sp,-96
 932:	ec06                	sd	ra,24(sp)
 934:	e822                	sd	s0,16(sp)
 936:	1000                	addi	s0,sp,32
 938:	e40c                	sd	a1,8(s0)
 93a:	e810                	sd	a2,16(s0)
 93c:	ec14                	sd	a3,24(s0)
 93e:	f018                	sd	a4,32(s0)
 940:	f41c                	sd	a5,40(s0)
 942:	03043823          	sd	a6,48(s0)
 946:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 94a:	00840613          	addi	a2,s0,8
 94e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 952:	85aa                	mv	a1,a0
 954:	4505                	li	a0,1
 956:	00000097          	auipc	ra,0x0
 95a:	dd2080e7          	jalr	-558(ra) # 728 <vprintf>
}
 95e:	60e2                	ld	ra,24(sp)
 960:	6442                	ld	s0,16(sp)
 962:	6125                	addi	sp,sp,96
 964:	8082                	ret

0000000000000966 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 966:	1141                	addi	sp,sp,-16
 968:	e422                	sd	s0,8(sp)
 96a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 96c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 970:	00000797          	auipc	a5,0x0
 974:	2f878793          	addi	a5,a5,760 # c68 <__bss_start>
 978:	639c                	ld	a5,0(a5)
 97a:	a805                	j	9aa <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 97c:	4618                	lw	a4,8(a2)
 97e:	9db9                	addw	a1,a1,a4
 980:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 984:	6398                	ld	a4,0(a5)
 986:	6318                	ld	a4,0(a4)
 988:	fee53823          	sd	a4,-16(a0)
 98c:	a091                	j	9d0 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 98e:	ff852703          	lw	a4,-8(a0)
 992:	9e39                	addw	a2,a2,a4
 994:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 996:	ff053703          	ld	a4,-16(a0)
 99a:	e398                	sd	a4,0(a5)
 99c:	a099                	j	9e2 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 99e:	6398                	ld	a4,0(a5)
 9a0:	00e7e463          	bltu	a5,a4,9a8 <free+0x42>
 9a4:	00e6ea63          	bltu	a3,a4,9b8 <free+0x52>
{
 9a8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9aa:	fed7fae3          	bleu	a3,a5,99e <free+0x38>
 9ae:	6398                	ld	a4,0(a5)
 9b0:	00e6e463          	bltu	a3,a4,9b8 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9b4:	fee7eae3          	bltu	a5,a4,9a8 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 9b8:	ff852583          	lw	a1,-8(a0)
 9bc:	6390                	ld	a2,0(a5)
 9be:	02059713          	slli	a4,a1,0x20
 9c2:	9301                	srli	a4,a4,0x20
 9c4:	0712                	slli	a4,a4,0x4
 9c6:	9736                	add	a4,a4,a3
 9c8:	fae60ae3          	beq	a2,a4,97c <free+0x16>
    bp->s.ptr = p->s.ptr;
 9cc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9d0:	4790                	lw	a2,8(a5)
 9d2:	02061713          	slli	a4,a2,0x20
 9d6:	9301                	srli	a4,a4,0x20
 9d8:	0712                	slli	a4,a4,0x4
 9da:	973e                	add	a4,a4,a5
 9dc:	fae689e3          	beq	a3,a4,98e <free+0x28>
  } else
    p->s.ptr = bp;
 9e0:	e394                	sd	a3,0(a5)
  freep = p;
 9e2:	00000717          	auipc	a4,0x0
 9e6:	28f73323          	sd	a5,646(a4) # c68 <__bss_start>
}
 9ea:	6422                	ld	s0,8(sp)
 9ec:	0141                	addi	sp,sp,16
 9ee:	8082                	ret

00000000000009f0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9f0:	7139                	addi	sp,sp,-64
 9f2:	fc06                	sd	ra,56(sp)
 9f4:	f822                	sd	s0,48(sp)
 9f6:	f426                	sd	s1,40(sp)
 9f8:	f04a                	sd	s2,32(sp)
 9fa:	ec4e                	sd	s3,24(sp)
 9fc:	e852                	sd	s4,16(sp)
 9fe:	e456                	sd	s5,8(sp)
 a00:	e05a                	sd	s6,0(sp)
 a02:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a04:	02051993          	slli	s3,a0,0x20
 a08:	0209d993          	srli	s3,s3,0x20
 a0c:	09bd                	addi	s3,s3,15
 a0e:	0049d993          	srli	s3,s3,0x4
 a12:	2985                	addiw	s3,s3,1
 a14:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 a18:	00000797          	auipc	a5,0x0
 a1c:	25078793          	addi	a5,a5,592 # c68 <__bss_start>
 a20:	6388                	ld	a0,0(a5)
 a22:	c515                	beqz	a0,a4e <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a24:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a26:	4798                	lw	a4,8(a5)
 a28:	03277f63          	bleu	s2,a4,a66 <malloc+0x76>
 a2c:	8a4e                	mv	s4,s3
 a2e:	0009871b          	sext.w	a4,s3
 a32:	6685                	lui	a3,0x1
 a34:	00d77363          	bleu	a3,a4,a3a <malloc+0x4a>
 a38:	6a05                	lui	s4,0x1
 a3a:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 a3e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a42:	00000497          	auipc	s1,0x0
 a46:	22648493          	addi	s1,s1,550 # c68 <__bss_start>
  if(p == (char*)-1)
 a4a:	5b7d                	li	s6,-1
 a4c:	a885                	j	abc <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 a4e:	00000797          	auipc	a5,0x0
 a52:	22278793          	addi	a5,a5,546 # c70 <base>
 a56:	00000717          	auipc	a4,0x0
 a5a:	20f73923          	sd	a5,530(a4) # c68 <__bss_start>
 a5e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a60:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a64:	b7e1                	j	a2c <malloc+0x3c>
      if(p->s.size == nunits)
 a66:	02e90b63          	beq	s2,a4,a9c <malloc+0xac>
        p->s.size -= nunits;
 a6a:	4137073b          	subw	a4,a4,s3
 a6e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a70:	1702                	slli	a4,a4,0x20
 a72:	9301                	srli	a4,a4,0x20
 a74:	0712                	slli	a4,a4,0x4
 a76:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a78:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a7c:	00000717          	auipc	a4,0x0
 a80:	1ea73623          	sd	a0,492(a4) # c68 <__bss_start>
      return (void*)(p + 1);
 a84:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a88:	70e2                	ld	ra,56(sp)
 a8a:	7442                	ld	s0,48(sp)
 a8c:	74a2                	ld	s1,40(sp)
 a8e:	7902                	ld	s2,32(sp)
 a90:	69e2                	ld	s3,24(sp)
 a92:	6a42                	ld	s4,16(sp)
 a94:	6aa2                	ld	s5,8(sp)
 a96:	6b02                	ld	s6,0(sp)
 a98:	6121                	addi	sp,sp,64
 a9a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a9c:	6398                	ld	a4,0(a5)
 a9e:	e118                	sd	a4,0(a0)
 aa0:	bff1                	j	a7c <malloc+0x8c>
  hp->s.size = nu;
 aa2:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 aa6:	0541                	addi	a0,a0,16
 aa8:	00000097          	auipc	ra,0x0
 aac:	ebe080e7          	jalr	-322(ra) # 966 <free>
  return freep;
 ab0:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 ab2:	d979                	beqz	a0,a88 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ab4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ab6:	4798                	lw	a4,8(a5)
 ab8:	fb2777e3          	bleu	s2,a4,a66 <malloc+0x76>
    if(p == freep)
 abc:	6098                	ld	a4,0(s1)
 abe:	853e                	mv	a0,a5
 ac0:	fef71ae3          	bne	a4,a5,ab4 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 ac4:	8552                	mv	a0,s4
 ac6:	00000097          	auipc	ra,0x0
 aca:	b7a080e7          	jalr	-1158(ra) # 640 <sbrk>
  if(p == (char*)-1)
 ace:	fd651ae3          	bne	a0,s6,aa2 <malloc+0xb2>
        return 0;
 ad2:	4501                	li	a0,0
 ad4:	bf55                	j	a88 <malloc+0x98>
