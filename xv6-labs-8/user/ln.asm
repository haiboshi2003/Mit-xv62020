
user/_ln：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  if(argc != 3){
   a:	478d                	li	a5,3
   c:	02f50063          	beq	a0,a5,2c <main+0x2c>
    fprintf(2, "Usage: ln old new\n");
  10:	00001597          	auipc	a1,0x1
  14:	88858593          	addi	a1,a1,-1912 # 898 <statistics+0x8a>
  18:	4509                	li	a0,2
  1a:	00000097          	auipc	ra,0x0
  1e:	620080e7          	jalr	1568(ra) # 63a <fprintf>
    exit(1);
  22:	4505                	li	a0,1
  24:	00000097          	auipc	ra,0x0
  28:	2cc080e7          	jalr	716(ra) # 2f0 <exit>
  2c:	84ae                	mv	s1,a1
  }
  if(link(argv[1], argv[2]) < 0)
  2e:	698c                	ld	a1,16(a1)
  30:	6488                	ld	a0,8(s1)
  32:	00000097          	auipc	ra,0x0
  36:	31e080e7          	jalr	798(ra) # 350 <link>
  3a:	00054763          	bltz	a0,48 <main+0x48>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2b0080e7          	jalr	688(ra) # 2f0 <exit>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  48:	6894                	ld	a3,16(s1)
  4a:	6490                	ld	a2,8(s1)
  4c:	00001597          	auipc	a1,0x1
  50:	86458593          	addi	a1,a1,-1948 # 8b0 <statistics+0xa2>
  54:	4509                	li	a0,2
  56:	00000097          	auipc	ra,0x0
  5a:	5e4080e7          	jalr	1508(ra) # 63a <fprintf>
  5e:	b7c5                	j	3e <main+0x3e>

0000000000000060 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  60:	1141                	addi	sp,sp,-16
  62:	e422                	sd	s0,8(sp)
  64:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  66:	87aa                	mv	a5,a0
  68:	0585                	addi	a1,a1,1
  6a:	0785                	addi	a5,a5,1
  6c:	fff5c703          	lbu	a4,-1(a1)
  70:	fee78fa3          	sb	a4,-1(a5)
  74:	fb75                	bnez	a4,68 <strcpy+0x8>
    ;
  return os;
}
  76:	6422                	ld	s0,8(sp)
  78:	0141                	addi	sp,sp,16
  7a:	8082                	ret

000000000000007c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7c:	1141                	addi	sp,sp,-16
  7e:	e422                	sd	s0,8(sp)
  80:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  82:	00054783          	lbu	a5,0(a0)
  86:	cf91                	beqz	a5,a2 <strcmp+0x26>
  88:	0005c703          	lbu	a4,0(a1)
  8c:	00f71b63          	bne	a4,a5,a2 <strcmp+0x26>
    p++, q++;
  90:	0505                	addi	a0,a0,1
  92:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  94:	00054783          	lbu	a5,0(a0)
  98:	c789                	beqz	a5,a2 <strcmp+0x26>
  9a:	0005c703          	lbu	a4,0(a1)
  9e:	fef709e3          	beq	a4,a5,90 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
  a2:	0005c503          	lbu	a0,0(a1)
}
  a6:	40a7853b          	subw	a0,a5,a0
  aa:	6422                	ld	s0,8(sp)
  ac:	0141                	addi	sp,sp,16
  ae:	8082                	ret

00000000000000b0 <strlen>:

uint
strlen(const char *s)
{
  b0:	1141                	addi	sp,sp,-16
  b2:	e422                	sd	s0,8(sp)
  b4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  b6:	00054783          	lbu	a5,0(a0)
  ba:	cf91                	beqz	a5,d6 <strlen+0x26>
  bc:	0505                	addi	a0,a0,1
  be:	87aa                	mv	a5,a0
  c0:	4685                	li	a3,1
  c2:	9e89                	subw	a3,a3,a0
  c4:	00f6853b          	addw	a0,a3,a5
  c8:	0785                	addi	a5,a5,1
  ca:	fff7c703          	lbu	a4,-1(a5)
  ce:	fb7d                	bnez	a4,c4 <strlen+0x14>
    ;
  return n;
}
  d0:	6422                	ld	s0,8(sp)
  d2:	0141                	addi	sp,sp,16
  d4:	8082                	ret
  for(n = 0; s[n]; n++)
  d6:	4501                	li	a0,0
  d8:	bfe5                	j	d0 <strlen+0x20>

00000000000000da <memset>:

void*
memset(void *dst, int c, uint n)
{
  da:	1141                	addi	sp,sp,-16
  dc:	e422                	sd	s0,8(sp)
  de:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  e0:	ce09                	beqz	a2,fa <memset+0x20>
  e2:	87aa                	mv	a5,a0
  e4:	fff6071b          	addiw	a4,a2,-1
  e8:	1702                	slli	a4,a4,0x20
  ea:	9301                	srli	a4,a4,0x20
  ec:	0705                	addi	a4,a4,1
  ee:	972a                	add	a4,a4,a0
    cdst[i] = c;
  f0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  f4:	0785                	addi	a5,a5,1
  f6:	fee79de3          	bne	a5,a4,f0 <memset+0x16>
  }
  return dst;
}
  fa:	6422                	ld	s0,8(sp)
  fc:	0141                	addi	sp,sp,16
  fe:	8082                	ret

