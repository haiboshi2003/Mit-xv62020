
user/_usertests：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00005097          	auipc	ra,0x5
      14:	690080e7          	jalr	1680(ra) # 56a0 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00005097          	auipc	ra,0x5
      26:	67e080e7          	jalr	1662(ra) # 56a0 <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	f1250513          	addi	a0,a0,-238 # 5f50 <malloc+0x4b8>
      46:	00006097          	auipc	ra,0x6
      4a:	992080e7          	jalr	-1646(ra) # 59d8 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	610080e7          	jalr	1552(ra) # 5660 <exit>

0000000000000058 <bsstest>:
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
    if(uninit[i] != '\0'){
      58:	00009797          	auipc	a5,0x9
      5c:	3887c783          	lbu	a5,904(a5) # 93e0 <uninit>
      60:	e385                	bnez	a5,80 <bsstest+0x28>
      62:	00009797          	auipc	a5,0x9
      66:	37f78793          	addi	a5,a5,895 # 93e1 <uninit+0x1>
      6a:	0000c697          	auipc	a3,0xc
      6e:	a8668693          	addi	a3,a3,-1402 # baf0 <buf>
      72:	0007c703          	lbu	a4,0(a5)
      76:	e709                	bnez	a4,80 <bsstest+0x28>
  for(i = 0; i < sizeof(uninit); i++){
      78:	0785                	addi	a5,a5,1
      7a:	fed79ce3          	bne	a5,a3,72 <bsstest+0x1a>
      7e:	8082                	ret
{
      80:	1141                	addi	sp,sp,-16
      82:	e406                	sd	ra,8(sp)
      84:	e022                	sd	s0,0(sp)
      86:	0800                	addi	s0,sp,16
      88:	85aa                	mv	a1,a0
      printf("%s: bss test failed\n", s);
      8a:	00006517          	auipc	a0,0x6
      8e:	ee650513          	addi	a0,a0,-282 # 5f70 <malloc+0x4d8>
      92:	00006097          	auipc	ra,0x6
      96:	946080e7          	jalr	-1722(ra) # 59d8 <printf>
      exit(1);
      9a:	4505                	li	a0,1
      9c:	00005097          	auipc	ra,0x5
      a0:	5c4080e7          	jalr	1476(ra) # 5660 <exit>

00000000000000a4 <opentest>:
{
      a4:	1101                	addi	sp,sp,-32
      a6:	ec06                	sd	ra,24(sp)
      a8:	e822                	sd	s0,16(sp)
      aa:	e426                	sd	s1,8(sp)
      ac:	1000                	addi	s0,sp,32
      ae:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      b0:	4581                	li	a1,0
      b2:	00006517          	auipc	a0,0x6
      b6:	ed650513          	addi	a0,a0,-298 # 5f88 <malloc+0x4f0>
      ba:	00005097          	auipc	ra,0x5
      be:	5e6080e7          	jalr	1510(ra) # 56a0 <open>
  if(fd < 0){
      c2:	02054663          	bltz	a0,ee <opentest+0x4a>
  close(fd);
      c6:	00005097          	auipc	ra,0x5
      ca:	5c2080e7          	jalr	1474(ra) # 5688 <close>
  fd = open("doesnotexist", 0);
      ce:	4581                	li	a1,0
      d0:	00006517          	auipc	a0,0x6
      d4:	ed850513          	addi	a0,a0,-296 # 5fa8 <malloc+0x510>
      d8:	00005097          	auipc	ra,0x5
      dc:	5c8080e7          	jalr	1480(ra) # 56a0 <open>
  if(fd >= 0){
      e0:	02055563          	bgez	a0,10a <opentest+0x66>
}
      e4:	60e2                	ld	ra,24(sp)
      e6:	6442                	ld	s0,16(sp)
      e8:	64a2                	ld	s1,8(sp)
      ea:	6105                	addi	sp,sp,32
      ec:	8082                	ret
    printf("%s: open echo failed!\n", s);
      ee:	85a6                	mv	a1,s1
      f0:	00006517          	auipc	a0,0x6
      f4:	ea050513          	addi	a0,a0,-352 # 5f90 <malloc+0x4f8>
      f8:	00006097          	auipc	ra,0x6
      fc:	8e0080e7          	jalr	-1824(ra) # 59d8 <printf>
    exit(1);
     100:	4505                	li	a0,1
     102:	00005097          	auipc	ra,0x5
     106:	55e080e7          	jalr	1374(ra) # 5660 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     10a:	85a6                	mv	a1,s1
     10c:	00006517          	auipc	a0,0x6
     110:	eac50513          	addi	a0,a0,-340 # 5fb8 <malloc+0x520>
     114:	00006097          	auipc	ra,0x6
     118:	8c4080e7          	jalr	-1852(ra) # 59d8 <printf>
    exit(1);
     11c:	4505                	li	a0,1
     11e:	00005097          	auipc	ra,0x5
     122:	542080e7          	jalr	1346(ra) # 5660 <exit>

0000000000000126 <truncate2>:
{
     126:	7179                	addi	sp,sp,-48
     128:	f406                	sd	ra,40(sp)
     12a:	f022                	sd	s0,32(sp)
     12c:	ec26                	sd	s1,24(sp)
     12e:	e84a                	sd	s2,16(sp)
     130:	e44e                	sd	s3,8(sp)
     132:	1800                	addi	s0,sp,48
     134:	89aa                	mv	s3,a0
  unlink("truncfile");
     136:	00006517          	auipc	a0,0x6
     13a:	eaa50513          	addi	a0,a0,-342 # 5fe0 <malloc+0x548>
     13e:	00005097          	auipc	ra,0x5
     142:	572080e7          	jalr	1394(ra) # 56b0 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     146:	60100593          	li	a1,1537
     14a:	00006517          	auipc	a0,0x6
     14e:	e9650513          	addi	a0,a0,-362 # 5fe0 <malloc+0x548>
     152:	00005097          	auipc	ra,0x5
     156:	54e080e7          	jalr	1358(ra) # 56a0 <open>
     15a:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     15c:	4611                	li	a2,4
     15e:	00006597          	auipc	a1,0x6
     162:	e9258593          	addi	a1,a1,-366 # 5ff0 <malloc+0x558>
     166:	00005097          	auipc	ra,0x5
     16a:	51a080e7          	jalr	1306(ra) # 5680 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     16e:	40100593          	li	a1,1025
     172:	00006517          	auipc	a0,0x6
     176:	e6e50513          	addi	a0,a0,-402 # 5fe0 <malloc+0x548>
     17a:	00005097          	auipc	ra,0x5
     17e:	526080e7          	jalr	1318(ra) # 56a0 <open>
     182:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     184:	4605                	li	a2,1
     186:	00006597          	auipc	a1,0x6
     18a:	e7258593          	addi	a1,a1,-398 # 5ff8 <malloc+0x560>
     18e:	8526                	mv	a0,s1
     190:	00005097          	auipc	ra,0x5
     194:	4f0080e7          	jalr	1264(ra) # 5680 <write>
  if(n != -1){
     198:	57fd                	li	a5,-1
     19a:	02f51b63          	bne	a0,a5,1d0 <truncate2+0xaa>
  unlink("truncfile");
     19e:	00006517          	auipc	a0,0x6
     1a2:	e4250513          	addi	a0,a0,-446 # 5fe0 <malloc+0x548>
     1a6:	00005097          	auipc	ra,0x5
     1aa:	50a080e7          	jalr	1290(ra) # 56b0 <unlink>
  close(fd1);
     1ae:	8526                	mv	a0,s1
     1b0:	00005097          	auipc	ra,0x5
     1b4:	4d8080e7          	jalr	1240(ra) # 5688 <close>
  close(fd2);
     1b8:	854a                	mv	a0,s2
     1ba:	00005097          	auipc	ra,0x5
     1be:	4ce080e7          	jalr	1230(ra) # 5688 <close>
}
     1c2:	70a2                	ld	ra,40(sp)
     1c4:	7402                	ld	s0,32(sp)
     1c6:	64e2                	ld	s1,24(sp)
     1c8:	6942                	ld	s2,16(sp)
     1ca:	69a2                	ld	s3,8(sp)
     1cc:	6145                	addi	sp,sp,48
     1ce:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1d0:	862a                	mv	a2,a0
     1d2:	85ce                	mv	a1,s3
     1d4:	00006517          	auipc	a0,0x6
     1d8:	e2c50513          	addi	a0,a0,-468 # 6000 <malloc+0x568>
     1dc:	00005097          	auipc	ra,0x5
     1e0:	7fc080e7          	jalr	2044(ra) # 59d8 <printf>
    exit(1);
     1e4:	4505                	li	a0,1
     1e6:	00005097          	auipc	ra,0x5
     1ea:	47a080e7          	jalr	1146(ra) # 5660 <exit>

00000000000001ee <createtest>:
{
     1ee:	7179                	addi	sp,sp,-48
     1f0:	f406                	sd	ra,40(sp)
     1f2:	f022                	sd	s0,32(sp)
     1f4:	ec26                	sd	s1,24(sp)
     1f6:	e84a                	sd	s2,16(sp)
     1f8:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1fa:	06100793          	li	a5,97
     1fe:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     202:	fc040d23          	sb	zero,-38(s0)
     206:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     20a:	06400913          	li	s2,100
    name[1] = '0' + i;
     20e:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     212:	20200593          	li	a1,514
     216:	fd840513          	addi	a0,s0,-40
     21a:	00005097          	auipc	ra,0x5
     21e:	486080e7          	jalr	1158(ra) # 56a0 <open>
    close(fd);
     222:	00005097          	auipc	ra,0x5
     226:	466080e7          	jalr	1126(ra) # 5688 <close>
  for(i = 0; i < N; i++){
     22a:	2485                	addiw	s1,s1,1
     22c:	0ff4f493          	andi	s1,s1,255
     230:	fd249fe3          	bne	s1,s2,20e <createtest+0x20>
  name[0] = 'a';
     234:	06100793          	li	a5,97
     238:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     23c:	fc040d23          	sb	zero,-38(s0)
     240:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     244:	06400913          	li	s2,100
    name[1] = '0' + i;
     248:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     24c:	fd840513          	addi	a0,s0,-40
     250:	00005097          	auipc	ra,0x5
     254:	460080e7          	jalr	1120(ra) # 56b0 <unlink>
  for(i = 0; i < N; i++){
     258:	2485                	addiw	s1,s1,1
     25a:	0ff4f493          	andi	s1,s1,255
     25e:	ff2495e3          	bne	s1,s2,248 <createtest+0x5a>
}
     262:	70a2                	ld	ra,40(sp)
     264:	7402                	ld	s0,32(sp)
     266:	64e2                	ld	s1,24(sp)
     268:	6942                	ld	s2,16(sp)
     26a:	6145                	addi	sp,sp,48
     26c:	8082                	ret

000000000000026e <bigwrite>:
{
     26e:	715d                	addi	sp,sp,-80
     270:	e486                	sd	ra,72(sp)
     272:	e0a2                	sd	s0,64(sp)
     274:	fc26                	sd	s1,56(sp)
     276:	f84a                	sd	s2,48(sp)
     278:	f44e                	sd	s3,40(sp)
     27a:	f052                	sd	s4,32(sp)
     27c:	ec56                	sd	s5,24(sp)
     27e:	e85a                	sd	s6,16(sp)
     280:	e45e                	sd	s7,8(sp)
     282:	0880                	addi	s0,sp,80
     284:	8baa                	mv	s7,a0
  unlink("bigwrite");
     286:	00006517          	auipc	a0,0x6
     28a:	da250513          	addi	a0,a0,-606 # 6028 <malloc+0x590>
     28e:	00005097          	auipc	ra,0x5
     292:	422080e7          	jalr	1058(ra) # 56b0 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     296:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     29a:	00006a17          	auipc	s4,0x6
     29e:	d8ea0a13          	addi	s4,s4,-626 # 6028 <malloc+0x590>
      int cc = write(fd, buf, sz);
     2a2:	0000c997          	auipc	s3,0xc
     2a6:	84e98993          	addi	s3,s3,-1970 # baf0 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2aa:	6b0d                	lui	s6,0x3
     2ac:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x147>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2b0:	20200593          	li	a1,514
     2b4:	8552                	mv	a0,s4
     2b6:	00005097          	auipc	ra,0x5
     2ba:	3ea080e7          	jalr	1002(ra) # 56a0 <open>
     2be:	892a                	mv	s2,a0
    if(fd < 0){
     2c0:	04054d63          	bltz	a0,31a <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2c4:	8626                	mv	a2,s1
     2c6:	85ce                	mv	a1,s3
     2c8:	00005097          	auipc	ra,0x5
     2cc:	3b8080e7          	jalr	952(ra) # 5680 <write>
     2d0:	8aaa                	mv	s5,a0
      if(cc != sz){
     2d2:	06a49463          	bne	s1,a0,33a <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2d6:	8626                	mv	a2,s1
     2d8:	85ce                	mv	a1,s3
     2da:	854a                	mv	a0,s2
     2dc:	00005097          	auipc	ra,0x5
     2e0:	3a4080e7          	jalr	932(ra) # 5680 <write>
      if(cc != sz){
     2e4:	04951963          	bne	a0,s1,336 <bigwrite+0xc8>
    close(fd);
     2e8:	854a                	mv	a0,s2
     2ea:	00005097          	auipc	ra,0x5
     2ee:	39e080e7          	jalr	926(ra) # 5688 <close>
    unlink("bigwrite");
     2f2:	8552                	mv	a0,s4
     2f4:	00005097          	auipc	ra,0x5
     2f8:	3bc080e7          	jalr	956(ra) # 56b0 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2fc:	1d74849b          	addiw	s1,s1,471
     300:	fb6498e3          	bne	s1,s6,2b0 <bigwrite+0x42>
}
     304:	60a6                	ld	ra,72(sp)
     306:	6406                	ld	s0,64(sp)
     308:	74e2                	ld	s1,56(sp)
     30a:	7942                	ld	s2,48(sp)
     30c:	79a2                	ld	s3,40(sp)
     30e:	7a02                	ld	s4,32(sp)
     310:	6ae2                	ld	s5,24(sp)
     312:	6b42                	ld	s6,16(sp)
     314:	6ba2                	ld	s7,8(sp)
     316:	6161                	addi	sp,sp,80
     318:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     31a:	85de                	mv	a1,s7
     31c:	00006517          	auipc	a0,0x6
     320:	d1c50513          	addi	a0,a0,-740 # 6038 <malloc+0x5a0>
     324:	00005097          	auipc	ra,0x5
     328:	6b4080e7          	jalr	1716(ra) # 59d8 <printf>
      exit(1);
     32c:	4505                	li	a0,1
     32e:	00005097          	auipc	ra,0x5
     332:	332080e7          	jalr	818(ra) # 5660 <exit>
     336:	84d6                	mv	s1,s5
      int cc = write(fd, buf, sz);
     338:	8aaa                	mv	s5,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     33a:	86d6                	mv	a3,s5
     33c:	8626                	mv	a2,s1
     33e:	85de                	mv	a1,s7
     340:	00006517          	auipc	a0,0x6
     344:	d1850513          	addi	a0,a0,-744 # 6058 <malloc+0x5c0>
     348:	00005097          	auipc	ra,0x5
     34c:	690080e7          	jalr	1680(ra) # 59d8 <printf>
        exit(1);
     350:	4505                	li	a0,1
     352:	00005097          	auipc	ra,0x5
     356:	30e080e7          	jalr	782(ra) # 5660 <exit>

000000000000035a <copyin>:
{
     35a:	711d                	addi	sp,sp,-96
     35c:	ec86                	sd	ra,88(sp)
     35e:	e8a2                	sd	s0,80(sp)
     360:	e4a6                	sd	s1,72(sp)
     362:	e0ca                	sd	s2,64(sp)
     364:	fc4e                	sd	s3,56(sp)
     366:	f852                	sd	s4,48(sp)
     368:	f456                	sd	s5,40(sp)
     36a:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     36c:	4785                	li	a5,1
     36e:	07fe                	slli	a5,a5,0x1f
     370:	faf43823          	sd	a5,-80(s0)
     374:	57fd                	li	a5,-1
     376:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     37a:	fb040493          	addi	s1,s0,-80
     37e:	fc040a93          	addi	s5,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     382:	00006a17          	auipc	s4,0x6
     386:	ceea0a13          	addi	s4,s4,-786 # 6070 <malloc+0x5d8>
    uint64 addr = addrs[ai];
     38a:	0004b903          	ld	s2,0(s1)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     38e:	20100593          	li	a1,513
     392:	8552                	mv	a0,s4
     394:	00005097          	auipc	ra,0x5
     398:	30c080e7          	jalr	780(ra) # 56a0 <open>
     39c:	89aa                	mv	s3,a0
    if(fd < 0){
     39e:	08054763          	bltz	a0,42c <copyin+0xd2>
    int n = write(fd, (void*)addr, 8192);
     3a2:	6609                	lui	a2,0x2
     3a4:	85ca                	mv	a1,s2
     3a6:	00005097          	auipc	ra,0x5
     3aa:	2da080e7          	jalr	730(ra) # 5680 <write>
    if(n >= 0){
     3ae:	08055c63          	bgez	a0,446 <copyin+0xec>
    close(fd);
     3b2:	854e                	mv	a0,s3
     3b4:	00005097          	auipc	ra,0x5
     3b8:	2d4080e7          	jalr	724(ra) # 5688 <close>
    unlink("copyin1");
     3bc:	8552                	mv	a0,s4
     3be:	00005097          	auipc	ra,0x5
     3c2:	2f2080e7          	jalr	754(ra) # 56b0 <unlink>
    n = write(1, (char*)addr, 8192);
     3c6:	6609                	lui	a2,0x2
     3c8:	85ca                	mv	a1,s2
     3ca:	4505                	li	a0,1
     3cc:	00005097          	auipc	ra,0x5
     3d0:	2b4080e7          	jalr	692(ra) # 5680 <write>
    if(n > 0){
     3d4:	08a04863          	bgtz	a0,464 <copyin+0x10a>
    if(pipe(fds) < 0){
     3d8:	fa840513          	addi	a0,s0,-88
     3dc:	00005097          	auipc	ra,0x5
     3e0:	294080e7          	jalr	660(ra) # 5670 <pipe>
     3e4:	08054f63          	bltz	a0,482 <copyin+0x128>
    n = write(fds[1], (char*)addr, 8192);
     3e8:	6609                	lui	a2,0x2
     3ea:	85ca                	mv	a1,s2
     3ec:	fac42503          	lw	a0,-84(s0)
     3f0:	00005097          	auipc	ra,0x5
     3f4:	290080e7          	jalr	656(ra) # 5680 <write>
    if(n > 0){
     3f8:	0aa04263          	bgtz	a0,49c <copyin+0x142>
    close(fds[0]);
     3fc:	fa842503          	lw	a0,-88(s0)
     400:	00005097          	auipc	ra,0x5
     404:	288080e7          	jalr	648(ra) # 5688 <close>
    close(fds[1]);
     408:	fac42503          	lw	a0,-84(s0)
     40c:	00005097          	auipc	ra,0x5
     410:	27c080e7          	jalr	636(ra) # 5688 <close>
  for(int ai = 0; ai < 2; ai++){
     414:	04a1                	addi	s1,s1,8
     416:	f7549ae3          	bne	s1,s5,38a <copyin+0x30>
}
     41a:	60e6                	ld	ra,88(sp)
     41c:	6446                	ld	s0,80(sp)
     41e:	64a6                	ld	s1,72(sp)
     420:	6906                	ld	s2,64(sp)
     422:	79e2                	ld	s3,56(sp)
     424:	7a42                	ld	s4,48(sp)
     426:	7aa2                	ld	s5,40(sp)
     428:	6125                	addi	sp,sp,96
     42a:	8082                	ret
      printf("open(copyin1) failed\n");
     42c:	00006517          	auipc	a0,0x6
     430:	c4c50513          	addi	a0,a0,-948 # 6078 <malloc+0x5e0>
     434:	00005097          	auipc	ra,0x5
     438:	5a4080e7          	jalr	1444(ra) # 59d8 <printf>
      exit(1);
     43c:	4505                	li	a0,1
     43e:	00005097          	auipc	ra,0x5
     442:	222080e7          	jalr	546(ra) # 5660 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     446:	862a                	mv	a2,a0
     448:	85ca                	mv	a1,s2
     44a:	00006517          	auipc	a0,0x6
     44e:	c4650513          	addi	a0,a0,-954 # 6090 <malloc+0x5f8>
     452:	00005097          	auipc	ra,0x5
     456:	586080e7          	jalr	1414(ra) # 59d8 <printf>
      exit(1);
     45a:	4505                	li	a0,1
     45c:	00005097          	auipc	ra,0x5
     460:	204080e7          	jalr	516(ra) # 5660 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     464:	862a                	mv	a2,a0
     466:	85ca                	mv	a1,s2
     468:	00006517          	auipc	a0,0x6
     46c:	c5850513          	addi	a0,a0,-936 # 60c0 <malloc+0x628>
     470:	00005097          	auipc	ra,0x5
     474:	568080e7          	jalr	1384(ra) # 59d8 <printf>
      exit(1);
     478:	4505                	li	a0,1
     47a:	00005097          	auipc	ra,0x5
     47e:	1e6080e7          	jalr	486(ra) # 5660 <exit>
      printf("pipe() failed\n");
     482:	00006517          	auipc	a0,0x6
     486:	c6e50513          	addi	a0,a0,-914 # 60f0 <malloc+0x658>
     48a:	00005097          	auipc	ra,0x5
     48e:	54e080e7          	jalr	1358(ra) # 59d8 <printf>
      exit(1);
     492:	4505                	li	a0,1
     494:	00005097          	auipc	ra,0x5
     498:	1cc080e7          	jalr	460(ra) # 5660 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     49c:	862a                	mv	a2,a0
     49e:	85ca                	mv	a1,s2
     4a0:	00006517          	auipc	a0,0x6
     4a4:	c6050513          	addi	a0,a0,-928 # 6100 <malloc+0x668>
     4a8:	00005097          	auipc	ra,0x5
     4ac:	530080e7          	jalr	1328(ra) # 59d8 <printf>
      exit(1);
     4b0:	4505                	li	a0,1
     4b2:	00005097          	auipc	ra,0x5
     4b6:	1ae080e7          	jalr	430(ra) # 5660 <exit>

00000000000004ba <copyout>:
{
     4ba:	711d                	addi	sp,sp,-96
     4bc:	ec86                	sd	ra,88(sp)
     4be:	e8a2                	sd	s0,80(sp)
     4c0:	e4a6                	sd	s1,72(sp)
     4c2:	e0ca                	sd	s2,64(sp)
     4c4:	fc4e                	sd	s3,56(sp)
     4c6:	f852                	sd	s4,48(sp)
     4c8:	f456                	sd	s5,40(sp)
     4ca:	f05a                	sd	s6,32(sp)
     4cc:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     4ce:	4785                	li	a5,1
     4d0:	07fe                	slli	a5,a5,0x1f
     4d2:	faf43823          	sd	a5,-80(s0)
     4d6:	57fd                	li	a5,-1
     4d8:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     4dc:	fb040493          	addi	s1,s0,-80
     4e0:	fc040b13          	addi	s6,s0,-64
    int fd = open("README", 0);
     4e4:	00006a17          	auipc	s4,0x6
     4e8:	c4ca0a13          	addi	s4,s4,-948 # 6130 <malloc+0x698>
    n = write(fds[1], "x", 1);
     4ec:	00006a97          	auipc	s5,0x6
     4f0:	b0ca8a93          	addi	s5,s5,-1268 # 5ff8 <malloc+0x560>
    uint64 addr = addrs[ai];
     4f4:	0004b983          	ld	s3,0(s1)
    int fd = open("README", 0);
     4f8:	4581                	li	a1,0
     4fa:	8552                	mv	a0,s4
     4fc:	00005097          	auipc	ra,0x5
     500:	1a4080e7          	jalr	420(ra) # 56a0 <open>
     504:	892a                	mv	s2,a0
    if(fd < 0){
     506:	08054563          	bltz	a0,590 <copyout+0xd6>
    int n = read(fd, (void*)addr, 8192);
     50a:	6609                	lui	a2,0x2
     50c:	85ce                	mv	a1,s3
     50e:	00005097          	auipc	ra,0x5
     512:	16a080e7          	jalr	362(ra) # 5678 <read>
    if(n > 0){
     516:	08a04a63          	bgtz	a0,5aa <copyout+0xf0>
    close(fd);
     51a:	854a                	mv	a0,s2
     51c:	00005097          	auipc	ra,0x5
     520:	16c080e7          	jalr	364(ra) # 5688 <close>
    if(pipe(fds) < 0){
     524:	fa840513          	addi	a0,s0,-88
     528:	00005097          	auipc	ra,0x5
     52c:	148080e7          	jalr	328(ra) # 5670 <pipe>
     530:	08054c63          	bltz	a0,5c8 <copyout+0x10e>
    n = write(fds[1], "x", 1);
     534:	4605                	li	a2,1
     536:	85d6                	mv	a1,s5
     538:	fac42503          	lw	a0,-84(s0)
     53c:	00005097          	auipc	ra,0x5
     540:	144080e7          	jalr	324(ra) # 5680 <write>
    if(n != 1){
     544:	4785                	li	a5,1
     546:	08f51e63          	bne	a0,a5,5e2 <copyout+0x128>
    n = read(fds[0], (void*)addr, 8192);
     54a:	6609                	lui	a2,0x2
     54c:	85ce                	mv	a1,s3
     54e:	fa842503          	lw	a0,-88(s0)
     552:	00005097          	auipc	ra,0x5
     556:	126080e7          	jalr	294(ra) # 5678 <read>
    if(n > 0){
     55a:	0aa04163          	bgtz	a0,5fc <copyout+0x142>
    close(fds[0]);
     55e:	fa842503          	lw	a0,-88(s0)
     562:	00005097          	auipc	ra,0x5
     566:	126080e7          	jalr	294(ra) # 5688 <close>
    close(fds[1]);
     56a:	fac42503          	lw	a0,-84(s0)
     56e:	00005097          	auipc	ra,0x5
     572:	11a080e7          	jalr	282(ra) # 5688 <close>
  for(int ai = 0; ai < 2; ai++){
     576:	04a1                	addi	s1,s1,8
     578:	f7649ee3          	bne	s1,s6,4f4 <copyout+0x3a>
}
     57c:	60e6                	ld	ra,88(sp)
     57e:	6446                	ld	s0,80(sp)
     580:	64a6                	ld	s1,72(sp)
     582:	6906                	ld	s2,64(sp)
     584:	79e2                	ld	s3,56(sp)
     586:	7a42                	ld	s4,48(sp)
     588:	7aa2                	ld	s5,40(sp)
     58a:	7b02                	ld	s6,32(sp)
     58c:	6125                	addi	sp,sp,96
     58e:	8082                	ret
      printf("open(README) failed\n");
     590:	00006517          	auipc	a0,0x6
     594:	ba850513          	addi	a0,a0,-1112 # 6138 <malloc+0x6a0>
     598:	00005097          	auipc	ra,0x5
     59c:	440080e7          	jalr	1088(ra) # 59d8 <printf>
      exit(1);
     5a0:	4505                	li	a0,1
     5a2:	00005097          	auipc	ra,0x5
     5a6:	0be080e7          	jalr	190(ra) # 5660 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5aa:	862a                	mv	a2,a0
     5ac:	85ce                	mv	a1,s3
     5ae:	00006517          	auipc	a0,0x6
     5b2:	ba250513          	addi	a0,a0,-1118 # 6150 <malloc+0x6b8>
     5b6:	00005097          	auipc	ra,0x5
     5ba:	422080e7          	jalr	1058(ra) # 59d8 <printf>
      exit(1);
     5be:	4505                	li	a0,1
     5c0:	00005097          	auipc	ra,0x5
     5c4:	0a0080e7          	jalr	160(ra) # 5660 <exit>
      printf("pipe() failed\n");
     5c8:	00006517          	auipc	a0,0x6
     5cc:	b2850513          	addi	a0,a0,-1240 # 60f0 <malloc+0x658>
     5d0:	00005097          	auipc	ra,0x5
     5d4:	408080e7          	jalr	1032(ra) # 59d8 <printf>
      exit(1);
     5d8:	4505                	li	a0,1
     5da:	00005097          	auipc	ra,0x5
     5de:	086080e7          	jalr	134(ra) # 5660 <exit>
      printf("pipe write failed\n");
     5e2:	00006517          	auipc	a0,0x6
     5e6:	b9e50513          	addi	a0,a0,-1122 # 6180 <malloc+0x6e8>
     5ea:	00005097          	auipc	ra,0x5
     5ee:	3ee080e7          	jalr	1006(ra) # 59d8 <printf>
      exit(1);
     5f2:	4505                	li	a0,1
     5f4:	00005097          	auipc	ra,0x5
     5f8:	06c080e7          	jalr	108(ra) # 5660 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5fc:	862a                	mv	a2,a0
     5fe:	85ce                	mv	a1,s3
     600:	00006517          	auipc	a0,0x6
     604:	b9850513          	addi	a0,a0,-1128 # 6198 <malloc+0x700>
     608:	00005097          	auipc	ra,0x5
     60c:	3d0080e7          	jalr	976(ra) # 59d8 <printf>
      exit(1);
     610:	4505                	li	a0,1
     612:	00005097          	auipc	ra,0x5
     616:	04e080e7          	jalr	78(ra) # 5660 <exit>

000000000000061a <truncate1>:
{
     61a:	711d                	addi	sp,sp,-96
     61c:	ec86                	sd	ra,88(sp)
     61e:	e8a2                	sd	s0,80(sp)
     620:	e4a6                	sd	s1,72(sp)
     622:	e0ca                	sd	s2,64(sp)
     624:	fc4e                	sd	s3,56(sp)
     626:	f852                	sd	s4,48(sp)
     628:	f456                	sd	s5,40(sp)
     62a:	1080                	addi	s0,sp,96
     62c:	8aaa                	mv	s5,a0
  unlink("truncfile");
     62e:	00006517          	auipc	a0,0x6
     632:	9b250513          	addi	a0,a0,-1614 # 5fe0 <malloc+0x548>
     636:	00005097          	auipc	ra,0x5
     63a:	07a080e7          	jalr	122(ra) # 56b0 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     63e:	60100593          	li	a1,1537
     642:	00006517          	auipc	a0,0x6
     646:	99e50513          	addi	a0,a0,-1634 # 5fe0 <malloc+0x548>
     64a:	00005097          	auipc	ra,0x5
     64e:	056080e7          	jalr	86(ra) # 56a0 <open>
     652:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     654:	4611                	li	a2,4
     656:	00006597          	auipc	a1,0x6
     65a:	99a58593          	addi	a1,a1,-1638 # 5ff0 <malloc+0x558>
     65e:	00005097          	auipc	ra,0x5
     662:	022080e7          	jalr	34(ra) # 5680 <write>
  close(fd1);
     666:	8526                	mv	a0,s1
     668:	00005097          	auipc	ra,0x5
     66c:	020080e7          	jalr	32(ra) # 5688 <close>
  int fd2 = open("truncfile", O_RDONLY);
     670:	4581                	li	a1,0
     672:	00006517          	auipc	a0,0x6
     676:	96e50513          	addi	a0,a0,-1682 # 5fe0 <malloc+0x548>
     67a:	00005097          	auipc	ra,0x5
     67e:	026080e7          	jalr	38(ra) # 56a0 <open>
     682:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     684:	02000613          	li	a2,32
     688:	fa040593          	addi	a1,s0,-96
     68c:	00005097          	auipc	ra,0x5
     690:	fec080e7          	jalr	-20(ra) # 5678 <read>
  if(n != 4){
     694:	4791                	li	a5,4
     696:	0cf51e63          	bne	a0,a5,772 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     69a:	40100593          	li	a1,1025
     69e:	00006517          	auipc	a0,0x6
     6a2:	94250513          	addi	a0,a0,-1726 # 5fe0 <malloc+0x548>
     6a6:	00005097          	auipc	ra,0x5
     6aa:	ffa080e7          	jalr	-6(ra) # 56a0 <open>
     6ae:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     6b0:	4581                	li	a1,0
     6b2:	00006517          	auipc	a0,0x6
     6b6:	92e50513          	addi	a0,a0,-1746 # 5fe0 <malloc+0x548>
     6ba:	00005097          	auipc	ra,0x5
     6be:	fe6080e7          	jalr	-26(ra) # 56a0 <open>
     6c2:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6c4:	02000613          	li	a2,32
     6c8:	fa040593          	addi	a1,s0,-96
     6cc:	00005097          	auipc	ra,0x5
     6d0:	fac080e7          	jalr	-84(ra) # 5678 <read>
     6d4:	8a2a                	mv	s4,a0
  if(n != 0){
     6d6:	ed4d                	bnez	a0,790 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     6d8:	02000613          	li	a2,32
     6dc:	fa040593          	addi	a1,s0,-96
     6e0:	8526                	mv	a0,s1
     6e2:	00005097          	auipc	ra,0x5
     6e6:	f96080e7          	jalr	-106(ra) # 5678 <read>
     6ea:	8a2a                	mv	s4,a0
  if(n != 0){
     6ec:	e971                	bnez	a0,7c0 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     6ee:	4619                	li	a2,6
     6f0:	00006597          	auipc	a1,0x6
     6f4:	b3858593          	addi	a1,a1,-1224 # 6228 <malloc+0x790>
     6f8:	854e                	mv	a0,s3
     6fa:	00005097          	auipc	ra,0x5
     6fe:	f86080e7          	jalr	-122(ra) # 5680 <write>
  n = read(fd3, buf, sizeof(buf));
     702:	02000613          	li	a2,32
     706:	fa040593          	addi	a1,s0,-96
     70a:	854a                	mv	a0,s2
     70c:	00005097          	auipc	ra,0x5
     710:	f6c080e7          	jalr	-148(ra) # 5678 <read>
  if(n != 6){
     714:	4799                	li	a5,6
     716:	0cf51d63          	bne	a0,a5,7f0 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     71a:	02000613          	li	a2,32
     71e:	fa040593          	addi	a1,s0,-96
     722:	8526                	mv	a0,s1
     724:	00005097          	auipc	ra,0x5
     728:	f54080e7          	jalr	-172(ra) # 5678 <read>
  if(n != 2){
     72c:	4789                	li	a5,2
     72e:	0ef51063          	bne	a0,a5,80e <truncate1+0x1f4>
  unlink("truncfile");
     732:	00006517          	auipc	a0,0x6
     736:	8ae50513          	addi	a0,a0,-1874 # 5fe0 <malloc+0x548>
     73a:	00005097          	auipc	ra,0x5
     73e:	f76080e7          	jalr	-138(ra) # 56b0 <unlink>
  close(fd1);
     742:	854e                	mv	a0,s3
     744:	00005097          	auipc	ra,0x5
     748:	f44080e7          	jalr	-188(ra) # 5688 <close>
  close(fd2);
     74c:	8526                	mv	a0,s1
     74e:	00005097          	auipc	ra,0x5
     752:	f3a080e7          	jalr	-198(ra) # 5688 <close>
  close(fd3);
     756:	854a                	mv	a0,s2
     758:	00005097          	auipc	ra,0x5
     75c:	f30080e7          	jalr	-208(ra) # 5688 <close>
}
     760:	60e6                	ld	ra,88(sp)
     762:	6446                	ld	s0,80(sp)
     764:	64a6                	ld	s1,72(sp)
     766:	6906                	ld	s2,64(sp)
     768:	79e2                	ld	s3,56(sp)
     76a:	7a42                	ld	s4,48(sp)
     76c:	7aa2                	ld	s5,40(sp)
     76e:	6125                	addi	sp,sp,96
     770:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     772:	862a                	mv	a2,a0
     774:	85d6                	mv	a1,s5
     776:	00006517          	auipc	a0,0x6
     77a:	a5250513          	addi	a0,a0,-1454 # 61c8 <malloc+0x730>
     77e:	00005097          	auipc	ra,0x5
     782:	25a080e7          	jalr	602(ra) # 59d8 <printf>
    exit(1);
     786:	4505                	li	a0,1
     788:	00005097          	auipc	ra,0x5
     78c:	ed8080e7          	jalr	-296(ra) # 5660 <exit>
    printf("aaa fd3=%d\n", fd3);
     790:	85ca                	mv	a1,s2
     792:	00006517          	auipc	a0,0x6
     796:	a5650513          	addi	a0,a0,-1450 # 61e8 <malloc+0x750>
     79a:	00005097          	auipc	ra,0x5
     79e:	23e080e7          	jalr	574(ra) # 59d8 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7a2:	8652                	mv	a2,s4
     7a4:	85d6                	mv	a1,s5
     7a6:	00006517          	auipc	a0,0x6
     7aa:	a5250513          	addi	a0,a0,-1454 # 61f8 <malloc+0x760>
     7ae:	00005097          	auipc	ra,0x5
     7b2:	22a080e7          	jalr	554(ra) # 59d8 <printf>
    exit(1);
     7b6:	4505                	li	a0,1
     7b8:	00005097          	auipc	ra,0x5
     7bc:	ea8080e7          	jalr	-344(ra) # 5660 <exit>
    printf("bbb fd2=%d\n", fd2);
     7c0:	85a6                	mv	a1,s1
     7c2:	00006517          	auipc	a0,0x6
     7c6:	a5650513          	addi	a0,a0,-1450 # 6218 <malloc+0x780>
     7ca:	00005097          	auipc	ra,0x5
     7ce:	20e080e7          	jalr	526(ra) # 59d8 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7d2:	8652                	mv	a2,s4
     7d4:	85d6                	mv	a1,s5
     7d6:	00006517          	auipc	a0,0x6
     7da:	a2250513          	addi	a0,a0,-1502 # 61f8 <malloc+0x760>
     7de:	00005097          	auipc	ra,0x5
     7e2:	1fa080e7          	jalr	506(ra) # 59d8 <printf>
    exit(1);
     7e6:	4505                	li	a0,1
     7e8:	00005097          	auipc	ra,0x5
     7ec:	e78080e7          	jalr	-392(ra) # 5660 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     7f0:	862a                	mv	a2,a0
     7f2:	85d6                	mv	a1,s5
     7f4:	00006517          	auipc	a0,0x6
     7f8:	a3c50513          	addi	a0,a0,-1476 # 6230 <malloc+0x798>
     7fc:	00005097          	auipc	ra,0x5
     800:	1dc080e7          	jalr	476(ra) # 59d8 <printf>
    exit(1);
     804:	4505                	li	a0,1
     806:	00005097          	auipc	ra,0x5
     80a:	e5a080e7          	jalr	-422(ra) # 5660 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     80e:	862a                	mv	a2,a0
     810:	85d6                	mv	a1,s5
     812:	00006517          	auipc	a0,0x6
     816:	a3e50513          	addi	a0,a0,-1474 # 6250 <malloc+0x7b8>
     81a:	00005097          	auipc	ra,0x5
     81e:	1be080e7          	jalr	446(ra) # 59d8 <printf>
    exit(1);
     822:	4505                	li	a0,1
     824:	00005097          	auipc	ra,0x5
     828:	e3c080e7          	jalr	-452(ra) # 5660 <exit>

000000000000082c <writetest>:
{
     82c:	7139                	addi	sp,sp,-64
     82e:	fc06                	sd	ra,56(sp)
     830:	f822                	sd	s0,48(sp)
     832:	f426                	sd	s1,40(sp)
     834:	f04a                	sd	s2,32(sp)
     836:	ec4e                	sd	s3,24(sp)
     838:	e852                	sd	s4,16(sp)
     83a:	e456                	sd	s5,8(sp)
     83c:	e05a                	sd	s6,0(sp)
     83e:	0080                	addi	s0,sp,64
     840:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     842:	20200593          	li	a1,514
     846:	00006517          	auipc	a0,0x6
     84a:	a2a50513          	addi	a0,a0,-1494 # 6270 <malloc+0x7d8>
     84e:	00005097          	auipc	ra,0x5
     852:	e52080e7          	jalr	-430(ra) # 56a0 <open>
  if(fd < 0){
     856:	0a054d63          	bltz	a0,910 <writetest+0xe4>
     85a:	892a                	mv	s2,a0
     85c:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     85e:	00006997          	auipc	s3,0x6
     862:	a3a98993          	addi	s3,s3,-1478 # 6298 <malloc+0x800>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     866:	00006a97          	auipc	s5,0x6
     86a:	a6aa8a93          	addi	s5,s5,-1430 # 62d0 <malloc+0x838>
  for(i = 0; i < N; i++){
     86e:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     872:	4629                	li	a2,10
     874:	85ce                	mv	a1,s3
     876:	854a                	mv	a0,s2
     878:	00005097          	auipc	ra,0x5
     87c:	e08080e7          	jalr	-504(ra) # 5680 <write>
     880:	47a9                	li	a5,10
     882:	0af51563          	bne	a0,a5,92c <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     886:	4629                	li	a2,10
     888:	85d6                	mv	a1,s5
     88a:	854a                	mv	a0,s2
     88c:	00005097          	auipc	ra,0x5
     890:	df4080e7          	jalr	-524(ra) # 5680 <write>
     894:	47a9                	li	a5,10
     896:	0af51a63          	bne	a0,a5,94a <writetest+0x11e>
  for(i = 0; i < N; i++){
     89a:	2485                	addiw	s1,s1,1
     89c:	fd449be3          	bne	s1,s4,872 <writetest+0x46>
  close(fd);
     8a0:	854a                	mv	a0,s2
     8a2:	00005097          	auipc	ra,0x5
     8a6:	de6080e7          	jalr	-538(ra) # 5688 <close>
  fd = open("small", O_RDONLY);
     8aa:	4581                	li	a1,0
     8ac:	00006517          	auipc	a0,0x6
     8b0:	9c450513          	addi	a0,a0,-1596 # 6270 <malloc+0x7d8>
     8b4:	00005097          	auipc	ra,0x5
     8b8:	dec080e7          	jalr	-532(ra) # 56a0 <open>
     8bc:	84aa                	mv	s1,a0
  if(fd < 0){
     8be:	0a054563          	bltz	a0,968 <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     8c2:	7d000613          	li	a2,2000
     8c6:	0000b597          	auipc	a1,0xb
     8ca:	22a58593          	addi	a1,a1,554 # baf0 <buf>
     8ce:	00005097          	auipc	ra,0x5
     8d2:	daa080e7          	jalr	-598(ra) # 5678 <read>
  if(i != N*SZ*2){
     8d6:	7d000793          	li	a5,2000
     8da:	0af51563          	bne	a0,a5,984 <writetest+0x158>
  close(fd);
     8de:	8526                	mv	a0,s1
     8e0:	00005097          	auipc	ra,0x5
     8e4:	da8080e7          	jalr	-600(ra) # 5688 <close>
  if(unlink("small") < 0){
     8e8:	00006517          	auipc	a0,0x6
     8ec:	98850513          	addi	a0,a0,-1656 # 6270 <malloc+0x7d8>
     8f0:	00005097          	auipc	ra,0x5
     8f4:	dc0080e7          	jalr	-576(ra) # 56b0 <unlink>
     8f8:	0a054463          	bltz	a0,9a0 <writetest+0x174>
}
     8fc:	70e2                	ld	ra,56(sp)
     8fe:	7442                	ld	s0,48(sp)
     900:	74a2                	ld	s1,40(sp)
     902:	7902                	ld	s2,32(sp)
     904:	69e2                	ld	s3,24(sp)
     906:	6a42                	ld	s4,16(sp)
     908:	6aa2                	ld	s5,8(sp)
     90a:	6b02                	ld	s6,0(sp)
     90c:	6121                	addi	sp,sp,64
     90e:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     910:	85da                	mv	a1,s6
     912:	00006517          	auipc	a0,0x6
     916:	96650513          	addi	a0,a0,-1690 # 6278 <malloc+0x7e0>
     91a:	00005097          	auipc	ra,0x5
     91e:	0be080e7          	jalr	190(ra) # 59d8 <printf>
    exit(1);
     922:	4505                	li	a0,1
     924:	00005097          	auipc	ra,0x5
     928:	d3c080e7          	jalr	-708(ra) # 5660 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     92c:	8626                	mv	a2,s1
     92e:	85da                	mv	a1,s6
     930:	00006517          	auipc	a0,0x6
     934:	97850513          	addi	a0,a0,-1672 # 62a8 <malloc+0x810>
     938:	00005097          	auipc	ra,0x5
     93c:	0a0080e7          	jalr	160(ra) # 59d8 <printf>
      exit(1);
     940:	4505                	li	a0,1
     942:	00005097          	auipc	ra,0x5
     946:	d1e080e7          	jalr	-738(ra) # 5660 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     94a:	8626                	mv	a2,s1
     94c:	85da                	mv	a1,s6
     94e:	00006517          	auipc	a0,0x6
     952:	99250513          	addi	a0,a0,-1646 # 62e0 <malloc+0x848>
     956:	00005097          	auipc	ra,0x5
     95a:	082080e7          	jalr	130(ra) # 59d8 <printf>
      exit(1);
     95e:	4505                	li	a0,1
     960:	00005097          	auipc	ra,0x5
     964:	d00080e7          	jalr	-768(ra) # 5660 <exit>
    printf("%s: error: open small failed!\n", s);
     968:	85da                	mv	a1,s6
     96a:	00006517          	auipc	a0,0x6
     96e:	99e50513          	addi	a0,a0,-1634 # 6308 <malloc+0x870>
     972:	00005097          	auipc	ra,0x5
     976:	066080e7          	jalr	102(ra) # 59d8 <printf>
    exit(1);
     97a:	4505                	li	a0,1
     97c:	00005097          	auipc	ra,0x5
     980:	ce4080e7          	jalr	-796(ra) # 5660 <exit>
    printf("%s: read failed\n", s);
     984:	85da                	mv	a1,s6
     986:	00006517          	auipc	a0,0x6
     98a:	9a250513          	addi	a0,a0,-1630 # 6328 <malloc+0x890>
     98e:	00005097          	auipc	ra,0x5
     992:	04a080e7          	jalr	74(ra) # 59d8 <printf>
    exit(1);
     996:	4505                	li	a0,1
     998:	00005097          	auipc	ra,0x5
     99c:	cc8080e7          	jalr	-824(ra) # 5660 <exit>
    printf("%s: unlink small failed\n", s);
     9a0:	85da                	mv	a1,s6
     9a2:	00006517          	auipc	a0,0x6
     9a6:	99e50513          	addi	a0,a0,-1634 # 6340 <malloc+0x8a8>
     9aa:	00005097          	auipc	ra,0x5
     9ae:	02e080e7          	jalr	46(ra) # 59d8 <printf>
    exit(1);
     9b2:	4505                	li	a0,1
     9b4:	00005097          	auipc	ra,0x5
     9b8:	cac080e7          	jalr	-852(ra) # 5660 <exit>

00000000000009bc <writebig>:
{
     9bc:	7139                	addi	sp,sp,-64
     9be:	fc06                	sd	ra,56(sp)
     9c0:	f822                	sd	s0,48(sp)
     9c2:	f426                	sd	s1,40(sp)
     9c4:	f04a                	sd	s2,32(sp)
     9c6:	ec4e                	sd	s3,24(sp)
     9c8:	e852                	sd	s4,16(sp)
     9ca:	e456                	sd	s5,8(sp)
     9cc:	0080                	addi	s0,sp,64
     9ce:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9d0:	20200593          	li	a1,514
     9d4:	00006517          	auipc	a0,0x6
     9d8:	98c50513          	addi	a0,a0,-1652 # 6360 <malloc+0x8c8>
     9dc:	00005097          	auipc	ra,0x5
     9e0:	cc4080e7          	jalr	-828(ra) # 56a0 <open>
     9e4:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9e6:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9e8:	0000b917          	auipc	s2,0xb
     9ec:	10890913          	addi	s2,s2,264 # baf0 <buf>
  for(i = 0; i < MAXFILE; i++){
     9f0:	10c00a13          	li	s4,268
  if(fd < 0){
     9f4:	06054c63          	bltz	a0,a6c <writebig+0xb0>
    ((int*)buf)[0] = i;
     9f8:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9fc:	40000613          	li	a2,1024
     a00:	85ca                	mv	a1,s2
     a02:	854e                	mv	a0,s3
     a04:	00005097          	auipc	ra,0x5
     a08:	c7c080e7          	jalr	-900(ra) # 5680 <write>
     a0c:	40000793          	li	a5,1024
     a10:	06f51c63          	bne	a0,a5,a88 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     a14:	2485                	addiw	s1,s1,1
     a16:	ff4491e3          	bne	s1,s4,9f8 <writebig+0x3c>
  close(fd);
     a1a:	854e                	mv	a0,s3
     a1c:	00005097          	auipc	ra,0x5
     a20:	c6c080e7          	jalr	-916(ra) # 5688 <close>
  fd = open("big", O_RDONLY);
     a24:	4581                	li	a1,0
     a26:	00006517          	auipc	a0,0x6
     a2a:	93a50513          	addi	a0,a0,-1734 # 6360 <malloc+0x8c8>
     a2e:	00005097          	auipc	ra,0x5
     a32:	c72080e7          	jalr	-910(ra) # 56a0 <open>
     a36:	89aa                	mv	s3,a0
  n = 0;
     a38:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a3a:	0000b917          	auipc	s2,0xb
     a3e:	0b690913          	addi	s2,s2,182 # baf0 <buf>
  if(fd < 0){
     a42:	06054263          	bltz	a0,aa6 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     a46:	40000613          	li	a2,1024
     a4a:	85ca                	mv	a1,s2
     a4c:	854e                	mv	a0,s3
     a4e:	00005097          	auipc	ra,0x5
     a52:	c2a080e7          	jalr	-982(ra) # 5678 <read>
    if(i == 0){
     a56:	c535                	beqz	a0,ac2 <writebig+0x106>
    } else if(i != BSIZE){
     a58:	40000793          	li	a5,1024
     a5c:	0af51f63          	bne	a0,a5,b1a <writebig+0x15e>
    if(((int*)buf)[0] != n){
     a60:	00092683          	lw	a3,0(s2)
     a64:	0c969a63          	bne	a3,s1,b38 <writebig+0x17c>
    n++;
     a68:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a6a:	bff1                	j	a46 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     a6c:	85d6                	mv	a1,s5
     a6e:	00006517          	auipc	a0,0x6
     a72:	8fa50513          	addi	a0,a0,-1798 # 6368 <malloc+0x8d0>
     a76:	00005097          	auipc	ra,0x5
     a7a:	f62080e7          	jalr	-158(ra) # 59d8 <printf>
    exit(1);
     a7e:	4505                	li	a0,1
     a80:	00005097          	auipc	ra,0x5
     a84:	be0080e7          	jalr	-1056(ra) # 5660 <exit>
      printf("%s: error: write big file failed\n", s, i);
     a88:	8626                	mv	a2,s1
     a8a:	85d6                	mv	a1,s5
     a8c:	00006517          	auipc	a0,0x6
     a90:	8fc50513          	addi	a0,a0,-1796 # 6388 <malloc+0x8f0>
     a94:	00005097          	auipc	ra,0x5
     a98:	f44080e7          	jalr	-188(ra) # 59d8 <printf>
      exit(1);
     a9c:	4505                	li	a0,1
     a9e:	00005097          	auipc	ra,0x5
     aa2:	bc2080e7          	jalr	-1086(ra) # 5660 <exit>
    printf("%s: error: open big failed!\n", s);
     aa6:	85d6                	mv	a1,s5
     aa8:	00006517          	auipc	a0,0x6
     aac:	90850513          	addi	a0,a0,-1784 # 63b0 <malloc+0x918>
     ab0:	00005097          	auipc	ra,0x5
     ab4:	f28080e7          	jalr	-216(ra) # 59d8 <printf>
    exit(1);
     ab8:	4505                	li	a0,1
     aba:	00005097          	auipc	ra,0x5
     abe:	ba6080e7          	jalr	-1114(ra) # 5660 <exit>
      if(n == MAXFILE - 1){
     ac2:	10b00793          	li	a5,267
     ac6:	02f48a63          	beq	s1,a5,afa <writebig+0x13e>
  close(fd);
     aca:	854e                	mv	a0,s3
     acc:	00005097          	auipc	ra,0x5
     ad0:	bbc080e7          	jalr	-1092(ra) # 5688 <close>
  if(unlink("big") < 0){
     ad4:	00006517          	auipc	a0,0x6
     ad8:	88c50513          	addi	a0,a0,-1908 # 6360 <malloc+0x8c8>
     adc:	00005097          	auipc	ra,0x5
     ae0:	bd4080e7          	jalr	-1068(ra) # 56b0 <unlink>
     ae4:	06054963          	bltz	a0,b56 <writebig+0x19a>
}
     ae8:	70e2                	ld	ra,56(sp)
     aea:	7442                	ld	s0,48(sp)
     aec:	74a2                	ld	s1,40(sp)
     aee:	7902                	ld	s2,32(sp)
     af0:	69e2                	ld	s3,24(sp)
     af2:	6a42                	ld	s4,16(sp)
     af4:	6aa2                	ld	s5,8(sp)
     af6:	6121                	addi	sp,sp,64
     af8:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     afa:	10b00613          	li	a2,267
     afe:	85d6                	mv	a1,s5
     b00:	00006517          	auipc	a0,0x6
     b04:	8d050513          	addi	a0,a0,-1840 # 63d0 <malloc+0x938>
     b08:	00005097          	auipc	ra,0x5
     b0c:	ed0080e7          	jalr	-304(ra) # 59d8 <printf>
        exit(1);
     b10:	4505                	li	a0,1
     b12:	00005097          	auipc	ra,0x5
     b16:	b4e080e7          	jalr	-1202(ra) # 5660 <exit>
      printf("%s: read failed %d\n", s, i);
     b1a:	862a                	mv	a2,a0
     b1c:	85d6                	mv	a1,s5
     b1e:	00006517          	auipc	a0,0x6
     b22:	8da50513          	addi	a0,a0,-1830 # 63f8 <malloc+0x960>
     b26:	00005097          	auipc	ra,0x5
     b2a:	eb2080e7          	jalr	-334(ra) # 59d8 <printf>
      exit(1);
     b2e:	4505                	li	a0,1
     b30:	00005097          	auipc	ra,0x5
     b34:	b30080e7          	jalr	-1232(ra) # 5660 <exit>
      printf("%s: read content of block %d is %d\n", s,
     b38:	8626                	mv	a2,s1
     b3a:	85d6                	mv	a1,s5
     b3c:	00006517          	auipc	a0,0x6
     b40:	8d450513          	addi	a0,a0,-1836 # 6410 <malloc+0x978>
     b44:	00005097          	auipc	ra,0x5
     b48:	e94080e7          	jalr	-364(ra) # 59d8 <printf>
      exit(1);
     b4c:	4505                	li	a0,1
     b4e:	00005097          	auipc	ra,0x5
     b52:	b12080e7          	jalr	-1262(ra) # 5660 <exit>
    printf("%s: unlink big failed\n", s);
     b56:	85d6                	mv	a1,s5
     b58:	00006517          	auipc	a0,0x6
     b5c:	8e050513          	addi	a0,a0,-1824 # 6438 <malloc+0x9a0>
     b60:	00005097          	auipc	ra,0x5
     b64:	e78080e7          	jalr	-392(ra) # 59d8 <printf>
    exit(1);
     b68:	4505                	li	a0,1
     b6a:	00005097          	auipc	ra,0x5
     b6e:	af6080e7          	jalr	-1290(ra) # 5660 <exit>

0000000000000b72 <unlinkread>:
{
     b72:	7179                	addi	sp,sp,-48
     b74:	f406                	sd	ra,40(sp)
     b76:	f022                	sd	s0,32(sp)
     b78:	ec26                	sd	s1,24(sp)
     b7a:	e84a                	sd	s2,16(sp)
     b7c:	e44e                	sd	s3,8(sp)
     b7e:	1800                	addi	s0,sp,48
     b80:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b82:	20200593          	li	a1,514
     b86:	00006517          	auipc	a0,0x6
     b8a:	8ca50513          	addi	a0,a0,-1846 # 6450 <malloc+0x9b8>
     b8e:	00005097          	auipc	ra,0x5
     b92:	b12080e7          	jalr	-1262(ra) # 56a0 <open>
  if(fd < 0){
     b96:	0e054563          	bltz	a0,c80 <unlinkread+0x10e>
     b9a:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b9c:	4615                	li	a2,5
     b9e:	00006597          	auipc	a1,0x6
     ba2:	8e258593          	addi	a1,a1,-1822 # 6480 <malloc+0x9e8>
     ba6:	00005097          	auipc	ra,0x5
     baa:	ada080e7          	jalr	-1318(ra) # 5680 <write>
  close(fd);
     bae:	8526                	mv	a0,s1
     bb0:	00005097          	auipc	ra,0x5
     bb4:	ad8080e7          	jalr	-1320(ra) # 5688 <close>
  fd = open("unlinkread", O_RDWR);
     bb8:	4589                	li	a1,2
     bba:	00006517          	auipc	a0,0x6
     bbe:	89650513          	addi	a0,a0,-1898 # 6450 <malloc+0x9b8>
     bc2:	00005097          	auipc	ra,0x5
     bc6:	ade080e7          	jalr	-1314(ra) # 56a0 <open>
     bca:	84aa                	mv	s1,a0
  if(fd < 0){
     bcc:	0c054863          	bltz	a0,c9c <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     bd0:	00006517          	auipc	a0,0x6
     bd4:	88050513          	addi	a0,a0,-1920 # 6450 <malloc+0x9b8>
     bd8:	00005097          	auipc	ra,0x5
     bdc:	ad8080e7          	jalr	-1320(ra) # 56b0 <unlink>
     be0:	ed61                	bnez	a0,cb8 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     be2:	20200593          	li	a1,514
     be6:	00006517          	auipc	a0,0x6
     bea:	86a50513          	addi	a0,a0,-1942 # 6450 <malloc+0x9b8>
     bee:	00005097          	auipc	ra,0x5
     bf2:	ab2080e7          	jalr	-1358(ra) # 56a0 <open>
     bf6:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     bf8:	460d                	li	a2,3
     bfa:	00006597          	auipc	a1,0x6
     bfe:	8ce58593          	addi	a1,a1,-1842 # 64c8 <malloc+0xa30>
     c02:	00005097          	auipc	ra,0x5
     c06:	a7e080e7          	jalr	-1410(ra) # 5680 <write>
  close(fd1);
     c0a:	854a                	mv	a0,s2
     c0c:	00005097          	auipc	ra,0x5
     c10:	a7c080e7          	jalr	-1412(ra) # 5688 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c14:	660d                	lui	a2,0x3
     c16:	0000b597          	auipc	a1,0xb
     c1a:	eda58593          	addi	a1,a1,-294 # baf0 <buf>
     c1e:	8526                	mv	a0,s1
     c20:	00005097          	auipc	ra,0x5
     c24:	a58080e7          	jalr	-1448(ra) # 5678 <read>
     c28:	4795                	li	a5,5
     c2a:	0af51563          	bne	a0,a5,cd4 <unlinkread+0x162>
  if(buf[0] != 'h'){
     c2e:	0000b717          	auipc	a4,0xb
     c32:	ec274703          	lbu	a4,-318(a4) # baf0 <buf>
     c36:	06800793          	li	a5,104
     c3a:	0af71b63          	bne	a4,a5,cf0 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c3e:	4629                	li	a2,10
     c40:	0000b597          	auipc	a1,0xb
     c44:	eb058593          	addi	a1,a1,-336 # baf0 <buf>
     c48:	8526                	mv	a0,s1
     c4a:	00005097          	auipc	ra,0x5
     c4e:	a36080e7          	jalr	-1482(ra) # 5680 <write>
     c52:	47a9                	li	a5,10
     c54:	0af51c63          	bne	a0,a5,d0c <unlinkread+0x19a>
  close(fd);
     c58:	8526                	mv	a0,s1
     c5a:	00005097          	auipc	ra,0x5
     c5e:	a2e080e7          	jalr	-1490(ra) # 5688 <close>
  unlink("unlinkread");
     c62:	00005517          	auipc	a0,0x5
     c66:	7ee50513          	addi	a0,a0,2030 # 6450 <malloc+0x9b8>
     c6a:	00005097          	auipc	ra,0x5
     c6e:	a46080e7          	jalr	-1466(ra) # 56b0 <unlink>
}
     c72:	70a2                	ld	ra,40(sp)
     c74:	7402                	ld	s0,32(sp)
     c76:	64e2                	ld	s1,24(sp)
     c78:	6942                	ld	s2,16(sp)
     c7a:	69a2                	ld	s3,8(sp)
     c7c:	6145                	addi	sp,sp,48
     c7e:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c80:	85ce                	mv	a1,s3
     c82:	00005517          	auipc	a0,0x5
     c86:	7de50513          	addi	a0,a0,2014 # 6460 <malloc+0x9c8>
     c8a:	00005097          	auipc	ra,0x5
     c8e:	d4e080e7          	jalr	-690(ra) # 59d8 <printf>
    exit(1);
     c92:	4505                	li	a0,1
     c94:	00005097          	auipc	ra,0x5
     c98:	9cc080e7          	jalr	-1588(ra) # 5660 <exit>
    printf("%s: open unlinkread failed\n", s);
     c9c:	85ce                	mv	a1,s3
     c9e:	00005517          	auipc	a0,0x5
     ca2:	7ea50513          	addi	a0,a0,2026 # 6488 <malloc+0x9f0>
     ca6:	00005097          	auipc	ra,0x5
     caa:	d32080e7          	jalr	-718(ra) # 59d8 <printf>
    exit(1);
     cae:	4505                	li	a0,1
     cb0:	00005097          	auipc	ra,0x5
     cb4:	9b0080e7          	jalr	-1616(ra) # 5660 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     cb8:	85ce                	mv	a1,s3
     cba:	00005517          	auipc	a0,0x5
     cbe:	7ee50513          	addi	a0,a0,2030 # 64a8 <malloc+0xa10>
     cc2:	00005097          	auipc	ra,0x5
     cc6:	d16080e7          	jalr	-746(ra) # 59d8 <printf>
    exit(1);
     cca:	4505                	li	a0,1
     ccc:	00005097          	auipc	ra,0x5
     cd0:	994080e7          	jalr	-1644(ra) # 5660 <exit>
    printf("%s: unlinkread read failed", s);
     cd4:	85ce                	mv	a1,s3
     cd6:	00005517          	auipc	a0,0x5
     cda:	7fa50513          	addi	a0,a0,2042 # 64d0 <malloc+0xa38>
     cde:	00005097          	auipc	ra,0x5
     ce2:	cfa080e7          	jalr	-774(ra) # 59d8 <printf>
    exit(1);
     ce6:	4505                	li	a0,1
     ce8:	00005097          	auipc	ra,0x5
     cec:	978080e7          	jalr	-1672(ra) # 5660 <exit>
    printf("%s: unlinkread wrong data\n", s);
     cf0:	85ce                	mv	a1,s3
     cf2:	00005517          	auipc	a0,0x5
     cf6:	7fe50513          	addi	a0,a0,2046 # 64f0 <malloc+0xa58>
     cfa:	00005097          	auipc	ra,0x5
     cfe:	cde080e7          	jalr	-802(ra) # 59d8 <printf>
    exit(1);
     d02:	4505                	li	a0,1
     d04:	00005097          	auipc	ra,0x5
     d08:	95c080e7          	jalr	-1700(ra) # 5660 <exit>
    printf("%s: unlinkread write failed\n", s);
     d0c:	85ce                	mv	a1,s3
     d0e:	00006517          	auipc	a0,0x6
     d12:	80250513          	addi	a0,a0,-2046 # 6510 <malloc+0xa78>
     d16:	00005097          	auipc	ra,0x5
     d1a:	cc2080e7          	jalr	-830(ra) # 59d8 <printf>
    exit(1);
     d1e:	4505                	li	a0,1
     d20:	00005097          	auipc	ra,0x5
     d24:	940080e7          	jalr	-1728(ra) # 5660 <exit>

0000000000000d28 <linktest>:
{
     d28:	1101                	addi	sp,sp,-32
     d2a:	ec06                	sd	ra,24(sp)
     d2c:	e822                	sd	s0,16(sp)
     d2e:	e426                	sd	s1,8(sp)
     d30:	e04a                	sd	s2,0(sp)
     d32:	1000                	addi	s0,sp,32
     d34:	892a                	mv	s2,a0
  unlink("lf1");
     d36:	00005517          	auipc	a0,0x5
     d3a:	7fa50513          	addi	a0,a0,2042 # 6530 <malloc+0xa98>
     d3e:	00005097          	auipc	ra,0x5
     d42:	972080e7          	jalr	-1678(ra) # 56b0 <unlink>
  unlink("lf2");
     d46:	00005517          	auipc	a0,0x5
     d4a:	7f250513          	addi	a0,a0,2034 # 6538 <malloc+0xaa0>
     d4e:	00005097          	auipc	ra,0x5
     d52:	962080e7          	jalr	-1694(ra) # 56b0 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d56:	20200593          	li	a1,514
     d5a:	00005517          	auipc	a0,0x5
     d5e:	7d650513          	addi	a0,a0,2006 # 6530 <malloc+0xa98>
     d62:	00005097          	auipc	ra,0x5
     d66:	93e080e7          	jalr	-1730(ra) # 56a0 <open>
  if(fd < 0){
     d6a:	10054763          	bltz	a0,e78 <linktest+0x150>
     d6e:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d70:	4615                	li	a2,5
     d72:	00005597          	auipc	a1,0x5
     d76:	70e58593          	addi	a1,a1,1806 # 6480 <malloc+0x9e8>
     d7a:	00005097          	auipc	ra,0x5
     d7e:	906080e7          	jalr	-1786(ra) # 5680 <write>
     d82:	4795                	li	a5,5
     d84:	10f51863          	bne	a0,a5,e94 <linktest+0x16c>
  close(fd);
     d88:	8526                	mv	a0,s1
     d8a:	00005097          	auipc	ra,0x5
     d8e:	8fe080e7          	jalr	-1794(ra) # 5688 <close>
  if(link("lf1", "lf2") < 0){
     d92:	00005597          	auipc	a1,0x5
     d96:	7a658593          	addi	a1,a1,1958 # 6538 <malloc+0xaa0>
     d9a:	00005517          	auipc	a0,0x5
     d9e:	79650513          	addi	a0,a0,1942 # 6530 <malloc+0xa98>
     da2:	00005097          	auipc	ra,0x5
     da6:	91e080e7          	jalr	-1762(ra) # 56c0 <link>
     daa:	10054363          	bltz	a0,eb0 <linktest+0x188>
  unlink("lf1");
     dae:	00005517          	auipc	a0,0x5
     db2:	78250513          	addi	a0,a0,1922 # 6530 <malloc+0xa98>
     db6:	00005097          	auipc	ra,0x5
     dba:	8fa080e7          	jalr	-1798(ra) # 56b0 <unlink>
  if(open("lf1", 0) >= 0){
     dbe:	4581                	li	a1,0
     dc0:	00005517          	auipc	a0,0x5
     dc4:	77050513          	addi	a0,a0,1904 # 6530 <malloc+0xa98>
     dc8:	00005097          	auipc	ra,0x5
     dcc:	8d8080e7          	jalr	-1832(ra) # 56a0 <open>
     dd0:	0e055e63          	bgez	a0,ecc <linktest+0x1a4>
  fd = open("lf2", 0);
     dd4:	4581                	li	a1,0
     dd6:	00005517          	auipc	a0,0x5
     dda:	76250513          	addi	a0,a0,1890 # 6538 <malloc+0xaa0>
     dde:	00005097          	auipc	ra,0x5
     de2:	8c2080e7          	jalr	-1854(ra) # 56a0 <open>
     de6:	84aa                	mv	s1,a0
  if(fd < 0){
     de8:	10054063          	bltz	a0,ee8 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     dec:	660d                	lui	a2,0x3
     dee:	0000b597          	auipc	a1,0xb
     df2:	d0258593          	addi	a1,a1,-766 # baf0 <buf>
     df6:	00005097          	auipc	ra,0x5
     dfa:	882080e7          	jalr	-1918(ra) # 5678 <read>
     dfe:	4795                	li	a5,5
     e00:	10f51263          	bne	a0,a5,f04 <linktest+0x1dc>
  close(fd);
     e04:	8526                	mv	a0,s1
     e06:	00005097          	auipc	ra,0x5
     e0a:	882080e7          	jalr	-1918(ra) # 5688 <close>
  if(link("lf2", "lf2") >= 0){
     e0e:	00005597          	auipc	a1,0x5
     e12:	72a58593          	addi	a1,a1,1834 # 6538 <malloc+0xaa0>
     e16:	852e                	mv	a0,a1
     e18:	00005097          	auipc	ra,0x5
     e1c:	8a8080e7          	jalr	-1880(ra) # 56c0 <link>
     e20:	10055063          	bgez	a0,f20 <linktest+0x1f8>
  unlink("lf2");
     e24:	00005517          	auipc	a0,0x5
     e28:	71450513          	addi	a0,a0,1812 # 6538 <malloc+0xaa0>
     e2c:	00005097          	auipc	ra,0x5
     e30:	884080e7          	jalr	-1916(ra) # 56b0 <unlink>
  if(link("lf2", "lf1") >= 0){
     e34:	00005597          	auipc	a1,0x5
     e38:	6fc58593          	addi	a1,a1,1788 # 6530 <malloc+0xa98>
     e3c:	00005517          	auipc	a0,0x5
     e40:	6fc50513          	addi	a0,a0,1788 # 6538 <malloc+0xaa0>
     e44:	00005097          	auipc	ra,0x5
     e48:	87c080e7          	jalr	-1924(ra) # 56c0 <link>
     e4c:	0e055863          	bgez	a0,f3c <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e50:	00005597          	auipc	a1,0x5
     e54:	6e058593          	addi	a1,a1,1760 # 6530 <malloc+0xa98>
     e58:	00005517          	auipc	a0,0x5
     e5c:	7e850513          	addi	a0,a0,2024 # 6640 <malloc+0xba8>
     e60:	00005097          	auipc	ra,0x5
     e64:	860080e7          	jalr	-1952(ra) # 56c0 <link>
     e68:	0e055863          	bgez	a0,f58 <linktest+0x230>
}
     e6c:	60e2                	ld	ra,24(sp)
     e6e:	6442                	ld	s0,16(sp)
     e70:	64a2                	ld	s1,8(sp)
     e72:	6902                	ld	s2,0(sp)
     e74:	6105                	addi	sp,sp,32
     e76:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e78:	85ca                	mv	a1,s2
     e7a:	00005517          	auipc	a0,0x5
     e7e:	6c650513          	addi	a0,a0,1734 # 6540 <malloc+0xaa8>
     e82:	00005097          	auipc	ra,0x5
     e86:	b56080e7          	jalr	-1194(ra) # 59d8 <printf>
    exit(1);
     e8a:	4505                	li	a0,1
     e8c:	00004097          	auipc	ra,0x4
     e90:	7d4080e7          	jalr	2004(ra) # 5660 <exit>
    printf("%s: write lf1 failed\n", s);
     e94:	85ca                	mv	a1,s2
     e96:	00005517          	auipc	a0,0x5
     e9a:	6c250513          	addi	a0,a0,1730 # 6558 <malloc+0xac0>
     e9e:	00005097          	auipc	ra,0x5
     ea2:	b3a080e7          	jalr	-1222(ra) # 59d8 <printf>
    exit(1);
     ea6:	4505                	li	a0,1
     ea8:	00004097          	auipc	ra,0x4
     eac:	7b8080e7          	jalr	1976(ra) # 5660 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     eb0:	85ca                	mv	a1,s2
     eb2:	00005517          	auipc	a0,0x5
     eb6:	6be50513          	addi	a0,a0,1726 # 6570 <malloc+0xad8>
     eba:	00005097          	auipc	ra,0x5
     ebe:	b1e080e7          	jalr	-1250(ra) # 59d8 <printf>
    exit(1);
     ec2:	4505                	li	a0,1
     ec4:	00004097          	auipc	ra,0x4
     ec8:	79c080e7          	jalr	1948(ra) # 5660 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     ecc:	85ca                	mv	a1,s2
     ece:	00005517          	auipc	a0,0x5
     ed2:	6c250513          	addi	a0,a0,1730 # 6590 <malloc+0xaf8>
     ed6:	00005097          	auipc	ra,0x5
     eda:	b02080e7          	jalr	-1278(ra) # 59d8 <printf>
    exit(1);
     ede:	4505                	li	a0,1
     ee0:	00004097          	auipc	ra,0x4
     ee4:	780080e7          	jalr	1920(ra) # 5660 <exit>
    printf("%s: open lf2 failed\n", s);
     ee8:	85ca                	mv	a1,s2
     eea:	00005517          	auipc	a0,0x5
     eee:	6d650513          	addi	a0,a0,1750 # 65c0 <malloc+0xb28>
     ef2:	00005097          	auipc	ra,0x5
     ef6:	ae6080e7          	jalr	-1306(ra) # 59d8 <printf>
    exit(1);
     efa:	4505                	li	a0,1
     efc:	00004097          	auipc	ra,0x4
     f00:	764080e7          	jalr	1892(ra) # 5660 <exit>
    printf("%s: read lf2 failed\n", s);
     f04:	85ca                	mv	a1,s2
     f06:	00005517          	auipc	a0,0x5
     f0a:	6d250513          	addi	a0,a0,1746 # 65d8 <malloc+0xb40>
     f0e:	00005097          	auipc	ra,0x5
     f12:	aca080e7          	jalr	-1334(ra) # 59d8 <printf>
    exit(1);
     f16:	4505                	li	a0,1
     f18:	00004097          	auipc	ra,0x4
     f1c:	748080e7          	jalr	1864(ra) # 5660 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f20:	85ca                	mv	a1,s2
     f22:	00005517          	auipc	a0,0x5
     f26:	6ce50513          	addi	a0,a0,1742 # 65f0 <malloc+0xb58>
     f2a:	00005097          	auipc	ra,0x5
     f2e:	aae080e7          	jalr	-1362(ra) # 59d8 <printf>
    exit(1);
     f32:	4505                	li	a0,1
     f34:	00004097          	auipc	ra,0x4
     f38:	72c080e7          	jalr	1836(ra) # 5660 <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
     f3c:	85ca                	mv	a1,s2
     f3e:	00005517          	auipc	a0,0x5
     f42:	6da50513          	addi	a0,a0,1754 # 6618 <malloc+0xb80>
     f46:	00005097          	auipc	ra,0x5
     f4a:	a92080e7          	jalr	-1390(ra) # 59d8 <printf>
    exit(1);
     f4e:	4505                	li	a0,1
     f50:	00004097          	auipc	ra,0x4
     f54:	710080e7          	jalr	1808(ra) # 5660 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f58:	85ca                	mv	a1,s2
     f5a:	00005517          	auipc	a0,0x5
     f5e:	6ee50513          	addi	a0,a0,1774 # 6648 <malloc+0xbb0>
     f62:	00005097          	auipc	ra,0x5
     f66:	a76080e7          	jalr	-1418(ra) # 59d8 <printf>
    exit(1);
     f6a:	4505                	li	a0,1
     f6c:	00004097          	auipc	ra,0x4
     f70:	6f4080e7          	jalr	1780(ra) # 5660 <exit>

0000000000000f74 <bigdir>:
{
     f74:	715d                	addi	sp,sp,-80
     f76:	e486                	sd	ra,72(sp)
     f78:	e0a2                	sd	s0,64(sp)
     f7a:	fc26                	sd	s1,56(sp)
     f7c:	f84a                	sd	s2,48(sp)
     f7e:	f44e                	sd	s3,40(sp)
     f80:	f052                	sd	s4,32(sp)
     f82:	ec56                	sd	s5,24(sp)
     f84:	e85a                	sd	s6,16(sp)
     f86:	0880                	addi	s0,sp,80
     f88:	89aa                	mv	s3,a0
  unlink("bd");
     f8a:	00005517          	auipc	a0,0x5
     f8e:	6de50513          	addi	a0,a0,1758 # 6668 <malloc+0xbd0>
     f92:	00004097          	auipc	ra,0x4
     f96:	71e080e7          	jalr	1822(ra) # 56b0 <unlink>
  fd = open("bd", O_CREATE);
     f9a:	20000593          	li	a1,512
     f9e:	00005517          	auipc	a0,0x5
     fa2:	6ca50513          	addi	a0,a0,1738 # 6668 <malloc+0xbd0>
     fa6:	00004097          	auipc	ra,0x4
     faa:	6fa080e7          	jalr	1786(ra) # 56a0 <open>
  if(fd < 0){
     fae:	0c054963          	bltz	a0,1080 <bigdir+0x10c>
  close(fd);
     fb2:	00004097          	auipc	ra,0x4
     fb6:	6d6080e7          	jalr	1750(ra) # 5688 <close>
  for(i = 0; i < N; i++){
     fba:	4901                	li	s2,0
    name[0] = 'x';
     fbc:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     fc0:	00005a17          	auipc	s4,0x5
     fc4:	6a8a0a13          	addi	s4,s4,1704 # 6668 <malloc+0xbd0>
  for(i = 0; i < N; i++){
     fc8:	1f400b13          	li	s6,500
    name[0] = 'x';
     fcc:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     fd0:	41f9579b          	sraiw	a5,s2,0x1f
     fd4:	01a7d71b          	srliw	a4,a5,0x1a
     fd8:	012707bb          	addw	a5,a4,s2
     fdc:	4067d69b          	sraiw	a3,a5,0x6
     fe0:	0306869b          	addiw	a3,a3,48
     fe4:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     fe8:	03f7f793          	andi	a5,a5,63
     fec:	9f99                	subw	a5,a5,a4
     fee:	0307879b          	addiw	a5,a5,48
     ff2:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     ff6:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     ffa:	fb040593          	addi	a1,s0,-80
     ffe:	8552                	mv	a0,s4
    1000:	00004097          	auipc	ra,0x4
    1004:	6c0080e7          	jalr	1728(ra) # 56c0 <link>
    1008:	84aa                	mv	s1,a0
    100a:	e949                	bnez	a0,109c <bigdir+0x128>
  for(i = 0; i < N; i++){
    100c:	2905                	addiw	s2,s2,1
    100e:	fb691fe3          	bne	s2,s6,fcc <bigdir+0x58>
  unlink("bd");
    1012:	00005517          	auipc	a0,0x5
    1016:	65650513          	addi	a0,a0,1622 # 6668 <malloc+0xbd0>
    101a:	00004097          	auipc	ra,0x4
    101e:	696080e7          	jalr	1686(ra) # 56b0 <unlink>
    name[0] = 'x';
    1022:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1026:	1f400a13          	li	s4,500
    name[0] = 'x';
    102a:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    102e:	41f4d79b          	sraiw	a5,s1,0x1f
    1032:	01a7d71b          	srliw	a4,a5,0x1a
    1036:	009707bb          	addw	a5,a4,s1
    103a:	4067d69b          	sraiw	a3,a5,0x6
    103e:	0306869b          	addiw	a3,a3,48
    1042:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1046:	03f7f793          	andi	a5,a5,63
    104a:	9f99                	subw	a5,a5,a4
    104c:	0307879b          	addiw	a5,a5,48
    1050:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1054:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    1058:	fb040513          	addi	a0,s0,-80
    105c:	00004097          	auipc	ra,0x4
    1060:	654080e7          	jalr	1620(ra) # 56b0 <unlink>
    1064:	ed21                	bnez	a0,10bc <bigdir+0x148>
  for(i = 0; i < N; i++){
    1066:	2485                	addiw	s1,s1,1
    1068:	fd4491e3          	bne	s1,s4,102a <bigdir+0xb6>
}
    106c:	60a6                	ld	ra,72(sp)
    106e:	6406                	ld	s0,64(sp)
    1070:	74e2                	ld	s1,56(sp)
    1072:	7942                	ld	s2,48(sp)
    1074:	79a2                	ld	s3,40(sp)
    1076:	7a02                	ld	s4,32(sp)
    1078:	6ae2                	ld	s5,24(sp)
    107a:	6b42                	ld	s6,16(sp)
    107c:	6161                	addi	sp,sp,80
    107e:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    1080:	85ce                	mv	a1,s3
    1082:	00005517          	auipc	a0,0x5
    1086:	5ee50513          	addi	a0,a0,1518 # 6670 <malloc+0xbd8>
    108a:	00005097          	auipc	ra,0x5
    108e:	94e080e7          	jalr	-1714(ra) # 59d8 <printf>
    exit(1);
    1092:	4505                	li	a0,1
    1094:	00004097          	auipc	ra,0x4
    1098:	5cc080e7          	jalr	1484(ra) # 5660 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    109c:	fb040613          	addi	a2,s0,-80
    10a0:	85ce                	mv	a1,s3
    10a2:	00005517          	auipc	a0,0x5
    10a6:	5ee50513          	addi	a0,a0,1518 # 6690 <malloc+0xbf8>
    10aa:	00005097          	auipc	ra,0x5
    10ae:	92e080e7          	jalr	-1746(ra) # 59d8 <printf>
      exit(1);
    10b2:	4505                	li	a0,1
    10b4:	00004097          	auipc	ra,0x4
    10b8:	5ac080e7          	jalr	1452(ra) # 5660 <exit>
      printf("%s: bigdir unlink failed", s);
    10bc:	85ce                	mv	a1,s3
    10be:	00005517          	auipc	a0,0x5
    10c2:	5f250513          	addi	a0,a0,1522 # 66b0 <malloc+0xc18>
    10c6:	00005097          	auipc	ra,0x5
    10ca:	912080e7          	jalr	-1774(ra) # 59d8 <printf>
      exit(1);
    10ce:	4505                	li	a0,1
    10d0:	00004097          	auipc	ra,0x4
    10d4:	590080e7          	jalr	1424(ra) # 5660 <exit>

00000000000010d8 <validatetest>:
{
    10d8:	7139                	addi	sp,sp,-64
    10da:	fc06                	sd	ra,56(sp)
    10dc:	f822                	sd	s0,48(sp)
    10de:	f426                	sd	s1,40(sp)
    10e0:	f04a                	sd	s2,32(sp)
    10e2:	ec4e                	sd	s3,24(sp)
    10e4:	e852                	sd	s4,16(sp)
    10e6:	e456                	sd	s5,8(sp)
    10e8:	e05a                	sd	s6,0(sp)
    10ea:	0080                	addi	s0,sp,64
    10ec:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10ee:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    10f0:	00005997          	auipc	s3,0x5
    10f4:	5e098993          	addi	s3,s3,1504 # 66d0 <malloc+0xc38>
    10f8:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10fa:	6a85                	lui	s5,0x1
    10fc:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    1100:	85a6                	mv	a1,s1
    1102:	854e                	mv	a0,s3
    1104:	00004097          	auipc	ra,0x4
    1108:	5bc080e7          	jalr	1468(ra) # 56c0 <link>
    110c:	01251f63          	bne	a0,s2,112a <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1110:	94d6                	add	s1,s1,s5
    1112:	ff4497e3          	bne	s1,s4,1100 <validatetest+0x28>
}
    1116:	70e2                	ld	ra,56(sp)
    1118:	7442                	ld	s0,48(sp)
    111a:	74a2                	ld	s1,40(sp)
    111c:	7902                	ld	s2,32(sp)
    111e:	69e2                	ld	s3,24(sp)
    1120:	6a42                	ld	s4,16(sp)
    1122:	6aa2                	ld	s5,8(sp)
    1124:	6b02                	ld	s6,0(sp)
    1126:	6121                	addi	sp,sp,64
    1128:	8082                	ret
      printf("%s: link should not succeed\n", s);
    112a:	85da                	mv	a1,s6
    112c:	00005517          	auipc	a0,0x5
    1130:	5b450513          	addi	a0,a0,1460 # 66e0 <malloc+0xc48>
    1134:	00005097          	auipc	ra,0x5
    1138:	8a4080e7          	jalr	-1884(ra) # 59d8 <printf>
      exit(1);
    113c:	4505                	li	a0,1
    113e:	00004097          	auipc	ra,0x4
    1142:	522080e7          	jalr	1314(ra) # 5660 <exit>

0000000000001146 <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    1146:	7179                	addi	sp,sp,-48
    1148:	f406                	sd	ra,40(sp)
    114a:	f022                	sd	s0,32(sp)
    114c:	ec26                	sd	s1,24(sp)
    114e:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    1150:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1154:	00007797          	auipc	a5,0x7
    1158:	16c78793          	addi	a5,a5,364 # 82c0 <digits+0x20>
    115c:	6384                	ld	s1,0(a5)
    115e:	fd840593          	addi	a1,s0,-40
    1162:	8526                	mv	a0,s1
    1164:	00004097          	auipc	ra,0x4
    1168:	534080e7          	jalr	1332(ra) # 5698 <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    116c:	8526                	mv	a0,s1
    116e:	00004097          	auipc	ra,0x4
    1172:	502080e7          	jalr	1282(ra) # 5670 <pipe>

  exit(0);
    1176:	4501                	li	a0,0
    1178:	00004097          	auipc	ra,0x4
    117c:	4e8080e7          	jalr	1256(ra) # 5660 <exit>

0000000000001180 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1180:	7139                	addi	sp,sp,-64
    1182:	fc06                	sd	ra,56(sp)
    1184:	f822                	sd	s0,48(sp)
    1186:	f426                	sd	s1,40(sp)
    1188:	f04a                	sd	s2,32(sp)
    118a:	ec4e                	sd	s3,24(sp)
    118c:	0080                	addi	s0,sp,64
    118e:	64b1                	lui	s1,0xc
    1190:	35048493          	addi	s1,s1,848 # c350 <buf+0x860>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1194:	597d                	li	s2,-1
    1196:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    119a:	00005997          	auipc	s3,0x5
    119e:	dee98993          	addi	s3,s3,-530 # 5f88 <malloc+0x4f0>
    argv[0] = (char*)0xffffffff;
    11a2:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    11a6:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    11aa:	fc040593          	addi	a1,s0,-64
    11ae:	854e                	mv	a0,s3
    11b0:	00004097          	auipc	ra,0x4
    11b4:	4e8080e7          	jalr	1256(ra) # 5698 <exec>
  for(int i = 0; i < 50000; i++){
    11b8:	34fd                	addiw	s1,s1,-1
    11ba:	f4e5                	bnez	s1,11a2 <badarg+0x22>
  }
  
  exit(0);
    11bc:	4501                	li	a0,0
    11be:	00004097          	auipc	ra,0x4
    11c2:	4a2080e7          	jalr	1186(ra) # 5660 <exit>

00000000000011c6 <copyinstr2>:
{
    11c6:	7155                	addi	sp,sp,-208
    11c8:	e586                	sd	ra,200(sp)
    11ca:	e1a2                	sd	s0,192(sp)
    11cc:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    11ce:	f6840793          	addi	a5,s0,-152
    11d2:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    11d6:	07800713          	li	a4,120
    11da:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    11de:	0785                	addi	a5,a5,1
    11e0:	fed79de3          	bne	a5,a3,11da <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    11e4:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    11e8:	f6840513          	addi	a0,s0,-152
    11ec:	00004097          	auipc	ra,0x4
    11f0:	4c4080e7          	jalr	1220(ra) # 56b0 <unlink>
  if(ret != -1){
    11f4:	57fd                	li	a5,-1
    11f6:	0ef51063          	bne	a0,a5,12d6 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    11fa:	20100593          	li	a1,513
    11fe:	f6840513          	addi	a0,s0,-152
    1202:	00004097          	auipc	ra,0x4
    1206:	49e080e7          	jalr	1182(ra) # 56a0 <open>
  if(fd != -1){
    120a:	57fd                	li	a5,-1
    120c:	0ef51563          	bne	a0,a5,12f6 <copyinstr2+0x130>
  ret = link(b, b);
    1210:	f6840593          	addi	a1,s0,-152
    1214:	852e                	mv	a0,a1
    1216:	00004097          	auipc	ra,0x4
    121a:	4aa080e7          	jalr	1194(ra) # 56c0 <link>
  if(ret != -1){
    121e:	57fd                	li	a5,-1
    1220:	0ef51b63          	bne	a0,a5,1316 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1224:	00006797          	auipc	a5,0x6
    1228:	69c78793          	addi	a5,a5,1692 # 78c0 <malloc+0x1e28>
    122c:	f4f43c23          	sd	a5,-168(s0)
    1230:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1234:	f5840593          	addi	a1,s0,-168
    1238:	f6840513          	addi	a0,s0,-152
    123c:	00004097          	auipc	ra,0x4
    1240:	45c080e7          	jalr	1116(ra) # 5698 <exec>
  if(ret != -1){
    1244:	57fd                	li	a5,-1
    1246:	0ef51963          	bne	a0,a5,1338 <copyinstr2+0x172>
  int pid = fork();
    124a:	00004097          	auipc	ra,0x4
    124e:	40e080e7          	jalr	1038(ra) # 5658 <fork>
  if(pid < 0){
    1252:	10054363          	bltz	a0,1358 <copyinstr2+0x192>
  if(pid == 0){
    1256:	12051463          	bnez	a0,137e <copyinstr2+0x1b8>
    125a:	00007797          	auipc	a5,0x7
    125e:	17e78793          	addi	a5,a5,382 # 83d8 <big.1284>
    1262:	00008697          	auipc	a3,0x8
    1266:	17668693          	addi	a3,a3,374 # 93d8 <__global_pointer$+0x918>
      big[i] = 'x';
    126a:	07800713          	li	a4,120
    126e:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    1272:	0785                	addi	a5,a5,1
    1274:	fed79de3          	bne	a5,a3,126e <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1278:	00008797          	auipc	a5,0x8
    127c:	16078023          	sb	zero,352(a5) # 93d8 <__global_pointer$+0x918>
    char *args2[] = { big, big, big, 0 };
    1280:	00005797          	auipc	a5,0x5
    1284:	90078793          	addi	a5,a5,-1792 # 5b80 <malloc+0xe8>
    1288:	6390                	ld	a2,0(a5)
    128a:	6794                	ld	a3,8(a5)
    128c:	6b98                	ld	a4,16(a5)
    128e:	6f9c                	ld	a5,24(a5)
    1290:	f2c43823          	sd	a2,-208(s0)
    1294:	f2d43c23          	sd	a3,-200(s0)
    1298:	f4e43023          	sd	a4,-192(s0)
    129c:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    12a0:	f3040593          	addi	a1,s0,-208
    12a4:	00005517          	auipc	a0,0x5
    12a8:	ce450513          	addi	a0,a0,-796 # 5f88 <malloc+0x4f0>
    12ac:	00004097          	auipc	ra,0x4
    12b0:	3ec080e7          	jalr	1004(ra) # 5698 <exec>
    if(ret != -1){
    12b4:	57fd                	li	a5,-1
    12b6:	0af50e63          	beq	a0,a5,1372 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    12ba:	55fd                	li	a1,-1
    12bc:	00005517          	auipc	a0,0x5
    12c0:	4cc50513          	addi	a0,a0,1228 # 6788 <malloc+0xcf0>
    12c4:	00004097          	auipc	ra,0x4
    12c8:	714080e7          	jalr	1812(ra) # 59d8 <printf>
      exit(1);
    12cc:	4505                	li	a0,1
    12ce:	00004097          	auipc	ra,0x4
    12d2:	392080e7          	jalr	914(ra) # 5660 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    12d6:	862a                	mv	a2,a0
    12d8:	f6840593          	addi	a1,s0,-152
    12dc:	00005517          	auipc	a0,0x5
    12e0:	42450513          	addi	a0,a0,1060 # 6700 <malloc+0xc68>
    12e4:	00004097          	auipc	ra,0x4
    12e8:	6f4080e7          	jalr	1780(ra) # 59d8 <printf>
    exit(1);
    12ec:	4505                	li	a0,1
    12ee:	00004097          	auipc	ra,0x4
    12f2:	372080e7          	jalr	882(ra) # 5660 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    12f6:	862a                	mv	a2,a0
    12f8:	f6840593          	addi	a1,s0,-152
    12fc:	00005517          	auipc	a0,0x5
    1300:	42450513          	addi	a0,a0,1060 # 6720 <malloc+0xc88>
    1304:	00004097          	auipc	ra,0x4
    1308:	6d4080e7          	jalr	1748(ra) # 59d8 <printf>
    exit(1);
    130c:	4505                	li	a0,1
    130e:	00004097          	auipc	ra,0x4
    1312:	352080e7          	jalr	850(ra) # 5660 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1316:	86aa                	mv	a3,a0
    1318:	f6840613          	addi	a2,s0,-152
    131c:	85b2                	mv	a1,a2
    131e:	00005517          	auipc	a0,0x5
    1322:	42250513          	addi	a0,a0,1058 # 6740 <malloc+0xca8>
    1326:	00004097          	auipc	ra,0x4
    132a:	6b2080e7          	jalr	1714(ra) # 59d8 <printf>
    exit(1);
    132e:	4505                	li	a0,1
    1330:	00004097          	auipc	ra,0x4
    1334:	330080e7          	jalr	816(ra) # 5660 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1338:	567d                	li	a2,-1
    133a:	f6840593          	addi	a1,s0,-152
    133e:	00005517          	auipc	a0,0x5
    1342:	42a50513          	addi	a0,a0,1066 # 6768 <malloc+0xcd0>
    1346:	00004097          	auipc	ra,0x4
    134a:	692080e7          	jalr	1682(ra) # 59d8 <printf>
    exit(1);
    134e:	4505                	li	a0,1
    1350:	00004097          	auipc	ra,0x4
    1354:	310080e7          	jalr	784(ra) # 5660 <exit>
    printf("fork failed\n");
    1358:	00006517          	auipc	a0,0x6
    135c:	89050513          	addi	a0,a0,-1904 # 6be8 <malloc+0x1150>
    1360:	00004097          	auipc	ra,0x4
    1364:	678080e7          	jalr	1656(ra) # 59d8 <printf>
    exit(1);
    1368:	4505                	li	a0,1
    136a:	00004097          	auipc	ra,0x4
    136e:	2f6080e7          	jalr	758(ra) # 5660 <exit>
    exit(747); // OK
    1372:	2eb00513          	li	a0,747
    1376:	00004097          	auipc	ra,0x4
    137a:	2ea080e7          	jalr	746(ra) # 5660 <exit>
  int st = 0;
    137e:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1382:	f5440513          	addi	a0,s0,-172
    1386:	00004097          	auipc	ra,0x4
    138a:	2e2080e7          	jalr	738(ra) # 5668 <wait>
  if(st != 747){
    138e:	f5442703          	lw	a4,-172(s0)
    1392:	2eb00793          	li	a5,747
    1396:	00f71663          	bne	a4,a5,13a2 <copyinstr2+0x1dc>
}
    139a:	60ae                	ld	ra,200(sp)
    139c:	640e                	ld	s0,192(sp)
    139e:	6169                	addi	sp,sp,208
    13a0:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    13a2:	00005517          	auipc	a0,0x5
    13a6:	40e50513          	addi	a0,a0,1038 # 67b0 <malloc+0xd18>
    13aa:	00004097          	auipc	ra,0x4
    13ae:	62e080e7          	jalr	1582(ra) # 59d8 <printf>
    exit(1);
    13b2:	4505                	li	a0,1
    13b4:	00004097          	auipc	ra,0x4
    13b8:	2ac080e7          	jalr	684(ra) # 5660 <exit>

00000000000013bc <truncate3>:
{
    13bc:	7159                	addi	sp,sp,-112
    13be:	f486                	sd	ra,104(sp)
    13c0:	f0a2                	sd	s0,96(sp)
    13c2:	eca6                	sd	s1,88(sp)
    13c4:	e8ca                	sd	s2,80(sp)
    13c6:	e4ce                	sd	s3,72(sp)
    13c8:	e0d2                	sd	s4,64(sp)
    13ca:	fc56                	sd	s5,56(sp)
    13cc:	1880                	addi	s0,sp,112
    13ce:	8a2a                	mv	s4,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    13d0:	60100593          	li	a1,1537
    13d4:	00005517          	auipc	a0,0x5
    13d8:	c0c50513          	addi	a0,a0,-1012 # 5fe0 <malloc+0x548>
    13dc:	00004097          	auipc	ra,0x4
    13e0:	2c4080e7          	jalr	708(ra) # 56a0 <open>
    13e4:	00004097          	auipc	ra,0x4
    13e8:	2a4080e7          	jalr	676(ra) # 5688 <close>
  pid = fork();
    13ec:	00004097          	auipc	ra,0x4
    13f0:	26c080e7          	jalr	620(ra) # 5658 <fork>
  if(pid < 0){
    13f4:	08054063          	bltz	a0,1474 <truncate3+0xb8>
  if(pid == 0){
    13f8:	e969                	bnez	a0,14ca <truncate3+0x10e>
    13fa:	06400913          	li	s2,100
      int fd = open("truncfile", O_WRONLY);
    13fe:	00005997          	auipc	s3,0x5
    1402:	be298993          	addi	s3,s3,-1054 # 5fe0 <malloc+0x548>
      int n = write(fd, "1234567890", 10);
    1406:	00005a97          	auipc	s5,0x5
    140a:	40aa8a93          	addi	s5,s5,1034 # 6810 <malloc+0xd78>
      int fd = open("truncfile", O_WRONLY);
    140e:	4585                	li	a1,1
    1410:	854e                	mv	a0,s3
    1412:	00004097          	auipc	ra,0x4
    1416:	28e080e7          	jalr	654(ra) # 56a0 <open>
    141a:	84aa                	mv	s1,a0
      if(fd < 0){
    141c:	06054a63          	bltz	a0,1490 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    1420:	4629                	li	a2,10
    1422:	85d6                	mv	a1,s5
    1424:	00004097          	auipc	ra,0x4
    1428:	25c080e7          	jalr	604(ra) # 5680 <write>
      if(n != 10){
    142c:	47a9                	li	a5,10
    142e:	06f51f63          	bne	a0,a5,14ac <truncate3+0xf0>
      close(fd);
    1432:	8526                	mv	a0,s1
    1434:	00004097          	auipc	ra,0x4
    1438:	254080e7          	jalr	596(ra) # 5688 <close>
      fd = open("truncfile", O_RDONLY);
    143c:	4581                	li	a1,0
    143e:	854e                	mv	a0,s3
    1440:	00004097          	auipc	ra,0x4
    1444:	260080e7          	jalr	608(ra) # 56a0 <open>
    1448:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    144a:	02000613          	li	a2,32
    144e:	f9840593          	addi	a1,s0,-104
    1452:	00004097          	auipc	ra,0x4
    1456:	226080e7          	jalr	550(ra) # 5678 <read>
      close(fd);
    145a:	8526                	mv	a0,s1
    145c:	00004097          	auipc	ra,0x4
    1460:	22c080e7          	jalr	556(ra) # 5688 <close>
    for(int i = 0; i < 100; i++){
    1464:	397d                	addiw	s2,s2,-1
    1466:	fa0914e3          	bnez	s2,140e <truncate3+0x52>
    exit(0);
    146a:	4501                	li	a0,0
    146c:	00004097          	auipc	ra,0x4
    1470:	1f4080e7          	jalr	500(ra) # 5660 <exit>
    printf("%s: fork failed\n", s);
    1474:	85d2                	mv	a1,s4
    1476:	00005517          	auipc	a0,0x5
    147a:	36a50513          	addi	a0,a0,874 # 67e0 <malloc+0xd48>
    147e:	00004097          	auipc	ra,0x4
    1482:	55a080e7          	jalr	1370(ra) # 59d8 <printf>
    exit(1);
    1486:	4505                	li	a0,1
    1488:	00004097          	auipc	ra,0x4
    148c:	1d8080e7          	jalr	472(ra) # 5660 <exit>
        printf("%s: open failed\n", s);
    1490:	85d2                	mv	a1,s4
    1492:	00005517          	auipc	a0,0x5
    1496:	36650513          	addi	a0,a0,870 # 67f8 <malloc+0xd60>
    149a:	00004097          	auipc	ra,0x4
    149e:	53e080e7          	jalr	1342(ra) # 59d8 <printf>
        exit(1);
    14a2:	4505                	li	a0,1
    14a4:	00004097          	auipc	ra,0x4
    14a8:	1bc080e7          	jalr	444(ra) # 5660 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    14ac:	862a                	mv	a2,a0
    14ae:	85d2                	mv	a1,s4
    14b0:	00005517          	auipc	a0,0x5
    14b4:	37050513          	addi	a0,a0,880 # 6820 <malloc+0xd88>
    14b8:	00004097          	auipc	ra,0x4
    14bc:	520080e7          	jalr	1312(ra) # 59d8 <printf>
        exit(1);
    14c0:	4505                	li	a0,1
    14c2:	00004097          	auipc	ra,0x4
    14c6:	19e080e7          	jalr	414(ra) # 5660 <exit>
    14ca:	09600913          	li	s2,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14ce:	00005997          	auipc	s3,0x5
    14d2:	b1298993          	addi	s3,s3,-1262 # 5fe0 <malloc+0x548>
    int n = write(fd, "xxx", 3);
    14d6:	00005a97          	auipc	s5,0x5
    14da:	36aa8a93          	addi	s5,s5,874 # 6840 <malloc+0xda8>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14de:	60100593          	li	a1,1537
    14e2:	854e                	mv	a0,s3
    14e4:	00004097          	auipc	ra,0x4
    14e8:	1bc080e7          	jalr	444(ra) # 56a0 <open>
    14ec:	84aa                	mv	s1,a0
    if(fd < 0){
    14ee:	04054763          	bltz	a0,153c <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    14f2:	460d                	li	a2,3
    14f4:	85d6                	mv	a1,s5
    14f6:	00004097          	auipc	ra,0x4
    14fa:	18a080e7          	jalr	394(ra) # 5680 <write>
    if(n != 3){
    14fe:	478d                	li	a5,3
    1500:	04f51c63          	bne	a0,a5,1558 <truncate3+0x19c>
    close(fd);
    1504:	8526                	mv	a0,s1
    1506:	00004097          	auipc	ra,0x4
    150a:	182080e7          	jalr	386(ra) # 5688 <close>
  for(int i = 0; i < 150; i++){
    150e:	397d                	addiw	s2,s2,-1
    1510:	fc0917e3          	bnez	s2,14de <truncate3+0x122>
  wait(&xstatus);
    1514:	fbc40513          	addi	a0,s0,-68
    1518:	00004097          	auipc	ra,0x4
    151c:	150080e7          	jalr	336(ra) # 5668 <wait>
  unlink("truncfile");
    1520:	00005517          	auipc	a0,0x5
    1524:	ac050513          	addi	a0,a0,-1344 # 5fe0 <malloc+0x548>
    1528:	00004097          	auipc	ra,0x4
    152c:	188080e7          	jalr	392(ra) # 56b0 <unlink>
  exit(xstatus);
    1530:	fbc42503          	lw	a0,-68(s0)
    1534:	00004097          	auipc	ra,0x4
    1538:	12c080e7          	jalr	300(ra) # 5660 <exit>
      printf("%s: open failed\n", s);
    153c:	85d2                	mv	a1,s4
    153e:	00005517          	auipc	a0,0x5
    1542:	2ba50513          	addi	a0,a0,698 # 67f8 <malloc+0xd60>
    1546:	00004097          	auipc	ra,0x4
    154a:	492080e7          	jalr	1170(ra) # 59d8 <printf>
      exit(1);
    154e:	4505                	li	a0,1
    1550:	00004097          	auipc	ra,0x4
    1554:	110080e7          	jalr	272(ra) # 5660 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1558:	862a                	mv	a2,a0
    155a:	85d2                	mv	a1,s4
    155c:	00005517          	auipc	a0,0x5
    1560:	2ec50513          	addi	a0,a0,748 # 6848 <malloc+0xdb0>
    1564:	00004097          	auipc	ra,0x4
    1568:	474080e7          	jalr	1140(ra) # 59d8 <printf>
      exit(1);
    156c:	4505                	li	a0,1
    156e:	00004097          	auipc	ra,0x4
    1572:	0f2080e7          	jalr	242(ra) # 5660 <exit>

0000000000001576 <exectest>:
{
    1576:	715d                	addi	sp,sp,-80
    1578:	e486                	sd	ra,72(sp)
    157a:	e0a2                	sd	s0,64(sp)
    157c:	fc26                	sd	s1,56(sp)
    157e:	f84a                	sd	s2,48(sp)
    1580:	0880                	addi	s0,sp,80
    1582:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1584:	00005797          	auipc	a5,0x5
    1588:	a0478793          	addi	a5,a5,-1532 # 5f88 <malloc+0x4f0>
    158c:	fcf43023          	sd	a5,-64(s0)
    1590:	00005797          	auipc	a5,0x5
    1594:	2d878793          	addi	a5,a5,728 # 6868 <malloc+0xdd0>
    1598:	fcf43423          	sd	a5,-56(s0)
    159c:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    15a0:	00005517          	auipc	a0,0x5
    15a4:	2d050513          	addi	a0,a0,720 # 6870 <malloc+0xdd8>
    15a8:	00004097          	auipc	ra,0x4
    15ac:	108080e7          	jalr	264(ra) # 56b0 <unlink>
  pid = fork();
    15b0:	00004097          	auipc	ra,0x4
    15b4:	0a8080e7          	jalr	168(ra) # 5658 <fork>
  if(pid < 0) {
    15b8:	04054663          	bltz	a0,1604 <exectest+0x8e>
    15bc:	84aa                	mv	s1,a0
  if(pid == 0) {
    15be:	e959                	bnez	a0,1654 <exectest+0xde>
    close(1);
    15c0:	4505                	li	a0,1
    15c2:	00004097          	auipc	ra,0x4
    15c6:	0c6080e7          	jalr	198(ra) # 5688 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    15ca:	20100593          	li	a1,513
    15ce:	00005517          	auipc	a0,0x5
    15d2:	2a250513          	addi	a0,a0,674 # 6870 <malloc+0xdd8>
    15d6:	00004097          	auipc	ra,0x4
    15da:	0ca080e7          	jalr	202(ra) # 56a0 <open>
    if(fd < 0) {
    15de:	04054163          	bltz	a0,1620 <exectest+0xaa>
    if(fd != 1) {
    15e2:	4785                	li	a5,1
    15e4:	04f50c63          	beq	a0,a5,163c <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    15e8:	85ca                	mv	a1,s2
    15ea:	00005517          	auipc	a0,0x5
    15ee:	2a650513          	addi	a0,a0,678 # 6890 <malloc+0xdf8>
    15f2:	00004097          	auipc	ra,0x4
    15f6:	3e6080e7          	jalr	998(ra) # 59d8 <printf>
      exit(1);
    15fa:	4505                	li	a0,1
    15fc:	00004097          	auipc	ra,0x4
    1600:	064080e7          	jalr	100(ra) # 5660 <exit>
     printf("%s: fork failed\n", s);
    1604:	85ca                	mv	a1,s2
    1606:	00005517          	auipc	a0,0x5
    160a:	1da50513          	addi	a0,a0,474 # 67e0 <malloc+0xd48>
    160e:	00004097          	auipc	ra,0x4
    1612:	3ca080e7          	jalr	970(ra) # 59d8 <printf>
     exit(1);
    1616:	4505                	li	a0,1
    1618:	00004097          	auipc	ra,0x4
    161c:	048080e7          	jalr	72(ra) # 5660 <exit>
      printf("%s: create failed\n", s);
    1620:	85ca                	mv	a1,s2
    1622:	00005517          	auipc	a0,0x5
    1626:	25650513          	addi	a0,a0,598 # 6878 <malloc+0xde0>
    162a:	00004097          	auipc	ra,0x4
    162e:	3ae080e7          	jalr	942(ra) # 59d8 <printf>
      exit(1);
    1632:	4505                	li	a0,1
    1634:	00004097          	auipc	ra,0x4
    1638:	02c080e7          	jalr	44(ra) # 5660 <exit>
    if(exec("echo", echoargv) < 0){
    163c:	fc040593          	addi	a1,s0,-64
    1640:	00005517          	auipc	a0,0x5
    1644:	94850513          	addi	a0,a0,-1720 # 5f88 <malloc+0x4f0>
    1648:	00004097          	auipc	ra,0x4
    164c:	050080e7          	jalr	80(ra) # 5698 <exec>
    1650:	02054163          	bltz	a0,1672 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1654:	fdc40513          	addi	a0,s0,-36
    1658:	00004097          	auipc	ra,0x4
    165c:	010080e7          	jalr	16(ra) # 5668 <wait>
    1660:	02951763          	bne	a0,s1,168e <exectest+0x118>
  if(xstatus != 0)
    1664:	fdc42503          	lw	a0,-36(s0)
    1668:	cd0d                	beqz	a0,16a2 <exectest+0x12c>
    exit(xstatus);
    166a:	00004097          	auipc	ra,0x4
    166e:	ff6080e7          	jalr	-10(ra) # 5660 <exit>
      printf("%s: exec echo failed\n", s);
    1672:	85ca                	mv	a1,s2
    1674:	00005517          	auipc	a0,0x5
    1678:	22c50513          	addi	a0,a0,556 # 68a0 <malloc+0xe08>
    167c:	00004097          	auipc	ra,0x4
    1680:	35c080e7          	jalr	860(ra) # 59d8 <printf>
      exit(1);
    1684:	4505                	li	a0,1
    1686:	00004097          	auipc	ra,0x4
    168a:	fda080e7          	jalr	-38(ra) # 5660 <exit>
    printf("%s: wait failed!\n", s);
    168e:	85ca                	mv	a1,s2
    1690:	00005517          	auipc	a0,0x5
    1694:	22850513          	addi	a0,a0,552 # 68b8 <malloc+0xe20>
    1698:	00004097          	auipc	ra,0x4
    169c:	340080e7          	jalr	832(ra) # 59d8 <printf>
    16a0:	b7d1                	j	1664 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    16a2:	4581                	li	a1,0
    16a4:	00005517          	auipc	a0,0x5
    16a8:	1cc50513          	addi	a0,a0,460 # 6870 <malloc+0xdd8>
    16ac:	00004097          	auipc	ra,0x4
    16b0:	ff4080e7          	jalr	-12(ra) # 56a0 <open>
  if(fd < 0) {
    16b4:	02054a63          	bltz	a0,16e8 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    16b8:	4609                	li	a2,2
    16ba:	fb840593          	addi	a1,s0,-72
    16be:	00004097          	auipc	ra,0x4
    16c2:	fba080e7          	jalr	-70(ra) # 5678 <read>
    16c6:	4789                	li	a5,2
    16c8:	02f50e63          	beq	a0,a5,1704 <exectest+0x18e>
    printf("%s: read failed\n", s);
    16cc:	85ca                	mv	a1,s2
    16ce:	00005517          	auipc	a0,0x5
    16d2:	c5a50513          	addi	a0,a0,-934 # 6328 <malloc+0x890>
    16d6:	00004097          	auipc	ra,0x4
    16da:	302080e7          	jalr	770(ra) # 59d8 <printf>
    exit(1);
    16de:	4505                	li	a0,1
    16e0:	00004097          	auipc	ra,0x4
    16e4:	f80080e7          	jalr	-128(ra) # 5660 <exit>
    printf("%s: open failed\n", s);
    16e8:	85ca                	mv	a1,s2
    16ea:	00005517          	auipc	a0,0x5
    16ee:	10e50513          	addi	a0,a0,270 # 67f8 <malloc+0xd60>
    16f2:	00004097          	auipc	ra,0x4
    16f6:	2e6080e7          	jalr	742(ra) # 59d8 <printf>
    exit(1);
    16fa:	4505                	li	a0,1
    16fc:	00004097          	auipc	ra,0x4
    1700:	f64080e7          	jalr	-156(ra) # 5660 <exit>
  unlink("echo-ok");
    1704:	00005517          	auipc	a0,0x5
    1708:	16c50513          	addi	a0,a0,364 # 6870 <malloc+0xdd8>
    170c:	00004097          	auipc	ra,0x4
    1710:	fa4080e7          	jalr	-92(ra) # 56b0 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1714:	fb844703          	lbu	a4,-72(s0)
    1718:	04f00793          	li	a5,79
    171c:	00f71863          	bne	a4,a5,172c <exectest+0x1b6>
    1720:	fb944703          	lbu	a4,-71(s0)
    1724:	04b00793          	li	a5,75
    1728:	02f70063          	beq	a4,a5,1748 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    172c:	85ca                	mv	a1,s2
    172e:	00005517          	auipc	a0,0x5
    1732:	1a250513          	addi	a0,a0,418 # 68d0 <malloc+0xe38>
    1736:	00004097          	auipc	ra,0x4
    173a:	2a2080e7          	jalr	674(ra) # 59d8 <printf>
    exit(1);
    173e:	4505                	li	a0,1
    1740:	00004097          	auipc	ra,0x4
    1744:	f20080e7          	jalr	-224(ra) # 5660 <exit>
    exit(0);
    1748:	4501                	li	a0,0
    174a:	00004097          	auipc	ra,0x4
    174e:	f16080e7          	jalr	-234(ra) # 5660 <exit>

0000000000001752 <pipe1>:
{
    1752:	715d                	addi	sp,sp,-80
    1754:	e486                	sd	ra,72(sp)
    1756:	e0a2                	sd	s0,64(sp)
    1758:	fc26                	sd	s1,56(sp)
    175a:	f84a                	sd	s2,48(sp)
    175c:	f44e                	sd	s3,40(sp)
    175e:	f052                	sd	s4,32(sp)
    1760:	ec56                	sd	s5,24(sp)
    1762:	e85a                	sd	s6,16(sp)
    1764:	0880                	addi	s0,sp,80
    1766:	89aa                	mv	s3,a0
  if(pipe(fds) != 0){
    1768:	fb840513          	addi	a0,s0,-72
    176c:	00004097          	auipc	ra,0x4
    1770:	f04080e7          	jalr	-252(ra) # 5670 <pipe>
    1774:	e935                	bnez	a0,17e8 <pipe1+0x96>
    1776:	84aa                	mv	s1,a0
  pid = fork();
    1778:	00004097          	auipc	ra,0x4
    177c:	ee0080e7          	jalr	-288(ra) # 5658 <fork>
  if(pid == 0){
    1780:	c151                	beqz	a0,1804 <pipe1+0xb2>
  } else if(pid > 0){
    1782:	18a05963          	blez	a0,1914 <pipe1+0x1c2>
    close(fds[1]);
    1786:	fbc42503          	lw	a0,-68(s0)
    178a:	00004097          	auipc	ra,0x4
    178e:	efe080e7          	jalr	-258(ra) # 5688 <close>
    total = 0;
    1792:	8aa6                	mv	s5,s1
    cc = 1;
    1794:	4a05                	li	s4,1
    while((n = read(fds[0], buf, cc)) > 0){
    1796:	0000a917          	auipc	s2,0xa
    179a:	35a90913          	addi	s2,s2,858 # baf0 <buf>
      if(cc > sizeof(buf))
    179e:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    17a0:	8652                	mv	a2,s4
    17a2:	85ca                	mv	a1,s2
    17a4:	fb842503          	lw	a0,-72(s0)
    17a8:	00004097          	auipc	ra,0x4
    17ac:	ed0080e7          	jalr	-304(ra) # 5678 <read>
    17b0:	10a05d63          	blez	a0,18ca <pipe1+0x178>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17b4:	0014879b          	addiw	a5,s1,1
    17b8:	00094683          	lbu	a3,0(s2)
    17bc:	0ff4f713          	andi	a4,s1,255
    17c0:	0ce69863          	bne	a3,a4,1890 <pipe1+0x13e>
    17c4:	0000a717          	auipc	a4,0xa
    17c8:	32d70713          	addi	a4,a4,813 # baf1 <buf+0x1>
    17cc:	9ca9                	addw	s1,s1,a0
      for(i = 0; i < n; i++){
    17ce:	0e978463          	beq	a5,s1,18b6 <pipe1+0x164>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17d2:	00074683          	lbu	a3,0(a4)
    17d6:	0017861b          	addiw	a2,a5,1
    17da:	0705                	addi	a4,a4,1
    17dc:	0ff7f793          	andi	a5,a5,255
    17e0:	0af69863          	bne	a3,a5,1890 <pipe1+0x13e>
    17e4:	87b2                	mv	a5,a2
    17e6:	b7e5                	j	17ce <pipe1+0x7c>
    printf("%s: pipe() failed\n", s);
    17e8:	85ce                	mv	a1,s3
    17ea:	00005517          	auipc	a0,0x5
    17ee:	0fe50513          	addi	a0,a0,254 # 68e8 <malloc+0xe50>
    17f2:	00004097          	auipc	ra,0x4
    17f6:	1e6080e7          	jalr	486(ra) # 59d8 <printf>
    exit(1);
    17fa:	4505                	li	a0,1
    17fc:	00004097          	auipc	ra,0x4
    1800:	e64080e7          	jalr	-412(ra) # 5660 <exit>
    close(fds[0]);
    1804:	fb842503          	lw	a0,-72(s0)
    1808:	00004097          	auipc	ra,0x4
    180c:	e80080e7          	jalr	-384(ra) # 5688 <close>
    for(n = 0; n < N; n++){
    1810:	0000aa97          	auipc	s5,0xa
    1814:	2e0a8a93          	addi	s5,s5,736 # baf0 <buf>
    1818:	0ffaf793          	andi	a5,s5,255
    181c:	40f004b3          	neg	s1,a5
    1820:	0ff4f493          	andi	s1,s1,255
    1824:	02d00a13          	li	s4,45
    1828:	40fa0a3b          	subw	s4,s4,a5
    182c:	0ffa7a13          	andi	s4,s4,255
    1830:	409a8913          	addi	s2,s5,1033
      if(write(fds[1], buf, SZ) != SZ){
    1834:	8b56                	mv	s6,s5
{
    1836:	87d6                	mv	a5,s5
        buf[i] = seq++;
    1838:	0097873b          	addw	a4,a5,s1
    183c:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1840:	0785                	addi	a5,a5,1
    1842:	fef91be3          	bne	s2,a5,1838 <pipe1+0xe6>
      if(write(fds[1], buf, SZ) != SZ){
    1846:	40900613          	li	a2,1033
    184a:	85da                	mv	a1,s6
    184c:	fbc42503          	lw	a0,-68(s0)
    1850:	00004097          	auipc	ra,0x4
    1854:	e30080e7          	jalr	-464(ra) # 5680 <write>
    1858:	40900793          	li	a5,1033
    185c:	00f51c63          	bne	a0,a5,1874 <pipe1+0x122>
    for(n = 0; n < N; n++){
    1860:	24a5                	addiw	s1,s1,9
    1862:	0ff4f493          	andi	s1,s1,255
    1866:	fd4498e3          	bne	s1,s4,1836 <pipe1+0xe4>
    exit(0);
    186a:	4501                	li	a0,0
    186c:	00004097          	auipc	ra,0x4
    1870:	df4080e7          	jalr	-524(ra) # 5660 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1874:	85ce                	mv	a1,s3
    1876:	00005517          	auipc	a0,0x5
    187a:	08a50513          	addi	a0,a0,138 # 6900 <malloc+0xe68>
    187e:	00004097          	auipc	ra,0x4
    1882:	15a080e7          	jalr	346(ra) # 59d8 <printf>
        exit(1);
    1886:	4505                	li	a0,1
    1888:	00004097          	auipc	ra,0x4
    188c:	dd8080e7          	jalr	-552(ra) # 5660 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1890:	85ce                	mv	a1,s3
    1892:	00005517          	auipc	a0,0x5
    1896:	08650513          	addi	a0,a0,134 # 6918 <malloc+0xe80>
    189a:	00004097          	auipc	ra,0x4
    189e:	13e080e7          	jalr	318(ra) # 59d8 <printf>
}
    18a2:	60a6                	ld	ra,72(sp)
    18a4:	6406                	ld	s0,64(sp)
    18a6:	74e2                	ld	s1,56(sp)
    18a8:	7942                	ld	s2,48(sp)
    18aa:	79a2                	ld	s3,40(sp)
    18ac:	7a02                	ld	s4,32(sp)
    18ae:	6ae2                	ld	s5,24(sp)
    18b0:	6b42                	ld	s6,16(sp)
    18b2:	6161                	addi	sp,sp,80
    18b4:	8082                	ret
      total += n;
    18b6:	00aa8abb          	addw	s5,s5,a0
      cc = cc * 2;
    18ba:	001a179b          	slliw	a5,s4,0x1
    18be:	00078a1b          	sext.w	s4,a5
      if(cc > sizeof(buf))
    18c2:	ed4b7fe3          	bleu	s4,s6,17a0 <pipe1+0x4e>
        cc = sizeof(buf);
    18c6:	8a5a                	mv	s4,s6
    18c8:	bde1                	j	17a0 <pipe1+0x4e>
    if(total != N * SZ){
    18ca:	6785                	lui	a5,0x1
    18cc:	42d78793          	addi	a5,a5,1069 # 142d <truncate3+0x71>
    18d0:	02fa8063          	beq	s5,a5,18f0 <pipe1+0x19e>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18d4:	85d6                	mv	a1,s5
    18d6:	00005517          	auipc	a0,0x5
    18da:	05a50513          	addi	a0,a0,90 # 6930 <malloc+0xe98>
    18de:	00004097          	auipc	ra,0x4
    18e2:	0fa080e7          	jalr	250(ra) # 59d8 <printf>
      exit(1);
    18e6:	4505                	li	a0,1
    18e8:	00004097          	auipc	ra,0x4
    18ec:	d78080e7          	jalr	-648(ra) # 5660 <exit>
    close(fds[0]);
    18f0:	fb842503          	lw	a0,-72(s0)
    18f4:	00004097          	auipc	ra,0x4
    18f8:	d94080e7          	jalr	-620(ra) # 5688 <close>
    wait(&xstatus);
    18fc:	fb440513          	addi	a0,s0,-76
    1900:	00004097          	auipc	ra,0x4
    1904:	d68080e7          	jalr	-664(ra) # 5668 <wait>
    exit(xstatus);
    1908:	fb442503          	lw	a0,-76(s0)
    190c:	00004097          	auipc	ra,0x4
    1910:	d54080e7          	jalr	-684(ra) # 5660 <exit>
    printf("%s: fork() failed\n", s);
    1914:	85ce                	mv	a1,s3
    1916:	00005517          	auipc	a0,0x5
    191a:	03a50513          	addi	a0,a0,58 # 6950 <malloc+0xeb8>
    191e:	00004097          	auipc	ra,0x4
    1922:	0ba080e7          	jalr	186(ra) # 59d8 <printf>
    exit(1);
    1926:	4505                	li	a0,1
    1928:	00004097          	auipc	ra,0x4
    192c:	d38080e7          	jalr	-712(ra) # 5660 <exit>

0000000000001930 <exitwait>:
{
    1930:	7139                	addi	sp,sp,-64
    1932:	fc06                	sd	ra,56(sp)
    1934:	f822                	sd	s0,48(sp)
    1936:	f426                	sd	s1,40(sp)
    1938:	f04a                	sd	s2,32(sp)
    193a:	ec4e                	sd	s3,24(sp)
    193c:	e852                	sd	s4,16(sp)
    193e:	0080                	addi	s0,sp,64
    1940:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1942:	4481                	li	s1,0
    1944:	06400993          	li	s3,100
    pid = fork();
    1948:	00004097          	auipc	ra,0x4
    194c:	d10080e7          	jalr	-752(ra) # 5658 <fork>
    1950:	892a                	mv	s2,a0
    if(pid < 0){
    1952:	02054a63          	bltz	a0,1986 <exitwait+0x56>
    if(pid){
    1956:	c151                	beqz	a0,19da <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1958:	fcc40513          	addi	a0,s0,-52
    195c:	00004097          	auipc	ra,0x4
    1960:	d0c080e7          	jalr	-756(ra) # 5668 <wait>
    1964:	03251f63          	bne	a0,s2,19a2 <exitwait+0x72>
      if(i != xstate) {
    1968:	fcc42783          	lw	a5,-52(s0)
    196c:	04979963          	bne	a5,s1,19be <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    1970:	2485                	addiw	s1,s1,1
    1972:	fd349be3          	bne	s1,s3,1948 <exitwait+0x18>
}
    1976:	70e2                	ld	ra,56(sp)
    1978:	7442                	ld	s0,48(sp)
    197a:	74a2                	ld	s1,40(sp)
    197c:	7902                	ld	s2,32(sp)
    197e:	69e2                	ld	s3,24(sp)
    1980:	6a42                	ld	s4,16(sp)
    1982:	6121                	addi	sp,sp,64
    1984:	8082                	ret
      printf("%s: fork failed\n", s);
    1986:	85d2                	mv	a1,s4
    1988:	00005517          	auipc	a0,0x5
    198c:	e5850513          	addi	a0,a0,-424 # 67e0 <malloc+0xd48>
    1990:	00004097          	auipc	ra,0x4
    1994:	048080e7          	jalr	72(ra) # 59d8 <printf>
      exit(1);
    1998:	4505                	li	a0,1
    199a:	00004097          	auipc	ra,0x4
    199e:	cc6080e7          	jalr	-826(ra) # 5660 <exit>
        printf("%s: wait wrong pid\n", s);
    19a2:	85d2                	mv	a1,s4
    19a4:	00005517          	auipc	a0,0x5
    19a8:	fc450513          	addi	a0,a0,-60 # 6968 <malloc+0xed0>
    19ac:	00004097          	auipc	ra,0x4
    19b0:	02c080e7          	jalr	44(ra) # 59d8 <printf>
        exit(1);
    19b4:	4505                	li	a0,1
    19b6:	00004097          	auipc	ra,0x4
    19ba:	caa080e7          	jalr	-854(ra) # 5660 <exit>
        printf("%s: wait wrong exit status\n", s);
    19be:	85d2                	mv	a1,s4
    19c0:	00005517          	auipc	a0,0x5
    19c4:	fc050513          	addi	a0,a0,-64 # 6980 <malloc+0xee8>
    19c8:	00004097          	auipc	ra,0x4
    19cc:	010080e7          	jalr	16(ra) # 59d8 <printf>
        exit(1);
    19d0:	4505                	li	a0,1
    19d2:	00004097          	auipc	ra,0x4
    19d6:	c8e080e7          	jalr	-882(ra) # 5660 <exit>
      exit(i);
    19da:	8526                	mv	a0,s1
    19dc:	00004097          	auipc	ra,0x4
    19e0:	c84080e7          	jalr	-892(ra) # 5660 <exit>

00000000000019e4 <twochildren>:
{
    19e4:	1101                	addi	sp,sp,-32
    19e6:	ec06                	sd	ra,24(sp)
    19e8:	e822                	sd	s0,16(sp)
    19ea:	e426                	sd	s1,8(sp)
    19ec:	e04a                	sd	s2,0(sp)
    19ee:	1000                	addi	s0,sp,32
    19f0:	892a                	mv	s2,a0
    19f2:	3e800493          	li	s1,1000
    int pid1 = fork();
    19f6:	00004097          	auipc	ra,0x4
    19fa:	c62080e7          	jalr	-926(ra) # 5658 <fork>
    if(pid1 < 0){
    19fe:	02054c63          	bltz	a0,1a36 <twochildren+0x52>
    if(pid1 == 0){
    1a02:	c921                	beqz	a0,1a52 <twochildren+0x6e>
      int pid2 = fork();
    1a04:	00004097          	auipc	ra,0x4
    1a08:	c54080e7          	jalr	-940(ra) # 5658 <fork>
      if(pid2 < 0){
    1a0c:	04054763          	bltz	a0,1a5a <twochildren+0x76>
      if(pid2 == 0){
    1a10:	c13d                	beqz	a0,1a76 <twochildren+0x92>
        wait(0);
    1a12:	4501                	li	a0,0
    1a14:	00004097          	auipc	ra,0x4
    1a18:	c54080e7          	jalr	-940(ra) # 5668 <wait>
        wait(0);
    1a1c:	4501                	li	a0,0
    1a1e:	00004097          	auipc	ra,0x4
    1a22:	c4a080e7          	jalr	-950(ra) # 5668 <wait>
  for(int i = 0; i < 1000; i++){
    1a26:	34fd                	addiw	s1,s1,-1
    1a28:	f4f9                	bnez	s1,19f6 <twochildren+0x12>
}
    1a2a:	60e2                	ld	ra,24(sp)
    1a2c:	6442                	ld	s0,16(sp)
    1a2e:	64a2                	ld	s1,8(sp)
    1a30:	6902                	ld	s2,0(sp)
    1a32:	6105                	addi	sp,sp,32
    1a34:	8082                	ret
      printf("%s: fork failed\n", s);
    1a36:	85ca                	mv	a1,s2
    1a38:	00005517          	auipc	a0,0x5
    1a3c:	da850513          	addi	a0,a0,-600 # 67e0 <malloc+0xd48>
    1a40:	00004097          	auipc	ra,0x4
    1a44:	f98080e7          	jalr	-104(ra) # 59d8 <printf>
      exit(1);
    1a48:	4505                	li	a0,1
    1a4a:	00004097          	auipc	ra,0x4
    1a4e:	c16080e7          	jalr	-1002(ra) # 5660 <exit>
      exit(0);
    1a52:	00004097          	auipc	ra,0x4
    1a56:	c0e080e7          	jalr	-1010(ra) # 5660 <exit>
        printf("%s: fork failed\n", s);
    1a5a:	85ca                	mv	a1,s2
    1a5c:	00005517          	auipc	a0,0x5
    1a60:	d8450513          	addi	a0,a0,-636 # 67e0 <malloc+0xd48>
    1a64:	00004097          	auipc	ra,0x4
    1a68:	f74080e7          	jalr	-140(ra) # 59d8 <printf>
        exit(1);
    1a6c:	4505                	li	a0,1
    1a6e:	00004097          	auipc	ra,0x4
    1a72:	bf2080e7          	jalr	-1038(ra) # 5660 <exit>
        exit(0);
    1a76:	00004097          	auipc	ra,0x4
    1a7a:	bea080e7          	jalr	-1046(ra) # 5660 <exit>

0000000000001a7e <forkfork>:
{
    1a7e:	7179                	addi	sp,sp,-48
    1a80:	f406                	sd	ra,40(sp)
    1a82:	f022                	sd	s0,32(sp)
    1a84:	ec26                	sd	s1,24(sp)
    1a86:	1800                	addi	s0,sp,48
    1a88:	84aa                	mv	s1,a0
    int pid = fork();
    1a8a:	00004097          	auipc	ra,0x4
    1a8e:	bce080e7          	jalr	-1074(ra) # 5658 <fork>
    if(pid < 0){
    1a92:	04054163          	bltz	a0,1ad4 <forkfork+0x56>
    if(pid == 0){
    1a96:	cd29                	beqz	a0,1af0 <forkfork+0x72>
    int pid = fork();
    1a98:	00004097          	auipc	ra,0x4
    1a9c:	bc0080e7          	jalr	-1088(ra) # 5658 <fork>
    if(pid < 0){
    1aa0:	02054a63          	bltz	a0,1ad4 <forkfork+0x56>
    if(pid == 0){
    1aa4:	c531                	beqz	a0,1af0 <forkfork+0x72>
    wait(&xstatus);
    1aa6:	fdc40513          	addi	a0,s0,-36
    1aaa:	00004097          	auipc	ra,0x4
    1aae:	bbe080e7          	jalr	-1090(ra) # 5668 <wait>
    if(xstatus != 0) {
    1ab2:	fdc42783          	lw	a5,-36(s0)
    1ab6:	ebbd                	bnez	a5,1b2c <forkfork+0xae>
    wait(&xstatus);
    1ab8:	fdc40513          	addi	a0,s0,-36
    1abc:	00004097          	auipc	ra,0x4
    1ac0:	bac080e7          	jalr	-1108(ra) # 5668 <wait>
    if(xstatus != 0) {
    1ac4:	fdc42783          	lw	a5,-36(s0)
    1ac8:	e3b5                	bnez	a5,1b2c <forkfork+0xae>
}
    1aca:	70a2                	ld	ra,40(sp)
    1acc:	7402                	ld	s0,32(sp)
    1ace:	64e2                	ld	s1,24(sp)
    1ad0:	6145                	addi	sp,sp,48
    1ad2:	8082                	ret
      printf("%s: fork failed", s);
    1ad4:	85a6                	mv	a1,s1
    1ad6:	00005517          	auipc	a0,0x5
    1ada:	eca50513          	addi	a0,a0,-310 # 69a0 <malloc+0xf08>
    1ade:	00004097          	auipc	ra,0x4
    1ae2:	efa080e7          	jalr	-262(ra) # 59d8 <printf>
      exit(1);
    1ae6:	4505                	li	a0,1
    1ae8:	00004097          	auipc	ra,0x4
    1aec:	b78080e7          	jalr	-1160(ra) # 5660 <exit>
{
    1af0:	0c800493          	li	s1,200
        int pid1 = fork();
    1af4:	00004097          	auipc	ra,0x4
    1af8:	b64080e7          	jalr	-1180(ra) # 5658 <fork>
        if(pid1 < 0){
    1afc:	00054f63          	bltz	a0,1b1a <forkfork+0x9c>
        if(pid1 == 0){
    1b00:	c115                	beqz	a0,1b24 <forkfork+0xa6>
        wait(0);
    1b02:	4501                	li	a0,0
    1b04:	00004097          	auipc	ra,0x4
    1b08:	b64080e7          	jalr	-1180(ra) # 5668 <wait>
      for(int j = 0; j < 200; j++){
    1b0c:	34fd                	addiw	s1,s1,-1
    1b0e:	f0fd                	bnez	s1,1af4 <forkfork+0x76>
      exit(0);
    1b10:	4501                	li	a0,0
    1b12:	00004097          	auipc	ra,0x4
    1b16:	b4e080e7          	jalr	-1202(ra) # 5660 <exit>
          exit(1);
    1b1a:	4505                	li	a0,1
    1b1c:	00004097          	auipc	ra,0x4
    1b20:	b44080e7          	jalr	-1212(ra) # 5660 <exit>
          exit(0);
    1b24:	00004097          	auipc	ra,0x4
    1b28:	b3c080e7          	jalr	-1220(ra) # 5660 <exit>
      printf("%s: fork in child failed", s);
    1b2c:	85a6                	mv	a1,s1
    1b2e:	00005517          	auipc	a0,0x5
    1b32:	e8250513          	addi	a0,a0,-382 # 69b0 <malloc+0xf18>
    1b36:	00004097          	auipc	ra,0x4
    1b3a:	ea2080e7          	jalr	-350(ra) # 59d8 <printf>
      exit(1);
    1b3e:	4505                	li	a0,1
    1b40:	00004097          	auipc	ra,0x4
    1b44:	b20080e7          	jalr	-1248(ra) # 5660 <exit>

0000000000001b48 <reparent2>:
{
    1b48:	1101                	addi	sp,sp,-32
    1b4a:	ec06                	sd	ra,24(sp)
    1b4c:	e822                	sd	s0,16(sp)
    1b4e:	e426                	sd	s1,8(sp)
    1b50:	1000                	addi	s0,sp,32
    1b52:	32000493          	li	s1,800
    int pid1 = fork();
    1b56:	00004097          	auipc	ra,0x4
    1b5a:	b02080e7          	jalr	-1278(ra) # 5658 <fork>
    if(pid1 < 0){
    1b5e:	00054f63          	bltz	a0,1b7c <reparent2+0x34>
    if(pid1 == 0){
    1b62:	c915                	beqz	a0,1b96 <reparent2+0x4e>
    wait(0);
    1b64:	4501                	li	a0,0
    1b66:	00004097          	auipc	ra,0x4
    1b6a:	b02080e7          	jalr	-1278(ra) # 5668 <wait>
  for(int i = 0; i < 800; i++){
    1b6e:	34fd                	addiw	s1,s1,-1
    1b70:	f0fd                	bnez	s1,1b56 <reparent2+0xe>
  exit(0);
    1b72:	4501                	li	a0,0
    1b74:	00004097          	auipc	ra,0x4
    1b78:	aec080e7          	jalr	-1300(ra) # 5660 <exit>
      printf("fork failed\n");
    1b7c:	00005517          	auipc	a0,0x5
    1b80:	06c50513          	addi	a0,a0,108 # 6be8 <malloc+0x1150>
    1b84:	00004097          	auipc	ra,0x4
    1b88:	e54080e7          	jalr	-428(ra) # 59d8 <printf>
      exit(1);
    1b8c:	4505                	li	a0,1
    1b8e:	00004097          	auipc	ra,0x4
    1b92:	ad2080e7          	jalr	-1326(ra) # 5660 <exit>
      fork();
    1b96:	00004097          	auipc	ra,0x4
    1b9a:	ac2080e7          	jalr	-1342(ra) # 5658 <fork>
      fork();
    1b9e:	00004097          	auipc	ra,0x4
    1ba2:	aba080e7          	jalr	-1350(ra) # 5658 <fork>
      exit(0);
    1ba6:	4501                	li	a0,0
    1ba8:	00004097          	auipc	ra,0x4
    1bac:	ab8080e7          	jalr	-1352(ra) # 5660 <exit>

0000000000001bb0 <createdelete>:
{
    1bb0:	7175                	addi	sp,sp,-144
    1bb2:	e506                	sd	ra,136(sp)
    1bb4:	e122                	sd	s0,128(sp)
    1bb6:	fca6                	sd	s1,120(sp)
    1bb8:	f8ca                	sd	s2,112(sp)
    1bba:	f4ce                	sd	s3,104(sp)
    1bbc:	f0d2                	sd	s4,96(sp)
    1bbe:	ecd6                	sd	s5,88(sp)
    1bc0:	e8da                	sd	s6,80(sp)
    1bc2:	e4de                	sd	s7,72(sp)
    1bc4:	e0e2                	sd	s8,64(sp)
    1bc6:	fc66                	sd	s9,56(sp)
    1bc8:	0900                	addi	s0,sp,144
    1bca:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1bcc:	4901                	li	s2,0
    1bce:	4991                	li	s3,4
    pid = fork();
    1bd0:	00004097          	auipc	ra,0x4
    1bd4:	a88080e7          	jalr	-1400(ra) # 5658 <fork>
    1bd8:	84aa                	mv	s1,a0
    if(pid < 0){
    1bda:	02054f63          	bltz	a0,1c18 <createdelete+0x68>
    if(pid == 0){
    1bde:	c939                	beqz	a0,1c34 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1be0:	2905                	addiw	s2,s2,1
    1be2:	ff3917e3          	bne	s2,s3,1bd0 <createdelete+0x20>
    1be6:	4491                	li	s1,4
    wait(&xstatus);
    1be8:	f7c40513          	addi	a0,s0,-132
    1bec:	00004097          	auipc	ra,0x4
    1bf0:	a7c080e7          	jalr	-1412(ra) # 5668 <wait>
    if(xstatus != 0)
    1bf4:	f7c42903          	lw	s2,-132(s0)
    1bf8:	0e091263          	bnez	s2,1cdc <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1bfc:	34fd                	addiw	s1,s1,-1
    1bfe:	f4ed                	bnez	s1,1be8 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1c00:	f8040123          	sb	zero,-126(s0)
    1c04:	03000993          	li	s3,48
    1c08:	5a7d                	li	s4,-1
    1c0a:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1c0e:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1c10:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1c12:	07400a93          	li	s5,116
    1c16:	a29d                	j	1d7c <createdelete+0x1cc>
      printf("fork failed\n", s);
    1c18:	85e6                	mv	a1,s9
    1c1a:	00005517          	auipc	a0,0x5
    1c1e:	fce50513          	addi	a0,a0,-50 # 6be8 <malloc+0x1150>
    1c22:	00004097          	auipc	ra,0x4
    1c26:	db6080e7          	jalr	-586(ra) # 59d8 <printf>
      exit(1);
    1c2a:	4505                	li	a0,1
    1c2c:	00004097          	auipc	ra,0x4
    1c30:	a34080e7          	jalr	-1484(ra) # 5660 <exit>
      name[0] = 'p' + pi;
    1c34:	0709091b          	addiw	s2,s2,112
    1c38:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1c3c:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1c40:	4951                	li	s2,20
    1c42:	a015                	j	1c66 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1c44:	85e6                	mv	a1,s9
    1c46:	00005517          	auipc	a0,0x5
    1c4a:	c3250513          	addi	a0,a0,-974 # 6878 <malloc+0xde0>
    1c4e:	00004097          	auipc	ra,0x4
    1c52:	d8a080e7          	jalr	-630(ra) # 59d8 <printf>
          exit(1);
    1c56:	4505                	li	a0,1
    1c58:	00004097          	auipc	ra,0x4
    1c5c:	a08080e7          	jalr	-1528(ra) # 5660 <exit>
      for(i = 0; i < N; i++){
    1c60:	2485                	addiw	s1,s1,1
    1c62:	07248863          	beq	s1,s2,1cd2 <createdelete+0x122>
        name[1] = '0' + i;
    1c66:	0304879b          	addiw	a5,s1,48
    1c6a:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1c6e:	20200593          	li	a1,514
    1c72:	f8040513          	addi	a0,s0,-128
    1c76:	00004097          	auipc	ra,0x4
    1c7a:	a2a080e7          	jalr	-1494(ra) # 56a0 <open>
        if(fd < 0){
    1c7e:	fc0543e3          	bltz	a0,1c44 <createdelete+0x94>
        close(fd);
    1c82:	00004097          	auipc	ra,0x4
    1c86:	a06080e7          	jalr	-1530(ra) # 5688 <close>
        if(i > 0 && (i % 2 ) == 0){
    1c8a:	fc905be3          	blez	s1,1c60 <createdelete+0xb0>
    1c8e:	0014f793          	andi	a5,s1,1
    1c92:	f7f9                	bnez	a5,1c60 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1c94:	01f4d79b          	srliw	a5,s1,0x1f
    1c98:	9fa5                	addw	a5,a5,s1
    1c9a:	4017d79b          	sraiw	a5,a5,0x1
    1c9e:	0307879b          	addiw	a5,a5,48
    1ca2:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1ca6:	f8040513          	addi	a0,s0,-128
    1caa:	00004097          	auipc	ra,0x4
    1cae:	a06080e7          	jalr	-1530(ra) # 56b0 <unlink>
    1cb2:	fa0557e3          	bgez	a0,1c60 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1cb6:	85e6                	mv	a1,s9
    1cb8:	00005517          	auipc	a0,0x5
    1cbc:	d1850513          	addi	a0,a0,-744 # 69d0 <malloc+0xf38>
    1cc0:	00004097          	auipc	ra,0x4
    1cc4:	d18080e7          	jalr	-744(ra) # 59d8 <printf>
            exit(1);
    1cc8:	4505                	li	a0,1
    1cca:	00004097          	auipc	ra,0x4
    1cce:	996080e7          	jalr	-1642(ra) # 5660 <exit>
      exit(0);
    1cd2:	4501                	li	a0,0
    1cd4:	00004097          	auipc	ra,0x4
    1cd8:	98c080e7          	jalr	-1652(ra) # 5660 <exit>
      exit(1);
    1cdc:	4505                	li	a0,1
    1cde:	00004097          	auipc	ra,0x4
    1ce2:	982080e7          	jalr	-1662(ra) # 5660 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1ce6:	f8040613          	addi	a2,s0,-128
    1cea:	85e6                	mv	a1,s9
    1cec:	00005517          	auipc	a0,0x5
    1cf0:	cfc50513          	addi	a0,a0,-772 # 69e8 <malloc+0xf50>
    1cf4:	00004097          	auipc	ra,0x4
    1cf8:	ce4080e7          	jalr	-796(ra) # 59d8 <printf>
        exit(1);
    1cfc:	4505                	li	a0,1
    1cfe:	00004097          	auipc	ra,0x4
    1d02:	962080e7          	jalr	-1694(ra) # 5660 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d06:	054b7163          	bleu	s4,s6,1d48 <createdelete+0x198>
      if(fd >= 0)
    1d0a:	02055a63          	bgez	a0,1d3e <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1d0e:	2485                	addiw	s1,s1,1
    1d10:	0ff4f493          	andi	s1,s1,255
    1d14:	05548c63          	beq	s1,s5,1d6c <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1d18:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1d1c:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1d20:	4581                	li	a1,0
    1d22:	f8040513          	addi	a0,s0,-128
    1d26:	00004097          	auipc	ra,0x4
    1d2a:	97a080e7          	jalr	-1670(ra) # 56a0 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1d2e:	00090463          	beqz	s2,1d36 <createdelete+0x186>
    1d32:	fd2bdae3          	ble	s2,s7,1d06 <createdelete+0x156>
    1d36:	fa0548e3          	bltz	a0,1ce6 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d3a:	014b7963          	bleu	s4,s6,1d4c <createdelete+0x19c>
        close(fd);
    1d3e:	00004097          	auipc	ra,0x4
    1d42:	94a080e7          	jalr	-1718(ra) # 5688 <close>
    1d46:	b7e1                	j	1d0e <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d48:	fc0543e3          	bltz	a0,1d0e <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1d4c:	f8040613          	addi	a2,s0,-128
    1d50:	85e6                	mv	a1,s9
    1d52:	00005517          	auipc	a0,0x5
    1d56:	cbe50513          	addi	a0,a0,-834 # 6a10 <malloc+0xf78>
    1d5a:	00004097          	auipc	ra,0x4
    1d5e:	c7e080e7          	jalr	-898(ra) # 59d8 <printf>
        exit(1);
    1d62:	4505                	li	a0,1
    1d64:	00004097          	auipc	ra,0x4
    1d68:	8fc080e7          	jalr	-1796(ra) # 5660 <exit>
  for(i = 0; i < N; i++){
    1d6c:	2905                	addiw	s2,s2,1
    1d6e:	2a05                	addiw	s4,s4,1
    1d70:	2985                	addiw	s3,s3,1
    1d72:	0ff9f993          	andi	s3,s3,255
    1d76:	47d1                	li	a5,20
    1d78:	02f90a63          	beq	s2,a5,1dac <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1d7c:	84e2                	mv	s1,s8
    1d7e:	bf69                	j	1d18 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1d80:	2905                	addiw	s2,s2,1
    1d82:	0ff97913          	andi	s2,s2,255
    1d86:	2985                	addiw	s3,s3,1
    1d88:	0ff9f993          	andi	s3,s3,255
    1d8c:	03490863          	beq	s2,s4,1dbc <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1d90:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1d92:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1d96:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1d9a:	f8040513          	addi	a0,s0,-128
    1d9e:	00004097          	auipc	ra,0x4
    1da2:	912080e7          	jalr	-1774(ra) # 56b0 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1da6:	34fd                	addiw	s1,s1,-1
    1da8:	f4ed                	bnez	s1,1d92 <createdelete+0x1e2>
    1daa:	bfd9                	j	1d80 <createdelete+0x1d0>
    1dac:	03000993          	li	s3,48
    1db0:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1db4:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1db6:	08400a13          	li	s4,132
    1dba:	bfd9                	j	1d90 <createdelete+0x1e0>
}
    1dbc:	60aa                	ld	ra,136(sp)
    1dbe:	640a                	ld	s0,128(sp)
    1dc0:	74e6                	ld	s1,120(sp)
    1dc2:	7946                	ld	s2,112(sp)
    1dc4:	79a6                	ld	s3,104(sp)
    1dc6:	7a06                	ld	s4,96(sp)
    1dc8:	6ae6                	ld	s5,88(sp)
    1dca:	6b46                	ld	s6,80(sp)
    1dcc:	6ba6                	ld	s7,72(sp)
    1dce:	6c06                	ld	s8,64(sp)
    1dd0:	7ce2                	ld	s9,56(sp)
    1dd2:	6149                	addi	sp,sp,144
    1dd4:	8082                	ret

0000000000001dd6 <linkunlink>:
{
    1dd6:	711d                	addi	sp,sp,-96
    1dd8:	ec86                	sd	ra,88(sp)
    1dda:	e8a2                	sd	s0,80(sp)
    1ddc:	e4a6                	sd	s1,72(sp)
    1dde:	e0ca                	sd	s2,64(sp)
    1de0:	fc4e                	sd	s3,56(sp)
    1de2:	f852                	sd	s4,48(sp)
    1de4:	f456                	sd	s5,40(sp)
    1de6:	f05a                	sd	s6,32(sp)
    1de8:	ec5e                	sd	s7,24(sp)
    1dea:	e862                	sd	s8,16(sp)
    1dec:	e466                	sd	s9,8(sp)
    1dee:	1080                	addi	s0,sp,96
    1df0:	84aa                	mv	s1,a0
  unlink("x");
    1df2:	00004517          	auipc	a0,0x4
    1df6:	20650513          	addi	a0,a0,518 # 5ff8 <malloc+0x560>
    1dfa:	00004097          	auipc	ra,0x4
    1dfe:	8b6080e7          	jalr	-1866(ra) # 56b0 <unlink>
  pid = fork();
    1e02:	00004097          	auipc	ra,0x4
    1e06:	856080e7          	jalr	-1962(ra) # 5658 <fork>
  if(pid < 0){
    1e0a:	02054b63          	bltz	a0,1e40 <linkunlink+0x6a>
    1e0e:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1e10:	4c85                	li	s9,1
    1e12:	e119                	bnez	a0,1e18 <linkunlink+0x42>
    1e14:	06100c93          	li	s9,97
    1e18:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1e1c:	41c659b7          	lui	s3,0x41c65
    1e20:	e6d9899b          	addiw	s3,s3,-403
    1e24:	690d                	lui	s2,0x3
    1e26:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1e2a:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1e2c:	4b05                	li	s6,1
      unlink("x");
    1e2e:	00004a97          	auipc	s5,0x4
    1e32:	1caa8a93          	addi	s5,s5,458 # 5ff8 <malloc+0x560>
      link("cat", "x");
    1e36:	00005b97          	auipc	s7,0x5
    1e3a:	c02b8b93          	addi	s7,s7,-1022 # 6a38 <malloc+0xfa0>
    1e3e:	a091                	j	1e82 <linkunlink+0xac>
    printf("%s: fork failed\n", s);
    1e40:	85a6                	mv	a1,s1
    1e42:	00005517          	auipc	a0,0x5
    1e46:	99e50513          	addi	a0,a0,-1634 # 67e0 <malloc+0xd48>
    1e4a:	00004097          	auipc	ra,0x4
    1e4e:	b8e080e7          	jalr	-1138(ra) # 59d8 <printf>
    exit(1);
    1e52:	4505                	li	a0,1
    1e54:	00004097          	auipc	ra,0x4
    1e58:	80c080e7          	jalr	-2036(ra) # 5660 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1e5c:	20200593          	li	a1,514
    1e60:	8556                	mv	a0,s5
    1e62:	00004097          	auipc	ra,0x4
    1e66:	83e080e7          	jalr	-1986(ra) # 56a0 <open>
    1e6a:	00004097          	auipc	ra,0x4
    1e6e:	81e080e7          	jalr	-2018(ra) # 5688 <close>
    1e72:	a031                	j	1e7e <linkunlink+0xa8>
      unlink("x");
    1e74:	8556                	mv	a0,s5
    1e76:	00004097          	auipc	ra,0x4
    1e7a:	83a080e7          	jalr	-1990(ra) # 56b0 <unlink>
  for(i = 0; i < 100; i++){
    1e7e:	34fd                	addiw	s1,s1,-1
    1e80:	c09d                	beqz	s1,1ea6 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1e82:	033c87bb          	mulw	a5,s9,s3
    1e86:	012787bb          	addw	a5,a5,s2
    1e8a:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1e8e:	0347f7bb          	remuw	a5,a5,s4
    1e92:	d7e9                	beqz	a5,1e5c <linkunlink+0x86>
    } else if((x % 3) == 1){
    1e94:	ff6790e3          	bne	a5,s6,1e74 <linkunlink+0x9e>
      link("cat", "x");
    1e98:	85d6                	mv	a1,s5
    1e9a:	855e                	mv	a0,s7
    1e9c:	00004097          	auipc	ra,0x4
    1ea0:	824080e7          	jalr	-2012(ra) # 56c0 <link>
    1ea4:	bfe9                	j	1e7e <linkunlink+0xa8>
  if(pid)
    1ea6:	020c0463          	beqz	s8,1ece <linkunlink+0xf8>
    wait(0);
    1eaa:	4501                	li	a0,0
    1eac:	00003097          	auipc	ra,0x3
    1eb0:	7bc080e7          	jalr	1980(ra) # 5668 <wait>
}
    1eb4:	60e6                	ld	ra,88(sp)
    1eb6:	6446                	ld	s0,80(sp)
    1eb8:	64a6                	ld	s1,72(sp)
    1eba:	6906                	ld	s2,64(sp)
    1ebc:	79e2                	ld	s3,56(sp)
    1ebe:	7a42                	ld	s4,48(sp)
    1ec0:	7aa2                	ld	s5,40(sp)
    1ec2:	7b02                	ld	s6,32(sp)
    1ec4:	6be2                	ld	s7,24(sp)
    1ec6:	6c42                	ld	s8,16(sp)
    1ec8:	6ca2                	ld	s9,8(sp)
    1eca:	6125                	addi	sp,sp,96
    1ecc:	8082                	ret
    exit(0);
    1ece:	4501                	li	a0,0
    1ed0:	00003097          	auipc	ra,0x3
    1ed4:	790080e7          	jalr	1936(ra) # 5660 <exit>

0000000000001ed8 <manywrites>:
{
    1ed8:	711d                	addi	sp,sp,-96
    1eda:	ec86                	sd	ra,88(sp)
    1edc:	e8a2                	sd	s0,80(sp)
    1ede:	e4a6                	sd	s1,72(sp)
    1ee0:	e0ca                	sd	s2,64(sp)
    1ee2:	fc4e                	sd	s3,56(sp)
    1ee4:	f852                	sd	s4,48(sp)
    1ee6:	f456                	sd	s5,40(sp)
    1ee8:	f05a                	sd	s6,32(sp)
    1eea:	ec5e                	sd	s7,24(sp)
    1eec:	1080                	addi	s0,sp,96
    1eee:	8b2a                	mv	s6,a0
  for(int ci = 0; ci < nchildren; ci++){
    1ef0:	4481                	li	s1,0
    1ef2:	4991                	li	s3,4
    int pid = fork();
    1ef4:	00003097          	auipc	ra,0x3
    1ef8:	764080e7          	jalr	1892(ra) # 5658 <fork>
    1efc:	892a                	mv	s2,a0
    if(pid < 0){
    1efe:	02054963          	bltz	a0,1f30 <manywrites+0x58>
    if(pid == 0){
    1f02:	c521                	beqz	a0,1f4a <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    1f04:	2485                	addiw	s1,s1,1
    1f06:	ff3497e3          	bne	s1,s3,1ef4 <manywrites+0x1c>
    1f0a:	4491                	li	s1,4
    int st = 0;
    1f0c:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    1f10:	fa840513          	addi	a0,s0,-88
    1f14:	00003097          	auipc	ra,0x3
    1f18:	754080e7          	jalr	1876(ra) # 5668 <wait>
    if(st != 0)
    1f1c:	fa842503          	lw	a0,-88(s0)
    1f20:	ed6d                	bnez	a0,201a <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    1f22:	34fd                	addiw	s1,s1,-1
    1f24:	f4e5                	bnez	s1,1f0c <manywrites+0x34>
  exit(0);
    1f26:	4501                	li	a0,0
    1f28:	00003097          	auipc	ra,0x3
    1f2c:	738080e7          	jalr	1848(ra) # 5660 <exit>
      printf("fork failed\n");
    1f30:	00005517          	auipc	a0,0x5
    1f34:	cb850513          	addi	a0,a0,-840 # 6be8 <malloc+0x1150>
    1f38:	00004097          	auipc	ra,0x4
    1f3c:	aa0080e7          	jalr	-1376(ra) # 59d8 <printf>
      exit(1);
    1f40:	4505                	li	a0,1
    1f42:	00003097          	auipc	ra,0x3
    1f46:	71e080e7          	jalr	1822(ra) # 5660 <exit>
      name[0] = 'b';
    1f4a:	06200793          	li	a5,98
    1f4e:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    1f52:	0614879b          	addiw	a5,s1,97
    1f56:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    1f5a:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    1f5e:	fa840513          	addi	a0,s0,-88
    1f62:	00003097          	auipc	ra,0x3
    1f66:	74e080e7          	jalr	1870(ra) # 56b0 <unlink>
    1f6a:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    1f6c:	0000aa97          	auipc	s5,0xa
    1f70:	b84a8a93          	addi	s5,s5,-1148 # baf0 <buf>
        for(int i = 0; i < ci+1; i++){
    1f74:	8a4a                	mv	s4,s2
    1f76:	0204ce63          	bltz	s1,1fb2 <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    1f7a:	20200593          	li	a1,514
    1f7e:	fa840513          	addi	a0,s0,-88
    1f82:	00003097          	auipc	ra,0x3
    1f86:	71e080e7          	jalr	1822(ra) # 56a0 <open>
    1f8a:	89aa                	mv	s3,a0
          if(fd < 0){
    1f8c:	04054763          	bltz	a0,1fda <manywrites+0x102>
          int cc = write(fd, buf, sz);
    1f90:	660d                	lui	a2,0x3
    1f92:	85d6                	mv	a1,s5
    1f94:	00003097          	auipc	ra,0x3
    1f98:	6ec080e7          	jalr	1772(ra) # 5680 <write>
          if(cc != sz){
    1f9c:	678d                	lui	a5,0x3
    1f9e:	04f51e63          	bne	a0,a5,1ffa <manywrites+0x122>
          close(fd);
    1fa2:	854e                	mv	a0,s3
    1fa4:	00003097          	auipc	ra,0x3
    1fa8:	6e4080e7          	jalr	1764(ra) # 5688 <close>
        for(int i = 0; i < ci+1; i++){
    1fac:	2a05                	addiw	s4,s4,1
    1fae:	fd44d6e3          	ble	s4,s1,1f7a <manywrites+0xa2>
        unlink(name);
    1fb2:	fa840513          	addi	a0,s0,-88
    1fb6:	00003097          	auipc	ra,0x3
    1fba:	6fa080e7          	jalr	1786(ra) # 56b0 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    1fbe:	3bfd                	addiw	s7,s7,-1
    1fc0:	fa0b9ae3          	bnez	s7,1f74 <manywrites+0x9c>
      unlink(name);
    1fc4:	fa840513          	addi	a0,s0,-88
    1fc8:	00003097          	auipc	ra,0x3
    1fcc:	6e8080e7          	jalr	1768(ra) # 56b0 <unlink>
      exit(0);
    1fd0:	4501                	li	a0,0
    1fd2:	00003097          	auipc	ra,0x3
    1fd6:	68e080e7          	jalr	1678(ra) # 5660 <exit>
            printf("%s: cannot create %s\n", s, name);
    1fda:	fa840613          	addi	a2,s0,-88
    1fde:	85da                	mv	a1,s6
    1fe0:	00005517          	auipc	a0,0x5
    1fe4:	a6050513          	addi	a0,a0,-1440 # 6a40 <malloc+0xfa8>
    1fe8:	00004097          	auipc	ra,0x4
    1fec:	9f0080e7          	jalr	-1552(ra) # 59d8 <printf>
            exit(1);
    1ff0:	4505                	li	a0,1
    1ff2:	00003097          	auipc	ra,0x3
    1ff6:	66e080e7          	jalr	1646(ra) # 5660 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    1ffa:	86aa                	mv	a3,a0
    1ffc:	660d                	lui	a2,0x3
    1ffe:	85da                	mv	a1,s6
    2000:	00004517          	auipc	a0,0x4
    2004:	05850513          	addi	a0,a0,88 # 6058 <malloc+0x5c0>
    2008:	00004097          	auipc	ra,0x4
    200c:	9d0080e7          	jalr	-1584(ra) # 59d8 <printf>
            exit(1);
    2010:	4505                	li	a0,1
    2012:	00003097          	auipc	ra,0x3
    2016:	64e080e7          	jalr	1614(ra) # 5660 <exit>
      exit(st);
    201a:	00003097          	auipc	ra,0x3
    201e:	646080e7          	jalr	1606(ra) # 5660 <exit>

0000000000002022 <forktest>:
{
    2022:	7179                	addi	sp,sp,-48
    2024:	f406                	sd	ra,40(sp)
    2026:	f022                	sd	s0,32(sp)
    2028:	ec26                	sd	s1,24(sp)
    202a:	e84a                	sd	s2,16(sp)
    202c:	e44e                	sd	s3,8(sp)
    202e:	1800                	addi	s0,sp,48
    2030:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    2032:	4481                	li	s1,0
    2034:	3e800913          	li	s2,1000
    pid = fork();
    2038:	00003097          	auipc	ra,0x3
    203c:	620080e7          	jalr	1568(ra) # 5658 <fork>
    if(pid < 0)
    2040:	02054863          	bltz	a0,2070 <forktest+0x4e>
    if(pid == 0)
    2044:	c115                	beqz	a0,2068 <forktest+0x46>
  for(n=0; n<N; n++){
    2046:	2485                	addiw	s1,s1,1
    2048:	ff2498e3          	bne	s1,s2,2038 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    204c:	85ce                	mv	a1,s3
    204e:	00005517          	auipc	a0,0x5
    2052:	a2250513          	addi	a0,a0,-1502 # 6a70 <malloc+0xfd8>
    2056:	00004097          	auipc	ra,0x4
    205a:	982080e7          	jalr	-1662(ra) # 59d8 <printf>
    exit(1);
    205e:	4505                	li	a0,1
    2060:	00003097          	auipc	ra,0x3
    2064:	600080e7          	jalr	1536(ra) # 5660 <exit>
      exit(0);
    2068:	00003097          	auipc	ra,0x3
    206c:	5f8080e7          	jalr	1528(ra) # 5660 <exit>
  if (n == 0) {
    2070:	cc9d                	beqz	s1,20ae <forktest+0x8c>
  if(n == N){
    2072:	3e800793          	li	a5,1000
    2076:	fcf48be3          	beq	s1,a5,204c <forktest+0x2a>
  for(; n > 0; n--){
    207a:	00905b63          	blez	s1,2090 <forktest+0x6e>
    if(wait(0) < 0){
    207e:	4501                	li	a0,0
    2080:	00003097          	auipc	ra,0x3
    2084:	5e8080e7          	jalr	1512(ra) # 5668 <wait>
    2088:	04054163          	bltz	a0,20ca <forktest+0xa8>
  for(; n > 0; n--){
    208c:	34fd                	addiw	s1,s1,-1
    208e:	f8e5                	bnez	s1,207e <forktest+0x5c>
  if(wait(0) != -1){
    2090:	4501                	li	a0,0
    2092:	00003097          	auipc	ra,0x3
    2096:	5d6080e7          	jalr	1494(ra) # 5668 <wait>
    209a:	57fd                	li	a5,-1
    209c:	04f51563          	bne	a0,a5,20e6 <forktest+0xc4>
}
    20a0:	70a2                	ld	ra,40(sp)
    20a2:	7402                	ld	s0,32(sp)
    20a4:	64e2                	ld	s1,24(sp)
    20a6:	6942                	ld	s2,16(sp)
    20a8:	69a2                	ld	s3,8(sp)
    20aa:	6145                	addi	sp,sp,48
    20ac:	8082                	ret
    printf("%s: no fork at all!\n", s);
    20ae:	85ce                	mv	a1,s3
    20b0:	00005517          	auipc	a0,0x5
    20b4:	9a850513          	addi	a0,a0,-1624 # 6a58 <malloc+0xfc0>
    20b8:	00004097          	auipc	ra,0x4
    20bc:	920080e7          	jalr	-1760(ra) # 59d8 <printf>
    exit(1);
    20c0:	4505                	li	a0,1
    20c2:	00003097          	auipc	ra,0x3
    20c6:	59e080e7          	jalr	1438(ra) # 5660 <exit>
      printf("%s: wait stopped early\n", s);
    20ca:	85ce                	mv	a1,s3
    20cc:	00005517          	auipc	a0,0x5
    20d0:	9cc50513          	addi	a0,a0,-1588 # 6a98 <malloc+0x1000>
    20d4:	00004097          	auipc	ra,0x4
    20d8:	904080e7          	jalr	-1788(ra) # 59d8 <printf>
      exit(1);
    20dc:	4505                	li	a0,1
    20de:	00003097          	auipc	ra,0x3
    20e2:	582080e7          	jalr	1410(ra) # 5660 <exit>
    printf("%s: wait got too many\n", s);
    20e6:	85ce                	mv	a1,s3
    20e8:	00005517          	auipc	a0,0x5
    20ec:	9c850513          	addi	a0,a0,-1592 # 6ab0 <malloc+0x1018>
    20f0:	00004097          	auipc	ra,0x4
    20f4:	8e8080e7          	jalr	-1816(ra) # 59d8 <printf>
    exit(1);
    20f8:	4505                	li	a0,1
    20fa:	00003097          	auipc	ra,0x3
    20fe:	566080e7          	jalr	1382(ra) # 5660 <exit>

0000000000002102 <kernmem>:
{
    2102:	715d                	addi	sp,sp,-80
    2104:	e486                	sd	ra,72(sp)
    2106:	e0a2                	sd	s0,64(sp)
    2108:	fc26                	sd	s1,56(sp)
    210a:	f84a                	sd	s2,48(sp)
    210c:	f44e                	sd	s3,40(sp)
    210e:	f052                	sd	s4,32(sp)
    2110:	ec56                	sd	s5,24(sp)
    2112:	0880                	addi	s0,sp,80
    2114:	8aaa                	mv	s5,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2116:	4485                	li	s1,1
    2118:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    211a:	5a7d                	li	s4,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    211c:	69b1                	lui	s3,0xc
    211e:	35098993          	addi	s3,s3,848 # c350 <buf+0x860>
    2122:	1003d937          	lui	s2,0x1003d
    2126:	090e                	slli	s2,s2,0x3
    2128:	48090913          	addi	s2,s2,1152 # 1003d480 <_end+0x1002e980>
    pid = fork();
    212c:	00003097          	auipc	ra,0x3
    2130:	52c080e7          	jalr	1324(ra) # 5658 <fork>
    if(pid < 0){
    2134:	02054963          	bltz	a0,2166 <kernmem+0x64>
    if(pid == 0){
    2138:	c529                	beqz	a0,2182 <kernmem+0x80>
    wait(&xstatus);
    213a:	fbc40513          	addi	a0,s0,-68
    213e:	00003097          	auipc	ra,0x3
    2142:	52a080e7          	jalr	1322(ra) # 5668 <wait>
    if(xstatus != -1)  // did kernel kill child?
    2146:	fbc42783          	lw	a5,-68(s0)
    214a:	05479d63          	bne	a5,s4,21a4 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    214e:	94ce                	add	s1,s1,s3
    2150:	fd249ee3          	bne	s1,s2,212c <kernmem+0x2a>
}
    2154:	60a6                	ld	ra,72(sp)
    2156:	6406                	ld	s0,64(sp)
    2158:	74e2                	ld	s1,56(sp)
    215a:	7942                	ld	s2,48(sp)
    215c:	79a2                	ld	s3,40(sp)
    215e:	7a02                	ld	s4,32(sp)
    2160:	6ae2                	ld	s5,24(sp)
    2162:	6161                	addi	sp,sp,80
    2164:	8082                	ret
      printf("%s: fork failed\n", s);
    2166:	85d6                	mv	a1,s5
    2168:	00004517          	auipc	a0,0x4
    216c:	67850513          	addi	a0,a0,1656 # 67e0 <malloc+0xd48>
    2170:	00004097          	auipc	ra,0x4
    2174:	868080e7          	jalr	-1944(ra) # 59d8 <printf>
      exit(1);
    2178:	4505                	li	a0,1
    217a:	00003097          	auipc	ra,0x3
    217e:	4e6080e7          	jalr	1254(ra) # 5660 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    2182:	0004c683          	lbu	a3,0(s1)
    2186:	8626                	mv	a2,s1
    2188:	85d6                	mv	a1,s5
    218a:	00005517          	auipc	a0,0x5
    218e:	93e50513          	addi	a0,a0,-1730 # 6ac8 <malloc+0x1030>
    2192:	00004097          	auipc	ra,0x4
    2196:	846080e7          	jalr	-1978(ra) # 59d8 <printf>
      exit(1);
    219a:	4505                	li	a0,1
    219c:	00003097          	auipc	ra,0x3
    21a0:	4c4080e7          	jalr	1220(ra) # 5660 <exit>
      exit(1);
    21a4:	4505                	li	a0,1
    21a6:	00003097          	auipc	ra,0x3
    21aa:	4ba080e7          	jalr	1210(ra) # 5660 <exit>

00000000000021ae <bigargtest>:
{
    21ae:	7179                	addi	sp,sp,-48
    21b0:	f406                	sd	ra,40(sp)
    21b2:	f022                	sd	s0,32(sp)
    21b4:	ec26                	sd	s1,24(sp)
    21b6:	1800                	addi	s0,sp,48
    21b8:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    21ba:	00005517          	auipc	a0,0x5
    21be:	92e50513          	addi	a0,a0,-1746 # 6ae8 <malloc+0x1050>
    21c2:	00003097          	auipc	ra,0x3
    21c6:	4ee080e7          	jalr	1262(ra) # 56b0 <unlink>
  pid = fork();
    21ca:	00003097          	auipc	ra,0x3
    21ce:	48e080e7          	jalr	1166(ra) # 5658 <fork>
  if(pid == 0){
    21d2:	c121                	beqz	a0,2212 <bigargtest+0x64>
  } else if(pid < 0){
    21d4:	0a054063          	bltz	a0,2274 <bigargtest+0xc6>
  wait(&xstatus);
    21d8:	fdc40513          	addi	a0,s0,-36
    21dc:	00003097          	auipc	ra,0x3
    21e0:	48c080e7          	jalr	1164(ra) # 5668 <wait>
  if(xstatus != 0)
    21e4:	fdc42503          	lw	a0,-36(s0)
    21e8:	e545                	bnez	a0,2290 <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    21ea:	4581                	li	a1,0
    21ec:	00005517          	auipc	a0,0x5
    21f0:	8fc50513          	addi	a0,a0,-1796 # 6ae8 <malloc+0x1050>
    21f4:	00003097          	auipc	ra,0x3
    21f8:	4ac080e7          	jalr	1196(ra) # 56a0 <open>
  if(fd < 0){
    21fc:	08054e63          	bltz	a0,2298 <bigargtest+0xea>
  close(fd);
    2200:	00003097          	auipc	ra,0x3
    2204:	488080e7          	jalr	1160(ra) # 5688 <close>
}
    2208:	70a2                	ld	ra,40(sp)
    220a:	7402                	ld	s0,32(sp)
    220c:	64e2                	ld	s1,24(sp)
    220e:	6145                	addi	sp,sp,48
    2210:	8082                	ret
    2212:	00006797          	auipc	a5,0x6
    2216:	0c678793          	addi	a5,a5,198 # 82d8 <args.1854>
    221a:	00006697          	auipc	a3,0x6
    221e:	1b668693          	addi	a3,a3,438 # 83d0 <args.1854+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    2222:	00005717          	auipc	a4,0x5
    2226:	8d670713          	addi	a4,a4,-1834 # 6af8 <malloc+0x1060>
    222a:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    222c:	07a1                	addi	a5,a5,8
    222e:	fed79ee3          	bne	a5,a3,222a <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    2232:	00006597          	auipc	a1,0x6
    2236:	0a658593          	addi	a1,a1,166 # 82d8 <args.1854>
    223a:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    223e:	00004517          	auipc	a0,0x4
    2242:	d4a50513          	addi	a0,a0,-694 # 5f88 <malloc+0x4f0>
    2246:	00003097          	auipc	ra,0x3
    224a:	452080e7          	jalr	1106(ra) # 5698 <exec>
    fd = open("bigarg-ok", O_CREATE);
    224e:	20000593          	li	a1,512
    2252:	00005517          	auipc	a0,0x5
    2256:	89650513          	addi	a0,a0,-1898 # 6ae8 <malloc+0x1050>
    225a:	00003097          	auipc	ra,0x3
    225e:	446080e7          	jalr	1094(ra) # 56a0 <open>
    close(fd);
    2262:	00003097          	auipc	ra,0x3
    2266:	426080e7          	jalr	1062(ra) # 5688 <close>
    exit(0);
    226a:	4501                	li	a0,0
    226c:	00003097          	auipc	ra,0x3
    2270:	3f4080e7          	jalr	1012(ra) # 5660 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    2274:	85a6                	mv	a1,s1
    2276:	00005517          	auipc	a0,0x5
    227a:	96250513          	addi	a0,a0,-1694 # 6bd8 <malloc+0x1140>
    227e:	00003097          	auipc	ra,0x3
    2282:	75a080e7          	jalr	1882(ra) # 59d8 <printf>
    exit(1);
    2286:	4505                	li	a0,1
    2288:	00003097          	auipc	ra,0x3
    228c:	3d8080e7          	jalr	984(ra) # 5660 <exit>
    exit(xstatus);
    2290:	00003097          	auipc	ra,0x3
    2294:	3d0080e7          	jalr	976(ra) # 5660 <exit>
    printf("%s: bigarg test failed!\n", s);
    2298:	85a6                	mv	a1,s1
    229a:	00005517          	auipc	a0,0x5
    229e:	95e50513          	addi	a0,a0,-1698 # 6bf8 <malloc+0x1160>
    22a2:	00003097          	auipc	ra,0x3
    22a6:	736080e7          	jalr	1846(ra) # 59d8 <printf>
    exit(1);
    22aa:	4505                	li	a0,1
    22ac:	00003097          	auipc	ra,0x3
    22b0:	3b4080e7          	jalr	948(ra) # 5660 <exit>

00000000000022b4 <stacktest>:
{
    22b4:	7179                	addi	sp,sp,-48
    22b6:	f406                	sd	ra,40(sp)
    22b8:	f022                	sd	s0,32(sp)
    22ba:	ec26                	sd	s1,24(sp)
    22bc:	1800                	addi	s0,sp,48
    22be:	84aa                	mv	s1,a0
  pid = fork();
    22c0:	00003097          	auipc	ra,0x3
    22c4:	398080e7          	jalr	920(ra) # 5658 <fork>
  if(pid == 0) {
    22c8:	c115                	beqz	a0,22ec <stacktest+0x38>
  } else if(pid < 0){
    22ca:	04054463          	bltz	a0,2312 <stacktest+0x5e>
  wait(&xstatus);
    22ce:	fdc40513          	addi	a0,s0,-36
    22d2:	00003097          	auipc	ra,0x3
    22d6:	396080e7          	jalr	918(ra) # 5668 <wait>
  if(xstatus == -1)  // kernel killed child?
    22da:	fdc42503          	lw	a0,-36(s0)
    22de:	57fd                	li	a5,-1
    22e0:	04f50763          	beq	a0,a5,232e <stacktest+0x7a>
    exit(xstatus);
    22e4:	00003097          	auipc	ra,0x3
    22e8:	37c080e7          	jalr	892(ra) # 5660 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    22ec:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    22ee:	77fd                	lui	a5,0xfffff
    22f0:	97ba                	add	a5,a5,a4
    22f2:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <_end+0xffffffffffff0500>
    22f6:	85a6                	mv	a1,s1
    22f8:	00005517          	auipc	a0,0x5
    22fc:	92050513          	addi	a0,a0,-1760 # 6c18 <malloc+0x1180>
    2300:	00003097          	auipc	ra,0x3
    2304:	6d8080e7          	jalr	1752(ra) # 59d8 <printf>
    exit(1);
    2308:	4505                	li	a0,1
    230a:	00003097          	auipc	ra,0x3
    230e:	356080e7          	jalr	854(ra) # 5660 <exit>
    printf("%s: fork failed\n", s);
    2312:	85a6                	mv	a1,s1
    2314:	00004517          	auipc	a0,0x4
    2318:	4cc50513          	addi	a0,a0,1228 # 67e0 <malloc+0xd48>
    231c:	00003097          	auipc	ra,0x3
    2320:	6bc080e7          	jalr	1724(ra) # 59d8 <printf>
    exit(1);
    2324:	4505                	li	a0,1
    2326:	00003097          	auipc	ra,0x3
    232a:	33a080e7          	jalr	826(ra) # 5660 <exit>
    exit(0);
    232e:	4501                	li	a0,0
    2330:	00003097          	auipc	ra,0x3
    2334:	330080e7          	jalr	816(ra) # 5660 <exit>

0000000000002338 <copyinstr3>:
{
    2338:	7179                	addi	sp,sp,-48
    233a:	f406                	sd	ra,40(sp)
    233c:	f022                	sd	s0,32(sp)
    233e:	ec26                	sd	s1,24(sp)
    2340:	1800                	addi	s0,sp,48
  sbrk(8192);
    2342:	6509                	lui	a0,0x2
    2344:	00003097          	auipc	ra,0x3
    2348:	3a4080e7          	jalr	932(ra) # 56e8 <sbrk>
  uint64 top = (uint64) sbrk(0);
    234c:	4501                	li	a0,0
    234e:	00003097          	auipc	ra,0x3
    2352:	39a080e7          	jalr	922(ra) # 56e8 <sbrk>
  if((top % PGSIZE) != 0){
    2356:	6785                	lui	a5,0x1
    2358:	17fd                	addi	a5,a5,-1
    235a:	8fe9                	and	a5,a5,a0
    235c:	e3d1                	bnez	a5,23e0 <copyinstr3+0xa8>
  top = (uint64) sbrk(0);
    235e:	4501                	li	a0,0
    2360:	00003097          	auipc	ra,0x3
    2364:	388080e7          	jalr	904(ra) # 56e8 <sbrk>
  if(top % PGSIZE){
    2368:	6785                	lui	a5,0x1
    236a:	17fd                	addi	a5,a5,-1
    236c:	8fe9                	and	a5,a5,a0
    236e:	e7c1                	bnez	a5,23f6 <copyinstr3+0xbe>
  char *b = (char *) (top - 1);
    2370:	fff50493          	addi	s1,a0,-1 # 1fff <manywrites+0x127>
  *b = 'x';
    2374:	07800793          	li	a5,120
    2378:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    237c:	8526                	mv	a0,s1
    237e:	00003097          	auipc	ra,0x3
    2382:	332080e7          	jalr	818(ra) # 56b0 <unlink>
  if(ret != -1){
    2386:	57fd                	li	a5,-1
    2388:	08f51463          	bne	a0,a5,2410 <copyinstr3+0xd8>
  int fd = open(b, O_CREATE | O_WRONLY);
    238c:	20100593          	li	a1,513
    2390:	8526                	mv	a0,s1
    2392:	00003097          	auipc	ra,0x3
    2396:	30e080e7          	jalr	782(ra) # 56a0 <open>
  if(fd != -1){
    239a:	57fd                	li	a5,-1
    239c:	08f51963          	bne	a0,a5,242e <copyinstr3+0xf6>
  ret = link(b, b);
    23a0:	85a6                	mv	a1,s1
    23a2:	8526                	mv	a0,s1
    23a4:	00003097          	auipc	ra,0x3
    23a8:	31c080e7          	jalr	796(ra) # 56c0 <link>
  if(ret != -1){
    23ac:	57fd                	li	a5,-1
    23ae:	08f51f63          	bne	a0,a5,244c <copyinstr3+0x114>
  char *args[] = { "xx", 0 };
    23b2:	00005797          	auipc	a5,0x5
    23b6:	50e78793          	addi	a5,a5,1294 # 78c0 <malloc+0x1e28>
    23ba:	fcf43823          	sd	a5,-48(s0)
    23be:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    23c2:	fd040593          	addi	a1,s0,-48
    23c6:	8526                	mv	a0,s1
    23c8:	00003097          	auipc	ra,0x3
    23cc:	2d0080e7          	jalr	720(ra) # 5698 <exec>
  if(ret != -1){
    23d0:	57fd                	li	a5,-1
    23d2:	08f51d63          	bne	a0,a5,246c <copyinstr3+0x134>
}
    23d6:	70a2                	ld	ra,40(sp)
    23d8:	7402                	ld	s0,32(sp)
    23da:	64e2                	ld	s1,24(sp)
    23dc:	6145                	addi	sp,sp,48
    23de:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    23e0:	6785                	lui	a5,0x1
    23e2:	17fd                	addi	a5,a5,-1
    23e4:	8d7d                	and	a0,a0,a5
    23e6:	6785                	lui	a5,0x1
    23e8:	40a7853b          	subw	a0,a5,a0
    23ec:	00003097          	auipc	ra,0x3
    23f0:	2fc080e7          	jalr	764(ra) # 56e8 <sbrk>
    23f4:	b7ad                	j	235e <copyinstr3+0x26>
    printf("oops\n");
    23f6:	00005517          	auipc	a0,0x5
    23fa:	84a50513          	addi	a0,a0,-1974 # 6c40 <malloc+0x11a8>
    23fe:	00003097          	auipc	ra,0x3
    2402:	5da080e7          	jalr	1498(ra) # 59d8 <printf>
    exit(1);
    2406:	4505                	li	a0,1
    2408:	00003097          	auipc	ra,0x3
    240c:	258080e7          	jalr	600(ra) # 5660 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    2410:	862a                	mv	a2,a0
    2412:	85a6                	mv	a1,s1
    2414:	00004517          	auipc	a0,0x4
    2418:	2ec50513          	addi	a0,a0,748 # 6700 <malloc+0xc68>
    241c:	00003097          	auipc	ra,0x3
    2420:	5bc080e7          	jalr	1468(ra) # 59d8 <printf>
    exit(1);
    2424:	4505                	li	a0,1
    2426:	00003097          	auipc	ra,0x3
    242a:	23a080e7          	jalr	570(ra) # 5660 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    242e:	862a                	mv	a2,a0
    2430:	85a6                	mv	a1,s1
    2432:	00004517          	auipc	a0,0x4
    2436:	2ee50513          	addi	a0,a0,750 # 6720 <malloc+0xc88>
    243a:	00003097          	auipc	ra,0x3
    243e:	59e080e7          	jalr	1438(ra) # 59d8 <printf>
    exit(1);
    2442:	4505                	li	a0,1
    2444:	00003097          	auipc	ra,0x3
    2448:	21c080e7          	jalr	540(ra) # 5660 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    244c:	86aa                	mv	a3,a0
    244e:	8626                	mv	a2,s1
    2450:	85a6                	mv	a1,s1
    2452:	00004517          	auipc	a0,0x4
    2456:	2ee50513          	addi	a0,a0,750 # 6740 <malloc+0xca8>
    245a:	00003097          	auipc	ra,0x3
    245e:	57e080e7          	jalr	1406(ra) # 59d8 <printf>
    exit(1);
    2462:	4505                	li	a0,1
    2464:	00003097          	auipc	ra,0x3
    2468:	1fc080e7          	jalr	508(ra) # 5660 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    246c:	567d                	li	a2,-1
    246e:	85a6                	mv	a1,s1
    2470:	00004517          	auipc	a0,0x4
    2474:	2f850513          	addi	a0,a0,760 # 6768 <malloc+0xcd0>
    2478:	00003097          	auipc	ra,0x3
    247c:	560080e7          	jalr	1376(ra) # 59d8 <printf>
    exit(1);
    2480:	4505                	li	a0,1
    2482:	00003097          	auipc	ra,0x3
    2486:	1de080e7          	jalr	478(ra) # 5660 <exit>

000000000000248a <rwsbrk>:
{
    248a:	1101                	addi	sp,sp,-32
    248c:	ec06                	sd	ra,24(sp)
    248e:	e822                	sd	s0,16(sp)
    2490:	e426                	sd	s1,8(sp)
    2492:	e04a                	sd	s2,0(sp)
    2494:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    2496:	6509                	lui	a0,0x2
    2498:	00003097          	auipc	ra,0x3
    249c:	250080e7          	jalr	592(ra) # 56e8 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    24a0:	57fd                	li	a5,-1
    24a2:	06f50263          	beq	a0,a5,2506 <rwsbrk+0x7c>
    24a6:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    24a8:	7579                	lui	a0,0xffffe
    24aa:	00003097          	auipc	ra,0x3
    24ae:	23e080e7          	jalr	574(ra) # 56e8 <sbrk>
    24b2:	57fd                	li	a5,-1
    24b4:	06f50663          	beq	a0,a5,2520 <rwsbrk+0x96>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    24b8:	20100593          	li	a1,513
    24bc:	00004517          	auipc	a0,0x4
    24c0:	7c450513          	addi	a0,a0,1988 # 6c80 <malloc+0x11e8>
    24c4:	00003097          	auipc	ra,0x3
    24c8:	1dc080e7          	jalr	476(ra) # 56a0 <open>
    24cc:	892a                	mv	s2,a0
  if(fd < 0){
    24ce:	06054663          	bltz	a0,253a <rwsbrk+0xb0>
  n = write(fd, (void*)(a+4096), 1024);
    24d2:	6785                	lui	a5,0x1
    24d4:	94be                	add	s1,s1,a5
    24d6:	40000613          	li	a2,1024
    24da:	85a6                	mv	a1,s1
    24dc:	00003097          	auipc	ra,0x3
    24e0:	1a4080e7          	jalr	420(ra) # 5680 <write>
  if(n >= 0){
    24e4:	06054863          	bltz	a0,2554 <rwsbrk+0xca>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    24e8:	862a                	mv	a2,a0
    24ea:	85a6                	mv	a1,s1
    24ec:	00004517          	auipc	a0,0x4
    24f0:	7b450513          	addi	a0,a0,1972 # 6ca0 <malloc+0x1208>
    24f4:	00003097          	auipc	ra,0x3
    24f8:	4e4080e7          	jalr	1252(ra) # 59d8 <printf>
    exit(1);
    24fc:	4505                	li	a0,1
    24fe:	00003097          	auipc	ra,0x3
    2502:	162080e7          	jalr	354(ra) # 5660 <exit>
    printf("sbrk(rwsbrk) failed\n");
    2506:	00004517          	auipc	a0,0x4
    250a:	74250513          	addi	a0,a0,1858 # 6c48 <malloc+0x11b0>
    250e:	00003097          	auipc	ra,0x3
    2512:	4ca080e7          	jalr	1226(ra) # 59d8 <printf>
    exit(1);
    2516:	4505                	li	a0,1
    2518:	00003097          	auipc	ra,0x3
    251c:	148080e7          	jalr	328(ra) # 5660 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    2520:	00004517          	auipc	a0,0x4
    2524:	74050513          	addi	a0,a0,1856 # 6c60 <malloc+0x11c8>
    2528:	00003097          	auipc	ra,0x3
    252c:	4b0080e7          	jalr	1200(ra) # 59d8 <printf>
    exit(1);
    2530:	4505                	li	a0,1
    2532:	00003097          	auipc	ra,0x3
    2536:	12e080e7          	jalr	302(ra) # 5660 <exit>
    printf("open(rwsbrk) failed\n");
    253a:	00004517          	auipc	a0,0x4
    253e:	74e50513          	addi	a0,a0,1870 # 6c88 <malloc+0x11f0>
    2542:	00003097          	auipc	ra,0x3
    2546:	496080e7          	jalr	1174(ra) # 59d8 <printf>
    exit(1);
    254a:	4505                	li	a0,1
    254c:	00003097          	auipc	ra,0x3
    2550:	114080e7          	jalr	276(ra) # 5660 <exit>
  close(fd);
    2554:	854a                	mv	a0,s2
    2556:	00003097          	auipc	ra,0x3
    255a:	132080e7          	jalr	306(ra) # 5688 <close>
  unlink("rwsbrk");
    255e:	00004517          	auipc	a0,0x4
    2562:	72250513          	addi	a0,a0,1826 # 6c80 <malloc+0x11e8>
    2566:	00003097          	auipc	ra,0x3
    256a:	14a080e7          	jalr	330(ra) # 56b0 <unlink>
  fd = open("README", O_RDONLY);
    256e:	4581                	li	a1,0
    2570:	00004517          	auipc	a0,0x4
    2574:	bc050513          	addi	a0,a0,-1088 # 6130 <malloc+0x698>
    2578:	00003097          	auipc	ra,0x3
    257c:	128080e7          	jalr	296(ra) # 56a0 <open>
    2580:	892a                	mv	s2,a0
  if(fd < 0){
    2582:	02054963          	bltz	a0,25b4 <rwsbrk+0x12a>
  n = read(fd, (void*)(a+4096), 10);
    2586:	4629                	li	a2,10
    2588:	85a6                	mv	a1,s1
    258a:	00003097          	auipc	ra,0x3
    258e:	0ee080e7          	jalr	238(ra) # 5678 <read>
  if(n >= 0){
    2592:	02054e63          	bltz	a0,25ce <rwsbrk+0x144>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    2596:	862a                	mv	a2,a0
    2598:	85a6                	mv	a1,s1
    259a:	00004517          	auipc	a0,0x4
    259e:	73650513          	addi	a0,a0,1846 # 6cd0 <malloc+0x1238>
    25a2:	00003097          	auipc	ra,0x3
    25a6:	436080e7          	jalr	1078(ra) # 59d8 <printf>
    exit(1);
    25aa:	4505                	li	a0,1
    25ac:	00003097          	auipc	ra,0x3
    25b0:	0b4080e7          	jalr	180(ra) # 5660 <exit>
    printf("open(rwsbrk) failed\n");
    25b4:	00004517          	auipc	a0,0x4
    25b8:	6d450513          	addi	a0,a0,1748 # 6c88 <malloc+0x11f0>
    25bc:	00003097          	auipc	ra,0x3
    25c0:	41c080e7          	jalr	1052(ra) # 59d8 <printf>
    exit(1);
    25c4:	4505                	li	a0,1
    25c6:	00003097          	auipc	ra,0x3
    25ca:	09a080e7          	jalr	154(ra) # 5660 <exit>
  close(fd);
    25ce:	854a                	mv	a0,s2
    25d0:	00003097          	auipc	ra,0x3
    25d4:	0b8080e7          	jalr	184(ra) # 5688 <close>
  exit(0);
    25d8:	4501                	li	a0,0
    25da:	00003097          	auipc	ra,0x3
    25de:	086080e7          	jalr	134(ra) # 5660 <exit>

00000000000025e2 <sbrkbasic>:
{
    25e2:	715d                	addi	sp,sp,-80
    25e4:	e486                	sd	ra,72(sp)
    25e6:	e0a2                	sd	s0,64(sp)
    25e8:	fc26                	sd	s1,56(sp)
    25ea:	f84a                	sd	s2,48(sp)
    25ec:	f44e                	sd	s3,40(sp)
    25ee:	f052                	sd	s4,32(sp)
    25f0:	ec56                	sd	s5,24(sp)
    25f2:	0880                	addi	s0,sp,80
    25f4:	8aaa                	mv	s5,a0
  pid = fork();
    25f6:	00003097          	auipc	ra,0x3
    25fa:	062080e7          	jalr	98(ra) # 5658 <fork>
  if(pid < 0){
    25fe:	02054c63          	bltz	a0,2636 <sbrkbasic+0x54>
  if(pid == 0){
    2602:	ed21                	bnez	a0,265a <sbrkbasic+0x78>
    a = sbrk(TOOMUCH);
    2604:	40000537          	lui	a0,0x40000
    2608:	00003097          	auipc	ra,0x3
    260c:	0e0080e7          	jalr	224(ra) # 56e8 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    2610:	57fd                	li	a5,-1
    2612:	02f50f63          	beq	a0,a5,2650 <sbrkbasic+0x6e>
    for(b = a; b < a+TOOMUCH; b += 4096){
    2616:	400007b7          	lui	a5,0x40000
    261a:	97aa                	add	a5,a5,a0
      *b = 99;
    261c:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    2620:	6705                	lui	a4,0x1
      *b = 99;
    2622:	00d50023          	sb	a3,0(a0) # 40000000 <_end+0x3fff1500>
    for(b = a; b < a+TOOMUCH; b += 4096){
    2626:	953a                	add	a0,a0,a4
    2628:	fef51de3          	bne	a0,a5,2622 <sbrkbasic+0x40>
    exit(1);
    262c:	4505                	li	a0,1
    262e:	00003097          	auipc	ra,0x3
    2632:	032080e7          	jalr	50(ra) # 5660 <exit>
    printf("fork failed in sbrkbasic\n");
    2636:	00004517          	auipc	a0,0x4
    263a:	6c250513          	addi	a0,a0,1730 # 6cf8 <malloc+0x1260>
    263e:	00003097          	auipc	ra,0x3
    2642:	39a080e7          	jalr	922(ra) # 59d8 <printf>
    exit(1);
    2646:	4505                	li	a0,1
    2648:	00003097          	auipc	ra,0x3
    264c:	018080e7          	jalr	24(ra) # 5660 <exit>
      exit(0);
    2650:	4501                	li	a0,0
    2652:	00003097          	auipc	ra,0x3
    2656:	00e080e7          	jalr	14(ra) # 5660 <exit>
  wait(&xstatus);
    265a:	fbc40513          	addi	a0,s0,-68
    265e:	00003097          	auipc	ra,0x3
    2662:	00a080e7          	jalr	10(ra) # 5668 <wait>
  if(xstatus == 1){
    2666:	fbc42703          	lw	a4,-68(s0)
    266a:	4785                	li	a5,1
    266c:	00f70e63          	beq	a4,a5,2688 <sbrkbasic+0xa6>
  a = sbrk(0);
    2670:	4501                	li	a0,0
    2672:	00003097          	auipc	ra,0x3
    2676:	076080e7          	jalr	118(ra) # 56e8 <sbrk>
    267a:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    267c:	4901                	li	s2,0
    *b = 1;
    267e:	4a05                	li	s4,1
  for(i = 0; i < 5000; i++){
    2680:	6985                	lui	s3,0x1
    2682:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x1c2>
    2686:	a005                	j	26a6 <sbrkbasic+0xc4>
    printf("%s: too much memory allocated!\n", s);
    2688:	85d6                	mv	a1,s5
    268a:	00004517          	auipc	a0,0x4
    268e:	68e50513          	addi	a0,a0,1678 # 6d18 <malloc+0x1280>
    2692:	00003097          	auipc	ra,0x3
    2696:	346080e7          	jalr	838(ra) # 59d8 <printf>
    exit(1);
    269a:	4505                	li	a0,1
    269c:	00003097          	auipc	ra,0x3
    26a0:	fc4080e7          	jalr	-60(ra) # 5660 <exit>
    a = b + 1;
    26a4:	84be                	mv	s1,a5
    b = sbrk(1);
    26a6:	4505                	li	a0,1
    26a8:	00003097          	auipc	ra,0x3
    26ac:	040080e7          	jalr	64(ra) # 56e8 <sbrk>
    if(b != a){
    26b0:	04951b63          	bne	a0,s1,2706 <sbrkbasic+0x124>
    *b = 1;
    26b4:	01448023          	sb	s4,0(s1)
    a = b + 1;
    26b8:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    26bc:	2905                	addiw	s2,s2,1
    26be:	ff3913e3          	bne	s2,s3,26a4 <sbrkbasic+0xc2>
  pid = fork();
    26c2:	00003097          	auipc	ra,0x3
    26c6:	f96080e7          	jalr	-106(ra) # 5658 <fork>
    26ca:	892a                	mv	s2,a0
  if(pid < 0){
    26cc:	04054d63          	bltz	a0,2726 <sbrkbasic+0x144>
  c = sbrk(1);
    26d0:	4505                	li	a0,1
    26d2:	00003097          	auipc	ra,0x3
    26d6:	016080e7          	jalr	22(ra) # 56e8 <sbrk>
  c = sbrk(1);
    26da:	4505                	li	a0,1
    26dc:	00003097          	auipc	ra,0x3
    26e0:	00c080e7          	jalr	12(ra) # 56e8 <sbrk>
  if(c != a + 1){
    26e4:	0489                	addi	s1,s1,2
    26e6:	04a48e63          	beq	s1,a0,2742 <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    26ea:	85d6                	mv	a1,s5
    26ec:	00004517          	auipc	a0,0x4
    26f0:	68c50513          	addi	a0,a0,1676 # 6d78 <malloc+0x12e0>
    26f4:	00003097          	auipc	ra,0x3
    26f8:	2e4080e7          	jalr	740(ra) # 59d8 <printf>
    exit(1);
    26fc:	4505                	li	a0,1
    26fe:	00003097          	auipc	ra,0x3
    2702:	f62080e7          	jalr	-158(ra) # 5660 <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    2706:	86aa                	mv	a3,a0
    2708:	8626                	mv	a2,s1
    270a:	85ca                	mv	a1,s2
    270c:	00004517          	auipc	a0,0x4
    2710:	62c50513          	addi	a0,a0,1580 # 6d38 <malloc+0x12a0>
    2714:	00003097          	auipc	ra,0x3
    2718:	2c4080e7          	jalr	708(ra) # 59d8 <printf>
      exit(1);
    271c:	4505                	li	a0,1
    271e:	00003097          	auipc	ra,0x3
    2722:	f42080e7          	jalr	-190(ra) # 5660 <exit>
    printf("%s: sbrk test fork failed\n", s);
    2726:	85d6                	mv	a1,s5
    2728:	00004517          	auipc	a0,0x4
    272c:	63050513          	addi	a0,a0,1584 # 6d58 <malloc+0x12c0>
    2730:	00003097          	auipc	ra,0x3
    2734:	2a8080e7          	jalr	680(ra) # 59d8 <printf>
    exit(1);
    2738:	4505                	li	a0,1
    273a:	00003097          	auipc	ra,0x3
    273e:	f26080e7          	jalr	-218(ra) # 5660 <exit>
  if(pid == 0)
    2742:	00091763          	bnez	s2,2750 <sbrkbasic+0x16e>
    exit(0);
    2746:	4501                	li	a0,0
    2748:	00003097          	auipc	ra,0x3
    274c:	f18080e7          	jalr	-232(ra) # 5660 <exit>
  wait(&xstatus);
    2750:	fbc40513          	addi	a0,s0,-68
    2754:	00003097          	auipc	ra,0x3
    2758:	f14080e7          	jalr	-236(ra) # 5668 <wait>
  exit(xstatus);
    275c:	fbc42503          	lw	a0,-68(s0)
    2760:	00003097          	auipc	ra,0x3
    2764:	f00080e7          	jalr	-256(ra) # 5660 <exit>

0000000000002768 <sbrkmuch>:
{
    2768:	7179                	addi	sp,sp,-48
    276a:	f406                	sd	ra,40(sp)
    276c:	f022                	sd	s0,32(sp)
    276e:	ec26                	sd	s1,24(sp)
    2770:	e84a                	sd	s2,16(sp)
    2772:	e44e                	sd	s3,8(sp)
    2774:	e052                	sd	s4,0(sp)
    2776:	1800                	addi	s0,sp,48
    2778:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    277a:	4501                	li	a0,0
    277c:	00003097          	auipc	ra,0x3
    2780:	f6c080e7          	jalr	-148(ra) # 56e8 <sbrk>
    2784:	892a                	mv	s2,a0
  a = sbrk(0);
    2786:	4501                	li	a0,0
    2788:	00003097          	auipc	ra,0x3
    278c:	f60080e7          	jalr	-160(ra) # 56e8 <sbrk>
    2790:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2792:	06400537          	lui	a0,0x6400
    2796:	9d05                	subw	a0,a0,s1
    2798:	00003097          	auipc	ra,0x3
    279c:	f50080e7          	jalr	-176(ra) # 56e8 <sbrk>
  if (p != a) {
    27a0:	0ca49763          	bne	s1,a0,286e <sbrkmuch+0x106>
  char *eee = sbrk(0);
    27a4:	4501                	li	a0,0
    27a6:	00003097          	auipc	ra,0x3
    27aa:	f42080e7          	jalr	-190(ra) # 56e8 <sbrk>
  for(char *pp = a; pp < eee; pp += 4096)
    27ae:	00a4f963          	bleu	a0,s1,27c0 <sbrkmuch+0x58>
    *pp = 1;
    27b2:	4705                	li	a4,1
  for(char *pp = a; pp < eee; pp += 4096)
    27b4:	6785                	lui	a5,0x1
    *pp = 1;
    27b6:	00e48023          	sb	a4,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    27ba:	94be                	add	s1,s1,a5
    27bc:	fea4ede3          	bltu	s1,a0,27b6 <sbrkmuch+0x4e>
  *lastaddr = 99;
    27c0:	064007b7          	lui	a5,0x6400
    27c4:	06300713          	li	a4,99
    27c8:	fee78fa3          	sb	a4,-1(a5) # 63fffff <_end+0x63f14ff>
  a = sbrk(0);
    27cc:	4501                	li	a0,0
    27ce:	00003097          	auipc	ra,0x3
    27d2:	f1a080e7          	jalr	-230(ra) # 56e8 <sbrk>
    27d6:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    27d8:	757d                	lui	a0,0xfffff
    27da:	00003097          	auipc	ra,0x3
    27de:	f0e080e7          	jalr	-242(ra) # 56e8 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    27e2:	57fd                	li	a5,-1
    27e4:	0af50363          	beq	a0,a5,288a <sbrkmuch+0x122>
  c = sbrk(0);
    27e8:	4501                	li	a0,0
    27ea:	00003097          	auipc	ra,0x3
    27ee:	efe080e7          	jalr	-258(ra) # 56e8 <sbrk>
  if(c != a - PGSIZE){
    27f2:	77fd                	lui	a5,0xfffff
    27f4:	97a6                	add	a5,a5,s1
    27f6:	0af51863          	bne	a0,a5,28a6 <sbrkmuch+0x13e>
  a = sbrk(0);
    27fa:	4501                	li	a0,0
    27fc:	00003097          	auipc	ra,0x3
    2800:	eec080e7          	jalr	-276(ra) # 56e8 <sbrk>
    2804:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2806:	6505                	lui	a0,0x1
    2808:	00003097          	auipc	ra,0x3
    280c:	ee0080e7          	jalr	-288(ra) # 56e8 <sbrk>
    2810:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    2812:	0aa49a63          	bne	s1,a0,28c6 <sbrkmuch+0x15e>
    2816:	4501                	li	a0,0
    2818:	00003097          	auipc	ra,0x3
    281c:	ed0080e7          	jalr	-304(ra) # 56e8 <sbrk>
    2820:	6785                	lui	a5,0x1
    2822:	97a6                	add	a5,a5,s1
    2824:	0af51163          	bne	a0,a5,28c6 <sbrkmuch+0x15e>
  if(*lastaddr == 99){
    2828:	064007b7          	lui	a5,0x6400
    282c:	fff7c703          	lbu	a4,-1(a5) # 63fffff <_end+0x63f14ff>
    2830:	06300793          	li	a5,99
    2834:	0af70963          	beq	a4,a5,28e6 <sbrkmuch+0x17e>
  a = sbrk(0);
    2838:	4501                	li	a0,0
    283a:	00003097          	auipc	ra,0x3
    283e:	eae080e7          	jalr	-338(ra) # 56e8 <sbrk>
    2842:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    2844:	4501                	li	a0,0
    2846:	00003097          	auipc	ra,0x3
    284a:	ea2080e7          	jalr	-350(ra) # 56e8 <sbrk>
    284e:	40a9053b          	subw	a0,s2,a0
    2852:	00003097          	auipc	ra,0x3
    2856:	e96080e7          	jalr	-362(ra) # 56e8 <sbrk>
  if(c != a){
    285a:	0aa49463          	bne	s1,a0,2902 <sbrkmuch+0x19a>
}
    285e:	70a2                	ld	ra,40(sp)
    2860:	7402                	ld	s0,32(sp)
    2862:	64e2                	ld	s1,24(sp)
    2864:	6942                	ld	s2,16(sp)
    2866:	69a2                	ld	s3,8(sp)
    2868:	6a02                	ld	s4,0(sp)
    286a:	6145                	addi	sp,sp,48
    286c:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    286e:	85ce                	mv	a1,s3
    2870:	00004517          	auipc	a0,0x4
    2874:	52850513          	addi	a0,a0,1320 # 6d98 <malloc+0x1300>
    2878:	00003097          	auipc	ra,0x3
    287c:	160080e7          	jalr	352(ra) # 59d8 <printf>
    exit(1);
    2880:	4505                	li	a0,1
    2882:	00003097          	auipc	ra,0x3
    2886:	dde080e7          	jalr	-546(ra) # 5660 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    288a:	85ce                	mv	a1,s3
    288c:	00004517          	auipc	a0,0x4
    2890:	55450513          	addi	a0,a0,1364 # 6de0 <malloc+0x1348>
    2894:	00003097          	auipc	ra,0x3
    2898:	144080e7          	jalr	324(ra) # 59d8 <printf>
    exit(1);
    289c:	4505                	li	a0,1
    289e:	00003097          	auipc	ra,0x3
    28a2:	dc2080e7          	jalr	-574(ra) # 5660 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    28a6:	86aa                	mv	a3,a0
    28a8:	8626                	mv	a2,s1
    28aa:	85ce                	mv	a1,s3
    28ac:	00004517          	auipc	a0,0x4
    28b0:	55450513          	addi	a0,a0,1364 # 6e00 <malloc+0x1368>
    28b4:	00003097          	auipc	ra,0x3
    28b8:	124080e7          	jalr	292(ra) # 59d8 <printf>
    exit(1);
    28bc:	4505                	li	a0,1
    28be:	00003097          	auipc	ra,0x3
    28c2:	da2080e7          	jalr	-606(ra) # 5660 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    28c6:	86d2                	mv	a3,s4
    28c8:	8626                	mv	a2,s1
    28ca:	85ce                	mv	a1,s3
    28cc:	00004517          	auipc	a0,0x4
    28d0:	57450513          	addi	a0,a0,1396 # 6e40 <malloc+0x13a8>
    28d4:	00003097          	auipc	ra,0x3
    28d8:	104080e7          	jalr	260(ra) # 59d8 <printf>
    exit(1);
    28dc:	4505                	li	a0,1
    28de:	00003097          	auipc	ra,0x3
    28e2:	d82080e7          	jalr	-638(ra) # 5660 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    28e6:	85ce                	mv	a1,s3
    28e8:	00004517          	auipc	a0,0x4
    28ec:	58850513          	addi	a0,a0,1416 # 6e70 <malloc+0x13d8>
    28f0:	00003097          	auipc	ra,0x3
    28f4:	0e8080e7          	jalr	232(ra) # 59d8 <printf>
    exit(1);
    28f8:	4505                	li	a0,1
    28fa:	00003097          	auipc	ra,0x3
    28fe:	d66080e7          	jalr	-666(ra) # 5660 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    2902:	86aa                	mv	a3,a0
    2904:	8626                	mv	a2,s1
    2906:	85ce                	mv	a1,s3
    2908:	00004517          	auipc	a0,0x4
    290c:	5a050513          	addi	a0,a0,1440 # 6ea8 <malloc+0x1410>
    2910:	00003097          	auipc	ra,0x3
    2914:	0c8080e7          	jalr	200(ra) # 59d8 <printf>
    exit(1);
    2918:	4505                	li	a0,1
    291a:	00003097          	auipc	ra,0x3
    291e:	d46080e7          	jalr	-698(ra) # 5660 <exit>

0000000000002922 <sbrkarg>:
{
    2922:	7179                	addi	sp,sp,-48
    2924:	f406                	sd	ra,40(sp)
    2926:	f022                	sd	s0,32(sp)
    2928:	ec26                	sd	s1,24(sp)
    292a:	e84a                	sd	s2,16(sp)
    292c:	e44e                	sd	s3,8(sp)
    292e:	1800                	addi	s0,sp,48
    2930:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2932:	6505                	lui	a0,0x1
    2934:	00003097          	auipc	ra,0x3
    2938:	db4080e7          	jalr	-588(ra) # 56e8 <sbrk>
    293c:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    293e:	20100593          	li	a1,513
    2942:	00004517          	auipc	a0,0x4
    2946:	58e50513          	addi	a0,a0,1422 # 6ed0 <malloc+0x1438>
    294a:	00003097          	auipc	ra,0x3
    294e:	d56080e7          	jalr	-682(ra) # 56a0 <open>
    2952:	84aa                	mv	s1,a0
  unlink("sbrk");
    2954:	00004517          	auipc	a0,0x4
    2958:	57c50513          	addi	a0,a0,1404 # 6ed0 <malloc+0x1438>
    295c:	00003097          	auipc	ra,0x3
    2960:	d54080e7          	jalr	-684(ra) # 56b0 <unlink>
  if(fd < 0)  {
    2964:	0404c163          	bltz	s1,29a6 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2968:	6605                	lui	a2,0x1
    296a:	85ca                	mv	a1,s2
    296c:	8526                	mv	a0,s1
    296e:	00003097          	auipc	ra,0x3
    2972:	d12080e7          	jalr	-750(ra) # 5680 <write>
    2976:	04054663          	bltz	a0,29c2 <sbrkarg+0xa0>
  close(fd);
    297a:	8526                	mv	a0,s1
    297c:	00003097          	auipc	ra,0x3
    2980:	d0c080e7          	jalr	-756(ra) # 5688 <close>
  a = sbrk(PGSIZE);
    2984:	6505                	lui	a0,0x1
    2986:	00003097          	auipc	ra,0x3
    298a:	d62080e7          	jalr	-670(ra) # 56e8 <sbrk>
  if(pipe((int *) a) != 0){
    298e:	00003097          	auipc	ra,0x3
    2992:	ce2080e7          	jalr	-798(ra) # 5670 <pipe>
    2996:	e521                	bnez	a0,29de <sbrkarg+0xbc>
}
    2998:	70a2                	ld	ra,40(sp)
    299a:	7402                	ld	s0,32(sp)
    299c:	64e2                	ld	s1,24(sp)
    299e:	6942                	ld	s2,16(sp)
    29a0:	69a2                	ld	s3,8(sp)
    29a2:	6145                	addi	sp,sp,48
    29a4:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    29a6:	85ce                	mv	a1,s3
    29a8:	00004517          	auipc	a0,0x4
    29ac:	53050513          	addi	a0,a0,1328 # 6ed8 <malloc+0x1440>
    29b0:	00003097          	auipc	ra,0x3
    29b4:	028080e7          	jalr	40(ra) # 59d8 <printf>
    exit(1);
    29b8:	4505                	li	a0,1
    29ba:	00003097          	auipc	ra,0x3
    29be:	ca6080e7          	jalr	-858(ra) # 5660 <exit>
    printf("%s: write sbrk failed\n", s);
    29c2:	85ce                	mv	a1,s3
    29c4:	00004517          	auipc	a0,0x4
    29c8:	52c50513          	addi	a0,a0,1324 # 6ef0 <malloc+0x1458>
    29cc:	00003097          	auipc	ra,0x3
    29d0:	00c080e7          	jalr	12(ra) # 59d8 <printf>
    exit(1);
    29d4:	4505                	li	a0,1
    29d6:	00003097          	auipc	ra,0x3
    29da:	c8a080e7          	jalr	-886(ra) # 5660 <exit>
    printf("%s: pipe() failed\n", s);
    29de:	85ce                	mv	a1,s3
    29e0:	00004517          	auipc	a0,0x4
    29e4:	f0850513          	addi	a0,a0,-248 # 68e8 <malloc+0xe50>
    29e8:	00003097          	auipc	ra,0x3
    29ec:	ff0080e7          	jalr	-16(ra) # 59d8 <printf>
    exit(1);
    29f0:	4505                	li	a0,1
    29f2:	00003097          	auipc	ra,0x3
    29f6:	c6e080e7          	jalr	-914(ra) # 5660 <exit>

00000000000029fa <argptest>:
{
    29fa:	1101                	addi	sp,sp,-32
    29fc:	ec06                	sd	ra,24(sp)
    29fe:	e822                	sd	s0,16(sp)
    2a00:	e426                	sd	s1,8(sp)
    2a02:	e04a                	sd	s2,0(sp)
    2a04:	1000                	addi	s0,sp,32
    2a06:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2a08:	4581                	li	a1,0
    2a0a:	00004517          	auipc	a0,0x4
    2a0e:	4fe50513          	addi	a0,a0,1278 # 6f08 <malloc+0x1470>
    2a12:	00003097          	auipc	ra,0x3
    2a16:	c8e080e7          	jalr	-882(ra) # 56a0 <open>
  if (fd < 0) {
    2a1a:	02054b63          	bltz	a0,2a50 <argptest+0x56>
    2a1e:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2a20:	4501                	li	a0,0
    2a22:	00003097          	auipc	ra,0x3
    2a26:	cc6080e7          	jalr	-826(ra) # 56e8 <sbrk>
    2a2a:	567d                	li	a2,-1
    2a2c:	fff50593          	addi	a1,a0,-1
    2a30:	8526                	mv	a0,s1
    2a32:	00003097          	auipc	ra,0x3
    2a36:	c46080e7          	jalr	-954(ra) # 5678 <read>
  close(fd);
    2a3a:	8526                	mv	a0,s1
    2a3c:	00003097          	auipc	ra,0x3
    2a40:	c4c080e7          	jalr	-948(ra) # 5688 <close>
}
    2a44:	60e2                	ld	ra,24(sp)
    2a46:	6442                	ld	s0,16(sp)
    2a48:	64a2                	ld	s1,8(sp)
    2a4a:	6902                	ld	s2,0(sp)
    2a4c:	6105                	addi	sp,sp,32
    2a4e:	8082                	ret
    printf("%s: open failed\n", s);
    2a50:	85ca                	mv	a1,s2
    2a52:	00004517          	auipc	a0,0x4
    2a56:	da650513          	addi	a0,a0,-602 # 67f8 <malloc+0xd60>
    2a5a:	00003097          	auipc	ra,0x3
    2a5e:	f7e080e7          	jalr	-130(ra) # 59d8 <printf>
    exit(1);
    2a62:	4505                	li	a0,1
    2a64:	00003097          	auipc	ra,0x3
    2a68:	bfc080e7          	jalr	-1028(ra) # 5660 <exit>

0000000000002a6c <sbrkbugs>:
{
    2a6c:	1141                	addi	sp,sp,-16
    2a6e:	e406                	sd	ra,8(sp)
    2a70:	e022                	sd	s0,0(sp)
    2a72:	0800                	addi	s0,sp,16
  int pid = fork();
    2a74:	00003097          	auipc	ra,0x3
    2a78:	be4080e7          	jalr	-1052(ra) # 5658 <fork>
  if(pid < 0){
    2a7c:	02054363          	bltz	a0,2aa2 <sbrkbugs+0x36>
  if(pid == 0){
    2a80:	ed15                	bnez	a0,2abc <sbrkbugs+0x50>
    int sz = (uint64) sbrk(0);
    2a82:	00003097          	auipc	ra,0x3
    2a86:	c66080e7          	jalr	-922(ra) # 56e8 <sbrk>
    sbrk(-sz);
    2a8a:	40a0053b          	negw	a0,a0
    2a8e:	2501                	sext.w	a0,a0
    2a90:	00003097          	auipc	ra,0x3
    2a94:	c58080e7          	jalr	-936(ra) # 56e8 <sbrk>
    exit(0);
    2a98:	4501                	li	a0,0
    2a9a:	00003097          	auipc	ra,0x3
    2a9e:	bc6080e7          	jalr	-1082(ra) # 5660 <exit>
    printf("fork failed\n");
    2aa2:	00004517          	auipc	a0,0x4
    2aa6:	14650513          	addi	a0,a0,326 # 6be8 <malloc+0x1150>
    2aaa:	00003097          	auipc	ra,0x3
    2aae:	f2e080e7          	jalr	-210(ra) # 59d8 <printf>
    exit(1);
    2ab2:	4505                	li	a0,1
    2ab4:	00003097          	auipc	ra,0x3
    2ab8:	bac080e7          	jalr	-1108(ra) # 5660 <exit>
  wait(0);
    2abc:	4501                	li	a0,0
    2abe:	00003097          	auipc	ra,0x3
    2ac2:	baa080e7          	jalr	-1110(ra) # 5668 <wait>
  pid = fork();
    2ac6:	00003097          	auipc	ra,0x3
    2aca:	b92080e7          	jalr	-1134(ra) # 5658 <fork>
  if(pid < 0){
    2ace:	02054563          	bltz	a0,2af8 <sbrkbugs+0x8c>
  if(pid == 0){
    2ad2:	e121                	bnez	a0,2b12 <sbrkbugs+0xa6>
    int sz = (uint64) sbrk(0);
    2ad4:	00003097          	auipc	ra,0x3
    2ad8:	c14080e7          	jalr	-1004(ra) # 56e8 <sbrk>
    sbrk(-(sz - 3500));
    2adc:	6785                	lui	a5,0x1
    2ade:	dac7879b          	addiw	a5,a5,-596
    2ae2:	40a7853b          	subw	a0,a5,a0
    2ae6:	00003097          	auipc	ra,0x3
    2aea:	c02080e7          	jalr	-1022(ra) # 56e8 <sbrk>
    exit(0);
    2aee:	4501                	li	a0,0
    2af0:	00003097          	auipc	ra,0x3
    2af4:	b70080e7          	jalr	-1168(ra) # 5660 <exit>
    printf("fork failed\n");
    2af8:	00004517          	auipc	a0,0x4
    2afc:	0f050513          	addi	a0,a0,240 # 6be8 <malloc+0x1150>
    2b00:	00003097          	auipc	ra,0x3
    2b04:	ed8080e7          	jalr	-296(ra) # 59d8 <printf>
    exit(1);
    2b08:	4505                	li	a0,1
    2b0a:	00003097          	auipc	ra,0x3
    2b0e:	b56080e7          	jalr	-1194(ra) # 5660 <exit>
  wait(0);
    2b12:	4501                	li	a0,0
    2b14:	00003097          	auipc	ra,0x3
    2b18:	b54080e7          	jalr	-1196(ra) # 5668 <wait>
  pid = fork();
    2b1c:	00003097          	auipc	ra,0x3
    2b20:	b3c080e7          	jalr	-1220(ra) # 5658 <fork>
  if(pid < 0){
    2b24:	02054a63          	bltz	a0,2b58 <sbrkbugs+0xec>
  if(pid == 0){
    2b28:	e529                	bnez	a0,2b72 <sbrkbugs+0x106>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2b2a:	00003097          	auipc	ra,0x3
    2b2e:	bbe080e7          	jalr	-1090(ra) # 56e8 <sbrk>
    2b32:	67ad                	lui	a5,0xb
    2b34:	8007879b          	addiw	a5,a5,-2048
    2b38:	40a7853b          	subw	a0,a5,a0
    2b3c:	00003097          	auipc	ra,0x3
    2b40:	bac080e7          	jalr	-1108(ra) # 56e8 <sbrk>
    sbrk(-10);
    2b44:	5559                	li	a0,-10
    2b46:	00003097          	auipc	ra,0x3
    2b4a:	ba2080e7          	jalr	-1118(ra) # 56e8 <sbrk>
    exit(0);
    2b4e:	4501                	li	a0,0
    2b50:	00003097          	auipc	ra,0x3
    2b54:	b10080e7          	jalr	-1264(ra) # 5660 <exit>
    printf("fork failed\n");
    2b58:	00004517          	auipc	a0,0x4
    2b5c:	09050513          	addi	a0,a0,144 # 6be8 <malloc+0x1150>
    2b60:	00003097          	auipc	ra,0x3
    2b64:	e78080e7          	jalr	-392(ra) # 59d8 <printf>
    exit(1);
    2b68:	4505                	li	a0,1
    2b6a:	00003097          	auipc	ra,0x3
    2b6e:	af6080e7          	jalr	-1290(ra) # 5660 <exit>
  wait(0);
    2b72:	4501                	li	a0,0
    2b74:	00003097          	auipc	ra,0x3
    2b78:	af4080e7          	jalr	-1292(ra) # 5668 <wait>
  exit(0);
    2b7c:	4501                	li	a0,0
    2b7e:	00003097          	auipc	ra,0x3
    2b82:	ae2080e7          	jalr	-1310(ra) # 5660 <exit>

0000000000002b86 <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    2b86:	715d                	addi	sp,sp,-80
    2b88:	e486                	sd	ra,72(sp)
    2b8a:	e0a2                	sd	s0,64(sp)
    2b8c:	fc26                	sd	s1,56(sp)
    2b8e:	f84a                	sd	s2,48(sp)
    2b90:	f44e                	sd	s3,40(sp)
    2b92:	f052                	sd	s4,32(sp)
    2b94:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2b96:	4901                	li	s2,0
    2b98:	49bd                	li	s3,15
    int pid = fork();
    2b9a:	00003097          	auipc	ra,0x3
    2b9e:	abe080e7          	jalr	-1346(ra) # 5658 <fork>
    2ba2:	84aa                	mv	s1,a0
    if(pid < 0){
    2ba4:	02054063          	bltz	a0,2bc4 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2ba8:	c91d                	beqz	a0,2bde <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    2baa:	4501                	li	a0,0
    2bac:	00003097          	auipc	ra,0x3
    2bb0:	abc080e7          	jalr	-1348(ra) # 5668 <wait>
  for(int avail = 0; avail < 15; avail++){
    2bb4:	2905                	addiw	s2,s2,1
    2bb6:	ff3912e3          	bne	s2,s3,2b9a <execout+0x14>
    }
  }

  exit(0);
    2bba:	4501                	li	a0,0
    2bbc:	00003097          	auipc	ra,0x3
    2bc0:	aa4080e7          	jalr	-1372(ra) # 5660 <exit>
      printf("fork failed\n");
    2bc4:	00004517          	auipc	a0,0x4
    2bc8:	02450513          	addi	a0,a0,36 # 6be8 <malloc+0x1150>
    2bcc:	00003097          	auipc	ra,0x3
    2bd0:	e0c080e7          	jalr	-500(ra) # 59d8 <printf>
      exit(1);
    2bd4:	4505                	li	a0,1
    2bd6:	00003097          	auipc	ra,0x3
    2bda:	a8a080e7          	jalr	-1398(ra) # 5660 <exit>
        if(a == 0xffffffffffffffffLL)
    2bde:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2be0:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2be2:	6505                	lui	a0,0x1
    2be4:	00003097          	auipc	ra,0x3
    2be8:	b04080e7          	jalr	-1276(ra) # 56e8 <sbrk>
        if(a == 0xffffffffffffffffLL)
    2bec:	01350763          	beq	a0,s3,2bfa <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2bf0:	6785                	lui	a5,0x1
    2bf2:	97aa                	add	a5,a5,a0
    2bf4:	ff478fa3          	sb	s4,-1(a5) # fff <bigdir+0x8b>
      while(1){
    2bf8:	b7ed                	j	2be2 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2bfa:	01205a63          	blez	s2,2c0e <execout+0x88>
        sbrk(-4096);
    2bfe:	757d                	lui	a0,0xfffff
    2c00:	00003097          	auipc	ra,0x3
    2c04:	ae8080e7          	jalr	-1304(ra) # 56e8 <sbrk>
      for(int i = 0; i < avail; i++)
    2c08:	2485                	addiw	s1,s1,1
    2c0a:	ff249ae3          	bne	s1,s2,2bfe <execout+0x78>
      close(1);
    2c0e:	4505                	li	a0,1
    2c10:	00003097          	auipc	ra,0x3
    2c14:	a78080e7          	jalr	-1416(ra) # 5688 <close>
      char *args[] = { "echo", "x", 0 };
    2c18:	00003517          	auipc	a0,0x3
    2c1c:	37050513          	addi	a0,a0,880 # 5f88 <malloc+0x4f0>
    2c20:	faa43c23          	sd	a0,-72(s0)
    2c24:	00003797          	auipc	a5,0x3
    2c28:	3d478793          	addi	a5,a5,980 # 5ff8 <malloc+0x560>
    2c2c:	fcf43023          	sd	a5,-64(s0)
    2c30:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2c34:	fb840593          	addi	a1,s0,-72
    2c38:	00003097          	auipc	ra,0x3
    2c3c:	a60080e7          	jalr	-1440(ra) # 5698 <exec>
      exit(0);
    2c40:	4501                	li	a0,0
    2c42:	00003097          	auipc	ra,0x3
    2c46:	a1e080e7          	jalr	-1506(ra) # 5660 <exit>

0000000000002c4a <fourteen>:
{
    2c4a:	1101                	addi	sp,sp,-32
    2c4c:	ec06                	sd	ra,24(sp)
    2c4e:	e822                	sd	s0,16(sp)
    2c50:	e426                	sd	s1,8(sp)
    2c52:	1000                	addi	s0,sp,32
    2c54:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2c56:	00004517          	auipc	a0,0x4
    2c5a:	48a50513          	addi	a0,a0,1162 # 70e0 <malloc+0x1648>
    2c5e:	00003097          	auipc	ra,0x3
    2c62:	a6a080e7          	jalr	-1430(ra) # 56c8 <mkdir>
    2c66:	e165                	bnez	a0,2d46 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2c68:	00004517          	auipc	a0,0x4
    2c6c:	2d050513          	addi	a0,a0,720 # 6f38 <malloc+0x14a0>
    2c70:	00003097          	auipc	ra,0x3
    2c74:	a58080e7          	jalr	-1448(ra) # 56c8 <mkdir>
    2c78:	e56d                	bnez	a0,2d62 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2c7a:	20000593          	li	a1,512
    2c7e:	00004517          	auipc	a0,0x4
    2c82:	31250513          	addi	a0,a0,786 # 6f90 <malloc+0x14f8>
    2c86:	00003097          	auipc	ra,0x3
    2c8a:	a1a080e7          	jalr	-1510(ra) # 56a0 <open>
  if(fd < 0){
    2c8e:	0e054863          	bltz	a0,2d7e <fourteen+0x134>
  close(fd);
    2c92:	00003097          	auipc	ra,0x3
    2c96:	9f6080e7          	jalr	-1546(ra) # 5688 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2c9a:	4581                	li	a1,0
    2c9c:	00004517          	auipc	a0,0x4
    2ca0:	36c50513          	addi	a0,a0,876 # 7008 <malloc+0x1570>
    2ca4:	00003097          	auipc	ra,0x3
    2ca8:	9fc080e7          	jalr	-1540(ra) # 56a0 <open>
  if(fd < 0){
    2cac:	0e054763          	bltz	a0,2d9a <fourteen+0x150>
  close(fd);
    2cb0:	00003097          	auipc	ra,0x3
    2cb4:	9d8080e7          	jalr	-1576(ra) # 5688 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2cb8:	00004517          	auipc	a0,0x4
    2cbc:	3c050513          	addi	a0,a0,960 # 7078 <malloc+0x15e0>
    2cc0:	00003097          	auipc	ra,0x3
    2cc4:	a08080e7          	jalr	-1528(ra) # 56c8 <mkdir>
    2cc8:	c57d                	beqz	a0,2db6 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2cca:	00004517          	auipc	a0,0x4
    2cce:	40650513          	addi	a0,a0,1030 # 70d0 <malloc+0x1638>
    2cd2:	00003097          	auipc	ra,0x3
    2cd6:	9f6080e7          	jalr	-1546(ra) # 56c8 <mkdir>
    2cda:	cd65                	beqz	a0,2dd2 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2cdc:	00004517          	auipc	a0,0x4
    2ce0:	3f450513          	addi	a0,a0,1012 # 70d0 <malloc+0x1638>
    2ce4:	00003097          	auipc	ra,0x3
    2ce8:	9cc080e7          	jalr	-1588(ra) # 56b0 <unlink>
  unlink("12345678901234/12345678901234");
    2cec:	00004517          	auipc	a0,0x4
    2cf0:	38c50513          	addi	a0,a0,908 # 7078 <malloc+0x15e0>
    2cf4:	00003097          	auipc	ra,0x3
    2cf8:	9bc080e7          	jalr	-1604(ra) # 56b0 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2cfc:	00004517          	auipc	a0,0x4
    2d00:	30c50513          	addi	a0,a0,780 # 7008 <malloc+0x1570>
    2d04:	00003097          	auipc	ra,0x3
    2d08:	9ac080e7          	jalr	-1620(ra) # 56b0 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2d0c:	00004517          	auipc	a0,0x4
    2d10:	28450513          	addi	a0,a0,644 # 6f90 <malloc+0x14f8>
    2d14:	00003097          	auipc	ra,0x3
    2d18:	99c080e7          	jalr	-1636(ra) # 56b0 <unlink>
  unlink("12345678901234/123456789012345");
    2d1c:	00004517          	auipc	a0,0x4
    2d20:	21c50513          	addi	a0,a0,540 # 6f38 <malloc+0x14a0>
    2d24:	00003097          	auipc	ra,0x3
    2d28:	98c080e7          	jalr	-1652(ra) # 56b0 <unlink>
  unlink("12345678901234");
    2d2c:	00004517          	auipc	a0,0x4
    2d30:	3b450513          	addi	a0,a0,948 # 70e0 <malloc+0x1648>
    2d34:	00003097          	auipc	ra,0x3
    2d38:	97c080e7          	jalr	-1668(ra) # 56b0 <unlink>
}
    2d3c:	60e2                	ld	ra,24(sp)
    2d3e:	6442                	ld	s0,16(sp)
    2d40:	64a2                	ld	s1,8(sp)
    2d42:	6105                	addi	sp,sp,32
    2d44:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2d46:	85a6                	mv	a1,s1
    2d48:	00004517          	auipc	a0,0x4
    2d4c:	1c850513          	addi	a0,a0,456 # 6f10 <malloc+0x1478>
    2d50:	00003097          	auipc	ra,0x3
    2d54:	c88080e7          	jalr	-888(ra) # 59d8 <printf>
    exit(1);
    2d58:	4505                	li	a0,1
    2d5a:	00003097          	auipc	ra,0x3
    2d5e:	906080e7          	jalr	-1786(ra) # 5660 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2d62:	85a6                	mv	a1,s1
    2d64:	00004517          	auipc	a0,0x4
    2d68:	1f450513          	addi	a0,a0,500 # 6f58 <malloc+0x14c0>
    2d6c:	00003097          	auipc	ra,0x3
    2d70:	c6c080e7          	jalr	-916(ra) # 59d8 <printf>
    exit(1);
    2d74:	4505                	li	a0,1
    2d76:	00003097          	auipc	ra,0x3
    2d7a:	8ea080e7          	jalr	-1814(ra) # 5660 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2d7e:	85a6                	mv	a1,s1
    2d80:	00004517          	auipc	a0,0x4
    2d84:	24050513          	addi	a0,a0,576 # 6fc0 <malloc+0x1528>
    2d88:	00003097          	auipc	ra,0x3
    2d8c:	c50080e7          	jalr	-944(ra) # 59d8 <printf>
    exit(1);
    2d90:	4505                	li	a0,1
    2d92:	00003097          	auipc	ra,0x3
    2d96:	8ce080e7          	jalr	-1842(ra) # 5660 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2d9a:	85a6                	mv	a1,s1
    2d9c:	00004517          	auipc	a0,0x4
    2da0:	29c50513          	addi	a0,a0,668 # 7038 <malloc+0x15a0>
    2da4:	00003097          	auipc	ra,0x3
    2da8:	c34080e7          	jalr	-972(ra) # 59d8 <printf>
    exit(1);
    2dac:	4505                	li	a0,1
    2dae:	00003097          	auipc	ra,0x3
    2db2:	8b2080e7          	jalr	-1870(ra) # 5660 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2db6:	85a6                	mv	a1,s1
    2db8:	00004517          	auipc	a0,0x4
    2dbc:	2e050513          	addi	a0,a0,736 # 7098 <malloc+0x1600>
    2dc0:	00003097          	auipc	ra,0x3
    2dc4:	c18080e7          	jalr	-1000(ra) # 59d8 <printf>
    exit(1);
    2dc8:	4505                	li	a0,1
    2dca:	00003097          	auipc	ra,0x3
    2dce:	896080e7          	jalr	-1898(ra) # 5660 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2dd2:	85a6                	mv	a1,s1
    2dd4:	00004517          	auipc	a0,0x4
    2dd8:	31c50513          	addi	a0,a0,796 # 70f0 <malloc+0x1658>
    2ddc:	00003097          	auipc	ra,0x3
    2de0:	bfc080e7          	jalr	-1028(ra) # 59d8 <printf>
    exit(1);
    2de4:	4505                	li	a0,1
    2de6:	00003097          	auipc	ra,0x3
    2dea:	87a080e7          	jalr	-1926(ra) # 5660 <exit>

0000000000002dee <iputtest>:
{
    2dee:	1101                	addi	sp,sp,-32
    2df0:	ec06                	sd	ra,24(sp)
    2df2:	e822                	sd	s0,16(sp)
    2df4:	e426                	sd	s1,8(sp)
    2df6:	1000                	addi	s0,sp,32
    2df8:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2dfa:	00004517          	auipc	a0,0x4
    2dfe:	32e50513          	addi	a0,a0,814 # 7128 <malloc+0x1690>
    2e02:	00003097          	auipc	ra,0x3
    2e06:	8c6080e7          	jalr	-1850(ra) # 56c8 <mkdir>
    2e0a:	04054563          	bltz	a0,2e54 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2e0e:	00004517          	auipc	a0,0x4
    2e12:	31a50513          	addi	a0,a0,794 # 7128 <malloc+0x1690>
    2e16:	00003097          	auipc	ra,0x3
    2e1a:	8ba080e7          	jalr	-1862(ra) # 56d0 <chdir>
    2e1e:	04054963          	bltz	a0,2e70 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2e22:	00004517          	auipc	a0,0x4
    2e26:	34650513          	addi	a0,a0,838 # 7168 <malloc+0x16d0>
    2e2a:	00003097          	auipc	ra,0x3
    2e2e:	886080e7          	jalr	-1914(ra) # 56b0 <unlink>
    2e32:	04054d63          	bltz	a0,2e8c <iputtest+0x9e>
  if(chdir("/") < 0){
    2e36:	00004517          	auipc	a0,0x4
    2e3a:	36250513          	addi	a0,a0,866 # 7198 <malloc+0x1700>
    2e3e:	00003097          	auipc	ra,0x3
    2e42:	892080e7          	jalr	-1902(ra) # 56d0 <chdir>
    2e46:	06054163          	bltz	a0,2ea8 <iputtest+0xba>
}
    2e4a:	60e2                	ld	ra,24(sp)
    2e4c:	6442                	ld	s0,16(sp)
    2e4e:	64a2                	ld	s1,8(sp)
    2e50:	6105                	addi	sp,sp,32
    2e52:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2e54:	85a6                	mv	a1,s1
    2e56:	00004517          	auipc	a0,0x4
    2e5a:	2da50513          	addi	a0,a0,730 # 7130 <malloc+0x1698>
    2e5e:	00003097          	auipc	ra,0x3
    2e62:	b7a080e7          	jalr	-1158(ra) # 59d8 <printf>
    exit(1);
    2e66:	4505                	li	a0,1
    2e68:	00002097          	auipc	ra,0x2
    2e6c:	7f8080e7          	jalr	2040(ra) # 5660 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2e70:	85a6                	mv	a1,s1
    2e72:	00004517          	auipc	a0,0x4
    2e76:	2d650513          	addi	a0,a0,726 # 7148 <malloc+0x16b0>
    2e7a:	00003097          	auipc	ra,0x3
    2e7e:	b5e080e7          	jalr	-1186(ra) # 59d8 <printf>
    exit(1);
    2e82:	4505                	li	a0,1
    2e84:	00002097          	auipc	ra,0x2
    2e88:	7dc080e7          	jalr	2012(ra) # 5660 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2e8c:	85a6                	mv	a1,s1
    2e8e:	00004517          	auipc	a0,0x4
    2e92:	2ea50513          	addi	a0,a0,746 # 7178 <malloc+0x16e0>
    2e96:	00003097          	auipc	ra,0x3
    2e9a:	b42080e7          	jalr	-1214(ra) # 59d8 <printf>
    exit(1);
    2e9e:	4505                	li	a0,1
    2ea0:	00002097          	auipc	ra,0x2
    2ea4:	7c0080e7          	jalr	1984(ra) # 5660 <exit>
    printf("%s: chdir / failed\n", s);
    2ea8:	85a6                	mv	a1,s1
    2eaa:	00004517          	auipc	a0,0x4
    2eae:	2f650513          	addi	a0,a0,758 # 71a0 <malloc+0x1708>
    2eb2:	00003097          	auipc	ra,0x3
    2eb6:	b26080e7          	jalr	-1242(ra) # 59d8 <printf>
    exit(1);
    2eba:	4505                	li	a0,1
    2ebc:	00002097          	auipc	ra,0x2
    2ec0:	7a4080e7          	jalr	1956(ra) # 5660 <exit>

0000000000002ec4 <exitiputtest>:
{
    2ec4:	7179                	addi	sp,sp,-48
    2ec6:	f406                	sd	ra,40(sp)
    2ec8:	f022                	sd	s0,32(sp)
    2eca:	ec26                	sd	s1,24(sp)
    2ecc:	1800                	addi	s0,sp,48
    2ece:	84aa                	mv	s1,a0
  pid = fork();
    2ed0:	00002097          	auipc	ra,0x2
    2ed4:	788080e7          	jalr	1928(ra) # 5658 <fork>
  if(pid < 0){
    2ed8:	04054663          	bltz	a0,2f24 <exitiputtest+0x60>
  if(pid == 0){
    2edc:	ed45                	bnez	a0,2f94 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2ede:	00004517          	auipc	a0,0x4
    2ee2:	24a50513          	addi	a0,a0,586 # 7128 <malloc+0x1690>
    2ee6:	00002097          	auipc	ra,0x2
    2eea:	7e2080e7          	jalr	2018(ra) # 56c8 <mkdir>
    2eee:	04054963          	bltz	a0,2f40 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2ef2:	00004517          	auipc	a0,0x4
    2ef6:	23650513          	addi	a0,a0,566 # 7128 <malloc+0x1690>
    2efa:	00002097          	auipc	ra,0x2
    2efe:	7d6080e7          	jalr	2006(ra) # 56d0 <chdir>
    2f02:	04054d63          	bltz	a0,2f5c <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2f06:	00004517          	auipc	a0,0x4
    2f0a:	26250513          	addi	a0,a0,610 # 7168 <malloc+0x16d0>
    2f0e:	00002097          	auipc	ra,0x2
    2f12:	7a2080e7          	jalr	1954(ra) # 56b0 <unlink>
    2f16:	06054163          	bltz	a0,2f78 <exitiputtest+0xb4>
    exit(0);
    2f1a:	4501                	li	a0,0
    2f1c:	00002097          	auipc	ra,0x2
    2f20:	744080e7          	jalr	1860(ra) # 5660 <exit>
    printf("%s: fork failed\n", s);
    2f24:	85a6                	mv	a1,s1
    2f26:	00004517          	auipc	a0,0x4
    2f2a:	8ba50513          	addi	a0,a0,-1862 # 67e0 <malloc+0xd48>
    2f2e:	00003097          	auipc	ra,0x3
    2f32:	aaa080e7          	jalr	-1366(ra) # 59d8 <printf>
    exit(1);
    2f36:	4505                	li	a0,1
    2f38:	00002097          	auipc	ra,0x2
    2f3c:	728080e7          	jalr	1832(ra) # 5660 <exit>
      printf("%s: mkdir failed\n", s);
    2f40:	85a6                	mv	a1,s1
    2f42:	00004517          	auipc	a0,0x4
    2f46:	1ee50513          	addi	a0,a0,494 # 7130 <malloc+0x1698>
    2f4a:	00003097          	auipc	ra,0x3
    2f4e:	a8e080e7          	jalr	-1394(ra) # 59d8 <printf>
      exit(1);
    2f52:	4505                	li	a0,1
    2f54:	00002097          	auipc	ra,0x2
    2f58:	70c080e7          	jalr	1804(ra) # 5660 <exit>
      printf("%s: child chdir failed\n", s);
    2f5c:	85a6                	mv	a1,s1
    2f5e:	00004517          	auipc	a0,0x4
    2f62:	25a50513          	addi	a0,a0,602 # 71b8 <malloc+0x1720>
    2f66:	00003097          	auipc	ra,0x3
    2f6a:	a72080e7          	jalr	-1422(ra) # 59d8 <printf>
      exit(1);
    2f6e:	4505                	li	a0,1
    2f70:	00002097          	auipc	ra,0x2
    2f74:	6f0080e7          	jalr	1776(ra) # 5660 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2f78:	85a6                	mv	a1,s1
    2f7a:	00004517          	auipc	a0,0x4
    2f7e:	1fe50513          	addi	a0,a0,510 # 7178 <malloc+0x16e0>
    2f82:	00003097          	auipc	ra,0x3
    2f86:	a56080e7          	jalr	-1450(ra) # 59d8 <printf>
      exit(1);
    2f8a:	4505                	li	a0,1
    2f8c:	00002097          	auipc	ra,0x2
    2f90:	6d4080e7          	jalr	1748(ra) # 5660 <exit>
  wait(&xstatus);
    2f94:	fdc40513          	addi	a0,s0,-36
    2f98:	00002097          	auipc	ra,0x2
    2f9c:	6d0080e7          	jalr	1744(ra) # 5668 <wait>
  exit(xstatus);
    2fa0:	fdc42503          	lw	a0,-36(s0)
    2fa4:	00002097          	auipc	ra,0x2
    2fa8:	6bc080e7          	jalr	1724(ra) # 5660 <exit>

0000000000002fac <dirtest>:
{
    2fac:	1101                	addi	sp,sp,-32
    2fae:	ec06                	sd	ra,24(sp)
    2fb0:	e822                	sd	s0,16(sp)
    2fb2:	e426                	sd	s1,8(sp)
    2fb4:	1000                	addi	s0,sp,32
    2fb6:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2fb8:	00004517          	auipc	a0,0x4
    2fbc:	21850513          	addi	a0,a0,536 # 71d0 <malloc+0x1738>
    2fc0:	00002097          	auipc	ra,0x2
    2fc4:	708080e7          	jalr	1800(ra) # 56c8 <mkdir>
    2fc8:	04054563          	bltz	a0,3012 <dirtest+0x66>
  if(chdir("dir0") < 0){
    2fcc:	00004517          	auipc	a0,0x4
    2fd0:	20450513          	addi	a0,a0,516 # 71d0 <malloc+0x1738>
    2fd4:	00002097          	auipc	ra,0x2
    2fd8:	6fc080e7          	jalr	1788(ra) # 56d0 <chdir>
    2fdc:	04054963          	bltz	a0,302e <dirtest+0x82>
  if(chdir("..") < 0){
    2fe0:	00004517          	auipc	a0,0x4
    2fe4:	21050513          	addi	a0,a0,528 # 71f0 <malloc+0x1758>
    2fe8:	00002097          	auipc	ra,0x2
    2fec:	6e8080e7          	jalr	1768(ra) # 56d0 <chdir>
    2ff0:	04054d63          	bltz	a0,304a <dirtest+0x9e>
  if(unlink("dir0") < 0){
    2ff4:	00004517          	auipc	a0,0x4
    2ff8:	1dc50513          	addi	a0,a0,476 # 71d0 <malloc+0x1738>
    2ffc:	00002097          	auipc	ra,0x2
    3000:	6b4080e7          	jalr	1716(ra) # 56b0 <unlink>
    3004:	06054163          	bltz	a0,3066 <dirtest+0xba>
}
    3008:	60e2                	ld	ra,24(sp)
    300a:	6442                	ld	s0,16(sp)
    300c:	64a2                	ld	s1,8(sp)
    300e:	6105                	addi	sp,sp,32
    3010:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3012:	85a6                	mv	a1,s1
    3014:	00004517          	auipc	a0,0x4
    3018:	11c50513          	addi	a0,a0,284 # 7130 <malloc+0x1698>
    301c:	00003097          	auipc	ra,0x3
    3020:	9bc080e7          	jalr	-1604(ra) # 59d8 <printf>
    exit(1);
    3024:	4505                	li	a0,1
    3026:	00002097          	auipc	ra,0x2
    302a:	63a080e7          	jalr	1594(ra) # 5660 <exit>
    printf("%s: chdir dir0 failed\n", s);
    302e:	85a6                	mv	a1,s1
    3030:	00004517          	auipc	a0,0x4
    3034:	1a850513          	addi	a0,a0,424 # 71d8 <malloc+0x1740>
    3038:	00003097          	auipc	ra,0x3
    303c:	9a0080e7          	jalr	-1632(ra) # 59d8 <printf>
    exit(1);
    3040:	4505                	li	a0,1
    3042:	00002097          	auipc	ra,0x2
    3046:	61e080e7          	jalr	1566(ra) # 5660 <exit>
    printf("%s: chdir .. failed\n", s);
    304a:	85a6                	mv	a1,s1
    304c:	00004517          	auipc	a0,0x4
    3050:	1ac50513          	addi	a0,a0,428 # 71f8 <malloc+0x1760>
    3054:	00003097          	auipc	ra,0x3
    3058:	984080e7          	jalr	-1660(ra) # 59d8 <printf>
    exit(1);
    305c:	4505                	li	a0,1
    305e:	00002097          	auipc	ra,0x2
    3062:	602080e7          	jalr	1538(ra) # 5660 <exit>
    printf("%s: unlink dir0 failed\n", s);
    3066:	85a6                	mv	a1,s1
    3068:	00004517          	auipc	a0,0x4
    306c:	1a850513          	addi	a0,a0,424 # 7210 <malloc+0x1778>
    3070:	00003097          	auipc	ra,0x3
    3074:	968080e7          	jalr	-1688(ra) # 59d8 <printf>
    exit(1);
    3078:	4505                	li	a0,1
    307a:	00002097          	auipc	ra,0x2
    307e:	5e6080e7          	jalr	1510(ra) # 5660 <exit>

0000000000003082 <subdir>:
{
    3082:	1101                	addi	sp,sp,-32
    3084:	ec06                	sd	ra,24(sp)
    3086:	e822                	sd	s0,16(sp)
    3088:	e426                	sd	s1,8(sp)
    308a:	e04a                	sd	s2,0(sp)
    308c:	1000                	addi	s0,sp,32
    308e:	892a                	mv	s2,a0
  unlink("ff");
    3090:	00004517          	auipc	a0,0x4
    3094:	2c850513          	addi	a0,a0,712 # 7358 <malloc+0x18c0>
    3098:	00002097          	auipc	ra,0x2
    309c:	618080e7          	jalr	1560(ra) # 56b0 <unlink>
  if(mkdir("dd") != 0){
    30a0:	00004517          	auipc	a0,0x4
    30a4:	18850513          	addi	a0,a0,392 # 7228 <malloc+0x1790>
    30a8:	00002097          	auipc	ra,0x2
    30ac:	620080e7          	jalr	1568(ra) # 56c8 <mkdir>
    30b0:	38051663          	bnez	a0,343c <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    30b4:	20200593          	li	a1,514
    30b8:	00004517          	auipc	a0,0x4
    30bc:	19050513          	addi	a0,a0,400 # 7248 <malloc+0x17b0>
    30c0:	00002097          	auipc	ra,0x2
    30c4:	5e0080e7          	jalr	1504(ra) # 56a0 <open>
    30c8:	84aa                	mv	s1,a0
  if(fd < 0){
    30ca:	38054763          	bltz	a0,3458 <subdir+0x3d6>
  write(fd, "ff", 2);
    30ce:	4609                	li	a2,2
    30d0:	00004597          	auipc	a1,0x4
    30d4:	28858593          	addi	a1,a1,648 # 7358 <malloc+0x18c0>
    30d8:	00002097          	auipc	ra,0x2
    30dc:	5a8080e7          	jalr	1448(ra) # 5680 <write>
  close(fd);
    30e0:	8526                	mv	a0,s1
    30e2:	00002097          	auipc	ra,0x2
    30e6:	5a6080e7          	jalr	1446(ra) # 5688 <close>
  if(unlink("dd") >= 0){
    30ea:	00004517          	auipc	a0,0x4
    30ee:	13e50513          	addi	a0,a0,318 # 7228 <malloc+0x1790>
    30f2:	00002097          	auipc	ra,0x2
    30f6:	5be080e7          	jalr	1470(ra) # 56b0 <unlink>
    30fa:	36055d63          	bgez	a0,3474 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    30fe:	00004517          	auipc	a0,0x4
    3102:	1a250513          	addi	a0,a0,418 # 72a0 <malloc+0x1808>
    3106:	00002097          	auipc	ra,0x2
    310a:	5c2080e7          	jalr	1474(ra) # 56c8 <mkdir>
    310e:	38051163          	bnez	a0,3490 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    3112:	20200593          	li	a1,514
    3116:	00004517          	auipc	a0,0x4
    311a:	1b250513          	addi	a0,a0,434 # 72c8 <malloc+0x1830>
    311e:	00002097          	auipc	ra,0x2
    3122:	582080e7          	jalr	1410(ra) # 56a0 <open>
    3126:	84aa                	mv	s1,a0
  if(fd < 0){
    3128:	38054263          	bltz	a0,34ac <subdir+0x42a>
  write(fd, "FF", 2);
    312c:	4609                	li	a2,2
    312e:	00004597          	auipc	a1,0x4
    3132:	1ca58593          	addi	a1,a1,458 # 72f8 <malloc+0x1860>
    3136:	00002097          	auipc	ra,0x2
    313a:	54a080e7          	jalr	1354(ra) # 5680 <write>
  close(fd);
    313e:	8526                	mv	a0,s1
    3140:	00002097          	auipc	ra,0x2
    3144:	548080e7          	jalr	1352(ra) # 5688 <close>
  fd = open("dd/dd/../ff", 0);
    3148:	4581                	li	a1,0
    314a:	00004517          	auipc	a0,0x4
    314e:	1b650513          	addi	a0,a0,438 # 7300 <malloc+0x1868>
    3152:	00002097          	auipc	ra,0x2
    3156:	54e080e7          	jalr	1358(ra) # 56a0 <open>
    315a:	84aa                	mv	s1,a0
  if(fd < 0){
    315c:	36054663          	bltz	a0,34c8 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    3160:	660d                	lui	a2,0x3
    3162:	00009597          	auipc	a1,0x9
    3166:	98e58593          	addi	a1,a1,-1650 # baf0 <buf>
    316a:	00002097          	auipc	ra,0x2
    316e:	50e080e7          	jalr	1294(ra) # 5678 <read>
  if(cc != 2 || buf[0] != 'f'){
    3172:	4789                	li	a5,2
    3174:	36f51863          	bne	a0,a5,34e4 <subdir+0x462>
    3178:	00009717          	auipc	a4,0x9
    317c:	97874703          	lbu	a4,-1672(a4) # baf0 <buf>
    3180:	06600793          	li	a5,102
    3184:	36f71063          	bne	a4,a5,34e4 <subdir+0x462>
  close(fd);
    3188:	8526                	mv	a0,s1
    318a:	00002097          	auipc	ra,0x2
    318e:	4fe080e7          	jalr	1278(ra) # 5688 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    3192:	00004597          	auipc	a1,0x4
    3196:	1be58593          	addi	a1,a1,446 # 7350 <malloc+0x18b8>
    319a:	00004517          	auipc	a0,0x4
    319e:	12e50513          	addi	a0,a0,302 # 72c8 <malloc+0x1830>
    31a2:	00002097          	auipc	ra,0x2
    31a6:	51e080e7          	jalr	1310(ra) # 56c0 <link>
    31aa:	34051b63          	bnez	a0,3500 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    31ae:	00004517          	auipc	a0,0x4
    31b2:	11a50513          	addi	a0,a0,282 # 72c8 <malloc+0x1830>
    31b6:	00002097          	auipc	ra,0x2
    31ba:	4fa080e7          	jalr	1274(ra) # 56b0 <unlink>
    31be:	34051f63          	bnez	a0,351c <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    31c2:	4581                	li	a1,0
    31c4:	00004517          	auipc	a0,0x4
    31c8:	10450513          	addi	a0,a0,260 # 72c8 <malloc+0x1830>
    31cc:	00002097          	auipc	ra,0x2
    31d0:	4d4080e7          	jalr	1236(ra) # 56a0 <open>
    31d4:	36055263          	bgez	a0,3538 <subdir+0x4b6>
  if(chdir("dd") != 0){
    31d8:	00004517          	auipc	a0,0x4
    31dc:	05050513          	addi	a0,a0,80 # 7228 <malloc+0x1790>
    31e0:	00002097          	auipc	ra,0x2
    31e4:	4f0080e7          	jalr	1264(ra) # 56d0 <chdir>
    31e8:	36051663          	bnez	a0,3554 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    31ec:	00004517          	auipc	a0,0x4
    31f0:	1fc50513          	addi	a0,a0,508 # 73e8 <malloc+0x1950>
    31f4:	00002097          	auipc	ra,0x2
    31f8:	4dc080e7          	jalr	1244(ra) # 56d0 <chdir>
    31fc:	36051a63          	bnez	a0,3570 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    3200:	00004517          	auipc	a0,0x4
    3204:	21850513          	addi	a0,a0,536 # 7418 <malloc+0x1980>
    3208:	00002097          	auipc	ra,0x2
    320c:	4c8080e7          	jalr	1224(ra) # 56d0 <chdir>
    3210:	36051e63          	bnez	a0,358c <subdir+0x50a>
  if(chdir("./..") != 0){
    3214:	00004517          	auipc	a0,0x4
    3218:	23450513          	addi	a0,a0,564 # 7448 <malloc+0x19b0>
    321c:	00002097          	auipc	ra,0x2
    3220:	4b4080e7          	jalr	1204(ra) # 56d0 <chdir>
    3224:	38051263          	bnez	a0,35a8 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    3228:	4581                	li	a1,0
    322a:	00004517          	auipc	a0,0x4
    322e:	12650513          	addi	a0,a0,294 # 7350 <malloc+0x18b8>
    3232:	00002097          	auipc	ra,0x2
    3236:	46e080e7          	jalr	1134(ra) # 56a0 <open>
    323a:	84aa                	mv	s1,a0
  if(fd < 0){
    323c:	38054463          	bltz	a0,35c4 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    3240:	660d                	lui	a2,0x3
    3242:	00009597          	auipc	a1,0x9
    3246:	8ae58593          	addi	a1,a1,-1874 # baf0 <buf>
    324a:	00002097          	auipc	ra,0x2
    324e:	42e080e7          	jalr	1070(ra) # 5678 <read>
    3252:	4789                	li	a5,2
    3254:	38f51663          	bne	a0,a5,35e0 <subdir+0x55e>
  close(fd);
    3258:	8526                	mv	a0,s1
    325a:	00002097          	auipc	ra,0x2
    325e:	42e080e7          	jalr	1070(ra) # 5688 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3262:	4581                	li	a1,0
    3264:	00004517          	auipc	a0,0x4
    3268:	06450513          	addi	a0,a0,100 # 72c8 <malloc+0x1830>
    326c:	00002097          	auipc	ra,0x2
    3270:	434080e7          	jalr	1076(ra) # 56a0 <open>
    3274:	38055463          	bgez	a0,35fc <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    3278:	20200593          	li	a1,514
    327c:	00004517          	auipc	a0,0x4
    3280:	25c50513          	addi	a0,a0,604 # 74d8 <malloc+0x1a40>
    3284:	00002097          	auipc	ra,0x2
    3288:	41c080e7          	jalr	1052(ra) # 56a0 <open>
    328c:	38055663          	bgez	a0,3618 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3290:	20200593          	li	a1,514
    3294:	00004517          	auipc	a0,0x4
    3298:	27450513          	addi	a0,a0,628 # 7508 <malloc+0x1a70>
    329c:	00002097          	auipc	ra,0x2
    32a0:	404080e7          	jalr	1028(ra) # 56a0 <open>
    32a4:	38055863          	bgez	a0,3634 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    32a8:	20000593          	li	a1,512
    32ac:	00004517          	auipc	a0,0x4
    32b0:	f7c50513          	addi	a0,a0,-132 # 7228 <malloc+0x1790>
    32b4:	00002097          	auipc	ra,0x2
    32b8:	3ec080e7          	jalr	1004(ra) # 56a0 <open>
    32bc:	38055a63          	bgez	a0,3650 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    32c0:	4589                	li	a1,2
    32c2:	00004517          	auipc	a0,0x4
    32c6:	f6650513          	addi	a0,a0,-154 # 7228 <malloc+0x1790>
    32ca:	00002097          	auipc	ra,0x2
    32ce:	3d6080e7          	jalr	982(ra) # 56a0 <open>
    32d2:	38055d63          	bgez	a0,366c <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    32d6:	4585                	li	a1,1
    32d8:	00004517          	auipc	a0,0x4
    32dc:	f5050513          	addi	a0,a0,-176 # 7228 <malloc+0x1790>
    32e0:	00002097          	auipc	ra,0x2
    32e4:	3c0080e7          	jalr	960(ra) # 56a0 <open>
    32e8:	3a055063          	bgez	a0,3688 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    32ec:	00004597          	auipc	a1,0x4
    32f0:	2ac58593          	addi	a1,a1,684 # 7598 <malloc+0x1b00>
    32f4:	00004517          	auipc	a0,0x4
    32f8:	1e450513          	addi	a0,a0,484 # 74d8 <malloc+0x1a40>
    32fc:	00002097          	auipc	ra,0x2
    3300:	3c4080e7          	jalr	964(ra) # 56c0 <link>
    3304:	3a050063          	beqz	a0,36a4 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    3308:	00004597          	auipc	a1,0x4
    330c:	29058593          	addi	a1,a1,656 # 7598 <malloc+0x1b00>
    3310:	00004517          	auipc	a0,0x4
    3314:	1f850513          	addi	a0,a0,504 # 7508 <malloc+0x1a70>
    3318:	00002097          	auipc	ra,0x2
    331c:	3a8080e7          	jalr	936(ra) # 56c0 <link>
    3320:	3a050063          	beqz	a0,36c0 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    3324:	00004597          	auipc	a1,0x4
    3328:	02c58593          	addi	a1,a1,44 # 7350 <malloc+0x18b8>
    332c:	00004517          	auipc	a0,0x4
    3330:	f1c50513          	addi	a0,a0,-228 # 7248 <malloc+0x17b0>
    3334:	00002097          	auipc	ra,0x2
    3338:	38c080e7          	jalr	908(ra) # 56c0 <link>
    333c:	3a050063          	beqz	a0,36dc <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3340:	00004517          	auipc	a0,0x4
    3344:	19850513          	addi	a0,a0,408 # 74d8 <malloc+0x1a40>
    3348:	00002097          	auipc	ra,0x2
    334c:	380080e7          	jalr	896(ra) # 56c8 <mkdir>
    3350:	3a050463          	beqz	a0,36f8 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3354:	00004517          	auipc	a0,0x4
    3358:	1b450513          	addi	a0,a0,436 # 7508 <malloc+0x1a70>
    335c:	00002097          	auipc	ra,0x2
    3360:	36c080e7          	jalr	876(ra) # 56c8 <mkdir>
    3364:	3a050863          	beqz	a0,3714 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    3368:	00004517          	auipc	a0,0x4
    336c:	fe850513          	addi	a0,a0,-24 # 7350 <malloc+0x18b8>
    3370:	00002097          	auipc	ra,0x2
    3374:	358080e7          	jalr	856(ra) # 56c8 <mkdir>
    3378:	3a050c63          	beqz	a0,3730 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    337c:	00004517          	auipc	a0,0x4
    3380:	18c50513          	addi	a0,a0,396 # 7508 <malloc+0x1a70>
    3384:	00002097          	auipc	ra,0x2
    3388:	32c080e7          	jalr	812(ra) # 56b0 <unlink>
    338c:	3c050063          	beqz	a0,374c <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3390:	00004517          	auipc	a0,0x4
    3394:	14850513          	addi	a0,a0,328 # 74d8 <malloc+0x1a40>
    3398:	00002097          	auipc	ra,0x2
    339c:	318080e7          	jalr	792(ra) # 56b0 <unlink>
    33a0:	3c050463          	beqz	a0,3768 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    33a4:	00004517          	auipc	a0,0x4
    33a8:	ea450513          	addi	a0,a0,-348 # 7248 <malloc+0x17b0>
    33ac:	00002097          	auipc	ra,0x2
    33b0:	324080e7          	jalr	804(ra) # 56d0 <chdir>
    33b4:	3c050863          	beqz	a0,3784 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    33b8:	00004517          	auipc	a0,0x4
    33bc:	33050513          	addi	a0,a0,816 # 76e8 <malloc+0x1c50>
    33c0:	00002097          	auipc	ra,0x2
    33c4:	310080e7          	jalr	784(ra) # 56d0 <chdir>
    33c8:	3c050c63          	beqz	a0,37a0 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    33cc:	00004517          	auipc	a0,0x4
    33d0:	f8450513          	addi	a0,a0,-124 # 7350 <malloc+0x18b8>
    33d4:	00002097          	auipc	ra,0x2
    33d8:	2dc080e7          	jalr	732(ra) # 56b0 <unlink>
    33dc:	3e051063          	bnez	a0,37bc <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    33e0:	00004517          	auipc	a0,0x4
    33e4:	e6850513          	addi	a0,a0,-408 # 7248 <malloc+0x17b0>
    33e8:	00002097          	auipc	ra,0x2
    33ec:	2c8080e7          	jalr	712(ra) # 56b0 <unlink>
    33f0:	3e051463          	bnez	a0,37d8 <subdir+0x756>
  if(unlink("dd") == 0){
    33f4:	00004517          	auipc	a0,0x4
    33f8:	e3450513          	addi	a0,a0,-460 # 7228 <malloc+0x1790>
    33fc:	00002097          	auipc	ra,0x2
    3400:	2b4080e7          	jalr	692(ra) # 56b0 <unlink>
    3404:	3e050863          	beqz	a0,37f4 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    3408:	00004517          	auipc	a0,0x4
    340c:	35050513          	addi	a0,a0,848 # 7758 <malloc+0x1cc0>
    3410:	00002097          	auipc	ra,0x2
    3414:	2a0080e7          	jalr	672(ra) # 56b0 <unlink>
    3418:	3e054c63          	bltz	a0,3810 <subdir+0x78e>
  if(unlink("dd") < 0){
    341c:	00004517          	auipc	a0,0x4
    3420:	e0c50513          	addi	a0,a0,-500 # 7228 <malloc+0x1790>
    3424:	00002097          	auipc	ra,0x2
    3428:	28c080e7          	jalr	652(ra) # 56b0 <unlink>
    342c:	40054063          	bltz	a0,382c <subdir+0x7aa>
}
    3430:	60e2                	ld	ra,24(sp)
    3432:	6442                	ld	s0,16(sp)
    3434:	64a2                	ld	s1,8(sp)
    3436:	6902                	ld	s2,0(sp)
    3438:	6105                	addi	sp,sp,32
    343a:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    343c:	85ca                	mv	a1,s2
    343e:	00004517          	auipc	a0,0x4
    3442:	df250513          	addi	a0,a0,-526 # 7230 <malloc+0x1798>
    3446:	00002097          	auipc	ra,0x2
    344a:	592080e7          	jalr	1426(ra) # 59d8 <printf>
    exit(1);
    344e:	4505                	li	a0,1
    3450:	00002097          	auipc	ra,0x2
    3454:	210080e7          	jalr	528(ra) # 5660 <exit>
    printf("%s: create dd/ff failed\n", s);
    3458:	85ca                	mv	a1,s2
    345a:	00004517          	auipc	a0,0x4
    345e:	df650513          	addi	a0,a0,-522 # 7250 <malloc+0x17b8>
    3462:	00002097          	auipc	ra,0x2
    3466:	576080e7          	jalr	1398(ra) # 59d8 <printf>
    exit(1);
    346a:	4505                	li	a0,1
    346c:	00002097          	auipc	ra,0x2
    3470:	1f4080e7          	jalr	500(ra) # 5660 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3474:	85ca                	mv	a1,s2
    3476:	00004517          	auipc	a0,0x4
    347a:	dfa50513          	addi	a0,a0,-518 # 7270 <malloc+0x17d8>
    347e:	00002097          	auipc	ra,0x2
    3482:	55a080e7          	jalr	1370(ra) # 59d8 <printf>
    exit(1);
    3486:	4505                	li	a0,1
    3488:	00002097          	auipc	ra,0x2
    348c:	1d8080e7          	jalr	472(ra) # 5660 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3490:	85ca                	mv	a1,s2
    3492:	00004517          	auipc	a0,0x4
    3496:	e1650513          	addi	a0,a0,-490 # 72a8 <malloc+0x1810>
    349a:	00002097          	auipc	ra,0x2
    349e:	53e080e7          	jalr	1342(ra) # 59d8 <printf>
    exit(1);
    34a2:	4505                	li	a0,1
    34a4:	00002097          	auipc	ra,0x2
    34a8:	1bc080e7          	jalr	444(ra) # 5660 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    34ac:	85ca                	mv	a1,s2
    34ae:	00004517          	auipc	a0,0x4
    34b2:	e2a50513          	addi	a0,a0,-470 # 72d8 <malloc+0x1840>
    34b6:	00002097          	auipc	ra,0x2
    34ba:	522080e7          	jalr	1314(ra) # 59d8 <printf>
    exit(1);
    34be:	4505                	li	a0,1
    34c0:	00002097          	auipc	ra,0x2
    34c4:	1a0080e7          	jalr	416(ra) # 5660 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    34c8:	85ca                	mv	a1,s2
    34ca:	00004517          	auipc	a0,0x4
    34ce:	e4650513          	addi	a0,a0,-442 # 7310 <malloc+0x1878>
    34d2:	00002097          	auipc	ra,0x2
    34d6:	506080e7          	jalr	1286(ra) # 59d8 <printf>
    exit(1);
    34da:	4505                	li	a0,1
    34dc:	00002097          	auipc	ra,0x2
    34e0:	184080e7          	jalr	388(ra) # 5660 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    34e4:	85ca                	mv	a1,s2
    34e6:	00004517          	auipc	a0,0x4
    34ea:	e4a50513          	addi	a0,a0,-438 # 7330 <malloc+0x1898>
    34ee:	00002097          	auipc	ra,0x2
    34f2:	4ea080e7          	jalr	1258(ra) # 59d8 <printf>
    exit(1);
    34f6:	4505                	li	a0,1
    34f8:	00002097          	auipc	ra,0x2
    34fc:	168080e7          	jalr	360(ra) # 5660 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    3500:	85ca                	mv	a1,s2
    3502:	00004517          	auipc	a0,0x4
    3506:	e5e50513          	addi	a0,a0,-418 # 7360 <malloc+0x18c8>
    350a:	00002097          	auipc	ra,0x2
    350e:	4ce080e7          	jalr	1230(ra) # 59d8 <printf>
    exit(1);
    3512:	4505                	li	a0,1
    3514:	00002097          	auipc	ra,0x2
    3518:	14c080e7          	jalr	332(ra) # 5660 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    351c:	85ca                	mv	a1,s2
    351e:	00004517          	auipc	a0,0x4
    3522:	e6a50513          	addi	a0,a0,-406 # 7388 <malloc+0x18f0>
    3526:	00002097          	auipc	ra,0x2
    352a:	4b2080e7          	jalr	1202(ra) # 59d8 <printf>
    exit(1);
    352e:	4505                	li	a0,1
    3530:	00002097          	auipc	ra,0x2
    3534:	130080e7          	jalr	304(ra) # 5660 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3538:	85ca                	mv	a1,s2
    353a:	00004517          	auipc	a0,0x4
    353e:	e6e50513          	addi	a0,a0,-402 # 73a8 <malloc+0x1910>
    3542:	00002097          	auipc	ra,0x2
    3546:	496080e7          	jalr	1174(ra) # 59d8 <printf>
    exit(1);
    354a:	4505                	li	a0,1
    354c:	00002097          	auipc	ra,0x2
    3550:	114080e7          	jalr	276(ra) # 5660 <exit>
    printf("%s: chdir dd failed\n", s);
    3554:	85ca                	mv	a1,s2
    3556:	00004517          	auipc	a0,0x4
    355a:	e7a50513          	addi	a0,a0,-390 # 73d0 <malloc+0x1938>
    355e:	00002097          	auipc	ra,0x2
    3562:	47a080e7          	jalr	1146(ra) # 59d8 <printf>
    exit(1);
    3566:	4505                	li	a0,1
    3568:	00002097          	auipc	ra,0x2
    356c:	0f8080e7          	jalr	248(ra) # 5660 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3570:	85ca                	mv	a1,s2
    3572:	00004517          	auipc	a0,0x4
    3576:	e8650513          	addi	a0,a0,-378 # 73f8 <malloc+0x1960>
    357a:	00002097          	auipc	ra,0x2
    357e:	45e080e7          	jalr	1118(ra) # 59d8 <printf>
    exit(1);
    3582:	4505                	li	a0,1
    3584:	00002097          	auipc	ra,0x2
    3588:	0dc080e7          	jalr	220(ra) # 5660 <exit>
    printf("chdir dd/../../dd failed\n", s);
    358c:	85ca                	mv	a1,s2
    358e:	00004517          	auipc	a0,0x4
    3592:	e9a50513          	addi	a0,a0,-358 # 7428 <malloc+0x1990>
    3596:	00002097          	auipc	ra,0x2
    359a:	442080e7          	jalr	1090(ra) # 59d8 <printf>
    exit(1);
    359e:	4505                	li	a0,1
    35a0:	00002097          	auipc	ra,0x2
    35a4:	0c0080e7          	jalr	192(ra) # 5660 <exit>
    printf("%s: chdir ./.. failed\n", s);
    35a8:	85ca                	mv	a1,s2
    35aa:	00004517          	auipc	a0,0x4
    35ae:	ea650513          	addi	a0,a0,-346 # 7450 <malloc+0x19b8>
    35b2:	00002097          	auipc	ra,0x2
    35b6:	426080e7          	jalr	1062(ra) # 59d8 <printf>
    exit(1);
    35ba:	4505                	li	a0,1
    35bc:	00002097          	auipc	ra,0x2
    35c0:	0a4080e7          	jalr	164(ra) # 5660 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    35c4:	85ca                	mv	a1,s2
    35c6:	00004517          	auipc	a0,0x4
    35ca:	ea250513          	addi	a0,a0,-350 # 7468 <malloc+0x19d0>
    35ce:	00002097          	auipc	ra,0x2
    35d2:	40a080e7          	jalr	1034(ra) # 59d8 <printf>
    exit(1);
    35d6:	4505                	li	a0,1
    35d8:	00002097          	auipc	ra,0x2
    35dc:	088080e7          	jalr	136(ra) # 5660 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    35e0:	85ca                	mv	a1,s2
    35e2:	00004517          	auipc	a0,0x4
    35e6:	ea650513          	addi	a0,a0,-346 # 7488 <malloc+0x19f0>
    35ea:	00002097          	auipc	ra,0x2
    35ee:	3ee080e7          	jalr	1006(ra) # 59d8 <printf>
    exit(1);
    35f2:	4505                	li	a0,1
    35f4:	00002097          	auipc	ra,0x2
    35f8:	06c080e7          	jalr	108(ra) # 5660 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    35fc:	85ca                	mv	a1,s2
    35fe:	00004517          	auipc	a0,0x4
    3602:	eaa50513          	addi	a0,a0,-342 # 74a8 <malloc+0x1a10>
    3606:	00002097          	auipc	ra,0x2
    360a:	3d2080e7          	jalr	978(ra) # 59d8 <printf>
    exit(1);
    360e:	4505                	li	a0,1
    3610:	00002097          	auipc	ra,0x2
    3614:	050080e7          	jalr	80(ra) # 5660 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3618:	85ca                	mv	a1,s2
    361a:	00004517          	auipc	a0,0x4
    361e:	ece50513          	addi	a0,a0,-306 # 74e8 <malloc+0x1a50>
    3622:	00002097          	auipc	ra,0x2
    3626:	3b6080e7          	jalr	950(ra) # 59d8 <printf>
    exit(1);
    362a:	4505                	li	a0,1
    362c:	00002097          	auipc	ra,0x2
    3630:	034080e7          	jalr	52(ra) # 5660 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3634:	85ca                	mv	a1,s2
    3636:	00004517          	auipc	a0,0x4
    363a:	ee250513          	addi	a0,a0,-286 # 7518 <malloc+0x1a80>
    363e:	00002097          	auipc	ra,0x2
    3642:	39a080e7          	jalr	922(ra) # 59d8 <printf>
    exit(1);
    3646:	4505                	li	a0,1
    3648:	00002097          	auipc	ra,0x2
    364c:	018080e7          	jalr	24(ra) # 5660 <exit>
    printf("%s: create dd succeeded!\n", s);
    3650:	85ca                	mv	a1,s2
    3652:	00004517          	auipc	a0,0x4
    3656:	ee650513          	addi	a0,a0,-282 # 7538 <malloc+0x1aa0>
    365a:	00002097          	auipc	ra,0x2
    365e:	37e080e7          	jalr	894(ra) # 59d8 <printf>
    exit(1);
    3662:	4505                	li	a0,1
    3664:	00002097          	auipc	ra,0x2
    3668:	ffc080e7          	jalr	-4(ra) # 5660 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    366c:	85ca                	mv	a1,s2
    366e:	00004517          	auipc	a0,0x4
    3672:	eea50513          	addi	a0,a0,-278 # 7558 <malloc+0x1ac0>
    3676:	00002097          	auipc	ra,0x2
    367a:	362080e7          	jalr	866(ra) # 59d8 <printf>
    exit(1);
    367e:	4505                	li	a0,1
    3680:	00002097          	auipc	ra,0x2
    3684:	fe0080e7          	jalr	-32(ra) # 5660 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3688:	85ca                	mv	a1,s2
    368a:	00004517          	auipc	a0,0x4
    368e:	eee50513          	addi	a0,a0,-274 # 7578 <malloc+0x1ae0>
    3692:	00002097          	auipc	ra,0x2
    3696:	346080e7          	jalr	838(ra) # 59d8 <printf>
    exit(1);
    369a:	4505                	li	a0,1
    369c:	00002097          	auipc	ra,0x2
    36a0:	fc4080e7          	jalr	-60(ra) # 5660 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    36a4:	85ca                	mv	a1,s2
    36a6:	00004517          	auipc	a0,0x4
    36aa:	f0250513          	addi	a0,a0,-254 # 75a8 <malloc+0x1b10>
    36ae:	00002097          	auipc	ra,0x2
    36b2:	32a080e7          	jalr	810(ra) # 59d8 <printf>
    exit(1);
    36b6:	4505                	li	a0,1
    36b8:	00002097          	auipc	ra,0x2
    36bc:	fa8080e7          	jalr	-88(ra) # 5660 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    36c0:	85ca                	mv	a1,s2
    36c2:	00004517          	auipc	a0,0x4
    36c6:	f0e50513          	addi	a0,a0,-242 # 75d0 <malloc+0x1b38>
    36ca:	00002097          	auipc	ra,0x2
    36ce:	30e080e7          	jalr	782(ra) # 59d8 <printf>
    exit(1);
    36d2:	4505                	li	a0,1
    36d4:	00002097          	auipc	ra,0x2
    36d8:	f8c080e7          	jalr	-116(ra) # 5660 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    36dc:	85ca                	mv	a1,s2
    36de:	00004517          	auipc	a0,0x4
    36e2:	f1a50513          	addi	a0,a0,-230 # 75f8 <malloc+0x1b60>
    36e6:	00002097          	auipc	ra,0x2
    36ea:	2f2080e7          	jalr	754(ra) # 59d8 <printf>
    exit(1);
    36ee:	4505                	li	a0,1
    36f0:	00002097          	auipc	ra,0x2
    36f4:	f70080e7          	jalr	-144(ra) # 5660 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    36f8:	85ca                	mv	a1,s2
    36fa:	00004517          	auipc	a0,0x4
    36fe:	f2650513          	addi	a0,a0,-218 # 7620 <malloc+0x1b88>
    3702:	00002097          	auipc	ra,0x2
    3706:	2d6080e7          	jalr	726(ra) # 59d8 <printf>
    exit(1);
    370a:	4505                	li	a0,1
    370c:	00002097          	auipc	ra,0x2
    3710:	f54080e7          	jalr	-172(ra) # 5660 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3714:	85ca                	mv	a1,s2
    3716:	00004517          	auipc	a0,0x4
    371a:	f2a50513          	addi	a0,a0,-214 # 7640 <malloc+0x1ba8>
    371e:	00002097          	auipc	ra,0x2
    3722:	2ba080e7          	jalr	698(ra) # 59d8 <printf>
    exit(1);
    3726:	4505                	li	a0,1
    3728:	00002097          	auipc	ra,0x2
    372c:	f38080e7          	jalr	-200(ra) # 5660 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3730:	85ca                	mv	a1,s2
    3732:	00004517          	auipc	a0,0x4
    3736:	f2e50513          	addi	a0,a0,-210 # 7660 <malloc+0x1bc8>
    373a:	00002097          	auipc	ra,0x2
    373e:	29e080e7          	jalr	670(ra) # 59d8 <printf>
    exit(1);
    3742:	4505                	li	a0,1
    3744:	00002097          	auipc	ra,0x2
    3748:	f1c080e7          	jalr	-228(ra) # 5660 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    374c:	85ca                	mv	a1,s2
    374e:	00004517          	auipc	a0,0x4
    3752:	f3a50513          	addi	a0,a0,-198 # 7688 <malloc+0x1bf0>
    3756:	00002097          	auipc	ra,0x2
    375a:	282080e7          	jalr	642(ra) # 59d8 <printf>
    exit(1);
    375e:	4505                	li	a0,1
    3760:	00002097          	auipc	ra,0x2
    3764:	f00080e7          	jalr	-256(ra) # 5660 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3768:	85ca                	mv	a1,s2
    376a:	00004517          	auipc	a0,0x4
    376e:	f3e50513          	addi	a0,a0,-194 # 76a8 <malloc+0x1c10>
    3772:	00002097          	auipc	ra,0x2
    3776:	266080e7          	jalr	614(ra) # 59d8 <printf>
    exit(1);
    377a:	4505                	li	a0,1
    377c:	00002097          	auipc	ra,0x2
    3780:	ee4080e7          	jalr	-284(ra) # 5660 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3784:	85ca                	mv	a1,s2
    3786:	00004517          	auipc	a0,0x4
    378a:	f4250513          	addi	a0,a0,-190 # 76c8 <malloc+0x1c30>
    378e:	00002097          	auipc	ra,0x2
    3792:	24a080e7          	jalr	586(ra) # 59d8 <printf>
    exit(1);
    3796:	4505                	li	a0,1
    3798:	00002097          	auipc	ra,0x2
    379c:	ec8080e7          	jalr	-312(ra) # 5660 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    37a0:	85ca                	mv	a1,s2
    37a2:	00004517          	auipc	a0,0x4
    37a6:	f4e50513          	addi	a0,a0,-178 # 76f0 <malloc+0x1c58>
    37aa:	00002097          	auipc	ra,0x2
    37ae:	22e080e7          	jalr	558(ra) # 59d8 <printf>
    exit(1);
    37b2:	4505                	li	a0,1
    37b4:	00002097          	auipc	ra,0x2
    37b8:	eac080e7          	jalr	-340(ra) # 5660 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    37bc:	85ca                	mv	a1,s2
    37be:	00004517          	auipc	a0,0x4
    37c2:	bca50513          	addi	a0,a0,-1078 # 7388 <malloc+0x18f0>
    37c6:	00002097          	auipc	ra,0x2
    37ca:	212080e7          	jalr	530(ra) # 59d8 <printf>
    exit(1);
    37ce:	4505                	li	a0,1
    37d0:	00002097          	auipc	ra,0x2
    37d4:	e90080e7          	jalr	-368(ra) # 5660 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    37d8:	85ca                	mv	a1,s2
    37da:	00004517          	auipc	a0,0x4
    37de:	f3650513          	addi	a0,a0,-202 # 7710 <malloc+0x1c78>
    37e2:	00002097          	auipc	ra,0x2
    37e6:	1f6080e7          	jalr	502(ra) # 59d8 <printf>
    exit(1);
    37ea:	4505                	li	a0,1
    37ec:	00002097          	auipc	ra,0x2
    37f0:	e74080e7          	jalr	-396(ra) # 5660 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    37f4:	85ca                	mv	a1,s2
    37f6:	00004517          	auipc	a0,0x4
    37fa:	f3a50513          	addi	a0,a0,-198 # 7730 <malloc+0x1c98>
    37fe:	00002097          	auipc	ra,0x2
    3802:	1da080e7          	jalr	474(ra) # 59d8 <printf>
    exit(1);
    3806:	4505                	li	a0,1
    3808:	00002097          	auipc	ra,0x2
    380c:	e58080e7          	jalr	-424(ra) # 5660 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3810:	85ca                	mv	a1,s2
    3812:	00004517          	auipc	a0,0x4
    3816:	f4e50513          	addi	a0,a0,-178 # 7760 <malloc+0x1cc8>
    381a:	00002097          	auipc	ra,0x2
    381e:	1be080e7          	jalr	446(ra) # 59d8 <printf>
    exit(1);
    3822:	4505                	li	a0,1
    3824:	00002097          	auipc	ra,0x2
    3828:	e3c080e7          	jalr	-452(ra) # 5660 <exit>
    printf("%s: unlink dd failed\n", s);
    382c:	85ca                	mv	a1,s2
    382e:	00004517          	auipc	a0,0x4
    3832:	f5250513          	addi	a0,a0,-174 # 7780 <malloc+0x1ce8>
    3836:	00002097          	auipc	ra,0x2
    383a:	1a2080e7          	jalr	418(ra) # 59d8 <printf>
    exit(1);
    383e:	4505                	li	a0,1
    3840:	00002097          	auipc	ra,0x2
    3844:	e20080e7          	jalr	-480(ra) # 5660 <exit>

0000000000003848 <rmdot>:
{
    3848:	1101                	addi	sp,sp,-32
    384a:	ec06                	sd	ra,24(sp)
    384c:	e822                	sd	s0,16(sp)
    384e:	e426                	sd	s1,8(sp)
    3850:	1000                	addi	s0,sp,32
    3852:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3854:	00004517          	auipc	a0,0x4
    3858:	f4450513          	addi	a0,a0,-188 # 7798 <malloc+0x1d00>
    385c:	00002097          	auipc	ra,0x2
    3860:	e6c080e7          	jalr	-404(ra) # 56c8 <mkdir>
    3864:	e549                	bnez	a0,38ee <rmdot+0xa6>
  if(chdir("dots") != 0){
    3866:	00004517          	auipc	a0,0x4
    386a:	f3250513          	addi	a0,a0,-206 # 7798 <malloc+0x1d00>
    386e:	00002097          	auipc	ra,0x2
    3872:	e62080e7          	jalr	-414(ra) # 56d0 <chdir>
    3876:	e951                	bnez	a0,390a <rmdot+0xc2>
  if(unlink(".") == 0){
    3878:	00003517          	auipc	a0,0x3
    387c:	dc850513          	addi	a0,a0,-568 # 6640 <malloc+0xba8>
    3880:	00002097          	auipc	ra,0x2
    3884:	e30080e7          	jalr	-464(ra) # 56b0 <unlink>
    3888:	cd59                	beqz	a0,3926 <rmdot+0xde>
  if(unlink("..") == 0){
    388a:	00004517          	auipc	a0,0x4
    388e:	96650513          	addi	a0,a0,-1690 # 71f0 <malloc+0x1758>
    3892:	00002097          	auipc	ra,0x2
    3896:	e1e080e7          	jalr	-482(ra) # 56b0 <unlink>
    389a:	c545                	beqz	a0,3942 <rmdot+0xfa>
  if(chdir("/") != 0){
    389c:	00004517          	auipc	a0,0x4
    38a0:	8fc50513          	addi	a0,a0,-1796 # 7198 <malloc+0x1700>
    38a4:	00002097          	auipc	ra,0x2
    38a8:	e2c080e7          	jalr	-468(ra) # 56d0 <chdir>
    38ac:	e94d                	bnez	a0,395e <rmdot+0x116>
  if(unlink("dots/.") == 0){
    38ae:	00004517          	auipc	a0,0x4
    38b2:	f5250513          	addi	a0,a0,-174 # 7800 <malloc+0x1d68>
    38b6:	00002097          	auipc	ra,0x2
    38ba:	dfa080e7          	jalr	-518(ra) # 56b0 <unlink>
    38be:	cd55                	beqz	a0,397a <rmdot+0x132>
  if(unlink("dots/..") == 0){
    38c0:	00004517          	auipc	a0,0x4
    38c4:	f6850513          	addi	a0,a0,-152 # 7828 <malloc+0x1d90>
    38c8:	00002097          	auipc	ra,0x2
    38cc:	de8080e7          	jalr	-536(ra) # 56b0 <unlink>
    38d0:	c179                	beqz	a0,3996 <rmdot+0x14e>
  if(unlink("dots") != 0){
    38d2:	00004517          	auipc	a0,0x4
    38d6:	ec650513          	addi	a0,a0,-314 # 7798 <malloc+0x1d00>
    38da:	00002097          	auipc	ra,0x2
    38de:	dd6080e7          	jalr	-554(ra) # 56b0 <unlink>
    38e2:	e961                	bnez	a0,39b2 <rmdot+0x16a>
}
    38e4:	60e2                	ld	ra,24(sp)
    38e6:	6442                	ld	s0,16(sp)
    38e8:	64a2                	ld	s1,8(sp)
    38ea:	6105                	addi	sp,sp,32
    38ec:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    38ee:	85a6                	mv	a1,s1
    38f0:	00004517          	auipc	a0,0x4
    38f4:	eb050513          	addi	a0,a0,-336 # 77a0 <malloc+0x1d08>
    38f8:	00002097          	auipc	ra,0x2
    38fc:	0e0080e7          	jalr	224(ra) # 59d8 <printf>
    exit(1);
    3900:	4505                	li	a0,1
    3902:	00002097          	auipc	ra,0x2
    3906:	d5e080e7          	jalr	-674(ra) # 5660 <exit>
    printf("%s: chdir dots failed\n", s);
    390a:	85a6                	mv	a1,s1
    390c:	00004517          	auipc	a0,0x4
    3910:	eac50513          	addi	a0,a0,-340 # 77b8 <malloc+0x1d20>
    3914:	00002097          	auipc	ra,0x2
    3918:	0c4080e7          	jalr	196(ra) # 59d8 <printf>
    exit(1);
    391c:	4505                	li	a0,1
    391e:	00002097          	auipc	ra,0x2
    3922:	d42080e7          	jalr	-702(ra) # 5660 <exit>
    printf("%s: rm . worked!\n", s);
    3926:	85a6                	mv	a1,s1
    3928:	00004517          	auipc	a0,0x4
    392c:	ea850513          	addi	a0,a0,-344 # 77d0 <malloc+0x1d38>
    3930:	00002097          	auipc	ra,0x2
    3934:	0a8080e7          	jalr	168(ra) # 59d8 <printf>
    exit(1);
    3938:	4505                	li	a0,1
    393a:	00002097          	auipc	ra,0x2
    393e:	d26080e7          	jalr	-730(ra) # 5660 <exit>
    printf("%s: rm .. worked!\n", s);
    3942:	85a6                	mv	a1,s1
    3944:	00004517          	auipc	a0,0x4
    3948:	ea450513          	addi	a0,a0,-348 # 77e8 <malloc+0x1d50>
    394c:	00002097          	auipc	ra,0x2
    3950:	08c080e7          	jalr	140(ra) # 59d8 <printf>
    exit(1);
    3954:	4505                	li	a0,1
    3956:	00002097          	auipc	ra,0x2
    395a:	d0a080e7          	jalr	-758(ra) # 5660 <exit>
    printf("%s: chdir / failed\n", s);
    395e:	85a6                	mv	a1,s1
    3960:	00004517          	auipc	a0,0x4
    3964:	84050513          	addi	a0,a0,-1984 # 71a0 <malloc+0x1708>
    3968:	00002097          	auipc	ra,0x2
    396c:	070080e7          	jalr	112(ra) # 59d8 <printf>
    exit(1);
    3970:	4505                	li	a0,1
    3972:	00002097          	auipc	ra,0x2
    3976:	cee080e7          	jalr	-786(ra) # 5660 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    397a:	85a6                	mv	a1,s1
    397c:	00004517          	auipc	a0,0x4
    3980:	e8c50513          	addi	a0,a0,-372 # 7808 <malloc+0x1d70>
    3984:	00002097          	auipc	ra,0x2
    3988:	054080e7          	jalr	84(ra) # 59d8 <printf>
    exit(1);
    398c:	4505                	li	a0,1
    398e:	00002097          	auipc	ra,0x2
    3992:	cd2080e7          	jalr	-814(ra) # 5660 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3996:	85a6                	mv	a1,s1
    3998:	00004517          	auipc	a0,0x4
    399c:	e9850513          	addi	a0,a0,-360 # 7830 <malloc+0x1d98>
    39a0:	00002097          	auipc	ra,0x2
    39a4:	038080e7          	jalr	56(ra) # 59d8 <printf>
    exit(1);
    39a8:	4505                	li	a0,1
    39aa:	00002097          	auipc	ra,0x2
    39ae:	cb6080e7          	jalr	-842(ra) # 5660 <exit>
    printf("%s: unlink dots failed!\n", s);
    39b2:	85a6                	mv	a1,s1
    39b4:	00004517          	auipc	a0,0x4
    39b8:	e9c50513          	addi	a0,a0,-356 # 7850 <malloc+0x1db8>
    39bc:	00002097          	auipc	ra,0x2
    39c0:	01c080e7          	jalr	28(ra) # 59d8 <printf>
    exit(1);
    39c4:	4505                	li	a0,1
    39c6:	00002097          	auipc	ra,0x2
    39ca:	c9a080e7          	jalr	-870(ra) # 5660 <exit>

00000000000039ce <dirfile>:
{
    39ce:	1101                	addi	sp,sp,-32
    39d0:	ec06                	sd	ra,24(sp)
    39d2:	e822                	sd	s0,16(sp)
    39d4:	e426                	sd	s1,8(sp)
    39d6:	e04a                	sd	s2,0(sp)
    39d8:	1000                	addi	s0,sp,32
    39da:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    39dc:	20000593          	li	a1,512
    39e0:	00004517          	auipc	a0,0x4
    39e4:	e9050513          	addi	a0,a0,-368 # 7870 <malloc+0x1dd8>
    39e8:	00002097          	auipc	ra,0x2
    39ec:	cb8080e7          	jalr	-840(ra) # 56a0 <open>
  if(fd < 0){
    39f0:	0e054d63          	bltz	a0,3aea <dirfile+0x11c>
  close(fd);
    39f4:	00002097          	auipc	ra,0x2
    39f8:	c94080e7          	jalr	-876(ra) # 5688 <close>
  if(chdir("dirfile") == 0){
    39fc:	00004517          	auipc	a0,0x4
    3a00:	e7450513          	addi	a0,a0,-396 # 7870 <malloc+0x1dd8>
    3a04:	00002097          	auipc	ra,0x2
    3a08:	ccc080e7          	jalr	-820(ra) # 56d0 <chdir>
    3a0c:	cd6d                	beqz	a0,3b06 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    3a0e:	4581                	li	a1,0
    3a10:	00004517          	auipc	a0,0x4
    3a14:	ea850513          	addi	a0,a0,-344 # 78b8 <malloc+0x1e20>
    3a18:	00002097          	auipc	ra,0x2
    3a1c:	c88080e7          	jalr	-888(ra) # 56a0 <open>
  if(fd >= 0){
    3a20:	10055163          	bgez	a0,3b22 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    3a24:	20000593          	li	a1,512
    3a28:	00004517          	auipc	a0,0x4
    3a2c:	e9050513          	addi	a0,a0,-368 # 78b8 <malloc+0x1e20>
    3a30:	00002097          	auipc	ra,0x2
    3a34:	c70080e7          	jalr	-912(ra) # 56a0 <open>
  if(fd >= 0){
    3a38:	10055363          	bgez	a0,3b3e <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    3a3c:	00004517          	auipc	a0,0x4
    3a40:	e7c50513          	addi	a0,a0,-388 # 78b8 <malloc+0x1e20>
    3a44:	00002097          	auipc	ra,0x2
    3a48:	c84080e7          	jalr	-892(ra) # 56c8 <mkdir>
    3a4c:	10050763          	beqz	a0,3b5a <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3a50:	00004517          	auipc	a0,0x4
    3a54:	e6850513          	addi	a0,a0,-408 # 78b8 <malloc+0x1e20>
    3a58:	00002097          	auipc	ra,0x2
    3a5c:	c58080e7          	jalr	-936(ra) # 56b0 <unlink>
    3a60:	10050b63          	beqz	a0,3b76 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3a64:	00004597          	auipc	a1,0x4
    3a68:	e5458593          	addi	a1,a1,-428 # 78b8 <malloc+0x1e20>
    3a6c:	00002517          	auipc	a0,0x2
    3a70:	6c450513          	addi	a0,a0,1732 # 6130 <malloc+0x698>
    3a74:	00002097          	auipc	ra,0x2
    3a78:	c4c080e7          	jalr	-948(ra) # 56c0 <link>
    3a7c:	10050b63          	beqz	a0,3b92 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    3a80:	00004517          	auipc	a0,0x4
    3a84:	df050513          	addi	a0,a0,-528 # 7870 <malloc+0x1dd8>
    3a88:	00002097          	auipc	ra,0x2
    3a8c:	c28080e7          	jalr	-984(ra) # 56b0 <unlink>
    3a90:	10051f63          	bnez	a0,3bae <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3a94:	4589                	li	a1,2
    3a96:	00003517          	auipc	a0,0x3
    3a9a:	baa50513          	addi	a0,a0,-1110 # 6640 <malloc+0xba8>
    3a9e:	00002097          	auipc	ra,0x2
    3aa2:	c02080e7          	jalr	-1022(ra) # 56a0 <open>
  if(fd >= 0){
    3aa6:	12055263          	bgez	a0,3bca <dirfile+0x1fc>
  fd = open(".", 0);
    3aaa:	4581                	li	a1,0
    3aac:	00003517          	auipc	a0,0x3
    3ab0:	b9450513          	addi	a0,a0,-1132 # 6640 <malloc+0xba8>
    3ab4:	00002097          	auipc	ra,0x2
    3ab8:	bec080e7          	jalr	-1044(ra) # 56a0 <open>
    3abc:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3abe:	4605                	li	a2,1
    3ac0:	00002597          	auipc	a1,0x2
    3ac4:	53858593          	addi	a1,a1,1336 # 5ff8 <malloc+0x560>
    3ac8:	00002097          	auipc	ra,0x2
    3acc:	bb8080e7          	jalr	-1096(ra) # 5680 <write>
    3ad0:	10a04b63          	bgtz	a0,3be6 <dirfile+0x218>
  close(fd);
    3ad4:	8526                	mv	a0,s1
    3ad6:	00002097          	auipc	ra,0x2
    3ada:	bb2080e7          	jalr	-1102(ra) # 5688 <close>
}
    3ade:	60e2                	ld	ra,24(sp)
    3ae0:	6442                	ld	s0,16(sp)
    3ae2:	64a2                	ld	s1,8(sp)
    3ae4:	6902                	ld	s2,0(sp)
    3ae6:	6105                	addi	sp,sp,32
    3ae8:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    3aea:	85ca                	mv	a1,s2
    3aec:	00004517          	auipc	a0,0x4
    3af0:	d8c50513          	addi	a0,a0,-628 # 7878 <malloc+0x1de0>
    3af4:	00002097          	auipc	ra,0x2
    3af8:	ee4080e7          	jalr	-284(ra) # 59d8 <printf>
    exit(1);
    3afc:	4505                	li	a0,1
    3afe:	00002097          	auipc	ra,0x2
    3b02:	b62080e7          	jalr	-1182(ra) # 5660 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    3b06:	85ca                	mv	a1,s2
    3b08:	00004517          	auipc	a0,0x4
    3b0c:	d9050513          	addi	a0,a0,-624 # 7898 <malloc+0x1e00>
    3b10:	00002097          	auipc	ra,0x2
    3b14:	ec8080e7          	jalr	-312(ra) # 59d8 <printf>
    exit(1);
    3b18:	4505                	li	a0,1
    3b1a:	00002097          	auipc	ra,0x2
    3b1e:	b46080e7          	jalr	-1210(ra) # 5660 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3b22:	85ca                	mv	a1,s2
    3b24:	00004517          	auipc	a0,0x4
    3b28:	da450513          	addi	a0,a0,-604 # 78c8 <malloc+0x1e30>
    3b2c:	00002097          	auipc	ra,0x2
    3b30:	eac080e7          	jalr	-340(ra) # 59d8 <printf>
    exit(1);
    3b34:	4505                	li	a0,1
    3b36:	00002097          	auipc	ra,0x2
    3b3a:	b2a080e7          	jalr	-1238(ra) # 5660 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3b3e:	85ca                	mv	a1,s2
    3b40:	00004517          	auipc	a0,0x4
    3b44:	d8850513          	addi	a0,a0,-632 # 78c8 <malloc+0x1e30>
    3b48:	00002097          	auipc	ra,0x2
    3b4c:	e90080e7          	jalr	-368(ra) # 59d8 <printf>
    exit(1);
    3b50:	4505                	li	a0,1
    3b52:	00002097          	auipc	ra,0x2
    3b56:	b0e080e7          	jalr	-1266(ra) # 5660 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3b5a:	85ca                	mv	a1,s2
    3b5c:	00004517          	auipc	a0,0x4
    3b60:	d9450513          	addi	a0,a0,-620 # 78f0 <malloc+0x1e58>
    3b64:	00002097          	auipc	ra,0x2
    3b68:	e74080e7          	jalr	-396(ra) # 59d8 <printf>
    exit(1);
    3b6c:	4505                	li	a0,1
    3b6e:	00002097          	auipc	ra,0x2
    3b72:	af2080e7          	jalr	-1294(ra) # 5660 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3b76:	85ca                	mv	a1,s2
    3b78:	00004517          	auipc	a0,0x4
    3b7c:	da050513          	addi	a0,a0,-608 # 7918 <malloc+0x1e80>
    3b80:	00002097          	auipc	ra,0x2
    3b84:	e58080e7          	jalr	-424(ra) # 59d8 <printf>
    exit(1);
    3b88:	4505                	li	a0,1
    3b8a:	00002097          	auipc	ra,0x2
    3b8e:	ad6080e7          	jalr	-1322(ra) # 5660 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3b92:	85ca                	mv	a1,s2
    3b94:	00004517          	auipc	a0,0x4
    3b98:	dac50513          	addi	a0,a0,-596 # 7940 <malloc+0x1ea8>
    3b9c:	00002097          	auipc	ra,0x2
    3ba0:	e3c080e7          	jalr	-452(ra) # 59d8 <printf>
    exit(1);
    3ba4:	4505                	li	a0,1
    3ba6:	00002097          	auipc	ra,0x2
    3baa:	aba080e7          	jalr	-1350(ra) # 5660 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3bae:	85ca                	mv	a1,s2
    3bb0:	00004517          	auipc	a0,0x4
    3bb4:	db850513          	addi	a0,a0,-584 # 7968 <malloc+0x1ed0>
    3bb8:	00002097          	auipc	ra,0x2
    3bbc:	e20080e7          	jalr	-480(ra) # 59d8 <printf>
    exit(1);
    3bc0:	4505                	li	a0,1
    3bc2:	00002097          	auipc	ra,0x2
    3bc6:	a9e080e7          	jalr	-1378(ra) # 5660 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3bca:	85ca                	mv	a1,s2
    3bcc:	00004517          	auipc	a0,0x4
    3bd0:	dbc50513          	addi	a0,a0,-580 # 7988 <malloc+0x1ef0>
    3bd4:	00002097          	auipc	ra,0x2
    3bd8:	e04080e7          	jalr	-508(ra) # 59d8 <printf>
    exit(1);
    3bdc:	4505                	li	a0,1
    3bde:	00002097          	auipc	ra,0x2
    3be2:	a82080e7          	jalr	-1406(ra) # 5660 <exit>
    printf("%s: write . succeeded!\n", s);
    3be6:	85ca                	mv	a1,s2
    3be8:	00004517          	auipc	a0,0x4
    3bec:	dc850513          	addi	a0,a0,-568 # 79b0 <malloc+0x1f18>
    3bf0:	00002097          	auipc	ra,0x2
    3bf4:	de8080e7          	jalr	-536(ra) # 59d8 <printf>
    exit(1);
    3bf8:	4505                	li	a0,1
    3bfa:	00002097          	auipc	ra,0x2
    3bfe:	a66080e7          	jalr	-1434(ra) # 5660 <exit>

0000000000003c02 <iref>:
{
    3c02:	7139                	addi	sp,sp,-64
    3c04:	fc06                	sd	ra,56(sp)
    3c06:	f822                	sd	s0,48(sp)
    3c08:	f426                	sd	s1,40(sp)
    3c0a:	f04a                	sd	s2,32(sp)
    3c0c:	ec4e                	sd	s3,24(sp)
    3c0e:	e852                	sd	s4,16(sp)
    3c10:	e456                	sd	s5,8(sp)
    3c12:	e05a                	sd	s6,0(sp)
    3c14:	0080                	addi	s0,sp,64
    3c16:	8b2a                	mv	s6,a0
    3c18:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    3c1c:	00004a17          	auipc	s4,0x4
    3c20:	daca0a13          	addi	s4,s4,-596 # 79c8 <malloc+0x1f30>
    mkdir("");
    3c24:	00004497          	auipc	s1,0x4
    3c28:	8ac48493          	addi	s1,s1,-1876 # 74d0 <malloc+0x1a38>
    link("README", "");
    3c2c:	00002a97          	auipc	s5,0x2
    3c30:	504a8a93          	addi	s5,s5,1284 # 6130 <malloc+0x698>
    fd = open("xx", O_CREATE);
    3c34:	00004997          	auipc	s3,0x4
    3c38:	c8c98993          	addi	s3,s3,-884 # 78c0 <malloc+0x1e28>
    3c3c:	a891                	j	3c90 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3c3e:	85da                	mv	a1,s6
    3c40:	00004517          	auipc	a0,0x4
    3c44:	d9050513          	addi	a0,a0,-624 # 79d0 <malloc+0x1f38>
    3c48:	00002097          	auipc	ra,0x2
    3c4c:	d90080e7          	jalr	-624(ra) # 59d8 <printf>
      exit(1);
    3c50:	4505                	li	a0,1
    3c52:	00002097          	auipc	ra,0x2
    3c56:	a0e080e7          	jalr	-1522(ra) # 5660 <exit>
      printf("%s: chdir irefd failed\n", s);
    3c5a:	85da                	mv	a1,s6
    3c5c:	00004517          	auipc	a0,0x4
    3c60:	d8c50513          	addi	a0,a0,-628 # 79e8 <malloc+0x1f50>
    3c64:	00002097          	auipc	ra,0x2
    3c68:	d74080e7          	jalr	-652(ra) # 59d8 <printf>
      exit(1);
    3c6c:	4505                	li	a0,1
    3c6e:	00002097          	auipc	ra,0x2
    3c72:	9f2080e7          	jalr	-1550(ra) # 5660 <exit>
      close(fd);
    3c76:	00002097          	auipc	ra,0x2
    3c7a:	a12080e7          	jalr	-1518(ra) # 5688 <close>
    3c7e:	a889                	j	3cd0 <iref+0xce>
    unlink("xx");
    3c80:	854e                	mv	a0,s3
    3c82:	00002097          	auipc	ra,0x2
    3c86:	a2e080e7          	jalr	-1490(ra) # 56b0 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3c8a:	397d                	addiw	s2,s2,-1
    3c8c:	06090063          	beqz	s2,3cec <iref+0xea>
    if(mkdir("irefd") != 0){
    3c90:	8552                	mv	a0,s4
    3c92:	00002097          	auipc	ra,0x2
    3c96:	a36080e7          	jalr	-1482(ra) # 56c8 <mkdir>
    3c9a:	f155                	bnez	a0,3c3e <iref+0x3c>
    if(chdir("irefd") != 0){
    3c9c:	8552                	mv	a0,s4
    3c9e:	00002097          	auipc	ra,0x2
    3ca2:	a32080e7          	jalr	-1486(ra) # 56d0 <chdir>
    3ca6:	f955                	bnez	a0,3c5a <iref+0x58>
    mkdir("");
    3ca8:	8526                	mv	a0,s1
    3caa:	00002097          	auipc	ra,0x2
    3cae:	a1e080e7          	jalr	-1506(ra) # 56c8 <mkdir>
    link("README", "");
    3cb2:	85a6                	mv	a1,s1
    3cb4:	8556                	mv	a0,s5
    3cb6:	00002097          	auipc	ra,0x2
    3cba:	a0a080e7          	jalr	-1526(ra) # 56c0 <link>
    fd = open("", O_CREATE);
    3cbe:	20000593          	li	a1,512
    3cc2:	8526                	mv	a0,s1
    3cc4:	00002097          	auipc	ra,0x2
    3cc8:	9dc080e7          	jalr	-1572(ra) # 56a0 <open>
    if(fd >= 0)
    3ccc:	fa0555e3          	bgez	a0,3c76 <iref+0x74>
    fd = open("xx", O_CREATE);
    3cd0:	20000593          	li	a1,512
    3cd4:	854e                	mv	a0,s3
    3cd6:	00002097          	auipc	ra,0x2
    3cda:	9ca080e7          	jalr	-1590(ra) # 56a0 <open>
    if(fd >= 0)
    3cde:	fa0541e3          	bltz	a0,3c80 <iref+0x7e>
      close(fd);
    3ce2:	00002097          	auipc	ra,0x2
    3ce6:	9a6080e7          	jalr	-1626(ra) # 5688 <close>
    3cea:	bf59                	j	3c80 <iref+0x7e>
    3cec:	03300493          	li	s1,51
    chdir("..");
    3cf0:	00003997          	auipc	s3,0x3
    3cf4:	50098993          	addi	s3,s3,1280 # 71f0 <malloc+0x1758>
    unlink("irefd");
    3cf8:	00004917          	auipc	s2,0x4
    3cfc:	cd090913          	addi	s2,s2,-816 # 79c8 <malloc+0x1f30>
    chdir("..");
    3d00:	854e                	mv	a0,s3
    3d02:	00002097          	auipc	ra,0x2
    3d06:	9ce080e7          	jalr	-1586(ra) # 56d0 <chdir>
    unlink("irefd");
    3d0a:	854a                	mv	a0,s2
    3d0c:	00002097          	auipc	ra,0x2
    3d10:	9a4080e7          	jalr	-1628(ra) # 56b0 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3d14:	34fd                	addiw	s1,s1,-1
    3d16:	f4ed                	bnez	s1,3d00 <iref+0xfe>
  chdir("/");
    3d18:	00003517          	auipc	a0,0x3
    3d1c:	48050513          	addi	a0,a0,1152 # 7198 <malloc+0x1700>
    3d20:	00002097          	auipc	ra,0x2
    3d24:	9b0080e7          	jalr	-1616(ra) # 56d0 <chdir>
}
    3d28:	70e2                	ld	ra,56(sp)
    3d2a:	7442                	ld	s0,48(sp)
    3d2c:	74a2                	ld	s1,40(sp)
    3d2e:	7902                	ld	s2,32(sp)
    3d30:	69e2                	ld	s3,24(sp)
    3d32:	6a42                	ld	s4,16(sp)
    3d34:	6aa2                	ld	s5,8(sp)
    3d36:	6b02                	ld	s6,0(sp)
    3d38:	6121                	addi	sp,sp,64
    3d3a:	8082                	ret

0000000000003d3c <openiputtest>:
{
    3d3c:	7179                	addi	sp,sp,-48
    3d3e:	f406                	sd	ra,40(sp)
    3d40:	f022                	sd	s0,32(sp)
    3d42:	ec26                	sd	s1,24(sp)
    3d44:	1800                	addi	s0,sp,48
    3d46:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3d48:	00004517          	auipc	a0,0x4
    3d4c:	cb850513          	addi	a0,a0,-840 # 7a00 <malloc+0x1f68>
    3d50:	00002097          	auipc	ra,0x2
    3d54:	978080e7          	jalr	-1672(ra) # 56c8 <mkdir>
    3d58:	04054263          	bltz	a0,3d9c <openiputtest+0x60>
  pid = fork();
    3d5c:	00002097          	auipc	ra,0x2
    3d60:	8fc080e7          	jalr	-1796(ra) # 5658 <fork>
  if(pid < 0){
    3d64:	04054a63          	bltz	a0,3db8 <openiputtest+0x7c>
  if(pid == 0){
    3d68:	e93d                	bnez	a0,3dde <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    3d6a:	4589                	li	a1,2
    3d6c:	00004517          	auipc	a0,0x4
    3d70:	c9450513          	addi	a0,a0,-876 # 7a00 <malloc+0x1f68>
    3d74:	00002097          	auipc	ra,0x2
    3d78:	92c080e7          	jalr	-1748(ra) # 56a0 <open>
    if(fd >= 0){
    3d7c:	04054c63          	bltz	a0,3dd4 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    3d80:	85a6                	mv	a1,s1
    3d82:	00004517          	auipc	a0,0x4
    3d86:	c9e50513          	addi	a0,a0,-866 # 7a20 <malloc+0x1f88>
    3d8a:	00002097          	auipc	ra,0x2
    3d8e:	c4e080e7          	jalr	-946(ra) # 59d8 <printf>
      exit(1);
    3d92:	4505                	li	a0,1
    3d94:	00002097          	auipc	ra,0x2
    3d98:	8cc080e7          	jalr	-1844(ra) # 5660 <exit>
    printf("%s: mkdir oidir failed\n", s);
    3d9c:	85a6                	mv	a1,s1
    3d9e:	00004517          	auipc	a0,0x4
    3da2:	c6a50513          	addi	a0,a0,-918 # 7a08 <malloc+0x1f70>
    3da6:	00002097          	auipc	ra,0x2
    3daa:	c32080e7          	jalr	-974(ra) # 59d8 <printf>
    exit(1);
    3dae:	4505                	li	a0,1
    3db0:	00002097          	auipc	ra,0x2
    3db4:	8b0080e7          	jalr	-1872(ra) # 5660 <exit>
    printf("%s: fork failed\n", s);
    3db8:	85a6                	mv	a1,s1
    3dba:	00003517          	auipc	a0,0x3
    3dbe:	a2650513          	addi	a0,a0,-1498 # 67e0 <malloc+0xd48>
    3dc2:	00002097          	auipc	ra,0x2
    3dc6:	c16080e7          	jalr	-1002(ra) # 59d8 <printf>
    exit(1);
    3dca:	4505                	li	a0,1
    3dcc:	00002097          	auipc	ra,0x2
    3dd0:	894080e7          	jalr	-1900(ra) # 5660 <exit>
    exit(0);
    3dd4:	4501                	li	a0,0
    3dd6:	00002097          	auipc	ra,0x2
    3dda:	88a080e7          	jalr	-1910(ra) # 5660 <exit>
  sleep(1);
    3dde:	4505                	li	a0,1
    3de0:	00002097          	auipc	ra,0x2
    3de4:	910080e7          	jalr	-1776(ra) # 56f0 <sleep>
  if(unlink("oidir") != 0){
    3de8:	00004517          	auipc	a0,0x4
    3dec:	c1850513          	addi	a0,a0,-1000 # 7a00 <malloc+0x1f68>
    3df0:	00002097          	auipc	ra,0x2
    3df4:	8c0080e7          	jalr	-1856(ra) # 56b0 <unlink>
    3df8:	cd19                	beqz	a0,3e16 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3dfa:	85a6                	mv	a1,s1
    3dfc:	00003517          	auipc	a0,0x3
    3e00:	bd450513          	addi	a0,a0,-1068 # 69d0 <malloc+0xf38>
    3e04:	00002097          	auipc	ra,0x2
    3e08:	bd4080e7          	jalr	-1068(ra) # 59d8 <printf>
    exit(1);
    3e0c:	4505                	li	a0,1
    3e0e:	00002097          	auipc	ra,0x2
    3e12:	852080e7          	jalr	-1966(ra) # 5660 <exit>
  wait(&xstatus);
    3e16:	fdc40513          	addi	a0,s0,-36
    3e1a:	00002097          	auipc	ra,0x2
    3e1e:	84e080e7          	jalr	-1970(ra) # 5668 <wait>
  exit(xstatus);
    3e22:	fdc42503          	lw	a0,-36(s0)
    3e26:	00002097          	auipc	ra,0x2
    3e2a:	83a080e7          	jalr	-1990(ra) # 5660 <exit>

0000000000003e2e <forkforkfork>:
{
    3e2e:	1101                	addi	sp,sp,-32
    3e30:	ec06                	sd	ra,24(sp)
    3e32:	e822                	sd	s0,16(sp)
    3e34:	e426                	sd	s1,8(sp)
    3e36:	1000                	addi	s0,sp,32
    3e38:	84aa                	mv	s1,a0
  unlink("stopforking");
    3e3a:	00004517          	auipc	a0,0x4
    3e3e:	c0e50513          	addi	a0,a0,-1010 # 7a48 <malloc+0x1fb0>
    3e42:	00002097          	auipc	ra,0x2
    3e46:	86e080e7          	jalr	-1938(ra) # 56b0 <unlink>
  int pid = fork();
    3e4a:	00002097          	auipc	ra,0x2
    3e4e:	80e080e7          	jalr	-2034(ra) # 5658 <fork>
  if(pid < 0){
    3e52:	04054563          	bltz	a0,3e9c <forkforkfork+0x6e>
  if(pid == 0){
    3e56:	c12d                	beqz	a0,3eb8 <forkforkfork+0x8a>
  sleep(20); // two seconds
    3e58:	4551                	li	a0,20
    3e5a:	00002097          	auipc	ra,0x2
    3e5e:	896080e7          	jalr	-1898(ra) # 56f0 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3e62:	20200593          	li	a1,514
    3e66:	00004517          	auipc	a0,0x4
    3e6a:	be250513          	addi	a0,a0,-1054 # 7a48 <malloc+0x1fb0>
    3e6e:	00002097          	auipc	ra,0x2
    3e72:	832080e7          	jalr	-1998(ra) # 56a0 <open>
    3e76:	00002097          	auipc	ra,0x2
    3e7a:	812080e7          	jalr	-2030(ra) # 5688 <close>
  wait(0);
    3e7e:	4501                	li	a0,0
    3e80:	00001097          	auipc	ra,0x1
    3e84:	7e8080e7          	jalr	2024(ra) # 5668 <wait>
  sleep(10); // one second
    3e88:	4529                	li	a0,10
    3e8a:	00002097          	auipc	ra,0x2
    3e8e:	866080e7          	jalr	-1946(ra) # 56f0 <sleep>
}
    3e92:	60e2                	ld	ra,24(sp)
    3e94:	6442                	ld	s0,16(sp)
    3e96:	64a2                	ld	s1,8(sp)
    3e98:	6105                	addi	sp,sp,32
    3e9a:	8082                	ret
    printf("%s: fork failed", s);
    3e9c:	85a6                	mv	a1,s1
    3e9e:	00003517          	auipc	a0,0x3
    3ea2:	b0250513          	addi	a0,a0,-1278 # 69a0 <malloc+0xf08>
    3ea6:	00002097          	auipc	ra,0x2
    3eaa:	b32080e7          	jalr	-1230(ra) # 59d8 <printf>
    exit(1);
    3eae:	4505                	li	a0,1
    3eb0:	00001097          	auipc	ra,0x1
    3eb4:	7b0080e7          	jalr	1968(ra) # 5660 <exit>
      int fd = open("stopforking", 0);
    3eb8:	00004497          	auipc	s1,0x4
    3ebc:	b9048493          	addi	s1,s1,-1136 # 7a48 <malloc+0x1fb0>
    3ec0:	4581                	li	a1,0
    3ec2:	8526                	mv	a0,s1
    3ec4:	00001097          	auipc	ra,0x1
    3ec8:	7dc080e7          	jalr	2012(ra) # 56a0 <open>
      if(fd >= 0){
    3ecc:	02055463          	bgez	a0,3ef4 <forkforkfork+0xc6>
      if(fork() < 0){
    3ed0:	00001097          	auipc	ra,0x1
    3ed4:	788080e7          	jalr	1928(ra) # 5658 <fork>
    3ed8:	fe0554e3          	bgez	a0,3ec0 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    3edc:	20200593          	li	a1,514
    3ee0:	8526                	mv	a0,s1
    3ee2:	00001097          	auipc	ra,0x1
    3ee6:	7be080e7          	jalr	1982(ra) # 56a0 <open>
    3eea:	00001097          	auipc	ra,0x1
    3eee:	79e080e7          	jalr	1950(ra) # 5688 <close>
    3ef2:	b7f9                	j	3ec0 <forkforkfork+0x92>
        exit(0);
    3ef4:	4501                	li	a0,0
    3ef6:	00001097          	auipc	ra,0x1
    3efa:	76a080e7          	jalr	1898(ra) # 5660 <exit>

0000000000003efe <preempt>:
{
    3efe:	7139                	addi	sp,sp,-64
    3f00:	fc06                	sd	ra,56(sp)
    3f02:	f822                	sd	s0,48(sp)
    3f04:	f426                	sd	s1,40(sp)
    3f06:	f04a                	sd	s2,32(sp)
    3f08:	ec4e                	sd	s3,24(sp)
    3f0a:	e852                	sd	s4,16(sp)
    3f0c:	0080                	addi	s0,sp,64
    3f0e:	8a2a                	mv	s4,a0
  pid1 = fork();
    3f10:	00001097          	auipc	ra,0x1
    3f14:	748080e7          	jalr	1864(ra) # 5658 <fork>
  if(pid1 < 0) {
    3f18:	00054563          	bltz	a0,3f22 <preempt+0x24>
    3f1c:	89aa                	mv	s3,a0
  if(pid1 == 0)
    3f1e:	e105                	bnez	a0,3f3e <preempt+0x40>
    for(;;)
    3f20:	a001                	j	3f20 <preempt+0x22>
    printf("%s: fork failed", s);
    3f22:	85d2                	mv	a1,s4
    3f24:	00003517          	auipc	a0,0x3
    3f28:	a7c50513          	addi	a0,a0,-1412 # 69a0 <malloc+0xf08>
    3f2c:	00002097          	auipc	ra,0x2
    3f30:	aac080e7          	jalr	-1364(ra) # 59d8 <printf>
    exit(1);
    3f34:	4505                	li	a0,1
    3f36:	00001097          	auipc	ra,0x1
    3f3a:	72a080e7          	jalr	1834(ra) # 5660 <exit>
  pid2 = fork();
    3f3e:	00001097          	auipc	ra,0x1
    3f42:	71a080e7          	jalr	1818(ra) # 5658 <fork>
    3f46:	892a                	mv	s2,a0
  if(pid2 < 0) {
    3f48:	00054463          	bltz	a0,3f50 <preempt+0x52>
  if(pid2 == 0)
    3f4c:	e105                	bnez	a0,3f6c <preempt+0x6e>
    for(;;)
    3f4e:	a001                	j	3f4e <preempt+0x50>
    printf("%s: fork failed\n", s);
    3f50:	85d2                	mv	a1,s4
    3f52:	00003517          	auipc	a0,0x3
    3f56:	88e50513          	addi	a0,a0,-1906 # 67e0 <malloc+0xd48>
    3f5a:	00002097          	auipc	ra,0x2
    3f5e:	a7e080e7          	jalr	-1410(ra) # 59d8 <printf>
    exit(1);
    3f62:	4505                	li	a0,1
    3f64:	00001097          	auipc	ra,0x1
    3f68:	6fc080e7          	jalr	1788(ra) # 5660 <exit>
  pipe(pfds);
    3f6c:	fc840513          	addi	a0,s0,-56
    3f70:	00001097          	auipc	ra,0x1
    3f74:	700080e7          	jalr	1792(ra) # 5670 <pipe>
  pid3 = fork();
    3f78:	00001097          	auipc	ra,0x1
    3f7c:	6e0080e7          	jalr	1760(ra) # 5658 <fork>
    3f80:	84aa                	mv	s1,a0
  if(pid3 < 0) {
    3f82:	02054e63          	bltz	a0,3fbe <preempt+0xc0>
  if(pid3 == 0){
    3f86:	e525                	bnez	a0,3fee <preempt+0xf0>
    close(pfds[0]);
    3f88:	fc842503          	lw	a0,-56(s0)
    3f8c:	00001097          	auipc	ra,0x1
    3f90:	6fc080e7          	jalr	1788(ra) # 5688 <close>
    if(write(pfds[1], "x", 1) != 1)
    3f94:	4605                	li	a2,1
    3f96:	00002597          	auipc	a1,0x2
    3f9a:	06258593          	addi	a1,a1,98 # 5ff8 <malloc+0x560>
    3f9e:	fcc42503          	lw	a0,-52(s0)
    3fa2:	00001097          	auipc	ra,0x1
    3fa6:	6de080e7          	jalr	1758(ra) # 5680 <write>
    3faa:	4785                	li	a5,1
    3fac:	02f51763          	bne	a0,a5,3fda <preempt+0xdc>
    close(pfds[1]);
    3fb0:	fcc42503          	lw	a0,-52(s0)
    3fb4:	00001097          	auipc	ra,0x1
    3fb8:	6d4080e7          	jalr	1748(ra) # 5688 <close>
    for(;;)
    3fbc:	a001                	j	3fbc <preempt+0xbe>
     printf("%s: fork failed\n", s);
    3fbe:	85d2                	mv	a1,s4
    3fc0:	00003517          	auipc	a0,0x3
    3fc4:	82050513          	addi	a0,a0,-2016 # 67e0 <malloc+0xd48>
    3fc8:	00002097          	auipc	ra,0x2
    3fcc:	a10080e7          	jalr	-1520(ra) # 59d8 <printf>
     exit(1);
    3fd0:	4505                	li	a0,1
    3fd2:	00001097          	auipc	ra,0x1
    3fd6:	68e080e7          	jalr	1678(ra) # 5660 <exit>
      printf("%s: preempt write error", s);
    3fda:	85d2                	mv	a1,s4
    3fdc:	00004517          	auipc	a0,0x4
    3fe0:	a7c50513          	addi	a0,a0,-1412 # 7a58 <malloc+0x1fc0>
    3fe4:	00002097          	auipc	ra,0x2
    3fe8:	9f4080e7          	jalr	-1548(ra) # 59d8 <printf>
    3fec:	b7d1                	j	3fb0 <preempt+0xb2>
  close(pfds[1]);
    3fee:	fcc42503          	lw	a0,-52(s0)
    3ff2:	00001097          	auipc	ra,0x1
    3ff6:	696080e7          	jalr	1686(ra) # 5688 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    3ffa:	660d                	lui	a2,0x3
    3ffc:	00008597          	auipc	a1,0x8
    4000:	af458593          	addi	a1,a1,-1292 # baf0 <buf>
    4004:	fc842503          	lw	a0,-56(s0)
    4008:	00001097          	auipc	ra,0x1
    400c:	670080e7          	jalr	1648(ra) # 5678 <read>
    4010:	4785                	li	a5,1
    4012:	02f50363          	beq	a0,a5,4038 <preempt+0x13a>
    printf("%s: preempt read error", s);
    4016:	85d2                	mv	a1,s4
    4018:	00004517          	auipc	a0,0x4
    401c:	a5850513          	addi	a0,a0,-1448 # 7a70 <malloc+0x1fd8>
    4020:	00002097          	auipc	ra,0x2
    4024:	9b8080e7          	jalr	-1608(ra) # 59d8 <printf>
}
    4028:	70e2                	ld	ra,56(sp)
    402a:	7442                	ld	s0,48(sp)
    402c:	74a2                	ld	s1,40(sp)
    402e:	7902                	ld	s2,32(sp)
    4030:	69e2                	ld	s3,24(sp)
    4032:	6a42                	ld	s4,16(sp)
    4034:	6121                	addi	sp,sp,64
    4036:	8082                	ret
  close(pfds[0]);
    4038:	fc842503          	lw	a0,-56(s0)
    403c:	00001097          	auipc	ra,0x1
    4040:	64c080e7          	jalr	1612(ra) # 5688 <close>
  printf("kill... ");
    4044:	00004517          	auipc	a0,0x4
    4048:	a4450513          	addi	a0,a0,-1468 # 7a88 <malloc+0x1ff0>
    404c:	00002097          	auipc	ra,0x2
    4050:	98c080e7          	jalr	-1652(ra) # 59d8 <printf>
  kill(pid1);
    4054:	854e                	mv	a0,s3
    4056:	00001097          	auipc	ra,0x1
    405a:	63a080e7          	jalr	1594(ra) # 5690 <kill>
  kill(pid2);
    405e:	854a                	mv	a0,s2
    4060:	00001097          	auipc	ra,0x1
    4064:	630080e7          	jalr	1584(ra) # 5690 <kill>
  kill(pid3);
    4068:	8526                	mv	a0,s1
    406a:	00001097          	auipc	ra,0x1
    406e:	626080e7          	jalr	1574(ra) # 5690 <kill>
  printf("wait... ");
    4072:	00004517          	auipc	a0,0x4
    4076:	a2650513          	addi	a0,a0,-1498 # 7a98 <malloc+0x2000>
    407a:	00002097          	auipc	ra,0x2
    407e:	95e080e7          	jalr	-1698(ra) # 59d8 <printf>
  wait(0);
    4082:	4501                	li	a0,0
    4084:	00001097          	auipc	ra,0x1
    4088:	5e4080e7          	jalr	1508(ra) # 5668 <wait>
  wait(0);
    408c:	4501                	li	a0,0
    408e:	00001097          	auipc	ra,0x1
    4092:	5da080e7          	jalr	1498(ra) # 5668 <wait>
  wait(0);
    4096:	4501                	li	a0,0
    4098:	00001097          	auipc	ra,0x1
    409c:	5d0080e7          	jalr	1488(ra) # 5668 <wait>
    40a0:	b761                	j	4028 <preempt+0x12a>

00000000000040a2 <sbrkfail>:
{
    40a2:	7119                	addi	sp,sp,-128
    40a4:	fc86                	sd	ra,120(sp)
    40a6:	f8a2                	sd	s0,112(sp)
    40a8:	f4a6                	sd	s1,104(sp)
    40aa:	f0ca                	sd	s2,96(sp)
    40ac:	ecce                	sd	s3,88(sp)
    40ae:	e8d2                	sd	s4,80(sp)
    40b0:	e4d6                	sd	s5,72(sp)
    40b2:	0100                	addi	s0,sp,128
    40b4:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    40b6:	fb040513          	addi	a0,s0,-80
    40ba:	00001097          	auipc	ra,0x1
    40be:	5b6080e7          	jalr	1462(ra) # 5670 <pipe>
    40c2:	e901                	bnez	a0,40d2 <sbrkfail+0x30>
    40c4:	f8040493          	addi	s1,s0,-128
    40c8:	fa840993          	addi	s3,s0,-88
    40cc:	8926                	mv	s2,s1
    if(pids[i] != -1)
    40ce:	5a7d                	li	s4,-1
    40d0:	a085                	j	4130 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    40d2:	85d6                	mv	a1,s5
    40d4:	00003517          	auipc	a0,0x3
    40d8:	81450513          	addi	a0,a0,-2028 # 68e8 <malloc+0xe50>
    40dc:	00002097          	auipc	ra,0x2
    40e0:	8fc080e7          	jalr	-1796(ra) # 59d8 <printf>
    exit(1);
    40e4:	4505                	li	a0,1
    40e6:	00001097          	auipc	ra,0x1
    40ea:	57a080e7          	jalr	1402(ra) # 5660 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    40ee:	00001097          	auipc	ra,0x1
    40f2:	5fa080e7          	jalr	1530(ra) # 56e8 <sbrk>
    40f6:	064007b7          	lui	a5,0x6400
    40fa:	40a7853b          	subw	a0,a5,a0
    40fe:	00001097          	auipc	ra,0x1
    4102:	5ea080e7          	jalr	1514(ra) # 56e8 <sbrk>
      write(fds[1], "x", 1);
    4106:	4605                	li	a2,1
    4108:	00002597          	auipc	a1,0x2
    410c:	ef058593          	addi	a1,a1,-272 # 5ff8 <malloc+0x560>
    4110:	fb442503          	lw	a0,-76(s0)
    4114:	00001097          	auipc	ra,0x1
    4118:	56c080e7          	jalr	1388(ra) # 5680 <write>
      for(;;) sleep(1000);
    411c:	3e800513          	li	a0,1000
    4120:	00001097          	auipc	ra,0x1
    4124:	5d0080e7          	jalr	1488(ra) # 56f0 <sleep>
    4128:	bfd5                	j	411c <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    412a:	0911                	addi	s2,s2,4
    412c:	03390563          	beq	s2,s3,4156 <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    4130:	00001097          	auipc	ra,0x1
    4134:	528080e7          	jalr	1320(ra) # 5658 <fork>
    4138:	00a92023          	sw	a0,0(s2)
    413c:	d94d                	beqz	a0,40ee <sbrkfail+0x4c>
    if(pids[i] != -1)
    413e:	ff4506e3          	beq	a0,s4,412a <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    4142:	4605                	li	a2,1
    4144:	faf40593          	addi	a1,s0,-81
    4148:	fb042503          	lw	a0,-80(s0)
    414c:	00001097          	auipc	ra,0x1
    4150:	52c080e7          	jalr	1324(ra) # 5678 <read>
    4154:	bfd9                	j	412a <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    4156:	6505                	lui	a0,0x1
    4158:	00001097          	auipc	ra,0x1
    415c:	590080e7          	jalr	1424(ra) # 56e8 <sbrk>
    4160:	892a                	mv	s2,a0
    if(pids[i] == -1)
    4162:	5a7d                	li	s4,-1
    4164:	a021                	j	416c <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4166:	0491                	addi	s1,s1,4
    4168:	01348f63          	beq	s1,s3,4186 <sbrkfail+0xe4>
    if(pids[i] == -1)
    416c:	4088                	lw	a0,0(s1)
    416e:	ff450ce3          	beq	a0,s4,4166 <sbrkfail+0xc4>
    kill(pids[i]);
    4172:	00001097          	auipc	ra,0x1
    4176:	51e080e7          	jalr	1310(ra) # 5690 <kill>
    wait(0);
    417a:	4501                	li	a0,0
    417c:	00001097          	auipc	ra,0x1
    4180:	4ec080e7          	jalr	1260(ra) # 5668 <wait>
    4184:	b7cd                	j	4166 <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    4186:	57fd                	li	a5,-1
    4188:	04f90163          	beq	s2,a5,41ca <sbrkfail+0x128>
  pid = fork();
    418c:	00001097          	auipc	ra,0x1
    4190:	4cc080e7          	jalr	1228(ra) # 5658 <fork>
    4194:	84aa                	mv	s1,a0
  if(pid < 0){
    4196:	04054863          	bltz	a0,41e6 <sbrkfail+0x144>
  if(pid == 0){
    419a:	c525                	beqz	a0,4202 <sbrkfail+0x160>
  wait(&xstatus);
    419c:	fbc40513          	addi	a0,s0,-68
    41a0:	00001097          	auipc	ra,0x1
    41a4:	4c8080e7          	jalr	1224(ra) # 5668 <wait>
  if(xstatus != -1 && xstatus != 2)
    41a8:	fbc42783          	lw	a5,-68(s0)
    41ac:	577d                	li	a4,-1
    41ae:	00e78563          	beq	a5,a4,41b8 <sbrkfail+0x116>
    41b2:	4709                	li	a4,2
    41b4:	08e79d63          	bne	a5,a4,424e <sbrkfail+0x1ac>
}
    41b8:	70e6                	ld	ra,120(sp)
    41ba:	7446                	ld	s0,112(sp)
    41bc:	74a6                	ld	s1,104(sp)
    41be:	7906                	ld	s2,96(sp)
    41c0:	69e6                	ld	s3,88(sp)
    41c2:	6a46                	ld	s4,80(sp)
    41c4:	6aa6                	ld	s5,72(sp)
    41c6:	6109                	addi	sp,sp,128
    41c8:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    41ca:	85d6                	mv	a1,s5
    41cc:	00004517          	auipc	a0,0x4
    41d0:	8dc50513          	addi	a0,a0,-1828 # 7aa8 <malloc+0x2010>
    41d4:	00002097          	auipc	ra,0x2
    41d8:	804080e7          	jalr	-2044(ra) # 59d8 <printf>
    exit(1);
    41dc:	4505                	li	a0,1
    41de:	00001097          	auipc	ra,0x1
    41e2:	482080e7          	jalr	1154(ra) # 5660 <exit>
    printf("%s: fork failed\n", s);
    41e6:	85d6                	mv	a1,s5
    41e8:	00002517          	auipc	a0,0x2
    41ec:	5f850513          	addi	a0,a0,1528 # 67e0 <malloc+0xd48>
    41f0:	00001097          	auipc	ra,0x1
    41f4:	7e8080e7          	jalr	2024(ra) # 59d8 <printf>
    exit(1);
    41f8:	4505                	li	a0,1
    41fa:	00001097          	auipc	ra,0x1
    41fe:	466080e7          	jalr	1126(ra) # 5660 <exit>
    a = sbrk(0);
    4202:	4501                	li	a0,0
    4204:	00001097          	auipc	ra,0x1
    4208:	4e4080e7          	jalr	1252(ra) # 56e8 <sbrk>
    420c:	892a                	mv	s2,a0
    sbrk(10*BIG);
    420e:	3e800537          	lui	a0,0x3e800
    4212:	00001097          	auipc	ra,0x1
    4216:	4d6080e7          	jalr	1238(ra) # 56e8 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    421a:	874a                	mv	a4,s2
    421c:	3e8007b7          	lui	a5,0x3e800
    4220:	97ca                	add	a5,a5,s2
    4222:	6685                	lui	a3,0x1
      n += *(a+i);
    4224:	00074603          	lbu	a2,0(a4)
    4228:	9cb1                	addw	s1,s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    422a:	9736                	add	a4,a4,a3
    422c:	fee79ce3          	bne	a5,a4,4224 <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4230:	8626                	mv	a2,s1
    4232:	85d6                	mv	a1,s5
    4234:	00004517          	auipc	a0,0x4
    4238:	89450513          	addi	a0,a0,-1900 # 7ac8 <malloc+0x2030>
    423c:	00001097          	auipc	ra,0x1
    4240:	79c080e7          	jalr	1948(ra) # 59d8 <printf>
    exit(1);
    4244:	4505                	li	a0,1
    4246:	00001097          	auipc	ra,0x1
    424a:	41a080e7          	jalr	1050(ra) # 5660 <exit>
    exit(1);
    424e:	4505                	li	a0,1
    4250:	00001097          	auipc	ra,0x1
    4254:	410080e7          	jalr	1040(ra) # 5660 <exit>

0000000000004258 <reparent>:
{
    4258:	7179                	addi	sp,sp,-48
    425a:	f406                	sd	ra,40(sp)
    425c:	f022                	sd	s0,32(sp)
    425e:	ec26                	sd	s1,24(sp)
    4260:	e84a                	sd	s2,16(sp)
    4262:	e44e                	sd	s3,8(sp)
    4264:	e052                	sd	s4,0(sp)
    4266:	1800                	addi	s0,sp,48
    4268:	89aa                	mv	s3,a0
  int master_pid = getpid();
    426a:	00001097          	auipc	ra,0x1
    426e:	476080e7          	jalr	1142(ra) # 56e0 <getpid>
    4272:	8a2a                	mv	s4,a0
    4274:	0c800913          	li	s2,200
    int pid = fork();
    4278:	00001097          	auipc	ra,0x1
    427c:	3e0080e7          	jalr	992(ra) # 5658 <fork>
    4280:	84aa                	mv	s1,a0
    if(pid < 0){
    4282:	02054263          	bltz	a0,42a6 <reparent+0x4e>
    if(pid){
    4286:	cd21                	beqz	a0,42de <reparent+0x86>
      if(wait(0) != pid){
    4288:	4501                	li	a0,0
    428a:	00001097          	auipc	ra,0x1
    428e:	3de080e7          	jalr	990(ra) # 5668 <wait>
    4292:	02951863          	bne	a0,s1,42c2 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    4296:	397d                	addiw	s2,s2,-1
    4298:	fe0910e3          	bnez	s2,4278 <reparent+0x20>
  exit(0);
    429c:	4501                	li	a0,0
    429e:	00001097          	auipc	ra,0x1
    42a2:	3c2080e7          	jalr	962(ra) # 5660 <exit>
      printf("%s: fork failed\n", s);
    42a6:	85ce                	mv	a1,s3
    42a8:	00002517          	auipc	a0,0x2
    42ac:	53850513          	addi	a0,a0,1336 # 67e0 <malloc+0xd48>
    42b0:	00001097          	auipc	ra,0x1
    42b4:	728080e7          	jalr	1832(ra) # 59d8 <printf>
      exit(1);
    42b8:	4505                	li	a0,1
    42ba:	00001097          	auipc	ra,0x1
    42be:	3a6080e7          	jalr	934(ra) # 5660 <exit>
        printf("%s: wait wrong pid\n", s);
    42c2:	85ce                	mv	a1,s3
    42c4:	00002517          	auipc	a0,0x2
    42c8:	6a450513          	addi	a0,a0,1700 # 6968 <malloc+0xed0>
    42cc:	00001097          	auipc	ra,0x1
    42d0:	70c080e7          	jalr	1804(ra) # 59d8 <printf>
        exit(1);
    42d4:	4505                	li	a0,1
    42d6:	00001097          	auipc	ra,0x1
    42da:	38a080e7          	jalr	906(ra) # 5660 <exit>
      int pid2 = fork();
    42de:	00001097          	auipc	ra,0x1
    42e2:	37a080e7          	jalr	890(ra) # 5658 <fork>
      if(pid2 < 0){
    42e6:	00054763          	bltz	a0,42f4 <reparent+0x9c>
      exit(0);
    42ea:	4501                	li	a0,0
    42ec:	00001097          	auipc	ra,0x1
    42f0:	374080e7          	jalr	884(ra) # 5660 <exit>
        kill(master_pid);
    42f4:	8552                	mv	a0,s4
    42f6:	00001097          	auipc	ra,0x1
    42fa:	39a080e7          	jalr	922(ra) # 5690 <kill>
        exit(1);
    42fe:	4505                	li	a0,1
    4300:	00001097          	auipc	ra,0x1
    4304:	360080e7          	jalr	864(ra) # 5660 <exit>

0000000000004308 <mem>:
{
    4308:	7139                	addi	sp,sp,-64
    430a:	fc06                	sd	ra,56(sp)
    430c:	f822                	sd	s0,48(sp)
    430e:	f426                	sd	s1,40(sp)
    4310:	f04a                	sd	s2,32(sp)
    4312:	ec4e                	sd	s3,24(sp)
    4314:	0080                	addi	s0,sp,64
    4316:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    4318:	00001097          	auipc	ra,0x1
    431c:	340080e7          	jalr	832(ra) # 5658 <fork>
    m1 = 0;
    4320:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    4322:	6909                	lui	s2,0x2
    4324:	71190913          	addi	s2,s2,1809 # 2711 <sbrkbasic+0x12f>
  if((pid = fork()) == 0){
    4328:	e135                	bnez	a0,438c <mem+0x84>
    while((m2 = malloc(10001)) != 0){
    432a:	854a                	mv	a0,s2
    432c:	00001097          	auipc	ra,0x1
    4330:	76c080e7          	jalr	1900(ra) # 5a98 <malloc>
    4334:	c501                	beqz	a0,433c <mem+0x34>
      *(char**)m2 = m1;
    4336:	e104                	sd	s1,0(a0)
      m1 = m2;
    4338:	84aa                	mv	s1,a0
    433a:	bfc5                	j	432a <mem+0x22>
    while(m1){
    433c:	c899                	beqz	s1,4352 <mem+0x4a>
      m2 = *(char**)m1;
    433e:	0004b903          	ld	s2,0(s1)
      free(m1);
    4342:	8526                	mv	a0,s1
    4344:	00001097          	auipc	ra,0x1
    4348:	6ca080e7          	jalr	1738(ra) # 5a0e <free>
      m1 = m2;
    434c:	84ca                	mv	s1,s2
    while(m1){
    434e:	fe0918e3          	bnez	s2,433e <mem+0x36>
    m1 = malloc(1024*20);
    4352:	6515                	lui	a0,0x5
    4354:	00001097          	auipc	ra,0x1
    4358:	744080e7          	jalr	1860(ra) # 5a98 <malloc>
    if(m1 == 0){
    435c:	c911                	beqz	a0,4370 <mem+0x68>
    free(m1);
    435e:	00001097          	auipc	ra,0x1
    4362:	6b0080e7          	jalr	1712(ra) # 5a0e <free>
    exit(0);
    4366:	4501                	li	a0,0
    4368:	00001097          	auipc	ra,0x1
    436c:	2f8080e7          	jalr	760(ra) # 5660 <exit>
      printf("couldn't allocate mem?!!\n", s);
    4370:	85ce                	mv	a1,s3
    4372:	00003517          	auipc	a0,0x3
    4376:	78650513          	addi	a0,a0,1926 # 7af8 <malloc+0x2060>
    437a:	00001097          	auipc	ra,0x1
    437e:	65e080e7          	jalr	1630(ra) # 59d8 <printf>
      exit(1);
    4382:	4505                	li	a0,1
    4384:	00001097          	auipc	ra,0x1
    4388:	2dc080e7          	jalr	732(ra) # 5660 <exit>
    wait(&xstatus);
    438c:	fcc40513          	addi	a0,s0,-52
    4390:	00001097          	auipc	ra,0x1
    4394:	2d8080e7          	jalr	728(ra) # 5668 <wait>
    if(xstatus == -1){
    4398:	fcc42503          	lw	a0,-52(s0)
    439c:	57fd                	li	a5,-1
    439e:	00f50663          	beq	a0,a5,43aa <mem+0xa2>
    exit(xstatus);
    43a2:	00001097          	auipc	ra,0x1
    43a6:	2be080e7          	jalr	702(ra) # 5660 <exit>
      exit(0);
    43aa:	4501                	li	a0,0
    43ac:	00001097          	auipc	ra,0x1
    43b0:	2b4080e7          	jalr	692(ra) # 5660 <exit>

00000000000043b4 <sharedfd>:
{
    43b4:	7159                	addi	sp,sp,-112
    43b6:	f486                	sd	ra,104(sp)
    43b8:	f0a2                	sd	s0,96(sp)
    43ba:	eca6                	sd	s1,88(sp)
    43bc:	e8ca                	sd	s2,80(sp)
    43be:	e4ce                	sd	s3,72(sp)
    43c0:	e0d2                	sd	s4,64(sp)
    43c2:	fc56                	sd	s5,56(sp)
    43c4:	f85a                	sd	s6,48(sp)
    43c6:	f45e                	sd	s7,40(sp)
    43c8:	1880                	addi	s0,sp,112
    43ca:	89aa                	mv	s3,a0
  unlink("sharedfd");
    43cc:	00003517          	auipc	a0,0x3
    43d0:	74c50513          	addi	a0,a0,1868 # 7b18 <malloc+0x2080>
    43d4:	00001097          	auipc	ra,0x1
    43d8:	2dc080e7          	jalr	732(ra) # 56b0 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    43dc:	20200593          	li	a1,514
    43e0:	00003517          	auipc	a0,0x3
    43e4:	73850513          	addi	a0,a0,1848 # 7b18 <malloc+0x2080>
    43e8:	00001097          	auipc	ra,0x1
    43ec:	2b8080e7          	jalr	696(ra) # 56a0 <open>
  if(fd < 0){
    43f0:	04054a63          	bltz	a0,4444 <sharedfd+0x90>
    43f4:	892a                	mv	s2,a0
  pid = fork();
    43f6:	00001097          	auipc	ra,0x1
    43fa:	262080e7          	jalr	610(ra) # 5658 <fork>
    43fe:	8a2a                	mv	s4,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    4400:	06300593          	li	a1,99
    4404:	c119                	beqz	a0,440a <sharedfd+0x56>
    4406:	07000593          	li	a1,112
    440a:	4629                	li	a2,10
    440c:	fa040513          	addi	a0,s0,-96
    4410:	00001097          	auipc	ra,0x1
    4414:	03a080e7          	jalr	58(ra) # 544a <memset>
    4418:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    441c:	4629                	li	a2,10
    441e:	fa040593          	addi	a1,s0,-96
    4422:	854a                	mv	a0,s2
    4424:	00001097          	auipc	ra,0x1
    4428:	25c080e7          	jalr	604(ra) # 5680 <write>
    442c:	47a9                	li	a5,10
    442e:	02f51963          	bne	a0,a5,4460 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    4432:	34fd                	addiw	s1,s1,-1
    4434:	f4e5                	bnez	s1,441c <sharedfd+0x68>
  if(pid == 0) {
    4436:	040a1363          	bnez	s4,447c <sharedfd+0xc8>
    exit(0);
    443a:	4501                	li	a0,0
    443c:	00001097          	auipc	ra,0x1
    4440:	224080e7          	jalr	548(ra) # 5660 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    4444:	85ce                	mv	a1,s3
    4446:	00003517          	auipc	a0,0x3
    444a:	6e250513          	addi	a0,a0,1762 # 7b28 <malloc+0x2090>
    444e:	00001097          	auipc	ra,0x1
    4452:	58a080e7          	jalr	1418(ra) # 59d8 <printf>
    exit(1);
    4456:	4505                	li	a0,1
    4458:	00001097          	auipc	ra,0x1
    445c:	208080e7          	jalr	520(ra) # 5660 <exit>
      printf("%s: write sharedfd failed\n", s);
    4460:	85ce                	mv	a1,s3
    4462:	00003517          	auipc	a0,0x3
    4466:	6ee50513          	addi	a0,a0,1774 # 7b50 <malloc+0x20b8>
    446a:	00001097          	auipc	ra,0x1
    446e:	56e080e7          	jalr	1390(ra) # 59d8 <printf>
      exit(1);
    4472:	4505                	li	a0,1
    4474:	00001097          	auipc	ra,0x1
    4478:	1ec080e7          	jalr	492(ra) # 5660 <exit>
    wait(&xstatus);
    447c:	f9c40513          	addi	a0,s0,-100
    4480:	00001097          	auipc	ra,0x1
    4484:	1e8080e7          	jalr	488(ra) # 5668 <wait>
    if(xstatus != 0)
    4488:	f9c42a03          	lw	s4,-100(s0)
    448c:	000a0763          	beqz	s4,449a <sharedfd+0xe6>
      exit(xstatus);
    4490:	8552                	mv	a0,s4
    4492:	00001097          	auipc	ra,0x1
    4496:	1ce080e7          	jalr	462(ra) # 5660 <exit>
  close(fd);
    449a:	854a                	mv	a0,s2
    449c:	00001097          	auipc	ra,0x1
    44a0:	1ec080e7          	jalr	492(ra) # 5688 <close>
  fd = open("sharedfd", 0);
    44a4:	4581                	li	a1,0
    44a6:	00003517          	auipc	a0,0x3
    44aa:	67250513          	addi	a0,a0,1650 # 7b18 <malloc+0x2080>
    44ae:	00001097          	auipc	ra,0x1
    44b2:	1f2080e7          	jalr	498(ra) # 56a0 <open>
    44b6:	8baa                	mv	s7,a0
  nc = np = 0;
    44b8:	8ad2                	mv	s5,s4
  if(fd < 0){
    44ba:	02054563          	bltz	a0,44e4 <sharedfd+0x130>
    44be:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    44c2:	06300493          	li	s1,99
      if(buf[i] == 'p')
    44c6:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    44ca:	4629                	li	a2,10
    44cc:	fa040593          	addi	a1,s0,-96
    44d0:	855e                	mv	a0,s7
    44d2:	00001097          	auipc	ra,0x1
    44d6:	1a6080e7          	jalr	422(ra) # 5678 <read>
    44da:	02a05f63          	blez	a0,4518 <sharedfd+0x164>
    44de:	fa040793          	addi	a5,s0,-96
    44e2:	a01d                	j	4508 <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    44e4:	85ce                	mv	a1,s3
    44e6:	00003517          	auipc	a0,0x3
    44ea:	68a50513          	addi	a0,a0,1674 # 7b70 <malloc+0x20d8>
    44ee:	00001097          	auipc	ra,0x1
    44f2:	4ea080e7          	jalr	1258(ra) # 59d8 <printf>
    exit(1);
    44f6:	4505                	li	a0,1
    44f8:	00001097          	auipc	ra,0x1
    44fc:	168080e7          	jalr	360(ra) # 5660 <exit>
        nc++;
    4500:	2a05                	addiw	s4,s4,1
    for(i = 0; i < sizeof(buf); i++){
    4502:	0785                	addi	a5,a5,1
    4504:	fd2783e3          	beq	a5,s2,44ca <sharedfd+0x116>
      if(buf[i] == 'c')
    4508:	0007c703          	lbu	a4,0(a5) # 3e800000 <_end+0x3e7f1500>
    450c:	fe970ae3          	beq	a4,s1,4500 <sharedfd+0x14c>
      if(buf[i] == 'p')
    4510:	ff6719e3          	bne	a4,s6,4502 <sharedfd+0x14e>
        np++;
    4514:	2a85                	addiw	s5,s5,1
    4516:	b7f5                	j	4502 <sharedfd+0x14e>
  close(fd);
    4518:	855e                	mv	a0,s7
    451a:	00001097          	auipc	ra,0x1
    451e:	16e080e7          	jalr	366(ra) # 5688 <close>
  unlink("sharedfd");
    4522:	00003517          	auipc	a0,0x3
    4526:	5f650513          	addi	a0,a0,1526 # 7b18 <malloc+0x2080>
    452a:	00001097          	auipc	ra,0x1
    452e:	186080e7          	jalr	390(ra) # 56b0 <unlink>
  if(nc == N*SZ && np == N*SZ){
    4532:	6789                	lui	a5,0x2
    4534:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x12e>
    4538:	00fa1763          	bne	s4,a5,4546 <sharedfd+0x192>
    453c:	6789                	lui	a5,0x2
    453e:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x12e>
    4542:	02fa8063          	beq	s5,a5,4562 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    4546:	85ce                	mv	a1,s3
    4548:	00003517          	auipc	a0,0x3
    454c:	65050513          	addi	a0,a0,1616 # 7b98 <malloc+0x2100>
    4550:	00001097          	auipc	ra,0x1
    4554:	488080e7          	jalr	1160(ra) # 59d8 <printf>
    exit(1);
    4558:	4505                	li	a0,1
    455a:	00001097          	auipc	ra,0x1
    455e:	106080e7          	jalr	262(ra) # 5660 <exit>
    exit(0);
    4562:	4501                	li	a0,0
    4564:	00001097          	auipc	ra,0x1
    4568:	0fc080e7          	jalr	252(ra) # 5660 <exit>

000000000000456c <fourfiles>:
{
    456c:	7135                	addi	sp,sp,-160
    456e:	ed06                	sd	ra,152(sp)
    4570:	e922                	sd	s0,144(sp)
    4572:	e526                	sd	s1,136(sp)
    4574:	e14a                	sd	s2,128(sp)
    4576:	fcce                	sd	s3,120(sp)
    4578:	f8d2                	sd	s4,112(sp)
    457a:	f4d6                	sd	s5,104(sp)
    457c:	f0da                	sd	s6,96(sp)
    457e:	ecde                	sd	s7,88(sp)
    4580:	e8e2                	sd	s8,80(sp)
    4582:	e4e6                	sd	s9,72(sp)
    4584:	e0ea                	sd	s10,64(sp)
    4586:	fc6e                	sd	s11,56(sp)
    4588:	1100                	addi	s0,sp,160
    458a:	8d2a                	mv	s10,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    458c:	00003797          	auipc	a5,0x3
    4590:	62478793          	addi	a5,a5,1572 # 7bb0 <malloc+0x2118>
    4594:	f6f43823          	sd	a5,-144(s0)
    4598:	00003797          	auipc	a5,0x3
    459c:	62078793          	addi	a5,a5,1568 # 7bb8 <malloc+0x2120>
    45a0:	f6f43c23          	sd	a5,-136(s0)
    45a4:	00003797          	auipc	a5,0x3
    45a8:	61c78793          	addi	a5,a5,1564 # 7bc0 <malloc+0x2128>
    45ac:	f8f43023          	sd	a5,-128(s0)
    45b0:	00003797          	auipc	a5,0x3
    45b4:	61878793          	addi	a5,a5,1560 # 7bc8 <malloc+0x2130>
    45b8:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    45bc:	f7040b13          	addi	s6,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    45c0:	895a                	mv	s2,s6
  for(pi = 0; pi < NCHILD; pi++){
    45c2:	4481                	li	s1,0
    45c4:	4a11                	li	s4,4
    fname = names[pi];
    45c6:	00093983          	ld	s3,0(s2)
    unlink(fname);
    45ca:	854e                	mv	a0,s3
    45cc:	00001097          	auipc	ra,0x1
    45d0:	0e4080e7          	jalr	228(ra) # 56b0 <unlink>
    pid = fork();
    45d4:	00001097          	auipc	ra,0x1
    45d8:	084080e7          	jalr	132(ra) # 5658 <fork>
    if(pid < 0){
    45dc:	04054063          	bltz	a0,461c <fourfiles+0xb0>
    if(pid == 0){
    45e0:	cd21                	beqz	a0,4638 <fourfiles+0xcc>
  for(pi = 0; pi < NCHILD; pi++){
    45e2:	2485                	addiw	s1,s1,1
    45e4:	0921                	addi	s2,s2,8
    45e6:	ff4490e3          	bne	s1,s4,45c6 <fourfiles+0x5a>
    45ea:	4491                	li	s1,4
    wait(&xstatus);
    45ec:	f6c40513          	addi	a0,s0,-148
    45f0:	00001097          	auipc	ra,0x1
    45f4:	078080e7          	jalr	120(ra) # 5668 <wait>
    if(xstatus != 0)
    45f8:	f6c42503          	lw	a0,-148(s0)
    45fc:	e961                	bnez	a0,46cc <fourfiles+0x160>
  for(pi = 0; pi < NCHILD; pi++){
    45fe:	34fd                	addiw	s1,s1,-1
    4600:	f4f5                	bnez	s1,45ec <fourfiles+0x80>
    4602:	03000a93          	li	s5,48
    total = 0;
    4606:	8daa                	mv	s11,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4608:	00007997          	auipc	s3,0x7
    460c:	4e898993          	addi	s3,s3,1256 # baf0 <buf>
    if(total != N*SZ){
    4610:	6c05                	lui	s8,0x1
    4612:	770c0c13          	addi	s8,s8,1904 # 1770 <pipe1+0x1e>
  for(i = 0; i < NCHILD; i++){
    4616:	03400c93          	li	s9,52
    461a:	aa15                	j	474e <fourfiles+0x1e2>
      printf("fork failed\n", s);
    461c:	85ea                	mv	a1,s10
    461e:	00002517          	auipc	a0,0x2
    4622:	5ca50513          	addi	a0,a0,1482 # 6be8 <malloc+0x1150>
    4626:	00001097          	auipc	ra,0x1
    462a:	3b2080e7          	jalr	946(ra) # 59d8 <printf>
      exit(1);
    462e:	4505                	li	a0,1
    4630:	00001097          	auipc	ra,0x1
    4634:	030080e7          	jalr	48(ra) # 5660 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4638:	20200593          	li	a1,514
    463c:	854e                	mv	a0,s3
    463e:	00001097          	auipc	ra,0x1
    4642:	062080e7          	jalr	98(ra) # 56a0 <open>
    4646:	892a                	mv	s2,a0
      if(fd < 0){
    4648:	04054663          	bltz	a0,4694 <fourfiles+0x128>
      memset(buf, '0'+pi, SZ);
    464c:	1f400613          	li	a2,500
    4650:	0304859b          	addiw	a1,s1,48
    4654:	00007517          	auipc	a0,0x7
    4658:	49c50513          	addi	a0,a0,1180 # baf0 <buf>
    465c:	00001097          	auipc	ra,0x1
    4660:	dee080e7          	jalr	-530(ra) # 544a <memset>
    4664:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4666:	00007997          	auipc	s3,0x7
    466a:	48a98993          	addi	s3,s3,1162 # baf0 <buf>
    466e:	1f400613          	li	a2,500
    4672:	85ce                	mv	a1,s3
    4674:	854a                	mv	a0,s2
    4676:	00001097          	auipc	ra,0x1
    467a:	00a080e7          	jalr	10(ra) # 5680 <write>
    467e:	1f400793          	li	a5,500
    4682:	02f51763          	bne	a0,a5,46b0 <fourfiles+0x144>
      for(i = 0; i < N; i++){
    4686:	34fd                	addiw	s1,s1,-1
    4688:	f0fd                	bnez	s1,466e <fourfiles+0x102>
      exit(0);
    468a:	4501                	li	a0,0
    468c:	00001097          	auipc	ra,0x1
    4690:	fd4080e7          	jalr	-44(ra) # 5660 <exit>
        printf("create failed\n", s);
    4694:	85ea                	mv	a1,s10
    4696:	00003517          	auipc	a0,0x3
    469a:	53a50513          	addi	a0,a0,1338 # 7bd0 <malloc+0x2138>
    469e:	00001097          	auipc	ra,0x1
    46a2:	33a080e7          	jalr	826(ra) # 59d8 <printf>
        exit(1);
    46a6:	4505                	li	a0,1
    46a8:	00001097          	auipc	ra,0x1
    46ac:	fb8080e7          	jalr	-72(ra) # 5660 <exit>
          printf("write failed %d\n", n);
    46b0:	85aa                	mv	a1,a0
    46b2:	00003517          	auipc	a0,0x3
    46b6:	52e50513          	addi	a0,a0,1326 # 7be0 <malloc+0x2148>
    46ba:	00001097          	auipc	ra,0x1
    46be:	31e080e7          	jalr	798(ra) # 59d8 <printf>
          exit(1);
    46c2:	4505                	li	a0,1
    46c4:	00001097          	auipc	ra,0x1
    46c8:	f9c080e7          	jalr	-100(ra) # 5660 <exit>
      exit(xstatus);
    46cc:	00001097          	auipc	ra,0x1
    46d0:	f94080e7          	jalr	-108(ra) # 5660 <exit>
      total += n;
    46d4:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    46d8:	660d                	lui	a2,0x3
    46da:	85ce                	mv	a1,s3
    46dc:	8552                	mv	a0,s4
    46de:	00001097          	auipc	ra,0x1
    46e2:	f9a080e7          	jalr	-102(ra) # 5678 <read>
    46e6:	04a05463          	blez	a0,472e <fourfiles+0x1c2>
        if(buf[j] != '0'+i){
    46ea:	0009c783          	lbu	a5,0(s3)
    46ee:	02979263          	bne	a5,s1,4712 <fourfiles+0x1a6>
    46f2:	00007797          	auipc	a5,0x7
    46f6:	3ff78793          	addi	a5,a5,1023 # baf1 <buf+0x1>
    46fa:	fff5069b          	addiw	a3,a0,-1
    46fe:	1682                	slli	a3,a3,0x20
    4700:	9281                	srli	a3,a3,0x20
    4702:	96be                	add	a3,a3,a5
      for(j = 0; j < n; j++){
    4704:	fcd788e3          	beq	a5,a3,46d4 <fourfiles+0x168>
        if(buf[j] != '0'+i){
    4708:	0007c703          	lbu	a4,0(a5)
    470c:	0785                	addi	a5,a5,1
    470e:	fe970be3          	beq	a4,s1,4704 <fourfiles+0x198>
          printf("wrong char\n", s);
    4712:	85ea                	mv	a1,s10
    4714:	00003517          	auipc	a0,0x3
    4718:	4e450513          	addi	a0,a0,1252 # 7bf8 <malloc+0x2160>
    471c:	00001097          	auipc	ra,0x1
    4720:	2bc080e7          	jalr	700(ra) # 59d8 <printf>
          exit(1);
    4724:	4505                	li	a0,1
    4726:	00001097          	auipc	ra,0x1
    472a:	f3a080e7          	jalr	-198(ra) # 5660 <exit>
    close(fd);
    472e:	8552                	mv	a0,s4
    4730:	00001097          	auipc	ra,0x1
    4734:	f58080e7          	jalr	-168(ra) # 5688 <close>
    if(total != N*SZ){
    4738:	03891863          	bne	s2,s8,4768 <fourfiles+0x1fc>
    unlink(fname);
    473c:	855e                	mv	a0,s7
    473e:	00001097          	auipc	ra,0x1
    4742:	f72080e7          	jalr	-142(ra) # 56b0 <unlink>
  for(i = 0; i < NCHILD; i++){
    4746:	0b21                	addi	s6,s6,8
    4748:	2a85                	addiw	s5,s5,1
    474a:	039a8d63          	beq	s5,s9,4784 <fourfiles+0x218>
    fname = names[i];
    474e:	000b3b83          	ld	s7,0(s6) # 3000 <dirtest+0x54>
    fd = open(fname, 0);
    4752:	4581                	li	a1,0
    4754:	855e                	mv	a0,s7
    4756:	00001097          	auipc	ra,0x1
    475a:	f4a080e7          	jalr	-182(ra) # 56a0 <open>
    475e:	8a2a                	mv	s4,a0
    total = 0;
    4760:	896e                	mv	s2,s11
    4762:	000a849b          	sext.w	s1,s5
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4766:	bf8d                	j	46d8 <fourfiles+0x16c>
      printf("wrong length %d\n", total);
    4768:	85ca                	mv	a1,s2
    476a:	00003517          	auipc	a0,0x3
    476e:	49e50513          	addi	a0,a0,1182 # 7c08 <malloc+0x2170>
    4772:	00001097          	auipc	ra,0x1
    4776:	266080e7          	jalr	614(ra) # 59d8 <printf>
      exit(1);
    477a:	4505                	li	a0,1
    477c:	00001097          	auipc	ra,0x1
    4780:	ee4080e7          	jalr	-284(ra) # 5660 <exit>
}
    4784:	60ea                	ld	ra,152(sp)
    4786:	644a                	ld	s0,144(sp)
    4788:	64aa                	ld	s1,136(sp)
    478a:	690a                	ld	s2,128(sp)
    478c:	79e6                	ld	s3,120(sp)
    478e:	7a46                	ld	s4,112(sp)
    4790:	7aa6                	ld	s5,104(sp)
    4792:	7b06                	ld	s6,96(sp)
    4794:	6be6                	ld	s7,88(sp)
    4796:	6c46                	ld	s8,80(sp)
    4798:	6ca6                	ld	s9,72(sp)
    479a:	6d06                	ld	s10,64(sp)
    479c:	7de2                	ld	s11,56(sp)
    479e:	610d                	addi	sp,sp,160
    47a0:	8082                	ret

00000000000047a2 <concreate>:
{
    47a2:	7135                	addi	sp,sp,-160
    47a4:	ed06                	sd	ra,152(sp)
    47a6:	e922                	sd	s0,144(sp)
    47a8:	e526                	sd	s1,136(sp)
    47aa:	e14a                	sd	s2,128(sp)
    47ac:	fcce                	sd	s3,120(sp)
    47ae:	f8d2                	sd	s4,112(sp)
    47b0:	f4d6                	sd	s5,104(sp)
    47b2:	f0da                	sd	s6,96(sp)
    47b4:	ecde                	sd	s7,88(sp)
    47b6:	1100                	addi	s0,sp,160
    47b8:	89aa                	mv	s3,a0
  file[0] = 'C';
    47ba:	04300793          	li	a5,67
    47be:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    47c2:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    47c6:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    47c8:	4b0d                	li	s6,3
    47ca:	4a85                	li	s5,1
      link("C0", file);
    47cc:	00003b97          	auipc	s7,0x3
    47d0:	454b8b93          	addi	s7,s7,1108 # 7c20 <malloc+0x2188>
  for(i = 0; i < N; i++){
    47d4:	02800a13          	li	s4,40
    47d8:	acc1                	j	4aa8 <concreate+0x306>
      link("C0", file);
    47da:	fa840593          	addi	a1,s0,-88
    47de:	855e                	mv	a0,s7
    47e0:	00001097          	auipc	ra,0x1
    47e4:	ee0080e7          	jalr	-288(ra) # 56c0 <link>
    if(pid == 0) {
    47e8:	a45d                	j	4a8e <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    47ea:	4795                	li	a5,5
    47ec:	02f9693b          	remw	s2,s2,a5
    47f0:	4785                	li	a5,1
    47f2:	02f90b63          	beq	s2,a5,4828 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    47f6:	20200593          	li	a1,514
    47fa:	fa840513          	addi	a0,s0,-88
    47fe:	00001097          	auipc	ra,0x1
    4802:	ea2080e7          	jalr	-350(ra) # 56a0 <open>
      if(fd < 0){
    4806:	26055b63          	bgez	a0,4a7c <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    480a:	fa840593          	addi	a1,s0,-88
    480e:	00003517          	auipc	a0,0x3
    4812:	41a50513          	addi	a0,a0,1050 # 7c28 <malloc+0x2190>
    4816:	00001097          	auipc	ra,0x1
    481a:	1c2080e7          	jalr	450(ra) # 59d8 <printf>
        exit(1);
    481e:	4505                	li	a0,1
    4820:	00001097          	auipc	ra,0x1
    4824:	e40080e7          	jalr	-448(ra) # 5660 <exit>
      link("C0", file);
    4828:	fa840593          	addi	a1,s0,-88
    482c:	00003517          	auipc	a0,0x3
    4830:	3f450513          	addi	a0,a0,1012 # 7c20 <malloc+0x2188>
    4834:	00001097          	auipc	ra,0x1
    4838:	e8c080e7          	jalr	-372(ra) # 56c0 <link>
      exit(0);
    483c:	4501                	li	a0,0
    483e:	00001097          	auipc	ra,0x1
    4842:	e22080e7          	jalr	-478(ra) # 5660 <exit>
        exit(1);
    4846:	4505                	li	a0,1
    4848:	00001097          	auipc	ra,0x1
    484c:	e18080e7          	jalr	-488(ra) # 5660 <exit>
  memset(fa, 0, sizeof(fa));
    4850:	02800613          	li	a2,40
    4854:	4581                	li	a1,0
    4856:	f8040513          	addi	a0,s0,-128
    485a:	00001097          	auipc	ra,0x1
    485e:	bf0080e7          	jalr	-1040(ra) # 544a <memset>
  fd = open(".", 0);
    4862:	4581                	li	a1,0
    4864:	00002517          	auipc	a0,0x2
    4868:	ddc50513          	addi	a0,a0,-548 # 6640 <malloc+0xba8>
    486c:	00001097          	auipc	ra,0x1
    4870:	e34080e7          	jalr	-460(ra) # 56a0 <open>
    4874:	892a                	mv	s2,a0
  n = 0;
    4876:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4878:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    487c:	02700b13          	li	s6,39
      fa[i] = 1;
    4880:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    4882:	4641                	li	a2,16
    4884:	f7040593          	addi	a1,s0,-144
    4888:	854a                	mv	a0,s2
    488a:	00001097          	auipc	ra,0x1
    488e:	dee080e7          	jalr	-530(ra) # 5678 <read>
    4892:	08a05163          	blez	a0,4914 <concreate+0x172>
    if(de.inum == 0)
    4896:	f7045783          	lhu	a5,-144(s0)
    489a:	d7e5                	beqz	a5,4882 <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    489c:	f7244783          	lbu	a5,-142(s0)
    48a0:	ff4791e3          	bne	a5,s4,4882 <concreate+0xe0>
    48a4:	f7444783          	lbu	a5,-140(s0)
    48a8:	ffe9                	bnez	a5,4882 <concreate+0xe0>
      i = de.name[1] - '0';
    48aa:	f7344783          	lbu	a5,-141(s0)
    48ae:	fd07879b          	addiw	a5,a5,-48
    48b2:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    48b6:	00eb6f63          	bltu	s6,a4,48d4 <concreate+0x132>
      if(fa[i]){
    48ba:	fb040793          	addi	a5,s0,-80
    48be:	97ba                	add	a5,a5,a4
    48c0:	fd07c783          	lbu	a5,-48(a5)
    48c4:	eb85                	bnez	a5,48f4 <concreate+0x152>
      fa[i] = 1;
    48c6:	fb040793          	addi	a5,s0,-80
    48ca:	973e                	add	a4,a4,a5
    48cc:	fd770823          	sb	s7,-48(a4)
      n++;
    48d0:	2a85                	addiw	s5,s5,1
    48d2:	bf45                	j	4882 <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    48d4:	f7240613          	addi	a2,s0,-142
    48d8:	85ce                	mv	a1,s3
    48da:	00003517          	auipc	a0,0x3
    48de:	36e50513          	addi	a0,a0,878 # 7c48 <malloc+0x21b0>
    48e2:	00001097          	auipc	ra,0x1
    48e6:	0f6080e7          	jalr	246(ra) # 59d8 <printf>
        exit(1);
    48ea:	4505                	li	a0,1
    48ec:	00001097          	auipc	ra,0x1
    48f0:	d74080e7          	jalr	-652(ra) # 5660 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    48f4:	f7240613          	addi	a2,s0,-142
    48f8:	85ce                	mv	a1,s3
    48fa:	00003517          	auipc	a0,0x3
    48fe:	36e50513          	addi	a0,a0,878 # 7c68 <malloc+0x21d0>
    4902:	00001097          	auipc	ra,0x1
    4906:	0d6080e7          	jalr	214(ra) # 59d8 <printf>
        exit(1);
    490a:	4505                	li	a0,1
    490c:	00001097          	auipc	ra,0x1
    4910:	d54080e7          	jalr	-684(ra) # 5660 <exit>
  close(fd);
    4914:	854a                	mv	a0,s2
    4916:	00001097          	auipc	ra,0x1
    491a:	d72080e7          	jalr	-654(ra) # 5688 <close>
  if(n != N){
    491e:	02800793          	li	a5,40
    4922:	00fa9763          	bne	s5,a5,4930 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    4926:	4a8d                	li	s5,3
    4928:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    492a:	02800a13          	li	s4,40
    492e:	a8c9                	j	4a00 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    4930:	85ce                	mv	a1,s3
    4932:	00003517          	auipc	a0,0x3
    4936:	35e50513          	addi	a0,a0,862 # 7c90 <malloc+0x21f8>
    493a:	00001097          	auipc	ra,0x1
    493e:	09e080e7          	jalr	158(ra) # 59d8 <printf>
    exit(1);
    4942:	4505                	li	a0,1
    4944:	00001097          	auipc	ra,0x1
    4948:	d1c080e7          	jalr	-740(ra) # 5660 <exit>
      printf("%s: fork failed\n", s);
    494c:	85ce                	mv	a1,s3
    494e:	00002517          	auipc	a0,0x2
    4952:	e9250513          	addi	a0,a0,-366 # 67e0 <malloc+0xd48>
    4956:	00001097          	auipc	ra,0x1
    495a:	082080e7          	jalr	130(ra) # 59d8 <printf>
      exit(1);
    495e:	4505                	li	a0,1
    4960:	00001097          	auipc	ra,0x1
    4964:	d00080e7          	jalr	-768(ra) # 5660 <exit>
      close(open(file, 0));
    4968:	4581                	li	a1,0
    496a:	fa840513          	addi	a0,s0,-88
    496e:	00001097          	auipc	ra,0x1
    4972:	d32080e7          	jalr	-718(ra) # 56a0 <open>
    4976:	00001097          	auipc	ra,0x1
    497a:	d12080e7          	jalr	-750(ra) # 5688 <close>
      close(open(file, 0));
    497e:	4581                	li	a1,0
    4980:	fa840513          	addi	a0,s0,-88
    4984:	00001097          	auipc	ra,0x1
    4988:	d1c080e7          	jalr	-740(ra) # 56a0 <open>
    498c:	00001097          	auipc	ra,0x1
    4990:	cfc080e7          	jalr	-772(ra) # 5688 <close>
      close(open(file, 0));
    4994:	4581                	li	a1,0
    4996:	fa840513          	addi	a0,s0,-88
    499a:	00001097          	auipc	ra,0x1
    499e:	d06080e7          	jalr	-762(ra) # 56a0 <open>
    49a2:	00001097          	auipc	ra,0x1
    49a6:	ce6080e7          	jalr	-794(ra) # 5688 <close>
      close(open(file, 0));
    49aa:	4581                	li	a1,0
    49ac:	fa840513          	addi	a0,s0,-88
    49b0:	00001097          	auipc	ra,0x1
    49b4:	cf0080e7          	jalr	-784(ra) # 56a0 <open>
    49b8:	00001097          	auipc	ra,0x1
    49bc:	cd0080e7          	jalr	-816(ra) # 5688 <close>
      close(open(file, 0));
    49c0:	4581                	li	a1,0
    49c2:	fa840513          	addi	a0,s0,-88
    49c6:	00001097          	auipc	ra,0x1
    49ca:	cda080e7          	jalr	-806(ra) # 56a0 <open>
    49ce:	00001097          	auipc	ra,0x1
    49d2:	cba080e7          	jalr	-838(ra) # 5688 <close>
      close(open(file, 0));
    49d6:	4581                	li	a1,0
    49d8:	fa840513          	addi	a0,s0,-88
    49dc:	00001097          	auipc	ra,0x1
    49e0:	cc4080e7          	jalr	-828(ra) # 56a0 <open>
    49e4:	00001097          	auipc	ra,0x1
    49e8:	ca4080e7          	jalr	-860(ra) # 5688 <close>
    if(pid == 0)
    49ec:	08090363          	beqz	s2,4a72 <concreate+0x2d0>
      wait(0);
    49f0:	4501                	li	a0,0
    49f2:	00001097          	auipc	ra,0x1
    49f6:	c76080e7          	jalr	-906(ra) # 5668 <wait>
  for(i = 0; i < N; i++){
    49fa:	2485                	addiw	s1,s1,1
    49fc:	0f448563          	beq	s1,s4,4ae6 <concreate+0x344>
    file[1] = '0' + i;
    4a00:	0304879b          	addiw	a5,s1,48
    4a04:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    4a08:	00001097          	auipc	ra,0x1
    4a0c:	c50080e7          	jalr	-944(ra) # 5658 <fork>
    4a10:	892a                	mv	s2,a0
    if(pid < 0){
    4a12:	f2054de3          	bltz	a0,494c <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    4a16:	0354e73b          	remw	a4,s1,s5
    4a1a:	00a767b3          	or	a5,a4,a0
    4a1e:	2781                	sext.w	a5,a5
    4a20:	d7a1                	beqz	a5,4968 <concreate+0x1c6>
    4a22:	01671363          	bne	a4,s6,4a28 <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    4a26:	f129                	bnez	a0,4968 <concreate+0x1c6>
      unlink(file);
    4a28:	fa840513          	addi	a0,s0,-88
    4a2c:	00001097          	auipc	ra,0x1
    4a30:	c84080e7          	jalr	-892(ra) # 56b0 <unlink>
      unlink(file);
    4a34:	fa840513          	addi	a0,s0,-88
    4a38:	00001097          	auipc	ra,0x1
    4a3c:	c78080e7          	jalr	-904(ra) # 56b0 <unlink>
      unlink(file);
    4a40:	fa840513          	addi	a0,s0,-88
    4a44:	00001097          	auipc	ra,0x1
    4a48:	c6c080e7          	jalr	-916(ra) # 56b0 <unlink>
      unlink(file);
    4a4c:	fa840513          	addi	a0,s0,-88
    4a50:	00001097          	auipc	ra,0x1
    4a54:	c60080e7          	jalr	-928(ra) # 56b0 <unlink>
      unlink(file);
    4a58:	fa840513          	addi	a0,s0,-88
    4a5c:	00001097          	auipc	ra,0x1
    4a60:	c54080e7          	jalr	-940(ra) # 56b0 <unlink>
      unlink(file);
    4a64:	fa840513          	addi	a0,s0,-88
    4a68:	00001097          	auipc	ra,0x1
    4a6c:	c48080e7          	jalr	-952(ra) # 56b0 <unlink>
    4a70:	bfb5                	j	49ec <concreate+0x24a>
      exit(0);
    4a72:	4501                	li	a0,0
    4a74:	00001097          	auipc	ra,0x1
    4a78:	bec080e7          	jalr	-1044(ra) # 5660 <exit>
      close(fd);
    4a7c:	00001097          	auipc	ra,0x1
    4a80:	c0c080e7          	jalr	-1012(ra) # 5688 <close>
    if(pid == 0) {
    4a84:	bb65                	j	483c <concreate+0x9a>
      close(fd);
    4a86:	00001097          	auipc	ra,0x1
    4a8a:	c02080e7          	jalr	-1022(ra) # 5688 <close>
      wait(&xstatus);
    4a8e:	f6c40513          	addi	a0,s0,-148
    4a92:	00001097          	auipc	ra,0x1
    4a96:	bd6080e7          	jalr	-1066(ra) # 5668 <wait>
      if(xstatus != 0)
    4a9a:	f6c42483          	lw	s1,-148(s0)
    4a9e:	da0494e3          	bnez	s1,4846 <concreate+0xa4>
  for(i = 0; i < N; i++){
    4aa2:	2905                	addiw	s2,s2,1
    4aa4:	db4906e3          	beq	s2,s4,4850 <concreate+0xae>
    file[1] = '0' + i;
    4aa8:	0309079b          	addiw	a5,s2,48
    4aac:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4ab0:	fa840513          	addi	a0,s0,-88
    4ab4:	00001097          	auipc	ra,0x1
    4ab8:	bfc080e7          	jalr	-1028(ra) # 56b0 <unlink>
    pid = fork();
    4abc:	00001097          	auipc	ra,0x1
    4ac0:	b9c080e7          	jalr	-1124(ra) # 5658 <fork>
    if(pid && (i % 3) == 1){
    4ac4:	d20503e3          	beqz	a0,47ea <concreate+0x48>
    4ac8:	036967bb          	remw	a5,s2,s6
    4acc:	d15787e3          	beq	a5,s5,47da <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4ad0:	20200593          	li	a1,514
    4ad4:	fa840513          	addi	a0,s0,-88
    4ad8:	00001097          	auipc	ra,0x1
    4adc:	bc8080e7          	jalr	-1080(ra) # 56a0 <open>
      if(fd < 0){
    4ae0:	fa0553e3          	bgez	a0,4a86 <concreate+0x2e4>
    4ae4:	b31d                	j	480a <concreate+0x68>
}
    4ae6:	60ea                	ld	ra,152(sp)
    4ae8:	644a                	ld	s0,144(sp)
    4aea:	64aa                	ld	s1,136(sp)
    4aec:	690a                	ld	s2,128(sp)
    4aee:	79e6                	ld	s3,120(sp)
    4af0:	7a46                	ld	s4,112(sp)
    4af2:	7aa6                	ld	s5,104(sp)
    4af4:	7b06                	ld	s6,96(sp)
    4af6:	6be6                	ld	s7,88(sp)
    4af8:	610d                	addi	sp,sp,160
    4afa:	8082                	ret

0000000000004afc <bigfile>:
{
    4afc:	7139                	addi	sp,sp,-64
    4afe:	fc06                	sd	ra,56(sp)
    4b00:	f822                	sd	s0,48(sp)
    4b02:	f426                	sd	s1,40(sp)
    4b04:	f04a                	sd	s2,32(sp)
    4b06:	ec4e                	sd	s3,24(sp)
    4b08:	e852                	sd	s4,16(sp)
    4b0a:	e456                	sd	s5,8(sp)
    4b0c:	0080                	addi	s0,sp,64
    4b0e:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    4b10:	00003517          	auipc	a0,0x3
    4b14:	1b850513          	addi	a0,a0,440 # 7cc8 <malloc+0x2230>
    4b18:	00001097          	auipc	ra,0x1
    4b1c:	b98080e7          	jalr	-1128(ra) # 56b0 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    4b20:	20200593          	li	a1,514
    4b24:	00003517          	auipc	a0,0x3
    4b28:	1a450513          	addi	a0,a0,420 # 7cc8 <malloc+0x2230>
    4b2c:	00001097          	auipc	ra,0x1
    4b30:	b74080e7          	jalr	-1164(ra) # 56a0 <open>
    4b34:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    4b36:	4481                	li	s1,0
    memset(buf, i, SZ);
    4b38:	00007917          	auipc	s2,0x7
    4b3c:	fb890913          	addi	s2,s2,-72 # baf0 <buf>
  for(i = 0; i < N; i++){
    4b40:	4a51                	li	s4,20
  if(fd < 0){
    4b42:	0a054063          	bltz	a0,4be2 <bigfile+0xe6>
    memset(buf, i, SZ);
    4b46:	25800613          	li	a2,600
    4b4a:	85a6                	mv	a1,s1
    4b4c:	854a                	mv	a0,s2
    4b4e:	00001097          	auipc	ra,0x1
    4b52:	8fc080e7          	jalr	-1796(ra) # 544a <memset>
    if(write(fd, buf, SZ) != SZ){
    4b56:	25800613          	li	a2,600
    4b5a:	85ca                	mv	a1,s2
    4b5c:	854e                	mv	a0,s3
    4b5e:	00001097          	auipc	ra,0x1
    4b62:	b22080e7          	jalr	-1246(ra) # 5680 <write>
    4b66:	25800793          	li	a5,600
    4b6a:	08f51a63          	bne	a0,a5,4bfe <bigfile+0x102>
  for(i = 0; i < N; i++){
    4b6e:	2485                	addiw	s1,s1,1
    4b70:	fd449be3          	bne	s1,s4,4b46 <bigfile+0x4a>
  close(fd);
    4b74:	854e                	mv	a0,s3
    4b76:	00001097          	auipc	ra,0x1
    4b7a:	b12080e7          	jalr	-1262(ra) # 5688 <close>
  fd = open("bigfile.dat", 0);
    4b7e:	4581                	li	a1,0
    4b80:	00003517          	auipc	a0,0x3
    4b84:	14850513          	addi	a0,a0,328 # 7cc8 <malloc+0x2230>
    4b88:	00001097          	auipc	ra,0x1
    4b8c:	b18080e7          	jalr	-1256(ra) # 56a0 <open>
    4b90:	8a2a                	mv	s4,a0
  total = 0;
    4b92:	4981                	li	s3,0
  for(i = 0; ; i++){
    4b94:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4b96:	00007917          	auipc	s2,0x7
    4b9a:	f5a90913          	addi	s2,s2,-166 # baf0 <buf>
  if(fd < 0){
    4b9e:	06054e63          	bltz	a0,4c1a <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    4ba2:	12c00613          	li	a2,300
    4ba6:	85ca                	mv	a1,s2
    4ba8:	8552                	mv	a0,s4
    4baa:	00001097          	auipc	ra,0x1
    4bae:	ace080e7          	jalr	-1330(ra) # 5678 <read>
    if(cc < 0){
    4bb2:	08054263          	bltz	a0,4c36 <bigfile+0x13a>
    if(cc == 0)
    4bb6:	c971                	beqz	a0,4c8a <bigfile+0x18e>
    if(cc != SZ/2){
    4bb8:	12c00793          	li	a5,300
    4bbc:	08f51b63          	bne	a0,a5,4c52 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    4bc0:	01f4d79b          	srliw	a5,s1,0x1f
    4bc4:	9fa5                	addw	a5,a5,s1
    4bc6:	4017d79b          	sraiw	a5,a5,0x1
    4bca:	00094703          	lbu	a4,0(s2)
    4bce:	0af71063          	bne	a4,a5,4c6e <bigfile+0x172>
    4bd2:	12b94703          	lbu	a4,299(s2)
    4bd6:	08f71c63          	bne	a4,a5,4c6e <bigfile+0x172>
    total += cc;
    4bda:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    4bde:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    4be0:	b7c9                	j	4ba2 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    4be2:	85d6                	mv	a1,s5
    4be4:	00003517          	auipc	a0,0x3
    4be8:	0f450513          	addi	a0,a0,244 # 7cd8 <malloc+0x2240>
    4bec:	00001097          	auipc	ra,0x1
    4bf0:	dec080e7          	jalr	-532(ra) # 59d8 <printf>
    exit(1);
    4bf4:	4505                	li	a0,1
    4bf6:	00001097          	auipc	ra,0x1
    4bfa:	a6a080e7          	jalr	-1430(ra) # 5660 <exit>
      printf("%s: write bigfile failed\n", s);
    4bfe:	85d6                	mv	a1,s5
    4c00:	00003517          	auipc	a0,0x3
    4c04:	0f850513          	addi	a0,a0,248 # 7cf8 <malloc+0x2260>
    4c08:	00001097          	auipc	ra,0x1
    4c0c:	dd0080e7          	jalr	-560(ra) # 59d8 <printf>
      exit(1);
    4c10:	4505                	li	a0,1
    4c12:	00001097          	auipc	ra,0x1
    4c16:	a4e080e7          	jalr	-1458(ra) # 5660 <exit>
    printf("%s: cannot open bigfile\n", s);
    4c1a:	85d6                	mv	a1,s5
    4c1c:	00003517          	auipc	a0,0x3
    4c20:	0fc50513          	addi	a0,a0,252 # 7d18 <malloc+0x2280>
    4c24:	00001097          	auipc	ra,0x1
    4c28:	db4080e7          	jalr	-588(ra) # 59d8 <printf>
    exit(1);
    4c2c:	4505                	li	a0,1
    4c2e:	00001097          	auipc	ra,0x1
    4c32:	a32080e7          	jalr	-1486(ra) # 5660 <exit>
      printf("%s: read bigfile failed\n", s);
    4c36:	85d6                	mv	a1,s5
    4c38:	00003517          	auipc	a0,0x3
    4c3c:	10050513          	addi	a0,a0,256 # 7d38 <malloc+0x22a0>
    4c40:	00001097          	auipc	ra,0x1
    4c44:	d98080e7          	jalr	-616(ra) # 59d8 <printf>
      exit(1);
    4c48:	4505                	li	a0,1
    4c4a:	00001097          	auipc	ra,0x1
    4c4e:	a16080e7          	jalr	-1514(ra) # 5660 <exit>
      printf("%s: short read bigfile\n", s);
    4c52:	85d6                	mv	a1,s5
    4c54:	00003517          	auipc	a0,0x3
    4c58:	10450513          	addi	a0,a0,260 # 7d58 <malloc+0x22c0>
    4c5c:	00001097          	auipc	ra,0x1
    4c60:	d7c080e7          	jalr	-644(ra) # 59d8 <printf>
      exit(1);
    4c64:	4505                	li	a0,1
    4c66:	00001097          	auipc	ra,0x1
    4c6a:	9fa080e7          	jalr	-1542(ra) # 5660 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4c6e:	85d6                	mv	a1,s5
    4c70:	00003517          	auipc	a0,0x3
    4c74:	10050513          	addi	a0,a0,256 # 7d70 <malloc+0x22d8>
    4c78:	00001097          	auipc	ra,0x1
    4c7c:	d60080e7          	jalr	-672(ra) # 59d8 <printf>
      exit(1);
    4c80:	4505                	li	a0,1
    4c82:	00001097          	auipc	ra,0x1
    4c86:	9de080e7          	jalr	-1570(ra) # 5660 <exit>
  close(fd);
    4c8a:	8552                	mv	a0,s4
    4c8c:	00001097          	auipc	ra,0x1
    4c90:	9fc080e7          	jalr	-1540(ra) # 5688 <close>
  if(total != N*SZ){
    4c94:	678d                	lui	a5,0x3
    4c96:	ee078793          	addi	a5,a5,-288 # 2ee0 <exitiputtest+0x1c>
    4c9a:	02f99363          	bne	s3,a5,4cc0 <bigfile+0x1c4>
  unlink("bigfile.dat");
    4c9e:	00003517          	auipc	a0,0x3
    4ca2:	02a50513          	addi	a0,a0,42 # 7cc8 <malloc+0x2230>
    4ca6:	00001097          	auipc	ra,0x1
    4caa:	a0a080e7          	jalr	-1526(ra) # 56b0 <unlink>
}
    4cae:	70e2                	ld	ra,56(sp)
    4cb0:	7442                	ld	s0,48(sp)
    4cb2:	74a2                	ld	s1,40(sp)
    4cb4:	7902                	ld	s2,32(sp)
    4cb6:	69e2                	ld	s3,24(sp)
    4cb8:	6a42                	ld	s4,16(sp)
    4cba:	6aa2                	ld	s5,8(sp)
    4cbc:	6121                	addi	sp,sp,64
    4cbe:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4cc0:	85d6                	mv	a1,s5
    4cc2:	00003517          	auipc	a0,0x3
    4cc6:	0ce50513          	addi	a0,a0,206 # 7d90 <malloc+0x22f8>
    4cca:	00001097          	auipc	ra,0x1
    4cce:	d0e080e7          	jalr	-754(ra) # 59d8 <printf>
    exit(1);
    4cd2:	4505                	li	a0,1
    4cd4:	00001097          	auipc	ra,0x1
    4cd8:	98c080e7          	jalr	-1652(ra) # 5660 <exit>

0000000000004cdc <fsfull>:
{
    4cdc:	7171                	addi	sp,sp,-176
    4cde:	f506                	sd	ra,168(sp)
    4ce0:	f122                	sd	s0,160(sp)
    4ce2:	ed26                	sd	s1,152(sp)
    4ce4:	e94a                	sd	s2,144(sp)
    4ce6:	e54e                	sd	s3,136(sp)
    4ce8:	e152                	sd	s4,128(sp)
    4cea:	fcd6                	sd	s5,120(sp)
    4cec:	f8da                	sd	s6,112(sp)
    4cee:	f4de                	sd	s7,104(sp)
    4cf0:	f0e2                	sd	s8,96(sp)
    4cf2:	ece6                	sd	s9,88(sp)
    4cf4:	e8ea                	sd	s10,80(sp)
    4cf6:	e4ee                	sd	s11,72(sp)
    4cf8:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4cfa:	00003517          	auipc	a0,0x3
    4cfe:	0b650513          	addi	a0,a0,182 # 7db0 <malloc+0x2318>
    4d02:	00001097          	auipc	ra,0x1
    4d06:	cd6080e7          	jalr	-810(ra) # 59d8 <printf>
  for(nfiles = 0; ; nfiles++){
    4d0a:	4481                	li	s1,0
    name[0] = 'f';
    4d0c:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4d10:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4d14:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4d18:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4d1a:	00003c97          	auipc	s9,0x3
    4d1e:	0a6c8c93          	addi	s9,s9,166 # 7dc0 <malloc+0x2328>
    int total = 0;
    4d22:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4d24:	00007a17          	auipc	s4,0x7
    4d28:	dcca0a13          	addi	s4,s4,-564 # baf0 <buf>
    name[0] = 'f';
    4d2c:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4d30:	0384c7bb          	divw	a5,s1,s8
    4d34:	0307879b          	addiw	a5,a5,48
    4d38:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4d3c:	0384e7bb          	remw	a5,s1,s8
    4d40:	0377c7bb          	divw	a5,a5,s7
    4d44:	0307879b          	addiw	a5,a5,48
    4d48:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4d4c:	0374e7bb          	remw	a5,s1,s7
    4d50:	0367c7bb          	divw	a5,a5,s6
    4d54:	0307879b          	addiw	a5,a5,48
    4d58:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4d5c:	0364e7bb          	remw	a5,s1,s6
    4d60:	0307879b          	addiw	a5,a5,48
    4d64:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4d68:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4d6c:	f5040593          	addi	a1,s0,-176
    4d70:	8566                	mv	a0,s9
    4d72:	00001097          	auipc	ra,0x1
    4d76:	c66080e7          	jalr	-922(ra) # 59d8 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4d7a:	20200593          	li	a1,514
    4d7e:	f5040513          	addi	a0,s0,-176
    4d82:	00001097          	auipc	ra,0x1
    4d86:	91e080e7          	jalr	-1762(ra) # 56a0 <open>
    4d8a:	89aa                	mv	s3,a0
    if(fd < 0){
    4d8c:	0a055663          	bgez	a0,4e38 <fsfull+0x15c>
      printf("open %s failed\n", name);
    4d90:	f5040593          	addi	a1,s0,-176
    4d94:	00003517          	auipc	a0,0x3
    4d98:	03c50513          	addi	a0,a0,60 # 7dd0 <malloc+0x2338>
    4d9c:	00001097          	auipc	ra,0x1
    4da0:	c3c080e7          	jalr	-964(ra) # 59d8 <printf>
  while(nfiles >= 0){
    4da4:	0604c363          	bltz	s1,4e0a <fsfull+0x12e>
    name[0] = 'f';
    4da8:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4dac:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4db0:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4db4:	4929                	li	s2,10
  while(nfiles >= 0){
    4db6:	5afd                	li	s5,-1
    name[0] = 'f';
    4db8:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4dbc:	0344c7bb          	divw	a5,s1,s4
    4dc0:	0307879b          	addiw	a5,a5,48
    4dc4:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4dc8:	0344e7bb          	remw	a5,s1,s4
    4dcc:	0337c7bb          	divw	a5,a5,s3
    4dd0:	0307879b          	addiw	a5,a5,48
    4dd4:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4dd8:	0334e7bb          	remw	a5,s1,s3
    4ddc:	0327c7bb          	divw	a5,a5,s2
    4de0:	0307879b          	addiw	a5,a5,48
    4de4:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4de8:	0324e7bb          	remw	a5,s1,s2
    4dec:	0307879b          	addiw	a5,a5,48
    4df0:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4df4:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4df8:	f5040513          	addi	a0,s0,-176
    4dfc:	00001097          	auipc	ra,0x1
    4e00:	8b4080e7          	jalr	-1868(ra) # 56b0 <unlink>
    nfiles--;
    4e04:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4e06:	fb5499e3          	bne	s1,s5,4db8 <fsfull+0xdc>
  printf("fsfull test finished\n");
    4e0a:	00003517          	auipc	a0,0x3
    4e0e:	fe650513          	addi	a0,a0,-26 # 7df0 <malloc+0x2358>
    4e12:	00001097          	auipc	ra,0x1
    4e16:	bc6080e7          	jalr	-1082(ra) # 59d8 <printf>
}
    4e1a:	70aa                	ld	ra,168(sp)
    4e1c:	740a                	ld	s0,160(sp)
    4e1e:	64ea                	ld	s1,152(sp)
    4e20:	694a                	ld	s2,144(sp)
    4e22:	69aa                	ld	s3,136(sp)
    4e24:	6a0a                	ld	s4,128(sp)
    4e26:	7ae6                	ld	s5,120(sp)
    4e28:	7b46                	ld	s6,112(sp)
    4e2a:	7ba6                	ld	s7,104(sp)
    4e2c:	7c06                	ld	s8,96(sp)
    4e2e:	6ce6                	ld	s9,88(sp)
    4e30:	6d46                	ld	s10,80(sp)
    4e32:	6da6                	ld	s11,72(sp)
    4e34:	614d                	addi	sp,sp,176
    4e36:	8082                	ret
    int total = 0;
    4e38:	896e                	mv	s2,s11
      if(cc < BSIZE)
    4e3a:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4e3e:	40000613          	li	a2,1024
    4e42:	85d2                	mv	a1,s4
    4e44:	854e                	mv	a0,s3
    4e46:	00001097          	auipc	ra,0x1
    4e4a:	83a080e7          	jalr	-1990(ra) # 5680 <write>
      if(cc < BSIZE)
    4e4e:	00aad563          	ble	a0,s5,4e58 <fsfull+0x17c>
      total += cc;
    4e52:	00a9093b          	addw	s2,s2,a0
    while(1){
    4e56:	b7e5                	j	4e3e <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4e58:	85ca                	mv	a1,s2
    4e5a:	00003517          	auipc	a0,0x3
    4e5e:	f8650513          	addi	a0,a0,-122 # 7de0 <malloc+0x2348>
    4e62:	00001097          	auipc	ra,0x1
    4e66:	b76080e7          	jalr	-1162(ra) # 59d8 <printf>
    close(fd);
    4e6a:	854e                	mv	a0,s3
    4e6c:	00001097          	auipc	ra,0x1
    4e70:	81c080e7          	jalr	-2020(ra) # 5688 <close>
    if(total == 0)
    4e74:	f20908e3          	beqz	s2,4da4 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4e78:	2485                	addiw	s1,s1,1
    4e7a:	bd4d                	j	4d2c <fsfull+0x50>

0000000000004e7c <rand>:
{
    4e7c:	1141                	addi	sp,sp,-16
    4e7e:	e422                	sd	s0,8(sp)
    4e80:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4e82:	00003717          	auipc	a4,0x3
    4e86:	44670713          	addi	a4,a4,1094 # 82c8 <randstate>
    4e8a:	6308                	ld	a0,0(a4)
    4e8c:	001967b7          	lui	a5,0x196
    4e90:	60d78793          	addi	a5,a5,1549 # 19660d <_end+0x187b0d>
    4e94:	02f50533          	mul	a0,a0,a5
    4e98:	3c6ef7b7          	lui	a5,0x3c6ef
    4e9c:	35f78793          	addi	a5,a5,863 # 3c6ef35f <_end+0x3c6e085f>
    4ea0:	953e                	add	a0,a0,a5
    4ea2:	e308                	sd	a0,0(a4)
}
    4ea4:	2501                	sext.w	a0,a0
    4ea6:	6422                	ld	s0,8(sp)
    4ea8:	0141                	addi	sp,sp,16
    4eaa:	8082                	ret

0000000000004eac <badwrite>:
{
    4eac:	7179                	addi	sp,sp,-48
    4eae:	f406                	sd	ra,40(sp)
    4eb0:	f022                	sd	s0,32(sp)
    4eb2:	ec26                	sd	s1,24(sp)
    4eb4:	e84a                	sd	s2,16(sp)
    4eb6:	e44e                	sd	s3,8(sp)
    4eb8:	e052                	sd	s4,0(sp)
    4eba:	1800                	addi	s0,sp,48
  unlink("junk");
    4ebc:	00003517          	auipc	a0,0x3
    4ec0:	f4c50513          	addi	a0,a0,-180 # 7e08 <malloc+0x2370>
    4ec4:	00000097          	auipc	ra,0x0
    4ec8:	7ec080e7          	jalr	2028(ra) # 56b0 <unlink>
    4ecc:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4ed0:	00003997          	auipc	s3,0x3
    4ed4:	f3898993          	addi	s3,s3,-200 # 7e08 <malloc+0x2370>
    write(fd, (char*)0xffffffffffL, 1);
    4ed8:	5a7d                	li	s4,-1
    4eda:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4ede:	20100593          	li	a1,513
    4ee2:	854e                	mv	a0,s3
    4ee4:	00000097          	auipc	ra,0x0
    4ee8:	7bc080e7          	jalr	1980(ra) # 56a0 <open>
    4eec:	84aa                	mv	s1,a0
    if(fd < 0){
    4eee:	06054b63          	bltz	a0,4f64 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4ef2:	4605                	li	a2,1
    4ef4:	85d2                	mv	a1,s4
    4ef6:	00000097          	auipc	ra,0x0
    4efa:	78a080e7          	jalr	1930(ra) # 5680 <write>
    close(fd);
    4efe:	8526                	mv	a0,s1
    4f00:	00000097          	auipc	ra,0x0
    4f04:	788080e7          	jalr	1928(ra) # 5688 <close>
    unlink("junk");
    4f08:	854e                	mv	a0,s3
    4f0a:	00000097          	auipc	ra,0x0
    4f0e:	7a6080e7          	jalr	1958(ra) # 56b0 <unlink>
  for(int i = 0; i < assumed_free; i++){
    4f12:	397d                	addiw	s2,s2,-1
    4f14:	fc0915e3          	bnez	s2,4ede <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    4f18:	20100593          	li	a1,513
    4f1c:	00003517          	auipc	a0,0x3
    4f20:	eec50513          	addi	a0,a0,-276 # 7e08 <malloc+0x2370>
    4f24:	00000097          	auipc	ra,0x0
    4f28:	77c080e7          	jalr	1916(ra) # 56a0 <open>
    4f2c:	84aa                	mv	s1,a0
  if(fd < 0){
    4f2e:	04054863          	bltz	a0,4f7e <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    4f32:	4605                	li	a2,1
    4f34:	00001597          	auipc	a1,0x1
    4f38:	0c458593          	addi	a1,a1,196 # 5ff8 <malloc+0x560>
    4f3c:	00000097          	auipc	ra,0x0
    4f40:	744080e7          	jalr	1860(ra) # 5680 <write>
    4f44:	4785                	li	a5,1
    4f46:	04f50963          	beq	a0,a5,4f98 <badwrite+0xec>
    printf("write failed\n");
    4f4a:	00003517          	auipc	a0,0x3
    4f4e:	ede50513          	addi	a0,a0,-290 # 7e28 <malloc+0x2390>
    4f52:	00001097          	auipc	ra,0x1
    4f56:	a86080e7          	jalr	-1402(ra) # 59d8 <printf>
    exit(1);
    4f5a:	4505                	li	a0,1
    4f5c:	00000097          	auipc	ra,0x0
    4f60:	704080e7          	jalr	1796(ra) # 5660 <exit>
      printf("open junk failed\n");
    4f64:	00003517          	auipc	a0,0x3
    4f68:	eac50513          	addi	a0,a0,-340 # 7e10 <malloc+0x2378>
    4f6c:	00001097          	auipc	ra,0x1
    4f70:	a6c080e7          	jalr	-1428(ra) # 59d8 <printf>
      exit(1);
    4f74:	4505                	li	a0,1
    4f76:	00000097          	auipc	ra,0x0
    4f7a:	6ea080e7          	jalr	1770(ra) # 5660 <exit>
    printf("open junk failed\n");
    4f7e:	00003517          	auipc	a0,0x3
    4f82:	e9250513          	addi	a0,a0,-366 # 7e10 <malloc+0x2378>
    4f86:	00001097          	auipc	ra,0x1
    4f8a:	a52080e7          	jalr	-1454(ra) # 59d8 <printf>
    exit(1);
    4f8e:	4505                	li	a0,1
    4f90:	00000097          	auipc	ra,0x0
    4f94:	6d0080e7          	jalr	1744(ra) # 5660 <exit>
  close(fd);
    4f98:	8526                	mv	a0,s1
    4f9a:	00000097          	auipc	ra,0x0
    4f9e:	6ee080e7          	jalr	1774(ra) # 5688 <close>
  unlink("junk");
    4fa2:	00003517          	auipc	a0,0x3
    4fa6:	e6650513          	addi	a0,a0,-410 # 7e08 <malloc+0x2370>
    4faa:	00000097          	auipc	ra,0x0
    4fae:	706080e7          	jalr	1798(ra) # 56b0 <unlink>
  exit(0);
    4fb2:	4501                	li	a0,0
    4fb4:	00000097          	auipc	ra,0x0
    4fb8:	6ac080e7          	jalr	1708(ra) # 5660 <exit>

0000000000004fbc <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    4fbc:	7139                	addi	sp,sp,-64
    4fbe:	fc06                	sd	ra,56(sp)
    4fc0:	f822                	sd	s0,48(sp)
    4fc2:	f426                	sd	s1,40(sp)
    4fc4:	f04a                	sd	s2,32(sp)
    4fc6:	ec4e                	sd	s3,24(sp)
    4fc8:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    4fca:	fc840513          	addi	a0,s0,-56
    4fce:	00000097          	auipc	ra,0x0
    4fd2:	6a2080e7          	jalr	1698(ra) # 5670 <pipe>
    4fd6:	06054863          	bltz	a0,5046 <countfree+0x8a>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    4fda:	00000097          	auipc	ra,0x0
    4fde:	67e080e7          	jalr	1662(ra) # 5658 <fork>

  if(pid < 0){
    4fe2:	06054f63          	bltz	a0,5060 <countfree+0xa4>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    4fe6:	ed59                	bnez	a0,5084 <countfree+0xc8>
    close(fds[0]);
    4fe8:	fc842503          	lw	a0,-56(s0)
    4fec:	00000097          	auipc	ra,0x0
    4ff0:	69c080e7          	jalr	1692(ra) # 5688 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    4ff4:	54fd                	li	s1,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    4ff6:	4985                	li	s3,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    4ff8:	00001917          	auipc	s2,0x1
    4ffc:	00090913          	mv	s2,s2
      uint64 a = (uint64) sbrk(4096);
    5000:	6505                	lui	a0,0x1
    5002:	00000097          	auipc	ra,0x0
    5006:	6e6080e7          	jalr	1766(ra) # 56e8 <sbrk>
      if(a == 0xffffffffffffffff){
    500a:	06950863          	beq	a0,s1,507a <countfree+0xbe>
      *(char *)(a + 4096 - 1) = 1;
    500e:	6785                	lui	a5,0x1
    5010:	97aa                	add	a5,a5,a0
    5012:	ff378fa3          	sb	s3,-1(a5) # fff <bigdir+0x8b>
      if(write(fds[1], "x", 1) != 1){
    5016:	4605                	li	a2,1
    5018:	85ca                	mv	a1,s2
    501a:	fcc42503          	lw	a0,-52(s0)
    501e:	00000097          	auipc	ra,0x0
    5022:	662080e7          	jalr	1634(ra) # 5680 <write>
    5026:	4785                	li	a5,1
    5028:	fcf50ce3          	beq	a0,a5,5000 <countfree+0x44>
        printf("write() failed in countfree()\n");
    502c:	00003517          	auipc	a0,0x3
    5030:	e4c50513          	addi	a0,a0,-436 # 7e78 <malloc+0x23e0>
    5034:	00001097          	auipc	ra,0x1
    5038:	9a4080e7          	jalr	-1628(ra) # 59d8 <printf>
        exit(1);
    503c:	4505                	li	a0,1
    503e:	00000097          	auipc	ra,0x0
    5042:	622080e7          	jalr	1570(ra) # 5660 <exit>
    printf("pipe() failed in countfree()\n");
    5046:	00003517          	auipc	a0,0x3
    504a:	df250513          	addi	a0,a0,-526 # 7e38 <malloc+0x23a0>
    504e:	00001097          	auipc	ra,0x1
    5052:	98a080e7          	jalr	-1654(ra) # 59d8 <printf>
    exit(1);
    5056:	4505                	li	a0,1
    5058:	00000097          	auipc	ra,0x0
    505c:	608080e7          	jalr	1544(ra) # 5660 <exit>
    printf("fork failed in countfree()\n");
    5060:	00003517          	auipc	a0,0x3
    5064:	df850513          	addi	a0,a0,-520 # 7e58 <malloc+0x23c0>
    5068:	00001097          	auipc	ra,0x1
    506c:	970080e7          	jalr	-1680(ra) # 59d8 <printf>
    exit(1);
    5070:	4505                	li	a0,1
    5072:	00000097          	auipc	ra,0x0
    5076:	5ee080e7          	jalr	1518(ra) # 5660 <exit>
      }
    }

    exit(0);
    507a:	4501                	li	a0,0
    507c:	00000097          	auipc	ra,0x0
    5080:	5e4080e7          	jalr	1508(ra) # 5660 <exit>
  }

  close(fds[1]);
    5084:	fcc42503          	lw	a0,-52(s0)
    5088:	00000097          	auipc	ra,0x0
    508c:	600080e7          	jalr	1536(ra) # 5688 <close>

  int n = 0;
    5090:	4481                	li	s1,0
    5092:	a839                	j	50b0 <countfree+0xf4>
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    if(cc < 0){
      printf("read() failed in countfree()\n");
    5094:	00003517          	auipc	a0,0x3
    5098:	e0450513          	addi	a0,a0,-508 # 7e98 <malloc+0x2400>
    509c:	00001097          	auipc	ra,0x1
    50a0:	93c080e7          	jalr	-1732(ra) # 59d8 <printf>
      exit(1);
    50a4:	4505                	li	a0,1
    50a6:	00000097          	auipc	ra,0x0
    50aa:	5ba080e7          	jalr	1466(ra) # 5660 <exit>
    }
    if(cc == 0)
      break;
    n += 1;
    50ae:	2485                	addiw	s1,s1,1
    int cc = read(fds[0], &c, 1);
    50b0:	4605                	li	a2,1
    50b2:	fc740593          	addi	a1,s0,-57
    50b6:	fc842503          	lw	a0,-56(s0)
    50ba:	00000097          	auipc	ra,0x0
    50be:	5be080e7          	jalr	1470(ra) # 5678 <read>
    if(cc < 0){
    50c2:	fc0549e3          	bltz	a0,5094 <countfree+0xd8>
    if(cc == 0)
    50c6:	f565                	bnez	a0,50ae <countfree+0xf2>
  }

  close(fds[0]);
    50c8:	fc842503          	lw	a0,-56(s0)
    50cc:	00000097          	auipc	ra,0x0
    50d0:	5bc080e7          	jalr	1468(ra) # 5688 <close>
  wait((int*)0);
    50d4:	4501                	li	a0,0
    50d6:	00000097          	auipc	ra,0x0
    50da:	592080e7          	jalr	1426(ra) # 5668 <wait>
  
  return n;
}
    50de:	8526                	mv	a0,s1
    50e0:	70e2                	ld	ra,56(sp)
    50e2:	7442                	ld	s0,48(sp)
    50e4:	74a2                	ld	s1,40(sp)
    50e6:	7902                	ld	s2,32(sp)
    50e8:	69e2                	ld	s3,24(sp)
    50ea:	6121                	addi	sp,sp,64
    50ec:	8082                	ret

00000000000050ee <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    50ee:	7179                	addi	sp,sp,-48
    50f0:	f406                	sd	ra,40(sp)
    50f2:	f022                	sd	s0,32(sp)
    50f4:	ec26                	sd	s1,24(sp)
    50f6:	e84a                	sd	s2,16(sp)
    50f8:	1800                	addi	s0,sp,48
    50fa:	84aa                	mv	s1,a0
    50fc:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    50fe:	00003517          	auipc	a0,0x3
    5102:	dba50513          	addi	a0,a0,-582 # 7eb8 <malloc+0x2420>
    5106:	00001097          	auipc	ra,0x1
    510a:	8d2080e7          	jalr	-1838(ra) # 59d8 <printf>
  if((pid = fork()) < 0) {
    510e:	00000097          	auipc	ra,0x0
    5112:	54a080e7          	jalr	1354(ra) # 5658 <fork>
    5116:	02054e63          	bltz	a0,5152 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    511a:	c929                	beqz	a0,516c <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    511c:	fdc40513          	addi	a0,s0,-36
    5120:	00000097          	auipc	ra,0x0
    5124:	548080e7          	jalr	1352(ra) # 5668 <wait>
    if(xstatus != 0) 
    5128:	fdc42783          	lw	a5,-36(s0)
    512c:	c7b9                	beqz	a5,517a <run+0x8c>
      printf("FAILED\n");
    512e:	00003517          	auipc	a0,0x3
    5132:	db250513          	addi	a0,a0,-590 # 7ee0 <malloc+0x2448>
    5136:	00001097          	auipc	ra,0x1
    513a:	8a2080e7          	jalr	-1886(ra) # 59d8 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    513e:	fdc42503          	lw	a0,-36(s0)
  }
}
    5142:	00153513          	seqz	a0,a0
    5146:	70a2                	ld	ra,40(sp)
    5148:	7402                	ld	s0,32(sp)
    514a:	64e2                	ld	s1,24(sp)
    514c:	6942                	ld	s2,16(sp)
    514e:	6145                	addi	sp,sp,48
    5150:	8082                	ret
    printf("runtest: fork error\n");
    5152:	00003517          	auipc	a0,0x3
    5156:	d7650513          	addi	a0,a0,-650 # 7ec8 <malloc+0x2430>
    515a:	00001097          	auipc	ra,0x1
    515e:	87e080e7          	jalr	-1922(ra) # 59d8 <printf>
    exit(1);
    5162:	4505                	li	a0,1
    5164:	00000097          	auipc	ra,0x0
    5168:	4fc080e7          	jalr	1276(ra) # 5660 <exit>
    f(s);
    516c:	854a                	mv	a0,s2
    516e:	9482                	jalr	s1
    exit(0);
    5170:	4501                	li	a0,0
    5172:	00000097          	auipc	ra,0x0
    5176:	4ee080e7          	jalr	1262(ra) # 5660 <exit>
      printf("OK\n");
    517a:	00003517          	auipc	a0,0x3
    517e:	d6e50513          	addi	a0,a0,-658 # 7ee8 <malloc+0x2450>
    5182:	00001097          	auipc	ra,0x1
    5186:	856080e7          	jalr	-1962(ra) # 59d8 <printf>
    518a:	bf55                	j	513e <run+0x50>

000000000000518c <main>:

int
main(int argc, char *argv[])
{
    518c:	c1010113          	addi	sp,sp,-1008
    5190:	3e113423          	sd	ra,1000(sp)
    5194:	3e813023          	sd	s0,992(sp)
    5198:	3c913c23          	sd	s1,984(sp)
    519c:	3d213823          	sd	s2,976(sp)
    51a0:	3d313423          	sd	s3,968(sp)
    51a4:	3d413023          	sd	s4,960(sp)
    51a8:	3b513c23          	sd	s5,952(sp)
    51ac:	3b613823          	sd	s6,944(sp)
    51b0:	1f80                	addi	s0,sp,1008
    51b2:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    51b4:	4789                	li	a5,2
    51b6:	08f50c63          	beq	a0,a5,524e <main+0xc2>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    51ba:	4785                	li	a5,1
    51bc:	0ca7c763          	blt	a5,a0,528a <main+0xfe>
  char *justone = 0;
    51c0:	4981                	li	s3,0
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    51c2:	00001797          	auipc	a5,0x1
    51c6:	9de78793          	addi	a5,a5,-1570 # 5ba0 <malloc+0x108>
    51ca:	c1040713          	addi	a4,s0,-1008
    51ce:	00001817          	auipc	a6,0x1
    51d2:	d7280813          	addi	a6,a6,-654 # 5f40 <malloc+0x4a8>
    51d6:	6388                	ld	a0,0(a5)
    51d8:	678c                	ld	a1,8(a5)
    51da:	6b90                	ld	a2,16(a5)
    51dc:	6f94                	ld	a3,24(a5)
    51de:	e308                	sd	a0,0(a4)
    51e0:	e70c                	sd	a1,8(a4)
    51e2:	eb10                	sd	a2,16(a4)
    51e4:	ef14                	sd	a3,24(a4)
    51e6:	02078793          	addi	a5,a5,32
    51ea:	02070713          	addi	a4,a4,32
    51ee:	ff0794e3          	bne	a5,a6,51d6 <main+0x4a>
    51f2:	6394                	ld	a3,0(a5)
    51f4:	679c                	ld	a5,8(a5)
    51f6:	e314                	sd	a3,0(a4)
    51f8:	e71c                	sd	a5,8(a4)
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    51fa:	00003517          	auipc	a0,0x3
    51fe:	da650513          	addi	a0,a0,-602 # 7fa0 <malloc+0x2508>
    5202:	00000097          	auipc	ra,0x0
    5206:	7d6080e7          	jalr	2006(ra) # 59d8 <printf>
  int free0 = countfree();
    520a:	00000097          	auipc	ra,0x0
    520e:	db2080e7          	jalr	-590(ra) # 4fbc <countfree>
    5212:	8b2a                	mv	s6,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    5214:	c1843903          	ld	s2,-1000(s0)
    5218:	c1040493          	addi	s1,s0,-1008
  int fail = 0;
    521c:	4a01                	li	s4,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    521e:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    5220:	0a091a63          	bnez	s2,52d4 <main+0x148>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    5224:	00000097          	auipc	ra,0x0
    5228:	d98080e7          	jalr	-616(ra) # 4fbc <countfree>
    522c:	85aa                	mv	a1,a0
    522e:	0f655463          	ble	s6,a0,5316 <main+0x18a>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5232:	865a                	mv	a2,s6
    5234:	00003517          	auipc	a0,0x3
    5238:	d2450513          	addi	a0,a0,-732 # 7f58 <malloc+0x24c0>
    523c:	00000097          	auipc	ra,0x0
    5240:	79c080e7          	jalr	1948(ra) # 59d8 <printf>
    exit(1);
    5244:	4505                	li	a0,1
    5246:	00000097          	auipc	ra,0x0
    524a:	41a080e7          	jalr	1050(ra) # 5660 <exit>
    524e:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5250:	00003597          	auipc	a1,0x3
    5254:	ca058593          	addi	a1,a1,-864 # 7ef0 <malloc+0x2458>
    5258:	6488                	ld	a0,8(s1)
    525a:	00000097          	auipc	ra,0x0
    525e:	192080e7          	jalr	402(ra) # 53ec <strcmp>
    5262:	10050863          	beqz	a0,5372 <main+0x1e6>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    5266:	00003597          	auipc	a1,0x3
    526a:	d7258593          	addi	a1,a1,-654 # 7fd8 <malloc+0x2540>
    526e:	6488                	ld	a0,8(s1)
    5270:	00000097          	auipc	ra,0x0
    5274:	17c080e7          	jalr	380(ra) # 53ec <strcmp>
    5278:	cd75                	beqz	a0,5374 <main+0x1e8>
  } else if(argc == 2 && argv[1][0] != '-'){
    527a:	0084b983          	ld	s3,8(s1)
    527e:	0009c703          	lbu	a4,0(s3)
    5282:	02d00793          	li	a5,45
    5286:	f2f71ee3          	bne	a4,a5,51c2 <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    528a:	00003517          	auipc	a0,0x3
    528e:	c6e50513          	addi	a0,a0,-914 # 7ef8 <malloc+0x2460>
    5292:	00000097          	auipc	ra,0x0
    5296:	746080e7          	jalr	1862(ra) # 59d8 <printf>
    exit(1);
    529a:	4505                	li	a0,1
    529c:	00000097          	auipc	ra,0x0
    52a0:	3c4080e7          	jalr	964(ra) # 5660 <exit>
          exit(1);
    52a4:	4505                	li	a0,1
    52a6:	00000097          	auipc	ra,0x0
    52aa:	3ba080e7          	jalr	954(ra) # 5660 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    52ae:	40a905bb          	subw	a1,s2,a0
    52b2:	855a                	mv	a0,s6
    52b4:	00000097          	auipc	ra,0x0
    52b8:	724080e7          	jalr	1828(ra) # 59d8 <printf>
        if(continuous != 2)
    52bc:	09498763          	beq	s3,s4,534a <main+0x1be>
          exit(1);
    52c0:	4505                	li	a0,1
    52c2:	00000097          	auipc	ra,0x0
    52c6:	39e080e7          	jalr	926(ra) # 5660 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    52ca:	04c1                	addi	s1,s1,16
    52cc:	0084b903          	ld	s2,8(s1)
    52d0:	02090463          	beqz	s2,52f8 <main+0x16c>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    52d4:	00098963          	beqz	s3,52e6 <main+0x15a>
    52d8:	85ce                	mv	a1,s3
    52da:	854a                	mv	a0,s2
    52dc:	00000097          	auipc	ra,0x0
    52e0:	110080e7          	jalr	272(ra) # 53ec <strcmp>
    52e4:	f17d                	bnez	a0,52ca <main+0x13e>
      if(!run(t->f, t->s))
    52e6:	85ca                	mv	a1,s2
    52e8:	6088                	ld	a0,0(s1)
    52ea:	00000097          	auipc	ra,0x0
    52ee:	e04080e7          	jalr	-508(ra) # 50ee <run>
    52f2:	fd61                	bnez	a0,52ca <main+0x13e>
        fail = 1;
    52f4:	8a56                	mv	s4,s5
    52f6:	bfd1                	j	52ca <main+0x13e>
  if(fail){
    52f8:	f20a06e3          	beqz	s4,5224 <main+0x98>
    printf("SOME TESTS FAILED\n");
    52fc:	00003517          	auipc	a0,0x3
    5300:	c4450513          	addi	a0,a0,-956 # 7f40 <malloc+0x24a8>
    5304:	00000097          	auipc	ra,0x0
    5308:	6d4080e7          	jalr	1748(ra) # 59d8 <printf>
    exit(1);
    530c:	4505                	li	a0,1
    530e:	00000097          	auipc	ra,0x0
    5312:	352080e7          	jalr	850(ra) # 5660 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    5316:	00003517          	auipc	a0,0x3
    531a:	c7250513          	addi	a0,a0,-910 # 7f88 <malloc+0x24f0>
    531e:	00000097          	auipc	ra,0x0
    5322:	6ba080e7          	jalr	1722(ra) # 59d8 <printf>
    exit(0);
    5326:	4501                	li	a0,0
    5328:	00000097          	auipc	ra,0x0
    532c:	338080e7          	jalr	824(ra) # 5660 <exit>
        printf("SOME TESTS FAILED\n");
    5330:	8556                	mv	a0,s5
    5332:	00000097          	auipc	ra,0x0
    5336:	6a6080e7          	jalr	1702(ra) # 59d8 <printf>
        if(continuous != 2)
    533a:	f74995e3          	bne	s3,s4,52a4 <main+0x118>
      int free1 = countfree();
    533e:	00000097          	auipc	ra,0x0
    5342:	c7e080e7          	jalr	-898(ra) # 4fbc <countfree>
      if(free1 < free0){
    5346:	f72544e3          	blt	a0,s2,52ae <main+0x122>
      int free0 = countfree();
    534a:	00000097          	auipc	ra,0x0
    534e:	c72080e7          	jalr	-910(ra) # 4fbc <countfree>
    5352:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    5354:	c1843583          	ld	a1,-1000(s0)
    5358:	d1fd                	beqz	a1,533e <main+0x1b2>
    535a:	c1040493          	addi	s1,s0,-1008
        if(!run(t->f, t->s)){
    535e:	6088                	ld	a0,0(s1)
    5360:	00000097          	auipc	ra,0x0
    5364:	d8e080e7          	jalr	-626(ra) # 50ee <run>
    5368:	d561                	beqz	a0,5330 <main+0x1a4>
      for (struct test *t = tests; t->s != 0; t++) {
    536a:	04c1                	addi	s1,s1,16
    536c:	648c                	ld	a1,8(s1)
    536e:	f9e5                	bnez	a1,535e <main+0x1d2>
    5370:	b7f9                	j	533e <main+0x1b2>
    continuous = 1;
    5372:	4985                	li	s3,1
  } tests[] = {
    5374:	00001797          	auipc	a5,0x1
    5378:	82c78793          	addi	a5,a5,-2004 # 5ba0 <malloc+0x108>
    537c:	c1040713          	addi	a4,s0,-1008
    5380:	00001817          	auipc	a6,0x1
    5384:	bc080813          	addi	a6,a6,-1088 # 5f40 <malloc+0x4a8>
    5388:	6388                	ld	a0,0(a5)
    538a:	678c                	ld	a1,8(a5)
    538c:	6b90                	ld	a2,16(a5)
    538e:	6f94                	ld	a3,24(a5)
    5390:	e308                	sd	a0,0(a4)
    5392:	e70c                	sd	a1,8(a4)
    5394:	eb10                	sd	a2,16(a4)
    5396:	ef14                	sd	a3,24(a4)
    5398:	02078793          	addi	a5,a5,32
    539c:	02070713          	addi	a4,a4,32
    53a0:	ff0794e3          	bne	a5,a6,5388 <main+0x1fc>
    53a4:	6394                	ld	a3,0(a5)
    53a6:	679c                	ld	a5,8(a5)
    53a8:	e314                	sd	a3,0(a4)
    53aa:	e71c                	sd	a5,8(a4)
    printf("continuous usertests starting\n");
    53ac:	00003517          	auipc	a0,0x3
    53b0:	c0c50513          	addi	a0,a0,-1012 # 7fb8 <malloc+0x2520>
    53b4:	00000097          	auipc	ra,0x0
    53b8:	624080e7          	jalr	1572(ra) # 59d8 <printf>
        printf("SOME TESTS FAILED\n");
    53bc:	00003a97          	auipc	s5,0x3
    53c0:	b84a8a93          	addi	s5,s5,-1148 # 7f40 <malloc+0x24a8>
        if(continuous != 2)
    53c4:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    53c6:	00003b17          	auipc	s6,0x3
    53ca:	b5ab0b13          	addi	s6,s6,-1190 # 7f20 <malloc+0x2488>
    53ce:	bfb5                	j	534a <main+0x1be>

00000000000053d0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    53d0:	1141                	addi	sp,sp,-16
    53d2:	e422                	sd	s0,8(sp)
    53d4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    53d6:	87aa                	mv	a5,a0
    53d8:	0585                	addi	a1,a1,1
    53da:	0785                	addi	a5,a5,1
    53dc:	fff5c703          	lbu	a4,-1(a1)
    53e0:	fee78fa3          	sb	a4,-1(a5)
    53e4:	fb75                	bnez	a4,53d8 <strcpy+0x8>
    ;
  return os;
}
    53e6:	6422                	ld	s0,8(sp)
    53e8:	0141                	addi	sp,sp,16
    53ea:	8082                	ret

00000000000053ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
    53ec:	1141                	addi	sp,sp,-16
    53ee:	e422                	sd	s0,8(sp)
    53f0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    53f2:	00054783          	lbu	a5,0(a0)
    53f6:	cf91                	beqz	a5,5412 <strcmp+0x26>
    53f8:	0005c703          	lbu	a4,0(a1)
    53fc:	00f71b63          	bne	a4,a5,5412 <strcmp+0x26>
    p++, q++;
    5400:	0505                	addi	a0,a0,1
    5402:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    5404:	00054783          	lbu	a5,0(a0)
    5408:	c789                	beqz	a5,5412 <strcmp+0x26>
    540a:	0005c703          	lbu	a4,0(a1)
    540e:	fef709e3          	beq	a4,a5,5400 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
    5412:	0005c503          	lbu	a0,0(a1)
}
    5416:	40a7853b          	subw	a0,a5,a0
    541a:	6422                	ld	s0,8(sp)
    541c:	0141                	addi	sp,sp,16
    541e:	8082                	ret

0000000000005420 <strlen>:

uint
strlen(const char *s)
{
    5420:	1141                	addi	sp,sp,-16
    5422:	e422                	sd	s0,8(sp)
    5424:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    5426:	00054783          	lbu	a5,0(a0)
    542a:	cf91                	beqz	a5,5446 <strlen+0x26>
    542c:	0505                	addi	a0,a0,1
    542e:	87aa                	mv	a5,a0
    5430:	4685                	li	a3,1
    5432:	9e89                	subw	a3,a3,a0
    5434:	00f6853b          	addw	a0,a3,a5
    5438:	0785                	addi	a5,a5,1
    543a:	fff7c703          	lbu	a4,-1(a5)
    543e:	fb7d                	bnez	a4,5434 <strlen+0x14>
    ;
  return n;
}
    5440:	6422                	ld	s0,8(sp)
    5442:	0141                	addi	sp,sp,16
    5444:	8082                	ret
  for(n = 0; s[n]; n++)
    5446:	4501                	li	a0,0
    5448:	bfe5                	j	5440 <strlen+0x20>

000000000000544a <memset>:

void*
memset(void *dst, int c, uint n)
{
    544a:	1141                	addi	sp,sp,-16
    544c:	e422                	sd	s0,8(sp)
    544e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    5450:	ce09                	beqz	a2,546a <memset+0x20>
    5452:	87aa                	mv	a5,a0
    5454:	fff6071b          	addiw	a4,a2,-1
    5458:	1702                	slli	a4,a4,0x20
    545a:	9301                	srli	a4,a4,0x20
    545c:	0705                	addi	a4,a4,1
    545e:	972a                	add	a4,a4,a0
    cdst[i] = c;
    5460:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    5464:	0785                	addi	a5,a5,1
    5466:	fee79de3          	bne	a5,a4,5460 <memset+0x16>
  }
  return dst;
}
    546a:	6422                	ld	s0,8(sp)
    546c:	0141                	addi	sp,sp,16
    546e:	8082                	ret

0000000000005470 <strchr>:

char*
strchr(const char *s, char c)
{
    5470:	1141                	addi	sp,sp,-16
    5472:	e422                	sd	s0,8(sp)
    5474:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5476:	00054783          	lbu	a5,0(a0)
    547a:	cf91                	beqz	a5,5496 <strchr+0x26>
    if(*s == c)
    547c:	00f58a63          	beq	a1,a5,5490 <strchr+0x20>
  for(; *s; s++)
    5480:	0505                	addi	a0,a0,1
    5482:	00054783          	lbu	a5,0(a0)
    5486:	c781                	beqz	a5,548e <strchr+0x1e>
    if(*s == c)
    5488:	feb79ce3          	bne	a5,a1,5480 <strchr+0x10>
    548c:	a011                	j	5490 <strchr+0x20>
      return (char*)s;
  return 0;
    548e:	4501                	li	a0,0
}
    5490:	6422                	ld	s0,8(sp)
    5492:	0141                	addi	sp,sp,16
    5494:	8082                	ret
  return 0;
    5496:	4501                	li	a0,0
    5498:	bfe5                	j	5490 <strchr+0x20>

000000000000549a <gets>:

char*
gets(char *buf, int max)
{
    549a:	711d                	addi	sp,sp,-96
    549c:	ec86                	sd	ra,88(sp)
    549e:	e8a2                	sd	s0,80(sp)
    54a0:	e4a6                	sd	s1,72(sp)
    54a2:	e0ca                	sd	s2,64(sp)
    54a4:	fc4e                	sd	s3,56(sp)
    54a6:	f852                	sd	s4,48(sp)
    54a8:	f456                	sd	s5,40(sp)
    54aa:	f05a                	sd	s6,32(sp)
    54ac:	ec5e                	sd	s7,24(sp)
    54ae:	1080                	addi	s0,sp,96
    54b0:	8baa                	mv	s7,a0
    54b2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    54b4:	892a                	mv	s2,a0
    54b6:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    54b8:	4aa9                	li	s5,10
    54ba:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    54bc:	0019849b          	addiw	s1,s3,1
    54c0:	0344d863          	ble	s4,s1,54f0 <gets+0x56>
    cc = read(0, &c, 1);
    54c4:	4605                	li	a2,1
    54c6:	faf40593          	addi	a1,s0,-81
    54ca:	4501                	li	a0,0
    54cc:	00000097          	auipc	ra,0x0
    54d0:	1ac080e7          	jalr	428(ra) # 5678 <read>
    if(cc < 1)
    54d4:	00a05e63          	blez	a0,54f0 <gets+0x56>
    buf[i++] = c;
    54d8:	faf44783          	lbu	a5,-81(s0)
    54dc:	00f90023          	sb	a5,0(s2) # 5ff8 <malloc+0x560>
    if(c == '\n' || c == '\r')
    54e0:	01578763          	beq	a5,s5,54ee <gets+0x54>
    54e4:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
    54e6:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
    54e8:	fd679ae3          	bne	a5,s6,54bc <gets+0x22>
    54ec:	a011                	j	54f0 <gets+0x56>
  for(i=0; i+1 < max; ){
    54ee:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    54f0:	99de                	add	s3,s3,s7
    54f2:	00098023          	sb	zero,0(s3)
  return buf;
}
    54f6:	855e                	mv	a0,s7
    54f8:	60e6                	ld	ra,88(sp)
    54fa:	6446                	ld	s0,80(sp)
    54fc:	64a6                	ld	s1,72(sp)
    54fe:	6906                	ld	s2,64(sp)
    5500:	79e2                	ld	s3,56(sp)
    5502:	7a42                	ld	s4,48(sp)
    5504:	7aa2                	ld	s5,40(sp)
    5506:	7b02                	ld	s6,32(sp)
    5508:	6be2                	ld	s7,24(sp)
    550a:	6125                	addi	sp,sp,96
    550c:	8082                	ret

000000000000550e <stat>:

int
stat(const char *n, struct stat *st)
{
    550e:	1101                	addi	sp,sp,-32
    5510:	ec06                	sd	ra,24(sp)
    5512:	e822                	sd	s0,16(sp)
    5514:	e426                	sd	s1,8(sp)
    5516:	e04a                	sd	s2,0(sp)
    5518:	1000                	addi	s0,sp,32
    551a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    551c:	4581                	li	a1,0
    551e:	00000097          	auipc	ra,0x0
    5522:	182080e7          	jalr	386(ra) # 56a0 <open>
  if(fd < 0)
    5526:	02054563          	bltz	a0,5550 <stat+0x42>
    552a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    552c:	85ca                	mv	a1,s2
    552e:	00000097          	auipc	ra,0x0
    5532:	18a080e7          	jalr	394(ra) # 56b8 <fstat>
    5536:	892a                	mv	s2,a0
  close(fd);
    5538:	8526                	mv	a0,s1
    553a:	00000097          	auipc	ra,0x0
    553e:	14e080e7          	jalr	334(ra) # 5688 <close>
  return r;
}
    5542:	854a                	mv	a0,s2
    5544:	60e2                	ld	ra,24(sp)
    5546:	6442                	ld	s0,16(sp)
    5548:	64a2                	ld	s1,8(sp)
    554a:	6902                	ld	s2,0(sp)
    554c:	6105                	addi	sp,sp,32
    554e:	8082                	ret
    return -1;
    5550:	597d                	li	s2,-1
    5552:	bfc5                	j	5542 <stat+0x34>

0000000000005554 <atoi>:

int
atoi(const char *s)
{
    5554:	1141                	addi	sp,sp,-16
    5556:	e422                	sd	s0,8(sp)
    5558:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    555a:	00054683          	lbu	a3,0(a0)
    555e:	fd06879b          	addiw	a5,a3,-48
    5562:	0ff7f793          	andi	a5,a5,255
    5566:	4725                	li	a4,9
    5568:	02f76963          	bltu	a4,a5,559a <atoi+0x46>
    556c:	862a                	mv	a2,a0
  n = 0;
    556e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    5570:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    5572:	0605                	addi	a2,a2,1
    5574:	0025179b          	slliw	a5,a0,0x2
    5578:	9fa9                	addw	a5,a5,a0
    557a:	0017979b          	slliw	a5,a5,0x1
    557e:	9fb5                	addw	a5,a5,a3
    5580:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5584:	00064683          	lbu	a3,0(a2) # 3000 <dirtest+0x54>
    5588:	fd06871b          	addiw	a4,a3,-48
    558c:	0ff77713          	andi	a4,a4,255
    5590:	fee5f1e3          	bleu	a4,a1,5572 <atoi+0x1e>
  return n;
}
    5594:	6422                	ld	s0,8(sp)
    5596:	0141                	addi	sp,sp,16
    5598:	8082                	ret
  n = 0;
    559a:	4501                	li	a0,0
    559c:	bfe5                	j	5594 <atoi+0x40>

000000000000559e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    559e:	1141                	addi	sp,sp,-16
    55a0:	e422                	sd	s0,8(sp)
    55a2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    55a4:	02b57663          	bleu	a1,a0,55d0 <memmove+0x32>
    while(n-- > 0)
    55a8:	02c05163          	blez	a2,55ca <memmove+0x2c>
    55ac:	fff6079b          	addiw	a5,a2,-1
    55b0:	1782                	slli	a5,a5,0x20
    55b2:	9381                	srli	a5,a5,0x20
    55b4:	0785                	addi	a5,a5,1
    55b6:	97aa                	add	a5,a5,a0
  dst = vdst;
    55b8:	872a                	mv	a4,a0
      *dst++ = *src++;
    55ba:	0585                	addi	a1,a1,1
    55bc:	0705                	addi	a4,a4,1
    55be:	fff5c683          	lbu	a3,-1(a1)
    55c2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    55c6:	fee79ae3          	bne	a5,a4,55ba <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    55ca:	6422                	ld	s0,8(sp)
    55cc:	0141                	addi	sp,sp,16
    55ce:	8082                	ret
    dst += n;
    55d0:	00c50733          	add	a4,a0,a2
    src += n;
    55d4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    55d6:	fec05ae3          	blez	a2,55ca <memmove+0x2c>
    55da:	fff6079b          	addiw	a5,a2,-1
    55de:	1782                	slli	a5,a5,0x20
    55e0:	9381                	srli	a5,a5,0x20
    55e2:	fff7c793          	not	a5,a5
    55e6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    55e8:	15fd                	addi	a1,a1,-1
    55ea:	177d                	addi	a4,a4,-1
    55ec:	0005c683          	lbu	a3,0(a1)
    55f0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    55f4:	fef71ae3          	bne	a4,a5,55e8 <memmove+0x4a>
    55f8:	bfc9                	j	55ca <memmove+0x2c>

00000000000055fa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    55fa:	1141                	addi	sp,sp,-16
    55fc:	e422                	sd	s0,8(sp)
    55fe:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5600:	ce15                	beqz	a2,563c <memcmp+0x42>
    5602:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
    5606:	00054783          	lbu	a5,0(a0)
    560a:	0005c703          	lbu	a4,0(a1)
    560e:	02e79063          	bne	a5,a4,562e <memcmp+0x34>
    5612:	1682                	slli	a3,a3,0x20
    5614:	9281                	srli	a3,a3,0x20
    5616:	0685                	addi	a3,a3,1
    5618:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
    561a:	0505                	addi	a0,a0,1
    p2++;
    561c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    561e:	00d50d63          	beq	a0,a3,5638 <memcmp+0x3e>
    if (*p1 != *p2) {
    5622:	00054783          	lbu	a5,0(a0)
    5626:	0005c703          	lbu	a4,0(a1)
    562a:	fee788e3          	beq	a5,a4,561a <memcmp+0x20>
      return *p1 - *p2;
    562e:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
    5632:	6422                	ld	s0,8(sp)
    5634:	0141                	addi	sp,sp,16
    5636:	8082                	ret
  return 0;
    5638:	4501                	li	a0,0
    563a:	bfe5                	j	5632 <memcmp+0x38>
    563c:	4501                	li	a0,0
    563e:	bfd5                	j	5632 <memcmp+0x38>

0000000000005640 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5640:	1141                	addi	sp,sp,-16
    5642:	e406                	sd	ra,8(sp)
    5644:	e022                	sd	s0,0(sp)
    5646:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5648:	00000097          	auipc	ra,0x0
    564c:	f56080e7          	jalr	-170(ra) # 559e <memmove>
}
    5650:	60a2                	ld	ra,8(sp)
    5652:	6402                	ld	s0,0(sp)
    5654:	0141                	addi	sp,sp,16
    5656:	8082                	ret

0000000000005658 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5658:	4885                	li	a7,1
 ecall
    565a:	00000073          	ecall
 ret
    565e:	8082                	ret

0000000000005660 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5660:	4889                	li	a7,2
 ecall
    5662:	00000073          	ecall
 ret
    5666:	8082                	ret

0000000000005668 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5668:	488d                	li	a7,3
 ecall
    566a:	00000073          	ecall
 ret
    566e:	8082                	ret

0000000000005670 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5670:	4891                	li	a7,4
 ecall
    5672:	00000073          	ecall
 ret
    5676:	8082                	ret

0000000000005678 <read>:
.global read
read:
 li a7, SYS_read
    5678:	4895                	li	a7,5
 ecall
    567a:	00000073          	ecall
 ret
    567e:	8082                	ret

0000000000005680 <write>:
.global write
write:
 li a7, SYS_write
    5680:	48c1                	li	a7,16
 ecall
    5682:	00000073          	ecall
 ret
    5686:	8082                	ret

0000000000005688 <close>:
.global close
close:
 li a7, SYS_close
    5688:	48d5                	li	a7,21
 ecall
    568a:	00000073          	ecall
 ret
    568e:	8082                	ret

0000000000005690 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5690:	4899                	li	a7,6
 ecall
    5692:	00000073          	ecall
 ret
    5696:	8082                	ret

0000000000005698 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5698:	489d                	li	a7,7
 ecall
    569a:	00000073          	ecall
 ret
    569e:	8082                	ret

00000000000056a0 <open>:
.global open
open:
 li a7, SYS_open
    56a0:	48bd                	li	a7,15
 ecall
    56a2:	00000073          	ecall
 ret
    56a6:	8082                	ret

00000000000056a8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    56a8:	48c5                	li	a7,17
 ecall
    56aa:	00000073          	ecall
 ret
    56ae:	8082                	ret

00000000000056b0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    56b0:	48c9                	li	a7,18
 ecall
    56b2:	00000073          	ecall
 ret
    56b6:	8082                	ret

00000000000056b8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    56b8:	48a1                	li	a7,8
 ecall
    56ba:	00000073          	ecall
 ret
    56be:	8082                	ret

00000000000056c0 <link>:
.global link
link:
 li a7, SYS_link
    56c0:	48cd                	li	a7,19
 ecall
    56c2:	00000073          	ecall
 ret
    56c6:	8082                	ret

00000000000056c8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    56c8:	48d1                	li	a7,20
 ecall
    56ca:	00000073          	ecall
 ret
    56ce:	8082                	ret

00000000000056d0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    56d0:	48a5                	li	a7,9
 ecall
    56d2:	00000073          	ecall
 ret
    56d6:	8082                	ret

00000000000056d8 <dup>:
.global dup
dup:
 li a7, SYS_dup
    56d8:	48a9                	li	a7,10
 ecall
    56da:	00000073          	ecall
 ret
    56de:	8082                	ret

00000000000056e0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    56e0:	48ad                	li	a7,11
 ecall
    56e2:	00000073          	ecall
 ret
    56e6:	8082                	ret

00000000000056e8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    56e8:	48b1                	li	a7,12
 ecall
    56ea:	00000073          	ecall
 ret
    56ee:	8082                	ret

00000000000056f0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    56f0:	48b5                	li	a7,13
 ecall
    56f2:	00000073          	ecall
 ret
    56f6:	8082                	ret

00000000000056f8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    56f8:	48b9                	li	a7,14
 ecall
    56fa:	00000073          	ecall
 ret
    56fe:	8082                	ret

0000000000005700 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5700:	1101                	addi	sp,sp,-32
    5702:	ec06                	sd	ra,24(sp)
    5704:	e822                	sd	s0,16(sp)
    5706:	1000                	addi	s0,sp,32
    5708:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    570c:	4605                	li	a2,1
    570e:	fef40593          	addi	a1,s0,-17
    5712:	00000097          	auipc	ra,0x0
    5716:	f6e080e7          	jalr	-146(ra) # 5680 <write>
}
    571a:	60e2                	ld	ra,24(sp)
    571c:	6442                	ld	s0,16(sp)
    571e:	6105                	addi	sp,sp,32
    5720:	8082                	ret

0000000000005722 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5722:	7139                	addi	sp,sp,-64
    5724:	fc06                	sd	ra,56(sp)
    5726:	f822                	sd	s0,48(sp)
    5728:	f426                	sd	s1,40(sp)
    572a:	f04a                	sd	s2,32(sp)
    572c:	ec4e                	sd	s3,24(sp)
    572e:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    5730:	c299                	beqz	a3,5736 <printint+0x14>
    5732:	0005cd63          	bltz	a1,574c <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5736:	2581                	sext.w	a1,a1
  neg = 0;
    5738:	4301                	li	t1,0
    573a:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
    573e:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
    5740:	2601                	sext.w	a2,a2
    5742:	00003897          	auipc	a7,0x3
    5746:	b5e88893          	addi	a7,a7,-1186 # 82a0 <digits>
    574a:	a801                	j	575a <printint+0x38>
    x = -xx;
    574c:	40b005bb          	negw	a1,a1
    5750:	2581                	sext.w	a1,a1
    neg = 1;
    5752:	4305                	li	t1,1
    x = -xx;
    5754:	b7dd                	j	573a <printint+0x18>
  }while((x /= base) != 0);
    5756:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
    5758:	8836                	mv	a6,a3
    575a:	0018069b          	addiw	a3,a6,1
    575e:	02c5f7bb          	remuw	a5,a1,a2
    5762:	1782                	slli	a5,a5,0x20
    5764:	9381                	srli	a5,a5,0x20
    5766:	97c6                	add	a5,a5,a7
    5768:	0007c783          	lbu	a5,0(a5)
    576c:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
    5770:	0705                	addi	a4,a4,1
    5772:	02c5d7bb          	divuw	a5,a1,a2
    5776:	fec5f0e3          	bleu	a2,a1,5756 <printint+0x34>
  if(neg)
    577a:	00030b63          	beqz	t1,5790 <printint+0x6e>
    buf[i++] = '-';
    577e:	fd040793          	addi	a5,s0,-48
    5782:	96be                	add	a3,a3,a5
    5784:	02d00793          	li	a5,45
    5788:	fef68823          	sb	a5,-16(a3) # ff0 <bigdir+0x7c>
    578c:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
    5790:	02d05963          	blez	a3,57c2 <printint+0xa0>
    5794:	89aa                	mv	s3,a0
    5796:	fc040793          	addi	a5,s0,-64
    579a:	00d784b3          	add	s1,a5,a3
    579e:	fff78913          	addi	s2,a5,-1
    57a2:	9936                	add	s2,s2,a3
    57a4:	36fd                	addiw	a3,a3,-1
    57a6:	1682                	slli	a3,a3,0x20
    57a8:	9281                	srli	a3,a3,0x20
    57aa:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
    57ae:	fff4c583          	lbu	a1,-1(s1)
    57b2:	854e                	mv	a0,s3
    57b4:	00000097          	auipc	ra,0x0
    57b8:	f4c080e7          	jalr	-180(ra) # 5700 <putc>
  while(--i >= 0)
    57bc:	14fd                	addi	s1,s1,-1
    57be:	ff2498e3          	bne	s1,s2,57ae <printint+0x8c>
}
    57c2:	70e2                	ld	ra,56(sp)
    57c4:	7442                	ld	s0,48(sp)
    57c6:	74a2                	ld	s1,40(sp)
    57c8:	7902                	ld	s2,32(sp)
    57ca:	69e2                	ld	s3,24(sp)
    57cc:	6121                	addi	sp,sp,64
    57ce:	8082                	ret

00000000000057d0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    57d0:	7119                	addi	sp,sp,-128
    57d2:	fc86                	sd	ra,120(sp)
    57d4:	f8a2                	sd	s0,112(sp)
    57d6:	f4a6                	sd	s1,104(sp)
    57d8:	f0ca                	sd	s2,96(sp)
    57da:	ecce                	sd	s3,88(sp)
    57dc:	e8d2                	sd	s4,80(sp)
    57de:	e4d6                	sd	s5,72(sp)
    57e0:	e0da                	sd	s6,64(sp)
    57e2:	fc5e                	sd	s7,56(sp)
    57e4:	f862                	sd	s8,48(sp)
    57e6:	f466                	sd	s9,40(sp)
    57e8:	f06a                	sd	s10,32(sp)
    57ea:	ec6e                	sd	s11,24(sp)
    57ec:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    57ee:	0005c483          	lbu	s1,0(a1)
    57f2:	18048d63          	beqz	s1,598c <vprintf+0x1bc>
    57f6:	8aaa                	mv	s5,a0
    57f8:	8b32                	mv	s6,a2
    57fa:	00158913          	addi	s2,a1,1
  state = 0;
    57fe:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    5800:	02500a13          	li	s4,37
      if(c == 'd'){
    5804:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    5808:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    580c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    5810:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5814:	00003b97          	auipc	s7,0x3
    5818:	a8cb8b93          	addi	s7,s7,-1396 # 82a0 <digits>
    581c:	a839                	j	583a <vprintf+0x6a>
        putc(fd, c);
    581e:	85a6                	mv	a1,s1
    5820:	8556                	mv	a0,s5
    5822:	00000097          	auipc	ra,0x0
    5826:	ede080e7          	jalr	-290(ra) # 5700 <putc>
    582a:	a019                	j	5830 <vprintf+0x60>
    } else if(state == '%'){
    582c:	01498f63          	beq	s3,s4,584a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    5830:	0905                	addi	s2,s2,1
    5832:	fff94483          	lbu	s1,-1(s2)
    5836:	14048b63          	beqz	s1,598c <vprintf+0x1bc>
    c = fmt[i] & 0xff;
    583a:	0004879b          	sext.w	a5,s1
    if(state == 0){
    583e:	fe0997e3          	bnez	s3,582c <vprintf+0x5c>
      if(c == '%'){
    5842:	fd479ee3          	bne	a5,s4,581e <vprintf+0x4e>
        state = '%';
    5846:	89be                	mv	s3,a5
    5848:	b7e5                	j	5830 <vprintf+0x60>
      if(c == 'd'){
    584a:	05878063          	beq	a5,s8,588a <vprintf+0xba>
      } else if(c == 'l') {
    584e:	05978c63          	beq	a5,s9,58a6 <vprintf+0xd6>
      } else if(c == 'x') {
    5852:	07a78863          	beq	a5,s10,58c2 <vprintf+0xf2>
      } else if(c == 'p') {
    5856:	09b78463          	beq	a5,s11,58de <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    585a:	07300713          	li	a4,115
    585e:	0ce78563          	beq	a5,a4,5928 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5862:	06300713          	li	a4,99
    5866:	0ee78c63          	beq	a5,a4,595e <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    586a:	11478663          	beq	a5,s4,5976 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    586e:	85d2                	mv	a1,s4
    5870:	8556                	mv	a0,s5
    5872:	00000097          	auipc	ra,0x0
    5876:	e8e080e7          	jalr	-370(ra) # 5700 <putc>
        putc(fd, c);
    587a:	85a6                	mv	a1,s1
    587c:	8556                	mv	a0,s5
    587e:	00000097          	auipc	ra,0x0
    5882:	e82080e7          	jalr	-382(ra) # 5700 <putc>
      }
      state = 0;
    5886:	4981                	li	s3,0
    5888:	b765                	j	5830 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    588a:	008b0493          	addi	s1,s6,8
    588e:	4685                	li	a3,1
    5890:	4629                	li	a2,10
    5892:	000b2583          	lw	a1,0(s6)
    5896:	8556                	mv	a0,s5
    5898:	00000097          	auipc	ra,0x0
    589c:	e8a080e7          	jalr	-374(ra) # 5722 <printint>
    58a0:	8b26                	mv	s6,s1
      state = 0;
    58a2:	4981                	li	s3,0
    58a4:	b771                	j	5830 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    58a6:	008b0493          	addi	s1,s6,8
    58aa:	4681                	li	a3,0
    58ac:	4629                	li	a2,10
    58ae:	000b2583          	lw	a1,0(s6)
    58b2:	8556                	mv	a0,s5
    58b4:	00000097          	auipc	ra,0x0
    58b8:	e6e080e7          	jalr	-402(ra) # 5722 <printint>
    58bc:	8b26                	mv	s6,s1
      state = 0;
    58be:	4981                	li	s3,0
    58c0:	bf85                	j	5830 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    58c2:	008b0493          	addi	s1,s6,8
    58c6:	4681                	li	a3,0
    58c8:	4641                	li	a2,16
    58ca:	000b2583          	lw	a1,0(s6)
    58ce:	8556                	mv	a0,s5
    58d0:	00000097          	auipc	ra,0x0
    58d4:	e52080e7          	jalr	-430(ra) # 5722 <printint>
    58d8:	8b26                	mv	s6,s1
      state = 0;
    58da:	4981                	li	s3,0
    58dc:	bf91                	j	5830 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    58de:	008b0793          	addi	a5,s6,8
    58e2:	f8f43423          	sd	a5,-120(s0)
    58e6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    58ea:	03000593          	li	a1,48
    58ee:	8556                	mv	a0,s5
    58f0:	00000097          	auipc	ra,0x0
    58f4:	e10080e7          	jalr	-496(ra) # 5700 <putc>
  putc(fd, 'x');
    58f8:	85ea                	mv	a1,s10
    58fa:	8556                	mv	a0,s5
    58fc:	00000097          	auipc	ra,0x0
    5900:	e04080e7          	jalr	-508(ra) # 5700 <putc>
    5904:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5906:	03c9d793          	srli	a5,s3,0x3c
    590a:	97de                	add	a5,a5,s7
    590c:	0007c583          	lbu	a1,0(a5)
    5910:	8556                	mv	a0,s5
    5912:	00000097          	auipc	ra,0x0
    5916:	dee080e7          	jalr	-530(ra) # 5700 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    591a:	0992                	slli	s3,s3,0x4
    591c:	34fd                	addiw	s1,s1,-1
    591e:	f4e5                	bnez	s1,5906 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    5920:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5924:	4981                	li	s3,0
    5926:	b729                	j	5830 <vprintf+0x60>
        s = va_arg(ap, char*);
    5928:	008b0993          	addi	s3,s6,8
    592c:	000b3483          	ld	s1,0(s6)
        if(s == 0)
    5930:	c085                	beqz	s1,5950 <vprintf+0x180>
        while(*s != 0){
    5932:	0004c583          	lbu	a1,0(s1)
    5936:	c9a1                	beqz	a1,5986 <vprintf+0x1b6>
          putc(fd, *s);
    5938:	8556                	mv	a0,s5
    593a:	00000097          	auipc	ra,0x0
    593e:	dc6080e7          	jalr	-570(ra) # 5700 <putc>
          s++;
    5942:	0485                	addi	s1,s1,1
        while(*s != 0){
    5944:	0004c583          	lbu	a1,0(s1)
    5948:	f9e5                	bnez	a1,5938 <vprintf+0x168>
        s = va_arg(ap, char*);
    594a:	8b4e                	mv	s6,s3
      state = 0;
    594c:	4981                	li	s3,0
    594e:	b5cd                	j	5830 <vprintf+0x60>
          s = "(null)";
    5950:	00003497          	auipc	s1,0x3
    5954:	96848493          	addi	s1,s1,-1688 # 82b8 <digits+0x18>
        while(*s != 0){
    5958:	02800593          	li	a1,40
    595c:	bff1                	j	5938 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
    595e:	008b0493          	addi	s1,s6,8
    5962:	000b4583          	lbu	a1,0(s6)
    5966:	8556                	mv	a0,s5
    5968:	00000097          	auipc	ra,0x0
    596c:	d98080e7          	jalr	-616(ra) # 5700 <putc>
    5970:	8b26                	mv	s6,s1
      state = 0;
    5972:	4981                	li	s3,0
    5974:	bd75                	j	5830 <vprintf+0x60>
        putc(fd, c);
    5976:	85d2                	mv	a1,s4
    5978:	8556                	mv	a0,s5
    597a:	00000097          	auipc	ra,0x0
    597e:	d86080e7          	jalr	-634(ra) # 5700 <putc>
      state = 0;
    5982:	4981                	li	s3,0
    5984:	b575                	j	5830 <vprintf+0x60>
        s = va_arg(ap, char*);
    5986:	8b4e                	mv	s6,s3
      state = 0;
    5988:	4981                	li	s3,0
    598a:	b55d                	j	5830 <vprintf+0x60>
    }
  }
}
    598c:	70e6                	ld	ra,120(sp)
    598e:	7446                	ld	s0,112(sp)
    5990:	74a6                	ld	s1,104(sp)
    5992:	7906                	ld	s2,96(sp)
    5994:	69e6                	ld	s3,88(sp)
    5996:	6a46                	ld	s4,80(sp)
    5998:	6aa6                	ld	s5,72(sp)
    599a:	6b06                	ld	s6,64(sp)
    599c:	7be2                	ld	s7,56(sp)
    599e:	7c42                	ld	s8,48(sp)
    59a0:	7ca2                	ld	s9,40(sp)
    59a2:	7d02                	ld	s10,32(sp)
    59a4:	6de2                	ld	s11,24(sp)
    59a6:	6109                	addi	sp,sp,128
    59a8:	8082                	ret

00000000000059aa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    59aa:	715d                	addi	sp,sp,-80
    59ac:	ec06                	sd	ra,24(sp)
    59ae:	e822                	sd	s0,16(sp)
    59b0:	1000                	addi	s0,sp,32
    59b2:	e010                	sd	a2,0(s0)
    59b4:	e414                	sd	a3,8(s0)
    59b6:	e818                	sd	a4,16(s0)
    59b8:	ec1c                	sd	a5,24(s0)
    59ba:	03043023          	sd	a6,32(s0)
    59be:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    59c2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    59c6:	8622                	mv	a2,s0
    59c8:	00000097          	auipc	ra,0x0
    59cc:	e08080e7          	jalr	-504(ra) # 57d0 <vprintf>
}
    59d0:	60e2                	ld	ra,24(sp)
    59d2:	6442                	ld	s0,16(sp)
    59d4:	6161                	addi	sp,sp,80
    59d6:	8082                	ret

00000000000059d8 <printf>:

void
printf(const char *fmt, ...)
{
    59d8:	711d                	addi	sp,sp,-96
    59da:	ec06                	sd	ra,24(sp)
    59dc:	e822                	sd	s0,16(sp)
    59de:	1000                	addi	s0,sp,32
    59e0:	e40c                	sd	a1,8(s0)
    59e2:	e810                	sd	a2,16(s0)
    59e4:	ec14                	sd	a3,24(s0)
    59e6:	f018                	sd	a4,32(s0)
    59e8:	f41c                	sd	a5,40(s0)
    59ea:	03043823          	sd	a6,48(s0)
    59ee:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    59f2:	00840613          	addi	a2,s0,8
    59f6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    59fa:	85aa                	mv	a1,a0
    59fc:	4505                	li	a0,1
    59fe:	00000097          	auipc	ra,0x0
    5a02:	dd2080e7          	jalr	-558(ra) # 57d0 <vprintf>
}
    5a06:	60e2                	ld	ra,24(sp)
    5a08:	6442                	ld	s0,16(sp)
    5a0a:	6125                	addi	sp,sp,96
    5a0c:	8082                	ret

0000000000005a0e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5a0e:	1141                	addi	sp,sp,-16
    5a10:	e422                	sd	s0,8(sp)
    5a12:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5a14:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5a18:	00003797          	auipc	a5,0x3
    5a1c:	8b878793          	addi	a5,a5,-1864 # 82d0 <_edata>
    5a20:	639c                	ld	a5,0(a5)
    5a22:	a805                	j	5a52 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5a24:	4618                	lw	a4,8(a2)
    5a26:	9db9                	addw	a1,a1,a4
    5a28:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5a2c:	6398                	ld	a4,0(a5)
    5a2e:	6318                	ld	a4,0(a4)
    5a30:	fee53823          	sd	a4,-16(a0)
    5a34:	a091                	j	5a78 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5a36:	ff852703          	lw	a4,-8(a0)
    5a3a:	9e39                	addw	a2,a2,a4
    5a3c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5a3e:	ff053703          	ld	a4,-16(a0)
    5a42:	e398                	sd	a4,0(a5)
    5a44:	a099                	j	5a8a <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5a46:	6398                	ld	a4,0(a5)
    5a48:	00e7e463          	bltu	a5,a4,5a50 <free+0x42>
    5a4c:	00e6ea63          	bltu	a3,a4,5a60 <free+0x52>
{
    5a50:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5a52:	fed7fae3          	bleu	a3,a5,5a46 <free+0x38>
    5a56:	6398                	ld	a4,0(a5)
    5a58:	00e6e463          	bltu	a3,a4,5a60 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5a5c:	fee7eae3          	bltu	a5,a4,5a50 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
    5a60:	ff852583          	lw	a1,-8(a0)
    5a64:	6390                	ld	a2,0(a5)
    5a66:	02059713          	slli	a4,a1,0x20
    5a6a:	9301                	srli	a4,a4,0x20
    5a6c:	0712                	slli	a4,a4,0x4
    5a6e:	9736                	add	a4,a4,a3
    5a70:	fae60ae3          	beq	a2,a4,5a24 <free+0x16>
    bp->s.ptr = p->s.ptr;
    5a74:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5a78:	4790                	lw	a2,8(a5)
    5a7a:	02061713          	slli	a4,a2,0x20
    5a7e:	9301                	srli	a4,a4,0x20
    5a80:	0712                	slli	a4,a4,0x4
    5a82:	973e                	add	a4,a4,a5
    5a84:	fae689e3          	beq	a3,a4,5a36 <free+0x28>
  } else
    p->s.ptr = bp;
    5a88:	e394                	sd	a3,0(a5)
  freep = p;
    5a8a:	00003717          	auipc	a4,0x3
    5a8e:	84f73323          	sd	a5,-1978(a4) # 82d0 <_edata>
}
    5a92:	6422                	ld	s0,8(sp)
    5a94:	0141                	addi	sp,sp,16
    5a96:	8082                	ret

0000000000005a98 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5a98:	7139                	addi	sp,sp,-64
    5a9a:	fc06                	sd	ra,56(sp)
    5a9c:	f822                	sd	s0,48(sp)
    5a9e:	f426                	sd	s1,40(sp)
    5aa0:	f04a                	sd	s2,32(sp)
    5aa2:	ec4e                	sd	s3,24(sp)
    5aa4:	e852                	sd	s4,16(sp)
    5aa6:	e456                	sd	s5,8(sp)
    5aa8:	e05a                	sd	s6,0(sp)
    5aaa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5aac:	02051993          	slli	s3,a0,0x20
    5ab0:	0209d993          	srli	s3,s3,0x20
    5ab4:	09bd                	addi	s3,s3,15
    5ab6:	0049d993          	srli	s3,s3,0x4
    5aba:	2985                	addiw	s3,s3,1
    5abc:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
    5ac0:	00003797          	auipc	a5,0x3
    5ac4:	81078793          	addi	a5,a5,-2032 # 82d0 <_edata>
    5ac8:	6388                	ld	a0,0(a5)
    5aca:	c515                	beqz	a0,5af6 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5acc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5ace:	4798                	lw	a4,8(a5)
    5ad0:	03277f63          	bleu	s2,a4,5b0e <malloc+0x76>
    5ad4:	8a4e                	mv	s4,s3
    5ad6:	0009871b          	sext.w	a4,s3
    5ada:	6685                	lui	a3,0x1
    5adc:	00d77363          	bleu	a3,a4,5ae2 <malloc+0x4a>
    5ae0:	6a05                	lui	s4,0x1
    5ae2:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
    5ae6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5aea:	00002497          	auipc	s1,0x2
    5aee:	7e648493          	addi	s1,s1,2022 # 82d0 <_edata>
  if(p == (char*)-1)
    5af2:	5b7d                	li	s6,-1
    5af4:	a885                	j	5b64 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
    5af6:	00009797          	auipc	a5,0x9
    5afa:	ffa78793          	addi	a5,a5,-6 # eaf0 <base>
    5afe:	00002717          	auipc	a4,0x2
    5b02:	7cf73923          	sd	a5,2002(a4) # 82d0 <_edata>
    5b06:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5b08:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5b0c:	b7e1                	j	5ad4 <malloc+0x3c>
      if(p->s.size == nunits)
    5b0e:	02e90b63          	beq	s2,a4,5b44 <malloc+0xac>
        p->s.size -= nunits;
    5b12:	4137073b          	subw	a4,a4,s3
    5b16:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5b18:	1702                	slli	a4,a4,0x20
    5b1a:	9301                	srli	a4,a4,0x20
    5b1c:	0712                	slli	a4,a4,0x4
    5b1e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5b20:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5b24:	00002717          	auipc	a4,0x2
    5b28:	7aa73623          	sd	a0,1964(a4) # 82d0 <_edata>
      return (void*)(p + 1);
    5b2c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5b30:	70e2                	ld	ra,56(sp)
    5b32:	7442                	ld	s0,48(sp)
    5b34:	74a2                	ld	s1,40(sp)
    5b36:	7902                	ld	s2,32(sp)
    5b38:	69e2                	ld	s3,24(sp)
    5b3a:	6a42                	ld	s4,16(sp)
    5b3c:	6aa2                	ld	s5,8(sp)
    5b3e:	6b02                	ld	s6,0(sp)
    5b40:	6121                	addi	sp,sp,64
    5b42:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5b44:	6398                	ld	a4,0(a5)
    5b46:	e118                	sd	a4,0(a0)
    5b48:	bff1                	j	5b24 <malloc+0x8c>
  hp->s.size = nu;
    5b4a:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
    5b4e:	0541                	addi	a0,a0,16
    5b50:	00000097          	auipc	ra,0x0
    5b54:	ebe080e7          	jalr	-322(ra) # 5a0e <free>
  return freep;
    5b58:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
    5b5a:	d979                	beqz	a0,5b30 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5b5c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5b5e:	4798                	lw	a4,8(a5)
    5b60:	fb2777e3          	bleu	s2,a4,5b0e <malloc+0x76>
    if(p == freep)
    5b64:	6098                	ld	a4,0(s1)
    5b66:	853e                	mv	a0,a5
    5b68:	fef71ae3          	bne	a4,a5,5b5c <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
    5b6c:	8552                	mv	a0,s4
    5b6e:	00000097          	auipc	ra,0x0
    5b72:	b7a080e7          	jalr	-1158(ra) # 56e8 <sbrk>
  if(p == (char*)-1)
    5b76:	fd651ae3          	bne	a0,s6,5b4a <malloc+0xb2>
        return 0;
    5b7a:	4501                	li	a0,0
    5b7c:	bf55                	j	5b30 <malloc+0x98>
