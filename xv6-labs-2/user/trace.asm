
user/_trace：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	712d                	addi	sp,sp,-288
   2:	ee06                	sd	ra,280(sp)
   4:	ea22                	sd	s0,272(sp)
   6:	e626                	sd	s1,264(sp)
   8:	e24a                	sd	s2,256(sp)
   a:	1200                	addi	s0,sp,288
   c:	892e                	mv	s2,a1
  int i;
  char *nargv[MAXARG];

  if(argc < 3 || (argv[1][0] < '0' || argv[1][0] > '9')){
   e:	4789                	li	a5,2
  10:	00a7dd63          	ble	a0,a5,2a <main+0x2a>
  14:	84aa                	mv	s1,a0
  16:	6588                	ld	a0,8(a1)
  18:	00054783          	lbu	a5,0(a0)
  1c:	fd07879b          	addiw	a5,a5,-48
  20:	0ff7f793          	andi	a5,a5,255
  24:	4725                	li	a4,9
  26:	02f77263          	bleu	a5,a4,4a <main+0x4a>
    fprintf(2, "Usage: %s mask command\n", argv[0]);
  2a:	00093603          	ld	a2,0(s2)
  2e:	00001597          	auipc	a1,0x1
  32:	85258593          	addi	a1,a1,-1966 # 880 <malloc+0xe8>
  36:	4509                	li	a0,2
  38:	00000097          	auipc	ra,0x0
  3c:	672080e7          	jalr	1650(ra) # 6aa <fprintf>
    exit(1);
  40:	4505                	li	a0,1
  42:	00000097          	auipc	ra,0x0
  46:	30e080e7          	jalr	782(ra) # 350 <exit>
  }

  if (trace(atoi(argv[1])) < 0) {
  4a:	00000097          	auipc	ra,0x0
  4e:	1fa080e7          	jalr	506(ra) # 244 <atoi>
  52:	00000097          	auipc	ra,0x0
  56:	39e080e7          	jalr	926(ra) # 3f0 <trace>
  5a:	04054363          	bltz	a0,a0 <main+0xa0>
  5e:	01090793          	addi	a5,s2,16
  62:	ee040713          	addi	a4,s0,-288
  66:	ffd4869b          	addiw	a3,s1,-3
  6a:	1682                	slli	a3,a3,0x20
  6c:	9281                	srli	a3,a3,0x20
  6e:	068e                	slli	a3,a3,0x3
  70:	96be                	add	a3,a3,a5
  72:	10090913          	addi	s2,s2,256
    fprintf(2, "%s: trace failed\n", argv[0]);
    exit(1);
  }
  
  for(i = 2; i < argc && i < MAXARG; i++){
    nargv[i-2] = argv[i];
  76:	6390                	ld	a2,0(a5)
  78:	e310                	sd	a2,0(a4)
  for(i = 2; i < argc && i < MAXARG; i++){
  7a:	00d78663          	beq	a5,a3,86 <main+0x86>
  7e:	07a1                	addi	a5,a5,8
  80:	0721                	addi	a4,a4,8
  82:	ff279ae3          	bne	a5,s2,76 <main+0x76>
  }
  exec(nargv[0], nargv);
  86:	ee040593          	addi	a1,s0,-288
  8a:	ee043503          	ld	a0,-288(s0)
  8e:	00000097          	auipc	ra,0x0
  92:	2fa080e7          	jalr	762(ra) # 388 <exec>
  exit(0);
  96:	4501                	li	a0,0
  98:	00000097          	auipc	ra,0x0
  9c:	2b8080e7          	jalr	696(ra) # 350 <exit>
    fprintf(2, "%s: trace failed\n", argv[0]);
  a0:	00093603          	ld	a2,0(s2)
  a4:	00000597          	auipc	a1,0x0
  a8:	7f458593          	addi	a1,a1,2036 # 898 <malloc+0x100>
  ac:	4509                	li	a0,2
  ae:	00000097          	auipc	ra,0x0
  b2:	5fc080e7          	jalr	1532(ra) # 6aa <fprintf>
    exit(1);
  b6:	4505                	li	a0,1
  b8:	00000097          	auipc	ra,0x0
  bc:	298080e7          	jalr	664(ra) # 350 <exit>

00000000000000c0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e422                	sd	s0,8(sp)
  c4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c6:	87aa                	mv	a5,a0
  c8:	0585                	addi	a1,a1,1
  ca:	0785                	addi	a5,a5,1
  cc:	fff5c703          	lbu	a4,-1(a1)
  d0:	fee78fa3          	sb	a4,-1(a5)
  d4:	fb75                	bnez	a4,c8 <strcpy+0x8>
    ;
  return os;
}
  d6:	6422                	ld	s0,8(sp)
  d8:	0141                	addi	sp,sp,16
  da:	8082                	ret

