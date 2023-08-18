
user/_find：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <basename>:
#include "kernel/fcntl.h"
#include "kernel/fs.h"
#include "kernel/stat.h"
#include "user/user.h"

char *basename(char *pathname) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  char *prev = 0;
  char *curr = strchr(pathname, '/');
   a:	02f00593          	li	a1,47
   e:	00000097          	auipc	ra,0x0
  12:	2ca080e7          	jalr	714(ra) # 2d8 <strchr>
  16:	84aa                	mv	s1,a0
  while (curr != 0) {
  18:	e119                	bnez	a0,1e <basename+0x1e>
  1a:	a819                	j	30 <basename+0x30>
    prev = curr;
    curr = strchr(curr + 1, '/');
  1c:	84aa                	mv	s1,a0
  1e:	02f00593          	li	a1,47
  22:	00148513          	addi	a0,s1,1
  26:	00000097          	auipc	ra,0x0
  2a:	2b2080e7          	jalr	690(ra) # 2d8 <strchr>
  while (curr != 0) {
  2e:	f57d                	bnez	a0,1c <basename+0x1c>
  }
  return prev;
}
  30:	8526                	mv	a0,s1
  32:	60e2                	ld	ra,24(sp)
  34:	6442                	ld	s0,16(sp)
  36:	64a2                	ld	s1,8(sp)
  38:	6105                	addi	sp,sp,32
  3a:	8082                	ret

000000000000003c <find>:

