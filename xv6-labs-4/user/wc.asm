
user/_wc：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4981                	li	s3,0
  l = w = c = 0;
  28:	4d01                	li	s10,0
  2a:	4c81                	li	s9,0
  2c:	4c01                	li	s8,0
  2e:	00001d97          	auipc	s11,0x1
  32:	99bd8d93          	addi	s11,s11,-1637 # 9c9 <buf+0x1>
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	920a0a13          	addi	s4,s4,-1760 # 958 <malloc+0xea>
        inword = 0;
  40:	4b81                	li	s7,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a805                	j	72 <wc+0x72>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	00000097          	auipc	ra,0x0
  4a:	1f0080e7          	jalr	496(ra) # 236 <strchr>
  4e:	c919                	beqz	a0,64 <wc+0x64>
        inword = 0;
  50:	89de                	mv	s3,s7
    for(i=0; i<n; i++){
  52:	0485                	addi	s1,s1,1
  54:	01248d63          	beq	s1,s2,6e <wc+0x6e>
      if(buf[i] == '\n')
  58:	0004c583          	lbu	a1,0(s1)
  5c:	ff5594e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  60:	2c05                	addiw	s8,s8,1
  62:	b7cd                	j	44 <wc+0x44>
      else if(!inword){
  64:	fe0997e3          	bnez	s3,52 <wc+0x52>
        w++;
  68:	2c85                	addiw	s9,s9,1
        inword = 1;
  6a:	4985                	li	s3,1
  6c:	b7dd                	j	52 <wc+0x52>
  6e:	016d0d3b          	addw	s10,s10,s6
  while((n = read(fd, buf, sizeof(buf))) > 0){
  72:	20000613          	li	a2,512
  76:	00001597          	auipc	a1,0x1
  7a:	95258593          	addi	a1,a1,-1710 # 9c8 <buf>
  7e:	f8843503          	ld	a0,-120(s0)
  82:	00000097          	auipc	ra,0x0
  86:	3bc080e7          	jalr	956(ra) # 43e <read>
  8a:	00a05f63          	blez	a0,a8 <wc+0xa8>
  8e:	00001497          	auipc	s1,0x1
  92:	93a48493          	addi	s1,s1,-1734 # 9c8 <buf>
  96:	00050b1b          	sext.w	s6,a0
  9a:	fffb091b          	addiw	s2,s6,-1
  9e:	1902                	slli	s2,s2,0x20
  a0:	02095913          	srli	s2,s2,0x20
  a4:	996e                	add	s2,s2,s11
  a6:	bf4d                	j	58 <wc+0x58>
      }
    }
  }
  if(n < 0){
  a8:	02054e63          	bltz	a0,e4 <wc+0xe4>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  ac:	f8043703          	ld	a4,-128(s0)
  b0:	86ea                	mv	a3,s10
  b2:	8666                	mv	a2,s9
  b4:	85e2                	mv	a1,s8
  b6:	00001517          	auipc	a0,0x1
  ba:	8ba50513          	addi	a0,a0,-1862 # 970 <malloc+0x102>
  be:	00000097          	auipc	ra,0x0
  c2:	6f0080e7          	jalr	1776(ra) # 7ae <printf>
}
  c6:	70e6                	ld	ra,120(sp)
  c8:	7446                	ld	s0,112(sp)
  ca:	74a6                	ld	s1,104(sp)
  cc:	7906                	ld	s2,96(sp)
  ce:	69e6                	ld	s3,88(sp)
  d0:	6a46                	ld	s4,80(sp)
  d2:	6aa6                	ld	s5,72(sp)
  d4:	6b06                	ld	s6,64(sp)
  d6:	7be2                	ld	s7,56(sp)
  d8:	7c42                	ld	s8,48(sp)
  da:	7ca2                	ld	s9,40(sp)
  dc:	7d02                	ld	s10,32(sp)
  de:	6de2                	ld	s11,24(sp)
  e0:	6109                	addi	sp,sp,128
  e2:	8082                	ret
    printf("wc: read error\n");
  e4:	00001517          	auipc	a0,0x1
  e8:	87c50513          	addi	a0,a0,-1924 # 960 <malloc+0xf2>
  ec:	00000097          	auipc	ra,0x0
  f0:	6c2080e7          	jalr	1730(ra) # 7ae <printf>
    exit(1);
  f4:	4505                	li	a0,1
  f6:	00000097          	auipc	ra,0x0
  fa:	330080e7          	jalr	816(ra) # 426 <exit>

00000000000000fe <main>:

int
main(int argc, char *argv[])
{
  fe:	7179                	addi	sp,sp,-48
 100:	f406                	sd	ra,40(sp)
 102:	f022                	sd	s0,32(sp)
 104:	ec26                	sd	s1,24(sp)
 106:	e84a                	sd	s2,16(sp)
 108:	e44e                	sd	s3,8(sp)
 10a:	e052                	sd	s4,0(sp)
 10c:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
 10e:	4785                	li	a5,1
 110:	04a7d763          	ble	a0,a5,15e <main+0x60>
 114:	00858493          	addi	s1,a1,8
 118:	ffe5099b          	addiw	s3,a0,-2
 11c:	1982                	slli	s3,s3,0x20
 11e:	0209d993          	srli	s3,s3,0x20
 122:	098e                	slli	s3,s3,0x3
 124:	05c1                	addi	a1,a1,16
 126:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 128:	4581                	li	a1,0
 12a:	6088                	ld	a0,0(s1)
 12c:	00000097          	auipc	ra,0x0
 130:	33a080e7          	jalr	826(ra) # 466 <open>
 134:	892a                	mv	s2,a0
 136:	04054263          	bltz	a0,17a <main+0x7c>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 13a:	608c                	ld	a1,0(s1)
 13c:	00000097          	auipc	ra,0x0
 140:	ec4080e7          	jalr	-316(ra) # 0 <wc>
    close(fd);
 144:	854a                	mv	a0,s2
 146:	00000097          	auipc	ra,0x0
 14a:	308080e7          	jalr	776(ra) # 44e <close>
  for(i = 1; i < argc; i++){
 14e:	04a1                	addi	s1,s1,8
 150:	fd349ce3          	bne	s1,s3,128 <main+0x2a>
  }
  exit(0);
 154:	4501                	li	a0,0
 156:	00000097          	auipc	ra,0x0
 15a:	2d0080e7          	jalr	720(ra) # 426 <exit>
    wc(0, "");
 15e:	00001597          	auipc	a1,0x1
 162:	82258593          	addi	a1,a1,-2014 # 980 <malloc+0x112>
 166:	4501                	li	a0,0
 168:	00000097          	auipc	ra,0x0
 16c:	e98080e7          	jalr	-360(ra) # 0 <wc>
    exit(0);
 170:	4501                	li	a0,0
 172:	00000097          	auipc	ra,0x0
 176:	2b4080e7          	jalr	692(ra) # 426 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 17a:	608c                	ld	a1,0(s1)
 17c:	00001517          	auipc	a0,0x1
 180:	80c50513          	addi	a0,a0,-2036 # 988 <malloc+0x11a>
 184:	00000097          	auipc	ra,0x0
 188:	62a080e7          	jalr	1578(ra) # 7ae <printf>
      exit(1);
 18c:	4505                	li	a0,1
 18e:	00000097          	auipc	ra,0x0
 192:	298080e7          	jalr	664(ra) # 426 <exit>

0000000000000196 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 196:	1141                	addi	sp,sp,-16
 198:	e422                	sd	s0,8(sp)
 19a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 19c:	87aa                	mv	a5,a0
 19e:	0585                	addi	a1,a1,1
 1a0:	0785                	addi	a5,a5,1
 1a2:	fff5c703          	lbu	a4,-1(a1)
 1a6:	fee78fa3          	sb	a4,-1(a5)
 1aa:	fb75                	bnez	a4,19e <strcpy+0x8>
    ;
  return os;
}
 1ac:	6422                	ld	s0,8(sp)
 1ae:	0141                	addi	sp,sp,16
 1b0:	8082                	ret

00000000000001b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b2:	1141                	addi	sp,sp,-16
 1b4:	e422                	sd	s0,8(sp)
 1b6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	cf91                	beqz	a5,1d8 <strcmp+0x26>
 1be:	0005c703          	lbu	a4,0(a1)
 1c2:	00f71b63          	bne	a4,a5,1d8 <strcmp+0x26>
    p++, q++;
 1c6:	0505                	addi	a0,a0,1
 1c8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1ca:	00054783          	lbu	a5,0(a0)
 1ce:	c789                	beqz	a5,1d8 <strcmp+0x26>
 1d0:	0005c703          	lbu	a4,0(a1)
 1d4:	fef709e3          	beq	a4,a5,1c6 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 1d8:	0005c503          	lbu	a0,0(a1)
}
 1dc:	40a7853b          	subw	a0,a5,a0
 1e0:	6422                	ld	s0,8(sp)
 1e2:	0141                	addi	sp,sp,16
 1e4:	8082                	ret

00000000000001e6 <strlen>:

uint
strlen(const char *s)
{
 1e6:	1141                	addi	sp,sp,-16
 1e8:	e422                	sd	s0,8(sp)
 1ea:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ec:	00054783          	lbu	a5,0(a0)
 1f0:	cf91                	beqz	a5,20c <strlen+0x26>
 1f2:	0505                	addi	a0,a0,1
 1f4:	87aa                	mv	a5,a0
 1f6:	4685                	li	a3,1
 1f8:	9e89                	subw	a3,a3,a0
 1fa:	00f6853b          	addw	a0,a3,a5
 1fe:	0785                	addi	a5,a5,1
 200:	fff7c703          	lbu	a4,-1(a5)
 204:	fb7d                	bnez	a4,1fa <strlen+0x14>
    ;
  return n;
}
 206:	6422                	ld	s0,8(sp)
 208:	0141                	addi	sp,sp,16
 20a:	8082                	ret
  for(n = 0; s[n]; n++)
 20c:	4501                	li	a0,0
 20e:	bfe5                	j	206 <strlen+0x20>

0000000000000210 <memset>:

void*
memset(void *dst, int c, uint n)
{
 210:	1141                	addi	sp,sp,-16
 212:	e422                	sd	s0,8(sp)
 214:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 216:	ce09                	beqz	a2,230 <memset+0x20>
 218:	87aa                	mv	a5,a0
 21a:	fff6071b          	addiw	a4,a2,-1
 21e:	1702                	slli	a4,a4,0x20
 220:	9301                	srli	a4,a4,0x20
 222:	0705                	addi	a4,a4,1
 224:	972a                	add	a4,a4,a0
    cdst[i] = c;
 226:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 22a:	0785                	addi	a5,a5,1
 22c:	fee79de3          	bne	a5,a4,226 <memset+0x16>
  }
  return dst;
}
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret

0000000000000236 <strchr>:

char*
strchr(const char *s, char c)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 23c:	00054783          	lbu	a5,0(a0)
 240:	cf91                	beqz	a5,25c <strchr+0x26>
    if(*s == c)
 242:	00f58a63          	beq	a1,a5,256 <strchr+0x20>
  for(; *s; s++)
 246:	0505                	addi	a0,a0,1
 248:	00054783          	lbu	a5,0(a0)
 24c:	c781                	beqz	a5,254 <strchr+0x1e>
    if(*s == c)
 24e:	feb79ce3          	bne	a5,a1,246 <strchr+0x10>
 252:	a011                	j	256 <strchr+0x20>
      return (char*)s;
  return 0;
 254:	4501                	li	a0,0
}
 256:	6422                	ld	s0,8(sp)
 258:	0141                	addi	sp,sp,16
 25a:	8082                	ret
  return 0;
 25c:	4501                	li	a0,0
 25e:	bfe5                	j	256 <strchr+0x20>

0000000000000260 <gets>:

char*
gets(char *buf, int max)
{
 260:	711d                	addi	sp,sp,-96
 262:	ec86                	sd	ra,88(sp)
 264:	e8a2                	sd	s0,80(sp)
 266:	e4a6                	sd	s1,72(sp)
 268:	e0ca                	sd	s2,64(sp)
 26a:	fc4e                	sd	s3,56(sp)
 26c:	f852                	sd	s4,48(sp)
 26e:	f456                	sd	s5,40(sp)
 270:	f05a                	sd	s6,32(sp)
 272:	ec5e                	sd	s7,24(sp)
 274:	1080                	addi	s0,sp,96
 276:	8baa                	mv	s7,a0
 278:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27a:	892a                	mv	s2,a0
 27c:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 27e:	4aa9                	li	s5,10
 280:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 282:	0019849b          	addiw	s1,s3,1
 286:	0344d863          	ble	s4,s1,2b6 <gets+0x56>
    cc = read(0, &c, 1);
 28a:	4605                	li	a2,1
 28c:	faf40593          	addi	a1,s0,-81
 290:	4501                	li	a0,0
 292:	00000097          	auipc	ra,0x0
 296:	1ac080e7          	jalr	428(ra) # 43e <read>
    if(cc < 1)
 29a:	00a05e63          	blez	a0,2b6 <gets+0x56>
    buf[i++] = c;
 29e:	faf44783          	lbu	a5,-81(s0)
 2a2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2a6:	01578763          	beq	a5,s5,2b4 <gets+0x54>
 2aa:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 2ac:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 2ae:	fd679ae3          	bne	a5,s6,282 <gets+0x22>
 2b2:	a011                	j	2b6 <gets+0x56>
  for(i=0; i+1 < max; ){
 2b4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2b6:	99de                	add	s3,s3,s7
 2b8:	00098023          	sb	zero,0(s3)
  return buf;
}
 2bc:	855e                	mv	a0,s7
 2be:	60e6                	ld	ra,88(sp)
 2c0:	6446                	ld	s0,80(sp)
 2c2:	64a6                	ld	s1,72(sp)
 2c4:	6906                	ld	s2,64(sp)
 2c6:	79e2                	ld	s3,56(sp)
 2c8:	7a42                	ld	s4,48(sp)
 2ca:	7aa2                	ld	s5,40(sp)
 2cc:	7b02                	ld	s6,32(sp)
 2ce:	6be2                	ld	s7,24(sp)
 2d0:	6125                	addi	sp,sp,96
 2d2:	8082                	ret

00000000000002d4 <stat>:

int
stat(const char *n, struct stat *st)
{
 2d4:	1101                	addi	sp,sp,-32
 2d6:	ec06                	sd	ra,24(sp)
 2d8:	e822                	sd	s0,16(sp)
 2da:	e426                	sd	s1,8(sp)
 2dc:	e04a                	sd	s2,0(sp)
 2de:	1000                	addi	s0,sp,32
 2e0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2e2:	4581                	li	a1,0
 2e4:	00000097          	auipc	ra,0x0
 2e8:	182080e7          	jalr	386(ra) # 466 <open>
  if(fd < 0)
 2ec:	02054563          	bltz	a0,316 <stat+0x42>
 2f0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2f2:	85ca                	mv	a1,s2
 2f4:	00000097          	auipc	ra,0x0
 2f8:	18a080e7          	jalr	394(ra) # 47e <fstat>
 2fc:	892a                	mv	s2,a0
  close(fd);
 2fe:	8526                	mv	a0,s1
 300:	00000097          	auipc	ra,0x0
 304:	14e080e7          	jalr	334(ra) # 44e <close>
  return r;
}
 308:	854a                	mv	a0,s2
 30a:	60e2                	ld	ra,24(sp)
 30c:	6442                	ld	s0,16(sp)
 30e:	64a2                	ld	s1,8(sp)
 310:	6902                	ld	s2,0(sp)
 312:	6105                	addi	sp,sp,32
 314:	8082                	ret
    return -1;
 316:	597d                	li	s2,-1
 318:	bfc5                	j	308 <stat+0x34>

000000000000031a <atoi>:

int
atoi(const char *s)
{
 31a:	1141                	addi	sp,sp,-16
 31c:	e422                	sd	s0,8(sp)
 31e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 320:	00054683          	lbu	a3,0(a0)
 324:	fd06879b          	addiw	a5,a3,-48
 328:	0ff7f793          	andi	a5,a5,255
 32c:	4725                	li	a4,9
 32e:	02f76963          	bltu	a4,a5,360 <atoi+0x46>
 332:	862a                	mv	a2,a0
  n = 0;
 334:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 336:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 338:	0605                	addi	a2,a2,1
 33a:	0025179b          	slliw	a5,a0,0x2
 33e:	9fa9                	addw	a5,a5,a0
 340:	0017979b          	slliw	a5,a5,0x1
 344:	9fb5                	addw	a5,a5,a3
 346:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 34a:	00064683          	lbu	a3,0(a2)
 34e:	fd06871b          	addiw	a4,a3,-48
 352:	0ff77713          	andi	a4,a4,255
 356:	fee5f1e3          	bleu	a4,a1,338 <atoi+0x1e>
  return n;
}
 35a:	6422                	ld	s0,8(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret
  n = 0;
 360:	4501                	li	a0,0
 362:	bfe5                	j	35a <atoi+0x40>

0000000000000364 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 364:	1141                	addi	sp,sp,-16
 366:	e422                	sd	s0,8(sp)
 368:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 36a:	02b57663          	bleu	a1,a0,396 <memmove+0x32>
    while(n-- > 0)
 36e:	02c05163          	blez	a2,390 <memmove+0x2c>
 372:	fff6079b          	addiw	a5,a2,-1
 376:	1782                	slli	a5,a5,0x20
 378:	9381                	srli	a5,a5,0x20
 37a:	0785                	addi	a5,a5,1
 37c:	97aa                	add	a5,a5,a0
  dst = vdst;
 37e:	872a                	mv	a4,a0
      *dst++ = *src++;
 380:	0585                	addi	a1,a1,1
 382:	0705                	addi	a4,a4,1
 384:	fff5c683          	lbu	a3,-1(a1)
 388:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 38c:	fee79ae3          	bne	a5,a4,380 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 390:	6422                	ld	s0,8(sp)
 392:	0141                	addi	sp,sp,16
 394:	8082                	ret
    dst += n;
 396:	00c50733          	add	a4,a0,a2
    src += n;
 39a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 39c:	fec05ae3          	blez	a2,390 <memmove+0x2c>
 3a0:	fff6079b          	addiw	a5,a2,-1
 3a4:	1782                	slli	a5,a5,0x20
 3a6:	9381                	srli	a5,a5,0x20
 3a8:	fff7c793          	not	a5,a5
 3ac:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3ae:	15fd                	addi	a1,a1,-1
 3b0:	177d                	addi	a4,a4,-1
 3b2:	0005c683          	lbu	a3,0(a1)
 3b6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3ba:	fef71ae3          	bne	a4,a5,3ae <memmove+0x4a>
 3be:	bfc9                	j	390 <memmove+0x2c>

00000000000003c0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e422                	sd	s0,8(sp)
 3c4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3c6:	ce15                	beqz	a2,402 <memcmp+0x42>
 3c8:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 3cc:	00054783          	lbu	a5,0(a0)
 3d0:	0005c703          	lbu	a4,0(a1)
 3d4:	02e79063          	bne	a5,a4,3f4 <memcmp+0x34>
 3d8:	1682                	slli	a3,a3,0x20
 3da:	9281                	srli	a3,a3,0x20
 3dc:	0685                	addi	a3,a3,1
 3de:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 3e0:	0505                	addi	a0,a0,1
    p2++;
 3e2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3e4:	00d50d63          	beq	a0,a3,3fe <memcmp+0x3e>
    if (*p1 != *p2) {
 3e8:	00054783          	lbu	a5,0(a0)
 3ec:	0005c703          	lbu	a4,0(a1)
 3f0:	fee788e3          	beq	a5,a4,3e0 <memcmp+0x20>
      return *p1 - *p2;
 3f4:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 3f8:	6422                	ld	s0,8(sp)
 3fa:	0141                	addi	sp,sp,16
 3fc:	8082                	ret
  return 0;
 3fe:	4501                	li	a0,0
 400:	bfe5                	j	3f8 <memcmp+0x38>
 402:	4501                	li	a0,0
 404:	bfd5                	j	3f8 <memcmp+0x38>

0000000000000406 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 406:	1141                	addi	sp,sp,-16
 408:	e406                	sd	ra,8(sp)
 40a:	e022                	sd	s0,0(sp)
 40c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 40e:	00000097          	auipc	ra,0x0
 412:	f56080e7          	jalr	-170(ra) # 364 <memmove>
}
 416:	60a2                	ld	ra,8(sp)
 418:	6402                	ld	s0,0(sp)
 41a:	0141                	addi	sp,sp,16
 41c:	8082                	ret

000000000000041e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 41e:	4885                	li	a7,1
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <exit>:
.global exit
exit:
 li a7, SYS_exit
 426:	4889                	li	a7,2
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <wait>:
.global wait
wait:
 li a7, SYS_wait
 42e:	488d                	li	a7,3
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 436:	4891                	li	a7,4
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <read>:
.global read
read:
 li a7, SYS_read
 43e:	4895                	li	a7,5
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <write>:
.global write
write:
 li a7, SYS_write
 446:	48c1                	li	a7,16
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <close>:
.global close
close:
 li a7, SYS_close
 44e:	48d5                	li	a7,21
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <kill>:
.global kill
kill:
 li a7, SYS_kill
 456:	4899                	li	a7,6
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <exec>:
.global exec
exec:
 li a7, SYS_exec
 45e:	489d                	li	a7,7
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <open>:
.global open
open:
 li a7, SYS_open
 466:	48bd                	li	a7,15
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 46e:	48c5                	li	a7,17
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 476:	48c9                	li	a7,18
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 47e:	48a1                	li	a7,8
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <link>:
.global link
link:
 li a7, SYS_link
 486:	48cd                	li	a7,19
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 48e:	48d1                	li	a7,20
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 496:	48a5                	li	a7,9
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <dup>:
.global dup
dup:
 li a7, SYS_dup
 49e:	48a9                	li	a7,10
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4a6:	48ad                	li	a7,11
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4ae:	48b1                	li	a7,12
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4b6:	48b5                	li	a7,13
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4be:	48b9                	li	a7,14
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 4c6:	48d9                	li	a7,22
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 4ce:	48dd                	li	a7,23
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4d6:	1101                	addi	sp,sp,-32
 4d8:	ec06                	sd	ra,24(sp)
 4da:	e822                	sd	s0,16(sp)
 4dc:	1000                	addi	s0,sp,32
 4de:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4e2:	4605                	li	a2,1
 4e4:	fef40593          	addi	a1,s0,-17
 4e8:	00000097          	auipc	ra,0x0
 4ec:	f5e080e7          	jalr	-162(ra) # 446 <write>
}
 4f0:	60e2                	ld	ra,24(sp)
 4f2:	6442                	ld	s0,16(sp)
 4f4:	6105                	addi	sp,sp,32
 4f6:	8082                	ret

00000000000004f8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4f8:	7139                	addi	sp,sp,-64
 4fa:	fc06                	sd	ra,56(sp)
 4fc:	f822                	sd	s0,48(sp)
 4fe:	f426                	sd	s1,40(sp)
 500:	f04a                	sd	s2,32(sp)
 502:	ec4e                	sd	s3,24(sp)
 504:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 506:	c299                	beqz	a3,50c <printint+0x14>
 508:	0005cd63          	bltz	a1,522 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 50c:	2581                	sext.w	a1,a1
  neg = 0;
 50e:	4301                	li	t1,0
 510:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 514:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 516:	2601                	sext.w	a2,a2
 518:	00000897          	auipc	a7,0x0
 51c:	48888893          	addi	a7,a7,1160 # 9a0 <digits>
 520:	a801                	j	530 <printint+0x38>
    x = -xx;
 522:	40b005bb          	negw	a1,a1
 526:	2581                	sext.w	a1,a1
    neg = 1;
 528:	4305                	li	t1,1
    x = -xx;
 52a:	b7dd                	j	510 <printint+0x18>
  }while((x /= base) != 0);
 52c:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 52e:	8836                	mv	a6,a3
 530:	0018069b          	addiw	a3,a6,1
 534:	02c5f7bb          	remuw	a5,a1,a2
 538:	1782                	slli	a5,a5,0x20
 53a:	9381                	srli	a5,a5,0x20
 53c:	97c6                	add	a5,a5,a7
 53e:	0007c783          	lbu	a5,0(a5)
 542:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 546:	0705                	addi	a4,a4,1
 548:	02c5d7bb          	divuw	a5,a1,a2
 54c:	fec5f0e3          	bleu	a2,a1,52c <printint+0x34>
  if(neg)
 550:	00030b63          	beqz	t1,566 <printint+0x6e>
    buf[i++] = '-';
 554:	fd040793          	addi	a5,s0,-48
 558:	96be                	add	a3,a3,a5
 55a:	02d00793          	li	a5,45
 55e:	fef68823          	sb	a5,-16(a3)
 562:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 566:	02d05963          	blez	a3,598 <printint+0xa0>
 56a:	89aa                	mv	s3,a0
 56c:	fc040793          	addi	a5,s0,-64
 570:	00d784b3          	add	s1,a5,a3
 574:	fff78913          	addi	s2,a5,-1
 578:	9936                	add	s2,s2,a3
 57a:	36fd                	addiw	a3,a3,-1
 57c:	1682                	slli	a3,a3,0x20
 57e:	9281                	srli	a3,a3,0x20
 580:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 584:	fff4c583          	lbu	a1,-1(s1)
 588:	854e                	mv	a0,s3
 58a:	00000097          	auipc	ra,0x0
 58e:	f4c080e7          	jalr	-180(ra) # 4d6 <putc>
  while(--i >= 0)
 592:	14fd                	addi	s1,s1,-1
 594:	ff2498e3          	bne	s1,s2,584 <printint+0x8c>
}
 598:	70e2                	ld	ra,56(sp)
 59a:	7442                	ld	s0,48(sp)
 59c:	74a2                	ld	s1,40(sp)
 59e:	7902                	ld	s2,32(sp)
 5a0:	69e2                	ld	s3,24(sp)
 5a2:	6121                	addi	sp,sp,64
 5a4:	8082                	ret

