
user/_sysinfotest：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <sinfo>:
#include "kernel/sysinfo.h"
#include "user/user.h"


void
sinfo(struct sysinfo *info) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if (sysinfo(info) < 0) {
   8:	00000097          	auipc	ra,0x0
   c:	672080e7          	jalr	1650(ra) # 67a <sysinfo>
  10:	00054663          	bltz	a0,1c <sinfo+0x1c>
    printf("FAIL: sysinfo failed");
    exit(1);
  }
}
  14:	60a2                	ld	ra,8(sp)
  16:	6402                	ld	s0,0(sp)
  18:	0141                	addi	sp,sp,16
  1a:	8082                	ret
    printf("FAIL: sysinfo failed");
  1c:	00001517          	auipc	a0,0x1
  20:	ae450513          	addi	a0,a0,-1308 # b00 <malloc+0xe6>
  24:	00001097          	auipc	ra,0x1
  28:	936080e7          	jalr	-1738(ra) # 95a <printf>
    exit(1);
  2c:	4505                	li	a0,1
  2e:	00000097          	auipc	ra,0x0
  32:	5a4080e7          	jalr	1444(ra) # 5d2 <exit>

0000000000000036 <countfree>:
//
// use sbrk() to count how many free physical memory pages there are.
//
int
countfree()
{
  36:	7139                	addi	sp,sp,-64
  38:	fc06                	sd	ra,56(sp)
  3a:	f822                	sd	s0,48(sp)
  3c:	f426                	sd	s1,40(sp)
  3e:	f04a                	sd	s2,32(sp)
  40:	ec4e                	sd	s3,24(sp)
  42:	e852                	sd	s4,16(sp)
  44:	0080                	addi	s0,sp,64
  uint64 sz0 = (uint64)sbrk(0);
  46:	4501                	li	a0,0
  48:	00000097          	auipc	ra,0x0
  4c:	612080e7          	jalr	1554(ra) # 65a <sbrk>
  50:	8a2a                	mv	s4,a0
  struct sysinfo info;
  int n = 0;
  52:	4481                	li	s1,0

  while(1){
    if((uint64)sbrk(PGSIZE) == 0xffffffffffffffff){
  54:	597d                	li	s2,-1
      break;
    }
    n += PGSIZE;
  56:	6985                	lui	s3,0x1
    if((uint64)sbrk(PGSIZE) == 0xffffffffffffffff){
  58:	6505                	lui	a0,0x1
  5a:	00000097          	auipc	ra,0x0
  5e:	600080e7          	jalr	1536(ra) # 65a <sbrk>
  62:	01250563          	beq	a0,s2,6c <countfree+0x36>
    n += PGSIZE;
  66:	009984bb          	addw	s1,s3,s1
    if((uint64)sbrk(PGSIZE) == 0xffffffffffffffff){
  6a:	b7fd                	j	58 <countfree+0x22>
  }
  sinfo(&info);
  6c:	fc040513          	addi	a0,s0,-64
  70:	00000097          	auipc	ra,0x0
  74:	f90080e7          	jalr	-112(ra) # 0 <sinfo>
  if (info.freemem != 0) {
  78:	fc043583          	ld	a1,-64(s0)
  7c:	e58d                	bnez	a1,a6 <countfree+0x70>
    printf("FAIL: there is no free mem, but sysinfo.freemem=%d\n",
      info.freemem);
    exit(1);
  }
  sbrk(-((uint64)sbrk(0) - sz0));
  7e:	4501                	li	a0,0
  80:	00000097          	auipc	ra,0x0
  84:	5da080e7          	jalr	1498(ra) # 65a <sbrk>
  88:	40aa053b          	subw	a0,s4,a0
  8c:	00000097          	auipc	ra,0x0
  90:	5ce080e7          	jalr	1486(ra) # 65a <sbrk>
  return n;
}
  94:	8526                	mv	a0,s1
  96:	70e2                	ld	ra,56(sp)
  98:	7442                	ld	s0,48(sp)
  9a:	74a2                	ld	s1,40(sp)
  9c:	7902                	ld	s2,32(sp)
  9e:	69e2                	ld	s3,24(sp)
  a0:	6a42                	ld	s4,16(sp)
  a2:	6121                	addi	sp,sp,64
  a4:	8082                	ret
    printf("FAIL: there is no free mem, but sysinfo.freemem=%d\n",
  a6:	00001517          	auipc	a0,0x1
  aa:	a7250513          	addi	a0,a0,-1422 # b18 <malloc+0xfe>
  ae:	00001097          	auipc	ra,0x1
  b2:	8ac080e7          	jalr	-1876(ra) # 95a <printf>
    exit(1);
  b6:	4505                	li	a0,1
  b8:	00000097          	auipc	ra,0x0
  bc:	51a080e7          	jalr	1306(ra) # 5d2 <exit>

00000000000000c0 <testmem>:

void
testmem() {
  c0:	7179                	addi	sp,sp,-48
  c2:	f406                	sd	ra,40(sp)
  c4:	f022                	sd	s0,32(sp)
  c6:	ec26                	sd	s1,24(sp)
  c8:	e84a                	sd	s2,16(sp)
  ca:	1800                	addi	s0,sp,48
  struct sysinfo info;
  uint64 n = countfree();
  cc:	00000097          	auipc	ra,0x0
  d0:	f6a080e7          	jalr	-150(ra) # 36 <countfree>
  d4:	84aa                	mv	s1,a0
  
  sinfo(&info);
  d6:	fd040513          	addi	a0,s0,-48
  da:	00000097          	auipc	ra,0x0
  de:	f26080e7          	jalr	-218(ra) # 0 <sinfo>

  if (info.freemem!= n) {
  e2:	fd043583          	ld	a1,-48(s0)
  e6:	04959e63          	bne	a1,s1,142 <testmem+0x82>
    printf("FAIL: free mem %d (bytes) instead of %d\n", info.freemem, n);
    exit(1);
  }
  
  if((uint64)sbrk(PGSIZE) == 0xffffffffffffffff){
  ea:	6505                	lui	a0,0x1
  ec:	00000097          	auipc	ra,0x0
  f0:	56e080e7          	jalr	1390(ra) # 65a <sbrk>
  f4:	57fd                	li	a5,-1
  f6:	06f50463          	beq	a0,a5,15e <testmem+0x9e>
    printf("sbrk failed");
    exit(1);
  }

  sinfo(&info);
  fa:	fd040513          	addi	a0,s0,-48
  fe:	00000097          	auipc	ra,0x0
 102:	f02080e7          	jalr	-254(ra) # 0 <sinfo>
    
  if (info.freemem != n-PGSIZE) {
 106:	fd043603          	ld	a2,-48(s0)
 10a:	75fd                	lui	a1,0xfffff
 10c:	95a6                	add	a1,a1,s1
 10e:	06b61563          	bne	a2,a1,178 <testmem+0xb8>
    printf("FAIL: free mem %d (bytes) instead of %d\n", n-PGSIZE, info.freemem);
    exit(1);
  }
  
  if((uint64)sbrk(-PGSIZE) == 0xffffffffffffffff){
 112:	757d                	lui	a0,0xfffff
 114:	00000097          	auipc	ra,0x0
 118:	546080e7          	jalr	1350(ra) # 65a <sbrk>
 11c:	57fd                	li	a5,-1
 11e:	06f50a63          	beq	a0,a5,192 <testmem+0xd2>
    printf("sbrk failed");
    exit(1);
  }

  sinfo(&info);
 122:	fd040513          	addi	a0,s0,-48
 126:	00000097          	auipc	ra,0x0
 12a:	eda080e7          	jalr	-294(ra) # 0 <sinfo>
    
  if (info.freemem != n) {
 12e:	fd043603          	ld	a2,-48(s0)
 132:	06961d63          	bne	a2,s1,1ac <testmem+0xec>
    printf("FAIL: free mem %d (bytes) instead of %d\n", n, info.freemem);
    exit(1);
  }
}
 136:	70a2                	ld	ra,40(sp)
 138:	7402                	ld	s0,32(sp)
 13a:	64e2                	ld	s1,24(sp)
 13c:	6942                	ld	s2,16(sp)
 13e:	6145                	addi	sp,sp,48
 140:	8082                	ret
    printf("FAIL: free mem %d (bytes) instead of %d\n", info.freemem, n);
 142:	8626                	mv	a2,s1
 144:	00001517          	auipc	a0,0x1
 148:	a0c50513          	addi	a0,a0,-1524 # b50 <malloc+0x136>
 14c:	00001097          	auipc	ra,0x1
 150:	80e080e7          	jalr	-2034(ra) # 95a <printf>
    exit(1);
 154:	4505                	li	a0,1
 156:	00000097          	auipc	ra,0x0
 15a:	47c080e7          	jalr	1148(ra) # 5d2 <exit>
    printf("sbrk failed");
 15e:	00001517          	auipc	a0,0x1
 162:	a2250513          	addi	a0,a0,-1502 # b80 <malloc+0x166>
 166:	00000097          	auipc	ra,0x0
 16a:	7f4080e7          	jalr	2036(ra) # 95a <printf>
    exit(1);
 16e:	4505                	li	a0,1
 170:	00000097          	auipc	ra,0x0
 174:	462080e7          	jalr	1122(ra) # 5d2 <exit>
    printf("FAIL: free mem %d (bytes) instead of %d\n", n-PGSIZE, info.freemem);
 178:	00001517          	auipc	a0,0x1
 17c:	9d850513          	addi	a0,a0,-1576 # b50 <malloc+0x136>
 180:	00000097          	auipc	ra,0x0
 184:	7da080e7          	jalr	2010(ra) # 95a <printf>
    exit(1);
 188:	4505                	li	a0,1
 18a:	00000097          	auipc	ra,0x0
 18e:	448080e7          	jalr	1096(ra) # 5d2 <exit>
    printf("sbrk failed");
 192:	00001517          	auipc	a0,0x1
 196:	9ee50513          	addi	a0,a0,-1554 # b80 <malloc+0x166>
 19a:	00000097          	auipc	ra,0x0
 19e:	7c0080e7          	jalr	1984(ra) # 95a <printf>
    exit(1);
 1a2:	4505                	li	a0,1
 1a4:	00000097          	auipc	ra,0x0
 1a8:	42e080e7          	jalr	1070(ra) # 5d2 <exit>
    printf("FAIL: free mem %d (bytes) instead of %d\n", n, info.freemem);
 1ac:	85a6                	mv	a1,s1
 1ae:	00001517          	auipc	a0,0x1
 1b2:	9a250513          	addi	a0,a0,-1630 # b50 <malloc+0x136>
 1b6:	00000097          	auipc	ra,0x0
 1ba:	7a4080e7          	jalr	1956(ra) # 95a <printf>
    exit(1);
 1be:	4505                	li	a0,1
 1c0:	00000097          	auipc	ra,0x0
 1c4:	412080e7          	jalr	1042(ra) # 5d2 <exit>

00000000000001c8 <testcall>:

void
testcall() {
 1c8:	1101                	addi	sp,sp,-32
 1ca:	ec06                	sd	ra,24(sp)
 1cc:	e822                	sd	s0,16(sp)
 1ce:	1000                	addi	s0,sp,32
  struct sysinfo info;
  
  if (sysinfo(&info) < 0) {
 1d0:	fe040513          	addi	a0,s0,-32
 1d4:	00000097          	auipc	ra,0x0
 1d8:	4a6080e7          	jalr	1190(ra) # 67a <sysinfo>
 1dc:	02054263          	bltz	a0,200 <testcall+0x38>
    printf("FAIL: sysinfo failed\n");
    exit(1);
  }

  if (sysinfo((struct sysinfo *) 0xeaeb0b5b00002f5e) !=  0xffffffffffffffff) {
 1e0:	00001797          	auipc	a5,0x1
 1e4:	a9878793          	addi	a5,a5,-1384 # c78 <digits+0x20>
 1e8:	6388                	ld	a0,0(a5)
 1ea:	00000097          	auipc	ra,0x0
 1ee:	490080e7          	jalr	1168(ra) # 67a <sysinfo>
 1f2:	57fd                	li	a5,-1
 1f4:	02f51363          	bne	a0,a5,21a <testcall+0x52>
    printf("FAIL: sysinfo succeeded with bad argument\n");
    exit(1);
  }
}
 1f8:	60e2                	ld	ra,24(sp)
 1fa:	6442                	ld	s0,16(sp)
 1fc:	6105                	addi	sp,sp,32
 1fe:	8082                	ret
    printf("FAIL: sysinfo failed\n");
 200:	00001517          	auipc	a0,0x1
 204:	99050513          	addi	a0,a0,-1648 # b90 <malloc+0x176>
 208:	00000097          	auipc	ra,0x0
 20c:	752080e7          	jalr	1874(ra) # 95a <printf>
    exit(1);
 210:	4505                	li	a0,1
 212:	00000097          	auipc	ra,0x0
 216:	3c0080e7          	jalr	960(ra) # 5d2 <exit>
    printf("FAIL: sysinfo succeeded with bad argument\n");
 21a:	00001517          	auipc	a0,0x1
 21e:	98e50513          	addi	a0,a0,-1650 # ba8 <malloc+0x18e>
 222:	00000097          	auipc	ra,0x0
 226:	738080e7          	jalr	1848(ra) # 95a <printf>
    exit(1);
 22a:	4505                	li	a0,1
 22c:	00000097          	auipc	ra,0x0
 230:	3a6080e7          	jalr	934(ra) # 5d2 <exit>

0000000000000234 <testproc>:

void testproc() {
 234:	7139                	addi	sp,sp,-64
 236:	fc06                	sd	ra,56(sp)
 238:	f822                	sd	s0,48(sp)
 23a:	f426                	sd	s1,40(sp)
 23c:	0080                	addi	s0,sp,64
  struct sysinfo info;
  uint64 nproc;
  int status;
  int pid;
  
  sinfo(&info);
 23e:	fd040513          	addi	a0,s0,-48
 242:	00000097          	auipc	ra,0x0
 246:	dbe080e7          	jalr	-578(ra) # 0 <sinfo>
  nproc = info.nproc;
 24a:	fd843483          	ld	s1,-40(s0)

  pid = fork();
 24e:	00000097          	auipc	ra,0x0
 252:	37c080e7          	jalr	892(ra) # 5ca <fork>
  if(pid < 0){
 256:	02054c63          	bltz	a0,28e <testproc+0x5a>
    printf("sysinfotest: fork failed\n");
    exit(1);
  }
  if(pid == 0){
 25a:	ed21                	bnez	a0,2b2 <testproc+0x7e>
    sinfo(&info);
 25c:	fd040513          	addi	a0,s0,-48
 260:	00000097          	auipc	ra,0x0
 264:	da0080e7          	jalr	-608(ra) # 0 <sinfo>
    if(info.nproc != nproc+1) {
 268:	fd843583          	ld	a1,-40(s0)
 26c:	00148613          	addi	a2,s1,1
 270:	02c58c63          	beq	a1,a2,2a8 <testproc+0x74>
      printf("sysinfotest: FAIL nproc is %d instead of %d\n", info.nproc, nproc+1);
 274:	00001517          	auipc	a0,0x1
 278:	98450513          	addi	a0,a0,-1660 # bf8 <malloc+0x1de>
 27c:	00000097          	auipc	ra,0x0
 280:	6de080e7          	jalr	1758(ra) # 95a <printf>
      exit(1);
 284:	4505                	li	a0,1
 286:	00000097          	auipc	ra,0x0
 28a:	34c080e7          	jalr	844(ra) # 5d2 <exit>
    printf("sysinfotest: fork failed\n");
 28e:	00001517          	auipc	a0,0x1
 292:	94a50513          	addi	a0,a0,-1718 # bd8 <malloc+0x1be>
 296:	00000097          	auipc	ra,0x0
 29a:	6c4080e7          	jalr	1732(ra) # 95a <printf>
    exit(1);
 29e:	4505                	li	a0,1
 2a0:	00000097          	auipc	ra,0x0
 2a4:	332080e7          	jalr	818(ra) # 5d2 <exit>
    }
    exit(0);
 2a8:	4501                	li	a0,0
 2aa:	00000097          	auipc	ra,0x0
 2ae:	328080e7          	jalr	808(ra) # 5d2 <exit>
  }
  wait(&status);
 2b2:	fcc40513          	addi	a0,s0,-52
 2b6:	00000097          	auipc	ra,0x0
 2ba:	324080e7          	jalr	804(ra) # 5da <wait>
  sinfo(&info);
 2be:	fd040513          	addi	a0,s0,-48
 2c2:	00000097          	auipc	ra,0x0
 2c6:	d3e080e7          	jalr	-706(ra) # 0 <sinfo>
  if(info.nproc != nproc) {
 2ca:	fd843583          	ld	a1,-40(s0)
 2ce:	00959763          	bne	a1,s1,2dc <testproc+0xa8>
      printf("sysinfotest: FAIL nproc is %d instead of %d\n", info.nproc, nproc);
      exit(1);
  }
}
 2d2:	70e2                	ld	ra,56(sp)
 2d4:	7442                	ld	s0,48(sp)
 2d6:	74a2                	ld	s1,40(sp)
 2d8:	6121                	addi	sp,sp,64
 2da:	8082                	ret
      printf("sysinfotest: FAIL nproc is %d instead of %d\n", info.nproc, nproc);
 2dc:	8626                	mv	a2,s1
 2de:	00001517          	auipc	a0,0x1
 2e2:	91a50513          	addi	a0,a0,-1766 # bf8 <malloc+0x1de>
 2e6:	00000097          	auipc	ra,0x0
 2ea:	674080e7          	jalr	1652(ra) # 95a <printf>
      exit(1);
 2ee:	4505                	li	a0,1
 2f0:	00000097          	auipc	ra,0x0
 2f4:	2e2080e7          	jalr	738(ra) # 5d2 <exit>

00000000000002f8 <main>:

int
main(int argc, char *argv[])
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e406                	sd	ra,8(sp)
 2fc:	e022                	sd	s0,0(sp)
 2fe:	0800                	addi	s0,sp,16
  printf("sysinfotest: start\n");
 300:	00001517          	auipc	a0,0x1
 304:	92850513          	addi	a0,a0,-1752 # c28 <malloc+0x20e>
 308:	00000097          	auipc	ra,0x0
 30c:	652080e7          	jalr	1618(ra) # 95a <printf>
  testcall();
 310:	00000097          	auipc	ra,0x0
 314:	eb8080e7          	jalr	-328(ra) # 1c8 <testcall>
  testmem();
 318:	00000097          	auipc	ra,0x0
 31c:	da8080e7          	jalr	-600(ra) # c0 <testmem>
  testproc();
 320:	00000097          	auipc	ra,0x0
 324:	f14080e7          	jalr	-236(ra) # 234 <testproc>
  printf("sysinfotest: OK\n");
 328:	00001517          	auipc	a0,0x1
 32c:	91850513          	addi	a0,a0,-1768 # c40 <malloc+0x226>
 330:	00000097          	auipc	ra,0x0
 334:	62a080e7          	jalr	1578(ra) # 95a <printf>
  exit(0);
 338:	4501                	li	a0,0
 33a:	00000097          	auipc	ra,0x0
 33e:	298080e7          	jalr	664(ra) # 5d2 <exit>

0000000000000342 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 342:	1141                	addi	sp,sp,-16
 344:	e422                	sd	s0,8(sp)
 346:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 348:	87aa                	mv	a5,a0
 34a:	0585                	addi	a1,a1,1
 34c:	0785                	addi	a5,a5,1
 34e:	fff5c703          	lbu	a4,-1(a1) # ffffffffffffefff <__global_pointer$+0xffffffffffffdb87>
 352:	fee78fa3          	sb	a4,-1(a5)
 356:	fb75                	bnez	a4,34a <strcpy+0x8>
    ;
  return os;
}
 358:	6422                	ld	s0,8(sp)
 35a:	0141                	addi	sp,sp,16
 35c:	8082                	ret

000000000000035e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 35e:	1141                	addi	sp,sp,-16
 360:	e422                	sd	s0,8(sp)
 362:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 364:	00054783          	lbu	a5,0(a0)
 368:	cf91                	beqz	a5,384 <strcmp+0x26>
 36a:	0005c703          	lbu	a4,0(a1)
 36e:	00f71b63          	bne	a4,a5,384 <strcmp+0x26>
    p++, q++;
 372:	0505                	addi	a0,a0,1
 374:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 376:	00054783          	lbu	a5,0(a0)
 37a:	c789                	beqz	a5,384 <strcmp+0x26>
 37c:	0005c703          	lbu	a4,0(a1)
 380:	fef709e3          	beq	a4,a5,372 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 384:	0005c503          	lbu	a0,0(a1)
}
 388:	40a7853b          	subw	a0,a5,a0
 38c:	6422                	ld	s0,8(sp)
 38e:	0141                	addi	sp,sp,16
 390:	8082                	ret

0000000000000392 <strlen>:

uint
strlen(const char *s)
{
 392:	1141                	addi	sp,sp,-16
 394:	e422                	sd	s0,8(sp)
 396:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 398:	00054783          	lbu	a5,0(a0)
 39c:	cf91                	beqz	a5,3b8 <strlen+0x26>
 39e:	0505                	addi	a0,a0,1
 3a0:	87aa                	mv	a5,a0
 3a2:	4685                	li	a3,1
 3a4:	9e89                	subw	a3,a3,a0
 3a6:	00f6853b          	addw	a0,a3,a5
 3aa:	0785                	addi	a5,a5,1
 3ac:	fff7c703          	lbu	a4,-1(a5)
 3b0:	fb7d                	bnez	a4,3a6 <strlen+0x14>
    ;
  return n;
}
 3b2:	6422                	ld	s0,8(sp)
 3b4:	0141                	addi	sp,sp,16
 3b6:	8082                	ret
  for(n = 0; s[n]; n++)
 3b8:	4501                	li	a0,0
 3ba:	bfe5                	j	3b2 <strlen+0x20>

00000000000003bc <memset>:

void*
memset(void *dst, int c, uint n)
{
 3bc:	1141                	addi	sp,sp,-16
 3be:	e422                	sd	s0,8(sp)
 3c0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3c2:	ce09                	beqz	a2,3dc <memset+0x20>
 3c4:	87aa                	mv	a5,a0
 3c6:	fff6071b          	addiw	a4,a2,-1
 3ca:	1702                	slli	a4,a4,0x20
 3cc:	9301                	srli	a4,a4,0x20
 3ce:	0705                	addi	a4,a4,1
 3d0:	972a                	add	a4,a4,a0
    cdst[i] = c;
 3d2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3d6:	0785                	addi	a5,a5,1
 3d8:	fee79de3          	bne	a5,a4,3d2 <memset+0x16>
  }
  return dst;
}
 3dc:	6422                	ld	s0,8(sp)
 3de:	0141                	addi	sp,sp,16
 3e0:	8082                	ret

