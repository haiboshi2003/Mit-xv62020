
user/_bcachetest：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <createfile>:
  exit(0);
}

void
createfile(char *file, int nblock)
{
   0:	bd010113          	addi	sp,sp,-1072
   4:	42113423          	sd	ra,1064(sp)
   8:	42813023          	sd	s0,1056(sp)
   c:	40913c23          	sd	s1,1048(sp)
  10:	41213823          	sd	s2,1040(sp)
  14:	41313423          	sd	s3,1032(sp)
  18:	41413023          	sd	s4,1024(sp)
  1c:	43010413          	addi	s0,sp,1072
  20:	8a2a                	mv	s4,a0
  22:	89ae                	mv	s3,a1
  int fd;
  char buf[BSIZE];
  int i;
  
  fd = open(file, O_CREATE | O_RDWR);
  24:	20200593          	li	a1,514
  28:	00001097          	auipc	ra,0x1
  2c:	806080e7          	jalr	-2042(ra) # 82e <open>
  if(fd < 0){
  30:	04054a63          	bltz	a0,84 <createfile+0x84>
  34:	892a                	mv	s2,a0
    printf("createfile %s failed\n", file);
    exit(-1);
  }
  for(i = 0; i < nblock; i++) {
  36:	4481                	li	s1,0
  38:	03305263          	blez	s3,5c <createfile+0x5c>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)) {
  3c:	40000613          	li	a2,1024
  40:	bd040593          	addi	a1,s0,-1072
  44:	854a                	mv	a0,s2
  46:	00000097          	auipc	ra,0x0
  4a:	7c8080e7          	jalr	1992(ra) # 80e <write>
  4e:	40000793          	li	a5,1024
  52:	04f51763          	bne	a0,a5,a0 <createfile+0xa0>
  for(i = 0; i < nblock; i++) {
  56:	2485                	addiw	s1,s1,1
  58:	fe9992e3          	bne	s3,s1,3c <createfile+0x3c>
      printf("write %s failed\n", file);
      exit(-1);
    }
  }
  close(fd);
  5c:	854a                	mv	a0,s2
  5e:	00000097          	auipc	ra,0x0
  62:	7b8080e7          	jalr	1976(ra) # 816 <close>
}
  66:	42813083          	ld	ra,1064(sp)
  6a:	42013403          	ld	s0,1056(sp)
  6e:	41813483          	ld	s1,1048(sp)
  72:	41013903          	ld	s2,1040(sp)
  76:	40813983          	ld	s3,1032(sp)
  7a:	40013a03          	ld	s4,1024(sp)
  7e:	43010113          	addi	sp,sp,1072
  82:	8082                	ret
    printf("createfile %s failed\n", file);
  84:	85d2                	mv	a1,s4
  86:	00001517          	auipc	a0,0x1
  8a:	d1250513          	addi	a0,a0,-750 # d98 <statistics+0x8c>
  8e:	00001097          	auipc	ra,0x1
  92:	ad8080e7          	jalr	-1320(ra) # b66 <printf>
    exit(-1);
  96:	557d                	li	a0,-1
  98:	00000097          	auipc	ra,0x0
  9c:	756080e7          	jalr	1878(ra) # 7ee <exit>
      printf("write %s failed\n", file);
  a0:	85d2                	mv	a1,s4
  a2:	00001517          	auipc	a0,0x1
  a6:	d0e50513          	addi	a0,a0,-754 # db0 <statistics+0xa4>
  aa:	00001097          	auipc	ra,0x1
  ae:	abc080e7          	jalr	-1348(ra) # b66 <printf>
      exit(-1);
  b2:	557d                	li	a0,-1
  b4:	00000097          	auipc	ra,0x0
  b8:	73a080e7          	jalr	1850(ra) # 7ee <exit>

00000000000000bc <readfile>:

