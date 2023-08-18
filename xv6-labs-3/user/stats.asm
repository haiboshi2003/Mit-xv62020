
user/_stats：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#define SZ 4096
char buf[SZ];

int
main(void)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
  int i, n;
  
  while (1) {
    n = statistics(buf, SZ);
  12:	00001a17          	auipc	s4,0x1
  16:	8e6a0a13          	addi	s4,s4,-1818 # 8f8 <buf>
  1a:	00001a97          	auipc	s5,0x1
  1e:	8dfa8a93          	addi	s5,s5,-1825 # 8f9 <buf+0x1>
  22:	a021                	j	2a <main+0x2a>
    for (i = 0; i < n; i++) {
      write(1, buf+i, 1);
    }
    if (n != SZ)
  24:	6785                	lui	a5,0x1
  26:	04f99063          	bne	s3,a5,66 <main+0x66>
    n = statistics(buf, SZ);
  2a:	6585                	lui	a1,0x1
  2c:	8552                	mv	a0,s4
  2e:	00000097          	auipc	ra,0x0
  32:	7f0080e7          	jalr	2032(ra) # 81e <statistics>
  36:	89aa                	mv	s3,a0
    for (i = 0; i < n; i++) {
  38:	fea056e3          	blez	a0,24 <main+0x24>
  3c:	00001497          	auipc	s1,0x1
  40:	8bc48493          	addi	s1,s1,-1860 # 8f8 <buf>
  44:	fff5091b          	addiw	s2,a0,-1
  48:	1902                	slli	s2,s2,0x20
  4a:	02095913          	srli	s2,s2,0x20
  4e:	9956                	add	s2,s2,s5
      write(1, buf+i, 1);
  50:	4605                	li	a2,1
  52:	85a6                	mv	a1,s1
  54:	4505                	li	a0,1
  56:	00000097          	auipc	ra,0x0
  5a:	2ca080e7          	jalr	714(ra) # 320 <write>
    for (i = 0; i < n; i++) {
  5e:	0485                	addi	s1,s1,1
  60:	ff2498e3          	bne	s1,s2,50 <main+0x50>
  64:	b7c1                	j	24 <main+0x24>
      break;
  }

  exit(0);
  66:	4501                	li	a0,0
  68:	00000097          	auipc	ra,0x0
  6c:	298080e7          	jalr	664(ra) # 300 <exit>

0000000000000070 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  70:	1141                	addi	sp,sp,-16
  72:	e422                	sd	s0,8(sp)
  74:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  76:	87aa                	mv	a5,a0
  78:	0585                	addi	a1,a1,1
  7a:	0785                	addi	a5,a5,1
  7c:	fff5c703          	lbu	a4,-1(a1) # fff <buf+0x707>
  80:	fee78fa3          	sb	a4,-1(a5) # fff <buf+0x707>
  84:	fb75                	bnez	a4,78 <strcpy+0x8>
    ;
  return os;
}
  86:	6422                	ld	s0,8(sp)
  88:	0141                	addi	sp,sp,16
  8a:	8082                	ret

000000000000008c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8c:	1141                	addi	sp,sp,-16
  8e:	e422                	sd	s0,8(sp)
  90:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  92:	00054783          	lbu	a5,0(a0)
  96:	cf91                	beqz	a5,b2 <strcmp+0x26>
  98:	0005c703          	lbu	a4,0(a1)
  9c:	00f71b63          	bne	a4,a5,b2 <strcmp+0x26>
    p++, q++;
  a0:	0505                	addi	a0,a0,1
  a2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  a4:	00054783          	lbu	a5,0(a0)
  a8:	c789                	beqz	a5,b2 <strcmp+0x26>
  aa:	0005c703          	lbu	a4,0(a1)
  ae:	fef709e3          	beq	a4,a5,a0 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
  b2:	0005c503          	lbu	a0,0(a1)
}
  b6:	40a7853b          	subw	a0,a5,a0
  ba:	6422                	ld	s0,8(sp)
  bc:	0141                	addi	sp,sp,16
  be:	8082                	ret

00000000000000c0 <strlen>:

uint
strlen(const char *s)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e422                	sd	s0,8(sp)
  c4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  c6:	00054783          	lbu	a5,0(a0)
  ca:	cf91                	beqz	a5,e6 <strlen+0x26>
  cc:	0505                	addi	a0,a0,1
  ce:	87aa                	mv	a5,a0
  d0:	4685                	li	a3,1
  d2:	9e89                	subw	a3,a3,a0
  d4:	00f6853b          	addw	a0,a3,a5
  d8:	0785                	addi	a5,a5,1
  da:	fff7c703          	lbu	a4,-1(a5)
  de:	fb7d                	bnez	a4,d4 <strlen+0x14>
    ;
  return n;
}
  e0:	6422                	ld	s0,8(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret
  for(n = 0; s[n]; n++)
  e6:	4501                	li	a0,0
  e8:	bfe5                	j	e0 <strlen+0x20>

00000000000000ea <memset>:

void*
memset(void *dst, int c, uint n)
{
  ea:	1141                	addi	sp,sp,-16
  ec:	e422                	sd	s0,8(sp)
  ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  f0:	ce09                	beqz	a2,10a <memset+0x20>
  f2:	87aa                	mv	a5,a0
  f4:	fff6071b          	addiw	a4,a2,-1
  f8:	1702                	slli	a4,a4,0x20
  fa:	9301                	srli	a4,a4,0x20
  fc:	0705                	addi	a4,a4,1
  fe:	972a                	add	a4,a4,a0
    cdst[i] = c;
 100:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 104:	0785                	addi	a5,a5,1
 106:	fee79de3          	bne	a5,a4,100 <memset+0x16>
  }
  return dst;
}
 10a:	6422                	ld	s0,8(sp)
 10c:	0141                	addi	sp,sp,16
 10e:	8082                	ret