00000000000003e2 <strchr>:

char*
strchr(const char *s, char c)
{
 3e2:	1141                	addi	sp,sp,-16
 3e4:	e422                	sd	s0,8(sp)
 3e6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3e8:	00054783          	lbu	a5,0(a0)
 3ec:	cf91                	beqz	a5,408 <strchr+0x26>
    if(*s == c)
 3ee:	00f58a63          	beq	a1,a5,402 <strchr+0x20>
  for(; *s; s++)
 3f2:	0505                	addi	a0,a0,1
 3f4:	00054783          	lbu	a5,0(a0)
 3f8:	c781                	beqz	a5,400 <strchr+0x1e>
    if(*s == c)
 3fa:	feb79ce3          	bne	a5,a1,3f2 <strchr+0x10>
 3fe:	a011                	j	402 <strchr+0x20>
      return (char*)s;
  return 0;
 400:	4501                	li	a0,0
}
 402:	6422                	ld	s0,8(sp)
 404:	0141                	addi	sp,sp,16
 406:	8082                	ret
  return 0;
 408:	4501                	li	a0,0
 40a:	bfe5                	j	402 <strchr+0x20>

000000000000040c <gets>:

char*
gets(char *buf, int max)
{
 40c:	711d                	addi	sp,sp,-96
 40e:	ec86                	sd	ra,88(sp)
 410:	e8a2                	sd	s0,80(sp)
 412:	e4a6                	sd	s1,72(sp)
 414:	e0ca                	sd	s2,64(sp)
 416:	fc4e                	sd	s3,56(sp)
 418:	f852                	sd	s4,48(sp)
 41a:	f456                	sd	s5,40(sp)
 41c:	f05a                	sd	s6,32(sp)
 41e:	ec5e                	sd	s7,24(sp)
 420:	1080                	addi	s0,sp,96
 422:	8baa                	mv	s7,a0
 424:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 426:	892a                	mv	s2,a0
 428:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 42a:	4aa9                	li	s5,10
 42c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 42e:	0019849b          	addiw	s1,s3,1
 432:	0344d863          	ble	s4,s1,462 <gets+0x56>
    cc = read(0, &c, 1);
 436:	4605                	li	a2,1
 438:	faf40593          	addi	a1,s0,-81
 43c:	4501                	li	a0,0
 43e:	00000097          	auipc	ra,0x0
 442:	1ac080e7          	jalr	428(ra) # 5ea <read>
    if(cc < 1)
 446:	00a05e63          	blez	a0,462 <gets+0x56>
    buf[i++] = c;
 44a:	faf44783          	lbu	a5,-81(s0)
 44e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 452:	01578763          	beq	a5,s5,460 <gets+0x54>
 456:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 458:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 45a:	fd679ae3          	bne	a5,s6,42e <gets+0x22>
 45e:	a011                	j	462 <gets+0x56>
  for(i=0; i+1 < max; ){
 460:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 462:	99de                	add	s3,s3,s7
 464:	00098023          	sb	zero,0(s3) # 1000 <_end+0x368>
  return buf;
}
 468:	855e                	mv	a0,s7
 46a:	60e6                	ld	ra,88(sp)
 46c:	6446                	ld	s0,80(sp)
 46e:	64a6                	ld	s1,72(sp)
 470:	6906                	ld	s2,64(sp)
 472:	79e2                	ld	s3,56(sp)
 474:	7a42                	ld	s4,48(sp)
 476:	7aa2                	ld	s5,40(sp)
 478:	7b02                	ld	s6,32(sp)
 47a:	6be2                	ld	s7,24(sp)
 47c:	6125                	addi	sp,sp,96
 47e:	8082                	ret

0000000000000480 <stat>:

int
stat(const char *n, struct stat *st)
{
 480:	1101                	addi	sp,sp,-32
 482:	ec06                	sd	ra,24(sp)
 484:	e822                	sd	s0,16(sp)
 486:	e426                	sd	s1,8(sp)
 488:	e04a                	sd	s2,0(sp)
 48a:	1000                	addi	s0,sp,32
 48c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 48e:	4581                	li	a1,0
 490:	00000097          	auipc	ra,0x0
 494:	182080e7          	jalr	386(ra) # 612 <open>
  if(fd < 0)
 498:	02054563          	bltz	a0,4c2 <stat+0x42>
 49c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 49e:	85ca                	mv	a1,s2
 4a0:	00000097          	auipc	ra,0x0
 4a4:	18a080e7          	jalr	394(ra) # 62a <fstat>
 4a8:	892a                	mv	s2,a0
  close(fd);
 4aa:	8526                	mv	a0,s1
 4ac:	00000097          	auipc	ra,0x0
 4b0:	14e080e7          	jalr	334(ra) # 5fa <close>
  return r;
}
 4b4:	854a                	mv	a0,s2
 4b6:	60e2                	ld	ra,24(sp)
 4b8:	6442                	ld	s0,16(sp)
 4ba:	64a2                	ld	s1,8(sp)
 4bc:	6902                	ld	s2,0(sp)
 4be:	6105                	addi	sp,sp,32
 4c0:	8082                	ret
    return -1;
 4c2:	597d                	li	s2,-1
 4c4:	bfc5                	j	4b4 <stat+0x34>

00000000000004c6 <atoi>:

int
atoi(const char *s)
{
 4c6:	1141                	addi	sp,sp,-16
 4c8:	e422                	sd	s0,8(sp)
 4ca:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4cc:	00054683          	lbu	a3,0(a0)
 4d0:	fd06879b          	addiw	a5,a3,-48
 4d4:	0ff7f793          	andi	a5,a5,255
 4d8:	4725                	li	a4,9
 4da:	02f76963          	bltu	a4,a5,50c <atoi+0x46>
 4de:	862a                	mv	a2,a0
  n = 0;
 4e0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4e2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4e4:	0605                	addi	a2,a2,1
 4e6:	0025179b          	slliw	a5,a0,0x2
 4ea:	9fa9                	addw	a5,a5,a0
 4ec:	0017979b          	slliw	a5,a5,0x1
 4f0:	9fb5                	addw	a5,a5,a3
 4f2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4f6:	00064683          	lbu	a3,0(a2)
 4fa:	fd06871b          	addiw	a4,a3,-48
 4fe:	0ff77713          	andi	a4,a4,255
 502:	fee5f1e3          	bleu	a4,a1,4e4 <atoi+0x1e>
  return n;
}
 506:	6422                	ld	s0,8(sp)
 508:	0141                	addi	sp,sp,16
 50a:	8082                	ret
  n = 0;
 50c:	4501                	li	a0,0
 50e:	bfe5                	j	506 <atoi+0x40>

0000000000000510 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 510:	1141                	addi	sp,sp,-16
 512:	e422                	sd	s0,8(sp)
 514:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 516:	02b57663          	bleu	a1,a0,542 <memmove+0x32>
    while(n-- > 0)
 51a:	02c05163          	blez	a2,53c <memmove+0x2c>
 51e:	fff6079b          	addiw	a5,a2,-1
 522:	1782                	slli	a5,a5,0x20
 524:	9381                	srli	a5,a5,0x20
 526:	0785                	addi	a5,a5,1
 528:	97aa                	add	a5,a5,a0
  dst = vdst;
 52a:	872a                	mv	a4,a0
      *dst++ = *src++;
 52c:	0585                	addi	a1,a1,1
 52e:	0705                	addi	a4,a4,1
 530:	fff5c683          	lbu	a3,-1(a1)
 534:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 538:	fee79ae3          	bne	a5,a4,52c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 53c:	6422                	ld	s0,8(sp)
 53e:	0141                	addi	sp,sp,16
 540:	8082                	ret
    dst += n;
 542:	00c50733          	add	a4,a0,a2
    src += n;
 546:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 548:	fec05ae3          	blez	a2,53c <memmove+0x2c>
 54c:	fff6079b          	addiw	a5,a2,-1
 550:	1782                	slli	a5,a5,0x20
 552:	9381                	srli	a5,a5,0x20
 554:	fff7c793          	not	a5,a5
 558:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 55a:	15fd                	addi	a1,a1,-1
 55c:	177d                	addi	a4,a4,-1
 55e:	0005c683          	lbu	a3,0(a1)
 562:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 566:	fef71ae3          	bne	a4,a5,55a <memmove+0x4a>
 56a:	bfc9                	j	53c <memmove+0x2c>

000000000000056c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 56c:	1141                	addi	sp,sp,-16
 56e:	e422                	sd	s0,8(sp)
 570:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 572:	ce15                	beqz	a2,5ae <memcmp+0x42>
 574:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 578:	00054783          	lbu	a5,0(a0)
 57c:	0005c703          	lbu	a4,0(a1)
 580:	02e79063          	bne	a5,a4,5a0 <memcmp+0x34>
 584:	1682                	slli	a3,a3,0x20
 586:	9281                	srli	a3,a3,0x20
 588:	0685                	addi	a3,a3,1
 58a:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 58c:	0505                	addi	a0,a0,1
    p2++;
 58e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 590:	00d50d63          	beq	a0,a3,5aa <memcmp+0x3e>
    if (*p1 != *p2) {
 594:	00054783          	lbu	a5,0(a0)
 598:	0005c703          	lbu	a4,0(a1)
 59c:	fee788e3          	beq	a5,a4,58c <memcmp+0x20>
      return *p1 - *p2;
 5a0:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 5a4:	6422                	ld	s0,8(sp)
 5a6:	0141                	addi	sp,sp,16
 5a8:	8082                	ret
  return 0;
 5aa:	4501                	li	a0,0
 5ac:	bfe5                	j	5a4 <memcmp+0x38>
 5ae:	4501                	li	a0,0
 5b0:	bfd5                	j	5a4 <memcmp+0x38>

00000000000005b2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 5b2:	1141                	addi	sp,sp,-16
 5b4:	e406                	sd	ra,8(sp)
 5b6:	e022                	sd	s0,0(sp)
 5b8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 5ba:	00000097          	auipc	ra,0x0
 5be:	f56080e7          	jalr	-170(ra) # 510 <memmove>
}
 5c2:	60a2                	ld	ra,8(sp)
 5c4:	6402                	ld	s0,0(sp)
 5c6:	0141                	addi	sp,sp,16
 5c8:	8082                	ret

00000000000005ca <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5ca:	4885                	li	a7,1
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 5d2:	4889                	li	a7,2
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <wait>:
.global wait
wait:
 li a7, SYS_wait
 5da:	488d                	li	a7,3
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5e2:	4891                	li	a7,4
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <read>:
.global read
read:
 li a7, SYS_read
 5ea:	4895                	li	a7,5
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <write>:
.global write
write:
 li a7, SYS_write
 5f2:	48c1                	li	a7,16
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <close>:
.global close
close:
 li a7, SYS_close
 5fa:	48d5                	li	a7,21
 ecall
 5fc:	00000073          	ecall
 ret
 600:	8082                	ret

0000000000000602 <kill>:
.global kill
kill:
 li a7, SYS_kill
 602:	4899                	li	a7,6
 ecall
 604:	00000073          	ecall
 ret
 608:	8082                	ret

000000000000060a <exec>:
.global exec
exec:
 li a7, SYS_exec
 60a:	489d                	li	a7,7
 ecall
 60c:	00000073          	ecall
 ret
 610:	8082                	ret

0000000000000612 <open>:
.global open
open:
 li a7, SYS_open
 612:	48bd                	li	a7,15
 ecall
 614:	00000073          	ecall
 ret
 618:	8082                	ret

000000000000061a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 61a:	48c5                	li	a7,17
 ecall
 61c:	00000073          	ecall
 ret
 620:	8082                	ret

0000000000000622 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 622:	48c9                	li	a7,18
 ecall
 624:	00000073          	ecall
 ret
 628:	8082                	ret

000000000000062a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 62a:	48a1                	li	a7,8
 ecall
 62c:	00000073          	ecall
 ret
 630:	8082                	ret

0000000000000632 <link>:
.global link
link:
 li a7, SYS_link
 632:	48cd                	li	a7,19
 ecall
 634:	00000073          	ecall
 ret
 638:	8082                	ret

000000000000063a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 63a:	48d1                	li	a7,20
 ecall
 63c:	00000073          	ecall
 ret
 640:	8082                	ret

0000000000000642 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 642:	48a5                	li	a7,9
 ecall
 644:	00000073          	ecall
 ret
 648:	8082                	ret

000000000000064a <dup>:
.global dup
dup:
 li a7, SYS_dup
 64a:	48a9                	li	a7,10
 ecall
 64c:	00000073          	ecall
 ret
 650:	8082                	ret

0000000000000652 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 652:	48ad                	li	a7,11
 ecall
 654:	00000073          	ecall
 ret
 658:	8082                	ret

000000000000065a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 65a:	48b1                	li	a7,12
 ecall
 65c:	00000073          	ecall
 ret
 660:	8082                	ret

0000000000000662 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 662:	48b5                	li	a7,13
 ecall
 664:	00000073          	ecall
 ret
 668:	8082                	ret

000000000000066a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 66a:	48b9                	li	a7,14
 ecall
 66c:	00000073          	ecall
 ret
 670:	8082                	ret

0000000000000672 <trace>:
.global trace
trace:
 li a7, SYS_trace
 672:	48d9                	li	a7,22
 ecall
 674:	00000073          	ecall
 ret
 678:	8082                	ret

000000000000067a <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 67a:	48dd                	li	a7,23
 ecall
 67c:	00000073          	ecall
 ret
 680:	8082                	ret

0000000000000682 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 682:	1101                	addi	sp,sp,-32
 684:	ec06                	sd	ra,24(sp)
 686:	e822                	sd	s0,16(sp)
 688:	1000                	addi	s0,sp,32
 68a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 68e:	4605                	li	a2,1
 690:	fef40593          	addi	a1,s0,-17
 694:	00000097          	auipc	ra,0x0
 698:	f5e080e7          	jalr	-162(ra) # 5f2 <write>
}
 69c:	60e2                	ld	ra,24(sp)
 69e:	6442                	ld	s0,16(sp)
 6a0:	6105                	addi	sp,sp,32
 6a2:	8082                	ret

