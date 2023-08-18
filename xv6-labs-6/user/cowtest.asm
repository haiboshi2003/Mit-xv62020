
user/_cowtest：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <simpletest>:
// allocate more than half of physical memory,
// then fork. this will fail in the default
// kernel, which does not support copy-on-write.
void
simpletest()
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  uint64 phys_size = PHYSTOP - KERNBASE;
  int sz = (phys_size / 3) * 2;

  printf("simple: ");
   e:	00001517          	auipc	a0,0x1
  12:	c7a50513          	addi	a0,a0,-902 # c88 <malloc+0xe8>
  16:	00001097          	auipc	ra,0x1
  1a:	aca080e7          	jalr	-1334(ra) # ae0 <printf>
  
  char *p = sbrk(sz);
  1e:	05555537          	lui	a0,0x5555
  22:	55450513          	addi	a0,a0,1364 # 5555554 <_end+0x555075c>
  26:	00000097          	auipc	ra,0x0
  2a:	7ca080e7          	jalr	1994(ra) # 7f0 <sbrk>
  if(p == (char*)0xffffffffffffffffL){
  2e:	57fd                	li	a5,-1
  30:	06f50563          	beq	a0,a5,9a <simpletest+0x9a>
  34:	84aa                	mv	s1,a0
    printf("sbrk(%d) failed\n", sz);
    exit(-1);
  }

  for(char *q = p; q < p + sz; q += 4096){
  36:	05556937          	lui	s2,0x5556
  3a:	992a                	add	s2,s2,a0
  3c:	6985                	lui	s3,0x1
    *(int*)q = getpid();
  3e:	00000097          	auipc	ra,0x0
  42:	7aa080e7          	jalr	1962(ra) # 7e8 <getpid>
  46:	c088                	sw	a0,0(s1)
  for(char *q = p; q < p + sz; q += 4096){
  48:	94ce                	add	s1,s1,s3
  4a:	ff249ae3          	bne	s1,s2,3e <simpletest+0x3e>
  }

  int pid = fork();
  4e:	00000097          	auipc	ra,0x0
  52:	712080e7          	jalr	1810(ra) # 760 <fork>
  if(pid < 0){
  56:	06054363          	bltz	a0,bc <simpletest+0xbc>
    printf("fork() failed\n");
    exit(-1);
  }

  if(pid == 0)
  5a:	cd35                	beqz	a0,d6 <simpletest+0xd6>
    exit(0);

  wait(0);
  5c:	4501                	li	a0,0
  5e:	00000097          	auipc	ra,0x0
  62:	712080e7          	jalr	1810(ra) # 770 <wait>

  if(sbrk(-sz) == (char*)0xffffffffffffffffL){
  66:	faaab537          	lui	a0,0xfaaab
  6a:	aac50513          	addi	a0,a0,-1364 # fffffffffaaaaaac <_end+0xfffffffffaaa5cb4>
  6e:	00000097          	auipc	ra,0x0
  72:	782080e7          	jalr	1922(ra) # 7f0 <sbrk>
  76:	57fd                	li	a5,-1
  78:	06f50363          	beq	a0,a5,de <simpletest+0xde>
    printf("sbrk(-%d) failed\n", sz);
    exit(-1);
  }

  printf("ok\n");
  7c:	00001517          	auipc	a0,0x1
  80:	c5c50513          	addi	a0,a0,-932 # cd8 <malloc+0x138>
  84:	00001097          	auipc	ra,0x1
  88:	a5c080e7          	jalr	-1444(ra) # ae0 <printf>
}
  8c:	70a2                	ld	ra,40(sp)
  8e:	7402                	ld	s0,32(sp)
  90:	64e2                	ld	s1,24(sp)
  92:	6942                	ld	s2,16(sp)
  94:	69a2                	ld	s3,8(sp)
  96:	6145                	addi	sp,sp,48
  98:	8082                	ret
    printf("sbrk(%d) failed\n", sz);
  9a:	055555b7          	lui	a1,0x5555
  9e:	55458593          	addi	a1,a1,1364 # 5555554 <_end+0x555075c>
  a2:	00001517          	auipc	a0,0x1
  a6:	bf650513          	addi	a0,a0,-1034 # c98 <malloc+0xf8>
  aa:	00001097          	auipc	ra,0x1
  ae:	a36080e7          	jalr	-1482(ra) # ae0 <printf>
    exit(-1);
  b2:	557d                	li	a0,-1
  b4:	00000097          	auipc	ra,0x0
  b8:	6b4080e7          	jalr	1716(ra) # 768 <exit>
    printf("fork() failed\n");
  bc:	00001517          	auipc	a0,0x1
  c0:	bf450513          	addi	a0,a0,-1036 # cb0 <malloc+0x110>
  c4:	00001097          	auipc	ra,0x1
  c8:	a1c080e7          	jalr	-1508(ra) # ae0 <printf>
    exit(-1);
  cc:	557d                	li	a0,-1
  ce:	00000097          	auipc	ra,0x0
  d2:	69a080e7          	jalr	1690(ra) # 768 <exit>
    exit(0);
  d6:	00000097          	auipc	ra,0x0
  da:	692080e7          	jalr	1682(ra) # 768 <exit>
    printf("sbrk(-%d) failed\n", sz);
  de:	055555b7          	lui	a1,0x5555
  e2:	55458593          	addi	a1,a1,1364 # 5555554 <_end+0x555075c>
  e6:	00001517          	auipc	a0,0x1
  ea:	bda50513          	addi	a0,a0,-1062 # cc0 <malloc+0x120>
  ee:	00001097          	auipc	ra,0x1
  f2:	9f2080e7          	jalr	-1550(ra) # ae0 <printf>
    exit(-1);
  f6:	557d                	li	a0,-1
  f8:	00000097          	auipc	ra,0x0
  fc:	670080e7          	jalr	1648(ra) # 768 <exit>