0000000000000100 <strchr>:

char*
strchr(const char *s, char c)
{
 100:	1141                	addi	sp,sp,-16
 102:	e422                	sd	s0,8(sp)
 104:	0800                	addi	s0,sp,16
  for(; *s; s++)
 106:	00054783          	lbu	a5,0(a0)
 10a:	cf91                	beqz	a5,126 <strchr+0x26>
    if(*s == c)
 10c:	00f58a63          	beq	a1,a5,120 <strchr+0x20>
  for(; *s; s++)
 110:	0505                	addi	a0,a0,1
 112:	00054783          	lbu	a5,0(a0)
 116:	c781                	beqz	a5,11e <strchr+0x1e>
    if(*s == c)
 118:	feb79ce3          	bne	a5,a1,110 <strchr+0x10>
 11c:	a011                	j	120 <strchr+0x20>
      return (char*)s;
  return 0;
 11e:	4501                	li	a0,0
}
 120:	6422                	ld	s0,8(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret
  return 0;
 126:	4501                	li	a0,0
 128:	bfe5                	j	120 <strchr+0x20>

000000000000012a <gets>:

char*
gets(char *buf, int max)
{
 12a:	711d                	addi	sp,sp,-96
 12c:	ec86                	sd	ra,88(sp)
 12e:	e8a2                	sd	s0,80(sp)
 130:	e4a6                	sd	s1,72(sp)
 132:	e0ca                	sd	s2,64(sp)
 134:	fc4e                	sd	s3,56(sp)
 136:	f852                	sd	s4,48(sp)
 138:	f456                	sd	s5,40(sp)
 13a:	f05a                	sd	s6,32(sp)
 13c:	ec5e                	sd	s7,24(sp)
 13e:	1080                	addi	s0,sp,96
 140:	8baa                	mv	s7,a0
 142:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 144:	892a                	mv	s2,a0
 146:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 148:	4aa9                	li	s5,10
 14a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 14c:	0019849b          	addiw	s1,s3,1
 150:	0344d863          	ble	s4,s1,180 <gets+0x56>
    cc = read(0, &c, 1);
 154:	4605                	li	a2,1
 156:	faf40593          	addi	a1,s0,-81
 15a:	4501                	li	a0,0
 15c:	00000097          	auipc	ra,0x0
 160:	1ac080e7          	jalr	428(ra) # 308 <read>
    if(cc < 1)
 164:	00a05e63          	blez	a0,180 <gets+0x56>
    buf[i++] = c;
 168:	faf44783          	lbu	a5,-81(s0)
 16c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 170:	01578763          	beq	a5,s5,17e <gets+0x54>
 174:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 176:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 178:	fd679ae3          	bne	a5,s6,14c <gets+0x22>
 17c:	a011                	j	180 <gets+0x56>
  for(i=0; i+1 < max; ){
 17e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 180:	99de                	add	s3,s3,s7
 182:	00098023          	sb	zero,0(s3)
  return buf;
}
 186:	855e                	mv	a0,s7
 188:	60e6                	ld	ra,88(sp)
 18a:	6446                	ld	s0,80(sp)
 18c:	64a6                	ld	s1,72(sp)
 18e:	6906                	ld	s2,64(sp)
 190:	79e2                	ld	s3,56(sp)
 192:	7a42                	ld	s4,48(sp)
 194:	7aa2                	ld	s5,40(sp)
 196:	7b02                	ld	s6,32(sp)
 198:	6be2                	ld	s7,24(sp)
 19a:	6125                	addi	sp,sp,96
 19c:	8082                	ret

000000000000019e <stat>:

int
stat(const char *n, struct stat *st)
{
 19e:	1101                	addi	sp,sp,-32
 1a0:	ec06                	sd	ra,24(sp)
 1a2:	e822                	sd	s0,16(sp)
 1a4:	e426                	sd	s1,8(sp)
 1a6:	e04a                	sd	s2,0(sp)
 1a8:	1000                	addi	s0,sp,32
 1aa:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ac:	4581                	li	a1,0
 1ae:	00000097          	auipc	ra,0x0
 1b2:	182080e7          	jalr	386(ra) # 330 <open>
  if(fd < 0)
 1b6:	02054563          	bltz	a0,1e0 <stat+0x42>
 1ba:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1bc:	85ca                	mv	a1,s2
 1be:	00000097          	auipc	ra,0x0
 1c2:	18a080e7          	jalr	394(ra) # 348 <fstat>
 1c6:	892a                	mv	s2,a0
  close(fd);
 1c8:	8526                	mv	a0,s1
 1ca:	00000097          	auipc	ra,0x0
 1ce:	14e080e7          	jalr	334(ra) # 318 <close>
  return r;
}
 1d2:	854a                	mv	a0,s2
 1d4:	60e2                	ld	ra,24(sp)
 1d6:	6442                	ld	s0,16(sp)
 1d8:	64a2                	ld	s1,8(sp)
 1da:	6902                	ld	s2,0(sp)
 1dc:	6105                	addi	sp,sp,32
 1de:	8082                	ret
    return -1;
 1e0:	597d                	li	s2,-1
 1e2:	bfc5                	j	1d2 <stat+0x34>

00000000000001e4 <atoi>:

int
atoi(const char *s)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ea:	00054683          	lbu	a3,0(a0)
 1ee:	fd06879b          	addiw	a5,a3,-48
 1f2:	0ff7f793          	andi	a5,a5,255
 1f6:	4725                	li	a4,9
 1f8:	02f76963          	bltu	a4,a5,22a <atoi+0x46>
 1fc:	862a                	mv	a2,a0
  n = 0;
 1fe:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 200:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 202:	0605                	addi	a2,a2,1
 204:	0025179b          	slliw	a5,a0,0x2
 208:	9fa9                	addw	a5,a5,a0
 20a:	0017979b          	slliw	a5,a5,0x1
 20e:	9fb5                	addw	a5,a5,a3
 210:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 214:	00064683          	lbu	a3,0(a2)
 218:	fd06871b          	addiw	a4,a3,-48
 21c:	0ff77713          	andi	a4,a4,255
 220:	fee5f1e3          	bleu	a4,a1,202 <atoi+0x1e>
  return n;
}
 224:	6422                	ld	s0,8(sp)
 226:	0141                	addi	sp,sp,16
 228:	8082                	ret
  n = 0;
 22a:	4501                	li	a0,0
 22c:	bfe5                	j	224 <atoi+0x40>

000000000000022e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 234:	02b57663          	bleu	a1,a0,260 <memmove+0x32>
    while(n-- > 0)
 238:	02c05163          	blez	a2,25a <memmove+0x2c>
 23c:	fff6079b          	addiw	a5,a2,-1
 240:	1782                	slli	a5,a5,0x20
 242:	9381                	srli	a5,a5,0x20
 244:	0785                	addi	a5,a5,1
 246:	97aa                	add	a5,a5,a0
  dst = vdst;
 248:	872a                	mv	a4,a0
      *dst++ = *src++;
 24a:	0585                	addi	a1,a1,1
 24c:	0705                	addi	a4,a4,1
 24e:	fff5c683          	lbu	a3,-1(a1)
 252:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 256:	fee79ae3          	bne	a5,a4,24a <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 25a:	6422                	ld	s0,8(sp)
 25c:	0141                	addi	sp,sp,16
 25e:	8082                	ret
    dst += n;
 260:	00c50733          	add	a4,a0,a2
    src += n;
 264:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 266:	fec05ae3          	blez	a2,25a <memmove+0x2c>
 26a:	fff6079b          	addiw	a5,a2,-1
 26e:	1782                	slli	a5,a5,0x20
 270:	9381                	srli	a5,a5,0x20
 272:	fff7c793          	not	a5,a5
 276:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 278:	15fd                	addi	a1,a1,-1
 27a:	177d                	addi	a4,a4,-1
 27c:	0005c683          	lbu	a3,0(a1)
 280:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 284:	fef71ae3          	bne	a4,a5,278 <memmove+0x4a>
 288:	bfc9                	j	25a <memmove+0x2c>

000000000000028a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 28a:	1141                	addi	sp,sp,-16
 28c:	e422                	sd	s0,8(sp)
 28e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 290:	ce15                	beqz	a2,2cc <memcmp+0x42>
 292:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 296:	00054783          	lbu	a5,0(a0)
 29a:	0005c703          	lbu	a4,0(a1)
 29e:	02e79063          	bne	a5,a4,2be <memcmp+0x34>
 2a2:	1682                	slli	a3,a3,0x20
 2a4:	9281                	srli	a3,a3,0x20
 2a6:	0685                	addi	a3,a3,1
 2a8:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 2aa:	0505                	addi	a0,a0,1
    p2++;
 2ac:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2ae:	00d50d63          	beq	a0,a3,2c8 <memcmp+0x3e>
    if (*p1 != *p2) {
 2b2:	00054783          	lbu	a5,0(a0)
 2b6:	0005c703          	lbu	a4,0(a1)
 2ba:	fee788e3          	beq	a5,a4,2aa <memcmp+0x20>
      return *p1 - *p2;
 2be:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 2c2:	6422                	ld	s0,8(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret
  return 0;
 2c8:	4501                	li	a0,0
 2ca:	bfe5                	j	2c2 <memcmp+0x38>
 2cc:	4501                	li	a0,0
 2ce:	bfd5                	j	2c2 <memcmp+0x38>

00000000000002d0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e406                	sd	ra,8(sp)
 2d4:	e022                	sd	s0,0(sp)
 2d6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2d8:	00000097          	auipc	ra,0x0
 2dc:	f56080e7          	jalr	-170(ra) # 22e <memmove>
}
 2e0:	60a2                	ld	ra,8(sp)
 2e2:	6402                	ld	s0,0(sp)
 2e4:	0141                	addi	sp,sp,16
 2e6:	8082                	ret

00000000000002e8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e8:	4885                	li	a7,1
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2f0:	4889                	li	a7,2
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f8:	488d                	li	a7,3
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 300:	4891                	li	a7,4
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <read>:
.global read
read:
 li a7, SYS_read
 308:	4895                	li	a7,5
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <write>:
.global write
write:
 li a7, SYS_write
 310:	48c1                	li	a7,16
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <close>:
.global close
close:
 li a7, SYS_close
 318:	48d5                	li	a7,21
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <kill>:
.global kill
kill:
 li a7, SYS_kill
 320:	4899                	li	a7,6
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <exec>:
.global exec
exec:
 li a7, SYS_exec
 328:	489d                	li	a7,7
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <open>:
.global open
open:
 li a7, SYS_open
 330:	48bd                	li	a7,15
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 338:	48c5                	li	a7,17
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 340:	48c9                	li	a7,18
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 348:	48a1                	li	a7,8
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <link>:
.global link
link:
 li a7, SYS_link
 350:	48cd                	li	a7,19
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 358:	48d1                	li	a7,20
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 360:	48a5                	li	a7,9
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <dup>:
.global dup
dup:
 li a7, SYS_dup
 368:	48a9                	li	a7,10
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 370:	48ad                	li	a7,11
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 378:	48b1                	li	a7,12
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 380:	48b5                	li	a7,13
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 388:	48b9                	li	a7,14
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 390:	1101                	addi	sp,sp,-32
 392:	ec06                	sd	ra,24(sp)
 394:	e822                	sd	s0,16(sp)
 396:	1000                	addi	s0,sp,32
 398:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 39c:	4605                	li	a2,1
 39e:	fef40593          	addi	a1,s0,-17
 3a2:	00000097          	auipc	ra,0x0
 3a6:	f6e080e7          	jalr	-146(ra) # 310 <write>
}
 3aa:	60e2                	ld	ra,24(sp)
 3ac:	6442                	ld	s0,16(sp)
 3ae:	6105                	addi	sp,sp,32
 3b0:	8082                	ret

00000000000003b2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b2:	7139                	addi	sp,sp,-64
 3b4:	fc06                	sd	ra,56(sp)
 3b6:	f822                	sd	s0,48(sp)
 3b8:	f426                	sd	s1,40(sp)
 3ba:	f04a                	sd	s2,32(sp)
 3bc:	ec4e                	sd	s3,24(sp)
 3be:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3c0:	c299                	beqz	a3,3c6 <printint+0x14>
 3c2:	0005cd63          	bltz	a1,3dc <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3c6:	2581                	sext.w	a1,a1
  neg = 0;
 3c8:	4301                	li	t1,0
 3ca:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 3ce:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 3d0:	2601                	sext.w	a2,a2
 3d2:	00000897          	auipc	a7,0x0
 3d6:	4f688893          	addi	a7,a7,1270 # 8c8 <digits>
 3da:	a801                	j	3ea <printint+0x38>
    x = -xx;
 3dc:	40b005bb          	negw	a1,a1
 3e0:	2581                	sext.w	a1,a1
    neg = 1;
 3e2:	4305                	li	t1,1
    x = -xx;
 3e4:	b7dd                	j	3ca <printint+0x18>
  }while((x /= base) != 0);
 3e6:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 3e8:	8836                	mv	a6,a3
 3ea:	0018069b          	addiw	a3,a6,1
 3ee:	02c5f7bb          	remuw	a5,a1,a2
 3f2:	1782                	slli	a5,a5,0x20
 3f4:	9381                	srli	a5,a5,0x20
 3f6:	97c6                	add	a5,a5,a7
 3f8:	0007c783          	lbu	a5,0(a5)
 3fc:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 400:	0705                	addi	a4,a4,1
 402:	02c5d7bb          	divuw	a5,a1,a2
 406:	fec5f0e3          	bleu	a2,a1,3e6 <printint+0x34>
  if(neg)
 40a:	00030b63          	beqz	t1,420 <printint+0x6e>
    buf[i++] = '-';
 40e:	fd040793          	addi	a5,s0,-48
 412:	96be                	add	a3,a3,a5
 414:	02d00793          	li	a5,45
 418:	fef68823          	sb	a5,-16(a3)
 41c:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 420:	02d05963          	blez	a3,452 <printint+0xa0>
 424:	89aa                	mv	s3,a0
 426:	fc040793          	addi	a5,s0,-64
 42a:	00d784b3          	add	s1,a5,a3
 42e:	fff78913          	addi	s2,a5,-1
 432:	9936                	add	s2,s2,a3
 434:	36fd                	addiw	a3,a3,-1
 436:	1682                	slli	a3,a3,0x20
 438:	9281                	srli	a3,a3,0x20
 43a:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 43e:	fff4c583          	lbu	a1,-1(s1)
 442:	854e                	mv	a0,s3
 444:	00000097          	auipc	ra,0x0
 448:	f4c080e7          	jalr	-180(ra) # 390 <putc>
  while(--i >= 0)
 44c:	14fd                	addi	s1,s1,-1
 44e:	ff2498e3          	bne	s1,s2,43e <printint+0x8c>
}
 452:	70e2                	ld	ra,56(sp)
 454:	7442                	ld	s0,48(sp)
 456:	74a2                	ld	s1,40(sp)
 458:	7902                	ld	s2,32(sp)
 45a:	69e2                	ld	s3,24(sp)
 45c:	6121                	addi	sp,sp,64
 45e:	8082                	ret