void find(char *curr_path, char *target) {
  3c:	d9010113          	addi	sp,sp,-624
  40:	26113423          	sd	ra,616(sp)
  44:	26813023          	sd	s0,608(sp)
  48:	24913c23          	sd	s1,600(sp)
  4c:	25213823          	sd	s2,592(sp)
  50:	25313423          	sd	s3,584(sp)
  54:	25413023          	sd	s4,576(sp)
  58:	23513c23          	sd	s5,568(sp)
  5c:	23613823          	sd	s6,560(sp)
  60:	1c80                	addi	s0,sp,624
  62:	892a                	mv	s2,a0
  64:	8a2e                	mv	s4,a1
  int fd;
  char *f_name = "";
  int match = 1;
  struct dirent de;
  struct stat st;
  if ((fd = open(curr_path, O_RDONLY)) < 0) {
  66:	4581                	li	a1,0
  68:	00000097          	auipc	ra,0x0
  6c:	4a0080e7          	jalr	1184(ra) # 508 <open>
  70:	04054863          	bltz	a0,c0 <find+0x84>
  74:	84aa                	mv	s1,a0
    fprintf(2, "find: cannot open %s\n", curr_path);
    return;
  }

  if (fstat(fd, &st) < 0) {
  76:	d9840593          	addi	a1,s0,-616
  7a:	00000097          	auipc	ra,0x0
  7e:	4a6080e7          	jalr	1190(ra) # 520 <fstat>
  82:	06054c63          	bltz	a0,fa <find+0xbe>
    fprintf(2, "find: cannot stat %s\n", curr_path);
    close(fd);
    return;
  }

  switch (st.type) {
  86:	da041783          	lh	a5,-608(s0)
  8a:	0007869b          	sext.w	a3,a5
  8e:	4705                	li	a4,1
  90:	08e68f63          	beq	a3,a4,12e <find+0xf2>
  94:	4709                	li	a4,2
  96:	02e69f63          	bne	a3,a4,d4 <find+0x98>

  case T_FILE:
    f_name = basename(curr_path);
  9a:	854a                	mv	a0,s2
  9c:	00000097          	auipc	ra,0x0
  a0:	f64080e7          	jalr	-156(ra) # 0 <basename>
    if (f_name == 0 || strcmp(f_name + 1, target) != 0) {
  a4:	c901                	beqz	a0,b4 <find+0x78>
  a6:	85d2                	mv	a1,s4
  a8:	0505                	addi	a0,a0,1
  aa:	00000097          	auipc	ra,0x0
  ae:	1aa080e7          	jalr	426(ra) # 254 <strcmp>
  b2:	c525                	beqz	a0,11a <find+0xde>
      match = 0;
    }
    if (match)
      printf("%s\n", curr_path);
    close(fd);
  b4:	8526                	mv	a0,s1
  b6:	00000097          	auipc	ra,0x0
  ba:	43a080e7          	jalr	1082(ra) # 4f0 <close>
    break;
  be:	a819                	j	d4 <find+0x98>
    fprintf(2, "find: cannot open %s\n", curr_path);
  c0:	864a                	mv	a2,s2
  c2:	00001597          	auipc	a1,0x1
  c6:	92658593          	addi	a1,a1,-1754 # 9e8 <malloc+0xe8>
  ca:	4509                	li	a0,2
  cc:	00000097          	auipc	ra,0x0
  d0:	746080e7          	jalr	1862(ra) # 812 <fprintf>
      find(buf, target); 
    }
    close(fd);
    break;
  }
}
  d4:	26813083          	ld	ra,616(sp)
  d8:	26013403          	ld	s0,608(sp)
  dc:	25813483          	ld	s1,600(sp)
  e0:	25013903          	ld	s2,592(sp)
  e4:	24813983          	ld	s3,584(sp)
  e8:	24013a03          	ld	s4,576(sp)
  ec:	23813a83          	ld	s5,568(sp)
  f0:	23013b03          	ld	s6,560(sp)
  f4:	27010113          	addi	sp,sp,624
  f8:	8082                	ret
    fprintf(2, "find: cannot stat %s\n", curr_path);
  fa:	864a                	mv	a2,s2
  fc:	00001597          	auipc	a1,0x1
 100:	90458593          	addi	a1,a1,-1788 # a00 <malloc+0x100>
 104:	4509                	li	a0,2
 106:	00000097          	auipc	ra,0x0
 10a:	70c080e7          	jalr	1804(ra) # 812 <fprintf>
    close(fd);
 10e:	8526                	mv	a0,s1
 110:	00000097          	auipc	ra,0x0
 114:	3e0080e7          	jalr	992(ra) # 4f0 <close>
    return;
 118:	bf75                	j	d4 <find+0x98>
      printf("%s\n", curr_path);
 11a:	85ca                	mv	a1,s2
 11c:	00001517          	auipc	a0,0x1
 120:	8fc50513          	addi	a0,a0,-1796 # a18 <malloc+0x118>
 124:	00000097          	auipc	ra,0x0
 128:	71c080e7          	jalr	1820(ra) # 840 <printf>
 12c:	b761                	j	b4 <find+0x78>
    memset(buf, 0, sizeof(buf));
 12e:	20000613          	li	a2,512
 132:	4581                	li	a1,0
 134:	dc040513          	addi	a0,s0,-576
 138:	00000097          	auipc	ra,0x0
 13c:	17a080e7          	jalr	378(ra) # 2b2 <memset>
    uint curr_path_len = strlen(curr_path);
 140:	854a                	mv	a0,s2
 142:	00000097          	auipc	ra,0x0
 146:	146080e7          	jalr	326(ra) # 288 <strlen>
 14a:	0005099b          	sext.w	s3,a0
    memcpy(buf, curr_path, curr_path_len);
 14e:	864e                	mv	a2,s3
 150:	85ca                	mv	a1,s2
 152:	dc040513          	addi	a0,s0,-576
 156:	00000097          	auipc	ra,0x0
 15a:	352080e7          	jalr	850(ra) # 4a8 <memcpy>
    buf[curr_path_len] = '/';
 15e:	1982                	slli	s3,s3,0x20
 160:	0209d993          	srli	s3,s3,0x20
 164:	fc040793          	addi	a5,s0,-64
 168:	97ce                	add	a5,a5,s3
 16a:	02f00713          	li	a4,47
 16e:	e0e78023          	sb	a4,-512(a5)
    p = buf + curr_path_len + 1;
 172:	0985                	addi	s3,s3,1
 174:	dc040793          	addi	a5,s0,-576
 178:	99be                	add	s3,s3,a5
      if (de.inum == 0 || strcmp(de.name, ".") == 0 ||
 17a:	00001a97          	auipc	s5,0x1
 17e:	8a6a8a93          	addi	s5,s5,-1882 # a20 <malloc+0x120>
          strcmp(de.name, "..") == 0)
 182:	00001b17          	auipc	s6,0x1
 186:	8a6b0b13          	addi	s6,s6,-1882 # a28 <malloc+0x128>
      if (de.inum == 0 || strcmp(de.name, ".") == 0 ||
 18a:	db240913          	addi	s2,s0,-590
    while (read(fd, &de, sizeof(de)) == sizeof(de)) {
 18e:	4641                	li	a2,16
 190:	db040593          	addi	a1,s0,-592
 194:	8526                	mv	a0,s1
 196:	00000097          	auipc	ra,0x0
 19a:	34a080e7          	jalr	842(ra) # 4e0 <read>
 19e:	47c1                	li	a5,16
 1a0:	04f51563          	bne	a0,a5,1ea <find+0x1ae>
      if (de.inum == 0 || strcmp(de.name, ".") == 0 ||
 1a4:	db045783          	lhu	a5,-592(s0)
 1a8:	d3fd                	beqz	a5,18e <find+0x152>
 1aa:	85d6                	mv	a1,s5
 1ac:	854a                	mv	a0,s2
 1ae:	00000097          	auipc	ra,0x0
 1b2:	0a6080e7          	jalr	166(ra) # 254 <strcmp>
 1b6:	dd61                	beqz	a0,18e <find+0x152>
          strcmp(de.name, "..") == 0)
 1b8:	85da                	mv	a1,s6
 1ba:	854a                	mv	a0,s2
 1bc:	00000097          	auipc	ra,0x0
 1c0:	098080e7          	jalr	152(ra) # 254 <strcmp>
      if (de.inum == 0 || strcmp(de.name, ".") == 0 ||
 1c4:	d569                	beqz	a0,18e <find+0x152>
      memcpy(p, de.name, DIRSIZ);
 1c6:	4639                	li	a2,14
 1c8:	db240593          	addi	a1,s0,-590
 1cc:	854e                	mv	a0,s3
 1ce:	00000097          	auipc	ra,0x0
 1d2:	2da080e7          	jalr	730(ra) # 4a8 <memcpy>
      p[DIRSIZ] = 0;
 1d6:	00098723          	sb	zero,14(s3)
      find(buf, target); 
 1da:	85d2                	mv	a1,s4
 1dc:	dc040513          	addi	a0,s0,-576
 1e0:	00000097          	auipc	ra,0x0
 1e4:	e5c080e7          	jalr	-420(ra) # 3c <find>
 1e8:	b75d                	j	18e <find+0x152>
    close(fd);
 1ea:	8526                	mv	a0,s1
 1ec:	00000097          	auipc	ra,0x0
 1f0:	304080e7          	jalr	772(ra) # 4f0 <close>
    break;
 1f4:	b5c5                	j	d4 <find+0x98>

00000000000001f6 <main>:

int main(int argc, char *argv[]) {
 1f6:	1141                	addi	sp,sp,-16
 1f8:	e406                	sd	ra,8(sp)
 1fa:	e022                	sd	s0,0(sp)
 1fc:	0800                	addi	s0,sp,16
  if (argc != 3) {
 1fe:	478d                	li	a5,3
 200:	02f50063          	beq	a0,a5,220 <main+0x2a>
    fprintf(2, "usage: find [directory] [target filename]\n");
 204:	00001597          	auipc	a1,0x1
 208:	82c58593          	addi	a1,a1,-2004 # a30 <malloc+0x130>
 20c:	4509                	li	a0,2
 20e:	00000097          	auipc	ra,0x0
 212:	604080e7          	jalr	1540(ra) # 812 <fprintf>
    exit(1);
 216:	4505                	li	a0,1
 218:	00000097          	auipc	ra,0x0
 21c:	2b0080e7          	jalr	688(ra) # 4c8 <exit>
 220:	872e                	mv	a4,a1
  }
  find(argv[1], argv[2]);
 222:	698c                	ld	a1,16(a1)
 224:	6708                	ld	a0,8(a4)
 226:	00000097          	auipc	ra,0x0
 22a:	e16080e7          	jalr	-490(ra) # 3c <find>
  exit(0);
 22e:	4501                	li	a0,0
 230:	00000097          	auipc	ra,0x0
 234:	298080e7          	jalr	664(ra) # 4c8 <exit>

0000000000000238 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 23e:	87aa                	mv	a5,a0
 240:	0585                	addi	a1,a1,1
 242:	0785                	addi	a5,a5,1
 244:	fff5c703          	lbu	a4,-1(a1)
 248:	fee78fa3          	sb	a4,-1(a5)
 24c:	fb75                	bnez	a4,240 <strcpy+0x8>
    ;
  return os;
}
 24e:	6422                	ld	s0,8(sp)
 250:	0141                	addi	sp,sp,16
 252:	8082                	ret

0000000000000254 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 254:	1141                	addi	sp,sp,-16
 256:	e422                	sd	s0,8(sp)
 258:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 25a:	00054783          	lbu	a5,0(a0)
 25e:	cf91                	beqz	a5,27a <strcmp+0x26>
 260:	0005c703          	lbu	a4,0(a1)
 264:	00f71b63          	bne	a4,a5,27a <strcmp+0x26>
    p++, q++;
 268:	0505                	addi	a0,a0,1
 26a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 26c:	00054783          	lbu	a5,0(a0)
 270:	c789                	beqz	a5,27a <strcmp+0x26>
 272:	0005c703          	lbu	a4,0(a1)
 276:	fef709e3          	beq	a4,a5,268 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 27a:	0005c503          	lbu	a0,0(a1)
}
 27e:	40a7853b          	subw	a0,a5,a0
 282:	6422                	ld	s0,8(sp)
 284:	0141                	addi	sp,sp,16
 286:	8082                	ret

0000000000000288 <strlen>:

uint
strlen(const char *s)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e422                	sd	s0,8(sp)
 28c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 28e:	00054783          	lbu	a5,0(a0)
 292:	cf91                	beqz	a5,2ae <strlen+0x26>
 294:	0505                	addi	a0,a0,1
 296:	87aa                	mv	a5,a0
 298:	4685                	li	a3,1
 29a:	9e89                	subw	a3,a3,a0
 29c:	00f6853b          	addw	a0,a3,a5
 2a0:	0785                	addi	a5,a5,1
 2a2:	fff7c703          	lbu	a4,-1(a5)
 2a6:	fb7d                	bnez	a4,29c <strlen+0x14>
    ;
  return n;
}
 2a8:	6422                	ld	s0,8(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret
  for(n = 0; s[n]; n++)
 2ae:	4501                	li	a0,0
 2b0:	bfe5                	j	2a8 <strlen+0x20>

00000000000002b2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e422                	sd	s0,8(sp)
 2b6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2b8:	ce09                	beqz	a2,2d2 <memset+0x20>
 2ba:	87aa                	mv	a5,a0
 2bc:	fff6071b          	addiw	a4,a2,-1
 2c0:	1702                	slli	a4,a4,0x20
 2c2:	9301                	srli	a4,a4,0x20
 2c4:	0705                	addi	a4,a4,1
 2c6:	972a                	add	a4,a4,a0
    cdst[i] = c;
 2c8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2cc:	0785                	addi	a5,a5,1
 2ce:	fee79de3          	bne	a5,a4,2c8 <memset+0x16>
  }
  return dst;
}
 2d2:	6422                	ld	s0,8(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret

00000000000002d8 <strchr>:

char*
strchr(const char *s, char c)
{
 2d8:	1141                	addi	sp,sp,-16
 2da:	e422                	sd	s0,8(sp)
 2dc:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2de:	00054783          	lbu	a5,0(a0)
 2e2:	cf91                	beqz	a5,2fe <strchr+0x26>
    if(*s == c)
 2e4:	00f58a63          	beq	a1,a5,2f8 <strchr+0x20>
  for(; *s; s++)
 2e8:	0505                	addi	a0,a0,1
 2ea:	00054783          	lbu	a5,0(a0)
 2ee:	c781                	beqz	a5,2f6 <strchr+0x1e>
    if(*s == c)
 2f0:	feb79ce3          	bne	a5,a1,2e8 <strchr+0x10>
 2f4:	a011                	j	2f8 <strchr+0x20>
      return (char*)s;
  return 0;
 2f6:	4501                	li	a0,0
}
 2f8:	6422                	ld	s0,8(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret
  return 0;
 2fe:	4501                	li	a0,0
 300:	bfe5                	j	2f8 <strchr+0x20>

0000000000000302 <gets>:

char*
gets(char *buf, int max)
{
 302:	711d                	addi	sp,sp,-96
 304:	ec86                	sd	ra,88(sp)
 306:	e8a2                	sd	s0,80(sp)
 308:	e4a6                	sd	s1,72(sp)
 30a:	e0ca                	sd	s2,64(sp)
 30c:	fc4e                	sd	s3,56(sp)
 30e:	f852                	sd	s4,48(sp)
 310:	f456                	sd	s5,40(sp)
 312:	f05a                	sd	s6,32(sp)
 314:	ec5e                	sd	s7,24(sp)
 316:	1080                	addi	s0,sp,96
 318:	8baa                	mv	s7,a0
 31a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 31c:	892a                	mv	s2,a0
 31e:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 320:	4aa9                	li	s5,10
 322:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 324:	0019849b          	addiw	s1,s3,1
 328:	0344d863          	ble	s4,s1,358 <gets+0x56>
    cc = read(0, &c, 1);
 32c:	4605                	li	a2,1
 32e:	faf40593          	addi	a1,s0,-81
 332:	4501                	li	a0,0
 334:	00000097          	auipc	ra,0x0
 338:	1ac080e7          	jalr	428(ra) # 4e0 <read>
    if(cc < 1)
 33c:	00a05e63          	blez	a0,358 <gets+0x56>
    buf[i++] = c;
 340:	faf44783          	lbu	a5,-81(s0)
 344:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 348:	01578763          	beq	a5,s5,356 <gets+0x54>
 34c:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 34e:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 350:	fd679ae3          	bne	a5,s6,324 <gets+0x22>
 354:	a011                	j	358 <gets+0x56>
  for(i=0; i+1 < max; ){
 356:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 358:	99de                	add	s3,s3,s7
 35a:	00098023          	sb	zero,0(s3)
  return buf;
}
 35e:	855e                	mv	a0,s7
 360:	60e6                	ld	ra,88(sp)
 362:	6446                	ld	s0,80(sp)
 364:	64a6                	ld	s1,72(sp)
 366:	6906                	ld	s2,64(sp)
 368:	79e2                	ld	s3,56(sp)
 36a:	7a42                	ld	s4,48(sp)
 36c:	7aa2                	ld	s5,40(sp)
 36e:	7b02                	ld	s6,32(sp)
 370:	6be2                	ld	s7,24(sp)
 372:	6125                	addi	sp,sp,96
 374:	8082                	ret

0000000000000376 <stat>:

int
stat(const char *n, struct stat *st)
{
 376:	1101                	addi	sp,sp,-32
 378:	ec06                	sd	ra,24(sp)
 37a:	e822                	sd	s0,16(sp)
 37c:	e426                	sd	s1,8(sp)
 37e:	e04a                	sd	s2,0(sp)
 380:	1000                	addi	s0,sp,32
 382:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 384:	4581                	li	a1,0
 386:	00000097          	auipc	ra,0x0
 38a:	182080e7          	jalr	386(ra) # 508 <open>
  if(fd < 0)
 38e:	02054563          	bltz	a0,3b8 <stat+0x42>
 392:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 394:	85ca                	mv	a1,s2
 396:	00000097          	auipc	ra,0x0
 39a:	18a080e7          	jalr	394(ra) # 520 <fstat>
 39e:	892a                	mv	s2,a0
  close(fd);
 3a0:	8526                	mv	a0,s1
 3a2:	00000097          	auipc	ra,0x0
 3a6:	14e080e7          	jalr	334(ra) # 4f0 <close>
  return r;
}
 3aa:	854a                	mv	a0,s2
 3ac:	60e2                	ld	ra,24(sp)
 3ae:	6442                	ld	s0,16(sp)
 3b0:	64a2                	ld	s1,8(sp)
 3b2:	6902                	ld	s2,0(sp)
 3b4:	6105                	addi	sp,sp,32
 3b6:	8082                	ret
    return -1;
 3b8:	597d                	li	s2,-1
 3ba:	bfc5                	j	3aa <stat+0x34>

00000000000003bc <atoi>:

int
atoi(const char *s)
{
 3bc:	1141                	addi	sp,sp,-16
 3be:	e422                	sd	s0,8(sp)
 3c0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3c2:	00054683          	lbu	a3,0(a0)
 3c6:	fd06879b          	addiw	a5,a3,-48
 3ca:	0ff7f793          	andi	a5,a5,255
 3ce:	4725                	li	a4,9
 3d0:	02f76963          	bltu	a4,a5,402 <atoi+0x46>
 3d4:	862a                	mv	a2,a0
  n = 0;
 3d6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3d8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3da:	0605                	addi	a2,a2,1
 3dc:	0025179b          	slliw	a5,a0,0x2
 3e0:	9fa9                	addw	a5,a5,a0
 3e2:	0017979b          	slliw	a5,a5,0x1
 3e6:	9fb5                	addw	a5,a5,a3
 3e8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3ec:	00064683          	lbu	a3,0(a2)
 3f0:	fd06871b          	addiw	a4,a3,-48
 3f4:	0ff77713          	andi	a4,a4,255
 3f8:	fee5f1e3          	bleu	a4,a1,3da <atoi+0x1e>
  return n;
}
 3fc:	6422                	ld	s0,8(sp)
 3fe:	0141                	addi	sp,sp,16
 400:	8082                	ret
  n = 0;
 402:	4501                	li	a0,0
 404:	bfe5                	j	3fc <atoi+0x40>

0000000000000406 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 406:	1141                	addi	sp,sp,-16
 408:	e422                	sd	s0,8(sp)
 40a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 40c:	02b57663          	bleu	a1,a0,438 <memmove+0x32>
    while(n-- > 0)
 410:	02c05163          	blez	a2,432 <memmove+0x2c>
 414:	fff6079b          	addiw	a5,a2,-1
 418:	1782                	slli	a5,a5,0x20
 41a:	9381                	srli	a5,a5,0x20
 41c:	0785                	addi	a5,a5,1
 41e:	97aa                	add	a5,a5,a0
  dst = vdst;
 420:	872a                	mv	a4,a0
      *dst++ = *src++;
 422:	0585                	addi	a1,a1,1
 424:	0705                	addi	a4,a4,1
 426:	fff5c683          	lbu	a3,-1(a1)
 42a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 42e:	fee79ae3          	bne	a5,a4,422 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 432:	6422                	ld	s0,8(sp)
 434:	0141                	addi	sp,sp,16
 436:	8082                	ret
    dst += n;
 438:	00c50733          	add	a4,a0,a2
    src += n;
 43c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 43e:	fec05ae3          	blez	a2,432 <memmove+0x2c>
 442:	fff6079b          	addiw	a5,a2,-1
 446:	1782                	slli	a5,a5,0x20
 448:	9381                	srli	a5,a5,0x20
 44a:	fff7c793          	not	a5,a5
 44e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 450:	15fd                	addi	a1,a1,-1
 452:	177d                	addi	a4,a4,-1
 454:	0005c683          	lbu	a3,0(a1)
 458:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 45c:	fef71ae3          	bne	a4,a5,450 <memmove+0x4a>
 460:	bfc9                	j	432 <memmove+0x2c>

0000000000000462 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 462:	1141                	addi	sp,sp,-16
 464:	e422                	sd	s0,8(sp)
 466:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 468:	ce15                	beqz	a2,4a4 <memcmp+0x42>
 46a:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 46e:	00054783          	lbu	a5,0(a0)
 472:	0005c703          	lbu	a4,0(a1)
 476:	02e79063          	bne	a5,a4,496 <memcmp+0x34>
 47a:	1682                	slli	a3,a3,0x20
 47c:	9281                	srli	a3,a3,0x20
 47e:	0685                	addi	a3,a3,1
 480:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 482:	0505                	addi	a0,a0,1
    p2++;
 484:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 486:	00d50d63          	beq	a0,a3,4a0 <memcmp+0x3e>
    if (*p1 != *p2) {
 48a:	00054783          	lbu	a5,0(a0)
 48e:	0005c703          	lbu	a4,0(a1)
 492:	fee788e3          	beq	a5,a4,482 <memcmp+0x20>
      return *p1 - *p2;
 496:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 49a:	6422                	ld	s0,8(sp)
 49c:	0141                	addi	sp,sp,16
 49e:	8082                	ret
  return 0;
 4a0:	4501                	li	a0,0
 4a2:	bfe5                	j	49a <memcmp+0x38>
 4a4:	4501                	li	a0,0
 4a6:	bfd5                	j	49a <memcmp+0x38>

00000000000004a8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4a8:	1141                	addi	sp,sp,-16
 4aa:	e406                	sd	ra,8(sp)
 4ac:	e022                	sd	s0,0(sp)
 4ae:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4b0:	00000097          	auipc	ra,0x0
 4b4:	f56080e7          	jalr	-170(ra) # 406 <memmove>
}
 4b8:	60a2                	ld	ra,8(sp)
 4ba:	6402                	ld	s0,0(sp)
 4bc:	0141                	addi	sp,sp,16
 4be:	8082                	ret

00000000000004c0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4c0:	4885                	li	a7,1
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4c8:	4889                	li	a7,2
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4d0:	488d                	li	a7,3
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4d8:	4891                	li	a7,4
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <read>:
.global read
read:
 li a7, SYS_read
 4e0:	4895                	li	a7,5
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <write>:
.global write
write:
 li a7, SYS_write
 4e8:	48c1                	li	a7,16
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <close>:
.global close
close:
 li a7, SYS_close
 4f0:	48d5                	li	a7,21
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4f8:	4899                	li	a7,6
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <exec>:
.global exec
exec:
 li a7, SYS_exec
 500:	489d                	li	a7,7
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <open>:
.global open
open:
 li a7, SYS_open
 508:	48bd                	li	a7,15
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 510:	48c5                	li	a7,17
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 518:	48c9                	li	a7,18
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 520:	48a1                	li	a7,8
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <link>:
.global link
link:
 li a7, SYS_link
 528:	48cd                	li	a7,19
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 530:	48d1                	li	a7,20
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 538:	48a5                	li	a7,9
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <dup>:
.global dup
dup:
 li a7, SYS_dup
 540:	48a9                	li	a7,10
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 548:	48ad                	li	a7,11
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 550:	48b1                	li	a7,12
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 558:	48b5                	li	a7,13
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 560:	48b9                	li	a7,14
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 568:	1101                	addi	sp,sp,-32
 56a:	ec06                	sd	ra,24(sp)
 56c:	e822                	sd	s0,16(sp)
 56e:	1000                	addi	s0,sp,32
 570:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 574:	4605                	li	a2,1
 576:	fef40593          	addi	a1,s0,-17
 57a:	00000097          	auipc	ra,0x0
 57e:	f6e080e7          	jalr	-146(ra) # 4e8 <write>
}
 582:	60e2                	ld	ra,24(sp)
 584:	6442                	ld	s0,16(sp)
 586:	6105                	addi	sp,sp,32
 588:	8082                	ret

000000000000058a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 58a:	7139                	addi	sp,sp,-64
 58c:	fc06                	sd	ra,56(sp)
 58e:	f822                	sd	s0,48(sp)
 590:	f426                	sd	s1,40(sp)
 592:	f04a                	sd	s2,32(sp)
 594:	ec4e                	sd	s3,24(sp)
 596:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 598:	c299                	beqz	a3,59e <printint+0x14>
 59a:	0005cd63          	bltz	a1,5b4 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 59e:	2581                	sext.w	a1,a1
  neg = 0;
 5a0:	4301                	li	t1,0
 5a2:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 5a6:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 5a8:	2601                	sext.w	a2,a2
 5aa:	00000897          	auipc	a7,0x0
 5ae:	4b688893          	addi	a7,a7,1206 # a60 <digits>
 5b2:	a801                	j	5c2 <printint+0x38>
    x = -xx;
 5b4:	40b005bb          	negw	a1,a1
 5b8:	2581                	sext.w	a1,a1
    neg = 1;
 5ba:	4305                	li	t1,1
    x = -xx;
 5bc:	b7dd                	j	5a2 <printint+0x18>
  }while((x /= base) != 0);
 5be:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 5c0:	8836                	mv	a6,a3
 5c2:	0018069b          	addiw	a3,a6,1
 5c6:	02c5f7bb          	remuw	a5,a1,a2
 5ca:	1782                	slli	a5,a5,0x20
 5cc:	9381                	srli	a5,a5,0x20
 5ce:	97c6                	add	a5,a5,a7
 5d0:	0007c783          	lbu	a5,0(a5)
 5d4:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 5d8:	0705                	addi	a4,a4,1
 5da:	02c5d7bb          	divuw	a5,a1,a2
 5de:	fec5f0e3          	bleu	a2,a1,5be <printint+0x34>
  if(neg)
 5e2:	00030b63          	beqz	t1,5f8 <printint+0x6e>
    buf[i++] = '-';
 5e6:	fd040793          	addi	a5,s0,-48
 5ea:	96be                	add	a3,a3,a5
 5ec:	02d00793          	li	a5,45
 5f0:	fef68823          	sb	a5,-16(a3)
 5f4:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 5f8:	02d05963          	blez	a3,62a <printint+0xa0>
 5fc:	89aa                	mv	s3,a0
 5fe:	fc040793          	addi	a5,s0,-64
 602:	00d784b3          	add	s1,a5,a3
 606:	fff78913          	addi	s2,a5,-1
 60a:	9936                	add	s2,s2,a3
 60c:	36fd                	addiw	a3,a3,-1
 60e:	1682                	slli	a3,a3,0x20
 610:	9281                	srli	a3,a3,0x20
 612:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 616:	fff4c583          	lbu	a1,-1(s1)
 61a:	854e                	mv	a0,s3
 61c:	00000097          	auipc	ra,0x0
 620:	f4c080e7          	jalr	-180(ra) # 568 <putc>
  while(--i >= 0)
 624:	14fd                	addi	s1,s1,-1
 626:	ff2498e3          	bne	s1,s2,616 <printint+0x8c>
}
 62a:	70e2                	ld	ra,56(sp)
 62c:	7442                	ld	s0,48(sp)
 62e:	74a2                	ld	s1,40(sp)
 630:	7902                	ld	s2,32(sp)
 632:	69e2                	ld	s3,24(sp)
 634:	6121                	addi	sp,sp,64
 636:	8082                	ret