00000000000000dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  dc:	1141                	addi	sp,sp,-16
  de:	e422                	sd	s0,8(sp)
  e0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  e2:	00054783          	lbu	a5,0(a0)
  e6:	cf91                	beqz	a5,102 <strcmp+0x26>
  e8:	0005c703          	lbu	a4,0(a1)
  ec:	00f71b63          	bne	a4,a5,102 <strcmp+0x26>
    p++, q++;
  f0:	0505                	addi	a0,a0,1
  f2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  f4:	00054783          	lbu	a5,0(a0)
  f8:	c789                	beqz	a5,102 <strcmp+0x26>
  fa:	0005c703          	lbu	a4,0(a1)
  fe:	fef709e3          	beq	a4,a5,f0 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 102:	0005c503          	lbu	a0,0(a1)
}
 106:	40a7853b          	subw	a0,a5,a0
 10a:	6422                	ld	s0,8(sp)
 10c:	0141                	addi	sp,sp,16
 10e:	8082                	ret

0000000000000110 <strlen>:

uint
strlen(const char *s)
{
 110:	1141                	addi	sp,sp,-16
 112:	e422                	sd	s0,8(sp)
 114:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 116:	00054783          	lbu	a5,0(a0)
 11a:	cf91                	beqz	a5,136 <strlen+0x26>
 11c:	0505                	addi	a0,a0,1
 11e:	87aa                	mv	a5,a0
 120:	4685                	li	a3,1
 122:	9e89                	subw	a3,a3,a0
 124:	00f6853b          	addw	a0,a3,a5
 128:	0785                	addi	a5,a5,1
 12a:	fff7c703          	lbu	a4,-1(a5)
 12e:	fb7d                	bnez	a4,124 <strlen+0x14>
    ;
  return n;
}
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret
  for(n = 0; s[n]; n++)
 136:	4501                	li	a0,0
 138:	bfe5                	j	130 <strlen+0x20>

000000000000013a <memset>:

void*
memset(void *dst, int c, uint n)
{
 13a:	1141                	addi	sp,sp,-16
 13c:	e422                	sd	s0,8(sp)
 13e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 140:	ce09                	beqz	a2,15a <memset+0x20>
 142:	87aa                	mv	a5,a0
 144:	fff6071b          	addiw	a4,a2,-1
 148:	1702                	slli	a4,a4,0x20
 14a:	9301                	srli	a4,a4,0x20
 14c:	0705                	addi	a4,a4,1
 14e:	972a                	add	a4,a4,a0
    cdst[i] = c;
 150:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 154:	0785                	addi	a5,a5,1
 156:	fee79de3          	bne	a5,a4,150 <memset+0x16>
  }
  return dst;
}
 15a:	6422                	ld	s0,8(sp)
 15c:	0141                	addi	sp,sp,16
 15e:	8082                	ret

0000000000000160 <strchr>:

char*
strchr(const char *s, char c)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  for(; *s; s++)
 166:	00054783          	lbu	a5,0(a0)
 16a:	cf91                	beqz	a5,186 <strchr+0x26>
    if(*s == c)
 16c:	00f58a63          	beq	a1,a5,180 <strchr+0x20>
  for(; *s; s++)
 170:	0505                	addi	a0,a0,1
 172:	00054783          	lbu	a5,0(a0)
 176:	c781                	beqz	a5,17e <strchr+0x1e>
    if(*s == c)
 178:	feb79ce3          	bne	a5,a1,170 <strchr+0x10>
 17c:	a011                	j	180 <strchr+0x20>
      return (char*)s;
  return 0;
 17e:	4501                	li	a0,0
}
 180:	6422                	ld	s0,8(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret
  return 0;
 186:	4501                	li	a0,0
 188:	bfe5                	j	180 <strchr+0x20>

000000000000018a <gets>:

char*
gets(char *buf, int max)
{
 18a:	711d                	addi	sp,sp,-96
 18c:	ec86                	sd	ra,88(sp)
 18e:	e8a2                	sd	s0,80(sp)
 190:	e4a6                	sd	s1,72(sp)
 192:	e0ca                	sd	s2,64(sp)
 194:	fc4e                	sd	s3,56(sp)
 196:	f852                	sd	s4,48(sp)
 198:	f456                	sd	s5,40(sp)
 19a:	f05a                	sd	s6,32(sp)
 19c:	ec5e                	sd	s7,24(sp)
 19e:	1080                	addi	s0,sp,96
 1a0:	8baa                	mv	s7,a0
 1a2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a4:	892a                	mv	s2,a0
 1a6:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1a8:	4aa9                	li	s5,10
 1aa:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ac:	0019849b          	addiw	s1,s3,1
 1b0:	0344d863          	ble	s4,s1,1e0 <gets+0x56>
    cc = read(0, &c, 1);
 1b4:	4605                	li	a2,1
 1b6:	faf40593          	addi	a1,s0,-81
 1ba:	4501                	li	a0,0
 1bc:	00000097          	auipc	ra,0x0
 1c0:	1ac080e7          	jalr	428(ra) # 368 <read>
    if(cc < 1)
 1c4:	00a05e63          	blez	a0,1e0 <gets+0x56>
    buf[i++] = c;
 1c8:	faf44783          	lbu	a5,-81(s0)
 1cc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d0:	01578763          	beq	a5,s5,1de <gets+0x54>
 1d4:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 1d6:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 1d8:	fd679ae3          	bne	a5,s6,1ac <gets+0x22>
 1dc:	a011                	j	1e0 <gets+0x56>
  for(i=0; i+1 < max; ){
 1de:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1e0:	99de                	add	s3,s3,s7
 1e2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e6:	855e                	mv	a0,s7
 1e8:	60e6                	ld	ra,88(sp)
 1ea:	6446                	ld	s0,80(sp)
 1ec:	64a6                	ld	s1,72(sp)
 1ee:	6906                	ld	s2,64(sp)
 1f0:	79e2                	ld	s3,56(sp)
 1f2:	7a42                	ld	s4,48(sp)
 1f4:	7aa2                	ld	s5,40(sp)
 1f6:	7b02                	ld	s6,32(sp)
 1f8:	6be2                	ld	s7,24(sp)
 1fa:	6125                	addi	sp,sp,96
 1fc:	8082                	ret

00000000000001fe <stat>:

int
stat(const char *n, struct stat *st)
{
 1fe:	1101                	addi	sp,sp,-32
 200:	ec06                	sd	ra,24(sp)
 202:	e822                	sd	s0,16(sp)
 204:	e426                	sd	s1,8(sp)
 206:	e04a                	sd	s2,0(sp)
 208:	1000                	addi	s0,sp,32
 20a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20c:	4581                	li	a1,0
 20e:	00000097          	auipc	ra,0x0
 212:	182080e7          	jalr	386(ra) # 390 <open>
  if(fd < 0)
 216:	02054563          	bltz	a0,240 <stat+0x42>
 21a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 21c:	85ca                	mv	a1,s2
 21e:	00000097          	auipc	ra,0x0
 222:	18a080e7          	jalr	394(ra) # 3a8 <fstat>
 226:	892a                	mv	s2,a0
  close(fd);
 228:	8526                	mv	a0,s1
 22a:	00000097          	auipc	ra,0x0
 22e:	14e080e7          	jalr	334(ra) # 378 <close>
  return r;
}
 232:	854a                	mv	a0,s2
 234:	60e2                	ld	ra,24(sp)
 236:	6442                	ld	s0,16(sp)
 238:	64a2                	ld	s1,8(sp)
 23a:	6902                	ld	s2,0(sp)
 23c:	6105                	addi	sp,sp,32
 23e:	8082                	ret
    return -1;
 240:	597d                	li	s2,-1
 242:	bfc5                	j	232 <stat+0x34>

0000000000000244 <atoi>:

int
atoi(const char *s)
{
 244:	1141                	addi	sp,sp,-16
 246:	e422                	sd	s0,8(sp)
 248:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 24a:	00054683          	lbu	a3,0(a0)
 24e:	fd06879b          	addiw	a5,a3,-48
 252:	0ff7f793          	andi	a5,a5,255
 256:	4725                	li	a4,9
 258:	02f76963          	bltu	a4,a5,28a <atoi+0x46>
 25c:	862a                	mv	a2,a0
  n = 0;
 25e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 260:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 262:	0605                	addi	a2,a2,1
 264:	0025179b          	slliw	a5,a0,0x2
 268:	9fa9                	addw	a5,a5,a0
 26a:	0017979b          	slliw	a5,a5,0x1
 26e:	9fb5                	addw	a5,a5,a3
 270:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 274:	00064683          	lbu	a3,0(a2)
 278:	fd06871b          	addiw	a4,a3,-48
 27c:	0ff77713          	andi	a4,a4,255
 280:	fee5f1e3          	bleu	a4,a1,262 <atoi+0x1e>
  return n;
}
 284:	6422                	ld	s0,8(sp)
 286:	0141                	addi	sp,sp,16
 288:	8082                	ret
  n = 0;
 28a:	4501                	li	a0,0
 28c:	bfe5                	j	284 <atoi+0x40>

000000000000028e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 294:	02b57663          	bleu	a1,a0,2c0 <memmove+0x32>
    while(n-- > 0)
 298:	02c05163          	blez	a2,2ba <memmove+0x2c>
 29c:	fff6079b          	addiw	a5,a2,-1
 2a0:	1782                	slli	a5,a5,0x20
 2a2:	9381                	srli	a5,a5,0x20
 2a4:	0785                	addi	a5,a5,1
 2a6:	97aa                	add	a5,a5,a0
  dst = vdst;
 2a8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2aa:	0585                	addi	a1,a1,1
 2ac:	0705                	addi	a4,a4,1
 2ae:	fff5c683          	lbu	a3,-1(a1)
 2b2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2b6:	fee79ae3          	bne	a5,a4,2aa <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret
    dst += n;
 2c0:	00c50733          	add	a4,a0,a2
    src += n;
 2c4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2c6:	fec05ae3          	blez	a2,2ba <memmove+0x2c>
 2ca:	fff6079b          	addiw	a5,a2,-1
 2ce:	1782                	slli	a5,a5,0x20
 2d0:	9381                	srli	a5,a5,0x20
 2d2:	fff7c793          	not	a5,a5
 2d6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2d8:	15fd                	addi	a1,a1,-1
 2da:	177d                	addi	a4,a4,-1
 2dc:	0005c683          	lbu	a3,0(a1)
 2e0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e4:	fef71ae3          	bne	a4,a5,2d8 <memmove+0x4a>
 2e8:	bfc9                	j	2ba <memmove+0x2c>

00000000000002ea <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e422                	sd	s0,8(sp)
 2ee:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f0:	ce15                	beqz	a2,32c <memcmp+0x42>
 2f2:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 2f6:	00054783          	lbu	a5,0(a0)
 2fa:	0005c703          	lbu	a4,0(a1)
 2fe:	02e79063          	bne	a5,a4,31e <memcmp+0x34>
 302:	1682                	slli	a3,a3,0x20
 304:	9281                	srli	a3,a3,0x20
 306:	0685                	addi	a3,a3,1
 308:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 30a:	0505                	addi	a0,a0,1
    p2++;
 30c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 30e:	00d50d63          	beq	a0,a3,328 <memcmp+0x3e>
    if (*p1 != *p2) {
 312:	00054783          	lbu	a5,0(a0)
 316:	0005c703          	lbu	a4,0(a1)
 31a:	fee788e3          	beq	a5,a4,30a <memcmp+0x20>
      return *p1 - *p2;
 31e:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 322:	6422                	ld	s0,8(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret
  return 0;
 328:	4501                	li	a0,0
 32a:	bfe5                	j	322 <memcmp+0x38>
 32c:	4501                	li	a0,0
 32e:	bfd5                	j	322 <memcmp+0x38>

0000000000000330 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 330:	1141                	addi	sp,sp,-16
 332:	e406                	sd	ra,8(sp)
 334:	e022                	sd	s0,0(sp)
 336:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 338:	00000097          	auipc	ra,0x0
 33c:	f56080e7          	jalr	-170(ra) # 28e <memmove>
}
 340:	60a2                	ld	ra,8(sp)
 342:	6402                	ld	s0,0(sp)
 344:	0141                	addi	sp,sp,16
 346:	8082                	ret

0000000000000348 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 348:	4885                	li	a7,1
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <exit>:
.global exit
exit:
 li a7, SYS_exit
 350:	4889                	li	a7,2
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <wait>:
.global wait
wait:
 li a7, SYS_wait
 358:	488d                	li	a7,3
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 360:	4891                	li	a7,4
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <read>:
.global read
read:
 li a7, SYS_read
 368:	4895                	li	a7,5
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <write>:
.global write
write:
 li a7, SYS_write
 370:	48c1                	li	a7,16
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <close>:
.global close
close:
 li a7, SYS_close
 378:	48d5                	li	a7,21
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <kill>:
.global kill
kill:
 li a7, SYS_kill
 380:	4899                	li	a7,6
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <exec>:
.global exec
exec:
 li a7, SYS_exec
 388:	489d                	li	a7,7
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <open>:
.global open
open:
 li a7, SYS_open
 390:	48bd                	li	a7,15
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 398:	48c5                	li	a7,17
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a0:	48c9                	li	a7,18
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3a8:	48a1                	li	a7,8
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <link>:
.global link
link:
 li a7, SYS_link
 3b0:	48cd                	li	a7,19
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3b8:	48d1                	li	a7,20
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c0:	48a5                	li	a7,9
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3c8:	48a9                	li	a7,10
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d0:	48ad                	li	a7,11
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3d8:	48b1                	li	a7,12
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3e0:	48b5                	li	a7,13
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3e8:	48b9                	li	a7,14
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <trace>:
.global trace
trace:
 li a7, SYS_trace
 3f0:	48d9                	li	a7,22
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 3f8:	48dd                	li	a7,23
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 400:	1101                	addi	sp,sp,-32
 402:	ec06                	sd	ra,24(sp)
 404:	e822                	sd	s0,16(sp)
 406:	1000                	addi	s0,sp,32
 408:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 40c:	4605                	li	a2,1
 40e:	fef40593          	addi	a1,s0,-17
 412:	00000097          	auipc	ra,0x0
 416:	f5e080e7          	jalr	-162(ra) # 370 <write>
}
 41a:	60e2                	ld	ra,24(sp)
 41c:	6442                	ld	s0,16(sp)
 41e:	6105                	addi	sp,sp,32
 420:	8082                	ret

0000000000000422 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 422:	7139                	addi	sp,sp,-64
 424:	fc06                	sd	ra,56(sp)
 426:	f822                	sd	s0,48(sp)
 428:	f426                	sd	s1,40(sp)
 42a:	f04a                	sd	s2,32(sp)
 42c:	ec4e                	sd	s3,24(sp)
 42e:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 430:	c299                	beqz	a3,436 <printint+0x14>
 432:	0005cd63          	bltz	a1,44c <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 436:	2581                	sext.w	a1,a1
  neg = 0;
 438:	4301                	li	t1,0
 43a:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 43e:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 440:	2601                	sext.w	a2,a2
 442:	00000897          	auipc	a7,0x0
 446:	46e88893          	addi	a7,a7,1134 # 8b0 <digits>
 44a:	a801                	j	45a <printint+0x38>
    x = -xx;
 44c:	40b005bb          	negw	a1,a1
 450:	2581                	sext.w	a1,a1
    neg = 1;
 452:	4305                	li	t1,1
    x = -xx;
 454:	b7dd                	j	43a <printint+0x18>
  }while((x /= base) != 0);
 456:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 458:	8836                	mv	a6,a3
 45a:	0018069b          	addiw	a3,a6,1
 45e:	02c5f7bb          	remuw	a5,a1,a2
 462:	1782                	slli	a5,a5,0x20
 464:	9381                	srli	a5,a5,0x20
 466:	97c6                	add	a5,a5,a7
 468:	0007c783          	lbu	a5,0(a5)
 46c:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 470:	0705                	addi	a4,a4,1
 472:	02c5d7bb          	divuw	a5,a1,a2
 476:	fec5f0e3          	bleu	a2,a1,456 <printint+0x34>
  if(neg)
 47a:	00030b63          	beqz	t1,490 <printint+0x6e>
    buf[i++] = '-';
 47e:	fd040793          	addi	a5,s0,-48
 482:	96be                	add	a3,a3,a5
 484:	02d00793          	li	a5,45
 488:	fef68823          	sb	a5,-16(a3)
 48c:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 490:	02d05963          	blez	a3,4c2 <printint+0xa0>
 494:	89aa                	mv	s3,a0
 496:	fc040793          	addi	a5,s0,-64
 49a:	00d784b3          	add	s1,a5,a3
 49e:	fff78913          	addi	s2,a5,-1
 4a2:	9936                	add	s2,s2,a3
 4a4:	36fd                	addiw	a3,a3,-1
 4a6:	1682                	slli	a3,a3,0x20
 4a8:	9281                	srli	a3,a3,0x20
 4aa:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 4ae:	fff4c583          	lbu	a1,-1(s1)
 4b2:	854e                	mv	a0,s3
 4b4:	00000097          	auipc	ra,0x0
 4b8:	f4c080e7          	jalr	-180(ra) # 400 <putc>
  while(--i >= 0)
 4bc:	14fd                	addi	s1,s1,-1
 4be:	ff2498e3          	bne	s1,s2,4ae <printint+0x8c>
}
 4c2:	70e2                	ld	ra,56(sp)
 4c4:	7442                	ld	s0,48(sp)
 4c6:	74a2                	ld	s1,40(sp)
 4c8:	7902                	ld	s2,32(sp)
 4ca:	69e2                	ld	s3,24(sp)
 4cc:	6121                	addi	sp,sp,64
 4ce:	8082                	ret

00000000000004d0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d0:	7119                	addi	sp,sp,-128
 4d2:	fc86                	sd	ra,120(sp)
 4d4:	f8a2                	sd	s0,112(sp)
 4d6:	f4a6                	sd	s1,104(sp)
 4d8:	f0ca                	sd	s2,96(sp)
 4da:	ecce                	sd	s3,88(sp)
 4dc:	e8d2                	sd	s4,80(sp)
 4de:	e4d6                	sd	s5,72(sp)
 4e0:	e0da                	sd	s6,64(sp)
 4e2:	fc5e                	sd	s7,56(sp)
 4e4:	f862                	sd	s8,48(sp)
 4e6:	f466                	sd	s9,40(sp)
 4e8:	f06a                	sd	s10,32(sp)
 4ea:	ec6e                	sd	s11,24(sp)
 4ec:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ee:	0005c483          	lbu	s1,0(a1)
 4f2:	18048d63          	beqz	s1,68c <vprintf+0x1bc>
 4f6:	8aaa                	mv	s5,a0
 4f8:	8b32                	mv	s6,a2
 4fa:	00158913          	addi	s2,a1,1
  state = 0;
 4fe:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 500:	02500a13          	li	s4,37
      if(c == 'd'){
 504:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 508:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 50c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 510:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 514:	00000b97          	auipc	s7,0x0
 518:	39cb8b93          	addi	s7,s7,924 # 8b0 <digits>
 51c:	a839                	j	53a <vprintf+0x6a>
        putc(fd, c);
 51e:	85a6                	mv	a1,s1
 520:	8556                	mv	a0,s5
 522:	00000097          	auipc	ra,0x0
 526:	ede080e7          	jalr	-290(ra) # 400 <putc>
 52a:	a019                	j	530 <vprintf+0x60>
    } else if(state == '%'){
 52c:	01498f63          	beq	s3,s4,54a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 530:	0905                	addi	s2,s2,1
 532:	fff94483          	lbu	s1,-1(s2)
 536:	14048b63          	beqz	s1,68c <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 53a:	0004879b          	sext.w	a5,s1
    if(state == 0){
 53e:	fe0997e3          	bnez	s3,52c <vprintf+0x5c>
      if(c == '%'){
 542:	fd479ee3          	bne	a5,s4,51e <vprintf+0x4e>
        state = '%';
 546:	89be                	mv	s3,a5
 548:	b7e5                	j	530 <vprintf+0x60>
      if(c == 'd'){
 54a:	05878063          	beq	a5,s8,58a <vprintf+0xba>
      } else if(c == 'l') {
 54e:	05978c63          	beq	a5,s9,5a6 <vprintf+0xd6>
      } else if(c == 'x') {
 552:	07a78863          	beq	a5,s10,5c2 <vprintf+0xf2>
      } else if(c == 'p') {
 556:	09b78463          	beq	a5,s11,5de <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 55a:	07300713          	li	a4,115
 55e:	0ce78563          	beq	a5,a4,628 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 562:	06300713          	li	a4,99
 566:	0ee78c63          	beq	a5,a4,65e <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 56a:	11478663          	beq	a5,s4,676 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 56e:	85d2                	mv	a1,s4
 570:	8556                	mv	a0,s5
 572:	00000097          	auipc	ra,0x0
 576:	e8e080e7          	jalr	-370(ra) # 400 <putc>
        putc(fd, c);
 57a:	85a6                	mv	a1,s1
 57c:	8556                	mv	a0,s5
 57e:	00000097          	auipc	ra,0x0
 582:	e82080e7          	jalr	-382(ra) # 400 <putc>
      }
      state = 0;
 586:	4981                	li	s3,0
 588:	b765                	j	530 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 58a:	008b0493          	addi	s1,s6,8
 58e:	4685                	li	a3,1
 590:	4629                	li	a2,10
 592:	000b2583          	lw	a1,0(s6)
 596:	8556                	mv	a0,s5
 598:	00000097          	auipc	ra,0x0
 59c:	e8a080e7          	jalr	-374(ra) # 422 <printint>
 5a0:	8b26                	mv	s6,s1
      state = 0;
 5a2:	4981                	li	s3,0
 5a4:	b771                	j	530 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5a6:	008b0493          	addi	s1,s6,8
 5aa:	4681                	li	a3,0
 5ac:	4629                	li	a2,10
 5ae:	000b2583          	lw	a1,0(s6)
 5b2:	8556                	mv	a0,s5
 5b4:	00000097          	auipc	ra,0x0
 5b8:	e6e080e7          	jalr	-402(ra) # 422 <printint>
 5bc:	8b26                	mv	s6,s1
      state = 0;
 5be:	4981                	li	s3,0
 5c0:	bf85                	j	530 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5c2:	008b0493          	addi	s1,s6,8
 5c6:	4681                	li	a3,0
 5c8:	4641                	li	a2,16
 5ca:	000b2583          	lw	a1,0(s6)
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	e52080e7          	jalr	-430(ra) # 422 <printint>
 5d8:	8b26                	mv	s6,s1
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	bf91                	j	530 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5de:	008b0793          	addi	a5,s6,8
 5e2:	f8f43423          	sd	a5,-120(s0)
 5e6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5ea:	03000593          	li	a1,48
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	e10080e7          	jalr	-496(ra) # 400 <putc>
  putc(fd, 'x');
 5f8:	85ea                	mv	a1,s10
 5fa:	8556                	mv	a0,s5
 5fc:	00000097          	auipc	ra,0x0
 600:	e04080e7          	jalr	-508(ra) # 400 <putc>
 604:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 606:	03c9d793          	srli	a5,s3,0x3c
 60a:	97de                	add	a5,a5,s7
 60c:	0007c583          	lbu	a1,0(a5)
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	dee080e7          	jalr	-530(ra) # 400 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 61a:	0992                	slli	s3,s3,0x4
 61c:	34fd                	addiw	s1,s1,-1
 61e:	f4e5                	bnez	s1,606 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 620:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 624:	4981                	li	s3,0
 626:	b729                	j	530 <vprintf+0x60>
        s = va_arg(ap, char*);
 628:	008b0993          	addi	s3,s6,8
 62c:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 630:	c085                	beqz	s1,650 <vprintf+0x180>
        while(*s != 0){
 632:	0004c583          	lbu	a1,0(s1)
 636:	c9a1                	beqz	a1,686 <vprintf+0x1b6>
          putc(fd, *s);
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	dc6080e7          	jalr	-570(ra) # 400 <putc>
          s++;
 642:	0485                	addi	s1,s1,1
        while(*s != 0){
 644:	0004c583          	lbu	a1,0(s1)
 648:	f9e5                	bnez	a1,638 <vprintf+0x168>
        s = va_arg(ap, char*);
 64a:	8b4e                	mv	s6,s3
      state = 0;
 64c:	4981                	li	s3,0
 64e:	b5cd                	j	530 <vprintf+0x60>
          s = "(null)";
 650:	00000497          	auipc	s1,0x0
 654:	27848493          	addi	s1,s1,632 # 8c8 <digits+0x18>
        while(*s != 0){
 658:	02800593          	li	a1,40
 65c:	bff1                	j	638 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 65e:	008b0493          	addi	s1,s6,8
 662:	000b4583          	lbu	a1,0(s6)
 666:	8556                	mv	a0,s5
 668:	00000097          	auipc	ra,0x0
 66c:	d98080e7          	jalr	-616(ra) # 400 <putc>
 670:	8b26                	mv	s6,s1
      state = 0;
 672:	4981                	li	s3,0
 674:	bd75                	j	530 <vprintf+0x60>
        putc(fd, c);
 676:	85d2                	mv	a1,s4
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	d86080e7          	jalr	-634(ra) # 400 <putc>
      state = 0;
 682:	4981                	li	s3,0
 684:	b575                	j	530 <vprintf+0x60>
        s = va_arg(ap, char*);
 686:	8b4e                	mv	s6,s3
      state = 0;
 688:	4981                	li	s3,0
 68a:	b55d                	j	530 <vprintf+0x60>
    }
  }
}
 68c:	70e6                	ld	ra,120(sp)
 68e:	7446                	ld	s0,112(sp)
 690:	74a6                	ld	s1,104(sp)
 692:	7906                	ld	s2,96(sp)
 694:	69e6                	ld	s3,88(sp)
 696:	6a46                	ld	s4,80(sp)
 698:	6aa6                	ld	s5,72(sp)
 69a:	6b06                	ld	s6,64(sp)
 69c:	7be2                	ld	s7,56(sp)
 69e:	7c42                	ld	s8,48(sp)
 6a0:	7ca2                	ld	s9,40(sp)
 6a2:	7d02                	ld	s10,32(sp)
 6a4:	6de2                	ld	s11,24(sp)
 6a6:	6109                	addi	sp,sp,128
 6a8:	8082                	ret

00000000000006aa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6aa:	715d                	addi	sp,sp,-80
 6ac:	ec06                	sd	ra,24(sp)
 6ae:	e822                	sd	s0,16(sp)
 6b0:	1000                	addi	s0,sp,32
 6b2:	e010                	sd	a2,0(s0)
 6b4:	e414                	sd	a3,8(s0)
 6b6:	e818                	sd	a4,16(s0)
 6b8:	ec1c                	sd	a5,24(s0)
 6ba:	03043023          	sd	a6,32(s0)
 6be:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6c2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6c6:	8622                	mv	a2,s0
 6c8:	00000097          	auipc	ra,0x0
 6cc:	e08080e7          	jalr	-504(ra) # 4d0 <vprintf>
}
 6d0:	60e2                	ld	ra,24(sp)
 6d2:	6442                	ld	s0,16(sp)
 6d4:	6161                	addi	sp,sp,80
 6d6:	8082                	ret

00000000000006d8 <printf>:

void
printf(const char *fmt, ...)
{
 6d8:	711d                	addi	sp,sp,-96
 6da:	ec06                	sd	ra,24(sp)
 6dc:	e822                	sd	s0,16(sp)
 6de:	1000                	addi	s0,sp,32
 6e0:	e40c                	sd	a1,8(s0)
 6e2:	e810                	sd	a2,16(s0)
 6e4:	ec14                	sd	a3,24(s0)
 6e6:	f018                	sd	a4,32(s0)
 6e8:	f41c                	sd	a5,40(s0)
 6ea:	03043823          	sd	a6,48(s0)
 6ee:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6f2:	00840613          	addi	a2,s0,8
 6f6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6fa:	85aa                	mv	a1,a0
 6fc:	4505                	li	a0,1
 6fe:	00000097          	auipc	ra,0x0
 702:	dd2080e7          	jalr	-558(ra) # 4d0 <vprintf>
}
 706:	60e2                	ld	ra,24(sp)
 708:	6442                	ld	s0,16(sp)
 70a:	6125                	addi	sp,sp,96
 70c:	8082                	ret

000000000000070e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 70e:	1141                	addi	sp,sp,-16
 710:	e422                	sd	s0,8(sp)
 712:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 714:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 718:	00000797          	auipc	a5,0x0
 71c:	1b878793          	addi	a5,a5,440 # 8d0 <__bss_start>
 720:	639c                	ld	a5,0(a5)
 722:	a805                	j	752 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 724:	4618                	lw	a4,8(a2)
 726:	9db9                	addw	a1,a1,a4
 728:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 72c:	6398                	ld	a4,0(a5)
 72e:	6318                	ld	a4,0(a4)
 730:	fee53823          	sd	a4,-16(a0)
 734:	a091                	j	778 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 736:	ff852703          	lw	a4,-8(a0)
 73a:	9e39                	addw	a2,a2,a4
 73c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 73e:	ff053703          	ld	a4,-16(a0)
 742:	e398                	sd	a4,0(a5)
 744:	a099                	j	78a <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 746:	6398                	ld	a4,0(a5)
 748:	00e7e463          	bltu	a5,a4,750 <free+0x42>
 74c:	00e6ea63          	bltu	a3,a4,760 <free+0x52>
{
 750:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 752:	fed7fae3          	bleu	a3,a5,746 <free+0x38>
 756:	6398                	ld	a4,0(a5)
 758:	00e6e463          	bltu	a3,a4,760 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75c:	fee7eae3          	bltu	a5,a4,750 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 760:	ff852583          	lw	a1,-8(a0)
 764:	6390                	ld	a2,0(a5)
 766:	02059713          	slli	a4,a1,0x20
 76a:	9301                	srli	a4,a4,0x20
 76c:	0712                	slli	a4,a4,0x4
 76e:	9736                	add	a4,a4,a3
 770:	fae60ae3          	beq	a2,a4,724 <free+0x16>
    bp->s.ptr = p->s.ptr;
 774:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 778:	4790                	lw	a2,8(a5)
 77a:	02061713          	slli	a4,a2,0x20
 77e:	9301                	srli	a4,a4,0x20
 780:	0712                	slli	a4,a4,0x4
 782:	973e                	add	a4,a4,a5
 784:	fae689e3          	beq	a3,a4,736 <free+0x28>
  } else
    p->s.ptr = bp;
 788:	e394                	sd	a3,0(a5)
  freep = p;
 78a:	00000717          	auipc	a4,0x0
 78e:	14f73323          	sd	a5,326(a4) # 8d0 <__bss_start>
}
 792:	6422                	ld	s0,8(sp)
 794:	0141                	addi	sp,sp,16
 796:	8082                	ret

0000000000000798 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 798:	7139                	addi	sp,sp,-64
 79a:	fc06                	sd	ra,56(sp)
 79c:	f822                	sd	s0,48(sp)
 79e:	f426                	sd	s1,40(sp)
 7a0:	f04a                	sd	s2,32(sp)
 7a2:	ec4e                	sd	s3,24(sp)
 7a4:	e852                	sd	s4,16(sp)
 7a6:	e456                	sd	s5,8(sp)
 7a8:	e05a                	sd	s6,0(sp)
 7aa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7ac:	02051993          	slli	s3,a0,0x20
 7b0:	0209d993          	srli	s3,s3,0x20
 7b4:	09bd                	addi	s3,s3,15
 7b6:	0049d993          	srli	s3,s3,0x4
 7ba:	2985                	addiw	s3,s3,1
 7bc:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 7c0:	00000797          	auipc	a5,0x0
 7c4:	11078793          	addi	a5,a5,272 # 8d0 <__bss_start>
 7c8:	6388                	ld	a0,0(a5)
 7ca:	c515                	beqz	a0,7f6 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7cc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ce:	4798                	lw	a4,8(a5)
 7d0:	03277f63          	bleu	s2,a4,80e <malloc+0x76>
 7d4:	8a4e                	mv	s4,s3
 7d6:	0009871b          	sext.w	a4,s3
 7da:	6685                	lui	a3,0x1
 7dc:	00d77363          	bleu	a3,a4,7e2 <malloc+0x4a>
 7e0:	6a05                	lui	s4,0x1
 7e2:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 7e6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7ea:	00000497          	auipc	s1,0x0
 7ee:	0e648493          	addi	s1,s1,230 # 8d0 <__bss_start>
  if(p == (char*)-1)
 7f2:	5b7d                	li	s6,-1
 7f4:	a885                	j	864 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 7f6:	00000797          	auipc	a5,0x0
 7fa:	0e278793          	addi	a5,a5,226 # 8d8 <base>
 7fe:	00000717          	auipc	a4,0x0
 802:	0cf73923          	sd	a5,210(a4) # 8d0 <__bss_start>
 806:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 808:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 80c:	b7e1                	j	7d4 <malloc+0x3c>
      if(p->s.size == nunits)
 80e:	02e90b63          	beq	s2,a4,844 <malloc+0xac>
        p->s.size -= nunits;
 812:	4137073b          	subw	a4,a4,s3
 816:	c798                	sw	a4,8(a5)
        p += p->s.size;
 818:	1702                	slli	a4,a4,0x20
 81a:	9301                	srli	a4,a4,0x20
 81c:	0712                	slli	a4,a4,0x4
 81e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 820:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 824:	00000717          	auipc	a4,0x0
 828:	0aa73623          	sd	a0,172(a4) # 8d0 <__bss_start>
      return (void*)(p + 1);
 82c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 830:	70e2                	ld	ra,56(sp)
 832:	7442                	ld	s0,48(sp)
 834:	74a2                	ld	s1,40(sp)
 836:	7902                	ld	s2,32(sp)
 838:	69e2                	ld	s3,24(sp)
 83a:	6a42                	ld	s4,16(sp)
 83c:	6aa2                	ld	s5,8(sp)
 83e:	6b02                	ld	s6,0(sp)
 840:	6121                	addi	sp,sp,64
 842:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 844:	6398                	ld	a4,0(a5)
 846:	e118                	sd	a4,0(a0)
 848:	bff1                	j	824 <malloc+0x8c>
  hp->s.size = nu;
 84a:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 84e:	0541                	addi	a0,a0,16
 850:	00000097          	auipc	ra,0x0
 854:	ebe080e7          	jalr	-322(ra) # 70e <free>
  return freep;
 858:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 85a:	d979                	beqz	a0,830 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 85e:	4798                	lw	a4,8(a5)
 860:	fb2777e3          	bleu	s2,a4,80e <malloc+0x76>
    if(p == freep)
 864:	6098                	ld	a4,0(s1)
 866:	853e                	mv	a0,a5
 868:	fef71ae3          	bne	a4,a5,85c <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 86c:	8552                	mv	a0,s4
 86e:	00000097          	auipc	ra,0x0
 872:	b6a080e7          	jalr	-1174(ra) # 3d8 <sbrk>
  if(p == (char*)-1)
 876:	fd651ae3          	bne	a0,s6,84a <malloc+0xb2>
        return 0;
 87a:	4501                	li	a0,0
 87c:	bf55                	j	830 <malloc+0x98>
