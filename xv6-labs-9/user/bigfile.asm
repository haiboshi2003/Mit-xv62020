
user/_bigfile：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fcntl.h"
#include "kernel/fs.h"

int
main()
{
   0:	bd010113          	addi	sp,sp,-1072
   4:	42113423          	sd	ra,1064(sp)
   8:	42813023          	sd	s0,1056(sp)
   c:	40913c23          	sd	s1,1048(sp)
  10:	41213823          	sd	s2,1040(sp)
  14:	41313423          	sd	s3,1032(sp)
  18:	41413023          	sd	s4,1024(sp)
  1c:	43010413          	addi	s0,sp,1072
  char buf[BSIZE];
  int fd, i, blocks;

  fd = open("big.file", O_CREATE | O_WRONLY);
  20:	20100593          	li	a1,513
  24:	00001517          	auipc	a0,0x1
  28:	91c50513          	addi	a0,a0,-1764 # 940 <malloc+0xe8>
  2c:	00000097          	auipc	ra,0x0
  30:	42c080e7          	jalr	1068(ra) # 458 <open>
  if(fd < 0){
  34:	00054b63          	bltz	a0,4a <main+0x4a>
  38:	892a                	mv	s2,a0
  3a:	4481                	li	s1,0
    *(int*)buf = blocks;
    int cc = write(fd, buf, sizeof(buf));
    if(cc <= 0)
      break;
    blocks++;
    if (blocks % 100 == 0)
  3c:	06400993          	li	s3,100
      printf(".");
  40:	00001a17          	auipc	s4,0x1
  44:	940a0a13          	addi	s4,s4,-1728 # 980 <malloc+0x128>
  48:	a01d                	j	6e <main+0x6e>
    printf("bigfile: cannot open big.file for writing\n");
  4a:	00001517          	auipc	a0,0x1
  4e:	90650513          	addi	a0,a0,-1786 # 950 <malloc+0xf8>
  52:	00000097          	auipc	ra,0x0
  56:	746080e7          	jalr	1862(ra) # 798 <printf>
    exit(-1);
  5a:	557d                	li	a0,-1
  5c:	00000097          	auipc	ra,0x0
  60:	3bc080e7          	jalr	956(ra) # 418 <exit>
      printf(".");
  64:	8552                	mv	a0,s4
  66:	00000097          	auipc	ra,0x0
  6a:	732080e7          	jalr	1842(ra) # 798 <printf>
    *(int*)buf = blocks;
  6e:	bc942823          	sw	s1,-1072(s0)
    int cc = write(fd, buf, sizeof(buf));
  72:	40000613          	li	a2,1024
  76:	bd040593          	addi	a1,s0,-1072
  7a:	854a                	mv	a0,s2
  7c:	00000097          	auipc	ra,0x0
  80:	3bc080e7          	jalr	956(ra) # 438 <write>
    if(cc <= 0)
  84:	00a05a63          	blez	a0,98 <main+0x98>
    blocks++;
  88:	0014879b          	addiw	a5,s1,1
  8c:	0007849b          	sext.w	s1,a5
    if (blocks % 100 == 0)
  90:	0337e7bb          	remw	a5,a5,s3
  94:	ffe9                	bnez	a5,6e <main+0x6e>
  96:	b7f9                	j	64 <main+0x64>
  }

  printf("\nwrote %d blocks\n", blocks);
  98:	85a6                	mv	a1,s1
  9a:	00001517          	auipc	a0,0x1
  9e:	8ee50513          	addi	a0,a0,-1810 # 988 <malloc+0x130>
  a2:	00000097          	auipc	ra,0x0
  a6:	6f6080e7          	jalr	1782(ra) # 798 <printf>
  if(blocks != 65803) {
  aa:	67c1                	lui	a5,0x10
  ac:	10b78793          	addi	a5,a5,267 # 1010b <__global_pointer$+0xee8b>
  b0:	00f48f63          	beq	s1,a5,ce <main+0xce>
    printf("bigfile: file is too small\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	8ec50513          	addi	a0,a0,-1812 # 9a0 <malloc+0x148>
  bc:	00000097          	auipc	ra,0x0
  c0:	6dc080e7          	jalr	1756(ra) # 798 <printf>
    exit(-1);
  c4:	557d                	li	a0,-1
  c6:	00000097          	auipc	ra,0x0
  ca:	352080e7          	jalr	850(ra) # 418 <exit>
  }
  
  close(fd);
  ce:	854a                	mv	a0,s2
  d0:	00000097          	auipc	ra,0x0
  d4:	370080e7          	jalr	880(ra) # 440 <close>
  fd = open("big.file", O_RDONLY);
  d8:	4581                	li	a1,0
  da:	00001517          	auipc	a0,0x1
  de:	86650513          	addi	a0,a0,-1946 # 940 <malloc+0xe8>
  e2:	00000097          	auipc	ra,0x0
  e6:	376080e7          	jalr	886(ra) # 458 <open>
  ea:	892a                	mv	s2,a0
  if(fd < 0){
    printf("bigfile: cannot re-open big.file for reading\n");
    exit(-1);
  }
  for(i = 0; i < blocks; i++){
  ec:	4481                	li	s1,0
  if(fd < 0){
  ee:	04054463          	bltz	a0,136 <main+0x136>
  for(i = 0; i < blocks; i++){
  f2:	69c1                	lui	s3,0x10
  f4:	10b98993          	addi	s3,s3,267 # 1010b <__global_pointer$+0xee8b>
    int cc = read(fd, buf, sizeof(buf));
  f8:	40000613          	li	a2,1024
  fc:	bd040593          	addi	a1,s0,-1072
 100:	854a                	mv	a0,s2
 102:	00000097          	auipc	ra,0x0
 106:	32e080e7          	jalr	814(ra) # 430 <read>
    if(cc <= 0){
 10a:	04a05363          	blez	a0,150 <main+0x150>
      printf("bigfile: read error at block %d\n", i);
      exit(-1);
    }
    if(*(int*)buf != i){
 10e:	bd042583          	lw	a1,-1072(s0)
 112:	04959d63          	bne	a1,s1,16c <main+0x16c>
  for(i = 0; i < blocks; i++){
 116:	2485                	addiw	s1,s1,1
 118:	ff3490e3          	bne	s1,s3,f8 <main+0xf8>
             *(int*)buf, i);
      exit(-1);
    }
  }

  printf("bigfile done; ok\n"); 
 11c:	00001517          	auipc	a0,0x1
 120:	92c50513          	addi	a0,a0,-1748 # a48 <malloc+0x1f0>
 124:	00000097          	auipc	ra,0x0
 128:	674080e7          	jalr	1652(ra) # 798 <printf>

  exit(0);
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	2ea080e7          	jalr	746(ra) # 418 <exit>
    printf("bigfile: cannot re-open big.file for reading\n");
 136:	00001517          	auipc	a0,0x1
 13a:	88a50513          	addi	a0,a0,-1910 # 9c0 <malloc+0x168>
 13e:	00000097          	auipc	ra,0x0
 142:	65a080e7          	jalr	1626(ra) # 798 <printf>
    exit(-1);
 146:	557d                	li	a0,-1
 148:	00000097          	auipc	ra,0x0
 14c:	2d0080e7          	jalr	720(ra) # 418 <exit>
      printf("bigfile: read error at block %d\n", i);
 150:	85a6                	mv	a1,s1
 152:	00001517          	auipc	a0,0x1
 156:	89e50513          	addi	a0,a0,-1890 # 9f0 <malloc+0x198>
 15a:	00000097          	auipc	ra,0x0
 15e:	63e080e7          	jalr	1598(ra) # 798 <printf>
      exit(-1);
 162:	557d                	li	a0,-1
 164:	00000097          	auipc	ra,0x0
 168:	2b4080e7          	jalr	692(ra) # 418 <exit>
      printf("bigfile: read the wrong data (%d) for block %d\n",
 16c:	8626                	mv	a2,s1
 16e:	00001517          	auipc	a0,0x1
 172:	8aa50513          	addi	a0,a0,-1878 # a18 <malloc+0x1c0>
 176:	00000097          	auipc	ra,0x0
 17a:	622080e7          	jalr	1570(ra) # 798 <printf>
      exit(-1);
 17e:	557d                	li	a0,-1
 180:	00000097          	auipc	ra,0x0
 184:	298080e7          	jalr	664(ra) # 418 <exit>

0000000000000188 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 18e:	87aa                	mv	a5,a0
 190:	0585                	addi	a1,a1,1
 192:	0785                	addi	a5,a5,1
 194:	fff5c703          	lbu	a4,-1(a1)
 198:	fee78fa3          	sb	a4,-1(a5)
 19c:	fb75                	bnez	a4,190 <strcpy+0x8>
    ;
  return os;
}
 19e:	6422                	ld	s0,8(sp)
 1a0:	0141                	addi	sp,sp,16
 1a2:	8082                	ret

00000000000001a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1aa:	00054783          	lbu	a5,0(a0)
 1ae:	cf91                	beqz	a5,1ca <strcmp+0x26>
 1b0:	0005c703          	lbu	a4,0(a1)
 1b4:	00f71b63          	bne	a4,a5,1ca <strcmp+0x26>
    p++, q++;
 1b8:	0505                	addi	a0,a0,1
 1ba:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	c789                	beqz	a5,1ca <strcmp+0x26>
 1c2:	0005c703          	lbu	a4,0(a1)
 1c6:	fef709e3          	beq	a4,a5,1b8 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 1ca:	0005c503          	lbu	a0,0(a1)
}
 1ce:	40a7853b          	subw	a0,a5,a0
 1d2:	6422                	ld	s0,8(sp)
 1d4:	0141                	addi	sp,sp,16
 1d6:	8082                	ret

00000000000001d8 <strlen>:

uint
strlen(const char *s)
{
 1d8:	1141                	addi	sp,sp,-16
 1da:	e422                	sd	s0,8(sp)
 1dc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1de:	00054783          	lbu	a5,0(a0)
 1e2:	cf91                	beqz	a5,1fe <strlen+0x26>
 1e4:	0505                	addi	a0,a0,1
 1e6:	87aa                	mv	a5,a0
 1e8:	4685                	li	a3,1
 1ea:	9e89                	subw	a3,a3,a0
 1ec:	00f6853b          	addw	a0,a3,a5
 1f0:	0785                	addi	a5,a5,1
 1f2:	fff7c703          	lbu	a4,-1(a5)
 1f6:	fb7d                	bnez	a4,1ec <strlen+0x14>
    ;
  return n;
}
 1f8:	6422                	ld	s0,8(sp)
 1fa:	0141                	addi	sp,sp,16
 1fc:	8082                	ret
  for(n = 0; s[n]; n++)
 1fe:	4501                	li	a0,0
 200:	bfe5                	j	1f8 <strlen+0x20>

0000000000000202 <memset>:

void*
memset(void *dst, int c, uint n)
{
 202:	1141                	addi	sp,sp,-16
 204:	e422                	sd	s0,8(sp)
 206:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 208:	ce09                	beqz	a2,222 <memset+0x20>
 20a:	87aa                	mv	a5,a0
 20c:	fff6071b          	addiw	a4,a2,-1
 210:	1702                	slli	a4,a4,0x20
 212:	9301                	srli	a4,a4,0x20
 214:	0705                	addi	a4,a4,1
 216:	972a                	add	a4,a4,a0
    cdst[i] = c;
 218:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 21c:	0785                	addi	a5,a5,1
 21e:	fee79de3          	bne	a5,a4,218 <memset+0x16>
  }
  return dst;
}
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret

0000000000000228 <strchr>:

char*
strchr(const char *s, char c)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e422                	sd	s0,8(sp)
 22c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 22e:	00054783          	lbu	a5,0(a0)
 232:	cf91                	beqz	a5,24e <strchr+0x26>
    if(*s == c)
 234:	00f58a63          	beq	a1,a5,248 <strchr+0x20>
  for(; *s; s++)
 238:	0505                	addi	a0,a0,1
 23a:	00054783          	lbu	a5,0(a0)
 23e:	c781                	beqz	a5,246 <strchr+0x1e>
    if(*s == c)
 240:	feb79ce3          	bne	a5,a1,238 <strchr+0x10>
 244:	a011                	j	248 <strchr+0x20>
      return (char*)s;
  return 0;
 246:	4501                	li	a0,0
}
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret
  return 0;
 24e:	4501                	li	a0,0
 250:	bfe5                	j	248 <strchr+0x20>

0000000000000252 <gets>:

char*
gets(char *buf, int max)
{
 252:	711d                	addi	sp,sp,-96
 254:	ec86                	sd	ra,88(sp)
 256:	e8a2                	sd	s0,80(sp)
 258:	e4a6                	sd	s1,72(sp)
 25a:	e0ca                	sd	s2,64(sp)
 25c:	fc4e                	sd	s3,56(sp)
 25e:	f852                	sd	s4,48(sp)
 260:	f456                	sd	s5,40(sp)
 262:	f05a                	sd	s6,32(sp)
 264:	ec5e                	sd	s7,24(sp)
 266:	1080                	addi	s0,sp,96
 268:	8baa                	mv	s7,a0
 26a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26c:	892a                	mv	s2,a0
 26e:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 270:	4aa9                	li	s5,10
 272:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 274:	0019849b          	addiw	s1,s3,1
 278:	0344d863          	ble	s4,s1,2a8 <gets+0x56>
    cc = read(0, &c, 1);
 27c:	4605                	li	a2,1
 27e:	faf40593          	addi	a1,s0,-81
 282:	4501                	li	a0,0
 284:	00000097          	auipc	ra,0x0
 288:	1ac080e7          	jalr	428(ra) # 430 <read>
    if(cc < 1)
 28c:	00a05e63          	blez	a0,2a8 <gets+0x56>
    buf[i++] = c;
 290:	faf44783          	lbu	a5,-81(s0)
 294:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 298:	01578763          	beq	a5,s5,2a6 <gets+0x54>
 29c:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 29e:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 2a0:	fd679ae3          	bne	a5,s6,274 <gets+0x22>
 2a4:	a011                	j	2a8 <gets+0x56>
  for(i=0; i+1 < max; ){
 2a6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2a8:	99de                	add	s3,s3,s7
 2aa:	00098023          	sb	zero,0(s3)
  return buf;
}
 2ae:	855e                	mv	a0,s7
 2b0:	60e6                	ld	ra,88(sp)
 2b2:	6446                	ld	s0,80(sp)
 2b4:	64a6                	ld	s1,72(sp)
 2b6:	6906                	ld	s2,64(sp)
 2b8:	79e2                	ld	s3,56(sp)
 2ba:	7a42                	ld	s4,48(sp)
 2bc:	7aa2                	ld	s5,40(sp)
 2be:	7b02                	ld	s6,32(sp)
 2c0:	6be2                	ld	s7,24(sp)
 2c2:	6125                	addi	sp,sp,96
 2c4:	8082                	ret

00000000000002c6 <stat>:

int
stat(const char *n, struct stat *st)
{
 2c6:	1101                	addi	sp,sp,-32
 2c8:	ec06                	sd	ra,24(sp)
 2ca:	e822                	sd	s0,16(sp)
 2cc:	e426                	sd	s1,8(sp)
 2ce:	e04a                	sd	s2,0(sp)
 2d0:	1000                	addi	s0,sp,32
 2d2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2d4:	4581                	li	a1,0
 2d6:	00000097          	auipc	ra,0x0
 2da:	182080e7          	jalr	386(ra) # 458 <open>
  if(fd < 0)
 2de:	02054563          	bltz	a0,308 <stat+0x42>
 2e2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2e4:	85ca                	mv	a1,s2
 2e6:	00000097          	auipc	ra,0x0
 2ea:	18a080e7          	jalr	394(ra) # 470 <fstat>
 2ee:	892a                	mv	s2,a0
  close(fd);
 2f0:	8526                	mv	a0,s1
 2f2:	00000097          	auipc	ra,0x0
 2f6:	14e080e7          	jalr	334(ra) # 440 <close>
  return r;
}
 2fa:	854a                	mv	a0,s2
 2fc:	60e2                	ld	ra,24(sp)
 2fe:	6442                	ld	s0,16(sp)
 300:	64a2                	ld	s1,8(sp)
 302:	6902                	ld	s2,0(sp)
 304:	6105                	addi	sp,sp,32
 306:	8082                	ret
    return -1;
 308:	597d                	li	s2,-1
 30a:	bfc5                	j	2fa <stat+0x34>

000000000000030c <atoi>:

int
atoi(const char *s)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 312:	00054683          	lbu	a3,0(a0)
 316:	fd06879b          	addiw	a5,a3,-48
 31a:	0ff7f793          	andi	a5,a5,255
 31e:	4725                	li	a4,9
 320:	02f76963          	bltu	a4,a5,352 <atoi+0x46>
 324:	862a                	mv	a2,a0
  n = 0;
 326:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 328:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 32a:	0605                	addi	a2,a2,1
 32c:	0025179b          	slliw	a5,a0,0x2
 330:	9fa9                	addw	a5,a5,a0
 332:	0017979b          	slliw	a5,a5,0x1
 336:	9fb5                	addw	a5,a5,a3
 338:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 33c:	00064683          	lbu	a3,0(a2)
 340:	fd06871b          	addiw	a4,a3,-48
 344:	0ff77713          	andi	a4,a4,255
 348:	fee5f1e3          	bleu	a4,a1,32a <atoi+0x1e>
  return n;
}
 34c:	6422                	ld	s0,8(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret
  n = 0;
 352:	4501                	li	a0,0
 354:	bfe5                	j	34c <atoi+0x40>

0000000000000356 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 356:	1141                	addi	sp,sp,-16
 358:	e422                	sd	s0,8(sp)
 35a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 35c:	02b57663          	bleu	a1,a0,388 <memmove+0x32>
    while(n-- > 0)
 360:	02c05163          	blez	a2,382 <memmove+0x2c>
 364:	fff6079b          	addiw	a5,a2,-1
 368:	1782                	slli	a5,a5,0x20
 36a:	9381                	srli	a5,a5,0x20
 36c:	0785                	addi	a5,a5,1
 36e:	97aa                	add	a5,a5,a0
  dst = vdst;
 370:	872a                	mv	a4,a0
      *dst++ = *src++;
 372:	0585                	addi	a1,a1,1
 374:	0705                	addi	a4,a4,1
 376:	fff5c683          	lbu	a3,-1(a1)
 37a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 37e:	fee79ae3          	bne	a5,a4,372 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 382:	6422                	ld	s0,8(sp)
 384:	0141                	addi	sp,sp,16
 386:	8082                	ret
    dst += n;
 388:	00c50733          	add	a4,a0,a2
    src += n;
 38c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 38e:	fec05ae3          	blez	a2,382 <memmove+0x2c>
 392:	fff6079b          	addiw	a5,a2,-1
 396:	1782                	slli	a5,a5,0x20
 398:	9381                	srli	a5,a5,0x20
 39a:	fff7c793          	not	a5,a5
 39e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3a0:	15fd                	addi	a1,a1,-1
 3a2:	177d                	addi	a4,a4,-1
 3a4:	0005c683          	lbu	a3,0(a1)
 3a8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3ac:	fef71ae3          	bne	a4,a5,3a0 <memmove+0x4a>
 3b0:	bfc9                	j	382 <memmove+0x2c>

00000000000003b2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3b2:	1141                	addi	sp,sp,-16
 3b4:	e422                	sd	s0,8(sp)
 3b6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3b8:	ce15                	beqz	a2,3f4 <memcmp+0x42>
 3ba:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 3be:	00054783          	lbu	a5,0(a0)
 3c2:	0005c703          	lbu	a4,0(a1)
 3c6:	02e79063          	bne	a5,a4,3e6 <memcmp+0x34>
 3ca:	1682                	slli	a3,a3,0x20
 3cc:	9281                	srli	a3,a3,0x20
 3ce:	0685                	addi	a3,a3,1
 3d0:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 3d2:	0505                	addi	a0,a0,1
    p2++;
 3d4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3d6:	00d50d63          	beq	a0,a3,3f0 <memcmp+0x3e>
    if (*p1 != *p2) {
 3da:	00054783          	lbu	a5,0(a0)
 3de:	0005c703          	lbu	a4,0(a1)
 3e2:	fee788e3          	beq	a5,a4,3d2 <memcmp+0x20>
      return *p1 - *p2;
 3e6:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 3ea:	6422                	ld	s0,8(sp)
 3ec:	0141                	addi	sp,sp,16
 3ee:	8082                	ret
  return 0;
 3f0:	4501                	li	a0,0
 3f2:	bfe5                	j	3ea <memcmp+0x38>
 3f4:	4501                	li	a0,0
 3f6:	bfd5                	j	3ea <memcmp+0x38>

00000000000003f8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3f8:	1141                	addi	sp,sp,-16
 3fa:	e406                	sd	ra,8(sp)
 3fc:	e022                	sd	s0,0(sp)
 3fe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 400:	00000097          	auipc	ra,0x0
 404:	f56080e7          	jalr	-170(ra) # 356 <memmove>
}
 408:	60a2                	ld	ra,8(sp)
 40a:	6402                	ld	s0,0(sp)
 40c:	0141                	addi	sp,sp,16
 40e:	8082                	ret

0000000000000410 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 410:	4885                	li	a7,1
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <exit>:
.global exit
exit:
 li a7, SYS_exit
 418:	4889                	li	a7,2
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <wait>:
.global wait
wait:
 li a7, SYS_wait
 420:	488d                	li	a7,3
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 428:	4891                	li	a7,4
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <read>:
.global read
read:
 li a7, SYS_read
 430:	4895                	li	a7,5
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <write>:
.global write
write:
 li a7, SYS_write
 438:	48c1                	li	a7,16
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <close>:
.global close
close:
 li a7, SYS_close
 440:	48d5                	li	a7,21
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <kill>:
.global kill
kill:
 li a7, SYS_kill
 448:	4899                	li	a7,6
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <exec>:
.global exec
exec:
 li a7, SYS_exec
 450:	489d                	li	a7,7
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <open>:
.global open
open:
 li a7, SYS_open
 458:	48bd                	li	a7,15
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 460:	48c5                	li	a7,17
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 468:	48c9                	li	a7,18
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 470:	48a1                	li	a7,8
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <link>:
.global link
link:
 li a7, SYS_link
 478:	48cd                	li	a7,19
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 480:	48d1                	li	a7,20
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 488:	48a5                	li	a7,9
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <dup>:
.global dup
dup:
 li a7, SYS_dup
 490:	48a9                	li	a7,10
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 498:	48ad                	li	a7,11
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4a0:	48b1                	li	a7,12
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4a8:	48b5                	li	a7,13
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4b0:	48b9                	li	a7,14
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <symlink>:
.global symlink
symlink:
 li a7, SYS_symlink
 4b8:	48d9                	li	a7,22
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4c0:	1101                	addi	sp,sp,-32
 4c2:	ec06                	sd	ra,24(sp)
 4c4:	e822                	sd	s0,16(sp)
 4c6:	1000                	addi	s0,sp,32
 4c8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4cc:	4605                	li	a2,1
 4ce:	fef40593          	addi	a1,s0,-17
 4d2:	00000097          	auipc	ra,0x0
 4d6:	f66080e7          	jalr	-154(ra) # 438 <write>
}
 4da:	60e2                	ld	ra,24(sp)
 4dc:	6442                	ld	s0,16(sp)
 4de:	6105                	addi	sp,sp,32
 4e0:	8082                	ret

00000000000004e2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4e2:	7139                	addi	sp,sp,-64
 4e4:	fc06                	sd	ra,56(sp)
 4e6:	f822                	sd	s0,48(sp)
 4e8:	f426                	sd	s1,40(sp)
 4ea:	f04a                	sd	s2,32(sp)
 4ec:	ec4e                	sd	s3,24(sp)
 4ee:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4f0:	c299                	beqz	a3,4f6 <printint+0x14>
 4f2:	0005cd63          	bltz	a1,50c <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4f6:	2581                	sext.w	a1,a1
  neg = 0;
 4f8:	4301                	li	t1,0
 4fa:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 4fe:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 500:	2601                	sext.w	a2,a2
 502:	00000897          	auipc	a7,0x0
 506:	55e88893          	addi	a7,a7,1374 # a60 <digits>
 50a:	a801                	j	51a <printint+0x38>
    x = -xx;
 50c:	40b005bb          	negw	a1,a1
 510:	2581                	sext.w	a1,a1
    neg = 1;
 512:	4305                	li	t1,1
    x = -xx;
 514:	b7dd                	j	4fa <printint+0x18>
  }while((x /= base) != 0);
 516:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 518:	8836                	mv	a6,a3
 51a:	0018069b          	addiw	a3,a6,1
 51e:	02c5f7bb          	remuw	a5,a1,a2
 522:	1782                	slli	a5,a5,0x20
 524:	9381                	srli	a5,a5,0x20
 526:	97c6                	add	a5,a5,a7
 528:	0007c783          	lbu	a5,0(a5)
 52c:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 530:	0705                	addi	a4,a4,1
 532:	02c5d7bb          	divuw	a5,a1,a2
 536:	fec5f0e3          	bleu	a2,a1,516 <printint+0x34>
  if(neg)
 53a:	00030b63          	beqz	t1,550 <printint+0x6e>
    buf[i++] = '-';
 53e:	fd040793          	addi	a5,s0,-48
 542:	96be                	add	a3,a3,a5
 544:	02d00793          	li	a5,45
 548:	fef68823          	sb	a5,-16(a3)
 54c:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 550:	02d05963          	blez	a3,582 <printint+0xa0>
 554:	89aa                	mv	s3,a0
 556:	fc040793          	addi	a5,s0,-64
 55a:	00d784b3          	add	s1,a5,a3
 55e:	fff78913          	addi	s2,a5,-1
 562:	9936                	add	s2,s2,a3
 564:	36fd                	addiw	a3,a3,-1
 566:	1682                	slli	a3,a3,0x20
 568:	9281                	srli	a3,a3,0x20
 56a:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 56e:	fff4c583          	lbu	a1,-1(s1)
 572:	854e                	mv	a0,s3
 574:	00000097          	auipc	ra,0x0
 578:	f4c080e7          	jalr	-180(ra) # 4c0 <putc>
  while(--i >= 0)
 57c:	14fd                	addi	s1,s1,-1
 57e:	ff2498e3          	bne	s1,s2,56e <printint+0x8c>
}
 582:	70e2                	ld	ra,56(sp)
 584:	7442                	ld	s0,48(sp)
 586:	74a2                	ld	s1,40(sp)
 588:	7902                	ld	s2,32(sp)
 58a:	69e2                	ld	s3,24(sp)
 58c:	6121                	addi	sp,sp,64
 58e:	8082                	ret