0000000000000110 <strchr>:

char*
strchr(const char *s, char c)
{
 110:	1141                	addi	sp,sp,-16
 112:	e422                	sd	s0,8(sp)
 114:	0800                	addi	s0,sp,16
  for(; *s; s++)
 116:	00054783          	lbu	a5,0(a0)
 11a:	cf91                	beqz	a5,136 <strchr+0x26>
    if(*s == c)
 11c:	00f58a63          	beq	a1,a5,130 <strchr+0x20>
  for(; *s; s++)
 120:	0505                	addi	a0,a0,1
 122:	00054783          	lbu	a5,0(a0)
 126:	c781                	beqz	a5,12e <strchr+0x1e>
    if(*s == c)
 128:	feb79ce3          	bne	a5,a1,120 <strchr+0x10>
 12c:	a011                	j	130 <strchr+0x20>
      return (char*)s;
  return 0;
 12e:	4501                	li	a0,0
}
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret
  return 0;
 136:	4501                	li	a0,0
 138:	bfe5                	j	130 <strchr+0x20>

000000000000013a <gets>:

char*
gets(char *buf, int max)
{
 13a:	711d                	addi	sp,sp,-96
 13c:	ec86                	sd	ra,88(sp)
 13e:	e8a2                	sd	s0,80(sp)
 140:	e4a6                	sd	s1,72(sp)
 142:	e0ca                	sd	s2,64(sp)
 144:	fc4e                	sd	s3,56(sp)
 146:	f852                	sd	s4,48(sp)
 148:	f456                	sd	s5,40(sp)
 14a:	f05a                	sd	s6,32(sp)
 14c:	ec5e                	sd	s7,24(sp)
 14e:	1080                	addi	s0,sp,96
 150:	8baa                	mv	s7,a0
 152:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 154:	892a                	mv	s2,a0
 156:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 158:	4aa9                	li	s5,10
 15a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 15c:	0019849b          	addiw	s1,s3,1
 160:	0344d863          	ble	s4,s1,190 <gets+0x56>
    cc = read(0, &c, 1);
 164:	4605                	li	a2,1
 166:	faf40593          	addi	a1,s0,-81
 16a:	4501                	li	a0,0
 16c:	00000097          	auipc	ra,0x0
 170:	1ac080e7          	jalr	428(ra) # 318 <read>
    if(cc < 1)
 174:	00a05e63          	blez	a0,190 <gets+0x56>
    buf[i++] = c;
 178:	faf44783          	lbu	a5,-81(s0)
 17c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 180:	01578763          	beq	a5,s5,18e <gets+0x54>
 184:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 186:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 188:	fd679ae3          	bne	a5,s6,15c <gets+0x22>
 18c:	a011                	j	190 <gets+0x56>
  for(i=0; i+1 < max; ){
 18e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 190:	99de                	add	s3,s3,s7
 192:	00098023          	sb	zero,0(s3)
  return buf;
}
 196:	855e                	mv	a0,s7
 198:	60e6                	ld	ra,88(sp)
 19a:	6446                	ld	s0,80(sp)
 19c:	64a6                	ld	s1,72(sp)
 19e:	6906                	ld	s2,64(sp)
 1a0:	79e2                	ld	s3,56(sp)
 1a2:	7a42                	ld	s4,48(sp)
 1a4:	7aa2                	ld	s5,40(sp)
 1a6:	7b02                	ld	s6,32(sp)
 1a8:	6be2                	ld	s7,24(sp)
 1aa:	6125                	addi	sp,sp,96
 1ac:	8082                	ret

00000000000001ae <stat>:

int
stat(const char *n, struct stat *st)
{
 1ae:	1101                	addi	sp,sp,-32
 1b0:	ec06                	sd	ra,24(sp)
 1b2:	e822                	sd	s0,16(sp)
 1b4:	e426                	sd	s1,8(sp)
 1b6:	e04a                	sd	s2,0(sp)
 1b8:	1000                	addi	s0,sp,32
 1ba:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1bc:	4581                	li	a1,0
 1be:	00000097          	auipc	ra,0x0
 1c2:	182080e7          	jalr	386(ra) # 340 <open>
  if(fd < 0)
 1c6:	02054563          	bltz	a0,1f0 <stat+0x42>
 1ca:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1cc:	85ca                	mv	a1,s2
 1ce:	00000097          	auipc	ra,0x0
 1d2:	18a080e7          	jalr	394(ra) # 358 <fstat>
 1d6:	892a                	mv	s2,a0
  close(fd);
 1d8:	8526                	mv	a0,s1
 1da:	00000097          	auipc	ra,0x0
 1de:	14e080e7          	jalr	334(ra) # 328 <close>
  return r;
}
 1e2:	854a                	mv	a0,s2
 1e4:	60e2                	ld	ra,24(sp)
 1e6:	6442                	ld	s0,16(sp)
 1e8:	64a2                	ld	s1,8(sp)
 1ea:	6902                	ld	s2,0(sp)
 1ec:	6105                	addi	sp,sp,32
 1ee:	8082                	ret
    return -1;
 1f0:	597d                	li	s2,-1
 1f2:	bfc5                	j	1e2 <stat+0x34>

00000000000001f4 <atoi>:

int
atoi(const char *s)
{
 1f4:	1141                	addi	sp,sp,-16
 1f6:	e422                	sd	s0,8(sp)
 1f8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1fa:	00054683          	lbu	a3,0(a0)
 1fe:	fd06879b          	addiw	a5,a3,-48
 202:	0ff7f793          	andi	a5,a5,255
 206:	4725                	li	a4,9
 208:	02f76963          	bltu	a4,a5,23a <atoi+0x46>
 20c:	862a                	mv	a2,a0
  n = 0;
 20e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 210:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 212:	0605                	addi	a2,a2,1
 214:	0025179b          	slliw	a5,a0,0x2
 218:	9fa9                	addw	a5,a5,a0
 21a:	0017979b          	slliw	a5,a5,0x1
 21e:	9fb5                	addw	a5,a5,a3
 220:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 224:	00064683          	lbu	a3,0(a2)
 228:	fd06871b          	addiw	a4,a3,-48
 22c:	0ff77713          	andi	a4,a4,255
 230:	fee5f1e3          	bleu	a4,a1,212 <atoi+0x1e>
  return n;
}
 234:	6422                	ld	s0,8(sp)
 236:	0141                	addi	sp,sp,16
 238:	8082                	ret
  n = 0;
 23a:	4501                	li	a0,0
 23c:	bfe5                	j	234 <atoi+0x40>

000000000000023e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 23e:	1141                	addi	sp,sp,-16
 240:	e422                	sd	s0,8(sp)
 242:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 244:	02b57663          	bleu	a1,a0,270 <memmove+0x32>
    while(n-- > 0)
 248:	02c05163          	blez	a2,26a <memmove+0x2c>
 24c:	fff6079b          	addiw	a5,a2,-1
 250:	1782                	slli	a5,a5,0x20
 252:	9381                	srli	a5,a5,0x20
 254:	0785                	addi	a5,a5,1
 256:	97aa                	add	a5,a5,a0
  dst = vdst;
 258:	872a                	mv	a4,a0
      *dst++ = *src++;
 25a:	0585                	addi	a1,a1,1
 25c:	0705                	addi	a4,a4,1
 25e:	fff5c683          	lbu	a3,-1(a1)
 262:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 266:	fee79ae3          	bne	a5,a4,25a <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 26a:	6422                	ld	s0,8(sp)
 26c:	0141                	addi	sp,sp,16
 26e:	8082                	ret
    dst += n;
 270:	00c50733          	add	a4,a0,a2
    src += n;
 274:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 276:	fec05ae3          	blez	a2,26a <memmove+0x2c>
 27a:	fff6079b          	addiw	a5,a2,-1
 27e:	1782                	slli	a5,a5,0x20
 280:	9381                	srli	a5,a5,0x20
 282:	fff7c793          	not	a5,a5
 286:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 288:	15fd                	addi	a1,a1,-1
 28a:	177d                	addi	a4,a4,-1
 28c:	0005c683          	lbu	a3,0(a1)
 290:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 294:	fef71ae3          	bne	a4,a5,288 <memmove+0x4a>
 298:	bfc9                	j	26a <memmove+0x2c>

000000000000029a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 29a:	1141                	addi	sp,sp,-16
 29c:	e422                	sd	s0,8(sp)
 29e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2a0:	ce15                	beqz	a2,2dc <memcmp+0x42>
 2a2:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 2a6:	00054783          	lbu	a5,0(a0)
 2aa:	0005c703          	lbu	a4,0(a1)
 2ae:	02e79063          	bne	a5,a4,2ce <memcmp+0x34>
 2b2:	1682                	slli	a3,a3,0x20
 2b4:	9281                	srli	a3,a3,0x20
 2b6:	0685                	addi	a3,a3,1
 2b8:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 2ba:	0505                	addi	a0,a0,1
    p2++;
 2bc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2be:	00d50d63          	beq	a0,a3,2d8 <memcmp+0x3e>
    if (*p1 != *p2) {
 2c2:	00054783          	lbu	a5,0(a0)
 2c6:	0005c703          	lbu	a4,0(a1)
 2ca:	fee788e3          	beq	a5,a4,2ba <memcmp+0x20>
      return *p1 - *p2;
 2ce:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 2d2:	6422                	ld	s0,8(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret
  return 0;
 2d8:	4501                	li	a0,0
 2da:	bfe5                	j	2d2 <memcmp+0x38>
 2dc:	4501                	li	a0,0
 2de:	bfd5                	j	2d2 <memcmp+0x38>

00000000000002e0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e406                	sd	ra,8(sp)
 2e4:	e022                	sd	s0,0(sp)
 2e6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2e8:	00000097          	auipc	ra,0x0
 2ec:	f56080e7          	jalr	-170(ra) # 23e <memmove>
}
 2f0:	60a2                	ld	ra,8(sp)
 2f2:	6402                	ld	s0,0(sp)
 2f4:	0141                	addi	sp,sp,16
 2f6:	8082                	ret

00000000000002f8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2f8:	4885                	li	a7,1
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <exit>:
.global exit
exit:
 li a7, SYS_exit
 300:	4889                	li	a7,2
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <wait>:
.global wait
wait:
 li a7, SYS_wait
 308:	488d                	li	a7,3
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 310:	4891                	li	a7,4
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <read>:
.global read
read:
 li a7, SYS_read
 318:	4895                	li	a7,5
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <write>:
.global write
write:
 li a7, SYS_write
 320:	48c1                	li	a7,16
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <close>:
.global close
close:
 li a7, SYS_close
 328:	48d5                	li	a7,21
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <kill>:
.global kill
kill:
 li a7, SYS_kill
 330:	4899                	li	a7,6
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <exec>:
.global exec
exec:
 li a7, SYS_exec
 338:	489d                	li	a7,7
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <open>:
.global open
open:
 li a7, SYS_open
 340:	48bd                	li	a7,15
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 348:	48c5                	li	a7,17
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 350:	48c9                	li	a7,18
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 358:	48a1                	li	a7,8
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <link>:
.global link
link:
 li a7, SYS_link
 360:	48cd                	li	a7,19
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 368:	48d1                	li	a7,20
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 370:	48a5                	li	a7,9
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <dup>:
.global dup
dup:
 li a7, SYS_dup
 378:	48a9                	li	a7,10
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 380:	48ad                	li	a7,11
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 388:	48b1                	li	a7,12
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 390:	48b5                	li	a7,13
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 398:	48b9                	li	a7,14
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3a0:	1101                	addi	sp,sp,-32
 3a2:	ec06                	sd	ra,24(sp)
 3a4:	e822                	sd	s0,16(sp)
 3a6:	1000                	addi	s0,sp,32
 3a8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ac:	4605                	li	a2,1
 3ae:	fef40593          	addi	a1,s0,-17
 3b2:	00000097          	auipc	ra,0x0
 3b6:	f6e080e7          	jalr	-146(ra) # 320 <write>
}
 3ba:	60e2                	ld	ra,24(sp)
 3bc:	6442                	ld	s0,16(sp)
 3be:	6105                	addi	sp,sp,32
 3c0:	8082                	ret

00000000000003c2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3c2:	7139                	addi	sp,sp,-64
 3c4:	fc06                	sd	ra,56(sp)
 3c6:	f822                	sd	s0,48(sp)
 3c8:	f426                	sd	s1,40(sp)
 3ca:	f04a                	sd	s2,32(sp)
 3cc:	ec4e                	sd	s3,24(sp)
 3ce:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3d0:	c299                	beqz	a3,3d6 <printint+0x14>
 3d2:	0005cd63          	bltz	a1,3ec <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3d6:	2581                	sext.w	a1,a1
  neg = 0;
 3d8:	4301                	li	t1,0
 3da:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 3de:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 3e0:	2601                	sext.w	a2,a2
 3e2:	00000897          	auipc	a7,0x0
 3e6:	4c688893          	addi	a7,a7,1222 # 8a8 <digits>
 3ea:	a801                	j	3fa <printint+0x38>
    x = -xx;
 3ec:	40b005bb          	negw	a1,a1
 3f0:	2581                	sext.w	a1,a1
    neg = 1;
 3f2:	4305                	li	t1,1
    x = -xx;
 3f4:	b7dd                	j	3da <printint+0x18>
  }while((x /= base) != 0);
 3f6:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 3f8:	8836                	mv	a6,a3
 3fa:	0018069b          	addiw	a3,a6,1
 3fe:	02c5f7bb          	remuw	a5,a1,a2
 402:	1782                	slli	a5,a5,0x20
 404:	9381                	srli	a5,a5,0x20
 406:	97c6                	add	a5,a5,a7
 408:	0007c783          	lbu	a5,0(a5)
 40c:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 410:	0705                	addi	a4,a4,1
 412:	02c5d7bb          	divuw	a5,a1,a2
 416:	fec5f0e3          	bleu	a2,a1,3f6 <printint+0x34>
  if(neg)
 41a:	00030b63          	beqz	t1,430 <printint+0x6e>
    buf[i++] = '-';
 41e:	fd040793          	addi	a5,s0,-48
 422:	96be                	add	a3,a3,a5
 424:	02d00793          	li	a5,45
 428:	fef68823          	sb	a5,-16(a3)
 42c:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 430:	02d05963          	blez	a3,462 <printint+0xa0>
 434:	89aa                	mv	s3,a0
 436:	fc040793          	addi	a5,s0,-64
 43a:	00d784b3          	add	s1,a5,a3
 43e:	fff78913          	addi	s2,a5,-1
 442:	9936                	add	s2,s2,a3
 444:	36fd                	addiw	a3,a3,-1
 446:	1682                	slli	a3,a3,0x20
 448:	9281                	srli	a3,a3,0x20
 44a:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 44e:	fff4c583          	lbu	a1,-1(s1)
 452:	854e                	mv	a0,s3
 454:	00000097          	auipc	ra,0x0
 458:	f4c080e7          	jalr	-180(ra) # 3a0 <putc>
  while(--i >= 0)
 45c:	14fd                	addi	s1,s1,-1
 45e:	ff2498e3          	bne	s1,s2,44e <printint+0x8c>
}
 462:	70e2                	ld	ra,56(sp)
 464:	7442                	ld	s0,48(sp)
 466:	74a2                	ld	s1,40(sp)
 468:	7902                	ld	s2,32(sp)
 46a:	69e2                	ld	s3,24(sp)
 46c:	6121                	addi	sp,sp,64
 46e:	8082                	ret

