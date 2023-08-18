
user/_kill：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   c:	4785                	li	a5,1
   e:	02a7dd63          	ble	a0,a5,48 <main+0x48>
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	1902                	slli	s2,s2,0x20
  1c:	02095913          	srli	s2,s2,0x20
  20:	090e                	slli	s2,s2,0x3
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	1c0080e7          	jalr	448(ra) # 1e8 <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	2f4080e7          	jalr	756(ra) # 324 <kill>
  for(i=1; i<argc; i++)
  38:	04a1                	addi	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2b4080e7          	jalr	692(ra) # 2f4 <exit>
    fprintf(2, "usage: kill pid...\n");
  48:	00000597          	auipc	a1,0x0
  4c:	7e058593          	addi	a1,a1,2016 # 828 <malloc+0xec>
  50:	4509                	li	a0,2
  52:	00000097          	auipc	ra,0x0
  56:	5fc080e7          	jalr	1532(ra) # 64e <fprintf>
    exit(1);
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	298080e7          	jalr	664(ra) # 2f4 <exit>

0000000000000064 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  64:	1141                	addi	sp,sp,-16
  66:	e422                	sd	s0,8(sp)
  68:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  6a:	87aa                	mv	a5,a0
  6c:	0585                	addi	a1,a1,1
  6e:	0785                	addi	a5,a5,1
  70:	fff5c703          	lbu	a4,-1(a1)
  74:	fee78fa3          	sb	a4,-1(a5)
  78:	fb75                	bnez	a4,6c <strcpy+0x8>
    ;
  return os;
}
  7a:	6422                	ld	s0,8(sp)
  7c:	0141                	addi	sp,sp,16
  7e:	8082                	ret

0000000000000080 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80:	1141                	addi	sp,sp,-16
  82:	e422                	sd	s0,8(sp)
  84:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  86:	00054783          	lbu	a5,0(a0)
  8a:	cf91                	beqz	a5,a6 <strcmp+0x26>
  8c:	0005c703          	lbu	a4,0(a1)
  90:	00f71b63          	bne	a4,a5,a6 <strcmp+0x26>
    p++, q++;
  94:	0505                	addi	a0,a0,1
  96:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  98:	00054783          	lbu	a5,0(a0)
  9c:	c789                	beqz	a5,a6 <strcmp+0x26>
  9e:	0005c703          	lbu	a4,0(a1)
  a2:	fef709e3          	beq	a4,a5,94 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
  a6:	0005c503          	lbu	a0,0(a1)
}
  aa:	40a7853b          	subw	a0,a5,a0
  ae:	6422                	ld	s0,8(sp)
  b0:	0141                	addi	sp,sp,16
  b2:	8082                	ret

00000000000000b4 <strlen>:

uint
strlen(const char *s)
{
  b4:	1141                	addi	sp,sp,-16
  b6:	e422                	sd	s0,8(sp)
  b8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ba:	00054783          	lbu	a5,0(a0)
  be:	cf91                	beqz	a5,da <strlen+0x26>
  c0:	0505                	addi	a0,a0,1
  c2:	87aa                	mv	a5,a0
  c4:	4685                	li	a3,1
  c6:	9e89                	subw	a3,a3,a0
  c8:	00f6853b          	addw	a0,a3,a5
  cc:	0785                	addi	a5,a5,1
  ce:	fff7c703          	lbu	a4,-1(a5)
  d2:	fb7d                	bnez	a4,c8 <strlen+0x14>
    ;
  return n;
}
  d4:	6422                	ld	s0,8(sp)
  d6:	0141                	addi	sp,sp,16
  d8:	8082                	ret
  for(n = 0; s[n]; n++)
  da:	4501                	li	a0,0
  dc:	bfe5                	j	d4 <strlen+0x20>

00000000000000de <memset>:

void*
memset(void *dst, int c, uint n)
{
  de:	1141                	addi	sp,sp,-16
  e0:	e422                	sd	s0,8(sp)
  e2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  e4:	ce09                	beqz	a2,fe <memset+0x20>
  e6:	87aa                	mv	a5,a0
  e8:	fff6071b          	addiw	a4,a2,-1
  ec:	1702                	slli	a4,a4,0x20
  ee:	9301                	srli	a4,a4,0x20
  f0:	0705                	addi	a4,a4,1
  f2:	972a                	add	a4,a4,a0
    cdst[i] = c;
  f4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  f8:	0785                	addi	a5,a5,1
  fa:	fee79de3          	bne	a5,a4,f4 <memset+0x16>
  }
  return dst;
}
  fe:	6422                	ld	s0,8(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret

0000000000000104 <strchr>:

char*
strchr(const char *s, char c)
{
 104:	1141                	addi	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	addi	s0,sp,16
  for(; *s; s++)
 10a:	00054783          	lbu	a5,0(a0)
 10e:	cf91                	beqz	a5,12a <strchr+0x26>
    if(*s == c)
 110:	00f58a63          	beq	a1,a5,124 <strchr+0x20>
  for(; *s; s++)
 114:	0505                	addi	a0,a0,1
 116:	00054783          	lbu	a5,0(a0)
 11a:	c781                	beqz	a5,122 <strchr+0x1e>
    if(*s == c)
 11c:	feb79ce3          	bne	a5,a1,114 <strchr+0x10>
 120:	a011                	j	124 <strchr+0x20>
      return (char*)s;
  return 0;
 122:	4501                	li	a0,0
}
 124:	6422                	ld	s0,8(sp)
 126:	0141                	addi	sp,sp,16
 128:	8082                	ret
  return 0;
 12a:	4501                	li	a0,0
 12c:	bfe5                	j	124 <strchr+0x20>

000000000000012e <gets>:

char*
gets(char *buf, int max)
{
 12e:	711d                	addi	sp,sp,-96
 130:	ec86                	sd	ra,88(sp)
 132:	e8a2                	sd	s0,80(sp)
 134:	e4a6                	sd	s1,72(sp)
 136:	e0ca                	sd	s2,64(sp)
 138:	fc4e                	sd	s3,56(sp)
 13a:	f852                	sd	s4,48(sp)
 13c:	f456                	sd	s5,40(sp)
 13e:	f05a                	sd	s6,32(sp)
 140:	ec5e                	sd	s7,24(sp)
 142:	1080                	addi	s0,sp,96
 144:	8baa                	mv	s7,a0
 146:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 148:	892a                	mv	s2,a0
 14a:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 14c:	4aa9                	li	s5,10
 14e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 150:	0019849b          	addiw	s1,s3,1
 154:	0344d863          	ble	s4,s1,184 <gets+0x56>
    cc = read(0, &c, 1);
 158:	4605                	li	a2,1
 15a:	faf40593          	addi	a1,s0,-81
 15e:	4501                	li	a0,0
 160:	00000097          	auipc	ra,0x0
 164:	1ac080e7          	jalr	428(ra) # 30c <read>
    if(cc < 1)
 168:	00a05e63          	blez	a0,184 <gets+0x56>
    buf[i++] = c;
 16c:	faf44783          	lbu	a5,-81(s0)
 170:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 174:	01578763          	beq	a5,s5,182 <gets+0x54>
 178:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 17a:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 17c:	fd679ae3          	bne	a5,s6,150 <gets+0x22>
 180:	a011                	j	184 <gets+0x56>
  for(i=0; i+1 < max; ){
 182:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 184:	99de                	add	s3,s3,s7
 186:	00098023          	sb	zero,0(s3)
  return buf;
}
 18a:	855e                	mv	a0,s7
 18c:	60e6                	ld	ra,88(sp)
 18e:	6446                	ld	s0,80(sp)
 190:	64a6                	ld	s1,72(sp)
 192:	6906                	ld	s2,64(sp)
 194:	79e2                	ld	s3,56(sp)
 196:	7a42                	ld	s4,48(sp)
 198:	7aa2                	ld	s5,40(sp)
 19a:	7b02                	ld	s6,32(sp)
 19c:	6be2                	ld	s7,24(sp)
 19e:	6125                	addi	sp,sp,96
 1a0:	8082                	ret

00000000000001a2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1a2:	1101                	addi	sp,sp,-32
 1a4:	ec06                	sd	ra,24(sp)
 1a6:	e822                	sd	s0,16(sp)
 1a8:	e426                	sd	s1,8(sp)
 1aa:	e04a                	sd	s2,0(sp)
 1ac:	1000                	addi	s0,sp,32
 1ae:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b0:	4581                	li	a1,0
 1b2:	00000097          	auipc	ra,0x0
 1b6:	182080e7          	jalr	386(ra) # 334 <open>
  if(fd < 0)
 1ba:	02054563          	bltz	a0,1e4 <stat+0x42>
 1be:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c0:	85ca                	mv	a1,s2
 1c2:	00000097          	auipc	ra,0x0
 1c6:	18a080e7          	jalr	394(ra) # 34c <fstat>
 1ca:	892a                	mv	s2,a0
  close(fd);
 1cc:	8526                	mv	a0,s1
 1ce:	00000097          	auipc	ra,0x0
 1d2:	14e080e7          	jalr	334(ra) # 31c <close>
  return r;
}
 1d6:	854a                	mv	a0,s2
 1d8:	60e2                	ld	ra,24(sp)
 1da:	6442                	ld	s0,16(sp)
 1dc:	64a2                	ld	s1,8(sp)
 1de:	6902                	ld	s2,0(sp)
 1e0:	6105                	addi	sp,sp,32
 1e2:	8082                	ret
    return -1;
 1e4:	597d                	li	s2,-1
 1e6:	bfc5                	j	1d6 <stat+0x34>

00000000000001e8 <atoi>:

int
atoi(const char *s)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e422                	sd	s0,8(sp)
 1ec:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ee:	00054683          	lbu	a3,0(a0)
 1f2:	fd06879b          	addiw	a5,a3,-48
 1f6:	0ff7f793          	andi	a5,a5,255
 1fa:	4725                	li	a4,9
 1fc:	02f76963          	bltu	a4,a5,22e <atoi+0x46>
 200:	862a                	mv	a2,a0
  n = 0;
 202:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 204:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 206:	0605                	addi	a2,a2,1
 208:	0025179b          	slliw	a5,a0,0x2
 20c:	9fa9                	addw	a5,a5,a0
 20e:	0017979b          	slliw	a5,a5,0x1
 212:	9fb5                	addw	a5,a5,a3
 214:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 218:	00064683          	lbu	a3,0(a2)
 21c:	fd06871b          	addiw	a4,a3,-48
 220:	0ff77713          	andi	a4,a4,255
 224:	fee5f1e3          	bleu	a4,a1,206 <atoi+0x1e>
  return n;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret
  n = 0;
 22e:	4501                	li	a0,0
 230:	bfe5                	j	228 <atoi+0x40>

0000000000000232 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 238:	02b57663          	bleu	a1,a0,264 <memmove+0x32>
    while(n-- > 0)
 23c:	02c05163          	blez	a2,25e <memmove+0x2c>
 240:	fff6079b          	addiw	a5,a2,-1
 244:	1782                	slli	a5,a5,0x20
 246:	9381                	srli	a5,a5,0x20
 248:	0785                	addi	a5,a5,1
 24a:	97aa                	add	a5,a5,a0
  dst = vdst;
 24c:	872a                	mv	a4,a0
      *dst++ = *src++;
 24e:	0585                	addi	a1,a1,1
 250:	0705                	addi	a4,a4,1
 252:	fff5c683          	lbu	a3,-1(a1)
 256:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 25a:	fee79ae3          	bne	a5,a4,24e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 25e:	6422                	ld	s0,8(sp)
 260:	0141                	addi	sp,sp,16
 262:	8082                	ret
    dst += n;
 264:	00c50733          	add	a4,a0,a2
    src += n;
 268:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 26a:	fec05ae3          	blez	a2,25e <memmove+0x2c>
 26e:	fff6079b          	addiw	a5,a2,-1
 272:	1782                	slli	a5,a5,0x20
 274:	9381                	srli	a5,a5,0x20
 276:	fff7c793          	not	a5,a5
 27a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 27c:	15fd                	addi	a1,a1,-1
 27e:	177d                	addi	a4,a4,-1
 280:	0005c683          	lbu	a3,0(a1)
 284:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 288:	fef71ae3          	bne	a4,a5,27c <memmove+0x4a>
 28c:	bfc9                	j	25e <memmove+0x2c>

000000000000028e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 294:	ce15                	beqz	a2,2d0 <memcmp+0x42>
 296:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 29a:	00054783          	lbu	a5,0(a0)
 29e:	0005c703          	lbu	a4,0(a1)
 2a2:	02e79063          	bne	a5,a4,2c2 <memcmp+0x34>
 2a6:	1682                	slli	a3,a3,0x20
 2a8:	9281                	srli	a3,a3,0x20
 2aa:	0685                	addi	a3,a3,1
 2ac:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 2ae:	0505                	addi	a0,a0,1
    p2++;
 2b0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2b2:	00d50d63          	beq	a0,a3,2cc <memcmp+0x3e>
    if (*p1 != *p2) {
 2b6:	00054783          	lbu	a5,0(a0)
 2ba:	0005c703          	lbu	a4,0(a1)
 2be:	fee788e3          	beq	a5,a4,2ae <memcmp+0x20>
      return *p1 - *p2;
 2c2:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 2c6:	6422                	ld	s0,8(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret
  return 0;
 2cc:	4501                	li	a0,0
 2ce:	bfe5                	j	2c6 <memcmp+0x38>
 2d0:	4501                	li	a0,0
 2d2:	bfd5                	j	2c6 <memcmp+0x38>

00000000000002d4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e406                	sd	ra,8(sp)
 2d8:	e022                	sd	s0,0(sp)
 2da:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2dc:	00000097          	auipc	ra,0x0
 2e0:	f56080e7          	jalr	-170(ra) # 232 <memmove>
}
 2e4:	60a2                	ld	ra,8(sp)
 2e6:	6402                	ld	s0,0(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret

00000000000002ec <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ec:	4885                	li	a7,1
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2f4:	4889                	li	a7,2
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <wait>:
.global wait
wait:
 li a7, SYS_wait
 2fc:	488d                	li	a7,3
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 304:	4891                	li	a7,4
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <read>:
.global read
read:
 li a7, SYS_read
 30c:	4895                	li	a7,5
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <write>:
.global write
write:
 li a7, SYS_write
 314:	48c1                	li	a7,16
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <close>:
.global close
close:
 li a7, SYS_close
 31c:	48d5                	li	a7,21
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <kill>:
.global kill
kill:
 li a7, SYS_kill
 324:	4899                	li	a7,6
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <exec>:
.global exec
exec:
 li a7, SYS_exec
 32c:	489d                	li	a7,7
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <open>:
.global open
open:
 li a7, SYS_open
 334:	48bd                	li	a7,15
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 33c:	48c5                	li	a7,17
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 344:	48c9                	li	a7,18
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 34c:	48a1                	li	a7,8
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <link>:
.global link
link:
 li a7, SYS_link
 354:	48cd                	li	a7,19
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 35c:	48d1                	li	a7,20
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 364:	48a5                	li	a7,9
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <dup>:
.global dup
dup:
 li a7, SYS_dup
 36c:	48a9                	li	a7,10
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 374:	48ad                	li	a7,11
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 37c:	48b1                	li	a7,12
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 384:	48b5                	li	a7,13
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 38c:	48b9                	li	a7,14
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 394:	48d9                	li	a7,22
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 39c:	48dd                	li	a7,23
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3a4:	1101                	addi	sp,sp,-32
 3a6:	ec06                	sd	ra,24(sp)
 3a8:	e822                	sd	s0,16(sp)
 3aa:	1000                	addi	s0,sp,32
 3ac:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3b0:	4605                	li	a2,1
 3b2:	fef40593          	addi	a1,s0,-17
 3b6:	00000097          	auipc	ra,0x0
 3ba:	f5e080e7          	jalr	-162(ra) # 314 <write>
}
 3be:	60e2                	ld	ra,24(sp)
 3c0:	6442                	ld	s0,16(sp)
 3c2:	6105                	addi	sp,sp,32
 3c4:	8082                	ret

00000000000003c6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3c6:	7139                	addi	sp,sp,-64
 3c8:	fc06                	sd	ra,56(sp)
 3ca:	f822                	sd	s0,48(sp)
 3cc:	f426                	sd	s1,40(sp)
 3ce:	f04a                	sd	s2,32(sp)
 3d0:	ec4e                	sd	s3,24(sp)
 3d2:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3d4:	c299                	beqz	a3,3da <printint+0x14>
 3d6:	0005cd63          	bltz	a1,3f0 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3da:	2581                	sext.w	a1,a1
  neg = 0;
 3dc:	4301                	li	t1,0
 3de:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 3e2:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 3e4:	2601                	sext.w	a2,a2
 3e6:	00000897          	auipc	a7,0x0
 3ea:	45a88893          	addi	a7,a7,1114 # 840 <digits>
 3ee:	a801                	j	3fe <printint+0x38>
    x = -xx;
 3f0:	40b005bb          	negw	a1,a1
 3f4:	2581                	sext.w	a1,a1
    neg = 1;
 3f6:	4305                	li	t1,1
    x = -xx;
 3f8:	b7dd                	j	3de <printint+0x18>
  }while((x /= base) != 0);
 3fa:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 3fc:	8836                	mv	a6,a3
 3fe:	0018069b          	addiw	a3,a6,1
 402:	02c5f7bb          	remuw	a5,a1,a2
 406:	1782                	slli	a5,a5,0x20
 408:	9381                	srli	a5,a5,0x20
 40a:	97c6                	add	a5,a5,a7
 40c:	0007c783          	lbu	a5,0(a5)
 410:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 414:	0705                	addi	a4,a4,1
 416:	02c5d7bb          	divuw	a5,a1,a2
 41a:	fec5f0e3          	bleu	a2,a1,3fa <printint+0x34>
  if(neg)
 41e:	00030b63          	beqz	t1,434 <printint+0x6e>
    buf[i++] = '-';
 422:	fd040793          	addi	a5,s0,-48
 426:	96be                	add	a3,a3,a5
 428:	02d00793          	li	a5,45
 42c:	fef68823          	sb	a5,-16(a3)
 430:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 434:	02d05963          	blez	a3,466 <printint+0xa0>
 438:	89aa                	mv	s3,a0
 43a:	fc040793          	addi	a5,s0,-64
 43e:	00d784b3          	add	s1,a5,a3
 442:	fff78913          	addi	s2,a5,-1
 446:	9936                	add	s2,s2,a3
 448:	36fd                	addiw	a3,a3,-1
 44a:	1682                	slli	a3,a3,0x20
 44c:	9281                	srli	a3,a3,0x20
 44e:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 452:	fff4c583          	lbu	a1,-1(s1)
 456:	854e                	mv	a0,s3
 458:	00000097          	auipc	ra,0x0
 45c:	f4c080e7          	jalr	-180(ra) # 3a4 <putc>
  while(--i >= 0)
 460:	14fd                	addi	s1,s1,-1
 462:	ff2498e3          	bne	s1,s2,452 <printint+0x8c>
}
 466:	70e2                	ld	ra,56(sp)
 468:	7442                	ld	s0,48(sp)
 46a:	74a2                	ld	s1,40(sp)
 46c:	7902                	ld	s2,32(sp)
 46e:	69e2                	ld	s3,24(sp)
 470:	6121                	addi	sp,sp,64
 472:	8082                	ret

