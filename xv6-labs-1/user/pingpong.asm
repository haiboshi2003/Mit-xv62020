
user/_pingpong：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	0080                	addi	s0,sp,64
  int pid;
  int pipes1[2], pipes2[2];
  char buf[] = {'a'};
   a:	06100793          	li	a5,97
   e:	fcf40423          	sb	a5,-56(s0)
  pipe(pipes1);
  12:	fd840513          	addi	a0,s0,-40
  16:	00000097          	auipc	ra,0x0
  1a:	3b4080e7          	jalr	948(ra) # 3ca <pipe>
  pipe(pipes2);
  1e:	fd040513          	addi	a0,s0,-48
  22:	00000097          	auipc	ra,0x0
  26:	3a8080e7          	jalr	936(ra) # 3ca <pipe>

  int ret = fork();
  2a:	00000097          	auipc	ra,0x0
  2e:	388080e7          	jalr	904(ra) # 3b2 <fork>

  // parent send in pipes1[1], child receives in pipes1[0]
  // child send in pipes2[1], parent receives in pipes2[0]
  // should have checked close & read & write return value for error, but i am
  // lazy
  if (ret == 0) {
  32:	c92d                	beqz	a0,a4 <main+0xa4>
    printf("%d: received ping\n", pid);
    buf[0]='0';
    write(pipes2[1], buf, 1);
    exit(0);
  } 
  else if (ret == -1){
  34:	57fd                	li	a5,-1
  36:	0cf50c63          	beq	a0,a5,10e <main+0x10e>
  }

  
  else {
    // 父进程
    pid = getpid();
  3a:	00000097          	auipc	ra,0x0
  3e:	400080e7          	jalr	1024(ra) # 43a <getpid>
  42:	84aa                	mv	s1,a0
    close(pipes1[0]);
  44:	fd842503          	lw	a0,-40(s0)
  48:	00000097          	auipc	ra,0x0
  4c:	39a080e7          	jalr	922(ra) # 3e2 <close>
    close(pipes2[1]);
  50:	fd442503          	lw	a0,-44(s0)
  54:	00000097          	auipc	ra,0x0
  58:	38e080e7          	jalr	910(ra) # 3e2 <close>
    buf[0]='1';
  5c:	03100793          	li	a5,49
  60:	fcf40423          	sb	a5,-56(s0)
    write(pipes1[1], buf, 1);
  64:	4605                	li	a2,1
  66:	fc840593          	addi	a1,s0,-56
  6a:	fdc42503          	lw	a0,-36(s0)
  6e:	00000097          	auipc	ra,0x0
  72:	36c080e7          	jalr	876(ra) # 3da <write>
    read(pipes2[0], buf, 1);
  76:	4605                	li	a2,1
  78:	fc840593          	addi	a1,s0,-56
  7c:	fd042503          	lw	a0,-48(s0)
  80:	00000097          	auipc	ra,0x0
  84:	352080e7          	jalr	850(ra) # 3d2 <read>
    printf("%d: received pong\n", pid);
  88:	85a6                	mv	a1,s1
  8a:	00001517          	auipc	a0,0x1
  8e:	88e50513          	addi	a0,a0,-1906 # 918 <malloc+0x126>
  92:	00000097          	auipc	ra,0x0
  96:	6a0080e7          	jalr	1696(ra) # 732 <printf>
    exit(0);
  9a:	4501                	li	a0,0
  9c:	00000097          	auipc	ra,0x0
  a0:	31e080e7          	jalr	798(ra) # 3ba <exit>
    pid = getpid();
  a4:	00000097          	auipc	ra,0x0
  a8:	396080e7          	jalr	918(ra) # 43a <getpid>
  ac:	84aa                	mv	s1,a0
    close(pipes1[1]);
  ae:	fdc42503          	lw	a0,-36(s0)
  b2:	00000097          	auipc	ra,0x0
  b6:	330080e7          	jalr	816(ra) # 3e2 <close>
    close(pipes2[0]);
  ba:	fd042503          	lw	a0,-48(s0)
  be:	00000097          	auipc	ra,0x0
  c2:	324080e7          	jalr	804(ra) # 3e2 <close>
    read(pipes1[0], buf, 1);
  c6:	4605                	li	a2,1
  c8:	fc840593          	addi	a1,s0,-56
  cc:	fd842503          	lw	a0,-40(s0)
  d0:	00000097          	auipc	ra,0x0
  d4:	302080e7          	jalr	770(ra) # 3d2 <read>
    printf("%d: received ping\n", pid);
  d8:	85a6                	mv	a1,s1
  da:	00000517          	auipc	a0,0x0
  de:	7fe50513          	addi	a0,a0,2046 # 8d8 <malloc+0xe6>
  e2:	00000097          	auipc	ra,0x0
  e6:	650080e7          	jalr	1616(ra) # 732 <printf>
    buf[0]='0';
  ea:	03000793          	li	a5,48
  ee:	fcf40423          	sb	a5,-56(s0)
    write(pipes2[1], buf, 1);
  f2:	4605                	li	a2,1
  f4:	fc840593          	addi	a1,s0,-56
  f8:	fd442503          	lw	a0,-44(s0)
  fc:	00000097          	auipc	ra,0x0
 100:	2de080e7          	jalr	734(ra) # 3da <write>
    exit(0);
 104:	4501                	li	a0,0
 106:	00000097          	auipc	ra,0x0
 10a:	2b4080e7          	jalr	692(ra) # 3ba <exit>
    fprintf(2, "Failed to create a child process\n");
 10e:	00000597          	auipc	a1,0x0
 112:	7e258593          	addi	a1,a1,2018 # 8f0 <malloc+0xfe>
 116:	4509                	li	a0,2
 118:	00000097          	auipc	ra,0x0
 11c:	5ec080e7          	jalr	1516(ra) # 704 <fprintf>
    exit(1);
 120:	4505                	li	a0,1
 122:	00000097          	auipc	ra,0x0
 126:	298080e7          	jalr	664(ra) # 3ba <exit>

000000000000012a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 12a:	1141                	addi	sp,sp,-16
 12c:	e422                	sd	s0,8(sp)
 12e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 130:	87aa                	mv	a5,a0
 132:	0585                	addi	a1,a1,1
 134:	0785                	addi	a5,a5,1
 136:	fff5c703          	lbu	a4,-1(a1)
 13a:	fee78fa3          	sb	a4,-1(a5)
 13e:	fb75                	bnez	a4,132 <strcpy+0x8>
    ;
  return os;
}
 140:	6422                	ld	s0,8(sp)
 142:	0141                	addi	sp,sp,16
 144:	8082                	ret

