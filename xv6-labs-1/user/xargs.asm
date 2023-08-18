
user/_xargs：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

#define buf_size 512

int main(int argc, char *argv[]) {
   0:	a8010113          	addi	sp,sp,-1408
   4:	56113c23          	sd	ra,1400(sp)
   8:	56813823          	sd	s0,1392(sp)
   c:	56913423          	sd	s1,1384(sp)
  10:	57213023          	sd	s2,1376(sp)
  14:	55313c23          	sd	s3,1368(sp)
  18:	55413823          	sd	s4,1360(sp)
  1c:	55513423          	sd	s5,1352(sp)
  20:	55613023          	sd	s6,1344(sp)
  24:	53713c23          	sd	s7,1336(sp)
  28:	53813823          	sd	s8,1328(sp)
  2c:	53913423          	sd	s9,1320(sp)
  30:	53a13023          	sd	s10,1312(sp)
  34:	58010413          	addi	s0,sp,1408
  38:	8b2a                	mv	s6,a0
  3a:	8cae                	mv	s9,a1
  char buf[buf_size + 1] = {0};
  3c:	20100613          	li	a2,513
  40:	4581                	li	a1,0
  42:	d9840513          	addi	a0,s0,-616
  46:	00000097          	auipc	ra,0x0
  4a:	20c080e7          	jalr	524(ra) # 252 <memset>
  uint occupy = 0;
  char *xargv[MAXARG] = {0};
  4e:	10000613          	li	a2,256
  52:	4581                	li	a1,0
  54:	c9840513          	addi	a0,s0,-872
  58:	00000097          	auipc	ra,0x0
  5c:	1fa080e7          	jalr	506(ra) # 252 <memset>
  int stdin_end = 0;

  for (int i = 1; i < argc; i++) {
  60:	4785                	li	a5,1
  62:	0367d463          	ble	s6,a5,8a <main+0x8a>
  66:	008c8693          	addi	a3,s9,8
  6a:	c9840793          	addi	a5,s0,-872
  6e:	ffeb071b          	addiw	a4,s6,-2
  72:	1702                	slli	a4,a4,0x20
  74:	9301                	srli	a4,a4,0x20
  76:	070e                	slli	a4,a4,0x3
  78:	ca040613          	addi	a2,s0,-864
  7c:	9732                	add	a4,a4,a2
    xargv[i - 1] = argv[i];
  7e:	6290                	ld	a2,0(a3)
  80:	e390                	sd	a2,0(a5)
  for (int i = 1; i < argc; i++) {
  82:	06a1                	addi	a3,a3,8
  84:	07a1                	addi	a5,a5,8
  86:	fee79ce3          	bne	a5,a4,7e <main+0x7e>
  int stdin_end = 0;
  8a:	4c01                	li	s8,0
  uint occupy = 0;
  8c:	4b81                	li	s7,0
    // process lines read
    char *line_end = strchr(buf, '\n');
    while (line_end) {
      char xbuf[buf_size + 1] = {0};
      memcpy(xbuf, buf, line_end - buf);
      xargv[argc - 1] = xbuf;
  8e:	3b7d                	addiw	s6,s6,-1
  90:	0b0e                	slli	s6,s6,0x3
  92:	fa040793          	addi	a5,s0,-96
  96:	9b3e                	add	s6,s6,a5
  while (!(stdin_end && occupy == 0)) {
  98:	020c0263          	beqz	s8,bc <main+0xbc>
  9c:	120b8963          	beqz	s7,1ce <main+0x1ce>
    char *line_end = strchr(buf, '\n');
  a0:	45a9                	li	a1,10
  a2:	d9840513          	addi	a0,s0,-616
  a6:	00000097          	auipc	ra,0x0
  aa:	1d2080e7          	jalr	466(ra) # 278 <strchr>
  ae:	8a2a                	mv	s4,a0
    while (line_end) {
  b0:	d565                	beqz	a0,98 <main+0x98>
      char xbuf[buf_size + 1] = {0};
  b2:	a9040913          	addi	s2,s0,-1392
      memcpy(xbuf, buf, line_end - buf);
  b6:	d9840993          	addi	s3,s0,-616
  ba:	a885                	j	12a <main+0x12a>
      int read_bytes = read(0, buf + occupy, remain_size);
  bc:	020b9593          	slli	a1,s7,0x20
  c0:	9181                	srli	a1,a1,0x20
  c2:	20000613          	li	a2,512
  c6:	4176063b          	subw	a2,a2,s7
  ca:	d9840793          	addi	a5,s0,-616
  ce:	95be                	add	a1,a1,a5
  d0:	4501                	li	a0,0
  d2:	00000097          	auipc	ra,0x0
  d6:	3ae080e7          	jalr	942(ra) # 480 <read>
  da:	84aa                	mv	s1,a0
      if (read_bytes < 0) {
  dc:	00054663          	bltz	a0,e8 <main+0xe8>
      if (read_bytes == 0) {
  e0:	cd11                	beqz	a0,fc <main+0xfc>
      occupy += read_bytes;
  e2:	01748bbb          	addw	s7,s1,s7
  e6:	bf6d                	j	a0 <main+0xa0>
        fprintf(2, "xargs: read returns -1 error\n");
  e8:	00001597          	auipc	a1,0x1
  ec:	8a058593          	addi	a1,a1,-1888 # 988 <malloc+0xe8>
  f0:	4509                	li	a0,2
  f2:	00000097          	auipc	ra,0x0
  f6:	6c0080e7          	jalr	1728(ra) # 7b2 <fprintf>
      if (read_bytes == 0) {
  fa:	b7e5                	j	e2 <main+0xe2>
        close(0);
  fc:	4501                	li	a0,0
  fe:	00000097          	auipc	ra,0x0
 102:	392080e7          	jalr	914(ra) # 490 <close>
        stdin_end = 1;
 106:	4c05                	li	s8,1
 108:	bfe9                	j	e2 <main+0xe2>
      int ret = fork();
      if (ret == 0) {
        // i am child
        if (!stdin_end) {
          close(0);
 10a:	00000097          	auipc	ra,0x0
 10e:	386080e7          	jalr	902(ra) # 490 <close>
        }
        if (exec(argv[1], xargv) < 0) {
 112:	c9840593          	addi	a1,s0,-872
 116:	008cb503          	ld	a0,8(s9)
 11a:	00000097          	auipc	ra,0x0
 11e:	386080e7          	jalr	902(ra) # 4a0 <exec>
 122:	02054f63          	bltz	a0,160 <main+0x160>
    while (line_end) {
 126:	f60a09e3          	beqz	s4,98 <main+0x98>
      char xbuf[buf_size + 1] = {0};
 12a:	20100613          	li	a2,513
 12e:	4581                	li	a1,0
 130:	854a                	mv	a0,s2
 132:	00000097          	auipc	ra,0x0
 136:	120080e7          	jalr	288(ra) # 252 <memset>
      memcpy(xbuf, buf, line_end - buf);
 13a:	413a04bb          	subw	s1,s4,s3
 13e:	8626                	mv	a2,s1
 140:	85ce                	mv	a1,s3
 142:	854a                	mv	a0,s2
 144:	00000097          	auipc	ra,0x0
 148:	304080e7          	jalr	772(ra) # 448 <memcpy>
      xargv[argc - 1] = xbuf;
 14c:	cf2b3c23          	sd	s2,-776(s6)
      int ret = fork();
 150:	00000097          	auipc	ra,0x0
 154:	310080e7          	jalr	784(ra) # 460 <fork>
      if (ret == 0) {
 158:	e115                	bnez	a0,17c <main+0x17c>
        if (!stdin_end) {
 15a:	fa0c1ce3          	bnez	s8,112 <main+0x112>
 15e:	b775                	j	10a <main+0x10a>
          fprintf(2, "xargs: exec fails with -1\n");
 160:	00001597          	auipc	a1,0x1
 164:	84858593          	addi	a1,a1,-1976 # 9a8 <malloc+0x108>
 168:	4509                	li	a0,2
 16a:	00000097          	auipc	ra,0x0
 16e:	648080e7          	jalr	1608(ra) # 7b2 <fprintf>
          exit(1);
 172:	4505                	li	a0,1
 174:	00000097          	auipc	ra,0x0
 178:	2f4080e7          	jalr	756(ra) # 468 <exit>
        }
      } else {
        // trim out line already processed
        memmove(buf, line_end + 1, occupy - (line_end - buf) - 1);
 17c:	fffb8d1b          	addiw	s10,s7,-1
 180:	409d0abb          	subw	s5,s10,s1
 184:	000a8b9b          	sext.w	s7,s5
 188:	865e                	mv	a2,s7
 18a:	001a0593          	addi	a1,s4,1
 18e:	854e                	mv	a0,s3
 190:	00000097          	auipc	ra,0x0
 194:	216080e7          	jalr	534(ra) # 3a6 <memmove>
        occupy -= line_end - buf + 1;
        memset(buf + occupy, 0, buf_size - occupy);
 198:	41a4863b          	subw	a2,s1,s10
 19c:	020a9513          	slli	a0,s5,0x20
 1a0:	9101                	srli	a0,a0,0x20
 1a2:	2006061b          	addiw	a2,a2,512
 1a6:	4581                	li	a1,0
 1a8:	954e                	add	a0,a0,s3
 1aa:	00000097          	auipc	ra,0x0
 1ae:	0a8080e7          	jalr	168(ra) # 252 <memset>
        // harvest zombie
        int pid;
        wait(&pid);
 1b2:	a8c40513          	addi	a0,s0,-1396
 1b6:	00000097          	auipc	ra,0x0
 1ba:	2ba080e7          	jalr	698(ra) # 470 <wait>

        line_end = strchr(buf, '\n');
 1be:	45a9                	li	a1,10
 1c0:	854e                	mv	a0,s3
 1c2:	00000097          	auipc	ra,0x0
 1c6:	0b6080e7          	jalr	182(ra) # 278 <strchr>
 1ca:	8a2a                	mv	s4,a0
 1cc:	bfa9                	j	126 <main+0x126>
      }
    }
  }
  exit(0);
 1ce:	4501                	li	a0,0
 1d0:	00000097          	auipc	ra,0x0
 1d4:	298080e7          	jalr	664(ra) # 468 <exit>

00000000000001d8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1d8:	1141                	addi	sp,sp,-16
 1da:	e422                	sd	s0,8(sp)
 1dc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1de:	87aa                	mv	a5,a0
 1e0:	0585                	addi	a1,a1,1
 1e2:	0785                	addi	a5,a5,1
 1e4:	fff5c703          	lbu	a4,-1(a1)
 1e8:	fee78fa3          	sb	a4,-1(a5)
 1ec:	fb75                	bnez	a4,1e0 <strcpy+0x8>
    ;
  return os;
}
 1ee:	6422                	ld	s0,8(sp)
 1f0:	0141                	addi	sp,sp,16
 1f2:	8082                	ret

00000000000001f4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1f4:	1141                	addi	sp,sp,-16
 1f6:	e422                	sd	s0,8(sp)
 1f8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1fa:	00054783          	lbu	a5,0(a0)
 1fe:	cf91                	beqz	a5,21a <strcmp+0x26>
 200:	0005c703          	lbu	a4,0(a1)
 204:	00f71b63          	bne	a4,a5,21a <strcmp+0x26>
    p++, q++;
 208:	0505                	addi	a0,a0,1
 20a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 20c:	00054783          	lbu	a5,0(a0)
 210:	c789                	beqz	a5,21a <strcmp+0x26>
 212:	0005c703          	lbu	a4,0(a1)
 216:	fef709e3          	beq	a4,a5,208 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 21a:	0005c503          	lbu	a0,0(a1)
}
 21e:	40a7853b          	subw	a0,a5,a0
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret

0000000000000228 <strlen>:

uint
strlen(const char *s)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e422                	sd	s0,8(sp)
 22c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 22e:	00054783          	lbu	a5,0(a0)
 232:	cf91                	beqz	a5,24e <strlen+0x26>
 234:	0505                	addi	a0,a0,1
 236:	87aa                	mv	a5,a0
 238:	4685                	li	a3,1
 23a:	9e89                	subw	a3,a3,a0
 23c:	00f6853b          	addw	a0,a3,a5
 240:	0785                	addi	a5,a5,1
 242:	fff7c703          	lbu	a4,-1(a5)
 246:	fb7d                	bnez	a4,23c <strlen+0x14>
    ;
  return n;
}
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret
  for(n = 0; s[n]; n++)
 24e:	4501                	li	a0,0
 250:	bfe5                	j	248 <strlen+0x20>

0000000000000252 <memset>:

void*
memset(void *dst, int c, uint n)
{
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 258:	ce09                	beqz	a2,272 <memset+0x20>
 25a:	87aa                	mv	a5,a0
 25c:	fff6071b          	addiw	a4,a2,-1
 260:	1702                	slli	a4,a4,0x20
 262:	9301                	srli	a4,a4,0x20
 264:	0705                	addi	a4,a4,1
 266:	972a                	add	a4,a4,a0
    cdst[i] = c;
 268:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 26c:	0785                	addi	a5,a5,1
 26e:	fee79de3          	bne	a5,a4,268 <memset+0x16>
  }
  return dst;
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret

0000000000000278 <strchr>:

char*
strchr(const char *s, char c)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e422                	sd	s0,8(sp)
 27c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 27e:	00054783          	lbu	a5,0(a0)
 282:	cf91                	beqz	a5,29e <strchr+0x26>
    if(*s == c)
 284:	00f58a63          	beq	a1,a5,298 <strchr+0x20>
  for(; *s; s++)
 288:	0505                	addi	a0,a0,1
 28a:	00054783          	lbu	a5,0(a0)
 28e:	c781                	beqz	a5,296 <strchr+0x1e>
    if(*s == c)
 290:	feb79ce3          	bne	a5,a1,288 <strchr+0x10>
 294:	a011                	j	298 <strchr+0x20>
      return (char*)s;
  return 0;
 296:	4501                	li	a0,0
}
 298:	6422                	ld	s0,8(sp)
 29a:	0141                	addi	sp,sp,16
 29c:	8082                	ret
  return 0;
 29e:	4501                	li	a0,0
 2a0:	bfe5                	j	298 <strchr+0x20>

00000000000002a2 <gets>:

char*
gets(char *buf, int max)
{
 2a2:	711d                	addi	sp,sp,-96
 2a4:	ec86                	sd	ra,88(sp)
 2a6:	e8a2                	sd	s0,80(sp)
 2a8:	e4a6                	sd	s1,72(sp)
 2aa:	e0ca                	sd	s2,64(sp)
 2ac:	fc4e                	sd	s3,56(sp)
 2ae:	f852                	sd	s4,48(sp)
 2b0:	f456                	sd	s5,40(sp)
 2b2:	f05a                	sd	s6,32(sp)
 2b4:	ec5e                	sd	s7,24(sp)
 2b6:	1080                	addi	s0,sp,96
 2b8:	8baa                	mv	s7,a0
 2ba:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2bc:	892a                	mv	s2,a0
 2be:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2c0:	4aa9                	li	s5,10
 2c2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2c4:	0019849b          	addiw	s1,s3,1
 2c8:	0344d863          	ble	s4,s1,2f8 <gets+0x56>
    cc = read(0, &c, 1);
 2cc:	4605                	li	a2,1
 2ce:	faf40593          	addi	a1,s0,-81
 2d2:	4501                	li	a0,0
 2d4:	00000097          	auipc	ra,0x0
 2d8:	1ac080e7          	jalr	428(ra) # 480 <read>
    if(cc < 1)
 2dc:	00a05e63          	blez	a0,2f8 <gets+0x56>
    buf[i++] = c;
 2e0:	faf44783          	lbu	a5,-81(s0)
 2e4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2e8:	01578763          	beq	a5,s5,2f6 <gets+0x54>
 2ec:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 2ee:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 2f0:	fd679ae3          	bne	a5,s6,2c4 <gets+0x22>
 2f4:	a011                	j	2f8 <gets+0x56>
  for(i=0; i+1 < max; ){
 2f6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2f8:	99de                	add	s3,s3,s7
 2fa:	00098023          	sb	zero,0(s3)
  return buf;
}
 2fe:	855e                	mv	a0,s7
 300:	60e6                	ld	ra,88(sp)
 302:	6446                	ld	s0,80(sp)
 304:	64a6                	ld	s1,72(sp)
 306:	6906                	ld	s2,64(sp)
 308:	79e2                	ld	s3,56(sp)
 30a:	7a42                	ld	s4,48(sp)
 30c:	7aa2                	ld	s5,40(sp)
 30e:	7b02                	ld	s6,32(sp)
 310:	6be2                	ld	s7,24(sp)
 312:	6125                	addi	sp,sp,96
 314:	8082                	ret

0000000000000316 <stat>:

int
stat(const char *n, struct stat *st)
{
 316:	1101                	addi	sp,sp,-32
 318:	ec06                	sd	ra,24(sp)
 31a:	e822                	sd	s0,16(sp)
 31c:	e426                	sd	s1,8(sp)
 31e:	e04a                	sd	s2,0(sp)
 320:	1000                	addi	s0,sp,32
 322:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 324:	4581                	li	a1,0
 326:	00000097          	auipc	ra,0x0
 32a:	182080e7          	jalr	386(ra) # 4a8 <open>
  if(fd < 0)
 32e:	02054563          	bltz	a0,358 <stat+0x42>
 332:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 334:	85ca                	mv	a1,s2
 336:	00000097          	auipc	ra,0x0
 33a:	18a080e7          	jalr	394(ra) # 4c0 <fstat>
 33e:	892a                	mv	s2,a0
  close(fd);
 340:	8526                	mv	a0,s1
 342:	00000097          	auipc	ra,0x0
 346:	14e080e7          	jalr	334(ra) # 490 <close>
  return r;
}
 34a:	854a                	mv	a0,s2
 34c:	60e2                	ld	ra,24(sp)
 34e:	6442                	ld	s0,16(sp)
 350:	64a2                	ld	s1,8(sp)
 352:	6902                	ld	s2,0(sp)
 354:	6105                	addi	sp,sp,32
 356:	8082                	ret
    return -1;
 358:	597d                	li	s2,-1
 35a:	bfc5                	j	34a <stat+0x34>

000000000000035c <atoi>:

int
atoi(const char *s)
{
 35c:	1141                	addi	sp,sp,-16
 35e:	e422                	sd	s0,8(sp)
 360:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 362:	00054683          	lbu	a3,0(a0)
 366:	fd06879b          	addiw	a5,a3,-48
 36a:	0ff7f793          	andi	a5,a5,255
 36e:	4725                	li	a4,9
 370:	02f76963          	bltu	a4,a5,3a2 <atoi+0x46>
 374:	862a                	mv	a2,a0
  n = 0;
 376:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 378:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 37a:	0605                	addi	a2,a2,1
 37c:	0025179b          	slliw	a5,a0,0x2
 380:	9fa9                	addw	a5,a5,a0
 382:	0017979b          	slliw	a5,a5,0x1
 386:	9fb5                	addw	a5,a5,a3
 388:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 38c:	00064683          	lbu	a3,0(a2)
 390:	fd06871b          	addiw	a4,a3,-48
 394:	0ff77713          	andi	a4,a4,255
 398:	fee5f1e3          	bleu	a4,a1,37a <atoi+0x1e>
  return n;
}
 39c:	6422                	ld	s0,8(sp)
 39e:	0141                	addi	sp,sp,16
 3a0:	8082                	ret
  n = 0;
 3a2:	4501                	li	a0,0
 3a4:	bfe5                	j	39c <atoi+0x40>

00000000000003a6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3a6:	1141                	addi	sp,sp,-16
 3a8:	e422                	sd	s0,8(sp)
 3aa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3ac:	02b57663          	bleu	a1,a0,3d8 <memmove+0x32>
    while(n-- > 0)
 3b0:	02c05163          	blez	a2,3d2 <memmove+0x2c>
 3b4:	fff6079b          	addiw	a5,a2,-1
 3b8:	1782                	slli	a5,a5,0x20
 3ba:	9381                	srli	a5,a5,0x20
 3bc:	0785                	addi	a5,a5,1
 3be:	97aa                	add	a5,a5,a0
  dst = vdst;
 3c0:	872a                	mv	a4,a0
      *dst++ = *src++;
 3c2:	0585                	addi	a1,a1,1
 3c4:	0705                	addi	a4,a4,1
 3c6:	fff5c683          	lbu	a3,-1(a1)
 3ca:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3ce:	fee79ae3          	bne	a5,a4,3c2 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3d2:	6422                	ld	s0,8(sp)
 3d4:	0141                	addi	sp,sp,16
 3d6:	8082                	ret
    dst += n;
 3d8:	00c50733          	add	a4,a0,a2
    src += n;
 3dc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3de:	fec05ae3          	blez	a2,3d2 <memmove+0x2c>
 3e2:	fff6079b          	addiw	a5,a2,-1
 3e6:	1782                	slli	a5,a5,0x20
 3e8:	9381                	srli	a5,a5,0x20
 3ea:	fff7c793          	not	a5,a5
 3ee:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3f0:	15fd                	addi	a1,a1,-1
 3f2:	177d                	addi	a4,a4,-1
 3f4:	0005c683          	lbu	a3,0(a1)
 3f8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3fc:	fef71ae3          	bne	a4,a5,3f0 <memmove+0x4a>
 400:	bfc9                	j	3d2 <memmove+0x2c>

0000000000000402 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 402:	1141                	addi	sp,sp,-16
 404:	e422                	sd	s0,8(sp)
 406:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 408:	ce15                	beqz	a2,444 <memcmp+0x42>
 40a:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 40e:	00054783          	lbu	a5,0(a0)
 412:	0005c703          	lbu	a4,0(a1)
 416:	02e79063          	bne	a5,a4,436 <memcmp+0x34>
 41a:	1682                	slli	a3,a3,0x20
 41c:	9281                	srli	a3,a3,0x20
 41e:	0685                	addi	a3,a3,1
 420:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 422:	0505                	addi	a0,a0,1
    p2++;
 424:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 426:	00d50d63          	beq	a0,a3,440 <memcmp+0x3e>
    if (*p1 != *p2) {
 42a:	00054783          	lbu	a5,0(a0)
 42e:	0005c703          	lbu	a4,0(a1)
 432:	fee788e3          	beq	a5,a4,422 <memcmp+0x20>
      return *p1 - *p2;
 436:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 43a:	6422                	ld	s0,8(sp)
 43c:	0141                	addi	sp,sp,16
 43e:	8082                	ret
  return 0;
 440:	4501                	li	a0,0
 442:	bfe5                	j	43a <memcmp+0x38>
 444:	4501                	li	a0,0
 446:	bfd5                	j	43a <memcmp+0x38>

0000000000000448 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 448:	1141                	addi	sp,sp,-16
 44a:	e406                	sd	ra,8(sp)
 44c:	e022                	sd	s0,0(sp)
 44e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 450:	00000097          	auipc	ra,0x0
 454:	f56080e7          	jalr	-170(ra) # 3a6 <memmove>
}
 458:	60a2                	ld	ra,8(sp)
 45a:	6402                	ld	s0,0(sp)
 45c:	0141                	addi	sp,sp,16
 45e:	8082                	ret

0000000000000460 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 460:	4885                	li	a7,1
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <exit>:
.global exit
exit:
 li a7, SYS_exit
 468:	4889                	li	a7,2
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <wait>:
.global wait
wait:
 li a7, SYS_wait
 470:	488d                	li	a7,3
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 478:	4891                	li	a7,4
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <read>:
.global read
read:
 li a7, SYS_read
 480:	4895                	li	a7,5
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <write>:
.global write
write:
 li a7, SYS_write
 488:	48c1                	li	a7,16
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <close>:
.global close
close:
 li a7, SYS_close
 490:	48d5                	li	a7,21
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <kill>:
.global kill
kill:
 li a7, SYS_kill
 498:	4899                	li	a7,6
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4a0:	489d                	li	a7,7
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <open>:
.global open
open:
 li a7, SYS_open
 4a8:	48bd                	li	a7,15
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4b0:	48c5                	li	a7,17
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4b8:	48c9                	li	a7,18
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4c0:	48a1                	li	a7,8
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <link>:
.global link
link:
 li a7, SYS_link
 4c8:	48cd                	li	a7,19
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4d0:	48d1                	li	a7,20
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4d8:	48a5                	li	a7,9
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4e0:	48a9                	li	a7,10
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4e8:	48ad                	li	a7,11
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4f0:	48b1                	li	a7,12
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4f8:	48b5                	li	a7,13
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 500:	48b9                	li	a7,14
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 508:	1101                	addi	sp,sp,-32
 50a:	ec06                	sd	ra,24(sp)
 50c:	e822                	sd	s0,16(sp)
 50e:	1000                	addi	s0,sp,32
 510:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 514:	4605                	li	a2,1
 516:	fef40593          	addi	a1,s0,-17
 51a:	00000097          	auipc	ra,0x0
 51e:	f6e080e7          	jalr	-146(ra) # 488 <write>
}
 522:	60e2                	ld	ra,24(sp)
 524:	6442                	ld	s0,16(sp)
 526:	6105                	addi	sp,sp,32
 528:	8082                	ret

000000000000052a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 52a:	7139                	addi	sp,sp,-64
 52c:	fc06                	sd	ra,56(sp)
 52e:	f822                	sd	s0,48(sp)
 530:	f426                	sd	s1,40(sp)
 532:	f04a                	sd	s2,32(sp)
 534:	ec4e                	sd	s3,24(sp)
 536:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 538:	c299                	beqz	a3,53e <printint+0x14>
 53a:	0005cd63          	bltz	a1,554 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 53e:	2581                	sext.w	a1,a1
  neg = 0;
 540:	4301                	li	t1,0
 542:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 546:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 548:	2601                	sext.w	a2,a2
 54a:	00000897          	auipc	a7,0x0
 54e:	47e88893          	addi	a7,a7,1150 # 9c8 <digits>
 552:	a801                	j	562 <printint+0x38>
    x = -xx;
 554:	40b005bb          	negw	a1,a1
 558:	2581                	sext.w	a1,a1
    neg = 1;
 55a:	4305                	li	t1,1
    x = -xx;
 55c:	b7dd                	j	542 <printint+0x18>
  }while((x /= base) != 0);
 55e:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 560:	8836                	mv	a6,a3
 562:	0018069b          	addiw	a3,a6,1
 566:	02c5f7bb          	remuw	a5,a1,a2
 56a:	1782                	slli	a5,a5,0x20
 56c:	9381                	srli	a5,a5,0x20
 56e:	97c6                	add	a5,a5,a7
 570:	0007c783          	lbu	a5,0(a5)
 574:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 578:	0705                	addi	a4,a4,1
 57a:	02c5d7bb          	divuw	a5,a1,a2
 57e:	fec5f0e3          	bleu	a2,a1,55e <printint+0x34>
  if(neg)
 582:	00030b63          	beqz	t1,598 <printint+0x6e>
    buf[i++] = '-';
 586:	fd040793          	addi	a5,s0,-48
 58a:	96be                	add	a3,a3,a5
 58c:	02d00793          	li	a5,45
 590:	fef68823          	sb	a5,-16(a3)
 594:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 598:	02d05963          	blez	a3,5ca <printint+0xa0>
 59c:	89aa                	mv	s3,a0
 59e:	fc040793          	addi	a5,s0,-64
 5a2:	00d784b3          	add	s1,a5,a3
 5a6:	fff78913          	addi	s2,a5,-1
 5aa:	9936                	add	s2,s2,a3
 5ac:	36fd                	addiw	a3,a3,-1
 5ae:	1682                	slli	a3,a3,0x20
 5b0:	9281                	srli	a3,a3,0x20
 5b2:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 5b6:	fff4c583          	lbu	a1,-1(s1)
 5ba:	854e                	mv	a0,s3
 5bc:	00000097          	auipc	ra,0x0
 5c0:	f4c080e7          	jalr	-180(ra) # 508 <putc>
  while(--i >= 0)
 5c4:	14fd                	addi	s1,s1,-1
 5c6:	ff2498e3          	bne	s1,s2,5b6 <printint+0x8c>
}
 5ca:	70e2                	ld	ra,56(sp)
 5cc:	7442                	ld	s0,48(sp)
 5ce:	74a2                	ld	s1,40(sp)
 5d0:	7902                	ld	s2,32(sp)
 5d2:	69e2                	ld	s3,24(sp)
 5d4:	6121                	addi	sp,sp,64
 5d6:	8082                	ret

00000000000005d8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5d8:	7119                	addi	sp,sp,-128
 5da:	fc86                	sd	ra,120(sp)
 5dc:	f8a2                	sd	s0,112(sp)
 5de:	f4a6                	sd	s1,104(sp)
 5e0:	f0ca                	sd	s2,96(sp)
 5e2:	ecce                	sd	s3,88(sp)
 5e4:	e8d2                	sd	s4,80(sp)
 5e6:	e4d6                	sd	s5,72(sp)
 5e8:	e0da                	sd	s6,64(sp)
 5ea:	fc5e                	sd	s7,56(sp)
 5ec:	f862                	sd	s8,48(sp)
 5ee:	f466                	sd	s9,40(sp)
 5f0:	f06a                	sd	s10,32(sp)
 5f2:	ec6e                	sd	s11,24(sp)
 5f4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5f6:	0005c483          	lbu	s1,0(a1)
 5fa:	18048d63          	beqz	s1,794 <vprintf+0x1bc>
 5fe:	8aaa                	mv	s5,a0
 600:	8b32                	mv	s6,a2
 602:	00158913          	addi	s2,a1,1
  state = 0;
 606:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 608:	02500a13          	li	s4,37
      if(c == 'd'){
 60c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 610:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 614:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 618:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 61c:	00000b97          	auipc	s7,0x0
 620:	3acb8b93          	addi	s7,s7,940 # 9c8 <digits>
 624:	a839                	j	642 <vprintf+0x6a>
        putc(fd, c);
 626:	85a6                	mv	a1,s1
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	ede080e7          	jalr	-290(ra) # 508 <putc>
 632:	a019                	j	638 <vprintf+0x60>
    } else if(state == '%'){
 634:	01498f63          	beq	s3,s4,652 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 638:	0905                	addi	s2,s2,1
 63a:	fff94483          	lbu	s1,-1(s2)
 63e:	14048b63          	beqz	s1,794 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 642:	0004879b          	sext.w	a5,s1
    if(state == 0){
 646:	fe0997e3          	bnez	s3,634 <vprintf+0x5c>
      if(c == '%'){
 64a:	fd479ee3          	bne	a5,s4,626 <vprintf+0x4e>
        state = '%';
 64e:	89be                	mv	s3,a5
 650:	b7e5                	j	638 <vprintf+0x60>
      if(c == 'd'){
 652:	05878063          	beq	a5,s8,692 <vprintf+0xba>
      } else if(c == 'l') {
 656:	05978c63          	beq	a5,s9,6ae <vprintf+0xd6>
      } else if(c == 'x') {
 65a:	07a78863          	beq	a5,s10,6ca <vprintf+0xf2>
      } else if(c == 'p') {
 65e:	09b78463          	beq	a5,s11,6e6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 662:	07300713          	li	a4,115
 666:	0ce78563          	beq	a5,a4,730 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 66a:	06300713          	li	a4,99
 66e:	0ee78c63          	beq	a5,a4,766 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 672:	11478663          	beq	a5,s4,77e <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 676:	85d2                	mv	a1,s4
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	e8e080e7          	jalr	-370(ra) # 508 <putc>
        putc(fd, c);
 682:	85a6                	mv	a1,s1
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	e82080e7          	jalr	-382(ra) # 508 <putc>
      }
      state = 0;
 68e:	4981                	li	s3,0
 690:	b765                	j	638 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 692:	008b0493          	addi	s1,s6,8
 696:	4685                	li	a3,1
 698:	4629                	li	a2,10
 69a:	000b2583          	lw	a1,0(s6)
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	e8a080e7          	jalr	-374(ra) # 52a <printint>
 6a8:	8b26                	mv	s6,s1
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	b771                	j	638 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ae:	008b0493          	addi	s1,s6,8
 6b2:	4681                	li	a3,0
 6b4:	4629                	li	a2,10
 6b6:	000b2583          	lw	a1,0(s6)
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	e6e080e7          	jalr	-402(ra) # 52a <printint>
 6c4:	8b26                	mv	s6,s1
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	bf85                	j	638 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6ca:	008b0493          	addi	s1,s6,8
 6ce:	4681                	li	a3,0
 6d0:	4641                	li	a2,16
 6d2:	000b2583          	lw	a1,0(s6)
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	e52080e7          	jalr	-430(ra) # 52a <printint>
 6e0:	8b26                	mv	s6,s1
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	bf91                	j	638 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6e6:	008b0793          	addi	a5,s6,8
 6ea:	f8f43423          	sd	a5,-120(s0)
 6ee:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6f2:	03000593          	li	a1,48
 6f6:	8556                	mv	a0,s5
 6f8:	00000097          	auipc	ra,0x0
 6fc:	e10080e7          	jalr	-496(ra) # 508 <putc>
  putc(fd, 'x');
 700:	85ea                	mv	a1,s10
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	e04080e7          	jalr	-508(ra) # 508 <putc>
 70c:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 70e:	03c9d793          	srli	a5,s3,0x3c
 712:	97de                	add	a5,a5,s7
 714:	0007c583          	lbu	a1,0(a5)
 718:	8556                	mv	a0,s5
 71a:	00000097          	auipc	ra,0x0
 71e:	dee080e7          	jalr	-530(ra) # 508 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 722:	0992                	slli	s3,s3,0x4
 724:	34fd                	addiw	s1,s1,-1
 726:	f4e5                	bnez	s1,70e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 728:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 72c:	4981                	li	s3,0
 72e:	b729                	j	638 <vprintf+0x60>
        s = va_arg(ap, char*);
 730:	008b0993          	addi	s3,s6,8
 734:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 738:	c085                	beqz	s1,758 <vprintf+0x180>
        while(*s != 0){
 73a:	0004c583          	lbu	a1,0(s1)
 73e:	c9a1                	beqz	a1,78e <vprintf+0x1b6>
          putc(fd, *s);
 740:	8556                	mv	a0,s5
 742:	00000097          	auipc	ra,0x0
 746:	dc6080e7          	jalr	-570(ra) # 508 <putc>
          s++;
 74a:	0485                	addi	s1,s1,1
        while(*s != 0){
 74c:	0004c583          	lbu	a1,0(s1)
 750:	f9e5                	bnez	a1,740 <vprintf+0x168>
        s = va_arg(ap, char*);
 752:	8b4e                	mv	s6,s3
      state = 0;
 754:	4981                	li	s3,0
 756:	b5cd                	j	638 <vprintf+0x60>
          s = "(null)";
 758:	00000497          	auipc	s1,0x0
 75c:	28848493          	addi	s1,s1,648 # 9e0 <digits+0x18>
        while(*s != 0){
 760:	02800593          	li	a1,40
 764:	bff1                	j	740 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 766:	008b0493          	addi	s1,s6,8
 76a:	000b4583          	lbu	a1,0(s6)
 76e:	8556                	mv	a0,s5
 770:	00000097          	auipc	ra,0x0
 774:	d98080e7          	jalr	-616(ra) # 508 <putc>
 778:	8b26                	mv	s6,s1
      state = 0;
 77a:	4981                	li	s3,0
 77c:	bd75                	j	638 <vprintf+0x60>
        putc(fd, c);
 77e:	85d2                	mv	a1,s4
 780:	8556                	mv	a0,s5
 782:	00000097          	auipc	ra,0x0
 786:	d86080e7          	jalr	-634(ra) # 508 <putc>
      state = 0;
 78a:	4981                	li	s3,0
 78c:	b575                	j	638 <vprintf+0x60>
        s = va_arg(ap, char*);
 78e:	8b4e                	mv	s6,s3
      state = 0;
 790:	4981                	li	s3,0
 792:	b55d                	j	638 <vprintf+0x60>
    }
  }
}
 794:	70e6                	ld	ra,120(sp)
 796:	7446                	ld	s0,112(sp)
 798:	74a6                	ld	s1,104(sp)
 79a:	7906                	ld	s2,96(sp)
 79c:	69e6                	ld	s3,88(sp)
 79e:	6a46                	ld	s4,80(sp)
 7a0:	6aa6                	ld	s5,72(sp)
 7a2:	6b06                	ld	s6,64(sp)
 7a4:	7be2                	ld	s7,56(sp)
 7a6:	7c42                	ld	s8,48(sp)
 7a8:	7ca2                	ld	s9,40(sp)
 7aa:	7d02                	ld	s10,32(sp)
 7ac:	6de2                	ld	s11,24(sp)
 7ae:	6109                	addi	sp,sp,128
 7b0:	8082                	ret

00000000000007b2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7b2:	715d                	addi	sp,sp,-80
 7b4:	ec06                	sd	ra,24(sp)
 7b6:	e822                	sd	s0,16(sp)
 7b8:	1000                	addi	s0,sp,32
 7ba:	e010                	sd	a2,0(s0)
 7bc:	e414                	sd	a3,8(s0)
 7be:	e818                	sd	a4,16(s0)
 7c0:	ec1c                	sd	a5,24(s0)
 7c2:	03043023          	sd	a6,32(s0)
 7c6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ca:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ce:	8622                	mv	a2,s0
 7d0:	00000097          	auipc	ra,0x0
 7d4:	e08080e7          	jalr	-504(ra) # 5d8 <vprintf>
}
 7d8:	60e2                	ld	ra,24(sp)
 7da:	6442                	ld	s0,16(sp)
 7dc:	6161                	addi	sp,sp,80
 7de:	8082                	ret

00000000000007e0 <printf>:

void
printf(const char *fmt, ...)
{
 7e0:	711d                	addi	sp,sp,-96
 7e2:	ec06                	sd	ra,24(sp)
 7e4:	e822                	sd	s0,16(sp)
 7e6:	1000                	addi	s0,sp,32
 7e8:	e40c                	sd	a1,8(s0)
 7ea:	e810                	sd	a2,16(s0)
 7ec:	ec14                	sd	a3,24(s0)
 7ee:	f018                	sd	a4,32(s0)
 7f0:	f41c                	sd	a5,40(s0)
 7f2:	03043823          	sd	a6,48(s0)
 7f6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7fa:	00840613          	addi	a2,s0,8
 7fe:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 802:	85aa                	mv	a1,a0
 804:	4505                	li	a0,1
 806:	00000097          	auipc	ra,0x0
 80a:	dd2080e7          	jalr	-558(ra) # 5d8 <vprintf>
}
 80e:	60e2                	ld	ra,24(sp)
 810:	6442                	ld	s0,16(sp)
 812:	6125                	addi	sp,sp,96
 814:	8082                	ret

0000000000000816 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 816:	1141                	addi	sp,sp,-16
 818:	e422                	sd	s0,8(sp)
 81a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 81c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 820:	00000797          	auipc	a5,0x0
 824:	1c878793          	addi	a5,a5,456 # 9e8 <__bss_start>
 828:	639c                	ld	a5,0(a5)
 82a:	a805                	j	85a <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 82c:	4618                	lw	a4,8(a2)
 82e:	9db9                	addw	a1,a1,a4
 830:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 834:	6398                	ld	a4,0(a5)
 836:	6318                	ld	a4,0(a4)
 838:	fee53823          	sd	a4,-16(a0)
 83c:	a091                	j	880 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 83e:	ff852703          	lw	a4,-8(a0)
 842:	9e39                	addw	a2,a2,a4
 844:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 846:	ff053703          	ld	a4,-16(a0)
 84a:	e398                	sd	a4,0(a5)
 84c:	a099                	j	892 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84e:	6398                	ld	a4,0(a5)
 850:	00e7e463          	bltu	a5,a4,858 <free+0x42>
 854:	00e6ea63          	bltu	a3,a4,868 <free+0x52>
{
 858:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85a:	fed7fae3          	bleu	a3,a5,84e <free+0x38>
 85e:	6398                	ld	a4,0(a5)
 860:	00e6e463          	bltu	a3,a4,868 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 864:	fee7eae3          	bltu	a5,a4,858 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 868:	ff852583          	lw	a1,-8(a0)
 86c:	6390                	ld	a2,0(a5)
 86e:	02059713          	slli	a4,a1,0x20
 872:	9301                	srli	a4,a4,0x20
 874:	0712                	slli	a4,a4,0x4
 876:	9736                	add	a4,a4,a3
 878:	fae60ae3          	beq	a2,a4,82c <free+0x16>
    bp->s.ptr = p->s.ptr;
 87c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 880:	4790                	lw	a2,8(a5)
 882:	02061713          	slli	a4,a2,0x20
 886:	9301                	srli	a4,a4,0x20
 888:	0712                	slli	a4,a4,0x4
 88a:	973e                	add	a4,a4,a5
 88c:	fae689e3          	beq	a3,a4,83e <free+0x28>
  } else
    p->s.ptr = bp;
 890:	e394                	sd	a3,0(a5)
  freep = p;
 892:	00000717          	auipc	a4,0x0
 896:	14f73b23          	sd	a5,342(a4) # 9e8 <__bss_start>
}
 89a:	6422                	ld	s0,8(sp)
 89c:	0141                	addi	sp,sp,16
 89e:	8082                	ret

00000000000008a0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8a0:	7139                	addi	sp,sp,-64
 8a2:	fc06                	sd	ra,56(sp)
 8a4:	f822                	sd	s0,48(sp)
 8a6:	f426                	sd	s1,40(sp)
 8a8:	f04a                	sd	s2,32(sp)
 8aa:	ec4e                	sd	s3,24(sp)
 8ac:	e852                	sd	s4,16(sp)
 8ae:	e456                	sd	s5,8(sp)
 8b0:	e05a                	sd	s6,0(sp)
 8b2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b4:	02051993          	slli	s3,a0,0x20
 8b8:	0209d993          	srli	s3,s3,0x20
 8bc:	09bd                	addi	s3,s3,15
 8be:	0049d993          	srli	s3,s3,0x4
 8c2:	2985                	addiw	s3,s3,1
 8c4:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 8c8:	00000797          	auipc	a5,0x0
 8cc:	12078793          	addi	a5,a5,288 # 9e8 <__bss_start>
 8d0:	6388                	ld	a0,0(a5)
 8d2:	c515                	beqz	a0,8fe <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d6:	4798                	lw	a4,8(a5)
 8d8:	03277f63          	bleu	s2,a4,916 <malloc+0x76>
 8dc:	8a4e                	mv	s4,s3
 8de:	0009871b          	sext.w	a4,s3
 8e2:	6685                	lui	a3,0x1
 8e4:	00d77363          	bleu	a3,a4,8ea <malloc+0x4a>
 8e8:	6a05                	lui	s4,0x1
 8ea:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 8ee:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8f2:	00000497          	auipc	s1,0x0
 8f6:	0f648493          	addi	s1,s1,246 # 9e8 <__bss_start>
  if(p == (char*)-1)
 8fa:	5b7d                	li	s6,-1
 8fc:	a885                	j	96c <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 8fe:	00000797          	auipc	a5,0x0
 902:	0f278793          	addi	a5,a5,242 # 9f0 <base>
 906:	00000717          	auipc	a4,0x0
 90a:	0ef73123          	sd	a5,226(a4) # 9e8 <__bss_start>
 90e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 910:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 914:	b7e1                	j	8dc <malloc+0x3c>
      if(p->s.size == nunits)
 916:	02e90b63          	beq	s2,a4,94c <malloc+0xac>
        p->s.size -= nunits;
 91a:	4137073b          	subw	a4,a4,s3
 91e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 920:	1702                	slli	a4,a4,0x20
 922:	9301                	srli	a4,a4,0x20
 924:	0712                	slli	a4,a4,0x4
 926:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 928:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 92c:	00000717          	auipc	a4,0x0
 930:	0aa73e23          	sd	a0,188(a4) # 9e8 <__bss_start>
      return (void*)(p + 1);
 934:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 938:	70e2                	ld	ra,56(sp)
 93a:	7442                	ld	s0,48(sp)
 93c:	74a2                	ld	s1,40(sp)
 93e:	7902                	ld	s2,32(sp)
 940:	69e2                	ld	s3,24(sp)
 942:	6a42                	ld	s4,16(sp)
 944:	6aa2                	ld	s5,8(sp)
 946:	6b02                	ld	s6,0(sp)
 948:	6121                	addi	sp,sp,64
 94a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 94c:	6398                	ld	a4,0(a5)
 94e:	e118                	sd	a4,0(a0)
 950:	bff1                	j	92c <malloc+0x8c>
  hp->s.size = nu;
 952:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 956:	0541                	addi	a0,a0,16
 958:	00000097          	auipc	ra,0x0
 95c:	ebe080e7          	jalr	-322(ra) # 816 <free>
  return freep;
 960:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 962:	d979                	beqz	a0,938 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 964:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 966:	4798                	lw	a4,8(a5)
 968:	fb2777e3          	bleu	s2,a4,916 <malloc+0x76>
    if(p == freep)
 96c:	6098                	ld	a4,0(s1)
 96e:	853e                	mv	a0,a5
 970:	fef71ae3          	bne	a4,a5,964 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 974:	8552                	mv	a0,s4
 976:	00000097          	auipc	ra,0x0
 97a:	b7a080e7          	jalr	-1158(ra) # 4f0 <sbrk>
  if(p == (char*)-1)
 97e:	fd651ae3          	bne	a0,s6,952 <malloc+0xb2>
        return 0;
 982:	4501                	li	a0,0
 984:	bf55                	j	938 <malloc+0x98>
