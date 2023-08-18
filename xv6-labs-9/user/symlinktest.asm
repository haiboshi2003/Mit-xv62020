
user/_symlinktest：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <stat_slink>:
}

// stat a symbolic link using O_NOFOLLOW
static int
stat_slink(char *pn, struct stat *st)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84ae                	mv	s1,a1
  int fd = open(pn, O_RDONLY | O_NOFOLLOW);
   c:	6585                	lui	a1,0x1
   e:	80058593          	addi	a1,a1,-2048 # 800 <gets+0x5a>
  12:	00001097          	auipc	ra,0x1
  16:	99a080e7          	jalr	-1638(ra) # 9ac <open>
  if(fd < 0)
  1a:	02054163          	bltz	a0,3c <stat_slink+0x3c>
    return -1;
  if(fstat(fd, st) != 0)
  1e:	85a6                	mv	a1,s1
  20:	00001097          	auipc	ra,0x1
  24:	9a4080e7          	jalr	-1628(ra) # 9c4 <fstat>
  28:	00a03533          	snez	a0,a0
  2c:	40a0053b          	negw	a0,a0
  30:	2501                	sext.w	a0,a0
    return -1;
  return 0;
}
  32:	60e2                	ld	ra,24(sp)
  34:	6442                	ld	s0,16(sp)
  36:	64a2                	ld	s1,8(sp)
  38:	6105                	addi	sp,sp,32
  3a:	8082                	ret
    return -1;
  3c:	557d                	li	a0,-1
  3e:	bfd5                	j	32 <stat_slink+0x32>