00000000000005a6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5a6:	7119                	addi	sp,sp,-128
 5a8:	fc86                	sd	ra,120(sp)
 5aa:	f8a2                	sd	s0,112(sp)
 5ac:	f4a6                	sd	s1,104(sp)
 5ae:	f0ca                	sd	s2,96(sp)
 5b0:	ecce                	sd	s3,88(sp)
 5b2:	e8d2                	sd	s4,80(sp)
 5b4:	e4d6                	sd	s5,72(sp)
 5b6:	e0da                	sd	s6,64(sp)
 5b8:	fc5e                	sd	s7,56(sp)
 5ba:	f862                	sd	s8,48(sp)
 5bc:	f466                	sd	s9,40(sp)
 5be:	f06a                	sd	s10,32(sp)
 5c0:	ec6e                	sd	s11,24(sp)
 5c2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5c4:	0005c483          	lbu	s1,0(a1)
 5c8:	18048d63          	beqz	s1,762 <vprintf+0x1bc>
 5cc:	8aaa                	mv	s5,a0
 5ce:	8b32                	mv	s6,a2
 5d0:	00158913          	addi	s2,a1,1
  state = 0;
 5d4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5d6:	02500a13          	li	s4,37
      if(c == 'd'){
 5da:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5de:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5e2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5e6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ea:	00000b97          	auipc	s7,0x0
 5ee:	3b6b8b93          	addi	s7,s7,950 # 9a0 <digits>
 5f2:	a839                	j	610 <vprintf+0x6a>
        putc(fd, c);
 5f4:	85a6                	mv	a1,s1
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	ede080e7          	jalr	-290(ra) # 4d6 <putc>
 600:	a019                	j	606 <vprintf+0x60>
    } else if(state == '%'){
 602:	01498f63          	beq	s3,s4,620 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 606:	0905                	addi	s2,s2,1
 608:	fff94483          	lbu	s1,-1(s2)
 60c:	14048b63          	beqz	s1,762 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 610:	0004879b          	sext.w	a5,s1
    if(state == 0){
 614:	fe0997e3          	bnez	s3,602 <vprintf+0x5c>
      if(c == '%'){
 618:	fd479ee3          	bne	a5,s4,5f4 <vprintf+0x4e>
        state = '%';
 61c:	89be                	mv	s3,a5
 61e:	b7e5                	j	606 <vprintf+0x60>
      if(c == 'd'){
 620:	05878063          	beq	a5,s8,660 <vprintf+0xba>
      } else if(c == 'l') {
 624:	05978c63          	beq	a5,s9,67c <vprintf+0xd6>
      } else if(c == 'x') {
 628:	07a78863          	beq	a5,s10,698 <vprintf+0xf2>
      } else if(c == 'p') {
 62c:	09b78463          	beq	a5,s11,6b4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 630:	07300713          	li	a4,115
 634:	0ce78563          	beq	a5,a4,6fe <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 638:	06300713          	li	a4,99
 63c:	0ee78c63          	beq	a5,a4,734 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 640:	11478663          	beq	a5,s4,74c <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 644:	85d2                	mv	a1,s4
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	e8e080e7          	jalr	-370(ra) # 4d6 <putc>
        putc(fd, c);
 650:	85a6                	mv	a1,s1
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	e82080e7          	jalr	-382(ra) # 4d6 <putc>
      }
      state = 0;
 65c:	4981                	li	s3,0
 65e:	b765                	j	606 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 660:	008b0493          	addi	s1,s6,8
 664:	4685                	li	a3,1
 666:	4629                	li	a2,10
 668:	000b2583          	lw	a1,0(s6)
 66c:	8556                	mv	a0,s5
 66e:	00000097          	auipc	ra,0x0
 672:	e8a080e7          	jalr	-374(ra) # 4f8 <printint>
 676:	8b26                	mv	s6,s1
      state = 0;
 678:	4981                	li	s3,0
 67a:	b771                	j	606 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67c:	008b0493          	addi	s1,s6,8
 680:	4681                	li	a3,0
 682:	4629                	li	a2,10
 684:	000b2583          	lw	a1,0(s6)
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	e6e080e7          	jalr	-402(ra) # 4f8 <printint>
 692:	8b26                	mv	s6,s1
      state = 0;
 694:	4981                	li	s3,0
 696:	bf85                	j	606 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 698:	008b0493          	addi	s1,s6,8
 69c:	4681                	li	a3,0
 69e:	4641                	li	a2,16
 6a0:	000b2583          	lw	a1,0(s6)
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	e52080e7          	jalr	-430(ra) # 4f8 <printint>
 6ae:	8b26                	mv	s6,s1
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	bf91                	j	606 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6b4:	008b0793          	addi	a5,s6,8
 6b8:	f8f43423          	sd	a5,-120(s0)
 6bc:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6c0:	03000593          	li	a1,48
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	e10080e7          	jalr	-496(ra) # 4d6 <putc>
  putc(fd, 'x');
 6ce:	85ea                	mv	a1,s10
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	e04080e7          	jalr	-508(ra) # 4d6 <putc>
 6da:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6dc:	03c9d793          	srli	a5,s3,0x3c
 6e0:	97de                	add	a5,a5,s7
 6e2:	0007c583          	lbu	a1,0(a5)
 6e6:	8556                	mv	a0,s5
 6e8:	00000097          	auipc	ra,0x0
 6ec:	dee080e7          	jalr	-530(ra) # 4d6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6f0:	0992                	slli	s3,s3,0x4
 6f2:	34fd                	addiw	s1,s1,-1
 6f4:	f4e5                	bnez	s1,6dc <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6f6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	b729                	j	606 <vprintf+0x60>
        s = va_arg(ap, char*);
 6fe:	008b0993          	addi	s3,s6,8
 702:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 706:	c085                	beqz	s1,726 <vprintf+0x180>
        while(*s != 0){
 708:	0004c583          	lbu	a1,0(s1)
 70c:	c9a1                	beqz	a1,75c <vprintf+0x1b6>
          putc(fd, *s);
 70e:	8556                	mv	a0,s5
 710:	00000097          	auipc	ra,0x0
 714:	dc6080e7          	jalr	-570(ra) # 4d6 <putc>
          s++;
 718:	0485                	addi	s1,s1,1
        while(*s != 0){
 71a:	0004c583          	lbu	a1,0(s1)
 71e:	f9e5                	bnez	a1,70e <vprintf+0x168>
        s = va_arg(ap, char*);
 720:	8b4e                	mv	s6,s3
      state = 0;
 722:	4981                	li	s3,0
 724:	b5cd                	j	606 <vprintf+0x60>
          s = "(null)";
 726:	00000497          	auipc	s1,0x0
 72a:	29248493          	addi	s1,s1,658 # 9b8 <digits+0x18>
        while(*s != 0){
 72e:	02800593          	li	a1,40
 732:	bff1                	j	70e <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 734:	008b0493          	addi	s1,s6,8
 738:	000b4583          	lbu	a1,0(s6)
 73c:	8556                	mv	a0,s5
 73e:	00000097          	auipc	ra,0x0
 742:	d98080e7          	jalr	-616(ra) # 4d6 <putc>
 746:	8b26                	mv	s6,s1
      state = 0;
 748:	4981                	li	s3,0
 74a:	bd75                	j	606 <vprintf+0x60>
        putc(fd, c);
 74c:	85d2                	mv	a1,s4
 74e:	8556                	mv	a0,s5
 750:	00000097          	auipc	ra,0x0
 754:	d86080e7          	jalr	-634(ra) # 4d6 <putc>
      state = 0;
 758:	4981                	li	s3,0
 75a:	b575                	j	606 <vprintf+0x60>
        s = va_arg(ap, char*);
 75c:	8b4e                	mv	s6,s3
      state = 0;
 75e:	4981                	li	s3,0
 760:	b55d                	j	606 <vprintf+0x60>
    }
  }
}
 762:	70e6                	ld	ra,120(sp)
 764:	7446                	ld	s0,112(sp)
 766:	74a6                	ld	s1,104(sp)
 768:	7906                	ld	s2,96(sp)
 76a:	69e6                	ld	s3,88(sp)
 76c:	6a46                	ld	s4,80(sp)
 76e:	6aa6                	ld	s5,72(sp)
 770:	6b06                	ld	s6,64(sp)
 772:	7be2                	ld	s7,56(sp)
 774:	7c42                	ld	s8,48(sp)
 776:	7ca2                	ld	s9,40(sp)
 778:	7d02                	ld	s10,32(sp)
 77a:	6de2                	ld	s11,24(sp)
 77c:	6109                	addi	sp,sp,128
 77e:	8082                	ret

0000000000000780 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 780:	715d                	addi	sp,sp,-80
 782:	ec06                	sd	ra,24(sp)
 784:	e822                	sd	s0,16(sp)
 786:	1000                	addi	s0,sp,32
 788:	e010                	sd	a2,0(s0)
 78a:	e414                	sd	a3,8(s0)
 78c:	e818                	sd	a4,16(s0)
 78e:	ec1c                	sd	a5,24(s0)
 790:	03043023          	sd	a6,32(s0)
 794:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 798:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 79c:	8622                	mv	a2,s0
 79e:	00000097          	auipc	ra,0x0
 7a2:	e08080e7          	jalr	-504(ra) # 5a6 <vprintf>
}
 7a6:	60e2                	ld	ra,24(sp)
 7a8:	6442                	ld	s0,16(sp)
 7aa:	6161                	addi	sp,sp,80
 7ac:	8082                	ret

00000000000007ae <printf>:

void
printf(const char *fmt, ...)
{
 7ae:	711d                	addi	sp,sp,-96
 7b0:	ec06                	sd	ra,24(sp)
 7b2:	e822                	sd	s0,16(sp)
 7b4:	1000                	addi	s0,sp,32
 7b6:	e40c                	sd	a1,8(s0)
 7b8:	e810                	sd	a2,16(s0)
 7ba:	ec14                	sd	a3,24(s0)
 7bc:	f018                	sd	a4,32(s0)
 7be:	f41c                	sd	a5,40(s0)
 7c0:	03043823          	sd	a6,48(s0)
 7c4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7c8:	00840613          	addi	a2,s0,8
 7cc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d0:	85aa                	mv	a1,a0
 7d2:	4505                	li	a0,1
 7d4:	00000097          	auipc	ra,0x0
 7d8:	dd2080e7          	jalr	-558(ra) # 5a6 <vprintf>
}
 7dc:	60e2                	ld	ra,24(sp)
 7de:	6442                	ld	s0,16(sp)
 7e0:	6125                	addi	sp,sp,96
 7e2:	8082                	ret

00000000000007e4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e4:	1141                	addi	sp,sp,-16
 7e6:	e422                	sd	s0,8(sp)
 7e8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ea:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ee:	00000797          	auipc	a5,0x0
 7f2:	1d278793          	addi	a5,a5,466 # 9c0 <__bss_start>
 7f6:	639c                	ld	a5,0(a5)
 7f8:	a805                	j	828 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7fa:	4618                	lw	a4,8(a2)
 7fc:	9db9                	addw	a1,a1,a4
 7fe:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 802:	6398                	ld	a4,0(a5)
 804:	6318                	ld	a4,0(a4)
 806:	fee53823          	sd	a4,-16(a0)
 80a:	a091                	j	84e <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 80c:	ff852703          	lw	a4,-8(a0)
 810:	9e39                	addw	a2,a2,a4
 812:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 814:	ff053703          	ld	a4,-16(a0)
 818:	e398                	sd	a4,0(a5)
 81a:	a099                	j	860 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81c:	6398                	ld	a4,0(a5)
 81e:	00e7e463          	bltu	a5,a4,826 <free+0x42>
 822:	00e6ea63          	bltu	a3,a4,836 <free+0x52>
{
 826:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 828:	fed7fae3          	bleu	a3,a5,81c <free+0x38>
 82c:	6398                	ld	a4,0(a5)
 82e:	00e6e463          	bltu	a3,a4,836 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 832:	fee7eae3          	bltu	a5,a4,826 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 836:	ff852583          	lw	a1,-8(a0)
 83a:	6390                	ld	a2,0(a5)
 83c:	02059713          	slli	a4,a1,0x20
 840:	9301                	srli	a4,a4,0x20
 842:	0712                	slli	a4,a4,0x4
 844:	9736                	add	a4,a4,a3
 846:	fae60ae3          	beq	a2,a4,7fa <free+0x16>
    bp->s.ptr = p->s.ptr;
 84a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 84e:	4790                	lw	a2,8(a5)
 850:	02061713          	slli	a4,a2,0x20
 854:	9301                	srli	a4,a4,0x20
 856:	0712                	slli	a4,a4,0x4
 858:	973e                	add	a4,a4,a5
 85a:	fae689e3          	beq	a3,a4,80c <free+0x28>
  } else
    p->s.ptr = bp;
 85e:	e394                	sd	a3,0(a5)
  freep = p;
 860:	00000717          	auipc	a4,0x0
 864:	16f73023          	sd	a5,352(a4) # 9c0 <__bss_start>
}
 868:	6422                	ld	s0,8(sp)
 86a:	0141                	addi	sp,sp,16
 86c:	8082                	ret

000000000000086e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 86e:	7139                	addi	sp,sp,-64
 870:	fc06                	sd	ra,56(sp)
 872:	f822                	sd	s0,48(sp)
 874:	f426                	sd	s1,40(sp)
 876:	f04a                	sd	s2,32(sp)
 878:	ec4e                	sd	s3,24(sp)
 87a:	e852                	sd	s4,16(sp)
 87c:	e456                	sd	s5,8(sp)
 87e:	e05a                	sd	s6,0(sp)
 880:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 882:	02051993          	slli	s3,a0,0x20
 886:	0209d993          	srli	s3,s3,0x20
 88a:	09bd                	addi	s3,s3,15
 88c:	0049d993          	srli	s3,s3,0x4
 890:	2985                	addiw	s3,s3,1
 892:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 896:	00000797          	auipc	a5,0x0
 89a:	12a78793          	addi	a5,a5,298 # 9c0 <__bss_start>
 89e:	6388                	ld	a0,0(a5)
 8a0:	c515                	beqz	a0,8cc <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a4:	4798                	lw	a4,8(a5)
 8a6:	03277f63          	bleu	s2,a4,8e4 <malloc+0x76>
 8aa:	8a4e                	mv	s4,s3
 8ac:	0009871b          	sext.w	a4,s3
 8b0:	6685                	lui	a3,0x1
 8b2:	00d77363          	bleu	a3,a4,8b8 <malloc+0x4a>
 8b6:	6a05                	lui	s4,0x1
 8b8:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 8bc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8c0:	00000497          	auipc	s1,0x0
 8c4:	10048493          	addi	s1,s1,256 # 9c0 <__bss_start>
  if(p == (char*)-1)
 8c8:	5b7d                	li	s6,-1
 8ca:	a885                	j	93a <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 8cc:	00000797          	auipc	a5,0x0
 8d0:	2fc78793          	addi	a5,a5,764 # bc8 <base>
 8d4:	00000717          	auipc	a4,0x0
 8d8:	0ef73623          	sd	a5,236(a4) # 9c0 <__bss_start>
 8dc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8de:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8e2:	b7e1                	j	8aa <malloc+0x3c>
      if(p->s.size == nunits)
 8e4:	02e90b63          	beq	s2,a4,91a <malloc+0xac>
        p->s.size -= nunits;
 8e8:	4137073b          	subw	a4,a4,s3
 8ec:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ee:	1702                	slli	a4,a4,0x20
 8f0:	9301                	srli	a4,a4,0x20
 8f2:	0712                	slli	a4,a4,0x4
 8f4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8fa:	00000717          	auipc	a4,0x0
 8fe:	0ca73323          	sd	a0,198(a4) # 9c0 <__bss_start>
      return (void*)(p + 1);
 902:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 906:	70e2                	ld	ra,56(sp)
 908:	7442                	ld	s0,48(sp)
 90a:	74a2                	ld	s1,40(sp)
 90c:	7902                	ld	s2,32(sp)
 90e:	69e2                	ld	s3,24(sp)
 910:	6a42                	ld	s4,16(sp)
 912:	6aa2                	ld	s5,8(sp)
 914:	6b02                	ld	s6,0(sp)
 916:	6121                	addi	sp,sp,64
 918:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 91a:	6398                	ld	a4,0(a5)
 91c:	e118                	sd	a4,0(a0)
 91e:	bff1                	j	8fa <malloc+0x8c>
  hp->s.size = nu;
 920:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 924:	0541                	addi	a0,a0,16
 926:	00000097          	auipc	ra,0x0
 92a:	ebe080e7          	jalr	-322(ra) # 7e4 <free>
  return freep;
 92e:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 930:	d979                	beqz	a0,906 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 932:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 934:	4798                	lw	a4,8(a5)
 936:	fb2777e3          	bleu	s2,a4,8e4 <malloc+0x76>
    if(p == freep)
 93a:	6098                	ld	a4,0(s1)
 93c:	853e                	mv	a0,a5
 93e:	fef71ae3          	bne	a4,a5,932 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 942:	8552                	mv	a0,s4
 944:	00000097          	auipc	ra,0x0
 948:	b6a080e7          	jalr	-1174(ra) # 4ae <sbrk>
  if(p == (char*)-1)
 94c:	fd651ae3          	bne	a0,s6,920 <malloc+0xb2>
        return 0;
 950:	4501                	li	a0,0
 952:	bf55                	j	906 <malloc+0x98>