0000000000000146 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 146:	1141                	addi	sp,sp,-16
 148:	e422                	sd	s0,8(sp)
 14a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 14c:	00054783          	lbu	a5,0(a0)
 150:	cf91                	beqz	a5,16c <strcmp+0x26>
 152:	0005c703          	lbu	a4,0(a1)
 156:	00f71b63          	bne	a4,a5,16c <strcmp+0x26>
    p++, q++;
 15a:	0505                	addi	a0,a0,1
 15c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 15e:	00054783          	lbu	a5,0(a0)
 162:	c789                	beqz	a5,16c <strcmp+0x26>
 164:	0005c703          	lbu	a4,0(a1)
 168:	fef709e3          	beq	a4,a5,15a <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 16c:	0005c503          	lbu	a0,0(a1)
}
 170:	40a7853b          	subw	a0,a5,a0
 174:	6422                	ld	s0,8(sp)
 176:	0141                	addi	sp,sp,16
 178:	8082                	ret

000000000000017a <strlen>:

uint
strlen(const char *s)
{
 17a:	1141                	addi	sp,sp,-16
 17c:	e422                	sd	s0,8(sp)
 17e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 180:	00054783          	lbu	a5,0(a0)
 184:	cf91                	beqz	a5,1a0 <strlen+0x26>
 186:	0505                	addi	a0,a0,1
 188:	87aa                	mv	a5,a0
 18a:	4685                	li	a3,1
 18c:	9e89                	subw	a3,a3,a0
 18e:	00f6853b          	addw	a0,a3,a5
 192:	0785                	addi	a5,a5,1
 194:	fff7c703          	lbu	a4,-1(a5)
 198:	fb7d                	bnez	a4,18e <strlen+0x14>
    ;
  return n;
}
 19a:	6422                	ld	s0,8(sp)
 19c:	0141                	addi	sp,sp,16
 19e:	8082                	ret
  for(n = 0; s[n]; n++)
 1a0:	4501                	li	a0,0
 1a2:	bfe5                	j	19a <strlen+0x20>

00000000000001a4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1aa:	ce09                	beqz	a2,1c4 <memset+0x20>
 1ac:	87aa                	mv	a5,a0
 1ae:	fff6071b          	addiw	a4,a2,-1
 1b2:	1702                	slli	a4,a4,0x20
 1b4:	9301                	srli	a4,a4,0x20
 1b6:	0705                	addi	a4,a4,1
 1b8:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1ba:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1be:	0785                	addi	a5,a5,1
 1c0:	fee79de3          	bne	a5,a4,1ba <memset+0x16>
  }
  return dst;
}
 1c4:	6422                	ld	s0,8(sp)
 1c6:	0141                	addi	sp,sp,16
 1c8:	8082                	ret

00000000000001ca <strchr>:

char*
strchr(const char *s, char c)
{
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e422                	sd	s0,8(sp)
 1ce:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1d0:	00054783          	lbu	a5,0(a0)
 1d4:	cf91                	beqz	a5,1f0 <strchr+0x26>
    if(*s == c)
 1d6:	00f58a63          	beq	a1,a5,1ea <strchr+0x20>
  for(; *s; s++)
 1da:	0505                	addi	a0,a0,1
 1dc:	00054783          	lbu	a5,0(a0)
 1e0:	c781                	beqz	a5,1e8 <strchr+0x1e>
    if(*s == c)
 1e2:	feb79ce3          	bne	a5,a1,1da <strchr+0x10>
 1e6:	a011                	j	1ea <strchr+0x20>
      return (char*)s;
  return 0;
 1e8:	4501                	li	a0,0
}
 1ea:	6422                	ld	s0,8(sp)
 1ec:	0141                	addi	sp,sp,16
 1ee:	8082                	ret
  return 0;
 1f0:	4501                	li	a0,0
 1f2:	bfe5                	j	1ea <strchr+0x20>

00000000000001f4 <gets>:

char*
gets(char *buf, int max)
{
 1f4:	711d                	addi	sp,sp,-96
 1f6:	ec86                	sd	ra,88(sp)
 1f8:	e8a2                	sd	s0,80(sp)
 1fa:	e4a6                	sd	s1,72(sp)
 1fc:	e0ca                	sd	s2,64(sp)
 1fe:	fc4e                	sd	s3,56(sp)
 200:	f852                	sd	s4,48(sp)
 202:	f456                	sd	s5,40(sp)
 204:	f05a                	sd	s6,32(sp)
 206:	ec5e                	sd	s7,24(sp)
 208:	1080                	addi	s0,sp,96
 20a:	8baa                	mv	s7,a0
 20c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20e:	892a                	mv	s2,a0
 210:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 212:	4aa9                	li	s5,10
 214:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 216:	0019849b          	addiw	s1,s3,1
 21a:	0344d863          	ble	s4,s1,24a <gets+0x56>
    cc = read(0, &c, 1);
 21e:	4605                	li	a2,1
 220:	faf40593          	addi	a1,s0,-81
 224:	4501                	li	a0,0
 226:	00000097          	auipc	ra,0x0
 22a:	1ac080e7          	jalr	428(ra) # 3d2 <read>
    if(cc < 1)
 22e:	00a05e63          	blez	a0,24a <gets+0x56>
    buf[i++] = c;
 232:	faf44783          	lbu	a5,-81(s0)
 236:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 23a:	01578763          	beq	a5,s5,248 <gets+0x54>
 23e:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 240:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 242:	fd679ae3          	bne	a5,s6,216 <gets+0x22>
 246:	a011                	j	24a <gets+0x56>
  for(i=0; i+1 < max; ){
 248:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 24a:	99de                	add	s3,s3,s7
 24c:	00098023          	sb	zero,0(s3)
  return buf;
}
 250:	855e                	mv	a0,s7
 252:	60e6                	ld	ra,88(sp)
 254:	6446                	ld	s0,80(sp)
 256:	64a6                	ld	s1,72(sp)
 258:	6906                	ld	s2,64(sp)
 25a:	79e2                	ld	s3,56(sp)
 25c:	7a42                	ld	s4,48(sp)
 25e:	7aa2                	ld	s5,40(sp)
 260:	7b02                	ld	s6,32(sp)
 262:	6be2                	ld	s7,24(sp)
 264:	6125                	addi	sp,sp,96
 266:	8082                	ret

0000000000000268 <stat>:

int
stat(const char *n, struct stat *st)
{
 268:	1101                	addi	sp,sp,-32
 26a:	ec06                	sd	ra,24(sp)
 26c:	e822                	sd	s0,16(sp)
 26e:	e426                	sd	s1,8(sp)
 270:	e04a                	sd	s2,0(sp)
 272:	1000                	addi	s0,sp,32
 274:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 276:	4581                	li	a1,0
 278:	00000097          	auipc	ra,0x0
 27c:	182080e7          	jalr	386(ra) # 3fa <open>
  if(fd < 0)
 280:	02054563          	bltz	a0,2aa <stat+0x42>
 284:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 286:	85ca                	mv	a1,s2
 288:	00000097          	auipc	ra,0x0
 28c:	18a080e7          	jalr	394(ra) # 412 <fstat>
 290:	892a                	mv	s2,a0
  close(fd);
 292:	8526                	mv	a0,s1
 294:	00000097          	auipc	ra,0x0
 298:	14e080e7          	jalr	334(ra) # 3e2 <close>
  return r;
}
 29c:	854a                	mv	a0,s2
 29e:	60e2                	ld	ra,24(sp)
 2a0:	6442                	ld	s0,16(sp)
 2a2:	64a2                	ld	s1,8(sp)
 2a4:	6902                	ld	s2,0(sp)
 2a6:	6105                	addi	sp,sp,32
 2a8:	8082                	ret
    return -1;
 2aa:	597d                	li	s2,-1
 2ac:	bfc5                	j	29c <stat+0x34>

00000000000002ae <atoi>:

int
atoi(const char *s)
{
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e422                	sd	s0,8(sp)
 2b2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b4:	00054683          	lbu	a3,0(a0)
 2b8:	fd06879b          	addiw	a5,a3,-48
 2bc:	0ff7f793          	andi	a5,a5,255
 2c0:	4725                	li	a4,9
 2c2:	02f76963          	bltu	a4,a5,2f4 <atoi+0x46>
 2c6:	862a                	mv	a2,a0
  n = 0;
 2c8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2ca:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2cc:	0605                	addi	a2,a2,1
 2ce:	0025179b          	slliw	a5,a0,0x2
 2d2:	9fa9                	addw	a5,a5,a0
 2d4:	0017979b          	slliw	a5,a5,0x1
 2d8:	9fb5                	addw	a5,a5,a3
 2da:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2de:	00064683          	lbu	a3,0(a2)
 2e2:	fd06871b          	addiw	a4,a3,-48
 2e6:	0ff77713          	andi	a4,a4,255
 2ea:	fee5f1e3          	bleu	a4,a1,2cc <atoi+0x1e>
  return n;
}
 2ee:	6422                	ld	s0,8(sp)
 2f0:	0141                	addi	sp,sp,16
 2f2:	8082                	ret
  n = 0;
 2f4:	4501                	li	a0,0
 2f6:	bfe5                	j	2ee <atoi+0x40>

00000000000002f8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e422                	sd	s0,8(sp)
 2fc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2fe:	02b57663          	bleu	a1,a0,32a <memmove+0x32>
    while(n-- > 0)
 302:	02c05163          	blez	a2,324 <memmove+0x2c>
 306:	fff6079b          	addiw	a5,a2,-1
 30a:	1782                	slli	a5,a5,0x20
 30c:	9381                	srli	a5,a5,0x20
 30e:	0785                	addi	a5,a5,1
 310:	97aa                	add	a5,a5,a0
  dst = vdst;
 312:	872a                	mv	a4,a0
      *dst++ = *src++;
 314:	0585                	addi	a1,a1,1
 316:	0705                	addi	a4,a4,1
 318:	fff5c683          	lbu	a3,-1(a1)
 31c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 320:	fee79ae3          	bne	a5,a4,314 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 324:	6422                	ld	s0,8(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret
    dst += n;
 32a:	00c50733          	add	a4,a0,a2
    src += n;
 32e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 330:	fec05ae3          	blez	a2,324 <memmove+0x2c>
 334:	fff6079b          	addiw	a5,a2,-1
 338:	1782                	slli	a5,a5,0x20
 33a:	9381                	srli	a5,a5,0x20
 33c:	fff7c793          	not	a5,a5
 340:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 342:	15fd                	addi	a1,a1,-1
 344:	177d                	addi	a4,a4,-1
 346:	0005c683          	lbu	a3,0(a1)
 34a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 34e:	fef71ae3          	bne	a4,a5,342 <memmove+0x4a>
 352:	bfc9                	j	324 <memmove+0x2c>

0000000000000354 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 354:	1141                	addi	sp,sp,-16
 356:	e422                	sd	s0,8(sp)
 358:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 35a:	ce15                	beqz	a2,396 <memcmp+0x42>
 35c:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 360:	00054783          	lbu	a5,0(a0)
 364:	0005c703          	lbu	a4,0(a1)
 368:	02e79063          	bne	a5,a4,388 <memcmp+0x34>
 36c:	1682                	slli	a3,a3,0x20
 36e:	9281                	srli	a3,a3,0x20
 370:	0685                	addi	a3,a3,1
 372:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 374:	0505                	addi	a0,a0,1
    p2++;
 376:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 378:	00d50d63          	beq	a0,a3,392 <memcmp+0x3e>
    if (*p1 != *p2) {
 37c:	00054783          	lbu	a5,0(a0)
 380:	0005c703          	lbu	a4,0(a1)
 384:	fee788e3          	beq	a5,a4,374 <memcmp+0x20>
      return *p1 - *p2;
 388:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 38c:	6422                	ld	s0,8(sp)
 38e:	0141                	addi	sp,sp,16
 390:	8082                	ret
  return 0;
 392:	4501                	li	a0,0
 394:	bfe5                	j	38c <memcmp+0x38>
 396:	4501                	li	a0,0
 398:	bfd5                	j	38c <memcmp+0x38>

000000000000039a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 39a:	1141                	addi	sp,sp,-16
 39c:	e406                	sd	ra,8(sp)
 39e:	e022                	sd	s0,0(sp)
 3a0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3a2:	00000097          	auipc	ra,0x0
 3a6:	f56080e7          	jalr	-170(ra) # 2f8 <memmove>
}
 3aa:	60a2                	ld	ra,8(sp)
 3ac:	6402                	ld	s0,0(sp)
 3ae:	0141                	addi	sp,sp,16
 3b0:	8082                	ret

00000000000003b2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3b2:	4885                	li	a7,1
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ba:	4889                	li	a7,2
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3c2:	488d                	li	a7,3
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ca:	4891                	li	a7,4
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <read>:
.global read
read:
 li a7, SYS_read
 3d2:	4895                	li	a7,5
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <write>:
.global write
write:
 li a7, SYS_write
 3da:	48c1                	li	a7,16
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <close>:
.global close
close:
 li a7, SYS_close
 3e2:	48d5                	li	a7,21
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ea:	4899                	li	a7,6
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3f2:	489d                	li	a7,7
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <open>:
.global open
open:
 li a7, SYS_open
 3fa:	48bd                	li	a7,15
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 402:	48c5                	li	a7,17
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 40a:	48c9                	li	a7,18
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 412:	48a1                	li	a7,8
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <link>:
.global link
link:
 li a7, SYS_link
 41a:	48cd                	li	a7,19
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 422:	48d1                	li	a7,20
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 42a:	48a5                	li	a7,9
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <dup>:
.global dup
dup:
 li a7, SYS_dup
 432:	48a9                	li	a7,10
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 43a:	48ad                	li	a7,11
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 442:	48b1                	li	a7,12
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 44a:	48b5                	li	a7,13
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 452:	48b9                	li	a7,14
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 45a:	1101                	addi	sp,sp,-32
 45c:	ec06                	sd	ra,24(sp)
 45e:	e822                	sd	s0,16(sp)
 460:	1000                	addi	s0,sp,32
 462:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 466:	4605                	li	a2,1
 468:	fef40593          	addi	a1,s0,-17
 46c:	00000097          	auipc	ra,0x0
 470:	f6e080e7          	jalr	-146(ra) # 3da <write>
}
 474:	60e2                	ld	ra,24(sp)
 476:	6442                	ld	s0,16(sp)
 478:	6105                	addi	sp,sp,32
 47a:	8082                	ret

000000000000047c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 47c:	7139                	addi	sp,sp,-64
 47e:	fc06                	sd	ra,56(sp)
 480:	f822                	sd	s0,48(sp)
 482:	f426                	sd	s1,40(sp)
 484:	f04a                	sd	s2,32(sp)
 486:	ec4e                	sd	s3,24(sp)
 488:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 48a:	c299                	beqz	a3,490 <printint+0x14>
 48c:	0005cd63          	bltz	a1,4a6 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 490:	2581                	sext.w	a1,a1
  neg = 0;
 492:	4301                	li	t1,0
 494:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 498:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 49a:	2601                	sext.w	a2,a2
 49c:	00000897          	auipc	a7,0x0
 4a0:	49488893          	addi	a7,a7,1172 # 930 <digits>
 4a4:	a801                	j	4b4 <printint+0x38>
    x = -xx;
 4a6:	40b005bb          	negw	a1,a1
 4aa:	2581                	sext.w	a1,a1
    neg = 1;
 4ac:	4305                	li	t1,1
    x = -xx;
 4ae:	b7dd                	j	494 <printint+0x18>
  }while((x /= base) != 0);
 4b0:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 4b2:	8836                	mv	a6,a3
 4b4:	0018069b          	addiw	a3,a6,1
 4b8:	02c5f7bb          	remuw	a5,a1,a2
 4bc:	1782                	slli	a5,a5,0x20
 4be:	9381                	srli	a5,a5,0x20
 4c0:	97c6                	add	a5,a5,a7
 4c2:	0007c783          	lbu	a5,0(a5)
 4c6:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 4ca:	0705                	addi	a4,a4,1
 4cc:	02c5d7bb          	divuw	a5,a1,a2
 4d0:	fec5f0e3          	bleu	a2,a1,4b0 <printint+0x34>
  if(neg)
 4d4:	00030b63          	beqz	t1,4ea <printint+0x6e>
    buf[i++] = '-';
 4d8:	fd040793          	addi	a5,s0,-48
 4dc:	96be                	add	a3,a3,a5
 4de:	02d00793          	li	a5,45
 4e2:	fef68823          	sb	a5,-16(a3)
 4e6:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 4ea:	02d05963          	blez	a3,51c <printint+0xa0>
 4ee:	89aa                	mv	s3,a0
 4f0:	fc040793          	addi	a5,s0,-64
 4f4:	00d784b3          	add	s1,a5,a3
 4f8:	fff78913          	addi	s2,a5,-1
 4fc:	9936                	add	s2,s2,a3
 4fe:	36fd                	addiw	a3,a3,-1
 500:	1682                	slli	a3,a3,0x20
 502:	9281                	srli	a3,a3,0x20
 504:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 508:	fff4c583          	lbu	a1,-1(s1)
 50c:	854e                	mv	a0,s3
 50e:	00000097          	auipc	ra,0x0
 512:	f4c080e7          	jalr	-180(ra) # 45a <putc>
  while(--i >= 0)
 516:	14fd                	addi	s1,s1,-1
 518:	ff2498e3          	bne	s1,s2,508 <printint+0x8c>
}
 51c:	70e2                	ld	ra,56(sp)
 51e:	7442                	ld	s0,48(sp)
 520:	74a2                	ld	s1,40(sp)
 522:	7902                	ld	s2,32(sp)
 524:	69e2                	ld	s3,24(sp)
 526:	6121                	addi	sp,sp,64
 528:	8082                	ret