0000000000000460 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 460:	7119                	addi	sp,sp,-128
 462:	fc86                	sd	ra,120(sp)
 464:	f8a2                	sd	s0,112(sp)
 466:	f4a6                	sd	s1,104(sp)
 468:	f0ca                	sd	s2,96(sp)
 46a:	ecce                	sd	s3,88(sp)
 46c:	e8d2                	sd	s4,80(sp)
 46e:	e4d6                	sd	s5,72(sp)
 470:	e0da                	sd	s6,64(sp)
 472:	fc5e                	sd	s7,56(sp)
 474:	f862                	sd	s8,48(sp)
 476:	f466                	sd	s9,40(sp)
 478:	f06a                	sd	s10,32(sp)
 47a:	ec6e                	sd	s11,24(sp)
 47c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 47e:	0005c483          	lbu	s1,0(a1)
 482:	18048d63          	beqz	s1,61c <vprintf+0x1bc>
 486:	8aaa                	mv	s5,a0
 488:	8b32                	mv	s6,a2
 48a:	00158913          	addi	s2,a1,1
  state = 0;
 48e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 490:	02500a13          	li	s4,37
      if(c == 'd'){
 494:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 498:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 49c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4a0:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4a4:	00000b97          	auipc	s7,0x0
 4a8:	424b8b93          	addi	s7,s7,1060 # 8c8 <digits>
 4ac:	a839                	j	4ca <vprintf+0x6a>
        putc(fd, c);
 4ae:	85a6                	mv	a1,s1
 4b0:	8556                	mv	a0,s5
 4b2:	00000097          	auipc	ra,0x0
 4b6:	ede080e7          	jalr	-290(ra) # 390 <putc>
 4ba:	a019                	j	4c0 <vprintf+0x60>
    } else if(state == '%'){
 4bc:	01498f63          	beq	s3,s4,4da <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4c0:	0905                	addi	s2,s2,1
 4c2:	fff94483          	lbu	s1,-1(s2)
 4c6:	14048b63          	beqz	s1,61c <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 4ca:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4ce:	fe0997e3          	bnez	s3,4bc <vprintf+0x5c>
      if(c == '%'){
 4d2:	fd479ee3          	bne	a5,s4,4ae <vprintf+0x4e>
        state = '%';
 4d6:	89be                	mv	s3,a5
 4d8:	b7e5                	j	4c0 <vprintf+0x60>
      if(c == 'd'){
 4da:	05878063          	beq	a5,s8,51a <vprintf+0xba>
      } else if(c == 'l') {
 4de:	05978c63          	beq	a5,s9,536 <vprintf+0xd6>
      } else if(c == 'x') {
 4e2:	07a78863          	beq	a5,s10,552 <vprintf+0xf2>
      } else if(c == 'p') {
 4e6:	09b78463          	beq	a5,s11,56e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4ea:	07300713          	li	a4,115
 4ee:	0ce78563          	beq	a5,a4,5b8 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4f2:	06300713          	li	a4,99
 4f6:	0ee78c63          	beq	a5,a4,5ee <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4fa:	11478663          	beq	a5,s4,606 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4fe:	85d2                	mv	a1,s4
 500:	8556                	mv	a0,s5
 502:	00000097          	auipc	ra,0x0
 506:	e8e080e7          	jalr	-370(ra) # 390 <putc>
        putc(fd, c);
 50a:	85a6                	mv	a1,s1
 50c:	8556                	mv	a0,s5
 50e:	00000097          	auipc	ra,0x0
 512:	e82080e7          	jalr	-382(ra) # 390 <putc>
      }
      state = 0;
 516:	4981                	li	s3,0
 518:	b765                	j	4c0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 51a:	008b0493          	addi	s1,s6,8
 51e:	4685                	li	a3,1
 520:	4629                	li	a2,10
 522:	000b2583          	lw	a1,0(s6)
 526:	8556                	mv	a0,s5
 528:	00000097          	auipc	ra,0x0
 52c:	e8a080e7          	jalr	-374(ra) # 3b2 <printint>
 530:	8b26                	mv	s6,s1
      state = 0;
 532:	4981                	li	s3,0
 534:	b771                	j	4c0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 536:	008b0493          	addi	s1,s6,8
 53a:	4681                	li	a3,0
 53c:	4629                	li	a2,10
 53e:	000b2583          	lw	a1,0(s6)
 542:	8556                	mv	a0,s5
 544:	00000097          	auipc	ra,0x0
 548:	e6e080e7          	jalr	-402(ra) # 3b2 <printint>
 54c:	8b26                	mv	s6,s1
      state = 0;
 54e:	4981                	li	s3,0
 550:	bf85                	j	4c0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 552:	008b0493          	addi	s1,s6,8
 556:	4681                	li	a3,0
 558:	4641                	li	a2,16
 55a:	000b2583          	lw	a1,0(s6)
 55e:	8556                	mv	a0,s5
 560:	00000097          	auipc	ra,0x0
 564:	e52080e7          	jalr	-430(ra) # 3b2 <printint>
 568:	8b26                	mv	s6,s1
      state = 0;
 56a:	4981                	li	s3,0
 56c:	bf91                	j	4c0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 56e:	008b0793          	addi	a5,s6,8
 572:	f8f43423          	sd	a5,-120(s0)
 576:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 57a:	03000593          	li	a1,48
 57e:	8556                	mv	a0,s5
 580:	00000097          	auipc	ra,0x0
 584:	e10080e7          	jalr	-496(ra) # 390 <putc>
  putc(fd, 'x');
 588:	85ea                	mv	a1,s10
 58a:	8556                	mv	a0,s5
 58c:	00000097          	auipc	ra,0x0
 590:	e04080e7          	jalr	-508(ra) # 390 <putc>
 594:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 596:	03c9d793          	srli	a5,s3,0x3c
 59a:	97de                	add	a5,a5,s7
 59c:	0007c583          	lbu	a1,0(a5)
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	dee080e7          	jalr	-530(ra) # 390 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5aa:	0992                	slli	s3,s3,0x4
 5ac:	34fd                	addiw	s1,s1,-1
 5ae:	f4e5                	bnez	s1,596 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5b0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	b729                	j	4c0 <vprintf+0x60>
        s = va_arg(ap, char*);
 5b8:	008b0993          	addi	s3,s6,8
 5bc:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 5c0:	c085                	beqz	s1,5e0 <vprintf+0x180>
        while(*s != 0){
 5c2:	0004c583          	lbu	a1,0(s1)
 5c6:	c9a1                	beqz	a1,616 <vprintf+0x1b6>
          putc(fd, *s);
 5c8:	8556                	mv	a0,s5
 5ca:	00000097          	auipc	ra,0x0
 5ce:	dc6080e7          	jalr	-570(ra) # 390 <putc>
          s++;
 5d2:	0485                	addi	s1,s1,1
        while(*s != 0){
 5d4:	0004c583          	lbu	a1,0(s1)
 5d8:	f9e5                	bnez	a1,5c8 <vprintf+0x168>
        s = va_arg(ap, char*);
 5da:	8b4e                	mv	s6,s3
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	b5cd                	j	4c0 <vprintf+0x60>
          s = "(null)";
 5e0:	00000497          	auipc	s1,0x0
 5e4:	30048493          	addi	s1,s1,768 # 8e0 <digits+0x18>
        while(*s != 0){
 5e8:	02800593          	li	a1,40
 5ec:	bff1                	j	5c8 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 5ee:	008b0493          	addi	s1,s6,8
 5f2:	000b4583          	lbu	a1,0(s6)
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	d98080e7          	jalr	-616(ra) # 390 <putc>
 600:	8b26                	mv	s6,s1
      state = 0;
 602:	4981                	li	s3,0
 604:	bd75                	j	4c0 <vprintf+0x60>
        putc(fd, c);
 606:	85d2                	mv	a1,s4
 608:	8556                	mv	a0,s5
 60a:	00000097          	auipc	ra,0x0
 60e:	d86080e7          	jalr	-634(ra) # 390 <putc>
      state = 0;
 612:	4981                	li	s3,0
 614:	b575                	j	4c0 <vprintf+0x60>
        s = va_arg(ap, char*);
 616:	8b4e                	mv	s6,s3
      state = 0;
 618:	4981                	li	s3,0
 61a:	b55d                	j	4c0 <vprintf+0x60>
    }
  }
}
 61c:	70e6                	ld	ra,120(sp)
 61e:	7446                	ld	s0,112(sp)
 620:	74a6                	ld	s1,104(sp)
 622:	7906                	ld	s2,96(sp)
 624:	69e6                	ld	s3,88(sp)
 626:	6a46                	ld	s4,80(sp)
 628:	6aa6                	ld	s5,72(sp)
 62a:	6b06                	ld	s6,64(sp)
 62c:	7be2                	ld	s7,56(sp)
 62e:	7c42                	ld	s8,48(sp)
 630:	7ca2                	ld	s9,40(sp)
 632:	7d02                	ld	s10,32(sp)
 634:	6de2                	ld	s11,24(sp)
 636:	6109                	addi	sp,sp,128
 638:	8082                	ret

000000000000063a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 63a:	715d                	addi	sp,sp,-80
 63c:	ec06                	sd	ra,24(sp)
 63e:	e822                	sd	s0,16(sp)
 640:	1000                	addi	s0,sp,32
 642:	e010                	sd	a2,0(s0)
 644:	e414                	sd	a3,8(s0)
 646:	e818                	sd	a4,16(s0)
 648:	ec1c                	sd	a5,24(s0)
 64a:	03043023          	sd	a6,32(s0)
 64e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 652:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 656:	8622                	mv	a2,s0
 658:	00000097          	auipc	ra,0x0
 65c:	e08080e7          	jalr	-504(ra) # 460 <vprintf>
}
 660:	60e2                	ld	ra,24(sp)
 662:	6442                	ld	s0,16(sp)
 664:	6161                	addi	sp,sp,80
 666:	8082                	ret

0000000000000668 <printf>:

void
printf(const char *fmt, ...)
{
 668:	711d                	addi	sp,sp,-96
 66a:	ec06                	sd	ra,24(sp)
 66c:	e822                	sd	s0,16(sp)
 66e:	1000                	addi	s0,sp,32
 670:	e40c                	sd	a1,8(s0)
 672:	e810                	sd	a2,16(s0)
 674:	ec14                	sd	a3,24(s0)
 676:	f018                	sd	a4,32(s0)
 678:	f41c                	sd	a5,40(s0)
 67a:	03043823          	sd	a6,48(s0)
 67e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 682:	00840613          	addi	a2,s0,8
 686:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 68a:	85aa                	mv	a1,a0
 68c:	4505                	li	a0,1
 68e:	00000097          	auipc	ra,0x0
 692:	dd2080e7          	jalr	-558(ra) # 460 <vprintf>
}
 696:	60e2                	ld	ra,24(sp)
 698:	6442                	ld	s0,16(sp)
 69a:	6125                	addi	sp,sp,96
 69c:	8082                	ret

000000000000069e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 69e:	1141                	addi	sp,sp,-16
 6a0:	e422                	sd	s0,8(sp)
 6a2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6a4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6a8:	00000797          	auipc	a5,0x0
 6ac:	26878793          	addi	a5,a5,616 # 910 <__bss_start>
 6b0:	639c                	ld	a5,0(a5)
 6b2:	a805                	j	6e2 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6b4:	4618                	lw	a4,8(a2)
 6b6:	9db9                	addw	a1,a1,a4
 6b8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6bc:	6398                	ld	a4,0(a5)
 6be:	6318                	ld	a4,0(a4)
 6c0:	fee53823          	sd	a4,-16(a0)
 6c4:	a091                	j	708 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6c6:	ff852703          	lw	a4,-8(a0)
 6ca:	9e39                	addw	a2,a2,a4
 6cc:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6ce:	ff053703          	ld	a4,-16(a0)
 6d2:	e398                	sd	a4,0(a5)
 6d4:	a099                	j	71a <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d6:	6398                	ld	a4,0(a5)
 6d8:	00e7e463          	bltu	a5,a4,6e0 <free+0x42>
 6dc:	00e6ea63          	bltu	a3,a4,6f0 <free+0x52>
{
 6e0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e2:	fed7fae3          	bleu	a3,a5,6d6 <free+0x38>
 6e6:	6398                	ld	a4,0(a5)
 6e8:	00e6e463          	bltu	a3,a4,6f0 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ec:	fee7eae3          	bltu	a5,a4,6e0 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 6f0:	ff852583          	lw	a1,-8(a0)
 6f4:	6390                	ld	a2,0(a5)
 6f6:	02059713          	slli	a4,a1,0x20
 6fa:	9301                	srli	a4,a4,0x20
 6fc:	0712                	slli	a4,a4,0x4
 6fe:	9736                	add	a4,a4,a3
 700:	fae60ae3          	beq	a2,a4,6b4 <free+0x16>
    bp->s.ptr = p->s.ptr;
 704:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 708:	4790                	lw	a2,8(a5)
 70a:	02061713          	slli	a4,a2,0x20
 70e:	9301                	srli	a4,a4,0x20
 710:	0712                	slli	a4,a4,0x4
 712:	973e                	add	a4,a4,a5
 714:	fae689e3          	beq	a3,a4,6c6 <free+0x28>
  } else
    p->s.ptr = bp;
 718:	e394                	sd	a3,0(a5)
  freep = p;
 71a:	00000717          	auipc	a4,0x0
 71e:	1ef73b23          	sd	a5,502(a4) # 910 <__bss_start>
}
 722:	6422                	ld	s0,8(sp)
 724:	0141                	addi	sp,sp,16
 726:	8082                	ret