0000000000000040 <main>:
{
  40:	7119                	addi	sp,sp,-128
  42:	fc86                	sd	ra,120(sp)
  44:	f8a2                	sd	s0,112(sp)
  46:	f4a6                	sd	s1,104(sp)
  48:	f0ca                	sd	s2,96(sp)
  4a:	ecce                	sd	s3,88(sp)
  4c:	e8d2                	sd	s4,80(sp)
  4e:	e4d6                	sd	s5,72(sp)
  50:	e0da                	sd	s6,64(sp)
  52:	fc5e                	sd	s7,56(sp)
  54:	f862                	sd	s8,48(sp)
  56:	0100                	addi	s0,sp,128
  unlink("/testsymlink/a");
  58:	00001517          	auipc	a0,0x1
  5c:	e4050513          	addi	a0,a0,-448 # e98 <malloc+0xec>
  60:	00001097          	auipc	ra,0x1
  64:	95c080e7          	jalr	-1700(ra) # 9bc <unlink>
  unlink("/testsymlink/b");
  68:	00001517          	auipc	a0,0x1
  6c:	e4050513          	addi	a0,a0,-448 # ea8 <malloc+0xfc>
  70:	00001097          	auipc	ra,0x1
  74:	94c080e7          	jalr	-1716(ra) # 9bc <unlink>
  unlink("/testsymlink/c");
  78:	00001517          	auipc	a0,0x1
  7c:	e4050513          	addi	a0,a0,-448 # eb8 <malloc+0x10c>
  80:	00001097          	auipc	ra,0x1
  84:	93c080e7          	jalr	-1732(ra) # 9bc <unlink>
  unlink("/testsymlink/1");
  88:	00001517          	auipc	a0,0x1
  8c:	e4050513          	addi	a0,a0,-448 # ec8 <malloc+0x11c>
  90:	00001097          	auipc	ra,0x1
  94:	92c080e7          	jalr	-1748(ra) # 9bc <unlink>
  unlink("/testsymlink/2");
  98:	00001517          	auipc	a0,0x1
  9c:	e4050513          	addi	a0,a0,-448 # ed8 <malloc+0x12c>
  a0:	00001097          	auipc	ra,0x1
  a4:	91c080e7          	jalr	-1764(ra) # 9bc <unlink>
  unlink("/testsymlink/3");
  a8:	00001517          	auipc	a0,0x1
  ac:	e4050513          	addi	a0,a0,-448 # ee8 <malloc+0x13c>
  b0:	00001097          	auipc	ra,0x1
  b4:	90c080e7          	jalr	-1780(ra) # 9bc <unlink>
  unlink("/testsymlink/4");
  b8:	00001517          	auipc	a0,0x1
  bc:	e4050513          	addi	a0,a0,-448 # ef8 <malloc+0x14c>
  c0:	00001097          	auipc	ra,0x1
  c4:	8fc080e7          	jalr	-1796(ra) # 9bc <unlink>
  unlink("/testsymlink/z");
  c8:	00001517          	auipc	a0,0x1
  cc:	e4050513          	addi	a0,a0,-448 # f08 <malloc+0x15c>
  d0:	00001097          	auipc	ra,0x1
  d4:	8ec080e7          	jalr	-1812(ra) # 9bc <unlink>
  unlink("/testsymlink/y");
  d8:	00001517          	auipc	a0,0x1
  dc:	e4050513          	addi	a0,a0,-448 # f18 <malloc+0x16c>
  e0:	00001097          	auipc	ra,0x1
  e4:	8dc080e7          	jalr	-1828(ra) # 9bc <unlink>
  unlink("/testsymlink");
  e8:	00001517          	auipc	a0,0x1
  ec:	e4050513          	addi	a0,a0,-448 # f28 <malloc+0x17c>
  f0:	00001097          	auipc	ra,0x1
  f4:	8cc080e7          	jalr	-1844(ra) # 9bc <unlink>

static void
testsymlink(void)
{
  int r, fd1 = -1, fd2 = -1;
  char buf[4] = {'a', 'b', 'c', 'd'};
  f8:	00001797          	auipc	a5,0x1
  fc:	25878793          	addi	a5,a5,600 # 1350 <digits+0x20>
 100:	439c                	lw	a5,0(a5)
 102:	f8f42823          	sw	a5,-112(s0)
  char c = 0, c2 = 0;
 106:	f8040723          	sb	zero,-114(s0)
 10a:	f80407a3          	sb	zero,-113(s0)
  struct stat st;
    
  printf("Start: test symlinks\n");
 10e:	00001517          	auipc	a0,0x1
 112:	e2a50513          	addi	a0,a0,-470 # f38 <malloc+0x18c>
 116:	00001097          	auipc	ra,0x1
 11a:	bd6080e7          	jalr	-1066(ra) # cec <printf>

  mkdir("/testsymlink");
 11e:	00001517          	auipc	a0,0x1
 122:	e0a50513          	addi	a0,a0,-502 # f28 <malloc+0x17c>
 126:	00001097          	auipc	ra,0x1
 12a:	8ae080e7          	jalr	-1874(ra) # 9d4 <mkdir>

  fd1 = open("/testsymlink/a", O_CREATE | O_RDWR);
 12e:	20200593          	li	a1,514
 132:	00001517          	auipc	a0,0x1
 136:	d6650513          	addi	a0,a0,-666 # e98 <malloc+0xec>
 13a:	00001097          	auipc	ra,0x1
 13e:	872080e7          	jalr	-1934(ra) # 9ac <open>
 142:	84aa                	mv	s1,a0
  if(fd1 < 0) fail("failed to open a");
 144:	10054063          	bltz	a0,244 <main+0x204>

  r = symlink("/testsymlink/a", "/testsymlink/b");
 148:	00001597          	auipc	a1,0x1
 14c:	d6058593          	addi	a1,a1,-672 # ea8 <malloc+0xfc>
 150:	00001517          	auipc	a0,0x1
 154:	d4850513          	addi	a0,a0,-696 # e98 <malloc+0xec>
 158:	00001097          	auipc	ra,0x1
 15c:	8b4080e7          	jalr	-1868(ra) # a0c <symlink>
  if(r < 0)
 160:	10054163          	bltz	a0,262 <main+0x222>
    fail("symlink b -> a failed");

  if(write(fd1, buf, sizeof(buf)) != 4)
 164:	4611                	li	a2,4
 166:	f9040593          	addi	a1,s0,-112
 16a:	8526                	mv	a0,s1
 16c:	00001097          	auipc	ra,0x1
 170:	820080e7          	jalr	-2016(ra) # 98c <write>
 174:	4791                	li	a5,4
 176:	10f50563          	beq	a0,a5,280 <main+0x240>
    fail("failed to write to a");
 17a:	00001517          	auipc	a0,0x1
 17e:	e1650513          	addi	a0,a0,-490 # f90 <malloc+0x1e4>
 182:	00001097          	auipc	ra,0x1
 186:	b6a080e7          	jalr	-1174(ra) # cec <printf>
 18a:	4785                	li	a5,1
 18c:	00001717          	auipc	a4,0x1
 190:	1cf72623          	sw	a5,460(a4) # 1358 <failed>
  int r, fd1 = -1, fd2 = -1;
 194:	597d                	li	s2,-1
  if(c!=c2)
    fail("Value read from 4 differed from value written to 1\n");

  printf("test symlinks: ok\n");
done:
  close(fd1);
 196:	8526                	mv	a0,s1
 198:	00000097          	auipc	ra,0x0
 19c:	7fc080e7          	jalr	2044(ra) # 994 <close>
  close(fd2);
 1a0:	854a                	mv	a0,s2
 1a2:	00000097          	auipc	ra,0x0
 1a6:	7f2080e7          	jalr	2034(ra) # 994 <close>
  int pid, i;
  int fd;
  struct stat st;
  int nchild = 2;

  printf("Start: test concurrent symlinks\n");
 1aa:	00001517          	auipc	a0,0x1
 1ae:	0c650513          	addi	a0,a0,198 # 1270 <malloc+0x4c4>
 1b2:	00001097          	auipc	ra,0x1
 1b6:	b3a080e7          	jalr	-1222(ra) # cec <printf>
    
  fd = open("/testsymlink/z", O_CREATE | O_RDWR);
 1ba:	20200593          	li	a1,514
 1be:	00001517          	auipc	a0,0x1
 1c2:	d4a50513          	addi	a0,a0,-694 # f08 <malloc+0x15c>
 1c6:	00000097          	auipc	ra,0x0
 1ca:	7e6080e7          	jalr	2022(ra) # 9ac <open>
  if(fd < 0) {
 1ce:	42054363          	bltz	a0,5f4 <main+0x5b4>
    printf("FAILED: open failed");
    exit(1);
  }
  close(fd);
 1d2:	00000097          	auipc	ra,0x0
 1d6:	7c2080e7          	jalr	1986(ra) # 994 <close>

  for(int j = 0; j < nchild; j++) {
    pid = fork();
 1da:	00000097          	auipc	ra,0x0
 1de:	78a080e7          	jalr	1930(ra) # 964 <fork>
    if(pid < 0){
 1e2:	42054663          	bltz	a0,60e <main+0x5ce>
      printf("FAILED: fork failed\n");
      exit(1);
    }
    if(pid == 0) {
 1e6:	44050163          	beqz	a0,628 <main+0x5e8>
    pid = fork();
 1ea:	00000097          	auipc	ra,0x0
 1ee:	77a080e7          	jalr	1914(ra) # 964 <fork>
    if(pid < 0){
 1f2:	40054e63          	bltz	a0,60e <main+0x5ce>
    if(pid == 0) {
 1f6:	42050963          	beqz	a0,628 <main+0x5e8>
    }
  }

  int r;
  for(int j = 0; j < nchild; j++) {
    wait(&r);
 1fa:	f9840513          	addi	a0,s0,-104
 1fe:	00000097          	auipc	ra,0x0
 202:	776080e7          	jalr	1910(ra) # 974 <wait>
    if(r != 0) {
 206:	f9842783          	lw	a5,-104(s0)
 20a:	4a079c63          	bnez	a5,6c2 <main+0x682>
    wait(&r);
 20e:	f9840513          	addi	a0,s0,-104
 212:	00000097          	auipc	ra,0x0
 216:	762080e7          	jalr	1890(ra) # 974 <wait>
    if(r != 0) {
 21a:	f9842783          	lw	a5,-104(s0)
 21e:	4a079263          	bnez	a5,6c2 <main+0x682>
      printf("test concurrent symlinks: failed\n");
      exit(1);
    }
  }
  printf("test concurrent symlinks: ok\n");
 222:	00001517          	auipc	a0,0x1
 226:	0ee50513          	addi	a0,a0,238 # 1310 <malloc+0x564>
 22a:	00001097          	auipc	ra,0x1
 22e:	ac2080e7          	jalr	-1342(ra) # cec <printf>
  exit(failed);
 232:	00001797          	auipc	a5,0x1
 236:	12678793          	addi	a5,a5,294 # 1358 <failed>
 23a:	4388                	lw	a0,0(a5)
 23c:	00000097          	auipc	ra,0x0
 240:	730080e7          	jalr	1840(ra) # 96c <exit>
  if(fd1 < 0) fail("failed to open a");
 244:	00001517          	auipc	a0,0x1
 248:	d0c50513          	addi	a0,a0,-756 # f50 <malloc+0x1a4>
 24c:	00001097          	auipc	ra,0x1
 250:	aa0080e7          	jalr	-1376(ra) # cec <printf>
 254:	4785                	li	a5,1
 256:	00001717          	auipc	a4,0x1
 25a:	10f72123          	sw	a5,258(a4) # 1358 <failed>
  int r, fd1 = -1, fd2 = -1;
 25e:	597d                	li	s2,-1
 260:	bf1d                	j	196 <main+0x156>
    fail("symlink b -> a failed");
 262:	00001517          	auipc	a0,0x1
 266:	d0e50513          	addi	a0,a0,-754 # f70 <malloc+0x1c4>
 26a:	00001097          	auipc	ra,0x1
 26e:	a82080e7          	jalr	-1406(ra) # cec <printf>
 272:	4785                	li	a5,1
 274:	00001717          	auipc	a4,0x1
 278:	0ef72223          	sw	a5,228(a4) # 1358 <failed>
  int r, fd1 = -1, fd2 = -1;
 27c:	597d                	li	s2,-1
 27e:	bf21                	j	196 <main+0x156>
  if (stat_slink("/testsymlink/b", &st) != 0)
 280:	f9840593          	addi	a1,s0,-104
 284:	00001517          	auipc	a0,0x1
 288:	c2450513          	addi	a0,a0,-988 # ea8 <malloc+0xfc>
 28c:	00000097          	auipc	ra,0x0
 290:	d74080e7          	jalr	-652(ra) # 0 <stat_slink>
 294:	e50d                	bnez	a0,2be <main+0x27e>
  if(st.type != T_SYMLINK)
 296:	fa041703          	lh	a4,-96(s0)
 29a:	4791                	li	a5,4
 29c:	04f70063          	beq	a4,a5,2dc <main+0x29c>
    fail("b isn't a symlink");
 2a0:	00001517          	auipc	a0,0x1
 2a4:	d3050513          	addi	a0,a0,-720 # fd0 <malloc+0x224>
 2a8:	00001097          	auipc	ra,0x1
 2ac:	a44080e7          	jalr	-1468(ra) # cec <printf>
 2b0:	4785                	li	a5,1
 2b2:	00001717          	auipc	a4,0x1
 2b6:	0af72323          	sw	a5,166(a4) # 1358 <failed>
  int r, fd1 = -1, fd2 = -1;
 2ba:	597d                	li	s2,-1
 2bc:	bde9                	j	196 <main+0x156>
    fail("failed to stat b");
 2be:	00001517          	auipc	a0,0x1
 2c2:	cf250513          	addi	a0,a0,-782 # fb0 <malloc+0x204>
 2c6:	00001097          	auipc	ra,0x1
 2ca:	a26080e7          	jalr	-1498(ra) # cec <printf>
 2ce:	4785                	li	a5,1
 2d0:	00001717          	auipc	a4,0x1
 2d4:	08f72423          	sw	a5,136(a4) # 1358 <failed>
  int r, fd1 = -1, fd2 = -1;
 2d8:	597d                	li	s2,-1
 2da:	bd75                	j	196 <main+0x156>
  fd2 = open("/testsymlink/b", O_RDWR);
 2dc:	4589                	li	a1,2
 2de:	00001517          	auipc	a0,0x1
 2e2:	bca50513          	addi	a0,a0,-1078 # ea8 <malloc+0xfc>
 2e6:	00000097          	auipc	ra,0x0
 2ea:	6c6080e7          	jalr	1734(ra) # 9ac <open>
 2ee:	892a                	mv	s2,a0
  if(fd2 < 0)
 2f0:	02054d63          	bltz	a0,32a <main+0x2ea>
  read(fd2, &c, 1);
 2f4:	4605                	li	a2,1
 2f6:	f8e40593          	addi	a1,s0,-114
 2fa:	00000097          	auipc	ra,0x0
 2fe:	68a080e7          	jalr	1674(ra) # 984 <read>
  if (c != 'a')
 302:	f8e44703          	lbu	a4,-114(s0)
 306:	06100793          	li	a5,97
 30a:	02f70e63          	beq	a4,a5,346 <main+0x306>
    fail("failed to read bytes from b");
 30e:	00001517          	auipc	a0,0x1
 312:	d0250513          	addi	a0,a0,-766 # 1010 <malloc+0x264>
 316:	00001097          	auipc	ra,0x1
 31a:	9d6080e7          	jalr	-1578(ra) # cec <printf>
 31e:	4785                	li	a5,1
 320:	00001717          	auipc	a4,0x1
 324:	02f72c23          	sw	a5,56(a4) # 1358 <failed>
 328:	b5bd                	j	196 <main+0x156>
    fail("failed to open b");
 32a:	00001517          	auipc	a0,0x1
 32e:	cc650513          	addi	a0,a0,-826 # ff0 <malloc+0x244>
 332:	00001097          	auipc	ra,0x1
 336:	9ba080e7          	jalr	-1606(ra) # cec <printf>
 33a:	4785                	li	a5,1
 33c:	00001717          	auipc	a4,0x1
 340:	00f72e23          	sw	a5,28(a4) # 1358 <failed>
 344:	bd89                	j	196 <main+0x156>
  unlink("/testsymlink/a");
 346:	00001517          	auipc	a0,0x1
 34a:	b5250513          	addi	a0,a0,-1198 # e98 <malloc+0xec>
 34e:	00000097          	auipc	ra,0x0
 352:	66e080e7          	jalr	1646(ra) # 9bc <unlink>
  if(open("/testsymlink/b", O_RDWR) >= 0)
 356:	4589                	li	a1,2
 358:	00001517          	auipc	a0,0x1
 35c:	b5050513          	addi	a0,a0,-1200 # ea8 <malloc+0xfc>
 360:	00000097          	auipc	ra,0x0
 364:	64c080e7          	jalr	1612(ra) # 9ac <open>
 368:	12055263          	bgez	a0,48c <main+0x44c>
  r = symlink("/testsymlink/b", "/testsymlink/a");
 36c:	00001597          	auipc	a1,0x1
 370:	b2c58593          	addi	a1,a1,-1236 # e98 <malloc+0xec>
 374:	00001517          	auipc	a0,0x1
 378:	b3450513          	addi	a0,a0,-1228 # ea8 <malloc+0xfc>
 37c:	00000097          	auipc	ra,0x0
 380:	690080e7          	jalr	1680(ra) # a0c <symlink>
  if(r < 0)
 384:	12054263          	bltz	a0,4a8 <main+0x468>
  r = open("/testsymlink/b", O_RDWR);
 388:	4589                	li	a1,2
 38a:	00001517          	auipc	a0,0x1
 38e:	b1e50513          	addi	a0,a0,-1250 # ea8 <malloc+0xfc>
 392:	00000097          	auipc	ra,0x0
 396:	61a080e7          	jalr	1562(ra) # 9ac <open>
  if(r >= 0)
 39a:	12055563          	bgez	a0,4c4 <main+0x484>
  r = symlink("/testsymlink/nonexistent", "/testsymlink/c");
 39e:	00001597          	auipc	a1,0x1
 3a2:	b1a58593          	addi	a1,a1,-1254 # eb8 <malloc+0x10c>
 3a6:	00001517          	auipc	a0,0x1
 3aa:	d2a50513          	addi	a0,a0,-726 # 10d0 <malloc+0x324>
 3ae:	00000097          	auipc	ra,0x0
 3b2:	65e080e7          	jalr	1630(ra) # a0c <symlink>
  if(r != 0)
 3b6:	12051563          	bnez	a0,4e0 <main+0x4a0>
  r = symlink("/testsymlink/2", "/testsymlink/1");
 3ba:	00001597          	auipc	a1,0x1
 3be:	b0e58593          	addi	a1,a1,-1266 # ec8 <malloc+0x11c>
 3c2:	00001517          	auipc	a0,0x1
 3c6:	b1650513          	addi	a0,a0,-1258 # ed8 <malloc+0x12c>
 3ca:	00000097          	auipc	ra,0x0
 3ce:	642080e7          	jalr	1602(ra) # a0c <symlink>
  if(r) fail("Failed to link 1->2");
 3d2:	12051563          	bnez	a0,4fc <main+0x4bc>
  r = symlink("/testsymlink/3", "/testsymlink/2");
 3d6:	00001597          	auipc	a1,0x1
 3da:	b0258593          	addi	a1,a1,-1278 # ed8 <malloc+0x12c>
 3de:	00001517          	auipc	a0,0x1
 3e2:	b0a50513          	addi	a0,a0,-1270 # ee8 <malloc+0x13c>
 3e6:	00000097          	auipc	ra,0x0
 3ea:	626080e7          	jalr	1574(ra) # a0c <symlink>
  if(r) fail("Failed to link 2->3");
 3ee:	12051563          	bnez	a0,518 <main+0x4d8>
  r = symlink("/testsymlink/4", "/testsymlink/3");
 3f2:	00001597          	auipc	a1,0x1
 3f6:	af658593          	addi	a1,a1,-1290 # ee8 <malloc+0x13c>
 3fa:	00001517          	auipc	a0,0x1
 3fe:	afe50513          	addi	a0,a0,-1282 # ef8 <malloc+0x14c>
 402:	00000097          	auipc	ra,0x0
 406:	60a080e7          	jalr	1546(ra) # a0c <symlink>
  if(r) fail("Failed to link 3->4");
 40a:	12051563          	bnez	a0,534 <main+0x4f4>
  close(fd1);
 40e:	8526                	mv	a0,s1
 410:	00000097          	auipc	ra,0x0
 414:	584080e7          	jalr	1412(ra) # 994 <close>
  close(fd2);
 418:	854a                	mv	a0,s2
 41a:	00000097          	auipc	ra,0x0
 41e:	57a080e7          	jalr	1402(ra) # 994 <close>
  fd1 = open("/testsymlink/4", O_CREATE | O_RDWR);
 422:	20200593          	li	a1,514
 426:	00001517          	auipc	a0,0x1
 42a:	ad250513          	addi	a0,a0,-1326 # ef8 <malloc+0x14c>
 42e:	00000097          	auipc	ra,0x0
 432:	57e080e7          	jalr	1406(ra) # 9ac <open>
 436:	84aa                	mv	s1,a0
  if(fd1<0) fail("Failed to create 4\n");
 438:	10054c63          	bltz	a0,550 <main+0x510>
  fd2 = open("/testsymlink/1", O_RDWR);
 43c:	4589                	li	a1,2
 43e:	00001517          	auipc	a0,0x1
 442:	a8a50513          	addi	a0,a0,-1398 # ec8 <malloc+0x11c>
 446:	00000097          	auipc	ra,0x0
 44a:	566080e7          	jalr	1382(ra) # 9ac <open>
 44e:	892a                	mv	s2,a0
  if(fd2<0) fail("Failed to open 1\n");
 450:	10054e63          	bltz	a0,56c <main+0x52c>
  c = '#';
 454:	02300793          	li	a5,35
 458:	f8f40723          	sb	a5,-114(s0)
  r = write(fd2, &c, 1);
 45c:	4605                	li	a2,1
 45e:	f8e40593          	addi	a1,s0,-114
 462:	00000097          	auipc	ra,0x0
 466:	52a080e7          	jalr	1322(ra) # 98c <write>
  if(r!=1) fail("Failed to write to 1\n");
 46a:	4785                	li	a5,1
 46c:	10f50e63          	beq	a0,a5,588 <main+0x548>
 470:	00001517          	auipc	a0,0x1
 474:	d6050513          	addi	a0,a0,-672 # 11d0 <malloc+0x424>
 478:	00001097          	auipc	ra,0x1
 47c:	874080e7          	jalr	-1932(ra) # cec <printf>
 480:	4785                	li	a5,1
 482:	00001717          	auipc	a4,0x1
 486:	ecf72b23          	sw	a5,-298(a4) # 1358 <failed>
 48a:	b331                	j	196 <main+0x156>
    fail("Should not be able to open b after deleting a");
 48c:	00001517          	auipc	a0,0x1
 490:	bac50513          	addi	a0,a0,-1108 # 1038 <malloc+0x28c>
 494:	00001097          	auipc	ra,0x1
 498:	858080e7          	jalr	-1960(ra) # cec <printf>
 49c:	4785                	li	a5,1
 49e:	00001717          	auipc	a4,0x1
 4a2:	eaf72d23          	sw	a5,-326(a4) # 1358 <failed>
 4a6:	b9c5                	j	196 <main+0x156>
    fail("symlink a -> b failed");
 4a8:	00001517          	auipc	a0,0x1
 4ac:	bc850513          	addi	a0,a0,-1080 # 1070 <malloc+0x2c4>
 4b0:	00001097          	auipc	ra,0x1
 4b4:	83c080e7          	jalr	-1988(ra) # cec <printf>
 4b8:	4785                	li	a5,1
 4ba:	00001717          	auipc	a4,0x1
 4be:	e8f72f23          	sw	a5,-354(a4) # 1358 <failed>
 4c2:	b9d1                	j	196 <main+0x156>
    fail("Should not be able to open b (cycle b->a->b->..)\n");
 4c4:	00001517          	auipc	a0,0x1
 4c8:	bcc50513          	addi	a0,a0,-1076 # 1090 <malloc+0x2e4>
 4cc:	00001097          	auipc	ra,0x1
 4d0:	820080e7          	jalr	-2016(ra) # cec <printf>
 4d4:	4785                	li	a5,1
 4d6:	00001717          	auipc	a4,0x1
 4da:	e8f72123          	sw	a5,-382(a4) # 1358 <failed>
 4de:	b965                	j	196 <main+0x156>
    fail("Symlinking to nonexistent file should succeed\n");
 4e0:	00001517          	auipc	a0,0x1
 4e4:	c1050513          	addi	a0,a0,-1008 # 10f0 <malloc+0x344>
 4e8:	00001097          	auipc	ra,0x1
 4ec:	804080e7          	jalr	-2044(ra) # cec <printf>
 4f0:	4785                	li	a5,1
 4f2:	00001717          	auipc	a4,0x1
 4f6:	e6f72323          	sw	a5,-410(a4) # 1358 <failed>
 4fa:	b971                	j	196 <main+0x156>
  if(r) fail("Failed to link 1->2");
 4fc:	00001517          	auipc	a0,0x1
 500:	c3450513          	addi	a0,a0,-972 # 1130 <malloc+0x384>
 504:	00000097          	auipc	ra,0x0
 508:	7e8080e7          	jalr	2024(ra) # cec <printf>
 50c:	4785                	li	a5,1
 50e:	00001717          	auipc	a4,0x1
 512:	e4f72523          	sw	a5,-438(a4) # 1358 <failed>
 516:	b141                	j	196 <main+0x156>
  if(r) fail("Failed to link 2->3");
 518:	00001517          	auipc	a0,0x1
 51c:	c3850513          	addi	a0,a0,-968 # 1150 <malloc+0x3a4>
 520:	00000097          	auipc	ra,0x0
 524:	7cc080e7          	jalr	1996(ra) # cec <printf>
 528:	4785                	li	a5,1
 52a:	00001717          	auipc	a4,0x1
 52e:	e2f72723          	sw	a5,-466(a4) # 1358 <failed>
 532:	b195                	j	196 <main+0x156>
  if(r) fail("Failed to link 3->4");
 534:	00001517          	auipc	a0,0x1
 538:	c3c50513          	addi	a0,a0,-964 # 1170 <malloc+0x3c4>
 53c:	00000097          	auipc	ra,0x0
 540:	7b0080e7          	jalr	1968(ra) # cec <printf>
 544:	4785                	li	a5,1
 546:	00001717          	auipc	a4,0x1
 54a:	e0f72923          	sw	a5,-494(a4) # 1358 <failed>
 54e:	b1a1                	j	196 <main+0x156>
  if(fd1<0) fail("Failed to create 4\n");
 550:	00001517          	auipc	a0,0x1
 554:	c4050513          	addi	a0,a0,-960 # 1190 <malloc+0x3e4>
 558:	00000097          	auipc	ra,0x0
 55c:	794080e7          	jalr	1940(ra) # cec <printf>
 560:	4785                	li	a5,1
 562:	00001717          	auipc	a4,0x1
 566:	def72b23          	sw	a5,-522(a4) # 1358 <failed>
 56a:	b135                	j	196 <main+0x156>
  if(fd2<0) fail("Failed to open 1\n");
 56c:	00001517          	auipc	a0,0x1
 570:	c4450513          	addi	a0,a0,-956 # 11b0 <malloc+0x404>
 574:	00000097          	auipc	ra,0x0
 578:	778080e7          	jalr	1912(ra) # cec <printf>
 57c:	4785                	li	a5,1
 57e:	00001717          	auipc	a4,0x1
 582:	dcf72d23          	sw	a5,-550(a4) # 1358 <failed>
 586:	b901                	j	196 <main+0x156>
  r = read(fd1, &c2, 1);
 588:	4605                	li	a2,1
 58a:	f8f40593          	addi	a1,s0,-113
 58e:	8526                	mv	a0,s1
 590:	00000097          	auipc	ra,0x0
 594:	3f4080e7          	jalr	1012(ra) # 984 <read>
  if(r!=1) fail("Failed to read from 4\n");
 598:	4785                	li	a5,1
 59a:	02f51663          	bne	a0,a5,5c6 <main+0x586>
  if(c!=c2)
 59e:	f8e44703          	lbu	a4,-114(s0)
 5a2:	f8f44783          	lbu	a5,-113(s0)
 5a6:	02f70e63          	beq	a4,a5,5e2 <main+0x5a2>
    fail("Value read from 4 differed from value written to 1\n");
 5aa:	00001517          	auipc	a0,0x1
 5ae:	c6e50513          	addi	a0,a0,-914 # 1218 <malloc+0x46c>
 5b2:	00000097          	auipc	ra,0x0
 5b6:	73a080e7          	jalr	1850(ra) # cec <printf>
 5ba:	4785                	li	a5,1
 5bc:	00001717          	auipc	a4,0x1
 5c0:	d8f72e23          	sw	a5,-612(a4) # 1358 <failed>
 5c4:	bec9                	j	196 <main+0x156>
  if(r!=1) fail("Failed to read from 4\n");
 5c6:	00001517          	auipc	a0,0x1
 5ca:	c2a50513          	addi	a0,a0,-982 # 11f0 <malloc+0x444>
 5ce:	00000097          	auipc	ra,0x0
 5d2:	71e080e7          	jalr	1822(ra) # cec <printf>
 5d6:	4785                	li	a5,1
 5d8:	00001717          	auipc	a4,0x1
 5dc:	d8f72023          	sw	a5,-640(a4) # 1358 <failed>
 5e0:	be5d                	j	196 <main+0x156>
  printf("test symlinks: ok\n");
 5e2:	00001517          	auipc	a0,0x1
 5e6:	c7650513          	addi	a0,a0,-906 # 1258 <malloc+0x4ac>
 5ea:	00000097          	auipc	ra,0x0
 5ee:	702080e7          	jalr	1794(ra) # cec <printf>
 5f2:	b655                	j	196 <main+0x156>
    printf("FAILED: open failed");
 5f4:	00001517          	auipc	a0,0x1
 5f8:	ca450513          	addi	a0,a0,-860 # 1298 <malloc+0x4ec>
 5fc:	00000097          	auipc	ra,0x0
 600:	6f0080e7          	jalr	1776(ra) # cec <printf>
    exit(1);
 604:	4505                	li	a0,1
 606:	00000097          	auipc	ra,0x0
 60a:	366080e7          	jalr	870(ra) # 96c <exit>
      printf("FAILED: fork failed\n");
 60e:	00001517          	auipc	a0,0x1
 612:	ca250513          	addi	a0,a0,-862 # 12b0 <malloc+0x504>
 616:	00000097          	auipc	ra,0x0
 61a:	6d6080e7          	jalr	1750(ra) # cec <printf>
      exit(1);
 61e:	4505                	li	a0,1
 620:	00000097          	auipc	ra,0x0
 624:	34c080e7          	jalr	844(ra) # 96c <exit>
  int r, fd1 = -1, fd2 = -1;
 628:	06400913          	li	s2,100
      unsigned int x = (pid ? 1 : 97);
 62c:	06100993          	li	s3,97
        x = x * 1103515245 + 12345;
 630:	41c65ab7          	lui	s5,0x41c65
 634:	e6da8a9b          	addiw	s5,s5,-403
 638:	6a0d                	lui	s4,0x3
 63a:	039a0a1b          	addiw	s4,s4,57
        if((x % 3) == 0) {
 63e:	4c0d                	li	s8,3
          unlink("/testsymlink/y");
 640:	00001497          	auipc	s1,0x1
 644:	8d848493          	addi	s1,s1,-1832 # f18 <malloc+0x16c>
          symlink("/testsymlink/z", "/testsymlink/y");
 648:	00001b97          	auipc	s7,0x1
 64c:	8c0b8b93          	addi	s7,s7,-1856 # f08 <malloc+0x15c>
            if(st.type != T_SYMLINK) {
 650:	4b11                	li	s6,4
 652:	a809                	j	664 <main+0x624>
          unlink("/testsymlink/y");
 654:	8526                	mv	a0,s1
 656:	00000097          	auipc	ra,0x0
 65a:	366080e7          	jalr	870(ra) # 9bc <unlink>
      for(i = 0; i < 100; i++){
 65e:	397d                	addiw	s2,s2,-1
 660:	04090c63          	beqz	s2,6b8 <main+0x678>
        x = x * 1103515245 + 12345;
 664:	035987bb          	mulw	a5,s3,s5
 668:	014787bb          	addw	a5,a5,s4
 66c:	0007899b          	sext.w	s3,a5
        if((x % 3) == 0) {
 670:	0387f7bb          	remuw	a5,a5,s8
 674:	f3e5                	bnez	a5,654 <main+0x614>
          symlink("/testsymlink/z", "/testsymlink/y");
 676:	85a6                	mv	a1,s1
 678:	855e                	mv	a0,s7
 67a:	00000097          	auipc	ra,0x0
 67e:	392080e7          	jalr	914(ra) # a0c <symlink>
          if (stat_slink("/testsymlink/y", &st) == 0) {
 682:	f9840593          	addi	a1,s0,-104
 686:	8526                	mv	a0,s1
 688:	00000097          	auipc	ra,0x0
 68c:	978080e7          	jalr	-1672(ra) # 0 <stat_slink>
 690:	f579                	bnez	a0,65e <main+0x61e>
            if(st.type != T_SYMLINK) {
 692:	fa041583          	lh	a1,-96(s0)
 696:	0005879b          	sext.w	a5,a1
 69a:	fd6782e3          	beq	a5,s6,65e <main+0x61e>
              printf("FAILED: not a symbolic link\n", st.type);
 69e:	00001517          	auipc	a0,0x1
 6a2:	c2a50513          	addi	a0,a0,-982 # 12c8 <malloc+0x51c>
 6a6:	00000097          	auipc	ra,0x0
 6aa:	646080e7          	jalr	1606(ra) # cec <printf>
              exit(1);
 6ae:	4505                	li	a0,1
 6b0:	00000097          	auipc	ra,0x0
 6b4:	2bc080e7          	jalr	700(ra) # 96c <exit>
      exit(0);
 6b8:	4501                	li	a0,0
 6ba:	00000097          	auipc	ra,0x0
 6be:	2b2080e7          	jalr	690(ra) # 96c <exit>
      printf("test concurrent symlinks: failed\n");
 6c2:	00001517          	auipc	a0,0x1
 6c6:	c2650513          	addi	a0,a0,-986 # 12e8 <malloc+0x53c>
 6ca:	00000097          	auipc	ra,0x0
 6ce:	622080e7          	jalr	1570(ra) # cec <printf>
      exit(1);
 6d2:	4505                	li	a0,1
 6d4:	00000097          	auipc	ra,0x0
 6d8:	298080e7          	jalr	664(ra) # 96c <exit>

00000000000006dc <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 6dc:	1141                	addi	sp,sp,-16
 6de:	e422                	sd	s0,8(sp)
 6e0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 6e2:	87aa                	mv	a5,a0
 6e4:	0585                	addi	a1,a1,1
 6e6:	0785                	addi	a5,a5,1
 6e8:	fff5c703          	lbu	a4,-1(a1)
 6ec:	fee78fa3          	sb	a4,-1(a5)
 6f0:	fb75                	bnez	a4,6e4 <strcpy+0x8>
    ;
  return os;
}
 6f2:	6422                	ld	s0,8(sp)
 6f4:	0141                	addi	sp,sp,16
 6f6:	8082                	ret

00000000000006f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 6f8:	1141                	addi	sp,sp,-16
 6fa:	e422                	sd	s0,8(sp)
 6fc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 6fe:	00054783          	lbu	a5,0(a0)
 702:	cf91                	beqz	a5,71e <strcmp+0x26>
 704:	0005c703          	lbu	a4,0(a1)
 708:	00f71b63          	bne	a4,a5,71e <strcmp+0x26>
    p++, q++;
 70c:	0505                	addi	a0,a0,1
 70e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 710:	00054783          	lbu	a5,0(a0)
 714:	c789                	beqz	a5,71e <strcmp+0x26>
 716:	0005c703          	lbu	a4,0(a1)
 71a:	fef709e3          	beq	a4,a5,70c <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 71e:	0005c503          	lbu	a0,0(a1)
}
 722:	40a7853b          	subw	a0,a5,a0
 726:	6422                	ld	s0,8(sp)
 728:	0141                	addi	sp,sp,16
 72a:	8082                	ret

000000000000072c <strlen>:

uint
strlen(const char *s)
{
 72c:	1141                	addi	sp,sp,-16
 72e:	e422                	sd	s0,8(sp)
 730:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 732:	00054783          	lbu	a5,0(a0)
 736:	cf91                	beqz	a5,752 <strlen+0x26>
 738:	0505                	addi	a0,a0,1
 73a:	87aa                	mv	a5,a0
 73c:	4685                	li	a3,1
 73e:	9e89                	subw	a3,a3,a0
 740:	00f6853b          	addw	a0,a3,a5
 744:	0785                	addi	a5,a5,1
 746:	fff7c703          	lbu	a4,-1(a5)
 74a:	fb7d                	bnez	a4,740 <strlen+0x14>
    ;
  return n;
}
 74c:	6422                	ld	s0,8(sp)
 74e:	0141                	addi	sp,sp,16
 750:	8082                	ret
  for(n = 0; s[n]; n++)
 752:	4501                	li	a0,0
 754:	bfe5                	j	74c <strlen+0x20>

0000000000000756 <memset>:

void*
memset(void *dst, int c, uint n)
{
 756:	1141                	addi	sp,sp,-16
 758:	e422                	sd	s0,8(sp)
 75a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 75c:	ce09                	beqz	a2,776 <memset+0x20>
 75e:	87aa                	mv	a5,a0
 760:	fff6071b          	addiw	a4,a2,-1
 764:	1702                	slli	a4,a4,0x20
 766:	9301                	srli	a4,a4,0x20
 768:	0705                	addi	a4,a4,1
 76a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 76c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 770:	0785                	addi	a5,a5,1
 772:	fee79de3          	bne	a5,a4,76c <memset+0x16>
  }
  return dst;
}
 776:	6422                	ld	s0,8(sp)
 778:	0141                	addi	sp,sp,16
 77a:	8082                	ret

000000000000077c <strchr>:

char*
strchr(const char *s, char c)
{
 77c:	1141                	addi	sp,sp,-16
 77e:	e422                	sd	s0,8(sp)
 780:	0800                	addi	s0,sp,16
  for(; *s; s++)
 782:	00054783          	lbu	a5,0(a0)
 786:	cf91                	beqz	a5,7a2 <strchr+0x26>
    if(*s == c)
 788:	00f58a63          	beq	a1,a5,79c <strchr+0x20>
  for(; *s; s++)
 78c:	0505                	addi	a0,a0,1
 78e:	00054783          	lbu	a5,0(a0)
 792:	c781                	beqz	a5,79a <strchr+0x1e>
    if(*s == c)
 794:	feb79ce3          	bne	a5,a1,78c <strchr+0x10>
 798:	a011                	j	79c <strchr+0x20>
      return (char*)s;
  return 0;
 79a:	4501                	li	a0,0
}
 79c:	6422                	ld	s0,8(sp)
 79e:	0141                	addi	sp,sp,16
 7a0:	8082                	ret
  return 0;
 7a2:	4501                	li	a0,0
 7a4:	bfe5                	j	79c <strchr+0x20>

00000000000007a6 <gets>:

char*
gets(char *buf, int max)
{
 7a6:	711d                	addi	sp,sp,-96
 7a8:	ec86                	sd	ra,88(sp)
 7aa:	e8a2                	sd	s0,80(sp)
 7ac:	e4a6                	sd	s1,72(sp)
 7ae:	e0ca                	sd	s2,64(sp)
 7b0:	fc4e                	sd	s3,56(sp)
 7b2:	f852                	sd	s4,48(sp)
 7b4:	f456                	sd	s5,40(sp)
 7b6:	f05a                	sd	s6,32(sp)
 7b8:	ec5e                	sd	s7,24(sp)
 7ba:	1080                	addi	s0,sp,96
 7bc:	8baa                	mv	s7,a0
 7be:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 7c0:	892a                	mv	s2,a0
 7c2:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 7c4:	4aa9                	li	s5,10
 7c6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 7c8:	0019849b          	addiw	s1,s3,1
 7cc:	0344d863          	ble	s4,s1,7fc <gets+0x56>
    cc = read(0, &c, 1);
 7d0:	4605                	li	a2,1
 7d2:	faf40593          	addi	a1,s0,-81
 7d6:	4501                	li	a0,0
 7d8:	00000097          	auipc	ra,0x0
 7dc:	1ac080e7          	jalr	428(ra) # 984 <read>
    if(cc < 1)
 7e0:	00a05e63          	blez	a0,7fc <gets+0x56>
    buf[i++] = c;
 7e4:	faf44783          	lbu	a5,-81(s0)
 7e8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 7ec:	01578763          	beq	a5,s5,7fa <gets+0x54>
 7f0:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 7f2:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 7f4:	fd679ae3          	bne	a5,s6,7c8 <gets+0x22>
 7f8:	a011                	j	7fc <gets+0x56>
  for(i=0; i+1 < max; ){
 7fa:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 7fc:	99de                	add	s3,s3,s7
 7fe:	00098023          	sb	zero,0(s3)
  return buf;
}
 802:	855e                	mv	a0,s7
 804:	60e6                	ld	ra,88(sp)
 806:	6446                	ld	s0,80(sp)
 808:	64a6                	ld	s1,72(sp)
 80a:	6906                	ld	s2,64(sp)
 80c:	79e2                	ld	s3,56(sp)
 80e:	7a42                	ld	s4,48(sp)
 810:	7aa2                	ld	s5,40(sp)
 812:	7b02                	ld	s6,32(sp)
 814:	6be2                	ld	s7,24(sp)
 816:	6125                	addi	sp,sp,96
 818:	8082                	ret

000000000000081a <stat>:

int
stat(const char *n, struct stat *st)
{
 81a:	1101                	addi	sp,sp,-32
 81c:	ec06                	sd	ra,24(sp)
 81e:	e822                	sd	s0,16(sp)
 820:	e426                	sd	s1,8(sp)
 822:	e04a                	sd	s2,0(sp)
 824:	1000                	addi	s0,sp,32
 826:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 828:	4581                	li	a1,0
 82a:	00000097          	auipc	ra,0x0
 82e:	182080e7          	jalr	386(ra) # 9ac <open>
  if(fd < 0)
 832:	02054563          	bltz	a0,85c <stat+0x42>
 836:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 838:	85ca                	mv	a1,s2
 83a:	00000097          	auipc	ra,0x0
 83e:	18a080e7          	jalr	394(ra) # 9c4 <fstat>
 842:	892a                	mv	s2,a0
  close(fd);
 844:	8526                	mv	a0,s1
 846:	00000097          	auipc	ra,0x0
 84a:	14e080e7          	jalr	334(ra) # 994 <close>
  return r;
}
 84e:	854a                	mv	a0,s2
 850:	60e2                	ld	ra,24(sp)
 852:	6442                	ld	s0,16(sp)
 854:	64a2                	ld	s1,8(sp)
 856:	6902                	ld	s2,0(sp)
 858:	6105                	addi	sp,sp,32
 85a:	8082                	ret
    return -1;
 85c:	597d                	li	s2,-1
 85e:	bfc5                	j	84e <stat+0x34>

0000000000000860 <atoi>:

int
atoi(const char *s)
{
 860:	1141                	addi	sp,sp,-16
 862:	e422                	sd	s0,8(sp)
 864:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 866:	00054683          	lbu	a3,0(a0)
 86a:	fd06879b          	addiw	a5,a3,-48
 86e:	0ff7f793          	andi	a5,a5,255
 872:	4725                	li	a4,9
 874:	02f76963          	bltu	a4,a5,8a6 <atoi+0x46>
 878:	862a                	mv	a2,a0
  n = 0;
 87a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 87c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 87e:	0605                	addi	a2,a2,1
 880:	0025179b          	slliw	a5,a0,0x2
 884:	9fa9                	addw	a5,a5,a0
 886:	0017979b          	slliw	a5,a5,0x1
 88a:	9fb5                	addw	a5,a5,a3
 88c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 890:	00064683          	lbu	a3,0(a2)
 894:	fd06871b          	addiw	a4,a3,-48
 898:	0ff77713          	andi	a4,a4,255
 89c:	fee5f1e3          	bleu	a4,a1,87e <atoi+0x1e>
  return n;
}
 8a0:	6422                	ld	s0,8(sp)
 8a2:	0141                	addi	sp,sp,16
 8a4:	8082                	ret
  n = 0;
 8a6:	4501                	li	a0,0
 8a8:	bfe5                	j	8a0 <atoi+0x40>

00000000000008aa <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 8aa:	1141                	addi	sp,sp,-16
 8ac:	e422                	sd	s0,8(sp)
 8ae:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 8b0:	02b57663          	bleu	a1,a0,8dc <memmove+0x32>
    while(n-- > 0)
 8b4:	02c05163          	blez	a2,8d6 <memmove+0x2c>
 8b8:	fff6079b          	addiw	a5,a2,-1
 8bc:	1782                	slli	a5,a5,0x20
 8be:	9381                	srli	a5,a5,0x20
 8c0:	0785                	addi	a5,a5,1
 8c2:	97aa                	add	a5,a5,a0
  dst = vdst;
 8c4:	872a                	mv	a4,a0
      *dst++ = *src++;
 8c6:	0585                	addi	a1,a1,1
 8c8:	0705                	addi	a4,a4,1
 8ca:	fff5c683          	lbu	a3,-1(a1)
 8ce:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 8d2:	fee79ae3          	bne	a5,a4,8c6 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 8d6:	6422                	ld	s0,8(sp)
 8d8:	0141                	addi	sp,sp,16
 8da:	8082                	ret
    dst += n;
 8dc:	00c50733          	add	a4,a0,a2
    src += n;
 8e0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 8e2:	fec05ae3          	blez	a2,8d6 <memmove+0x2c>
 8e6:	fff6079b          	addiw	a5,a2,-1
 8ea:	1782                	slli	a5,a5,0x20
 8ec:	9381                	srli	a5,a5,0x20
 8ee:	fff7c793          	not	a5,a5
 8f2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 8f4:	15fd                	addi	a1,a1,-1
 8f6:	177d                	addi	a4,a4,-1
 8f8:	0005c683          	lbu	a3,0(a1)
 8fc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 900:	fef71ae3          	bne	a4,a5,8f4 <memmove+0x4a>
 904:	bfc9                	j	8d6 <memmove+0x2c>

0000000000000906 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 906:	1141                	addi	sp,sp,-16
 908:	e422                	sd	s0,8(sp)
 90a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 90c:	ce15                	beqz	a2,948 <memcmp+0x42>
 90e:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 912:	00054783          	lbu	a5,0(a0)
 916:	0005c703          	lbu	a4,0(a1)
 91a:	02e79063          	bne	a5,a4,93a <memcmp+0x34>
 91e:	1682                	slli	a3,a3,0x20
 920:	9281                	srli	a3,a3,0x20
 922:	0685                	addi	a3,a3,1
 924:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 926:	0505                	addi	a0,a0,1
    p2++;
 928:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 92a:	00d50d63          	beq	a0,a3,944 <memcmp+0x3e>
    if (*p1 != *p2) {
 92e:	00054783          	lbu	a5,0(a0)
 932:	0005c703          	lbu	a4,0(a1)
 936:	fee788e3          	beq	a5,a4,926 <memcmp+0x20>
      return *p1 - *p2;
 93a:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 93e:	6422                	ld	s0,8(sp)
 940:	0141                	addi	sp,sp,16
 942:	8082                	ret
  return 0;
 944:	4501                	li	a0,0
 946:	bfe5                	j	93e <memcmp+0x38>
 948:	4501                	li	a0,0
 94a:	bfd5                	j	93e <memcmp+0x38>

000000000000094c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 94c:	1141                	addi	sp,sp,-16
 94e:	e406                	sd	ra,8(sp)
 950:	e022                	sd	s0,0(sp)
 952:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 954:	00000097          	auipc	ra,0x0
 958:	f56080e7          	jalr	-170(ra) # 8aa <memmove>
}
 95c:	60a2                	ld	ra,8(sp)
 95e:	6402                	ld	s0,0(sp)
 960:	0141                	addi	sp,sp,16
 962:	8082                	ret

0000000000000964 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 964:	4885                	li	a7,1
 ecall
 966:	00000073          	ecall
 ret
 96a:	8082                	ret

000000000000096c <exit>:
.global exit
exit:
 li a7, SYS_exit
 96c:	4889                	li	a7,2
 ecall
 96e:	00000073          	ecall
 ret
 972:	8082                	ret

0000000000000974 <wait>:
.global wait
wait:
 li a7, SYS_wait
 974:	488d                	li	a7,3
 ecall
 976:	00000073          	ecall
 ret
 97a:	8082                	ret

000000000000097c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 97c:	4891                	li	a7,4
 ecall
 97e:	00000073          	ecall
 ret
 982:	8082                	ret

0000000000000984 <read>:
.global read
read:
 li a7, SYS_read
 984:	4895                	li	a7,5
 ecall
 986:	00000073          	ecall
 ret
 98a:	8082                	ret

000000000000098c <write>:
.global write
write:
 li a7, SYS_write
 98c:	48c1                	li	a7,16
 ecall
 98e:	00000073          	ecall
 ret
 992:	8082                	ret

0000000000000994 <close>:
.global close
close:
 li a7, SYS_close
 994:	48d5                	li	a7,21
 ecall
 996:	00000073          	ecall
 ret
 99a:	8082                	ret

000000000000099c <kill>:
.global kill
kill:
 li a7, SYS_kill
 99c:	4899                	li	a7,6
 ecall
 99e:	00000073          	ecall
 ret
 9a2:	8082                	ret

00000000000009a4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 9a4:	489d                	li	a7,7
 ecall
 9a6:	00000073          	ecall
 ret
 9aa:	8082                	ret

00000000000009ac <open>:
.global open
open:
 li a7, SYS_open
 9ac:	48bd                	li	a7,15
 ecall
 9ae:	00000073          	ecall
 ret
 9b2:	8082                	ret

00000000000009b4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 9b4:	48c5                	li	a7,17
 ecall
 9b6:	00000073          	ecall
 ret
 9ba:	8082                	ret

00000000000009bc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 9bc:	48c9                	li	a7,18
 ecall
 9be:	00000073          	ecall
 ret
 9c2:	8082                	ret

00000000000009c4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 9c4:	48a1                	li	a7,8
 ecall
 9c6:	00000073          	ecall
 ret
 9ca:	8082                	ret

00000000000009cc <link>:
.global link
link:
 li a7, SYS_link
 9cc:	48cd                	li	a7,19
 ecall
 9ce:	00000073          	ecall
 ret
 9d2:	8082                	ret

00000000000009d4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 9d4:	48d1                	li	a7,20
 ecall
 9d6:	00000073          	ecall
 ret
 9da:	8082                	ret

00000000000009dc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 9dc:	48a5                	li	a7,9
 ecall
 9de:	00000073          	ecall
 ret
 9e2:	8082                	ret

00000000000009e4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 9e4:	48a9                	li	a7,10
 ecall
 9e6:	00000073          	ecall
 ret
 9ea:	8082                	ret

00000000000009ec <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 9ec:	48ad                	li	a7,11
 ecall
 9ee:	00000073          	ecall
 ret
 9f2:	8082                	ret

00000000000009f4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 9f4:	48b1                	li	a7,12
 ecall
 9f6:	00000073          	ecall
 ret
 9fa:	8082                	ret

00000000000009fc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 9fc:	48b5                	li	a7,13
 ecall
 9fe:	00000073          	ecall
 ret
 a02:	8082                	ret

0000000000000a04 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 a04:	48b9                	li	a7,14
 ecall
 a06:	00000073          	ecall
 ret
 a0a:	8082                	ret

0000000000000a0c <symlink>:
.global symlink
symlink:
 li a7, SYS_symlink
 a0c:	48d9                	li	a7,22
 ecall
 a0e:	00000073          	ecall
 ret
 a12:	8082                	ret

0000000000000a14 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 a14:	1101                	addi	sp,sp,-32
 a16:	ec06                	sd	ra,24(sp)
 a18:	e822                	sd	s0,16(sp)
 a1a:	1000                	addi	s0,sp,32
 a1c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 a20:	4605                	li	a2,1
 a22:	fef40593          	addi	a1,s0,-17
 a26:	00000097          	auipc	ra,0x0
 a2a:	f66080e7          	jalr	-154(ra) # 98c <write>
}
 a2e:	60e2                	ld	ra,24(sp)
 a30:	6442                	ld	s0,16(sp)
 a32:	6105                	addi	sp,sp,32
 a34:	8082                	ret

0000000000000a36 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 a36:	7139                	addi	sp,sp,-64
 a38:	fc06                	sd	ra,56(sp)
 a3a:	f822                	sd	s0,48(sp)
 a3c:	f426                	sd	s1,40(sp)
 a3e:	f04a                	sd	s2,32(sp)
 a40:	ec4e                	sd	s3,24(sp)
 a42:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 a44:	c299                	beqz	a3,a4a <printint+0x14>
 a46:	0005cd63          	bltz	a1,a60 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 a4a:	2581                	sext.w	a1,a1
  neg = 0;
 a4c:	4301                	li	t1,0
 a4e:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 a52:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 a54:	2601                	sext.w	a2,a2
 a56:	00001897          	auipc	a7,0x1
 a5a:	8da88893          	addi	a7,a7,-1830 # 1330 <digits>
 a5e:	a801                	j	a6e <printint+0x38>
    x = -xx;
 a60:	40b005bb          	negw	a1,a1
 a64:	2581                	sext.w	a1,a1
    neg = 1;
 a66:	4305                	li	t1,1
    x = -xx;
 a68:	b7dd                	j	a4e <printint+0x18>
  }while((x /= base) != 0);
 a6a:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 a6c:	8836                	mv	a6,a3
 a6e:	0018069b          	addiw	a3,a6,1
 a72:	02c5f7bb          	remuw	a5,a1,a2
 a76:	1782                	slli	a5,a5,0x20
 a78:	9381                	srli	a5,a5,0x20
 a7a:	97c6                	add	a5,a5,a7
 a7c:	0007c783          	lbu	a5,0(a5)
 a80:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 a84:	0705                	addi	a4,a4,1
 a86:	02c5d7bb          	divuw	a5,a1,a2
 a8a:	fec5f0e3          	bleu	a2,a1,a6a <printint+0x34>
  if(neg)
 a8e:	00030b63          	beqz	t1,aa4 <printint+0x6e>
    buf[i++] = '-';
 a92:	fd040793          	addi	a5,s0,-48
 a96:	96be                	add	a3,a3,a5
 a98:	02d00793          	li	a5,45
 a9c:	fef68823          	sb	a5,-16(a3)
 aa0:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 aa4:	02d05963          	blez	a3,ad6 <printint+0xa0>
 aa8:	89aa                	mv	s3,a0
 aaa:	fc040793          	addi	a5,s0,-64
 aae:	00d784b3          	add	s1,a5,a3
 ab2:	fff78913          	addi	s2,a5,-1
 ab6:	9936                	add	s2,s2,a3
 ab8:	36fd                	addiw	a3,a3,-1
 aba:	1682                	slli	a3,a3,0x20
 abc:	9281                	srli	a3,a3,0x20
 abe:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 ac2:	fff4c583          	lbu	a1,-1(s1)
 ac6:	854e                	mv	a0,s3
 ac8:	00000097          	auipc	ra,0x0
 acc:	f4c080e7          	jalr	-180(ra) # a14 <putc>
  while(--i >= 0)
 ad0:	14fd                	addi	s1,s1,-1
 ad2:	ff2498e3          	bne	s1,s2,ac2 <printint+0x8c>
}
 ad6:	70e2                	ld	ra,56(sp)
 ad8:	7442                	ld	s0,48(sp)
 ada:	74a2                	ld	s1,40(sp)
 adc:	7902                	ld	s2,32(sp)
 ade:	69e2                	ld	s3,24(sp)
 ae0:	6121                	addi	sp,sp,64
 ae2:	8082                	ret

0000000000000ae4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 ae4:	7119                	addi	sp,sp,-128
 ae6:	fc86                	sd	ra,120(sp)
 ae8:	f8a2                	sd	s0,112(sp)
 aea:	f4a6                	sd	s1,104(sp)
 aec:	f0ca                	sd	s2,96(sp)
 aee:	ecce                	sd	s3,88(sp)
 af0:	e8d2                	sd	s4,80(sp)
 af2:	e4d6                	sd	s5,72(sp)
 af4:	e0da                	sd	s6,64(sp)
 af6:	fc5e                	sd	s7,56(sp)
 af8:	f862                	sd	s8,48(sp)
 afa:	f466                	sd	s9,40(sp)
 afc:	f06a                	sd	s10,32(sp)
 afe:	ec6e                	sd	s11,24(sp)
 b00:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 b02:	0005c483          	lbu	s1,0(a1)
 b06:	18048d63          	beqz	s1,ca0 <vprintf+0x1bc>
 b0a:	8aaa                	mv	s5,a0
 b0c:	8b32                	mv	s6,a2
 b0e:	00158913          	addi	s2,a1,1
  state = 0;
 b12:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 b14:	02500a13          	li	s4,37
      if(c == 'd'){
 b18:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 b1c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 b20:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 b24:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 b28:	00001b97          	auipc	s7,0x1
 b2c:	808b8b93          	addi	s7,s7,-2040 # 1330 <digits>
 b30:	a839                	j	b4e <vprintf+0x6a>
        putc(fd, c);
 b32:	85a6                	mv	a1,s1
 b34:	8556                	mv	a0,s5
 b36:	00000097          	auipc	ra,0x0
 b3a:	ede080e7          	jalr	-290(ra) # a14 <putc>
 b3e:	a019                	j	b44 <vprintf+0x60>
    } else if(state == '%'){
 b40:	01498f63          	beq	s3,s4,b5e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 b44:	0905                	addi	s2,s2,1
 b46:	fff94483          	lbu	s1,-1(s2)
 b4a:	14048b63          	beqz	s1,ca0 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 b4e:	0004879b          	sext.w	a5,s1
    if(state == 0){
 b52:	fe0997e3          	bnez	s3,b40 <vprintf+0x5c>
      if(c == '%'){
 b56:	fd479ee3          	bne	a5,s4,b32 <vprintf+0x4e>
        state = '%';
 b5a:	89be                	mv	s3,a5
 b5c:	b7e5                	j	b44 <vprintf+0x60>
      if(c == 'd'){
 b5e:	05878063          	beq	a5,s8,b9e <vprintf+0xba>
      } else if(c == 'l') {
 b62:	05978c63          	beq	a5,s9,bba <vprintf+0xd6>
      } else if(c == 'x') {
 b66:	07a78863          	beq	a5,s10,bd6 <vprintf+0xf2>
      } else if(c == 'p') {
 b6a:	09b78463          	beq	a5,s11,bf2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 b6e:	07300713          	li	a4,115
 b72:	0ce78563          	beq	a5,a4,c3c <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 b76:	06300713          	li	a4,99
 b7a:	0ee78c63          	beq	a5,a4,c72 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 b7e:	11478663          	beq	a5,s4,c8a <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b82:	85d2                	mv	a1,s4
 b84:	8556                	mv	a0,s5
 b86:	00000097          	auipc	ra,0x0
 b8a:	e8e080e7          	jalr	-370(ra) # a14 <putc>
        putc(fd, c);
 b8e:	85a6                	mv	a1,s1
 b90:	8556                	mv	a0,s5
 b92:	00000097          	auipc	ra,0x0
 b96:	e82080e7          	jalr	-382(ra) # a14 <putc>
      }
      state = 0;
 b9a:	4981                	li	s3,0
 b9c:	b765                	j	b44 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 b9e:	008b0493          	addi	s1,s6,8
 ba2:	4685                	li	a3,1
 ba4:	4629                	li	a2,10
 ba6:	000b2583          	lw	a1,0(s6)
 baa:	8556                	mv	a0,s5
 bac:	00000097          	auipc	ra,0x0
 bb0:	e8a080e7          	jalr	-374(ra) # a36 <printint>
 bb4:	8b26                	mv	s6,s1
      state = 0;
 bb6:	4981                	li	s3,0
 bb8:	b771                	j	b44 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 bba:	008b0493          	addi	s1,s6,8
 bbe:	4681                	li	a3,0
 bc0:	4629                	li	a2,10
 bc2:	000b2583          	lw	a1,0(s6)
 bc6:	8556                	mv	a0,s5
 bc8:	00000097          	auipc	ra,0x0
 bcc:	e6e080e7          	jalr	-402(ra) # a36 <printint>
 bd0:	8b26                	mv	s6,s1
      state = 0;
 bd2:	4981                	li	s3,0
 bd4:	bf85                	j	b44 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 bd6:	008b0493          	addi	s1,s6,8
 bda:	4681                	li	a3,0
 bdc:	4641                	li	a2,16
 bde:	000b2583          	lw	a1,0(s6)
 be2:	8556                	mv	a0,s5
 be4:	00000097          	auipc	ra,0x0
 be8:	e52080e7          	jalr	-430(ra) # a36 <printint>
 bec:	8b26                	mv	s6,s1
      state = 0;
 bee:	4981                	li	s3,0
 bf0:	bf91                	j	b44 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 bf2:	008b0793          	addi	a5,s6,8
 bf6:	f8f43423          	sd	a5,-120(s0)
 bfa:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 bfe:	03000593          	li	a1,48
 c02:	8556                	mv	a0,s5
 c04:	00000097          	auipc	ra,0x0
 c08:	e10080e7          	jalr	-496(ra) # a14 <putc>
  putc(fd, 'x');
 c0c:	85ea                	mv	a1,s10
 c0e:	8556                	mv	a0,s5
 c10:	00000097          	auipc	ra,0x0
 c14:	e04080e7          	jalr	-508(ra) # a14 <putc>
 c18:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 c1a:	03c9d793          	srli	a5,s3,0x3c
 c1e:	97de                	add	a5,a5,s7
 c20:	0007c583          	lbu	a1,0(a5)
 c24:	8556                	mv	a0,s5
 c26:	00000097          	auipc	ra,0x0
 c2a:	dee080e7          	jalr	-530(ra) # a14 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 c2e:	0992                	slli	s3,s3,0x4
 c30:	34fd                	addiw	s1,s1,-1
 c32:	f4e5                	bnez	s1,c1a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 c34:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 c38:	4981                	li	s3,0
 c3a:	b729                	j	b44 <vprintf+0x60>
        s = va_arg(ap, char*);
 c3c:	008b0993          	addi	s3,s6,8
 c40:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 c44:	c085                	beqz	s1,c64 <vprintf+0x180>
        while(*s != 0){
 c46:	0004c583          	lbu	a1,0(s1)
 c4a:	c9a1                	beqz	a1,c9a <vprintf+0x1b6>
          putc(fd, *s);
 c4c:	8556                	mv	a0,s5
 c4e:	00000097          	auipc	ra,0x0
 c52:	dc6080e7          	jalr	-570(ra) # a14 <putc>
          s++;
 c56:	0485                	addi	s1,s1,1
        while(*s != 0){
 c58:	0004c583          	lbu	a1,0(s1)
 c5c:	f9e5                	bnez	a1,c4c <vprintf+0x168>
        s = va_arg(ap, char*);
 c5e:	8b4e                	mv	s6,s3
      state = 0;
 c60:	4981                	li	s3,0
 c62:	b5cd                	j	b44 <vprintf+0x60>
          s = "(null)";
 c64:	00000497          	auipc	s1,0x0
 c68:	6e448493          	addi	s1,s1,1764 # 1348 <digits+0x18>
        while(*s != 0){
 c6c:	02800593          	li	a1,40
 c70:	bff1                	j	c4c <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 c72:	008b0493          	addi	s1,s6,8
 c76:	000b4583          	lbu	a1,0(s6)
 c7a:	8556                	mv	a0,s5
 c7c:	00000097          	auipc	ra,0x0
 c80:	d98080e7          	jalr	-616(ra) # a14 <putc>
 c84:	8b26                	mv	s6,s1
      state = 0;
 c86:	4981                	li	s3,0
 c88:	bd75                	j	b44 <vprintf+0x60>
        putc(fd, c);
 c8a:	85d2                	mv	a1,s4
 c8c:	8556                	mv	a0,s5
 c8e:	00000097          	auipc	ra,0x0
 c92:	d86080e7          	jalr	-634(ra) # a14 <putc>
      state = 0;
 c96:	4981                	li	s3,0
 c98:	b575                	j	b44 <vprintf+0x60>
        s = va_arg(ap, char*);
 c9a:	8b4e                	mv	s6,s3
      state = 0;
 c9c:	4981                	li	s3,0
 c9e:	b55d                	j	b44 <vprintf+0x60>
    }
  }
}
 ca0:	70e6                	ld	ra,120(sp)
 ca2:	7446                	ld	s0,112(sp)
 ca4:	74a6                	ld	s1,104(sp)
 ca6:	7906                	ld	s2,96(sp)
 ca8:	69e6                	ld	s3,88(sp)
 caa:	6a46                	ld	s4,80(sp)
 cac:	6aa6                	ld	s5,72(sp)
 cae:	6b06                	ld	s6,64(sp)
 cb0:	7be2                	ld	s7,56(sp)
 cb2:	7c42                	ld	s8,48(sp)
 cb4:	7ca2                	ld	s9,40(sp)
 cb6:	7d02                	ld	s10,32(sp)
 cb8:	6de2                	ld	s11,24(sp)
 cba:	6109                	addi	sp,sp,128
 cbc:	8082                	ret

0000000000000cbe <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 cbe:	715d                	addi	sp,sp,-80
 cc0:	ec06                	sd	ra,24(sp)
 cc2:	e822                	sd	s0,16(sp)
 cc4:	1000                	addi	s0,sp,32
 cc6:	e010                	sd	a2,0(s0)
 cc8:	e414                	sd	a3,8(s0)
 cca:	e818                	sd	a4,16(s0)
 ccc:	ec1c                	sd	a5,24(s0)
 cce:	03043023          	sd	a6,32(s0)
 cd2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 cd6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 cda:	8622                	mv	a2,s0
 cdc:	00000097          	auipc	ra,0x0
 ce0:	e08080e7          	jalr	-504(ra) # ae4 <vprintf>
}
 ce4:	60e2                	ld	ra,24(sp)
 ce6:	6442                	ld	s0,16(sp)
 ce8:	6161                	addi	sp,sp,80
 cea:	8082                	ret

0000000000000cec <printf>:

void
printf(const char *fmt, ...)
{
 cec:	711d                	addi	sp,sp,-96
 cee:	ec06                	sd	ra,24(sp)
 cf0:	e822                	sd	s0,16(sp)
 cf2:	1000                	addi	s0,sp,32
 cf4:	e40c                	sd	a1,8(s0)
 cf6:	e810                	sd	a2,16(s0)
 cf8:	ec14                	sd	a3,24(s0)
 cfa:	f018                	sd	a4,32(s0)
 cfc:	f41c                	sd	a5,40(s0)
 cfe:	03043823          	sd	a6,48(s0)
 d02:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 d06:	00840613          	addi	a2,s0,8
 d0a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 d0e:	85aa                	mv	a1,a0
 d10:	4505                	li	a0,1
 d12:	00000097          	auipc	ra,0x0
 d16:	dd2080e7          	jalr	-558(ra) # ae4 <vprintf>
}
 d1a:	60e2                	ld	ra,24(sp)
 d1c:	6442                	ld	s0,16(sp)
 d1e:	6125                	addi	sp,sp,96
 d20:	8082                	ret

0000000000000d22 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 d22:	1141                	addi	sp,sp,-16
 d24:	e422                	sd	s0,8(sp)
 d26:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 d28:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d2c:	00000797          	auipc	a5,0x0
 d30:	63478793          	addi	a5,a5,1588 # 1360 <freep>
 d34:	639c                	ld	a5,0(a5)
 d36:	a805                	j	d66 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 d38:	4618                	lw	a4,8(a2)
 d3a:	9db9                	addw	a1,a1,a4
 d3c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 d40:	6398                	ld	a4,0(a5)
 d42:	6318                	ld	a4,0(a4)
 d44:	fee53823          	sd	a4,-16(a0)
 d48:	a091                	j	d8c <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 d4a:	ff852703          	lw	a4,-8(a0)
 d4e:	9e39                	addw	a2,a2,a4
 d50:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 d52:	ff053703          	ld	a4,-16(a0)
 d56:	e398                	sd	a4,0(a5)
 d58:	a099                	j	d9e <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d5a:	6398                	ld	a4,0(a5)
 d5c:	00e7e463          	bltu	a5,a4,d64 <free+0x42>
 d60:	00e6ea63          	bltu	a3,a4,d74 <free+0x52>
{
 d64:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d66:	fed7fae3          	bleu	a3,a5,d5a <free+0x38>
 d6a:	6398                	ld	a4,0(a5)
 d6c:	00e6e463          	bltu	a3,a4,d74 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d70:	fee7eae3          	bltu	a5,a4,d64 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 d74:	ff852583          	lw	a1,-8(a0)
 d78:	6390                	ld	a2,0(a5)
 d7a:	02059713          	slli	a4,a1,0x20
 d7e:	9301                	srli	a4,a4,0x20
 d80:	0712                	slli	a4,a4,0x4
 d82:	9736                	add	a4,a4,a3
 d84:	fae60ae3          	beq	a2,a4,d38 <free+0x16>
    bp->s.ptr = p->s.ptr;
 d88:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 d8c:	4790                	lw	a2,8(a5)
 d8e:	02061713          	slli	a4,a2,0x20
 d92:	9301                	srli	a4,a4,0x20
 d94:	0712                	slli	a4,a4,0x4
 d96:	973e                	add	a4,a4,a5
 d98:	fae689e3          	beq	a3,a4,d4a <free+0x28>
  } else
    p->s.ptr = bp;
 d9c:	e394                	sd	a3,0(a5)
  freep = p;
 d9e:	00000717          	auipc	a4,0x0
 da2:	5cf73123          	sd	a5,1474(a4) # 1360 <freep>
}
 da6:	6422                	ld	s0,8(sp)
 da8:	0141                	addi	sp,sp,16
 daa:	8082                	ret

0000000000000dac <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 dac:	7139                	addi	sp,sp,-64
 dae:	fc06                	sd	ra,56(sp)
 db0:	f822                	sd	s0,48(sp)
 db2:	f426                	sd	s1,40(sp)
 db4:	f04a                	sd	s2,32(sp)
 db6:	ec4e                	sd	s3,24(sp)
 db8:	e852                	sd	s4,16(sp)
 dba:	e456                	sd	s5,8(sp)
 dbc:	e05a                	sd	s6,0(sp)
 dbe:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 dc0:	02051993          	slli	s3,a0,0x20
 dc4:	0209d993          	srli	s3,s3,0x20
 dc8:	09bd                	addi	s3,s3,15
 dca:	0049d993          	srli	s3,s3,0x4
 dce:	2985                	addiw	s3,s3,1
 dd0:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 dd4:	00000797          	auipc	a5,0x0
 dd8:	58c78793          	addi	a5,a5,1420 # 1360 <freep>
 ddc:	6388                	ld	a0,0(a5)
 dde:	c515                	beqz	a0,e0a <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 de0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 de2:	4798                	lw	a4,8(a5)
 de4:	03277f63          	bleu	s2,a4,e22 <malloc+0x76>
 de8:	8a4e                	mv	s4,s3
 dea:	0009871b          	sext.w	a4,s3
 dee:	6685                	lui	a3,0x1
 df0:	00d77363          	bleu	a3,a4,df6 <malloc+0x4a>
 df4:	6a05                	lui	s4,0x1
 df6:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 dfa:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 dfe:	00000497          	auipc	s1,0x0
 e02:	56248493          	addi	s1,s1,1378 # 1360 <freep>
  if(p == (char*)-1)
 e06:	5b7d                	li	s6,-1
 e08:	a885                	j	e78 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 e0a:	00000797          	auipc	a5,0x0
 e0e:	55e78793          	addi	a5,a5,1374 # 1368 <base>
 e12:	00000717          	auipc	a4,0x0
 e16:	54f73723          	sd	a5,1358(a4) # 1360 <freep>
 e1a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 e1c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 e20:	b7e1                	j	de8 <malloc+0x3c>
      if(p->s.size == nunits)
 e22:	02e90b63          	beq	s2,a4,e58 <malloc+0xac>
        p->s.size -= nunits;
 e26:	4137073b          	subw	a4,a4,s3
 e2a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 e2c:	1702                	slli	a4,a4,0x20
 e2e:	9301                	srli	a4,a4,0x20
 e30:	0712                	slli	a4,a4,0x4
 e32:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 e34:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 e38:	00000717          	auipc	a4,0x0
 e3c:	52a73423          	sd	a0,1320(a4) # 1360 <freep>
      return (void*)(p + 1);
 e40:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 e44:	70e2                	ld	ra,56(sp)
 e46:	7442                	ld	s0,48(sp)
 e48:	74a2                	ld	s1,40(sp)
 e4a:	7902                	ld	s2,32(sp)
 e4c:	69e2                	ld	s3,24(sp)
 e4e:	6a42                	ld	s4,16(sp)
 e50:	6aa2                	ld	s5,8(sp)
 e52:	6b02                	ld	s6,0(sp)
 e54:	6121                	addi	sp,sp,64
 e56:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 e58:	6398                	ld	a4,0(a5)
 e5a:	e118                	sd	a4,0(a0)
 e5c:	bff1                	j	e38 <malloc+0x8c>
  hp->s.size = nu;
 e5e:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 e62:	0541                	addi	a0,a0,16
 e64:	00000097          	auipc	ra,0x0
 e68:	ebe080e7          	jalr	-322(ra) # d22 <free>
  return freep;
 e6c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 e6e:	d979                	beqz	a0,e44 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e70:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 e72:	4798                	lw	a4,8(a5)
 e74:	fb2777e3          	bleu	s2,a4,e22 <malloc+0x76>
    if(p == freep)
 e78:	6098                	ld	a4,0(s1)
 e7a:	853e                	mv	a0,a5
 e7c:	fef71ae3          	bne	a4,a5,e70 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 e80:	8552                	mv	a0,s4
 e82:	00000097          	auipc	ra,0x0
 e86:	b72080e7          	jalr	-1166(ra) # 9f4 <sbrk>
  if(p == (char*)-1)
 e8a:	fd651ae3          	bne	a0,s6,e5e <malloc+0xb2>
        return 0;
 e8e:	4501                	li	a0,0
 e90:	bf55                	j	e44 <malloc+0x98>
