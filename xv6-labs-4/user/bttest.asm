
user/_bttest：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  sleep(1);
   8:	4505                	li	a0,1
   a:	00000097          	auipc	ra,0x0
   e:	332080e7          	jalr	818(ra) # 33c <sleep>
  exit(0);
  12:	4501                	li	a0,0
  14:	00000097          	auipc	ra,0x0
  18:	298080e7          	jalr	664(ra) # 2ac <exit>

000000000000001c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  1c:	1141                	addi	sp,sp,-16
  1e:	e422                	sd	s0,8(sp)
  20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  22:	87aa                	mv	a5,a0
  24:	0585                	addi	a1,a1,1
  26:	0785                	addi	a5,a5,1
  28:	fff5c703          	lbu	a4,-1(a1)
  2c:	fee78fa3          	sb	a4,-1(a5)
  30:	fb75                	bnez	a4,24 <strcpy+0x8>
    ;
  return os;
}
  32:	6422                	ld	s0,8(sp)
  34:	0141                	addi	sp,sp,16
  36:	8082                	ret

0000000000000038 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  38:	1141                	addi	sp,sp,-16
  3a:	e422                	sd	s0,8(sp)
  3c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  3e:	00054783          	lbu	a5,0(a0)
  42:	cf91                	beqz	a5,5e <strcmp+0x26>
  44:	0005c703          	lbu	a4,0(a1)
  48:	00f71b63          	bne	a4,a5,5e <strcmp+0x26>
    p++, q++;
  4c:	0505                	addi	a0,a0,1
  4e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  50:	00054783          	lbu	a5,0(a0)
  54:	c789                	beqz	a5,5e <strcmp+0x26>
  56:	0005c703          	lbu	a4,0(a1)
  5a:	fef709e3          	beq	a4,a5,4c <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
  5e:	0005c503          	lbu	a0,0(a1)
}
  62:	40a7853b          	subw	a0,a5,a0
  66:	6422                	ld	s0,8(sp)
  68:	0141                	addi	sp,sp,16
  6a:	8082                	ret

000000000000006c <strlen>:

uint
strlen(const char *s)
{
  6c:	1141                	addi	sp,sp,-16
  6e:	e422                	sd	s0,8(sp)
  70:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  72:	00054783          	lbu	a5,0(a0)
  76:	cf91                	beqz	a5,92 <strlen+0x26>
  78:	0505                	addi	a0,a0,1
  7a:	87aa                	mv	a5,a0
  7c:	4685                	li	a3,1
  7e:	9e89                	subw	a3,a3,a0
  80:	00f6853b          	addw	a0,a3,a5
  84:	0785                	addi	a5,a5,1
  86:	fff7c703          	lbu	a4,-1(a5)
  8a:	fb7d                	bnez	a4,80 <strlen+0x14>
    ;
  return n;
}
  8c:	6422                	ld	s0,8(sp)
  8e:	0141                	addi	sp,sp,16
  90:	8082                	ret
  for(n = 0; s[n]; n++)
  92:	4501                	li	a0,0
  94:	bfe5                	j	8c <strlen+0x20>

0000000000000096 <memset>:

void*
memset(void *dst, int c, uint n)
{
  96:	1141                	addi	sp,sp,-16
  98:	e422                	sd	s0,8(sp)
  9a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  9c:	ce09                	beqz	a2,b6 <memset+0x20>
  9e:	87aa                	mv	a5,a0
  a0:	fff6071b          	addiw	a4,a2,-1
  a4:	1702                	slli	a4,a4,0x20
  a6:	9301                	srli	a4,a4,0x20
  a8:	0705                	addi	a4,a4,1
  aa:	972a                	add	a4,a4,a0
    cdst[i] = c;
  ac:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  b0:	0785                	addi	a5,a5,1
  b2:	fee79de3          	bne	a5,a4,ac <memset+0x16>
  }
  return dst;
}
  b6:	6422                	ld	s0,8(sp)
  b8:	0141                	addi	sp,sp,16
  ba:	8082                	ret

00000000000000bc <strchr>:

char*
strchr(const char *s, char c)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e422                	sd	s0,8(sp)
  c0:	0800                	addi	s0,sp,16
  for(; *s; s++)
  c2:	00054783          	lbu	a5,0(a0)
  c6:	cf91                	beqz	a5,e2 <strchr+0x26>
    if(*s == c)
  c8:	00f58a63          	beq	a1,a5,dc <strchr+0x20>
  for(; *s; s++)
  cc:	0505                	addi	a0,a0,1
  ce:	00054783          	lbu	a5,0(a0)
  d2:	c781                	beqz	a5,da <strchr+0x1e>
    if(*s == c)
  d4:	feb79ce3          	bne	a5,a1,cc <strchr+0x10>
  d8:	a011                	j	dc <strchr+0x20>
      return (char*)s;
  return 0;
  da:	4501                	li	a0,0
}
  dc:	6422                	ld	s0,8(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret
  return 0;
  e2:	4501                	li	a0,0
  e4:	bfe5                	j	dc <strchr+0x20>

00000000000000e6 <gets>:

char*
gets(char *buf, int max)
{
  e6:	711d                	addi	sp,sp,-96
  e8:	ec86                	sd	ra,88(sp)
  ea:	e8a2                	sd	s0,80(sp)
  ec:	e4a6                	sd	s1,72(sp)
  ee:	e0ca                	sd	s2,64(sp)
  f0:	fc4e                	sd	s3,56(sp)
  f2:	f852                	sd	s4,48(sp)
  f4:	f456                	sd	s5,40(sp)
  f6:	f05a                	sd	s6,32(sp)
  f8:	ec5e                	sd	s7,24(sp)
  fa:	1080                	addi	s0,sp,96
  fc:	8baa                	mv	s7,a0
  fe:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 100:	892a                	mv	s2,a0
 102:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 104:	4aa9                	li	s5,10
 106:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 108:	0019849b          	addiw	s1,s3,1
 10c:	0344d863          	ble	s4,s1,13c <gets+0x56>
    cc = read(0, &c, 1);
 110:	4605                	li	a2,1
 112:	faf40593          	addi	a1,s0,-81
 116:	4501                	li	a0,0
 118:	00000097          	auipc	ra,0x0
 11c:	1ac080e7          	jalr	428(ra) # 2c4 <read>
    if(cc < 1)
 120:	00a05e63          	blez	a0,13c <gets+0x56>
    buf[i++] = c;
 124:	faf44783          	lbu	a5,-81(s0)
 128:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 12c:	01578763          	beq	a5,s5,13a <gets+0x54>
 130:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 132:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 134:	fd679ae3          	bne	a5,s6,108 <gets+0x22>
 138:	a011                	j	13c <gets+0x56>
  for(i=0; i+1 < max; ){
 13a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 13c:	99de                	add	s3,s3,s7
 13e:	00098023          	sb	zero,0(s3)
  return buf;
}
 142:	855e                	mv	a0,s7
 144:	60e6                	ld	ra,88(sp)
 146:	6446                	ld	s0,80(sp)
 148:	64a6                	ld	s1,72(sp)
 14a:	6906                	ld	s2,64(sp)
 14c:	79e2                	ld	s3,56(sp)
 14e:	7a42                	ld	s4,48(sp)
 150:	7aa2                	ld	s5,40(sp)
 152:	7b02                	ld	s6,32(sp)
 154:	6be2                	ld	s7,24(sp)
 156:	6125                	addi	sp,sp,96
 158:	8082                	ret

000000000000015a <stat>:

int
stat(const char *n, struct stat *st)
{
 15a:	1101                	addi	sp,sp,-32
 15c:	ec06                	sd	ra,24(sp)
 15e:	e822                	sd	s0,16(sp)
 160:	e426                	sd	s1,8(sp)
 162:	e04a                	sd	s2,0(sp)
 164:	1000                	addi	s0,sp,32
 166:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 168:	4581                	li	a1,0
 16a:	00000097          	auipc	ra,0x0
 16e:	182080e7          	jalr	386(ra) # 2ec <open>
  if(fd < 0)
 172:	02054563          	bltz	a0,19c <stat+0x42>
 176:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 178:	85ca                	mv	a1,s2
 17a:	00000097          	auipc	ra,0x0
 17e:	18a080e7          	jalr	394(ra) # 304 <fstat>
 182:	892a                	mv	s2,a0
  close(fd);
 184:	8526                	mv	a0,s1
 186:	00000097          	auipc	ra,0x0
 18a:	14e080e7          	jalr	334(ra) # 2d4 <close>
  return r;
}
 18e:	854a                	mv	a0,s2
 190:	60e2                	ld	ra,24(sp)
 192:	6442                	ld	s0,16(sp)
 194:	64a2                	ld	s1,8(sp)
 196:	6902                	ld	s2,0(sp)
 198:	6105                	addi	sp,sp,32
 19a:	8082                	ret
    return -1;
 19c:	597d                	li	s2,-1
 19e:	bfc5                	j	18e <stat+0x34>

00000000000001a0 <atoi>:

int
atoi(const char *s)
{
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e422                	sd	s0,8(sp)
 1a4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1a6:	00054683          	lbu	a3,0(a0)
 1aa:	fd06879b          	addiw	a5,a3,-48
 1ae:	0ff7f793          	andi	a5,a5,255
 1b2:	4725                	li	a4,9
 1b4:	02f76963          	bltu	a4,a5,1e6 <atoi+0x46>
 1b8:	862a                	mv	a2,a0
  n = 0;
 1ba:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1bc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1be:	0605                	addi	a2,a2,1
 1c0:	0025179b          	slliw	a5,a0,0x2
 1c4:	9fa9                	addw	a5,a5,a0
 1c6:	0017979b          	slliw	a5,a5,0x1
 1ca:	9fb5                	addw	a5,a5,a3
 1cc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1d0:	00064683          	lbu	a3,0(a2)
 1d4:	fd06871b          	addiw	a4,a3,-48
 1d8:	0ff77713          	andi	a4,a4,255
 1dc:	fee5f1e3          	bleu	a4,a1,1be <atoi+0x1e>
  return n;
}
 1e0:	6422                	ld	s0,8(sp)
 1e2:	0141                	addi	sp,sp,16
 1e4:	8082                	ret
  n = 0;
 1e6:	4501                	li	a0,0
 1e8:	bfe5                	j	1e0 <atoi+0x40>

00000000000001ea <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e422                	sd	s0,8(sp)
 1ee:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1f0:	02b57663          	bleu	a1,a0,21c <memmove+0x32>
    while(n-- > 0)
 1f4:	02c05163          	blez	a2,216 <memmove+0x2c>
 1f8:	fff6079b          	addiw	a5,a2,-1
 1fc:	1782                	slli	a5,a5,0x20
 1fe:	9381                	srli	a5,a5,0x20
 200:	0785                	addi	a5,a5,1
 202:	97aa                	add	a5,a5,a0
  dst = vdst;
 204:	872a                	mv	a4,a0
      *dst++ = *src++;
 206:	0585                	addi	a1,a1,1
 208:	0705                	addi	a4,a4,1
 20a:	fff5c683          	lbu	a3,-1(a1)
 20e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 212:	fee79ae3          	bne	a5,a4,206 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 216:	6422                	ld	s0,8(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret
    dst += n;
 21c:	00c50733          	add	a4,a0,a2
    src += n;
 220:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 222:	fec05ae3          	blez	a2,216 <memmove+0x2c>
 226:	fff6079b          	addiw	a5,a2,-1
 22a:	1782                	slli	a5,a5,0x20
 22c:	9381                	srli	a5,a5,0x20
 22e:	fff7c793          	not	a5,a5
 232:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 234:	15fd                	addi	a1,a1,-1
 236:	177d                	addi	a4,a4,-1
 238:	0005c683          	lbu	a3,0(a1)
 23c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 240:	fef71ae3          	bne	a4,a5,234 <memmove+0x4a>
 244:	bfc9                	j	216 <memmove+0x2c>

0000000000000246 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 246:	1141                	addi	sp,sp,-16
 248:	e422                	sd	s0,8(sp)
 24a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 24c:	ce15                	beqz	a2,288 <memcmp+0x42>
 24e:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 252:	00054783          	lbu	a5,0(a0)
 256:	0005c703          	lbu	a4,0(a1)
 25a:	02e79063          	bne	a5,a4,27a <memcmp+0x34>
 25e:	1682                	slli	a3,a3,0x20
 260:	9281                	srli	a3,a3,0x20
 262:	0685                	addi	a3,a3,1
 264:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 266:	0505                	addi	a0,a0,1
    p2++;
 268:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 26a:	00d50d63          	beq	a0,a3,284 <memcmp+0x3e>
    if (*p1 != *p2) {
 26e:	00054783          	lbu	a5,0(a0)
 272:	0005c703          	lbu	a4,0(a1)
 276:	fee788e3          	beq	a5,a4,266 <memcmp+0x20>
      return *p1 - *p2;
 27a:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 27e:	6422                	ld	s0,8(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret
  return 0;
 284:	4501                	li	a0,0
 286:	bfe5                	j	27e <memcmp+0x38>
 288:	4501                	li	a0,0
 28a:	bfd5                	j	27e <memcmp+0x38>

000000000000028c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e406                	sd	ra,8(sp)
 290:	e022                	sd	s0,0(sp)
 292:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 294:	00000097          	auipc	ra,0x0
 298:	f56080e7          	jalr	-170(ra) # 1ea <memmove>
}
 29c:	60a2                	ld	ra,8(sp)
 29e:	6402                	ld	s0,0(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret

00000000000002a4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2a4:	4885                	li	a7,1
 ecall
 2a6:	00000073          	ecall
 ret
 2aa:	8082                	ret

00000000000002ac <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ac:	4889                	li	a7,2
 ecall
 2ae:	00000073          	ecall
 ret
 2b2:	8082                	ret

00000000000002b4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2b4:	488d                	li	a7,3
 ecall
 2b6:	00000073          	ecall
 ret
 2ba:	8082                	ret

00000000000002bc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2bc:	4891                	li	a7,4
 ecall
 2be:	00000073          	ecall
 ret
 2c2:	8082                	ret

00000000000002c4 <read>:
.global read
read:
 li a7, SYS_read
 2c4:	4895                	li	a7,5
 ecall
 2c6:	00000073          	ecall
 ret
 2ca:	8082                	ret

00000000000002cc <write>:
.global write
write:
 li a7, SYS_write
 2cc:	48c1                	li	a7,16
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <close>:
.global close
close:
 li a7, SYS_close
 2d4:	48d5                	li	a7,21
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <kill>:
.global kill
kill:
 li a7, SYS_kill
 2dc:	4899                	li	a7,6
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2e4:	489d                	li	a7,7
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <open>:
.global open
open:
 li a7, SYS_open
 2ec:	48bd                	li	a7,15
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2f4:	48c5                	li	a7,17
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2fc:	48c9                	li	a7,18
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 304:	48a1                	li	a7,8
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <link>:
.global link
link:
 li a7, SYS_link
 30c:	48cd                	li	a7,19
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 314:	48d1                	li	a7,20
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 31c:	48a5                	li	a7,9
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <dup>:
.global dup
dup:
 li a7, SYS_dup
 324:	48a9                	li	a7,10
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 32c:	48ad                	li	a7,11
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 334:	48b1                	li	a7,12
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 33c:	48b5                	li	a7,13
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 344:	48b9                	li	a7,14
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 34c:	48d9                	li	a7,22
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 354:	48dd                	li	a7,23
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 35c:	1101                	addi	sp,sp,-32
 35e:	ec06                	sd	ra,24(sp)
 360:	e822                	sd	s0,16(sp)
 362:	1000                	addi	s0,sp,32
 364:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 368:	4605                	li	a2,1
 36a:	fef40593          	addi	a1,s0,-17
 36e:	00000097          	auipc	ra,0x0
 372:	f5e080e7          	jalr	-162(ra) # 2cc <write>
}
 376:	60e2                	ld	ra,24(sp)
 378:	6442                	ld	s0,16(sp)
 37a:	6105                	addi	sp,sp,32
 37c:	8082                	ret

000000000000037e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 37e:	7139                	addi	sp,sp,-64
 380:	fc06                	sd	ra,56(sp)
 382:	f822                	sd	s0,48(sp)
 384:	f426                	sd	s1,40(sp)
 386:	f04a                	sd	s2,32(sp)
 388:	ec4e                	sd	s3,24(sp)
 38a:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 38c:	c299                	beqz	a3,392 <printint+0x14>
 38e:	0005cd63          	bltz	a1,3a8 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 392:	2581                	sext.w	a1,a1
  neg = 0;
 394:	4301                	li	t1,0
 396:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 39a:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 39c:	2601                	sext.w	a2,a2
 39e:	00000897          	auipc	a7,0x0
 3a2:	44288893          	addi	a7,a7,1090 # 7e0 <digits>
 3a6:	a801                	j	3b6 <printint+0x38>
    x = -xx;
 3a8:	40b005bb          	negw	a1,a1
 3ac:	2581                	sext.w	a1,a1
    neg = 1;
 3ae:	4305                	li	t1,1
    x = -xx;
 3b0:	b7dd                	j	396 <printint+0x18>
  }while((x /= base) != 0);
 3b2:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 3b4:	8836                	mv	a6,a3
 3b6:	0018069b          	addiw	a3,a6,1
 3ba:	02c5f7bb          	remuw	a5,a1,a2
 3be:	1782                	slli	a5,a5,0x20
 3c0:	9381                	srli	a5,a5,0x20
 3c2:	97c6                	add	a5,a5,a7
 3c4:	0007c783          	lbu	a5,0(a5)
 3c8:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 3cc:	0705                	addi	a4,a4,1
 3ce:	02c5d7bb          	divuw	a5,a1,a2
 3d2:	fec5f0e3          	bleu	a2,a1,3b2 <printint+0x34>
  if(neg)
 3d6:	00030b63          	beqz	t1,3ec <printint+0x6e>
    buf[i++] = '-';
 3da:	fd040793          	addi	a5,s0,-48
 3de:	96be                	add	a3,a3,a5
 3e0:	02d00793          	li	a5,45
 3e4:	fef68823          	sb	a5,-16(a3)
 3e8:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 3ec:	02d05963          	blez	a3,41e <printint+0xa0>
 3f0:	89aa                	mv	s3,a0
 3f2:	fc040793          	addi	a5,s0,-64
 3f6:	00d784b3          	add	s1,a5,a3
 3fa:	fff78913          	addi	s2,a5,-1
 3fe:	9936                	add	s2,s2,a3
 400:	36fd                	addiw	a3,a3,-1
 402:	1682                	slli	a3,a3,0x20
 404:	9281                	srli	a3,a3,0x20
 406:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 40a:	fff4c583          	lbu	a1,-1(s1)
 40e:	854e                	mv	a0,s3
 410:	00000097          	auipc	ra,0x0
 414:	f4c080e7          	jalr	-180(ra) # 35c <putc>
  while(--i >= 0)
 418:	14fd                	addi	s1,s1,-1
 41a:	ff2498e3          	bne	s1,s2,40a <printint+0x8c>
}
 41e:	70e2                	ld	ra,56(sp)
 420:	7442                	ld	s0,48(sp)
 422:	74a2                	ld	s1,40(sp)
 424:	7902                	ld	s2,32(sp)
 426:	69e2                	ld	s3,24(sp)
 428:	6121                	addi	sp,sp,64
 42a:	8082                	ret

000000000000042c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 42c:	7119                	addi	sp,sp,-128
 42e:	fc86                	sd	ra,120(sp)
 430:	f8a2                	sd	s0,112(sp)
 432:	f4a6                	sd	s1,104(sp)
 434:	f0ca                	sd	s2,96(sp)
 436:	ecce                	sd	s3,88(sp)
 438:	e8d2                	sd	s4,80(sp)
 43a:	e4d6                	sd	s5,72(sp)
 43c:	e0da                	sd	s6,64(sp)
 43e:	fc5e                	sd	s7,56(sp)
 440:	f862                	sd	s8,48(sp)
 442:	f466                	sd	s9,40(sp)
 444:	f06a                	sd	s10,32(sp)
 446:	ec6e                	sd	s11,24(sp)
 448:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 44a:	0005c483          	lbu	s1,0(a1)
 44e:	18048d63          	beqz	s1,5e8 <vprintf+0x1bc>
 452:	8aaa                	mv	s5,a0
 454:	8b32                	mv	s6,a2
 456:	00158913          	addi	s2,a1,1
  state = 0;
 45a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 45c:	02500a13          	li	s4,37
      if(c == 'd'){
 460:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 464:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 468:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 46c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 470:	00000b97          	auipc	s7,0x0
 474:	370b8b93          	addi	s7,s7,880 # 7e0 <digits>
 478:	a839                	j	496 <vprintf+0x6a>
        putc(fd, c);
 47a:	85a6                	mv	a1,s1
 47c:	8556                	mv	a0,s5
 47e:	00000097          	auipc	ra,0x0
 482:	ede080e7          	jalr	-290(ra) # 35c <putc>
 486:	a019                	j	48c <vprintf+0x60>
    } else if(state == '%'){
 488:	01498f63          	beq	s3,s4,4a6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 48c:	0905                	addi	s2,s2,1
 48e:	fff94483          	lbu	s1,-1(s2)
 492:	14048b63          	beqz	s1,5e8 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 496:	0004879b          	sext.w	a5,s1
    if(state == 0){
 49a:	fe0997e3          	bnez	s3,488 <vprintf+0x5c>
      if(c == '%'){
 49e:	fd479ee3          	bne	a5,s4,47a <vprintf+0x4e>
        state = '%';
 4a2:	89be                	mv	s3,a5
 4a4:	b7e5                	j	48c <vprintf+0x60>
      if(c == 'd'){
 4a6:	05878063          	beq	a5,s8,4e6 <vprintf+0xba>
      } else if(c == 'l') {
 4aa:	05978c63          	beq	a5,s9,502 <vprintf+0xd6>
      } else if(c == 'x') {
 4ae:	07a78863          	beq	a5,s10,51e <vprintf+0xf2>
      } else if(c == 'p') {
 4b2:	09b78463          	beq	a5,s11,53a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4b6:	07300713          	li	a4,115
 4ba:	0ce78563          	beq	a5,a4,584 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4be:	06300713          	li	a4,99
 4c2:	0ee78c63          	beq	a5,a4,5ba <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4c6:	11478663          	beq	a5,s4,5d2 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4ca:	85d2                	mv	a1,s4
 4cc:	8556                	mv	a0,s5
 4ce:	00000097          	auipc	ra,0x0
 4d2:	e8e080e7          	jalr	-370(ra) # 35c <putc>
        putc(fd, c);
 4d6:	85a6                	mv	a1,s1
 4d8:	8556                	mv	a0,s5
 4da:	00000097          	auipc	ra,0x0
 4de:	e82080e7          	jalr	-382(ra) # 35c <putc>
      }
      state = 0;
 4e2:	4981                	li	s3,0
 4e4:	b765                	j	48c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4e6:	008b0493          	addi	s1,s6,8
 4ea:	4685                	li	a3,1
 4ec:	4629                	li	a2,10
 4ee:	000b2583          	lw	a1,0(s6)
 4f2:	8556                	mv	a0,s5
 4f4:	00000097          	auipc	ra,0x0
 4f8:	e8a080e7          	jalr	-374(ra) # 37e <printint>
 4fc:	8b26                	mv	s6,s1
      state = 0;
 4fe:	4981                	li	s3,0
 500:	b771                	j	48c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 502:	008b0493          	addi	s1,s6,8
 506:	4681                	li	a3,0
 508:	4629                	li	a2,10
 50a:	000b2583          	lw	a1,0(s6)
 50e:	8556                	mv	a0,s5
 510:	00000097          	auipc	ra,0x0
 514:	e6e080e7          	jalr	-402(ra) # 37e <printint>
 518:	8b26                	mv	s6,s1
      state = 0;
 51a:	4981                	li	s3,0
 51c:	bf85                	j	48c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 51e:	008b0493          	addi	s1,s6,8
 522:	4681                	li	a3,0
 524:	4641                	li	a2,16
 526:	000b2583          	lw	a1,0(s6)
 52a:	8556                	mv	a0,s5
 52c:	00000097          	auipc	ra,0x0
 530:	e52080e7          	jalr	-430(ra) # 37e <printint>
 534:	8b26                	mv	s6,s1
      state = 0;
 536:	4981                	li	s3,0
 538:	bf91                	j	48c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 53a:	008b0793          	addi	a5,s6,8
 53e:	f8f43423          	sd	a5,-120(s0)
 542:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 546:	03000593          	li	a1,48
 54a:	8556                	mv	a0,s5
 54c:	00000097          	auipc	ra,0x0
 550:	e10080e7          	jalr	-496(ra) # 35c <putc>
  putc(fd, 'x');
 554:	85ea                	mv	a1,s10
 556:	8556                	mv	a0,s5
 558:	00000097          	auipc	ra,0x0
 55c:	e04080e7          	jalr	-508(ra) # 35c <putc>
 560:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 562:	03c9d793          	srli	a5,s3,0x3c
 566:	97de                	add	a5,a5,s7
 568:	0007c583          	lbu	a1,0(a5)
 56c:	8556                	mv	a0,s5
 56e:	00000097          	auipc	ra,0x0
 572:	dee080e7          	jalr	-530(ra) # 35c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 576:	0992                	slli	s3,s3,0x4
 578:	34fd                	addiw	s1,s1,-1
 57a:	f4e5                	bnez	s1,562 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 57c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 580:	4981                	li	s3,0
 582:	b729                	j	48c <vprintf+0x60>
        s = va_arg(ap, char*);
 584:	008b0993          	addi	s3,s6,8
 588:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 58c:	c085                	beqz	s1,5ac <vprintf+0x180>
        while(*s != 0){
 58e:	0004c583          	lbu	a1,0(s1)
 592:	c9a1                	beqz	a1,5e2 <vprintf+0x1b6>
          putc(fd, *s);
 594:	8556                	mv	a0,s5
 596:	00000097          	auipc	ra,0x0
 59a:	dc6080e7          	jalr	-570(ra) # 35c <putc>
          s++;
 59e:	0485                	addi	s1,s1,1
        while(*s != 0){
 5a0:	0004c583          	lbu	a1,0(s1)
 5a4:	f9e5                	bnez	a1,594 <vprintf+0x168>
        s = va_arg(ap, char*);
 5a6:	8b4e                	mv	s6,s3
      state = 0;
 5a8:	4981                	li	s3,0
 5aa:	b5cd                	j	48c <vprintf+0x60>
          s = "(null)";
 5ac:	00000497          	auipc	s1,0x0
 5b0:	24c48493          	addi	s1,s1,588 # 7f8 <digits+0x18>
        while(*s != 0){
 5b4:	02800593          	li	a1,40
 5b8:	bff1                	j	594 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 5ba:	008b0493          	addi	s1,s6,8
 5be:	000b4583          	lbu	a1,0(s6)
 5c2:	8556                	mv	a0,s5
 5c4:	00000097          	auipc	ra,0x0
 5c8:	d98080e7          	jalr	-616(ra) # 35c <putc>
 5cc:	8b26                	mv	s6,s1
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	bd75                	j	48c <vprintf+0x60>
        putc(fd, c);
 5d2:	85d2                	mv	a1,s4
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	d86080e7          	jalr	-634(ra) # 35c <putc>
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	b575                	j	48c <vprintf+0x60>
        s = va_arg(ap, char*);
 5e2:	8b4e                	mv	s6,s3
      state = 0;
 5e4:	4981                	li	s3,0
 5e6:	b55d                	j	48c <vprintf+0x60>
    }
  }
}
 5e8:	70e6                	ld	ra,120(sp)
 5ea:	7446                	ld	s0,112(sp)
 5ec:	74a6                	ld	s1,104(sp)
 5ee:	7906                	ld	s2,96(sp)
 5f0:	69e6                	ld	s3,88(sp)
 5f2:	6a46                	ld	s4,80(sp)
 5f4:	6aa6                	ld	s5,72(sp)
 5f6:	6b06                	ld	s6,64(sp)
 5f8:	7be2                	ld	s7,56(sp)
 5fa:	7c42                	ld	s8,48(sp)
 5fc:	7ca2                	ld	s9,40(sp)
 5fe:	7d02                	ld	s10,32(sp)
 600:	6de2                	ld	s11,24(sp)
 602:	6109                	addi	sp,sp,128
 604:	8082                	ret

0000000000000606 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 606:	715d                	addi	sp,sp,-80
 608:	ec06                	sd	ra,24(sp)
 60a:	e822                	sd	s0,16(sp)
 60c:	1000                	addi	s0,sp,32
 60e:	e010                	sd	a2,0(s0)
 610:	e414                	sd	a3,8(s0)
 612:	e818                	sd	a4,16(s0)
 614:	ec1c                	sd	a5,24(s0)
 616:	03043023          	sd	a6,32(s0)
 61a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 61e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 622:	8622                	mv	a2,s0
 624:	00000097          	auipc	ra,0x0
 628:	e08080e7          	jalr	-504(ra) # 42c <vprintf>
}
 62c:	60e2                	ld	ra,24(sp)
 62e:	6442                	ld	s0,16(sp)
 630:	6161                	addi	sp,sp,80
 632:	8082                	ret

0000000000000634 <printf>:

void
printf(const char *fmt, ...)
{
 634:	711d                	addi	sp,sp,-96
 636:	ec06                	sd	ra,24(sp)
 638:	e822                	sd	s0,16(sp)
 63a:	1000                	addi	s0,sp,32
 63c:	e40c                	sd	a1,8(s0)
 63e:	e810                	sd	a2,16(s0)
 640:	ec14                	sd	a3,24(s0)
 642:	f018                	sd	a4,32(s0)
 644:	f41c                	sd	a5,40(s0)
 646:	03043823          	sd	a6,48(s0)
 64a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 64e:	00840613          	addi	a2,s0,8
 652:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 656:	85aa                	mv	a1,a0
 658:	4505                	li	a0,1
 65a:	00000097          	auipc	ra,0x0
 65e:	dd2080e7          	jalr	-558(ra) # 42c <vprintf>
}
 662:	60e2                	ld	ra,24(sp)
 664:	6442                	ld	s0,16(sp)
 666:	6125                	addi	sp,sp,96
 668:	8082                	ret

000000000000066a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 66a:	1141                	addi	sp,sp,-16
 66c:	e422                	sd	s0,8(sp)
 66e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 670:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 674:	00000797          	auipc	a5,0x0
 678:	18c78793          	addi	a5,a5,396 # 800 <__bss_start>
 67c:	639c                	ld	a5,0(a5)
 67e:	a805                	j	6ae <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 680:	4618                	lw	a4,8(a2)
 682:	9db9                	addw	a1,a1,a4
 684:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 688:	6398                	ld	a4,0(a5)
 68a:	6318                	ld	a4,0(a4)
 68c:	fee53823          	sd	a4,-16(a0)
 690:	a091                	j	6d4 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 692:	ff852703          	lw	a4,-8(a0)
 696:	9e39                	addw	a2,a2,a4
 698:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 69a:	ff053703          	ld	a4,-16(a0)
 69e:	e398                	sd	a4,0(a5)
 6a0:	a099                	j	6e6 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6a2:	6398                	ld	a4,0(a5)
 6a4:	00e7e463          	bltu	a5,a4,6ac <free+0x42>
 6a8:	00e6ea63          	bltu	a3,a4,6bc <free+0x52>
{
 6ac:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ae:	fed7fae3          	bleu	a3,a5,6a2 <free+0x38>
 6b2:	6398                	ld	a4,0(a5)
 6b4:	00e6e463          	bltu	a3,a4,6bc <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b8:	fee7eae3          	bltu	a5,a4,6ac <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 6bc:	ff852583          	lw	a1,-8(a0)
 6c0:	6390                	ld	a2,0(a5)
 6c2:	02059713          	slli	a4,a1,0x20
 6c6:	9301                	srli	a4,a4,0x20
 6c8:	0712                	slli	a4,a4,0x4
 6ca:	9736                	add	a4,a4,a3
 6cc:	fae60ae3          	beq	a2,a4,680 <free+0x16>
    bp->s.ptr = p->s.ptr;
 6d0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6d4:	4790                	lw	a2,8(a5)
 6d6:	02061713          	slli	a4,a2,0x20
 6da:	9301                	srli	a4,a4,0x20
 6dc:	0712                	slli	a4,a4,0x4
 6de:	973e                	add	a4,a4,a5
 6e0:	fae689e3          	beq	a3,a4,692 <free+0x28>
  } else
    p->s.ptr = bp;
 6e4:	e394                	sd	a3,0(a5)
  freep = p;
 6e6:	00000717          	auipc	a4,0x0
 6ea:	10f73d23          	sd	a5,282(a4) # 800 <__bss_start>
}
 6ee:	6422                	ld	s0,8(sp)
 6f0:	0141                	addi	sp,sp,16
 6f2:	8082                	ret

00000000000006f4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6f4:	7139                	addi	sp,sp,-64
 6f6:	fc06                	sd	ra,56(sp)
 6f8:	f822                	sd	s0,48(sp)
 6fa:	f426                	sd	s1,40(sp)
 6fc:	f04a                	sd	s2,32(sp)
 6fe:	ec4e                	sd	s3,24(sp)
 700:	e852                	sd	s4,16(sp)
 702:	e456                	sd	s5,8(sp)
 704:	e05a                	sd	s6,0(sp)
 706:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 708:	02051993          	slli	s3,a0,0x20
 70c:	0209d993          	srli	s3,s3,0x20
 710:	09bd                	addi	s3,s3,15
 712:	0049d993          	srli	s3,s3,0x4
 716:	2985                	addiw	s3,s3,1
 718:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 71c:	00000797          	auipc	a5,0x0
 720:	0e478793          	addi	a5,a5,228 # 800 <__bss_start>
 724:	6388                	ld	a0,0(a5)
 726:	c515                	beqz	a0,752 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 728:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 72a:	4798                	lw	a4,8(a5)
 72c:	03277f63          	bleu	s2,a4,76a <malloc+0x76>
 730:	8a4e                	mv	s4,s3
 732:	0009871b          	sext.w	a4,s3
 736:	6685                	lui	a3,0x1
 738:	00d77363          	bleu	a3,a4,73e <malloc+0x4a>
 73c:	6a05                	lui	s4,0x1
 73e:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 742:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 746:	00000497          	auipc	s1,0x0
 74a:	0ba48493          	addi	s1,s1,186 # 800 <__bss_start>
  if(p == (char*)-1)
 74e:	5b7d                	li	s6,-1
 750:	a885                	j	7c0 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 752:	00000797          	auipc	a5,0x0
 756:	0b678793          	addi	a5,a5,182 # 808 <base>
 75a:	00000717          	auipc	a4,0x0
 75e:	0af73323          	sd	a5,166(a4) # 800 <__bss_start>
 762:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 764:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 768:	b7e1                	j	730 <malloc+0x3c>
      if(p->s.size == nunits)
 76a:	02e90b63          	beq	s2,a4,7a0 <malloc+0xac>
        p->s.size -= nunits;
 76e:	4137073b          	subw	a4,a4,s3
 772:	c798                	sw	a4,8(a5)
        p += p->s.size;
 774:	1702                	slli	a4,a4,0x20
 776:	9301                	srli	a4,a4,0x20
 778:	0712                	slli	a4,a4,0x4
 77a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 77c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 780:	00000717          	auipc	a4,0x0
 784:	08a73023          	sd	a0,128(a4) # 800 <__bss_start>
      return (void*)(p + 1);
 788:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 78c:	70e2                	ld	ra,56(sp)
 78e:	7442                	ld	s0,48(sp)
 790:	74a2                	ld	s1,40(sp)
 792:	7902                	ld	s2,32(sp)
 794:	69e2                	ld	s3,24(sp)
 796:	6a42                	ld	s4,16(sp)
 798:	6aa2                	ld	s5,8(sp)
 79a:	6b02                	ld	s6,0(sp)
 79c:	6121                	addi	sp,sp,64
 79e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7a0:	6398                	ld	a4,0(a5)
 7a2:	e118                	sd	a4,0(a0)
 7a4:	bff1                	j	780 <malloc+0x8c>
  hp->s.size = nu;
 7a6:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 7aa:	0541                	addi	a0,a0,16
 7ac:	00000097          	auipc	ra,0x0
 7b0:	ebe080e7          	jalr	-322(ra) # 66a <free>
  return freep;
 7b4:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 7b6:	d979                	beqz	a0,78c <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ba:	4798                	lw	a4,8(a5)
 7bc:	fb2777e3          	bleu	s2,a4,76a <malloc+0x76>
    if(p == freep)
 7c0:	6098                	ld	a4,0(s1)
 7c2:	853e                	mv	a0,a5
 7c4:	fef71ae3          	bne	a4,a5,7b8 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 7c8:	8552                	mv	a0,s4
 7ca:	00000097          	auipc	ra,0x0
 7ce:	b6a080e7          	jalr	-1174(ra) # 334 <sbrk>
  if(p == (char*)-1)
 7d2:	fd651ae3          	bne	a0,s6,7a6 <malloc+0xb2>
        return 0;
 7d6:	4501                	li	a0,0
 7d8:	bf55                	j	78c <malloc+0x98>