00000000000006a4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6a4:	7139                	addi	sp,sp,-64
 6a6:	fc06                	sd	ra,56(sp)
 6a8:	f822                	sd	s0,48(sp)
 6aa:	f426                	sd	s1,40(sp)
 6ac:	f04a                	sd	s2,32(sp)
 6ae:	ec4e                	sd	s3,24(sp)
 6b0:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 6b2:	c299                	beqz	a3,6b8 <printint+0x14>
 6b4:	0005cd63          	bltz	a1,6ce <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 6b8:	2581                	sext.w	a1,a1
  neg = 0;
 6ba:	4301                	li	t1,0
 6bc:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 6c0:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 6c2:	2601                	sext.w	a2,a2
 6c4:	00000897          	auipc	a7,0x0
 6c8:	59488893          	addi	a7,a7,1428 # c58 <digits>
 6cc:	a801                	j	6dc <printint+0x38>
    x = -xx;
 6ce:	40b005bb          	negw	a1,a1
 6d2:	2581                	sext.w	a1,a1
    neg = 1;
 6d4:	4305                	li	t1,1
    x = -xx;
 6d6:	b7dd                	j	6bc <printint+0x18>
  }while((x /= base) != 0);
 6d8:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 6da:	8836                	mv	a6,a3
 6dc:	0018069b          	addiw	a3,a6,1
 6e0:	02c5f7bb          	remuw	a5,a1,a2
 6e4:	1782                	slli	a5,a5,0x20
 6e6:	9381                	srli	a5,a5,0x20
 6e8:	97c6                	add	a5,a5,a7
 6ea:	0007c783          	lbu	a5,0(a5)
 6ee:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 6f2:	0705                	addi	a4,a4,1
 6f4:	02c5d7bb          	divuw	a5,a1,a2
 6f8:	fec5f0e3          	bleu	a2,a1,6d8 <printint+0x34>
  if(neg)
 6fc:	00030b63          	beqz	t1,712 <printint+0x6e>
    buf[i++] = '-';
 700:	fd040793          	addi	a5,s0,-48
 704:	96be                	add	a3,a3,a5
 706:	02d00793          	li	a5,45
 70a:	fef68823          	sb	a5,-16(a3)
 70e:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 712:	02d05963          	blez	a3,744 <printint+0xa0>
 716:	89aa                	mv	s3,a0
 718:	fc040793          	addi	a5,s0,-64
 71c:	00d784b3          	add	s1,a5,a3
 720:	fff78913          	addi	s2,a5,-1
 724:	9936                	add	s2,s2,a3
 726:	36fd                	addiw	a3,a3,-1
 728:	1682                	slli	a3,a3,0x20
 72a:	9281                	srli	a3,a3,0x20
 72c:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 730:	fff4c583          	lbu	a1,-1(s1)
 734:	854e                	mv	a0,s3
 736:	00000097          	auipc	ra,0x0
 73a:	f4c080e7          	jalr	-180(ra) # 682 <putc>
  while(--i >= 0)
 73e:	14fd                	addi	s1,s1,-1
 740:	ff2498e3          	bne	s1,s2,730 <printint+0x8c>
}
 744:	70e2                	ld	ra,56(sp)
 746:	7442                	ld	s0,48(sp)
 748:	74a2                	ld	s1,40(sp)
 74a:	7902                	ld	s2,32(sp)
 74c:	69e2                	ld	s3,24(sp)
 74e:	6121                	addi	sp,sp,64
 750:	8082                	ret