void
readfile(char *file, int nbytes, int inc)
{
  bc:	bc010113          	addi	sp,sp,-1088
  c0:	42113c23          	sd	ra,1080(sp)
  c4:	42813823          	sd	s0,1072(sp)
  c8:	42913423          	sd	s1,1064(sp)
  cc:	43213023          	sd	s2,1056(sp)
  d0:	41313c23          	sd	s3,1048(sp)
  d4:	41413823          	sd	s4,1040(sp)
  d8:	41513423          	sd	s5,1032(sp)
  dc:	44010413          	addi	s0,sp,1088
  char buf[BSIZE];
  int fd;
  int i;

  if(inc > BSIZE) {
  e0:	40000793          	li	a5,1024
  e4:	06c7c463          	blt	a5,a2,14c <readfile+0x90>
  e8:	8aaa                	mv	s5,a0
  ea:	8a2e                	mv	s4,a1
  ec:	84b2                	mv	s1,a2
    printf("readfile: inc too large\n");
    exit(-1);
  }
  if ((fd = open(file, O_RDONLY)) < 0) {
  ee:	4581                	li	a1,0
  f0:	00000097          	auipc	ra,0x0
  f4:	73e080e7          	jalr	1854(ra) # 82e <open>
  f8:	89aa                	mv	s3,a0
  fa:	06054663          	bltz	a0,166 <readfile+0xaa>
    printf("readfile open %s failed\n", file);
    exit(-1);
  }
  for (i = 0; i < nbytes; i += inc) {
  fe:	4901                	li	s2,0
 100:	03405063          	blez	s4,120 <readfile+0x64>
    if(read(fd, buf, inc) != inc) {
 104:	8626                	mv	a2,s1
 106:	bc040593          	addi	a1,s0,-1088
 10a:	854e                	mv	a0,s3
 10c:	00000097          	auipc	ra,0x0
 110:	6fa080e7          	jalr	1786(ra) # 806 <read>
 114:	06951763          	bne	a0,s1,182 <readfile+0xc6>
  for (i = 0; i < nbytes; i += inc) {
 118:	0124893b          	addw	s2,s1,s2
 11c:	ff4944e3          	blt	s2,s4,104 <readfile+0x48>
      printf("read %s failed for block %d (%d)\n", file, i, nbytes);
      exit(-1);
    }
  }
  close(fd);
 120:	854e                	mv	a0,s3
 122:	00000097          	auipc	ra,0x0
 126:	6f4080e7          	jalr	1780(ra) # 816 <close>
}
 12a:	43813083          	ld	ra,1080(sp)
 12e:	43013403          	ld	s0,1072(sp)
 132:	42813483          	ld	s1,1064(sp)
 136:	42013903          	ld	s2,1056(sp)
 13a:	41813983          	ld	s3,1048(sp)
 13e:	41013a03          	ld	s4,1040(sp)
 142:	40813a83          	ld	s5,1032(sp)
 146:	44010113          	addi	sp,sp,1088
 14a:	8082                	ret
    printf("readfile: inc too large\n");
 14c:	00001517          	auipc	a0,0x1
 150:	c7c50513          	addi	a0,a0,-900 # dc8 <statistics+0xbc>
 154:	00001097          	auipc	ra,0x1
 158:	a12080e7          	jalr	-1518(ra) # b66 <printf>
    exit(-1);
 15c:	557d                	li	a0,-1
 15e:	00000097          	auipc	ra,0x0
 162:	690080e7          	jalr	1680(ra) # 7ee <exit>
    printf("readfile open %s failed\n", file);
 166:	85d6                	mv	a1,s5
 168:	00001517          	auipc	a0,0x1
 16c:	c8050513          	addi	a0,a0,-896 # de8 <statistics+0xdc>
 170:	00001097          	auipc	ra,0x1
 174:	9f6080e7          	jalr	-1546(ra) # b66 <printf>
    exit(-1);
 178:	557d                	li	a0,-1
 17a:	00000097          	auipc	ra,0x0
 17e:	674080e7          	jalr	1652(ra) # 7ee <exit>
      printf("read %s failed for block %d (%d)\n", file, i, nbytes);
 182:	86d2                	mv	a3,s4
 184:	864a                	mv	a2,s2
 186:	85d6                	mv	a1,s5
 188:	00001517          	auipc	a0,0x1
 18c:	c8050513          	addi	a0,a0,-896 # e08 <statistics+0xfc>
 190:	00001097          	auipc	ra,0x1
 194:	9d6080e7          	jalr	-1578(ra) # b66 <printf>
      exit(-1);
 198:	557d                	li	a0,-1
 19a:	00000097          	auipc	ra,0x0
 19e:	654080e7          	jalr	1620(ra) # 7ee <exit>

00000000000001a2 <ntas>:

int ntas(int print)
{
 1a2:	1101                	addi	sp,sp,-32
 1a4:	ec06                	sd	ra,24(sp)
 1a6:	e822                	sd	s0,16(sp)
 1a8:	e426                	sd	s1,8(sp)
 1aa:	e04a                	sd	s2,0(sp)
 1ac:	1000                	addi	s0,sp,32
 1ae:	892a                	mv	s2,a0
  int n;
  char *c;

  if (statistics(buf, SZ) <= 0) {
 1b0:	6585                	lui	a1,0x1
 1b2:	00001517          	auipc	a0,0x1
 1b6:	d6e50513          	addi	a0,a0,-658 # f20 <buf>
 1ba:	00001097          	auipc	ra,0x1
 1be:	b52080e7          	jalr	-1198(ra) # d0c <statistics>
 1c2:	02a05b63          	blez	a0,1f8 <ntas+0x56>
    fprintf(2, "ntas: no stats\n");
  }
  c = strchr(buf, '=');
 1c6:	03d00593          	li	a1,61
 1ca:	00001517          	auipc	a0,0x1
 1ce:	d5650513          	addi	a0,a0,-682 # f20 <buf>
 1d2:	00000097          	auipc	ra,0x0
 1d6:	42c080e7          	jalr	1068(ra) # 5fe <strchr>
  n = atoi(c+2);
 1da:	0509                	addi	a0,a0,2
 1dc:	00000097          	auipc	ra,0x0
 1e0:	506080e7          	jalr	1286(ra) # 6e2 <atoi>
 1e4:	84aa                	mv	s1,a0
  if(print)
 1e6:	02091363          	bnez	s2,20c <ntas+0x6a>
    printf("%s", buf);
  return n;
}
 1ea:	8526                	mv	a0,s1
 1ec:	60e2                	ld	ra,24(sp)
 1ee:	6442                	ld	s0,16(sp)
 1f0:	64a2                	ld	s1,8(sp)
 1f2:	6902                	ld	s2,0(sp)
 1f4:	6105                	addi	sp,sp,32
 1f6:	8082                	ret
    fprintf(2, "ntas: no stats\n");
 1f8:	00001597          	auipc	a1,0x1
 1fc:	c3858593          	addi	a1,a1,-968 # e30 <statistics+0x124>
 200:	4509                	li	a0,2
 202:	00001097          	auipc	ra,0x1
 206:	936080e7          	jalr	-1738(ra) # b38 <fprintf>
 20a:	bf75                	j	1c6 <ntas+0x24>
    printf("%s", buf);
 20c:	00001597          	auipc	a1,0x1
 210:	d1458593          	addi	a1,a1,-748 # f20 <buf>
 214:	00001517          	auipc	a0,0x1
 218:	c2c50513          	addi	a0,a0,-980 # e40 <statistics+0x134>
 21c:	00001097          	auipc	ra,0x1
 220:	94a080e7          	jalr	-1718(ra) # b66 <printf>
 224:	b7d9                	j	1ea <ntas+0x48>

0000000000000226 <test0>:

void
test0()
{
 226:	7139                	addi	sp,sp,-64
 228:	fc06                	sd	ra,56(sp)
 22a:	f822                	sd	s0,48(sp)
 22c:	f426                	sd	s1,40(sp)
 22e:	f04a                	sd	s2,32(sp)
 230:	ec4e                	sd	s3,24(sp)
 232:	0080                	addi	s0,sp,64
  char file[2];
  char dir[2];
  enum { N = 10, NCHILD = 3 };
  int m, n;

  dir[0] = '0';
 234:	03000793          	li	a5,48
 238:	fcf40023          	sb	a5,-64(s0)
  dir[1] = '\0';
 23c:	fc0400a3          	sb	zero,-63(s0)
  file[0] = 'F';
 240:	04600793          	li	a5,70
 244:	fcf40423          	sb	a5,-56(s0)
  file[1] = '\0';
 248:	fc0404a3          	sb	zero,-55(s0)

  printf("start test0\n");
 24c:	00001517          	auipc	a0,0x1
 250:	bfc50513          	addi	a0,a0,-1028 # e48 <statistics+0x13c>
 254:	00001097          	auipc	ra,0x1
 258:	912080e7          	jalr	-1774(ra) # b66 <printf>
 25c:	03000493          	li	s1,48
      printf("chdir failed\n");
      exit(1);
    }
    unlink(file);
    createfile(file, N);
    if (chdir("..") < 0) {
 260:	00001997          	auipc	s3,0x1
 264:	c0898993          	addi	s3,s3,-1016 # e68 <statistics+0x15c>
  for(int i = 0; i < NCHILD; i++){
 268:	03300913          	li	s2,51
    dir[0] = '0' + i;
 26c:	fc940023          	sb	s1,-64(s0)
    mkdir(dir);
 270:	fc040513          	addi	a0,s0,-64
 274:	00000097          	auipc	ra,0x0
 278:	5e2080e7          	jalr	1506(ra) # 856 <mkdir>
    if (chdir(dir) < 0) {
 27c:	fc040513          	addi	a0,s0,-64
 280:	00000097          	auipc	ra,0x0
 284:	5de080e7          	jalr	1502(ra) # 85e <chdir>
 288:	0c054463          	bltz	a0,350 <test0+0x12a>
    unlink(file);
 28c:	fc840513          	addi	a0,s0,-56
 290:	00000097          	auipc	ra,0x0
 294:	5ae080e7          	jalr	1454(ra) # 83e <unlink>
    createfile(file, N);
 298:	45a9                	li	a1,10
 29a:	fc840513          	addi	a0,s0,-56
 29e:	00000097          	auipc	ra,0x0
 2a2:	d62080e7          	jalr	-670(ra) # 0 <createfile>
    if (chdir("..") < 0) {
 2a6:	854e                	mv	a0,s3
 2a8:	00000097          	auipc	ra,0x0
 2ac:	5b6080e7          	jalr	1462(ra) # 85e <chdir>
 2b0:	0a054d63          	bltz	a0,36a <test0+0x144>
  for(int i = 0; i < NCHILD; i++){
 2b4:	2485                	addiw	s1,s1,1
 2b6:	0ff4f493          	andi	s1,s1,255
 2ba:	fb2499e3          	bne	s1,s2,26c <test0+0x46>
      printf("chdir failed\n");
      exit(1);
    }
  }
  m = ntas(0);
 2be:	4501                	li	a0,0
 2c0:	00000097          	auipc	ra,0x0
 2c4:	ee2080e7          	jalr	-286(ra) # 1a2 <ntas>
 2c8:	892a                	mv	s2,a0
 2ca:	03000493          	li	s1,48
  for(int i = 0; i < NCHILD; i++){
 2ce:	03300993          	li	s3,51
    dir[0] = '0' + i;
 2d2:	fc940023          	sb	s1,-64(s0)
    int pid = fork();
 2d6:	00000097          	auipc	ra,0x0
 2da:	510080e7          	jalr	1296(ra) # 7e6 <fork>
    if(pid < 0){
 2de:	0a054363          	bltz	a0,384 <test0+0x15e>
      printf("fork failed");
      exit(-1);
    }
    if(pid == 0){
 2e2:	cd55                	beqz	a0,39e <test0+0x178>
  for(int i = 0; i < NCHILD; i++){
 2e4:	2485                	addiw	s1,s1,1
 2e6:	0ff4f493          	andi	s1,s1,255
 2ea:	ff3494e3          	bne	s1,s3,2d2 <test0+0xac>
      exit(0);
    }
  }

  for(int i = 0; i < NCHILD; i++){
    wait(0);
 2ee:	4501                	li	a0,0
 2f0:	00000097          	auipc	ra,0x0
 2f4:	506080e7          	jalr	1286(ra) # 7f6 <wait>
 2f8:	4501                	li	a0,0
 2fa:	00000097          	auipc	ra,0x0
 2fe:	4fc080e7          	jalr	1276(ra) # 7f6 <wait>
 302:	4501                	li	a0,0
 304:	00000097          	auipc	ra,0x0
 308:	4f2080e7          	jalr	1266(ra) # 7f6 <wait>
  }
  printf("test0 results:\n");
 30c:	00001517          	auipc	a0,0x1
 310:	b7450513          	addi	a0,a0,-1164 # e80 <statistics+0x174>
 314:	00001097          	auipc	ra,0x1
 318:	852080e7          	jalr	-1966(ra) # b66 <printf>
  n = ntas(1);
 31c:	4505                	li	a0,1
 31e:	00000097          	auipc	ra,0x0
 322:	e84080e7          	jalr	-380(ra) # 1a2 <ntas>
  if (n-m < 500)
 326:	4125053b          	subw	a0,a0,s2
 32a:	1f300793          	li	a5,499
 32e:	0aa7cc63          	blt	a5,a0,3e6 <test0+0x1c0>
    printf("test0: OK\n");
 332:	00001517          	auipc	a0,0x1
 336:	b5e50513          	addi	a0,a0,-1186 # e90 <statistics+0x184>
 33a:	00001097          	auipc	ra,0x1
 33e:	82c080e7          	jalr	-2004(ra) # b66 <printf>
  else
    printf("test0: FAIL\n");
}
 342:	70e2                	ld	ra,56(sp)
 344:	7442                	ld	s0,48(sp)
 346:	74a2                	ld	s1,40(sp)
 348:	7902                	ld	s2,32(sp)
 34a:	69e2                	ld	s3,24(sp)
 34c:	6121                	addi	sp,sp,64
 34e:	8082                	ret
      printf("chdir failed\n");
 350:	00001517          	auipc	a0,0x1
 354:	b0850513          	addi	a0,a0,-1272 # e58 <statistics+0x14c>
 358:	00001097          	auipc	ra,0x1
 35c:	80e080e7          	jalr	-2034(ra) # b66 <printf>
      exit(1);
 360:	4505                	li	a0,1
 362:	00000097          	auipc	ra,0x0
 366:	48c080e7          	jalr	1164(ra) # 7ee <exit>
      printf("chdir failed\n");
 36a:	00001517          	auipc	a0,0x1
 36e:	aee50513          	addi	a0,a0,-1298 # e58 <statistics+0x14c>
 372:	00000097          	auipc	ra,0x0
 376:	7f4080e7          	jalr	2036(ra) # b66 <printf>
      exit(1);
 37a:	4505                	li	a0,1
 37c:	00000097          	auipc	ra,0x0
 380:	472080e7          	jalr	1138(ra) # 7ee <exit>
      printf("fork failed");
 384:	00001517          	auipc	a0,0x1
 388:	aec50513          	addi	a0,a0,-1300 # e70 <statistics+0x164>
 38c:	00000097          	auipc	ra,0x0
 390:	7da080e7          	jalr	2010(ra) # b66 <printf>
      exit(-1);
 394:	557d                	li	a0,-1
 396:	00000097          	auipc	ra,0x0
 39a:	458080e7          	jalr	1112(ra) # 7ee <exit>
      if (chdir(dir) < 0) {
 39e:	fc040513          	addi	a0,s0,-64
 3a2:	00000097          	auipc	ra,0x0
 3a6:	4bc080e7          	jalr	1212(ra) # 85e <chdir>
 3aa:	02054163          	bltz	a0,3cc <test0+0x1a6>
      readfile(file, N*BSIZE, 1);
 3ae:	4605                	li	a2,1
 3b0:	658d                	lui	a1,0x3
 3b2:	80058593          	addi	a1,a1,-2048 # 2800 <_end+0x8d0>
 3b6:	fc840513          	addi	a0,s0,-56
 3ba:	00000097          	auipc	ra,0x0
 3be:	d02080e7          	jalr	-766(ra) # bc <readfile>
      exit(0);
 3c2:	4501                	li	a0,0
 3c4:	00000097          	auipc	ra,0x0
 3c8:	42a080e7          	jalr	1066(ra) # 7ee <exit>
        printf("chdir failed\n");
 3cc:	00001517          	auipc	a0,0x1
 3d0:	a8c50513          	addi	a0,a0,-1396 # e58 <statistics+0x14c>
 3d4:	00000097          	auipc	ra,0x0
 3d8:	792080e7          	jalr	1938(ra) # b66 <printf>
        exit(1);
 3dc:	4505                	li	a0,1
 3de:	00000097          	auipc	ra,0x0
 3e2:	410080e7          	jalr	1040(ra) # 7ee <exit>
    printf("test0: FAIL\n");
 3e6:	00001517          	auipc	a0,0x1
 3ea:	aba50513          	addi	a0,a0,-1350 # ea0 <statistics+0x194>
 3ee:	00000097          	auipc	ra,0x0
 3f2:	778080e7          	jalr	1912(ra) # b66 <printf>
}
 3f6:	b7b1                	j	342 <test0+0x11c>

00000000000003f8 <test1>:

void test1()
{
 3f8:	7179                	addi	sp,sp,-48
 3fa:	f406                	sd	ra,40(sp)
 3fc:	f022                	sd	s0,32(sp)
 3fe:	ec26                	sd	s1,24(sp)
 400:	e84a                	sd	s2,16(sp)
 402:	1800                	addi	s0,sp,48
  char file[3];
  enum { N = 100, BIG=100, NCHILD=2 };
  
  printf("start test1\n");
 404:	00001517          	auipc	a0,0x1
 408:	aac50513          	addi	a0,a0,-1364 # eb0 <statistics+0x1a4>
 40c:	00000097          	auipc	ra,0x0
 410:	75a080e7          	jalr	1882(ra) # b66 <printf>
  file[0] = 'B';
 414:	04200793          	li	a5,66
 418:	fcf40c23          	sb	a5,-40(s0)
  file[2] = '\0';
 41c:	fc040d23          	sb	zero,-38(s0)
 420:	4485                	li	s1,1
  for(int i = 0; i < NCHILD; i++){
    file[1] = '0' + i;
    unlink(file);
    if (i == 0) {
 422:	4905                	li	s2,1
 424:	a811                	j	438 <test1+0x40>
      createfile(file, BIG);
 426:	06400593          	li	a1,100
 42a:	fd840513          	addi	a0,s0,-40
 42e:	00000097          	auipc	ra,0x0
 432:	bd2080e7          	jalr	-1070(ra) # 0 <createfile>
  for(int i = 0; i < NCHILD; i++){
 436:	2485                	addiw	s1,s1,1
    file[1] = '0' + i;
 438:	02f4879b          	addiw	a5,s1,47
 43c:	fcf40ca3          	sb	a5,-39(s0)
    unlink(file);
 440:	fd840513          	addi	a0,s0,-40
 444:	00000097          	auipc	ra,0x0
 448:	3fa080e7          	jalr	1018(ra) # 83e <unlink>
    if (i == 0) {
 44c:	fd248de3          	beq	s1,s2,426 <test1+0x2e>
    } else {
      createfile(file, 1);
 450:	85ca                	mv	a1,s2
 452:	fd840513          	addi	a0,s0,-40
 456:	00000097          	auipc	ra,0x0
 45a:	baa080e7          	jalr	-1110(ra) # 0 <createfile>
  for(int i = 0; i < NCHILD; i++){
 45e:	0004879b          	sext.w	a5,s1
 462:	fcf95ae3          	ble	a5,s2,436 <test1+0x3e>
    }
  }
  for(int i = 0; i < NCHILD; i++){
    file[1] = '0' + i;
 466:	03000793          	li	a5,48
 46a:	fcf40ca3          	sb	a5,-39(s0)
    int pid = fork();
 46e:	00000097          	auipc	ra,0x0
 472:	378080e7          	jalr	888(ra) # 7e6 <fork>
    if(pid < 0){
 476:	04054663          	bltz	a0,4c2 <test1+0xca>
      printf("fork failed");
      exit(-1);
    }
    if(pid == 0){
 47a:	c12d                	beqz	a0,4dc <test1+0xe4>
    file[1] = '0' + i;
 47c:	03100793          	li	a5,49
 480:	fcf40ca3          	sb	a5,-39(s0)
    int pid = fork();
 484:	00000097          	auipc	ra,0x0
 488:	362080e7          	jalr	866(ra) # 7e6 <fork>
    if(pid < 0){
 48c:	02054b63          	bltz	a0,4c2 <test1+0xca>
    if(pid == 0){
 490:	cd35                	beqz	a0,50c <test1+0x114>
      exit(0);
    }
  }

  for(int i = 0; i < NCHILD; i++){
    wait(0);
 492:	4501                	li	a0,0
 494:	00000097          	auipc	ra,0x0
 498:	362080e7          	jalr	866(ra) # 7f6 <wait>
 49c:	4501                	li	a0,0
 49e:	00000097          	auipc	ra,0x0
 4a2:	358080e7          	jalr	856(ra) # 7f6 <wait>
  }
  printf("test1 OK\n");
 4a6:	00001517          	auipc	a0,0x1
 4aa:	a1a50513          	addi	a0,a0,-1510 # ec0 <statistics+0x1b4>
 4ae:	00000097          	auipc	ra,0x0
 4b2:	6b8080e7          	jalr	1720(ra) # b66 <printf>
}
 4b6:	70a2                	ld	ra,40(sp)
 4b8:	7402                	ld	s0,32(sp)
 4ba:	64e2                	ld	s1,24(sp)
 4bc:	6942                	ld	s2,16(sp)
 4be:	6145                	addi	sp,sp,48
 4c0:	8082                	ret
      printf("fork failed");
 4c2:	00001517          	auipc	a0,0x1
 4c6:	9ae50513          	addi	a0,a0,-1618 # e70 <statistics+0x164>
 4ca:	00000097          	auipc	ra,0x0
 4ce:	69c080e7          	jalr	1692(ra) # b66 <printf>
      exit(-1);
 4d2:	557d                	li	a0,-1
 4d4:	00000097          	auipc	ra,0x0
 4d8:	31a080e7          	jalr	794(ra) # 7ee <exit>
    if(pid == 0){
 4dc:	06400493          	li	s1,100
          readfile(file, BIG*BSIZE, BSIZE);
 4e0:	40000613          	li	a2,1024
 4e4:	65e5                	lui	a1,0x19
 4e6:	fd840513          	addi	a0,s0,-40
 4ea:	00000097          	auipc	ra,0x0
 4ee:	bd2080e7          	jalr	-1070(ra) # bc <readfile>
        for (i = 0; i < N; i++) {
 4f2:	34fd                	addiw	s1,s1,-1
 4f4:	f4f5                	bnez	s1,4e0 <test1+0xe8>
        unlink(file);
 4f6:	fd840513          	addi	a0,s0,-40
 4fa:	00000097          	auipc	ra,0x0
 4fe:	344080e7          	jalr	836(ra) # 83e <unlink>
        exit(0);
 502:	4501                	li	a0,0
 504:	00000097          	auipc	ra,0x0
 508:	2ea080e7          	jalr	746(ra) # 7ee <exit>
 50c:	06400493          	li	s1,100
          readfile(file, 1, BSIZE);
 510:	40000613          	li	a2,1024
 514:	4585                	li	a1,1
 516:	fd840513          	addi	a0,s0,-40
 51a:	00000097          	auipc	ra,0x0
 51e:	ba2080e7          	jalr	-1118(ra) # bc <readfile>
        for (i = 0; i < N; i++) {
 522:	34fd                	addiw	s1,s1,-1
 524:	f4f5                	bnez	s1,510 <test1+0x118>
        unlink(file);
 526:	fd840513          	addi	a0,s0,-40
 52a:	00000097          	auipc	ra,0x0
 52e:	314080e7          	jalr	788(ra) # 83e <unlink>
      exit(0);
 532:	4501                	li	a0,0
 534:	00000097          	auipc	ra,0x0
 538:	2ba080e7          	jalr	698(ra) # 7ee <exit>

000000000000053c <main>:
{
 53c:	1141                	addi	sp,sp,-16
 53e:	e406                	sd	ra,8(sp)
 540:	e022                	sd	s0,0(sp)
 542:	0800                	addi	s0,sp,16
  test0();
 544:	00000097          	auipc	ra,0x0
 548:	ce2080e7          	jalr	-798(ra) # 226 <test0>
  test1();
 54c:	00000097          	auipc	ra,0x0
 550:	eac080e7          	jalr	-340(ra) # 3f8 <test1>
  exit(0);
 554:	4501                	li	a0,0
 556:	00000097          	auipc	ra,0x0
 55a:	298080e7          	jalr	664(ra) # 7ee <exit>

000000000000055e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 55e:	1141                	addi	sp,sp,-16
 560:	e422                	sd	s0,8(sp)
 562:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 564:	87aa                	mv	a5,a0
 566:	0585                	addi	a1,a1,1
 568:	0785                	addi	a5,a5,1
 56a:	fff5c703          	lbu	a4,-1(a1) # 18fff <_end+0x170cf>
 56e:	fee78fa3          	sb	a4,-1(a5)
 572:	fb75                	bnez	a4,566 <strcpy+0x8>
    ;
  return os;
}
 574:	6422                	ld	s0,8(sp)
 576:	0141                	addi	sp,sp,16
 578:	8082                	ret

000000000000057a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 57a:	1141                	addi	sp,sp,-16
 57c:	e422                	sd	s0,8(sp)
 57e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 580:	00054783          	lbu	a5,0(a0)
 584:	cf91                	beqz	a5,5a0 <strcmp+0x26>
 586:	0005c703          	lbu	a4,0(a1)
 58a:	00f71b63          	bne	a4,a5,5a0 <strcmp+0x26>
    p++, q++;
 58e:	0505                	addi	a0,a0,1
 590:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 592:	00054783          	lbu	a5,0(a0)
 596:	c789                	beqz	a5,5a0 <strcmp+0x26>
 598:	0005c703          	lbu	a4,0(a1)
 59c:	fef709e3          	beq	a4,a5,58e <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 5a0:	0005c503          	lbu	a0,0(a1)
}
 5a4:	40a7853b          	subw	a0,a5,a0
 5a8:	6422                	ld	s0,8(sp)
 5aa:	0141                	addi	sp,sp,16
 5ac:	8082                	ret

00000000000005ae <strlen>:

uint
strlen(const char *s)
{
 5ae:	1141                	addi	sp,sp,-16
 5b0:	e422                	sd	s0,8(sp)
 5b2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 5b4:	00054783          	lbu	a5,0(a0)
 5b8:	cf91                	beqz	a5,5d4 <strlen+0x26>
 5ba:	0505                	addi	a0,a0,1
 5bc:	87aa                	mv	a5,a0
 5be:	4685                	li	a3,1
 5c0:	9e89                	subw	a3,a3,a0
 5c2:	00f6853b          	addw	a0,a3,a5
 5c6:	0785                	addi	a5,a5,1
 5c8:	fff7c703          	lbu	a4,-1(a5)
 5cc:	fb7d                	bnez	a4,5c2 <strlen+0x14>
    ;
  return n;
}
 5ce:	6422                	ld	s0,8(sp)
 5d0:	0141                	addi	sp,sp,16
 5d2:	8082                	ret
  for(n = 0; s[n]; n++)
 5d4:	4501                	li	a0,0
 5d6:	bfe5                	j	5ce <strlen+0x20>

00000000000005d8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 5d8:	1141                	addi	sp,sp,-16
 5da:	e422                	sd	s0,8(sp)
 5dc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 5de:	ce09                	beqz	a2,5f8 <memset+0x20>
 5e0:	87aa                	mv	a5,a0
 5e2:	fff6071b          	addiw	a4,a2,-1
 5e6:	1702                	slli	a4,a4,0x20
 5e8:	9301                	srli	a4,a4,0x20
 5ea:	0705                	addi	a4,a4,1
 5ec:	972a                	add	a4,a4,a0
    cdst[i] = c;
 5ee:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 5f2:	0785                	addi	a5,a5,1
 5f4:	fee79de3          	bne	a5,a4,5ee <memset+0x16>
  }
  return dst;
}
 5f8:	6422                	ld	s0,8(sp)
 5fa:	0141                	addi	sp,sp,16
 5fc:	8082                	ret

00000000000005fe <strchr>:

char*
strchr(const char *s, char c)
{
 5fe:	1141                	addi	sp,sp,-16
 600:	e422                	sd	s0,8(sp)
 602:	0800                	addi	s0,sp,16
  for(; *s; s++)
 604:	00054783          	lbu	a5,0(a0)
 608:	cf91                	beqz	a5,624 <strchr+0x26>
    if(*s == c)
 60a:	00f58a63          	beq	a1,a5,61e <strchr+0x20>
  for(; *s; s++)
 60e:	0505                	addi	a0,a0,1
 610:	00054783          	lbu	a5,0(a0)
 614:	c781                	beqz	a5,61c <strchr+0x1e>
    if(*s == c)
 616:	feb79ce3          	bne	a5,a1,60e <strchr+0x10>
 61a:	a011                	j	61e <strchr+0x20>
      return (char*)s;
  return 0;
 61c:	4501                	li	a0,0
}
 61e:	6422                	ld	s0,8(sp)
 620:	0141                	addi	sp,sp,16
 622:	8082                	ret
  return 0;
 624:	4501                	li	a0,0
 626:	bfe5                	j	61e <strchr+0x20>

0000000000000628 <gets>:

char*
gets(char *buf, int max)
{
 628:	711d                	addi	sp,sp,-96
 62a:	ec86                	sd	ra,88(sp)
 62c:	e8a2                	sd	s0,80(sp)
 62e:	e4a6                	sd	s1,72(sp)
 630:	e0ca                	sd	s2,64(sp)
 632:	fc4e                	sd	s3,56(sp)
 634:	f852                	sd	s4,48(sp)
 636:	f456                	sd	s5,40(sp)
 638:	f05a                	sd	s6,32(sp)
 63a:	ec5e                	sd	s7,24(sp)
 63c:	1080                	addi	s0,sp,96
 63e:	8baa                	mv	s7,a0
 640:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 642:	892a                	mv	s2,a0
 644:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 646:	4aa9                	li	s5,10
 648:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 64a:	0019849b          	addiw	s1,s3,1
 64e:	0344d863          	ble	s4,s1,67e <gets+0x56>
    cc = read(0, &c, 1);
 652:	4605                	li	a2,1
 654:	faf40593          	addi	a1,s0,-81
 658:	4501                	li	a0,0
 65a:	00000097          	auipc	ra,0x0
 65e:	1ac080e7          	jalr	428(ra) # 806 <read>
    if(cc < 1)
 662:	00a05e63          	blez	a0,67e <gets+0x56>
    buf[i++] = c;
 666:	faf44783          	lbu	a5,-81(s0)
 66a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 66e:	01578763          	beq	a5,s5,67c <gets+0x54>
 672:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 674:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 676:	fd679ae3          	bne	a5,s6,64a <gets+0x22>
 67a:	a011                	j	67e <gets+0x56>
  for(i=0; i+1 < max; ){
 67c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 67e:	99de                	add	s3,s3,s7
 680:	00098023          	sb	zero,0(s3)
  return buf;
}
 684:	855e                	mv	a0,s7
 686:	60e6                	ld	ra,88(sp)
 688:	6446                	ld	s0,80(sp)
 68a:	64a6                	ld	s1,72(sp)
 68c:	6906                	ld	s2,64(sp)
 68e:	79e2                	ld	s3,56(sp)
 690:	7a42                	ld	s4,48(sp)
 692:	7aa2                	ld	s5,40(sp)
 694:	7b02                	ld	s6,32(sp)
 696:	6be2                	ld	s7,24(sp)
 698:	6125                	addi	sp,sp,96
 69a:	8082                	ret

000000000000069c <stat>:

int
stat(const char *n, struct stat *st)
{
 69c:	1101                	addi	sp,sp,-32
 69e:	ec06                	sd	ra,24(sp)
 6a0:	e822                	sd	s0,16(sp)
 6a2:	e426                	sd	s1,8(sp)
 6a4:	e04a                	sd	s2,0(sp)
 6a6:	1000                	addi	s0,sp,32
 6a8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6aa:	4581                	li	a1,0
 6ac:	00000097          	auipc	ra,0x0
 6b0:	182080e7          	jalr	386(ra) # 82e <open>
  if(fd < 0)
 6b4:	02054563          	bltz	a0,6de <stat+0x42>
 6b8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 6ba:	85ca                	mv	a1,s2
 6bc:	00000097          	auipc	ra,0x0
 6c0:	18a080e7          	jalr	394(ra) # 846 <fstat>
 6c4:	892a                	mv	s2,a0
  close(fd);
 6c6:	8526                	mv	a0,s1
 6c8:	00000097          	auipc	ra,0x0
 6cc:	14e080e7          	jalr	334(ra) # 816 <close>
  return r;
}
 6d0:	854a                	mv	a0,s2
 6d2:	60e2                	ld	ra,24(sp)
 6d4:	6442                	ld	s0,16(sp)
 6d6:	64a2                	ld	s1,8(sp)
 6d8:	6902                	ld	s2,0(sp)
 6da:	6105                	addi	sp,sp,32
 6dc:	8082                	ret
    return -1;
 6de:	597d                	li	s2,-1
 6e0:	bfc5                	j	6d0 <stat+0x34>

00000000000006e2 <atoi>:

int
atoi(const char *s)
{
 6e2:	1141                	addi	sp,sp,-16
 6e4:	e422                	sd	s0,8(sp)
 6e6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 6e8:	00054683          	lbu	a3,0(a0)
 6ec:	fd06879b          	addiw	a5,a3,-48
 6f0:	0ff7f793          	andi	a5,a5,255
 6f4:	4725                	li	a4,9
 6f6:	02f76963          	bltu	a4,a5,728 <atoi+0x46>
 6fa:	862a                	mv	a2,a0
  n = 0;
 6fc:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 6fe:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 700:	0605                	addi	a2,a2,1
 702:	0025179b          	slliw	a5,a0,0x2
 706:	9fa9                	addw	a5,a5,a0
 708:	0017979b          	slliw	a5,a5,0x1
 70c:	9fb5                	addw	a5,a5,a3
 70e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 712:	00064683          	lbu	a3,0(a2)
 716:	fd06871b          	addiw	a4,a3,-48
 71a:	0ff77713          	andi	a4,a4,255
 71e:	fee5f1e3          	bleu	a4,a1,700 <atoi+0x1e>
  return n;
}
 722:	6422                	ld	s0,8(sp)
 724:	0141                	addi	sp,sp,16
 726:	8082                	ret
  n = 0;
 728:	4501                	li	a0,0
 72a:	bfe5                	j	722 <atoi+0x40>

000000000000072c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 72c:	1141                	addi	sp,sp,-16
 72e:	e422                	sd	s0,8(sp)
 730:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 732:	02b57663          	bleu	a1,a0,75e <memmove+0x32>
    while(n-- > 0)
 736:	02c05163          	blez	a2,758 <memmove+0x2c>
 73a:	fff6079b          	addiw	a5,a2,-1
 73e:	1782                	slli	a5,a5,0x20
 740:	9381                	srli	a5,a5,0x20
 742:	0785                	addi	a5,a5,1
 744:	97aa                	add	a5,a5,a0
  dst = vdst;
 746:	872a                	mv	a4,a0
      *dst++ = *src++;
 748:	0585                	addi	a1,a1,1
 74a:	0705                	addi	a4,a4,1
 74c:	fff5c683          	lbu	a3,-1(a1)
 750:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 754:	fee79ae3          	bne	a5,a4,748 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 758:	6422                	ld	s0,8(sp)
 75a:	0141                	addi	sp,sp,16
 75c:	8082                	ret
    dst += n;
 75e:	00c50733          	add	a4,a0,a2
    src += n;
 762:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 764:	fec05ae3          	blez	a2,758 <memmove+0x2c>
 768:	fff6079b          	addiw	a5,a2,-1
 76c:	1782                	slli	a5,a5,0x20
 76e:	9381                	srli	a5,a5,0x20
 770:	fff7c793          	not	a5,a5
 774:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 776:	15fd                	addi	a1,a1,-1
 778:	177d                	addi	a4,a4,-1
 77a:	0005c683          	lbu	a3,0(a1)
 77e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 782:	fef71ae3          	bne	a4,a5,776 <memmove+0x4a>
 786:	bfc9                	j	758 <memmove+0x2c>

0000000000000788 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 788:	1141                	addi	sp,sp,-16
 78a:	e422                	sd	s0,8(sp)
 78c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 78e:	ce15                	beqz	a2,7ca <memcmp+0x42>
 790:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 794:	00054783          	lbu	a5,0(a0)
 798:	0005c703          	lbu	a4,0(a1)
 79c:	02e79063          	bne	a5,a4,7bc <memcmp+0x34>
 7a0:	1682                	slli	a3,a3,0x20
 7a2:	9281                	srli	a3,a3,0x20
 7a4:	0685                	addi	a3,a3,1
 7a6:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 7a8:	0505                	addi	a0,a0,1
    p2++;
 7aa:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 7ac:	00d50d63          	beq	a0,a3,7c6 <memcmp+0x3e>
    if (*p1 != *p2) {
 7b0:	00054783          	lbu	a5,0(a0)
 7b4:	0005c703          	lbu	a4,0(a1)
 7b8:	fee788e3          	beq	a5,a4,7a8 <memcmp+0x20>
      return *p1 - *p2;
 7bc:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 7c0:	6422                	ld	s0,8(sp)
 7c2:	0141                	addi	sp,sp,16
 7c4:	8082                	ret
  return 0;
 7c6:	4501                	li	a0,0
 7c8:	bfe5                	j	7c0 <memcmp+0x38>
 7ca:	4501                	li	a0,0
 7cc:	bfd5                	j	7c0 <memcmp+0x38>

00000000000007ce <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 7ce:	1141                	addi	sp,sp,-16
 7d0:	e406                	sd	ra,8(sp)
 7d2:	e022                	sd	s0,0(sp)
 7d4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 7d6:	00000097          	auipc	ra,0x0
 7da:	f56080e7          	jalr	-170(ra) # 72c <memmove>
}
 7de:	60a2                	ld	ra,8(sp)
 7e0:	6402                	ld	s0,0(sp)
 7e2:	0141                	addi	sp,sp,16
 7e4:	8082                	ret

00000000000007e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 7e6:	4885                	li	a7,1
 ecall
 7e8:	00000073          	ecall
 ret
 7ec:	8082                	ret

00000000000007ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 7ee:	4889                	li	a7,2
 ecall
 7f0:	00000073          	ecall
 ret
 7f4:	8082                	ret

00000000000007f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 7f6:	488d                	li	a7,3
 ecall
 7f8:	00000073          	ecall
 ret
 7fc:	8082                	ret

00000000000007fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 7fe:	4891                	li	a7,4
 ecall
 800:	00000073          	ecall
 ret
 804:	8082                	ret

0000000000000806 <read>:
.global read
read:
 li a7, SYS_read
 806:	4895                	li	a7,5
 ecall
 808:	00000073          	ecall
 ret
 80c:	8082                	ret

000000000000080e <write>:
.global write
write:
 li a7, SYS_write
 80e:	48c1                	li	a7,16
 ecall
 810:	00000073          	ecall
 ret
 814:	8082                	ret

0000000000000816 <close>:
.global close
close:
 li a7, SYS_close
 816:	48d5                	li	a7,21
 ecall
 818:	00000073          	ecall
 ret
 81c:	8082                	ret

000000000000081e <kill>:
.global kill
kill:
 li a7, SYS_kill
 81e:	4899                	li	a7,6
 ecall
 820:	00000073          	ecall
 ret
 824:	8082                	ret

0000000000000826 <exec>:
.global exec
exec:
 li a7, SYS_exec
 826:	489d                	li	a7,7
 ecall
 828:	00000073          	ecall
 ret
 82c:	8082                	ret

000000000000082e <open>:
.global open
open:
 li a7, SYS_open
 82e:	48bd                	li	a7,15
 ecall
 830:	00000073          	ecall
 ret
 834:	8082                	ret

0000000000000836 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 836:	48c5                	li	a7,17
 ecall
 838:	00000073          	ecall
 ret
 83c:	8082                	ret

000000000000083e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 83e:	48c9                	li	a7,18
 ecall
 840:	00000073          	ecall
 ret
 844:	8082                	ret

0000000000000846 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 846:	48a1                	li	a7,8
 ecall
 848:	00000073          	ecall
 ret
 84c:	8082                	ret

000000000000084e <link>:
.global link
link:
 li a7, SYS_link
 84e:	48cd                	li	a7,19
 ecall
 850:	00000073          	ecall
 ret
 854:	8082                	ret

0000000000000856 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 856:	48d1                	li	a7,20
 ecall
 858:	00000073          	ecall
 ret
 85c:	8082                	ret

000000000000085e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 85e:	48a5                	li	a7,9
 ecall
 860:	00000073          	ecall
 ret
 864:	8082                	ret

0000000000000866 <dup>:
.global dup
dup:
 li a7, SYS_dup
 866:	48a9                	li	a7,10
 ecall
 868:	00000073          	ecall
 ret
 86c:	8082                	ret

000000000000086e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 86e:	48ad                	li	a7,11
 ecall
 870:	00000073          	ecall
 ret
 874:	8082                	ret

0000000000000876 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 876:	48b1                	li	a7,12
 ecall
 878:	00000073          	ecall
 ret
 87c:	8082                	ret

000000000000087e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 87e:	48b5                	li	a7,13
 ecall
 880:	00000073          	ecall
 ret
 884:	8082                	ret

0000000000000886 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 886:	48b9                	li	a7,14
 ecall
 888:	00000073          	ecall
 ret
 88c:	8082                	ret

000000000000088e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 88e:	1101                	addi	sp,sp,-32
 890:	ec06                	sd	ra,24(sp)
 892:	e822                	sd	s0,16(sp)
 894:	1000                	addi	s0,sp,32
 896:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 89a:	4605                	li	a2,1
 89c:	fef40593          	addi	a1,s0,-17
 8a0:	00000097          	auipc	ra,0x0
 8a4:	f6e080e7          	jalr	-146(ra) # 80e <write>
}
 8a8:	60e2                	ld	ra,24(sp)
 8aa:	6442                	ld	s0,16(sp)
 8ac:	6105                	addi	sp,sp,32
 8ae:	8082                	ret

00000000000008b0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 8b0:	7139                	addi	sp,sp,-64
 8b2:	fc06                	sd	ra,56(sp)
 8b4:	f822                	sd	s0,48(sp)
 8b6:	f426                	sd	s1,40(sp)
 8b8:	f04a                	sd	s2,32(sp)
 8ba:	ec4e                	sd	s3,24(sp)
 8bc:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 8be:	c299                	beqz	a3,8c4 <printint+0x14>
 8c0:	0005cd63          	bltz	a1,8da <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 8c4:	2581                	sext.w	a1,a1
  neg = 0;
 8c6:	4301                	li	t1,0
 8c8:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 8cc:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 8ce:	2601                	sext.w	a2,a2
 8d0:	00000897          	auipc	a7,0x0
 8d4:	60088893          	addi	a7,a7,1536 # ed0 <digits>
 8d8:	a801                	j	8e8 <printint+0x38>
    x = -xx;
 8da:	40b005bb          	negw	a1,a1
 8de:	2581                	sext.w	a1,a1
    neg = 1;
 8e0:	4305                	li	t1,1
    x = -xx;
 8e2:	b7dd                	j	8c8 <printint+0x18>
  }while((x /= base) != 0);
 8e4:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 8e6:	8836                	mv	a6,a3
 8e8:	0018069b          	addiw	a3,a6,1
 8ec:	02c5f7bb          	remuw	a5,a1,a2
 8f0:	1782                	slli	a5,a5,0x20
 8f2:	9381                	srli	a5,a5,0x20
 8f4:	97c6                	add	a5,a5,a7
 8f6:	0007c783          	lbu	a5,0(a5)
 8fa:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 8fe:	0705                	addi	a4,a4,1
 900:	02c5d7bb          	divuw	a5,a1,a2
 904:	fec5f0e3          	bleu	a2,a1,8e4 <printint+0x34>
  if(neg)
 908:	00030b63          	beqz	t1,91e <printint+0x6e>
    buf[i++] = '-';
 90c:	fd040793          	addi	a5,s0,-48
 910:	96be                	add	a3,a3,a5
 912:	02d00793          	li	a5,45
 916:	fef68823          	sb	a5,-16(a3)
 91a:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 91e:	02d05963          	blez	a3,950 <printint+0xa0>
 922:	89aa                	mv	s3,a0
 924:	fc040793          	addi	a5,s0,-64
 928:	00d784b3          	add	s1,a5,a3
 92c:	fff78913          	addi	s2,a5,-1
 930:	9936                	add	s2,s2,a3
 932:	36fd                	addiw	a3,a3,-1
 934:	1682                	slli	a3,a3,0x20
 936:	9281                	srli	a3,a3,0x20
 938:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 93c:	fff4c583          	lbu	a1,-1(s1)
 940:	854e                	mv	a0,s3
 942:	00000097          	auipc	ra,0x0
 946:	f4c080e7          	jalr	-180(ra) # 88e <putc>
  while(--i >= 0)
 94a:	14fd                	addi	s1,s1,-1
 94c:	ff2498e3          	bne	s1,s2,93c <printint+0x8c>
}
 950:	70e2                	ld	ra,56(sp)
 952:	7442                	ld	s0,48(sp)
 954:	74a2                	ld	s1,40(sp)
 956:	7902                	ld	s2,32(sp)
 958:	69e2                	ld	s3,24(sp)
 95a:	6121                	addi	sp,sp,64
 95c:	8082                	ret

000000000000095e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 95e:	7119                	addi	sp,sp,-128
 960:	fc86                	sd	ra,120(sp)
 962:	f8a2                	sd	s0,112(sp)
 964:	f4a6                	sd	s1,104(sp)
 966:	f0ca                	sd	s2,96(sp)
 968:	ecce                	sd	s3,88(sp)
 96a:	e8d2                	sd	s4,80(sp)
 96c:	e4d6                	sd	s5,72(sp)
 96e:	e0da                	sd	s6,64(sp)
 970:	fc5e                	sd	s7,56(sp)
 972:	f862                	sd	s8,48(sp)
 974:	f466                	sd	s9,40(sp)
 976:	f06a                	sd	s10,32(sp)
 978:	ec6e                	sd	s11,24(sp)
 97a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 97c:	0005c483          	lbu	s1,0(a1)
 980:	18048d63          	beqz	s1,b1a <vprintf+0x1bc>
 984:	8aaa                	mv	s5,a0
 986:	8b32                	mv	s6,a2
 988:	00158913          	addi	s2,a1,1
  state = 0;
 98c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 98e:	02500a13          	li	s4,37
      if(c == 'd'){
 992:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 996:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 99a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 99e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9a2:	00000b97          	auipc	s7,0x0
 9a6:	52eb8b93          	addi	s7,s7,1326 # ed0 <digits>
 9aa:	a839                	j	9c8 <vprintf+0x6a>
        putc(fd, c);
 9ac:	85a6                	mv	a1,s1
 9ae:	8556                	mv	a0,s5
 9b0:	00000097          	auipc	ra,0x0
 9b4:	ede080e7          	jalr	-290(ra) # 88e <putc>
 9b8:	a019                	j	9be <vprintf+0x60>
    } else if(state == '%'){
 9ba:	01498f63          	beq	s3,s4,9d8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 9be:	0905                	addi	s2,s2,1
 9c0:	fff94483          	lbu	s1,-1(s2)
 9c4:	14048b63          	beqz	s1,b1a <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 9c8:	0004879b          	sext.w	a5,s1
    if(state == 0){
 9cc:	fe0997e3          	bnez	s3,9ba <vprintf+0x5c>
      if(c == '%'){
 9d0:	fd479ee3          	bne	a5,s4,9ac <vprintf+0x4e>
        state = '%';
 9d4:	89be                	mv	s3,a5
 9d6:	b7e5                	j	9be <vprintf+0x60>
      if(c == 'd'){
 9d8:	05878063          	beq	a5,s8,a18 <vprintf+0xba>
      } else if(c == 'l') {
 9dc:	05978c63          	beq	a5,s9,a34 <vprintf+0xd6>
      } else if(c == 'x') {
 9e0:	07a78863          	beq	a5,s10,a50 <vprintf+0xf2>
      } else if(c == 'p') {
 9e4:	09b78463          	beq	a5,s11,a6c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 9e8:	07300713          	li	a4,115
 9ec:	0ce78563          	beq	a5,a4,ab6 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 9f0:	06300713          	li	a4,99
 9f4:	0ee78c63          	beq	a5,a4,aec <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 9f8:	11478663          	beq	a5,s4,b04 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 9fc:	85d2                	mv	a1,s4
 9fe:	8556                	mv	a0,s5
 a00:	00000097          	auipc	ra,0x0
 a04:	e8e080e7          	jalr	-370(ra) # 88e <putc>
        putc(fd, c);
 a08:	85a6                	mv	a1,s1
 a0a:	8556                	mv	a0,s5
 a0c:	00000097          	auipc	ra,0x0
 a10:	e82080e7          	jalr	-382(ra) # 88e <putc>
      }
      state = 0;
 a14:	4981                	li	s3,0
 a16:	b765                	j	9be <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 a18:	008b0493          	addi	s1,s6,8
 a1c:	4685                	li	a3,1
 a1e:	4629                	li	a2,10
 a20:	000b2583          	lw	a1,0(s6)
 a24:	8556                	mv	a0,s5
 a26:	00000097          	auipc	ra,0x0
 a2a:	e8a080e7          	jalr	-374(ra) # 8b0 <printint>
 a2e:	8b26                	mv	s6,s1
      state = 0;
 a30:	4981                	li	s3,0
 a32:	b771                	j	9be <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 a34:	008b0493          	addi	s1,s6,8
 a38:	4681                	li	a3,0
 a3a:	4629                	li	a2,10
 a3c:	000b2583          	lw	a1,0(s6)
 a40:	8556                	mv	a0,s5
 a42:	00000097          	auipc	ra,0x0
 a46:	e6e080e7          	jalr	-402(ra) # 8b0 <printint>
 a4a:	8b26                	mv	s6,s1
      state = 0;
 a4c:	4981                	li	s3,0
 a4e:	bf85                	j	9be <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 a50:	008b0493          	addi	s1,s6,8
 a54:	4681                	li	a3,0
 a56:	4641                	li	a2,16
 a58:	000b2583          	lw	a1,0(s6)
 a5c:	8556                	mv	a0,s5
 a5e:	00000097          	auipc	ra,0x0
 a62:	e52080e7          	jalr	-430(ra) # 8b0 <printint>
 a66:	8b26                	mv	s6,s1
      state = 0;
 a68:	4981                	li	s3,0
 a6a:	bf91                	j	9be <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 a6c:	008b0793          	addi	a5,s6,8
 a70:	f8f43423          	sd	a5,-120(s0)
 a74:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 a78:	03000593          	li	a1,48
 a7c:	8556                	mv	a0,s5
 a7e:	00000097          	auipc	ra,0x0
 a82:	e10080e7          	jalr	-496(ra) # 88e <putc>
  putc(fd, 'x');
 a86:	85ea                	mv	a1,s10
 a88:	8556                	mv	a0,s5
 a8a:	00000097          	auipc	ra,0x0
 a8e:	e04080e7          	jalr	-508(ra) # 88e <putc>
 a92:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a94:	03c9d793          	srli	a5,s3,0x3c
 a98:	97de                	add	a5,a5,s7
 a9a:	0007c583          	lbu	a1,0(a5)
 a9e:	8556                	mv	a0,s5
 aa0:	00000097          	auipc	ra,0x0
 aa4:	dee080e7          	jalr	-530(ra) # 88e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 aa8:	0992                	slli	s3,s3,0x4
 aaa:	34fd                	addiw	s1,s1,-1
 aac:	f4e5                	bnez	s1,a94 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 aae:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 ab2:	4981                	li	s3,0
 ab4:	b729                	j	9be <vprintf+0x60>
        s = va_arg(ap, char*);
 ab6:	008b0993          	addi	s3,s6,8
 aba:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 abe:	c085                	beqz	s1,ade <vprintf+0x180>
        while(*s != 0){
 ac0:	0004c583          	lbu	a1,0(s1)
 ac4:	c9a1                	beqz	a1,b14 <vprintf+0x1b6>
          putc(fd, *s);
 ac6:	8556                	mv	a0,s5
 ac8:	00000097          	auipc	ra,0x0
 acc:	dc6080e7          	jalr	-570(ra) # 88e <putc>
          s++;
 ad0:	0485                	addi	s1,s1,1
        while(*s != 0){
 ad2:	0004c583          	lbu	a1,0(s1)
 ad6:	f9e5                	bnez	a1,ac6 <vprintf+0x168>
        s = va_arg(ap, char*);
 ad8:	8b4e                	mv	s6,s3
      state = 0;
 ada:	4981                	li	s3,0
 adc:	b5cd                	j	9be <vprintf+0x60>
          s = "(null)";
 ade:	00000497          	auipc	s1,0x0
 ae2:	40a48493          	addi	s1,s1,1034 # ee8 <digits+0x18>
        while(*s != 0){
 ae6:	02800593          	li	a1,40
 aea:	bff1                	j	ac6 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 aec:	008b0493          	addi	s1,s6,8
 af0:	000b4583          	lbu	a1,0(s6)
 af4:	8556                	mv	a0,s5
 af6:	00000097          	auipc	ra,0x0
 afa:	d98080e7          	jalr	-616(ra) # 88e <putc>
 afe:	8b26                	mv	s6,s1
      state = 0;
 b00:	4981                	li	s3,0
 b02:	bd75                	j	9be <vprintf+0x60>
        putc(fd, c);
 b04:	85d2                	mv	a1,s4
 b06:	8556                	mv	a0,s5
 b08:	00000097          	auipc	ra,0x0
 b0c:	d86080e7          	jalr	-634(ra) # 88e <putc>
      state = 0;
 b10:	4981                	li	s3,0
 b12:	b575                	j	9be <vprintf+0x60>
        s = va_arg(ap, char*);
 b14:	8b4e                	mv	s6,s3
      state = 0;
 b16:	4981                	li	s3,0
 b18:	b55d                	j	9be <vprintf+0x60>
    }
  }
}
 b1a:	70e6                	ld	ra,120(sp)
 b1c:	7446                	ld	s0,112(sp)
 b1e:	74a6                	ld	s1,104(sp)
 b20:	7906                	ld	s2,96(sp)
 b22:	69e6                	ld	s3,88(sp)
 b24:	6a46                	ld	s4,80(sp)
 b26:	6aa6                	ld	s5,72(sp)
 b28:	6b06                	ld	s6,64(sp)
 b2a:	7be2                	ld	s7,56(sp)
 b2c:	7c42                	ld	s8,48(sp)
 b2e:	7ca2                	ld	s9,40(sp)
 b30:	7d02                	ld	s10,32(sp)
 b32:	6de2                	ld	s11,24(sp)
 b34:	6109                	addi	sp,sp,128
 b36:	8082                	ret

0000000000000b38 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 b38:	715d                	addi	sp,sp,-80
 b3a:	ec06                	sd	ra,24(sp)
 b3c:	e822                	sd	s0,16(sp)
 b3e:	1000                	addi	s0,sp,32
 b40:	e010                	sd	a2,0(s0)
 b42:	e414                	sd	a3,8(s0)
 b44:	e818                	sd	a4,16(s0)
 b46:	ec1c                	sd	a5,24(s0)
 b48:	03043023          	sd	a6,32(s0)
 b4c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 b50:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 b54:	8622                	mv	a2,s0
 b56:	00000097          	auipc	ra,0x0
 b5a:	e08080e7          	jalr	-504(ra) # 95e <vprintf>
}
 b5e:	60e2                	ld	ra,24(sp)
 b60:	6442                	ld	s0,16(sp)
 b62:	6161                	addi	sp,sp,80
 b64:	8082                	ret

0000000000000b66 <printf>:

void
printf(const char *fmt, ...)
{
 b66:	711d                	addi	sp,sp,-96
 b68:	ec06                	sd	ra,24(sp)
 b6a:	e822                	sd	s0,16(sp)
 b6c:	1000                	addi	s0,sp,32
 b6e:	e40c                	sd	a1,8(s0)
 b70:	e810                	sd	a2,16(s0)
 b72:	ec14                	sd	a3,24(s0)
 b74:	f018                	sd	a4,32(s0)
 b76:	f41c                	sd	a5,40(s0)
 b78:	03043823          	sd	a6,48(s0)
 b7c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b80:	00840613          	addi	a2,s0,8
 b84:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b88:	85aa                	mv	a1,a0
 b8a:	4505                	li	a0,1
 b8c:	00000097          	auipc	ra,0x0
 b90:	dd2080e7          	jalr	-558(ra) # 95e <vprintf>
}
 b94:	60e2                	ld	ra,24(sp)
 b96:	6442                	ld	s0,16(sp)
 b98:	6125                	addi	sp,sp,96
 b9a:	8082                	ret

0000000000000b9c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b9c:	1141                	addi	sp,sp,-16
 b9e:	e422                	sd	s0,8(sp)
 ba0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ba2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ba6:	00000797          	auipc	a5,0x0
 baa:	37278793          	addi	a5,a5,882 # f18 <__bss_start>
 bae:	639c                	ld	a5,0(a5)
 bb0:	a805                	j	be0 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 bb2:	4618                	lw	a4,8(a2)
 bb4:	9db9                	addw	a1,a1,a4
 bb6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 bba:	6398                	ld	a4,0(a5)
 bbc:	6318                	ld	a4,0(a4)
 bbe:	fee53823          	sd	a4,-16(a0)
 bc2:	a091                	j	c06 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 bc4:	ff852703          	lw	a4,-8(a0)
 bc8:	9e39                	addw	a2,a2,a4
 bca:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 bcc:	ff053703          	ld	a4,-16(a0)
 bd0:	e398                	sd	a4,0(a5)
 bd2:	a099                	j	c18 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bd4:	6398                	ld	a4,0(a5)
 bd6:	00e7e463          	bltu	a5,a4,bde <free+0x42>
 bda:	00e6ea63          	bltu	a3,a4,bee <free+0x52>
{
 bde:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 be0:	fed7fae3          	bleu	a3,a5,bd4 <free+0x38>
 be4:	6398                	ld	a4,0(a5)
 be6:	00e6e463          	bltu	a3,a4,bee <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bea:	fee7eae3          	bltu	a5,a4,bde <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 bee:	ff852583          	lw	a1,-8(a0)
 bf2:	6390                	ld	a2,0(a5)
 bf4:	02059713          	slli	a4,a1,0x20
 bf8:	9301                	srli	a4,a4,0x20
 bfa:	0712                	slli	a4,a4,0x4
 bfc:	9736                	add	a4,a4,a3
 bfe:	fae60ae3          	beq	a2,a4,bb2 <free+0x16>
    bp->s.ptr = p->s.ptr;
 c02:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 c06:	4790                	lw	a2,8(a5)
 c08:	02061713          	slli	a4,a2,0x20
 c0c:	9301                	srli	a4,a4,0x20
 c0e:	0712                	slli	a4,a4,0x4
 c10:	973e                	add	a4,a4,a5
 c12:	fae689e3          	beq	a3,a4,bc4 <free+0x28>
  } else
    p->s.ptr = bp;
 c16:	e394                	sd	a3,0(a5)
  freep = p;
 c18:	00000717          	auipc	a4,0x0
 c1c:	30f73023          	sd	a5,768(a4) # f18 <__bss_start>
}
 c20:	6422                	ld	s0,8(sp)
 c22:	0141                	addi	sp,sp,16
 c24:	8082                	ret

0000000000000c26 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 c26:	7139                	addi	sp,sp,-64
 c28:	fc06                	sd	ra,56(sp)
 c2a:	f822                	sd	s0,48(sp)
 c2c:	f426                	sd	s1,40(sp)
 c2e:	f04a                	sd	s2,32(sp)
 c30:	ec4e                	sd	s3,24(sp)
 c32:	e852                	sd	s4,16(sp)
 c34:	e456                	sd	s5,8(sp)
 c36:	e05a                	sd	s6,0(sp)
 c38:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c3a:	02051993          	slli	s3,a0,0x20
 c3e:	0209d993          	srli	s3,s3,0x20
 c42:	09bd                	addi	s3,s3,15
 c44:	0049d993          	srli	s3,s3,0x4
 c48:	2985                	addiw	s3,s3,1
 c4a:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 c4e:	00000797          	auipc	a5,0x0
 c52:	2ca78793          	addi	a5,a5,714 # f18 <__bss_start>
 c56:	6388                	ld	a0,0(a5)
 c58:	c515                	beqz	a0,c84 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c5a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c5c:	4798                	lw	a4,8(a5)
 c5e:	03277f63          	bleu	s2,a4,c9c <malloc+0x76>
 c62:	8a4e                	mv	s4,s3
 c64:	0009871b          	sext.w	a4,s3
 c68:	6685                	lui	a3,0x1
 c6a:	00d77363          	bleu	a3,a4,c70 <malloc+0x4a>
 c6e:	6a05                	lui	s4,0x1
 c70:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 c74:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 c78:	00000497          	auipc	s1,0x0
 c7c:	2a048493          	addi	s1,s1,672 # f18 <__bss_start>
  if(p == (char*)-1)
 c80:	5b7d                	li	s6,-1
 c82:	a885                	j	cf2 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 c84:	00001797          	auipc	a5,0x1
 c88:	29c78793          	addi	a5,a5,668 # 1f20 <base>
 c8c:	00000717          	auipc	a4,0x0
 c90:	28f73623          	sd	a5,652(a4) # f18 <__bss_start>
 c94:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c96:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 c9a:	b7e1                	j	c62 <malloc+0x3c>
      if(p->s.size == nunits)
 c9c:	02e90b63          	beq	s2,a4,cd2 <malloc+0xac>
        p->s.size -= nunits;
 ca0:	4137073b          	subw	a4,a4,s3
 ca4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ca6:	1702                	slli	a4,a4,0x20
 ca8:	9301                	srli	a4,a4,0x20
 caa:	0712                	slli	a4,a4,0x4
 cac:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 cae:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 cb2:	00000717          	auipc	a4,0x0
 cb6:	26a73323          	sd	a0,614(a4) # f18 <__bss_start>
      return (void*)(p + 1);
 cba:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 cbe:	70e2                	ld	ra,56(sp)
 cc0:	7442                	ld	s0,48(sp)
 cc2:	74a2                	ld	s1,40(sp)
 cc4:	7902                	ld	s2,32(sp)
 cc6:	69e2                	ld	s3,24(sp)
 cc8:	6a42                	ld	s4,16(sp)
 cca:	6aa2                	ld	s5,8(sp)
 ccc:	6b02                	ld	s6,0(sp)
 cce:	6121                	addi	sp,sp,64
 cd0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 cd2:	6398                	ld	a4,0(a5)
 cd4:	e118                	sd	a4,0(a0)
 cd6:	bff1                	j	cb2 <malloc+0x8c>
  hp->s.size = nu;
 cd8:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 cdc:	0541                	addi	a0,a0,16
 cde:	00000097          	auipc	ra,0x0
 ce2:	ebe080e7          	jalr	-322(ra) # b9c <free>
  return freep;
 ce6:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 ce8:	d979                	beqz	a0,cbe <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cea:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 cec:	4798                	lw	a4,8(a5)
 cee:	fb2777e3          	bleu	s2,a4,c9c <malloc+0x76>
    if(p == freep)
 cf2:	6098                	ld	a4,0(s1)
 cf4:	853e                	mv	a0,a5
 cf6:	fef71ae3          	bne	a4,a5,cea <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 cfa:	8552                	mv	a0,s4
 cfc:	00000097          	auipc	ra,0x0
 d00:	b7a080e7          	jalr	-1158(ra) # 876 <sbrk>
  if(p == (char*)-1)
 d04:	fd651ae3          	bne	a0,s6,cd8 <malloc+0xb2>
        return 0;
 d08:	4501                	li	a0,0
 d0a:	bf55                	j	cbe <malloc+0x98>

0000000000000d0c <statistics>:
#include "kernel/fcntl.h"
#include "user/user.h"

int
statistics(void *buf, int sz)
{
 d0c:	7179                	addi	sp,sp,-48
 d0e:	f406                	sd	ra,40(sp)
 d10:	f022                	sd	s0,32(sp)
 d12:	ec26                	sd	s1,24(sp)
 d14:	e84a                	sd	s2,16(sp)
 d16:	e44e                	sd	s3,8(sp)
 d18:	e052                	sd	s4,0(sp)
 d1a:	1800                	addi	s0,sp,48
 d1c:	8a2a                	mv	s4,a0
 d1e:	892e                	mv	s2,a1
  int fd, i, n;
  
  fd = open("statistics", O_RDONLY);
 d20:	4581                	li	a1,0
 d22:	00000517          	auipc	a0,0x0
 d26:	1ce50513          	addi	a0,a0,462 # ef0 <digits+0x20>
 d2a:	00000097          	auipc	ra,0x0
 d2e:	b04080e7          	jalr	-1276(ra) # 82e <open>
  if(fd < 0) {
 d32:	04054263          	bltz	a0,d76 <statistics+0x6a>
 d36:	89aa                	mv	s3,a0
      fprintf(2, "stats: open failed\n");
      exit(1);
  }
  for (i = 0; i < sz; ) {
 d38:	4481                	li	s1,0
 d3a:	03205063          	blez	s2,d5a <statistics+0x4e>
    if ((n = read(fd, buf+i, sz-i)) < 0) {
 d3e:	4099063b          	subw	a2,s2,s1
 d42:	009a05b3          	add	a1,s4,s1
 d46:	854e                	mv	a0,s3
 d48:	00000097          	auipc	ra,0x0
 d4c:	abe080e7          	jalr	-1346(ra) # 806 <read>
 d50:	00054563          	bltz	a0,d5a <statistics+0x4e>
      break;
    }
    i += n;
 d54:	9ca9                	addw	s1,s1,a0
  for (i = 0; i < sz; ) {
 d56:	ff24c4e3          	blt	s1,s2,d3e <statistics+0x32>
  }
  close(fd);
 d5a:	854e                	mv	a0,s3
 d5c:	00000097          	auipc	ra,0x0
 d60:	aba080e7          	jalr	-1350(ra) # 816 <close>
  return i;
}
 d64:	8526                	mv	a0,s1
 d66:	70a2                	ld	ra,40(sp)
 d68:	7402                	ld	s0,32(sp)
 d6a:	64e2                	ld	s1,24(sp)
 d6c:	6942                	ld	s2,16(sp)
 d6e:	69a2                	ld	s3,8(sp)
 d70:	6a02                	ld	s4,0(sp)
 d72:	6145                	addi	sp,sp,48
 d74:	8082                	ret
      fprintf(2, "stats: open failed\n");
 d76:	00000597          	auipc	a1,0x0
 d7a:	18a58593          	addi	a1,a1,394 # f00 <digits+0x30>
 d7e:	4509                	li	a0,2
 d80:	00000097          	auipc	ra,0x0
 d84:	db8080e7          	jalr	-584(ra) # b38 <fprintf>
      exit(1);
 d88:	4505                	li	a0,1
 d8a:	00000097          	auipc	ra,0x0
 d8e:	a64080e7          	jalr	-1436(ra) # 7ee <exit>