0000000000000474 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 474:	7119                	addi	sp,sp,-128
 476:	fc86                	sd	ra,120(sp)
 478:	f8a2                	sd	s0,112(sp)
 47a:	f4a6                	sd	s1,104(sp)
 47c:	f0ca                	sd	s2,96(sp)
 47e:	ecce                	sd	s3,88(sp)
 480:	e8d2                	sd	s4,80(sp)
 482:	e4d6                	sd	s5,72(sp)
 484:	e0da                	sd	s6,64(sp)
 486:	fc5e                	sd	s7,56(sp)
 488:	f862                	sd	s8,48(sp)
 48a:	f466                	sd	s9,40(sp)
 48c:	f06a                	sd	s10,32(sp)
 48e:	ec6e                	sd	s11,24(sp)
 490:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 492:	0005c483          	lbu	s1,0(a1)
 496:	18048d63          	beqz	s1,630 <vprintf+0x1bc>
 49a:	8aaa                	mv	s5,a0
 49c:	8b32                	mv	s6,a2
 49e:	00158913          	addi	s2,a1,1
  state = 0;
 4a2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4a4:	02500a13          	li	s4,37
      if(c == 'd'){
 4a8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4ac:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4b0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4b4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4b8:	00000b97          	auipc	s7,0x0
 4bc:	388b8b93          	addi	s7,s7,904 # 840 <digits>
 4c0:	a839                	j	4de <vprintf+0x6a>
        putc(fd, c);
 4c2:	85a6                	mv	a1,s1
 4c4:	8556                	mv	a0,s5
 4c6:	00000097          	auipc	ra,0x0
 4ca:	ede080e7          	jalr	-290(ra) # 3a4 <putc>
 4ce:	a019                	j	4d4 <vprintf+0x60>
    } else if(state == '%'){
 4d0:	01498f63          	beq	s3,s4,4ee <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4d4:	0905                	addi	s2,s2,1
 4d6:	fff94483          	lbu	s1,-1(s2)
 4da:	14048b63          	beqz	s1,630 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 4de:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4e2:	fe0997e3          	bnez	s3,4d0 <vprintf+0x5c>
      if(c == '%'){
 4e6:	fd479ee3          	bne	a5,s4,4c2 <vprintf+0x4e>
        state = '%';
 4ea:	89be                	mv	s3,a5
 4ec:	b7e5                	j	4d4 <vprintf+0x60>
      if(c == 'd'){
 4ee:	05878063          	beq	a5,s8,52e <vprintf+0xba>
      } else if(c == 'l') {
 4f2:	05978c63          	beq	a5,s9,54a <vprintf+0xd6>
      } else if(c == 'x') {
 4f6:	07a78863          	beq	a5,s10,566 <vprintf+0xf2>
      } else if(c == 'p') {
 4fa:	09b78463          	beq	a5,s11,582 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4fe:	07300713          	li	a4,115
 502:	0ce78563          	beq	a5,a4,5cc <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 506:	06300713          	li	a4,99
 50a:	0ee78c63          	beq	a5,a4,602 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 50e:	11478663          	beq	a5,s4,61a <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 512:	85d2                	mv	a1,s4
 514:	8556                	mv	a0,s5
 516:	00000097          	auipc	ra,0x0
 51a:	e8e080e7          	jalr	-370(ra) # 3a4 <putc>
        putc(fd, c);
 51e:	85a6                	mv	a1,s1
 520:	8556                	mv	a0,s5
 522:	00000097          	auipc	ra,0x0
 526:	e82080e7          	jalr	-382(ra) # 3a4 <putc>
      }
      state = 0;
 52a:	4981                	li	s3,0
 52c:	b765                	j	4d4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 52e:	008b0493          	addi	s1,s6,8
 532:	4685                	li	a3,1
 534:	4629                	li	a2,10
 536:	000b2583          	lw	a1,0(s6)
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	e8a080e7          	jalr	-374(ra) # 3c6 <printint>
 544:	8b26                	mv	s6,s1
      state = 0;
 546:	4981                	li	s3,0
 548:	b771                	j	4d4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 54a:	008b0493          	addi	s1,s6,8
 54e:	4681                	li	a3,0
 550:	4629                	li	a2,10
 552:	000b2583          	lw	a1,0(s6)
 556:	8556                	mv	a0,s5
 558:	00000097          	auipc	ra,0x0
 55c:	e6e080e7          	jalr	-402(ra) # 3c6 <printint>
 560:	8b26                	mv	s6,s1
      state = 0;
 562:	4981                	li	s3,0
 564:	bf85                	j	4d4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 566:	008b0493          	addi	s1,s6,8
 56a:	4681                	li	a3,0
 56c:	4641                	li	a2,16
 56e:	000b2583          	lw	a1,0(s6)
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	e52080e7          	jalr	-430(ra) # 3c6 <printint>
 57c:	8b26                	mv	s6,s1
      state = 0;
 57e:	4981                	li	s3,0
 580:	bf91                	j	4d4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 582:	008b0793          	addi	a5,s6,8
 586:	f8f43423          	sd	a5,-120(s0)
 58a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 58e:	03000593          	li	a1,48
 592:	8556                	mv	a0,s5
 594:	00000097          	auipc	ra,0x0
 598:	e10080e7          	jalr	-496(ra) # 3a4 <putc>
  putc(fd, 'x');
 59c:	85ea                	mv	a1,s10
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	e04080e7          	jalr	-508(ra) # 3a4 <putc>
 5a8:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5aa:	03c9d793          	srli	a5,s3,0x3c
 5ae:	97de                	add	a5,a5,s7
 5b0:	0007c583          	lbu	a1,0(a5)
 5b4:	8556                	mv	a0,s5
 5b6:	00000097          	auipc	ra,0x0
 5ba:	dee080e7          	jalr	-530(ra) # 3a4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5be:	0992                	slli	s3,s3,0x4
 5c0:	34fd                	addiw	s1,s1,-1
 5c2:	f4e5                	bnez	s1,5aa <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5c4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	b729                	j	4d4 <vprintf+0x60>
        s = va_arg(ap, char*);
 5cc:	008b0993          	addi	s3,s6,8
 5d0:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 5d4:	c085                	beqz	s1,5f4 <vprintf+0x180>
        while(*s != 0){
 5d6:	0004c583          	lbu	a1,0(s1)
 5da:	c9a1                	beqz	a1,62a <vprintf+0x1b6>
          putc(fd, *s);
 5dc:	8556                	mv	a0,s5
 5de:	00000097          	auipc	ra,0x0
 5e2:	dc6080e7          	jalr	-570(ra) # 3a4 <putc>
          s++;
 5e6:	0485                	addi	s1,s1,1
        while(*s != 0){
 5e8:	0004c583          	lbu	a1,0(s1)
 5ec:	f9e5                	bnez	a1,5dc <vprintf+0x168>
        s = va_arg(ap, char*);
 5ee:	8b4e                	mv	s6,s3
      state = 0;
 5f0:	4981                	li	s3,0
 5f2:	b5cd                	j	4d4 <vprintf+0x60>
          s = "(null)";
 5f4:	00000497          	auipc	s1,0x0
 5f8:	26448493          	addi	s1,s1,612 # 858 <digits+0x18>
        while(*s != 0){
 5fc:	02800593          	li	a1,40
 600:	bff1                	j	5dc <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 602:	008b0493          	addi	s1,s6,8
 606:	000b4583          	lbu	a1,0(s6)
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	d98080e7          	jalr	-616(ra) # 3a4 <putc>
 614:	8b26                	mv	s6,s1
      state = 0;
 616:	4981                	li	s3,0
 618:	bd75                	j	4d4 <vprintf+0x60>
        putc(fd, c);
 61a:	85d2                	mv	a1,s4
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	d86080e7          	jalr	-634(ra) # 3a4 <putc>
      state = 0;
 626:	4981                	li	s3,0
 628:	b575                	j	4d4 <vprintf+0x60>
        s = va_arg(ap, char*);
 62a:	8b4e                	mv	s6,s3
      state = 0;
 62c:	4981                	li	s3,0
 62e:	b55d                	j	4d4 <vprintf+0x60>
    }
  }
}
 630:	70e6                	ld	ra,120(sp)
 632:	7446                	ld	s0,112(sp)
 634:	74a6                	ld	s1,104(sp)
 636:	7906                	ld	s2,96(sp)
 638:	69e6                	ld	s3,88(sp)
 63a:	6a46                	ld	s4,80(sp)
 63c:	6aa6                	ld	s5,72(sp)
 63e:	6b06                	ld	s6,64(sp)
 640:	7be2                	ld	s7,56(sp)
 642:	7c42                	ld	s8,48(sp)
 644:	7ca2                	ld	s9,40(sp)
 646:	7d02                	ld	s10,32(sp)
 648:	6de2                	ld	s11,24(sp)
 64a:	6109                	addi	sp,sp,128
 64c:	8082                	ret

000000000000064e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 64e:	715d                	addi	sp,sp,-80
 650:	ec06                	sd	ra,24(sp)
 652:	e822                	sd	s0,16(sp)
 654:	1000                	addi	s0,sp,32
 656:	e010                	sd	a2,0(s0)
 658:	e414                	sd	a3,8(s0)
 65a:	e818                	sd	a4,16(s0)
 65c:	ec1c                	sd	a5,24(s0)
 65e:	03043023          	sd	a6,32(s0)
 662:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 666:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 66a:	8622                	mv	a2,s0
 66c:	00000097          	auipc	ra,0x0
 670:	e08080e7          	jalr	-504(ra) # 474 <vprintf>
}
 674:	60e2                	ld	ra,24(sp)
 676:	6442                	ld	s0,16(sp)
 678:	6161                	addi	sp,sp,80
 67a:	8082                	ret

000000000000067c <printf>:

void
printf(const char *fmt, ...)
{
 67c:	711d                	addi	sp,sp,-96
 67e:	ec06                	sd	ra,24(sp)
 680:	e822                	sd	s0,16(sp)
 682:	1000                	addi	s0,sp,32
 684:	e40c                	sd	a1,8(s0)
 686:	e810                	sd	a2,16(s0)
 688:	ec14                	sd	a3,24(s0)
 68a:	f018                	sd	a4,32(s0)
 68c:	f41c                	sd	a5,40(s0)
 68e:	03043823          	sd	a6,48(s0)
 692:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 696:	00840613          	addi	a2,s0,8
 69a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 69e:	85aa                	mv	a1,a0
 6a0:	4505                	li	a0,1
 6a2:	00000097          	auipc	ra,0x0
 6a6:	dd2080e7          	jalr	-558(ra) # 474 <vprintf>
}
 6aa:	60e2                	ld	ra,24(sp)
 6ac:	6442                	ld	s0,16(sp)
 6ae:	6125                	addi	sp,sp,96
 6b0:	8082                	ret

00000000000006b2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b2:	1141                	addi	sp,sp,-16
 6b4:	e422                	sd	s0,8(sp)
 6b6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6b8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6bc:	00000797          	auipc	a5,0x0
 6c0:	1a478793          	addi	a5,a5,420 # 860 <__bss_start>
 6c4:	639c                	ld	a5,0(a5)
 6c6:	a805                	j	6f6 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6c8:	4618                	lw	a4,8(a2)
 6ca:	9db9                	addw	a1,a1,a4
 6cc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6d0:	6398                	ld	a4,0(a5)
 6d2:	6318                	ld	a4,0(a4)
 6d4:	fee53823          	sd	a4,-16(a0)
 6d8:	a091                	j	71c <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6da:	ff852703          	lw	a4,-8(a0)
 6de:	9e39                	addw	a2,a2,a4
 6e0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6e2:	ff053703          	ld	a4,-16(a0)
 6e6:	e398                	sd	a4,0(a5)
 6e8:	a099                	j	72e <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ea:	6398                	ld	a4,0(a5)
 6ec:	00e7e463          	bltu	a5,a4,6f4 <free+0x42>
 6f0:	00e6ea63          	bltu	a3,a4,704 <free+0x52>
{
 6f4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f6:	fed7fae3          	bleu	a3,a5,6ea <free+0x38>
 6fa:	6398                	ld	a4,0(a5)
 6fc:	00e6e463          	bltu	a3,a4,704 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 700:	fee7eae3          	bltu	a5,a4,6f4 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 704:	ff852583          	lw	a1,-8(a0)
 708:	6390                	ld	a2,0(a5)
 70a:	02059713          	slli	a4,a1,0x20
 70e:	9301                	srli	a4,a4,0x20
 710:	0712                	slli	a4,a4,0x4
 712:	9736                	add	a4,a4,a3
 714:	fae60ae3          	beq	a2,a4,6c8 <free+0x16>
    bp->s.ptr = p->s.ptr;
 718:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 71c:	4790                	lw	a2,8(a5)
 71e:	02061713          	slli	a4,a2,0x20
 722:	9301                	srli	a4,a4,0x20
 724:	0712                	slli	a4,a4,0x4
 726:	973e                	add	a4,a4,a5
 728:	fae689e3          	beq	a3,a4,6da <free+0x28>
  } else
    p->s.ptr = bp;
 72c:	e394                	sd	a3,0(a5)
  freep = p;
 72e:	00000717          	auipc	a4,0x0
 732:	12f73923          	sd	a5,306(a4) # 860 <__bss_start>
}
 736:	6422                	ld	s0,8(sp)
 738:	0141                	addi	sp,sp,16
 73a:	8082                	ret