0000000000000728 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 728:	7139                	addi	sp,sp,-64
 72a:	fc06                	sd	ra,56(sp)
 72c:	f822                	sd	s0,48(sp)
 72e:	f426                	sd	s1,40(sp)
 730:	f04a                	sd	s2,32(sp)
 732:	ec4e                	sd	s3,24(sp)
 734:	e852                	sd	s4,16(sp)
 736:	e456                	sd	s5,8(sp)
 738:	e05a                	sd	s6,0(sp)
 73a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 73c:	02051993          	slli	s3,a0,0x20
 740:	0209d993          	srli	s3,s3,0x20
 744:	09bd                	addi	s3,s3,15
 746:	0049d993          	srli	s3,s3,0x4
 74a:	2985                	addiw	s3,s3,1
 74c:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 750:	00000797          	auipc	a5,0x0
 754:	1c078793          	addi	a5,a5,448 # 910 <__bss_start>
 758:	6388                	ld	a0,0(a5)
 75a:	c515                	beqz	a0,786 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 75c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 75e:	4798                	lw	a4,8(a5)
 760:	03277f63          	bleu	s2,a4,79e <malloc+0x76>
 764:	8a4e                	mv	s4,s3
 766:	0009871b          	sext.w	a4,s3
 76a:	6685                	lui	a3,0x1
 76c:	00d77363          	bleu	a3,a4,772 <malloc+0x4a>
 770:	6a05                	lui	s4,0x1
 772:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 776:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 77a:	00000497          	auipc	s1,0x0
 77e:	19648493          	addi	s1,s1,406 # 910 <__bss_start>
  if(p == (char*)-1)
 782:	5b7d                	li	s6,-1
 784:	a885                	j	7f4 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 786:	00000797          	auipc	a5,0x0
 78a:	19278793          	addi	a5,a5,402 # 918 <base>
 78e:	00000717          	auipc	a4,0x0
 792:	18f73123          	sd	a5,386(a4) # 910 <__bss_start>
 796:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 798:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 79c:	b7e1                	j	764 <malloc+0x3c>
      if(p->s.size == nunits)
 79e:	02e90b63          	beq	s2,a4,7d4 <malloc+0xac>
        p->s.size -= nunits;
 7a2:	4137073b          	subw	a4,a4,s3
 7a6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7a8:	1702                	slli	a4,a4,0x20
 7aa:	9301                	srli	a4,a4,0x20
 7ac:	0712                	slli	a4,a4,0x4
 7ae:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7b0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7b4:	00000717          	auipc	a4,0x0
 7b8:	14a73e23          	sd	a0,348(a4) # 910 <__bss_start>
      return (void*)(p + 1);
 7bc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7c0:	70e2                	ld	ra,56(sp)
 7c2:	7442                	ld	s0,48(sp)
 7c4:	74a2                	ld	s1,40(sp)
 7c6:	7902                	ld	s2,32(sp)
 7c8:	69e2                	ld	s3,24(sp)
 7ca:	6a42                	ld	s4,16(sp)
 7cc:	6aa2                	ld	s5,8(sp)
 7ce:	6b02                	ld	s6,0(sp)
 7d0:	6121                	addi	sp,sp,64
 7d2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7d4:	6398                	ld	a4,0(a5)
 7d6:	e118                	sd	a4,0(a0)
 7d8:	bff1                	j	7b4 <malloc+0x8c>
  hp->s.size = nu;
 7da:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 7de:	0541                	addi	a0,a0,16
 7e0:	00000097          	auipc	ra,0x0
 7e4:	ebe080e7          	jalr	-322(ra) # 69e <free>
  return freep;
 7e8:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 7ea:	d979                	beqz	a0,7c0 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ee:	4798                	lw	a4,8(a5)
 7f0:	fb2777e3          	bleu	s2,a4,79e <malloc+0x76>
    if(p == freep)
 7f4:	6098                	ld	a4,0(s1)
 7f6:	853e                	mv	a0,a5
 7f8:	fef71ae3          	bne	a4,a5,7ec <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 7fc:	8552                	mv	a0,s4
 7fe:	00000097          	auipc	ra,0x0
 802:	b7a080e7          	jalr	-1158(ra) # 378 <sbrk>
  if(p == (char*)-1)
 806:	fd651ae3          	bne	a0,s6,7da <malloc+0xb2>
        return 0;
 80a:	4501                	li	a0,0
 80c:	bf55                	j	7c0 <malloc+0x98>