0000000000000590 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 590:	7119                	addi	sp,sp,-128
 592:	fc86                	sd	ra,120(sp)
 594:	f8a2                	sd	s0,112(sp)
 596:	f4a6                	sd	s1,104(sp)
 598:	f0ca                	sd	s2,96(sp)
 59a:	ecce                	sd	s3,88(sp)
 59c:	e8d2                	sd	s4,80(sp)
 59e:	e4d6                	sd	s5,72(sp)
 5a0:	e0da                	sd	s6,64(sp)
 5a2:	fc5e                	sd	s7,56(sp)
 5a4:	f862                	sd	s8,48(sp)
 5a6:	f466                	sd	s9,40(sp)
 5a8:	f06a                	sd	s10,32(sp)
 5aa:	ec6e                	sd	s11,24(sp)
 5ac:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5ae:	0005c483          	lbu	s1,0(a1)
 5b2:	18048d63          	beqz	s1,74c <vprintf+0x1bc>
 5b6:	8aaa                	mv	s5,a0
 5b8:	8b32                	mv	s6,a2
 5ba:	00158913          	addi	s2,a1,1
  state = 0;
 5be:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5c0:	02500a13          	li	s4,37
      if(c == 'd'){
 5c4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5c8:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5cc:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5d0:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5d4:	00000b97          	auipc	s7,0x0
 5d8:	48cb8b93          	addi	s7,s7,1164 # a60 <digits>
 5dc:	a839                	j	5fa <vprintf+0x6a>
        putc(fd, c);
 5de:	85a6                	mv	a1,s1
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	ede080e7          	jalr	-290(ra) # 4c0 <putc>
 5ea:	a019                	j	5f0 <vprintf+0x60>
    } else if(state == '%'){
 5ec:	01498f63          	beq	s3,s4,60a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5f0:	0905                	addi	s2,s2,1
 5f2:	fff94483          	lbu	s1,-1(s2)
 5f6:	14048b63          	beqz	s1,74c <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 5fa:	0004879b          	sext.w	a5,s1
    if(state == 0){
 5fe:	fe0997e3          	bnez	s3,5ec <vprintf+0x5c>
      if(c == '%'){
 602:	fd479ee3          	bne	a5,s4,5de <vprintf+0x4e>
        state = '%';
 606:	89be                	mv	s3,a5
 608:	b7e5                	j	5f0 <vprintf+0x60>
      if(c == 'd'){
 60a:	05878063          	beq	a5,s8,64a <vprintf+0xba>
      } else if(c == 'l') {
 60e:	05978c63          	beq	a5,s9,666 <vprintf+0xd6>
      } else if(c == 'x') {
 612:	07a78863          	beq	a5,s10,682 <vprintf+0xf2>
      } else if(c == 'p') {
 616:	09b78463          	beq	a5,s11,69e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 61a:	07300713          	li	a4,115
 61e:	0ce78563          	beq	a5,a4,6e8 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 622:	06300713          	li	a4,99
 626:	0ee78c63          	beq	a5,a4,71e <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 62a:	11478663          	beq	a5,s4,736 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 62e:	85d2                	mv	a1,s4
 630:	8556                	mv	a0,s5
 632:	00000097          	auipc	ra,0x0
 636:	e8e080e7          	jalr	-370(ra) # 4c0 <putc>
        putc(fd, c);
 63a:	85a6                	mv	a1,s1
 63c:	8556                	mv	a0,s5
 63e:	00000097          	auipc	ra,0x0
 642:	e82080e7          	jalr	-382(ra) # 4c0 <putc>
      }
      state = 0;
 646:	4981                	li	s3,0
 648:	b765                	j	5f0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 64a:	008b0493          	addi	s1,s6,8
 64e:	4685                	li	a3,1
 650:	4629                	li	a2,10
 652:	000b2583          	lw	a1,0(s6)
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	e8a080e7          	jalr	-374(ra) # 4e2 <printint>
 660:	8b26                	mv	s6,s1
      state = 0;
 662:	4981                	li	s3,0
 664:	b771                	j	5f0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 666:	008b0493          	addi	s1,s6,8
 66a:	4681                	li	a3,0
 66c:	4629                	li	a2,10
 66e:	000b2583          	lw	a1,0(s6)
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	e6e080e7          	jalr	-402(ra) # 4e2 <printint>
 67c:	8b26                	mv	s6,s1
      state = 0;
 67e:	4981                	li	s3,0
 680:	bf85                	j	5f0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 682:	008b0493          	addi	s1,s6,8
 686:	4681                	li	a3,0
 688:	4641                	li	a2,16
 68a:	000b2583          	lw	a1,0(s6)
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	e52080e7          	jalr	-430(ra) # 4e2 <printint>
 698:	8b26                	mv	s6,s1
      state = 0;
 69a:	4981                	li	s3,0
 69c:	bf91                	j	5f0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 69e:	008b0793          	addi	a5,s6,8
 6a2:	f8f43423          	sd	a5,-120(s0)
 6a6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6aa:	03000593          	li	a1,48
 6ae:	8556                	mv	a0,s5
 6b0:	00000097          	auipc	ra,0x0
 6b4:	e10080e7          	jalr	-496(ra) # 4c0 <putc>
  putc(fd, 'x');
 6b8:	85ea                	mv	a1,s10
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	e04080e7          	jalr	-508(ra) # 4c0 <putc>
 6c4:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6c6:	03c9d793          	srli	a5,s3,0x3c
 6ca:	97de                	add	a5,a5,s7
 6cc:	0007c583          	lbu	a1,0(a5)
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	dee080e7          	jalr	-530(ra) # 4c0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6da:	0992                	slli	s3,s3,0x4
 6dc:	34fd                	addiw	s1,s1,-1
 6de:	f4e5                	bnez	s1,6c6 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6e0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	b729                	j	5f0 <vprintf+0x60>
        s = va_arg(ap, char*);
 6e8:	008b0993          	addi	s3,s6,8
 6ec:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 6f0:	c085                	beqz	s1,710 <vprintf+0x180>
        while(*s != 0){
 6f2:	0004c583          	lbu	a1,0(s1)
 6f6:	c9a1                	beqz	a1,746 <vprintf+0x1b6>
          putc(fd, *s);
 6f8:	8556                	mv	a0,s5
 6fa:	00000097          	auipc	ra,0x0
 6fe:	dc6080e7          	jalr	-570(ra) # 4c0 <putc>
          s++;
 702:	0485                	addi	s1,s1,1
        while(*s != 0){
 704:	0004c583          	lbu	a1,0(s1)
 708:	f9e5                	bnez	a1,6f8 <vprintf+0x168>
        s = va_arg(ap, char*);
 70a:	8b4e                	mv	s6,s3
      state = 0;
 70c:	4981                	li	s3,0
 70e:	b5cd                	j	5f0 <vprintf+0x60>
          s = "(null)";
 710:	00000497          	auipc	s1,0x0
 714:	36848493          	addi	s1,s1,872 # a78 <digits+0x18>
        while(*s != 0){
 718:	02800593          	li	a1,40
 71c:	bff1                	j	6f8 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 71e:	008b0493          	addi	s1,s6,8
 722:	000b4583          	lbu	a1,0(s6)
 726:	8556                	mv	a0,s5
 728:	00000097          	auipc	ra,0x0
 72c:	d98080e7          	jalr	-616(ra) # 4c0 <putc>
 730:	8b26                	mv	s6,s1
      state = 0;
 732:	4981                	li	s3,0
 734:	bd75                	j	5f0 <vprintf+0x60>
        putc(fd, c);
 736:	85d2                	mv	a1,s4
 738:	8556                	mv	a0,s5
 73a:	00000097          	auipc	ra,0x0
 73e:	d86080e7          	jalr	-634(ra) # 4c0 <putc>
      state = 0;
 742:	4981                	li	s3,0
 744:	b575                	j	5f0 <vprintf+0x60>
        s = va_arg(ap, char*);
 746:	8b4e                	mv	s6,s3
      state = 0;
 748:	4981                	li	s3,0
 74a:	b55d                	j	5f0 <vprintf+0x60>
    }
  }
}
 74c:	70e6                	ld	ra,120(sp)
 74e:	7446                	ld	s0,112(sp)
 750:	74a6                	ld	s1,104(sp)
 752:	7906                	ld	s2,96(sp)
 754:	69e6                	ld	s3,88(sp)
 756:	6a46                	ld	s4,80(sp)
 758:	6aa6                	ld	s5,72(sp)
 75a:	6b06                	ld	s6,64(sp)
 75c:	7be2                	ld	s7,56(sp)
 75e:	7c42                	ld	s8,48(sp)
 760:	7ca2                	ld	s9,40(sp)
 762:	7d02                	ld	s10,32(sp)
 764:	6de2                	ld	s11,24(sp)
 766:	6109                	addi	sp,sp,128
 768:	8082                	ret

000000000000076a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 76a:	715d                	addi	sp,sp,-80
 76c:	ec06                	sd	ra,24(sp)
 76e:	e822                	sd	s0,16(sp)
 770:	1000                	addi	s0,sp,32
 772:	e010                	sd	a2,0(s0)
 774:	e414                	sd	a3,8(s0)
 776:	e818                	sd	a4,16(s0)
 778:	ec1c                	sd	a5,24(s0)
 77a:	03043023          	sd	a6,32(s0)
 77e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 782:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 786:	8622                	mv	a2,s0
 788:	00000097          	auipc	ra,0x0
 78c:	e08080e7          	jalr	-504(ra) # 590 <vprintf>
}
 790:	60e2                	ld	ra,24(sp)
 792:	6442                	ld	s0,16(sp)
 794:	6161                	addi	sp,sp,80
 796:	8082                	ret

0000000000000798 <printf>:

void
printf(const char *fmt, ...)
{
 798:	711d                	addi	sp,sp,-96
 79a:	ec06                	sd	ra,24(sp)
 79c:	e822                	sd	s0,16(sp)
 79e:	1000                	addi	s0,sp,32
 7a0:	e40c                	sd	a1,8(s0)
 7a2:	e810                	sd	a2,16(s0)
 7a4:	ec14                	sd	a3,24(s0)
 7a6:	f018                	sd	a4,32(s0)
 7a8:	f41c                	sd	a5,40(s0)
 7aa:	03043823          	sd	a6,48(s0)
 7ae:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7b2:	00840613          	addi	a2,s0,8
 7b6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ba:	85aa                	mv	a1,a0
 7bc:	4505                	li	a0,1
 7be:	00000097          	auipc	ra,0x0
 7c2:	dd2080e7          	jalr	-558(ra) # 590 <vprintf>
}
 7c6:	60e2                	ld	ra,24(sp)
 7c8:	6442                	ld	s0,16(sp)
 7ca:	6125                	addi	sp,sp,96
 7cc:	8082                	ret

00000000000007ce <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ce:	1141                	addi	sp,sp,-16
 7d0:	e422                	sd	s0,8(sp)
 7d2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d8:	00000797          	auipc	a5,0x0
 7dc:	2a878793          	addi	a5,a5,680 # a80 <__bss_start>
 7e0:	639c                	ld	a5,0(a5)
 7e2:	a805                	j	812 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7e4:	4618                	lw	a4,8(a2)
 7e6:	9db9                	addw	a1,a1,a4
 7e8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ec:	6398                	ld	a4,0(a5)
 7ee:	6318                	ld	a4,0(a4)
 7f0:	fee53823          	sd	a4,-16(a0)
 7f4:	a091                	j	838 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7f6:	ff852703          	lw	a4,-8(a0)
 7fa:	9e39                	addw	a2,a2,a4
 7fc:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7fe:	ff053703          	ld	a4,-16(a0)
 802:	e398                	sd	a4,0(a5)
 804:	a099                	j	84a <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 806:	6398                	ld	a4,0(a5)
 808:	00e7e463          	bltu	a5,a4,810 <free+0x42>
 80c:	00e6ea63          	bltu	a3,a4,820 <free+0x52>
{
 810:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 812:	fed7fae3          	bleu	a3,a5,806 <free+0x38>
 816:	6398                	ld	a4,0(a5)
 818:	00e6e463          	bltu	a3,a4,820 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81c:	fee7eae3          	bltu	a5,a4,810 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 820:	ff852583          	lw	a1,-8(a0)
 824:	6390                	ld	a2,0(a5)
 826:	02059713          	slli	a4,a1,0x20
 82a:	9301                	srli	a4,a4,0x20
 82c:	0712                	slli	a4,a4,0x4
 82e:	9736                	add	a4,a4,a3
 830:	fae60ae3          	beq	a2,a4,7e4 <free+0x16>
    bp->s.ptr = p->s.ptr;
 834:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 838:	4790                	lw	a2,8(a5)
 83a:	02061713          	slli	a4,a2,0x20
 83e:	9301                	srli	a4,a4,0x20
 840:	0712                	slli	a4,a4,0x4
 842:	973e                	add	a4,a4,a5
 844:	fae689e3          	beq	a3,a4,7f6 <free+0x28>
  } else
    p->s.ptr = bp;
 848:	e394                	sd	a3,0(a5)
  freep = p;
 84a:	00000717          	auipc	a4,0x0
 84e:	22f73b23          	sd	a5,566(a4) # a80 <__bss_start>
}
 852:	6422                	ld	s0,8(sp)
 854:	0141                	addi	sp,sp,16
 856:	8082                	ret

0000000000000858 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 858:	7139                	addi	sp,sp,-64
 85a:	fc06                	sd	ra,56(sp)
 85c:	f822                	sd	s0,48(sp)
 85e:	f426                	sd	s1,40(sp)
 860:	f04a                	sd	s2,32(sp)
 862:	ec4e                	sd	s3,24(sp)
 864:	e852                	sd	s4,16(sp)
 866:	e456                	sd	s5,8(sp)
 868:	e05a                	sd	s6,0(sp)
 86a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 86c:	02051993          	slli	s3,a0,0x20
 870:	0209d993          	srli	s3,s3,0x20
 874:	09bd                	addi	s3,s3,15
 876:	0049d993          	srli	s3,s3,0x4
 87a:	2985                	addiw	s3,s3,1
 87c:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 880:	00000797          	auipc	a5,0x0
 884:	20078793          	addi	a5,a5,512 # a80 <__bss_start>
 888:	6388                	ld	a0,0(a5)
 88a:	c515                	beqz	a0,8b6 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 88e:	4798                	lw	a4,8(a5)
 890:	03277f63          	bleu	s2,a4,8ce <malloc+0x76>
 894:	8a4e                	mv	s4,s3
 896:	0009871b          	sext.w	a4,s3
 89a:	6685                	lui	a3,0x1
 89c:	00d77363          	bleu	a3,a4,8a2 <malloc+0x4a>
 8a0:	6a05                	lui	s4,0x1
 8a2:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 8a6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8aa:	00000497          	auipc	s1,0x0
 8ae:	1d648493          	addi	s1,s1,470 # a80 <__bss_start>
  if(p == (char*)-1)
 8b2:	5b7d                	li	s6,-1
 8b4:	a885                	j	924 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 8b6:	00000797          	auipc	a5,0x0
 8ba:	1d278793          	addi	a5,a5,466 # a88 <base>
 8be:	00000717          	auipc	a4,0x0
 8c2:	1cf73123          	sd	a5,450(a4) # a80 <__bss_start>
 8c6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8cc:	b7e1                	j	894 <malloc+0x3c>
      if(p->s.size == nunits)
 8ce:	02e90b63          	beq	s2,a4,904 <malloc+0xac>
        p->s.size -= nunits;
 8d2:	4137073b          	subw	a4,a4,s3
 8d6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8d8:	1702                	slli	a4,a4,0x20
 8da:	9301                	srli	a4,a4,0x20
 8dc:	0712                	slli	a4,a4,0x4
 8de:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8e4:	00000717          	auipc	a4,0x0
 8e8:	18a73e23          	sd	a0,412(a4) # a80 <__bss_start>
      return (void*)(p + 1);
 8ec:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8f0:	70e2                	ld	ra,56(sp)
 8f2:	7442                	ld	s0,48(sp)
 8f4:	74a2                	ld	s1,40(sp)
 8f6:	7902                	ld	s2,32(sp)
 8f8:	69e2                	ld	s3,24(sp)
 8fa:	6a42                	ld	s4,16(sp)
 8fc:	6aa2                	ld	s5,8(sp)
 8fe:	6b02                	ld	s6,0(sp)
 900:	6121                	addi	sp,sp,64
 902:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 904:	6398                	ld	a4,0(a5)
 906:	e118                	sd	a4,0(a0)
 908:	bff1                	j	8e4 <malloc+0x8c>
  hp->s.size = nu;
 90a:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 90e:	0541                	addi	a0,a0,16
 910:	00000097          	auipc	ra,0x0
 914:	ebe080e7          	jalr	-322(ra) # 7ce <free>
  return freep;
 918:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 91a:	d979                	beqz	a0,8f0 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 91c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 91e:	4798                	lw	a4,8(a5)
 920:	fb2777e3          	bleu	s2,a4,8ce <malloc+0x76>
    if(p == freep)
 924:	6098                	ld	a4,0(s1)
 926:	853e                	mv	a0,a5
 928:	fef71ae3          	bne	a4,a5,91c <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 92c:	8552                	mv	a0,s4
 92e:	00000097          	auipc	ra,0x0
 932:	b72080e7          	jalr	-1166(ra) # 4a0 <sbrk>
  if(p == (char*)-1)
 936:	fd651ae3          	bne	a0,s6,90a <malloc+0xb2>
        return 0;
 93a:	4501                	li	a0,0
 93c:	bf55                	j	8f0 <malloc+0x98>