000000000000073c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 73c:	7139                	addi	sp,sp,-64
 73e:	fc06                	sd	ra,56(sp)
 740:	f822                	sd	s0,48(sp)
 742:	f426                	sd	s1,40(sp)
 744:	f04a                	sd	s2,32(sp)
 746:	ec4e                	sd	s3,24(sp)
 748:	e852                	sd	s4,16(sp)
 74a:	e456                	sd	s5,8(sp)
 74c:	e05a                	sd	s6,0(sp)
 74e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 750:	02051993          	slli	s3,a0,0x20
 754:	0209d993          	srli	s3,s3,0x20
 758:	09bd                	addi	s3,s3,15
 75a:	0049d993          	srli	s3,s3,0x4
 75e:	2985                	addiw	s3,s3,1
 760:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 764:	00000797          	auipc	a5,0x0
 768:	0fc78793          	addi	a5,a5,252 # 860 <__bss_start>
 76c:	6388                	ld	a0,0(a5)
 76e:	c515                	beqz	a0,79a <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 770:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 772:	4798                	lw	a4,8(a5)
 774:	03277f63          	bleu	s2,a4,7b2 <malloc+0x76>
 778:	8a4e                	mv	s4,s3
 77a:	0009871b          	sext.w	a4,s3
 77e:	6685                	lui	a3,0x1
 780:	00d77363          	bleu	a3,a4,786 <malloc+0x4a>
 784:	6a05                	lui	s4,0x1
 786:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 78a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 78e:	00000497          	auipc	s1,0x0
 792:	0d248493          	addi	s1,s1,210 # 860 <__bss_start>
  if(p == (char*)-1)
 796:	5b7d                	li	s6,-1
 798:	a885                	j	808 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 79a:	00000797          	auipc	a5,0x0
 79e:	0ce78793          	addi	a5,a5,206 # 868 <base>
 7a2:	00000717          	auipc	a4,0x0
 7a6:	0af73f23          	sd	a5,190(a4) # 860 <__bss_start>
 7aa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7ac:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7b0:	b7e1                	j	778 <malloc+0x3c>
      if(p->s.size == nunits)
 7b2:	02e90b63          	beq	s2,a4,7e8 <malloc+0xac>
        p->s.size -= nunits;
 7b6:	4137073b          	subw	a4,a4,s3
 7ba:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7bc:	1702                	slli	a4,a4,0x20
 7be:	9301                	srli	a4,a4,0x20
 7c0:	0712                	slli	a4,a4,0x4
 7c2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7c4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7c8:	00000717          	auipc	a4,0x0
 7cc:	08a73c23          	sd	a0,152(a4) # 860 <__bss_start>
      return (void*)(p + 1);
 7d0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7d4:	70e2                	ld	ra,56(sp)
 7d6:	7442                	ld	s0,48(sp)
 7d8:	74a2                	ld	s1,40(sp)
 7da:	7902                	ld	s2,32(sp)
 7dc:	69e2                	ld	s3,24(sp)
 7de:	6a42                	ld	s4,16(sp)
 7e0:	6aa2                	ld	s5,8(sp)
 7e2:	6b02                	ld	s6,0(sp)
 7e4:	6121                	addi	sp,sp,64
 7e6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7e8:	6398                	ld	a4,0(a5)
 7ea:	e118                	sd	a4,0(a0)
 7ec:	bff1                	j	7c8 <malloc+0x8c>
  hp->s.size = nu;
 7ee:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 7f2:	0541                	addi	a0,a0,16
 7f4:	00000097          	auipc	ra,0x0
 7f8:	ebe080e7          	jalr	-322(ra) # 6b2 <free>
  return freep;
 7fc:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 7fe:	d979                	beqz	a0,7d4 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 800:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 802:	4798                	lw	a4,8(a5)
 804:	fb2777e3          	bleu	s2,a4,7b2 <malloc+0x76>
    if(p == freep)
 808:	6098                	ld	a4,0(s1)
 80a:	853e                	mv	a0,a5
 80c:	fef71ae3          	bne	a4,a5,800 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 810:	8552                	mv	a0,s4
 812:	00000097          	auipc	ra,0x0
 816:	b6a080e7          	jalr	-1174(ra) # 37c <sbrk>
  if(p == (char*)-1)
 81a:	fd651ae3          	bne	a0,s6,7ee <malloc+0xb2>
        return 0;
 81e:	4501                	li	a0,0
 820:	bf55                	j	7d4 <malloc+0x98>