0000000000000638 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 638:	7119                	addi	sp,sp,-128
 63a:	fc86                	sd	ra,120(sp)
 63c:	f8a2                	sd	s0,112(sp)
 63e:	f4a6                	sd	s1,104(sp)
 640:	f0ca                	sd	s2,96(sp)
 642:	ecce                	sd	s3,88(sp)
 644:	e8d2                	sd	s4,80(sp)
 646:	e4d6                	sd	s5,72(sp)
 648:	e0da                	sd	s6,64(sp)
 64a:	fc5e                	sd	s7,56(sp)
 64c:	f862                	sd	s8,48(sp)
 64e:	f466                	sd	s9,40(sp)
 650:	f06a                	sd	s10,32(sp)
 652:	ec6e                	sd	s11,24(sp)
 654:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 656:	0005c483          	lbu	s1,0(a1)
 65a:	18048d63          	beqz	s1,7f4 <vprintf+0x1bc>
 65e:	8aaa                	mv	s5,a0
 660:	8b32                	mv	s6,a2
 662:	00158913          	addi	s2,a1,1
  state = 0;
 666:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 668:	02500a13          	li	s4,37
      if(c == 'd'){
 66c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 670:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 674:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 678:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 67c:	00000b97          	auipc	s7,0x0
 680:	3e4b8b93          	addi	s7,s7,996 # a60 <digits>
 684:	a839                	j	6a2 <vprintf+0x6a>
        putc(fd, c);
 686:	85a6                	mv	a1,s1
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	ede080e7          	jalr	-290(ra) # 568 <putc>
 692:	a019                	j	698 <vprintf+0x60>
    } else if(state == '%'){
 694:	01498f63          	beq	s3,s4,6b2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 698:	0905                	addi	s2,s2,1
 69a:	fff94483          	lbu	s1,-1(s2)
 69e:	14048b63          	beqz	s1,7f4 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 6a2:	0004879b          	sext.w	a5,s1
    if(state == 0){
 6a6:	fe0997e3          	bnez	s3,694 <vprintf+0x5c>
      if(c == '%'){
 6aa:	fd479ee3          	bne	a5,s4,686 <vprintf+0x4e>
        state = '%';
 6ae:	89be                	mv	s3,a5
 6b0:	b7e5                	j	698 <vprintf+0x60>
      if(c == 'd'){
 6b2:	05878063          	beq	a5,s8,6f2 <vprintf+0xba>
      } else if(c == 'l') {
 6b6:	05978c63          	beq	a5,s9,70e <vprintf+0xd6>
      } else if(c == 'x') {
 6ba:	07a78863          	beq	a5,s10,72a <vprintf+0xf2>
      } else if(c == 'p') {
 6be:	09b78463          	beq	a5,s11,746 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6c2:	07300713          	li	a4,115
 6c6:	0ce78563          	beq	a5,a4,790 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6ca:	06300713          	li	a4,99
 6ce:	0ee78c63          	beq	a5,a4,7c6 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6d2:	11478663          	beq	a5,s4,7de <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6d6:	85d2                	mv	a1,s4
 6d8:	8556                	mv	a0,s5
 6da:	00000097          	auipc	ra,0x0
 6de:	e8e080e7          	jalr	-370(ra) # 568 <putc>
        putc(fd, c);
 6e2:	85a6                	mv	a1,s1
 6e4:	8556                	mv	a0,s5
 6e6:	00000097          	auipc	ra,0x0
 6ea:	e82080e7          	jalr	-382(ra) # 568 <putc>
      }
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	b765                	j	698 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6f2:	008b0493          	addi	s1,s6,8
 6f6:	4685                	li	a3,1
 6f8:	4629                	li	a2,10
 6fa:	000b2583          	lw	a1,0(s6)
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	e8a080e7          	jalr	-374(ra) # 58a <printint>
 708:	8b26                	mv	s6,s1
      state = 0;
 70a:	4981                	li	s3,0
 70c:	b771                	j	698 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70e:	008b0493          	addi	s1,s6,8
 712:	4681                	li	a3,0
 714:	4629                	li	a2,10
 716:	000b2583          	lw	a1,0(s6)
 71a:	8556                	mv	a0,s5
 71c:	00000097          	auipc	ra,0x0
 720:	e6e080e7          	jalr	-402(ra) # 58a <printint>
 724:	8b26                	mv	s6,s1
      state = 0;
 726:	4981                	li	s3,0
 728:	bf85                	j	698 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 72a:	008b0493          	addi	s1,s6,8
 72e:	4681                	li	a3,0
 730:	4641                	li	a2,16
 732:	000b2583          	lw	a1,0(s6)
 736:	8556                	mv	a0,s5
 738:	00000097          	auipc	ra,0x0
 73c:	e52080e7          	jalr	-430(ra) # 58a <printint>
 740:	8b26                	mv	s6,s1
      state = 0;
 742:	4981                	li	s3,0
 744:	bf91                	j	698 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 746:	008b0793          	addi	a5,s6,8
 74a:	f8f43423          	sd	a5,-120(s0)
 74e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 752:	03000593          	li	a1,48
 756:	8556                	mv	a0,s5
 758:	00000097          	auipc	ra,0x0
 75c:	e10080e7          	jalr	-496(ra) # 568 <putc>
  putc(fd, 'x');
 760:	85ea                	mv	a1,s10
 762:	8556                	mv	a0,s5
 764:	00000097          	auipc	ra,0x0
 768:	e04080e7          	jalr	-508(ra) # 568 <putc>
 76c:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 76e:	03c9d793          	srli	a5,s3,0x3c
 772:	97de                	add	a5,a5,s7
 774:	0007c583          	lbu	a1,0(a5)
 778:	8556                	mv	a0,s5
 77a:	00000097          	auipc	ra,0x0
 77e:	dee080e7          	jalr	-530(ra) # 568 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 782:	0992                	slli	s3,s3,0x4
 784:	34fd                	addiw	s1,s1,-1
 786:	f4e5                	bnez	s1,76e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 788:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 78c:	4981                	li	s3,0
 78e:	b729                	j	698 <vprintf+0x60>
        s = va_arg(ap, char*);
 790:	008b0993          	addi	s3,s6,8
 794:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 798:	c085                	beqz	s1,7b8 <vprintf+0x180>
        while(*s != 0){
 79a:	0004c583          	lbu	a1,0(s1)
 79e:	c9a1                	beqz	a1,7ee <vprintf+0x1b6>
          putc(fd, *s);
 7a0:	8556                	mv	a0,s5
 7a2:	00000097          	auipc	ra,0x0
 7a6:	dc6080e7          	jalr	-570(ra) # 568 <putc>
          s++;
 7aa:	0485                	addi	s1,s1,1
        while(*s != 0){
 7ac:	0004c583          	lbu	a1,0(s1)
 7b0:	f9e5                	bnez	a1,7a0 <vprintf+0x168>
        s = va_arg(ap, char*);
 7b2:	8b4e                	mv	s6,s3
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	b5cd                	j	698 <vprintf+0x60>
          s = "(null)";
 7b8:	00000497          	auipc	s1,0x0
 7bc:	2c048493          	addi	s1,s1,704 # a78 <digits+0x18>
        while(*s != 0){
 7c0:	02800593          	li	a1,40
 7c4:	bff1                	j	7a0 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 7c6:	008b0493          	addi	s1,s6,8
 7ca:	000b4583          	lbu	a1,0(s6)
 7ce:	8556                	mv	a0,s5
 7d0:	00000097          	auipc	ra,0x0
 7d4:	d98080e7          	jalr	-616(ra) # 568 <putc>
 7d8:	8b26                	mv	s6,s1
      state = 0;
 7da:	4981                	li	s3,0
 7dc:	bd75                	j	698 <vprintf+0x60>
        putc(fd, c);
 7de:	85d2                	mv	a1,s4
 7e0:	8556                	mv	a0,s5
 7e2:	00000097          	auipc	ra,0x0
 7e6:	d86080e7          	jalr	-634(ra) # 568 <putc>
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	b575                	j	698 <vprintf+0x60>
        s = va_arg(ap, char*);
 7ee:	8b4e                	mv	s6,s3
      state = 0;
 7f0:	4981                	li	s3,0
 7f2:	b55d                	j	698 <vprintf+0x60>
    }
  }
}
 7f4:	70e6                	ld	ra,120(sp)
 7f6:	7446                	ld	s0,112(sp)
 7f8:	74a6                	ld	s1,104(sp)
 7fa:	7906                	ld	s2,96(sp)
 7fc:	69e6                	ld	s3,88(sp)
 7fe:	6a46                	ld	s4,80(sp)
 800:	6aa6                	ld	s5,72(sp)
 802:	6b06                	ld	s6,64(sp)
 804:	7be2                	ld	s7,56(sp)
 806:	7c42                	ld	s8,48(sp)
 808:	7ca2                	ld	s9,40(sp)
 80a:	7d02                	ld	s10,32(sp)
 80c:	6de2                	ld	s11,24(sp)
 80e:	6109                	addi	sp,sp,128
 810:	8082                	ret

0000000000000812 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 812:	715d                	addi	sp,sp,-80
 814:	ec06                	sd	ra,24(sp)
 816:	e822                	sd	s0,16(sp)
 818:	1000                	addi	s0,sp,32
 81a:	e010                	sd	a2,0(s0)
 81c:	e414                	sd	a3,8(s0)
 81e:	e818                	sd	a4,16(s0)
 820:	ec1c                	sd	a5,24(s0)
 822:	03043023          	sd	a6,32(s0)
 826:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 82a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 82e:	8622                	mv	a2,s0
 830:	00000097          	auipc	ra,0x0
 834:	e08080e7          	jalr	-504(ra) # 638 <vprintf>
}
 838:	60e2                	ld	ra,24(sp)
 83a:	6442                	ld	s0,16(sp)
 83c:	6161                	addi	sp,sp,80
 83e:	8082                	ret

0000000000000840 <printf>:

void
printf(const char *fmt, ...)
{
 840:	711d                	addi	sp,sp,-96
 842:	ec06                	sd	ra,24(sp)
 844:	e822                	sd	s0,16(sp)
 846:	1000                	addi	s0,sp,32
 848:	e40c                	sd	a1,8(s0)
 84a:	e810                	sd	a2,16(s0)
 84c:	ec14                	sd	a3,24(s0)
 84e:	f018                	sd	a4,32(s0)
 850:	f41c                	sd	a5,40(s0)
 852:	03043823          	sd	a6,48(s0)
 856:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 85a:	00840613          	addi	a2,s0,8
 85e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 862:	85aa                	mv	a1,a0
 864:	4505                	li	a0,1
 866:	00000097          	auipc	ra,0x0
 86a:	dd2080e7          	jalr	-558(ra) # 638 <vprintf>
}
 86e:	60e2                	ld	ra,24(sp)
 870:	6442                	ld	s0,16(sp)
 872:	6125                	addi	sp,sp,96
 874:	8082                	ret

0000000000000876 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 876:	1141                	addi	sp,sp,-16
 878:	e422                	sd	s0,8(sp)
 87a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 87c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 880:	00000797          	auipc	a5,0x0
 884:	20078793          	addi	a5,a5,512 # a80 <__bss_start>
 888:	639c                	ld	a5,0(a5)
 88a:	a805                	j	8ba <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 88c:	4618                	lw	a4,8(a2)
 88e:	9db9                	addw	a1,a1,a4
 890:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 894:	6398                	ld	a4,0(a5)
 896:	6318                	ld	a4,0(a4)
 898:	fee53823          	sd	a4,-16(a0)
 89c:	a091                	j	8e0 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 89e:	ff852703          	lw	a4,-8(a0)
 8a2:	9e39                	addw	a2,a2,a4
 8a4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8a6:	ff053703          	ld	a4,-16(a0)
 8aa:	e398                	sd	a4,0(a5)
 8ac:	a099                	j	8f2 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ae:	6398                	ld	a4,0(a5)
 8b0:	00e7e463          	bltu	a5,a4,8b8 <free+0x42>
 8b4:	00e6ea63          	bltu	a3,a4,8c8 <free+0x52>
{
 8b8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ba:	fed7fae3          	bleu	a3,a5,8ae <free+0x38>
 8be:	6398                	ld	a4,0(a5)
 8c0:	00e6e463          	bltu	a3,a4,8c8 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c4:	fee7eae3          	bltu	a5,a4,8b8 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 8c8:	ff852583          	lw	a1,-8(a0)
 8cc:	6390                	ld	a2,0(a5)
 8ce:	02059713          	slli	a4,a1,0x20
 8d2:	9301                	srli	a4,a4,0x20
 8d4:	0712                	slli	a4,a4,0x4
 8d6:	9736                	add	a4,a4,a3
 8d8:	fae60ae3          	beq	a2,a4,88c <free+0x16>
    bp->s.ptr = p->s.ptr;
 8dc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8e0:	4790                	lw	a2,8(a5)
 8e2:	02061713          	slli	a4,a2,0x20
 8e6:	9301                	srli	a4,a4,0x20
 8e8:	0712                	slli	a4,a4,0x4
 8ea:	973e                	add	a4,a4,a5
 8ec:	fae689e3          	beq	a3,a4,89e <free+0x28>
  } else
    p->s.ptr = bp;
 8f0:	e394                	sd	a3,0(a5)
  freep = p;
 8f2:	00000717          	auipc	a4,0x0
 8f6:	18f73723          	sd	a5,398(a4) # a80 <__bss_start>
}
 8fa:	6422                	ld	s0,8(sp)
 8fc:	0141                	addi	sp,sp,16
 8fe:	8082                	ret

0000000000000900 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 900:	7139                	addi	sp,sp,-64
 902:	fc06                	sd	ra,56(sp)
 904:	f822                	sd	s0,48(sp)
 906:	f426                	sd	s1,40(sp)
 908:	f04a                	sd	s2,32(sp)
 90a:	ec4e                	sd	s3,24(sp)
 90c:	e852                	sd	s4,16(sp)
 90e:	e456                	sd	s5,8(sp)
 910:	e05a                	sd	s6,0(sp)
 912:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 914:	02051993          	slli	s3,a0,0x20
 918:	0209d993          	srli	s3,s3,0x20
 91c:	09bd                	addi	s3,s3,15
 91e:	0049d993          	srli	s3,s3,0x4
 922:	2985                	addiw	s3,s3,1
 924:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 928:	00000797          	auipc	a5,0x0
 92c:	15878793          	addi	a5,a5,344 # a80 <__bss_start>
 930:	6388                	ld	a0,0(a5)
 932:	c515                	beqz	a0,95e <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 934:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 936:	4798                	lw	a4,8(a5)
 938:	03277f63          	bleu	s2,a4,976 <malloc+0x76>
 93c:	8a4e                	mv	s4,s3
 93e:	0009871b          	sext.w	a4,s3
 942:	6685                	lui	a3,0x1
 944:	00d77363          	bleu	a3,a4,94a <malloc+0x4a>
 948:	6a05                	lui	s4,0x1
 94a:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 94e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 952:	00000497          	auipc	s1,0x0
 956:	12e48493          	addi	s1,s1,302 # a80 <__bss_start>
  if(p == (char*)-1)
 95a:	5b7d                	li	s6,-1
 95c:	a885                	j	9cc <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 95e:	00000797          	auipc	a5,0x0
 962:	12a78793          	addi	a5,a5,298 # a88 <base>
 966:	00000717          	auipc	a4,0x0
 96a:	10f73d23          	sd	a5,282(a4) # a80 <__bss_start>
 96e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 970:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 974:	b7e1                	j	93c <malloc+0x3c>
      if(p->s.size == nunits)
 976:	02e90b63          	beq	s2,a4,9ac <malloc+0xac>
        p->s.size -= nunits;
 97a:	4137073b          	subw	a4,a4,s3
 97e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 980:	1702                	slli	a4,a4,0x20
 982:	9301                	srli	a4,a4,0x20
 984:	0712                	slli	a4,a4,0x4
 986:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 988:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 98c:	00000717          	auipc	a4,0x0
 990:	0ea73a23          	sd	a0,244(a4) # a80 <__bss_start>
      return (void*)(p + 1);
 994:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 998:	70e2                	ld	ra,56(sp)
 99a:	7442                	ld	s0,48(sp)
 99c:	74a2                	ld	s1,40(sp)
 99e:	7902                	ld	s2,32(sp)
 9a0:	69e2                	ld	s3,24(sp)
 9a2:	6a42                	ld	s4,16(sp)
 9a4:	6aa2                	ld	s5,8(sp)
 9a6:	6b02                	ld	s6,0(sp)
 9a8:	6121                	addi	sp,sp,64
 9aa:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9ac:	6398                	ld	a4,0(a5)
 9ae:	e118                	sd	a4,0(a0)
 9b0:	bff1                	j	98c <malloc+0x8c>
  hp->s.size = nu;
 9b2:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 9b6:	0541                	addi	a0,a0,16
 9b8:	00000097          	auipc	ra,0x0
 9bc:	ebe080e7          	jalr	-322(ra) # 876 <free>
  return freep;
 9c0:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 9c2:	d979                	beqz	a0,998 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9c6:	4798                	lw	a4,8(a5)
 9c8:	fb2777e3          	bleu	s2,a4,976 <malloc+0x76>
    if(p == freep)
 9cc:	6098                	ld	a4,0(s1)
 9ce:	853e                	mv	a0,a5
 9d0:	fef71ae3          	bne	a4,a5,9c4 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 9d4:	8552                	mv	a0,s4
 9d6:	00000097          	auipc	ra,0x0
 9da:	b7a080e7          	jalr	-1158(ra) # 550 <sbrk>
  if(p == (char*)-1)
 9de:	fd651ae3          	bne	a0,s6,9b2 <malloc+0xb2>
        return 0;
 9e2:	4501                	li	a0,0
 9e4:	bf55                	j	998 <malloc+0x98>