0000000000000470 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 470:	7119                	addi	sp,sp,-128
 472:	fc86                	sd	ra,120(sp)
 474:	f8a2                	sd	s0,112(sp)
 476:	f4a6                	sd	s1,104(sp)
 478:	f0ca                	sd	s2,96(sp)
 47a:	ecce                	sd	s3,88(sp)
 47c:	e8d2                	sd	s4,80(sp)
 47e:	e4d6                	sd	s5,72(sp)
 480:	e0da                	sd	s6,64(sp)
 482:	fc5e                	sd	s7,56(sp)
 484:	f862                	sd	s8,48(sp)
 486:	f466                	sd	s9,40(sp)
 488:	f06a                	sd	s10,32(sp)
 48a:	ec6e                	sd	s11,24(sp)
 48c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 48e:	0005c483          	lbu	s1,0(a1)
 492:	18048d63          	beqz	s1,62c <vprintf+0x1bc>
 496:	8aaa                	mv	s5,a0
 498:	8b32                	mv	s6,a2
 49a:	00158913          	addi	s2,a1,1
  state = 0;
 49e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4a0:	02500a13          	li	s4,37
      if(c == 'd'){
 4a4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4a8:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4ac:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4b0:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4b4:	00000b97          	auipc	s7,0x0
 4b8:	3f4b8b93          	addi	s7,s7,1012 # 8a8 <digits>
 4bc:	a839                	j	4da <vprintf+0x6a>
        putc(fd, c);
 4be:	85a6                	mv	a1,s1
 4c0:	8556                	mv	a0,s5
 4c2:	00000097          	auipc	ra,0x0
 4c6:	ede080e7          	jalr	-290(ra) # 3a0 <putc>
 4ca:	a019                	j	4d0 <vprintf+0x60>
    } else if(state == '%'){
 4cc:	01498f63          	beq	s3,s4,4ea <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4d0:	0905                	addi	s2,s2,1
 4d2:	fff94483          	lbu	s1,-1(s2)
 4d6:	14048b63          	beqz	s1,62c <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 4da:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4de:	fe0997e3          	bnez	s3,4cc <vprintf+0x5c>
      if(c == '%'){
 4e2:	fd479ee3          	bne	a5,s4,4be <vprintf+0x4e>
        state = '%';
 4e6:	89be                	mv	s3,a5
 4e8:	b7e5                	j	4d0 <vprintf+0x60>
      if(c == 'd'){
 4ea:	05878063          	beq	a5,s8,52a <vprintf+0xba>
      } else if(c == 'l') {
 4ee:	05978c63          	beq	a5,s9,546 <vprintf+0xd6>
      } else if(c == 'x') {
 4f2:	07a78863          	beq	a5,s10,562 <vprintf+0xf2>
      } else if(c == 'p') {
 4f6:	09b78463          	beq	a5,s11,57e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4fa:	07300713          	li	a4,115
 4fe:	0ce78563          	beq	a5,a4,5c8 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 502:	06300713          	li	a4,99
 506:	0ee78c63          	beq	a5,a4,5fe <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 50a:	11478663          	beq	a5,s4,616 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 50e:	85d2                	mv	a1,s4
 510:	8556                	mv	a0,s5
 512:	00000097          	auipc	ra,0x0
 516:	e8e080e7          	jalr	-370(ra) # 3a0 <putc>
        putc(fd, c);
 51a:	85a6                	mv	a1,s1
 51c:	8556                	mv	a0,s5
 51e:	00000097          	auipc	ra,0x0
 522:	e82080e7          	jalr	-382(ra) # 3a0 <putc>
      }
      state = 0;
 526:	4981                	li	s3,0
 528:	b765                	j	4d0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 52a:	008b0493          	addi	s1,s6,8
 52e:	4685                	li	a3,1
 530:	4629                	li	a2,10
 532:	000b2583          	lw	a1,0(s6)
 536:	8556                	mv	a0,s5
 538:	00000097          	auipc	ra,0x0
 53c:	e8a080e7          	jalr	-374(ra) # 3c2 <printint>
 540:	8b26                	mv	s6,s1
      state = 0;
 542:	4981                	li	s3,0
 544:	b771                	j	4d0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 546:	008b0493          	addi	s1,s6,8
 54a:	4681                	li	a3,0
 54c:	4629                	li	a2,10
 54e:	000b2583          	lw	a1,0(s6)
 552:	8556                	mv	a0,s5
 554:	00000097          	auipc	ra,0x0
 558:	e6e080e7          	jalr	-402(ra) # 3c2 <printint>
 55c:	8b26                	mv	s6,s1
      state = 0;
 55e:	4981                	li	s3,0
 560:	bf85                	j	4d0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 562:	008b0493          	addi	s1,s6,8
 566:	4681                	li	a3,0
 568:	4641                	li	a2,16
 56a:	000b2583          	lw	a1,0(s6)
 56e:	8556                	mv	a0,s5
 570:	00000097          	auipc	ra,0x0
 574:	e52080e7          	jalr	-430(ra) # 3c2 <printint>
 578:	8b26                	mv	s6,s1
      state = 0;
 57a:	4981                	li	s3,0
 57c:	bf91                	j	4d0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 57e:	008b0793          	addi	a5,s6,8
 582:	f8f43423          	sd	a5,-120(s0)
 586:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 58a:	03000593          	li	a1,48
 58e:	8556                	mv	a0,s5
 590:	00000097          	auipc	ra,0x0
 594:	e10080e7          	jalr	-496(ra) # 3a0 <putc>
  putc(fd, 'x');
 598:	85ea                	mv	a1,s10
 59a:	8556                	mv	a0,s5
 59c:	00000097          	auipc	ra,0x0
 5a0:	e04080e7          	jalr	-508(ra) # 3a0 <putc>
 5a4:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a6:	03c9d793          	srli	a5,s3,0x3c
 5aa:	97de                	add	a5,a5,s7
 5ac:	0007c583          	lbu	a1,0(a5)
 5b0:	8556                	mv	a0,s5
 5b2:	00000097          	auipc	ra,0x0
 5b6:	dee080e7          	jalr	-530(ra) # 3a0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5ba:	0992                	slli	s3,s3,0x4
 5bc:	34fd                	addiw	s1,s1,-1
 5be:	f4e5                	bnez	s1,5a6 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5c0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5c4:	4981                	li	s3,0
 5c6:	b729                	j	4d0 <vprintf+0x60>
        s = va_arg(ap, char*);
 5c8:	008b0993          	addi	s3,s6,8
 5cc:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 5d0:	c085                	beqz	s1,5f0 <vprintf+0x180>
        while(*s != 0){
 5d2:	0004c583          	lbu	a1,0(s1)
 5d6:	c9a1                	beqz	a1,626 <vprintf+0x1b6>
          putc(fd, *s);
 5d8:	8556                	mv	a0,s5
 5da:	00000097          	auipc	ra,0x0
 5de:	dc6080e7          	jalr	-570(ra) # 3a0 <putc>
          s++;
 5e2:	0485                	addi	s1,s1,1
        while(*s != 0){
 5e4:	0004c583          	lbu	a1,0(s1)
 5e8:	f9e5                	bnez	a1,5d8 <vprintf+0x168>
        s = va_arg(ap, char*);
 5ea:	8b4e                	mv	s6,s3
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	b5cd                	j	4d0 <vprintf+0x60>
          s = "(null)";
 5f0:	00000497          	auipc	s1,0x0
 5f4:	2d048493          	addi	s1,s1,720 # 8c0 <digits+0x18>
        while(*s != 0){
 5f8:	02800593          	li	a1,40
 5fc:	bff1                	j	5d8 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 5fe:	008b0493          	addi	s1,s6,8
 602:	000b4583          	lbu	a1,0(s6)
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	d98080e7          	jalr	-616(ra) # 3a0 <putc>
 610:	8b26                	mv	s6,s1
      state = 0;
 612:	4981                	li	s3,0
 614:	bd75                	j	4d0 <vprintf+0x60>
        putc(fd, c);
 616:	85d2                	mv	a1,s4
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	d86080e7          	jalr	-634(ra) # 3a0 <putc>
      state = 0;
 622:	4981                	li	s3,0
 624:	b575                	j	4d0 <vprintf+0x60>
        s = va_arg(ap, char*);
 626:	8b4e                	mv	s6,s3
      state = 0;
 628:	4981                	li	s3,0
 62a:	b55d                	j	4d0 <vprintf+0x60>
    }
  }
}
 62c:	70e6                	ld	ra,120(sp)
 62e:	7446                	ld	s0,112(sp)
 630:	74a6                	ld	s1,104(sp)
 632:	7906                	ld	s2,96(sp)
 634:	69e6                	ld	s3,88(sp)
 636:	6a46                	ld	s4,80(sp)
 638:	6aa6                	ld	s5,72(sp)
 63a:	6b06                	ld	s6,64(sp)
 63c:	7be2                	ld	s7,56(sp)
 63e:	7c42                	ld	s8,48(sp)
 640:	7ca2                	ld	s9,40(sp)
 642:	7d02                	ld	s10,32(sp)
 644:	6de2                	ld	s11,24(sp)
 646:	6109                	addi	sp,sp,128
 648:	8082                	ret

000000000000064a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 64a:	715d                	addi	sp,sp,-80
 64c:	ec06                	sd	ra,24(sp)
 64e:	e822                	sd	s0,16(sp)
 650:	1000                	addi	s0,sp,32
 652:	e010                	sd	a2,0(s0)
 654:	e414                	sd	a3,8(s0)
 656:	e818                	sd	a4,16(s0)
 658:	ec1c                	sd	a5,24(s0)
 65a:	03043023          	sd	a6,32(s0)
 65e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 662:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 666:	8622                	mv	a2,s0
 668:	00000097          	auipc	ra,0x0
 66c:	e08080e7          	jalr	-504(ra) # 470 <vprintf>
}
 670:	60e2                	ld	ra,24(sp)
 672:	6442                	ld	s0,16(sp)
 674:	6161                	addi	sp,sp,80
 676:	8082                	ret

0000000000000678 <printf>:

void
printf(const char *fmt, ...)
{
 678:	711d                	addi	sp,sp,-96
 67a:	ec06                	sd	ra,24(sp)
 67c:	e822                	sd	s0,16(sp)
 67e:	1000                	addi	s0,sp,32
 680:	e40c                	sd	a1,8(s0)
 682:	e810                	sd	a2,16(s0)
 684:	ec14                	sd	a3,24(s0)
 686:	f018                	sd	a4,32(s0)
 688:	f41c                	sd	a5,40(s0)
 68a:	03043823          	sd	a6,48(s0)
 68e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 692:	00840613          	addi	a2,s0,8
 696:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 69a:	85aa                	mv	a1,a0
 69c:	4505                	li	a0,1
 69e:	00000097          	auipc	ra,0x0
 6a2:	dd2080e7          	jalr	-558(ra) # 470 <vprintf>
}
 6a6:	60e2                	ld	ra,24(sp)
 6a8:	6442                	ld	s0,16(sp)
 6aa:	6125                	addi	sp,sp,96
 6ac:	8082                	ret

00000000000006ae <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ae:	1141                	addi	sp,sp,-16
 6b0:	e422                	sd	s0,8(sp)
 6b2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6b4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b8:	00000797          	auipc	a5,0x0
 6bc:	23878793          	addi	a5,a5,568 # 8f0 <__bss_start>
 6c0:	639c                	ld	a5,0(a5)
 6c2:	a805                	j	6f2 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6c4:	4618                	lw	a4,8(a2)
 6c6:	9db9                	addw	a1,a1,a4
 6c8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6cc:	6398                	ld	a4,0(a5)
 6ce:	6318                	ld	a4,0(a4)
 6d0:	fee53823          	sd	a4,-16(a0)
 6d4:	a091                	j	718 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6d6:	ff852703          	lw	a4,-8(a0)
 6da:	9e39                	addw	a2,a2,a4
 6dc:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6de:	ff053703          	ld	a4,-16(a0)
 6e2:	e398                	sd	a4,0(a5)
 6e4:	a099                	j	72a <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e6:	6398                	ld	a4,0(a5)
 6e8:	00e7e463          	bltu	a5,a4,6f0 <free+0x42>
 6ec:	00e6ea63          	bltu	a3,a4,700 <free+0x52>
{
 6f0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f2:	fed7fae3          	bleu	a3,a5,6e6 <free+0x38>
 6f6:	6398                	ld	a4,0(a5)
 6f8:	00e6e463          	bltu	a3,a4,700 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6fc:	fee7eae3          	bltu	a5,a4,6f0 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 700:	ff852583          	lw	a1,-8(a0)
 704:	6390                	ld	a2,0(a5)
 706:	02059713          	slli	a4,a1,0x20
 70a:	9301                	srli	a4,a4,0x20
 70c:	0712                	slli	a4,a4,0x4
 70e:	9736                	add	a4,a4,a3
 710:	fae60ae3          	beq	a2,a4,6c4 <free+0x16>
    bp->s.ptr = p->s.ptr;
 714:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 718:	4790                	lw	a2,8(a5)
 71a:	02061713          	slli	a4,a2,0x20
 71e:	9301                	srli	a4,a4,0x20
 720:	0712                	slli	a4,a4,0x4
 722:	973e                	add	a4,a4,a5
 724:	fae689e3          	beq	a3,a4,6d6 <free+0x28>
  } else
    p->s.ptr = bp;
 728:	e394                	sd	a3,0(a5)
  freep = p;
 72a:	00000717          	auipc	a4,0x0
 72e:	1cf73323          	sd	a5,454(a4) # 8f0 <__bss_start>
}
 732:	6422                	ld	s0,8(sp)
 734:	0141                	addi	sp,sp,16
 736:	8082                	ret