0000000000000752 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 752:	7119                	addi	sp,sp,-128
 754:	fc86                	sd	ra,120(sp)
 756:	f8a2                	sd	s0,112(sp)
 758:	f4a6                	sd	s1,104(sp)
 75a:	f0ca                	sd	s2,96(sp)
 75c:	ecce                	sd	s3,88(sp)
 75e:	e8d2                	sd	s4,80(sp)
 760:	e4d6                	sd	s5,72(sp)
 762:	e0da                	sd	s6,64(sp)
 764:	fc5e                	sd	s7,56(sp)
 766:	f862                	sd	s8,48(sp)
 768:	f466                	sd	s9,40(sp)
 76a:	f06a                	sd	s10,32(sp)
 76c:	ec6e                	sd	s11,24(sp)
 76e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 770:	0005c483          	lbu	s1,0(a1)
 774:	18048d63          	beqz	s1,90e <vprintf+0x1bc>
 778:	8aaa                	mv	s5,a0
 77a:	8b32                	mv	s6,a2
 77c:	00158913          	addi	s2,a1,1
  state = 0;
 780:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 782:	02500a13          	li	s4,37
      if(c == 'd'){
 786:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 78a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 78e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 792:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 796:	00000b97          	auipc	s7,0x0
 79a:	4c2b8b93          	addi	s7,s7,1218 # c58 <digits>
 79e:	a839                	j	7bc <vprintf+0x6a>
        putc(fd, c);
 7a0:	85a6                	mv	a1,s1
 7a2:	8556                	mv	a0,s5
 7a4:	00000097          	auipc	ra,0x0
 7a8:	ede080e7          	jalr	-290(ra) # 682 <putc>
 7ac:	a019                	j	7b2 <vprintf+0x60>
    } else if(state == '%'){
 7ae:	01498f63          	beq	s3,s4,7cc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 7b2:	0905                	addi	s2,s2,1
 7b4:	fff94483          	lbu	s1,-1(s2)
 7b8:	14048b63          	beqz	s1,90e <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 7bc:	0004879b          	sext.w	a5,s1
    if(state == 0){
 7c0:	fe0997e3          	bnez	s3,7ae <vprintf+0x5c>
      if(c == '%'){
 7c4:	fd479ee3          	bne	a5,s4,7a0 <vprintf+0x4e>
        state = '%';
 7c8:	89be                	mv	s3,a5
 7ca:	b7e5                	j	7b2 <vprintf+0x60>
      if(c == 'd'){
 7cc:	05878063          	beq	a5,s8,80c <vprintf+0xba>
      } else if(c == 'l') {
 7d0:	05978c63          	beq	a5,s9,828 <vprintf+0xd6>
      } else if(c == 'x') {
 7d4:	07a78863          	beq	a5,s10,844 <vprintf+0xf2>
      } else if(c == 'p') {
 7d8:	09b78463          	beq	a5,s11,860 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 7dc:	07300713          	li	a4,115
 7e0:	0ce78563          	beq	a5,a4,8aa <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7e4:	06300713          	li	a4,99
 7e8:	0ee78c63          	beq	a5,a4,8e0 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7ec:	11478663          	beq	a5,s4,8f8 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7f0:	85d2                	mv	a1,s4
 7f2:	8556                	mv	a0,s5
 7f4:	00000097          	auipc	ra,0x0
 7f8:	e8e080e7          	jalr	-370(ra) # 682 <putc>
        putc(fd, c);
 7fc:	85a6                	mv	a1,s1
 7fe:	8556                	mv	a0,s5
 800:	00000097          	auipc	ra,0x0
 804:	e82080e7          	jalr	-382(ra) # 682 <putc>
      }
      state = 0;
 808:	4981                	li	s3,0
 80a:	b765                	j	7b2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 80c:	008b0493          	addi	s1,s6,8
 810:	4685                	li	a3,1
 812:	4629                	li	a2,10
 814:	000b2583          	lw	a1,0(s6)
 818:	8556                	mv	a0,s5
 81a:	00000097          	auipc	ra,0x0
 81e:	e8a080e7          	jalr	-374(ra) # 6a4 <printint>
 822:	8b26                	mv	s6,s1
      state = 0;
 824:	4981                	li	s3,0
 826:	b771                	j	7b2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 828:	008b0493          	addi	s1,s6,8
 82c:	4681                	li	a3,0
 82e:	4629                	li	a2,10
 830:	000b2583          	lw	a1,0(s6)
 834:	8556                	mv	a0,s5
 836:	00000097          	auipc	ra,0x0
 83a:	e6e080e7          	jalr	-402(ra) # 6a4 <printint>
 83e:	8b26                	mv	s6,s1
      state = 0;
 840:	4981                	li	s3,0
 842:	bf85                	j	7b2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 844:	008b0493          	addi	s1,s6,8
 848:	4681                	li	a3,0
 84a:	4641                	li	a2,16
 84c:	000b2583          	lw	a1,0(s6)
 850:	8556                	mv	a0,s5
 852:	00000097          	auipc	ra,0x0
 856:	e52080e7          	jalr	-430(ra) # 6a4 <printint>
 85a:	8b26                	mv	s6,s1
      state = 0;
 85c:	4981                	li	s3,0
 85e:	bf91                	j	7b2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 860:	008b0793          	addi	a5,s6,8
 864:	f8f43423          	sd	a5,-120(s0)
 868:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 86c:	03000593          	li	a1,48
 870:	8556                	mv	a0,s5
 872:	00000097          	auipc	ra,0x0
 876:	e10080e7          	jalr	-496(ra) # 682 <putc>
  putc(fd, 'x');
 87a:	85ea                	mv	a1,s10
 87c:	8556                	mv	a0,s5
 87e:	00000097          	auipc	ra,0x0
 882:	e04080e7          	jalr	-508(ra) # 682 <putc>
 886:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 888:	03c9d793          	srli	a5,s3,0x3c
 88c:	97de                	add	a5,a5,s7
 88e:	0007c583          	lbu	a1,0(a5)
 892:	8556                	mv	a0,s5
 894:	00000097          	auipc	ra,0x0
 898:	dee080e7          	jalr	-530(ra) # 682 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 89c:	0992                	slli	s3,s3,0x4
 89e:	34fd                	addiw	s1,s1,-1
 8a0:	f4e5                	bnez	s1,888 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 8a2:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 8a6:	4981                	li	s3,0
 8a8:	b729                	j	7b2 <vprintf+0x60>
        s = va_arg(ap, char*);
 8aa:	008b0993          	addi	s3,s6,8
 8ae:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 8b2:	c085                	beqz	s1,8d2 <vprintf+0x180>
        while(*s != 0){
 8b4:	0004c583          	lbu	a1,0(s1)
 8b8:	c9a1                	beqz	a1,908 <vprintf+0x1b6>
          putc(fd, *s);
 8ba:	8556                	mv	a0,s5
 8bc:	00000097          	auipc	ra,0x0
 8c0:	dc6080e7          	jalr	-570(ra) # 682 <putc>
          s++;
 8c4:	0485                	addi	s1,s1,1
        while(*s != 0){
 8c6:	0004c583          	lbu	a1,0(s1)
 8ca:	f9e5                	bnez	a1,8ba <vprintf+0x168>
        s = va_arg(ap, char*);
 8cc:	8b4e                	mv	s6,s3
      state = 0;
 8ce:	4981                	li	s3,0
 8d0:	b5cd                	j	7b2 <vprintf+0x60>
          s = "(null)";
 8d2:	00000497          	auipc	s1,0x0
 8d6:	39e48493          	addi	s1,s1,926 # c70 <digits+0x18>
        while(*s != 0){
 8da:	02800593          	li	a1,40
 8de:	bff1                	j	8ba <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 8e0:	008b0493          	addi	s1,s6,8
 8e4:	000b4583          	lbu	a1,0(s6)
 8e8:	8556                	mv	a0,s5
 8ea:	00000097          	auipc	ra,0x0
 8ee:	d98080e7          	jalr	-616(ra) # 682 <putc>
 8f2:	8b26                	mv	s6,s1
      state = 0;
 8f4:	4981                	li	s3,0
 8f6:	bd75                	j	7b2 <vprintf+0x60>
        putc(fd, c);
 8f8:	85d2                	mv	a1,s4
 8fa:	8556                	mv	a0,s5
 8fc:	00000097          	auipc	ra,0x0
 900:	d86080e7          	jalr	-634(ra) # 682 <putc>
      state = 0;
 904:	4981                	li	s3,0
 906:	b575                	j	7b2 <vprintf+0x60>
        s = va_arg(ap, char*);
 908:	8b4e                	mv	s6,s3
      state = 0;
 90a:	4981                	li	s3,0
 90c:	b55d                	j	7b2 <vprintf+0x60>
    }
  }
}
 90e:	70e6                	ld	ra,120(sp)
 910:	7446                	ld	s0,112(sp)
 912:	74a6                	ld	s1,104(sp)
 914:	7906                	ld	s2,96(sp)
 916:	69e6                	ld	s3,88(sp)
 918:	6a46                	ld	s4,80(sp)
 91a:	6aa6                	ld	s5,72(sp)
 91c:	6b06                	ld	s6,64(sp)
 91e:	7be2                	ld	s7,56(sp)
 920:	7c42                	ld	s8,48(sp)
 922:	7ca2                	ld	s9,40(sp)
 924:	7d02                	ld	s10,32(sp)
 926:	6de2                	ld	s11,24(sp)
 928:	6109                	addi	sp,sp,128
 92a:	8082                	ret

000000000000092c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 92c:	715d                	addi	sp,sp,-80
 92e:	ec06                	sd	ra,24(sp)
 930:	e822                	sd	s0,16(sp)
 932:	1000                	addi	s0,sp,32
 934:	e010                	sd	a2,0(s0)
 936:	e414                	sd	a3,8(s0)
 938:	e818                	sd	a4,16(s0)
 93a:	ec1c                	sd	a5,24(s0)
 93c:	03043023          	sd	a6,32(s0)
 940:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 944:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 948:	8622                	mv	a2,s0
 94a:	00000097          	auipc	ra,0x0
 94e:	e08080e7          	jalr	-504(ra) # 752 <vprintf>
}
 952:	60e2                	ld	ra,24(sp)
 954:	6442                	ld	s0,16(sp)
 956:	6161                	addi	sp,sp,80
 958:	8082                	ret

000000000000095a <printf>:

void
printf(const char *fmt, ...)
{
 95a:	711d                	addi	sp,sp,-96
 95c:	ec06                	sd	ra,24(sp)
 95e:	e822                	sd	s0,16(sp)
 960:	1000                	addi	s0,sp,32
 962:	e40c                	sd	a1,8(s0)
 964:	e810                	sd	a2,16(s0)
 966:	ec14                	sd	a3,24(s0)
 968:	f018                	sd	a4,32(s0)
 96a:	f41c                	sd	a5,40(s0)
 96c:	03043823          	sd	a6,48(s0)
 970:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 974:	00840613          	addi	a2,s0,8
 978:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 97c:	85aa                	mv	a1,a0
 97e:	4505                	li	a0,1
 980:	00000097          	auipc	ra,0x0
 984:	dd2080e7          	jalr	-558(ra) # 752 <vprintf>
}
 988:	60e2                	ld	ra,24(sp)
 98a:	6442                	ld	s0,16(sp)
 98c:	6125                	addi	sp,sp,96
 98e:	8082                	ret

0000000000000990 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 990:	1141                	addi	sp,sp,-16
 992:	e422                	sd	s0,8(sp)
 994:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 996:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 99a:	00000797          	auipc	a5,0x0
 99e:	2e678793          	addi	a5,a5,742 # c80 <_edata>
 9a2:	639c                	ld	a5,0(a5)
 9a4:	a805                	j	9d4 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9a6:	4618                	lw	a4,8(a2)
 9a8:	9db9                	addw	a1,a1,a4
 9aa:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9ae:	6398                	ld	a4,0(a5)
 9b0:	6318                	ld	a4,0(a4)
 9b2:	fee53823          	sd	a4,-16(a0)
 9b6:	a091                	j	9fa <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9b8:	ff852703          	lw	a4,-8(a0)
 9bc:	9e39                	addw	a2,a2,a4
 9be:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 9c0:	ff053703          	ld	a4,-16(a0)
 9c4:	e398                	sd	a4,0(a5)
 9c6:	a099                	j	a0c <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9c8:	6398                	ld	a4,0(a5)
 9ca:	00e7e463          	bltu	a5,a4,9d2 <free+0x42>
 9ce:	00e6ea63          	bltu	a3,a4,9e2 <free+0x52>
{
 9d2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9d4:	fed7fae3          	bleu	a3,a5,9c8 <free+0x38>
 9d8:	6398                	ld	a4,0(a5)
 9da:	00e6e463          	bltu	a3,a4,9e2 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9de:	fee7eae3          	bltu	a5,a4,9d2 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 9e2:	ff852583          	lw	a1,-8(a0)
 9e6:	6390                	ld	a2,0(a5)
 9e8:	02059713          	slli	a4,a1,0x20
 9ec:	9301                	srli	a4,a4,0x20
 9ee:	0712                	slli	a4,a4,0x4
 9f0:	9736                	add	a4,a4,a3
 9f2:	fae60ae3          	beq	a2,a4,9a6 <free+0x16>
    bp->s.ptr = p->s.ptr;
 9f6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9fa:	4790                	lw	a2,8(a5)
 9fc:	02061713          	slli	a4,a2,0x20
 a00:	9301                	srli	a4,a4,0x20
 a02:	0712                	slli	a4,a4,0x4
 a04:	973e                	add	a4,a4,a5
 a06:	fae689e3          	beq	a3,a4,9b8 <free+0x28>
  } else
    p->s.ptr = bp;
 a0a:	e394                	sd	a3,0(a5)
  freep = p;
 a0c:	00000717          	auipc	a4,0x0
 a10:	26f73a23          	sd	a5,628(a4) # c80 <_edata>
}
 a14:	6422                	ld	s0,8(sp)
 a16:	0141                	addi	sp,sp,16
 a18:	8082                	ret

0000000000000a1a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a1a:	7139                	addi	sp,sp,-64
 a1c:	fc06                	sd	ra,56(sp)
 a1e:	f822                	sd	s0,48(sp)
 a20:	f426                	sd	s1,40(sp)
 a22:	f04a                	sd	s2,32(sp)
 a24:	ec4e                	sd	s3,24(sp)
 a26:	e852                	sd	s4,16(sp)
 a28:	e456                	sd	s5,8(sp)
 a2a:	e05a                	sd	s6,0(sp)
 a2c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a2e:	02051993          	slli	s3,a0,0x20
 a32:	0209d993          	srli	s3,s3,0x20
 a36:	09bd                	addi	s3,s3,15
 a38:	0049d993          	srli	s3,s3,0x4
 a3c:	2985                	addiw	s3,s3,1
 a3e:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 a42:	00000797          	auipc	a5,0x0
 a46:	23e78793          	addi	a5,a5,574 # c80 <_edata>
 a4a:	6388                	ld	a0,0(a5)
 a4c:	c515                	beqz	a0,a78 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a4e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a50:	4798                	lw	a4,8(a5)
 a52:	03277f63          	bleu	s2,a4,a90 <malloc+0x76>
 a56:	8a4e                	mv	s4,s3
 a58:	0009871b          	sext.w	a4,s3
 a5c:	6685                	lui	a3,0x1
 a5e:	00d77363          	bleu	a3,a4,a64 <malloc+0x4a>
 a62:	6a05                	lui	s4,0x1
 a64:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 a68:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a6c:	00000497          	auipc	s1,0x0
 a70:	21448493          	addi	s1,s1,532 # c80 <_edata>
  if(p == (char*)-1)
 a74:	5b7d                	li	s6,-1
 a76:	a885                	j	ae6 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 a78:	00000797          	auipc	a5,0x0
 a7c:	21078793          	addi	a5,a5,528 # c88 <base>
 a80:	00000717          	auipc	a4,0x0
 a84:	20f73023          	sd	a5,512(a4) # c80 <_edata>
 a88:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a8a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a8e:	b7e1                	j	a56 <malloc+0x3c>
      if(p->s.size == nunits)
 a90:	02e90b63          	beq	s2,a4,ac6 <malloc+0xac>
        p->s.size -= nunits;
 a94:	4137073b          	subw	a4,a4,s3
 a98:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a9a:	1702                	slli	a4,a4,0x20
 a9c:	9301                	srli	a4,a4,0x20
 a9e:	0712                	slli	a4,a4,0x4
 aa0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 aa2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 aa6:	00000717          	auipc	a4,0x0
 aaa:	1ca73d23          	sd	a0,474(a4) # c80 <_edata>
      return (void*)(p + 1);
 aae:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 ab2:	70e2                	ld	ra,56(sp)
 ab4:	7442                	ld	s0,48(sp)
 ab6:	74a2                	ld	s1,40(sp)
 ab8:	7902                	ld	s2,32(sp)
 aba:	69e2                	ld	s3,24(sp)
 abc:	6a42                	ld	s4,16(sp)
 abe:	6aa2                	ld	s5,8(sp)
 ac0:	6b02                	ld	s6,0(sp)
 ac2:	6121                	addi	sp,sp,64
 ac4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 ac6:	6398                	ld	a4,0(a5)
 ac8:	e118                	sd	a4,0(a0)
 aca:	bff1                	j	aa6 <malloc+0x8c>
  hp->s.size = nu;
 acc:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 ad0:	0541                	addi	a0,a0,16
 ad2:	00000097          	auipc	ra,0x0
 ad6:	ebe080e7          	jalr	-322(ra) # 990 <free>
  return freep;
 ada:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 adc:	d979                	beqz	a0,ab2 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ade:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ae0:	4798                	lw	a4,8(a5)
 ae2:	fb2777e3          	bleu	s2,a4,a90 <malloc+0x76>
    if(p == freep)
 ae6:	6098                	ld	a4,0(s1)
 ae8:	853e                	mv	a0,a5
 aea:	fef71ae3          	bne	a4,a5,ade <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 aee:	8552                	mv	a0,s4
 af0:	00000097          	auipc	ra,0x0
 af4:	b6a080e7          	jalr	-1174(ra) # 65a <sbrk>
  if(p == (char*)-1)
 af8:	fd651ae3          	bne	a0,s6,acc <malloc+0xb2>
        return 0;
 afc:	4501                	li	a0,0
 afe:	bf55                	j	ab2 <malloc+0x98>