0000000000000100 <threetest>:
// this causes more than half of physical memory
// to be allocated, so it also checks whether
// copied pages are freed.
void
threetest()
{
 100:	7179                	addi	sp,sp,-48
 102:	f406                	sd	ra,40(sp)
 104:	f022                	sd	s0,32(sp)
 106:	ec26                	sd	s1,24(sp)
 108:	e84a                	sd	s2,16(sp)
 10a:	e44e                	sd	s3,8(sp)
 10c:	e052                	sd	s4,0(sp)
 10e:	1800                	addi	s0,sp,48
  uint64 phys_size = PHYSTOP - KERNBASE;
  int sz = phys_size / 4;
  int pid1, pid2;

  printf("three: ");
 110:	00001517          	auipc	a0,0x1
 114:	bd050513          	addi	a0,a0,-1072 # ce0 <malloc+0x140>
 118:	00001097          	auipc	ra,0x1
 11c:	9c8080e7          	jalr	-1592(ra) # ae0 <printf>
  
  char *p = sbrk(sz);
 120:	02000537          	lui	a0,0x2000
 124:	00000097          	auipc	ra,0x0
 128:	6cc080e7          	jalr	1740(ra) # 7f0 <sbrk>
  if(p == (char*)0xffffffffffffffffL){
 12c:	57fd                	li	a5,-1
 12e:	08f50763          	beq	a0,a5,1bc <threetest+0xbc>
 132:	84aa                	mv	s1,a0
    printf("sbrk(%d) failed\n", sz);
    exit(-1);
  }

  pid1 = fork();
 134:	00000097          	auipc	ra,0x0
 138:	62c080e7          	jalr	1580(ra) # 760 <fork>
  if(pid1 < 0){
 13c:	08054f63          	bltz	a0,1da <threetest+0xda>
    printf("fork failed\n");
    exit(-1);
  }
  if(pid1 == 0){
 140:	c955                	beqz	a0,1f4 <threetest+0xf4>
      *(int*)q = 9999;
    }
    exit(0);
  }

  for(char *q = p; q < p + sz; q += 4096){
 142:	020009b7          	lui	s3,0x2000
 146:	99a6                	add	s3,s3,s1
 148:	8926                	mv	s2,s1
 14a:	6a05                	lui	s4,0x1
    *(int*)q = getpid();
 14c:	00000097          	auipc	ra,0x0
 150:	69c080e7          	jalr	1692(ra) # 7e8 <getpid>
 154:	00a92023          	sw	a0,0(s2) # 5556000 <_end+0x5551208>
  for(char *q = p; q < p + sz; q += 4096){
 158:	9952                	add	s2,s2,s4
 15a:	ff3919e3          	bne	s2,s3,14c <threetest+0x4c>
  }

  wait(0);
 15e:	4501                	li	a0,0
 160:	00000097          	auipc	ra,0x0
 164:	610080e7          	jalr	1552(ra) # 770 <wait>

  sleep(1);
 168:	4505                	li	a0,1
 16a:	00000097          	auipc	ra,0x0
 16e:	68e080e7          	jalr	1678(ra) # 7f8 <sleep>

  for(char *q = p; q < p + sz; q += 4096){
 172:	6a05                	lui	s4,0x1
    if(*(int*)q != getpid()){
 174:	0004a903          	lw	s2,0(s1)
 178:	00000097          	auipc	ra,0x0
 17c:	670080e7          	jalr	1648(ra) # 7e8 <getpid>
 180:	10a91a63          	bne	s2,a0,294 <threetest+0x194>
  for(char *q = p; q < p + sz; q += 4096){
 184:	94d2                	add	s1,s1,s4
 186:	ff3497e3          	bne	s1,s3,174 <threetest+0x74>
      printf("wrong content\n");
      exit(-1);
    }
  }

  if(sbrk(-sz) == (char*)0xffffffffffffffffL){
 18a:	fe000537          	lui	a0,0xfe000
 18e:	00000097          	auipc	ra,0x0
 192:	662080e7          	jalr	1634(ra) # 7f0 <sbrk>
 196:	57fd                	li	a5,-1
 198:	10f50b63          	beq	a0,a5,2ae <threetest+0x1ae>
    printf("sbrk(-%d) failed\n", sz);
    exit(-1);
  }

  printf("ok\n");
 19c:	00001517          	auipc	a0,0x1
 1a0:	b3c50513          	addi	a0,a0,-1220 # cd8 <malloc+0x138>
 1a4:	00001097          	auipc	ra,0x1
 1a8:	93c080e7          	jalr	-1732(ra) # ae0 <printf>
}
 1ac:	70a2                	ld	ra,40(sp)
 1ae:	7402                	ld	s0,32(sp)
 1b0:	64e2                	ld	s1,24(sp)
 1b2:	6942                	ld	s2,16(sp)
 1b4:	69a2                	ld	s3,8(sp)
 1b6:	6a02                	ld	s4,0(sp)
 1b8:	6145                	addi	sp,sp,48
 1ba:	8082                	ret
    printf("sbrk(%d) failed\n", sz);
 1bc:	020005b7          	lui	a1,0x2000
 1c0:	00001517          	auipc	a0,0x1
 1c4:	ad850513          	addi	a0,a0,-1320 # c98 <malloc+0xf8>
 1c8:	00001097          	auipc	ra,0x1
 1cc:	918080e7          	jalr	-1768(ra) # ae0 <printf>
    exit(-1);
 1d0:	557d                	li	a0,-1
 1d2:	00000097          	auipc	ra,0x0
 1d6:	596080e7          	jalr	1430(ra) # 768 <exit>
    printf("fork failed\n");
 1da:	00001517          	auipc	a0,0x1
 1de:	b0e50513          	addi	a0,a0,-1266 # ce8 <malloc+0x148>
 1e2:	00001097          	auipc	ra,0x1
 1e6:	8fe080e7          	jalr	-1794(ra) # ae0 <printf>
    exit(-1);
 1ea:	557d                	li	a0,-1
 1ec:	00000097          	auipc	ra,0x0
 1f0:	57c080e7          	jalr	1404(ra) # 768 <exit>
    pid2 = fork();
 1f4:	00000097          	auipc	ra,0x0
 1f8:	56c080e7          	jalr	1388(ra) # 760 <fork>
    if(pid2 < 0){
 1fc:	04054263          	bltz	a0,240 <threetest+0x140>
    if(pid2 == 0){
 200:	ed29                	bnez	a0,25a <threetest+0x15a>
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 202:	0199a9b7          	lui	s3,0x199a
 206:	99a6                	add	s3,s3,s1
 208:	8926                	mv	s2,s1
 20a:	6a05                	lui	s4,0x1
        *(int*)q = getpid();
 20c:	00000097          	auipc	ra,0x0
 210:	5dc080e7          	jalr	1500(ra) # 7e8 <getpid>
 214:	00a92023          	sw	a0,0(s2)
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 218:	9952                	add	s2,s2,s4
 21a:	ff3919e3          	bne	s2,s3,20c <threetest+0x10c>
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 21e:	6a05                	lui	s4,0x1
        if(*(int*)q != getpid()){
 220:	0004a903          	lw	s2,0(s1)
 224:	00000097          	auipc	ra,0x0
 228:	5c4080e7          	jalr	1476(ra) # 7e8 <getpid>
 22c:	04a91763          	bne	s2,a0,27a <threetest+0x17a>
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 230:	94d2                	add	s1,s1,s4
 232:	ff3497e3          	bne	s1,s3,220 <threetest+0x120>
      exit(-1);
 236:	557d                	li	a0,-1
 238:	00000097          	auipc	ra,0x0
 23c:	530080e7          	jalr	1328(ra) # 768 <exit>
      printf("fork failed");
 240:	00001517          	auipc	a0,0x1
 244:	ab850513          	addi	a0,a0,-1352 # cf8 <malloc+0x158>
 248:	00001097          	auipc	ra,0x1
 24c:	898080e7          	jalr	-1896(ra) # ae0 <printf>
      exit(-1);
 250:	557d                	li	a0,-1
 252:	00000097          	auipc	ra,0x0
 256:	516080e7          	jalr	1302(ra) # 768 <exit>
    for(char *q = p; q < p + (sz/2); q += 4096){
 25a:	01000737          	lui	a4,0x1000
 25e:	9726                	add	a4,a4,s1
      *(int*)q = 9999;
 260:	6789                	lui	a5,0x2
 262:	70f7879b          	addiw	a5,a5,1807
    for(char *q = p; q < p + (sz/2); q += 4096){
 266:	6685                	lui	a3,0x1
      *(int*)q = 9999;
 268:	c09c                	sw	a5,0(s1)
    for(char *q = p; q < p + (sz/2); q += 4096){
 26a:	94b6                	add	s1,s1,a3
 26c:	fee49ee3          	bne	s1,a4,268 <threetest+0x168>
    exit(0);
 270:	4501                	li	a0,0
 272:	00000097          	auipc	ra,0x0
 276:	4f6080e7          	jalr	1270(ra) # 768 <exit>
          printf("wrong content\n");
 27a:	00001517          	auipc	a0,0x1
 27e:	a8e50513          	addi	a0,a0,-1394 # d08 <malloc+0x168>
 282:	00001097          	auipc	ra,0x1
 286:	85e080e7          	jalr	-1954(ra) # ae0 <printf>
          exit(-1);
 28a:	557d                	li	a0,-1
 28c:	00000097          	auipc	ra,0x0
 290:	4dc080e7          	jalr	1244(ra) # 768 <exit>
      printf("wrong content\n");
 294:	00001517          	auipc	a0,0x1
 298:	a7450513          	addi	a0,a0,-1420 # d08 <malloc+0x168>
 29c:	00001097          	auipc	ra,0x1
 2a0:	844080e7          	jalr	-1980(ra) # ae0 <printf>
      exit(-1);
 2a4:	557d                	li	a0,-1
 2a6:	00000097          	auipc	ra,0x0
 2aa:	4c2080e7          	jalr	1218(ra) # 768 <exit>
    printf("sbrk(-%d) failed\n", sz);
 2ae:	020005b7          	lui	a1,0x2000
 2b2:	00001517          	auipc	a0,0x1
 2b6:	a0e50513          	addi	a0,a0,-1522 # cc0 <malloc+0x120>
 2ba:	00001097          	auipc	ra,0x1
 2be:	826080e7          	jalr	-2010(ra) # ae0 <printf>
    exit(-1);
 2c2:	557d                	li	a0,-1
 2c4:	00000097          	auipc	ra,0x0
 2c8:	4a4080e7          	jalr	1188(ra) # 768 <exit>

00000000000002cc <filetest>:
char junk3[4096];

// test whether copyout() simulates COW faults.
void
filetest()
{
 2cc:	7179                	addi	sp,sp,-48
 2ce:	f406                	sd	ra,40(sp)
 2d0:	f022                	sd	s0,32(sp)
 2d2:	ec26                	sd	s1,24(sp)
 2d4:	e84a                	sd	s2,16(sp)
 2d6:	1800                	addi	s0,sp,48
  printf("file: ");
 2d8:	00001517          	auipc	a0,0x1
 2dc:	a4050513          	addi	a0,a0,-1472 # d18 <malloc+0x178>
 2e0:	00001097          	auipc	ra,0x1
 2e4:	800080e7          	jalr	-2048(ra) # ae0 <printf>
  
  buf[0] = 99;
 2e8:	06300793          	li	a5,99
 2ec:	00002717          	auipc	a4,0x2
 2f0:	aef70e23          	sb	a5,-1284(a4) # 1de8 <buf>

  for(int i = 0; i < 4; i++){
 2f4:	fc042c23          	sw	zero,-40(s0)
    if(pipe(fds) != 0){
 2f8:	00001497          	auipc	s1,0x1
 2fc:	ae048493          	addi	s1,s1,-1312 # dd8 <fds>
  for(int i = 0; i < 4; i++){
 300:	490d                	li	s2,3
    if(pipe(fds) != 0){
 302:	8526                	mv	a0,s1
 304:	00000097          	auipc	ra,0x0
 308:	474080e7          	jalr	1140(ra) # 778 <pipe>
 30c:	e149                	bnez	a0,38e <filetest+0xc2>
      printf("pipe() failed\n");
      exit(-1);
    }
    int pid = fork();
 30e:	00000097          	auipc	ra,0x0
 312:	452080e7          	jalr	1106(ra) # 760 <fork>
    if(pid < 0){
 316:	08054963          	bltz	a0,3a8 <filetest+0xdc>
      printf("fork failed\n");
      exit(-1);
    }
    if(pid == 0){
 31a:	c545                	beqz	a0,3c2 <filetest+0xf6>
        printf("error: read the wrong value\n");
        exit(1);
      }
      exit(0);
    }
    if(write(fds[1], &i, sizeof(i)) != sizeof(i)){
 31c:	4611                	li	a2,4
 31e:	fd840593          	addi	a1,s0,-40
 322:	40c8                	lw	a0,4(s1)
 324:	00000097          	auipc	ra,0x0
 328:	464080e7          	jalr	1124(ra) # 788 <write>
 32c:	4791                	li	a5,4
 32e:	10f51d63          	bne	a0,a5,448 <filetest+0x17c>
  for(int i = 0; i < 4; i++){
 332:	fd842783          	lw	a5,-40(s0)
 336:	2785                	addiw	a5,a5,1
 338:	0007871b          	sext.w	a4,a5
 33c:	fcf42c23          	sw	a5,-40(s0)
 340:	fce951e3          	ble	a4,s2,302 <filetest+0x36>
      printf("error: write failed\n");
      exit(-1);
    }
  }

  int xstatus = 0;
 344:	fc042e23          	sw	zero,-36(s0)
 348:	4491                	li	s1,4
  for(int i = 0; i < 4; i++) {
    wait(&xstatus);
 34a:	fdc40513          	addi	a0,s0,-36
 34e:	00000097          	auipc	ra,0x0
 352:	422080e7          	jalr	1058(ra) # 770 <wait>
    if(xstatus != 0) {
 356:	fdc42783          	lw	a5,-36(s0)
 35a:	10079463          	bnez	a5,462 <filetest+0x196>
  for(int i = 0; i < 4; i++) {
 35e:	34fd                	addiw	s1,s1,-1
 360:	f4ed                	bnez	s1,34a <filetest+0x7e>
      exit(1);
    }
  }

  if(buf[0] != 99){
 362:	00002717          	auipc	a4,0x2
 366:	a8674703          	lbu	a4,-1402(a4) # 1de8 <buf>
 36a:	06300793          	li	a5,99
 36e:	0ef71f63          	bne	a4,a5,46c <filetest+0x1a0>
    printf("error: child overwrote parent\n");
    exit(1);
  }

  printf("ok\n");
 372:	00001517          	auipc	a0,0x1
 376:	96650513          	addi	a0,a0,-1690 # cd8 <malloc+0x138>
 37a:	00000097          	auipc	ra,0x0
 37e:	766080e7          	jalr	1894(ra) # ae0 <printf>
}
 382:	70a2                	ld	ra,40(sp)
 384:	7402                	ld	s0,32(sp)
 386:	64e2                	ld	s1,24(sp)
 388:	6942                	ld	s2,16(sp)
 38a:	6145                	addi	sp,sp,48
 38c:	8082                	ret
      printf("pipe() failed\n");
 38e:	00001517          	auipc	a0,0x1
 392:	99250513          	addi	a0,a0,-1646 # d20 <malloc+0x180>
 396:	00000097          	auipc	ra,0x0
 39a:	74a080e7          	jalr	1866(ra) # ae0 <printf>
      exit(-1);
 39e:	557d                	li	a0,-1
 3a0:	00000097          	auipc	ra,0x0
 3a4:	3c8080e7          	jalr	968(ra) # 768 <exit>
      printf("fork failed\n");
 3a8:	00001517          	auipc	a0,0x1
 3ac:	94050513          	addi	a0,a0,-1728 # ce8 <malloc+0x148>
 3b0:	00000097          	auipc	ra,0x0
 3b4:	730080e7          	jalr	1840(ra) # ae0 <printf>
      exit(-1);
 3b8:	557d                	li	a0,-1
 3ba:	00000097          	auipc	ra,0x0
 3be:	3ae080e7          	jalr	942(ra) # 768 <exit>
      sleep(1);
 3c2:	4505                	li	a0,1
 3c4:	00000097          	auipc	ra,0x0
 3c8:	434080e7          	jalr	1076(ra) # 7f8 <sleep>
      if(read(fds[0], buf, sizeof(i)) != sizeof(i)){
 3cc:	4611                	li	a2,4
 3ce:	00002597          	auipc	a1,0x2
 3d2:	a1a58593          	addi	a1,a1,-1510 # 1de8 <buf>
 3d6:	00001797          	auipc	a5,0x1
 3da:	a0278793          	addi	a5,a5,-1534 # dd8 <fds>
 3de:	4388                	lw	a0,0(a5)
 3e0:	00000097          	auipc	ra,0x0
 3e4:	3a0080e7          	jalr	928(ra) # 780 <read>
 3e8:	4791                	li	a5,4
 3ea:	02f51d63          	bne	a0,a5,424 <filetest+0x158>
      sleep(1);
 3ee:	4505                	li	a0,1
 3f0:	00000097          	auipc	ra,0x0
 3f4:	408080e7          	jalr	1032(ra) # 7f8 <sleep>
      if(j != i){
 3f8:	fd842703          	lw	a4,-40(s0)
 3fc:	00002797          	auipc	a5,0x2
 400:	9ec78793          	addi	a5,a5,-1556 # 1de8 <buf>
 404:	439c                	lw	a5,0(a5)
 406:	02f70c63          	beq	a4,a5,43e <filetest+0x172>
        printf("error: read the wrong value\n");
 40a:	00001517          	auipc	a0,0x1
 40e:	93e50513          	addi	a0,a0,-1730 # d48 <malloc+0x1a8>
 412:	00000097          	auipc	ra,0x0
 416:	6ce080e7          	jalr	1742(ra) # ae0 <printf>
        exit(1);
 41a:	4505                	li	a0,1
 41c:	00000097          	auipc	ra,0x0
 420:	34c080e7          	jalr	844(ra) # 768 <exit>
        printf("error: read failed\n");
 424:	00001517          	auipc	a0,0x1
 428:	90c50513          	addi	a0,a0,-1780 # d30 <malloc+0x190>
 42c:	00000097          	auipc	ra,0x0
 430:	6b4080e7          	jalr	1716(ra) # ae0 <printf>
        exit(1);
 434:	4505                	li	a0,1
 436:	00000097          	auipc	ra,0x0
 43a:	332080e7          	jalr	818(ra) # 768 <exit>
      exit(0);
 43e:	4501                	li	a0,0
 440:	00000097          	auipc	ra,0x0
 444:	328080e7          	jalr	808(ra) # 768 <exit>
      printf("error: write failed\n");
 448:	00001517          	auipc	a0,0x1
 44c:	92050513          	addi	a0,a0,-1760 # d68 <malloc+0x1c8>
 450:	00000097          	auipc	ra,0x0
 454:	690080e7          	jalr	1680(ra) # ae0 <printf>
      exit(-1);
 458:	557d                	li	a0,-1
 45a:	00000097          	auipc	ra,0x0
 45e:	30e080e7          	jalr	782(ra) # 768 <exit>
      exit(1);
 462:	4505                	li	a0,1
 464:	00000097          	auipc	ra,0x0
 468:	304080e7          	jalr	772(ra) # 768 <exit>
    printf("error: child overwrote parent\n");
 46c:	00001517          	auipc	a0,0x1
 470:	91450513          	addi	a0,a0,-1772 # d80 <malloc+0x1e0>
 474:	00000097          	auipc	ra,0x0
 478:	66c080e7          	jalr	1644(ra) # ae0 <printf>
    exit(1);
 47c:	4505                	li	a0,1
 47e:	00000097          	auipc	ra,0x0
 482:	2ea080e7          	jalr	746(ra) # 768 <exit>

0000000000000486 <main>:

int
main(int argc, char *argv[])
{
 486:	1141                	addi	sp,sp,-16
 488:	e406                	sd	ra,8(sp)
 48a:	e022                	sd	s0,0(sp)
 48c:	0800                	addi	s0,sp,16
  simpletest();
 48e:	00000097          	auipc	ra,0x0
 492:	b72080e7          	jalr	-1166(ra) # 0 <simpletest>

  // check that the first simpletest() freed the physical memory.
  simpletest();
 496:	00000097          	auipc	ra,0x0
 49a:	b6a080e7          	jalr	-1174(ra) # 0 <simpletest>

  threetest();
 49e:	00000097          	auipc	ra,0x0
 4a2:	c62080e7          	jalr	-926(ra) # 100 <threetest>
  threetest();
 4a6:	00000097          	auipc	ra,0x0
 4aa:	c5a080e7          	jalr	-934(ra) # 100 <threetest>
  threetest();
 4ae:	00000097          	auipc	ra,0x0
 4b2:	c52080e7          	jalr	-942(ra) # 100 <threetest>

  filetest();
 4b6:	00000097          	auipc	ra,0x0
 4ba:	e16080e7          	jalr	-490(ra) # 2cc <filetest>

  printf("ALL COW TESTS PASSED\n");
 4be:	00001517          	auipc	a0,0x1
 4c2:	8e250513          	addi	a0,a0,-1822 # da0 <malloc+0x200>
 4c6:	00000097          	auipc	ra,0x0
 4ca:	61a080e7          	jalr	1562(ra) # ae0 <printf>

  exit(0);
 4ce:	4501                	li	a0,0
 4d0:	00000097          	auipc	ra,0x0
 4d4:	298080e7          	jalr	664(ra) # 768 <exit>

00000000000004d8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 4d8:	1141                	addi	sp,sp,-16
 4da:	e422                	sd	s0,8(sp)
 4dc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 4de:	87aa                	mv	a5,a0
 4e0:	0585                	addi	a1,a1,1
 4e2:	0785                	addi	a5,a5,1
 4e4:	fff5c703          	lbu	a4,-1(a1)
 4e8:	fee78fa3          	sb	a4,-1(a5)
 4ec:	fb75                	bnez	a4,4e0 <strcpy+0x8>
    ;
  return os;
}
 4ee:	6422                	ld	s0,8(sp)
 4f0:	0141                	addi	sp,sp,16
 4f2:	8082                	ret

00000000000004f4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4f4:	1141                	addi	sp,sp,-16
 4f6:	e422                	sd	s0,8(sp)
 4f8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 4fa:	00054783          	lbu	a5,0(a0)
 4fe:	cf91                	beqz	a5,51a <strcmp+0x26>
 500:	0005c703          	lbu	a4,0(a1)
 504:	00f71b63          	bne	a4,a5,51a <strcmp+0x26>
    p++, q++;
 508:	0505                	addi	a0,a0,1
 50a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 50c:	00054783          	lbu	a5,0(a0)
 510:	c789                	beqz	a5,51a <strcmp+0x26>
 512:	0005c703          	lbu	a4,0(a1)
 516:	fef709e3          	beq	a4,a5,508 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 51a:	0005c503          	lbu	a0,0(a1)
}
 51e:	40a7853b          	subw	a0,a5,a0
 522:	6422                	ld	s0,8(sp)
 524:	0141                	addi	sp,sp,16
 526:	8082                	ret

0000000000000528 <strlen>:

uint
strlen(const char *s)
{
 528:	1141                	addi	sp,sp,-16
 52a:	e422                	sd	s0,8(sp)
 52c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 52e:	00054783          	lbu	a5,0(a0)
 532:	cf91                	beqz	a5,54e <strlen+0x26>
 534:	0505                	addi	a0,a0,1
 536:	87aa                	mv	a5,a0
 538:	4685                	li	a3,1
 53a:	9e89                	subw	a3,a3,a0
 53c:	00f6853b          	addw	a0,a3,a5
 540:	0785                	addi	a5,a5,1
 542:	fff7c703          	lbu	a4,-1(a5)
 546:	fb7d                	bnez	a4,53c <strlen+0x14>
    ;
  return n;
}
 548:	6422                	ld	s0,8(sp)
 54a:	0141                	addi	sp,sp,16
 54c:	8082                	ret
  for(n = 0; s[n]; n++)
 54e:	4501                	li	a0,0
 550:	bfe5                	j	548 <strlen+0x20>

0000000000000552 <memset>:

void*
memset(void *dst, int c, uint n)
{
 552:	1141                	addi	sp,sp,-16
 554:	e422                	sd	s0,8(sp)
 556:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 558:	ce09                	beqz	a2,572 <memset+0x20>
 55a:	87aa                	mv	a5,a0
 55c:	fff6071b          	addiw	a4,a2,-1
 560:	1702                	slli	a4,a4,0x20
 562:	9301                	srli	a4,a4,0x20
 564:	0705                	addi	a4,a4,1
 566:	972a                	add	a4,a4,a0
    cdst[i] = c;
 568:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 56c:	0785                	addi	a5,a5,1
 56e:	fee79de3          	bne	a5,a4,568 <memset+0x16>
  }
  return dst;
}
 572:	6422                	ld	s0,8(sp)
 574:	0141                	addi	sp,sp,16
 576:	8082                	ret

0000000000000578 <strchr>:

char*
strchr(const char *s, char c)
{
 578:	1141                	addi	sp,sp,-16
 57a:	e422                	sd	s0,8(sp)
 57c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 57e:	00054783          	lbu	a5,0(a0)
 582:	cf91                	beqz	a5,59e <strchr+0x26>
    if(*s == c)
 584:	00f58a63          	beq	a1,a5,598 <strchr+0x20>
  for(; *s; s++)
 588:	0505                	addi	a0,a0,1
 58a:	00054783          	lbu	a5,0(a0)
 58e:	c781                	beqz	a5,596 <strchr+0x1e>
    if(*s == c)
 590:	feb79ce3          	bne	a5,a1,588 <strchr+0x10>
 594:	a011                	j	598 <strchr+0x20>
      return (char*)s;
  return 0;
 596:	4501                	li	a0,0
}
 598:	6422                	ld	s0,8(sp)
 59a:	0141                	addi	sp,sp,16
 59c:	8082                	ret
  return 0;
 59e:	4501                	li	a0,0
 5a0:	bfe5                	j	598 <strchr+0x20>

00000000000005a2 <gets>:

char*
gets(char *buf, int max)
{
 5a2:	711d                	addi	sp,sp,-96
 5a4:	ec86                	sd	ra,88(sp)
 5a6:	e8a2                	sd	s0,80(sp)
 5a8:	e4a6                	sd	s1,72(sp)
 5aa:	e0ca                	sd	s2,64(sp)
 5ac:	fc4e                	sd	s3,56(sp)
 5ae:	f852                	sd	s4,48(sp)
 5b0:	f456                	sd	s5,40(sp)
 5b2:	f05a                	sd	s6,32(sp)
 5b4:	ec5e                	sd	s7,24(sp)
 5b6:	1080                	addi	s0,sp,96
 5b8:	8baa                	mv	s7,a0
 5ba:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5bc:	892a                	mv	s2,a0
 5be:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 5c0:	4aa9                	li	s5,10
 5c2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 5c4:	0019849b          	addiw	s1,s3,1
 5c8:	0344d863          	ble	s4,s1,5f8 <gets+0x56>
    cc = read(0, &c, 1);
 5cc:	4605                	li	a2,1
 5ce:	faf40593          	addi	a1,s0,-81
 5d2:	4501                	li	a0,0
 5d4:	00000097          	auipc	ra,0x0
 5d8:	1ac080e7          	jalr	428(ra) # 780 <read>
    if(cc < 1)
 5dc:	00a05e63          	blez	a0,5f8 <gets+0x56>
    buf[i++] = c;
 5e0:	faf44783          	lbu	a5,-81(s0)
 5e4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 5e8:	01578763          	beq	a5,s5,5f6 <gets+0x54>
 5ec:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 5ee:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 5f0:	fd679ae3          	bne	a5,s6,5c4 <gets+0x22>
 5f4:	a011                	j	5f8 <gets+0x56>
  for(i=0; i+1 < max; ){
 5f6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 5f8:	99de                	add	s3,s3,s7
 5fa:	00098023          	sb	zero,0(s3) # 199a000 <_end+0x1995208>
  return buf;
}
 5fe:	855e                	mv	a0,s7
 600:	60e6                	ld	ra,88(sp)
 602:	6446                	ld	s0,80(sp)
 604:	64a6                	ld	s1,72(sp)
 606:	6906                	ld	s2,64(sp)
 608:	79e2                	ld	s3,56(sp)
 60a:	7a42                	ld	s4,48(sp)
 60c:	7aa2                	ld	s5,40(sp)
 60e:	7b02                	ld	s6,32(sp)
 610:	6be2                	ld	s7,24(sp)
 612:	6125                	addi	sp,sp,96
 614:	8082                	ret

0000000000000616 <stat>:

int
stat(const char *n, struct stat *st)
{
 616:	1101                	addi	sp,sp,-32
 618:	ec06                	sd	ra,24(sp)
 61a:	e822                	sd	s0,16(sp)
 61c:	e426                	sd	s1,8(sp)
 61e:	e04a                	sd	s2,0(sp)
 620:	1000                	addi	s0,sp,32
 622:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 624:	4581                	li	a1,0
 626:	00000097          	auipc	ra,0x0
 62a:	182080e7          	jalr	386(ra) # 7a8 <open>
  if(fd < 0)
 62e:	02054563          	bltz	a0,658 <stat+0x42>
 632:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 634:	85ca                	mv	a1,s2
 636:	00000097          	auipc	ra,0x0
 63a:	18a080e7          	jalr	394(ra) # 7c0 <fstat>
 63e:	892a                	mv	s2,a0
  close(fd);
 640:	8526                	mv	a0,s1
 642:	00000097          	auipc	ra,0x0
 646:	14e080e7          	jalr	334(ra) # 790 <close>
  return r;
}
 64a:	854a                	mv	a0,s2
 64c:	60e2                	ld	ra,24(sp)
 64e:	6442                	ld	s0,16(sp)
 650:	64a2                	ld	s1,8(sp)
 652:	6902                	ld	s2,0(sp)
 654:	6105                	addi	sp,sp,32
 656:	8082                	ret
    return -1;
 658:	597d                	li	s2,-1
 65a:	bfc5                	j	64a <stat+0x34>

000000000000065c <atoi>:

int
atoi(const char *s)
{
 65c:	1141                	addi	sp,sp,-16
 65e:	e422                	sd	s0,8(sp)
 660:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 662:	00054683          	lbu	a3,0(a0)
 666:	fd06879b          	addiw	a5,a3,-48
 66a:	0ff7f793          	andi	a5,a5,255
 66e:	4725                	li	a4,9
 670:	02f76963          	bltu	a4,a5,6a2 <atoi+0x46>
 674:	862a                	mv	a2,a0
  n = 0;
 676:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 678:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 67a:	0605                	addi	a2,a2,1
 67c:	0025179b          	slliw	a5,a0,0x2
 680:	9fa9                	addw	a5,a5,a0
 682:	0017979b          	slliw	a5,a5,0x1
 686:	9fb5                	addw	a5,a5,a3
 688:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 68c:	00064683          	lbu	a3,0(a2)
 690:	fd06871b          	addiw	a4,a3,-48
 694:	0ff77713          	andi	a4,a4,255
 698:	fee5f1e3          	bleu	a4,a1,67a <atoi+0x1e>
  return n;
}
 69c:	6422                	ld	s0,8(sp)
 69e:	0141                	addi	sp,sp,16
 6a0:	8082                	ret
  n = 0;
 6a2:	4501                	li	a0,0
 6a4:	bfe5                	j	69c <atoi+0x40>

00000000000006a6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 6a6:	1141                	addi	sp,sp,-16
 6a8:	e422                	sd	s0,8(sp)
 6aa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 6ac:	02b57663          	bleu	a1,a0,6d8 <memmove+0x32>
    while(n-- > 0)
 6b0:	02c05163          	blez	a2,6d2 <memmove+0x2c>
 6b4:	fff6079b          	addiw	a5,a2,-1
 6b8:	1782                	slli	a5,a5,0x20
 6ba:	9381                	srli	a5,a5,0x20
 6bc:	0785                	addi	a5,a5,1
 6be:	97aa                	add	a5,a5,a0
  dst = vdst;
 6c0:	872a                	mv	a4,a0
      *dst++ = *src++;
 6c2:	0585                	addi	a1,a1,1
 6c4:	0705                	addi	a4,a4,1
 6c6:	fff5c683          	lbu	a3,-1(a1)
 6ca:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 6ce:	fee79ae3          	bne	a5,a4,6c2 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 6d2:	6422                	ld	s0,8(sp)
 6d4:	0141                	addi	sp,sp,16
 6d6:	8082                	ret
    dst += n;
 6d8:	00c50733          	add	a4,a0,a2
    src += n;
 6dc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 6de:	fec05ae3          	blez	a2,6d2 <memmove+0x2c>
 6e2:	fff6079b          	addiw	a5,a2,-1
 6e6:	1782                	slli	a5,a5,0x20
 6e8:	9381                	srli	a5,a5,0x20
 6ea:	fff7c793          	not	a5,a5
 6ee:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 6f0:	15fd                	addi	a1,a1,-1
 6f2:	177d                	addi	a4,a4,-1
 6f4:	0005c683          	lbu	a3,0(a1)
 6f8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 6fc:	fef71ae3          	bne	a4,a5,6f0 <memmove+0x4a>
 700:	bfc9                	j	6d2 <memmove+0x2c>

0000000000000702 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 702:	1141                	addi	sp,sp,-16
 704:	e422                	sd	s0,8(sp)
 706:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 708:	ce15                	beqz	a2,744 <memcmp+0x42>
 70a:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 70e:	00054783          	lbu	a5,0(a0)
 712:	0005c703          	lbu	a4,0(a1)
 716:	02e79063          	bne	a5,a4,736 <memcmp+0x34>
 71a:	1682                	slli	a3,a3,0x20
 71c:	9281                	srli	a3,a3,0x20
 71e:	0685                	addi	a3,a3,1
 720:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 722:	0505                	addi	a0,a0,1
    p2++;
 724:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 726:	00d50d63          	beq	a0,a3,740 <memcmp+0x3e>
    if (*p1 != *p2) {
 72a:	00054783          	lbu	a5,0(a0)
 72e:	0005c703          	lbu	a4,0(a1)
 732:	fee788e3          	beq	a5,a4,722 <memcmp+0x20>
      return *p1 - *p2;
 736:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 73a:	6422                	ld	s0,8(sp)
 73c:	0141                	addi	sp,sp,16
 73e:	8082                	ret
  return 0;
 740:	4501                	li	a0,0
 742:	bfe5                	j	73a <memcmp+0x38>
 744:	4501                	li	a0,0
 746:	bfd5                	j	73a <memcmp+0x38>

0000000000000748 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 748:	1141                	addi	sp,sp,-16
 74a:	e406                	sd	ra,8(sp)
 74c:	e022                	sd	s0,0(sp)
 74e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 750:	00000097          	auipc	ra,0x0
 754:	f56080e7          	jalr	-170(ra) # 6a6 <memmove>
}
 758:	60a2                	ld	ra,8(sp)
 75a:	6402                	ld	s0,0(sp)
 75c:	0141                	addi	sp,sp,16
 75e:	8082                	ret

0000000000000760 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 760:	4885                	li	a7,1
 ecall
 762:	00000073          	ecall
 ret
 766:	8082                	ret

0000000000000768 <exit>:
.global exit
exit:
 li a7, SYS_exit
 768:	4889                	li	a7,2
 ecall
 76a:	00000073          	ecall
 ret
 76e:	8082                	ret

0000000000000770 <wait>:
.global wait
wait:
 li a7, SYS_wait
 770:	488d                	li	a7,3
 ecall
 772:	00000073          	ecall
 ret
 776:	8082                	ret

0000000000000778 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 778:	4891                	li	a7,4
 ecall
 77a:	00000073          	ecall
 ret
 77e:	8082                	ret

0000000000000780 <read>:
.global read
read:
 li a7, SYS_read
 780:	4895                	li	a7,5
 ecall
 782:	00000073          	ecall
 ret
 786:	8082                	ret

0000000000000788 <write>:
.global write
write:
 li a7, SYS_write
 788:	48c1                	li	a7,16
 ecall
 78a:	00000073          	ecall
 ret
 78e:	8082                	ret

0000000000000790 <close>:
.global close
close:
 li a7, SYS_close
 790:	48d5                	li	a7,21
 ecall
 792:	00000073          	ecall
 ret
 796:	8082                	ret

0000000000000798 <kill>:
.global kill
kill:
 li a7, SYS_kill
 798:	4899                	li	a7,6
 ecall
 79a:	00000073          	ecall
 ret
 79e:	8082                	ret

00000000000007a0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 7a0:	489d                	li	a7,7
 ecall
 7a2:	00000073          	ecall
 ret
 7a6:	8082                	ret

00000000000007a8 <open>:
.global open
open:
 li a7, SYS_open
 7a8:	48bd                	li	a7,15
 ecall
 7aa:	00000073          	ecall
 ret
 7ae:	8082                	ret

00000000000007b0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 7b0:	48c5                	li	a7,17
 ecall
 7b2:	00000073          	ecall
 ret
 7b6:	8082                	ret

00000000000007b8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 7b8:	48c9                	li	a7,18
 ecall
 7ba:	00000073          	ecall
 ret
 7be:	8082                	ret

00000000000007c0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 7c0:	48a1                	li	a7,8
 ecall
 7c2:	00000073          	ecall
 ret
 7c6:	8082                	ret

00000000000007c8 <link>:
.global link
link:
 li a7, SYS_link
 7c8:	48cd                	li	a7,19
 ecall
 7ca:	00000073          	ecall
 ret
 7ce:	8082                	ret

00000000000007d0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 7d0:	48d1                	li	a7,20
 ecall
 7d2:	00000073          	ecall
 ret
 7d6:	8082                	ret

00000000000007d8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 7d8:	48a5                	li	a7,9
 ecall
 7da:	00000073          	ecall
 ret
 7de:	8082                	ret

00000000000007e0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 7e0:	48a9                	li	a7,10
 ecall
 7e2:	00000073          	ecall
 ret
 7e6:	8082                	ret

00000000000007e8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 7e8:	48ad                	li	a7,11
 ecall
 7ea:	00000073          	ecall
 ret
 7ee:	8082                	ret

00000000000007f0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 7f0:	48b1                	li	a7,12
 ecall
 7f2:	00000073          	ecall
 ret
 7f6:	8082                	ret

00000000000007f8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 7f8:	48b5                	li	a7,13
 ecall
 7fa:	00000073          	ecall
 ret
 7fe:	8082                	ret

0000000000000800 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 800:	48b9                	li	a7,14
 ecall
 802:	00000073          	ecall
 ret
 806:	8082                	ret

0000000000000808 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 808:	1101                	addi	sp,sp,-32
 80a:	ec06                	sd	ra,24(sp)
 80c:	e822                	sd	s0,16(sp)
 80e:	1000                	addi	s0,sp,32
 810:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 814:	4605                	li	a2,1
 816:	fef40593          	addi	a1,s0,-17
 81a:	00000097          	auipc	ra,0x0
 81e:	f6e080e7          	jalr	-146(ra) # 788 <write>
}
 822:	60e2                	ld	ra,24(sp)
 824:	6442                	ld	s0,16(sp)
 826:	6105                	addi	sp,sp,32
 828:	8082                	ret

000000000000082a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 82a:	7139                	addi	sp,sp,-64
 82c:	fc06                	sd	ra,56(sp)
 82e:	f822                	sd	s0,48(sp)
 830:	f426                	sd	s1,40(sp)
 832:	f04a                	sd	s2,32(sp)
 834:	ec4e                	sd	s3,24(sp)
 836:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 838:	c299                	beqz	a3,83e <printint+0x14>
 83a:	0005cd63          	bltz	a1,854 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 83e:	2581                	sext.w	a1,a1
  neg = 0;
 840:	4301                	li	t1,0
 842:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 846:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 848:	2601                	sext.w	a2,a2
 84a:	00000897          	auipc	a7,0x0
 84e:	56e88893          	addi	a7,a7,1390 # db8 <digits>
 852:	a801                	j	862 <printint+0x38>
    x = -xx;
 854:	40b005bb          	negw	a1,a1
 858:	2581                	sext.w	a1,a1
    neg = 1;
 85a:	4305                	li	t1,1
    x = -xx;
 85c:	b7dd                	j	842 <printint+0x18>
  }while((x /= base) != 0);
 85e:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 860:	8836                	mv	a6,a3
 862:	0018069b          	addiw	a3,a6,1
 866:	02c5f7bb          	remuw	a5,a1,a2
 86a:	1782                	slli	a5,a5,0x20
 86c:	9381                	srli	a5,a5,0x20
 86e:	97c6                	add	a5,a5,a7
 870:	0007c783          	lbu	a5,0(a5)
 874:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 878:	0705                	addi	a4,a4,1
 87a:	02c5d7bb          	divuw	a5,a1,a2
 87e:	fec5f0e3          	bleu	a2,a1,85e <printint+0x34>
  if(neg)
 882:	00030b63          	beqz	t1,898 <printint+0x6e>
    buf[i++] = '-';
 886:	fd040793          	addi	a5,s0,-48
 88a:	96be                	add	a3,a3,a5
 88c:	02d00793          	li	a5,45
 890:	fef68823          	sb	a5,-16(a3) # ff0 <junk3+0x208>
 894:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 898:	02d05963          	blez	a3,8ca <printint+0xa0>
 89c:	89aa                	mv	s3,a0
 89e:	fc040793          	addi	a5,s0,-64
 8a2:	00d784b3          	add	s1,a5,a3
 8a6:	fff78913          	addi	s2,a5,-1
 8aa:	9936                	add	s2,s2,a3
 8ac:	36fd                	addiw	a3,a3,-1
 8ae:	1682                	slli	a3,a3,0x20
 8b0:	9281                	srli	a3,a3,0x20
 8b2:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 8b6:	fff4c583          	lbu	a1,-1(s1)
 8ba:	854e                	mv	a0,s3
 8bc:	00000097          	auipc	ra,0x0
 8c0:	f4c080e7          	jalr	-180(ra) # 808 <putc>
  while(--i >= 0)
 8c4:	14fd                	addi	s1,s1,-1
 8c6:	ff2498e3          	bne	s1,s2,8b6 <printint+0x8c>
}
 8ca:	70e2                	ld	ra,56(sp)
 8cc:	7442                	ld	s0,48(sp)
 8ce:	74a2                	ld	s1,40(sp)
 8d0:	7902                	ld	s2,32(sp)
 8d2:	69e2                	ld	s3,24(sp)
 8d4:	6121                	addi	sp,sp,64
 8d6:	8082                	ret

00000000000008d8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 8d8:	7119                	addi	sp,sp,-128
 8da:	fc86                	sd	ra,120(sp)
 8dc:	f8a2                	sd	s0,112(sp)
 8de:	f4a6                	sd	s1,104(sp)
 8e0:	f0ca                	sd	s2,96(sp)
 8e2:	ecce                	sd	s3,88(sp)
 8e4:	e8d2                	sd	s4,80(sp)
 8e6:	e4d6                	sd	s5,72(sp)
 8e8:	e0da                	sd	s6,64(sp)
 8ea:	fc5e                	sd	s7,56(sp)
 8ec:	f862                	sd	s8,48(sp)
 8ee:	f466                	sd	s9,40(sp)
 8f0:	f06a                	sd	s10,32(sp)
 8f2:	ec6e                	sd	s11,24(sp)
 8f4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 8f6:	0005c483          	lbu	s1,0(a1)
 8fa:	18048d63          	beqz	s1,a94 <vprintf+0x1bc>
 8fe:	8aaa                	mv	s5,a0
 900:	8b32                	mv	s6,a2
 902:	00158913          	addi	s2,a1,1
  state = 0;
 906:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 908:	02500a13          	li	s4,37
      if(c == 'd'){
 90c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 910:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 914:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 918:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 91c:	00000b97          	auipc	s7,0x0
 920:	49cb8b93          	addi	s7,s7,1180 # db8 <digits>
 924:	a839                	j	942 <vprintf+0x6a>
        putc(fd, c);
 926:	85a6                	mv	a1,s1
 928:	8556                	mv	a0,s5
 92a:	00000097          	auipc	ra,0x0
 92e:	ede080e7          	jalr	-290(ra) # 808 <putc>
 932:	a019                	j	938 <vprintf+0x60>
    } else if(state == '%'){
 934:	01498f63          	beq	s3,s4,952 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 938:	0905                	addi	s2,s2,1
 93a:	fff94483          	lbu	s1,-1(s2)
 93e:	14048b63          	beqz	s1,a94 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 942:	0004879b          	sext.w	a5,s1
    if(state == 0){
 946:	fe0997e3          	bnez	s3,934 <vprintf+0x5c>
      if(c == '%'){
 94a:	fd479ee3          	bne	a5,s4,926 <vprintf+0x4e>
        state = '%';
 94e:	89be                	mv	s3,a5
 950:	b7e5                	j	938 <vprintf+0x60>
      if(c == 'd'){
 952:	05878063          	beq	a5,s8,992 <vprintf+0xba>
      } else if(c == 'l') {
 956:	05978c63          	beq	a5,s9,9ae <vprintf+0xd6>
      } else if(c == 'x') {
 95a:	07a78863          	beq	a5,s10,9ca <vprintf+0xf2>
      } else if(c == 'p') {
 95e:	09b78463          	beq	a5,s11,9e6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 962:	07300713          	li	a4,115
 966:	0ce78563          	beq	a5,a4,a30 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 96a:	06300713          	li	a4,99
 96e:	0ee78c63          	beq	a5,a4,a66 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 972:	11478663          	beq	a5,s4,a7e <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 976:	85d2                	mv	a1,s4
 978:	8556                	mv	a0,s5
 97a:	00000097          	auipc	ra,0x0
 97e:	e8e080e7          	jalr	-370(ra) # 808 <putc>
        putc(fd, c);
 982:	85a6                	mv	a1,s1
 984:	8556                	mv	a0,s5
 986:	00000097          	auipc	ra,0x0
 98a:	e82080e7          	jalr	-382(ra) # 808 <putc>
      }
      state = 0;
 98e:	4981                	li	s3,0
 990:	b765                	j	938 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 992:	008b0493          	addi	s1,s6,8
 996:	4685                	li	a3,1
 998:	4629                	li	a2,10
 99a:	000b2583          	lw	a1,0(s6)
 99e:	8556                	mv	a0,s5
 9a0:	00000097          	auipc	ra,0x0
 9a4:	e8a080e7          	jalr	-374(ra) # 82a <printint>
 9a8:	8b26                	mv	s6,s1
      state = 0;
 9aa:	4981                	li	s3,0
 9ac:	b771                	j	938 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9ae:	008b0493          	addi	s1,s6,8
 9b2:	4681                	li	a3,0
 9b4:	4629                	li	a2,10
 9b6:	000b2583          	lw	a1,0(s6)
 9ba:	8556                	mv	a0,s5
 9bc:	00000097          	auipc	ra,0x0
 9c0:	e6e080e7          	jalr	-402(ra) # 82a <printint>
 9c4:	8b26                	mv	s6,s1
      state = 0;
 9c6:	4981                	li	s3,0
 9c8:	bf85                	j	938 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 9ca:	008b0493          	addi	s1,s6,8
 9ce:	4681                	li	a3,0
 9d0:	4641                	li	a2,16
 9d2:	000b2583          	lw	a1,0(s6)
 9d6:	8556                	mv	a0,s5
 9d8:	00000097          	auipc	ra,0x0
 9dc:	e52080e7          	jalr	-430(ra) # 82a <printint>
 9e0:	8b26                	mv	s6,s1
      state = 0;
 9e2:	4981                	li	s3,0
 9e4:	bf91                	j	938 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 9e6:	008b0793          	addi	a5,s6,8
 9ea:	f8f43423          	sd	a5,-120(s0)
 9ee:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 9f2:	03000593          	li	a1,48
 9f6:	8556                	mv	a0,s5
 9f8:	00000097          	auipc	ra,0x0
 9fc:	e10080e7          	jalr	-496(ra) # 808 <putc>
  putc(fd, 'x');
 a00:	85ea                	mv	a1,s10
 a02:	8556                	mv	a0,s5
 a04:	00000097          	auipc	ra,0x0
 a08:	e04080e7          	jalr	-508(ra) # 808 <putc>
 a0c:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a0e:	03c9d793          	srli	a5,s3,0x3c
 a12:	97de                	add	a5,a5,s7
 a14:	0007c583          	lbu	a1,0(a5)
 a18:	8556                	mv	a0,s5
 a1a:	00000097          	auipc	ra,0x0
 a1e:	dee080e7          	jalr	-530(ra) # 808 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a22:	0992                	slli	s3,s3,0x4
 a24:	34fd                	addiw	s1,s1,-1
 a26:	f4e5                	bnez	s1,a0e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 a28:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 a2c:	4981                	li	s3,0
 a2e:	b729                	j	938 <vprintf+0x60>
        s = va_arg(ap, char*);
 a30:	008b0993          	addi	s3,s6,8
 a34:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 a38:	c085                	beqz	s1,a58 <vprintf+0x180>
        while(*s != 0){
 a3a:	0004c583          	lbu	a1,0(s1)
 a3e:	c9a1                	beqz	a1,a8e <vprintf+0x1b6>
          putc(fd, *s);
 a40:	8556                	mv	a0,s5
 a42:	00000097          	auipc	ra,0x0
 a46:	dc6080e7          	jalr	-570(ra) # 808 <putc>
          s++;
 a4a:	0485                	addi	s1,s1,1
        while(*s != 0){
 a4c:	0004c583          	lbu	a1,0(s1)
 a50:	f9e5                	bnez	a1,a40 <vprintf+0x168>
        s = va_arg(ap, char*);
 a52:	8b4e                	mv	s6,s3
      state = 0;
 a54:	4981                	li	s3,0
 a56:	b5cd                	j	938 <vprintf+0x60>
          s = "(null)";
 a58:	00000497          	auipc	s1,0x0
 a5c:	37848493          	addi	s1,s1,888 # dd0 <digits+0x18>
        while(*s != 0){
 a60:	02800593          	li	a1,40
 a64:	bff1                	j	a40 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 a66:	008b0493          	addi	s1,s6,8
 a6a:	000b4583          	lbu	a1,0(s6)
 a6e:	8556                	mv	a0,s5
 a70:	00000097          	auipc	ra,0x0
 a74:	d98080e7          	jalr	-616(ra) # 808 <putc>
 a78:	8b26                	mv	s6,s1
      state = 0;
 a7a:	4981                	li	s3,0
 a7c:	bd75                	j	938 <vprintf+0x60>
        putc(fd, c);
 a7e:	85d2                	mv	a1,s4
 a80:	8556                	mv	a0,s5
 a82:	00000097          	auipc	ra,0x0
 a86:	d86080e7          	jalr	-634(ra) # 808 <putc>
      state = 0;
 a8a:	4981                	li	s3,0
 a8c:	b575                	j	938 <vprintf+0x60>
        s = va_arg(ap, char*);
 a8e:	8b4e                	mv	s6,s3
      state = 0;
 a90:	4981                	li	s3,0
 a92:	b55d                	j	938 <vprintf+0x60>
    }
  }
}
 a94:	70e6                	ld	ra,120(sp)
 a96:	7446                	ld	s0,112(sp)
 a98:	74a6                	ld	s1,104(sp)
 a9a:	7906                	ld	s2,96(sp)
 a9c:	69e6                	ld	s3,88(sp)
 a9e:	6a46                	ld	s4,80(sp)
 aa0:	6aa6                	ld	s5,72(sp)
 aa2:	6b06                	ld	s6,64(sp)
 aa4:	7be2                	ld	s7,56(sp)
 aa6:	7c42                	ld	s8,48(sp)
 aa8:	7ca2                	ld	s9,40(sp)
 aaa:	7d02                	ld	s10,32(sp)
 aac:	6de2                	ld	s11,24(sp)
 aae:	6109                	addi	sp,sp,128
 ab0:	8082                	ret

0000000000000ab2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 ab2:	715d                	addi	sp,sp,-80
 ab4:	ec06                	sd	ra,24(sp)
 ab6:	e822                	sd	s0,16(sp)
 ab8:	1000                	addi	s0,sp,32
 aba:	e010                	sd	a2,0(s0)
 abc:	e414                	sd	a3,8(s0)
 abe:	e818                	sd	a4,16(s0)
 ac0:	ec1c                	sd	a5,24(s0)
 ac2:	03043023          	sd	a6,32(s0)
 ac6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 aca:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 ace:	8622                	mv	a2,s0
 ad0:	00000097          	auipc	ra,0x0
 ad4:	e08080e7          	jalr	-504(ra) # 8d8 <vprintf>
}
 ad8:	60e2                	ld	ra,24(sp)
 ada:	6442                	ld	s0,16(sp)
 adc:	6161                	addi	sp,sp,80
 ade:	8082                	ret

0000000000000ae0 <printf>:

void
printf(const char *fmt, ...)
{
 ae0:	711d                	addi	sp,sp,-96
 ae2:	ec06                	sd	ra,24(sp)
 ae4:	e822                	sd	s0,16(sp)
 ae6:	1000                	addi	s0,sp,32
 ae8:	e40c                	sd	a1,8(s0)
 aea:	e810                	sd	a2,16(s0)
 aec:	ec14                	sd	a3,24(s0)
 aee:	f018                	sd	a4,32(s0)
 af0:	f41c                	sd	a5,40(s0)
 af2:	03043823          	sd	a6,48(s0)
 af6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 afa:	00840613          	addi	a2,s0,8
 afe:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b02:	85aa                	mv	a1,a0
 b04:	4505                	li	a0,1
 b06:	00000097          	auipc	ra,0x0
 b0a:	dd2080e7          	jalr	-558(ra) # 8d8 <vprintf>
}
 b0e:	60e2                	ld	ra,24(sp)
 b10:	6442                	ld	s0,16(sp)
 b12:	6125                	addi	sp,sp,96
 b14:	8082                	ret

0000000000000b16 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b16:	1141                	addi	sp,sp,-16
 b18:	e422                	sd	s0,8(sp)
 b1a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b1c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b20:	00000797          	auipc	a5,0x0
 b24:	2c078793          	addi	a5,a5,704 # de0 <freep>
 b28:	639c                	ld	a5,0(a5)
 b2a:	a805                	j	b5a <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b2c:	4618                	lw	a4,8(a2)
 b2e:	9db9                	addw	a1,a1,a4
 b30:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b34:	6398                	ld	a4,0(a5)
 b36:	6318                	ld	a4,0(a4)
 b38:	fee53823          	sd	a4,-16(a0)
 b3c:	a091                	j	b80 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b3e:	ff852703          	lw	a4,-8(a0)
 b42:	9e39                	addw	a2,a2,a4
 b44:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 b46:	ff053703          	ld	a4,-16(a0)
 b4a:	e398                	sd	a4,0(a5)
 b4c:	a099                	j	b92 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b4e:	6398                	ld	a4,0(a5)
 b50:	00e7e463          	bltu	a5,a4,b58 <free+0x42>
 b54:	00e6ea63          	bltu	a3,a4,b68 <free+0x52>
{
 b58:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b5a:	fed7fae3          	bleu	a3,a5,b4e <free+0x38>
 b5e:	6398                	ld	a4,0(a5)
 b60:	00e6e463          	bltu	a3,a4,b68 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b64:	fee7eae3          	bltu	a5,a4,b58 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 b68:	ff852583          	lw	a1,-8(a0)
 b6c:	6390                	ld	a2,0(a5)
 b6e:	02059713          	slli	a4,a1,0x20
 b72:	9301                	srli	a4,a4,0x20
 b74:	0712                	slli	a4,a4,0x4
 b76:	9736                	add	a4,a4,a3
 b78:	fae60ae3          	beq	a2,a4,b2c <free+0x16>
    bp->s.ptr = p->s.ptr;
 b7c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b80:	4790                	lw	a2,8(a5)
 b82:	02061713          	slli	a4,a2,0x20
 b86:	9301                	srli	a4,a4,0x20
 b88:	0712                	slli	a4,a4,0x4
 b8a:	973e                	add	a4,a4,a5
 b8c:	fae689e3          	beq	a3,a4,b3e <free+0x28>
  } else
    p->s.ptr = bp;
 b90:	e394                	sd	a3,0(a5)
  freep = p;
 b92:	00000717          	auipc	a4,0x0
 b96:	24f73723          	sd	a5,590(a4) # de0 <freep>
}
 b9a:	6422                	ld	s0,8(sp)
 b9c:	0141                	addi	sp,sp,16
 b9e:	8082                	ret

0000000000000ba0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ba0:	7139                	addi	sp,sp,-64
 ba2:	fc06                	sd	ra,56(sp)
 ba4:	f822                	sd	s0,48(sp)
 ba6:	f426                	sd	s1,40(sp)
 ba8:	f04a                	sd	s2,32(sp)
 baa:	ec4e                	sd	s3,24(sp)
 bac:	e852                	sd	s4,16(sp)
 bae:	e456                	sd	s5,8(sp)
 bb0:	e05a                	sd	s6,0(sp)
 bb2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bb4:	02051993          	slli	s3,a0,0x20
 bb8:	0209d993          	srli	s3,s3,0x20
 bbc:	09bd                	addi	s3,s3,15
 bbe:	0049d993          	srli	s3,s3,0x4
 bc2:	2985                	addiw	s3,s3,1
 bc4:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 bc8:	00000797          	auipc	a5,0x0
 bcc:	21878793          	addi	a5,a5,536 # de0 <freep>
 bd0:	6388                	ld	a0,0(a5)
 bd2:	c515                	beqz	a0,bfe <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bd4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bd6:	4798                	lw	a4,8(a5)
 bd8:	03277f63          	bleu	s2,a4,c16 <malloc+0x76>
 bdc:	8a4e                	mv	s4,s3
 bde:	0009871b          	sext.w	a4,s3
 be2:	6685                	lui	a3,0x1
 be4:	00d77363          	bleu	a3,a4,bea <malloc+0x4a>
 be8:	6a05                	lui	s4,0x1
 bea:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 bee:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 bf2:	00000497          	auipc	s1,0x0
 bf6:	1ee48493          	addi	s1,s1,494 # de0 <freep>
  if(p == (char*)-1)
 bfa:	5b7d                	li	s6,-1
 bfc:	a885                	j	c6c <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 bfe:	00004797          	auipc	a5,0x4
 c02:	1ea78793          	addi	a5,a5,490 # 4de8 <base>
 c06:	00000717          	auipc	a4,0x0
 c0a:	1cf73d23          	sd	a5,474(a4) # de0 <freep>
 c0e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c10:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 c14:	b7e1                	j	bdc <malloc+0x3c>
      if(p->s.size == nunits)
 c16:	02e90b63          	beq	s2,a4,c4c <malloc+0xac>
        p->s.size -= nunits;
 c1a:	4137073b          	subw	a4,a4,s3
 c1e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c20:	1702                	slli	a4,a4,0x20
 c22:	9301                	srli	a4,a4,0x20
 c24:	0712                	slli	a4,a4,0x4
 c26:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c28:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c2c:	00000717          	auipc	a4,0x0
 c30:	1aa73a23          	sd	a0,436(a4) # de0 <freep>
      return (void*)(p + 1);
 c34:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 c38:	70e2                	ld	ra,56(sp)
 c3a:	7442                	ld	s0,48(sp)
 c3c:	74a2                	ld	s1,40(sp)
 c3e:	7902                	ld	s2,32(sp)
 c40:	69e2                	ld	s3,24(sp)
 c42:	6a42                	ld	s4,16(sp)
 c44:	6aa2                	ld	s5,8(sp)
 c46:	6b02                	ld	s6,0(sp)
 c48:	6121                	addi	sp,sp,64
 c4a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 c4c:	6398                	ld	a4,0(a5)
 c4e:	e118                	sd	a4,0(a0)
 c50:	bff1                	j	c2c <malloc+0x8c>
  hp->s.size = nu;
 c52:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 c56:	0541                	addi	a0,a0,16
 c58:	00000097          	auipc	ra,0x0
 c5c:	ebe080e7          	jalr	-322(ra) # b16 <free>
  return freep;
 c60:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 c62:	d979                	beqz	a0,c38 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c64:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c66:	4798                	lw	a4,8(a5)
 c68:	fb2777e3          	bleu	s2,a4,c16 <malloc+0x76>
    if(p == freep)
 c6c:	6098                	ld	a4,0(s1)
 c6e:	853e                	mv	a0,a5
 c70:	fef71ae3          	bne	a4,a5,c64 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 c74:	8552                	mv	a0,s4
 c76:	00000097          	auipc	ra,0x0
 c7a:	b7a080e7          	jalr	-1158(ra) # 7f0 <sbrk>
  if(p == (char*)-1)
 c7e:	fd651ae3          	bne	a0,s6,c52 <malloc+0xb2>
        return 0;
 c82:	4501                	li	a0,0
 c84:	bf55                	j	c38 <malloc+0x98>