000000000000080e <statistics>:
#include "kernel/fcntl.h"
#include "user/user.h"

int
statistics(void *buf, int sz)
{
 80e:	7179                	addi	sp,sp,-48
 810:	f406                	sd	ra,40(sp)
 812:	f022                	sd	s0,32(sp)
 814:	ec26                	sd	s1,24(sp)
 816:	e84a                	sd	s2,16(sp)
 818:	e44e                	sd	s3,8(sp)
 81a:	e052                	sd	s4,0(sp)
 81c:	1800                	addi	s0,sp,48
 81e:	8a2a                	mv	s4,a0
 820:	892e                	mv	s2,a1
  int fd, i, n;
  
  fd = open("statistics", O_RDONLY);
 822:	4581                	li	a1,0
 824:	00000517          	auipc	a0,0x0
 828:	0c450513          	addi	a0,a0,196 # 8e8 <digits+0x20>
 82c:	00000097          	auipc	ra,0x0
 830:	b04080e7          	jalr	-1276(ra) # 330 <open>
  if(fd < 0) {
 834:	04054263          	bltz	a0,878 <statistics+0x6a>
 838:	89aa                	mv	s3,a0
      fprintf(2, "stats: open failed\n");
      exit(1);
  }
  for (i = 0; i < sz; ) {
 83a:	4481                	li	s1,0
 83c:	03205063          	blez	s2,85c <statistics+0x4e>
    if ((n = read(fd, buf+i, sz-i)) < 0) {
 840:	4099063b          	subw	a2,s2,s1
 844:	009a05b3          	add	a1,s4,s1
 848:	854e                	mv	a0,s3
 84a:	00000097          	auipc	ra,0x0
 84e:	abe080e7          	jalr	-1346(ra) # 308 <read>
 852:	00054563          	bltz	a0,85c <statistics+0x4e>
      break;
    }
    i += n;
 856:	9ca9                	addw	s1,s1,a0
  for (i = 0; i < sz; ) {
 858:	ff24c4e3          	blt	s1,s2,840 <statistics+0x32>
  }
  close(fd);
 85c:	854e                	mv	a0,s3
 85e:	00000097          	auipc	ra,0x0
 862:	aba080e7          	jalr	-1350(ra) # 318 <close>
  return i;
}
 866:	8526                	mv	a0,s1
 868:	70a2                	ld	ra,40(sp)
 86a:	7402                	ld	s0,32(sp)
 86c:	64e2                	ld	s1,24(sp)
 86e:	6942                	ld	s2,16(sp)
 870:	69a2                	ld	s3,8(sp)
 872:	6a02                	ld	s4,0(sp)
 874:	6145                	addi	sp,sp,48
 876:	8082                	ret
      fprintf(2, "stats: open failed\n");
 878:	00000597          	auipc	a1,0x0
 87c:	08058593          	addi	a1,a1,128 # 8f8 <digits+0x30>
 880:	4509                	li	a0,2
 882:	00000097          	auipc	ra,0x0
 886:	db8080e7          	jalr	-584(ra) # 63a <fprintf>
      exit(1);
 88a:	4505                	li	a0,1
 88c:	00000097          	auipc	ra,0x0
 890:	a64080e7          	jalr	-1436(ra) # 2f0 <exit>