0000000000000738 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 738:	7139                	addi	sp,sp,-64
 73a:	fc06                	sd	ra,56(sp)
 73c:	f822                	sd	s0,48(sp)
 73e:	f426                	sd	s1,40(sp)
 740:	f04a                	sd	s2,32(sp)
 742:	ec4e                	sd	s3,24(sp)
 744:	e852                	sd	s4,16(sp)
 746:	e456                	sd	s5,8(sp)
 748:	e05a                	sd	s6,0(sp)
 74a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 74c:	02051993          	slli	s3,a0,0x20
 750:	0209d993          	srli	s3,s3,0x20
 754:	09bd                	addi	s3,s3,15
 756:	0049d993          	srli	s3,s3,0x4
 75a:	2985                	addiw	s3,s3,1
 75c:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 760:	00000797          	auipc	a5,0x0
 764:	19078793          	addi	a5,a5,400 # 8f0 <__bss_start>
 768:	6388                	ld	a0,0(a5)
 76a:	c515                	beqz	a0,796 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 76c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 76e:	4798                	lw	a4,8(a5)
 770:	03277f63          	bleu	s2,a4,7ae <malloc+0x76>
 774:	8a4e                	mv	s4,s3
 776:	0009871b          	sext.w	a4,s3
 77a:	6685                	lui	a3,0x1
 77c:	00d77363          	bleu	a3,a4,782 <malloc+0x4a>
 780:	6a05                	lui	s4,0x1
 782:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 786:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 78a:	00000497          	auipc	s1,0x0
 78e:	16648493          	addi	s1,s1,358 # 8f0 <__bss_start>
  if(p == (char*)-1)
 792:	5b7d                	li	s6,-1
 794:	a885                	j	804 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 796:	00001797          	auipc	a5,0x1
 79a:	16278793          	addi	a5,a5,354 # 18f8 <base>
 79e:	00000717          	auipc	a4,0x0
 7a2:	14f73923          	sd	a5,338(a4) # 8f0 <__bss_start>
 7a6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7a8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ac:	b7e1                	j	774 <malloc+0x3c>
      if(p->s.size == nunits)
 7ae:	02e90b63          	beq	s2,a4,7e4 <malloc+0xac>
        p->s.size -= nunits;
 7b2:	4137073b          	subw	a4,a4,s3
 7b6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7b8:	1702                	slli	a4,a4,0x20
 7ba:	9301                	srli	a4,a4,0x20
 7bc:	0712                	slli	a4,a4,0x4
 7be:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7c0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7c4:	00000717          	auipc	a4,0x0
 7c8:	12a73623          	sd	a0,300(a4) # 8f0 <__bss_start>
      return (void*)(p + 1);
 7cc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7d0:	70e2                	ld	ra,56(sp)
 7d2:	7442                	ld	s0,48(sp)
 7d4:	74a2                	ld	s1,40(sp)
 7d6:	7902                	ld	s2,32(sp)
 7d8:	69e2                	ld	s3,24(sp)
 7da:	6a42                	ld	s4,16(sp)
 7dc:	6aa2                	ld	s5,8(sp)
 7de:	6b02                	ld	s6,0(sp)
 7e0:	6121                	addi	sp,sp,64
 7e2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7e4:	6398                	ld	a4,0(a5)
 7e6:	e118                	sd	a4,0(a0)
 7e8:	bff1                	j	7c4 <malloc+0x8c>
  hp->s.size = nu;
 7ea:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 7ee:	0541                	addi	a0,a0,16
 7f0:	00000097          	auipc	ra,0x0
 7f4:	ebe080e7          	jalr	-322(ra) # 6ae <free>
  return freep;
 7f8:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 7fa:	d979                	beqz	a0,7d0 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7fe:	4798                	lw	a4,8(a5)
 800:	fb2777e3          	bleu	s2,a4,7ae <malloc+0x76>
    if(p == freep)
 804:	6098                	ld	a4,0(s1)
 806:	853e                	mv	a0,a5
 808:	fef71ae3          	bne	a4,a5,7fc <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 80c:	8552                	mv	a0,s4
 80e:	00000097          	auipc	ra,0x0
 812:	b7a080e7          	jalr	-1158(ra) # 388 <sbrk>
  if(p == (char*)-1)
 816:	fd651ae3          	bne	a0,s6,7ea <malloc+0xb2>
        return 0;
 81a:	4501                	li	a0,0
 81c:	bf55                	j	7d0 <malloc+0x98>

