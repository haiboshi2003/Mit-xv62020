
user/_call：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <g>:
#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int g(int x) {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  return x+3;
}
   6:	250d                	addiw	a0,a0,3
   8:	6422                	ld	s0,8(sp)
   a:	0141                	addi	sp,sp,16
   c:	8082                	ret

000000000000000e <f>:

int f(int x) {
   e:	1141                	addi	sp,sp,-16
  10:	e422                	sd	s0,8(sp)
  12:	0800                	addi	s0,sp,16
  return g(x);
}
  14:	250d                	addiw	a0,a0,3
  16:	6422                	ld	s0,8(sp)
  18:	0141                	addi	sp,sp,16
  1a:	8082                	ret

000000000000001c <main>:

void main(void) {
  1c:	1141                	addi	sp,sp,-16
  1e:	e406                	sd	ra,8(sp)
  20:	e022                	sd	s0,0(sp)
  22:	0800                	addi	s0,sp,16
  printf("%d %d\n", f(8)+1, 13);
  24:	4635                	li	a2,13
  26:	45b1                	li	a1,12
  28:	00000517          	auipc	a0,0x0
  2c:	7d850513          	addi	a0,a0,2008 # 800 <malloc+0xe6>
  30:	00000097          	auipc	ra,0x0
  34:	62a080e7          	jalr	1578(ra) # 65a <printf>
  exit(0);
  38:	4501                	li	a0,0
  3a:	00000097          	auipc	ra,0x0
  3e:	298080e7          	jalr	664(ra) # 2d2 <exit>

0000000000000042 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  42:	1141                	addi	sp,sp,-16
  44:	e422                	sd	s0,8(sp)
  46:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  48:	87aa                	mv	a5,a0
  4a:	0585                	addi	a1,a1,1
  4c:	0785                	addi	a5,a5,1
  4e:	fff5c703          	lbu	a4,-1(a1)
  52:	fee78fa3          	sb	a4,-1(a5)
  56:	fb75                	bnez	a4,4a <strcpy+0x8>
    ;
  return os;
}
  58:	6422                	ld	s0,8(sp)
  5a:	0141                	addi	sp,sp,16
  5c:	8082                	ret

000000000000005e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  5e:	1141                	addi	sp,sp,-16
  60:	e422                	sd	s0,8(sp)
  62:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  64:	00054783          	lbu	a5,0(a0)
  68:	cf91                	beqz	a5,84 <strcmp+0x26>
  6a:	0005c703          	lbu	a4,0(a1)
  6e:	00f71b63          	bne	a4,a5,84 <strcmp+0x26>
    p++, q++;
  72:	0505                	addi	a0,a0,1
  74:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  76:	00054783          	lbu	a5,0(a0)
  7a:	c789                	beqz	a5,84 <strcmp+0x26>
  7c:	0005c703          	lbu	a4,0(a1)
  80:	fef709e3          	beq	a4,a5,72 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
  84:	0005c503          	lbu	a0,0(a1)
}
  88:	40a7853b          	subw	a0,a5,a0
  8c:	6422                	ld	s0,8(sp)
  8e:	0141                	addi	sp,sp,16
  90:	8082                	ret

0000000000000092 <strlen>:

uint
strlen(const char *s)
{
  92:	1141                	addi	sp,sp,-16
  94:	e422                	sd	s0,8(sp)
  96:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  98:	00054783          	lbu	a5,0(a0)
  9c:	cf91                	beqz	a5,b8 <strlen+0x26>
  9e:	0505                	addi	a0,a0,1
  a0:	87aa                	mv	a5,a0
  a2:	4685                	li	a3,1
  a4:	9e89                	subw	a3,a3,a0
  a6:	00f6853b          	addw	a0,a3,a5
  aa:	0785                	addi	a5,a5,1
  ac:	fff7c703          	lbu	a4,-1(a5)
  b0:	fb7d                	bnez	a4,a6 <strlen+0x14>
    ;
  return n;
}
  b2:	6422                	ld	s0,8(sp)
  b4:	0141                	addi	sp,sp,16
  b6:	8082                	ret
  for(n = 0; s[n]; n++)
  b8:	4501                	li	a0,0
  ba:	bfe5                	j	b2 <strlen+0x20>

00000000000000bc <memset>:

void*
memset(void *dst, int c, uint n)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e422                	sd	s0,8(sp)
  c0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  c2:	ce09                	beqz	a2,dc <memset+0x20>
  c4:	87aa                	mv	a5,a0
  c6:	fff6071b          	addiw	a4,a2,-1
  ca:	1702                	slli	a4,a4,0x20
  cc:	9301                	srli	a4,a4,0x20
  ce:	0705                	addi	a4,a4,1
  d0:	972a                	add	a4,a4,a0
    cdst[i] = c;
  d2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  d6:	0785                	addi	a5,a5,1
  d8:	fee79de3          	bne	a5,a4,d2 <memset+0x16>
  }
  return dst;
}
  dc:	6422                	ld	s0,8(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret

00000000000000e2 <strchr>:

char*
strchr(const char *s, char c)
{
  e2:	1141                	addi	sp,sp,-16
  e4:	e422                	sd	s0,8(sp)
  e6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  e8:	00054783          	lbu	a5,0(a0)
  ec:	cf91                	beqz	a5,108 <strchr+0x26>
    if(*s == c)
  ee:	00f58a63          	beq	a1,a5,102 <strchr+0x20>
  for(; *s; s++)
  f2:	0505                	addi	a0,a0,1
  f4:	00054783          	lbu	a5,0(a0)
  f8:	c781                	beqz	a5,100 <strchr+0x1e>
    if(*s == c)
  fa:	feb79ce3          	bne	a5,a1,f2 <strchr+0x10>
  fe:	a011                	j	102 <strchr+0x20>
      return (char*)s;
  return 0;
 100:	4501                	li	a0,0
}
 102:	6422                	ld	s0,8(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret
  return 0;
 108:	4501                	li	a0,0
 10a:	bfe5                	j	102 <strchr+0x20>

000000000000010c <gets>:

char*
gets(char *buf, int max)
{
 10c:	711d                	addi	sp,sp,-96
 10e:	ec86                	sd	ra,88(sp)
 110:	e8a2                	sd	s0,80(sp)
 112:	e4a6                	sd	s1,72(sp)
 114:	e0ca                	sd	s2,64(sp)
 116:	fc4e                	sd	s3,56(sp)
 118:	f852                	sd	s4,48(sp)
 11a:	f456                	sd	s5,40(sp)
 11c:	f05a                	sd	s6,32(sp)
 11e:	ec5e                	sd	s7,24(sp)
 120:	1080                	addi	s0,sp,96
 122:	8baa                	mv	s7,a0
 124:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 126:	892a                	mv	s2,a0
 128:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 12a:	4aa9                	li	s5,10
 12c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 12e:	0019849b          	addiw	s1,s3,1
 132:	0344d863          	ble	s4,s1,162 <gets+0x56>
    cc = read(0, &c, 1);
 136:	4605                	li	a2,1
 138:	faf40593          	addi	a1,s0,-81
 13c:	4501                	li	a0,0
 13e:	00000097          	auipc	ra,0x0
 142:	1ac080e7          	jalr	428(ra) # 2ea <read>
    if(cc < 1)
 146:	00a05e63          	blez	a0,162 <gets+0x56>
    buf[i++] = c;
 14a:	faf44783          	lbu	a5,-81(s0)
 14e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 152:	01578763          	beq	a5,s5,160 <gets+0x54>
 156:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 158:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 15a:	fd679ae3          	bne	a5,s6,12e <gets+0x22>
 15e:	a011                	j	162 <gets+0x56>
  for(i=0; i+1 < max; ){
 160:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 162:	99de                	add	s3,s3,s7
 164:	00098023          	sb	zero,0(s3)
  return buf;
}
 168:	855e                	mv	a0,s7
 16a:	60e6                	ld	ra,88(sp)
 16c:	6446                	ld	s0,80(sp)
 16e:	64a6                	ld	s1,72(sp)
 170:	6906                	ld	s2,64(sp)
 172:	79e2                	ld	s3,56(sp)
 174:	7a42                	ld	s4,48(sp)
 176:	7aa2                	ld	s5,40(sp)
 178:	7b02                	ld	s6,32(sp)
 17a:	6be2                	ld	s7,24(sp)
 17c:	6125                	addi	sp,sp,96
 17e:	8082                	ret

0000000000000180 <stat>:

int
stat(const char *n, struct stat *st)
{
 180:	1101                	addi	sp,sp,-32
 182:	ec06                	sd	ra,24(sp)
 184:	e822                	sd	s0,16(sp)
 186:	e426                	sd	s1,8(sp)
 188:	e04a                	sd	s2,0(sp)
 18a:	1000                	addi	s0,sp,32
 18c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 18e:	4581                	li	a1,0
 190:	00000097          	auipc	ra,0x0
 194:	182080e7          	jalr	386(ra) # 312 <open>
  if(fd < 0)
 198:	02054563          	bltz	a0,1c2 <stat+0x42>
 19c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 19e:	85ca                	mv	a1,s2
 1a0:	00000097          	auipc	ra,0x0
 1a4:	18a080e7          	jalr	394(ra) # 32a <fstat>
 1a8:	892a                	mv	s2,a0
  close(fd);
 1aa:	8526                	mv	a0,s1
 1ac:	00000097          	auipc	ra,0x0
 1b0:	14e080e7          	jalr	334(ra) # 2fa <close>
  return r;
}
 1b4:	854a                	mv	a0,s2
 1b6:	60e2                	ld	ra,24(sp)
 1b8:	6442                	ld	s0,16(sp)
 1ba:	64a2                	ld	s1,8(sp)
 1bc:	6902                	ld	s2,0(sp)
 1be:	6105                	addi	sp,sp,32
 1c0:	8082                	ret
    return -1;
 1c2:	597d                	li	s2,-1
 1c4:	bfc5                	j	1b4 <stat+0x34>

00000000000001c6 <atoi>:

int
atoi(const char *s)
{
 1c6:	1141                	addi	sp,sp,-16
 1c8:	e422                	sd	s0,8(sp)
 1ca:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1cc:	00054683          	lbu	a3,0(a0)
 1d0:	fd06879b          	addiw	a5,a3,-48
 1d4:	0ff7f793          	andi	a5,a5,255
 1d8:	4725                	li	a4,9
 1da:	02f76963          	bltu	a4,a5,20c <atoi+0x46>
 1de:	862a                	mv	a2,a0
  n = 0;
 1e0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1e2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1e4:	0605                	addi	a2,a2,1
 1e6:	0025179b          	slliw	a5,a0,0x2
 1ea:	9fa9                	addw	a5,a5,a0
 1ec:	0017979b          	slliw	a5,a5,0x1
 1f0:	9fb5                	addw	a5,a5,a3
 1f2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1f6:	00064683          	lbu	a3,0(a2)
 1fa:	fd06871b          	addiw	a4,a3,-48
 1fe:	0ff77713          	andi	a4,a4,255
 202:	fee5f1e3          	bleu	a4,a1,1e4 <atoi+0x1e>
  return n;
}
 206:	6422                	ld	s0,8(sp)
 208:	0141                	addi	sp,sp,16
 20a:	8082                	ret
  n = 0;
 20c:	4501                	li	a0,0
 20e:	bfe5                	j	206 <atoi+0x40>

0000000000000210 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 210:	1141                	addi	sp,sp,-16
 212:	e422                	sd	s0,8(sp)
 214:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 216:	02b57663          	bleu	a1,a0,242 <memmove+0x32>
    while(n-- > 0)
 21a:	02c05163          	blez	a2,23c <memmove+0x2c>
 21e:	fff6079b          	addiw	a5,a2,-1
 222:	1782                	slli	a5,a5,0x20
 224:	9381                	srli	a5,a5,0x20
 226:	0785                	addi	a5,a5,1
 228:	97aa                	add	a5,a5,a0
  dst = vdst;
 22a:	872a                	mv	a4,a0
      *dst++ = *src++;
 22c:	0585                	addi	a1,a1,1
 22e:	0705                	addi	a4,a4,1
 230:	fff5c683          	lbu	a3,-1(a1)
 234:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 238:	fee79ae3          	bne	a5,a4,22c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 23c:	6422                	ld	s0,8(sp)
 23e:	0141                	addi	sp,sp,16
 240:	8082                	ret
    dst += n;
 242:	00c50733          	add	a4,a0,a2
    src += n;
 246:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 248:	fec05ae3          	blez	a2,23c <memmove+0x2c>
 24c:	fff6079b          	addiw	a5,a2,-1
 250:	1782                	slli	a5,a5,0x20
 252:	9381                	srli	a5,a5,0x20
 254:	fff7c793          	not	a5,a5
 258:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 25a:	15fd                	addi	a1,a1,-1
 25c:	177d                	addi	a4,a4,-1
 25e:	0005c683          	lbu	a3,0(a1)
 262:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 266:	fef71ae3          	bne	a4,a5,25a <memmove+0x4a>
 26a:	bfc9                	j	23c <memmove+0x2c>

000000000000026c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e422                	sd	s0,8(sp)
 270:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 272:	ce15                	beqz	a2,2ae <memcmp+0x42>
 274:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 278:	00054783          	lbu	a5,0(a0)
 27c:	0005c703          	lbu	a4,0(a1)
 280:	02e79063          	bne	a5,a4,2a0 <memcmp+0x34>
 284:	1682                	slli	a3,a3,0x20
 286:	9281                	srli	a3,a3,0x20
 288:	0685                	addi	a3,a3,1
 28a:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 28c:	0505                	addi	a0,a0,1
    p2++;
 28e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 290:	00d50d63          	beq	a0,a3,2aa <memcmp+0x3e>
    if (*p1 != *p2) {
 294:	00054783          	lbu	a5,0(a0)
 298:	0005c703          	lbu	a4,0(a1)
 29c:	fee788e3          	beq	a5,a4,28c <memcmp+0x20>
      return *p1 - *p2;
 2a0:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 2a4:	6422                	ld	s0,8(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret
  return 0;
 2aa:	4501                	li	a0,0
 2ac:	bfe5                	j	2a4 <memcmp+0x38>
 2ae:	4501                	li	a0,0
 2b0:	bfd5                	j	2a4 <memcmp+0x38>

00000000000002b2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e406                	sd	ra,8(sp)
 2b6:	e022                	sd	s0,0(sp)
 2b8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ba:	00000097          	auipc	ra,0x0
 2be:	f56080e7          	jalr	-170(ra) # 210 <memmove>
}
 2c2:	60a2                	ld	ra,8(sp)
 2c4:	6402                	ld	s0,0(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret

00000000000002ca <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ca:	4885                	li	a7,1
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2d2:	4889                	li	a7,2
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <wait>:
.global wait
wait:
 li a7, SYS_wait
 2da:	488d                	li	a7,3
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2e2:	4891                	li	a7,4
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <read>:
.global read
read:
 li a7, SYS_read
 2ea:	4895                	li	a7,5
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <write>:
.global write
write:
 li a7, SYS_write
 2f2:	48c1                	li	a7,16
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <close>:
.global close
close:
 li a7, SYS_close
 2fa:	48d5                	li	a7,21
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <kill>:
.global kill
kill:
 li a7, SYS_kill
 302:	4899                	li	a7,6
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <exec>:
.global exec
exec:
 li a7, SYS_exec
 30a:	489d                	li	a7,7
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <open>:
.global open
open:
 li a7, SYS_open
 312:	48bd                	li	a7,15
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 31a:	48c5                	li	a7,17
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 322:	48c9                	li	a7,18
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 32a:	48a1                	li	a7,8
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <link>:
.global link
link:
 li a7, SYS_link
 332:	48cd                	li	a7,19
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 33a:	48d1                	li	a7,20
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 342:	48a5                	li	a7,9
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <dup>:
.global dup
dup:
 li a7, SYS_dup
 34a:	48a9                	li	a7,10
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 352:	48ad                	li	a7,11
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 35a:	48b1                	li	a7,12
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 362:	48b5                	li	a7,13
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 36a:	48b9                	li	a7,14
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 372:	48d9                	li	a7,22
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 37a:	48dd                	li	a7,23
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 382:	1101                	addi	sp,sp,-32
 384:	ec06                	sd	ra,24(sp)
 386:	e822                	sd	s0,16(sp)
 388:	1000                	addi	s0,sp,32
 38a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 38e:	4605                	li	a2,1
 390:	fef40593          	addi	a1,s0,-17
 394:	00000097          	auipc	ra,0x0
 398:	f5e080e7          	jalr	-162(ra) # 2f2 <write>
}
 39c:	60e2                	ld	ra,24(sp)
 39e:	6442                	ld	s0,16(sp)
 3a0:	6105                	addi	sp,sp,32
 3a2:	8082                	ret

00000000000003a4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3a4:	7139                	addi	sp,sp,-64
 3a6:	fc06                	sd	ra,56(sp)
 3a8:	f822                	sd	s0,48(sp)
 3aa:	f426                	sd	s1,40(sp)
 3ac:	f04a                	sd	s2,32(sp)
 3ae:	ec4e                	sd	s3,24(sp)
 3b0:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3b2:	c299                	beqz	a3,3b8 <printint+0x14>
 3b4:	0005cd63          	bltz	a1,3ce <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3b8:	2581                	sext.w	a1,a1
  neg = 0;
 3ba:	4301                	li	t1,0
 3bc:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 3c0:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 3c2:	2601                	sext.w	a2,a2
 3c4:	00000897          	auipc	a7,0x0
 3c8:	44488893          	addi	a7,a7,1092 # 808 <digits>
 3cc:	a801                	j	3dc <printint+0x38>
    x = -xx;
 3ce:	40b005bb          	negw	a1,a1
 3d2:	2581                	sext.w	a1,a1
    neg = 1;
 3d4:	4305                	li	t1,1
    x = -xx;
 3d6:	b7dd                	j	3bc <printint+0x18>
  }while((x /= base) != 0);
 3d8:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 3da:	8836                	mv	a6,a3
 3dc:	0018069b          	addiw	a3,a6,1
 3e0:	02c5f7bb          	remuw	a5,a1,a2
 3e4:	1782                	slli	a5,a5,0x20
 3e6:	9381                	srli	a5,a5,0x20
 3e8:	97c6                	add	a5,a5,a7
 3ea:	0007c783          	lbu	a5,0(a5)
 3ee:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 3f2:	0705                	addi	a4,a4,1
 3f4:	02c5d7bb          	divuw	a5,a1,a2
 3f8:	fec5f0e3          	bleu	a2,a1,3d8 <printint+0x34>
  if(neg)
 3fc:	00030b63          	beqz	t1,412 <printint+0x6e>
    buf[i++] = '-';
 400:	fd040793          	addi	a5,s0,-48
 404:	96be                	add	a3,a3,a5
 406:	02d00793          	li	a5,45
 40a:	fef68823          	sb	a5,-16(a3)
 40e:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 412:	02d05963          	blez	a3,444 <printint+0xa0>
 416:	89aa                	mv	s3,a0
 418:	fc040793          	addi	a5,s0,-64
 41c:	00d784b3          	add	s1,a5,a3
 420:	fff78913          	addi	s2,a5,-1
 424:	9936                	add	s2,s2,a3
 426:	36fd                	addiw	a3,a3,-1
 428:	1682                	slli	a3,a3,0x20
 42a:	9281                	srli	a3,a3,0x20
 42c:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 430:	fff4c583          	lbu	a1,-1(s1)
 434:	854e                	mv	a0,s3
 436:	00000097          	auipc	ra,0x0
 43a:	f4c080e7          	jalr	-180(ra) # 382 <putc>
  while(--i >= 0)
 43e:	14fd                	addi	s1,s1,-1
 440:	ff2498e3          	bne	s1,s2,430 <printint+0x8c>
}
 444:	70e2                	ld	ra,56(sp)
 446:	7442                	ld	s0,48(sp)
 448:	74a2                	ld	s1,40(sp)
 44a:	7902                	ld	s2,32(sp)
 44c:	69e2                	ld	s3,24(sp)
 44e:	6121                	addi	sp,sp,64
 450:	8082                	ret

0000000000000452 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 452:	7119                	addi	sp,sp,-128
 454:	fc86                	sd	ra,120(sp)
 456:	f8a2                	sd	s0,112(sp)
 458:	f4a6                	sd	s1,104(sp)
 45a:	f0ca                	sd	s2,96(sp)
 45c:	ecce                	sd	s3,88(sp)
 45e:	e8d2                	sd	s4,80(sp)
 460:	e4d6                	sd	s5,72(sp)
 462:	e0da                	sd	s6,64(sp)
 464:	fc5e                	sd	s7,56(sp)
 466:	f862                	sd	s8,48(sp)
 468:	f466                	sd	s9,40(sp)
 46a:	f06a                	sd	s10,32(sp)
 46c:	ec6e                	sd	s11,24(sp)
 46e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 470:	0005c483          	lbu	s1,0(a1)
 474:	18048d63          	beqz	s1,60e <vprintf+0x1bc>
 478:	8aaa                	mv	s5,a0
 47a:	8b32                	mv	s6,a2
 47c:	00158913          	addi	s2,a1,1
  state = 0;
 480:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 482:	02500a13          	li	s4,37
      if(c == 'd'){
 486:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 48a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 48e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 492:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 496:	00000b97          	auipc	s7,0x0
 49a:	372b8b93          	addi	s7,s7,882 # 808 <digits>
 49e:	a839                	j	4bc <vprintf+0x6a>
        putc(fd, c);
 4a0:	85a6                	mv	a1,s1
 4a2:	8556                	mv	a0,s5
 4a4:	00000097          	auipc	ra,0x0
 4a8:	ede080e7          	jalr	-290(ra) # 382 <putc>
 4ac:	a019                	j	4b2 <vprintf+0x60>
    } else if(state == '%'){
 4ae:	01498f63          	beq	s3,s4,4cc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4b2:	0905                	addi	s2,s2,1
 4b4:	fff94483          	lbu	s1,-1(s2)
 4b8:	14048b63          	beqz	s1,60e <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 4bc:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4c0:	fe0997e3          	bnez	s3,4ae <vprintf+0x5c>
      if(c == '%'){
 4c4:	fd479ee3          	bne	a5,s4,4a0 <vprintf+0x4e>
        state = '%';
 4c8:	89be                	mv	s3,a5
 4ca:	b7e5                	j	4b2 <vprintf+0x60>
      if(c == 'd'){
 4cc:	05878063          	beq	a5,s8,50c <vprintf+0xba>
      } else if(c == 'l') {
 4d0:	05978c63          	beq	a5,s9,528 <vprintf+0xd6>
      } else if(c == 'x') {
 4d4:	07a78863          	beq	a5,s10,544 <vprintf+0xf2>
      } else if(c == 'p') {
 4d8:	09b78463          	beq	a5,s11,560 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4dc:	07300713          	li	a4,115
 4e0:	0ce78563          	beq	a5,a4,5aa <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4e4:	06300713          	li	a4,99
 4e8:	0ee78c63          	beq	a5,a4,5e0 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4ec:	11478663          	beq	a5,s4,5f8 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4f0:	85d2                	mv	a1,s4
 4f2:	8556                	mv	a0,s5
 4f4:	00000097          	auipc	ra,0x0
 4f8:	e8e080e7          	jalr	-370(ra) # 382 <putc>
        putc(fd, c);
 4fc:	85a6                	mv	a1,s1
 4fe:	8556                	mv	a0,s5
 500:	00000097          	auipc	ra,0x0
 504:	e82080e7          	jalr	-382(ra) # 382 <putc>
      }
      state = 0;
 508:	4981                	li	s3,0
 50a:	b765                	j	4b2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 50c:	008b0493          	addi	s1,s6,8
 510:	4685                	li	a3,1
 512:	4629                	li	a2,10
 514:	000b2583          	lw	a1,0(s6)
 518:	8556                	mv	a0,s5
 51a:	00000097          	auipc	ra,0x0
 51e:	e8a080e7          	jalr	-374(ra) # 3a4 <printint>
 522:	8b26                	mv	s6,s1
      state = 0;
 524:	4981                	li	s3,0
 526:	b771                	j	4b2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 528:	008b0493          	addi	s1,s6,8
 52c:	4681                	li	a3,0
 52e:	4629                	li	a2,10
 530:	000b2583          	lw	a1,0(s6)
 534:	8556                	mv	a0,s5
 536:	00000097          	auipc	ra,0x0
 53a:	e6e080e7          	jalr	-402(ra) # 3a4 <printint>
 53e:	8b26                	mv	s6,s1
      state = 0;
 540:	4981                	li	s3,0
 542:	bf85                	j	4b2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 544:	008b0493          	addi	s1,s6,8
 548:	4681                	li	a3,0
 54a:	4641                	li	a2,16
 54c:	000b2583          	lw	a1,0(s6)
 550:	8556                	mv	a0,s5
 552:	00000097          	auipc	ra,0x0
 556:	e52080e7          	jalr	-430(ra) # 3a4 <printint>
 55a:	8b26                	mv	s6,s1
      state = 0;
 55c:	4981                	li	s3,0
 55e:	bf91                	j	4b2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 560:	008b0793          	addi	a5,s6,8
 564:	f8f43423          	sd	a5,-120(s0)
 568:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 56c:	03000593          	li	a1,48
 570:	8556                	mv	a0,s5
 572:	00000097          	auipc	ra,0x0
 576:	e10080e7          	jalr	-496(ra) # 382 <putc>
  putc(fd, 'x');
 57a:	85ea                	mv	a1,s10
 57c:	8556                	mv	a0,s5
 57e:	00000097          	auipc	ra,0x0
 582:	e04080e7          	jalr	-508(ra) # 382 <putc>
 586:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 588:	03c9d793          	srli	a5,s3,0x3c
 58c:	97de                	add	a5,a5,s7
 58e:	0007c583          	lbu	a1,0(a5)
 592:	8556                	mv	a0,s5
 594:	00000097          	auipc	ra,0x0
 598:	dee080e7          	jalr	-530(ra) # 382 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 59c:	0992                	slli	s3,s3,0x4
 59e:	34fd                	addiw	s1,s1,-1
 5a0:	f4e5                	bnez	s1,588 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5a2:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5a6:	4981                	li	s3,0
 5a8:	b729                	j	4b2 <vprintf+0x60>
        s = va_arg(ap, char*);
 5aa:	008b0993          	addi	s3,s6,8
 5ae:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 5b2:	c085                	beqz	s1,5d2 <vprintf+0x180>
        while(*s != 0){
 5b4:	0004c583          	lbu	a1,0(s1)
 5b8:	c9a1                	beqz	a1,608 <vprintf+0x1b6>
          putc(fd, *s);
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	dc6080e7          	jalr	-570(ra) # 382 <putc>
          s++;
 5c4:	0485                	addi	s1,s1,1
        while(*s != 0){
 5c6:	0004c583          	lbu	a1,0(s1)
 5ca:	f9e5                	bnez	a1,5ba <vprintf+0x168>
        s = va_arg(ap, char*);
 5cc:	8b4e                	mv	s6,s3
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	b5cd                	j	4b2 <vprintf+0x60>
          s = "(null)";
 5d2:	00000497          	auipc	s1,0x0
 5d6:	24e48493          	addi	s1,s1,590 # 820 <digits+0x18>
        while(*s != 0){
 5da:	02800593          	li	a1,40
 5de:	bff1                	j	5ba <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 5e0:	008b0493          	addi	s1,s6,8
 5e4:	000b4583          	lbu	a1,0(s6)
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	d98080e7          	jalr	-616(ra) # 382 <putc>
 5f2:	8b26                	mv	s6,s1
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	bd75                	j	4b2 <vprintf+0x60>
        putc(fd, c);
 5f8:	85d2                	mv	a1,s4
 5fa:	8556                	mv	a0,s5
 5fc:	00000097          	auipc	ra,0x0
 600:	d86080e7          	jalr	-634(ra) # 382 <putc>
      state = 0;
 604:	4981                	li	s3,0
 606:	b575                	j	4b2 <vprintf+0x60>
        s = va_arg(ap, char*);
 608:	8b4e                	mv	s6,s3
      state = 0;
 60a:	4981                	li	s3,0
 60c:	b55d                	j	4b2 <vprintf+0x60>
    }
  }
}
 60e:	70e6                	ld	ra,120(sp)
 610:	7446                	ld	s0,112(sp)
 612:	74a6                	ld	s1,104(sp)
 614:	7906                	ld	s2,96(sp)
 616:	69e6                	ld	s3,88(sp)
 618:	6a46                	ld	s4,80(sp)
 61a:	6aa6                	ld	s5,72(sp)
 61c:	6b06                	ld	s6,64(sp)
 61e:	7be2                	ld	s7,56(sp)
 620:	7c42                	ld	s8,48(sp)
 622:	7ca2                	ld	s9,40(sp)
 624:	7d02                	ld	s10,32(sp)
 626:	6de2                	ld	s11,24(sp)
 628:	6109                	addi	sp,sp,128
 62a:	8082                	ret

000000000000062c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 62c:	715d                	addi	sp,sp,-80
 62e:	ec06                	sd	ra,24(sp)
 630:	e822                	sd	s0,16(sp)
 632:	1000                	addi	s0,sp,32
 634:	e010                	sd	a2,0(s0)
 636:	e414                	sd	a3,8(s0)
 638:	e818                	sd	a4,16(s0)
 63a:	ec1c                	sd	a5,24(s0)
 63c:	03043023          	sd	a6,32(s0)
 640:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 644:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 648:	8622                	mv	a2,s0
 64a:	00000097          	auipc	ra,0x0
 64e:	e08080e7          	jalr	-504(ra) # 452 <vprintf>
}
 652:	60e2                	ld	ra,24(sp)
 654:	6442                	ld	s0,16(sp)
 656:	6161                	addi	sp,sp,80
 658:	8082                	ret

000000000000065a <printf>:

void
printf(const char *fmt, ...)
{
 65a:	711d                	addi	sp,sp,-96
 65c:	ec06                	sd	ra,24(sp)
 65e:	e822                	sd	s0,16(sp)
 660:	1000                	addi	s0,sp,32
 662:	e40c                	sd	a1,8(s0)
 664:	e810                	sd	a2,16(s0)
 666:	ec14                	sd	a3,24(s0)
 668:	f018                	sd	a4,32(s0)
 66a:	f41c                	sd	a5,40(s0)
 66c:	03043823          	sd	a6,48(s0)
 670:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 674:	00840613          	addi	a2,s0,8
 678:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 67c:	85aa                	mv	a1,a0
 67e:	4505                	li	a0,1
 680:	00000097          	auipc	ra,0x0
 684:	dd2080e7          	jalr	-558(ra) # 452 <vprintf>
}
 688:	60e2                	ld	ra,24(sp)
 68a:	6442                	ld	s0,16(sp)
 68c:	6125                	addi	sp,sp,96
 68e:	8082                	ret

0000000000000690 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 690:	1141                	addi	sp,sp,-16
 692:	e422                	sd	s0,8(sp)
 694:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 696:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 69a:	00000797          	auipc	a5,0x0
 69e:	18e78793          	addi	a5,a5,398 # 828 <__bss_start>
 6a2:	639c                	ld	a5,0(a5)
 6a4:	a805                	j	6d4 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6a6:	4618                	lw	a4,8(a2)
 6a8:	9db9                	addw	a1,a1,a4
 6aa:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6ae:	6398                	ld	a4,0(a5)
 6b0:	6318                	ld	a4,0(a4)
 6b2:	fee53823          	sd	a4,-16(a0)
 6b6:	a091                	j	6fa <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6b8:	ff852703          	lw	a4,-8(a0)
 6bc:	9e39                	addw	a2,a2,a4
 6be:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6c0:	ff053703          	ld	a4,-16(a0)
 6c4:	e398                	sd	a4,0(a5)
 6c6:	a099                	j	70c <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c8:	6398                	ld	a4,0(a5)
 6ca:	00e7e463          	bltu	a5,a4,6d2 <free+0x42>
 6ce:	00e6ea63          	bltu	a3,a4,6e2 <free+0x52>
{
 6d2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d4:	fed7fae3          	bleu	a3,a5,6c8 <free+0x38>
 6d8:	6398                	ld	a4,0(a5)
 6da:	00e6e463          	bltu	a3,a4,6e2 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6de:	fee7eae3          	bltu	a5,a4,6d2 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 6e2:	ff852583          	lw	a1,-8(a0)
 6e6:	6390                	ld	a2,0(a5)
 6e8:	02059713          	slli	a4,a1,0x20
 6ec:	9301                	srli	a4,a4,0x20
 6ee:	0712                	slli	a4,a4,0x4
 6f0:	9736                	add	a4,a4,a3
 6f2:	fae60ae3          	beq	a2,a4,6a6 <free+0x16>
    bp->s.ptr = p->s.ptr;
 6f6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6fa:	4790                	lw	a2,8(a5)
 6fc:	02061713          	slli	a4,a2,0x20
 700:	9301                	srli	a4,a4,0x20
 702:	0712                	slli	a4,a4,0x4
 704:	973e                	add	a4,a4,a5
 706:	fae689e3          	beq	a3,a4,6b8 <free+0x28>
  } else
    p->s.ptr = bp;
 70a:	e394                	sd	a3,0(a5)
  freep = p;
 70c:	00000717          	auipc	a4,0x0
 710:	10f73e23          	sd	a5,284(a4) # 828 <__bss_start>
}
 714:	6422                	ld	s0,8(sp)
 716:	0141                	addi	sp,sp,16
 718:	8082                	ret

000000000000071a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 71a:	7139                	addi	sp,sp,-64
 71c:	fc06                	sd	ra,56(sp)
 71e:	f822                	sd	s0,48(sp)
 720:	f426                	sd	s1,40(sp)
 722:	f04a                	sd	s2,32(sp)
 724:	ec4e                	sd	s3,24(sp)
 726:	e852                	sd	s4,16(sp)
 728:	e456                	sd	s5,8(sp)
 72a:	e05a                	sd	s6,0(sp)
 72c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 72e:	02051993          	slli	s3,a0,0x20
 732:	0209d993          	srli	s3,s3,0x20
 736:	09bd                	addi	s3,s3,15
 738:	0049d993          	srli	s3,s3,0x4
 73c:	2985                	addiw	s3,s3,1
 73e:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 742:	00000797          	auipc	a5,0x0
 746:	0e678793          	addi	a5,a5,230 # 828 <__bss_start>
 74a:	6388                	ld	a0,0(a5)
 74c:	c515                	beqz	a0,778 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 74e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 750:	4798                	lw	a4,8(a5)
 752:	03277f63          	bleu	s2,a4,790 <malloc+0x76>
 756:	8a4e                	mv	s4,s3
 758:	0009871b          	sext.w	a4,s3
 75c:	6685                	lui	a3,0x1
 75e:	00d77363          	bleu	a3,a4,764 <malloc+0x4a>
 762:	6a05                	lui	s4,0x1
 764:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 768:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 76c:	00000497          	auipc	s1,0x0
 770:	0bc48493          	addi	s1,s1,188 # 828 <__bss_start>
  if(p == (char*)-1)
 774:	5b7d                	li	s6,-1
 776:	a885                	j	7e6 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 778:	00000797          	auipc	a5,0x0
 77c:	0b878793          	addi	a5,a5,184 # 830 <base>
 780:	00000717          	auipc	a4,0x0
 784:	0af73423          	sd	a5,168(a4) # 828 <__bss_start>
 788:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 78a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 78e:	b7e1                	j	756 <malloc+0x3c>
      if(p->s.size == nunits)
 790:	02e90b63          	beq	s2,a4,7c6 <malloc+0xac>
        p->s.size -= nunits;
 794:	4137073b          	subw	a4,a4,s3
 798:	c798                	sw	a4,8(a5)
        p += p->s.size;
 79a:	1702                	slli	a4,a4,0x20
 79c:	9301                	srli	a4,a4,0x20
 79e:	0712                	slli	a4,a4,0x4
 7a0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7a2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7a6:	00000717          	auipc	a4,0x0
 7aa:	08a73123          	sd	a0,130(a4) # 828 <__bss_start>
      return (void*)(p + 1);
 7ae:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7b2:	70e2                	ld	ra,56(sp)
 7b4:	7442                	ld	s0,48(sp)
 7b6:	74a2                	ld	s1,40(sp)
 7b8:	7902                	ld	s2,32(sp)
 7ba:	69e2                	ld	s3,24(sp)
 7bc:	6a42                	ld	s4,16(sp)
 7be:	6aa2                	ld	s5,8(sp)
 7c0:	6b02                	ld	s6,0(sp)
 7c2:	6121                	addi	sp,sp,64
 7c4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7c6:	6398                	ld	a4,0(a5)
 7c8:	e118                	sd	a4,0(a0)
 7ca:	bff1                	j	7a6 <malloc+0x8c>
  hp->s.size = nu;
 7cc:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 7d0:	0541                	addi	a0,a0,16
 7d2:	00000097          	auipc	ra,0x0
 7d6:	ebe080e7          	jalr	-322(ra) # 690 <free>
  return freep;
 7da:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 7dc:	d979                	beqz	a0,7b2 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7de:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7e0:	4798                	lw	a4,8(a5)
 7e2:	fb2777e3          	bleu	s2,a4,790 <malloc+0x76>
    if(p == freep)
 7e6:	6098                	ld	a4,0(s1)
 7e8:	853e                	mv	a0,a5
 7ea:	fef71ae3          	bne	a4,a5,7de <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 7ee:	8552                	mv	a0,s4
 7f0:	00000097          	auipc	ra,0x0
 7f4:	b6a080e7          	jalr	-1174(ra) # 35a <sbrk>
  if(p == (char*)-1)
 7f8:	fd651ae3          	bne	a0,s6,7cc <malloc+0xb2>
        return 0;
 7fc:	4501                	li	a0,0
 7fe:	bf55                	j	7b2 <malloc+0x98>