000000000000052a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 52a:	7119                	addi	sp,sp,-128
 52c:	fc86                	sd	ra,120(sp)
 52e:	f8a2                	sd	s0,112(sp)
 530:	f4a6                	sd	s1,104(sp)
 532:	f0ca                	sd	s2,96(sp)
 534:	ecce                	sd	s3,88(sp)
 536:	e8d2                	sd	s4,80(sp)
 538:	e4d6                	sd	s5,72(sp)
 53a:	e0da                	sd	s6,64(sp)
 53c:	fc5e                	sd	s7,56(sp)
 53e:	f862                	sd	s8,48(sp)
 540:	f466                	sd	s9,40(sp)
 542:	f06a                	sd	s10,32(sp)
 544:	ec6e                	sd	s11,24(sp)
 546:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 548:	0005c483          	lbu	s1,0(a1)
 54c:	18048d63          	beqz	s1,6e6 <vprintf+0x1bc>
 550:	8aaa                	mv	s5,a0
 552:	8b32                	mv	s6,a2
 554:	00158913          	addi	s2,a1,1
  state = 0;
 558:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 55a:	02500a13          	li	s4,37
      if(c == 'd'){
 55e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 562:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 566:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 56a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 56e:	00000b97          	auipc	s7,0x0
 572:	3c2b8b93          	addi	s7,s7,962 # 930 <digits>
 576:	a839                	j	594 <vprintf+0x6a>
        putc(fd, c);
 578:	85a6                	mv	a1,s1
 57a:	8556                	mv	a0,s5
 57c:	00000097          	auipc	ra,0x0
 580:	ede080e7          	jalr	-290(ra) # 45a <putc>
 584:	a019                	j	58a <vprintf+0x60>
    } else if(state == '%'){
 586:	01498f63          	beq	s3,s4,5a4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 58a:	0905                	addi	s2,s2,1
 58c:	fff94483          	lbu	s1,-1(s2)
 590:	14048b63          	beqz	s1,6e6 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 594:	0004879b          	sext.w	a5,s1
    if(state == 0){
 598:	fe0997e3          	bnez	s3,586 <vprintf+0x5c>
      if(c == '%'){
 59c:	fd479ee3          	bne	a5,s4,578 <vprintf+0x4e>
        state = '%';
 5a0:	89be                	mv	s3,a5
 5a2:	b7e5                	j	58a <vprintf+0x60>
      if(c == 'd'){
 5a4:	05878063          	beq	a5,s8,5e4 <vprintf+0xba>
      } else if(c == 'l') {
 5a8:	05978c63          	beq	a5,s9,600 <vprintf+0xd6>
      } else if(c == 'x') {
 5ac:	07a78863          	beq	a5,s10,61c <vprintf+0xf2>
      } else if(c == 'p') {
 5b0:	09b78463          	beq	a5,s11,638 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5b4:	07300713          	li	a4,115
 5b8:	0ce78563          	beq	a5,a4,682 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5bc:	06300713          	li	a4,99
 5c0:	0ee78c63          	beq	a5,a4,6b8 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5c4:	11478663          	beq	a5,s4,6d0 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5c8:	85d2                	mv	a1,s4
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	e8e080e7          	jalr	-370(ra) # 45a <putc>
        putc(fd, c);
 5d4:	85a6                	mv	a1,s1
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	e82080e7          	jalr	-382(ra) # 45a <putc>
      }
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	b765                	j	58a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5e4:	008b0493          	addi	s1,s6,8
 5e8:	4685                	li	a3,1
 5ea:	4629                	li	a2,10
 5ec:	000b2583          	lw	a1,0(s6)
 5f0:	8556                	mv	a0,s5
 5f2:	00000097          	auipc	ra,0x0
 5f6:	e8a080e7          	jalr	-374(ra) # 47c <printint>
 5fa:	8b26                	mv	s6,s1
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	b771                	j	58a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 600:	008b0493          	addi	s1,s6,8
 604:	4681                	li	a3,0
 606:	4629                	li	a2,10
 608:	000b2583          	lw	a1,0(s6)
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	e6e080e7          	jalr	-402(ra) # 47c <printint>
 616:	8b26                	mv	s6,s1
      state = 0;
 618:	4981                	li	s3,0
 61a:	bf85                	j	58a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 61c:	008b0493          	addi	s1,s6,8
 620:	4681                	li	a3,0
 622:	4641                	li	a2,16
 624:	000b2583          	lw	a1,0(s6)
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	e52080e7          	jalr	-430(ra) # 47c <printint>
 632:	8b26                	mv	s6,s1
      state = 0;
 634:	4981                	li	s3,0
 636:	bf91                	j	58a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 638:	008b0793          	addi	a5,s6,8
 63c:	f8f43423          	sd	a5,-120(s0)
 640:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 644:	03000593          	li	a1,48
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	e10080e7          	jalr	-496(ra) # 45a <putc>
  putc(fd, 'x');
 652:	85ea                	mv	a1,s10
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	e04080e7          	jalr	-508(ra) # 45a <putc>
 65e:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 660:	03c9d793          	srli	a5,s3,0x3c
 664:	97de                	add	a5,a5,s7
 666:	0007c583          	lbu	a1,0(a5)
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	dee080e7          	jalr	-530(ra) # 45a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 674:	0992                	slli	s3,s3,0x4
 676:	34fd                	addiw	s1,s1,-1
 678:	f4e5                	bnez	s1,660 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 67a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 67e:	4981                	li	s3,0
 680:	b729                	j	58a <vprintf+0x60>
        s = va_arg(ap, char*);
 682:	008b0993          	addi	s3,s6,8
 686:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 68a:	c085                	beqz	s1,6aa <vprintf+0x180>
        while(*s != 0){
 68c:	0004c583          	lbu	a1,0(s1)
 690:	c9a1                	beqz	a1,6e0 <vprintf+0x1b6>
          putc(fd, *s);
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	dc6080e7          	jalr	-570(ra) # 45a <putc>
          s++;
 69c:	0485                	addi	s1,s1,1
        while(*s != 0){
 69e:	0004c583          	lbu	a1,0(s1)
 6a2:	f9e5                	bnez	a1,692 <vprintf+0x168>
        s = va_arg(ap, char*);
 6a4:	8b4e                	mv	s6,s3
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	b5cd                	j	58a <vprintf+0x60>
          s = "(null)";
 6aa:	00000497          	auipc	s1,0x0
 6ae:	29e48493          	addi	s1,s1,670 # 948 <digits+0x18>
        while(*s != 0){
 6b2:	02800593          	li	a1,40
 6b6:	bff1                	j	692 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 6b8:	008b0493          	addi	s1,s6,8
 6bc:	000b4583          	lbu	a1,0(s6)
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	d98080e7          	jalr	-616(ra) # 45a <putc>
 6ca:	8b26                	mv	s6,s1
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	bd75                	j	58a <vprintf+0x60>
        putc(fd, c);
 6d0:	85d2                	mv	a1,s4
 6d2:	8556                	mv	a0,s5
 6d4:	00000097          	auipc	ra,0x0
 6d8:	d86080e7          	jalr	-634(ra) # 45a <putc>
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	b575                	j	58a <vprintf+0x60>
        s = va_arg(ap, char*);
 6e0:	8b4e                	mv	s6,s3
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	b55d                	j	58a <vprintf+0x60>
    }
  }
}
 6e6:	70e6                	ld	ra,120(sp)
 6e8:	7446                	ld	s0,112(sp)
 6ea:	74a6                	ld	s1,104(sp)
 6ec:	7906                	ld	s2,96(sp)
 6ee:	69e6                	ld	s3,88(sp)
 6f0:	6a46                	ld	s4,80(sp)
 6f2:	6aa6                	ld	s5,72(sp)
 6f4:	6b06                	ld	s6,64(sp)
 6f6:	7be2                	ld	s7,56(sp)
 6f8:	7c42                	ld	s8,48(sp)
 6fa:	7ca2                	ld	s9,40(sp)
 6fc:	7d02                	ld	s10,32(sp)
 6fe:	6de2                	ld	s11,24(sp)
 700:	6109                	addi	sp,sp,128
 702:	8082                	ret

0000000000000704 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 704:	715d                	addi	sp,sp,-80
 706:	ec06                	sd	ra,24(sp)
 708:	e822                	sd	s0,16(sp)
 70a:	1000                	addi	s0,sp,32
 70c:	e010                	sd	a2,0(s0)
 70e:	e414                	sd	a3,8(s0)
 710:	e818                	sd	a4,16(s0)
 712:	ec1c                	sd	a5,24(s0)
 714:	03043023          	sd	a6,32(s0)
 718:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 71c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 720:	8622                	mv	a2,s0
 722:	00000097          	auipc	ra,0x0
 726:	e08080e7          	jalr	-504(ra) # 52a <vprintf>
}
 72a:	60e2                	ld	ra,24(sp)
 72c:	6442                	ld	s0,16(sp)
 72e:	6161                	addi	sp,sp,80
 730:	8082                	ret

0000000000000732 <printf>:

void
printf(const char *fmt, ...)
{
 732:	711d                	addi	sp,sp,-96
 734:	ec06                	sd	ra,24(sp)
 736:	e822                	sd	s0,16(sp)
 738:	1000                	addi	s0,sp,32
 73a:	e40c                	sd	a1,8(s0)
 73c:	e810                	sd	a2,16(s0)
 73e:	ec14                	sd	a3,24(s0)
 740:	f018                	sd	a4,32(s0)
 742:	f41c                	sd	a5,40(s0)
 744:	03043823          	sd	a6,48(s0)
 748:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 74c:	00840613          	addi	a2,s0,8
 750:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 754:	85aa                	mv	a1,a0
 756:	4505                	li	a0,1
 758:	00000097          	auipc	ra,0x0
 75c:	dd2080e7          	jalr	-558(ra) # 52a <vprintf>
}
 760:	60e2                	ld	ra,24(sp)
 762:	6442                	ld	s0,16(sp)
 764:	6125                	addi	sp,sp,96
 766:	8082                	ret

0000000000000768 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 768:	1141                	addi	sp,sp,-16
 76a:	e422                	sd	s0,8(sp)
 76c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 772:	00000797          	auipc	a5,0x0
 776:	1de78793          	addi	a5,a5,478 # 950 <__bss_start>
 77a:	639c                	ld	a5,0(a5)
 77c:	a805                	j	7ac <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 77e:	4618                	lw	a4,8(a2)
 780:	9db9                	addw	a1,a1,a4
 782:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 786:	6398                	ld	a4,0(a5)
 788:	6318                	ld	a4,0(a4)
 78a:	fee53823          	sd	a4,-16(a0)
 78e:	a091                	j	7d2 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 790:	ff852703          	lw	a4,-8(a0)
 794:	9e39                	addw	a2,a2,a4
 796:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 798:	ff053703          	ld	a4,-16(a0)
 79c:	e398                	sd	a4,0(a5)
 79e:	a099                	j	7e4 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a0:	6398                	ld	a4,0(a5)
 7a2:	00e7e463          	bltu	a5,a4,7aa <free+0x42>
 7a6:	00e6ea63          	bltu	a3,a4,7ba <free+0x52>
{
 7aa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ac:	fed7fae3          	bleu	a3,a5,7a0 <free+0x38>
 7b0:	6398                	ld	a4,0(a5)
 7b2:	00e6e463          	bltu	a3,a4,7ba <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b6:	fee7eae3          	bltu	a5,a4,7aa <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 7ba:	ff852583          	lw	a1,-8(a0)
 7be:	6390                	ld	a2,0(a5)
 7c0:	02059713          	slli	a4,a1,0x20
 7c4:	9301                	srli	a4,a4,0x20
 7c6:	0712                	slli	a4,a4,0x4
 7c8:	9736                	add	a4,a4,a3
 7ca:	fae60ae3          	beq	a2,a4,77e <free+0x16>
    bp->s.ptr = p->s.ptr;
 7ce:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7d2:	4790                	lw	a2,8(a5)
 7d4:	02061713          	slli	a4,a2,0x20
 7d8:	9301                	srli	a4,a4,0x20
 7da:	0712                	slli	a4,a4,0x4
 7dc:	973e                	add	a4,a4,a5
 7de:	fae689e3          	beq	a3,a4,790 <free+0x28>
  } else
    p->s.ptr = bp;
 7e2:	e394                	sd	a3,0(a5)
  freep = p;
 7e4:	00000717          	auipc	a4,0x0
 7e8:	16f73623          	sd	a5,364(a4) # 950 <__bss_start>
}
 7ec:	6422                	ld	s0,8(sp)
 7ee:	0141                	addi	sp,sp,16
 7f0:	8082                	ret

00000000000007f2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7f2:	7139                	addi	sp,sp,-64
 7f4:	fc06                	sd	ra,56(sp)
 7f6:	f822                	sd	s0,48(sp)
 7f8:	f426                	sd	s1,40(sp)
 7fa:	f04a                	sd	s2,32(sp)
 7fc:	ec4e                	sd	s3,24(sp)
 7fe:	e852                	sd	s4,16(sp)
 800:	e456                	sd	s5,8(sp)
 802:	e05a                	sd	s6,0(sp)
 804:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 806:	02051993          	slli	s3,a0,0x20
 80a:	0209d993          	srli	s3,s3,0x20
 80e:	09bd                	addi	s3,s3,15
 810:	0049d993          	srli	s3,s3,0x4
 814:	2985                	addiw	s3,s3,1
 816:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 81a:	00000797          	auipc	a5,0x0
 81e:	13678793          	addi	a5,a5,310 # 950 <__bss_start>
 822:	6388                	ld	a0,0(a5)
 824:	c515                	beqz	a0,850 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 826:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 828:	4798                	lw	a4,8(a5)
 82a:	03277f63          	bleu	s2,a4,868 <malloc+0x76>
 82e:	8a4e                	mv	s4,s3
 830:	0009871b          	sext.w	a4,s3
 834:	6685                	lui	a3,0x1
 836:	00d77363          	bleu	a3,a4,83c <malloc+0x4a>
 83a:	6a05                	lui	s4,0x1
 83c:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 840:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 844:	00000497          	auipc	s1,0x0
 848:	10c48493          	addi	s1,s1,268 # 950 <__bss_start>
  if(p == (char*)-1)
 84c:	5b7d                	li	s6,-1
 84e:	a885                	j	8be <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 850:	00000797          	auipc	a5,0x0
 854:	10878793          	addi	a5,a5,264 # 958 <base>
 858:	00000717          	auipc	a4,0x0
 85c:	0ef73c23          	sd	a5,248(a4) # 950 <__bss_start>
 860:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 862:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 866:	b7e1                	j	82e <malloc+0x3c>
      if(p->s.size == nunits)
 868:	02e90b63          	beq	s2,a4,89e <malloc+0xac>
        p->s.size -= nunits;
 86c:	4137073b          	subw	a4,a4,s3
 870:	c798                	sw	a4,8(a5)
        p += p->s.size;
 872:	1702                	slli	a4,a4,0x20
 874:	9301                	srli	a4,a4,0x20
 876:	0712                	slli	a4,a4,0x4
 878:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 87a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 87e:	00000717          	auipc	a4,0x0
 882:	0ca73923          	sd	a0,210(a4) # 950 <__bss_start>
      return (void*)(p + 1);
 886:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 88a:	70e2                	ld	ra,56(sp)
 88c:	7442                	ld	s0,48(sp)
 88e:	74a2                	ld	s1,40(sp)
 890:	7902                	ld	s2,32(sp)
 892:	69e2                	ld	s3,24(sp)
 894:	6a42                	ld	s4,16(sp)
 896:	6aa2                	ld	s5,8(sp)
 898:	6b02                	ld	s6,0(sp)
 89a:	6121                	addi	sp,sp,64
 89c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 89e:	6398                	ld	a4,0(a5)
 8a0:	e118                	sd	a4,0(a0)
 8a2:	bff1                	j	87e <malloc+0x8c>
  hp->s.size = nu;
 8a4:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 8a8:	0541                	addi	a0,a0,16
 8aa:	00000097          	auipc	ra,0x0
 8ae:	ebe080e7          	jalr	-322(ra) # 768 <free>
  return freep;
 8b2:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8b4:	d979                	beqz	a0,88a <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b8:	4798                	lw	a4,8(a5)
 8ba:	fb2777e3          	bleu	s2,a4,868 <malloc+0x76>
    if(p == freep)
 8be:	6098                	ld	a4,0(s1)
 8c0:	853e                	mv	a0,a5
 8c2:	fef71ae3          	bne	a4,a5,8b6 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 8c6:	8552                	mv	a0,s4
 8c8:	00000097          	auipc	ra,0x0
 8cc:	b7a080e7          	jalr	-1158(ra) # 442 <sbrk>
  if(p == (char*)-1)
 8d0:	fd651ae3          	bne	a0,s6,8a4 <malloc+0xb2>
        return 0;
 8d4:	4501                	li	a0,0
 8d6:	bf55                	j	88a <malloc+0x98>