000000000000081e <statistics>:
#include "kernel/fcntl.h"
#include "user/user.h"

int
statistics(void *buf, int sz)
{
 81e:	7179                	addi	sp,sp,-48
 820:	f406                	sd	ra,40(sp)
 822:	f022                	sd	s0,32(sp)
 824:	ec26                	sd	s1,24(sp)
 826:	e84a                	sd	s2,16(sp)
 828:	e44e                	sd	s3,8(sp)
 82a:	e052                	sd	s4,0(sp)
 82c:	1800                	addi	s0,sp,48
 82e:	8a2a                	mv	s4,a0
 830:	892e                	mv	s2,a1
  int fd, i, n;
  
  fd = open("statistics", O_RDONLY);
 832:	4581                	li	a1,0
 834:	00000517          	auipc	a0,0x0
 838:	09450513          	addi	a0,a0,148 # 8c8 <digits+0x20>
 83c:	00000097          	auipc	ra,0x0
 840:	b04080e7          	jalr	-1276(ra) # 340 <open>
  if(fd < 0) {
 844:	04054263          	bltz	a0,888 <statistics+0x6a>
 848:	89aa                	mv	s3,a0
      fprintf(2, "stats: open failed\n");
      exit(1);
  }
  for (i = 0; i < sz; ) {
 84a:	4481                	li	s1,0
 84c:	03205063          	blez	s2,86c <statistics+0x4e>
    if ((n = read(fd, buf+i, sz-i)) < 0) {
 850:	4099063b          	subw	a2,s2,s1
 854:	009a05b3          	add	a1,s4,s1
 858:	854e                	mv	a0,s3
 85a:	00000097          	auipc	ra,0x0
 85e:	abe080e7          	jalr	-1346(ra) # 318 <read>
 862:	00054563          	bltz	a0,86c <statistics+0x4e>
      break;
    }
    i += n;
 866:	9ca9                	addw	s1,s1,a0
  for (i = 0; i < sz; ) {
 868:	ff24c4e3          	blt	s1,s2,850 <statistics+0x32>
  }
  close(fd);
 86c:	854e                	mv	a0,s3
 86e:	00000097          	auipc	ra,0x0
 872:	aba080e7          	jalr	-1350(ra) # 328 <close>
  return i;
}
 876:	8526                	mv	a0,s1
 878:	70a2                	ld	ra,40(sp)
 87a:	7402                	ld	s0,32(sp)
 87c:	64e2                	ld	s1,24(sp)
 87e:	6942                	ld	s2,16(sp)
 880:	69a2                	ld	s3,8(sp)
 882:	6a02                	ld	s4,0(sp)
 884:	6145                	addi	sp,sp,48
 886:	8082                	ret
      fprintf(2, "stats: open failed\n");
 888:	00000597          	auipc	a1,0x0
 88c:	05058593          	addi	a1,a1,80 # 8d8 <digits+0x30>
 890:	4509                	li	a0,2
 892:	00000097          	auipc	ra,0x0
 896:	db8080e7          	jalr	-584(ra) # 64a <fprintf>
      exit(1);
 89a:	4505                	li	a0,1
 89c:	00000097          	auipc	ra,0x0
 8a0:	a64080e7          	jalr	-1436(ra) # 300 <exit>
